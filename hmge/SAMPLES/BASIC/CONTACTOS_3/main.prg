/*
* Harbour MiniGUI: Free xBase Win32/GUI Development System
* Copyright 2002-07 Roberto Lopez <harbourminigui@google.com>
* http://harbourminigui.googlepages.com
* Copyright 2007 MigSoft <fugaz_cl@yahoo.es>
*/

#include "minigui.ch"

#ifndef __XHARBOUR__
#xcommand TRY  => BEGIN SEQUENCE WITH {|oErr| Break( oErr )}
#xcommand CATCH [<!oErr!>] => RECOVER [USING <oErr>] <-oErr->
#endif

MEMVAR CnAdo, oCursor, lIng, Nuevo
MEMVAR nFont, cArquivo

FUNCTION Main()

   PUBLIC CnAdo,oCursor,lIng := .T.,Nuevo := .F.

   Seteos()
   ConectaMDB()
   LOAD WINDOW Principal
   Principal.Maximize
   ACTIVATE WINDOW Principal

   RETURN NIL

PROCEDURE Seteos()

   SET CENTURY ON
   SET DATE french
   SET NAVIGATION EXTENDED

   RETURN

PROCEDURE ConectaMDB()

   LOCAL e

   Try
      CnAdo:=CreateObject("ADODB.Connection")
      IF Ole2TxtError() != "S_OK"
         MsgStop("ADO is not available.","Error")
         ExitProcess(0)
      ENDIF
      CnAdo:Open("Provider=Microsoft.Jet.OLEDB.4.0;Data Source=Agenda.mdb")
      oCursor:=CreateObject("ADODB.Recordset")
   CATCH e
      MsgStop("Operation: "+e:operation+"-"+"Description: "+e:Description+chr(10)+vMat(e:Args),"Error")
      ExitProcess(0)
   END

   RETURN

PROCEDURE AdministradorDeContactos()

   LOAD WINDOW Win_1
   CENTER WINDOW Win_1
   ACTIVATE WINDOW Win_1

   RETURN

PROCEDURE AbrirTablas()

   Primero()

   RETURN

PROCEDURE CerrarTablas

   RETURN

PROCEDURE AbrirCursor()

   IF lIng
      oCursor:Open("Select * from contactos order by Apellido",CnAdo,2,3)
      lIng := .F.
   ENDIF

   RETURN

PROCEDURE Primero()

   AbrirCursor()
   oCursor:MoveFirst()
   CancelarEdicion()

   RETURN

PROCEDURE Siguiente()

   AbrirCursor()
   IF !oCursor:Eof()
      oCursor:MoveNext()
   ENDIF
   CancelarEdicion()

   RETURN

PROCEDURE Anterior()

   AbrirCursor()
   IF !oCursor:Bof()
      oCursor:MovePrevious()
   ENDIF
   CancelarEdicion()

   RETURN

PROCEDURE Ultimo()

   AbrirCursor()
   oCursor:MoveLast()
   CancelarEdicion()

   RETURN

PROCEDURE DesactivarEdicion

   Win_1.Control_1.Enabled      := .F.
   Win_1.Control_3.Enabled      := .F.
   Win_1.Control_4.Enabled      := .F.
   Win_1.Control_5.Enabled      := .F.
   Win_1.Control_6.Enabled      := .F.
   Win_1.Control_7.Enabled      := .F.
   Win_1.Control_8.Enabled      := .F.
   Win_1.Control_9.Enabled      := .F.
   Win_1.Control_10.Enabled           := .F.
   Win_1.Control_11.Enabled           := .F.
   Win_1.Aceptar.Enabled      := .F.
   Win_1.Cancelar.Enabled      := .F.
   Win_1.ToolBar_1.Enabled      := .T.

   RETURN

PROCEDURE ActivarEdicion

   Win_1.Control_1.Enabled      := .T.
   Win_1.Control_3.Enabled      := .T.
   Win_1.Control_4.Enabled      := .T.
   Win_1.Control_5.Enabled      := .T.
   Win_1.Control_6.Enabled      := .T.
   Win_1.Control_7.Enabled      := .T.
   Win_1.Control_8.Enabled      := .T.
   Win_1.Control_9.Enabled      := .T.
   Win_1.Control_10.Enabled           := .T.
   Win_1.Control_11.Enabled           := .T.
   Win_1.Aceptar.Enabled      := .T.
   Win_1.Cancelar.Enabled      := .T.
   Win_1.ToolBar_1.Enabled      := .F.
   Win_1.Control_1.SetFocus

   RETURN

PROCEDURE CancelarEdicion()

   DesactivarEdicion()
   Actualizar()
   Nuevo := .F.

   RETURN

PROCEDURE AceptarEdicion()

   LOCAL cSql

   DesactivarEdicion()
   IF Nuevo
      cSql:="INSERT INTO CONTACTOS (Apellido,Nombres,Calle,Numero,Piso,Dpto,Tel_Part,Tel_Cel,E_Mail,Fecha_Nac) VALUES ('"
      cSql+=Win_1.Control_1.Value        +"','"
      cSql+=Win_1.Control_3.Value        +"','"
      cSql+=Win_1.Control_4.Value        +"','"
      cSql+=str(Win_1.Control_5.Value)   +"','"
      cSql+=str(Win_1.Control_6.Value)   +"','"
      cSql+=Win_1.Control_7.Value        +"','"
      cSql+=Win_1.Control_8.Value        +"','"
      cSql+=Win_1.Control_9.Value        +"','"
      cSql+=Win_1.Control_10.Value       +"','"
      cSql+=dtoc(Win_1.Control_11.Value) +"')"
      Nuevo := .F.
   ELSE
      cSql:="UPDATE CONTACTOS SET "
      cSql+="Nombres='"+Win_1.Control_3.Value          +"',"
      cSql+="Calle='"+Win_1.Control_4.Value            +"',"
      cSql+="Numero='"+str(Win_1.Control_5.Value)      +"',"
      cSql+="Piso='"+str(Win_1.Control_6.Value)        +"',"
      cSql+="Dpto='"+Win_1.Control_7.Value             +"',"
      cSql+="Tel_Part='"+Win_1.Control_8.Value         +"',"
      cSql+="Tel_Cel='"+Win_1.Control_9.Value          +"',"
      cSql+="E_Mail='"+Win_1.Control_10.Value          +"',"
      cSql+="Fecha_Nac='"+dtoc(Win_1.Control_11.Value) +"'"
      cSql+="Where Apellido='"+Win_1.Control_1.Value   +"'"
   ENDIF
   CnAdo:Execute(cSql)
   oCursor:Close()
   lIng := .T.
   AbrirCursor()
   oCursor:Find("Apellido='"+Win_1.Control_1.Value+"'")

   RETURN

PROCEDURE Nuevo()

   Win_1.Control_1.Value := ''
   Win_1.Control_3.Value := ''
   Win_1.Control_4.Value := ''
   Win_1.Control_5.Value := 0
   Win_1.Control_6.Value := 0
   Win_1.Control_7.Value := ''
   Win_1.Control_8.Value := ''
   Win_1.Control_9.Value := ''
   Win_1.Control_10.Value := ''
   Win_1.Control_11.Value := CtoD ('01/01/1976')
   ActivarEdicion()

   RETURN

PROCEDURE Actualizar()

   DO CASE
   CASE oCursor:Bof()
      oCursor:MoveFirst()
   CASE oCursor:Eof()
      oCursor:MoveLast()
   ENDCASE
   Win_1.Control_1.Value   := oCursor:Fields["Apellido"]:value
   Win_1.Control_3.Value   := oCursor:Fields["Nombres"]:value
   Win_1.Control_4.Value   := oCursor:Fields["Calle"]:value
   Win_1.Control_5.Value    := oCursor:Fields["Numero"]:value
   Win_1.Control_6.Value   := oCursor:Fields["Piso"]:value
   Win_1.Control_7.Value    := oCursor:Fields["Dpto"]:value
   Win_1.Control_8.Value   := oCursor:Fields["Tel_Part"]:value
   Win_1.Control_9.Value   := oCursor:Fields["Tel_Cel"]:value
   Win_1.Control_10.Value   := oCursor:Fields["E_Mail"]:value
   Win_1.Control_11.Value   := oCursor:Fields["Fecha_Nac"]:value

   RETURN

FUNCTION BloquearRegistro()

   RETURN NIL

PROCEDURE Eliminar

   LOCAL cApeF,cSql,cPreF

   IF MsgYesNo ( 'Esta Seguro','Eliminar Registro')
      cApeF := Win_1.Control_1.Value
      oCursor:MovePrevious()
      IF oCursor:Bof()
         oCursor:MoveFirst()
         oCursor:MoveNext()
      ENDIF
      CancelarEdicion()
      cPreF := Win_1.Control_1.Value
      cSql := "DELETE FROM CONTACTOS WHERE Apellido='"+cApeF+"'"
      CnAdo:Execute(cSql)
      oCursor:Close()
      lIng := .T.
      AbrirCursor()
      oCursor:Find("Apellido='"+cPreF+"'")
      CancelarEdicion()
   ENDIF

   RETURN

PROCEDURE Buscar

   LOCAL Buscar

   Buscar := Upper ( AllTrim ( InputBox( 'Ingrese Apellido a Buscar:' , 'Busqueda' ) ) )
   Buscar := IIf( Empty(Buscar), "A" , Buscar )
   oCursor:Close()
   oCursor:Open("Select * from contactos where Apellido like '"+Buscar+"%'"+" order by Apellido",CnAdo,2,3)
   IF !oCursor:Eof()
      Actualizar()
   ELSE
      MsgInfo("Registro no Encontrado","No existe")
   ENDIF
   oCursor:Close()
   lIng := .T.
   AbrirCursor()
   oCursor:Find("Apellido='"+Win_1.Control_1.Value+"'")

   RETURN

STATIC FUNCTION vMat(a)

   LOCAL cMsg:="",i

   IF valtype(a)="A"
      FOR i=1 to len(a)
         IF valtype(a[i])="N"
            cMsg += Str(a[i])+" "
         ELSEIF valtype(a[i])="L"
            cMsg += if(a[i],".T.",".F.")+" "
         ELSEIF valtype(a[i])="D"
            cMsg += Dtoc(a[i])+" "
         ELSE
            cMsg += a[i]+" "
         ENDIF
      NEXT
   ENDIF

   RETURN cMsg

PROCEDURE Imprimir

   LOCAL nLin:=0,i,nReg:=0,cLetra:="",Handle,cLinea,Ape1,Nom1
   PRIVATE nFont := 11
   PRIVATE cArquivo := ""

   Handle := fCreate("Rel.tmp")
   IF Handle <= 0

      RETURN
   ENDIF
   oCursor:MoveFirst()
   DO WHILE ! oCursor:Eof()
      IF nLin == 0.or.nLin>55
         cLinea := PadC("Agenda de Contactos",78)+CRLF
         cLinea += PadC("Contactos por Apellido"+cLetra,78)+CRLF
         cLinea += PadR("Apellidos",22)+space(3)+PadR("Nombres",23)+CRLF
         cLinea += Replicate("-",78)+CRLF
         Fwrite(Handle,cLinea)
         nLin:=5
      ENDIF
      nLin += 1 ; nReg += 1
      Ape1 := oCursor:Fields["Apellido"]:Value ; Nom1 := oCursor:Fields["Nombres"]:Value
      Fwrite(Handle,PadR(ltrim(Ape1),22)+space(3)+PadR(ltrim(Nom1),23)+CRLF)
      oCursor:MoveNext()
   ENDDO
   cLinea:=Replicate("-",78)+CRLF
   cLinea+="Registros Impresos: "+StrZero(nReg,4)
   Fwrite(Handle,cLinea)
   fClose(Handle)
   cArquivo := memoRead("REL.TMP")
   fErase("Rel.tmp")

   DEFINE WINDOW Form_3;
         At 0,0   ;
         WIDTH 450   ;
         HEIGHT 500   ;
         TITLE "Contactos por Apellido"+cLetra;
         ICON "Tutor"   ;
         MODAL   ;
         NOSYSMENU   ;
         NOSIZE   ;
         BACKCOLOR WHITE

      @ 20,-1  RICHEDITBOX Edit_1 ;
         WIDTH 460 ;
         HEIGHT 510 ;
         VALUE cArquivo ;
         TOOLTIP "Contactos por Apellido"+cLetra ;
         MAXLENGTH 255

      @ 01,01  BUTTON Bt_Zoom_Mais  ;
         CAPTION '&Zoom(+)'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION ZoomLabel(1);
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 01,125 BUTTON Bt_Zoom_menos  ;
         CAPTION '&Zoom(-)'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION ZoomLabel(-1);
         FONT "MS Sans Serif" SIZE 09 FLAT

      @ 01,321 BUTTON Sair_1  ;
         CAPTION '&Salir'             ;
         WIDTH 120 HEIGHT 17    ;
         ACTION Form_3.Release;
         FONT "MS Sans Serif" SIZE 09 FLAT
   END WINDOW
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont
   CENTER WINDOW Form_3
   ACTIVATE WINDOW Form_3

   RETURN

PROCEDURE ZoomLabel(nmm)

   IF nmm == 1
      nFont++
   ELSE
      nFont--
   ENDIF
   MODIFY CONTROL Edit_1 OF Form_3 FONTSIZE nFont

   RETURN
