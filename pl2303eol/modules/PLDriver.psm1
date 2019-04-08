using module .\PLUtil.psm1

class PLDriver
{
    [string]$Path
    [string]$InfFile
    [string]$SysFile
    [string]$Date
    [string]$Version

    PLDriver([string]$path)
    {
        $this.Path = $path
        $this.InfFile = 'ser2pl.inf'

        # Get the appropriate sys filename
        if ([Environment]::Is64BitProcess) {
            $this.SysFile = 'ser2pl64.sys'
        } else {
            $this.SysFile = 'ser2pl.sys'
        }

        if (!($this.CheckAndSetVersion())) {
            throw 'Driver package not configured correctly.'
        }
    }

    [string] GetVersionString()
    {
        return "$($this.Version) ($($this.Date))"
    }

    [bool] CheckAndSetVersion()
    {
        # Get driver date and version from inf file
        $infPath = Join-Path $this.Path $this.InfFile

        if (!(Test-Path $infPath)) {
            return $false
        }

        $line = Select-String -Pattern 'DriverVer' -Path $infPath | Select-Object -ExpandProperty Line

        if (!($line)) {
            return $false
        }

        $data = $line.Split('=').Trim()[-1]
        $this.Date, $this.Version  = [PLUtil]::GetDriverDateAndVersion($data)

        # Check we don't have a mismatch
        $sysPath = Join-Path $this.Path $this.SysFile
        $sysVersion = [PLUtil]::GetFileVersion($sysPath)

        return [PLUtil]::CheckSameVersion($sysVersion, $this.Version)
    }
}
