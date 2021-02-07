unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, ExtDlgs,jpeg,Math,GDIPAPI, GDIPOBJ,
  Menus;

const
  PI         = 3.141592653589793;

type
  TPinList =array of TPoint;
  TColorList =array[0..4-1] of LongInt;

  type
   PRGBTripleArray = ^TRGBTripleArray;
   TRGBTripleArray = array[0..4095] of TRGBTriple;


type
  TControlDragKind = (dkNone, dkTopLeft, dkTop, dkTopRight, dkRight, dkBottomRight,
    dkBottom, dkBottomLeft, dkLeft, dkClient);

type
  TForm1 = class(TForm)
    OpenPictureDialog1: TOpenPictureDialog;
    Timer1: TTimer;
    SavePictureDialog1: TSavePictureDialog;
    Panel1: TPanel;
    Label1: TLabel;
    Button2: TButton;
    Button4: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label3: TLabel;
    Edit1: TEdit;
    Edit2: TEdit;
    GroupBox2: TGroupBox;
    Label5: TLabel;
    Label6: TLabel;
    Edit3: TEdit;
    Edit4: TEdit;
    ScrollBar1: TScrollBar;
    RadioGroup2: TRadioGroup;
    ProgressBar1: TProgressBar;
    ScrollBox1: TScrollBox;
    OpenImage: TImage;
    Shape1: TShape;
    Button1: TButton;
    StatusBar1: TStatusBar;
    Memo1: TMemo;
    PopupMenu1: TPopupMenu;
    SaveImage1: TMenuItem;
    ComboBox1: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Shape1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Shape1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure RadioGroup2Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ScrollBox1Resize(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SaveImage1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FDownPos: TPoint;
    FDragKind: TcontrolDragKind;
  public
    { Public declarations }

    procedure Draw(Pins:Integer);
  end;

var
  Form1: TForm1;

   PinList:TPinList;

  LineList:TPinList;
  Data   :array of Integer;
  PinCount:Integer=200;
  WireCount:Integer=1000;
  lineCount:Integer=0;
  startPinIndex:Integer=0;
  g: TGPGraphics;
  p: TGPPen;
  B: TGPSolidBrush;



  IMG_SIZE:Integer   = 4;
  IMG_WIDTH:Integer  = 480;
  IMG_HEIGHT:Integer = 480;

  str:string='';
  GrayBitmap:TBitmap;


implementation

{$R *.dfm}

const
  { Set of cursors to use while moving over and dragging on controls. }
  DragCursors: array[TControlDragKind] of TCursor =
  (crDefault, crSizeNWSE, crSizeNS, crSizeNESW, crSizeWE,
    crSizeNWSE, crSizeNS, crSizeNESW, crSizeWE, crHandPoint);
  {Width of "hot zone" for dragging around the control borders. }
  HittestMargin = 3;

function GetDragKind(Shape: TShape; X, Y: Integer): TControlDragKind;
var
  r: TRect;
begin
  r := Shape.Clientrect;
  Result := dkNone;
  if Abs(X - r.left) <= HittestMargin then
    if Abs(Y - r.top) <= HittestMargin then
      Result := dkTopLeft
    else if Abs(Y - r.bottom) <= HittestMargin then
      Result := dkBottomLeft
    else
      Result := dkLeft
  else if Abs(X - r.right) <= HittestMargin then
    if Abs(Y - r.top) <= HittestMargin then
      Result := dkTopRight
    else if Abs(Y - r.bottom) <= HittestMargin then
      Result := dkBottomRight
    else
      Result := dkRight
  else if Abs(Y - r.top) <= HittestMargin then
    Result := dkTop
  else if Abs(Y - r.bottom) <= HittestMargin then
    Result := dkBottom
  else if PtInRect(r, Point(X, Y)) then
    Result := dkClient;
end;


{


procedure TForm1.Draw(Pins:Integer);
var
 I,X,Y,X1,Y1:Integer;
 W,H,W1,H1:Integer;

 Radius:Integer;
 angleUnit:Extended;
 angle:Extended;


  cos_angle,sin_angle:Extended;

   lf: TLogFont;
  tf: TFont;


  c:TPoint;
  r:Trect;


begin
   OpenImage.Picture.Bitmap.Canvas.Font.Name := 'Arial';
    OpenImage.Picture.Bitmap.Canvas.Font.Size := 8;



   W:=OpenImage.Picture.Bitmap.Width;
   H:=OpenImage.Picture.Bitmap.Height;

   OpenImage.Picture.Bitmap.Canvas.Brush.Color := clWhite;
   OpenImage.Picture.Bitmap.Canvas.Pen.Color:=clBlack;
   OpenImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0,OpenImage.Picture.Bitmap.Width,OpenImage.Picture.Bitmap.Height));

    c:=point((W div 2), (H div 2));
    W1:=W-200;
    H1:=H-200;

    r:=rect(c.x - trunc( W1 /2),c.Y-trunc(H1/2),
              c.x+trunc( W1/2),c.y+trunc(H1/2));

    //Image1.Picture.Bitmap.Canvas.rectangle(r.left,r.top,r.right,r.bottom);




   

   Radius:=(W div 2)-40;
   angleUnit :=(PI * 2) / Pins;


        for I:=0 to Pins-1 do
        begin
            angle := angleUnit * I - PI / 2;

            tf := TFont.Create;
            try
               tf.Assign(OpenImage.Picture.Bitmap.Canvas.Font);
               GetObject(tf.Handle, SizeOf(lf), @lf);


                  lf.lfEscapement  :=900-(I*(3600 div Pins));
                  lf.lfOrientation :=900-(I*(3600 div Pins));
                  tf.Handle := CreateFontIndirect(lf);
                  OpenImage.Picture.Bitmap.Canvas.Font.Assign(tf);

                  x := Round((W div 2) + (radius-20) * cos(angle));
                  y := Round((H div 2) + (radius-20) * sin(angle));
                  OpenImage.Picture.Bitmap.Canvas.TextOut(x,y,'o');


                  x := Round((W div 2) + (radius-10) * cos(angle));
                  y := Round((H div 2) + (radius-10) * sin(angle));
                  OpenImage.Picture.Bitmap.Canvas.TextOut(x,y,'--');

                  x := Round((W div 2) + radius * cos(angle));
                  y := Round((H div 2) + radius * sin(angle));
                  OpenImage.Picture.Bitmap.Canvas.TextOut(x,y,inttostr(i));


            finally
              tf.Free;
            end;
       end;

end;

 }




procedure TForm1.Draw(Pins:Integer);
var
 I,X,Y,X1,Y1:Integer;
 W,H:Integer;

  radius:Extended;
   RMod,D:Extended;
   N:Integer;
   angle,Alpha,Rotade:Extended;





begin
   OpenImage.Picture.Bitmap.Canvas.Font.Name := 'Arial';
   OpenImage.Picture.Bitmap.Canvas.Font.Size := 8;

   W:=OpenImage.Picture.Bitmap.Width;
   H:=OpenImage.Picture.Bitmap.Height;

   OpenImage.Picture.Bitmap.Canvas.Brush.Color := clWhite;
   OpenImage.Picture.Bitmap.Canvas.Pen.Color:=clBlack;
   OpenImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0,OpenImage.Picture.Bitmap.Width,OpenImage.Picture.Bitmap.Height));



    Rotade:=0;
    radius := min(W / 2,H /2)-50;


    case Form1.ComboBox1.ItemIndex of
     0: N:=180;
     1: begin
        N:=4;
        Rotade:=PI/N;
     end;
     2: N:=5;
     3: N:=6;
     4: N:=7;
     5: N:=8;
   END;

       

        for I:=0 to Pins-1 do
        begin

                 
                 Angle:=I*((PI*2)/Pins);

                 RMod := 2*PI/N;
                 Alpha :=  PI/2-abs((Angle - RMod * Trunc(Angle/RMod))-(PI/N));
                 D := radius*(cos(pi/N)/sin(Alpha));

                 if I mod 2=0 then
                   OpenImage.Picture.Bitmap.Canvas.Font.Color:= clRed
                 else
                   OpenImage.Picture.Bitmap.Canvas.Font.Color:= clBlack;

                 X := Round(W Div 2+ D * cos(Angle-Rotade)); //  -(PI/N)
                 Y := Round(H Div 2+ D * sin(Angle-Rotade)); //  -(PI/N)
                 OpenImage.Picture.Bitmap.Canvas.TextOut(x,y,'o');

                 X1 := Round(W Div 2+ (D+25) * cos(Angle-Rotade)); //  -(PI/N)
                 Y1 := Round(H Div 2+ (D+25) * sin(Angle-Rotade)); //  -(PI/N)
                 OpenImage.Picture.Bitmap.Canvas.TextOut(X1,Y1,IntToStr(I));


               //  OpenImage.Picture.Bitmap.Canvas.MoveTo(X,Y);
               //  OpenImage.Picture.Bitmap.Canvas.LineTo(X1,Y1);


            
       end;

end;



procedure ResizeBitmap(Bitmap: TBitmap; const NewWidth, NewHeight: integer);
var
  buffer: TBitmap;
begin
  buffer := TBitmap.Create;
  try
    buffer.PixelFormat:=pf32bit;
    buffer.Width:=NewWidth;
    buffer.Height:=NewHeight;
    buffer.Canvas.StretchDraw(Rect(0, 0, NewWidth, NewHeight), Bitmap);
    Bitmap.Width:=NewWidth;
    Bitmap.Height:=NewHeight;

    Bitmap.Canvas.Draw(0, 0, buffer);
  finally
    buffer.Free;
  end;
end;

procedure BitmapToGrayscale(const Bitmap: TBitmap);
type
  PPixelRec = ^TPixelRec;
  TPixelRec = packed record
    B: Byte;
    G: Byte;
    R: Byte;
    Reserved: Byte;
  end;
var
  X: Integer;
  Y: Integer;
  P: PPixelRec;
  Gray: Byte;

  scanline: PRGBQuad;
begin
  Bitmap.PixelFormat := pf32Bit;
  for Y := 0 to (Bitmap.Height - 1) do
  begin
    P := Bitmap.ScanLine[Y];
    for X := 0 to (Bitmap.Width - 1) do
    begin
      Gray := Round(0.30 * P.R + 0.59 * P.G + 0.11 * P.B);
      // Gray := (P.R shr 2) + (P.R shr 4) + (P.G shr 1) + (P.G shr 4) + (P.B shr 3);
      P.R := Gray;
      P.G := Gray;
      P.B := Gray;
      Inc(P);
    end;
  end;
end;

function isDotOnLine(dotPoint, startPoint, endPoint:TPoint):Boolean;
var
  slope:Extended;
  intercept:Extended;
  blockTopY,blockBottomY,blockLeftY,blockRightY:Extended;
begin
  if (endPoint.X - startPoint.X = 0) then
  begin
    Result:=(dotPoint.X = endPoint.X);
    Exit;
  end;

   slope := (endPoint.Y - startPoint.Y) / (endPoint.X - startPoint.X);
   intercept := startPoint.Y - slope * startPoint.X;

   blockTopY := dotPoint.Y + 0.5;
   blockBottomY := dotPoint.Y - 0.5;
   blockLeftY := slope * (dotPoint.X - 0.5) + intercept;
   blockRightY := slope * (dotPoint.X + 0.5) + intercept;

  if (abs(slope) <= 1)  then
  begin

    Result:= (((blockLeftY >= blockBottomY) and (blockLeftY <= blockTopY)) or
             ((blockRightY >= blockBottomY) and (blockRightY <= blockTopY)));
  end
  else
  begin
    if (slope > 0)  then
        Result:= not ((blockLeftY > blockTopY) or (blockRightY < blockBottomY))
    else
        Result:= not ((blockRightY > blockTopY) or  (blockLeftY < blockBottomY)) ;
       
   end;


end;


function getPointListOnLine(startPoint, endPoint:TPoint):TPinList;
var

  movementX, movementY:Integer;
  currentX,currentY:Integer;
  loopcount:Integer;
begin
  if endPoint.X > startPoint.X then movementX :=1  else   movementX :=-1;
  if endPoint.Y > startPoint.Y then movementY :=1  else   movementY :=-1;

  currentX := startPoint.X;
  currentY := startPoint.Y;

  loopcount := 0;
  while ((currentX <> endPoint.X) or (currentY <> endPoint.Y)) and (loopcount <= 1000) do
  begin
   SetLength(Result, Length(Result)+1);
   Result[High(Result)]:=point(currentX, currentY);


    if isDotOnLine(Point(currentX + movementX, currentY), startPoint, endPoint) then
    begin
      Inc(currentX, movementX);
    end else begin
      Inc(currentY , movementY);
    end;

    Inc(loopcount);
  end;
  SetLength(Result, Length(Result)+1);
  Result[High(Result)] := endPoint;


end;

function isLineDrawn(lineLst:TPinList; startPinIndex, endPinIndex:Integer):Boolean ;
var
  I:Integer;
  lineFound:Boolean;
begin
   lineFound :=false;

   for i :=Low(lineLst) to High(lineLst) do
   begin
     if ((startPinIndex = lineLst[I].X) and (endPinIndex = lineLst[I].Y)) or
        ((startPinIndex = lineLst[I].Y) and (endPinIndex = lineLst[I].X))  then
      begin
        lineFound :=true;
        break;
      end;
   end;

   Result := Boolean(lineFound);
end;


function isPinTooClose(pinList:TPinList; startPinIndex, endPinIndex:Integer) :Boolean;
var
  pinDistance:Extended;
begin
   pinDistance := abs(endPinIndex - startPinIndex);

   if  pinDistance > (length(pinList) / 2)  then
      pinDistance := length(pinList) - pinDistance;


       Result:=(pinDistance < 25)

end;


procedure GetPixelData(Bitmap:TBitmap);
var i, x, y: Integer;
   ptr: PByteArray;
begin
 i := 0;


 SetLength(Data,IMG_WIDTH * IMG_HEIGHT * IMG_SIZE);

 for y := 0 to Bitmap.Height - 1 do
 begin
   ptr := PByteArray(Bitmap.ScanLine[y]);
   for x := 0 to Bitmap.Width*IMG_SIZE - 1 do
   begin
     Data[i] := byte(ptr[x]);
     Inc(i);
   end;
 end;
end;




procedure  GeneratePinList(len,W,H:Integer);
var
   radius:Extended;
   RMod,D:Extended;
   I,N,R:Integer;
   angle,Alpha,Rotade:Extended;
   X,Y:Integer;
   CenterX,CenterY:Integer;
begin

  
   SetLength(pinList,len);
   Rotade:=0;
   R:=0;
   CenterX:=W div 2;
   CenterY:=H div 2;


   radius := min(W / 2,H /2);

   case Form1.ComboBox1.ItemIndex of
     0: N:=180;
     1: begin
        N:=4;
        R:=75;
        Rotade:=PI/N;
     end;
     2: N:=5;
     3: N:=6;
     4: N:=7;
     5: N:=8;
   END;

   for i :=Low(pinList) to High(pinList) do
   begin

        Angle:=I*((PI*2)/len);
        RMod := 2*PI/N;
        Alpha :=  PI/2-abs((Angle - RMod * Trunc(Angle/RMod))-(PI/N));
        D := (radius+R) *(cos(pi/N)/sin(Alpha));

        X := Round(CenterX + D * cos(Angle-Rotade)); //  -(PI/N)
        Y := Round(CenterY + D * sin(Angle-Rotade)); //  -(PI/N)

        pinList[I] :=Point(x, y );
   end;


end;



function GetImageData(dot:TPoint):TColorList;
var
  startIndex: Longint;
begin
  startIndex := (dot.y * IMG_WIDTH  + dot.x) * IMG_SIZE ; // rgba

  Result[0]:=Data[startIndex];
  Result[1]:=Data[startIndex + 1];
  Result[2]:=Data[startIndex + 2];
  Result[3]:=Data[startIndex + 3];

end;

procedure ReduceImageData(startPoint, endPoint:TPoint) ;
var
  dotList: TPinList;
  I:Integer;
  startIndex: Longint;
begin
   dotList := getPointListOnLine(startPoint, endPoint);

   for i :=Low(dotList) to High(dotList) do
   begin
      startIndex := (dotList[i].y * IMG_WIDTH  + dotList[i].x) * IMG_SIZE; // rgba
      Inc(Data[startIndex],50);

      if Data[startIndex]>255 then Data[startIndex] :=255;
   end;

end;



function GetLineScore(startPoint, endPoint:TPoint):Extended;
 var
  dotList: TPinList;
  I:Integer;
  colorR:Longint;
  dotScore:Extended;
  dotScoreList:array of Double;
begin
  dotList := getPointListOnLine(startPoint, endPoint);

  for i :=Low(dotList) to High(dotList) do
  begin
    colorR := getImageData(Point(dotList[i].x,dotList[i].y))[0];
    dotScore:= 1 - colorR / 255 ;
    SetLength(dotScoreList, Length(dotScoreList)+1);
    dotScoreList[High(dotScoreList)] := dotScore;
  end;

  Result:=Sum(dotScoreList) / Length(dotScoreList) ;
end;



procedure DrawLine(X1,Y1,X2,Y2:Integer;Index:Integer);
begin
   g.DrawLine(p,X1,Y1,X2,Y2);
   //Form1.DrawImage.Picture.Bitmap.Assign(Bitmap);
   str:=Str+IntToStr(Index)+',';
   Form1.Memo1.Text:=Str;

  // SendMessage(Form1.Memo1.Handle, EM_LINESCROLL, 0,Form1.Memo1.Lines.Count);
   Form1.OpenImage.Invalidate;
end;




procedure TForm1.FormCreate(Sender: TObject);
begin

 ScrollBox1.DoubleBuffered := True;
 GrayBitmap:=TBitmap.Create;
 //panel1.DoubleBuffered:=true;


end;

procedure TForm1.Button4Click(Sender: TObject);
var
 Picture:TPicture;


begin
  if OpenPictureDialog1.Execute then
  begin
    Picture:=TPicture.Create;
    try
      Picture.LoadFromFile(OpenPictureDialog1.FileName);
      OpenImage.Picture.Bitmap.Assign(Picture.Graphic);
      OpenImage.Left:=(ScrollBox1.Width div 2)-(OpenImage.Width div 2);
      OpenImage.Top:=(ScrollBox1.Height div 2)-(OpenImage.Height div 2);
      OpenImage.Picture.Bitmap.PixelFormat:=pf24bit;
      Shape1.SetBounds(OpenImage.Left,OpenImage.Top,OpenImage.Width,OpenImage.Height);



         Shape1.Visible:=True;
         Button1.Enabled:=false;
         Button2.Enabled:=false;

    //  Shape1.Left:=(OpenScrollBox.Width div 2)-(Shape1.Width div 2);
    //  Shape1.Top:=(OpenScrollBox.Height div 2)-(Shape1.Height div 2);

    finally
     Picture.Free;
    end;
  end;
end;

procedure TForm1.Shape1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) and (Shift = [ssLeft]) then
  begin
    FDragKind := GetDragKind(Shape1, X, Y);
    if FDragKind <> dkNone then
    begin
       FDownPos := Shape1.ClientToScreen(Point(X, Y));
       Shape1.Pen.Color := clRed;
    end;
  end;
end;

procedure TForm1.Shape1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  dx, dy: Integer;
  pt: TPoint;
  r: TRect;

  X1,Y1:Integer;
begin

  Shape1.Cursor := DragCursors[GetDragKind(Shape1, X, Y)];

  if FDragKind <> dkNone then
    with Shape1 do
    begin
      pt := Shape1.ClientToScreen(Point(X, Y));
      dx := pt.X - FDownPos.X;
      dy := pt.Y - FDownPos.Y;

      FDownPos := pt;
      r := Shape1.BoundsRect;
      case FDragKind of
        dkTopLeft:
          begin
            r.Left := r.Left + dx;
            r.Top := r.Top + dy;
          end;
        dkTop:
          begin
            r.Top := r.Top + dy;
          end;
        dkTopRight:
          begin
            r.Right := r.Right + dx;
            r.Top := r.Top + dy;
          end;
        dkRight:
          begin
            r.Right := r.Right + dx;
          end;
        dkBottomRight:
          begin
            r.Right := r.Right + dx;
            r.Bottom := r.Bottom + dy;
          end;
        dkBottom:
          begin
            r.Bottom := r.Bottom + dy;
          end;
        dkBottomLeft:
          begin
            r.Left := r.Left + dx;
            r.Bottom := r.Bottom + dy;
          end;
        dkLeft:
          begin
            r.Left := r.Left + dx;
          end;
        dkClient:
          begin
            OffsetRect(r, dx, dy);
          end;
      end;

      if ((r.right - r.left) > 2 * HittestMargin) and ((r.bottom - r.top) > 2 *
        HittestMargin) then
        Shape1.Boundsrect := r;
    end;

   // image2.Canvas.FillRect(image2.ClientRect);

     X1 :=(Form1.OpenImage.ScreenToClient(Form1.Shape1.ClientOrigin)).X;
     Y1 :=(Form1.OpenImage.ScreenToClient(Form1.Shape1.ClientOrigin)).Y ;

   Panel1.Caption:=Format('Width =%d  Height =%d',[Shape1.Width,Shape1.Height]);


    GrayBitmap.Width:=Shape1.Width;
    GrayBitmap.Height:= Shape1.Height;
    GrayBitmap.Canvas.FillRect(rect(0,0,GrayBitmap.Width,GrayBitmap.Height));
    GrayBitmap.Canvas.CopyRect(rect(0,0,Shape1.Width,Shape1.Height),OpenImage.Picture.Bitmap.Canvas,Rect(x1,y1,x1+Form1.Shape1.Width, y1+Form1.Shape1.Height));
    BitmapToGrayscale(GrayBitmap);

    Edit3.Text:=IntToStr(Shape1.Width);
    Edit4.Text:=IntToStr(Shape1.Height);
end;


procedure TForm1.Shape1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if FDragKind <> dkNone then
  begin
    FDragKind := dkNone;
    Shape1.Pen.Color := clBlue;
    Button2.Enabled:=True;
   end;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
   if not (Key in [#8, '0'..'9']) then begin
     Key := #0;
  end;
end;

procedure TForm1.Edit3Change(Sender: TObject);
var
 Number, Code: Integer;
begin
 {
 Val (TEdit(Sender).Text, Number, Code);
 if Code <> 0 then
 begin
   //Edit1.SetFocus;
   //MessageDlg ('Not a number in the first edit', mtError, [mbOK], 0);
 end
 else
 begin
  if Number>100 then
  begin
     ResizeBitmap(OpenImage.Picture.Bitmap,StrToInt(Edit3.Text),StrToInt(Edit4.Text));
     GrayImage.Left:=(GrayScrollBox.Width div 2)-(GrayImage.Width div 2);
     GrayImage.Top:=(GrayScrollBox.Height div 2)-(GrayImage.Height div 2);
  end;
  end;
 
  if  (Edit3.Text <>'') and  (Edit4.Text <>'') and (StrToInt(Edit3.Text)>100) and (StrToInt(Edit4.Text)>100) then
  begin
     ResizeBitmap(GrayImage.Picture.Bitmap,StrToInt(Edit3.Text),StrToInt(Edit4.Text));
     GrayImage.Left:=(GrayScrollBox.Width div 2)-(GrayImage.Width div 2);
     GrayImage.Top:=(GrayScrollBox.Height div 2)-(GrayImage.Height div 2);
  end;
 }

end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
  I:Integer;
  score :Extended;
  highestScore :Extended;
  endPinIndex:Integer;
begin

 if  (lineCount <= WireCount) then
 begin
      endPinIndex:=0;
      highestScore := 0;
      
    for i :=Low(pinList) to High(pinList) do
    begin
       if (startPinIndex = I) or
          (isLineDrawn(lineList, startPinIndex, I)) or
          (isPinTooClose(pinList, startPinIndex, I))
       then
       begin
            continue;
       end ;

       score :=getLineScore(pinList[startPinIndex], pinList[I]);
       if (score > highestScore) then
       begin
          endPinIndex := I;
          highestScore := score;
       end;
    end;

      SetLength(lineList, Length(lineList)+1);
      lineList[High( lineList)] :=Point(startPinIndex, endPinIndex);


      DrawLine(pinList[startPinIndex].X,pinList[startPinIndex].Y,pinList[endPinIndex].X, pinList[endPinIndex].Y,startPinIndex) ;

      reduceImageData(pinList[startPinIndex], pinList[endPinIndex]);
      startPinIndex:=endPinIndex;
      ProgressBar1.Position:=ProgressBar1.Position+1;

      Label1.Caption:= Inttostr(muldiv(ProgressBar1.Position, 100, WireCount)) + '%';
      Inc(lineCount);
 end
 else
 begin

 Button2Click(Self);
   
  {   p.Free;
     g.Free;
    SetLength(pinList,0);
    lineCount := 0;
    SetLength(lineList,0);
    SetLength(Data,0);
    Timer1.Enabled:=False;
    Str:='';
    Button2.Enabled:=True;
    }
 end;
end;

procedure TForm1.RadioGroup2Click(Sender: TObject);
begin
   case  RadioGroup2.ItemIndex of
   0:Timer1.Interval:=100;
   1:Timer1.Interval:=50;
   2:Timer1.Interval:=10;
 end;
end;

procedure TForm1.Button8Click(Sender: TObject);
begin
  Timer1.Enabled:=false;

end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
begin
   OpenImage.Picture.Bitmap.Width:=IMG_WIDTH + ScrollBar1.Position;
   OpenImage.Picture.Bitmap.Height:=IMG_HEIGHT + ScrollBar1.Position;

  // Label1.Caption:=IntToStr(DrawImage.Picture.Bitmap.Width)+'x'+IntToStr(DrawImage.Picture.Bitmap.Height);

     OpenImage.Left:=0;
    OpenImage.Top:=0;

  OpenImage.Left:=(ScrollBox1.Width div 2)-(OpenImage.Width div 2);
   OpenImage.Top:=(ScrollBox1.Height div 2)-(OpenImage.Height div 2);

  // OpenImage.Left:=(ScrollBox1.Width div 2)-(OpenImage.Width div 2);
  //  OpenImage.Top:=(ScrollBox1.Height div 2)-(OpenImage.Height div 2);
   Draw(StrToInt(Edit1.text));

 // CenterRadius();
end;

procedure TForm1.Button7Click(Sender: TObject);
var
  jp: TJpegImage;
begin
 if SavePictureDialog1.Execute then
 begin
  jp := TJpegImage.Create;
  try
    with jp do
    begin
      Assign(OpenImage.picture.bitmap);
      SaveToFile(savepicturedialog1.filename)
    end;
  finally
    jp.Free;
  end;
 end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  GrayBitmap.Free;
end;

procedure TForm1.ScrollBox1Resize(Sender: TObject);
begin
   OpenImage.Left:=(ScrollBox1.Width div 2)-(OpenImage.Width div 2);
   OpenImage.Top:=(ScrollBox1.Height div 2)-(OpenImage.Height div 2);
   Shape1.SetBounds(OpenImage.Left+5,OpenImage.Top+5,OpenImage.Width-5,OpenImage.Height-5);
    
end;

procedure TForm1.Button2Click(Sender: TObject);
begin

 if Button2.Caption='Start' then
 begin

   SetLength(LineList,0);
   SetLength(PinList,0);
   SetLength(Data,0);

   PinCount:=StrToInt(Edit1.Text);
   WireCount:=StrToInt(Edit2.Text);
   startPinIndex:=0;
   lineCount:=0;

   IMG_WIDTH:= StrToInt(Edit3.Text);//GrayBitmap.Width;
   IMG_HEIGHT:=StrToInt(Edit4.Text);// GrayBitmap.Height;

   ResizeBitmap(GrayBitmap,IMG_WIDTH,IMG_HEIGHT);

   GeneratePinList(PinCount,IMG_WIDTH-1,IMG_HEIGHT-1);
   GrayBitmap.PixelFormat:=pf32bit;
   GetPixelData(GrayBitmap);

   ProgressBar1.Max:=WireCount;
   ProgressBar1.Position:=0;
   Memo1.Text:='';
   Str:='';


    OpenImage.Picture.Bitmap.Width:=IMG_WIDTH;
    OpenImage.Picture.Bitmap.Height:=IMG_HEIGHT;
    OpenImage.Picture.Bitmap.Canvas.Brush.Color := clWhite;
    OpenImage.Picture.Bitmap.Canvas.Pen.Color:=clBlack;
    OpenImage.Picture.Bitmap.Canvas.FillRect(Rect(0, 0,IMG_WIDTH,IMG_HEIGHT));
    OpenImage.Picture.Bitmap.PixelFormat:=pf32bit;

     g := TGPGraphics.Create(OpenImage.Picture.Bitmap.Canvas.Handle);
     g.SetSmoothingMode(SmoothingModeAntiAlias);
     p := TGPPen.Create(MakeColor(60,0, 0, 0),0.6);


   Shape1.Visible:=false;
    Button4.Enabled:=false;
     Button1.Enabled:=false;
   Button2.Caption:='Stop';
   Timer1.Enabled:=True;
  end
  else
  begin

   Button2.Caption:='Start';
   Timer1.Enabled:=False;
    p.Free;
    g.Free;
    SetLength(pinList,0);
    lineCount := 0;
    SetLength(lineList,0);
    SetLength(Data,0);

    Str:='';
    Button2.Enabled:=True;
    Button4.Enabled:=True;
     Button1.Enabled:=True;
  end;

end;

procedure TForm1.SaveImage1Click(Sender: TObject);
var
  jp: TJpegImage;
begin
 if SavePictureDialog1.Execute then
 begin
  jp := TJpegImage.Create;
  try
    with jp do
    begin
      Assign(OpenImage.picture.bitmap);
      SaveToFile(savepicturedialog1.filename)
    end;
  finally
    jp.Free;
  end;
 end;

end;

procedure TForm1.Button1Click(Sender: TObject);
var
 Picture:TPicture;
 

begin

    Picture:=TPicture.Create;
    try
      Picture.LoadFromFile(OpenPictureDialog1.FileName);
      OpenImage.Picture.Bitmap.Assign(Picture.Graphic);
      OpenImage.Left:=(ScrollBox1.Width div 2)-(OpenImage.Width div 2);
      OpenImage.Top:=(ScrollBox1.Height div 2)-(OpenImage.Height div 2);
      OpenImage.Picture.Bitmap.PixelFormat:=pf24bit;
      Shape1.SetBounds(OpenImage.Left+5,OpenImage.Top+5,OpenImage.Width-5,OpenImage.Height-5);
    



         Shape1.Visible:=True;
         ProgressBar1.Position:=0;
    //  Shape1.Left:=(OpenScrollBox.Width div 2)-(Shape1.Width div 2);
    //  Shape1.Top:=(OpenScrollBox.Height div 2)-(Shape1.Height div 2);

    finally
     Picture.Free;
    end;
  
end;


end.
