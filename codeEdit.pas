unit codeEdit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DScintilla;

type
  TcodeEditFrm = class(TForm)
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    FSci: TDScintilla;
    scpName: string;
  public
    { Public declarations }
    constructor Create(fileName: string); overload;
  end;

var
  codeEditFrm: TcodeEditFrm;

implementation

{$R *.dfm}

constructor TcodeEditFrm.Create(fileName: string);
begin
  inherited Create(nil);
  scpName := fileName;
end;

procedure TcodeEditFrm.FormDestroy(Sender: TObject);
begin
  FSci.Free;
  FSci := nil;
end;

procedure TcodeEditFrm.FormShow(Sender: TObject);
var
  content: TstringList;
begin
  FSci := TDScintilla.Create(nil);
  FSci.DllModule := 'SciLexer.dll';
  FSci.Align := alClient;
  FSci.Parent := Self;

  FSci.SendEditor(4001, 15);

  content := TstringList.Create;
  content.LoadFromFile(scpName);
  FSci.SetText(content.Text);
  content.Free;
  //
end;

end.
