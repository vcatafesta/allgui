/*******************************************************************************
Filename      : Repint.prg

Created         : 17 November 2011 (12:00:20)
Created by      : Pierpaolo Martinello

Last Updated   : 22 May 2015
Updated by      : Pierpaolo

Comments      :
*******************************************************************************/
#ifndef __CALLDLL__
#define __CALLDLL__
#endif
#include 'minigui.ch'
#include 'winprint.ch'
#include "hbdyn.ch"

#define FR_PRIVATE     0x10
#define FR_NOT_ENUM    0x20

REQUEST __objSetClass

MEMVAR aPrinters, aports
MEMVAR tagged, asay, oWr, _HMG_MINIPRINT
MEMVAR valore, AHEAD, ABody, lstep, nline

/*
*/

PROCEDURE main()

   PRIVATE aPrinters, aports

   AddFont()

   INIT PRINTSYS
   GET PRINTERS TO aprinters
   GET PORTS TO aports
   RELEASE PRINTSYS

   DEFINE WINDOW F1 ;
         AT 10,10 ;
         WIDTH 545 HEIGHT 300 ;
         TITLE 'Report Interpreter Demo' ;
         ICON 'PRINT' ;
         MAIN ;
         FONT 'Arial' SIZE 10 ;
         ON RELEASE RemoveFont()

      ON KEY ESCAPE ACTION exit()

      DEFINE STATUSBAR
         STATUSITEM '[x] Harbour Power Ready!'
      END STATUSBAR

      @5 ,5   BUTTON Button_1 CAPTION '&Two Db'  ACTION  {||print(1),f1.button_1.setfocus} Tooltip "See Bolla.mod" default
      @5 ,110 BUTTON Button_2 CAPTION '&Fantasy' ACTION  {||print(2),f1.button_2.setfocus} Tooltip "See ReportF.mod"
      @5 ,215 BUTTON Button_3 CAPTION '&Group' ACTION  {||print(3),f1.button_3.setfocus} Tooltip "See ReportG.mod"
      @5 ,320 BUTTON Button_4 CAPTION '&Simple (mm)' ACTION  {||print(4),f1.button_4.setfocus} Tooltip "See ReportS.mod"
      @5 ,425 BUTTON Button_5 CAPTION '&Miniprint (mm)' ACTION  {||print(5),f1.button_5.setfocus} Tooltip "See ReportM.mod"
      @50,5   BUTTON Button_6 CAPTION '&2PageS/Recno' ACTION  {||print(6),f1.button_6.setfocus} Tooltip "See ReportD.mod"
      @50,110 BUTTON Button_7 CAPTION '&Labels' ACTION  {||print(7),f1.button_7.setfocus} Tooltip "See ReportL.mod"
      @50,215 BUTTON Button_8 CAPTION '&Array' ACTION  {||print(9),f1.button_8.setfocus} Tooltip "See ReportA.mod"
      @50,320 BUTTON Button_9 CAPTION '&Pdf (mm)' ACTION  {||print(8),f1.button_9.setfocus} Tooltip "See ReportP.mod"
      @50,425 BUTTON Button_10 CAPTION '&Unified' ACTION {||print(10),f1.button_10.setfocus} Tooltip [See Unified.mod "One script 3 drivers"]

      @100,10  LISTBOX L1 WIDTH 250 HEIGHT 100 ITEMS aprinters
      @100,270 LISTBOX L2 WIDTH 250 HEIGHT 100 ITEMS aports

      @210,160 LABEL LB1 VALUE "Available Printers and Ports" autosize
      @210,425 BUTTON Button_11 CAPTION '&QUIT' ACTION {|| exit()}

   END WINDOW

   CENTER WINDOW F1

   ACTIVATE WINDOW F1

   RETURN
   /*
   */

FUNCTION print(arg1)

   LOCAL atag := {2,3,4}, afld:= {"First","Last","Birth" }, afldn:={"Simple","Apellido","Nato"}
   LOCAL choice := 0, aDrv:={[HBPRINTER],[MINIPRINT],[PDFPRINT]}

   PRIVATE tagged, asay :={}

   IF arg1=1
      SELE 1
      USE CLIENTI ALIAS CLIENTI
      INDEX ON Field->CLIENTE to CLIENTI

      SELE 2
      USE PRGB2003 ALIAS PROGRB
      INDEX ON Field->N_DOC to NPROG
      SET filter to Field->n_doc < 3

      SELE 3
      USE bdyb2003 ALIAS BOLLE
      INDEX ON Field->N_DOC to NBOLLE
      choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," Unified Commands Demo",1)

      IF choice = 0

         RETURN NIL
      ENDIF

      WinREPINT("Bolla.mod","Bolle",NIL,"PROGRB->n_doc",,,aDRV[choice])

   ELSE
      USE test shared
      // make an array
      DBEval( {|| aadd(asay,{fieldget(1),hb_valtostr(fieldget(2)),fieldget(4),fieldget(7)})},,,,, .F. )

      INDEX ON Field->first to lista

      dbgotop()
      DO CASE
      CASE arg1 = 2

         WinREPINT("ReportF.mod","TEST",,,,,aDRV[1])

      CASE arg1 = 3
         WinREPINT("ReportG.mod","TEST",)

      CASE arg1 = 4
         tagged := tagit(atag,aFld ,afldN ,"Make your choice!",,,580,580 )
         IF len(tagged) > 0
            SET filter to ascan(tagged,recno()) > 0
            WinREPINT("ReportS.mod","TEST")
            SET filter to
         ELSE
            msgExclamation("No choice from user !!!","Print Aborted.")
         ENDIF

      CASE arg1 = 5
         WinREPINT("ReportM.mod","TEST",)

      CASE arg1 = 6
         tagged := {33,34,35,36,37,38,39,40,41,42}
         SET filter to ascan(tagged,recno()) > 0
         WinREPINT("ReportD.mod","TEST",)
         SET filter to

      CASE arg1 = 7
         choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," WinReport Demo",1)

         IF choice = 0

            RETURN NIL
         ENDIF
         WinREPINT("ReportL.mod","TEST",nil,nil,,,aDRV[choice])

      CASE arg1 = 8
         choice := Scegli({"As Miniprint","Generic features (unusual use!)"},"Example choice"," WinReport Pdf Demo",1)

         SWITCH choice
         CASE 0
            EXIT
         CASE 1
            WinREPINT("ReportP.mod","TEST",)
            EXIT
         CASE 2
            WinREPINT("ReportPG.mod","TEST",)
         END SWITCH

      CASE arg1 = 9
         dbclosearea()
         WinREPINT("ReportA.mod",asay)

      CASE arg1 = 10
         choice := Scegli({"Use Hbprinter","use Miniprint","Use PdfPrint"},"Driver choice"," Unified Commands Demo",1)

         IF choice = 0

            RETURN NIL
         ENDIF

         WinREPINT("Unified.mod","TEST",,,,,aDRV[choice])

      ENDCASE
   ENDIF
   RELEASE tagged

   RETURN NIL

FUNCTION Page2(row,col,argm1,argl1,argcolor1)

   LOCAL _Memo1:=argm1, mrow := mlcount(_memo1,argl1), arrymemo:={}
   LOCAL units := hbprn:UNITS, k, mcl , argcolor

   DEFAULT col to 0, row to nline, argl1 to 10
   argcolor := oWr:UsaColor(argcolor1)
   FOR k := 1 to mrow
      aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
   NEXT
   oWr:TheFeet()
   IF oWr:prndrv = "MINI"
      oWr:TheMiniHead()
   ELSE
      oWr:TheHead()
   ENDIF
   IF len(arrymemo) > 0
      nline := row
      FOR mcl := 1 to len(arrymemo)
         IF nline >= oWr:HB -1
            oWr:TheFeet()
            IF oWr:prndrv = "MINI"
               oWr:TheMiniHead()
            ELSE
               oWr:TheHead()
            ENDIF
         ENDIF
         IF oWr:prndrv = "MINI"
            // @ lstep*nline,col PRINT arrymemo[mcl] FONT "ARIAL" SIZE 10 color argcolor
            _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , lstep*nline , col ;
               , "ARIAL" , 10 , argcolor[1] , argcolor[2] , argcolor[3] ;
               , arrymemo[mcl] , .F. , .F. , .F. , .F. , .T. , .T. , .T. , )
         ELSE
            hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[mcl],'Fx',argcolor)
         ENDIF
         nline ++
      NEXT
      oWr:TheFeet()
      IF oWr:prndrv = "MINI"
         oWr:TheMiniHead()
      ELSE
         oWr:TheHead()
      ENDIF
   ENDIF

   RETURN NIL

   /*
   */

FUNCTION exit()

   CLOSE databases
   RELEASE WINDOW all

   RETURN NIL
   /*
   */

FUNCTION what(calias, Checosa, nindexorder,ritorna,sync)

   LOCAL px
   LOCAL retval
   LOCAL ncurrentpos := recno()             // position of original file
   LOCAL noldorder   := indexord()          // original file index order
   LOCAL ntargetpos  := (calias)->(recno()) // position of target file
   LOCAL OLD_AREA    := ALIAS()

   DEFAULT sync to .f.

   IF nindexorder == nil
      nindexorder := 1
   ENDIF

   dbSelectArea( calias )
   (calias)->(dbsetorder(nindexorder))     // set index order
   IF (calias)->(dbseek(Checosa)) .and. !empty(checosa)
      IF valtype(ritorna)="C"
         retval := (calias)->(fieldget(fieldpos(ritorna)))
      ELSEIF valtype(ritorna)="A"
         retval:={}
         FOR px = 1 to len(ritorna)
            aadd(retval,(calias)->(fieldget(fieldpos(ritorna[px]))))
         NEXT px
      ENDIF
   ELSE
      IF valtype(ritorna)="C"
         retval :=azzera((calias)->(fieldget(fieldpos(ritorna))))
      ELSEIF valtype(ritorna)="A"
         retval:={}
         FOR px = 1 to len(ritorna)
            aadd(retval,azzera((calias)->(fieldget(fieldpos(ritorna[px])))))
         NEXT px
      ENDIF
      sync := .f.
   ENDIF
   IF !sync
      (calias)->(dbgoto(ntargetpos))       // reposition target file
      (calias)->(dbsetorder(noldorder))    // restore index order
      dbSelectArea( OLD_AREA )
      dbgoto(ncurrentpos)                  // reposition original file
   ENDIF

   RETURN retval
   /*
   */

FUNCTION azzera(y_campo)

   LOCAL ritorno

   DO CASE
   CASE valtype(y_campo) = "C"
      ritorno:= space(len(y_campo))
   CASE valtype(y_campo) = "D"
      ritorno:= ctod("")
   CASE valtype(y_campo) = "N"
      ritorno:= 0
   CASE valtype(y_campo) = "L"
      ritorno:= .f.
   CASE valtype(y_campo) = "M"
      ritorno:= ''
   ENDCASE

   RETURN ritorno

   #include "S_Mchoice.prg"

STATIC FUNCTION AddFont

   LOCAL nRet := AddFontResourceEx("FREE3OF9.ttf",FR_PRIVATE+FR_NOT_ENUM,0)

   IF nRet == 0
      MsgStop("An error is occured at installing of font FREE3OF9.ttf.","Warning")
   ENDIF

   RETURN NIL

STATIC FUNCTION RemoveFont

   LOCAL lRet := RemoveFontResourceEx("FREE3OF9.ttf",FR_PRIVATE+FR_NOT_ENUM,0)

   IF lRet == .F.
      MsgStop("An error is occured at removing of font FREE3OF9.ttf.","Warning")
   ENDIF

   RETURN NIL

   DECLARE HB_DYN_CTYPE_INT AddFontResourceEx ( lpszFilename, fl, pdv ) IN GDI32.DLL
   DECLARE HB_DYN_CTYPE_BOOL RemoveFontResourceEx ( lpFileName, fl, pdv ) IN GDI32.DLL
   /*
   */

FUNCTION Scegli(opt,title,note,def)

   LOCAL r:= 0, S_HG := 0

   DEFAULT title to "Scelta stampe", opt to {"Questa Scheda","Tutte"}
   DEFAULT note to "", def to 1
   note := space(10)+ note
   s_hg := len (opt)*25 + 125

   DEFINE WINDOW SCEGLI AT 140 , 235 WIDTH 286 HEIGHT S_hg TITLE "Azzeramento Flag" ;
         ICON NIL MODAL NOSIZE NOSYSMENU CURSOR NIL ;
         ON INIT Load_Scegli_base(title,def) ;

      DEFINE STATUSBAR FONT "Arial" SIZE 9 BOLD
         STATUSITEM note
      END STATUSBAR

      DEFINE RADIOGROUP RadioGroup_1
         ROW    11
         COL    21
         WIDTH  230
         HEIGHT 59
         OPTIONS OPT
         VALUE 1
         FONTNAME "Arial"
         FONTSIZE 9
         SPACING 25
      END RADIOGROUP

      DEFINE BUTTONEX Button_1
         ROW    S_HG - 105
         COL    20
         WIDTH  100
         HEIGHT 40
         PICTURE "Minigui_EDIT_OK"
         CAPTION _HMG_aLangButton[8]
         ACTION  ( r:= Scegli.RadioGroup_1.value ,Scegli.release)
         FONTNAME  "Arial"
         FONTSIZE  9
      END BUTTONEX

      DEFINE BUTTONEX Button_2
         ROW    S_Hg - 105
         COL    160
         WIDTH  100
         HEIGHT 40
         PICTURE "Minigui_EDIT_CANCEL"
         CAPTION _HMG_aLangButton[7]
         ACTION   Scegli.release
         FONTNAME  "Arial"
         FONTSIZE  9
      END BUTTONEX

   END WINDOW

   Scegli.center
   Scegli.activate

   RETURN r
   /*
   */

PROCEDURE load_Scegli_base(title,def)

   ON KEY RETURN OF SCEGLI ACTION ( SCEGLI.BUTTON_1.SETFOCUS, _PUSHKEY( VK_SPACE ) )
   escape_on('Scegli')
   Scegli.Title := Title
   Scegli.RadioGroup_1.value := def

   RETURN
   /*
   */

PROCEDURE ESCAPE_ON(ARG1)

   LOCAL WinName:=if(arg1==NIL,procname(1),arg1)

   IF upper(WinName)<>'OFF'
      _definehotkey(arg1,0,27,{||_releasewindow(arg1)})
   ELSE
      ON KEY ESCAPE ACTION nil
   ENDIF

   RETURN
