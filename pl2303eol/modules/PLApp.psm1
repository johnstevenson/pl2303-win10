using module .\PLConsole.psm1
using module .\PLDriver.psm1
using module .\PLUtil.psm1

class PLApp
{
    [PLDriver]$Driver
    [PLConsole]$IO
    [string]$SystemSys
    [array]$InstalledDrivers

    PLApp([string]$driverPath)
    {
        $this.Driver = [PLDriver]::new($driverPath)
        $this.IO = [PLConsole]::new()
        $this.SystemSys = Join-Path $([Environment]::SystemDirectory) "drivers\$($this.Driver.SysFile)"
    }

    [void] CheckForDrivers()
    {
        Write-Host 'Checking the DriverStore for installed PL-2303 drivers'
        $this.InstalledDrivers = [PLUtil]::GetDrivers($this.Driver.InfFile)

        if ($this.InstalledDrivers.Count -eq 0) {
            $this.IO.Indent('Found: none')
        } else {
            foreach ($item in $this.InstalledDrivers) {
                $msg = "Found: $($item.oem) ($($item.date), $($item.version))"
                $this.IO.Indent($msg)
            }
        }
    }

    [void] CheckForInstaller()
    {
        Write-Host 'Checking the Registry for a PL-2303 driver installation program'
        $installer = $this.GetInstallationProgram()

        if ($installer) {
            $this.IO.Indent("Found: $installer")
            $msg = "Please uninstall '$installer' from the Control Panel, then run this script again."
            $this.IO.Finish($msg, 1)
        } else {
            $this.IO.Indent('Found: none')
        }
    }

    [bool] CheckSystemSys()
    {
        $version = [PLUtil]::GetFileVersion($this.SystemSys)
        return [PLUtil]::CheckSameVersion($version, $this.Driver.Version)
    }

    [void] GetConsent() {

        Write-Host "This script will install PL-2303 driver, version $($this.Driver.Version)."

        $installedVersion = [PLUtil]::GetFileVersion($this.SystemSys)
        $sameVersion = [PLUtil]::CheckSameVersion($installedVersion, $this.Driver.Version)
        $matchedVersion = $false

        foreach ($driver in $this.InstalledDrivers) {
            if ([PLUtil]::CheckSameVersion($installedVersion, $driver.version)) {
                $matchedVersion = $true
                break
            }
        }

        if ($installedVersion)
        {
            if ($matchedVersion) {
                if ($sameVersion) {
                    $prefix = 'This version is already installed'
                } else {
                    $prefix = "Version $installedVersion is installed"
                }
            } else {
                $prefix = "Version $installedVersion may be installed"
            }
            $this.IO.Indent("$prefix and will be replaced.")
        }

        if (!($this.IO.PromptYes('Please confirm that you want to do this?'))) {
            exit 1
        }
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
        # Add installer from http://www.ifamilysoftware.com/ (see news pages)
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
        if ($this.InstalledDrivers.Count -eq 0) {
            return $true;
        }

        Write-Host 'Removing PL-2303 drivers from the DriverStore'
        $errors = [PLUtil]::RemoveDrivers($this.InstalledDrivers)

        if ($errors.Count -eq 0) {
            $driverStr = $(if ($this.InstalledDrivers.Count -eq 1) {'driver'} else {'drivers'})
            $this.IO.Indent("Success: PL-2303 $driverStr removed")
        } else {
            foreach ($item in $errors) {
                $msg = "Error: failed to remove $($item.oem) ($($item.date), $($item.version))"
                $this.IO.Indent($msg)
            }
        }
        return ($errors.Count -eq 0)
    }
}
