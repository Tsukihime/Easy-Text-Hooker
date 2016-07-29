#ifndef WINAPITIMER_H
#define WINAPITIMER_H

#include "windows.h"
#include <functional>

typedef std::function<void()> TimerProc;

class WinapiTimer
{
public:
    WinapiTimer(UINT timeout_ms, TimerProc lambda);
    ~WinapiTimer();
    void DoTimer();

protected:
    HWND Handle;
    UINT_PTR TimerID;
    TimerProc TimerLambda;
protected:
    HWND AllocateHWnd();
};

#endif // WINAPITIMER_H
