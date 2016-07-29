#include "winapitimer.h"

HWND WinapiTimer::AllocateHWnd()
{
    HINSTANCE HInstance = GetModuleHandle(NULL);
    WNDCLASS TimerWindowClass;
    WNDCLASS TempClass;
    TimerWindowClass.style = 0;
    TimerWindowClass.lpfnWndProc = DefWindowProc;
    TimerWindowClass.cbClsExtra = 0;
    TimerWindowClass.cbWndExtra = 0;
    TimerWindowClass.hInstance = 0;
    TimerWindowClass.hIcon = 0;
    TimerWindowClass.hCursor = 0;
    TimerWindowClass.hbrBackground = 0;
    TimerWindowClass.lpszMenuName = nullptr;
    TimerWindowClass.lpszClassName = L"TimerWindow";

    bool ClassRegistered = GetClassInfo(HInstance, TimerWindowClass.lpszClassName, &TempClass);

    if (!ClassRegistered || (TempClass.lpfnWndProc != DefWindowProc))
    {
       if (ClassRegistered)
           UnregisterClass(TimerWindowClass.lpszClassName, HInstance);
       RegisterClass(&TimerWindowClass);
    }
    return CreateWindowEx(WS_EX_TOOLWINDOW, TimerWindowClass.lpszClassName,
                          nullptr, WS_POPUP, 0, 0, 0, 0, 0, 0, HInstance, nullptr);
}


void CALLBACK TimerCallback(HWND hwnd, UINT uMsg, UINT_PTR idEvent, DWORD dwTime)
{
    (void)hwnd;
    (void)uMsg;
    (void)dwTime;
    WinapiTimer* timer = reinterpret_cast<WinapiTimer*>(idEvent);
    timer->DoTimer();
}

WinapiTimer::WinapiTimer(UINT timeout_ms, TimerProc lambda)
{
    TimerLambda = lambda;
    Handle = AllocateHWnd();
    TimerID = SetTimer(Handle, reinterpret_cast<UINT_PTR>(this), timeout_ms, TimerCallback);
}

WinapiTimer::~WinapiTimer()
{
    KillTimer(Handle, TimerID);
    DestroyWindow(Handle);
}

void WinapiTimer::DoTimer()
{
    TimerLambda();
}
