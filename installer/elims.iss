; ELIMS Windows installer (Inno Setup 6)
; Compile via installer\build-installer.ps1 (assembles payload first).
; Offline install: place images.tar next to ELIMS-Setup.exe before running it.

[Setup]
AppName=ELIMS
AppVersion=0.1.0
AppPublisher=ASLM 2026 ELIMS Project
AppPublisherURL=https://github.com/DrTemesgen/ELIMS
DefaultDirName={sd}\ELIMS
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=..\dist
OutputBaseFilename=ELIMS-Setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Files]
Source: "..\dist\payload\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs ignoreversion

[Icons]
Name: "{autoprograms}\ELIMS\ELIMS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\launch-elims.ps1"""; WorkingDir: "{app}"; Comment: "Start ELIMS and open it in the browser"
Name: "{autoprograms}\ELIMS\Stop ELIMS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\stop-elims.ps1"""; WorkingDir: "{app}"
Name: "{autoprograms}\ELIMS\Update ELIMS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\update-elims.ps1"""; WorkingDir: "{app}"; Comment: "Download the latest ELIMS version (requires internet)"
Name: "{autoprograms}\ELIMS\ELIMS Status"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -NoExit -File ""{app}\scripts\status-elims.ps1"""; WorkingDir: "{app}"
Name: "{autodesktop}\ELIMS"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\launch-elims.ps1"""; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; GroupDescription: "Additional icons:"

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\installer\install-elims.ps1"" -ImagesTar ""{src}\images.tar"""; StatusMsg: "Setting up Docker and loading ELIMS (this can take a while)..."; Flags: waituntilterminated

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\scripts\stop-elims.ps1"""; Flags: waituntilterminated; RunOnceId: "StopElims"
