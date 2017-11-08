/*
 * Ejemplo Zebra n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear códigos de barras
 * utilizando la librería Zebra.
 *
 * Adaptado del ejemplo "HMG_Zebra" incluido en el paquete HMG Extended.
 *
 * Para construir el exe ejecute:
 *    BUILDAPP demo -ic:\oohg\hb32\contrib\hbzebra
 * o:
 *    COMPILE demo -ic:\oohg\hb32\contrib\hbzebra
 * o:
 *    CREAR.BAT
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 *
 * Puede descargar demo.ico y crear.bat desde
 * https://github.com/fyurisich/OOHG_Samples/tree/master/Español/Ejemplos/Zebra
 */

#include "oohg.ch"
#include "bostaurus.ch"
#include "i_windefs.ch"
#include "hbzebra.ch"

MEMVAR aTipos
MEMVAR aValores
MEMVAR aColorBarra
MEMVAR aColorFondo

FUNCTION Main
   PRIVATE aTipos := { "EAN13", ;
                       "EAN8", ;
                       "UPCA", ;
                       "UPCE", ;
                       "CODE39", ;
                       "ITF", ;
                       "MSI", ;
                       "CODABAR", ;
                       "CODE93", ;
                       "CODE11", ;
                       "CODE128", ;
                       "PDF417", ;
                       "DATAMATRIX", ;
                       "QRCODE" }
   PRIVATE aValores := { "477012345678", ;
                         "1234567", ;
                         "01234567891", ;
                         "123456", ;
                         "ABC123", ;
                         "12345678901", ;
                         "1234", ;
                         "1234567", ;
                         "-1234", ;
                         "ABC-123", ;
                         "Code 128", ;
                         "Hola, Mundo de Harbour! Es un código 2D PDF417", ;
                         "Hola, Mundo de Harbour! Es un código 2D DataMatrix", ;
                         "https://harbour.github.io/" }
   PRIVATE aColorBarra := { 0, 0, 0 }
   PRIVATE aColorFondo := { 255, 255, 255 }

   SET DEFAULT ICON TO 'demo.ico'

   DEFINE WINDOW form ;
      AT 0, 0 ;
      WIDTH 450 HEIGHT 270 ;
      MAIN ;
      TITLE 'Generador de Códigos de Barra' ;
      NOMAXIMIZE NOSIZE

      DEFINE LABEL lbl_tipo
         ROW 10
         COL 10
         WIDTH 120
         VALUE 'Seleccione Tipo'
      END LABEL

      DEFINE COMBOBOX cmb_tipo
         ROW 10
         COL 130
         WIDTH 100
         ITEMS aTipos
         ON CHANGE form.txt_codigo.Value := aValores[ form.cmb_tipo.Value ]
      END COMBOBOX

      DEFINE LABEL lbl_codigo
         ROW 40
         COL 10
         WIDTH 100
         VALUE 'Ingrese el Código'
      END LABEL

      DEFINE TEXTBOX txt_codigo
         ROW 40
         COL 130
         WIDTH 300
      END TEXTBOX

      DEFINE LABEL lbl_ancho
         ROW 70
         COL 10
         WIDTH 100
         VALUE 'Ancho de Línea'
      END LABEL

      DEFINE SPINNER spn_ancholinea
         ROW 70
         COL 130
         WIDTH 100
         VALUE 2
         RIGHTALIGN .T.
         RANGEMIN 1
         RANGEMAX 200
      END SPINNER

      DEFINE LABEL lbl_alto
         ROW 100
         COL 10
         WIDTH 100
         VALUE 'Alto de Línea'
      END LABEL

      DEFINE SPINNER spn_altolinea
         ROW 100
         COL 130
         WIDTH 100
         VALUE 110
         RIGHTALIGN .T.
         INCREMENT 10
         RANGEMIN 10
         RANGEMAX 2000
      END SPINNER

      DEFINE LABEL lbl_colorbarra
         ROW 130
         COL 10
         WIDTH 110
         VALUE 'Color del Código'
         TOOLTIP 'Haga clic para cambiar el color!'
         ACTION CambiarColorBarra()
         VCENTERALIGN .T.
      END LABEL

      DEFINE LABEL lbl_colorfondo
         ROW 130
         COL 130
         WIDTH 100
         BACKCOLOR { 255, 255, 255 }
         VALUE 'Color del Fondo'
         TOOLTIP 'Haga clic para cambiar el color!'
         ACTION CambiarColorFondo()
         CENTERALIGN .T.
         VCENTERALIGN .T.
         BORDER .T.
      END LABEL

      DEFINE CHECKBOX chk_mostrardigitos
         ROW 160
         COL 10
         WIDTH 120
         CAPTION 'Mostrar Dígitos'
         VALUE .T.
      END CHECKBOX

      DEFINE CHECKBOX chk_digitocontrol
         ROW 160
         COL 130
         WIDTH 170
         CAPTION 'Agregar Dígito de Control'
         VALUE .T.
      END CHECKBOX

      DEFINE CHECKBOX chk_ancho2_5
         ROW 190
         COL 10
         WIDTH 120
         CAPTION 'Ancho 2.5'
         ONCHANGE IIF( This.Value, form.chk_ancho3.Value := .F., Nil )
      END CHECKBOX

      DEFINE CHECKBOX chk_ancho3
         ROW 190
         COL 130
         WIDTH 120
         CAPTION 'Ancho 3'
         ONCHANGE IIF( This.Value, form.chk_ancho2_5.Value := .F., Nil )
      END CHECKBOX

      DEFINE BUTTON btn_ok
         ROW 150
         COL 320
         WIDTH 110
         CAPTION 'Mostrar'
         ACTION MostrarCodigoBarras()
         BOTTOM .T.
      END BUTTON

      DEFINE BUTTON btn_png
         ROW 190
         COL 320
         WIDTH 110
         CAPTION 'Guardar en PNG'
         ACTION GuardarCodigoEnPNG()
      END BUTTON

      ON KEY ESCAPE ACTION ThisWindow.Release
   END WINDOW

   form.cmb_tipo.Value := 1
   form.Center
   form.Activate
RETURN Nil


FUNCTION MostrarCodigoBarras
   LOCAL hBitMap

   hBitMap := CrearCodigoDeBarras( form.txt_codigo.Value, ;
                                   form.cmb_tipo.Item( form.cmb_tipo.Value ), ;
                                   form.spn_ancholinea.Value, ;
                                   form.spn_altolinea.Value, ;
                                   form.chk_mostrardigitos.Value, ;
                                   '', ;
                                   aColorBarra, ;
                                   aColorFondo, ;
                                   form.chk_digitocontrol.Value, ;
                                   form.chk_ancho2_5.Value, ;
                                   form.chk_ancho3.Value )
   IF hBitMap == 0
      RETURN Nil
   ENDIF

   IF OSisWinXPorLater()
      SET WINDOW form TRANSPARENT TO 150
   ENDIF

   DEFINE WINDOW frm_mostrarcodigobarras ;
      AT BT_DesktopHeight() / 2, BT_DesktopWidth() / 2 ;
      WIDTH  BT_BitmapWidth( hBitmap ) + 300 ;
      HEIGHT BT_BitmapHeight( hBitmap ) + 150 ;
      TITLE 'Código de Barras' ;
      MODAL NOMAXIMIZE ;
      ON RELEASE {|| BT_BitmapRelease( hBitmap ), IIF( OSisWinXPorLater(), SET WINDOW form TRANSPARENT TO OPAQUE, Nil ) }

      @ 10, 10 IMAGE img_imagen HBITMAP hBitmap
   END WINDOW

   FLASH WINDOW frm_mostrarcodigobarras COUNT 5 INTERVAL 50

   ACTIVATE WINDOW frm_mostrarcodigobarras
RETURN Nil


FUNCTION GuardarCodigoEnPNG
   LOCAL cNombreImagen

   cNombreImagen := PutFile( { { "Archivos PNG", "*.png" } }, "Guardar Código de Barras en Archivo PNG" )
   IF LEN( cNombreImagen ) == 0
      RETURN Nil
   ENDIF
   IF FILE( cNombreImagen )
      IF MsgYesNo( 'El archivo ya existe. ¿Desea sobrescribirlo?', 'Confirmación' )
         FERASE( cNombreImagen )
      ELSE
         RETURN Nil
      ENDIF
   ENDIF
   CrearCodigoDeBarras( form.txt_codigo.Value, ;
                        form.cmb_tipo.Item( form.cmb_tipo.Value ), ;
                        form.spn_ancholinea.Value, ;
                        form.spn_altolinea.Value, ;
                        form.chk_mostrardigitos.Value, ;
                        cNombreImagen, ;
                        aColorBarra, ;
                        aColorFondo, ;
                        form.chk_digitocontrol.Value, ;
                        form.chk_ancho2_5.Value, ;
                        form.chk_ancho3.Value )
   IF FILE( cNombreImagen )
      EXECUTE FILE cNombreImagen
   ENDIF
RETURN Nil


FUNCTION CambiarColorBarra
   LOCAL aColor := GetColor( form.lbl_barcolor.FontColor )

   IF VALTYPE( aColor[ 1 ] ) == 'N'
      form.lbl_barcolor.FontColor := aColor
      aColorBarra := aColor
   ENDIF
RETURN Nil
   

FUNCTION CambiarColorFondo
   LOCAL aColor := GetColor( form.lbl_backgroundcolor.BackColor )

   IF VALTYPE( aColor[ 1 ] ) == 'N'
      form.lbl_backgroundcolor.BackColor := aColor
      aColorFondo := aColor
   ENDIF
RETURN Nil


/*
  La función CrearCodigoDeBarras() puede ser usada para crear imágenes en formato PNG de códigos de barras si se incluye el parámetro cNombreImagen.
  Si cNombreImagen se omite, la función retorna el hBitMap de la imagen.
  Los tipos de código de barras permitidos son:
  { "EAN13", "EAN8", "UPCA", "UPCE", "CODE39", "ITF", "MSI", "CODABAR", "CODE93", "CODE11", "CODE128", "PDF417", "DATAMATRIX", "QRCODE" }
  En caso de omitirse, el dígito de control será generado por la librería.
*/

FUNCTION CrearCodigoDeBarras( cCodigo, cTipo, nAnchoLinea, nAltoLinea, lMostrarDigitos, cNombreImagen, aColorBarra, aColorFondo, lDigitoControl, lAncho2_5, lAncho3 )
   LOCAL hBitmap, cTexto, nFlags

   DEFAULT nAnchoLinea := 2
   DEFAULT nAltoLinea := 100
   DEFAULT aColorBarra := BLACK
   DEFAULT aColorFondo := WHITE
   DEFAULT lDigitoControl := .F.
   DEFAULT lAncho2_5 := .F.
   DEFAULT lAncho3 := .F.
   DEFAULT lMostrarDigitos := .F.
   DEFAULT cNombreImagen := ''

   nFlags := 0
   IF lDigitoControl
      nFlags := nFlags + HB_ZEBRA_FLAG_CHECKSUM
   ENDIF
   IF lAncho2_5
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE2_5
   ENDIF
   IF lAncho3
      nFlags := nFlags + HB_ZEBRA_FLAG_WIDE3
   ENDIF

   IF nFlags == 0
      nFlags := Nil
   ENDIF

   cTexto   := ""
   hBitmap := Zebra_CreateBitmapBarcode( aColorBarra, aColorFondo, nAnchoLinea, nAltoLinea, cTipo, cCodigo, nFlags, lMostrarDigitos, @cTexto )

   IF hBitmap == 0
      RETURN hBitmap
   ENDIF

   IF LEN( cNombreImagen ) <> 0
      BT_BitmapSaveFile( hBitmap, cNombreImagen, BT_FILEFORMAT_PNG )
      BT_BitmapRelease( hBitmap )
      RETURN 1
   ENDIF
RETURN hBitmap


FUNCTION Zebra_CreateBitmapBarcode( aColorBarra, aColorFondo, nAnchoLinea, nAltoLinea, cTipo, cCodigo, nFlags, lMostrarDigitos, cTexto )
   LOCAL hBitmap := 0, hZebra
   LOCAL hDC, BTstruct, nTamanioFuente
   LOCAL nAncho, nAlto
   LOCAL cFuente := 'Arial'

   SWITCH cTipo
   CASE "EAN13"      ; hZebra := hb_zebra_create_ean13( cCodigo, nFlags )      ;                                                          EXIT
   CASE "EAN8"       ; hZebra := hb_zebra_create_ean8( cCodigo, nFlags )       ;                                                          EXIT
   CASE "UPCA"       ; hZebra := hb_zebra_create_upca( cCodigo, nFlags )       ;                                                          EXIT
   CASE "UPCE"       ; hZebra := hb_zebra_create_upce( cCodigo, nFlags )       ;                                                          EXIT
   CASE "CODE39"     ; hZebra := hb_zebra_create_code39( cCodigo, nFlags )     ;                                                          EXIT
   CASE "ITF"        ; hZebra := hb_zebra_create_itf( cCodigo, nFlags )        ;                                                          EXIT
   CASE "MSI"        ; hZebra := hb_zebra_create_msi( cCodigo, nFlags )        ;                                                          EXIT
   CASE "CODABAR"    ; hZebra := hb_zebra_create_codabar( cCodigo, nFlags )    ;                                                          EXIT
   CASE "CODE93"     ; hZebra := hb_zebra_create_code93( cCodigo, nFlags )     ;                                                          EXIT
   CASE "CODE11"     ; hZebra := hb_zebra_create_code11( cCodigo, nFlags )     ;                                                          EXIT
   CASE "CODE128"    ; hZebra := hb_zebra_create_code128( cCodigo, nFlags )    ;                                                          EXIT
   CASE "PDF417"     ; hZebra := hb_zebra_create_pdf417( cCodigo, nFlags )     ; nAltoLinea := nAnchoLinea * 3 ; lMostrarDigitos := .F. ; EXIT
   CASE "DATAMATRIX" ; hZebra := hb_zebra_create_datamatrix( cCodigo, nFlags ) ; nAltoLinea := nAnchoLinea     ; lMostrarDigitos := .F. ; EXIT
   CASE "QRCODE"     ; hZebra := hb_zebra_create_qrcode( cCodigo, nFlags )     ; nAltoLinea := nAnchoLinea     ; lMostrarDigitos := .F. ; EXIT
   ENDSWITCH

   IF hZebra != Nil
      IF hb_zebra_geterror( hZebra ) == 0
         cTexto  := hb_zebra_getcode( hZebra )
         nAncho  := Zebra_GetWidth( hZebra, nAnchoLinea, nAltoLinea, Nil )
         nAlto   := Zebra_GetHeight( hZebra, nAnchoLinea, nAltoLinea, Nil ) + IIF( lMostrarDigitos, ( nAnchoLinea * 10 ) + 20, 0 )
         hBitmap := BT_BitmapCreateNew( nAncho, nAlto, aColorFondo )
         hDC     := BT_CreateDC( hBitmap, BT_HDC_BITMAP, @BTstruct )
         Zebra_Draw( hZebra, hDC, aColorBarra, 0, 0, nAnchoLinea, nAltoLinea, Nil )
         IF lMostrarDigitos
            nTamanioFuente := ( ( nAncho / LEN( cTexto ) ) / 96 * 72 * 1 )
            BT_DrawText( hDC, nAlto - ( ( nAnchoLinea * 10 ) + 20 ) + 5, nAncho / 2, cTexto, cFuente, nTamanioFuente, aColorBarra, aColorFondo, Nil, BT_TEXT_CENTER )
         ENDIF
         BT_DeleteDC( BTstruct )
      ELSE
         MsgInfo( "Tipo " + cTipo + CRLF + "Código " + cCodigo + CRLF + "Error  " + LTRIM( HB_VALTOSTR( hb_zebra_geterror( hZebra ) ) ) )
      ENDIF
      hb_zebra_destroy( hZebra )
   ELSE
      MsgStop( "Tipo de código no válido !", cTipo )
   ENDIF
RETURN hBitmap


FUNCTION Zebra_Draw( hZebra, hDC, aColorBarra, nRow, nCol, nAnchoLinea, nAltoLinea, iFlags )
   IF hb_zebra_GetError( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF
//     hb_zebra_draw( hZebra, bCodeBlock,                                                            dX,   dY,   dWidth,     dHeight,     iFlags )
RETURN hb_zebra_draw( hZebra, { |x, y, w, h| BT_DrawFillRectangle( hDC, y, x, w, h, aColorBarra ) }, nCol, nRow, nAnchoLinea, nAltoLinea, iFlags )


FUNCTION Zebra_GetWidth( hZebra, nAnchoLinea, nAltoLinea, iFlags )
   LOCAL x1 := 0, y1 := 0, nAncho := 0, nAlto := 0

   // always --> nAlto = nAltoLinea
   IF hb_zebra_GetError( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF
// hb_zebra_draw( hZebra, bCodeBlock,                                                         dX, dY, dWidth,     dHeight,     iFlags )
   hb_zebra_draw( hZebra, { |x, y, w, h| nAncho := x + w - x1, nAlto := y + h - y1 }, x1, y1, nAnchoLinea, nAltoLinea, iFlags )
RETURN nAncho


FUNCTION Zebra_GetHeight( hZebra, nAnchoLinea, nAltoLinea, iFlags )
   LOCAL x1 := 0, y1 := 0, nAncho := 0, nAlto := 0

   // always --> nAlto = nAltoLinea
   IF hb_zebra_GetError( hZebra ) != 0
      RETURN HB_ZEBRA_ERROR_INVALIDZEBRA
   ENDIF
// hb_zebra_draw( hZebra, bCodeBlock,                                                          dX, dY, dWidth,     dHeight,     iFlags )
   hb_zebra_draw( hZebra, { |x, y, w, h | nAncho := x + w - x1, nAlto := y + h - y1 }, x1, y1, nAnchoLinea, nAltoLinea, iFlags )
RETURN nAlto

/*
 * EOF
 */
