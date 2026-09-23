# PowerShellClassificationBanner
Classification Banner for Windows written in PowerShell

# An NSIS install package is coming but in the interim perform the following manually

Create Program Files folder
C:\Program Files\PowerShell Classification Banner

Copy pct.ps1, cc.ps1, and the admx folder to C:\Program Files\PowerShell Classification Banner

Create Start Menu folder
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerShell Classification Banner

Copy ConfigureClassification.lnk C:\Program Files\PowerShell Classification Banner to C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PowerShell Classification Banner

Apply key.reg to create the initial registry configuration

Place PowerShell Classification Banner.lnk in:
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp

if needed copy the admx/adml files to their respective locations in: C:\Windows\PolicyDefinitions 

