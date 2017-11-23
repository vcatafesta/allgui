/*
* $Id: demo.prg,v 1.4 2017/08/25 19:28:45 fyurisich Exp $
*/
/*
* This demo shows how to use GRID.
* Copyright (c)2007-2017 MigSoft <migsoft/at/oohg.org>
*/

#include "oohg.ch"

PROCEDURE Main()

   SET MULTIPLE OFF Warning

   USE Cuentas
   INDEX ON field->nombre To cuentas

   LOAD WINDOW Win_1
   CENTER WINDOW Win_1
   Win_1.Text_1.Setfocus
   ACTIVATE WINDOW Win_1

   RETURN

FUNCTION Captura()

   LOCAL cCapt       := Upper(AllTrim(win_1.Text_1.value))
   LOCAL nTaman      := Len(cCapt)
   LOCAL nRegProc    := 0
   LOCAL nMaxRegGrid := 70
   MEMVAR cCampo
   PRIVATE cCampo    := "NOMBRE"

   DBSELECTAREA("Cuentas")
   DBSeek(cCapt)

   win_1.Grid_1.DisableUpdate
   DELETE ITEM ALL FROM Grid_1 OF Win_1

   DO WHILE !EOF()
      IF Substr(FIELD->&cCampo,1,nTaman) == cCapt
         nRegProc += 1
         IF nRegProc > nMaxRegGrid
            EXIT
         ENDIF
         ADD ITEM { TRANSF(Cuentas->Imputacion,"9999999") , ;
            Cuentas->Nombre } TO Grid_1 of Win_1
      ELSEIF Substr(FIELD->&cCampo,1,nTaman) > cCapt
         EXIT
      ENDIF
      DBSkip()
   ENDDO
   win_1.Grid_1.EnableUpdate

   RETURN NIL

PROCEDURE VerItem()

   MsgInfo( 'Col 1: ' + GetColValue( "Grid_1", "Win_1", 1 )+'  ';
      + 'Col 2: ' + GetColValue( "Grid_1", "Win_1", 2 ) )

   RETURN

FUNCTION GetColValue( xObj, xForm, nCol )

   LOCAL nPos:= GetProperty(xForm, xObj, 'Value')
   LOCAL aRet:= GetProperty(xForm, xObj, 'Item', nPos)

   RETURN aRet[nCol]

FUNCTION SetColValue( xObj, xForm, nCol, xValue )

   LOCAL nPos:= GetProperty(xForm, xObj, 'Value')
   LOCAL aRet:= GetProperty(xForm, xObj, 'Item', nPos)

   aRet[nCol] := xValue
   SetProperty(xForm, xObj, 'Item', nPos, aRet)

   RETURN NIL
