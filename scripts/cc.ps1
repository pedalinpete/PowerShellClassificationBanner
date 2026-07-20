<#
.SYNOPSIS
    GUI configuration of the classification status

.DESCRIPTION
    This script must be run as an admin but allows an administrative user to update the classification status of the PowerShell Classification Banner.
    The form simply updates the registry value that controls the classification.

.EXAMPLE
    .\ConfigureClassification.ps1

.NOTES
    Author: Trent Taylor
    Date: 2026-5-1
    Version: 1.0
    GitHub: https://github.com/pedalinpete/Source/PowerShellClassificationBanner


#>

# --- Force Run as Administrator ---
$currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Start-Process powershell.exe -Verb RunAs -ArgumentList $arguments
    exit
}

# --- Hide Console Window ---
$showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

$consoleHandle = (Get-Process -Id $PID).MainWindowHandle
if ($consoleHandle -ne [IntPtr]::Zero) {
    $showWindowAsync::ShowWindowAsync($consoleHandle, 0)
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Registry Configuration ---
$regPath = "HKLM:\SOFTWARE\PowerShell Classification Banner"
if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

function Save-Settings {
    Set-ItemProperty -Path $regPath -Name "Classification" -Value $dropDown.SelectedItem -Force
    Set-ItemProperty -Path $regPath -Name "FontSize" -Value $numFontSize.Value -Force
    Set-ItemProperty -Path $regPath -Name "Font" -Value $cmbFont.SelectedItem -Force
    Set-ItemProperty -Path $regPath -Name "BarHeight" -Value $numBarHeight.Value -Force
}

# --- GUI Construction ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "PCB Configuration"
$form.Size = New-Object System.Drawing.Size(460, 240)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.TopMost = $true
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$regValues = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue

# --- ROW 1: Classification & Bar Height ---
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = "Classification"
$label1.Location = New-Object System.Drawing.Point(20, 15)
$label1.Size = New-Object System.Drawing.Size(180, 15)
$form.Controls.Add($label1)

$dropDown = New-Object System.Windows.Forms.ComboBox
$dropDown.Location = New-Object System.Drawing.Point(20, 35)
$dropDown.Size = New-Object System.Drawing.Size(180, 25)
$dropDown.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$items = @("UNCLASSIFIED", "CUI", "CONFIDENTIAL", "SECRET", "TOP SECRET", "TOP SECRET/SCI")
$dropDown.Items.AddRange($items)
$dropDown.SelectedItem = if ($regValues.Classification -and $items -contains $regValues.Classification) { $regValues.Classification } else { "UNCLASSIFIED" }
$form.Controls.Add($dropDown)

$label4 = New-Object System.Windows.Forms.Label
$label4.Text = "Bar Height"
$label4.Location = New-Object System.Drawing.Point(220, 15)
$label4.Size = New-Object System.Drawing.Size(80, 15)
$form.Controls.Add($label4)

$numBarHeight = New-Object System.Windows.Forms.NumericUpDown
$numBarHeight.Location = New-Object System.Drawing.Point(220, 35)
$numBarHeight.Size = New-Object System.Drawing.Size(80, 25)
$numBarHeight.Minimum = 10
$numBarHeight.Maximum = 200
$numBarHeight.Value = if ($regValues.BarHeight) { [math]::Max(10, [math]::Min(200, $regValues.BarHeight)) } else { 25 }
$form.Controls.Add($numBarHeight)

# --- ROW 2: Font Family & Font Size ---
$label2 = New-Object System.Windows.Forms.Label
$label2.Text = "Font Family"
$label2.Location = New-Object System.Drawing.Point(20, 75)
$label2.Size = New-Object System.Drawing.Size(180, 15)
$form.Controls.Add($label2)

$cmbFont = New-Object System.Windows.Forms.ComboBox
$cmbFont.Location = New-Object System.Drawing.Point(20, 95)
$cmbFont.Size = New-Object System.Drawing.Size(180, 25)
$cmbFont.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
$fonts = (New-Object System.Drawing.Text.InstalledFontCollection).Families.Name
$cmbFont.Items.AddRange($fonts)
$savedFont = if ($regValues.Font) { $regValues.Font } else { "Segoe UI" }
$cmbFont.SelectedItem = if ($fonts -contains $savedFont) { $savedFont } else { $fonts[0] }
$form.Controls.Add($cmbFont)

$label3 = New-Object System.Windows.Forms.Label
$label3.Text = "Font Size"
$label3.Location = New-Object System.Drawing.Point(220, 75)
$label3.Size = New-Object System.Drawing.Size(80, 15)
$form.Controls.Add($label3)

$numFontSize = New-Object System.Windows.Forms.NumericUpDown
$numFontSize.Location = New-Object System.Drawing.Point(220, 95)
$numFontSize.Size = New-Object System.Drawing.Size(80, 25)
$numFontSize.Minimum = 6
$numFontSize.Maximum = 72
$numFontSize.Value = if ($regValues.FontSize) { [math]::Max(6, [math]::Min(72, $regValues.FontSize)) } else { 10 }
$form.Controls.Add($numFontSize)

# --- Buttons (Windows 11 Standard Style) ---
# Standard Win11 Button Size is ~94x32
$btnWidth = 94
$btnHeight = 32
$btnY = 150

$btnApply = New-Object System.Windows.Forms.Button
$btnApply.Text = "Apply"
$btnApply.Location = New-Object System.Drawing.Point(120, $btnY)
$btnApply.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnApply.Add_Click({ Save-Settings })
$form.Controls.Add($btnApply)

$btnSave = New-Object System.Windows.Forms.Button
$btnSave.Text = "OK"
$btnSave.Location = New-Object System.Drawing.Point(224, $btnY)
$btnSave.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnSave.Add_Click({ Save-Settings; $form.Close() })
$form.Controls.Add($btnSave)

$btnCancel = New-Object System.Windows.Forms.Button
$btnCancel.Text = "Cancel"
$btnCancel.Location = New-Object System.Drawing.Point(328, $btnY)
$btnCancel.Size = New-Object System.Drawing.Size($btnWidth, $btnHeight)
$btnCancel.Add_Click({ $form.Close() })
$form.Controls.Add($btnCancel)

$form.ShowDialog() | Out-Null
