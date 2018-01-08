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

#include 'hmg.ch'
#define SB_CTL          2  // ok
#define CB_SHOWDROPDOWN 335  // ok
MEMVAR aresult

#include "SETCompileBrowse.ch"
#ifdef COMPILEBROWSE

FUNCTION _DefineBrowse ( ControlName, ;
      ParentForm, ;
      x, ;
      y, ;
      w, ;
      h, ;
      aHeaders, ;
      aWidths, ;
      aFields , ;
      value, ;
      fontname, ;
      FONTSIZE , ;
      TOOLTIP , ;
      change , ;
      dblclick , ;
      aHeadClick , ;
      gotfocus , ;
      lostfocus , ;
      WORKAREA , ;
      DELETE, ;
      nogrid, ;
      aImage, ;
      aJust , ;
      HelpId , ;
      bold , ;
      italic , ;
      underline , ;
      strikeout , ;
      break , ;
      BACKCOLOR , ;
      FONTCOLOR , ;
      lock , ;
      inplace , ;
      novscroll , ;
      APPENDable , ;
      READonly , ;
      valid , ;
      validmessages , ;
      edit , ;
      DYNAMICBACKCOLOR , ;
      aWhenFields , ;
      DYNAMICforecolor , ;
      INPUTMASK , ;
      format , ;
      inputitems , displayitems , aHeaderImages, ;
      NoTrans, NoTransHeader)
   LOCAL i , cParentForm , mVar , ix, wBitmap , z , ScrollBarHandle , DeltaWidth , k := 0
   LOCAL cParentTabName

   LOCAL ControlHandle
   LOCAL FontHandle
   LOCAL hsum := 0
   LOCAL ScrollBarButtonHandle
   LOCAL nHeaderImageListHandle

   InPlace := .T.

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
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   ix := GetFormIndex (ParentForm)

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm = ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF valtype(w) == "U"
      w := 240
   ENDIF
   IF valtype(h) == "U"
      h := 120
   ENDIF
   IF valtype(value) == "U"
      VALUE := 0
   ENDIF
   IF valtype(aFields) == "U"
      aFields := {}
   ENDIF
   IF valtype(aJust) == "U"      // Browse+
      aJust := Array( HMG_LEN( aFields ) )
      aFill( aJust, 0 )
   ELSE
      aSize( aJust, HMG_LEN( aFields) )
      aEval( aJust, { |x| x := iif( x == NIL, 0, x ) } )
   ENDIF
   IF valtype(aImage) == "U"
      aImage := {}
   ENDIF

   // If splitboxed force no vertical scrollbar

   IF valtype(x) == "U" .or. valtype(y) == "U"
      novscroll := .T.
   ENDIF

   IF novscroll == .F.
      DeltaWidth := GETVSCROLLBARWIDTH()
   ELSE
      DeltaWidth := 0
   ENDIF

   IF valtype(x) == "U" .or. valtype(y) == "U"

      IF _HMG_SYSDATA [ 216 ] == 'TOOLBAR'
         Break := .T.
      ENDIF

      _HMG_SYSDATA [ 216 ]   := 'GRID'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         ControlHandle := InitBrowse ( ParentForm, 0, x, y, w - DeltaWidth , h , '', 0, iif( nogrid, 0, 1 ) ) // Browse+

         x := GetWindowCol ( Controlhandle )
         y := GetWindowRow ( Controlhandle )

         IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle, _HMG_SYSDATA [ 87 ] [i] , w , break , , , , _HMG_SYSDATA [ 258 ] )
      ENDIF

   ELSE

      ControlHandle := InitBrowse ( ParentForm, 0, x, y, w - DeltaWidth , h , '', 0, iif( nogrid, 0, 1 ) ) // Browse+

      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
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

   wBitmap := iif( HMG_LEN( aImage ) > 0, AddListViewBitmap( ControlHandle, aImage, NoTrans ), 0 ) //Add Bitmap Column
   aWidths[1] := max ( aWidths[1], wBitmap + 2 ) // Set Column 1 witth to Bitmap width

   IF valtype(aHeadClick) == "U"
      aHeadClick := {}
   ENDIF

   IF valtype(change) == "U"
      change := ""
   ENDIF

   IF valtype(dblclick) == "U"
      dblclick := ""
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [  1 ] [k] := "BROWSE"
   _HMG_SYSDATA [  2 ] [k] := ControlName
   _HMG_SYSDATA [  3 ] [k] := ControlHandle
   _HMG_SYSDATA [  4 ] [k] := ParentForm
   _HMG_SYSDATA [  5 ] [k] := 0
   _HMG_SYSDATA [  6 ] [k] := aWidths
   _HMG_SYSDATA [  7 ] [k] := aHeaders
   _HMG_SYSDATA [  8 ] [k] := Value
   _HMG_SYSDATA [  9 ] [k] := Lock
   _HMG_SYSDATA [ 10 ] [k] := lostfocus
   _HMG_SYSDATA [ 11 ] [k] := gotfocus
   _HMG_SYSDATA [ 12 ] [k] := change
   _HMG_SYSDATA [ 13 ] [k] := .F.
   _HMG_SYSDATA [ 14 ] [k] := aImage // Browse+
   _HMG_SYSDATA [ 15 ] [k] := inplace
   _HMG_SYSDATA [ 16 ] [k] := dblclick
   _HMG_SYSDATA [ 17 ] [k] := aHeadClick
   _HMG_SYSDATA [ 18 ] [k] := y
   _HMG_SYSDATA [ 19 ] [k] := x
   _HMG_SYSDATA [ 20 ] [k] := w
   _HMG_SYSDATA [ 21 ] [k] := h
   _HMG_SYSDATA [ 22 ] [k] := WorkArea
   _HMG_SYSDATA [ 23 ] [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ] [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ] [k] := Delete
   _HMG_SYSDATA [ 26 ] [k] := 0
   _HMG_SYSDATA [ 27 ] [k] := fontname
   _HMG_SYSDATA [ 28 ] [k] := fontsize
   _HMG_SYSDATA [ 29 ] [k] := {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ] [k] := tooltip
   _HMG_SYSDATA [ 31 ] [k] := aFields
   _HMG_SYSDATA [ 32 ] [k] := {}
   _HMG_SYSDATA [ 33 ] [k] := aHeaders
   _HMG_SYSDATA [ 34 ] [k] := .t.
   _HMG_SYSDATA [ 35 ] [k] := HelpId
   _HMG_SYSDATA [ 36 ] [k] := FontHandle
   _HMG_SYSDATA [ 37 ] [k] := cParentTabName
   _HMG_SYSDATA [ 38 ] [k] := .T.
   _HMG_SYSDATA [ 39 ] [k] := { 0 , appendable , readonly , valid , validmessages , edit , inputitems , displayitems , Nil , Nil , Nil }
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   InitListViewColumns ( ControlHandle , aHeaders , aWidths, aJust ) // Browse+

   // Add to browselist array to update on window activation

   i := k
   aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , k )

   FOR z := 1 To HMG_LEN ( _HMG_SYSDATA [  6 ] [i] )
      hsum := hsum + ListView_GetColumnWidth ( _HMG_SYSDATA [3] [i] , z - 1 )
      _HMG_SYSDATA [  6 ] [i] [z] := ListView_GetColumnWidth ( _HMG_SYSDATA [3] [i] , z - 1 )
   NEXT z

   // Add Vertical scrollbar

   IF novscroll == .F.

      IF hsum > w - GETVSCROLLBARWIDTH() - 4
         ScrollBarHandle := InitVScrollBar (  ParentForm , x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h - GETHSCROLLBARHEIGHT() )
         ScrollBarButtonHandle := InitVScrollBarButton (  ParentForm , x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , GETVSCROLLBARWIDTH() , GETHSCROLLBARHEIGHT() )
      ELSE
         ScrollBarHandle := InitVScrollBar (  ParentForm , x + w - GETVSCROLLBARWIDTH() , y , GETVSCROLLBARWIDTH() , h )
         ScrollBarButtonHandle := InitVScrollBarButton (  ParentForm , x + w - GETVSCROLLBARWIDTH() , y + h - GETHSCROLLBARHEIGHT() , 0 , 0 )
      ENDIF

      IF _HMG_SYSDATA [ 265 ] = .T.
         aAdd ( _HMG_SYSDATA [ 142 ] , { ControlHandle , ScrollBarHandle , ScrollBarButtonHandle } )
      ENDIF

   ELSE

      ScrollBarHandle := 0

      IF _HMG_SYSDATA [ 265 ] = .T.
         aAdd ( _HMG_SYSDATA [ 142 ] , ControlHandle )
      ENDIF

   ENDIF

   _HMG_SYSDATA [  5 ] [i] := ScrollBarHandle
   _HMG_SYSDATA [ 39 ] [i] [1] := ScrollBarButtonHandle

   _HMG_SYSDATA [ 40 ] [k] [1] := dynamicbackcolor
   _HMG_SYSDATA [ 40 ] [k] [2] := dynamicforecolor
   _HMG_SYSDATA [ 40 ] [k] [3] := aWhenFields
   _HMG_SYSDATA [ 40 ] [k] [4] := inputmask
   _HMG_SYSDATA [ 40 ] [k] [5] := format

   IF ValType(aHeaderImages) <> "U"
      nHeaderImageListHandle := SetListViewHeaderImages ( ControlHandle , aHeaderImages , aJust, NoTransHeader )
      _HMG_SYSDATA [ 39 ] [k] [9] := aHeaderImages
      _HMG_SYSDATA [ 39 ] [k] [10] := nHeaderImageListHandle
      _HMG_SYSDATA [ 39 ] [k] [11] := aJust
   ENDIF

   RETURN NIL

PROCEDURE _BrowseUpdate( ControlName,ParentName , z )

   LOCAL PageLength , aTemp := {} , cTemp , Fields , _BrowseRecMap := {} , i , x , j , First , Image , _Rec , ColorMap , ColorRow , processdbc , processdfc , k
   LOCAL dbc
   LOCAL dFc

   LOCAL fcolormap
   LOCAL fcolorrow

   LOCAL dim
   LOCAL processdim

   LOCAL dft
   LOCAL processdft

   LOCAL teval

   LOCAL aDisplayItems
   LOCAL aDisplayItemsLengths
   LOCAL aProcessDisplayItems
   LOCAL lFound
   LOCAL p

   IF pcount() == 2
      i := GetControlIndex(ControlName,ParentName)
   ELSE
      i := z
   ENDIF

   IF Select() == 0

      RETURN
   ENDIF

   aDisplayItems := _HMG_SYSDATA [39] [I] [8]

   aProcessDisplayItems := array ( HMG_LEN (_HMG_SYSDATA [ 31 ] [i]) )
   aDisplayItemsLengths := array ( HMG_LEN (_HMG_SYSDATA [ 31 ] [i]) )

   IF valtype (aDisplayItems) = 'A'

      FOR k := 1 To HMG_LEN ( aProcessDisplayItems )

         IF valtype ( aDisplayItems [k] ) = 'A'
            aProcessDisplayItems [k] := .T.
            aDisplayItemsLengths [k] := HMG_LEN ( aDisplayItems [k] )
         ELSE
            aProcessDisplayItems [k] := .F.
            aDisplayItemsLengths [k] := 0
         ENDIF

      NEXT k

   ELSE

      FOR k := 1 To HMG_LEN ( aProcessDisplayItems )
         aProcessDisplayItems [k] := .F.
         aDisplayItemsLengths [k] := 0
      NEXT k

   ENDIF

   dim :=    _HMG_SYSDATA [40] [I] [4]

   processdim := array ( HMG_LEN (_HMG_SYSDATA [ 31 ] [i]) )

   IF valtype (dim) = 'A'

      FOR k := 1 To HMG_LEN ( processdim )
         IF valtype ( dim [k] ) = 'C'
            IF .not. empty ( dim [k] )
               processdim [k] := .T.
            ELSE
               processdim [k] := .F.
            ENDIF
         ELSE
            processdim [k] := .F.
         ENDIF
      NEXT k

   ELSE

      FOR k := 1 To HMG_LEN ( processdim )
         processdim [k] := .F.
      NEXT k

   ENDIF

   dft :=    _HMG_SYSDATA [40] [I] [5]

   processdft := array ( HMG_LEN (_HMG_SYSDATA [ 31 ] [i]) )

   IF valtype (dft) = 'A'

      FOR k := 1 To HMG_LEN ( processdft )
         IF valtype ( dft [k] ) = 'C'
            IF .not. empty ( dft [k] )
               processdft [k] := .T.
            ELSE
               processdft [k] := .F.
            ENDIF
         ELSE
            processdft [k] := .F.
         ENDIF
      NEXT k

   ELSE

      FOR k := 1 To HMG_LEN ( processdft )
         processdft [k] := .F.
      NEXT k

   ENDIF

   dbc :=    _HMG_SYSDATA [ 40 ] [i] [1]

   processdbc := if ( valtype (dbc) = 'A' , .t. , .f. )

   dfc :=    _HMG_SYSDATA [ 40 ] [i] [2]

   processdFc := if ( valtype (dFc) = 'A' , .t. , .f. )

   _HMG_SYSDATA [ 26 ] [i] := 0

   First   := iif( HMG_LEN( _HMG_SYSDATA [ 14 ][i] ) == 0, 1, 2 ) // Browse+ ( 2= bitmap definido, se cargan campos a partir de 2º )

   FIELDS := _HMG_SYSDATA [ 31 ] [i]

   ListViewReset ( _HMG_SYSDATA [3][i] )
   PageLength := ListViewGetCountPerPage ( _HMG_SYSDATA [3][i] )

   IF processdbc == .t.
      colormap := {}
      colorrow := {}
   ENDIF

   IF processdfc == .t.
      fcolormap := {}
      fcolorrow := {}
   ENDIF

   FOR x := 1 to PageLength

      aTemp := {}

      IF First == 2                  // Browse+
         cTemp := Fields [1]

         IF Type (cTemp) == 'N'            // ..
            image := &cTemp

         ELSEIF Type (cTemp) == 'L'         // ..
            image := iif( &cTemp, 1, 0 )

         ELSE                  // ..
            image := 0

         ENDIF                  // ..
         aadd ( aTemp , NIL )

         IF processdbc == .t.
            IF valtype ( dbc ) = 'A'
               IF HMG_LEN ( dbc ) = HMG_LEN ( Fields )
                  aadd ( colorrow , -1 )
               ENDIF
            ENDIF
         ENDIF
         IF processdfc == .t.
            IF valtype ( dfc ) = 'A'
               IF HMG_LEN ( dfc ) = HMG_LEN ( Fields )
                  aadd ( fcolorrow , -1 )
               ENDIF
            ENDIF
         ENDIF

      ENDIF                     // Browse+

      FOR j := First To HMG_LEN (Fields)

         cTemp := Fields [j]

         IF aProcessDisplayItems [ j ] == .T.

            lFound := .F.

            FOR p := 1 To aDisplayItemsLengths [ j ]
               IF aDisplayItems [ j ] [ p ] [ 2 ] = &cTemp
                  aadd ( aTemp , RTRIM ( aDisplayItems [ j ] [ p ] [ 1 ] ) )
                  lFound := .T.
                  EXIT
               ENDIF
            NEXT p

            IF lFound == .F.
               aadd ( aTemp , '' )
            ENDIF

         ELSEIF Type (cTemp) == 'N'

            IF   processdim [j] == .f. .and. processdft [j] == .f.

               aadd ( aTemp , LTRIM ( STR (&cTemp) ) )

            ELSEIF   processdim [j] == .t. .and. processdft [j] == .f.

               aadd ( aTemp , TransForm ( &cTemp , dim [j] ) )

            ELSEIF   processdim [j] == .f. .and. processdft [j] == .t.

               aadd ( aTemp , TransForm ( &cTemp , '@' + dft [j] ) )

            ELSEIF   processdim [j] == .t. .and. processdft [j] == .t.

               aadd ( aTemp , TransForm ( &cTemp , '@' + dft [j] + ' ' + dim [j] ) )

            ENDIF

         ELSEIF Type (cTemp) == 'D'

            aadd ( aTemp , Dtoc(&cTemp) )

         ELSEIF Type (cTemp) == 'L'

            aadd ( aTemp , IIF ( &cTemp == .T. , '.T.' , '.F.' ) )

         ELSEIF Type (cTemp) == 'C'

            IF processdim [j] == .t.
               aadd ( aTemp , RTRIM ( _BrowseCharMaskDisplay ( &cTemp , dim [j] ) ) )
            ELSE
               aadd ( aTemp , RTRIM ( &cTemp ) )
            ENDIF

         ELSEIF Type (cTemp) == 'M'

            aadd ( aTemp , '<Memo>' )

         ELSEIF ValType (cTemp) == 'N'

            IF   processdim [j] == .f. .and. processdft [j] == .f.

               aadd ( aTemp , LTRIM ( STR (&cTemp) ) )

            ELSEIF   processdim [j] == .t. .and. processdft [j] == .f.

               aadd ( aTemp , TransForm ( &cTemp , dim [j] ) )

            ELSEIF   processdim [j] == .f. .and. processdft [j] == .t.

               aadd ( aTemp , TransForm ( &cTemp , '@' + dft [j] ) )

            ELSEIF   processdim [j] == .t. .and. processdft [j] == .t.

               aadd ( aTemp , TransForm ( &cTemp , '@' + dft [j] + ' ' + dim [j] ) )

            ENDIF

         ELSEIF ValType (cTemp) == 'D'

            aadd ( aTemp , Dtoc(&cTemp) )

         ELSEIF ValType (cTemp) == 'L'

            aadd ( aTemp , IIF ( &cTemp == .T. , '.T.' , '.F.' ) )

         ELSEIF ValType (cTemp) == 'C'

            IF processdim [j] == .t.
               aadd ( aTemp , RTRIM ( _BrowseCharMaskDisplay ( &cTemp , dim [j] ) ) )
            ELSE
               aadd ( aTemp , RTRIM ( &cTemp ) )
            ENDIF

         ELSEIF ValType (cTemp) == 'M'

            aadd ( aTemp , '<Memo>' )

         ELSE
            aadd ( aTemp , 'Nil' )

         ENDIF

         IF processdbc == .t.

            IF valtype ( dbc ) = 'A'

               IF HMG_LEN ( dbc ) = HMG_LEN ( Fields )

                  IF valtype ( dbc [j] ) = 'B'

                     tEval := eval ( dbc [j] )

                     IF VALTYPE ( TEVAL ) == 'A'
                        IF HMG_LEN ( TEVAL ) == 3
                           TEVAL := RGB ( TEVAL [1] , TEVAL [2] , TEVAL [3] )
                        ENDIF
                     ENDIF

                     aadd ( colorrow , tEval )

                  ELSE
                     aadd ( colorrow , -1 )
                  ENDIF

               ENDIF

            ENDIF

         ENDIF

         IF processdfc == .t.

            IF valtype ( dfc ) = 'A'

               IF HMG_LEN ( dfc ) = HMG_LEN ( Fields )

                  IF valtype ( dfc [j] ) = 'B'

                     tEval := eval ( dfc [j] )

                     IF VALTYPE ( TEVAL ) == 'A'
                        IF HMG_LEN ( TEVAL ) == 3
                           TEVAL := RGB ( TEVAL [1] , TEVAL [2] , TEVAL [3] )
                        ENDIF
                     ENDIF

                     aadd ( fcolorrow , tEval )

                  ELSE
                     aadd ( fcolorrow , -1 )
                  ENDIF

               ENDIF

            ENDIF

         ENDIF

      NEXT j

      AddListViewItems ( _HMG_SYSDATA [3][i] , aTemp , Image )

      _Rec := RecNo()

      aadd ( _BrowseRecMap , _Rec )

      IF processdbc == .t.
         aadd ( colormap , colorrow )
         colorrow := {}
      ENDIF

      IF processdfc == .t.
         aadd ( fcolormap , fcolorrow )
         fcolorrow := {}
      ENDIF

      SKIP

      IF Eof()
         _HMG_SYSDATA [ 26 ] [i] := 1
         Go Bottom
         EXIT
      ENDIF

   NEXT x

   IF processdbc == .t.

      _HMG_SYSDATA [ 40 ] [ I ] [ 6 ] := colormap

   ELSE

      _HMG_SYSDATA [ 40 ] [ I ] [ 6 ] := Nil

   ENDIF

   IF processdfc == .t.

      _HMG_SYSDATA [ 40 ] [ I ] [ 7 ] := fcolormap

   ELSE

      _HMG_SYSDATA [ 40 ] [ I ] [ 7 ] := Nil

   ENDIF

   _HMG_SYSDATA [ 32 ] [i] := _BrowseRecMap

   RETURN

PROCEDURE _BrowseNext ( ControlName , ParentForm , z )

   LOCAL i , PageLength , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil } , s

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   PageLength := LISTVIEWGETCOUNTPERPAGE ( _HMG_SYSDATA [3][i] )

   s := LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] )

   IF  s == PageLength

      IF _HMG_SYSDATA [ 26 ] [i] != 0

         RETURN
      ENDIF

      _Alias := Alias()
      _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
      IF Select (_BrowseArea) == 0

         RETURN
      ENDIF
      SELECT &_BrowseArea
      _RecNo := RecNo()

      Go _BrowseRecMap [PageLength]
      _BrowseUpdate( ControlName , ParentForm , i )
      _BrowseVscrollUpdate( i )
      ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , HMG_LEN(_HMG_SYSDATA [ 32 ] [i] ) )
      Go _RecNo
      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

   ELSE

      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , HMG_LEN(_BrowseRecMap) )
      _BrowseVscrollFastUpdate ( i , PageLength - s )

   ENDIF

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowsePrior ( ControlName , ParentForm , z )

   LOCAL i , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil }

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   IF LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) == 1
      _Alias := Alias()
      _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
      IF Select (_BrowseArea) == 0

         RETURN
      ENDIF
      SELECT &_BrowseArea
      _RecNo := RecNo()
      Go _BrowseRecMap [1]
      SKIP - LISTVIEWGETCOUNTPERPAGE ( _HMG_SYSDATA [3][i] ) + 1
      _BrowseVscrollUpdate( i )
      _BrowseUpdate(ControlName , ParentForm , i )
      ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
      Go _RecNo
      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

   ELSE

      _BrowseVscrollFastUpdate ( i , 1 - LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) )

   ENDIF

   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , 1 )

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowseHome ( ControlName , ParentForm , z )

   LOCAL i , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil }

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
   IF Select (_BrowseArea) == 0

      RETURN
   ENDIF
   SELECT &_BrowseArea
   _RecNo := RecNo()
   GO TOP
   _BrowseVscrollUpdate( i )
   _BrowseUpdate( ControlName , ParentForm , i )
   ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , 1 )

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowseEnd ( ControlName , ParentForm , z )

   LOCAL i , _Alias , _RecNo , _BrowseArea , _BrowseRecMap   , _DeltaScroll := { Nil , Nil , Nil , Nil } , _BottomRec

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
   IF Select (_BrowseArea) == 0

      RETURN
   ENDIF
   SELECT &_BrowseArea
   _RecNo := RecNo()
   Go Bottom
   _BottomRec := RecNo()

   _BrowseVscrollUpdate( i )
   SKIP - LISTVIEWGETCOUNTPERPAGE ( _HMG_SYSDATA [3][i] ) + 1
   _BrowseUpdate(ControlName , ParentForm , i )
   ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , ascan ( _HMG_SYSDATA [ 32 ] [i] , _BottomRec ) )

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowseUp ( ControlName , ParentForm , z )

   LOCAL i , s  , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil }

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   s := LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] )

   IF s == 1
      _Alias := Alias()
      _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
      IF Select (_BrowseArea) == 0

         RETURN
      ENDIF
      SELECT &_BrowseArea
      _RecNo := RecNo()
      Go _BrowseRecMap [1]
      SKIP - 1
      _BrowseVscrollUpdate( i )
      _BrowseUpdate(ControlName , ParentForm , i )
      ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
      Go _RecNo
      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF
      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , 1 )

   ELSE
      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , s - 1 )
      _BrowseVscrollFastUpdate ( i , -1 )
   ENDIF

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowseDown ( ControlName , ParentForm , z )

   LOCAL i , PageLength , s , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil }

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   s := LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] )

   PageLength := LISTVIEWGETCOUNTPERPAGE ( _HMG_SYSDATA [3][i] )

   IF s == PageLength

      IF _HMG_SYSDATA [ 26 ] [i] != 0

         RETURN
      ENDIF

      _Alias := Alias()
      _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
      IF Select (_BrowseArea) == 0

         RETURN
      ENDIF
      SELECT &_BrowseArea
      _RecNo := RecNo()

      Go _BrowseRecMap [1]
      SKIP
      _BrowseUpdate( ControlName , ParentForm , i )
      _BrowseVscrollUpdate( i )
      ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
      Go _RecNo
      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , HMG_LEN(_HMG_SYSDATA [ 32 ] [i]) )

   ELSE

      ListView_SetCursel ( _HMG_SYSDATA [3] [i] , s+1 )
      _BrowseVscrollFastUpdate ( i , 1 )

   ENDIF

   _BrowseOnChange (i)

   RETURN

PROCEDURE _BrowseRefresh ( ControlName , ParentForm , z )

   LOCAL i , s , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , _DeltaScroll := { Nil , Nil , Nil , Nil }
   LOCAL v
   MEMVAR cMacroVar
   PRIVATE cMacroVar

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   v := _BrowseGetValue ( '','' , i )

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   s := LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] )

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]

   IF Select (_BrowseArea) == 0
      ListViewReset ( _HMG_SYSDATA [3][i] )

      RETURN
   ENDIF

   SELECT &_BrowseArea
   _RecNo := RecNo()

   IF v <= 0
      v := _RecNo
   ENDIF

   Go v

   IF s == 1 .or. s == 0
      cMacroVar := dbfilter()
      IF HMG_LEN (cMacroVar) > 0
         IF ! &cMacroVar
            SKIP
         ENDIF
      ENDIF
   ENDIF

   IF s == 0 .or. s == 1
      IF INDEXORD() != 0
         IF ORDKEYVAL() == Nil
            GO TOP
         ENDIF
      ENDIF
   ENDIF

   IF s == 0 .or. s == 1
      IF Set ( _SET_DELETED ) == .T.
         IF Deleted() == .T.
            GO TOP
         ENDIF
      ENDIF
   ENDIF

   IF Eof()

      ListViewReset ( _HMG_SYSDATA [3][i] )

      Go _RecNo

      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

      RETURN

   ENDIF

   _BrowseVscrollUpdate( i )

   IF s != 0
      SKIP -s+1
   ENDIF

   _BrowseUpdate( '' , '' , i )

   ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , ascan ( _HMG_SYSDATA [ 32 ] [i] , v ) )

   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   RETURN

PROCEDURE _BrowseSetValue ( ControlName , ParentForm , Value , z , mp )

   LOCAL i  , _Alias , _RecNo , _BrowseArea , _BrowseRecMap , NewPos := 50  , _DeltaScroll := { Nil , Nil , Nil , Nil } , m
   MEMVAR cMacroVar
   PRIVATE cMacroVar

   IF Value <= 0

      RETURN
   ENDIF

   IF valtype ( z ) == 'U'
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   IF _HMG_SYSDATA [ 232 ] == 'BROWSE_ONCHANGE'
      IF i == _HMG_SYSDATA [ 203 ]
         MsgHMGError ("BROWSE: Value property can't be changed inside ONCHANGE event. Program Terminated" )
      ENDIF
   ENDIF

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]

   IF Select (_BrowseArea) == 0

      RETURN
   ENDIF

   IF Value == (_BrowseArea)->(RecCount()) + 1
      _HMG_SYSDATA [  8 ] [i] := Value
      ListViewReset ( _HMG_SYSDATA [3][i] )
      _BrowseOnChange (i)

      RETURN
   ENDIF

   IF Value > (_BrowseArea)->(RecCount()) + 1

      RETURN
   ENDIF

   IF Select (_BrowseArea) == 0

      RETURN
   ENDIF

   IF valtype ( mp ) == 'U'
      m := int ( ListViewGetCountPerPage ( _HMG_SYSDATA [3][i] ) / 2 )
   ELSE
      m := mp
   ENDIF

   _DeltaScroll := ListView_GetSubItemRect ( _HMG_SYSDATA [3][i] , 0 , 0 )
   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   SELECT &_BrowseArea

   _RecNo := RecNo()

   Go Value

   cMacroVar := dbfilter()

   IF HMG_LEN (cMacroVar) > 0

      IF ! &cMacroVar

         Go _RecNo
         IF Select( _Alias ) != 0
            SELECT &_Alias
         ELSE
            SELECT 0
         ENDIF

         RETURN

      ENDIF

   ENDIF

   IF Eof()
      Go _RecNo
      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

      RETURN
   ELSE
      IF pcount() < 5
         _BrowseVscrollUpdate( i )
      ENDIF
      SKIP -m + 1
   ENDIF

   _HMG_SYSDATA [  8 ] [i] := Value
   _BrowseUpdate( '' , '' , i )
   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   ListView_Scroll( _HMG_SYSDATA [3][i] , _DeltaScroll[2] * (-1) , 0 )
   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , ascan ( _HMG_SYSDATA [ 32 ] [i] , Value ) )

   _HMG_SYSDATA [ 232 ] := 'BROWSE_ONCHANGE'
   _BrowseOnChange (i)
   _HMG_SYSDATA [ 232 ] := ''

   RETURN

FUNCTION _BrowseGetValue ( ControlName , ParentForm , z )

   LOCAL i , RetVal , _BrowseRecMap , _Alias , _BrowseArea

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]

   IF Select (_BrowseArea) == 0

      RETURN 0
   ENDIF

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   IF LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) != 0
      RetVal := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) ]
   ELSE
      RetVal := 0
   ENDIF

   RETURN ( RetVal )

FUNCTION  _BrowseDelete (  ControlName , ParentForm , z  )

   LOCAL i , _BrowseRecMap , Value , _Alias , _RecNo , _BrowseArea

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   IF LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) == 0

      RETURN NIL
   ENDIF

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   VALUE := _BrowseRecMap [ LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) ]

   IF Value == 0

      RETURN NIL
   ENDIF

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
   IF Select (_BrowseArea) == 0

      RETURN NIL
   ENDIF
   SELECT &_BrowseArea
   _RecNo := RecNo()

   Go Value

   IF _HMG_SYSDATA [  9 ] [i] == .t.
      IF Rlock()
         DELETE
         SKIP
         IF eof()
            Go Bottom
         ENDIF

         IF Set ( _SET_DELETED ) == .T.
            _BrowseSetValue( '' , '' , RecNo() , i , LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) )
         ENDIF

      ELSE

         MsgStop('Record is being editied by another user. Retry later','Delete Record')

      ENDIF

   ELSE

      DELETE
      SKIP
      IF eof()
         Go Bottom
      ENDIF
      IF Set ( _SET_DELETED ) == .T.
         _BrowseSetValue( '' , '' , RecNo() , i  , LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) )
      ENDIF

   ENDIF

   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   RETURN NIL

FUNCTION _BrowseEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , inplace , INPUTITEMS )

   LOCAL actpos:={0,0,0,0}
   LOCAL aInitValues := {} , aFormats := {} , TmpNames := {} , NewRec := 0 , MixedFields := .f.
   PRIVATE aWhen
   PRIVATE aWhenVarNames

   InPlace := .T.

   IF LISTVIEW_GETFIRSTITEM (GridHandle) == 0
      IF Valtype (append) != 'U'
         IF append == .f.

            RETURN NIL
         ENDIF
      ENDIF
   ENDIF

   IF InPlace
      _BrowseInPlaceEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , INPUTITEMS )

      RETURN NIL
   ENDIF

   RETURN NIL

FUNCTION _BrowseInPlaceEdit ( GridHandle , aValid , aValidMessages , aReadOnly , lock , append , aInputItems )

   LOCAL GridCol , GridRow , i , nrec , _GridWorkArea , BackArea , BackRec , _GridFields , FieldName , CellData  := '' , CellColIndex , x
   LOCAL aFieldNames
   LOCAL aTypes
   LOCAL aWidths
   LOCAL aDecimals
   LOCAL Type
   LOCAL Width
   LOCAL Decimals
   LOCAL sFieldname
   LOCAL r
   LOCAL ControlType
   LOCAL Ldelta := 0
   LOCAL aTemp
   LOCAL E
   LOCAL aInputMask
   LOCAL aFormat
   LOCAL BFN
   LOCAL BFS
   LOCAL lInputItems := .F.
   LOCAL aItems := {}
   LOCAL p
   LOCAL aValues := {}
   LOCAL ii
   LOCAL ba
   LOCAL br

   IF _HMG_SYSDATA [ 232 ] == 'BROWSE_WHEN'
      MsgHMGError("BROWSE: Editing within a browse 'when' event procedure is not allowed. Program terminated" )
   ENDIF
   IF _HMG_SYSDATA [ 232 ] == 'BROWSE_VALID'
      MsgHMGError("BROWSE: Editing within a browse 'valid' event procedure is not allowed. Program terminated" )
   ENDIF

   IF append

      I := ascan ( _HMG_SYSDATA [3] , GridHandle )

      _BrowseInPlaceAppend ( '' , '' , i )

      RETURN NIL

   ENDIF

   IF This.CellRowIndex != LISTVIEW_GETFIRSTITEM ( GridHandle )

      RETURN NIL
   ENDIF

   I := ascan ( _HMG_SYSDATA [3] , GridHandle )

   BFN := _HMG_SYSDATA [ 27 ] [i]
   BFS := _HMG_SYSDATA [ 28 ] [i]

   aInputMask := _HMG_SYSDATA [ 40 ] [ I ] [ 4 ]

   aFormat := _HMG_SYSDATA [40] [I] [5]

   _GridWorkArea := _HMG_SYSDATA [ 22 ] [i]

   _GridFields := _HMG_SYSDATA [ 31 ] [i]

   CellColIndex := This.CellColIndex

   IF CellColIndex < 1 .or. CellColIndex > HMG_LEN (_GridFields)

      RETURN NIL
   ENDIF

   IF HMG_LEN ( _HMG_SYSDATA [ 14 ] [i] ) > 0 .And. CellColIndex == 1
      PlayHand()

      RETURN NIL
   ENDIF

   IF valType ( aInputItems ) == 'A'
      IF HMG_LEN ( aInputItems ) >= CellColIndex
         IF ValType ( aInputItems [ CellColIndex ] ) == 'A'
            lInputItems := .T.
         ENDIF
      ENDIF
   ENDIF

   IF ValType ( aReadOnly ) == 'A'
      IF HMG_LEN ( aReadOnly ) >= CellColIndex
         IF aReadOnly [ CellColIndex ] != Nil
            IF aReadOnly [ CellColIndex ] == .T.
               _HMG_SYSDATA [ 256 ] := .F.

               RETURN NIL
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   FieldName := _GridFields [  CellColIndex ]

   // If the specified area does not exists, set recorcount to 0 and
   // return

   IF Select (_GridWorkArea) == 0

      RETURN NIL
   ENDIF

   // Save Original WorkArea
   BackArea := Alias()

   // Save Original Record Pointer
   BackRec := RecNo()

   // Selects Grid's WorkArea

   SELECT &_GridWorkArea

   nRec := _GetValue ( '','',i )
   Go nRec

   // If LOCK clause is present, try to lock.

   IF lock == .T.
      IF Rlock() == .F.
         MsgExclamation(_HMG_SYSDATA [ 136 ][9],_HMG_SYSDATA [ 136 ][10])
         // Restore Original Record Pointer
         Go BackRec
         // Restore Original WorkArea
         IF Select (BackArea) != 0
            SELECT &BackArea
         ELSE
            SELECT 0
         ENDIF

         RETURN NIL
      ENDIF
   ENDIF

   aTemp := _HMG_SYSDATA [40] [i] [3]

   IF VALTYPE ( aTemp ) = 'A'
      IF HMG_LEN (aTemp) == HMG_LEN (_GridFields)
         IF VALTYPE ( aTemp [CellColIndex] ) = 'B'
            ba := Alias()
            br := recno()
            _HMG_SYSDATA [ 232 ] := 'BROWSE_WHEN'
            E := EVAL ( aTemp [CellColIndex] )
            _HMG_SYSDATA [ 232 ] := ''
            IF E == .F.
               PlayHand()
               // Restore Original Record Pointer
               Go BackRec
               // Restore Original WorkArea
               IF Select (BackArea) != 0
                  SELECT &BackArea
               ELSE
                  SELECT 0
               ENDIF
               _HMG_SYSDATA [ 256 ] := .F.

               RETURN NIL
            ENDIF
            SELECT (ba)
            Go br
         ENDIF
      ENDIF
   ENDIF

   CellData := &FieldName

   aFieldNames   := ARRAY(FCOUNT())
   aTypes      := ARRAY(FCOUNT())
   aWidths      := ARRAY(FCOUNT())
   aDecimals   := ARRAY(FCOUNT())

   AFIELDS(aFieldNames, aTypes, aWidths, aDecimals)

   r := HB_UAT ('>',FieldName)

   IF r != 0
      sFieldName := HB_URIGHT ( FieldName, HMG_LEN(Fieldname) - r )
   ELSE
      sFieldName := FieldName
   ENDIF

   x := FieldPos ( sFieldName )

   IF x > 0
      Type      := aTypes [x]
      WIDTH      := aWidths [x]
      Decimals   := aDecimals [x]
   ENDIF

   GridRow := GetWIndowRow (GridHandle)
   GridCol := GetWIndowCol (GridHandle)

   IF lInputItems == .T.
      ControlType := 'X'
      Ldelta := 1
   ELSEIF Type (FieldName) == 'C'
      ControlType := 'C'
   ELSEIF Type (FieldName) == 'D'
      ControlType := 'D'
   ELSEIF Type (FieldName) == 'L'
      ControlType := 'L'
      Ldelta := 1
   ELSEIF Type (FieldName) == 'M'
      ControlType := 'M'
   ELSEIF Type (FieldName) == 'N'
      IF Decimals == 0
         ControlType := 'I'
      ELSE
         ControlType := 'F'
      ENDIF
   ENDIF

   IF ControlType == 'M'

      r := InputBox ( '' , _HMG_SYSDATA [ 33 ] [I] [CellColIndex] , HB_UTF8STRTRAN(CellData,CHR(141),' ') , , , .T. )

      IF _HMG_SYSDATA [ 257 ] == .F.
         REPLACE &FieldName With r
         _HMG_SYSDATA [ 256 ] := .F.
      ELSE
         _HMG_SYSDATA [ 256 ] := .T.
      ENDIF

   ELSE

      _HMG_SYSDATA [ 109 ] := GetActiveWindow()

      DEFINE WINDOW _InPlaceEdit ;
            AT This.CellRow + GridRow - _HMG_SYSDATA [ 18 ] [i] - 1 , This.CellCol + GridCol - _HMG_SYSDATA [ 19 ] [i] + 2 ;
            WIDTH This.CellWidth ;
            HEIGHT This.CellHeight + 6 + Ldelta ;
            MODAL ;
            NOCAPTION ;
            NOSIZE

         ON KEY CONTROL+W ACTION if ( _IsWindowActive ( '_InPlaceEdit' ) , _InPlaceEditOk ( i , Fieldname , _InPlaceEdit.Control_1.Value , ControlType , aValid , CellColIndex , sFieldName , _GridWorkArea , aValidMessages , lock , aInputItems ) , Nil )
         ON KEY RETURN ACTION if ( _IsWindowActive ( '_InPlaceEdit' ) , _InPlaceEditOk ( i , Fieldname , _InPlaceEdit.Control_1.Value , ControlType , aValid , CellColIndex , sFieldName , _GridWorkArea , aValidMessages , lock , aInputItems ) , Nil )
         ON KEY ESCAPE ACTION ( _HMG_SYSDATA [ 256 ] := .T. , dbrunlock() , _InPlaceEdit.Release , setfocus ( _HMG_SYSDATA [3] [i] ) )

         IF lInputItems == .T.

            * Fill Items Array

            FOR p := 1 To HMG_LEN ( aInputItems [ CellColIndex ] )
               aadd ( aItems , aInputItems [ CellColIndex ] [p] [1] )
            NEXT p

            * Fill Values Array

            FOR p := 1 To HMG_LEN ( aInputItems [ CellColIndex ] )
               aadd ( aValues , aInputItems [ CellColIndex ] [p] [2] )
            NEXT p

            ii := aScan ( aValues , CellData )

            IF ii == 0
               ii := 1
            ENDIF

            DEFINE COMBOBOX Control_1
               FONTNAME BFN
               FONTSIZE BFS
               ROW 0
               COL 0
               ITEMS aItems
               WIDTH This.CellWidth
               VALUE ii
            END COMBOBOX

         ELSEIF ControlType == 'C'
            CellData := RTRIM ( CellData )

            DEFINE TEXTBOX Control_1
               FONTNAME BFN
               FONTSIZE BFS

               ROW 0
               COL 0
               WIDTH This.CellWidth
               HEIGHT This.CellHeight + 6
               VALUE CellData
               MAXLENGTH Width

               IF VALTYPE ( AINPUTMASK ) == 'A'
                  IF HMG_LEN ( AINPUTMASK ) >= CellColIndex
                     IF VALTYPE ( AINPUTMASK [CellColIndex] ) == 'C'
                        IF ! EMPTY ( AINPUTMASK [CellColIndex] )
                           INPUTMASK AINPUTMASK [CellColIndex]
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF

            END TEXTBOX

         ELSEIF ControlType == 'D'

            DEFINE DATEPICKER Control_1
               FONTNAME BFN
               FONTSIZE BFS
               ROW 0
               COL 0
               HEIGHT This.CellHeight + 6
               WIDTH This.CellWidth
               VALUE CellData
               UPDOWN .T.
               SHOWNONE .T.
            END DATEPICKER

         ELSEIF ControlType == 'L'

            DEFINE COMBOBOX Control_1
               FONTNAME BFN
               FONTSIZE BFS
               ROW 0
               COL 0
               ITEMS { '.T.','.F.' }
               WIDTH This.CellWidth
               VALUE If ( CellData , 1 , 2 )
            END COMBOBOX

         ELSEIF ControlType == 'I'

            DEFINE TEXTBOX Control_1
               FONTNAME BFN
               FONTSIZE BFS
               ROW 0
               COL 0
               NUMERIC   .T.
               WIDTH This.CellWidth
               HEIGHT This.CellHeight + 6
               VALUE CellData

               IF VALTYPE ( AINPUTMASK ) == 'A'
                  IF HMG_LEN ( AINPUTMASK ) >= CellColIndex
                     IF VALTYPE ( AINPUTMASK [CellColIndex] ) == 'C'
                        IF ! EMPTY ( AINPUTMASK [CellColIndex] )
                           INPUTMASK AINPUTMASK [CellColIndex]
                        ELSE
                           MAXLENGTH Width
                        ENDIF
                     ELSE
                        MAXLENGTH Width
                     ENDIF
                  ELSE
                     MAXLENGTH Width
                  ENDIF
               ELSE
                  MAXLENGTH Width
               ENDIF

               IF VALTYPE ( AFORMAT ) == 'A'
                  IF HMG_LEN ( AFORMAT ) >= CellColIndex
                     IF VALTYPE ( AFORMAT [CellColIndex] ) == 'C'
                        IF ! EMPTY ( AFORMAT [CellColIndex] )
                           FORMAT AFORMAT [CellColIndex]
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF

            END TEXTBOX

         ELSEIF ControlType == 'F'

            DEFINE TEXTBOX Control_1
               FONTNAME BFN
               FONTSIZE BFS
               ROW 0
               COL 0
               NUMERIC   .T.
               WIDTH This.CellWidth
               HEIGHT This.CellHeight + 6
               VALUE CellData

               IF VALTYPE ( AINPUTMASK ) == 'A'
                  IF HMG_LEN ( AINPUTMASK ) >= CellColIndex
                     IF VALTYPE ( AINPUTMASK [CellColIndex] ) == 'C'
                        IF ! EMPTY ( AINPUTMASK [CellColIndex] )
                           INPUTMASK AINPUTMASK [CellColIndex]
                        ELSE
                           INPUTMASK REPLICATE ( '9', Width - Decimals - 1 ) + '.' + REPLICATE ( '9', Decimals )
                        ENDIF
                     ELSE
                        INPUTMASK REPLICATE ( '9', Width - Decimals - 1 ) + '.' + REPLICATE ( '9', Decimals )
                     ENDIF
                  ELSE
                     INPUTMASK REPLICATE ( '9', Width - Decimals - 1 ) + '.' + REPLICATE ( '9', Decimals )
                  ENDIF
               ELSE
                  INPUTMASK REPLICATE ( '9', Width - Decimals - 1 ) + '.' + REPLICATE ( '9', Decimals )
               ENDIF

               IF VALTYPE ( AFORMAT ) == 'A'
                  IF HMG_LEN ( AFORMAT ) >= CellColIndex
                     IF VALTYPE ( AFORMAT [CellColIndex] ) == 'C'
                        IF ! EMPTY ( AFORMAT [CellColIndex] )
                           FORMAT AFORMAT [CellColIndex]
                        ENDIF
                     ENDIF
                  ENDIF
               ENDIF

            END TEXTBOX

         ENDIF

      END WINDOW

      ACTIVATE WINDOW _InPlaceEdit

      _HMG_SYSDATA [ 109 ] := 0

   ENDIF

   // Restore Original Record Pointer
   Go BackRec

   // Restore Original WorkArea
   IF Select (BackArea) != 0
      SELECT &BackArea
   ELSE
      SELECT 0
   ENDIF

   RETURN NIL

PROCEDURE _InPlaceEditOk ( i , Fieldname , r , ControlType , aValid , CellColIndex , sFieldName , AreaName , aValidMessages , lock , aInputItems )

   LOCAL b , Result , mVar , TmpName

   IF ControlType == 'X' .Or. ControlType == 'L'

      IF GetDroppedState ( GetControlHandle ('Control_1' , '_InPlaceEdit' ) ) == 1
         SendMessage ( GetControlHandle ('Control_1' , '_InPlaceEdit' ) , CB_SHOWDROPDOWN , 0 , 0 )
         InsertReturn()

         RETURN
      ENDIF

   ENDIF

   IF ValType ( aValid ) == 'A'
      IF HMG_LEN ( aValid ) >= CellColIndex
         IF aValid [ CellColIndex ] != Nil
            Result := _GetValue ( 'Control_1' , '_InPlaceEdit' )

            IF ControlType == 'L'
               Result := if ( Result == 0 .or. Result == 2 , .F. , .T. )
            ENDIF

            TmpName := 'MemVar' + AreaName + sFieldname
            mVar := TmpName
            &mVar := Result

            _HMG_SYSDATA [ 232 ] := 'BROWSE_VALID'

            b := Eval ( aValid [ CellColIndex ] )

            _HMG_SYSDATA [ 232 ] := ''

            IF b == .f.

               IF ValType ( aValidMessages ) == 'A'

                  IF HMG_LEN ( aValidMessages ) >= CellColIndex

                     IF aValidMessages [CellColIndex] != Nil

                        MsgExclamation ( aValidMessages [CellColIndex] )

                     ELSE

                        MsgExclamation (_HMG_SYSDATA [ 136 ][11])

                     ENDIF

                  ELSE

                     MsgExclamation (_HMG_SYSDATA [ 136 ][11])

                  ENDIF

               ELSE

                  MsgExclamation (_HMG_SYSDATA [ 136 ][11])

               ENDIF

            ELSE

               IF ControlType == 'L'
                  r := if ( r == 0 .or. r == 2 , .F. , .T. )

               ELSEIF ControlType == 'X'

                  r := aInputItems [ CellColIndex ] [ r ] [ 2 ]

               ENDIF

               IF lock == .t.
                  REPLACE &FieldName With r
                  UNLOCK

                  _BrowseRefresh ( '' , '' , i )

                  _InPlaceEdit.Release
               ELSE
                  REPLACE &FieldName With r

                  _BrowseRefresh ( '' , '' , i )

                  _InPlaceEdit.Release
               ENDIF

            ENDIF

         ELSE

            IF ControlType == 'L'

               r := if ( r == 0 .or. r == 2 , .F. , .T. )

            ELSEIF ControlType == 'X'

               r := aInputItems [ CellColIndex ] [ r ] [ 2 ]

            ENDIF

            IF lock == .t.

               REPLACE &FieldName With r
               UNLOCK

               _BrowseRefresh ( '' , '' , i )

               _InPlaceEdit.Release

            ELSE

               REPLACE &FieldName With r

               _BrowseRefresh ( '' , '' , i )

               _InPlaceEdit.Release

            ENDIF

         ENDIF

      ENDIF

   ELSE

      IF ControlType == 'L'

         r := if ( r == 0 .or. r == 2 , .F. , .T. )

      ELSEIF ControlType == 'X'

         r := aInputItems [ CellColIndex ] [ r ] [ 2 ]

      ENDIF

      IF lock == .t.

         REPLACE &FieldName With r
         UNLOCK

         _BrowseRefresh ( '' , '' , i )

         _InPlaceEdit.Release

      ELSE

         REPLACE &FieldName With r

         _BrowseRefresh ( '' , '' , i )

         _InPlaceEdit.Release

      ENDIF

   ENDIF

   _HMG_SYSDATA [ 256 ] := .F.

   setfocus ( _HMG_SYSDATA [3] [i] )

   RETURN

PROCEDURE ProcessInPlaceKbdEdit(i)

   LOCAL r
   LOCAL IPE_MAXCOL
   LOCAL TmpRow
   LOCAL xs,xd

   IF _HMG_SYSDATA [ 15 ] [ i ] == .F.

      RETURN
   ENDIF

   IF LISTVIEW_GETFIRSTITEM ( _HMG_SYSDATA [3] [i] ) == 0

      RETURN
   ENDIF

   IPE_MAXCOL := HMG_LEN ( _HMG_SYSDATA [ 31 ] [i] )

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

      xs :=   ( ( _HMG_SYSDATA [ 19 ] [i] + r [2] ) +( r[3] ))  -  ( _HMG_SYSDATA [ 19 ] [i] + _HMG_SYSDATA [ 20 ] [i] )

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

      _HMG_SYSDATA [ 197 ] := _HMG_SYSDATA [ 18 ] [i] + r [1]
      _HMG_SYSDATA [ 198 ] := _HMG_SYSDATA [ 19 ] [i] + r [2]
      _HMG_SYSDATA [ 199 ] := r[3]
      _HMG_SYSDATA [ 200 ] := r[4]
      _BrowseEdit ( _HMG_SYSDATA [3][i] , _HMG_SYSDATA [ 39 ] [i] [4] , _HMG_SYSDATA [ 39 ] [i] [5] , _HMG_SYSDATA [ 39 ] [i] [3] , _HMG_SYSDATA [  9 ] [i] , .f. , _HMG_SYSDATA [ 15 ] [i] , _HMG_SYSDATA [ 39 ] [i] [7] )
      _HMG_SYSDATA [ 203 ] := 0
      _HMG_SYSDATA [ 231 ] := ''

      _HMG_SYSDATA [ 195 ] := 0
      _HMG_SYSDATA [ 196 ] := 0
      _HMG_SYSDATA [ 197 ] := 0
      _HMG_SYSDATA [ 198 ] := 0
      _HMG_SYSDATA [ 199 ] := 0
      _HMG_SYSDATA [ 200 ] := 0

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

PROCEDURE _BrowseSync (i)

   LOCAL _Alias
   LOCAL _BrowseArea
   LOCAL _RecNo
   LOCAL _CurrentValue

   IF _HMG_SYSDATA [ 254 ] == .T.

      _Alias := Alias()
      _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
      IF Select (_BrowseArea) == 0

         RETURN
      ENDIF
      SELECT &_BrowseArea
      _RecNo := RecNo()

      _CurrentValue := _BrowseGetValue ( '' , '' , i )

      IF _RecNo != _CurrentValue
         Go _CurrentValue
      ENDIF

      IF Select( _Alias ) != 0
         SELECT &_Alias
      ELSE
         SELECT 0
      ENDIF

   ENDIF

   RETURN

PROCEDURE _BrowseOnChange (i)

   _BrowseSync (i)

   _DoControlEventProcedure ( _HMG_SYSDATA [ 12 ] [i] , i )

   RETURN

PROCEDURE _BrowseInPlaceAppend ( ControlName , ParentForm , z )

   LOCAL i , _Alias , _RecNo , _BrowseArea , _BrowseRecMap   , _DeltaScroll := { Nil , Nil , Nil , Nil } , _NewRec , aTemp

   IF pcount() == 2
      i := GetControlIndex ( ControlName , ParentForm )
   ELSE
      i := z
   ENDIF

   _BrowseRecMap := _HMG_SYSDATA [ 32 ] [i]

   _Alias := Alias()
   _BrowseArea := _HMG_SYSDATA [ 22 ] [i]
   IF Select (_BrowseArea) == 0

      RETURN
   ENDIF
   SELECT &_BrowseArea
   _RecNo := RecNo()
   Go Bottom

   _NewRec := RecCount() + 1

   IF ListView_GetItemCount(_HMG_SYSDATA [3][i] ) != 0
      _BrowseVscrollUpdate( i )
      SKIP - LISTVIEWGETCOUNTPERPAGE ( _HMG_SYSDATA [3][i] ) + 2
      _BrowseUpdate(ControlName , ParentForm , i )
   ENDIF

   APPEND BLANK

   Go _RecNo
   IF Select( _Alias ) != 0
      SELECT &_Alias
   ELSE
      SELECT 0
   ENDIF

   aTemp := array ( HMG_LEN (_HMG_SYSDATA [ 31 ] [i]) )
   afill ( aTemp , '' )
   aadd ( _HMG_SYSDATA [ 32 ] [i] , _NewRec )

   AddListViewItems ( _HMG_SYSDATA [3][i] , aTemp , 0 )

   ListView_SetCursel ( _HMG_SYSDATA [3] [i] , HMG_LEN ( _HMG_SYSDATA [ 32 ] [i] ) )

   _BrowseOnChange (i)

   _HMG_SYSDATA [ 341 ] := 1
   _HMG_SYSDATA [ 340 ] := 1

   RETURN

PROCEDURE _BrowseVscrollUpdate (i)

   LOCAL ActualRecord , RecordCount , KeyCount

   // If vertical scrollbar is used it must be updated
   IF _HMG_SYSDATA [  5 ] [i] != 0

      KeyCount := OrdKeyCount()
      IF KeyCount > 0
         ActualRecord := OrdKeyNo()
         RecordCount := KeyCount
      ELSE
         ActualRecord := RecNo()
         RecordCount := RecCount()
      ENDIF

      _HMG_SYSDATA [ 37 ] [i] := RecordCount

      IF RecordCount < 100
         SetScrollRange (_HMG_SYSDATA [  5 ] [i] , 2 , 1 , RecordCount , .t. )
         SetScrollPos ( _HMG_SYSDATA [  5 ] [i] , 2 , ActualRecord , .T. )
      ELSE
         SetScrollRange (_HMG_SYSDATA [  5 ] [i] , 2 , 1 , 100 , .t. )
         SetScrollPos ( _HMG_SYSDATA [  5 ] [i] , 2 , Int ( ActualRecord * 100 / RecordCount ) , .T. )
      ENDIF

   ENDIF

   RETURN

PROCEDURE _BrowseVscrollFastUpdate ( i , d )

   LOCAL ActualRecord , RecordCount

   // If vertical scrollbar is used it must be updated
   IF _HMG_SYSDATA [  5 ] [i] != 0

      RecordCount := _HMG_SYSDATA [ 37 ] [i]

      IF ValType(RecordCount) <> 'N'

         RETURN
      ENDIF

      IF RecordCount == 0

         RETURN
      ENDIF

      IF RecordCount < 100
         ActualRecord := GetScrollPos(_HMG_SYSDATA [  5 ] [i],2)
         ActualRecord := ActualRecord + d
         SetScrollRange (_HMG_SYSDATA [  5 ] [i] , 2 , 1 , RecordCount , .t. )
         SetScrollPos ( _HMG_SYSDATA [  5 ] [i] , 2 , ActualRecord , .T. )
      ENDIF

   ENDIF

   RETURN

FUNCTION _SetBrowseAllowEdit ( cControlName , cWindowName , lValue )

   LOCAL i

   IF ValType ( lValue ) <> 'L'
      MsgHMGError("Wrong Parameter Type (Logical Required). Program terminated" )
   ENDIF

   i := GetControlIndex ( cControlName , cWindowName )

   _HMG_SYSDATA [ 39 ] [i] [6] := lValue

   RETURN NIL

FUNCTION _SetBrowseAllowAppend ( cControlName , cWindowName , lValue )

   LOCAL i

   IF ValType ( lValue ) <> 'L'
      MsgHMGError("Wrong Parameter Type (Logical Required). Program terminated" )
   ENDIF

   i := GetControlIndex ( cControlName , cWindowName )

   _HMG_SYSDATA [ 39 ] [i] [2] := lValue

   RETURN NIL

FUNCTION _SetBrowseAllowDelete ( cControlName , cWindowName , lValue )

   LOCAL i

   IF ValType ( lValue ) <> 'L'
      MsgHMGError("Wrong Parameter Type (Logical Required). Program terminated" )
   ENDIF

   i := GetControlIndex ( cControlName , cWindowName )

   _HMG_SYSDATA [ 25 ] [i] := lValue

   RETURN NIL

FUNCTION _SetBrowseInputItems ( cControlName , cWindowName , aValue )

   LOCAL i

   IF ValType ( aValue ) <> 'A'
      MsgHMGError("Wrong Parameter Type (Array Required). Program terminated" )
   ENDIF

   i := GetControlIndex ( cControlName , cWindowName )

   _HMG_SYSDATA [ 39 ] [ i ] [ 7 ] := aValue

   RETURN NIL

FUNCTION _SetBrowseDisplayItems ( cControlName , cWindowName , aValue )

   LOCAL i

   IF ValType ( aValue ) <> 'A'
      MsgHMGError("Wrong Parameter Type (Array Required). Program terminated" )
   ENDIF

   i := GetControlIndex ( cControlName , cWindowName )

   _HMG_SYSDATA [ 39 ] [ i ] [ 8 ] := aValue

   RETURN NIL

FUNCTION _GetBrowseInputItems ( cControlName , cWindowName )

   LOCAL i

   i := GetControlIndex ( cControlName , cWindowName )

   RETURN _HMG_SYSDATA [ 39 ] [i] [7]

FUNCTION _GetBrowseDisplayItems ( cControlName , cWindowName )

   LOCAL i

   i := GetControlIndex ( cControlName , cWindowName )

   RETURN _HMG_SYSDATA [ 39 ] [i] [8]

FUNCTION _GetBrowseAllowEdit ( cControlName , cWindowName )

   LOCAL i

   i := GetControlIndex ( cControlName , cWindowName )

   RETURN _HMG_SYSDATA [ 39 ] [i] [6]

FUNCTION _GetBrowseAllowAppend ( cControlName , cWindowName , lValue )

   LOCAL i

   lValue := NIL   // ADD

   i := GetControlIndex ( cControlName , cWindowName )

   RETURN _HMG_SYSDATA [ 39 ] [i] [2]

FUNCTION _GetBrowseAllowDelete ( cControlName , cWindowName , lValue )

   LOCAL i

   lValue := NIL   // ADD

   i := GetControlIndex ( cControlName , cWindowName )

   RETURN _HMG_SYSDATA [ 25 ] [i]

FUNCTION _BrowseCharMaskDisplay ( cText , cMask )

   LOCAL i
   LOCAL Out
   LOCAL m
   LOCAL t

   Out := ''

   FOR i := 1 To HMG_LEN ( cMask )

      t := HB_USUBSTR ( cText , i , 1 )
      m := HB_USUBSTR ( cMask , i , 1 )

      IF   m = '!'

         Out := Out + HMG_UPPER (t)

      ELSEIF   m = 'A' .or. m = '9'

         Out := Out + t

      ELSE

         Out := Out + m

      ENDIF

   NEXT i

   RETURN Out

#endif
