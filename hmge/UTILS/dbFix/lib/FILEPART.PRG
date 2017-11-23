/*

FILEPART.PRG    Functions dealing with filenames or parts thereof...

*/
#include "default.ch"
#include "filepart.ch"

FUNCTION AddSlash(cPath)

   /*
   Adds a trailing backslash to a path name if not already present.  An empty
   string will not be affected.  You may pass cPath by reference if desired.
   */

   IF !empty(cPath)
      IF right(cPath, 1) <> "\"
         cPath += "\"
      ENDIF
   ENDIF

   Return(cPath)

   #ifndef DOS_ONLY

FUNCTION CurPath(lSlash)

   /*

   Returns the current drive and path in the format "D:\PATH".  If lSlash is
   true, a trailing backslash will be appended.  lSlash defaults to false.
   */
   LOCAL cPath := CurDrive() + ":\" + curdir()

   // CurDrive() is a FiveWin function.

   DEFAULT lSlash := .F.

   Return(iif(lSlash, AddSlash(cPath), StripSlash(cPath)))

FUNCTION ExeName()

   /*

   Returns the current executable's name.
   Translates directly to GetModuleFileName(GetInstance()).
   */

   Return(GetModuleFileName(GetInstance()))

FUNCTION ExePath(lSlash)

   /*

   Returns the location of the currently running Windows EXE in the format
   "D:\PATH".  If the optional parameter lSlash is true, a trailing backslash
   will be appended.  lSlash defaults to false.
   */
   LOCAL cExe := ExeName()

   DEFAULT lSlash := .F.

   Return( left(cExe, rat("\", cExe) - iif(lSlash, 0, 1)) )

   #endif

FUNCTION FileParts(cFileSpec, nPart)

   /*
   This function returns requested part(s) from an extended filename.

   The part of cFileSpec you get is determined by the value of nPart:

   FP_FILENAME  = Filename, including extension
   FP_NAMEONLY  = Filename, without the extension
   FP_EXTENSION = Extension (no period)
   FP_PATH      = Pathname including a trailing backslash
   FP_DIR       = Pathname without a trailing backslash
   FP_DRIVE     = Drive letter including a trailing colon
   FP_STRIPEXT  = Returns everything to the left of the extension.

   These constants are defined in FILEPART.CH.

   Examples:

   ? FileParts("C:\TEMP\JUNK.TMP", FP_FILENAME)  --> "JUNK.TMP"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_NAMEONLY)  --> "JUNK"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_EXTENSION) --> "TMP"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_PATH)      --> "C:\TEMP\"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_DIR)       --> "C:\TEMP"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_DRIVE)     --> "C:"
   ? FileParts("C:\TEMP\JUNK.TMP", FP_STRIPEXT)  --> "C:\TEMP\JUNK"

   If nPart is empty or omitted, it will default to FP_FILENAME.

   If the requested part is not found within cFileSpec, a null string ("")
   is returned, except for FP_STRIPEXT, where the whole string will be

   returned if no extension is found.

   ? FileParts("JUNK.TMP", FP_PATH)    --> ""
   ? FileParts("JUNK.TMP", FP_DRIVE)   --> ""
   ? FileParts("C:\JUNK"), FP_STRIPEXT --> "C:\JUNK"

   If a path is requested, but only a drive letter exists, a trailing
   backslash will be added to the returned text:

   ? FileParts("B:REPORT.TXT", FP_PATH) --> "B:\"

   FP_DIR is the same as FP_PATH except that it strips a trailing backslash
   if present.

   Note: FileParts() assumes that the last thing in cFileSpec is a filename
   unless it ends with a trailing backslash.  In the following example,
   FileParts() thinks "DOCS" is a filename without an extension:

   ? FileParts("C:\WP51\DOCS", FP_PATH)     --> "C:\WP51\"
   ? FileParts("C:\WP51\DOCS", FP_FILENAME) --> "DOCS"

   By adding a trailing backslash to the above example, the confusion would
   be avoided.

   Also, directories with extensions (periods) really confuse the function.
   Don't allow them!
   */
   LOCAL cText := "", nL, nR
   LOCAL nColon := at(":", cFileSpec)
   LOCAL nDot   := rat(".", cFileSpec)
   LOCAL nSlash := rat("\", cFileSpec)

   DEFAULT nPart := FP_FILENAME

   DO CASE
   CASE nPart == FP_FILENAME
      IF nSlash > 0                               // Is there a path?
         cText := substr(cFileSpec, nSlash + 1)
      ELSEIF nColon > 0                           // How about a colon?
         cText := substr(cFileSpec, nColon + 1)
      ELSE                                        // Must be filename only
         cText := cFileSpec
      ENDIF

   CASE nPart == FP_NAMEONLY
      IF nSlash > 0                               // Find the left boundary
         nL := nSlash + 1                          //  (Just like filename)
      ELSEIF nColon > 0
         nL := nColon + 1
      ELSE
         nL := 1
      ENDIF
      IF nDot > 0                                 // Find the right boundary
         nR := nDot - 1                            // at the dot
      ELSE
         nR := len(cFileSpec)                      // No dot?
      ENDIF
      cText := substr(cFileSpec, nL, (nR - nL) + 1) // Get the stuff between

   CASE nPart == FP_EXTENSION
      IF nDot > 0                                 // Take everything past the
         cText := substr(cFileSpec, nDot + 1)      // dot.
      ENDIF

   CASE nPart == FP_PATH .or. nPart == FP_DIR
      IF nSlash > 0
         cText := left(cFileSpec, nSlash - iif(nPart == FP_DIR, 1, 0))
      ELSEIF nColon > 0
         cText := left(cFileSpec, nColon) + iif(nPart == FP_PATH, "\", "")
      ENDIF

   CASE nPart == FP_DRIVE
      IF nColon > 0
         cText := left(cFileSpec, nColon)
      ENDIF

   CASE nPart == FP_STRIPEXT
      IF nDot > 0
         cText := left(cFileSpec, nDot - 1)
      ELSE
         cText := cFileSpec
      ENDIF

   ENDCASE

   Return(cText)

FUNCTION GetTempDir(lSlash)

   /*

   Returns the name of the temp directory.  lSlash determines if the string
   will end with a trailing backslash or not (default is false).

   The function first looks for the environment variable "TEMP", then "TMP".
   If neither of these is found or the specified directories do not exist,
   C:\TEMP then C:\WINDOWS\TEMP will be used if found.  If all these fail,
   the function will return a null string.
   */
   LOCAL x, cDir := ""

   #ifdef DOS_ONLY
   LOCAL aTemp_ := { getenv("TEMP"), ;
      getenv("TMP") , ;
      "C:\TEMP"      }
   #else
   LOCAL aTemp_ := { getenv("TEMP"), ;
      getenv("TMP") , ;
      "C:\TEMP"     , ;
      AddSlash(GetWinDir()) + "TEMP" }
   #endif

   DEFAULT lSlash := .F.

   FOR x := 1 to len(aTemp_)
      IF !empty(aTemp_[x])
         IF GoodFile(Temp_Name(".TMP", aTemp_[x]))
            cDir := iif(lSlash, AddSlash(aTemp_[x]), StripSlash(aTemp_[x]))
            EXIT
         ENDIF
      ENDIF
   NEXT

   Return(cDir)

FUNCTION IndexOf(cFile)

   /*

   Returns the name of a file's structural index by stripping the extension
   off the given filename & adding the index extension.  Merely a convenience
   item and to make code more readable.

   Translates directly to: NewExt(cFile, ordBagExt())
   */

   Return(NewExt(cFile, ordBagExt()))

FUNCTION MemoOf(cFile)

   /*

   Returns the name of a database's memo file.  The function does not check
   if the database has a memo or not, just what it would be called.  It uses
   the Comix function cmxMemoExt() to get the extension.  Obviously, this
   function only works with the Comix RDD.
   */

   Return(NewExt(cFile, sx_MemoExt()))

FUNCTION NewExt(cFile, cExt)

   /*
   Strips the current extension off a file and replaces it with cExt.  The
   function will add the period if not provided.

   Translates directly to FileParts(cFile, FP_STRIPEXT) + cExt
   */

   IF left(cExt, 1) <> "." // Add period if needed
      cExt := "." + cExt
   ENDIF

   Return(FileParts(cFile, FP_STRIPEXT) + cExt)

FUNCTION RevExt(cFile)

   /*

   Returns <cFile> with its extension reversed.  Useful for making backup
   copies of files, etc.

   RevExt("FILE.DBF") -> "FILE.FBD"
   */
   LOCAL cRev := FileParts(cFile, FP_STRIPEXT) + "."
   LOCAL cExt := FileParts(cFile, FP_EXTENSION)
   LOCAL x

   FOR x := len(cExt) to 1 step -1
      cRev += substr(cExt, x, 1)
   NEXT

   Return(cRev)

FUNCTION StripExt(cFile)

   /*
   Just a quick way to write FileParts(cFile, FP_STRIPEXT)
   */

   Return(FileParts(cFile, FP_STRIPEXT))

FUNCTION StripSlash(cPath)

   /*
   Removes a trailing backslash (if any) from cPath.  You may pass cPath by
   reference if desired.
   */

   IF right(cPath, 1) == "\"
      cPath := left(cPath, len(cPath) - 1)
   ENDIF

   Return(cPath)

FUNCTION Temp_Name(cExt, cPath)

   /*

   Returns a temporary, unique filename based on the current value of the
   system timer.

   cExt is an optional extension to use for the file, defaulting to ".TMP".

   cPath is an optional path to locate the temporary file in.  It defaults to
   the current path (blank).

   The extension and path (if any) will be part of the returned filename.

   Examples:

   Temp_Name()                   -->  "_0123456.TMP"
   Temp_Name(".CDX")             -->  "_0123456.CDX"
   Temp_Name(".DBF", "C:\TEMP")  -->  "C:\TEMP\_0123456.DBF"
   */
   LOCAL cTemp

   STATIC cLast := ""

   DEFAULT cExt  := ".TMP", ;
      cPath := ""

   IF left(cExt, 1) <> "."   // Add dot if needed
      cExt := "." + cExt
   ENDIF

   cPath := AddSlash(cPath)  // Add trailing backslash if needed

   DO WHILE .T.

      cTemp := cPath + "_" + ;
         padl(ltrim(str(seconds() * 100, 7, 0)), 7, "0") + cExt

      IF cTemp == cLast .or. file(cTemp)                 // Already exist or
         LOOP                                             // same as last time?
      ENDIF

      cLast := cTemp                                     // Record it & exit
      EXIT

   ENDDO

   Return(cTemp)
