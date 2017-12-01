/*

FILE_IO.PRG    Low-level file i/o functions

*/
#include "default.ch"
#include "error.ch"
#include "fileio.ch"

FUNCTION cFError(n)

   /*

   Returns the text description of a numeric ferror() code.
   */
   LOCAL cText

   DEFAULT n := ferror()

   DO CASE
   CASE n == 0
      cText := "No error"
   CASE n == 2
      cText := "File not found"
   CASE n == 3
      cText := "Path not found"
   CASE n == 4
      cText := "Too many files open"
   CASE n == 5
      cText := "Access denied"
   CASE n == 6
      cText := "Invalid handle"
   CASE n == 8
      cText := "Insufficient memory"
   CASE n == 15
      cText := "Invalid drive specified"
   CASE n == 19
      cText := "Attempted to write to a write-protected disk"
   CASE n == 21
      cText := "Drive not ready"
   CASE n == 23
      cText := "Data CRC error"
   CASE n == 29
      cText := "Write fault"
   CASE n == 30
      cText := "Read fault"
   CASE n == 32
      cText := "Sharing violation"
   CASE n == 33
      cText := "Lock violation"
   OTHERWISE
      cText := "Error #" + Nstr(n)
   ENDCASE

   Return(cText)

FUNCTION FCopy(cSource, cTarget, lMsgs)

   /*
   A low-level file copy function that returns a logical indicating success.
   If an error occurs, the function will attempt to erase the target file and
   will show an error message unless lMsgs is false (default is true).

   If the source file does not exist, the function will return false but will
   not show an error message.
   */
#define FC_CHUNK  8192

   LOCAL lOk := .T., cMsg := "", nErr := 0
   LOCAL hSource := F_ERROR, hTarget := F_ERROR
   LOCAL nBytes, cBuffer

   DEFAULT lMsgs := .T.

   IF !file(cSource)

      Return(.F.)
   ENDIF

   DO WHILE lOk

      IF (hSource := fopen(cSource, FO_READ + FO_DENYWRITE)) == F_ERROR
         lOk := .F.
         nErr := ferror()
         cMsg := " opening " + cSource
         EXIT
      ENDIF

      IF (hTarget := fcreate(cTarget, FC_NORMAL)) == F_ERROR
         lOk := .F.
         nErr := ferror()
         cMsg := " creating " + cTarget
         EXIT
      ENDIF

      nBytes  := FC_CHUNK
      cBuffer := space(FC_CHUNK)

      DO WHILE nBytes == FC_CHUNK .and. lOk
         nBytes := fread(hSource, @cBuffer, FC_CHUNK)
         IF nBytes > 0
            IF fwrite(hTarget, cBuffer, nBytes) <> nBytes
               lOk := .F.
               nErr := ferror()
               cMsg := " writing to " + cTarget
            ENDIF
         ELSEIF nBytes < 0
            lOk := .F.
            nErr := ferror()
            cMsg := " reading " + cSource
         ENDIF
      ENDDO

      EXIT

   ENDDO

   IF hTarget <> F_ERROR
      IF !fclose(hTarget) .and. lOk
         lOk := .F.
         nErr := ferror()
         cMsg := " closing " + cTarget
      ENDIF
   ENDIF

   IF hSource <> F_ERROR
      IF !fclose(hSource) .and. lOk
         lOk := .F.
         nErr := ferror()
         cMsg := " closing " + cSource
      ENDIF
   ENDIF

   IF !lOk
      ferase(cTarget)
      IF lMsgs
         MsgAlert("Error " + Nstr(nErr) + cMsg, ;
            procname(1) + "(" + Nstr(procline(1)) + ")")
      ENDIF
   ENDIF

   Return(lOk)

FUNCTION FileCopy(cSource, cTarget)

   /*
   Wraps an error trap around the standard "copy file" syntax.  Will display
   an error message and return false if an error occurs.

   Return value:  Logical indicating success.
   */
   LOCAL lOk := .F.
   LOCAL oErr, bErr := errorblock({|oErr| break(oErr) })

   BEGIN sequence

      COPY file (cSource) to (cTarget)
      lOk := .T.

   RECOVER using oErr

      IF oErr:genCode == EG_CREATE .or. oErr:genCode == EG_OPEN .or. ;
            oErr:genCode == EG_CLOSE  .or. oErr:genCode == EG_READ .or. ;
            oErr:genCode == EG_WRITE
         MsgAlert(cValToChar(oErr:description) + " " + ;
            Nstr(oErr:osCode) + ": " + ;
            cValToChar(oErr:filename), "Copy Error")
      ELSE
         eval(bErr, oErr) // Unexpected - give it to the default error handler
      ENDIF

   END SEQUENCE

   errorblock(bErr)

   IF !lOk
      ferase(cTarget)
   ENDIF

   Return(lOk)

FUNCTION RenFile(cOld, cNew)

   /*
   Error-checking, destructive file rename function - use it instead of
   frename().  If cNew exists, it will be deleted before renaming cOld,
   instead of just failing like frename() would - make sure you don't want it!

   Returns a logical indicating success.  If an error occurs during the
   rename, a MsgRetryCancel() showing the ferror() number & the calling
   procname() and procline() will be shown.

   If cOld does not exist, the function will return false but will not show an
   error message (but you should check that first anyway!).
   */
   LOCAL lOk := .F.

   IF file(cOld)
      DO WHILE !lOk
         IF file(cNew)
            ferase((cNew))
            SysRefresh()
         ENDIF
         IF frename(cOld, cNew) == F_ERROR
            IF !MsgRetryCancel("Error " + Nstr(ferror()) + " renaming " + ;
                  cOld + " to " + cNew, ;
                  procname(1) + "(" + Nstr(procline(1)) + ")")
               EXIT
            ENDIF
            SysRefresh()
         ELSE
            lOk := .T.
         ENDIF
      ENDDO
   ENDIF

   Return(lOk)

FUNCTION WriteLog(xMsg, cFile, lOverwrite)

   /*
   Writes a character string (or array) <xMsg> to a text file <cFile>.
   lOverwrite defaults to false.
   */
   LOCAL hLog, lOpen := .F.

   DEFAULT lOverwrite := .F.

   IF file(cFile) .and. !lOverwrite
      hLog := fopen(cFile, FO_READWRITE)
      lOpen := .T.
   ELSE
      hLog := fcreate(cFile, FC_NORMAL)
   ENDIF

   IF hLog == F_ERROR
      MsgAlert("Error " + Nstr(ferror()) + ;
         iif(lOpen, " opening ", " creating ") + cFile, ;
         procname(1) + "(" + Nstr(procline(1)) + ")")

      Return(.F.)
   ENDIF

   // Seek to the end of the file (append):

   fseek(hLog, 0, FS_END)

   // If xMsg is an array, each element is a line of text.  If character, it
   // is a single line of text:

   IF valtype(xMsg) == "A"
      aeval(xMsg, {|e| FWriteLn(hLog, e) })
   ELSEIF valtype(xMsg) == "C"
      FWriteLn(hLog, xMsg)
   ENDIF

   fclose(hLog)

   Return(.T.)
