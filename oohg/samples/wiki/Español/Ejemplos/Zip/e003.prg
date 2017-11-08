/*
 * Ejemplo Zip n° 3
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo crear un archivo ZIP conteniendo
 * archivos seleccionados de una o varias carpetas.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include 'oohg.ch'
#include 'directry.ch'

FUNCTION Main()

   DEFINE WINDOW MainForm ;
      AT 114,218 ;
      WIDTH 534 ;
      HEIGHT 276 ;
      TITLE 'Crear un Zip con Archivos Seleccionados Usando la librería MiniZip' ;
      MAIN

      @ 20,20 BUTTON btn_1 ;
         CAPTION 'Crear' ;
         ACTION ZipFiles()

      ON KEY ESCAPE ACTION MainForm.Release
   END WINDOW

   MainForm.Center
   MainForm.Activate

RETURN NIL

FUNCTION ZipFiles
   LOCAL aFiles := {}

   MemoWrit( 'C:\File0.txt', 'This is file 0' )
   CreateFolder( 'C:\Data' )
   CreateFolder( 'C:\Data\Test' )
   MemoWrit( 'C:\Data\Test\File1.txt', 'This is file 1' )
   MemoWrit( 'C:\Data\Test\File2.txt', 'This is file 2' )

   /* El camino de los archivos a agregar debe ser relativo a
      una carpeta de mayor nivel. No agregue archivos como:
      \path\file.ext
      c:\path\file.ext
      ..\path\file.ext
      o tendrá problemas a la hora de extraerlos.
      Debe cambiar el directorio corriente del sistema operativo
      a una carpeta de nivel superior antes de agregar los archivos.
   */
   AEVAL( DIRECTORY( 'C:\*.TXT'), {|e| AADD( aFiles, e[1] )} )
   AEVAL( DIRECTORY( 'C:\Data\Test\*.TXT'), {|e| AADD( aFiles, 'Data\Test\' + e[1])} )

   DIRCHANGE( 'C:\' )
   HB_ZIPFILE( hb_dirbase() + 'myzip.zip', aFiles, 9, NIL , .T., NIL, .T. )
   DIRCHANGE( 'C:\' + hb_dirbase() )

   DELETE FILE 'C:\Data\Test\File2.txt'
   DELETE FILE 'C:\Data\Test\File1.txt'
   RemoveFolder( 'C:\Data\Test' )
   RemoveFolder( 'C:\Data' )
   DELETE FILE 'C:\File0.txt'

   IF FILE( hb_dirbase() + 'myzip.zip' )
      MsgInfo( 'El archivo myzip.zip fue creado !!! ')
   ELSE
      MsgStop( 'El archivo myzip.zip no fue creado !!!')
   ENDIF

RETURN NIL

/*
 * EOF
 */
