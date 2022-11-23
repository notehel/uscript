{$I var.txt}
unit funs;

interface

uses
  winsock, Windows, SysUtils, Classes, Graphics, Types, Math, IniFiles, Forms,
  main, UrlMon, StdCtrls, Wininet, DateUtils, perlregex, comobj, activex, shlobj,
  ShellAPI, IdHashMessageDigest, IdGlobal, IdHash, dialogs, setting, OverbyteIcsWndControl, OverbyteIcsHttpProt;

type
  TLANGANDCODEPAGE = record
    wLanguage, wCodePage: Word;
  end;

  PLANGANDCODEPAGE = ^TLANGANDCODEPAGE;

function in_strings(val: string; arr: TstringList): boolean;

function set_date(val: string): string;

function ValidatePID(const APID: string): string;

function isDate(str: string): Boolean;

function IsIntHave(int1, intbegin, intend: integer): boolean;

function implode(str: string; list: TStringList): string;

procedure writeFile(filename, content, action: string);

function getUnion(one, two: TStringList): TStringList;

function getMonths(beginTime, endTime: integer): integer;

function formatDateByMonth(months: integer): string;

function formatDateByInt(adate: string): string;

function selectIndex(key: string; list: Tstrings): integer;

procedure QSort(var A: array of Integer);

function GetDirFileName(Dir, ExtName: string): TStringList;

function getFileVersionX(FileName: string): string;

function isInteger(intx: string): boolean;

function DeletePath(mDirName: string): Boolean;

function DownLoadFile(url: string; desc: string): boolean;

function GetFileSize(filename: string): int64;

function Escape(const StrToEscape: WideString): string;

function Unescape(const StrEscaped: string): WideString;

function jscode(Str: string): string;

function showAttach(Str: string): string;

function GetFileVersion(fn: string; var ma, mi, r, b: integer): boolean; //得到本程序的版本号
//获取unix时间戳

function GetUnixTime(atime: TDateTime): integer;

function SplitString(const Source, ch: string): TStringList;

function HTML2TColor(html: string): TColor;

function Color2Html(DColor: TColor): string;

function GetRandomString(len: integer): string;

function GetFileIcon(FileName: string; var DocType: string): TIcon;

function LinkFileInfo(const lnkFileName: string; var info: LINK_FILE_INFO; const bSet: boolean): boolean;

function formatDate(const Format: string; DateTime: TDateTime): string;

function md5(str: string): string;

function md5File(str: string): string;

function ReadTextFile(filename: string; encode: string): AnsiString;

function WriteTextFile(filename: string; buff: TBytes): AnsiString;

function httpPost(url: string; params: string): UTF8String;

function httpGet(url: string): UTF8String;

implementation

function httpGet(url: string): UTF8String;
var
  htpcli: THttpCli;
begin
  htpcli := THttpCli.Create(nil);
  htpcli.Agent := 'Mozilla/5.0 (Windows; U; Windows NT 5.2; zh-CN; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8';
  htpcli.Accept := 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
  htpcli.NoCache := True;
  htpcli.MultiThreaded := False;
  htpcli.RequestVer := '1.1';
  htpcli.FollowRelocation := false;
  htpcli.Timeout := 10;
  htpcli.URL := url;
  htpcli.RcvdStream := TMemoryStream.Create;

  try
    htpcli.Get;

    if (htpcli.StatusCode = 200) then
    begin
      htpcli.RcvdStream.Seek(0, 0);
      SetLength(result, htpcli.RcvdStream.Size);
      htpcli.RcvdStream.Read(result[1], htpcli.RcvdStream.Size);

    end;

    htpcli.RcvdStream.Free;
    htpcli.RcvdStream := nil;
    htpcli.Close;
  except
    //
  end;

  htpcli.Free;
end;

function httpPost(url: string; params: string): UTF8String;
var
  htpcli: THttpCli;
begin
  htpcli := THttpCli.Create(nil);
  htpcli.Agent := 'Mozilla/5.0 (Windows; U; Windows NT 5.2; zh-CN; rv:1.9.2.8) Gecko/20100722 Firefox/3.6.8';
  htpcli.Accept := 'image/gif, image/x-xbitmap, image/jpeg, image/pjpeg, */*';
  htpcli.NoCache := True;
  htpcli.MultiThreaded := False;
  htpcli.RequestVer := '1.1';
  htpcli.FollowRelocation := false;
  htpcli.Timeout := 10;
  htpcli.URL := url;
  htpcli.SendStream := TStringStream.Create(params,TEncoding.UTF8,true);
  htpcli.RcvdStream := TMemoryStream.Create;

  try
    htpcli.Post;

    if (htpcli.StatusCode = 200) then
    begin
      htpcli.RcvdStream.Seek(0, 0);
      SetLength(result, htpcli.RcvdStream.Size);
      htpcli.RcvdStream.Read(result[1], htpcli.RcvdStream.Size);

    end;

    htpcli.SendStream.Free;
    htpcli.SendStream := nil;

    htpcli.RcvdStream.Free;
    htpcli.RcvdStream := nil;
    htpcli.Close;
  except
    //
  end;

  htpcli.Free;
end;

function WriteTextFile(filename: string; buff: TBytes): AnsiString;
var
  files: Tfilestream;
begin
  if FileExists(filename) then
  begin
    files := TFileStream.Create(filename, fmOpenWrite);
  end
  else
  begin
    files := TFileStream.Create(filename, fmCreate);
  end;

  files.Write(buff[0], Length(buff));
  files.Free;
end;

function ReadTextFile(filename: string; encode: string): AnsiString;
var
  stream: TMemoryStream;
  Byte: TBytes;
begin
  stream := TMemoryStream.Create();
  stream.LoadFromFile(filename);
  SetLength(Byte, stream.Size);
  stream.Read(Byte[0], stream.Size);
  Byte := TEncoding.Convert(TEncoding.UTF8, TEncoding.GetEncoding(936), Byte);
  result := TEncoding.GetEncoding(936).GetString(Byte);
  stream.Free;
end;

function md5(str: string): string;
var
  Md5Encode: TIdHashMessageDigest5;
begin
  Md5Encode := TIdHashMessageDigest5.Create;
  try
    //Result := Md5Encode.AsHex(Md5Encode.HashValue(S)); // Indy9的写法
    Result := LowerCase(Md5Encode.HashStringAsHex(str));    // Indy10中可以直接HashStringAsHex
  finally
    Md5Encode.Free;
  end;
end;

function md5File(str: string): string;
var
  Md5Encode: TIdHashMessageDigest5;
  stream: TFileStream;
begin
  Md5Encode := TIdHashMessageDigest5.Create;
  try
    //Result := Md5Encode.AsHex(Md5Encode.HashValue(S)); // Indy9的写法
    stream := TFileStream.Create(str, fmOpenRead);
    Result := LowerCase(Md5Encode.HashStreamAsHex(stream));
  finally
    Md5Encode.Free;
    stream.Free;
  end;
end;

function formatDate(const Format: string; DateTime: TDateTime): string;
begin
  Result := FormatDateTime(Format, DateTime, MainFrm.dtFormat);
end;

function LinkFileInfo(const lnkFileName: string; var info: LINK_FILE_INFO; const bSet: boolean): boolean;
var
  hr: hresult;
  psl: IShelllink;
  wfd: win32_find_data;
  ppf: IPersistFile;
  lpw: pwidechar;
  buf: pwidechar;
begin
  result := false;
  getmem(buf, MAX_PATH);
  try
    if SUCCEEDED(CoInitialize(nil)) then
      if (succeeded(cocreateinstance(clsid_shelllink, nil, clsctx_inproc_server, IID_IShellLinkA, psl))) then
      begin
        hr := psl.QueryInterface(iPersistFile, ppf);
        if succeeded(hr) then
        begin
          lpw := stringtowidechar(lnkFileName, buf, MAX_PATH);
          hr := ppf.Load(lpw, STGM_READ);
          if succeeded(hr) then
          begin
            hr := psl.Resolve(0, SLR_NO_UI);
            if succeeded(hr) then
            begin
              if bSet then
              begin
                psl.SetArguments(info.Arguments);
                psl.SetDescription(info.Description);
                psl.SetHotkey(info.HotKey);
                psl.SetIconLocation(info.IconLocation, info.IconIndex);
                psl.SetIDList(info.ItemIDList);
                psl.SetPath(info.FileName);
                psl.SetShowCmd(info.ShowState);
                psl.SetRelativePath(info.RelativePath, 0);
                psl.SetWorkingDirectory(info.WorkDirectory);
                result := succeeded(psl.Resolve(0, SLR_UPDATE));
              end
              else
              begin
                psl.GetPath(info.FileName, MAX_PATH, wfd, SLGP_SHORTPATH);
                psl.GetIconLocation(info.IconLocation, MAX_PATH, info.IconIndex);
                psl.GetWorkingDirectory(info.WorkDirectory, MAX_PATH);
                psl.GetDescription(info.Description, CCH_MAXNAME);
                psl.GetArguments(info.Arguments, MAX_PATH);
                psl.GetHotkey(info.HotKey);
                psl.GetIDList(info.ItemIDList);
                psl.GetShowCmd(info.ShowState);
                result := true;
              end;
            end;
          end;
        end;
      end;
  finally
    freemem(buf);
  end;
end;

function GetFileIcon(FileName: string; var DocType: string): TIcon;
var
  Info: SHFILEINFO;
begin
  FillChar(Info, SizeOf(Info), 0);
  Result := TIcon.Create;
  Result.Transparent := true;
  SHGetFileInfo(PChar(FileName), 0, Info, SizeOf(Info), SHGFI_ICON or SHGFI_TYPENAME or SHGFI_DISPLAYNAME);
  DocType := Info.szTypeName;
  Result.Handle := Info.hIcon;
end;

function showAttach(Str: string): string;
var
  regex: tperlregex;
begin
  regex := TPerlRegEx.Create;
  regex.Options := [preMultiLine, preCaseLess];

  regex.Subject := Str;

  regex.RegEx := '\[attachment=([\d]*)\]';
  regex.Replacement := 'note://local/attachment/$1';
  regex.ReplaceAll;

  Result := regex.Subject;

  FreeAndNil(regex);
end;

function GetRandomString(len: integer): string;
var
  I, idx: integer;
  Str: string;
  outstr: string;
begin
  I := 0;
  outstr := '';
  Str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  while Length(Trim(outstr)) < len do
  begin
    Randomize;
    idx := random(Length(Str) - 1) + 1;
    outstr := outstr + Str[idx];
    Inc(I);
  end;
  result := outstr;
end;

//读取文件

function ReadFile(filename: string): string;
var
  txtlist: TStringList;
begin
  txtlist := TStringList.create;
  txtlist.LoadFromFile(filename);
  result := txtlist.Text;
  txtlist.Destroy;
end;

//文本转化为html

function Text2Html(content: string): string;
begin
  content := stringreplace(content, '<', '&lt;', [rfreplaceall, rfignorecase]);
  content := stringreplace(content, '>', '&gt;', [rfreplaceall, rfignorecase]);
  content := stringreplace(content, ' ', '&nbsp;', [rfreplaceall, rfignorecase]);
  content := stringreplace(content, #13, '<br />', [rfreplaceall, rfignorecase]);
  content := stringreplace(content, #10, '', [rfreplaceall, rfignorecase]);
  result := content;
end;

function HTML2TColor(html: string): TColor;
begin
  //#889977
  Result := RGB(StrToIntDef('$' + copy(html, 2, 2), 0), StrToIntDef('$' + copy(html, 4, 2), 0), StrToIntDef('$' + copy(html, 6, 2), 0));
end;

function Color2Html(DColor: TColor): string;
var
  tmpRGB: TColorRef;
begin
  tmpRGB := ColorToRGB(DColor);
  Result := Format('#%.2x%.2x%.2x', [GetRValue(tmpRGB), GetGValue(tmpRGB), GetBValue(tmpRGB)]);
end;

function jscode(Str: string): string;
begin
  Result := StringReplace(Str, '\', '\\', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, '''', '\''', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, #13, '\n\r', [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, #10, '', [rfReplaceAll, rfIgnoreCase]);

end;

function Escape(const StrToEscape: WideString): string;
var
  i: Integer;
  w: Word;
begin
  Result := '';

  for i := 1 to Length(StrToEscape) do
  begin
    w := Word(StrToEscape[i]);

    if w in [Ord('0')..Ord('9'), Ord('A')..Ord('Z'), Ord('a')..Ord('z')] then
      Result := Result + Char(w)
    else if w <= 255 then
      Result := Result + '%' + IntToHex(w, 2)
    else
      Result := Result + '%u' + IntToHex(w, 4);
  end;
end;

function Unescape(const StrEscaped: string): WideString;

  function UnescapeUncodeChar(const s: string): WideChar;
  var
    r: array[0..1] of Byte;
  begin
    HexToBin(PChar(LowerCase(s)), @r, SizeOf(r));
    Result := WideChar((r[0] shl 8) or r[1]);
  end;

  function UnescapeAnsiChar(const s: string): Char;
  begin
    HexToBin(PChar(LowerCase(s)), @Result, SizeOf(Result));
  end;

var
  i: Integer;
  c: Integer;
begin
  c := 1;
  SetLength(Result, Length(StrEscaped));

  i := 1;
  while i <= Length(StrEscaped) do
  begin
    if StrEscaped[i] = '%' then
    begin
      if (i < Length(StrEscaped)) and (StrEscaped[i + 1] = 'u') then
      begin
        Result[c] := UnescapeUncodeChar(Copy(StrEscaped, i + 2, 4)); //Do with '%uxxxx'
        Inc(i, 6);
      end
      else
      begin
        Result[c] := WideChar(UnescapeAnsiChar(Copy(StrEscaped, i + 1, 2))); //Do with '%xx'
        Inc(i, 3);
      end;
    end
    else
    begin
      Result[c] := WideChar(StrEscaped[i]);

      Inc(i);
    end;

    Inc(c);
  end;

  SetLength(Result, c - 1);
end;

function CharToInt(C: char): Integer;
begin
  if Ord((C)) >= 65 then
    Result := 10 + Ord(C) - 65
  else
    Result := Ord(C) - 48;
end;

function HexToInt(Str: string): longint;
var
  I: Integer;
  p1: array[0..1] of Char;
begin
  Result := 0;
  Str := Trim(Str);
  for I := 1 to length(Str) do
  begin
    StrPcopy(p1, Copy(Str, I, 1));
    Result := Result * 16 + CharToInt(p1[0]);
  end;
end;

function in_strings(val: string; arr: TstringList): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to arr.Count - 1 do
  begin
    if arr[i] = val then
    begin
      Result := true;
      break;
    end;
  end;
end;

function set_date(val: string): string;
var
  year, month: string;
begin
  if Length(val) <> 6 then
  begin
    result := '';
  end
  else
  begin
    year := Copy(val, 1, 4);
    month := Copy(val, 5, 2);
    if Length(month) = 1 then
    begin
      month := '0' + month;
    end;
  end;
  result := year + month;
end;

function ValidatePID(const APID: string): string;
{内部函数,取身份证号校验位,最后一位,对18位有效}

  function GetVerifyBit(sIdentityNum: string): Char;
  var
    nNum: Integer;
  begin
    Result := #0;
    nNum := StrToInt(sIdentityNum[1]) * 7 + StrToInt(sIdentityNum[2]) * 9 + StrToInt(sIdentityNum[3]) * 10 + StrToInt(sIdentityNum[4]) * 5 + StrToInt(sIdentityNum[5]) * 8 + StrToInt(sIdentityNum[6]) * 4 + StrToInt(sIdentityNum[7]) * 2 + StrToInt(sIdentityNum[8]) * 1 + StrToInt(sIdentityNum[9]) * 6 + StrToInt(sIdentityNum[10]) * 3 + StrToInt(sIdentityNum[11]) * 7 + StrToInt(sIdentityNum[12]) * 9 + StrToInt(sIdentityNum[13]) * 10 + StrToInt(sIdentityNum[14]) * 5 + StrToInt(sIdentityNum[15]) * 8 + StrToInt(sIdentityNum[16]) * 4 + StrToInt(sIdentityNum[17]) * 2;
    nNum := nNum mod 11;
    case nNum of
      0:
        Result := '1';
      1:
        Result := '0';
      2:
        Result := 'x';
      3:
        Result := '9';
      4:
        Result := '8';
      5:
        Result := '7';
      6:
        Result := '6';
      7:
        Result := '5';
      8:
        Result := '4';
      9:
        Result := '3';
      10:
        Result := '2';
    end;
  end;

var
  L: Integer;
  sCentury: string;
  sYear2Bit: string;
  sMonth: string;
  sDate: string;
  iCentury: Integer;
  iMonth: Integer;
  iDate: Integer;
  CRCFact: string; //18位证号的实际值
  CRCTh: string; //18位证号的理论值
  FebDayAmt: Byte; //2月天数
begin
  L := Length(APID);
  if (L in [15, 18]) = False then
  begin
    Result := Format('身份证号不是15位或18位(%0:s, 实际位数:%1:d)', [APID, L]);
    Exit;
  end;
  CRCFact := '';
  if L = 18 then
  begin
    sCentury := Copy(APID, 7, 2);
    iCentury := StrToInt(sCentury);
    if (iCentury in [18..20]) = False then
    begin
      Result := Format('身份证号码无效:18位证号的年份前两位必须在18-20之间(%0:S)', [sCentury]);
      Exit;
    end;
    sYear2Bit := Copy(APID, 9, 2);
    sMonth := Copy(APID, 11, 2);
    sDate := Copy(APID, 13, 2);
    CRCFact := Copy(APID, 18, 1);
  end
  else
  begin
    sCentury := '19';
    sYear2Bit := Copy(APID, 7, 2);
    sMonth := Copy(APID, 9, 2);
    sDate := Copy(APID, 11, 2);
  end;
  iMonth := StrToInt(sMonth);
  iDate := StrToInt(sDate);
  if (iMonth in [01..12]) = False then
  begin
    Result := Format('身份证号码无效:月份必须在01-12之间(%0:s)', [sMonth]);
    Exit;
  end;
  if (iMonth in [1, 3, 5, 7, 8, 10, 12]) then
  begin
    if (iDate in [01..31]) = False then
    begin
      Result := Format('身份证号码无效:日期无效,不能为零或超出当月最大值(%0:s)', [sDate]);
      Exit;
    end;
  end;
  if (iMonth in [4, 6, 9, 11]) then
  begin
    if (iDate in [01..30]) = False then
    begin
      Result := Format('身份证号码无效:日期无效,不能为零或超出当月最大值(%0:s)', [sDate]);
      Exit;
    end;
  end;
  if IsLeapYear(StrToInt(sCentury + sYear2Bit)) = True then
  begin
    FebDayAmt := 29;
  end
  else
  begin
    FebDayAmt := 28;
  end;
  if (iMonth in [2]) then
  begin
    if (iDate in [01..FebDayAmt]) = False then
    begin
      Result := Format('身份证号码无效:日期无效,不能为零或超出当月最大值(%0:s)', [sDate]);
      Exit;
    end;
  end;
  if CRCFact <> '' then
  begin
    CRCTh := GetVerifyBit(APID);
    if CRCFact <> CRCTh then
    begin
      Result := Format('身份证号码无效:校验位(第18位)错:(%0:s)', [APID]);
      Exit;
    end;
  end;
end;

function isDate(str: string): Boolean;
var
  Adate: TdateTime;
begin
  Result := false;
  if tryStrToDateTime(str, Adate, MainFrm.dtFormat) then
  begin
    Result := true;
  end;
end;

//判断一个数字是否再另两个数字的中间

function IsIntHave(int1, intbegin, intend: integer): boolean;
begin
  result := false;
  if (int1 >= intbegin) and (int1 <= intend) then
  begin
    result := true;
  end;
end;

procedure writeFile(filename, content, action: string);
var
  F: TextFile;
begin
  AssignFile(F, filename);
  if not FileExists(filename) then
  begin
    Rewrite(F);
  end;
  //Reset(F);
  if (action = 'rewrite') then
  begin
    Rewrite(F); //覆盖原来文本
  end
  else
  begin
    Append(F); //追加到原来文本
  end;

  Writeln(F, content);
  CloseFile(F);
end;

function getUnion(one, two: TStringList): TStringList;
var
  i: integer;
begin
  result := TStringList.Create;
  for i := 0 to one.Count - 1 do
  begin
    if in_strings(one[i], two) then
    begin
      result.Add(one[i]);
    end;
  end;
end;

function implode(str: string; list: TStringList): string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to list.Count - 1 do
  begin
    Result := Result + list[i] + str;
  end;
  if (result <> '') then
  begin
    result := Copy(Result, 1, Length(result) - length(str));
  end;
end;

function getMonths(beginTime, endTime: integer): integer;
var
  beginyear, endyear: integer;
  beginmonth, endmonth: integer;
begin
  result := 0;
  if (endTime = 0) then
  begin
    endTime := StrToInt(FormatDateTime('yyyymmdd', Now, MainFrm.dtFormat));
  end;
  beginyear := StrToInt(Copy(inttostr(beginTime), 1, 4));
  endyear := StrToInt(Copy(inttostr(endTime), 1, 4));
  beginmonth := StrToInt(Copy(inttostr(beginTime), 5, 2));
  endmonth := StrToInt(Copy(inttostr(endTime), 5, 2));
  Result := ((endyear - beginyear) * 12) + (endmonth - beginmonth) + 1;
end;

function formatDateByMonth(months: integer): string;
var
  y, m: integer;
begin
  result := '';
  if months > 0 then
  begin
    y := months div 12;
    m := months - (y * 12);
    {
    if (y > 0) then
    begin
      result := IntToStr(y)+'年';
    end;

    if (m > 0) then
    begin
      result := IntToStr(m)+'月';
    end;
    }
    result := IntToStr(y) + '年' + IntToStr(m) + '月';
  end;
end;

function formatDateByInt(adate: string): string;
begin
  if (adate = '0') then
  begin
    result := '至今';
  end
  else
  begin
    result := Copy(adate, 1, 4) + '-' + Copy(adate, 5, 2)
  end;
end;

function selectIndex(key: string; list: Tstrings): integer;
begin
  result := list.IndexOf(key);
end;

procedure QSort(var A: array of Integer);

  procedure QuickSort(var A: array of Integer; iLo, iHi: Integer);
  var
    Lo, Hi, Mid, T: Integer;
  begin
    Lo := iLo;
    Hi := iHi;
    Mid := A[(Lo + Hi) div 2];
    repeat
      while A[Lo] < Mid do
        Inc(Lo);
      while A[Hi] > Mid do
        Dec(Hi);
      if Lo <= Hi then
      begin
        T := A[Lo];
        A[Lo] := A[Hi];
        A[Hi] := T;
        Inc(Lo);
        Dec(Hi);
      end;
    until Lo > Hi;
    if Hi > iLo then
      QuickSort(A, iLo, Hi);
    if Lo < iHi then
      QuickSort(A, Lo, iHi);
  end;

begin
  QuickSort(A, Low(A), High(A));
end;

function GetDirFileName(Dir, ExtName: string): TStringList;
var
  FSearchRec: TSearchRec;
  FileList: TStringList;
  FindResult: Integer;
begin
  if Dir[length(Dir)] <> '\' then
  begin
    Dir := Dir + '\';
  end;
  FileList := TStringList.Create;
  FindResult := FindFirst(Dir + ExtName, faAnyFile, FSearchRec); //
  try
    while FindResult = 0 do
    begin
      if (FSearchRec.name <> '.') and (FSearchRec.name <> '..') then
      begin
        FileList.Add(LowerCase(Dir + FSearchRec.Name));
      end;
      FindResult := FindNext(FSearchRec);
    end;
  finally
    SysUtils.FindClose(FSearchRec);
    //FindClose(FSearchRec);
    Dir := '';
  end;
  Result := FileList;
end;

function GetFileVersion(fn: string; var ma, mi, r, b: integer): boolean; //得到本程序的版本号
var
  buf, p: pChar;
  sver: ^VS_FIXEDFILEINFO;
  i: LongWord;
begin
  i := GetFileVersionInfoSize(pchar(fn), i);
  new(sver);
  p := pchar(sver);
  GetMem(buf, i);
  ZeroMemory(buf, i);
  result := false;
  if GetFileVersionInfo(pchar(fn), 0, 4096, pointer(buf)) then
    if VerQueryValue(buf, '\', pointer(sver), i) then
    begin
      ma := sver^.dwFileVersionMS shr 16;
      mi := sver^.dwFileVersionMS and $0000FFFF;
      r := sver^.dwFileVersionLS shr 16;
      b := sver^.dwFileVersionLS and $0000FFFF;
      result := true;
    end;
  Dispose(p);
  FreeMem(buf);
end;

function isInteger(intx: string): boolean;
var
  i: LongInt;
  f: Double;
begin
  if TryStrToInt(intx, i) or TryStrToFloat(intx, f) then
  begin
    result := true;
  end
  else
  begin
    result := false;
  end;
end;

function getFileVersionX(FileName: string): string;
type
  PVerInfo = ^TVS_FIXEDFILEINFO;

  TVS_FIXEDFILEINFO = record
    dwSignature: longint;
    dwStrucVersion: longint;
    dwFileVersionMS: longint;
    dwFileVersionLS: longint;
    dwFileFlagsMask: longint;
    dwFileFlags: longint;
    dwFileOS: longint;
    dwFileType: longint;
    dwFileSubtype: longint;
    dwFileDateMS: longint;
    dwFileDateLS: longint;
  end;
var
  ExeNames: array[0..255] of char;
  zKeyPath: array[0..255] of Char;
  VerInfo: PVerInfo;
  Buf: pointer;
  Sz: word;
  L, Len: Cardinal;
begin
  StrPCopy(ExeNames, FileName);
  Sz := GetFileVersionInfoSize(ExeNames, L);
  if Sz = 0 then
  begin
    Result := '';
    Exit;
  end;

  try
    GetMem(Buf, Sz);
    try
      GetFileVersionInfo(ExeNames, 0, Sz, Buf);
      if VerQueryValue(Buf, '\', Pointer(VerInfo), Len) then
      begin
        Result := IntToStr(HIWORD(VerInfo.dwFileVersionMS)) + '.' + IntToStr(LOWORD(VerInfo.dwFileVersionMS)) + '.' + IntToStr(HIWORD(VerInfo.dwFileVersionLS)) + '.' + IntToStr(LOWORD(VerInfo.dwFileVersionLS));

      end;
    finally
      FreeMem(Buf);
    end;
  except
    Result := '-1';
  end;
end;

function GetUnixTime(atime: TDateTime): integer;
begin
  if atime = 0 then
  begin
    atime := Now;
  end;
  result := DatetimetoUnix(atime) - (MainFrm.OwnOption.TimeZone * 3600);
end;

function SplitString(const Source, ch: string): TStringList;
var
  temp: string;
  i: Integer;
begin
  Result := TStringList.Create;

  //如果是空自符串则返回空列表
  if Source = '' then
    exit;
  temp := Source;
  i := pos(ch, Source);
  while i <> 0 do
  begin
    Result.add(copy(temp, 0, i - 1));
    Delete(temp, 1, i);
    i := pos(ch, temp);
  end;
  Result.add(temp);
end;

function DeletePath(mDirName: string): Boolean;
var
  vSearchRec: TSearchRec;
  vPathName: string;
  K: Integer;
begin
  Result := True;
  vPathName := mDirName + '\*.*';
  K := FindFirst(vPathName, faAnyFile, vSearchRec);
  while K = 0 do
  begin
    if (vSearchRec.Attr and faDirectory > 0) and (Pos(vSearchRec.Name, '..') = 0) then
    begin
      FileSetAttr(mDirName + '\' + vSearchRec.Name, faDirectory);
      Result := DeletePath(mDirName + '\' + vSearchRec.Name);
    end
    else if Pos(vSearchRec.Name, '..') = 0 then
    begin
      FileSetAttr(mDirName + '\' + vSearchRec.Name, 0);
      Result := DeleteFile(PChar(mDirName + '\' + vSearchRec.Name));
    end;
    if not Result then
      Break;
    K := FindNext(vSearchRec);
  end;
  FindClose(vSearchRec);
  Result := RemoveDir(mDirName);
end;

function DownLoadFile(url: string; desc: string): boolean;
begin
  try
    Result := UrlDownloadToFile(nil, PChar(url), PChar(desc), 0, nil) = 0;
  except
    Result := False;
  end;
end;

function GetFileSize(filename: string): int64;
var
  FS: TFileStream;
begin
  FS := TFileStream.Create(filename, fmShareDenyNone);
  result := FS.Size;
  FS.Free;
end;

end.

