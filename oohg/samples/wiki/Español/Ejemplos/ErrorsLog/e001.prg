/*
 * Ejemplo Errors Log n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * This sample shows how to change the name and the folder
 * of the runtime errors log.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"

FUNCTION Main

   SET AUTOADJUST ON
   SET LANGUAGE TO SPANISH

   DEFINE WINDOW Form_1 ;
      AT 0,0 ;
      WIDTH 500 ;
      HEIGHT 500 ;
      TITLE "OOHG - Cambiar Nombre, Carpeta y Lenguaje del Log de Errores" ;
      MAIN ;
      ON INIT AUTOMSGBOX(VARIABLE_INEXISTENT)
      /*
       * VARIABLE_INEXISTENT genera un error
       * lo que hace que se cree el log de errores
       */

      @ 10,10 LISTBOX List_1 ;
         OBJ oList ;
         ITEMS { 'Uno', 'Dos', 'Tres', 'Cuatro', 'Cinco' } ;
         VALUE 1 ;
         HEIGHT 310 ;
         WIDTH 300
   END WINDOW

   /*
    * Los valores por defecto son Inglés, Carpeta del EXE y ERRORLOG.HTM
    */
   PUBLIC _OOHG_TxtError := OOHG_TErrorHtml():New( SET( _SET_LANGUAGE ) )
   _OOHG_TxtError:Path     := "C:\"
   _OOHG_TxtError:FileName := "MiLogDeErrores.htm"
   _OOHG_TxtError:cBufferScreen := ;
      "Por favor, reporte este error al programador." + ;
      hb_osnewline() + ;
      "Gracias." + ;
      hb_osnewline() + ;
      hb_osnewline()

   CENTER WINDOW Form_1
   ACTIVATE WINDOW Form_1

RETURN Nil

/*
 * EOF
 */
