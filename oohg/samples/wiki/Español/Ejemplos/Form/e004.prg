/*
 * Ejemplo Form n° 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo anclar un formulario a otro,
 * utilizando el evento ON SIZE.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main
  PUBLIC oPrincipal, oHijo

  DEFINE WINDOW frm_Principal OBJ oPrincipal ;
     TITLE "Principal" ;
     AT 0, 0 ;
     MAIN ;
     ON INIT DefinirHijo() ;
     ON SIZE MoverHijo()

     @ 20, 20 LABEL lbl_1 ;
        AUTOSIZE ;
        VALUE "Mueva esta ventana !!!"

  END WINDOW
  CENTER WINDOW frm_Principal
  ACTIVATE WINDOW frm_Principal
RETURN NIL

FUNCTION DefinirHijo
  DEFINE WINDOW frm_Hijo OBJ oHijo ;
     TITLE "Hijo" ;
     AT oPrincipal:Row + 40, oPrincipal:Col + 40 ;
     CHILD ;
     ON SIZE AjustarAlPrincipal()

     @ 20, 20 LABEL lbl_1 ;
        AUTOSIZE ;
        VALUE "Mueva esta ventana !!!"

  END WINDOW
  ACTIVATE WINDOW frm_Hijo NOWAIT
RETURN NIL

FUNCTION MoverHijo
   oHijo:Row := oPrincipal:Row + 40
   oHijo:Col := oPrincipal:Col + 40
RETURN NIL

FUNCTION AjustarAlPrincipal
   IF oHijo:Row # oPrincipal:Row + 40
     oHijo:Row := oPrincipal:Row + 40
   ENDIF
   IF oHijo:Col # oPrincipal:Col + 40
     oHijo:Col := oPrincipal:Col + 40
   ENDIF
RETURN NIL

/*
 * EOF
 */
