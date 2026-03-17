[Setup]
; NOTE: The value of AppId uniquely identifies this application. Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{D37E7A6B-99DE-4581-9AE7-23A4DBA4CC61}
AppName=Task Flow
AppVersion=1.3.19
AppPublisher=Robel
DefaultDirName={localappdata}\Task Flow
DisableProgramGroupPage=yes
; Produce the installer in the current TaskFlowExe directory
OutputDir=.
OutputBaseFilename=TaskFlow_Installer
; Use the icon flutter generated for our app
SetupIconFile="..\windows\runner\resources\app_icon.ico"
Compression=lzma
SolidCompression=yes
WizardStyle=modern
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; IMPORTANT: task_recorder_pro.exe needs to be your main executable
Source: "..\build\windows\x64\runner\Release\task_recorder_pro.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Task Flow"; Filename: "{app}\task_recorder_pro.exe"
Name: "{autodesktop}\Task Flow"; Filename: "{app}\task_recorder_pro.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\task_recorder_pro.exe"; Description: "{cm:LaunchProgram,Task Flow}"; Flags: nowait postinstall skipifsilent
