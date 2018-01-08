#include "hmg.ch"

/***/

FUNCTION Main()

   LOAD WINDOW Mdi_5Main As frmMain
   CrearMenuPpal()
   frmMain.Center
   frmMain.Activate

   Return( Nil )

   /***/

FUNCTION CrearMenuPpal()

   DEFINE MAIN MENU Of frmMain
      DEFINE MENU PopUp "&Operaciones"
         MENUITEM "&Operación 1" ;
            ACTION CrearChild( 1 )
         SEPARATOR
         MENUITEM "&Operación 2"   ;
            ACTION CrearChild( 2 )
         SEPARATOR
         MENUITEM "&Operación 3"   ;
            ACTION CrearChild( 3 )
         SEPARATOR
         MENUITEM "&Salir" ;
            ACTION ThisWindow.Release()
      END POPUP
      DEFINE MENU PopUp "&Ventanas"
         POPUP '&Tiled'
            MENUITEM '&Horizontal' ;
               ACTION WinChildTile( .F. )
            MENUITEM '&Vertical' ;
               ACTION WinChildTile( .T. )
         END POPUP
         MENUITEM '&Cascade' ;
            ACTION WinChildCascade()
         MENUITEM '&Maximize' ;
            ACTION WinChildMaximize()
         SEPARATOR
         MENUITEM "&Listar" ;
            ACTION MostrarVentanasCargadas()
      END POPUP
      DEFINE MENU PopUp "&Ayuda"
         MENUITEM 'HMG Version' ;
            ACTION MsgInfo( MiniGuiVersion() )
         MENUITEM "&Ayuda" ;
            ACTION MsgInfo( "MiniGUI MDI Childs Load Demo" )
      END POPUP

   END MENU

   Return( Nil )

   /***/

FUNCTION CrearChild( nChild )

   LOCAL cChild:="Child_"+hb_ntos( nChild )
   LOCAL row,col,ntitle:=GetTitleHeight()+GetBorderHeight()
   LOCAL width:=.77*frmMain.Width,height:=.618*(frmMain.Height-ntitle)

   IF !_IsWindowDefined( cChild )
      DECLARE Window &cChild
      _HMG_ActiveMDIChildIndex := --nChild
      LOAD WINDOW Mdi_5Child As Child
      SetProperty( cChild, 'Title', cChild )
      On Key Control+F4 Action _CloseActiveMdi()
      On Key Control+F6 Action SwitchToNextWin()
      SWITCH Val( Right( cChild, 1 ) )
      CASE 1
         ROW := 0
         COL := 0
         EXIT
      CASE 2
         ROW := ntitle - 1
         COL := 22
         EXIT
      CASE 3
         ROW := 2*(ntitle - 1)
         COL := 44
      END SWITCH
      MoveWindow ( GetFormHandle(cChild), col, row, width, height, .T. )
   ELSE
      DoMethod( cChild, 'Center' )
   END IF

   Return( Nil )

   /***/

FUNCTION MostrarVentanasCargadas()

   LOCAL I,cNombres

   cNombres := ""
   FOR I := 1 To Len( _HMG_aFormNames )
      cNombres += ( _HMG_aFormNames[ I ] + Chr( 13 ))
   NEXT I
   MsgInfo( cNombres )

   Return( Nil )

   /***/

FUNCTION WinChildMaximize()

   LOCAL ChildHandle

   ChildHandle := GetActiveMdiHandle()
   IF aScan ( _HMG_aFormHandles, ChildHandle ) > 0
#define WM_MDIMAXIMIZE 0x0225
      SendMessage( _HMG_MainClientMDIHandle, WM_MDIMAXIMIZE, ChildHandle, 0 )
   END IF

   Return( Nil )

   /***/

FUNCTION WinChildTile(lVert)

   IF lVert
      TILE MDICHILDS VERTICAL
   ELSE
      TILE MDICHILDS HORIZONTAL
   END IF

   Return( Nil )

   /***/

FUNCTION WinChildCascade()

   CASCADE MDICHILDS

   Return( Nil )

   /***/

FUNCTION SwitchToNextWin()

   LOCAL ChildName, nForm

   GET WINDOWPROPERTY "PROP_FORMNAME" VALUE ChildName
   nForm := Val( Right( ChildName, 1 ) )
   IF ++nForm > 3
      nForm := 1
   ENDIF
   IF !_IsWindowDefined( "Child_" + hb_ntos(nForm) )
      nForm++
   END IF
   IF _IsWindowDefined( "Child_" + hb_ntos(nForm) )
      DoMethod( "Child_" + hb_ntos(nForm), "SetFocus" )
   END IF

   Return( Nil )
