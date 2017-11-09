/*

FREQUENT.PRG    These functions get used everywhere!

These functions are called so often (both by external programs and within
RayLib) that they deserve their own uncluttered OBJ!

*/
#include "default.ch"

#define CRLF  chr(13)+chr(10)

FUNCTION FWriteLn(h, cText)

   /*
   Writes a line of text to a file handle (h) followed by CRLF.
   */

   fwrite(h, cText + CRLF)

   RETURN(NIL)

FUNCTION InsDel(cOrig, nStart, nDelete, cInsert)

   /*
   InsDel() works exactly like Clipper's stuff() function, but for some
   reason stuff() seemed to be causing GPFs when used with FiveWin.
   */

   RETURN(left(cOrig, nStart - 1) + cInsert + substr(cOrig, nStart + nDelete))

FUNCTION Nstr(n, nLen, nDec)

   /*
   ltrim(str(n[, nLen, nDec]))
   */
   LOCAL c

   IF nLen == NIL
      c := str(n)
   ELSE
      DEFAULT nDec := 0
      c := str(n, nLen, nDec)
   ENDIF

   RETURN(ltrim(c))

FUNCTION ReplaceStr(cString, cOld, cNew)

   /*
   Equivalent to strtran(), without the nStart and nCount options.

   Replaces all occurrences of the cOld substring with cNew within the larger
   string cString.  Case matters.

   Example:  ReplaceStr("Peter Piper", "er", "ery")  -->  "Petery Pipery"

   (The function formerly known as Replace())
   */
   LOCAL o, n, x, i := 1
   LOCAL cWork := cString

   o := len(cOld)
   n := len(cNew)

   IF len(cWork) == 0 .or. o == 0 // Can't replace null strings!

      RETURN(cWork)
   ENDIF

   DO WHILE (x := at(cOld, substr(cWork, i))) > 0
      x += (i - 1)
      cWork := InsDel(cWork, x, o, cNew)
      // Move the index past the replacement string.  This avoids an endless
      // loop should cOld be a substring of cNew!
      i := x + n
   ENDDO

   RETURN(cWork)

FUNCTION IReplaceStr(cString, cOld, cNew)

   /*
   Like ReplaceStr(), but case-insensitive.
   */
   LOCAL o, n, x, i := 1
   LOCAL cWork := cString
   LOCAL cUpOld, cUpWork

   o := len(cOld)
   n := len(cNew)

   IF len(cWork) == 0 .or. o == 0 // Can't replace null strings!

      RETURN(cWork)
   ENDIF

   cUpOld := upper(cOld)
   cUpWork := upper(cWork)

   DO WHILE (x := at(cUpOld, substr(cUpWork, i))) > 0
      x += (i - 1)
      cWork := InsDel(cWork, x, o, cNew)
      // Move the index past the replacement string.  This avoids an endless
      // loop should cOld be a substring of cNew!
      i := x + n
      cUpWork := upper(cWork)
   ENDDO

   RETURN(cWork)

FUNCTION SetCentury(lToggle)

   /*
   Logical Set/Get function for the SET CENTURY setting.  It simply calls the

   function that SET CENTURY preprocesses to: __SetCentury(lToggle).

   */

   RETURN(__SetCentury(lToggle))

FUNCTION StoD(cDTOS)

   /*
   The functional inverse of dtos().
   */
   LOCAL dNew
   LOCAL cDF := set(_SET_DATEFORMAT, "YYYY/MM/DD")

   dNew := ctod(transform(cDTOS, "@R 9999/99/99"))

   set(_SET_DATEFORMAT, cDF)

   RETURN(dNew)

FUNCTION XCommit(lExclusive)

   /*
   Use in an aliased expression to issue the following oft-reapeated commands:

   DBCommit()
   DBUnlock()
   DBSkip(0)

   The DBUnlock() step will not be performed if lExclusive is true (defaults
   to false).
   */
   DEFAULT lExclusive := .F.

   DBCommit()

   IF !lExclusive
      DBUnlock()
   ENDIF

   DBSkip(0)

   RETURN(NIL)

   // Stubs for common FiveWin function calls:

   #ifdef DOS_ONLY

FUNCTION CursorArrow()

   RETURN(NIL)

FUNCTION CursorWait()

   RETURN(NIL)

FUNCTION cValToChar(u)

   RETURN(XtoC(u))

FUNCTION MessageBeep(nBeep)

   RETURN(tone(100, 3))

FUNCTION MsgAlert(cText, cCaption)

   RETURN(alert(cText))

FUNCTION MsgInfo(cText, cCaption)

   RETURN(alert(cText))

FUNCTION MsgMeter(bAction, cMsg, cTitle, lNoCancel, oParent)

   RETURN(eval(bAction))

FUNCTION MsgRetryCancel(cText, cCaption)

   RETURN(alert(cText, { "Retry", "Cancel" }) == 1)

FUNCTION MsgStop(cText, cCaption)

   RETURN(alert(cText))

FUNCTION MsgYesNo(cText, cCaption)

   RETURN(alert(cText, { "Yes", "No" }) == 1)

FUNCTION SysRefresh()

   RETURN(NIL)

   #endif

