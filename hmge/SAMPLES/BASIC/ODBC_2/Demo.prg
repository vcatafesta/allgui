#include 'minigui.ch'
STATIC oConexion

PROCEDURE inicio

   SET NAVIGATION EXTENDED

   oConexion = todbc():new('DBQ=bd1.mdb;Driver={Microsoft Access Driver (*.mdb)}')
   oConexion:Open()

   DEFINE WINDOW form1;
         at 0,0 width 400 height 400 title 'Demo Odbc/Access';
         Main;
         ON INIT ( ajustar(), cargar_datos(1) );
         on maximize ( ajustar() );
         on size ( ajustar() );
         ON RELEASE ( oConexion:Destroy() );
         font 'ms sans serif' size 8

      @ 0,  0 button btn1 caption '&Agregar'    width 80 height 20 action eventos(1)
      @ 0, 80 button btn2 caption '&Editar'    width 80 height 20 action eventos(2)
      @ 0,160 button btn3 caption '&Borrar'    width 80 height 20 action eventos(3)
      @ 0,240 button btn4 caption '&Salir'    width 80 height 20 action form1.release

      DEFINE GRID grid1
         ROW 22
         COL 5
         WIDTH 300
         HEIGHT 300
         HEADERS {'Id','Descripcion'}
         WIDTHS { 60, 300 }
         ON DBLCLICK    eventos(2)
         ON CHANGE    form1.statusbar.item(1) := "Registro "+;
            ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
         COLUMNCONTROLS   { ;
            {'TEXTBOX','NUMERIC',repl('9',10)} , ;
            {'TEXTBOX','CHARACTER'} ;
            }
      END GRID

      DEFINE STATUSBAR
         statusitem "Registro "
         date
      END STATUSBAR
   END WINDOW
   form1.center
   ACTIVATE WINDOW form1

   RETURN

PROCEDURE cargar_datos(n)

   LOCAL i := 1

   form1.grid1.Deleteallitems

   oConexion:Setsql('SELECT * FROM Sucursal')

   IF !oConexion:Open()
      msgstop('No se pudo conectar la base de datos')
   ELSE
      FOR i= 1 to len( oConexion:aRecordset )
         form1.grid1.additem( oConexion:aRecordset[i] )
      NEXT
      form1.grid1.value := n
   END

   oConexion:Close()
   form1.grid1.setfocus

   RETURN

PROCEDURE eventos(n)

   LOCAL cNombre := "", Cad := ""

   DO CASE
   CASE n == 1 .or. n == 2
      IF n = 2
         cNombre := form1.grid1.cell( form1.grid1.value, 2 )
      END
      DEFINE WINDOW form1a;
            at 0,0 width 350 height 120;
            TITLE iif(n = 2,'Edicion','Agregar');
            modal;
            font 'ms sans serif' size 8

         @ 10, 10 label label1 width 80 height 20 value 'Nombre sucursal'
         @ 10,100 textbox text1 width 200 height 20 value cNombre
         @ 40,170 button button1 caption '&Aceptar' action grabar_datos( n ) width 80 height 20
         @ 40,250 button button2 caption '&Cerrar' action form1a.release width 80 height 20

         ON KEY ESCAPE ACTION form1a.button2.onclick
      END WINDOW
      form1a.center
      ACTIVATE WINDOW form1a

   CASE n == 3
      Cad := "DELETE FROM Sucursal WHERE id="+str(form1.grid1.cell(form1.grid1.value,1))
      IF msgyesno('Desea eliminar este registro '+hb_osnewline()+form1.grid1.cell(form1.grid1.value,2),'Confirmar')
         oConexion:Setsql( Cad )
         IF !oConexion:Open()
            msgstop('No se pudo eliminar el registro')
         ELSE
            n := form1.grid1.value
            form1.grid1.deleteitem( n )
            form1.grid1.value := iif(n > 1, n-1, 1)
            form1.statusbar.item(1) := "Registro "+;
               ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
         END
         oConexion:Close()
         form1.grid1.setfocus
      END
   ENDCASE

   RETURN

PROCEDURE grabar_datos(n)

   LOCAL cad := ""

   IF n = 1
      Cad := "INSERT INTO sucursal (nombre) VALUES ('"+form1a.text1.value+"')"
   ELSE
      Cad := "UPDATE sucursal SET nombre='"+form1a.text1.value+;
         "' WHERE id="+str(form1.grid1.cell(form1.grid1.value,1))
   END
   oConexion:Setsql( Cad )
   IF !oConexion:Open()
      msgstop('No se pudo actualizar la tabla Sucursal')
   END
   oConexion:Close()
   IF n == 1
      cargar_datos( form1.grid1.itemcount+1 )
   ELSE
      form1.grid1.cell( form1.grid1.value, 2 ) := form1a.text1.value
   END
   form1.statusbar.item(1) := "Registro "+;
      ltrim(str(form1.grid1.value))+" de "+alltrim(str(form1.grid1.itemcount))
   form1a.release

   RETURN

PROCEDURE ajustar()

   form1.grid1.width := form1.width - 20
   form1.grid1.height:= ( form1.height- form1.grid1.row ) - 60

   RETURN
