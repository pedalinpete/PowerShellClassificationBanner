# PowerShellClassificationBanner
Classification Banner for Windows written in PowerShell

# An NSIS install package is comming but in the interim perform the following manually

# Create Program Files folder
C:\Program Files\PowerShell Classification Banner

# Copy the two scripts
Copy pct.ps1 and cc.ps1 to C:\Program Files\PowerShell Classification Banner

# Create the Registry key (use key.reg)
Apply key.reg

# Place PowerShell Classification Banner.lnk in:
C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
