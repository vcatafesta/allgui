/*
 * Ejemplo Picture n° 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo colocar un control Picture sobre
 * otro, cado uno con su propio ON CLICK y TOOLTIP.
 * It also shows how to dynamicaly set the excluded area of
 * the "background" picture control, using DATA aExcludeArea.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main
   LOCAL oPict1
   // Esta declaración es necesaria para la cláusula OBJECT

   DEFINE WINDOW frm_Main OBJ oWin ;
      AT 100,100 ;
      CLIENTAREA ;
      WIDTH 341 ;
      HEIGHT 155 ;
      TITLE 'Control Picture sobre Control Picture' ;
      MAIN ;
      ON INIT SetExcludeArea( oPict1 )

      @ 20,20 PICTURE img_Pict2 ;
         OBJ oPict2 ;
         WIDTH 60 ;
         HEIGHT 60 ;
         STRETCH ;
         PICTURE "oohg.jpg" ;   // 95 x 95
         ON CLICK AutoMsgBox("Pict2") ;
         TOOLTIP "Soy oPict2, haz clic sobre mi." ;
         TRANSPARENT  // Esta cláusula es necesaria
/*
   Si se omite la cláusula TRANSPARENT de img_Pict2, la imagen no
   es visible o no es pintada correctamente. Si no se utiliza esta
   cláusula, se debe definir img_Pict1 antes que img_Pict2.
   Esto se debe a que los controles son pintados en el mismo orden
   en que fueron definidos, excepto cuando alguno tiene la cláusula
   TRANSPARENT. Los controles con esta cláusula son pintados siempre
   en último lugar. Por mayor información, vea esta página:
   http://blogs.msdn.com/b/oldnewthing/archive/2012/12/17/10378525.aspx
*/
      DEFINE PICTURE img_Pict1
         OBJECT oPict1
         ROW 0
         COL 0
         IMAGESIZE .T.
         PICTURE  "logo.jpg"
         TOOLTIP "Soy oPict1, haz clic sobre mi."
         ONCLICK AutoMsgBox( "Pict1" )
         // No utilice TRANSPARENT aquí
      END PICTURE

      @ 20, 200 LABEL lbl_1 ;
         OBJ oLbl1 ;
         VALUE "LABEL" ;
         BOLD ;
         AUTOSIZE ;
         TOOLTIP "Soy un Label !!!" ;
         ON CLICK AutoMsgBox("lbl_1") ;
         TRANSPARENT

      ON KEY ESCAPE ACTION oWin:Release()
	END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL

FUNCTION SetExcludeArea( oPict1 )
/*
   Las coordenadas del area a excluir deben ser relativas a oPict1.
   Ud. puede sumar sectores adicionales agregando elementos al array
   oPict1:aExcludeArea
*/
   oPict1:aExcludeArea := ;
      { { oLbl1:col - oPict1:col, ;                   // izquierda
          oLbl1:row - oPict1:row, ;                   // arriba
          oLbl1:col - oPict1:col + oLbl1:Width, ;     // derecha
          oLbl1:row - oPict1:row + oLbl1:Height } }   // abajo
RETURN NIL

/*
   Note que si se borra la cláusula TRANSPARENT de img_Pict2, el área
   excluida funcionará como se espera pero la imagen no es visible o
   no se pinta correctamente. Sin la cláusula TRANSPARENT, debe definirse
   img_Pict1 antes que img_Pict2. La razón es que los controles son
   pintados en el mismo orden en que fuereon definidos excepto cuando
   se usa la cláusula TRANSPARENT. Los controles con esta cláusula son
   siempre pintados al final. Ver esta página para más información:
   http://blogs.msdn.com/b/oldnewthing/archive/2012/12/17/10378525.aspx
*/

/*
 * EOF
 */
