/*
* $Id: Import.prg $
*/
/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2012 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Program to view DBF files using standard Browse control
* Miguel Angel Juárez A. - 2009-2012 MigSoft <mig2soft/at/yahoo.com>
*/

#include "oohg.ch"
#include "dbuvar.ch"

PROCEDURE ImportFile()

   IF !Empty( Alias() )
      DECLARE window form_idx

      aTypes := {}
      Aadd( aTypes, {{'Text files (*.txt)', '*.txt'},{'CSV files (*.csv)', '*.csv'}} )
      Aadd( aTypes, {{'DBF files (*.dbf)' , '*.dbf'}} )

      IF !IsWindowDefined(Import)
         LOAD WINDOW Import
         CENTER WINDOW Import
         ACTIVATE WINDOW Import
      ENDIF

      //Ultimo()

   ENDIF

   RETURN

PROCEDURE ImportGetFile()

   Iif ( !Empty( sFile := GetFile( aTypes[Import.RadioGroup_i1.value], 'Select Import files', CurDir(), .T.) ) , Import.text_ii1.Value := sFile[1] , )

   RETURN

   /*
   APPEND FROM <xcFile>
   [FIELDS <idField list>]
   [<scope>] [WHILE <lCondition>] [FOR <lCondition>]
   [SDF | DELIMITED [WITH BLANK | <xcDelimiter>] |
   [VIA <xcDriver>]]
   */

FUNCTION OpenImpFile()

   IF !Empty(Import.text_ii1.Value)
      cFile     := GetName(Import.text_ii1.Value)
      nStrDelim := Import.Combo_ii3.Value
      nFldSepar := Import.Combo_ii2.Value

      aStrDelim := {'"','',"'"}
      aFldSepar := {';',',',':','   ',' '}

      //      If ImpAppend( cFile, aStrDelim[nStrDelim], aFldSepar[nFldSepar] )
      IF Append_Now( cFile, aStrDelim[nStrDelim], aFldSepar[nFldSepar] )
         MsgInfo( "File "+cFile+" successfully imported", "Success" )
      ELSE
         MsgInfo( "File "+cFile+" could not be imported","Failure" )
      ENDIF

   ENDIF

   Import.Release

   Return(Nil)

FUNCTION ImpAppend( cFile, cStrDelim, cFldSepar )

   LOCAL lSucces := .F.

   cStrDelim := Iif(Empty(cStrDelim),cStrDelim := '' ,cStrDelim)
   cFldSepar := Iif(Empty(cFldSepar),cFldSepar := ' ',cFldSepar)

   TRY
      IF Import.RadioGroup_i1.Value == 1    // .txt .csv
         IF  !Empty( cFldSepar ) .AND. Import.Combo_ii2.Value < 4 .AND. Import.Check_1.Value == .F.
            IF ( Alias() )->( Flock() )
               APPEND FROM (cFile) DELIMITED WITH ( { cStrDelim, cFldSepar } )
               ( Alias() )->( dbUnlock() )
               lSucces := .T.
            ENDIF
         ENDIF
         IF Import.Combo_ii2.Value == 4
            IF ( Alias() )->( Flock() )
               APPEND FROM (cFile) DELIMITED WITH TAB
               ( Alias() )->( dbUnlock() )
               lSucces := .T.
            ENDIF
         ENDIF
         IF Import.Combo_ii2.Value == 5
            IF ( Alias() )->( Flock() )
               APPEND FROM (cFile) DELIMITED WITH BLANK
               ( Alias() )->( dbUnlock() )
               lSucces := .T.
            ENDIF
         ENDIF
         IF Import.Combo_ii2.Value == 6
            IF ( Alias() )->( Flock() )
               APPEND FROM (cFile) DELIMITED WITH PIPE
               ( Alias() )->( dbUnlock() )
               lSucces := .T.
            ENDIF
         ENDIF
         IF Import.Check_1.Value == .T.
            IF ( Alias() )->( Flock() )
               APPEND FROM (cFile) SDF
               ( Alias() )->( dbUnlock() )
               lSucces := .T.
            ENDIF
         ENDIF
      ELSE     // .dbf
         IF ( Alias() )->( Flock() )
            APPEND FROM (cFile) WHILE { || App_Progress() }
            ( Alias() )->( dbUnlock() )
            lSucces := .T.
         ENDIF
      ENDIF

   CATCH loError
      lSucces := .F.
   END

   Form_idx.Release

   Return(lSucces)

   /*
   FUNCTION GetName(cFileName)
   Local cTrim  := ALLTRIM(cFileName)
   Local nSlash := MAX(RAT('\', cTrim), AT(':', cTrim))
   Local cName  := IF(EMPTY(nSlash), cTrim, SUBSTR(cTrim, nSlash + 1))

   RETURN( cName )
   */

FUNCTION Append_Now( cFile, cStrDelim, cFldSepar )

   LOCAL lResult := .F.

   DEFINE WINDOW Form_idx AT 274,282 WIDTH 298 HEIGHT 100 ;
         TITLE "Append in progress !!!" ICON "Main1" MODAL NOSIZE ;
         ON INIT lResult := ImpAppend( cFile, cStrDelim, cFldSepar ) ;
         FONT 'Arial' SIZE 09 nosysmenu nomaximize nominimize

      @  6,94 LABEL Label_001 VALUE "Completed " WIDTH 120 HEIGHT 18
      @ 26,19 PROGRESSBAR ProgressBar_1 RANGE 0,100 WIDTH 252 HEIGHT 18 MARQUEE 40

      DEFINE STATUSBAR
         STATUSITEM PadC( cFile, 80 )
      END STATUSBAR

   END WINDOW

   Form_idx.Center
   Form_idx.Activate

   Return( lResult )

   /*
   FUNCTION App_Progress()
   Local nComplete := Max( Min( ( RecNo()/LastRec() ) * 100, 100 ), 0 )
   Local cComplete := Ltrim(Str(nComplete))

   Form_idx.Label_001.Value := "Completed "+ cComplete + "%"
   Form_idx.ProgressBar_1.Value := nComplete

   Return(.T.)
   */

FUNCTION DBF_ANSI2OEM(lOem)

   LOCAL i := 1
   LOCAL aDatos := {}

   IF !Empty( Alias() )
      ( Alias() )->( DBGoTop() )
      DO WHILE !( Alias() )->( EOF() )
         FOR i = 1 to ( Alias() )->( Fcount() )
            Aadd( aDatos, ( Alias() )->( Fieldget(i) ) )
            ( Alias() )->( flock() )
            IF lOem == .T.
               ( Alias() )->( Fieldput( i, iif("CM"$ValType(adatos[i]),WIN_AnsiToOEM(adatos[i]),adatos[i] ) ) )
            ELSE
               ( Alias() )->( Fieldput( i, iif("CM"$ValType(adatos[i]),WIN_OEMToAnsi(adatos[i]),adatos[i] ) ) )
            ENDIF
            ( Alias() )->( DbUnLock() )
         NEXT
         ( Alias() )->( DBSkip() )
         aDatos := {}
      ENDDO
      Actualizar()
   ENDIF

   RETURN
