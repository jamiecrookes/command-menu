# [1.2.1] - 2026-02-26
### Removed
- Support for non PSReadLine terminals. It makes no sense to include it
  as there's no way to bind to a hotkey without it.

# [1.2.0] - 2026-02-26
### Fixed
- Windows PowerShell 5.1 support was broken, now fixed
- Menu border glyphs had to use ascii codes rather than their translated form
  due to BOM/UTF encoder issues with Windows PowerShell. I should have tested
  Windows PowerShell. I developed in PS Core and assumed it would work.

# [1.1.0] - 2026-02-26
### Added
Function to do the command line writing: Write-CommandLineText:
- Module now supports Non-PsReadLine terminals
- Auto-detects the terminal type and outputs the correct method
- WScript.SendKey method for other terminal types
- ChangeLog.md
### Changed
- Beep count to 1, as it was a little annoying
- Readme updated to denote the additions above

# [1.0.0] - 2026-02-25
### Added
- Initial Release