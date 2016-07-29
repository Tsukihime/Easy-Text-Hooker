#include "textprocessor.h"
#include "loremipsum.h"
#include <QDebug>
#include "windows.h"

QString loremIpsumText = QString("") +
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n" +
        "Morbi tincidunt tristique tortor sit amet aliquam.\n" +
        "Sed auctor elit id tortor pellentesque, sed tincidunt nisl vulputate.\n" +
        "Vestibulum accumsan enim at tortor elementum, non rutrum eros eleifend.\n" +
        "In ultrices lacus sodales, gravida sapien nec, imperdiet justo.\n" +
        "Morbi massa tortor, viverra eget nulla ornare, imperdiet auctor urna.\n" +
        "Nunc ut nisl dui.\n" +
        "Donec id erat sed turpis ullamcorper posuere at ac odio.\n" +
        "Vivamus pellentesque id massa sit amet luctus.\n" +
        "Aliquam varius risus suscipit efficitur sagittis.\n" +
        "Vivamus tortor dui, posuere quis purus ac, ultrices placerat mi.\n" +
        "Maecenas ut libero pharetra, sollicitudin sem fringilla, placerat orci.\n" +
        "Cras nec odio eu leo varius laoreet sed eget arcu.\n" +
        "Morbi faucibus mauris turpis.\n" +
        "Aenean a nisl sit amet mi maximus fringilla vel ac nisl.\n" +
        "Sed ornare laoreet nisi a tempor.\n" +
        "Quisque consectetur nunc a quam maximus, quis porttitor sem dignissim.\n" +
        "Nulla tristique consectetur risus eget mollis.\n" +
        "Duis pulvinar leo non finibus bibendum.\n" +
        "Nulla non nunc semper, semper urna nec, dignissim odio.\n" +
        "Nulla vitae rhoncus metus, et ornare lectus.\n" +
        "Nullam accumsan risus sed dui dapibus molestie.\n" +
        "Curabitur nisl est, aliquam nec aliquam quis, dignissim congue nulla.\n" +
        "Sed sagittis sed purus accumsan iaculis.\n" +
        "Phasellus non interdum augue.\n" +
        "Phasellus sagittis, nulla non pretium gravida, eros augue mattis dolor, ac pharetra urna risus non sapien.\n" +
        "Vivamus lacinia sagittis mattis.\n" +
        "Nunc fermentum nisi nec sem scelerisque, vitae suscipit nibh euismod.\n" +
        "Donec id orci sit amet ligula congue venenatis.\n" +
        "Maecenas et hendrerit mauris.\n" +
        "Aliquam ut ultrices augue.\n" +
        "Vivamus eget leo nec diam porttitor ultricies.\n" +
        "Vivamus accumsan massa lectus.\n" +
        "Aenean nec congue libero, at sollicitudin odio.\n" +
        "Cras sit amet orci ac turpis vehicula mattis.\n" +
        "Vestibulum tristique odio tincidunt, iaculis quam eget, malesuada massa.\n" +
        "Donec ut interdum erat, eu auctor tortor.\n" +
        "Fusce viverra, magna sed scelerisque ornare, dui turpis feugiat enim, et mollis quam libero ut arcu.\n" +
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n" +
        "Fusce vestibulum nibh ut dolor sagittis, vehicula feugiat leo condimentum.\n" +
        "Praesent ac ipsum ultrices, efficitur mi non, blandit arcu.\n" +
        "Praesent auctor justo ut sodales pulvinar.\n" +
        "Phasellus vel consectetur felis, posuere tempor odio.\n" +
        "Vestibulum at condimentum sapien.\n" +
        "Proin ligula arcu, viverra nec ornare nec, hendrerit sed elit.\n" +
        "Maecenas semper, ante et interdum pellentesque, est neque ultricies dolor, sit amet porta purus metus nec metus.\n" +
        "Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.\n" +
        "Mauris sed nibh et mauris commodo iaculis.\n" +
        "Morbi sodales sollicitudin mattis.\n" +
        "Quisque porttitor sapien sodales ipsum efficitur, id rutrum justo consectetur.\n" +
        "Aenean fermentum nec sapien vitae laoreet.\n" +
        "Donec iaculis, urna mollis tincidunt aliquet, diam mi eleifend felis, eget lacinia nisl metus quis ante.\n" +
        "Aliquam felis sapien, elementum a feugiat ut, tincidunt eu turpis.\n" +
        "Donec commodo suscipit lacus eget pharetra.\n" +
        "Nunc eget eros augue.\n" +
        "Mauris mattis tellus purus, quis fringilla turpis dapibus eu.\n" +
        "Duis tristique quam eget leo congue, quis interdum nunc porta.\n" +
        "Pellentesque viverra arcu facilisis nisi tempus interdum.\n" +
        "Etiam nec est dapibus, fringilla sapien sit amet, molestie odio.\n" +
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n";

QStringList loremIpsumLines = loremIpsumText.split("\n");

TextProcessor::TextProcessor(IApplicationCore *ApplicationCore)
{
    this->ApplicationCore = ApplicationCore;
    this->ApplicationCore->AddRef();

    IApplicationWindows* wnds;
    this->ApplicationCore->get_ApplicationWindows(&wnds);
    long HostWindow;
    wnds->get_HostWnd(&HostWindow);
    wnds->Release();
    HWND HostWindowHandle = reinterpret_cast<HWND>(HostWindow);

    settingsForm = new SettingsForm();
    settingsForm->setWindowFlags(Qt::FramelessWindowHint);

    HWND hwnd = reinterpret_cast<HWND>(settingsForm->winId());
    SetParent(hwnd, HostWindowHandle);

    LONG_PTR newStyle = WS_CLIPCHILDREN | WS_CLIPSIBLINGS | WS_CHILD;
    SetWindowLongPtr(hwnd, GWL_STYLE, newStyle);

    timer = new QTimer();
    QObject::connect(timer, &QTimer::timeout, [=](){OnTimerUpdate();});
    timer->start(700);
}

TextProcessor::~TextProcessor()
{
    delete settingsForm;
    this->ApplicationCore->Release();
    delete timer;
}

void TextProcessor::OnTimerUpdate()
{
    if (this->Reciever != nullptr)
    {
        if (Iteration == loremIpsumLines.count())
        {
            Iteration = 0;
        }

        QString qstr = loremIpsumLines[Iteration++];
        QString html = "<html><head/><body><p align=\"center\"><span style=\" font-size:14pt;\">" +
                       qstr +
                       "</span></p></body></html>";

        settingsForm->setText(html);
        std::wstring wstr = qstr.toStdWString();
        BSTR bstr = SysAllocString(wstr.c_str());
        this->Reciever->OnNewText(bstr);
        SysFreeString(bstr);
    }
}

HRESULT STDMETHODCALLTYPE TextProcessor::SetTextReceiver(Pluginapi_tlb::ITextEvents* Reciever/*[in]*/)
{
    this->Reciever = Reciever;
    return S_OK;
}

HRESULT STDMETHODCALLTYPE TextProcessor::HideSettingsWindow(void)
{
    settingsForm->hide();
    return S_OK;
}

HRESULT STDMETHODCALLTYPE TextProcessor::ShowSettingsWindow(void)
{
    settingsForm->show();
    return S_OK;
}
