Easy-Text-Hooker
================
[ ![Download](https://api.bintray.com/packages/tsukihime/Easy-Text-Hooker/Easy-Text-Hooker/images/download.svg) ](https://bintray.com/tsukihime/Easy-Text-Hooker/Easy-Text-Hooker/_latestVersion)

Copyright (c) 2013, Tsukihime
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## Features
- support AGTH "h-codes"
- preprocessing text with custom scripts on JavaScript
- online translation
- OSD function to display translated text atop the game

## Screenshots

![OSD](https://dl.dropboxusercontent.com/u/14783184/ETH/Game.png?dl=1)

# Manual

### Tab AGTH

![TabAGTH](https://dl.dropboxusercontent.com/u/14783184/ETH/AGTH.png?dl=1)

In order to establish the interception of text in the game:
- Select the game in the drop-down list of processes
- enter the "H-code" if needed
- Press `Hook`
- As the game will display the text: in the drop-down list on the right displays a list of text streams. Select the desired. It will be used as a source text for further processing.

### Tab Text processor

![TabJS](https://dl.dropboxusercontent.com/u/14783184/ETH/JS.png?dl=1)

If you want to preprocess text before translate (eg to remove duplicate symbols, replace the names of heroes, and so forth), use a custom script.

For this:
- Load the script by clicking the `Load` and select the script file.
- For activate the preprocessing text tick checkbox `Enable`

The scripts should be written in JavaScript and take form of:

```javascript
/* preprocess text function */
function process_text(text)
{
	// write code here
	return ">>>" + text + "<<<";
}
```
Where the variable `text` contains a line of text to be processed, and return returns processed text back in the program.

### Tab Translate

![TabTranslate](https://dl.dropboxusercontent.com/u/14783184/ETH/translate.png?dl=1)

- Checkbox `Enable` activates the online text translation feature.
- In the drop-down lists you can choose the source language and the language which will be translated
- This function requires an Internet connection.

### Tab Text

![TabText](https://dl.dropboxusercontent.com/u/14783184/ETH/text.png?dl=1)

Displays intercepted, processed and translated text.

The checkbox `Copy text to clipboard` enables copying text from a text field to the clipboard. (Need for integration of offline translators).

### Tab OSD

![TabOSD](https://dl.dropboxusercontent.com/u/14783184/ETH/OSD.png?dl=1)

Responsible for the display subtitles on top of the game.

- Checkbox `Enable` enables subtitles
- `From textarea` & `From clipboard` radio buttons specify the source text to display: a text box or clipboard - respectively.
- Sliders `X`,` Y`, `Width` and` Height` define the position and size of the window display subtitles.
- Checkbox `Sticky text` responsible for auto positioning subtitle window on the current active window (the game).
- Button `Select font` allows you to select the subtitle font.
- `Font color` and `Outline color` set the text color and outline color.
- Slider `Outline width` sets the outline width in pixels.