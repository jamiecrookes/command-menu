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
        
        # Make sure barWidth is an Int32 to avoid double
        $barWidth = [int]([Math]::Min($targetBarWidth, [Math]::Max(10, $windowWidth - $rightMargin)))

        # Character codepoints required for PowerShell 5.1 BOM/UTF compatibility
        $TL = [char]0x2554; $HZ = [char]0x2550; $TR = [char]0x2557
        $ML = [char]0x2560; $MR = [char]0x2563
        $BL = [char]0x255A; $BR = [char]0x255D
        $VL = [char]0x2551

        # Cast the repeating char to string before using * to draw borders
        $topBorderLines    = "$TL" + ("$HZ" * $barWidth) + "$TR"
        $midBorderLines    = "$ML" + ("$HZ" * $barWidth) + "$MR"
        $bottomBorderLines = "$BL" + ("$HZ" * $barWidth) + "$BR"
        $menuTitle         = "$VL" + " Command Menu" + (" " * ($barWidth - 13)) + "$VL"

        # Output to screen
        [Console]::Clear()
        Write-Host $topBorderLines
        Write-Host $menuTitle
        Write-Host $midBorderLines

        # Draw the menu items
        for ($i = 0; $i -le $maxIndex; $i++) {

            $raw = " $($menuOptions[$i])"

            if ($raw.Length -gt $barWidth) {
                $raw = $raw.Substring(0, [Math]::Max(0, $barWidth - 1)) + $EL
            }

            $line = $raw.PadRight($barWidth)

            if ($i -eq $selection) {
                # Write selected entry
                Write-Host $VL -NoNewline
                Write-Host $line -BackgroundColor DarkRed -ForegroundColor Yellow -NoNewline
                Write-Host $VL
            } else {
                # Write unselected entries
                Write-Host $VL -NoNewline
                Write-Host $line -NoNewline
                Write-Host $VL
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

# Process the hotkey if PsReadLine is available
if (Get-Command Set-PSReadLineKeyHandler -ErrorAction SilentlyContinue) {
    Set-PSReadLineKeyHandler -Chord 'Ctrl+g' -BriefDescription 'Command Menu' -ScriptBlock {
        param($key, $arg)

        # Spawn menu
        $choice = Show-CommandMenu

        # Clear the screen and leave the selection on the input line on enter press
        [Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
        if ($choice -ne -1) {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("$choice ")
        }
    }
}