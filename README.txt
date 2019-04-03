Installs Prolific PL2303 driver, version 3.3.11.152 (12-03-2010). The install
program is a simple script which uses built-in Windows commands to add
this driver to the internal DriverStore.

1. Double-click "install.bat"
2. Allow Windows SmartScreen to run the app.
3. Follow the on-screen instructions.

To prevent Windows Automatic Updates from updating the PL2303 driver to a
newer (incompatible) version, you can update it yourself then roll back to
this version. Windows records this action and should not try to replace it
automatically. Follow the steps below:

* Plug the USB device into your computer. Open up Device Manager (type Device
Manager into Search) and expand the "Ports (COM & LPT)" entry. You should see
"Prolific USB-to-Serial Comm Port". Double-click this to open the Properties
page then go to the "Driver" tab.

* Click "Update driver" and let Windows search automatically and update it.
You may be required to restart your computer after this step.

* Finally replug in the device, open Device Manager and go to the "Driver" tab
as outlined above. Click "Roll Back Driver" to restore version 3.3.11.152

See https://github.com/johnstevenson/pl2303-win10 for more information.
