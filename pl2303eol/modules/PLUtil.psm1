class PLUtil
{
    static [bool] AddDriver([string]$infPath)
    {
        &pnputil.exe /add-driver """$infPath""" /install >$null 2>&1
        return $LastExitCode -eq 0
    }

    static [bool] CheckSameVersion([string]$version1, [string]$version2)
    {
        if (!($version1) -or !($version2)) {
            return $false
        }

        return [Version] $version1 -eq [Version] $version2
    }

    static [string] CreateTempDriverFolder([string]$driverPath)
    {
        $path = $Env:Temp
        $folder = [Guid]::NewGuid().ToString()
        $tempPath = Join-Path $path "{$folder}"

        try {
            Copy-Item $driverPath -Destination $tempPath -Recurse -ErrorAction SilentlyContinue
        } catch {
            $tempPath = [string]::Empty
        }

        return $tempPath
    }

    static [void] DeleteTempDriverFolder([string]$tempPath)
    {
        Get-ChildItem -Path $tempPath -Recurse | Remove-Item -Force -ErrorAction SilentlyContinue
        Remove-Item $tempPath -Force -ErrorAction SilentlyContinue
    }

    static [array] GetDriverDateAndVersion([string]$data)
    {
        $date,$version = $data.Split('[, ]').Trim()
        $parts = $date.Split('/')
        $date = '{0}-{1}-{2}' -f $parts[1], $parts[0], $parts[2]

        return @($date, $version)
    }

    static [string] GetFileVersion([string]$filePath)
    {
        if (!(Test-Path $filePath)) {
            return [string]::Empty
        }

        $info = (Get-Item $filePath).VersionInfo

        return ('{0}.{1}.{2}.{3}' -f $info.FileMajorPart,
            $info.FileMinorPart,
            $info.FileBuildPart,
            $info.FilePrivatePart)
    }

    static [array] GetDrivers([string]$infName)
    {
        $drivers = @()
        $publishedName = ''
        $matched = $false
        $pnpoutput = &pnputil.exe /enum-drivers

        foreach ($line in $pnpoutput) {
            $key,$value = $line.Split(':').Trim()

            if ($key -eq 'Published Name') {
                $publishedName = $value
            } elseif ($key -eq 'Original Name') {
                $matched = $value -eq $infName
            } elseif ($key -eq 'Driver Version' -and $matched) {
                $date, $version = [PLUtil]::GetDriverDateAndVersion($value)
                $drivers += @{oem = $publishedName; date = $date; version = $version}
                $matched = $false
            }
        }
        return $drivers
    }

    static [object] MatchDriver([array]$drivers, [string]$version)
    {
        foreach ($driver in $drivers) {
            if ([PLUtil]::CheckSameVersion($version, $driver.version)) {
                return $driver.Clone()
            }
        }
        return $null
    }

    static [array] RemoveDrivers([array]$drivers)
    {
        $errors = @()

        foreach ($driver in $drivers) {
            &pnputil.exe /delete-driver $driver.oem /uninstall /force >$null 2>&1

            if ($LastExitCode -ne 0) {
                $errors += $driver
            }
        }
        return $errors
    }
}
