#include "cldbfix.ch"

REQUEST DBFCDX
REQUEST SIXCDX
REQUEST HB_GT_WIN_DEFAULT

FUNCTION Main(cDbf, o1, o2, o3, o4, o5)

   LOCAL aArgs_ := {}
   LOCAL cTemp, cOpt, cValue
   LOCAL c, i, j
   LOCAL cLog, cDonor, cRDD, cJunkChar
   LOCAL lUpper, lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk

   IF empty(cDbf)
      Usage()

      Return(NIL)
   ENDIF

   IF !file(cDbf)
      Usage("Repair file not found: " + cDbf)

      Return(NIL)
   ENDIF

   // Default options:
   cLog      := ""
   cDonor    := ""
   cRDD      := "SIXCDX"
   cJunkChar := "?"
   lPreload  := .F.
   lDeleted  := .F.
   lPartial  := .T.
   lTotal    := .T.
   lCharJunk := .T.
   lMemoJunk := .T.

   // Gather the command line parameters into an array:
   IF !empty(o1)
      aadd(aArgs_, o1)
   ENDIF
   IF !empty(o2)
      aadd(aArgs_, o2)
   ENDIF
   IF !empty(o3)
      aadd(aArgs_, o3)
   ENDIF
   IF !empty(o4)
      aadd(aArgs_, o4)
   ENDIF
   IF !empty(o5)
      aadd(aArgs_, o5)
   ENDIF

   // Parse the various options from the command line:
   FOR i := 1 to len(aArgs_)
      cTemp := aArgs_[i]
      j := at(":", cTemp)
      IF j <> 2
         Usage("Unrecognized argument: " + cTemp)

         Return(NIL)
      ENDIF
      cOpt := left(cTemp, 1)
      cValue := substr(cTemp, 3)
      DO CASE
      CASE cOpt == "L" // Log file
         cLog := cValue
      CASE cOpt == "D" // Donor file
         cDonor := cValue
      CASE cOpt == "R" // RDD
         cRDD := cValue
      CASE cOpt == "J" // Junk replacement character
         cJunkChar := cValue
      CASE cOpt == "O" // Options
         FOR j := 1 to len(cValue)
            c := substr(cValue, j, 1)
            lUpper := c == upper(c)
            c := upper(c)
            DO CASE
            CASE c == "L"
               lPreload := lUpper
            CASE c == "D"
               lDeleted := lUpper
            CASE c == "P"
               lPartial := lUpper
            CASE c == "T"
               lTotal := lUpper
            CASE c == "C"
               lCharJunk := lUpper
            CASE c == "M"
               lMemoJunk := lUpper
            OTHERWISE
               Usage("Unrecognized option: " + c)

               Return(NIL)
            ENDCASE
         NEXT
      OTHERWISE
         Usage("Unrecognized argument: " + cTemp)

         Return(NIL)
      ENDCASE
   NEXT // aArgs_

   // Make sure the options we got are valid:
   IF !file(cDbf)
      Usage("Repair file not found: " + cDbf)

      Return(NIL)
   ENDIF

   IF !empty(cDonor) .and. !file(cDonor)
      Usage("Donor file not found: " + cDonor)

      Return(NIL)
   ENDIF

   IF at("/" + cRDD + "/", "/DBFIV/DBFMDX/DBF/DBFNDX/DBFNTX/SIXCDX/DBFCDX/") = 0
      Usage("Unrecognised RDD: " + cRDD)

      Return(NIL)
   ENDIF

   IF lTotal
      lPartial := lTotal
   ENDIF

   // OK! Let 'er rip!

   DBRepair(cDbf, cLog, cDonor, cRDD, cJunkChar, ;
      lPreload, lDeleted, lPartial, lTotal, lCharJunk, lMemoJunk)

   Return(NIL)

STATIC FUNCTION Usage(cError)

   IF !empty(cError)
      ? cError
      ?
   ENDIF

   //"12345678901234567890123456789012345678901234567890123456789012345678901234567890"
   ? "CLDBFIX v" + DBFIX_VERSION + " Syntax:"
   ?
   ? "CLDBFIX damaged.dbf [L:log.txt] [D:donor.dbf] [R:RDD] [J:?] [O:LDPTCM]"
   ?
   ? "If a log file is not specified, log output goes to the screen."
   ?
   ? "The default RDD is SIXCDX.  Change this with the R: option if needed."
   ?
   ? "The J: option specifies the junk replacement character, either as a single"
   ? "character or a three-digit ASCII code.  (Default=?)"
   ?
   ? "The O: options toggle based on case:  upper=ON  lower=OFF"
   ? " L = preLoad memos (default=OFF)"
   ? " D = save Deleted records (default=OFF)"
   ? " P = save Partially damaged records (default=ON)"
   ? " T = save Totally damaged records (default=ON)"
   ? " C = allow junk in Character fields (default=ON)"
   ? " M = allow junk in Memo fields (default=ON)"
   ?
   //"12345678901234567890123456789012345678901234567890123456789012345678901234567890"

   Return(NIL)
