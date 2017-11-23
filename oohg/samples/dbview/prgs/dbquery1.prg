/*
* $Id: dbquery1.prg,v 1.2 2016/10/17 01:55:33 fyurisich Exp $
*/

/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2012 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Program to view DBF files using standard Browse control
* Miguel Angel Juárez A. - 2009-2012 MigSoft <mig2soft/at/yahoo.com>
* Includes the code of Grigory Filatov <gfilatov@inbox.ru>
* and Rathinagiri <srathinagiri@gmail.com>
*/

#include "oohg.ch"
#include "dbuvar.ch"

#define COMPILE(cExpr)    &("{||" + cExpr + "}")
#define MsgInfo( c ) MsgInfo( c, "DBView", , .f. )

#define Q_FILE  1   // For the aQuery_ array
#define Q_DESC  2
#define Q_EXPR  3

DECLARE WINDOW Form_Query

FUNCTION AddText(cExpr, aUndo_, cText)

   cExpr += cText
   aadd(aUndo_, cText)
   Form_Query.Edit_1.Value := cExpr
   DO EVENTS

   RETURN(NIL)

FUNCTION GetType(cField, aFlds_, cChar)

   LOCAL cType, n

   n := len(aFlds_)

   IF cField == aFlds_[n]    // Deleted() == Logical
      cType := "L"
   ELSE
      n := ascan(aFlds_, cField)
      cType := valtype((cAlias)->( fieldget(n) ))
      IF cType == "M"
         cType := "C"
      ELSEIF cType == "C"
         cChar := padr(cChar, len((cAlias)->( fieldget(n) )))
      ENDIF
   ENDIF

   RETURN(cType)

FUNCTION CheckComp(cType, cComp)

   LOCAL lOk := .T.
   LOCAL cTemp := left(cComp, 2)

   DO CASE
   CASE cType $ "ND"
      IF cTemp $ "$ ()"
         lOk := .F.
      ENDIF
   CASE cType == "L"
      IF cTemp <> "==" .and. cTemp <> "<>" .and. cTemp <> '""'
         lOk := .F.
      ENDIF
   OTHERWISE     // All are Ok for character variables
      lOk := .T.
   ENDCASE

   IF !lOk
      MsgInfo("Invalid comparison for selected data type.")
   ENDIF

   RETURN(lOk)

FUNCTION AddExpr(cExpr, aUndo_, cField, cComp, uVal)

   LOCAL cVT, cTemp
   LOCAL xFieldVal := (cAlias)->( fieldget(fieldpos(cField)) )

   cVT := alltrim(left(cComp, 2))
   IF cVT == '()'
      cTemp := '"' + rtrim(uVal) + '" $ ' + cField
   ELSEIF cVT == '""'
      cTemp := "empty(" + cField + ")"
   ELSE
      cTemp := cField + ' ' + cVT + ' '
      cVT := valtype(uVal)
      DO CASE
      CASE cVT == 'C'
         cTemp += '"' + padr(uVal, len(xFieldVal)) + '"'
      CASE cVT == 'N'
         cTemp += ltrim(str(uVal))
      CASE cVT == 'D'
         cTemp += 'ctod("' + dtoc(uVal) + '")'
      CASE cVT == "L"
         cTemp += iif(uVal, '.T.', '.F.')
      ENDCASE
   ENDIF

   cTemp += " "

   AddText(@cExpr, aUndo_, cTemp)

   RETURN(NIL)

FUNCTION Undo(cExpr, aUndo_)

   LOCAL l := len(aUndo_)
   LOCAL x, cTemp := cExpr

   IF (x := rat(aUndo_[l], cTemp)) > 0
      cExpr := InsDel(cTemp, x, len(aUndo_[l]), "")
      Form_Query.Edit_1.Value := cExpr
      DO EVENTS
   ENDIF

   asize(aUndo_, l - 1)

   RETURN(NIL)

FUNCTION RunQuery(cExpr)

   LOCAL nCurRec := (cAlias)->( recno() )
   LOCAL bOldErr := ErrorBlock({|e| QueryError(e) })
   LOCAL lOk := .T.
   LOCAL nCount := 0

   BEGIN sequence
      (cAlias)->( DbSetFilter(COMPILE(cExpr), cExpr) )
   RECOVER
      (cAlias)->( DbClearFilter() )
      lOk := .F.
   END SEQUENCE
   errorblock(bOldErr)

   IF !lOk
      (cAlias)->( DbGoTo(nCurRec) )

      RETURN(lOk)
   ENDIF

   (cAlias)->( DbGoTop() )
   DO WHILE !(cAlias)->( EoF() )
      nCount++
      (cAlias)->( DbSkip() )
      IF !(cAlias)->( EoF() )
         EXIT
      ENDIF
   ENDDO
   DO EVENTS

   IF Empty(nCount)
      lOk := .F.
      MsgInfo( 'There are no such records!' )
      (cAlias)->( DbClearFilter() )
      (cAlias)->( DbGoTo(nCurRec) )
   ELSE
      (cAlias)->( DbGoTop() )
   ENDIF

   RETURN(lOk)

FUNCTION SaveQuery(cExpr, aQuery_,cBase)

   LOCAL cDesc := ""
   LOCAL cQFile
   LOCAL lAppend := .T., x
   LOCAL aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
      { "All Files        (*.*)", "*.*"} }

   IF !empty(aQuery_[Q_DESC])
      cDesc := alltrim(aQuery_[Q_DESC])
   ENDIF

   cDesc := InputBox( 'Enter a brief description of this query'+":" , 'Query Description' , cDesc )
   IF len(cDesc) == 0  // Rather than empty() because they may hit 'Ok' on

      RETURN(NIL)       // just spaces and that is acceptable.
   ENDIF

   cpath  := _DBULastPath
   cQFile := PutFile( aMask, 'Save Query', cPath, .t. )

   IF !Empty( cQFile )

      cQFile := cPath + "\" + cFileNoExt( cQFile ) + ".dbq"
      IF !file(cQFile)
         Cr_QFile(cQFile)
      ENDIF

      aQuery_[Q_FILE] := padr(cDBFile, 12)
      aQuery_[Q_DESC] := padr(cDesc, 80)
      aQuery_[Q_EXPR] := cExpr

      IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

         IF QFile->( NotDBQ( cQFile ) )
            QFile->( DBCloseArea() )

            RETURN(NIL)
         ENDIF

         QFile->( DBGoTop() )
         DO WHILE !QFile->( eof() )
            IF QFile->FILENAME == aQuery_[Q_FILE]
               IF QFile->DESC == aQuery_[Q_DESC]
                  x := MsgYesNo( 'A query with the same description was found for this database' + "." + CRLF + ;
                     'Do you wish to overwrite the existing query or append a new one?', 'Duplicate Query', , .f. )

                  IF x == 6
                     lAppend := .F.
                  ELSEIF x == 2
                     QFile->( DBCloseArea() )

                     RETURN(NIL)
                  ENDIF
                  EXIT
               ENDIF
            ENDIF
            QFile->( DBSkip() )
         ENDDO

         IF lAppend
            QFile->( DBAppend() )
         ENDIF

         QFile->FILENAME := aQuery_[Q_FILE]
         QFile->DESC     := aQuery_[Q_DESC]
         QFile->EXPR     := aQuery_[Q_EXPR]

         QFile->( DBCloseArea() )

         Sele &cBase

         MsgInfo('Query Saved')

      ENDIF

   ENDIF

   RETURN(NIL)

FUNCTION LoadQuery(cExpr, aQuery_,cBase)

   //local cQFile := ""
   LOCAL lLoaded := .F., lCancel := .F.
   LOCAL aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
      { "All Files        (*.*)", "*.*"} }

   cpath := _DBULastPath
   cQFile := GetFile(aMask, 'Select a Query to Load', cPath, .f., .t.)

   IF empty(cQFile)

      RETURN(lLoaded)
   ENDIF

   IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

      IF QFile->( NotDBQ( cQFile ) )
         QFile->( DBCloseArea() )

         RETURN(lLoaded)
      ELSEIF QFile->( eof() )
         MsgInfo(cQFile + " " + 'does not contain any queries' + "!")
      ELSE
         DEFINE WINDOW Form_Load ;
               AT 0, 0 WIDTH 484 HEIGHT 214 ;
               TITLE "Load Query" + cQFile ;
               ICON 'MAIN1' ;
               MODAL ;
               FONT "MS Sans Serif" ;
               SIZE 8

            DEFINE BROWSE Browse_1
               ROW 10
               COL 10
               WIDTH  Form_Load.Width  - 28   //GetProperty( 'Form_Load', 'Width' ) - 28
               HEIGHT Form_Load.Height - 78   //GetProperty( 'Form_Load', 'Height' ) - 78
               HEADERS { "X", 'Database', 'Description', 'Query Expression' }
               WIDTHS { 16, 86, 174, if(QFile->( Lastrec() ) > 8, 160, 176) }
               FIELDS { 'iif(QFile->( deleted() ), " X", "  ")', ;
                  'QFile->FILENAME', ;
                  'QFile->DESC', ;
                  'QFile->EXPR' }
               WORKAREA QFile
               VALUE QFile->( Recno() )
               VSCROLLBAR QFile->( Lastrec() ) > 8
               READONLYFIELDS { .t., .t., .t., .t. }
               ONDBLCLICK Form_Load.Button_1.OnClick()
            END BROWSE

            DEFINE BUTTON Button_1
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    186
               WIDTH  80
               HEIGHT 24
               CAPTION "&Load"
               ACTION iif(LoadIt(aQuery_), Form_Load.Release, )
               TABSTOP .T.
               VISIBLE .T.
            END BUTTON

            DEFINE BUTTON Button_2
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    286
               WIDTH  80
               HEIGHT 24
               CAPTION "&Close"
               ACTION (lCancel := .T., Form_Load.Release )
               TABSTOP .T.
               VISIBLE .T.
            END BUTTON

            DEFINE BUTTON Button_3
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    386
               WIDTH  80
               HEIGHT 24
               CAPTION '&Delete'
               ACTION iif(QFile->( DelRec() ), ( Form_Load.Browse_1.Refresh, Form_Load.Browse_1.Setfocus ), )
               TABSTOP .T.
               VISIBLE .T.
            END BUTTON

            ON KEY ESCAPE ACTION Form_Load.Button_2.OnClick

         END WINDOW

         CENTER WINDOW Form_Load

         ACTIVATE WINDOW Form_Load

         IF !lCancel
            cExpr := aQuery_[Q_EXPR]
            Form_Query.Edit_1.Value := cExpr
            lLoaded := .T.
         ENDIF

      ENDIF

      QFile->( __DBPack() )
      QFile->( DBCloseArea() )

      sele &cBase

   ENDIF

   RETURN(lLoaded)

FUNCTION NotDBQ( cQFile )

   LOCAL lNot := .F.

   IF fieldpos("FILENAME") == 0 .or. ;
         fieldpos("DESC") == 0 .or. ;
         fieldpos("EXPR") == 0
      lNot := .T.
      MsgInfo(cQFile + " " + "is not a DataBase query file" + ".")
   ENDIF

   RETURN(lNot)

FUNCTION LoadIt(aQuery_)

   LOCAL lLoaded := .F.

   IF QFile->FILENAME <> padr(cDBFile, 12)
      IF MsgYesNo("The query's filename does not match that of the currently loaded file" + "." + CRLF + ;
            'Load it anyway?', 'Different Filename')
         lLoaded := .T.
      ENDIF
   ELSE
      lLoaded := .T.
   ENDIF

   IF lLoaded
      aQuery_[Q_FILE] := alltrim(QFile->FILENAME)
      aQuery_[Q_DESC] := alltrim(QFile->DESC)
      aQuery_[Q_EXPR] := alltrim(QFile->EXPR) + " "
   ENDIF

   RETURN(lLoaded)

FUNCTION DelRec()

   LOCAL lDel := .F.
   LOCAL cMsg, cTitle

   IF deleted()
      cMsg := 'Are you sure you wish to recall this record?'
      cTitle := 'Recall'
   ELSE
      cMsg := 'Are you sure you wish to delete this record?'
      cTitle := 'Delete'
   ENDIF

   IF MsgYesNo(cMsg, cTitle)
      IF deleted()
         DBRecall()
      ELSE
         DBDelete()
      ENDIF
      lDel := .T.
   ENDIF

   RETURN(lDel)

FUNCTION QueryError(e)

   LOCAL cMsg := 'Syntax error in Query expression!'

   IF valtype(e:description) == "C"
      cMsg := e:description
      cMsg += if(!empty(e:filename), ": " + e:filename, ;
         if(!empty(e:operation), ": " + e:operation, "" ))
   ENDIF

   MsgInfo(cMsg)

   RETURN break(e)

PROCEDURE Cr_QFile(cQFile)

   LOCAL aArray_ := { { "FILENAME", "C",  12, 0 }, ;
      { "DESC", "C",  80, 0 }, ;
      { "EXPR", "C", 255, 0 } }

   DBCreate(cQFile, aArray_)

   RETURN

FUNCTION InsDel(cOrig, nStart, nDelete, cInsert)

   LOCAL cLeft := left(cOrig, nStart - 1)
   LOCAL cRight := substr(cOrig, nStart + nDelete)

   RETURN(cLeft + cInsert + cRight)

FUNCTION OpenDataBaseFile( cDataBaseFileName, cAlias, lExclusive, lReadOnly, cDriverName, lNew )

   LOCAL _bLastHandler := ErrorBlock( {|o| Break(o)} ), _lGood := .T. /*, oError*/

   IF PCount() < 6 .or. ValType(lNew) <> "L"
      lNew := .T.
   ENDIF

   BEGIN SEQUENCE

      dbUseArea( lNew, cDriverName, cDataBaseFileName, cAlias, !lExclusive, lReadOnly )

   RECOVER //USING oError

      _lGood := .F.
      MsgInfo( "Unable to open file:" + CRLF + cDataBaseFileName )

   END

   ErrorBlock( _bLastHandler )

   RETURN( _lGood )
