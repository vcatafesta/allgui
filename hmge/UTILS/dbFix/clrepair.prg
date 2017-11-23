/*

REPAIR.PRG   Main Database Repair Function

*/
#include "cldbfix.ch"
#include "error.ch"

#define CRLF      chr(13)+chr(10)

#define MAX_64K   65500 // 65516 is the most I can get into a string w/o an overflow.
// 65520 is the max memo size as defined by Comix.
#define TYPE_FPT  1
#define TYPE_III  2
#define TYPE_IV   3

#define MEMO_HDR_SIZE   512 // Standard memo header size for all types

#define ERR_BLANK "B"
#define ERR_SIZE  "S"
#define ERR_EOF   "T"

STATIC lLog, hLog, nMemoType, nBlockSize, nMemoEOF, nMaxMemoSize

FUNCTION DBRepair(cDbf, cLog, cDonor, cRDD, cJunkChar, ;
      lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk)

   LOCAL cTitle := "Database Repair: " + FileParts(cDbf, FP_FILENAME)
   LOCAL lOk := .F., lRestore := .F., lRestMemo := .F., lRestIndex := .F.
   LOCAL hDBF, nEvery, nBytes, f, i, n, x
   LOCAL cTemp, cMsg, cRecord, cField, cBakDbf, cBakIndex, cIndex
   LOCAL cMemo, cBakMemo, cMemoDups, cMemoData, hMemo, lMemo := .F.
   LOCAL nDBFSize, nRecCount, nHdrLen, nRecLen, nFields
   LOCAL aStruct_ := {}, aTemp_ := array(4), cEOF := chr(26)
   LOCAL nSaved := 0, nLost := 0, nDamaged := 0, nDeleted := 0
   LOCAL nDCount, nProcessed := 0, lDamage
   LOCAL cCont := "Correct this error and attempt to continue?"
   LOCAL lDonor := !empty(cDonor)
   LOCAL lLogDeleted := .F. // GetIni(INI_SECT, "LogDeleted", .F.)
   LOCAL lCopyBackup := .F. // GetIni(INI_SECT, "CopyBackup", .F.)
   LOCAL lSaveTemp   := .F. // GetIni(INI_SECT, "SaveTemp",   .F.)
   LOCAL lEnd := .F.
   LOCAL nLastPercent := 0

   nMaxMemoSize := 60000 // min(GetIni(INI_SECT, "MaxMemoSize", MAX_64K), MAX_64K)

   nBlockSize := 0

   // Set these "undocumented" INI entries so they're easier to edit:

   // SetIni(INI_SECT, "LogDeleted",  lLogDeleted)
   // SetIni(INI_SECT, "CopyBackup",  lCopyBackup)
   // SetIni(INI_SECT, "SaveTemp",    lSaveTemp)
   // SetIni(INI_SECT, "MaxMemoSize", nMaxMemoSize)

   // Set default values for parameters:

   cDbf := alltrim(cDbf)

   DEFAULT cLog      := "", ;
      cRDD      := rddSetDefault(), ;
      cJunkChar := "?", ;
      lCharJunk := .F., ;
      lMemoJunk := .F., ;
      lDeleted  := .F., ;
      lPartial  := .F., ;
      lTotal    := .F.

   cLog := alltrim(cLog)

   lLog := !empty(cLog)
   hLog := F_ERROR

   // Make sure required files exist & ask to overwrite those that do:

   IF !file(cDbf)
      ? cDbf + " not found."

      Return(.F.)
   ENDIF

   cBakDbf := RevExt(cDBF)

   IF file(cBakDbf)
      IF !GetYesNo("The backup file " + cBakDbf + " exists.  Overwrite?", .F.)

         Return(.F.)
      ENDIF
   ENDIF

   // If this file is less than 66 bytes, it can't be a dbf!

   IF FSize(cDbf) < 66
      ? cDbf + " is too small to be a DBF file (minimum size is 66 bytes)."

      Return(.F.)
   ENDIF

   BEGIN sequence

      // Start the log:

      IF lLog
         IF file(cLog)
            IF !GetYesNo("The log file " + cLog + " exists.  Overwrite?", .F.)
               lLog := .F.
               break
            ENDIF
         ENDIF
         hLog := fcreate(cLog, FC_NORMAL)
         IF hLog == F_ERROR
            FileErrMsg(cLog, "creating")
            lLog := .F.
            break
         ENDIF
         LogText("CLDBFix v" + DBFIX_VERSION)
         LogText("Database Repair Log: " + cDbf)
         LogText("Repair started " + dtoc(date()) + " " + time())
         LogText(CRLF + "Repair Options:")
         LogText("Preload memo data................" + transform(lPreload,  "Y"))
         LogText("Save deleted records............." + transform(lDeleted,  "Y"))
         LogText("Save partially damaged records..." + transform(lPartial,  "Y"))
         LogText("  Save totally damaged records..." + transform(lTotal,    "Y"))
         LogText("Allow junk in character fields..." + transform(lCharJunk, "Y"))
         LogText("Allow junk in memo fields........" + transform(lMemoJunk, "Y"))
         LogText("Junk replacement character......." + cJunkChar)
         IF lDonor
            LogText(CRLF + "Header Donor database: " + cDonor)
         ENDIF
      ENDIF

      // Convert a three-digit ASCII code into a real replacement character:

      IF len(cJunkChar) > 1
         cJunkChar := chr(val(cJunkChar))
      ENDIF

      // See if we can determine what RDD this file was created with, first by
      // finding an index that would give it away, then by looking at the
      // version byte:

      ? "Determining RDD..."
      IF inkey() = K_ESC
         break
      ENDIF

      cTemp := cRDD
      cIndex := FindIndex(cDbf, @cTemp)
      IF !empty(cIndex)
         cRDD := cTemp
      ENDIF

      cTemp := iif(lDonor, cDonor, cDbf)
      n := fopen(cTemp, FO_READ + FO_SHARED)
      IF n == F_ERROR
         FileErrMsg(cTemp)
         break
      ENDIF
      cField := " "
      fread(n, @cField, 1)
      fclose(n)
      n := asc(cField)

      LogText(CRLF + "DBF version byte: " + Nstr(n))

      cMemo := NewExt(cDbf, ".DBT")

      DO CASE
      CASE n == 2 .or. n == 3 .or. n == 4
         // Database without a memo - use the default RDD
      CASE n == 11
         // dBase IV without memo
         IF cRDD <> "DBFIV" .and. cRDD <> "DBFMDX"
            cRDD := "DBFMDX"
         ENDIF
      CASE n == 131
         // dBase III with memo
         lMemo := .T.
         IF cRDD <> "DBF" .and. cRDD <> "DBFNDX" .and. cRDD <> "DBFNTX"
            cRDD := "DBFNTX"
         ENDIF
      CASE n == 139
         // dBase IV with memo
         lMemo := .T.
         IF cRDD <> "DBFIV" .and. cRDD <> "DBFMDX"
            cRDD := "DBFMDX"
         ENDIF
      CASE n == 245
         // Comix/DBFCDX/FoxPro with memo
         lMemo := .T.
         cMemo := NewExt(cDbf, ".FPT")
         IF cRDD <> "SIXCDX" .and. cRDD <> "DBFCDX"
            cRDD := "SIXCDX"
         ENDIF
      CASE file(cMemo)  // *.DBT?
         lMemo := .T.
         cRDD := DBT_Type(cMemo, cRDD)
      CASE file(cMemo := NewExt(cDbf, ".FPT"))
         lMemo := .T.
         IF cRDD <> "SIXCDX" .and. cRDD <> "DBFCDX"
            cRDD := "SIXCDX"
         ENDIF
      ENDCASE

      IF lMemo
         LogText("Memo file: " + cMemo)
      ENDIF
      IF !empty(cIndex)
         LogText("Index file: " + cIndex)
      ENDIF

      LogText("Using " + cRDD + " RDD", .T.)
      LogText("Maximum memo size: " + Nstr(nMaxMemoSize))
      rddSetDefault(cRDD)

      // Make sure the memo file is present if required...

      IF lMemo
         IF !file(cMemo)
            cMsg := "Memo file not found.  "
            IF GetYesNo(cMsg + "Proceed without memo data?", .F.)
               LogText(cMsg + "Proceeding without memo." + CRLF)
               lMemo := .F.
            ELSE
               LogText(cMsg + "Repair cancelled." + CRLF, .T.)
               break
            ENDIF
         ENDIF
      ENDIF

      // Copy the original file to the backup name:

      // Copying is used rather than just renaming due to certain OS errors
      // involving misreported file sizes (such as the Novell Turbo-FAT bug).
      // This can be turned off by changing the "CopyBackup" INI entry.

      // I changed the default to renaming because copying takes so long...

      ? "Creating backup..."
      IF inkey() = K_ESC
         break
      ENDIF

      cTemp := iif(lCopyBackup, " copied to ", " renamed to ")

      IF iif(lCopyBackup, CopyFile(cDbf, cBakDbf), RenFile(cDbf, cBakDbf))
         LogText(CRLF + cDbf + cTemp + cBakDbf)
         ferase(cDbf)
         lRestore := .T.
         IF lMemo
            cBakMemo := RevExt(cMemo)
            IF iif(lCopyBackup, CopyFile(cMemo, cBakMemo), RenFile(cMemo, cBakMemo))
               lRestMemo := .T.
               LogText(cMemo + cTemp + cBakMemo)
               ferase(cMemo)
            ELSE
               LogText("Failed to create backup of memo.", .T.)
               break
            ENDIF
         ENDIF
         IF !empty(cIndex)
            cBakIndex := RevExt(cIndex)
            IF RenFile(cIndex, cBakIndex)
               lRestIndex := .T.
               LogText(cIndex + " renamed to " + cBakIndex)
            ELSE
               LogText("Failed to create backup of index.", .T.)
               break
            ENDIF
         ENDIF
      ELSE
         LogText(CRLF + "Failed to create backup of DBF.", .T.)
         break
      ENDIF

      // Read the header from the corrupt file:

      ? "Reading header..."
      IF inkey() = K_ESC
         break
      ENDIF

      lOk := .T.

      hDbf := fopen(cBakDbf, FO_READ + FO_EXCLUSIVE)

      IF hDbf == F_ERROR
         FileErrMsg(cBakDbf)
         hDbf := NIL
         break
      ENDIF

      IF lMemo
         hMemo := fopen(cBakMemo, FO_READ + FO_EXCLUSIVE)
         IF hMemo == F_ERROR
            FileErrMsg(cBakMemo)
            hMemo := NIL
            break
         ENDIF
      ENDIF

      nDBFSize := fseek(hDbf, 0, FS_END)
      fseek(hDbf, 0, FS_SET)

      /* Main Header Structure - first 32 bytes

      Pos     Data
      --------------------------
      1       Version byte
      2-4     Last update (ymd)
      5-8     Record count
      9-10    Header length
      11-12   Record length
      13-32   Reserved
      --------------------------
      */

      cRecord := space(32)
      fread(hDbf, @cRecord, 32)

      cField := substr(cRecord, 5, 4)
      nRecCount := CtoN(cField)

      cField := substr(cRecord, 9, 2)
      nHdrLen := CtoN(cField)

      cField := substr(cRecord, 11, 2)
      nRecLen := CtoN(cField)

      IF lDonor

         IF NetUse(cDonor + " alias Donor readonly", .F.,, .F.) // Don't open index
            nRecLen  := Donor->( recsize() )
            nHdrLen  := Donor->( header() )
            nFields  := Donor->( fcount() )
            aStruct_ := Donor->( DBStruct() )
            Donor->( DBCloseArea() )
         ELSE
            lOk := .F.
            break
         ENDIF

      ELSE

         /*

         Try to find the actual end of the header to see if it matches the
         header length read from the file.

         In a Clipper database where nHdrLen will always be an even number,
         we should find chr(13)+chr(0) at offset (nHdrLen - 2).  In any case
         it will always be on a 32-byte boundary at offset 64 or greater.

         For dBase databases, nHdrLen will be an odd number and the chr(13)
         should be found at (nHdrLen - 1).

         */

         lOk := .F.
         i := chr(13)
         cTemp := space(32)

         n := 64 // This is the earliest place it could be (main hdr + 1 field)
         fseek(hDbf, n, FS_SET)

         DO WHILE fread(hDbf, @cTemp, 32) == 32
            IF left(cTemp, 1) == i // Found it!
               lOk := .T.
               n++
               IF substr(cTemp, 2, 1) == chr(0)
                  n++
               ENDIF
               EXIT
            ENDIF
            n += 32
         ENDDO

         fseek(hDbf, 32, FS_SET) // Return to the end of the main file header

         /*

         If unable to find the terminator, that part of the file must have
         been damaged so we'll have to go by the value from the header.  If
         we did find it, make sure it matches:

         */

         IF lOk .and. n <> nHdrLen
            // "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
            ?  "The file header reports the header length as " + Nstr(nHdrLen) + ", but the header terminator"
            x := GetYesNo("was found at position " + Nstr(n) + ".  Use the found value instead?")
            IF x == NIL
               lOk := .F.
               break
            ELSEIF x
               LogText(CRLF + "Header length changed from " + Nstr(nHdrLen) + ;
                  " to the location of the terminator found at " + Nstr(n) + ".")
               nHdrLen := n
            ENDIF
         ENDIF

         lOk := .T.

         // Is the dbf big enough to hold the header?

         IF nHdrLen > nDBFSize
            LogText("Database header truncated by eof.  Data is unrecoverable.", .T.)
            lOk := .F.
            break
         ENDIF

         // Retrieve the database structure:

         nFields := (int(nHdrLen / 32) - 1) // Calculate # of fields

         x := 1 // Count the record length.  Start with 1 for the deleted byte.

         FOR f := 1 to nFields

            /* Field Header Structure

            Pos     Data
            -------------------------------
            1-11    Name (padded w/ chr(0))
            12      Type
            13-16   Reserved
            17      Length
            18      Decimals
            19-32   Reserved
            -------------------------------
            */

            IF fread(hDbf, @cRecord, 32) <> 32
               FileErrMsg(cBakDbf, "reading")
               lOk := .F.
               EXIT
            ENDIF

            // Name:
            cField := substr(cRecord, 1, 11)
            cTemp := left(cField, at(chr(0), cField) - 1)
            IF !FieldValid(cTemp, .F.)
               lOk := .F.
               LogText(CRLF + "Field #" + Nstr(f) + " has an invalid field name: " + cTemp)
               ? "Field #" + Nstr(f) + " has an invalid field name."
               IF GetYesNo("Would you like to try and correct it?", .F.)
                  DO WHILE !FieldValid(cTemp, .F.)
                     ACCEPT "Enter the corrected field name (blank to cancel): " TO cTemp
                     IF empty(cTemp)
                        EXIT
                     ENDIF
                     cTemp := upper(left(alltrim(cTemp), 10))
                  ENDDO
                  IF !empty(cTemp)
                     lOk := .T.
                     LogText("Field #" + Nstr(f) + " name corrected to " + cTemp)
                  ENDIF
               ENDIF
               IF !lOk
                  EXIT
               ENDIF
            ENDIF
            aTemp_[DBS_NAME] := alltrim(cTemp)

            // Type:
            cField := substr(cRecord, 12, 1)
            IF .not. (cField $ "CDLMN")
               lOk := .F.
               IF !IsAlpha(cField)
                  cField := "?"
               ENDIF
               LogText(CRLF + "Field " + aTemp_[DBS_NAME] + ;
                  " has an unsupported or invalid data type: " + cField)
               ? "Field " + aTemp_[DBS_NAME] + " has an unsupported or invalid data type (" + cField + ")."
               IF GetYesNo("Would you like to try and correct it?", .F.)
                  DO WHILE at(cField, "CDLMN") == 0
                     ACCEPT "Enter the correct data type (C,D,L,M,N, blank to cancel): " TO cField
                     IF empty(cField)
                        EXIT
                     ENDIF
                     cField := upper(left(cField, 1))
                  ENDDO
                  IF !empty(cField)
                     lOk := .T.
                     LogText("Field " + aTemp_[DBS_NAME] + ;
                        " data type corrected to " + cField)
                  ENDIF
               ENDIF
               IF !lOk
                  EXIT
               ENDIF
            ENDIF
            aTemp_[DBS_TYPE] := cField

            // Assign type adjective and required length (0=any length)
            DO CASE
            CASE cField == "C"
               cTemp := "character"
               i := 0
            CASE cField == "D"
               cTemp := "date"
               i := 8
            CASE cField == "L"
               cTemp := "logical"
               i := 1
            CASE cField == "M"
               cTemp := "memo"
               i := 10
            CASE cField == "N"
               cTemp := "numeric"
               i := 0
            ENDCASE

            // Length:
            cField := substr(cRecord, 17, 1)
            n := asc(cField)
            IF i > 0 .and. n <> i
               cMsg := "The " + cTemp + " field " + aTemp_[DBS_NAME] + ;
                  " should have a length of " + Nstr(i) + ;
                  ", but is reporting a length of " + Nstr(n) + "."
               ? cMsg
               IF GetYesNo(cCont, .F.)
                  LogText(CRLF + cMsg + " - Corrected")
                  n := i
               ELSE
                  LogText(CRLF + cMsg)
                  lOk := .F.
                  EXIT
               ENDIF
            ENDIF
            aTemp_[DBS_LEN] := n

            // Decimals:
            cField := substr(cRecord, 18, 1)
            n := asc(cField)
            IF n > 0
               IF aTemp_[DBS_TYPE] == "C" // Char field > 255 length
                  aTemp_[DBS_LEN] += (n * 256)
                  n := 0
               ELSEIF aTemp_[DBS_TYPE] $ "DLM"
                  cMsg := "The " + cTemp + " field " + aTemp_[DBS_NAME] + ;
                     " should not have a decimal value but is reporting " + ;
                     Nstr(n) + " decimal places."
                  ? cMsg
                  IF GetYesNo(cCont, .F.)
                     LogText(CRLF + cMsg + " - Corrected")
                     n := 0
                  ELSE
                     LogText(CRLF + cMsg)
                     lOk := .F.
                     EXIT
                  ENDIF
               ENDIF
            ENDIF
            aTemp_[DBS_DEC] := n

            // Add this field to the structure
            aadd(aStruct_, aclone(aTemp_))

            // Add the field length to the record length tally:
            x += aTemp_[DBS_LEN]

            lEnd := inkey() == K_ESC
            IF lEnd
               lOk := .F.
               break
            ENDIF

         NEXT

         // Check the record length:

         IF lOk .and. x <> nRecLen
            cMsg := "The database header gives a record length of " + ;
               Nstr(nRecLen) + ".  The database structure indicates a" + ;
               " record length of " + Nstr(x) + "."
            ? cMsg
            IF GetYesNo(cCont, .F.)
               LogText(CRLF + cMsg + " - Corrected")
               nRecLen := x
            ELSE
               LogText(CRLF + cMsg)
               lOk := .F.
            ENDIF
         ENDIF

         // Did any of the above fail?

         cTemp := cDbf + " can not be repaired due to "

         IF !lOk .and. !lEnd
            cMsg := cTemp + "header damage."
            LogText(CRLF + cMsg, .T.)
            break
         ENDIF

      ENDIF // lDonor

      // See how often we need to update the meter (at least every 100 recs):

      nEvery := Crop(1, int((nDBFSize / nRecLen) / 100), 100)

      // Initialize the memo data:

      IF lMemo
         IF MemoInit(hMemo, cRDD) > 0 // Returns nBlockSize
            // Create a database to detect duplicate memos:
            cMemoDups := Temp_Name(".TMP", FileParts(cDbf, FP_PATH))
            DBCreate(cMemoDups, {{ "POINTER", "C", 10, 0 }, ;
               { "RECORD",  "N", 10, 0 }, ;
               { "FIELD",   "C", 10, 0 }}, "SIXCDX")
            IF !NetUse(cMemoDups + " alias MemoDups via SIXCDX", .T.)
               lOk := .F.
               break
            ENDIF
            SELECT MemoDups
            INDEX ON ("POINTER") tag POINTER
            // Preload all the memo data:
            IF lPreload
               cMemoData := Temp_Name(".TMP", FileParts(cDbf, FP_PATH))
               DBCreate(cMemoData, {{ "POINTER",  "C", 10, 0 }, ;
                  { "ERROR",    "C",  1, 0 }, ;
                  { "MEMOTEXT", "M", 10, 0 }}, "SIXCDX")
               IF !NetUse(cMemoData + " alias MemoData via SIXCDX", .T.)
                  lOk := .F.
                  break
               ENDIF
               SELECT MemoData
               INDEX ON ("POINTER") tag POINTER
               IF !MemoPreload(hMemo, @lEnd)
                  lOk := .F.
                  break
               ENDIF
            ENDIF
         ENDIF
      ENDIF

      // Create a new copy of the database and open it up:

      ? "Creating new database..."

      DBCreate(cDbf, aStruct_)
      IF !NetUse(cDbf + " alias Target", .T.)
         lOk := .F.
         break
      ENDIF

      // Begin reading the data:

      ? "Evaluating data..."

      LogText("")

      fseek(hDbf, nHdrLen, FS_SET) // Position to start of data

      aTemp_ := array(nFields)

      cRecord := space(nRecLen)

      nBytes := nRecLen

      DO WHILE lOk .and. nBytes == nRecLen

         nBytes := fread(hDbf, @cRecord, nRecLen)

         IF nBytes == 0 .or. ; // No more data?
            (nBytes == 1 .and. left(cRecord, nBytes) == cEOF)
            EXIT
         ENDIF

         nProcessed++

         IF nBytes < nRecLen // Was this record truncated by eof?
            LogText("Record #" + Nstr(nProcessed) + ;
               " truncated by eof after " + Nstr(nBytes) + " bytes.")
            cRecord := left(cRecord, nBytes)
         ENDIF

         IF !lDeleted // Ignore deleted records?
            IF left(cRecord, 1) == "*"
               IF lLogDeleted
                  LogText("Deleted record #" + Nstr(nProcessed) + " discarded.")
               ENDIF
               nDeleted++
               LOOP
            ENDIF
         ENDIF

         nDCount := 0 // Count the number of damaged fields

         x := 2
         FOR f := 1 to nFields
            cMsg := "Record #" + Nstr(nProcessed) + ;
               " field " + aStruct_[f, DBS_NAME] + " "
            cField := substr(cRecord, x, aStruct_[f, DBS_LEN])
            x += aStruct_[f, DBS_LEN]
            DO CASE
            CASE len(cField) == 0 //-------------------------- Truncated by EOF
               nDCount++
               LogText(cMsg + "truncated by eof.")
               aTemp_[f] := NIL
            CASE aStruct_[f, DBS_TYPE] == "C" //--------------------- Character
               // Allow anything unless checking for junk
               IF !lCharJunk
                  IF HasJunk(@cField, .F., cJunkChar)
                     LogText(cMsg + "contains junk.")
                     nDCount++
                  ENDIF
               ENDIF
               aTemp_[f] := cField
            CASE aStruct_[f, DBS_TYPE] == "D" //-------------------------- Date
               // Dates must be valid or blank:
               aTemp_[f] := StoD(cField)
               IF dtos(aTemp_[f]) <> cField
                  LogText(cMsg + "invalid date (" + cField + ")")
                  nDCount++
               ENDIF
            CASE aStruct_[f, DBS_TYPE] == "L" //----------------------- Logical
               // Logicals must be T or F.
               // Blank and ? are also valid for uninitialized data.
               aTemp_[f] := (cField == "T")
               IF !(cField $ "TF ?")
                  LogText(cMsg + "invalid logical (" + cField + ")")
                  nDCount++
               ENDIF
            CASE aStruct_[f, DBS_TYPE] == "M" //-------------------------- Memo
               aTemp_[f] := ""
               IF nBlockSize > 0 .and. !empty(cField)
                  n := val(cField)
                  IF n > 0 .and. str(n, 10, 0) == cField
                     IF (n * nBlockSize) > nMemoEOF
                        LogText(cMsg + "memo pointer * blocksize > eof: " + ;
                           alltrim(cField))
                        nDCount++
                     ELSE
                        lDamage := MemoDupe(cField, cMsg, ;
                           aStruct_[f, DBS_NAME], nProcessed)
                        IF lPreLoad
                           cTemp := MemoSeek(cField, cMsg, @lDamage)
                        ELSE
                           cTemp := MemoRead(hMemo, cField, cMsg, @lDamage)
                        ENDIF
                        IF !empty(cTemp)
                           IF !lMemoJunk
                              IF HasJunk(@cTemp, .T., cJunkChar)
                                 lDamage := .T.
                                 // If the whole thing is junk, don't bother saving it.
                                 IF AllJunk(cTemp, cJunkChar)
                                    cTemp := ""
                                    LogText(cMsg + "is 100% junk, memo discarded.")
                                 ELSE
                                    LogText(cMsg + "contains junk.")
                                 ENDIF
                              ENDIF
                           ENDIF
                           aTemp_[f] := cTemp
                        ENDIF
                        IF lDamage
                           nDCount++
                        ENDIF
                     ENDIF
                  ELSE
                     LogText(cMsg + "invalid memo pointer (" + cField + ")")
                     nDCount++
                  ENDIF
               ENDIF
            CASE aStruct_[f, DBS_TYPE] == "N" //----------------------- Numeric
               // Numbers must have the correct number of decimal places.
               // Blank numbers (including lone decimal points) are normal for
               // uninitialized data.
               n := val(cField)
               cTemp := str(n, aStruct_[f, DBS_LEN], aStruct_[f, DBS_DEC])
               IF !empty(cField)
                  IF cTemp <> cField .and. alltrim(cField) <> "."
                     LogText(cMsg + "invalid number (" + cField + ")")
                     nDCount++
                  ENDIF
               ENDIF
               aTemp_[f] := val(cTemp)
            ENDCASE
            IF !lPartial .and. nDCount > 0  // Not saving damaged records?
               nDCount := nFields // Pretend it's a total loss and move on.
               EXIT
            ENDIF
         NEXT

         IF nDCount == nFields .and. !lTotal  // Was this record totalled?
            LogText("Record #" + Nstr(nProcessed) + " lost to corruption.")
            nLost++
            LOOP
         ENDIF

         Target->( DBAppend() ) // Add the record to the database
         FOR f := 1 to nFields
            Target->( fieldput(f, aTemp_[f]) )
         NEXT

         IF left(cRecord, 1) == "*" // Was this record deleted?  Preserve that.
            Target->( DBDelete() )
         ENDIF

         IF nDCount > 0 // Count the damaged/saved records
            // Log entry for easy lookup when the record numbers don't match:
            IF Target->( recno() ) <> nProcessed
               LogText("Target record #" + Nstr(Target->( recno() )) + ;
                  " contains damaged data.")
            ENDIF
            nDamaged++
         ELSE
            nSaved++
         ENDIF

         IF nProcessed % nEvery == 0
            x := fseek(hDbf, 0, FS_RELATIVE)
            x := round((x / nDBFSize) * 100, 0)
            IF (x % 10 == 0) .and. (x <> nLastPercent)
               ? "Repair " + Nstr(x) + "% complete"
               nLastPercent := x
            ENDIF
            lEnd := inkey() == K_ESC
            IF lEnd
               lOk := .F.
               break
            ENDIF
         ENDIF

      ENDDO

      Target->( DBCommit() )

   END SEQUENCE

   DBCloseAll()

   IF !lSaveTemp
      IF !empty(cMemoDups)
         ferase(cMemoDups)
         ferase(NewExt(cMemoDups, "CDX")) // IndexOf() uses the default RDD!
      ENDIF
      IF !empty(cMemoData)
         ferase(cMemoData)
         ferase(NewExt(cMemoData, "CDX"))
         ferase(NewExt(cMemoData, "FPT"))
      ENDIF
   ENDIF

   IF valtype(hDbf) == "N"
      fclose(hDbf)
   ENDIF

   IF valtype(hMemo) == "N"
      fclose(hMemo)
   ENDIF

   IF lOk

      n := len(Nstr(max(nRecCount, nProcessed))) // Length of longest number

      cMsg := str(nRecCount, n) + ;
         " records were reported in the original DBF header." + CRLF + ;
         str(nProcessed, n) + " records were processed."

      IF nDeleted > 0
         cMsg += CRLF + str(nDeleted, n) + " deleted records were discarded."
      ENDIF

      IF nLost > 0
         cMsg += CRLF + str(nLost, n) + " records were lost to corruption."
      ENDIF

      cMsg += CRLF + str(nSaved + nDamaged, n) + " records were saved." + ;
         CRLF + iif(nDamaged > 0, str(nDamaged, n), "None") + ;
         " of the saved records were damaged."

      IF lLog
         LogText(CRLF + "*** Repair Summary ***" + CRLF + cMsg, .T.)
         LogText(CRLF + "Repair ended " + dtoc(date()) + " " + time())
      ENDIF

      ? "Repair Complete"
      ?

   ELSE

      LogText("")

      IF lEnd
         LogText("Repair cancelled by user: " + ;
            dtoc(date()) + " " + time() + CRLF)
      ENDIF

      IF lRestore
         ? "Cancelled - Restoring original files..."
         IF RenFile(cBakDbf, cDbf)
            LogText(cBakDbf + " restored to " + cDbf)
            IF lRestMemo
               IF RenFile(cBakMemo, cMemo)
                  LogText(cBakMemo + " restored to " + cMemo)
               ELSE
                  cMsg := "Failed to restore " + cBakMemo + " to " + cMemo + "!"
                  LogText(CRLF + cMsg, .T.)
               ENDIF
            ENDIF
            IF lRestIndex
               IF RenFile(cBakIndex, cIndex)
                  LogText(cBakIndex + " restored to " + cIndex)
               ELSE
                  cMsg := "Failed to restore " + cBakIndex + " to " + cIndex + "!"
                  LogText(CRLF + cMsg, .T.)
               ENDIF
            ENDIF
         ELSE
            cMsg := "Failed to restore " + cBakDbf + " to " + cDbf + "!"
            LogText(CRLF + cMsg, .T.)
         ENDIF
      ENDIF

      IF lEnd
         ? "Repair Cancelled"
      ENDIF

   ENDIF

   IF hLog <> F_ERROR
      fclose(hLog)
   ENDIF

   Return(lLog)

STATIC FUNCTION AllJunk(cMemo, cJunkChar)

   /*

   Returns true if a memo consists entirely of cJunkChar and/or whitespace.
   */
   LOCAL lAllJunk := .T.
   LOCAL cJunk := cJunkChar + " " + chr(9) + chr(10) + chr(13) + chr(141)
   LOCAL x, nLen := len(cMemo)

   FOR x := 1 to nLen
      IF .not. substr(cMemo, x, 1) $ cJunk
         lAllJunk := .F.
         EXIT
      ENDIF
   NEXT

   Return(lAllJunk)

STATIC FUNCTION CopyFile(cSource, cTarget)

   COPY file (cSource) to (cTarget)

   Return(file(cTarget))

STATIC FUNCTION DBT_Type(cMemo, cDefault)

   LOCAL cRDD := cDefault
   LOCAL h, cTemp := ""

   IF !file(cMemo) // No memo?  Worry about it later...

      Return(cRDD)
   ENDIF

   FindIndex(cMemo, @cTemp) // Got a good index to go by?  Use it.
   IF !empty(cTemp)

      Return(cTemp)
   ENDIF

   h := fopen(cMemo, FO_READ + FO_SHARED)

   IF h == F_ERROR
      FileErrMsg(cMemo)

      Return(cRDD)
   ENDIF

   // Try to find something in the header to clue us in:

   cTemp := space(MEMO_HDR_SIZE)
   fread(h, cTemp, MEMO_HDR_SIZE)
   fclose(h)

   DO CASE
   CASE substr(cTemp, 32, 6) == "DBFNTX"
      cRDD := "DBFNTX"
   CASE substr(cTemp, 32, 6) == "DBFNDX"
      cRDD := "DBFNDX"
   CASE substr(cTemp, 32, 3) == "DBF"
      cRDD := "DBF"
   CASE ".NTX" $ cTemp
      cRDD := "DBFNTX"
   CASE ".NDX" $ cTemp
      cRDD := "DBFNDX"
   CASE ".MDX" $ cTemp
      cRDD := "DBFMDX"
   CASE cRDD == "SIXCDX" .or. cRDD == "DBFCDX"
      // Unable to determine anything from the header.  If the default RDD
      // is set to the wrong type (FPT memos), change to DBFNTX since it's
      // the Clipper default.
      cRDD := "DBFNTX"
   ENDCASE

   Return(cRDD)

STATIC FUNCTION FieldValid(cName, lMsgs)

   /*

   Returns a logical indicating if cName is a valid field name
   */

   Return(GenValid(cName, "NE,<@,MCO@#_",,, lMsgs))

STATIC FUNCTION FileErrMsg(cFile, cVerb)

   LOCAL cMsg

   DEFAULT cVerb := "opening"

   cMsg := "Error #" + Nstr(ferror()) + " " + cVerb + " " + cFile

   IF hLog <> F_ERROR
      LogText(cMsg)
   ENDIF

   ? cMsg

   Return(NIL)

STATIC FUNCTION FindIndex(cDbf, cRDD)

   LOCAL aExt_ := { "CDX",   "IDX",    "MDX",    "NDX",    "NTX"    }
   LOCAL aRDD_ := { "SIXCDX", "DBFCDX", "DBFMDX", "DBFNDX", "DBFNTX" }
   LOCAL cStub := StripExt(cDbf) + "."
   LOCAL x, cIndex := ""

   FOR x := 1 to len(aExt_)
      IF file(cStub + aExt_[x])
         cIndex := cStub + aExt_[x]
         cRDD := aRDD_[x]
         EXIT
      ENDIF
   NEXT

   Return(cIndex)

STATIC FUNCTION HasJunk(cText, lMemo, cJunkChar)

   /*
   Checks a character var for low/high ASCII characters.  If cText is passed
   by reference, these occurences will be replaced with <cJunkChar>.
   */
   LOCAL nLen, n, x
   LOCAL lJunk := .F.

   #ifdef SHOWJUNK
   LOCAL cJunk := ""

   #endif

   nLen := len(rtrim(cText))

   FOR x := 1 to nLen
      n := asc(substr(cText, x, 1))
      IF n < 32 .or. n > 126
         lJunk := iif(lMemo, ;
            .not. (n == 9 .or. n == 10 .or. n == 13 .or. n == 141), ;
            .T.)
         IF lJunk
            cText := InsDel(cText, x, 1, cJunkChar)
            #ifdef SHOWJUNK
            cJunk += Nstr(n) + " "
            #endif
         ENDIF
      ENDIF
   NEXT

   #ifdef SHOWJUNK
   IF lJunk
      LogText(cJunk)
   ENDIF
   #endif

   Return(lJunk)

STATIC FUNCTION LogText(cMsg, lShow)

   DEFAULT lShow := .F.

   IF lLog
      FWriteLn(hLog, cMsg)
   ENDIF

   IF !lLog .or. lShow
      ? cMsg
   ENDIF

   Return(NIL)

STATIC FUNCTION MemoDupe(cPointer, cMsg, cFieldName, nRecno)

   LOCAL lDupe := .F.

   IF MemoDups->( DBSeek(cPointer) )
      lDupe := .T.
      LogText(cMsg + "duplicate memo pointer of record #" + ;
         Nstr(MemoDups->RECORD) + " field " + ;
         alltrim(MemoDups->FIELD) + ": " + ;
         alltrim(cPointer))
   ELSE
      MemoDups->( DBAppend() )
      MemoDups->POINTER := cPointer
      MemoDups->RECORD  := nRecno
      MemoDups->FIELD   := cFieldName
      MemoDups->( XCommit(.T.) )
   ENDIF

   Return(lDupe)

STATIC FUNCTION MemoInit(hMemo, cRDD)

   LOCAL cBuff, cTemp, n

   DO CASE
   CASE cRDD $ "DBF,DBFNDX,DBFNTX"
      nMemoType := TYPE_III
   CASE cRDD $ "DBFIV,DBFMDX"
      nMemoType := TYPE_IV
   CASE cRDD $ "SIXCDX,DBFCDX"
      nMemoType := TYPE_FPT
   ENDCASE

   nMemoEOF := fseek(hMemo, 0, FS_END)

   cBuff := space(MEMO_HDR_SIZE)
   fseek(hMemo, 0, FS_SET)
   n := fread(hMemo, @cBuff, MEMO_HDR_SIZE)

   DO CASE
   CASE nMemoEOF < MEMO_HDR_SIZE
      // The file is smaller than it's header should be!
      // If the next available block is 1, it means the memo is empty.
      // Otherwise, the file has been badly truncated.
      // In either case, set nBlockSize to zero to avoid any further reads.
      nBlockSize := 0
      cTemp := left(cBuff, 4)
      n := CtoN(cTemp)
      IF n == 1 .and. nMemoType == TYPE_III // Empty DBT?
         LogText("Memo file is empty (normal).")
      ELSE
         LogText("Memo file has been truncated and is not recoverable.")
      ENDIF
   CASE nMemoType == TYPE_III
      nBlockSize := 512 // Standard DBT memo blocks are 512 bytes.
   CASE nMemoType == TYPE_IV
      cTemp := substr(cBuff, 21, 2)
      nBlockSize := CtoN(cTemp)
   CASE nMemoType == TYPE_FPT
      cTemp := substr(cBuff, 7, 2)
      nBlockSize := CtoN(cTemp, .T.) // Big-endian value
      IF nBlockSize < 32 .or. nBlockSize > 16384
         LogText("Invalid block size in memo header: " + ;
            Nstr(nBlockSize) + ".  Assuming the default of 64.")
         nBlockSize := 64
      ENDIF
      sx_SetMemoBlock(nBlockSize)
   ENDCASE

   IF nBlockSize > 0
      LogText(CRLF + "Memo block size: " + Nstr(nBlockSize))
   ENDIF

   Return(nBlockSize)

STATIC FUNCTION MemoPreload(hMemo, lEnd)

   LOCAL cError, cBuffer, cData
   LOCAL nMemoLen, n, x
   LOCAL nEOM, cEOM := chr(26) // Memo terminator character
   LOCAL nEvery, nNext, nPos := MEMO_HDR_SIZE
   LOCAL nLastPercent := 0

   ? "Preloading memo data..."

   // Refresh 100 times or every megabyte, whichever comes more often:
   nEvery := Crop(nBlockSize, nMemoEOF / 100, 1024 * 1024)
   nEvery -= nEvery % nBlockSize
   nNext := nEvery

   DO WHILE nPos < nMemoEOF .and. !lEnd

      fseek(hMemo, nPos, FS_SET)

      cError := ""
      cData  := ""

      IF nMemoType == TYPE_III

         n := nBlockSize
         cBuffer := space(n)
         nMemoLen := 0
         nEOM := 0

         DO WHILE nEOM == 0 .and. n == nBlockSize
            n := fread(hMemo, @cBuffer, nBlockSize)
            nEOM := at(cEOM, left(cBuffer, n))
            IF nEOM > 0
               x := nEOM - 1
            ELSE
               x := n
            ENDIF
            IF nMemoLen + x > nMaxMemoSize
               cError := ERR_SIZE // Memo size > max, truncated.
               x := nMaxMemoSize - nMemoLen
               nEOM := 1 // No need for another loop
            ELSEIF n < nBlockSize .and. nEOM == 0
               cError := ERR_EOF // Truncated by EOF
            ENDIF
            cData += left(cBuffer, x)
            nMemoLen += x
         ENDDO

      ELSE

         nMemoLen := 8 // The first 8 bytes contain memo type & size info
         cBuffer := space(nMemoLen)
         n := fread(hMemo, @cBuffer, nMemoLen)

         IF n == nMemoLen
            IF nMemoType == TYPE_FPT
               nMemoLen := CtoN(substr(cBuffer, 7, 2), .T.)
            ELSE // TYPE_IV
               nMemoLen := CtoN(substr(cBuffer, 5, 2)) - 8
            ENDIF
            IF nMemoLen > 0
               IF nMemoLen > nMaxMemoSize
                  cError := ERR_SIZE
                  nMemoLen := nMaxMemoSize
               ENDIF
               // Read the entire memo in one gulp:
               cBuffer := space(nMemoLen)
               n := fread(hMemo, @cBuffer, nMemoLen)
               cData := left(cBuffer, n)
               IF n < nMemoLen
                  cError := ERR_EOF
               ENDIF
               nMemoLen += 8 // Add the 8-byte header back in
            ENDIF
         ELSE
            cError := ERR_EOF
            nMemoLen := 0
         ENDIF

      ENDIF // nMemoType

      IF nMemoLen == 0
         IF empty(cError)
            cError := ERR_BLANK // Blank memo but otherwise no error
         ENDIF
         nMemoLen := nBlockSize // Advance the pointer to the next block
      ENDIF

      MemoData->( DBAppend() )
      MemoData->POINTER  := str(int(nPos / nBlockSize), 10, 0)
      MemoData->ERROR    := cError
      MemoData->MEMOTEXT := cData

      nPos += nMemoLen
      n := nPos % nBlockSize
      IF n > 0
         nPos += nBlockSize - n // Jump to the start of the next block
      ENDIF

      IF nPos >= nNext
         x := round((nPos / nMemoEOF) * 100, 0)
         IF (x % 10 == 0) .and. (x <> nLastPercent)
            ? "Memo " + Nstr(x) + "% preloaded"
            nLastPercent := x
         ENDIF
         lEnd := inkey() == K_ESC
         DO WHILE nNext < nPos
            nNext += nEvery
         ENDDO
      ENDIF

   ENDDO

   MemoData->( DBCommit() )

   Return(!lEnd)

STATIC FUNCTION MemoRead(hMemo, cPointer, cMsg, lDamage)

   LOCAL cBuffer, cData := ""
   LOCAL nMemoLen, n, x
   LOCAL nEOM, cEOM

   // We already know at this point if we don't have a memo to read or that
   // the pointer is empty or invalid, so don't check for any of that again.

   // All memo files have a header of 512 bytes (bytes 0-511).
   // The first actual memo data starts at byte 512.

   n := (val(cPointer) * nBlockSize)

   IF n < MEMO_HDR_SIZE
      LogText(cMsg + "memo pointer * blocksize < header size: " + ;
         alltrim(cPointer))
      lDamage := .T.

      Return(cData)
   ENDIF

   // Read the data:

   fseek(hMemo, n, FS_SET)

   IF nMemoType == TYPE_III

      cBuffer := space(nBlockSize)
      cEOM := chr(26) // Memo terminator character
      nEOM := 0
      n := nBlockSize
      nMemoLen := 0

      DO WHILE nEOM == 0 .and. n == nBlockSize
         n := fread(hMemo, @cBuffer, nBlockSize)
         nEOM := at(cEOM, left(cBuffer, n))
         IF nEOM > 0
            x := nEOM - 1
         ELSE
            x := n
         ENDIF
         IF nMemoLen + x > nMaxMemoSize
            LogText(cMsg + "memo size > max.  Truncating.")
            lDamage := .T.
            x := nMaxMemoSize - nMemoLen
            nEOM := 1 // No need for another loop
         ELSEIF n < nBlockSize .and. nEOM == 0
            LogText("memo truncated by eof.  " + ;
               Nstr(nMemoLen + x) + " bytes saved.")
            lDamage := .T.
         ENDIF
         cData += left(cBuffer, x)
         nMemoLen += x
      ENDDO

   ELSE

      nMemoLen := 8 // The first 8 bytes contain memo type & size info
      cBuffer := space(nMemoLen)
      n := fread(hMemo, @cBuffer, nMemoLen)

      IF n == nMemoLen
         IF nMemoType == TYPE_FPT
            // Bytes 0-3 are the FPT "record type".  Usage?  Who knows...
            // Bytes 4-7 are the memo length (big-endian).
            // Since I can't use more than 64K, just take the last two bytes.
            // This allows bytes 4-5 to be corrupted without consequence.
            nMemoLen := CtoN(substr(cBuffer, 7, 2), .T.)
         ELSE // TYPE_IV
            // Bytes 4-7 are the memo length (little-endian) including this
            // 8-byte "header".
            // Since I can't use more than 64K, just take the first two bytes.
            // This allows bytes 6-7 to be corrupted without consequence.
            nMemoLen := CtoN(substr(cBuffer, 5, 2)) - 8
         ENDIF
         IF nMemoLen > 0
            IF nMemoLen > nMaxMemoSize
               LogText(cMsg + "reports a memo size > max.  Truncating.")
               lDamage := .T.
               nMemoLen := nMaxMemoSize
            ENDIF
            // Read the entire memo in one gulp:
            cBuffer := space(nMemoLen)
            n := fread(hMemo, @cBuffer, nMemoLen)
            cData := left(cBuffer, n)
            IF n < nMemoLen
               LogText(cMsg + "memo truncated by eof.  " + Nstr(n) + ;
                  " of " + Nstr(nMemoLen) + " bytes saved.")
               lDamage := .T.
            ENDIF
         ENDIF
      ELSE
         LogText(cMsg + "memo truncated by eof.  Entire memo lost.")
         lDamage := .T.
      ENDIF

   ENDIF // nMemoType

   Return(cData)

STATIC FUNCTION MemoSeek(cPointer, cMsg, lDamage)

   LOCAL cData := ""

   IF MemoData->( DBSeek(cPointer) )
      IF MemoData->ERROR <> ERR_BLANK
         cData := MemoData->MEMOTEXT
         IF !empty(MemoData->ERROR)
            lDamage := .T.
            DO CASE
            CASE MemoData->ERROR == ERR_SIZE
               LogText(cMsg + "reports a memo size > max.  Truncated.")
            CASE MemoData->ERROR == ERR_EOF
               LogText(cMsg + "memo partially truncated by eof.")
            ENDCASE
         ENDIF
      ENDIF
   ELSE
      lDamage := .T.
      LogText(cMsg + "incorrect memo pointer (" + cPointer + ")")
   ENDIF

   Return(cData)

STATIC FUNCTION GetYesNo(cMsg, lEsc)

   LOCAL i

   ? cMsg + " (Y/N/Esc) "

   DO WHILE .T.
      i := inkey(0)
      IF i == K_ESC

         Return(lEsc)
      ELSEIF i == asc("Y") .or. i == asc("y")
         ?? "Y"

         Return(.T.)
      ELSEIF i == asc("N") .or. i == asc("n")
         ?? "N"

         Return(.F.)
      ENDIF
   ENDDO

   Return(NIL)
