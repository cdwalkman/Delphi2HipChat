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
(** 程式名稱:
(** 程式說明: 將訊息發送到 HipChat
(** 建立日期: 2018/01/27
(** 異動日期: 2018/01/29
(** 維護人員: JunJia
(** 備    註: Token須由JIRA管理者權限產生，一般使用者無法產生。
(******************************************************************************)
var
  json : TJSONObject;
  ssApiResult: TStringStream;
  sApiURL:string;
  JsonToSend : TStringStream;
  sResponse: string;
  // 組成訊息內容(顏色尚在測試)
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
      sApiURL := Format('https://api.hipchat.com/v2/room/%s/notification?auth_token=your_token',//Token無法作為參數
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
