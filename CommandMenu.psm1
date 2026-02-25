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
        $MenuOptions = Get-Content -Path "$HOME\commandmenu.txt"
    } else {
        throw "Favourites file $HOME\commandmenu.txt not found"
    }

    # Check for file contents and throw if empty
    if (-not $MenuOptions -or $MenuOptions.Count -eq 0) {
        throw "MenuOptions cannot be empty."
    }

    # Make some nooooooise
    [console]::beep(2000,80)
    [console]::beep(2000,80)

    # Some maths for menu sizing
    $maxIndex  = $MenuOptions.Count - 1
    $selection = 0
    $rightMargin = 2

    # Longest entry + padding
    $longest = ($MenuOptions | Measure-Object -Property Length -Maximum).Maximum
    $targetBarWidth = ($longest + 4) + 10

    while ($true) {
        # Cap to console width each redraw so it won't wrap
        $windowWidth = $Host.UI.RawUI.WindowSize.Width
        $barWidth = [Math]::Min($targetBarWidth, [Math]::Max(10, $windowWidth - $rightMargin))

        # Menu title drawing preparation
        $topBorderLines = "╔" + "═"*(($barWidth)) + "╗"
        $midBorderLines = "╠" + "═"*(($barWidth)) + "╣"
        $bottomBorderLines = "╚" + "═"*(($barWidth)) + "╝"
        $menuTitle = "║" + " PowerShell Favourites" + " "*(($barWidth) - 22) + "║"

        # Output to screen
        Clear-Host
        Write-Host $topBorderLines
        Write-Host $menuTitle
        Write-Host $midBorderLines

        # Draw the menu items
        for ($i = 0; $i -le $maxIndex; $i++) {

            $raw = " $($MenuOptions[$i])"

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
            13 { return $MenuOptions[$selection] }
            27 { return -1 }
            38 { $selection = if ($selection -eq 0) { $maxIndex } else { $selection - 1 } }
            40 { $selection = if ($selection -eq $maxIndex) { 0 } else { $selection + 1 } }
            default { }
        }
    }
}

## Set hotkey binding for bookmark selection
Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -BriefDescription 'PsFaves menu' -ScriptBlock {
    param($key, $arg)

    # Execute the function and store the selected item result
    $choice = Show-CommandMenu
    
    # Clear the screen or render issues occur
    Clear-Host

    # Leave the selected command on the input line
    if ($choice -ne -1) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$choice ")
    }
}