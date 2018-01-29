unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,System.JSON, Vcl.StdCtrls,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IPPeerClient, REST.Client, Data.Bind.Components, Data.Bind.ObjectScope,
  System.JSON.Types,
  System.JSON.Writers,
  System.JSON.Builders;

type
  TForm1 = class(TForm)
    Button1: TButton;
    edtMsg: TEdit;
    ComboBox1: TComboBox;
    idhtpHipChat: TIdHTTP;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure send_hiphop_msg(idhttpAPI:TIdHTTP;sRoom,sReciver,sMsg:string);
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}




procedure TForm1.Button1Click(Sender: TObject);
begin
  send_hiphop_msg(idhtpHipChat,'QMS-Notice',ComboBox1.Text,edtMsg.Text);
end;

procedure TForm1.send_hiphop_msg(idhttpAPI:TIdHTTP;sRoom,sReciver,sMsg: string);
(******************************************************************************)
(** �{���W��:
(** �{������: �N�T���o�e�� HipChat
(** �إߤ��: 2018/01/27
(** ���ʤ��: 2018/01/29
(** ���@�H��: JunJia
(** ��    ��: Token����JIRA�޲z���v�����͡A�@��ϥΪ̵L�k���͡C
(******************************************************************************)
var
  json : TJSONObject;
  ssApiResult: TStringStream;
  sApiURL:string;
  JsonToSend : TStringStream;
  sResponse: string;
  // �զ��T�����e(�C��|�b����)
  function set_msg:string;
  var
    writer : TJsonTextWriter;
    sw : TStringWriter;
  begin
    sw := TStringWriter.Create;
    writer := TJsonTextWriter.Create(sw);
    writer.Formatting := TJsonFormatting.Indented;
    writer.WriteStartObject;

    writer.WritePropertyName('color');
    writer.WriteValue('red');
    writer.WritePropertyName('notify');
    writer.WriteValue('true');
    writer.WritePropertyName('message_format');
    writer.WriteValue('text');
    writer.WritePropertyName( 'message');
    writer.WriteValue(sReciver+' ' +sMsg);
    writer.WriteEndObject;

    Result := sw.ToString;
    sw.Free;
  end;
begin
  JsonToSend := TStringStream.Create(set_msg);
  try
    idhttpAPI.Request.ContentType := 'application/json';
    idhttpAPI.Request.ContentEncoding := 'utf-8';
    try
      sApiURL := Format('https://api.hipchat.com/v2/room/%s/notification?auth_token=yoGUlzWddLcnuov9CLLZCCsMQj9kchYNnkxWkJgL',//Token�L�k�@���Ѽ�
                        [sRoom]);
      sResponse := idhttpAPI.Post(sApiURL,JsonToSend);
    except
      on E: Exception do
        ShowMessage('Error Message: '#13#10 + e.Message);
    end;
  finally
    JsonToSend.Free();
  end;
end;

end.
