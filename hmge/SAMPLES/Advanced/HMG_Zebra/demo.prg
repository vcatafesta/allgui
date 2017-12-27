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
         row 10
         col 10
         width 100
         value 'Select a Type'
      END LABEL
      DEFINE COMBOBOX type
         row 10
         col 110
         width 100
         items aTypeItems
         ON CHANGE barcode.code.value := aValues [ barcode.Type.value ]
      END COMBOBOX

      DEFINE LABEL codelabel
         row 40
         col 10
         width 100
         value 'Enter the Code'
      END LABEL
      DEFINE TEXTBOX code
         row 40
         col 110
         width 120
         //         maxlength 13
      END TEXTBOX
      DEFINE LABEL widthlabel
         row 70
         col 10
         width 100
         value 'Line Width'
      END LABEL
      DEFINE SPINNER linewidth
         row 70
         col 110
         width 80
         value 2
         rightalign .t.
         rangemin 1
         rangemax 200
      end spinner
      DEFINE LABEL heightlabel
         row 100
         col 10
         width 100
         value 'Barcode Height'
      END LABEL
      DEFINE SPINNER lineheight
         row 100
         col 110
         width 80
         value 110
         rightalign .t.
         increment 10
         rangemin 10
         rangemax 2000
      end spinner
      DEFINE CHECKBOX showdigits
         row 130
         col 10
         width 120
         caption 'Display Code'
         value .t.
      END CHECKBOX
      DEFINE CHECKBOX checksum
         row 130
         col 150
         width 120
         caption 'Checksum'
         value .t.
      END CHECKBOX
      DEFINE CHECKBOX wide2_5
         row 160
         col 10
         width 120
         caption 'Wide 2.5'
         onchange iif( this.value, barcode.wide3.value := .f., )
      END CHECKBOX
      DEFINE CHECKBOX wide3
         row 160
         col 150
         width 120
         caption 'Wide 3'
         onchange iif( this.value, barcode.wide2_5.value := .f., )
      END CHECKBOX
      DEFINE LABEL barcolor
         row 190
         col 10
         width 110
         fontcolor { 0, 0, 0 }
         value 'Barcode Color'
         fontsize 11
         tooltip 'Click to change color!'
         action changebarcolor()
         alignment center
         alignment vcenter
      END LABEL
      DEFINE LABEL backgroundcolor
         row 190
         col 150
         width 100
         backcolor { 255, 255, 255 }
         value 'Back Color'
         fontsize 11
         tooltip 'Click to change color!'
         action changebackcolor()
         alignment center
         alignment vcenter
      END LABEL

      DEFINE BUTTON ok
         row 230
         col 60
         width 90
         caption 'Show Barcode'
         action createbarcode()
      END BUTTON
      DEFINE BUTTON png
         row 230
         col 160
         width 90
         caption 'Save to PNG'
         action createbarcodepng()
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
