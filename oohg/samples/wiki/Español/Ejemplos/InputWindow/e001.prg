/*
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licencido bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Basado en una contribución original de
 * Antonio Vázquez <avazquezc@telefonica.net>
 *
 * Este ejemplo muestra cómo capturar datos utilizando
 * la función InputWindow.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main()

   SET LANGUAGE TO SPANISH

   DEFINE WINDOW Frm1 ;
      AT 0, 0 ;
      WIDTH 300 HEIGHT 300 ;
      MAIN ;
      TITLE "Función InputWindow"

      @  20, 20 LABEL lbl_0 VALUE "Concepto:"
      @  50, 20 LABEL lbl_1 VALUE "Motivo:"
      @  83, 20 LABEL lbl_2 VALUE "Fecha:"
      @ 113, 20 LABEL lbl_3 VALUE "Importe:"
      @ 143, 20 LABEL lbl_4 VALUE "Contabilizar:"
      @ 173, 20 LABEL lbl_5 VALUE "Tipo:"

      @  20, 120 LABEL lbl_Concepto ;
         VALUE "ENTREGA A CUENTA" ;
         AUTOSIZE
      @  50, 120 LABEL lbl_Motivo ;
         VALUE "PAGO FACTURA N° 1122" ;
         AUTOSIZE
      @  80, 120 DATEPICKER dtp_Fecha ;
         WIDTH 110 ;
         DISABLED ;
         NOTABSTOP
      @ 110, 120 TEXTBOX txt_Importe ;
         VALUE 1234 ;
         HEIGHT 24 ;
         WIDTH 110 ;
         NUMERIC ;
         INPUTMASK "@E 999,999.99" ;
         READONLY ;
         NOTABSTOP
      @ 140, 120 CHECKBOX chk_Contabil ;
         CAPTION "" ;
         WIDTH 110 ;
         HEIGHT 24 ;
         VALUE .F. ;
         DISABLED ;
         NOTABSTOP
      @ 170, 120 COMBOBOX cmb_Tipo ;
         ITEMS { "Cobro", "Pago" } ;
         WIDTH 110 ;
         HEIGHT 60 ;
         VALUE 1 ;
         DISABLED ;
         NOTABSTOP

      @ 220, 90 BUTTON btn_Capturar ;
         CAPTION "Capturar" ;
         ACTION Capturar() ;
         WIDTH 120 ;
         HEIGHT 28

      ON KEY ESCAPE ACTION Frm1.Release
   END WINDOW

   CENTER WINDOW Frm1
   ACTIVATE WINDOW Frm1

RETURN NIL

FUNCTION Capturar()

/*
 * Parámetros de la función InputWindow:
 *
 * ( cTitulo, ;
 *   aEtiquetas, ;
 *   aValoresIniciales, ;
 *   aFormatos, ;
 *   nFila, ;
 *   nColumna, ;
 *   aTextoBotones, ;
 *   nAnchoEtiqueta, ;
 *   nAnchoControl, ;
 *   nAnchoBoton  )
 *
 * cTitulo
 *    String.
 *    Título de la ventana.
 * aEtiquetas
 *    Array de strings.
 *    Etiquetas a mostrar. La cantidad de ítems determina la cantidad de
 *    campos a capturar.
 * aValoresIniciales
 *    Array.
 *    Valores iniciales de los campos a capturar.
 *    El tipo de cada ítem determina el tipo de control a utilizar para la
 *    captura. Los tipos válidos son logical, date, numeric, string y memo.
 *    Los controles a utilizar son checkbox, datepicker, combobox o editbox
 *    (ver siguiente parámetro), textbox o editbox (ver siguiente parámetro)
 *    y editbox.
 * aFormatos
 *    Array.
 *    Datos adicionales para la captura. Dependen del tipo de datos a capturar.
 *    Logical y memo: NIL.
 *    Date: "SHOWNONE" para permitir fechas en blanco, NIL en otro caso.
 *    Numeric: array o string. Si es un array se utilizará un control combobox
 *       y el contenido del array será utilizado como items del combobox.
 *       Si es un string (o memo) se utilizará un control textbox numérico.
 *       Si el string contiene un punto decimal, su contenido se usará como
 *       máscara; si no lo contiene, el largo del string se usará para indicar
 *       la cantidad máxima de caracteres del textbox.
 *    String: numeric. Si el valor del item es menor o igual a 32 se usará
 *       un control textbox y si es mayor se usará un control editbox.
 *       El valor se utilizará para indicar la cantidad máxima de caracteres
 *       del control.
 * nFila y nColumna
 *   Numéricos
 *   Posición de la ventana.
 *   Si no son numéricos la ventana se centrará en la pantalla.
 * aTextoBotones
 *   Array con 2 ítems de tipo string
 *   Texto de los botones en la ventana de captura.
 *   Por defecto se utilizará {'Ok','Cancel'} si el lenguaje
 *   es Inglés o {'Aceptar','Cancelar'} si el lenguaje es Español.
 * nAnchoEtiqueta
 *   Numérico
 *   Ancho de las etiquetas. Por defecto se utilizará 110.
 * nAnchoControl
 *   Numérico
 *   Ancho de los controles. Por defecto se utilizará 140.
 * nAnchoBoton
 *   Numérico
 *   Ancho de los botons. Por defecto se utilizará 100.
 */

   cTitle      := "Introduzca Datos"
   aLabels     := { "Concepto:", ;
                    "Motivo:", ;
                    "Fecha:", ;
                    "Importe:", ;
                    "Contabilizar:", ;
                    "Tipo:" }
   aInitValues := { Frm1.lbl_Concepto.Value, ;
                    Frm1.lbl_Motivo.Value, ;
                    Frm1.dtp_Fecha.Value, ;
                    Frm1.txt_Importe.Value, ;
                    Frm1.chk_Contabil.Value, ;
                    Frm1.cmb_Tipo.Value }
   aFormats    := { 40, ;
                    20, ;
                    NIL, ;
                    "@E 999,999.99", ;
                    NIL, ;
                    {"Cobro", "Pago"} }

   aResults    := InputWindow( cTitle, aLabels, aInitValues, aFormats )

   Frm1.lbl_Concepto.Value := aResults[1]
   Frm1.lbl_Motivo.Value   := aResults[2]
   Frm1.dtp_Fecha.Value    := aResults[3]
   Frm1.txt_Importe.Value  := aResults[4]
   Frm1.chk_Contabil.Value := aResults[5]
   Frm1.cmb_Tipo.Value     := aResults[6]

RETURN NIL

/*
 * EOF
 */
