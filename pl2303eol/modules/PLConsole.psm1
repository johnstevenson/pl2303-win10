class PLConsole
{
    [void] Finish([string]$message, [int32]$exitCode)
    {
        if ($message) {
            Write-Host
            Write-Host $message
        }

        try {
            Write-Host
            Read-Host -Prompt 'Press the enter key to finish'
        } catch {
        }
        exit $exitCode
    }

    [void] FinishWithHelp([string]$message)
    {
        Write-Host
        Write-Host $message
        $this.ShowHelp()
        $this.Finish([string]::Empty, 0)
    }

    [void] FinishVerbose([string]$message)
    {
        Write-Host
        Write-Host $message
        $this.ShowHelp()
        $this.ShowInfo()
        $this.Finish([string]::Empty, 0)
    }

    [void] FinishWithInfo()
    {
        Write-Host
        Write-Host 'The installed driver has been activated by Windows and is now ready for use.'
        $this.ShowInfo()
        $this.Finish([string]::Empty, 0)
    }

    [void] Indent([string]$message)
    {
        Write-Host "   $message"
    }

    [bool] PromptYes ([string]$question)
    {
        try {
            $reply = Read-Host -Prompt "   $question [y/n]"
        } catch {
            # Answer Yes if non-interactive
            $reply = 'y'
        }
        return ($reply -match '^y')
    }

    [void] ShowHelp()
    {
        $this.Indent('* Unplug and plug in your USB device. Then run this script again.')
        $this.Indent('* Restart your computer. Then run this script again.')
    }

    [void] ShowInfo()
    {
        Write-Host
        Write-Host '** Windows Automatic Updates may replace this driver with a newer version,'
        Write-Host 'which will be incompatible. If this happens, you can rollback the driver'
        Write-Host 'to this version. The README file explains how to prevent this.'
    }
}
