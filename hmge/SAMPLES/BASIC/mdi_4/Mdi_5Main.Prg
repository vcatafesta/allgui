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
         MenuItem "&Operación 1" ;
            Action CrearChild( 1 )
         Separator
         MenuItem "&Operación 2"   ;
            Action CrearChild( 2 )
         Separator
         MenuItem "&Operación 3"   ;
            Action CrearChild( 3 )
         Separator
         MenuItem "&Salir" ;
            Action ThisWindow.Release()
      End PopUp
      DEFINE MENU PopUp "&Ventanas"
         POPUP '&Tiled'
            MenuItem '&Horizontal' ;
               Action WinChildTile( .F. )
            MenuItem '&Vertical' ;
               Action WinChildTile( .T. )
         End PopUp
         MenuItem '&Cascade' ;
            Action WinChildCascade()
         MenuItem '&Maximize' ;
            Action WinChildMaximize()
         Separator
         MenuItem "&Listar" ;
            Action MostrarVentanasCargadas()
      End PopUp
      DEFINE MENU PopUp "&Ayuda"
         MenuItem 'HMG Version' ;
            Action MsgInfo( MiniGuiVersion() )
         MenuItem "&Ayuda" ;
            Action MsgInfo( "MiniGUI MDI Childs Load Demo" )
      End PopUp

   End Menu

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
         row := 0
         col := 0
         EXIT
      CASE 2
         row := ntitle - 1
         col := 22
         EXIT
      CASE 3
         row := 2*(ntitle - 1)
         col := 44
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
