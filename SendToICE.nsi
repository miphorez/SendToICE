;
;инсталлятор к программе SendToICE

;---------------------
;Включаем необходимые модули

  !include "MUI2.nsh"       				; - это модуль, необходимый для использования нового интерфейса
  !include "Sections.nsh"  				; - модуль для работы с секциями инсталлятора
  !include "InstallOptions.nsh"  				; - модуль для работы с секциями инсталлятора
  !include LogicLib.nsh
  !include "FileFunc.nsh"
  !include "WinMessages.nsh"
  !include "WordFunc.nsh"
;--------------------------------
;Конфигурация                     в этом разделе содержатся главные настройки инсталлятора

  ;Главная
  ;SetCompressor lzma          				; - сжимаем инсталлятор алгоритмом Lzma
  SetDatablockOptimize on     				; - оптимизация блока данных
  Name "«Send Text File To ICE Reader»"			; - название инсталлятора
  OutFile "Install_SendToICE.exe"       			; - выходной файл с инсталлятором после выполнения компиляции
  AllowRootDirInstall false   				; - отменяем возможность установки программы в корень
  AutoCloseWindow false       				; - отмена автозакрытия инсталлятора после выполнения всех действий
  CRCCheck off                				; - отмена проверки контрольной суммы инсталлятора
  SetFont Tahoma 8            				; - основной шрифт инсталлятора - Tahoma размером в 8pt
  WindowIcon off              				; - выключаем иконку у окна инсталлятора
  XPStyle on                  					; - включаем использование стиля XP
  SetOverwrite on             				; - возможность перезаписи файлов включена

  ;Папка для инсталляции по умолчанию
  InstallDir "$PROGRAMFILES\SendToICE\"

;--------------------------------
;Variables
!define TEMP1 $R0 					; временная переменная -  регистр R0

;--------------------------------
;Настройки интерфейса
   !define MUI_ICON "eBooks.ico"              			; - иконка файла - инсталлятора

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_COMPONENTS            		; - страница с выбором компонентов для установки
  !insertmacro MUI_PAGE_DIRECTORY              		; - страница с выбором папки для установки
 
  Page instfiles 
  !insertmacro MUI_UNPAGE_CONFIRM              		; - страница с подтверждением удаления (деинсталлятор)
  !insertmacro MUI_UNPAGE_INSTFILES            		; - страница с подробностями удаления (деинсталлятор)
;--------------------------------
;Языки
 
  !insertmacro MUI_LANGUAGE "Russian"      		; - задаем язык как "русский"


;--------------------------------
;Секции компонентов для установки

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Section "!Программа" Program     			; секция "Программа". Знак "!" означает, что пункт жирным текстом

  SectionIn RO     					; секция только для чтения (не отключить)

  SetOutPath "$INSTDIR"              			; папка для выполнения операций
  File "SendToICE.exe"    		
;  File "eBooks.ico"    		

;Создаем uninstall'ятор и записываем его в папку, куда устанавливаем программу
  WriteUninstaller "$INSTDIR\Uninstall.exe"

;записываем инсталляцию в меню по правой кнопке
WriteRegStr HKLM "Software\Classes\*\Shell\Open with ICE Reader" "" "Открыть через ICE Reader"
WriteRegStr HKLM "Software\Classes\*\Shell\Open with ICE Reader\command" "" '"$INSTDIR\SendToICE.exe" "%1"'

;записываем в реестр для работы штатного uninstaller-а
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

; в этой секции написаны макросы, которые позволяют при наведении на компонент для установки показывать его
; описание

  LangString DESC_Program ${LANG_RUSSIAN} "Файл программы и модули для работы «Считывателя ID пропусков»."

   !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

    !insertmacro MUI_DESCRIPTION_TEXT ${Program} $(DESC_Program)

  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Installer Functions

Function .onInstSuccess
;после инсталляции сделать первый запуск для инициализации реестра
  IfFileExists  $INSTDIR\SendToICE.exe 0 onunitexit 		                 
   StrCpy $2 "$INSTDIR\SendToICE.exe"
   Exec "$2"
   Delete $2

onunitexit:
FunctionEnd


LangString TEXT_IO_TITLE1 ${LANG_ENGLISH} "Копирование файлов"
LangString TEXT_IO_SUBTITLE1 ${LANG_ENGLISH} "Подождите, идет копирование файлов..."

;-------------------------------
;###################################################################
;Uninstaller Section


Section "Uninstall"  ; данная секция необходима для описания деинсталлятора

  ;удаляем все...
  Delete "$INSTDIR\*.*"
  RMDir "$INSTDIR" 


  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\SendToICE"
  DeleteRegKey HKLM "SOFTWARE\Classes\*\Shell\Open with ICE Reader"
SectionEnd
