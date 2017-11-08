/*
 * Ejemplo OpenOffice n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo abrir un libro de OpenOffice
 * Calc en modo "solo lectura".
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main

   SET DATE BRITISH
   SET CENTURY ON
   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 600 ;
      HEIGHT 480 ;
      TITLE 'Abrir un libro de OpenOffice Calc en modo "solo lectura"' ;
      MAIN

      DEFINE STATUSBAR
         STATUSITEM 'El poder de OOHG !!!'
      END STATUSBAR

      @ 370,20 BUTTON btn_Abrir ;
         CAPTION 'Abrir Archivo' ;
         WIDTH 140 ;
         ACTION Abrir()

      ON KEY ESCAPE ACTION Form_1.Release()
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN NIL

FUNCTION Abrir

   LOCAL w_arch, oSerM, oDesk, oPropVals, oBook, x, bErrBlck1

   IF Empty(w_arch := GetFile({ {'*.ods','*.ods'} }, 'Abrir Archivo', 'C:\', .f., .f.))
      RETURN NIL
   ENDIF

   // abrir el Service Manager
   #ifndef __XHARBOUR__
      IF( oSerM := win_oleCreateObject( 'com.sun.star.ServiceManager' ) ) == NIL
         MsgStop( 'Error: OpenOffice no está disponible. [' + win_oleErrorText()+ ']' )
         RETURN NIL
      ENDIF
   #else
      oSerM := TOleAuto():New( 'com.sun.star.ServiceManager' )
      IF Ole2TxtError() != 'S_OK'
         MsgStop( 'Error: OpenOffice no está disponible.' )
         RETURN NIL
      ENDIF
   #endif

   // capturar todos los errores
   bErrBlck1 := ErrorBlock( { | x | break( x ) } )

   BEGIN SEQUENCE
      // abrir el Desktop Service
      IF (oDesk := oSerM:CreateInstance("com.sun.star.frame.Desktop")) == NIL
         MsgStop( 'Error: OpenOffice Desktop no está disponible.' )
         oSerM := NIL
         BREAK
      ENDIF

      // definir propiedades para el libro
      oPropVals := oSerM:Bridge_GetStruct("com.sun.star.beans.PropertyValue")
      oPropVals:Name := "ReadOnly"
      oPropVals:Value := .T.

      // abrir libro
      IF (oBook := oDesk:LoadComponentFromURL(OO_ConvertToURL(w_arch), "_blank", 0, {oPropVals})) == NIL
         MsgStop( 'Error: OpenOffice Calc no está disponible.' )
         oDesk := NIL
         oSerM := NIL
         BREAK
      ENDIF

      // seleccionar la primera hoja como corriente
      oBook:getCurrentController:SetActiveSheet(oBook:Sheets:GetByIndex(0))
   RECOVER USING x
      MsgStop( x:Description, "Error de OpenOffice" )
      oDesk := NIL
      oSerM := NIL
   END SEQUENCE

   ErrorBlock( bErrBlck1 )

RETURN NIL

/*
 * EOF
 */
