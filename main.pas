{$I var.txt}
unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Menus, setting, Lua, LuaLib, codeEdit,
  PHPCommon, php4delphi;

type
  TMainFrm = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Splitter2: TSplitter;
    scriptList: TListBox;
    editMenu: TPopupMenu;
    N1: TMenuItem;
    paramBox: TScrollBox;
    content_output: TMemo;
    Panel3: TPanel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure scriptListClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    editList: array of TcodeEditFrm;
  public
    dtFormat: TFormatSettings;
    apppath: string;
    OwnOption: TOptions;
    RequestID: integer;

    PEngine: TPHPEngine;

    procedure readScript(content: string; stype: string);
    procedure readPhpScript(content: string);
    procedure readLuaScript(content: string);

    procedure runScript(content: string; stype: string);
    procedure runPhpScript(content: string);
    procedure runLuaScript(content: string);
    function getParam(idx: integer): TMemo;
    { Public declarations }
  end;

var
  MainFrm: TMainFrm;

implementation

uses funs, lua52, luaAction;
{$R *.dfm}

procedure TMainFrm.Button1Click(Sender: TObject);
var
  content: string;
  fileInfo: TstringList;
  stype: string;
  filename: string;
begin
  if scriptList.ItemIndex < 0 then
  begin
    application.MessageBox('没有选择脚本', '提示');
    exit;
  end;

  filename := scriptList.Items[scriptList.ItemIndex];
  if copy(filename,0,5) = '<lua>' then
  begin
    filename := copy(filename,6,length(filename)) + '.lua';
    stype := 'lua';
  end
  else if copy(filename,0,5) = '<php>' then
  begin
    filename := copy(filename,6,length(filename)) + '.php';
    stype := 'php';
  end;

  //
  fileInfo := TstringList.Create();
  fileInfo.LoadFromFile(apppath + 'script\' + filename);
  content := fileInfo.Text;
  fileInfo.Free;

  runScript(content, stype);
end;

procedure TMainFrm.FormCreate(Sender: TObject);
var
  fileList: TstringList;
  i: integer;
begin
  // 设置字体
  MainFrm.Font.Name := '宋体';
  MainFrm.Font.Size := 9;

  Self.DoubleBuffered := true;

  // 程序路径
  apppath := ExtractFilePath(application.ExeName);

  // 初始化时间格式
  dtFormat.ShortDateFormat := 'yyyy-mm-dd';
  dtFormat.LongDateFormat := 'yyyy-mm-dd hh:nn:ss';
  dtFormat.LongTimeFormat := 'hh:mm:ss.zzz';
  dtFormat.DateSeparator := '-';
  dtFormat.TimeSeparator := ':';

  // php路径
  PEngine := TPHPEngine.Create(self);
  PEngine.DLLFolder := apppath + 'php\';
  PEngine.IniPath := apppath + 'php\php.ini';
  PEngine.StartupEngine;

  // 读取lua脚本
  fileList := funs.GetDirFileName(apppath + 'script', '*.lua');
  for i := 0 to fileList.Count - 1 do
  begin
    scriptList.Items.Add('<lua>' + ExtractFileName(Copy(fileList[i], 0, Length(fileList[i]) - 4)));
  end;
  fileList.Free;

  // 读取php脚本
  fileList := funs.GetDirFileName(apppath + 'script', '*.php');
  for i := 0 to fileList.Count - 1 do
  begin
    scriptList.Items.Add('<php>' + ExtractFileName(Copy(fileList[i], 0, Length(fileList[i]) - 4)));
  end;
  fileList.Free;
end;

procedure TMainFrm.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  for i := 0 to Length(editList) - 1 do
  begin
    if editList[i] <> nil then
    begin
      editList[i].Free;
    end;
  end;

  PEngine.ShutdownAndWaitFor;
  PEngine.Free;
end;

function TMainFrm.getParam(idx: integer): TMemo;
var
  i: integer;
begin
  for i := 0 to paramBox.ControlCount - 1 do
  begin
    if paramBox.Controls[i].Tag = idx then
    begin
      result := TMemo(paramBox.Controls[i]);
      break;
    end;
  end;

end;

procedure TMainFrm.N1Click(Sender: TObject);
var
  filename: string;
begin
  if scriptList.ItemIndex < 0 then
  begin
    application.MessageBox('没有选择脚本', '提示');
    exit;
  end;

  filename := scriptList.Items[scriptList.ItemIndex];
  if copy(filename,0,5) = '<lua>' then
  begin
    filename := copy(filename,6,length(filename)) + '.lua';
  end
  else if copy(filename,0,5) = '<php>' then
  begin
    filename := copy(filename,6,length(filename)) + '.php';
  end;

  filename := apppath + 'script\' +filename;

  setlength(editList, Length(editList) + 1);
  editList[Length(editList) - 1] := TcodeEditFrm.Create(filename);
  editList[Length(editList) - 1].Show;
end;

procedure TMainFrm.readScript(content: string; stype: string);
begin
  if stype = 'lua' then
  begin
    readLuaScript(content);
  end
  else if stype = 'php' then
  begin
    readPhpScript(content);
  end;
end;

procedure TMainFrm.readLuaScript(content: string);
var
  slist: TstringList;
  i: integer;
  lineStr: string;
  sedit: TMemo;
  stitle: TLabel;
  idx, memoIdx: integer;
begin
  while paramBox.ControlCount > 0 do
  begin
    paramBox.Controls[0].Free;
  end;

  memoIdx := 1;

  // content := TEncoding.UTF8.GetString(bytesof(content));
  slist := funs.SplitString(content, #13#10);
  for i := 0 to slist.Count - 1 do
  begin
    lineStr := trim(slist[i]);
    if Copy(lineStr, 0, 10) = '--- param ' then
    begin
      idx := paramBox.ControlCount;
      // content_output.Lines.Add(copy(lineStr, 11, length(lineStr)));
      stitle := TLabel.Create(paramBox);
      stitle.Parent := paramBox;
      stitle.Caption := Copy(lineStr, 11, Length(lineStr)) + '：';
      stitle.Left := 8;
      stitle.top := (46 * idx) + 8;
      stitle.Show;

      sedit := TMemo.Create(paramBox);
      sedit.ScrollBars := ssVertical;
      sedit.Parent := paramBox;
      sedit.Anchors := [akLeft, akTop, akRight];
      sedit.Left := 8;
      sedit.top := (46 * idx) + 30;
      sedit.Width := paramBox.Width - 16 - 20;
      sedit.Height := 60;
      sedit.Tag := memoIdx;
      sedit.Show;

      inc(memoIdx);
    end;

  end;
  slist.Free;
end;

procedure TMainFrm.readPhpScript(content: string);
var
  slist: TstringList;
  i: integer;
  lineStr: string;
  sedit: TMemo;
  stitle: TLabel;
  idx, memoIdx: integer;
begin
  while paramBox.ControlCount > 0 do
  begin
    paramBox.Controls[0].Free;
  end;

  memoIdx := 1;

  // content := TEncoding.UTF8.GetString(bytesof(content));
  slist := funs.SplitString(content, #13#10);
  for i := 0 to slist.Count - 1 do
  begin
    lineStr := trim(slist[i]);
    if Copy(lineStr, 0, 10) = '/// param ' then
    begin
      idx := paramBox.ControlCount;
      // content_output.Lines.Add(copy(lineStr, 11, length(lineStr)));
      stitle := TLabel.Create(paramBox);
      stitle.Parent := paramBox;
      stitle.Caption := Copy(lineStr, 11, Length(lineStr)) + '：';
      stitle.Left := 8;
      stitle.top := (46 * idx) + 8;
      stitle.Show;

      sedit := TMemo.Create(paramBox);
      sedit.ScrollBars := ssVertical;
      sedit.Parent := paramBox;
      sedit.Name := 'param'+inttostr(memoIdx);
      sedit.Text := '';
      sedit.Anchors := [akLeft, akTop, akRight];
      sedit.Left := 8;
      sedit.top := (46 * idx) + 30;
      sedit.Width := paramBox.Width - 16 - 20;
      sedit.Height := 60;
      sedit.Tag := memoIdx;
      sedit.Show;

      inc(memoIdx);
    end;

  end;
  slist.Free;
end;

procedure TMainFrm.runScript(content: string; stype: string);
begin
  if stype = 'lua' then
  begin
    runLuaScript(content);
  end
  else if stype = 'php' then
  begin
    runPhpScript(content);
  end;
end;

procedure TMainFrm.runLuaScript(content: string);
var
  alua: TLua;
  errMsg: string;
begin
  try
    alua := TLuaAction.Create;
    errMsg := alua.DoString(content);
    if errMsg <> '' then
    begin
      content_output.Lines.Add(errMsg);
    end;
    alua.Free;
  except
    on E: Exception do
    begin
      content_output.Lines.Add(E.ClassName + ': ' + E.Message);
    end;
  end;
end;

procedure TMainFrm.runPhpScript(content: string);
var
  Doc: AnsiString;

  php: TpsvPHP;
  i: integer;
  idx: integer;
  memo: Tmemo;
  bs : TBytes;
begin
  content_output.Clear;

  php := TpsvPHP.Create(self);

  idx := 0;

  for i := 0 to paramBox.ControlCount - 1 do
  begin
    if paramBox.Controls[i].Tag > 0 then
    begin
      memo := TMemo(paramBox.Controls[i]);

      php.Variables.Add;
      php.Variables.Items[idx].Name := 'param'+inttostr(idx+1);
      php.Variables.Items[idx].Value := utf8encode(memo.Text);
      inc(idx);
    end;
  end;

  Doc := php.RunCode(content);

  bs := tencoding.UTF8.GetBytes(Doc);
  bs := tencoding.Convert(tencoding.UTF8, tencoding.GetEncoding(936), bs);

  content_output.Lines.Add(tencoding.GetEncoding(936).GetString(bs));
  php.Free;
end;

procedure TMainFrm.scriptListClick(Sender: TObject);
var
  content: string;
  fileInfo: TstringList;
  filename: string;
  stype: string;
begin
  if scriptList.ItemIndex < 0 then
  begin
    application.MessageBox('没有选择脚本', '提示');
    exit;
  end;

  filename := scriptList.Items[scriptList.ItemIndex];
  if copy(filename,0,5) = '<lua>' then
  begin
    filename := copy(filename,6,length(filename)) + '.lua';
    stype := 'lua';
  end
  else if copy(filename,0,5) = '<php>' then
  begin
    filename := copy(filename,6,length(filename)) + '.php';
    stype := 'php';
  end;

  //
  fileInfo := TstringList.Create();
  fileInfo.LoadFromFile(apppath + 'script\' + filename);
  content := fileInfo.Text;
  fileInfo.Free;

  readScript(content, stype);
end;

end.
