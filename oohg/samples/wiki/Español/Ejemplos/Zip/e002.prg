/*
 * Ejemplo Zip n° 2
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo extraer todos los archivos de un
 * archivo ZIP mientras se recrea la estructura de carpetas
 * almacenada.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'
#include 'directry.ch'

FUNCTION Main()
   LOCAL oUnzip, oZipFile, oFolder

   DEFINE WINDOW FormPrin ;
      AT 114,218 ;
      WIDTH 534 ;
      HEIGHT 276 ;
      TITLE 'Como Extraer Archivos de un ZIP Usando la Librería MiniZip' ;
      MAIN

      @ 20,20 BUTTON btn_1 ;
         CAPTION 'Archivo ZIP' ;
         ACTION oUnzip:Enabled := ! EMPTY( oZipFile:Value := GetFile( { {'Zip Files','*.zip'} }, 'Archivo ZIP', 'C:\' ) )

      @ 20,140 BUTTON btn_2 ;
         CAPTION 'Carpeta Destino' ;
         ACTION oUnzip:Enabled := ! EMPTY( oFolder:Value := BrowseForFolder( Nil, BIF_NEWDIALOGSTYLE, 'Carpeta Destino', 'C:\' ) )

      @ 20,260 BUTTON btn_3 ;
         OBJ oUnzip ;
         CAPTION 'Extraer' ;
         ACTION ExtraerArchivos( oZipFile:Value, oFolder:Value ) ;
         DISABLED

      @ 60,20 PROGRESSBAR prg_1 ;
         SMOOTH ;
         WIDTH 480

      @ 100,20 LABEL lbl_1 ;
         VALUE "" ;
         WIDTH 480

      @ 150,20 LABEL lbl_2 ;
         OBJ oZipFile ;
         VALUE "" ;
         WIDTH 480

      @ 200,20 LABEL lbl_3 ;
         OBJ oFolder ;
         VALUE "" ;
         WIDTH 480

      ON KEY ESCAPE ACTION FormPrin.Release
   END WINDOW

   FormPrin.Center
   FormPrin.Activate

RETURN NIL

FUNCTION ExtraerArchivos( cArchZip, cFolder )

   FormPrin.prg_1.RangeMax := hb_GetFileCount( cArchZip )

   IF Right( cFolder, 1 ) != "\"
      cFolder += "\"
   ENDIF

   hb_UnzipFile( cArchZip, {|cArch, nPos| Progreso( nPos, cArch ) }, .T., Nil, cFolder )

   MsgInfo( "Hecho !!!" )

   FormPrin.prg_1.Value := 0
   FormPrin.lbl_1.Value := ""

RETURN

FUNCTION Progreso( nPos, cArch )

   FormPrin.prg_1.Value := nPos
   FormPrin.lbl_1.Value := cArch

RETURN NIL

/*
 * EOF
 */
