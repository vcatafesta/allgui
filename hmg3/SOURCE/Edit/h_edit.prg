
/*----------------------------------------------------------------------------

* Implementación del comando EDIT para la librería HMG.
* (c) Cristóbal Mollá [cemese@terra.es]

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this file.

The exception is that, if you link this code with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking
this code into it.

*/

/***************************************************************************************
*   Historial: Mar 03  - Definición de la función.
*                      - Pruebas.
*                      - Soporte para lenguaje en inglés.
*                      - Corregido bug al borrar en bdds con CDX.
*                      - Mejora del control de parámetros.
*                      - Mejorada la función de soprte de busqueda.
*                      - Soprte para multilenguaje.
*              Abr 03  - Corregido bug en la función de busqueda (Nombre del botón).
*                      - Añadido soporte para lenguaje Ruso (Grigory Filiatov).
*                      - Añadido soporte para lenguaje Catalán.
*                      - Añadido soporte para lenguaje Portugués (Clovis Nogueira Jr).
*         - Añadido soporte para lenguaja Polaco 852 (Janusz Poura).
*         - Añadido soporte para lenguaje Francés (C. Jouniauxdiv).
*              May 03  - Añadido soporte para lenguaje Italiano (Lupano Piero).
*                      - Añadido soporte para lenguaje Alemán (Janusz Poura).
***************************************************************************************/

MEMVAR _HMG_SYSDATA

#include "hmg.ch"

// Modos.
#define ABM_MODO_VER            1
#define ABM_MODO_EDITAR         2

// Eventos de la ventana principal.
#define ABM_EVENTO_SALIR        1
#define ABM_EVENTO_NUEVO        2
#define ABM_EVENTO_EDITAR       3
#define ABM_EVENTO_BORRAR       4
#define ABM_EVENTO_BUSCAR       5
#define ABM_EVENTO_IR           6
#define ABM_EVENTO_LISTADO      7
#define ABM_EVENTO_PRIMERO      8
#define ABM_EVENTO_ANTERIOR     9
#define ABM_EVENTO_SIGUIENTE   10
#define ABM_EVENTO_ULTIMO      11
#define ABM_EVENTO_GUARDAR     12
#define ABM_EVENTO_CANCELAR    13

// Eventos de la ventana de definición de listados.
#define ABM_LISTADO_CERRAR      1
#define ABM_LISTADO_MAS         2
#define ABM_LISTADO_MENOS       3
#define ABM_LISTADO_IMPRIMIR    4

MEMVAR _HMG_CMACROTEMP

/*
* ABM()
* Descipción:
*      ABM es una función para la realización de altas, bajas y modificaciones
*      sobre una base de datos dada (el nombre del area). Esta función esta basada
*      en la libreria GUI para [x]Harbour/W32 de Roberto López, HMG.
* Limitaciones:
*      - El tamaño de la ventana de dialogo es de 640 x 480 pixels.
*      - No puede manejar bases de datos de más de 16 campos.
*      - El tamaño máximo de las etiquetas de los campos es de 70 pixels.
*      - El tamaño máximo de los controles de edición es de 160 pixels.
*      - Si no se especifica función de busqueda, esta se realiza por el
*        indice activo (si existe) y solo en campos tipo carácter y fecha.
*        El indice activo tiene que tener el mismo nombre que el campo por
*        el que va indexada la base de datos.
*      - Los campos Memo deben ir al final de la base de datos.
* Sintaxis:
*      ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
*              cArea      Cadena de texto con el nombre del area de la base de
*                         datos a tratar.
*              cTitulo    Cadena de texto con el nombre de la ventana, se le añade
*                         "Listado de " como título de los listados. Por defecto se
*                         toma el nombre del area de la base de datos.
*              aCampos    Matriz de cadenas de texto con los nombres desciptivos
*                         de los campos de la base de datos. Tiene que tener el mismo
*                         numero de elementos que campos hay en la base de datos.
*                         Por defecto se toman los nombres de los campos de la
*                         estructura de la base de datos.
*              aEditables Array de valores lógicos qie indican si un campo es editable.
*                         Normalmente se utiliza cuando se usan campos calculados y se
*                         pasa el bloque de código para el evento de guardar registro.
*                         Tiene que tener el mismo numero de elementos que campos hay en
*                         la estructura de la base de datos. Por defecto es una matriz
*                         con todos los valores verdaderos (.t.).
*              bGuardar   Bloque de codigo al que se le pasa uan matriz con los
*                         valores a guardar/editar y una variable lógica que indica
*                         si se esta editando (.t.) o añadiendo (.f.). El bloque de código
*                         tendrá la siguiente forma {|p1, p2| MiFuncion( p1, p2 ) }, donde
*                         p1 será un array con los valores para cada campo y p2 sera el
*                         valor lógico que indica el estado. Por defecto se guarda usando
*                         el código interno de la función. Tras la operación se realiza un
*                         refresco del cuadro de dialogo. La función debe devolver un valor
*                         .f. si no se quiere salir del modo de edición o cualquier otro
*                         si se desea salir. Esto es util a la hora de comprobar los valores
*                         a añadir a la base de datos.
*              bBuscar    Bloque de código para la función de busqueda. Por defecto se usa
*                         el código interno que solo permite la busqueda por el campo
*                         indexado actual, y solo si es de tipo caracter o fecha.
*/

// Declaración de variables globales.
STATIC _cArea          := ""                            // Nombre del area.
STATIC _aEstructura    := {}                            // Estructura de la bdd.
STATIC _cTitulo        := ""                            // Titulo de la ventana.
STATIC _aCampos        := {}                            // Nombre de los campos.
STATIC _aEditables     := {}                            // Controles editables.
STATIC _bGuardar       := {|| NIL }                     // Bloque para la accion guardar.
STATIC _bBuscar        := {|| NIL }                     // Bloque para la acción buscar.
STATIC _HMG_aControles     := {}                            // Controles de edición.
STATIC _aBotones       := {}                            // Controles BUTTON.
STATIC _lEditar        := .t.                           // Modo.
STATIC _aCamposListado := {}                            // Campos del listado.
STATIC _aAnchoCampo    := {}                            // Ancho campos listado.
STATIC _aNumeroCampo   := {}                            // Numero de campo del listado.

/***************************************************************************************
*     Función: ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
*       Autor: Cristóbal Mollá.
* Descripción: Crea un dialogo de altas, bajas y modificaciones a partir
*              de la estructura del area de datos pasada.
*  Parámetros: cArea        Cadena de texto con el nombre del area de la BDD.
*              [cTitulo]    Cadena de texto con el título de la ventana.
*              [aCampos]    Array con cadenas de texto para las etiquetas de los campos.
*              [aEditables] Array de valores lógicos que indican si el campo es editable.
*              [bGuardar]   Bloque de codigo para la acción de guardar registro.
*              [bBuscar]    Bloque de código para la acción de buscar registro.
*    Devuelve: NIL
****************************************************************************************/

FUNCTION ABM( cArea, cTitulo, aCampos, aEditables, bGuardar, bBuscar )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nArea             := 0                            // Area anterior.
   LOCAL nRegistro         := 0                            // Numero de registro anterior.
   LOCAL cMensaje          := ""                           // Mensajes al usuario.
   LOCAL nCampos           := 0                            // Numero de campos de la base.
   LOCAL nItem             := 1                            // Indice de iteración.
   LOCAL nFila             := 20                           // Fila de creación del control.
   LOCAL nColumna          := 20                           // Columna de creación de control.
   LOCAL aEtiquetas        := {}                           // Array con los controles LABEL.
   LOCAL aBrwCampos        := {}                           // Títulos de columna del BROWSE.
   LOCAL aBrwAnchos        := {}                           // Anchos de columna del BROWSE.
   LOCAL nBrwAnchoCampo    := 0                            // Ancho del campo para el browse.
   LOCAL nBrwAnchoRegistro := 0                            // Ancho del registro para el browse.
   LOCAL cMascara          := ""                           // Mascara de datos para el TEXTBOX.
   LOCAL nMascaraTotal     := 0                            // Tamaño de la máscara de edición.
   LOCAL nMascaraDecimales := 0                            // Tamaño de los decimales.
   LOCAL _BackDeleted

   // Inicializa el soporte multilenguaje.----------------------------------------
   InitMessages()

   ////////// Gusrdar estado actual de SET DELETED y activarlo
   _BackDeleted := set( _SET_DELETED )
   SET DELETED ON

   // Control de parámetros.
   // Area de la base de datos.---------------------------------------------------
   IF ( ValType( cArea ) != "C" ) .or. Empty( cArea )
      MsgHMGError( _HMG_SYSDATA [ 134 ][1], "" )
   ELSE
      _cArea       := cArea
      _aEstructura := (_cArea)->( dbStruct() )
      nCampos      := HMG_LEN( _aEstructura )
   ENDIF

   // Numero de campos.-----------------------------------------------------------
   IF ( nCampos > 16 )
      MsgHMGError( _HMG_SYSDATA [ 134 ][2], "" )
   ENDIF

   // Titulo de la ventana.-------------------------------------------------------
   IF ( ValType( cTitulo ) != "C" ) .or. Empty( cTitulo )
      _cTitulo := cArea
   ELSE
      _cTitulo := cTitulo
   ENDIF

   // Nombre de los campos.-------------------------------------------------------
   _aCampos := Array( nCampos )
   IF ( ValType( aCampos ) != "A" ) .or. ( HMG_LEN( aCampos ) != nCampos )
      _aCampos   := Array( nCampos )
      FOR nItem := 1 to nCampos
         _aCampos[nItem] := HMG_LOWER( _aEstructura[nItem,1] )
      NEXT
   ELSE
      FOR nItem := 1 to nCampos
         IF Valtype( aCampos[nItem] ) != "C"
            _aCampos[nItem] := HMG_LOWER( _aEstructura[nItem,1] )
         ELSE
            _aCampos[nItem] := aCampos[nItem]
         ENDIF
      NEXT
   ENDIF

   // Array de controles editables.-----------------------------------------------
   _aEditables := Array( nCampos )
   IF ( ValType( aEditables ) != "A" ) .or. ( HMG_LEN( aEditables ) != nCampos )
      _aEditables := Array( nCampos )
      FOR nItem := 1 to nCampos
         _aEditables[nItem] := .t.
      NEXT
   ELSE
      FOR nItem := 1 to nCampos
         IF Valtype( aEditables[nItem] ) != "L"
            _aEditables[nItem] := .t.
         ELSE
            _aEditables[nItem] := aEditables[nItem]
         ENDIF
      NEXT
   ENDIF

   // Bloque de codigo de la acción guardar.--------------------------------------
   IF ValType( bGuardar ) != "B"
      _bGuardar := NIL
   ELSE
      _bGuardar := bGuardar
   ENDIF

   // Bloque de código de la acción buscar.---------------------------------------
   IF ValType( bBuscar ) != "B"
      _bBuscar := NIL
   ELSE
      _bBuscar := bBuscar
   ENDIF

   // Inicialización de variables.------------------------------------------------
   aEtiquetas  := Array( nCampos, 3 )
   aBrwCampos  := Array( nCampos )
   aBrwAnchos  := Array( nCampos )
   _HMG_aControles := Array( nCampos, 3)

   // Propiedades de las etiquetas.-----------------------------------------------
   nFila    := 20
   nColumna := 20
   FOR nItem := 1 to nCampos
      aEtiquetas[nItem,1] := "lbl" + "Etiqueta" + ALLTRIM( STR( nItem ,4,0 ) )
      aEtiquetas[nItem,2] := nFila
      aEtiquetas[nItem,3] := nColumna
      nFila += 25
      IF nFila >= 200
         nFila    := 20
         nColumna := 270
      ENDIF
   NEXT

   // Propiedades del browse.-----------------------------------------------------
   FOR nItem := 1 to nCampos
      aBrwCampos[nItem] := cArea + "->" + _aEstructura[nItem,1]
      nBrwAnchoRegistro := _aEstructura[nItem,3] * 10
      nBrwAnchoCampo    := HMG_LEN( _aCampos[nItem] ) * 10
      nBrwAnchoCampo    := iif( nBrwanchoCampo >= nBrwAnchoRegistro, nBrwanchoCampo, nBrwAnchoRegistro )
      aBrwAnchos[nItem] := nBrwAnchoCampo
   NEXT

   // Propiedades de los controles de edición.------------------------------------
   nFila    := 20
   nColumna := 20
   FOR nItem := 1 to nCampos
      DO CASE
      CASE _aEstructura[nItem,2] == "C"        // Campo tipo caracter.
         _HMG_aControles[nItem,1] := "txt" + "Control" + ALLTRIM( STR( nItem ,4,0) )
         _HMG_aControles[nItem,2] := nFila
         _HMG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "N"        // Campo tipo numerico.
         _HMG_aControles[nItem,1] := "txn" + "Control" + ALLTRIM( STR( nItem ,4,0) )
         _HMG_aControles[nItem,2] := nFila
         _HMG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "D"        // Campo tipo fecha.
         _HMG_aControles[nItem,1] := "dat" + "Control" + ALLTRIM( STR( nItem ,4,0) )
         _HMG_aControles[nItem,2] := nFila
         _HMG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "L"        // Campo tipo lógico.
         _HMG_aControles[nItem,1] := "chk" + "Control" + ALLTRIM( STR( nItem ,4,0) )
         _HMG_aControles[nItem,2] := nFila
         _HMG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "M"        // Campo tipo memo.
         _HMG_aControles[nItem,1] := "edt" + "Control" + ALLTRIM( STR( nItem ,4,0) )
         _HMG_aControles[nItem,2] := nFila
         _HMG_aControles[nItem,3] := nColumna + 80
         nFila += 25
      ENDCASE
      nFila += 25
      IF nFila >= 200
         nFila    := 20
         nColumna := 270
      ENDIF
   NEXT

   // Propiedades de los botones.-------------------------------------------------
   _aBotones := { "btnCerrar", "btnNuevo", "btnEditar", ;
      "btnBorrar", "btnBuscar", "btnIr",;
      "btnListado","btnPrimero", "btnAnterior",;
      "btnSiguiente", "btnUltimo", "btnGuardar",;
      "btnCancelar" }

   // Defincinión de la ventana de edición.---------------------------------------
   DEFINE WINDOW wndABM ;
         AT     0, 0 ;
         WIDTH  640 ;
         HEIGHT 480 ;
         TITLE  _cTitulo ;
         modal ;
         NOSYSMENU ;
         font "Serif" ;
         size 8 ;
         ON INIT ABMRefresh( ABM_MODO_VER )
   END WINDOW

   // Defincición del frame.------------------------------------------------------
   @  10,  10 frame frmFrame1 of wndABM width 510 height 290

   // Defincición de las etiquetas.-----------------------------------------------
   FOR nItem := 1 to nCampos

      _HMG_cMacroTemp := aEtiquetas[nItem,1]

      @ aEtiquetas[nItem,2], aEtiquetas[nItem,3] label &_HMG_cMacroTemp ;
         of     wndABM ;
         VALUE  _aCampos[nItem] ;
         WIDTH  70 ;
         HEIGHT 21 ;
         font   "ms sans serif" ;
         size   8
   NEXT
   @ 310, 535 label  lblLabel1 ;
      of     wndABM ;
      VALUE  _HMG_SYSDATA [ 132 ][1] ;
      WIDTH  85 ;
      HEIGHT 20 ;
      font   "ms sans serif" ;
      size   8
   @ 330, 535 label  lblRegistro ;
      of     wndABM ;
      VALUE  "9999" ;
      WIDTH  85 ;
      HEIGHT 20 ;
      font   "ms sans serif" ;
      size   8
   @ 350, 535 label  lblLabel2 ;
      of     wndABM ;
      VALUE  _HMG_SYSDATA [ 132 ][2] ;
      WIDTH  85 ;
      HEIGHT 20 ;
      font   "ms sans serif" ;
      size   8
   @ 370, 535 label  lblTotales ;
      of     wndABM ;
      VALUE  "9999" ;
      WIDTH  85 ;
      HEIGHT 20 ;
      font   "ms sans serif" ;
      size   8

   // Defincición del browse.-----------------------------------------------------
   @ 310, 10 browse brwBrowse ;
      of wndABM ;
      WIDTH    510 ;
      HEIGHT   125 ;
      HEADERS  _aCampos ;
      WIDTHS   aBrwAnchos ;
      WORKAREA &_cArea ;
      FIELDS   aBrwCampos ;
      VALUE    (_cArea)->( RecNo() ) ;
      ON CHANGE {|| (_cArea)->( dbGoTo( wndABM.brwBrowse.Value ) ), ABMRefresh( ABM_MODO_VER ) }

   // Definición de los botones.--------------------------------------------------
   @ 400, 535 button btnCerrar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][1] ;
      ACTION  ABMEventos( ABM_EVENTO_SALIR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8
   @ 20, 535 button btnNuevo ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][2] ;
      ACTION  ABMEventos( ABM_EVENTO_NUEVO ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 65, 535 button btnEditar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][3] ;
      ACTION  ABMEventos( ABM_EVENTO_EDITAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 110, 535 button btnBorrar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][4] ;
      ACTION  ABMEventos( ABM_EVENTO_BORRAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 155, 535 button btnBuscar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][5] ;
      ACTION  ABMEventos( ABM_EVENTO_BUSCAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 200, 535 button btnIr ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][6] ;
      ACTION  ABMEventos( ABM_EVENTO_IR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 245, 535 button btnListado ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][7] ;
      ACTION  ABMEventos( ABM_EVENTO_LISTADO ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 20 button btnPrimero ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][8] ;
      ACTION  ABMEventos( ABM_EVENTO_PRIMERO ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 100 button btnAnterior ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][9] ;
      ACTION  ABMEventos( ABM_EVENTO_ANTERIOR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 180 button btnSiguiente ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][10] ;
      ACTION  ABMEventos( ABM_EVENTO_SIGUIENTE ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 260 button btnUltimo ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][11] ;
      ACTION  ABMEventos( ABM_EVENTO_ULTIMO ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 355 button btnGuardar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][12] ;
      ACTION  ABMEventos( ABM_EVENTO_GUARDAR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8
   @ 260, 435 button btnCancelar ;
      of      wndABM ;
      CAPTION _HMG_SYSDATA [ 133 ][13] ;
      ACTION  ABMEventos( ABM_EVENTO_CANCELAR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8

   // Defincición de los controles de edición.------------------------------------
   FOR nItem := 1 to nCampos
      DO CASE
      CASE _aEstructura[nItem,2] == "C"        // Campo tipo caracter.

         _HMG_cMacroTemp := _HMG_aControles[nItem,1]

         @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] textbox &_HMG_cMacroTemp ;
            of      wndABM ;
            HEIGHT  21 ;
            VALUE   "" ;
            WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
            font    "Arial" ;
            size    9 ;
            MAXLENGTH _aEstructura[nItem,3]

      CASE _aEstructura[nItem,2] == "N"        // Campo tipo numerico
         IF _aEstructura[nItem,4] == 0

            _HMG_cMacroTemp := _HMG_aControles[nItem,1]

            @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] textbox &_HMG_cMacroTemp ;
               of      wndABM ;
               HEIGHT  21 ;
               VALUE   0 ;
               WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
               NUMERIC ;
               MAXLENGTH _aEstructura[nItem,3] ;
               font "Arial" ;
               size 9
         ELSE
            nMascaraTotal     := _aEstructura[nItem,3]
            nMascaraDecimales := _aEstructura[nItem,4]
            cMascara := REPLICATE( "9", nMascaraTotal - (nMascaraDecimales + 1) )
            cMascara += "."
            cMascara += REPLICATE( "9", nMascaraDecimales )

            _HMG_cMacroTemp := _HMG_aControles[nItem,1]

            @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] textbox &_HMG_cMacroTemp ;
               of      wndABM ;
               HEIGHT  21 ;
               VALUE   0 ;
               WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
               NUMERIC ;
               INPUTMASK cMascara
         ENDIF
      CASE _aEstructura[nItem,2] == "D"        // Campo tipo fecha.

         _HMG_cMacroTemp := _HMG_aControles[nItem,1]

         @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] datepicker &_HMG_cMacroTemp ;
            of      wndABM ;
            VALUE   Date() ;
            WIDTH   100 ;
            font    "Arial" ;
            size    9

         *_HMG_cMacroTemp := _HMG_aControles[nItem,1]

         *wndABM.&_HMG_cMacroTemp.Height := 21

         SetProperty ( 'wndABM' , _HMG_aControles[nItem,1] , 'Height' , 21 )

      CASE _aEstructura[nItem,2] == "L"        // Campo tipo logico.

         _HMG_cMacroTemp := _HMG_aControles[nItem,1]

         @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] checkbox &_HMG_cMacroTemp ;
            of      wndABM ;
            CAPTION "" ;
            WIDTH   21 ;
            HEIGHT  21 ;
            VALUE   .t. ;
            font    "Arial" ;
            size    9
      CASE _aEstructura[nItem,2] == "M"        // Campo tipo memo.

         _HMG_cMacroTemp := _HMG_aControles[nItem,1]

         @ _HMG_aControles[nItem,2], _HMG_aControles[nItem,3] editbox &_HMG_cMacroTemp ;
            of     wndABM ;
            WIDTH  160 ;
            HEIGHT 47
      ENDCASE
   NEXT

   // Puntero de registros.------------------------------------------------------
   nArea     := Select()
   nRegistro := RecNo()
   dbSelectArea( _cArea )
   (_cArea)->( dbGoTop() )

   // Activación de la ventana.---------------------------------------------------
   center   window wndABM
   ACTIVATE WINDOW wndABM

   ////////// Restaurar SET DELETED a su valor inicial

   set( _SET_DELETED , _BackDeleted  )

   // Salida.---------------------------------------------------------------------
   (_cArea )->( dbGoTop() )
   dbSelectArea( nArea )
   dbGoTo( nRegistro )

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMRefresh( [nEstado] )
   *       Autor: Cristóbal Mollá
   * Descripción: Refresca la ventana segun el estado pasado.
   *  Parámetros: nEstado    Valor numerico que indica el tipo de estado.
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMRefresh( nEstado )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem    := 1                                     // Indice de iteración.
   LOCAL cMensaje := ""                                    // Mensajes al usuario.

   // Refresco del cuadro de dialogo.
   DO CASE
      // Modo de visualización.----------------------------------------------
   CASE nEstado == ABM_MODO_VER

      // Estado de los controles.
      // Botones Cerrar y Nuevo.
      FOR nItem := 1 to 2
         // _HMG_cMacroTemp := _aBotones[nItem]
         // wndABM.&_HMG_cMacroTemp.Enabled := .t.
         SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .T. )
      NEXT

      // Botones Guardar y Cancelar.
      FOR nItem := ( HMG_LEN( _aBotones ) - 1 ) to HMG_LEN( _aBotones )
         *_HMG_cMacroTemp := _aBotones[nItem]
         *wndABM.&_HMG_cMacroTemp.Enabled := .f.
         SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .F. )
      NEXT

      // Resto de botones.
      IF (_cArea)->( RecCount() ) == 0
         wndABM.brwBrowse.Enabled := .f.
         FOR nItem := 3 to ( HMG_LEN( _aBotones ) - 2 )
            *_HMG_cMacroTemp := _aBotones[nItem]
            *wndABM.&_HMG_cMacroTemp.Enabled := .f.
            SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .F. )
         NEXT
      ELSE
         wndABM.brwBrowse.Enabled := .t.
         FOR nItem := 3 to ( HMG_LEN( _aBotones ) - 2 )
            *_HMG_cMacroTemp := _aBotones[nItem]
            *wndABM.&_HMG_cMacroTemp.Enabled := .t.
            SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .T. )
         NEXT
      ENDIF

      // Controles de edición.
      FOR nItem := 1 to HMG_LEN( _HMG_aControles )
         *_HMG_cMacroTemp := _HMG_aControles[nItem,1]
         *wndABM.&_HMG_cMacroTemp.Enabled := .f.
         SetProperty ( 'wndABM' , _HMG_aControles[nItem,1] , 'Enabled' , .F. )
      NEXT

      // Contenido de los controles.
      // Controles de edición.
      FOR nItem := 1 to HMG_LEN( _HMG_aControles )
         *_HMG_cMacroTemp := _HMG_aControles[nItem,1]
         *wndABM.&_HMG_cMacroTemp.Value := (_cArea)->( FieldGet( nItem ) )
         SetProperty ( 'wndABM' , _HMG_aControles[nItem,1] , 'Value' , (_cArea)->( FieldGet( nItem ) ) )
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Modo de edición.----------------------------------------------------
   CASE nEstado == ABM_MODO_EDITAR

      // Estado de los controles.
      // Botones Guardar y Cancelar.
      FOR nItem := ( HMG_LEN( _aBotones ) - 1 ) to HMG_LEN( _aBotones )
         *_HMG_cMacroTemp := _aBotones[nItem]
         *wndABM.&_HMG_cMacroTemp.Enabled := .t.
         SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .T. )
      NEXT

      // Resto de los botones.
      FOR nItem := 1 to ( HMG_LEN( _aBotones ) - 2 )
         *_HMG_cMacroTemp := _aBotones[nItem]
         *wndABM.&_HMG_cMacroTemp.Enabled := .f.
         SetProperty ( 'wndABM' , _aBotones[nItem] , 'Enabled' , .f. )
      NEXT
      wndABM.brwBrowse.Enabled := .f.

      // Contenido de los controles.
      // Controles de edición.
      FOR nItem := 1 to HMG_LEN( _HMG_aControles )
         *_HMG_cMacroTemp := _HMG_aControles[nItem,1]
         *wndABM.&_HMG_cMacroTemp.Enabled := _aEditables[nItem]
         SetProperty ( 'wndABM' , _HMG_aControles[nItem,1] , 'Enabled' , _aEditables[nItem] )
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgHMGError( _HMG_SYSDATA [ 134 ][3], "" )
   END CASE

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMEventos( nEvento )
   *       Autor: Cristóbal Mollá
   * Descripción: Gestiona los eventos que se producen en la ventana wndABM.
   *  Parámetros: nEvento    Valor numérico que indica el evento a ejecutar.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABMEventos( nEvento )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem      := 1                                   // Indice de iteración.
   LOCAL cMensaje   := ""                                  // Mensaje al usuario.
   LOCAL aValores   := {}                                  // Valores de los campos de edición.
   LOCAL nRegistro  := 0                                   // Numero de registro.
   LOCAL lGuardar   := .t.                                 // Salida del bloque _bGuardar.
   LOCAL cModo      := ""                                  // Texto del modo.
   LOCAL cRegistro  := ""                                  // Numero de registro.

   // Gestión de eventos.
   DO CASE
      // Pulsación del botón CERRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_SALIR
      wndABM.Release

      // Pulsación del botón NUEVO.------------------------------------------
   CASE nEvento == ABM_EVENTO_NUEVO
      _lEditar := .f.
      cModo := _HMG_SYSDATA [ 132 ][3]
      wndABM.Title := wndABM.Title + cModo

      // Pasa a modo de edición.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edición.
      FOR nItem := 1 to HMG_LEN( _HMG_aControles )
         DO CASE
         CASE _aEstructura[nItem, 2] == "C"
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            wndABM.&(_HMG_cMacroTemp).Value := ""
         CASE _aEstructura[nItem, 2] == "N"
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            wndABM.&(_HMG_cMacroTemp).Value := 0
         CASE _aEstructura[nItem, 2] == "D"
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            wndABM.&(_HMG_cMacroTemp).Value := Date()
         CASE _aEstructura[nItem, 2] == "L"
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            wndABM.&(_HMG_cMacroTemp).Value := .f.
         CASE _aEstructura[nItem, 2] == "M"
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            wndABM.&(_HMG_cMacroTemp).Value := ""
         ENDCASE
      NEXT

      // Esteblece el foco en el primer control.
      _HMG_cMacroTemp := _HMG_aControles[1,1]
      wndABM.&(_HMG_cMacroTemp).SetFocus

      // Pulsación del botón EDITAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_EDITAR
      _lEditar := .t.
      cModo := _HMG_SYSDATA [ 132 ][4]
      wndABM.Title := wndABM.Title + cModo

      // Pasa a modo de edicion.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edición.
      FOR nItem := 1 to HMG_LEN( _HMG_aControles )
         _HMG_cMacroTemp := _HMG_aControles[nItem,1]
         wndABM.&(_HMG_cMacroTemp).Value := (_cArea)->( FieldGet(nItem) )
      NEXT

      // Establece el foco en el primer coltrol.
      _HMG_cMacroTemp := _HMG_aControles[1,1]
      wndABM.&(_HMG_cMacroTemp).SetFocus

      // Pulsación del botón BORRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BORRAR

      // Borra el registro si se acepta.
      IF MsgOKCancel( _HMG_SYSDATA [ 131 ][1], "" )
         IF (_cArea)->( rlock() )
            (_cArea)->( dbDelete() )
            (_cArea)->( dbCommit() )
            (_cArea)->( dbunlock() )
            IF .not. set( _SET_DELETED )
               SET DELETED ON
            ENDIF
            (_cArea)->( dbSkip() )
            IF (_cArea)->( eof() )
               (_cArea)->( dbGoBottom() )
            ENDIF
         ELSE
            Msgstop( _HMG_SYSDATA [ 130 ] [41] , '' )
         ENDIF
      ENDIF

      // Refresca.
      wndABM.brwBrowse.Refresh
      wndABM.brwBrowse.Value := (_cArea)->( RecNo() )

      // Pulsación del botón BUSCAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BUSCAR
      IF ValType( _bBuscar ) != "B"
         IF Empty( (_cArea)->( ordSetFocus() ) )
            msgExclamation( _HMG_SYSDATA [ 131 ][2] , "" )
         ELSE
            ABMBuscar()
         ENDIF
      ELSE
         Eval( _bBuscar )
         wndABM.brwBrowse.Value := (_cArea)->( RecNo() )
      ENDIF

      // Pulsación del botón IR AL REGISTRO.---------------------------------
   CASE nEvento == ABM_EVENTO_IR
      cRegistro := InputBox( _HMG_SYSDATA [ 132 ][5], "" )
      IF !Empty( cRegistro )
         nRegistro := Val( cRegistro )
         IF ( nRegistro != 0 ) .and. ( nRegistro <= (_cArea)->( RecCount() ) )
            (_cArea)->( dbGoTo( nRegistro ) )
            wndABM.brwBrowse.Value := nRegistro
         ENDIF
      ENDIF

      // Pulsación del botón LISTADO.----------------------------------------
   CASE nEvento == ABM_EVENTO_LISTADO
      ABMListado()

      // Pulsación del botón PRIMERO.----------------------------------------
   CASE nEvento == ABM_EVENTO_PRIMERO
      (_cArea)->( dbGoTop() )
      wndABM.brwBrowse.Value   := (_cArea)->( RecNo() )
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Pulsación del botón ANTERIOR.---------------------------------------
   CASE nEvento == ABM_EVENTO_ANTERIOR
      (_cArea)->( dbSkip( -1 ) )
      wndABM.brwBrowse.Value   := (_cArea)->( RecNo() )
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Pulsación del botón SIGUIENTE.--------------------------------------
   CASE nEvento == ABM_EVENTO_SIGUIENTE
      (_cArea)->( dbSkip( 1 ) )
      wndABM.brwBrowse.Value := (_cArea)->( RecNo() )
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Pulsación del botón ULTIMO.-----------------------------------------
   CASE nEvento == ABM_EVENTO_ULTIMO
      (_cArea)->( dbGoBottom() )
      wndABM.brwBrowse.Value   := (_cArea)->( RecNo() )
      wndABM.lblRegistro.Value := ALLTRIM( STR( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := ALLTRIM( STR( (_cArea)->(RecCount()) ) )

      // Pulsación del botón GUARDAR.----------------------------------------
   CASE nEvento == ABM_EVENTO_GUARDAR
      IF ( ValType( _bGuardar ) != "B" )

         // Guarda el registro.
         IF .not. _lEditar
            (_cArea)->( dbAppend() )
         ENDIF

         IF (_cArea)->(rlock())

            FOR nItem := 1 to HMG_LEN( _HMG_aControles )
               _HMG_cMacroTemp := _HMG_aControles[nItem,1]
               (_cArea)->( FieldPut( nItem, wndABM.&(_HMG_cMacroTemp).Value ) )
            NEXT

            (_cArea)->( dbCommit() )

            UNLOCK

            // Refresca el browse.

            wndABM.brwBrowse.Value := (_cArea)->( RecNo() )
            wndABM.brwBrowse.Refresh
            wndABM.Title := HB_USUBSTR( wndABM.Title, 1, HMG_LEN(wndABM.Title) - 12 )

         ELSE

            MsgStop ('Record locked by another user')

         ENDIF

      ELSE

         // Evalúa el bloque de código bGuardar.
         FOR nItem := 1 to HMG_LEN( _HMG_aControles )
            _HMG_cMacroTemp := _HMG_aControles[nItem,1]
            aAdd( aValores, wndABM.&(_HMG_cMacroTemp).Value )
         NEXT
         lGuardar := Eval( _bGuardar, aValores, _lEditar )
         lGuardar := iif( ValType( lGuardar ) != "L", .t., lGuardar )
         IF lGuardar
            (_cArea)->( dbCommit() )

            // Refresca el browse.
            wndABM.brwBrowse.Value := (_cArea)->( RecNo() )
            wndABM.brwBrowse.Refresh
            wndABM.Title := HB_USUBSTR( wndABM.Title, 1, HMG_LEN(wndABM.Title) - 12 )
         ENDIF
      ENDIF

      // Pulsación del botón CANCELAR.---------------------------------------
   CASE nEvento == ABM_EVENTO_CANCELAR

      // Pasa a modo de visualización.
      ABMRefresh( ABM_MODO_VER )
      wndABM.Title := HB_USUBSTR( wndABM.Title, 1, HMG_LEN(wndABM.Title) - 12 )

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgHMGError( _HMG_SYSDATA [ 134 ][4], "" )

   ENDCASE

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMBuscar()
   *       Autor: Cristóbal Mollá
   * Descripción: Definición de la busqueda
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMBuscar()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem      := 0                                   // Indice de iteración.
   LOCAL aCampo     := {}                                  // Nombre de los campos.
   LOCAL aTipoCampo := {}                                  // Matriz con los tipos de campo.
   LOCAL cCampo     := ""                                  // Nombre del campo.
   LOCAL cMensaje   := ""                                  // Mensaje al usuario.
   LOCAL nTipoCampo := 0                                   // Indice el tipo de campo.
   LOCAL cTipoCampo := ""                                  // Tipo de campo.
   LOCAL cModo      := ""                                  // Texto del modo de busqueda.

   // Obtiene el nombre y el tipo de campo.---------------------------------------
   FOR nItem := 1 to HMG_LEN( _aEstructura )
      aAdd( aCampo, _aEstructura[nItem,1] )
      aAdd( aTipoCampo, _aEstructura[nItem,2] )
   NEXT

   // Evalua si el campo indexado existe y obtiene su tipo.-----------------------
   cCampo := HMG_UPPER( (_cArea)->( ordSetFocus() ) )
   nTipoCampo := aScan( aCampo, cCampo )
   IF nTipoCampo == 0
      msgExclamation( _HMG_SYSDATA [ 131 ][3], "" )

      RETURN ( nil )
   ENDIF
   cTipoCampo := aTipoCampo[nTipoCampo]

   // Comprueba si el tipo se puede buscar.---------------------------------------
   IF ( cTipoCampo == "N" ) .or. ( cTipoCampo == "L" ) .or. ( cTipoCampo == "M" )
      MsgExclamation( _HMG_SYSDATA [ 131 ][4], "" )

      RETURN ( nil )
   ENDIF

   // Define la ventana de busqueda.----------------------------------------------
   DEFINE WINDOW wndABMBuscar ;
         AT 0, 0 ;
         WIDTH  200 ;
         HEIGHT 160 ;
         TITLE _HMG_SYSDATA [ 132 ][6] ;
         modal ;
         NOSYSMENU ;
         font "Serif" ;
         size 8
   END WINDOW

   // Define los controles de la ventana de busqueda.-----------------------------
   // Etiquetas
   @ 20, 20 label lblEtiqueta1 ;
      of wndABMBuscar ;
      VALUE "" ;
      WIDTH 160 ;
      HEIGHT 21 ;
      font "ms sans serif" ;
      size 8

   // Botones.
   @ 80, 20 button btnGuardar ;
      of      wndABMBuscar ;
      CAPTION "&" + _HMG_SYSDATA [ 133 ][5] ;
      ACTION  {|| ABMBusqueda() } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8
   @ 80, 100 button btnCancelar ;
      of      wndABMBuscar ;
      CAPTION "&" + _HMG_SYSDATA [ 133 ][13] ;
      ACTION  {|| wndABMBuscar.Release } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8

   // Controles de edición.
   DO CASE
   CASE cTipoCampo == "C"
      cModo := _HMG_SYSDATA [ 132 ][7]
      wndABMBuscar.lblEtiqueta1.Value := cModo
      @ 45, 20 textbox txtBuscar ;
         of wndABMBuscar ;
         HEIGHT 21 ;
         VALUE "" ;
         WIDTH 160 ;
         font "Arial" ;
         size 9 ;
         MAXLENGTH _aEstructura[nTipoCampo,3]
   CASE cTipoCampo == "D"
      cModo := _HMG_SYSDATA [ 132 ] [8]
      wndABMBuscar.lblEtiqueta1.Value := cModo
      @ 45, 20 datepicker txtBuscar ;
         of  wndABMBuscar ;
         VALUE   Date() ;
         WIDTH   100 ;
         font    "Arial" ;
         size    9
   ENDCASE

   // Activa la ventana.----------------------------------------------------------
   CENTER WINDOW   wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMBusqueda()
   *       Autor: Cristóbal Mollá
   * Descripción: Realiza la busqueda en la base de datos
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMBusqueda()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nRegistro := (_cArea)->( RecNo() )                // Registro anterior.

   // Busca el registro.----------------------------------------------------------
   IF (_cArea)->( dbSeek( wndABMBuscar.txtBuscar.Value ) )
      nRegistro := (_cArea)->( RecNo() )
   ELSE
      msgExclamation( _HMG_SYSDATA [ 131 ][5] , "" )
      (_cArea)->(dbGoTo( nRegistro ) )
   ENDIF

   // Cierra y actualiza.---------------------------------------------------------
   wndABMBuscar.Release
   wndABM.brwBrowse.Value := nRegistro

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMListado()
   *       Autor: Cristóbal Mollá
   * Descripción: Definición del listado.
   *  Parámetros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListado()

   // Declaración de variables locales.-------------------------------------------
   LOCAL nItem          := 1                               // Indice de iteración.
   LOCAL aCamposListado := {}                              // Matriz con los campos del listado.
   LOCAL aCamposTotales := {}                              // Matriz con los campos totales.
   LOCAL nPrimero       := 0                               // Registro inicial.
   LOCAL nUltimo        := 0                               // Registro final.
   LOCAL nRegistro      := (_cArea)->( RecNo() )           // Registro anterior.

   // Inicialización de variables.------------------------------------------------
   // Campos imprimibles.
   FOR nItem := 1 to HMG_LEN( _aEstructura )

      // Todos los campos son imprimibles menos los memo.
      IF _aEstructura[nItem,2] != "M"
         aAdd( aCamposTotales, _aEstructura[nItem,1] )
      ENDIF
   NEXT

   // Rango de registros.
   (_cArea)->( dbGoTop() )
   nPrimero := (_cArea)->( RecNo() )
   (_cArea)->( dbGoBottom() )
   nUltimo  := (_cArea)->( RecNo() )
   (_cArea)->( dbGoTo( nRegistro ) )

   // Defincicón de la ventana del proceso.---------------------------------------
   DEFINE WINDOW wndABMListado ;
         AT 0, 0 ;
         WIDTH  420 ;
         HEIGHT 295 ;
         TITLE _HMG_SYSDATA [ 132 ][10] ;
         modal ;
         NOSYSMENU ;
         font "Serif" ;
         size 8
   END WINDOW

   // Definición de los controles.------------------------------------------------
   // Frame.
   @ 10, 10 frame frmFrame1 of wndABMListado width 390 height 205

   // Label.
   @ 20, 20 label lblLabel1 ;
      of wndABMListado ;
      VALUE _HMG_SYSDATA [ 132 ][11] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      font "ms sans serif" ;
      size 8
   @ 20, 250 label lblLabel2 ;
      of     wndABMListado ;
      VALUE  _HMG_SYSDATA [ 132 ][12] ;
      WIDTH  140 ;
      HEIGHT 21 ;
      font   "ms sans serif" ;
      size   8
   @ 160, 20 label lblLabel3 ;
      of wndABMListado ;
      VALUE _HMG_SYSDATA [ 132 ][13] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      font "ms sans serif" ;
      size 8
   @ 160, 250 label lblLabel4 ;
      of wndABMListado ;
      VALUE _HMG_SYSDATA [ 132 ][14] ;
      WIDTH 140 ;
      HEIGHT 21 ;
      font "ms sans serif" ;
      size 8

   // ListBox.
   @ 45, 20 listbox lbxListado ;
      of wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCamposListado ;
      VALUE 1 ;
      font "Arial" ;
      size 9
   @ 45, 250 listbox lbxCampos ;
      of wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCamposTotales ;
      VALUE 1 ;
      font "Arial" ;
      size 9 ;
      SORT

   // Spinner.
   @ 185, 20 spinner spnPrimero ;
      of wndABMListado ;
      range 1, (_cArea)->( RecCount() ) ;
      VALUE nPrimero ;
      WIDTH 70 ;
      HEIGHT 21 ;
      font "Arial" ;
      size 9
   @ 185, 250 spinner spnUltimo ;
      of wndABMListado ;
      range 1, (_cArea)->( RecCount() ) ;
      VALUE nUltimo ;
      WIDTH 70 ;
      HEIGHT 21 ;
      font "Arial" ;
      size 9

   // Botones.
   @ 45, 170 button btnMas ;
      of      wndABMListado ;
      CAPTION _HMG_SYSDATA [ 133 ][14] ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_MAS ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8
   @ 85, 170 button btnMenos ;
      of      wndABMListado ;
      CAPTION _HMG_SYSDATA [ 133 ][15] ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_MENOS ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8
   @ 225, 240 button btnImprimir ;
      of      wndABMListado ;
      CAPTION _HMG_SYSDATA [ 133 ][16] ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_IMPRIMIR ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 225, 330 button btnCerrar ;
      of      wndABMListado ;
      CAPTION _HMG_SYSDATA [ 133 ][17] ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_CERRAR ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      font    "ms sans serif" ;
      size    8 ;
      NOTABSTOP

   // Activación de la ventana----------------------------------------------------
   center   window wndABMListado
   ACTIVATE WINDOW wndABMListado

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMListadoEvento( nEvento )
   *       Autor: Cristóbal Mollá
   * Descripción: Ejecuta los eventos de la ventana de definición del listado.
   *  Parámetros: nEvento    Valor numérico con el tipo de evento a ejecutar.
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListadoEvento( nEvento )

   // Declaración de variables locales.-------------------------------------------
   LOCAL cItem        := ""                                // Nombre del item.
   LOCAL nItem        := 0                                 // Numero del item.
   LOCAL aCampo       := {}                                // Nombres de los campos.
   LOCAL nIndice      := 0                                 // Numero del campo.
   LOCAL nAnchoCampo  := 0                                 // Ancho del campo.
   LOCAL nAnchoTitulo := 0                                 // Ancho del título.
   LOCAL nTotal       := 0                                 // Ancho total.
   LOCAL cMensaje     := ""                                // Mensaje al usuario.
   LOCAL nPrimero     := wndABMListado.spnPrimero.Value    // Registro inicial.
   LOCAL nUltimo      := wndABMListado.spnUltimo.Value     // Registro final.

   // Control de eventos.
   DO CASE
      // Cerrar el cuadro de dialogo de definición de listado.---------------
   CASE nEvento == ABM_LISTADO_CERRAR
      wndABMListado.Release

      // Añadir columna.-----------------------------------------------------
   CASE nEvento == ABM_LISTADO_MAS
      IF .not. wndABMListado.lbxCampos.ItemCount == 0 .or. ;
            wndABMListado.lbxCampos.Value == 0
         nItem := wndABMListado.lbxCampos.Value
         cItem := wndABMListado.lbxCampos.Item( nItem )
         wndABMListado.lbxListado.addItem( cItem )
         DELETE item nItem from lbxCampos of wndABMListado
      ENDIF

      // Quitar columna.-----------------------------------------------------
   CASE nevento == ABM_LISTADO_MENOS
      IF .not. wndABMListado.lbxListado.ItemCount == 0 .or. ;
            wndABMListado.lbxListado.Value == 0
         nItem := wndABMListado.lbxListado.Value
         cItem := wndABMListado.lbxListado.Item( nItem )
         wndABMListado.lbxCampos.addItem( cItem )
         DELETE item nItem from lbxListado of wndABMListado
      ENDIF

      // Imprimir listado.---------------------------------------------------
   CASE nevento == ABM_LISTADO_IMPRIMIR

      // Copia el contenido de los controles a las variables.
      _aCamposListado := {}
      FOR nItem := 1 to wndABMListado.lbxListado.ItemCount
         aAdd( _aCamposListado, wndABMListado.lbxListado.Item( nItem ) )
      NEXT

      // Establece el numero de orden del campo a listar.
      _aNumeroCampo := {}
      FOR nItem := 1 to HMG_LEN( _aEstructura )
         aAdd( aCampo, _aEstructura[nItem,1] )
      NEXT
      FOR nItem := 1 to HMG_LEN( _aCamposListado )
         aAdd( _aNumeroCampo, aScan( aCampo, _aCamposListado[nItem] ) )
      NEXT

      // Establece el ancho del campo a listar.
      _aAnchoCampo := {}
      FOR nItem := 1 to HMG_LEN( _aCamposListado )
         nIndice      := _aNumeroCampo[nItem]
         nAnchoTitulo := HMG_LEN( _aCampos[nIndice] )
         nAnchoCampo  := _aEstructura[nIndice,3]
         IF _aEstructura[nIndice,2] == "D"
            aAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo,;
               nAnchoTitulo+4,;
               nAnchoCampo+4 ) )
         ELSE
            aAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo,;
               nAnchoTitulo+2,;
               nAnchoCampo+2 ) )
         ENDIF
      NEXT

      // Comprueba el tamaño del listado y lanza la impresión.
      FOR nItem := 1 to HMG_LEN( _aAnchoCampo )
         nTotal += _aAnchoCampo[nItem]
      NEXT
      IF nTotal > 164

         // No cabe en la hoja.
         MsgExclamation( _HMG_SYSDATA [ 131 ][6], "" )
      ELSE
         IF nTotal > 109

            // Cabe en una hoja horizontal.
            ABMListadoImprimir( .t., nPrimero, nUltimo )
         ELSE

            // Cabe en una hoja vertical.
            ABMListadoImprimir( .f., nPrimero, nUltimo )
         ENDIF
      ENDIF

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgHMGError( _HMG_SYSDATA [ 134 ][5], "" )
   ENDCASE

   RETURN ( nil )

   /***************************************************************************************
   *     Función: ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )
   *       Autor: Cristóbal Mollá
   * Descripción: Lanza el listado definido a la impresora.
   *  Parámetros: lOrientacion    Lógico que indica si el listado es horizontal (.t.)
   *                              o vertical (.f.)
   *              nPrimero        Valor numerico con el primer registro a imprimir.
   *              nUltimo         Valor numérico con el último registro a imprimir.
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )

   // Declaración de variables locales.-------------------------------------------
   LOCAL nLineas   := 0                                    // Numero de linea.
   LOCAL nPaginas  := 0                                    // Numero de páginas.
   LOCAL nFila     := 12                                   // Numero de fila.
   LOCAL nColumna  := 10                                   // Numero de columna.
   LOCAL nItem     := 1                                    // Indice de iteracion.
   LOCAL nIndice   := 1                                    // Indice de campo.
   LOCAL lCabecera := .t.                                  // ¿Imprimir cabecera?.
   LOCAL lPie      := .f.                                  // ¿Imprimir pie?.
   LOCAL nPagina   := 1                                    // Numero de pagina.
   LOCAL lSalida   := .t.                                  // ¿Salir del listado?.
   LOCAL nRegistro := (_cArea)->( RecNo() )                // Registro anterior.
   LOCAL cTexto    := ""                                   // Texto para lógicos.
   LOCAL lsuccess  := .f.
   LOCAL RF := 4
   LOCAL CF := 3

   // Definición del rango del listado.-------------------------------------------
   (_cArea)->( dbGoTo( nPrimero ) )
   DO WHILE .not. ( (_cArea)->( RecNo() ) ) == nUltimo .or. ( (_cArea)->( Eof() ) )
      nLineas++
      (_cArea)->( dbSkip( 1 ) )
   ENDDO
   (_cArea)->( dbGoTo( nPrimero ) )

   // Inicialización de la impresora.---------------------------------------------

   SELECT PRINTER DIALOG TO lsuccess PREVIEW

   // Control de errores.---------------------------------------------------------

   IF lsuccess == .f.

      RETURN NIL
   ENDIF

   // Inicio del listado.
   START PRINTDOC

      lCabecera := .t.
      lSalida   := .t.
      DO WHILE lSalida

         // Cabecera.-----------------------------------------------------------
         IF lCabecera
            START PRINTPAGE
               @ 5*RF, 10*CF PRINT _HMG_SYSDATA [ 132 ][15] + _cTitulo FONT "COURIER NEW" SIZE 14 BOLD

               @ 6*RF + 2 , 10*CF PRINT LINE TO 6*RF + 2 , 62*CF PENWIDTH 0.2
               @ 7*RF, 10*CF PRINT _HMG_SYSDATA [ 132 ][16]   FONT "COURIER NEW" SIZE 10 BOLD
               @ 7*RF, 18*CF PRINT Date()                     FONT "COURIER NEW" SIZE 10
               @ 8*RF, 10*CF PRINT _HMG_SYSDATA [ 132 ][17]    FONT "COURIER NEW" SIZE 10 BOLD
               @ 8*RF, 30*CF PRINT ALLTRIM( STR( nPrimero ) ) FONT "COURIER NEW" SIZE 10
               @ 8*RF, 40*CF PRINT _HMG_SYSDATA [ 132 ][18]     FONT "COURIER NEW" SIZE 10 BOLD
               @ 8*RF, 60*CF PRINT ALLTRIM( STR( nUltimo ) )  FONT "COURIER NEW" SIZE 10
               @ 9*RF, 10*CF PRINT _HMG_SYSDATA [ 132 ][19]     FONT "COURIER NEW" SIZE 10 BOLD
               @ 9*RF, 30*CF PRINT ordName()                  FONT "COURIER NEW" SIZE 10
               nColumna := 10
               FOR nItem := 1 to HMG_LEN( _aNumeroCampo )
                  nIndice := _aNumeroCampo[nItem]
                  @ 11*RF, nColumna *CF PRINT _aCampos[nIndice] FONT "COURIER NEW" SIZE 9 BOLD UNDERLINE
                  nColumna += _aAnchoCampo[nItem]
               NEXT
               lCabecera := .f.
            ENDIF

            // Registros.-----------------------------------------------------------
            nColumna := 10
            FOR nItem := 1 to HMG_LEN( _aNumeroCampo )
               nIndice := _aNumeroCampo[nItem]
               DO CASE
               CASE _aEstructura[nIndice,2] == "L"

                  cTexto := iif( (_cArea)->( FieldGet( nIndice ) ), _HMG_SYSDATA [ 132 ][20], _HMG_SYSDATA [ 132 ][21] )
                  @ nFila*RF, nColumna *CF PRINT cTexto FONT "COURIER NEW" SIZE 10
                  nColumna += _aAnchoCampo[nItem]
               CASE _aEstructura[nIndice,2] == "N"
                  nColumna += _aAnchoCampo[nItem] - 2
                  @ nFila*RF, nColumna *CF PRINT (_cArea)->( FieldGet( nIndice ) ) FONT "COURIER NEW" SIZE 10
                  nColumna += 2
               OTHERWISE

                  @ nFila*RF, nColumna *CF PRINT (_cArea)->( FieldGet( nIndice ) ) FONT "COURIER NEW" SIZE 10
                  nColumna += _aAnchoCampo[nItem]
               ENDCASE
            NEXT
            nFila++
            (_cArea)->( dbSkip( 1 ) )

            // Pie.-----------------------------------------------------------------
            IF lOrientacion
               // Horizontal
               IF nFila > 43
                  nPaginas := Int( nLineas / 32 )
                  IF .not. Mod( nLineas, 32 ) == 0
                     nPaginas++
                  ENDIF

                  @ 45*RF, 10 *CF PRINT LINE TO 45*RF , 50 *CF PENWIDTH 0.2

                  @ 45*RF, 60/2*CF PRINT _HMG_SYSDATA [ 132 ][22] + ALLTRIM( STR( nPagina ) ) + _HMG_SYSDATA [ 132 ][23] + ALLTRIM( STR( nPaginas ) ) FONT "COURIER NEW" SIZE 10 BOLD
                  lCabecera := .t.
                  nPagina++
                  nFila := 12
               END PAGE
            ENDIF
         ELSE
            // Vertical
            IF nFila > 63
               nPaginas := Int( nLineas / 52 )
               IF .not. Mod( nLineas, 52 ) == 0
                  nPaginas++
               ENDIF

               @ 65 * RF - 1 , 10 *CF PRINT LINE TO 65 * RF - 1 , 62 * CF PENWIDTH 0.2

               @ 65*RF, 60/2*CF PRINT _HMG_SYSDATA [ 132 ][22] + ALLTRIM( STR( nPagina ) ) + _HMG_SYSDATA [ 132 ][23] + ALLTRIM( STR( nPaginas ) ) FONT "COURIER NEW" SIZE 10 BOLD
               lCabecera := .t.
               nPagina++
               nFila := 12

            END PRINTPAGE
         ENDIF
      ENDIF

      // Comprobación del rango de registro.---------------------------------
      IF ( (_cArea)->( RecNo() ) == nUltimo )
         nColumna := 10

         // Imprime el último registro.
         FOR nItem := 1 to HMG_LEN( _aNumeroCampo )
            nIndice := _aNumeroCampo[nItem]
            DO CASE
            CASE _aEstructura[nIndice,2] == "L"

               cTexto := iif( (_cArea)->( FieldGet( nIndice ) ), _HMG_SYSDATA [ 132 ][20], _HMG_SYSDATA [ 132 ][21] )
               @ nFila*RF, nColumna *CF PRINT cTexto FONT "COURIER NEW" SIZE 10
               nColumna += _aAnchoCampo[nItem]
            CASE _aEstructura[nIndice,2] == "N"
               nColumna += _aAnchoCampo[nItem] - 2
               @ nFila*RF, nColumna *CF PRINT (_cArea)->( FieldGet( nIndice ) ) FONT "COURIER NEW" SIZE 10
               nColumna += 2
            OTHERWISE
               @ nFila*RF, nColumna *CF PRINT (_cArea)->( FieldGet( nIndice ) ) FONT "COURIER NEW" SIZE 10
               nColumna += _aAnchoCampo[nItem]
            ENDCASE
         NEXT
         lSalida := .f.
      ENDIF
      IF ( (_cArea)->( Eof() ) )
         lSalida := .f.
      ENDIF
   ENDDO

   // Comprueba que se imprime el pie al finalizar.-------------------------------
   IF lOrientacion
      // Horizontal
      IF nFila <= 43
         nPaginas := Int( nLineas / 32 )
         IF .not. Mod( nLineas, 32 ) == 0
            nPaginas++
         ENDIF
         @ 45*RF, 10 *CF PRINT LINE TO 45*RF , 62*CF PENWIDTH 0.2
         @ 45*RF, 60/2*CF PRINT _HMG_SYSDATA [ 132 ][22] + ALLTRIM( STR( nPagina ) ) + _HMG_SYSDATA [ 132 ][23] + ALLTRIM( STR( nPaginas ) ) FONT "COURIER NEW" SIZE 10 BOLD
      ENDIF
   ELSE
      // Vertical
      IF nFila <= 63
         nPaginas := Int( nLineas / 52 )
         IF .not. Mod( nLineas, 52 ) == 0
            nPaginas++
         ENDIF
         @ 65*RF - 1 , 10*CF PRINT LINE TO 65*RF - 1 ,62*CF PENWIDTH 0.2
         @ 65*RF, 60/2*CF PRINT _HMG_SYSDATA [ 132 ][22] + ALLTRIM( STR( nPagina ) ) + _HMG_SYSDATA [ 132 ][23] + ALLTRIM( STR( nPaginas ) ) FONT "COURIER NEW" SIZE 10 BOLD
      ENDIF
   ENDIF

END PRINTPAGE
END PRINTDOC

// Restaura.-------------------------------------------------------------------
(_cArea)->( dbGoTo( nRegistro ) )

RETURN ( nil )

FUNCTION NoArray (OldArray)

   LOCAL NewArray := {}
   LOCAL i

   IF ValType ( OldArray ) == 'U'

      RETURN NIL
   ELSE
      Asize ( NewArray , HMG_LEN (OldArray) )
   ENDIF

   FOR i := 1 To HMG_LEN ( OldArray )

      IF OldArray [i] == .t.
         NewArray [i] := .f.
      ELSE
         NewArray [i] := .t.
      ENDIF

   NEXT i

   RETURN NewArray
