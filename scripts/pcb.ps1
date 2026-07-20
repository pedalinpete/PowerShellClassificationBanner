<#
.SYNOPSIS
    A Powershell Classification Banner

.DESCRIPTION
    Once installed this script will start a classification banner across the top of every system monitor. It will set the classification based on the classification
    that is set in the Classification key located in HKLM:\SOFTWARE\PowerShell Classification Banner. Policy objects have been created so that the classification can 
    be set via group policy. 

.EXAMPLE
    C:\Windows\System32\conhost.exe --headless powershell.exe -File "C:\Program Files\PowerBar Classification Banner\PowerBar.ps1"

.NOTES
    Author: Trent Taylor
    Date: 2026-5-1
    Version: 1.0
    GitHub: https://github.com/pedalinpete/Source/PowerShellClassificationBanner


#>

Add-Type -AssemblyName System.Windows.Forms, System.Drawing

$win32code = @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
    [StructLayout(LayoutKind.Sequential)]
    public struct RECT { public int Left, Top, Right, Bottom; }
    [StructLayout(LayoutKind.Sequential)]
    public struct APPBARDATA {
        public int cbSize;
        public IntPtr hWnd;
        public int uCallbackMessage;
        public int uEdge;
        public RECT rc;
        public IntPtr lParam;
    }
    [DllImport("shell32.dll")]
    public static extern IntPtr SHAppBarMessage(int dwMessage, ref APPBARDATA pData);
    [DllImport("user32.dll")]
    public static extern bool SystemParametersInfo(uint uiAction, uint uiParam, ref RECT pvParam, uint fWinIni);
}
"@
if (-not ([System.Management.Automation.PSTypeName]'Win32').Type) { Add-Type -TypeDefinition $win32code }

# --- Configuration ---

$RegPath    = "HKLM:\SOFTWARE\PowerShell Classification Banner"
$RegValue   = "Classification"
$Classification = Get-ItemPropertyValue -Path "$RegPath" -Name "Classification"

# Define Bar and Text Colors
$classi = @{
    'UNCLASSIFIED'   = [PSCustomObject]@{ BarColor = '#007A33'; TextColor = '0xFFFFFF'}
    'CUI'            = [PSCustomObject]@{ BarColor = '#502B85'; TextColor = '0xFFFFFF'}
    'CONFIDENTIAL'   = [PSCustomObject]@{ BarColor = '#0033A0'; TextColor = '0xFFFFFF'}
    'SECRET'         = [PSCustomObject]@{ BarColor = '#C8102E'; TextColor = '0xFFFFFF'}
    'TOP SECRET'     = [PSCustomObject]@{ BarColor = '#FF8C00'; TextColor = '#000000'}
    'TOP SECRET/SCI' = [PSCustomObject]@{ BarColor = '#FCE83A'; TextColor = '#000000'}
}
# Assign Bar Attributes
$BarHeight  = Get-ItemPropertyValue -Path "$RegPath" -Name "BarHeight"
$Font       = Get-ItemPropertyValue -Path "$RegPath" -Name "Font"
$FontSize   = Get-ItemPropertyValue -Path "$RegPath" -Name "FontSize"
$BarColor   = $Classi[$Classification].BarColor
$TextCenter = $Classification
$TextColor  = $Classi[$Classification].TextColor
$TextFont   = New-Object System.Drawing.Font("$Font", $FontSize, [System.Drawing.FontStyle]::Bold)
#$TextFont   = New-Object System.Drawing.Font("Consolas", 12, [System.Drawing.FontStyle]::Bold)
$Forms      = New-Object System.Collections.Generic.List[System.Windows.Forms.Form]
$OriginalWorkAreas = @{} # Store original work areas for cleanup

# ---------------------

# --- Refresh Logic ---

function Update-ClassificationUI {
    # Re-read all configuration values
    $current = Get-ItemPropertyValue -Path $RegPath -Name $RegValue -ErrorAction SilentlyContinue
    $newHeight = Get-ItemPropertyValue -Path $RegPath -Name "BarHeight" -ErrorAction SilentlyContinue
    $newFontName = Get-ItemPropertyValue -Path $RegPath -Name "Font" -ErrorAction SilentlyContinue
    $newSize = Get-ItemPropertyValue -Path $RegPath -Name "FontSize" -ErrorAction SilentlyContinue

    # Update Classification Colors and Text
    if ($null -ne $current -and $null -ne $classi[$current]) {
        $newBarColor  = [System.Drawing.ColorTranslator]::FromHtml($classi[$current].BarColor)
        $newTextColor = [System.Drawing.ColorTranslator]::FromHtml($classi[$current].TextColor)
        
        # Create a new Font object if Font or Size changed
        $newFont = New-Object System.Drawing.Font($newFontName, $newSize, [System.Drawing.FontStyle]::Bold)

        foreach ($f in $Forms) {
            # Update Colors and Text
            $f.BackColor = $newBarColor
            $f.Controls[0].Text = $current
            $f.Controls[0].ForeColor = $newTextColor
            
            # Update Font
            $f.Controls[0].Font = $newFont

            # 3. Update Bar Height and Work Area if Height changed
            if ($f.Height -ne $newHeight) {
                $f.Height = $newHeight
                $f.MaximumSize = New-Object System.Drawing.Size($f.Width, $newHeight)
                $f.Controls[0].Height = $newHeight
                
                # We need to find which screen this form belongs to to recalculate the Work Area
                $screen = [System.Windows.Forms.Screen]::FromHandle($f.Handle)
                $wa = $screen.WorkingArea
                $newWorkArea = New-Object Win32+RECT
                $newWorkArea.Left = $wa.Left
                $newWorkArea.Top = $screen.Bounds.Y + $newHeight
                $newWorkArea.Right = $wa.Right
                $newWorkArea.Bottom = $wa.Bottom
                [Win32]::SystemParametersInfo(0x002F, 0, [ref]$newWorkArea, 0x01)
            }
        }
    }
}


# ---------------------


try {
    foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
        $OriginalWorkAreas[$screen.DeviceName] = $screen.WorkingArea
        
        $topbar = New-Object System.Windows.Forms.Form
        $topbar.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None
        $topbar.FormBorderStyle = "None"
        $topbar.TopMost = $true
        $topbar.ShowInTaskbar = $false
        $topbar.StartPosition = "Manual"
        $topbar.BackColor = $BarColor
        $topbar.Location = New-Object System.Drawing.Point($screen.Bounds.X, $screen.Bounds.Y)
        $topbar.MinimumSize = New-Object System.Drawing.Size(0, 0)
        $topbar.MaximumSize = New-Object System.Drawing.Size($screen.Bounds.Width, $BarHeight)
        $topbar.Size = New-Object System.Drawing.Size($screen.Bounds.Width, $BarHeight)
        
        $rect = New-Object System.Drawing.Rectangle(0, 0, $screen.Bounds.Width, $BarHeight)
        $topbar.Region = New-Object System.Drawing.Region($rect)
        $topbar.ContextMenuStrip = $ContextMenu

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $TextCenter; $label.Font = $TextFont; $label.ForeColor = $TextColor; $label.AutoSize = $false
        $label.Location = New-Object System.Drawing.Point(0, 0)
        $label.Size = New-Object System.Drawing.Size($screen.Bounds.Width, $BarHeight)
        $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $label.UseCompatibleTextRendering = $true 
        $label.ContextMenuStrip = $ContextMenu
        $topbar.Controls.Add($label)

        $Forms.Add($topbar)
        $topbar.Show()

        # REGISTER AS APPBAR FOR THIS SCREEN
        $abd = New-Object Win32+APPBARDATA
        $abd.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($abd)
        $abd.hWnd = $topbar.Handle
        $abd.uEdge = 1 # Top
        [Win32]::SHAppBarMessage(0, [ref]$abd) # ABM_NEW

        # SET WORK AREA FOR THIS SCREEN
        # SystemParametersInfo updates the monitor that contains the specified rectangle
        $wa = $screen.WorkingArea
        $newWorkArea = New-Object Win32+RECT
        $newWorkArea.Left = $wa.Left
        $newWorkArea.Top = $screen.Bounds.Y + $BarHeight
        $newWorkArea.Right = $wa.Right
        $newWorkArea.Bottom = $wa.Bottom
        [Win32]::SystemParametersInfo(0x002F, 0, [ref]$newWorkArea, 0x01) # SPI_SETWORKAREA
    }

        # Setup Refresh Timer (checks every 5 seconds)
        $Timer = New-Object System.Windows.Forms.Timer
        $Timer.Interval = 5000 
        $Timer.Add_Tick({ Update-ClassificationUI })
        $Timer.Start()

    [System.Windows.Forms.Application]::Run()

} finally {
    # CLEANUP ALL SCREENS
    foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
        if ($OriginalWorkAreas.ContainsKey($screen.DeviceName)) {
            $orig = $OriginalWorkAreas[$screen.DeviceName]
            $restoreArea = New-Object Win32+RECT
            $restoreArea.Left = $orig.Left; $restoreArea.Top = $orig.Top; $restoreArea.Right = $orig.Right; $restoreArea.Bottom = $orig.Bottom
            [Win32]::SystemParametersInfo(0x002F, 0, [ref]$restoreArea, 0x01)
        }
    }
    foreach ($f in $Forms) { 
        $abd = New-Object Win32+APPBARDATA
        $abd.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($abd)
        $abd.hWnd = $f.Handle
        [Win32]::SHAppBarMessage(1, [ref]$abd) # ABM_REMOVE
        $f.Dispose() 
    }
}
