#include <oohg.ch>
#include "SDC_Colores.ch"

* Realizado por Sergio Castellari

DECLARE Window Parametros

* Parametros()      Carga Parametros.FMG y sirve para admininstrar parámetros  *
*                  del Sistema.                                                *

FUNCTION Parametros

   IF IsWindowActive('Parametros')
      RESTORE Window Parametros ; Parametros.SetFocus ; Return Nil
   ENDIF
   PRIVATE lMaxi:=.t.             //Maximizar Pantalla principal del Sistema
   PRIVATE cHost:='127.0.0.1'     //Host de MySql local
   PRIVATE cUser:='root'          //Nombre de Usuario
   PRIVATE cPass:='root'          //Password de acceso

   IF !File('Parametros.Ini') ; CrearIniPar() ; EndIf
   LOAD WINDOW Parametros ; Center Window Parametros
   CargarIniPar()
   ACTIVATE WINDOW Parametros

   RETURN NIL

   * CrearIniPar() Genera un archivo INI para Configuración de Parámetros.        *

FUNCTION CrearIniPar

   SET CONSOLE OFF
   SET PRINTER ON
   SET PRINTER TO Parametros.Ini
   ?? '[General]'
   ? 'Maximizar = T'

   ? '[Acceso]'
   ? 'Host  = 127.0.0.1'
   ? 'Usuario = root'
   ? 'Pass = root'

   SET CONSOLE ON
   SET PRINTER OFF
   SET PRINTER TO

   RETURN

   * CargarIniPar() Carga los valores desde Parametros.INI                        *

FUNCTION CargarIniPar

   BEGIN INI FILE "Parametros.Ini"
      GET lMaxi          SECTION "General"    ENTRY 'Maximizar'
      GET cHost          SECTION "Acceso"     ENTRY 'Host'
      GET cUser          SECTION "Acceso"     ENTRY 'Usuario'
      GET cPass          SECTION "Acceso"     ENTRY 'Pass'
   END INI
   Parametros.Check_2.Value    :=lMaxi
   Parametros.Text_1.Value     :=cUser
   Parametros.Text_2.Value     :=cPass
   Parametros.Text_3.Value     :=cHost
   Parametros.Button_1.SetFocus

   RETURN NIL

   * GrabarIniPar() Graba los valores desde Parametros.FMG                        *

FUNCTION GrabarIniPar

   BEGIN INI FILE "Parametros.Ini"
      SET SECTION "General"    ENTRY "Maximizar"     TO Parametros.Check_2.Value
      SET SECTION "Acceso"     ENTRY "Usuario"       TO Parametros.Text_1.Value
      SET SECTION "Acceso"     ENTRY "Pass"          TO Parametros.Text_2.Value
      SET SECTION "Acceso"     ENTRY "Host"          TO Parametros.Text_3.Value
   END INI
   Parametros.Release

   RETURN NIL
