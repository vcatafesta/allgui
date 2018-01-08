/*----------------------------------------------------------------------------
HMG Source File --> h_EventCB.prg

Copyright 2012-2016 by Dr. Claudio Soto (from Uruguay).

mail: <srvet@adinet.com.uy>
blog: http://srvet.blogspot.com

Permission to use, copy, modify, distribute and sell this software
and its documentation for any purpose is hereby granted without fee,
provided that the above copyright notice appear in all copies and
that both that copyright notice and this permission notice appear
in supporting documentation.
It is provided "as is" without express or implied warranty.

----------------------------------------------------------------------------*/

#include "SET_COMPILE_HMG_UNICODE.ch"

MEMVAR _HMG_SYSDATA
MEMVAR _HMG_MainFormIndex
MEMVAR _HMG_LastActiveFormIndex
MEMVAR _HMG_LastActiveControlIndex
MEMVAR _HMG_LastFormIndexWithCursor

MEMVAR _HMG_EventData
MEMVAR _HMG_EventIsInProgress
MEMVAR _HMG_EventIsKeyboardMessage
MEMVAR _HMG_EventIsMouseMessage
MEMVAR _HMG_EventIsHMGWindowsMessage
MEMVAR _HMG_EventHookID
MEMVAR _HMG_EventHookCode
MEMVAR _HMG_EventINDEX
MEMVAR _HMG_EventHWND
MEMVAR _HMG_EventMSG
MEMVAR _HMG_EventWPARAM
MEMVAR _HMG_EventLPARAM
MEMVAR _HMG_EventPROCNAME

FUNCTION EventCompareParam (Param1, Param2)

   IF ValType (Param1) <> "U" .AND. ValType (Param2) <> "U"
      IF ValType (Param1) == "C" .AND. ValType (Param2) == "C"

         RETURN (ALLTRIM(Param1) == ALLTRIM(Param2))
      ELSE

         RETURN (Param1 == Param2)
      ENDIF
   ENDIF

   RETURN .T.

FUNCTION EventCreate (cProcName, hWnd, nMsg)

   LOCAL lStopEvent := .F., lProcessKeyboardMessage := .T., lProcessMouseMessage := .T.
   LOCAL lProcessHMGWindowsMessage := .T., lProcessAllHookMessage := .F.
   LOCAL i, nIndex := 0

   IF ValType( cProcName ) == "C"
      cProcName := AllTrim( cProcName )
   ENDIF
   FOR i := 1 TO EventCount()
      IF ValType ( _HMG_EventData [i] ) <> "A"
         nIndex := i
         _HMG_EventData [ nIndex ] := { cProcName, hWnd, nMsg, lStopEvent, lProcessKeyboardMessage, lProcessMouseMessage, lProcessHMGWindowsMessage, lProcessAllHookMessage, nIndex }
         EXIT
      ENDIF
   NEXT
   IF nIndex == 0
      nIndex := EventCount() + 1
      AADD (_HMG_EventData, { cProcName, hWnd, nMsg, lStopEvent, lProcessKeyboardMessage, lProcessMouseMessage, lProcessHMGWindowsMessage, lProcessAllHookMessage, nIndex })
   ENDIF

   RETURN nIndex

FUNCTION EventRemove (nIndex)

   LOCAL i

   FOR i := 1 TO EventCount()
      IF ValType (_HMG_EventData [i]) == "A" .AND. _HMG_EventData [i] [ HMG_LEN(_HMG_EventData[1]) ] == nIndex   // July 2015
         _HMG_EventData [i] := NIL

         RETURN .T.
      ENDIF
   NEXT

   RETURN .F.

FUNCTION EventRemoveAll()

   IF HMG_LEN (_HMG_EventData) > 0
      _HMG_EventData := {}

      RETURN .T.
   ENDIF

   RETURN .F.

FUNCTION EventCount()

   RETURN HMG_LEN (_HMG_EventData)

FUNCTION EventProcess (hWnd, nMsg, wParam, lParam, IsKeyboardMessage, IsMouseMessage, IsHMGWindowsMessage, nHookID, nHookCode)

   LOCAL nIndex
   LOCAL cProcName, Ret := NIL
   LOCAL lProcessMessage

   FOR nIndex = 1 TO EventCount()

      IF ValType ( _HMG_EventData [ nIndex ] ) <> "A"   // avoids processing the events removed
         LOOP
      ENDIF

      lProcessMessage := .F.
      IF EventProcessAllHookMessage (nIndex) == .T.
         lProcessMessage := .T.
      ELSEIF EventProcessHMGWindowsMessage (nIndex) == .T. .AND. IsHMGWindowsMessage == .T.
         lProcessMessage := .T.
      ELSEIF EventProcessKeyboardMessage   (nIndex) == .T. .AND. IsKeyboardMessage   == .T.
         lProcessMessage := .T.
      ELSEIF EventProcessMouseMessage      (nIndex) == .T. .AND. IsMouseMessage      == .T.
         lProcessMessage := .T.
      ENDIF

      IF lProcessMessage == .T.                              .AND. ;
            EventSTOP (nIndex) <> .T.                           .AND. ;
            EventCompareParam (_HMG_EventData[nIndex][2], hWnd) .AND. ;
            EventCompareParam (_HMG_EventData[nIndex][3], nMsg)

         EventSTOP (nIndex, .T.)   // avoids re-entry
         _PushEventInfo()
         _HMG_EventIsInProgress        := .T.
         _HMG_EventIsKeyboardMessage   := IsKeyboardMessage
         _HMG_EventIsMouseMessage      := IsMouseMessage
         _HMG_EventIsHMGWindowsMessage := IsHMGWindowsMessage
         _HMG_EventHookID              := nHookID
         _HMG_EventHookCode            := nHookCode
         _HMG_EventINDEX               := nIndex
         _HMG_EventHWND                := hWnd
         _HMG_EventMSG                 := nMsg
         _HMG_EventWPARAM              := wParam
         _HMG_EventLPARAM              := lParam
         _HMG_EventPROCNAME := EventGetPROCNAME (nIndex)

         IF ValType( _HMG_EventPROCNAME ) <> "C"
            Ret := EVAL( _HMG_EventPROCNAME )   // is codeblock
         ELSE
            cProcName := _HMG_EventPROCNAME
            IF HB_URIGHT(cProcName, 1) <> ")"
               Ret := &cProcName()
            ELSE
               Ret := &cProcName
            ENDIF
         ENDIF

         _HMG_EventIsInProgress        := .F.
         _HMG_EventIsKeyboardMessage   := .F.
         _HMG_EventIsMouseMessage      := .F.
         _HMG_EventIsHMGWindowsMessage := .F.
         _HMG_EventHookID              := -1
         _HMG_EventHookCode            := -1
         _HMG_EventINDEX               := 0
         _HMG_EventHWND                := 0
         _HMG_EventMSG                 := 0
         _HMG_EventWPARAM              := 0
         _HMG_EventLPARAM              := 0
         _HMG_EventPROCNAME            := ""
         _PopEventInfo()
         EventSTOP (nIndex, .F.)   // restore entry
         IF ValType (Ret) == "N"

            RETURN Ret
         ENDIF
      ENDIF
   NEXT

   RETURN Ret

FUNCTION EventIsInProgress()

   RETURN _HMG_EventIsInProgress

FUNCTION EventIsKeyboardMessage ()

   RETURN _HMG_EventIsKeyboardMessage

FUNCTION EventIsMouseMessage ()

   RETURN _HMG_EventIsMouseMessage

FUNCTION EventIsHMGWindowsMessage ()

   RETURN _HMG_EventIsHMGWindowsMessage

FUNCTION EventHookID ()

   RETURN _HMG_EventHookID

FUNCTION EventHookCode ()

   RETURN _HMG_EventHookCode

FUNCTION EventINDEX ()

   RETURN _HMG_EventINDEX

FUNCTION EventPROCNAME ()

   RETURN _HMG_EventPROCNAME

FUNCTION EventHWND ()

   RETURN _HMG_EventHWND

FUNCTION EventMSG ()

   RETURN _HMG_EventMSG

FUNCTION EventWPARAM ()

   RETURN _HMG_EventWPARAM

FUNCTION EventLPARAM ()

   RETURN _HMG_EventLPARAM

FUNCTION EventGetPROCNAME (nIndex)

   RETURN _HMG_EventData [nIndex] [1]

FUNCTION EventGetHWND (nIndex)

   RETURN _HMG_EventData [nIndex] [2]

FUNCTION EventGetMSG (nIndex)

   RETURN _HMG_EventData [nIndex] [3]

FUNCTION EventSTOP (nIndex, lStop)

   LOCAL lRet := _HMG_EventData [nIndex] [4]

   IF ValType (lStop) == "L"
      _HMG_EventData [nIndex] [4] := lStop
   ENDIF

   RETURN lRet

FUNCTION EventProcessKeyboardMessage (nIndex, lProcess)

   LOCAL lRet := _HMG_EventData [nIndex] [5]

   IF ValType (lProcess) == "L"
      _HMG_EventData [nIndex] [5] := lProcess
   ENDIF

   RETURN lRet

FUNCTION EventProcessMouseMessage (nIndex, lProcess)

   LOCAL lRet := _HMG_EventData [nIndex] [6]

   IF ValType (lProcess) == "L"
      _HMG_EventData [nIndex] [6] := lProcess
   ENDIF

   RETURN lRet

FUNCTION EventProcessHMGWindowsMessage (nIndex, lProcess)

   LOCAL lRet := _HMG_EventData [nIndex] [7]

   IF ValType (lProcess) == "L"
      _HMG_EventData [nIndex] [7] := lProcess
   ENDIF

   RETURN lRet

FUNCTION EventProcessAllHookMessage (nIndex, lProcess)

   LOCAL lRet := _HMG_EventData [nIndex] [8]

   IF ValType (lProcess) == "L"
      _HMG_EventData [nIndex] [8] := lProcess
   ENDIF

   RETURN lRet

   //*****************************************************************************************************************//
   //*   Events Complementary Functions                                                                              *//
   //*****************************************************************************************************************//

   * GetLastFormIndexWithCursor ()  --> Return nIndex

   * GetLastActiveFormIndex ()      --> Return nIndex
   * GetLastActiveControlIndex ()   --> Return nIndex

   * ListCalledFunctions ( [ nActivation ], [ @aInfo ] ) --> Return cInfo

   * GetFormHandleByIndex    (nIndex) --> Return hWnd
   * GetControlHandleByIndex (nIndex) --> Return hWnd

   * GetFormNameByIndex    ( nFormIndex )    --> Return cName
   * GetControlNameByIndex ( nControlIndex ) --> Return cName

   * GetFormNameByHandle    (hWnd, @cFormName,    @cFormParentName) --> Return nFormIndex
   * GetControlNameByHandle (hWnd, @cControlName, @cFormParentName) --> Return nControlIndex

   * GetFormIndexByHandle    ( hWnd, [ @nFormSubIndex1 ],    [ @nFormSubIndex2 ]    ) --> Return nIndex
   * GetControlIndexByHandle ( hWnd, [ @nControlSubIndex1 ], [ @nControlSubIndex2 ] ) --> Return nIndex

   * GetFormParentHandleByIndex    ( nIndex ) --> Return hWnd
   * GetControlParentHandleByIndex ( nIndex ) --> Return hWnd

   // GetFormParentNameByIndex    ( nFormIndex )    --> Return cName
   // GetControlParentNameByIndex ( nControlIndex ) --> Return cName

   * GetFormTypeByIndex    ( nIndex ) --> Return cType
   * GetControlTypeByIndex ( nIndex ) --> Return cType

   * GetWindowInfoByHandle   (hWnd, [ @aInfo ], [ lShowType ] ) --> Return cInfo = "FormName1(FormType1).FormNameN(FormTypeN).ControlName(ControlType)"
   * GetWindowInfoByHandleEx (hWnd, [ @aInfo ], [ lShowType ] ) --> Return cInfo = "FormName1(FormType1).FormNameN(FormTypeN).ControlName(ControlType)"

   * GetFormInfoByHandle    (hWnd, [ aInfo ], [ lShowType ] ) --> Return cInfo = "FormName1(FormType1).FormNameN(FormTypeN)"
   * GetControlInfoByHandle (hWnd, [ aInfo ], [ lShowType ] ) --> Return cInfo = "FormName1(FormType1).FormNameN(FormTypeN).ControlName(ControlType)"

   * HMG_CompareHandle ( Handle1, Handle2, [ @nSubIndex1 ], [ @nSubIndex2 ] ) --> Return .T. or .F.

   * GetFormDataByIndex    (nIndex) --> Return aFormData
   * GetControlDataByIndex (nIndex) --> Return aControlData

   * IsFormDeletedByIndex    (nIndex) --> Return .T. or .F.
   * IsControlDeletedByIndex (nIndex) --> Return .T. or .F.

   * GetMainFormName   () --> Return cName
   * GetMainFormHandle () --> Return hWnd

FUNCTION GetLastFormIndexWithCursor ()

   RETURN _HMG_LastFormIndexWithCursor

FUNCTION GetLastActiveFormIndex ()

   RETURN _HMG_LastActiveFormIndex

FUNCTION GetLastActiveControlIndex ()

   RETURN _HMG_LastActiveControlIndex

FUNCTION ListCalledFunctions (nActivation, aInfo)

   LOCAL cMsg := "", i:= 1
   LOCAL nProcLine, cProcFile, cProcName

   aInfo := {}
   nActivation := IF (ValType(nActivation) <> "N", 1, nActivation)
   DO WHILE .NOT.(PROCNAME(nActivation) == "")
      cProcName := PROCNAME(nActivation)
      nProcLine := PROCLINE(nActivation)
      cProcFile := PROCFILE(nActivation)
      AADD (aInfo, {cProcName, nProcLine, cProcFile})
      cMsg := cMsg + aInfo[i,1] + "(" + HB_NTOS(aInfo[i,2]) + ") ("+ aInfo[i,3] + ")" + HB_OSNEWLINE()
      nActivation++
      i++
   ENDDO

   RETURN cMsg

FUNCTION GetFormHandleByIndex (nIndex)

   LOCAL hWnd := _HMG_SYSDATA [67] [nIndex]   // aFormHandle

   RETURN hWnd

FUNCTION GetControlHandleByIndex (nIndex)

   LOCAL hWnd := _HMG_SYSDATA [3] [nIndex]   // aControlHandle

   RETURN hWnd

FUNCTION GetFormNameByIndex (nIndex)

   LOCAL cName := _HMG_SYSDATA [66] [nIndex]   // aFormName

   RETURN cName

FUNCTION GetControlNameByIndex (nIndex)

   LOCAL cName := _HMG_SYSDATA [2] [nIndex]   // aControlName

   RETURN cName

FUNCTION GetFormIndexByHandle (hWnd, nFormSubIndex1, nFormSubIndex2)

   LOCAL i, FormHandle, nIndex := 0

   FOR i = 1 TO HMG_LEN (_HMG_SYSDATA [67])   // aFormHandle
      FormHandle :=  _HMG_SYSDATA [67] [i]
      IF HMG_CompareHandle (hWnd, FormHandle, @nFormSubIndex1, @nFormSubIndex2) == .T.
         nIndex := i
         EXIT
      ENDIF
   NEXT

   RETURN nIndex

FUNCTION GetControlIndexByHandle (hWnd, nControlSubIndex1, nControlSubIndex2)

   LOCAL i, ControlHandle, nIndex := 0

   FOR i = 1 TO HMG_LEN (_HMG_SYSDATA [3])   // aControlHandle
      ControlHandle :=  _HMG_SYSDATA [3] [i]
      IF HMG_CompareHandle (hWnd, ControlHandle, @nControlSubIndex1, @nControlSubIndex2) == .T.
         nIndex := i
         EXIT
      ENDIF
   NEXT

   RETURN nIndex

FUNCTION GetFormParentHandleByIndex (nIndex)

   LOCAL hWnd := _HMG_SYSDATA [70] [nIndex]   // aFormParentHandle

   RETURN hWnd

FUNCTION GetControlParentHandleByIndex (nIndex)

   LOCAL hWnd := _HMG_SYSDATA [4] [nIndex]   // aControlParentHandle

   RETURN hWnd

FUNCTION GetFormTypeByIndex (nIndex)

   LOCAL cType := _HMG_SYSDATA [69] [nIndex]   // aFormType

   RETURN cType

FUNCTION GetFormTypeByIndexEx (nIndex)

   LOCAL aType1 := { 'A',    'C',     'P',     'S',        'M',     'X'         }
   LOCAL aType2 := { "MAIN", "CHILD", "PANEL", "STANDARD", "MODAL", "SPLITCHILD" }
   LOCAL i := ASCAN (aType1, _HMG_SYSDATA [69] [nIndex])   // aFormType

   RETURN IIF ( i > 0, aType2 [i] , "<Unknown>" )

FUNCTION GetControlTypeByIndex (nIndex)

   LOCAL cType := _HMG_SYSDATA [1] [nIndex]   // aControlType

   RETURN cType

FUNCTION GetWindowInfoByHandle (hWnd, aInfo, lShowType)

   LOCAL i, ControlParentHandle:=0, FormParentHandle:=0, cInfo := "", lFlagControl := .F.
   LOCAL nIndexForm := 0, nIndexControl := 0, nInfoLen := 0, Text := "", nControlSubIndex2 := 0

   IF ValType (lShowType) <> "L"
      lShowType := .T.
   ENDIF

   aInfo := {}
   nIndexControl := GetControlIndexByHandle (hWnd, NIL, @nControlSubIndex2)
   WHILE nIndexControl > 0
      IF nIndexControl > 0
         lFlagControl := .T.
         TEXT := ALLTRIM(GetControlNameByIndex(nIndexControl)) + IF (lShowType, "("+ ALLTRIM(GetControlTypeByIndex (nIndexControl)) +")", "")
         AADD (aInfo, Text)
         ControlParentHandle := GetControlParentHandleByIndex (nIndexControl)
         IF ControlParentHandle <> 0
            nIndexControl := GetControlIndexByHandle (ControlParentHandle)
         ELSE
            nIndexControl := 0
         ENDIF
      ENDIF
   ENDDO

   IF lFlagControl == .T.
      IF ControlParentHandle <> 0
         nIndexForm := GetFormIndexByHandle (ControlParentHandle)
      ELSE
         nIndexForm := 0
      ENDIF
   ELSE
      nIndexForm := GetFormIndexByHandle (hWnd)
   ENDIF

   WHILE nIndexForm > 0
      IF nIndexForm > 0
         TEXT := ALLTRIM(GetFormNameByIndex(nIndexForm)) + IF (lShowType, "("+ ALLTRIM(GetFormTypeByIndexEx (nIndexForm)) +")", "")
         AADD (aInfo, Text)
         FormParentHandle := GetFormParentHandleByIndex (nIndexForm)
         IF FormParentHandle <> 0
            nIndexForm := GetFormIndexByHandle (FormParentHandle)
         ELSE
            nIndexForm := 0
         ENDIF
      ENDIF
   ENDDO

   nInfoLen := HMG_LEN(aInfo)
   FOR i = nInfoLen TO 1 STEP -1
      cInfo := cInfo + IF(i == nInfoLen,"",".") + aInfo [i]
   NEXT

   RETURN cInfo

FUNCTION GetWindowInfoByHandleEx (hWnd, aInfo, lShowType)

   LOCAL i, ControlParentHandle:=0, FormParentHandle:=0, cInfo := "", lFlagControl := .F.
   LOCAL nIndexForm := 0, nIndexControl := 0, nInfoLen := 0, Text := ""
   LOCAL nControlSubIndex1 := 0, nControlSubIndex2 := 0

   IF ValType (lShowType) <> "L"
      lShowType := .T.
   ENDIF

   aInfo := {}
   nIndexControl := GetControlIndexByHandle (hWnd, @nControlSubIndex1, @nControlSubIndex2)
   IF nIndexControl > 0 .AND. nControlSubIndex1 > 0
      hWnd := hWnd [nControlSubIndex1]
   ENDIF

   WHILE nIndexControl > 0
      IF nIndexControl > 0
         lFlagControl := .T.
         TEXT := ALLTRIM(GetControlNameByIndex(nIndexControl)) + IF (lShowType, "("+ ALLTRIM(GetControlTypeByIndex (nIndexControl)) +")", "")
         AADD (aInfo, Text)
         ControlParentHandle := GetParent (hWnd)
         IF ControlParentHandle <> 0
            nIndexControl := GetControlIndexByHandle (ControlParentHandle)
            hWnd := ControlParentHandle
         ELSE
            nIndexControl := 0
         ENDIF
      ENDIF
   ENDDO

   IF lFlagControl == .T.
      IF ControlParentHandle <> 0
         nIndexForm := GetFormIndexByHandle (ControlParentHandle)
         hWnd := ControlParentHandle
      ELSE
         nIndexForm := 0
      ENDIF
   ELSE
      nIndexForm := GetFormIndexByHandle (hWnd)
   ENDIF

   WHILE nIndexForm > 0
      IF nIndexForm > 0
         TEXT := ALLTRIM(GetFormNameByIndex(nIndexForm)) + IF (lShowType, "("+ ALLTRIM(GetFormTypeByIndexEx (nIndexForm)) +")", "")
         AADD (aInfo, Text)
         FormParentHandle := GetParent (hWnd)
         IF FormParentHandle <> 0
            nIndexForm := GetFormIndexByHandle (FormParentHandle)
            hWnd := FormParentHandle
         ELSE
            nIndexForm := 0
         ENDIF
      ENDIF
   ENDDO

   nInfoLen := HMG_LEN(aInfo)
   FOR i = nInfoLen TO 1 STEP -1
      cInfo := cInfo + IF(i == nInfoLen,"",".") + aInfo [i]
   NEXT

   RETURN cInfo

FUNCTION HMG_CompareHandle (Handle1, Handle2, nSubIndex1, nSubIndex2)

   LOCAL i,k

   nSubIndex1 := nSubIndex2 := 0

   IF ValType (Handle1) == "N" .AND. ValType (Handle2) == "N"
      IF Handle1 == Handle2

         RETURN .T.
      ENDIF

   ELSEIF ValType (Handle1) == "A" .AND. ValType (Handle2) == "N"
      FOR i = 1 TO HMG_LEN (Handle1)
         IF Handle1 [i] == Handle2
            nSubIndex1 := i

            RETURN .T.
         ENDIF
      NEXT

   ELSEIF ValType (Handle1) == "N" .AND. ValType (Handle2) == "A"
      FOR k = 1 TO HMG_LEN (Handle2)
         IF Handle1 == Handle2 [k]
            nSubIndex2 := k

            RETURN .T.
         ENDIF
      NEXT

   ELSEIF ValType (Handle1) == "A" .AND. ValType (Handle2) == "A"
      FOR i = 1 TO HMG_LEN (Handle1)
         FOR k = 1 TO HMG_LEN (Handle2)
            IF Handle1 [i] == Handle2 [k]
               nSubIndex1 := i
               nSubIndex2 := k

               RETURN .T.
            ENDIF
         NEXT
      NEXT
   ENDIF

   RETURN .F.

FUNCTION GetFormInfoByHandle (hWnd, aInfo, lShowType)

   LOCAL i, FormParentHandle:=0, cInfo := ""
   LOCAL nIndexForm := 0, nInfoLen := 0, Text := ""

   IF ValType (lShowType) <> "L"
      lShowType := .T.
   ENDIF

   aInfo := {}
   nIndexForm := GetFormIndexByHandle (hWnd)
   WHILE nIndexForm > 0
      IF nIndexForm > 0
         TEXT := ALLTRIM(GetFormNameByIndex(nIndexForm)) + IF( lShowType, "("+ ALLTRIM(GetFormTypeByIndex (nIndexForm)) +")", "")
         AADD (aInfo, Text)
         FormParentHandle := GetFormParentHandleByIndex (nIndexForm)
         IF FormParentHandle <> 0
            nIndexForm := GetFormIndexByHandle (FormParentHandle)
         ELSE
            nIndexForm := 0
         ENDIF
      ENDIF
   ENDDO

   nInfoLen := HMG_LEN(aInfo)
   FOR i = nInfoLen TO 1 STEP -1
      cInfo := cInfo + IF(i == nInfoLen,"",".") + aInfo [i]
   NEXT

   RETURN cInfo

FUNCTION GetControlInfoByHandle (hWnd, aInfo, lShowType)

   LOCAL i, ControlParentHandle:=0, FormParentHandle:=0, cInfo := "", lFlagControl := .F.
   LOCAL nIndexForm := 0, nIndexControl := 0, nInfoLen := 0, Text := "", nControlSubIndex2 := 0

   IF ValType (lShowType) <> "L"
      lShowType := .T.
   ENDIF

   aInfo := {}
   nIndexControl := GetControlIndexByHandle (hWnd, NIL, @nControlSubIndex2)
   WHILE nIndexControl > 0
      IF nIndexControl > 0
         lFlagControl := .T.
         TEXT := ALLTRIM(GetControlNameByIndex(nIndexControl)) + IF( lShowType, "("+ ALLTRIM(GetControlTypeByIndex (nIndexControl)) +")", "")
         AADD (aInfo, Text)
         ControlParentHandle := GetControlParentHandleByIndex (nIndexControl)
         IF ControlParentHandle <> 0
            nIndexControl := GetControlIndexByHandle (ControlParentHandle)
         ELSE
            nIndexControl := 0
         ENDIF
      ENDIF
   ENDDO

   IF lFlagControl == .T.
      IF ControlParentHandle <> 0
         nIndexForm := GetFormIndexByHandle (ControlParentHandle)
      ELSE
         nIndexForm := 0
      ENDIF

      WHILE nIndexForm > 0
         IF nIndexForm > 0
            TEXT := ALLTRIM(GetFormNameByIndex(nIndexForm)) + IF( lShowType, "("+ ALLTRIM(GetFormTypeByIndex (nIndexForm)) +")", "")
            AADD (aInfo, Text)
            FormParentHandle := GetFormParentHandleByIndex (nIndexForm)
            IF FormParentHandle <> 0
               nIndexForm := GetFormIndexByHandle (FormParentHandle)
            ELSE
               nIndexForm := 0
            ENDIF
         ENDIF
      ENDDO
   ENDIF

   nInfoLen := HMG_LEN(aInfo)
   FOR i = nInfoLen TO 1 STEP -1
      cInfo := cInfo + IF(i == nInfoLen,"",".") + aInfo [i]
   NEXT

   RETURN cInfo

FUNCTION GetFormDataByIndex (nIndex)

   LOCAL i, aFormData := {}

   FOR i := 65 TO 108
      AADD (aFormData, _HMG_SYSDATA [i] [nIndex])
   NEXT

   RETURN aFormData

FUNCTION GetControlDataByIndex (nIndex)

   LOCAL i, aControlData := {}

   FOR i := 1 TO 40
      AADD (aControlData, _HMG_SYSDATA [i] [nIndex])
   NEXT

   RETURN aControlData

FUNCTION IsFormDeletedByIndex (nIndex)

   RETURN _HMG_SYSDATA [65] [nIndex]   // _HMG_aFormDeleted

FUNCTION IsControlDeletedByIndex (nIndex)

   RETURN _HMG_SYSDATA [13] [nIndex]   // _HMG_aControlDeleted

FUNCTION GetMainFormName ()

   RETURN GetFormNameByIndex (_HMG_MainFormIndex)

FUNCTION GetMainFormHandle ()

   RETURN GetFormHandleByIndex (_HMG_MainFormIndex)

FUNCTION GetFormNameByHandle (hWnd, cFormName, cFormParentName)

   LOCAL nIndexFormParent, FormParentHandle
   LOCAL nIndexForm := GetFormIndexByHandle (hWnd)

   cFormName := cFormParentName := ""
   IF nIndexForm > 0
      cFormName := GetFormNameByIndex (nIndexForm)
      FormParentHandle := GetFormParentHandleByIndex (nIndexForm)
      IF FormParentHandle <> 0
         nIndexFormParent := GetFormIndexByHandle (FormParentHandle)
         cFormParentName  := GetFormNameByIndex (nIndexFormParent)
      ENDIF
   ENDIF

   RETURN nIndexForm

FUNCTION GetControlNameByHandle (hWnd, cControlName, cFormParentName)

   LOCAL nIndexControlParent, ControlParentHandle
   LOCAL nIndexControl := GetControlIndexByHandle (hWnd)

   cControlName := cFormParentName := ""
   IF nIndexControl > 0
      cControlName := GetControlNameByIndex (nIndexControl)
      ControlParentHandle := GetControlParentHandleByIndex (nIndexControl)
      IF ControlParentHandle <> 0
         nIndexControlParent := GetFormIndexByHandle (ControlParentHandle)
         cFormParentName     := GetFormNameByIndex (nIndexControlParent)
      ENDIF
   ENDIF

   RETURN nIndexControl

   /*
   #xtranslate CHECK TYPE [ <lSoft: SOFT> ] <var> AS <type> [, <varN> AS <typeN> ] => ;
   HMG_CheckType( <.lSoft.>, { <"type"> , ValType( <var> ), <"var"> } [, { <"typeN"> , ValType( <varN> ), <"varN"> } ] )
   */

PROCEDURE HMG_CheckType( lSoft, ... )

   LOCAL i, j
   LOCAL aParams, aData
   LOCAL aType := { ;
      { "ARRAY"      , "A" } , ;
      { "BLOCK"      , "B" } , ;
      { "CHARACTER"  , "C" } , ;
      { "DATE"       , "D" } , ;
      { "HASH"       , "H" } , ;
      { "LOGICAL"    , "L" } , ;
      { "NIL"        , "U" } , ;
      { "NUMERIC"    , "N" } , ;
      { "MEMO"       , "M" } , ;
      { "POINTER"    , "P" } , ;
      { "SYMBOL"     , "S" } , ;
      { "TIMESTAMP"  , "T" } , ;
      { "OBJECT"     , "O" } , ;
      { "USUAL"      , ""  }}

   aParams := hb_aParams()

   hb_ADEL( aParams, 1, .T. )   // Remove lSoft param of the array

   FOR EACH aData IN aParams

      IF HMG_UPPER( AllTrim( aData[ 1 ] ) ) <> "USUAL"

         IF .NOT. ( lSoft == .T. .AND. HMG_UPPER( AllTrim( aData[ 2 ] ) ) == "U" )

            // aData := { cTypeDef, cValType, cVarName }
            // aType := { cTypeDef, cValType }

            i := ASCAN( aType, { | x | HMG_UPPER( AllTrim( x[ 1 ] ) ) == HMG_UPPER( AllTrim( aData[ 1 ] ) ) } )

            IF i == 0 .OR. HMG_UPPER( AllTrim( aType[ i ][ 2 ] ) ) <> HMG_UPPER( AllTrim( aData[ 2 ] ) )

               j := ASCAN( aType, { | x | HMG_UPPER( AllTrim( x[ 2 ] ) ) == HMG_UPPER( AllTrim( aData[ 2 ] ) ) } )

               MsgHMGError( "CHECK TYPE ( Param # "+ hb_NtoS( aData:__enumindex() ) + " ) : " + AllTrim( aData[ 3 ] ) + " is declared as " + HMG_UPPER( AllTrim( aData[ 1 ] ) ) + " but it is of type " + HMG_UPPER( AllTrim( aType[ j ][ 1 ] ) ) + ". Program terminated", "HMG Error" )

            ENDIF

         ENDIF

      ENDIF

   NEXT

   RETURN

FUNCTION HMG_GetAllSubMenu (hMenu)

   LOCAL aMenuInfo:={}, hSubMenu
   LOCAL nParent:=0, n1:=0, n2:=0, nItem:=0

   // nParent := parent position in array
   IF IsMenu (hMenu)
      WHILE .T.
         FOR nItem = 0 TO GetMenuItemCount (hMenu) - 1
            hSubMenu := GetSubMenu (hMenu, nItem)
            IF IsMenu (hSubMenu)
               AADD (aMenuInfo, {hSubMenu, nParent, nItem})
               n1 ++
            ENDIF
         NEXT
         n2 ++
         nParent++
         IF n2 > n1
            EXIT
         ELSE
            hMenu := aMenuInfo [n2] [1]
         ENDIF
      ENDDO
   ENDIF

   RETURN aMenuInfo

FUNCTION HMG_GetSubMenuItemFromPoint (hWnd, aMenuInfo, x_scr, y_scr, aInfo)

   LOCAL nPos, i, cText:="", hMenu, nIndex, nParent

   // nParent := parent position in array
   aInfo := {}
   FOR i = 1 TO HMG_LEN (aMenuInfo)
      hMenu := aMenuInfo [i] [1]
      nPos := MenuItemFromPoint (hWnd, hMenu, x_scr, y_scr)
      IF nPos >= 0
         cText   := HB_NTOS (nPos+1)
         AADD (aInfo, nPos+1)
         nParent := aMenuInfo [i] [2]
         IF nParent == 0
            cText := HB_NTOS (aMenuInfo [i] [3] + 1) + ":" + cText
            AADD (aInfo, (aMenuInfo [i] [3] + 1))

            RETURN cText
         ENDIF

         nIndex  := i
         WHILE nParent > 0
            cText := HB_NTOS (aMenuInfo [nIndex] [3] + 1) + ":" + cText
            AADD (aInfo, (aMenuInfo [nIndex] [3] + 1))
            nIndex  := nParent
            nParent := aMenuInfo [nIndex] [2]
         ENDDO
         IF nParent == 0
            cText := HB_NTOS (aMenuInfo [nIndex] [3] + 1) + ":" + cText
            AADD (aInfo, (aMenuInfo [nIndex] [3] + 1))

            RETURN cText
         ENDIF

         EXIT
      ENDIF
   NEXT

   RETURN cText

FUNCTION GetSplitChildWindowHandle (cFormName, cParentForm)

   LOCAL i, hWnd := GetFormHandle (cParentForm)

   FOR i = 1 TO HMG_LEN (_HMG_SYSDATA [ 66 ])
      IF (_HMG_SYSDATA [ 66 ] [i] == cFormName) .AND. (_HMG_SYSDATA [ 69 ] [i] ==  'X') .AND. (_HMG_SYSDATA [ 70 ]  [i] == hWnd)

         RETURN _HMG_SYSDATA [ 67] [i]
      ENDIF
   NEXT

   RETURN 0

FUNCTION GetSplitBoxHandle (cParentForm)

   LOCAL i := GetFormIndex (cParentForm)

   IF i > 0 .AND. _HMG_SYSDATA [87] [i] <> 0

      RETURN _HMG_SYSDATA [ 87 ] [i]
   ENDIF

   RETURN 0

FUNCTION GetSplitBoxRect (cParentForm)

   LOCAL hWnd, aPos := {0,0,0,0}

   hWnd := GetSplitBoxHandle (cParentForm)
   GetWindowRect (hWnd, aPos)

   RETURN aPos   // return array --> { Left, Top, Right, Bottom }

FUNCTION GetSplitBoxWIDTH (cParentForm)

   LOCAL hWnd, aPos := {0,0,0,0}

   hWnd := GetSplitBoxHandle (cParentForm)
   GetWindowRect (hWnd, aPos)

   RETURN (aPos[3] - aPos[1])

FUNCTION GetSplitBoxHEIGHT (cParentForm)

   LOCAL hWnd, aPos := {0,0,0,0}

   hWnd := GetSplitBoxHandle (cParentForm)
   GetWindowRect (hWnd, aPos)

   RETURN (aPos[4] - aPos[2])
