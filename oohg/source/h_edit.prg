/*
* $Id: h_edit.prg $
*/
/*
* ooHG source code:
* EDIT WORKAREA command
* Copyright 2005-2017 Vicente Guerra <vicente@guerra.com.mx>
* https://oohg.github.io/
* Portions of this project are based upon Harbour MiniGUI library.
* Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
* Portions of this project are based upon Harbour GUI framework for Win32.
* Copyright 2001 Alexander S. Kresin <alex@belacy.belgorod.su>
* Copyright 2001 Antonio Linares <alinares@fivetech.com>
* Portions of this project are based upon Harbour Project.
* Copyright 1999-2017, https://harbour.github.io/
*/
/*
* This program is free software; you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation; either version 2, or (at your option)
* any later version.
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
* You should have received a copy of the GNU General Public License
* along with this software; see the file LICENSE.txt. If not, write to
* the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1335,USA (or download from http://www.gnu.org/licenses/).
* As a special exception, the ooHG Project gives permission for
* additional uses of the text contained in its release of ooHG.
* The exception is that, if you link the ooHG libraries with other
* files to produce an executable, this does not by itself cause the
* resulting executable to be covered by the GNU General Public License.
* Your use of that executable is in no way restricted on account of
* linking the ooHG library code into it.
* This exception does not however invalidate any other reasons why
* the executable file might be covered by the GNU General Public License.
* This exception applies only to the code released by the ooHG
* Project under the name ooHG. If you copy code from other
* ooHG Project or Free Software Foundation releases into a copy of
* ooHG, as the General Public License permits, the exception does
* not apply to the code that you add in this way. To avoid misleading
* anyone as to the status of such modified files, you must delete
* this exception notice from them.
* If you write modifications of your own for ooHG, it is your choice
* whether to permit this exception to apply to your modifications.
* If you do not wish that, delete this exception notice.
*/

/*
* - Descripci�n -
* ===============
*      EDIT WORKAREA, es un comando que permite realizar altas, bajas y modificaciones
*      sobre una base de datos.
* - Sint�xis -
* ============
*      Todos los par�metros del comando EDIT WORKAREA son opcionales, con excepci�n del �rea de trabajo.
*      EDIT WORKAREA cArea      ;
*       [ TITLE cTitulo ]       ;
*       [ FIELDS aCampos ]      ;
*       [ READONLY aEditables ] ;
*       [ SAVE bGuardar ]       ;
*       [ SEARCH bBuscar ]
*      Ver detalle de par�metros en funci�n ABM().
* - Historial -
* =============
*              Mar 03  - Definici�n de la funci�n.
*                      - Pruebas.
*                      - Soporte para lenguaje en ingl�s.
*                      - Corregido bug al borrar en bdds con CDX.
*                      - Mejora del control de par�metros.
*                      - Mejorada la funci�n de soprte de busqueda.
*                      - Soprte para multilenguaje.
*              Abr 03  - Corregido bug en la funci�n de busqueda (Nombre del bot�n).
*                      - A�adido soporte para lenguaje Ruso (Grigory Filiatov).
*                      - A�adido soporte para lenguaje Catal�n.
*                      - A�adido soporte para lenguaje Portugu�s (Clovis Nogueira Jr).
*         - A�adido soporte para lenguaja Polaco 852 (Janusz Poura).
*         - A�adido soporte para lenguaje Franc�s (C. Jouniauxdiv).
*              May 03  - A�adido soporte para lenguaje Italiano (Lupano Piero).
*                      - A�adido soporte para lenguaje Alem�n (Janusz Poura).
*/

#include "oohg.ch"

#define NO_HBPRN_DECLARATION
#include "winprint.ch"

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

// Eventos de la ventana de definici�n de listados.
#define ABM_LISTADO_CERRAR      1
#define ABM_LISTADO_MAS         2
#define ABM_LISTADO_MENOS       3
#define ABM_LISTADO_IMPRIMIR    4

/*
* ABM()
* Descipci�n:
*      ABM es una funci�n para la realizaci�n de altas, bajas y modificaciones
*      sobre una base de datos dada (el nombre del area). Esta funci�n esta basada
*      en la libreria GUI para [x]Harbour/W32 de Roberto L�pez, MiniGUI.
* Limitaciones:
*      - El tama�o de la ventana de dialogo es de 640 x 480 pixels.
*      - No puede manejar bases de datos de m�s de 16 campos.
*      - El tama�o m�ximo de las etiquetas de los campos es de 70 pixels.
*      - El tama�o m�ximo de los controles de edici�n es de 160 pixels.
*      - Si no se especifica funci�n de busqueda, esta se realiza por el
*        indice activo (si existe) y solo en campos tipo car�cter y fecha.
*        El indice activo tiene que tener el mismo nombre que el campo por
*        el que va indexada la base de datos.
*      - Los campos Memo deben ir al final de la base de datos.
* Sintaxis:
*      ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
*              cArea      Cadena de texto con el nombre del area de la base de
*                         datos a tratar.
*              cTitulo    Cadena de texto con el nombre de la ventana, se le a�ade
*                         "Listado de " como t�tulo de los listados. Por defecto se
*                         toma el nombre del area de la base de datos.
*              aCampos    Matriz de cadenas de texto con los nombres desciptivos
*                         de los campos de la base de datos. Tiene que tener el mismo
*                         numero de elementos que campos hay en la base de datos.
*                         Por defecto se toman los nombres de los campos de la
*                         estructura de la base de datos.
*              aEditables Array de valores l�gicos qie indican si un campo es editable.
*                         Normalmente se utiliza cuando se usan campos calculados y se
*                         pasa el bloque de c�digo para el evento de guardar registro.
*                         Tiene que tener el mismo numero de elementos que campos hay en
*                         la estructura de la base de datos. Por defecto es una matriz
*                         con todos los valores verdaderos (.t.).
*              bGuardar   Bloque de codigo al que se le pasa uan matriz con los
*                         valores a guardar/editar y una variable l�gica que indica
*                         si se esta editando (.t.) o a�adiendo (.f.). El bloque de c�digo
*                         tendr� la siguiente forma {|p1, p2| MiFuncion( p1, p2 ) }, donde
*                         p1 ser� un array con los valores para cada campo y p2 sera el
*                         valor l�gico que indica el estado. Por defecto se guarda usando
*                         el c�digo interno de la funci�n. Tras la operaci�n se realiza un
*                         refresco del cuadro de dialogo. La funci�n debe devolver un valor
*                         .f. si no se quiere salir del modo de edici�n o cualquier otro
*                         si se desea salir. Esto es util a la hora de comprobar los valores
*                         a a�adir a la base de datos.
*              bBuscar    Bloque de c�digo para la funci�n de busqueda. Por defecto se usa
*                         el c�digo interno que solo permite la busqueda por el campo
*                         indexado actual, y solo si es de tipo caracter o fecha.
*/

// Declaraci�n de variables globales. // TODO: thread safe?
STATIC _cArea          := ""                            // Nombre del area.
STATIC _aEstructura    := {}                            // Estructura de la bdd.
STATIC _cTitulo        := ""                            // Titulo de la ventana.
STATIC _aCampos        := {}                            // Nombre de los campos.
STATIC _aEditables     := {}                            // Controles editables.
STATIC _bGuardar       := {|| NIL }                     // Bloque para la accion guardar.
STATIC _bBuscar        := {|| NIL }                     // Bloque para la acci�n buscar.
STATIC _OOHG_aControles     := {}                            // Controles de edici�n.
STATIC _aBotones       := {}                            // Controles BUTTON.
STATIC _lEditar        := .t.                           // Modo.
STATIC _aCamposListado := {}                            // Campos del listado.
STATIC _aAnchoCampo    := {}                            // Ancho campos listado.
STATIC _aNumeroCampo   := {}                            // Numero de campo del listado.

/***************************************************************************************
*     Funci�n: ABM( cArea, [cTitulo], [aCampos], [aEditables], [bGuardar], [bBuscar] )
*       Autor: Crist�bal Moll�.
* Descripci�n: Crea un di�logo de altas, bajas y modificaciones a partir
*              de la estructura del area de datos pasada.
*  Par�metros: cArea        Cadena de texto con el nombre del �rea de la BDD.
*              [cTitulo]    Cadena de texto con el t�tulo de la ventana.
*              [aCampos]    Array con cadenas de texto para las etiquetas de los campos.
*              [aEditables] Array de valores l�gicos que indican si el campo es editable.
*              [bGuardar]   Bloque de c�digo para la acci�n de guardar registro.
*              [bBuscar]    Bloque de c�digo para la acci�n de buscar registro.
*    Devuelve: NIL
****************************************************************************************/

FUNCTION ABM( cArea, cTitulo, aCampos, aEditables, bGuardar, bBuscar )

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nArea             // := 0                         // �rea anterior.
   LOCAL nRegistro         // := 0                         // N�mero de registro anterior.

   // local cMensaje          := ""                        // Mensajes al usuario.
   LOCAL nCampos              := 0                         // N�mero de campos de la base.
   LOCAL nItem             // := 1                         // �ndice de iteraci�n.
   LOCAL nFila             // := 20                        // Fila de creaci�n del control.
   LOCAL nColumna          // := 20                        // Columna de creaci�n de control.
   LOCAL aEtiquetas        // := {}                        // Array con los controles LABEL.
   LOCAL aBrwCampos        // := {}                        // T�tulos de columna del BROWSE.
   LOCAL aBrwAnchos        // := {}                        // Anchos de columna del BROWSE.
   LOCAL nBrwAnchoCampo    // := 0                         // Ancho del campo para el browse.
   LOCAL nBrwAnchoRegistro // := 0                         // Ancho del registro para el browse.
   LOCAL cMascara          // := ""                        // M�scara de datos para el TEXTBOX.
   LOCAL nMascaraTotal     // := 0                         // Tama�o de la m�scara de edici�n.
   LOCAL nMascaraDecimales // := 0                         // Tama�o de los decimales.
   LOCAL _BackDeleted

   ////////// Guardar estado actual de SET DELETED y activarlo
   _BackDeleted := set( _SET_DELETED )
   SET DELETED ON

   // Control de par�metros.
   // �rea de la base de datos.---------------------------------------------------
   IF ( ! VALTYPE( cArea ) $"CM" ) .or. Empty( cArea )
      MsgOOHGError( _OOHG_Messages( 8, 1 ), "" )
   ELSE
      _cArea       := cArea
      _aEstructura := (_cArea)->( dbStruct() )
      nCampos      := Len( _aEstructura )
   ENDIF

   // N�mero de campos.-----------------------------------------------------------
   IF ( nCampos > 16 )
      MsgOOHGError( _OOHG_Messages( 8, 2 ), "" )
   ENDIF

   // T�tulo de la ventana.-------------------------------------------------------
   IF ( ! VALTYPE( cTitulo ) $ "CM" ) .or. Empty( cTitulo )
      _cTitulo := cArea
   ELSE
      _cTitulo := cTitulo
   ENDIF

   // Nombre de los campos.-------------------------------------------------------
   _aCampos := Array( nCampos )
   IF ( !HB_IsArray( aCampos ) ) .or. ( Len( aCampos ) != nCampos )
      _aCampos   := Array( nCampos )
      FOR nItem := 1 to nCampos
         _aCampos[nItem] := Lower( _aEstructura[nItem,1] )
      NEXT
   ELSE
      FOR nItem := 1 to nCampos
         IF ! (VALTYPE( aCampos[nItem] )  $ "CM" )
            _aCampos[nItem] := Lower( _aEstructura[nItem,1] )
         ELSE
            _aCampos[nItem] := aCampos[nItem]
         ENDIF
      NEXT
   ENDIF

   // Array de controles editables.-----------------------------------------------
   _aEditables := Array( nCampos )
   IF ( !HB_IsArray( aEditables ) ) .or. ( Len( aEditables ) != nCampos )
      _aEditables := Array( nCampos )
      FOR nItem := 1 to nCampos
         _aEditables[nItem] := .t.
      NEXT
   ELSE
      FOR nItem := 1 to nCampos
         IF !HB_IsLogical( aEditables[nItem] )
            _aEditables[nItem] := .t.
         ELSE
            _aEditables[nItem] := aEditables[nItem]
         ENDIF
      NEXT
   ENDIF

   // Bloque de c�digo de la acci�n guardar.--------------------------------------
   IF !HB_IsBlock( bGuardar )
      _bGuardar := NIL
   ELSE
      _bGuardar := bGuardar
   ENDIF

   // Bloque de c�digo de la acci�n buscar.---------------------------------------
   IF !HB_IsBlock( bBuscar )
      _bBuscar := NIL
   ELSE
      _bBuscar := bBuscar
   ENDIF

   // Inicializaci�n de variables.------------------------------------------------
   aEtiquetas  := Array( nCampos, 3 )
   aBrwCampos  := Array( nCampos )
   aBrwAnchos  := Array( nCampos )
   _OOHG_aControles := Array( nCampos, 3)

   // Propiedades de las etiquetas.-----------------------------------------------
   nFila    := 20
   nColumna := 20
   FOR nItem := 1 to nCampos
      aEtiquetas[nItem,1] := "lbl" + "Etiqueta" + AllTrim( Str( nItem ,4,0 ) )
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
      nBrwAnchoCampo    := Len( _aCampos[nItem] ) * 10
      nBrwAnchoCampo    := iif( nBrwanchoCampo >= nBrwAnchoRegistro, nBrwanchoCampo, nBrwAnchoRegistro )
      aBrwAnchos[nItem] := nBrwAnchoCampo
   NEXT

   // Propiedades de los controles de edici�n.------------------------------------
   nFila    := 20
   nColumna := 20
   FOR nItem := 1 to nCampos
      DO CASE
      CASE _aEstructura[nItem,2] == "C"        // Campo tipo caracter.
         _OOHG_aControles[nItem,1] := "txt" + "Control" + AllTrim( Str( nItem ,4,0) )
         _OOHG_aControles[nItem,2] := nFila
         _OOHG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "N"        // Campo tipo numerico.
         _OOHG_aControles[nItem,1] := "txn" + "Control" + AllTrim( Str( nItem ,4,0) )
         _OOHG_aControles[nItem,2] := nFila
         _OOHG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "D"        // Campo tipo fecha.
         _OOHG_aControles[nItem,1] := "dat" + "Control" + AllTrim( Str( nItem ,4,0) )
         _OOHG_aControles[nItem,2] := nFila
         _OOHG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "L"        // Campo tipo l�gico.
         _OOHG_aControles[nItem,1] := "chk" + "Control" + AllTrim( Str( nItem ,4,0) )
         _OOHG_aControles[nItem,2] := nFila
         _OOHG_aControles[nItem,3] := nColumna + 80
      CASE _aEstructura[nItem,2] == "M"        // Campo tipo memo.
         _OOHG_aControles[nItem,1] := "edt" + "Control" + AllTrim( Str( nItem ,4,0) )
         _OOHG_aControles[nItem,2] := nFila
         _OOHG_aControles[nItem,3] := nColumna + 80
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
      "btnBorrar", "btnBuscar", "btnIr", ;
      "btnListado","btnPrimero", "btnAnterior", ;
      "btnSiguiente", "btnUltimo", "btnGuardar", ;
      "btnCancelar" }

   // Definici�n de la ventana de edici�n.---------------------------------------
   DEFINE WINDOW wndABM ;
         at     0, 0 ;
         WIDTH  640 ;
         HEIGHT 480 ;
         TITLE  _cTitulo ;
         modal ;
         NOSYSMENU ;
         FONT "Serif" ;
         size 8 ;
         ON INIT ABMRefresh( ABM_MODO_VER ) ;
         BACKCOLOR ( GetFormObjectByHandle( GetActiveWindow() ):BackColor )
   END WINDOW

   // Definici�n del frame.------------------------------------------------------
   @  10,  10 frame frmFrame1 of wndABM width 510 height 290

   // Definici�n de las etiquetas.-----------------------------------------------
   FOR nItem := 1 to nCampos

      @ aEtiquetas[nItem,2], aEtiquetas[nItem,3] label &( aEtiquetas[nItem,1] ) ;
         of     wndABM ;
         VALUE  _aCampos[nItem] ;
         WIDTH  70 ;
         HEIGHT 21 ;
         FONT   "ms sans serif" ;
         size   8
   NEXT

   @ 310, 535 label  lblLabel1 ;
      of     wndABM ;
      VALUE  _OOHG_Messages( 6, 1 ) ;
      WIDTH  85 ;
      HEIGHT 20 ;
      FONT   "ms sans serif" ;
      size   8
   @ 330, 535 label  lblRegistro ;
      of     wndABM ;
      VALUE  "9999" ;
      WIDTH  85 ;
      HEIGHT 20 ;
      FONT   "ms sans serif" ;
      size   8
   @ 350, 535 label  lblLabel2 ;
      of     wndABM ;
      VALUE  _OOHG_Messages( 6, 2 ) ;
      WIDTH  85 ;
      HEIGHT 20 ;
      FONT   "ms sans serif" ;
      size   8
   @ 370, 535 label  lblTotales ;
      of     wndABM ;
      VALUE  "9999" ;
      WIDTH  85 ;
      HEIGHT 20 ;
      FONT   "ms sans serif" ;
      size   8

   // Definici�n del browse.-----------------------------------------------------
   @ 310, 10 browse brwBrowse ;
      of       wndABM ;
      WIDTH    510 ;
      HEIGHT   125 ;
      HEADERS  _aCampos ;
      WIDTHS   aBrwAnchos ;
      WORKAREA &_cArea ;
      FIELDS   aBrwCampos ;
      VALUE    (_cArea)->( RecNo() ) ;
      ON DBLCLICK ABMEventos( ABM_EVENTO_EDITAR ) ;
      ON CHANGE {|| (_cArea)->( dbGoTo( wndABM.brwBrowse.Value ) ), ABMRefresh( ABM_MODO_VER ) }

   // Definici�n de los botones.--------------------------------------------------
   @ 400, 535 button btnCerrar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 1 ) ;
      ACTION  ABMEventos( ABM_EVENTO_SALIR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8
   @ 20, 535 button btnNuevo ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 2 ) ;
      ACTION  ABMEventos( ABM_EVENTO_NUEVO ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 65, 535 button btnEditar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 3 ) ;
      ACTION  ABMEventos( ABM_EVENTO_EDITAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 110, 535 button btnBorrar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 4 ) ;
      ACTION  ABMEventos( ABM_EVENTO_BORRAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 155, 535 button btnBuscar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 5 ) ;
      ACTION  ABMEventos( ABM_EVENTO_BUSCAR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 200, 535 button btnIr ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 6 ) ;
      ACTION  ABMEventos( ABM_EVENTO_IR ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 245, 535 button btnListado ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 7 ) ;
      ACTION  ABMEventos( ABM_EVENTO_LISTADO ) ;
      WIDTH   85 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 20 button btnPrimero ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 8 ) ;
      ACTION  ABMEventos( ABM_EVENTO_PRIMERO ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 100 button btnAnterior ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 9 ) ;
      ACTION  ABMEventos( ABM_EVENTO_ANTERIOR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 180 button btnSiguiente ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 10 ) ;
      ACTION  ABMEventos( ABM_EVENTO_SIGUIENTE ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 260 button btnUltimo ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 11 ) ;
      ACTION  ABMEventos( ABM_EVENTO_ULTIMO ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 260, 355 button btnGuardar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 12 ) ;
      ACTION  ABMEventos( ABM_EVENTO_GUARDAR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8
   @ 260, 435 button btnCancelar ;
      of      wndABM ;
      CAPTION _OOHG_Messages( 7, 13 ) ;
      ACTION  ABMEventos( ABM_EVENTO_CANCELAR ) ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8

   // Definici�n de los controles de edici�n.------------------------------------
   FOR nItem := 1 to nCampos
      DO CASE
      CASE _aEstructura[nItem,2] == "C"        // Campo tipo caracter.

         @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] textbox &( _OOHG_aControles[nItem,1] ) ;
            of      wndABM ;
            HEIGHT  21 ;
            VALUE   "" ;
            WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
            FONT    "Arial" ;
            size    9 ;
            MAXLENGTH _aEstructura[nItem,3]

      CASE _aEstructura[nItem,2] == "N"        // Campo tipo num�rico
         IF _aEstructura[nItem,4] == 0

            @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] textbox &( _OOHG_aControles[nItem,1] ) ;
               of      wndABM ;
               HEIGHT  21 ;
               VALUE   0 ;
               WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
               NUMERIC ;
               MAXLENGTH _aEstructura[nItem,3] ;
               FONT "Arial" ;
               size 9
         ELSE
            nMascaraTotal     := _aEstructura[nItem,3]
            nMascaraDecimales := _aEstructura[nItem,4]
            cMascara := Replicate( "9", nMascaraTotal - (nMascaraDecimales + 1) )
            cMascara += "."
            cMascara += Replicate( "9", nMascaraDecimales )

            @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] textbox &( _OOHG_aControles[nItem,1] ) ;
               of      wndABM ;
               HEIGHT  21 ;
               VALUE   0 ;
               WIDTH   iif( (_aEstructura[nItem,3] * 10)>160, 160, _aEstructura[nItem,3] * 10 ) ;
               NUMERIC ;
               INPUTMASK cMascara
         ENDIF
      CASE _aEstructura[nItem,2] == "D"        // Campo tipo fecha.

         @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] datepicker &( _OOHG_aControles[nItem,1] ) ;
            of      wndABM ;
            VALUE   Date() ;
            WIDTH   100 ;
            FONT    "Arial" ;
            size    9

         wndABM.&( _OOHG_aControles[nItem,1] ).Height := 21

      CASE _aEstructura[nItem,2] == "L"        // Campo tipo l�gico.

         @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] checkbox &( _OOHG_aControles[nItem,1] ) ;
            of      wndABM ;
            CAPTION "" ;
            WIDTH   21 ;
            HEIGHT  21 ;
            VALUE   .t. ;
            FONT    "Arial" ;
            size    9
      CASE _aEstructura[nItem,2] == "M"        // Campo tipo memo.

         @ _OOHG_aControles[nItem,2], _OOHG_aControles[nItem,3] editbox &( _OOHG_aControles[nItem,1] ) ;
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

   // Activaci�n de la ventana.---------------------------------------------------
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
   *     Funci�n: ABMRefresh( [nEstado] )
   *       Autor: Crist�bal Moll�
   * Descripci�n: Refresca la ventana segun el estado pasado.
   *  Par�metros: nEstado    Valor numerico que indica el tipo de estado.
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMRefresh( nEstado )

   // Declaraci�n de variables locales.-------------------------------------------

   LOCAL nItem    // := 1                                  // Indice de iteraci�n.

   // local cMensaje := ""                                 // Mensajes al usuario.

   // Refresco del cuadro de dialogo.
   DO CASE

      // Modo de visualizaci�n.----------------------------------------------
   CASE nEstado == ABM_MODO_VER

      // Estado de los controles.
      // Botones Cerrar y Nuevo.
      FOR nItem := 1 to 2
         wndABM.&( _aBotones[nItem] ).Enabled := .t.
      NEXT

      // Botones Guardar y Cancelar.
      FOR nItem := ( Len( _aBotones ) - 1 ) to Len( _aBotones )
         wndABM.&( _aBotones[nItem] ).Enabled := .f.
      NEXT

      // Resto de botones.
      IF (_cArea)->( RecCount() ) == 0
         wndABM.brwBrowse.Enabled := .f.
         FOR nItem := 3 to ( Len( _aBotones ) - 2 )
            wndABM.&( _aBotones[nItem] ).Enabled := .f.
         NEXT
      ELSE
         wndABM.brwBrowse.Enabled := .t.
         FOR nItem := 3 to ( Len( _aBotones ) - 2 )
            wndABM.&( _aBotones[nItem] ).Enabled := .t.
         NEXT
      ENDIF

      // Controles de edici�n.
      FOR nItem := 1 to Len( _OOHG_aControles )
         wndABM.&( _OOHG_aControles[nItem,1] ).Enabled := .f.
      NEXT

      // Contenido de los controles.
      // Controles de edici�n.
      FOR nItem := 1 to Len( _OOHG_aControles )
         wndABM.&( _OOHG_aControles[nItem,1] ).Value := (_cArea)->( FieldGet( nItem ) )
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Modo de edici�n.----------------------------------------------------
   CASE nEstado == ABM_MODO_EDITAR

      // Estado de los controles.
      // Botones Guardar y Cancelar.
      FOR nItem := ( Len( _aBotones ) - 1 ) to Len( _aBotones )
         wndABM.&( _aBotones[nItem] ).Enabled := .t.
      NEXT

      // Resto de los botones.
      FOR nItem := 1 to ( Len( _aBotones ) - 2 )
         wndABM.&( _aBotones[nItem] ).Enabled := .f.
      NEXT
      wndABM.brwBrowse.Enabled := .f.

      // Contenido de los controles.
      // Controles de edici�n.
      FOR nItem := 1 to Len( _OOHG_aControles )
         wndABM.&( _OOHG_aControles[nItem,1] ).Enabled := _aEditables[nItem]
      NEXT

      // Numero de registro y total.
      wndABM.lblRegistro.Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM.lblTotales.Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgOOHGError( _OOHG_Messages( 8, 3 ), "" )
   END CASE

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMEventos( nEvento )
   *       Autor: Crist�bal Moll�
   * Descripci�n: Gestiona los eventos que se producen en la ventana wndABM.
   *  Par�metros: nEvento    Valor num�rico que indica el evento a ejecutar.
   *    Devuelve: NIL
   ****************************************************************************************/

STATIC FUNCTION ABMEventos( nEvento )

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nItem      // := 1                                // Indice de iteraci�n.

   // local cMensaje   := ""                               // Mensaje al usuario.
   LOCAL aValores      := {}                               // Valores de los campos de edici�n.
   LOCAL nRegistro  // := 0                                // Numero de registro.
   LOCAL lGuardar   // := .t.                              // Salida del bloque _bGuardar.
   LOCAL cModo      // := ""                               // Texto del modo.
   LOCAL cRegistro  // := ""                               // Numero de registro.
   LOCAL wndABM        := GetFormObject( "wndABM" )

   // Gesti�n de eventos.
   DO CASE

      // Pulsaci�n del bot�n CERRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_SALIR
      wndABM:Release()

      // Pulsaci�n del bot�n NUEVO.------------------------------------------
   CASE nEvento == ABM_EVENTO_NUEVO
      _lEditar := .f.
      cModo := _OOHG_Messages( 6, 3 )
      wndABM:Title := wndABM:Title + cModo

      // Pasa a modo de edici�n.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edici�n.
      FOR nItem := 1 to Len( _OOHG_aControles )
         DO CASE
         CASE _aEstructura[nItem, 2] == "C"
            wndABM:Control( _OOHG_aControles[nItem,1] ):Value := ""
         CASE _aEstructura[nItem, 2] == "N"
            wndABM:Control( _OOHG_aControles[nItem,1] ):Value := 0
         CASE _aEstructura[nItem, 2] == "D"
            wndABM:Control( _OOHG_aControles[nItem,1] ):Value := Date()
         CASE _aEstructura[nItem, 2] == "L"
            wndABM:Control( _OOHG_aControles[nItem,1] ):Value := .f.
         CASE _aEstructura[nItem, 2] == "M"
            wndABM:Control( _OOHG_aControles[nItem,1] ):Value := ""
         ENDCASE
      NEXT

      // Esteblece el foco en el primer control.
      wndABM:Control( _OOHG_aControles[1,1] ):SetFocus()

      // Pulsaci�n del bot�n EDITAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_EDITAR
      _lEditar := .t.
      cModo := _OOHG_Messages( 6, 4 )
      wndABM:Title := wndABM:Title + cModo

      // Pasa a modo de edicion.
      ABMRefresh( ABM_MODO_EDITAR )

      // Actualiza los valores de los controles de edici�n.
      FOR nItem := 1 to Len( _OOHG_aControles )
         wndABM:Control( _OOHG_aControles[nItem,1] ):Value := (_cArea)->( FieldGet(nItem) )
      NEXT

      // Establece el foco en el primer coltrol.
      wndABM:Control( _OOHG_aControles[1,1] ):SetFocus()

      // Pulsaci�n del bot�n BORRAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BORRAR

      // Borra el registro si se acepta.
      IF MsgOKCancel( _OOHG_Messages( 5, 1 ), "" )
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
            Msgstop( _OOHG_Messages( 11, 41 ), '' )
         ENDIF
      ENDIF

      // Refresca.
      wndABM:brwBrowse:Refresh()
      wndABM:brwBrowse:Value := (_cArea)->( RecNo() )

      // Pulsaci�n del bot�n BUSCAR.-----------------------------------------
   CASE nEvento == ABM_EVENTO_BUSCAR
      IF !HB_IsBlock( _bBuscar )
         IF Empty( (_cArea)->( ordSetFocus() ) )
            msgExclamation( _OOHG_Messages( 5, 2 ), "" )
         ELSE
            ABMBuscar()
         ENDIF
      ELSE
         Eval( _bBuscar )
         wndABM:brwBrowse:Value := (_cArea)->( RecNo() )
      ENDIF

      // Pulsaci�n del bot�n IR AL REGISTRO.---------------------------------
   CASE nEvento == ABM_EVENTO_IR
      cRegistro := InputBox( _OOHG_Messages( 6, 5 ), "" )
      IF !Empty( cRegistro )
         nRegistro := Val( cRegistro )
         IF ( nRegistro != 0 ) .and. ( nRegistro <= (_cArea)->( RecCount() ) )
            (_cArea)->( dbGoTo( nRegistro ) )
            wndABM:brwBrowse:Value := nRegistro
         ENDIF
      ENDIF

      // Pulsaci�n del bot�n LISTADO.----------------------------------------
   CASE nEvento == ABM_EVENTO_LISTADO
      ABMListado()

      // Pulsaci�n del bot�n PRIMERO.----------------------------------------
   CASE nEvento == ABM_EVENTO_PRIMERO
      (_cArea)->( dbGoTop() )
      wndABM:brwBrowse:Value   := (_cArea)->( RecNo() )
      wndABM:lblRegistro:Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM:lblTotales:Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Pulsaci�n del bot�n ANTERIOR.---------------------------------------
   CASE nEvento == ABM_EVENTO_ANTERIOR
      (_cArea)->( dbSkip( -1 ) )
      wndABM:brwBrowse:Value   := (_cArea)->( RecNo() )
      wndABM:lblRegistro:Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM:lblTotales:Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Pulsaci�n del bot�n SIGUIENTE.--------------------------------------
   CASE nEvento == ABM_EVENTO_SIGUIENTE
      (_cArea)->( dbSkip( 1 ) )
      iif( (_cArea)->( EOF() ) , (_cArea)->( DbGoBottom() ), Nil )
      wndABM:brwBrowse:Value := (_cArea)->( RecNo() )
      wndABM:lblRegistro:Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM:lblTotales:Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Pulsaci�n del bot�n ULTIMO.-----------------------------------------
   CASE nEvento == ABM_EVENTO_ULTIMO
      (_cArea)->( dbGoBottom() )
      wndABM:brwBrowse:Value   := (_cArea)->( RecNo() )
      wndABM:lblRegistro:Value := AllTrim( Str( (_cArea)->(RecNo()) ) )
      wndABM:lblTotales:Value  := AllTrim( Str( (_cArea)->(RecCount()) ) )

      // Pulsaci�n del bot�n GUARDAR.----------------------------------------
   CASE nEvento == ABM_EVENTO_GUARDAR
      IF ( !HB_IsBlock( _bGuardar ) )

         // Guarda el registro.
         IF .not. _lEditar
            (_cArea)->( dbAppend() )
         ENDIF

         IF (_cArea)->(rlock())

            FOR nItem := 1 to Len( _OOHG_aControles )
               (_cArea)->( FieldPut( nItem, wndABM:Control( _OOHG_aControles[nItem,1] ):Value ) )
            NEXT

            (_cArea)->( dbCommit() )

            UNLOCK

            // Refresca el browse.

            wndABM:brwBrowse:Value := (_cArea)->( RecNo() )
            wndABM:brwBrowse:Refresh()
            wndABM:Title := SubStr( wndABM:Title, 1, Len(wndABM:Title) - 12 )

         ELSE

            MsgStop ('Record locked by another user')

         ENDIF

      ELSE

         // Eval�a el bloque de c�digo bGuardar.
         FOR nItem := 1 to Len( _OOHG_aControles )
            aAdd( aValores, wndABM:Control( _OOHG_aControles[nItem,1] ):Value )
         NEXT
         lGuardar := Eval( _bGuardar, aValores, _lEditar )
         lGuardar := iif( !HB_IsLogical( lGuardar ) , .t., lGuardar )
         IF lGuardar
            (_cArea)->( dbCommit() )

            // Refresca el browse.
            wndABM:brwBrowse:Value := (_cArea)->( RecNo() )
            wndABM:brwBrowse:Refresh()
            wndABM:Title := SubStr( wndABM:Title, 1, Len(wndABM:Title) - 12 )
         ENDIF
      ENDIF

      // Pulsaci�n del bot�n CANCELAR.---------------------------------------
   CASE nEvento == ABM_EVENTO_CANCELAR

      // Pasa a modo de visualizaci�n.
      ABMRefresh( ABM_MODO_VER )
      wndABM:Title := SubStr( wndABM:Title, 1, Len(wndABM:Title) - 12 )

      // Control de error.---------------------------------------------------
   OTHERWISE
      MsgOOHGError( _OOHG_Messages( 8, 4 ), "" )

   ENDCASE

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMBuscar()
   *       Autor: Crist�bal Moll�
   * Descripci�n: Definici�n de la busqueda
   *  Par�metros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMBuscar()

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nItem      // := 0                                // Indice de iteraci�n.
   LOCAL aCampo        := {}                               // Nombre de los campos.
   LOCAL aTipoCampo    := {}                               // Matriz con los tipos de campo.
   LOCAL cCampo     // := ""                               // Nombre del campo.

   // local cMensaje   := ""                               // Mensaje al usuario.
   LOCAL nTipoCampo // := 0                                // Indice el tipo de campo.
   LOCAL cTipoCampo // := ""                               // Tipo de campo.
   LOCAL cModo      // := ""                               // Texto del modo de busqueda.

   // Obtiene el nombre y el tipo de campo.---------------------------------------
   FOR nItem := 1 to Len( _aEstructura )
      aAdd( aCampo, _aEstructura[nItem,1] )
      aAdd( aTipoCampo, _aEstructura[nItem,2] )
   NEXT

   // Evalua si el campo indexado existe y obtiene su tipo.-----------------------
   cCampo := Upper( (_cArea)->( ordSetFocus() ) )
   nTipoCampo := aScan( aCampo, cCampo )
   IF nTipoCampo == 0
      msgExclamation( _OOHG_Messages( 5, 3 ), "" )
      RETURN ( nil )
   ENDIF
   cTipoCampo := aTipoCampo[nTipoCampo]

   // Comprueba si el tipo se puede buscar.---------------------------------------
   IF ( cTipoCampo == "N" ) .or. ( cTipoCampo == "L" ) .or. ( cTipoCampo == "M" )
      MsgExclamation( _OOHG_Messages( 5, 4 ), "" )
      RETURN ( nil )
   ENDIF

   // Define la ventana de busqueda.----------------------------------------------
   DEFINE WINDOW wndABMBuscar ;
         at 0, 0 ;
         WIDTH  200 ;
         HEIGHT 160 ;
         TITLE _OOHG_Messages( 6, 6 ) ;
         modal ;
         NOSYSMENU ;
         FONT "Serif" ;
         size 8 ;
         BACKCOLOR ( GetFormObjectByHandle( GetActiveWindow() ):BackColor )
   END WINDOW

   // Define los controles de la ventana de busqueda.-----------------------------
   // Etiquetas
   @ 20, 20 label lblEtiqueta1 ;
      of wndABMBuscar ;
      VALUE "" ;
      WIDTH 160 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      size 8

   // Botones.
   @ 80, 20 button btnGuardar ;
      of      wndABMBuscar ;
      CAPTION "&" + _OOHG_Messages( 7, 5 ) ;
      ACTION  {|| ABMBusqueda() } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8
   @ 80, 100 button btnCancelar ;
      of      wndABMBuscar ;
      CAPTION "&" + _OOHG_Messages( 7, 13 ) ;
      ACTION  {|| wndABMBuscar.Release } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8

   // Controles de edici�n.
   DO CASE
   CASE cTipoCampo == "C"
      cModo := _OOHG_Messages( 6, 7 )
      wndABMBuscar.lblEtiqueta1.Value := cModo
      @ 45, 20 textbox txtBuscar ;
         of wndABMBuscar ;
         HEIGHT 21 ;
         VALUE "" ;
         WIDTH 160 ;
         FONT "Arial" ;
         size 9 ;
         MAXLENGTH _aEstructura[nTipoCampo,3]
   CASE cTipoCampo == "D"
      cModo := _OOHG_Messages( 6, 8 )
      wndABMBuscar.lblEtiqueta1.Value := cModo
      @ 45, 20 datepicker txtBuscar ;
         of  wndABMBuscar ;
         VALUE   Date() ;
         WIDTH   100 ;
         FONT    "Arial" ;
         size    9
   ENDCASE

   // Activa la ventana.----------------------------------------------------------
   CENTER WINDOW   wndABMBuscar
   ACTIVATE WINDOW wndABMBuscar

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMBusqueda()
   *       Autor: Crist�bal Moll�
   * Descripci�n: Realiza la busqueda en la base de datos
   *  Par�metros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

STATIC FUNCTION ABMBusqueda()

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nRegistro := (_cArea)->( RecNo() )                // Registro anterior.

   // Busca el registro.----------------------------------------------------------
   IF (_cArea)->( dbSeek( wndABMBuscar.txtBuscar.Value ) )
      nRegistro := (_cArea)->( RecNo() )
   ELSE
      msgExclamation( _OOHG_Messages( 5, 5 ), "" )
      (_cArea)->(dbGoTo( nRegistro ) )
   ENDIF

   // Cierra y actualiza.---------------------------------------------------------
   wndABMBuscar.Release
   wndABM.brwBrowse.Value := nRegistro

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMListado()
   *       Autor: Crist�bal Moll�
   * Descripci�n: Definici�n del listado.
   *  Par�metros: Ninguno
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListado()

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nItem          // := 1                            // Indice de iteraci�n.
   LOCAL aCamposListado    := {}                           // Matriz con los campos del listado.
   LOCAL aCamposTotales    := {}                           // Matriz con los campos totales.
   LOCAL nPrimero       // := 0                            // Registro inicial.
   LOCAL nUltimo        // := 0                            // Registro final.
   LOCAL nRegistro         := (_cArea)->( RecNo() )        // Registro anterior.

   // Inicializaci�n de variables.------------------------------------------------
   // Campos imprimibles.
   FOR nItem := 1 to Len( _aEstructura )

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

   // Defincic�n de la ventana del proceso.---------------------------------------
   DEFINE WINDOW wndABMListado ;
         at 0, 0 ;
         WIDTH  420 ;
         HEIGHT 295 ;
         TITLE _OOHG_Messages( 6, 10 ) ;
         modal ;
         NOSYSMENU ;
         FONT "Serif" ;
         size 8 ;
         BACKCOLOR ( GetFormObjectByHandle( GetActiveWindow() ):BackColor )

   END WINDOW

   // Definici�n de los controles.------------------------------------------------
   // Frame.
   @ 10, 10 frame frmFrame1 of wndABMListado width 390 height 205

   // Label.
   @ 20, 20 label lblLabel1 ;
      of wndABMListado ;
      VALUE _OOHG_Messages( 6, 11 ) ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      size 8
   @ 20, 250 label lblLabel2 ;
      of     wndABMListado ;
      VALUE  _OOHG_Messages( 6, 12 ) ;
      WIDTH  140 ;
      HEIGHT 21 ;
      FONT   "ms sans serif" ;
      size   8
   @ 160, 20 label lblLabel3 ;
      of wndABMListado ;
      VALUE _OOHG_Messages( 6, 13 ) ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      size 8
   @ 160, 250 label lblLabel4 ;
      of wndABMListado ;
      VALUE _OOHG_Messages( 6, 14 ) ;
      WIDTH 140 ;
      HEIGHT 21 ;
      FONT "ms sans serif" ;
      size 8

   // ListBox.
   @ 45, 20 listbox lbxListado ;
      of wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCamposListado ;
      VALUE 1 ;
      FONT "Arial" ;
      size 9
   @ 45, 250 listbox lbxCampos ;
      of wndABMListado ;
      WIDTH 140 ;
      HEIGHT 100 ;
      ITEMS aCamposTotales ;
      VALUE 1 ;
      FONT "Arial" ;
      size 9 ;
      SORT

   // Spinner.
   @ 185, 20 spinner spnPrimero ;
      of wndABMListado ;
      range 1, (_cArea)->( RecCount() ) ;
      VALUE nPrimero ;
      WIDTH 70 ;
      HEIGHT 21 ;
      FONT "Arial" ;
      size 9
   @ 185, 250 spinner spnUltimo ;
      of wndABMListado ;
      range 1, (_cArea)->( RecCount() ) ;
      VALUE nUltimo ;
      WIDTH 70 ;
      HEIGHT 21 ;
      FONT "Arial" ;
      size 9

   // Botones.
   @ 45, 170 button btnMas ;
      of      wndABMListado ;
      CAPTION _OOHG_Messages( 7, 14 ) ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_MAS ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8
   @ 85, 170 button btnMenos ;
      of      wndABMListado ;
      CAPTION _OOHG_Messages( 7, 15 ) ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_MENOS ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8
   @ 225, 240 button btnImprimir ;
      of      wndABMListado ;
      CAPTION _OOHG_Messages( 7, 16 ) ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_IMPRIMIR ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP
   @ 225, 330 button btnCerrar ;
      of      wndABMListado ;
      CAPTION _OOHG_Messages( 7, 17 ) ;
      ACTION  {|| ABMListadoEvento( ABM_LISTADO_CERRAR ) } ;
      WIDTH   70 ;
      HEIGHT  30 ;
      FONT    "ms sans serif" ;
      size    8 ;
      NOTABSTOP

   // Activaci�n de la ventana----------------------------------------------------
   center   window wndABMListado
   ACTIVATE WINDOW wndABMListado

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMListadoEvento( nEvento )
   *       Autor: Crist�bal Moll�
   * Descripci�n: Ejecuta los eventos de la ventana de definici�n del listado.
   *  Par�metros: nEvento    Valor num�rico con el tipo de evento a ejecutar.
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListadoEvento( nEvento )

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL cItem        // := ""                             // Nombre del item.
   LOCAL nItem        // := 0                              // Numero del item.
   LOCAL aCampo          := {}                             // Nombres de los campos.
   LOCAL nIndice      // := 0                              // Numero del campo.
   LOCAL nAnchoCampo  // := 0                              // Ancho del campo.
   LOCAL nAnchoTitulo // := 0                              // Ancho del t�tulo.
   LOCAL nTotal          := 0                              // Ancho total.

   // local cMensaje     := ""                             // Mensaje al usuario.
   LOCAL nPrimero        := wndABMListado.spnPrimero.Value // Registro inicial.
   LOCAL nUltimo         := wndABMListado.spnUltimo.Value  // Registro final.

   // Control de eventos.
   DO CASE
      // Cerrar el cuadro de dialogo de definici�n de listado.---------------
   CASE nEvento == ABM_LISTADO_CERRAR
      wndABMListado.Release

      // A�adir columna.-----------------------------------------------------
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
      FOR nItem := 1 to Len( _aEstructura )
         aAdd( aCampo, _aEstructura[nItem,1] )
      NEXT
      FOR nItem := 1 to Len( _aCamposListado )
         aAdd( _aNumeroCampo, aScan( aCampo, _aCamposListado[nItem] ) )
      NEXT

      // Establece el ancho del campo a listar.
      _aAnchoCampo := {}
      FOR nItem := 1 to Len( _aCamposListado )
         nIndice      := _aNumeroCampo[nItem]
         nAnchoTitulo := Len( _aCampos[nIndice] )
         nAnchoCampo  := _aEstructura[nIndice,3]
         IF _aEstructura[nIndice,2] == "D"
            aAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo, ;
               nAnchoTitulo+4, ;
               nAnchoCampo+4 ) )
         ELSE
            aAdd( _aAnchoCampo, iif( nAnchoTitulo > nAnchoCampo, ;
               nAnchoTitulo+2, ;
               nAnchoCampo+2 ) )
         ENDIF
      NEXT

      // Comprueba el tama�o del listado y lanza la impresi�n.
      FOR nItem := 1 to Len( _aAnchoCampo )
         nTotal += _aAnchoCampo[nItem]
      NEXT
      IF nTotal > 164

         // No cabe en la hoja.
         MsgExclamation( _OOHG_Messages( 5, 6 ), "" )
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
      MsgOOHGError( _OOHG_Messages( 8, 5 ), "" )
   ENDCASE

   RETURN ( nil )

   /***************************************************************************************
   *     Funci�n: ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )
   *       Autor: Crist�bal Moll�
   * Descripci�n: Lanza el listado definido a la impresora.
   *  Par�metros: lOrientacion    L�gico que indica si el listado es horizontal (.t.)
   *                              o vertical (.f.)
   *              nPrimero        Valor numerico con el primer registro a imprimir.
   *              nUltimo         Valor num�rico con el �ltimo registro a imprimir.
   *    Devuelve: NIL
   ***************************************************************************************/

FUNCTION ABMListadoImprimir( lOrientacion, nPrimero, nUltimo )

   // Declaraci�n de variables locales.-------------------------------------------
   LOCAL nLineas      := 0                                 // Numero de linea.
   LOCAL nPaginas  // := 0                                 // Numero de p�ginas.
   LOCAL nFila        := 13                                // Numero de fila.
   LOCAL nColumna  // := 10                                // Numero de columna.
   LOCAL nItem     // := 1                                 // Indice de iteracion.
   LOCAL nIndice   // := 1                                 // Indice de campo.
   LOCAL lCabecera // := .t.                               // �Imprimir cabecera?.

   // local lPie      := .f.                               // �Imprimir pie?.
   LOCAL nPagina      := 1                                 // Numero de pagina.
   LOCAL lSalida   // := .t.                               // �Salir del listado?.
   LOCAL nRegistro    := (_cArea)->( RecNo() )             // Registro anterior.
   LOCAL cTexto    // := ""                                // Texto para l�gicos.
   LOCAL oprint

   // Definici�n del rango del listado.-------------------------------------------
   (_cArea)->( dbGoTo( nPrimero ) )
   DO WHILE .not. ( (_cArea)->( RecNo() ) ) == nUltimo .or. ( (_cArea)->( Eof() ) )
      nLineas++
      (_cArea)->( dbSkip( 1 ) )
   ENDDO
   (_cArea)->( dbGoTo( nPrimero ) )

   // Inicializaci�n de la impresora.---------------------------------------------

   oprint:=tprint()
   oprint:init()   ////// printlibrary
   oprint:selprinter(.T. , .T.  )  /// select,preview,landscape,papersize
   IF oprint:lprerror
      oprint:release()
      RETURN NIL
   ENDIF

   // Control de errores.---------------------------------------------------------

   // Definici�n de fuentes, rellenos y tipos de linea.---------------------------
   // Fuentes.

   // Inicio del listado.

   oprint:begindoc()

   lCabecera := .t.
   lSalida   := .t.
   DO WHILE lSalida

      // Cabecera.-----------------------------------------------------------
      IF lCabecera
         oprint:beginpage()
         oprint:printdata(5,1,_OOHG_Messages(6,15) + _cTitulo,"times new roman",14,.T.) ///
         oprint:printline(6,1,6,140)
         oprint:printdata(7,1,_OOHG_messages(6,16) ,"times new roman",10,.T.) ///
         oprint:printdata(7,30,date(),"times new roman",10,.F.) ///
         oprint:printdata(8,1, _OOHG_messages(6,17) ,"times new roman",10,.T.) ///
         oprint:printdata(8,30, alltrim(str(nprimero)),"times new roman",10,.F.) ///
         oprint:printdata(8,40,_OOHG_messages(6,18) ,"times new roman",10,.T.) ///
         oprint:printdata(8,60, alltrim(str(nultimo)),"times new roman",10,.F.) ///
         oprint:printdata(9,1,_OOHG_messages(6,19) ,"times new roman",10,.T.) ///
         oprint:printdata(9,30, ordname(),"times new roman",10,.F.) ///
         nColumna := 1
         FOR nItem := 1 to Len( _aNumeroCampo )
            nIndice := _aNumeroCampo[nItem]
            oprint:printdata(11,ncolumna,UPPER(_acampos[nindice]),,9,.T.) ///
            nColumna += _aAnchoCampo[nItem] +2
         NEXT
         lCabecera := .f.
      ENDIF

      // Registros.-----------------------------------------------------------
      nColumna := 1
      FOR nItem := 1 to Len( _aNumeroCampo )
         nIndice := _aNumeroCampo[nItem]
         DO CASE
         CASE _aEstructura[nIndice,2] == "L"

            cTexto := iif( (_cArea)->( FieldGet( nIndice ) ), _OOHG_Messages( 6, 20 ), _OOHG_Messages( 6, 21 ) )
            oprint:printdata(nfila,ncolumna,ctexto, ,,)
            nColumna += _aAnchoCampo[nItem] +2
         CASE _aEstructura[nIndice,2] == "N"
            oprint:printdata(nfila,ncolumna, (_cArea)->( FieldGet( nIndice ) ), ,,)
            nColumna += _aAnchoCampo[nItem] +2

         OTHERWISE
            oprint:printdata(nfila,ncolumna, (_cArea)->( FieldGet( nIndice ) ), ,,)
            nColumna += _aAnchoCampo[nItem] +2
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

            oprint:printline(45,10,45,140)
            oprint:printdata(46,1,_OOHG_messages(6,22) + AllTrim( Str( nPagina ) )  ,"times new roman",10,.F.) ///
            lCabecera := .t.
            nPagina++
            nFila := 13
            oprint:endpage()
         ENDIF
      ELSE
         // Vertical
         IF nFila > 53
            nPaginas := Int( nLineas / 42 )
            IF .not. Mod( nLineas, 42 ) == 0
               nPaginas++
            ENDIF

            oprint:printline(55,1,55,140)

            oprint:printdata(56,70,_OOHG_messages(6,22) + AllTrim( Str( nPagina ) )  ,"times new roman",10,.F.) ///
            lCabecera := .t.
            nPagina++
            nFila := 13

            oprint:endpage()
         ENDIF
      ENDIF
      Empty( nPaginas )

      // Comprobaci�n del rango de registro.---------------------------------
      IF ( (_cArea)->( RecNo() ) == nUltimo )
         nColumna := 1

         // Imprime el �ltimo registro.
         FOR nItem := 1 to Len( _aNumeroCampo )
            nIndice := _aNumeroCampo[nItem]
            DO CASE
            CASE _aEstructura[nIndice,2] == "L"
               cTexto := iif( (_cArea)->( FieldGet( nIndice ) ), _OOHG_Messages( 6, 20 ), _OOHG_Messages( 6, 21 ) )
               oprint:printdata(nfila,ncolumna, ctexto, ,,.F.)
               nColumna += _aAnchoCampo[nItem]  +2
            CASE _aEstructura[nIndice,2] == "N"
               oprint:printdata(nfila,ncolumna, (_cArea)->( FieldGet( nIndice ) )    , ,,.F.)
               nColumna += _aAnchoCampo[nItem] +2

            OTHERWISE
               oprint:printdata(nfila,ncolumna, (_cArea)->( FieldGet( nIndice ) )    , ,,.F.)
               nColumna += _aAnchoCampo[nItem] +2
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
         oprint:printline(45,1,45,140)
         oprint:printdata(46,70,_OOHG_messages(6,22) + AllTrim( Str( nPagina ) )   ,"times new roman" ,10,.F.)
      ENDIF
   ELSE
      // Vertical
      IF nFila <= 53
         nPaginas := Int( nLineas / 42 )
         IF .not. Mod( nLineas, 42 ) == 0
            nPaginas++
         ENDIF
         oprint:printline(55,1,55,140)
         oprint:printdata(56,70,_OOHG_messages(6,22) + AllTrim( Str( nPagina ) )   ,"times new roman" ,10,.F.)
      ENDIF
   ENDIF
   Empty( nPaginas )
   oprint:endpage()
   oprint:enddoc()
   oprint:release()
   RELEASE oprint
   // Restaura.-------------------------------------------------------------------
   (_cArea)->( dbGoTo( nRegistro ) )

   RETURN ( nil )
