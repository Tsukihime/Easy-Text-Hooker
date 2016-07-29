#ifndef LOREMIPSUM_H
#define LOREMIPSUM_H

#include <QApplication>
extern QApplication* qApplication;

#define EXPORT extern "C" __declspec (dllexport)
#define ETHAPI __stdcall

#include "PluginAPI/PluginAPI_TLB.h"

EXPORT void ETHAPI ETHInitializeTextProcessors(ITextProcessorRegistry* Registry);
EXPORT void ETHAPI ETHFinalize();

#endif // LOREMIPSUM_H
