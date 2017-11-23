#include "minigui.ch"

#define COMPILE(cExpr)    &("{||" + cExpr + "}")
#define MsgInfo( c ) MsgInfo( c, PROGRAM, , .f. )

#define Q_FILE  1   // For the aQuery_ array
#define Q_DESC  2
#define Q_EXPR  3

DECLARE WINDOW Form_Query

STATIC FUNCTION AddText(cExpr, aUndo_, cText)

   cExpr += cText
   aadd(aUndo_, cText)
   Form_Query.Edit_1.Value := cExpr
   DO EVENTS

   Return(NIL)

STATIC FUNCTION GetType(cField, aFlds_, cChar)

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

   Return(cType)

STATIC FUNCTION CheckComp(cType, cComp)

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
      MsgAlert("Invalid comparison for selected data type.")
   ENDIF

   Return(lOk)

STATIC FUNCTION AddExpr(cExpr, aUndo_, cField, cComp, uVal)

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

   Return(NIL)

STATIC FUNCTION Undo(cExpr, aUndo_)

   LOCAL l := len(aUndo_)
   LOCAL x, cTemp := cExpr

   IF (x := rat(aUndo_[l], cTemp)) > 0
      cExpr := InsDel(cTemp, x, len(aUndo_[l]), "")
      Form_Query.Edit_1.Value := cExpr
      DO EVENTS
   ENDIF

   asize(aUndo_, l - 1)

   Return(NIL)

STATIC FUNCTION RunQuery(cExpr)

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

      Return(lOk)
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
      MsgAlert( aLangStrings[133] )
      (cAlias)->( DbClearFilter() )
      (cAlias)->( DbGoTo(nCurRec) )
   ELSE
      (cAlias)->( DbGoTop() )
   ENDIF

   Return(lOk)

STATIC FUNCTION SaveQuery(cExpr, aQuery_)

   LOCAL cDesc := ""
   LOCAL cQFile
   LOCAL lAppend := .T., x
   LOCAL aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
      { "All Files        (*.*)", "*.*"} }

   IF !empty(aQuery_[Q_DESC])
      cDesc := alltrim(aQuery_[Q_DESC])
   ENDIF

   cDesc := InputBox( aLangStrings[134]+":" , aLangStrings[135] , cDesc )
   IF len(cDesc) == 0  // Rather than empty() because they may hit 'Ok' on

      Return(NIL)       // just spaces and that is acceptable.
   ENDIF

   cQFile := PutFile( aMask, aLangStrings[136], cPath, .t. )
   IF empty(cQFile)

      Return(NIL)
   ENDIF
   cQFile := cPath + "\" + cFileNoExt( cQFile ) + ".dbq"
   IF !file(cQFile)
      Cr_QFile(cQFile)
   ENDIF

   aQuery_[Q_FILE] := padr(cDBFile, 12)
   aQuery_[Q_DESC] := padr(cDesc, 80)
   aQuery_[Q_EXPR] := cExpr

   IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

      IF QFile->( NotDBQ(cQFile) )
         QFile->( DBCloseArea() )

         Return(NIL)
      ENDIF

      QFile->( DBGoTop() )
      DO WHILE !QFile->( eof() )
         IF QFile->FILENAME == aQuery_[Q_FILE]
            IF QFile->DESC == aQuery_[Q_DESC]
               x := MsgYesNoCancel( aLangStrings[137] + "." + CRLF + ;
                  aLangStrings[138], aLangStrings[139], , .f. )
               IF x == 6
                  lAppend := .F.
               ELSEIF x == 2
                  QFile->( DBCloseArea() )

                  Return(NIL)
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
      QFile->DESC := aQuery_[Q_DESC]
      QFile->EXPR := aQuery_[Q_EXPR]

      QFile->( DBCloseArea() )

      MsgInfo(aLangStrings[140])

   ENDIF

   Return(NIL)

STATIC FUNCTION LoadQuery(cExpr, aQuery_)

   LOCAL cQFile
   LOCAL lLoaded := .F., lCancel := .F.
   LOCAL aMask := { { "DataBase Queries (*.dbq)", "*.dbq" }, ;
      { "All Files        (*.*)", "*.*"} }

   cQFile := GetFile(aMask, aLangStrings[141], cPath, .f., .t.)

   IF empty(cQFile)

      Return(lLoaded)
   ENDIF

   IF OpenDataBaseFile( cQFile, "QFile", .T., .F., RddSetDefault() )

      IF QFile->( NotDBQ(cQFile) )
         QFile->( DBCloseArea() )

         Return(lLoaded)
      ELSEIF QFile->( eof() )
         MsgInfo(cQFile + " " + aLangStrings[142] + "!")
      ELSE
         DEFINE WINDOW Form_Load ;
               AT 0, 0 WIDTH 484 HEIGHT 214 ;
               TITLE aLangStrings[143] + " - " + cQFile ;
               ICON 'CHILD' ;
               MODAL ;
               FONT "MS Sans Serif" ;
               SIZE 8

            DEFINE BROWSE Browse_1
               ROW 10
               COL 10
               WIDTH GetProperty( 'Form_Load', 'Width' ) - 28
               HEIGHT GetProperty( 'Form_Load', 'Height' ) - 78
               HEADERS { "X", aLangStrings[144], aLangStrings[145], aLangStrings[146] }
               WIDTHS { 16, 86, 174, if(QFile->( Lastrec() ) > 8, 160, 176) }
               FIELDS { 'iif(QFile->( deleted() ), " X", "  ")', ;
                  'QFile->FILENAME', ;
                  'QFile->DESC', ;
                  'QFile->EXPR' }
               WORKAREA QFile
               VALUE QFile->( Recno() )
               VSCROLLBAR QFile->( Lastrec() ) > 8
               READONLYFIELDS { .t., .t., .t., .t. }
               ONDBLCLICK Form_Load.Button_1.OnClick
            END BROWSE

            DEFINE BUTTON Button_1
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    186
               WIDTH  80
               HEIGHT 24
               CAPTION aLangStrings[132]
               ACTION iif(LoadIt(aQuery_), ThisWindow.Release, )
               TABSTOP .T.
               VISIBLE .T.
            END BUTTON

            DEFINE BUTTON Button_2
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    286
               WIDTH  80
               HEIGHT 24
               CAPTION aLangStrings[4]
               ACTION (lCancel := .T., ThisWindow.Release )
               TABSTOP .T.
               VISIBLE .T.
            END BUTTON

            DEFINE BUTTON Button_3
               ROW    GetProperty( 'Form_Load', 'Height' ) - 58
               COL    386
               WIDTH  80
               HEIGHT 24
               CAPTION aLangStrings[147]
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

   ENDIF

   Return(lLoaded)

STATIC FUNCTION NotDBQ(cQFile)

   LOCAL lNot := .F.

   IF fieldpos("FILENAME") == 0 .or. ;
         fieldpos("DESC") == 0 .or. ;
         fieldpos("EXPR") == 0
      lNot := .T.
      MsgAlert(cQFile + " " + aLangStrings[148] + ".")
   ENDIF

   Return(lNot)

STATIC FUNCTION LoadIt(aQuery_)

   LOCAL lLoaded := .F.

   IF QFile->FILENAME <> padr(cDBFile, 12)
      IF MsgYesNo(aLangStrings[149] + "." + CRLF + ;
            aLangStrings[150], aLangStrings[151])
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

   Return(lLoaded)

FUNCTION DelRec()

   LOCAL lDel := .F.
   LOCAL cMsg, cTitle

   IF deleted()
      cMsg := aLangStrings[152]
      cTitle := aLangStrings[153]
   ELSE
      cMsg := aLangStrings[154]
      cTitle := aLangStrings[155]
   ENDIF

   IF MsgYesNo(cMsg, cTitle)
      IF deleted()
         DBRecall()
      ELSE
         DBDelete()
      ENDIF
      lDel := .T.
   ENDIF

   Return(lDel)

STATIC FUNCTION QueryError(e)

   LOCAL cMsg := aLangStrings[156]

   IF valtype(e:description) == "C"
      cMsg := e:description
      cMsg += if(!empty(e:filename), ": " + e:filename, ;
         if(!empty(e:operation), ": " + e:operation, "" ))
   ENDIF

   MsgAlert(cMsg)

   RETURN break(e)

STATIC PROCEDURE Cr_QFile(cQFile)

   LOCAL aArray_ := { { "FILENAME", "C",  12, 0 }, ;
      { "DESC", "C",  80, 0 }, ;
      { "EXPR", "C", 255, 0 } }

   DBCreate(cQFile, aArray_)

   RETURN

STATIC FUNCTION InsDel(cOrig, nStart, nDelete, cInsert)

   LOCAL cLeft := left(cOrig, nStart - 1)
   LOCAL cRight := substr(cOrig, nStart + nDelete)

   Return(cLeft + cInsert + cRight)
