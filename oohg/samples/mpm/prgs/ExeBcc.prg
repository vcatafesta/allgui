/*
* $Id: ExeBcc.prg
* (c) migsoft 2013-11-18
*/

#include "oohg.ch"
#include "mpm.ch"

PROCEDURE Build( ProjectName )  // Borland C

   DECLARE WINDOW main
   DECLARE WINDOW MigMess

   StartBuild()

   BCCFOLDER      := AllTrim(main.text_16.Value)
   CCOMPFOLDER    := BCCFOLDER

   IF HBCHOICE = 1
      HARBOURFOLDER  := AllTrim(main.text_20.Value)
      MINIGUIFOLDER  := AllTrim(main.text_23.Value)
   ELSE
      HARBOURFOLDER  := AllTrim(main.text_4 .Value)
      MINIGUIFOLDER  := AllTrim(main.text_21.Value)
   ENDIF

   WATHGUI        := Auto_GUI(MINIGUIFOLDER)

   ExeName := iif(empty(EXEOUTPUTNAME), Left ( Alltrim(main.List_1.Item(1)), Len(Alltrim(main.List_1.Item(1))) - 4 ) , EXEOUTPUTNAME )

   BEGIN SEQUENCE

      MsgBuild()

      INCFOLDER := iif(Empty(INCFOLDER),'',INCFOLDER+' -I')

      Out := Out + 'HARBOUR_EXE = ' + HARBOURFOLDER + If ( Right ( HARBOURFOLDER , 1 ) != '\' , '\' , '' ) + 'BIN\HARBOUR.EXE'  + NewLi
      Out := Out + 'CC = ' + BCCFOLDER + If ( Right ( BCCFOLDER , 1 ) != '\' , '\' , '' ) + 'BIN\BCC32.EXE'  + NewLi
      Out := Out + 'ILINK_EXE = ' + BCCFOLDER + If ( Right ( BCCFOLDER , 1 ) != '\' , '\' , '' ) + 'BIN\ILINK32.EXE'  + NewLi
      Out := Out + 'BRC_EXE = ' + BCCFOLDER + If ( Right ( BCCFOLDER , 1 ) != '\' , '\' , '' ) + 'BIN\BRC32.EXE'  + NewLi
      Out := Out + 'APP_NAME = ' +iif(empty(EXEOUTPUTNAME), GetName(Left ( PRGFILES [1] , Len(PRGFILES [1] ) - 4 ) + '.Exe') + NewLi, EXEOUTPUTNAME+ '.Exe' + NewLi )
      Out := Out + 'RC_FILE = ' + MINIGUIFOLDER + If ( Right ( MINIGUIFOLDER , 1 ) != '\' , '\' , '' ) + 'RESOURCES\oohg.RC'  + NewLi
      Out := Out + 'INCLUDE_DIR = ' + HARBOURFOLDER+'\INCLUDE -I'+INCFOLDER+MINIGUIFOLDER+'\INCLUDE -I'+BCCFOLDER+'\INCLUDE -I'+PROJECTFOLDER + NewLi
      Out := Out + 'CC_LIB_DIR = ' + BCCFOLDER+'\LIB -L'+HARBOURFOLDER+'\LIB -L'+HARBOURFOLDER+'\LIB\WIN\BCC -L'+MINIGUIFOLDER+'\LIB -L'+MINIGUIFOLDER+'\LIB\hb\bcc -L'+MINIGUIFOLDER+'\HARBOUR\LIB -L'+PROJECTFOLDER + NewLi

      IF file(HarbourFolder + '\LIB\tip.lib')
         Out += 'HRB_LIB_DIR = ' + HarbourFolder + '\LIB'  + NewLi
      ELSEIF file(HarbourFolder + '\LIB\hbwin.lib')
         Out += 'HRB_LIB_DIR = ' + HarbourFolder + '\LIB'  + NewLi
      ELSEIF file(HarbourFolder + '\LIB\WIN\bcc\hbwin.lib')
         Out += 'HRB_LIB_DIR = ' + HarbourFolder + '\LIB\WIN\bcc' + NewLi
      ENDIF

      Out := Out + 'USR_LIB_DIR = ' + if( Empty( LIBFOLDER ),NewLi,LIBFOLDER + NewLi )
      Out := Out + 'OBJ_DIR = ' + PROJECTFOLDER + cOBJ_DIR + NewLi
      Out := Out + 'C_DIR = ' + PROJECTFOLDER + cOBJ_DIR + NewLi
      Out := Out + 'USER_FLAGS = ' + iif( empty(USERFLAGS),'',USERFLAGS ) + NewLi

      IF WITHDEBUG = 2
         Out := Out + 'HARBOUR_FLAGS = /i$(INCLUDE_DIR) /n /b '+RetHbLevel()+' $(USER_FLAGS)' + NewLi
      ELSE
         Out := Out + 'HARBOUR_FLAGS = /i$(INCLUDE_DIR) /n '+RetHbLevel()+' $(USER_FLAGS)' + NewLi
      ENDIF

      cFlags :=  iif(empty(USERCFLAGS),' -c -O2 -tW -M ', USERCFLAGS)

      Out := Out + 'COBJFLAGS = '+ cFlags + ' -I$(INCLUDE_DIR) -L$(CC_LIB_DIR)' + NewLi

      Out := Out + NewLi
      Out := Out + '$(APP_NAME) :   $(OBJ_DIR)\' + GetName(Left ( PRGFILES [1] , Len(PRGFILES [1] ) - 4 ))  + '.obj \' + NewLi

      nTotFmgs := 0

      FOR i := 2 TO Len ( PrgFiles )
         DO EVENTS
         IF upper(Right( PRGFILES [i] , 3 )) = 'FMG'
            nTotFmgs := nTotFmgs + 1
         ENDIF
      NEXT

      FOR i := 2 To main.List_1.ItemCount
         IF upper(Right( PRGFILES [i] , 3 )) = 'PRG'
            IF i == main.List_1.ItemCount - nTotFmgs
               Out := Out + '   $(OBJ_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 ))  + '.obj' + NewLi
            ELSE
               Out := Out + '   $(OBJ_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 ))  + '.obj \' + NewLi
            ENDIF
         ELSEIF upper(Right( PRGFILES [i] , 1 )) = 'C'
            IF i == main.List_1.ItemCount - nTotFmgs
               Out := Out + '   $(OBJ_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 ))  + '.obj' + NewLi
            ELSE
               Out := Out + '   $(OBJ_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 ))  + '.obj \' + NewLi
            ENDIF
         ENDIF
      NEXT i

      Out := Out + NewLi

      cFilerc := Left ( PRGFILES [1] , Len(PRGFILES [1] ) - 4 )

      IF Crea_Temp_rc( GetName(cFilerc)  )
         IF WATHGUI = 4
            Out := Out + '   $(BRC_EXE) -d__BORLANDC__ -r -fo _temp.res _temp.rc ' + NewLi
         ELSE
            Out := Out + '   $(BRC_EXE) -d__BORLANDC__ -r -fo' + MiniGuiFolder + '\RESOURCES\_temp.res ' + MiniGuiFolder +'\RESOURCES\_temp.rc ' + NewLi
         ENDIF
      ENDIF

      FOR i := 1 To Len ( PrgFiles ) - nTotFmgs
         IF upper(Right( PRGFILES [i] , 3 )) = 'PRG'
            Out := Out + '   echo $(OBJ_DIR)\' +  GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 )) +  '.obj + >' + if(i>1,'>','') +'b32.bc ' + NewLi
         ELSEIF upper(Right( PRGFILES [i] , 1 )) = 'C'
            Out := Out + '   echo $(OBJ_DIR)\' +  GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 )) +  '.obj + >' + if(i>1,'>','') +'b32.bc ' + NewLi
         ENDIF
      NEXT i

      IF File(MiniGuiFolder+'\LIB\oohg.lib')
         cLib_ooHG      :='\LIB\oohg.lib'
         cLib_Hbprinter :='\LIB\hbprinter.lib'
         cLib_Miniprint :='\LIB\miniprint.lib'
      ELSEIF File(MiniGuiFolder+'\LIB\hb\bcc\oohg.lib')  .AND.HBCHOICE = 1
         cLib_ooHG      :='\LIB\hb\bcc\oohg.lib'
         cLib_Hbprinter :='\LIB\hb\bcc\hbprinter.lib'
         cLib_Miniprint :='\LIB\hb\bcc\miniprint.lib'
      ELSEIF File(MiniGuiFolder+'\LIB\xhb\bcc\oohg.lib') .AND.HBCHOICE = 2
         cLib_ooHG      :='\LIB\xhb\bcc\oohg.lib'
         cLib_Hbprinter :='\LIB\xhb\bcc\hbprinter.lib'
         cLib_Miniprint :='\LIB\xhb\bcc\miniprint.lib'
      ELSEIF File(MiniGuiFolder+'\LIB\fiveh.lib')        .AND.HBCHOICE = 1
         cLib_Five      :='\LIB\fiveh.lib'
         cLib_Five2     :='\LIB\fivehc.lib'
      ELSEIF File(MiniGuiFolder+'\LIB\fivehx.lib')       .AND.HBCHOICE = 2
         cLib_Five      :='\LIB\fivexh.lib'
         cLib_Five2     :='\LIB\fivehc.lib'
      ELSEIF File(MiniGuiFolder+'\LIB\oohg.lib')
         cLib_ooHG      :='\LIB\oohg.lib'
         cLib_Hbprinter :='\LIB\hbprinter.lib'
         cLib_Miniprint :='\LIB\miniprint.lib'
      ENDIF

      Out := Out + '   echo ' + BCCFOLDER + If ( Right ( BCCFOLDER , 1 ) != '\' , '\' , '' ) + 'LIB\c0w32.obj, + >> b32.bc ' + NewLi

      Out := Out + '   echo $(APP_NAME),' + Left ( PRGFILES [1] , Len(PRGFILES [1] ) - 4 ) + '.map, + >> b32.bc' + NewLi

      Out := Out + WathLibLink(MiniGuiFolder,HBCHOICE) // GUI Libs

      IF WITHGTMODE = 1
         Out := Out + '   echo $(HRB_LIB_DIR)\gtgui.lib + >> b32.bc' + NewLi
      ENDIF
      IF WITHGTMODE = 2
         Out := Out + '   echo $(HRB_LIB_DIR)\gtwin.lib + >> b32.bc' + NewLi
      ENDIF
      IF WITHGTMODE = 3
         Out := Out + '   echo $(HRB_LIB_DIR)\gtwin.lib + >> b32.bc' + NewLi
         Out := Out + '   echo $(HRB_LIB_DIR)\gtgui.lib + >> b32.bc' + NewLi
      ENDIF

      IF HBCHOICE = 1   // Harbour
         Out   := Out + HbLibs(HARBOURFOLDER,1,2)  // Harbour - Borland
      ELSE
         Out   := Out + HbLibs(HARBOURFOLDER,2,2)  // xHarbour - Borland
      ENDIF

      FOR i := 1 To Len ( LIBFILES )
         DO EVENTS
         Out := Out +'   echo ' + Left ( LIBFILES [i] , Len(LIBFILES [i] ) - 4 ) + '.lib + >>' + 'b32.bc ' + NewLi
      NEXT i

      Out := Out + '   echo '+BCCFOLDER+'LIB\cw32.lib + >> b32.bc' + NewLi
      Out := Out + '   echo '+BCCFOLDER+'LIB\import32.lib, >> b32.bc' + NewLi

      IF WATHGUI = 4
         Out += '   echo _temp.res >> b32.bc' + NewLi
      ELSE
         Out += '   echo ' + MiniGuiFolder +'\resources\_temp.res >> b32.bc' + NewLi
      ENDIF

      IF WITHDEBUG = 2
         cLFlags :=iif(empty(USERLFLAGS),' -Gn -Tpe -ap ', USERLFLAGS)
         Out := Out + '   $(ILINK_EXE) '+ cLFlags +' -L$(CC_LIB_DIR) @b32.bc' + NewLi
      ELSE
         cLFlags :=iif(empty(USERLFLAGS),' -Gn -Tpe -aa ', USERLFLAGS)
         Out := Out + '   $(ILINK_EXE) '+ cLFlags +' -L$(CC_LIB_DIR) @b32.bc' + NewLi
      ENDIF

      Out := Out + NewLi

      FOR i := 1 To Len ( PrgFiles ) - nTotFmgs
         DO EVENTS
         IF upper(Right( PRGFILES [i] , 3 )) = 'PRG'
            Out := Out + NewLi
            Out := Out + '$(C_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 )) + '.c : ' + Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 ) + '.Prg' + NewLi
            Out := Out + '   $(HARBOUR_EXE) $(HARBOUR_FLAGS) $** -o$@'  + NewLi
            Out := Out + NewLi
            Out := Out + '$(OBJ_DIR)\'  + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 )) + '.obj : $(C_DIR)\' +  GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 4 )) + '.c'  + NewLi
            Out := Out + '   $(CC) $(COBJFLAGS) -o$@ $**' + NewLi
         ELSEIF upper(Right( PRGFILES [i] , 1 )) = 'C'
            Out := Out + NewLi
            Out := Out + '$(C_DIR)\' + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 )) + '.c : ' + Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 ) + '.c' + NewLi

            Out := Out + NewLi
            Out := Out + '$(OBJ_DIR)\'  + GetName(Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 )) + '.obj : ' +  Left ( PRGFILES [i] , Len(PRGFILES [i] ) - 2 ) + '.c'  + NewLi
            Out := Out + '   $(CC) $(COBJFLAGS) -o$@ $**' + NewLi
         ENDIF
      NEXT i

      Memowrit ( PROJECTFOLDER + '\_Temp.Bc' , Out )

      MakeName    := BCCFOLDER + '\BIN\MAKE.EXE'
      ParamString := '/f' + PROJECTFOLDER + '\_Temp.Bc' + ' 1>' + PROJECTFOLDER + '\_Temp.Log 2>&1'

      Memowrit ( PROJECTFOLDER + If ( Right ( PROJECTFOLDER , 1 ) != '\' , '\' , '' ) + ;
         '_Build.Bat' , '@ECHO OFF' + NewLi + MakeName + ' ' + ParamString + ;
         NewLi + 'Echo End > ' + PROJECTFOLDER + If ( Right ( PROJECTFOLDER , 1 ) != '\' , '\' , '' ) + ;
         'End.Txt' + NewLi )

      Procesando(1)
      Processing  := .T.

      main.RichEdit_1.Value := ''

      CorreBuildBat()

   END SEQUENCE

   QuitarEspera()

   EndBuild()

   Procesando(2)

   RETURN
