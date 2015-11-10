
unit frmToICE;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls,
  Registry, ClipBrd, ShellAPI, TlHelp32, SendKey, RusClipboard;

const
     REESTR_KEY_INSTALL = '\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\ICE Book Reader Professional Russian_is1';
     REESTR_INSTALL_PAPH = 'Inno Setup: App Path';
     PROG_NAME = 'ICEReaderRus.exe';
const
  ClassNameLen = 512;

type
  Tfrm_toICE = class(TForm)
    TreeWindows: TTreeView;
    ListParams: TListView;
  private
    procedure ClearParamList;
    procedure FillWindowList(PID: Cardinal);
    function GetChildClassWnd(ParentWnd, ClassWnd: string): HWND;
    function GetChildTextClassWnd(TextWnd, ParentWnd,
      ClassWnd: string): HWND;
    { Private declarations }
  public
    { Public declarations }
    procedure FillProcessList;
    function GetClassWnd(ClassWnd: string): HWND;
  end;

procedure StartProgram;

var
  frm_toICE: Tfrm_toICE;

implementation

{$R *.dfm}
var
   ICEpid:cardinal;
   ICEhwnd:HWND;

function SlashSep(Path, FName: string): string;
begin
 if Path[Length(Path)] <> '\' then
  Result := Path + '\' + FName
 else Result := Path + FName;
end;

function GetProgPathToProgram:string;
var Reg: TRegistry;
begin
result:='';
    Reg:= TRegistry.Create;
    Reg.RootKey:= HKEY_LOCAL_MACHINE;
    if not Reg.KeyExists(REESTR_KEY_INSTALL) then begin
      Reg.CloseKey;
      Reg.Free;
      exit;
    end;
    Reg.OpenKey(REESTR_KEY_INSTALL,false);
    result:= SlashSep(Reg.ReadString(REESTR_INSTALL_PAPH),PROG_NAME);
    Reg.Free;
end;

procedure StartProgram;
var
   FileName:string;
   iHWND:HWND;
   pPoint: TPoint;
   WindowInfo: TWindowInfo;
   hPointWnd,hTimer: HWND;
   cnt: integer;
begin
   //проверим установлен ли ICE Reader
   FileName:= GetProgPathToProgram;
   if FileName='' then begin
             MessageBox(Application.Handle, 'Программа ICE Reader не установлена!'+#13+
             'Работа программы SendToICE будет прервана.',
             'Внимание!',MB_ICONSTOP);
             Exit;
   end;
   if not FileExists(ParamStr(1)) then begin
             MessageBox(Application.Handle, PAnsiChar('Файл книги не найден'+#13+#10+ParamStr(1)+#13+
             'Работа программы SendToICE будет прервана.'),
             'Внимание!',MB_ICONSTOP);
             Exit;
   end;
   //занесем в клипборд полный путь к файлу
   ClipBoard.Open;
   ClipBoard.Clear;
   ClipBoard.AsText:= ParamStr(1);
   ClipBoard.Close;

//Создаем пустое события для реализации задержки
hTimer:=CreateEvent(nil, true, false, nil);
frm_toICE:= Tfrm_toICE.Create(Application);

        //проверить не запущена ли она уже?
        frm_toICE.FillProcessList;
        if ICEpid=0 then begin
            ShellExecute(0, nil, PChar(FileName), '', nil, SW_NORMAL);
        end  else begin
         //если запущена посмотреть не свернута ли она
         ICEhwnd:= frm_toICE.GetClassWnd('(TApplication)');
         iHWND:= frm_toICE.GetClassWnd('(TAA_Main)');
         if iHWND=0  then begin
            ShowWindow(ICEhwnd, SW_MAXIMIZE);
         end  else begin
            ShowWindow(ICEhwnd, SW_SHOWMAXIMIZED);
            SetForegroundWindow(ICEhwnd);
         end;
        end;

   //ищем подтверждения, что программа запущена - основное окно
   cnt:= 0;
   repeat
   WaitForSingleObject(hTimer,1000);
   frm_toICE.FillProcessList;
   iHWND:= frm_toICE.GetClassWnd('(TAA_Main)');
   inc(cnt);
   until (iHWND<>0)or(cnt = 10);


        //проверить, нет ли уже запущенной библиотеки
         if frm_toICE.GetClassWnd('(TAA_Library)')=0  then begin
            if iHWND = 0 then begin
                MessageBox(Application.Handle, 'Программа ICE Reader не запущена!'+#13+
                'Работа программы SendToICE будет прервана.',
                'Внимание!',MB_ICONSTOP);
                Exit;
            end;
            SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
            iHWND:= frm_toICE.GetChildClassWnd('(TAA_Main)','(TToolBar)');
            //нашли толбар основного окна - нажать кнопку Библиотеки
            if iHWND<>0 then begin
               //возьмем координаты
               GetWindowInfo(iHWND, WindowInfo);
               pPoint.X:= WindowInfo.rcWindow.Left+10;
               pPoint.Y:= WindowInfo.rcWindow.Top+10;
//               SetCursorPos(pPoint.X,pPoint.Y);
               hPointWnd := WindowFromPoint(pPoint);
               SendMessage(hPointWnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELONG(0, 0));
               SendMessage(hPointWnd, WM_LBUTTONUP, 0, MAKELONG(0, 0));
            end;
         end;

   //ищем подтверждения, что библиотека запущена
   cnt:=0;
   repeat
   WaitForSingleObject(hTimer,1000);
   frm_toICE.FillProcessList;
   iHWND:= frm_toICE.GetClassWnd('(TAA_Library)');
   inc(cnt);
   until (iHWND<>0)or(cnt = 10);

//            if iHWND<>0 then begin
//               //возьмем координаты
//               GetWindowInfo(iHWND, WindowInfo);
//               pPoint.X:= WindowInfo.rcWindow.Left+20;
//               pPoint.Y:= WindowInfo.rcWindow.Top+30;
//               SetCursorPos(pPoint.X,pPoint.Y);
//               hPointWnd := WindowFromPoint(pPoint);
//               SendMessage(hPointWnd, WM_LBUTTONDOWN, MK_LBUTTON, MAKELONG(0, 0));
//               SendMessage(hPointWnd, WM_LBUTTONUP, 0, MAKELONG(0, 0));
//            end;

         //вызываем у библиотеки окно ввода нового имени книги для добавления
         if frm_toICE.GetClassWnd('(TAA_OpenFile)')=0 then begin
            if iHWND = 0 then begin
                MessageBox(Application.Handle, 'Окно библиотеки ICE Reader не открыто!'+#13+
                'Работа программы SendToICE будет прервана.',
                'Внимание!',MB_ICONSTOP);
                Exit;
            end;
            iHWND:= frm_toICE.GetChildClassWnd('(TAA_Library)','(TDrawGrid)');
            if iHWND<>0 then begin
               //возьмем координаты
               GetWindowInfo(iHWND, WindowInfo);
               pPoint.X:= WindowInfo.rcWindow.Left+30;
               pPoint.Y:= WindowInfo.rcWindow.Top+30;
               hPointWnd := WindowFromPoint(pPoint);
               SendMessage(hPointWnd, WM_LBUTTONDOWN, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               SendMessage(hPointWnd, WM_LBUTTONUP, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               //выбрали Библиотекy - нажать горячую кнопку вызов окна выбора новой книги  (Alt+F)
               iHWND:= frm_toICE.GetClassWnd('(TAA_Library)');
               SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
               PlayKeys(Chr(vk_menu)+#0+'F'+#0);
            end;
         end;

   //ищем подтверждения, что окно для добавления книги запущено
   cnt:=0;
   repeat
   WaitForSingleObject(hTimer,1000);
   frm_toICE.FillProcessList;
   iHWND:= frm_toICE.GetClassWnd('(TAA_OpenFile)');
   inc(cnt);
   until (iHWND<>0)or(cnt = 5);
//Exit;
// frm_toICE.TreeWindows.SaveToFile('ProcessList.txt');
//MessageBox(Application.Handle,'Yes!!!', 'Попался!',MB_OK);Exit;

            if iHWND = 0 then begin
                MessageBox(Application.Handle, 'Окно ввода новой книги в библиотеку ICE Reader не открыто!'+#13+
                'Работа программы SendToICE будет прервана.',
                'Внимание!',MB_ICONSTOP);
                Exit;
            end;
            //вводим из буфера обмена имя книги в поле ввода
            iHWND:= frm_toICE.GetChildClassWnd('(TAA_OpenFile)','(TTntEdit.UnicodeClass)');
            if iHWND<>0 then begin
               //возьмем координаты
               GetWindowInfo(iHWND, WindowInfo);
               pPoint.X:= WindowInfo.rcWindow.Left+10;
               pPoint.Y:= WindowInfo.rcWindow.Top+10;
               hPointWnd := WindowFromPoint(pPoint);
               SendMessage(hPointWnd, WM_LBUTTONDOWN, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               SendMessage(hPointWnd, WM_LBUTTONUP, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               iHWND:= frm_toICE.GetClassWnd('(TAA_OpenFile)');
               SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
               PlayKeys(Chr(vk_control)+#0+'V'+#0);
            end;
 
            //нажимаем кнопку ОК
            iHWND:= frm_toICE.GetChildTextClassWnd('&OK','(TAA_OpenFile)','(TButton)');
            if iHWND<>0 then begin
               //возьмем координаты
               GetWindowInfo(iHWND, WindowInfo);
               pPoint.X:= WindowInfo.rcWindow.Left+10;
               pPoint.Y:= WindowInfo.rcWindow.Top+10;
               SetCursorPos(pPoint.X,pPoint.Y);
               hPointWnd := WindowFromPoint(pPoint);
               SendMessage(hPointWnd, WM_LBUTTONDOWN, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               SendMessage(hPointWnd, WM_LBUTTONUP, MK_LBUTTON,MAKELONG(pPoint.X,pPoint.Y));
               iHWND:= frm_toICE.GetClassWnd('(TAA_OpenFile)');
               SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
               PlayKeys(' '+#0);
            end;

   //ищем подтверждения, что книга найдена и закодирована
   cnt:= 0;
   repeat
   WaitForSingleObject(hTimer,1000);
   frm_toICE.FillProcessList;
   iHWND:= frm_toICE.GetClassWnd('(TAA_Encode)');
   inc(cnt);
   until (iHWND<>0)or(cnt = 40);

            //подтверждаем добавление книги в библиотеку
            if iHWND<>0 then begin
               SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
               PlayKeys(' '+#0);
            end else begin
                MessageBox(Application.Handle, 'Ошибка добавления книги в библиотеку ICE Reader!'+#13+
                'Работа программы SendToICE будет прервана.',
                'Внимание!',MB_ICONSTOP);
                Exit;
            end;

   //ищем подтверждения, что книга закодирована (прогресса нет)
   repeat
   WaitForSingleObject(hTimer,1000);
   frm_toICE.FillProcessList;
   iHWND:= frm_toICE.GetClassWnd('(TAA_Progress)');
   until iHWND=0;
           
               //выбрали Библиотекy - нажать горячую кнопку- вверх списка и ввод
               iHWND:= frm_toICE.GetClassWnd('(TAA_Library)');
               SendMessage(iHWND,  WM_SYSCOMMAND,  SC_HOTKEY,  iHWND);
               PlayKeys(Chr(vk_control)+#0+Chr(vk_home)+#0);
               PlayKeys(StrToKeys(chr(vk_return)));
end;

function Tfrm_toICE.GetChildTextClassWnd(TextWnd,ParentWnd,ClassWnd:string):HWND;
var iNode: TTreeNode;
     yes:boolean;
begin
result:= 0;
yes:=false;
iNode:= TreeWindows.Items[0];
   while Assigned(iNode) do begin
    if Pos(ParentWnd,iNode.Text)<>0 then begin yes:=true; end;
    if (Pos(ClassWnd,iNode.Text)<>0)and(Pos(TextWnd,iNode.Text)<>0)and yes then begin result:=HWND(iNode.Data); break; end;
    iNode := iNode.GetNext;
   end;
end;

function Tfrm_toICE.GetChildClassWnd(ParentWnd,ClassWnd:string):HWND;
var iNode: TTreeNode;
     yes:boolean;
begin
result:= 0;
yes:=false;
iNode:= TreeWindows.Items[0];
   while Assigned(iNode) do begin
    if Pos(ParentWnd,iNode.Text)<>0 then begin yes:=true; end;
    if (Pos(ClassWnd,iNode.Text)<>0)and yes then begin result:=HWND(iNode.Data); break; end;
    iNode := iNode.GetNext;
   end;
end;

function Tfrm_toICE.GetClassWnd(ClassWnd:string):HWND;
var iNode: TTreeNode;
begin
result:= 0;
iNode:= TreeWindows.Items[0];
   while Assigned(iNode) do begin
    if Pos(ClassWnd,iNode.Text)<>0 then begin result:=HWND(iNode.Data); break; end;
    iNode := iNode.GetNext;
   end;
end;

procedure Tfrm_toICE.ClearParamList;
var
  I: Integer;
begin
  for I := 0 to ListParams.Items.Count - 1 do
    ListParams.Items[I].SubItems[0] := '';
  ListParams.Visible := True;
end;

function EnumWindowsProc(Wnd: HWnd; ParentNode: TTreeNode): Bool; stdcall;
var
  Text: string;
  TextLen: Integer;
  ClassName: array[0..ClassNameLen - 1] of Char;
  Node: TTreeNode;
  NodeName: string;
begin
  Result := True;
  // Функция EnumChildWindows возвращает список
  // не только прямых потомков окна, но и потомков его
  // потомков, поэтому необходимо отсеять все те окна,
  // которые не являются прямыми потомками данного
  if Assigned(ParentNode) and
    (THandle(ParentNode.Data) <> GetAncestor(Wnd, GA_PARENT)) then Exit;
  TextLen := GetWindowTextLength(Wnd);
  SetLength(Text, TextLen);
  if TextLen > 0 then
    GetWindowText(Wnd, PChar(Text), TextLen + 1);
  if TextLen > 100 then
    Text := Copy(Text, 1, 100) + ' ...';
  GetClassName(Wnd, ClassName, ClassNameLen);
  ClassName[ClassNameLen - 1] := #0;
  if Text = '' then
    NodeName := 'Без названия (' + ClassName + ')'
  else
    NodeName := Text + ' (' + ClassName + ')';
  NodeName := '$' + IntToHex(Wnd, 8) + ' ' + NodeName;
  Node := frm_toICE.TreeWindows.Items.AddChild(ParentNode, NodeName);
  Node.Data := Pointer(Wnd);
  EnumChildWindows(Wnd, @EnumWindowsProc, LParam(Node));
end;

function EnumTopWindowsProc(Wnd: HWnd; PIDNeeded: Cardinal): Bool; stdcall;
var
  Text: string;
  TextLen: Integer;
  ClassName: array[0..ClassNameLen - 1] of Char;
  Node: TTreeNode;
  NodeName: string;
  WndPID: Cardinal;
begin
  Result := True;
  // Здесь отсеиваются окна, которые не принадлежат
  // выбранному процессу
  GetWindowThreadProcessID(Wnd, @WndPID);
  if (WndPID = PIDNeeded)and(IsWindowVisible(Wnd)) then begin
    TextLen := GetWindowTextLength(Wnd);
    SetLength(Text, TextLen);
    if TextLen > 0 then
      GetWindowText(Wnd, PChar(Text), TextLen + 1);
    if TextLen > 100 then
      Text := Copy(Text, 1, 100) + ' ...';
    GetClassName(Wnd, ClassName, ClassNameLen);
    ClassName[ClassNameLen - 1] := #0;
    if Text = '' then
      NodeName := 'Без названия (' + ClassName + ')'
    else
      NodeName := Text + ' (' + ClassName + ')';
    NodeName := '$' + IntToHex(Wnd, 8) + ' ' + NodeName;
    Node := frm_toICE.TreeWindows.Items.AddChild(nil, NodeName);
    Node.Data := Pointer(Wnd);
    EnumChildWindows(Wnd, @EnumWindowsProc, LParam(Node));
  end;
end;

procedure Tfrm_toICE.FillWindowList(PID: Cardinal);
begin
  if PID = 0 then Exit;
  EnumWindows(@EnumTopWindowsProc, PID);
end;

procedure Tfrm_toICE.FillProcessList;
var
  SnapProc: THandle;
  ProcEntry: TProcessEntry32;
begin
  ICEpid:= 0;
  SnapProc := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if SnapProc <> INVALID_HANDLE_VALUE then
  try
    ProcEntry.dwSize := SizeOf(TProcessEntry32);
    if Process32First(SnapProc, ProcEntry) then
      repeat
        if ProcEntry.szExeFile = 'ICEReaderRus.exe' then begin
           ICEpid:= ProcEntry.th32ProcessID;
        end;
      until not Process32Next(SnapProc, ProcEntry);
  finally
    CloseHandle(SnapProc);
  end;

  TreeWindows.Items.Clear;
  if ICEpid<>0 then begin
  ClearParamList;
  FillWindowList(ICEpid);
  end;
end;

end.
