///Mail Sample using Matteo Bacan socket function
///Based on Paola's Bruccoleri Mail Function
///Bruno Luciani
///bruno.luciani@gmail.com

#include "oohg.ch"

PROCEDURE main

   LOAD WINDOW mailing
   mailing.smtp.value:="mail.servidor.com"

   CENTER WINDOW mailing
   ACTIVATE WINDOW mailing

   RETURN

FUNCTION enviomail

   sendmail(mailing.send.value,mailing.rname.value,mailing.smtp.value)

   RETURN

   RETURN

FUNCTION sendmail(email,nombre,cServer)

   LOCAL oSock, cRet

   ///local cServer := "mail.tuservidor.com"   / puedes poner la IP tambien

   oSock := TSmtp():New()

   Mailing.statusbar.value:= "Conectando a " +cServer

   IF oSock:Connect( cServer )
      Mailing.statusbar.value:= "Conectado...."

      IF !Empty(alltrim(email))

         Mailing.confirmacion_lbl.Value:= ""

         oSock:ClearData()
         oSock:SetFrom( "Mail Sample", "<oohg@oohg.org>" )
         oSock:SetSubject( Mailing.asunto_txb.Value )
         oSock:AddTo( alltrim(nombre),"<"+alltrim(email)+">" )
         oSock:SetData( Mailing.texto_edt.value, .t. )
         IF !oSock:Send( .T. )
            Mailing.confirmacion_lbl.Value:= "Error: "+oSock:getLastError()
         ELSE
            Mailing.confirmacion_lbl.Value:= 'Envio correcto'
         ENDIF
      ENDIF

      Mailing.statusbar.Value:= "Cerrando la conexion"
      IF oSock:Close()
         Mailing.statusbar.Value:= "Cerrada la conexion"
         Mailing.release
      ELSE
         Mailing.statusbar.Value:= "Error al cerrar la conexion"
      ENDIF
   ELSE
      Mailing.statusbar.Value:= "Fallo conexion " + oSock:getLastError()
   ENDIF

   RETURN

   #define NO_SAMPLE
   #include "TSmtpClient.prg"

