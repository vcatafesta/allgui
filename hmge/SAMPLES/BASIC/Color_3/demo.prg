/*
* CAS - webcas@bol.com.br
* Create : 14/11/2003
* Modify : 26/8/2004  00:58am
*        : backcolor,fontcolor in textbox
*        : backcolor,fontcolor in label
* Revized: 05/01/2007 by Grigory Filatov
*/

#include "minigui.ch"

MEMVAR c_txt_back, c_txt_color
MEMVAR c_lbl_back, c_lbl_color

FUNCTION Main

   LOCAL cas_n, cas_var, cas_lbl, m_col

   PRIVATE c_txt_back  := {255, 255,   0}
   PRIVATE c_txt_color := {255, 255, 255}

   PRIVATE c_lbl_back  := {0, 255, 255}
   PRIVATE c_lbl_color := {0, 255, 255}

   SET NAVIGATION EXTENDED

   DEFINE WINDOW Form_cas ;
         AT 0,0 WIDTH 400 HEIGHT 400 ;
         TITLE 'Press UP or DOWN or ENTER  -   by CAS' MAIN ;
         BACKCOLOR {0, 255, 255}

      ON KEY DOWN ACTION InsertTab()
      ON KEY UP   ACTION InsertShiftTab()
      ON KEY ESCAPE ACTION Form_cas.Release

      FOR cas_n=1 to 10
         cas_var := 'TEXT_' + alltrim(str(cas_n))
         cas_lbl := 'LBL_'  + alltrim(str(cas_n))

         @ cas_n*30 , 30 LABEL &cas_lbl value cas_lbl ;
            width 95 height 25 backcolor c_lbl_color

         m_col := form_cas.&(cas_lbl).col + form_cas.&(cas_lbl).width + 20

         @ cas_n*30 , m_col TEXTBOX &cas_var value cas_var width 200 ;
            ON LOSTFOCUS cas_func(1) ;
            ON GOTFOCUS cas_func() ;
            BACKCOLOR c_txt_color ;
            FONTCOLOR {0,0,0}
      NEXT

   END WINDOW

   Form_cas.Center
   Form_cas.Activate

   RETURN NIL

   *............................................................................*

STATIC FUNCTION cas_func(...)

   LOCAL var_text  := this.name
   LOCAL var_label := 'LBL_' + substr(var_text, 6)

   IF pcount() # 0

      form_cas.&(var_label).fontbold := .f.
      form_cas.&(var_label).fontsize := 9

      form_cas.&(var_label).backcolor := c_lbl_color
      form_cas.&(var_text).backcolor  := c_txt_color

   ELSE

      form_cas.&(var_label).fontbold := .t.
      form_cas.&(var_label).fontsize := 12

      form_cas.&(var_label).backcolor := c_lbl_back
      form_cas.&(var_text).backcolor  := c_txt_back

      form_cas.&(var_text).caretpos  := 0
      * caretpos = 0, foi colocado para não selecionar todo o texto
      * caretpos = 0, it was put for not selecting the whole text

   ENDIF

   RETURN NIL
