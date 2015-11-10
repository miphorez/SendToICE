program SendToICE;

uses
  Windows,
  SysUtils,
  SendKey in 'SendKey.pas',
  frmToICE in 'frmToICE.pas' {frm_toICE},
  RusClipBoard in 'RusClipBoard.pas';

{$R SendToICE.res}

begin
    if ParamCount = 0 then Exit;
    StartProgram;
end.
