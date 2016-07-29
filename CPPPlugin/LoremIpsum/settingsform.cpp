#include "settingsform.h"
#include "ui_settingsform.h"

SettingsForm::SettingsForm(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::SettingsForm)
{
    ui->setupUi(this);
    setMinimumSize(200, 200);
}

SettingsForm::~SettingsForm()
{
    delete ui;
}

void SettingsForm::setText(QString &text)
{
    ui->loremLabel->setText(text);
}
