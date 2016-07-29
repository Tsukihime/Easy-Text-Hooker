TARGET = LoremIpsum
TEMPLATE = lib

QT += axcontainer
QT -= core

QMAKE_LFLAGS += -Wl,--kill-at
#QMAKE_LFLAGS += -static-libgcc -static-libstdc++

DEFINES += LOREMIPSUM_LIBRARY

SOURCES += loremipsum.cpp \
    PluginAPI/PluginAPI_TLB.cpp \
    textprocessorinfo.cpp \
    textprocessorfactory.cpp \
    textprocessor.cpp \
    winapitimer.cpp \
    settingsform.cpp

HEADERS += loremipsum.h \
    PluginAPI/PluginAPI_TLB.h \
    textprocessorinfo.h \
    textprocessorfactory.h \
    textprocessor.h \
    winapitimer.h \
    interfacedobject.h \
    settingsform.h

unix {
    target.path = /usr/lib
    INSTALLS += target
}

FORMS += \
    settingsform.ui
