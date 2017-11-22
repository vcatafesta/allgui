/*--------------------------------------------------------------------------
MINIGUI - Harbour Win32 GUI library source code
Adaptation FiveWin Class TSBrowse 9.0
---------------------------------------------------------------------------*/

#include "minigui.ch"
#include "hbclass.ch"
#include "TSBrowse.ch"

// 03.10.2012
// If it's uncommented:
// - select a row by Shift+DblClick
// - evaluate the block bPreSelect before selection (check of condition for selection)
// #define __EXT_SELECTION__

// 26.05.2017
#ifdef __XHARBOUR__
/* Hash item functions */
#xtranslate hb_Hash( [<x,...>] ) => Hash( <x> )
#xtranslate hb_HSet( [<x,...>] ) => HSet( <x> )
#endif
// If it's uncommented:
// - extended user keys handling
// - evaluate the code block by a key from a hash
#define __EXT_USERKEYS__

EXTERN OrdKeyNo, OrdKeyCount, OrdKeyGoto

#define SB_VERT             1
#define PBM_SETPOS       1026
#define EM_SETSEL         177

#define VK_CONTEXT         93
#define WS_3DLOOK           4    // 0x4L
#define WM_SETFONT         48    // 0x0030
#define WM_LBUTTONDBLCLK  515    // 0x203

// mouse wheel Windows message
#define WM_MOUSEWHEEL     522

// let's save DGroup space
// ahorremos espacio para DGroup
#define nsCol        asTSB[1]
#define nsWidth      asTSB[2]
#define nsOldPixPos  asTSB[3]
#define bCxKeyNo     asTSB[4]
#define bCmKeyNo     asTSB[5]
#define nGap         asTSB[6]
#define nNewEle      asTSB[7]
#define nKeyPressed  asTSB[8]
#define lNoAppend    asTSB[9]
#define nInstance    asTSB[10]

// api maximal vertical scrollbar position
#define MAX_POS                         65535

#define xlWorkbookNormal                -4143
#define xlContinuous                        1
#define xlHAlignCenterAcrossSelection       7

#ifndef __XHARBOUR__
#xcommand TRY                            => BEGIN SEQUENCE WITH {|__o| break(__o) }
#xcommand CATCH [<!oErr!>]               => RECOVER [USING <oErr>] <-oErr->
#xcommand FINALLY                        => ALWAYS
#else
#xtranslate hb_Hour( [<x>] )             => Hour( <x> )
#xtranslate hb_Minute( [<x>] )           => Minute( <x> )
#xtranslate hb_Sec( [<x>] )              => Secs( <x> )
#endif

#xtranslate _DbSkipper => DbSkipper

MEMVAR _TSB_aControlhWnd
MEMVAR _TSB_aControlObjects
MEMVAR _TSB_aClientMDIhWnd

STATIC asTSB := { Nil, Nil, 0, Nil, Nil, 0, 0, Nil, Nil, Nil }
STATIC hToolTip := 0

FUNCTION _DefineTBrowse ( ControlName, ParentFormName, nCol, nRow, nWidth, nHeight,;
      aHeaders, aWidths, bFields, value, fontname,fontsize, tooltip, change,;
      bDblclick , aHeadClick , gotfocus , lostfocus , uAlias , Delete, lNogrid,;
      aImages, aJust , HelpId , bold , italic , underline , strikeout , break ,;
      backcolor , fontcolor , lock , cell , nStyle , appendable , readonly ,;
      valid , validmessages , aColors , uWhen , nId , aFlds, cMsg, lRePaint,;
      lEnum, lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture,;
      lTransparent, uSelector, lEditable, lAutoCol, aColSel )
   LOCAL oBrw, ParentFormHandle, mVar, k
   LOCAL ControlHandle, FontHandle, blInit, aBmp := {}
   LOCAL bRClick, bLClick, hCursor, update, nLineStyle := 1
   LOCAL aTmpColor := Array( 17 )
   LOCAL i, nColums, nLen

   DEFAULT nRow        := 0, ;
      nCol        := 0, ;
      nHeight     := 120, ;
      nWidth      := 240, ;
      value       := 0, ;
      aImages     := {}, ;
      aHeadClick  := {}, ;
      aFlds       := {},;
      aHeaders    := {},;
      aWidths     := {},;
      aPicture    := {},;
      aJust       := {},;
      hCursor     := 0, ;
      cMsg        := "", ;
      UPDATE      := .f., ;
      lNogrid     := .F.,;
      lock        := .F.,;
      appendable  := .F.,;
      lEnum       := .F.,;
      lAutoSearch := .F.,;
      lAutoFilter := .F.,;
      lAutoCol    := .F.

   HB_SYMBOL_UNUSED( break )
   HB_SYMBOL_UNUSED( validmessages )

   IF lNogrid
      nLineStyle := 0
   ENDIF
   IF Len(aHeaders) > 0 .and. ValType(aHeaders[1]) == 'A'
      aHeaders := aHeaders[1]
   ENDIF
   IF Len(aWidths) > 0 .and. ValType(aWidths[1]) == 'A'
      aWidths := aWidths[1]
   ENDIF
   IF Len(aPicture) > 0 .and. ValType(aPicture[1]) == 'A'
      aPicture := aPicture[1]
   ENDIF
   IF Len(aFlds) > 0 .and. ValType(aFlds[1]) == 'A'
      aFlds := aFlds[1]
   ENDIF
   IF ValType(aColSel) != 'U' .and. ValType(aColSel) == 'A'
      IF ValType(aColSel[1]) == 'A'
         aColSel := aColSel[1]
      ENDIF
   ENDIF

   IF valtype(uWhen) == 'B'                                         /* BK    18.05.2015 */
      IF valtype(readonly) != 'A'
         readonly := ! Eval( uWhen )
      ENDIF
      uWhen := Nil                                                  // its needed else will be crash
   ENDIF
   IF valtype(valid) == 'B'
      valid := Eval( valid )
   ENDIF                                                            /* BK end */

   IF ( FontHandle := GetFontHandle( FontName ) ) != 0
      GetFontParamByRef( FontHandle, @FontName, @FontSize, @bold, @italic, @underline, @strikeout )
   ENDIF

   IF Type( '_TSB_aControlhWnd' ) != 'A'
      PUBLIC _TSB_aControlhWnd := {}, _TSB_aControlObjects := {}, _TSB_aClientMDIhWnd := {}

   ENDIF

   IF aColors != Nil .And. ValType( aColors ) == 'A'
      Aeval( aColors, { | bColor, nEle | aTmpColor[ nEle ] := bColor } )
   ENDIF
   IF ValType( fontcolor ) != "U"
      aTmpColor[1] := RGB( fontcolor[1], fontcolor[2], fontcolor[3] )
   ENDIF
   IF ValType( backcolor ) != "U"
      aTmpColor[2] := RGB( backcolor[1], backcolor[2], backcolor[3] )
   ENDIF

   IF _HMG_BeginWindowActive .or. _HMG_BeginDialogActive
      IF _HMG_BeginWindowMDIActive
         ParentFormHandle := GetActiveMdiHandle()
         ParentFormName := _GetWindowProperty ( ParentFormHandle, "PROP_FORMNAME" )
      ELSE
         ParentFormName := if( _HMG_BeginDialogActive, _HMG_ActiveDialogName, _HMG_ActiveFormName )
      ENDIF
      IF .Not. Empty( _HMG_ActiveFontName ) .And. ValType( FontName ) == "U"
         FontName := _HMG_ActiveFontName
      ENDIF
      IF .Not. Empty( _HMG_ActiveFontSize ) .And. ValType( FontSize ) == "U"
         FontSize := _HMG_ActiveFontSize
      ENDIF
   ENDIF
   IF _HMG_FrameLevel > 0
      nCol += _HMG_ActiveFrameCol [_HMG_FrameLevel]
      nRow += _HMG_ActiveFrameRow [_HMG_FrameLevel]
      ParentFormName := _HMG_ActiveFrameParentFormName [_HMG_FrameLevel]
   ENDIF

   IF .Not. _IsWindowDefined (ParentFormName) .And. .Not. _HMG_DialogInMemory
      MsgMiniGuiError("Window: "+ ParentFormName + " is not defined." )
   ENDIF

   IF _IsControlDefined (ControlName,ParentFormName) .And. .Not. _HMG_DialogInMemory
      MsgMiniGuiError ("Control: " + ControlName + " Of " + ParentFormName + " already defined." )
   ENDIF

   IF aImages != Nil .And. ValType( aImages ) == 'A'
      aBmp := Array( Len( aImages ) )
      Aeval( aImages, { | cImage, nEle | aBmp[ nEle ] := LoadImage( cImage ) } )
   ENDIF

   mVar := '_' + ParentFormName + '_' + ControlName
   k := _GetControlFree()

   IF _HMG_BeginDialogActive

      ParentFormHandle := _HMG_ActiveDialogHandle

      nStyle := WS_CHILD + WS_TABSTOP + WS_VISIBLE + WS_CAPTION + WS_BORDER + WS_SYSMENU + WS_THICKFRAME

      IF _HMG_DialogInMemory         // Dialog Template
         IF GetClassInfo( GetInstance(), ControlName ) == nil
            IF !Register_Class(ControlName, CreateSolidBrush(GetRed ( GetSysColor ( COLOR_BTNFACE ) ) , GetGreen ( GetSysColor ( COLOR_BTNFACE ) ), GetBlue ( GetSysColor ( COLOR_BTNFACE ) ) ))

               RETURN NIL
            ENDIF
         ENDIF
         blInit:= {|x,y,z| InitDialogBrowse(x,y,z) }
         aadd(_HMG_aDialogItems,{nId,k,ControlName,nStyle,0,nCol,nRow,nWidth,nHeight,"",HelpId,tooltip,FontName,FontSize,bold,italic,underline,strikeout,blInit,_HMG_BeginTabActive,.f.,_HMG_ActiveTabPage })
         IF _HMG_aDialogTemplate[3]   // Modal

            RETURN NIL
         ENDIF
      ELSE

         ControlHandle := GetDialogItemHandle( ParentFormHandle, nId )
         SetWindowStyle ( ControlHandle, nStyle, .t. )

         nCol := GetWindowCol ( Controlhandle )
         nRow := GetWindowRow ( Controlhandle )
         nWidth := GetWindowWidth  ( Controlhandle )
         nHeight := GetWindowHeight ( Controlhandle )
      ENDIF

   ELSE

      ParentFormHandle := GetFormHandle (ParentFormName)
      hToolTip := GetFormToolTipHandle (ParentFormName)

      oBrw := TSBrowse():New( ControlName, nRow, nCol, nWidth, nHeight,;
         bFields, aHeaders, aWidths, ParentFormName,;
         change , bDblClick, bRClick, fontname, fontsize, ;
         hCursor, aTmpColor , aBmp, cMsg, update, uAlias, uWhen, value, cell,;
         nStyle, bLClick, aFlds, aHeadClick, nLineStyle, lRePaint,;
         Delete, aJust, lock, appendable, lEnum,;
         lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture, ;
         lTransparent, uSelector, lEditable, lAutoCol, aColSel, tooltip )

      IF ( nColums := Len(oBrw:aColumns) ) > 0                           /* BK  18.05.2015 */
         IF Valtype(readonly) == 'A'                                     // sets oCol:bWhen
            nLen := Min(Len(readonly), nColums)
            FOR i := 1 TO nLen
               IF Valtype(readonly[i]) == 'B'
                  oBrw:aColumns[ i ]:bWhen := readonly[i]
               ELSEIF readonly[i] == NIL .or. Empty(readonly[i])
                  oBrw:aColumns[ i ]:bWhen :=  {||.T.}
                  oBrw:aColumns[ i ]:cWhen := '{||.T.}'
               ELSE
                  oBrw:aColumns[ i ]:bWhen :=  {||.F.}
                  oBrw:aColumns[ i ]:cWhen := '{||.F.}'
               ENDIF
            NEXT
         ENDIF
         IF Valtype(valid) == 'A'                                        // sets oCol:bValid
            nLen := Min(Len(valid), nColums)
            FOR i := 1 TO nLen
               IF valtype(valid[ i ]) == 'B'
                  oBrw:aColumns[ i ]:bValid := valid[i]
               ENDIF
            NEXT
         ENDIF
      ENDIF                                                              /* BK end */

      ControlHandle := oBrw:hWnd
      IF ValType(gotfocus) != "U"
         oBrw:bGotFocus := gotfocus
      ENDIF
      IF ValType(lostfocus) != "U"
         oBrw:bLostFocus := lostfocus
      ENDIF
      IF ! lRePaint
         _HMG_ActiveTBrowseName   := ControlName
         _HMG_ActiveTBrowseHandle := ControlHandle
         _HMG_BeginTBrowseActive  := .T.
      ENDIF

   ENDIF

   IF .Not. _HMG_DialogInMemory

      IF _HMG_BeginTabActive
         aAdd ( _HMG_ActiveTabCurrentPageMap , Controlhandle )
      ENDIF

      IF FontHandle != 0
         _SetFontHandle(ControlHandle,FontHandle)
         oBrw:hFont := FontHandle
      ELSE
         IF valtype(fontname) == "U"
            FontName := _HMG_DefaultFontName
         ENDIF
         IF valtype(fontsize) == "U"
            FontSize := _HMG_DefaultFontSize
         ENDIF
         oBrw:hFont := _SetFont (ControlHandle,FontName,FontSize,bold,italic,underline,strikeout)
      ENDIF

   ENDIF

   PUBLIC &mVar. := k

   _HMG_aControlType [k] := "TBROWSE"
   _HMG_aControlNames [k] := ControlName
   _HMG_aControlHandles [k] := ControlHandle
   _HMG_aControlParenthandles [k] := ParentFormHandle
   _HMG_aControlIds  [k] := oBrw
   _HMG_aControlProcedures  [k] := bDblclick
   _HMG_aControlPageMap   [k] := aHeaders
   _HMG_aControlValue   [k] := Value
   _HMG_aControlInputMask   [k] := Lock
   _HMG_aControllostFocusProcedure  [k] :=  lostfocus
   _HMG_aControlGotFocusProcedure  [k] :=  gotfocus
   _HMG_aControlChangeProcedure  [k] :=  change
   _HMG_aControlDeleted   [k] := .F.
   _HMG_aControlBkColor  [k] :=  aImages
   _HMG_aControlFontColor   [k] := Nil
   _HMG_aControlDblClick   [k] := bDblclick
   _HMG_aControlHeadClick   [k] := aHeadClick
   _HMG_aControlRow   [k] := nRow
   _HMG_aControlCol   [k] := nCol
   _HMG_aControlWidth   [k] := nWidth
   _HMG_aControlHeight   [k] := nHeight
   _HMG_aControlSpacing   [k] := uAlias
   _HMG_aControlContainerRow  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameRow [_HMG_FrameLevel] , -1 )
   _HMG_aControlContainerCol  [k] :=  iif ( _HMG_FrameLevel > 0 ,_HMG_ActiveFrameCol [_HMG_FrameLevel] , -1 )
   _HMG_aControlPicture   [k] := Delete
   _HMG_aControlContainerHandle [k] := 0
   _HMG_aControlFontName   [k] := fontname
   _HMG_aControlFontSize   [k] := fontsize
   _HMG_aControlFontAttributes [k] := {bold,italic,underline,strikeout}
   _HMG_aControlToolTip    [k] := tooltip
   _HMG_aControlRangeMin   [k] := 0
   _HMG_aControlRangeMax   [k] :=  {}
   _HMG_aControlCaption  [k] :=   aHeaders
   _HMG_aControlVisible  [k] :=   .T.
   _HMG_aControlHelpId  [k] :=   HelpId
   _HMG_aControlFontHandle   [k] :=  oBrw:hFont
   _HMG_aControlBrushHandle  [k] :=  0
   _HMG_aControlEnabled   [k] :=  .T.
   _HMG_aControlMiscData1 [k] :=  0
   _HMG_aControlMiscData2 [k] :=  ''

   IF _HMG_lOOPEnabled
      Eval ( _HMG_bOnControlInit, k, mVar )
   ENDIF

   RETURN oBrw

FUNCTION _EndTBrowse()

   LOCAL i, oBrw

   IF _HMG_BeginTBrowseActive
      i := ascan ( _HMG_aControlHandles , _HMG_ActiveTBrowseHandle )
      IF i > 0
         oBrw := _HMG_aControlIds [i]
         oBrw:lRePaint := .T.
         oBrw:Display()
         _HMG_ActiveTBrowseName    := ""
         _HMG_ActiveTBrowseHandle  := 0
         _HMG_BeginTBrowseActive   := .F.
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION LoadFields( ControlName, ParentForm, lEdit, aFieldNames )

   LOCAL ix, oBrw

   DEFAULT lEdit := .F.
   ix := GetControlIndex (ControlName, ParentForm)
   oBrw := _HMG_aControlIds [ix]
   IF ISARRAY(aFieldNames)
      oBrw:aColSel := aFieldNames
   ENDIF
   oBrw:LoadFields(lEdit)

   RETURN oBrw

FUNCTION SetArray( ControlName, ParentForm, Arr, lAutoCols, aHead, aSizes )

   LOCAL ix, oBrw

   ix := GetControlIndex (ControlName, ParentForm)
   oBrw := _HMG_aControlIds [ix]
   oBrw:SetArray(Arr, lAutoCols, aHead, aSizes)

   RETURN oBrw

FUNCTION SetArrayTo( ControlName, ParentForm, Arr, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName )

   LOCAL ix, oBrw

   ix := GetControlIndex (ControlName, ParentForm)
   oBrw := _HMG_aControlIds [ix]
   oBrw:SetArrayTo(Arr, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName)

   RETURN oBrw

   * ============================================================================
   * TSBrowse.PRG Version 9.0 Nov/30/2009
   * ============================================================================

   /* This Classs is a recapitulation of the code adapted by Luis Krause Mantilla,
   of FiveWin classes: TCBrowse, TWBrowse, TCColumn and Clipper Wrapers in C
   that support the visual Windows interface.

   Originally TCBrowse was a Sub-Class of TWBrowse, with this work, we have the
   new class "TSBrowse" that is no more a Sub-Class. Now, TSBrowse is an
   independent control that inherits directly from TControl class.

   My work has mainly consisted on putting pieces together with some extra from
   my own crop.

   Credits:
   Luis Krause Mantilla
   Selim Anter
   Stan Littlefield
   Marshall Thomas
   Eric Yang
   John Stolte
   Harry Van Tassell
   Martin Vogel
   Katy Hayes
   Jose Gimenez
   Hernan Diego Ceccarelli ( some ideas taked from his TWBrowse )
   Antonio Carlos Pantaglione ( Toninho@fwi.com.br )
   TSBtnGet is an adaptation of the Ricardo Ramirez TBtnGet Class
   Gianni Santamarina
   Ralph del Castillo
   Daniel Andrade
   Yamil Bracho
   Victor Manuel Tomás (VikThor)
   FiveTechSoft (original classes)

   Many thanks to all of them.

   Regards.

   Manuel Mercado.  July 15th, 2004

   ¡ Aquí vamos ! | ¡ Here we go !...  */

CLASS TSBrowse FROM TControl

   CLASSDATA lRegistered AS LOGICAL

   CLASSDATA aProperties AS ARRAY INIT { "aColumns", "cVarName", "nTop", "nLeft", "nWidth", "nHeight" }

   CLASSDATA lVScroll, lHScroll

   DATA   aActions                                   // actions to be executed on header's click
   DATA   aCheck                                     // stock bitmaps for check box
   DATA   aColors                                    // the whole colors kit
   DATA   aColSel                                    // automatic selected columns creation with databases or recordsets
   DATA   aArray        AS ARRAY                     // browsed array
   DATA   aBitmaps      AS ARRAY INIT {}             // array with bitmaps handles
   DATA   aDefault      AS ARRAY INIT {}             // default values in append mode
   DATA   aClipBoard                                 // used by RButtonDown method
   DATA   aColSizes, aColumns, aHeaders              // the core of TSBrowse
   DATA   aDefValue     AS ARRAY INIT {}             // for array in append mode
   DATA   aIcons        AS ARRAY INIT {}             // array with icons names
   DATA   aImages       AS ARRAY INIT {}             // array with bitmaps names
   DATA   aJustify                                   // compatibility with TWBrowse
   DATA   aLine                                      // bLine as array
   DATA   aMsg          AS ARRAY INIT {}             // multi languaje feature
   DATA   aKeyRemap     AS ARRAY INIT {}             // to prevalidate keys at KeyChar method
   DATA   aPostList                                  // used by ComboWBlock function
   DATA   aSelected                                  // selected items in select mode
   DATA   aSortBmp                                   // stock bitmaps for sort in headers
   DATA   aSuperHead                                 // array with SuperHeads properties
   DATA   aTags                                      // array with dbf index tags
   DATA   aFormatPic                                 // array of picture clause
   DATA   aPopupCol     AS ARRAY INIT {}             // User PopUp menu in Columns ({0} -> all)
   DATA   aEditCellAdjust AS ARRAY INIT { 0,0,0,0 }  // array for correction of edit cell position
   #ifdef __EXT_USERKEYS__
   DATA   aUserKeys     INIT hb_Hash()
   DATA   lUserKeys     INIT .F.
   #endif

   DATA   bBof                                       // codeblock to check if we are before the first record
   DATA   bEof                                       // codeblock to check if we are beyond the last record
   DATA   bAddRec                                    // custom function for adding record (with your own message)
   DATA   bBitMapH                                   // bitmap handle
   DATA   bContext                                   // evaluates windows keyboard context key
   DATA   bBookMark                                  // for xBrowse compatibility
   DATA   bDelete                                    // evaluated after user deletes a row with lCanDelete mode
   DATA   bEvents                                    // custom function for events processing
   DATA   bFileLock                                  // custom function for locking database (with your own message)
   DATA   bGoToPos                                   // scrollbar block
   DATA   bFilter                                    // a simple filter tool
   DATA   bIconDraw, bIconText                       // icons drawing directives
   DATA   bInit                                      // code block to be evaluated on init
   DATA   bKeyCount                                  // ADO keycount block
   DATA   bLine, bSkip, bGoTop, bGoBottom, ;
      bLogicLen, bChange                         // navigation codeblocks
   DATA   bKeyNo                                     // logical position on indexed databases
   DATA   bOnDraw                                    // evaluated in DrawSelect()
   DATA   bOnDrawLine                                // evaluated in DrawLine()
   DATA   bOnEscape                                  // to do something when browse ends through escape key
   DATA   bPostDel                                   // evaluated after record deletion
   DATA   bRecLock                                   // custom function for locking record (with your own message)
   DATA   bRecNo                                     // retrieves or changes physical record position
   DATA   bSeekChange                                // used by seeking feature
   #ifdef __EXT_SELECTION__
   DATA   bPreSelect                                 // to be evaluated before selection for
   // check of condition in select mode.
   // Must return .T. or .F.
   #endif
   DATA   bSelected                                  // to be evaluated in select mode
   DATA   bSetOrder                                  // used by seeking feature
   DATA   bTagOrder                                  // to restore index on GotFocus
   DATA   bLineDrag                                  // evaluated after a dividing line dragging
   DATA   bColDrag                                   // evaluated after a column dragging
   DATA   bUserSearch                                // user code block for AutoSearch
   DATA   bUserFilter                                // user code block for AutoFilter
   DATA   bUserPopupItem                             // user code block for UserPopup
   DATA   bUserKeys                                  // user code block to change the
   // behavior of pressed keys
   DATA   cAlias                                     // data base alias or "ARRAY" or "TEXT_"
   DATA   cDriver                                    // RDD in use
   DATA   cField, uValue1, uValue2                   // SetFilter Params
   DATA   cOrderType                                 // index key type for seeking
   DATA   cPrefix                                    // used by TSBrowse search feature
   DATA   cSeek                                      // used by TSBrowse search feature
   DATA   cFont                                      // new
   DATA   cChildControl                              // new
   DATA   cArray                                     // new
   DATA   cToolTip                                   // tooltip when mouse is over Cells
   DATA   nToolTip      AS NUMERIC INIT 0
   DATA   nToolTipRow   AS NUMERIC INIT 0

   DATA   hBmpCursor    AS NUMERIC                   // bitmap cursor for first column
   DATA   hFontEdit     AS NUMERIC                   // edition font
   DATA   hFontHead     AS NUMERIC                   // header font
   DATA   hFontFoot     AS NUMERIC                   // footer font
   DATA   hFontSpcHd    AS NUMERIC                   // special header font

   DATA   l2007         AS LOGICAL INIT .F.          // new look
   DATA   l3DLook       AS LOGICAL INIT .F. READONLY // internally control state of ::Look3D() in "Phantom" column
   DATA   lHitTop, lHitBottom, lCaptured, lMChange   // browsing flags
   DATA   lAppendMode   AS LOGICAL INIT .F. READONLY // automatic append flag
   DATA   lAutoCol                                   // automatic columns generation from AUTOCOLS clause
   DATA   lAutoEdit     AS LOGICAL INIT .F.          // activates continuous edition mode
   DATA   lAutoSkip     AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lCanAppend    AS LOGICAL INIT .F. READONLY // activates auto append mode
   DATA   lCanDelete    AS LOGICAL INIT .F. HIDDEN   // activates delete capability
   DATA   lCanSelect    AS LOGICAL INIT .F.          // activates select mode
   DATA   lCellBrw                                   // celled browse flag
   DATA   lCellStyle    AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lChanged      AS LOGICAL INIT .F.          // field has changed indicator
   DATA   lClipMore     AS LOGICAL INIT .F.          // ClipMore RDD
   DATA   lColDrag      AS LOGICAL                   // dragging feature
   DATA   lConfirm      AS LOGICAL INIT .T. HIDDEN   // ask for user confirm to delete a row
   DATA   lDescend      AS LOGICAL INIT .F.          // descending indexes
   DATA   lDestroy                                   // flag to destroy bitmap created for selected records
   DATA   lDontChange                                // avoids user to change line with mouse or keyboard
   DATA   lDrawHeaders  AS LOGICAL INIT .T.          // condition for headers drawing
   DATA   lDrawFooters                               // condition for footers drawing
   DATA   lDrawSelect   AS LOGICAL INIT .F.          // flag for selected row drawing
   DATA   lEditable     AS LOGICAL                   // editabe cells in automatic columns creation
   DATA   lEditing      AS LOGICAL INIT .F. READONLY // to avoid lost focus at editing time
   DATA   lDrawSuperHd  AS LOGICAL INIT .F.          // condition for SuperHeader drawing
   DATA   lDrawSpecHd   AS LOGICAL INIT .F.          // condition for SpecHeader drawing
   DATA   lEditingHd    AS LOGICAL INIT .F. READONLY // to avoid lost focus at editing time SpecHd
   DATA   lEditableHd   AS LOGICAL INIT .F.          // activates edition mode of SpecHd on init
   DATA   lFilterMode   AS LOGICAL INIT .F. READONLY // index based filters with NTX RDD
   DATA   lAutoSearch   AS LOGICAL INIT .F. READONLY // condition for SuperHeader as AutoSearch
   DATA   lAutoFilter   AS LOGICAL INIT .F. READONLY // condition for SuperHeader as AutoFilter
   DATA   lHasChgSpec   AS LOGICAL INIT .F.          // SpecHeader data has changed flag for further actions
   DATA   lFirstFocus   HIDDEN                       // controls some actions on init
   DATA   lFirstPaint                                // controls some actions on init
   DATA   lFixCaret     AS LOGICAL                   // TSGet fix caret at editing time
   DATA   lFooting      AS LOGICAL                   // indicates footers can be drawn
   DATA   lNoPaint                                   // to avoid unnecessary painting
   DATA   lGrasp        AS LOGICAL INIT .F. READONLY // used by drag & drop feature
   DATA   lHasChanged   AS LOGICAL INIT .F.          // browsed data has changed flag for further actions
   DATA   lHasFocus     AS LOGICAL INIT .F.          // focused flag
   DATA   lIconView     AS LOGICAL INIT .F.          // compatibility with TCBrowse
   DATA   lInitGoTop                                 // go to top on init, default = .T.
   DATA   lIsArr                                     // browsing an array
   DATA   lIsDbf        AS LOGICAL INIT .F. READONLY // browsed object is a database
   DATA   lIsTxt                                     // browsing a text file
   DATA   lLineDrag     AS LOGICAL                   // TSBrowse dragging feature
   DATA   lLockFreeze   AS LOGICAL                   // avoids cursor positioning on frozen columns
   DATA   lMoveCols     AS LOGICAL                   // Choose between moving or exchanging columns (::moveColumn() or ::exchange())
   DATA   lNoChangeOrd  AS LOGICAL                   // avoids changing active order by double clicking on headers
   DATA   lNoExit       AS LOGICAL INIT .F.          // prevents edit exit with arrow keys
   DATA   lNoGrayBar    AS LOGICAL                   // don't show inactive cursor
   DATA   lNoHScroll    AS LOGICAL                   // disables horizontal scroll bar
   DATA   lNoKeyChar    AS LOGICAL INIT .F.          // no key char
   DATA   lNoLiteBar    AS LOGICAL                   // no cursor
   DATA   lNoMoveCols   AS LOGICAL                   // avoids resize or move columns by the user
   DATA   lNoPopup      AS LOGICAL INIT .T.          // avoids popup menu when right click the column's header
   DATA   lPopupActiv   AS LOGICAL INIT .F.          // defined popup menu when right click the column's header
   DATA   lPopupUser    AS LOGICAL INIT .F.          // activates user defined popup menu
   DATA   lNoResetPos   AS LOGICAL                   // prevents to reset record position on gotfocus
   DATA   lNoVScroll    AS LOGICAL                   // disables vertical scroll bar
   DATA   lLogicDrop    AS LOGICAL                   // compatibility with TCBrowse
   DATA   lPageMode     AS LOGICAL INIT .F.          // paging mode flag
   DATA   lPainted      AS LOGICAL                   // controls some actions on init
   DATA   lRePaint      AS LOGICAL                   // bypass paint if false
   DATA   lPostEdit                                  // to detect postediting
   DATA   lUndo         AS LOGICAL INIT .F.          // used by RButtonDown method
   DATA   lUpdated      AS LOGICAL INIT .F.          // replaces lEditCol return value
   DATA   lUpperSeek    AS LOGICAL INIT .T.          // controls if char expresions are seek in uppercase or not
   DATA   lSeek         AS LOGICAL INIT .T.          // activates TSBrowse seeking feature
   DATA   lSelector     AS LOGICAL INIT .F.          // automatic first column with pointer bitmap
   DATA   lInsertMode                                // flag for switching of Insert mode at editing   //Naz
   DATA   lTransparent                               // flag for transparent browses
   DATA   lEnabled      AS LOGICAL INIT .T.          // enable/disable TSBrowse for displaying data    //JP 1.55
   DATA   lPickerMode   AS LOGICAL INIT .T.          // enable/disable DatePicker Mode in inplace Editing  //MWS Sep 20/07
   DATA   lPhantArrRow  AS LOGICAL INIT .F.          // Flag for initial empty row in array
   DATA   lEnum         AS LOGICAL INIT .F.          // activates SpecHeader as Enumerator

   DATA   nAdjColumn    AS NUMERIC                   // column expands to flush table window right
   DATA   nAligBmp      AS NUMERIC INIT 0            // bitmap layout in selected cell
   DATA   nCell         AS NUMERIC                   // actual column
   DATA   nClrHeadBack, nClrHeadFore                 // headers colors
   DATA   nClrFocuBack, nClrFocuFore                 // focused cell colors
   DATA   nClrEditBack, nClrEditFore                 // editing cell colors
   DATA   nClrFootBack, nClrFootFore                 // footers colors
   DATA   nClrSeleBack, nClrSeleFore                 // selected cell no focused
   DATA   nClrOrdeBack, nClrOrdeFore                 // order control column colors
   DATA   nClrSpcHdBack,nClrSpcHdFore,nClrSpcHdActive // special headers colors
   DATA   nClrSelectorHdBack                         // special selector header background color
   DATA   nClrLine                                   // grid line color
   DATA   nColOrder     AS NUMERIC                   // compatibility with TCBrowse
   DATA   nColPos       AS NUMERIC INIT 0            // grid column position
   DATA   nColSel       AS NUMERIC INIT 0            // column to mark in selected records
   DATA   nColSpecHd    AS NUMERIC                   // activatec editing column of SpecHeader
   DATA   nDragCol      AS NUMERIC INIT 0 HIDDEN     // drag & drop  feature
   DATA   nFireKey                                   // key to start edition, defaults to VK_F2
   DATA   nFirstKey     AS NUMERIC INIT 0 HIDDEN     // First logic pos in filtered databases
   DATA   nFreeze       AS NUMERIC                   // 0,1,2.. freezes left most columns
   DATA   nHeightCell   AS NUMERIC INIT 0            // resizable cell height
   DATA   nHeightHead   AS NUMERIC INIT 0            //      "    header  "
   DATA   nHeightFoot   AS NUMERIC INIT 0            //      "    footer  "
   DATA   nHeightSuper  AS NUMERIC INIT 0            //      "    Superhead  "
   DATA   nHeightSpecHd AS NUMERIC INIT 0            //      "    Special header  "
   DATA   nIconPos                                   // compability with TCBrowse
   DATA   nLastPainted  AS NUMERIC INIT 0 HIDDEN     // last painted nRow
   DATA   nLastPos      AS NUMERIC                   // last record position before lost focus
   DATA   nLastnAt      AS NUMERIC INIT 0 HIDDEN     // last ::nAt value before lost focus
   DATA   nLen          AS NUMERIC                   // total number of browsed items
   DATA   nLineStyle                                 // user definable grid lines style
   DATA   nMaxFilter                                 // maximum number of records to count on index based filters
   DATA   nPopupActiv   AS NUMERIC                   // last activated user popup menu

   DATA   nMemoHE, nMemoWE, nMemoHV, nMemoWV         // memo sizes on edit and view mode
   // Height in lines and Width in pixels
   // default: 3 lines height and 200 pixels width
   DATA   nOldCell      HIDDEN                       // to control column bGotfocus
   DATA   nOffset       AS NUMERIC INIT 0 HIDDEN     // offset marker for text viewer
   DATA   nPaintRow     AS NUMERIC                   // row being painted in DrawLine Method
   DATA   nPhantom      AS NUMERIC INIT PHCOL_GRID   // controls drawing state for "Phantom" column (-1 or -2) inside ::Look3D()
   DATA   nPrevRec                                   // internally used to go previous record back
   DATA   nRowPos, nAt  AS NUMERIC INIT 0            // grid row positions
   DATA   nSelWidth                                  // Selector column's width
   DATA   nLenPos       AS NUMERIC INIT 0            // total number of browsed items in Window  JP 1.31
   DATA   nWheelLines                                // lines to scroll with mouse wheel action
   DATA   nFontSize                                  // New from HMG
   DATA   nMinWidthCols AS NUMERIC INIT 4            // minimal columns width at resizing  GF 1.96
   DATA   nUserKey                                   // user key to change the behavior of pressed keys
   DATA   nSortColDir   AS NUMERIC INIT 0            // Sorting table columns ascending or descending

   DATA   oGet                                       // get object
   DATA   oPhant                                     // phantom column
   DATA   oRSet                                      // recordset toleauto object
   DATA   oTxtFile      AS OBJECT                    // for text files browsing (TTxtFile() class)

   DATA   uBmpSel                                    // bitmap to show in selected records
   DATA   uLastTag                                   // last TagOrder before losing focus
   VAR    nLapsus       AS NUMERIC INIT 0 PROTECTED

METHOD New( cControlName, nRow, nCol, nWidth, nHeight, bLine, aHeaders, aColSizes, cParentWnd,;
      bChange, bLDblClick, bRClick, cFont, nFontSize, hCursor, aColors, aImages, cMsg,;
      lUpdate, uAlias, bWhen, nValue, lCellBrw, nStyle, bLClick, aLine,;
      aActions, nLineStyle, lRePaint, lDelete, aJust, lLock, lAppend, lEnum,;
      lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture,;
      lTransparent, uSelector, lEditable, lAutoCol, aColSel, cTooltip ) CONSTRUCTOR

METHOD AddColumn( oColumn )

METHOD SetColumn( oColumn, nCol )

METHOD AddSuperHead( nFromCol, nToCol, uHead, nHeight, aColors, l3dLook, ;
      uFont, uBitMap, lAdjust, lTransp, ;
      lNoLines, nHAlign, nVAlign )

METHOD BeginPaint() INLINE If( ::lRepaint, ::Super:BeginPaint(), 0 )

METHOD BugUp() INLINE ::UpStable()

METHOD BiClr( uClrOdd, uClrPair )

METHOD Bof() INLINE If( ::bBoF != Nil, Eval( ::bBof ), .F. )

METHOD ChangeFont( hFont, nColumn, nLevel )

METHOD DbSkipper( nToSkip )

METHOD Default()

METHOD Del( nItem )

METHOD DeleteRow( lAll )

METHOD DelColumn( nPos )

METHOD Destroy()

METHOD Display()

METHOD DrawFooters() INLINE ::DrawHeaders( .T. )

   //   MESSAGE DrawIcon METHOD _DrawIcon( nIcon, lFocused )

METHOD DrawIcons()

METHOD DrawLine( xRow )

METHOD DrawPressed( nCell, lPressed )

METHOD DrawSelect( xRow )

METHOD DrawSuper()

METHOD DrawHeaders( lFooters )

METHOD Edit( uVar, nCell, nKey, nKeyFlags, cPicture, bValid, nClrFore, nClrBack )

METHOD EditExit( nCol, nKey, uVar, bValid, lLostFocus )

METHOD EndPaint()   INLINE If( ::lRePaint, ::Super:EndPaint(), ( ::lRePaint := .T., 0 ) )

METHOD Eof() INLINE If( ::bEoF != Nil, Eval( ::bEof ), .F. )

METHOD Excel2( cFile, lActivate, hProgress, cTitle, lSave, bPrintRow )

METHOD ExcelOle( cXlsFile, lActivate, hProgress, cTitle, hFont, lSave, bExtern, aColSel, bPrintRow )

METHOD Exchange( nCol1, nCol2 )  INLINE ::SwitchCols( nCol1, nCol2 ), ::SetFocus()

METHOD ExpLocate( cExp, nCol )

METHOD ExpSeek( cExp, lSoft )

METHOD FreezeCol( lNext )

METHOD GetAllColsWidth()

METHOD GetColSizes() INLINE If( ValType( ::aColSizes ) == "A", ::aColSizes, Eval( ::aColSizes ) )

METHOD GetColumn( nCol )

METHOD GetDlgCode( nLastKey )

METHOD GetRealPos( nRelPos )

METHOD GetTxtRow( nRowPix ) INLINE RowFromPix( ::hWnd, nRowPix, ::nHeightCell, ;
      If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
      If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
      If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
      If( ::lDrawSpecHd, ::nHeightSpecHd, 0 ) )

METHOD GoBottom()

METHOD GoDown()

METHOD GoEnd()

METHOD GoHome()

METHOD GoLeft()

METHOD GoNext()

METHOD GoPos( nNewRow, nNewCol )

METHOD GoRight()

METHOD GotFocus( hCtlLost )

METHOD GoTop()

METHOD GoToRec( nRec )

METHOD GoUp()

METHOD HandleEvent( nMsg, nWParam, nLParam )

METHOD HiliteCell( nCol, nColPix )

METHOD HScroll( nWParam, nLParam )

METHOD HThumbDrag( nPos )

METHOD InsColumn( nPos, oColumn )

METHOD Insert( cItem, nAt )

METHOD AddItem( cItem )

METHOD IsColVisible( nCol )

METHOD IsColVis2( nCol )

METHOD IsEditable( nCol ) INLINE ::lCellBrw .and. ::aColumns[ nCol ]:lEdit .and. ;
      ( ::aColumns[ nCol ]:bWhen == Nil .or. Eval( ::aColumns[ nCol ]:bWhen, Self ) )

METHOD KeyChar( nKey, nFlags )

METHOD KeyDown( nKey, nFlags )

METHOD KeyUp( nKey, nFlags )

METHOD LButtonDown( nRowPix, nColPix, nKeyFlags )

METHOD LButtonUp( nRowPix, nColPix, nFlags )

METHOD lCloseArea() INLINE If( ::lIsDbf .and. ! Empty( ::cAlias ), ( ( ::cAlias )->( DbCloseArea() ), ;
      ::cAlias := "", .T. ), .F. )

METHOD LDblClick( nRowPix, nColPix, nKeyFlags )

METHOD lEditCol( uVar, nCol, cPicture, bValid, nClrFore, nClrBack )

METHOD lIgnoreKey( nKey, nFlags )

METHOD LoadFields( lEditable )

METHOD LoadRecordSet()

METHOD LoadRelated( cAlias, lEditable, aNames, aHeaders )

METHOD Look3D( lOnOff, nColumn, nLevel, lPhantom )

METHOD LostFocus( hCtlFocus )

METHOD lRSeek( uData, nFld, lSoft )

METHOD MButtonDown( nRow, nCol, nKeyFlags )

METHOD MouseMove( nRowPix, nColPix, nKeyFlags )

METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos )

METHOD MoveColumn( nColPos, nNewPos )

METHOD nAtCol( nColPixel, lActual )

METHOD nAtColActual( nColPixel )  //SergKis & Igor Nazarov

METHOD nAtIcon( nRow, nCol )

METHOD nColCount() INLINE Len( ::aColumns )

METHOD nColumn( cName ) INLINE _nColumn( Self, cName )

METHOD nField( cName )

METHOD nLogicPos()

METHOD nRowCount() INLINE CountRows( ::hWnd, ::nHeightCell, If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
      If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
      If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
      If( ::lDrawSpecHd, ::nHeightSpecHd, 0 ) )

METHOD PageUp( nLines )

METHOD PageDown( nLines )

METHOD Paint()

METHOD PanHome()

METHOD PanEnd()

METHOD PanLeft()

METHOD PanRight()

METHOD PostEdit( uTemp, nCol, bValid )

METHOD RButtonDown( nRowPix, nColPix, nFlags )

METHOD Refresh( lPaint, lRecount )

METHOD RelPos( nLogicPos )

METHOD Report( cTitle, aCols, lPreview, lMultiple, lLandscape, lFromPos, aTotal )

METHOD Reset( lBottom )

METHOD ResetSeek()

METHOD ResetVScroll( lInit )

METHOD ReSize( nSizeType, nWidth, nHeight )

METHOD TSBrwScroll( nDir ) INLINE TSBrwScroll( ::hWnd, nDir, ::hFont, ;
      ::nHeightCell, If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
      If( ValType( ::lDrawFooters ) == "L" .and. ;
      ::lDrawFooters , ::nHeightFoot, 0 ), ::nHeightSuper, ::nHeightSpecHd )

METHOD Seek( nKey )

METHOD Selection()

METHOD Set3DText( lOnOff, lRaised, nColumn, nLevel, nClrLight, nClrShadow )

METHOD SetAlign( nColumn, nLevel, nAlign )

METHOD SetAppendMode( lMode )

METHOD SetArray( aArray, lAutoCols, aHead, aSizes )

METHOD SetArrayTo( aArray, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName )

METHOD SetBtnGet( nColumn, cResName, bAction, nBmpWidth )

METHOD SetColMsg( cMsg, cEditMsg, nCol )

METHOD SetColor( xColor1, xColor2, nColumn )

METHOD SetColSize( nCol, nWidth )

METHOD SetColumns( aData, aHeaders, aColSizes )

METHOD SetDeleteMode( lOnOff, lConfirm, bDelete, bPostDel )

METHOD SetHeaders( nHeight, aCols, aTitles, aAlign , al3DLook, aFonts, aActions )

METHOD SetData( nColumn, bData, aList )

METHOD SetFilter( cField, uVal1, uVal2 )

METHOD SetFont( hFont )

METHOD SetIndexCols( nCol1, nCol2, nCol3, nCol4, nCol5 )

METHOD SetItems( aItems ) INLINE ::SetArray( aItems, .T. )

METHOD SetDBF( cAlias )

METHOD SetNoHoles ( nDelta, lSet )  //BK

METHOD SetOrder( nColumn, cPrefix, lDescend )

METHOD SetRecordSet( oRSet )

METHOD SetSelectMode( lOnOff, bSelected, uBmpSel, nColSel, nAlign )

METHOD SetSpinner( nColumn, lOnOff, bUp, bDown, bMin, bMax )

   #ifdef __DEBUG__

METHOD ShowSizes()

   #endif

METHOD Skip( n )

METHOD SortArray( nCol, lDescend )

METHOD SwitchCols( nCol1, nCol2 )

METHOD SyncChild( aoChildBrw, abAction )

METHOD UpAStable()

METHOD UpRStable( nRecNo )

METHOD UpStable()

METHOD Proper( cString )

METHOD VertLine( nColPixPos, nColInit, nGapp )

METHOD VScroll( nMsg, nPos )

METHOD Enabled( lEnab )   //JP 1.55

METHOD HideColumns( nColumn, lHide )  //JP 1.58

METHOD AutoSpec( nCol )

METHOD RefreshARow( xRow )  //JP 1.88

METHOD UserPopup( bUserPopupItem, aColumn )  //JP 1.92

METHOD GetCellInfo( nRowPos, nCell, lColSpecHd )  //BK

   #ifdef __EXT_USERKEYS__

METHOD UserKeys( nKey, bKey, lCtrl, lShift )

   #endif

ENDCLASS

* ============================================================================
* METHOD TSBrowse:New() Version 9.0 Nov/30/2009
* ============================================================================

METHOD New( cControlName, nRow, nCol, nWidth, nHeight, bLine, aHeaders, aColSizes, cParentWnd, ;
      bChange, bLDblClick, bRClick, cFont, nFontSize, ;
      hCursor, aColors, aImages, cMsg, lUpdate, uAlias, ;
      bWhen, nValue, lCellBrw, nStyle, bLClick, aLine, ;
      aActions, nLineStyle, lRePaint, lDelete, aJust, ;
      lLock, lAppend, lEnum, lAutoSearch, uUserSearch, lAutoFilter, uUserFilter, aPicture, ;
      lTransparent, uSelector, lEditable, lAutoCol, aColSel, cTooltip ) CLASS TSBrowse

   LOCAL aSuperHeaders, ParentHandle, ;
      aTmpColor    := Array( 20 ), ;
      cAlias       := "", ;
      lSuperHeader := .f., ;
      hFont

   IF aColors != Nil
      Aeval( aColors, { | bColor, nEle | aTmpColor[ nEle ] := bColor } )
   ENDIF

   DEFAULT nRow            := 0, ;
      nCol            := 0, ;
      nHeight         := 100, ;
      nWidth          := 100, ;
      nLineStyle      := LINES_ALL, ;
      aLine           := {},;
      aImages         := {},;
      cFont           := _HMG_ActiveFontName,;
      nFontSize       := _HMG_ActiveFontSize,;
      nValue          := 0,;
      lDelete         := .F., ;
      lAutoFilter     := .F., ;
      lRepaint        := .T., ;
      lAppend         := .F., ;
      lLock           := .F., ;
      lEnum           := .F., ;
      lAutoSearch     := .F., ;
      lTransparent    := .F., ;
      lEditable       := .F.

   IF _HMG_BeginWindowActive
      cParentWnd := _HMG_ActiveFormName
   ENDIF

   DEFAULT aTmpColor[ 1 ]  := GetSysColor( COLOR_WINDOWTEXT ), ;  // nClrText
   aTmpColor[ 2 ]  := GetSysColor( COLOR_WINDOW )    , ;  // nClrPane
   aTmpColor[ 3 ]  := GetSysColor( COLOR_BTNTEXT )   , ;  // nClrHeadFore
   aTmpColor[ 4 ]  := GetSysColor( COLOR_BTNFACE )   , ;  // nClrHeadBack
   aTmpColor[ 5 ]  := GetSysColor( COLOR_CAPTIONTEXT ), ; // nClrForeFocu
   aTmpColor[ 6 ]  := GetSysColor( COLOR_ACTIVECAPTION )  // nClrFocuBack

   DEFAULT aTmpColor[ 7 ]  := GetSysColor( COLOR_WINDOWTEXT ), ; // nClrEditFore
   aTmpColor[ 8 ]  := GetSysColor( COLOR_WINDOW )    , ; // nClrEditBack
   aTmpColor[ 9 ]  := GetSysColor( COLOR_BTNTEXT )   , ; // nClrFootFore
   aTmpColor[ 10 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrFootBack
   aTmpColor[ 11 ] := CLR_HGRAY                      , ; // nClrSeleFore inactive focused
   aTmpColor[ 12 ] := CLR_GRAY                       , ; // nClrSeleBack inactive focused
   aTmpColor[ 13 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrOrdeFore
   aTmpColor[ 14 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrOrdeBack
   aTmpColor[ 15 ] := GetSysColor( COLOR_BTNSHADOW ) , ; // nClrLine
   aTmpColor[ 16 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSupHeadFore
   aTmpColor[ 17 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSupHeadBack
   aTmpColor[ 18 ] := GetSysColor( COLOR_BTNTEXT )   , ; // nClrSpecHeadFore
   aTmpColor[ 19 ] := GetSysColor( COLOR_BTNFACE )   , ; // nClrSpecHeadBack
   aTmpColor[ 20 ] := CLR_HRED                           // nClrSpecHeadActive

   DEFAULT lUpdate         := .F., ;
      aColSizes       := {}, ;
      lCellBrw        := lEditable

   DEFAULT nStyle := nOr( WS_CHILD, WS_BORDER, WS_VISIBLE,WS_CLIPCHILDREN, WS_TABSTOP, WS_3DLOOK )

   IF lAutoFilter
      aTmpColor[ 19 ] := GetSysColor( COLOR_INACTCAPTEXT )
   ELSEIF lAutoSearch
      aTmpColor[ 19 ] := GetSysColor( COLOR_INFOBK )
   ENDIF
   IF ValType( uAlias ) == "A"
      cAlias := "ARRAY"
      ::cArray:= uAlias
      ::aArray:= {}
   ELSEIF ValType( uAlias ) == "C" .and. "." $ uAlias
      cAlias := "TEXT_" + AllTrim( uAlias )
   ELSEIF ValType( uAlias ) == "C"
      cAlias := Upper( uAlias )
   ELSEIF ValType( uAlias ) == "O"

      IF Upper( uAlias:ClassName() ) == "TOLEAUTO"
         cAlias  := "ADO_"
         ::oRSet := uAlias
      ENDIF
      #ifdef __XHARBOUR__
   ELSEIF ValType( uAlias ) == "H"
      cAlias := "ARRAY"
      uAlias := aHash2Array( uAlias )
      #endif
   ENDIF
   IF _HMG_BeginWindowMDIActive
      ParentHandle :=  GetActiveMdiHandle()
      cParentWnd   := _GetWindowProperty ( ParentHandle, "PROP_FORMNAME" )
   ELSE
      ParentHandle := GetFormHandle (cParentWnd)
   ENDIF

   DO CASE
   CASE ValType( uSelector ) == "C"
      ::lSelector  := .T.
      ::hBmpCursor := LoadImage( uSelector )
   CASE ValType( uSelector ) == "N"
      ::lSelector  := .T.
      ::hBmpCursor := StockBmp( 3 )
      ::nSelWidth  := uSelector
   CASE ValType( uSelector ) == "L" .and. uSelector
      ::lSelector := .T.
      ::hBmpCursor := StockBmp( 3 )
   CASE uSelector != Nil
      ::lSelector := .T.
   ENDCASE

   ::oWnd := Self

   ::cCaption    := ""
   ::cTooltip    := ctooltip
   ::nTop        := nRow
   ::nLeft       := nCol
   ::nBottom     := ::nTop + nHeight - 1
   ::nRight      := ::nLeft + nWidth - 1
   ::oWnd:hWnd   := ParentHandle                  //JP
   ::hWndParent  := ParentHandle                  //JP 1.45
   ::cControlName:= cControlName                  //JP
   ::cParentWnd  := cParentWnd                    //JP

   ::lHitTop     := .F.
   ::lHitBottom  := .F.
   ::lFocused    := .F.
   ::lCaptured   := .F.
   ::lMChange    := .T.
   ::nRowPos     := 1
   ::nAt         := 1
   ::nColPos     := 1
   ::nStyle      := nStyle
   ::lRePaint    := lRePaint
   ::lNoHScroll  := .F.
   ::lNoVScroll  := .F.
   ::lNoLiteBar  := .F.
   ::lNoGrayBar  := .F.
   ::lLogicDrop  := .T. //1.54
   ::lColDrag    := .F.
   ::lLineDrag   := .F.
   ::nFreeze     := 0
   ::aColumns    := {}
   ::nColOrder   := 0
   ::cOrderType  := ""
   ::lFooting    := .F.
   ::nCell       := 1
   ::lCellBrw    := lCellBrw
   ::lMoveCols   := .F.
   ::lLockFreeze := .F.
   ::lCanAppend  := lAppend
   ::lCanDelete  := lDelete
   ::lAppendMode := .F.
   ::aImages     := aImages
   ::aBitmaps    := aImages              //{} if aImages = array handles !!
   ::nId         := ::GetNewId()
   ::cAlias      := cAlias
   ::bLine       := bLine
   ::aLine       := aLine
   ::lAutoEdit   := .F.
   ::lAutoSkip   := .F.
   ::lIconView   := .F.
   ::lCellStyle  := .F.
   ::nIconPos    := 0
   ::lMChange    := .T.
   ::bChange     := bChange
   ::bLClicked   := bLClick
   ::bLDblClick  := bLDblClick
   ::bRClicked   := bRClick
   ::aHeaders    := aHeaders
   ::aColSizes   := aColSizes
   ::aFormatPic  := If( ISARRAY(aPicture), aPicture, {} )
   ::aJustify    := aJust
   ::nLen        := 0
   ::lCaptured   := .F.
   ::lPainted    := .F.
   ::lNoResetPos := .T.
   ::hCursor     := hCursor
   ::cMsg        := cMsg
   ::lUpdate     := lUpdate
   ::bWhen       := bWhen
   ::aColSel     := aColSel
   ::aActions    := aActions
   ::aColors     := aTmpColor
   ::nLineStyle  := nLineStyle
   ::aSelected   := {}
   ::aSuperHead  := {}
   ::lFixCaret   := .F.
   ::lEditable   := lEditable
   ::cFont       := cFont
   ::nFontSize   := nFontSize
   ::lTransparent:= lTransparent
   ::lAutoCol    := lAutoCol
   ::bRecLock    := If( lLock, {|| ( ::cAlias )->( RLock() ) } , ::bRecLock )
   ::lEnum       := lEnum
   ::lAutoSearch := lAutoSearch
   ::lAutoFilter := lAutoFilter
   ::lEditableHd := lAutoSearch .or. lAutoFilter
   ::lDrawSpecHd := lEnum .or. lAutoSearch .or. lAutoFilter
   ::bUserSearch := If( lAutoSearch, uUserSearch, ::bUserSearch )
   ::bUserFilter := If( lAutoFilter, uUserFilter, ::bUserFilter )

   ::SetColor( , aTmpColor )

   ::bBitMapH := &( "{|oBmp|If(oBmp!=Nil,oBmp:hBitMap,0)}" )

   ::lIsDbf := ! EmptyAlias( ::cAlias ) .and. ::cAlias != "ARRAY" .and. ;
      ! ( "TEXT_" $ ::cAlias ) .and. ::cAlias != "ADO_"

   ::lIsArr := ( ::cAlias == "ARRAY" )  // JP 1.66

   ::aMsg := LoadMsg()

   IF Valtype( ::oWnd:hWnd ) != 'U'
      ::Create( ::cControlName )

      IF ::hFont != Nil
         ::SetFont( ::hFont )
         ::nHeightCell := ::nHeightHead := SBGetHeight( ::hWnd, ::hFont, 0 )
      ELSE
         hFont := InitFont( ::cFont, ::nFontSize )  // SergKis addition
         ::nHeightCell := ::nHeightHead := GetTextHeight( 0, "B", hFont ) + 1
         DeleteObject( hFont )
      ENDIF
      ::nHeightFoot := 0
      ::nHeightSpecHd := If( ::lEditableHd, ::nHeightHead, 0 )

      ::lVisible = .T.
      ::lValidating := .F.
      IF ::lIsArr                // JP 1.66
         ::lFirstPaint := .T.
      ENDIF

      IF aHeaders != Nil .And. ValType( aHeaders ) == 'A'
         AEval( aHeaders, { | cHeader | lSuperHeader := ( At('~', cHeader) != 0 ) .or. lSuperHeader } )
         IF lSuperHeader
            aSuperHeaders := IdentSuper( aHeaders, Self )
         ENDIF
      ENDIF

      ::Default()

      IF aSuperHeaders != Nil .And. ValType( aSuperHeaders ) == 'A'
         AEval( aSuperHeaders, { | aHead | ::AddSuperHead( aHead[2], aHead[3], aHead[1], ;
            ::nHeightSuper, { aTmpColor[ 16 ], aTmpColor[ 17 ], aTmpColor[ 15 ] }, ;
            .f., If( ::hFont != Nil, ::hFont, 0 ) ) } )

         ::SetColor( , aTmpColor )
      ENDIF
   ELSE
      ::lVisible = .F.
   ENDIF

   ctooltip := ::cToolTip
   IF Valtype( ctooltip ) == "B"
      ctooltip := Eval( ctooltip, Self )
   ENDIF

   SetToolTip( ::hWnd, cToolTip, hToolTip )

   IF nValue > 0 .and. nValue <= ::nLen
      IF Len( ::aColumns ) > 0                  //JP 1.59
         ::GoPos( nValue )
      ELSE
         ::nAt := nValue
      ENDIF
      IF nValue > 0 .and. nValue <= Eval( ::bLogicLen )  // JP 1.59
         Eval( ::bGoToPos, nValue )
      ENDIF
      ::lInitGoTop := .F.
      ::Super:Refresh( .T. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:AddColumn() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD AddColumn( oColumn ) CLASS TSBrowse

   LOCAL nHeight, nAt, cHeading, cRest, nOcurs, ;
      hFont := If( ::hFont != Nil, ::hFont, 0 )

   DEFAULT ::aColSizes := {}

   IF ::lDrawHeaders
      cHeading := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading, ::nColCount() + 1, Self ), oColumn:cHeading )

      IF Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0
         nOcurs := 1
         cRest := Substr( cHeading, nAt + 2 )

         WHILE ( nAt := At( Chr( 13 ), cRest ) ) > 0
            nOcurs++
            cRest := Substr( cRest, nAt + 2 )
         ENDDO

         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontHead != Nil, oColumn:hFontHead, hFont ), 0 )
         nHeight *= ( nOcurs + 1 )

         IF ( nHeight + 1 ) > ::nHeightHead
            ::nHeightHead := nHeight + 1
         ENDIF
      ENDIF
   ENDIF

   IF ValType( oColumn:cFooting ) $ "CB"
      ::lDrawFooters := If( ::lDrawFooters == Nil, .T., ::lDrawFooters )
      ::lFooting := ::lDrawFooters

      cHeading := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting, ::nColCount() + 1, Self ), oColumn:cFooting )

      IF Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0
         nOcurs := 1
         cRest := Substr( cHeading, nAt + 2 )

         WHILE ( nAt := At( Chr( 13 ), cRest ) ) > 0
            nOcurs++
            cRest := Substr( cRest, nAt + 2 )
         ENDDO

         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, hFont ), 0 )
         nHeight *= ( nOcurs + 1 )

         IF ( nHeight + 1 ) > ::nHeightHead
            ::nHeightFoot := nHeight + 1
         ENDIF
      ELSE
         nHeight := SBGetHeight( ::hWnd, If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, hFont ), 0 ) + 1
         IF nHeight > ::nHeightFoot .and. ::lFooting
            ::nHeightFoot := nHeight
         ENDIF
      ENDIF
   ENDIF

   AAdd( ::aColumns, oColumn )

   IF Len( ::aColSizes ) < Len( ::aColumns )
      AAdd( ::aColSizes, oColumn:nWidth )
   ENDIF

   IF ::aPostList != Nil // from ComboWBlock function

      IF ATail( ::aColumns ):lComboBox

         IF ValType( ::aPostList[ 1 ] ) == "A"
            ATail( ::aColumns ):aItems := ::aPostList[ 1 ]
            ATail( ::aColumns ):aData := ::aPostList[ 2 ]
            ATail( ::aColumns ):cDataType := ValType( ::aPostList[ 2, 1 ] )
         ELSE
            ATail( ::aColumns ):aItems := AClone( ::aPostList )
         ENDIF
      ENDIF

      ::aPostList := Nil

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetColumn() Version 7.0 Oct/10/2007
   * ============================================================================
   // Not included in V90, leaved only for compatibility

METHOD SetColumn( oColumn, nCol ) CLASS TSBrowse

   ::InsColumn( nCol, oColumn )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:AddSuperHead() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD AddSuperHead( nFromCol, nToCol, uHead, nHeight, aColors, l3dLook, uFont, uBitMap, lAdjust, lTransp, ;
      lNoLines, nHAlign, nVAlign ) CLASS TSBrowse

   LOCAL cHeading, nAt, nLheight, nOcurs, cRest, nLineStyle, nClrText, nClrBack, nClrLine, ;
      hFont := If( ::hFont != Nil, ::hFont, 0 )

   DEFAULT lAdjust  := .F., ;
      l3DLook  := ::aColumns[ nFromCol ]:l3DLookHead, ;
      nHAlign  := DT_CENTER, ;
      nVAlign  := DT_CENTER, ;
      lTransp  := .T., ;
      uHead    := ""

   IF Valtype( nFromCol ) == "C"
      nFromCol := ::nColumn( nFromCol )
   ENDIF

   IF Valtype( nToCol ) == "C"
      nToCol := ::nColumn( nToCol )
   ENDIF

   uFont := If( uFont != Nil, If( ValType( uFont ) == "O", uFont:hFont, uFont ), uFont )

   IF ! Empty( ::aColumns )
      hFont := If( ValType( ::aColumns[ nFromCol]:hFontHead ) == "O", ::aColumns[ nFromCol]:hFontHead, ;
         If( ::aColumns[ nFromCol]:hFontHead != Nil, ::aColumns[ nFromCol]:hFontHead, hFont ) )
   ENDIF

   hFont := If( uFont != Nil, uFont, hFont )

   IF ValType( aColors ) == "A"
      ASize( aColors, 3 )

      IF ! Empty( ::aColumns )
         nClrText := If( aColors[ 1 ] != Nil, aColors[ 1 ], ::aColumns[ nFromCol ]:nClrHeadFore )
         nClrBack := If( aColors[ 2 ] != Nil, aColors[ 2 ], ::aColumns[ nFromCol ]:nClrHeadBack )
         nClrLine := If( aColors[ 3 ] != Nil, aColors[ 3 ], ::nClrLine )
      ELSE
         nClrText := If( aColors[ 1 ] != Nil, aColors[ 1 ], ::nClrHeadFore )
         nClrBack := If( aColors[ 2 ] != Nil, aColors[ 2 ], ::nClrHeadBack )
         nClrLine := If( aColors[ 3 ] != Nil, aColors[ 3 ], ::nClrLine )
      ENDIF
   ELSE
      IF ! Empty( ::aColumns )
         nClrText := ::aColumns[ nFromCol ]:nClrHeadFore
         nClrBack := ::aColumns[ nFromCol ]:nClrHeadBack
         nClrLine := ::nClrLine
      ELSE
         nClrText := ::nClrHeadFore
         nClrBack := ::nClrHeadBack
         nClrLine := ::nClrLine
      ENDIF
   ENDIF

   IF uBitMap != Nil .and. ValType( uBitMap ) != "L"

      DEFAULT lNoLines := .T.
      cHeading := If( ValType( uBitMap ) == "B", Eval( uBitMap ), uBitMap )
      cHeading := If( ValType( cHeading ) == "O", Eval( ::bBitMapH, cHeading ), cHeading )
      IF Empty( cHeading )
         MsgStop( "Image is not found!", "Error" )

         RETURN NIL
      ENDIF
      nLHeight := SBmpHeight( cHeading )

      IF nHeight != Nil
         IF nHeight < nLHeight .and. lAdjust
            nLHeight := nHeight
         ELSEIF nHeight > nLheight
            nLHeight := nHeight
         ENDIF
      ENDIF

      IF ( nLHeight + 1 ) > ::nHeightSuper
         ::nHeightSuper := nLHeight + 1
      ENDIF

   ELSE
      uBitMap := Nil
   ENDIF

   cHeading := If( Valtype( uHead ) == "B", Eval( uHead ), uHead )

   DO CASE

   CASE Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0

      DEFAULT lNoLines := .F.

      nOcurs := 1
      cRest := Substr( cHeading, nAt + 2 )

      WHILE ( nAt := At( Chr( 13 ), cRest ) ) > 0
         nOcurs++
         cRest := Substr( cRest, nAt + 2 )
      ENDDO

      nLheight := SBGetHeight( ::hWnd, hFont, 0 )
      nLheight *= ( nOcurs + 1 )
      nLheight := If( nHeight == Nil .or. nLheight > nHeight, nLheight, nHeight )

      IF ( nLheight + 1 ) > ::nHeightSuper
         ::nHeightSuper := nLHeight + 1
      ENDIF

   CASE Valtype( cHeading ) == "C"
      DEFAULT lNoLines := .F.

      nLheight := SBGetHeight( ::hWnd, hFont, 0 )
      nLheight := If( nHeight == Nil .or. nLheight > nHeight, nLheight, nHeight )

      IF ( nLheight + 1 ) > ::nHeightSuper
         ::nHeightSuper := nLHeight + 1
      ENDIF

   CASE Valtype( cHeading ) == "N" .or. ValType( cHeading ) == "O"
      DEFAULT lNoLines := .T.
      uBitMap := uHead

      IF ValType( cHeading ) == "O"
         uHead := Eval( ::bBitMapH, cHeading )
      ENDIF

      nLheight := SBmpHeight( uHead )
      uHead    := ""

      IF nHeight != Nil
         IF nHeight < nLHeight .and. lAdjust
            nLheight := nHeight
         ELSEIF nHeight > nLheight
            nLheight := nHeight
         ENDIF
      ENDIF

      IF ( nLheight + 1 ) > ::nHeightSuper
         ::nHeightSuper := nLHeight + 1
      ENDIF

   ENDCASE

   nLineStyle := If( lNoLines, 0, 1 )

   AAdd( ::aSuperHead, { nFromCol, nToCol, uHead, nClrText, nClrBack, l3dLook, hFont, uBitMap, lAdjust, nLineStyle, ;
      nClrLine, nHAlign, nVAlign, lTransp } )

   IF Len(::aSuperHead) > 0
      ::lDrawSuperHd := .t.
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:BiClr() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD BiClr( uClrOdd, uClrPair ) CLASS TSBrowse

   uClrOdd  := If( ValType( uClrOdd ) == "B", Eval( uClrOdd, Self ), ;
      uClrOdd )

   uClrPair := If( ValType( uClrPair ) == "B", Eval( uClrPair, Self ), ;
      uClrPair )

   RETURN If( ::nAt % 2 > 0, uClrOdd, uClrPair )

   * ============================================================================
   * METHOD TSBrowse:ChangeFont() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ChangeFont( hFont, nColumn, nLevel ) CLASS TSBrowse

   LOCAL nEle, ;
      lDrawFooters := If( ::lDrawFooters != Nil, ::lDrawFooters, .F. )

   DEFAULT nColumn := 0   // all columns

   IF nColumn == 0

      IF nLevel == Nil

         FOR nEle := 1 TO Len( ::aColumns )
            ::aColumns[ nEle ]:hFont := hFont
         NEXT

         IF ::lDrawHeaders

            FOR nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontHead := hFont
            NEXT

         ENDIF

         IF ::lFooting .and. lDrawFooters

            FOR nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontFoot := hFont
            NEXT

         ENDIF

         IF ::lDrawSuperHd

            FOR nEle := 1 TO Len( ::aSuperHead )
               ::aSuperHead[ nEle, 7 ] := hFont
            NEXT

         ENDIF

      ELSE

         DO CASE

         CASE nLevel == 1                                      // nLevel 1 = Cells

            FOR nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFont := hFont
            NEXT

         CASE nLevel == 2  .and. ::lDrawHeaders                // nLevel 2 = Headers

            FOR nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontHead := hFont
            NEXT

         CASE nLevel == 3 .and. ::lFooting .and. lDrawFooters  // nLevel 3 = Footers

            FOR nEle := 1 TO Len( ::aColumns )
               ::aColumns[ nEle ]:hFontFoot := hFont
            NEXT

         CASE nLevel == 4  .and. ::lDrawSuperHd                // nLevel 4 = SuperHeaders

            FOR nEle := 1 TO Len( ::aSuperHead )
               ::aSuperHead[ nEle, 7 ] := hFont
            NEXT

         ENDCASE

      ENDIF

   ELSE

      IF nLevel == Nil

         ::aColumns[ nColumn ]:hFont := hFont

         IF ::lDrawHeaders
            ::aColumns[ nColumn ]:hFontHead := hFont
         ENDIF

         IF ::lFooting .and. lDrawFooters
            ::aColumns[ nColumn ]:hFontFoot := hFont
         ENDIF

         IF ::lDrawSuperHd
            ::aSuperHead[ nColumn, 7 ] := hFont
         ENDIF

      ELSE

         DO CASE

         CASE nLevel == 1                                      // nLevel 1 = Cells
            ::aColumns[ nColumn ]:hFont := hFont
         CASE nLevel == 2 .and. ::lDrawHeaders                 // nLevel 2 = Headers
            ::aColumns[ nColumn ]:hFontHead := hFont
         CASE nLevel == 3 .and. ::lFooting .and. lDrawFooters  // nLevel 3 = Footers
            ::aColumns[ nColumn ]:hFontFoot := hFont
         CASE nLevel == 4 .and. ::lDrawSuperHd                 // nLevel 4 = SuperHeaders
            ::aSuperHead[ nColumn, 7 ] := hFont
         ENDCASE
      ENDIF

   ENDIF

   IF ::lPainted
      SetHeights( Self )
      ::Refresh( .F. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DbSkipper() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DbSkipper( nToSkip ) CLASS TSBrowse

   LOCAL nSkipped := 0, ;
      nRecNo   := ( ::cAlias )->( RecNo() )

   DEFAULT nToSkip := 0, ;
      ::nAt := 1

   IF nToSkip == 0 .or. ( ::cAlias )->( LastRec() ) == 0
      //      ( ::cAlias )->( dbSkip( 0 ) )
   ELSEIF nToSkip > 0 .and. ! ( ::cAlias )->( EoF() ) // going down

      WHILE nSkipped < nToSkip

         ( ::cAlias )->( DbSkip( 1 ) )

         IF ::bFilter != Nil
            WHILE ! Eval( ::bFilter ) .and. ! ( ::cAlias )->( EoF() )
               ( ::cAlias )->( DbSkip( 1 ) )
            ENDDO
         ENDIF

         IF ( ::cAlias )->( Eof() )

            IF ::lAppendMode
               nSkipped ++
            ELSE
               ( ::cAlias )->( DbSkip( -1 ) )
            ENDIF

            EXIT
         ENDIF

         nSkipped ++
      ENDDO
   ELSEIF nToSkip < 0 .and. ! ( ::cAlias )->( BoF() )  // going up

      WHILE nSkipped > nToSkip

         ( ::cAlias )->( DbSkip( -1 ) )

         IF ::bFilter != Nil .and. ! ( ::cAlias )->( BoF() )
            WHILE ! Eval( ::bFilter ) .and. ! ( ::cAlias )->( BoF() )
               ( ::cAlias )->( DbSkip( -1 ) )
            ENDDO

            IF ( ::cAlias )->( BoF() )
               ( ::cAlias )->( DbGoTo( nRecNo ) )

               RETURN nSkipped
            ENDIF
         ENDIF

         IF ( ::cAlias )->( Bof() )
            ( ::cAlias )->( DbGoTop() )
            EXIT
         ENDIF

         nSkipped --
      ENDDO
   ENDIF

   ::nAt += nSkipped

   RETURN nSkipped

   * ============================================================================
   * METHOD TSBrowse:Default() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Default() CLASS TSBrowse

   LOCAL nI, nTemp, nElements, aFields, nHeight, nMin, nMax, nPage, bBlock, aJustify, cBlock, nTxtWid, ;
      nWidth    := 0, ;
      cAlias    := Alias(), ;
      nMaxWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
      hFont     := If( ::oFont != Nil, ::oFont:hFont, 0 ), ;
      nAdj      := ::nAdjColumn, ;
      lAutocol  := If( ::lAutoCol == Nil, .F., ::lAutocol )

   DEFAULT ::aHeaders  := {}, ;
      ::aColSizes := {}, ;
      ::nOldCell  := 1, ;
      ::lIsTxt    := ("TEXT_" $ ::cAlias), ;
      ::lIsArr    := (::cAlias == "ARRAY")

   IF ::bLine == Nil .and. Empty( ::aColumns )

      IF Empty( ::cAlias )
         ::cAlias := cAlias
      ELSE
         cAlias := ::cAlias
      ENDIF

      IF ! EmptyAlias( ::cAlias )
         IF ! ::lIsArr .and. ! ::lIsTxt .and. lAutoCol
            IF ::lIsDbf
               IF Empty( ::nLen )
                  ::SetDbf()
               ENDIF
               ::LoadFields()
            ELSEIF ::cAlias == "ADO_"
               IF Empty( ::nLen )
                  ::SetRecordSet()
               ENDIF
               ::LoadRecordSet()
            ENDIF
         ENDIF
         IF ::lIsArr
            IF Len( ::cArray ) == 0 .and. ValType( ::aHeaders ) == "A"
               ::cArray := Array( 1, Len( ::aHeaders ) )
               AEval( ::aHeaders, { | cHead, nEle | ::cArray[1, nEle] := "???", HB_SYMBOL_UNUSED( cHead ) } )
               ::lPhantArrRow := .T.
            ENDIF
            IF Len( ::cArray ) > 0
               IF ValType( ::cArray[ 1 ] ) != "A"
                  ::SetItems( ::cArray )
               ELSE
                  ::SetArray( ::cArray, .t. )
               ENDIF
            ENDIF
            IF ::lPhantArrRow
               ::Deleterow( .t. )
            ENDIF
         ENDIF
      ENDIF

   ENDIF

   ::lFirstPaint := .F.

   IF ::bLine != Nil .and. Empty( ::aColumns )

      DEFAULT nElements := Len( Eval( ::bLine ) )

      aJustify := Afill( Array( nElements ), 0 )

      IF Len( ::aHeaders ) < nElements

         ::aHeaders := Array( nElements )
         FOR nI := 1 to nElements
            IF At( '->', FieldName( nI ) ) == 0
               ::aHeaders[ nI ] := ( cAlias )->( FieldName( nI ) )
            ELSE
               ::aHeaders[ nI ] := FieldName( nI )
            ENDIF
         NEXT
      ENDIF

      IF ValType( ::aColSizes ) == "B"
         ::aColSizes := Eval( ::aColSizes )
      ENDIF

      aFields := Eval( ::bLine )

      IF Len( ::GetColSizes() ) < nElements
         ::aColSizes := Afill( Array( nElements ), 0 )

         nTxtWid := SBGetHeight( ::hWnd, hFont, 1 )

         FOR nI := 1 TO nElements
            ::aColSizes[ nI ] := If( ValType( aFields[ nI ] ) != "C", 16, ; // Bitmap handle
            ( nTxtWid * Max( Len( ::aHeaders[ nI ] ), Len( aFields[ nI ] ) ) + 1 ) )
         NEXT

      ENDIF

      FOR nI := 1 To nElements

         IF ValType( aFields[ nI ] ) == "N" .or. ValType( aFields[ nI ] ) == "D"
            aJustify[ nI ] := 2
         ELSEIF ValType( aFields[ nI ] ) == "B"

            IF ValType( Eval( aFields[ nI ] ) ) == "N" .or. ValType( Eval( aFields[ nI ] ) ) == "D"

               aJustify[ nI ] := 2
            ELSE
               aJustify[ nI ] := 0
            ENDIF
         ELSE
            aJustify[ nI ] := 0
         ENDIF
      NEXT

      ASize( ::aFormatPic, nElements )  // make sure they match sizes

      FOR nI := 1 To nElements

         bBlock := If( ValType( Eval( ::bLine )[ nI ] ) == "B", Eval( ::bLine )[ nI ], MakeBlock( Self, nI ) )
         cBlock := If( ValType( Eval( ::bLine )[ nI ] ) == "B", ::aLine[ nI ], ;
            "{||" + cValToChar( ::aLine[ nI ] ) + "}" )
         ::AddColumn( TSColumn():New( ::aHeaders[ nI ], bBlock, ::aFormatPic[nI], { ::nClrText, ::nClrPane, ;
            ::nClrHeadFore, ::nClrHeadBack, ::nClrFocuFore, ::nClrFocuBack }, ;
            {aJustify[ nI ], 1}, ::aColSizes[ nI ],, ;
            ::lEditable .or. ValType( Eval( ::bLine )[ nI ] ) == "B",,,,,,, ;
            5,, {.F., .T.},, Self, cBlock ) )

         IF At( '->', ::aLine[ nI ] ) == 0
            ATail( ::aColumns ):cData := ::cAlias + "->" + ::aLine[ nI ]
         ELSE
            ATail( ::aColumns ):cData := ::aLine[ nI ]
         ENDIF
      NEXT

   ENDIF

   ::lIsDbf := ! EmptyAlias( ::cAlias ) .and. ! ::lIsArr .and. ! ::lIsTxt .and. ::cAlias != "ADO_"

   IF ! Empty( ::aColumns )
      ASize( ::aColSizes, Len( ::aColumns ) ) // make sure they match sizes
   ENDIF

   IF ::lIsDbf
      IF Empty( ::nLen )
         ::SetDbf()
      ENDIF
   ENDIF

   // rebuild build the aColSize, it's needed to Horiz Scroll etc
   // and expand selected column to flush table window right

   FOR nI := 1 To Len( ::aColumns )

      nTemp := ( ::aColSizes[ nI ] := If( ::aColumns[ nI ]:lVisible, ::aColumns[ nI ]:nWidth, 0 ) )  //JP 1.58

      IF ! Empty( nAdj ) .and. ( nWidth + nTemp > nMaxWidth )

         IF nAdj < nI
            ::aColumns[ nAdj ]:nWidth := ::aColSizes[ nAdj ] += ( nMaxWidth - nWidth )
         ENDIF

         nAdj := 0

      ENDIF

      nWidth += nTemp

      IF ::lIsDbf .and. ! Empty( ::aColumns[ nI ]:cOrder ) .and. ! ::aColumns[ nI ]:lEdit

         IF ::nColOrder == 0
            ::SetOrder( nI )
         ENDIF

         ::aColumns[ nI ]:lIndexCol := .T.
      ENDIF

      IF ValType( ::aColumns[ nI ]:cFooting ) $ "CB" // informs browse that it has footings to display
         ::lDrawFooters := If( ::lDrawFooters == Nil, .T., ::lDrawFooters )
         ::lFooting := ::lDrawFooters
         nHeight := SBGetHeight( ::hWnd, If( ::aColumns[ nI ]:hFontFoot != Nil, ;
            ::aColumns[ nI ]:hFontFoot, hFont ), 0 ) + 1
         IF nHeight > ::nHeightFoot .and. ::lFooting
            ::nHeightFoot := nHeight
         ENDIF

      ENDIF

   NEXT

   // now catch the odd-ball where last column doesn't fill box
   IF ! Empty( nAdj ) .and. nWidth < nMaxWidth .and. nAdj < nI
      ::aColumns[ nAdj ]:nWidth := ::aColSizes[ nAdj ] += ( nMaxWidth - nWidth )
   ENDIF

   IF ::bLogicLen != Nil
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF

   IF ! ::lNoVScroll
      IF ::nLen <= ::nRowCount()
         nMin := nMax := 0
      ELSE
         nMax  := Min( ::nLen, MAX_POS )
         nPage := Min( ::nRowCount(), ::nLen )
      ENDIF

      ::oVScroll := TSBScrlBar ():WinNew( nMin, nMax, nPage, .T., Self )
   ENDIF

   IF ! Empty( ::cAlias ) .and. ::cAlias != "ADO_" .and. ::bKeyNo != Nil
      ::ResetVScroll( .T. )
   ENDIF

   IF ! ::lNoHScroll
      IF ! Empty( ::cAlias ) .and. ::lIsTxt .and. ::oTxtFile != Nil
         nTxtWid := Max( 1, GetTextWidth( 0, "B", hFont ) )
         nMin := 1
         nMax := ::oTxtFile:nMaxLineLength - Int( nMaxWidth / nTxtWid )
         ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      ELSE
         nMin := Min( 1, Len( ::aColumns ) )
         nMax := Len( ::aColumns )
         ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      ENDIF

   ENDIF

   FOR nI := 1 To Len( ::aColumns )

      IF ::aColumns[ nI ]:hFont == Nil
         ::aColumns[ nI ]:hFont := ::hFont
      ENDIF

      IF ::aColumns[ nI ]:hFontHead == Nil
         ::aColumns[ nI ]:hFontHead := ::hFont
      ENDIF

      IF ::aColumns[ nI ]:hFontFoot == Nil
         ::aColumns[ nI ]:hFontFoot := ::hFont
      ENDIF

      IF ::lLockFreeze .and. ::nFreeze >= nI
         ::aColumns[ nI ]:lNoHilite := .T.
      ENDIF

   NEXT

   ::nHeightHead   := If( ::lDrawHeaders, ::nHeightHead, 0 )
   ::nHeightFoot   := If( ::lFooting .and. ::lDrawFooters, ::nHeightFoot, 0 )
   ::nHeightSpecHd := If( ::nHeightSpecHd ==0 , SBGetHeight( ::hWnd, hFont, 0 ),::nHeightSpecHd)
   ::nHeightSpecHd := If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   IF ! ::lNoVScroll
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll:SetPage( nPage, .T. )
   ENDIF

   IF ! ::lNoHScroll
      nPage := 1
      ::oHScroll:SetPage( nPage, .T. )
   ENDIF

   IF Len( ::aColumns ) > 0
      ::HiliteCell( Max( ::nCell, ::nFreeze + 1 ) )
   ENDIF

   ::nOldCell := ::nCell
   ::nLapsus  := Seconds()

   IF ::nLen == 0
      ::nLen := If( ::bLogicLen == Nil, Eval( ::bLogicLen := {||( cAlias )->( LastRec() ) } ), Eval( ::bLogicLen ) )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:Del() Version 9.0 Nov/30/2009
   * Only for array browse. (ListBox behavior)
   * ============================================================================

METHOD Del( nItem ) CLASS TSBrowse

   DEFAULT nItem := ::nAt

   IF ! ::lIsArr

      RETURN Self
   ENDIF

   hb_ADel( ::aArray, nItem, .T. )

   ::nLen := Eval( ::bLogicLen )
   ::Refresh( .T., .T. )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DelColumn() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DelColumn( nPos ) CLASS TSBrowse

   LOCAL oCol, nMin, nMax, nI, ;
      nLen := Len( ::aSuperHead )

   DEFAULT nPos := 1

   IF Len( ::aColumns ) == 1                     // cannot delete last column

      RETURN NIL                                 // ... or Nil if last column
   ENDIF

   IF Valtype( nPos ) == "C"
      nPos := ::nColumn( nPos )  // 23.07.2015
   ENDIF

   IF nPos < 1
      nPos := 1
   ELSEIF nPos > Len( ::aColumns )
      nPos := Len( ::aColumns )
   ENDIF

   oCol := ::aColumns[ nPos ]
   hb_ADel( ::aColumns, nPos, .T. )
   hb_ADel( ::aColSizes, nPos, .T. )

   IF ::lSelector .and. nPos == 1

      RETURN NIL
   ENDIF

   IF ::nColOrder == nPos                        // deleting a ::SetOrder() column
      ::nColOrder := 0                           // to avoid runtime error
      ::cOrderType := ""
   ELSEIF ::nColOrder != 0 .and. ::nColOrder > nPos .and. ::nColOrder <= Len( ::aColumns )
      ::nColOrder --
   ENDIF

   IF ::nCell > Len( ::aColSizes )
      IF ! ::IsColVisible( ::nCell - 1 )
         ::GoLeft()
      ELSE
         ::nCell--
      ENDIF
   ENDIF

   ::HiliteCell( ::nCell )                       // make sure we have a hilited cell

   IF ! ::lNoHScroll
      nMin := Min( 1, Len( ::aColumns ) )
      nMax := Len( ::aColumns )
      ::oHScroll := TSBScrlBar ():WinNew( nMin, nMax,, .F., Self )
      ::oHScroll:SetRange( 1, Len( ::aColumns ) )
      ::oHScroll:SetPage( 1 , .T. )

      IF ::nCell == Len( ::aColSizes )
         ::oHScroll:GoBottom()
      ELSE
         ::oHScroll:SetPos( ::nCell )
      ENDIF

   ENDIF

   IF ! Empty( ::aSuperHead )

      FOR nI := 1 To nLen

         IF nPos >= ::aSuperHead[ nI, 1 ] .and. nPos <= ::aSuperHead[ nI, 2 ]

            ::aSuperHead[ nI, 2 ] --

            IF ::aSuperHead[ nI, 2 ] < ::aSuperHead[ nI, 1 ]
               ASize( ADel( ::aSuperHead, nI ), Len( ::aSuperHead ) - 1 )
            ENDIF

         ELSEIF nPos < ::aSuperHead[ nI, 1 ]
            ::aSuperHead[ nI, 1 ] --
            ::aSuperHead[ nI, 2 ] --
         ENDIF

      NEXT

   ENDIF

   ::SetFocus()
   ::Refresh( .F. )

   RETURN oCol

   * ============================================================================
   * METHOD TSBrowse:DeleteRow() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DeleteRow(lAll) CLASS TSBrowse

   LOCAL lRecall, lUpStable, nAt, nRowPos, nRecNo, lRefresh, cAlias, lEval, uTemp

   DEFAULT lAll := .f.

   IF ( ! ::lCanDelete .OR. ::nLen == 0 ) .and. ! ::lPhantArrRow  // Modificado por Carlos - Erro Keychar

      RETURN .f.
   ENDIF

   IF ::lIsDbf
      cAlias := ::cAlias
   ENDIF

   nRecNo := ( cAlias  )->( RecNo() )

   lRecall := ! Set( _SET_DELETED )
   lUpStable := ! lRecall

   IF ! ::lIsTxt

      IF ::lConfirm .and. !lAll .and.;
            ! MsgYesNo( If( ::lIsDbf, ::aMsg[ 37 ], ::aMsg[ 38 ] ), ::aMsg[ 39 ] )

         RETURN .f.
      ENDIF

      IF ::lAppendMode

         RETURN .f.
      ENDIF

      ::SetFocus()

      IF ::lIsDbf
         ( cAlias )->( DbGoTo( nRecNo ) )
      ENDIF

      DO CASE

      CASE ::lIsDbf
         lEval := .T.

         IF ::bDelete != Nil
            lEval := Eval( ::bDelete, nRecNo, Self )
         ENDIF

         IF ValType( lEval ) == "L" .and. ! lEval

            RETURN .f.
         ENDIF

         IF !( "SQL" $ ::cDriver )
            IF ! ( cAlias )->( RLock() )
               MsgStop( ::aMsg[ 40 ] , ::aMsg[ 28 ] )

               RETURN .f.
            ENDIF
         ENDIF

         IF ! ( cAlias )->( Deleted() )
            ( cAlias )->( DbDelete() )
            IF !("SQL" $ ::cDriver)
               ( cAlias )->( DbUnlock() )
            ENDIF
            ::nLen := ( cAlias )->( Eval( ::bLogicLen ) )

            IF lUpStable
               ( cAlias )->( DbSkip() )
               lRefresh :=  ( cAlias )->( EOF() )
               ( cAlias )->( DbSkip( -1 ) )
               ::nRowPos -= If( lRefresh .and. ;
                  ! ( cAlias )->( BOF() ), 1, 0 )
               ::Refresh( .T. )
            ENDIF

         ELSEIF lRecall
            ( cAlias )->( DbRecall() )
            ( cAlias )->( DbUnlock() )
         ENDIF

         IF ::lCanAppend .and. ::nLen == 0
            ::nRowPos := ::nColPos := 1
            ::PostMsg( WM_KEYDOWN, VK_DOWN, nMakeLong( 0, 0 ) )
         ENDIF

         IF ::bPostDel != Nil
            Eval( ::bPostDel, Self )
         ENDIF

         ::lHasChanged := .T.

      CASE ::lIsArr

         nAt     := ::nAt
         nRowPos := ::nRowPos
         lEval   := .T.

         IF ::bDelete != Nil .and. ! ::lPhantArrRow
            lEval := Eval( ::bDelete, nAt, Self, lAll )
         ENDIF

         IF ValType( lEval ) == "L" .and. ! lEval

            RETURN .f.
         ENDIF

         IF lAll
            ::aArray := {}
            ::aSelected := {}
            IF  ::nColOrder != 0
               ::aColumns[ ::nColOrder ]:cOrder := ""
               ::aColumns[ ::nColOrder ]:lDescend := Nil
               ::nColOrder := 0
            ENDIF
         ELSE
            hb_ADel( ::aArray, nAt, .T. )
            IF ::lCanSelect .and. Len( ::aSelected ) > 0
               IF ( uTemp := AScan( ::aSelected, nAt ) ) > 0
                  hb_ADel( ::aSelected, uTemp, .T. )
               ENDIF
               AEval( ::aSelected, {|x,nEle| ::aSelected[nEle] := If(x > nAt, x-1, x)} )
            ENDIF
         ENDIF

         IF Len( ::aArray ) == 0
            ::aArray := { AClone( ::aDefValue ) }
            ::lPhantArrRow := .T.
            IF ::aArray[ 1, 1 ] == Nil
               hb_ADel( ::aArray[ 1 ], 1, .T. )
            ENDIF
         ENDIF

         IF ::bPostDel != Nil
            Eval( ::bPostDel, Self )
         ENDIF

         ::lHasChanged := .T.
         ::nLen        := Len( ::aArray )
         ::nAt         := Min( nAt, ::nLen )
         ::nRowPos     := Min( nRowPos, ::nLen )

         ::Refresh( ::nLen < ::nRowCount() )
         ::DrawSelect()
         IF lAll
            ::DrawHeaders()
         ENDIF

      ENDCASE

   ELSE
      ::SetFocus()
      ::DrawSelect()
   ENDIF

   RETURN ::lHasChanged

   * ============================================================================
   * METHOD TSBrowse:Destroy() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Destroy() CLASS TSBrowse

   LOCAL i

   DEFAULT ::lDestroy := .F.

   IF ::uBmpSel != Nil .and. ::lDestroy
      DeleteObject ( ::uBmpSel )
   ENDIF

   IF ::hBrush != Nil   // Alen Uzelac 13.09.2012
      DeleteObject ( ::hBrush )
   ENDIF

   IF ::oCursor != Nil  // GF 29.02.2016
      ::oCursor:End()
   ENDIF

   IF ::hBmpCursor != Nil
      DeleteObject ( ::hBmpCursor )
   ENDIF

   IF ::aSortBmp != Nil
      DeleteObject ( ::aSortBmp[ 1 ] )
      DeleteObject ( ::aSortBmp[ 2 ] )
   ENDIF

   IF ::aCheck != Nil
      DeleteObject ( ::aCheck[ 1 ] )
      DeleteObject ( ::aCheck[ 2 ] )
   ENDIF

   IF Len( ::aColumns ) > 0
      FOR i := 1 To Len( ::aColumns )
         IF Valtype( ::aColumns[ i ]:aCheck ) == "A"
            AEval( ::aColumns[ i ]:aCheck, {|hBmp| If( Empty( hBmp ), , DeleteObject( hBmp ) ) } )
         ENDIF
         IF Valtype( ::aColumns[ i ]:aBitMaps ) == "A"
            AEval( ::aColumns[ i ]:aBitMaps, {|hBmp| If( Empty( hBmp ), , DeleteObject( hBmp ) ) } )
         ENDIF
      NEXT
   ENDIF
   #ifndef _TSBFILTER7_
   IF ::lFilterMode
      ::lFilterMode := .F.
      IF Select( ::cAlias ) != 0
         ::SetFilter()
      ENDIF
   ENDIF
   #endif
   ::hWnd := 0

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:Display() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Display() CLASS TSBrowse

   DEFAULT ::lFirstPaint := .T.

   IF Empty( ::aColumns ) .and. ! ::lFirstPaint

      RETURN 0
   ENDIF

   ::BeginPaint()
   ::Paint()
   ::EndPaint()

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:DrawHeaders() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DrawHeaders( lFooters ) CLASS TSBrowse

   LOCAL nI, nJ, nBegin, nStartCol, oColumn, l3DLook, nClrFore, lAdjBmp, nAlign, nClrBack, hFont, cFooting, ;
      cHeading, hBitMap, nLastCol, lMultiLine, nVertText, nClrTo, lOpaque, lBrush, nClrToS, nClrBackS, lOrder, lDescend, ;
      nMaxWidth    := ::nWidth() , ;
      aColSizes    := AClone( ::aColSizes ), ;   // use local copies for speed
   nHeightHead  := ::nHeightHead, ;
      nHeightFoot  := ::nHeightFoot, ;
      nHeightSpecHd:= ::nHeightSpecHd

   LOCAL nHeightSuper := ::nHeightSuper, ;
      nVAlign      := 1, ;
      l3DText, nClr3dL, nClr3dS

   LOCAL hWnd         := ::hWnd, ;
      hDC          := ::hDc, ;
      nClrText     := ::nClrText, ;
      nClrPane     := ::nClrPane, ;
      nClrHeadFore := ::nClrHeadFore, ;
      nClrHeadBack := ::nClrHeadBack, ;
      nClrFootFore := ::nClrFootFore, ;
      nClrFootBack := ::nClrFootBack, ;
      nClrOrdeFore := ::nClrOrdeFore, ;
      nClrOrdeBack := ::nClrOrdeBack, ;
      nClrSpcHdFore:= If( ::lEnum, ::nClrHeadFore, ::nClrText ),;
      nClrSpcHdBack:= If( ::lEnum, ::nClrHeadBack, ::nClrPane ),;
      nClrSpcHdAct := ::nClrSpcHdActive,;
      nClrLine     := ::nClrLine

   DEFAULT lFooters := .F.

   IF Empty( ::aColumns )

      RETURN Self
   ENDIF

   IF ::aColSizes == Nil .or. Len( ::aColSizes ) < Len( ::aColumns )
      ::aColSizes := {}
      FOR nI := 1 To Len( ::aColumns )
         AAdd( ::aColSizes, If( ::aColumns[ nI ]:lVisible, ::aColumns[ nI ]:nWidth, 0 ) )   //JP 1.58
      NEXT
   ENDIF

   IF ::lMChange   //GF 1.96
      FOR nI := 1 To Len( ::aColumns )
         IF ::aColumns[ nI ]:lVisible
            aColSizes[ nI ] := Max(::aColumns[ nI ]:nWidth, ::nMinWidthCols)
            ::aColumns[ nI ]:nWidth := aColSizes[ nI ]
            ::aColSizes[ nI ] := aColSizes[ nI ]
         ENDIF
      NEXT
   ENDIF

   nClrBack := If( ::nPhantom == -1, ATail( ::aColumns ):nClrHeadBack, nClrPane )
   nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
   nClrFore := If( ::nPhantom == -1, ATail( ::aColumns ):nClrFootBack, nClrPane )
   nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore ), nClrFore )
   l3DLook  := If( ::nPhantom == -1, ATail( ::aColumns ):l3DLookHead, .F. )

   IF ::oPhant == Nil
      // "Phantom" column; :nPhantom hidden IVar
      ::oPhant := TSColumn():New(   "", ; // cHeading
      {|| "" }, ; // bdata
      nil, ; // cPicture
      { nClrText, nClrPane,, ;
         nClrBack,,,,,,nClrFore }, ; // aColors
      nil, ; // aAlign
      ::nPhantom, ; // nWidth
      nil, ; // lBitMap
      nil, ; // lEdit
      nil, ; // bValid
      .T., ; // lNoLite
      nil, ; // cOrder
      nil, ; // cFooting
      nil, ; // bPrevEdit
      nil, ; // bPostEdit
      nil, ; // nEditMove
      nil, ; // lFixLite
      { l3DLook, l3DLook }, ;
         nil, ;
         Self  )
   ELSE
      ::oPhant:nClrFore := nClrText
      ::oPhant:nClrBack := nClrBack
      ::oPhant:nWidth   := ::nPhantom
      ::oPhant:l3DLookHead := l3DLook
   ENDIF

   nLastCol := Len( ::aColumns ) + 1
   AAdd( aColSizes, ::nPhantom )

   nJ := nStartCol := 0

   nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
      ::nColPos - ::nFreeze ), nLastCol )

   IF Empty( ::aColumns )

      RETURN Self
   ENDIF

   IF ! Empty( ::aSuperHead ) .and. ! lFooters
      ::DrawSuper()
   ENDIF

   FOR nI := nBegin To nLastCol

      IF nStartCol > nMaxWidth
         EXIT
      ENDIF

      nJ := If( nI < ::nColPos, nJ + 1, nI )

      oColumn := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )
      IF ::lDrawHeaders .and. ! lFooters

         nVertText := 0
         lOrder    := ::nColOrder == nJ
         lDescend  := oColumn:lDescend

         IF LoWord( oColumn:nHAlign ) == DT_VERT
            cHeading := "Arial"

            hFont := InitFont ( cHeading, -11, .f., .f., .f. , .f. , 900 )

            nVAlign   := 2
            nVertText := 1

         ELSE
            hFont    := If( oColumn:hFontHead == Nil, ::hFont, oColumn:hFontHead )
            hFont    := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), ;
               hFont )
         ENDIF

         l3DLook := oColumn:l3DLookHead
         nAlign  := If( ValType( oColumn:nHAlign ) == "B", ;
            Eval( oColumn:nHAlign, nJ, Self ), oColumn:nHAlign )

         IF ( nClrFore := If( ::nColOrder == nI, oColumn:nClrOrdeFore, ;
               oColumn:nClrHeadFore ) ) == Nil
            nClrFore := If( ::nColOrder == nI, nClrOrdeFore, ;
               nClrHeadFore )
         ENDIF

         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )
         IF !( nJ == 1 .and. ::lSelector )
            IF ( nClrBack := If( ::nColOrder == nI, oColumn:nClrOrdeBack, oColumn:nClrHeadBack ) ) == Nil
               nClrBack := If( ::nColOrder == nI, nClrOrdeBack, nClrHeadBack )
            ENDIF
         ELSE
            nClrBack := iif( ::nClrSelectorHdBack == Nil, ATail( ::aColumns ):nClrHeadBack, ::nClrSelectorHdBack )
         ENDIF

         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, nJ, Self ), nClrBack )

         lBrush   := Valtype( nClrBack ) == "O"

         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         ELSE
            nClrTo   := nClrBack
         ENDIF
         IF lOrder
            DEFAULT lDescend := .F., ::aSortBmp := { StockBmp( 4 ), StockBmp( 5 ) }
            hBitMap := ::aSortBmp[ If( lDescend, 2, 1 ) ]
            nAlign  := nMakeLong( If( nAlign == DT_RIGHT, DT_LEFT, nAlign ), DT_RIGHT )
         ELSE
            hBitMap    := If( ValType( oColumn:uBmpHead ) == "B", Eval( oColumn:uBmpHead, nJ, Self ), oColumn:uBmpHead )
            hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         ENDIF

         cHeading   := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading, nJ, Self ), oColumn:cHeading )
         lAdjBmp    := oColumn:lAdjBmpHead
         lOpaque    := .T. //oColumn:nOpaque == 2
         lMultiLine := ( Valtype( cHeading ) == "C" .and. At( Chr( 13 ), cHeading ) > 0 )
         DEFAULT hBitMap := 0

         IF lMultiLine
            nVAlign := DT_TOP
         ENDIF

         IF oColumn:l3DTextHead != Nil
            l3DText := oColumn:l3DTextHead
            nClr3dL := oColumn:nClr3DLHead
            nClr3dS := oColumn:nClr3DSHead
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         ELSE
            l3DText := nClr3dL := nClr3dS := Nil
         ENDIF

         TSDrawCell(      hWnd, ;  // 1
         hDC, ;  // 2
         0, ;  // 3
         nStartCol, ;  // 4
         aColSizes[ nJ ], ;  // 5
         cHeading, ;  // 6
         nAlign, ;  // 7
         nClrFore, ;  // 8
         nClrBack, ;  // 9
         hFont, ;  // 10
         hBitMap, ;  // 11
         nHeightHead, ;  // 12
         l3DLook, ;  // 13
         1, ;  // 14 nLineStyle
         nClrLine, ;  // 15
         1, ;  // 16 1=Header 2=Footer 3=Super 4=Special
         nHeightHead, ;  // 17
         nHeightFoot, ;  // 18
         nHeightSuper, ;  // 19
         nHeightSpecHd, ;  // 20
         lAdjBmp, ;  // 21
         lMulTiLine, ;  // 22
         nVAlign, ;  // 23
         nVertText, ;  // 24
         nClrTo, ;  // 25
         lOpaque, ;  // 26
         If( lBrush, ;
            nClrBack:hBrush, 0 ), ;  // 27
         l3DText, ;  // 28  3D text
         nClr3dL, ;  // 29  3D text light color
         nClr3dS )   // 30  3D text shadow color

         nVAlign := 1

         IF LoWord( oColumn:nHAlign ) == DT_VERT
            DeleteObject( hFont )
         ENDIF

      ENDIF

      IF ::lDrawSpecHd

         hFont    := If( oColumn:hFontSpcHd == Nil, ::hFont, oColumn:hFontSpcHd )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), hFont )

         l3DLook := oColumn:l3DLookHead
         nAlign  := If( ValType( oColumn:nSAlign ) == "B", Eval( oColumn:nSAlign, nJ, Self ), oColumn:nSAlign )

         IF ( nClrFore := If( ::nColOrder == nI, oColumn:nClrOrdeFore, oColumn:nClrSpcHdFore ) ) == Nil
            nClrFore := If( ::nColOrder == nI, nClrOrdeFore, nClrSpcHdFore )
         ENDIF

         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )

         nClrBacks := If( ::nPhantom == -1, ATail( ::aColumns ):nClrSpcHdBack, nClrPane )
         nClrBackS := If( ValType( nClrBackS ) == "B", Eval( nClrBackS, nJ, Self ), nClrBackS )
         lBrush := Valtype( nClrBackS ) == "O"

         IF ValType( nClrBackS ) == "A"
            nClrToS   := nClrBackS[ 2 ]
            nClrBackS := nClrBackS[ 1 ]
            nClrToS := If( ValType( nClrToS ) == "B", Eval( nClrToS ), nClrToS )
            nClrBackS := If( ValType( nClrBackS ) == "B", Eval( nClrBackS ), nClrBackS )
         ELSE
            nClrToS := nClrBackS
         ENDIF
         IF ::lEnum
            cHeading   := AllTrim(Str(nI - iif(::lSelector, 1, 0)))
            IF nI == nBegin .and. ::lSelector .or. nI == nLastCol
               cHeading := ""
            ENDIF
         ELSE
            cHeading := If( Valtype( oColumn:cSpcHeading ) == "B", Eval( oColumn:cSpcHeading, nJ, Self ), oColumn:cSpcHeading )
            IF Empty( oColumn:cPicture  )
               cHeading := If( Valtype( cHeading ) != "C", cValToChar( cHeading ), cHeading )
            ELSE
               cHeading := If( cHeading == NIL, "", Transform( cHeading, oColumn:cPicture ) )
            ENDIF

            nAlign := oColumn:nAlign
            nClrBackS := If( Empty(cHeading), nClrBackS, CLR_HRED )
            nClrBackS := If( oColumn:lEditSpec, nClrBackS, nClrBack )
            nClrToS   := If( oColumn:lEditSpec, nClrToS  , nClrTo )
         ENDIF
         IF nI == nLastCol
            nClrBackS := If( ::nPhantom == PHCOL_GRID, nClrBackS, ::nClrPane )
            nClrTo    := nClrBackS
         ENDIF
         hBitMap := If( ValType( oColumn:uBmpSpcHd ) == "B", Eval( oColumn:uBmpSpcHd, nJ, Self ), oColumn:uBmpSpcHd )
         hBitMap := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lAdjBmp := oColumn:lAdjBmpSpcHd
         lOpaque := .t.
         DEFAULT hBitMap := 0

         IF oColumn:l3DTextHead != Nil
            l3DText := oColumn:l3DTextSpcHd
            nClr3dL := oColumn:nClr3DLSpcHd
            nClr3dS := oColumn:nClr3DSSpcHd
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         ELSE
            l3DText := nClr3dL := nClr3dS := Nil
         ENDIF

         TSDrawCell(     hWnd, ;  // 1
         hDC, ;  // 2
         0, ;  // 3
         nStartCol, ;  // 4
         aColSizes[nJ], ;  // 5
         cHeading, ;  // 6
         nAlign, ;  // 7
         nClrFore, ;  // 8
         nClrBackS, ;  // 9
         hFont, ;  // 10
         hBitMap, ;  // 11
         0, ;  // 12  nHeightFoot
         l3DLook, ;  // 13
         1, ;  // 14  nLineStyle
         nClrLine, ;  // 15
         4, ;  // 16  1=Header 2=Footer 3=Super  4=Special
         nHeightHead, ;  // 17
         nHeightFoot, ;  // 18
         nHeightSuper, ;  // 19
         nHeightSpecHd, ;  // 20
         lAdjBmp, ;  // 21
         .f., ;  // 22
         nVAlign, ;  // 23
         0, ;  // 24 nVertText
         nClrToS, ;  // 25
         lOpaque, ;  // 26
         If( lBrush, ;
            nClrBackS:hBrush, 0 ), ;  // 27
         l3DText, ;  // 28  3D text
         nClr3dL, ;  // 29  3D text light color
         nClr3dS )   // 30  3D text shadow color

      ENDIF

      IF ::lFooting .and. ::lDrawFooters

         hFont   := If( oColumn:hFontFoot == Nil, ::hFont, oColumn:hFontFoot )
         hFont   := If( ValType( hFont ) == "B", Eval( hFont, 0, nJ, Self ), hFont )
         l3DLook := oColumn:l3DLookFoot

         ::oPhant:l3DLookFoot := l3DLook

         nAlign   := If( ValType( oColumn:nFAlign ) == "B", Eval( oColumn:nFAlign ), oColumn:nFAlign )
         nClrFore := If( oColumn:nClrFootFore != Nil, oColumn:nClrFootFore , nClrFootFore )
         nClrFore := If( ValType( nClrFore ) == "B", Eval( nClrFore, nJ, Self ), nClrFore )
         IF !( nJ == 1 .and. ::lSelector )    //JP
            nClrBack := If( oColumn:nClrFootBack != Nil, oColumn:nClrFootBack, nClrFootBack )
         ELSE
            nClrBack := ATail( ::aColumns ):nClrFootBack
         ENDIF
         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, nJ, Self ), nClrBack )

         lBrush := Valtype( nClrBack ) == "O"

         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         ELSE
            nClrTo := nClrBack
         ENDIF

         IF nI == nBegin .and. ::lSelector   //JP
            cFooting := ""
         ELSE
            cFooting := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting, nJ, Self ), oColumn:cFooting )
         ENDIF

         IF ValType( cFooting ) == "O"
            oColumn:uBmpFoot := cFooting
            cFooting := ""
         ENDIF

         hBitMap    := If( ValType( oColumn:uBmpFoot ) == "B", Eval( oColumn:uBmpFoot, nJ, Self ), oColumn:uBmpFoot )
         hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lOpaque    := .t.
         lAdjBmp    := oColumn:lAdjBmpFoot
         lMultiLine := Valtype( cFooting ) == "C" .and. At( Chr( 13 ), cFooting ) > 0
         DEFAULT hBitMap := 0

         IF oColumn:l3DTextFoot != Nil
            l3DText := oColumn:l3DTextFoot
            nClr3dL := oColumn:nClr3DLFoot
            nClr3dS := oColumn:nClr3DSFoot
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nJ, Self ), nClr3dS )
         ELSE
            l3DText := nClr3dL := nClr3dS := Nil
         ENDIF

         TSDrawCell(     hWnd, ;  // 1
         hDC, ;  // 2
         ::nRowCount(), ;  // 3
         nStartCol, ;  // 4
         aColSizes[nJ], ;  // 5
         cFooting, ;  // 6
         nAlign, ;  // 7
         nClrFore, ;  // 8
         nClrBack, ;  // 9
         hFont, ;  // 10
         hBitMap, ;  // 11
         nHeightFoot, ;  // 12
         l3DLook, ;  // 13
         1, ;  // 14  nLineStyle
         nClrLine, ;  // 15
         2, ;  // 16  1=Header 2=Footer 3=Super
         nHeightHead, ;  // 17
         nHeightFoot, ;  // 18
         nHeightSuper, ;  // 19
         nHeightSpecHd, ;  // 20
         lAdjBmp, ;  // 21
         lMultiLine, ;  // 22
         nVAlign, ;  // 23
         0, ;  // 24 nVertText
         nClrTo, ;  // 25
         lOpaque, ;  // 26
         If( lBrush, ;
            nClrBack:hBrush, 0 ), ;  // 27
         l3DText, ;  // 28  3D text
         nClr3dL, ;  // 29  3D text light color
         nClr3dS )   // 30  3D text shadow color
      ENDIF

      nStartCol += aColSizes[nJ]

   NEXT

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DrawIcons() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DrawIcons() CLASS TSBrowse

   LOCAL cText,  ;
      nWidth := ::nWidth(), ;
      nHeight := ::nHeight(), ;
      nRow := 10, ;
      nCol := 10, ;
      n := 1

   LOCAL nIcons := Int( nWidth / 50 ) * Int( nHeight / 50 ), ;
      hIcon := ExtractIcon( "user.exe", 0 )

   SetBkColor( ::hDC, CLR_BLUE )
   SetTextColor( ::hDC, CLR_WHITE )

   WHILE n <= nIcons .and. ! ( ::cAlias )->( EoF() )
      IF ::bIconDraw != nil .and. ::aIcons != nil
         hIcon := ::aIcons[ Eval( ::bIconDraw, Self ) ]
      ENDIF

      DrawIcon( ::hDC, nRow, nCol, hIcon )

      IF ::bIconText != nil
         cText := cValToChar( Eval( ::bIconText, Self ) )
      ELSE
         cText := Str( ( ::cAlias )->( RecNo() ) )
      ENDIF

      DrawText( ::hDC, cText, { nRow + 35, nCol - 5, nRow + 48, nCol + 40 }, 1 )

      nCol += 50

      IF nCol >= nWidth - 32
         nRow += 50
         nCol := 10
      ENDIF

      ( ::cAlias )->( DbSkip() )
      n ++

   ENDDO

   ( ::cAlias )->( DbSkip( 1 - n ) )

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:DrawLine() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DrawLine( xRow ) CLASS TSBrowse

   LOCAL nI, nJ, nBegin, nStartCol, oColumn, hBitMap, cPicture, hFont, nClrTo, nClrFore, nClrBack, uData, nLastCol, ;
      lAdjBmp, lMultiLine, nAlign, lOpaque, lBrush, lCheck, uBmpCell, nVertText, lSelected, ;
      nVAlign     := 1, ;
      nMaxWidth   := ::nWidth(), ;
      nRowPos     := ::nRowPos, ;
      nClrText    := ::nClrText, ;
      nClrPane    := ::nClrPane

   LOCAL l3DText, nClr3dL, nClr3dS, l3DLook
   LOCAL aBitMaps, lCheckVal := .F.

   LOCAL aColSizes    := AClone( ::aColSizes ), ;
      hWnd         := ::hWnd, ;
      hDC          := ::hDC, ;
      nLineStyle   := ::nLineStyle, ;
      nClrLine     := ::nClrLine, ;
      nHeightCell  := ::nHeightCell, ;
      nHeightHead  := If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
      nHeightFoot  := If( ::lDrawFooters != Nil .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
      nHeightSuper := If( ::lDrawHeaders, ::nHeightSuper, 0 ), ;
      nHeightSpecHd:= If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   IF Empty( ::aColumns )

      RETURN NIL
   ENDIF

   DEFAULT xRow := If( ::lDrawHeaders, Max( 1, nRowPos ), nRowPos )

   IF !::lEnabled

      RETURN SELF
   ENDIF

   ::nPaintRow := xRow
   lSelected   := ::lCanSelect .and. ( AScan( ::aSelected, If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt ) ) ) > 0

   nClrBack := If( ::nPhantom = -1, ATail( ::aColumns ):nClrBack, nClrPane )
   nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, ::nAt, Len( ::aColumns ), Self ), nClrBack )
   l3DLook  := If( ::nPhantom == -1, ATail( ::aColumns ):l3DLook, .F. )

   IF ::nLen > 0

      IF ::oPhant == Nil
         //  "Phantom" column; :nPhantom hidden IVar
         ::oPhant := TSColumn():New(        "", ; // cHeading
         {|| "" }, ; // bdata
         Nil, ; // cPicture
         { nClrText, nClrBack }, ; // aColors
         Nil, ; // aAlign
         ::nPhantom, ; // nWidth
         Nil, ; // lBitMap
         Nil, ; // lEdit
         Nil, ; // bValid
         .T., ; // lNoLite
         Nil, ; // cOrder
         Nil, ; // cFooting
         Nil, ; // bPrevEdit
         Nil, ; // bPostEdit
         Nil, ; // nEditMove
         Nil, ; // lFixLite
         { l3DLook }, ;
            Nil, ;
            Self )
      ELSE
         ::oPhant:nClrFore := nClrText
         ::oPhant:nClrBack := nClrBack
         ::oPhant:nWidth   := ::nPhantom
         ::oPhant:l3DLook  := l3DLook
      ENDIF

      AAdd( aColSizes, ::nPhantom )

      nJ := nStartCol := 0
      nLastCol := Len( ::aColumns ) + 1
      nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ;
         ::nColPos - ::nFreeze ), ::nColPos - ::nFreeze ), nLastCol )

      IF ::bOnDrawLine != Nil
         Eval( ::bOnDrawLine, Self )
      ENDIF

      FOR nI := nBegin To nLastCol

         IF nStartCol > nMaxWidth
            EXIT
         ENDIF

         nJ := If( nI < ::nColPos, nJ + 1, nI )

         lSelected := If( nJ == nLastCol, .F., lSelected )
         oColumn  := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )
         cPicture := If( ValType( oColumn:cPicture ) == "B", Eval( oColumn:cPicture, ::nAt, nJ, Self ), ;
            oColumn:cPicture )
         hFont    := If( oColumn:hFont == Nil, ::hFont, oColumn:hFont )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, ::nAt, nJ, Self ), ;
            hFont )
         hFont    := If( hFont == Nil, 0, hFont )

         IF ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) )
            uData := ""                     // append mode for arrays
         ELSE
            uData := Eval( oColumn:bData )
         ENDIF

         nVertText := 0
         lCheck := ( oColumn:lCheckBox .and. ValType( uData ) == "L" .and. oColumn:lVisible )

         IF lCheck .and. ValType( uData ) == "L"
            cPicture:= ""
            nVertText := If( uData, 3, 4 )
            lCheckVal := uData
         ENDIF

         nAlign := oColumn:nAlign

         uBmpCell := oColumn:uBmpCell

         IF nJ == ::nColSel .and. ::uBmpSel != Nil .and. lSelected
            uBmpCell := ::uBmpSel
            nAlign   := nMakeLong( LoWord( nAlign ), ::nAligBmp )
         ELSEIF oColumn:lBitMap .and. Valtype( uData ) == "N"
            aBitMaps := If( Valtype( oColumn:aBitMaps ) == "A", oColumn:aBitMaps, ::aBitMaps )
            IF ! Empty( aBitMaps ) .and. uData > 0 .and. uData <= Len( aBitMaps )
               uBmpCell := aBitMaps[ uData ]
            ENDIF
            nAlign := nMakeLong( oColumn:nAlign, oColumn:nAlign )
            uData  := ""
         ELSEIF ! lCheck .and. oColumn:lEmptyValToChar .and. Empty( uData )
            uData := ""
         ELSEIF Empty( cPicture  )
            uData := If( Valtype( uData ) != "C", cValToChar( uData ), uData )
         ELSE
            uData := If( uData == NIL, "", Transform( uData, cPicture ) )
         ENDIF
         nAlign := If( ValType( nAlign ) == "B", Eval( nAlign, nJ, Self ), nAlign )

         IF ( nClrFore := oColumn:nClrFore ) == Nil .or. ( lSelected .and. ::uBmpSel == Nil )
            nClrFore := If( ! lSelected, nClrText, ::nClrSeleFore )
         ENDIF

         nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

         IF ( nClrBack := oColumn:nClrBack ) == Nil .or. ;
               ( lSelected .and. ::uBmpSel == Nil )
            nClrBack := If( ! lSelected, nClrPane, ::nClrSeleBack )
         ENDIF

         nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )

         lBrush := Valtype( nClrBack ) == "O"

         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )

            IF nJ == 1 .and. ! Empty( ::hBmpCursor )
               nClrTo *= -1
            ENDIF
         ELSE
            nClrTo := nClrBack
         ENDIF

         hBitMap := If( ValType( uBmpCell ) == "B", Eval( uBmpCell, nJ, Self ), uBmpCell )
         hBitMap := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         DEFAULT hBitMap := 0
         lAdjBmp := oColumn:lAdjBmp
         lOpaque := .T.  //JP

         IF lCheck
            DEFAULT ::aCheck := { StockBmp( 6 ), StockBmp( 7 ) }
            IF Valtype( oColumn:aCheck ) == "A"
               hBitMap := oColumn:aCheck[ If( lCheckVal, 1, 2 ) ]
            ELSE
               hBitMap := ::aCheck[ If( lCheckVal, 1, 2 ) ]
            ENDIF
            nAlign := nMakeLong( DT_CENTER, DT_CENTER )
            uData  := ""
         ENDIF

         lMultiLine := Valtype( uData ) == "C" .and. At( Chr( 13 ), uData ) > 0

         IF oColumn:l3DTextCell != Nil
            l3DText := oColumn:l3DTextCell
            nClr3dL := oColumn:nClr3DLCell
            nClr3dS := oColumn:nClr3DSCell
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, ::nAt, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, ::nAt, nJ, Self ), nClr3dS )
         ELSE
            l3DText := nClr3dL := nClr3dS := Nil
         ENDIF

         TSDrawCell(                    hWnd, ; // 1
         hDC, ; // 2
         xRow, ; // 3
         nStartCol , ; // 4
         aColSizes[ nJ ], ; // 5
         uData, ; // 6
         nAlign , ; // 7
         nClrFore, ; // 8
         nClrBack, ; // 9
         hFont, ; // 10
         hBitMap, ; // 11
         nHeightCell, ; // 12
         oColumn:l3DLook, ; // 13
         nLineStyle, ; // 14
         nClrLine, ; // 15
         0, ; // 16 header/footer/super
         nHeightHead, ; // 17
         nHeightFoot, ; // 18
         nHeightSuper, ; // 19
         nHeightSpecHd, ; // 20
         lAdjBmp, ; // 21
         lMultiline, ; // 22
         nVAlign, ; // 23
         nVertText, ; // 24
         nClrTo, ; // 25
         lOpaque, ; // 26
         If( lBrush, nClrBack:hBrush, 0 ), ; // 27
         l3DText, ;  // 28  3D text
         nClr3dL, ;  // 29  3D text light color
         nClr3dS )   // 30  3D text shadow color
         nStartCol += aColSizes[ nJ ]

      NEXT

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DrawPressed() Version 9.0 Nov/30/2009
   * Header pressed effect
   * ============================================================================

METHOD DrawPressed( nCell, lPressed ) CLASS TSBrowse

   LOCAL nI, nLeft, nTop, nBottom, nRight, hDC, hOldPen
   LOCAL hGrayPen  := CreatePen( PS_SOLID, 1, ::nClrLine ), ;
      hWhitePen := CreatePen( PS_SOLID, 1, GetSysColor( COLOR_BTNHIGHLIGHT ) )

   DEFAULT lPressed := .T.

   nKeyPressed := Nil

   IF Empty( nCell ) .or. nCell > Len( ::aColumns ) .or. ! ::lDrawHeaders

      RETURN Self
   ELSEIF ! lPressed .and. ! ::aColumns[ nCell ]:l3DLookHead
      ::DrawHeaders()

      RETURN Self
   ENDIF

   hDC   := GetDC( ::hWnd )
   nLeft := 0

   IF ::nFreeze > 0
      FOR nI := 1 To Min( ::nFreeze , nCell - 1 )
         nLeft += ::GetColSizes()[ nI ]
      NEXT
   ENDIF

   FOR nI := ::nColPos To nCell - 1
      nLeft += ::GetColSizes()[ nI ]
   NEXT

   nTop    := ::nHeightSuper
   nTop    -= If( nTop > 0, 1, 0 )
   nRight  := nLeft + ::aColSizes[ nCell ]
   nBottom := nTop + ::nHeightHead
   hOldPen := SelectObject( hDC, If( lPressed, hGrayPen, hWhitePen ) )

   MoveTo( hDC, nLeft, nBottom )
   LineTo( hDC, nLeft, nTop )
   LineTo( hDC, nRight, nTop )
   SelectObject( hDC, If( lPressed, hWhitePen, hGrayPen ) )
   MoveTo( hDC, nLeft, nBottom - 1 )
   LineTo( hDC, nRight - 1, nBottom - 1 )
   LineTo( hDC, nRight - 1, nTop - 1 )
   SelectObject( hDC, hOldPen )
   DeleteObject( hGrayPen )
   DeleteObject( hWhitePen )
   ReleaseDC( ::hWnd, hDC )

   IF lPressed
      nKeyPressed := nCell
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DrawSelect()  Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DrawSelect( xRow ) CLASS TSBrowse

   LOCAL nI, nJ, nBegin, nStartCol, oColumn, nLastCol, hBitMap, hFont, nAlign, cPicture, nClrFore, nClrBack, ;
      lNoLite, uData, l3DLook, lMulti, nClrTo, lOpaque, lBrush, nCursor, lCheck, uBmpCell, cMsg, lAdjBmp, ;
      lSelected, ;
      nVertText := 0, ;
      nMaxWidth := ::nWidth(), ;    // use local copies for speed
   nRowPos   := ::nRowPos, ;
      aColSizes := AClone( ::aColSizes ), ;
      hWnd      := ::hWnd, ;
      hDC       := ::hDc, ;
      lFocused  := ::lFocused := ( GetFocus() == ::hWnd ), ;
      nVAlign   := 1

   LOCAL l3DText, nClr3dL, nClr3dS
   LOCAL aBitMaps, lCheckVal := .F.

   LOCAL nClrText     := ::nClrText, ;
      nClrPane     := ::nClrPane, ;
      nClrFocuFore := ::nClrFocuFore, ;
      nClrFocuBack := ::nClrFocuBack, ;
      nClrLine     := ::nClrLine, ;
      nLineStyle   := ::nLineStyle, ;
      nClrSeleBack := ::nClrSeleBack, ;
      nClrSeleFore := ::nClrSeleFore, ;
      nHeightCell  := ::nHeightCell, ;
      nHeightHead  := If( ::lDrawHeaders, ::nHeightHead, 0 ), ;
      nHeightFoot  := If( ::lDrawFooters != Nil .and. ::lDrawFooters, ::nHeightFoot, 0 ), ;
      nHeightSuper := If( ::lDrawHeaders, ::nHeightSuper, 0 ),;
      nHeightSpecHd:= If( ::lDrawSpecHd, ::nHeightSpecHd, 0 )

   DEFAULT xRow := nRowPos

   ::nPaintRow := xRow

   IF Empty( ::aColumns ) .or. ! ::lEnabled

      RETURN Self
   ENDIF

   IF _HMG_MainClientMDIHandle != 0 .and. ! lFocused .and. ::hWndParent == GetActiveMdiHandle()
      lFocused := .T.
   ENDIF

   ::lDrawSelect := .T.
   lSelected := ::lCanSelect .and. ( AScan( ::aSelected, If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt ) ) > 0 )

   IF ( ::lNoLiteBar .or. ( ::lNoGrayBar .and. ! lFocused ) ) .and. Empty( ::hBmpCursor )
      ::DrawLine()   // don't want hilited cursor bar of any color
   ELSEIF ::nLen > 0

      nClrBack := If( ::nPhantom = -1 .and. ! Empty( ::aColumns ), ATail( ::aColumns ):nClrBack, nClrPane )
      nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack, ::nAt, Len( ::aColumns ), Self ), nClrBack )
      l3DLook  := If( ::nPhantom = -1 .and. ! Empty( ::aColumns ), ATail( ::aColumns ):l3DLook, .F. )

      IF ::oPhant == Nil
         // "Phantom" column; :nPhantom hidden IVar
         ::oPhant := TSColumn():New(        "", ; // cHeading
         {|| "" }, ; // bdata
         nil, ; // cPicture
         { nClrText, nClrBack }, ; // aColors
         nil, ; // aAlign
         ::nPhantom, ; // nWidth
         nil, ; // lBitMap
         nil, ; // lEdit
         nil, ; // bValid
         .T., ; // lNoLite
         nil, ; // cOrder
         nil, ; // cFooting
         nil, ; // bPrevEdit
         nil, ; // bPostEdit
         nil, ; // nEditMove
         nil, ; // lFixLite
         {l3DLook}, ;
            nil, ;
            Self )
      ELSE
         ::oPhant:nClrFore := nClrText
         ::oPhant:nClrBack := nClrBack
         ::oPhant:nWidth   := ::nPhantom
         ::oPhant:l3DLook  := l3DLook
      ENDIF

      AAdd( aColSizes, ::nPhantom )
      nJ := nStartCol := 0
      nLastCol := Len( ::aColumns ) + 1
      nBegin   := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
         ::nColPos - ::nFreeze ), nLastCol )

      FOR nI := nBegin To nLastCol

         IF nStartCol > nMaxWidth
            EXIT
         ENDIF

         nJ := If( nI < ::nColPos, nJ + 1, nI )
         oColumn := If( nJ > Len( ::aColumns ), ::oPhant, ::aColumns[ nJ ] )

         hFont    := If( oColumn:hFont == Nil, ::hFont, oColumn:hFont )
         hFont    := If( ValType( hFont ) == "B", Eval( hFont, ::nAt, nI, Self ), hFont )
         hFont    := If( hFont == Nil, 0, hFont )
         lAdjBmp  := oColumn:lAdjBmp
         nAlign   := oColumn:nAlign
         lOpaque  := .t.

         IF nJ == 1 .and. ! Empty( ::hBmpCursor )
            uBmpCell := ::hBmpCursor
            uData    := ""
            nAlign   := nMakeLong( oColumn:nAlign, oColumn:nAlign )
            lNoLite  := .T.
            lAdjBmp  := .F.
            lCheck   := .F.
         ELSE

            IF ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) )
               uData := ""                         // append mode for arrays
            ELSE
               uData := Eval( oColumn:bData )
            ENDIF

            cPicture  := If( ValType( oColumn:cPicture ) == "B", Eval( oColumn:cPicture, ::nAt, nJ, Self ), ;
               oColumn:cPicture )

            lCheck    := ( oColumn:lCheckBox .and. ValType( uData ) == "L" .and. oColumn:lVisible )
            lNoLite   := oColumn:lNoLite
            nVertText := 0

            IF lCheck
               cPicture := ""
               nVertText := If( uData, 3, 4 )
               lCheckVal := uData
            ENDIF

            uBmpCell := oColumn:uBmpCell

            IF nJ == ::nColSel .and. ::uBmpSel != Nil .and. lSelected
               uBmpCell := ::uBmpSel
               nAlign   := nMakeLong( LoWord( nAlign ), ::nAligBmp )
            ELSEIF oColumn:lBitMap .and. Valtype( uData ) == "N"
               aBitMaps := If( Valtype( oColumn:aBitMaps ) == "A", oColumn:aBitMaps, ::aBitMaps )
               IF ! Empty( aBitMaps ) .and. uData > 0 .and. uData <= Len( aBitMaps )
                  uBmpCell := aBitMaps[ uData ]
               ENDIF
               nAlign := nMakeLong( LoWord( nAlign ), nAlign )
               uData  := ""
            ELSEIF ! lCheck .and. oColumn:lEmptyValToChar .and. Empty( uData )
               uData := ""
            ELSEIF Empty( cPicture )
               uData := If( Valtype( uData ) != "C", cValToChar( uData ), uData )
            ELSE
               uData := If( uData == NIL, "", Transform( uData, cPicture ) )
            ENDIF
         ENDIF

         nAlign := If( ValType( nAlign ) == "B", Eval( nAlign, nJ, Self ), nAlign )

         IF lNoLite
            IF ( nClrFore := oColumn:nClrFore ) == Nil
               nClrFore := nClrText
            ENDIF

            nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

            IF ( nClrBack := oColumn:nClrBack ) == Nil
               nClrBack := nClrPane
            ENDIF

            nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )
            nCursor  := 0
         ELSE
            IF ( nClrFore := If( lFocused, oColumn:nClrFocuFore, oColumn:nClrSeleFore ) ) == Nil
               nClrFore := If( lFocused, nClrFocuFore, nClrSeleFore )
            ENDIF

            nClrFore := If( Valtype( nClrFore ) == "B", Eval( nClrFore, ::nAt, nJ, Self ), nClrFore )

            IF ( nClrBack := If( lFocused, oColumn:nClrFocuBack, oColumn:nClrSeleBack ) ) == Nil
               nClrBack := If( lFocused, nClrFocuBack, nClrSeleBack )
            ENDIF

            nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )

            IF ValType( nClrBack ) == "N" .and. nClrBack < 0

               nCursor := Abs( nClrBack )

               IF ( nClrBack := oColumn:nClrBack ) == Nil
                  nClrBack := nClrPane
               ENDIF

               nClrBack := If( Valtype( nClrBack ) == "B", Eval( nClrBack, ::nAt, nJ, Self ), nClrBack )
            ELSE
               nCursor := 0
            ENDIF
         ENDIF

         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
            IF nJ == 1 .and. ! Empty( ::hBmpCursor )
               nClrTo *= -1
            ENDIF
         ELSE
            nClrTo := nClrBack
         ENDIF

         lBrush := Valtype( nClrBack ) == "O"
         l3DLook := oColumn:l3DLook

         hBitMap := If( ValType( uBmpCell ) == "B" .and. ! ::lPhantArrRow, Eval( uBmpCell, nJ, Self ), uBmpCell )
         hBitMap := If( ValType( hBitMap ) == "O" .and. ! ::lPhantArrRow, Eval( ::bBitMapH, hBitMap ), hBitMap )

         DEFAULT hBitMap := 0
         lMulti  := Valtype( uData ) == "C" .and. At( Chr( 13 ), uData ) > 0

         IF lCheck
            DEFAULT ::aCheck := { StockBmp( 6 ), StockBmp( 7 ) }
            IF Valtype(oColumn:aCheck) == "A"
               hBitMap := oColumn:aCheck[ If( lCheckVal, 1, 2 ) ]
            ELSE
               hBitMap := ::aCheck[ If( lCheckVal, 1, 2 ) ]
            ENDIF
            nAlign := nMakeLong( DT_CENTER, DT_CENTER )
            uData  := ""
         ENDIF

         IF oColumn:l3DTextCell != Nil
            l3DText := oColumn:l3DTextCell
            nClr3dL := oColumn:nClr3DLCell
            nClr3dS := oColumn:nClr3DSCell
            nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, ::nAt, nJ, Self ), nClr3dL )
            nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, ::nAt, nJ, Self ), nClr3dS )
         ELSE
            l3DText := nClr3dL := nClr3dS := Nil
         ENDIF

         TSDrawCell(            hWnd, ; //  1
         hDC, ; //  2
         nRowPos, ; //  3
         nStartCol, ; //  4
         aColSizes[ nJ ], ; //  5
         uData, ; //  6
         nAlign, ; //  7
         nClrFore, ; //  8
         nClrBack, ; //  9
         hFont, ; // 10
         hBitMap, ; // 11
         nHeightCell, ; // 12
         l3DLook, ; // 13
         nLineStyle, ; // 14
         nClrLine, ; // 15
         0, ; // 16 Header/Footer/Super
         nHeightHead, ; // 17
         nHeightFoot, ; // 18
         nHeightSuper, ; // 19
         nHeightSpecHd, ; // 20
         lAdjBmp, ; // 21
         lMulti, ; // 22 Multiline text
         nVAlign, ; // 23
         nVertText, ; // 24
         nClrTo, ; // 25
         lOpaque, ; // 26
         If( lBrush, ;
            nClrBack:hBrush, 0 ), ; // 27
         l3DText, ; // 28  3D text
         nClr3dL, ; // 29  3D text light color
         nClr3dS, ; // 30  3D text shadow color
         nCursor, ; // 31  Rect cursor
         !(::lCellBrw .and. nJ != ::nCell) ) // 32  Invert color

         nStartCol += aColSizes[ nJ ]

      NEXT

   ENDIF

   IF ::bOnDraw != Nil
      Eval( ::bOnDraw, Self )
   ENDIF

   IF ::lCellBrw
      cMsg := If( ! Empty( ::AColumns[ ::nCell ]:cMsg ), ::AColumns[ ::nCell ]:cMsg, ::cMsg )
      cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )

      IF ! Empty( cMsg )
         ::SetMsg( cMsg )
      ENDIF
   ENDIF

   ::lDrawSelect := .F.

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:DrawSuper() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD DrawSuper() CLASS TSBrowse

   LOCAL nI, nJ, nBegin, nStartCol, l3DLook, nClrFore, lAdjBmp, nClrTo, lOpaque, nClrBack, hFont, cHeading, hBitMap, ;
      lMulti, nHAlign, nVAlign, nWidth, nS, nLineStyle, lBrush, ;
      nMaxWidth    := ::nWidth() , ;
      aColSizes    := AClone( ::aColSizes ), ;   // use local copies for speed
   aSuperHead   := AClone( ::aSuperHead ), ;
      nHeightHead  := ::nHeightHead, ;
      nHeightFoot  := ::nHeightFoot, ;
      nHeightSuper := ::nHeightSuper, ;
      nHeightSpecHd:= ::nHeightSpecHd

   LOCAL hWnd         := ::hWnd, ;
      hDC          := ::hDc, ;
      nClrText     := ::nClrText, ;
      nClrPane     := ::nClrPane, ;
      nClrLine     := ::nClrLine

   LOCAL l3DText, nClr3dL, nClr3dS

   IF Empty( ::aColumns )

      RETURN NIL
   ENDIF

   nClrText   := aSuperHead[ 1, 4 ]
   nClrBack   := aSuperHead[ 1, 5 ]
   l3DLook    := aSuperHead[ 1, 6 ]
   hFont      := aSuperHead[ 1, 7 ]
   nLineStyle := aSuperHead[ 1, 10 ]
   nClrLine   := aSuperHead[ 1, 11 ]

   nBegin := nI := 1

   WHILE nI <= Len( aSuperHead )

      IF aSuperHead[ nI, 1 ] > nBegin
         nJ := aSuperHead[ nI, 1 ] - 1
         ASize( aSuperHead, Len( aSuperHead ) + 1 )
         AIns( aSuperHead, nI )
         aSuperHead[ nI ] := { nBegin, nJ, "", nClrText, nClrBack, l3DLook , hFont, .F., .F., nLineStyle, ;
            nClrLine, 1, 1, .F. }
         nBegin := nJ + 1
      ELSE
         nBegin := aSuperHead[ nI++, 2 ] + 1
      ENDIF

   ENDDO

   nI := Len( aSuperHead )
   nClrText   := aSuperHead[ nI, 4 ]
   nClrBack   := aSuperHead[ nI, 5 ]
   l3DLook    := aSuperHead[ nI, 6 ]
   hFont      := aSuperHead[ nI, 7 ]
   nLineStyle := aSuperHead[ nI, 10 ]
   nClrLine   := aSuperHead[ nI, 11 ]

   IF ( nI := ATail( aSuperHead )[  2 ] ) < Len( ::aColumns )
      AAdd( aSuperHead, { nI + 1, Len( ::aColumns ), "", nClrText, nClrBack, l3DLook, hFont, .F., .F., nLineStyle, ;
         nClrLine, 1, 1, .F. } )
   ENDIF

   nStartCol := nWidth := 0

   nBegin := If( ::nColPos == ::nFreeze + 1, ::nColPos - ::nFreeze, ::nColPos )

   FOR nS := 1 To Len( aSuperHead )

      IF nBegin >= aSuperHead[ nS, 1 ] .and. nBegin <= aSuperHead[ nS, 2 ]
         DO CASE
         CASE nBegin > aSuperHead[ nS, 1 ] .and. nS == 1
            FOR nJ := aSuperHead[ nS, 1 ] To nBegin - 1
               nStartCol -= ::aColSizes[ nJ ]
            NEXT

            FOR nJ := aSuperHead[ nS, 1 ]  To aSuperHead[ nS, 2 ]
               nWidth += aColSizes[ nJ ]
            NEXT

         CASE nBegin > aSuperHead[ nS, 1 ] .and. nS > 1
            FOR nJ := 1 To ::nFreeze
               nStartCol += ::aColSizes[ nJ ]
            NEXT

            FOR nJ := nBegin  To aSuperHead[ nS, 2 ]
               nWidth += aColSizes[ nJ ]
            NEXT

         OTHERWISE
            IF nBegin > 1
               FOR nJ := 1 To ::nFreeze
                  nStartCol += ::aColSizes[ nJ ]
               NEXT
            ENDIF

            FOR nJ := aSuperHead[ nS, 1 ]  To aSuperHead[ nS, 2 ]
               nWidth += aColSizes[ nJ ]
            NEXT

         ENDCASE

         EXIT

      ENDIF

   NEXT

   FOR nI := nS To Len( aSuperHead ) + 1

      IF nStartCol > nMaxWidth
         EXIT
      ENDIF

      IF nI <= Len( aSuperHead )
         nClrFore := If( ValType( aSuperHead[ nI, 4 ] ) == "B", Eval( aSuperHead[ nI, 4 ] ), aSuperHead[ nI, 4 ] )
         nClrBack := If( ValType( aSuperHead[ nI, 5 ] ) == "B", Eval( aSuperHead[ nI, 5 ] ), aSuperHead[ nI, 5 ] )
         lBrush   := Valtype( nClrBack ) == "O"

         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         ELSE
            nClrTo   := nClrBack
         ENDIF

         cHeading := aSuperHead[ nI, 3 ]
         cHeading := If( Valtype( cHeading ) == "B", Eval( cHeading ), cHeading )
         lMulti   := Valtype( cHeading ) == "C" .and. At( Chr( 13 ), cHeading ) > 0

         l3DLook    := aSuperHead[ nI, 6 ]
         hFont      := aSuperHead[ nI, 7 ]
         hBitMap    := aSuperHead[ nI, 8 ]
         hBitMap    := If( ValType( hBitMap ) == "B", Eval( hBitMap ), hBitMap )
         hBitMap    := If( ValType( hBitMap ) == "O", Eval( ::bBitMapH, hBitMap ), hBitMap )
         lAdjBmp    := aSuperHead[ nI, 9 ]
         nLineStyle := aSuperHead[ nI, 10 ]
         nClrLine   := aSuperHead[ nI, 11 ]
         nHAlign    := aSuperHead[ nI, 12 ]
         nVAlign    := aSuperHead[ nI, 13 ]
         lOpaque    := aSuperHead[ nI, 14 ]

         DEFAULT hBitMap := 0, ;
            lOpaque := .T.
         lOpaque := ! lOpaque
      ELSE
         cHeading := ""
         nWidth   := ::nPhantom
         hBitmap  := 0
         lOpaque  := .F.
         nClrBack := If( ::nPhantom == -2, nClrPane, Atail( aSuperHead)[ 5 ] )
         nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         IF ValType( nClrBack ) == "A"
            nClrTo   := nClrBack[ 2 ]
            nClrBack := nClrBack[ 1 ]
            nClrTo   := If( ValType( nClrTo ) == "B", Eval( nClrTo ), nClrTo )
            nClrBack := If( ValType( nClrBack ) == "B", Eval( nClrBack ), nClrBack )
         ELSE
            nClrTo   := nClrBack
         ENDIF
      ENDIF

      IF nI <= Len( aSuperHead ) .and. ::aColumns[ aSuperHead[ nI, 1 ] ]:l3DTextHead != Nil
         l3DText := ::aColumns[ aSuperHead[ nI, 1 ] ]:l3DTextHead
         nClr3dL := ::aColumns[ aSuperHead[ nI, 1 ] ]:nClr3DLHead
         nClr3dS := ::aColumns[ aSuperHead[ nI, 1 ] ]:nClr3DSHead
         nClr3dL := If( ValType( nClr3dL ) == "B", Eval( nClr3dL, 0, nStartCol ), nClr3dL )
         nClr3dS := If( ValType( nClr3dS ) == "B", Eval( nClr3dS, 0, nStartCol ), nClr3dS )
      ELSE
         l3DText := nClr3dL := nClr3dS := Nil
      ENDIF

      TSDrawCell(      hWnd, ;  // 1
      hDC, ;  // 2
      0, ;  // 3
      nStartCol, ;  // 4
      nWidth, ;  // 5
      cHeading, ;  // 6
      nHAlign, ;  // 7
      nClrFore, ;  // 8
      nClrBack, ;  // 9
      hFont, ;  // 10
      hBitMap, ;  // 11
      nHeightHead, ;  // 12
      l3DLook, ;  // 13
      nLineStyle, ;  // 14
      nClrLine, ;  // 15
      3, ;  // 16 1=Header 2=Footer 3=Super
      nHeightHead, ;  // 17
      nHeightFoot, ;  // 18
      nHeightSuper, ;  // 19
      nHeightSpecHd, ;  // 20
      lAdjBmp, ;  // 21
      lMulTi, ;  // 22 Multiline text
      nVAlign, ;  // 23
      0, ;  // 24 nVertLine
      nClrTo, ;  // 25
      lOpaque, ;  // 26
      If( lBrush, ;
         nClrBack:hBrush, 0 ), ;  // 27
      l3DText, ;  // 28  3D text
      nClr3dL, ;  // 29  3D text light color
      nClr3dS )   // 30  3D text shadow color

      nStartCol += nWidth

      nWidth := 0

      IF nI < Len( aSuperHead )
         FOR nJ := aSuperHead[ nI + 1, 1 ] To aSuperHead[ nI + 1, 2 ]
            nWidth += aColSizes[ nJ ]
         NEXT
      ENDIF

   NEXT

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:Edit() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Edit( uVar, nCell, nKey, nKeyFlags, cPicture, bValid, nClrFore, ;
      nClrBack ) CLASS TSBrowse

   LOCAL nRow, nHeight, cType, uValue, nI, aGet, oCol, cMsg, aRct, bChange, lSpinner, bUp, bDown, ;
      bMin, bMax, nStartX, nWidth, lCombo, lMulti, nCol, lLogicDrop, lPicker, nTxtHeight, hFont, ix
   LOCAL cWnd := ::cControlName

   DEFAULT nCell       := ::nCell, ;
      ::lPostEdit := .F., ;
      ::lNoPaint  := .F.

   IF ::lPhantArrRow

      RETURN NIL
   ENDIF

   oCol := ::aColumns[ nCell ]

   DEFAULT ::nHeightSuper := 0, ;
      nKey           := VK_RETURN, ;
      nKeyFlags      := 0, ;
      uVar           := Eval( oCol:bData ), ;
      cPicture       := oCol:cPicture, ;
      bValid         := oCol:bValid, ;
      nClrFore       := oCol:nClrEditFore, ;
      nClrBack       := oCol:nClrEditBack

   IF ValType( ::lInsertMode ) == "L"  //Igor Nazarov
      IF IsInsertActive() != ::lInsertMode
         iif( _HMG_IsXPorLater, KeyToggleNT( VK_INSERT ), KeyToggle( VK_INSERT ) )
      ENDIF
   ENDIF

   uValue   := uVar
   cType    := If( Empty( oCol:cDataType ), ValType( uValue ), oCol:cDataType )
   IF ::lIsArr .and. oCol:cDataType # ValType( uValue )  // GF 15/07/2009
      cType := ValType( uValue )
      oCol:cDataType := cType
   ENDIF
   cMsg     := oCol:cMsgEdit
   bChange  := oCol:bChange
   lSpinner := oCol:lSpinner
   bUp      := oCol:bUp
   bDown    := oCol:bDown
   bMin     := oCol:bMin
   bMax     := oCol:bMax
   nStartX  := 0
   lCombo   := lMulti := .F.
   ::oGet   := ::bValid    //JP
   ::bValid := { || ! ::lEditing }
   // JP 1.58
   IF !oCol:lVisible
      ::lChanged := .F.
      ::lPostEdit := .F.
      ::oWnd:nLastKey := VK_RIGHT
      ::PostEdit( uVar, nCell, bValid )

      RETURN NIL
   ENDIF
   //End
   IF oCol:bPassWord != Nil
      IF ! Eval( oCol:bPassWord, uValue, nCell, ::nAt, Self )

         RETURN NIL
      ENDIF
   ENDIF

   lLogicDrop   := ::lLogicDrop
   lPicker      := ::lPickerMode   //MWS Sep 20/07
   IF cType == 'T'
      lPicker := ( hb_Hour( uValue ) == 0 .and. hb_Minute( uValue ) == 0 .and. hb_Sec( uValue ) == 0 )
   ENDIF

   ::lEditing   := .T.
   ::lHitBottom := .F.

   IF ::nLen > 0
      ::lNoPaint := .T.
   ENDIF

   IF oCol:bPrevEdit != Nil
      IF ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) ) // append mode for arrays
      ELSEIF nKey != VK_RETURN // GF 15-10-2015
         uVar := Eval( oCol:bPrevEdit, uValue, Self )
         IF ValType( uVar ) == "L" .and. ! uVar
            nKey := VK_RETURN
         ENDIF
      ENDIF
   ENDIF

   cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, nCell ), cMsg )

   IF cType == "L" .and. oCol:lCheckBox

      IF nKey != VK_RETURN

         IF Upper( Chr( nKey ) ) $ "YCST1"
            ::lChanged := uVar == .F.
            uVar := .T.
         ELSEIF Upper( Chr( nKey ) ) $ "FN0"
            ::lChanged := uVar == .T.
            uVar := .F.
         ELSEIF nKey == VK_SPACE
            uVar := ! uValue
            ::lChanged := .T.
         ELSE

            RETURN 0
         ENDIF

         ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         ::oWnd:nLastKey := VK_RETURN
         ::PostEdit( uVar, nCell )
         ::lPostEdit := .F.

         RETURN 0
      ELSE
         ::lPostEdit := .T.
         ::lChanged := .F.
         ::oWnd:nLastKey := nKey
         ::PostEdit( uValue, nCell )
         ::lPostEdit := .F.

         RETURN 0
      ENDIF
   ENDIF

   IF oCol:bExtEdit != Nil  // external edition
      ::lNoPaint := ::lEditing := .F.
      uVar := Eval( oCol:bExtEdit, uValue, Self )
      ::lChanged := ( ValType( uVar ) != ValType( uValue ) .or. uVar != uValue )
      ::lPostEdit := .T.
      ::oWnd:nLastKey := VK_RETURN
      ::PostEdit( uVar, nCell, bValid )

      RETURN NIL
   ENDIF

   hFont := If( oCol:hFontEdit != Nil, oCol:hFontEdit, ;
      If( oCol:hFont != Nil, oCol:hFont, ::hFont ) )

   IF oCol:oEdit != Nil
      oCol:oEdit:End()
      oCol:oEdit := Nil
   ENDIF

   IF ::nFreeze > 0
      FOR nI := 1 To Min( ::nFreeze , nCell - 1 )
         nStartX += ::GetColSizes()[ nI ]
      NEXT
   ENDIF

   FOR nI := ::nColPos To nCell - 1
      nStartX += ::GetColSizes()[ nI ]
   NEXT

   nClrFore := If( ValType( nClrFore ) == "B", ;
      Eval( nClrFore, ::nAt, nCell, Self ), nClrFore )

   nClrBack := If( ValType( nClrBack ) == "B", ;
      Eval( nClrBack, ::nAt, nCell, Self ), nClrBack )

   IF ::nColSpecHd != 0
      nRow    := ::nHeightHead + ::nHeightSuper + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 1 )
      nHeight := ::nHeightSpecHd - If( oCol:l3DLook, 1, -1 )
   ELSE
      nRow    := ::nRowPos - 1
      nRow    := ( nRow * ::nHeightCell ) + ::nHeightHead + ;
         ::nHeightSuper + ::nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 0 )
      nHeight := ::nHeightCell - If( oCol:l3DLook, 1, -1 )
   ENDIF

   IF oCol:cResName != Nil .or. oCol:lBtnGet

      ::cChildControl := GetUniqueName( "BtnBox" )

      oCol:oEdit := TBtnBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
         bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
         cPicture, nClrFore, nClrBack, hFont, ::cChildControl, cWnd, ;
         cMsg, bChange, bValid, oCol:cResName,oCol:bAction, ;
         lSpinner .and. cType $ "ND", bUp, bDown, ;
         bMin, bMax, oCol:nBmpWidth, nCell )

      oCol:oEdit:lAppend := ::lAppendMode
      oCol:oEdit:Hide()

   ELSEIF ( cType == "C" .and. Chr( 13 ) $ uValue ) .or. cType == "M"

      DEFAULT uValue := ""

      IF ::nMemoHE == Nil

         IF ! Empty( uValue )
            nHeight := Max( 5, StrCharCount( uValue, Chr( 10 ) ) )
         ELSE
            nHeight := 5
         ENDIF

      ELSE
         nHeight := ::nMemoHE
      ENDIF

      aRct := ::GetCliRect( ::hWnd )
      IF ::nMemoWE == Nil .or. Empty( ::nMemoWE )
         nWidth := Max( nWidth, GetTextWidth( 0, SubStr( uValue, 1, ;
            At( Chr( 13 ), uValue ) - 1 ), ;
            If( hFont != Nil, hFont, 0 ) ) )
         nWidth := Min( nWidth, Int( aRct[ 3 ] * .8 ) )
      ELSE
         nWidth := ::nMemoWE
      ENDIF

      nTxtHeight := SBGetHeight( ::hWnd, If( hFont != Nil, hFont, 0 ), 0 )

      WHILE ( nRow + ( nTxtHeight * nHeight ) ) > aRct[ 4 ]
         nRow -= nTxtHeight
      ENDDO

      nI := nCol + nWidth - aRct[ 3 ]
      nCol -= If( nI <= 0, 0, nI )
      nCol := Max( 10, nCol )
      nHeight *= nTxtHeight
      ::cChildControl := GetUniqueName( "EditBox" )

      oCol:oEdit := TSMulti():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
         bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
         hFont, nClrFore, nClrBack, ::cChildControl, cWnd )
      oCol:oEdit:bGotFocus := { || oCol:oEdit:HideSel(), oCol:oEdit:SetPos( 0 ) }
      lMulti := .T.
      oCol:oEdit:Hide()

   ELSEIF ( cType == "L" .and. lLogicDrop ) .or. oCol:lComboBox

      lCombo := .T.

      IF oCol:lComboBox

         aGet := oCol:aItems
         IF Empty( aGet )

            RETURN NIL
         ENDIF

         IF nKey == VK_RETURN
            IF oCol:cDataType != Nil .and. oCol:cDataType == "N"
               IF oCol:aData <> NIL
                  uValue := Max( 1, AScan( aGet, uValue ) )
               ELSE
                  uValue := IIf(uValue < 1 .OR. uValue > Len(aGet), 1, uValue)
               ENDIF
            ELSE
               uValue := Max( 1, AScan( aGet, uValue ) )
            ENDIF
         ELSE
            uValue := Max( 1, AScan( aGet, Upper( Chr( nKey ) ) ) )
         ENDIF

         IF ValType( Eval( oCol:bData ) ) == "N"
            nWidth := 0
            Aeval( aGet, { |x| nWidth := Max( Len(x), nWidth ) } )
            nWidth := Max( GetTextWidth( 0, Replicate( 'B', nWidth ), hFont ), oCol:nWidth )
         ENDIF

         nHeight := Max( 10, Min( 10, Len( aGet ) ) ) * ::nHeightCell

      ELSE

         aGet := { ::aMsg[ 1 ], ::aMsg[ 2 ] }

         IF nKey == VK_RETURN
            uValue := iif( uValue, 1, 2 )
         ELSE
            uValue := Max( 1, AScan( aGet, Upper( Chr( nKey ) ) ) )
         ENDIF

         nHeight := ::nHeightCell * 4  //1.54

      ENDIF

      ::cChildControl := GetUniqueName( "ComboBox" )

      oCol:oEdit := TComboBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
         bSETGET( uValue ), aGet, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
         Self, bChange, nClrFore, nClrBack, hFont, cMsg, ::cChildControl, cWnd )

      oCol:oEdit:lAppend := ::lAppendMode

   ELSEIF ( cType $ "DT" ) .and. lPicker     // MWS Sep 20/07

      nRow -= 2
      nHeight := Max( ::nHeightCell, 19 )
      ::cChildControl := GetUniqueName( "DatePicker" )

      oCol:oEdit := TDatePicker():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
         bSETGET( uValue ), Self, nWidth+::aEditCellAdjust[3], nHeight+::aEditCellAdjust[4], ;
         cPicture,, nClrFore, nClrBack, hFont, ::cChildControl,, cWnd, ;
         cMsg,,,,, bChange,,, .T. )
      oCol:oEdit:Hide()

   ELSE

      ix := GetControlIndex ( cWnd, ::cParentWnd )
      IF _HMG_aControlContainerRow [ix] == -1
         nRow += ::nTop - 1
         nCol += ::nLeft
      ELSE
         nRow += _HMG_aControlRow [ix] - 1
         nCol += _HMG_aControlCol [ix]
      ENDIF
      ::cChildControl := GetUniqueName( "GetBox" )

      oCol:oEdit := TGetBox():New( nRow+::aEditCellAdjust[1], nCol+::aEditCellAdjust[2], ;
         bSETGET( uValue ), Self, nWidth+2+::aEditCellAdjust[3], nHeight+2+::aEditCellAdjust[4], ;
         cPicture,, nClrFore, nClrBack, hFont, ::cChildControl, cWnd, ;
         cMsg,,,,, bChange, .T.,, lSpinner .and. cType $ "ND", bUp, bDown, ;
         bMin, bMax, oCol:lNoMinus )

   ENDIF

   IF oCol:oEdit != Nil

      oCol:oEdit:bLostFocus := { | nKey | ::EditExit( nCell, nKey, uValue, bValid, .F. ) }

      oCol:oEdit:bKeyDown   := { | nKey, nFlags, lExit | If( lExit != Nil .and. lExit, ;
         ::EditExit( nCell, nKey, uValue, bValid ), Nil ), HB_SYMBOL_UNUSED( nFlags ) }
      DO CASE
      CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
         oCol:oEdit:bLostFocus := Nil
      CASE "TGETBOX" $ Upper( oCol:oEdit:ClassName() )
         ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
         _HMG_InteractiveCloseStarted := .T.
         IF ix > 0
            IF oCol:lOnGotFocusSelect
               IF ValType(uValue) == "C"
                  _HMG_aControlGotFocusProcedure [ix] := {|| SendMessage( _HMG_aControlHandles [ix], EM_SETSEL, 0, If( Empty(uValue), -1, Len(Trim(uValue))) ) }
               ELSEIF ValType(uValue) $ "ND"
                  _HMG_aControlGotFocusProcedure [ix] := {|| SendMessage( _HMG_aControlHandles [ix], EM_SETSEL, 0, -1 ) }
               ENDIF
            ENDIF
            _HMG_aControlLostFocusProcedure [ix] := { | nKey | ::EditExit( nCell, nKey, uValue, bValid, .F. ) }
         ENDIF
         IF Empty( ::bLostFocus )
            ::bLostFocus := { || iif( _HMG_InteractiveCloseStarted, _HMG_InteractiveCloseStarted := .F., ) }
         ENDIF
      ENDCASE

      oCol:oEdit:SetFocus()

      IF nKey != Nil .and. nKey > 31

         IF ! lCombo .and. ! lMulti
            ::KeyChar( nKey, nKeyFlags )    //1.53
         ENDIF

      ENDIF

      IF oCol:oEdit != Nil
         oCol:oEdit:Show()
      ENDIF

      ::SetMsg( oCol:cMsgEdit )

      IF oCol:bEditing != Nil
         Eval( oCol:bEditing, uValue, Self )
      ENDIF

   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:EditExit() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD EditExit( nCol, nKey, uVar, bValid, lLostFocus ) CLASS TSBrowse

   LOCAL uValue, cType, oCol, lCombo, cMsg, ix, lSpinner

   DEFAULT lLostFocus  := .F., ;
      ::lPostEdit := .F., ;
      nCol        := ::nCell,;
      nKey        := 0

   oCol     := ::aColumns[ nCol ]
   lSpinner := oCol:lSpinner
   lCombo   := ValType( oCol:oEdit ) == "O" .and. "COMBO" $ Upper( oCol:oEdit:ClassName() )

   IF ValType( oCol:oEdit ) == "O"
      DO CASE
      CASE "TGETBOX" $ Upper( oCol:oEdit:ClassName() )
         ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
         nKey := _HMG_aControlMiscData1 [ix][3]
         SetFocus( ::hWnd )  // JP 1.59
      CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() ) .and. lSpinner
         IF oCol:oEdit:hWndChild != Nil
            PostMessage( oCol:oEdit:hWndChild, WM_CLOSE )
         ENDIF
         SetFocus( ::hWnd )
      ENDCASE
   ENDIF
   IF nKey == 0
      lLostFocus := .T.
   ENDIF

   IF ! lLostFocus .and. nKey > 0 .and. (nKey != VK_ESCAPE .or. ::nColSpecHd != 0) .and. ;
         ValType( oCol:oEdit ) == "O"

      ::lPostEdit := .T.
      HideCaret( oCol:oEdit:hWnd )

      IF lCombo

         cType := If( oCol:cDataType != Nil, oCol:cDataType, ValType( uVar ) )

         IF cType == "L"
            uValue := ( oCol:oEdit:nAt == 1 )
            uVar := If( ValType( uVar ) == "C", ( AScan( oCol:aItems, uVar ) == 1 ), ;
               If( ValType( uVar ) == "N", ( uVar == 1 ), uVar ) )
         ELSE
            IF oCol:aData != Nil
               IF ValType( uValue ) == "N" .and. ValType( uVar ) == "C"
                  uVar := AScan( oCol:aData, uVar )
               ENDIF
               ::lChanged := ( oCol:oEdit:nAt != uVar )    //JP 69
               uValue := oCol:aData[ oCol:oEdit:nAt ]
            ELSE
               IF cType == "N"
                  uValue := oCol:oEdit:nAt
               ELSE
                  uValue := oCol:oEdit:aItems[ oCol:oEdit:nAt ]
                  uVar := Substr(oCol:oEdit:aItems[uVar],1,Len(uValue)) //1.54
               ENDIF
               ::lChanged := ( uValue != uVar )            //JP 69
            ENDIF
            ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         ENDIF

         ::oWnd:nLastKey := nKey

         IF oCol:bEditEnd != Nil
            Eval( oCol:bEditEnd, uValue, Self, .T. )
         ENDIF

         IF ::nColSpecHd != 0
            ::aColumns[ nCol ]:cSpcHeading := uValue
            oCol:oEdit:End()
            oCol:oEdit := Nil
            ::lEditing  := ::lPostEdit := ::lNoPaint := .F.
            ::nColSpecHd := 0

            RETURN NIL
         ENDIF

         IF ValType( oCol:oEdit ) == "O"
            ::lAppendMode := oCol:oEdit:lAppend
            oCol:oEdit:Move( 1500,0 )
            oCol:oEdit:End()
         ENDIF
         ::PostEdit( uValue, nCol, bValid )
         oCol:oEdit := Nil
         ::oWnd:bValid := ::oGet

         cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
         IF Valtype( cMsg ) == "B"
            cMsg := Eval( cMsg, Self, ::nCell )
         ENDIF
         ::SetMsg( cMsg )

         RETURN NIL

      ENDIF

      uValue := oCol:oEdit:VarGet()
      IF ::nColSpecHd != 0
         uValue := If(nKey != VK_ESCAPE, uValue, "")
         ::aColumns[ nCol ]:cSpcHeading := uValue
         ::lChanged := ValType( uValue ) != ValType( uVar ) .or. uValue != uVar
         oCol:oEdit:End()
         oCol:oEdit := Nil
         ::lEditing := ::lPostEdit := ::lNoPaint := .F.
         ::nColSpecHd := 0
         ::lHasChgSpec := ::lChanged
         ::AutoSpec( nCol )

         RETURN NIL
      ELSE
         IF oCol:bCustomEdit != Nil
            uValue := Eval( oCol:bCustomEdit, uValue, oCol:oEdit, Self )
         ENDIF

         IF ::lAppendMode .and. Empty( oCol:oEdit:VarGet() ) .and. nKey != VK_RETURN
            bValid := {||.F.}
            IF ::nLenPos > ::nRowCount()   //JP 1.50
               ::nLenPos--
            ENDIF
            ::nRowPos := ::nLenPos       //JP 1.31
         ENDIF

         IF oCol:bEditEnd != Nil
            Eval( oCol:bEditEnd, uValue, Self, .T. )
         ENDIF

         ::lChanged := ValType( uValue ) != ValType( uVar ) .or. uValue != uVar
         ::lHasChanged := If( ::lChanged, .T., ::lHasChanged )
         ::oWnd:nLastKey := nKey

         oCol:oEdit:End()
         ::PostEdit( uValue, nCol, bValid )
         oCol:oEdit := Nil
         ::oWnd:bValid := ::oGet

         cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
         IF Valtype( cMsg ) == "B"
            cMsg := Eval( cMsg, Self, ::nCell )
         ENDIF
         ::SetMsg( cMsg )
      ENDIF

   ELSE

      IF ::lPostEdit

         RETURN NIL
      ENDIF

      IF oCol:bEditEnd != Nil .and. ValType( oCol:oEdit ) == "O"
         Eval( oCol:bEditEnd, uValue, Self, .F. )
      ENDIF

      IF ValType( oCol:oEdit ) == "O"
         IF lCombo
            ::lAppendMode := oCol:oEdit:lAppend
         ENDIF
         oCol:oEdit:End()
         oCol:oEdit := Nil
      ENDIF

      ::oWnd:nLastKey := VK_ESCAPE
      ::lChanged := .F.
      ::lEditing := .F.

      IF ::lAppendMode
         IF ::lIsArr .and. ::nAt > Len( ::aArray )    //JP 74
            ::nAt--
            ::Refresh( .T. )
            ::HiliteCell( ::nCell )
         ENDIF

         ::lAppendMode := .F.
         ::lHitBottom  := .F.
         ::lNoPaint    := .F.

         IF ::nLen <= ::nRowCount()
            ::Refresh( .T. )
         ELSEIF ! ::lCanAppend
            ::GoBottom()
         ENDIF

      ENDIF
      cMsg := If( ! Empty( oCol:cMsg ), oCol:cMsg, ::cMsg )
      cMsg := If( Valtype( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )
      ::SetMsg( cMsg )

   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:AutoSpec() Version 1.83 Adaption HMG  01/01/2010
   * ============================================================================

METHOD AutoSpec( nCol )

   LOCAL cExp, uExp, nPos, acSpecHdr := {}
   LOCAL bError := ErrorBlock( { | x | Break( x ) } )

   IF ::lAutoSearch
      IF ::bUserSearch != Nil
         AEval( ::aColumns, {|x| AAdd(acSpecHdr, x:cSpcHeading)} )
         Eval( ::bUserSearch, nCol, acSpecHdr, Self )
      ELSE
         cExp := BuildAutoSeek( Self )
         IF ! Empty(cExp)
            IF ::cAlias != "ADO_"
               BEGIN Sequence
                  uExp := &( cExp )
               RECOVER
                  ErrorBlock( bError )
               END SEQUENCE
            ENDIF
            IF ::lIsArr
               IF ( nPos := Eval(uExp, Self) ) != 0
                  ::nAt := nPos
                  IF ::bChange != Nil
                     Eval( ::bChange, Self, 0 )
                  ENDIF
                  ::Refresh(.t.)
               ELSE
                  Tone( 500, 1 )
               ENDIF
            ENDIF
            IF ::lIsDbf .or. (!::lIsArr .and. ::cAlias == "ADO_" )
               IF ::lHasChgSpec
                  Eval( ::bGoTop )
               ENDIF
               IF ::ExpLocate( cExp, nCol )
                  ::Refresh(.t.)
               ELSE
                  Tone( 500, 1 )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ELSEIF ::lAutoFilter
      IF ::bUserFilter != Nil
         AEval( ::aColumns, {|x| AAdd( acSpecHdr, x:cSpcHeading )} )
         cExp := Eval( ::bUserFilter, nCol, acSpecHdr, Self )
      ELSE
         cExp := BuildAutoFilter( Self )
      ENDIF
      IF ! Empty(cExp)
         IF ::cAlias != "ADO_"
            BEGIN Sequence
               uExp := &( "{||(" + Trim( cExp ) + ")}" )
            RECOVER
               ErrorBlock( bError )

               RETURN NIL
            END SEQUENCE
         ENDIF
         IF ::lIsDbf
            ::bFilter := uExp
            DbSetFilter( uExp, cExp )
            ( ::cAlias )->( DbGoTop() )
            ::GoTop()
            ::lHitBottom := .F.
            ::nRowPos    := ::nAt := ::nLastnAt := 1
            ::lHitTop    := .T.
            ::Refresh(.t.)
         ELSE
            IF ::cAlias == "ADO_"
               ::nRowPos := RSetFilter( Self, cExp  )
               ::GoTop()
               ::ResetVScroll()
               ::Refresh(.t.)
            ENDIF
         ENDIF
      ELSE
         IF ::lIsDbf
            DbClearFilter()
            ::bFilter := Nil
            ::GoTop()
            ::UpStable()
            ::Refresh(.t.)
         ELSE
            IF ::cAlias == "ADO_"
               ::nRowPos := RSetFilter( Self, ""  )
               ::GoTop()
               ::ResetVScroll()
               ::Refresh(.t.)
            ENDIF
         ENDIF
      ENDIF
   ENDIF
   ::lHasChgSpec := .f.

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:Excel2() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD Excel2( cFile, lActivate, hProgress, cTitle, lSave, bPrintRow ) CLASS TSBrowse

   LOCAL i, nRow, uData, nAlign, nEvery, nPic, nFont, cWork, aFontTmp, nHandle, nTotal, nSkip, nCol, ;
      hFont  := iif( ::hFont != Nil, ::hFont, 0 ), ;
      nLine  := 1, ;
      nCount := 0, ;
      aLen   := {}, ;
      aPic   := {}, cPic, anPic := {}, cType, cc, cPic1, ;
      aFont  := {}, ;
      nRecNo := iif( ::lIsDbf, ( ::cAlias )->( RecNo() ), 0), ;
      nAt    := ::nAt,;
      nOldRow := ::nLogicPos(), ;
      nOldCol := ::nCell

   DEFAULT nInstance := 0

   DEFAULT cFile     := "Book1.xls", ;
      lActivate := .T., ;
      cTitle    := "", ;
      lSave     := .F.

   CursorWait()

   ::lNoPaint := .F.
   nInstance ++
   cWork := GetStartupFolder() + "\Book" + LTrim( Str( nInstance ) ) + ".xls"
   ::SetFocus()
   cFile  := ::Proper( StrTran( AllTrim( Upper( cFile ) ), ".XLS" ) + ".XLS" )
   cTitle := AllTrim( cTitle )

   FOR nCol := 1 To Len( ::aColSizes )

      AAdd( aLen, Max( 1, Round( ::aColSizes[ nCol ] / ;
         GetTextWidth( 0, "B", hFont ), 0 ) ) )

      cPic := ''
      cType := If( Empty( ::aColumns[ nCol ]:cDataType ), ValType(Eval(::aColumns[ nCol ]:bData)), ::aColumns[ nCol ]:cDataType )
      IF cType == 'N' .and.  !Empty( ::aColumns[ nCol ]:cPicture )
         FOR i := 1 to LEN( ::aColumns[ nCol ]:cPicture )
            cc := substr( ::aColumns[ nCol ]:cPicture, i, 1 )
            IF cc=='9';   cc := '0';   endif
            IF cc=='.';   cc := ',';   endif
            IF cc=='@' .or. cc=='K' .or. cc=='Z';   loop;   endif
            IF !Empty(cPic);   cPic += cc
            ELSEIF cc # '0';   cPic += ( '#0' + cc )
            ENDIF
         NEXT
         IF Empty(cPic)
            cPic := '#0'
         ENDIF
         IF "@Z " $ ::aColumns[ nCol ]:cPicture .or. LEN(cPic) > 3
            IF "," $ cPic
               cPic1 := SubStr( cPic, 2, At( ",", cPic ) - 2 )
               cPic := StrTran( cPic1, '0', '#' ) + SubStr( cPic, At( ",", cPic ) - 1, LEN(cPic) - 2 )
            ELSE
               cPic1 := SubStr( cPic, 2, LEN(cPic) - 2 )
               cPic := StrTran( cPic1, '0', '#' ) + '0'
            ENDIF
         ENDIF
      ENDIF
      nPic := iif( !Empty(cPic), AScan( aPic, {|x| x==cPic} ), 0 )
      IF nPic == 0
         AAdd( aPic, cPic );  nPic := LEN(aPic)
      ENDIF
      AADD( anPIC, nPic )
   NEXT

   IF ( nHandle := FCreate( cWork, 0 ) ) < 0
      MsgStop( "Can't create XLS file", cWork )

      RETURN NIL
   ENDIF

   FWrite( nHandle, BiffRec( 9 ) )
   // set CodePage
   FWrite( nHandle, BiffRec( 66, GetACP() ) )
   FWrite( nHandle, BiffRec( 12 ) )
   FWrite( nHandle, BiffRec( 13 ) )

   IF ::hFont != Nil
      AAdd( aFont,  GetFontParam( ::hFont ) )
   ELSE
      IF ( hFont := GetFontHandle( ::cFont ) ) != 0
         AAdd(aFont, GetFontParam( hFont ) )
      ENDIF
   ENDIF

   FOR nCol := 1 To Len( ::aColumns )

      IF Empty( ::aColumns[ nCol ]:hFont ) .and. Empty( ::aColumns[ nCol ]:hFontHead )
         LOOP
      ENDIF

      hFont := ::aColumns[ nCol ]:hFont

      IF hFont != Nil
         aFontTmp := GetFontParam( hFont )
         IF AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
               e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
               e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } ) == 0

            AAdd( aFont, aFontTmp )
         ENDIF

      ENDIF

      hFont := ::aColumns[ nCol ]:hFontHead

      IF hFont != Nil
         aFontTmp := GetFontParam( hFont )
         IF AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
               e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
               e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } ) == 0

            AAdd( aFont, aFontTmp )
         ENDIF

      ENDIF

   NEXT

   IF Len( aFont ) > 4
      ASize( aFont, 4 )
   ENDIF

   IF ! Empty( aFont )
      FOR nCol := 1 To Len( aFont )
         FWrite( nHandle, BiffRec( 49, aFont[ nCol ] ) )
      NEXT
   ENDIF

   FWrite( nHandle, BiffRec( 31, 1 ) )
   FWrite( nHandle, BiffRec( 30, "General" ) )

   IF ! Empty( aPic )
      AEval( aPic, {|e| FWrite( nHandle, BiffRec( 30, e ) ) } )
   ENDIF

   AEval( aLen, { |e,n| FWrite( nHandle, BiffRec( 36, e, n - 1, n - 1 ) ) } )
   IF hProgress != Nil
      nTotal := ( ::nLen + 1 ) * Len( ::aColumns )
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS,0,0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   ENDIF

   IF ::lIsDbf
      ( ::cAlias )->( Eval( ::bGoTop ) )
   ENDIF

   FOR nRow := 1 To ( ::nLen )

      IF nRow == 1

         IF ! Empty( cTitle )
            cTitle := StrTran( cTitle, CRLF, Chr( 10 ) )
            nAlign := If( Chr( 10 ) $ cTitle, 5, 1 )
            FWrite( nHandle, BiffRec( 4, cTitle, 0, 0,, nAlign ) )
            nLine := 3
         ENDIF

         FOR nCol := 1 To Len( ::aColumns )

            uData := If( ValType( ::aColumns[ nCol ]:cHeading ) == "B", ;
               Eval( ::aColumns[ nCol ]:cHeading ), ;
               ::aColumns[ nCol ]:cHeading )

            IF ValType( uData ) != "C"
               LOOP
            ENDIF

            uData  := Trim( StrTran( uData, CRLF, Chr( 10 ) ) )
            nAlign := Min( LoWord( ::aColumns[ nCol ]:nHAlign ), 2 )
            nAlign := If( Chr( 10 ) $ uData, 4, nAlign )
            hFont  := ::aColumns[ nCol ]:hFontHead
            aFontTmp := GetFontParam( hFont )
            nFont  := AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
               e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
               e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } )

            FWrite( nHandle, BiffRec( 4, uData, nLine - 1, nCol - 1, .T., nAlign + 1,, ;
               Max( 0, nFont - 1 ) ) )

            IF hProgress != Nil

               IF nCount % nEvery == 0
                  SendMessage(hProgress, PBM_SETPOS, nCount, 0)
               ENDIF

               nCount ++

            ENDIF

         NEXT

         ++nLine

      ENDIF

      IF bPrintRow != Nil .and. ! Eval( bPrintRow, nRow )
         ::Skip( 1 )
         LOOP
      ENDIF

      FOR nCol := 1 To Len( ::aColumns )

         IF ::aColumns[ nCol ]:lBitMap
            LOOP
         ENDIF

         uData  := Eval( ::aColumns[ nCol ]:bData )
         nAlign := LoWord( ::aColumns[ nCol ]:nAlign )
         hFont  := ::aColumns[ nCol ]:hFont
         aFontTmp := GetFontParam( hFont )
         nFont  := AScan( aFont, {|e| e[ 1 ] == aFontTmp[ 1 ] .and. e[ 2 ] == aFontTmp[ 2 ] .and. ;
            e[ 3 ] == aFontTmp[ 3 ] .and. e[ 4 ] == aFontTmp[ 4 ] .and. ;
            e[ 5 ] == aFontTmp[ 5 ] .and. e[ 6 ] == aFontTmp[ 6 ] } )

         nPic := If( ! Empty( ::aColumns[ nCol ]:cPicture ), anPIC[ nCol ], Nil )

         IF ValType( uData ) == "N"
            FWrite( nHandle, BiffRec( 3, uData, nLine - 1, nCol - 1,, nAlign + 1, nPic, ;
               Max( 0, nFont - 1 ) ) )
         ELSE
            uData := Trim( StrTran( cValToChar( uData ), CRLF, Chr( 10 ) ) )
            nAlign := If( Chr( 10 ) $ uData, 4, nAlign )
            FWrite( nHandle, BiffRec( 4, uData, nLine - 1, nCol - 1,, nAlign + 1, nPic, ;
               Max( 0, nFont - 1 ) ) )
         ENDIF

         IF hProgress != Nil

            IF nCount % nEvery == 0
               SendMessage(hProgress, PBM_SETPOS, nCount, 0)
            ENDIF

            nCount ++

         ENDIF

      NEXT

      nSkip := ::Skip( 1 )

      ++nLine
      SysRefresh()
      IF nSkip ==0
         EXIT
      ENDIF
   NEXT

   FWrite( nHandle, BiffRec( 10 ) )
   FClose( nHandle )

   IF hProgress != Nil
      SendMessage(hProgress, PBM_SETPOS, nTotal, 0)
   ENDIF

   IF lSave
      FileRename( Self, cWork, cFile )
   ENDIF

   CursorArrow()

   IF ::lIsDbf
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      ::GoPos(nOldRow, nOldCol)
   ENDIF

   ::nAt := nAt

   IF lActivate
      ShellExecute( 0, "Open", If( lSave, cFile, cWork ),,, 3 )
   ENDIF

   ::Display()

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:ExcelOle() Version 9.0 Nov/30/2009
   * Requires TOleAuto class
   * Many thanks to Victor Manuel Tomás for the core of this method
   * ============================================================================

METHOD ExcelOle( cXlsFile, lActivate, hProgress, cTitle, hFont, lSave, bExtern, aColSel, bPrintRow ) CLASS TSBrowse

   LOCAL oExcel, oBook, oSheet, nRow, nCol, uData, nEvery, oRange, cRange, cCell, cLet, nColHead, nVar, ;
      cText, nStart, nTotal, aFont, aRepl, ;
      nLine  := 1, ;
      nCount := 0, ;
      nRecNo := ( ::cAlias )->( RecNo() ), ;
      nAt    := ::nAt,;
      aCol := { 26, 52, 78, 104, 130, 156 }, ;
      aLet := { "", "A", "B", "C", "D", "E" }, ;
      nOldRow := ::nLogicPos(), ;
      nOldCol := ::nCell

   DEFAULT lActivate := Empty( cXlsFile ), ;
      cTitle    := ""

   DEFAULT lSave    := ! lActivate .and. ! Empty( cXlsFile ), ;
      cXlsFile := ""

   CursorWait()

   IF ::lSelector
      ::aClipBoard := { ColClone( ::aColumns[ 1 ], Self ), 1, "" }
      ::DelColumn( 1 )
   ENDIF

   cLet := aLet[ AScan( aCol, {|e| Len( If( aColSel != Nil, aColSel, ::aColumns ) ) <= e } ) ]

   IF ! Empty( cLet )
      nCol := AScan( aLet, cLet ) - 1
      cLet += Chr( 64 + Len( If( aColSel != Nil, aColSel, ::aColumns ) ) - aCol[ Max( 1, nCol ) ] )
   ELSE
      cLet := Chr( 64 + Len( If( aColSel != Nil, aColSel, ::aColumns ) ) )
   ENDIF

   aRepl := {}

   ::lNoPaint := .F.

   IF hProgress != Nil
      nTotal := ( ::nLen + 1 ) * Len( ::aColumns ) + 30
      SetProgressBarRange ( hProgress , 1 , nTotal )
      SendMessage(hProgress, PBM_SETPOS, 0, 0)
      nEvery := Max( 1, Int( nTotal * .02 ) ) // refresh hProgress every 2 %
   ENDIF

   IF ! Empty( cXlsFile )
      cXlsFile := AllTrim( StrTran( Upper( cXlsFile ), ".XLS" ) )
   ENDIF

   cTitle := AllTrim( cTitle )

   Try
      oExcel := CreateObject( "Excel.Application" )
   CATCH
      MsgStop( "Excel not available. [" + Ole2TxtError()+ "]", "Error" )

      RETURN NIL
   End

   IF hProgress != Nil
      nCount -= 15
      SendMessage(hProgress, PBM_SETPOS, nCount, 0)
   ENDIF

   oExcel:WorkBooks:Add()
   oBook  := oExcel:Get( "ActiveWorkBook")
   oSheet := oExcel:Get( "ActiveSheet" )

   IF hProgress != Nil
      nCount -= 15
      SendMessage(hProgress, PBM_SETPOS, nCount, 0)
   ENDIF

   ( ::cAlias )->( Eval( ::bGoTop ) )

   cText := ""

   FOR nRow := 1 To ::nLen

      IF nRow == 1

         IF ! Empty( cTitle )
            oSheet:Cells( nLine++, 1 ):Value := AllTrim( cTitle )
            oSheet:Range( "A1:" + cLet + "1" ):Set( "HorizontalAlignment", xlHAlignCenterAcrossSelection )
            ++nLine
            nStart := nLine
         ELSE
            nStart := nLine
         ENDIF

         IF ! Empty( ::aSuperHead )

            FOR nCol := 1 To Len( ::aSuperHead )
               nVar := If( ::lSelector, 1, 0 )
               uData := If( ValType( ::aSuperhead[ nCol, 3 ] ) == "B", Eval( ::aSuperhead[ nCol, 3 ] ), ;
                  ::aSuperhead[ nCol, 3 ] )
               oSheet:Cells( nLine, ::aSuperHead[ nCol, 1 ] - nVar ):Value := uData
               cRange :=  Chr( 64 + ::aSuperHead[ nCol, 1 ] - nVar ) + LTrim( Str( nLine ) ) + ":" + ;
                  Chr( 64 + ::aSuperHead[ nCol, 2 ] - nVar ) + LTrim( Str( nLine ) )
               oSheet:Range( cRange ):Borders():LineStyle := xlContinuous
               oSheet:Range( cRange ):Set( "HorizontalAlignment", xlHAlignCenterAcrossSelection )
            NEXT

            nStart := nLine ++
         ENDIF

         nColHead := 0

         FOR nCol := 1 To Len( ::aColumns )

            IF aColSel != Nil .and. AScan( aColSel, nCol ) == 0
               LOOP
            ENDIF

            uData := If( ValType( ::aColumns[ nCol ]:cHeading ) == "B", Eval( ::aColumns[ nCol ]:cHeading ), ;
               ::aColumns[ nCol ]:cHeading )

            IF ValType( uData ) != "C"
               LOOP
            ENDIF

            uData := StrTran( uData, CRLF, Chr( 10 ) )
            nColHead ++
            oSheet:Cells( nLine, nColHead ):Value := uData

            IF hProgress != Nil

               IF nCount % nEvery == 0
                  SendMessage(hProgress, PBM_SETPOS,nCount,0)
               ENDIF

               nCount ++
            ENDIF
         NEXT

         nStart := ++ nLine

      ENDIF

      IF bPrintRow != Nil .and. ! Eval( bPrintRow, nRow )
         ::Skip( 1 )
         LOOP
      ENDIF

      FOR nCol := 1 To Len( ::aColumns )
         IF aColSel != Nil .and. AScan( aColSel, nCol ) == 0
            LOOP
         ENDIF

         uData := Eval( ::aColumns[ nCol ]:bData )

         IF ValType( uData ) == "C" .and. At( CRLF, uData ) > 0
            uData := StrTran( uData, CRLF, "&&" )

            IF AScan( aRepl, nCol ) == 0
               AAdd( aRepl, nCol )
            ENDIF
         ENDIF

         IF ::aColumns[ nCol ]:cPicture != Nil
            uData := Transform( uData, ::aColumns[ nCol ]:cPicture )
         ENDIF

         uData  :=  If( ValType( uData )=="D", DtoC( uData ), If( ValType( uData )=="N", Str( uData ) , ;
            If( ValType( uData )=="L", If( uData ,".T." ,".F." ), cValToChar( uData ) ) ) )

         cText += Trim( uData ) + Chr( 9 )

         IF hProgress != Nil

            IF nCount % nEvery == 0
               SendMessage(hProgress, PBM_SETPOS, nCount, 0)
            ENDIF

            nCount ++
         ENDIF
      NEXT

      ::Skip( 1 )
      cText += Chr( 13 )

      ++nLine

      /*
      Cada 20k volcamos el texto a la hoja de Excel , usando el portapapeles , algo muy rapido y facil ;-)
      Every 20k set text into excel sheet , using Clipboard , very easy and faster.
      */

      IF Len( cText ) > 20000
         CopyToClipboard( cText )
         cCell := "A" + Alltrim( Str( nStart ) )
         oRange := oSheet:Range( cCell )
         oRange:Select()
         oSheet:Paste()
         cText := ""
         nStart := nLine + 1

      ENDIF

   NEXT

   IF AScan( ::aColumns, { |o| o:cFooting != Nil  } ) > 0

      FOR nCol := 1 To Len( ::aColumns )

         IF ( aColSel != Nil .and. AScan( aColSel, nCol ) == 0 ) .or. ::aColumns[ nCol ]:cFooting == Nil
            LOOP
         ENDIF

         uData := If( ValType( ::aColumns[ nCol ]:cFooting ) == "B", Eval( ::aColumns[ nCol ]:cFooting ), ;
            ::aColumns[ nCol ]:cFooting )
         uData := cValTochar( uData )
         uData := StrTran( uData, CRLF, Chr( 10 ) )
         oSheet:Cells( nLine, nCol ):Value := uData
      NEXT
   ENDIF

   IF ::lIsDbf
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      ::GoPos(nOldRow, nOldCol)

   ENDIF

   ::nAt := nAt

   IF Len( cText ) > 0
      CopyToClipboard( cText )
      cCell := "A" + Alltrim( Str( nStart ) )
      oRange := oSheet:Range( cCell )
      oRange:Select()
      oSheet:Paste()
      cText := ""
   ENDIF

   nLine := If( ! Empty( cTitle ), 3, 1 )
   nLIne += If( ! Empty( ::aSuperHead ), 1, 0 )
   cRange := "A" + LTrim( Str( nLine ) ) + ":" + cLet + Alltrim( Str( oSheet:UsedRange:Rows:Count() ) )
   oRange := oSheet:Range( cRange )

   IF hFont != NIL  // let the programmer to decide the font he wants, otherwise use Excel's default
      aFont := GetFontParam( hFont )
      oRange:Font:Name := aFont[ 1 ]
      oRange:Font:Size := aFont[ 2 ]
      oRange:Font:Bold := aFont[ 3 ]
   ENDIF

   IF ! Empty( aRepl )
      FOR nCol := 1 To Len( aRepl )
         oSheet:Columns( Chr( 64 + aRepl[ nCol ] ) ):Replace( "&&", Chr( 10 ) )
      NEXT
   ENDIF

   IF bExtern != Nil
      Eval( bExtern, oSheet, Self )
   ENDIF

   oRange:Borders():LineStyle := xlContinuous
   oRange:Columns:AutoFit()

   IF ! Empty( aRepl )
      FOR nCol := 1 To Len( aRepl )
         oSheet:Columns( Chr( 64 + aRepl[ nCol ] ) ):WrapText := .T.
      NEXT
   ENDIF

   IF hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, nCount, 0 )
   ENDIF

   IF ::lSelector
      ::InsColumn( ::aClipBoard[ 2 ], ::aClipBoard[ 1 ] )
      ::lNoPaint := .F.
   ENDIF

   IF ! Empty( cXlsFile ) .and. lSave
      oBook:SaveAs( cXlsFile, xlWorkbookNormal )

      IF ! lActivate
         CursorArrow()
         oExcel:Quit()
         ::Reset()

         RETURN NIL
      ENDIF
   ENDIF

   CursorArrow()

   IF lActivate
      oSheet:Range( "A1" ):Select()
      oExcel:Visible := .T.
   ENDIF

   ::Reset()

   IF hProgress != Nil
      SendMessage( hProgress, PBM_SETPOS, 0, 0 )
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:ExpLocate() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ExpLocate( cExp, nCol ) CLASS TSBrowse

   LOCAL uExp, bExp, ;
      nLines := ::nRowCount(), ;
      nRecNo := ( ::cAlias )->( RecNo() ), ;
      bError := ErrorBlock( { | x | Break( x ) } )

   ::lValidating := .T.

   IF ::cAlias != "ADO_"
      BEGIN Sequence
         uExp := &( cExp )
      RECOVER
         ErrorBlock( bError )
         Tone( 500, 1 )

         RETURN .F.
      END SEQUENCE

      ErrorBlock( bError )

      bExp := &( "{||(" + Trim( cExp ) + ")}" )

      IF Eval( bExp )
         ::Skip( 1 )
      ENDIF
   ENDIF

   IF ::cAlias == "ADO_"
      RSetLocate( Self, cExp, ::aColumns[nCol]:lDescend )
   ELSE
      ( ::cAlias )->( __dbLocate( bExp,cExp,,, .T. ) )

      IF ( ::cAlias )->( EoF() )
         ( ::cAlias)->( DbGoTo( nRecNo ) )
         Tone( 500, 1 )

         RETURN .F.
      ENDIF
   ENDIF

   IF nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines

      nRecNo := ( ::cAlias )->( RecNo() )
      ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

      IF ( ::cAlias )->( EoF() )

         Eval( ::bGoBottom )
         ::nRowPos := nLines
         ::nAt := ::nLogicPos()

         WHILE ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
            ::Skip( -1 )
            ::nRowPos --
         ENDDO
      ELSE
         ( ::cAlias )->( DbGoTo( nRecNo ) )
         ::nAt := ::nLogicPos()
      ENDIF

      ::Refresh( .F. )
      ::ResetVScroll()
   ELSEIF nRecNo != ( ::cAlias )->( RecNo() )
      nRecNo := ( ::cAlias )->( RecNo() )
      Eval( ::bGoTop )
      ::nAt := ::nRowPos := 1

      WHILE nRecNo != ( ::cAlias )->( RecNo() )
         ::Skip( 1 )
         ::nRowPos++
      ENDDO
      ::Refresh( .F. )
      ::ResetVScroll()
   ENDIF

   IF ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   ENDIF

   IF ::lIsArr .and. ::bSetGet != Nil
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ELSEIF ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      ELSE
         Eval( ::bSetGet, "" )
      ENDIF
   ENDIF

   ::lHitTop := ::lHitBottom := .F.

   RETURN .T.

   * ============================================================================
   * METHOD TSBrowse:GoToRec() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoToRec( nRec ) CLASS TSBrowse

   LOCAL nRecNo, nLines

   IF ::lIsDbf

      ::Reset()
      nRecNo := ( ::cAlias )->( RecNo() )
      nLines := ::nRowCount()

      ::lValidating := .T.

      ( ::cAlias )->( DbGoto( nRec ) )

      IF ::nLen > nLines

         nRecNo := ( ::cAlias )->( RecNo() )
         ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

         IF ( ::cAlias )->( EoF() )

            Eval( ::bGoBottom )
            ::nRowPos := nLines
            ::nAt := ::nLogicPos()

            WHILE ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
               ::Skip( -1 )
               ::nRowPos --
            ENDDO
         ELSE
            ( ::cAlias )->( DbGoTo( nRecNo ) )
            ::nLastPos := nRecNo
            ::nAt := ::nLogicPos()
         ENDIF

         ::Refresh( .F. )
         ::ResetVScroll()

      ELSEIF nRecNo != ( ::cAlias )->( RecNo() )

         nRecNo := ( ::cAlias )->( RecNo() )
         Eval( ::bGoTop )
         ::nAt := ::nRowPos := 1

         WHILE nRecNo != ( ::cAlias )->( RecNo() )
            ::Skip( 1 )
            ::nRowPos ++
         ENDDO

         ::Refresh( .F. )
         ::ResetVScroll()

      ENDIF

      IF ::bChange != Nil
         Eval( ::bChange, Self, 0 )
      ENDIF

      ::lHitTop := ::lHitBottom := .F.

   ENDIF

   RETURN ::lValidating

   * ============================================================================
   * METHOD TSBrowse:ExpSeek() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ExpSeek( cExp, lSoft ) CLASS TSBrowse

   LOCAL nQuote, uExp, cType, ;
      nRecNo := ( ::cAlias )->( RecNo() ), ;
      nLines := ::nRowCount(), ;
      bError := ErrorBlock( { | x | Break( x ) } )

   IF !( Alias() == ::cAlias )
      MsgInfo( "TsBrowse ExpSeek "+ ::aMsg[ 25 ] + "'" + Alias() + "' != '" + ::cAlias + "'", ::aMsg[ 28 ] )
   ENDIF

   BEGIN Sequence
      cType := ValType( Eval( &("{||" + ( ::cAlias ) + "->(" + ( ::cAlias )->( IndexKey() ) + ")}") ) )
   RECOVER
      ErrorBlock( bError )
      Tone( 500, 1 )

      RETURN .F.
   END SEQUENCE

   ::lValidating := .T.

   nQuote := At( '"', cExp )
   nQuote := If( nQuote == 0, At( "'", cExp ), nQuote )

   cExp := If( cType == "C" .and. nQuote == 0, '"' + Trim( cExp ) + '"', ;
      If( cType == "D" .and. At( "CTOD", Upper( cExp ) ) == 0, 'CtoD( "' + AllTrim( cExp ) + '")', ;
      If( cType == "N", AllTrim( cExp ), If( cType == "L", If( AllTrim( cExp ) == "T", ".T.", ".F." ), ;
      AllTrim( cExp ) ) ) ) )

   BEGIN Sequence
      uExp := &( cExp )
   RECOVER
      ErrorBlock( bError )
      Tone( 500, 1 )

      RETURN .F.
   END SEQUENCE

   ErrorBlock( bError )

   ( ::cAlias )->( DbSeek( uExp, lSoft ) )

   IF ( ::cAlias )->( EoF() )
      ( ::cAlias )->( DbGoTo( nRecNo ) )
      Tone( 500, 1 )

      RETURN .F.
   ENDIF

   IF nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines

      nRecNo := ( ::cAlias )->( RecNo() )
      ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

      IF ( ::cAlias )->( EoF() )

         Eval( ::bGoBottom )
         ::nRowPos := nLines
         ::nAt := ::nLogicPos()

         WHILE ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
            ::Skip( -1 )
            ::nRowPos --
         ENDDO
      ELSE
         ( ::cAlias )->( DbGoTo( nRecNo ) )
         ::nAt := ::nLogicPos()
      ENDIF

      ::Refresh( .F. )
      ::ResetVScroll()

   ELSEIF nRecNo != ( ::cAlias )->( RecNo() )

      nRecNo := ( ::cAlias )->( RecNo() )
      Eval( ::bGoTop )
      ::nAt := ::nRowPos := 1

      WHILE nRecNo != ( ::cAlias )->( RecNo() )
         ::Skip( 1 )
         ::nRowPos ++
      ENDDO

      ::Refresh( .F. )
      ::ResetVScroll()

   ENDIF

   IF ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   ENDIF

   IF ::lIsArr .and. ::bSetGet != Nil
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ELSEIF ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      ELSE
         Eval( ::bSetGet, "" )
      ENDIF
   ENDIF

   ::lHitTop := ::lHitBottom := .F.

   RETURN .T.

   * ============================================================================
   * METHOD TSBrowse:FreezeCol() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD FreezeCol( lNext ) CLASS TSBrowse

   LOCAL nFreeze := ::nFreeze

   DEFAULT lNext := .T.

   IF lNext                                      // freeze next available column
      ::nFreeze := Min( nFreeze + 1, Len( ::aColumns ) )
   ELSE                                          // unfreeze previous column
      ::nFreeze := Max( nFreeze - 1, 0 )
   ENDIF

   IF ::nFreeze != nFreeze                        // only update if necessary
      If( ! lNext, ::PanHome(), Nil )
      ::HiliteCell( ::nFreeze + 1 )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GetAllColsWidth() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GetAllColsWidth() CLASS TSBrowse

   LOCAL nWidth := 0, ;
      nPos, ;
      nLen := Len( ::aColumns )

   FOR nPos := 1 To nLen
      nWidth += ::aColumns[ nPos ]:nWidth
   NEXT

   RETURN nWidth

   * ============================================================================
   * METHOD TSBrowse:GetColumn() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GetColumn( nCol ) CLASS TSBrowse

   DEFAULT nCol := 1

   IF hb_IsString( nCol )  // 14.07.2015
      nCol := ::nColumn( nCol )
   ELSE
      IF nCol < 1
         nCol := 1
      ELSEIF nCol > Len( ::aColumns )
         nCol := Len( ::aColumns )
      ENDIF
   ENDIF

   RETURN ::aColumns[ nCol ]                       // returns a Column object

   * ============================================================================
   * METHOD TSBrowse:GetDlgCode() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GetDlgCode( nLastKey ) CLASS TSBrowse

   IF nLastKey == VK_ESCAPE .and. ::bOnEscape != Nil
      Eval( ::bOnEscape, Self )
   ENDIF

   IF ! ::oWnd:lValidating
      IF nLastKey == VK_UP .or. nLastKey == VK_DOWN .or. nLastKey == VK_RETURN .or. nLastKey == VK_TAB .or. ;
            nLastKey == VK_ESCAPE
         ::oWnd:nLastKey := nLastKey
      ELSE
         ::oWnd:nLastKey := 0
      ENDIF
   ENDIF

   RETURN If( IsWindowEnabled( ::hWnd ) .and. nLastKey != VK_ESCAPE, DLGC_WANTALLKEYS, 0 )

   * ============================================================================
   * METHOD TSBrowse:GetRealPos() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GetRealPos( nRelPos ) CLASS TSBrowse

   LOCAL nLen

   IF ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF

   nLen := ::nLen

   nRelPos := If( nLen > MAX_POS, Int( ( nRelPos / MAX_POS ) * nLen ), nRelPos )

   RETURN nRelPos

   * ============================================================================
   * METHOD TSBrowse:GoBottom() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoBottom() CLASS TSBrowse

   LOCAL nLines := ::nRowCount()

   IF ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF
   IF ::nLenPos ==0
      ::nLenPos := Min( nLines, ::nLen )
   ENDIF
   IF ::nLen < 1

      RETURN Self
   ENDIF

   ::lAppendMode := .F.
   ::ResetSeek()

   IF ! ::lHitBottom

      Eval( ::bGoBottom )

      IF ::bFilter != Nil
         WHILE ! Eval( ::bFilter ) .and. ! BoF()
            ( ::cAlias )->( DbSkip( -1 ) )
         ENDDO
      ENDIF

      ::lHitBottom := .T.
      ::lHitTop    := .F.
      ::nRowPos    := Min( nLines, ::nLen )
      ::nRowPos    := Min( nLines, ::nLenPos ) //JP 1.31
      ::nAt        := ::nLastnAt := ::nLogicPos()
      ::nLenPos := ::nRowPos

      IF ::lIsDbf
         ::nLastPos := ( ::cAlias )->( RecNo() )
      ENDIF

      IF ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      ENDIF

      IF ::oVScroll != Nil
         ::oVScroll:SetPos( ::oVScroll:nMax )
      ENDIF

      ::Refresh( ::nLen < nLines )

      IF ::lIsArr .and. ::bSetGet != Nil
         IF ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ELSEIF ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         ELSE
            Eval( ::bSetGet, "" )
         ENDIF
      ENDIF

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GoDown() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoDown() CLASS TSBrowse

   LOCAL nFirst, lRePaint, ;
      nLines    := ::nRowCount(), ;
      lEditable := .F., ;
      lTranspar := ::lTransparent .and. ( ::hBrush != Nil .or. ::oWnd:hBrush != Nil )

   IF ::nLen < 1       // for empty dbfs or arrays
      IF ::lCanAppend
         ::nRowPos := 1
      ELSE

         RETURN Self
      ENDIF
   ENDIF

   ::ResetSeek()

   IF ::nLen <= nLines .and. ::lNoLiteBar

      RETURN Self
   ENDIF

   IF ::lNoLiteBar
      nFirst := nLines - ::nRowPos
      ::Skip( nFirst )
      ::nRowPos := nLines
   ENDIF

   ::nRowPos := Max( 1, ::nRowPos )
   AEval( ::aColumns, { |o| If( ::lCanAppend .and. o:lEdit, lEditable := .T., Nil ) } )

   IF ! ::lAppendMode
      ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )
   ENDIF

   IF ! ::lHitBottom

      IF ! ::lAppendMode .and. ::nRowPos < nLines .and. ! ::lIsTxt  // 14.07.2015
         ::DrawLine()
      ENDIF

      IF ::Skip( 1 ) == 1 .or. ::lAppendMode
         ::lHitTop := .F.

         IF ::nRowPos < nLines
            ::nRowPos++
         ELSE
            IF ::lPageMode
               lRePaint := If( ( ::nLogicPos + nLines - 1 ) > ::nLen, .T., .F. )
               ::nRowPos := 1
               ::Refresh( lRePaint )
            ELSE
               IF lTranspar
                  ::Paint()
               ELSE
                  ::nRowPos := nLines
                  ::TSBrwScroll( 1 )
                  ::Skip( -1 )
                  ::DrawLine( ::nRowPos - 1 ) // added 10.07.2015
                  ::Skip( 1 )
               ENDIF
            ENDIF
         ENDIF
         #ifdef _TSBFILTER7_
      ELSEIF ::lFilterMode .and. ::nPrevRec != Nil
         ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
         #else
      ELSE
         Eval( ::bGoBottom )
         ::lHitBottom := .T.
         #endif
      ENDIF

      IF ! ::lAppendMode .and. ! ::lEditing
         ::DrawSelect()
      ENDIF

      IF ::oVScroll != Nil .and. ! ::lAppendMode
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      ENDIF

      IF ! ::lHitBottom .and. ! ::lAppendMode .and. ::bChange != nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      ENDIF

      ::nAt := ::nLogicPos()

   ELSEIF ::lCanAppend .and. lEditable .and. ! ::lAppendMode

      ::lAppendMode := .T.
      nFirst := 0
      Aeval( ::aColumns, { | oCol, nCol | nFirst := If( ::IsEditable( nCol ) .and. nFirst == 0, nCol, nFirst ),HB_SYMBOL_UNUSED( oCol ) } )
      IF nFirst == 0
         ::lAppendMode := .F.
         ::lHitTop := ::lHitBottom := .F.

         RETURN Self
      ELSEIF ::lSelector .and. nFirst == 1
         nFirst++
      ENDIF

      IF ::nCell != nFirst .and. ! ::IsColVisible( nFirst )

         WHILE ! ::IsColVisible( nFirst )
            ::nColPos += If( nFirst < ::nCell, -1, 1 )
         ENDDO
      ENDIF

      ::lHitTop := ::lHitBottom := .F.
      ::nCell := nFirst
      ::nLenPos := ::nRowPos   //JP 1.31
      IF ::lIsArr
         ::lAppendMode := .F.
         ::DrawLine()
         ::lAppendMode := .T.
      ELSE
         ::DrawLine()
      ENDIF

      ::GoDown()             // recursive call to force entry to itself
      ::nLastKey := ::oWnd:nLastKey := VK_RETURN
      ::DrawLine()

      IF ! ::lAutoEdit
         ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
      ENDIF

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GoEnd() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoEnd() CLASS TSBrowse

   LOCAL nTxtWid, nI, nLastCol, nBegin, ;
      nWidth   := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
      nWide    := 0, ;
      nCols    := Len( ::aColumns ), ;
      nPos     := ::nColPos

   IF ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != Nil, ::hFont, 0 ) ) )

      IF ::nAt < ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::Refresh( .F. )
         IF ::oHScroll != Nil
            ::oHScroll:SetPos( ::nAt )
         ENDIF
      ENDIF

      RETURN Self
   ENDIF

   nLastCol := Len( ::aColumns )
   nBegin := Min( If( ::nColPos <= ::nFreeze, ( ::nColPos := ::nFreeze + 1, ::nColPos - ::nFreeze ), ;
      ::nColPos - ::nFreeze ), nLastCol )

   nWide := 0

   FOR nI := nBegin To nPos
      nWide += ::aColSizes[ nI ]
   NEXT

   nBegin := ::nCell

   FOR nI := nPos + 1 To nCols
      IF nWide + ::aColSizes[ nI ] <= nWidth    // only if column if fully visible
         nWide += ::aColSizes[ nI ]
         ::nCell := nI
      ELSE
         EXIT
      ENDIF
   NEXT

   IF nBegin == ::nCell

      RETURN Self
   ENDIF

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

   ENDIF

   ::Refresh( .F. )

   IF ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   ENDIF

   ::nOldCell := ::nCell
   ::HiliteCell( ::nCell )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GoHome() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoHome() CLASS TSBrowse

   ::nOldCell := ::nCell

   IF ::lIsTxt

      IF ::nAt > 1
         ::nAt := 1
         ::Refresh( .F. )
         IF ::oHScroll != Nil
            ::oHScroll:SetPos( ::nAt )
         ENDIF
      ENDIF

      RETURN Self
   ENDIF

   ::nCell := ::nColPos

   IF ::nCell == ::nOldCell

      RETURN Self
   ENDIF

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

   ENDIF

   ::Refresh( .F. )

   IF ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   ENDIF

   IF ::aColumns[ ::nCell ]:lVisible == .F.
      ::GoRight()
   ENDIF

   ::nOldCell := ::nCell
   ::HiliteCell( ::nCell )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GoLeft() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoLeft() CLASS TSBrowse

   LOCAL nCell, nSkip, ;
      lLock := ::nFreeze > 0 .and. ::lLockFreeze, ;
      lDraw := .F.

   ::nOldCell := ::nCell

   IF ::lIsTxt
      IF ::nOffset > 5
         ::nOffset -= 5
      ELSE
         ::nOffset := 1
      ENDIF
      ::Refresh( .F. )

      IF ::oHScroll != Nil
         ::oHScroll:SetPos( ::nOffset )
      ENDIF

      RETURN Self
   ENDIF

   ::ResetSeek()

   IF ::lCellBrw

      nCell := ::nCell
      nSkip := 0

      WHILE nCell > ( If( lLock, ::nFreeze + 1, 1 ) )

         nCell --
         nSkip ++

         IF ! ::aColumns[ nCell ]:lNoHilite
            EXIT
         ENDIF

      ENDDO

      IF nSkip == 0

         RETURN Self
      ENDIF

      WHILE ::nColPos > ( ::nFreeze + 1 ) .and. ! ::IsColVisible( nCell )
         lDraw := .T.
         ::nColPos --
      ENDDO

      ::nCell := nCell

      IF lDraw
         ::Refresh( .F. )
      ENDIF

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )
      ::nOldCell := ::nCell
      ::HiliteCell( ::nCell )
      ::DrawSelect()
      IF ::aColumns[ ::nCell ]:lVisible == .F.
         IF ::nCell == 1
            ::GoRight()
         ELSE
            ::GoLeft()
         ENDIF
      ENDIF

   ELSE

      IF ::nCell > ( ::nFreeze + 1 )

         ::nColPos := ::nCell := ::nFreeze + 1
         ::Refresh( .F. )

         IF ::oHScroll != Nil
            ::oHScroll:GoTop()
         ENDIF

      ENDIF

   ENDIF

   RETURN Self

   // ============================================================================
   // METHOD TSBrowse:GoNext() Version 9.0 Nov/30/2009
   // Post-edition cursor movement.  Cursor goes to next editable cell, right
   // or first-down according to the position of the last edited cell.
   // This method is activated when the MOVE clause of ADD COLUMN command is
   // set to 5 ( DT_MOVE_NEXT )
   // ============================================================================

METHOD GoNext() CLASS TSBrowse

   LOCAL nEle, ;
      nFirst := 0

   ::nOldCell   := ::nCell

   FOR nEle := ( ::nCell  + 1 ) To Len( ::aColumns )

      IF ::IsEditable( nEle ) .and. ! ::aColumns[ nEle ]:lNoHiLite .and. ::aColumns[ nEle ]:lVisible
         nFirst := nEle
         EXIT
      ENDIF
   NEXT

   IF nFirst > 0
      IF ::IsColVisible( nFirst )

         ::nCell := nFirst
         ::HiLiteCell( ::nCell )

         IF ! ::lAutoEdit
            ::DrawSelect()
         ELSE
            ::DrawLine()
         ENDIF
      ELSE
         WHILE ! ::IsColVisible( nFirst ) .and. ::nColPos < nFirst
            ::nColPos ++
         ENDDO

         ::lNoPaint := .F.
         ::nCell := nFirst
         ::HiliteCell( nFirst )
         ::Refresh( .F. )
      ENDIF

      IF ::oHScroll != Nil
         ::oHScroll:SetPos( ::nCell )
      ENDIF

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

      RETURN Self
   ENDIF

   Aeval( ::aColumns, { | oCol, nCol | nFirst := If( ::IsEditable( nCol ) .and. nFirst == 0, ;
      nCol, nFirst ),HB_SYMBOL_UNUSED( oCol ) } )

   IF nFirst == 0

      RETURN Self
   ENDIF

   IF ::IsColVisible( nFirst )
      ::nCell := nFirst
      ::lNoPaint := .F.
   ELSE

      ::nColPos := Min( nFirst, ::nFreeze + 1 )
      ::nCell   := nFirst

      WHILE ::nColPos < ::nCell .and. ! ::IsColVisible( ::nCell )
         ::nColPos ++
      ENDDO

      ::lNoPaint := .F.
      ::Refresh( .F. )

   ENDIF

   ::HiliteCell( ::nCell )

   If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )

   IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
      Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
   ENDIF

   IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
      Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
   ENDIF

   IF ::lAutoEdit
      SysRefresh()
   ENDIF

   ::nOldCell := ::nCell
   ::lHitBottom := ( ::nAt == ::nLen )
   IF ::lHitBottom
      SysRefresh()
   ENDIF
   ::GoDown()

   RETURN Self

   // ============================================================================
   // METHOD TSBrowse:GoPos() Version 9.0 Nov/30/2009
   // ============================================================================

METHOD GoPos( nNewRow, nNewCol ) CLASS TSBrowse

   LOCAL nSkip, cAlias, nRecNo, ;
      nTotRow := ::nRowCount(), ;
      nOldRow := ::nLogicPos(), ;
      nOldCol := ::nCell

   DEFAULT nNewRow := ::nLogicPos, ;
      nNewCol := ::nCell

   ::lNoPaint := ::lFirstFocus := .F.

   IF ValType( nNewRow ) != "N" .or. ValType( nNewCol ) != "N" .or. ;
         nNewCol > Len( ::aColumns ) .or. nNewRow > ::nLen .or. ;
         nNewCol <= 0 .or. nNewRow <= 0

      Tone( 500, 1 )

      RETURN NIL

   ENDIF

   cAlias := ::cAlias

   nSkip := nNewRow - nOldRow

   IF ( ::nRowPos + nSkip ) <= nTotRow .and. ( ::nRowPos + nSkip ) >= 1

      ::Skip( nSkip )
      ::nRowPos += nSkip

   ELSEIF ! ::lIsDbf
      ::nAt := nNewRow
   ELSEIF Empty( ::nLogicPos() )

      WHILE ::nAt != nNewRow

         IF ::nAt < nNewRow
            ::Skip( 1 )
         ELSE
            ::Skip( -1 )
         ENDIF

      ENDDO

   ELSEIF ! Empty( ::nLogicPos() )

      ( cAlias )->( DbSkip( nSkip ) )
      ::nAt := ::nLogicPos()

   ELSE
      ( cAlias )->( Eval( ::bGoToPos, nNewRow ) )
      ::nAt := ::nLogicPos()
   ENDIF

   IF nNewRow != nOldRow .and. ::nLen > nTotRow .and. nNewRow > nTotRow

      IF ::lIsDbf

         nRecNo := ( cAlias )->( RecNo() )

         ( cAlias )->( DbSkip( nTotRow - ::nRowPos ) )

         IF ( cAlias )->( EoF() )

            Eval( ::bGoBottom )
            ::nRowPos := nTotRow

            WHILE ::nRowPos > 1 .and. ( cAlias )->( RecNo() ) != nRecNo
               ::Skip( -1 )
               ::nRowPos --
            ENDDO

         ELSE
            ( cAlias )->( DbGoTo( nRecNo ) )
         ENDIF

      ELSE

         IF ( ::nAt + nTotRow - ::nRowPos ) > ::nLen

            Eval( ::bGoBottom )
            ::nRowPos := nTotRow

            WHILE ::nRowPos > 1 .and. ::nAt != nNewRow
               ::Skip( -1 )
               ::nRowPos --
            ENDDO

         ENDIF

      ENDIF

   ELSEIF nNewRow != nOldRow .and. ::nLen > nTotRow

      IF ::lIsDbf

         nRecNo := ( cAlias )->( RecNo() )
         Eval( ::bGoTop )
         ::nRowPos := ::nAt := 1

         WHILE ::nRowPos < nTotRow .and. ( cAlias )->( RecNo() ) != nRecNo
            ::Skip( 1 )
            ::nRowPos ++
         ENDDO

      ELSE

         Eval( ::bGoTop )
         ::nRowPos := ::nAt := 1

         WHILE ::nRowPos < nTotRow .and. ::nAt != nNewRow
            ::Skip( 1 )
            ::nRowPos ++
         ENDDO

      ENDIF

   ENDIF

   IF nNewCol != nOldCol

      WHILE ! ::IsColVisible( nNewCol ) .and. ::nColpos >= 1 .and. ::nColPos < Len( ::aColumns )

         IF nNewCol < ::nCell
            ::nColPos --
         ELSE
            ::nColPos ++
         ENDIF

      ENDDO

   ENDIF

   ::nCell := nNewCol
   ::HiliteCell( ::nCell )
   ::Refresh( .F. )

   IF ::bChange != Nil .and. nNewRow != nOldRow
      Eval( ::bChange, Self, 0 )
   ENDIF

   IF ::oVScroll != Nil .and. nNewRow != nOldRow
      ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
   ENDIF

   IF ::oHScroll != Nil .and. nNewCol != nOldCol
      ::oHScroll:SetPos( nNewCol )
   ENDIF

   ::lHitTop := ::nAt == 1

   IF ::lIsArr .and. ::bSetGet != Nil
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ELSEIF ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      ELSE
         Eval( ::bSetGet, "" )
      ENDIF
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:GoRight() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoRight() CLASS TSBrowse

   LOCAL nTxtWid, nWidth, nCell, nSkip, lRefresh

   ::nOldCell := ::nCell
   nWidth     := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   IF ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )
      IF ::nOffset < ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
         ::nOffset += 5
         ::Refresh( .F. )
         IF ::oHScroll != Nil
            ::oHScroll:SetPos( ::nOffset )
         ENDIF
      ENDIF

      RETURN Self
   ENDIF

   ::ResetSeek()

   IF ::lCellBrw

      IF ::nCell == Len( ::aColumns ) .and. ;  // avoid undesired displacement  //::GetColSizes()
         ::IsColVisible( ::nCell )

         RETURN Self
      ENDIF

      nCell := ::nCell
      nSkip := 0

      WHILE nCell < Len( ::aColumns )
         nCell ++
         nSkip ++
         IF nCell <= Len( ::aColumns ) .and. ! ::aColumns[ nCell ]:lNoHilite
            EXIT
         ENDIF
      ENDDO

      IF nCell > Len( ::aColumns )

         RETURN Self
      ENDIF

      WHILE nSkip > 0
         ::nCell ++
         nSkip --
      ENDDO

      lRefresh := ( ::lCanAppend .or. ::lIsArr )

      WHILE ! ::IsColVisible( ::nCell ) .and. ::nColPos < ::nCell
         ::nColPos ++
         lRefresh := .T.
      ENDDO

      ::HiliteCell( ::nCell )

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      IF lRefresh
         ::lNoPaint := .F.
         ::Refresh( .F. )
      ELSEIF ! ::lEditing
         ::DrawSelect()
      ENDIF

      If( ::oHScroll != Nil, ::oHScroll:SetPos( ::nCell ), Nil )

      ::nOldCell := ::nCell
      IF ::aColumns[ ::nCell ]:lVisible == .F.
         IF ::nCell == Len( ::aColumns )
            ::GoLeft()
         ELSE
            ::GoRight()
         ENDIF
      ENDIF

   ELSE

      IF ::nCell == Len( ::aColumns ) .and. ;  // avoid undesired displacement  //::GetColSizes()
         ::IsColVisible( ::nCell )

         RETURN Self
      ENDIF

      IF ::oHScroll != Nil
         ::HScroll( SB_PAGEDOWN )
      ENDIF

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GotFocus() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GotFocus( hCtlLost ) CLASS TSBrowse

   LOCAL cMsg

   DEFAULT ::lPostEdit   := .F., ;
      ::lFirstFocus := .T., ;
      ::lNoPaint    := .F., ;
      ::lInitGoTop  := .T.

   IF ::lEditing .or. ::lPostEdit

      RETURN 0
   ENDIF

   ::lFocused       := .T.
   ::oWnd:hCtlFocus := ::hWnd

   IF ::bGotFocus != Nil
      Eval( ::bGotFocus, Self, hCtlLost )
   ENDIF

   IF ::lIsDbf .and. ::lPainted .and. ! ::lFirstFocus .and. ! ::lNoResetPos .and. ! ::lValidating .and. ! ::lNoPaint .and. ! ::lCanAppend

      IF ::uLastTag != Nil
         ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
      ENDIF

      ( ::cAlias )->( DbGoTo( ::nLastPos ) )
      ::nAt := ::nLastnAt

   ELSEIF ::lIsDbf .and. ::lFirstFocus .and. ! ::lNoResetPos .and. ! ::lValidating

      IF ::lPainted
         ::GoTop()
      ELSE
         ( ::cAlias )->( Eval( ::bGoTop ) )
      ENDIF

      ::nLastPos := ( ::cAlias )->( RecNo() )
      ::nAt := ::nLastnAt := ::nLogicPos()

   ELSEIF ::lFirstFocus .and. ! ::lValidating  .and. ! ::lNoResetPos    //JP 1.70

      IF ::lPainted
         ::GoTop()
      ELSE
         IF ::lIsDbf
            ( ::cAlias )->( Eval( ::bGoTop ) )
         ELSE
            Eval( ::bGoTop )
         ENDIF
      ENDIF

   ENDIF

   ::lFirstFocus := .F.

   IF ::nLen > 0 .and. ! EmptyAlias( ::cAlias ) .and. ! ::lIconView .and. ::lPainted
      ::DrawSelect()
   ENDIF

   ::lHasFocus   := .T.
   ::lValidating := .F.

   IF ::lCellBrw .and. ::lPainted
      cMsg := If( ! Empty( ::AColumns[ ::nCell ]:cMsg ), ::AColumns[ ::nCell ]:cMsg, ::cMsg )
      cMsg := If( ValType( cMsg ) == "B", Eval( cMsg, Self, ::nCell ), cMsg )
      ::SetMsg( cMsg )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:GoTop() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoTop() CLASS TSBrowse

   LOCAL nAt     := ::nAt, ;
      nLines  := ::nRowCount()

   IF ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF

   IF ::nLen < 1

      RETURN Self
   ENDIF

   ::lAppendMode := .F.
   ::ResetSeek()

   IF ! ::lHitTop

      IF ::lPainted .and. nAt < nLines
         ::DrawLine()
      ENDIF

      Eval( ::bGoTop )

      IF ::bFilter != Nil
         WHILE ! Eval( ::bFilter ) .and. ! EoF()
            ( ::cAlias )->( DbSkip( 1 ) )
         ENDDO
      ENDIF

      ::lHitBottom := .F.
      ::nRowPos    := ::nAt := ::nLastnAt := 1
      ::lHitTop    := .T.

      IF ::lIsDbf
         ::nLastPos := ( ::cAlias )->( RecNo() )
      ENDIF

      IF ::lPainted
         IF nAt < nLines
            ::DrawSelect()
            ::Refresh( .F. )
         ELSE
            ::Refresh( ::nLen < nLines )
         ENDIF
      ENDIF

      IF ::oVScroll != Nil
         ::oVScroll:GoTop()
      ENDIF

      IF ::lPainted .and. ::bChange != Nil
         Eval( ::bChange, Self, VK_UP )
      ENDIF

      IF ::lIsArr .and. ::bSetGet != Nil
         IF ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ELSEIF ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         ELSE
            Eval( ::bSetGet, "" )
         ENDIF
      ENDIF

      ::HiliteCell( ::nCell )

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:GoUp() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD GoUp() CLASS TSBrowse

   LOCAL nSkipped, ;
      nLines := ::nRowCount(), ;
      lTranspar := ::lTransparent .and. ( ::hBrush != Nil .or. ::oWnd:hBrush != Nil )

   IF ::nLen < 1

      IF ::lCanAppend .and. ::lAppendMode        // append mode being canceled
         ::lAppendMode := ::lHitBottom := .F.
         ::nRowPos--                             // for empty dbfs
      ELSE

         RETURN Self
      ENDIF
   ENDIF

   ::ResetSeek()

   IF ::nLen <= nLines .and. ::lNoLiteBar

      RETURN Self
   ENDIF

   IF ::lNoLiteBar
      nSkipped := 1 - ::nRowPos
      ::Skip( nSkipped )
      ::nRowPos := 1
   ENDIF

   IF ::lAppendMode .and. ::lFilterMode .and. ::nPrevRec != Nil
      ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
   ENDIF

   IF ! ::lHitTop

      IF ! ::lAppendMode .and. ::nRowPos > 1  // 14.07.2015
         ::DrawLine()
      ENDIF

      IF ::Skip( -1 ) == -1

         ::lHitBottom := .F.

         IF ::nRowPos > 1

            IF ! ::lAppendMode .or. ( ::lAppendMode .and. ::nLen < nLines )
               ::nRowPos--
            ENDIF

            IF ::lAppendMode

               IF ::lFilterMode
                  ::Skip( 1 )
               ENDIF

               ::Refresh( If( ::nLen < nLines, .T., .F. ) )
               ::HiliteCell( ::nCell )
            ENDIF

         ELSE

            IF ::lPageMode
               ::nRowPos := nLines
               ::Refresh( .F. )
            ELSE
               IF ! lTranspar
                  ::lRePaint := .F.
                  ::TSBrwScroll( -1 )
                  ::Skip( 1 )
                  ::DrawLine( 2 )
                  ::Skip( -1 )
               ELSE
                  ::Paint()
               ENDIF
            ENDIF

         ENDIF

      ELSEIF ! ::lAppendMode
         ::lHitTop := .T.
      ENDIF

      ::DrawSelect()

      IF ::oVScroll != Nil .and. ! ::lAppendMode
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      ENDIF

      IF ::bChange != Nil
         Eval( ::bChange, Self, VK_UP )
      ENDIF

   ENDIF

   ::lAppendMode := .F.
   ::nPrevRec := Nil

   RETURN Self

   * ==============================================================================
   * METHOD TSBrowse:KeyChar()  Version 9.0 Nov/30/2009
   * ==============================================================================

METHOD KeyChar( nKey, nFlags )  CLASS TSBrowse

   /* Next lines were added to filter keys according with
   the data type of columns to start editing cells. Also were defined
   two static functions IsChar() and IsNumeric() to do the job */

   LOCAL cComp, lProcess, cTypeCol
   LOCAL ix

   DEFAULT ::nUserKey := nKey

   IF ::nUserKey == 255 .or. ::lNoKeyChar  // from KeyDown() method

      RETURN 0
   ENDIF

   IF ::lAppendMode

      RETURN 0
   ENDIF

   ::lNoPaint := .F.
   cTypeCol := iif( ::nLen == 0, "U", ValType( Eval( ::aColumns[ ::nCell ]:bData ) ) ) // Modificado por Carlos

   IF Upper( ::aMsg[ 1 ] ) == "YES"
      cComp := "TFYN10"
   ELSE
      cComp := "TF10" + SubStr( ::aMsg[ 1 ], 1, 1 ) + SubStr( ::aMsg[ 2 ], 1, 1 )
   ENDIF

   lProcess := If(( cTypeCol == "C" .or. cTypeCol == "M") .and. _IsChar( nKey ), .T., ;
      If(( cTypeCol == "N" .or. cTypeCol == "D") .and. _IsNumeric( nKey ), .T., ;
      If( ( cTypeCol == "L" .and. Upper( Chr( nKey ) ) $ cComp ) .or. ;
      ( cTypeCol == "L" .and. ::aColumns[ ::nCell ]:lCheckBox .and. nKey == VK_SPACE ), .T., .F. ) ) )

   // here we process direct cell editing with keyboard, not just the Enter key !
   IF lProcess .and. ::IsEditable( ::nCell ) .and. ! ::aColumns[ ::nCell ]:lSeek

      IF ::aColumns[ ::nCell ]:oEdit == Nil
         ::Edit( , ::nCell, nKey, nFlags )
      ELSE
         ix := ::aColumns[ ::nCell ]:oEdit:Atx
         IF ix > 0
            PostMessage( _HMG_aControlHandles [ix], WM_CHAR, nKey, nFlags )
         ENDIF
      ENDIF

   ELSEIF ::aColumns[ ::nCell ]:lSeek .and. ( nKey >= 32 .or. nKey == VK_BACK )
      ::Seek( nKey )
   ELSEIF lProcess .and. ::lEditableHd .and. nKey >= 32
      IF ::aColumns[ ::nCell ]:oEditSpec == Nil
         IF ::IsEditable( ::nCell )
            ::Edit( , ::nCell, nKey, nFlags )
         ENDIF
      ELSE
         ix := ::aColumns[ ::nCell ]:oEditSpec:Atx
         IF ix > 0
            PostMessage( _HMG_aControlHandles [ix], WM_CHAR, nKey, nFlags )
         ENDIF
      ENDIF
   ELSE
      ::Super:KeyChar( nKey, nFlags )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:KeyDown() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD KeyDown( nKey, nFlags ) CLASS TSBrowse

   LOCAL uTemp, uVal, uReturn, cType, ;
      lEditable := .F., ;
      nFireKey  := ::nFireKey, ;
      nCol      := ::nCell

   DEFAULT nFireKey := VK_F2

   ::lNoPaint := .F.
   ::oWnd:nLastKey := ::nLastKey := ::nUserKey := nKey

   #ifdef __EXT_USERKEYS__
   IF ::lUserKeys
      uTemp := hb_ntos( nKey )
      uTemp += iif( _GetKeyState( VK_CONTROL ), "#", "" )
      uTemp += iif( _GetKeyState( VK_SHIFT   ), "^", "" )
      uVal := hb_HGetDef( ::aUserKeys, uTemp, NIL )
      IF ! HB_ISBLOCK( uVal )
         uTemp := 'other'
         uVal  := hb_HGetDef( ::aUserKeys, uTemp, NIL )
      ENDIF
      IF HB_ISBLOCK( uVal )
         uReturn := Eval( uVal, Self, nKey, uTemp )
         IF uTemp == 'other' .and. ! HB_ISLOGICAL( uReturn )
            uReturn := .T.
         ENDIF
         IF uReturn == Nil .or. HB_ISLOGICAL( uReturn ) .and. ! uReturn
            ::nLastKey := 255

            RETURN 0
         ENDIF
         uReturn := Nil
      ENDIF
      uTemp := Nil
   ENDIF
   #endif

   IF ::bUserKeys != Nil

      uReturn := Eval( ::bUserKeys, nKey, nFlags, Self )

      IF uReturn != Nil .and. ValType( uReturn ) == "N" .and. uReturn < 200 // interpreted as a virtual key code to
         nKey := uReturn                                                    // change the original key pressed
      ELSEIF uReturn != Nil .and. ValType( uReturn ) == "L" .and. ! uReturn
         ::nUserKey := 255  // want to inhibit the KeyDown and KeyChar Methods for key pressed

         RETURN 0
      ENDIF
   ENDIF

   lEditable := ::IsEditable( nCol )

   IF ! lEditable .and. ::lCanAppend
      AEval( ::aColumns, { |o,n| If( ::IsEditable( n ), lEditable := .T., Nil ),HB_SYMBOL_UNUSED( o ) } )
   ENDIF

   DO CASE                                       // Maintain Clipper behavior for key navigation
   CASE ::lIgnoreKey( nKey, nFlags )          // has to go before any other case statement
      ::SuperKeyDown( nKey, nFlags )

   CASE _GetKeyState( VK_CONTROL ) .and. _GetKeyState( VK_SHIFT )    // Ctrl+Shift+key
      IF nKey == VK_RIGHT                     // Ctrl+Shift+Right Arrow
         ::aColumns[ nCol ]:nEditMove := DT_MOVE_RIGHT
      ELSEIF nKey == VK_DOWN                  // Ctrl+Shift+Down Arrow
         ::aColumns[ nCol ]:nEditMove := DT_MOVE_DOWN
      ELSEIF nKey == VK_UP                    // Ctrl+Shift+Up Arrow
         ::aColumns[ nCol ]:nEditMove := DT_MOVE_UP
      ELSEIF nKey == VK_LEFT                  // Ctrl+Shift+Left Arrow
         ::aColumns[ nCol ]:nEditMove := DT_MOVE_LEFT
      ENDIF

   CASE _GetKeyState( VK_CONTROL )
      IF nKey == VK_HOME                      // Ctrl+Home
         ::GoTop()
         ::PanHome()
      ELSEIF nKey == VK_END                   // Ctrl+End
         IF ::lHitBottom
            ::PanEnd()
         ELSE
            ::GoBottom()
         ENDIF
      ELSEIF nKey == VK_PRIOR                 // Ctrl+PgUp
         ::GoTop()
      ELSEIF nKey == VK_NEXT                  // Ctrl+PgDn
         ::GoBottom()
      ELSEIF nKey == VK_LEFT                  // Ctrl+Left
         ::PanLeft()
      ELSEIF nKey == VK_RIGHT                 // Ctrl+Right
         ::PanRight()
      ELSEIF lEditable .and. nKey == VK_PASTE
         ::Edit( uTemp, nCol, VK_PASTE, nFlags )
      ELSEIF ::lCellBrw .and. ( nKey == VK_COPY .or. nKey == VK_INSERT )
         uTemp := cValToChar( Eval( ::aColumns[ nCol ]:bData ) )
         CopyToClipboard( uTemp )
         SysRefresh()
      ELSE
         ::SuperKeyDown( nKey, nFlags )
      ENDIF

   CASE _GetKeyState( VK_SHIFT ) .and. nKey < 48 .and. nKey != VK_SPACE

      IF nKey == VK_HOME                      // Shift+Home
         ::PanHome()
      ELSEIF nKey == VK_END                   // Shift+End
         ::PanEnd()
      ELSEIF lEditable .and. nKey == VK_INSERT
         ::Edit( uTemp, nCol, VK_PASTE, nFlags )
      ELSEIF ( nKey == VK_DOWN .or. nKey == VK_UP ) .and. ::lCanSelect
         ::Selection()
         IF nKey == VK_UP
            ::GoUp()
         ELSEIF nKey == VK_DOWN
            ::GoDown()
         ENDIF
      ELSE
         ::SuperKeyDown( nKey, nFlags )
      ENDIF

   CASE nKey == VK_HOME
      ::GoTop()

   CASE nKey == VK_END
      ::GoBottom()

   CASE ::lEditableHd .and. ( nKey == VK_RETURN .or. nKey == nFireKey ) .and. ::nColSpecHd != 0

      uTemp := ::aColumns[ ::nColSpecHd ]:cSpcHeading

      nCol := ::nColSpecHd
      IF Empty(uTemp)
         cType := ValType( Eval( ::aColumns[ nCol ]:bData ) )
         IF cType $ "CM"
            uTemp := Space( Len( Eval( ::aColumns[ nCol ]:bData ) ) )
         ELSEIF cType == "N"
            uTemp := 0
         ELSEIF cType == "D"
            uTemp := CToD( "" )
         ELSEIF cType == "L"
            uTemp := .F.
         ENDIF
      ENDIF

      IF ::nColSpecHd != 0
         ::Edit( uTemp, nCol, nKey, nFlags )
      ENDIF

   CASE lEditable .and. ( nKey == VK_RETURN .or. nKey == nFireKey )

      IF nKey == nFireKey
         nKey := VK_RETURN
      ENDIF

      IF ::nColSpecHd != 0

         RETURN 0
      ENDIF

      IF ::nRowPos == 0

         IF ::nLen == 0 .and. ! ::lCanAppend

            RETURN 0
         ENDIF

      ENDIF

      ::oWnd:nLastKey := nKey

      IF ::aColumns[ nCol ]:bPrevEdit != Nil

         IF ::lIsArr .and. ( ::lAppendMode .or. ::nAt > Len( ::aArray ) ) // append mode for arrays
         ELSE  // GF 16-05-2008
            uVal := Eval( ::aColumns[ nCol ]:bData )
            uVal := Eval( ::aColumns[ nCol ]:bPrevEdit, uVal, Self )
            IF ValType( uVal ) == "L" .and. ! uVal

               RETURN 0
            ENDIF
         ENDIF

      ENDIF

      IF ::lAppendMode .and. ::lIsArr

         IF ! Empty( ::aDefault )

            IF Len( ::aDefault ) < Len( ::aColumns )
               ASize( ::aDefault, Len( ::aColumns ) )
            ENDIF

            uTemp := If( ::aDefault[ nCol ] == Nil, ;
               If( ::aDefValue[ 1 ] == Nil, ;
               ::aDefValue[ nCol + 1 ], ;
               ::aDefValue[ nCol ] ), ;
               If( ValType( ::aDefault[ nCol ] ) == "B", ;
               Eval( ::aDefault[ nCol ], Self ), ::aDefault[ nCol ] ) )
         ELSE
            uTemp := If( nCol <= Len( ::aDefValue ), ;
               ::aDefValue[ nCol ], Space( 10 ) )
         ENDIF

      ELSEIF ::lAppendMode .and. ::aDefault != Nil

         IF Len( ::aDefault ) < Len( ::aColumns )
            ASize( ::aDefault, Len( ::aColumns ) )
         ENDIF

         uTemp := If( ::aDefault[ nCol ] != Nil, If( ValType( ::aDefault[ nCol ] ) == "B", ;
            Eval( ::aDefault[ nCol ], Self ), ::aDefault[ nCol ] ), Eval( ::aColumns[ nCol ]:bData ) )
      ELSE
         uTemp := Eval( ::aColumns[ nCol ]:bData )
      ENDIF

      IF ::lCellBrw .and. ::aColumns[ nCol ]:lEdit            // JP v.1.1
         ::Edit( uTemp, nCol, nKey, nFlags )
      ENDIF

   CASE ::lCanSelect .and. !lEditable .and. nKey == VK_SPACE  // Added 27.09.2012
      ::Selection()
      ::GoDown()
   CASE nKey == VK_UP
      ::GoUp()
   CASE nKey == VK_DOWN
      ::GoDown()
   CASE nKey == VK_LEFT
      ::GoLeft()
   CASE nKey == VK_RIGHT
      ::GoRight()
   CASE nKey == VK_PRIOR
      nKeyPressed := .T.
      ::PageUp()
   CASE nKey == VK_NEXT
      nKeyPressed := .T.
      ::PageDown()
   CASE nKey == VK_DELETE .and. ::lCanDelete
      ::DeleteRow()
   CASE nKey == VK_CONTEXT .and. nFlags == 22872065
      IF ::bContext != Nil
         Eval( ::bContext, ::nRowPos, ::nColPos, Self )
      ENDIF
   CASE !::lCellbrw .and. ( nKey == VK_RETURN .or. nKey == VK_SPACE ) .and. ::bLDblClick != Nil  // 14.07.2015
      Eval( ::bLDblClick, Nil, nKey, nFlags, Self )
   OTHERWISE
      ::SuperKeyDown( nKey, nFlags )
   ENDCASE

   RETURN 0

   #ifdef __EXT_USERKEYS__
   * ============================================================================
   * METHOD TSBrowse:UserKeys()  by SergKis
   * ============================================================================

METHOD UserKeys( nKey, bKey, lCtrl, lShift ) CLASS TSBrowse

   LOCAL cKey := 'other', uVal

   IF HB_ISBLOCK( bKey )                             // set a codeblock on key in a hash
      IF ! Empty( nKey )
         IF HB_ISNUMERIC( nKey )
            cKey := hb_ntos( nKey )
            cKey += iif( Empty( lCtrl ), '', '#' )
            cKey += iif( Empty( lShift), '', '^' )
         ELSEIF HB_ISCHAR( nKey )
            cKey := nKey
         ENDIF
      ENDIF
      hb_HSet( ::aUserKeys, cKey, bKey )
      ::lUserKeys := ( Len( ::aUserKeys ) > 0 )
   ELSE                                              // execute a codeblock by key from a hash
      IF HB_ISNUMERIC( nKey )
         cKey := hb_ntos( nKey )
      ELSEIF HB_ISCHAR( nKey )
         cKey := nKey
      ENDIF
      IF ::lUserKeys                                 // allowed of setting of the codeblocks
         uVal := hb_HGetDef( ::aUserKeys, cKey, NIL )
         IF HB_ISBLOCK( uVal )
            cKey := Eval( uVal, Self, nKey, cKey, bKey, lCtrl, lShift )
         ENDIF
      ENDIF
   ENDIF

   RETURN cKey
   #endif

   * ============================================================================
   * METHOD TSBrowse:Selection()  Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Selection() CLASS TSBrowse

   LOCAL uTemp, uVal

   #ifdef __EXT_SELECTION__
   LOCAL lCan := .T.

   IF HB_IsBlock( ::bPreSelect )
      lCan := Eval( ::bPreSelect, ::nAt )
      IF !HB_IsLogical( lCan )
         lCan := .T.
      ENDIF
   ENDIF

   IF lCan
      #endif
      uVal := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

      IF ( uTemp := AScan( ::aSelected, uVal ) ) > 0
         hb_ADel( ::aSelected, uTemp, .T. )
         ::DrawSelect()

         IF ::bSelected != Nil
            Eval( ::bSelected, Self, uVal, .F. )
         ENDIF

      ELSE

         AAdd( ::aSelected, uVal )
         ::DrawSelect()

         IF ::bSelected != Nil
            Eval( ::bSelected, Self, uVal, .T. )
         ENDIF

      ENDIF
      #ifdef __EXT_SELECTION__
   ENDIF
   #endif

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:KeyUp()  Version 9.0 Nov/30/2009
   * ============================================================================

METHOD KeyUp( nKey, nFlags ) CLASS TSBrowse

   IF lNoAppend != Nil
      ::lCanAppend := .T.
      lNoAppend := Nil
   ENDIF

   IF nKeyPressed != Nil

      ::Refresh( .F. )
      nKeyPressed := Nil

      IF ::bChange != Nil
         Eval( ::bChange, Self, nKey )
      ENDIF

   ENDIF

   RETURN ::Super:KeyUp( nKey, nFlags )

   * ============================================================================
   * METHOD TSBrowse:LButtonDown() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LButtonDown( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   LOCAL nClickRow, nSkipped, nI, lHeader, lFooter, nIcon, nAtCol, bLClicked, lMChange, lSpecHd, ;
      nColPixPos := 0, ;
      uPar1    := nRowPix, ;
      uPar2    := nColPix, ;
      nColInit := ::nColPos - 1, ;
      lDrawRow := .F., ;
      lDrawCol := .F., ;
      nLines   := ::nRowCount(), ;
      nCol     := 0, ;
      oCol, ix

   DEFAULT ::lDontChange := .F.

   ::lNoPaint := .F.

   IF ::nFreeze > 0
      FOR nI := 1 To ::nFreeze
         nColPixPos += ::GetColSizes()[ nI ]
      NEXT
   ENDIF

   nClickRow := ::GetTxtRow( nRowPix )
   nAtCol    := Max( ::nAtCol( nColPix ), 1 )   // JP 1.31
   lHeader   := nClickRow == 0 .and. ::lDrawHeaders
   lFooter   := nClickRow == -1 .and. If( ::lDrawFooters != Nil, ::lDrawFooters, .F. )
   lSpecHd   := nClickRow == -2 .and. if( ::lDrawSpecHd != Nil, ::lDrawSpecHd , .F. )
   ::oWnd:nLastKey := 0

   IF ::aColumns[ nAtCol ]:lNoHilite .and. ! lHeader .and. ! lFooter

      IF nAtCol <= ::nFreeze .and. ::lLockFreeze
         nAtCol := ::nFreeze + 1
      ENDIF
   ENDIF

   IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
      IF  nClickRow == -2 .and. ::nColSpecHd > 0
         oCol := ::oWnd:aColumns[ ::nColSpecHd ]
      ELSE
         oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
      ENDIF
      IF oCol:oEdit != Nil
         // JP 1.40-64
         IF (nClickRow  == ::nRowPos .AND. nAtCol == ::oWnd:nCell) .or. ;
               (nClickRow == -2 .and. ::lDrawSpecHd .AND. nAtCol == ::nColSpecHd )

            DO CASE
            CASE "TSMULTI" $ Upper( oCol:oEdit:ClassName() )

               RETURN 0
            CASE "TCOMBOBOX" $ Upper( oCol:oEdit:ClassName() )
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )

               RETURN 0
            CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )  // JP 1.64
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )

               RETURN 0
            OTHERWISE
               ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
               IF ix > 0
                  nCol := _HMG_aControlCol [ix]
               ENDIF
               IF nCol > nColPix
                  nCol := 0
               ENDIF
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )

               RETURN 0
            ENDCASE
         ELSE
            DO CASE
            CASE "TSMULTI" $ Upper( oCol:oEdit:ClassName() )
               IF oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               ENDIF
            CASE "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
               IF oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               ELSE
                  Eval( oCol:oEdit:bKeyDown , VK_ESCAPE, 0, .t. )
               ENDIF
            OTHERWISE
               IF oCol:oEdit:bLostFocus != Nil
                  Eval( oCol:oEdit:bLostFocus , VK_ESCAPE )
               ENDIF
            ENDCASE
            SetFocus( ::hWnd )
            ::Refresh( .T. )
         ENDIF
         //end
      ENDIF
   ENDIF

   IF ::lIconView

      IF ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0
         ::DrawIcon( nIcon )
      ENDIF

      RETURN NIL

   ENDIF

   SetFocus( ::hWnd )

   IF ::nLen < 1 .or. ::lIsTxt
      IF ! ::lCanAppend .or. ::lIsTxt

         RETURN 0
      ELSEIF nClickRow > 0
         ::PostMsg( WM_KEYDOWN, VK_DOWN, nMakeLong( 0, 0 ) )

         RETURN 0
      ENDIF
   ENDIF

   IF lHeader .and. Valtype( nKeyFlags ) == "N"
      lMChange   := ::lMChange
      ::lMChange := .F.

      IF ::nHeightSuper == 0 .or. ( ::nHeightSuper > 0 .and. nRowPix >= ::nHeightSuper )
         ::DrawPressed( nAtCol )
      ENDIF

      IF ::aActions != Nil .and. nAtCol <= Len( ::aActions )

         IF ::aActions[ nAtCol ] != Nil
            ::DrawHeaders()
            Eval( ::aActions[ nAtCol ], Self, uPar1, uPar2 )

            IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
               CursorArrow()

               RETURN 0
            ENDIF

            ::DrawHeaders()
         ENDIF
      ENDIF

      ::lMChange := lMChange

   ELSEIF lFooter

      lMChange   := ::lMChange
      ::lMChange := .F.

      IF ::aColumns[ nAtCol ]:bFLClicked != Nil

         Eval( ::aColumns[ nAtCol ]:bFLClicked, uPar1, uPar2, ::nAt, Self )

         IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd

            RETURN 0
         ENDIF

      ENDIF

      ::lMChange := lMChange
      ::DrawFooters()

   ELSEIF lSpecHd .and. ::lEditableHd

      lMChange   := ::lMChange
      ::lMChange := .F.
      IF ::aColumns[ nAtCol ]:bSLClicked != Nil

         Eval( ::aColumns[ nAtCol ]:bSLClicked, uPar1, uPar2, ::nAt, Self )

         IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd

            RETURN 0
         ENDIF
      ELSE
         IF ::lEditingHd
            oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
            IF oCol:oEditSpec != Nil
               ix := GetControlIndex ( ::cChildControl, ::cParentWnd )
               IF ix > 0
                  nCol := _HMG_aControlCol [ix]
               ENDIF
               IF nCol > nColPix
                  nCol := 0
               ENDIF
               PostMessage( ::oWnd:hCtlFocus, WM_LBUTTONDOWN, nKeyFlags, nMakeLong( nColPix - nCol, nRowPix ) )

               RETURN 0
            ENDIF
         ENDIF
      ENDIF

      ::lMChange := lMChange
      ::DrawHeaders()

   ENDIF

   IF ::lDontChange

      RETURN NIL
   ENDIF

   IF ::lMChange .and. nClickRow == 0 .and. ! ::lNoMoveCols

      IF AScan( ::GetColSizes(), { | nColumn | nColPixPos += nColumn, nColInit ++, ;
            nColPix >= nColPixPos - 2 .and. nColPix <= nColPixPos + 2 }, ::nColPos ) != 0

         ::lLineDrag := .T.
         ::VertLine( nColPixPos, nColInit, nColPixPos - nColPix )
      ELSE
         ::lColDrag := .T.
         ::nDragCol := ::nAtCol( nColPix )
      ENDIF

      IF ! ::lCaptured
         ::lCaptured := .T.
         ::Capture()
      ENDIF

   ENDIF

   IF nClickRow > 0 .and. nClickRow != ::nRowPos .and. nClickRow < ( nLines + 1 )

      ::ResetSeek()
      ::DrawLine()

      nSkipped  := ::Skip( nClickRow - ::nRowPos )
      ::nRowPos += nSkipped

      IF ::oVScroll != Nil
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      ENDIF

      lDrawRow      := .T.
      ::lHitTop     := .F.
      ::lHitBottom  := .F.
      ::lAppendMode := .F.

      IF ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      ENDIF

   ENDIF

   IF nClickRow > 0 .or. ( ! ::lDrawHeaders .and. nClickRow >= 0 )

      bLClicked := If( ::aColumns[ nAtCol ]:bLClicked != Nil, ::aColumns[ nAtCol ]:bLClicked, ::bLClicked )

      IF ! ( ::lLockFreeze .and. ::nAtCol( nColPix, .T. ) <= ::nFreeze )
         lDrawCol := ::HiliteCell( ::nCell, nColPix )
      ENDIF

      IF bLClicked != Nil
         Eval( bLClicked, uPar1, uPar2, nKeyFlags, Self )
      ENDIF

      IF ! ::lNoHScroll .and. ::oHScroll != Nil .and. lDrawCol
         ::oHScroll:SetPos( ::nCell )
      ENDIF

   ENDIF

   IF lDrawRow .or. lDrawCol
      ::DrawSelect()
   ENDIF

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

   ENDIF

   ::lGrasp := ! lHeader

   IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus == ::hWnd
      ::lMouseDown := .T.
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:LButtonUp() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LButtonUp( nRowPix, nColPix, nFlags ) CLASS TSBrowse

   LOCAL nClickRow, nDestCol

   IF nKeyPressed != Nil
      ::DrawPressed( nKeyPressed, .F. )
   ENDIF

   IF ::lCaptured
      ::lCaptured := .F.
      ReleaseCapture()

      IF ::lLineDrag
         ::lLineDrag := .F.
         ::VertLine()
      ELSE
         ::lColDrag := .F.
         nClickRow := ::GetTxtRow( nRowPix )

         nDestCol := ::nAtCol( nColPix )

         // we gotta be on header row within listbox and not same colm
         IF nClickRow == 0 .or. nClickRow == -2
            IF  nColPix > ::nLeft .and. ::nDragCol != nDestCol

               IF ::lMoveCols
                  ::MoveColumn( ::nDragCol, nDestCol )
               ELSE
                  ::Exchange( ::nDragCol, nDestCol )
               ENDIF

               IF ValType( ::bColDrag ) == "B"
                  Eval( ::bColDrag, nDestCol, ::nDragCol, Self )
               ENDIF
            ELSEIF ::nDragCol = nDestCol

               IF ::aColumns[ nDestCol ]:bHLClicked != Nil
                  ::DrawHeaders()
                  Eval( ::aColumns[ nDestCol ]:bHLClicked, nRowPix, nColPix, ::nAt, Self )
                  ::DrawHeaders()
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   ::lGrasp := .F.
   ::Super:LButtonUp( nRowPix, nColPix, nFlags )

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:LDblClick() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LDblClick( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   LOCAL nClickRow := ::GetTxtRow( nRowPix ), ;
      nCol      := ::nAtCol( nColPix, ::lSelector ), ;
      uPar1     := nRowPix, ;
      uPar2     := nColPix

   ::oWnd:nLastKey := 0
   IF ! ::lEnabled

      RETURN Self
   ENDIF

   IF ( nClickRow == ::nRowPos .and. nClickRow > 0 ) .or. ( nClickRow == ::nRowPos .and. ! ::lDrawHeaders )

      IF ::lCellBrw .and. ::IsEditable( nCol )

         ::nColSpecHd := 0
         IF ValType( Eval( ::aColumns[ nCol ]:bData ) ) == "L" .and. ;
               ::aColumns[ nCol ]:lCheckBox  // virtual checkbox
            ::PostMsg( WM_CHAR, VK_SPACE, 0 )
         ELSEIF ::aColumns[ nCol ]:oEdit != Nil
            ::PostMsg( WM_KEYDOWN, VK_RETURN, 0 )
         ELSEIF ::bLDblClick != Nil
            Eval( ::bLDblClick, uPar1, uPar2, nKeyFlags, Self )
         ELSE
            ::PostMsg( WM_KEYDOWN, VK_RETURN, 0 )
         ENDIF

         RETURN 0
         #ifndef __EXT_SELECTION__
      ELSEIF ::lCanSelect .and. ::bUserKeys == Nil  // Added 28.09.2012
         ::Selection()
         #endif
      ELSEIF ::bLDblClick != Nil
         Eval( ::bLDblClick, uPar1, uPar2, nKeyFlags, Self )
      ENDIF

   ELSEIF nClickRow == 0 .and. ::lDrawHeaders .and. ! ::lNoChangeOrd  // GF 1.71
      IF ::bLDblClick != Nil .and. ::aActions == Nil
         Eval( ::bLDblClick, uPar1, uPar2, nKeyFlags, Self )
      ELSE
         ::SetOrder( ::nAtCol( nColPix, ! ::lSelector ) )
      ENDIF
   ELSEIF nClickRow == -2 .and. ::lDrawSpecHd .and. ::aColumns[ nCol ]:lEditSpec
      IF ::lAutoSearch .or. ::lAutoFilter
         ::nColSpecHd := Min( If( nCol <= ::nFreeze, ::nFreeze + 1, ::nAtCol( nColPix ) ), Len( ::aColumns ) )
         ::PostMsg( WM_KEYDOWN, VK_RETURN, 0 )

         RETURN 0
      ENDIF
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:LoadFields() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LoadFields( lEditable ) CLASS TSBrowse

   LOCAL n, nE, cHeading, nAlign, nSize, cData, cType, nDec, hFont, cPicture, ;
      cBlock, nCols, aNames, cKey, ;
      aColSizes := ::aColSizes, ;
      cOrder, nEle, ;
      cAlias := ::cAlias, ;
      aAlign := { "LEFT", "CENTER", "RIGHT", "VERT" }, ;
      aStru  := ( ::cAlias )->( DbStruct() )

   DEFAULT lEditable := ::lEditable, ;
      aColSizes := {}

   aNames    := ::aColSel
   nCols     := If( aNames == Nil, ( ::cAlias )->( FCount() ), Len( aNames ) )
   aColSizes := If( Len( ::aColumns ) == Len( aColSizes ), Nil, aColSizes )

   FOR n := 1 To nCols

      nE := If( aNames == Nil, n, ( ::cAlias )->( FieldPos( aNames[ n ] ) ) )

      IF ValType( ::aHeaders ) == "A" .and. ! Empty( ::aHeaders ) .and. n <= Len( ::aHeaders )
         cHeading := ::aHeaders[ n ]
      ELSE
         cHeading := ::Proper( ( ::cAlias )->( Field( nE ) ) )
      ENDIF

      IF ( nEle := AScan( ::aTags, {|e| Upper( cHeading ) $ Upper( e[ 2 ] ) } ) ) > 0
         cOrder := ::aTags[ nEle, 1 ]
         cKey   := ( ::cAlias )->( OrdKey() )

         IF Upper( cHeading ) $ Upper( cKey )
            ::nColOrder := If( Empty( ::nColOrder ), Len( ::aColumns ) + 1, ::nColOrder )
         ENDIF
      ELSE
         cOrder := ""
      ENDIF

      nAlign := If( ::aJustify != Nil .and. Len( ::aJustify ) >= nE, ::aJustify[ nE ], ;
         If( ( ::cAlias )->( ValType( FieldGet( nE ) ) ) == "N", 2, ;
         If( ( ::cAlias )->( ValType( FieldGet( nE ) ) ) == "L", 1, 0 ) ) )

      nAlign := If( ValType( nAlign ) == "L", If( nAlign, 2, 0 ), ;
         If( ValType( nAlign ) == "C", AScan( aAlign, nAlign ) - 1, nAlign ) )

      nSize := If( ! aColSizes == Nil .and. Len( aColsizes ) >= nE, aColSizes[ nE ], Nil )

      cType := aStru[ nE, 2 ]
      IF cType == "C"
         cPicture := "@K " + Replicate( 'X', aStru[ nE, 3 ] )
      ELSEIF cType == "N"
         cPicture := Replicate( '9', aStru[ nE, 3 ] )
         IF aStru[ nE, 4 ] > 0
            cPicture := SubStr( cPicture, 1, aStru[ nE, 3 ]-aStru[ nE, 4 ] - 1 ) + '.' + Replicate( '9', aStru[ nE, 4 ] )
         ENDIF
         cPicture := "@K " + cPicture
      ENDIF

      IF nSize == Nil
         cData := ( ::cAlias )->( FieldGet( nE ) )
         cType := aStru[ nE, 2 ]
         nSize := aStru[ nE, 3 ]
         nDec  := aStru[ nE, 4 ]
         hFont := If( ::hFont != Nil, ::hFont, 0 )

         IF cType == "C"
            cData := PadR( Trim( cData ), nSize, "B" )
            nSize := GetTextWidth( 0, cData, hFont )
         ELSEIF cType == "N"
            cData := StrZero( cData, nSize, nDec )
            nSize := GetTextWidth( 0, cData, hFont )
         ELSEIF cType == "D"
            cData := cValToChar( If( Empty( cData ), Date(), cData ) )
            nSize := Int( GetTextWidth( 0, cData + "B", hFont ) ) + If( lEditable, 30, 0 )
         ELSEIF cType == "M"
            nSize := If( ::nMemoWV == Nil, 200, ::nMemoWV )
         ELSE
            cData := cValToChar( cData )
            nSize := GetTextWidth( 0, cData, hFont )
         ENDIF

         nSize := Max( GetTextWidth( 0, Replicate( "B", Len( cHeading ) ), hFont ), nSize )
         nSize += If( ! Empty( cOrder ), 14, 0 )

      ELSEIF ValType( ::aColSizes ) == "A" .and. ! Empty( ::aColSizes ) .and. n <= Len( ::aColSizes )
         nSize := ::aColSizes[ n ]
      ENDIF

      IF ValType( ::aFormatPic ) == "A" .and. ! Empty( ::aFormatPic ) .and. n <= Len( ::aFormatPic )
         cPicture := ::aFormatPic[ n ]
      ENDIF

      cBlock := 'FieldWBlock("' + aStru[ nE, 1 ] + '",Select("' + ::cAlias + '"))'
      ::AddColumn( TSColumn():New( cHeading, FieldWBlock( aStru[ nE, 1 ], Select( ::cAlias ) ),cPicture, ;
         { ::nClrText, ::nClrPane }, { nAlign, DT_CENTER }, nSize,, lEditable,,, cOrder,,,, ;
         5,,,, Self, cBlock ) )

      ATail( ::aColumns ):cData := ::cAlias + "->" + FieldName( nE )
      ATail( ::aColumns ):cName := ( ::cAlias )->( FieldName( nE ) )  // 21.07.2015

      IF cType == "L"
         ATail( ::aColumns ):lCheckBox := .T.
      ENDIF

      IF ! Empty( cOrder )
         ATail( ::aColumns ):lIndexCol := .T.
      ENDIF

   NEXT

   IF ::nLen == 0
      ::nLen := If( ::bLogicLen == Nil, Eval( ::bLogicLen := {||( cAlias )->( LastRec() ) } ), Eval( ::bLogicLen ) )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:nAtCol() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD nAtCol( nColPixel, lActual ) CLASS TSBrowse

   LOCAL nColumn := ::nColPos - 1, ;
      aSizes  := ::GetColSizes(), ;
      nI, ;
      nPos    := 0

   DEFAULT lActual := .F.

   IF ::nFreeze > 0

      IF lActual
         nColumn := 0
      ELSE
         FOR nI := 1 To ::nFreeze
            nPos += aSizes[ nI ]
         NEXT
      ENDIF
   ENDIF

   WHILE nPos < nColPixel .and. nColumn < ::nColCount()
      IF ::aColumns[ nColumn + 1 ]:lVisible  // skip hidden columns
         nPos += aSizes[ nColumn + 1 ]
      ENDIF
      nColumn++
   ENDDO

   RETURN nColumn

   * ============================================================================
   * METHOD TSBrowse:nAtColActual()
   * ============================================================================

METHOD nAtColActual( nColPixel ) CLASS TSBrowse

   LOCAL nColumn := 0, ;
      aSizes  := ::GetColSizes(), ;
      nI, ;
      nColPix := 0

   FOR nI := 1 To ::nFreeze
      IF nColPixel > nColPix
         nColumn := nI
      ENDIF
      nColPix += aSizes[ nI ]
   NEXT

   FOR nI := 1 To ::nColCount()
      IF nI > ::nFreeze
         IF nColPixel > nColPix
            nColumn++
         ENDIF
         nColPix += If( ::IsColVis2( nI ), aSizes[ nI ], 0 )
      ENDIF
   NEXT

   RETURN nColumn

   * ============================================================================
   * METHOD TSBrowse:nAtIcon() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD nAtIcon( nRow, nCol ) CLASS TSBrowse

   LOCAL nIconsByRow := Int( ::nWidth() / 50 )

   nRow -= 9
   nCol -= 1

   IF ( nCol % 50 ) >= 9 .and. ( nCol % 50 ) <= 41

      RETURN Int( ( nIconsByRow * Int( nRow / 50 ) ) + Int( nCol / 50 ) ) + 1
   ELSE

      RETURN 0
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:nLogicPos() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD nLogicPos() CLASS TSBrowse

   LOCAL cAlias, cOrderName, nLogicPos

   DEFAULT ::lIsDbf  := .F., ;
      ::lIsTxt  := .F.

   IF ! ::lIsDbf

      IF ::lIsTxt
         ::nAt := ::oTxtFile:RecNo()
      ENDIF

      IF ::cAlias == "ADO_"

         RETURN Eval( ::bKeyNo )
      ENDIF

      RETURN ::nAt

   ENDIF

   cAlias := ::cAlias

   cOrderName := If( ::bTagOrder != Nil, ( cAlias )->( Eval( ::bTagOrder ) ), Nil )
   nLogicPos  := ( cAlias )->( Eval( ::bKeyNo, Nil, Self ) )

   IF ::lFilterMode
      nLogicPos := nLogicPos - ::nFirstKey
   ENDIF

   nLogicPos := If( nLogicPos <= 0, ::nLen + 1, nLogicPos )

   RETURN nLogicPos

   * ============================================================================
   * METHOD TSBrowse:HandleEvent() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD HandleEvent( nMsg, nWParam, nLParam ) CLASS TSBrowse

   LOCAL nDelta, ix

   DEFAULT ::lNoPaint := .F., ;
      ::lDontChange := .F.

   IF hb_IsBlock( ::bEvents )
      IF ! Empty( EVal( ::bEvents, Self, nMsg, nWParam, nLParam ) )

         RETURN 1
      ENDIF
   ENDIF
   IF nMsg == WM_SETFOCUS .and. ! ::lPainted

      RETURN 0
   ELSEIF nMsg == WM_GETDLGCODE

      RETURN ::GetDlgCode( nWParam )
   ELSEIF nMsg == WM_CHAR .and. ::lEditing

      RETURN 0
   ELSEIF nMsg == WM_CHAR

      RETURN ::KeyChar( nWParam, nLParam )
   ELSEIF nMsg == WM_KEYDOWN .and. ::lDontChange

      RETURN 0
   ELSEIF nMsg == WM_KEYDOWN

      RETURN ::KeyDown( nWParam, nLParam )
   ELSEIF nMsg == WM_KEYUP

      RETURN ::KeyUp( nWParam, nLParam )
   ELSEIF nMsg == WM_VSCROLL
      IF ::lDontchange

         RETURN NIL
      ENDIF
      IF nLParam == 0

         RETURN ::VScroll( Loword( nWParam ), HiWord( nWParam ) )
      ENDIF
   ELSEIF nMsg == WM_HSCROLL
      IF ::lDontchange

         RETURN NIL
      ENDIF

      RETURN ::HScroll( Loword( nWParam ), HiWord( nWParam ) )
   ELSEIF nMsg == WM_ERASEBKGND .and. ! ::lEditing
      ::lNoPaint := .F.
   ELSEIF nMsg == WM_DESTROY .and. ! Empty( ::aColumns ) .and. ::aColumns[ ::nCell ]:oEdit != Nil
      ix := ::aColumns[ ::nCell ]:oEdit:Atx
      IF ix > 0
         PostMessage( _HMG_aControlHandles [ix], WM_KEYDOWN, VK_ESCAPE, 0 )
      ENDIF
      #ifdef __EXT_SELECTION__
   ELSEIF nMsg == WM_LBUTTONDBLCLK .and. _GetKeyState( VK_SHIFT )
      IF ::lCanSelect .and. !::lEditable
         ::Selection()
      ENDIF
      #endif
   ELSEIF nMsg == WM_LBUTTONDBLCLK

      RETURN ::LDblClick( HiWord( nLParam ), LoWord( nLParam ), nWParam )
   ELSEIF nMsg == WM_MOUSEWHEEL
      IF ::hWnd != 0 .and. ! ::lDontChange
         nDelta := Bin2I( I2Bin( HiWord( nWParam ) ) ) / 120
         ::MouseWheel( nMsg, nDelta, LoWord( nLParam ), HiWord( nLParam ) )
      ENDIF

      RETURN 0
   ENDIF

   RETURN ::Super:HandleEvent( nMsg, nWParam, nLParam )

   * ============================================================================
   * METHOD TSBrowse:HiliteCell() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD HiliteCell( nCol, nColPix ) CLASS TSBrowse

   LOCAL nI, nAbsCell, nRelCell, nNowPos, nOldPos, nLeftPix, ;
      lDraw := .F.,;
      lMove := .T.

   DEFAULT nCol := 1

   IF ! ::lCellBrw .and. nColPix == Nil            // if not browsing cell-style AND no nColPix, ignore call.

      RETURN lDraw                                 // nColPix NOT nil means called from ::LButtonDown()
   ENDIF

   IF nCol < 1
      nCol := 1
   ELSEIF nCol > Len( ::aColumns )
      nCol := Len( ::aColumns )
   ENDIF

   IF Len( ::aColumns ) > 0

      IF nColPix != Nil                            // used internally by ::LButtonDown() only
         nAbsCell := ::nAtCol( nColPix, .F. )
         nRelCell := ::nAtCol( nColPix, .T. )

         IF nAbsCell >= ::nFreeze .and. nRelCell <= ::nFreeze
            nNowPos := nRelCell
         ELSE
            nNowPos := nAbsCell
         ENDIF

         nOldPos := ::nCell

         IF ::nFreeze > 0 .and. nOldPos < nNowPos .and. ::lLockFreeze  // frozen col and going right
            nNowPos := nAbsCell
            lMove := ( nOldPos > ::nFreeze )
         ENDIF

         IF nOldPos < nNowPos                      // going right
            nLeftPix := 0

            FOR nI := nOldPos To nNowPos - 1
               lDraw := .T.
               ::nCell ++
               nLeftPix += ::aColSizes[ nI ]       // we need to know pixels left of final cell...
            NEXT

            ::nCell := If( ::nCell > Len(::aColumns), Len(::aColumns), ::nCell )

            IF ::nWidth() < ( nLeftPix + ::aColSizes[ ::nCell ] ) .and. ::nColPos < Len( ::aColumns ) .and. lMove
               ::nColPos ++
               ::Refresh( .F. )
            ENDIF
         ELSEIF nNowPos < nOldPos                  // going left

            FOR nI := nNowPos To nOldPos - 1
               lDraw := .T.
               ::nCell --
            NEXT

            ::nCell := If( ::nCell < 1, 1, ::nCell )
         ENDIF

         nCol := ::nCell
      ELSE
         lDraw := ! ( ::nCell == nCol )

         ::nColPos := Max( ::nFreeze + 1, ::nColPos )

         IF ::nFreeze > 0 .and. ::lLockFreeze
            ::nCell := Max( nCol, ::nFreeze + 1 )
         ELSEIF ::nCell != nCol
            ::nCell := nCol
         ENDIF

         IF ! ::lNoHScroll .and. ::oHScroll != Nil .and. lDraw

            ::oHScroll:SetPos( nCol )

            IF ::lPainted
               ::Refresh( .F. )
            ENDIF

         ENDIF
      ENDIF

      IF ::lCellBrw
         // unhilite all columns EXCEPT those with "double cursor" (permanent) efect
         AEval( ::aColumns, { |oColumn| oColumn:lNoLite := ! oColumn:lFixLite } ) // allways .T. if no double cursor
         ::aColumns[ nCol ]:lNoLite := .F.
      ENDIF
   ENDIF

   RETURN lDraw

   * ============================================================================
   * METHOD TSBrowse:HScroll() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD HScroll( nWParam, nLParam ) CLASS TSBrowse

   LOCAL nCol, nMsg, nPos

   nMsg := nWParam
   nPos := nLParam

   ::lNoPaint := .F.

   IF GetFocus() != ::hWnd
      SetFocus( ::hWnd )
   ENDIF

   DO CASE
   CASE nMsg == SB_LINEUP
      ::GoLeft()

   CASE nMsg == SB_LINEDOWN
      ::GoRight()

   CASE nMsg == SB_PAGEUP
      ::PanLeft()

   CASE nMsg == SB_PAGEDOWN
      nCol := ::nColPos + 1

      WHILE ::IsColVisible( nCol ) .and. nCol <= Len( ::aColumns )
         ++nCol
      ENDDO

      IF nCol < Len ( ::aColumns )
         ::nColPos := ::nCell := nCol
         ::Refresh( .F. )
         ::oHScroll:SetPos( nCol )
      ELSE

         nCol := Len( ::aColumns )
         WHILE ! ::IsColVisible( nCol ) .and. ::nColPos < nCol
            ::nColPos++
         ENDDO
         ::nCell := nCol
         ::oHScroll:GoBottom()
         ::Refresh( .F. )
      ENDIF

      IF ::lCellBrw
         ::HiLiteCell( ::nCell )
      ENDIF

   CASE nMsg == SB_TOP
      ::PanHome()

   CASE nMsg == SB_BOTTOM
      ::PanEnd()

   CASE nMsg == SB_THUMBPOSITION
      ::HThumbDrag( nPos )

   CASE nMsg == SB_THUMBTRACK
      ::HThumbDrag( nPos )

   ENDCASE

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:HThumbDrag() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD HThumbDrag( nPos ) CLASS TSBrowse

   LOCAL nI, nLeftPix, nColPos,;
      nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   IF ::oHScroll != Nil .and. ! Empty( nPos )

      IF nPos >= Len( ::aColumns )
         IF ::IsColVisible( Len( ::aColumns ) )
            ::nCell := Len( ::aColumns )
            ::HiliteCell( ::nCell )
            ::Refresh( .F. )
         ELSE
            ::PanEnd()
         ENDIF
         ::oHScroll:GoBottom()

         RETURN Self
      ENDIF

      IF ::lIsTxt
         ::oHScroll:SetPos( ::nAt := nPos )
      ELSE
         IF ::lLockFreeze .and. nPos <= ::nFreeze   // watch out for frozen columns
            ::oHScroll:SetPos( ::nCell := ::nFreeze + 1 )
         ELSE
            ::oHScroll:SetPos( ::nCell := Min( nPos, Len( ::aColumns ) ) )
         ENDIF

         nLeftPix := 0                              // check for frozen columns,

         FOR nI := 1 To ::nFreeze                   // if any
            nLeftPix += ::aColSizes[ nI ]
         NEXT

         nColPos := ::nCell

         FOR nI := ::nCell To 1 Step - 1            // avoid extra scrolling
            IF nLeftPix + ::aColSizes[nI] < nWidth  // to the right of the
               nLeftPix += ::aColSizes[nI]          // last cell (column)
               nColPos := nI
            ELSE
               EXIT
            ENDIF
         NEXT

         ::nColPos := nColPos
         ::HiliteCell( ::nCell )
      ENDIF

      ::Refresh( .F. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:InsColumn() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD InsColumn( nPos, oColumn ) CLASS TSBrowse

   LOCAL nI, ;
      nCell := ::nCell

   DEFAULT nPos := 1

   IF oColumn == Nil                             // if no Column object supplied

      RETURN NIL                                 // return nil insted of reference to object
   ENDIF

   IF Valtype( nPos ) == "C"
      nPos := ::nColumn( nPos )
   ENDIF

   IF nPos < 1
      nPos := 1
   ELSEIF nPos > Len( ::aColumns ) + 1
      nPos := Len( ::aColumns ) + 1
   ENDIF

   ASize( ::aColumns, Len( ::aColumns ) + 1 )
   aIns( ::aColumns, nPos )
   ::aColumns[ nPos ] := oColumn

   ASize( ::aColSizes, Len( ::aColSizes ) + 1 )
   aIns( ::aColSizes, nPos )
   ::aColsizes[ nPos ] := If(oColumn:lVisible, oColumn:nWidth, 0)

   IF nPos == 1 .and. Len( ::aColumns ) > 1 .and. ::lSelector

      RETURN NIL
   ENDIF

   If( nCell != nPos, ::nCell := If( ::lPainted, nPos, nCell ), Nil )

   IF ! Empty( oColumn:cOrder )                       // if column has a TAG, we
      ::SetOrder( nPos )                              // set it as controling order
   ELSEIF ::nColOrder != 0 .and. nPos <= ::nColOrder  // if left of current order
      ::nColOrder ++                                  // adjust position
   ENDIF

   IF ::lPainted
      ::HiliteCell( ::nCell )

      IF ::oHScroll != Nil
         ::oHScroll:SetRange( 1, Len( ::aColumns ) )
         ::oHScroll:SetPos( ::nCell )
      ENDIF

      IF ! Empty( ::aSuperHead )

         FOR nI := 1 To Len( ::aSuperHead )

            IF nPos >= ::aSuperHead[ nI, 1 ] .and. nPos <= ::aSuperHead[ nI, 2 ]
               ::aSuperHead[ nI, 2 ] ++
            ELSEIF nPos < ::aSuperHead[ nI, 1 ]
               ::aSuperHead[ nI, 1 ] ++
               ::aSuperHead[ nI, 2 ] ++
            ENDIF
         NEXT
      ENDIF

      ::Refresh( .F. )
      ::SetFocus()
   ENDIF

   RETURN oColumn  // returns reference to Column object

   * ============================================================================
   * METHOD TSBrowse:IsColVisible() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD IsColVisible( nCol ) CLASS TSBrowse

   LOCAL nCols, nFirstCol, nLastCol, nWidth, nBrwWidth, xVar, ;
      aColSizes := ::GetColSizes()

   nCols     := Len( aColSizes )
   nFirstCol := ::nColPos
   nLastCol  := nFirstCol
   nWidth    := 0
   nBrwWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   IF nCol < ::nColPos .or. ::nColPos <= 0

      RETURN .F.
   ENDIF

   xVar := 1

   WHILE xVar <= ::nFreeze
      nWidth += aColSizes[ xVar++ ]
   ENDDO

   WHILE nWidth < nBrwWidth .and. nLastCol <= nCol .and. nLastCol <= nCols
      nWidth += aColSizes[ nLastCol ]
      nLastCol++
   ENDDO

   IF nCol <= --nLastCol

      RETURN ! nWidth > nBrwWidth
   ENDIF

   RETURN .F.

   * ============================================================================
   * METHOD TSBrowse:IsColVis2() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD IsColVis2( nCol ) CLASS TSBrowse

   LOCAL nCols, nFirstCol, nLastCol, nBrwWidth, ;
      nWidth := 0, ;
      aColSizes := ::GetColSizes()

   nCols     := Len( aColSizes )
   nFirstCol := ::nColPos
   nLastCol  := nFirstCol

   // mt differs from iscolvisible here - allows for frozen column
   IF ::nFreeze > 0
      AEval( aColSizes, {|nSize| nWidth += nSize }, 1, ::nFreeze )
   ENDIF

   nBrwWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 )

   IF nCol < ::nColPos

      RETURN .F.
   ENDIF

   DO WHILE nWidth < nBrwWidth .and. nLastCol <= nCols
      nWidth += aColSizes[ nLastCol ]
      nLastCol++
   ENDDO

   IF nCol <= --nLastCol
      // mt differs from new iscolvisible here

      RETURN .T.
   ENDIF

   RETURN .F.

   * ============================================================================
   * METHOD TSBrowse:Insert() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Insert( cItem, nAt ) CLASS TSBrowse

   LOCAL nMin, nMax, nPage

   DEFAULT nAt := ::nAt, ;
      cItem := AClone( ::aDefValue )

   IF ! ::lIsArr

      RETURN NIL
   ENDIF

   IF ValType( cItem ) == "A" .and. cItem[ 1 ] == Nil
      hb_ADel( cItem, 1, .T. )
   ENDIF

   ASize( ::aArray, Len( ::aArray ) + 1 )
   nAt := Max( 1, nAt )
   AIns( ::aArray, nAt )
   ::aArray[ nAt ] := If( Valtype( cItem ) == "A", cItem, {cItem} )

   ::nLen := Eval( ::bLogicLen )
   IF ::lNoVScroll
      IF ::nLen > ::nRowCount()
         ::lNoVScroll := .F.
      ENDIF
   ENDIF

   IF ! ::lNoVScroll
      nMin  := Min( 1, ::nLen )
      nMax  := Min( ::nLen, MAX_POS )
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll := TSBScrlBar():WinNew( nMin, nMax, nPage, .T., Self )
   ENDIF

   ::Refresh( .T. )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:AddItem() Version 7.0 Oct/10/2007
   * ============================================================================

METHOD AddItem( cItem ) CLASS TSBrowse    // delete in V90

   LOCAL nMin, nMax, nPage

   DEFAULT cItem := AClone( ::aDefValue )

   IF ! ::lIsArr

      RETURN NIL
   ENDIF

   IF ValType( cItem ) == "A" .and. cItem[ 1 ] == Nil
      hb_ADel( cItem, 1, .T. )
   ENDIF

   cItem := If( Valtype( cItem ) == "A", cItem, {cItem} )

   IF ::lPhantArrRow .and. Len(::aArray) == 1
      ::SetArray( {cItem},.t. )
      ::lPhantArrRow := .F.
   ELSEIF  Len(::aArray) == 0
      ::SetArray( {cItem},.t. )
   ELSE
      AAdd(::aArray,  cItem )
   ENDIF

   ::nLen := Eval( ::bLogicLen )
   IF ::lNoVScroll
      IF ::nLen > ::nRowCount()
         ::lNoVScroll := .F.
      ENDIF
   ENDIF

   IF ! ::lNoVScroll
      nMin  := Min( 1, ::nLen )
      nMax  := Min( ::nLen, MAX_POS )
      nPage := Min( ::nRowCount(), ::nLen )
      ::oVScroll := TSBScrlBar():WinNew( nMin, nMax, nPage, .T., Self )
   ENDIF

   ::Refresh( .T. )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:lEditCol() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD lEditCol( uVar, nCol, cPicture, bValid, nClrFore, nClrBack ) CLASS TSBrowse

   RETURN ::Edit( uVar, nCol,,, cPicture, bValid, nClrFore, nClrBack ) // just for compatibility

   * ============================================================================
   * METHOD TSBrowse:lIgnoreKey() Version 9.0 Nov/30/2009
   * Checks if any of the predefined navigation keys has been remapped so as to
   * ignore its default behavior and forward it to TWindow class in case a new
   * behavior has been defined in ::bKeyDown. Uses the new nested array IVar
   * ::aKeyRemap which has the following structure (data type in parens):
   * { { VK_ to ignore(n), alone(l), ctrl(l), shift(l), alt(l), ctrl+shift(l), bBlock }, ... }
   * Example:  AAdd( ::aKeyRemap, { VK_END, .T., .F., .T., .F., .F., { || Tone(600) } } )
   *           will ignore End key alone and with shift+end combinations
   * It's the programmer's (ie you!) responsibility to make sure each subarray
   * has 6 elements of the specified data type or kaboom!
   * This method is called by ::KeyDown() which provides nKey and nFlags.
   * If called directly, you must specify the parameter nKey (nFlags is always ignored)
   * ============================================================================

METHOD lIgnoreKey( nKey, nFlags ) CLASS TSBrowse

   LOCAL lIgnore := .F., ;
      nAsync := 2, ;                // key by itself
   nIgnore := AScan( ::aKeyRemap, {|aRemap| aRemap[ 1 ] == nKey } )

   HB_SYMBOL_UNUSED( nFlags )

   IF nIgnore > 0

      IF _GetKeyState( VK_CONTROL ) .and. _GetKeyState( VK_SHIFT )
         nAsync := 6
      ELSEIF _GetKeyState( VK_CONTROL )
         nAsync := 3
      ELSEIF _GetKeyState( VK_SHIFT )
         nAsync := 4
      ELSEIF _GetKeyState( VK_MENU )                    // alt key
         nAsync := 5
      ENDIF

      lIgnore := ::aKeyRemap[ nIgnore, nAsync ]

      IF lIgnore .and. ValType( ::aKeyRemap[ nIgnore, 7 ] ) == "B"
         Eval( ::aKeyRemap[ nIgnore, 7 ] )
      ENDIF

   ENDIF

   RETURN lIgnore

   * ============================================================================
   * METHOD TSBrowse:LoadRecordSet() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LoadRecordSet() CLASS TSBrowse

   LOCAL n, nE, cHeading, nAlign, aColSizes, cData, cType, nDec, hFont, cBlock, nType, nWidth, ;
      cOrder := Upper( ::oRSet:Sort ), ;
      aAlign := { "LEFT", "CENTER", "RIGHT", "VERT" }, ;
      nCols  := ::oRSet:Fields:Count(), ;
      aRName := {}, ;
      aNames := ::aColSel

   IF ! Empty( aNames )
      FOR n := 1 To nCols
         AAdd( aRName, ::oRSet:Fields( n - 1 ):Name )
      NEXT

      nCols := Len( aNames )
   ENDIF

   cOrder := AllTrim( StrTran( StrTran( cOrder, "ASC" ), "DESC" ) )
   aColSizes := If( Len( ::aColumns ) == Len( ::aColSizes ), Nil, ::aColSizes )

   FOR n := 1 To nCols

      nE := If( Empty( aNames ), n - 1, AScan( aRName, { |e| Upper( e ) == Upper( aNames[ n ] ) } ) - 1 )

      cHeading := If( ! Empty( ::aHeaders ) .and. Len( ::aHeaders ) >= n, ::aHeaders[ n ], ;
         ::Proper( ::oRSet:Fields( nE ):Name ) )

      nAlign := If( ::aJustify != Nil .and. Len( ::aJustify ) >= n, ::aJustify[ n ], ;
         If( ValType( ::oRSet:Fields( nE ):Value ) == "N", 2, ;
         If( ValType( ::oRSet:Fields( nE ):Value ) == "L", 1, 0 ) ) )

      nAlign := If( ValType( nAlign ) == "L", If( nAlign, 2, 0 ), ;
         If( ValType( nAlign ) == "C", AScan( aAlign, nAlign ) - 1, nAlign ) )

      nWidth := If( ! aColSizes == Nil .and. Len( aColsizes ) >= n, aColSizes[ n ], Nil )

      IF nWidth == Nil
         cData := ::oRSet:Fields( nE ):Value
         cType := ClipperFieldType( nType := ::oRSet:Fields( nE ):Type )
         IF ValType( cType ) != "C"
            //msginfo(::oRSet:Fields( nE ):Name,cType)
            LOOP
         ENDIF

         nWidth := If( cType == "N", ::oRSet:Fields( nE ):Precision, ::oRSet:Fields( nE ):DefinedSize )
         nDec   := If( cType != "N", 0, If( nType == adCurrency, 2, ;
            If( ASCan( { adDecimal, adNumeric, adVarNumeric }, nType ) > 0, ::oRSet:Fields( nE ):NumericScale, ;
            0 ) ) )
         hFont := If( ::oFont != Nil, ::oFont:hFont, 0 )

         IF cType == "C" .and. ValType( cData ) == "C"
            cData := PadR( Trim( cData ), nWidth, "B" )
            nWidth := GetTextWidth( 0, cData, hFont )
         ELSEIF cType == "N"
            cData := StrZero( Val( Replicate( "4", nWidth ) ), nDec )
            nWidth := GetTextWidth( 0, cData, hFont )
         ELSEIF cType == "D"
            cData := cValToChar( If( ! Empty( cData ), cData, Date() ) )
            nWidth := Int( GetTextWidth( 0, cData, hFont ) ) + 22
         ELSEIF cType == "M"
            //cData := cValToChar( cData )
            nWidth := If( ::nMemoWV == Nil, 200, ::nMemoWV )
         ELSE
            cData := cValToChar( cData )
            nWidth := GetTextWidth( 0, cData, hFont )
         ENDIF
      ENDIF

      nWidth := Max( nWidth, GetTextWidth( 0, cHeading, hFont ) )
      cBlock := 'AdoGenFldBlk( Self:oRS, ' + LTrim( Str( nE ) ) + ' )'
      ::AddColumn( TSColumn():New( cHeading, AdoGenFldBlk( ::oRSet, nE ),, { ::nClrText, ::nClrPane }, ;
         { nAlign, DT_CENTER }, nWidth,, ::lEditable,,, ::oRSet:Fields( nE ):Name,,,, ;
         5,,,, Self, cBlock ) )
      ATail( ::aColumns ):cDatatype := cType
      ATail( ::aColumns ):Cargo := ::oRSet:Fields( nE ):Name

      IF cOrder == Upper( cHeading )
         ::nColOrder := Len( ::aColumns )
         Atail( ::aColumns ):cOrder := cOrder
      ENDIF
   NEXT

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:LoadRelated() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LoadRelated( cAlias, lEditable, aNames, aHeaders ) CLASS TSBrowse

   LOCAL n, nE, cHeading, nAlign, nSize, cData, cType, nDec, hFont, aStru, nArea, nFields, cBlock

   DEFAULT lEditable := .F.

   IF Empty( cAlias )

      RETURN Self
   ENDIF

   cAlias  := AllTrim( cAlias )
   nArea   := Select( cAlias )
   aStru   := ( cAlias )->( DbStruct() )
   nFields := If( aNames == Nil, ( cAlias )->( FCount() ), Len( aNames ) )

   FOR n := 1 To nFields

      nE := If( aNames == Nil, n, ( cAlias )->( FieldPos( aNames[ n ] ) ) )

      cHeading := If( aHeaders != Nil .and. Len( aHeaders ) >= n, ;
         aHeaders[ n ], cAlias + "->" + ;
         ::Proper( ( cAlias )->( Field( nE ) ) ) )

      nAlign := If( ( cAlias )->( ValType( FieldGet( nE ) ) ) == "N", 2, ;
         If( ( cAlias )->( ValType( FieldGet( nE ) ) ) == "L", 1, 0 ) )

      cData := ( cAlias )->( FieldGet( nE ) )
      cType := ValType( cData )
      nSize := aStru[ nE, 3 ]
      nDec  := aStru[ nE, 4 ]
      hFont := If( ::hFont != Nil, ::hFont, 0 )

      IF cType == "C"
         cData := PadR( Trim( cData ), nSize, "B" )
         nSize := GetTextWidth( 0, cData, hFont )
      ELSEIF cType == "N"
         cData := StrZero( cData, nSize, nDec )
         nSize := GetTextWidth( 0, cData, hFont )
      ELSEIF cType == "D"
         cData := cValToChar( If( ! Empty( cData ), cData, Date() ) )
         nSize := Int( GetTextWidth( 0, cData, hFont ) * 1.15 )
      ELSE
         cData := cValToChar( cData )
         nSize := GetTextWidth( 0, cData, hFont )
      ENDIF

      nSize := Max( GetTextWidth( 0, Replicate( "B", Len( cHeading ) ), ;
         hFont ), nSize )
      cBlock := 'FieldWBlock( "' + ( cAlias )->( Field( nE ) ) + '", Select( "' + ;
         cAlias + '" ) )'
      ::AddColumn( TSColumn():New( cHeading, FieldWBlock( ( cAlias )->( Field( nE ) ), nArea ),, ;
         { ::nClrText, ::nClrPane }, { nAlign, DT_CENTER }, nSize,, lEditable,,,,,,, ;
         5,,,, Self, cBlock ) )

      ATail( ::aColumns ):cAlias := cAlias
      ATail( ::aColumns ):cData  := cAlias + "->" + FieldName( nE )

   NEXT

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:Look3D() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Look3D( lOnOff, nColumn, nLevel, lPhantom ) CLASS TSBrowse

   DEFAULT lOnOff   := .T., ;
      nColumn  :=  0 , ;
      lPhantom := .T., ;
      nLevel   :=  0

   ::l3DLook := lOnOff                              // used internally

   IF nColumn > 0
      IF nLevel = 1 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLook := lOnOff
      ENDIF

      IF nLevel = 2 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLookHead := lOnOff
      ENDIF

      IF nLevel = 3 .or. nLevel = 0
         ::aColumns[ nColumn ]:l3DLookFoot := lOnOff
      ENDIF
   ELSE
      IF nLevel > 0
         AEval( ::aColumns, { | oCol | If( nLevel = 1, oCol:l3DLook := lOnOff, If( nLevel = 2, ;
            oCol:l3DLookHead := lOnOff, oCol:l3DLookFoot := lOnOff ) ) } )
      ELSE
         AEval( ::aColumns, { | oCol | oCol:l3DLook := lOnOff, oCol:l3DLookHead := lOnOff, ;
            oCol:l3DLookFoot := lOnOff } )
      ENDIF
   ENDIF

   IF lPhantom
      ::nPhantom := PHCOL_GRID
   ELSE
      ::nPhantom := PHCOL_NOGRID
   ENDIF

   ::Refresh( .T. )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:LostFocus() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD LostFocus( hCtlFocus ) CLASS TSBrowse

   LOCAL nRecNo, uTag

   DEFAULT ::aControls := {}

   IF ::lEditing .and. Len( ::aControls ) > 0 .and. ;
         hCtlFocus == ::aControls[ 1 ]

      RETURN 0

   ENDIF

   IF ::lEditing

      IF ::aColumns[ ::nCell ]:oEdit != Nil
         IF IsControlDefined (::cChildControl, ::cParentWnd )
            ::aColumns[ ::nCell ]:oEdit:End()
            ::aColumns[ ::nCell ]:oEdit := Nil
         ENDIF
      ENDIF

      ::lEditing := ::lPostEdit := .F.

   ENDIF

   ::lNoPaint := .F.

   ::lFocused := .F.

   IF ! Empty( ::bLostFocus )
      Eval( ::bLostFocus, hCtlFocus )
   ENDIF

   IF ::nLen > 0 .and. ! EmptyAlias( ::cAlias ) .and. ! ::lIconView

      IF ::lIsDbf .and. ( ::cAlias )->( RecNo() ) != ::nLastPos

         IF ::bTagOrder != Nil .and. ::uLastTag != Nil
            uTag := ( ::cAlias )->( Eval( ::bTagOrder ) )
            ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
         ENDIF

         nRecNo := ( ::cAlias )->( RecNo() )
         ( ::cAlias )->( DbGoTo( ::nLastPos ) )

      ENDIF

      IF ::lPainted
         ::DrawSelect()
      ENDIF

      IF nRecNo != Nil

         IF uTag != Nil
            ( ::cAlias )->( Eval( ::bTagOrder, uTag ) )
         ENDIF

         ( ::cAlias )->( DbGoTo( nRecNo ) )
      ENDIF
   ENDIF

   ::lHasFocus := .F.

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:MButtonDown() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD MButtonDown( nRow, nCol, nKeyFlags ) CLASS TSBrowse

   IF ::bMButtonDown != Nil
      Eval( ::bMButtonDown, nRow, nCol, nKeyFlags )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:MouseMove() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD MouseMove( nRowPix, nColPix, nKeyFlags ) CLASS TSBrowse

   LOCAL nI, nIcon, lHeader, lMChange, nFirst, nLast, nDestCol, ;
      cMsg       := ::cMsg, ;
      nColPixPos := 0, ;
      lFrozen    := .F., ;
      nColumn    := Max( 1, ::nAtColActual( nColPix ) ), ;
      nRowLine   := ::GetTxtRow( nRowPix ), cToolTip

   DEFAULT ::lMouseDown  := .F., ;
      ::lNoMoveCols := .F., ;
      ::lDontChange := .F.

   IF ::lIconView

      IF ( nIcon := ::nAtIcon( nRowPix, nColPix ) ) != 0

         IF ::nIconPos != 0 .and. ::nIconPos != nIcon
            ::DrawIcon( ::nIconPos )
         ENDIF

         ::nIconPos := nIcon
         ::DrawIcon( nIcon, .T. )
         CursorHand()

         RETURN 0
      ENDIF
   ENDIF

   IF ::nFreeze > 0

      FOR nI := 1 To ::nFreeze
         nColPixPos += ::GetColSizes()[ nI ]
      NEXT

      IF nColPix < nColPixPos
         lFrozen := .T.
      ENDIF
   ENDIF

   IF nColumn <= ::nColCount()

      IF ( lHeader := ( nRowLine == 0 .or. nRowLine == -2 ) ) .and. ! Empty( ::aColumns ) .and. ;
            ! Empty( ::aColumns[ nColumn ]:cToolTip )
         cToolTip := ::aColumns[ nColumn ]:cToolTip  // column's header tooltip
      ELSE
         cToolTip := ::cToolTip  // grid's tooltip
      ENDIF

      IF ( ::nToolTip != nColumn .or. nRowLine != ::nToolTipRow ) .and. IsWindowHandle( ::hWnd ) .and. IsWindowHandle( hToolTip )

         IF Valtype( ctooltip ) == "B"
            cToolTip := Eval( cToolTip, Self, nColumn, nRowLine )
         ENDIF

         SetToolTip( ::hWnd, cToolTip, hToolTip )
         SysRefresh()

         ::nToolTipRow := nRowLine
      ENDIF

      ::nToolTip := nColumn
   ENDIF

   IF ! ::lGrasp .and. ( lFrozen .or. ! lHeader .or. ! ::lMChange )
      // don't allow MouseMove to drag/resize columns
      // unless in header row and not in frozen zone
      CursorArrow()

      IF ::lCaptured
         IF ::lLineDrag
            ::VertLine()
            ::lLineDrag := .F.
         ENDIF

         ReleaseCapture()
         ::lColDrag := ::lCaptured := ::lMouseDown := .F.
      ELSEIF ::lDontChange
         CursorStop()

         RETURN 0
      ENDIF

      lMChange := ::lMChange  // save it for restore
      ::lMChange := .F.

      IF ::lCellBrw .and. ! Empty( ::aColumns[ Max( 1, ::nAtCol( nColPix ) ) ]:cMsg )
         ::cMsg := ::aColumns[ Max( 1, ::nAtCol( nColPix ) ) ]:cMsg
      ELSE
         ::cMsg := cMsg
      ENDIF

      ::cMsg := If( ValType( ::cMsg ) == "B", Eval( ::cMsg, Self, Max( 1, ::nAtCol( nColPix ) ) ), ::cMsg )
      ::Super:MouseMove( nRowPix, nColPix, nKeyFlags )
      ::lMChange := lMChange
      ::cMsg := cMsg

      RETURN 0
   ENDIF

   IF ::lMChange .and. ! ::lNoMoveCols .and. ! ::lDontChange
      IF lHeader
         IF ! Empty( ::aSuperHead )  .and. !::lLineDrag

            nFirst := 0
            nLast  := 0
            Aeval( ::aSuperHead, { | aSup, nCol | nFirst := If( ::nDragCol >= aSup[1] .and. ::nDragCol <= aSup[ 2 ],nCol,nFirst ), ;
               nLast := max(nLast,aSup[ 2 ])} )

            nDestCol := ::nAtCol( nColPix )
            IF nLast < nDestCol
               nLast := nFirst+1
            ELSE
               Aeval( ::aSuperHead, { | aSup, nCol | nlast := If( nDestCol >= aSup[1] .and. nDestCol <= aSup[ 2 ],nCol,nlast )} )
            ENDIF
            IF nLast != nFirst
               ::lGrasp := .F.
               CursorHand()
               ::lColDrag := ::lCaptured := ::lMouseDown := .F.
            ENDIF
         ENDIF
         IF ::lGrasp             // avoid dragging between header & rows
            ::lGrasp := .F.
            CursorArrow()        // restore default cursor
         ENDIF

         IF ::lColDrag
            CursorSize()
         ELSE
            IF ::lLineDrag
               ::VertLine( nColPix )
               CursorWE()
            ELSE
               IF AScan( ::GetColSizes(), { | nColumn | nColPixPos += nColumn, ;
                     nColPix >= nColPixPos - 2 .and. nColPix <= nColPixPos + 2 }, ::nColPos ) != 0
                  CursorWE()
               ELSE
                  CursorHand()
               ENDIF
            ENDIF
         ENDIF
      ELSEIF ::lGrasp
         ::lCaptured := ::lColDrag := .F.     // to avoid collision with header/column dragging
         ::lMouseDown := .T.                  // has to be down until dragging finishes
         ::Super:MouseMove( nRowPix, nColPix, nKeyFlags )
      ELSE
         CursorArrow()
      ENDIF
   ELSE
      IF ::lDontChange
         CursorStop()
      ELSE
         CursorArrow()
      ENDIF
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:MouseWheel() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD MouseWheel( nKeys, nDelta, nXPos, nYPos ) CLASS TSBrowse

   LOCAL nWParam, oReg, ;
      aCoors := {0,0,0,0}

   HB_SYMBOL_UNUSED( nKeys )

   GetWindowRect( ::hWnd, aCoors )

   IF ::nWheelLines == Nil
      oReg:= Treg32():New( HKEY_CURRENT_USER, "Control Panel\Desktop" )
      ::nWheelLines := Val( oReg:Get( "WheelScrollLines" ) )
      oReg:Close()
   ENDIF

   IF nYPos >= aCoors[ 2 ] .and. nXPos >= aCoors[ 1 ] .and. ;
         nYPos <= ( aCoors[ 4 ] )  .and.  nXPos <= ( aCoors[ 3 ]  )

      IF ( nDelta ) > 0

         IF ! Empty( ::nWheelLines )
            nWParam := SB_LINEUP
            nDelta  := ::nWheelLines * nDelta
         ELSE
            nWParam := SB_PAGEUP
         ENDIF

      ELSE

         IF ! Empty( ::nWheelLines )
            nWParam := SB_LINEDOWN
            nDelta  := ::nWheelLines * Abs( nDelta )
         ELSE
            nWParam := SB_PAGEDOWN
            nDelta := Abs( nDelta )
         ENDIF

      ENDIF

      WHILE nDelta > 1
         ::VScroll( nWParam, 0 )
         nDelta--
      ENDDO
   ENDIF

   RETURN ::VScroll( nWParam, 0 )

   * ============================================================================
   * METHOD TSBrowse:MoveColumn() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD MoveColumn( nColPos, nNewPos ) CLASS TSBrowse

   LOCAL oCol, cOrder, ;
      nMaxCol   := Len( ::aColumns ), ;
      nOrder    := ::nColOrder, ;
      lCurOrder := ( ::nColOrder == nColPos )

   LOCAL lSetOrder := ;
      ( nOrder != nColPos .and. nOrder != nNewPos .and. ::nColOrder == nNewPos )

   IF ! Empty( nColPos ) .and. ! Empty( nNewPos ) .and. ;
         nColPos > ::nFreeze .and. nNewPos > ::nFreeze .and. ;
         nColPos <= nMaxCol .and. nNewPos <= nMaxCol

      oCol   := ::aColumns[ nColPos ]
      cOrder := oCol:cOrder
      oCol:cOrder := Nil                         // avoid ::InsColumn() from seting order...

      ::DelColumn( nColPos )
      ::InsColumn( nNewPos, oCol )
      ::aColumns[ nNewPos ]:cOrder := cOrder     // ...restore ::cOrder (if any)

      IF lSetOrder
         ::SetOrder( nNewPos - 1 )
      ELSEIF lCurOrder
         ::SetOrder( nNewPos )
      ELSEIF nOrder != 0
         // check if current order is in between moving columns
         IF nOrder >= nColPos .and. nOrder <= nNewPos      // left to right movement
            nOrder --
         ELSEIF nOrder <= nColPos .and. nOrder >= nNewPos  // right to left movement
            nOrder ++
         ENDIF

         ::SetOrder( nOrder )

      ENDIF

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:PageDown() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PageDown( nLines ) CLASS TSBrowse

   LOCAL nSkipped, nI, ;
      lPageMode := ::lPageMode, ;
      nTotLines := ::nRowCount()

   DEFAULT nLines := nTotLines

   ::lAppendMode := .F.
   ::ResetSeek()

   IF ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF

   IF ::nLen < 1

      RETURN NIL
   ENDIF

   IF ! ::lHitBottom

      ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

      IF lPageMode .and. ::nRowPos < nLines
         nSkipped := ::Skip( nLines - ::nRowPos )
         lPageMode := .F.
      ELSE
         nSkipped = ::Skip( ( nLines * 2 ) - ::nRowPos )
      ENDIF

      IF nSkipped != 0
         ::lHitTop = .F.
      ENDIF

      DO CASE

      CASE nSkipped == 0
         ::lHitBottom := .T.

         RETURN NIL

      CASE nSkipped < nLines .and. ! lPageMode

         nI := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

         IF ::lIsDbf
            ( ::cAlias )->( DbGoTo( ::nPrevRec ) )
         ELSE
            ::nAt := ::nPrevRec
         ENDIF

         ::DrawLine()

         IF ::lIsDbf
            ( ::cAlias )->( DbGoTo( nI ) )
         ELSE
            ::nAt := nI
         ENDIF

         IF nLines - ::nRowPos < nSkipped

            nKeyPressed := Nil
            ::Skip( -( nLines ) )

            FOR nI = 1 To ( nLines - 1 )
               ::Skip( 1 )
               ::DrawLine( nI )
            NEXT

            ::Skip( 1 )
         ENDIF

         ::nRowPos = Min( ::nRowPos + nSkipped, nTotLines )

      CASE nSkipped < nLines .and. lPageMode
         ::Refresh( .T. )

      OTHERWISE

         FOR nI = nLines To 1 Step -1
            ::Skip( -1 )
         NEXT

         ::Skip( ::nRowPos )
         ::lRepaint := .T.       // JP 1.31
      ENDCASE

      IF nKeyPressed == Nil

         ::Refresh( ::nLen < nTotLines )

         IF ::bChange != Nil
            Eval( ::bChange, Self, VK_NEXT )
         ENDIF

      ELSEIF nSkipped >= nLines
         ::DrawSelect()

      ELSE

         nKeyPressed := Nil
         ::DrawSelect()

         IF ::bChange != Nil
            Eval( ::bChange, Self, VK_NEXT )   // Haz 13/04/2017
         ENDIF

      ENDIF

      IF ::oVScroll != Nil
         IF ! ::lHitBottom
            ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
         ELSE
            ::oVScroll:GoBottom()
         ENDIF
      ENDIF

      IF ::lRepaint .and. ::nRowPos == nTotLines
         IF ::bChange != Nil
            Eval( ::bChange, Self, VK_NEXT )   // GF 15/01/2009
         ENDIF
      ENDIF

   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:PageUp() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PageUp( nLines ) CLASS TSBrowse

   LOCAL nSkipped, nRecNo

   DEFAULT nLines := ::nRowCount()

   ::lHitBottom := .F.
   ::lAppendMode := .F.
   ::ResetSeek()

   IF ::lPageMode .and. ::nRowPos > 1

      ::DrawLine()
      //      nSkipped := ::Skip( -( ::nRowPos - 1 ) )    //V90 active
      ::nRowPos := 1
      ::Refresh( .F. )

      IF ::oVScroll != Nil
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      ENDIF

      IF ::bChange != Nil
         Eval( ::bChange, Self, VK_PRIOR )
      ENDIF

      RETURN Self

   ENDIF

   ::nPrevRec := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )
   nSkipped := ::Skip( -nLines )

   IF ::nLen == 0
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), ;
         Eval( ::bLogicLen ) )
   ENDIF

   IF ::nLen < 1

      RETURN NIL
   ENDIF

   IF ! ::lHitTop

      IF nSkipped == 0
         ::lHitTop := .T.
      ELSE

         IF -nSkipped < nLines .or. ::nAt == 1  // 14.07.2015

            nRecNo := If( ::lIsDbf, ( ::cAlias )->( RecNo() ), ::nAt )

            IF ::lIsDbf
               ( ::cAlias )->( DbGoto( ::nPrevRec ) )
            ELSE
               ::nAt := ::nPrevRec
            ENDIF

            ::DrawLine()
            ::nRowPos := 1
            ::Refresh( .F. )   // GF 14/01/2009

            IF ::lIsDbf
               ( ::cAlias )->( DbGoto( nRecNo ) )
            ELSE
               ::nAt := nRecNo
            ENDIF

            IF ::oVScroll != Nil
               ::oVScroll:SetPos( 1 )
            ENDIF

         ELSE

            IF ::oVScroll != nil
               ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
            ENDIF

         ENDIF

         IF nKeyPressed == Nil

            ::Refresh( .F. )

            IF ::bChange != Nil
               Eval( ::bChange, Self, VK_PRIOR )
            ENDIF

         ELSE

            ::DrawSelect()

            IF -nSkipped < nLines
               nKeyPressed := Nil

               IF ::bChange != Nil
                  Eval( ::bChange, Self, VK_PRIOR )   // GF 15/01/2009
               ENDIF

            ENDIF

         ENDIF

      ENDIF

   ELSE

      IF ::oVScroll != Nil
         ::oVScroll:GoTop()
      ENDIF

   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:Paint() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Paint() CLASS TSBrowse

   LOCAL lAppendMode, nRecNo, uTag, oCol, ;
      nColPos := ::nColPos, ;
      nI      := 1, ;
      nLines  := Min( ( ::nLen + If( ::lAppendMode .and. ! ::lIsArr, 1, 0 ) ), ::nRowCount() ), ;
      nSkipped := 1

   DEFAULT ::lPostEdit   := .F., ;
      ::lFirstPaint := .T., ;
      ::lNoPaint    := .F., ;
      ::lInitGoTop  := .T., ;
      ::nFreeze     := 0

   IF ! ::lRepaint

      RETURN 0
   ENDIF

   IF ::lEditing .and. ! ::lPostEdit .and. ::nLen > 0

      RETURN 0
   ELSEIF ::lEditing .or. ::lNoPaint

      IF ::lDrawHeaders
         ::DrawHeaders()
      ENDIF

      ::DrawSelect()

      RETURN 0
   ENDIF

   IF ::lFirstPaint
      ::Default()
   ENDIF

   ::nRowPos := If( ::lDrawHeaders, Max( 1, ::nRowPos ), ::nRowPos )

   IF ::lIconView
      ::DrawIcons()

      RETURN 0
   ENDIF

   IF Empty( ::aColumns )

      RETURN NIL
   ENDIF

   IF ! ::lPainted
      SetHeights( Self )

      IF ::lSelector
         DEFAULT ::nSelWidth := Max( nBmpWidth( ::hBmpCursor ), Min( ::nHeightHead, 25 ) )

         oCol           := ColClone( ::aColumns[ 1 ], Self )
         oCol:bData     := {||""}
         oCol:cHeading  := ""
         oCol:nWidth    := ::nSelWidth
         oCol:lNoHilite := .T.
         oCol:lFixLite  := Empty( ::hBmpCursor )
         oCol:nClrBack  := oCol:nClrHeadBack
         ::InsColumn( 1, oCol )
         ::nFreeze ++
         ::lLockFreeze := .T.
         ::HiliteCell( Max( ::nCell, ::nFreeze + 1 ) )

         IF ! Empty( ::nColOrder )
            ::nColOrder ++
            ::SetOrder( ::nColOrder )
         ENDIF
      ENDIF

      nLines := Min( ( ::nLen + If( ::lAppendMode .and. ! ::lIsArr, 1, 0 ) ), ::nRowCount() )

      IF ::nLen <= nLines .and. ::nAt > ::nRowPos
         ::nRowPos := ::nAt
      ENDIF

      IF ::lInitGoTop
         ::GoTop()
      ENDIF

      IF ! ::lNoHScroll .and. ::oHScroll != Nil
         ::oHScroll:SetRange( 1, Len( ::aColumns ) )
      ENDIF

      IF ::bInit != Nil
         Eval( ::bInit, Self )
      ENDIF
   ENDIF

   IF ::lDrawHeaders .and. ::nHeightSuper > 0
      ::nColPos := ::nFreeze + 1
      ::DrawSuper()
      ::nColPos := nColPos
   ENDIF

   IF ::lDrawHeaders
      ::nRowPos := Max( 1, ::nRowPos )
      ::DrawHeaders()
   ENDIF

   IF ::lIsDbf .and. ::lPainted .and. ! ::lFocused .and. Select( ::cAlias ) > 0 .and. ;
         ( ::cAlias )->( RecNo() ) != ::nLastPos

      IF ::bTagOrder != Nil .and. ::uLastTag != Nil
         uTag := ( ::cAlias )->( Eval( ::bTagOrder ) )
         ( ::cAlias )->( Eval( ::bTagOrder, ::uLastTag ) )
      ENDIF

      nRecNo := ( ::cAlias )->( RecNo() )
      ( ::cAlias )->( DbGoTo( ::nLastPos ) )

   ENDIF

   IF ::lAppendMode .and. ::lFilterMode
      Eval( ::bGoBottom )
   ENDIF

   ::Skip( 1 - ::nRowPos )

   IF ::lIsArr
      lAppendMode   := ::lAppendMode
      ::lAppendMode := .F.
   ENDIF

   ::nLastPainted := 0

   WHILE nI <= nLines .and. nSkipped == 1

      IF ::nRowPos == nI
         ::DrawSelect()
      ELSE
         ::DrawLine( nI )
      ENDIF

      ::nLastPainted := nI
      nSkipped := ::Skip( 1 )

      IF nSkipped == 1
         nI++
      ENDIF
   ENDDO
   ::nLenPos:=nI  //JP 1.31
   IF ::lIsArr
      ::lAppendMode := lAppendMode
   ENDIF

   IF ::lAppendMode
      nI := Max( 1, --nI )
   ENDIF

   ::Skip( ::nRowPos - nI )

   IF ::nLen < ::nRowPos
      ::nRowPos := ::nLen
   ENDIF

   IF ::lAppendMode .and. ::nLen == ::nRowPos .and. ::nRowPos < nLines
      ::DrawLine( ++ ::nRowPos )
   ENDIF

   IF ! ::lPainted
      IF ::bChange != Nil .and. ! ::lPhantArrRow
         Eval( ::bChange, Self, 0 )
      ENDIF

      IF ::lIsDbf .and. ! ::lNoResetPos

         IF ::bTagOrder != Nil
            ::uLastTag := ( ::cAlias )->( Eval( ::btagOrder ) )
         ENDIF

         ::nLastPos := ( ::cAlias )->( RecNo() )
      ENDIF

      IF ::lCanAppend .and. ::lHasFocus .and. ! ::lAppendMode .and. ::nLen == 0
         ::lHitBottom := .T.
         ::PostMsg( WM_KEYDOWN, VK_DOWN, 0 )
      ELSE
         ::lNoPaint := .T.
      ENDIF
   ENDIF

   ::lPainted := .T.

   IF nRecNo != Nil

      IF uTag != Nil
         ( ::cAlias )->( Eval( ::bTagOrder, uTag ) )
      ENDIF

      ( ::cAlias )->( DbGoTo( nRecNo ) )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:PanEnd() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PanEnd() CLASS TSBrowse

   LOCAL nI, nTxtWid, ;
      nWidth   := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ), ;
      nWide    := 0, ;
      nCols    := Len( ::aColumns )

   ::nOldCell := ::nCell

   IF ::lIsTxt
      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )
      ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
      ::Refresh( .F. )

      IF ! ::lNoHScroll .and. ::oHScroll != Nil
         ::oHScroll:setPos( ::nAt )
      ENDIF

      RETURN Self
   ENDIF

   ::nColPos := nCols
   ::nCell := nCols
   nWide := ::aColSizes[nCols]

   FOR nI := nCols - 1 To 1 Step - 1
      IF nWide + ::aColSizes[nI] <= nWidth
         nWide += ::aColSizes[nI]
         ::nColPos--
      ELSE
         EXIT
      ENDIF
   NEXT

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

   ENDIF

   ::Refresh( .F. )

   IF ! ::lNoHScroll .and. ::oHScroll != Nil
      IF ::oHScroll:nMax != nCols
         ::oHScroll:SetRange( 1, nCols )
      ENDIF
      ::oHScroll:GoBottom()
   ENDIF

   ::HiliteCell( nCols )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:PanHome() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PanHome() CLASS TSBrowse

   LOCAL nColChk, nEle

   ::nOldCell := ::nCell

   IF ::lIsTxt

      ::nAt := 1
      ::Refresh( .F. )

      IF ::oHScroll != Nil
         ::oHScroll:setPos( ::nAt )
      ENDIF

      RETURN Self
   ENDIF

   FOR nEle := 1 To Len( ::aColumns )
      IF ! ::aColumns[ nEle ]:lNoHilite
         nColChk := nEle
         EXIT
      ENDIF
   NEXT

   ::nColPos := 1
   ::nCell := nColChk

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

   ENDIF

   IF ! ::lEditing
      ::Refresh( .F. )
   ELSE
      ::Paint()
   ENDIF

   IF ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   ENDIF

   ::HiliteCell( ::nCell )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:PanLeft() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PanLeft() CLASS TSBrowse

   LOCAL nI,;
      nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ),;
      nWide  := 0,;
      nCols  := Len( ::aColumns ),;
      nPos   := ::nColPos,;
      nFirst := If( ::lLockFreeze .and. ::nFreeze > 0, ::nFreeze + 1, 1 )

   ::nOldCell := ::nCell

   IF ::lIsTxt

      IF ::nAt > 11
         ::nAt := ::nAt - 10
      ELSE
         ::nAt := 1
      ENDIF
      IF ::oHScroll != Nil
         ::oHScroll:SetPos( ::nAt )
      ENDIF
      ::Refresh( .F. )

      RETURN Self
   ENDIF

   IF ::nFreeze >= nCols

      RETURN Self
   ENDIF

   AEval( ::aColSizes, { | nSize | nWide += nSize } )

   IF  nWide <= nWidth                           // browse fits all inside
      ::nCell := nFirst                          // window or dialog
      ::nColPos := 1
   ELSE
      nWide := ::aColSizes[nPos]
      FOR nI := nPos - 1 To nFirst Step - 1
         IF nWide <= nWidth
            nWide += ::aColSizes[ nI ]
            ::nCell := nI
         ELSE
            EXIT
         ENDIF
      NEXT
      ::nColPos := ::nCell                       // current column becomes first in offset
   ENDIF

   IF ! ::lCellBrw .and. ! ::lLockFreeze .and. ;  // for frozen columns
      ::nFreeze > 0 .and. ::nCell - 1 == 1
      ::nCell := ::nColPos := ::nFreeze
   ENDIF

   IF ::nCell != ::nOldCell
      ::Refresh( .F. )
   ENDIF

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

   ENDIF

   IF ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   ENDIF

   IF ::lCellBrw
      ::HiliteCell( ::nCell )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:PanRight() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PanRight() CLASS TSBrowse

   LOCAL nTxtWid, nI,;
      nWidth := ::nWidth() - If( ::oVScroll != Nil, GetSysMetrics( 2 ), 0 ),;
      nWide  := 0,;
      nCols  := Len( ::aColumns ),;
      nPos   := ::nColPos

   ::nOldCell := ::nCell

   IF ::lIsTxt

      nTxtWid := Max( 1, GetTextWidth( 0, "B", If( ::hFont != nil, ::hFont, 0 ) ) )

      IF ::nAt < ::oTxtFile:nMaxLineLength - 21 - Int( nWidth / nTxtWid )
         ::nAt := ::nAt + 20
      ELSE
         ::nAt := ::oTxtFile:nMaxLineLength - Int( nWidth / nTxtWid )
      ENDIF

      IF ::oHScroll != Nil
         ::oHScroll:SetPos( ::nAt )
      ENDIF

      ::Refresh( .F. )

      RETURN Self
   ENDIF

   IF ::nFreeze >= nCols

      RETURN Self
   ENDIF

   AEval( ::aColSizes, {|nSize| nWide += nSize }, nPos )

   IF ::nFreeze > 0
      AEval( ::aColSizes, {|nSize| nWide += nSize }, 1, ::nFreeze )
   ENDIF

   IF nWide <= nWidth     // we're in last columns (including the current one),
      ::nCell := nCols    // so just ::nCell changes, not ::nColPos
   ELSE
      nWide := 0
      AEval( ::aColSizes, {|nSize| nWide += nSize }, nPos + 1 )

      IF ::nFreeze > 0
         AEval( ::aColSizes, {|nSize| nWide += nSize }, 1, ::nFreeze )
      ENDIF

      IF nWide <= nWidth .and. nPos < nCols      // the remaining columns are added
         ::nCell := nPos + 1                     // the last in the browse
         nPos := nCols                           // so as to avoid For..Next
      ENDIF

      nWide := ::aColSizes[nPos]

      FOR nI := nPos + 1 To nCols
         IF ( nWide + ::aColSizes[nI] <= nWidth ) .or. ;
               ( nI - nPos < 2 .and. nWide + ::aColSizes[nI] > nWidth )  // two consecutive very wide columns
            nWide += ::aColSizes[nI]
            ::nCell := nI
         ELSE
            EXIT
         ENDIF
      NEXT
      ::nColPos := ::nCell                       // last column becomes first in offset
   ENDIF

   IF ! ::lCellBrw .and. ;                       // for frozen columns
      If( ::nFreeze > 0, ::IsColVis2( nCols ), ::IsColVisible( nCols ) )

      ::nCell := nCols

   ENDIF

   IF ::nCell != ::nOldCell
      ::Refresh( .F. )
   ENDIF

   IF ::lCellBrw

      IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
      ENDIF

      IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
         Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
      ENDIF

      ::nOldCell := ::nCell

   ENDIF

   IF ::oHScroll != Nil
      ::oHScroll:SetPos( ::nCell )
   ENDIF

   ::HiliteCell( ::nCell )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:Proper() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Proper( cString ) CLASS TSBrowse

   LOCAL nPos, cChr, cTxt, cAnt, ;
      nLen := Len( cString )

   cString := Lower( Trim( cString ) ) + " "

   nPos := 1
   cAnt := "."
   cTxt := ""

   WHILE nPos <= Len( cString )
      cChr := SubStr( cString, nPos, 1 )
      cTxt += If( cAnt $ '".,-/ (', Upper( cChr ), If( Asc( cChr ) == 209, Chr( 241 ), cChr ) )
      cAnt := cChr
      nPos++
   ENDDO

   cTxt := StrTran( cTxt, ::aMsg[ 51 ], Lower( ::aMsg[ 51 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 52 ], Lower( ::aMsg[ 52 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 53 ], Lower( ::aMsg[ 53 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 54 ], Lower( ::aMsg[ 54 ] ) )
   cTxt := StrTran( cTxt, ::aMsg[ 55 ], Lower( ::aMsg[ 55 ] ) )

   RETURN PadR( cTxt, nLen )

   * ============================================================================
   * METHOD TSBrowse:PostEdit() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD PostEdit( uTemp, nCol, bValid ) CLASS TSBrowse

   LOCAL aMoveCell, bRecLock, bAddRec, cAlias, uRet, ;
      nLastKey := ::oWnd:nLastKey, ;
      lAppend  := ::lAppendMode

   cAlias := If( ::lIsDbf .and. ::aColumns[ nCol ]:cAlias != Nil, ::aColumns[ nCol ]:cAlias, ::cAlias )

   aMoveCell := { {|| ::GoRight() }, {|| ::GoDown() }, {|| ::GoLeft() },  {|| ::GoUp() }, {|| ::GoNext() } }

   bRecLock := If( ! Empty( ::bRecLock ), ::bRecLock, {|| ( cAlias )->( RLock() ) } )

   bAddRec := If( ! Empty( ::bAddRec ), ::bAddRec, {|| ( cAlias )->( dbAppend() ), ! NetErr() } )

   IF bValid != Nil

      uRet := Eval( bValid, uTemp, Self )

      IF ValType( uRet ) == "B"
         uRet := Eval( uRet, uTemp, Self )
      ENDIF

      IF ! uRet

         Tone( 500, 1 )
         ::lEditing  := ::lPostEdit := ::lNoPaint := .F.

         IF lAppend
            ::lAppendMode := .F.
            ::lHitBottom  := .F.
            ::GoBottom()
            ::HiliteCell( nCol )
            lNoAppend := .T.
            ::lCanAppend := .F.
         ELSE
            ::DrawSelect()
         ENDIF

         RETURN NIL

      ENDIF

   ENDIF

   IF ::lIsDbf

      IF Eval( If( ! ::lAppendMode, bRecLock, bAddRec ), uTemp )

         Eval( ::aColumns[ nCol ]:bData, uTemp, Self )
         SysRefresh()

         IF lAppend

            IF ! Empty( ::aDefault )
               ASize( ::aDefault, Len( ::aColumns ) )
               AEval( ::aDefault, { | e, n | If( e != Nil .and. n != nCol, If( Valtype( e ) == "B", ;
                  Eval( ::aColumns[ n ]:bData, Eval( e, Self ) ), ;
                  Eval( ::aColumns[ n ]:bData, e ) ), Nil ) } )
               ::DrawLine()
            ENDIF
            #ifdef _TSBFILTER7_
            IF ::lFilterMode .and. ::aColumns[ nCol ]:lIndexCol

               IF &( ( cAlias )->( IndexKey() ) ) >= ::uValue1 .and. ;
                     &( ( cAlias )->( IndexKey() ) ) <= ::uValue2

                  ::nLen := ( cAlias )->( Eval( ::bLogicLen() ) )
                  ::nRowPos := ::nAt := Min( ::nRowCount, ::nLen )
               ELSE
                  ::lChanged := .F.
                  ( cAlias )->( DbGoTo( ::nPrevRec ) )
                  ::Refresh( .F. )
               ENDIF

            ELSE
               ::nLen++
            ENDIF
            #else
            ::nLen++
            #endif
            ::lAppendMode := .F.

            IF ::nRowPos == 0 .and. ::lDrawHeaders
               ::nRowPos := ::nAt := 1
            ENDIF

            IF ::oVScroll != Nil
               ::oVScroll:SetRange( 1, Max( 1, ::nLen ) )
               ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
            ENDIF

            ::DrawLine( ::nRowPos )
         ENDIF

         IF ::aColumns[ nCol ]:bPostEdit != Nil
            Eval( ::aColumns[ nCol ]:bPostEdit, uTemp, Self, lAppend )
         ENDIF

         ::lEditing  := .F.
         ::lPostEdit := .F.
         ::lUpdated  := .T.
         IF !("SQL" $ ::cDriver)
            ( cAlias )->( DbUnLock() )
         ENDIF

         IF lAppend
            IF ::bChange != Nil
               Eval( ::bChange, Self, ::oWnd:nLastKey )
            ENDIF

            lAppend := .F.
            AEval( ::aColumns, { |oC| lAppend := If( oC:lIndexCol, .T., lAppend ) } )
         ENDIF

         IF ( ::aColumns[ nCol ]:lIndexCol .and. ::lChanged ) .or. lAppend
            ::lNoPaint := .F.
            #ifdef _TSBFILTER7_
            IF ::lFilterMode

               IF &( ( cAlias )->( IndexKey() ) ) >= ::uValue1 .and. ;
                     &( ( cAlias )->( IndexKey() ) ) <= ::uValue2

                  ::UpStable()

               ELSE
                  ::Reset()
               ENDIF

            ELSE
               ::UpStable()
            ENDIF
            #else
            ::UpStable()
            #endif
         ENDIF

         ( cAlias )->( DbSkip( 0 ) )  // refresh relations just in case that a relation field changes

         ::SetFocus()

         IF nLastKey == VK_UP
            ::GoUp()
         ELSEIF nLastkey == VK_RIGHT
            ::GoRight()
         ELSEIF nLastkey == VK_LEFT
            ::GoLeft()
         ELSEIF nLastkey == VK_DOWN
            ::GoDown()
            ::Refresh( .F. )
         ELSEIF ::aColumns[ nCol ]:nEditMove >= 1 .and. ::aColumns[ nCol ]:nEditMove <= 5  // excel-like behavior post-edit movement
            Eval( aMoveCell[ ::aColumns[ nCol ]:nEditMove ] )
            ::DrawSelect()
            IF ! ::lAppendMode
               ::Refresh( .F. )
            ENDIF
         ELSEIF ::aColumns[ nCol ]:nEditMove == 0 .and. ! ::lAutoEdit
            ::DrawSelect()
         ENDIF

         ::oWnd:nLastKey := Nil

         IF ::lAutoEdit .and. ! lAppend
            SysRefresh()

            IF ! ::aColumns[ ::nCell ]:lCheckBox
               ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
            ENDIF

            RETURN NIL
         ENDIF

      ELSE
         IF ! lAppend .and. Empty( ::bRecLock )
            MsgStop( ::aMsg[ 3 ], ::aMsg[ 4 ] )
         ELSEIF lAppend .and. Empty( ::bAddRec )
            MsgStop( ::aMsg[ 5 ], ::aMsg[ 4 ] )
         ENDIF
      ENDIF
   ELSE
      IF lAppend .and. ::lIsArr
         // when ::aDefValue[1] == Nil, it flags this element
         // as the equivalent of the "record no" for the array
         // this is why ::aDefValue will have one more element
         // than Len( ::aArray )
         ::lAppendMode := .F.
         AAdd( ::aArray, Array( Len( ::aDefValue ) - If( ::aDefValue[ 1 ] == Nil, 1, 0 ) ) )
         ::nAt := ::nLen := Len( ::aArray )

         IF ::oVScroll != Nil
            ::oVScroll:SetRange( 1, Max( 1, ::nLen ) )
            ::oVScroll:GoBottom()
         ENDIF

         AEval( ATail( ::aArray ), ;
            { | uVal, n | ::aArray[ ::nAt, n ] := ::aDefValue[ n + If( ::aDefValue[ 1 ] == Nil, 1, 0 ) ],HB_SYMBOL_UNUSED( uVal ) } )

      ENDIF

      Eval( ::aColumns[ nCol ]:bData, uTemp )
      SysRefresh()

      IF ::aColumns[ nCol ]:bPostEdit != Nil
         Eval( ::aColumns[ nCol ]:bPostEdit, uTemp, Self, lAppend )
      ENDIF

      ::lEditing  := .F.
      ::lPostEdit := .F.

      IF lAppend
         IF ! Empty( ::aDefault )
            ASize( ::aDefault, Len( ::aColumns ) )
            AEval( ::aDefault, { | e, n | If( e != Nil .and. n != nCol, If( Valtype( e ) == "B", ;
               Eval( ::aColumns[ n ]:bData, Eval( e, Self ) ), Eval( ::aColumns[ n ]:bData, e ) ), Nil ) } )
         ENDIF
         ::DrawLine()
      ENDIF

      IF lAppend .and. ::nLen <= ::nRowCount()
         ::Refresh( .T. )
         ::nRowPos := Min( ::nRowCount(), ::nLen )
      ENDIF

      IF lAppend .and. ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      ENDIF

      ::SetFocus()

      IF nLastKey == VK_UP
         ::GoUp()
      ELSEIF nLastkey == VK_RIGHT
         ::GoRight()
      ELSEIF nLastkey == VK_LEFT
         ::GoLeft()
      ELSEIF nLastkey == VK_DOWN
         ::GoDown()
         ::Refresh( .F. )
      ELSEIF ::aColumns[ nCol ]:nEditMove >= 1 .and. ::aColumns[ nCol ]:nEditMove <= 5  // excel-like behaviour post-edit movement
         Eval( aMoveCell[ ::aColumns[ nCol ]:nEditMove ] )
      ELSEIF ::aColumns[ nCol ]:nEditMove == 0
         ::DrawSelect()
      ENDIF

      ::oWnd:nLastKey := Nil

      IF ::lAutoEdit .and. ! lAppend
         SysRefresh()
         IF ! ::aColumns[ ::nCell ]:lCheckBox
            ::PostMsg( WM_KEYDOWN, VK_RETURN, nMakeLong( 0, 0 ) )
         ENDIF
      ENDIF

   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:RButtonDown() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD RButtonDown( nRowPix, nColPix, nFlags ) CLASS TSBrowse

   LOCAL nRow, nCol, nSkipped, bRClicked, lHeader, lFooter, lSpecHd, ;
      uPar1 := nRowPix, ;
      uPar2 := nColPix

   HB_SYMBOL_UNUSED( nFlags )

   DEFAULT ::lNoPopup    := .T., ;
      ::lNoMoveCols := .F.

   ::lNoPaint := .F.

   ::SetFocus()
   ::oWnd:nLastKey := 0

   IF ::nLen < 1

      RETURN 0
   ENDIF

   nRow    := ::GetTxtRow( nRowPix )
   nCol    := ::nAtCol( nColPix )
   lHeader := nRow == 0
   lFooter := nRow == -1
   lSpecHd := nRow == -2
   //lNoEdit := ! ::aColumns[ nCol ]:lEdit

   IF nRow > 0

      IF ::lPopupActiv
         _ShowControlContextMenu( ::cControlName, ::cParentWnd, .f. )
      ENDIF

      IF ::lDontChange

         RETURN 0
      ENDIF

      IF nCol <= ::nFreeze .and. ::lLockFreeze

         RETURN 0
      ENDIF

      IF ::lNoMoveCols

         RETURN 0
      ENDIF

      ::ResetSeek()
      ::DrawLine()

      nSkipped  := ::Skip( nRow - ::nRowPos )
      ::nRowPos += nSkipped
      ::nCell := nCol

      IF ! ::lNoVScroll
         ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
      ENDIF

      IF ! ::lNoHScroll
         ::oHScroll:SetPos( ::nCell )
      ENDIF

      IF nSkipped != 0 .and. ::bChange != Nil
         Eval( ::bChange, Self, ::oWnd:nLastKey )
      ENDIF

      IF ::lCellBrw

         IF ::aColumns[ ::nCell ]:bGotFocus != Nil .and. ::nOldCell != ::nCell
            Eval( ::aColumns[ ::nCell ]:bGotFocus, ::nOldCell, ::nCell, Self )
         ENDIF

         IF ::aColumns[ ::nOldCell ]:bLostFocus != Nil .and. ::nOldCell != ::nCell
            Eval( ::aColumns[ ::nOldCell ]:bLostFocus, ::nCell, ::nOldCell, Self )
         ENDIF

         ::nOldCell := ::nCell
         ::HiliteCell( ::nCell )

      ENDIF

      ::DrawSelect()
      bRClicked := If( ::aColumns[ nCol ]:bRClicked != Nil, ;
         ::aColumns[ nCol ]:bRClicked, ::bRClicked )

      IF bRClicked != Nil
         Eval( bRClicked, uPar1, uPar2, ::nAt, Self )
      ENDIF

      RETURN 0

   ELSEIF lHeader
      IF ::lPopupActiv
         IF ::lPopupUser
            IF  AScan( ::aPopupCol, nCol ) > 0 .or. ::aPopupCol[1] == 0
               IF ::nPopupActiv == nCol
                  _ShowControlContextMenu( ::cControlName, ::cParentWnd, .t. )
               ELSE
                  IF ::bUserPopupItem != Nil
                     Eval( ::bUserPopupItem, nCol )
                     ::nPopupActiv := nCol
                  ENDIF
               ENDIF
            ELSE
               _ShowControlContextMenu( ::cControlName, ::cParentWnd, .f. )
            ENDIF
         ELSE
            _ShowControlContextMenu( ::cControlName, ::cParentWnd, .t. )
         ENDIF
      ENDIF

      IF ::aColumns[ nCol ]:bHRClicked != Nil
         Eval( ::aColumns[ nCol ]:bHRClicked, uPar1, uPar2, ::nAt, Self )
      ENDIF
   ELSEIF lSpecHd
      IF ::aColumns[ nCol ]:bSRClicked != Nil
         Eval( ::aColumns[ nCol ]:bSRClicked, uPar1, uPar2, ::nAt, Self )
      ENDIF
   ELSEIF lFooter
      IF ::aColumns[ nCol ]:bFRClicked != Nil
         Eval( ::aColumns[ nCol ]:bFRClicked, uPar1, uPar2, ::nAt, Self )
      ENDIF
   ENDIF

   IF nCol <= ::nFreeze .or. ::lNoPopup

      RETURN 0
   ENDIF

   IF ::lPopupUser
      IF ::bUserPopupItem != Nil
         IF ! ::lPopupActiv
            IF  AScan( ::aPopupCol, nCol ) > 0 .or. ::aPopupCol[1] == 0
               _DefineControlContextMenu( ::cControlName, ::cParentWnd )

               EVAL( ::bUserPopupItem, nCol )

            END MENU
            ::nPopupActiv := nCol
            ::lPopupActiv := .T.
         ENDIF
      ENDIF
   ENDIF
ELSE
   IF ! ::lPopupActiv
      _DefineControlContextMenu( ::cControlName, ::cParentWnd )
      IF ::lUnDo
         MENUITEM ::aMsg[ 6 ] + Space( 1 ) + ::aClipBoard[ 3 ] ;
            ACTION {|| ::InsColumn( ::aClipBoard[ 2 ], ;
            ::aClipBoard[ 1 ] ), ;
            ::nCell := ::aClipBoard[ 2 ], ::Refresh( .T. ), ;
            ::aClipBoard := Nil, ::lUnDo := .F. } NAME M_UNDO
      ELSE
         MENUITEM ::aMsg[ 6 ] ACTION Nil DISABLED NAME M_UNDO
      ENDIF
      MENUITEM ::aMsg[ 7 ]  ;
         ACTION {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 12 ] } } NAME M_COPY

      MENUITEM ::aMsg[ 8 ]  ;
         ACTION {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 13 ] }, ;
         ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. }  NAME M_CUT
      IF ::aClipBoard != Nil .and. ::aClipBoard[ 3 ] != ::aMsg[ 12 ]
         MENUITEM ::aMsg[ 9 ] ;
            ACTION {|| ::InsColumn( nCol, ::aClipBoard[ 1 ] ), ::nCell := nCol, ::Refresh( .T. ), ;
            ::aClipBoard := Nil, ::lUnDo := .F. } NAME M_PASTE
      ELSE
         MENUITEM ::aMsg[ 9 ] ACTION Nil DISABLED NAME M_PASTE
      ENDIF
      SEPARATOR

      MENUITEM ::aMsg[ 10 ]  ;
         ACTION  {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 11 ] }, ;
         ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. } NAME M_DEL

   END MENU
   ::lPopupActiv := .T.
ELSE
   IF ::lUnDo
      _ModifyMenuItem ( "M_UNDO" , ::cParentWnd ,::aMsg[ 6 ] + Space( 1 ) + ::aClipBoard[ 3 ] ,;
         {|| ::InsColumn( ::aClipBoard[ 2 ], ;
         ::aClipBoard[ 1 ] ), ;
         ::nCell := ::aClipBoard[ 2 ], ::Refresh( .T. ), ;
         ::aClipBoard := Nil, ::lUnDo := .F. }, "M_UNDO", "" )
      _EnableMenuItem ( "M_UNDO" , ::cParentWnd )
   ELSE
      _ModifyMenuItem ( "M_UNDO" , ::cParentWnd ,::aMsg[ 6 ],Nil,"M_UNDO","" )
      _DisableMenuItem ( "M_UNDO" , ::cParentWnd )
   ENDIF
   _ModifyMenuItem ( "M_COPY" , ::cParentWnd ,::aMsg[ 7 ],;
      {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 12 ] } },"M_COPY","" )
   _ModifyMenuItem ( "M_CUT" , ::cParentWnd ,::aMsg[ 8 ],;
      {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 13 ] }, ;
      ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. },"M_CUT","" )
   IF ::aClipBoard != Nil .and. ::aClipBoard[ 3 ] != ::aMsg[ 12 ]
      _ModifyMenuItem ( "M_PASTE" , ::cParentWnd ,::aMsg[ 9 ], ;
         {|| ::InsColumn( nCol, ::aClipBoard[ 1 ] ), ::nCell := nCol, ::Refresh( .T. ), ;
         ::aClipBoard := Nil, ::lUnDo := .F. },"M_PASTE","" )
      _EnableMenuItem ( "M_PASTE" , ::cParentWnd )
   ELSE
      _ModifyMenuItem ( "M_PASTE" , ::cParentWnd ,::aMsg[ 9 ], Nil ,"M_PASTE","" )
      _DisableMenuItem ( "M_PASTE" , ::cParentWnd )
   ENDIF
   _ModifyMenuItem ( "M_DEL" , ::cParentWnd ,::aMsg[ 10 ],;
      {|| ::aClipBoard := { ColClone( ::aColumns[ nCol ],Self ), nCol, ::aMsg[ 11 ] }, ;
      ::DelColumn( nCol ), ::Refresh( .T. ), ::lUnDo := .T. },"M_DEL","" )
ENDIF
ENDIF

RETURN 0

* ============================================================================
* METHOD TSBrowse:Refresh() Version 9.0 Nov/30/2009
* ============================================================================

METHOD Refresh( lPaint, lRecount ) CLASS TSBrowse

   DEFAULT lPaint   := .T., ;
      lRecount := .F.

   IF ::lFirstPaint == Nil .or. ::lFirstPaint

      RETURN 0
   ENDIF

   IF lRecount .or. Empty( ::nLen )
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
   ENDIF

   ::lNoPaint := .F.

   RETURN ::Super:Refresh( lPaint )

   * ============================================================================
   * METHOD TSBrowse:RelPos() Version 9.0 Nov/30/2009
   * Calculates the relative position of vertical scroll box in huge databases
   * ============================================================================

METHOD RelPos( nLogicPos ) CLASS TSBrowse

   LOCAL nRet

   IF ::nLen > MAX_POS
      nRet := Int( nLogicPos * ( MAX_POS / ::nLen ) )
   ELSE
      nRet := nLogicPos
   ENDIF

   RETURN nRet

   * ============================================================================
   * METHOD TSBrowse:Report() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Report( cTitle, aCols, lPreview, lMultiple, lLandscape, lFromPos, aTotal ) CLASS TSBrowse

   LOCAL nI, nRecNo, nSize, cAlias, ;
      aHeader1 := {}, ;
      aHeader2 := {}, ;
      aFields  := {}, ;
      aWidths  := {}, ;
      aFormats := {}, ;
      hFont    := ::hFont
   #ifdef _TSBFILTER7_
   LOCAL cFilterBlock

   #endif

   DEFAULT cTitle     := ::oWnd:GetText(), ;
      lPreview   := .T., ;
      lMultiple  := .F., ;
      lLandscape := .F., ;
      lFromPos   := .F.

   ::lNoPaint := .F.

   IF aCols == Nil

      aCols := {}

      FOR nI := 1 To Len( ::aColumns )
         AAdd( aCols, nI )
      NEXT

   ENDIF

   IF aTotal == Nil
      aTotal := AFill( Array( Len(aCols) ), .F. )
   ELSE
      IF Len( aTotal ) <> Len( aCols )
         ASize( aTotal, Len(aCols) )
      ENDIF
      FOR nI := 1 To Len( aCols )
         IF aTotal[nI] == Nil
            aTotal[nI] := .F.
         ENDIF
      NEXT
   ENDIF

   IF ::lIsDbf
      nRecNo := ( ::cAlias )->( RecNo() )
      cAlias := ::cAlias
   ENDIF

   IF lFromPos
      ::lNoResetPos := .F.
   ELSE
      ::GoTop()
   ENDIF
   Eval( ::bGoTop )

   FOR nI := If( ::lSelector, 2, 1 ) To Len( aCols )

      IF ! ::aColumns[ aCols[ nI ] ]:lBitMap

         nSize := Max( 1, Round( ::aColSizes[ aCols[ nI ] ] / ;
            GetTextWidth( 0, "b", If( hFont != Nil, ;
            hFont, ::hFont ) ), 0 ) )
         AAdd ( aWidths, nSize )
         AAdd ( aHeader1, "")
         AAdd ( aHeader2, ::aColumns[ aCols[ nI ] ]:cHeading )
         AAdd ( aFields , ::aColumns[ aCols[ nI ] ]:cData )
         AAdd ( aFormats, iif( ::aColumns[ aCols[ nI ] ]:cPicture != Nil, ::aColumns[ aCols[ nI ] ]:cPicture, '' ) ) // Nil or char.

      ENDIF

   NEXT

   #ifdef _TSBFILTER7_
   IF ::lIsDbf .AND. ::lFilterMode

      cFilterBlock := BuildFiltr( ::cField, ::uValue1, ::uValue2, SELF )

      ( cAlias )->( DbSetFilter( &(cFilterBlock) , cFilterBlock ) )
      ( cAlias )->( DbGoTop() )

   ENDIF
   #endif

   IF ::lIsDbf

      EasyReport ( cTitle +"|"+ ::aMsg[ 20 ] + Space( 1 ) + ;
         DToC( Date() ) + " - " + ::aMsg[ 22 ] + Space( 1 ) + Time() , ;
         aHeader1 , aHeader2 , ;
         aFields , aWidths , aTotal , ,.F. , lPreview ,,,,,, ;
         lMultiple ,,,     ;
         lLandscape ,,.t., ;
         cAlias ,,aFormats,;
         DMPAPER_A4 ,, .t. )

      ( ::cAlias )->( DbGoTo( nRecNo ) )
   ENDIF

   #ifdef _TSBFILTER7_
   IF ::lIsDbf .AND. ::lFilterMode
      ( cAlias )->( DbClearFilter() )
   ENDIF
   #endif

   ::lHitTop := .F.
   ::SetFocus()

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:Reset() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Reset( lBottom ) CLASS TSBrowse

   LOCAL nMin, nMax, nPage

   DEFAULT lBottom := .F., ;
      ::lInitGoTop := .F.

   IF ::lIsDbf
      ::nLen := ( ::cAlias )->( Eval( ::bLogicLen ) )
   ELSE
      ::nLen := Eval( ::bLogicLen )
   ENDIF

   IF ! ::lNoVScroll .and. ::oVScroll != Nil

      IF ::nLen <= ::nRowCount()
         ::oVScroll:SetRange( 0, 0 )
      ELSE
         nMin  := Min( 1, ::nLen )
         nMax  := Min( ::nLen, MAX_POS )
         nPage := Min( ::nRowCount(), ::nLen )
         ::oVScroll:SetRange( nMin, nMax )
      ENDIF

   ENDIF

   ::lNoPaint := .F.
   ::lHitTop  := ::lHitBottom := .F.
   ::nColPos  := 1

   IF lBottom
      ::GoBottom()
   ELSEIF ::lInitGoTop
      ::GoTop()
   ENDIF

   ::Refresh( .T., .T. )

   IF ::bChange != Nil
      Eval( ::bChange, Self, 0 )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:ResetVScroll() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ResetVScroll( lInit ) CLASS TSBrowse

   LOCAL nMin, nMax, nPage, ;
      nLogicPos := ::nLogicPos()

   DEFAULT lInit := .F.

   IF ::nLen <= ::nRowCount()
      nMin := nMax := 0
   ELSE
      nMin := Min( 1, ::nLen )
      nMax := Min( ::nLen, MAX_POS )
   ENDIF

   IF lInit .and. ! ::lNoVScroll

      IF ::oVScroll == Nil
         nPage := Min( ::nRowCount(), ::nLen )
         ::oVScroll := TSBScrlBar ():WinNew( nMin, nMax, nPage, .T., Self )
      ELSE
         ::oVScroll:SetRange( nMin, nMax )
      ENDIF

      ::oVScroll:SetPos( ::RelPos( nLogicPos ) )
   ELSEIF ::oVScroll != Nil
      ::oVScroll:SetRange( nMin, nMax )
      ::oVScroll:SetPos( ::RelPos( ::nLogicPos() ) )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:ResetSeek() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ResetSeek() CLASS TSBrowse

   IF ::nColOrder > 0
      IF ::cOrderType == "D"
         ::cSeek := "  /  /    "
      ELSE
         ::cSeek := ""
      ENDIF
   ENDIF

   IF ::bSeekChange != Nil
      Eval( ::bSeekChange )
   ENDIF

   nNewEle := 0

   RETURN ::cSeek

   * ============================================================================
   * METHOD TSBrowse:ReSize() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ReSize( nSizeType, nWidth, nHeight ) CLASS TSBrowse

   LOCAL nTotPix := 0

   IF Empty( ::aColSizes )

      RETURN NIL
   ENDIF

   AEval( ::aColumns, { | oCol | iif( oCol:lVisible, nTotPix += oCol:nWidth, Nil ) } )  // 14.07.2015

   IF ::lEditing .and. ::aColumns[ ::nCell ]:oEdit != Nil .and. IsWindowHandle( ::aColumns[ ::nCell ]:oEdit:hWnd )
      SendMessage( ::aColumns[ ::nCell ]:oEdit:hWnd, WM_KEYDOWN, VK_ESCAPE, 0 )
   ENDIF

   IF ! Empty( ::nAdjColumn )
      ::nAdjColumn := Min( Len( ::aColumns ), ::nAdjColumn )
   ENDIF

   ::nRowPos := Min( ::nRowPos, Max( ::nRowCount(), 1 ) )

   IF ! Empty( ::nAdjColumn ) .and. nTotPix != nWidth
      ::aColumns[ ::nAdjColumn ]:nWidth := ;
         ::aColSizes[ ::nAdjColumn ] += ( nWidth - nTotPix )
   ENDIF

   RETURN ::Super:ReSize( nSizeType, nWidth, nHeight )

   * ============================================================================
   * METHOD TSBrowse:Seek() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Seek( nKey ) CLASS TSBrowse

   LOCAL nIdxLen, cPrefix, lFound, lEoF, nRecNo, ;
      nLines    := ::nRowCount(), ;
      lTrySeek  := .T., ;
      cSeek     := ::cSeek, ;
      xSeek

   IF ( Seconds() - ::nLapsus ) > 3 .or. ( Seconds() - ::nLapsus ) < 0
      ::cSeek := cSeek := ""
   ENDIF

   ::nLapsus := Seconds()
   cPrefix := If( ::cPrefix == Nil, "", If( ValType( ::cPrefix ) == "B", Eval( ::cPrefix, Self ), ::cPrefix ) )

   IF ::nColOrder > 0 .and. ::lIsDbf
      lTrySeek := .T.

      IF ::cOrderType == "C"
         nIdxLen := ( ::cAlias )->( Len( Eval( &( "{||" + IndexKey() + "}" ) ) ) )
      ENDIF

      IF nKey == VK_BACK
         IF ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ELSE
            cSeek := Left( cSeek, Len( cSeek ) - 1 )
         ENDIF
      ELSE
         IF ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ELSEIF ::cOrderType == "N"
            /* only  0..9, minus and dot*/
            IF ( nKey >= 48 .and. nKey <= 57 ) .or. ( nKey >= 45 .or. ;
                  nKey <= 46 )
               cSeek += Chr( nKey )
            ELSE
               Tone( 500, 1 )
               lTrySeek := .F.
            ENDIF
         ELSEIF ::cOrderType == "C"
            IF Len( cSeek ) < nIdxLen
               cSeek += If( ::lUpperSeek, Upper( Chr( nKey ) ), Chr( nKey ) )
            ELSE
               Tone( 500, 1 )
               lTrySeek := .F.
            ENDIF
         ENDIF
      ENDIF

      IF ::cOrderType == "C"
         xSeek := cPrefix + cSeek
      ELSEIF ::cOrderType == "N"
         xSeek := Val( cSeek )
      ELSEIF ::cOrderType == "D"
         xSeek := cPrefix + DToS( CToD( cSeek ) )
      ELSE
         xSeek := cPrefix + cSeek
      ENDIF

      IF ! ( ::cOrderType == "D" .and. Len( RTrim( cSeek ) ) < Len( DToC( Date() ) ) ) .and. lTrySeek

         nRecNo := ( ::cAlias )->( RecNo() )
         lFound := ( ::cAlias )->( DbSeek( xSeek, .T. ) )
         lEoF   := ( ::cAlias )->( Eof() )

         IF lEoF .or. ( ::cOrderType == "C" .and. ! lFound )
            ( ::cAlias )->( DbGoTo( nRecNo ) )
         ENDIF

         IF ( ::cOrderType == "C" .and. ! lFound ) .or. lEof
            Tone( 500, 1 )

            IF ::cOrderType == "D"
               ::cSeek := DateSeek( cSeek, VK_BACK )
            ELSE
               ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
            ENDIF

            RETURN Self

         ELSEIF ! lFound

            IF ::cOrderType == "N"
               ( ::cAlias )->( DbSeek( Val( cSeek ) * 10, .T. ) )
               xSeek := ( ::cAlias )->( Eval( &( "{||" + IndexKey() + "}" ) ) )
               xSeek := Val( Right( LTrim( Str( xSeek ) ), Len( cSeek ) + 1 ) )

               IF xSeek > ( ( Val( cSeek ) * 10 ) + 9 )
                  Tone( 500, 1 )
                  ( ::cAlias )->( DbGoTo( nRecNo ) )
                  ::cSeek := Left( cSeek, Len( cSeek ) - 1 )

                  RETURN Self
               ENDIF

            ENDIF

            ::cSeek := cSeek
            ( ::cAlias )->( DbGoto( nRecNo ) )

            RETURN Self
         ELSE
            ::lHitBottom := ::lHitTop := .F.

            IF nRecNo != ( ::cAlias )->( RecNo() ) .and. ::nLen > nLines
               nRecNo := ( ::cAlias )->( RecNo() )
               ( ::cAlias )->( DbSkip( nLines - ::nRowPos ) )

               IF ( ::cAlias )->( EoF() )
                  Eval( ::bGoBottom )
                  ::nRowPos := nLines

                  WHILE ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
                     ::Skip( -1 )
                     ::nRowPos --
                  ENDDO
               ELSE
                  ( ::cAlias )->( DbGoTo( nRecNo ) )
                  ::Upstable()
               ENDIF

               ::Refresh( .F. )
               ::ResetVScroll()
            ELSEIF nRecNo != ( ::cAlias )->( RecNo() )
               nRecNo := ( ::cAlias )->( RecNo() )
               Eval( ::bGoTop )
               ::nAt := ::nRowPos := 1

               WHILE nRecNo != ( ::cAlias )->( RecNo() )
                  ::Skip( 1 )
                  ::nRowPos++
               ENDDO

               ::Refresh( .F. )
               ::ResetVScroll()
            ENDIF

            IF ::bChange != Nil
               Eval( ::bChange, Self, 0 )
            ENDIF
         ENDIF
      ENDIF

      ::cSeek := cSeek

      IF ::bSeekChange != Nil
         Eval( ::bSeekChange )
      ENDIF

   ELSEIF ::nColOrder > 0 .and. ::lIsArr
      lTrySeek := .T.
      nIdxLen := Len( cValToChar( ::aArray[ ::nAt, ::nColOrder ] ) )

      IF nKey == VK_BACK

         IF ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ELSE
            cSeek := Left( cSeek, Len( cSeek ) - 1 )
         ENDIF
      ELSE
         IF ::cOrderType == "D"
            cSeek := DateSeek( cSeek, nKey )
         ELSEIF ::cOrderType == "N"
            /* only  0..9, minus and dot*/
            IF ( nKey >= 48 .and. nKey <= 57 ) .or. ( nKey >= 45 .or. ;
                  nKey <= 46 )
               cSeek += Chr( nKey )
            ELSE
               Tone( 500, 1 )
               lTrySeek := .F.
            ENDIF
         ELSEIF ::cOrderType == "C"
            IF Len( cSeek ) < nIdxLen
               cSeek += If( ::lUpperSeek, Upper( Chr( nKey ) ), Chr( nKey ) )
            ELSE
               Tone( 500, 1 )
               lTrySeek := .F.
            ENDIF
         ENDIF
      ENDIF

      IF ::cOrderType == "C"
         xSeek := cPrefix + cSeek
      ELSEIF ::cOrderType == "N"
         xSeek := Val( cSeek )
      ELSEIF ::cOrderType == "D"
         xSeek := cPrefix + DToS( CToD( cSeek ) )
      ELSE
         xSeek := cPrefix + cSeek
      ENDIF

      IF ! ( ::cOrderType == "D" .and. Len( RTrim( cSeek ) ) < Len( DToC( Date() ) ) ) .and. lTrySeek
         nRecNo := ::nAt
         lFound := lASeek( xSeek,, Self )

         IF ! lFound
            ::nAt   := nRecNo
         ENDIF

         IF ::cOrderType == "C" .and. ! lFound
            Tone( 500, 1 )
            ::cSeek := Left( cSeek, Len( cSeek ) - 1 )

            RETURN Self
         ELSEIF ! lFound
            IF ::cOrderType == "N"
               lASeek( Val( cSeek ) * 10, .T., Self )
               xSeek := ::aArray[ ::nAt, ::nColOrder ]
               xSeek := Val( Right( LTrim( Str( xSeek ) ), Len( cSeek ) + 1 ) )

               IF xSeek > ( ( Val( cSeek ) * 10 ) + 9 )
                  Tone( 500, 1 )
                  ::cSeek := Left( cSeek, Len( cSeek ) - 1 )
                  ::nAt := nRecNo

                  RETURN Self
               ENDIF
            ENDIF

            ::cSeek := cSeek
            ::nAt   := nRecNo

            RETURN Self
         ELSE
            IF nRecNo != ::nAt .and. ::nLen > nLines
               nRecNo := ::nAt
               ::nAt += ( nLines - ::nRowPos )

               IF ::nAt > ::nLen
                  Eval( ::bGoBottom )
                  ::nRowPos := nLines

                  WHILE ::nRowPos > 1 .and. ::nAt != nRecNo
                     ::Skip( -1 )
                     ::nRowPos --
                  ENDDO
               ELSE
                  ::nAt := nRecNo
               ENDIF

               ::Refresh( .F. )
               ::ResetVScroll()
            ELSEIF nRecNo != ::nAt
               nRecNo := ::nAt
               Eval( ::bGoTop )
               ::nAt := ::nRowPos := 1

               WHILE nRecNo != ::nAt
                  ::Skip( 1 )
                  ::nRowPos++
               ENDDO

               ::Refresh( .F. )
               ::ResetVScroll()
            ENDIF

            IF ::bChange != Nil
               Eval( ::bChange, Self, 0 )
            ENDIF
         ENDIF
      ENDIF

      ::cSeek := cSeek

      IF ::bSeekChange != Nil
         Eval( ::bSeekChange )
      ENDIF
   ENDIF

   IF ! lTrySeek
      ::ResetSeek()
   ENDIF

   IF ::lIsArr .and. ::bSetGet != Nil
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ELSEIF ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      ELSE
         Eval( ::bSetGet, "" )
      ENDIF
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:Set3DText() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Set3DText( lOnOff, lRaised, nColumn, nLevel, nClrLight, ;
      nClrShadow ) CLASS TSBrowse

   LOCAL nEle

   DEFAULT lOnOff     := .T., ;
      lRaised    := .T., ;
      nClrLight  := GetSysColor( COLOR_BTNHIGHLIGHT ), ;
      nClrShadow := GetSysColor( COLOR_BTNSHADOW )

   IF Empty( ::aColumns )

      RETURN Self
   ENDIF

   IF ! lOnOff
      IF Empty( nColumn )
         IF Empty( nLevel )
            FOR nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextCell := Nil
               ::aColumns[ nEle ]:l3DTextHead := Nil
               ::aColumns[ nEle ]:l3DTextFoot := Nil
            NEXT
         ELSEIF nLevel == 1
            FOR nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextCell := Nil
            NEXT
         ELSEIF nLevel == 2
            FOR nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextHead := Nil
            NEXT
         ELSE
            FOR nEle := 1 To Len( ::aColumns )
               ::aColumns[ nEle ]:l3DTextFoot := Nil
            NEXT
         ENDIF

      ELSEIF Empty( nLevel )
         ::aColumns[ nColumn ]:l3DTextCell := Nil
         ::aColumns[ nColumn ]:l3DTextHead := Nil
         ::aColumns[ nColumn ]:l3DTextFoot := Nil
      ELSEIF nLevel == 1
         ::aColumns[ nColumn ]:l3DTextCell := Nil
      ELSEIF nLevel == 2
         ::aColumns[ nColumn ]:l3DTextHead := Nil
      ELSE
         ::aColumns[ nColumn ]:l3DTextFoot := Nil
      ENDIF

      RETURN Self

   ENDIF

   IF Empty( nColumn )
      IF Empty( nLevel )
         FOR nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextCell  := lRaised
            ::aColumns[ nEle ]:l3DTextHead  := lRaised
            ::aColumns[ nEle ]:l3DTextFoot  := lRaised
            ::aColumns[ nEle ]:nClr3DLCell  := nClrLight
            ::aColumns[ nEle ]:nClr3DLHead  := nClrLight
            ::aColumns[ nEle ]:nClr3DLFoot  := nClrLight
            ::aColumns[ nEle ]:nClr3DSCell  := nClrShadow
            ::aColumns[ nEle ]:nClr3DSHead  := nClrShadow
            ::aColumns[ nEle ]:nClr3DSFoot  := nClrShadow
         NEXT
      ELSEIF nLevel == 1
         FOR nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextCell  := lRaised
            ::aColumns[ nEle ]:nClr3DLCell  := nClrLight
            ::aColumns[ nEle ]:nClr3DSCell  := nClrShadow
         NEXT
      ELSEIF nLevel == 2
         FOR nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextHead  := lRaised
            ::aColumns[ nEle ]:nClr3DLHead  := nClrLight
            ::aColumns[ nEle ]:nClr3DSHead  := nClrShadow
         NEXT

      ELSE
         FOR nEle := 1 To Len( ::aColumns )
            ::aColumns[ nEle ]:l3DTextFoot  := lRaised
            ::aColumns[ nEle ]:nClr3DLFoot  := nClrLight
            ::aColumns[ nEle ]:nClr3DSFoot  := nClrShadow
         NEXT
      ENDIF
   ELSE
      IF Empty( nLevel )
         ::aColumns[ nColumn ]:l3DTextCell  := lRaised
         ::aColumns[ nColumn ]:l3DTextHead  := lRaised
         ::aColumns[ nColumn ]:l3DTextFoot  := lRaised
         ::aColumns[ nColumn ]:nClr3DLCell  := nClrLight
         ::aColumns[ nColumn ]:nClr3DLHead  := nClrLight
         ::aColumns[ nColumn ]:nClr3DLFoot  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSCell  := nClrShadow
         ::aColumns[ nColumn ]:nClr3DSHead  := nClrShadow
         ::aColumns[ nColumn ]:nClr3DSFoot  := nClrShadow
      ELSEIF nLevel == 1
         ::aColumns[ nColumn ]:l3DTextCell  := lRaised
         ::aColumns[ nColumn ]:nClr3DLCell  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSCell  := nClrShadow
      ELSEIF nLevel == 2
         ::aColumns[ nColumn ]:l3DTextHead  := lRaised
         ::aColumns[ nColumn ]:nClr3DLHead  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSHead  := nClrShadow
      ELSE
         ::aColumns[ nColumn ]:l3DTextFoot  := lRaised
         ::aColumns[ nColumn ]:nClr3DLFoot  := nClrLight
         ::aColumns[ nColumn ]:nClr3DSFoot  := nClrShadow
      ENDIF
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetAlign() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetAlign( nColumn, nLevel, nAlign ) CLASS TSBrowse

   DEFAULT nColumn := 0, ;
      nLevel := 0, ;
      nAlign := DT_LEFT

   IF nColumn > 0
      IF nLevel > 0
         DO CASE
         CASE nLevel == 1
            ::aColumns[ nColumn ]:nAlign  := nAlign
         CASE nLevel == 2
            ::aColumns[ nColumn ]:nHAlign := nAlign
         OTHERWISE
            ::aColumns[ nColumn ]:nFAlign := nAlign
         ENDCASE
      ELSE
         ::aColumns[ nColumn ]:nAlign := ::aColumns[ nColumn ]:nHAlign := ;
            ::aColumns[ nColumn ]:nFAlign := nAlign
      ENDIF
   ELSE
      IF nLevel > 0
         AEval( ::aColumns, { | oCol | If( nLevel = 1, oCol:nAlign := nAlign, If( nLevel = 2, oCol:nHAlign := nAlign, ;
            oCol:nFAlign := nAlign ) ) } )
      ELSE
         AEval( ::aColumns, { | oCol | oCol:nAlign := nAlign, oCol:nHAlign := nAlign, oCol:nFAlign := nAlign } )
      ENDIF
   ENDIF

   IF ::lPainted
      ::Refresh( .T. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetAppendMode() Version 9.0 Nov/30/2009
   * Enables append mode in TSBrowse for DBF's and arrays.
   * At least one column in TSBrowse must have oCol:lEdit set to TRUE in order
   * to work and like direct cell editing.
   * ============================================================================

METHOD SetAppendMode( lMode ) CLASS TSBrowse

   LOCAL lPrevMode := ::lCanAppend

   DEFAULT lMode    := ! ::lCanAppend, ;
      ::lIsTxt := "TEXT_" $ ::cAlias

   IF ! ::lIsTxt
      ::lCanAppend := lMode
   ENDIF

   RETURN lPrevMode

   * ============================================================================
   * METHOD TSBrowse:SetArray() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetArray( aArray, lAutoCols, aHead, aSizes ) CLASS TSBrowse

   LOCAL nColumns, nI, cType, nMax, bData, cHead, ;
      lListBox := Len( aArray ) > 0 .and. ValType( aArray[ 1 ] ) != "A"

   DEFAULT aArray    := {}, ;
      lAutoCols := ::lAutoCol, ;
      aHead     := ::aHeaders, ;
      aSizes    := ::aColSizes

   IF lListBox
      ::aArray := {}

      FOR nI := 1 To Len( aArray )
         AAdd( ::aArray, { aArray[ nI ] } )
      NEXT
   ELSE
      ::aArray := aArray
   ENDIF

   //            default values for array elements used during append mode
   //            The user MUST AIns() as element no. 1 to ::aDefValue
   //            a nil value when using the actual elemnt no (::nAt)
   //            when browsing arrays like this:
   //            AIns( ASize( ::aDefValue, Len( ::aDefValue ) + 1 ), 1 )
   //            AFTER calling ::SetArray()

   nColumns    := If( ! Empty( aHead ), Len( aHead ), If( ! Empty( ::aArray ), Len( ::aArray[ 1 ] ), 0 ) )
   ::aDefValue := Array( Len( aArray[ 1 ] ) )

   FOR nI := 1 To nColumns
      cType := ValType( ::aArray[ 1, nI ] )

      IF cType $ "CM"
         ::aDefValue[ nI ] := Space( Len( ::aArray[ 1, nI ] ) )
      ELSEIF cType == "N"
         ::aDefValue[ nI ] := 0
      ELSEIF cType == "D"
         ::aDefValue[ nI ] := CToD( "" )
      ELSEIF cType == "T"
         #ifdef __XHARBOUR__
         ::aDefValue[ nI ] := CToT( "" )
         #else
         ::aDefValue[ nI ] := HB_CTOT("")
         #endif
      ELSEIF cType == "L"
         ::aDefValue[ nI ] := .F.
      ELSE                                // arrays, objects and codeblocks not allowed
         ::aDefValue[ nI ] := "???"       // not user editable data type
      ENDIF
   NEXT

   ::nAt       := 1
   ::bKeyNo    := { |n| If( n == Nil, ::nAt, ::nAt := n ) }
   ::cAlias    := "ARRAY"  // don't change name, used in method Default()
   ::lIsArr    := .T.
   ::lIsDbf    := .F.
   ::nLen      := Eval( ::bLogicLen := { || Len( ::aArray ) + If( ::lAppendMode, 1, 0 ) } )
   ::lIsArr    := .T.
   ::bGoTop    := { || ::nAt := 1 }
   ::bGoBottom := { || ::nAt := Eval( ::bLogicLen ) }
   ::bSkip     := { |nSkip, nOld| nOld := ::nAt, ::nAt += nSkip, ::nAt := Min( Max( ::nAt, 1 ), ::nLen ), ::nAt - nOld }
   ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
   ::bBof      := { || ::nAt < 1 }
   ::bEof      := { || ::nAt > Len( ::aArray ) }

   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::nRowPos    := 1
   ::nColPos    := 1
   ::nCell      := 1

   ::HiliteCell( 1 )
   lAutocols := If( lAutocols == Nil, ( ! Empty( aHead ) .and. ! Empty( aSizes ) ), lAutocols )

   IF lAutoCols .and. Empty( ::aColumns ) .and. lListBox
      nMax := ( ::nRight - ::nLeft + 1 ) * If( Empty( ::hWnd ), 2, 1 )
      ::lDrawHeaders := .F.
      ::nLineStyle   := LINES_NONE
      ::lNoHScroll   := .T.
      ::AddColumn( TSColumn():New( Nil, ArrayWBlock( Self, 1 ),,,, nMax,, ::lEditable,,,,,,,,,,, Self, ;
         "ArrayWBlock(::oBrw,1)" ) )

   ELSEIF lAutoCols .and. Empty( ::aColumns ) .and. ValType( ::aArray[ 1 ] ) == "A"
      IF Empty( aHead )
         aHead := AutoHeaders( Len( ::aArray[ 1 ] ) )
      ENDIF

      IF aSizes != Nil .and. ValType( aSizes ) != "A"
         aSizes := AFill( Array( Len( ::aArray[ 1 ] ) ), nValToNum( aSizes ) )
      ELSEIF ValType( aSizes ) == "A" .and. ! Empty( aSizes  )
         IF Len( aSizes ) < nColumns
            nI := Len( aSizes ) + 1
            ASize( aSizes, nColumns )
            AFill( aSizes, aSizes[ 1 ], nI )
         ENDIF
      ELSE
         aSizes := Nil
      ENDIF

      FOR nI := 1 To nColumns

         bData := ArrayWBlock( Self, nI )
         cHead := cValToChar( aHead[ nI ] )

         IF Empty( aSizes )
            nMax := Max( GetTextWidth( 0, cValToChar( EVal( bData ) ) ), GetTextWidth( 0, cHead ) )
            nMax := Max( nMax, 60 )
         ELSE
            nMax := aSizes[ nI ]
         ENDIF

         ::AddColumn( TSColumn():New( cHead, bData,,,, nMax,, ::lEditable,,,,,,,,,,, Self, ;
            "ArrayWBlock(::oBrw," + LTrim( Str( nI ) ) + ")" ) )
      NEXT

   ENDIF

   ::lNoPaint := .F.
   ::ResetVScroll( .T. )

   IF ::lPainted
      ::GoTop()
      ::Refresh()
   ENDIF

   RETURN Self

   * ============================================================================

METHOD SetArrayTo( aArray, uFontHF, aHead, aSizes, uFooter, aPicture, aAlign, aName ) CLASS TSBrowse

   LOCAL nColumns, nI, cType, nMax, bData, cHead
   LOCAL nN, cData, aDefMaxVal, aDefMaxLen, aDefType, aDefAlign, aDefFooter, oCol, ;
      nAlign, aAligns, lFooter := .F., cFooter, nFooter, cTemp, cPict, ;
      hFont := If( ::hFont != Nil, ::hFont, 0 ), ;
      lFont := ( hFont != 0 ), hFontHead := hFont, hFontFoot := hFont

   DEFAULT aHead    := AClone(::aHeaders), ;
      aSizes   := AClone(::aColSizes), ;
      aPicture := AClone(::aFormatPic), ;
      aAlign   := If( ISARRAY(::aJustify), AClone(::aJustify), {} ), ;
      aName    := {}

   IF ValType(uFontHF) == 'N' .and. uFontHF != 0
      hFontHead := uFontHF
      hFontFoot := uFontHF
   ELSEIF ValType(uFontHF) == 'A' .and. Len(uFontHF) >= 2
      IF ValType(uFontHF[1]) == 'N' .and. uFontHF[1] != 0
         hFontHead := uFontHF[1]
      ENDIF
      IF ValType(uFontHF[2]) == 'N' .and. uFontHF[2] != 0
         hFontFoot := uFontHF[2]
      ENDIF
   ENDIF

   ::aArray      := aArray
   ::lPickerMode := .F.

   nColumns := If( ! Empty( aHead ), Len( aHead ), If( ! Empty( ::aArray ), Len( ::aArray[ 1 ] ), 0 ) )

   ::aDefValue := Array( Len( aArray[ 1 ] ) )

   aDefMaxVal  := Array(nColumns)
   aDefType    := Array(nColumns)
   aDefAlign   := Array(nColumns)
   aDefMaxLen  := Array(nColumns)

   aFill(aDefMaxLen, 0)

   IF Len(aPicture) != nColumns
      ASize(aPicture, nColumns)
   ENDIF

   IF Len(aAlign) != nColumns
      ASize(aAlign, nColumns)
   ENDIF

   IF Len(aName) != nColumns
      ASize(aName, nColumns)
   ENDIF

   FOR nI := 1 To nColumns
      cType := ValType( ::aArray[ 1, nI ] )
      aDefType[ nI ] := cType

      IF cType $ "CM"
         ::aDefValue[ nI ] := Space( Len( ::aArray[ 1, nI ] ) )
         aDefMaxVal [ nI ] := Trim( ::aArray[ 1, nI ] )
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] )
         aDefAlign  [ nI ] := DT_LEFT
      ELSEIF cType == "N"
         ::aDefValue[ nI ] := 0
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] )
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] )
         aDefAlign  [ nI ] := DT_RIGHT
      ELSEIF cType == "D"
         ::aDefValue[ nI ] := CToD( "" )
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] )
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] )
         aDefAlign  [ nI ] := DT_CENTER
      ELSEIF cType == "T"
         #ifdef __XHARBOUR__
         ::aDefValue[ nI ] := CToT( "" )
         #else
         ::aDefValue[ nI ] := HB_CTOT("")
         #endif
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] )
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] )
         aDefAlign  [ nI ] := DT_LEFT
      ELSEIF cType == "L"
         ::aDefValue[ nI ] := .F.
         aDefMaxVal [ nI ] := cValToChar( ::aArray[ 1, nI ] )
         aDefMaxLen [ nI ] := Len( aDefMaxVal [ nI ] )
         aDefAlign  [ nI ] := DT_CENTER
      ELSE                                // arrays, objects and codeblocks not allowed
         ::aDefValue[ nI ] := "???"       // not user editable data type
         aDefMaxVal [ nI ] := "???"
         aDefMaxLen [ nI ] := 0
         aDefAlign  [ nI ] := DT_LEFT
      ENDIF
   NEXT

   ::nAt       := 1
   ::bKeyNo    := { |n| If( n == Nil, ::nAt, ::nAt := n ) }
   ::cAlias    := "ARRAY"     // don't change name, used in method Default()
   ::lIsArr    := .T.
   ::lIsDbf    := .F.
   ::nLen      := Eval( ::bLogicLen := { || Len( ::aArray ) + If( ::lAppendMode, 1, 0 ) } )
   ::lIsArr    := .T.
   ::bGoTop    := { || ::nAt := 1 }
   ::bGoBottom := { || ::nAt := Eval( ::bLogicLen ) }
   ::bSkip     := { |nSkip, nOld| nOld := ::nAt, ::nAt += nSkip, ::nAt := Min( Max( ::nAt, 1 ), ::nLen ), ::nAt - nOld }
   ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
   ::bBof      := { || ::nAt < 1 }
   ::bEof      := { || ::nAt > Len( ::aArray ) }

   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::nRowPos    := 1
   ::nColPos    := 1
   ::nCell      := 1

   ::HiliteCell( 1 )

   aDefFooter := Array(nColumns)
   aFill(aDefFooter, "")

   IF ValType(uFooter) == "L"
      lFooter := uFooter
   ELSEIF ValType(uFooter) == "A"
      lFooter := .T.
      FOR nI := 1 To Min( nColumns, Len(uFooter) )
         aDefFooter[ nI ] := cValToChar(uFooter[ nI ])
      NEXT
   ENDIF

   IF Empty( aHead )
      aHead := AutoHeaders( Len( ::aArray[ 1 ] ) )
   ENDIF

   IF aSizes != Nil .and. ValType( aSizes ) != "A"
      aSizes := AFill( Array( Len( ::aArray[ 1 ] ) ), nValToNum( aSizes ) )
   ELSEIF ValType( aSizes ) == "A" .and. ! Empty( aSizes  )
      IF Len( aSizes ) < nColumns
         nI := Len( aSizes ) + 1
         ASize( aSizes, nColumns )
         AFill( aSizes, aSizes[ 1 ], nI )
      ENDIF
   ELSE
      aSizes := Nil
   ENDIF

   FOR nI := 1 To Len(::aArray)
      FOR nN := 1 To nColumns
         cData := cValToChar( ::aArray[ nI, nN ] )
         IF len(cData) > len(aDefMaxVal[ nN ])
            IF aDefType[ nN ] == "C"
               aDefMaxVal[ nN ] := Trim(cData)
               aDefMaxLen[ nN ] := Max( aDefMaxLen[ nN ], Len(aDefMaxVal[ nN ]) )
            ELSE
               aDefMaxVal[ nN ] := cData
               aDefMaxLen[ nN ] := Max( aDefMaxLen[ nN ], Len(cData) )
            ENDIF
         ENDIF
      NEXT
   NEXT

   ::aHeaders   := Array(nColumns)
   ::aColSizes  := Array(nColumns)
   ::aFormatPic := Array(nColumns)
   ::aJustify   := Array(nColumns)

   FOR nI := 1 To nColumns

      bData  := ArrayWBlock( Self, nI )
      cHead  := cValToChar( aHead[ nI ] )
      nAlign := aDefAlign[ nI ]
      cPict  := Nil

      IF aDefType[ nI ] == "C"
         IF ValType(aPicture[ nI ]) == "C" .and. Len(aPicture[ nI ]) > 0
            cTemp := If( Left(aPicture[ nI ], 2) == "@K", SubStr(aPicture[ nI ], 4), aPicture[ nI ])
         ELSE
            cTemp := Replicate( "X", aDefMaxLen[ nI ] )
         ENDIF
         IF Len(cTemp) > Len(::aDefValue[ nI ])
            ::aDefValue[ nI ] := Space( Len( cTemp ) )
         ENDIF
         cPict := Replicate( "X", Len( ::aDefValue[ nI ] ) )
      ELSEIF aDefType[ nI ] == "N"
         IF ValType(aPicture[ nI ]) == "C"
            cPict := aPicture[ nI ]
         ELSE
            cPict := Replicate( "9", aDefMaxLen[ nI ] )
            IF ( nN := At(".", aDefMaxVal[ nI ]) ) > 0
               cTemp := SubStr( aDefMaxVal[ nI ], nN )
               cPict := Left( cPict, Len( cPict ) - Len( cTemp ) ) + "." + Replicate( "9", Len( cTemp ) - 1 )
            ENDIF
         ENDIF
      ENDIF

      IF ValType(aAlign[ nI ]) == "N" .and. ( aAlign[ nI ] == DT_LEFT   .or. ;
            aAlign[ nI ] == DT_CENTER .or. ;
            aAlign[ nI ] == DT_RIGHT )
         nAlign := aAlign[ nI ]
      ENDIF

      IF lFooter
         aAligns := { nAlign, DT_CENTER, nAlign }
         cFooter := aDefFooter[ nI ]
         IF CRLF $ cFooter
            cTemp := ""
            AEval(hb_aTokens(cFooter, CRLF), {|x| cTemp := If( Len(x) > Len(cTemp), x, cTemp )})
         ELSE
            cTemp := cFooter
         ENDIF
         nFooter := GetTextWidth( 0, cTemp, hFontFoot )
      ELSE
         aAligns := { nAlign, DT_CENTER }
         cFooter := Nil
         nFooter := 0
      ENDIF

      IF CRLF $ cHead
         cTemp := ""
         AEval(hb_aTokens(cHead, CRLF), {|x| cTemp := If( Len(x) > Len(cTemp), x, cTemp )})
      ELSE
         cTemp := cHead
      ENDIF

      nMax := Max( GetTextWidth( 0, aDefMaxVal[ nI ]+'W', hFont ), GetTextWidth( 0, cTemp, hFontHead ) )
      nMax := Max( nMax + GetBorderWidth(), 32 )
      nMax := Max( nMax, nFooter )

      IF ! Empty( aSizes )
         IF Valtype(aSizes[ nI ]) == 'N' .and. aSizes[ nI ] > 0
            nMax := aSizes[ nI ]
         ELSEIF valtype(aSizes[ nI ]) == 'C'
            nMax := GetTextWidth( 0, aSizes[ nI ], hFont )
         ENDIF
      ENDIF

      ::aHeaders  [ nI ] := cHead
      ::aColSizes [ nI ] := nMax
      ::aFormatPic[ nI ] := cPict
      ::aJustify  [ nI ] := aAligns

      oCol := TSColumn():New( cHead, bData, cPict,, aAligns, nMax,, ::lEditable,,,,cFooter,,,,,,, ;
         Self, "ArrayWBlock(::oBrw," + LTrim( Str( nI ) ) + ")" )
      IF lFont
         oCol:hFontHead := hFontHead
         IF lFooter
            oCol:hFontFoot := hFontFoot
         ENDIF
      ENDIF

      IF aDefType[ nI ] == "L"
         oCol:lCheckBox := .T.
         oCol:nEditMove := 0
      ENDIF

      IF ! Empty(aName[ nI ]) .and. ValType(aName[ nI ]) == "C"
         oCol:cName := aName[ nI ]
      ENDIF

      ::AddColumn( oCol )
   NEXT

   ::lNoPaint := .F.
   ::ResetVScroll( .T. )

   IF ::lPainted
      ::GoTop()
      ::Refresh()
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetBtnGet() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetBtnGet( nColumn, cResName, bAction, nBmpWidth ) CLASS TSBrowse

   DEFAULT nBmpWidth := 16

   nColumn := If( ValType( nColumn ) == "C", ::nColumn( nColumn ), nColumn )

   IF nColumn == Nil .or. nColumn > Len( ::aColumns ) .or. nColumn <= 0

      RETURN Self
   ENDIF

   ::aColumns[ nColumn ]:cResName  := cResName
   ::aColumns[ nColumn ]:bAction   := bAction
   ::aColumns[ nColumn ]:nBmpWidth := nBmpWidth
   ::aColumns[ nColumn ]:lBtnGet   := .t.

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetColMsg() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetColMsg( cMsg, cEditMsg, nCol ) CLASS TSBrowse

   IF Empty( ::aColumns ) .or. ( cMsg == Nil .and. cEditMsg == Nil )

      RETURN Self
   ENDIF

   IF nCol == Nil
      AEval( ::aColumns, { |e| If( cMsg != Nil, e:cMsg := cMsg, Nil ), If( cEditMsg != Nil, e:cMsgEdit := cEditMsg, ;
         Nil ) } )
   ELSE
      IF cMsg != Nil
         ::aColumns[ nCol ]:cMsg := cMsg
      ENDIF

      IF cEditMsg != Nil
         ::aColumns[ nCol ]:cMsgEdit := cEditMsg
      ENDIF
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetColor() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetColor( xColor1, xColor2, nColumn ) CLASS TSBrowse

   LOCAL nEle, nI, nColor

   DEFAULT xColor1 := {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}, ;
      nColumn := 0, ;
      ::lTransparent := .F.

   IF ( Empty( ::aColumns ) .and. nColumn > 0 )

      RETURN NIL
   End

   IF Valtype( xColor1 ) == "A" .and.  Valtype( xColor2 ) == "A" .and. len ( xColor1 ) > len ( xColor2 )

      RETURN NIL
   End

   IF Valtype( xColor1 ) == "N" .and. Valtype( xColor2 ) == "N" .and. nColumn == 0

      RETURN ::SetColor( xColor1, xColor2 )  // FW SetColor Method only nClrText and nClrPane
   ENDIF

   IF Len( ::aColumns ) == 0 .and. ! ::lTransparent .and. ::hBrush == Nil
      nColor := If( ValType( xColor2[ 2 ] ) == "B", Eval( xColor2[ 2 ], 1, 1, Self ), xColor2[ 2 ] )
      ::hBrush := CreateSolidBrush( GetRed ( nColor ), GetGreen ( nColor ), GetBlue (nColor ) )
   ENDIF

   IF nColumn == 0 .and. ValType ( xColor2[ 1 ] ) == "N" .and. ValType( xColor1 ) == "A" .and. xColor1[ 1 ] == 1 .and. ;
         Len( xColor1 ) > 1 .and. ValType( xColor2 ) == "A" .and. ValType( xColor2[ 2 ] ) == "N" .and. xColor1[ 2 ] == 2

      nColor := If( ValType( xColor2[ 2 ] ) == "B", Eval( xColor2[ 2 ], 1, 1, Self ), xColor2[ 2 ] )
      ::Super:SetColor( xColor2[ 1 ], nColor )
   ENDIF

   IF Valtype( xColor1 ) == "N"
      xColor1 := { xColor1 }
      xColor2 := { xcolor2 }
   ENDIF

   FOR nEle := 1 To Len( xColor1 )
      DO CASE

      CASE xColor1[ nEle ] == 1

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrText := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 2

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrPane := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 3

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrHeadFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrHeadFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrHeadFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 4

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrHeadBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrHeadBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrHeadBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 5

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrFocuFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrFocuFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrFocuFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 6

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrFocuBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrFocuBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrFocuBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 7

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrEditFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrEditFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrEditFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 8

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrEditBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrEditBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrEditBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 9

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrFootFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrFootFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrFootFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 10

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrFootBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrFootBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrFootBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 11

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrSeleFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrSeleFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrSeleFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 12

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrSeleBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrSeleBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrSeleBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 13

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrOrdeFore := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrOrdeFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrOrdeFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 14

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrOrdeBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrOrdeBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrOrdeBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 16

         IF nColumn == 0
            FOR nI := 1 TO Len( ::aSuperHead )
               ::aSuperHead[ nI , 5 ] := xColor2[ nEle ]
            NEXT

         ELSE
            ::aSuperHead[ nColumn , 5 ] := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 17
         IF nColumn == 0

            FOR nI := 1 TO Len( ::aSuperHead )
               ::aSuperHead[ nI , 4 ] := xColor2[ nEle ]
            NEXT

         ELSE
            ::aSuperHead[ nColumn , 4 ] := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 18

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrSpcHdFore := xColor2[ nEle ]
            NEXT
            IF Empty( ::aColumns )
               ::nClrSpcHdFore := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrSpcHdFore := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 19

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrSpcHdBack := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrSpcHdBack := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrSpcHdBack := xColor2[ nEle ]
         ENDIF

      CASE xColor1[ nEle ] == 20

         IF nColumn == 0

            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:nClrSpcHdActive := xColor2[ nEle ]
            NEXT

            IF Empty( ::aColumns )
               ::nClrSpcHdActive := xColor2[ nEle ]
            ENDIF

         ELSE
            ::aColumns[ nColumn ]:nClrSpcHdActive := xColor2[ nEle ]
         ENDIF

      OTHERWISE
         ::nClrLine := xColor2[ nEle ]
      ENDCASE

   NEXT

   IF ::lPainted
      ::Refresh( .T. )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:SetCols() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetColumns( aData, aHeaders, aColSizes ) CLASS TSBrowse

   LOCAL aFields, nElements, n

   nElements   := Len( aData )

   ::aHeaders  := If( aHeaders  != Nil, aHeaders, ::aHeaders )
   ::aColSizes := If( aColSizes != Nil, aColSizes, {} )
   ::bLine     := {|| _aData( aData ) }
   ::aJustify  := AFill( Array( nElements ), .F. )

   IF Len( ::GetColSizes() ) < nElements
      ::aColSizes := AFill( Array( nElements ), 0 )
      aFields := Eval( ::bLine )

      FOR n := 1 to nElements
         ::aColSizes[ n ] := If( ValType( aFields[ n ] ) != "C", 16,; // Bitmap handle
         GetTextWidth( 0, Replicate( "B", Max( Len( ::aHeaders[ n ] ), ;
            Len( aFields[ n ] ) ) + 1 ), ;
            If( ! Empty( ::hFont ), ::hFont, 0 ) ) )
      NEXT
   ENDIF

   IF ::oHScroll != nil
      ::oHScroll:nMax := ::GetColSizes()
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetColSize() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetColSize( nCol, nWidth ) CLASS TSBrowse

   LOCAL nI, nSize

   IF ValType( nCol ) == "A"
      FOR nI := 1 To Len( nCol )
         nSize := If( ValType( nWidth ) == "A", nWidth[ nI ], nWidth )
         ::aColumns[ nCol[ nI ] ]:nWidth := nSize
         ::aColSizes[ nCol[ nI ] ] := If(::aColumns[ nCol[ nI ] ]:lVisible, ::aColumns[ nCol[ nI ] ]:nWidth, 0)
      NEXT
   ELSE
      IF ValType( nCol ) == "C"  // 14.07.2015
         nCol := AScan( ::aColumns, { |oCol| Upper( oCol:cName ) == Upper(nCol) } )
      ENDIF
      ::aColumns[ nCol ]:nWidth := nWidth
      ::aColSizes[ nCol ] := If( ::aColumns[ nCol ]:lVisible, ::aColumns[ nCol ]:nWidth, 0 )
   ENDIF

   IF ::lPainted
      ::Refresh( .T. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetData() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetData( nColumn, bData, aList ) CLASS TSBrowse

   IF Valtype( nColumn ) == "C"
      nColumn := ::nColumn( nColumn )  // 21.07.2015
   ENDIF

   IF Valtype( nColumn ) != "N" .or. nColumn <= 0

      RETURN NIL
   ENDIF

   IF aList != Nil

      IF ValType( aList[ 1 ] ) == "A"
         ::aColumns[ nColumn ]:aItems := aList[ 1 ]
         ::aColumns[ nColumn ]:aData := aList[ 2 ]
         ::aColumns[ nColumn ]:cDataType := ValType( aList[ 2, 1 ] )
      ELSE
         ::aColumns[ nColumn ]:aItems := aList
      ENDIF

      ::aColumns[ nColumn ]:lComboBox := .T.

   ENDIF

   IF bData != Nil

      IF Valtype( bData ) == "B"
         ::aColumns[ nColumn ]:bData := bData
      ELSE
         ::aColumns[ nColumn ]:bData := { || (bData) }
      ENDIF

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetDbf() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetDbf( cAlias ) CLASS TSBrowse

   LOCAL cAdsKeyNo, cAdsKeyCount, nTags, nEle

   DEFAULT ::cAlias := cAlias
   DEFAULT ::cAlias := Alias()

   IF Empty( ::cAlias )

      RETURN NIL
   ENDIF

   cAlias := ::cAlias
   ::cDriver := ( ::cAlias )->( RddName() )

   DEFAULT ::bGoTop    := {|| ( cAlias )->( DbGoTop() ) }, ;
      ::bGoBottom := {|| ( cAlias )->( DbGoBottom() ) }, ;
      ::bSkip     := {| n | If( n == Nil, n := 1, Nil ), ::DbSkipper( n ) }, ;
      ::bBof      := {|| ( cAlias )->( Bof() ) }, ;
      ::bEof      := {|| ( cAlias )->( Eof() ) }

   IF "ADS" $ ::cDriver
      cAdsKeyNo := "{| n, oBrw | If( n == Nil, Round( " + cAlias + "->( ADSGetRelKeyPos() ) * oBrw:nLen, 0 ), " + ;
         cAlias + "->( ADSSetRelKeyPos( n / oBrw:nLen ) ) ) }"

      cAdsKeyCount := "{|cTag| " + cAlias + "->( ADSKeyCount(cTag,, 1 ) ) }"

      DEFAULT ::bKeyNo    := &cAdsKeyNo , ;
         ::bKeyCount := &cAdsKeyCount, ;
         ::bLogicLen := &cAdsKeyCount, ;
         ::bTagOrder := {|uTag| ( cAlias )->( OrdSetFocus( uTag ) ) }, ;
         ::bGoToPos  := {|n| Eval( ::bKeyNo, n, Self ) }
   ELSE
      DEFAULT ::bKeyNo    := {| n | ( cAlias )->( If( n == Nil, If( IndexOrd() > 0, OrdKeyNo(), RecNo() ), ;
         If( IndexOrd() > 0, OrdKeyGoto( n ), DbGoTo( n ) ) ) ) }, ;
         ::bKeyCount := {|| ( cAlias )->( If( IndexOrd() > 0, OrdKeyCount(), LastRec() ) ) }, ;
         ::bLogicLen := {|| ( cAlias )->( If(  IndexOrd() == 0, LastRec(), OrdKeyCount() ) ) }, ;
         ::bTagOrder := {|uTag| ( cAlias )->( OrdSetFocus( uTag ) ) }, ;
         ::bGoToPos  := {|n| Eval( ::bKeyNo, n ) }
   ENDIF

   nTags := ( cAlias )->( OrdCount() )
   ::aTags := {}

   FOR nEle := 1 To nTags
      AAdd( ::aTags, { ( cAlias )->( OrdName( nEle ) ), ( cAlias )->( OrdKey( nEle ) ) } )
   NEXT
   IF "SQL" $ ::cDriver
      Eval(::bGoToPos,100)
      ::bGoBottom := {|| CursorWait(), ( cAlias )->( DbGoBottom() ), CursorArrow() }
      ::bRecLock  := {|| .t. }
   ENDIF

   ::nLen := Eval( ::bLogicLen )
   ::ResetVScroll( .T. )

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetDeleteMode()  Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetDeleteMode( lOnOff, lConfirm, bDelete, bPostDel ) CLASS TSBrowse

   DEFAULT lOnOff   := .T., ;
      lConfirm := .T.

   ::lCanDelete := lOnOff
   ::lConfirm   := lConfirm
   ::bDelete    := bDelete
   ::bPostDel   := bPostDel

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetFilter() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD SetFilter( cField, uVal1, uVal2 ) CLASS TSBrowse

   LOCAL cIndexType, cAlias, ;
      lWasFiltered := ::lFilterMode

   DEFAULT uVal2 := uVal1

   IF ValType( uVal2 ) == "A"
      ::bFilter := uVal2[ 2 ]
      uVal2 := uVal2[ 1 ]
   ENDIF

   ::cField      := cField
   ::uValue1     := uVal1
   ::uValue2     := uVal2
   ::lFilterMode := ! Empty( cField )

   cAlias := ::cAlias

   IF ::lFilterMode
      ::lDescend := ( ::uValue2 < ::uValue1 )

      cIndexType := ( cAlias )->( ValType( &( IndexKey() ) ) )

      IF ( ::cAlias )->( ValType( &cField ) ) != cIndexType .or. ;
            ValType( uVal1 ) != cIndexType .or. ;
            ValType( uVal2 ) != cIndexType

         MsgInfo( ::aMsg[ 27 ], ::aMsg[ 28 ] )

         ::lFilterMode := .F.

      ENDIF

   ENDIF
   #ifdef _TSBFILTER7_
   // Posibility of using FILTERs based on INDEXES!!!

   ::bGoTop := If( ::lFilterMode, {|| BrwGoTop( Self ) },;
      {|| ( cAlias )->( DbGoTop() ) } )

   ::bGoBottom := If( ::lFilterMode, {|| BrwGoBottom( uVal2, Self ) },;
      {|| ( cAlias )->( DbGoBottom() ) } )

   ::bSkip := If( ::lFilterMode, BuildSkip( ::cAlias, cField, uVal1, uVal2, Self ), ;
      {| n | ::dbSkipper( n ) } )
   #else
   IF ::lFilterMode
      ( ::cAlias )->( OrdScope( 0, ::uValue1 ) )
      ( ::cAlias )->( OrdScope( 1, ::uValue2 ) )
   ELSE
      ( ::cAlias )->( OrdScope( 0, Nil ) )
      ( ::cAlias )->( OrdScope( 1, Nil ) )
   ENDIF
   #endif
   IF ::bLogicLen != Nil
      ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), ;
         Eval( ::bLogicLen ) )
   ENDIF

   ::ResetVScroll( .T. )
   ::lHitTop    := .F.
   ::lHitBottom := .F.

   IF ::lFilterMode .or. lWasFiltered
      ::GoTop()
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:SetFont() Version 7.0 Jul/15/2004
   * ============================================================================

METHOD SetFont( hFont ) CLASS TSBrowse

   IF hFont != Nil
      ::hFont := hFont
      SendMessage( ::hWnd, WM_SETFONT, hFont )
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:SetHeaders() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetHeaders( nHeight, aCols, aTitles, aAlign , al3DLook, aFonts, aActions ) CLASS TSBrowse

   LOCAL nI

   IF nHeight != Nil
      ::nHeightHead := nHeight
   ENDIF

   IF aCols == Nil

      aCols := {}

      DO CASE

      CASE ValType( aTitles ) == "A"
         FOR nI := 1 TO Len( aTitles )
            AAdd( aCols, nI )
         NEXT

      CASE ValType( aActions ) == "A"
         FOR nI := 1 TO Len( aActions )
            AAdd( aCols, nI )
         NEXT

      CASE ValType( aAlign ) == "A"
         FOR nI := 1 TO Len( aAlign )
            AAdd( aCols, nI )
         NEXT

      CASE ValType( al3DLook ) == "A"
         FOR nI := 1 TO Len( al3DLook )
            AAdd( aCols, nI )
         NEXT

      CASE ValType( aFonts ) == "A"
         FOR nI := 1 TO Len( aFonts )
            AAdd( aCols, nI )
         NEXT

      OTHERWISE

         RETURN NIL
      ENDCASE

   ENDIF

   FOR nI := 1 TO Len( aCols )

      IF aTitles != Nil
         ::aColumns[ aCols[ nI ] ]:cHeading := aTitles[ nI ]
      ENDIF

      IF aAlign != Nil
         ::aColumns[ aCols[ nI ] ]:nHAlign := If( ValType( aAlign ) == "A", aAlign[ nI ], aAlign )
      ENDIF

      IF al3DLook != Nil
         ::aColumns[ aCols[ nI ] ]:l3DLookHead := If( ValType( al3DLook ) == "A", al3DLook[ nI ], al3DLook )
      ENDIF

      IF aFonts != Nil
         ::aColumns[ aCols[ nI ] ]:hFontHead := If( ValType( aFonts ) == "A", aFonts[ nI ], aFonts )
      ENDIF

      IF aActions != Nil
         ::aColumns[ aCols[ nI ] ]:bAction := aActions[ nI ]
      ENDIF

   NEXT

   ::DrawHeaders()

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetIndexCols() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetIndexCols( nCol1, nCol2, nCol3, nCol4, nCol5 ) CLASS TSBrowse

   LOCAL aCol

   DEFAULT nCol2 := 0, ;
      nCol3 := 0, ;
      nCol4 := 0, ;
      nCol5 := 0

   IF Valtype( nCol1 ) == "A"
      AEval( nCol1, { | nCol | ::aColumns[ nCol ]:lIndexCol := .T. } )
   ELSE
      aCol := { nCol1, nCol2, nCol3, nCol4, nCol5 }
      AEval( aCol, { | nCol | If( nCol > 0, ::aColumns[ nCol ]:lIndexCol := .T., Nil ) } )
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:SetNoHoles() adjusts TBrowse height to the whole cells amount
   * ============================================================================

METHOD SetNoHoles( nDelta, lSet ) CLASS TSBrowse

   LOCAL nH, nK, nHeight, nHole

   DEFAULT nDelta := 2, lSet := .T.

   nHole := ::nHeight - ::nHeightHead - ::nHeightSuper - ;
      ::nHeightFoot - ::nHeightSpecHd - ;
      If( ::lNoHScroll, 0, GetHScrollBarHeight() )

   nHole   -= ( Int( nHole / ::nHeightCell ) * ::nHeightCell )
   nHole   -= nDelta
   nHeight := nHole

   IF lSet

      nH := If( ::nHeightSuper  > 0, 1, 0 ) + ;
         If( ::nHeightHead   > 0, 1, 0 ) + ;
         If( ::nHeightSpecHd > 0, 1, 0 ) + ;
         If( ::nHeightFoot   > 0, 1, 0 )

      IF nH > 0

         nK := int( nHole / nH )

         IF ::nHeightFoot   > 0
            ::nHeightFoot   += nK
            nHole           -= nK
         ENDIF
         IF ::nHeightSuper  > 0
            ::nHeightSuper  += nK
            nHole           -= nK
         ENDIF
         IF ::nHeightSpecHd > 0
            ::nHeightSpecHd += nK
            nHole           -= nK
         ENDIF
         IF ::nHeightHead   > 0
            ::nHeightHead   += nHole
         ENDIF

      ELSE

         SetProperty( ::cParentWnd, ::cControlName, "Height", ;
            GetProperty( ::cParentWnd, ::cControlName, "Height" ) - nHole )

      ENDIF

      ::Display()

   ENDIF

   RETURN nHeight

   * ============================================================================
   * METHOD TSBrowse:SetOrder() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetOrder( nColumn, cPrefix, lDescend ) CLASS TSBrowse

   LOCAL nDotPos, cAlias, nRecNo, ;
      lReturn := .F., ;
      oColumn := ::aColumns[ nColumn ]

   DEFAULT ::lIsArr := ( ::cAlias == "ARRAY" )

   IF nColumn == Nil .or. nColumn > Len( ::aColumns )

      RETURN .F.
   ENDIF

   ::lNoPaint := .F.

   IF ::lIsDbf .and. ! Empty( oColumn:cOrder )

      IF nColumn == ::nColOrder .or. oColumn:lDescend == Nil
         IF lDescend == Nil
            lDescend := If( Empty( ::nColOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
         ENDIF
         IF oColumn:lNoDescend   // SergKis addition
            lDescend := .F.
         ELSE
            ( ::cAlias )->( OrdDescend( ,, lDescend ) )
         ENDIF
         oColumn:lDescend := lDescend
         ::nColOrder := nColumn
         ::lHitTop := ::lHitBottom := .F.
         ::nAt := ::nLastnAt := Eval( ::bKeyNo, Nil, Self )
      ENDIF

      cAlias := ::cAlias

      IF ::bKeyNo == Nil
         ::SetDbf()
      ENDIF

      IF ( nDotPos := At( ".", oColumn:cOrder ) ) > 0 // in case TAG has an extension (ie .NTX)
         oColumn:cOrder := SubStr( oColumn:cOrder, 1, nDotPos - 1 )
      ENDIF

      ::uLastTag := oColumn:cOrder

      ( cAlias )->( Eval( ::bTagOrder, oColumn:cOrder ) )

      IF Empty( ( cAlias )->( IndexKey() ) )
         ::cOrderType := ""
      ELSE
         ::cOrderType := ( cAlias )->( ValType( &( IndexKey() ) ) )
      ENDIF

      ::UpStable()
      ::ResetVScroll()
      ::nColOrder := nColumn
      ::ResetSeek()
      ::nAt := ::nLastnAt := Eval( ::bKeyNo, Nil, Self )
      ::HiLiteCell( nColumn )

      IF ::bSetOrder != Nil
         Eval( ::bSetOrder, Self, ( cAlias )->( Eval( ::bTagOrder ) ), nColumn )
      ENDIF

      lReturn := .T.

      IF cPrefix != Nil
         ::cPrefix := cPrefix
      ENDIF

      ::aColumns[ nColumn ]:lSeek := ::lSeek  // GF 1.71

   ELSEIF ::lIsArr

      IF nColumn <= Len( ::aArray[ 1 ] ) .and. oColumn:lIndexCol
         ::cOrderType := ValType( ::aArray[ ::nAt, nColumn ] )

         IF nColumn == ::nColOrder .or. Empty( oColumn:cOrder ) .or. oColumn:lDescend == Nil
            IF lDescend == Nil
               lDescend := If( Empty( oColumn:cOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
            ENDIF
            IF oColumn:lNoDescend   // SergKis addition
               lDescend := .F.
            ENDIF
            oColumn:lDescend := lDescend
            ::nColOrder      := nColumn

            IF ::bSetOrder != Nil
               Eval( ::bSetOrder, Self, nColumn )
            ELSE
               ::SortArray( nColumn, lDescend )
            ENDIF

            IF ::lPainted
               ::UpAStable()
               ::Refresh()
               ::HiliteCell( nColumn )
            ENDIF

            ::ResetVScroll()
            oColumn:lSeek  := .T.
            oColumn:cOrder := "Order"

            RETURN .T.
         ELSE
            ::nColOrder := nColumn
         ENDIF

      ENDIF

      ::ResetSeek()
      lReturn := .T.

      IF cPrefix != Nil
         ::cPrefix := cPrefix
      ENDIF

      IF ::bSetGet != Nil
         IF ValType( Eval( ::bSetGet ) ) == "N"
            Eval( ::bSetGet, ::nAt )
         ELSEIF ::nLen > 0
            Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
         ELSE
            Eval( ::bSetGet, "" )
         ENDIF
      ENDIF

   ELSEIF ::oRSet != Nil .and. ! Empty( oColumn:cOrder )

      IF nColumn == ::nColOrder .or. oColumn:lDescend == Nil
         IF lDescend == Nil
            lDescend := If( Empty( ::nColOrder ) .or. oColumn:lDescend == Nil, .F., ! oColumn:lDescend )
         ENDIF

         nRecNo := Eval( ::bRecNo )
         ::oRSet:Sort := Upper( oColumn:cOrder ) + If( lDescend, " DESC", " ASC" )

         oColumn:lDescend := lDescend
         ::UpRStable( nRecNo )
         ::ResetVScroll()
         ::nColOrder := nColumn
         ::ResetSeek()
         ::lHitTop := ::lHitBottom := .F.
         ::nAt := ::nLastnAt := Eval( ::bKeyNo )
         ::HiLiteCell( nColumn )
         ::Refresh()

         RETURN .T.
      ENDIF

      ::uLastTag := oColumn:cOrder
      ::nColOrder := nColumn
      ::HiLiteCell( nColumn )
      ::nAt := ::nLastnAt := Eval( ::bKeyNo )
      lReturn := .T.

   ENDIF

   ::lHitTop := ::lHitBottom := .F.

   RETURN lReturn

   * ============================================================================
   * METHOD TSBrowse:SetSelectMode() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetSelectMode( lOnOff, bSelected, uBmpSel, nColSel, nAlign ) CLASS TSBrowse

   DEFAULT lOnOff  := .T., ;
      nColSel := 1, ;
      nAlign  := DT_RIGHT

   ::lCanSelect := lOnOff
   ::bSelected  := bSelected
   ::aSelected  := {}

   IF ::lCanSelect .and. ;
         ( uBmpSel == Nil .or. Empty( nColSel ) .or. nColSel > Len( ::aColumns ) )

      RETURN Self
   ENDIF

   IF ::lCanSelect .and. uBmpSel != Nil

      IF ValType( uBmpSel ) != "C"
         ::uBmpSel := uBmpSel
      ELSE
         ::uBmpSel := LoadImage ( uBmpSel )
         ::lDestroy := .T.
      ENDIF

      ::nColSel  := nColSel
      ::nAligBmp := nAlign

   ELSEIF ::uBmpSel != Nil

      IF ::lDestroy
         DeleteObject ( ::uBmpSel )
      ENDIF

      ::lDestroy := .F.
      ::uBmpSel  := Nil
      ::nCoSel   := 0
      ::nAligBmp := 0

   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SetSpinner() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetSpinner( nColumn, lOnOff, bUp, bDown, bMin, bMax ) CLASS TSBrowse

   DEFAULT lOnOff := .T., ;
      bUp := { | oGet | oGet++ }, ;
      bDown := { | oGet | oGet++ }

   IF nColumn == Nil .or. nColumn > Len( ::aColumns ) .or. nColumn <= 0

      RETURN Self
   ENDIF

   ::aColumns[ nColumn ]:lSpinner := lOnOff
   ::aColumns[ nColumn ]:bUp      := bUp
   ::aColumns[ nColumn ]:bDown    := bDown
   ::aColumns[ nColumn ]:bMin     := bMin
   ::aColumns[ nColumn ]:bMax     := bMax
   ::aColumns[ nColumn ]:lBtnGet  := .t.

   RETURN Self

   #ifdef __DEBUG__
   * ============================================================================
   * METHOD TSBrowse:ShowSizes() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD ShowSizes() CLASS TSBrowse

   LOCAL cText  := "", ;
      nTotal := 0, ;
      aTemp  := ::GetColSizes()

   AEval( aTemp, { | e, n | nTotal += e, cText += ( If( ValType( ::aColumns[ n ]:cHeading ) == "C", ;
      ::aColumns[ n ]:cHeading, ::aMsg[ 24 ] + Space( 1 ) + Ltrim( Str( n ) ) ) + ": " + ;
      Str( e, 3 ) + " Pixels" + CRLF ) } )

   cText += CRLF + "Total " + Str( nTotal, 4 ) + " Pixels" + CRLF + ::aMsg[ 25 ] + Space( 1) + ;
      Str( ::nWidth(), 4 ) + " Pixels" + CRLF

   MsgInfo( cText, ::aMsg[ 26 ] )

   RETURN Self
   #endif

   * ============================================================================
   * METHOD TSBrowse:Skip() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD Skip( n ) CLASS TSBrowse

   LOCAL nSkipped

   DEFAULT n := 1

   IF ::bSkip != Nil
      nSkipped := Eval( ::bSkip, n )
   ELSE
      nSkipped := ::DbSkipper( n )
   ENDIF

   IF ::lIsDbf
      ::nLastPos := ( ::cAlias )->( RecNo() )
   ENDIF

   ::nLastnAt := ::nAt

   IF ::lIsArr .and. ::bSetGet != Nil
      IF ValType( Eval( ::bSetGet ) ) == "N"
         Eval( ::bSetGet, ::nAt )
      ELSEIF ::nLen > 0
         Eval( ::bSetGet, ::aArray[ ::nAt, 1 ] )
      ELSE
         Eval( ::bSetGet, "" )
      ENDIF
   ENDIF

   RETURN nSkipped

   * ============================================================================
   * METHOD TSBrowse:SortArray() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SortArray( nCol, lDescend ) CLASS TSBrowse

   LOCAL aLine := ::aArray[ ::nAt ]

   DEFAULT nCol := ::nColOrder

   IF lDescend == Nil
      IF ::aColumns[ nCol ]:lDescend == Nil
         lDescend := .F.
      ELSE
         lDescend := ::aColumns[ nCol ]:lDescend
      ENDIF
   ENDIF

   CursorWait()

   ::aColumns[ nCol ]:lDescend := lDescend

   IF ::lSelector .and. nCol > 1
      nCol --
   ENDIF

   IF lDescend
      IF  ValType(::aColumns[ nCol ]:bArraySortDes) == "B"
         ::aArray := ASort( ::aArray,,, ::aColumns[ nCol ]:bArraySortDes )
      ELSE
         ::aArray := Asort( ::aArray,,, {|x,y| x[ nCol ] > y[ nCol ] } )
      ENDIF
   ELSE
      IF  ValType(::aColumns[ nCol ]:bArraySort) == "B"
         ::aArray := ASort( ::aArray,,, ::aColumns[ nCol ]:bArraySort )
      ELSE
         ::aArray := Asort( ::aArray,,, {|x,y| x[ nCol ] < y[ nCol ] } )
      ENDIF
   ENDIF

   ::nAt := AScan( ::aArray, {|e| lAEqual( e, aLine ) } )
   CursorHand()

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SwitchCols() Version 9.0 Nov/30/2009
   * This method is dedicated to John Stolte by the 'arry
   * ============================================================================

METHOD SwitchCols( nCol1, nCol2 ) CLASS TSBrowse

   LOCAL oHolder, nHolder, nMaxCol := Len(::aColumns)

   IF nCol1 > ::nFreeze .and. nCol2 > ::nFreeze .and. ;
         nCol1 <= nMaxCol .and. nCol2 <= nMaxCol

      oHolder := ::aColumns[ nCol1 ]
      nHolder := ::aColSizes[ nCol1 ]

      ::aColumns[ nCol1 ]  := ::aColumns[ nCol2 ]
      ::aColSizes[ nCol1 ] := ::aColSizes[ nCol2 ]

      ::aColumns[ nCol2 ]  := oHolder
      ::aColSizes[ nCol2 ] := nHolder

      IF ::nColOrder == nCol1
         ::nColOrder := nCol2
      ENDIF

   ENDIF

   IF ::lPainted
      ::Refresh( .F. )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:SyncChild() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SyncChild( aoChildBrw, abAction ) CLASS TSBrowse

   IF aoChildBrw != Nil
      IF ValType( aoChildBrw ) == "O"
         aoChildBrw := { aoChildBrw }
      ENDIF

      DEFAULT abAction := Array( Len( aoChildBrw ) )

      IF ValType( abAction ) == "B"
         abAction := { abAction }
      ENDIF

      ::bChange := {|| ;
         AEval( aoChildBrw, {|oChild,nI| If( ! Empty( oChild:cAlias ),;
         ( oChild:lHitTop := .F., oChild:goTop(),;
         If( abAction[nI] != Nil, Eval( abAction[nI], Self, oChild ), Nil ),;
         oChild:reset() ), Nil ) } ) }
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:UpStable() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD UpStable() CLASS TSBrowse

   LOCAL nRow     := ::nRowPos, ;
      nRecNo   := ( ::cAlias )->( RecNo() ), ;
      nRows    := ::nRowCount(), ;
      n        := 1, ;
      lSkip    := .T., ;
      bChange  := ::bChange, ;
      nLastPos := ::nLastPos

   IF ::nLen > nRows

      ( ::cAlias )->( DbSkip( nRows - nRow ) )

      IF ( ::cAlias )->( EoF() )
         Eval( ::bGoBottom )
         ::nRowPos := nRows

         WHILE ::nRowPos > 1 .and. ( ::cAlias )->( RecNo() ) != nRecNo
            ::Skip( -1 )
            ::nRowPos --
         ENDDO

         ::Refresh( .F. )
         ::ResetVScroll()

         RETURN Self
      ELSE
         ( ::cAlias )->( DbGoto( nRecNo ) )
      ENDIF

   ENDIF

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::GoTop()

   WHILE ! ( ::cAlias )->( EoF() )

      IF n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         EXIT
      ENDIF

      IF nRecNo == ( ::cAlias )->( RecNo() )
         ::nRowPos := n
         EXIT
      ELSE
         ::Skip( 1 )
      ENDIF

      n++

   ENDDO

   IF lSkip
      ::Skip( -::nRowPos )
   ENDIF

   ( ::cAlias )->( DbGoTo( nRecNo ) )                // restores Record position
   ::nLastPos := nLastPos
   ::nAt      := ::nLastnAt := ::nLogicPos()
   ::lHitTop  := ( ::nAt == 1 )

   IF ::oVScroll != Nil .and. ! Empty( ::bKeyNo )     // restore scrollbar thumb
      ::oVScroll:SetPos( ::RelPos( ( ::cAlias )->( Eval( ::bKeyNo, Nil, Self ) ) ) )
   ENDIF

   ::bChange := bChange

   IF ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   ENDIF

   RETURN Self

   * ============================================================================
   * METHOD TSBrowse:VertLine() Version 9.0 Nov/30/2009
   * Thanks to Gianni Santamarina
   * ============================================================================

METHOD VertLine( nColPixPos, nColInit, nGapp ) CLASS TSBrowse

   LOCAL hDC   := GetDC( ::hWnd )
   LOCAL aRect := ::GetRect()

   IF nColInit != Nil
      nsCol   := nColInit
      nsWidth := nColPixPos
      nGap := If( ! Empty( nGapp ), nGapp, 0 )
      nsOldPixPos := 0
      _InvertRect( ::hDC, { 0, nsWidth - ::aColSizes[ nsCol ] - 2, aRect[4], nsWidth - ::aColSizes[ nsCol ] + 2 } )
   ENDIF

   IF nColPixPos == Nil .and. nColInit == Nil   // We have finish dragging
      ::aColSizes[ nsCol ] -= ( nsWidth - nsOldPixPos )
      ::aColumns[ nsCol ]:nWidth -= ( nsWidth - nsOldPixPos )
      ::Refresh()

      IF ValType( ::bLineDrag ) == "B"
         Eval( ::bLineDrag, nsCol, ( nsOldPixPos - nsWidth ), Self )
      ENDIF
   ENDIF

   aRect := ::GetRect()

   IF nsOldPixPos != 0 .and. nColPixPos != Nil .and. nColPixPos != nsOldPixPos
      _InvertRect( hDC, { 0, nsOldPixPos - 2, aRect[4], nsOldPixPos + 2 } )
      nsOldPixPos := 0
   ENDIF

   IF nColPixPos != Nil .and. nColPixPos != nsOldPixPos
      nColPixPos := Max( nColPixPos, 10 )
      _InvertRect( hDC, { 0, nColPixPos - 2 + nGap, aRect[4], nColPixPos + 2 + nGap } )
      nsOldPixPos := nColPixPos + nGap
   ENDIF

   ReleaseDC( ::hWnd, hDC )

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:VScroll() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD VScroll( nMsg, nPos ) CLASS TSBrowse

   LOCAL oCol,;
      nLines := Min( ::nLen, ::nRowCount() )

   ::lNoPaint := .F.

   IF ::oWnd:hCtlFocus != Nil .and. ::oWnd:hCtlFocus != ::hWnd
      oCol := ::oWnd:aColumns[ ::oWnd:nCell ]
      IF oCol:oEdit != Nil .and. nPos == 0
         IF "TBTNBOX" $ Upper( oCol:oEdit:ClassName() )
            Eval( oCol:oEdit:bKeyDown , VK_ESCAPE, 0, .t. )
         ENDIF
      ENDIF
   ENDIF
   IF GetFocus() != ::hWnd
      SetFocus( ::hWnd )
   ENDIF

   DO CASE
   CASE nMsg == SB_LINEUP
      ::GoUp()

   CASE nMsg == SB_LINEDOWN
      IF ! ::lHitBottom
         ::GoDown()
      ENDIF

   CASE nMsg == SB_PAGEUP
      ::PageUp()

   CASE nMsg == SB_PAGEDOWN
      ::PageDown()

   CASE nMsg == SB_TOP
      ::GoTop()

   CASE nMsg == SB_BOTTOM
      ::GoBottom()

   CASE nMsg == SB_THUMBPOSITION

      IF ::nLen == 0
         ::nLen := If( ::lIsDbf, ( ::cAlias )->( Eval( ::bLogicLen ) ), Eval( ::bLogicLen ) )
      ENDIF

      IF ::nLen < 1

         RETURN 0
      ENDIF

      IF nPos == 1
         ::lHitTop := .F.
         ::GoTop()

         RETURN 0
      ELSEIF nPos >= ::oVScroll:GetRange()[ 2 ]
         ::lHitBottom := .F.
         ::GoBottom()

         RETURN 0
      ELSE
         ::lHitTop := .F.
         ::lHitBottom := .F.
      ENDIF

      ::nAt := ::nLogicPos()
      ::oVScroll:SetPos( ::RelPos( ::nAt ) )

      IF ( nPos - ::oVScroll:nMin ) < nLines
         ::nRowPos := 1
      ENDIF

      IF ( ::oVScroll:nMax - nPos ) < Min( nLines, ::nLen )
         ::nRowPos := Min( nLines, ::nLen ) - ( ::oVScroll:nMax - nPos )
      ENDIF

      ::Refresh( .F. )

      IF ::lIsDbf
         ::nLastPos := ( ::cAlias )->( RecNo() )
      ENDIF

      IF ::bChange != nil
         Eval( ::bChange, Self, 0 )
      ENDIF

   CASE nMsg == SB_THUMBTRACK

      IF ::lIsDbf
         ::GoPos( ::GetRealPos( nPos ) )
         ::Skip( ( ::GetRealPos( nPos ) - ::GetRealPos( ::oVScroll:GetPos() ) ) )
      ELSE
         IF ::bGoToPos != Nil
            ( ::cAlias )->( Eval( ::bGoToPos, ::GetRealPos( nPos ) ) )
         ELSE
            ::Skip( ( ::GetRealPos( nPos ) - ::GetRealPos( ::oVScroll:GetPos() ) ) )
         ENDIF

         IF nPos == 1
            ::lHitTop := .F.
            ::GoTop()

            RETURN 0
         ELSEIF nPos >= ::oVScroll:GetRange()[ 2 ]
            ::lHitBottom := .F.
            ::GoBottom()

            RETURN 0
         ELSE
            ::lHitTop := .F.
            ::lHitBottom := .F.
         ENDIF

         IF  ::nLen >= nLines
            IF (::nLen - ::nAt) <= nLines
               ::nRowPos := nLines - (::nLen - ::nAt )
            ELSEIF ::nLen == ::nAt
               ::nRowPos := nLines
            ELSE
               ::nRowPos := 1
            ENDIF
         ENDIF
         ::Refresh( .F. )
         SysRefresh()
      ENDIF
   OTHERWISE

      RETURN NIL
   ENDCASE

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:Enabled() Version 7.0 Adaptation Version
   * ============================================================================

METHOD Enabled( lEnab )  CLASS TSBrowse

   LOCAL nI

   DEFAULT lEnab := .T.

   IF ValType( lEnab ) == "L"
      IF !lEnab
         IF ::lEnabled
            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:SaveColor()
            NEXT
         ENDIF
         ::lEnabled := .F.
         ::SetColor( { 2 }, { CLR_HGRAY } )
         ::SetColor( { 3, 4 }, { CLR_GRAY, CLR_HGRAY } )
      ELSE
         IF ! ::lEnabled
            FOR nI := 1 TO Len( ::aColumns )
               ::aColumns[ nI ]:RestColor()
               SetColor( , ::aColumns[ nI ]:aColors, nI )
            NEXT
         ENDIF
         ::lEnabled := .T.
      ENDIF
   ENDIF

   RETURN 0

   * ============================================================================
   * METHOD TSBrowse:HideColumns() Version 7.0 Adaptation Version
   * ============================================================================

METHOD HideColumns( nColumn, lHide ) CLASS TSBrowse

   LOCAL aColumn, nI, nJ, lPaint := .F.

   DEFAULT lHide := .T.

   IF Valtype( nColumn ) == "C"
      nColumn := ::nColumn( nColumn )  // 21.07.2015
   ENDIF

   IF Empty( ::aColumns ) .and. nColumn > 0

      RETURN NIL
   ENDIF

   aColumn := If( ValType( nColumn ) == "N", { nColumn }, nColumn )

   FOR nI :=1 TO Len( aColumn )

      IF ( nJ := aColumn[ nI ] ) <= Len( ::aColumns )

         lPaint := .T.
         IF lHide
            ::aColSizes[ nJ ] := 0
         ELSE
            ::aColSizes[ nJ ] := ::aColumns[ nJ ]:nWidth
         ENDIF
         ::aColumns[ nJ ]:lVisible := ! lHide

      ENDIF

   NEXT

   ::Refresh( lPaint )

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:UserPopup() Version 9.0 Adaptation Version
   * ============================================================================

METHOD UserPopup( bUserPopupItem, aColumn ) CLASS TSBrowse

   IF Valtype( aColumn ) != "A"
      aColumn := If( Valtype( aColumn ) == "N", { aColumn }, { 0 } )
   ENDIF

   ::bUserPopupItem := If( Valtype( bUserPopupItem ) == "B", bUserPopupItem, ;
      { || (bUserPopupItem) } )
   ::lNoPopup   := .F.
   ::lPopupUser := .T.
   ::aPopupCol  := aColumn

   RETURN 0

   * ============================================================================
   *                    TSBrowse   Functions
   * ============================================================================

   * ============================================================================
   * FUNCTION TSBrowse _aData() Version 9.0 Nov/30/2009
   * Called from METHOD SetCols()
   * ============================================================================

STATIC FUNCTION _aData( aFields )

   LOCAL aFld, nFor, nLen

   nLen := Len( aFields )
   aFld := Array( nLen )

   FOR nFor := 1 To nLen
      aFld[ nFor ] := Eval( aFields[ nFor ] )
   NEXT

   RETURN aFld

   #ifdef __DEBUG__
   * ============================================================================
   * FUNCTION TSBrowse AClone() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION AClone( aSource )

   LOCAL aTarget := {}

   AEval( aSource, { |e| AAdd( aTarget, e ) } )

   RETURN aTarget
   #endif

   * ============================================================================
   * FUNCTION TSBrowse:AutoHeaders() Version 9.0 Nov/30/2009
   * Excel's style column's heading
   * ============================================================================

STATIC FUNCTION AutoHeaders( nCols )

   LOCAL nEle, aHead, nChg, cHead, ;
      aBCD := {}

   FOR nEle := 65 To 90
      AAdd( aBCD, Chr( nEle ) )
   NEXT

   IF nCols <= 26
      ASize( aBCD, nCols )

      RETURN aBCD
   ENDIF

   aHead := AClone( aBCD )
   nCols -= 26
   cHead := "A"
   nChg  := 1

   WHILE nCols > 0

      FOR nEle := 1 To Min( 26, nCols )
         AAdd( aHead, cHead + aBCD[ nEle ] )
      NEXT

      nCols -= 26

      IF Asc( SubStr( cHead, nChg, 1 ) ) == 90
         IF nChg > 1
            nChg --
         ELSE
            cHead := Replicate( Chr( 65 ), Len( cHead ) + 1 )
            nChg := Len( cHead )
         ENDIF
      ENDIF

      cHead := Stuff( cHead, nChg, 1, Chr( Asc( SubStr( cHead, nChg, 1 ) ) + 1 ) )

   ENDDO

   RETURN aHead

   * ============================================================================
   * FUNCTION TSBrowse lASeek() Version 9.0 Nov/30/2009
   * Incremental searching in arrays
   * ============================================================================

STATIC FUNCTION lASeek( uSeek, lSoft, oBrw )

   LOCAL nEle, uData, ;
      lFound := .F., ;
      aArray := oBrw:aArray, ;
      nCol   := oBrw:nColOrder, ;
      nRecNo := oBrw:nAt

   DEFAULT lSoft := .F.

   FOR nEle := Max( 1, nNewEle ) To Len( aArray )

      uData := aArray[ nEle, nCol ]
      uData := If( oBrw:lUpperSeek, Upper( cValToChar( uData ) ), cValToChar( uData ) )

      IF ! lSoft
         IF uData = cValToChar( uSeek )
            lFound := .T.
            EXIT
         ENDIF
      ELSE
         IF uData >= cValToChar( uSeek )
            lFound := .T.
            EXIT
         ENDIF
      ENDIF

   NEXT

   IF lFound .and. nEle <= oBrw:nLen
      oBrw:nAt := nEle
      nNewEle  := nEle
   ELSE
      oBrw:nAt := nRecNo
   ENDIF

   RETURN lFound

   #ifdef _TSBFILTER7_
   * ============================================================================
   * FUNCTION TSBrowse BrwGoBottom() Version 9.0 Nov/30/2009
   * Used by METHOD SetFilter() to set the bottom limit in an "Index Based"
   * filtered database
   * ============================================================================

STATIC FUNCTION BrwGoBottom( uExpr, oBrw )

   IF ValType( uExpr ) == "C"
      ( oBrw:cAlias )->( DbSeek( SubStr( uExpr, 1, Len( uExpr ) - 1 ) + ;
         Chr( Asc( SubStr( uExpr, Len( uExpr ) ) ) + ;
         If( ! oBrw:lDescend, 1, - 1 ) ), .T. ) )
   ELSE
      ( oBrw:cAlias )->( DbSeek( uExpr + If( ! oBrw:lDescend, 1, -1 ), .T. ) )
   ENDIF

   IF ( oBrw:cAlias )->( EoF() )
      ( oBrw:cAlias )->( DbGoBottom() )
   ELSE
      ( oBrw:cAlias )->( DbSkip( -1 ) )
   ENDIF

   WHILE oBrw:bFilter != Nil .and. ! Eval( oBrw:bFilter ) .and. ! ( oBrw:cAlias )->( BoF() )
      ( oBrw:cAlias )->( DbSkip( -1 ) )
   ENDDO

   RETURN NIL

   * ============================================================================
   * FUNCTION TSBrowse BrwGoTop() Version 7.0 Jul/15/2004
   * Used by METHOD SetFilter() to set the top limit in an "Index Based"
   * filtered database
   * ============================================================================

STATIC FUNCTION BrwGoTop( oBrw )

   ( oBrw:cAlias )->( DbSeek( oBrw:uValue1, .T. ) )

   WHILE oBrw:bFilter != Nil .and. ! Eval( oBrw:bFilter ) .and. ! ( oBrw:cAlias )->( EoF() )
      ( oBrw:cAlias )->( DbSkip( 1 ) )
   ENDDO

   RETURN NIL

   * ============================================================================
   * FUNCTION TSBrowse BuildSkip() Version 7.0 Jul/15/2004
   * Used by METHOD SetFilter(). Returns a block to be used on skipping records
   * in an "Index Based" filtered database
   * ============================================================================

STATIC FUNCTION BuildSkip( cAlias, cField, uValue1, uValue2, oTb )

   LOCAL bSkipBlock, lDescend := oTb:lDescend, ;
      cType := ValType( uValue1 )

   DO CASE
   CASE cType == "C"
      IF ! lDescend
         bSkipBlock := &( "{|| " + cField + ">= '" + uValue1 + "' .and. " + ;
            cField + "<= '" + uValue2 + "' }" )
      ELSE
         bSkipBlock := &( "{|| " + cField + "<= '" + uValue1 + "' .and. " + ;
            cField + ">= '" + uValue2 + "' }" )
      ENDIF
   CASE cType == "D"
      IF ! lDescend
         bSkipBlock := &( "{|| " + cField + ">= CToD( '" + DToC( uValue1 ) + "') .and. " + ;
            cField + "<= CToD( '" + DToC( uValue2 ) + "') }" )
      ELSE
         bSkipBlock := &( "{|| " + cField + "<= CToD( '" + DToC( uValue1 ) + "') .and. " + ;
            cField + ">= CToD( '" + DToC( uValue2 ) + "') }" )
      ENDIF

   CASE cType == "N"
      IF ! lDescend
         bSkipBlock := &( "{|| " + cField + ">= " + cValToChar( uValue1 ) + " .and. " + ;
            cField + "<= " + cValToChar( uValue2 ) + " }" )
      ELSE
         bSkipBlock := &( "{|| " + cField + "<= " + cValToChar( uValue1 ) + " .and. " + ;
            cField + ">= " + cValToChar( uValue2 ) + " }" )
      ENDIF

   CASE cType == "L"
      IF ! lDescend
         bSkipBlock := &( "{|| " + cField + ">= " + cValToChar( uValue1 ) + " .and. " + ;
            cField + "<= " + cValToChar( uValue2 ) + " }" )
      ELSE
         bSkipBlock := &( "{|| " + cField + "<= " + cValToChar( uValue1 ) + " .and. " + ;
            cField + ">= " + cValToChar( uValue2 ) + " }" )
      ENDIF
   ENDCASE

   RETURN { | n | ( cAlias )->( BrwGoTo( n, bSkipBlock, oTb ) ) }

   * ============================================================================
   * FUNCTION TSBrowse BuildFiltr() Version 1.47 Adaption HMG
   * Used in Report by Function dbSetFilter. Returns a string used for create bBlock of Filter
   * ============================================================================

STATIC FUNCTION BuildFiltr( cField, uValue1, uValue2, oTb )

   LOCAL cFiltrBlock, lDescend := oTb:lDescend, ;
      cType := ValType( uValue1 )

   DO CASE
   CASE cType == "C"
      IF ! lDescend
         cFiltrBlock := "{||" + cField + ">= '" + uValue1 + "' .and." + ;
            cField + "<= '" + uValue2 + "' }"
      ELSE
         cFiltrBlock := "{||" + cField + "<= '" + uValue1 + "' .and." + ;
            cField + ">= '" + uValue2 + "' }"
      ENDIF
   CASE cType == "D"
      IF ! lDescend
         cFiltrBlock := "{||" + cField + ">= CToD( '" + DToC( uValue1 ) + "') .and." + ;
            cField + "<= CToD( '" + DToC( uValue2 ) + "') }"
      ELSE
         cFiltrBlock := "{||" + cField + "<= CToD( '" + DToC( uValue1 ) + "') .and." + ;
            cField + ">= CToD( '" + DToC( uValue2 ) + "') }"
      ENDIF

   CASE cType == "N"
      IF ! lDescend
         cFiltrBlock := "{||" + cField + ">= " + cValToChar( uValue1 ) + " .and." + ;
            cField + "<= " + cValToChar( uValue2 ) + " }"
      ELSE
         cFiltrBlock := "{||" + cField + "<= " + cValToChar( uValue1 ) + " .and." + ;
            cField + ">= " + cValToChar( uValue2 ) + " }"
      ENDIF

   CASE cType == "L"
      IF ! lDescend
         cFiltrBlock := "{||" + cField + ">= " + cValToChar( uValue1 ) + " .and." + ;
            cField + "<= " + cValToChar( uValue2 ) + " }"
      ELSE
         cFiltrBlock := "{||" + cField + "<= " + cValToChar( uValue1 ) + " .and." + ;
            cField + ">= " + cValToChar( uValue2 ) + " }"
      ENDIF
   ENDCASE

   RETURN cFiltrBlock
   #endif

   * ============================================================================
   * FUNCTION TSBrowse BuildAutoSeek() Version 1.47 Adaption HMG
   * Used in AutoSeek by Functions SpecHeader. Returns a string used for create bBlock of Locate
   * ============================================================================

STATIC FUNCTION BuildAutoSeek( oTb )

   LOCAL nCol, nLen, cType, uValue, cField, cLocateBlock := "", cComp,cand

   IF oTb:lIsArr
      FOR nCol:=1 TO  Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cType := ValType( uValue )
         IF !Empty(uValue)
            IF Empty(cLocateBlock)
               DO CASE
               CASE cType == "C"
                  uValue := RTrim(uValue)
                  nLen   := Len(uValue)
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| substr(x["+lTrim(Str(nCol))+"],1,"+;
                     lTrim(Str(nLen))+" ) == '"+uValue+"'"
               CASE cType == "N" .or. cType == "L"
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| x["+lTrim(Str(nCol))+"] == "+;
                     cValToChar( uValue )
               CASE cType == "D"
                  cLocateBlock := "{|oTb|Ascan ( oTb:aArray, {|x,y| x["+lTrim(Str(nCol))+"] == "+;
                     "CToD( '" +DToC( uValue )+"' )"
               ENDCASE
            ELSE
               DO CASE
               CASE cType == "C"
                  uValue := RTrim(uValue)
                  nLen   := Len(uValue)
                  cLocateBlock += " .and. substr(x["+lTrim(Str(nCol))+"],1,"+;
                     lTrim(Str(nLen))+" ) == '"+uValue+"'"
               CASE cType == "N" .or. cType == "L"
                  cLocateBlock = " .and. x["+lTrim(Str(nCol))+"] == "+;
                     cValToChar( uValue )
               CASE cType == "D"
                  cLocateBlock += " .and. x["+lTrim(Str(nCol))+"] == "+;
                     "CToD( '" +DToC( uValue )+"' )"
               ENDCASE
            ENDIF
         ENDIF
      NEXT
      cLocateBlock += If( ! Empty(cLocateBlock), "}, oTB:nAT + 1 ) }", "" )
   ENDIF
   IF oTb:lIsDbf
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cData
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := If( Empty(cLocateBlock),"", " .AND. " )
            DO CASE
            CASE cType == "C"
               uValue := RTrim(uValue)
               nLen   := Len(uValue)
               cLocateBlock +=  cAnd + " substr("+cField +",1,"+;
                  lTrim(Str(nLen))+" ) == '" + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cLocateBlock += cAnd + cField + " == "+ cValToChar( uValue )
            CASE cType == "D"
               cLocateBlock += cAnd + cField + " == "+ "CToD( '" +DToC( uValue )+"' )"
            ENDCASE
         ENDIF
      NEXT
   ENDIF
   IF ! oTb:lIsArr .and. ! oTb:lIsTxt  .and. oTb:cAlias == "ADO_"
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cOrder
         cType := ValType( uValue )
         IF !Empty(uValue)
            IF !Empty(cLocateBlock)   // Only a single-column name may be specified in cLocateBlock.
               Tone( 500, 1 )

               RETURN cLocateBlock
            ENDIF
            DO CASE
            CASE cType == "C"
               cComp := If( At( '*', uValue ) != 0, " LIKE '", " = '" )
               uValue := RTrim(uValue)
               cLocateBlock :=  cField + cComp + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cLocateBlock := cField + " = "+ cValToChar( uValue )
            CASE cType == "D"
               cLocateBlock := cField + " = #" +DToC( uValue )+"# "
            ENDCASE
         ENDIF
      NEXT
   ENDIF

   RETURN cLocateBlock

   * ============================================================================
   * FUNCTION TSBrowse BuildAutoFiltr() Version 1.47 Adaption HMG
   * Used in AutoFilter by Functions SpecHeader. Returns a string used for create bBlock of Filter
   * ============================================================================

STATIC FUNCTION BuildAutoFilter( oTb )

   LOCAL nCol, nLen, cType, uValue, cField, cFilterBlock := "", cAnd, cComp

   //   IF oTb:lIsArr
   //   endif
   IF oTb:lIsDbf
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cData
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := If( Empty( cFilterBlock ), "", " .AND. " )
            DO CASE
            CASE cType == "C"
               uValue := RTrim(uValue)
               nLen   := Len(uValue)
               cFilterBlock += cAnd + " substr("+cField +",1,"+;
                  lTrim(Str(nLen))+" ) == '" + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cFilterBlock += cAnd + cField + " == "+ cValToChar( uValue )
            CASE cType == "D"
               cFilterBlock += cAnd + cField + " == "+ "CToD( '" +DToC( uValue )+"' )"
            ENDCASE
         ENDIF
      NEXT
   ENDIF
   IF ! oTb:lIsArr .and. ! oTb:lIsTxt .and. oTb:cAlias == "ADO_"
      FOR nCol:=1 TO Len( oTb:aColumns )
         uValue := oTb:aColumns[ nCol ]:cSpcHeading
         cField := oTb:aColumns[ nCol ]:cOrder
         cType := ValType( uValue )
         IF !Empty(uValue)
            cAnd := If( Empty( cFilterBlock ), "", " AND " )
            DO CASE
            CASE cType == "C"
               cComp := If(At( '*', uValue ) != 0, " LIKE '", " = '" )
               uValue := RTrim(uValue)
               cFilterBlock += cAnd + cField + cComp + uValue + "'"
            CASE cType == "N" .or. cType == "L"
               cFilterBlock += cAnd + cField + " = "+ cValToChar( uValue )
            CASE cType == "D"
               cFilterBlock += cAnd +cField + " = #" +DToC( uValue )+"# "
            ENDCASE
         ENDIF
      NEXT
   ENDIF

   RETURN cFilterBlock

   #ifdef _TSBFILTER7_
   * ============================================================================
   * FUNCTION TSBrowse BrwGoto() Version 7.0 Jul/15/2004
   * Executes the action defined into the block created with FUNCTION BuildSkip()
   * ============================================================================

STATIC FUNCTION BrwGoTo( n, bWhile, oTb )

   LOCAL nSkipped := 0, ;
      nDirection := If( n > 0, 1, -1 )

   WHILE nSkipped != n .and. Eval( bWhile ) .and. ! ( oTb:cAlias )->( EoF() ) .and. ! ( oTb:cAlias )->( BoF() )
      ( oTb:cAlias )->( DbSkip( nDirection ) )
      nSkipped += nDirection

      IF oTb:bFilter != Nil
         WHILE ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( EoF() ) .and. ! ( oTb:cAlias )->( BoF() )
            ( oTb:cAlias )->( DbSkip( nDirection ) )
         ENDDO
      ENDIF

   ENDDO

   DO CASE
   CASE ( oTb:cAlias )->( EoF() )
      ( oTb:cAlias )->( DbSkip( -1 ) )

      WHILE oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( BoF() )
         ( oTb:cAlias )->( DbSkip( -1 ) )
      ENDDO

      IF ! oTb:lAppendMode
         nSkipped += -nDirection
      ELSE
         IF oTb:nPrevRec == Nil
            oTb:nPrevRec := ( oTb:cAlias )->( RecNo() )
         ENDIF
         ( oTb:cAlias )->( DbGoTo( 0 ) )       // phantom record
      ENDIF

   CASE ( oTb:cAlias )->( BoF() )
      ( oTb:cAlias )->( DbGoTo( ( oTb:cAlias )->( RecNo() ) ) )

      WHILE oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ! ( oTb:cAlias )->( EoF() )
         ( oTb:cAlias )->( DbSkip( 1 ) )
      ENDDO

      nSkipped++

   CASE ! Eval( bWhile )
      IF nDirection == 1 .and. oTb:lAppendMode
         IF oTb:nPrevRec == Nil
            ( oTb:cAlias )->( DbSkip( -1 ) )
            oTb:nPrevRec := ( oTb:cAlias )->( RecNo() )
         ENDIF
         ( oTb:cAlias )->( DbGoTo( 0 ) )       // phantom record
      ELSE
         ( oTb:cAlias )->( DbSkip( -nDirection ) )
         WHILE oTb:bFilter != Nil .and. ! Eval( oTb:bFilter ) .and. ;
               ! ( oTb:cAlias )->( BoF() ) .and. ! ( oTb:cAlias )->( EoF() )
            ( oTb:cAlias )->( DbSkip( -nDirection ) )
         ENDDO

         nSkipped += -nDirection
      ENDIF
   ENDCASE

   RETURN nSkipped
   #endif

   * ============================================================================
   * FUNCTION TSBrowse:DateSeek() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION DateSeek( cSeek, nKey )

   LOCAL cChar  := Chr( nKey ), ;
      nSpace := At( " ", cSeek ), ;
      cTemp  := ""

   /* only  0..9 */
   IF nKey >= 48 .and. nKey <= 57
      IF nSpace <> 0
         cTemp := Left( cSeek, nSpace - 1 )
         cTemp += cChar
         cTemp += SubStr( cSeek, nSpace + 1, Len( cSeek ) )
         cSeek := cTemp
      ELSE
         cSeek := cSeek
         Tone(500, 1)
      ENDIF
   ELSEIF nKey == VK_BACK
      IF nSpace == 4 .or. nSpace == 7
         cTemp := Left( cSeek, nSpace - 3 )
         cTemp += " "
         cTemp += SubStr( cSeek, nSpace - 1, Len( cSeek ) )
      ELSEIF nSpace == 0
         cTemp := Left( cSeek, Len( cSeek ) - 1 )
      ELSEIF nSpace == 1
         cTemp := cSeek
      ELSE
         cTemp := Left( cSeek, nSpace - 2 )
         cTemp += " "
         cTemp += SubStr( cSeek, nSpace, Len( cSeek ) )
      ENDIF
      cSeek := PadR( cTemp, 10 )
   ELSE
      Tone( 500, 1 )
   ENDIF

   RETURN cSeek

   * ============================================================================
   * FUNCTION TSBrowse EmptyAlias() Version 9.0 Nov/30/2009
   * Returns .T. if cAlias is not a constant "ARRAY" (browsing an array),
   * or a constant "TEXT_" (browsing a text file), or an active database alias.
   * ============================================================================

STATIC FUNCTION EmptyAlias( cAlias )

   LOCAL bErrorBlock, lEmpty := .T.

   IF ! Empty( cAlias )

      IF cAlias == "ARRAY" .or. "TEXT_" $ cAlias .or. "ADO_" $ cAlias .or. "SQL" $ cAlias
         lEmpty := .F.
      ELSE
         bErrorBlock := ErrorBlock( { | o | Break( o ) } )
         BEGIN SEQUENCE
            IF (cAlias)->( Used() )
               lEmpty := .F.
            ENDIF
         END SEQUENCE
         ErrorBlock( bErrorBlock )
      ENDIF

   ENDIF

   RETURN lEmpty

   * ============================================================================
   * FUNCTION TSBrowse GetUniqueName( cName ) Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION GetUniqueName( cName )

   RETURN ( "TSB_" + cName + hb_ntos( _GetId() ) )

   * ============================================================================
   * FUNCTION TSBrowse IsChar() Version 9.0 Nov/30/2009
   * Used by METHOD KeyChar() to filter keys according to the field type
   * Clipper's function IsAlpha() doesn't fit the purpose in some cases
   * ============================================================================

STATIC FUNCTION _IsChar( nKey )

   RETURN ( nKey >= 32 .and. nKey <= 255 )

   * ============================================================================
   * FUNCTION TSBrowse IsNumeric() Version 9.0 Nov/30/2009
   * Function used by METHOD KeyChar() to filter keys according to the field type
   * Clipper's function IsDigit() doesn't fit the purpose in some cases
   * ============================================================================

STATIC FUNCTION _IsNumeric( nKey )

   RETURN ( Chr( nKey ) $ ".+-0123456789" )

   * ============================================================================
   * FUNCTION TSBrowse MakeBlock() Version 9.0 Nov/30/2009
   * Called from METHOD Default() to assign data to columns
   * ============================================================================

STATIC FUNCTION MakeBlock( Self, nI )

   RETURN { || Eval( ::bLine )[ nI ] }

   * ============================================================================
   * FUNCTION TSBrowse nValToNum() Version 9.0 Nov/30/2009
   * Converts any type variables value into numeric
   * ============================================================================

FUNCTION nValToNum( uVar )

   LOCAL nVar := If( ValType( uVar ) == "N", uVar, ;
      If( ValType( uVar ) == "C", Val( StrTran( AllTrim( uVar ), "," ) ), ;
      If( ValType( uVar ) == "L", If( uVar, 1, 0 ), ;
      If( ValType( uVar ) == "D", Val( DtoS( uVar ) ), 0 ) ) ) )

   RETURN nVar

   * ============================================================================
   * METHOD TSBrowse:SetRecordSet() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD SetRecordSet( oRSet ) CLASS TSBrowse

   DEFAULT ::oRSet     := oRSet, ;
      ::bGoTop    := {|| ::oRSet:MoveFirst() }, ;
      ::bGoBottom := {|| ::oRSet:MoveLast() }, ;
      ::bKeyCount := {|| ::oRSet:RecordCount() }, ;
      ::bBof      := {|| ::oRSet:Bof() }, ;
      ::bEof      := {|| ::oRSet:Eof() }, ;
      ::bSkip     := {| n | RSetSkip( ::oRSet, If( n == nil, 1, n ), Self ) }, ;
      ::bKeyNo    := { | n | If( n == Nil, ::oRSet:AbsolutePosition, ::oRSet:AbsolutePosition := n ) }, ;
      ::bLogicLen := { || ::oRSet:RecordCount() }, ;
      ::bGoToPos  := { |n| Eval( ::bKeyNo, n ) }
   ::bRecNo    := {| n | If( n == nil, If( ::oRSet:RecordCount() > 0, ::oRSet:BookMark, 0 ), ;
      If( ::oRSet:RecordCount() > 0, ( ::oRSet:BookMark := n ), 0 ) ) }

   ::nLen := Eval( ::bLogicLen )
   ::ResetVScroll( .T. )

   RETURN Self

   * ============================================================================
   * FUNCTION TSBrowse RSetSkip() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION RSetSkip( oRSet, n )

   LOCAL nRecNo := oRSet:AbsolutePosition

   oRSet:Move( n )

   IF oRSet:Eof()
      oRSet:MoveLast()
   ELSEIF oRSet:Bof()
      oRSet:MoveFirst()
   ENDIF

   RETURN oRSet:AbsolutePosition - nRecNo

   * ============================================================================
   * FUNCTION TSBrowse RSetLocate() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION RSetLocate( oTb, cFindCriteria, lDescend, lContinue  )

   LOCAL nRecNo
   LOCAL oRSet := oTb:oRSet

   DEFAULT lDescend := .f., lContinue := .t.

   nRecNo := oRSet:AbsolutePosition
   IF !lContinue
      oRSet:MoveFirst()
   ENDIF
   IF lDescend
      oRSet:Find( cFindCriteria, 1,adSearchBackward )
   ELSE
      oRSet:Find( cFindCriteria, 1,adSearchForward )
   ENDIF
   IF oRSet:Eof()
      Eval(oTb:bGoToPos, nRecNo )
      Tone( 500, 1 )
   ELSEIF oRSet:Bof()
      Eval(oTb:bGoToPos, nRecNo )
      Tone( 500, 1 )
   ENDIF

   RETURN oRSet:AbsolutePosition - nRecNo

   * ============================================================================
   * FUNCTION TSBrowse RSetFilter() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION RSetFilter( oTb, cFilterCriteria )

   LOCAL nRecNo
   LOCAL oRSet := oTb:oRSet

   IF !Empty(  cFilterCriteria )
      oRSet:Filter := cFilterCriteria
      IF oRSet:Eof()
         Tone( 500, 1 )
         oRSet:Filter := adFilterNone
      ENDIF
   ELSE
      oRSet:Filter := adFilterNone
   ENDIF
   nRecNo := oRSet:AbsolutePosition

   RETURN nRecNo

   * ============================================================================
   * FUNCTION TSBrowse SetHeights() Version 7.0 Jul/15/2004
   * ============================================================================

STATIC FUNCTION SetHeights( oBrw )

   LOCAL nEle, nHeight, nHHeight, oColumn, nAt, cHeading, cRest, nOcurs, ;
      hFont, ;
      lDrawFooters := If( oBrw:lDrawFooters != Nil, oBrw:lDrawFooters, .F. )

   DEFAULT oBrw:nLineStyle := LINES_ALL

   IF oBrw:lDrawHeaders

      nHHeight := oBrw:nHeightHead

      FOR nEle := 1 TO Len( oBrw:aColumns )

         oColumn := oBrw:aColumns[ nEle ]
         cHeading := If( Valtype( oColumn:cHeading ) == "B", Eval( oColumn:cHeading, nEle, oBrw ), oColumn:cHeading )
         hFont := If( oColumn:hFontHead != Nil, oColumn:hFontHead, oBrw:hFont )
         hFont := If( ValType( hFont ) == "B", Eval( hFont, 0, nEle, oBrw ), hFont )
         hFont := If( hFont == Nil, 0, oBrw:hFont )

         IF Valtype( cHeading ) == "C" .and. ;
               ( nAt := At( Chr( 13 ), cHeading ) ) > 0

            nOcurs := 1
            cRest := Substr( cHeading, nAt + 2 )

            WHILE ( nAt := At( Chr( 13 ), cRest ) ) > 0
               nOcurs++
               cRest := Substr( cRest, nAt + 2 )
            ENDDO

            nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
            nHeight *= ( nOcurs + 1 )

            IF ( nHeight + 1 ) > nHHeight
               nHHeight := nHeight + 1
            ENDIF

         ELSEIF Valtype( cHeading ) == "C" .and. LoWord( oBrw:aColumns[ nEle ]:nHAlign ) == DT_VERT

            nHeight := GetTextWidth( oBrw:hDC, cHeading, hFont )

            IF nHeight > nHHeight
               nHHeight := nHeight
            ENDIF

         ENDIF

      NEXT

      oBrw:nHeightHead := nHHeight
   ELSE
      oBrw:nHeightHead := 0
   ENDIF

   IF oBrw:lFooting .and. lDrawFooters

      nHHeight := oBrw:nHeightFoot

      FOR nEle := 1 TO Len( oBrw:aColumns )

         oColumn := oBrw:aColumns[ nEle ]
         cHeading := If( Valtype( oColumn:cFooting ) == "B", Eval( oColumn:cFooting, nEle, oBrw ), oColumn:cFooting )
         hFont := If( oColumn:hFontFoot != Nil, oColumn:hFontFoot, If( oBrw:hFont != Nil, oBrw:hFont, 0 ) )

         hFont := If( ValType( hFont ) == "B", Eval( hFont, 0, nEle, oBrw ), hFont )
         hFont := If( hFont == Nil, 0, oBrw:hFont )

         IF Valtype( cHeading ) == "C" .and. ( nAt := At( Chr( 13 ), cHeading ) ) > 0

            nOcurs := 1
            cRest := Substr( cHeading, nAt + 2 )

            WHILE ( nAt := At( Chr( 13 ), cRest ) ) > 0
               nOcurs++
               cRest := Substr( cRest, nAt + 2 )
            ENDDO

            nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
            nHeight *= ( nOcurs + 1 )

            IF ( nHeight + 1 ) > nHHeight
               nHHeight := nHeight + 1
            ENDIF

         ENDIF

      NEXT

      oBrw:nHeightFoot := nHHeight
   ELSE
      oBrw:nHeightFoot := 0
   ENDIF

   // Now for cells

   nHHeight := oBrw:nHeightCell

   FOR nEle := 1 TO Len( oBrw:aColumns )
      oColumn := oBrw:aColumns[ nEle ]
      cHeading := Eval( oColumn:bData )
      hFont := If( oColumn:hFont != Nil, oColumn:hFont, oBrw:hFont )
      hFont := If( ValType( hFont ) == "B", Eval( hFont, 1, nEle, oBrw ), hFont )
      hFont := If( hFont == Nil, 0, oBrw:hFont )

      IF ( Valtype( cHeading ) == "C"  .and. At( Chr( 13 ), cHeading ) > 0 ) .or. ;
            ValType( cHeading ) == "M" .or. ( oColumn:cDataType != Nil .and. oColumn:cDataType == "M" )

         DEFAULT oBrw:nMemoHV := 2
         nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
         nHeight *= oBrw:nMemoHV
         nHeight += If( oBrw:nLineStyle != 0 .and. oBrw:nLineStyle != 2, 1, 0 )
      ELSE
         nHeight := SBGetHeight( oBrw:hWnd, hFont, 0 )
         nHeight += If( oBrw:nLineStyle != 0 .and. oBrw:nLineStyle != 2, 1, 0 )
      ENDIF

      nHHeight := Max( nHeight, nHHeight )

   NEXT

   oBrw:nHeightCell := nHHeight

   RETURN NIL

   * ============================================================================
   * FUNCTION TSBrowse FileRename() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION FileRename( oBrw, cOldName, cNewName, lErase )

   LOCAL nRet, lNew := File( cNewName )

   DEFAULT lErase := .T.

   IF ! File( cOldName )
      MsgStop( oBrw:aMsg[ 29 ] + CRLF + AllTrim( cOldName ) + oBrw:aMsg[ 30 ], oBrw:aMsg[ 28 ] )

      RETURN -1
   ENDIF

   IF lErase .and. lNew

      IF FErase(  cNewName  ) < 0
         MsgStop( oBrw:aMsg[ 11 ] + Space( 1 ) + AllTrim( cNewName ), ;
            oBrw:aMsg[ 28 ] + Space( 1 ) + LTrim( Str( FError() ) ) )

         RETURN -1
      ENDIF

   ELSEIF ! lErase .and. lNew

      RETURN -1
   ENDIF

   nRet := MoveFile( cOldName, cNewName )

   IF File( cOldName ) .and. File( cNewName )
      FErase( cOldName  )
   ENDIF

   RETURN nRet

STATIC FUNCTION AdoGenFldBlk( oRS, nFld )

   RETURN { |uVar| If( uVar == Nil, oRs:Fields( nFld ):Value, oRs:Fields( nFld ):Value := uVar ) }

STATIC FUNCTION ClipperFieldType( nType )

   LOCAL aNum := { adSmallInt, adInteger, adSingle, adDouble, adUnsignedTinyInt, adTinyInt, adUnsignedSmallInt, ;
      adUnsignedInt, adBigInt, adUnsignedBigInt, adNumeric, adVarNumeric, adCurrency }, ;
      cType

   DO CASE
   CASE AScan( { adChar, adWChar, adVarChar, adVarWChar }, nType ) > 0
      cType := "C"
   CASE AScan( aNum, nType ) > 0
      cType := "N"
   CASE nType == 11
      cType := "L"
   CASE AScan( { adDate, adDBDate }, nType ) > 0
      cType := "D"
   CASE nType == adLongVarWChar
      cType := "M"
   OTHERWISE
      cType := nType
   END CASE

   RETURN cType

   * ============================================================================
   * FUNCTION TSBrowse IdentSuper() Version 7.0
   * ============================================================================

STATIC FUNCTION IdentSuper( aHeaders, oBrw )

   LOCAL nI := 1, cSuper, cOldSuper := '', nFromCol := 1, nToCol
   LOCAL aSuperHeaders := {}, nSel := 0

   IF oBrw:lSelector
      nSel := 1
   ENDIF

   WHILE nI <= Len( aHeaders )
      IF Valtype( aHeaders[ nI ] ) == "C"  .and. At( '~', aHeaders[ nI ] ) > 0
         cSuper := SubStr(aHeaders[ nI ], At( '~', aHeaders[ nI ] )+1)
         aHeaders [nI] := SubStr( aHeaders[ nI ], 1, At( '~', aHeaders[ nI ] )-1 )
      ELSE
         cSuper := ''
      ENDIF
      IF !(cOldSuper == cSuper)
         nToCol := nI-1
         AAdd( aSuperHeaders, {cOldSuper, nFromCol+nSel, nToCol+nSel} )
         cOldSuper := cSuper
         nFromCol := nI
      ELSEIF nI == Len( aHeaders )
         AAdd( aSuperHeaders, {cOldSuper, nFromCol+nSel, nI+nSel} )
      ENDIF
      nI++
   ENDDO

   RETURN aSuperHeaders

   * ============================================================================
   * METHOD TSBrowse:RefreshARow() Version 9.0 Nov/30/2009    JP Ver 1.90
   * ============================================================================

METHOD RefreshARow( xRow ) CLASS TSBrowse

   LOCAL nRow     := ::nRowPos, nSkip, ;
      nRows    := ::nRowCount(), ;
      nAt      := ::nAt, ;
      nLine

   DEFAULT xRow := nAt

   IF xRow == nAt
      ::Refresh( .F. )
   ELSEIF xRow >= nAt - nRow + 1 .and. xRow <= nAt + nRows - nRow
      nLine := xRow - (nAt -nRow )
      nSkip := nline - nRow
      ::Skip( nSkip )
      ::DrawLine( nLine )
      ::Skip( -nSkip )
   ENDIF

   RETURN NIL

   * ============================================================================
   * METHOD TSBrowse:UpAStable() Version 9.0 Nov/30/2009
   * ============================================================================

METHOD UpAStable() CLASS TSBrowse

   LOCAL nRow     := ::nRowPos, ;
      nRows    := ::nRowCount(), ;
      n        := 1, ;
      lSkip    := .T., ;
      bChange  := ::bChange, ;
      nLastPos := ::nLastPos, ;
      nAt      := ::nAt , ;
      nRecNo

   ::nLen   := Len( ::aArray )
   ::nAt    := Min( ::nLen, ::nAt )
   nRecNo   := ::aArray[ ::nAt ]

   IF ::nLen > nRows

      nAt += ( nRows - nRow )

      IF nAt >= ::nLen
         Eval( ::bGoBottom )
         ::nRowPos := nRows

         WHILE ::nRowPos > 1 .and. ! lAEqual( ::aArray[ ::nAt ], nRecNo )
            ::Skip( -1 )
            ::nRowPos --
         ENDDO

         ::Refresh( .F. )
         ::ResetVScroll()

         RETURN Self
      ENDIF
   ENDIF

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   Eval( ::bGoTop )

   WHILE ! ::Eof()

      IF n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         EXIT
      ENDIF

      IF lAEqual( ::aArray[ ::nAt ], nRecNo )
         ::nRowPos := n
         EXIT
      ELSE
         ::Skip( 1 )
      ENDIF

      n++
   ENDDO

   IF lSkip
      ::Skip( -::nRowPos )
   ENDIF

   ::nLastPos := nLastPos
   ::nAt := AScan( ::aArray, {|e| lAEqual( e, nRecNo ) } )
   ::lHitTop  := .F.

   IF  ::oVScroll != Nil .and. nRow != ::nRowPos
      ::oVScroll:SetPos(  ::RelPos(  ::nLogicPos() ) )
   ENDIF

   ::bChange := bChange

   IF ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   ENDIF

   RETURN Self

   * =================================================================================
   * METHOD TSBrowse:lSeek() Version 9.0 Nov/30/2009 dichotomic search with recordsets
   * =================================================================================

METHOD lRSeek( uData, nFld, lSoft ) CLASS TSBrowse

   LOCAL nCen, ;
      lFound := .F., ;
      nInf   := 1, ;
      nSup   := ::nLen, ;
      nRecNo := Eval( ::bKeyNo )

   DEFAULT lSoft := .F.

   WHILE nInf <= nSup
      nCen := Int( ( nSup + nInf ) / 2 )
      Eval( ::bGoToPos, nCen )

      IF ( lFound := If( lSoft, uData = ::oRSet:Fields( nFld ):Value, uData == ::oRSet:Fields( nFld ):Value ) )
         EXIT
      ELSEIF uData > ::oRSet:Fields( nFld ):Value
         nInf := nCen + 1
      ELSE
         nSup := nCen - 1
      ENDIF
   ENDDO

   IF ! lFound
      Eval( ::bGoToPos, nRecNo )
   ENDIF

   RETURN lFound

   * ================================================================================
   * METHOD TSBrowse:UpRStable() Version 9.0 Nov/30/2009 recorset cursor repositioned
   * ================================================================================

METHOD UpRStable( nRecNo ) CLASS TSBrowse

   LOCAL nRow     := ::nRowPos, ;
      nRows    := ::nRowCount(), ;
      n        := 1, ;
      lSkip    := .T., ;
      bChange  := ::bChange, ;
      nLastPos := ::nLastPos

   Eval( ::bRecNo, nRecNo )
   IF ::nLen > nRows
      ::oRSet:Move( nRows - nRow )

      IF Eval( ::bBof )            //::EoF()
         Eval( ::bGoBottom )
         ::nRowPos := nRows
         WHILE ::nRowPos > 1 .and. nRecNo != Eval( ::bRecNo )
            ::Skip( -1 )
            ::nRowPos --
         ENDDO

         ::Refresh( .F. )
         ::ResetVScroll()

         RETURN Self
      ELSE
         Eval( ::bGoToPos, nRecNo )
      ENDIF

   ENDIF

   ::bChange    := Nil
   ::lHitTop    := .F.
   ::lHitBottom := .F.
   ::GoTop()

   WHILE ! ::EoF()

      IF n > nRows
         ::nRowPos := nRow
         lSkip     := .F.
         EXIT
      ENDIF

      IF nRecNo == Eval( ::bRecNo )
         ::nRowPos := n
         EXIT
      ELSE
         ::Skip( 1 )
      ENDIF

      n++
   ENDDO

   IF lSkip
      ::Skip( -::nRowPos )
   ENDIF

   Eval( ::bRecNo, nRecNo )  // restores Record position
   ::nLastPos := nLastPos
   ::nAt      := ::nLastnAt := ::nLogicPos()
   ::lHitTop  := .F.

   IF ::oVScroll != Nil .and. ! Empty( ::bKeyNo )     // restore scrollbar thumb
      ::oVScroll:SetPos( ::RelPos( ( ::cAlias )->( Eval( ::bKeyNo ) ) ) )
   ENDIF

   ::bChange := bChange

   IF ::lPainted
      ::Refresh( If( ::nLen < nRows, .T., .F. ) )
   ENDIF

   RETURN Self

   * ===================================================================================================
   * METHOD TSBrowse:nField() Version 9.0 Nov/30/2009 returns field number from field name in recordsets
   * ===================================================================================================

METHOD nField( cName ) CLASS TSBrowse

   LOCAL nEle, ;
      nCount := ::oRSet:Fields:Count()

   FOR nEle := 1 To nCount
      IF Upper( ::oRSet:Fields( nEle - 1 ):Name ) == Upper( cName )
         EXIT
      ENDIF
   NEXT

   RETURN If( nEle <= nCount, nEle - 1, -1 )

CLASS TSBcell

   VAR nRow       AS NUMERIC  INIT 0
   VAR nCol       AS NUMERIC  INIT 0
   VAR nWidth     AS NUMERIC  INIT 0
   VAR nHeight    AS NUMERIC  INIT 0

METHOD New()   INLINE ( Self )

ENDCLASS

* ===================================================================================================
* METHOD TSBrowse:GetCellInfo() returns the cell coordinates for auxiliary TSBcell class
* ===================================================================================================

METHOD GetCellInfo( nRowPos, nCell, lColSpecHd ) CLASS TSBrowse

   LOCAL nI, ix, nStartX := 0, oCol, cBrw, cForm
   LOCAL nRow, nCol, nWidth, nHeight
   LOCAL oCell := TSBcell():New()

   DEFAULT nRowPos    := ::nRowPos, ;
      nCell      := ::nCell, ;
      lColSpecHd := .F.

   cForm := ::cParentWnd
   cBrw  := ::cControlName
   oCol  := ::aColumns[ nCell ]

   IF ::nFreeze > 0
      FOR nI := 1 To Min( ::nFreeze , nCell - 1 )
         nStartX += ::GetColSizes()[ nI ]
      NEXT
   ENDIF

   FOR nI := ::nColPos To nCell - 1
      nStartX += ::GetColSizes()[ nI ]
   NEXT

   IF lColSpecHd
      nRow    := ::nHeightHead + ::nHeightSuper + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 1 )
      nHeight := ::nHeightSpecHd - If( oCol:l3DLook, 1, -1 )
   ELSE
      nRow    := nRowPos - 1
      nRow    := ( nRow * ::nHeightCell ) + ::nHeightHead + ;
         ::nHeightSuper + ::nHeightSpecHd + If( oCol:l3DLook, 2, 0 )
      nCol    := nStartX + If( oCol:l3DLook, 2, 0 )
      nWidth  := ::GetColSizes()[ nCell ] - If( oCol:l3DLook, 2, 0 )
      nHeight := ::nHeightCell - If( oCol:l3DLook, 1, -1 )
   ENDIF

   ix := GetControlIndex ( cBrw, cForm )
   IF _HMG_aControlContainerRow [ix] == -1
      nRow += ::nTop - 1
      nCol += ::nLeft
   ELSE
      nRow += _HMG_aControlRow [ix] - 1
      nCol += _HMG_aControlCol [ix]
   ENDIF

   nRow    += ::aEditCellAdjust[1]
   nCol    += ::aEditCellAdjust[2]
   nWidth  += ::aEditCellAdjust[3] + 2
   nHeight += ::aEditCellAdjust[4]

   oCell:nRow    := nRow
   oCell:nCol    := nCol
   oCell:nWidth  := nWidth
   oCell:nHeight := nHeight

   RETURN oCell

   * ============================================================================
   * FUNCTION lAEqual() Version 9.0 Nov/30/2009 arrays comparison
   * ============================================================================

FUNCTION lAEqual( aArr1, aArr2 )

   LOCAL nEle

   IF Empty( aArr1 ) .and. Empty( aArr2 )

      RETURN .T.
   ELSEIF Empty( aArr1 ) .or. Empty( aArr2 )

      RETURN .F.
   ELSEIF ValType( aArr1 ) != "A" .or. ValType( aArr2 ) != "A"

      RETURN .F.
   ELSEIF Len( aArr1 ) != Len( aArr2 )

      RETURN .F.
   ENDIF

   FOR nEle := 1 To Len( aArr1 )

      IF ValType( aArr1[ nEle ] ) == "A" .and. ! lAEqual( aArr1[ nEle ], aArr2[ nEle ] )

         RETURN .F.
      ELSEIF ValType( aArr1[ nEle ] ) != ValType( aArr2[ nEle ] )

         RETURN .F.
      ELSEIF ! ( aArr1[ nEle ] == aArr2[ nEle ] )

         RETURN .F.
      ENDIF
   NEXT

   RETURN .T.

FUNCTION StockBmp( uAnsi, oWnd, cPath, lNew )

   LOCAL cBmp, nHandle, nWrite, hBmp, cBmpFile, cName, ;
      cTmp := AllTrim( GetEnv( "TMP" ) )

   LOCAL aStock := { "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // calendar
   "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
      "00 00 80 00 00 00 C4 0E 00 00 C4 0E 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 88" + ;
      "88 88 88 88 88 88 88 77 77 77 77 77 77 78 80 00" + ;
      "00 00 00 00 00 08 80 77 77 77 07 77 77 08 80 FF" + ;
      "FF F7 FF FF FF 08 80 FF FF F7 FF FF FF 08 80 F0" + ;
      "00 07 F0 00 0F 08 80 F9 99 F7 FF 99 9F 08 80 FF" + ;
      "9F F7 FF 99 FF 08 80 FF 9F F7 FF F9 9F 08 80 F9" + ;
      "9F 00 0F 99 9F 08 80 F9 9F F7 FF 99 9F 08 80 FF" + ;
      "FF F7 FF FF FF 08 80 00 00 08 00 00 00 08 88 88" + ;
      "88 88 88 88 88 88", ;
      "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // spinner
   "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
      "00 00 80 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 FF FF FF FF FF FF FF FF FE EE" + ;
      "EE EE EE EE EE FF EE EE EE E6 EE EE EE EF EE EE" + ;
      "EE 66 6E EE EE EF EE EE E6 66 66 EE EE EF EE EE" + ;
      "66 6E 66 6E EE EF EE EE EE EE EE EE EE EF 88 88" + ;
      "88 88 88 88 88 8F EE EE EE EE EE EE EE EF EE EE" + ;
      "66 6E 66 6E EE EF EE EE E6 66 66 EE EE EF EE EE" + ;
      "EE 66 6E EE EE EF EE EE EE E6 EE EE EE EF EE EE" + ;
      "EE EE EE EE EE EF FE EE EE EE EE EE EE FF FF FF" + ;
      "FF FF FF FF FF FF", ;
      "42 4D F6 00 00 00 00 00 00 00 76 00 00 00 28 00" + ; // selector
   "00 00 10 00 00 00 10 00 00 00 01 00 04 00 00 00" + ;
      "00 00 80 00 00 00 C4 0E 00 00 C4 0E 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 C0 C0 C0 00 80 80 80 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 77 77 77 77 77 77 77 77 77 77" + ;
      "77 77 77 77 77 77 77 77 77 77 77 77 77 77 77 77" + ;
      "77 70 77 77 77 77 77 77 77 70 07 77 77 77 77 77" + ;
      "77 70 00 77 77 77 77 77 77 70 00 07 77 77 77 77" + ;
      "77 70 00 00 77 77 77 77 77 70 00 00 07 77 77 77" + ;
      "77 70 00 00 77 77 77 77 77 70 00 07 77 77 77 77" + ;
      "77 70 00 77 77 77 77 77 77 70 07 77 77 77 77 77" + ;
      "77 70 77 77 77 77 77 77 77 77 77 77 77 77 77 77" + ;
      "77 77 77 77 77 77", ;
      "42 4D DE 00 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // sort ascend
   "00 00 0D 00 00 00 0D 00 00 00 01 00 04 00 00 00" + ;
      "00 00 68 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 88 88 88 88 88 88 80 00 88 88" + ;
      "88 88 88 88 80 00 88 88 88 88 88 88 80 00 88 87" + ;
      "FF FF FF F8 80 00 88 87 78 88 8F F8 80 00 88 88" + ;
      "78 88 8F 88 80 00 88 88 77 88 FF 88 80 00 88 88" + ;
      "87 88 F8 88 80 00 88 88 87 7F F8 88 80 00 88 88" + ;
      "88 7F 88 88 80 00 88 88 88 88 88 88 80 00 88 88" + ;
      "88 88 88 88 80 00 88 88 88 88 88 88 80 00", ;
      "42 4D DE 00 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // sort descend
   "00 00 0D 00 00 00 0D 00 00 00 01 00 04 00 00 00" + ;
      "00 00 68 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 88 88 88 88 88 88 80 00 88 88" + ;
      "88 88 88 88 80 00 88 88 88 88 88 88 80 00 88 88" + ;
      "88 7F 88 88 80 00 88 88 87 7F F8 88 80 00 88 88" + ;
      "87 88 F8 88 80 00 88 88 77 88 FF 88 80 00 88 88" + ;
      "78 88 8F 88 80 00 88 87 78 88 8F F8 80 00 88 87" + ;
      "77 77 77 F8 80 00 88 88 88 88 88 88 80 00 88 88" + ;
      "88 88 88 88 80 00 88 88 88 88 88 88 80 00", ;
      "42 4D 4E 01 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // check box checked
   "00 00 12 00 00 00 12 00 00 00 01 00 04 00 00 00" + ;
      "00 00 D8 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 00" + ;
      "00 00 8F FF FF FF FF FF FF FF F8 00 00 00 8F 00" + ;
      "00 00 00 00 00 00 F8 00 00 00 8F 08 88 88 88 88" + ;
      "88 80 F8 00 00 00 8F 08 88 8F 88 88 88 80 F8 00" + ;
      "00 00 8F 08 88 F0 F8 88 88 80 F8 00 00 00 8F 08" + ;
      "8F 00 0F 88 88 80 F8 00 00 00 8F 08 F0 08 00 F8" + ;
      "88 80 F8 00 00 00 8F 08 00 88 80 0F 88 80 F8 00" + ;
      "00 00 8F 08 88 88 88 00 F8 80 F8 00 00 00 8F 08" + ;
      "88 88 88 80 0F 80 F8 00 00 00 8F 08 88 88 88 88" + ;
      "00 F0 F8 00 00 00 8F 08 88 88 88 88 80 80 F8 00" + ;
      "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
      "88 88 88 88 88 80 F8 00 00 00 8F 00 00 00 00 00" + ;
      "00 00 F8 00 00 00 8F FF FF FF FF FF FF FF F8 00" + ;
      "00 00 88 88 88 88 88 88 88 88 88 00 00 00", ;
      "42 4D 4E 01 00 00 00 00 00 00 76 00 00 00 28 00" + ;  // check box unchecked
   "00 00 12 00 00 00 12 00 00 00 01 00 04 00 00 00" + ;
      "00 00 D8 00 00 00 00 00 00 00 00 00 00 00 00 00" + ;
      "00 00 00 00 00 00 00 00 00 00 00 00 80 00 00 80" + ;
      "00 00 00 80 80 00 80 00 00 00 80 00 80 00 80 80" + ;
      "00 00 80 80 80 00 C0 C0 C0 00 00 00 FF 00 00 FF" + ;
      "00 00 00 FF FF 00 FF 00 00 00 FF 00 FF 00 FF FF" + ;
      "00 00 FF FF FF 00 88 88 88 88 88 88 88 88 88 00" + ;
      "00 00 8F FF FF FF FF FF FF FF F8 00 00 00 8F 00" + ;
      "00 00 00 00 00 00 F8 00 00 00 8F 08 88 88 88 88" + ;
      "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
      "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
      "88 88 88 88 88 80 F8 00 00 00 8F 08 88 88 88 88" + ;
      "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
      "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
      "88 88 88 88 88 80 F8 00 00 00 8F 08 88 88 88 88" + ;
      "88 80 F8 00 00 00 8F 08 88 88 88 88 88 80 F8 00" + ;
      "00 00 8F 08 88 88 88 88 88 80 F8 00 00 00 8F 08" + ;
      "88 88 88 88 88 80 F8 00 00 00 8F 00 00 00 00 00" + ;
      "00 00 F8 00 00 00 8F FF FF FF FF FF FF FF F8 00" + ;
      "00 00 88 88 88 88 88 88 88 88 88 00 00 00" }

   LOCAL aStkName  := { "SCalen.bmp", "SSpinn.bmp", "SSelec.bmp", "SSAsc.bmp", "SSDesc.bmp", "SCheck.bmp", "SUncheck.bmp" }

   DEFAULT uAnsi := aStock[ 1 ], ;
      cPath := "", ;
      lNew  := .F.

   HB_SYMBOL_UNUSED( oWnd )

   IF ValType( uAnsi ) == "N" .and. uAnsi <= Len( aStkName )
      cName := aStkName[ uAnsi ]
      uAnsi := StrTran( aStock[ uAnsi ], " " )
   ELSEIF ValType( uAnsi ) == "N"
      uAnsi := StrTran( aStock[ 1 ], " " )  // calendar
      cName := aStkName[ 1 ]
   ELSE
      uAnsi := StrTran( uAnsi, " " )
      cName := If( ! Empty( cPath ) .and. ".BMP" $ Upper( cPath ), "", "STmp.bmp" )
   ENDIF

   cBmp := cAnsi2Bmp( uAnsi )

   IF Empty( cTmp )
      IF Empty( cTmp := AllTrim( GetEnv( "TEMP" ) ) )
         cTmp := CurDir()
      ENDIF
   ENDIF

   cBmpFile := If( ! Empty( cPath ), cPath + If( Right( cPath ) != "\", "\", "" ), cTmp + "\" ) + cName
   cBmpFile := StrTran( cBmpFile, "\\", "\" )

   IF ! File( cBmpFile )

      IF ( nHandle := FCreate( cBmpFile ) ) < 0

         RETURN NIL
      ENDIF

      nWrite := FWrite( nHandle, cBmp, Len( cBmp ) )

      IF nWrite < Len( cBmp )
         FClose( nHandle )

         RETURN NIL
      ENDIF

      FClose( nHandle )
   ENDIF

   hBmp := LoadImage( cBmpFile )

   FErase( cBmpFile )

   RETURN hBmp

   * ============================================================================
   * FUNCTION cAnsi2Bmp() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION cAnsi2Bmp( cAnsi )

   LOCAL cLong, ;
      cBmp := ""

   WHILE Len( cAnsi ) >= 8
      cLong := Left( cAnsi, 8 )
      cBmp += cHex2Bin( cAnsi2Hex( cLong ) )
      cAnsi := Stuff( cAnsi, 1, 8, "" )
   ENDDO

   IF ! Empty( cAnsi )
      cBmp += cHex2Bin( cAnsi2Hex( PadR( cAnsi, 4, "0" ) ) )
   ENDIF

   RETURN cBmp

   * ============================================================================
   * FUNCTION cAnsi2Hex() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION cAnsi2Hex( cAnsi )

   LOCAL cDig, ;
      cHex := ""

   cAnsi := AllTrim( cAnsi )

   WHILE Len( cAnsi ) >= 2
      cDig := Left( cAnsi, 2 )
      cHex := cDig + cHex
      cAnsi := Stuff( cAnsi, 1, 2, "" )
   ENDDO

   RETURN cHex

   * ============================================================================
   * FUNCTION cHex2Bin() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION cHex2Bin( cHex )

   LOCAL nPos, nEle, ;
      nExp := 0, ;
      nDec := 0, ;
      aHex := { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F" }

   cHex := AllTrim( cHex )

   FOR nPos := Len( cHex ) To 1 Step -1
      nEle := Max( 0, AScan( aHex, SubStr( cHex, nPos, 1 ) ) - 1 )
      nDec += ( nEle * ( 16 ** nExp ) )
      nExp ++
   NEXT

   RETURN If( Len( cHex ) > 4, L2Bin( Int( nDec ) ), If( Len( cHex ) > 2, I2Bin( Int( nDec ) ), Chr( Int( nDec ) ) ) )

   * ============================================================================
   * FUNCTION nBmpWidth() Version 9.0 Nov/30/2009
   * ============================================================================

STATIC FUNCTION nBmpWidth( hBmp )

   RETURN GetBitmapSize( hBmp ) [1]

   * ============================================================================
   * FUNCTION _nColumn() Version 9.0 Nov/30/2009
   * ============================================================================

FUNCTION _nColumn( oBrw, cName )

   RETURN Max( AScan( oBrw:aColumns, { |oCol| Upper( oCol:cName ) == Upper( cName ) } ), 1 )

   * ============================================================================
   * FUNCTION SBrowse() Version 9.0 Nov/30/2009
   * ============================================================================

FUNCTION SBrowse( uAlias, cTitle, bSetUp, aCols, nWidth, nHeight, lSql ) // idea from xBrowse

   LOCAL cFormName, oBrw, nSaveSelect, cDbf, cAlias, lEdit, cTable

   DEFAULT uAlias  := Alias(), ;
      cTitle  := If( ValType( uAlias ) == "C", uAlias, "SBrowse"  ), ;
      bSetUp  := { || .F. }, ;
      aCols   := {}, ;
      nWidth  := GetSysMetrics( 0 ) * .75, ;
      nHeight := GetSysMetrics( 1 ) / 2,;
      lSql    := .f.

   IF ValType( uAlias ) == 'C' .and. Select( uAlias ) == 0
      nSaveSelect := Select()
      IF lSql
         cTable := GetUniqueName( "SqlTable" )

         DBUSEAREA( .T.,, "SELECT * FROM "+uAlias, cTable ,,, "UTF8")
         SELECT &cTable

         cAlias := cTable
         uAlias := cAlias
      ELSE

         cDbf   := uAlias
         cAlias := uAlias
         Try
            DbUseArea( .T., nil, cDbf, cAlias, .T. )
            uAlias := cAlias
         CATCH
            uAlias := { { uAlias } }
         End
      ENDIF
   ELSEIF ValType( uAlias ) == 'N'

      IF ! Empty( Alias( uAlias ) )
         uAlias := Alias( uAlias )
      ELSE
         uAlias := { { uAlias } }
      ENDIF
   ELSEIF ValType( uAlias ) $ 'BDLP'
      uAlias := { { uAlias } }
      #ifdef __XHARBOUR__
   ELSEIF ValType( uAlias ) == "H"
      uAlias := aHash2Array( uAlias )
      #endif
   ENDIF

   cFormName := GetUniqueName( "SBrowse" )

   DEFINE WINDOW &cFormName AT 0,0 WIDTH nWidth HEIGHT nHeight TITLE cTitle CHILD BACKCOLOR RGB( 191, 219, 255 )

      nWidth  -= 20
      nHeight -= 50
      DEFINE TBROWSE oBrw AT 10, 10 ALIAS (uAlias) WIDTH nWidth - 16 HEIGHT nHeight - 30 HEADER aCols ;
         AUTOCOLS SELECTOR 20

      lEdit := Eval( bSetUp, oBrw )
      lEdit := If( ValType( lEdit ) == "L", lEdit, .F. )

      WITH OBJECT oBrw
         :nTop      := 10
         :nLeft     := 10
         :nBottom   := :nTop + nHeight - 30
         :nRight    := :nLeft + nWidth - 16
         :lEditable := lEdit
         :lCellBrw  := lEdit
         :nClrLine  := COLOR_GRID
         :nClrHeadBack := { CLR_WHITE, COLOR_GRID }
         :lUpdate   := .T.
         :bRClicked := {|| RecordBrowse( oBrw ) }
         IF lEdit
            AEval( :aColumns, { |o| o:lEdit := .T. } )
         ENDIF
      End With

   END TBROWSE

   @ nHeight-12-iif(_HMG_IsXPorLater,3,0), 10 BUTTON Btn_1 CAPTION oBrw:aMsg[ 44 ] WIDTH 70 HEIGHT 24 ;
      ACTION {|| oBrw:Report(cTitle,,,,.t.), oBrw:GoTop() }

   @ nHeight-12-iif(_HMG_IsXPorLater,3,0), 90 BUTTON Btn_2 CAPTION "Excel" WIDTH 70 HEIGHT 24 ;
      ACTION oBrw:ExcelOle()

   @ nHeight-12-iif(_HMG_IsXPorLater,3,0),nWidth-76 BUTTON Btn_3 CAPTION oBrw:aMsg[ 45 ] WIDTH 70 HEIGHT 24 ;
      ACTION ThisWindow.Release

   IF ! lEdit
      ON KEY ESCAPE ACTION ThisWindow.Release
   ENDIF

END WINDOW
CENTER WINDOW &cFormName
ACTIVATE WINDOW &cFormName

IF ! Empty( cAlias )
   ( cAlias )->( DbCloseArea() )
ENDIF

IF ! Empty( nSaveSelect )
   Select( nSaveSelect )
ENDIF

RETURN NIL

STATIC FUNCTION RecordBrowse( oBrw )

   LOCAL oCol, ;
      aArr := {}

   FOR EACH oCol In oBrw:aColumns
      AAdd( aArr, { oCol:cHeading, Eval( oCol:bData ) } )
   NEXT

   SBrowse( aArr, "Record View", { || .T. }, { "Key", "Value" } )

   RETURN NIL

   #ifdef __XHARBOUR__

STATIC FUNCTION aHash2Array( uAlias ) // a fivetechsoft sample routine

   LOCAL nEle, ;
      aArr := {}

   FOR nEle := 1 To Len( uAlias )
      AAdd( aArr, { HGetKeyAt( uAlias, nEle ), HGetValueAt( uAlias, nEle ) } )
   NEXT

   RETURN aArr

FUNCTION hb_HGetDef( hHash, xKey, xDef )

   LOCAL nPos := HGetPos( hHash, xKey )

   RETURN iif( nPos > 0, HGetValueAt( hHash, nPos ), xDef )

   #endif

