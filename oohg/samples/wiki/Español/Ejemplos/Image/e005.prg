/*
 * Ejemplo Image n° 5
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo colocar un control Image sobre
 * otro, cado uno con su propio ON CLICK y TOOLTIP.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'

FUNCTION Main
   LOCAL oImage1
   // Esta declaración es necesaria para la cláusula OBJECT

   DEFINE WINDOW frm_Main OBJ oWin ;
      AT 100,100 ;
      CLIENTAREA ;
      WIDTH 341 ;
      HEIGHT 155 ;
      TITLE 'Control Image sobre Control Image' ;
      MAIN

      @ 20,20 IMAGE img_Image2 ;
         OBJ oImage2 ;
         WIDTH 200 ;
         HEIGHT 200 ;
         NORESIZE ;
         PICTURE "oohg.jpg" ;   // 95 x 95
         ON CLICK AutoMsgBox("Image2") ;
         TOOLTIP "Soy oImage2, haz clic sobre mi." ;
         TRANSPARENT  // Esta cláusula es necesaria
/*
   Si se omite la cláusula TRANSPARENT de img_Image2, la imagen no
   es visible o no es pintada correctamente. Si no se utiliza esta
   cláusula, se debe definir img_Image1 antes que img_Image2.
   Esto se debe a que los controles son pintados en el mismo orden
   en que fueron definidos, excepto cuando alguno tiene la cláusula
   TRANSPARENT. Los controles con esta cláusula son pintados siempre
   en último lugar. Por mayor información, vea esta página:
   http://blogs.msdn.com/b/oldnewthing/archive/2012/12/17/10378525.aspx
*/
      DEFINE IMAGE img_Image1
         OBJECT oImage1
         ROW 0
         COL 0
         IMAGESIZE .T.
         PICTURE  "logo.jpg"
         TOOLTIP "Soy oImage1, haz clic sobre mi."
         ONCLICK AutoMsgBox( "Image1" )
         // No utilice TRANSPARENT aquí
      END IMAGE

      ON KEY ESCAPE ACTION oWin:Release()
	END WINDOW

   oWin:Center()
   oWin:Activate()

RETURN NIL

/*
 * EOF
 */
