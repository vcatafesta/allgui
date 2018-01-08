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

///#xcommand WITH <oObject> DO => Self := <oObject>
///#xcommand ENDWITH           => Self := NIL

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
            MENUITEM 'Busqueda POR APELLIDO' Action Bus()
            MENUITEM 'Busqueda POR telefono' Action Bus1()
            MENUITEM 'Agregar' Action Addrec()
            MENUITEM 'Borrar' Action Borrarec()
            MENUITEM  'INDEX' action indexa()
            MENUITEM 'borra index' action borrai()
            MENUITEM  "version " action automsgbox(miniguiversion())
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

      ::SetSQL( "CREATE INDEX pornUM ON ABI (NUMERO)" )
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

      ::SetSQL( "DROP INDEX pornUM ON ABI" )

      IF .not. ::Open()
         msgbox("error")
      ENDIF

      ::Close()

   END

   RETURN

PROCEDURE conectar()

   ///Public cConStr   := ;
   ///"Driver={Advantage StreamlineSQL ODBC};SourceType=DBF;SourceDB=c:\oohginstall\oohg\samples\odbc;"

   ///  Public cConStr   :=
   ///   "Driver={Microsoft Visual FoxPro Driver};SourceType=DBF;SourceDB=c:\analisis\iden;Exclusive=No;Collate=Machine;NULL=NO;DELETED=NO;BACKGROUNDFETCH=NO;"

   PUBLIC cConStr := ;
      "Driver={Microsoft Visual FoxPro Driver};SourceType=DBF;SourceDB=c:\oohg\samples\odbc; Exclusive=No;Collate=Machine;NULL=NO;Deleted=NO"

   ////  cConStr := "DBQ=" + hb_FNameMerge( hb_DirBase(), "bd1.mdb" ) + ";Driver={Microsoft Access Driver (*.mdb)}"
   PUBLIC  dsFunctions := TODBC():New( cConStr ) // cConStr )

   IF .not. (dsfunctions:FETCH( SQL_FETCH_FIRST)= SQL_ERROR)
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

   ///WITH  dsFunctions DO

   dsFunctions:SetSQL( "SELECT * FROM ABI order by NOMBRE " )

   dsFunctions:Open()
   dsFunctions:skip()

   creg:=""
   contador:=0
   ///DO WHILE (dsFunctions:FETCH( SQL_FETCH_NEXT ,1)= SQL_SUCCESS)
   /////DO WHILE .NOT. :EOF()
   ///creg:=creg+ dsFunctions:Fieldbyname("nombre"):value+  chr(13)+chr(10)

   IF hb_isobject(dsfunctions)
      msgbox("si")
   ENDIF
   ww:=(dsFunctions:Fieldbyname( "NOMBRE" ):value)
   automsgbox(ww)
   contador++
   ///IF CONTADOR>=25
   IF .not. msgyesno(creg,"Continua ?")
      ///  exit
   ELSE
      CREG:=""
      CONTADOR:=0
   ENDIF
   ///ENDIF

   ///ENDDO
   dsFunctions:Close()

   ///END
   RETURN( NIL )

PROCEDURE Bus()

   LOCAL csearch:=upper(inputbox("Busca APELLIDO","Pregunta"))

   ///WITH OBJECT dsFunctions

   a:=seconds()

   dsFunctions:SetSQL( "SELECT top 50 * FROM ABI WHERE Nombre LIKE "+"'"+csearch+"%'" )

   IF .not. dsFunctions:Open()
      msgbox("error")
   ENDIF

   creg:=""
   sw:=0
   cn:=0
   WHILE (dsFunctions:FETCH( SQL_FETCH_NEXT ,1)= SQL_SUCCESS)
      creg:=creg+dsFunctions:FieldByName( "NOMBRE" ):Value+" "+(dsFunctions:FieldByName( "Numero" ):Value )+chr(13)+chr(10)
      sw:=1
      cn++
   ENDDO
   IF sw=1
      ////         b:=seconds()
      automsginfo(creg)
      ///         automsgbox(b-a)
   ELSE
      msgbox("registro no encontrado")
   ENDIF

   dsFunctions:Close()

   ///      :destroy()
   ///END

   RETURN  NIL

PROCEDURE Bus1()

   LOCAL csearch:=inputbox("Busca TELEFONO","Pregunta")

   WITH OBJECT dsFunctions

      a:=seconds()

      ::lcachers:=.T.
      ::SetSQL( "SELECT * FROM abi WHERE NUMERO = "+CSEARCH )

      IF .not. :Open()
         msgbox("error")
      ENDIF
      CREG:=""
      SW:=0
      WHILE .not. :eof()
         creg:=creg+::FieldByName( "NOMBRE" ):Value+" "+(::FieldByName( "Numero" ):Value )+chr(13)+chr(10)
         ::skip()
         sw:=1
      ENDDO
      IF sw=1
         automsginfo(creg)
         ///         automsgbox(b-a)
      ELSE
         msgbox("registro no encontrado")
      ENDIF

      ::lcachers:=.F.

      ::Close()

      ///      :destroy()

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
      ::SetSQL( "INSERT INTO ABI VALUES " + cinserta )
      IF (:Open())
         msgbox("registro agregado")
      ELSE
         msgbox("fallo agrega registro")
      ENDIF

      ::Close()

   END

   RETURN  NIL

PROCEDURE borrarec()

   LOCAL csearch:=ALLTRIM(upper(inputbox("Numero :","Pregunta")))

   WITH OBJECT dsFunctions

      ::SetSQL( "SELECT * FROM ABI WHERE NUMERO = "+csearch )
      ::Open()
      IF .not. ::eof()
         IF  msgyesno("Esta seguro de borrar: "+csearch)
            ::close()
            ::SetSQL( "DELETE FROM ABI WHERE NUMERO = "+csearch )
            IF (::Open())
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
