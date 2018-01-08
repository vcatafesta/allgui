/*
* MiniGUI MsgArray Demo
* (c) 2007 Grigory Filatov
* Functions MsgArray(), ImpArray() for Xailer
* Author: Bingen Ugaldebere
* Final revision: 07/11/2006
*/

#include "minigui.ch"
#include "winprint.ch"

PROCEDURE Main

   SET LANGUAGE TO SPANISH

   SET DATE FORMAT "dd-mm-yyyy"
   SET EPOCH TO Year(Date())-50

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 300 ;
         HEIGHT 190 ;
         TITLE 'MsgArray Demo' ;
         ICON "demo.ico" ;
         MAIN ;
         NOMAXIMIZE NOSIZE

      @ 10, 40 FRAME Frame_1 ;
         CAPTION '' ;
         WIDTH  220 ;
         HEIGHT 130

      @ 40 ,70 BUTTON Button_1 ;
         CAPTION "Click Me!" ;
         ACTION OnClick() ;
         WIDTH 160 ;
         HEIGHT 30

      @ 90 ,70 BUTTON Button_3 ;
         CAPTION _HMG_aABMLangButton [17] ;
         ACTION Form_1.Release() ;
         WIDTH 160 ;
         HEIGHT 30

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

#define MsgInfo( c ) MsgInfo( c, , , .f. )

FUNCTION OnClick()

   LOCAL aDatos:={{"Maria",45,Date()-45*365},{"Pedro",27,Date()-27*365},{"Josu",9,Date()-9*365},{"Bingen",41,Date()-41*365},{"Arantza",38,Date()-38*365}}
   LOCAL aDatos2:={"Uno","Dos","Tres"}
   LOCAL nItem:=0

   nItem:=MsgArray(aDatos,{"Nombre","Edad","Nacimiento"},"Edades de los familiares")
   IF nItem>0
      MsgInfo("Ha seleccionado el elemento "+Alltrim(Str(nItem))+"  "+aDatos[nItem,1])
   ENDIF

   MsgArray(aDatos2,{"Array"},"Array de una dimension")

   RETURN NIL

   *  MUESTRA UN ARRAY POR PANTALLA O IMPRESORA  *

FUNCTION MsgArray(aItems,aHeads,cText,cTitle,lCancel)

   LOCAL bColor := { |val,CellRowIndex| if( CellRowIndex/2==int(CellRowIndex/2), RGB( 255,255,255 ), RGB( 192,192,192 ) ) }
   LOCAL lOK:=.F., aArray:={}, aWidths:={}, aBkColors:={}
   LOCAL nAt:=0

   DEFAULT aHeads   To {}
   DEFAULT cText    To ""
   DEFAULT cTitle   To "Listado del contenido de la tabla"
   DEFAULT lCancel  To .T.

   //Controles previos
   IF Valtype(aItems)<>"A"    //Si no es un array
      MsgStop("Imposible mostrar datos que no son un ARRAY en MsgArray()"+CRLF+CRLF+ ;
         "Tipo de datos "+Valtype(aItems))

      RETURN 0
   ENDIF

   IF Len(aItems)=0     //Si esta vacio
      MsgStop("Imposible mostrar ARRAY vacio en MsgArray()")

      RETURN 0
   ENDIF

   IF Valtype(aItems[1])="A"     //Array de 2 dimensiones lo clono como esta
      FOR nAt:=1 To Len(aItems[1])
         aEval(aItems,{|e|e[nAt]:=If(Valtype(e[nAt])=="C",e[nAt],PadR(ToString(e[nAt]),10))})
      NEXT
      aArray:=aClone(aItems)
      aEval(aArray[1],{||Aadd(aWidths,80)})
      aEval(aArray[1],{||Aadd(aBkColors,bColor)})
   ELSE                          //Array de 1 dimension no vale lo convierto en 2
      FOR nAt:=1 To Len(aItems)
         Aadd(aArray,{aItems[nAt]})
      NEXT
      Aadd(aWidths,80)
      Aadd(aBkColors,bColor)
   ENDIF

   DEFINE WINDOW _ArrayForm ;
         AT 0,0                ;
         WIDTH 363             ;
         HEIGHT 427            ;
         TITLE cTitle          ;
         ICON "demo.ico"       ;
         MODAL                 ;
         NOSIZE                ;
         FONT "MS Sans Serif"  ;
         SIZE 9

      ON KEY ESCAPE ACTION _ArrayForm.Release

      @ 10, 10 LABEL _Label VALUE cText WIDTH 343 HEIGHT 25 TRANSPARENT

      DEFINE GRID Grid_1
         ROW   45
         COL   10
         WIDTH   343
         HEIGHT   300
         SHOWHEADERS (Len(aHeads)!=0)
         IF Len(aHeads)!=0
            HEADERS aHeads
         ENDIF
         WIDTHS aWidths
         ITEMS aArray
         VALUE 1
         NOLINES .T.
         DYNAMICBACKCOLOR aBkColors
         ON DBLCLICK {|| lOk := .T., nAt := _ArrayForm.Grid_1.Value, _ArrayForm.Release }
         FONTNAME "MS Sans Serif"
         FONTSIZE 10
      END GRID

      @ 355, 20 BUTTON _Ok CAPTION "&"+_HMG_MESSAGE [6] WIDTH 80 HEIGHT 25 DEFAULT ;
         ACTION ( lOk := .T., nAt := _ArrayForm.Grid_1.Value, _ArrayForm.Release )

      IF lCancel
         @ 355,135 BUTTON _Cancel CAPTION "&"+_HMG_MESSAGE [7] WIDTH 80 HEIGHT 25 ;
            ACTION _ArrayForm.Release
      ENDIF

      @ 355,250 BUTTON _Print CAPTION "&"+_HMG_aABMLangButton [16] WIDTH 80 HEIGHT 25 ;
         ACTION ImpArray(aItems,aHeads,cTitle,cText)

   END WINDOW

   CENTER WINDOW _ArrayForm

   ACTIVATE WINDOW _ArrayForm

   RETURN If(lOk,nAt,0)

#define CLR_BLUE { 0, 0, 128 }

   *******  IMPRIMIR ARRAY

STATIC FUNCTION ImpArray(aItems,aHeads,cTitle,cText)

   LOCAL n, aRect := Array(4)
   LOCAL nItem:=0, cHead:=""
   LOCAL aDatos:={}, aLen:={}, nL:=0, nC:=0, cTexto:="", lSalir:=.F., nNumpage:=0

   DEFAULT aHeads To {}

   //Calcular Numero de columnas e inicializar longitudes de columna
   aSize(aLen,If(ValType(aItems[1])="A",Len(aItems[1]),1))
   aFill(aLen,0)

   //Si no hay cabeceras crear un array de cabeceras a ""
   IF Len(aHeads)=0
      aSize(aHeads,Len(aLen))
      aFill(aHeads,"")
   ENDIF

   //Calcular anchura maxima de cada columna
   FOR nC:=1 to Len(aLen)
      FOR nL:=1 to Len(aItems)
         aLen[nC]:=Max(aLen[nC],Len(Alltrim(ToString(If(Len(aLen)>1,aItems[nL,nC],aItems[nL])))))
         aLen[nC]:=Max(aLen[nC],Len(Alltrim(aHeads[nC])))
      NEXT
   NEXT

   //Si hay cabeceras crear el literal de cabecera
   IF Len(aHeads)>0
      FOR nC:=1 to Len(aLen)
         cHead:=cHead+PadR(aHeads[nC],aLen[nC])+" "
      NEXT
   ENDIF

   //Crear el literal de cada linea del Array y cargar a aDatos
   FOR nL:=1 to Len(aItems)
      cTexto:=""
      FOR nC:=1 to Len(aLen)
         n := If(Len(aLen)>1,aItems[nL,nC],aItems[nL])
         DO CASE
         CASE !Empty(CtoD(n))
            cTexto:=cTexto+PadR(n,10)+" "
         CASE Val(n)>0
            cTexto:=cTexto+PadL(Alltrim(n),7)+" "
         CASE ValType(n)="C"
            cTexto:=cTexto+PadR(n,aLen[nC])+" "
         ENDCASE
      NEXT
      Aadd(aDatos,cTexto)
   NEXT

   //Comienza impresion
   INIT PRINTSYS

   SELECT PRINTER BY DIALOG

   IF HBPRNERROR != 0

      RETURN NIL
   ENDIF

   aRect[1] := ( GetDesktopHeight() - 599 ) / 2
   aRect[2] := ( GetDesktopWidth() - 799 ) / 2
   aRect[3] := GetDesktopHeight() - aRect[1]
   aRect[4] := GetDesktopWidth() - aRect[2]

   DEFINE FONT "Font_1" NAME "Courier New" SIZE 12 BOLD UNDERLINE
   DEFINE FONT "Font_2" NAME "Courier New" SIZE 10

   SET PAPERSIZE DMPAPER_A4   // Sets paper size to A4

   SET ORIENTATION PORTRAIT   // Sets paper orientation to portrait

   SET PREVIEW ON         // Enables print preview
   SET CLOSEPREVIEW OFF

   SET PREVIEW RECT aRect
   SET PREVIEW SCALE 3

   START DOC NAME cTitle

   DO WHILE !lSalir
      START PAGE

      @1, 1+(HBPRNMAXCOL-Len(cTitle))/2 SAY cTitle FONT "Font_1" COLOR CLR_BLUE TO PRINT

      @3, 2 SAY AllTrim(cHead) FONT "Font_1" TO PRINT

      FOR n := 1 To HBPRNMAXROW-5

         IF ++nItem<=Len(aDatos)
            @n+4, 2 SAY aDatos[nItem] FONT "Font_2" TO PRINT
         ELSE
            lSalir:=.T.
            EXIT
         ENDIF

      NEXT

      @HBPRNMAXROW, 1+(HBPRNMAXCOL-6)/2 SAY "- "+AllTrim(ToString(++nNumpage))+" -" FONT "Font_2" COLOR CLR_BLUE TO PRINT

   END PAGE
ENDDO

END DOC

RELEASE PRINTSYS

RETURN NIL

STATIC FUNCTION ToString( xValue )

   LOCAL cType := ValType( xValue )
   LOCAL cValue := "", nDecimals := Set( _SET_DECIMALS)

   DO CASE
   CASE cType $  "CM";  cValue := xValue
   CASE cType == "N" ;  nDecimals := iif( xValue == int(xValue), 0, nDecimals) ; cValue := LTrim( Str( xValue, 20, nDecimals ) )
   CASE cType == "D" ;  cValue := DToC( xValue )
   CASE cType == "L" ;  cValue := IIf( xValue, "T", "F" )
   CASE cType == "A" ;  cValue := AToC( xValue )
   CASE cType $  "UE";  cValue := "NIL"
   CASE cType == "B" ;  cValue := "{|| ... }"
   CASE cType == "O" ;  cValue := "{" + xValue:className + "}"
   ENDCASE

   RETURN cValue
