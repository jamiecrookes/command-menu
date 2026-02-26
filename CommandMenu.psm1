function Show-CommandMenu {
    <###################################################################################
    .SYNOPSIS
        Show-CommandMenu HotKey Activated Function
    .DESCRIPTION
        Arrow key driven menu for favourite commands read from $HOME\PsFaves.txt.
    .EXAMPLE
        Hotkey Activated (See Set-PSReadLineKeyHandler section below)
    .NOTES
        Author          :  Jamie Crookes
        Date Created    :  21st February 2026
    ###################################################################################>

    # Check for file and throw if missing
    if (Test-Path "$HOME\commandmenu.txt") {
        $menuOptions = Get-Content -Path "$HOME\commandmenu.txt"
    } else {
        throw "Favourites file $HOME\commandmenu.txt not found"
    }

    # Check for file contents and throw if empty
    if (-not $menuOptions -or $menuOptions.Count -eq 0) {
        throw "MenuOptions cannot be empty."
    }

    # Make some nooooooise, or not. Delete me if you don't like
    [console]::beep(2000,80)

    # Some maths for menu sizing
    $maxIndex  = $menuOptions.Count - 1
    $selection = 0
    $rightMargin = 2

    # Longest entry + padding
    $longest = ($menuOptions | Measure-Object -Property Length -Maximum).Maximum
    $targetBarWidth = ($longest + 4) + 10

    while ($true) {
        # Cap to console width each redraw so it won't wrap
        $windowWidth = $Host.UI.RawUI.WindowSize.Width
        $barWidth = [Math]::Min($targetBarWidth, [Math]::Max(10, $windowWidth - $rightMargin))

        # Menu title drawing preparation
        $topBorderLines = "╔" + "═"*(($barWidth)) + "╗"
        $midBorderLines = "╠" + "═"*(($barWidth)) + "╣"
        $bottomBorderLines = "╚" + "═"*(($barWidth)) + "╝"
        $menuTitle = "║" + " Command Menu" + " "*(($barWidth) - 13) + "║"

        # Output to screen
        Clear-Host
        Write-Host $topBorderLines
        Write-Host $menuTitle
        Write-Host $midBorderLines

        # Draw the menu items
        for ($i = 0; $i -le $maxIndex; $i++) {

            $raw = " $($menuOptions[$i])"

            if ($raw.Length -gt $barWidth) {
                $raw = $raw.Substring(0, [Math]::Max(0, $barWidth - 1)) + "…"
            }

            $line = $raw.PadRight($barWidth)

            if ($i -eq $selection) {
                Write-Host "║" -NoNewline
                Write-Host $line -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline
                Write-Host "║"
            } else {
                Write-Host "║" -NoNewline
                Write-Host $line -NoNewline
                Write-Host "║"
            }
        }

        # Draw closing border
        Write-Host $bottomBorderLines

        # Process input selection
        $keyInfo = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

        switch ($keyInfo.VirtualKeyCode) {
            # Enter pressed
            13 { return $menuOptions[$selection] }

            # Escape pressed
            27 { return -1 }

            # Up arrow pressed
            38 { $selection = if ($selection -eq 0) { $maxIndex } else { $selection - 1 } }

            # Down arrow pressed
            40 { $selection = if ($selection -eq $maxIndex) { 0 } else { $selection + 1 } }

            default { }
        }
    }
}

function Write-CommandLineText {
    <###################################################################################
    .SYNOPSIS
        Helper Function that properly detects terminal type
    .DESCRIPTION
        This function now detects whether PsReadLine is present. If it isn't then 
        WScript.Shell.SendKeys is used instead. This provides compatibility with
        older terminal types, or terminal types which don't allow PsReadLine, such as 
        remote sessions, locked down terminals etc.
    .PARAMETER Text
        The text string to dump onto the command line once an option is selected.
    .EXAMPLE
        <not run manually>
    .NOTES
        Author          :  Jamie Crookes
        Date Created    :  26th February 2026
    ###################################################################################>
    param([string]$Text)

    # Get current terminal type for PsReadLine compatibles
    $psrlType = [type]::GetType(
        "Microsoft.PowerShell.PSConsoleReadLine, Microsoft.PowerShell.PSReadLine",
        $false
    )

    # Send the text based on the test condition above
    if ($psrlType) {
        # PsReadLine method
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($Text)
    }
    else {
        # WScript.Shell SendKeys method
        $shell = New-Object -ComObject WScript.Shell
        $shell.SendKeys($Text)
    }
}

## Set hotkey binding for command menu
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -BriefDescription 'Command Menu' -ScriptBlock {
    param($key, $arg)

    # Execute the function and store the selected item result
    $choice = Show-CommandMenu
    
    # Clear the screen or render issues occur
    Clear-Host

    # Leave the selected command on the input line
    if ($choice -ne -1) {
        Write-CommandLineText "$choice "
    } 
}