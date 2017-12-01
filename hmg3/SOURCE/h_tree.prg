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

#include "common.ch"
#include "hmg.ch"

#define TVE_COLLAPSE   1      // ok
#define TVE_EXPAND     2      // ok

FUNCTION _DefineTree ( ControlName , ParentForm , row , col , width , height , change , tooltip ,;
      fontname , fontsize , gotfocus , lostfocus , dblclick , break , value  , HelpId ,;
      aImgNode, aImgItem, noBot , bold, italic, underline, strikeout , itemids , rootbutton ,;
      NoTrans , ON_EXPAND, ON_COLLAPSE, aBackColor, aFontColor, DynamicBackColor , DynamicForeColor , DynamicFont )
   LOCAL i , cParentForm , Controlhandle , mVar, ImgDefNode, ImgDefItem, aBitmaps := array(4)
   LOCAL FontHandle , k

   _HMG_SYSDATA [ 180 ] := 0
   _HMG_SYSDATA [ 307 ] := 1
   _HMG_SYSDATA [ 337 ] [1] := 0
   _HMG_SYSDATA [ 138 ] := {}
   _HMG_SYSDATA [ 139 ] := {}
   _HMG_SYSDATA [ 259 ] := itemids

   IF valtype (rootbutton) == 'L'
      noBot := .Not. RootButton
   ENDIF

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
      IF .Not. Empty (_HMG_SYSDATA [ 224 ]) .And. ValType(FontName) == "U"
         FontName := _HMG_SYSDATA [ 224 ]
      ENDIF
      IF .Not. Empty (_HMG_SYSDATA [ 182 ]) .And. ValType(FontSize) == "U"
         FontSize := _HMG_SYSDATA [ 182 ]
      ENDIF
   ENDIF
   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         col    := col + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         row    := row + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF valtype(Value) == "U"
      _HMG_SYSDATA [ 178 ] := 0
   ELSE
      _HMG_SYSDATA [ 178 ] := Value
   ENDIF
   IF valtype(Width) == "U"
      Width := 120
   ENDIF
   IF valtype(Height) == "U"
      Height := 120
   ENDIF

   IF valtype(Row) == "U" .or. valtype(Col) == "U"

      IF _HMG_SYSDATA [ 216 ] == 'TOOLBAR'
         Break := .T.
      ENDIF

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitTree ( _HMG_SYSDATA [ 87 ] [i] , col , row , width , height , 0 , '' , 0, iif(noBot,.T.,.F.) )
         IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_SYSDATA [ 87 ] [i] , Width , break , , , , _HMG_SYSDATA [ 258 ] )

         _HMG_SYSDATA [ 216 ] := 'TREE'

      ENDIF

   ELSE

      ControlHandle := InitTree ( ParentForm , col , row , width , height , 0 , '' , 0, iif(noBot,.T.,.F.) )
      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ])
      ENDIF

   ENDIF

   ImgDefNode := iif( valtype( aImgNode ) == "A" , HMG_LEN( aImgNode ), 0 )  //Tree+
   ImgDefItem := iif( valtype( aImgItem ) == "A" , HMG_LEN( aImgItem ), 0 )  //Tree+

   ImgDefNode := IF (ImgDefNode > 2, 2, ImgDefNode)   // ADD  get only first two NODE bitmaps
   ImgDefItem := IF (ImgDefItem > 2, 2, ImgDefItem)   // ADD  get only first two ITEM bitmaps

   IF ImgDefNode > 0

      aBitmaps[1] := aImgNode[1]           // Node default
      aBitmaps[2] := aImgNode[ImgDefNode]

      IF ImgDefItem > 0

         aBitmaps[3] := aImgItem[1]        // Item default
         aBitmaps[4] := aImgItem[ImgDefItem]

      ELSE

         aBitmaps[3] := aImgNode[1]         // Copy Node def if no Item def
         aBitmaps[4] := aImgNode[ImgDefNode]

      ENDIF

      InitTreeViewBitmap( ControlHandle, aBitmaps, NoTrans ) //Init Bitmap List
   ENDIF

   _HMG_SYSDATA [ 180 ] := ControlHandle

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , ControlHandle )
   ENDIF

   IF valtype(change) == "U"
      change := ""
   ENDIF

   IF valtype(gotfocus) == "U"
      gotfocus := ""
   ENDIF

   IF valtype(lostfocus) == "U"
      lostfocus := ""
   ENDIF

   IF valtype(dblclick) == "U"
      dblclick := ""
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [ 179 ] := k

   _HMG_SYSDATA [  1 ] [k] := "TREE"
   _HMG_SYSDATA [  2 ] [k] :=   ControlName
   _HMG_SYSDATA [  3 ] [k] :=   ControlHandle
   _HMG_SYSDATA [  4 ] [k] :=   ParentForm
   _HMG_SYSDATA [  5 ] [k] :=   0
   _HMG_SYSDATA [  6 ] [k] :=   ""
   _HMG_SYSDATA [  7 ] [k] :=  {}      // nTreeItemHandle
   _HMG_SYSDATA [  8 ] [k] :=  Nil
   _HMG_SYSDATA [  9 ] [k] :=  itemids
   _HMG_SYSDATA [ 10 ] [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ] [k] :=  gotfocus
   _HMG_SYSDATA [ 12 ] [k] :=  change
   _HMG_SYSDATA [ 13 ] [k] :=  .F.
   _HMG_SYSDATA [ 14 ] [k] :=  Nil
   _HMG_SYSDATA [ 15 ] [k] :=  Nil
   _HMG_SYSDATA [ 16 ] [k] := dblclick
   _HMG_SYSDATA [ 17 ] [k] := {ON_EXPAND, ON_COLLAPSE}
   _HMG_SYSDATA [ 18 ] [k] := Row
   _HMG_SYSDATA [ 19 ] [k] := Col
   _HMG_SYSDATA [ 20 ] [k] := Width
   _HMG_SYSDATA [ 21 ] [k] := Height
   _HMG_SYSDATA [ 22 ] [k] := 0
   _HMG_SYSDATA [ 23 ] [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ] [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ] [k] :=  {}     // nTreeItemID
   _HMG_SYSDATA [ 26 ] [k] :=  { ImgDefNode, ImgDefItem }  // Numbers of bitmaps defined in NODEIMAGES and in ITEMIMAGES
   _HMG_SYSDATA [ 27 ] [k] :=  fontname
   _HMG_SYSDATA [ 28 ] [k] :=  fontsize
   _HMG_SYSDATA [ 29 ] [k] := {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ] [k] :=  tooltip
   _HMG_SYSDATA [ 31 ] [k] :=  0
   _HMG_SYSDATA [ 32 ] [k] :=  {} // cargo
   _HMG_SYSDATA [ 33 ] [k] :=  ''
   _HMG_SYSDATA [ 34 ] [k] :=   .t.
   _HMG_SYSDATA [ 35 ] [k] :=   HelpId
   _HMG_SYSDATA [ 36 ] [k] :=  FontHandle
   _HMG_SYSDATA [ 37 ] [k] :=   0
   _HMG_SYSDATA [ 38 ] [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := NoTrans
   _HMG_SYSDATA [ 40 ] [k] := { DynamicBackColor , DynamicForeColor , DynamicFont , aBackColor, aFontColor, 0 /*hFontDynamic*/ , NIL , NIL }

   IF ValType (aFontColor) == "A"
      TreeView_SetTextColor (ControlHandle, aFontColor)
   ENDIF

   IF ValType (aBackColor) == "A"
      TreeView_SetBkColor (ControlHandle, aBackColor )
   ENDIF

   RETURN NIL

FUNCTION _DefineTreeNode ( text, aImage , nID )

   LOCAL    ImgDef, iUnSel, iSel
   LOCAL k := GetControlIndexByHandle ( _HMG_SYSDATA [ 180 ] )

   IF ValType ( nID ) == 'U'
      nID := 0
   ENDIF

   ImgDef := iif( valtype( aImage ) == "A" , HMG_LEN( aImage ), 0 )  //Tree+

   IF ImgDef == 0

      iUnsel := 0   // Index to defalut Node Bitmaps, no Bitmap loaded
      iSel   := 1

   ELSE
      iUnSel := AddTreeViewBitmap( _HMG_SYSDATA [ 180 ], aImage[1], _HMG_SYSDATA [ 39 ] [k] ) -1
      iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( _HMG_SYSDATA [ 180 ], aImage[2], _HMG_SYSDATA [ 39 ] [k] ) -1 )
      // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
   ENDIF

   _HMG_SYSDATA [ 307 ]++
   _HMG_SYSDATA [ 337 ] [_HMG_SYSDATA [ 307 ]]:= AddTreeItem ( _HMG_SYSDATA [ 180 ] , _HMG_SYSDATA [ 337 ] [_HMG_SYSDATA [ 307 ]-1] , text, iUnsel, iSel , nID , _IS_TREE_NODE_ )
   aAdd ( _HMG_SYSDATA [ 138 ] , _HMG_SYSDATA [ 337 ] [_HMG_SYSDATA [ 307 ]] )
   aAdd ( _HMG_SYSDATA [ 139 ] , nID )
   AADD ( _HMG_SYSDATA [ 32 ] [ _HMG_SYSDATA [ 179 ] ], NIL)   // cargo

   RETURN NIL

FUNCTION _EndTreeNode()

   _HMG_SYSDATA [ 307 ]--

   RETURN NIL

FUNCTION _DefineTreeItem ( text, aImage , nID )

   LOCAL ItemHandle, ImgDef, iUnSel, iSel
   LOCAL k := GetControlIndexByHandle ( _HMG_SYSDATA [ 180 ] )

   IF ValType ( nID ) == 'U'
      nID := 0
   ENDIF

   ImgDef := iif( valtype( aImage ) == "A" , HMG_LEN( aImage ), 0 )  //Tree+

   IF ImgDef == 0

      iUnsel := 2   // Index to defalut Item Bitmaps, no Bitmap loaded
      iSel   := 3

   ELSE
      iUnSel := AddTreeViewBitmap( _HMG_SYSDATA [ 180 ], aImage[1], _HMG_SYSDATA [ 39 ] [k] ) -1
      iSel   := iif( ImgDef == 1, iUnSel, AddTreeViewBitmap( _HMG_SYSDATA [ 180 ], aImage[2], _HMG_SYSDATA [ 39 ] [k] ) -1 )
      // If only one bitmap in array iSel = iUnsel, only one Bitmap loaded
   ENDIF

   ItemHandle := AddTreeItem ( _HMG_SYSDATA [ 180 ] , _HMG_SYSDATA [ 337 ] [_HMG_SYSDATA [ 307 ]] , text, iUnSel, iSel , nID, _IS_TREE_ITEM_ )
   aAdd ( _HMG_SYSDATA [ 138 ] , ItemHandle )
   aAdd ( _HMG_SYSDATA [ 139 ] , nID )
   AADD ( _HMG_SYSDATA [ 32 ] [ _HMG_SYSDATA [ 179 ] ], NIL)   // cargo

   RETURN NIL

FUNCTION _EndTree()

   _HMG_SYSDATA [  7 ] [ _HMG_SYSDATA [ 179 ] ] := _HMG_SYSDATA [ 138 ]
   _HMG_SYSDATA [ 25 ] [ _HMG_SYSDATA [ 179 ] ] := _HMG_SYSDATA [ 139 ]

   IF _HMG_SYSDATA [ 178 ] > 0

      IF _HMG_SYSDATA [ 259 ] == .F.
         TreeView_SelectItem ( _HMG_SYSDATA [ 180 ] , _HMG_SYSDATA [ 138 ] [ _HMG_SYSDATA [ 178 ] ] )
      ELSE
         TreeView_SelectItem ( _HMG_SYSDATA [ 180 ] , _HMG_SYSDATA [ 138 ] [ ascan ( _HMG_SYSDATA [ 139 ] , _HMG_SYSDATA [ 178 ] ) ] )
      ENDIF

   ENDIF

   RETURN NIL

PROCEDURE _Collapse ( ControlName , ParentForm , nItem , lRecurse)

   LOCAL i , ItemHandle

   i := GetControlIndex( ControlName , ParentForm )
   IF i > 0
      ItemHandle := TreeItemGetHandle ( ControlName , ParentForm , nItem )   // Claudio Soto (November 2013)
      IF ItemHandle <> 0
         DEFAULT lRecurse TO .F.
         TreeView_ExpandChildrenRecursive ( _HMG_SYSDATA [3] [i], ItemHandle, TVE_COLLAPSE, lRecurse )   // Claudio Soto (November 2013)
      ENDIF
   ENDIF

   RETURN

PROCEDURE _Expand ( ControlName , ParentForm , nItem , lRecurse)

   LOCAL i , ItemHandle

   i := GetControlIndex( ControlName , ParentForm )
   IF i > 0
      ItemHandle := TreeItemGetHandle ( ControlName , ParentForm , nItem )   // Claudio Soto (November 2013)
      IF ItemHandle <> 0
         DEFAULT lRecurse TO .F.
         TreeView_ExpandChildrenRecursive ( _HMG_SYSDATA [3] [i], ItemHandle, TVE_EXPAND, lRecurse )   // Claudio Soto (November 2013)
      ENDIF
   ENDIF

   RETURN

   // by Dr. Claudio Soto (November 2013)

PROCEDURE TreeItemCollapse2 ( i , nItem , lRecurse)

   LOCAL ItemHandle

   IF i > 0
      ItemHandle := TreeItemGetHandle2 ( i , nItem )
      IF ItemHandle <> 0
         DEFAULT lRecurse TO .F.
         TreeView_ExpandChildrenRecursive ( _HMG_SYSDATA [3] [i], ItemHandle, TVE_COLLAPSE, lRecurse )
      ENDIF
   ENDIF

   RETURN

PROCEDURE TreeItemExpand2 ( i , nItem , lRecurse)

   LOCAL ItemHandle

   IF i > 0
      ItemHandle := TreeItemGetHandle2 ( i , nItem )
      IF ItemHandle <> 0
         DEFAULT lRecurse TO .F.
         TreeView_ExpandChildrenRecursive ( _HMG_SYSDATA [3] [i], ItemHandle, TVE_EXPAND, lRecurse )
      ENDIF
   ENDIF

   RETURN

FUNCTION TreeItemGetHandle2 ( i , nItem )

   LOCAL nPos, nID, ItemHandle := 0

   IF i > 0
      IF _HMG_SYSDATA [ 9 ] [i] == .F.
         nPos := nItem
         ItemHandle := _HMG_SYSDATA [7] [i] [ nPos ]   // nPos
      ELSE
         nID := nItem
         nPos := ASCAN ( _HMG_SYSDATA [25] [i] , nID ) // nID
         ItemHandle := _HMG_SYSDATA [7] [i] [ nPos ]
      ENDIF
   ENDIF

   RETURN ItemHandle

FUNCTION TreeItemGetHandle ( ControlName , ParentForm , nItem )

   LOCAL nPos, nID, ItemHandle := 0
   LOCAL i := GetControlIndex( ControlName , ParentForm )

   IF i > 0
      IF _HMG_SYSDATA [ 9 ] [i] == .F.
         nPos := nItem
         ItemHandle := _HMG_SYSDATA [7] [i] [ nPos ]   // nPos
      ELSE
         nID := nItem
         nPos := ASCAN ( _HMG_SYSDATA [25] [i] , nID ) // nID
         ItemHandle := _HMG_SYSDATA [7] [i] [ nPos ]
      ENDIF
   ENDIF

   RETURN ItemHandle

FUNCTION TreeItemGetParentHandle ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEVIEW_GETPARENT ( nControlHandle, ItemHandle )

FUNCTION TreeItemGetRootHandle ( ControlName , ParentForm)

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )

   RETURN TREEVIEW_GETROOT ( nControlHandle )

FUNCTION TreeItemGetValueByItemHandle ( ControlName , ParentForm , ItemHandle )

   LOCAL nPos, nID
   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL i := GetControlIndex  ( ControlName , ParentForm )

   IF i > 0 .AND. ItemHandle <> 0
      IF _HMG_SYSDATA [9] [i] == .F.
         nPos := ASCAN ( _HMG_SYSDATA [7] [i], ItemHandle )

         RETURN nPos
      ELSE
         nID := TREEITEM_GETID ( nControlHandle, ItemHandle )

         RETURN nID
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION TreeItemGetValueByItemHandle2 ( i , ItemHandle )

   LOCAL nPos, nID
   LOCAL nControlHandle := GetControlHandleByIndex ( i )

   IF i > 0 .AND. ItemHandle <> 0
      IF _HMG_SYSDATA [9] [i] == .F.
         nPos := ASCAN ( _HMG_SYSDATA [7] [i], ItemHandle )

         RETURN nPos
      ELSE
         nID := TREEITEM_GETID ( nControlHandle, ItemHandle )

         RETURN nID
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION TreeGetImageCount ( ControlName , ParentForm )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )

   RETURN TREEVIEW_GETIMAGECOUNT ( nControlHandle )

FUNCTION TreeAddImage ( ControlName , ParentForm ,  cImageName )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL k := GetControlIndex ( ControlName , ParentForm )

   RETURN ADDTREEVIEWBITMAP ( nControlHandle , cImageName, _HMG_SYSDATA [ 39 ] [k] )

FUNCTION TreeItemGetAllValue ( ControlName , ParentForm )

   LOCAL k, aAllValues := {}
   LOCAL i := GetControlIndex  ( ControlName , ParentForm )

   IF i > 0 .AND. GetProperty ( ParentForm, ControlName, "ItemCount" ) > 0
      IF _HMG_SYSDATA [9] [i] == .F.
         FOR k = 1 TO GetProperty ( ParentForm, ControlName, "ItemCount" )
            AADD (aAllValues, k)
         NEXT
      ELSE
         aAllValues := _HMG_SYSDATA [25] [i]   // nTreeItemID
      ENDIF
   ENDIF

   RETURN IF (EMPTY(aAllValues), NIL, aAllValues)

FUNCTION TreeItemGetRootValue ( ControlName , ParentForm )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetRootHandle ( ControlName , ParentForm )

   RETURN TreeItemGetValueByItemHandle ( ControlName , ParentForm , ItemHandle )

FUNCTION TreeItemGetFirstItemValue ( ControlName , ParentForm )

   LOCAL nIndex     := GetControlIndex ( ControlName , ParentForm )
   LOCAL nID , nPos := 1

   IF GetProperty ( ParentForm, ControlName, "ItemCount" ) > 0
      IF _HMG_SYSDATA [9] [nIndex] == .F.

         RETURN nPos
      ELSE
         nID := _HMG_SYSDATA [25] [nIndex] [nPos]

         RETURN nID
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION TreeItemGetParentValue ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetParentHandle ( ControlName , ParentForm , nItem )

   RETURN TreeItemGetValueByItemHandle ( ControlName , ParentForm , ItemHandle )

FUNCTION TreeItemGetChildValue ( ControlName , ParentForm , nItem )

   LOCAL ChildItem, NextItem, aChildValues := {}
   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   ChildItem := TreeView_GetChild ( nControlHandle , ItemHandle )
   WHILE (ChildItem <> 0)
      AADD (aChildValues, TreeItemGetValueByItemHandle(ControlName, ParentForm, ChildItem) )
      NEXTItem = TreeView_GetNextSibling ( nControlHandle , ChildItem )
      ChildItem = NextItem
   ENDDO

   RETURN IF (EMPTY(aChildValues), NIL, aChildValues)

FUNCTION TreeItemGetSiblingValue ( ControlName , ParentForm , nItem )

   LOCAL SiblingItem, FirstItem, NextItem, aSiblingValues := {}
   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   IF ItemHandle <> TreeItemGetRootHandle ( ControlName , ParentForm)
      FirstItem := SiblingItem := ItemHandle
      WHILE (SiblingItem <> 0)
         SiblingItem := TreeView_GetPrevSibling ( nControlHandle , FirstItem )
         IF SiblingItem <> 0
            FirstItem := SiblingItem
         ENDIF
      ENDDO
      SiblingItem := FirstItem
      WHILE (SiblingItem <> 0)
         AADD (aSiblingValues, TreeItemGetValueByItemHandle(ControlName, ParentForm, SiblingItem) )
         NEXTItem = TreeView_GetNextSibling ( nControlHandle , SiblingItem )
         SiblingItem = NextItem
      ENDDO
   ENDIF

   RETURN IF (EMPTY(aSiblingValues), NIL, aSiblingValues)

FUNCTION TreeItemGetDisplayLevel ( ControlName , ParentForm , nItem )

   LOCAL nDisplayColumn := NIL
   LOCAL aPathValues    := TreeItemGetPathValue ( ControlName , ParentForm , nItem )

   IF ValType (aPathValues) == "A"
      nDisplayColumn := HMG_LEN (aPathValues)
   ENDIF

   RETURN nDisplayColumn

FUNCTION TreeItemGetPathValue ( ControlName , ParentForm , nItem )

   LOCAL ParentItem, aPathValues := NIL
   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   IF ItemHandle <> 0
      aPathValues := { nItem }
      ParentItem := TreeView_GetParent ( nControlHandle , ItemHandle )
      WHILE (ParentItem <> 0)
         AADD (aPathValues, NIL)
         AINS (aPathValues,  1 )
         aPathValues [1] := TreeItemGetValueByItemHandle ( ControlName, ParentForm, ParentItem )
         ParentItem := TreeView_GetParent ( nControlHandle , ParentItem )
      ENDDO
   ENDIF

   RETURN aPathValues

FUNCTION TreeItemGetPathName ( ControlName , ParentForm , nItem )

   LOCAL aPathName   := NIL
   LOCAL aPathValues := TreeItemGetPathValue ( ControlName , ParentForm , nItem )

   IF ValType (aPathValues) == "A"
      aPathName := TreeItemGetItemText ( ControlName , ParentForm , aPathValues )
   ENDIF

   RETURN aPathName

FUNCTION TreeItemGetItemText ( ControlName , ParentForm , aItem )

   LOCAL k, cText, aItemsText := NIL

   IF ValType (aItem) == "A"
      aItemsText := {}
      FOR k = 1 TO HMG_LEN (aItem)
         cText := GetProperty ( ParentForm, ControlName, "Item", aItem [k] )
         AADD (aItemsText, cText)
      NEXT
   ENDIF

   RETURN aItemsText

FUNCTION TreeItemIsTrueNode ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEITEM_ISTRUENODE ( nControlHandle, ItemHandle )

FUNCTION TreeItemSetNodeFlag ( ControlName , ParentForm , nItem , lNodeFlag)

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEITEM_SETNODEFLAG ( nControlHandle, ItemHandle, lNodeFlag )

FUNCTION TreeItemGetNodeFlag ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEITEM_GETNODEFLAG ( nControlHandle, ItemHandle )

FUNCTION TreeItemSetImageIndex ( ControlName , ParentForm , nItem , aSel)

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEITEM_SETIMAGEINDEX ( nControlHandle , ItemHandle , aSel[1] , aSel[2] )   // { iUnSel , iSel }

FUNCTION TreeItemGetImageIndex ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )

   RETURN TREEITEM_GETIMAGEINDEX ( nControlHandle , ItemHandle )   // { iUnSel , iSel }

PROCEDURE TreeItemSetDefaultNodeFlag ( ControlName , ParentForm , nItem )

   IF TreeItemIsTrueNode ( ControlName , ParentForm , nItem ) == .T. .AND. TreeItemGetNodeFlag ( ControlName , ParentForm , nItem ) == .F.
      TreeItemSetNodeFlag   ( ControlName , ParentForm , nItem , _IS_TREE_NODE_ )
      TreeItemSetImageIndex ( ControlName , ParentForm , nItem , TREEIMAGEINDEX_NODE )   // { iUnSel = 0 , iSel = 1 }

   ELSEIF TreeItemIsTrueNode ( ControlName , ParentForm , nItem ) == .F. .AND. TreeItemGetNodeFlag ( ControlName , ParentForm , nItem ) == .T.
      TreeItemSetNodeFlag   ( ControlName , ParentForm , nItem , _IS_TREE_ITEM_ )
      TreeItemSetImageIndex ( ControlName , ParentForm , nItem , TREEIMAGEINDEX_ITEM )   // { iUnSel = 2 , iSel = 3 }
   ENDIF

   RETURN

PROCEDURE TreeItemSetDefaultAllNodeFlag ( ControlName , ParentForm )

   LOCAL k, ItemHandle, aSel
   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL nIndex := GetControlIndex ( ControlName , ParentForm )

   FOR k = 1 TO GetProperty ( ParentForm, ControlName, "ItemCount" )
      ItemHandle := _HMG_SYSDATA [7] [nIndex] [k]
      IF TREEITEM_ISTRUENODE ( nControlHandle, ItemHandle ) == .T. .AND. TREEITEM_GETNODEFLAG ( nControlHandle, ItemHandle ) == .F.
         aSel := TREEIMAGEINDEX_NODE
         TREEITEM_SETNODEFLAG   ( nControlHandle, ItemHandle, _IS_TREE_NODE_ )
         TREEITEM_SETIMAGEINDEX ( nControlHandle, ItemHandle,  aSel[1] , aSel[2] )   // { iUnSel = 0 , iSel = 1 }

      ELSEIF TREEITEM_ISTRUENODE ( nControlHandle, ItemHandle ) == .F. .AND. TREEITEM_GETNODEFLAG ( nControlHandle, ItemHandle ) == .T.
         aSel := TREEIMAGEINDEX_ITEM
         TREEITEM_SETNODEFLAG   ( nControlHandle, ItemHandle, _IS_TREE_ITEM_ )
         TREEITEM_SETIMAGEINDEX ( nControlHandle, ItemHandle,  aSel[1] , aSel[2] )   // { iUnSel = 2 , iSel = 3 }
      ENDIF
   NEXT

   RETURN

PROCEDURE TreeItemSort (cTreeName, cFormName, nItem, lRecurse, lCaseSensitive, lAscendingOrder, nNodePosition)

   LOCAL nIndex, nControlHandle, nItemHandle

   nIndex          := GetControlIndex   ( cTreeName, cFormName )
   nControlHandle  := GetControlHandle  ( cTreeName, cFormName )

   IF ValType (nItem) == "U"
      nItemHandle := TreeView_GetRoot ( nControlHandle )
   ELSE
      nItemHandle := TreeItemGetHandle ( cTreeName, cFormName , nItem )
   ENDIF

   DEFAULT lRecurse        TO .T.
   DEFAULT lCaseSensitive  TO .F.
   DEFAULT lAscendingOrder TO .T.
   DEFAULT nNodePosition   TO TREESORTNODE_MIX

   TreeView_SortChildrenRecursiveCB (nControlHandle, nItemHandle, lRecurse, lCaseSensitive, lAscendingOrder, nNodePosition)

   RETURN

FUNCTION TreeSetTextColor ( ControlName , ParentForm , aColor )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )

   RETURN TreeView_SetTextColor ( nControlHandle , aColor )

FUNCTION TreeSetBackColor ( ControlName , ParentForm , aColor )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )

   RETURN TreeView_SetBkColor ( nControlHandle , aColor )

FUNCTION TreeSetLineColor ( ControlName , ParentForm , aColor )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )

   RETURN TreeView_SetLineColor ( nControlHandle , aColor )

#define TVIS_EXPANDED   32

FUNCTION TreeItemIsExpand ( ControlName , ParentForm , nItem )

   LOCAL nControlHandle := GetControlHandle  ( ControlName , ParentForm )
   LOCAL ItemHandle     := TreeItemGetHandle ( ControlName , ParentForm , nItem )
   LOCAL State          := TreeView_GetItemState (nControlHandle, ItemHandle, TVIS_EXPANDED)

   RETURN ( hb_bitAND (State, TVIS_EXPANDED) == TVIS_EXPANDED )

FUNCTION TreeItemIsExpand2 ( i , nItem )

   LOCAL nControlHandle := GetControlHandleByIndex ( i )
   LOCAL ItemHandle     := TreeItemGetHandle2 ( i , nItem )
   LOCAL State          := TreeView_GetItemState (nControlHandle, ItemHandle, TVIS_EXPANDED)

   RETURN ( hb_bitAND (State, TVIS_EXPANDED) == TVIS_EXPANDED )

FUNCTION _DoTreeCustomDraw ( i , lParam )

   LOCAL DefaultBackColor := RGB (255, 255, 255)   // WHITE
   LOCAL DefaultForeColor := RGB (  0,   0,   0)   // BLACK
   LOCAL BackColor  :=  _HMG_SYSDATA [40] [i] [4]
   LOCAL FontColor  :=  _HMG_SYSDATA [40] [i] [5]
   LOCAL DynamicBackColor := _HMG_SYSDATA [40] [i] [1]
   LOCAL DynamicForeColor := _HMG_SYSDATA [40] [i] [2]
   LOCAL nRGB_BackColor, nRGB_ForeColor, aRGB
   LOCAL hFont

   IF ValType (BackColor) == "A"
      DEFAULTBackColor := RGB (BackColor[1], BackColor[2], BackColor[3])
   ENDIF

   IF ValType (FontColor) == "A"
      DEFAULTForeColor := RGB (FontColor[1], FontColor[2], FontColor[3])
   ENDIF

   nRGB_BackColor := DefaultBackColor
   nRGB_ForeColor := DefaultForeColor

   IF ValType (DynamicBackColor) == "B"
      aRGB := EVAL (DynamicBackColor)
      IF ValType (aRGB) == "A"
         nRGB_BackColor := RGB (aRGB[1], aRGB[2], aRGB[3])
      ENDIF
   ENDIF

   IF ValType (DynamicForeColor) == "B"
      aRGB := EVAL (DynamicForeColor)
      IF ValType (aRGB) == "A"
         nRGB_ForeColor := RGB (aRGB[1], aRGB[2], aRGB[3])
      ENDIF
   ENDIF

   hFont := _TreeCustomDrawFont ( i, lParam )

   RETURN TREE_SETBCFC (lParam , nRGB_BackColor, nRGB_ForeColor, hFont)

FUNCTION _TreeCustomDrawFont ( i, lParam )

   LOCAL cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeOut
   LOCAL hFontDynamic
   LOCAL DefaultFontHandle := _HMG_SYSDATA [36] [i]
   LOCAL DynamicFont       := _HMG_SYSDATA [40] [i] [3]
   LOCAL DynamicData

   IF ValType (DynamicFont) == "B"
      DYNAMICData := EVAL (DynamicFont)
      IF ValType (DynamicData) == "A"
         IF HMG_LEN (DynamicData) < 6
            ASIZE (DynamicData, 6 )   // { cFontName, nFontSize, [ lBold, lItalic, lUnderline, lStrikeOut ] }
         ENDIF

         IF ValType (DynamicData [1]) == "C" .AND. .NOT. EMPTY(DynamicData [1]) .AND. ValType (DynamicData [2]) == "N" .AND. DynamicData [2] > 0
            cFontName  := DynamicData [1]
            nFontSize  := DynamicData [2]
            lBold      := DynamicData [3]
            lItalic    := DynamicData [4]
            lUnderline := DynamicData [5]
            lStrikeOut := DynamicData [6]

            hFontDynamic := _HMG_SYSDATA [40] [i] [6]
            IF hFontDynamic <> 0
               DELETEObject (hFontDynamic)
            ENDIF

            hFontDynamic := HMG_CreateFont (TreeView_CustomDraw_GetHDC (lParam), cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeOut )
            _HMG_SYSDATA [40] [i] [6] := hFontDynamic

            RETURN hFontDynamic   // <=== return new handle
         ENDIF

      ENDIF
   ENDIF

   RETURN DefaultFontHandle   // <=== return default handle
