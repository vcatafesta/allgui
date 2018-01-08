#include "hmg.ch"

SET Procedure To HMG_Zebra.prg

MEMVAR aTypeItems
MEMVAR aValues
MEMVAR aBarColor
MEMVAR aBackColor

FUNCTION Main

   PRIVATE aTypeItems :={;
      "EAN13","EAN8","UPCA","UPCE","CODE39","ITF","MSI","CODABAR",;
      "CODE93","CODE11","CODE128","PDF417","DATAMATRIX","QRCODE"}

   PRIVATE aValues :={;
      "477012345678","1234567","01234567891","123456","ABC123","12345678901","1234","1234567",;
      "-1234","ABC-123","Code 128","Hello, World of Harbour! It's 2D barcode PDF417",;
      "Hello, World of Harbour! It's 2D barcode DataMatrix","http://harbour-project.org/"}
   PRIVATE aBarColor := { 0, 0, 0 }
   PRIVATE aBackColor := { 255, 255, 255 }

   SET DEFAULT ICON TO 'demo.ico'

   DEFINE WINDOW barcode at 0, 0 width 300 height 310 main title 'HMG - BarCode Generator' nomaximize nosize
      DEFINE LABEL barcodetypelabel
         ROW 10
         COL 10
         WIDTH 100
         VALUE 'Select a Type'
      END LABEL
      DEFINE COMBOBOX type
         ROW 10
         COL 110
         WIDTH 100
         ITEMS aTypeItems
         ON CHANGE barcode.code.value := aValues [ barcode.Type.value ]
      END COMBOBOX

      DEFINE LABEL codelabel
         ROW 40
         COL 10
         WIDTH 100
         VALUE 'Enter the Code'
      END LABEL
      DEFINE TEXTBOX code
         ROW 40
         COL 110
         WIDTH 120
         //         maxlength 13
      END TEXTBOX
      DEFINE LABEL widthlabel
         ROW 70
         COL 10
         WIDTH 100
         VALUE 'Line Width'
      END LABEL
      DEFINE SPINNER linewidth
         ROW 70
         COL 110
         WIDTH 80
         VALUE 2
         RIGHTALIGN .t.
         RANGEMIN 1
         RANGEMAX 200
      END spinner
      DEFINE LABEL heightlabel
         ROW 100
         COL 10
         WIDTH 100
         VALUE 'Barcode Height'
      END LABEL
      DEFINE SPINNER lineheight
         ROW 100
         COL 110
         WIDTH 80
         VALUE 110
         RIGHTALIGN .t.
         INCREMENT 10
         RANGEMIN 10
         RANGEMAX 2000
      END spinner
      DEFINE CHECKBOX showdigits
         ROW 130
         COL 10
         WIDTH 120
         CAPTION 'Display Code'
         VALUE .t.
      END CHECKBOX
      DEFINE CHECKBOX checksum
         ROW 130
         COL 150
         WIDTH 120
         CAPTION 'Checksum'
         VALUE .t.
      END CHECKBOX
      DEFINE CHECKBOX wide2_5
         ROW 160
         COL 10
         WIDTH 120
         CAPTION 'Wide 2.5'
         ONCHANGE iif( this.value, barcode.wide3.value := .f., )
      END CHECKBOX
      DEFINE CHECKBOX wide3
         ROW 160
         COL 150
         WIDTH 120
         CAPTION 'Wide 3'
         ONCHANGE iif( this.value, barcode.wide2_5.value := .f., )
      END CHECKBOX
      DEFINE LABEL barcolor
         ROW 190
         COL 10
         WIDTH 110
         FONTCOLOR { 0, 0, 0 }
         VALUE 'Barcode Color'
         FONTSIZE 11
         TOOLTIP 'Click to change color!'
         ACTION changebarcolor()
         ALIGNMENT center
         ALIGNMENT vcenter
      END LABEL
      DEFINE LABEL backgroundcolor
         ROW 190
         COL 150
         WIDTH 100
         BACKCOLOR { 255, 255, 255 }
         VALUE 'Back Color'
         FONTSIZE 11
         TOOLTIP 'Click to change color!'
         ACTION changebackcolor()
         ALIGNMENT center
         ALIGNMENT vcenter
      END LABEL

      DEFINE BUTTON ok
         ROW 230
         COL 60
         WIDTH 90
         CAPTION 'Show Barcode'
         ACTION createbarcode()
      END BUTTON
      DEFINE BUTTON png
         ROW 230
         COL 160
         WIDTH 90
         CAPTION 'Save to PNG'
         ACTION createbarcodepng()
      END BUTTON

   END WINDOW
   barcode.type.value := 1
   barcode.center
   barcode.activate

   RETURN NIL

FUNCTION CreateBarCode

   LOCAL hBitMap

   hBitMap := HMG_CreateBarCode( barcode.code.value,;
      barcode.type.item( barcode.type.value ),;
      barcode.linewidth.value,;
      barcode.lineheight.value,;
      barcode.showdigits.value,;
      '',;
      aBarColor,;
      aBackColor,;
      barcode.checksum.value,;  // checksum
      barcode.wide2_5.value,;   // wide2_5
      barcode.wide3.value )     // wide3
   IF hBitMap == 0

      RETURN NIL
   ENDIF

   IF IsWinXPorLater()
      SET WINDOW barcode TRANSPARENT TO 150   // nAlphaBlend = 0 to 255 (completely transparent = 0, opaque = 255)
   ENDIF

   DEFINE WINDOW Form1;
         AT BT_DesktopHeight()/2, BT_DesktopWidth()/2 ;
         WIDTH  BT_BitmapWidth  ( hBitmap ) + 100 ;
         HEIGHT BT_BitmapHeight ( hBitmap ) + 100 ;
         TITLE 'Display Bar Code' ;
         MODAL ;
         ON RELEASE {|| BT_BitmapRelease ( hBitmap ), iif( IsWinXPorLater(), SET WINDOW barcode TRANSPARENT TO OPAQUE, ) }

      @ 10, 10 IMAGE Image1 PICTURE ""
      BT_HMGSetImage ("Form1", "Image1", hBitmap)
   END WINDOW

   FLASH WINDOW Form1 COUNT 5 INTERVAL 50

   ACTIVATE WINDOW Form1

   RETURN NIL

FUNCTION CreateBarCodepng

   LOCAL cImageFileName

   cImageFileName := putfile( { { "PNG Files", "*.png" } }, "Save Barcode to PNG File" )
   IF len( cImageFileName ) == 0

      RETURN NIL
   ENDIF
   IF file( cImageFileName )
      IF msgyesno( 'Image file already exists. Do you want to overwrite?', 'Confirmation' )
         ferase( cImageFileName )
      ELSE

         RETURN NIL
      ENDIF
   ENDIF
   HMG_CreateBarCode( barcode.code.value,;
      barcode.type.item( barcode.type.value ),;
      barcode.linewidth.value,;
      barcode.lineheight.value,;
      barcode.showdigits.value,;
      cImageFileName,;
      aBarColor,;
      aBackColor,;
      barcode.checksum.value,;  // checksum
      barcode.wide2_5.value,;   // wide2_5
      barcode.wide3.value )     // wide3
   IF file( cImageFileName )
      _Execute ( GetActiveWindow() , , cImageFileName, , , 5 )
   ENDIF

   RETURN NIL

FUNCTION changebarcolor

   LOCAL aColor := getcolor( barcode.barcolor.fontcolor )

   IF valtype( acolor[ 1 ] ) == 'N'
      barcode.barcolor.fontcolor := aColor
      aBarColor := aColor
   ENDIF

   RETURN NIL

FUNCTION changebackcolor

   LOCAL aColor := getcolor( barcode.backgroundcolor.backcolor )

   IF valtype( acolor[ 1 ] ) == 'N'
      barcode.backgroundcolor.backcolor := aColor
      aBackColor := aColor
   ENDIF

   RETURN NIL
