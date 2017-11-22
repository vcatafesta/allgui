/*

GENVALID.PRG    Functions for validating data entry

*/
#include "default.ch"
#include "fileio.ch"

FUNCTION AllNum(cVar)

   /*

   Returns a logical indicating if alltrim(cVar) is made up entirely of
   numeric digits.  An empty string will return true.
   */
   LOCAL x, lOk := .T.
   LOCAL cTemp := alltrim(cVar)
   LOCAL nLen := len(cTemp)

   FOR x := 1 to nLen
      IF !IsDigit(substr(cTemp, x, 1))
         lOk := .F.
         EXIT
      ENDIF
   NEXT

   Return(lOk)

   #ifndef DOS_ONLY

FUNCTION AllValid(oDlg)

   /*
   Validates all controls on a dialog.  If any control fails, the function
   will return false & focus will be given to the offending control.
   Requires FiveWin.
   */
   LOCAL x, lOk := .T.
   LOCAL nLen := len(oDlg:aControls)

   CursorWait()

   FOR x := 1 to nLen
      IF !(lOk := oDlg:aControls[x]:lValid())
         oDlg:aControls[x]:SetFocus()
         EXIT
      ENDIF
   NEXT

   CursorArrow()
   SysRefresh()

   Return(lOk)

FUNCTION FldValid(oFld)

   /*
   Validates all controls on a TFolder.  If any control fails, the folder
   will flip to the page in question and place focus on the failed control.

   Returns true if all edits were passed.
   Requires FiveWin.
   */
   LOCAL lOk := .T., d, x
   LOCAL nControls, nDialogs := len(oFld:aDialogs)

   CursorWait()

   FOR d := 1 to nDialogs
      nControls := len(oFld:aDialogs[d]:aControls)
      FOR x := 1 to nControls
         IF !oFld:aDialogs[d]:aControls[x]:lValid()
            oFld:SetOption(d)
            oFld:aDialogs[d]:aControls[x]:SetFocus()
            lOk := .F.
            EXIT
         ENDIF
      NEXT
   NEXT

   CursorArrow()
   SysRefresh()

   Return(lOk)

   #endif

FUNCTION GenValid(uVar, Edits, Misc1, Misc2, lMsgs, lEmpty)

   /*

   Accepts:  uVar    - The variable in question.  Not recommended for logicals.
   Edits   - A comma-delimited string of edit codes.  Alternatively,
   an array can be passed if the edits can not reasonably
   be represented as a comma delimited string.
   Misc1   - Varies depending on the value of Edits
   Misc2   - Varies depending on the value of Edits
   lMsgs   - Logical indicating whether you want MsgAlert()s with an
   appropriate error message.  Defaults to true.
   lEmpty  - Takes the place of the "NE" edit when used.  When true
   (the default) the entry is allowed to be empty, when
   false, it is the same as passing "NE" as an edit.

   Returns:  .F.     - Variable failed an edit
   .T.     - Variable passed all edits

   Default behaviors:

   Character vars must be left justified (no leading spaces)
   Trailing spaces are ignored on character variables.
   Character variables are not case sensitive except when using $.
   Entry may be empty (any data type).

   Edit codes:

   The Edits parameter does not necessarily have to be a comma delimited
   string.  If the first character of the string is "D", the character that
   follows will be used as the delimiter.  For example, "D~NE~MCO@#!*," would
   be delimited by the tilde (~) and would be broken into two edits, "NE" and
   "MCO@#!*," respectively.

   Edit codes are processed in the order given.  As soon as any edit fails,
   no further checks are made and the function returns false.  Checks for
   empty variables and leading spaces are processed before other edits.

   Data
   Code  Type  Description

   Generic edits -

   NE    Any   Entry may Not be Empty
   $     Any   Must be one of the values in the array passed as Misc1
   !     Any   Must NOT equal any of the values in the array passed as Misc1.
   R     Any   Range - min and max values are passed as Misc1 & Misc2.  If
   either of these parameters are nil, no respective range check
   is made.  Special: If uVar is character, and Misc1/Misc1 are
   numeric, the range comparison will be made using val(uVar).

   Special edits -

   DIR   C     Must be a valid existing directory (Requires FiveWin)
   FILE  C     Must be a valid filename
   XFILE C     Must be an existing file
   MCY   C     Variable must be a valid MMCCYY combination.  The minimum and
   maximum years allowed can be passed as Misc1 & Misc2
   respectively.  These values should be numeric, such as 1900 or
   2100.  The minimum year defaults to 1.  The entry must have a
   length of 6 and must not contain a slash.
   CYM   C     Just like MCY but in CCYYMM order.
   MY    C     Variable must be a valid MMYY combination.  The entry must have
   a length of 4 and must not contain a slash.
   SSN   CN    Must be a valid SSN (001010001 or greater)
   TEL   CN    Must be a valid 10-digit phone number (1000000000 or greater)
   ZIP5  C     Must be a valid 5-digit zip code
   ZIP9  C     Must be a valid 9-digit zip code.  The last 4 digits may be
   blank.

   Character only -

   LSA   C     Leading Spaces Allowed (they are not allowed by default)
   FF    C     Must Fill Field - no trailing spaces

   @     C     Must contain alpha characters only
   #     C     Must contain numeric characters only
   MCOx  C     Must Contain Only the characters represented by x. x can be a
   list of valid characters or one of the following special items:
   @ = A-Z, use @@ for a literal at-sign, @@@ for both.
   # = 0-9, use ## for a literal pound sign, ### for both.
   Don't forget to include a space if they are allowed!
   MNCx  C     Must Not Contain the characters represented by x.  The same
   formatting rules as MCO apply.

   <@    C     First character must be alpha.
   <#    C     First character must be numeric.
   >@    C     Last character must be alpha.
   >#    C     Last character must be numeric.
   <<    C     Leading characters must match one of the values in an array
   passed as Misc1.  How many leading characters is determined by
   the length of the first value in Misc1.
   >>    C     Trailing characters must match one of the values in an array
   passed as Misc2 (so you can use both << and >>).  Works the
   same as << except that the values are passed in Misc2.
   */
   LOCAL lOk := .T.
   LOCAL aEdits_ := {}, nEdits, e
   LOCAL x, y, nLen
   LOCAL cVT := valtype(uVar)
   LOCAL cTemp, uTemp
   LOCAL cMsg := ""

   DEFAULT lMsgs := .T.
   DEFAULT lEmpty := .T.   // Allow things to be empty by default

   // See if Edits is an array or comma delimited string and turn it into the
   // aEdits_ array either way:

   IF valtype(Edits) == "A"
      aEdits_ := aclone(Edits)
   ELSEIF valtype(Edits) == "C"
      e := ","
      IF left(Edits, 1) == "D"            // Different delimiter?
         e := substr(Edits, 2, 1)
         Edits := substr(Edits, 3)
      ENDIF
      DO WHILE (x := at(e, Edits)) > 0
         aadd(aEdits_, left(Edits, x - 1))
         Edits := substr(Edits, x + 1)
      ENDDO
      aadd(aEdits_, Edits)
   ENDIF

   // Check for an empty var:

   IF empty(uVar)
      IF ascan(aEdits_, "NE") > 0 .or. !lEmpty
         IF lMsgs
            MsgAlert("Entry may not be blank")
         ENDIF

         Return(.F.)
      ELSE

         Return(.T.)   // Allowed to be empty, so we're done.
      ENDIF
   ENDIF

   // Check for leading spaces on a character variable:

   IF cVT == "C" .and. ascan(aEdits_, "LSA") == 0
      IF left(uVar, 1) == " "
         IF lMsgs
            MsgAlert("Entry may not contain leading spaces")
         ENDIF

         Return(.F.)
      ENDIF
   ENDIF

   // Check the rest of the edits:

   nEdits := len(aEdits_)

   FOR x := 1 to nEdits

      e := aEdits_[x]

      DO CASE
      CASE e == "$" //----------------------------------------------------- $
         IF ascan(Misc1, uVar) == 0
            lOk := .F.
            cMsg := "Entry must be one of the following: "
            nLen := len(Misc1)
            FOR y := 1 to nLen
               cMsg += Misc1[y] + ", "
            NEXT
            cMsg := left(cMsg, len(cMsg) - 2)
         ENDIF
      CASE e == "!" //----------------------------------------------------- !
         IF ascan(Misc1, uVar) > 0
            lOk := .F.
            cMsg := "Entry must not equal the following value(s): "
            nLen := len(Misc1)
            FOR y := 1 to nLen
               cMsg += Misc1[y] + ", "
            NEXT
            cMsg := left(cMsg, len(cMsg) - 2)
         ENDIF
      CASE e == "R" .and. cVT $ "CDN" //------------------------------- Range
         uTemp := uVar
         // If uVar is character, and Misc1 and/or Misc2 are numeric, compare
         // them as numerics:
         IF cVT == "C" .and. (valtype(Misc1) == "N" .or. valtype(Misc2) == "N")
            uTemp := val(uVar)
         ENDIF
         IF Misc1 <> NIL .and. Misc2 <> NIL
            IF uTemp < Misc1 .or. uTemp > Misc2
               lOk := .F.
               cMsg := "Valid range is " + ;
                  cValToChar(Misc1) + " to " + cValToChar(Misc2)
            ENDIF
         ELSE
            IF Misc1 <> NIL
               IF uTemp < Misc1
                  lOk := .F.
                  cMsg := "Minimum value is " + cValToChar(Misc1)
               ENDIF
            ENDIF
            IF Misc2 <> NIL
               IF uTemp > Misc2
                  lOk := .F.
                  cMsg := "Maximum value is " + cValToChar(Misc2)
               ENDIF
            ENDIF
         ENDIF
      CASE e == "SSN" .and. cVT $ "CN"  //------------------------------- SSN
         cMsg := "Invalid SSN"
         uTemp := uVar
         IF cVT == "C"
            lOk := AllNum(uVar)
            lOk := (len(alltrim(uVar)) == 9)
            uTemp := val(uVar)
         ENDIF
         IF uTemp < 1010001
            lOk := .F.
         ENDIF
      CASE e == "TEL" .and. cVT $ "CN"  //------------------------- Telephone
         cMsg := "Invalid phone number"
         uTemp := uVar
         IF cVT == "C"
            lOk := AllNum(uVar)
            uTemp := val(uVar)
         ENDIF
         IF uTemp < 1000000000
            lOk := .F.
         ENDIF
      CASE cVT <> "C" //--- All of the following apply only to character vars
         LOOP
      CASE e == "DIR" //------------------------------------------- Directory
         cMsg := "Invalid directory"
         #ifdef DOS_ONLY
         lOk := .T. // We have no way to tell...
         #else
         lOk := lIsDir(StripSlash(alltrim(uVar)))
         #endif
      CASE e == "FILE" //----------------------------------------------- File
         IF !GoodFile(uVar)
            cMsg := "Invalid filename"
            lOk := .F.
         ENDIF
      CASE e == "XFILE" //------------------------------------- Existing File
         uTemp := alltrim(uVar)
         IF !file(uTemp)
            cMsg := "File not found: " + uTemp
            lOk := .F.
         ENDIF
      CASE e == "MY" //------------------------------------------------- MMYY
         cMsg := "Invalid MMYY value"
         lOk := AllNum(uVar)
         IF len(uVar) < 4
            lOk := .F.
         ENDIF
         uTemp := val(left(uVar, 2))
         IF uTemp < 1 .or. uTemp > 12
            lOk := .F.
         ENDIF
         uTemp := val(substr(uVar, 3))
         IF uTemp < 0 .or. uTemp > 99
            lOk := .F.
         ENDIF
      CASE e $ "MCY,CYM" //------------------------------------ MMCCYY/CCYYMM
         cMsg := "Invalid MMCCYY value"
         lOk := AllNum(uVar)
         IF len(uVar) < 6
            lOk := .F.
         ENDIF
         uTemp := val(left(uVar, 2))
         IF uTemp < 1 .or. uTemp > 12
            lOk := .F.
         ENDIF
         uTemp := val(substr(uVar, 3))
         IF uTemp < 100 .or. uTemp > 2999
            cMsg := "Valid year range is 0100 to 2999"
            lOk := .F.
         ENDIF
         IF lOk
            IF Misc1 <> NIL .and. Misc2 <> NIL
               IF uTemp < Misc1 .or. uTemp > Misc2
                  cMsg := "Valid year range is " + ltrim(str(Misc1)) + ;
                     " to " + ltrim(str(Misc2))
                  lOk := .F.
               ENDIF
            ELSE
               IF Misc1 <> NIL
                  IF uTemp < Misc1
                     cMsg := "Minimum year is " + ltrim(str(Misc1))
                     lOk := .F.
                  ENDIF
               ENDIF
               IF Misc2 <> NIL
                  IF uTemp > Misc2
                     cMsg := "Maximum year is " + ltrim(str(Misc2))
                     lOk := .F.
                  ENDIF
               ENDIF
            ENDIF
         ENDIF
      CASE e $ "ZIP5,ZIP9" //-------------------------------------- Zip Codes
         cMsg := "Invalid zip code"
         cTemp := alltrim(left(uVar, 5))
         lOk := AllNum(cTemp)
         IF val(cTemp) == 0 .or. len(cTemp) < 5
            lOk := .F.
         ENDIF
         IF lOk .and. e == "ZIP9"
            cTemp := alltrim(right(uVar, 4))
            IF !empty(cTemp)
               lOk := AllNum(cTemp) .and. len(cTemp) == 4
            ENDIF
         ENDIF
      CASE e == "FF" //-------------------------------------- Must Fill Field
         IF right(uVar, 1) == " "
            lOk := .F.
            cMsg := "Entry may not have trailing spaces"
         ENDIF
      CASE e == "@" //-------------------------------------------- Alpha only
         cMsg := "Entry must contain only alpha characters"
         cTemp := alltrim(uVar)
         nLen := len(cTemp)
         FOR y := 1 to nLen
            IF !IsAlpha(substr(cTemp, y, 1))
               lOk := .F.
               EXIT
            ENDIF
         NEXT
      CASE e == "#" //------------------------------------------- Digits only
         cMsg := "Entry must contain only numeric digits"
         lOk := AllNum(uVar)
      CASE left(e, 3) == "MCO" //-------------------------- Must Contain Only
         IF FindBad(uVar, substr(e, 4), .F., lMsgs)
            lOk := .F.
            EXIT  // Does its own message
         ENDIF
      CASE left(e, 3) == "MNC" //--------------------------- Must Not Contain
         IF FindBad(uVar, substr(e, 4), .T., lMsgs)
            lOk := .F.
            EXIT  // Does its own message
         ENDIF
      CASE e == "<@" //------------------------------------------ First Alpha
         IF !IsAlpha(uVar)
            lOk := .F.
            cMsg := "First character must be alpha"
         ENDIF
      CASE e == "<#" //------------------------------------------ First Digit
         IF !IsDigit(uVar)
            lOk := .F.
            cMsg := "First character must be a digit"
         ENDIF
      CASE e == ">@" //------------------------------------------- Last Alpha
         IF !IsAlpha(right(alltrim(uVar), 1))
            lOk := .F.
            cMsg := "Last character must be alpha"
         ENDIF
      CASE e == ">#" //------------------------------------------- Last Digit
         IF !IsDigit(right(alltrim(uVar), 1))
            lOk := .F.
            cMsg := "Last character must be a digit"
         ENDIF
      CASE e == "<<" //------------------------------------- First Characters
         cTemp := left(uVar, len(Misc1[1]))
         IF ascan(Misc1, cTemp) == 0
            lOk := .F.
            cMsg := "Entry must start with "
            nLen := len(Misc1)
            FOR y := 1 to nLen
               cMsg += Misc1[y] + ", "
            NEXT
            cMsg := left(cMsg, len(cMsg) - 2)
         ENDIF
      CASE e == ">>" //-------------------------------------- Last Characters
         cTemp := right(alltrim(uVar), len(Misc2[1]))
         IF ascan(Misc2, cTemp) == 0
            lOk := .F.
            cMsg := "Entry must end with "
            nLen := len(Misc2)
            FOR y := 1 to nLen
               cMsg += Misc2[y] + ", "
            NEXT
            cMsg := left(cMsg, len(cMsg) - 2)
         ENDIF
      ENDCASE

      IF !lOk
         IF lMsgs
            MsgAlert(cMsg)
         ENDIF
         EXIT
      ENDIF

   NEXT

   Return(lOk)

STATIC FUNCTION FindBad(uVar, cChars, lNotAllowed, lMsgs)

   LOCAL x, a, c, cTemp, nLen
   LOCAL lBad := .F.
   LOCAL cFind := ""

   // Parse cChars to get list of valid/invalid characters:

   cTemp := upper(cChars)
   nLen := len(cTemp)

   FOR x := 1 to nLen
      c := substr(cTemp, x, 1)
      IF c == "@"
         IF substr(cTemp, x + 1, 1) == c       // Is this a literal?
            cFind += c
            x++
         ELSE                                  // Nope - add alpha characters
            cFind += "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
         ENDIF
      ELSEIF c == "#"
         IF substr(cTemp, x + 1, 1) == c       // Is this a literal?
            cFind += c
            x++
         ELSE                                  // Nope - add digits
            cFind += "1234567890"
         ENDIF
      ELSE                                    // Regular character
         cFind += c
      ENDIF
   NEXT

   // Go through the input and look for characters in cFind:

   cTemp := upper(alltrim(uVar))
   nLen := len(cTemp)

   FOR x := 1 to nLen
      c := substr(cTemp, x, 1)
      a := at(c, cFind)
      IF lNotAllowed
         IF a > 0                              // Found and not allowed?
            lBad := .T.
            EXIT
         ENDIF
      ELSEIF a == 0                           // Not found and needs to be?
         lBad := .T.
         EXIT
      ENDIF
   NEXT

   // If a bad character was found, identify it:

   IF lBad .and. lMsgs
      IF c == " "
         MsgAlert("Entry may not contain spaces")
      ELSE
         MsgAlert("Invalid character in position " + ltrim(str(x)) + ": " + c)
      ENDIF
   ENDIF

   Return(lBad)

FUNCTION GoodFile(cFile)

   /*

   Returns a logical indicating whether the given filename is valid or not.
   Passing an empty filename will return false.
   If the file exists, the function returns true.
   If the file can be CREATED, the function returns true.
   */
   LOCAL h, lOk := .F.

   IF file(cFile)
      lOk := .T.
   ELSE
      IF (h := fcreate(cFile)) <> F_ERROR
         fclose(h)
         ferase(cFile)
         lOk := .T.
      ENDIF
   ENDIF

   Return(lOk)

