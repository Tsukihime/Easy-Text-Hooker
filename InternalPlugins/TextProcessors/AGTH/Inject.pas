unit Inject;

interface

uses
  Windows,
  tlhelp32,
  sysutils,
  Classes;

type
  THooker = class
  public
    class procedure GetProcessList(List: TStrings);
    class function HookProcess(processId: Cardinal;
      AGTHCommandLine: string): boolean;
    class function IsHooked(processId: Cardinal): boolean;
  private
    class function GenerateHCode(AGTHcmd: string): string;
    class function InjectDll(Process: DWORD;
      ModulePath, HCode: WideString): boolean;
  end;

  TInject = packed record
    // code
    cmd0: BYTE;
    cmd1: BYTE;
    cmd1arg: DWORD;
    cmd2: BYTE;
    cmd2arg: DWORD;
    cmd3: WORD;
    cmd3arg: DWORD;
    cmd4: BYTE;
    cmd4arg: DWORD;
    cmd5: WORD;
    cmd5arg: DWORD;
    cmd6: BYTE;
    cmd6arg: DWORD;
    cmd7: WORD;
    cmd7arg: DWORD;
    // data
    pLoadLibrary: Pointer;
    pExitThread: Pointer;
    pSetEnvironmentVariableW: Pointer;
    ENVName: array [0 .. 4] of WideChar;
    ENVValue: array [0 .. MAX_PATH] of WideChar;
    LibraryPath: array [0 .. MAX_PATH] of WideChar;
  end;

const
  PROCESS_SYSTEM_CONTEXT = $01;
  HOOK_SET_1 = $02;
  HOOK_SET_2 = $04;
  USE_THREAD_CODEPAGE = $08;
  NO_HOOK_CHILD = $10;
  NO_DEF_HOOKS = $20;

const // asm cmd
  PUSH: BYTE = $68;
  CALL_DWORD_PTR: WORD = $15FF;
  INT3: BYTE = $CC;
  NOP: BYTE = $90;

const
  INTERCEPT_MODULE_NAME: string = 'agth.dll';

implementation

{ Внедрение Dll в процесс }
class function THooker.InjectDll(Process: DWORD;
  ModulePath, HCode: WideString): boolean;
var
  Memory: Pointer;
  CodeBase: DWORD;
  BytesWritten: SIZE_T;
  ThreadId: DWORD;
  hThread: DWORD;
  hKernel32: DWORD;
  Inject: TInject;

  function RebasePtr(ptr: Pointer): DWORD;
  begin
    Result := CodeBase + DWORD(ptr) - DWORD(@Inject);
  end;

begin
  Result := false;
  Memory := VirtualAllocEx(Process, nil, sizeof(Inject), MEM_TOP_DOWN or
    MEM_COMMIT, PAGE_EXECUTE_READWRITE);
  if Memory = nil then
    Exit;

  CodeBase := DWORD(Memory);
  hKernel32 := GetModuleHandle('kernel32.dll');

  // инициализация внедряемого кода:
  FillChar(Inject, sizeof(Inject), 0);
  with Inject do
  begin
    // code
    cmd0 := NOP;
    cmd1 := PUSH;
    cmd1arg := RebasePtr(@ENVValue);
    cmd2 := PUSH;
    cmd2arg := RebasePtr(@ENVName);
    cmd3 := CALL_DWORD_PTR;
    cmd3arg := RebasePtr(@pSetEnvironmentVariableW);
    cmd4 := PUSH;
    cmd4arg := RebasePtr(@LibraryPath);
    cmd5 := CALL_DWORD_PTR;
    cmd5arg := RebasePtr(@pLoadLibrary);
    cmd6 := PUSH;
    cmd6arg := 0;
    cmd7 := CALL_DWORD_PTR;
    cmd7arg := RebasePtr(@pExitThread);
    // data
    // тут происходит магия основанная на том,
    // что ImageBase kernel32.dll во всех процессах одинаков
    // это справедливо лишь для kernel32.dll только
    pLoadLibrary := GetProcAddress(hKernel32, 'LoadLibraryW');
    pExitThread := GetProcAddress(hKernel32, 'ExitThread');
    pSetEnvironmentVariableW := GetProcAddress(hKernel32,
      'SetEnvironmentVariableW');
    lstrcpy(@LibraryPath, PWideChar(ModulePath));
    lstrcpy(@ENVName, PWideChar('AGTH'));
    lstrcpy(@ENVValue, PWideChar(HCode));
  end;
  // записать машинный код по зарезервированному адресу
  WriteProcessMemory(Process, Memory, @Inject, SIZE_T(sizeof(Inject)),
    BytesWritten);
  // выполнить машинный код
  hThread := CreateRemoteThread(Process, nil, 0, Memory, nil, 0, ThreadId);
  if hThread = 0 then
    Exit;
  WaitForSingleObject(hThread, INFINITE);
  CloseHandle(hThread);
  VirtualFreeEx(Process, Memory, 0, MEM_RELEASE);
  // надо-надо умываться по утрам и вечерам
  Result := true;
end;

class function THooker.IsHooked(processId: Cardinal): boolean;
var
  ContinueLoop: BOOL;
  SnapshotHandle: THandle;
  ModuleEntry32: TModuleEntry32;
  ModuleName: string;
begin
  Result := false;
  SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, processId);
  ModuleEntry32.dwSize := sizeof(ModuleEntry32);
  ContinueLoop := Module32First(SnapshotHandle, ModuleEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    ModuleName := ModuleEntry32.szModule;
    ModuleName := LowerCase(ModuleName);
    if ModuleName = INTERCEPT_MODULE_NAME then
    begin
      Result := true;
      break;
    end;
    ContinueLoop := Module32Next(SnapshotHandle, ModuleEntry32);
  end;
  CloseHandle(SnapshotHandle);
end;

class procedure THooker.GetProcessList(List: TStrings);
var
  ContinueLoop: BOOL;
  FSnapshotHandle: THandle;
  FProcessEntry32: TPROCESSENTRY32;
begin
  List.Clear;
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := sizeof(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  while Integer(ContinueLoop) <> 0 do
  begin
    if FProcessEntry32.th32ProcessID <> 0 then
      List.AddObject(FProcessEntry32.szExeFile,
        TObject(FProcessEntry32.th32ProcessID));
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

class function THooker.GenerateHCode(AGTHcmd: string): string;
var
  i: Integer;
  lcmd, uFlag, sFlag: string;
  flags: BYTE;
begin
  lcmd := LowerCase(AGTHcmd);
  flags := 0;

  if pos('/nh', lcmd) > 0 then
    flags := flags or NO_DEF_HOOKS;
  if pos('/nc', lcmd) > 0 then
    flags := flags or NO_HOOK_CHILD;
  if pos('/nj', lcmd) > 0 then
    flags := flags or USE_THREAD_CODEPAGE;
  if pos('/v', lcmd) > 0 then
    flags := flags or PROCESS_SYSTEM_CONTEXT;

  if pos('/x3', lcmd) > 0 then
    flags := flags or (HOOK_SET_1 or HOOK_SET_2)
  else if pos('/x2', lcmd) > 0 then
    flags := flags or HOOK_SET_2
  else if pos('/x', lcmd) > 0 then
    flags := flags or HOOK_SET_1;

  // выгребаем все между /h и пробелом и в начало ставим символ U
  i := pos('/h', lcmd);
  if i > 0 then
  begin
    uFlag := copy(AGTHcmd, i, length(AGTHcmd) - (i - 1)); // /h -> endstr
    delete(uFlag, 1, 2); // del /h
    i := pos(' ', uFlag);
    if i > 0 then
      delete(uFlag, i, length(uFlag) - (i - 1));
    uFlag := 'U' + uFlag;
  end
  else
    uFlag := '';

  // выгребаем все между /s и пробелом и в начало ставим символы S0:
  i := pos('/s', lcmd);
  if i > 0 then
  begin
    sFlag := copy(AGTHcmd, i, length(AGTHcmd) - (i - 1));
    delete(sFlag, 1, 2); // del /s
    i := pos(' ', sFlag);
    if i > 0 then
      delete(sFlag, i, length(sFlag) - (i - 1));
    sFlag := 'S0:' + sFlag;
  end
  else
    sFlag := '';

  Result := IntToHex(flags, 1) + sFlag + uFlag;
end;

class function THooker.HookProcess(processId: Cardinal;
  AGTHCommandLine: string): boolean;
var
  HCode: string;
  pHwnd: THandle;
  ModPath: string;
begin
  Result := false;
  HCode := GenerateHCode(AGTHCommandLine);

  pHwnd := OpenProcess(PROCESS_CREATE_THREAD or PROCESS_VM_OPERATION or
    PROCESS_VM_READ or PROCESS_VM_WRITE or PROCESS_QUERY_INFORMATION, false,
    processId);

  if pHwnd <> 0 then
  begin
    ModPath := ExtractFilePath(paramstr(0)) + INTERCEPT_MODULE_NAME;
    Result := InjectDll(pHwnd, ModPath, HCode);
    CloseHandle(pHwnd);
  end;
end;

end.
