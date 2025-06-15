unit tictactoe;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Menus, INIfiles;

type
  TForm1 = class(TForm)
    mm1: TMainMenu;
    Newgame1: TMenuItem;
    mniHvsH: TMenuItem;
    mniHvsC: TMenuItem;
    mniCvsH: TMenuItem;
    imgEmpty: TImage;
    imgDonut: TImage;
    imgCross: TImage;
    mniN1: TMenuItem;
    mniExit: TMenuItem;
    mniLevel: TMenuItem;
    mniLevel1: TMenuItem;
    mniLevel2: TMenuItem;
    mniLevel3: TMenuItem;
    mniLevel4: TMenuItem;
    mniLevel5: TMenuItem;
    procedure DrawIcon(X, Y, SquareIndex: Integer);
    procedure NewGame();
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure mniHvsHClick(Sender: TObject);
    procedure mniHvsCClick(Sender: TObject);
    procedure mniCvsHClick(Sender: TObject);
    procedure mniExitClick(Sender: TObject);
    procedure mniLevel1Click(Sender: TObject);
    procedure mniLevel2Click(Sender: TObject);
    procedure mniLevel3Click(Sender: TObject);
    procedure mniLevel4Click(Sender: TObject);
    procedure mniLevel5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure Paint; override; //Paint override needed to display new game from FormCreate
  end;

const
  IconSize = 154; //Size of an icon in pixels
  IconSpace = 3;
  P1Val = 1;
  P2Val = 4;
  P1Win = P1Val * 3;
  P2Win = P2Val * 3;

type
  GameBoard = array[0..2, 0..2] of Byte;

var
  Form1: TForm1;
  SquaresLeft, CPUVal, OppVal: Byte;
  BoardStatus: GameBoard;
  GameRunning, P1Playing, P1CPU, P2CPU: Boolean;
  IconPic: array[0..2] of^TBitmap;
  CPUlevel: Integer;

implementation

{$R *.dfm}

function CheckWin(): Byte;
begin
  Result := 0;
  if (BoardStatus[0, 0] + BoardStatus[1, 0] + BoardStatus[2, 0] = P1Win) or (BoardStatus[0, 1] + BoardStatus[1, 1] + BoardStatus[2, 1] = P1Win) or (BoardStatus[0, 2] + BoardStatus[1, 2] + BoardStatus[2, 2] = P1Win) or (BoardStatus[0, 0] + BoardStatus[0, 1] + BoardStatus[0, 2] = P1Win) or (BoardStatus[1, 0] + BoardStatus[1, 1] + BoardStatus[1, 2] = P1Win) or (BoardStatus[2, 0] + BoardStatus[2, 1] + BoardStatus[2, 2] = P1Win) or (BoardStatus[0, 0] + BoardStatus[1, 1] + BoardStatus[2, 2] = P1Win) or (BoardStatus[0, 2] + BoardStatus[1, 1] + BoardStatus[2, 0] = P1Win) then
    Result := 1;
  if (BoardStatus[0, 0] + BoardStatus[1, 0] + BoardStatus[2, 0] = P2Win) or (BoardStatus[0, 1] + BoardStatus[1, 1] + BoardStatus[2, 1] = P2Win) or (BoardStatus[0, 2] + BoardStatus[1, 2] + BoardStatus[2, 2] = P2Win) or (BoardStatus[0, 0] + BoardStatus[0, 1] + BoardStatus[0, 2] = P2Win) or (BoardStatus[1, 0] + BoardStatus[1, 1] + BoardStatus[1, 2] = P2Win) or (BoardStatus[2, 0] + BoardStatus[2, 1] + BoardStatus[2, 2] = P2Win) or (BoardStatus[0, 0] + BoardStatus[1, 1] + BoardStatus[2, 2] = P2Win) or (BoardStatus[0, 2] + BoardStatus[1, 1] + BoardStatus[2, 0] = P2Win) then
    Result := 2;
end;

procedure TForm1.DrawIcon(X, Y, SquareIndex: Integer);
begin
  Form1.Canvas.Draw(X * (IconSize + IconSpace), Y * (IconSize + IconSpace), IconPic[SquareIndex]^);
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  myINI: TINIFile;
begin
  //Initialise options from INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliTacToe.ini');
  //Read settings from INI file
  CPUlevel := myINI.ReadInteger('Settings', 'CPUlevel', 1);
  myINI.Free;
  //Set CPU level
  if CPUlevel = 1 then
    mniLevel1.Checked := true
  else if CPUlevel = 2 then
    mniLevel2.Checked := true
  else if CPUlevel = 3 then
    mniLevel3.Checked := true
  else if CPUlevel = 4 then
    mniLevel4.Checked := true
  else if CPUlevel = 5 then
    mniLevel5.Checked := true;
      //Initialise shapes images: 0=empty; 1=cross; 2=donut
  New(IconPic[0]);
  IconPic[0]^ := imgEmpty.Picture.Bitmap;
  New(IconPic[1]);
  IconPic[1]^ := imgCross.Picture.Bitmap;
  New(IconPic[2]);
  IconPic[2]^ := imgDonut.Picture.Bitmap;

end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
var
  myINI: TINIFile;
begin
  //Save settings to INI file
  myINI := TINIFile.Create(ExtractFilePath(Application.EXEName) + 'SliTacToe.ini');
  myINI.WriteInteger('Settings', 'CPUlevel', CPUlevel);
  myINI.Free;
end;

procedure TForm1.Paint;
//Paint override needed, otherwise won't display game if started from FormCreate
var
  X, Y: Byte;
begin
  //Start new game
  Form1.ClientWidth := 3 * IconSize + 2 * IconSpace;
  Form1.ClientHeight := 3 * IconSize + 2 * IconSpace;
  //Draw empty board
  for X := 0 to 2 do
    for Y := 0 to 2 do
      DrawIcon(X, Y, 0);
  GameRunning := false;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  PosX, PosY, i, j: Byte;
begin
  if (Button <> mbLeft) then
    Exit;
  if (GameRunning = false) then
  begin
    ShowMessage('You need to start a new game!');
    Exit;
  end;
  PosX := X div (IconSize + IconSpace);
  PosY := Y div (IconSize + IconSpace);
  //Check square not played
  if (BoardStatus[PosX, PosY] > 0) then
    Exit;
  //Clicking a square
  if P1Playing then
  begin
    DrawIcon(PosX, PosY, 1);
    BoardStatus[PosX, PosY] := P1Val;
  end
  else
  begin
    DrawIcon(PosX, PosY, 2);
    BoardStatus[PosX, PosY] := P2Val;
  end;
  //Check human win
  if (CheckWin = 1) then
  begin
    GameRunning := False;
    ShowMessage('Crosses win!');
    Exit;
  end;
  if (CheckWin = 2) then
  begin
    GameRunning := False;
    ShowMessage('Donuts win!');
    Exit;
  end;
  //Tied game?
  Dec(SquaresLeft);
  if SquaresLeft = 0 then
  begin
    GameRunning := False;
    ShowMessage('Game ended in a tie!');
    Exit;
  end;
  P1Playing := not P1Playing;
  //CPU turn
  if P1CPU or P2CPU then
  begin
    GameRunning := False; //Prevents human playing
    //Centre square taken?
    if (BoardStatus[1, 1] = 0) and (CPUlevel > 2) then  //Can play here
    begin
      BoardStatus[1, 1] := CPUVal;
      if P1Playing then
        DrawIcon(1, 1, 1)
      else
        DrawIcon(1, 1, 2);
      Dec(SquaresLeft);
      P1Playing := not P1Playing;
      GameRunning := True;  //Human can play
      Exit;
    end;
    //Check if CPU can win
    if (CPUlevel > 1) then
    begin
      for i := 0 to 2 do
        for j := 0 to 2 do
        begin
          if (BoardStatus[i, j] = 0) then  //Can play here
          begin
            BoardStatus[i, j] := CPUVal; //What if CPU plays here
            if (CheckWin > 0) then       //Win: play to win there
            begin
              if P1Playing then
                DrawIcon(i, j, 1)
              else
                DrawIcon(i, j, 2);
              ShowMessage('CPU wins!');
              Exit;
            end
            else
              BoardStatus[i, j] := 0;    //Not a win: revert and try next
          end;
        end;
    //Check if opponent can win
      for i := 0 to 2 do
        for j := 0 to 2 do
        begin
          if (BoardStatus[i, j] = 0) then  //Can play here
          begin
            BoardStatus[i, j] := OppVal; //What if opponent plays here
            if (CheckWin > 0) then       //Win: play to block there
            begin
              if P1Playing then
                DrawIcon(i, j, 1)
              else
                DrawIcon(i, j, 2);
              BoardStatus[i, j] := CPUVal;
            //Tied game?
              Dec(SquaresLeft);
              if SquaresLeft = 0 then
              begin
                ShowMessage('Game ended in a tie!');
                Exit;
              end;
              P1Playing := not P1Playing;
              GameRunning := True;  //Human can play
              Exit;
            end
            else
              BoardStatus[i, j] := 0;    //Not a win, revert and try another
          end;
        end;
    end;
    //Favour a corner
    if (CPUlevel > 3) then
    begin
      i := 9;
      j := 9;
      if (BoardStatus[0, 0] = 0) then
      begin
        i := 0;
        j := 0;
      end
      else if (BoardStatus[0, 2] = 0) then
      begin
        i := 0;
        j := 2;
      end
      else if (BoardStatus[2, 0] = 0) then
      begin
        i := 2;
        j := 0;
      end
      else if (BoardStatus[2, 2] = 0) then
      begin
        i := 2;
        j := 2;
      end;
      if (CPUlevel = 5) then
      begin
        if (BoardStatus[1, 1] = CPUVal) and (BoardStatus[0, 0] = OppVal) and (BoardStatus[2, 2] = OppVal) then
        begin
          if (BoardStatus[0, 1] = 0) then
          begin
            i := 0;
            j := 1;
          end
          else if (BoardStatus[1, 0] = 0) then
          begin
            i := 1;
            j := 0;
          end
          else if (BoardStatus[1, 2] = 0) then
          begin
            i := 1;
            j := 2;
          end
          else if (BoardStatus[2, 1] = 0) then
          begin
            i := 2;
            j := 1;
          end;
        end;
        if (BoardStatus[1, 1] = CPUVal) and (BoardStatus[0, 2] = OppVal) and (BoardStatus[2, 0] = OppVal) then
        begin
          if (BoardStatus[0, 1] = 0) then
          begin
            i := 0;
            j := 1;
          end
          else if (BoardStatus[1, 0] = 0) then
          begin
            i := 1;
            j := 0;
          end
          else if (BoardStatus[1, 2] = 0) then
          begin
            i := 1;
            j := 2;
          end
          else if (BoardStatus[2, 1] = 0) then
          begin
            i := 2;
            j := 1;
          end;
        end;
      end;
      if i <> 9 then
      begin
        BoardStatus[i, j] := CPUVal;
        if P1Playing then
          DrawIcon(i, j, 1)
        else
          DrawIcon(i, j, 2);
        Dec(SquaresLeft);
        P1Playing := not P1Playing;
        GameRunning := True;  //Human can play
        Exit;
      end;
    end;

    //Reached here: CPU can't win and human can't win, play random free square
    repeat
      i := Random(3);
      j := Random(3);
    until (BoardStatus[i, j] = 0);
    BoardStatus[i, j] := CPUVal; //Play
    if P1Playing then
      DrawIcon(i, j, 1)
    else
      DrawIcon(i, j, 2);
    //Tied game?
    Dec(SquaresLeft);
    if SquaresLeft = 0 then
    begin
      ShowMessage('Game ended in a tie!');
      Exit;
    end;
    //Game carries on
    P1Playing := not P1Playing;
    GameRunning := True;  //Human can play
  end;
end;

procedure TForm1.mniHvsHClick(Sender: TObject);
begin
  P1CPU := False;
  P2CPU := False;
  CPUVal := 0;
  OppVal := 0;
  NewGame();
end;

procedure TForm1.mniHvsCClick(Sender: TObject);
begin
  P1CPU := False;
  P2CPU := True;
  CPUVal := P2Val;
  OppVal := P1Val;
  NewGame();
end;

procedure TForm1.mniCvsHClick(Sender: TObject);
begin
  P1CPU := True;
  P2CPU := False;
  CPUVal := P1Val;
  OppVal := P2Val;
  NewGame();
end;

procedure TForm1.mniExitClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.mniLevel1Click(Sender: TObject);
begin
  mniLevel1.Checked := True;
  mniLevel2.Checked := False;
  mniLevel3.Checked := False;
  mniLevel4.Checked := False;
  mniLevel5.Checked := False;
  CPUlevel := 1;
end;

procedure TForm1.mniLevel2Click(Sender: TObject);
begin
  mniLevel1.Checked := False;
  mniLevel2.Checked := True;
  mniLevel3.Checked := False;
  mniLevel4.Checked := False;
  mniLevel5.Checked := False;
  CPUlevel := 2;
end;

procedure TForm1.mniLevel3Click(Sender: TObject);
begin
  mniLevel1.Checked := False;
  mniLevel2.Checked := False;
  mniLevel3.Checked := True;
  mniLevel4.Checked := False;
  mniLevel5.Checked := False;
  CPUlevel := 3;
end;

procedure TForm1.mniLevel4Click(Sender: TObject);
begin
  mniLevel1.Checked := False;
  mniLevel2.Checked := False;
  mniLevel3.Checked := False;
  mniLevel4.Checked := True;
  mniLevel5.Checked := False;
  CPUlevel := 4;
end;

procedure TForm1.mniLevel5Click(Sender: TObject);
begin
  mniLevel1.Checked := False;
  mniLevel2.Checked := False;
  mniLevel3.Checked := False;
  mniLevel4.Checked := False;
  mniLevel5.Checked := True;
  CPUlevel := 5;
end;

procedure TForm1.NewGame();
var
  X, Y: Byte;
begin
  //Initialise board
  for X := 0 to 2 do
    for Y := 0 to 2 do
    begin
      DrawIcon(X, Y, 0);
      BoardStatus[X, Y] := 0;
    end;
  //Initialise game
  SquaresLeft := 9;
  GameRunning := True;
  if P1CPU then
  begin
    if (CPUlevel > 2) then
    begin
    //CPU starts: always play centre of board
      DrawIcon(1, 1, 1);
      BoardStatus[1, 1] := P1Val;
      Dec(SquaresLeft);
      P1Playing := False;
    end
    else
    begin
    //Plays randomly
      X := Random(3);
      Y := Random(3);
      BoardStatus[X, Y] := CPUVal; //Play
      DrawIcon(X, Y, 1)
    end;
  end
  else
    P1Playing := True;
end;

end.

