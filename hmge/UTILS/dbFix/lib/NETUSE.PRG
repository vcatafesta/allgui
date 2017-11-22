/*---------------------------------------------------------------- NETUSE.PRG

Network aware file opening & locking routines

*/
#include "error.ch"
#include "filepart.ch"
#include "winmisc.ch"

#ifdef DOS_ONLY
#include "default.ch"
#include "inkey.ch"
#define CRLF  chr(13)+chr(10)
#else
#include "fivewin.ch"
#endif

STATIC cFATitle := "File Access"

//-------------------------------------------------------------------- NetUse

FUNCTION NetUse(cFile, lExclusive, cIndex, lAuto)

   /*
   An error-tolerant use function that returns a logical pass/fail result.
   Adapted from the old Grumpfish Net_Use() function.

   New: Putting the text "Immediate" (case does not matter) somewhere in the
   cFile parameter will cause the function to return immediately without
   notifying the user should the file not be available as requested.

   Added a new parameter 3/25/99: lAuto.  This value will temporarily change
   the cmxAutoOpen() setting while opening the requested database.

   See also: SetTryOut()
   */
   LOCAL lSuccess := .F.
   LOCAL cDriver, cAlias, lReadOnly := .F.
   LOCAL lBomb := .F., lRetry := .F., lWait := .T.
   LOCAL bPrevErr, oUseErr
   LOCAL cTemp, n

   // Fix up the incoming parameters...
   DEFAULT lExclusive := .F.
   cFile := upper(cFile)

   // Is ALIAS part of cFile?
   IF ( n := at(" ALIAS ", cFile) ) > 0
      cAlias := alltrim(substr(cFile, n + 7))
      IF ( n := at(" ", cAlias) ) > 0
         cAlias := substr(cAlias, 1, n - 1)
      ENDIF
      cFile := ReplaceStr(cFile, " ALIAS " + cAlias, "")
   ENDIF

   // Is VIA part of cFile?
   IF ( n := at(" VIA ", cFile) ) > 0
      cDriver := alltrim(substr(cFile, n + 5))
      IF ( n := at(" ", cDriver) ) > 0
         cDriver := substr(cDriver, 1, n - 1)
      ENDIF
      cFile := ReplaceStr(cFile, " VIA " + cDriver, "")
   ENDIF

   // Is IMMEDIATE part of cFile?
   IF ( n := at(" IMMEDIATE", cFile) ) > 0
      lWait := .F.
      cFile := ReplaceStr(cFile, " IMMEDIATE", "")
   ENDIF

   // Is READONLY part of cFile?
   IF ( n := at(" READONLY", cFile) ) > 0
      lReadonly := .T.
      cFile := left(cFile, n - 1) // Last one so remove everything...
   ENDIF

   cFile := alltrim(cFile)

   // See if the requested alias is already in use:
   cTemp := iif(empty(cAlias), FileParts(cFile, FP_NAMEONLY), cAlias)
   DO WHILE select(cTemp) > 0
      IF !MsgRetryCancel('The alias "' + cTemp + '" is already in use.', cFATitle)

         Return(lSuccess)
      ENDIF
      SysRefresh()
   ENDDO

   // Turn off cmxAutoOpen if requested:
   IF valtype(lAuto) == "L"
      lAuto := sx_AutoOpen(lAuto)
   ENDIF

   // Post custom error handler to take care of file handle problems, etc.
   bPrevErr := errorblock( {|e| NU_Error(e, bPrevErr, @lRetry) })

   // Try to open the database...
   lRetry := .T.
   DO WHILE !lBomb .and. lRetry
      lRetry := .F.
      BEGIN sequence
         dbUseArea(.T., cDriver, cFile, cAlias, !lExclusive, lReadonly)
         SysRefresh()
      RECOVER using oUseErr
         IF (oUseErr:genCode <> EG_OPEN .or. oUseErr:osCode <> 32) .and. !lRetry
            lBomb := .T.
         ENDIF
      END SEQUENCE
   ENDDO

   // If it didn't open (and didn't bomb), do the wait dialog...
   IF !lBomb
      IF neterr()
         IF lWait
            lSuccess := MsgWait({|oT, oD, lEnd| Try2Open(oUseErr, cFile, cDriver, cAlias, lExclusive, lReadonly, @lEnd) }, ;
               "Waiting for file to become available:" + CRLF + cFile, ;
               cFATitle)
         ENDIF
      ELSE
         lSuccess := .T.   // Otherwise set lSuccess to true!
      ENDIF
   ENDIF

   // If opened, open the index (if requested).  If that fails, close the DBF.
   IF lSuccess .and. !empty(cIndex)
      BEGIN sequence
         SET index to (cIndex)
      RECOVER
         lSuccess := .F.
         DBCloseArea()
      END SEQUENCE
   ENDIF

   // Replace the previous error handler:
   errorblock(bPrevErr)

   // Restore the previous auto-open setting:
   IF valtype(lAuto) == "L"
      sx_AutoOpen(lAuto)
   ENDIF

   Return(lSuccess)

STATIC FUNCTION Try2Open(oUseErr, cFile, cDriver, cAlias, lExclusive, lReadonly, lEnd)

   LOCAL lSuccess := .F.
   LOCAL nTries := 0, nTryOut := SetTryOut() * 2

   DO WHILE !lEnd .and. !lSuccess

      BEGIN sequence
         dbUseArea(.T., cDriver, cFile, cAlias, !lExclusive, lReadonly)
      RECOVER using oUseErr
         IF oUseErr:genCode <> EG_OPEN .or. oUseErr:osCode <> 32
            lEnd := .T.
            EXIT
         ENDIF
      END SEQUENCE

      SysRefresh()

      IF !neterr()
         MessageBeep(MB_ICONASTERISK)
         lSuccess := .T.
      ENDIF

      IF nTryOut > 0
         IF ++nTries >= nTryOut
            EXIT
         ENDIF
      ENDIF

      WaitASec()

      #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
      #endif

   ENDDO

   IF lEnd
      lSuccess := .F.
   ENDIF

   Return(lSuccess)

STATIC FUNCTION NU_Error(oUseErr, bPrevErr, lRetry)

   LOCAL cTitle := "File Error " + procname(4) + "(" + Nstr(procline(4)) + ")"

   LOCAL cMsg := "Cannot open " + oUseErr:filename + CRLF

   IF oUseErr:genCode == EG_OPEN

      IF oUseErr:osCode == 32 // A sharing violation?  Set neterr() & continue.
         neterr(.T.)
      ELSE
         DO CASE
         CASE oUseErr:osCode == 2
            cMsg += "File not found"
         CASE oUseErr:osCode == 3
            cMsg += "Path not found"
         CASE oUseErr:osCode == 4
            cMsg += "Out of file handles"
         CASE oUseErr:osCode == 5 .or. oUseErr:osCode == 65
            cMsg += "Access Denied"
         OTHERWISE
            cMsg += "OS Code #" + Nstr(oUseErr:osCode)
         ENDCASE
         lRetry := MsgRetryCancel(cMsg, cTitle)
      ENDIF
      break oUseErr

   ELSEIF oUseErr:genCode == EG_CORRUPTION

      MsgStop(cMsg + "Corruption detected", cTitle)
      // Don't break this error - if we do, the program dies anyway, but does
      // not generate an error.log!

   ENDIF

   RETURN eval(bPrevErr, oUseErr)

   //-------------------------------------------------------------------- AddRec

FUNCTION AddRec(nTryOut)

   /*
   Error-tolerant DBAppend() function that returns a logical pass/fail result.
   It tries to append a record until the user decides to cancel it.

   nTryOut is an optional parameter that will override the current setting of
   SetTryOut() if used.
   */
   LOCAL lAdded := .T.

   DBAppend()

   IF neterr()
      lAdded := MsgWait({|oT, oD, lEnd| Try2Add(nTryOut, @lEnd) }, ;
         "Waiting for record append:" + CRLF + ;
         "Work area '" + alias() + "'", ;
         cFATitle)
   ENDIF

   Return(lAdded)

STATIC FUNCTION Try2Add(nTryOut, lEnd)

   LOCAL lAdded := .F.
   LOCAL nTries := 0

   DEFAULT nTryOut := SetTryOut()

   nTryOut *= 2  // Two attempts per second

   DO WHILE !lEnd .and. !lAdded

      WaitASec()

      DBAppend()

      IF neterr()
         IF nTryOut > 0
            IF ++nTries >= nTryOut
               EXIT
            ENDIF
         ENDIF
      ELSE
         MessageBeep(MB_ICONASTERISK)
         lAdded := .T.
      ENDIF

      #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
      #endif

   ENDDO

   Return(lAdded)

   //------------------------------------------------------------------ FileLock

FUNCTION FileLock(nTryOut)

   /*
   An error-tolerant file locking function that returns a logical pass/fail
   result.  It tries to get a lock until the user decides to cancel it.

   nTryOut is an optional parameter that will override the current setting of
   SetTryOut() if used.
   */
   LOCAL lLocked := .F.

   IF !(lLocked := flock())
      lLocked := MsgWait({|oT, oD, lEnd| Try2Flock(nTryOut, @lEnd) }, ;
         "Waiting for file lock:" + CRLF + ;
         "Work area '" + alias() + "'", ;
         cFATitle)
   ENDIF

   Return(lLocked)

STATIC FUNCTION Try2Flock(nTryOut, lEnd)

   LOCAL lLocked := .F.
   LOCAL nTries := 0

   DEFAULT nTryOut := SetTryOut()

   nTryOut *= 2  // Two attempts per second

   DO WHILE !lEnd .and. !lLocked

      WaitASec()

      DBSkip(0) // Refresh the buffer in case someone else was in it!

      IF (lLocked := flock())
         MessageBeep(MB_ICONASTERISK)
      ELSEIF nTryOut > 0
         IF ++nTries >= nTryOut
            EXIT
         ENDIF
      ENDIF

      #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
      #endif

   ENDDO

   Return(lLocked)

   //------------------------------------------------------------------- RecLock

FUNCTION RecLock(nTryOut)

   /*
   Error tolerant record locking function that returns a logical pass/fail
   result.  It tries to get a lock until the user decides to cancel it.

   nTryOut is an optional parameter that will override the current setting of
   SetTryOut() if used.
   */
   LOCAL lLocked := .F.

   IF !(lLocked := rlock())
      lLocked := MsgWait({|oT, oD, lEnd| Try2Rlock(nTryOut, @lEnd) }, ;
         "Waiting for record lock:" + CRLF + "Record #" + ;
         Nstr(recno()) + " in work area '" + alias() + "'", ;
         cFATitle)
   ENDIF

   Return(lLocked)

STATIC FUNCTION Try2Rlock(nTryOut, lEnd)

   LOCAL lLocked := .F.
   LOCAL nTries := 0

   DEFAULT nTryOut := SetTryOut()

   nTryOut *= 2  // Two attempts per second

   DO WHILE !lEnd .and. !lLocked

      WaitASec()

      DBSkip(0) // Refresh the buffer in case someone else was in it!

      IF (lLocked := rlock())
         MessageBeep(MB_ICONASTERISK)
      ELSEIF nTryOut > 0
         IF ++nTries >= nTryOut
            EXIT
         ENDIF
      ENDIF

      #ifdef DOS_ONLY
      lEnd := (inkey() == K_ESC)
      #endif

   ENDDO

   Return(lLocked)

   //--------------------------------------------------------- Support Functions

FUNCTION SetTryOut(nNew)

   /*
   Set/get the default length of time in seconds to continue retrying a failed
   lock or open instruction in one of the following functions:

   NetUse(), RecLock(), FileLock() and AddRec()

   The default value is zero (0), meaning to retry indefinitely.

   Normally, this would be used before starting an automated process where the
   user wouldn't be there to respond to a "Waiting for..." dialog.  This
   allows the open/lock to be retried for a while but will give up & allow the
   rest of the process to continue instead of halting the entire job.
   */
   STATIC nTryOut := 0
   LOCAL nRet

   nRet := nTryOut

   IF valtype(nNew) == "N"   // New value given?
      nTryOut := nNew
   ENDIF

   Return(nRet)

STATIC FUNCTION WaitASec()

   LOCAL nStop := seconds() + .5
   LOCAL x := 0

   // This function does nothing but delay for one-half second.

   IF nStop >= 86398             // Don't get stuck at midnight!
      nStop := -1
   ENDIF

   DO WHILE seconds() < nStop
      IF x++ >= 50                // Don't SysRefresh() on every loop...
         x := 0
         SysRefresh()
      ENDIF
   ENDDO

   Return(NIL)

   //---------------------------------------------------------------------- Misc

FUNCTION NewAlias(cBase)

   /*
   Used to get a unique alias based on <cBase> (usually the filename).

   First, cBase is checked to see if it is a legal alias name.  If it contains
   any illegal characters, they are changed to underscores.  If it doesn't
   begin with a letter, one is prepended ("A" + cBase).

   If cBase is not already in use, it will be returned.  Otherwise, a number
   will be added to the end and incremented until an alias that is not in use
   is found.
   */
   LOCAL cAlias, cWork, x, nLen
   LOCAL cValid := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

   // Make sure cBase is a legal alias. Replace any illegal chars with "_":

   cWork := upper(alltrim(cBase))

   nLen := len(cWork)

   FOR x := 1 to nLen
      IF .not. substr(cWork, x, 1) $ cValid
         cWork := left(cWork, x - 1) + "_" + substr(cWork, x + 1)
      ENDIF
   NEXT

   // Add a leading alpha character if needed:

   IF !IsAlpha(cWork)
      cWork := "A" + cWork
   ENDIF

   // Make sure it's not in use:

   cAlias := cWork
   x := 0

   DO WHILE select(cAlias) > 0
      cAlias := cWork + Nstr(++x)
   ENDDO

   Return(cAlias)

FUNCTION SafeClose(cAlias)

   /*
   The function will close the workarea identified by <cAlias> if it is open
   and return a logical indicating whether it was open or not.
   */
   LOCAL lWasOpen := .F.

   IF !empty(cAlias)
      IF select(cAlias) > 0
         lWasOpen := .T.
         (cAlias)->( DBCloseArea() )
      ENDIF
   ENDIF

   Return(lWasOpen)

