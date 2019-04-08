using module .\PLDriver.psm1
using module .\PLUtil.psm1

class PLConfig
{
    [array]$Drivers
    [PLDriver]$Package
    [string]$InstalledMessage
    [string]$SysFile
    [string]$SysInfo
    [bool]$SysIsPackage
    [bool]$SysIsStaged
    [string]$SysVersion

    PLConfig([PLDriver]$package)
    {
        $this.Package = $package
        $this.SysFile = Join-Path $([Environment]::SystemDirectory) "drivers\$($this.Package.SysFile)"
        $this.Init()
    }

    [void] Init()
    {
        $this.Drivers = [PLUtil]::GetDrivers($this.Package.InfFile)
        $this.SysVersion = [PLUtil]::GetFileVersion($this.SysFile)
        $this.SysIsPackage = [PLUtil]::CheckSameVersion($this.SysVersion, $this.Package.Version)
        $this.SysIsStaged = $false
        $this.InstalledMessage = [string]::Empty

        if ($this.SysVersion) {

            # Set SysInfo. We cannot use the file date, so find a match from the DriverStore
            $item = [PLUtil]::MatchDriver($this.Drivers, $this.SysVersion)

            if ($item) {
                $this.SysIsStaged = $true
                $info = "$($item.date), $($item.version)"
            } else {
                $info = $this.SysVersion
            }

            $this.SysInfo = "$($this.Package.SysFile) ($info)"
            $this.InstalledMessage = "Version $($this.SysVersion) may be installed"
        }

        if ($this.SysIsStaged) {
            if ($this.SysIsPackage) {
                $this.InstalledMessage = 'This version is already installed'
            } else {
                $this.InstalledMessage = "Version $($this.SysVersion) is installed"
            }
        }
    }

    [bool] CheckCurrent([bool]$checkSystemSys)
    {
        $config = [PLConfig]::new($this.Package)

        if ($this.Drivers.Count -ne $config.Drivers.Count) {
            return $false
        }

        foreach ($driver in $this.Drivers) {
            if (!([PLUtil]::MatchDriver($config.Drivers, $driver.version))) {
                return $false
            }
        }

        if ($checkSystemSys) {
            return [PLUtil]::CheckSameVersion($this.SysVersion, $config.SysVersion)
        }
        return $true
    }
}
