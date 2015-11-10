;
;����������� � ��������� SendToICE

;---------------------
;�������� ����������� ������

  !include "MUI2.nsh"       				; - ��� ������, ����������� ��� ������������� ������ ����������
  !include "Sections.nsh"  				; - ������ ��� ������ � �������� ������������
  !include "InstallOptions.nsh"  				; - ������ ��� ������ � �������� ������������
  !include LogicLib.nsh
  !include "FileFunc.nsh"
  !include "WinMessages.nsh"
  !include "WordFunc.nsh"
;--------------------------------
;������������                     � ���� ������� ���������� ������� ��������� ������������

  ;�������
  ;SetCompressor lzma          				; - ������� ����������� ���������� Lzma
  SetDatablockOptimize on     				; - ����������� ����� ������
  Name "�Send Text File To ICE Reader�"			; - �������� ������������
  OutFile "Install_SendToICE.exe"       			; - �������� ���� � ������������� ����� ���������� ����������
  AllowRootDirInstall false   				; - �������� ����������� ��������� ��������� � ������
  AutoCloseWindow false       				; - ������ ������������ ������������ ����� ���������� ���� ��������
  CRCCheck off                				; - ������ �������� ����������� ����� ������������
  SetFont Tahoma 8            				; - �������� ����� ������������ - Tahoma �������� � 8pt
  WindowIcon off              				; - ��������� ������ � ���� ������������
  XPStyle on                  					; - �������� ������������� ����� XP
  SetOverwrite on             				; - ����������� ���������� ������ ��������

  ;����� ��� ����������� �� ���������
  InstallDir "$PROGRAMFILES\SendToICE\"

;--------------------------------
;Variables
!define TEMP1 $R0 					; ��������� ���������� -  ������� R0

;--------------------------------
;��������� ����������
   !define MUI_ICON "eBooks.ico"              			; - ������ ����� - ������������

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_COMPONENTS            		; - �������� � ������� ����������� ��� ���������
  !insertmacro MUI_PAGE_DIRECTORY              		; - �������� � ������� ����� ��� ���������
 
  Page instfiles 
  !insertmacro MUI_UNPAGE_CONFIRM              		; - �������� � �������������� �������� (�������������)
  !insertmacro MUI_UNPAGE_INSTFILES            		; - �������� � ������������� �������� (�������������)
;--------------------------------
;�����
 
  !insertmacro MUI_LANGUAGE "Russian"      		; - ������ ���� ��� "�������"


;--------------------------------
;������ ����������� ��� ���������

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Section "!���������" Program     			; ������ "���������". ���� "!" ��������, ��� ����� ������ �������

  SectionIn RO     					; ������ ������ ��� ������ (�� ���������)

  SetOutPath "$INSTDIR"              			; ����� ��� ���������� ��������
  File "SendToICE.exe"    		
;  File "eBooks.ico"    		

;������� uninstall'���� � ���������� ��� � �����, ���� ������������� ���������
  WriteUninstaller "$INSTDIR\Uninstall.exe"

;���������� ����������� � ���� �� ������ ������
WriteRegStr HKLM "Software\Classes\*\Shell\Open with ICE Reader" "" "������� ����� ICE Reader"
WriteRegStr HKLM "Software\Classes\*\Shell\Open with ICE Reader\command" "" '"$INSTDIR\SendToICE.exe" "%1"'

;���������� � ������ ��� ������ �������� uninstaller-�
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "DisplayName" "Send Text File To ICE Reader"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "UninstallString" "$INSTDIR\Uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "InstallLocation" "$INSTDIR"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "DisplayIcon" "$INSTDIR\SendToICE.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "Publisher" ""
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "NoModify" 0x00000001
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "NoRepair" 0x00000001
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE" "URLInfoAbout" ""

SectionEnd       

;--------------------------------
;Descriptions

; � ���� ������ �������� �������, ������� ��������� ��� ��������� �� ��������� ��� ��������� ���������� ���
; ��������

  LangString DESC_Program ${LANG_RUSSIAN} "���� ��������� � ������ ��� ������ ������������ ID ���������."

   !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

    !insertmacro MUI_DESCRIPTION_TEXT ${Program} $(DESC_Program)

  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Installer Functions

Function .onInstSuccess
;����� ����������� ������� ������ ������ ��� ������������� �������
  IfFileExists  $INSTDIR\SendToICE.exe 0 onunitexit 		                 
   StrCpy $2 "$INSTDIR\SendToICE.exe"
   Exec "$2"
   Delete $2

onunitexit:
FunctionEnd


LangString TEXT_IO_TITLE1 ${LANG_ENGLISH} "����������� ������"
LangString TEXT_IO_SUBTITLE1 ${LANG_ENGLISH} "���������, ���� ����������� ������..."

;-------------------------------
;###################################################################
;Uninstaller Section


Section "Uninstall"  ; ������ ������ ���������� ��� �������� ��������������

  ;������� ���...
  Delete "$INSTDIR\*.*"
  RMDir "$INSTDIR" 


  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE"
  DeleteRegKey HKLM "SOFTWARE\Classes\*\Shell\Open with ICE Reader"
SectionEnd
