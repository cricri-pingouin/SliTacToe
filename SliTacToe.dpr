program SliTacToe;

uses
  Forms,
  tictactoe in 'tictactoe.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Sli Tac Toe';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
