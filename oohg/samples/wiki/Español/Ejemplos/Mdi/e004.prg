/*
 * Ejemplo MDI n° 4
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo colocar una imagen en el fondo del
 * área cliente de la ventana principal de una aplicación MDI.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * La imagen fondo.jpg puede descargarse desde
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Mdi
 */

#include "oohg.ch"

PROCEDURE MAIN()
   LOCAL oMain

   DEFINE WINDOW wMain OBJ oMain ;
      AT 50,0 ;
      WIDTH  800 ;
      HEIGHT 600 ;
      TITLE "MDI" ;
      MDI

      DEFINE STATUSBAR
        STATUSITEM "El poder de OOHG !!!"
      END STATUSBAR

      DEFINE TOOLBAR TB BUTTONSIZE 70, 22 BORDER
         BUTTON TBN1 ;
            CAPTION "Nueva" ;
            ACTION NuevaChild( oMain )
         BUTTON TBN2 ;
            CAPTION "Childs" ;
            ACTION MostrarChilds( oMain )
         BUTTON TBN3 ;
            CAPTION "Cascada" ;
            ACTION OrdenarChilds( oMain, 1 )
         BUTTON TBN4 ;
            CAPTION "Mosaico H" ;
            ACTION OrdenarChilds( oMain, 2 )
         BUTTON TBN5 ;
            CAPTION "Mosaico V" ;
            ACTION OrdenarChilds( oMain, 3 )
         BUTTON TBN6 ;
            CAPTION "Ordenar" ;
            ACTION OrdenarChilds( oMain, 4 )
         BUTTON TBN7 ;
            CAPTION "Activa" ;
            ACTION AutoMsgBox( NombreChildActiva( oMain ) )
         BUTTON TBN8 ;
            CAPTION "Estado" ;
            ACTION MostrarEstado( oMain )
      END TOOLBAR

      DEFINE MAIN MENU
         ITEM "Salir" ACTION oMain:Release()
      END MENU

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

   ACTIVATE WINDOW wMain
RETURN

PROCEDURE OrdenarChilds( oMain, nAccion )
   IF HB_IsObject( oMain:oWndClient )
      IF Len( oMain:oWndClient:SplitChildList ) > 0
         DO CASE
         CASE nAccion == 1
            oMain:oWndClient:Cascade()
         CASE nAccion == 2
            oMain:oWndClient:TileHorizontal()
         CASE nAccion == 3
            oMain:oWndClient:TileVertical()
         CASE nAccion == 4
            oMain:oWndClient:IconArrange()
         ENDCASE
      ENDIF
   ENDIF
RETURN

PROCEDURE NombreChildActiva( oMain )
   LOCAL cNombre := "No hay childs activas !!!"

   IF HB_IsObject( oMain:oWndClient )
      cNombre := oMain:oWndClient:ActiveChild():Name
   ENDIF
RETURN cNombre

PROCEDURE MostrarEstado( oMain )
   LOCAL oChild, aEstado := {}

   IF HB_IsObject( oMain:oWndClient )
      FOR EACH oChild IN oMain:oWndClient:SplitChildList
         aAdd( aEstado, oChild:IsActive() )
      NEXT
      AutoMsgBox( aEstado )
   ELSE
      AutoMsgBox( "No hay childs activas !!!" )
   ENDIF
RETURN

PROCEDURE MostrarChilds( oMain )
   LOCAL oChild, aNombres := {}

   IF HB_IsObject( oMain:oWndClient )
      FOR EACH oChild IN oMain:oWndClient:SplitChildList
         aAdd( aNombres, oChild:Name )
      NEXT
      AutoMsgBox( aNombres )
   ELSE
      AutoMsgBox( "No hay childs activas !!!" )
   ENDIF
RETURN

PROCEDURE NuevaChild( oMain )
   DEFINE WINDOW 0 ;
      AT 0, 0 ;
      PARENT wMain ;
      WIDTH 300 ;
      HEIGHT 200 ;
      MDICHILD ;
      ON INIT IniciarChild( oMain, _OOHG_ThisForm ) ;
      ON RELEASE oMain:StatusBar:Item( 1, "" ) ;
      ON GOTFOCUS oMain:StatusBar:Item( 1, "Activa: " + ThisWindow:Title )

      DEFINE STATUSBAR
         STATUSITEM ""
      END STATUSBAR

      ThisWindow:StatusBar:Item( 1, ThisWindow:Name )

      @ 20, 20 LABEL lbl_1 ;
         PARENT ( ThisWindow:Name ) ;
         VALUE "Label en " + _OOHG_ThisForm:Title + " - Haz clic sobre mi !!!" ;
         AUTOSIZE ;
         FONTCOLOR RED BOLD ;
         ACTION MiMensaje( oMain:oWndClient:ActiveChild() )

      ON KEY ESCAPE ACTION ThisWindow.Release()
   END WINDOW

RETURN

PROCEDURE IniciarChild( oMain, oChild )
   LOCAL nPos

   FOR EACH oChild IN oMain:oWndClient:SplitChildList
      oChild:Hide()
   NEXT

   SetWindowBackColor( oMain:oWndClient:hWnd )

   IF ! _IsControlDefined( "Image_1", oMain:oWndClient:Name )
      DEFINE IMAGE Image_1
         PARENT (oMain:oWndClient:Name)
         ROW    0
         COL    0
         WIDTH  oMain:oWndClient:ClientWidth
         HEIGHT oMain:oWndClient:ClientHeight
         PICTURE  "fondo.jpg"
         TRANSPARENT .T.
      END IMAGE
   ENDIF

   nPos := Len( oMain:oWndClient:SplitChildList )

   oChild:Title := "Documento n° " + Ltrim( Str( nPos ) )
   oChild:Row := ( nPos - 1 ) * 20
   oChild:Col := ( nPos - 1 ) * 20

   @ 50, 20 BUTTON but_1 ;
      PARENT ( oChild ) ;
      CAPTION "Cerrar" ;
      ACTION oChild:Release()

   oMain:StatusBar:Item( 1, "Nueva child: " + oChild:Name )

   FOR EACH oChild IN oMain:oWndClient:SplitChildList
      oChild:Restore()
   NEXT

   /*
    * Note que en este punto ocurre un error en tiempo de ejecución
    * si se intenta acceder a los controles oChild:StatusBar u oChild:lbl_1.
    */
RETURN

PROCEDURE MiMensaje( oWin )
   MsgBox( "Acabas de hacer clic sobre lbl_1 de " + oWin:Name )
RETURN

/*
 * EOF
 */
