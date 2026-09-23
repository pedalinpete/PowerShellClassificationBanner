; .SYNOPSIS
;   Installer for Powershell Classfication Banner
;
; .DESCRIPTION
;   Powershell Classification Banner installation script
;
; .NOTES
;   Author:     Trent Taylor
;   Date:       2026-09-22
;   Version:    1.0.0
; ==========================================================================

Unicode True
Name "Powershell Classification Banner"
Outfile "InstallPCB.exe" 

!include MUI2.nsh
!include x64.nsh
!include LogicLib.nsh    
!define PSEXEC_INCLUDED
!define StrContains "!insertmacro StrContains"
!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-install.ico"
!define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\orange.bmp"
!define MUI_PAGE_HEADER_TEXT "PowerShell Classification Banner"
!define MUI_UI "${NSISDIR}\Contrib\UIs\modern.exe"
!define MUI_INSTFILESPAGE_COLORS "/windows"
!define MUI_INSTFILESPAGE_PROGRESSBAR "smooth"
!define NAME "PowerShell Classification Banner"
!define DESC "PowerShell Classification Banner"
!define COP "PCB"
!define VER "1.0.0.0"
!define INSTVER "1.0.0.0"
BrandingText "PowerShell Classification Banner"

# This sets file metadata for the patch executable 
VIProductVersion "${INSTVER}" # This is the parameter to add the installer version
VIAddVersionKey ProductName "${NAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey FileDescription "${DESC}"
VIAddVersionKey LegalCopyright "${COP}"

RequestExecutionLevel admin
ShowInstDetails nevershow
ShowUninstDetails nevershow


# Variables
# Install location Form
Var hCtl_InstallLocation
Var hCtl_InstallLocation_install_location
Var hCtl_InstallLocation_install_directory_Txti
Var hCtl_InstallLocation_install_directory_Txt
Var hCtl_InstallLocation_install_directory_Btn
# Classfication Form
Var hCtl_SetClassfication
Var hCtl_SetClassfication_ClassGroupbox
Var hCtl_SetClassfication_ClassLabel
Var hCtl_SetClassfication_Classificationi
Var hCtl_SetClassfication_Classification
# Classification Values
Var ClassyValue

# Execute Custom Forms
Page Custom InstallLocation InstallLocationLeave
Page Custom SetClassfication SetClassficationLeave
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_LANGUAGE "English"


Section "Install"
	
	# Set context to all users
	SetShellVarContext all
	
	SetOutPath $INSTDIR
	File /r ".\files\*.*"
	
	# Set NSIS to 64bit registry mode.
	${If} ${RunningX64}
	SetRegView 64
	
	# Create registry keys for classification banner
	WriteRegStr HKLM "SOFTWARE\PowerShell Classification Banner" 'Font' 'Consolas'
	WriteRegStr HKLM "SOFTWARE\PowerShell Classification Banner" 'FontSize' '12'
	WriteRegStr HKLM "SOFTWARE\PowerShell Classification Banner" 'Classification' '$ClassyValue'
	WriteRegStr HKLM "SOFTWARE\PowerShell Classification Banner" 'BarHeight' '20'
	WriteRegStr HKLM "SOFTWARE\PowerShell Classification Banner" 'Official_DoD_Colors' 'Purple-3D1E5A, Blue-0033A0, Green-007A33, Red-C8102E, Orange-FF671F, Yellow-F7EA48'
	
	# Create Programs and Features Record
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "DisplayName" "PowerShell Classification Banner"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "Publisher" "Trent Taylor"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "Size" ""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "DisplayVersion" "${VER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "DisplayIcon" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" \
                 "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB" 'EstimatedSize' '6892'			 
				 
	
	SetRegView LastUsed
	${EndIf}
	
	# Copy Policy files
		CopyFiles $INSTDIR\admx\en-US\*.adml $WINDIR\PolicyDefinitions\en-US
		CopyFiles $INSTDIR\admx\*.admx $WINDIR\PolicyDefinitions
	
	# Create startup shortcut
	CreateShortCut "$STARTMENU\Programs\StartUp\PowerShell Classification Banner.lnk" "$\"C:\Windows\System32\conhost.exe$\"" "--headless powershell.exe -File $\"$INSTDIR\pcb.ps1$\"" "$INSTDIR\pcb.ico"
	
	# Create Start Menu Shortcuts
	CreateDirectory "$STARTMENU\Programs\Powershell Classfication Banner"
	CreateShortCut "$STARTMENU\Programs\Powershell Classfication Banner\Configure Classification.lnk" "$\"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe$\"" "-ExecutionPolicy Bypass -WindowStyle Hidden -File $\"$INSTDIR\cc.ps1$\"" "$INSTDIR\pcb.ico"

	
	# Run pcb after Install
	#SetOutPath "\$INSTDIR"

	# C:\Windows\SysNative forces the 32-bit installer to run the real 64-bit PowerShell
	Exec `C:\Windows\SysNative\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$INSTDIR\pcb.ps1"`




	
	# Write the Uninstaller file
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

Section "Uninstall"
	
	# Set context to all users
	SetShellVarContext all
	
	# Kill the pcb process
	#nsExec::Exec 'powershell.exe -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name = \'powershell.exe\' AND CommandLine LIKE \'%pcb.ps1%\'\" | Invoke-CimMethod -MethodName Terminate"'
	ExecShellWait "open" "powershell.exe" `-NoProfile -WindowStyle Hidden -Command "Get-CimInstance Win32_Process -Filter 'Name=\"powershell.exe\" AND CommandLine LIKE \"%pcb.ps1%\"' | Invoke-CimMethod -MethodName Terminate"` SW_HIDE

	# Set NSIS to 64bit registry mode.
	${If} ${RunningX64}
	SetRegView 64
	
	# Create registry keys for classification banner
	DeleteRegValue HKLM "SOFTWARE\PowerShell Classification Banner" 'Font'
	DeleteRegValue HKLM "SOFTWARE\PowerShell Classification Banner" 'FontSize'
	DeleteRegValue HKLM "SOFTWARE\PowerShell Classification Banner" 'Classification'
	DeleteRegValue HKLM "SOFTWARE\PowerShell Classification Banner" 'BarHeight'
	DeleteRegValue HKLM "SOFTWARE\PowerShell Classification Banner" 'Official_DoD_Colors'
	DeleteRegKey HKLM "SOFTWARE\PowerShell Classification Banner"
	
	# Remove programs and features record
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB"
	
	SetRegView LastUsed
	${EndIf}
	
	# Copy files for classification banner
	RMDir /r /REBOOTOK "$INSTDIR"
	Delete $WINDIR\PolicyDefinitions\en-US\PCB.adml
	Delete $WINDIR\PolicyDefinitions\PCB.admx
	Delete "$STARTMENU\Programs\StartUp\PowerShell Classification Banner.lnk"
	Delete "$STARTMENU\Programs\Powershell Classfication Banner\Configure Classification.lnk"
	RMDir /r /REBOOTOK "$STARTMENU\Powershell Classfication Banner"
	
SectionEnd

#################### Below here, there be functions ##########################################

Function InstallLocation
  
  ; === InstallLocation (type: Dialog) ===
  nsDialogs::Create 1018
  Pop $hCtl_InstallLocation
  ${If} $hCtl_InstallLocation == error
    Abort
  ${EndIf}
  !insertmacro MUI_HEADER_TEXT "Installation Location" "Select the installation location."
  
  ; === install_location (type: GroupBox) ===
  ${NSD_CreateGroupBox} 8u 43u 280u 35u "Install Directory"
  Pop $hCtl_InstallLocation_install_location
  
  ; === install_directory_Txt (type: Text) ===
  ${NSD_CreateText} 16u 55u 221u 12u "C:\Program Files\PowerShell Classfication Banner"
  Pop $hCtl_InstallLocation_install_directory_Txti
  
  ; === install_directory_Btn (type: Button) ===
  ${NSD_CreateButton} 238u 55u 39u 14u "Browse..."
  Pop $hCtl_InstallLocation_install_directory_Btn
  ${NSD_OnClick} $hCtl_InstallLocation_install_directory_Btn OnDirBrowse
  
  nsDialogs::Show
  
FunctionEnd


Function OnDirBrowse
	Pop $R0
	${If} $R0 == $hCtl_InstallLocation_install_directory_Btn
		${NSD_GetText} $hCtl_InstallLocation_install_directory_Txti $R0
		nsDialogs::SelectFolderDialog "$INSTDIR" "" "$R0"
		Pop $R0
		${If} "$R0" != "error"
			${NSD_SetText} $hCtl_InstallLocation_install_directory_Txti "$R0"
		${EndIf}
	${EndIf}
FunctionEnd


Function InstallLocationLeave

    ${NSD_GetText} $hCtl_InstallLocation_install_directory_Txti $0

	# Put the form values back into the variable names
	StrCpy $hCtl_InstallLocation_install_directory_Txt $0
	StrCpy $INSTDIR $hCtl_InstallLocation_install_directory_Txt
	
	# Make sure all fields have values fail if any are blank.
	${if} $hCtl_InstallLocation_install_directory_Txt == ""
	MessageBox MB_ICONSTOP "The installation directory is required."
	call Failme
	${endif}

FunctionEnd

Function SetClassfication
  
  ; === SetClassfication (type: Dialog) ===
  nsDialogs::Create 1018
  Pop $hCtl_SetClassfication
  ${If} $hCtl_SetClassfication == error
    Abort
  ${EndIf}
  !insertmacro MUI_HEADER_TEXT "Initial Classification" "Setting the initial classification"
  
  ; === ClassGroupbox (type: GroupBox) ===
  ${NSD_CreateGroupBox} 19u 42u 255u 54u "Classification"
  Pop $hCtl_SetClassfication_ClassGroupbox
  
  ; === ClassLabel (type: Label) ===
  ${NSD_CreateLabel} 36u 63u 54u 13u "Classification:"
  Pop $hCtl_SetClassfication_ClassLabel
  
  ; === Classification (type: DropList) ===
  ${NSD_CreateDropList} 93u 63u 142u 13u ""
  Pop $hCtl_SetClassfication_Classificationi
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "CONTROLLED UNCLASSIFIED INFORMATION"
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "CONFIDENTIAL"
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "UNCLASSIFIED"
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "SECRET"
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "TOP SECRET"
  ${NSD_CB_AddString} $hCtl_SetClassfication_Classificationi "TOP SECRET/SCI"
  ${NSD_CB_SelectString} $hCtl_SetClassfication_Classificationi "UNCLASSIFIED"
  
  nsDialogs::Show
  
FunctionEnd

Function SetClassficationLeave

    ${NSD_GetText} $hCtl_SetClassfication_Classificationi $0

	# Put the form values back into the variable names
	StrCpy $hCtl_SetClassfication_Classification $0

	# Set the classification colors
	${if} $hCtl_SetClassfication_Classification == "CONTROLLED UNCLASSIFIED INFORMATION"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${elseif} $hCtl_SetClassfication_Classification == "CONFIDENTIAL"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${elseif} $hCtl_SetClassfication_Classification == "UNCLASSIFIED"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${elseif} $hCtl_SetClassfication_Classification == "SECRET"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${elseif} $hCtl_SetClassfication_Classification == "TOP SECRET"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${elseif} $hCtl_SetClassfication_Classification == "TOP SECRET/SCI"
		StrCpy $ClassyValue  "$hCtl_SetClassfication_Classification"
	${endif}

	# Make sure all fields have values fail if any are blank.
	${if} $hCtl_SetClassfication_Classification == ""
	MessageBox MB_ICONSTOP "You must select a default classification."
	call Failme
	${endif}

FunctionEnd

Function .onInit

	# Set the Registry to 64Bit
	SetRegView 64
		
	# Read the uninstall string
	ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\PCB"  "UninstallString"

	# This handles the silent installer defaults 
	${If} ${Silent}

		# Remove Previous install and call the installer again to install 
		${If} $0 != ""
			ExecWait '"$0" /S'
			ExecWait "$EXEDIR\$EXEFILE /S"
		${EndIf}

		# Set default installation directory
		StrCpy $INSTDIR "C:\Program Files\PowerShell Classification Banner"

		# Set to Unclassified by default
		StrCpy $ClassyValue  "Unclassified"

		# Execute Silent Install
		SetSilent silent

	${else} # Manual Install

		# Remove previous install before installing
		${If} $0 != ""
			ExecWait '"$0" /S'
		${EndIf}

	${EndIf}


FunctionEnd

Function Failme
	StrCmp $6 0 next_button return_to_page ; Next button clicked
	return_to_page:
	abort
	next_button:
FunctionEnd