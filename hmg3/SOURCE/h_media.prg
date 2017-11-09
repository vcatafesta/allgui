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

FUNCTION _DefinePlayer(ControlName,ParentForm,file,col,row,w,h,noasw,noasm,noed,nom,noo,nop,sha,shm,shn,shp , HelpId )

   LOCAL hh , mVar , k := 0

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
   ENDIF

   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         col    := col + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         row    := row + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated")
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated")
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   Hh :=InitPlayer ( GetFormHandle(ParentForm)   , ;
      file             , ;
      col             , ;
      row            , ;
      w            , ;
      h            , ;
      noasw            , ;
      noasm            , ;
      noed            , ;
      nom            , ;
      noo            , ;
      nop            , ;
      sha            , ;
      shm            , ;
      shn            , ;
      shp )

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , hh )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1]  [k] := "PLAYER"
   _HMG_SYSDATA [2]  [k] :=  ControlName
   _HMG_SYSDATA [3]  [k] :=  hh
   _HMG_SYSDATA [4]  [k] :=  GetFormHandle(ParentForm)
   _HMG_SYSDATA [  5 ]  [k] :=  0
   _HMG_SYSDATA [  6 ]  [k] :=  ""
   _HMG_SYSDATA [  7 ]  [k] :=  {}
   _HMG_SYSDATA [  8 ]  [k] :=  Nil
   _HMG_SYSDATA [  9 ]  [k] :=  ""
   _HMG_SYSDATA [ 10 ]  [k] :=  ""
   _HMG_SYSDATA [ 11 ]  [k] :=  ""
   _HMG_SYSDATA [ 12 ]  [k] :=  ""
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=  Nil
   _HMG_SYSDATA [ 15 ]  [k] :=  Nil
   _HMG_SYSDATA [ 16 ]   [k] := ""
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  row
   _HMG_SYSDATA [ 19 ]  [k] :=  col
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]  [k] :=  h
   _HMG_SYSDATA [ 22 ]   [k] := 0
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ]  [k] :=  0
   _HMG_SYSDATA [ 27 ]  [k] :=  ''
   _HMG_SYSDATA [ 28 ]  [k] :=  0
   _HMG_SYSDATA [ 29 ]  [k] :=  {.f.,.f.,.f.,.f.}
   _HMG_SYSDATA [ 30 ]   [k] :=  ''
   _HMG_SYSDATA [ 31 ]  [k] :=   0
   _HMG_SYSDATA [ 32 ]  [k] :=   0
   _HMG_SYSDATA [ 33 ]  [k] :=   ''
   _HMG_SYSDATA [ 34 ]  [k] :=   .t.
   _HMG_SYSDATA [ 35 ]  [k] :=   HelpId
   _HMG_SYSDATA [ 36 ]  [k] :=   0
   _HMG_SYSDATA [ 37 ]  [k] :=   0
   _HMG_SYSDATA [ 38 ]  [k] :=   .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   RETURN NIL

FUNCTION PlayWave(wave,r,s,ns,l,nd)

   IF PCount() == 1
      r := .F.
      s := .F.
      ns := .F.
      l := .F.
      nd := .F.
   ENDIF

   c_PlayWave(wave,r,s,ns,l,nd)

   RETURN NIL

FUNCTION PlayWaveFromResource(wave)

   c_PlayWave(wave,.t.,.f.,.f.,.f.,.f.)

   RETURN NIL

FUNCTION _PlayPlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 1 )

   RETURN NIL

FUNCTION _StopPlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 2 )

   RETURN NIL

FUNCTION _PausePlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 3 )

   RETURN NIL

FUNCTION _ClosePlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 4 )

   RETURN NIL

FUNCTION _DestroyPlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 5 )

   RETURN NIL

FUNCTION _EjectPlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 6 )

   RETURN NIL

FUNCTION _SetPlayerPositionEnd ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 7 )

   RETURN NIL

FUNCTION _SetPlayerPositionHome ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 8 )

   RETURN NIL

FUNCTION _OpenPlayer ( ControlName , ParentForm, file )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 9, file )

   RETURN NIL

FUNCTION _OpenPlayerDialog ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 10 )

   RETURN NIL

FUNCTION _PlayPlayerReverse ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 11 )

   RETURN NIL

FUNCTION _ResumePlayer ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 12 )

   RETURN NIL

FUNCTION _SetPlayerRepeatOn ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 13 , .T. )

   RETURN NIL

FUNCTION _SetPlayerRepeatOff ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 13 , .F. )

   RETURN NIL

FUNCTION _SetPlayerSpeed ( ControlName , ParentForm , speed )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , , 14 , speed )

   RETURN NIL

FUNCTION _SetPlayerVolume ( ControlName , ParentForm , volume )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 15 , volume )

   RETURN NIL

FUNCTION _SetPlayerZoom ( ControlName , ParentForm , zoom )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 16 , zoom )

   RETURN NIL

FUNCTION _SetPlayerSeek ( ControlName , ParentForm , seek )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   mcifunc ( h , 20 , seek )

   RETURN NIL

FUNCTION _GetPlayerLength ( ControlName , ParentForm )

   LOCAL h , mVar, nMCILength

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   nMCILength := mcifunc ( h , 17 )

   RETURN( nMCILength )

FUNCTION _GetPlayerPosition ( ControlName , ParentForm )

   LOCAL h , mVar, nMCIPosition

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   nMCIPosition := mcifunc ( h , 18 )

   RETURN( nMCIPosition )

FUNCTION _GetPlayerVolume ( ControlName , ParentForm )

   LOCAL h , mVar, nMCIVolume

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   nMCIVolume := mcifunc ( h , 19 )

   RETURN( nMCIVolume )

FUNCTION _DefineAnimateBox(ControlName,ParentForm,col,row,w,h,autoplay,center,transparent,file , HelpId )

   LOCAL hh , mVar , k := 0

   IF _HMG_SYSDATA [ 264 ] = .T.
      ParentForm := _HMG_SYSDATA [ 223 ]
   ENDIF

   IF _HMG_SYSDATA [ 183 ] > 0
      IF _HMG_SYSDATA [ 240 ] == .F.
         col    := col + _HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]]
         row    := row + _HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]]
         ParentForm := _HMG_SYSDATA [ 332 ] [_HMG_SYSDATA [ 183 ]]
      ENDIF
   ENDIF

   IF .Not. _IsWindowDefined (ParentForm)
      MsgHMGError("Window: "+ ParentForm + " is not defined. Program terminated")
   ENDIF

   IF _IsControlDefined (ControlName,ParentForm)
      MsgHMGError ("Control: " + ControlName + " Of " + ParentForm + " Already defined. Program Terminated")
   ENDIF

   mVar := '_' + ParentForm + '_' + ControlName

   hh:=InitAnimate(GetFormHandle(ParentForm),col,row,w,h,autoplay,center,transparent)

   IF _HMG_SYSDATA [ 265 ] = .T.
      aAdd ( _HMG_SYSDATA [ 142 ] , hh )
   ENDIF

   k := _GetControlFree()

   PUBLIC &mVar. := k

   _HMG_SYSDATA [1] [k] := "ANIMATEBOX"
   _HMG_SYSDATA [2]  [k] :=  ControlName
   _HMG_SYSDATA [3]  [k] :=  hh
   _HMG_SYSDATA [4]   [k] := GetFormHandle(ParentForm)
   _HMG_SYSDATA [  5 ]   [k] := 0
   _HMG_SYSDATA [  6 ]  [k] :=  ""
   _HMG_SYSDATA [  7 ]  [k] :=  {}
   _HMG_SYSDATA [  8 ]  [k] :=  Nil
   _HMG_SYSDATA [  9 ]  [k] :=  ""
   _HMG_SYSDATA [ 10 ]  [k] :=  ""
   _HMG_SYSDATA [ 11 ]  [k] :=  ""
   _HMG_SYSDATA [ 12 ]  [k] :=  ""
   _HMG_SYSDATA [ 13 ]  [k] :=  .F.
   _HMG_SYSDATA [ 14 ]  [k] :=  Nil
   _HMG_SYSDATA [ 15 ]  [k] :=  Nil
   _HMG_SYSDATA [ 16 ]  [k] :=  ""
   _HMG_SYSDATA [ 17 ]  [k] :=  {}
   _HMG_SYSDATA [ 18 ]  [k] :=  row
   _HMG_SYSDATA [ 19 ]  [k] :=  col
   _HMG_SYSDATA [ 20 ]   [k] := w
   _HMG_SYSDATA [ 21 ]   [k] := h
   _HMG_SYSDATA [ 22 ]   [k] := 0
   _HMG_SYSDATA [ 23 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 333 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 24 ]  [k] :=  iif ( _HMG_SYSDATA [ 183 ] > 0 ,_HMG_SYSDATA [ 334 ] [_HMG_SYSDATA [ 183 ]] , -1 )
   _HMG_SYSDATA [ 25 ]  [k] :=  ""
   _HMG_SYSDATA [ 26 ]   [k] := 0
   _HMG_SYSDATA [ 27 ]  [k] :=  ''
   _HMG_SYSDATA [ 28 ]  [k] :=  0
   _HMG_SYSDATA [ 29 ]  [k] :=  {.f.,.f.,.f.,.f.}
   _HMG_SYSDATA [ 30 ]   [k] :=  ''
   _HMG_SYSDATA [ 31 ]  [k] :=   0
   _HMG_SYSDATA [ 32 ]  [k] :=   0
   _HMG_SYSDATA [ 33 ]  [k] :=   ''
   _HMG_SYSDATA [ 34 ]  [k] :=   .t.
   _HMG_SYSDATA [ 35 ]  [k] :=   HelpId
   _HMG_SYSDATA [ 36 ]   [k] :=  0
   _HMG_SYSDATA [ 37 ]  [k] :=   0
   _HMG_SYSDATA [ 38 ]  [k] :=  .T.
   _HMG_SYSDATA [ 39 ] [k] := 0
   _HMG_SYSDATA [ 40 ] [k] := { NIL , NIL , NIL , NIL , NIL , NIL , NIL , NIL }

   IF valtype(file) <> 'U'
      _OpenAnimateBox ( ControlName , ParentForm , File )
   ENDIF

   RETURN NIL

FUNCTION _OpenAnimateBox ( ControlName , ParentForm , FileName )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   openanimate ( h , FileName )

   RETURN NIL

FUNCTION _PlayAnimateBox ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   playanimate ( h )

   RETURN NIL

FUNCTION _SeekAnimateBox ( ControlName , ParentForm , Frame )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   seekanimate ( h , Frame )

   RETURN NIL

FUNCTION _StopAnimateBox ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   stopanimate ( h )

   RETURN NIL

FUNCTION _CloseAnimateBox ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   CLOSEanimate ( h )

   RETURN NIL

FUNCTION _DestroyAnimateBox ( ControlName , ParentForm )

   LOCAL h , mVar

   mVar := '_' + ParentForm + '_' + ControlName
   h := _HMG_SYSDATA [3] [&mVar]
   destroyanimate ( h )

   RETURN NIL

