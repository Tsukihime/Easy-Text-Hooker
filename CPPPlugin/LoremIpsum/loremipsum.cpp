#include "loremipsum.h"

#include "textprocessorfactory.h"
#include "textprocessorinfo.h"

#include "winapitimer.h"
#include <shellapi.h>

QApplication* qApplication;
WinapiTimer* winapiTimer;

void InitQtApp()
{
    int argc = 0;
    LPWSTR* lpArgv = CommandLineToArgvW(GetCommandLine(), &argc);

    char** argv = (char**)malloc(argc * sizeof(char*));

    for(int i = 0; i < argc; ++i) {
        int size = wcslen(lpArgv[i])  + 1;
        argv[i] = (char*)malloc(size);
        wcstombs(argv[i], lpArgv[i], size);
    }

    qApplication = new QApplication(argc, argv);

    for(int i = 0; i < argc; ++i ) {
        free(argv[i]);
        free(argv);
    }

    if (lpArgv != NULL) {
        LocalFree(lpArgv);
    }

    // timer driven event loop :}
    winapiTimer = new WinapiTimer(1, [](){
        qApplication->processEvents();
    });
}

void FinalizeQtApp()
{
    delete winapiTimer;
    delete qApplication;
}

void ETHAPI ETHInitializeTextProcessors(ITextProcessorRegistry* Registry)
{
    InitQtApp();

    ITextProcessorFactory* FactoryIntf = nullptr;
    TextProcessorFactory* Factory = new TextProcessorFactory();
    Factory->QueryInterface(IID_ITextProcessorFactory, reinterpret_cast<void**>(&FactoryIntf));

    ITextProcessorInfo* InfoIntf = nullptr;
    TextProcessorInfo* Info = new TextProcessorInfo();
    Info->QueryInterface(IID_ITextProcessorInfo, reinterpret_cast<void**>(&InfoIntf));

    Registry->RegisterFactory(FactoryIntf, InfoIntf);

    FactoryIntf->Release();
    InfoIntf->Release();
}

void ETHAPI ETHFinalize()
{
    FinalizeQtApp();
}
