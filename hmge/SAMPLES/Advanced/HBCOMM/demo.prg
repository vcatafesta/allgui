/*         IDE: HMI+
* Description: Serial Port sample
*      Author: Marcelo Torres <lichitorres@yahoo.com.ar>
*        Date: 2006.08.29
*/

#include 'minigui.ch'

STATIC nHandle
STATIC lConectado := .f.
STATIC lOcupado   := .f.
STATIC cRecibe    := ""
STATIC buffer     := 0
STATIC cTemp      := ""

FUNCTION Main()

   LOAD WINDOW main
   CENTER WINDOW main
   ACTIVATE WINDOW main

   RETURN NIL

STATIC PROCEDURE fConecta()

   LOCAL f_Com       := "COM1"
   LOCAL f_BaudeRate := 19200
   LOCAL f_databits  := 8
   LOCAL f_parity    := 0  //ninguno
   LOCAL f_stopbit   := 1
   LOCAL f_Buff      := 8000

   nHandle := Init_Port( f_Com, f_BaudeRate, f_databits, f_parity, f_stopbit, f_Buff  )
   IF nHandle > 0
      MsgInfo("Conectado...","hbcomm")
      main.timer_1.enabled := .t.
      main.button_1.enabled :=.f.
      lConectado := .t.
      OutBufClr(nHandle)
   ELSE
      MsgStop("Verifique los valores, no se puede establecer la conexion","hbcomm")
      lConectado := .f.
   ENDIF

   RETURN

STATIC PROCEDURE fEnvia()

   LOCAL cEnvio := main.edit_2.value

   IF lConectado .and. !Empty(cEnvio) .and. IsWorking(nHandle)
      OutChr(nHandle,cEnvio)
   ELSE
      MsgStop("No se pueden enviar datos","Envio")
   ENDIF

   RETURN

STATIC PROCEDURE fRecibe()

   WHILE lOcupado
      do events
   ENDDO

   buffer  := InbufSize(nHandle)

   IF buffer > 0

      lOcupado := .t.

      cRecibe := main.edit_1.value
      cTemp := Substr(InChr(nHandle,buffer),1,buffer)

      cRecibe += cTemp
      main.edit_1.value := cRecibe

      lOcupado := .f.

   ENDIF

   RETURN

STATIC PROCEDURE fDesconecta()

   lConectado := .f.
   main.timer_1.enabled := .f.
   main.button_1.enabled :=.t.
   UnInt_Port(nHandle)
   main.edit_1.value := Space(32000)

   RETURN

STATIC PROCEDURE fSale()

   IF lConectado
      fDesconecta()
   ENDIF

   RELEASE WINDOW Main

   RETURN
