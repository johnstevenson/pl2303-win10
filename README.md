# pl2303-win10

| This repository has been archived. Please use [PL2303 Legacy Driver Updater](https://github.com/johnstevenson/pl2303-legacy) which is an updated solution for Windows 10 and Windows 11.
| ---


Windows 10 driver for end-of-life PL-2303 chipsets.

## About
Prolific PL-2303 USB-to-Serial driver, version 3.3.11.152 (12-03-2010). Compatible with unsupported end-of-life microchip versions (PL-2303HXA and PL-2303XA). This is a script-based installer that can either add or remove this driver.

Its purpose is to supplement the excellent [Prolific PL-2303 Code 10 Fix][codefix] program from [Family Software][family], which was initially produced to save their customers from having to buy new hardware. It has subsequently been successfully used around the world with all kinds of different devices.

However, the earlier _3.3.2.102_ driver version that it uses can sometimes fail on Windows 10, in that data can be read from the device but cannot be written to it.
This version does not exhibit this problem.  

### Technical notes
The [Prolific PL-2303 Code 10 Fix][codefix] documentation lists this driver (3.3.11.152) as being problematical. The reason is that the device cannot always be written to unless the program is using Windows API calls to communicate. This can affect applications that use the old Microsoft MSComm32 and other third party OCXs, particularly when coded in Visual Basic.

[codefix]:  https://www.ifamilysoftware.com/Prolific_PL-2303_Code_10_Fix.html
[family]:   https://www.ifamilysoftware.com/
