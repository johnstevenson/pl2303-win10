using module .\PLConfig.psm1
using module .\PLConsole.psm1
using module .\PLDriver.psm1
using module .\PLUtil.psm1

class PLApp
{
    [PLConfig]$Config
    [PLDriver]$Driver
    [PLConsole]$IO

    PLApp([string]$driverPath)
    {
        $this.Driver = [PLDriver]::new($driverPath)
        $this.IO = [PLConsole]::new()
    }

    [void] CheckForDrivers()
    {
        Write-Host 'Checking the DriverStore for installed PL-2303 driver packages'
        $this.Config = [PLConfig]::new($this.Driver)

        if ($this.Config.Drivers.Count -eq 0) {
            $this.IO.Indent('Found: none')
        } else {
            foreach ($item in $this.Config.Drivers) {
                $msg = "Found: $($item.oem) ($($item.date), $($item.version))"
                $this.IO.Indent($msg)
            }
        }

        Write-Host 'Checking the System directory for a PL-2303 device driver'

        if ($this.Config.SysInfo) {
            $this.IO.Indent("Found: $($this.Config.SysInfo)")
        } else {
            $this.IO.Indent('Found: none')
        }
    }

    [void] CheckForInstaller()
    {
        Write-Host 'Checking the Registry for a PL-2303 installation program'
        $installer = $this.GetInstallationProgram()

        if ($installer) {
            $this.IO.Indent("Found: $installer")
            $this.IO.FinishFailInstaller($installer)
        } else {
            $this.IO.Indent('Found: none')
        }
    }

    [void] CheckSameConfig($uninstall)
    {
        if (!($this.Config.CheckCurrent($uninstall))) {
            Write-Host 'Unable to continue. The driver configuration has been changed.'
            $this.IO.Indent('Please run this script again')
            $this.IO.Finish([string]::Empty, 1)
        }
    }

    [bool] CheckSystemSys()
    {
        $version = [PLUtil]::GetFileVersion($this.Config.SysFile)
        return [PLUtil]::CheckSameVersion($version, $this.Driver.Version)
    }

    [bool] GetConsent()
    {
        $uninstall = ($this.Config.SysIsStaged -and
            $this.Config.SysIsPackage -and
            $this.Config.Drivers.Count -eq 1)

        Write-Host

        if ($uninstall) {
            Write-Host "This script cannot install PL-2303 driver version $($this.Driver.Version),"
            Write-Host 'because it is already installed and available for use.'
            $question = 'Would you like to uninstall it instead?'
        } else {
            Write-Host "This script will install PL-2303 driver, version $($this.Driver.Version)"
            if ($this.Config.InstalledMessage) {
                $this.IO.Indent("$($this.Config.InstalledMessage) and will be replaced.")
            }
            $question = 'Please confirm that you want to do this?'
        }

        if ($this.IO.PromptYes($question, 'y')) {
            Write-Host
        } else {
            exit 1
        }

        return $uninstall
    }

    [string] GetInstallationProgram()
    {
        $uninstallKey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
        $keys = @()

        if ([Environment]::Is64BitProcess) {
            $keys += $uninstallKey -replace 'Microsoft', 'Wow6432Node\Microsoft'
            $keys += $uninstallKey
        } else {
            $keys += $uninstallKey
        }

        # The official Prolific installer id
        $productIds = @('{ECC3713C-08A4-40E3-95F1-7D0704F1CE5E}')
        # Add installer from http://www.ifamilysoftware.com/Prolific_PL-2303_Code_10_Fix.html
        $productIds += 'PL2303 Code 10 Fix_is1'

        $data = $this.GetRegUninstallData($keys, $productIds)

        if ($data) {
            return $data.DisplayName
        }
        return [string]::Empty
    }

    [object] GetRegUninstallData([array]$keys, [array]$productIds)
    {
        # Try with the specific installer product id
        foreach ($key in $keys) {
            foreach ($productId in $productIds) {
                $productKey = "$key\$productId"

                if (Test-Path -Path $productKey) {
                    return Get-Item -Path $productKey | Get-ItemProperty |
                        Select-Object -Property DisplayName
                }
            }
        }

        # Try with a generic description in case of a new installer
        foreach ($key in $keys) {
            $data = Get-ChildItem -Path $key | Get-ItemProperty |
                Where-Object {$_.Publisher -match 'Prolific' -and $_.DisplayName -match 'PL.*2303' } |
                Select-Object -Property DisplayName

            if ($data) {
                return $data
            }
        }
        return $null
    }

    [bool] InstallDriver()
    {
        Write-Host "Adding PL-2303 driver ($($this.Driver.Version)) to the DriverStore"

        # Install from a temporary folder, so Windows will not use the stored source location
        $tempPath = [PLUtil]::CreateTempDriverFolder($this.Driver.Path)

        if (!($tempPath)) {
            $this.IO.Indent("Error: failed to create temporary directory")
            return $false
        }

        $infPath = Join-Path $tempPath $this.Driver.InfFile
        $result = [PLUtil]::AddDriver($infPath)
        [PLUtil]::DeleteTempDriverFolder($tempPath)

        if ($result) {
            $this.IO.Indent('Success: PL-2303 driver added')
        } else {
            $this.IO.Indent('Error: failed to add PL-2303 driver')
        }
        return $result
    }

    [bool] RemoveInstalledDrivers()
    {
        # Check in case something has changed
        $this.CheckSameConfig($false)

        return $this.RemoveInstalledDrivers($this.Config.Drivers)
    }

    [bool] RemoveInstalledDrivers([array]$drivers)
    {
        $driverStr = $(if ($drivers.Count -eq 1) {'driver'} else {'drivers'})

        if ($drivers.Count -eq 0) {
            return $true;
        }

        Write-Host "Removing PL-2303 $driverStr from the DriverStore"
        $errors = [PLUtil]::RemoveDrivers($drivers)

        if ($errors.Count -eq 0) {
            $this.IO.Indent("Success: PL-2303 $driverStr removed")
        } else {
            foreach ($item in $errors) {
                $msg = "Error: failed to remove $($item.oem) ($($item.date), $($item.version))"
                $this.IO.Indent($msg)
            }
        }
        return ($errors.Count -eq 0)
    }

    [bool] UninstallDriver()
    {
        # Check in case something has changed
        $this.CheckSameConfig($true)

        if (!($this.RemoveInstalledDrivers($this.Config.Drivers))) {
            return $false
        }

        Write-Host "Removing the device driver from the System directory"
        Remove-Item $this.Config.SysFile

        if (!(Test-Path $this.Config.SysFile)) {
            $this.IO.Indent("Success: removed $($this.Config.SysInfo)")
        } else {
            # There is not much we can do about this, apart from report it
            $this.IO.Indent("Error: failed to remove $($this.Config.SysInfo)")
        }

        return $true
    }
}
