Prolific PL-2303 USB-to-Serial driver, version 3.3.11.152 (12-03-2010), which
is compatible with unsupported end-of-life microchip versions XA/HXA. This is
a script-based installer that can either add or remove this driver.

Source: https://github.com/johnstevenson/pl2303-win10

INSTRUCTIONS
1. Double-click "install.bat" in this folder.
2. Allow Windows SmartScreen to run it.
3. Follow the on-screen instructions.

You can delete this folder when you have finished.

AUTOMATIC UPDATES
To prevent Windows Automatic Updates from installing the latest version, you
can update it yourself then roll back to this version. Windows records this
action and should not try to replace it automatically. Follow the steps below:

* Plug the USB device into your computer. Open up Device Manager (type Device
Manager into Search) and expand the "Ports (COM & LPT)" entry. You should see
"Prolific USB-to-Serial Comm Port". Double-click this to open the Properties
page then go to the "Driver" tab.

* Click "Update driver" and let Windows search automatically and update it.
You may be required to restart your computer after this step.

* Finally replug in the device, open Device Manager and go to the "Driver" tab
as outlined above. Click "Roll Back Driver" to restore version 3.3.11.152

TROUBLESHOOTING
1. If you receive an error message, follow the on-screen instructions and run
this script again. If that fails, restart your computer and run this script
again. Windows is good at resolving drivers and devices that are out of sync.

2. If your USB device does not work correctly with this driver, you can remove
it by running "install.bat" again. The uninstall option is only available if
this is the only driver on the system and it has been activated. You can also
remove a driver from the "Driver" tab in Device Manager (see above). Click
"Uninstall Device" and choose the option to remove the driver software.

3. To install an alternative driver, you can either use Windows to install the
latest version or download an XA/HXA compatible driver installer from:
http://www.ifamilysoftware.com/Prolific_PL-2303_Code_10_Fix.html 
