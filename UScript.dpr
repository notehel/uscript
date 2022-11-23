{$I var.txt}
program UScript;

// {$IFDEF _DEBUGVERSION}
// FastMM4 in 'lib\fastmm\FastMM4.pas',
// FastMM4Messages in 'lib\fastmm\FastMM4Messages.pas',
// {$ENDIF}
uses
  Forms,
  DScintilla in '..\makecode\lib\scintilla\DScintilla.pas',
  DScintillaUtils in '..\makecode\lib\scintilla\DScintillaUtils.pas',
  DScintillaCustom in '..\makecode\lib\scintilla\DScintillaCustom.pas',
  DScintillaTypes in '..\makecode\lib\scintilla\DScintillaTypes.pas',
  Lua in '..\makecode\lib\lua\Lua.pas',
  LuaLib in '..\makecode\lib\lua\LuaLib.pas',
  lua52 in '..\makecode\lib\lua\lua52.pas',
  funs in '..\makecode\lib\funs.pas',
  pcre in '..\makecode\lib\pcre\pcre.pas',
  uLkJSON in '..\makecode\lib\uLkJSON.pas',
  PerlRegEx in '..\makecode\lib\pcre\PerlRegEx.pas',
  main in '..\makecode\main.pas',
  luaAction in '..\makecode\luaAction.pas',
  setting in '..\makecode\setting.pas',
  codeEdit in '..\makecode\codeEdit.pas' { codeEditFrm };

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'сп╫е╠╬';
  Application.CreateForm(TMainFrm, MainFrm);
  Application.Run;

end.
