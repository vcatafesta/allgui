/*
* $Id: menu.prg 2047 2013-05-24 10:44:30Z alkresin $
* HWGUI - Harbour Linux (GTK) GUI library source code:
* Prg level menu functions
* Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "hbclass.ch"
#include "guilib.ch"

#define  MENU_FIRST_ID   32000
#define  CONTEXTMENU_FIRST_ID   32900
#define  FLAG_DISABLED   1
#define  FLAG_CHECK      2

#define GDK_F1 0xffbe
#define GDK_F2 0xffbf
#define GDK_F3 0xffc0
#define GDK_F4 0xffc1
#define GDK_F5 0xffc2
#define GDK_F6 0xffc3
#define GDK_F7 0xffc4
#define GDK_F8 0xffc5
#define GDK_F9 0xffc6
#define GDK_F10 0xffc7
#define GDK_F11 0xffc8
#define GDK_F12 0xffc9

#define GDK_Home 0xff50
#define GDK_Left 0xff51
#define GDK_Up 0xff52
#define GDK_Right 0xff53
#define GDK_Down 0xff54
#define GDK_Page_Up 0xff55
#define GDK_Page_Down 0xff56
#define GDK_End 0xff57

STATIC _aMenuDef, _oWnd, _aAccel, _nLevel, _Id, _oMenu, _oBitmap
STATIC aKeysTable := { { VK_F1,GDK_F1 }, { VK_F2,GDK_F2 }, { VK_F3,GDK_F3 }, ;
   { VK_F4,GDK_F4 }, { VK_F5,GDK_F5 }, { VK_F6,GDK_F6 }, { VK_F7,GDK_F7 }, ;
   { VK_F8,GDK_F8 }, { VK_F9,GDK_F9 }, { VK_F10,GDK_F10 }, { VK_F11,GDK_F11 }, ;
   { VK_F12,GDK_F12 }, { VK_HOME,GDK_Home }, { VK_LEFT,GDK_Left }, { VK_END,GDK_End }, ;
   { VK_RIGHT,GDK_Right }, { VK_DOWN,GDK_Down }, { VK_UP,GDK_Up } }

CLASS HMenu INHERIT HObject

   DATA handle
   DATA aMenu

   METHOD New()  INLINE Self

   METHOD End()  INLINE Hwg_DestroyMenu(::handle)

   METHOD Show( oWnd,xPos,yPos,lWnd )

   ENDCLASS

METHOD Show( oWnd,xPos,yPos,lWnd ) CLASS HMenu

   LOCAL aCoor

   /*
   oWnd:oPopup := Self
   IF Pcount() == 1 .OR. lWnd == Nil .OR. !lWnd
   IF Pcount() == 1
   aCoor := hwg_GetCursorPos()
   xPos  := aCoor[1]
   yPos  := aCoor[2]
   ENDIF
   Hwg_trackmenu( ::handle,xPos,yPos,oWnd:handle )
   ELSE
   aCoor := ClientToScreen( oWnd:handle,xPos,yPos )
   Hwg_trackmenu( ::handle,aCoor[1],aCoor[2],oWnd:handle )
   ENDIF
   */

   RETURN NIL

FUNCTION Hwg_CreateMenu

   LOCAL hMenu

   IF ( EMPTY( hMenu := hwg__CreateMenu() ) )

      RETURN NIL
   ENDIF

   RETURN { {},,, hMenu }

FUNCTION Hwg_SetMenu( oWnd, aMenu )

   IF !Empty( oWnd:handle )
      IF hwg__SetMenu( oWnd:handle, aMenu[5] )
         oWnd:menu := aMenu
      ELSE

         RETURN .F.
      ENDIF
   ELSE
      oWnd:menu := aMenu
   ENDIF

   RETURN .T.

   /*
   *  AddMenuItem( aMenu,cItem,nMenuId,lSubMenu,[bItem] [,nPos] ) --> aMenuItem
   *  If nPos is omitted, the function adds menu item to the end of menu,
   *  else it inserts menu item in nPos position.
   */

FUNCTION Hwg_AddMenuItem( aMenu,cItem,nMenuId,lSubMenu,bItem,nPos )

   LOCAL hSubMenu

   IF nPos == Nil
      nPos := Len( aMenu[1] ) + 1
   ENDIF

   hSubMenu := aMenu[5]
   hSubMenu := hwg__AddMenuItem( hSubMenu, cItem, nPos-1, hwg_Getactivewindow(), nMenuId,,lSubMenu )

   IF nPos > Len( aMenu[1] )
      IF lSubmenu
         Aadd( aMenu[1],{ {},cItem,nMenuId,0,hSubMenu } )
      ELSE
         Aadd( aMenu[1],{ bItem,cItem,nMenuId,0,hSubMenu } )
      ENDIF

      RETURN ATail( aMenu[1] )
   ELSE
      Aadd( aMenu[1],Nil )
      Ains( aMenu[1],nPos )
      IF lSubmenu
         aMenu[ 1,nPos ] := { {},cItem,nMenuId,0,hSubMenu }
      ELSE
         aMenu[ 1,nPos ] := { bItem,cItem,nMenuId,0,hSubMenu }
      ENDIF

      RETURN aMenu[ 1,nPos ]
   ENDIF

   RETURN NIL

FUNCTION Hwg_FindMenuItem( aMenu, nId, nPos )

   LOCAL nPos1, aSubMenu

   nPos := 1
   DO WHILE nPos <= Len( aMenu[1] )
      IF aMenu[ 1,npos,3 ] == nId

         RETURN aMenu
      ELSEIF Valtype( aMenu[ 1,npos,1 ] ) == "A"
         IF ( aSubMenu := Hwg_FindMenuItem( aMenu[ 1,nPos ] , nId, @nPos1 ) ) != Nil
            nPos := nPos1

            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos ++
   ENDDO

   RETURN NIL

FUNCTION Hwg_GetSubMenuHandle( aMenu,nId )

   LOCAL aSubMenu := Hwg_FindMenuItem( aMenu, nId )

   RETURN Iif( aSubMenu == Nil, 0, aSubMenu[5] )

FUNCTION hwg_BuildMenu( aMenuInit, hWnd, oWnd, nPosParent,lPopup )

   LOCAL hMenu, nPos, aMenu, i, oBmp

   IF nPosParent == Nil
      IF lPopup == Nil .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := { aMenuInit,,,,hMenu }
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len( aMenuInit[1] )
      aMenu := aMenuInit[ 1,nPosParent ]
      hMenu := hwg__AddMenuItem( hMenu, aMenu[2], nPos+1, hWnd, aMenu[3],aMenu[4],.T. )
      IF Len( aMenu ) < 5
         Aadd( aMenu,hMenu )
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len( aMenu[1] )
      IF Valtype( aMenu[ 1,nPos,1 ] ) == "A"
         hwg_BuildMenu( aMenu,hWnd,,nPos )
      ELSE
         IF aMenu[ 1,nPos,1 ] == Nil .OR. aMenu[ 1,nPos,2 ] != Nil
            IF Len(aMenu[1,npos]) == 4
               Aadd(aMenu[1,npos],Nil)
            ENDIF
            aMenu[1,npos,5] := hwg__AddMenuItem( hMenu, aMenu[1,npos,2], ;
               nPos, hWnd, aMenu[1,nPos,3], aMenu[1,npos,4],.F. )
         ENDIF
      ENDIF
      nPos ++
   ENDDO
   IF hWnd != Nil .AND. oWnd != Nil
      Hwg_SetMenu( oWnd, aMenu )
   ELSEIF _oMenu != Nil
      _oMenu:handle := aMenu[5]
      _oMenu:aMenu := aMenu
   ENDIF

   RETURN NIL

FUNCTION Hwg_BeginMenu( oWnd,nId,cTitle )

   LOCAL aMenu, i

   IF oWnd != Nil
      _aMenuDef := {}
      _aAccel   := {}
      _oBitmap  := {}
      _oWnd     := oWnd
      _oMenu    := Nil
      _nLevel   := 0
      _Id       := Iif( nId == Nil, MENU_FIRST_ID, nId )
   ELSE
      nId   := Iif( nId == Nil, ++ _Id, nId )
      aMenu := _aMenuDef
      FOR i := 1 TO _nLevel
         aMenu := Atail(aMenu)[1]
      NEXT
      _nLevel++
      IF !empty( cTitle )
         cTitle := strtran( cTitle, "\t", "" )
         cTitle := strtran( cTitle, "&", "_" )
      ENDIF
      Aadd( aMenu, { {},cTitle,nId,0 } )
   ENDIF

   RETURN .T.

FUNCTION Hwg_ContextMenu()

   _aMenuDef := {}
   _oBitmap  := {}
   _oWnd := Nil
   _nLevel := 0
   _Id := CONTEXTMENU_FIRST_ID
   _oMenu := HMenu():New()

   RETURN _oMenu

FUNCTION Hwg_EndMenu()

   IF _nLevel > 0
      _nLevel --
   ELSE
      hwg_BuildMenu( Aclone(_aMenuDef), Iif( _oWnd!=Nil,_oWnd:handle,Nil ), ;
         _oWnd,,Iif( _oWnd!=Nil,.F.,.T. ) )
      IF _oWnd != Nil .AND. !Empty( _aAccel )
         _oWnd:hAccel := hwg_Createacceleratortable( _oWnd )
      ENDIF
      _aMenuDef := Nil
      _oBitmap  := Nil
      _aAccel   := Nil
      _oWnd     := Nil
      _oMenu    := Nil
   ENDIF

   RETURN .T.

FUNCTION Hwg_DefineMenuItem( cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck )

   LOCAL aMenu, i, oBmp, nFlag

   lCheck := Iif( lCheck==Nil, .F., lCheck )
   lDisabled := Iif( lDisabled==Nil,.T.,!lDisabled )
   nFlag := Hwg_BitOr( Iif( lCheck,FLAG_CHECK,0 ), Iif( lDisabled,0,FLAG_DISABLED ) )

   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := Iif( nId == Nil .AND. cItem != Nil, ++ _Id, nId )
   IF !empty( cItem )
      cItem := strtran( cItem, "\t", "" )
      cItem := strtran( cItem, "&", "_" )
   ENDIF
   Aadd( aMenu, { bItem,cItem,nId,nFlag,0 } )

   IF accFlag != Nil .AND. accKey != Nil
      Aadd( _aAccel, { accFlag,accKey,nId } )
   ENDIF

   /*
   IF lBitmap!=Nil .or. !Empty(lBitmap)
   if lResource==Nil ;lResource:=.F.; Endif
   if !lResource
   oBmp:=HBitmap():AddFile(lBitmap)
   else
   oBmp:=HBitmap():AddResource(lBitmap)
   endif
   Aadd( _oBitmap, {.t., oBmp:Handle,cItem,nId} )
   Else
   Aadd( _oBitmap, {.F., "",cItem, nID})
   Endif
   */

   RETURN .T.

FUNCTION Hwg_DefineAccelItem( nId, bItem, accFlag, accKey )

   LOCAL aMenu, i

   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := Iif( nId == Nil, ++ _Id, nId )
   Aadd( aMenu, { bItem,Nil,nId,.T. } )
   Aadd( _aAccel, { accFlag,accKey,nId } )

   RETURN .T.

STATIC FUNCTION hwg_Createacceleratortable( oWnd )

   LOCAL hTable := hwg__Createacceleratortable( oWnd:handle )
   LOCAL i, nPos, aSubMenu, nKey, n

   FOR i := 1 TO Len( _aAccel )
      IF ( aSubMenu := Hwg_FindMenuItem( oWnd:menu, _aAccel[i,3], @nPos ) ) != Nil
         IF ( nKey := _aAccel[i,2] ) >= 65 .AND. nKey <= 90
            nKey += 32
         ELSE
            nKey := hwg_gtk_convertkey( nKey )
         ENDIF
         hwg__AddAccelerator( hTable, aSubmenu[1,nPos,5], _aAccel[i,1], nKey )
      ENDIF
   NEXT

   RETURN hTable

   /*

   Function Hwg_SetMenuItemBitmaps( aMenu, nId, abmp1, abmp2 )

   Local aSubMenu := Hwg_FindMenuItem( aMenu, nId )
   Local oMenu:=aSubMenu

   Iif( aSubMenu == Nil,oMenu:=0, oMenu:=aSubMenu[5] )
   SetMenuItemBitmaps( oMenu, nId, abmp1, abmp2 )

   Return Nil

   Function Hwg_InsertBitmapMenu( aMenu, nId, lBitmap, oResource )

   Local aSubMenu := Hwg_FindMenuItem( aMenu, nId )
   Local oMenu:=aSubMenu, oBmp

   If !oResource .or. oResource==Nil
   oBmp:=HBitmap():AddFile(lBitmap)
   else
   oBmp:=HBitmap():AddResource(lBitmap)
   endif
   Iif( aSubMenu == Nil,oMenu:=0, oMenu:=aSubMenu[5] )
   HWG__InsertBitmapMenu( oMenu, nId, obmp:handle )

   Return Nil

   Function Hwg_SearchPosBitmap( nPos_Id )

   Local nPos := 1, lBmp:={.F.,""}

   IF _oBitmap != Nil
   DO WHILE nPos<=Len(_oBitmap )

   if _oBitmap[nPos][4] == nPos_Id
   lBmp:={_oBitmap[nPos][1], _oBitmap[nPos][2],_oBitmap[nPos][3]}
   Endif

   nPos ++

   ENDDO
   ENDIF

   Return lBmp
   */

STATIC FUNCTION GetMenuByHandle( hWnd )

   LOCAL i, aMenu, oDlg

   IF hWnd == Nil
      aMenu := HWindow():GetMain():menu
   ELSE
      IF ( oDlg := HDialog():FindDialog(hWnd) ) != Nil
         aMenu := oDlg:menu
      ELSEIF ( i := Ascan( HDialog():aModalDialogs,{|o|o:handle==hWnd} ) ) != Nil
         aMenu := HDialog():aModalDialogs[i]:menu
      ELSEIF ( i := Ascan( HWindow():aWindows,{|o|o:handle==hWnd} ) ) != Nil
         aMenu := HWindow():aWindows[i]:menu
      ENDIF
   ENDIF

   RETURN aMenu

FUNCTION hwg_CheckMenuItem( hWnd, nId, lValue )

   LOCAL aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != Nil
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != Nil
         hwg__CheckMenuItem( aSubmenu[1,nPos,5], lValue )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_IsCheckedMenuItem( hWnd, nId )

   LOCAL aMenu, aSubMenu, nPos, lRes := .F.

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != Nil
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != Nil
         lRes := hwg__IsCheckedMenuItem( aSubmenu[1,nPos,5] )
      ENDIF
   ENDIF

   RETURN lRes

FUNCTION hwg_EnableMenuItem( hWnd, nId, lValue )

   LOCAL aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle( Iif( hWnd==Nil,HWindow():GetMain():handle,hWnd ) )
   IF aMenu != Nil
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != Nil
         hwg__EnableMenuItem( aSubmenu[1,nPos,5], lValue )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_IsEnabledMenuItem( hWnd, nId )

   LOCAL aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle( Iif( hWnd==Nil,HWindow():GetMain():handle,hWnd ) )
   IF aMenu != Nil
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != Nil
         hwg__IsEnabledMenuItem( aSubmenu[1,nPos,5] )
      ENDIF
   ENDIF

   RETURN NIL

   /*
   *  hwg_SetMenuCaption( hMenu, nMenuId, cCaption )
   */

FUNCTION hwg_SetMenuCaption( hWnd, nId, cText )

   LOCAL aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle( hWnd )
   IF aMenu != Nil
      IF ( aSubMenu := Hwg_FindMenuItem( aMenu, nId, @nPos ) ) != Nil
         hwg__SetMenuCaption( aSubmenu[1,nPos,5], cText )
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION hwg_DeleteMenuItem( oWnd, nId )

   LOCAL aSubMenu, nPos

   IF ( aSubMenu := Hwg_FindMenuItem( oWnd:menu, nId, @nPos ) ) != Nil
      hwg__DeleteMenu( aSubmenu[1,nPos,5], nId )
      ADel( aSubMenu[ 1 ], nPos )
      ASize( aSubMenu[ 1 ], Len( aSubMenu[ 1 ] ) - 1 )
   ENDIF

   RETURN NIL

FUNCTION hwg_gtk_convertkey( nKey )

   LOCAL n

   IF nKey >= 65 .AND. nKey <= 90
      nKey += 32
   ELSEIF ( n := Ascan( aKeysTable, {|a|a[1]==nKey} ) ) > 0
      nKey := aKeysTable[n,2]
   ELSE
      nKey += 0xFF00
   ENDIF

   RETURN nKey
