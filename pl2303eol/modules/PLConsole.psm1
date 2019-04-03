class PLConsole
{
    [void] Finish([string]$message, [int32]$exitCode)
    {
        if ($message) {
            Write-Host
            Write-Host $message
        }

        if ($global:Host.name -eq 'ConsoleHost') {
            Write-Host
            Write-Host -NoNewline 'Press any key to finish...'
            $global:Host.UI.RawUI.FlushInputBuffer()
            $global:Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyUp') >$null
        }
        exit $exitCode
    }

    [void] Finish()
    {
        $this.Finish([string]::Empty, 0)
    }

    [void] FinishWithHelp([string]$message)
    {
        Write-Host
        Write-Host $message
        $this.ShowHelp()
        $this.Finish()
    }

    [void] FinishVerbose([string]$message)
    {
        Write-Host
        Write-Host $message
        $this.ShowHelp()
        $this.ShowInfo()
        $this.Finish()
    }

    [void] FinishWithInfo()
    {
        Write-Host
        Write-Host 'The installed driver has been activated by Windows and is now ready for use.'
        $this.ShowInfo()
        $this.Finish()
    }

    [void] Indent([string]$message)
    {
        Write-Host "   $message"
    }

    [bool] PromptYes ([string]$question)
    {
        $reply = Read-Host -Prompt "   $question [y/n]"
        Write-Host
        return ($reply -match '^y')
    }

    [void] ShowHelp()
    {
        $this.WriteIndented('* Unplug and plug in your USB device. Then run this script again.')
        $this.WriteIndented('* Restart your computer. Then run this script again.')
    }

    [void] ShowInfo()
    {
        Write-Host
        Write-Host '** Windows Automatic Updates may replace this driver with a newer version,'
        Write-Host 'which will be incompatible. If this happens, you can rollback the driver'
        Write-Host 'to this version. The README file explains how to prevent this.'
    }
}
