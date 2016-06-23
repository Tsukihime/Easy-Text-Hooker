Easy-Text-Hooker
================

Copyright (c) 2013, Tsukihime
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Особенности
- поддержка "h-кодов" от AGTH
- предварительная обработка текста пользовательскими скриптами на JavaScript
- онлайн перевод
- вывод переведенного текста поверх окна игры

## Скриншоты

![OSD](https://dl.dropboxusercontent.com/u/14783184/ETH/Game.png?dl=1)

# Справка

### Вкладка AGTH

![TabAGTH](https://dl.dropboxusercontent.com/u/14783184/ETH/AGTH.png?dl=1)

Для того чтобы установить перехват текста в игре:
- выберите процесс игры в выпадающем списке процессов
- введите H-код если нужно
- нажмите кнопку `Hook`
- по мере того как игра будет выводить текст: в выпадающем списке справа появится список текстовых потоков. Выберите нужный. Он будет использоваться как источник текста для последующей обработки.

### Вкладка Text processor

![TabJS](https://dl.dropboxusercontent.com/u/14783184/ETH/JS.png?dl=1)

Если нужно обработать текст перед переводом(например: убрать дублирующиеся символы, заменить имена героев, итп) следует использовать пользовательский скрипт.

Для этого:
- загрузите скрипт нажав кнопку `Load` и выберите файл скрипта.
- активируйте функцию препроцессинга текста галочкой `Enable`

Скрипты пишутся на JavaScript и должны иметь вид:

```javascript
/* preprocess text function */
function process_text(text)
{
	// write code here
	return ">>>" + text + "<<<";
}
```
Где переменная `text` содержит строку текста для обработки, а return возвращает обработанный текст в обратно программу.

### Вкладка Translate

![TabTranslate](https://dl.dropboxusercontent.com/u/14783184/ETH/translate.png?dl=1)

- Галочка `Enable` активирует функцию онлайн перевода текста.
- В выпадающих списках вы можете выбрать язык источника и язык на который будет осуществляться перевод
- Данная функция требует наличие подключения к интернету.

### Вкладка Text

![TabText](https://dl.dropboxusercontent.com/u/14783184/ETH/text.png?dl=1)

Отображает перехваченный, обработанный и переведенный текст.

Галочка `Copy text to clipboard` включает копирование текста из текстового поля в буфер обмена. (Нужна для интеграции о оффлайн переводчиками).

### Вкладка OSD

![TabOSD](https://dl.dropboxusercontent.com/u/14783184/ETH/OSD.png?dl=1)

Отвечает за вывод субтитров поверх игры.

- галочка `Enable` включает показ субтитров
- радиокнопки `From textarea` и `From clipboard` задают  источник текста для отображения: текстовое поле или буфер обмена - соответственно.
- ползунки `X`, `Y`, `Width` и `Height` задают положение и размеры окна вывода субтитров.
- галочка `Sticky text` отвечает за автопозиционирование окна субтитров относительно текущего активного окна(игры).
- Кнопка `Select font` позволяет выбрать шрифт субтитров.
- `Font color` и `Outline color` задают цвет текста и обводки.
- Ползунок `Outline width` задаёт ширину обводки в пикселах.
