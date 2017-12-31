/*
 * $Id: h_grid.prg $
 */
/*
 * ooHG source code:
 * Grid, GridMulti, GridByCell and GridControl controls
 *
 * Copyright 2005-2017 Vicente Guerra <vicente@guerra.com.mx>
 * https://oohg.github.io/
 *
 * Portions of this project are based upon Harbour MiniGUI library.
 * Copyright 2002-2005 Roberto Lopez <roblez@ciudad.com.ar>
 *
 * Portions of this project are based upon Harbour GUI framework for Win32.
 * Copyright 2001 Alexander S. Kresin <alex@belacy.belgorod.su>
 * Copyright 2001 Antonio Linares <alinares@fivetech.com>
 *
 * Portions of this project are based upon Harbour Project.
 * Copyright 1999-2017, https://harbour.github.io/
 */
/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file LICENSE.txt. If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1335,USA (or download from http://www.gnu.org/licenses/).
 *
 * As a special exception, the ooHG Project gives permission for
 * additional uses of the text contained in its release of ooHG.
 *
 * The exception is that, if you link the ooHG libraries with other
 * files to produce an executable, this does not by itself cause the
 * resulting executable to be covered by the GNU General Public License.
 * Your use of that executable is in no way restricted on account of
 * linking the ooHG library code into it.
 *
 * This exception does not however invalidate any other reasons why
 * the executable file might be covered by the GNU General Public License.
 *
 * This exception applies only to the code released by the ooHG
 * Project under the name ooHG. If you copy code from other
 * ooHG Project or Free Software Foundation releases into a copy of
 * ooHG, as the General Public License permits, the exception does
 * not apply to the code that you add in this way. To avoid misleading
 * anyone as to the status of such modified files, you must delete
 * this exception notice from them.
 *
 * If you write modifications of your own for ooHG, it is your choice
 * whether to permit this exception to apply to your modifications.
 * If you do not wish that, delete this exception notice.
 */


#include "oohg.ch"
#include "hbclass.ch"
#include "i_windefs.ch"

CLASS TGrid FROM TControl

   DATA aEditControls             INIT Nil
   DATA aEditKeys                 INIT Nil
   DATA aHeadClick                INIT Nil
   DATA aHeaderImage              INIT {}
   DATA aHeaderImageAlign         INIT {}
   DATA aHeaders                  INIT {}
   DATA aHiddenCols               INIT {}
   DATA aJust                     INIT Nil
   DATA AllowAppend               INIT .F.
   DATA AllowChangeSize           INIT .T.
   DATA AllowDelete               INIT .F.
   DATA AllowEdit                 INIT .F.
   DATA AllowMoveColumn           INIT .T.
   DATA aSelectedColors           INIT {}
   DATA aWhen                     INIT {}
   DATA aWidths                   INIT {}
   DATA bAfterColMove             INIT Nil
   DATA bAfterColSize             INIT Nil
   DATA bBeforeAutofit            INIT Nil
   DATA bBeforeColMove            INIT Nil
   DATA bBeforeColSize            INIT Nil
   DATA bCompareItems             INIT Nil
   DATA bDelWhen                  INIT Nil
   DATA bEditCellValue            INIT Nil
   DATA bHeadRClick               INIT Nil
   DATA bOnEnter                  INIT Nil
   DATA bPosition                 INIT 0
   DATA cEditKey                  INIT "F2"
   DATA ClickOnCheckbox           INIT .T.
   DATA cRowEditTitle             INIT Nil
   DATA cText                     INIT ""
   DATA DelMsg                    INIT Nil
   DATA DynamicBackColor          INIT {}
   DATA DynamicForeColor          INIT {}
   DATA EditControls              INIT Nil
   DATA FullMove                  INIT .F.
   DATA GridBackColor             INIT {}
   DATA GridForeColor             INIT {}
   DATA GridSelectedColors        INIT {}
   DATA HeaderFontHandle          INIT 0
   DATA HeaderImageList           INIT 0
   DATA ImageListColor            INIT CLR_DEFAULT
   DATA ImageListFlags            INIT LR_LOADTRANSPARENT + LR_DEFAULTCOLOR + LR_LOADMAP3DCOLORS
   DATA InPlace                   INIT .F.
   DATA lAppendMode               INIT .F.
   DATA lAppendOnAltA             INIT .F.
   DATA lAtFirstCol               INIT .T.
   DATA lBeginTrack               INIT .F.
   DATA lButtons                  INIT .F.
   DATA lCalledFromClass          INIT .F. PROTECTED
   DATA lChangeBeforeEdit         INIT .F.
   DATA lCheckBoxes               INIT .F.
   DATA lDividerDblclick          INIT .F.
   DATA lEditMode                 INIT .F.
   DATA lEndTrack                 INIT .F.
   DATA lExtendDblClick           INIT .F.
   DATA lFixedControls            INIT .F.
   DATA lFocusRect                INIT .T.
   DATA lKeysLikeClipper          INIT .F.
   DATA lLikeExcel                INIT .F.
   DATA lKeysOn                   INIT .T.
   DATA lNested                   INIT .F.
   DATA lNestedEdit               INIT .F.
   DATA lNoDelMsg                 INIT .F.
   DATA lNoGrid                   INIT .F.
   DATA lNoModal                  INIT .F.
   DATA lNoneUnsels               INIT .F.
   DATA lPLM                      INIT .F.
   DATA lScrollBarUsesClientArea  INIT .F.
   DATA lShowItemAtTop            INIT .F.
   DATA lSilent                   INIT .F.
   DATA lTracking                 INIT .F.
   DATA nColPos                   INIT 0 PROTECTED
   DATA nDelayedClick             INIT { 0, 0, 0, Nil } PROTECTED
   DATA nEditRow                  INIT 0 PROTECTED
   DATA nHeight                   INIT 120
   DATA nRowPos                   INIT 0 PROTECTED
   DATA nVisibleItems             INIT 0
   DATA nWidth                    INIT 240
   DATA OnAbortEdit               INIT Nil
   DATA OnAppend                  INIT Nil
   DATA OnBeforeEditCell          INIT Nil
   DATA OnCheckChange             INIT Nil
   DATA onDelete                  INIT Nil
   DATA OnDispInfo                INIT Nil
   DATA OnEditCell                INIT Nil
   DATA OnEditCellEnd             INIT Nil
   DATA OnInsert                  INIT Nil
   DATA Picture                   INIT Nil
   DATA RClickOnCheckbox          INIT .T.
   DATA ReadOnly                  INIT Nil
   DATA SearchCol                 INIT 0
   DATA SearchLapse               INIT 1000
   DATA SearchWrap                INIT .T.
   DATA SetImageListCommand       INIT LVM_SETIMAGELIST
   DATA SetImageListWParam        INIT LVSIL_SMALL
   DATA Type                      INIT "GRID" READONLY
   DATA uIniTime                  INIT 0
   DATA Valid                     INIT Nil
   DATA ValidMessages             INIT Nil

   METHOD AddBitMap
   METHOD AddColumn
   METHOD AddItem
   METHOD AdjustResize
   METHOD Append                  SETGET
   METHOD AppendItem
   METHOD BackColor               SETGET
   METHOD Cell
   METHOD CellCaption             BLOCK { | Self, nRow, nCol, uValue | CellRawValue( ::hWnd, nRow, nCol, 1, uValue ) }
   METHOD CellImage               BLOCK { | Self, nRow, nCol, uValue | CellRawValue( ::hWnd, nRow, nCol, 2, uValue ) }
   METHOD CheckItem               SETGET
   METHOD ColumnAutoFit
   METHOD ColumnAutoFitH
   METHOD ColumnBetterAutoFit
   METHOD ColumnCount
   METHOD ColumnHide
   METHOD ColumnOrder             SETGET
   METHOD ColumnsAutoFit
   METHOD ColumnsAutoFitH
   METHOD ColumnsBetterAutoFit
   METHOD ColumnShow
   METHOD ColumnWidth
   METHOD CompareItems
   METHOD CountPerPage            BLOCK { | Self | ListViewGetCountPerPage( ::hWnd ) }
   METHOD Define
   METHOD Define2
   METHOD Define4
   METHOD DeleteAllItems          BLOCK { | Self | ListViewReset( ::hWnd ), ::GridForeColor := Nil, ::GridBackColor := Nil, ::DoChange() }
   METHOD DeleteColumn
   METHOD DeleteItem
   METHOD Down
   METHOD EditAllCells
   METHOD EditCell
   METHOD EditCell2
   METHOD EditGrid
   METHOD EditItem
   METHOD EditItem2
   METHOD Events
   METHOD Events_Enter
   METHOD Events_Notify
   METHOD FirstColInOrder
   METHOD FirstSelectedItem       BLOCK { | Self | ListView_GetFirstItem( ::hWnd ) }
   METHOD FirstVisibleColumn
   METHOD FirstVisibleItem
   METHOD FixControls             SETGET
   METHOD FontColor               SETGET
   METHOD GoBottom
   METHOD GoTop
   METHOD Header
   METHOD HeaderHeight
   METHOD HeaderImage
   METHOD HeaderImageAlign
   METHOD HeaderSetFont
   METHOD InsertBlank
   METHOD InsertItem
   METHOD IsColumnReadOnly
   METHOD IsColumnWhen
   METHOD Item
   METHOD ItemCount               BLOCK { | Self | ListViewGetItemCount( ::hWnd ) }
   METHOD ItemHeight
   METHOD Justify
   METHOD LastColInOrder
   METHOD LastVisibleColumn
   METHOD Left
   METHOD LoadHeaderImages
   METHOD NextColInOrder
   METHOD OnEnter                 SETGET
   METHOD PageDown
   METHOD PageUp
   METHOD PriorColInOrder
   METHOD Release
   METHOD Right
   METHOD ScrollToCol
   METHOD ScrollToLeft
   METHOD ScrollToNext
   METHOD ScrollToPrior
   METHOD ScrollToRight
   METHOD SetColumn
   METHOD SetControlValue         BLOCK { |Self, nRow, nCol| Empty( nCol ), ::Value := nRow }
   METHOD SetItemColor
   METHOD SetRangeColor
   METHOD SetSelectedColors
   METHOD SortColumn
   METHOD SortItems
   METHOD ToExcel
   METHOD ToOpenOffice
   METHOD Up
   METHOD Value                   SETGET

   MESSAGE End                    METHOD GoBottom
   MESSAGE Home                   METHOD GoTop
   MESSAGE PanToLeft              METHOD ScrollToPrior
   MESSAGE PanToRight             METHOD ScrollToNext

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, ;
               aRows, value, fontname, fontsize, tooltip, change, dblclick, ;
               aHeadClick, gotfocus, lostfocus, nogrid, aImage, aJust, ;
               break, HelpId, bold, italic, underline, strikeout, ownerdata, ;
               ondispinfo, itemcount, editable, backcolor, fontcolor, ;
               dynamicbackcolor, dynamicforecolor, aPicture, lRtl, inplace, ;
               editcontrols, readonly, valid, validmessages, editcell, ;
               aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
               onenter, aHeaderImage, aHeaderImageAlign, FullMove, ;
               aSelectedColors, aEditKeys, lCheckBoxes, oncheck, lDblBffr, ;
               lFocusRect, lPLM, lFixedCols, abortedit, click, lFixedWidths, ;
               bBeforeColMove, bAfterColMove, bBeforeColSize, bAfterColSize, ;
               bBeforeAutofit, lLikeExcel, lButtons, AllowDelete, onDelete, ;
               bDelWhen, DelMsg, lNoDelMsg, AllowAppend, onappend, lNoModal, ;
               lFixedCtrls, bHeadRClick, lClickOnCheckbox, lRClickOnCheckbox, ;
               lExtDbl, lSilent, lAltA, lNoShowAlways, lNone, lCBE, onrclick, ;
               oninsert, editend, lAtFirst, bbeforeditcell, bEditCellValue, klc ) CLASS TGrid

   ::Define2( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, aRows, ;
              value, fontname, fontsize, tooltip, aHeadClick, nogrid, ;
              aImage, aJust, break, HelpId, bold, italic, underline, ;
              strikeout, ownerdata, itemcount, editable, backcolor, ;
              fontcolor, dynamicbackcolor, dynamicforecolor, aPicture, lRtl, ;
              LVS_SINGLESEL, inplace, editcontrols, readonly, valid, validmessages, ;
              aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
              aHeaderImage, aHeaderImageAlign, FullMove, aSelectedColors, ;
              aEditKeys, lCheckBoxes, lDblBffr, lFocusRect, lPLM, ;
              lFixedCols, lFixedWidths, lLikeExcel, lButtons, AllowDelete, ;
              DelMsg, lNoDelMsg, AllowAppend, lNoModal, lFixedCtrls, ;
              lClickOnCheckbox, lRClickOnCheckbox, lExtDbl, lSilent, lAltA, ;
              lNoShowAlways, lNone, lCBE, lAtFirst, klc )

   // Must be set after control is initialized
   ::Define4( change, dblclick, gotfocus, lostfocus, ondispinfo, editcell, ;
              onenter, oncheck, abortedit, click, bbeforecolmove, baftercolmove, ;
              bbeforecolsize, baftercolsize, bbeforeautofit, ondelete, ;
              bdelwhen, onappend, bheadrclick, onrclick, oninsert, editend, ;
              bbeforeditcell, bEditCellValue )

   Return Self

METHOD Define2( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, aRows, ;
                value, fontname, fontsize, tooltip, aHeadClick, nogrid, ;
                aImage, aJust, break, HelpId, bold, italic, underline, ;
                strikeout, ownerdata, itemcount, editable, backcolor, ;
                fontcolor, dynamicbackcolor, dynamicforecolor, aPicture, lRtl, ;
                nStyle, inplace, editcontrols, readonly, valid, validmessages, ;
                aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
                aHeaderImage, aHeaderImageAlign, FullMove, aSelectedColors, ;
                aEditKeys, lCheckBoxes, lDblBffr, lFocusRect, lPLM, ;
                lFixedCols, lFixedWidths, lLikeExcel, lButtons, AllowDelete, ;
                DelMsg, lNoDelMsg, AllowAppend, lNoModal, lFixedCtrls, ;
                lClickOnCheckbox, lRClickOnCheckbox, lExtDbl, lSilent, lAltA, ;
                lNoShowAlways, lNone, lCBE, lAtFirst, klc ) CLASS TGrid

   Local ControlHandle, aImageList, i

   ::SetForm( ControlName, ParentForm, FontName, FontSize, FontColor, BackColor, .t., lRtl )

   ASSIGN ::aWidths  VALUE aWidths  TYPE "A"
   ASSIGN ::aHeaders VALUE aHeaders TYPE "A"

   If Len( ::aHeaders ) != Len( ::aWidths )
      MsgOOHGError( "Grid: HEADERS/WIDTHS array size mismatch. Program terminated." )
   EndIf
   If HB_IsArray( aRows )
      If AScan( aRows, { |a| ! HB_IsArray( a ) .OR. Len( a ) != Len( aHeaders ) } ) > 0
         MsgOOHGError( "Grid: ITEMS length mismatch. Program terminated." )
      EndIf
   Else
      aRows := {}
   EndIf

   ASSIGN ::nWidth  VALUE w TYPE "N"
   ASSIGN ::nHeight VALUE h TYPE "N"
   ASSIGN ::nRow    VALUE y TYPE "N"
   ASSIGN ::nCol    VALUE x TYPE "N"

   If HB_IsArray( aHeadClick )
      ::aHeadClick := aHeadClick
      ASize( ::aHeadClick, Len( ::aHeaders ) )
   Else
      ::aHeadClick := Array( Len( ::aHeaders ) )
      If HB_IsBlock( aHeadClick )
         AFill( ::aHeadClick, aHeadClick )
      EndIf
   EndIf

   If HB_IsLogical( lFixedCols )
      ::AllowMoveColumn := ! lFixedCols
   EndIf

   If HB_IsLogical( lFixedWidths )
      ::AllowChangeSize := ! lFixedWidths
   EndIf

   ASSIGN ::aJust             VALUE aJust             TYPE "A"
   ASSIGN ::Picture           VALUE aPicture          TYPE "A"
   ASSIGN ownerdata           VALUE ownerdata         TYPE "L" DEFAULT .F.
   ASSIGN ::lNoGrid           VALUE nogrid            TYPE "L"
   ASSIGN ::lCheckBoxes       VALUE lCheckBoxes       TYPE "L"
   ASSIGN ::lFocusRect        VALUE lFocusRect        TYPE "L"
   ASSIGN ::lPLM              VALUE lPLM              TYPE "L"
   ASSIGN ::lLikeExcel        VALUE lLikeExcel        TYPE "L"
   ASSIGN ::lButtons          VALUE lButtons          TYPE "L"
   ASSIGN ::AllowEdit         VALUE editable          TYPE "L"
   ASSIGN ::AllowDelete       VALUE AllowDelete       TYPE "L"
   ASSIGN ::AllowAppend       VALUE AllowAppend       TYPE "L"
   ASSIGN ::lNoDelMsg         VALUE lNoDelMsg         TYPE "L"
   ASSIGN ::DelMsg            VALUE DelMsg            TYPE "C"
   ASSIGN ::lNoModal          VALUE lNoModal          TYPE "L"
   ASSIGN ::ClickOnCheckbox   VALUE lClickOnCheckbox  TYPE "L"
   ASSIGN ::RClickOnCheckbox  VALUE lRClickOnCheckbox TYPE "L"
   ASSIGN ::lExtendDblClick   VALUE lExtDbl           TYPE "L"
   ASSIGN ::lSilent           VALUE lSilent           TYPE "L"
   ASSIGN ::lAppendOnAltA     VALUE lAltA             TYPE "L"
   ASSIGN ::lNoneUnsels       VALUE lNone             TYPE "L"
   ASSIGN ::lChangeBeforeEdit VALUE lCBE              TYPE "L"
   ASSIGN ::lAtFirstCol       VALUE lAtFirst          TYPE "L"
   ASSIGN ::lKeysLikeClipper  VALUE klc               TYPE "L"

   /*
    * This must be placed before calling ::Register because when the
    * control is an XBrowse, ::Register will call ::ColumnBlock and
    * this method needs ::EditControls
    */
   ::EditControls := editcontrols

   If ::lCheckBoxes .AND. ::lPLM
      MsgOOHGError( "CHECKBOXES and PAINTLEFTMARGIN clauses can't be used simultaneously. Program terminated." )
   EndIf

   nStyle := ::InitStyle( nStyle,, lInvisible, lNoTabStop, lDisabled ) + ;
             If( HB_IsLogical( lHasHeaders ) .AND. ! lHasHeaders, LVS_NOCOLUMNHEADER, 0 ) + ;
             If( HB_IsLogical( lNoShowAlways ) .AND. ! lNoShowAlways, LVS_SHOWSELALWAYS, 0 )

   If ! HB_IsArray( ::aJust )
      ::aJust := AFill( Array( Len( ::aHeaders ) ), 0 )
   Else
      ASize( ::aJust, Len( ::aHeaders ) )
      AEval( ::aJust, { |x,i| ::aJust[ i ] := If( ! HB_IsNumeric( x ), 0, x ) } )
   EndIf

   If ! HB_IsArray( ::Picture )
      ::Picture := Array( Len( ::aHeaders ) )
   Else
      ASize( ::Picture, Len( ::aHeaders ) )
   EndIf
   AEval( ::Picture, { |x,i| ::Picture[ i ] := If( ( ValType( x ) $ "CM" .AND. ! Empty( x ) ) .OR. HB_IsLogical( x ), x, Nil ) } )

   ::SetSplitBoxInfo( Break )
   ControlHandle := InitListView( ::ContainerhWnd, 0, ::ContainerCol, ::ContainerRow, ::Width, ::Height, '', 0, If( ::lNoGrid, 0, 1 ), ownerdata, itemcount, nStyle, ::lRtl, ::lCheckBoxes, OSisWinXPorLater() .AND. lDblBffr )

   If HB_IsArray( aImage )
      // Can't use ::AddBitMap( aImage ) because control is not registered yet
      aImageList := ImageList_Init( aImage, ::ImageListColor, ::ImageListFlags )
      If ValidHandler( aImageList[ 1 ] )
         SendMessage( ControlHandle, ::SetImageListCommand, ::SetImageListWParam, aImageList[ 1 ] )
         ::ImageList := aImageList[ 1 ]
         i := AScan( ::Picture, .T. )
         If i == 0
            ::Picture[ 1 ] := .T.
            ::aWidths[ 1 ] := Max( ::aWidths[ 1 ], aImageList[ 2 ] + If( ::lCheckBoxes, GetStateListWidth( ControlHandle ) + 4, 4 ) ) // Ensure there's enough room for bitmap plus checkboxes
         Else
            ::aWidths[ i ] := Max( ::aWidths[ i ], aImageList[ 2 ] )  // Ensure there's enough room for bitmap
         EndIf
      EndIf
   ElseIf ::lCheckBoxes
      ::aWidths[ 1 ] := Max( ::aWidths[ 1 ], GetStateListWidth( ControlHandle ) + 4 ) // Set Column 1 width to checkboxes width
   EndIf

   InitListViewColumns( ControlHandle, ::aHeaders, ::aWidths, ::aJust )

   ::Register( ControlHandle, ControlName, HelpId, , ToolTip )
   ::SetFont( , , bold, italic, underline, strikeout )

   ::FontColor := ::Super:FontColor
   ::BackColor := ::Super:BackColor

   ::DynamicForeColor := dynamicforecolor
   ::DynamicBackColor := dynamicbackcolor
   ::Readonly := readonly
   ::Valid := valid
   ::ValidMessages := validmessages
   ::aEditKeys := aEditKeys
   ::aWhen := aWhenFields
   ASSIGN ::InPlace   VALUE inplace  TYPE "L"
   ASSIGN ::FullMove  VALUE FullMove TYPE "L"

   ASSIGN lFixedCtrls VALUE lFixedCtrls TYPE "L" DEFAULT _OOHG_GridFixedControls
   ::FixControls( lFixedCtrls )

   // Load images alignments
   // This should come before than 'Load header images'
   ::aHeaderImageAlign := AFill( Array( Len( ::aHeaders ) ), HEADER_IMG_AT_LEFT )

   If HB_IsArray( aHeaderImageAlign )
      For i := 1 To Len( aHeaderImageAlign )
         If HB_IsNumeric( aHeaderImageAlign[ i ] ) .AND. aHeaderImageAlign[ i ] == HEADER_IMG_AT_RIGHT
           ::aHeaderImageAlign[ i ] := HEADER_IMG_AT_RIGHT
         EndIf
      Next i
   EndIf

   // Load header images
   // This should come after 'Load images alignments'
   ::LoadHeaderImages( aHeaderImage )

   If ValidHandler( ::HeaderImageList )
      // Associate the imagelist with the listview's header control
      SetHeaderImageList( ControlHandle, ::HeaderImageList )

      // Set images aligments
      For i := 1 To Len( ::aHeaders )
        ::HeaderImage( i, ::aHeaderImage[ i ] )
        ::HeaderImageAlign( i, ::aHeaderImageAlign[ i ] )
      Next i
   EndIf

   // Load rows
   AEval( aRows, { |u| ::AddItem( u ) } )

   If ! HB_IsArray( aSelectedColors )
      aSelectedColors := {}
   EndIf
   ::SetSelectedColors( aSelectedColors, .F. )

   ::Value := value

   Return Self

METHOD Define4( change, dblclick, gotfocus, lostfocus, ondispinfo, editcell, ;
                onenter, oncheck, abortedit, click, bbeforecolmove, baftercolmove, ;
                bbeforecolsize, baftercolsize, bbeforeautofit, ondelete, ;
                bDelWhen, onappend, bheadrclick, onrclick, oninsert, editend, ;
                bbeforeditcell, bEditCellValue ) CLASS TGrid

   // Must be set after control is initialized
   ASSIGN ::OnChange         VALUE change         TYPE "B"
   ASSIGN ::OnDblClick       VALUE dblclick       TYPE "B"
   ASSIGN ::OnGotFocus       VALUE gotfocus       TYPE "B"
   ASSIGN ::OnLostFocus      VALUE lostfocus      TYPE "B"
   ASSIGN ::OnDispInfo       VALUE ondispinfo     TYPE "B"
   ASSIGN ::OnEditCell       VALUE editcell       TYPE "B"
   ASSIGN ::OnEnter          VALUE onenter        TYPE "B"
   ASSIGN ::OnCheckChange    VALUE oncheck        TYPE "B"
   ASSIGN ::OnAbortEdit      VALUE abortedit      TYPE "B"
   ASSIGN ::OnClick          VALUE click          TYPE "B"
   ASSIGN ::bBeforeColMove   VALUE bbeforecolmove TYPE "B"
   ASSIGN ::bAfterColMove    VALUE baftercolmove  TYPE "B"
   ASSIGN ::bBeforeColSize   VALUE bbeforecolsize TYPE "B"
   ASSIGN ::bAfterColSize    VALUE baftercolsize  TYPE "B"
   ASSIGN ::bBeforeAutofit   VALUE bbeforeautofit TYPE "B"
   ASSIGN ::OnDelete         VALUE ondelete       TYPE "B"
   ASSIGN ::bDelWhen         VALUE bdelwhen       TYPE "B"
   ASSIGN ::OnAppend         VALUE onappend       TYPE "B"
   ASSIGN ::bHeadRClick      VALUE bheadrclick    TYPE "B"
   ASSIGN ::OnRClick         VALUE onrclick       TYPE "B"
   ASSIGN ::OnInsert         VALUE oninsert       TYPE "B"
   ASSIGN ::OnEditCellEnd    VALUE editend        TYPE "B"
   ASSIGN ::OnBeforeEditCell VALUE bbeforeditcell TYPE "B"
   ASSIGN ::bEditCellValue   VALUE bEditCellValue TYPE "B"

   Return Self

METHOD AddBitMap( uImage ) CLASS TGrid

   Local aImageList, nPos, nCount, i

   If ValidHandler( ::ImageList )
      nCount := ImageList_GetImageCount( ::ImageList )
      If HB_IsArray( uImage )
         nPos := ImageList_Add( ::ImageList, uImage[ 1 ], ::ImageListFlags, ::ImageListColor )
         AEval( uImage, { |c| ImageList_Add( ::ImageList, c, ::ImageListFlags, ::ImageListColor ) }, 2 )
      Else
         nPos := ImageList_Add( ::ImageList, uImage, ::ImageListFlags, ::ImageListColor )
      EndIf
      If nCount == ImageList_GetImageCount( ::ImageList )
         nPos := 0
      EndIf
      SendMessage( ::hWnd, ::SetImageListCommand, ::SetImageListWParam, ::ImageList )
   Else
      If HB_IsArray( uImage )
         aImageList := ImageList_Init( uImage, ::ImageListColor, ::ImageListFlags )
      Else
         aImageList := ImageList_Init( { uImage }, ::ImageListColor, ::ImageListFlags )
      EndIf
      If ValidHandler( aImageList[ 1 ] )
         ::ImageList := aImageList[ 1 ]
         nPos := 1
         SendMessage( ::hWnd, ::SetImageListCommand, ::SetImageListWParam, aImageList[ 1 ] )
         i := AScan( ::Picture, .T. )
         If i == 0
            ::Picture[ 1 ] := .T.
            ::aWidths[ 1 ] := Max( ::ColumnWidth( 1 ), aImageList[ 2 ] + If( ::lCheckBoxes, GetStateListWidth( ::hWnd ) + 4, 4 ) ) // Ensure there's enough room for bitmap plus checkboxes
         Else
            ::aWidths[ i ] := Max( ::ColumnWidth( i ), aImageList[ 2 ] )  // Ensure there's enough room for bitmap
         EndIf
      Else
         nPos := 0
      EndIf
   Endif

   Return nPos

METHOD FirstVisibleItem CLASS TGrid

   Local nRet

   If ::ItemCount > 0
      nRet := ListView_GetTopIndex( ::hWnd )
      If nRet < 1 .OR. nRet > ::ItemCount
         nRet := 0
      EndIf
   Else
      nRet := 0
   EndIf

   Return nRet

METHOD FirstVisibleColumn( lStart ) CLASS TGrid

   Local aColumnOrder, nLen, i, r, nRet := 0, lEmpty := .F., nClientWidth, nScrollWidth

   ASSIGN lStart VALUE lStart TYPE "L" DEFAULT .F.

   If ::ItemCount < 1
      lEmpty := .T.
      InsertListViewItem( ::hWnd, Array( Len( ::aHeaders ) ), 1 )
   EndIf

   If lStart
      // We are looking for the leftmost column whose left side is visible.
      // To check we need the width of the grid's client area minus the width of the scrollbar if one is present.
      r := { 0, 0, 0, 0 }                                        // left, top, right, bottom
      GetClientRect( ::hWnd, r )
      nClientWidth := r[ 3 ] - r[ 1 ]
      If ::lScrollBarUsesClientArea .AND. ::ItemCount > ::CountPerPage
         nScrollWidth := GetVScrollBarWidth()
      Else
         nScrollWidth := 0
      EndIf
   EndIf

   aColumnOrder := ::ColumnOrder
   nLen := Len( aColumnOrder )
   i := 1
   Do While i <= nLen
      If AScan( ::aHiddenCols, aColumnOrder[ i ] ) == 0
         // get the column's rect
         r := ListView_GetSubitemRect( ::hWnd, 0, aColumnOrder[ i ] - 1 )     // top, left, width, height
         If lStart
            // check if the left side is inside the client area
            If r[ 2 ] >= 0 .AND. r[ 2 ] < nClientWidth - nScrollWidth
              nRet := aColumnOrder[ i ]
              Exit
            EndIf
         Else
            // We are looking for the leftmost column
            If r[ 2 ] + r[ 3 ] - 1 >= 0
               nRet := aColumnOrder[ i ]
               Exit
            EndIf
         EndIf
      EndIf
      i ++
   EndDo

   If lEmpty
      ListViewDeleteString( ::hWnd, 1 )
   EndIf

   Return nRet

METHOD LastVisibleColumn( lEnd ) CLASS TGrid

   Local aColumnOrder, nLen, i, r, nRet := 0, lEmpty := .F., nClientWidth, nScrollWidth

   ASSIGN lEnd VALUE lEnd TYPE "L" DEFAULT .F.

   If ::ItemCount < 1
      lEmpty := .T.
      InsertListViewItem( ::hWnd, Array( Len( ::aHeaders ) ), 1 )
   EndIf

   // To check we need the width of the grid's client area minus the width of the scrollbar if one is present.
   r := { 0, 0, 0, 0 }                                        // left, top, right, bottom
   GetClientRect( ::hWnd, r )
   nClientWidth := r[ 3 ] - r[ 1 ]
   If ::lScrollBarUsesClientArea .AND. ::ItemCount >  ::CountPerPage
      nScrollWidth := GetVScrollBarWidth()
   Else
      nScrollWidth := 0
   EndIf

   aColumnOrder := ::ColumnOrder
   nLen := Len( aColumnOrder )
   i := nLen
   Do While i >= 1
      If AScan( ::aHiddenCols, aColumnOrder[ i ] ) == 0
         // get the column's rect
         r := ListView_GetSubitemRect( ::hWnd, 0, aColumnOrder[ i ] - 1 )     // top, left, width, height
         If lEnd
            // check if the right side is inside the client area
            If r[ 2 ] + r[ 3 ] >= 0 .AND. r[ 2 ] + r[ 3 ] <= nClientWidth - nScrollWidth
              nRet := aColumnOrder[ i ]
              Exit
            EndIf
         Else
            // We are looking for the rightmost column
            If r[ 2 ] <= nClientWidth - nScrollWidth
               nRet := aColumnOrder[ i ]
               Exit
            EndIf
         EndIf
      EndIf
      i --
   EndDo

   If lEmpty
      ListViewDeleteString( ::hWnd, 1 )
   EndIf

   Return nRet

METHOD FixControls( lFix ) CLASS TGrid

   Local i

   If HB_IsLogical( lFix )
      If lFix
         ::aEditControls := Array( Len( ::aHeaders ) )
         For i := 1 To Len( ::aHeaders )
            ::aEditControls[ i ] := GetEditControlFromArray( Nil, ::EditControls, i, Self )
         Next i
         ::lFixedControls := .T.
      Else
         ::lFixedControls := .F.
      Endif
   EndIf

   Return ::lFixedControls

METHOD Append( lAppend ) CLASS TGrid

   If HB_IsLogical( lAppend )
      ::AllowAppend := lAppend
   EndIf

   Return ::AllowAppend

METHOD CheckItem( nItem, lChecked ) CLASS TGrid

   Local lRet, lOld

   If ::lCheckBoxes .AND. HB_IsNumeric( nItem )
      lOld := ListView_GetCheckState( ::hwnd, nItem )

      If HB_IsLogical( lChecked ) .AND. lChecked # lOld
         ListView_SetCheckState( ::hwnd, nItem, lChecked )

         lRet := ListView_GetCheckState( ::hwnd, nItem )

         If lRet # lOld
            ::DoEvent( ::OnCheckChange, "CHECKCHANGE", { nItem } )
         EndIf
      Else
         lRet := lOld
      EndIf
   Else
      lRet := .F.
   EndIf

   Return lRet

METHOD SetSelectedColors( aSelectedColors, lRedraw ) CLASS TGrid

   Local i, aColors[ 4 ]

   If HB_IsArray( aSelectedColors )
      aSelectedColors := AClone( aSelectedColors )
      ASize( aSelectedColors, 4 )

      // For text of selected row when grid has the focus
      If ! ValType( aSelectedColors[ 1 ] ) $ "ANB"
         aSelectedColors[ 1 ] := GetSysColor( COLOR_HIGHLIGHTTEXT )
      EndIf
      // For background of selected row when grid has the focus
      If ! ValType( aSelectedColors[ 2 ] ) $ "ANB"
         aSelectedColors[ 2 ] := GetSysColor( COLOR_HIGHLIGHT )
      EndIf
      // For text of selected row when grid doesn't has the focus
      If ! ValType( aSelectedColors[ 3 ] ) $ "ANB"
         aSelectedColors[ 3 ] := GetSysColor( COLOR_WINDOWTEXT )
      EndIf
      // For background of selected row when doesn't has the focus
      If ! ValType( aSelectedColors[ 4 ] ) $ "ANB"
         aSelectedColors[ 4 ] := GetSysColor( COLOR_3DFACE )
      EndIf

      ::aSelectedColors := aSelectedColors

      For i := 1 To 4
         aColors[ i ] := _OOHG_GetArrayItem( aSelectedColors, i )
      Next i

      ::GridSelectedColors := aColors

      If lRedraw
         RedrawWindow( ::hWnd )
      EndIf
   Else
      aSelectedColors := AClone( ::aSelectedColors )
   EndIf

   Return aSelectedColors

METHOD LoadHeaderImages( aNewHeaderImage ) CLASS TGrid

   Local i, nPos, nCount, aImageList, nImagesWidth, aHeaderImage, aImageName := {}

   // Clone the array in case aNewHeaderImage is the same as ::aHeaderImage
   If HB_IsArray( aNewHeaderImage )
      aHeaderImage := AClone( aNewHeaderImage )
   Else
      aHeaderImage := Nil
   EndIf

   // Destroy previous imagelist
   If ValidHandler( ::HeaderImageList )
      ImageList_Destroy( ::HeaderImageList )
   EndIf
   ::HeaderImageList := 0

   // Load images into imagelist
   ::aHeaderImage := AFill( Array( Len( ::aHeaders ) ), 0 )

   If HB_IsArray( aHeaderImage )
      For i := 1 To Len( aHeaderImage )
         If ValType( aHeaderImage[ i ] ) $ "CM" .AND. ! Empty( aHeaderImage[ i ] )
            If ValidHandler( ::HeaderImageList )
               nPos := AScan( aImageName, aHeaderImage[ i ] )
               If nPos > 0                                                 // Image already loaded, reuse it
                  ::aHeaderImage[ i ] := nPos
               Else
                  nCount := ImageList_GetImageCount( ::HeaderImageList )
                  nPos := ImageList_Add( ::HeaderImageList, aHeaderImage[ i ], ::ImageListFlags, ::ImageListColor )
                  If ImageList_GetImageCount( ::HeaderImageList ) == nCount
                     nPos := 0
                  EndIf

                  If nPos == 0                       // Image not added
                     aHeaderImage[ i ] := Nil
                  Else
                     AAdd( aImageName, aHeaderImage[ i ] )
                     ::aHeaderImage[ i ] := nPos
                     ::ColumnWidth( i, Max( ::ColumnWidth( i ), nImagesWidth ) )
                  EndIf
               EndIf
            Else
               aImageList := ImageList_Init( { aHeaderImage[ i ] }, ::ImageListColor, ::ImageListFlags )

               If ValidHandler( aImageList[ 1 ] )
                  ::HeaderImageList := aImageList[ 1 ]
                  AAdd( aImageName, aHeaderImage[ i ] )
                  ::aHeaderImage[ i ] := 1
                  nImagesWidth := aImageList[ 2 ] + 4
                  If i == 1
                     ::ColumnWidth( i, Max( ::ColumnWidth( i ), nImagesWidth + If( ::lCheckBoxes, GetStateListWidth( ::hWnd ), 0 ) ) )
                  Else
                     ::ColumnWidth( i, Max( ::ColumnWidth( i ), nImagesWidth ) )
                  EndIf
               Else
                  aHeaderImage[ i ] := Nil
               EndIf
            EndIf
         Else
            aHeaderImage[ i ] := Nil                 // Header has no image
         EndIf
      Next i
   EndIf

   If ValidHandler( ::HeaderImageList )
      // Associate the imagelist with the header control of the listview
      SetHeaderImageList( ::hWnd, ::HeaderImageList )

      // Set images aligments
      For i := 1 To Len( ::aHeaders )
        ::HeaderImage( i, ::aHeaderImage[ i ] )
        ::HeaderImageAlign( i, ::aHeaderImageAlign[ i ] )
      Next i
   Else
      // Deassociate the imagelist
      SetHeaderImageList( ::hWnd, 0 )
   EndIf

   Return Self

METHOD OnEnter( bEnter ) CLASS TGrid

   Local bRet

   If HB_IsBlock( bEnter )
      If _OOHG_SameEnterDblClick
         ::OnDblClick := bEnter
      Else
         ::bOnEnter := bEnter
      EndIf
      bRet := bEnter
   Else
      bRet := If( _OOHG_SameEnterDblClick, ::OnDblClick, ::bOnEnter )
   EndIf

   Return bRet

METHOD AppendItem( lAppend ) CLASS TGrid

   Local lRet := .F.

   ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT .F.
   IF ( ::AllowAppend .OR. lAppend ).AND. ! ::lNestedEdit
      ::lNestedEdit := .T.
      ::cText := ""
      If ::FirstVisibleColumn # 0
         ::lAppendMode := .T.
         ::InsertBlank( ::ItemCount + 1 )
         ::SetControlValue( ::ItemCount )
         If ::FullMove
            lRet := ::EditGrid()
         ElseIf ::InPlace
            lRet := ::EditAllCells()
         Else
            lRet := ::EditItem()
         EndIf
         ::lAppendMode := .F.
      EndIf
      ::lNestedEdit := .F.
   EndIf

   Return lRet

METHOD EditGrid( nRow, nCol, lAppend, lOneRow, lChange ) CLASS TGrid

   Local lRet, lSomethingEdited, nNextCol

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf

   ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT .F.

   If ! HB_IsNumeric( nCol )
      If ::lAppendMode .OR. lAppend .OR. ::lAtFirstCol
         nCol := ::FirstColInOrder
      Else
         nCol := ::FirstVisibleColumn
      EndIf
   EndIf
   If nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf

   If ::lAppendMode
      // Before calling ::EditGrid an empty item was added at ::ItemCount
      nRow := ::ItemCount
   ElseIf lAppend
      // Add new item, ignore ::AllowAppend
      ::lAppendMode := .T.
      ::InsertBlank( ::ItemCount + 1 )
      ::SetControlValue( ::ItemCount )
      nRow := ::ItemCount
   Else
      // Edit item nRow
      If ! HB_IsNumeric( nRow )
         nRow := Max( ::FirstSelectedItem, 1 )
      EndIf
      If nRow < 1 .OR. nRow > ::ItemCount
         Return .F.
      EndIf
      ASSIGN lChange VALUE lChange TYPE "L" DEFAULT ::lChangeBeforeEdit
      If lChange
         ::SetControlValue( nRow )
      EndIf
   EndIf

   ::nRowPos := nRow
   ::nColPos := nCol

   lSomethingEdited := .F.

   Do While ::nColPos >= 1 .AND. ::nColPos <= Len( ::aHeaders )
      _OOHG_ThisItemCellValue := ::Cell( ::nRowPos, ::nColPos )

      If ::IsColumnReadOnly( ::nColPos, ::nRowPos )
         // Read only column
      ElseIf ! ::IsColumnWhen( ::nColPos, ::nRowPos )
         // WHEN returned .F.
      ElseIf AScan( ::aHiddenCols, ::nColPos ) > 0
        // Hidden column
      Else
         ::lEditMode := ::FullMove
         ::lCalledFromClass := .T.
         lRet := ::EditCell( ::nRowPos, ::nColPos, , , , , , .F. )
         ::lCalledFromClass := .F.
         ::lEditMode := .F.

         If ::lAppendMode
            ::lAppendMode := .F.
            If lRet
               ::DoEvent( ::OnAppend, "APPEND", { ::nRowPos } )
               lSomethingEdited := .T.
            Else
               Exit
            EndIf
         ElseIf lRet
            lSomethingEdited := .T.
         Else
            Exit
         EndIf

         If ::bPosition == 9                     // MOUSE EXIT
            // Edition window lost focus, resume clic processing and process delayed click
            ::bPosition := 0
            If ::nDelayedClick[ 1 ] > 0
               // A click message was delayed
               If ::nDelayedClick[ 3 ] <= 0
                  ::SetControlValue( ::nDelayedClick[ 1 ] )
               EndIf

               If ::nDelayedClick[ 4 ] == NIL
                  If HB_IsBlock( ::OnClick )
                     If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                        If ! ::NestedClick
                           ::NestedClick := ! _OOHG_NestedSameEvent()
                           ::DoEventMouseCoords( ::OnClick, "CLICK" )
                           ::NestedClick := .F.
                        EndIf
                     EndIf
                  EndIf
               Else
                  If HB_IsBlock( ::OnRClick )
                     If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                        ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
                     EndIf
                  EndIf
               EndIf

               If ::nDelayedClick[ 3 ] > 0
                  // change check mark
                  ::CheckItem( ::nDelayedClick[ 3 ], ! ::CheckItem( ::nDelayedClick[ 3 ] ) )
               EndIf

               // fire context menu
               If ! ::nDelayedClick[ 4 ] == NIL .AND. ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0 )
                  ::ContextMenu:Cargo := ::nDelayedClick[ 4 ]
                  ::ContextMenu:Activate()
               EndIf
            EndIf
            Exit
         EndIf
      EndIf

      /*
       * ::OnEditCell may change ::nRowPos and/or ::nColPos using ::Up(), ::PageUp(), ::Home(),
       * ::End(), ::Down(), ::PageDown(), ::GoTop(), ::GoBottom(), ::Left() and/or ::Right()
       */

      If ::nColPos == 0
         nNextCol := ::FirstColInOrder
      Else
         nNextCol := ::NextColInOrder( ::nColPos )
      EndIf

      If nNextCol > 0
         ::nColPos := nNextCol
      ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
         Exit
      ElseIf ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
         Exit
      ElseIf ::nRowPos < ::ItemCount
         ::nColPos := ::FirstColInOrder
         If ::nColPos == 0
            Exit
         EndIf
         ::nRowPos ++
         ::SetControlValue( ::nRowPos )
         ::ScrollToLeft()
      ElseIf lAppend .OR. ::AllowAppend
         ::nColPos := ::FirstColInOrder
         If ::nColPos == 0
            Exit
         EndIf
         ::lAppendMode := .T.
         ::InsertBlank( ::ItemCount + 1 )
         ::nRowPos := ::ItemCount
         ::SetControlValue( ::nRowPos )
         ::ScrollToLeft()
      Else
         Exit
      EndIf
   EndDo

   ::ScrollToLeft()

   Return lSomethingEdited

METHOD Right() CLASS TGrid

   Local nNextCol

   If ::lEditMode
      nNextCol := ::NextColInOrder( ::nColPos )
      If nNextCol # 0
         ::nColPos := nNextCol
      EndIf
   EndIf

   Return Self

METHOD Left() CLASS TGrid

   If ::lEditMode
      If ::nColPos # ::FirstColInOrder
         ::nColPos := ::PriorColInOrder( ::PriorColInOrder( ::nColPos ) )
      EndIf
   EndIf

   Return Self

METHOD Down( lAppend ) CLASS TGrid

   If ::lEditMode
      If ::nRowPos < ::ItemCount
         ::nRowPos ++
      EndIf
   Else
      If ::FirstSelectedItem < ::ItemCount
         ::SetControlValue( ::FirstSelectedItem + 1 )
      Else
         ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT ::AllowAppend
         If lAppend
            ::AppendItem()
         EndIf
      EndIf
   EndIf

   Return Self

METHOD Up() CLASS TGrid

   If ::lEditMode
      If ::nRowPos > 1
         ::nRowPos --
      EndIf
   Else
      If ::FirstSelectedItem > 1
         ::SetControlValue( ::FirstSelectedItem - 1 )
      EndIf
   EndIf

   Return Self

METHOD PageUp() CLASS TGrid

   If ::lEditMode
      If ::nRowPos > ::CountPerPage
         ::nRowPos -= ::CountPerPage
      Else
         ::nRowPos := 1
      EndIf
   Else
      If ::FirstSelectedItem > ::CountPerPage
         ::SetControlValue( ::FirstSelectedItem - ::CountPerPage )
      Else
         ::GoTop()
      EndIf
   EndIf

   Return Self

METHOD PageDown() CLASS TGrid

   If ::lEditMode
      If ::nRowPos < ::ItemCount - ::CountPerPage
         ::nRowPos += ::CountPerPage
      Else
         ::nRowPos := ::ItemCount
      EndIf
   Else
      If ::FirstSelectedItem < ::ItemCount - ::CountPerPage
         ::SetControlValue( ::FirstSelectedItem + ::CountPerPage )
      Else
        ::GoBottom()
      EndIf
   EndIf

   Return Self

METHOD GoTop() CLASS TGrid

   If ::lEditMode
      ::nRowPos := 1
   Else
      If ::ItemCount > 0
         ::SetControlValue( 1 )
      EndIf
   EndIf

   Return Self

METHOD GoBottom() CLASS TGrid

   If ::lEditMode
      ::nRowPos := ::ItemCount
   Else
      If ::ItemCount > 0
         ::SetControlValue( ::ItemCount )
      EndIf
   EndIf

   Return Self

METHOD ToExcel( cTitle, nItemFrom, nItemTo, nColFrom, nColTo ) CLASS TGrid

   Local oExcel, oSheet, nLin, i, j, uValue, aColumnOrder

   If ! ValType( cTitle ) $ "CM"
      cTitle := ""
   EndIf
   If ! ValType( nItemFrom ) == "N" .OR. nItemFrom < 1 .OR. nItemFrom > ::ItemCount
      nItemFrom := Max( ::FirstSelectedItem, 1 )
   EndIf
   If ! ValType( nItemTo ) == "N" .OR. nItemTo < 1 .OR. nItemTo > ::ItemCount .OR. nItemTo < nItemFrom
      nItemTo := ::ItemCount
   EndIf
   If ! ValType( nColFrom ) == "N" .OR. nColFrom < 1 .OR. nColFrom > Len( ::aHeaders )
      // nColFrom is an index in ::ColumnOrder
      nColFrom := 1
   EndIf
   If ! ValType( nColTo ) == "N" .OR. nColTo < 1 .OR. nColTo > Len( ::aHeaders ) .OR. nColTo < nColFrom
      // nColTo is an index in ::ColumnOrder
      nColTo := Len( ::aHeaders )
   EndIf

   #ifndef __XHARBOUR__
      If ( oExcel := win_oleCreateObject( "Excel.Application" ) ) == Nil
         MsgStop( "Error: MS Excel not available. [" + win_oleErrorText()+ "]" )
         Return Self
      EndIf
   #else
      oExcel := TOleAuto():New( "Excel.Application" )
      If Ole2TxtError() != "S_OK"
         MsgStop( "Excel not found", "Error" )
         Return Self
      EndIf
   #EndIf

   oExcel:WorkBooks:Add()
   oSheet := oExcel:ActiveSheet()
   oSheet:Cells:Font:Name := "Arial"
   oSheet:Cells:Font:Size := 10

   aColumnOrder := ::ColumnOrder
   nLin := 4

   For i := nColFrom To nColTo
      oSheet:Cells( nLin, i - nColFrom + 1 ):Value := ::aHeaders[ aColumnOrder[ i ] ]
      oSheet:Cells( nLin, i - nColFrom + 1 ):Font:Bold := .T.
   Next i
   nLin += 2

   For j := nItemFrom To nItemTo
      For i := nColFrom To nColTo
         uValue := ::Cell( j, aColumnOrder[ i ] )
         If ! HB_IsDate( uValue ) .OR. ! Empty( uValue )
            oSheet:Cells( nLin, i - nColFrom + 1 ):Value := uValue
         EndIf
      Next i
      nLin ++
   Next j

   For i := nColFrom To nColTo
      oSheet:Columns( i - nColFrom + 1 ):AutoFit()
   Next i

   oSheet:Cells( 1, 1 ):Value := cTitle
   oSheet:Cells( 1, 1 ):Font:Bold := .T.

   oSheet:Cells( 1, 1 ):Select()
   oExcel:Visible := .T.
   oSheet := Nil
   oExcel := Nil

   Return Self

METHOD ToOpenOffice( cTitle, nItemFrom, nItemTo, nColFrom, nColTo ) CLASS TGrid

   Local oSerMan, oDesk, oPropVals, oBook, oSheet, nLin, i, j, uValue, aColumnOrder

   If ! ValType( cTitle ) $ "CM"
      cTitle := ""
   EndIf
   If ! ValType( nItemFrom ) == "N" .OR. nItemFrom < 1 .OR. nItemFrom > ::ItemCount
      nItemFrom := Max( ::FirstSelectedItem, 1 )
   EndIf
   If ! ValType( nItemTo ) == "N" .OR. nItemTo < 1 .OR. nItemTo > ::ItemCount .OR. nItemTo < nItemFrom
      nItemTo := ::ItemCount
   EndIf
   If ! ValType( nColFrom ) == "N" .OR. nColFrom < 1 .OR. nColFrom > Len( ::aHeaders )
      // nColFrom is an index in ::ColumnOrder
      nColFrom := 1
   EndIf
   If ! ValType( nColTo ) == "N" .OR. nColTo < 1 .OR. nColTo > Len( ::aHeaders ) .OR. nColTo < nColFrom
      // nColTo is an index in ::ColumnOrder
      nColTo := Len( ::aHeaders )
   EndIf

   // open service manager
   #ifndef __XHARBOUR__
      If ( oSerMan := win_oleCreateObject( "com.sun.star.ServiceManager" ) ) == Nil
         MsgStop( "Error: OpenOffice not available. [" + win_oleErrorText()+ "]" )
         Return Self
      EndIf
   #else
      oSerMan := TOleAuto():New( "com.sun.star.ServiceManager" )
      If Ole2TxtError() != "S_OK"
         MsgStop( "OpenOffice not found", "Error" )
         Return Self
      EndIf
   #EndIf

   // open desktop service
   If ( oDesk := oSerMan:CreateInstance( "com.sun.star.frame.Desktop" ) ) == Nil
      MsgStop( "Error: OpenOffice Desktop not available." )
      Return Self
   EndIf

   // set properties for new book
   oPropVals := oSerMan:Bridge_GetStruct( "com.sun.star.beans.PropertyValue" )
   oPropVals:Name := "Hidden"
   oPropVals:Value := .T.

   // open new book
   If ( oBook := oDesk:LoadComponentFromURL( "private:factory/scalc", "_blank", 0, {oPropVals} ) ) == Nil
      MsgStop( "Error: OpenOffice Calc not available." )
      oDesk := Nil
      Return Self
   EndIf

   // keep only one sheet
   Do While oBook:Sheets:GetCount() > 1
      oSheet := oBook:Sheets:GetByIndex( oBook:Sheets:GetCount() - 1 )
      oBook:Sheets:RemoveByName( oSheet:Name )
   EndDo

   // select first sheet
   oSheet := oBook:Sheets:GetByIndex( 0 )
   oBook:GetCurrentController:SetActiveSheet( oSheet )

   // set font name and size of all cells
   oSheet:CharFontName := "Arial"
   oSheet:CharHeight := 10

   aColumnOrder := ::ColumnOrder
   nLin := 4

   // put headers using bold style
   For i := nColFrom To nColTo
      oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetString( ::aHeaders[ aColumnOrder[ i ] ] )
      oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetPropertyValue( "CharWeight", 150 )
   Next i
   nLin += 2

   // put rows
   For j := nItemFrom To nItemTo
      For i := nColFrom To nColTo
         uValue := ::Cell( j, aColumnOrder[ i ] )
         Do Case
         Case uValue == Nil
         Case ValType( uValue ) == "C"
            If Left( uValue, 1 ) == "'"
               uValue := "'" + uValue
            EndIf
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetString( uValue )
         Case ValType( uValue ) == "N"
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetValue( uValue )
         Case ValType( uValue ) == "L"
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetValue( uValue )
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetPropertyValue("NumberFormat", 99 )
         Case ValType( uValue ) == "D"
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetValue( uValue )
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetPropertyValue( "NumberFormat", 36 )
         Case ValType( uValue ) == "T"
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetString( uValue )
         otherwise
            oSheet:GetCellByPosition( i - nColFrom, nLin - 1 ):SetFormula( uValue )
         EndCase
      Next i
      nLin ++
   Next j

   // autofit columns
   For i := nColFrom To nColTo
      oSheet:GetColumns:GetByIndex( i - nColFrom ):SetPropertyValue( "OptimalWidth", .T. )
   Next i

   // put title using bold style
   oSheet:GetCellByPosition( 0, 0 ):SetString( cTitle )
   oSheet:GetCellByPosition( 0, 0 ):SetPropertyValue( "CharWeight", 150 )

   // show
   oSheet:GetCellRangeByName( "A1:A1" )
   oSheet:IsVisible := .T.
   oBook:GetCurrentController():GetFrame():GetContainerWindow():SetVisible( .T. )
   oBook:GetCurrentController():GetFrame():GetContainerWindow():ToFront()

   // cleanup
   oSheet    := Nil
   oBook     := Nil
   oPropVals := Nil
   oDesk     := Nil
   oSerMan   := Nil

   Return Self

METHOD EditItem( nItem, lAppend, lOneRow, lChange ) CLASS TGrid

   Local aItems, lSomethingEdited := .F.

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf

   ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT .F.

   If ::lAppendMode
      // Before calling ::EditItem an empty item was added at ::ItemCount
      nItem := ::ItemCount
      lChange := .T.
   ElseIf lAppend
      // Add new item, ignore ::AllowAppend
      ::lAppendMode := .T.
      ::InsertBlank( ::ItemCount + 1 )
      nItem := ::ItemCount
      ASSIGN lChange VALUE lChange TYPE "L" DEFAULT ::lChangeBeforeEdit
      If lChange
         ::SetControlValue( nItem )
      EndIf
   Else
      // Edit item nItem
      If ! HB_IsNumeric( nItem )
         nItem := Max( ::FirstSelectedItem, 1 )
      EndIf
      If nItem < 1 .OR. nItem > ::ItemCount
         Return .F.
      EndIf
      ASSIGN lChange VALUE lChange TYPE "L" DEFAULT ::lChangeBeforeEdit
      If lChange
         ::SetControlValue( nItem )
      EndIf
   EndIf

   ASSIGN lOneRow VALUE lOneRow TYPE "L" DEFAULT .T.

   Do While .T.
      aItems := ::Item( nItem )

      aItems := ::EditItem2( nItem, aItems, , , If( ValType( ::cRowEditTitle ) $ "CM", ::cRowEditTitle, _OOHG_Messages( 1, 5 ) ) )

      If Empty( aItems )
         ::DoEvent( ::OnAbortEdit, "ABORTEDIT", { nItem, 0 } )
         If ::lAppendMode
            ::DeleteItem( ::ItemCount )
            If lChange
               ::SetControlValue( ::ItemCount )
            EndIf
         EndIf
         Exit
      EndIf

      lSomethingEdited := .T.
      ::Item( nItem, ASize( aItems, Len( ::aHeaders ) ) )

      _SetThisCellInfo( ::hWnd, nItem, 1, Nil )
      ::DoEvent( ::OnEditCellEnd, "EDITCELLEND", { nItem, 0 } )
      _ClearThisCellInfo()

      If ::lAppendMode
         _SetThisCellInfo( ::hWnd, nItem, 1, Nil )
         ::DoEvent( ::OnAppend, "APPEND", { nItem } )
         _ClearThisCellInfo()
      EndIf

      _SetThisCellInfo( ::hWnd, nItem, 1, Nil )
      ::DoEvent( ::OnEditCell, "EDITCELL", { nItem, 0 } )
      _ClearThisCellInfo()

      If lOneRow
         Exit
      ElseIf nItem < ::ItemCount
         nItem ++
         If lChange
            ::SetControlValue( nItem )
         EndIf
      ElseIf lAppend .OR. ::AllowAppend
         ::lAppendMode := .T.
         ::InsertBlank( ::ItemCount + 1 )
         nItem := ::ItemCount
         If lChange
            ::SetControlValue( nItem )
         EndIf
      Else
         Exit
      EndIf
   EndDo

   ::ScrollToLeft()

   Return lSomethingEdited

METHOD EditItem2( nItem, aItems, aEditControls, aMemVars, cTitle ) CLASS TGrid

   Local l, actpos := {0,0,0,0}, GCol, iRow, i, oWnd, nWidth, nMaxHigh, oMain
   Local EditControl, aEditControls2, nRow, lSplitWindow, nControlsMaxHeight
   Local aReturn, lHidden

   If ::FirstVisibleColumn == 0
      Return {}
   EndIf
   If ! HB_IsNumeric( nItem )
      nItem := Max( ::FirstSelectedItem, 1 )
   EndIf
   If nItem < 1 .OR. nItem > ::ItemCount
      Return {}
   EndIf
   If ::lNested
      Return {}
   EndIf
   ::lNested := .T.

   If ! HB_IsArray( aItems ) .OR. Len( aItems ) == 0
      aItems := ::Item( nItem )
   EndIf
   aItems := AClone( aItems )
   If Len( aItems ) > Len( ::aHeaders )
       ASize( aItems, Len( ::aHeaders ) )
   EndIf

   l := Len( aItems )

   iRow := ListViewGetItemRow( ::hWnd, nItem )

   GetWindowRect( ::hWnd, actpos )

   _SetThisCellInfo( ::hWnd, nItem, 1 )

   nControlsMaxHeight := GetDesktopHeight() - 130

   nWidth := 140
   nRow := 0
   aEditControls2 := Array( l )
   For i := 1 To l
      If ::FixControls()
         EditControl := ::aEditControls[ i ]
      Else
         EditControl := Nil
      EndIf
      EditControl := GetEditControlFromArray( EditControl, aEditControls, i, Self )
      EditControl := GetEditControlFromArray( EditControl, ::EditControls, i, Self )
      If ! HB_IsObject( EditControl )
         If ValType( ::Picture[ i ] ) $ "CM"
            EditControl := TGridControlTextBox():New( ::Picture[ i ], , "C", , , , Self )
         ElseIf ValType( ::Picture[ i ] ) == "L" .AND. ::Picture[ i ]
            EditControl := TGridControlImageList():New( Self )
         Else
            EditControl := TGridControlTextBox():New( , , , , , , Self )
         EndIf
      EndIf
      aEditControls2[ i ] := EditControl
      nWidth := Max( nWidth, EditControl:nDefWidth )
      nRow += EditControl:nDefHeight + 6
   Next

   lSplitWindow := ( nRow > nControlsMaxHeight )

   nWidth += If( lSplitWindow, 170, 140 )

   GCol := actpos[ 1 ] + ( ( ( actpos[ 3 ] - actpos[ 1 ] ) - nWidth ) / 2 )
   GCol := Max( Min( GCol, ( GetSystemMetrics( SM_CXFULLSCREEN ) - nWidth ) ), 0 )

   nMaxHigh := Min( nControlsMaxHeight, nRow ) + 70 + GetTitleHeight()
   iRow := Max( Min( iRow, ( GetSystemMetrics( SM_CYFULLSCREEN ) - nMaxHigh ) ), 0 )

   aReturn := {}

   DEFINE WINDOW 0 OBJ oMain AT iRow,GCol ;
      WIDTH nWidth HEIGHT nMaxHigh ;
      TITLE cTitle MODAL NOSIZE

   If lSplitWindow
      DEFINE SPLITBOX
         DEFINE WINDOW 0 OBJ oWnd;
            WIDTH nWidth ;
            HEIGHT nControlsMaxHeight ;
            VIRTUAL HEIGHT nRow + 20 ;
            SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK FOCUSED
   Else
      oWnd := oMain
   EndIf

   nRow := 10

   For i := 1 To l
      // Do not create label for hidden column
      lHidden := ( AScan( ::aHiddenCols, i ) > 0 )
      If ! lHidden
        @ nRow + 3, 10 LABEL 0 PARENT ( oWnd ) VALUE AllTrim( ::aHeaders[ i ] ) + ":" WIDTH 110 NOWORDWRAP
      EndIf
      aEditControls2[ i ]:CreateControl( aItems[ i ], oWnd:Name, nRow, 120, aEditControls2[ i ]:nDefWidth, aEditControls2[ i ]:nDefHeight )
      nRow += aEditControls2[ i ]:nDefHeight + 6
      If HB_IsArray( aMemVars ) .AND. Len( aMemVars ) >= i
         aEditControls2[ i ]:cMemVar := aMemVars[ i ]
         // Create memvars
         If ValType( aMemVars[ i ] ) $ "CM" .AND. ! Empty( aMemVars[ i ] )
            &( aMemVars[ i ] ) := Nil
         EndIf
      EndIf
      // Set Valid block
      If lHidden
         aEditControls2[ i ]:bValid := { || .T. }
         aEditControls2[ i ]:Visible := .F.
      ElseIf HB_IsArray( ::Valid ) .AND. Len( ::Valid ) >= i
         If HB_IsBlock( ::Valid[ i ] )
            aEditControls2[ i ]:bValid := ::Valid[ i ]
         Else
            aEditControls2[ i ]:bValid := { || .T. }
         EndIf
      ElseIf HB_IsBlock( ::Valid )
         aEditControls2[ i ]:bValid := ::Valid
      Else
         aEditControls2[ i ]:bValid := { || .T. }
      EndIf
      // Set message for invalid values
      If HB_IsArray( ::ValidMessages ) .AND. Len( ::ValidMessages ) >= i
         aEditControls2[ i ]:cValidMessage := ::ValidMessages[ i ]
      EndIf
      // Set When block
      If HB_IsArray( ::aWhen ) .AND. Len( ::aWhen ) >= i
         If HB_IsBlock( ::aWhen[ i ] )
            aEditControls2[ i ]:bWhen := ::aWhen[ i ]
         ElseIf ! ::IsColumnWhen( i, nItem )
            aEditControls2[ i ]:Enabled := .F.
            aEditControls2[ i ]:bWhen := { || .F. }
         EndIf
      ElseIf ! ::IsColumnWhen( i, nItem )
         aEditControls2[ i ]:Enabled := .F.
         aEditControls2[ i ]:bWhen := { || .F. }
      EndIf
      // Set Readonly block
      If HB_IsArray( ::ReadOnly ) .AND. Len( ::ReadOnly ) >= i
         If HB_IsBlock( ::ReadOnly[ i ] )
            aEditControls2[ i ]:bWhen := ::ReadOnly[ i ]
         ElseIf ::IsColumnReadOnly( i, nItem )
            aEditControls2[ i ]:Enabled := .F.
            aEditControls2[ i ]:bWhen := { || .F. }
         EndIf
      ElseIf ::IsColumnReadOnly( i, nItem )
         aEditControls2[ i ]:Enabled := .F.
         aEditControls2[ i ]:bWhen := { || .F. }
      EndIf
   Next

   If HB_IsArray( ::aEditKeys )
      For i := 1 To Len( ::aEditKeys )
         If HB_IsArray( ::aEditKeys[ i ] ) .AND. Len( ::aEditKeys[ i ] ) > 1 .AND. ValType( ::aEditKeys[ i, 1 ] ) $ "CM" .AND. HB_IsBlock( ::aEditKeys[ i, 2 ] )
            _DefineAnyKey( oWnd, ::aEditKeys[ i, 1 ], ::aEditKeys[ i, 2 ] )
         EndIf
      Next
   EndIf

   If lSplitWindow
      END WINDOW

      DEFINE WINDOW 0 OBJ oWnd ;
         WIDTH nWidth ;
         HEIGHT 50 ;
         SPLITCHILD NOCAPTION FONT 'Arial' SIZE 10 BREAK

      nRow := 10
   Else
      nRow += 10
   EndIf

   @ nRow,  25 BUTTON 0 PARENT ( oWnd ) CAPTION _OOHG_Messages( 1, 6 ) ;
         ACTION ( TGrid_EditItem_Check( aEditControls2, aItems, oMain, aReturn ) )

   @ nRow, 145 BUTTON 0 PARENT ( oWnd ) CAPTION _OOHG_Messages( 1, 7 ) ;
         ACTION oMain:Release()

   END WINDOW

   If lSplitWindow
      END SPLITBOX
      END WINDOW
   EndIf

   AEval( aEditControls2, { |o| o:OnLostFocus := { || TGrid_EditItem_When( aEditControls2 ) } } )

   TGrid_EditItem_When( aEditControls2 )

   aEditControls2[ 1 ]:SetFocus()

   oMain:Activate()

   _ClearThisCellInfo()

   ::SetFocus()

   ::lNested := .F.

   Return aReturn

STATIC FUNCTION TGrid_EditItem_When( aEditControls )

   Local nItem, lEnabled, aValues

   // Save values
   aValues := Array( Len( aEditControls ) )
   For nItem := 1 To Len( aEditControls )
      aValues[ nItem ] := aEditControls[ nItem ]:ControlValue
      If ValType( aEditControls[ nItem ]:cMemVar ) $ "CM" .AND. ! Empty( aEditControls[ nItem ]:cMemVar )
         &( aEditControls[ nItem ]:cMemVar ) := aValues[ nItem ]
      EndIf
   Next

   // WHEN clause
   For nItem := 1 To Len( aEditControls )
      _OOHG_ThisItemCellValue := aValues[ nItem ]
      lEnabled := _OOHG_Eval( aEditControls[ nItem ]:bWhen, nItem, aValues )
      If _CheckCellNewValue( aEditControls[ nItem ], aValues[ nItem ] )
         aValues[ nItem ] := _OOHG_ThisItemCellValue
      EndIf
      If HB_IsLogical( lEnabled ) .AND. ! lEnabled
         aEditControls[ nItem ]:Enabled := .F.
      Else
         aEditControls[ nItem ]:Enabled := .T.
      EndIf
   Next

   Return aValues

STATIC PROCEDURE TGrid_EditItem_Check( aEditControls, aItems, oWnd, aReturn )

   Local lRet, nItem, aValues, lValid, cValidMessage

   // Save values
   aValues := TGrid_EditItem_When( aEditControls )

   // Check VALID clauses
   lRet := .T.
   For nItem := 1 To Len( aEditControls )
      _OOHG_ThisItemCellValue := aValues[ nItem ]
      lValid := _OOHG_Eval( aEditControls[ nItem ]:bValid, aValues[ nItem ], nItem, aValues )
      If _CheckCellNewValue( aEditControls[ nItem ], aValues[ nItem ] )
         aValues[ nItem ] := _OOHG_ThisItemCellValue
      EndIf
      If HB_IsLogical( lValid ) .AND. ! lValid
         lRet := .F.
         cValidMessage := aEditControls[ nItem ]:cValidMessage
         If HB_IsBlock( cValidMessage )
            cValidMessage := Eval( cValidMessage, _OOHG_ThisItemCellValue )
         EndIf
         If ValType( cValidMessage ) $ "CM" .AND. ! Empty( cValidMessage )
            MsgExclamation( cValidMessage )
         Else
            MsgExclamation( _OOHG_Messages( 3, 11 ) )
         EndIf
         aEditControls[ nItem ]:SetFocus()
      EndIf
   Next

   // If all controls are valid, save values into "aItems"
   If lRet
      ASize( aReturn, Len( aItems ) )
      AEval( aValues, { |u,i| aItems[ i ] := aReturn[ i ] := u } )
      oWnd:Release()
   EndIf

   Return

METHOD IsColumnReadOnly( nCol, nRow ) CLASS TGrid

   Local uReadOnly

   If ! HB_IsNumeric( nRow ) .OR. nRow < 1 .OR. nRow > :: ItemCount
      nRow := ::FirstSelectedItem
   EndIf

   If nRow == 0
      uReadOnly := _OOHG_GetArrayItem( ::ReadOnly, nCol, {} )
   Else
      uReadOnly := _OOHG_GetArrayItem( ::ReadOnly, nCol, ::Item( nRow ) )
   EndIf

   Return ( HB_IsLogical( uReadOnly ) .AND. uReadOnly )

METHOD IsColumnWhen( nCol, nRow ) CLASS TGrid

   Local uWhen

   If ! HB_IsNumeric( nRow ) .OR. nRow < 1 .OR. nRow > :: ItemCount
      nRow := ::FirstSelectedItem
   EndIf

   If nRow == 0
      uWhen := _OOHG_GetArrayItem( ::aWhen, nCol, {} )
   Else
      uWhen := _OOHG_GetArrayItem( ::aWhen, nCol, ::Item( nRow ) )
   EndIf

   Return ( ! HB_IsLogical( uWhen ) .OR. uWhen )

METHOD AddColumn( nColIndex, cCaption, nWidth, nJustify, uForeColor, uBackColor, ;
                  lNoDelete, uPicture, uEditControl, uHeadClick, uValid, ;
                  uValidMessage, uWhen, nHeaderImage, nHeaderImageAlign, ;
                  uReadOnly ) CLASS TGrid

   Local nColumns, uGridColor, uDynamicColor, i

   // Set Default Values
   nColumns := Len( ::aHeaders ) + 1

   If ! HB_IsNumeric( nColIndex ) .OR. nColIndex > nColumns
      nColIndex := nColumns
   ElseIf nColIndex < 1
      nColIndex := 1
   EndIf

   For i := 1 To Len( ::aHiddenCols )
      If ::aHiddenCols[ i ] >= nColIndex
         ::aHiddenCols[ i ] ++
      EndIf
   Next i

   If ! ValType( cCaption ) $ 'CM'
      cCaption := ''
   EndIf

   If ! HB_IsNumeric( nWidth ) .OR. nWidth < 0
      nWidth := 120
   EndIf

   If ! HB_IsNumeric( nJustify )
      nJustify := 0
   EndIf

   // Update Headers
   ASize( ::aHeaders, nColumns )
   AIns( ::aHeaders, nColIndex )
   ::aHeaders[ nColIndex ] := cCaption

   // Update Pictures
   ASize( ::Picture, nColumns )
   AIns( ::Picture, nColIndex )
   ::Picture[ nColIndex ] := If( ( ValType( uPicture ) $ "CM" .AND. ! Empty( uPicture ) ) .OR. HB_IsLogical( uPicture ), uPicture, Nil )

   // Update Widths
   ASize( ::aWidths, nColumns )
   AIns( ::aWidths, nColIndex )
   ::aWidths[ nColIndex ] := nWidth

   If ! HB_IsLogical( lNoDelete )
      lNoDelete := .F.
   EndIf

   // Update Foreground Color
   uGridColor := ::GridForeColor
   uDynamicColor := ::DynamicForeColor
   TGrid_AddColumnColor( @uGridColor, nColIndex, uForeColor, @uDynamicColor, nColumns, ::ItemCount, lNoDelete, ::hWnd )
   ::GridForeColor := uGridColor
   ::DynamicForeColor := uDynamicColor

   // Update Background Color
   uGridColor := ::GridBackColor
   uDynamicColor := ::DynamicBackColor
   TGrid_AddColumnColor( @uGridColor, nColIndex, uBackColor, @uDynamicColor, nColumns, ::ItemCount, lNoDelete, ::hWnd )
   ::GridBackColor := uGridColor
   ::DynamicBackColor := uDynamicColor

   // Update edit control
   If ValType( uEditControl ) != Nil .OR. HB_IsArray( ::EditControls )
      If ! HB_IsArray( ::EditControls )
         ::EditControls := Array( nColumns )
      ElseIf Len( ::EditControls ) < nColumns
         ASize( ::EditControls, nColumns )
      EndIf
      AIns( ::EditControls, nColIndex )
      ::EditControls[ nColIndex ] := uEditControl
      If ::FixControls()
         ::FixControls( .T. )
      EndIf
   EndIf

   // Update justification
   ASize( ::aJust, nColumns )
   AIns( ::aJust, nColIndex )
   ::aJust[ nColIndex ] := nJustify

   // Update on head click codeblock
   ASize( ::aHeadClick, nColumns )
   AIns( ::aHeadClick, nColIndex )
   ::aHeadClick[ nColIndex ] := uHeadClick

   // Update valid
   If HB_IsArray( ::Valid )
      ASize( ::Valid, nColumns )
      AIns( ::Valid, nColIndex )
      ::Valid[ nColIndex ] := uValid
   ElseIf uValid != Nil
      ::Valid := Array( nColumns )
      ::Valid[ nColIndex ] := uValid
   EndIf

   // Update validmessages
   If HB_IsArray( ::ValidMessages )
      ASize( ::ValidMessages, nColumns )
      AIns( ::ValidMessages, nColIndex )
      ::ValidMessages[ nColIndex ] := uValidMessage
   ElseIf uValidMessage != Nil
      ::ValidMessages := Array( nColumns )
      ::ValidMessages[ nColIndex ] := uValidMessage
   EndIf

   // Update when
   If HB_IsArray( ::aWhen )
      ASize( ::aWhen, nColumns )
      AIns( ::aWhen, nColIndex )
      ::aWhen[ nColIndex ] := uWhen
   ElseIf uWhen != Nil
      ::aWhen := Array( nColumns )
      ::aWhen[ nColIndex ] := uWhen
   EndIf

   // Update readonly
   If HB_IsArray( ::Readonly )
      ASize( ::Readonly, nColumns )
      AIns( ::Readonly, nColIndex )
      ::Readonly[ nColIndex ] := uReadOnly
   ElseIf uReadOnly != Nil
      ::Readonly := Array( nColumns )
      ::Readonly[ nColIndex ] := uReadOnly
   EndIf

   // Update header image
   ASize( ::aHeaderImage, nColumns )
   AIns( ::aHeaderImage, nColIndex )
   If ! HB_IsNumeric( nHeaderImage ) .OR. nHeaderImage < 0
      nHeaderImage := 0
   EndIf
   ::HeaderImage( nColIndex, nHeaderImage )

   // Update header image alignment
   ASize( ::aHeaderImageAlign, nColumns )
   AIns( ::aHeaderImageAlign, nColIndex )
   If ! HB_IsNumeric( nHeaderImageAlign ) .OR. nHeaderImageAlign != HEADER_IMG_AT_RIGHT
      nHeaderImageAlign := HEADER_IMG_AT_LEFT
   EndIf
   ::HeaderImageAlign( nColIndex, nHeaderImageAlign )

   // Call C-Level Routine
   ListView_AddColumn( ::hWnd, nColIndex, nWidth, cCaption, nJustify, lNoDelete )

   Return nColIndex

// aGrid and uDynamicColor may be passed by reference
STATIC FUNCTION TGrid_AddColumnColor( aGrid, nColumn, uColor, uDynamicColor, nWidth, nItemCount, lNoDelete, hWnd )

   Local uTemp, x

   If ValType( uDynamicColor ) == "A"
      If Len( uDynamicColor ) < nWidth
         ASize( uDynamicColor, nWidth )
      EndIf
      AIns( uDynamicColor, nColumn )
      uDynamicColor[ nColumn ] := uColor
   ElseIf ValType( uColor ) $ "ANB"
      uTemp := uDynamicColor
      uDynamicColor := Array( nWidth )
      AFill( uDynamicColor, uTemp )
      uDynamicColor[ nColumn ] := uColor
   EndIf

   If ! lNoDelete
      uDynamicColor := Nil
   ElseIf HB_IsArray( aGrid ) .OR. ValType( uColor ) $ "ANB" .OR. ValType( uDynamicColor ) $ "ANB"
      If HB_IsArray( aGrid )
         If Len( aGrid ) < nItemCount
            ASize( aGrid, nItemCount )
         Else
            nItemCount := Len( aGrid )
         EndIf
      Else
         aGrid := Array( nItemCount )
      EndIf
      For x := 1 To nItemCount
         If HB_IsArray( aGrid[ x ] )
            If Len( aGrid[ x ] ) < nWidth
                ASize( aGrid[ x ], nWidth )
            EndIf
            AIns( aGrid[ x ], nColumn )
         Else
            aGrid[ x ] := Array( nWidth )
         EndIf
         _SetThisCellInfo( hWnd, x, nColumn, Nil )
         aGrid[ x ][ nColumn ] := _OOHG_GetArrayItem( uDynamicColor, nColumn, x )
         _ClearThisCellInfo()
      Next
   EndIf

   Return Nil

METHOD SetColumn( nColIndex, cCaption, nWidth, nJustify, uForeColor, uBackColor, ;
                  lNoDelete, uPicture, uEditControl, uHeadClick, uValid, ;
                  uValidMessage, uWhen, nHeaderImage, nHeaderImageAlign, ;
                  uReadonly ) CLASS TGrid

   Local nColumns, uGridColor, uDynamicColor

   // Set Default Values
   nColumns := Len( ::aHeaders )

   If ! HB_IsNumeric( nColIndex ) .OR. nColIndex > nColumns
      nColIndex := nColumns
   ElseIf nColIndex < 1
      nColIndex := 1
   EndIf

   If ! ValType( cCaption ) $ 'CM'
      cCaption := ''
   EndIf

   If ! HB_IsNumeric( nWidth ) .OR. nWidth < 0
      nWidth := ::ColumnWidth( nColIndex )
   EndIf

   If ! HB_IsNumeric( nJustify )
      nJustify := 0
   EndIf

   // Update Headers
   ::aHeaders[ nColIndex ] := cCaption

   // Update Pictures
   ::Picture[ nColIndex ] := If( ( ValType( uPicture ) $ "CM" .AND. ! Empty( uPicture ) ) .OR. HB_IsLogical( uPicture ), uPicture, Nil )

   // Update Widths
   ::aWidths[ nColIndex ] := nWidth

   If ! HB_IsLogical( lNoDelete )
      lNoDelete := .F.
   EndIf

   // Update Foreground Color
   uGridColor := ::GridForeColor
   uDynamicColor := ::DynamicForeColor
   TGrid_AddColumnColor( @uGridColor, nColIndex, uForeColor, @uDynamicColor, nColumns, ::ItemCount, lNoDelete, ::hWnd )
   ::GridForeColor := uGridColor
   ::DynamicForeColor := uDynamicColor

   // Update Background Color
   uGridColor := ::GridBackColor
   uDynamicColor := ::DynamicBackColor
   TGrid_AddColumnColor( @uGridColor, nColIndex, uBackColor, @uDynamicColor, nColumns, ::ItemCount, lNoDelete, ::hWnd )
   ::GridBackColor := uGridColor
   ::DynamicBackColor := uDynamicColor

   // Update edit control
   If ValType( uEditControl ) != Nil .OR. HB_IsArray( ::EditControls )
      If ! HB_IsArray( ::EditControls )
         ::EditControls := Array( nColumns )
      ElseIf Len( ::EditControls ) < nColumns
         ASize( ::EditControls, nColumns )
      EndIf
      ::EditControls[ nColIndex ] := uEditControl
      If ::FixControls()
         ::FixControls( .T. )
      EndIf
   EndIf

   // Update justification
   ::aJust[ nColIndex ] := nJustify

   // Update on head click codeblock
   ::aHeadClick[ nColIndex ] := uHeadClick

   // Update valid
   If HB_IsArray( ::Valid )
      ::Valid[ nColIndex ] := uValid
   ElseIf uValid != Nil
      ::Valid := Array( nColumns )
      ::Valid[ nColIndex ] := uValid
   EndIf

   // Update validmessages
   If HB_IsArray( ::ValidMessages )
      ::ValidMessages[ nColIndex ] := uValidMessage
   ElseIf uValidMessage != Nil
      ::ValidMessages := Array( nColumns )
      ::ValidMessages[ nColIndex ] := uValidMessage
   EndIf

   // Update when
   If HB_IsArray( ::aWhen )
      ::aWhen[ nColIndex ] := uWhen
   ElseIf uWhen != Nil
      ::aWhen := Array( nColumns )
      ::aWhen[ nColIndex ] := uWhen
   EndIf

   // Update readonly
   If HB_IsArray( ::Readonly )
      ::Readonly[ nColIndex ] := uReadOnly
   ElseIf uReadOnly != Nil
      ::Readonly := Array( nColumns )
      ::Readonly[ nColIndex ] := uReadOnly
   EndIf

   // Update header image
   If ! HB_IsNumeric( nHeaderImage ) .OR. nHeaderImage < 0
      nHeaderImage := 0
   EndIf
   ::HeaderImage( nColIndex, nHeaderImage )

   // Update header image alignment
   If ! HB_IsNumeric( nHeaderImageAlign ) .OR. nHeaderImageAlign != HEADER_IMG_AT_RIGHT
      nHeaderImageAlign := HEADER_IMG_AT_LEFT
   EndIf
   ::HeaderImageAlign( nColIndex, nHeaderImageAlign )

   // Call C-Level Routine
   ListView_SetColumn( ::hWnd, nColIndex, nWidth, cCaption, nJustify, lNoDelete )

   Return nColIndex

METHOD ColumnBetterAutoFit( nColIndex ) CLASS Tgrid

   Local n, nh

   If HB_IsNumeric( nColIndex )
      If nColindex > 0
         nh := ::ColumnAutoFitH( nColIndex )
         n := ::ColumnAutoFit( nColIndex )
         If nh > n
            ::ColumnAutoFitH( nColIndex )
         EndIf
      EndIf
   EndIf

   Return Self

METHOD ColumnHide( nColIndex ) CLASS TGrid

   If HB_IsNumeric( nColIndex )
      If nColIndex > 0 .AND. nColIndex <= Len( ::aHeaders ) .AND. AScan( ::aHiddenCols, nColIndex ) == 0
         ::ColumnWidth( nColIndex, 0 )
      EndIf
   EndIf

   Return Self

METHOD ColumnShow( nColIndex ) CLASS TGrid

   Local i

   If HB_IsNumeric( nColIndex )
      If nColindex > 0
         i := AScan( ::aHiddenCols, nColIndex )
         If i > 0
            ::ColumnBetterAutoFit ( nColIndex )
            _OOHG_DeleteArrayItem( ::aHiddenCols, i )
         EndIf
      EndIf
   EndIf

   Return Self

METHOD ColumnOrder( aOrder ) CLASS TGrid

   If HB_IsArray( aOrder )
      ListView_SetColumnOrder( ::hWnd, aOrder )
      ::Refresh()
   EndIf

   Return ListView_GetColumnOrder( ::hWnd )

METHOD DeleteColumn( nColIndex, lNoDelete ) CLASS TGrid

   Local nColumns, i

   nColumns := Len( ::aHeaders )
   If nColumns == 0
      Return 0
   EndIf

   If ! HB_IsNumeric( nColIndex ) .OR. nColIndex > nColumns
      nColIndex := nColumns
   ElseIf nColIndex < 1
      nColIndex := 1
   EndIf

   If ( i := AScan( ::aHiddenCols, nColIndex ) ) > 0
      _OOHG_DeleteArrayItem( ::aHiddenCols, i )
   EndIf

   _OOHG_DeleteArrayItem( ::aHeaders, nColIndex )
   _OOHG_DeleteArrayItem( ::aWidths, nColIndex )
   _OOHG_DeleteArrayItem( ::Picture, nColIndex )
   _OOHG_DeleteArrayItem( ::aHeadClick, nColIndex )
   _OOHG_DeleteArrayItem( ::aJust, nColIndex )
   _OOHG_DeleteArrayItem( ::Valid, nColIndex )
   _OOHG_DeleteArrayItem( ::ValidMessages, nColIndex )
   _OOHG_DeleteArrayItem( ::aWhen, nColIndex )
   _OOHG_DeleteArrayItem( ::aHeaderImage, nColIndex )
   _OOHG_DeleteArrayItem( ::aHeaderImageAlign, nColIndex )
   _OOHG_DeleteArrayItem( ::DynamicForeColor, nColIndex )
   _OOHG_DeleteArrayItem( ::DynamicBackColor, nColIndex )
   _OOHG_DeleteArrayItem( ::Readonly, nColIndex )
   _OOHG_DeleteArrayItem( ::EditControls, nColIndex )
   _OOHG_DeleteArrayItem( ::aEditControls, nColIndex )

   If HB_IsLogical( lNoDelete ) .AND. lNoDelete
      If HB_IsArray( ::GridForeColor )
         AEval( ::GridForeColor, { |a| _OOHG_DeleteArrayItem( a, nColIndex ) } )
      EndIf
      If ValType( ::GridBackColor ) == "A"
         AEval( ::GridBackColor, { |a| _OOHG_DeleteArrayItem( a, nColIndex ) } )
      EndIf
   Else
      ::GridForeColor := Nil
      ::GridBackColor := Nil
   EndIf

   // Call C-Level Routine
   ListView_DeleteColumn( ::hWnd, nColIndex, lNoDelete )

   Return nColIndex

METHOD Value( uValue ) CLASS TGrid

   If HB_IsNumeric( uValue )
      If ::lNoneUnsels .AND. ( uValue < 1 .OR. uValue > ::ItemCount() )
         If ::FirstSelectedItem # 0
            ListView_ClearCursel( ::hWnd, 0 )
            ::DoChange()
         EndIf
      Else
         ListView_SetCursel( ::hWnd, uValue )
         ListView_EnsureVisible( ::hWnd, uValue )
      EndIf
   EndIf

   Return ::FirstSelectedItem

METHOD Cell( nRow, nCol, uValue ) CLASS TGrid

   Local aItem, uValue2 := Nil

   If nRow >= 1 .AND. nRow <= ::ItemCount
      aItem := ::Item( nRow )
      If nCol >= 1 .AND. nCol <= Len( aItem )
         If PCount() > 2
            aItem[ nCol ] := uValue
            ::Item( nRow, aItem )
         EndIf
         uValue2 := aItem[ nCol ]
      EndIf
   EndIf

   Return uValue2

METHOD EditCell( nRow, nCol, EditControl, uOldValue, uValue, cMemVar, nOnFocusPos, lChange ) CLASS TGrid

   Local lRet, lRet2

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf
   If ! HB_IsNumeric( nRow )
      nRow := Max( ::FirstSelectedItem, 1 )
   EndIf
   If ! HB_IsNumeric( nCol )
      If ::lAppendMode .OR. ::lAtFirstCol
         nCol := ::FirstColInOrder
      Else
         nCol := ::FirstVisibleColumn
      EndIf
   EndIf
   If nRow < 1 .OR. nRow > ::ItemCount .OR. nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf
   If AScan( ::aHiddenCols, nCol ) > 0
      Return .F.
   EndIf

   ASSIGN lChange VALUE lChange TYPE "L" DEFAULT ::lChangeBeforeEdit
   If lChange
      ::SetControlValue( nRow )
   EndIf

   If HB_IsBlock( ::OnBeforeEditCell )
      _OOHG_ThisItemCellValue := ::Cell( nRow, nCol )
      lRet2 := ::DoEvent( ::OnBeforeEditCell, "BEFOREEDITCELL", { nRow, nCol } )
      _ClearThisCellInfo()
      If ! HB_IsLogical( lRet2 )
         lRet2 := .T.
      EndIf
   Else
      lRet2 := .T.
   EndIf

   If lRet2
      lRet := ::EditCell2( @nRow, @nCol, @EditControl, uOldValue, @uValue, cMemVar, nOnFocusPos )
   Else
      lRet := .F.
   EndIf

   If lRet
      If ValType( uValue ) $ "CM"
         uValue := Trim( uValue )
      EndIf
      If HB_IsBlock( ::OnEditCellEnd )
         _SetThisCellInfo( ::hWnd, nRow, nCol, uValue )
         lRet2 := ::DoEvent( ::OnEditCellEnd, "EDITCELLEND", { nRow, nCol } )
         _ClearThisCellInfo()
         If HB_IsLogical( lRet2 ) .and. ! lRet2
            lRet := .F.
         EndIf
      EndIf

      If lRet
         ::Cell( nRow, nCol, uValue )
         _SetThisCellInfo( ::hWnd, nRow, nCol, uValue )
         If HB_IsBlock( ::OnEditCell )
            lRet2 := ::DoEvent( ::OnEditCell, "EDITCELL", { nRow, nCol } )
            If HB_IsLogical( lRet2 ) .and. ! lRet2
               lRet := .F.
            EndIf
         EndIf
         If lRet
            If _CheckCellNewValue( EditControl, @uValue )
               ::Cell( nRow, nCol, uValue )
            EndIf
         EndIf
         _ClearThisCellInfo()

         If lRet
            If ! ::lCalledFromClass .AND. ::bPosition == 9
               // Edition window lost focus, resume clic processing and process delayed click
               ::bPosition := 0
               If ::nDelayedClick[ 1 ] > 0
                  // A click message was delayed
                  If ::nDelayedClick[ 3 ] <= 0
                     ::SetControlValue( ::nDelayedClick[ 1 ] )
                  EndIf

                  If ::nDelayedClick[ 4 ] == NIL
                     If HB_IsBlock( ::OnClick )
                        If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                           If ! ::NestedClick
                              ::NestedClick := ! _OOHG_NestedSameEvent()
                              ::DoEventMouseCoords( ::OnClick, "CLICK" )
                              ::NestedClick := .F.
                           EndIf
                        EndIf
                     EndIf
                  Else
                     If HB_IsBlock( ::OnRClick )
                        If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                           ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
                        EndIf
                     EndIf
                  EndIf

                  If ::nDelayedClick[ 3 ] > 0
                     // change check mark
                     ::CheckItem( ::nDelayedClick[ 3 ], ! ::CheckItem( ::nDelayedClick[ 3 ] ) )
                  EndIf

                  // fire context menu
                  If ! ::nDelayedClick[ 4 ] == NIL .AND. ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0 )
                     ::ContextMenu:Cargo := ::nDelayedClick[ 4 ]
                     ::ContextMenu:Activate()
                  EndIf
               EndIf
            EndIf
         EndIf
      EndIf
   EndIf

   If ! lRet
      If ::lAppendMode
         ::DoEvent( ::OnAbortEdit, "ABORTEDIT", { 0, 0 } )
         ::DeleteItem( ::ItemCount )
         ::SetControlValue( ::ItemCount )
      Else
         ::DoEvent( ::OnAbortEdit, "ABORTEDIT", { nRow, nCol } )
      EndIf
   EndIf

   Return lRet

// nRow, nCol, EditControl and uValue may be passed by reference
METHOD EditCell2( nRow, nCol, EditControl, uOldValue, uValue, cMemVar, nOnFocusPos ) CLASS TGrid

   Local r, r2, lRet := .F., nClientWidth, nScrollWidth

   If ! ValType( cMemVar ) $ "CM" .OR. Empty( cMemVar )
      cMemVar := "_OOHG_NULLVAR_"
   EndIf
   If ! HB_IsNumeric( nRow )
      nRow := Max( ::FirstSelectedItem, 1 )
   EndIf
   If ! HB_IsNumeric( nCol )
      If ::lAtFirstCol
         nCol := ::FirstColInOrder
      Else
         nCol := ::FirstVisibleColumn
      EndIf
   EndIf
   If nRow < 1 .OR. nRow > ::ItemCount .OR. nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf
   If ::lNested
      Return .F.
   EndIf
   ::lNested := .T.

   If ! ::lCalledFromClass
      // This var may be used in When codeblock
      _OOHG_ThisItemCellValue := ::Cell( nRow, nCol )

      If ::IsColumnReadOnly( nCol, nRow )
         // Read only column
         If ! ::lSilent
            PlayHand()
         EndIf
         ::lNested := .F.
         Return .F.
      ElseIf ! ::IsColumnWhen( nCol, nRow )
         // WHEN Returned .F.
         ::lNested := .F.
         Return .F.
      ElseIf AScan( ::aHiddenCols, nCol ) > 0
        // Hidden column
         ::lNested := .F.
         Return .F.
      EndIf
   EndIf

   // Get the initial value of the EditControl
   If ValType( uOldValue ) == "U"
      uValue := ::Cell( nRow, nCol )
   ElseIf HB_IsBlock( ::bEditCellValue )
      uValue := Eval( ::bEditCellValue, nCol, nRow, uOldValue )
   Else
      uValue := uOldValue
   EndIf

   // Determine control type
   If ! HB_IsObject( EditControl ) .AND. ::FixControls()
      EditControl := ::aEditControls[ nCol ]
   EndIf
   EditControl := GetEditControlFromArray( EditControl, ::EditControls, nCol, Self )
   If HB_IsObject( EditControl )
      // EditControl specified
   ElseIf ValType( ::Picture[ nCol ] ) $ "CM"
      // Picture-based
      EditControl := TGridControlTextBox():New( ::Picture[ nCol ], , ValType( uValue ), , , , Self )
   ElseIf ValType( ::Picture[ nCol ] ) == "L" .AND. ::Picture[ nCol ]
      EditControl := TGridControlImageList():New( Self )
   Else
      // Derive from data type
      EditControl := GridControlObjectByType( uValue, Self )
   EndIf

   If ! HB_IsObject( EditControl )
      MsgExclamation( _OOHG_Messages( 1, 12 ), _OOHG_Messages( 1, 5 ) )
   Else
      r := { 0, 0, 0, 0 }                                        // left, top, right, bottom
      GetClientRect( ::hWnd, r )
      nClientWidth := r[ 3 ] - r[ 1 ]
      r2 := { 0, 0, 0, 0 }                                       // left, top, right, bottom
      GetWindowRect( ::hWnd, r2 )
      // Ensure cell is visible and compute editing window's rect
      If ! OsIsWinVistaOrLater() .OR. ! ListView_IsItemVisible( ::hWnd, nRow )
         ListView_EnsureVisible( ::hWnd, nRow )
      EndIf
      r := ListView_GetSubitemRect( ::hWnd, nRow - 1, nCol - 1 ) // top, left, width, height
      If ::lScrollBarUsesClientArea .AND. ::ItemCount > ::CountPerPage
         nScrollWidth := GetVScrollBarWidth()
      Else
         nScrollWidth := 0
      EndIf
      If r[ 2 ] + r[ 3 ] + nScrollWidth > nClientWidth
         ListView_Scroll( ::hWnd, ( r[ 2 ] + r[ 3 ] + nScrollWidth - nClientWidth ), 0 )
         r := ListView_GetSubitemRect( ::hWnd, nRow - 1, nCol - 1 )
         r[ 3 ] := Min( r[ 3 ], nClientWidth )
      EndIf
      If r[ 2 ] < 0
         ListView_Scroll( ::hWnd, r[ 2 ], 0 )
         r := ListView_GetSubitemRect( ::hWnd, nRow - 1, nCol - 1 )
         r[ 3 ] := Min( r[ 3 ], nClientWidth )
      EndIf

      // Transform to screen coordinates, add some margins and check it's within form's rect
      r[ 1 ] += r2[ 2 ] + 2
      r[ 2 ] += r2[ 1 ] + 3
      r[ 3 ] := Min( r[ 3 ], ::Parent:Col + ::Parent:Width - GetBorderWidth() - r[ 2 ] )

      EditControl:cMemVar := cMemVar
      // Create memvar
      &( cMemVar ) := Nil

      If HB_IsArray( ::Valid ) .AND. Len( ::Valid ) >= nCol
         If HB_IsBlock( ::Valid[ nCol ] )
            EditControl:bValid := ::Valid[ nCol ]
         Else
            EditControl:bValid := { || .T. }
         EndIf
      ElseIf HB_IsBlock( ::Valid )
         EditControl:bValid := ::Valid
      Else
         EditControl:bValid := { || .T. }
      EndIf
      If HB_IsArray( ::ValidMessages ) .AND. Len( ::ValidMessages ) >= nCol
         EditControl:cValidMessage := ::ValidMessages[ nCol ]
      EndIf
      If nOnFocusPos # Nil
         EditControl:nOnFocusPos := nOnFocusPos
      EndIf
      If ValType( uValue ) $ "CM"
         uValue := Trim( uValue )
      EndIf

      ::nEditRow := nRow
      ::nDelayedClick := { 0, 0, 0, .F. }
      ::bPosition := -2
      _SetThisCellInfo( ::hWnd, nRow, nCol, uValue )
      lRet := EditControl:CreateWindow( uValue, r[ 1 ], r[ 2 ], r[ 3 ], r[ 4 ], ::FontName, ::FontSize, ::aEditKeys, Self )
      If lRet
         uValue := EditControl:Value
      Else
         ::SetFocus()
      EndIf

      _OOHG_ThisType := ''
      _ClearThisCellInfo()

   EndIf

   ::lNested := .F.

   Return lRet

METHOD EditAllCells( nRow, nCol, lAppend, lOneRow, lChange ) CLASS TGrid

   Local lRet, lSomethingEdited

   If ::FullMove
      Return ::EditGrid( nRow, nCol, lAppend, lOneRow, lChange )
   EndIf

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf

   ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT .F.

   If ! HB_IsNumeric( nCol )
      If ::lAppendMode .OR. lAppend .OR. ::lAtFirstCol
         nCol := ::FirstColInOrder
      Else
         nCol := ::FirstVisibleColumn
      EndIf
   EndIf
   If nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf

   If ::lAppendMode
      // Before calling ::EditAllCells an empty item was added at ::ItemCount
      nRow := ::ItemCount
   ElseIf lAppend
      // Add new item, ignore ::AllowAppend
      ::lAppendMode := .T.
      ::InsertBlank( ::ItemCount + 1 )
      ::SetControlValue( ::ItemCount, nCol )       // Needed by TGridByCell:EditAllCells
      nRow := ::ItemCount
   Else
      // Edit item nRow
      If ! HB_IsNumeric( nRow )
         nRow := Max( ::FirstSelectedItem, 1 )
      EndIf
      If nRow < 1 .OR. nRow > ::ItemCount
         Return .F.
      EndIf
      ASSIGN lChange VALUE lChange TYPE "L" DEFAULT ::lChangeBeforeEdit
      If lChange
         ::SetControlValue( nRow, nCol )           // Needed by TGridByCell:EditAllCells
      EndIf
   EndIf

   ASSIGN lOneRow VALUE lOneRow TYPE "L" DEFAULT .T.

   lSomethingEdited := .F.

   Do While nCol >= 1 .AND. nCol <= Len( ::aHeaders )
      _OOHG_ThisItemCellValue := ::Cell( nRow, nCol )

      If ::IsColumnReadOnly( nCol, nRow )
         // Read only column
      ElseIf ! ::IsColumnWhen( nCol, nRow )
         // WHEN Returned .F.
      ElseIf AScan( ::aHiddenCols, nCol ) > 0
        // Hidden column
      Else
         ::lCalledFromClass := .T.
         lRet := ::EditCell( nRow, nCol, , , , , , .F. )
         ::lCalledFromClass := .F.

         If ::lAppendMode
            ::lAppendMode := .F.
            If lRet
               ::DoEvent( ::OnAppend, "APPEND", { nRow } )
               lSomethingEdited := .T.
            Else
               Exit
            EndIf
         ElseIf lRet
            lSomethingEdited := .T.
         Else
            Exit
         EndIf

         If ::bPosition == 9                     // MOUSE EXIT
            // Edition window lost focus, resume clic processing and process delayed click
            ::bPosition := 0
            If ::nDelayedClick[ 1 ] > 0
               // A click message was delayed
               If ::nDelayedClick[ 3 ] <= 0
                  ::SetControlValue( ::nDelayedClick[ 1 ], ::nDelayedClick[ 2 ] )           // Second parameter is needed by TGridByCell:EditAllCells
               EndIf

               If ::nDelayedClick[ 4 ] == NIL
                  If HB_IsBlock( ::OnClick )
                     If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                        If ! ::NestedClick
                           ::NestedClick := ! _OOHG_NestedSameEvent()
                           ::DoEventMouseCoords( ::OnClick, "CLICK" )
                           ::NestedClick := .F.
                        EndIf
                     EndIf
                  EndIf
               Else
                  If HB_IsBlock( ::OnRClick )
                     If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                        ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
                     EndIf
                  EndIf
               EndIf

               If ::nDelayedClick[ 3 ] > 0
                  // change check mark
                  ::CheckItem( ::nDelayedClick[ 3 ], ! ::CheckItem( ::nDelayedClick[ 3 ] ) )
               EndIf

               // fire context menu
               If ! ::nDelayedClick[ 4 ] == NIL .AND. ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0 )
                  ::ContextMenu:Cargo := ::nDelayedClick[ 4 ]
                  ::ContextMenu:Activate()
               EndIf
            EndIf
            Exit
         EndIf
      EndIf

      nCol := ::NextColInOrder( nCol )
      If nCol > 0
         ::SetControlValue( nRow, nCol )           // Needed by TGridByCell:EditAllCells
      ElseIf lOneRow
         Exit
      ElseIf nRow < ::ItemCount
         nRow ++
         nCol := ::FirstColInOrder
         If nCol == 0
            Exit
         EndIf
         ::SetControlValue( nRow, nCol )           // Needed by TGridByCell:EditAllCells
         ::ScrollToLeft()
      ElseIf lAppend .OR. ::AllowAppend
         nCol := ::FirstColInOrder
         If nCol == 0
            Exit
         EndIf
         ::lAppendMode := .T.
         ::InsertBlank( ::ItemCount + 1 )
         nRow := ::ItemCount
         ::SetControlValue( nRow, nCol )           // Needed by TGridByCell:EditAllCells
         ::ScrollToLeft()
      Else
         Exit
      EndIf
   EndDo

   ::ScrollToLeft()

   Return lSomethingEdited

FUNCTION _OOHG_TGrid_Events2( Self, hWnd, nMsg, wParam, lParam ) // CLASS TGrid

   Local aCellData, nItem, i, aPos

   If nMsg == WM_LBUTTONDBLCLK
      If  ! ::lCheckBoxes .OR. ListView_HitOnCheckBox( hWnd, GetCursorRow() - GetWindowRow( hWnd ), GetCursorCol() - GetWindowCol( hWnd ) ) <= 0
         _PushEventInfo()
         _OOHG_ThisForm := ::Parent
         _OOHG_ThisType := 'C'
         _OOHG_ThisControl := Self

         // Identify item & subitem hitted
         aPos := Get_XY_LPARAM( lParam )
         aPos := ListView_HitTest( ::hWnd, aPos[ 1 ], aPos[ 2 ] )

         aCellData := _GetGridCellData( Self, aPos )
         _OOHG_ThisItemRowIndex   := aCellData[ 1 ]
         _OOHG_ThisItemColIndex   := aCellData[ 2 ]
         _OOHG_ThisItemCellRow    := aCellData[ 3 ]
         _OOHG_ThisItemCellCol    := aCellData[ 4 ]
         _OOHG_ThisItemCellWidth  := aCellData[ 5 ]
         _OOHG_ThisItemCellHeight := aCellData[ 6 ]
         _OOHG_ThisItemCellValue  := ::Cell( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex )

         If ! ::AllowEdit .OR. _OOHG_ThisItemRowIndex < 1 .OR. _OOHG_ThisItemRowIndex > ::ItemCount .OR. _OOHG_ThisItemColIndex < 1 .OR. _OOHG_ThisItemColIndex > Len( ::aHeaders )
            If HB_IsBlock( ::OnDblClick )
               ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
            EndIf
         ElseIf ::FullMove
            If ::IsColumnReadOnly( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
               // Cell is readonly
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            ElseIf ! ::IsColumnWhen( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
               // WHEN returned .F.
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            ElseIf AScan( ::aHiddenCols, _OOHG_ThisItemColIndex ) > 0
               // Hidden column
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            Else
               ::EditGrid( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex )
            EndIf
         ElseIf ::InPlace
            If ::IsColumnReadOnly( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
               // Cell is readonly
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            ElseIf ! ::IsColumnWhen( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
               // WHEN returned .F.
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            ElseIf AScan( ::aHiddenCols, _OOHG_ThisItemColIndex ) > 0
              // Hidden column
               If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
                  ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
               EndIf
            Else
               ::EditCell( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex )
            EndIf
         Else
            ::EditItem()
         EndIf

         _ClearThisCellInfo()
         _PopEventInfo()
      EndIf
      Return 0

   ElseIf nMsg == WM_MOUSEWHEEL
      If GET_WHEEL_DELTA_WPARAM( wParam ) > 0
         ::Up()
      Else
         ::Down()
      EndIf
      Return 1

   ElseIf nMsg == WM_CHAR
      If wParam < 32
         ::cText := ""
         Return 0
      ElseIf Empty( ::cText )
         ::uIniTime := HB_MilliSeconds()
         ::cText := Upper( Chr( wParam ) )
      ElseIf HB_MilliSeconds() > ::uIniTime + ::SearchLapse
         ::uIniTime := HB_MilliSeconds()
         ::cText := Upper( Chr( wParam ) )
      Else
         ::uIniTime := HB_MilliSeconds()
         ::cText += Upper( Chr( wParam ) )
      EndIf

      If ::SearchCol >= 1
         nItem := 0

         If ::SearchCol <= ::ColumnCount .AND. AScan( ::aHiddenCols, ::SearchCol ) == 0
            For i := ::FirstSelectedItem + 1 To ::ItemCount
               If Upper( Left( ::CellCaption( i, ::SearchCol ), Len( ::cText ) ) ) == ::cText
                  nItem := i
                  Exit
               EndIf
            Next i

            If nItem == 0 .AND. ::SearchWrap
               For i := 1 To ::FirstSelectedItem
                 If Upper( Left( ::CellCaption( i, ::SearchCol ), Len( ::cText ) ) ) == ::cText
                    nItem := i
                    Exit
                 EndIf
               Next i
            EndIf
         EndIf
      Else
         nItem := ListView_FindItem( hWnd, ::FirstSelectedItem - 2, ::cText, ::SearchWrap )
      EndIf
      If nItem > 0
         ::SetControlValue( nItem )
      EndIf
      Return 0

   EndIf

   Return Nil

FUNCTION _OOHG_TGrid_Notify2( Self, wParam, lParam ) // CLASS TGrid

   Local nNotify, nColumn, lGo, nNewWidth, nResul, aRect

   nNotify := GetNotifyCode( lParam )
   nColumn := NMHeader_iItem( lParam )

   If nNotify == HDN_BEGINDRAG
      // The user has begun dragging a column
      If HB_IsLogical( ::AllowMoveColumn ) .AND. ! ::AllowMoveColumn
         // Prevent the action
         Return 1
      EndIf

      If HB_IsBlock( ::bBeforeColMove )
         lGo := Eval( ::bBeforeColMove, nColumn )
         If HB_IsLogical( lGo ) .and. ! lGo
            // Prevent the action
            Return 1
         EndIf
      EndIf

   ElseIf nNotify == HDN_ENDDRAG
      // The user has finished dragging a column
      If HB_IsBlock( ::bAfterColMove )
         // HDITEM_iOrder() Returns the destination position in the header
         lGo := Eval( ::bAfterColMove, nColumn, HDITEM_iOrder( lParam ) )
         If HB_IsLogical( lGo ) .and. ! lGo
            // Prevent the action so the column remains in it's original place
            Return 1
         EndIf
      EndIf

   ElseIf nNotify == HDN_BEGINTRACK
      // The user has begun dragging a column divider
      If HB_IsLogical( ::AllowChangeSize ) .AND. ! ::AllowChangeSize
         // Prevent the action
         Return 1
      EndIf

      // Is a hidden column ?
      If AScan( ::aHiddenCols, nColumn ) > 0
         // Prevent the action
         Return 1
      EndIf

      If HB_IsBlock( ::bBeforeColSize )
         lGo := Eval( ::bBeforeColSize, nColumn )
         If HB_IsLogical( lGo ) .and. ! lGo
            // Prevent the action
            Return 1
         EndIf
      EndIf

      /*
         Notification sequence:
            for XP, Win7 with manifest
               when user starts dragging
                  HDN_BEGINTRACK
               while tracking goes on
                  HDN_ITEMCHANGING
                  HDN_ITEMCHANGED
               when user releases the mouse button
                  HDN_ENDTRACK
                  HDN_ITEMCHANGING
                  HDN_ITEMCHANGED
                  NM_RELEASEDCAPTURE

            for Win7 without manifest
               when user starts dragging
                  HDN_BEGINTRACK
               while tracking goes on
                  HDN_TRACK
               when user releases the mouse button
                  HDN_ENDTRACK
                  HDN_ITEMCHANGING
                  HDN_ITEMCHANGED
                  NM_RELEASEDCAPTURE
      */

      // Set HDN_BEGINTRACK flag and reset others
      ::lBeginTrack      := .T.
      ::lEndTrack        := .F.
      ::lDividerDblclick := .F.
      ::lTracking        := .F.
      ::nVisibleItems    := ::CountPerPage()

   ElseIf nNotify == HDN_ENDTRACK
      // The user has finished dragging a column divider but the new width is not set yet
      If HB_IsBlock( ::bAfterColSize )
         // HDITEM_cxy() gets the user's selected width from lParam
         nNewWidth := Eval( ::bAfterColSize, nColumn, HDITEM_cxy( lParam ) )
         If HB_IsNumeric( nNewWidth ) .and. nNewWidth >= 0
            // Set_HDITEM_cxy() sets the Returned width into lParam
            Set_HDITEM_cxy( lParam, nNewWidth )
         EndIf
      EndIf

      // Set HDN_ENDTRACK flag
      ::lEndTrack := .T.

   ElseIf nNotify == HDN_TRACK
      // A column divider is been dragged under Win7 without manifest
      ::lTracking := .T.

   ElseIf nNotify == HDN_DIVIDERDBLCLICK
      If HB_IsLogical( ::AllowChangeSize ) .AND. ! ::AllowChangeSize
         // Prevent column autofit
         Return 1
      EndIf

      If HB_IsBlock( ::bBeforeAutofit )
         lGo := Eval( ::bBeforeAutofit, nColumn )
         If HB_IsLogical( lGo ) .and. ! lGo
            // Prevent column autofit
            Return 1
         EndIf
      EndIf

      /*
         Notification sequence for XP and Win7 with/without manifest:
            when the user doubleclicks a header separator
               HDN_BEGINTRACK
               HDN_ENDTRACK
               HDN_ITEMCHANGING
               HDN_ITEMCHANGED
               NM_RELEASEDCAPTURE
               HDN_DIVIDERDBLCLICK
               HDN_ITEMCHANGING
               HDN_ITEMCHANGED
      */

      // Set HDN_DIVIDERDBLCLICK flag
      ::lDividerDblclick := .T.

   ElseIf nNotify == HDN_ITEMCHANGING
     If ::lBeginTrack .AND. ! ::lEndTrack
        // A column divider is been dragged under XP or Win7 with manifest
        ::lTracking := .T.
     EndIf

   ElseIf nNotify == HDN_ITEMCHANGED
      If ::lDividerDblclick
         ::lDividerDblclick := .F.
         // Do default processing (needed to properly update header)
         nResul := ExecOldWndProc( ::hWnd, WM_NOTIFY, wParam, lParam )

         // Ensure column is visible
         aRect := ListView_GetSubitemRect( ::hWnd, 0, nColumn - 1 )     // top, left, width, height
         If aRect[ 2 ] < 0
            ListView_Scroll( ::hWnd, aRect[ 2 ], 0 )
         EndIf

         // Force the repaint of the last row in case the horizontal scrollbar became hidden
         If ::nVisibleItems # ::CountPerPage()
            ::Refresh()
         EndIf

         // Repaint the grid
         RedrawWindow( ::ContainerhWnd )

         // Update column's width in array
         _OOHG_GridArrayWidths( ::hWnd, ::aWidths )

         //Prevent default processing
         Return nResul
      EndIf

   ElseIf nNotify == NM_RELEASEDCAPTURE
      If ::lTracking
         ::lTracking := .F.
         // Forces the repaint of the last row in case the horizontal scrollbar became hidden
         If ::nVisibleItems # ::CountPerPage()
            ::Refresh()
         EndIf

         // Repaint the grid
         RedrawWindow( ::ContainerhWnd )

         // Update column's width in array
         _OOHG_GridArrayWidths( ::hWnd, ::aWidths )
      EndIf

   ElseIf nNotify == NM_RCLICK
      If HB_IsBlock( ::bHeadRClick )
         nColumn := Header_HitTest( SendMessage( ::hWnd, LVM_GETHEADER, 0, 0 ) )
         Eval( ::bHeadRClick, nColumn, Self )
      EndIf
      // Prevent propagation to ::Events_Notify()
      Return 1

   EndIf

   Return Nil

METHOD Events_Enter() CLASS TGrid

   If ! ::lNestedEdit
      ::lNestedEdit := .T.
      ::cText := ""
      If ! ::AllowEdit
         ::DoEvent( ::OnEnter, "ENTER" )
      ElseIf ::FullMove
         ::EditGrid()
      ElseIf ::InPlace
         ::EditAllCells()
      Else
         ::EditItem()
      EndIf
      ::lNestedEdit := .F.
   EndIf

   Return Self

METHOD Events_Notify( wParam, lParam ) CLASS TGrid

   Local nNotify := GetNotifyCode( lParam )
   Local lvc, _ThisQueryTemp, nvkey, uValue, lGo, aItem

   If nNotify == NM_CUSTOMDRAW
      Return TGrid_Notify_CustomDraw( Self, lParam, .F., , , ::lCheckBoxes, ::lFocusRect, ::lNoGrid, ::lPLM )

   ElseIf nNotify == LVN_KEYDOWN
      If GetGridvKeyAsChar( lParam ) == 0
         ::cText := ""
      EndIf

      nvKey := GetGridvKey( lParam )

      If nvkey == VK_DOWN
         If ::FirstSelectedItem == ::ItemCount
            ::AppendItem()
            Return Nil
         EndIf
      ElseIf nvkey == VK_SPACE .AND. ::lCheckBoxes
         // detect item
         uValue := ::FirstSelectedItem
         If uValue > 0
            // change check mark
            ::CheckItem( uValue, ! ::CheckItem( uValue ) )
            // skip default action
            Return 1
         EndIf
      ElseIf nvKey == VK_DELETE .AND. ::AllowDelete
         // detect item
         uValue := ::FirstSelectedItem
         If uValue > 0
            If ValType( ::bDelWhen ) == "B"
               lGo := _OOHG_EVAL( ::bDelWhen )
            Else
               lGo := .t.
            EndIf

            If lGo
               If ::lNoDelMsg .OR. MsgYesNo( _OOHG_Messages(4, 1), _OOHG_Messages(4, 3) )
                  aItem := ::Item( uValue )
                  ::DeleteItem( uValue )
                  ::Value := Min( uValue, ::ItemCount )
                  ::DoEvent( ::OnDelete, "DELETE", { aItem } )
               EndIf
            ElseIf ! Empty( ::DelMsg )
               MsgExclamation( ::DelMsg, _OOHG_Messages(4, 3) )
            EndIf
         Endif
      ElseIf nvKey == VK_A .AND. GetKeyFlagState() == MOD_ALT
         If ::lAppendOnAltA
            ::AppendItem()
            Return Nil
         EndIf
      EndIf

   ElseIf nNotify == LVN_GETDISPINFO

      // Grid OnQueryData ............................

      If HB_IsBlock( ::OnDispInfo )

         _PushEventInfo()
         _OOHG_ThisForm := ::Parent
         _OOHG_ThisType := 'C'
         _OOHG_ThisControl := Self
         _ThisQueryTemp  := GetGridDispInfoIndex( lParam )
         _OOHG_ThisQueryRowIndex  := _ThisQueryTemp[ 1 ]
         _OOHG_ThisQueryColIndex  := _ThisQueryTemp[ 2 ]
         ::DoEvent( ::OnDispInfo, "DISPINFO" )
         If HB_IsNumeric( _OOHG_ThisQueryData )
            SetGridQueryImage ( lParam, _OOHG_ThisQueryData )
         ElseIf ValType( _OOHG_ThisQueryData ) $ "CM"
            SetGridQueryData ( lParam, _OOHG_ThisQueryData )
         EndIf
         _OOHG_ThisQueryRowIndex  := 0
         _OOHG_ThisQueryColIndex  := 0
         _OOHG_ThisQueryData := ""
         _PopEventInfo()
      EndIf

   ElseIf nNotify == LVN_ITEMCHANGED
      If GetGridOldState( lParam ) == 0 .AND. GetGridNewState( lParam ) != 0
         If ::bPosition # -2 .AND. ::bPosition # 9
            ::DoChange()
         EndIf
         Return Nil
      EndIf

   ElseIf nNotify == LVN_COLUMNCLICK
      lvc := GetGridColumn( lParam ) + 1
      If HB_IsBlock( ::aHeadClick[ lvc ] )
         _SetThisCellInfo( ::hWnd, 0, lvc )
         ::DoEvent( ::aHeadClick[ lvc ], "HEADCLICK", { lvc } )
         _ClearThisCellInfo()
         Return Nil
      EndIf

   ElseIf nNotify == LVN_ENDSCROLL
      // There is a bug in ListView under XP that causes the gridlines to be
      // incorrectly scrolled when the left button is clicked to scroll.
      // This is supposedly documented at KB 813791.
      RedrawWindow( ::hWnd )

   ElseIf nNotify == NM_CLICK
      If ::lCheckBoxes
         // detect item
         uValue := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      Else
         uValue := 0
      EndIf

      If ::bPosition == -2 .OR. ::bPosition == 9
         ::nDelayedClick := { ::FirstSelectedItem, 0, uValue, Nil }
         If ::nEditRow > 0
            ListView_SetCursel( ::hWnd, ::nEditRow )
         Else
            ListView_ClearCursel( ::hWnd )
         EndIf
      Else
         If HB_IsBlock( ::OnClick )
            If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. uValue <= 0
               If ! ::NestedClick
                  ::NestedClick := ! _OOHG_NestedSameEvent()
                  ::DoEventMouseCoords( ::OnClick, "CLICK" )
                  ::NestedClick := .F.
               EndIf
            EndIf
         EndIf

         If uValue > 0
            // change check mark
            ::CheckItem( uValue, ! ::CheckItem( uValue ) )
         ElseIf uValue < 0
            // select item
            ::SetControlValue( ListView_ItemActivate( lParam )[ 1 ] )
         EndIf
      EndIf

      // skip default action
      Return 1

   ElseIf nNotify == NM_RCLICK
      If ::lCheckBoxes
         // detect item
         uValue := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      Else
         uValue := 0
      EndIf

      If ::bPosition == -2 .OR. ::bPosition == 9
         ::nDelayedClick := { ::FirstSelectedItem, 0, uValue, _GetGridCellData( Self, ListView_ItemActivate( lParam ) ) }
         If ::nEditRow > 0
            ListView_SetCursel( ::hWnd, ::nEditRow )
         Else
            ListView_ClearCursel( ::hWnd )
         EndIf
      Else
         If HB_IsBlock( ::OnRClick )
            If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. uValue <= 0
               ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
            EndIf
         EndIf

         If uValue > 0
            // change check mark
            ::CheckItem( uValue, ! ::CheckItem( uValue ) )
         ElseIf uValue < 0
            // select item
            ::SetControlValue( ListView_ItemActivate( lParam )[ 1 ] )
         EndIf

         // fire context menu
         If ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. uValue <= 0 )
            ::ContextMenu:Cargo := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
            ::ContextMenu:Activate()
         EndIf
      EndIf

     // skip default action
      Return 1

   EndIf

   Return ::Super:Events_Notify( wParam, lParam )

METHOD AddItem( aRow, uForeColor, uBackColor ) CLASS TGrid

   Local aText

   If Len( ::aHeaders ) != Len( aRow )
      MsgOOHGError( "Grid.AddItem: Item size mismatch. Program terminated." )
   EndIf

   aText := TGrid_SetArray( Self, aRow )
   ::SetItemColor( ::ItemCount + 1, uForeColor, uBackColor, aRow )

   Return AddListViewItems( ::hWnd, aText )

METHOD InsertItem( nItem, aRow, uForeColor, uBackColor ) CLASS TGrid

   Local aText

   /*
    * This method may change the selected item's number if the new item is
    * inserted before or at the position of the selected item. For example:
    * ::FirstSelectedItem is 10, after inserting a new item at 5
    * ::FirestSelecteItem is 11. This is equivalent to ::Value == 10
    * before insertion and ::Value == 11 after.
    * This method does not trigger ::DoChange() because the selected item
    * is not changed.
    */

   If Len( ::aHeaders ) != Len( aRow )
      MsgOOHGError( "Grid.InsertItem: Item size mismatch. Program terminated." )
   EndIf

   aText := TGrid_SetArray( Self, aRow )
   nItem := ::InsertBlank( nItem )
   If nItem > 0
      ::SetItemColor( nItem, uForeColor, uBackColor, aRow )
      ListViewSetItem( ::hWnd, aText, nItem )
   EndIf

   Return nItem

METHOD InsertBlank( nItem ) CLASS TGrid

   Local aGrid

   /*
    * This method may change the selected item's number if the new item is
    * inserted before or at the position of the selected item. For example:
    * ::FirstSelectedItem is 10, after inserting a new item at 5
    * ::FirstSelectedItem is 11. This is equivalent to ::Value == 10
    * before insertion and ::Value == 11 after.
    * This method does not trigger ::DoChange() because the selected item
    * is not changed.
    */

   aGrid := ::GridForeColor
   If HB_IsArray( aGrid ) .AND. Len( aGrid ) >= nItem
      AAdd( aGrid, Nil )
      AIns( aGrid, nItem )
   EndIf
   aGrid := ::GridBackColor
   If HB_IsArray( aGrid ) .AND. Len( aGrid ) >= nItem
      AAdd( aGrid, Nil )
      AIns( aGrid, nItem )
   EndIf

   nItem := InsertListViewItem( ::hWnd, Array( Len( ::aHeaders ) ), nItem )

   ::DoEvent( ::OnInsert, "INSERT", { nItem } )

   Return nItem

METHOD DeleteItem( nItem ) CLASS TGrid

   Local lRet

   /*
    * This method may change the selected item's number if the deleted item
    * precedes the selected item. For example:
    * ::FirstSelectedItem is 10, after deleting item at 5 ::FirestSelecteItem is 9.
    * This is equivalent to ::Value == 10 before deletion and ::Value == 9 after.
    * In this case, this method does not trigger ::DoChange() because the selected
    * item is not changed.
    * If the deleted item is the selected item, ::FirstSelectedItem and ::Value
    * become 0. ::DoChange() is triggered only when ::lNoneUnsels is .T.
    */

   _OOHG_DeleteArrayItem( ::GridForeColor, nItem )
   _OOHG_DeleteArrayItem( ::GridBackColor, nItem )

   lRet := ListViewDeleteString( ::hWnd, nItem )

   If ::lNoneUnsels .AND. ::FirstSelectedItem == 0
      ::DoChange()
   EndIf

   Return lRet

METHOD Item( nItem, uValue, uForeColor, uBackColor ) CLASS TGrid

   Local nColumn, aTemp, oEditControl

   If PCount() > 1
      aTemp := TGrid_SetArray( Self, uValue )
      ::SetItemColor( nItem, uForeColor, uBackColor, uValue )
      ListViewSetItem( ::hWnd, aTemp, nItem )
   EndIf
   uValue := ListViewGetItem( ::hWnd, nItem, Len( ::aHeaders ) )
   If ::FixControls()
      For nColumn := 1 To Len( uValue )
         oEditControl := ::aEditControls[ nColumn ]
         If HB_IsObject( oEditControl )
            If oEditControl:Type == "TGRIDCONTROLIMAGEDATA"
               // when the column has images, ListViewGetItem Returns only the image's index number
               uValue[ nColumn ] := { ::CellCaption( nItem, nColumn ), ::CellImage( nItem, nColumn ) }
            EndIf
            uValue[ nColumn ] := oEditControl:Str2Val( uValue[ nColumn ] )
         EndIf
      Next
   Else
      ::aEditControls := Array( Len( uValue ) )
      If HB_IsArray( ::EditControls )
         For nColumn := 1 To Len( uValue )
            oEditControl := GetEditControlFromArray( Nil, ::EditControls, nColumn, Self )
            ::aEditControls[ nColumn ] := oEditControl
            If HB_IsObject( oEditControl )
               If oEditControl:Type == "TGRIDCONTROLIMAGEDATA"
                  // when the column has images, ListViewGetItem Returns only the image's index number
                  uValue[ nColumn ] := { ::CellCaption( nItem, nColumn ), ::CellImage( nItem, nColumn ) }
               EndIf
               uValue[ nColumn ] := oEditControl:Str2Val( uValue[ nColumn ] )
            EndIf
         Next
      EndIf
   EndIf

   Return uValue

FUNCTION TGrid_SetArray( Self, uValue )

   Local aTemp, nColumn, xValue, oEditControl

   aTemp := Array( Len( uValue ) )
   If ::FixControls()
      For nColumn := 1 To Len( uValue )
         xValue := uValue[ nColumn ]
         oEditControl := ::aEditControls[ nColumn ]
         If HB_IsObject( oEditControl )
            aTemp[ nColumn ] := oEditControl:GridValue( xValue )
         ElseIf ValType( ::Picture[ nColumn ] ) $ "CM"
            aTemp[ nColumn ] := Trim( Transform( xValue, ::Picture[ nColumn ] ) )
         Else
            aTemp[ nColumn ] := xValue
         EndIf
      Next
   Else
      ::aEditControls := Array( Len( uValue ) )
      For nColumn := 1 To Len( uValue )
         xValue := uValue[ nColumn ]
         oEditControl := GetEditControlFromArray( Nil, ::EditControls, nColumn, Self )
         ::aEditControls[ nColumn ] := oEditControl
         If HB_IsObject( oEditControl )
            aTemp[ nColumn ] := oEditControl:GridValue( xValue )
         ElseIf ValType( ::Picture[ nColumn ] ) $ "CM"
            aTemp[ nColumn ] := Trim( Transform( xValue, ::Picture[ nColumn ] ) )
         Else
            aTemp[ nColumn ] := xValue
         EndIf
      Next
   EndIf

   Return aTemp

METHOD SetItemColor( nItem, uForeColor, uBackColor, uExtra, lSetThisCellInfo ) CLASS TGrid

   Local nWidth

   nWidth := Len( ::aHeaders )
   If ! HB_IsArray( uExtra )
      uExtra := Array( nWidth )
   ElseIf Len( uExtra ) < nWidth
      ASize( uExtra, nWidth )
   EndIf
   ::GridForeColor := TGrid_CreateColorArray( ::GridForeColor, nItem, uForeColor, ::DynamicForeColor, nWidth, uExtra, ::hWnd, lSetThisCellInfo )
   ::GridBackColor := TGrid_CreateColorArray( ::GridBackColor, nItem, uBackColor, ::DynamicBackColor, nWidth, uExtra, ::hWnd, lSetThisCellInfo )

   Return Self

STATIC FUNCTION TGrid_CreateColorArray( aGrid, nItem, uColor, uDynamicColor, nWidth, uExtra, hWnd, lSetThisCellInfo )

   Local aTemp, nLen

   If ! ValType( uColor ) $ "ANB" .AND. ValType( uDynamicColor ) $ "ANB"
      uColor := uDynamicColor
   EndIf
   If ValType( uColor ) $ "ANB"
      If HB_IsArray( aGrid )
         If Len( aGrid ) < nItem
            ASize( aGrid, nItem )
         EndIf
      ELSE
         aGrid := Array( nItem )
      EndIf
      aTemp := Array( nWidth )
      If HB_IsArray( uColor ) .AND. Len( uColor ) < nWidth
         nLen := Len( uColor )
         uColor := AClone( uColor )
         If ValType( uDynamicColor ) $ "NB"
            ASize( uColor, nWidth )
            AFill( uColor, uDynamicColor, nLen + 1 )
         ElseIf HB_IsArray( uDynamicColor ) .AND. Len( uDynamicColor ) > nLen
            ASize( uColor, Min( nWidth, Len( uDynamicColor ) ) )
            AEval( uColor, { |x,i| uColor[ i ] := uDynamicColor[ i ], x }, nLen + 1 )
         EndIf
      EndIf
      If HB_IsLogical( lSetThisCellInfo ) .AND. ! lSetThisCellInfo
         // Set lSetThisCellInfo to .F. to avoid endless loop when calling this function inside the ON QUERYDATA block.
         AEval( aTemp, { |x,i| aTemp[ i ] := _OOHG_GetArrayItem( uColor, i, nItem, uExtra ), x } )
      Else
         AEval( aTemp, { |x,i| _SetThisCellInfo( hWnd, nItem, i, uExtra[ i ] ), aTemp[ i ] := _OOHG_GetArrayItem( uColor, i, nItem, uExtra ), x } )
         _ClearThisCellInfo()
      EndIf
      aGrid[ nItem ] := aTemp
   EndIf

   Return aGrid

METHOD Justify( uPar1, uPar2, uPar3 ) CLASS TGrid

   LOCAL uRet, aNew, i, nLen

/*
 * Expected params:
 *   For multiple columns change:
 *      uPar1 -> array of BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT or BROWSE_JTFY_CENTER.
 *               Note that invalid items are not changed.
 *      uPar2 -> .T. to force the control's redraw, defaults to .F.
 *      uPar3 -> not needed, it's ignored.
 *   For single column change:
 *      uPar1 -> numeric >= 1 and <= Len( ::aHeaders ).
 *      uPar2 -> BROWSE_JTFY_LEFT, BROWSE_JTFY_RIGHT OR BROWSE_JTFY_CENTER.
 *      uPar3 -> .T. to force the control's redraw, defaults to .F.
 *   For single column retrieve:
 *      uPar1 -> numeric >= 1 and <= Len( ::aHeaders ).
 *      uPar2 -> ommited.
 *      uPar3 -> not needed, it's ignored.
 *   For multiple columns retrieve:
 *      None.
 *
 * Return value:
 *   For multiple columns change:
 *      A copy of the resulting ::aJust property or a copy of the
 *      current ::aJust property if no change was made.
 *   For single column change:
 *      uPar2 if it was accepted by the control or column's current
 *      justification if it wasn't.
 *   For single column retrieve:
 *      uPar1's current justification.
 *   For multiple columns retrieve:
 *      A copy of the current ::aJust property.
 *   When uPar1 is not array nor a numeric:
 *      A copy of the current ::aJust property.
 *   When uPar1 is not a valid number:
 *      Nil.
 *   When uPar1 is a valid number and uPar2 is not a valid value:
 *      uPar1's current justification.
 */

   If HB_IsArray( uPar1 )
      aNew := aClone( uPar1 )
      nLen := Len( ::aHeaders )
      ASize( aNew, nLen )

      For i := 1 to nLen
         If HB_IsNumeric( aNew[i] )
            uRet := SetGridColumnJustify( ::hWnd, i, aNew[i] )
            If uRet != ::aJust[ i ]
               ::aJust[ i ] := uRet
            EndIf
         EndIf
      Next i

      uRet := aClone( ::aJust )
      If HB_IsLogical( uPar2 ) .AND. uPar2
         RedrawWindow( ::hWnd )
      EndIf
   ElseIf ! HB_IsNumeric( uPar1 )
      uRet := aClone( ::aJust )
   ElseIf uPar1 < 1 .OR. uPar1 > Len( ::aHeaders )
      uRet := Nil
   ElseIf ! HB_IsNumeric( uPar2 )
      uRet := ::aJust[ uPar1 ]
   Else
      uRet := SetGridColumnJustify( ::hWnd, uPar1, uPar2 )
      If uRet != ::aJust[ uPar1 ]
         ::aJust[ uPar1 ] := uRet
         If HB_IsLogical( uPar3 ) .AND. uPar3
            RedrawWindow( ::hWnd )
         EndIf
      EndIf
   EndIf

   Return uRet

METHOD Header( nColumn, uValue ) CLASS TGrid

   If ValType( uValue ) $ "CM"
      ::aHeaders[ nColumn ] := uValue
      SetGridColumnHeader( ::hWnd, nColumn, uValue )
   EndIf

   Return ::aHeaders[ nColumn ]

METHOD HeaderImage( nColumn, nImg ) CLASS TGrid

   If HB_IsNumeric( nImg ) .AND. nImg >= 0 .AND. nImg # ::aHeaderImage[ nColumn ]
      ::aHeaderImage[ nColumn ] := nImg

      If nImg == 0
        RemoveGridColumnImage( ::hWnd, nColumn )
      ElseIf ValidHandler( ::HeaderImageList )
        SetGridColumnImage( ::hWnd, nColumn, nImg, .F. )
      EndIf
   EndIf

   Return ::aHeaderImage[ nColumn ]

METHOD HeaderImageAlign( nColumn, nPlace ) CLASS TGrid

   If ::aHeaderImage[ nColumn ] != 0
      If HB_IsNumeric( nPlace )
         If nPlace == HEADER_IMG_AT_RIGHT
            ::aHeaderImageAlign[ nColumn ] := HEADER_IMG_AT_RIGHT

            If ValidHandler( ::HeaderImageList )
               SetGridColumnImage( ::hWnd, nColumn, ::aHeaderImage[ nColumn ], .T. )
            EndIf
         ELSE
            ::aHeaderImageAlign[ nColumn ] := HEADER_IMG_AT_LEFT

            If ValidHandler( ::HeaderImageList )
               SetGridColumnImage( ::hWnd, nColumn, ::aHeaderImage[ nColumn ], .F. )
            EndIf
         EndIf
      EndIf
   EndIf

   Return ::aHeaderImageAlign[ nColumn ]

METHOD HeaderSetFont( cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout, nFntAngle, nFntwidth ) CLASS TGrid

   Local HeaderHandle

   If ValidHandler( ::HeaderFontHandle )
      DeleteObject( ::HeaderFontHandle )
   EndIf
   ASSIGN cFontName  VALUE cFontName  TYPE "CM" DEFAULT ""
   ASSIGN nFontSize  VALUE nFontSize  TYPE "N"  DEFAULT 0
   ASSIGN lBold      VALUE lBold      TYPE "L"  DEFAULT .F.
   ASSIGN lItalic    VALUE lItalic    TYPE "L"  DEFAULT .F.
   ASSIGN lUnderline VALUE lUnderline TYPE "L"  DEFAULT .F.
   ASSIGN lStrikeout VALUE lStrikeout TYPE "L"  DEFAULT .F.
   ASSIGN nFntAngle  VALUE nFntAngle  TYPE "N"  DEFAULT 0
   ASSIGN nFntWidth  VALUE nFntWidth  TYPE "N"  DEFAULT 0
   HeaderHandle := GetHeader( ::hWnd )
   If ValidHandler( HeaderHandle )
      ::HeaderFontHandle := _SetFont( HeaderHandle, cFontName, nFontSize, lBold, lItalic, lUnderline, lStrikeout, nFntAngle, nFntWidth )
   EndIf

   Return Self

METHOD Release() CLASS TGrid

   If ValidHandler( ::HeaderImageList )
      ImageList_Destroy( ::HeaderImageList )
      ::HeaderImageList := 0
   EndIf

   If ValidHandler( ::HeaderFontHandle)
      DeleteObject( ::HeaderFontHandle )
      ::HeaderFontHandle := 0
   EndIf

   Return ::Super:Release()

METHOD SetRangeColor( uForeColor, uBackColor, nTop, nLeft, nBottom, nRight ) CLASS TGrid

   Local nAux, nLong := ::ItemCount

   If ! HB_IsNumeric( nBottom )
      nBottom := nTop
   EndIf
   If ! HB_IsNumeric( nRight )
      nRight := nLeft
   EndIf
   If nTop > nBottom
      nAux := nBottom
      nBottom := nTop
      nTop := nAux
   EndIf
   If nLeft > nRight
      nAux := nRight
      nRight := nLeft
      nLeft := nAux
   EndIf
   If nBottom > nLong
      nBottom := nLong
   EndIf
   If nRight > Len( ::aHeaders )
      nRight := Len( ::aHeaders )
   EndIf
   If nTop <= nLong .AND. nLeft <= Len( ::aHeaders ) .AND. nTop >= 1 .AND. nLeft >= 1
      ::GridForeColor := TGrid_FillColorArea( ::GridForeColor, uForeColor, nTop, nLeft, nBottom, nRight, ::hWnd )
      ::GridBackColor := TGrid_FillColorArea( ::GridBackColor, uBackColor, nTop, nLeft, nBottom, nRight, ::hWnd )
   EndIf

   Return Self

STATIC FUNCTION TGrid_FillColorArea( aGrid, uColor, nTop, nLeft, nBottom, nRight, hWnd )

   Local nAux

   If ValType( uColor ) $ "ANB"
      If ! HB_IsArray( aGrid )
         aGrid := Array( nBottom )
      ElseIf Len( aGrid ) < nBottom
         ASize( aGrid, nBottom )
      EndIf
      For nAux := nTop To nBottom
         If ! HB_IsArray( aGrid[ nAux ] )
            aGrid[ nAux ] := Array( nRight )
         ElseIf Len( aGrid[ nAux ] ) < nRight
            ASize( aGrid[ nAux ], nRight )
         EndIf
         AEval( aGrid[ nAux ], { |x,i| _SetThisCellInfo( hWnd, nAux, i ), aGrid[ nAux ][ i ] := _OOHG_GetArrayItem( uColor, i, nAux ), x }, nLeft, ( nRight - nLeft + 1 ) )
         _ClearThisCellInfo()
      Next
   EndIf

   Return aGrid

METHOD ColumnWidth( nColumn, nWidth ) CLASS TGrid

   Local i

   If HB_IsNumeric( nColumn ) .AND. nColumn >= 1 .AND. nColumn <= Len( ::aHeaders )
      If HB_IsNumeric( nWidth ) .AND. nWidth >= 0
         If nWidth == 0
            If AScan( ::aHiddenCols, nColumn ) == 0
               AAdd( ::aHiddenCols, nColumn )
            EndIf
         Else
            i := AScan( ::aHiddenCols, nColumn )
            If i # 0
               _OOHG_DeleteArrayItem( ::aHiddenCols, i )
            EndIf
         EndIf
         nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, nWidth )
      Else
         nWidth := ListView_GetColumnWidth( ::hWnd, nColumn - 1 )
      EndIf
      ::aWidths[ nColumn ] := nWidth
   Else
      nWidth := 0
   EndIf

   Return nWidth

METHOD ColumnAutoFit( nColumn ) CLASS TGrid

   Local nWidth

   If HB_IsNumeric( nColumn ) .AND. nColumn >= 1 .AND. nColumn <= Len( ::aHeaders )
      nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, LVSCW_AUTOSIZE )
      If nColumn == ::FirstColInOrder
         nWidth := nWidth + 6
         nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, nWidth )
      EndIf
      ::aWidths[ nColumn ] := nWidth
   Else
      nWidth := 0
   EndIf

   Return nWidth

METHOD ColumnAutoFitH( nColumn ) CLASS TGrid

   Local nWidth

   If HB_IsNumeric( nColumn ) .AND. nColumn >= 1 .AND. nColumn <= Len( ::aHeaders )
      nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, LVSCW_AUTOSIZE_USEHEADER )
      If nColumn == ::FirstColInOrder
         nWidth := nWidth + 6
         nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, nWidth )
      EndIf
      ::aWidths[ nColumn ] := nWidth
   Else
      nWidth := 0
   EndIf

   Return nWidth

METHOD ColumnsBetterAutoFit() CLASS TGrid

   Local nColumn

   For nColumn := 1 To Len( ::aHeaders )
       ::ColumnBetterAutoFit ( nColumn )
   Next nColumn

   Return Self

METHOD ColumnsAutoFit() CLASS TGrid

   Local nColumn, nWidth

   For nColumn := 1 To Len( ::aHeaders )
      nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, LVSCW_AUTOSIZE )
      ::aWidths[ nColumn ] := nWidth
   Next

   Return nWidth

METHOD ColumnsAutoFitH() CLASS TGrid

   Local nColumn, nWidth

   For nColumn := 1 To Len( ::aHeaders )
      nWidth := ListView_SetColumnWidth( ::hWnd, nColumn - 1, LVSCW_AUTOSIZE_USEHEADER )
      ::aWidths[ nColumn ] := nWidth
   Next

   Return nWidth

METHOD SortColumn( nColumn, lDescending ) CLASS TGrid

   Return ListView_SortItemsEx( ::hWnd, nColumn, lDescending )

METHOD SortItems( bBlock ) CLASS TGrid

   Local lRet := .F.

   If HB_IsBlock( bBlock )
      ::bCompareItems := bBlock
      lRet := ListView_SortItemsEx_User( Self )
   EndIf

   Return lRet

METHOD CompareItems( nItem1, nItem2 ) CLASS TGrid

   // Must Return -1 if nItem1 precedes nItem2 or 1 if nItem1 follows nItem2

   Return Eval( ::bCompareItems, Self, nItem1, nItem2 )

METHOD ItemHeight() CLASS TGrid

   Local aCellRect

   If ::ItemCount == 0
     Return 0
   EndIf
   aCellRect := ListView_GetSubitemRect( ::hWnd, 0, 0 )

   Return aCellRect[ 4 ]

METHOD ScrollToLeft CLASS TGrid

   ListView_Scroll( ::hWnd, - _OOHG_GridArrayWidths( ::hWnd, ::aWidths ), 0 )

   Return Self

METHOD ScrollToRight CLASS TGrid

   ListView_Scroll( ::hWnd, _OOHG_GridArrayWidths( ::hWnd, ::aWidths ), 0 )

   Return Self

METHOD ScrollToCol( nCol ) CLASS TGrid

   Local r

   r := ListView_GetSubitemRect( ::hWnd, 0, nCol - 1 ) // top, left, width, height
   If r[ 2 ] # 0
      ListView_Scroll( ::hWnd, r[ 2 ], 0 )
   EndIf

   Return Self

METHOD ScrollToPrior CLASS TGrid

   Local nColF, nColT, nColN

   nColF := ::FirstVisibleColumn( .F. )
   If nColF > 0
      nColT := ::FirstVisibleColumn( .T. )
      If nColT # nColF
        ::ScrollToCol( nColF )
      Else
         nColN := ::PriorColInOrder( nColF )
         If nColN # 0
            ::ScrollToCol( nColN )
         EndIf
      EndIf
   EndIf

   Return Self

METHOD ScrollToNext CLASS TGrid

   Local nColF, nColN

   nColF := ::FirstVisibleColumn( .F. )
   If nColF > 0
      nColN := ::NextColInOrder( nColF )
      If nColN # 0
         ::ScrollToCol( nColN )
      EndIf
   EndIf

   Return Self

METHOD PriorColInOrder( nCol ) CLASS TGrid

   Local nRet, aColumnOrder, i

   nRet := 0
   aColumnOrder := ::ColumnOrder
   i := AScan( aColumnOrder, nCol )
   Do While i > 1
      If AScan( ::aHiddenCols, aColumnOrder[ i - 1 ] ) == 0
         nRet := aColumnOrder[ i - 1 ]
         Exit
      EndIf
      i --
   EndDo

   Return nRet

METHOD NextColInOrder( nCol ) CLASS TGrid

   Local nRet, aColumnOrder, i

   nRet := 0
   aColumnOrder := ::ColumnOrder
   i := AScan( aColumnOrder, nCol )
   Do While i < Len( aColumnOrder )
      If AScan( ::aHiddenCols, aColumnOrder[ i + 1 ] ) == 0
         nRet := aColumnOrder[ i + 1 ]
         Exit
      EndIf
      i ++
   EndDo

   Return nRet

METHOD FirstColInOrder() CLASS TGrid

   Local nRet, aColumnOrder, i

   nRet := 0
   aColumnOrder := ::ColumnOrder
   For i := 1 To Len( aColumnOrder )
      If AScan( ::aHiddenCols, aColumnOrder[ i ] ) == 0
         nRet := aColumnOrder[ i ]
         Exit
      EndIf
   Next i

   Return nRet

METHOD LastColInOrder() CLASS TGrid

   Local nRet, aColumnOrder, i

   nRet := 0
   aColumnOrder := ::ColumnOrder
   For i := Len( aColumnOrder ) To 1 Step -1
      If AScan( ::aHiddenCols, aColumnOrder[ i ] ) == 0
         nRet := aColumnOrder[ i ]
         Exit
      EndIf
   Next i

   Return nRet

METHOD AdjustResize( nDivh, nDivw, lSelfOnly ) CLASS TGrid

   Local nCols, i

   nCols := ::ColumnCount
   For i := 1 To nCols
      ::ColumnWidth( i, ::ColumnWidth( i ) * nDivw )
   Next i

   Return ::Super:AdjustResize( nDivh, nDivw, lSelfOnly )


CLASS TGridMulti FROM TGrid

   DATA lDeleteAll                INIT .F.
   DATA Type                      INIT "MULTIGRID" READONLY

   METHOD Define
   METHOD DoChange
   METHOD Events_Notify
   METHOD SetControlValue         BLOCK { |Self, nRow, nCol| Empty( nCol ), ::Value := { nRow } }
   METHOD Value                   SETGET

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, ;
               aRows, value, fontname, fontsize, tooltip, change, dblclick, ;
               aHeadClick, gotfocus, lostfocus, nogrid, aImage, aJust, ;
               break, HelpId, bold, italic, underline, strikeout, ownerdata, ;
               ondispinfo, itemcount, editable, backcolor, fontcolor, ;
               dynamicbackcolor, dynamicforecolor, aPicture, lRtl, inplace, ;
               editcontrols, readonly, valid, validmessages, editcell, ;
               aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
               onenter, aHeaderImage, aHeaderImageAlign, FullMove, ;
               aSelectedColors, aEditKeys, lCheckBoxes, oncheck, lDblBffr, ;
               lFocusRect, lPLM, lFixedCols, abortedit, click, lFixedWidths, ;
               bBeforeColMove, bAfterColMove, bBeforeColSize, bAfterColSize, ;
               bBeforeAutofit, lLikeExcel, lButtons, AllowDelete, onDelete, ;
               bDelWhen, DelMsg, lNoDelMsg, AllowAppend, onappend, lNoModal, ;
               lFixedCtrls, bHeadRClick, lClickOnCheckbox, lRClickOnCheckbox, ;
               lExtDbl, lSilent, lAltA, lNoShowAlways, lNone, lCBE, onrclick, ;
               oninsert, editend, lAtFirst, bbeforeditcell, bEditCellValue, klc ) CLASS TGridMulti

   Local nStyle := 0

   HB_SYMBOL_UNUSED( lNone )

   ::Define2( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, aRows, ;
              value, fontname, fontsize, tooltip, aHeadClick, nogrid, ;
              aImage, aJust, break, HelpId, bold, italic, underline, ;
              strikeout, ownerdata, itemcount, editable, backcolor, ;
              fontcolor, dynamicbackcolor, dynamicforecolor, aPicture, lRtl, ;
              nStyle, inplace, editcontrols, readonly, valid, validmessages, ;
              aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
              aHeaderImage, aHeaderImageAlign, FullMove, aSelectedColors, ;
              aEditKeys, lCheckBoxes, lDblBffr, lFocusRect, lPLM, ;
              lFixedCols, lFixedWidths, lLikeExcel, lButtons, AllowDelete, ;
              DelMsg, lNoDelMsg, AllowAppend, lNoModal, lFixedCtrls, ;
              lClickOnCheckbox, lRClickOnCheckbox, lExtDbl, lSilent, lAltA, ;
              lNoShowAlways, .T., lCBE, lAtFirst, klc )

   // Must be set after control is initialized
   ::Define4( change, dblclick, gotfocus, lostfocus, ondispinfo, editcell, ;
              onenter, oncheck, abortedit, click, bBeforeColMove, bAfterColMove, ;
              bBeforeColSize, bAfterColSize, bBeforeAutofit, onDelete, ;
              bDelWhen, onappend, bHeadRClick, onrclick, oninsert, editend, ;
              bbeforeditcell, bEditCellValue )

   Return Self

METHOD Value( uValue ) CLASS TGridMulti

   Local aRet, aNew

   If HB_IsArray( uValue )
      aRet := ListViewGetMultiSel( ::hWnd )
      aNew := aSort( AClone( uValue ), Nil, Nil, {|x, y| x < y } )
      If ! aEqual( aNew, aRet )
         ListViewSetMultiSel( ::hWnd, uValue )
         If Len( uValue ) > 0
            ListView_EnsureVisible( ::hWnd, uValue[ 1 ] )
         EndIf
         aRet := ListViewGetMultiSel( ::hWnd )
      EndIf
   Else
      aRet := ListViewGetMultiSel( ::hWnd )
   EndIf

   Return aRet

FUNCTION aEqual( array1, array2 )

   Local lRet, nLen, i, cType

   IF HB_IsArray( array1 ) .AND. HB_IsArray( array2 )
      nLen := LEN( array1 )
      IF LEN( array2 ) == nLen
         lRet := .T.
         FOR i := 1 to nLen
            cType := VALTYPE( array1[ i ] )
            IF ! VALTYPE( array2[ i ] ) == cType
               lRet := .F.
               EXIT
            ELSEIF cType == "A" .AND. ! ArraysAreEqual( array1[ i ], array2[ i ] )
               lRet := .F.
               EXIT
            ELSEIF ! array1[ i ] == array2[ i ]
               lRet := .F.
               EXIT
            ENDIF
         NEXT i
      Else
         lRet := .F.
      ENDIF
   ELSE
      MsgOOHGError( 'ArraysAreEqual: Argument is not an array !!!' )
   ENDIF

   Return lRet

METHOD DoChange() CLASS TGridMulti

   Local xValue, cType, cOldType

   xValue   := ::Value
   cType    := ValType( xValue )
   cOldType := ValType( ::xOldValue )
   cType    := If( cType == "M", "C", cType )
   cOldType := If( cOldType == "M", "C", cOldType )
   If ( cOldType == "U" .OR. ! cType == cOldType .OR. ;
        ( HB_IsArray( xValue ) .AND. ! HB_IsArray( ::xOldValue ) ) .OR. ;
        ( ! HB_IsArray( xValue ) .AND. HB_IsArray( ::xOldValue ) ) .OR. ;
        ! aEqual( xValue, ::xOldValue ) )
      ::xOldValue := xValue
      ::DoEvent( ::OnChange, "CHANGE" )
   EndIf

   Return Self

METHOD Events_Notify( wParam, lParam ) CLASS TGridMulti

   Local nvkey, uValue, lGo, aSel, aItems, i, nNotify := GetNotifyCode( lParam )

   If nNotify == LVN_KEYDOWN
      If GetGridvKeyAsChar( lParam ) == 0
         ::cText := ""
      EndIf

      nvKey := GetGridvKey( lParam )

      If nvKey == VK_DELETE .AND. ::AllowDelete
         uValue := ::FirstSelectedItem
         If uValue > 0
            If ValType( ::bDelWhen ) == "B"
               lGo := _OOHG_EVAL( ::bDelWhen )
            Else
               lGo := .t.
            EndIf

            If lGo
               If ::lNoDelMsg .OR. MsgYesNo( _OOHG_Messages(4, 1), _OOHG_Messages(4, 3) )
                  If ::lDeleteAll
                     aItems := {}
                     aSel := ::Value
                     For i := Len( aSel ) To 1 Step -1
                        ASize( aItems, Len( aItems ) + 1 )
                        AIns( aItems, 1 )
                        aItems[ 1 ] := ::Item( aSel[ i ] )
                        ::DeleteItem( aSel[ i ] )
                     Next i
                  Else
                     aItems := ::Item( uValue )
                     ::DeleteItem( uValue )
                  EndIf
                  ::Value := { Min( uValue, ::ItemCount ) }
                  ::DoEvent( ::OnDelete, "DELETE", { aItems } )
               EndIf
            ElseIf ! Empty( ::DelMsg )
               MsgExclamation( ::DelMsg, _OOHG_Messages(4, 3) )
            EndIf
         Endif

         Return Nil
      EndIf

   EndIf

   Return ::Super:Events_Notify( wParam, lParam )


CLASS TGridByCell FROM TGrid

   DATA Type                      INIT "GRIDBYCELL" READONLY

   METHOD AddColumn
   METHOD Define
   METHOD DeleteAllItems
   METHOD DeleteColumn
   METHOD DeleteItem
   METHOD DoChange
   METHOD Down
   METHOD EditCell
   METHOD EditCell2
   METHOD EditGrid
   METHOD End
   METHOD Events
   METHOD Events_Notify
   METHOD GoBottom
   METHOD GoTop
   METHOD Home
   METHOD InsertBlank
   METHOD Left
   METHOD MoveToFirstCol
   METHOD MoveToFirstVisibleCol
   METHOD MoveToLastCol
   METHOD MoveToLastVisibleCol
   METHOD PageDown
   METHOD PageUp
   METHOD Right
   METHOD SetControlValue         BLOCK { |Self, nRow, nCol| If( nCol == NIL, nCol := 1, ), ::Value := { nRow, nCol } }
   METHOD SetSelectedColors
   METHOD Up
   METHOD Value                   SETGET

   ENDCLASS

METHOD Define( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, ;
               aRows, value, fontname, fontsize, tooltip, change, dblclick, ;
               aHeadClick, gotfocus, lostfocus, nogrid, aImage, aJust, ;
               break, HelpId, bold, italic, underline, strikeout, ownerdata, ;
               ondispinfo, itemcount, editable, backcolor, fontcolor, ;
               dynamicbackcolor, dynamicforecolor, aPicture, lRtl, InPlace, ;
               editcontrols, readonly, valid, validmessages, editcell, ;
               aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
               onenter, aHeaderImage, aHeaderImageAlign, FullMove, ;
               aSelectedColors, aEditKeys, lCheckBoxes, oncheck, lDblBffr, ;
               lFocusRect, lPLM, lFixedCols, abortedit, click, lFixedWidths, ;
               bBeforeColMove, bAfterColMove, bBeforeColSize, bAfterColSize, ;
               bBeforeAutofit, lLikeExcel, lButtons, AllowDelete, onDelete, ;
               bDelWhen, DelMsg, lNoDelMsg, AllowAppend, onappend, lNoModal, ;
               lFixedCtrls, bHeadRClick, lClickOnCheckbox, lRClickOnCheckbox, ;
               lExtDbl, lSilent, lAltA, lNoShowAlways, lNone, lCBE, onrclick, ;
               oninsert, editend, lAtFirst, bbeforeditcell, bEditCellValue, klc ) CLASS TGridByCell

   ASSIGN lFocusRect VALUE lFocusRect TYPE "L" DEFAULT .F.
   ASSIGN lNone      VALUE lNone      TYPE "L" DEFAULT .T.
   ASSIGN lCBE       VALUE lCBE       TYPE "L" DEFAULT .T.

   ::Define2( ControlName, ParentForm, x, y, w, h, aHeaders, aWidths, aRows, ;
              value, fontname, fontsize, tooltip, aHeadClick, nogrid, ;
              aImage, aJust, break, HelpId, bold, italic, underline, ;
              strikeout, ownerdata, itemcount, editable, backcolor, ;
              fontcolor, dynamicbackcolor, dynamicforecolor, aPicture, lRtl, ;
              LVS_SINGLESEL, inplace, editcontrols, readonly, valid, validmessages, ;
              aWhenFields, lDisabled, lNoTabStop, lInvisible, lHasHeaders, ;
              aHeaderImage, aHeaderImageAlign, FullMove, aSelectedColors, ;
              aEditKeys, lCheckBoxes, lDblBffr, lFocusRect, lPLM, ;
              lFixedCols, lFixedWidths, lLikeExcel, lButtons, AllowDelete, ;
              DelMsg, lNoDelMsg, AllowAppend, lNoModal, lFixedCtrls, ;
              lClickOnCheckbox, lRClickOnCheckbox, lExtDbl, lSilent, lAltA, ;
              lNoShowAlways, .T., lCBE, lAtFirst, klc )

   // Search the current column
   ::SearchCol := -1

   // Must be set after control is initialized
   ::Define4( change, dblclick, gotfocus, lostfocus, ondispinfo, editcell, ;
              onenter, oncheck, abortedit, click, bBeforeColMove, bAfterColMove, ;
              bBeforeColSize, bAfterColSize, bBeforeAutofit, onDelete, ;
              bDelWhen, onappend, bHeadRClick, onrclick, oninsert, editend, ;
              bbeforeditcell, bEditCellValue )

   Return Self

METHOD AddColumn( nColIndex, cCaption, nWidth, nJustify, uForeColor, uBackColor, ;
                  lNoDelete, uPicture, uEditControl, uHeadClick, uValid, ;
                  uValidMessage, uWhen, nHeaderImage, nHeaderImageAlign, ;
                  uReadOnly ) CLASS TGridByCell

   nColIndex := ::Super:AddColumn( nColIndex, cCaption, nWidth, nJustify, uForeColor, uBackColor, ;
                                   lNoDelete, uPicture, uEditControl, uHeadClick, uValid, ;
                                   uValidMessage, uWhen, nHeaderImage, nHeaderImageAlign, ;
                                   uReadOnly )

   If nColIndex <= ::nColPos
      ::Value := { ::nRowPos, ::nColPos + 1 }
   EndIf

   Return nColIndex

METHOD SetSelectedColors( aSelectedColors, lRedraw ) CLASS TGridByCell

   Local i, aColors[ 8 ]

   If HB_IsArray( aSelectedColors )
      aSelectedColors := AClone( aSelectedColors )
      ASize( aSelectedColors, 8 )

      // For text of selected cell when grid has the focus
      If ! ValType( aSelectedColors[ 1 ] ) $ "ANB"
         aSelectedColors[ 1 ] := GetSysColor( COLOR_HIGHLIGHTTEXT )
      EndIf
      // For background of selected cell when grid has the focus
      If ! ValType( aSelectedColors[ 2 ] ) $ "ANB"
         aSelectedColors[ 2 ] := GetSysColor( COLOR_HIGHLIGHT )
      EndIf
      // For text of selected cell when grid doesn't has the focus
      If ! ValType( aSelectedColors[ 3 ] ) $ "ANB"
         aSelectedColors[ 3 ] := GetSysColor( COLOR_WINDOWTEXT )
      EndIf
      // For background of selected cell when grid doesn't has the focus
      If ! ValType( aSelectedColors[ 4 ] ) $ "ANB"
         aSelectedColors[ 4 ] := GetSysColor( COLOR_3DFACE )
      EndIf

      // For text of other cells in the selected row when grid has the focus
      If ! ValType( aSelectedColors[ 5 ] ) $ "ANB"
         aSelectedColors[ 5 ] := -1                    // defaults to DYNAMICFORECOLOR, or FONTCOLOR or COLOR_WINDOWTEXT
      EndIf
      // For background of other cells in the selected row when grid has the focus
      If ! ValType( aSelectedColors[ 6 ] ) $ "ANB"
         aSelectedColors[ 6 ] := -1                    // defaults to DYNAMICBACKCOLOR, or BACKCOLOR or COLOR_WINDOW
      EndIf
      // For text of other cells in the selected row when grid doesn't has the focus
      If ! ValType( aSelectedColors[ 7 ] ) $ "ANB"
         aSelectedColors[ 7 ] := -1                    // defaults to DYNAMICFORECOLOR, or FONTCOLOR or COLOR_WINDOWTEXT
      EndIf
      // For background of other cells in the selected row when grid doesn't has the focus
      If ! ValType( aSelectedColors[ 8 ] ) $ "ANB"
         aSelectedColors[ 8 ] := -1                    // defaults to DYNAMICBACKCOLOR, or BACKCOLOR or COLOR_WINDOW
      EndIf

      ::aSelectedColors := aSelectedColors

      For i := 1 To 8
         aColors[ i ] := _OOHG_GetArrayItem( aSelectedColors, i )
      Next i

      ::GridSelectedColors := aColors

      If lRedraw
         RedrawWindow( ::hWnd )
      EndIf
   Else
      aSelectedColors := AClone( ::aSelectedColors )
   EndIf

   Return aSelectedColors

METHOD DeleteAllItems() CLASS TGridByCell

   ::nRowPos := 0
   ::nColPos := 0

   Return ::Super:DeleteAllItems()

METHOD Value( uValue ) CLASS TGridByCell

   Local r, nClientWidth, nScrollWidth, lRowChanged, lColChanged

   If HB_IsArray( uValue ) .AND. Len( uValue ) > 1 .AND. HB_IsNumeric( uValue[ 1 ] ) .AND. HB_IsNumeric( uValue[ 2 ] )
      If uValue[ 1 ] < 1 .OR. uValue[ 1 ] > ::ItemCount .OR. uValue[ 2 ] < 1 .OR. uValue[ 2 ] > Len( ::aHeaders )
         ::nRowPos := 0
         ::nColPos := 0
         ListView_ClearCursel( ::hWnd, 0 )
      Else
         lRowChanged := ( ::FirstSelectedItem # uValue[ 1 ] )
         lColChanged := ( ::nColPos # uValue[ 2 ] )
         ::nRowPos := uValue[ 1 ]
         ::nColPos := uValue[ 2 ]

         // Ensure that the column is inside the client area
         If lColChanged
            r := { 0, 0, 0, 0 }                                                              // left, top, right, bottom
            GetClientRect( ::hWnd, r )
            nClientWidth := r[ 3 ] - r[ 1 ]
            r := ListView_GetSubitemRect( ::hWnd, ::nRowPos - 1, ::nColPos - 1 )             // top, left, width, height
            If ::lScrollBarUsesClientArea .AND. ::ItemCount >  ::CountPerPage
               nScrollWidth := GetVScrollBarWidth()
            Else
               nScrollWidth := 0
            EndIf
            If r[ 2 ] + r[ 3 ] + nScrollWidth > nClientWidth
               // Move right side into client area
               ListView_Scroll( ::hWnd, ( r[ 2 ] + r[ 3 ] + nScrollWidth - nClientWidth ), 0 )
               // Get new position
               r := ListView_GetSubitemRect( ::hWnd, ::nRowPos - 1, ::nColPos - 1 )          // top, left, width, height
            EndIf
            If r[ 2 ] < 0
               // Move left side into client area
               ListView_Scroll( ::hWnd, r[ 2 ], 0 )
            EndIf
         EndIf

         // Ensure cell is visible
         If lRowChanged
            If ::lShowItemAtTop
               ListView_SetCursel( ::hWnd, ::ItemCount )
               If ! ListView_IsItemVisible( ::hWnd, ::ItemCount )
                  ListView_EnsureVisible( ::hWnd, ::ItemCount )
               EndIf
            EndIf
            ListView_SetCursel( ::hWnd, ::nRowPos )
         EndIf
         If ! ListView_IsItemVisible( ::hWnd, ::nRowPos )
            ListView_EnsureVisible( ::hWnd, ::nRowPos )
         EndIf
         ListView_RedrawItems( ::hWnd, ::nRowPos, ::ItemCount )
      EndIf
      ::DoChange()
   Else
      ::nRowPos := ::FirstSelectedItem
      If ::nRowPos == 0
         ::nColPos := 0
      EndIf
   EndIf

   Return { ::nRowPos, ::nColPos }

METHOD EditGrid( nRow, nCol, lAppend, lOneRow, lChange ) CLASS TGridByCell

   Local lRet, lSomethingEdited

   HB_SYMBOL_UNUSED( lChange )

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf
   If ! HB_IsNumeric( nRow )
      nRow := Max( ::FirstSelectedItem, 1 )
   EndIf
   If ! HB_IsNumeric( nCol )
      If ::nColPos >= 1
         nCol := ::nColPos
      Else
         nCol := ::FirstColInOrder
      EndIf
   EndIf
   If nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf

   ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT .F.

   If ::lAppendMode
      // Before calling ::EditGrid an empty item was added at ::ItemCount
   ElseIf lAppend
      // Add new item, ignore ::AllowAppend
      ::lAppendMode := .T.
      ::InsertBlank( ::ItemCount + 1 )
      ::Value := { ::ItemCount, nCol }
   Else
      // Edit item nRow
      If ! HB_IsNumeric( nRow )
         nRow := Max( ::FirstSelectedItem, 1 )
      EndIf
      If nRow < 1 .OR. nRow > ::ItemCount
         Return .F.
      EndIf
      ::Value := { nRow, nCol }
   EndIf

   lSomethingEdited := .F.

   Do While ::nRowPos >= 1 .AND. ::nRowPos <= ::ItemCount .AND. ::nColPos >= 1 .AND. ::nColPos <= Len( ::aHeaders )
      _OOHG_ThisItemCellValue := ::Cell( ::nRowPos, ::nColPos )

      If ::IsColumnReadOnly( ::nColPos, ::nRowPos )
         // Read only column
      ElseIf ! ::IsColumnWhen( ::nColPos, ::nRowPos )
         // WHEN returned .F.
      ElseIf AScan( ::aHiddenCols, ::nColPos ) > 0
         // Hidden column
      Else
         ::lCalledFromClass := .T.
         lRet := ::Super:EditCell( ::nRowPos, ::nColPos, , , , , , .F. )
         ::lCalledFromClass := .F.

         If ::lAppendMode
            ::lAppendMode := .F.
            If lRet
               ::DoEvent( ::OnAppend, "APPEND", { ::nRowPos } )
               lSomethingEdited := .T.
            Else
               Exit
            EndIf
         ElseIf lRet
            lSomethingEdited := .T.
         Else
            Exit
         EndIf
      EndIf

      /*
       * ::OnEditCell may change ::nRowPos and/or ::nColPos using ::Up(), ::PageUp(), ::Home(),
       * ::End(), ::Down(), ::PageDown(), ::GoTop(), ::GoBottom(), ::Left() and/or ::Right()
       */

      // ::bPosition is set by TGridControl()
      If ::bPosition == 1                            // UP
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount + 1 .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         ElseIf ::nRowPos > 1
            ::Value := { ::nRowPos - 1, ::nColPos }
         ElseIf ::FullMove
            ::Value := { ::ItemCount, ::nColPos }
         Else
            Exit
         EndIf
      ElseIf ::bPosition == 2                        // RIGHT
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         Else
            nCol := ::NextColInOrder( ::nColPos )
            If nCol == 0
               If HB_IsLogical( lOneRow ) .AND. lOneRow
                  Exit
               ElseIf ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
                  Exit
               EndIf
               nCol := ::FirstColInOrder
               If nCol == 0
                  Exit
               ElseIf ::nRowPos < ::ItemCount
                  ::Value := { ::nRowPos + 1, nCol }
               ElseIf ::AllowAppend .OR. lAppend
                  ::lAppendMode := .T.
                  ::InsertBlank( ::ItemCount + 1 )
                  ::Value := { ::ItemCount, nCol }
               ElseIf ::FullMove
                  ::Value := { 1, nCol }
               EndIf
            Else
               ::Value := { ::nRowPos, nCol }
            EndIf
         EndIf
      ElseIf ::bPosition == 3                        // LEFT
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         Else
            nCol := ::PriorColInOrder( ::nColPos )
            If nCol == 0
               If HB_IsLogical( lOneRow ) .AND. lOneRow
                  Exit
               ElseIf ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
                  Exit
               EndIf
               nCol := ::LastColInOrder
               If nCol == 0
                  Exit
               ElseIf ::nRowPos > 1
                  ::Value := { ::nRowPos - 1, nCol }
               ElseIf ::FullMove
                  ::Value := { ::ItemCount, nCol }
               EndIf
            Else
               ::Value := { ::nRowPos, nCol }
            EndIf
         EndIf
      ElseIf ::bPosition == 4                        // HOME
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         Else
            ::Value := { 1, ::FirstColInOrder }
            If ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
               Exit
            EndIf
         EndIf
      ElseIf ::bPosition == 5                        // END
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         Else
            ::Value := { ::ItemCount, ::LastColInOrder }
            If ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
               Exit
            EndIf
         EndIf
      ElseIf ::bPosition == 6                        // DOWN
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         ElseIf ::nRowPos < ::ItemCount
            ::Value := { ::nRowPos + 1, ::nColPos }
         ElseIf ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
            Exit
         ElseIf ::AllowAppend .OR. lAppend
            ::lAppendMode := .T.
            ::InsertBlank( ::ItemCount + 1 )
            ::Value := { ::ItemCount, ::nColPos }
         ElseIf ::FullMove
            ::Value := { 1, ::nColPos }
         EndIf
      ElseIf ::bPosition == 7                        // PRIOR
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         ElseIf ::nRowPos > ::CountPerPage
            ::Value := { ::nRowPos - ::CountPerPage, ::nColPos }
         Else
            ::Value := { 1, ::nColPos }
         EndIf
         If ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
            Exit
         EndIf
      ElseIf ::bPosition == 8                        // NEXT
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         ElseIf HB_IsLogical( lOneRow ) .AND. lOneRow
            Exit
         ElseIf ::nRowPos < ::ItemCount - ::CountPerPage
            ::Value := { ::nRowPos + ::CountPerPage, ::nColPos }
         Else
            ::Value := { ::ItemCount, ::nColPos }
         EndIf
         If ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
            Exit
         EndIf
      ElseIf ::bPosition == 9                        // MOUSE EXIT
         // Edition window lost focus, resume clic processing and process delayed click
         ::bPosition := 0
         If ::nDelayedClick[ 1 ] > 0
            // A click message was delayed
            If ::nDelayedClick[ 3 ] <= 0
               ::Value := { ::nDelayedClick[ 1 ], ::nDelayedClick[ 2 ] }
            EndIf

            If ::nDelayedClick[ 4 ] == NIL
               If HB_IsBlock( ::OnClick )
                  If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                     If ! ::NestedClick
                        ::NestedClick := ! _OOHG_NestedSameEvent()
                        ::DoEventMouseCoords( ::OnClick, "CLICK" )
                        ::NestedClick := .F.
                     EndIf
                  EndIf
               EndIf
            Else
               If HB_IsBlock( ::OnRClick )
                  If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                     ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
                  EndIf
               EndIf
            EndIf

            If ::nDelayedClick[ 3 ] > 0
               // change check mark
               ::CheckItem( ::nDelayedClick[ 3 ], ! ::CheckItem( ::nDelayedClick[ 3 ] ) )
            EndIf

            // fire context menu
            If ! ::nDelayedClick[ 4 ] == NIL .AND. ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0 )
               ::ContextMenu:Cargo := ::nDelayedClick[ 4 ]
               ::ContextMenu:Activate()
            EndIf
         EndIf
         Exit
      Else                                           // OK
         If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
            Exit
         Else
            nCol := ::NextColInOrder( ::nColPos )
            If nCol == 0
               If HB_IsLogical( lOneRow ) .AND. lOneRow
                  Exit
               ElseIf ! HB_IsLogical( lOneRow ) .AND. ! ::FullMove
                  Exit
               EndIf
               nCol := ::FirstColInOrder
               If nCol == 0
                  Exit
               ElseIf ::nRowPos < ::ItemCount
                  ::Value := { ::nRowPos + 1, nCol }
               ElseIf ::AllowAppend .OR. lAppend
                  ::lAppendMode := .T.
                  ::InsertBlank( ::ItemCount + 1 )
                  ::Value := { ::ItemCount, nCol }
               ElseIf ::FullMove
                  ::Value := { 1, nCol }
               EndIf
            Else
               ::Value := { ::nRowPos, nCol }
            EndIf
         EndIf
      EndIf
   EndDo

   Return lSomethingEdited

METHOD Right( lAppend ) CLASS TGridByCell

   Local nCol, lRet := .F.

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   Else
      nCol := ::NextColInOrder( ::nColPos )
      If nCol == 0
         If ::nRowPos < ::ItemCount
            If ::FullMove
               nCol := ::FirstColInOrder
               If nCol # 0
                  ::Value := { ::nRowPos + 1, nCol }
                  lRet := .T.
               EndIf
            Endif
         Else
            ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT ::AllowAppend
            If lAppend
               lRet := ::AppendItem()
            ElseIf ::FullMove
               ::Value := { 1, ::FirstColInOrder }
               lRet := .T.
            EndIf
         EndIf
      Else
         ::Value := { ::nRowPos, nCol }
         lRet := .T.
      EndIf
   EndIf

   Return lRet

METHOD Left() CLASS TGridByCell

   Local nCol, lRet := .F.

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   Else
      nCol := ::PriorColInOrder( ::nColPos )
      If nCol == 0
         If ::nRowPos > 1
            If ::FullMove
               nCol := ::LastColInOrder
               If nCol # 0
                  ::Value := { ::nRowPos - 1, nCol }
                  lRet := .T.
               EndIf
            EndIf
         ElseIf ::FullMove
            ::Value := { ::ItemCount, ::LastColInOrder }
         Endif
      Else
         ::Value := { ::nRowPos, nCol }
         lRet := .T.
      EndIf
   EndIf

   Return lRet

METHOD Up( lLast ) CLASS TGridByCell

   Local nCol, lRet := .F.

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   ElseIf ::nRowPos > 1
      If HB_IsLogical( lLast ) .AND. lLast
         nCol := ::LastColInOrder
         If nCol # 0
            ::Value := { ::nRowPos - 1, nCol }
            lRet := .T.
         EndIf
      Else
         ::Value := { ::nRowPos - 1, ::nColPos }
         lRet := .T.
      EndIf
   ElseIf ::FullMove
      ::Value := { ::ItemCount, ::nColPos }
      lRet := .T.
   EndIf

   Return lRet

METHOD Down( lAppend ) CLASS TGridByCell

   Local nCol, lRet := .F.

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   ElseIf ::nRowPos < ::ItemCount
      ::Value := { ::nRowPos + 1, ::nColPos }
      lRet := .T.
   Else
      ASSIGN lAppend VALUE lAppend TYPE "L" DEFAULT ::AllowAppend
      If lAppend
         lRet := ::AppendItem()
      ElseIf ::FullMove
         ::Value := { ::ItemCount, ::nColPos }
         lRet := .T.
      EndIf
   EndIf

   Return lRet

METHOD PageUp() CLASS TGridByCell

   Local nCol, lRet

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   ElseIf ::nRowPos > ::CountPerPage
      ::Value := { ::nRowPos - ::CountPerPage, ::nColPos }
      lRet := .T.
   ElseIf ::nRowPos # 1
      ::Value := { 1, ::nColPos }
      lRet := .T.
   Else
      lRet := .F.
   EndIf

   Return lRet

METHOD PageDown() CLASS TGridByCell

   Local nCol, lRet

   If ::nRowPos < 1 .OR. ::nRowPos > ::ItemCount .OR. ::nColPos < 1 .OR. ::nColPos > Len( ::aHeaders )
      If ::ItemCount > 0
         nCol := ::FirstColInOrder
         If nCol == 0
            ::Value := { 0, 0 }
         Else
            ::Value := { 1, nCol }
         EndIf
      Else
         ::Value := { 0, 0 }
      EndIf
      lRet := .T.
   ElseIf ::nRowPos < ::ItemCount - ::CountPerPage
      ::lShowItemAtTop := .T.
      ::Value := { ::nRowPos + ::CountPerPage, ::nColPos }
      ::lShowItemAtTop := .F.
      lRet := .T.
   ElseIf ::nRowPos # ::ItemCount
      ::Value := { ::ItemCount, ::nColPos }
      lRet := .T.
   Else
      lRet := .F.
   EndIf

   Return lRet

METHOD Home() CLASS TGridByCell

   Local lDone

   If ::lKeysLikeClipper
      lDone := ::MoveToFirstVisibleCol()
   Else
      lDone := ::GoTop( ::FirstColInOrder )
   EndIf

   Return lDone

METHOD GoTop( nCol ) CLASS TGridByCell

   Local lRet := .F.

   If ::ItemCount > 0
      If ! HB_IsNumeric( nCol )
         If ::lKeysLikeClipper
            nCol := ::nColPos
         Else
            nCol := ::FirstColInOrder
         EndIf
      EndIf
      If nCol # 0
         If ::nRowPos # 1 .OR. ::nColPos # nCol
            ::Value := { 1, nCol }
            lRet := .T.
         EndIf
      EndIf
   EndIf

   Return lRet

METHOD End() CLASS TGridByCell

   Local lDone

   If ::lKeysLikeClipper
      lDone := ::MoveToLastVisibleCol()
   Else
      lDone := ::GoBottom( ::LastColInOrder )
   EndIf

   Return lDone

METHOD GoBottom( nCol ) CLASS TGridByCell

   Local lRet := .F.

   If ::ItemCount > 0
      If ! HB_IsNumeric( nCol )
         If ::lKeysLikeClipper
            nCol := ::nColPos
         Else
            nCol := ::LastColInOrder
         EndIf
      EndIf
      If nCol # 0
         If ::nRowPos # ::ItemCount .OR. ::nColPos # nCol
            ::Value := { ::ItemCount, nCol }
            lRet := .T.
         EndIf
      EndIf
   EndIf

   Return lRet

METHOD InsertBlank( nItem ) CLASS TGridByCell

   nItem := ::Super:InsertBlank( nItem )

   If nItem > 0
      If nItem <= ::nRowPos
         ::Value := { ::nRowPos + 1, ::nColPos }
      EndIf
   EndIf

   Return nItem

METHOD DeleteItem( nItem ) CLASS TGridByCell

   Local lRet

   lRet := ::Super:DeleteItem( nItem )
   If lRet
      If nItem <= ::nRowPos
         ::Value := { ::nRowPos - 1, ::nColPos }
      EndIf
   EndIf

   Return lRet

METHOD DeleteColumn( nColIndex, lNoDelete ) CLASS TGridByCell

   nColIndex := ::Super:DeleteColumn( nColIndex, lNoDelete )
   If nColIndex > 0
      If nColIndex == ::nColPos
         ::Value := { 0, 0 }
      ElseIf nColIndex < ::nColPos
         ::Value := { ::nRowPos, ::nColPos - 1 }
      EndIf
   EndIf

   Return nColIndex

METHOD EditCell( nRow, nCol, EditControl, uOldValue, uValue, cMemVar, nOnFocusPos, lChange ) CLASS TGridByCell

   Local lRet

   HB_SYMBOL_UNUSED( lChange )

   If ::FirstVisibleColumn == 0
      Return .F.
   EndIf
   If ! HB_IsNumeric( nRow )
      nRow := Max( ::nRowPos, 1 )
   EndIf
   If ! HB_IsNumeric( nCol )
      If ::nColPos >= 1
         nCol := ::nColPos
      Else
         nCol := ::FirstColInOrder
      EndIf
   EndIf
   If nRow < 1 .OR. nRow > ::ItemCount .OR. nCol < 1 .OR. nCol > Len( ::aHeaders )
      Return .F.
   EndIf
   If AScan( ::aHiddenCols, nCol ) > 0
      Return .F.
   EndIf

   ::Value := { nRow, nCol }

   ::lCalledFromClass := .T.
   lRet := ::Super:EditCell( ::nRowPos, ::nColPos, EditControl, uOldValue, uValue, cMemVar, nOnFocusPos, .F. )
   ::lCalledFromClass := .F.

   If lRet
      // ::bPosition is set by TGridControl()
      If ::bPosition == 1                            // UP
         ::Up()
      ElseIf ::bPosition == 2                        // RIGHT
         ::Right( .F. )
      ElseIf ::bPosition == 3                        // LEFT
         ::Left()
      ElseIf ::bPosition == 4                        // HOME
         ::GoTop()
      ElseIf ::bPosition == 5                        // END
         ::GoBottom( .F. )
      ElseIf ::bPosition == 6                        // DOWN
         ::Down( .F. )
      ElseIf ::bPosition == 7                        // PRIOR
         ::PageUp()
      ElseIf ::bPosition == 8                        // NEXT
         ::PageDown( .F. )
      ElseIf ::bPosition == 9                        // MOUSE EXIT
         // Edition window lost focus, resume clic processing and process delayed click
         ::bPosition := 0
         If ::nDelayedClick[ 1 ] > 0
            // A click message was delayed
            If ::nDelayedClick[ 3 ] <= 0
               ::Value := { ::nDelayedClick[ 1 ], ::nDelayedClick[ 2 ] }
            EndIf

            If ::nDelayedClick[ 4 ] == NIL
               If HB_IsBlock( ::OnClick )
                  If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                     If ! ::NestedClick
                        ::NestedClick := ! _OOHG_NestedSameEvent()
                        ::DoEventMouseCoords( ::OnClick, "CLICK" )
                        ::NestedClick := .F.
                     EndIf
                  EndIf
               EndIf
            Else
               If HB_IsBlock( ::OnRClick )
                  If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0
                     ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
                  EndIf
               EndIf
            EndIf

            If ::nDelayedClick[ 3 ] > 0
               // change check mark
               ::CheckItem( ::nDelayedClick[ 3 ], ! ::CheckItem( ::nDelayedClick[ 3 ] ) )
            EndIf

            // fire context menu
            If ! ::nDelayedClick[ 4 ] == NIL .AND. ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. ::nDelayedClick[ 3 ] <= 0 )
               ::ContextMenu:Cargo := ::nDelayedClick[ 4 ]
               ::ContextMenu:Activate()
            EndIf
         EndIf
      Else                                           // OK
         If ::nRowPos >= 1 .AND. ::nRowPos <= ::ItemCount .AND. ::nColPos >= 1 .AND. ::nColPos <= Len( ::aHeaders )
            nCol := ::NextColInOrder( ::nColPos )
            If nCol == 0
               If ::FullMove
                  nCol := ::FirstColInOrder
                  If nCol > 0
                     If ::nRowPos < ::ItemCount
                        ::Value := { ::nRowPos + 1, nCol }
                     Else
                        ::Value := { 1, nCol }
                     EndIf
                  EndIf
               EndIf
            Else
               ::Value := { ::nRowPos, nCol }
            EndIf
         EndIf
      EndIf
   EndIf

   Return lRet

// nRow, nCol and uValue may be passed by reference
METHOD EditCell2( nRow, nCol, EditControl, uOldValue, uValue, cMemVar, nOnFocusPos ) CLASS TGridByCell

   If ! HB_IsNumeric( nRow )
      nRow := Max( ::nRowPos, 1 )
   EndIf
   If ! HB_IsNumeric( nCol )
      If ::nColPos >= 1
         nCol := ::nColPos
      Else
         nCol := ::FirstColInOrder
      EndIf
   EndIf

   Return ::Super:EditCell2( @nRow, @nCol, @EditControl, uOldValue, @uValue, cMemVar, nOnFocusPos )

METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TGridByCell

   Local aCellData, nItem, i, nSearchCol, aPos

   If nMsg == WM_LBUTTONDBLCLK
      If ! ::lCheckBoxes .OR. ListView_HitOnCheckBox( hWnd, GetCursorRow() - GetWindowRow( hWnd ), GetCursorCol() - GetWindowCol( hWnd ) ) <= 0
         _PushEventInfo()
         _OOHG_ThisForm := ::Parent
         _OOHG_ThisType := 'C'
         _OOHG_ThisControl := Self

         // Identify item & subitem hitted
         aPos := Get_XY_LPARAM( lParam )
         aPos := ListView_HitTest( ::hWnd, aPos[ 1 ], aPos[ 2 ] )

         aCellData := _GetGridCellData( Self, aPos )
         _OOHG_ThisItemRowIndex   := aCellData[ 1 ]
         _OOHG_ThisItemColIndex   := aCellData[ 2 ]
         _OOHG_ThisItemCellRow    := aCellData[ 3 ]
         _OOHG_ThisItemCellCol    := aCellData[ 4 ]
         _OOHG_ThisItemCellWidth  := aCellData[ 5 ]
         _OOHG_ThisItemCellHeight := aCellData[ 6 ]
         _OOHG_ThisItemCellValue  := ::Cell( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex )

         If ! ::AllowEdit .OR. _OOHG_ThisItemRowIndex < 1 .OR. _OOHG_ThisItemRowIndex > ::ItemCount .OR. _OOHG_ThisItemColIndex < 1 .OR. _OOHG_ThisItemColIndex > Len( ::aHeaders )
            If HB_IsBlock( ::OnDblClick )
               ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
            EndIf
         ElseIf ::IsColumnReadOnly( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
            // Cell is readonly
            If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
               ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
            EndIf
         ElseIf ! ::IsColumnWhen( _OOHG_ThisItemColIndex, _OOHG_ThisItemRowIndex )
            // WHEN returned .F.
            If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
               ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
            EndIf
         ElseIf AScan( ::aHiddenCols, _OOHG_ThisItemColIndex ) > 0
            // Cell is in a hidden column
            If ::lExtendDblClick .and. HB_IsBlock( ::OnDblClick )
               ::DoEventMouseCoords( ::OnDblClick, "DBLCLICK" )
            EndIf
         Else
            ::EditGrid( _OOHG_ThisItemRowIndex, _OOHG_ThisItemColIndex )
         EndIf

         _ClearThisCellInfo()
         _PopEventInfo()
      EndIf
      Return 0

   ElseIf nMsg == WM_CHAR
      If ::AllowEdit .AND. ( ::lLikeExcel .OR. EditControlLikeExcel( Self, ::Value[ 2 ] ) )
         ::EditCell( , , , Chr( wParam ) )
         Return 0

      Else
         If wParam < 32
            ::cText := ""
            Return 0
         ElseIf Empty( ::cText )
            ::uIniTime := HB_MilliSeconds()
            ::cText := Upper( Chr( wParam ) )
         ElseIf HB_MilliSeconds() > ::uIniTime + ::SearchLapse
            ::uIniTime := HB_MilliSeconds()
            ::cText := Upper( Chr( wParam ) )
         Else
            ::uIniTime := HB_MilliSeconds()
            ::cText += Upper( Chr( wParam ) )
         EndIf

         If ::SearchCol < 0
            // Current column
            nSearchCol := ::Value[ 2 ]
            If nSearchCol < 1 .OR. nSearchCol > ::ColumnCount .OR. AScan( ::aHiddenCols, nSearchCol ) # 0
               Return 0
            EndIf
         ElseIF ::SearchCol == 0
            // Listview search
            nSearchCol := 0
         ElseIf ::SearchCol > ::ColumnCount
            Return 0
         ElseIf AScan( ::aHiddenCols, ::SearchCol ) # 0
            Return 0
         Else
            nSearchCol := ::SearchCol
         EndIf

         If nSearchCol >= 1
            nItem := 0

            For i := ::FirstSelectedItem + 1 To ::ItemCount
               If Upper( Left( ::CellCaption( i, nSearchCol ), Len( ::cText ) ) ) == ::cText
                  nItem := i
                  Exit
               EndIf
            Next i

            If nItem == 0 .AND. ::SearchWrap
               For i := 1 To ::FirstSelectedItem
                 If Upper( Left( ::CellCaption( i, nSearchCol ), Len( ::cText ) ) ) == ::cText
                    nItem := i
                    Exit
                 EndIf
               Next i
            EndIf
         Else
            nItem := ListView_FindItem( hWnd, ::FirstSelectedItem - 2, ::cText, ::SearchWrap )
            nSearchCol := 1
         EndIf
         If nItem > 0
            ::Value := { nItem, nSearchCol }
         EndIf
         Return 0
      EndIf

   EndIf

   Return ::Super:Events( hWnd, nMsg, wParam, lParam )

FUNCTION EditControlLikeExcel( oGrid, nColumn )

   Local oEditControl

   If nColumn < 1
      Return .F.
   EndIf
   If oGrid:FixControls()
      oEditControl := oGrid:aEditControls[ nColumn ]
   EndIf
   oEditControl := GetEditControlFromArray( oEditControl, oGrid:EditControls, nColumn, oGrid )

   Return HB_IsObject( oEditControl ) .AND. oEditControl:lLikeExcel

METHOD MoveToFirstCol CLASS TGridByCell

Local aBefore, nCol, aAfter, lDone := .F.

   aBefore := ::Value
   nCol := ::FirstColInOrder
   If nCol # 0
      ::Value := { aBefore[ 1 ], nCol }
      aAfter := ::Value
      lDone := ( aAfter[ 1 ] # aBefore[ 1 ] .OR. aAfter[ 2 ] # aBefore[ 2 ] )
   EndIf

Return lDone

METHOD MoveToLastCol CLASS TGridByCell

Local aBefore, nCol, aAfter, lDone := .F.

   aBefore := ::Value
   nCol := ::LastColInOrder
   If nCol # 0
      ::Value := { aBefore[ 1 ], nCol }
      aAfter := ::Value
      lDone := ( aAfter[ 1 ] # aBefore[ 1 ] .OR. aAfter[ 2 ] # aBefore[ 2 ] )
   EndIf

Return lDone

METHOD MoveToFirstVisibleCol CLASS TGridByCell

Local aBefore, nCol, aAfter, lDone := .F.

   aBefore := ::Value
   ::ScrollToPrior()
   nCol := ::FirstVisibleColumn
   If nCol # 0
      ::Value := { aBefore[ 1 ], nCol }
      aAfter := ::Value
      lDone := ( aAfter[ 1 ] # aBefore[ 1 ] .OR. aAfter[ 2 ] # aBefore[ 2 ] )
   EndIf

Return lDone

METHOD MoveToLastVisibleCol CLASS TGridByCell

Local aBefore, nCol, aAfter, lDone := .F.

   aBefore := ::Value
   ::ScrollToPrior()
   nCol := ::LastVisibleColumn
   If nCol # 0
      ::Value := { aBefore[ 1 ], nCol }
      aAfter := ::Value
      lDone := ( aAfter[ 1 ] # aBefore[ 1 ] .OR. aAfter[ 2 ] # aBefore[ 2 ] )
   EndIf

Return lDone

METHOD Events_Notify( wParam, lParam ) CLASS TGridByCell

   Local nNotify := GetNotifyCode( lParam )
   Local nvkey, lGo, aItem, nRow, nCol, uValue, aCellData

   If nNotify == NM_CUSTOMDRAW
      Return TGrid_Notify_CustomDraw( Self, lParam, .T., ::nRowPos, ::nColPos, ::lCheckBoxes, ::lFocusRect, ::lNoGrid, ::lPLM )

   ElseIf nNotify == LVN_KEYDOWN
      If GetGridvKeyAsChar( lParam ) == 0
         ::cText := ""
      EndIf

      nvKey := GetGridvKey( lParam )

      If ::FirstVisibleColumn == 0
         // Do nothing
      ElseIf nvkey == VK_DOWN
         If GetKeyFlagState() == MOD_CONTROL
            If ! ::lKeysLikeClipper
               ::Value := { ::ItemCount, ::nColPos }
            EndIf
         Else
            ::Down()
         EndIf
      ElseIf nvkey == VK_UP
         If GetKeyFlagState() == MOD_CONTROL
            If ! ::lKeysLikeClipper
               ::Value := { 1, ::nColPos }
            EndIf
         Else
            ::Up()
         EndIf
      ElseIf nvkey == VK_PRIOR
         If ::lKeysLikeClipper .AND. GetKeyFlagState() == MOD_CONTROL
            ::GoTop()
         Else
            ::PageUp()
         EndIf
      ElseIf nvkey == VK_NEXT
         If ::lKeysLikeClipper .AND. GetKeyFlagState() == MOD_CONTROL
            ::GoBottom()
         Else
            ::PageDown()
         Endif
      ElseIf nvkey == VK_HOME
         If ::lKeysLikeClipper
            If GetKeyFlagState() == MOD_CONTROL
               ::MoveToFirstCol()
            Else
               ::MoveToFirstVisibleCol()
            EndIf
         Else
            ::GoTop()
         EndIf
      ElseIf nvkey == VK_END
         If ::lKeysLikeClipper
            If GetKeyFlagState() == MOD_CONTROL
               ::MoveToLastCol()
            Else
               ::MoveToLastVisibleCol()
            EndIf
         Else
            ::GoBottom()
         EndIf
      ElseIf nvkey == VK_LEFT
         If GetKeyFlagState() == MOD_CONTROL
            If ::lKeysLikeClipper
               ::PanToLeft()
            Else
               ::MoveToFirstCol()
            EndIf
         Else
            ::Left()
         EndIf
      ElseIf nvkey == VK_RIGHT
         If GetKeyFlagState() == MOD_CONTROL
            If ::lKeysLikeClipper
               ::PanToRight()
            Else
               ::MoveToLastCol()
            EndIf
         Else
            ::Right()
         EndIf
      ElseIf nvkey == VK_SPACE .AND. ::lCheckBoxes
         // detect item
         If ::nRowPos > 0
            // change check mark
            ::CheckItem( ::nRowPos, ! ::CheckItem( ::nRowPos ) )
         EndIf
      ElseIf nvKey == VK_DELETE .AND. ::AllowDelete
         // detect item
         If ::nRowPos > 0
            If ValType( ::bDelWhen ) == "B"
               lGo := _OOHG_EVAL( ::bDelWhen )
            Else
               lGo := .t.
            EndIf

            If lGo
               If ::lNoDelMsg .OR. MsgYesNo( _OOHG_Messages(4, 1), _OOHG_Messages(4, 3) )
                  nRow := ::nRowPos
                  nCol := ::nColPos
                  aItem := ::Item( nRow )
                  ::DeleteItem( nRow )
                  If ::ItemCount > 0
                     ::Value := { Min( nRow, ::ItemCount ), nCol }
                  Else
                     ::Value := { 0, 0 }
                  Endif
                  ::DoEvent( ::OnDelete, "DELETE", { aItem } )
               EndIf
            ElseIf ! Empty( ::DelMsg )
               MsgExclamation( ::DelMsg, _OOHG_Messages(4, 3) )
            EndIf
         EndIf
      ElseIf nvKey == VK_A .AND. GetKeyFlagState() == MOD_ALT
         If ::lAppendOnAltA
            ::AppendItem()
         EndIf
      EndIf
      // skip default action
      Return 1

   ElseIf nNotify == LVN_ITEMCHANGED
      If GetGridOldState( lParam ) == 0 .AND. GetGridNewState( lParam ) != 0
         Return Nil
      EndIf

   ElseIf nNotify == NM_CLICK
      If ::lCheckBoxes
         // detect item
         uValue := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      Else
         uValue := 0
      EndIf

      If ::bPosition == -2 .OR. ::bPosition == 9
         aCellData := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
         ::nDelayedClick := { aCellData[ 1 ], aCellData[ 2 ], uValue, Nil }
         If ::nEditRow > 0
            ListView_SetCursel( ::hWnd, ::nEditRow )
         Else
            ListView_ClearCursel( ::hWnd )
         EndIf
      Else
         If HB_IsBlock( ::OnClick )
            If ! ::lCheckBoxes .OR. ::ClickOnCheckbox .OR. uValue <= 0
               If ! ::NestedClick
                  ::NestedClick := ! _OOHG_NestedSameEvent()
                  ::DoEventMouseCoords( ::OnClick, "CLICK" )
                  ::NestedClick := .F.
               EndIf
            EndIf
         EndIf

         If uValue > 0
            // change check mark
            ::CheckItem( uValue, ! ::CheckItem( uValue ) )
         Else
            // select cell
            aCellData := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
            ::Value := { aCellData[ 1 ], aCellData[ 2 ] }
         EndIf
      EndIf

      // skip default action
      Return 1

   ElseIf nNotify == NM_RCLICK
      If ::lCheckBoxes
         // detect item
         uValue := ListView_HitOnCheckBox( ::hWnd, GetCursorRow() - GetWindowRow( ::hWnd ), GetCursorCol() - GetWindowCol( ::hWnd ) )
      Else
         uValue := 0
      EndIf

      If ::bPosition == -2 .OR. ::bPosition == 9
         aCellData := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
         ::nDelayedClick := { aCellData[ 1 ], aCellData[ 2 ], uValue, aCellData }
         If ::nEditRow > 0
            ListView_SetCursel( ::hWnd, ::nEditRow )
         Else
            ListView_ClearCursel( ::hWnd )
         EndIf
      Else
         If HB_IsBlock( ::OnRClick )
            If ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. uValue <= 0
               ::DoEventMouseCoords( ::OnRClick, "RCLICK" )
            EndIf
         EndIf

         If uValue > 0
            // change check mark
            ::CheckItem( uValue, ! ::CheckItem( uValue ) )
         Else
            // select cell
            aCellData := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
            ::Value := { aCellData[ 1 ], aCellData[ 2 ] }
         EndIf

         // fire context menu
         If ::ContextMenu != Nil .AND. ( ! ::lCheckBoxes .OR. ::RClickOnCheckbox .OR. uValue <= 0 )
            ::ContextMenu:Cargo := _GetGridCellData( Self, ListView_ItemActivate( lParam ) )
            ::ContextMenu:Activate()
         EndIf
      EndIf

      // skip default action
      Return 1

   EndIf

   Return ::Super:Events_Notify( wParam, lParam )

METHOD DoChange() CLASS TGridByCell

   Local xValue, cType, cOldType

   xValue   := ::Value
   cType    := ValType( xValue )
   cOldType := ValType( ::xOldValue )
   cType    := If( cType == "M", "C", cType )
   cOldType := If( cOldType == "M", "C", cOldType )

   If ( cOldType == "U" .OR. ! cType == cOldType .OR. ;
        ( HB_IsArray( xValue ) .AND. ! HB_IsArray( ::xOldValue ) ) .OR. ;
        ( ! HB_IsArray( xValue ) .AND. HB_IsArray( ::xOldValue ) ) .OR. ;
        ! aEqual( xValue, ::xOldValue ) )
      ::xOldValue := xValue
      ::DoEvent( ::OnChange, "CHANGE" )
   EndIf

   Return Self

FUNCTION _GetGridCellData( Self, aPos )

   Local ThisItemRowIndex
   Local ThisItemColIndex
   Local ThisItemCellRow
   Local ThisItemCellCol
   Local ThisItemCellWidth
   Local ThisItemCellHeight
   Local r
   Local nScrollWidth
   Local aCellData
   Local nClientWidth
   Local aControlRect

   If aPos[ 1 ] == 0
      // Hit on an empty row
      Return { 0, 0, 0, 0, 0, 0 }
   EndIf
   ThisItemRowIndex := aPos[ 1 ]              // item
   ThisItemColIndex := aPos[ 2 ]              // subitem (column)

   // Ensure that the column is inside the client area
   aControlRect := { 0, 0, 0, 0 }                                                         // left, top, right, bottom
   GetClientRect( ::hWnd, aControlRect )
   nClientWidth := aControlRect[ 3 ] - aControlRect[ 1 ]
   aControlRect := { 0, 0, 0, 0 }                                                         // left, top, right, bottom
   GetWindowRect( ::hWnd, aControlRect )
   r := ListView_GetSubitemRect( ::hWnd, ThisItemRowIndex - 1, ThisItemColIndex - 1 )     // top, left, width, height
   If ::lScrollBarUsesClientArea .AND. ListViewGetItemCount( ::hWnd ) >  ListViewGetCountPerPage( ::hWnd )
      nScrollWidth := GetVScrollBarWidth()
   Else
      nScrollWidth := 0
   EndIf

   If r[ 2 ] + r[ 3 ] + nScrollWidth > nClientWidth
      // Move right side into client area
      ListView_Scroll( ::hWnd, ( r[ 2 ] + r[ 3 ] + nScrollWidth - nClientWidth ), 0 )
      // Get new position
      r := ListView_GetSubitemRect( ::hWnd, ThisItemRowIndex - 1, ThisItemColIndex - 1 )  // top, left, width, height
   EndIf
   If r[ 2 ] < 0
      // Move left side into client area
      ListView_Scroll( ::hWnd, r[ 2 ], 0 )
   EndIf

   // Get final position
   r := ListView_GetSubitemRect( ::hWnd, ThisItemRowIndex - 1, ThisItemColIndex - 1 )

   ThisItemCellRow    := r[ 1 ] + aControlRect[ 2 ]
   ThisItemCellCol    := r[ 2 ] + aControlRect[ 1 ]
   ThisItemCellWidth  := r[ 3 ]
   ThisItemCellHeight := r[ 4 ]

   aCellData := { ThisItemRowIndex, ThisItemColIndex, ThisItemCellRow, ThisItemCellCol, ThisItemCellWidth, ThisItemCellHeight }

   Return aCellData

PROCEDURE _SetThisCellInfo( hWnd, nRow, nCol, uValue )

   Local aControlRect, aCellRect

   aControlRect := { 0, 0, 0, 0 }                                               // left, top, right, bottom
   GetWindowRect( hWnd, aControlRect )
   aCellRect := ListView_GetSubitemRect( hWnd, nRow - 1, nCol - 1 )             // top, left, width, height

   _OOHG_ThisItemRowIndex   := nRow
   _OOHG_ThisItemColIndex   := nCol
   _OOHG_ThisItemCellRow    := aCellRect[ 1 ] + aControlRect[ 2 ] + 2
   _OOHG_ThisItemCellCol    := aCellRect[ 2 ] + aControlRect[ 1 ] + 3
   _OOHG_ThisItemCellWidth  := aCellRect[ 3 ]
   _OOHG_ThisItemCellHeight := aCellRect[ 4 ]
   _OOHG_ThisItemCellValue  := uValue

   Return

PROCEDURE _ClearThisCellInfo()

   _OOHG_ThisItemRowIndex   := 0
   _OOHG_ThisItemColIndex   := 0
   _OOHG_ThisItemCellRow    := 0
   _OOHG_ThisItemCellCol    := 0
   _OOHG_ThisItemCellWidth  := 0
   _OOHG_ThisItemCellHeight := 0

   Return

// uValue may be passed by reference
FUNCTION _CheckCellNewValue( oControl, uValue )

   Local lChange, uValue2

   uValue2 := _OOHG_ThisItemCellValue
   If uValue == uValue2
      If ValType( oControl:cMemVar ) $ "CM" .AND. ! Empty( oControl:cMemVar ) .AND. Left( Type( oControl:cMemVar ), 1 ) != "U"
         uValue2 := &( oControl:cMemVar )
      EndIf
   EndIf
   If ! uValue == uValue2
      oControl:ControlValue := uValue2
      _OOHG_ThisItemCellValue := uValue2
      If ValType( oControl:cMemVar ) $ "CM" .AND. ! Empty( oControl:cMemVar )
         &( oControl:cMemVar ) := uValue2
      EndIf
      uValue := uValue2
      lChange := .T.
   Else
      lChange := .F.
   EndIf

   Return lChange

FUNCTION GridControlObject( aEditControl, oGrid )

   Local oGridControl, aEdit2, cControl

   oGridControl := Nil
   If HB_IsArray( aEditControl ) .AND. Len( aEditControl ) >= 1 .AND. ValType( aEditControl[ 1 ] ) $ "CM"
      aEdit2 := AClone( aEditControl )
      ASize( aEdit2, 11 )
      cControl := Upper( AllTrim( aEditControl[ 1 ] ) )
      Do Case
      Case cControl == "MEMO"
         oGridControl := TGridControlMemo():New( aEdit2[ 2 ], aEdit2[ 3 ], oGrid, aEdit2[ 4 ], aEdit2[ 5 ], aEdit2[ 6 ], aEdit2[ 7 ] )
      Case cControl == "DATEPICKER"
         oGridControl := TGridControlDatePicker():New( aEdit2[ 2 ], aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], oGrid, aEdit2[ 6 ] )
      Case cControl == "COMBOBOX"
         oGridControl := TGridControlComboBox():New( aEdit2[ 2 ], oGrid, aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], aEdit2[ 6 ], aEdit2[ 7 ] )
      Case cControl == "COMBOBOXTEXT"
         oGridControl := TGridControlComboBoxText():New( aEdit2[ 2 ], oGrid, aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], aEdit2[ 6 ], aEdit2[ 7 ] )
      Case cControl == "SPINNER"
         oGridControl := TGridControlSpinner():New( aEdit2[ 2 ], aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], oGrid, aEdit2[ 6 ] )
      Case cControl == "CHECKBOX"
         oGridControl := TGridControlCheckBox():New( aEdit2[ 2 ], aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], oGrid, aEdit2[ 6 ] )
      Case cControl == "TEXTBOX"
         oGridControl := TGridControlTextBox():New( aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 2 ], aEdit2[ 5 ], aEdit2[ 6 ], aEdit2[ 7 ], oGrid, aEdit2[ 8 ], aEdit2[ 9 ], aEdit2[ 10 ] )
      Case cControl == "TEXTBOXACTION"
         oGridControl := TGridControlTextBoxAction():New( aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 2 ], aEdit2[ 5 ], aEdit2[ 6 ], aEdit2[ 7 ], oGrid, aEdit2[ 8 ], aEdit2[ 9 ], aEdit2[ 10 ], aEdit2[ 11 ] )
      Case cControl == "IMAGELIST"
         oGridControl := TGridControlImageList():New( oGrid, aEdit2[ 2 ], aEdit2[ 3 ], aEdit2[ 4 ] )
      Case cControl == "IMAGEDATA"
         oGridControl := TGridControlImageData():New( oGrid, GridControlObject( aEdit2[ 2 ], oGrid ), aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ] )
      Case cControl == "LCOMBOBOX"
         oGridControl := TGridControlLComboBox():New( aEdit2[ 2 ], aEdit2[ 3 ], aEdit2[ 4 ], aEdit2[ 5 ], oGrid, aEdit2[ 6 ] )
      EndCase
   EndIf

   Return oGridControl

FUNCTION GridControlObjectByType( uValue, oGrid )

   Local oGridControl := Nil, cMask, nPos

   Do Case
   Case HB_IsNumeric( uValue )
      cMask := Str( uValue )
      cMask := Replicate( "9", Len( cMask ) )
      nPos := At( ".", cMask )
      If nPos != 0
         cMask := Left( cMask, nPos - 1 ) + "." + SubStr( cMask, nPos + 1 )
      EndIf
      oGridControl := TGridControlTextBox():New( cMask, , "N", , , , oGrid )
   Case HB_IsLogical( uValue )
      // oGridControl := TGridControlCheckBox():New( ".T.", ".F.", oGrid )
      oGridControl := TGridControlLComboBox():New( ".T.", ".F.", , , oGrid )
   Case HB_IsDate( uValue )
      // oGridControl := TGridControlDatePicker():New( .T., , oGrid )
      oGridControl := TGridControlTextBox():New( "@D", , "D", , , , oGrid )
   Case ValType( uValue ) == "M"
      oGridControl := TGridControlMemo():New( , , oGrid )
   Case ValType( uValue ) == "C"
      oGridControl := TGridControlTextBox():New( , , "C", , , , oGrid )
   OtherWise
      // Unimplemented data type!!!
   EndCase

   Return oGridControl

FUNCTION GetEditControlFromArray( oEditControl, aEditControls, nColumn, oGrid )

   If HB_IsArray( oEditControl )
      oEditControl := GridControlObject( oEditControl, oGrid )
   EndIf
   If ! HB_IsObject( oEditControl ) .AND. HB_IsArray( aEditControls ) .AND. HB_IsNumeric( nColumn ) .AND. nColumn >= 1 .AND. Len( aEditControls ) >= nColumn
      oEditControl := aEditControls[ nColumn ]
      If HB_IsArray( oEditControl )
         oEditControl := GridControlObject( oEditControl, oGrid )
      EndIf
   EndIf
   If ! HB_IsObject( oEditControl )
      oEditControl := Nil
   EndIf

   Return oEditControl

FUNCTION GetStateListWidth( hwnd )

   Return ImageList_Size( ListView_GetImageList( hwnd, LVSIL_STATE ) )[ 1 ]


CLASS TGridControl

   DATA Type                      INIT "TGRIDCONTROL" READONLY
   DATA oControl                  INIT Nil
   DATA oWindow                   INIT Nil
   DATA oGrid                     INIT Nil
   DATA Value                     INIT Nil
   DATA bWhen                     INIT Nil
   DATA cMemVar                   INIT Nil
   DATA bValid                    INIT Nil
   DATA cValidMessage             INIT Nil
   DATA nDefWidth                 INIT 140
   DATA nDefHeight                INIT 24
   DATA bCancel                   INIT Nil
   DATA bOk                       INIT Nil
   DATA lButtons                  INIT .F.
   DATA cImageOk                  INIT 'EDIT_OK_16'
   DATA cImageCancel              INIT 'EDIT_CANCEL_16'
   DATA lLikeExcel                INIT .F.
   DATA nOnFocusPos               INIT Nil
   DATA lNoModal                  INIT .F.

   METHOD New                     BLOCK { | Self | Self }
   METHOD CreateWindow
   METHOD Valid
   METHOD Str2Val( uValue )       BLOCK { | Self, uValue | Empty( Self ), uValue }
   METHOD GridValue( uValue )     BLOCK { | Self, uValue | Empty( Self ), If( ValType( uValue ) $ "CM", Trim( uValue ), uValue ) }
   METHOD SetFocus                BLOCK { | Self | ::oControl:SetFocus() }
   METHOD SetValue( uValue )      BLOCK { | Self, uValue | ::oControl:Value := uValue }
   METHOD ControlValue            SETGET
   METHOD Enabled                 SETGET
   METHOD OnLostFocus             SETGET
   METHOD Visible                 SETGET

   ENDCLASS

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControl

   Local lRet := .F., i, nSize

   If HB_IsObject( oGrid )
      ::oGrid := oGrid
   EndIf

   If HB_IsObject( ::oGrid ) .AND. ::oGrid:InPlace .AND. ( ::lNoModal .OR. ::oGrid:lNoModal )

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow, nCol WIDTH nWidth HEIGHT nHeight ;
      CHILD NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize ;
      ON INIT ( ::onLostFocus := { |bAux| ::oGrid:bPosition := 9, bAux := ::onLostFocus, ::onLostFocus := Nil, lRet := ::Valid(), ::onLostFocus := bAux } )

      ::bOk := { |nPos, bAux| ::oGrid:bPosition := nPos, bAux := ::onLostFocus, ::onLostFocus := Nil, lRet := ::Valid(), ::onLostFocus := bAux }
      ::bCancel := { || ::oGrid:bPosition := 0, ::oWindow:Release() }

   ElseIf HB_IsObject( ::oGrid )

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow, nCol WIDTH nWidth HEIGHT nHeight ;
      MODAL NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize

      ::bOk := { |nPos| ::oGrid:bPosition := nPos, lRet := ::Valid() }
      ::bCancel := { || ::oGrid:bPosition := 0, ::oWindow:Release() }

   Else

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow, nCol WIDTH nWidth HEIGHT nHeight ;
      MODAL NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize

      ::bOk := { || lRet := ::Valid() }
      ::bCancel := { || ::oWindow:Release() }

   EndIf

      ON KEY RETURN OF ( ::oWindow ) ACTION EVAL( ::bOk, -1 )
      ON KEY ESCAPE OF ( ::oWindow ) ACTION EVAL( ::bCancel )

      If HB_IsArray( aKeys )
         For i := 1 To Len( aKeys )
            If HB_IsArray( aKeys[ i ] ) .AND. Len( aKeys[ i ] ) > 1 .AND. ValType( aKeys[ i, 1 ] ) $ "CM" .AND. HB_IsBlock( aKeys[ i, 2 ] ) .AND. ! ( aKeys[ i, 1 ] == "RETURN" .OR. aKeys[ i, 1 ] == "ESCAPE" )
               _DefineAnyKey( ::oWindow, aKeys[ i, 1 ], aKeys[ i, 2 ] )
            EndIf
         Next
      EndIf

      If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
         nSize := nHeight - 4
         ::CreateControl( uValue, ::oWindow, 0, 0, nWidth - nSize * 2 - 6, nHeight )
         @ 2, nWidth - nSize * 2 - 6 + 2 BUTTON 0 WIDTH nSize HEIGHT nSize ACTION EVAL( ::bOk, -1 ) OF ( ::oWindow ) PICTURE ::cImageOk
         @ 2, nWidth - nSize - 2 BUTTON 0 WIDTH nSize HEIGHT nSize ACTION EVAL( ::bCancel ) OF ( ::oWindow ) PICTURE ::cImageCancel
      Else
         ::CreateControl( uValue, ::oWindow, 0, 0, nWidth, nHeight )
      EndIf
      ::Value := ::ControlValue
   END WINDOW

   If HB_IsObject( ::oControl )
      ::oControl:SetFocus()
   EndIf
   If HB_IsObject( ::oWindow )
      ::oWindow:Activate()
   EndIf
   ::oWindow := Nil

   Return lRet

METHOD Valid() CLASS TGridControl

   Local lValid, uValue, cValidMessage

   uValue := ::ControlValue

   If ValType( ::cMemVar ) $ "CM" .AND. ! Empty( ::cMemVar )
      &( ::cMemVar ) := uValue
   EndIf

   _OOHG_ThisItemCellValue := uValue
   _PushEventInfo()
   lValid := _OOHG_Eval( ::bValid, uValue )
   _PopEventInfo()
   _CheckCellNewValue( Self, @uValue )
   If ! HB_IsLogical( lValid )
      lValid := .T.
   EndIf

   If lValid
      ::Value := uValue
      ::oWindow:Release()
   Else
      cValidMessage := ::cValidMessage
      If HB_IsBlock( cValidMessage )
         cValidMessage := Eval( cValidMessage, uValue )
      EndIf
      If ValType( cValidMessage ) $ "CM" .AND. ! Empty( cValidMessage )
         MsgExclamation( cValidMessage )
      Else
         MsgExclamation( _OOHG_Messages( 3, 11 ) )
      EndIf
      ::oControl:SetFocus()
   EndIf

   Return lValid

METHOD ControlValue( uValue ) CLASS TGridControl

   If PCount() >= 1
      ::oControl:Value := uValue
   EndIf

   Return ::oControl:Value

METHOD Enabled( uValue ) CLASS TGridControl

   Return ( ::oControl:Enabled := uValue )

METHOD Visible( uValue ) CLASS TGridControl

   Return ( ::oControl:Visible := uValue )

METHOD OnLostFocus( uValue ) CLASS TGridControl

   If PCount() >= 1
      ::oControl:OnLostFocus := uValue
   EndIf

   Return ::oControl:OnLostFocus


CLASS TGridControlTextBox FROM TGridControl

   DATA cMask                     INIT ""
   DATA cType                     INIT ""
   DATA cEditKey                  INIT "F2"
   DATA lForceModal               INIT .F.
   DATA Type                      INIT "TGRIDCONTROLTEXTBOX" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val
   METHOD GridValue

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'TEXTBOX', cType, cPicture, cFunction, nOnFocusPos, lButtons, aImages, lLikeExcel, cEditKey, lNoModal}
*/
METHOD New( cPicture, cFunction, cType, nOnFocusPos, lButtons, aImages, oGrid, lLikeExcel, cEditKey, lNoModal ) CLASS TGridControlTextBox

   ::cMask := ""
   If ValType( cPicture ) $ "CM" .AND. ! Empty( cPicture )
      ::cMask := cPicture
   EndIf
   If ValType( cFunction ) $ "CM" .AND. ! Empty( cFunction )
      ::cMask := "@" + cFunction + " " + ::cMask
   EndIf

   If ValType( cType ) $ "CM" .AND. ! Empty( cType )
      cType := Upper( Left( AllTrim( cType ), 1 ) )
      ::cType := If( ( ! cType $ "CDNL" ), "C", cType )
   Else
      ::cType := "C"
   EndIf
   If ::cType == "D" .AND. Empty( ::cMask )
      ::cMask := "@D"
   ElseIf ::cType == "N" .AND. Empty( ::cMask )
//    ::cMask := "@D"
   ElseIf ::cType == "L" .AND. Empty( ::cMask )
      ::cMask := "L"
   EndIf

   ASSIGN ::nOnFocusPos VALUE nOnFocusPos TYPE "N"

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lLikeExcel VALUE lLikeExcel TYPE "L"

   If ValType( cEditKey ) $ "CM"
      ::cEditKey := cEditKey
   ElseIf HB_IsObject( ::oGrid )
      ::cEditKey := ::oGrid:cEditKey
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   // TODO: use buttons with NOMODAL state
   If ::lButtons
      ::lForceModal := .T.
   EndIf

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlTextBox

   Local lRet := .F., i, aPos, nPos1, nPos2, cText, nPos

   If HB_IsObject( oGrid )
      ::oGrid := oGrid
   EndIf

   If HB_IsObject( ::oGrid ) .AND. ::oGrid:InPlace .AND. ( ::lNoModal .OR. ::oGrid:lNoModal ) .AND. ! ::lForceModal

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow - 3, nCol - 3 WIDTH nWidth + 6 HEIGHT nHeight + 6 ;
      CHILD NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize ;
      ON INIT ( ::onLostFocus := { |bAux| ::oGrid:bPosition := 9, bAux := ::onLostFocus, ::onLostFocus := Nil, lRet := ::Valid(), ::onLostFocus := bAux } )

      ::bOk := { |nPos, bAux| ::oGrid:bPosition := nPos, bAux := ::onLostFocus, ::onLostFocus := Nil, lRet := ::Valid(), ::onLostFocus := bAux }
      ::bCancel := { || ::oGrid:bPosition := 0, ::oWindow:Release() }

   ElseIf HB_IsObject( ::oGrid )

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow - 3, nCol - 3 WIDTH nWidth + 6 HEIGHT nHeight + 6 ;
      MODAL NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize

      ::bOk := { |nPos| ::oGrid:bPosition := nPos, lRet := ::Valid() }
      ::bCancel := { || ::oGrid:bPosition := 0, ::oWindow:Release() }

   Else

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow - 3, nCol - 3 WIDTH nWidth + 6 HEIGHT nHeight + 6 ;
      MODAL NOSIZE NOCAPTION ;
      FONT cFontName SIZE nFontSize

      ::bOk := { || lRet := ::Valid() }
      ::bCancel := { || ::oWindow:Release() }

   EndIf

      ON KEY RETURN OF ( ::oWindow ) ACTION EVAL( ::bOk, -1 )
      ON KEY ESCAPE OF ( ::oWindow ) ACTION EVAL( ::bCancel )

      If HB_IsArray( aKeys )
         For i := 1 To Len( aKeys )
            If HB_IsArray( aKeys[ i ] ) .AND. Len( aKeys[ i ] ) > 1
               If ValType( aKeys[ i, 1 ] ) $ "CM" .AND. HB_IsBlock( aKeys[ i, 2 ] )
                  If ! ( aKeys[ i, 1 ] == "RETURN" .OR. aKeys[ i, 1 ] == "ESCAPE" .OR. ( aKeys[ i, 1 ] == ::cEditKey .AND. HB_IsObject( ::oGrid ) .AND. ::oGrid:InPlace .AND. ( ::lLikeExcel .OR. ::oGrid:lLikeExcel ) ) )
                     _DefineAnyKey( ::oWindow, aKeys[ i, 1 ], aKeys[ i, 2 ] )
                  EndIf
               EndIf
            EndIf
         Next
      EndIf

      ::CreateControl( uValue, ::oWindow, 0, 0, nWidth + 6, nHeight + 6 )

      If HB_IsObject( ::oGrid ) .AND. ::oGrid:InPlace .AND. ( ::lLikeExcel .OR. ::oGrid:lLikeExcel ) .AND. ::oGrid:lKeysOn
         ON KEY UP             OF ( ::oControl ) ACTION EVAL( ::bOk, 1 )
         ON KEY RIGHT          OF ( ::oControl ) ACTION EVAL( ::bOk, 2 )
         ON KEY LEFT           OF ( ::oControl ) ACTION EVAL( ::bOk, 3 )
         ON KEY HOME           OF ( ::oControl ) ACTION EVAL( ::bOk, 4 )
         ON KEY END            OF ( ::oControl ) ACTION EVAL( ::bOk, 5 )
         ON KEY DOWN           OF ( ::oControl ) ACTION EVAL( ::bOk, 6 )
         ON KEY PRIOR          OF ( ::oControl ) ACTION EVAL( ::bOk, 7 )
         ON KEY NEXT           OF ( ::oControl ) ACTION EVAL( ::bOk, 8 )
         ON KEY ( ::cEditKey ) OF ( ::oControl ) ACTION TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey )
         ::oControl:OnClick     := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         ::oControl:OnDblClick  := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         ::oControl:OnRClick    := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         ::oControl:OnRDblClick := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         ::oControl:OnMClick    := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         ::oControl:OnMDblClick := { || TGridControlTextBox_ReleaseKeys( ::oControl, ::cEditKey ) }
         If ::oGrid:lKeysLikeClipper
            ON KEY CTRL+HOME   OF ( ::oControl ) ACTION EVAL( ::bOk, 14 )
            ON KEY CTRL+END    OF ( ::oControl ) ACTION EVAL( ::bOk, 15 )
            ON KEY CTRL+PRIOR  OF ( ::oControl ) ACTION EVAL( ::bOk, 17 )
            ON KEY CTRL+NEXT   OF ( ::oControl ) ACTION EVAL( ::bOk, 18 )
         Else
            ON KEY CTRL+RIGHT  OF ( ::oControl ) ACTION EVAL( ::bOk, 12 )
            ON KEY CTRL+LEFT   OF ( ::oControl ) ACTION EVAL( ::bOk, 13 )
         Endif
      EndIf

      ::Value := ::ControlValue
   END WINDOW

   If HB_IsObject( ::oControl )
      ::oControl:SetFocus()
      If HB_IsObject( ::oGrid ) .AND. ::oGrid:InPlace .AND. ( ::lLikeExcel .OR. ::oGrid:lLikeExcel )
         If ::oControl:Type == "TEXTPICTURE"
            If ValType( uValue ) $ "CM" .AND. Len( uValue ) == 1
               aPos := ::oControl:GetSelection()
               nPos1 := aPos[ 1 ]
               nPos2 := aPos[ 2 ]
               cText := ::oControl:Caption
               nPos := nPos1
               cText := TTextPicture_Clear( cText, nPos + 1, nPos2 - nPos1, ::oControl:ValidMask, ::oControl:InsertStatus )
               If TTextPicture_Events2_String( ::oControl, @cText, @nPos, uValue, ::oControl:ValidMask, ::oControl:PictureMask, ::oControl:InsertStatus )
                  ::oControl:Caption := cText
                  SendMessage( ::oControl:hWnd, EM_SETSEL, nPos, nPos )
               EndIf
            EndIf
         Else
            ::oControl:CaretPos := -1
         EndIf
      EndIf
   EndIf
   If HB_IsObject( ::oWindow )
      ::oWindow:Activate()
   EndIf
   ::oWindow := Nil

   Return lRet

FUNCTION TGridControlTextBox_ReleaseKeys( oControl, cEditKey )

   RELEASE KEY LEFT         OF ( oControl )
   RELEASE KEY UP           OF ( oControl )
   RELEASE KEY RIGHT        OF ( oControl )
   RELEASE KEY DOWN         OF ( oControl )
   RELEASE KEY HOME         OF ( oControl )
   RELEASE KEY END          OF ( oControl )
   RELEASE KEY PRIOR        OF ( oControl )
   RELEASE KEY DOWN         OF ( oControl )
   RELEASE KEY CTRL+RIGHT   OF ( oControl )
   RELEASE KEY CTRL+LEFT    OF ( oControl )
   RELEASE KEY CTRL+HOME    OF ( oControl )
   RELEASE KEY CTRL+END     OF ( oControl )
   RELEASE KEY CTRL+PRIOR   OF ( oControl )
   RELEASE KEY CTRL+NEXT    OF ( oControl )
   RELEASE KEY ( cEditKey ) OF ( oControl )

   Return Nil

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlTextBox

   If ValType( uValue ) == "C" .AND. ::cType $ "DNL"
      uValue := ::Str2Val( uValue )
   EndIf
   If ! Empty( ::cMask )
      If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow,nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos
      EndIf
   ElseIf ::cType == "N"
      If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos
      EndIf
   ElseIf ::cType == "D"
      If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos
      EndIf
   Else
      If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos
      EndIf
   EndIf
   If ::lButtons .OR. ( HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons )
      ::oControl:oButton1:TabIndex := 2
   EndIf

   Return ::oControl

METHOD Str2Val( uValue ) CLASS TGridControlTextBox

   Do Case
   Case ::cType == "D"
      uValue := CtoD( uValue )
   Case ::cType == "L"
      uValue := ( PadL( uValue, 1 ) $ "TtYy" )
   Case ::cType == "N"
      uValue := Val( StrTran( _OOHG_UnTransform( uValue, ::cMask, ::cType ), " ", "" ) )
   Case ::cType == "T"
      uValue := CtoT( uValue )
   Otherwise
      If ! Empty( ::cMask )
         uValue := _OOHG_UnTransform( uValue, ::cMask, ::cType )
      EndIf
   EndCase

   Return uValue

METHOD GridValue( uValue ) CLASS TGridControlTextBox

   If Empty( ::cMask )
      If ::cType == "D"
         uValue := DtoC( uValue )
      ElseIf ::cType == "N"
         uValue := LTrim( Str( uValue ) )
      ElseIf ::cType == "L"
         uValue := If( uValue, "T", "F" )
      ElseIf ::cType $ "CM"
         uValue := Trim( uValue )
      ElseIf ::cType == "T"
         uValue := TtoC( uValue )
      EndIf
   Else
      uValue := Trim( Transform( uValue, ::cMask ) )
   EndIf

   Return uValue


CLASS TGridControlTextBoxAction FROM TGridControlTextBox

   DATA bAction                   INIT Nil
   DATA bAction2                  INIT Nil
   DATA Type                      INIT "TGRIDCONTROLTEXTBOXACTION" READONLY

   METHOD New
   METHOD CreateControl

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'TEXTBOXACTION', cType, cPicture, cFunction, nOnFocusPos, aImages, lLikeExcel, cEditKey, lNoModal, bAction, bAction2}
*/
METHOD New( cPicture, cFunction, cType, nOnFocusPos, aImages, oGrid, lLikeExcel, cEditKey, lNoModal, bAction, bAction2 ) CLASS TGridControlTextBoxAction

   ::cMask := ""
   If ValType( cPicture ) $ "CM" .AND. ! Empty( cPicture )
      ::cMask := cPicture
   EndIf
   If ValType( cFunction ) $ "CM" .AND. ! Empty( cFunction )
      ::cMask := "@" + cFunction + " " + ::cMask
   EndIf

   If ValType( cType ) $ "CM" .AND. ! Empty( cType )
      cType := Upper( Left( AllTrim( cType ), 1 ) )
      ::cType := If( ( ! cType $ "CDNL" ), "C", cType )
   Else
      ::cType := "C"
   EndIf
   If ::cType == "D" .AND. Empty( ::cMask )
      ::cMask := "@D"
   ElseIf ::cType == "N" .AND. Empty( ::cMask )
//    ::cMask := "@D"
   ElseIf ::cType == "L" .AND. Empty( ::cMask )
      ::cMask := "L"
   EndIf

   ASSIGN ::nOnFocusPos VALUE nOnFocusPos TYPE "N"

   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lLikeExcel VALUE lLikeExcel TYPE "L"

   If ValType( cEditKey ) $ "CM"
      ::cEditKey := cEditKey
   ElseIf HB_IsObject( ::oGrid )
      ::cEditKey := ::oGrid:cEditKey
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"
   ASSIGN ::bAction  VALUE bAction  TYPE "B"
   ASSIGN ::bAction2 VALUE bAction2 TYPE "B"

   // TODO: use actions with NOMODAL state
   If HB_IsBlock( ::bAction ) .OR. HB_IsBlock( ::bAction2 )
      ::lForceModal := .T.
   EndIf

   Return Self

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlTextBoxAction

   If ValType( uValue ) == "C" .AND. ::cType $ "DNL"
      uValue := ::Str2Val( uValue )
   EndIf
   If ! Empty( ::cMask )
      If HB_IsBlock( ::bAction ) .AND. HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) ACTION2 EVAL( ::bAction2 ) IMAGE {::cImageCancel, ::cImageOk}
      ElseIf HB_IsBlock( ::bAction )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) IMAGE {::cImageCancel, }
      ElseIf HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos ACTION2 EVAL( ::bAction2 ) IMAGE { , ::cImageOk}
      ElseIf HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow,nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue INPUTMASK ::cMask FOCUSEDPOS ::nOnFocusPos
      EndIf
   ElseIf ::cType == "N"
      If HB_IsBlock( ::bAction ) .AND. HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) ACTION2 EVAL( ::bAction2 ) IMAGE {::cImageCancel, ::cImageOk}
      ElseIf HB_IsBlock( ::bAction )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) IMAGE {::cImageCancel, }
      ElseIf HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos ACTION2 EVAL( ::bAction2 ) IMAGE { , ::cImageOk}
      ElseIf HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue NUMERIC FOCUSEDPOS ::nOnFocusPos
      EndIf
   ElseIf ::cType == "D"
      If HB_IsBlock( ::bAction ) .AND. HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) ACTION2 EVAL( ::bAction2 ) IMAGE {::cImageCancel, ::cImageOk}
      ElseIf HB_IsBlock( ::bAction )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) IMAGE {::cImageCancel, }
      ElseIf HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos ACTION2 EVAL( ::bAction2 ) IMAGE { , ::cImageOk}
      ElseIf HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue DATE FOCUSEDPOS ::nOnFocusPos
      EndIf
   Else
      If HB_IsBlock( ::bAction ) .AND. HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) ACTION2 EVAL( ::bAction2 ) IMAGE {::cImageCancel, ::cImageOk}
      ElseIf HB_IsBlock( ::bAction )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bAction ) IMAGE {::cImageCancel, }
      ElseIf HB_IsBlock( ::bAction2 )
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos ACTION2 EVAL( ::bAction2 ) IMAGE { , ::cImageOk}
      ElseIf HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos ACTION EVAL( ::bCancel ) ACTION2 EVAL( ::bOK, -1 ) IMAGE {::cImageCancel, ::cImageOk}
      Else
        @ nRow, nCol TEXTBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue FOCUSEDPOS ::nOnFocusPos
      EndIf
   EndIf
   If HB_IsBlock( ::bAction )
      ::oControl:oButton1:TabIndex := 2
   ElseIf HB_IsBlock( ::bAction2 )
      ::oControl:oButton1:TabIndex := 2
   ElseIf HB_IsObject( ::oGrid ) .AND. ::oGrid:lButtons
      ::oControl:oButton1:TabIndex := 2
   EndIf

   Return ::oControl


CLASS TGridControlMemo FROM TGridControl

   DATA nDefHeight                INIT 84
   DATA cTitle                    INIT _OOHG_Messages( 1, 11 )
   DATA lCleanCRLF                INIT .F.
   DATA nWidth                    INIT 350
   DATA nHeight                   INIT 265
   DATA lSize                     INIT .F.
   DATA lNoHScroll                INIT .F.
   DATA Type                      INIT "TGRIDCONTROLMEMO" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD GridValue

   ENDCLASS

   /*
   COLUMNCONTROLS syntax:
   {'MEMO', cTitle, lCleanCRLF, nWidth, nHeight, lSize, lNoHScroll}
   */
METHOD New( cTitle, lCleanCRLF, oGrid, nWidth, nHeight, lSize, lNoHScroll ) CLASS TGridControlMemo

   If ValType( cTitle ) $ "CM" .AND. ! Empty( cTitle )
      ::cTitle := cTitle
   EndIf
   If HB_IsLogical( lCleanCRLF )
      ::lCleanCRLF := lCleanCRLF
   EndIf
   ::oGrid := oGrid
   If HB_IsNumeric( nWidth ) .and. nWidth > 230
      ::nWidth := nWidth
   EndIf
   If HB_IsNumeric( nHeight ) .and. nHeight > 230
      ::nHeight := nHeight
   EndIf
   If HB_IsLogical( lSize )
      ::lSize := lSize
   EndIf
   If HB_IsLogical( lNoHScroll )
      ::lNoHScroll := lNoHScroll
   EndIf

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlMemo

   Local lRet := .F., i, oBut1, oBut2

   HB_SYMBOL_UNUSED( nWidth )
   HB_SYMBOL_UNUSED( nHeight )

   If ::lSize

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow, nCol ;
      WIDTH ::nWidth ;
      HEIGHT ::nHeight ;
      CLIENTAREA ;
      MINWIDTH 350 ;
      MINHEIGHT 265 ;
      TITLE ::cTitle ;
      MODAL ;
      ON SIZE ( ::oControl:Width := ::oWindow:ClientWidth - 20, ;
                ::oControl:Height := ::oWindow:ClientHeight - 90, ;
                i := Int( Max( ::oWindow:ClientWidth - 200, 0 ) / 3 ), ;
                oBut1:Row := ::oWindow:ClientHeight - 40, ;
                oBut1:Col := i, ;
                oBut2:Row := oBut1:Row, ;
                oBut2:Col := i + 100 + i )

   Else

   DEFINE WINDOW 0 OBJ ::oWindow ;
      AT nRow, nCol ;
      WIDTH ::nWidth ;
      HEIGHT ::nHeight ;
      CLIENTAREA ;
      TITLE ::cTitle ;
      MODAL ;
      NOSIZE

   EndIf

      If HB_IsObject( oGrid )
         ::oGrid := oGrid
         ::bOk := { |nPos| ::oGrid:bPosition := nPos, lRet := ::Valid() }
         ::bCancel := { || ::oGrid:bPosition := 0, ::oWindow:Release() }
      Else
         ::bOk := { || lRet := ::Valid() }
         ::bCancel := { || ::oWindow:Release() }
      EndIf

      ON KEY ESCAPE OF ( ::oWindow ) ACTION EVAL( ::bCancel )

      If HB_IsArray( aKeys )
         For i := 1 To Len( aKeys )
            If HB_IsArray( aKeys[ i ] ) .AND. Len( aKeys[ i ] ) > 1 .AND. ValType( aKeys[ i, 1 ] ) $ "CM" .AND. HB_IsBlock( aKeys[ i, 2 ] ) .AND. ! aKeys[ i, 1 ] == "ESCAPE"
               _DefineAnyKey( ::oWindow, aKeys[ i, 1 ], aKeys[ i, 2 ] )
            EndIf
         Next
      EndIf

      @ 07,10 LABEL 0 PARENT ( ::oWindow ) VALUE "" WIDTH 280

      ::CreateControl( uValue, ::oWindow:Name, 30, 10, ::oWindow:ClientWidth - 20, ::oWindow:ClientHeight - 90 )
      ::oControl:SetFont( cFontName, nFontSize )
      ::Value := ::ControlValue

      i := Int( Max( ::oWindow:ClientWidth - 200, 0 ) / 3 )

      @ ::oWindow:ClientHeight - 40,i BUTTON 0 OBJ oBut1 PARENT ( ::oWindow ) CAPTION _OOHG_Messages( 1, 6 ) ACTION EVAL( ::bOk, -1 )
      @ oBut1:Row,i + 100 + i BUTTON 0 OBJ oBut2 PARENT ( ::oWindow ) CAPTION _OOHG_Messages( 1, 7 ) ACTION EVAL( ::bCancel )
   END WINDOW

   ::oWindow:Center()
   ::oControl:SetFocus()
   ::oWindow:Activate()
   ::oWindow := Nil

   Return lRet

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlMemo

   If ::lNoHScroll
      @ nRow,nCol EDITBOX 0 OBJ ::oControl PARENT ( cWindow ) VALUE StrTran( uValue, Chr(141), ' ' ) HEIGHT nHeight WIDTH nWidth NOHSCROLL
   Else
      @ nRow,nCol EDITBOX 0 OBJ ::oControl PARENT ( cWindow ) VALUE StrTran( uValue, Chr(141), ' ' ) HEIGHT nHeight WIDTH nWidth
   EndIf

   Return ::oControl

METHOD GridValue( uValue ) CLASS TGridControlMemo

   Local uRet

   If ValType( uValue ) == "C"
      uRet := Trim( uValue )
   ElseIf ValType( uValue ) == "M"
      If ::lCleanCRLF
         uRet := StrTran( Trim( uValue ), Chr(13) + Chr(10), " " )
      Else
         uRet := Trim( uValue )
      EndIf
   Else
      uRet := uValue
   EndIf

   Return uRet


CLASS TGridControlDatePicker FROM TGridControl

   DATA lUpDown
   DATA lShowNone
   DATA Type                      INIT "TGRIDCONTROLDATEPICKER" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val( uValue )   BLOCK { |Self, uValue| Empty( Self ), CtoD( uValue ) }
   METHOD GridValue( uValue ) BLOCK { |Self, uValue| Empty( Self ), DtoC( uValue ) }

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'DATEPICKER', lUpDown, lShowNone, lButtons, aImages, lNoModal}
*/
METHOD New( lUpDown, lShowNone, lButtons, aImages, oGrid, lNoModal ) CLASS TGridControlDatePicker

   If ! HB_IsLogical( lUpDown )
      lUpDown := .F.
   EndIf
   ::lUpDown := lUpDown

   If ! HB_IsLogical( lShowNone )
      lShowNone := .F.
   EndIf
   ::lShowNone := lShowNone

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlDatePicker

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlDatePicker

   If ValType( uValue ) == "C"
      uValue := CtoD( uValue )
   EndIf
   If ::lUpDown
      If ::lShowNone
         @ nRow,nCol DATEPICKER 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue UPDOWN SHOWNONE
      Else
         @ nRow,nCol DATEPICKER 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue UPDOWN
      EndIf
   Else
      If ::lShowNone
         @ nRow,nCol DATEPICKER 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue SHOWNONE
      Else
         @ nRow,nCol DATEPICKER 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth HEIGHT nHeight VALUE uValue
      EndIf
   EndIf

   Return ::oControl


CLASS TGridControlComboBox FROM TGridControl

   DATA aItems                    INIT {}
   DATA aValues                   INIT Nil
   DATA cWorkArea                 INIT ""
   DATA cField                    INIT ""
   DATA cValueSource              INIT ""
   DATA cRetValType               INIT "N"   // Needed because cWorkArea can be not opened yet when ::New is first executed
   DATA Type                      INIT "TGRIDCONTROLCOMBOBOX" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val
   METHOD GridValue
   METHOD Refresh

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'COMBOBOX', aItems, aValues, cRetValType, lButtons, aImages, lNoModal}
*/
METHOD New( aItems, oGrid, aValues, cRetValType, lButtons, aImages, lNoModal ) CLASS TGridControlComboBox

   DEFAULT cRetValType TO "NUMERIC"
   If HB_IsArray( aItems )
      ::aItems := aItems
      If HB_IsArray( aValues ) .AND. Len( aValues ) > 0
         If ValType( aValues[1] ) $ "CM"
            ::aValues := aValues
            ::cRetValType := "C"
         ElseIf ValType( aValues[1] ) == "N"
            ::aValues := aValues
         EndIf
      EndIf
   ElseIf ValType( aItems ) $ "CM" .AND. '->' $ aItems
      ::cWorkArea := Left( aItems, At( '->', aItems ) - 1 )
      ::cField := Right( aItems, Len( aItems ) - At( '->', aItems ) - 1 )
      If ValType( aValues ) $ "CM"
         If Upper( cRetValType ) == "CHARACTER"
            ::cValueSource := aValues
            ::cRetValType := "C"
         ElseIf Upper( cRetValType ) == "NUMERIC"
            ::cValueSource := aValues
         EndIf
      EndIf
      ::Refresh()
   EndIf
   ::oGrid := oGrid

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD Refresh CLASS TGridControlComboBox

   Local cValueSource, cWorkArea, cField, nRecno, aIt, aVa, uValue

   cWorkArea := ::cWorkArea
   cField := ::cField
   cValueSource := ::cValueSource
   If Select( cWorkArea ) != 0
      nRecno := ( cWorkArea )->( RecNo() )
      ( cWorkArea )->( DBGoTop() )
      aIt := {}
      aVa := {}
      Do While ! ( cWorkArea )->( Eof() )
         AAdd( aIt, ( cWorkArea )->&( cField ) )
         If Empty( cValueSource )
            uValue := ( cWorkArea )->( RecNo() )
         Else
            uValue := &( cValueSource )
            If ! ValType( uValue ) == ::cRetValType
               MsgOOHGError( "GridControl: ValueSource/RetVal type mismatch. Program terminated." )
            EndIf
         EndIf
         AAdd( aVa, uValue )
         ( cWorkArea )->( DBSkip() )
      EndDo
      ( cWorkArea )->( DBGoTo( nRecno ) )
      ::aItems := aIt
      ::aValues := aVa
   EndIf

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlComboBox

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlComboBox

   HB_SYMBOL_UNUSED( nHeight )

   ::Refresh()
   @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS ::aItems VALUESOURCE ( ::aValues )
   If ! Empty( ::oGrid ) .AND. ValidHandler( ::oGrid:ImageList )
      ::oControl:ImageList := ImageList_Duplicate( ::oGrid:ImageList )
   EndIf

   Return ::oControl

METHOD Str2Val( uValue ) CLASS TGridControlComboBox

   Local xValue

   xValue := AScan( ::aItems, { |c| c == uValue } )
   If HB_IsArray( ::aValues )
      If xValue >= 1 .AND. xValue <= Len( ::aValues )
         xValue := ::aValues[ xValue ]
      ElseIf ::cRetValType == "C"
         xValue := ""
      Else
         xValue := 0
      EndIf
   ElseIf ::cRetValType == "C"
      xValue := ""
   EndIf

   Return xValue

METHOD GridValue( uValue ) CLASS TGridControlComboBox

   If HB_IsArray( ::aValues )
      uValue := AScan( ::aValues, { |c| c == uValue } )
   ElseIf ! ValType( uValue ) == "N"
     uValue := 0
   EndIf

   Return If( ( uValue >= 1 .AND. uValue <= Len( ::aItems ) ), ::aItems[ uValue ], "" )


CLASS TGridControlComboBoxText FROM TGridControl

   DATA aItems                    INIT {}
   DATA lIncremental              INIT .F.
   DATA lWinSize                  INIT .F.
   DATA Type                      INIT "TGRIDCONTROLCOMBOBOXTEXT" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val
   METHOD GridValue( uValue )     BLOCK { |Self, uValue| ::Str2Val( uValue ) }
   METHOD ControlValue            SETGET

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'COMBOBOXTEXT', aItems, lIncremental, lWinSize, lButtons, aImages, lNoModal}
*/
METHOD New( aItems, oGrid, lIncremental, lWinSize, lButtons, aImages, lNoModal ) CLASS TGridControlComboBoxText

   ASSIGN ::lIncremental VALUE lIncremental TYPE "L" DEFAULT .F.
   ASSIGN ::lWinSize     VALUE lWinSize     TYPE "L" DEFAULT .F.
   If HB_IsArray( aItems )
      ::aItems := Array( Len( aItems ) )
      AEval( aItems, { |x,i| ::aItems[ i ] := Trim( x ) } )
   EndIf
   ::oGrid := oGrid

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlComboBoxText

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlComboBoxText

   HB_SYMBOL_UNUSED( nHeight )

   uValue := AScan( ::aItems, { |c| c == uValue } )
   If ::lIncremental
      If ::lWinSize
         @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS ::aItems INTEGRALHEIGHT INCREMENTAL
      Else
         @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS ::aItems INCREMENTAL
      EndIf
   Else
      If ::lWinSize
         @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS ::aItems INTEGRALHEIGHT
      Else
         @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS ::aItems
      EndIf
   EndIf
   If ! Empty( ::oGrid ) .AND. ValidHandler( ::oGrid:ImageList )
      ::oControl:ImageList := ImageList_Duplicate( ::oGrid:ImageList )
   EndIf

   Return ::oControl

METHOD Str2Val( uValue ) CLASS TGridControlComboBoxText

   Local nPos

   nPos := AScan( ::aItems, { |c| c == Trim( uValue ) } )

   Return If( nPos == 0, "", ::aItems[ nPos ] )

METHOD ControlValue( uValue ) CLASS TGridControlComboBoxText

   Local nPos

   If PCount() >= 1
      ::oControl:Value := ::Str2Val( uValue )
   EndIf
   nPos := ::oControl:Value

   Return If( nPos == 0, "", ::aItems[ nPos ] )


CLASS TGridControlSpinner FROM TGridControl

   DATA nRangeMin                 INIT 0
   DATA nRangeMax                 INIT 100
   DATA Type                      INIT "TGRIDCONTROLSPINNER" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val( uValue )       BLOCK { |Self, uValue| Empty( Self ), Val( AllTrim( uValue ) ) }
   METHOD GridValue( uValue)      BLOCK { |Self, uValue| Empty( Self ), LTrim( Str( uValue ) ) }

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'SPINNER', nRangeMin, nRangeMax, lButtons, aImages, lNoModal}
*/
METHOD New( nRangeMin, nRangeMax, lButtons, aImages, oGrid, lNoModal ) CLASS TGridControlSpinner

   If HB_IsNumeric( nRangeMin )
      ::nRangeMin := nRangeMin
   EndIf
   If HB_IsNumeric( nRangeMax )
      ::nRangeMax := nRangeMax
   EndIf

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlSpinner

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlSpinner

   If ValType( uValue ) == "C"
      uValue := Val( uValue )
   EndIf
   @ nRow,nCol SPINNER 0 OBJ ::oControl PARENT ( cWindow ) RANGE ::nRangeMin, ::nRangeMax WIDTH nWidth HEIGHT nHeight VALUE uValue

   Return ::oControl


CLASS TGridControlCheckBox FROM TGridControl

   DATA cTrue                     INIT ".T."
   DATA cFalse                    INIT ".F."
   DATA Type                      INIT "TGRIDCONTROLCHECKBOX" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val( uValue )       BLOCK { |Self, uValue| ( uValue == ::cTrue .OR. Upper( uValue ) == ".T." ) }
   METHOD GridValue( uValue )     BLOCK { |Self, uValue| If( uValue, ::cTrue, ::cFalse ) }

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'CHECKBOX', cTrue, cFalse, lButtons, aImages, lNoModal}
*/
METHOD New( cTrue, cFalse, lButtons, aImages, oGrid, lNoModal ) CLASS TGridControlCheckBox

   If ValType( cTrue ) $ "CM"
      ::cTrue := cTrue
   EndIf
   If ValType( cFalse ) $ "CM"
      ::cFalse := cFalse
   EndIf

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlCheckBox

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlCheckBox

   If ValType( uValue ) == "C"
      uValue := ( uValue == ::cTrue .OR. Upper( uValue ) == ".T." )
   EndIf
   @ nRow,nCol CHECKBOX 0 OBJ ::oControl PARENT ( cWindow ) CAPTION If( uValue, ::cTrue, ::cFalse ) WIDTH nWidth HEIGHT nHeight VALUE uValue ;
               ON CHANGE ( ::oControl:Caption := If( ::oControl:Value, ::cTrue, ::cFalse ) )

   Return ::oControl


CLASS TGridControlImageList FROM TGridControl

   DATA Type                      INIT "TGRIDCONTROLIMAGELIST" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val( uValue )       BLOCK { |Self, uValue| Empty( Self ), If( ValType( uValue ) == "C", Val( uValue ), uValue ) }
   METHOD ControlValue            SETGET

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'IMAGELIST', lButtons, aImages, lNoModal}
*/
METHOD New( oGrid, lButtons, aImages, lNoModal ) CLASS TGridControlImageList

   ::oGrid := oGrid
   If ! Empty( ::oGrid ) .AND. ValidHandler( ::oGrid:ImageList )
      ::nDefHeight := ImageList_Size( ::oGrid:ImageList )[ 2 ] + 6
   EndIf

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlImageList

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlImageList

   HB_SYMBOL_UNUSED( nHeight )

   If ValType( uValue ) == "C"
      uValue := Val( uValue )
   EndIf
   If ! Empty( ::oGrid ) .AND. ValidHandler( ::oGrid:ImageList )
      @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE 0 ITEMS {} IMAGE {} TEXTHEIGHT ImageList_Size( ::oGrid:ImageList )[ 2 ]
      ::oControl:ImageList := ImageList_Duplicate( ::oGrid:ImageList )
      AEval( Array( ImageList_GetImageCount( ::oGrid:ImageList ) ), { |x,i| ::oControl:AddItem( i - 1 ), x } )
   Else
      @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE 0 ITEMS {}
   EndIf
   ::oControl:Value := uValue + 1

   Return ::oControl

METHOD ControlValue( uValue ) CLASS TGridControlImageList

   If PCount() >= 1
      ::oControl:Value := uValue + 1
   EndIf

   Return ::oControl:Value - 1


CLASS TGridControlImageData FROM TGridControl

   DATA Type                      INIT "TGRIDCONTROLIMAGEDATA" READONLY
   DATA oData

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD ControlValue            SETGET
   METHOD OnLostFocus             SETGET
   METHOD Enabled                 SETGET

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'IMAGEDATA', oData, lButtons, aImages, lNoModal}
*/
METHOD New( oGrid, oData, lButtons, aImages, lNoModal ) CLASS TGridControlImageData

   ::oGrid := oGrid
   If oData == Nil
      oData := TGridControlTextBox():New
   EndIf
   ::oData := oData

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlImageData

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlImageData

   Local oCData, oCImage, nSize

   If ValType( uValue[ 2 ] ) == "C"
      uValue[ 2 ] := Val( uValue[ 2 ] )
   EndIf
   nSize := LoWord( GetDialogBaseUnits() ) + GetVScrollBarWidth()
   nHeight := 6
   If ! Empty( ::oGrid ) .AND. ValidHandler( ::oGrid:ImageList )
      nSize += ImageList_Size( ::oGrid:ImageList )[ 1 ]
      nHeight += ImageList_Size( ::oGrid:ImageList )[ 2 ]
      @ nRow,nCol COMBOBOX 0 OBJ oCImage PARENT ( cWindow ) WIDTH nSize VALUE 0 ITEMS {} IMAGE {} TEXTHEIGHT ImageList_Size( ::oGrid:ImageList )[ 2 ]
      oCImage:ImageList := ImageList_Duplicate( ::oGrid:ImageList )
      AEval( Array( ImageList_GetImageCount( ::oGrid:ImageList ) ), { |x,i| oCImage:AddItem( i - 1 ), x } )
   Else
      @ nRow,nCol COMBOBOX 0 OBJ oCImage PARENT ( cWindow ) WIDTH nSize VALUE 0 ITEMS {}
   EndIf
   oCData := ::oData:CreateControl( uValue[ 1 ], cWindow, nRow, nCol + nSize, nWidth - nSize, nHeight )
   ::oControl := { oCData, oCImage }
   oCImage:Value := uValue[ 2 ] + 1

   Return ::oControl

METHOD ControlValue( uValue ) CLASS TGridControlImageData

   Local oCData, oCImage

   oCData := ::oControl[1]
   oCImage := ::oControl[2]
   If PCount() >= 1
      oCData:value := uValue[1]
      oCImage:value := uValue[2] + 1
   EndIf

   Return { oCData:Value, oCImage:value - 1 }

METHOD OnLostFocus( uValue ) CLASS TGridControlImageData

   Local oCData

   oCData := ::oControl[1]
   If PCount() >= 1
      oCData:OnLostFocus := uValue
   EndIf

   Return oCData:OnLostFocus

METHOD Enabled( uValue ) CLASS TGridControlImageData

   Local oCData

   oCData := ::oControl[1]

   Return ( oCData:Enabled := uValue )


CLASS TGridControlLComboBox FROM TGridControl

   DATA cTrue                     INIT ".T."
   DATA cFalse                    INIT ".F."
   DATA Type                      INIT "TGRIDCONTROLLCOMBOBOX" READONLY

   METHOD New
   METHOD CreateWindow
   METHOD CreateControl
   METHOD Str2Val( uValue )       BLOCK { |Self, uValue| ( uValue == ::cTrue .OR. Upper( uValue ) == ".T." ) }
   METHOD GridValue( uValue )     BLOCK { |Self, uValue| If( uValue, ::cTrue, ::cFalse ) }
   METHOD ControlValue            SETGET

   ENDCLASS

/*
COLUMNCONTROLS syntax:
{'LCOMBOBOX', cTrue, cFalse, lButtons, aImages, lNoModal}
*/
METHOD New( cTrue, cFalse, lButtons, aImages, oGrid, lNoModal ) CLASS TGridControlLComboBox

   If ValType( cTrue ) $ "CM"
      ::cTrue := cTrue
   EndIf
   If ValType( cFalse ) $ "CM"
      ::cFalse := cFalse
   EndIf

   ASSIGN ::lButtons VALUE lButtons TYPE "L"
   If HB_IsArray( aImages )
     If Len( aImages ) < 2
       ASize( aImages, 2 )
     EndIf
     ASSIGN ::cImageCancel VALUE aImages[ 1 ] TYPE "CM"
     ASSIGN ::cImageOk     VALUE aImages[ 2 ] TYPE "CM"
   EndIf

   ::oGrid := oGrid

   ASSIGN ::lNoModal VALUE lNoModal TYPE "L"

   Return Self

METHOD CreateWindow( uValue, nRow, nCol, nWidth, nHeight, cFontName, nFontSize, aKeys, oGrid ) CLASS TGridControlLComboBox

   Return ::Super:CreateWindow( uValue, nRow - 3, nCol - 3, nWidth + 6, nHeight + 6, cFontName, nFontSize, aKeys, oGrid )

METHOD CreateControl( uValue, cWindow, nRow, nCol, nWidth, nHeight ) CLASS TGridControlLComboBox

   HB_SYMBOL_UNUSED( nHeight )

   If ValType( uValue ) == "C"
      uValue := ( uValue == ::cTrue .OR. Upper( uValue ) == ".T." )
   EndIf
   uValue := If( uValue, 1, 2 )
   @ nRow,nCol COMBOBOX 0 OBJ ::oControl PARENT ( cWindow ) WIDTH nWidth VALUE uValue ITEMS { ::cTrue, ::cFalse }

   Return ::oControl

METHOD ControlValue( uValue ) CLASS TGridControlLComboBox

   If PCount() >= 1
      ::oControl:Value := If( uValue, 1, 2 )
   EndIf

   Return ( ::oControl:Value == 1 )


EXTERN InitListView, InitListViewColumns, AddListViewItems, InsertListViewItem
EXTERN ListViewSetItem, ListViewGetItem, FillGridFromArray
EXTERN ListView_SetItemCount, ListView_GetFirstItem, ListView_SetCurSel, ListViewDeleteString
EXTERN ListViewReset, ListViewGetMultiSel, ListViewSetMultiSel, ListViewGetItemRow
EXTERN ListViewGetItemCount, ListViewGetCountPerPage, ListView_EnsureVisible, ListView_GetTopIndex
EXTERN ListView_RedrawItems, ListView_HitTest, ListView_GetSubItemRect, ListView_GetItemRect
EXTERN ListView_Update, ListView_Scroll, ListView_SetBkColor, ListView_SetTextBkColor
EXTERN ListView_SetTextColor, ListView_GetTextColor, ListView_GetBkColor, ListView_GetColumnWidth
EXTERN ListView_SetColumnWidth, _OOHG_GridArrayWidths, ListView_AddColumn, ListView_DeleteColumn
EXTERN GetGridVKey, TGrid_Notify_CustomDraw

#pragma BEGINDUMP

#ifndef HB_OS_WIN_32_USED
   #define HB_OS_WIN_32_USED
#endif

#ifndef WINVER
   #define WINVER 0x0500
#endif
#if ( WINVER < 0x0500 )
   #undef WINVER
   #define WINVER 0x0500
#endif

#ifndef _WIN32_IE
   #define _WIN32_IE 0x0400
#endif
#if ( _WIN32_IE < 0x0400 )
   #undef _WIN32_IE
   #define _WIN32_IE 0x0400
#endif

#ifndef _WIN32_WINNT
   #define _WIN32_WINNT 0x0500
#endif
#if ( _WIN32_WINNT < 0x0500 )
   #undef _WIN32_WINNT
   #define _WIN32_WINNT 0x0500
#endif

#include "hbapi.h"
#include "hbapiitm.h"
#include "hbvm.h"
#include "hbstack.h"
#include <windows.h>
#include <windowsx.h>
#include <commctrl.h>
#include "oohg.h"

#ifndef LVS_EX_DOUBLEBUFFER
   #define LVS_EX_DOUBLEBUFFER 0x00010000
#endif

#ifndef WM_MOUSEWHEEL
   #define WM_MOUSEWHEEL  0x020A
#endif

#define s_Super s_TControl

// -----------------------------------------------------------------------------
HB_FUNC_STATIC( TGRID_EVENTS )   // METHOD Events( hWnd, nMsg, wParam, lParam ) CLASS TGrid
// -----------------------------------------------------------------------------
{
   HWND hWnd = HWNDparam( 1 );
   UINT message = (UINT ) hb_parni( 2 );
   WPARAM wParam = (WPARAM) hb_parni( 3 );
   LPARAM lParam = (LPARAM) hb_parnl( 4 );
   PHB_ITEM pSelf = hb_stackSelfItem();
   static PHB_SYMB s_Events2 = 0;                             //  TODO: Thread safe ?
   static PHB_SYMB s_Notify2 = 0;                             //  TODO: Thread safe ?
   BOOL bDefault = TRUE;

   switch( message )
   {
      case WM_MOUSEWHEEL:
      case WM_CHAR:
      case WM_LBUTTONDBLCLK:
         if( ! s_Events2 )
         {
            s_Events2 = hb_dynsymSymbol( hb_dynsymFind( "_OOHG_TGRID_EVENTS2" ) );
         }
         hb_vmPushSymbol( s_Events2 );
         hb_vmPushNil();
         hb_vmPush( pSelf );
         HWNDpush( hWnd );
         hb_vmPushLong( message );
         hb_vmPushLong( wParam );
         hb_vmPushLong( lParam );
         hb_vmDo( 5 );
         bDefault = FALSE;
         break;

      case WM_NOTIFY:
         if( ( ( NMHDR FAR * ) lParam )->hwndFrom == ( HWND ) SendMessage( hWnd, LVM_GETHEADER, 0, 0 ) )
         {
            if( ! s_Notify2 )
            {
               s_Notify2 = hb_dynsymSymbol( hb_dynsymFind( "_OOHG_TGRID_NOTIFY2" ) );
            }
            hb_vmPushSymbol( s_Notify2 );
            hb_vmPushNil();
            hb_vmPush( pSelf );
            hb_vmPushLong( wParam );
            hb_vmPushLong( lParam );
            hb_vmDo( 3 );
            if( HB_ISNUM( -1 ) )
            {
               bDefault = FALSE;
            }
         }
         break;
   }

   if( bDefault )
   {
      _OOHG_Send( pSelf, s_Super );
      hb_vmSend( 0 );
      _OOHG_Send( hb_param( -1, HB_IT_OBJECT ), s_Events );
      HWNDpush( hWnd );
      hb_vmPushLong( message );
      hb_vmPushLong( wParam );
      hb_vmPushLong( lParam );
      hb_vmSend( 4 );
   }
}

HB_FUNC_STATIC( TGRID_FONTCOLOR )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );

   if( _OOHG_DetermineColorReturn( hb_param( 1, HB_IT_ANY ), &oSelf->lFontColor, ( hb_pcount() >= 1 ) ) )
   {
      if( ValidHandler( oSelf->hWnd ) )
      {
         if( oSelf->lFontColor != -1 )
         {
            ListView_SetTextColor( oSelf->hWnd, oSelf->lFontColor );
         }
         else
         {
            ListView_SetTextColor( oSelf->hWnd, GetSysColor( COLOR_WINDOWTEXT ) );
         }
         RedrawWindow( oSelf->hWnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
      }
   }

   // Return value was set in _OOHG_DetermineColorReturn()
}

HB_FUNC_STATIC( TGRID_BACKCOLOR )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );

   if( _OOHG_DetermineColorReturn( hb_param( 1, HB_IT_ANY ), &oSelf->lBackColor, ( hb_pcount() >= 1 ) ) )
   {
      if( ValidHandler( oSelf->hWnd ) )
      {
         if( oSelf->lBackColor != -1 )
         {
            ListView_SetBkColor( oSelf->hWnd, oSelf->lBackColor );
         }
         else
         {
            ListView_SetBkColor( oSelf->hWnd, GetSysColor( COLOR_WINDOW ) );
         }
         RedrawWindow( oSelf->hWnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
      }
   }

   // Return value was set in _OOHG_DetermineColorReturn()
}

HB_FUNC_STATIC( TGRID_COLUMNCOUNT )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   int iCount;

   if( ValidHandler( oSelf->hWnd ) )
   {
      iCount = Header_GetItemCount( ListView_GetHeader( oSelf->hWnd ) );
   }
   else
   {
      iCount = 0;
   }

   hb_retni( iCount );
}

HB_FUNC_STATIC( TGRID_HEADERHEIGHT )
{
   PHB_ITEM pSelf = hb_stackSelfItem();
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   RECT rc;
   int iHeight;

   if( ValidHandler( oSelf->hWnd ) )
   {
      if( Header_GetItemRect( ListView_GetHeader( oSelf->hWnd ), 0, &rc ) )
      {
         iHeight = rc.bottom - rc.top;
      }
      else
      {
         iHeight = 0;
      }
   }
   else
   {
      iHeight = 0;
   }

   hb_retni( iHeight );
}

HB_FUNC( LISTVIEW_GETCOLUMNORDER )
{
   HWND hWnd = HWNDparam( 1 );
   int iCount, n;
   int *nArray;

   if( ValidHandler( hWnd ) )
   {
      iCount = Header_GetItemCount( ListView_GetHeader( hWnd ) );
      nArray = (int *) hb_xgrab( ( iCount ) * sizeof( int ) );

      if( ListView_GetColumnOrderArray( hWnd, (WPARAM) iCount, (LPARAM) (LPINT) nArray ) )
      {
         hb_reta( iCount );
         for( n = 0; n < iCount; n++ )
         {
            HB_STORNI( nArray[ n ] + 1, -1, n + 1 );
         }

         hb_xfree( nArray );
      }
      else
      {
         hb_xfree( nArray );

         hb_reta( 0 );
      }
   }
   else
   {
      hb_reta( 0 );
   }
}

HB_FUNC_STATIC( LISTVIEW_SETCOLUMNORDER )
{
   HWND hWnd = HWNDparam( 1 );
   int iCount, n;
   int *iArray;
   PHB_ITEM nArray;
   BOOL bRet = FALSE;

   if( ValidHandler( hWnd ) && HB_ISARRAY( 2 ) )
   {
      iCount = Header_GetItemCount( ListView_GetHeader( hWnd ) );

      if( (int) hb_parinfa( 2, 0 ) == iCount )
      {
         iArray = (int *) hb_xgrab( ( iCount ) * sizeof( int ) );
         nArray = hb_param( 2, HB_IT_ARRAY );

         for( n = 1; n <= iCount; n++ )
         {
            iArray[ n - 1 ] = hb_arrayGetNI( nArray, n ) - 1;
         }

         bRet = ListView_SetColumnOrderArray( hWnd, (WPARAM) iCount, (LPARAM) (LPINT) iArray );

         hb_xfree( iArray );
      }
   }

   hb_retl( bRet );
}

static WNDPROC lpfnOldWndProc = 0;                      //  TODO: Thread safe ?

static LRESULT APIENTRY SubClassFunc( HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam )
{
   return _OOHG_WndProcCtrl( hWnd, msg, wParam, lParam, lpfnOldWndProc );
}

HB_FUNC( EXECOLDWNDPROC )
{
   hb_retnl( (LRESULT) CallWindowProc( lpfnOldWndProc, HWNDparam( 1 ), (UINT) hb_parni( 2 ), (WPARAM) hb_parnl( 3 ), (LPARAM) hb_parnl( 4 ) ) );
}

HB_FUNC( INITLISTVIEW )
{
   HWND hwnd;
   int style, StyleEx, extStyle;
   INITCOMMONCONTROLSEX i;
   int iCol, iRow, iWidth, iHeight, iNewRow;
   BOOL bVisible;

   i.dwSize = sizeof( INITCOMMONCONTROLSEX );
   i.dwICC = ICC_DATE_CLASSES;
   InitCommonControlsEx( &i );

   StyleEx = WS_EX_CLIENTEDGE | _OOHG_RTL_Status( hb_parl( 13 ) );

   style = WS_CHILD | LVS_REPORT | hb_parni( 12 );
   if ( hb_parl( 10 ) )
   {
      style = style | LVS_OWNERDATA;
   }

   // control must have WS_VISIBLE style or it may not be painted properly

   bVisible = ( style & WS_VISIBLE );

   iCol = hb_parni(3);
   iRow = hb_parni(4);
   iWidth = hb_parni(5);
   iHeight = hb_parni(6);

   iNewRow = iRow;

   if( ! bVisible )
   {
      style = style | WS_VISIBLE;
      iRow = - 1000 - iRow;
   }

   hwnd = CreateWindowEx( StyleEx, "SysListView32", "", style,
                          iCol, iRow, iWidth, iHeight,
                          HWNDparam( 1 ), (HMENU) HWNDparam( 2 ), GetModuleHandle( NULL ), NULL ) ;

   extStyle = hb_parni(9) | LVS_EX_FULLROWSELECT | LVS_EX_HEADERDRAGDROP | LVS_EX_SUBITEMIMAGES;
   if ( hb_parl( 14 ) )
   {
      extStyle = extStyle | LVS_EX_CHECKBOXES;
   }
   if ( hb_parl( 15 ) )
   {
      extStyle = extStyle | LVS_EX_DOUBLEBUFFER;
   }
   SendMessage( hwnd, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, extStyle );

   if( ! bVisible )
   {
      SetWindowLong( hwnd, GWL_STYLE, style & ( ~ WS_VISIBLE ) );
      MoveWindow( hwnd, iCol, iNewRow, iWidth, iHeight, TRUE );
   }

   if ( hb_parl( 10 ) )
   {
      ListView_SetItemCount( hwnd, hb_parni( 11 ) ) ;
   }

   lpfnOldWndProc = ( WNDPROC ) SetWindowLong( hwnd, GWL_WNDPROC, ( LONG ) SubClassFunc );

   HWNDret( hwnd );
}

HB_FUNC( INITLISTVIEWCOLUMNS )
{
   PHB_ITEM wArray;
   PHB_ITEM hArray;
   PHB_ITEM jArray;

   HWND hc;
   LV_COLUMN COL;
   int iLen;
   int s;
   int iColumn;

   hc = HWNDparam( 1 );

   iLen = hb_parinfa( 2, 0 ) - 1;
   hArray = hb_param( 2, HB_IT_ARRAY );
   wArray = hb_param( 3, HB_IT_ARRAY );
   jArray = hb_param( 4, HB_IT_ARRAY );

   COL.mask = LVCF_FMT | LVCF_WIDTH | LVCF_TEXT | LVCF_SUBITEM;

   iColumn = 0;
   for( s = 0; s <= iLen; s++ )
   {
      COL.fmt = hb_arrayGetNI( jArray, s + 1 );
      COL.cx = hb_arrayGetNI( wArray, s + 1 );
      COL.pszText = ( char * ) hb_arrayGetCPtr( hArray, s + 1 );
      COL.iSubItem = iColumn;
      ListView_InsertColumn( hc, iColumn, &COL );
      if( iColumn == 0 && COL.fmt != LVCFMT_LEFT )
      {
         iColumn++;
         COL.iSubItem = iColumn;
         ListView_InsertColumn( hc, iColumn, &COL );
      }
      iColumn++;
   }

   if( iColumn != s )
   {
      ListView_DeleteColumn( hc, 0 );
   }
}

static void _OOHG_ListView_FillItem( HWND hWnd, int nItem, PHB_ITEM pItems )
{
   LV_ITEM LI;
   ULONG s, ulLen;
   struct IMAGE_PARAMETER pStruct;

   ulLen = hb_arrayLen( pItems );

   for( s = 0; s < ulLen; s++ )
   {
      LI.mask = LVIF_TEXT | LVIF_IMAGE;
      LI.state = 0;
      LI.stateMask = 0;
      LI.iItem = nItem;
      LI.iSubItem = s;
      ImageFillParameter( &pStruct, hb_arrayGetItemPtr( pItems, s + 1 ) );
      LI.pszText = pStruct.cString;
      LI.iImage = pStruct.iImage1;
      ListView_SetItem( hWnd, &LI );
   }
}

HB_FUNC( SETGRIDCOLUMNJUSTIFY )
{
   LV_COLUMN COL;
   int iOld, iNew;

   COL.mask = LVCF_FMT;
   ListView_GetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );
   iOld = ( COL.fmt & LVCFMT_JUSTIFYMASK );

   iNew = ( hb_parni( 3 ) & LVCFMT_JUSTIFYMASK );

   if( ( iNew == iOld ) || ( iNew == LVCFMT_JUSTIFYMASK ) )
   {
      hb_retni( iOld );
   }
   else
   {
      COL.fmt &= ~ ( COL.fmt & LVCFMT_JUSTIFYMASK );
      COL.fmt |= iNew;

      if( ListView_SetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL ) )
      {
         hb_retni( iNew );
      }
      else
      {
         hb_retni( iOld );
      }
   }
}

HB_FUNC( SETGRIDCOLUMNHEADER )
{
   LV_COLUMN COL;

   COL.mask = LVCF_TEXT;
   COL.pszText = ( char * ) hb_parc( 3 ) ;
   COL.fmt = hb_parni( 4 ) ;

   ListView_SetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );
}

HB_FUNC( SETHEADERIMAGELIST )
{
   SendMessage( ListView_GetHeader( HWNDparam( 1 ) ), HDM_SETIMAGELIST, 0, (LPARAM) hb_parnl( 2 ) );
}

HB_FUNC( GETHEADER )
{
   HWNDret( ListView_GetHeader( HWNDparam( 1 ) ) );
}

HB_FUNC( SETGRIDCOLUMNIMAGE )
{
   LV_COLUMN COL;

   COL.mask = LVCF_FMT;

   ListView_GetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );

   COL.mask |= LVCF_IMAGE;

   COL.fmt |= LVCFMT_IMAGE;

   if ( hb_parl( 4 ) )
   {
      COL.fmt |= LVCFMT_BITMAP_ON_RIGHT;
   }
   else
   {
      COL.fmt &= ~LVCFMT_BITMAP_ON_RIGHT;
   }

   COL.iImage = hb_parni( 3 ) - 1;

   ListView_SetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );
}

HB_FUNC( REMOVEGRIDCOLUMNIMAGE )
{
   LV_COLUMN COL;

   COL.mask = LVCF_FMT | LVCF_IMAGE;

   ListView_GetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );

   COL.mask &= ~LVCF_IMAGE;
   COL.fmt &= ~LVCFMT_IMAGE;
   COL.iImage = -1;

   ListView_SetColumn( HWNDparam( 1 ), hb_parni( 2 ) - 1, &COL );
}

HB_FUNC( ADDLISTVIEWITEMS )
{
   PHB_ITEM hArray;
   LV_ITEM LI;
   HWND h;
   int c;
   int nItem;

   hArray = hb_param( 2, HB_IT_ARRAY );
   if( ! hArray || hb_arrayLen( hArray ) == 0 )
   {
      return;
   }
   h = HWNDparam( 1 );
   c = ListView_GetItemCount( h );

   // First "default" item
   LI.mask = LVIF_TEXT | LVIF_IMAGE;
   LI.state = 0;
   LI.stateMask = 0;
   LI.iItem = c;
   LI.iSubItem = 0;
   LI.pszText = "";
   LI.iImage = -1;
   nItem = ListView_InsertItem( h, &LI );

   if( nItem > -1 )
   {
      _OOHG_ListView_FillItem( h, nItem, hArray );
   }

   hb_retni( nItem + 1 );
}

HB_FUNC( INSERTLISTVIEWITEM )
{
   PHB_ITEM hArray;
   LV_ITEM LI;
   HWND h;
   int c;
   int nItem;

   hArray = hb_param( 2, HB_IT_ARRAY );
   if( ! hArray || hb_arrayLen( hArray ) == 0 )
   {
      return;
   }
   h = HWNDparam( 1 );
   c = hb_parni( 3 ) - 1;

   // First "default" item
   LI.mask = LVIF_TEXT | LVIF_IMAGE;
   LI.state = 0;
   LI.stateMask = 0;
   LI.iItem = c;
   LI.iSubItem = 0;
   LI.pszText = "";
   LI.iImage = -1;
   nItem = ListView_InsertItem( h, &LI );

   if( nItem > -1)
   {
      _OOHG_ListView_FillItem( h, nItem, hArray );
   }

   hb_retni( nItem + 1 );
}

HB_FUNC( LISTVIEWSETITEM )
{
   _OOHG_ListView_FillItem( HWNDparam( 1 ), hb_parni( 3 ) - 1, hb_param( 2, HB_IT_ARRAY ) );
}

HB_FUNC( LISTVIEWGETITEM )
{
   char buffer[ 1024 ];
   HWND h;
   int s, c, l;
   LV_ITEM LI;
   PHB_ITEM pArray, pString;

   h = HWNDparam( 1 );

   c = hb_parni( 2 ) - 1;

   l = hb_parni( 3 );

   pArray = hb_itemArrayNew( l );
   pString = hb_itemNew( NULL );

   for( s = 0; s < l; s++ )
   {
      memset( &LI, 0, sizeof( LI ) );
      LI.iImage = -1;
      LI.mask = LVIF_TEXT | LVIF_IMAGE;
      LI.state = 0;
      LI.stateMask = 0;
      LI.iSubItem = s;
      LI.cchTextMax = 1022;
      LI.pszText = buffer;
      LI.iItem = c;
      buffer[ 0 ] = 0;
      buffer[ 1023 ] = 0;
      ListView_GetItem( h, &LI );
      buffer[ 1023 ] = 0;

      if( LI.iImage == -1 )
      {
         hb_itemPutC( pString, buffer );
      }
      else
      {
         hb_itemPutNI( pString, LI.iImage );
      }
      hb_itemArrayPut( pArray, s + 1, pString );
   }

   hb_itemReturn( pArray );
   hb_itemRelease( pArray );
   hb_itemRelease( pString );
}

HB_FUNC( FILLGRIDFROMARRAY )
{
   HWND hWnd = HWNDparam( 1 );
   ULONG iCount = ListView_GetItemCount( hWnd );
   PHB_ITEM pScreen = hb_param( 2, HB_IT_ARRAY );
   ULONG iLen = hb_arrayLen( pScreen );
   LV_ITEM LI;

   while( iCount > iLen )
   {
      iCount--;
      SendMessage( hWnd, LVM_DELETEITEM, ( WPARAM ) iCount, 0 );
   }
   while( iCount < iLen )
   {
      LI.mask = LVIF_TEXT | LVIF_IMAGE;
      LI.state = 0;
      LI.stateMask = 0;
      LI.iItem = iCount;
      LI.iSubItem = 0;
      LI.pszText = "";
      LI.iImage = -1;
      ListView_InsertItem( hWnd, &LI );
      iCount++;
   }

   for( iCount = 1; iCount <= iLen; iCount++ )
   {
      _OOHG_ListView_FillItem( hWnd, iCount, hb_arrayGetItemPtr( pScreen, iCount ) );
   }
}

HB_FUNC( CELLRAWVALUE )   // hWnd, nRow, nCol, nType, uValue
{
   HWND hWnd;
   LV_ITEM LI;
   char buffer[ 1024 ];
   int iType;

   hWnd = HWNDparam( 1 );
   iType = hb_parni( 4 );

   LI.mask = LVIF_TEXT | LVIF_IMAGE;
   LI.state = 0;
   LI.stateMask = 0;
   LI.iItem = hb_parni( 2 ) - 1;
   LI.iSubItem = hb_parni( 3 ) - 1;
   LI.cchTextMax = 1022;
   LI.pszText = buffer;
   buffer[ 0 ] = 0;
   buffer[ 1023 ] = 0;

   ListView_GetItem( hWnd, &LI );

   if( iType == 1 && HB_ISCHAR( 5 ) )
   {
      LI.cchTextMax = 1022;
      LI.pszText = ( char * ) hb_parc( 5 );
      ListView_SetItem( hWnd, &LI );
   }
   else if( iType == 2 && HB_ISNUM( 5 ) )
   {
      LI.iImage = hb_parni( 5 );
      ListView_SetItem( hWnd, &LI );
   }

   LI.cchTextMax = 1022;
   LI.pszText = buffer;
   buffer[ 0 ] = 0;
   buffer[ 1023 ] = 0;
   ListView_GetItem( hWnd, &LI );

   if( iType == 1 )
   {
      hb_retc( LI.pszText );
   }
   else // if( iType == 2 )
   {
      hb_retni( LI.iImage );
   }
}

typedef struct __OOHG_SortItemsInfo_ {
   HWND hWnd;
   int  iColumn;
   BOOL bDescending;
} _OOHG_SortItemsInfo;

PFNLVCOMPARE CALLBACK _OOHG_SortItems( LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort )
{
   _OOHG_SortItemsInfo *si;
   int iRet;
   LVITEM lvItem1, lvItem2;
   char cString1[ 1024 ], cString2[ 1024 ];

   si = ( _OOHG_SortItemsInfo * ) lParamSort;

   lvItem1.mask       = LVIF_TEXT;
   lvItem1.iItem      = lParam1;
   lvItem1.iSubItem   = si->iColumn;
   lvItem1.cchTextMax = 1022;
   lvItem1.pszText    = cString1;
   cString1[ 0 ] = cString1[ 1023 ] = 0;
   ListView_GetItem( si->hWnd, &lvItem1 );
   cString1[ 1023 ] = 0;

   lvItem2.mask       = LVIF_TEXT;
   lvItem2.iItem      = lParam2;
   lvItem2.iSubItem   = si->iColumn;
   lvItem2.cchTextMax = 1022;
   lvItem2.pszText    = cString2;
   cString2[ 0 ] = cString2[ 1023 ] = 0;
   ListView_GetItem( si->hWnd, &lvItem2 );
   cString2[ 1023 ] = 0;

   iRet = strcmp( cString1, cString2 );
   if( si->bDescending )
   {
      iRet = - iRet;
   }

   return ( PFNLVCOMPARE ) iRet;
}

HB_FUNC( LISTVIEW_SORTITEMSEX )   // hWnd, nColumn, lDescending
{
   _OOHG_SortItemsInfo si;

   si.hWnd = HWNDparam( 1 );
   si.iColumn = hb_parni( 2 ) - 1;
   si.bDescending = hb_parl( 3 );
   hb_retni( SendMessage( si.hWnd, LVM_SORTITEMSEX,
                          ( WPARAM ) ( _OOHG_SortItemsInfo * ) &si,
                          ( LPARAM ) ( PFNLVCOMPARE ) _OOHG_SortItems ) );
}

PFNLVCOMPARE CALLBACK _OOHG_SortItemsUser( LPARAM lParam1, LPARAM lParam2, LPARAM lParamSort )
{
   _OOHG_Send( (PHB_ITEM) lParamSort, s_CompareItems );
   hb_vmPushLong( (LONG) lParam1 + 1 );
   hb_vmPushLong( (LONG) lParam2 + 1 );
   hb_vmSend( 2 );
   return (PFNLVCOMPARE) hb_parni( -1 );
}

HB_FUNC( LISTVIEW_SORTITEMSEX_USER )
{
   PHB_ITEM pSelf = hb_param( 1, HB_IT_OBJECT );
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );

   hb_retni( SendMessage( oSelf->hWnd, LVM_SORTITEMSEX, (WPARAM) pSelf, (LPARAM) (PFNLVCOMPARE) _OOHG_SortItemsUser ) );
}

HB_FUNC( NMHEADER_IITEM )
{
   hb_retnl( ( LONG ) ( ( ( NMHEADER * ) hb_parnl( 1 ) )->iItem ) + 1 );
}

HB_FUNC( HDITEM_CXY )
{
   hb_retni( ( int ) ( ( ( ( NMHEADER * ) hb_parnl( 1 ) )->pitem )->cxy ) );
}

HB_FUNC( SET_HDITEM_CXY )
{
   ( ( ( NMHEADER * ) hb_parnl( 1 ) )->pitem )->cxy = hb_parni( 2 );
}

HB_FUNC( HDITEM_IORDER )
{
   hb_retni( ( int ) ( ( ( ( NMHEADER * ) hb_parnl( 1 ) )->pitem )->iOrder + 1 ) );
}

HB_FUNC( LISTVIEW_SETITEMCOUNT )
{
   ListView_SetItemCount ( HWNDparam( 1 ), hb_parni( 2 ) ) ;
}

HB_FUNC( LISTVIEW_GETFIRSTITEM )
{
   hb_retni( ListView_GetNextItem( HWNDparam( 1 ), -1, LVNI_ALL | LVNI_SELECTED ) + 1 );
}

HB_FUNC( LISTVIEW_SETCURSEL )
{
   ListView_SetItemState( HWNDparam( 1 ), ( WPARAM ) ( hb_parni( 2 ) - 1 ), LVIS_FOCUSED | LVIS_SELECTED, LVIS_FOCUSED | LVIS_SELECTED );
}

HB_FUNC( LISTVIEW_CLEARCURSEL )
{
   ListView_SetItemState( HWNDparam( 1 ), ( WPARAM ) ( hb_parni( 2 ) - 1 ), 0, LVIS_FOCUSED | LVIS_SELECTED );
}

HB_FUNC( LISTVIEWDELETESTRING )
{
   hb_retl( ListView_DeleteItem( HWNDparam( 1 ), (WPARAM) ( hb_parni( 2 ) - 1 ) ) );
}

HB_FUNC( LISTVIEWRESET )
{
   hb_retl( ListView_DeleteAllItems( HWNDparam( 1 ) ) );
}

HB_FUNC( LISTVIEWGETMULTISEL )
{
   HWND hwnd = HWNDparam( 1 );
   int i;
   int n;
   int j;

   n = SendMessage( hwnd, LVM_GETSELECTEDCOUNT, 0, 0 );

   hb_reta( n );

   i = -1;
   j = 0;

   while( 1 )
   {
      i = ListView_GetNextItem( hwnd, i, LVNI_ALL | LVNI_SELECTED );

      if( i == -1 )
      {
         break;
      }
      else
      {
         j++;
      }

      HB_STORNI( i + 1, -1, j );
   }
}

HB_FUNC( LISTVIEWSETMULTISEL )
{
   PHB_ITEM wArray;
   HWND hwnd = HWNDparam( 1 );
   int i, l, n;

   wArray = hb_param( 2, HB_IT_ARRAY );

   l = hb_parinfa( 2, 0 ) - 1;

   n = SendMessage( hwnd, LVM_GETITEMCOUNT, 0, 0 );

   // CLEAR CURRENT SELECTIONS
   for( i = 0; i < n; i++ )
   {
      ListView_SetItemState( hwnd, ( WPARAM ) i, 0, LVIS_FOCUSED | LVIS_SELECTED );
   }

   // SET NEW SELECTIONS
   for( i = 0; i <= l; i++ )
   {
      ListView_SetItemState( hwnd, hb_arrayGetNI( wArray, i + 1 ) - 1, LVIS_FOCUSED | LVIS_SELECTED, LVIS_FOCUSED | LVIS_SELECTED );
   }
}

HB_FUNC( LISTVIEWGETITEMROW )
{
   POINT point;

   ListView_GetItemPosition( HWNDparam( 1 ), hb_parni( 2 ), &point );

   hb_retnl( point.y );
}

HB_FUNC( LISTVIEWGETITEMCOUNT )
{
   hb_retnl( ListView_GetItemCount( HWNDparam( 1 ) ) );
}


HB_FUNC( LISTVIEWGETCOUNTPERPAGE )
{
   hb_retnl( ListView_GetCountPerPage( HWNDparam( 1 ) ) );
}

HB_FUNC( LISTVIEW_ENSUREVISIBLE )
{
   hb_retl( ListView_EnsureVisible( HWNDparam( 1 ), hb_parni( 2 ) - 1, FALSE ) );
}

HB_FUNC( LISTVIEW_ISITEMVISIBLE )
{
   HWND hwnd = HWNDparam( 1 );
   int iItem = hb_parni( 2 ) - 1;
   int iTop = ListView_GetTopIndex( hwnd );

   hb_retl( ( iItem >= iTop ) && ( iItem <= iTop + ListView_GetCountPerPage( hwnd ) - 1 ) );
}

HB_FUNC( LISTVIEW_GETTOPINDEX )
{
   hb_retnl( ListView_GetTopIndex( HWNDparam( 1 ) ) + 1 );
}

HB_FUNC( LISTVIEW_REDRAWITEMS )
{
   hb_retnl( ListView_RedrawItems( HWNDparam( 1 ), hb_parni( 2 ) - 1, hb_parni( 3 ) - 1 ) );
}

HB_FUNC( LISTVIEW_ITEMACTIVATE )
{
   LPNMITEMACTIVATE pData = ( NMITEMACTIVATE * ) hb_parnl( 1 );

   hb_reta( 2 );
   HB_STORNI( pData->iItem + 1, -1, 1 );
   HB_STORNI( pData->iSubItem + 1, -1, 2 );
}

HB_FUNC( LISTVIEW_LISTVIEW )
{
   LPNMLISTVIEW pData = ( NMLISTVIEW * ) hb_parnl( 1 );

   hb_reta( 2 );
   HB_STORNI( pData->iItem + 1, -1, 1 );
   HB_STORNI( pData->iSubItem + 1, -1, 2 );
}

HB_FUNC( LISTVIEW_HITTEST )
{
   POINT point;
   LVHITTESTINFO lvhti;

   point.y = hb_parni( 2 );
   point.x = hb_parni( 3 );

   lvhti.pt = point;

   ListView_SubItemHitTest( HWNDparam( 1 ), &lvhti );

   if( lvhti.flags & LVHT_ONITEM )
   {
      hb_reta( 2 );
      HB_STORNI( lvhti.iItem + 1, -1, 1 );
      HB_STORNI( lvhti.iSubItem + 1, -1, 2 );
   }
   else
   {
      hb_reta( 2 );
      HB_STORNI( 0, -1, 1 );
      HB_STORNI( 0, -1, 2 );
   }
}

HB_FUNC( GET_XY_LPARAM )
{
   POINT point;

   point.x = GET_X_LPARAM( hb_parnl( 1 ) );
   point.y = GET_Y_LPARAM( hb_parnl( 1 ) );

   hb_reta( 2 );
   HB_STORNI( point.y, -1, 1 );
   HB_STORNI( point.x, -1, 2 );
}

HB_FUNC( HEADER_HITTEST )
{
   int i, index;
   RECT rc;
   POINT point;
   HWND hWnd = HWNDparam( 1 );

   DWORD dwpos = GetMessagePos();

   point.x = GET_X_LPARAM( dwpos );
   point.y = GET_Y_LPARAM( dwpos );

   ScreenToClient( hWnd, &point );

   index = -1;
   for( i = 0; Header_GetItemRect( hWnd, i, &rc ); i ++ )
   {
      if( PtInRect( &rc, point ) )
      {
         index = i;
         break;
      }
   }

   hb_retni( index + 1 );
}

HB_FUNC( LISTVIEW_HITONCHECKBOX )
{
   /*
    * The default behaviour of listview is a little odd because it does not limit the toggle
    * of a checkbox to the clicks done inside it (or in it's borders). Sometimes it's toggle
    * when the click is done in the outside of the checkbox, and other times a click inside
    * it is ignored. This happens because the checkbox is drawn in an area different than
    * the defined state area (thus renders the LVHT_ONITEMSTATEICON flag useless).
    * The width of the state area is defined by the state imagelist width (XP=16 Win7=13)
    * and the height equals the height of the row. The checkbox dimensions are 13x13.
    * Under Win7 the clickable zone of the checkbox does not include it's rightmost 2 pixels.
    * Under WinXP the gap between the item's state image area and the item's icon area is
    * 2 pixels wide. Under Win7 is only 1 pixel wide.
    * Win7 places the checkbox centered in the y axe, but instead of using it's real height
    * it uses 16. XP uses a fixed 4 pixel margin.
    * The listview, as far as I know, exports no way of knowing the checkbox's rect nor
    * the size of the aforementioned gap.
    */
   POINT point ;
   LVHITTESTINFO lvhti;
   int item, cx, cy, chkWidth, gapWidth, margin;
   RECT rcIcon;
   LPRECT lprcIcon = &rcIcon;
   OSVERSIONINFO osvi;

   point.y = hb_parni( 2 );
   point.x = hb_parni( 3 );

   lvhti.pt = point;

   ListView_SubItemHitTest( HWNDparam( 1 ), &lvhti );

   if( lvhti.iSubItem == 0)
   {
      ListView_GetSubItemRect( HWNDparam( 1 ), lvhti.iItem, lvhti.iSubItem, LVIR_ICON, lprcIcon );

      ImageList_GetIconSize( ListView_GetImageList( HWNDparam( 1 ), LVSIL_STATE ), &cx, &cy );

      osvi.dwOSVersionInfoSize = sizeof( OSVERSIONINFO );
      GetVersionEx( (OSVERSIONINFO *) &osvi );

      if( osvi.dwMajorVersion >= 6 )                   // Win Vista or later
      {
         chkWidth = cx;
         gapWidth = 1;

         if( ( rcIcon.left - gapWidth > point.x ) && ( point.x >= rcIcon.left - chkWidth - gapWidth ) )
         {
            margin = ( rcIcon.bottom - rcIcon.top - chkWidth - 3 ) / 2;

            if( ( rcIcon.bottom - margin > point.y ) && ( point.y >= rcIcon.bottom - margin - chkWidth ) )
            {
               item = lvhti.iItem + 1;
            }
            else
            {
              item = -1;
            }
         }
         else
         {
            item = -1;
         }
      }
      else                                             // XP or older
      {
         chkWidth = cx - 3;
         gapWidth = 2;

         if( ( rcIcon.left - gapWidth > point.x ) && ( point.x >= rcIcon.left - chkWidth - gapWidth ) )
         {
            margin = 4;

            if( ( rcIcon.top + margin + chkWidth > point.y ) && ( point.y >= rcIcon.top + margin ) )
            {
               item = lvhti.iItem + 1;
            }
            else
            {
               item = -1;
            }
         }
         else
         {
            item = -1;
         }
      }
   }
   else
   {
      item = 0;
   }

   hb_retni( item );
}

HB_FUNC( LISTVIEW_GETSUBITEMRECT )
{
   RECT Rect ;
   LPRECT lpRect = (LPRECT) &Rect ;
   HWND hWnd = HWNDparam( 1 );

   /*
    * For first column, LVIR_BOUNDS always returns left == 0 and right == sum of all columns' widths
    * As a workaround use LVIR_LABEL to get the subitem's right and compute it's left
    * by substracting the column's width.
    */
   ListView_GetSubItemRect( hWnd, hb_parni( 2 ), hb_parni( 3 ), LVIR_LABEL, lpRect );
   Rect.left = Rect.right - ListView_GetColumnWidth( hWnd, hb_parni( 3 ) );

   hb_reta( 4 );
   HB_STORNI( Rect.top,  -1, 1 );
   HB_STORNI( Rect.left, -1, 2 );
   HB_STORNI( Rect.right  - Rect.left, -1, 3 );
   HB_STORNI( Rect.bottom - Rect.top,  -1, 4 );
}

HB_FUNC( LISTVIEW_GETITEMRECT )
{
   RECT Rect ;
   LPRECT lpRect = (LPRECT) &Rect ;

   if( ListView_GetItemRect( HWNDparam( 1 ), hb_parni( 2 ), lpRect, LVIR_LABEL ) )
   {
      hb_reta( 4 );
      HB_STORNI( Rect.top, -1, 1 );
      HB_STORNI( Rect.left, -1, 2 );
      HB_STORNI( Rect.right - Rect.left, -1, 3 );
      HB_STORNI( Rect.bottom - Rect.top, -1, 4 );
   }
   else
   {
      hb_reta( 4 );
      HB_STORNI( -1, -1, 1 );
      HB_STORNI( -1, -1, 2 );
      HB_STORNI( -1, -1, 3 );
      HB_STORNI( -1, -1, 4 );
   }
}

HB_FUNC( LISTVIEW_UPDATE )
{
   ListView_Update( HWNDparam( 1 ), hb_parni( 2 ) - 1 );
}

HB_FUNC( LISTVIEW_SCROLL )
{
   ListView_Scroll( HWNDparam( 1 ), hb_parni( 2 ), hb_parni( 3 ) );
}

HB_FUNC( LISTVIEW_SETBKCOLOR )
{
   ListView_SetBkColor( HWNDparam( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_SETTEXTBKCOLOR )
{
   ListView_SetTextBkColor( HWNDparam( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_SETTEXTCOLOR )
{
   ListView_SetTextColor( HWNDparam( 1 ), ( COLORREF ) RGB( hb_parni( 2 ), hb_parni( 3 ), hb_parni( 4 ) ) );
}

HB_FUNC( LISTVIEW_GETTEXTCOLOR )
{
   hb_retnl( ListView_GetTextColor( HWNDparam( 1 ) ) );
}

HB_FUNC( LISTVIEW_GETBKCOLOR )
{
   hb_retnl( ListView_GetBkColor( HWNDparam( 1 ) ) );
}

HB_FUNC( LISTVIEW_GETCOLUMNWIDTH )
{
   hb_retni( ListView_GetColumnWidth( HWNDparam( 1 ), hb_parni( 2 ) ) );
}

HB_FUNC( LISTVIEW_SETCOLUMNWIDTH )
{
   HWND hWnd = HWNDparam( 1 );
   int iColumn = hb_parni( 2 );

   ListView_SetColumnWidth( hWnd, iColumn, hb_parni( 3 ) );
   hb_retni( ListView_GetColumnWidth( hWnd, iColumn ) );
}

HB_FUNC( _OOHG_GRIDARRAYWIDTHS )
{
   HWND hWnd = HWNDparam( 1 );
   PHB_ITEM pArray = hb_param( 2, HB_IT_ARRAY );
   ULONG iSum = 0, iCount, iSize;

   if( pArray )
   {
      for( iCount = 0; iCount < hb_arrayLen( pArray ); iCount++ )
      {
         iSize = ListView_GetColumnWidth( hWnd, iCount );
         iSum += iSize;
         HB_STORNI( iSize, 2, iCount + 1 );
      }
   }

   hb_retni( iSum );
}

HB_FUNC( LISTVIEW_ADDCOLUMN )
{
   LV_COLUMN COL;
   int iColumn = hb_parni( 2 ) - 1;
   HWND hwnd = HWNDparam( 1 );
   int iWidth;

   if( iColumn < 0 )
   {
      return;
   }

   COL.mask = LVCF_WIDTH | LVCF_TEXT | LVCF_FMT | LVCF_SUBITEM; // | LVCF_IMAGE;
   COL.cx = hb_parni( 3 );
   COL.pszText = ( char * ) hb_parc( 4 );
   COL.iSubItem = iColumn;
   COL.fmt = hb_parni( 5 ); // | LVCFMT_IMAGE;

   ListView_InsertColumn( hwnd, iColumn, &COL );
   if( iColumn == 0 && COL.fmt != LVCFMT_LEFT )
   {
      COL.iSubItem = 1;
      ListView_InsertColumn( hwnd, 1, &COL );
      ListView_DeleteColumn( hwnd, 0 );
   }

   if( hb_parl( 6 ) )
   {
      iWidth = ListView_GetColumnWidth( hwnd, iColumn ) + 1;
      ListView_SetColumnWidth( hwnd, iColumn, iWidth );
      ListView_SetColumnWidth( hwnd, iColumn, iWidth - 1 );
   }
   else
   {
      SendMessage( hwnd, LVM_DELETEALLITEMS, 0, 0 );
      RedrawWindow( hwnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
   }
}

HB_FUNC( LISTVIEW_SETCOLUMN )
{
   LV_COLUMN COL;
   int iColumn = hb_parni( 2 ) - 1;
   HWND hwnd = HWNDparam( 1 );

   if( iColumn < 0 || iColumn > Header_GetItemCount( ListView_GetHeader( hwnd ) ) )
   {
      return;
   }

   COL.mask = LVCF_WIDTH | LVCF_TEXT | LVCF_FMT | LVCF_SUBITEM; // | LVCF_IMAGE;
   COL.cx = hb_parni( 3 );
   COL.pszText = ( char * ) hb_parc( 4 );
   COL.iSubItem = iColumn;
   COL.fmt = hb_parni( 5 ); // | LVCFMT_IMAGE;

   ListView_SetColumn( hwnd, iColumn, &COL );

   if( ! hb_parl( 6 ) )
   {
      SendMessage( hwnd, LVM_DELETEALLITEMS, 0, 0 );
      RedrawWindow( hwnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
   }
}

HB_FUNC( LISTVIEW_DELETECOLUMN )
{
   HWND hwnd = HWNDparam( 1 );
   int iColumn = hb_parni( 2 ) - 1;

   if( iColumn < 0 )
   {
      return;
   }

   ListView_DeleteColumn( hwnd, iColumn );

   if( ! hb_parl( 3 ) )
   {
      SendMessage( hwnd, LVM_DELETEALLITEMS, 0, 0 );
      RedrawWindow( hwnd, NULL, NULL, RDW_ERASE | RDW_INVALIDATE | RDW_ALLCHILDREN | RDW_ERASENOW | RDW_UPDATENOW );
   }
}

HB_FUNC( GETGRIDVKEY )
{
   hb_retnl( ( LPARAM ) ( ( ( LV_KEYDOWN * ) hb_parnl( 1 ) ) -> wVKey ) );
}

HB_FUNC( GETGRIDVKEYASCHAR )
{
   hb_retni( MapVirtualKey( (UINT) ( ( (LV_KEYDOWN *) hb_parnl( 1 ) ) -> wVKey ), 2 ) );
}

static int TGrid_Notify_CustomDraw_GetColor( PHB_ITEM pSelf, unsigned int x, unsigned int y, int sGridColor, int sObjColor, int iDefaultColor )
{
   PHB_ITEM pColor;
   LONG iColor;

   _OOHG_Send( pSelf, sGridColor );
   hb_vmSend( 0 );

   pColor = hb_param( -1, HB_IT_ARRAY );
   if( pColor &&                                                 // ValType( aColor ) == "A"
       hb_arrayLen( pColor ) >= y &&                             // Len( aColor ) >= y
       HB_IS_ARRAY( hb_arrayGetItemPtr( pColor, y ) ) &&         // ValType( aColor[ y ] ) == "A"
       hb_arrayLen( hb_arrayGetItemPtr( pColor, y ) ) >= x )     // Len( aColor[ y ] ) >= x
   {
      pColor = hb_arrayGetItemPtr( hb_arrayGetItemPtr( pColor, y ), x );
   }
   else
   {
      pColor = NULL;
   }

   iColor = -1;

   if( ! _OOHG_DetermineColor( pColor, &iColor ) || iColor == -1 )
   {
      _OOHG_Send( pSelf, sObjColor );
      hb_vmSend( 0 );
      if( ! _OOHG_DetermineColor( hb_param( -1, HB_IT_ANY ), &iColor ) || iColor == -1 )
      {
         iColor = GetSysColor( iDefaultColor );
      }
   }

   return iColor;
}

static int TGrid_Notify_CustomDraw_GetSelColor( PHB_ITEM pSelf, unsigned int x )
{
   PHB_ITEM pColor;
   LONG iColor = -1;
   char cBuffError[ 1000 ];

   _OOHG_Send( pSelf, s_GridSelectedColors );
   hb_vmSend( 0 );

   pColor = hb_param( -1, HB_IT_ARRAY );
   if( pColor &&                                                 // ValType( aColor ) == "A"
       hb_arrayLen( pColor ) >= x )                              // Len( aColor[ y ] ) >= x
   {
      pColor = hb_arrayGetItemPtr( pColor, x );

      if( _OOHG_DetermineColor( pColor, &iColor ) || iColor == -1 )
      {
         return iColor;
      }
   }

   sprintf( cBuffError, "GridSelectedColors is not a valid array !!!" );
   MessageBox( 0, cBuffError, "Error", MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL );
   ExitProcess( 1 );
   return 0;
}

int TGrid_Notify_CustomDraw( PHB_ITEM pSelf, LPARAM lParam, BOOL bByCell, int iRow, int iCol, BOOL bCheckBoxes, BOOL bFocusRect, BOOL bNoGrid, BOOL bPLM )
{
   LPNMLVCUSTOMDRAW lplvcd;
   int x, y;
   POCTRL oSelf = _OOHG_GetControlInfo( pSelf );
   RECT rcIcon, rcBack;
   LPRECT lprcIcon = &rcIcon;
   LPRECT lprcBack = &rcBack;
   HBRUSH hBrush;
   LV_ITEM LI;
   char buffer[ 1024 ];

   lplvcd = ( LPNMLVCUSTOMDRAW ) lParam;

   if( lplvcd->nmcd.dwDrawStage == CDDS_PREPAINT )
   {
      return CDRF_NOTIFYITEMDRAW;
   }
   else if( lplvcd->nmcd.dwDrawStage == CDDS_ITEMPREPAINT )
   {
      return CDRF_NOTIFYSUBITEMDRAW;
   }
   else if( lplvcd->nmcd.dwDrawStage == ( CDDS_SUBITEM | CDDS_ITEMPREPAINT ) )
   {
      // Get subitem's image, text and state
      memset( &LI, 0, sizeof( LI ) );
      LI.mask = LVIF_TEXT | LVIF_IMAGE | LVIF_STATE;
      LI.state = 0;
      LI.stateMask = LVIS_SELECTED | LVIS_FOCUSED;
      LI.iImage = -1;
      LI.iItem = lplvcd->nmcd.dwItemSpec;
      LI.iSubItem = lplvcd->iSubItem;
      LI.cchTextMax = 1022;
      LI.pszText = buffer;
      buffer[ 0 ] = 0;
      buffer[ 1023 ] = 0;
      ListView_GetItem( lplvcd->nmcd.hdr.hwndFrom, &LI );
      buffer[ 1023 ] = 0;

      // Get subitem's row (y) and col (x)
      x = lplvcd->iSubItem + 1;
      y = lplvcd->nmcd.dwItemSpec + 1;

      /*
       * Can't use (lplvcd->nmcd.uItemState | CDIS_SELECTED) to tell if the
       * subitem is selected when ListView control has LVS_SHOWSELALWAYS style.
       * See http://msdn.microsoft.com/en-us/library/bb775483(v=vs.85).aspx
       */

      // Get text's color and background color
      if( LI.state & LVIS_SELECTED )
      {
         if( bByCell )
         {
            if( ( y == iRow ) && ( x == iCol ) )
            {
               if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 1 );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 2 );
               }
               else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 3 );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 4 );
               }
               else
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridForeColor, s_FontColor, COLOR_WINDOWTEXT );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
            }
            else
            {
               if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 5 );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 6 );
               }
               else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 7 );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 8 );
               }
               else
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridForeColor, s_FontColor, COLOR_WINDOWTEXT );
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
               if( lplvcd->clrText == (COLORREF) -1 )
               {
                  lplvcd->clrText   = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridForeColor, s_FontColor, COLOR_WINDOWTEXT );
               }
               if( lplvcd->clrTextBk == (COLORREF) -1 )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
            }
         }
         else
         {
            if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
            {
               lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 1 );
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 2 );
            }
            else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
            {
               lplvcd->clrText   = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 3 );
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 4 );
            }
            else
            {
               lplvcd->clrText   = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridForeColor, s_FontColor, COLOR_WINDOWTEXT );
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
            }
         }
      }
      else
      {
         lplvcd->clrText   = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridForeColor, s_FontColor, COLOR_WINDOWTEXT );
         lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
      }

      if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
      {
         if ( LI.state & LVIS_FOCUSED )
         {
            if( ! bFocusRect )
            {
               lplvcd->nmcd.uItemState -= CDIS_FOCUS;
            }
         }
         if( LI.state & LVIS_SELECTED )
         {
            lplvcd->nmcd.uItemState -= CDIS_SELECTED;
         }
      }
      else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
      {
         if( LI.state & LVIS_SELECTED )
         {
            lplvcd->nmcd.uItemState -= CDIS_SELECTED;
         }
      }

      if( LI.iImage != -1 )                                 // Subitem has image?
      {
         return CDRF_NOTIFYPOSTPAINT;
      }
      else if( ( x == 1 ) && ( ! bCheckBoxes ) && bPLM )    // Is first subitem and has no image nor checkbox?
      {
         return CDRF_NOTIFYPOSTPAINT;
      }

      return CDRF_DODEFAULT;
   }
   else if( lplvcd->nmcd.dwDrawStage == ( CDDS_SUBITEM | CDDS_ITEMPOSTPAINT ) )
   {
      // Get subitem's image and state
      memset( &LI, 0, sizeof( LI ) );
      LI.mask = LVIF_IMAGE | LVIF_STATE;
      LI.iImage = -1;
      LI.state = 0;
      LI.stateMask = LVIS_SELECTED;
      LI.iItem = lplvcd->nmcd.dwItemSpec;
      LI.iSubItem = lplvcd->iSubItem;
      ListView_GetItem( lplvcd->nmcd.hdr.hwndFrom, &LI );

      // Get subitem's row (y) and col (x)
      x = lplvcd->iSubItem + 1;
      y = lplvcd->nmcd.dwItemSpec + 1;

      // Get text's background color
      if( LI.state & LVIS_SELECTED )
      {
         if( bByCell )
         {
            if( ( y == iRow ) && ( x == iCol ) )
            {
               if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 2 );
               }
               else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 4 );
               }
               else
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
            }
            else
            {
               if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 6 );
               }
               else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 8 );
               }
               else
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
               if( lplvcd->clrTextBk == (COLORREF) -1 )
               {
                  lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
               }
            }
         }
         else
         {
            if( GetFocus() == lplvcd->nmcd.hdr.hwndFrom )
            {
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 2 );
            }
            else if( GetWindowLong( lplvcd->nmcd.hdr.hwndFrom, GWL_STYLE ) & LVS_SHOWSELALWAYS )
            {
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetSelColor( pSelf, 4 );
            }
            else
            {
               lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
            }
         }
      }
      else
      {
         lplvcd->clrTextBk = TGrid_Notify_CustomDraw_GetColor( pSelf, x, y, s_GridBackColor, s_BackColor, COLOR_WINDOW );
      }

      // Subitem has image?
      if( LI.iImage != -1 )
      {
         // Get icon's rect
         ListView_GetSubItemRect( lplvcd->nmcd.hdr.hwndFrom, lplvcd->nmcd.dwItemSpec, lplvcd->iSubItem, LVIR_ICON, lprcIcon );

         // Calculate area for background and paint it
         if( x == 1)
         {
            rcBack.top = rcIcon.top;
            rcBack.left = ( ( ! bCheckBoxes ) && bPLM ) ? 0 : rcIcon.left;
            rcBack.bottom = bNoGrid ? rcIcon.bottom : ( rcIcon.bottom - 1 );
            rcBack.right = rcIcon.right;
         }
         else
         {
            rcBack.top = rcIcon.top;
            rcBack.left = rcIcon.left;
            rcBack.bottom = bNoGrid ? rcIcon.bottom : ( rcIcon.bottom - 1 );
            rcBack.right = rcIcon.right + 2;
            rcIcon.left += 2;
         }

         hBrush = CreateSolidBrush( lplvcd->clrTextBk );
         FillRect( lplvcd->nmcd.hdc, &rcBack, hBrush );
         DeleteObject( hBrush );

         // Draw image
         ImageList_DrawEx( oSelf->ImageList, LI.iImage, lplvcd->nmcd.hdc, rcIcon.left, rcIcon.top, 0, 0, CLR_DEFAULT, CLR_NONE, ILD_TRANSPARENT );

         return CDRF_SKIPDEFAULT;
      }
      else if( ( x == 1 ) && ( ! bCheckBoxes ) && bPLM )    // Is first subitem and has no image nor checkbox?
      {
         /*
          * LVIR_BOUNDS always returns left == 0 and right == sum of all columns' widths
          * As a workaround use LVIR_LABEL to get the subitem's right and compute it's left
          * by substracting the column's width.
          * Use LVIR_ICON to get the left of the icon area, and use this value as the right
          * of the area to paint.
          */
         ListView_GetSubItemRect( lplvcd->nmcd.hdr.hwndFrom, lplvcd->nmcd.dwItemSpec, lplvcd->iSubItem, LVIR_LABEL, lprcBack );
         rcBack.left = rcBack.right - ListView_GetColumnWidth( lplvcd->nmcd.hdr.hwndFrom, lplvcd->iSubItem );
         ListView_GetSubItemRect( lplvcd->nmcd.hdr.hwndFrom, lplvcd->nmcd.dwItemSpec, lplvcd->iSubItem, LVIR_ICON, lprcIcon );
         rcBack.right = rcIcon.right;

         // Paint to get rid of empty space at left
         hBrush = CreateSolidBrush( lplvcd->clrTextBk );
         FillRect( lplvcd->nmcd.hdc, &rcBack, hBrush );
         DeleteObject( hBrush );

         return CDRF_SKIPDEFAULT;
      }

      return CDRF_DODEFAULT;
   }
   else
   {
      return CDRF_DODEFAULT;
   }
}

HB_FUNC( TGRID_NOTIFY_CUSTOMDRAW )
{
   hb_retni( TGrid_Notify_CustomDraw( hb_param( 1, HB_IT_OBJECT ), ( LPARAM ) hb_parnl( 2 ), hb_parl( 3 ), hb_parni( 4 ), hb_parni( 5 ), hb_parl( 6 ), hb_parl( 7 ), hb_parl( 8 ), hb_parl( 9 ) ) );
}

HB_FUNC( LISTVIEW_GETCHECKSTATE )
{
   hb_retl( ListView_GetCheckState( HWNDparam( 1 ), hb_parni( 2 ) - 1 ) ) ;
}

HB_FUNC( LISTVIEW_SETCHECKSTATE )
{
   ListView_SetCheckState( HWNDparam( 1 ), hb_parni( 2 ) - 1, hb_parl( 3 ) ) ;
}

HB_FUNC( LISTVIEW_GETIMAGELIST )
{
   HWNDret( ListView_GetImageList( HWNDparam( 1 ), hb_parni( 2 ) ) ) ;
}

HB_FUNC( GETDIALOGBASEUNITS )
{
   hb_retnl( GetDialogBaseUnits() ) ;
}

HB_FUNC( LISTVIEW_FINDITEM )
{
   LVFINDINFO fi;

   fi.psz = (LPCTSTR) hb_parc( 3 );
   fi.flags = LVFI_PARTIAL;
   if( hb_parl( 4 ) )
   {
      fi.flags |= LVFI_WRAP;
   }

   hb_retni( ListView_FindItem( HWNDparam( 1 ), (WPARAM) hb_parni( 2 ), (LPARAM) &fi ) + 1 );
}

#ifdef __XHARBOUR__
#include "hbdate.h"
HB_FUNC( HB_MILLISECONDS )
{
   hb_retnint( hb_dateMilliSeconds() );
}
#endif

#pragma ENDDUMP
