/*
* $Id: mybrowse.prg,v 1.4 2017/08/25 19:28:46 fyurisich Exp $
*/
/*
* This demo shows how to use BROWSE.
* Copyright (c)2007-2017 MigSoft <migsoft/at/oohg.org>
*/

#include "oohg.ch"

FUNCTION Main()

   LOCAL cBaseFolder, aTypes, aNewFiles
   LOCAL nCamp, aEst, aNomb, aJust, aLong, i

   HB_LANGSELECT( "EN" )
   SET CENTURY ON
   SET EPOCH TO YEAR(DATE())-20
   SET DATE TO BRITISH

   cBaseFolder := GetStartupFolder()

   aTypes      := { {'Database files (*.dbf)', '*.dbf'} }
   aNewFiles   := GetFile( aTypes, 'Select database files', cBaseFolder, TRUE )

   IF !Empty(aNewFiles)

      USE (aNewFiles[1]) Shared New

      nCamp := Fcount()
      aEst  := DBstruct()

      aNomb := {'iif(deleted(),0,1)'} ; aJust := {0} ; aLong := {0}

      FOR i := 1 to nCamp
         aadd(aNomb,aEst[i,1])
         aadd(aJust,LtoN(aEst[i,2]=='N'))
         aadd(aLong,Max(100,Min(160,aEst[i,3]*14)))
      NEXT

      CreaBrowse( Alias(), aNomb, aLong, aJust )

   ENDIF

   RETURN NIL

FUNCTION CreaBrowse( cBase, aNomb, aLong, aJust )

   LOCAL nAltoPantalla  := GetDesktopHeight() + GetTitleHeight() + GetBorderHeight()
   LOCAL nAnchoPantalla := GetDesktopWidth()
   LOCAL nRow           := nAltoPantalla  * 0.10
   LOCAL nCol           := nAnchoPantalla * 0.10
   LOCAL nWidth         := nAnchoPantalla * 0.95
   LOCAL nHeight        := nAltoPantalla  * 0.85
   LOCAL aHdr           := aClone(aNomb)
   LOCAL aCabImg        := aClone(VerHeadIcon())

   aHdr[1] := Nil

   DEFINE WINDOW oWndBase AT nRow , nCol OBJ oWndBase;
         WIDTH nWidth HEIGHT nHeight ;
         TITLE "(c)2009-2017 MigSoft - MyBrowse" ;
         ICON "main" ;
         MAIN ;
         ON SIZE Adjust() ON MAXIMIZE Adjust()

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 90,32 FONT "Arial" SIZE 9 FLAT RIGHTTEXT
         BUTTON Cerrar    CAPTION "Cerrar"    PICTURE "MINIGUI_EDIT_CLOSE"  ACTION oWndBase.Release                    AUTOSIZE
         BUTTON Nuevo     CAPTION "Nuevo"     PICTURE "MINIGUI_EDIT_NEW"    ACTION Append()                            AUTOSIZE
         BUTTON Modificar CAPTION "Modificar" PICTURE "MINIGUI_EDIT_EDIT"   ACTION Edit()                              AUTOSIZE
         BUTTON Eliminar  CAPTION "Eliminar"  PICTURE "MINIGUI_EDIT_DELETE" ACTION DeleteRecall()                      AUTOSIZE
         BUTTON Buscar    CAPTION "Buscar"    PICTURE "MINIGUI_EDIT_FIND"   ACTION MsgInfo( "My Find routine", cBase ) AUTOSIZE
         BUTTON Imprimir  CAPTION "Imprimir"  PICTURE "MINIGUI_EDIT_PRINT"  ACTION printlist(cBase, aNomb, aLong)      AUTOSIZE
      END TOOLBAR

      IF !IsControlDefined(Browse_1,oWndBase)

         @ 45,20 BROWSE Browse_1               ;
            OF oWndBase                        ;
            WIDTH  oWndBase:Clientwidth  - 40  ;
            HEIGHT oWndBase:Clientheight - 95  ;
            HEADERS aHdr                       ;
            WIDTHS aLong                       ;
            WORKAREA &( Alias() )              ;
            FIELDS aNomb                       ;
            VALUE 0                            ;
            FONT "MS Sans Serif" SIZE 8        ;
            TOOLTIP ""                         ;
            IMAGE { "br_no", "br_ok" }         ;
            JUSTIFY aJust                      ;
            LOCK                               ;
            EDIT                               ;
            INPLACE                            ;
            DELETE                             ;
            ON HEADCLICK Nil                   ;
            HEADERIMAGES aCabImg               ;
            FULLMOVE                           ;
            DOUBLEBUFFER
      ENDIF

   END WINDOW

   oWndBase.Center
   oWndBase.Activate

   RETURN NIL

FUNCTION VerHeadIcon()

   LOCAL aName     := {}, cType, n
   LOCAL aHeadIcon := {"hdel"}

   FOR n := 1 to FCount()
      aadd( aName, Fieldname(n) )
      cType := ValType( &(aName[n]) )
      SWITCH cType
      CASE 'L'
         aadd(aHeadIcon,"hlogic")
         EXIT
      CASE 'D'
         aadd(aHeadIcon,"hfech")
         EXIT
      CASE 'N'
         aadd(aHeadIcon,"hnum")
         EXIT
      CASE 'C'
         aadd(aHeadIcon,"hchar")
         EXIT
      CASE 'M'
         aadd(aHeadIcon,"hmemo")
      End
   NEXT

   RETURN(aHeadIcon)

PROCEDURE Adjust()

   oWndBase.Browse_1.Width  := oWndBase.width  - 40
   oWndBase.Browse_1.Height := oWndBase.height - 95

   RETURN

PROCEDURE Append()

   RETURN

PROCEDURE Edit()

   RETURN

PROCEDURE DeleteRecall()

   ( Alias() )->( DbGoto(oWndBase.Browse_1.Value) )

   IF ( Alias() )->( Rlock() )
      iif( ( Alias() )->( Deleted() ), ( Alias() )->( DbRecall() ), ( Alias() )->( DbDelete() ) )
   ENDIF
   ( Alias() )->( dbUnlock() )

   oWndBase.Browse_1.Refresh
   oWndBase.Browse_1.SetFocus

   RETURN

PROCEDURE printlist()

   LOCAL aHdr1, aTot, aFmt, i

   _OOHG_PRINTLIBRARY="MINIPRINT"

   cBase := Alias()
   aEst  := DBstruct()

   aHdr  := {}
   aLen  := {}

   FOR i := 1 to ( Alias() )->(FCount())
      Aadd(aHdr,aEst[i,1])
      Aadd(aLen,Max(100,Min(160,aEst[i,3]*14)))
   NEXT

   aeval(aLen, {|e,i| aLen[i] := e/9})

   aHdr1 := array(len(aHdr))
   aTot  := array(len(aHdr))
   aFmt  := array(len(aHdr))
   afill(aHdr1, '')
   afill(aTot, .f.)
   afill(aFmt, '')

   SET DELETED ON

   ( Alias() )->( dbgotop() )

   DO REPORT ;
      TITLE    cBase                    ;
      HEADERS  aHdr1, aHdr              ;
      FIELDS   aHdr                     ;
      WIDTHS   aLen                     ;
      TOTALS   aTot                     ;
      NFORMATS aFmt                     ;
      WORKAREA &cBase                   ;
      LPP 60                            ;
      CPL 120                           ;
      LMARGIN  5                        ;
      PAPERSIZE DMPAPER_LETTER          ;
      PREVIEW

   SET DELETED OFF

   RETURN
