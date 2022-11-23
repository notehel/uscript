unit setting;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ShellApi, ShlObj, Generics.Collections;

const
  CCH_MAXNAME = 255; //描述的缓冲区的大小
  LNK_RUN_MIN = 7; //运行时最小化
  LNK_RUN_MAX = 3; //运行是最大化
  LNK_RUN_NORMAL = 1; //正常窗口
  //virtualtree 编辑
  WM_STARTEDITING = WM_USER + 2000;


type
  LINK_FILE_INFO = record
    FileName: array[0..MAX_PATH] of char; //目标文件名
    WorkDirectory: array[0..MAX_PATH] of char; //工作目录或者起始目录
    IconLocation: array[0..MAX_PATH] of char; //图标文件名
    IconIndex: integer; //图标索引
    Arguments: array[0..MAX_PATH] of char; //程序运行的参数
    Description: array[0..CCH_MAXNAME] of char; //快捷方式的描述
    ItemIDList: PItemIDList; //只供读取使用
    RelativePath: array[0..255] of char; //相对目录，只能设置
    ShowState: integer; //运行时的窗口状态
    HotKey: word; //快捷键
  end;

type
  TOptions = record
    TimeZone: integer; //时区
    FontSize: integer;
    FontName: string;
  end;

implementation

end.
