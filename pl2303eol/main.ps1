#Requires -Version 5.0 -RunAsAdministrator
using module .\modules\PLApp.psm1


# *****************************************************************************
# Ensure we stop and display any error and check for bitness incompatibility.
#
# *****************************************************************************
$ErrorActionPreference = 'Stop'

Trap {
    Write-Host "Error: $_" -ForegroundColor Red
    try {Read-Host -Prompt "`nPress the enter key to finish"} catch {}
    exit 1
}

if ($Env:PROCESSOR_ARCHITEW6432) {
    throw 'This script must run on 64-bit Powershell'
}


# *****************************************************************************
# Start main app and show the title.
#
# *****************************************************************************
$app = [PLApp]::new("$PSScriptRoot\driver")

Write-Host
Write-Host 'Prolific PL-2303 USB-to-Serial driver. Compatible with unsupported'
Write-Host 'end-of-life microchip versions (PL-2303HXA and PL-2303XA).'
Write-Host "Driver version: $($app.Driver.GetVersionString())"
Write-Host


# *****************************************************************************
# Show a list of PL-2303 drivers in the DriverStore and any sys file in the
# System drivers directory. Then check if a PL-2303 driver installation
# program is installed.
#
# - If there is an installer, the user will be asked to uninstall it and the
#   script will exit. We need to enforce this because uninstalling it later
#   would remove our compatible driver.
# *****************************************************************************
$app.CheckForDrivers()
$app.CheckForInstaller()


# *****************************************************************************
# Show the version of any installed driver and get confirmation to proceed. If
# this version is the only entry in the DriverStore and the System32 sys file
# matches, the user can only uninstall it.
#
# - The user can exit the script at this stage.
# *****************************************************************************
$uninstall = $app.GetConsent()

if ($uninstall) {
    if ($app.UninstallDriver()) {
        $app.IO.FinishForUninstaller($app.Driver.GetVersionString())
    } else {
        $app.IO.FinishFail()
    }
}


# *****************************************************************************
# Remove all PL-2303 drivers from the DriverStore then add our own driver.
#
# - Uses pnputil.exe for both operations. It is not uncommon for a removal to
#   fail, if the DriverStore and internal driver database are out of sync. We
#   let Windows sort this out the next time this script is run.
# *****************************************************************************
if (!($app.RemoveInstalledDrivers())) {
    $app.IO.FinishFail()
}

if (!($app.InstallDriver())) {
    # Something has gone badly wrong and there is not much we can do
    $msg = 'Restarting your computer and running this script again may resolve the issue.'
    $app.IO.Finish($msg, 1)
}


# *****************************************************************************
# Although our driver is now the only PL2303 version in the DriverStore, the
# sys file in the System drivers directory will not have been updated.
#
# - If the sys file is not the correct version, ask the user to re-plug in
#   their device, so that Windows will recognize the new driver and copy the
#   sys file from the DriverStore.
# *****************************************************************************
if ($app.CheckSystemSys()) {
    # The correct sys file was already in the System directory
    $app.IO.FinishWithInfo()
}

Write-Host
Write-Host 'To get Windows to activate this driver, you must re-plug in your USB device.'
$question = 'Enter Yes when you have done this, or No to skip this step'

if (!($app.IO.PromptYes($question, 'n'))) {
    # The user chose to skip this step
    $msg = 'If your USB device does not work when you next plug it in, please try the following:'
    $app.IO.FinishVerbose($msg)
}

if ($app.CheckSystemSys()) {
    # The correct sys file is now in the System directory
    $app.IO.FinishWithInfo()
} else {
    $msg = 'The new driver has not been activated. Please try the following:'
    $app.IO.FinishVerbose($msg)
}
