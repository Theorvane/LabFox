; Inno Setup script for the LabFox Windows build.
;
; Windows is a direct download rather than a store, so this installer is the
; whole install experience: it copies the release
; build, makes the Start-menu entry, and registers an uninstaller. The portable
; zip still ships beside it.
;
; AppVersion is passed in by the release workflow (/DAppVersion=...) so the
; installer cannot claim a version the release is not.

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\..\build\windows\x64\runner\Release"
#endif

[Setup]
AppId={{7A2B0E5C-8E2D-4E27-9E51-2C4C2E1A9F31}
AppName=LabFox
AppVersion={#AppVersion}
AppPublisher=sloki9637
AppPublisherURL=https://www.sloki9637.com
AppSupportURL=https://github.com/Theorvane/labfox/issues
DefaultDirName={autopf}\LabFox
DefaultGroupName=LabFox
DisableProgramGroupPage=yes
; Nothing here needs administrator, and an unsigned installer should not be
; asking for it: install per user and leave the machine alone.
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
OutputDir=..\..\..\..\dist
OutputBaseFilename=labfox-windows-x64-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName=LabFox
UninstallDisplayIcon={app}\labfox.exe
LicenseFile=..\..\..\..\LICENSE

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\LabFox"; Filename: "{app}\labfox.exe"
Name: "{autodesktop}\LabFox"; Filename: "{app}\labfox.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\labfox.exe"; Description: "{cm:LaunchProgram,LabFox}"; Flags: nowait postinstall skipifsilent
