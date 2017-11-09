/*----------------------------------------------------------------------------
HMG - Harbour Windows GUI library source code

Copyright 2002-2016 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

Head of HMG project:

2002-2012 Roberto Lopez <mail.box.hmg@gmail.com>
http://sites.google.com/site/hmgweb/

2012-2016 Dr. Claudio Soto <srvet@adinet.com.uy>
http://srvet.blogspot.com

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
contained in this release of HMG.

The exception is that, if you link the HMG library with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking the
HMG library code into it.

Parts of this project are based upon:

"Harbour GUI framework for Win32"
Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
Copyright 2001 Antonio Linares <alinares@fivetech.com>
www - http://www.harbour-project.org

"Harbour Project"
Copyright 1999-2008, http://www.harbour-project.org/

"WHAT32"
Copyright 2002 AJ Wos <andrwos@aust1.net>

"HWGUI"
Copyright 2001-2008 Alexander S.Kresin <alex@belacy.belgorod.su>

---------------------------------------------------------------------------*/
MEMVAR _HMG_SYSDATA
MEMVAR _HMG_SYSDATA_cButtonName
MEMVAR _HMG_SYSDATA_nControlHandle

#include "hmg.ch"

FUNCTION _DefineMainMenu ( Parent )

   IF valtype(Parent) == 'U'
      Parent := _HMG_SYSDATA [ 223 ]
   ENDIF

   IF IsMainMenuDefined (Parent) == .T.     // ADD
      MsgHMGError("Main Menu already defined in Window: "+ Parent + ". Program Terminated" )
   ENDIF

   _HMG_SYSDATA [ 218 ] := 'MAIN'
   _HMG_SYSDATA [ 172 ] := 0
   _HMG_SYSDATA [ 173 ] := 0
   _HMG_SYSDATA [ 174 ] := 0
   _HMG_SYSDATA [ 220 ] := ""

   _HMG_SYSDATA [ 173 ] := GetFormHandle ( Parent )
   _HMG_SYSDATA [ 220 ] := Parent
   _HMG_SYSDATA [ 172 ] := CreateMenu()

   RETURN NIL

FUNCTION _DefineMenuPopup ( Caption , Name )

   LOCAL mVar , k := 0

   IF _HMG_SYSDATA [ 218 ] == 'MAIN'

      _HMG_SYSDATA [ 174 ]++

      _HMG_SYSDATA [ 335 ] [ _HMG_SYSDATA [ 174 ] ] := CreatePopupMenu()

      _HMG_SYSDATA [ 336 ] [ _HMG_SYSDATA [ 174 ] ] := Caption

      IF _HMG_SYSDATA [ 174 ] > 1
         APPENDMenuPopup ( _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ] - 1 ] , _HMG_SYSDATA [ 335 ] [ _HMG_SYSDATA [ 174 ] ] , _HMG_SYSDATA [ 336 ] [ _HMG_SYSDATA [ 174 ] ] )
      ENDIF

      IF valtype (name) != 'U'

         mVar := '_' + _HMG_SYSDATA [ 220 ] + '_' + Name

         k := _GetControlFree()

         PUBLIC &mVar. := k

         _HMG_SYSDATA [1] [k] :=  "POPUP"
         _HMG_SYSDATA [2]  [k] :=  Name
         _HMG_SYSDATA [3]  [k] :=  _HMG_SYSDATA [ 172 ]   // Main Menu Handle  // Claudio Soto (July 2013)  // 0
         _HMG_SYSDATA [4]  [k] :=  _HMG_SYSDATA [ 173 ]   // Form Parent Handle
         _HMG_SYSDATA [  5 ]  [k] :=  0
         _HMG_SYSDATA [  6 ] [k] :=   Nil
         _HMG_SYSDATA [  7 ]  [k] :=   _HMG_SYSDATA [ 172 ]   // Main Menu Handle
         _HMG_SYSDATA [  8 ]  [k] :=  Nil
         _HMG_SYSDATA [  9 ]   [k] := ""
         _HMG_SYSDATA [ 10 ]  [k] :=  ""
         _HMG_SYSDATA [ 11 ]  [k] :=  ""
         _HMG_SYSDATA [ 12 ]  [k] :=  "MAIN_MENU_POPUP"   // ADD
         _HMG_SYSDATA [ 13 ]  [k] :=  .F.
         _HMG_SYSDATA [ 14 ]  [k] :=  Nil
         _HMG_SYSDATA [ 15 ]  [k] :=  Nil
         _HMG_SYSDATA [ 16 ]   [k] := ""
         _HMG_SYSDATA [ 17 ]  [k] :=  {}
         _HMG_SYSDATA [ 18 ]  [k] :=  0
         _HMG_SYSDATA [ 19 ]  [k] :=  0
         _HMG_SYSDATA [ 20 ]  [k] :=  0
         _HMG_SYSDATA [ 21 ]  [k] :=  0
         _HMG_SYSDATA [ 22 ]  [k] :=  _HMG_SYSDATA [ 335 ] [ _HMG_SYSDATA [ 174 ] ]   // Popup Menu Handle
         _HMG_SYSDATA [ 23 ]  [k] :=  -1
         _HMG_SYSDATA [ 24 ]  [k] :=  -1
         _HMG_SYSDATA [ 25 ]  [k] :=  ""
         _HMG_SYSDATA [ 26 ]  [k] :=  0
         _HMG_SYSDATA [ 27 ]  [k] :=  ''
         _HMG_SYSDATA [ 28 ]  [k] :=  0
         _HMG_SYSDATA [ 29 ]  [k] :=  {.f.,.f.,.f.,.f.}
         _HMG_SYSDATA [ 30 ]   [k] :=  ''
         _HMG_SYSDATA [ 31 ]   [k] :=  0
         _HMG_SYSDATA [ 32 ]  [k] :=   0
         _HMG_SYSDATA [ 33 ]  [k] :=   Caption
         _HMG_SYSDATA [ 34 ]  [k] :=   .t.
         _HMG_SYSDATA [ 35 ]  [k] :=   0
         _HMG_SYSDATA [ 36 ]   [k] :=  0
         _HMG_SYSDATA [ 37 ]  [k] :=   0
         _HMG_SYSDATA [ 38 ]  [k] :=   .T.
         _HMG_SYSDATA [ 39 ] [k] := 0
         _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

      ENDIF

   ELSE

      MsgHMGError("Context/DropDown/Notify Menus Does Not Support SubMenus. Program Terminated")

   ENDIF

   RETURN NIL

FUNCTION _EndMenuPopup()

   IF _HMG_SYSDATA [ 218 ] == 'MAIN'

      _HMG_SYSDATA [ 174 ]--

      IF _HMG_SYSDATA [ 174 ] == 0
         APPENDMenuPopup ( _HMG_SYSDATA [ 172 ] , _HMG_SYSDATA [ 335 ] [ 1 ] , _HMG_SYSDATA [ 336 ] [ 1 ] )
      ENDIF

   ELSE

      MsgHMGError("Context/DropDown/Notify Menus Does Not Support SubMenus. Program Terminated")

   ENDIF

   RETURN NIL

FUNCTION _DefineMenuItem ( caption , action , name , Image , checked , NoTrans, ToolTip )

   LOCAL Controlhandle , mVar := '' , k := 0, cTypeMenu :=""
   LOCAL id
   LOCAL cParentName := "", MenuItemID := 0

   IF _HMG_SYSDATA [ 218 ] == 'MAIN'

      Id := _GetId()

      Controlhandle := AppendMenuString ( _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ] ] , id ,  caption )   // This Not return a Handle, return lBoolean value

      IF Valtype ( image ) != 'U'
         MenuItem_SetBitMaps ( _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ]] , Id , image , "" , NoTrans )
      ENDIF

      k := _GetControlFree()

      IF valtype (name) != 'U'
         mVar := '_' + _HMG_SYSDATA [ 220 ] + '_' + Name
         PUBLIC &mVar. := k

      ELSE
         *mVar := '_MenuDummyVar'
         *Name := 'DummyMenuName'
         *Public &mVar. := 0
         Name := ''
      ENDIF

      _HMG_SYSDATA [1] [k] := "MENU"
      _HMG_SYSDATA [2]  [k] :=  Name
      _HMG_SYSDATA [3]  [k] :=  _HMG_SYSDATA [ 172 ]   // Main Menu Handle   // Claudio Soto (July 2013)  Controlhandle   // This Not a Handle, this is lBoolean value
      _HMG_SYSDATA [4]  [k] :=  _HMG_SYSDATA [ 173 ]   // Form Parent Handle
      _HMG_SYSDATA [  5 ]  [k] :=  id
      _HMG_SYSDATA [  6 ]  [k] :=  action
      _HMG_SYSDATA [  7 ]  [k] :=  _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ] ]   // Popup Menu Handle
      _HMG_SYSDATA [  8 ]  [k] :=  Nil                                            // _HMG_SYSDATA [ 335 ] -> _HMG_xMenuPopuphandle
      _HMG_SYSDATA [  9 ]  [k] :=  ""                                             // _HMG_SYSDATA [ 174 ] -> counter of Popup Menu Handle
      _HMG_SYSDATA [ 10 ]  [k] :=  ""
      _HMG_SYSDATA [ 11 ]  [k] :=  ""
      _HMG_SYSDATA [ 12 ]  [k] :=  "MAIN_MENU_ITEM"   // ADD
      _HMG_SYSDATA [ 13 ]  [k] :=  .F.
      _HMG_SYSDATA [ 14 ]  [k] :=  Nil
      _HMG_SYSDATA [ 15 ] [k] :=   Nil
      _HMG_SYSDATA [ 16 ]   [k] := ""
      _HMG_SYSDATA [ 17 ]  [k] :=  {}
      _HMG_SYSDATA [ 18 ]  [k] :=  0
      _HMG_SYSDATA [ 19 ]   [k] := 0
      _HMG_SYSDATA [ 20 ]  [k] :=  0
      _HMG_SYSDATA [ 21 ]  [k] :=  0
      _HMG_SYSDATA [ 22 ]  [k] :=  0
      _HMG_SYSDATA [ 23 ]  [k] :=  -1
      _HMG_SYSDATA [ 24 ]  [k] :=  -1
      _HMG_SYSDATA [ 25 ]  [k] :=  ""
      _HMG_SYSDATA [ 26 ]  [k] :=  0
      _HMG_SYSDATA [ 27 ]  [k] :=  ''
      _HMG_SYSDATA [ 28 ]  [k] :=  0
      _HMG_SYSDATA [ 29 ]  [k] :=  {.f.,.f.,.f.,.f.}
      _HMG_SYSDATA [ 30 ]   [k] :=  ToolTip
      _HMG_SYSDATA [ 31 ]  [k] :=   0
      _HMG_SYSDATA [ 32 ]   [k] :=  0
      _HMG_SYSDATA [ 33 ]  [k] :=   Caption
      _HMG_SYSDATA [ 34 ]  [k] :=   .t.
      _HMG_SYSDATA [ 35 ]  [k] :=   0
      _HMG_SYSDATA [ 36 ]  [k] :=   0
      _HMG_SYSDATA [ 37 ]   [k] :=  0
      _HMG_SYSDATA [ 38 ]  [k] :=   .T.
      _HMG_SYSDATA [ 39 ] [k] := 0
      _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }   // ToolTip MenuItem Data

      IF checked == .t.
         xCheckMenuItem ( _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ] ] , id )
      ENDIF

   ELSE

      id := _GetId()

      Controlhandle := AppendMenuString ( _HMG_SYSDATA [ 175 ] , id ,  caption )   // This Not return a Handle, return lBoolean value

      IF Valtype ( image ) != 'U'
         MenuItem_SetBitMaps ( _HMG_SYSDATA [ 175 ] , Id , image , "" , NoTrans )
      ENDIF

      k := _GetControlFree()

      IF valtype (name) != 'U'
         mVar := '_' + _HMG_SYSDATA [ 221 ] + '_' + Name
         PUBLIC &mVar. := k

      ELSE
         *mVar := '_MenuDummyVar'
         *Name := 'DummyMenuName'
         *Public &mVar. := 0
         Name := ''
      ENDIF

      IF     _HMG_SYSDATA [ 218 ] == "CONTEXT"       // ADD
         cTypeMenu := "CONTEXT_MENU_ITEM"        // ADD
      ELSEIF _HMG_SYSDATA [ 218 ] == "NOTIFY"        // ADD
         cTypeMenu := "NOTIFY_MENU_ITEM"         // ADD
      ELSEIF _HMG_SYSDATA [ 218 ] == "DROPDOWN"      // ADD
         cTypeMenu := "DROPDOWN_MENU_ITEM"       // ADD
      ELSEIF _HMG_SYSDATA [ 218 ] == "CONTROL"       // ADD
         cTypeMenu := "CONTROL_MENU_ITEM"        // ADD
      ENDIF

      _HMG_SYSDATA [  1 ]  [k] :=   "MENU"
      _HMG_SYSDATA [  2 ]  [k] :=   Name
      _HMG_SYSDATA [  3 ]  [k] :=   _HMG_SYSDATA [ 175 ]   // Popup Menu Handle  // Claudio Soto (July 2013)   Controlhandle   // This Not a Handle, this is lBoolean value
      _HMG_SYSDATA [  4 ]  [k] :=   _HMG_SYSDATA [ 176 ]   // _HMG_SYSDATA [ 176 ] := GetFormHandle ( Parent )   // Form Parent Handle
      _HMG_SYSDATA [  5 ]  [k] :=   id
      _HMG_SYSDATA [  6 ]  [k] :=   action
      _HMG_SYSDATA [  7 ]  [k] :=   _HMG_SYSDATA [ 175 ]   //_HMG_SYSDATA [ 175 ] := CreatePopupMenu()   // Popup Menu Handle
      _HMG_SYSDATA [  8 ]  [k] :=   Nil
      _HMG_SYSDATA [  9 ]  [k] :=   ""
      _HMG_SYSDATA [ 10 ]  [k] :=   ""
      _HMG_SYSDATA [ 11 ]  [k] :=   _HMG_SYSDATA_cButtonName   // ADD
      _HMG_SYSDATA [ 12 ]  [k] :=   cTypeMenu         // ADD
      _HMG_SYSDATA [ 13 ]  [k] :=   .F.
      _HMG_SYSDATA [ 14 ]  [k] :=   Nil
      _HMG_SYSDATA [ 15 ]  [k] :=   Nil
      _HMG_SYSDATA [ 16 ]  [k] :=   ""
      _HMG_SYSDATA [ 17 ]  [k] :=   {}
      _HMG_SYSDATA [ 18 ]  [k] :=   _HMG_SYSDATA_nControlHandle // ADD
      _HMG_SYSDATA [ 19 ]  [k] :=   0
      _HMG_SYSDATA [ 20 ]  [k] :=   0
      _HMG_SYSDATA [ 21 ]  [k] :=   0
      _HMG_SYSDATA [ 22 ]  [k] :=   0
      _HMG_SYSDATA [ 23 ]  [k] :=   -1
      _HMG_SYSDATA [ 24 ]  [k] :=   -1
      _HMG_SYSDATA [ 25 ]  [k] :=   ""
      _HMG_SYSDATA [ 26 ]  [k] :=   0
      _HMG_SYSDATA [ 27 ]  [k] :=   ''
      _HMG_SYSDATA [ 28 ]  [k] :=   0
      _HMG_SYSDATA [ 29 ]  [k] :=   {.f.,.f.,.f.,.f.}
      _HMG_SYSDATA [ 30 ]  [k] :=   ToolTip
      _HMG_SYSDATA [ 31 ]  [k] :=   0
      _HMG_SYSDATA [ 32 ]  [k] :=   0
      _HMG_SYSDATA [ 33 ]  [k] :=   Caption
      _HMG_SYSDATA [ 34 ]  [k] :=   .t.
      _HMG_SYSDATA [ 35 ]  [k] :=   0
      _HMG_SYSDATA [ 36 ]  [k] :=   0
      _HMG_SYSDATA [ 37 ]  [k] :=   0
      _HMG_SYSDATA [ 38 ]  [k] :=   .T.
      _HMG_SYSDATA [ 39 ]  [k] :=   0
      _HMG_SYSDATA [ 40 ]  [k] :=   { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

      IF checked == .t.
         xCheckMenuItem ( _HMG_SYSDATA [ 175 ] , id )
      ENDIF

   ENDIF

   // by Dr. Claudio Soto, December 2014
   IF valtype(tooltip) != "U"
      GetFormNameByHandle ( _HMG_SYSDATA [ 4 ] [ k ] , @cParentName )
      MenuItemID  := _HMG_SYSDATA [ 5 ] [ k ]
      SetToolTipMenuItem ( GetFormHandle (cParentName), ToolTip, MenuItemID, GetMenuToolTipHandle (cParentName) )
   ENDIF

   RETURN NIL

FUNCTION _DefineSeparator ()

   IF _HMG_SYSDATA [ 218 ] == 'MAIN'

      APPENDMenuSeparator ( _HMG_SYSDATA [ 335 ] [_HMG_SYSDATA [ 174 ] ] )
   ELSE

      APPENDMenuSeparator ( _HMG_SYSDATA [ 175 ] )

   ENDIF

   RETURN NIL

FUNCTION _EndMenu()

   LOCAL i

   DO CASE
   CASE _HMG_SYSDATA [ 218 ] == 'MAIN'

      SetMenu( _HMG_SYSDATA [ 173 ] , _HMG_SYSDATA [ 172 ] )

   CASE _HMG_SYSDATA [ 218 ] == 'CONTEXT'

      i := GetFormIndex ( _HMG_SYSDATA [ 221 ] )
      _HMG_SYSDATA [ 74  ] [i] := _HMG_SYSDATA [ 175 ]

   CASE _HMG_SYSDATA [ 218 ] == 'NOTIFY'

      i := GetFormIndex ( _HMG_SYSDATA [ 221 ] )
      _HMG_SYSDATA [ 88 ] [i] := _HMG_SYSDATA [ 175 ]

   CASE _HMG_SYSDATA [ 218 ] == 'DROPDOWN'

      _HMG_SYSDATA [ 32 ] [_HMG_SYSDATA [ 169 ]] := _HMG_SYSDATA [ 175 ]

   ENDCASE

   RETURN NIL

FUNCTION _DisableMenuItem ( ItemName , FormName )

   LOCAL i , h , x

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   xDisableMenuItem ( h , i )

   RETURN NIL

FUNCTION _EnableMenuItem ( ItemName , FormName )

   LOCAL i , h , x

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   xEnableMenuItem ( h , i )

   RETURN NIL

FUNCTION _CheckMenuItem ( ItemName , FormName )

   LOCAL i , h , x

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   xCheckMenuItem ( h , i )

   RETURN NIL

FUNCTION _UncheckMenuItem ( ItemName , FormName )

   LOCAL i , h , x

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   xUncheckMenuItem ( h , i )

   RETURN NIL

FUNCTION _IsMenuItemChecked ( ItemName , FormName )

   LOCAL x,h,i,r,z

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   r := xGetMenuCheckState ( h , i )

   IF r == 1
      z := .t.
   ELSE
      z := .f.
   ENDIF

   RETURN z

FUNCTION _IsMenuItemEnabled ( ItemName , FormName )

   LOCAL x,h,i,r,z

   x := GetControlIndex ( ItemName , FormName )

   h := _HMG_SYSDATA [  7 ] [ x ]

   IF _HMG_SYSDATA [1] [ x ] == "MENU"
      i := _HMG_SYSDATA [  5 ] [ x ]
   ELSEIF _HMG_SYSDATA [1] [ x ] == "POPUP"
      i := _HMG_SYSDATA [ 22 ] [ x ]
   ENDIF

   r := xGetMenuEnabledState ( h , i )

   IF r == 1
      z := .t.
   ELSE
      z := .f.
   ENDIF

   RETURN z

FUNCTION _DefineContextMenu ( Parent )

   IF valtype(Parent) == 'U'
      Parent := _HMG_SYSDATA [ 223 ]
   ENDIF

   PUBLIC _HMG_SYSDATA_cButtonName := ""   // ADD
   PUBLIC _HMG_SYSDATA_nControlHandle := 0 // ADD

   IF IsContextMenuDefined (Parent) == .T.     // ADD
      MsgHMGError("Context Menu already defined in Window: "+ Parent + ". Program Terminated" )
   ENDIF

   _HMG_SYSDATA [ 175 ] := 0
   _HMG_SYSDATA [ 176 ] := 0
   _HMG_SYSDATA [ 177 ] := 0
   _HMG_SYSDATA [ 221 ] := ""

   _HMG_SYSDATA [ 218 ] := 'CONTEXT'

   _HMG_SYSDATA [ 174 ] := 0

   _HMG_SYSDATA [ 176 ] := GetFormHandle ( Parent )
   _HMG_SYSDATA [ 221 ] := Parent
   _HMG_SYSDATA [ 175 ] := CreatePopupMenu()

   RETURN NIL

FUNCTION _DefineNotifyMenu ( Parent )

   IF valtype(Parent) == 'U'
      Parent := _HMG_SYSDATA [ 223 ]
   ENDIF

   PUBLIC _HMG_SYSDATA_cButtonName := ""   // ADD
   PUBLIC _HMG_SYSDATA_nControlHandle := 0 // ADD

   IF IsNotifyMenuDefined (Parent) == .T.     // ADD
      MsgHMGError("Notify Menu already defined in Window: "+ Parent + ". Program Terminated" )
   ENDIF

   _HMG_SYSDATA [ 175 ] := 0
   _HMG_SYSDATA [ 176 ] := 0
   _HMG_SYSDATA [ 177 ] := 0
   _HMG_SYSDATA [ 221 ] := ""

   _HMG_SYSDATA [ 218 ] := 'NOTIFY'

   _HMG_SYSDATA [ 174 ] := 0

   _HMG_SYSDATA [ 176 ] := GetFormHandle ( Parent )
   _HMG_SYSDATA [ 221 ] := Parent
   _HMG_SYSDATA [ 175 ] := CreatePopupMenu()

   RETURN NIL

FUNCTION _DefineDropDownMenu ( cButton , Parent )

   IF valtype(Parent) == 'U'
      Parent := _HMG_SYSDATA [ 223 ]
   ENDIF

   PUBLIC _HMG_SYSDATA_cButtonName := cButton   // ADD
   PUBLIC _HMG_SYSDATA_nControlHandle := 0 // ADD

   IF IsDropDownMenuDefined ( cButton, Parent ) == .T.     // ADD
      MsgHMGError("DropDown Menu of Button: " + cButton + " already defined in Window: "+ Parent + ". Program Terminated" )
   ENDIF

   _HMG_SYSDATA [ 175 ] := 0
   _HMG_SYSDATA [ 176 ] := 0
   _HMG_SYSDATA [ 177 ] := 0
   _HMG_SYSDATA [ 221 ] := ""

   _HMG_SYSDATA [ 218 ] := 'DROPDOWN'

   _HMG_SYSDATA [ 174 ] := 0

   _HMG_SYSDATA [ 169 ] := GetControlIndex ( cButton , Parent )
   _HMG_SYSDATA [ 176 ] := GetFormHandle ( Parent )
   _HMG_SYSDATA [ 221 ] := Parent
   _HMG_SYSDATA [ 175 ] := CreatePopupMenu()

   RETURN NIL

   // Claudio Soto (March 2013)

PROCEDURE DeleteItem_HMG_SYSDATA (k)

   _HMG_SYSDATA [ 13 ] [k] := .T.
   _HMG_SYSDATA [  1 ] [k] := ""
   _HMG_SYSDATA [  2 ] [k] := ""
   _HMG_SYSDATA [  3 ] [k] := 0
   _HMG_SYSDATA [  4 ] [k] := 0
   _HMG_SYSDATA [  5 ] [k] := 0
   _HMG_SYSDATA [  6 ] [k] := ""
   _HMG_SYSDATA [  7 ] [k] := {}
   _HMG_SYSDATA [  8 ] [k] := NIL
   _HMG_SYSDATA [  9 ] [k] := ""
   _HMG_SYSDATA [ 10 ] [k] := ""
   _HMG_SYSDATA [ 11 ] [k] := ""
   _HMG_SYSDATA [ 12 ] [k] := ""
   _HMG_SYSDATA [ 14 ] [k] := NIL
   _HMG_SYSDATA [ 15 ] [k] := NIL
   _HMG_SYSDATA [ 16 ] [k] := ""
   _HMG_SYSDATA [ 17 ] [k] := {}
   _HMG_SYSDATA [ 18 ] [k] := 0
   _HMG_SYSDATA [ 19 ] [k] := 0
   _HMG_SYSDATA [ 20 ] [k] := 0
   _HMG_SYSDATA [ 21 ] [k] := 0
   _HMG_SYSDATA [ 22 ] [k] := 0
   _HMG_SYSDATA [ 23 ] [k] := 0
   _HMG_SYSDATA [ 24 ] [k] := 0
   _HMG_SYSDATA [ 25 ] [k] := ''
   _HMG_SYSDATA [ 26 ] [k] := 0
   _HMG_SYSDATA [ 27 ] [k] := ''
   _HMG_SYSDATA [ 28 ] [k] := 0
   _HMG_SYSDATA [ 30 ] [k] := ''
   _HMG_SYSDATA [ 31 ] [k] := 0
   _HMG_SYSDATA [ 32 ] [k] := 0
   _HMG_SYSDATA [ 33 ] [k] := ''
   _HMG_SYSDATA [ 34 ] [k] := .F.
   _HMG_SYSDATA [ 35 ] [k] := 0
   _HMG_SYSDATA [ 36 ] [k] := 0
   _HMG_SYSDATA [ 29 ] [k] := {}
   _HMG_SYSDATA [ 37 ] [k] := 0
   _HMG_SYSDATA [ 38 ] [k] := .F.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := NIL

   RETURN

FUNCTION IsMainMenuDefined ( cParentForm )

   LOCAL hWnd, Ret

   hWnd := GetFormHandle (cParentForm)
   Ret  := ExistMainMenu (hWnd)

   RETURN Ret

FUNCTION IsContextMenuDefined ( cParentForm )

   LOCAL hWnd, k

   hWnd := GetFormHandle ( cParentForm )
   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "CONTEXT_MENU_ITEM") .AND. (_HMG_SYSDATA [4] [k] == hWnd))

            RETURN .T.
         ENDIF
      ENDIF
   NEXT

   RETURN .F.

FUNCTION IsNotifyMenuDefined ( cParentForm )

   LOCAL hWnd, k

   hWnd := GetFormHandle ( cParentForm )
   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "NOTIFY_MENU_ITEM") .AND. (_HMG_SYSDATA [4] [k] == hWnd))

            RETURN .T.
         ENDIF
      ENDIF
   NEXT

   RETURN .F.

FUNCTION IsDropDownMenuDefined ( cButton, cParentForm )

   LOCAL hWnd, k

   hWnd := GetFormHandle ( cParentForm )
   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "DROPDOWN_MENU_ITEM") .AND. (_HMG_SYSDATA [11] [k] == cButton) .AND. (_HMG_SYSDATA [4] [k] == hWnd))

            RETURN .T.
         ENDIF
      ENDIF
   NEXT

   RETURN .F.

FUNCTION ReleaseMainMenu ( cParentForm )

   LOCAL hWnd, k, Ret := 0

   IF VALTYPE (cParentForm) == 'U'
      cParentForm := ThisWindow.Name
   ENDIF

   IF IsMainMenuDefined (cParentForm) == .F.
      MsgHMGError("Main Menu not defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   hWnd := GetFormHandle ( cParentForm )
   DELETEMainMenu (hWnd)

   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "MAIN_MENU_ITEM" .OR. _HMG_SYSDATA [12] [k] == "MAIN_MENU_POPUP") .AND. (_HMG_SYSDATA [4] [k] == hWnd))
            DELETEItem_HMG_SYSDATA (k)
            Ret ++
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

FUNCTION ReleaseContextMenu ( cParentForm )

   LOCAL hWnd, hMenu, k, Ret := 0

   IF VALTYPE (cParentForm) == 'U'
      cParentForm := ThisWindow.Name
   ENDIF

   IF IsContextMenuDefined (cParentForm) == .F.
      MsgHMGError("Context Menu not defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   hWnd := GetFormHandle ( cParentForm )

   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "CONTEXT_MENU_ITEM") .AND. (_HMG_SYSDATA [4] [k] == hWnd))
            hMenu := _HMG_SYSDATA [7] [k]
            DestroyMenu (hMenu)
            DELETEItem_HMG_SYSDATA (k)
            Ret ++
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

FUNCTION ReleaseNotifyMenu ( cParentForm )

   LOCAL hWnd, hMenu, k, Ret := 0

   IF VALTYPE (cParentForm) == 'U'
      cParentForm := ThisWindow.Name
   ENDIF

   IF IsNotifyMenuDefined (cParentForm) == .F.
      MsgHMGError("Notify Menu not defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   hWnd := GetFormHandle ( cParentForm )

   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "NOTIFY_MENU_ITEM") .AND. (_HMG_SYSDATA [4] [k] == hWnd))
            hMenu := _HMG_SYSDATA [7] [k]
            DestroyMenu (hMenu)
            DELETEItem_HMG_SYSDATA (k)
            Ret ++
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

FUNCTION ReleaseDropDownMenu ( cButton, cParentForm )

   LOCAL hWnd, hMenu, k, Ret := 0

   IF VALTYPE (cParentForm) == 'U'
      cParentForm := ThisWindow.Name
   ENDIF

   IF IsDropDownMenuDefined ( cButton, cParentForm) == .F.
      MsgHMGError("DropDown Menu of Button: " + cButton + " not defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   hWnd := GetFormHandle ( cParentForm )

   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "DROPDOWN_MENU_ITEM") .AND. (_HMG_SYSDATA [11] [k] == cButton) .AND. (_HMG_SYSDATA [4] [k] == hWnd))
            hMenu := _HMG_SYSDATA [7] [k]
            DestroyMenu (hMenu)
            DELETEItem_HMG_SYSDATA (k)
            Ret ++
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

   // Control Context Menu

   // Claudio Soto (May 2013)

FUNCTION _DefineControlContextMenu ( cControl, cParentForm )

   IF valtype(cParentForm) == 'U'
      cParentForm := _HMG_SYSDATA [ 223 ]
   ENDIF

   PUBLIC _HMG_SYSDATA_cButtonName := ""   // ADD
   PUBLIC _HMG_SYSDATA_nControlHandle := 0 // ADD

   IF IsControlContextMenuDefined ( cControl, cParentForm ) == .T.
      MsgHMGError("Context Menu of Control: " + cControl + " already defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   _HMG_SYSDATA [ 175 ] := 0
   _HMG_SYSDATA [ 176 ] := 0
   _HMG_SYSDATA [ 177 ] := 0
   _HMG_SYSDATA [ 221 ] := ""

   _HMG_SYSDATA [ 218 ] := 'CONTROL'

   _HMG_SYSDATA [ 174 ] := 0

   _HMG_SYSDATA_nControlHandle := GetControlHandle ( cControl, cParentForm  )
   _HMG_SYSDATA [ 176 ] := GetFormHandle ( cParentForm  )
   _HMG_SYSDATA [ 221 ] := cParentForm
   _HMG_SYSDATA [ 175 ] := CreatePopupMenu()

   RETURN NIL

FUNCTION IsControlContextMenuDefined ( cControl, cParentForm )

   LOCAL hWnd, nControlHandle, k

   hWnd := GetFormHandle ( cParentForm )
   nControlHandle := GetControlHandle ( cControl, cParentForm )
   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "CONTROL_MENU_ITEM") .AND. _TestControlHandle_ContextMenu (_HMG_SYSDATA [18] [k], nControlHandle) .AND. (_HMG_SYSDATA [4] [k] == hWnd))

            RETURN .T.
         ENDIF
      ENDIF
   NEXT

   RETURN .F.

FUNCTION ReleaseControlContextMenu ( cControl, cParentForm )

   LOCAL hWnd, hMenu, nControlHandle, k, Ret := 0

   IF VALTYPE (cParentForm) == 'U'
      cParentForm := ThisWindow.Name
   ENDIF

   IF IsControlContextMenuDefined ( cControl, cParentForm ) == .F.
      MsgHMGError("Context Menu of Control: " + cControl + " not defined in Window: "+ cParentForm + ". Program Terminated" )
   ENDIF

   hWnd := GetFormHandle ( cParentForm )
   nControlHandle := GetControlHandle ( cControl, cParentForm )

   FOR k = 1 TO HMG_LEN (_HMG_SYSDATA [1])
      IF (_HMG_SYSDATA [1] [k] == "MENU") .OR. (_HMG_SYSDATA [1] [k] == "POPUP")
         IF ((_HMG_SYSDATA [12] [k] == "CONTROL_MENU_ITEM") .AND. _TestControlHandle_ContextMenu (_HMG_SYSDATA [18] [k], nControlHandle) .AND. (_HMG_SYSDATA [4] [k] == hWnd))
            hMenu := _HMG_SYSDATA [7] [k]
            DestroyMenu (hMenu)
            DELETEItem_HMG_SYSDATA (k)
            Ret ++
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

FUNCTION _TestControlHandle_ContextMenu  ( Handle , ControlHandle )

   LOCAL i, k

   IF ValType (Handle) == "N" .AND. ValType (ControlHandle) == "N"

      RETURN (Handle == ControlHandle)
   ENDIF

   IF ValType (Handle) == "A" .AND. ValType (ControlHandle) == "N"
      FOR i = 1 TO HMG_LEN (Handle)
         IF Handle [i] == ControlHandle

            RETURN .T.
         ENDIF
      NEXT

      RETURN .F.
   ENDIF

   IF ValType (Handle) == "N" .AND. ValType (ControlHandle) == "A"
      FOR i = 1 TO HMG_LEN (ControlHandle)
         IF Handle == ControlHandle [i]

            RETURN .T.
         ENDIF
      NEXT

      RETURN .F.
   ENDIF

   IF ValType (Handle) == "A" .AND. ValType (ControlHandle) == "A"
      FOR i = 1 TO HMG_LEN (Handle)
         FOR k = 1 TO HMG_LEN (ControlHandle)
            IF Handle [i] == ControlHandle [k]

               RETURN .T.
            ENDIF
         NEXT
      NEXT

      RETURN .F.
   ENDIF

   RETURN .F.

