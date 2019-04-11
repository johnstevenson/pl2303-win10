# pl2303-win10

[![GitHub release](https://img.shields.io/github/release/johnstevenson/pl2303-win10.svg?color=blue)](https://github.com/johnstevenson/pl2303-win10/releases)
[![AppVeyor](https://img.shields.io/appveyor/ci/johnstevenson/pl2303-win10/master.svg)](https://ci.appveyor.com/project/johnstevenson/pl2303-win10/branch/master)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Windows 10 driver for end-of-life PL-2303 chipsets.

## About
Prolific PL-2303 USB-to-Serial driver, version 3.3.11.152 (12-03-2010). Compatible with unsupported end-of-life microchip versions (PL-2303HXA and PL-2303XA). This is a script-based installer that can either add or remove this driver.

Its purpose is to supplement the excellent [Prolific PL-2303 Code 10 Fix][codefix] program from [Family Software][family], which was initially produced to save their customers from having to buy new hardware. It has subsequently been successfully used around the world with all kinds of different devices.

However, the earlier _3.3.2.102_ driver version that it uses can sometimes fail on Windows 10, in that data can be read from the device but cannot be written to it.
This version does not exhibit this problem.  

## Usage
Download the latest [release][release] and unzip it somewhere on your computer.
* Open the main folder (prefixed `pl2303-win10`) and double-click `install.bat`
* Allow Windows SmartScreen to run it.
* Follow the on-screen instructions.

You can delete the main folder when you have finished.

### Technical notes
The [Prolific PL-2303 Code 10 Fix][codefix] documentation lists this driver (3.3.11.152) as being problematical. The reason is that the device cannot always be written to unless the program is using Windows API calls to communicate. This can affect applications that use the old Microsoft MSComm32 and other third party OCXs, particularly when coded in Visual Basic.

[codefix]:  http://www.ifamilysoftware.com/Prolific_PL-2303_Code_10_Fix.html
[family]:   http://www.ifamilysoftware.com/
[release]:  https://github.com/johnstevenson/pl2303-win10/releases/latest
