/*
* $Id: ExeCommon.prg,v 1.2 2014/07/11 19:38:40 migsoft Exp $
*/

#include "oohg.ch"
#include "mpm.ch"

PROCEDURE StartBuild()

   DECLARE WINDOW main
   DECLARE WINDOW MigMess

   Out                   := ''
   main.RichEdit_1.Value := ''
   PRGFILES              := {}
   CFILES                := {}
   LIBFILES              := {}

   PROJECTFOLDER  := AllTrim(main.text_1.Value)
   EXEOUTPUTNAME  := AllTrim(main.text_2.Value)

   WLEVEL         := main.RadioGroup_1.Value
   WITHDEBUG      := main.RadioGroup_2.Value
   WITHGTMODE     := main.RadioGroup_3.Value
   INCREMENTAL    := main.RadioGroup_4.Value
   HBCHOICE       := main.RadioGroup_5.Value

   IF     main.RadioGroup_6.Value = 1
      USERFLAGS      := AllTrim(main.text_24.Value)
      USERCFLAGS     := AllTrim(main.text_12.Value)
      USERLFLAGS     := AllTrim(main.text_13.Value)
   ELSEIF main.RadioGroup_6.Value = 2
      USERFLAGS      := AllTrim(main.text_44.Value)
      USERCFLAGS     := AllTrim(main.text_32.Value)
      USERLFLAGS     := AllTrim(main.text_33.Value)
   ELSEIF main.RadioGroup_6.Value = 3
      USERFLAGS      := AllTrim(main.text_54.Value)
      USERCFLAGS     := AllTrim(main.text_42.Value)
      USERLFLAGS     := AllTrim(main.text_43.Value)
   ELSEIF main.RadioGroup_6.Value = 4
      USERFLAGS      := AllTrim(main.text_64.Value)
      USERCFLAGS     := AllTrim(main.text_52.Value)
      USERLFLAGS     := AllTrim(main.text_53.Value)
   ENDIF

   OBJFOLDER      := UPPER(AllTrim(main.Text_5.Value))
   LIBFOLDER      := UPPER(AllTrim(main.Text_6.Value))
   INCFOLDER      := UPPER(AllTrim(main.Text_7.Value))

   RETURN

PROCEDURE MsgBuild()

   DO EVENTS

   IF Empty ( ProjectName )
      MsgStop('You must save project first')
      BREAK
   ENDIF

   IF Empty ( ProjectFolder ) .Or. Empty ( main.List_1.Item(1) )  .Or. Empty (CCOMPFOLDER) .Or. Empty (MiniGUIFolder) .Or. Empty (HarbourFolder)
      MsgStop ( 'One or more required fields is not complete','')
      BREAK
   ENDIF

   SetCurrentFolder (PROJECTFOLDER)

   cOBJ_DIR := iif(empty(OBJFOLDER),'\'+MyOBJName(),'\'+GetName(OBJFOLDER))

   MakeInclude(MINIGUIFOLDER,Auto_GUI(MINIGUIFOLDER))

   IF INCREMENTAL = 2
      BorraOBJ(PROJECTFOLDER,cOBJ_DIR)
   ENDIF

   IF ( main.RadioGroup_7.Value == 1 ) // EXE
      IF File( GetName(ExeName)+'.exe' )
         IF MsgYesNo('File: '+ GetName(ExeName)+'.exe Already Exist, Rebuild?',"Rebuild Project") == .F.
            BREAK
         ELSE
            cDos1 := '/c Taskkill /f /im '+GetName(ExeName)+'.exe'
            EXECUTE FILE "CMD.EXE" PARAMETERS cDos1 HIDE
            main.RichEdit_1.Value := ''
         ENDIF
      ENDIF
   ENDIF

   PonerEspera('Compiling...')

   FOR i := 1 To main.List_1.ItemCount
      DO EVENTS
      aadd ( PRGFILES , Alltrim(main.List_1.Item(i)) )
   NEXT i

   FOR i := 1 To main.List_1.ItemCount
      DO EVENTS
      aadd ( CFILES , Alltrim(main.List_1.Item(i)) )
   NEXT i

   FOR i := 1 To main.List_2.ItemCount
      DO EVENTS
      aadd ( LIBFILES , Alltrim(main.List_2.Item(i)) )
   NEXT i

   CreateFolder ( PROJECTFOLDER + cOBJ_DIR )

   RETURN

PROCEDURE EndBuild()

   main.Tab_1.value := 7

   IF File(PROJECTFOLDER+'\'+GetName(ExeName)+'.exe') .and. TxtSearch('error') == .F.
      IF MsgYesNo('Execute File: ['+ GetName(ExeName)+'.exe] ?',"Project Build") == .T.
         cursorwait2()
         IF main.Check_1.value == .T.
            IF MsgYesNo('Compress File: ['+ GetName(ExeName)+'.exe] ?',"Compress Exe with UPX") == .T.
               PonerEspera('Compress...')
               ComprimoExe(PROJECTFOLDER,GetName(ExeName))
               QUITarEspera()
            ENDIF
         ENDIF
         EXECUTE FILE PROJECTFOLDER +'\'+GetName(ExeName)
         cursorarrow2()
      ELSE
         main.RichEdit_1.Value := 'File: [' + GetName(ExeName) + '.exe] is OK'
         main.Tab_1.value := 7
         main.RichEdit_1.Setfocus
      ENDIF
      DELETE FILE ( PROJECTFOLDER + '\_Temp.Log' )
   ELSE
      main.RichEdit_1.Setfocus
   ENDIF

   RETURN

FUNCTION WathLibLink(MiniGuiFolder,HBCHOICE)

   LOCAL Out := ""

   IF HBCHOICE = 2               // xHarbour
      IF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\minigui.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\minigui.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + HARBOURFOLDER + If ( Right ( HARBOURFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + HARBOURFOLDER + If ( Right ( HARBOURFOLDER , 1 ) != '\' , '\' , '' )  + 'XLIB\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fivehx.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fivehx.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fivehc.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\xhb\bcc\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\xhb\bcc\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\xhb\bcc\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\xhb\bcc\miniprint.LIB + >> b32.bc' + NewLi
      ENDIF
   ELSE
      IF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\bcc\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\bcc\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\bcc\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\bcc\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hb\bcc\oohg.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hb\bcc\oohg.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hb\bcc\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hb\bcc\miniprint.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fiveh.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fiveh.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\fivehc.LIB + >> b32.bc' + NewLi
      ELSEIF File(MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\minigui.LIB')
         Out := Out + '   echo ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\minigui.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + HARBOURFOLDER + If ( Right ( HARBOURFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\hbprinter.LIB + >> b32.bc' + NewLi
         Out := Out + '   echo ' + HARBOURFOLDER + If ( Right ( HARBOURFOLDER , 1 ) != '\' , '\' , '' )  + 'LIB\miniprint.LIB + >> b32.bc' + NewLi
      ENDIF
   ENDIF

   RETURN( Out )

