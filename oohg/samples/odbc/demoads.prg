/*
* MiniGUI ODBC Demo
* Based upon code from:
*        ODBCDEMO - ODBC Access Class Demonstration
*        Felipe G. Coury <fcoury@flexsys-ci.com>
* oohg Version:
*        Ciro Vargas Clemow
* For help about hbodbc class use, download harbour contributions package
* from www.harbour-project.org and look at ODBC folder.
*/

#include "oohg.ch"
#include "sql.ch"

FUNCTION Main

   DEFINE WINDOW Win_1 ;
         AT 0,0 ;
         WIDTH 400 ;
         HEIGHT 400 ;
         TITLE 'OOHG ODBC Demo ADS DBF/CDX ' ;
         MAIN  on init conectar() ;
         on release cerrar()

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            MENUITEM 'Listado' ACTION list()
            menuitem 'Busqueda POR APELLIDO' Action Bus()
            menuitem 'Busqueda POR telefono' Action Bus1()
            menuitem 'Agregar' Action Addrec()
            menuitem 'Borrar' Action Borrarec()
            menuitem  'INDEX' action indexa()
            menuitem 'borra index' action borrai()
            menuitem  "version " action automsgbox(miniguiversion())
         END POPUP
      END MENU

   END WINDOW
   ACTIVATE WINDOW Win_1

   RETURN

PROCEDURE INDEXA()

   WITH OBJECT dsFunctions
      ///      :SetSQL( "CREATE INDEX pornom ON ABI (NOMBRE)" )
      ////      :setsql( "ALTER TABLE ABI ADD INDEX pornumero (numero)")

      ///      if .not. :Open()
      ///          msgbox("error")
      ///      endif

      :SetSQL( "CREATE INDEX pornUM ON ABI (NUMERO)" )
      ////         :setsql( "ALTER TABLE ABI ADD INDEX pornumero (numero)")

      IF .not. :Open()
         msgbox("error")
      ELSE
         MSGBOX("INDEXADO")
      ENDIF

      :Close()

   END

   RETURN

PROCEDURE borrai()

   WITH OBJECT dsFunctions
      //      :SetSQL( "DROP INDEX pornom ON ABI" )
      ///         :setsql( "ALTER TABLE ABI ADD INDEX pornumero (numero)")

      //      if .not. :Open()
      //          msgbox("error")
      //      endif

      :SetSQL( "DROP INDEX pornUM ON ABI" )

      IF .not. :Open()
         msgbox("error")
      ENDIF

      :Close()

   END

   RETURN

PROCEDURE conectar()

   PUBLIC cConStr   := ;
      "Driver={Advantage StreamlineSQL ODBC};SourceType=DBF;SourceDB=c:\analisis\iden;"

   PUBLIC  dsFunctions := TODBC():New( cConStr ) // cConStr )

   IF SQL_ERROR = -1
      msgbox("si conecto")
   ELSE
      msgbox("no conecto")

      RETURN
   ENDIF

   dsfunctions:lcachers:=.F.

   RETURN

PROCEDURE cerrar()

   dsFunctions:Destroy()

   RETURN

PROCEDURE list()

   LOCAL i

   WITH OBJECT dsFunctions

      :SetSQL( "SELECT * FROM ABI order by NOMBRE " )

      :Open()

      creg:=""
      contador:=0
      DO WHILE (:FETCH( SQL_FETCH_NEXT ,1)= SQL_SUCCESS)
         creg:=creg+ :Fieldbyname("nombre"):value+ :fieldbyname("NUMERO"):value+ chr(13)+chr(10)
         contador++
         IF CONTADOR>=25
            IF .not. msgyesno(creg,"Continua ?")
               EXIT
            ELSE
               CREG:=""
               CONTADOR:=0
            ENDIF
         ENDIF

      ENDDO
      :Close()

   END

   RETURN( NIL )

PROCEDURE Bus()

   LOCAL csearch:=upper(inputbox("Busca APELLIDO","Pregunta"))

   WITH OBJECT dsFunctions

      a:=seconds()

      :SetSQL( "SELECT top 50 * FROM ABI WHERE Nombre LIKE "+"'"+csearch+"%'" )

      IF .not. :Open()
         msgbox("error")
      ENDIF

      creg:=""
      sw:=0
      cn:=0
      WHILE (:FETCH( SQL_FETCH_NEXT ,1)= SQL_SUCCESS)
         creg:=creg+:FieldByName( "NOMBRE" ):Value+" "+(:FieldByName( "Numero" ):Value )+chr(13)+chr(10)
         sw:=1
         cn++
      ENDDO
      IF sw=1

         automsginfo(creg)

      ELSE
         msgbox("registro no encontrado")
      ENDIF

      :Close()

   END

   RETURN  NIL

PROCEDURE Bus1()

   LOCAL csearch:=inputbox("Busca TELEFONO","Pregunta")

   WITH OBJECT dsFunctions

      a:=seconds()

      :lcachers:=.T.
      :SetSQL( "SELECT * FROM abi WHERE NUMERO = "+CSEARCH )

      IF .not. :Open()
         msgbox("error")
      ENDIF
      CREG:=""
      SW:=0
      WHILE .not. :eof()
         creg:=creg+:FieldByName( "NOMBRE" ):Value+" "+(:FieldByName( "Numero" ):Value )+chr(13)+chr(10)
         :skip()
         sw:=1
      ENDDO
      IF sw=1
         automsginfo(creg)
         ///         automsgbox(b-a)
      ELSE
         msgbox("registro no encontrado")
      ENDIF

      :lcachers:=.F.

      :Close()

   END

   RETURN  NIL

PROCEDURE addrec()

   LOCAL csearch:=upper(inputbox("Nombre :","Pregunta"))
   LOCAL csearch1:=upper(inputbox("Numero :","Pregunta"))

   IF empty(csearch) .or. empty(csearch1)
      msginfo("no se puede a¤adir datos en blanco")

      RETURN NIL
   ENDIF

   WITH OBJECT dsFunctions

      cinserta:="(" + csearch1 +",'" + csearch + "',' "+ "',' ',' ',' "+ "')"
      automsgbox(cinserta)
      :SetSQL( "INSERT INTO ABI VALUES " + cinserta )
      IF (:Open())
         msgbox("registro agregado")
      ELSE
         msgbox("fallo agrega registro")
      ENDIF

      :Close()

   END

   RETURN  NIL

PROCEDURE borrarec()

   LOCAL csearch:=ALLTRIM(upper(inputbox("Numero :","Pregunta")))

   WITH OBJECT dsFunctions

      :SetSQL( "SELECT * FROM ABI WHERE NUMERO = "+csearch )
      :Open()
      IF .not. :eof()
         IF  msgyesno("Esta seguro de borrar: "+csearch)
            :close()
            :SetSQL( "DELETE FROM ABI WHERE NUMERO = "+csearch )
            IF (:Open())
               msgbox("registro borrado")
            ELSE
               MSGBOX("NO SE PUDO BORRAR")
            ENDIF
         ENDIF
      ELSE
         msgbox("registro no encontrado")
      ENDIF

      :close()
   END

   RETURN NIL
