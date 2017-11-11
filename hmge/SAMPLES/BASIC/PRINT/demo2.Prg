/*
MINIGUI - Harbour Win32 GUI library Demo/Sample

Copyright 2002-09 Roberto Lopez <harbourminigui@gmail.com>
http://harbourminigui.googlepages.com/
*/

#include <minigui.ch>
#include "miniprint.ch"

//============================================================================================

FUNCTION Main()

   LOCAL myPrinters:=aPrinters(), lPreview:=.F.
   LOCAL aPapers:={ PRINTER_PAPER_LETTER ,;
      PRINTER_PAPER_LEGAL,;
      PRINTER_PAPER_A4,;
      PRINTER_PAPER_CSHEET,;
      PRINTER_PAPER_DSHEET,;
      PRINTER_PAPER_ESHEET,;
      PRINTER_PAPER_LETTERSMALL,;
      PRINTER_PAPER_TABLOID,;
      PRINTER_PAPER_LEDGER,;
      PRINTER_PAPER_EXECUTIVE }

   LOCAL papers_to_select:={ "Letter, 8 1/2- by 11-inches",;
      "Legal, 8 1/2- by 14-inches",;
      "A4 Sheet, 210- by 297-millimeters",;
      "C Sheet, 17- by 22-inches",;
      "D Sheet, 22- by 34-inches",;
      "E Sheet, 34- by 44-inches",;
      "Letter Small, 8 1/2- by 11-inches",;
      "Tabloid, 11- by 17-inches",;
      "Ledger, 17- by 11-inches",;
      "Executive, 7 1/4- by 10 1/2-inches" }

   LOAD WINDOW demo2 As Main
   Main.Combo_Printers.Value:=1
   Main.Combo_Papers.Value:=1
   Main.preview_not_yes.Value:=lPreview
   Main.RadioGroup_1.Value:=1
   Main.Combo_Printers.SetFocus
   Main.Center
   Main.Activate

   RETURN NIL
   //============================================================================================

FUNCTION printers_filter()

   LOCAL k, newPrinters:={}, combo_item

   IF Main.Check_1.Value
      IF Main.Combo_Printers.ItemCount > 0
         FOR k:=1 to Main.Combo_Printers.ItemCount
            combo_item:=Main.Combo_Printers.Item(k)
            IF Left(combo_item,2) <> "\\"
               AADD(newPrinters,combo_item)
            ENDIF
         NEXT k
         IF Len(newPrinters) <= 0
            MsgExclamation("No Local Printers Installed in this System !!")
         ENDIF
      ELSE
         MsgExclamation("No printers Installed !!")
      ENDIF
   ELSE
      newPrinters:=aPrinters()
   ENDIF
   IF Len(newPrinters) > 0
      Main.Combo_Printers.DeleteAllItems
      FOR k:=1 to Len(newPrinters)
         Main.Combo_Printers.AddItem(newPrinters[k])
      NEXT k
      Main.Combo_Printers.Value:=1
   ELSE
      MsgExclamation("No printers Installed !!")
   ENDIF
   Main.Combo_Printers.SetFocus

   RETURN NIL
   //============================================================================================

FUNCTION _Print_My_Job(xPaper)

   LOCAL lSuccess, myDataToPrint:={}, i, k, lResponse:=.T., zLine
   LOCAL wPrinter:=Alltrim(Main.Combo_Printers.Item(Main.Combo_Printers.Value)), docName:="Print test"

   IF Main.Combo_Printers.Value <=0 .OR. Main.Combo_Printers.Value == Nil
      MsgExclamation("Please, select a valid printer !!")
      Main.Combo_Printers.SetFocus

      RETURN NIL
   ENDIF

   FOR k:=1 to 10
      AADD( myDataToPrint, "This is My Print Job - Line "+StrZero(k,2) )
   NEXT k

   IF Main.preview_not_yes.Value == .F.
      PlayBeep()
      lresponse:=MsgYesNo("Are you sure that you want to print this job ??","Confirm Please")
   ENDIF

   IF lresponse == .F.
      Main.Combo_Printers.SetFocus

      RETURN NIL
   ENDIF

   IF Main.preview_not_yes.Value == .F.
      SELECT PRINTER wPrinter TO lSuccess;
         ORIENTATION Main.RadioGroup_1.Value;
         PAPERSIZE xPaper[Main.Combo_Papers.Value];
         DEFAULTSOURCE PRINTER_BIN_AUTO;               // Select your own Paper Source
      QUALITY PRINTER_RES_MEDIUM                  // Select your own print quality
   ELSE
      SELECT PRINTER wPrinter TO lSuccess PREVIEW;
         ORIENTATION Main.RadioGroup_1.Value;
         PAPERSIZE xPaper[Main.Combo_Papers.Value];
         DEFAULTSOURCE PRINTER_BIN_AUTO;               // Select your own Paper Source
      QUALITY PRINTER_RES_MEDIUM                  // Select your own print quality
   ENDIF

   IF lSuccess == .F.
      MsgStop("Print Error !", "Stop")
      Main.Combo_Printers.SetFocus

      RETURN NIL
   ENDIF

   START PRINTDOC NAME docName

      FOR i:=1 to 10

         zLine:=20

         START PRINTPAGE

            @zLine-7,180 PRINT "Page Number : " + Ltrim(Str(i)) ;
               FONT "Arial" SIZE 09 RIGHT

            FOR k:=1 to Len(myDataToPrint)
               @zLine,030 PRINT myDataToPrint[k] ;
                  FONT "Arial" SIZE 10 COLOR BLACK

               zLine += 7
            NEXT k

         END PRINTPAGE

      NEXT i

   END PRINTDOC

   RETURN NIL
   //============================================================================================

