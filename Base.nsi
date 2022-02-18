!include "FileFunc.nsh"
!include "LogicLib.nsh"

OutFile "Lua_v%FSV%_%AA%-Bits.exe"

Name "Lua %X.X.X%"
Icon "icon.ico"

; File > Properties > Details
VIAddVersionKey /Lang=0 "ProductName" "The Lua programming language"
VIAddVersionKey /Lang=0 "ProductVersion" "%X.X.X%"
VIAddVersionKey /Lang=0 "CompanyName" "PUC-Rio"
VIAddVersionKey /Lang=0 "LegalCopyright" "%LEGAL_COPY%"
VIAddVersionKey /Lang=0 "FileDescription" "Installer for the Lua programming language"
; Required to prevent wanings
VIAddVersionKey /Lang=0 "FileVersion" ""
; File version
VIProductVersion 0.0.0.0

; Enables show (un)installation details
ShowInstDetails Show
ShowUninstDetails Show

; Admin rights are optional
RequestExecutionLevel User
; But still we'll handle it
Var /Global IsAdmin

; For uninstall info
!define URegPath "Software\Microsoft\Windows\CurrentVersion\Uninstall\Lua%SV%"

; -------------------------------------------------------------
; Pages of the installer, in the same order that will be shown
PageEx License
  Caption ": License notice"
  LicenseText "License notice, please read before installing this software. If you accept the license terms, click the $\"I understand$\" button." "I understand"
  LicenseData "LuaLicense"
PageExEnd

PageEx Directory
  Caption ": Selec installation directory"
  DirText "Select where to isntall Lua %X.X.X% (optional). If you choose a custom directory, please make sure this installer has write permissions."
PageExEnd

Page Components

PageEx InstFiles
  Caption ": Installing..."
  CompletedText "Done!"
PageExEnd

; This will be executed when the installer is nearly finished initializing
Function .onInit
  ; -------------------------------------
  ; Gets the account type (admin or not)
  UserInfo::getAccountType
  Pop $0

  ; --------------------------------------------------------------
  ; Sets the installation directory depending on user permissions
  ${If} $0 == "Admin"
    StrCpy $INSTDIR "%PROGRAM_FILES%\Lua%SV%"
    Push True
    Pop $IsAdmin
  ${Else}
    StrCpy $INSTDIR "$LOCALAPPDATA\Lua%SV%"
    Push False
    Pop $IsAdmin
  ${EndIf}
FunctionEnd

; ----------
; Installer
Section "-Install"
  ; -----------------------------------
  ; Path where files will be installed
  SetOutPath $INSTDIR

  ; -----------------
  ; Files to install
  File "lua-%X.X.X%-%AA%\lua%SV%.exe"
  %LUAC_INST_FILE%
  File "lua-%X.X.X%-%AA%\lua%SV%.dll"
  File "icon.ico"

  ; ------------------------
  ; Creates the uninstaller
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ; ---------------
  ; Uninstall info
  ${If} $IsAdmin == True
    WriteRegStr HKLM "${URegPath}" "DisplayName" "The Lua programming language"
    WriteRegStr HKLM "${URegPath}" "DisplayIcon" "$\"$INSTDIR\icon.ico$\""
    WriteRegStr HKLM "${URegPath}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKLM "${URegPath}" "InstallLocation" "$\"$INSTDIR$\""
    WriteRegStr HKLM "${URegPath}" "DisplayVersion" "%X.X.X%"
    WriteRegStr HKLM "${URegPath}" "Publisher" "PUC-Rio"
    WriteRegStr HKLM "${URegPath}" "URLInfoAbout" "https://lua.org/"
  ${Else}
    WriteRegStr HKCU "${URegPath}" "DisplayName" "The Lua programming language"
    WriteRegStr HKCU "${URegPath}" "DisplayIcon" "$\"$INSTDIR\icon.ico$\""
    WriteRegStr HKCU "${URegPath}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKCU "${URegPath}" "InstallLocation" "$\"$INSTDIR$\""
    WriteRegStr HKCU "${URegPath}" "DisplayVersion" "%X.X.X%"
    WriteRegStr HKCU "${URegPath}" "Publisher" "PUC-Rio"
    WriteRegStr HKCU "${URegPath}" "URLInfoAbout" "https://lua.org/"
  ${EndIf}

  ; ---------------------------------------------------------------
  ; Calculates installation size and adds it to the uninstall info
  ${GetSize} "$INSTDIR" "/S=0K" $0 $1 $2
  IntFmt $0 "0x%08X" $0

  ${If} $IsAdmin == True
    WriteRegDWORD HKLM "${URegPath}" "EstimatedSize" "$0"
  ${Else}
    WriteRegDWORD HKCU "${URegPath}" "EstimatedSize" "$0"
  ${EndIf}
SectionEnd

Section "Add Lua %X.X.X% to PATH"
  ; ---------------------
  ; Adds Lua to PATH
  ${If} $IsAdmin == True
    EnVar::SetHKLM
  ${Else}
    EnVar::SetHKCU
  ${EndIf}

  EnVar::AddValue "PATH" "$INSTDIR"
  DetailPrint "Added $INSTDIR to PATH"
SectionEnd

; ------------
; Uninstaller
Section "Uninstall"
  ; -----------------
  ; Delete the files
  Delete "$INSTDIR\uninstall.exe"
  Delete "$INSTDIR\lua%SV%.exe"
  %LUAC_DEL_FILE%
  Delete "$INSTDIR\lua%SV%.dll"
  Delete "$INSTDIR\icon.ico"
  DetailPrint "Removed all files"

  ; --------------------------
  ; Removes Lua from PATH
  ${If} $IsAdmin == True
    EnVar::SetHKLM
  ${Else}
    EnVar::SetHKCU
  ${EndIf}

  EnVar::DeleteValue "PATH" "$INSTDIR"
  DetailPrint "Removed $INSTDIR from PATH"

  ; ----------------------
  ; Delete uninstall info
  ${If} $IsAdmin == True
    DeleteRegKey HKLM "${URegPath}"
  ${Else}
    DeleteRegKey HKCU "${URegPath}"
  ${EndIf}

  DetailPrint "Removed uninstall info"

  ; -------------------
  ; Delete data folder
  RMDir "$INSTDIR"
SectionEnd