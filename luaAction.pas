unit luaAction;
{$IFDEF FPS}
{$MODE Delphi}
{$ENDIF}
{$DEFINE LUA52}
{$M+}

interface

uses
  Lua, {$IFNDEF LUA52} LuaLib {$ELSE} Lua52 {$ENDIF}, main, Windows,
  Messages, SysUtils, Variants, classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Clipbrd, ShellAPI, PerlRegEx;

type
  // MyLua example class
  TLuaAction = class(TLua)
  private
    procedure RunCommand(Command: string; var slist: TStringStream); overload;
    procedure RunCommand(Command: string); overload;
  published
    // lua functions this published methods are automatically added
    // to the lua function table if called with TLua.Create(True) or Create()

    function APP_getContent(LuaState: TLuaState): Integer;
    function APP_showContent(LuaState: TLuaState): Integer;

    function APP_clearInput(LuaState: TLuaState): Integer;
    function APP_clearOutput(LuaState: TLuaState): Integer;
    function APP_execute(LuaState: TLuaState): Integer;
    function APP_mkdirs(LuaState: TLuaState): Integer;
    function APP_saveFile(LuaState: TLuaState): Integer;
    function APP_download(LuaState: TLuaState): Integer;
    function APP_md5(LuaState: TLuaState): Integer;
    function APP_md5File(LuaState: TLuaState): Integer;
    function APP_path(LuaState: TLuaState): Integer;
    function APP_httpPost(LuaState: TLuaState): Integer;
    function APP_httpGet(LuaState: TLuaState): Integer;
    function APP_regexp(LuaState: TLuaState): Integer;
    function APP_replace(LuaState: TLuaState): Integer;
    function APP_regexpList(LuaState: TLuaState): Integer;

    function testLua(LuaState: TLuaState): Integer;
    function HelloWorld(LuaState: TLuaState): Integer;
  end;

implementation

uses funs;

function TLuaAction.APP_clearInput(LuaState: TLuaState): Integer;
begin

end;

function TLuaAction.APP_clearOutput(LuaState: TLuaState): Integer;
begin
  mainFrm.content_output.clear;
end;

//
// Print out a Hello World text with all
// Arguments passed by the script and
// return some values
//
// @param      TLuaState       LuaState        The Lua Stack
// @return     integer
//
function TLuaAction.APP_download(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  srcFilename, desFilename: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  srcFilename := lua_tostring(LuaState, 1);
  desFilename := lua_tostring(LuaState, 2);

  if (srcFilename = '') or (desFilename = '') then
  begin
    application.MessageBox('网址和保存地址不可以为空', '提示');
  end
  else
  begin
    funs.DownLoadFile(srcFilename, mainFrm.apppath + 'output\' + desFilename);
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  result := 0;
end;

function TLuaAction.APP_execute(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  contentType: AnsiString;
  resultContent: AnsiString;
  cmdLine: string;
  text: AnsiString;
  return: AnsiString;
  cmsStr: TStringStream;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  text := lua_tostring(LuaState, 1);
  return := lua_tostring(LuaState, 2);
  cmdLine := TEncoding.Default.GetString(bytesof(text));

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  if return = 'continue' then
  begin
    RunCommand(cmdLine);
  end
  else
  begin
    cmsStr := TStringStream.Create;
    RunCommand(cmdLine, cmsStr);

    resultContent := TEncoding.Default.GetString(cmsStr.Bytes);

    cmsStr.Free;
  end;

  // 推送返回结果
  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));
  result := 1; // 返回值个数
end;

function TLuaAction.APP_getContent(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  contentType: AnsiString;
  // I: integer;
  txtFile: TStringList;
  resultContent: AnsiString;
  fileName: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  // writeln('Hello World from Delphi');
  // writeln('Arguments: ', ArgCount);

  // for I := 1 to ArgCount do
  // begin
  // //writeln('Arg1', I, ': ', Lua_ToInteger(LuaState, I));
  // end;

  contentType := lua_tostring(LuaState, 1);

  if contentType = 'memery' then
  begin
    if (Clipboard.HasFormat(CF_TEXT) or Clipboard.HasFormat(CF_OEMTEXT)) then
    begin
      resultContent := Clipboard.AsText;
    end;
  end
  else if copy(contentType, 1, 5) = 'param' then
  begin
    resultContent := mainFrm.getParam(strtoint(copy(contentType, 6, length(contentType)))).text;
  end
  else if contentType = 'file' then
  begin
    fileName := lua_tostring(LuaState, 2);
    resultContent := funs.ReadTextFile(fileName, '');
  end
  else
  begin
    resultContent := lua_tostring(LuaState, 2);
  end;

  // ShowMessage(content);

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  // 推送返回结果
  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));
  // Lua_PushInteger(LuaState, 102);
  result := 1; // 返回值个数
end;

function TLuaAction.APP_httpGet(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  content: AnsiString;
  url: AnsiString;
  resultContent: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 1 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  url := lua_tostring(LuaState, 1);

  resultContent := funs.httpGet(url);

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_httpPost(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  content: AnsiString;
  wText: string;
  url: AnsiString;
  resultContent: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  url := lua_tostring(LuaState, 1);
  content := lua_tostring(LuaState, 2);

  wText := TEncoding.UTF8.GetString(bytesof(UTF8Encode(content)));

  resultContent := funs.httpPost(url, wText);

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_md5(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  strContent: AnsiString;
  resultContent: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 1 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  strContent := lua_tostring(LuaState, 1);

  if (strContent = '') then
  begin
    application.MessageBox('md5的内容为空', '提示');
  end
  else
  begin
    resultContent := funs.md5(strContent)
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_md5File(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  strContent: AnsiString;
  resultContent: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 1 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  strContent := lua_tostring(LuaState, 1);

  if (strContent = '') then
  begin
    application.MessageBox('md5的内容为空', '提示');
  end
  else
  begin
    resultContent := funs.md5File(strContent)
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_mkdirs(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  path: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 1 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  path := lua_tostring(LuaState, 1);

  wText := TEncoding.Default.GetString(bytesof(path));

  ForceDirectories(wText);

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  result := 0;
end;

function TLuaAction.APP_path(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  strContent: AnsiString;
  resultContent: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 1 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  strContent := lua_tostring(LuaState, 1);

  if (strContent = '') then
  begin
    resultContent := mainFrm.apppath;
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_regexp(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  content: AnsiString;
  searchStr: AnsiString;
  replaceStr: AnsiString;
  resultContent: AnsiString;
  optionStr: AnsiString;
  optionList: TStringList;
  reg: TPerlRegEx;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 4 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  content := lua_tostring(LuaState, 1);
  searchStr := lua_tostring(LuaState, 2);
  replaceStr := lua_tostring(LuaState, 3);
  optionStr := lua_tostring(LuaState, 4);

  optionList := funs.SplitString(optionStr, ',');

  reg := TPerlRegEx.Create();

  if funs.in_strings('i', optionList) then
  begin
    reg.Options := [preCaseLess];
  end;

  if funs.in_strings('m', optionList) then
  begin
    reg.Options := [preMultiLine];
  end;

  if funs.in_strings('s', optionList) then
  begin
    reg.Options := [preSingleLine];
  end;

  optionList.Free;

  /// /

  reg.Subject := content;
  reg.RegEx := searchStr;
  reg.Replacement := replaceStr;
  reg.ReplaceAll;

  resultContent := reg.Subject;

  FreeAndNil(reg);
  ///

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_regexpList(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  regStr: AnsiString;
  content: AnsiString;
  showStr: AnsiString;
  newLine: AnsiString;
  resultContent: AnsiString;
  reg: TPerlRegEx;
  i: Integer;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 3 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  regStr := lua_tostring(LuaState, 1);
  content := lua_tostring(LuaState, 2);
  showStr := lua_tostring(LuaState, 3);

  resultContent := '';

  /// /
  reg := TPerlRegEx.Create();
  reg.Subject := content;
  reg.RegEx := regStr;
  while reg.MatchAgain do
  begin
    newLine := showStr;

    // newLine := StringReplace(newLine, '$0', reg.MatchedText, [rfReplaceAll, rfIgnoreCase]);

    for i := 0 to reg.GroupCount + 1 do
    begin
      newLine := StringReplace(newLine, '$' + IntToStr(i), reg.Groups[i],
        [rfReplaceAll, rfIgnoreCase]);
    end;
    resultContent := resultContent + newLine;
  end;

  FreeAndNil(reg);
  ///

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_replace(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  content: AnsiString;
  searchStr: AnsiString;
  replaceStr: AnsiString;
  resultContent: AnsiString;
  reg: TPerlRegEx;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 3 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  content := lua_tostring(LuaState, 1);
  searchStr := lua_tostring(LuaState, 2);
  replaceStr := lua_tostring(LuaState, 3);

  /// /
  resultContent := StringReplace(content, searchStr, replaceStr,
    [rfReplaceAll, rfIgnoreCase]);
  ///

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  lua_pushlstring(LuaState, PAnsiChar(resultContent), length(resultContent));

  result := 1;
end;

function TLuaAction.APP_saveFile(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  // wText: string;
  fileName: AnsiString;
  byte: TBytes;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  fileName := lua_tostring(LuaState, 1);
  text := lua_tostring(LuaState, 2);

  byte := TEncoding.GetEncoding(936).GetBytes(PAnsiChar(text));
  byte := TEncoding.UTF8.Convert(TEncoding.GetEncoding(936), TEncoding.UTF8,
    byte);

  // wText := TEncoding.UTF8.GetString(byte);

  if fileName = '' then
  begin
    application.MessageBox('文件名不可以为空', '提示');
  end
  else
  begin
    funs.WriteTextFile(mainFrm.apppath + 'output\' + fileName, byte);
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  result := 0;
end;

function TLuaAction.APP_showContent(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  text: AnsiString;
  wText: string;
  contentType: AnsiString;
begin
  ArgCount := Lua_GetTop(LuaState);
  if ArgCount <> 2 then
  begin
    Lua_Pop(LuaState, Lua_GetTop(LuaState));
    lua_pushstring(LuaState, '');
    exit;
  end;

  Lua_GetTop(LuaState);

  contentType := lua_tostring(LuaState, 1);
  text := lua_tostring(LuaState, 2);

  wText := TEncoding.Default.GetString(bytesof(text));

  if contentType = 'memery' then
  begin

    Clipboard.SetTextBuf(PWideChar(wText));
  end
  else
  begin
    // output
    mainFrm.content_output.Lines.Add(wText);
  end;

  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  result := 0;
end;

function TLuaAction.HelloWorld(LuaState: TLuaState): Integer;
var
  ArgCount: Integer;
  i: Integer;
begin
  ArgCount := Lua_GetTop(LuaState);

  writeln('Hello World from Delphi');
  writeln('Arguments: ', ArgCount);

  for i := 1 to ArgCount do
    writeln('Arg1', i, ': ', Lua_ToInteger(LuaState, i));

  // Clear stack
  Lua_Pop(LuaState, Lua_GetTop(LuaState));

  // Push return values
  Lua_PushInteger(LuaState, 101);
  Lua_PushInteger(LuaState, 102);
  result := 2;
end;

procedure TLuaAction.RunCommand(Command: string; var slist: TStringStream);
var
  hReadPipe: THandle;
  hWritePipe: THandle;
  SI: TStartUpInfo;
  PI: TProcessInformation;
  SA: TSecurityAttributes;
  BytesRead: DWORD;
  Avail, ExitCode, wrResult: DWORD;
  Dest: array [0 .. 1023] of Char;
  cmdLine: array [0 .. 1023] of Char;
  // TmpList: TStringStream;
  osVer: TOSVERSIONINFO;
  tmpstr: AnsiString;
begin
  osVer.dwOSVersionInfoSize := Sizeof(TOSVERSIONINFO);
  GetVersionEX(osVer);
  if osVer.dwPlatformId = VER_PLATFORM_WIN32_NT then
  begin
    SA.nLength := Sizeof(SA);
    SA.lpSecurityDescriptor := nil; // @SD;
    SA.bInheritHandle := True;
    CreatePipe(hReadPipe, hWritePipe, @SA, 0);
  end
  else
  begin
    CreatePipe(hReadPipe, hWritePipe, nil, 1024);
  end;
  try
    Screen.Cursor := crHourglass;
    FillChar(SI, Sizeof(SI), 0);
    SI.cb := Sizeof(TStartUpInfo);
    SI.wShowWindow := SW_HIDE;
    SI.dwFlags := STARTF_USESHOWWINDOW;
    SI.dwFlags := SI.dwFlags or STARTF_USESTDHANDLES;
    SI.hStdOutput := hWritePipe;
    SI.hStdError := hWritePipe;
    StrPCopy(cmdLine, Command);
    if CreateProcess(nil, cmdLine, nil, nil, True, NORMAL_PRIORITY_CLASS, nil,
      nil, SI, PI) then
    begin
      ExitCode := 0;
      while ExitCode = 0 do
      begin
        wrResult := WaitForSingleObject(PI.hProcess, 100);
        if PeekNamedPipe(hReadPipe, @Dest[0], 1024, @Avail, nil, nil) then
        begin
          if Avail > 0 then
          begin
            // TmpList := TStringList.Create;
            try
              FillChar(Dest, Sizeof(Dest), 0);
              ReadFile(hReadPipe, Dest[0], Avail, BytesRead, nil);
              slist.Write(Dest[0], BytesRead);
              // TmpStr := Copy(Dest, 0, BytesRead-1);
              // Output.Read(Dest, BytesRead-1);
              // TmpList.Text := TmpStr;
              // Output.AddStrings(TmpList);
            finally
              // TmpList.Free;
            end;
          end;
        end;
        if wrResult <> WAIT_TIMEOUT then
        begin
          ExitCode := 1;
        end;
      end;
      GetExitCodeProcess(PI.hProcess, ExitCode);
      CloseHandle(PI.hProcess);
      CloseHandle(PI.hThread);
    end;
  finally
    CloseHandle(hReadPipe);
    CloseHandle(hWritePipe);
    Screen.Cursor := crDefault;
  end;
end;

procedure TLuaAction.RunCommand(Command: string);
begin
  ShellExecute(mainFrm.Handle, 'Open', PChar(Command), nil, nil, SW_SHOWNORMAL);
end;

function TLuaAction.testLua(LuaState: TLuaState): Integer;
begin
  mainFrm.content_output.Lines.Add('test...');
end;

end.
