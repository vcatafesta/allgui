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

#include "hmg.ch"
#include "common.ch"

FUNCTION _DefineCombo ( ControlName, ;
      ParentForm, ;
      x, ;
      y, ;
      w, ;
      rows, ;
      value, ;
      fontname, ;
      fontsize, ;
      tooltip, ;
      changeprocedure, ;
      h, ;
      gotfocus, ;
      lostfocus, ;
      uEnter, ;
      HelpId, ;
      invisible, ;
      notabstop, ;
      SORT , ;
      bold, ;
      italic, ;
      underline, ;
      strikeout , ;
      itemsource , ;
      valuesource , ;
      DISPLAYedit , ;
      ondisplaychangeprocedure , ;
      break , ;
      GripperText , aImage , DroppedWidth , dropdownprocedure , closeupprocedure, oncancel,  NoTransparent )
   LOCAL i , cParentForm , mVar , ControlHandle , FontHandle , rcount := 0 , BackRec , cset := 0 , WorkArea , cField , ContainerHandle := 0 , k := 0
   LOCAL aRet := {}
   LOCAL ImageListHandle := Nil
   LOCAL aTemp
   LOCAL ImageSource
   LOCAL cImageWorkArea
   LOCAL cImageField

   DEFAULT w               TO 120
   DEFAULT h               TO 150
   DEFAULT changeprocedure TO ""
   DEFAULT gotfocus   TO ""
   DEFAULT lostfocus   TO ""
   DEFAULT rows      TO {}
   DEFAULT invisible   TO FALSE
   DEFAULT notabstop   TO FALSE
   DEFAULT sort      TO FALSE
   DEFAULT GripperText   TO ""
   DEFAULT DroppedWidth   TO w

   IF _HMG_SYSDATA [ 264 ] = TRUE
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
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated" )
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated" )
   ENDIF

   IF ValType ( ItemSource ) != 'U' .And. Sort == .T.
      MsgHMGError ("Sort and ItemSource clauses can't be used simultaneusly. Program Terminated" )
   ENDIF

   IF ValType ( ValueSource ) != 'U' .And. Sort == .T.
      MsgHMGError ("Sort and ValueSource clauses can't be used simultaneusly. Program Terminated" )
   ENDIF

   IF ValType ( ItemSource ) == 'A'

      aTemp := ItemSource

      IF   HMG_LEN ( ItemSource ) == 1 .And. ValType ( aImage ) = 'U'

         ItemSource   := aTemp [1]

      ELSEIF   HMG_LEN ( ItemSource ) == 2 .And. ValType ( aImage ) = 'A'

         ImageSource   := aTemp [1]
         ItemSource   := aTemp [2]

      ELSEIF    HMG_LEN ( ItemSource ) > 2

         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + "Invalid ItemSource property value. Program Terminated" )

      ELSEIF    HMG_LEN ( ItemSource ) == 0

         ItemSource := Nil

      ENDIF

   ENDIF

   IF valtype ( itemsource ) != 'U'
      IF  HB_UAT ( '>',ItemSource ) == 0
         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " (ItemSource): You must specify a fully qualified field name. Program Terminated" )
      ELSE
         WORKAREA := HB_ULEFT ( ItemSource , HB_UAT ( '>', ItemSource ) - 2 )
         cField := HB_URIGHT ( ItemSource , HMG_LEN (ItemSource) - HB_UAT ( '>', ItemSource ) )
      ENDIF
   ENDIF

   IF valtype ( imagesource ) != 'U'
      IF  HB_UAT ( '>',ImageSource ) == 0
         MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " (ItemSource): You must specify a fully qualified field name. Program Terminated" )
      ELSE
         cImageWorkArea := HB_ULEFT ( ImageSource , HB_UAT ( '>', ImageSource ) - 2 )
         cImageField := HB_URIGHT ( ImageSource , HMG_LEN (ImageSource) - HB_UAT ( '>', ImageSource ) )
      ENDIF
   ENDIF

   IF valtype(value) == "U"
      VALUE := 0
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   cParentForm := ParentForm

   ParentForm = GetFormHandle (ParentForm)

   IF valtype(x) == "U" .or. valtype(y) == "U"

      _HMG_SYSDATA [ 216 ]   := 'COMBOBOX'

      i := GetFormIndex ( cParentForm )

      IF i > 0

         IF ValType ( aImage ) == 'U'

            ControlHandle := InitComboBox ( _HMG_SYSDATA [ 87 ] [i], 0, x, y, w, '', 0 , h, invisible, notabstop, sort, displayedit , _HMG_SYSDATA [ 250 ] , DroppedWidth )

         ELSE

            aRet      := InitImageCombo ( _HMG_SYSDATA [ 87 ] [i] , y , x , w , h , aImage , displayedit , .Not. invisible , .Not. notabstop , IF ( WINMAJORVERSIONNUMBER() + ( WINMINORVERSIONNUMBER() / 10 ) > 5.1 , .T. , .F. ) , DroppedWidth, NoTransparent )
            ControlHandle   := aRet [1]
            ImageListHandle   := aRet [2]

         ENDIF

         IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
            FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
         ELSE
            FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
         ENDIF

         AddSplitBoxItem ( Controlhandle , _HMG_SYSDATA [ 87 ] [i] , w , break , GripperText , w , , _HMG_SYSDATA [ 258 ] )

         Containerhandle := _HMG_SYSDATA [ 87 ] [i]

      ENDIF

   ELSE

      IF ValType ( aImage ) == 'U'

         ControlHandle := InitComboBox ( ParentForm, 0, x, y, w, '', 0 , h, invisible, notabstop, sort , displayedit , _HMG_SYSDATA [ 250 ] , DroppedWidth )

      ELSE

         aRet      := InitImageCombo ( ParentForm , y , x , w , h , aImage , displayedit , .Not. invisible , .Not. notabstop , IF ( WINMAJORVERSIONNUMBER() + ( WINMINORVERSIONNUMBER() / 10 ) > 5.1 , .T. , .F. ) , DroppedWidth,  NoTransparent )
         ControlHandle   := aRet [1]
         ImageListHandle   := aRet [2]

      ENDIF

      IF valtype(fontname) != "U" .and. valtype(fontsize) != "U"
         FontHandle := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ELSE
         FontHandle := _SetFont (ControlHandle,_HMG_SYSDATA [ 342 ],_HMG_SYSDATA [ 343 ],bold,italic,underline,strikeout)
      ENDIF

   ENDIF

   IF _HMG_SYSDATA [ 265 ] = TRUE
      aAdd ( _HMG_SYSDATA [ 142 ] , Controlhandle )
   ENDIF

   IF valtype(uEnter) == "U"
      uEnter := ""
   ENDIF

   IF valtype(tooltip) != "U"
      SetToolTip ( ControlHandle , tooltip , GetFormToolTipHandle (cParentForm) )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [  1 ] [k] := "COMBO"
   _HMG_SYSDATA [  2 ] [k] := ControlName
   _HMG_SYSDATA [  3 ] [k] := ControlHandle
   _HMG_SYSDATA [  4 ] [k] := ParentForm
   _HMG_SYSDATA [  5 ] [k] := 0
   _HMG_SYSDATA [  6 ] [k] := ondisplaychangeprocedure
   _HMG_SYSDATA [  7 ] [k] := cField
   _HMG_SYSDATA [  8 ] [k] := Value
   _HMG_SYSDATA [  9 ] [k] := Nil
   _HMG_SYSDATA [ 10 ] [k] := lostfocus
   _HMG_SYSDATA [ 11 ] [k] := gotfocus
   _HMG_SYSDATA [ 12 ] [k] := changeprocedure
   _HMG_SYSDATA [ 13 ] [k] := FALSE
   _HMG_SYSDATA [ 14 ] [k] := cImageField
   _HMG_SYSDATA [ 15 ] [k] := ImageListHandle
   _HMG_SYSDATA [ 16 ] [k] := uEnter
   _HMG_SYSDATA [ 17 ] [k] := {}
   _HMG_SYSDATA [ 18 ] [k] := y
   _HMG_SYSDATA [ 19 ] [k] := x
   _HMG_SYSDATA [ 20 ] [k] := w
   _HMG_SYSDATA [ 21 ] [k] := h
   _HMG_SYSDATA [ 22 ] [k] := WorkArea
   _HMG_SYSDATA [ 23 ] [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ] [k] := iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ] [k] := ""
   _HMG_SYSDATA [ 26 ] [k] := ContainerHandle
   _HMG_SYSDATA [ 27 ] [k] := fontname
   _HMG_SYSDATA [ 28 ] [k] := fontsize
   _HMG_SYSDATA [ 29 ] [k] := {bold,italic,underline,strikeout}
   _HMG_SYSDATA [ 30 ] [k] := tooltip
   _HMG_SYSDATA [ 31 ] [k] := 0
   _HMG_SYSDATA [ 32 ] [k] := OnCancel
   _HMG_SYSDATA [ 33 ] [k] := valuesource
   _HMG_SYSDATA [ 34 ] [k] := if(invisible,FALSE,TRUE)
   _HMG_SYSDATA [ 35 ] [k] := HelpId
   _HMG_SYSDATA [ 36 ] [k] := FontHandle
   _HMG_SYSDATA [ 37 ] [k] := closeupprocedure
   _HMG_SYSDATA [ 38 ] [k] := .T.
   _HMG_SYSDATA [ 39 ] [k] := dropdownprocedure
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF displayedit == .T.
      _HMG_SYSDATA [ 31 ] [k] := FindWindowEx( Controlhandle , 0, "Edit", Nil )
   ENDIF

   IF  ValType( WorkArea ) == "C"

      IF Select ( WorkArea ) != 0

         BackRec := (WorkArea)->(RecNo())

         (WorkArea)->(DBGoTop())

         IF ValType ( aImage ) = 'U'

            DO WHILE ! (WorkArea)->(Eof())
               rcount++
               IF value == (WorkArea)->(RecNo())
                  cset := rcount
               ENDIF
               ComboAddString (ControlHandle, (WorkArea)->&(cField) )
               (WorkArea)->(DBSkip())
            ENDDO

         ELSE

            DO WHILE ! (WorkArea)->(Eof())
               rcount++
               IF value == (WorkArea)->(RecNo())
                  cset := rcount
               ENDIF
               ImageComboAddItem ( ControlHandle , (WorkArea)->&(cImageField) , (WorkArea)->&(cField) , -1 )
               (WorkArea)->(DBSkip())
            ENDDO

         ENDIF

         (WorkArea)->(DBGoTo(BackRec))

         ComboSetCurSel (ControlHandle,cset)

      ENDIF

   ELSE

      IF ValType ( aImage ) == 'U'

         FOR i = 1 to HMG_LEN (rows)
            ComboAddString (ControlHandle,rows[i] )
         NEXT i

      ELSE

         FOR i = 1 to HMG_LEN (rows)
            ImageComboAddItem ( ControlHandle , rows[i][1] , rows[i][2] , -1 )
         NEXT i

      ENDIF

      IF value <> 0
         ComboSetCurSel (ControlHandle,Value)
      ENDIF

   ENDIF

   IF valtype ( ItemSource ) != 'U'

      IF k > 0
         aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , k )
      ELSE
         aAdd ( _HMG_SYSDATA [ 89 ]   [ GetFormIndex ( cParentForm ) ] , HMG_LEN (_HMG_SYSDATA [3]) )
      ENDIF
   ENDIF

   IF ValType ( aImage ) <> 'U'

      _HMG_SYSDATA [ 32 ] [k] := SendMessage( Controlhandle, 1030 , 0 , 0 )

   ENDIF

   RETURN NIL

PROCEDURE _DataComboRefresh (i)

   LOCAL BackRec , WorkArea , cField , cImageField , xCurrentValue , Tmp

   Tmp := _HMG_SYSDATA [ 33 ] [i]
   _HMG_SYSDATA [ 33 ] [i] := Nil

   xCurrentValue := _GetValue ( , , i )

   _HMG_SYSDATA [ 33 ] [i] := Tmp

   cField := _HMG_SYSDATA [  7 ] [i]
   cImageField := _HMG_SYSDATA [  14 ] [i]

   WORKAREA := _HMG_SYSDATA [ 22 ] [i]

   BackRec := (WorkArea)->(RecNo())

   (WorkArea)->(DBGoTop())

   ComboboxReset ( _HMG_SYSDATA [3] [i] )

   IF _HMG_SYSDATA [15] [i] == Nil

      DO WHILE ! (WorkArea)->(Eof())

         ComboAddString ( _HMG_SYSDATA [3] [i] , (WorkArea)->&(cField) )

         (WorkArea)->(DBSkip())

      ENDDO

   ELSE

      DO WHILE ! (WorkArea)->(Eof())
         ComboAddString ( _HMG_SYSDATA [3] [i] , (WorkArea)->&(cField) )
         ImageComboAddItem ( _HMG_SYSDATA [3] [i] , (WorkArea)->&(cImageField) , (WorkArea)->&(cField) , -1 )
         (WorkArea)->(DBSkip())
      ENDDO

   ENDIF

   IF xCurrentValue > 0 .And. xCurrentValue <= (WorkArea)->(LastRec())
      _SetValue ( , , xCurrentValue , i )
   ENDIF

   (WorkArea)->(DBGoTo(BackRec))

   RETURN
