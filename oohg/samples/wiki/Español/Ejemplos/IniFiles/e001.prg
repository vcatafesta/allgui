/*
 * Ejemplo Archivos INI n° 1
 * Autor: Fernando Yurisich <fernando.yurisich@gmail.com>
 * Licenciado bajo The Code Project Open License (CPOL) 1.02
 * Ver <http://www.codeproject.com/info/cpol10.aspx>
 *
 * Este ejemplo muestra cómo guardar/cargar la estructura
 * de una DBF en/desde un archivo INI.
 *
 * Visítenos en https://github.com/fyurisich/OOHG_Samples o en
 * http://oohg.wikia.com/wiki/Object_Oriented_Harbour_GUI_Wiki
 */

#include "oohg.ch"
#include "dbstruct.ch"

FUNCTION Main

   LOCAL aStruc, i, cSection, nCount, cName, cType, nLength, nDecimals

   // Para que los números se guarden sin decimales
   SET DECIMALS TO 0

   /* Para cargar aStruc a partir de una DBF, utilice
   USE table
   aStruc := table->( DBSTRUCT() )
   */

   aStruc := { {'CODE', "C", 3, 0}, {'DESCRIP', "C", 55, 0} }

   /*
   Este código graba la estructura de una DBF en un archivo INI
   */
   ERASE table.ini

   BEGIN INI FILE "table.ini"
      SET SECTION "FIELDS" ENTRY "COUNT" TO LEN( aStruc )

      FOR i := 1 to LEN( aStruc )
         cSection := "Field #" + ltrim( str( i ) )

         SET SECTION cSection ENTRY "NAME"     TO aStruc[ i, DBS_NAME ]
         SET SECTION cSection ENTRY "TYPE"     TO aStruc[ i, DBS_TYPE ]
         SET SECTION cSection ENTRY "LENGTH"   TO aStruc[ i, DBS_LEN ]
         SET SECTION cSection ENTRY "DECIMALS" TO aStruc[ i, DBS_DEC ]
      NEXT i
   END INI

   /*
   Este código lee la estructura de una DBF desde un archivo INI
   */
   BEGIN INI FILE "table.ini"
      /*
      Estas sentencias son necesarias para que los datos sean cargados
      con el tipo correcto.
      */
      nCount := 0
      cName := ""
      cType := ""
      nLength := 0
      nDecimals := 0

      GET nCount SECTION "FIELDS" ENTRY "COUNT" DEFAULT 0

      aStruc := ARRAY( nCount )

      FOR i := 1 to nCount
         cSection := "FIELD #" + LTRIM( STR( i, 19, 0 ) )

         GET cName     SECTION cSection ENTRY "NAME"     DEFAULT ""
         GET cType     SECTION cSection ENTRY "TYPE"     DEFAULT ""
         GET nLength   SECTION cSection ENTRY "LENGTH"   DEFAULT 0
         GET nDecimals SECTION cSection ENTRY "DECIMALS" DEFAULT 0

         aStruc[ i ] := { cName, cType, nLength, nDecimals }
      NEXT i
   END INI

   /* Para crear la DBF a partir de aStruc, utilice
   DBCREATE( "table", aStruc )
   */

RETURN NIL

/*
 * EOF
 */
