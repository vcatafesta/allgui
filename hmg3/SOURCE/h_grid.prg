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
MEMVAR _HMG_GridInplaceEdit_StageEvent   // Pre, Into, Post
MEMVAR _HMG_GridInplaceEdit_ControlHandle
MEMVAR _HMG_GridInplaceEdit_GridIndex
MEMVAR _HMG_GridEx_InplaceEditOption
MEMVAR _HMG_GridEx_InplaceEdit_nMsg

FUNCTION GridInplaceEdit_ControlHandle()

   RETURN _HMG_GridInplaceEdit_ControlHandle

FUNCTION GridInplaceEdit_ControlIndex()

   RETURN GetControlIndexByHandle( _HMG_GridInplaceEdit_ControlHandle )

FUNCTION GridInplaceEdit_GridName()

   RETURN IIF( _HMG_GridInplaceEdit_GridIndex > 0, _HMG_SYSDATA [ 2 ] [ _HMG_GridInplaceEdit_GridIndex ], "")

FUNCTION GridInplaceEdit_ParentName()

   LOCAL hWnd, cFormName := ""

   IF _HMG_GridInplaceEdit_GridIndex > 0
      hWnd := GetControlParentHandleByIndex ( _HMG_GridInplaceEdit_GridIndex )
      GetFormNameByHandle (hWnd, @cFormName)
   ENDIF

   RETURN cFormName

#define WM_COMMAND  273
#define WM_SETFOCUS 7

#include 'hmg.ch'
#include 'common.ch'

FUNCTION _DefineGrid (   ControlName   , ;
      ParentForm   , ;
      x      , ;
      y      , ;
      w      , ;
      h      , ;
      aHeaders, ;
      aWidths, ;
      aRows, ;
      VALUE      , ;
      FONTNAME   , ;
      FONTSIZE   , ;
      TOOLTIP      , ;
      change      , ;
      dblclick   , ;
      aHeadClick   , ;
      gotfocus   , ;
      lostfocus   , ;
      NoGridLines      , ;
      aImage, ;
      aJust, ;
      break      , ;
      HelpId      , ;
      bold      , ;
      italic      , ;
      underline   , ;
      strikeout   , ;
      ownerdata   , ;
      ondispinfo   , ;
      ITEMCOUNT   , ;
      available0   , ;
      available1   , ;
      available2   , ;
      multiselect   , ;
      available3   , ;
      BACKCOLOR   , ;
      FONTCOLOR   , ;
      alloweditInplace   , ;
      editcontrols   , ;
      DYNAMICbackcolor ,;
      DYNAMICforecolor ,;
      columnvalid ,      ;
      COLUMNWHEN ,      ;
      columnheaders ,   ;
      aHeaderImages ,   ;
      CELLNAVIGATION ,  ;
      cRecordSource   , ;
      aColumnFields   , ;
      allowappend      , ;
      buffered   , ;
      allowdelete     , ;
      DYNAMICdisplay, ;
      onsave      , ;
      lockcolumns,;
      OnClick, OnKey, InplaceEditOption,;
      Notrans, NotransHeader,;
      aDynamicFont, OnCheckBoxClicked, OnInplaceEditEvent )
   LOCAL i , cParentForm , mVar, wBitmap , k := 0
   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL cParentTabName
   LOCAL nHeaderImageListHandle := Nil
   LOCAL ldfc := .F.   // ADD3
   LOCAL aColumnClassMap := {}
   LOCAL aFieldNames := {}
   LOCAL j
   LOCAL lArrayRows := .T.   // ADD3

   Available0 := Nil
   Available1 := Nil
   Available2 := Nil
   Available3 := Nil

   DEFAULT alloweditInplace TO .F.
   DEFAULT columnheaders TO .T.

   DEFAULT multiselect TO .F.
   DEFAULT InplaceEditOption TO GRID_EDIT_DEFAULT

   IF ValType ( lockcolumns ) == 'U'
      lockcolumns := 0
   ENDIF

   IF ValType ( cRecordSource ) == 'C'

      IF Select( cRecordSource ) == 0
         MsgHMGError ("Grid: 'RecordSource' WorkArea must be open at control definition. Program Terminated")
      ENDIF

      ownerdata      := .t.
      ITEMCOUNT      := GridRecCount( cRecordSource )
      CELLNAVIGATION := .t.
      buffered       := .t.
      lArrayRows     := .F.   // ADD3

      aSize ( aColumnClassMap , HMG_LEN ( aHeaders ) )

      aSize ( aFieldNames , &cRecordSource->( FCOUNT() ) )

      &cRecordSource->( AFIELDS( aFieldNames ) )

      aFill ( aColumnClassMap , 'E' )

      FOR i := 1 To HMG_LEN ( aColumnFields )
         FOR j := 1 To HMG_LEN ( aFieldNames )
            IF ALLTRIM( HMG_UPPER( aColumnFields [i] ) ) == ALLTRIM( HMG_UPPER( aFieldNames [j] ) )
               aColumnClassMap [ i ] := 'F'
               EXIT
            ENDIF
         NEXT
      NEXT

      IF alloweditInplace
         IF ValType(editcontrols) <> 'A'
            MsgHMGError ("Grid: 'ColumnControls' must be specified when 'RecordSource' was set. Program Terminated")
         ENDIF
      ENDIF

   ENDIF

   IF ValType(aColumnFields) == 'A'
      IF ValType ( cRecordSource ) != 'C'
         MsgHMGError ("Grid: 'ColumnFields' can be specified only for a 'RowSource' bound Grid. Program Terminated")
      ENDIF
   ENDIF

   IF allowappend == .T.
      IF ValType ( cRecordSource ) != 'C'
         MsgHMGError ("Grid: 'AllowAppend' can be specified only for a 'RowSource' bound Grid. Program Terminated")
      ENDIF
   ENDIF

   IF allowdelete == .T.
      IF ValType ( cRecordSource ) != 'C'
         MsgHMGError ("Grid: 'AllowDelete' can be specified only for a 'RowSource' bound Grid. Program Terminated")
      ENDIF
   ENDIF

   IF buffered == .T.
      IF ValType ( cRecordSource ) != 'C'
         MsgHMGError ("Grid: 'Buffered' can be specified only for a 'RowSource' bound Grid. Program Terminated")
      ENDIF
   ENDIF

   IF ValType(dynamicdisplay) == 'A'
      IF ValType ( cRecordSource ) != 'C'
         MsgHMGError ("Grid: 'DynamicDisplay' can be specified only for a 'RowSource' bound Grid. Program Terminated")
      ENDIF
   ENDIF

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
      IF .Not. Empty (_HMG_SYSDATA [ 224 ]) .And. ValType(FontName) == "U"
         FONTNAME := _HMG_SYSDATA [ 224 ]
      ENDIF
      IF .Not. Empty (_HMG_SYSDATA [ 182 ]) .And. ValType(FontSize) == "U"
         FONTSIZE := _HMG_SYSDATA [ 182 ]
      ENDIF
   ENDIF

   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         x    := x + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         y    := y + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
         cParentTabName := _HMG_SYSDATA [ 225 ]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError(_HMG_SYSDATA [ 136 ][1]+ ParentForm + _HMG_SYSDATA [ 136 ][2])
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError (_HMG_SYSDATA [ 136 ][4] + ControlName + _HMG_SYSDATA [ 136 ][5] + ParentForm + _HMG_SYSDATA [ 136 ][6])
   ENDIF

   // ADD April 2016
#define DEFAULT_COLUMNHEADER  "Column "
#define DEFAULT_COLUMNWIDTH   150
   IF lArrayRows == .T.
      IF ValType( aRows ) == "A" .AND. HMG_LEN( aRows ) > 0
         IF ValType( aHeaders ) == "U" .AND. ValType ( aWidths ) == "U"
            aHeaders := ARRAY( HMG_LEN( aRows[ 1 ] ))
            aWidths  := ARRAY( HMG_LEN( aRows[ 1 ] ))
            AEVAL( aHeaders, { |xValue,nIndex| xValue:= NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_NtoS( nIndex ) } )
            AFILL( aWidths,  DEFAULT_COLUMNWIDTH )
         ELSEIF ValType( aHeaders ) == "A" .AND. ValType ( aWidths ) == "U"
            aWidths  := ARRAY( HMG_LEN( aHeaders ))
            AFILL( aWidths,  DEFAULT_COLUMNWIDTH )
         ELSEIF ValType( aHeaders ) == "U" .AND. ValType ( aWidths ) == "A"
            aHeaders := ARRAY( HMG_LEN( aWidths ))
            AEVAL( aHeaders, { |xValue,nIndex| xValue:= NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_NtoS( nIndex ) } )
         ENDIF
      ELSE
         IF ValType( aHeaders ) == "U" .AND. ValType ( aWidths ) == "U"
            aHeaders := {}
            aWidths  := {}
         ELSEIF ValType( aHeaders ) == "A" .AND. ValType ( aWidths ) == "U"
            aWidths  := ARRAY( HMG_LEN( aHeaders ))
            AFILL( aWidths,  DEFAULT_COLUMNWIDTH )
         ELSEIF ValType( aHeaders ) == "U" .AND. ValType ( aWidths ) == "A"
            aHeaders := ARRAY( HMG_LEN( aWidths ))
            AEVAL( aHeaders, { |xValue,nIndex| xValue:= NIL, aHeaders[ nIndex ] := DEFAULT_COLUMNHEADER + hb_NtoS( nIndex ) } )
         ENDIF
      ENDIF
   ENDIF

   IF ValType ( aWidths ) == 'U'
      MsgHMGError ("Grid: WIDTHS not defined .Program Terminated")
   ENDIF

   IF columnheaders == .F.
      aHeaders := array ( HMG_LEN ( aWidths ) )
      afill ( aHeaders , '' )
   ENDIF

   IF ValType ( aHeaders ) == 'U'
      MsgHMGError ("Grid: HEADERS not defined .Program Terminated")
   ENDIF

   IF HMG_LEN ( aHeaders ) != HMG_LEN ( aWidths )
      MsgHMGError ("Browse/Grid: FIELDS/HEADERS/WIDTHS array size mismatch .Program Terminated")
   ENDIF

   IF ValType (aRows) != 'U' .AND. lArrayRows == .T.   // ADD3
      IF HMG_LEN (aRows) > 0 .AND. ValType (aRows [1]) == 'A'   // ADD
         IF HMG_LEN (aRows[1]) != HMG_LEN ( aHeaders )
            MsgHMGError ("Grid: ITEMS length mismatch. Program Terminated")
         ENDIF
      ENDIF
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm = ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF ValType(w) == "U"
      w := 240
   ENDIF
   IF ValType(h) == "U"
      h := 120
   ENDIF
   IF ValType(value) == "U" .and. !MultiSelect
      VALUE := 0
   ENDIF
   IF ValType(aRows) == "U"
      aRows := {}
   ENDIF
   IF ValType(aJust) == "U"      // Grid+
      aJust := Array( HMG_LEN( aHeaders ) )
      aFill( aJust, 0 )
   ELSE
      aSize( aJust, HMG_LEN( aHeaders ) )
      aEval( aJust, { |x| x := iif( x == NIL, 0, x ) } )
   ENDIF
   IF ValType(aImage) == "U"        // Grid+
      aImage := {}
   ENDIF

   IF ValType(x) == "U" .or. ValType(y) == "U"

      IF _HMG_SYSDATA [ 216 ] == 'TOOLBAR'
         Break := .T.
      ENDIF

      _HMG_SYSDATA [ 216 ]   := 'GRID'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitListView ( _HMG_SYSDATA [ 87 ] [i] , 0, 0, 0, w, h ,'',0, NoGridLines, ownerdata , itemcount , multiselect , columnheaders )

         IF ValType(fontname) != "U" .and. ValType(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle, _HMG_SYSDATA [ 87 ] [i] , w , break , , , , _HMG_SYSDATA [ 258 ] )
      ENDIF

   ELSE

      ControlHandle := InitListView ( ParentForm, 0, x, y, w, h ,'',0, NoGridLines, ownerdata  , itemcount  , multiselect , columnheaders )

      IF ValType(fontname) != "U" .and. ValType(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
      ENDIF

   ENDIF

   IF ValType (backcolor) != 'U'
      ListView_SetBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3] )
      ListView_SetTextBkColor ( ControlHandle , backcolor[1] , backcolor[2] , backcolor[3]  )
   ENDIF

   IF ValType (fontcolor) != 'U'
      ListView_SetTextColor ( ControlHandle , fontcolor[1] , fontcolor[2] , fontcolor[3]  )
   ENDIF

   wBitmap := iif( HMG_LEN( aImage ) > 0, AddListViewBitmap( ControlHandle, aImage, Notrans ), 0 )

   IF HMG_LEN( aWidths ) == 0
      aWidths := {0}   // ADD April 2016
   ENDIF

   aWidths[1] := max ( aWidths[1], wBitmap + 2 ) // Set Column 1 width to Bitmap width

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , ControlHandle )
   ENDIF

   IF ValType(aHeadClick) == "U"
      aHeadClick := {}
   ENDIF

   IF ValType(change) == "U"
      change := ""
   ENDIF

   IF ValType(dblclick) == "U"
      dblclick := ""
   ENDIF

   IF ValType(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   IF ValType (aDynamicFont) == "A"
      IF HMG_LEN ( aHeaders ) <> HMG_LEN ( aDynamicFont )
         MsgHMGError ("Grid: DYNAMIC FONT array size mismatch .Program Terminated")
      ENDIF
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [  1 ] [k] :=  if ( multiselect , "MULTIGRID" , "GRID" )
   _HMG_SYSDATA [  2 ] [k] :=  ControlName
   _HMG_SYSDATA [  3 ] [k] :=  ControlHandle
   _HMG_SYSDATA [  4 ] [k] :=  ParentForm
   _HMG_SYSDATA [  5 ] [k] :=  ListView_GetHeader ( ControlHandle )
   _HMG_SYSDATA [  6 ] [k] :=  ondispinfo
   _HMG_SYSDATA [  7 ] [k] :=  aHeaders
   _HMG_SYSDATA [  8 ] [k] :=  Value
   _HMG_SYSDATA [  9 ] [k] :=  Nil
   _HMG_SYSDATA [ 10 ] [k] :=  lostfocus
   _HMG_SYSDATA [ 11 ] [k] :=  gotfocus
   _HMG_SYSDATA [ 12 ] [k] :=  change
   _HMG_SYSDATA [ 13 ] [k] :=  .F.
   _HMG_SYSDATA [ 14 ] [k] :=  aImage
   _HMG_SYSDATA [ 15 ] [k] :=  1       // nCol cellnavigation
   _HMG_SYSDATA [ 16 ] [k] :=  dblclick
   _HMG_SYSDATA [ 17 ] [k] :=  aHeadClick
   _HMG_SYSDATA [ 18 ] [k] :=  y
   _HMG_SYSDATA [ 19 ] [k] :=  x
   _HMG_SYSDATA [ 20 ] [k] :=  w
   _HMG_SYSDATA [ 21 ] [k] :=  h
   _HMG_SYSDATA [ 22 ] [k] :=  Nil
   _HMG_SYSDATA [ 23 ] [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ] [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ] [k] :=  Nil
   _HMG_SYSDATA [ 26 ] [k] :=  0  // nHeaderImageListHandle
   _HMG_SYSDATA [ 27 ] [k] :=  fontname
   _HMG_SYSDATA [ 28 ] [k] :=  fontsize
   _HMG_SYSDATA [ 29 ] [k] :=  {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ] [k] :=  tooltip
   _HMG_SYSDATA [ 31 ] [k] :=  cParentTabName
   _HMG_SYSDATA [ 32 ] [k] :=  cellnavigation
   _HMG_SYSDATA [ 33 ] [k] :=  aHeaders
   _HMG_SYSDATA [ 34 ] [k] :=  .t.
   _HMG_SYSDATA [ 35 ] [k] :=  HelpId
   _HMG_SYSDATA [ 36 ] [k] :=  FontHandle
   _HMG_SYSDATA [ 37 ] [k] :=  aJust
   _HMG_SYSDATA [ 38 ] [k] :=  .T.
   _HMG_SYSDATA [ 39 ] [k] :=  0       // nRow cellnavigation
   _HMG_SYSDATA [ 40 ] [k] := Array (47)

   _HMG_SYSDATA [ 40 ] [ K ] [  1 ] := alloweditInplace   // Allow ENTER
   _HMG_SYSDATA [ 40 ] [ K ] [  2 ] := editcontrols
   _HMG_SYSDATA [ 40 ] [ K ] [  3 ] := dynamicbackcolor
   _HMG_SYSDATA [ 40 ] [ K ] [  4 ] := dynamicforecolor
   _HMG_SYSDATA [ 40 ] [ K ] [  5 ] := columnvalid
   _HMG_SYSDATA [ 40 ] [ K ] [  6 ] := columnwhen
   _HMG_SYSDATA [ 40 ] [ K ] [  7 ] := NIL // old internal dynamicforecolor --> ARRAY (nRowCount , nColCount)
   _HMG_SYSDATA [ 40 ] [ K ] [  8 ] := NIL // old internal dynamicforecolor --> ARRAY (nRowCount , nColCount)
   _HMG_SYSDATA [ 40 ] [ K ] [  9 ] := OWNERDATA
   _HMG_SYSDATA [ 40 ] [ K ] [ 10 ] := cRecordSource
   _HMG_SYSDATA [ 40 ] [ K ] [ 11 ] := aColumnFields
   _HMG_SYSDATA [ 40 ] [ K ] [ 12 ] := allowappend   // Allow ALT+A
   _HMG_SYSDATA [ 40 ] [ K ] [ 13 ] := if ( ValType (aColumnFields) == 'A' , array ( HMG_LEN (aColumnFields) ) , Nil )
   _HMG_SYSDATA [ 40 ] [ K ] [ 14 ] := .F.   // old Grid
   _HMG_SYSDATA [ 40 ] [ K ] [ 15 ] := buffered
   _HMG_SYSDATA [ 40 ] [ K ] [ 16 ] := ldfc
   _HMG_SYSDATA [ 40 ] [ K ] [ 17 ] := allowdelete   // Allow ALT+D and ALT+R
   _HMG_SYSDATA [ 40 ] [ K ] [ 18 ] := dynamicdisplay
   _HMG_SYSDATA [ 40 ] [ K ] [ 19 ] := .F.
   _HMG_SYSDATA [ 40 ] [ K ] [ 20 ] := .F. // Pending Edit Updates Flag
   _HMG_SYSDATA [ 40 ] [ K ] [ 21 ] := {}  // Edit Updates Buffer
   _HMG_SYSDATA [ 40 ] [ K ] [ 22 ] := 0   // Appended Record Buffer Count ( Negative )
   _HMG_SYSDATA [ 40 ] [ K ] [ 23 ] := ItemCount // Buffered Session Initial ItemCount
   _HMG_SYSDATA [ 40 ] [ K ] [ 24 ] :=  0 // Deleted / Recalled record count
   _HMG_SYSDATA [ 40 ] [ K ] [ 25 ] := {} // Delete / Recall Buffer Array { nLogicalRow , nPhysicalRow , cStatus ( 'D' or 'R' ) }
   _HMG_SYSDATA [ 40 ] [ K ] [ 26 ] := OnSave
   _HMG_SYSDATA [ 40 ] [ K ] [ 27 ] := NIL // old internal Enable Virtual Database Grid Optimization
   _HMG_SYSDATA [ 40 ] [ K ] [ 28 ] := backcolor
   _HMG_SYSDATA [ 40 ] [ K ] [ 29 ] := fontcolor
   _HMG_SYSDATA [ 40 ] [ K ] [ 30 ] := aColumnClassMap
   _HMG_SYSDATA [ 40 ] [ K ] [ 31 ] := aWidths
   _HMG_SYSDATA [ 40 ] [ K ] [ 32 ] := lockcolumns
   _HMG_SYSDATA [ 40 ] [ K ] [ 33 ] := .T.  // ENABLEUPDATE = .T. | DISABLEUPDATE = .F.
   _HMG_SYSDATA [ 40 ] [ K ] [ 34 ] := .T.
   _HMG_SYSDATA [ 40 ] [ K ] [ 35 ] := OnClick   // ADD
   _HMG_SYSDATA [ 40 ] [ K ] [ 36 ] := OnKey     // ADD
   _HMG_SYSDATA [ 40 ] [ K ] [ 37 ] := {0,0}   // CellRowClicked and CellColClicked       // ADD
   _HMG_SYSDATA [ 40 ] [ K ] [ 38 ] := IF (ValType(InplaceEditOption) == "N", InplaceEditOption, 0)
   _HMG_SYSDATA [ 40 ] [ K ] [ 39 ] := NotransHeader
   _HMG_SYSDATA [ 40 ] [ K ] [ 40 ] := cParentForm    // ADD
   _HMG_SYSDATA [ 40 ] [ K ] [ 41 ] := aDynamicFont   // ADD
   _HMG_SYSDATA [ 40 ] [ K ] [ 42 ] := 0              // hFont_Dynamic
   _HMG_SYSDATA [ 40 ] [ K ] [ 43 ] := NIL            // aHeaderFont
   _HMG_SYSDATA [ 40 ] [ K ] [ 44 ] := NIL            // aHeaderBackColor
   _HMG_SYSDATA [ 40 ] [ K ] [ 45 ] := NIL            // aHeaderForeColor
   _HMG_SYSDATA [ 40 ] [ K ] [ 46 ] := OnCheckBoxClicked
   _HMG_SYSDATA [ 40 ] [ K ] [ 47 ] := OnInplaceEditEvent

   InitListViewColumns ( ControlHandle, aHeaders , aWidths, aJust )

   IF lArrayRows == .T.   // ADD3
      FOR i := 1 to HMG_LEN (aRows)
         _AddGridRow ( ControlName, cParentForm, aRows [i] )
      NEXT
   ENDIF

   IF multiselect == .T.

      IF ValType ( value ) == 'A'
         ListViewSetMultiSel (ControlHandle,value)
      ENDIF

   ELSE

      IF CellNavigation == .T.
         _SetValue ( , , Value , k )
      ELSE

         IF Value <> 0
            ListView_SetCursel (ControlHandle , Value )
         ENDIF

      ENDIF

   ENDIF

   IF ValType(aHeaderImages) <> "U"
      nHeaderImageListHandle := SetListViewHeaderImages ( ControlHandle , aHeaderImages , aJust, NotransHeader )
      _HMG_SYSDATA [ 22 ] [k] := aHeaderImages
      _HMG_SYSDATA [ 26 ] [k] := nHeaderImageListHandle
   ENDIF

   RETURN NIL

   //* by Dr Claudio Soto, April 2014

FUNCTION _HMG_GridOnClickAndOnKeyEvent

   LOCAL ret := NIL, lInplacedEdit := .F.
   LOCAL i := ASCAN ( _HMG_SYSDATA [3] ,  EventHWND() )

   IF i > 0 .AND. ( EventHWND() == _HMG_GridInplaceEdit_ControlHandle )
      i := _HMG_GridInplaceEdit_GridIndex
      lInplacedEdit := .T.
   ENDIF

   IF i > 0 .AND. ( _HMG_SYSDATA [1] [i] == "GRID" .OR. _HMG_SYSDATA [1] [i] == "MULTIGRID" )

      _HMG_GridEx_InplaceEdit_nMsg  := EventMSG()
      _HMG_GridEx_InplaceEditOption := _HMG_SYSDATA [40] [i] [38]

      IF EventMSG() == WM_SETFOCUS
         HMG_GetLastCharacterEx()
      ENDIF

      IF ( EventMSG() == WM_LBUTTONDOWN .OR. EventMSG() == WM_LBUTTONDBLCLK ) .AND. ValType( _HMG_SYSDATA [40] [i] [35] ) == "B"
         IF lInplacedEdit == .F.
            _HMG_SYSDATA [40] [i] [37] := _GetGridCellData (i)   // { CellRowClicked, CellColClicked }
         ENDIF
         ret := EVAL ( _HMG_SYSDATA [40] [i] [35] )   // OnClick Event
      ENDIF

      IF EventIsKeyboardMessage() == .T. .AND. ValType( _HMG_SYSDATA [40] [i] [36] ) == "B"
         ret := EVAL ( _HMG_SYSDATA [40] [i] [36] )   // OnKey Event
      ENDIF

      IF lInplacedEdit == .F.
         IF ValType(ret) <> "N" .AND. EventMSG() == WM_CHAR .AND. _HMG_GridEx_InplaceEditOption >= 1 .AND. _HMG_GridEx_InplaceEditOption <= 4
            ret := Events (0, WM_COMMAND, 1, 0)
         ENDIF
      ENDIF

   ENDIF

   RETURN ret

FUNCTION _HMG_GridInplaceEditEvent

   STATIC Flag := .F.

   IF ValType (_HMG_GridInplaceEdit_ControlHandle) == "N" .AND. _HMG_GridInplaceEdit_ControlHandle <> 0
      IF Flag == .F.
         Flag := .T.

         IF _HMG_GridEx_InplaceEdit_nMsg == WM_LBUTTONDBLCLK
            HMG_GetLastCharacterEx()
         ENDIF

         IF _HMG_GridEx_InplaceEditOption == 2
            _PushKey (VK_END)
         ELSEIF _HMG_GridEx_InplaceEditOption == 3
            SendMessage (_HMG_GridInplaceEdit_ControlHandle, WM_KEYDOWN, VK_END, 0)
            SendMessage (_HMG_GridInplaceEdit_ControlHandle, WM_KEYUP,   VK_END, 0)
            HMG_SendCharacterEx (_HMG_GridInplaceEdit_ControlHandle, HMG_GetLastCharacterEx())
            _PushKey (VK_END)
         ELSEIF _HMG_GridEx_InplaceEditOption == 4
            IF _HMG_GridEx_InplaceEdit_nMsg == WM_LBUTTONDBLCLK
               _PushKey (VK_BACK)
            ELSE
               HMG_SendCharacter (_HMG_GridInplaceEdit_ControlHandle, HMG_GetLastCharacterEx())
            ENDIF
         ENDIF
      ENDIF
   ELSE
      Flag := .F.
   ENDIF

   RETURN NIL

   // Enhanced by Dr. Claudio Soto (April 2013)

FUNCTION _AddGridRow ( ControlName, ParentForm, aItem, nRowIndex )

   LOCAL i, hWnd, k
   LOCAL iImage := 0, aTemp

   i := GetControlIndex  ( ControlName, ParentForm )

   hWnd := GetControlHandle ( ControlName, ParentForm )

   IF ValType (nRowIndex) == "U"
      nRowIndex := ListView_GetItemCount (hWnd) + 1
   ELSEIF nRowIndex > (ListView_GetItemCount(hWnd) + 1)
      MsgHMGError ("Grid.AddItem (nRowIndex = " +ALLTRIM(STR(nRowIndex))+ "): Invalid nRowIndex. Program Terminated")
   ENDIF

   IF HMG_LEN ( _HMG_SYSDATA [ 7 ] [i] ) != HMG_LEN ( aItem )
      MsgHMGError ("Grid.AddItem (nRowIndex = " +ALLTRIM(STR(nRowIndex))+ "): Item size mismatch. Program Terminated")
   ENDIF

   IF ValType ( _HMG_SYSDATA [40] [i] [2] ) == 'A'   // editcontrols

      aTemp := ARRAY ( HMG_LEN(aItem) )
      AFILL ( aTemp , '' )
      IF HMG_LEN( _HMG_SYSDATA [14] [i] ) > 0   // aImage
         iImage   := aItem[1]
         aItem[1] := NIL
         aTemp[1] := NIL
      ENDIF
      AddListViewItems ( hWnd , aTemp , iImage , nRowIndex-1)
      _SetItem ( ControlName , ParentForm , nRowIndex , aItem )

   ELSE

      IF HMG_LEN( _HMG_SYSDATA [ 14 ][i] ) > 0   // aImage
         iImage   := aItem[1]
         aItem[1] := NIL
      ENDIF

      aTemp := ACLONE( aItem )
      FOR k := 1 TO HMG_LEN( aTemp )   // by Dr. Claudio Soto, April 2016
         IF ValType( aTemp[ k ] ) <> "C"
            aTemp[ k ] := hb_ValToStr( aTemp[ k ] )
         ENDIF
      NEXT

      AddListViewItems ( hWnd , aTemp, iImage , nRowIndex-1)

   ENDIF

   RETURN NIL

   // by Dr. Claudio Soto (April 2013)

PROCEDURE _AddGridColumn ( cControlName , cParentForm , nColIndex , cCaption , nWidth , nJustify, aColumnControl)

   LOCAL lRefresh
   LOCAL k, nWidth_sum := 0

   IF ValType ( nColIndex ) == 'U'
      nColIndex := _GridEx_ColumnCount (cControlName , cParentForm) + 1
   ENDIF

   IF ValType ( cCaption ) == 'U'
      cCaption := ''
   ENDIF

   IF ValType ( nWidth ) == 'U'
      nWidth := 120
   ENDIF

   IF ValType ( nJustify ) == 'U'
      nJustify := GRID_JTFY_LEFT
   ENDIF

   IF ValType ( aColumnControl ) == 'U'
      aColumnControl := {'TEXTBOX','CHARACTER'}
   ENDIF

   _GridEx_AddColumnEx (cControlName, cParentForm, nColIndex)
   lRefresh := .F.
   _GridEx_SetColumnControl (cControlName, cParentForm, _GRID_COLUMN_HEADER_,    nColIndex, cCaption,       lRefresh)
   _GridEx_SetColumnControl (cControlName, cParentForm, _GRID_COLUMN_WIDTH_,     nColIndex, nWidth,         lRefresh)
   _GridEx_SetColumnControl (cControlName, cParentForm, _GRID_COLUMN_JUSTIFY_,   nColIndex, nJustify,       lRefresh)
   _GridEx_SetColumnControl (cControlName, cParentForm, _GRID_COLUMN_CONTROL_,   nColIndex, aColumnControl, lRefresh)

   LISTVIEW_ADDCOLUMN (GetControlHandle(cControlName,cParentForm), nColIndex , nWidth , cCaption , nJustify )   // Call C-Level Routine (source c_grid.c)

   IF SET_GRID_DELETEALLITEMS () == .T.

      RETURN   // for compatibility with old behavior of ADDCOLUMN and DELETECOLUMN
   ENDIF

   FOR k = 1 TO _GridEx_ColumnCount(cControlName,cParentForm)
      nWidth_sum := nWidth_sum + LISTVIEW_GETCOLUMNWIDTH (GetControlHandle (cControlName, cParentForm), k-1)
   NEXT
   IF nWidth_sum > GetProperty (cParentForm, cControlName, "Width")
#define SB_HORZ   0
#define SB_VERT   1
#define SB_CTL    2
#define SB_BOTH   3
      k := GetScrollRangeMax ( GetControlHandle(cControlName,cParentForm), SB_HORZ )
      SETSCROLLRANGE ( GetControlHandle(cControlName,cParentForm), SB_HORZ, 0, k + LISTVIEW_GETCOLUMNWIDTH (GetControlHandle (cControlName, cParentForm), nColIndex-1), .T. )
      SHOWSCROLLBAR (GetControlHandle(cControlName,cParentForm), SB_HORZ, .T.)
   ENDIF

   _GridEx_UpdateCellValue (cControlName, cParentForm, nColIndex)   // Force the rewrite the all items of the Column(nColumnIndex)

   REDRAWWINDOW (GetControlHandle (cControlName, cParentForm))
   UpdateWindow (GetControlHandle (cControlName, cParentForm))

   RETURN

   // by Dr. Claudio Soto (April 2013)

PROCEDURE _DeleteGridColumn ( cControlName , cParentForm , nColIndex)

   LOCAL nItemCount

   _GridEx_DeleteColumnEx (cControlName, cParentForm, nColIndex)
   ListView_DeleteColumn ( GetControlHandle(cControlName,cParentForm), nColIndex )   // Call C-Level Routine (source c_grid.c)

   IF SET_GRID_DELETEALLITEMS () == .T.

      RETURN   // for compatibility with old behavior of ADDCOLUMN and DELETECOLUMN
   ENDIF

   nItemCount := ListView_GetItemCount (GetControlHandle(cControlName,cParentForm))
   LISTVIEW_REDRAWITEMS (GetControlHandle(cControlName,cParentForm) , 0, nItemCount-1)
   REDRAWWINDOW (GetControlHandle (cControlName, cParentForm))
   UpdateWindow (GetControlHandle (cControlName, cParentForm))

   RETURN

FUNCTION _HMG_GRIDINPLACEEDIT(IDX)

   LOCAL r , c , h , aTemp , ri , ci , DW := 0, DH := 0 , DR := 0 , DC := 0
   LOCAL AEDITCONTROLS
   LOCAL AEC := 'TEXTBOX'
   LOCAL AITEMS := {}
   LOCAL ARANGE := {}
   LOCAL DTYPE := 'D'
   LOCAL ALABELS := { '.T.' ,'.F.' }
   LOCAL CTYPE := 'CHARACTER'
   LOCAL CINPUTMASK := ''
   LOCAL CFORMAT := ''
   LOCAL XRES := {}
   LOCAL CVA
   LOCAL CWH
   LOCAL WHEN
   LOCAL GFN
   LOCAL GFS
   LOCAL V
   LOCAL nWx := 0
   LOCAL nHx := 0
   LOCAL ARETURNVALUES
   LOCAL Z
   LOCAL xValue := 0
   LOCAL cRecordSource
   LOCAL cTextFile
   LOCAL nIndex := 0, cProc

   _HMG_GridInplaceEdit_GridIndex := IDX  // ADD

   /*
   AEDITCONTROLS := _HMG_SYSDATA [ 40 ] [ IDX ] [ 2 ]
   IF ValType (AEDITCONTROLS) == "A" .AND. HMG_LEN (AEDITCONTROLS) >= This.CellRowIndex
   IF ValType (AEDITCONTROLS [This.CellRowIndex]) == "A" .AND. HMG_LEN (AEDITCONTROLS [This.CellRowIndex]) >= 2
   IF ValType (AEDITCONTROLS [This.CellRowIndex] [1]) == "C" .AND. ValType (AEDITCONTROLS [This.CellRowIndex] [2]) == "B"
   IF HMG_UPPER (AEDITCONTROLS [This.CellRowIndex] [1]) == 'CUSTOM'
   EVAL (AEDITCONTROLS [This.CellRowIndex] [2])

   RETURN .T.
   ENDIF
   ENDIF
   ENDIF
   ENDIF
   */

   IF _HMG_SYSDATA [ 232 ] == 'GRID_WHEN'
      MsgHMGError("GRID: Editing within a grid 'when' event procedure is not allowed. Program terminated" )
   ENDIF
   IF _HMG_SYSDATA [ 232 ] == 'GRID_VALID'
      MsgHMGError("GRID: Editing within a grid 'valid' event procedure is not allowed. Program terminated" )
   ENDIF

   IF _HMG_SYSDATA [32] [idx] == .F.

      IF This.CellRowIndex != LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [ idx ] )

         RETURN .f.
      ENDIF

   ELSE

      IF This.CellRowIndex != _HMG_SYSDATA [39] [ idx ]

         RETURN .f.
      ENDIF

   ENDIF

   ri := This.CellRowIndex
   ci := This.CellColIndex

   IF ri == 0 .or. ci == 0

      RETURN  .f.
   ENDIF

   IF ValType ( _HMG_SYSDATA [ 40 ] [ idx ] [ 10 ] ) == 'C'

      IF IsDataGridDeleted ( idx , ri )

         RETURN .f.
      ENDIF

      cRecordSource   := _HMG_SYSDATA [ 40 ] [ idx ] [ 10 ]

      IF &cRecordSource->(RddName()) == 'PGRDD'
         MsgHMGError("GRID: Modify PostGre RDD tables is not allowed. Program terminated" )
      ENDIF

      IF &cRecordSource->(RddName()) == 'SQLMIX'
         MsgHMGError("GRID: Modify SQLMIX RDD tables is not allowed. Program terminated" )
      ENDIF

   ENDIF

   GFN := _HMG_SYSDATA [ 27 ] [idx]   // FontName
   GFS := _HMG_SYSDATA [ 28 ] [idx]   // FontSize

   //Problem3031

   IF _HMG_SYSDATA [ 40 ] [ idx ] [ 9 ] == .F.

      aTemp := this.item(ri)

      v := aTemp [ci]

   ELSE

      _HMG_SYSDATA [ 201 ] := ri   // QueryRowIndex

      _HMG_SYSDATA [ 202 ] := ci   // QueryColIndex

      _HMG_SYSDATA [ 320 ] := .T.

      IF ValType ( _HMG_SYSDATA [ 40 ] [ idx ] [ 10 ] ) == 'C'

         GetDataGridCellData ( idx , .t. )

      ELSE

         Eval( _HMG_SYSDATA [  6 ] [ idx ]  )

      ENDIF

      _HMG_SYSDATA [ 320 ] := .F.

      v := _HMG_SYSDATA [ 230 ]      // QueryData

   ENDIF

   CWH :=    _HMG_SYSDATA [40] [IDX] [6]   // ColumnWhen

   //Problem3031

   IF ValType ( CWH ) = 'A'

      IF HMG_LEN ( CWH ) >= CI

         IF ValType ( CWH [CI] ) = 'B'

            _HMG_SYSDATA [ 318 ] := V

            _HMG_SYSDATA [ 232 ] := 'GRID_WHEN'

            WHEN := EVAL ( CWH [CI] )

            _HMG_SYSDATA [ 232 ] := ''

            IF WHEN = .F.
               _HMG_SYSDATA [ 256 ] := .F.

               RETURN .f.
            ENDIF

         ENDIF

      ENDIF

   ENDIF

   h := _HMG_SYSDATA [3] [IDX]   // ControlHandle

   //   This.CellRow    --> _HMG_SYSDATA [ 197 ]
   //   This.CellCol    --> _HMG_SYSDATA [ 198 ]
   //   This.CellWidth  --> _HMG_SYSDATA [ 199 ]
   //   This.CellHeight --> _HMG_SYSDATA [ 200 ]

   r := This.CellRow + GetWindowRow ( h ) - this.row - 1

   IF _HMG_SYSDATA [ 23 ]  [idx] <> -1
      r := r - _HMG_SYSDATA [ 23 ] [idx]
   ENDIF

   c := This.CellCol + GetWindowCol ( h ) - this.col + 2

   IF _HMG_SYSDATA [ 24 ] [idx] <> -1
      c := c - _HMG_SYSDATA [ 24 ] [idx]
   ENDIF

   AEDITCONTROLS := _HMG_SYSDATA [ 40 ] [ IDX ] [ 2 ]

   CVA :=    _HMG_SYSDATA [ 40 ] [ IDX ] [ 5 ]

   XRES := _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , CI )

   AEC      := XRES [1]
   CTYPE      := XRES [2]
   CINPUTMASK   := XRES [3]
   CFORMAT      := XRES [4]
   AITEMS      := XRES [5]
   ARANGE      := XRES [6]
   DTYPE      := XRES [7]
   ALABELS      := XRES [8]
   ARETURNVALUES   := XRES [9]

   IF AEC = 'COMBOBOX'
      DH := 1
   ELSEIF AEC = 'CHECKBOX'
      DR := 3
      DH := -7
   ELSEIF AEC = 'EDITBOX'
      _HMG_SYSDATA [321] := .T.
   ENDIF

   _HMG_SYSDATA [ 109 ] := GetActiveWindow()

   // Grid Valid Event Procedure Values

   _HMG_SYSDATA [ 209 ] := idx

   _HMG_SYSDATA [ 245 ] := .F.

   IF AEC = 'EDITBOX'

      DEFINE WINDOW _HMG_GRID_InplaceEdit AT 0 , 0 ;
            WIDTH   350    ;
            HEIGHT   350 + IF ( IsAppThemed() , 3 , 0 ) ;
            TITLE _HMG_SYSDATA [  7 ] [ idx ] [ ci ] ;
            MODAL ;
            NOSIZE ;
            SHORTTITLEBAR

      ELSE

         DEFINE WINDOW _HMG_GRID_InplaceEdit AT r + DR , c + DC ;
               WIDTH This.CellWidth +  DW ;
               HEIGHT This.CellHeight + 6 + DH ;
               TITLE '' ;
               MODAL NOSIZE NOCAPTION

         ENDIF

         ON KEY ESCAPE ACTION ( _HMG_SYSDATA [ 256 ] := .T. , THISWINDOW.RELEASE )

         _HMG_GridInplaceEdit_ControlHandle := 0   //ADD

         IF AEC = 'EDITBOX'

            ON KEY CONTROL+W ACTION IF ( _ISWINDOWACTIVE ( '_HMG_GRID_InplaceEdit' ),;
               ( _HMG_SYSDATA [ 256 ] := .F. ,;
               _HMG_GRIDINPLACEEDITOK( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues, V ) ),;  // ADD V parameter, by Pablo on February, 2015
               NIL )

            DEFINE BUTTON OK
               ROW   298
               COL   278 - IF ( IsAppThemed() , 1 , 0 )
               WIDTH   28
               HEIGHT   28
               ACTION   IF ( _ISWINDOWACTIVE ( '_HMG_GRID_InplaceEdit' ),;
                  ( _HMG_SYSDATA [ 256 ] := .F. , _HMG_GRIDINPLACEEDITOK( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues, V ) ),;  // ADD V parameter, by Pablo on February, 2015
                  NIL )
               PICTURE   'GRID_MSAV'
               TOOLTIP _hmg_sysdata [ 133 ] [ 12 ] + ' [Ctrl+W]'
            END BUTTON

            DEFINE BUTTON CANCEL
               ROW   298
               COL   312 - IF ( IsAppThemed() , 1 , 0 )
               WIDTH   28
               HEIGHT   28
               ACTION   ( _HMG_SYSDATA [ 256 ] := .T. , THISWINDOW.RELEASE )
               PICTURE   'GRID_MCAN'
               TOOLTIP _hmg_sysdata [ 133 ] [ 13 ] + ' [Esc]'
            END BUTTON

         ELSE

            ON KEY RETURN ACTION IIF ( _ISWINDOWACTIVE ( '_HMG_GRID_InplaceEdit' ),;
               ( _HMG_SYSDATA [ 256 ] := .F. , _HMG_GRIDINPLACEEDITOK( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues, V ) ) ,;  // ADD V parameter, by Pablo on February, 2015
               NIL )

            ON KEY TAB    ACTION ( _HMG_SYSDATA [ 285 ] := .T. , InsertReturn() )

         ENDIF

         ON KEY F2 ACTION IF ( _ISWINDOWACTIVE ( '_HMG_GRID_InplaceEdit' ),;
            ( _HMG_SYSDATA [ 256 ] := .F. , _HMG_GRIDINPLACEEDITOK( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues, V ) ) ,;  // ADD V parameter, by Pablo on February, 2015
            NIL )

         IF AEC == 'TEXTBOX' //*****************************************

            IF _HMG_SYSDATA [321] == .F.

               DEFINE TEXTBOX T

               ELSE

                  DEFINE EDITBOX T
                     HSCROLLBAR      .F.
                     VSCROLLBAR      .F.

                  ENDIF

                  FONTNAME   GFN
                  FONTSIZE   GFS

                  ROW   0
                  COL   0
                  WIDTH    This.CellWidth      + nWx
                  HEIGHT   This.CellHeight + 6   + nHx

                  IF CTYPE == 'NUMERIC'
                     NUMERIC .T.
                  ELSEIF CTYPE == 'PASSWORD'  // By Pablo on February, 2015
                     PASSWORD .T.
                  ELSEIF CTYPE == 'DATE'
                     DATE .T.
                  ENDIF

                  VALUE   v

                  IF ! EMPTY ( CINPUTMASK )
                     INPUTMASK CINPUTMASK
                  ENDIF

                  IF ! EMPTY ( CFORMAT )
                     FORMAT CFORMAT
                  ENDIF

                  IF _HMG_SYSDATA [321] == .F.
                  END TEXTBOX
               ELSE
               END EDITBOX
            ENDIF

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("t","_HMG_GRID_InplaceEdit")   //ADD

         ELSEIF AEC == 'EDITBOX' //**********************************************

            IF ":" $ V .and. File(V)                        // By Pablo on February, 2015
               cTextFile:=hb_MemoRead(V)
            ELSEIF "\" $ V .and. File(GetCurrentFolder()+V)
               cTextFile:=hb_MemoRead(GetCurrentFolder()+V)
            ELSEIF HMG_LOWER(V)=="<memo>" .or. IsDataGridMemo ( Idx, ci )
               cTextFile:=GetDataGridCellData ( idx , .t. )
            ELSE
               cTextFile:=V
            ENDIF

            DEFINE EDITBOX T
               HSCROLLBAR .T.
               VSCROLLBAR .T.
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW        2
               COL        2
               WIDTH      340
               HEIGHT     292
               VALUE      cTextFile  // By Pablo on February, 2015
            END EDITBOX

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("t","_HMG_GRID_InplaceEdit")   //ADD

         ELSEIF AEC == 'DATEPICKER' //*******************************************

            DEFINE DATEPICKER D
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW      0
               COL      0
               WIDTH      This.CellWidth
               HEIGHT      This.CellHeight + 6
               VALUE      V
               SHOWNONE   .T.

               IF DTYPE = 'DROPDOWN'
                  UPDOWN .F.
               ELSEIF DTYPE = 'UPDOWN'
                  UPDOWN .T.
               ENDIF

            END DATEPICKER

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("D","_HMG_GRID_InplaceEdit")   //ADD

         ELSEIF AEC == 'TIMEPICKER' //*******************************************   ( Claudio Soto, April 2013 )

            DEFINE TIMEPICKER TPICK
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW        0
               COL        0
               WIDTH      This.CellWidth
               HEIGHT     This.CellHeight + 6
               VALUE      V
               SHOWNONE   .F.
               FORMAT     CFORMAT
            END TIMEPICKER

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("tpick","_HMG_GRID_InplaceEdit")   //ADD

         ELSEIF AEC == 'COMBOBOX' //********************************************

            DEFINE COMBOBOX C
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW   0
               COL   0
               WIDTH    This.CellWidth
               ITEMS   AITEMS

               IF HMG_LEN ( ARETURNVALUES ) == 0
                  VALUE   v
               ELSE

                  FOR z := 1 To HMG_LEN ( aReturnValues )

                     IF v = aReturnValues [z]

                        xValue := z
                        EXIT

                     ENDIF

                  NEXT z

                  IF xValue == 0
                     xValue := 1
                  ENDIF

                  VALUE xValue

               ENDIF

               ONDROPDOWN   _hmg_grid_disablekeys()
               ONCLOSEUP   _hmg_grid_enablekeys( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues )

            END COMBOBOX

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("C","_HMG_GRID_InplaceEdit")   //ADD

         ELSEIF AEC == 'SPINNER' //*********************************************

            DEFINE SPINNER S
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW        0
               COL        0
               WIDTH      This.CellWidth
               HEIGHT     This.CellHeight + 6
               VALUE      V
               RANGEMIN   ARANGE [1]
               RANGEMAX   ARANGE [2]
               INCREMENT  ARANGE [3]  // By Pablo on February, 2015
            END SPINNER

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("S","_HMG_GRID_InplaceEdit")

         ELSEIF AEC == 'CHECKBOX' //********************************************

            DEFINE CHECKBOX C
               FONTNAME   GFN
               FONTSIZE   GFS
               ROW      0
               COL      0
               WIDTH       This.CellWidth + DW
               HEIGHT      This.CellHeight + 6 + DH
               VALUE      V

               IF V == .T.
                  CAPTION ALABELS [1]
               ELSEIF V == .F.
                  CAPTION ALABELS [2]
               ENDIF

               BACKCOLOR WHITE
               ONCHANGE IF ( THIS.VALUE == .T. , THIS.CAPTION := ALABELS [1] , THIS.CAPTION := ALABELS [2] )
            END CHECKBOX

            _HMG_GridInplaceEdit_ControlHandle := GetControlHandle ("C","_HMG_GRID_InplaceEdit")   //ADD

         ENDIF

      END WINDOW

      IF ValType( _HMG_GridInplaceEdit_ControlHandle ) == "A"
         _HMG_GridInplaceEdit_ControlHandle := _HMG_GridInplaceEdit_ControlHandle [1]
      ENDIF

      _HMG_GridInplaceEdit_StageEvent := 1   // PreEvent
      _HMG_OnInplaceEditEvent( IDX )

      _HMG_GridInplaceEdit_StageEvent := 2   // Into Event
      cProc := "_HMG_OnInplaceEditEvent( " + hb_NtoS( IDX ) + " ) "
      nIndex := EventCreate( cProc, NIL, NIL )   // by Dr. Claudio Soto, April 2016

      IF AEC = 'EDITBOX'

         SETFOCUS ( GetControlHandle( 't' , '_HMG_GRID_InplaceEdit' ) )

         CENTER WINDOW _HMG_GRID_InplaceEdit

      ENDIF

      ACTIVATE WINDOW _HMG_GRID_InplaceEdit

      // MsgDebug ("InplaceEdit END")

      IF nIndex > 0   // by Dr. Claudio Soto, April 2016
         EventRemove ( nIndex )
      ENDIF

      _HMG_GridInplaceEdit_StageEvent := 3   // PostEvent
      _HMG_OnInplaceEditEvent( IDX )

      _HMG_GridInplaceEdit_StageEvent    := 0   //ADD
      _HMG_GridInplaceEdit_ControlHandle := 0   //ADD
      _HMG_GridInplaceEdit_GridIndex     := 0   //ADD

      _HMG_SYSDATA [ 109 ] := 0

      SETFOCUS ( _HMG_SYSDATA [3] [IDX] )

      _HMG_SYSDATA [321] := .F.

      RETURN .t.

FUNCTION _HMG_OnInplaceEditEvent( nIndex )

   LOCAL Ret := NIL

   IF _HMG_GridInplaceEdit_ControlHandle <> 0 .AND. ValType( _HMG_SYSDATA [ 40 ] [ nIndex ] [ 47 ] ) == "B"
      Ret := EVAL( _HMG_SYSDATA [ 40 ] [ nIndex ] [ 47 ] )
   ENDIF

   RETURN Ret

PROCEDURE _hmg_grid_disablekeys

   RELEASE KEY RETURN OF _HMG_GRID_InplaceEdit
   RELEASE KEY ESCAPE OF _HMG_GRID_InplaceEdit

   RETURN

PROCEDURE _hmg_grid_enablekeys( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues )

   ON KEY RETURN OF _HMG_GRID_InplaceEdit ACTION IF ( _ISWINDOWACTIVE ( '_HMG_GRID_InplaceEdit' ),;
      ( _HMG_SYSDATA [ 256 ] := .F. , _HMG_GRIDINPLACEEDITOK ( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues ) ),;
      NIL )

   ON KEY ESCAPE OF _HMG_GRID_InplaceEdit ACTION ( _HMG_SYSDATA [ 256 ] := .T. , _HMG_GRID_InplaceEdit.RELEASE )

   RETURN

FUNCTION _HMG_PARSEGRIDCONTROLS ( AEDITCONTROLS , CI )

   LOCAL AEC := 'TEXTBOX'
   LOCAL AITEMS := {}
   LOCAL ARANGE := {}
   LOCAL DTYPE := 'D'
   LOCAL ALABELS := { '.T.' ,'.F.' }
   LOCAL CTYPE := 'CHARACTER'
   LOCAL CINPUTMASK := ''
   LOCAL CFORMAT := ''
   LOCAL ARET := {}
   LOCAL DW , DH , DR , DC
   LOCAL ARETURNVALUES := {}

   IF ValType ( AEDITCONTROLS ) = 'A'

      IF HMG_LEN ( AEDITCONTROLS ) >= ci

         IF ValType ( AEDITCONTROLS [CI] ) = 'A'

            IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 1

               AEC := AEDITCONTROLS [CI] [1]

               IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 2 ;
                     .AND. ;
                     AEC == 'TEXTBOX'

                  IF ValType ( AEDITCONTROLS [CI] [2] ) = 'C'
                     CTYPE := AEDITCONTROLS [CI] [2]
                  ENDIF

                  IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 3
                     IF ValType ( AEDITCONTROLS [CI] [3] ) = 'C'
                        CINPUTMASK := AEDITCONTROLS [CI] [3]
                     ENDIF
                  ENDIF

                  IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 4
                     IF ValType ( AEDITCONTROLS [CI] [4] ) = 'C'
                        CFORMAT := AEDITCONTROLS [CI] [4]
                     ENDIF
                  ENDIF

               ENDIF

               IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 2 ;
                     .AND. ;
                     AEC == 'COMBOBOX'

                  IF ValType ( AEDITCONTROLS [CI] [2] ) = 'A'
                     AITEMS := AEDITCONTROLS [CI] [2]
                  ENDIF

                  IF HMG_LEN ( AEDITCONTROLS [CI] ) == 3
                     IF ValType ( AEDITCONTROLS [CI] [3] ) = 'A'
                        ARETURNVALUES := AEDITCONTROLS [CI] [3]
                     ENDIF
                  ENDIF

               ENDIF

               IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 3 .AND. AEC == 'SPINNER'

                  IF ValType ( AEDITCONTROLS [CI] [2] ) = 'N' .AND. ValType ( AEDITCONTROLS [CI] [3] ) = 'N'
                     ARANGE := { AEDITCONTROLS [CI] [2] , AEDITCONTROLS [CI] [3] , 1 }
                  ENDIF
                  IF HMG_LEN (AEDITCONTROLS [CI]) == 4 .AND. ValType ( AEDITCONTROLS [CI] [4] ) = 'N'
                     ARANGE [3] := AEDITCONTROLS [CI] [4]
                  ENDIF

               ENDIF

               IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 2 ;
                     .AND. ;
                     AEC == 'DATEPICKER'
                  IF    ValType ( AEDITCONTROLS [CI] [2] ) = 'C'
                     DTYPE := AEDITCONTROLS [CI] [2]
                  ENDIF
               ENDIF

               IF HMG_LEN ( AEDITCONTROLS [CI] ) >= 2 ;
                     .AND. ;
                     AEC == 'TIMEPICKER'
                  IF ValType ( AEDITCONTROLS [CI] [2] ) = 'C'
                     CFORMAT := AEDITCONTROLS [CI] [2]
                  ENDIF
               ENDIF

               IF HMG_LEN ( AEDITCONTROLS [CI] ) == 3   .AND.   AEC == 'CHECKBOX'
                  DW := -4
                  DH := -7
                  DR := 3
                  DC := 2
                  IF ValType ( AEDITCONTROLS [CI] [2] ) = 'C'   .AND.   ValType ( AEDITCONTROLS [CI] [3] ) = 'C'
                     ALABELS := { AEDITCONTROLS [CI] [2] , AEDITCONTROLS [CI] [3] }
                  ENDIF
               ENDIF

            ENDIF

         ENDIF

      ENDIF

   ENDIF

   ARET := { AEC , CTYPE , CINPUTMASK , CFORMAT , AITEMS , ARANGE , DTYPE , ALABELS , ARETURNVALUES }

   RETURN ( ARET )

PROCEDURE _HMG_GRIDINPLACEEDITOK( IDX , CI , RI , AEC , ALABELS , CTYPE , CINPUTMASK , CFORMAT , CVA , aReturnValues, cValCell ) // ADD cValCell parameter, by Pablo on February, 2015

   LOCAL VALID, aTemp
   LOCAL Z
   LOCAL cTextFile:="" /* By Pablo on February, 2015 */

   ALABELS    := NIL   // ADD
   CTYPE      := NIL   // ADD
   CINPUTMASK := NIL   // ADD
   CFORMAT    := NIL   // ADD

   HMG_GetLastCharacterEx()   // Clean key char buffer

   IF ValType ( CVA ) = 'A'

      IF HMG_LEN ( CVA ) >= CI

         IF ValType ( CVA [CI] ) = 'B'

            IF   AEC == 'TEXTBOX' .or. AEC == 'EDITBOX'
               _HMG_SYSDATA [ 318 ] := GetProperty ( "_HMG_GRID_InplaceEdit","t","value")
            ELSEIF   AEC == 'DATEPICKER'
               _HMG_SYSDATA [ 318 ] := _HMG_GRID_InplaceEdit.d.value

            ELSEIF   AEC == 'TIMEPICKER'
               _HMG_SYSDATA [ 318 ] := _HMG_GRID_InplaceEdit.tpick.value

            ELSEIF   AEC == 'COMBOBOX'

               IF HMG_LEN ( ARETURNVALUES ) == 0

                  _HMG_SYSDATA [ 318 ] := _HMG_GRID_InplaceEdit.c.value

               ELSE

                  _HMG_SYSDATA [ 318 ] := aReturnValues [_HMG_GRID_InplaceEdit.c.value ]

               ENDIF

            ELSEIF   AEC == 'SPINNER'
               _HMG_SYSDATA [ 318 ] := _HMG_GRID_InplaceEdit.s.value
            ELSEIF   AEC == 'CHECKBOX'
               _HMG_SYSDATA [ 318 ] := _HMG_GRID_InplaceEdit.c.value
            ENDIF

            _HMG_SYSDATA [ 232 ] := 'GRID_VALID'

            _DoControlEventProcedure ( CVA [CI] , _HMG_SYSDATA [ 209 ] )

            VALID := _HMG_SYSDATA [ 293 ]

            _HMG_SYSDATA [ 232 ] := ''

            IF VALID = .F.

               MSGEXCLAMATION ( _HMG_SYSDATA [ 136 ][11] )

               RETURN

            ENDIF

            redrawwindow( _HMG_SYSDATA [3] [IDX] )

         ENDIF

      ENDIF

   ENDIF

   IF _HMG_SYSDATA [ 40 ] [ idx ] [ 9 ] == .F.

      aTemp := _GetItem (  ,  , ri , idx )

   ELSE

      aTemp := array ( HMG_LEN( _HMG_SYSDATA [  7 ] [ idx ] ) )

      aTemp := aFill ( aTemp , '' )

      FOR Z := 1 TO HMG_LEN ( _HMG_SYSDATA [  7 ] [ idx ] )

         _HMG_SYSDATA [ 201 ] := ri   // QueryRowIndex

         _HMG_SYSDATA [ 202 ] := z   // QueryColIndex

         IF ValType ( _HMG_SYSDATA [ 40 ] [ idx ] [ 10 ] ) == 'C'

            GetDataGridCellData ( idx , .t. )

         ELSE

            Eval( _HMG_SYSDATA [  6 ] [ idx ]  )

         ENDIF

         aTemp [z] := _HMG_SYSDATA [ 230 ]   // QueryData

      NEXT Z

   ENDIF

   IF   AEC == 'TEXTBOX' .OR. AEC = 'EDITBOX'
      aTemp [ci] := GetProperty ( "_HMG_GRID_InplaceEdit","t","value")
   ELSEIF   AEC == 'DATEPICKER'
      aTemp [ci] := _HMG_GRID_InplaceEdit.d.value

   ELSEIF   AEC == 'TIMEPICKER'
      aTemp [ci] := _HMG_GRID_InplaceEdit.tpick.value

   ELSEIF   AEC == 'COMBOBOX'

      IF HMG_LEN ( ARETURNVALUES ) == 0

         aTemp [ci] := _HMG_GRID_InplaceEdit.c.value

      ELSE

         aTemp [ci] := aReturnValues [_HMG_GRID_InplaceEdit.c.value ]

      ENDIF

   ELSEIF   AEC == 'SPINNER'
      aTemp [ci] := _HMG_GRID_InplaceEdit.s.value
   ELSEIF   AEC == 'CHECKBOX'
      aTemp [ci] := _HMG_GRID_InplaceEdit.c.value
   ENDIF

   IF _HMG_SYSDATA [ 40 ] [ idx ] [ 9 ] == .F.

      IF AEC == 'EDITBOX'  // By Pablo on February, 2015
         IF ":" $ cValCell .and. File(cValCell)
            cTextFile:=cValCell
         ELSEIF "\" $ cValCell .and. File(GetCurrentFolder()+cValCell)
            cTextFile:=GetCurrentFolder()+cValCell
         ELSEIF HMG_LOWER(cValCell)=="<memo>" .or. IsDataGridMemo ( Idx, ci )
            cTextFile:=GetDataGridCellData ( idx , .t. )
         ELSE
            cTextFile:=""
         ENDIF
      ENDIF
      IF Empty(cTextFile)
         _SetItem ( , , ri , aTemp , idx )
      ELSE
         hb_MemoWrit(cTextFile,aTemp[ci])   // By Pablo on February, 2015
      ENDIF

   ENDIF

   IF ValType ( _HMG_SYSDATA [ 40 ] [ idx ] [ 10 ] ) == 'C'

      _HMG_SYSDATA [ 196 ] := ci

      SaveDataGridField ( idx , aTemp [ci] )

   ENDIF

   _HMG_GRID_InplaceEdit.RELEASE

   RETURN

PROCEDURE _HMG_SetGridCellEditValue ( arg )

   IF   ValType ( arg ) == 'C'

      IF _IsControlDefined ( 't' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "t" , "value" , arg )

      ENDIF

   ELSEIF   ValType ( arg ) == 'D'

      IF _IsControlDefined ( 't' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "t" , "value" , arg )

      ELSEIF _IsControlDefined ( 'd' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "d" , "value" , arg )

      ENDIF

   ELSEIF   ValType ( arg ) == 'N'

      IF _IsControlDefined ( 'c' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "c" , "value" , arg )

      ELSEIF _IsControlDefined ( 's' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "s" , "value" , arg )

      ELSEIF _IsControlDefined ( 't' , "_HMG_GRID_InplaceEdit")

         SetProperty ( "_HMG_GRID_InplaceEdit" , "t" , "value" , arg )

      ENDIF

   ELSEIF   ValType ( arg ) == 'L'

      SetProperty ( "_HMG_GRID_InplaceEdit" , "c" , "value" , arg )

   ENDIF

   RETURN

FUNCTION GetControlSafeRow (i)

   RETURN IF (ValType(_HMG_SYSDATA [18] [i]) == "N", _HMG_SYSDATA [18] [i], 0)   // for SplitBox

FUNCTION GetControlSafeCol (i)

   RETURN IF (ValType(_HMG_SYSDATA [19] [i]) == "N", _HMG_SYSDATA [19] [i], 0)   // for SplitBox

PROCEDURE _HMG_GRIDINPLACEKBDEDIT(i)

   LOCAL TmpRow
   LOCAL XS
   LOCAL XD
   LOCAL R
   LOCAL IPE_MAXCOL

   IPE_MAXCOL := HMG_LEN ( _HMG_SYSDATA [ 33 ] [i] )

   DO WHILE .T.

      TmpRow := LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] )

      IF TmpRow != _HMG_SYSDATA [ 341 ]

         _HMG_SYSDATA [ 341 ] := TmpRow

         IF HMG_LEN ( _HMG_SYSDATA [ 14 ] [i] ) > 0
            _HMG_SYSDATA [ 340 ] := 2
         ELSE
            _HMG_SYSDATA [ 340 ] := 1
         ENDIF

      ENDIF

      _HMG_SYSDATA [ 195 ] := _HMG_SYSDATA [ 341 ]
      _HMG_SYSDATA [ 196 ] := _HMG_SYSDATA [ 340 ]

      IF _HMG_SYSDATA [ 340 ] == 1
         r := LISTVIEW_GETITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 341 ] - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 341 ] - 1 , _HMG_SYSDATA [ 340 ] - 1 )
      ENDIF

      xs :=   ( ( GetControlSafeCol(i) + r [2] ) +( r[3] ))  -  ( GetControlSafeCol(i) + _HMG_SYSDATA [ 20 ] [i] )

      xd := 20

      IF xs > -xd
         ListView_Scroll( _HMG_SYSDATA [3] [i] ,   xs + xd , 0 )
      ELSE

         IF r [2] < 0
            ListView_Scroll( _HMG_SYSDATA [3] [i] , r[2]   , 0 )
         ENDIF

      ENDIF

      IF _HMG_SYSDATA [ 340 ] == 1
         r := LISTVIEW_GETITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 341 ] - 1 )
      ELSE
         r := LISTVIEW_GETSUBITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 341 ] - 1 , _HMG_SYSDATA [ 340 ] - 1 )
      ENDIF

      _HMG_SYSDATA [ 197 ] := GetControlSafeRow(i) + r [1]
      _HMG_SYSDATA [ 198 ] := GetControlSafeCol(i) + r [2]
      _HMG_SYSDATA [ 199 ] := r[3]
      _HMG_SYSDATA [ 200 ] := r[4]

      _HMG_SYSDATA [ 194 ] := ascan ( _HMG_SYSDATA [ 67  ] , _HMG_SYSDATA [4][i] )
      _HMG_SYSDATA [ 231 ] := 'C'
      _HMG_SYSDATA [ 203 ] := i
      _HMG_SYSDATA [ 316 ] :=  _HMG_SYSDATA [  66 ] [ _HMG_SYSDATA [ 194 ] ]
      _HMG_SYSDATA [ 317 ] :=  _HMG_SYSDATA [2] [_HMG_SYSDATA [ 203 ]]

      _HMG_GRIDINPLACEEDIT(I)

      _HMG_SYSDATA [ 203 ] := 0
      _HMG_SYSDATA [ 231 ] := ''

      _HMG_SYSDATA [ 195 ] := 0
      _HMG_SYSDATA [ 196 ] := 0
      _HMG_SYSDATA [ 197 ] := 0
      _HMG_SYSDATA [ 198 ] := 0
      _HMG_SYSDATA [ 199 ] := 0
      _HMG_SYSDATA [ 200 ] := 0

      _HMG_SYSDATA [ 194 ] := 0
      _HMG_SYSDATA [ 232 ] := ''
      _HMG_SYSDATA [ 316 ] :=  ''
      _HMG_SYSDATA [ 317 ] := ''

      IF _HMG_SYSDATA [ 256 ] == .T.

         IF _HMG_SYSDATA [ 340 ] == IPE_MAXCOL

            IF HMG_LEN ( _HMG_SYSDATA [ 14 ] [i] ) > 0
               _HMG_SYSDATA [ 340 ] := 2
            ELSE
               _HMG_SYSDATA [ 340 ] := 1
            ENDIF

            ListView_Scroll( _HMG_SYSDATA [3] [i] ,   -10000  , 0 )
         ENDIF

         EXIT

      ELSE

         _HMG_SYSDATA [ 340 ]++

         IF _HMG_SYSDATA [ 340 ] > IPE_MAXCOL

            IF HMG_LEN ( _HMG_SYSDATA [ 14 ] [i] ) > 0
               _HMG_SYSDATA [ 340 ] := 2
            ELSE
               _HMG_SYSDATA [ 340 ] := 1
            ENDIF

            ListView_Scroll( _HMG_SYSDATA [3] [i] ,   -10000  , 0 )
            EXIT
         ENDIF

      ENDIF

   ENDDO

   RETURN

FUNCTION GetNumFromCellText ( Text )

   LOCAL x , c , s

   s := ''

   FOR x := 1 To HMG_LEN ( Text )

      c := HB_USUBSTR(Text,x,1)

      IF c='0' .or. c='1' .or. c='2' .or. c='3' .or. c='4' .or. c='5' .or. c='6' .or. c='7' .or. c='8' .or. c='9' .or. c='.' .or. c='-'
         s := s + c
      ENDIF

   NEXT x

   IF HB_ULEFT ( ALLTRIM(Text) , 1 ) == '(' .OR.  HB_URIGHT ( ALLTRIM(Text) , 2 ) == 'DB'
      s := '-' + s
   ENDIF

   RETURN Val(s)

FUNCTION GETNumFromCellTextSP(Text)

   LOCAL x , c , s

   s := ''

   FOR x := 1 To HMG_LEN ( Text )

      c := HB_USUBSTR(Text,x,1)

      IF c='0' .or. c='1' .or. c='2' .or. c='3' .or. c='4' .or. c='5' .or. c='6' .or. c='7' .or. c='8' .or. c='9' .or. c=',' .or. c='-' .or. c = '.'

         IF c == '.'
            c :=''
         ENDIF

         IF C == ','
            C:= '.'
         ENDIF

         s := s + c

      ENDIF

   NEXT x

   IF HB_ULEFT ( ALLTRIM(Text) , 1 ) == '(' .OR.  HB_URIGHT ( ALLTRIM(Text) , 2 ) == 'DB'
      s := '-' + s
   ENDIF

   RETURN Val(s)

   /*

   FUNCTION _HMG_GETGRIDCELLVALUE ( CONTROLNAME , PARENTFORM , ROW , COL )

   LOCAL A
   LOCAL V

   A := _GetItem ( CONTROLNAME , PARENTFORM , ROW  )

   V := A [ COL ]

   RETURN V

   PROCEDURE _HMG_SETGRIDCELLVALUE ( CONTROLNAME , PARENTFORM , ROW , COL , CELLVALUE )

   LOCAL A

   A := _GetItem ( CONTROLNAME , PARENTFORM , ROW  )

   A [ COL ] := CELLVALUE

   _SetItem ( CONTROLNAME , PARENTFORM , ROW , A )

   RETURN
   */

PROCEDURE _HMG_GRIDINPLACEKBDEDIT_2(i)

   LOCAL R
   LOCAL S
   LOCAL aColumnWhen := _HMG_SYSDATA [ 40 ] [ i ] [  6 ]
   LOCAL j
   LOCAL nWhenRow
   LOCAL xTmpCellValue
   LOCAL aTemp
   LOCAL nStart, nEnd, lResult

   //Problem3031

   _HMG_GRID_KBDSCROLL(I)

   IF _HMG_SYSDATA [ 15 ] [i] == 1   // nCol cellnavigation
      // nRow cellnavigation
      r := LISTVIEW_GETITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 39 ] [i] - 1 )
   ELSE
      //   nRow cellnavigation          nCol cellnavigation
      r := LISTVIEW_GETSUBITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 39 ] [i]- 1 , _HMG_SYSDATA [ 15 ] [i] - 1 )
   ENDIF

   nWhenRow := _HMG_SYSDATA [ 195]

   _HMG_SYSDATA [ 197 ] := GetControlSafeRow(i) + r [1]   // This.CellRow
   _HMG_SYSDATA [ 198 ] := GetControlSafeCol(i) + r [2]   // This.CellCol
   _HMG_SYSDATA [ 199 ] := r [3]                   // This.CellWidth
   _HMG_SYSDATA [ 200 ] := r [4]                   // This.CellHeight

   _HMG_SYSDATA [ 194 ] := ascan ( _HMG_SYSDATA [ 67  ] , _HMG_SYSDATA [4][i] )
   _HMG_SYSDATA [ 231 ] := 'C'
   _HMG_SYSDATA [ 203 ] := i
   _HMG_SYSDATA [ 316 ] :=  _HMG_SYSDATA [  66 ] [ _HMG_SYSDATA [ 194 ] ]
   _HMG_SYSDATA [ 317 ] :=  _HMG_SYSDATA [2] [_HMG_SYSDATA [ 203 ]]

   S := _HMG_GRIDINPLACEEDIT(I)

   IF _HMG_SYSDATA [ 32 ] [I] .AND. _HMG_SYSDATA [ 245 ] == .F.

      IF   _HMG_SYSDATA [ 15 ] [I] < HMG_LEN(_HMG_SYSDATA [  7 ] [I])

         IF _HMG_SYSDATA [ 40 ] [ I ] [ 32 ] == 0

            IF S

               IF .NOT. _HMG_SYSDATA [ 285 ]
                  *!!!!
                  IF _HMG_SYSDATA [ 284 ]
                     IF .NOT. _HMG_SYSDATA [ 256 ]
                        InsertDown()
                        InsertReturn()
                     ENDIF
                  ELSE
                     _HMG_SYSDATA [ 15 ] [I]++
                  ENDIF

               ELSE

                  _HMG_SYSDATA [ 15 ] [I]++
                  _HMG_SYSDATA [ 285 ] := .F.
                  InsertReturn()

               ENDIF

               IF ValType ( aColumnWhen ) == 'A'

                  nStart := _HMG_SYSDATA [ 15 ] [I]

                  nEnd := HMG_LEN ( aColumnWhen )

                  FOR j := nStart To nEnd

                     IF ValType ( aColumnWhen [j] ) == 'B'

                        IF _HMG_SYSDATA [ 40 ] [ i ] [ 9 ] == .F.
                           aTemp := this.item( nWhenRow )
                           xTmpCellValue := aTemp [j]
                        ELSE
                           _HMG_SYSDATA [ 201 ] := nWhenRow // QueryRowIndex
                           _HMG_SYSDATA [ 202 ] := j   // QueryColIndex
                           _HMG_SYSDATA [ 320 ] := .T.
                           IF ValType ( _HMG_SYSDATA [ 40 ] [ i ] [ 10 ] ) == 'C'
                              GetDataGridCellData ( i , .t. )
                           ELSE
                              Eval( _HMG_SYSDATA [  6 ] [ i ]  )
                           ENDIF
                           _HMG_SYSDATA [ 320 ] := .F.
                           xTmpCellValue := _HMG_SYSDATA [ 230 ]
                        ENDIF

                        _HMG_SYSDATA [ 318 ] := xTmpCellValue

                        _HMG_SYSDATA [ 232 ] := 'GRID_WHEN'

                        lResult := Eval ( aColumnWhen [j] )

                        _HMG_SYSDATA [ 232 ] := ''

                        IF lResult == .F.

                           _HMG_SYSDATA [ 15 ] [I]++

                        ELSE

                           EXIT

                        ENDIF

                     ENDIF

                  NEXT j

                  IF .NOT. _HMG_SYSDATA [ 284 ]

                     IF _HMG_SYSDATA [ 15 ] [I] > nEnd

                        _HMG_SYSDATA [ 15 ] [I] := nStart - 1

                     ENDIF

                  ENDIF

               ENDIF

            ENDIF

         ENDIF

      ELSEIF _HMG_SYSDATA [ 15 ] [I] == HMG_LEN(_HMG_SYSDATA [  7 ] [I])

         IF _HMG_SYSDATA [ 40 ] [ I ] [ 32 ] == 0

            IF S

               IF .NOT. _HMG_SYSDATA [ 285 ]

                  IF .NOT. _HMG_SYSDATA [ 284 ]
                     _HMG_SYSDATA [ 15 ] [I] := 1
                  ELSE
                     IF .NOT. _HMG_SYSDATA [ 256 ]
                        InsertDown()
                        InsertReturn()
                     ENDIF
                  ENDIF

               ELSE

                  _HMG_SYSDATA [ 15 ] [I] := 1
                  _HMG_SYSDATA [ 285 ] := .F.

               ENDIF

            ENDIF

         ENDIF

      ENDIF

      LISTVIEW_REDRAWITEMS( _HMG_SYSDATA[3][I] , _HMG_SYSDATA[39][I]-1 , _HMG_SYSDATA[39][I]-1 )
      _DoControlEventProcedure ( _HMG_SYSDATA [ 12 ] [i] , i )

   ENDIF

   _HMG_SYSDATA [ 203 ] := 0
   _HMG_SYSDATA [ 231 ] := ''

   _HMG_SYSDATA [ 195 ] := 0
   _HMG_SYSDATA [ 196 ] := 0
   _HMG_SYSDATA [ 197 ] := 0
   _HMG_SYSDATA [ 198 ] := 0
   _HMG_SYSDATA [ 199 ] := 0
   _HMG_SYSDATA [ 200 ] := 0

   _HMG_SYSDATA [ 194 ] := 0
   _HMG_SYSDATA [ 232 ] := ''
   _HMG_SYSDATA [ 316 ] :=  ''
   _HMG_SYSDATA [ 317 ] := ''

   RETURN

PROCEDURE _HMG_GRID_KBDSCROLL(I)

   LOCAL R ,XS , XD

   _HMG_SYSDATA [ 195 ] := _HMG_SYSDATA [ 39 ] [i]
   _HMG_SYSDATA [ 196 ] := _HMG_SYSDATA [ 15 ] [i]

   IF _HMG_SYSDATA [ 15 ] [i] == 1
      r := LISTVIEW_GETITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 39 ] [i] - 1 )
   ELSE
      r := LISTVIEW_GETSUBITEMRECT ( _HMG_SYSDATA [3] [i]  , _HMG_SYSDATA [ 39 ] [i] - 1 , _HMG_SYSDATA [ 15 ] [i] - 1 )
   ENDIF

   xs := ( ( GetControlSafeCol(i) + r [2] ) +( r[3] ))  -  ( GetControlSafeCol(i) + _HMG_SYSDATA [ 20 ] [i] )
   xd := 20

   IF xs > -xd
      ListView_Scroll( _HMG_SYSDATA [3] [i], xs + xd, 0 )
   ELSE
      IF r [2] < 0
         ListView_Scroll( _HMG_SYSDATA [3] [i], r[2], 0 )
      ENDIF
   ENDIF

   RETURN

   //   VIRTUAL GRID DATABASE FUNCTIONS

FUNCTION GridRecCount( cRecordSource )

   LOCAL nCount := 0
   LOCAL nOldRecno := &cRecordSource->( RECNO() )

   &cRecordSource->( DBGOTOP() )
   &cRecordSource->( DBEVAL( {|| nCount++ } ) )   // Dbeval  --> not ignore set delete, preceess only not deleleted records
   &cRecordSource->( DBGOTO( nOldRecno ) )
   // nCount := &cRecordSource->( LASTREC() )        // Lastrec -->     ignore set delete, proceess all records (deleted and non deleted)

   RETURN nCount

FUNCTION GetGridFieldName ( index , nField )

   LOCAL cRecordSource   := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   LOCAL aColumnFields   := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   LOCAL aColumnClassMap := _HMG_SYSDATA [ 40 ] [ index ] [ 30 ]
   LOCAL cFieldName

   IF aColumnClassMap [ nField ] == 'F'
      cFieldName := cRecordSource + '->' + aColumnFields[ nField ]   //  Field in this Area
   ELSE
      cFieldName := aColumnFields[ nField ]   // Field in other Area
   ENDIF

   RETURN cFieldName

FUNCTION IsDataGridMemo ( index , nField )

   LOCAL cFieldName := GetGridFieldName ( index , nField )

   IF TYPE ( cFieldName ) == 'M'

      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION IsDataGridDeleted ( index , nRow )

   LOCAL lRet := .F.
   LOCAL cRecordSource := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   LOCAL nOldRecno := &cRecordSource->( RECNO() )

   &cRecordSource->( ORDKEYGOTO( nRow ) )
   IF &cRecordSource->( DELETED() )
      lRet := .T.
   ENDIF
   &cRecordSource->( DBGOTO( nOldRecno ) )

   RETURN lRet

FUNCTION SetDataGridRecNo ( index , nRecNo  )

   LOCAL cRecordSource
   LOCAL aValue
   LOCAL nLogicalPos := 0
   LOCAL lOk := .f.
   LOCAL nBackRecNo

   cRecordSource  := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   nBackRecNo     := &cRecordSource->( RECNO() )
   aValue         := _GetValue (  ,  ,  index )

   IF ( empty ( &cRecordSource->( DBFILTER() ) ) ) .and. ( .Not. Set ( _SET_DELETED ) ) .and. ( empty ( &cRecordSource->( ORDFOR() ) ) )
      lOk := .t.
      &cRecordSource->( DBGOTO ( nRecNo ) )
      nLogicalPos := &cRecordSource->( ORDKEYNO () )
   ELSE
      lOk := .f.
      nLogicalPos := 1
      &cRecordSource->( DBGOTOP() )

      DO WHILE .Not. EOF()
         IF &cRecordSource->( RECNO() ) == nRecNo
            lOk := .t.
            EXIT
         ENDIF
         &cRecordSource->( DBSKIP() )
         nLogicalPos++
      ENDDO
   ENDIF

   &cRecordSource->( DBGOTO( nBackRecNo ) )

   IF lOk
      _SetValue (  ,  ,  {  nLogicalPos , aValue [2] } , index )
   ENDIF

   RETURN NIL

FUNCTION GetDataGridRecno( index )

   LOCAL cRecordSource := ''
   LOCAL nHandle
   LOCAL aColumnFields := {}
   LOCAL lRet := .T.
   LOCAL aValue
   LOCAL nRecNo
   LOCAL nBackRecNo

   LOCAL aTemp
   LOCAL nBuffLogicalRow
   LOCAL nBuffPhysicalRow
   LOCAL k

   nHandle        := _HMG_SYSDATA [  3 ] [ index ]
   aColumnFields  := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   cRecordSource  := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   nBackRecNo     := &cRecordSource->( RECNO() )
   aValue         := _GetValue (  ,  ,  index )

   IF (( empty ( &cRecordSource->( DBFILTER() ) ) ) .and. ( .Not. SET( _SET_DELETED ) ))
      &cRecordSource->( ORDKEYGOTO ( aValue[1] ) )
   ELSE
      &cRecordSource->( DBGOTOP() )
      &cRecordSource->( DBSKIP( aValue[1] - 1 ) )
   ENDIF

   IF &cRecordSource->(EOF())
      nRecNo := 0
      // Try to get the buffer record number (if available)
      aTemp := _HMG_SYSDATA [ 40 ] [ index ] [21]
      FOR k := 1 To HMG_LEN ( aTemp )
         // Get Buffer Data
         nBuffLogicalRow  := aTemp [ k ] [ 1 ]
         nBuffPhysicalRow := aTemp [ k ] [ 4 ]
         IF nBuffLogicalRow == _HMG_SYSDATA [ 39 ] [ index ]
            nRecNo := nBuffPhysicalRow
            EXIT
         ENDIF
      NEXT
   ELSE
      nRecNo := &cRecordSource->( RECNO() )
   ENDIF

   &cRecordSource->( DBGOTO( nBackRecNo ) )

   RETURN nRecNo

FUNCTION DataGridDelete ( index )

   LOCAL cOperation
   LOCAL nLogicalRow
   LOCAL nPhysicalRow
   LOCAL x

   // Set Operation Type
   cOperation := 'D'

   // Get Logical Row
   nLogicalRow := _HMG_SYSDATA [ 39 ] [index]

   // Get Physical Row
   nPhysicalRow := GetDataGridRecNo(index)

   // Process Double-Deleted/Recalled
   FOR x := 1 To _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]
      IF _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ x ] [ 1 ] == nLogicalRow
         _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ x ] [ 3 ] := 'D'

         RETURN .T.
      ENDIF
   NEXT

   // Not Double Deleted/Recalled *********************************************

   // Append Record To Deleted / Recalled Buffer
   aadd ( _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] , { nLogicalRow , nPhysicalRow , cOperation } )

   // Update Deleted / Recalled Buffer Count
   _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]++

   // Set Pending Updates Flag
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .T.

   RETURN .T.

FUNCTION DataGridRecall ( index )

   LOCAL cOperation
   LOCAL nLogicalRow
   LOCAL nPhysicalRow
   LOCAL x

   // Set Operation Type
   cOperation := 'R'

   // Get Logical Row
   nLogicalRow := _HMG_SYSDATA [ 39 ] [index]

   // Get Physical Row
   nPhysicalRow := GetDataGridRecNo(index)

   // Process Double-Deleted/Recalled
   FOR x := 1 To _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]
      IF _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ x ] [ 1 ] == nLogicalRow
         _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ x ] [ 3 ] := 'R'

         RETURN .T.
      ENDIF
   NEXT

   // Not Double Deleted/Recalled *******************************************

   // Append Record To Deleted / Recalled Buffer
   aadd ( _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] , { nLogicalRow , nPhysicalRow , cOperation } )

   // Update Deleted / Recalled Buffer Count
   _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]++

   // Set Pending Updates Flag
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .T.

   RETURN .T.

   /*

   Function IsDataGridFiltered ( index )

   Local cRecordSource, lRet, nRecNo

   cRecordSource := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   if ( .not. empty ( &cRecordSource->( dbFilter() ) ) ) .or. Set ( _SET_DELETED ) .or. ( .not. empty ( &cRecordSource->( OrdFor( indexord() ) ) ) )
   lRet := .t.
   else
   lRet := .f.
   endif

   Return lRet
   */

FUNCTION SaveDataGridField ( index , Value )

   LOCAL nLogicalRow
   LOCAL nLogicalCol
   LOCAL lReEdit := .F.
   LOCAL aTemp := {}
   LOCAL nBufferRow
   LOCAL x, nRecNo

   // Get Logical Position
   nLogicalRow := _HMG_SYSDATA [ 39 ] [index]
   nLogicalCol := _HMG_SYSDATA [ 15 ] [index]

   // Get Selected Row Record Number
   nRecNo := GetDataGridRecNo(index)

   // New Buffered Record Without a True RecNo
   IF nRecNo == 0
      nRecNo := _HMG_SYSDATA [ 40 ] [ index ] [ 23 ] - nLogicalRow
   ENDIF

   // Is re-edit of the same cell ?
   IF _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] == .T.
      aTemp := _HMG_SYSDATA [ 40 ] [ index ] [21]
      FOR x := 1 To HMG_LEN ( aTemp )
         IF aTemp [ x ] [ 1 ] == nLogicalRow
            IF aTemp [ x ] [ 2 ] == nLogicalCol
               lReEdit := .T.
               nBufferRow := x
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF

   // Add Data to Pending Updates Buffer
   IF lReEdit
      _HMG_SYSDATA [ 40 ] [ index ] [21] [ nBufferRow ] := { nLogicalRow , nLogicalCol , Value , nRecNo }
   ELSE
      aadd ( _HMG_SYSDATA [ 40 ] [ index ] [21] , { nLogicalRow , nLogicalCol , Value , nRecNo } )
   ENDIF

   // Set Pending Updates Flag
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .T.

   RETURN .T.

FUNCTION DataGridAppend( index )

   LOCAL cRecordSource := ''
   LOCAL nItemCount
   LOCAL nHandle
   LOCAL aColumnFields := {}
   LOCAL lRet := .T.
   LOCAL j

   // Get Control Data
   nHandle        := _HMG_SYSDATA [  3 ] [ index ]
   aColumnFields  := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   cRecordSource  := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   nItemCount     := ListView_GetItemCount ( nHandle )

   // Append a Row To The Grid
   ListView_SetItemCount ( nHandle , 0 )
   ListView_SetItemCount ( nHandle , nItemCount + 1 )

   &cRecordSource->( DBGOTOP() )
   &cRecordSource->( DBGOBOTTOM() )

   nItemCount := ListView_GetItemCount ( nHandle )
   _SetValue ( , , { nItemCount , 1 } , index )

   // Update New Record Buffer Count (Negative)
   _HMG_SYSDATA [ 40 ] [ index ] [ 22 ]--

   // Set Default Values For The New Record
   FOR j := 1 to HMG_LEN ( _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] )
      IF type ( aColumnFields [j] ) == 'C'
         _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] := ''
      ELSEIF type ( aColumnFields [j] ) == 'N'
         _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] := 0
      ELSEIF   type ( aColumnFields [j] ) == 'D'
         _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] := ctod('  /  /  ')
      ELSEIF   type ( aColumnFields [j] ) == 'L'
         _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] := .F.
      ELSEIF   type ( aColumnFields [j] ) == 'M'
         _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] := '<Memo>'
      ENDIF
      aadd ( _HMG_SYSDATA [ 40 ] [ index ] [21] , { nItemCount , j , _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [j] , _HMG_SYSDATA [ 40 ] [ index ] [ 22 ] } )
   NEXT

   // Set Pending Updates Flag
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .T.

   RETURN lRet

FUNCTION DataGridSave(index)

   LOCAL x
   LOCAL z
   LOCAL n
   LOCAL l
   LOCAL j
   LOCAL k
   LOCAL aTemp
   LOCAL g
   LOCAL h
   LOCAL aAppendBuffer
   LOCAL aEditBuffer
   LOCAL aMarkBuffer
   LOCAL nColumnCount
   LOCAL nAppendRecordCount
   LOCAL aRecord
   LOCAL aColumnClassMap
   LOCAL cRecordSource, aColumnFields, nHandle, nItemCount, nRecNo, nLogicalRow, nLogicalCol, xValue, nPhysicalRow, cCommand

   // If Not Buffered Data Then Return ************************************
   IF _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] == .F.

      RETURN .F.
   ENDIF

   // Get Control Data ****************************************************
   nHandle           := _HMG_SYSDATA [  3 ] [ index ]
   cRecordSource     := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   aColumnFields     := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   aColumnClassMap   := _HMG_SYSDATA [ 40 ] [ index ] [ 30 ]
   nItemCount        := ListView_GetItemCount ( nHandle )

   // Backup Record Number ************************************************
   nRecNo := &cRecordSource->( RECNO() )

   // If OnSave Specified, Process It And Exit ****************************
   IF ValType ( _HMG_SYSDATA [ 40 ] [ index ] [ 26 ] ) == 'B'

      // Create User Buffer Arrays From Internal Ones ****************
      aAppendBuffer  := {}
      aEditBuffer    := {}
      aMarkBuffer    := _HMG_SYSDATA [ 40 ] [ index ] [ 25 ]
      aTemp := _HMG_SYSDATA [ 40 ] [ index ] [ 21 ] // Internal Buffer

      nColumnCount := HMG_LEN ( aColumnFields )
      nAppendRecordCount := _HMG_SYSDATA [ 40 ] [ index ] [ 22 ]

      // Create User Append Buffer ***********************************
      FOR h := -1 To nAppendRecordCount Step -1
         aRecord := array ( nColumnCount )
         FOR g := 1 To HMG_LEN ( aTemp )
            IF aTemp [ g ] [ 4 ] == h
               aRecord [ aTemp [ g ] [ 2 ] ] := aTemp [ g ] [ 3 ]
            ENDIF
         NEXT
         aadd ( aAppendBuffer , aRecord )
      NEXT

      // Create User Edit Buffer *******************************************
      FOR g := 1 To HMG_LEN ( aTemp )
         h := aTemp [ g ] [ 4 ]
         IF h > 0
            aadd ( aEditBuffer , aTemp [ g ] )
         ENDIF
      NEXT

      // Set This.*Buffer Properties
      _HMG_SYSDATA [ 278 ] := aClone ( aEditBuffer )
      _HMG_SYSDATA [ 279 ] := aClone ( aMarkBuffer )
      _HMG_SYSDATA [ 280 ] := aClone ( aAppendBuffer )

      // Execute It!
      Eval ( _HMG_SYSDATA [ 40 ] [ index ] [ 26 ] )

      // Cleanup ********************************************

      // Set Pending Updates Flag
      _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .F.

      // Clean Data Buffer
      _HMG_SYSDATA [ 40 ] [ index ] [21] := {}

      // Update New Records Buffer Count
      _HMG_SYSDATA [ 40 ] [ index ] [ 22 ] := 0

      // Reset Buffered Session Initial Item Count
      _HMG_SYSDATA [ 40 ] [ index ] [ 23 ] := GridRecCount( cRecordSource )

      // Reset Deleted / Recalled Buffer Count
      _HMG_SYSDATA [ 40 ] [ index ] [ 24 ] :=  0

      // Reset Deleted / Recalled Buffer
      _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] := {}

      // Refresh
      DataGridRefresh(index)

      // The End

      RETURN .T.

   ENDIF

   // RDD DEPENDANT CODE

   IF &cRecordSource->( RddName() ) == 'SQLMIX'
      MsgHMGError("GRID: Modify SQLMIX RDD tables are not allowed. Program terminated" )
   ELSEIF   &cRecordSource->(RddName()) == 'PGRDD'
      MsgHMGError("GRID: Modify PostGre RDD tables are not allowed. Program terminated" )
   ELSE
      _HMG_SYSDATA [ 347 ] := .F.   // Grid Automatic Update

      // Process Existing Records *************************************************
      aTemp := _HMG_SYSDATA [ 40 ] [ index ] [ 21 ]
      FOR x := 1 To HMG_LEN ( aTemp )

         // Get Buffer Data
         nLogicalRow    := aTemp [ x ] [ 1 ]
         nLogicalCol    := aTemp [ x ] [ 2 ]
         xValue         := aTemp [ x ] [ 3 ]
         nPhysicalRow   := aTemp [ x ] [ 4 ]

         // Position in Physical Row ..............
         IF nPhysicalRow > 0
            &cRecordSource->( DBGOTO( nPhysicalRow ) )

            // Attempt To Lock To Save ....................................
            IF RLOCK() == .F.
               MsgExclamation(_HMG_SYSDATA [ 136 ][9],_HMG_SYSDATA [ 136 ][10])
               &cRecordSource->( DBGOTO( nRecNo ) )

               RETURN .f.
            ENDIF

            // Save Data ..................................................
            IF aColumnClassMap[ nLogicalCol ] == 'F'
               &cRecordSource->&( aColumnFields[ nLogicalCol ] ) := xValue
            ELSE
               &( aColumnFields[ nLogicalCol ] ) := xValue
            ENDIF

            // Unlock .....................................................
            &cRecordSource->( DBRUNLOCK( &cRecordSource->( RECNO() ) ) )
         ENDIF
      NEXT x

      // Process New Records ************************************************
      l := HMG_LEN(aTemp)
      FOR z := 1 To l
         IF aTemp [ z ] [ 4 ] < 0
            // If the new record is marked as 'Deleted' do not append.
            IF ! IsBufferedRecordMarkedForDeletion( index , aTemp [ z ] [ 4 ] )
               &cRecordSource->( DBAPPEND() )
               n := aTemp [ z ] [ 4 ]
               FOR j := 1 To l
                  IF aTemp [j] [4] == n
                     // Attempt To Lock To Save .............
                     IF RLOCK() == .F.
                        MsgExclamation(_HMG_SYSDATA [ 136 ][9],_HMG_SYSDATA [ 136 ][10])
                        &cRecordSource->( DBGOTO( nRecNo ) )

                        RETURN .f.
                     ENDIF

                     // Save Data ...........................
                     IF aColumnClassMap[ aTemp [j] [2] ] == 'F'
                        &cRecordSource->&( aColumnFields[ aTemp [j] [2] ] ) := aTemp [j] [3]
                     ELSE
                        &( aColumnFields[ aTemp [j] [2] ] ) := aTemp [j] [3]   // Add, May 2016
                     ENDIF

                     // Unlock ..............................
                     &cRecordSource->( DBRUNLOCK( &cRecordSource->( RECNO() ) ) )

                     // CleanUp .............................
                     aTemp [j] [1] := 0
                     aTemp [j] [2] := 0
                     aTemp [j] [3] := Nil
                     aTemp [j] [4] := 0
                  ENDIF
               NEXT j
            ENDIF
         ENDIF
      NEXT z

      // Precess Delete / ReCall Commands ****************************
      FOR k := 1 To _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]

         // Get Row And Command
         nPhysicalRow := _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ k ] [ 2 ]
         cCommand := _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ k ] [ 3 ]

         // Position On The Record To Process
         &cRecordSource->( DBGOTO( nPhysicalRow ) )

         // Lock Record
         IF RLOCK() == .F.
            MsgExclamation(_HMG_SYSDATA [ 136 ][9],_HMG_SYSDATA [ 136 ][10])

            RETURN .f.
         ENDIF

         // Excute Command **************************************
         IF cCommand == 'D'
            &cRecordSource->( DBDELETE() )
         ELSEIF cCommand == 'R'
            &cRecordSource->( DBRECALL() )
         ENDIF

         // Unlock **********************************************
         &cRecordSource->( DBRUNLOCK( &cRecordSource->( RECNO() ) ) )
      NEXT

      _HMG_SYSDATA [347] := .T.   // Grid Automatic Update

   ENDIF

   // END RDD DEPENDANT CODE

   // Cleanup ********************************************

   // Restore Original Record Number **************************************
   &cRecordSource->( DBGOTO( nRecNo ) )

   // Set Pending Updates Flag ********************************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .F.

   // Clean Data Buffer ***************************************************
   _HMG_SYSDATA [ 40 ] [ index ] [21] := {}

   // Update New Records Buffer Count *************************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 22 ] := 0

   // Reset Buffered Session Initial Item Count
   _HMG_SYSDATA [ 40 ] [ index ] [ 23 ] := GridRecCount( cRecordSource )

   // Reset Deleted / Recalled Buffer Count
   _HMG_SYSDATA [ 40 ] [ index ] [ 24 ] :=  0

   // Reset Deleted / Recalled Buffer
   _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] := {}

   // Refresh
   DataGridRefresh(index)

   RETURN .t.

FUNCTION IsBufferedRecordMarkedForDeletion( index , nPhysicalRow )

   LOCAL lRetVal := .F.
   LOCAL k, cCommand

   FOR k := 1 To _HMG_SYSDATA [ 40 ] [ index ] [ 24 ]
      cCommand := _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ k ] [ 3 ]
      IF cCommand == 'D'
         IF nPhysicalRow == _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] [ k ] [ 2 ]
            lRetVal := .T.
            EXIT
         ENDIF
      ENDIF
   NEXT

   RETURN lRetVal

FUNCTION DataGridRefresh( index , lPreserveSelection )

   LOCAL cRecordSource
   LOCAL nHandle
   LOCAL aValue

   DEFAULT lPreserveSelection TO .F.

   // Get Control Data ****************************************************
   nHandle       := _HMG_SYSDATA [  3 ] [ index ]
   cRecordSource := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   IF ValType ( cRecordSource ) <> 'C'

      RETURN .F.   // Not Grid with cRecordSource ( DataBase )
   ENDIF

   IF lPreserveSelection
      aValue := _GetValue ( , , index )
   ENDIF

   // Reset Cell Position Data ********************************************
   _HMG_SYSDATA [ 39 ] [ index ] := 0
   _HMG_SYSDATA [ 15 ] [ index ] := 0

   // Set New ItemCount ***************************************************
   // ListView_SetItemCount ( nHandle , 0 )
   ListView_SetItemCount ( nHandle , GridRecCount( cRecordSource ) )

   // ReSet Selected Row **************************************************
   IF lPreserveSelection
      _SetValue (  ,  , aValue , index )
   ELSE
      _SetValue (  ,  , {1,1} , index )
   ENDIF

   //   RedrawWindow( nHandle )

   RETURN .t.

FUNCTION DataGridClearBuffer(index)

   LOCAL cRecordSource, nHandle

   // Get Control Data ****************************************************
   nHandle        := _HMG_SYSDATA [  3 ] [ index ]
   cRecordSource  := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]

   // Set Pending Updates Flag ********************************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] := .F.

   // Clean Data Buffer ***************************************************
   _HMG_SYSDATA [ 40 ] [ index ] [21] := {}

   // Update New Records Buffer Count *************************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 22 ] := 0

   // Reset Deleted / Recalled Buffer Count *******************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 24 ] :=  0

   // Reset Deleted / Recalled Buffer *************************************
   _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] := {}

   // Refresh *************************************************************
   DataGridRefresh(index)

   RETURN .t.

PROCEDURE GetDataGridCellData ( index , lTrueData )

   STATIC nLastLogicalRecord := 0
   STATIC nLastHandle := 0
   LOCAL x, aTemp
   LOCAL cRecordSource
   LOCAL aColumnFields
   LOCAL xBufferedCellValue
   LOCAL lBufferedCell := .F.

   IF _HMG_SYSDATA [ 347 ] == .F.   // Grid Automatic Update

      RETURN
   ENDIF

   IF _HMG_SYSDATA [ 40 ] [ index ] [ 33 ] == .F.  // ENABLEUPDATE = .T. | DISABLEUPDATE = .F.

      RETURN
   ENDIF

   cRecordSource     := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   aColumnFields     := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]

   // Update Physical Record position
   IF nLasthandle <> _HMG_SYSDATA [3] [ Index ] .OR. nLastLogicalRecord <> This.QueryRowIndex .OR. ListView_GetItemCount( _HMG_SYSDATA [3] [ Index ] ) == 1
      nLasthandle := _HMG_SYSDATA [3] [ Index ]
      nLastLogicalRecord := This.QueryRowIndex
      GridSetPhysicalRecord( index, This.QueryRowIndex )
   ENDIF

   // Determine If The Required Cell Is Buffered
   IF _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] == .T.  // Pending Edit Updates Flag
      aTemp := _HMG_SYSDATA [ 40 ] [ index ] [ 21 ]   // { nLogicalRow , nLogicalCol , xValue , nRecNo }
      lBufferedCell := .F.
      FOR x := 1 TO HMG_LEN ( aTemp )
         IF  aTemp [ x ] [ 1 ] == This.QueryRowIndex .and. aTemp [ x ] [ 2 ] == This.QueryColIndex
            lBufferedCell := .T.
            xBufferedCellValue := aTemp [ x ] [ 3 ]
            EXIT
         ENDIF
      NEXT
   ENDIF

   // This started like a nice and compact piece of code, but it is becoming terribly complicated now
   IF IsDataGridMemo( index , This.QueryColIndex ) == .T.
      IF lTrueData
         This.QueryData := iif( lBufferedCell == .T., xBufferedCellValue, GetFiledData( index , This.QueryColIndex ) )
      ELSE
         This.QueryData := '<Memo>'
      ENDIF
   ELSE
      IF lTrueData
         This.QueryData := iif( lBufferedCell == .T., xBufferedCellValue, GetFiledData( index , This.QueryColIndex ) )
      ELSE
         IF ValType ( _HMG_SYSDATA [ 40 ] [ index ] [ 18 ] ) = 'A' // DynamicDisplay
            This.CellRowIndex := This.QueryRowIndex
            This.CellColIndex := This.QueryColIndex
            This.CellValue := iif( lBufferedCell == .T., xBufferedCellValue, GetFiledData( index , This.QueryColIndex ) )
            This.QueryData := EVAL ( _HMG_SYSDATA [ 40 ] [ index ] [ 18 ] [ This.QueryColIndex ] )   // Eval DynamicDisplay CodeBlock
         ELSE
            This.QueryData := iif( lBufferedCell == .T., xBufferedCellValue, GetFiledData( index , This.QueryColIndex ) )
         ENDIF
      ENDIF
   ENDIF

   RETURN

FUNCTION GetFiledData ( index, nField )   // ADD May 2016

   LOCAL cRecordSource   := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   LOCAL aColumnFields   := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   LOCAL aColumnClassMap := _HMG_SYSDATA [ 40 ] [ index ] [ 30 ]
   LOCAL xData

   IF aColumnClassMap [ nField ] == 'F'
      // xData := &cRecordSource->( FIELDGET( &cRecordSource->( FIELDPOS( aColumnFields[ nField ] ) ) ) )
      xData := &cRecordSource->&( aColumnFields[ nField ] )   //  Field in this Area
   ELSE
      xData := &( aColumnFields[ nField ] )   // Field in other Area
   ENDIF

   RETURN xData

FUNCTION GridSetPhysicalRecord( index, nLogicalRecno )   // ADD May 2016

   LOCAL cRecordSource   := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   LOCAL nPhysicalRecord := 0
   LOCAL nLogicalRecord  := 0
   LOCAL nOldWorkArea

   IF SET ( _SET_DELETED )
      /*
      &cRecordSource->( DBGOTOP() )
      WHILE .NOT. &cRecordSource->( EOF() )
      IF &cRecordSource->( DELETED() ) == .F.
      nLogicalRecord ++
      IF nLogicalRecord == nLogicalRecno
      nPhysicalRecord := &cRecordSource->( RECNO() )
      EXIT
      ENDIF
      ENDIF
      &cRecordSource->( DBSKIP() )
      ENDDO
      */
      nOldWorkArea := SELECT()
      SELECT( cRecordSource )
      DBGOTOP()
      // if Set Delete is On, dbeval() not process deleted records
      DBEVAL( {|| nLogicalRecord++, nPhysicalRecord := RECNO() }, NIL, {|| nLogicalRecord <> nLogicalRecno } )
      DBGOTO( nPhysicalRecord )
      SELECT( nOldWorkArea )
   ELSE
      nLogicalRecord := nLogicalRecno
      &cRecordSource->( ORDKEYGOTO( nLogicalRecord ) )
      nPhysicalRecord := &cRecordSource->( RECNO() )
   ENDIF

   RETURN nPhysicalRecord

   /*

   Procedure GetDataGridCellData ( index , lTrueData )

   Local nDelta
   Local aTemp
   Local nLength
   Local lBufferedCell := .F.
   Local lBufferedDeletedRow := .F.
   Local lBufferedRecalledRow := .F.
   Local cRecordSource := ''
   Local aColumnFields := {}
   Local aColumnClassMap := {}

   Local xBufferedCellValue, x

   Static nPrevPhysicalRecord := 0
   Static nPrevLogicalRecord := 1
   Static nLastHandle := 0

   IF _HMG_SYSDATA [ 347 ] == .F.   // Grid Automatic Update

   RETURN
   ENDIF

   IF _HMG_SYSDATA [ 40 ] [ index ] [ 33 ] == .F.  // ENABLEUPDATE = .T. | DISABLEUPDATE = .F.

   RETURN
   ENDIF

   cRecordSource     := _HMG_SYSDATA [ 40 ] [ index ] [ 10 ]
   aColumnFields     := _HMG_SYSDATA [ 40 ] [ index ] [ 11 ]
   aColumnClassMap   := _HMG_SYSDATA [ 40 ] [ index ] [ 30 ]

   If nLasthandle == _HMG_SYSDATA [3] [ Index ]

   // If record pointer was moved externally it must be adjusted to avoid terrible things to happen :)
   if nPrevPhysicalRecord != &cRecordSource->( recno() )
   if nPrevPhysicalRecord != 0
   &cRecordSource->( dbGoTo( nPrevPhysicalRecord ) )
   endif
   endif

   // Trick to do less calls to OrdKeyGoTo()
   nDelta := This.QueryRowIndex - nPrevLogicalRecord
   if nDelta != 0
   if abs ( nDelta ) < _HMG_SYSDATA [ 40 ] [ index ] [ 27 ]
   &cRecordSource->( DBSKIP( nDelta) )
   else
   &cRecordSource->( OrdKeyGoTo( This.QueryRowIndex ) )
   endif
   nPrevLogicalRecord := This.QueryRowIndex
   nPrevPhysicalRecord := &cRecordSource->( Recno() )
   endif

   Else

   nLasthandle := _HMG_SYSDATA [ 3 ] [ Index ]
   &cRecordSource->( OrdKeyGoTo( This.QueryRowIndex ) )
   nPrevLogicalRecord  := This.QueryRowIndex
   nPrevPhysicalRecord := &cRecordSource->( Recno() )

   EndIf

   // Determine If The Required Cell Is Buffered
   IF _HMG_SYSDATA [ 40 ] [ index ] [ 20 ] == .T.
   aTemp         := _HMG_SYSDATA [ 40 ] [ index ] [21]
   nLength       := HMG_LEN ( aTemp )
   lBufferedCell := .F.

   FOR X := 1 TO nLength
   IF  aTemp [ x ] [ 1 ] == This.QueryRowIndex .and. aTemp [ x ] [ 2 ] == This.QueryColIndex
   lBufferedCell := .T.
   xBufferedCellValue := aTemp [ x ] [ 3 ]
   Exit
   ENDIF
   NEXT

   // Process Deleted Rows
   aTemp   := _HMG_SYSDATA [ 40 ] [ index ] [ 25 ] // Delete / Recall Buffer Array { nLogicalRow , nPhysicalRow , cStatus ( 'D' or 'R' ) }
   nLength := _HMG_SYSDATA [ 40 ] [ index ] [ 24 ] // Deleted / Recalled record count

   lBufferedDeletedRow := .F.
   lBufferedRecalledRow := .F.
   For x := 1 To nLength
   IF aTemp [ x ] [ 1 ] == This.QueryRowIndex .and. aTemp [ x ] [ 3 ] == 'D'
   lBufferedDeletedRow := .T.
   Exit
   EndIf
   IF  aTemp [ x ] [ 1 ] == This.QueryRowIndex .and. aTemp [ x ] [ 3 ] == 'R'
   lBufferedRecalledRow := .T.
   Exit
   EndIf
   Next
   ENDIF

   // This started like a nice and compact piece of code, but it is becoming terribly complicated now
   if Type ( cRecordSource + '->' + aColumnFields[ This.QueryColIndex ] ) == 'M'
   If lTrueData
   If lBufferedCell
   This.QueryData := xBufferedCellValue
   else
   This.QueryData := GetFiledData( index , This.QueryColIndex )
   endif
   else
   This.QueryData := '<Memo>'
   EndIf
   else
   If lTrueData
   If lBufferedCell
   This.QueryData := xBufferedCellValue
   Else
   This.QueryData := GetFiledData( index , This.QueryColIndex )
   EndIf
   else
   If ValType ( _HMG_SYSDATA [ 40 ] [ index ] [ 18 ] ) = 'A' // DynamicDisplay
   _HMG_SYSDATA [ 195 ] := This.QueryRowIndex
   _HMG_SYSDATA [ 196 ] := This.QueryColIndex
   IF _HMG_SYSDATA [ 40 ] [ index ] [ 15 ] == .T. .AND. _HMG_SYSDATA [ 40 ] [ index ] [ 14 ] == .T.
   IF This.QueryRowIndex == ListView_GetItemCount( _HMG_SYSDATA [3] [ index ] )
   This.CellValue := _HMG_SYSDATA [ 40 ] [ index ] [ 13 ] [ This.QueryColIndex ]
   ELSE
   If lBufferedCell
   This.CellValue := xBufferedCellValue
   Else
   This.CellValue := GetFiledData( index , This.QueryColIndex )
   EndIf
   ENDIF
   ELSE
   If lBufferedCell
   This.CellValue := xBufferedCellValue
   Else
   This.CellValue := GetFiledData( index , This.QueryColIndex )
   EndIf
   ENDIF
   This.QueryData := EVAL ( _HMG_SYSDATA [ 40 ] [ index ] [ 18 ] [ This.QueryColIndex ] )   // Eval DynamicDisplay CodeBlock
   Else
   If lBufferedCell
   This.QueryData := xBufferedCellValue
   Else
   This.QueryData := GetFiledData( index , This.QueryColIndex )
   EndIf
   EndIf
   Endif
   Endif

   Return
   */
