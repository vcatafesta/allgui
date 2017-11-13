// Created By Pierpaolo Martinello Italy
// Part of this Program is made by Bicahi Esgici <esgici@gmail.com>

#include 'minigui.ch'
#include 'winprint.ch'
#include 'miniprint.ch'
#include "hbclass.ch"
#include "BosTaurus.ch"

#include "hbwin.ch"
#include "hbzebra.ch"
#require "hbzebra"

#define MGSYS  .F.

#define MB_ICONEXCLAMATION 0x30
#define MB_OK 0
#define MB_ICONINFORMATION 64
#define MB_ICONSTOP 16
#define MB_OKCANCEL 1
#define MB_RETRYCANCEL 5
#define MB_SETFOREGROUND 0x10000
#define MB_SYSTEMMODAL 4096
#define MB_TASKMODAL 0x2000
#define MB_YESNO 4
#define MB_YESNOCANCEL 3

#ifndef __XHARBOUR__
/* FOR EACH hb_enumIndex() */
#xtranslate hb_enumIndex( <!v!> ) => <v>:__enumIndex()
#endif
#translate MSG   => MSGBOX
#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#translate ZAPS(<X>) => NTrim(<X>)
#translate Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, , , .F. )
#define MsgAlert( c ) MsgEXCLAMATION( c, , , .F. )
#define MsgStop( c ) MsgStop( c, , , .F. )

MEMVAR endof_file, separator, atf
MEMVAR An_Vari, aend
MEMVAR Atutto, Anext, Aivarpt, ActIva, nomevar
MEMVAR _aFnt,ritspl,abort
MEMVAR last_pag
MEMVAR string1
MEMVAR start
MEMVAR LStep
MEMVAR Cstep
MEMVAR pagina
MEMVAR format
MEMVAR _money
MEMVAR _separator
MEMVAR _euro
MEMVAR atr
MEMVAR vsect
MEMVAR epar
MEMVAR vpar
MEMVAR chblk,chblk2
MEMVAR chkArg
MEMVAR oneatleast, shd, sbt, sgh,insgh
MEMVAR gcounter
MEMVAR counter
MEMVAR gcdemo
MEMVAR grdemo

MEMVAR align
MEMVAR GHstring, GFstring, GTstring
MEMVAR GField
MEMVAR s_head, TTS
MEMVAR s_col, t_col, wheregt
MEMVAR gftotal, Gfexec, s_total
MEMVAR nline
MEMVAR nPag, nPgr, Tpg
MEMVAR eLine, GFline
MEMVAR maxrow, maxcol, mncl, mxH
MEMVAR flob, mx_pg

MEMVAR query_exp
MEMVAR __arg1, __arg2
MEMVAR xlwh,xfo,xfc,xbr,xpe,xwa,xbmp
MEMVAR oWr
MEMVAR _HMG_HPDFDATA

/*
*/

FUNCTION WinRepInt(filename,db_arc,_NREC,_MainArea,_psd,_prw,drv)

   LOCAL ritorna:=.t., handle, n, n_var, x_exact := set(1)
   LOCAL str1:="", Vcb:='', lcnt:=0, a1:=0, a2:=0, al:=0, L1:=.F., L2:=.F.
   LOCAL _object_ := '', Linea, sezione, cWord
   PRIVATE endof_file
   PUBLIC SEPARATOR := [/], atf := ''

   DEFAULT db_arc to dbf(), _nrec to 0, _MainArea to ""
   DEFAULT _prw to .F. , drv to ""

   SET( _SET_DELETED , TRUE )
   SET CENTURY ON
   // SET EPOCH TO Year(Date()) - 50

   // init of object conversion
   PUBLIC oWr   := WREPORT()

   oWr:New()
   oWr:argm     := {_MainArea,_psd,db_arc,_prw}
   oWr:filename := filename
   // Pdf
   PUBLIC _HMG_HPDFDATA := Array( 1 )

   IF valtype(_nrec)== "C"
      atf :=_nrec
      oWr:nrec := 1
   ELSE
      oWr:nrec := _nrec
   ENDIF

   *- check for file's existence
   IF empty(filename) .or. !file(filename)
      _object_ := valtype(filename)
      msgstop([Warning...]+CRLF+[Report not found ]+IF(_object_=="C",': "'+Filename+'"','!')+CRLF+[The type of argument is: ]+_object_,'')
      ritorna:=.F.
   ELSEIF !file(filename)
      MsgT(2,[Warning...]+CRLF+[The file "]+FILENAME+[" not exist!!!],,"STOP")
      ritorna:=.F.
   ENDIF
   IF ritorna
      *- open the file, check for errors
      handle := FOPEN(filename,64)
      IF Ferror() <> 0
         msg("Error opening file : "+filename)
         ritorna := .F.
      ENDIF

      *- not at the end of file
      endof_file := .F.
   ENDIF
   IF ritorna
      PRIVATE An_Vari  :={}, aend  :={}
      PRIVATE Atutto   :={},Anext    :={},Aivarpt  :={},ActIva:={} , nomevar:={}
      PRIVATE _aFnt    :={}

      PRIVATE string1  := ''
      PRIVATE start    := ''

      _object_         := ''
      PRIVATE LStep    := 25.4 / 6          // 1/6 of inch
      PRIVATE Cstep    := 0
      PRIVATE pagina   := 1
      PRIVATE Format   := {}
      PRIVATE _money   :=.F.
      PRIVATE _separator:=.T.           // Messo a vero per comodit‡ sui conti
      PRIVATE _euro    := .T.           // Messo a vero per l'Europa
      PRIVATE atr      :=.T.

      // valore := {|x|val(substr(x[1],at("]",x[1])+1))}

      *- for < of lines allowed in box

      DO WHILE !endof_file
         Linea := oWr:fgetline(handle)
         IF left(linea,1)=="["
            sezione := [A]+upper(substr(linea,2,AT("]", linea)-2))
            oWr:aStat[ 'Define' ] := .F.
            oWr:aStat[ 'Head' ]   := .F.
            oWr:aStat[ 'Feet' ]   := .F.
            oWr:aStat[ 'Body' ]   := .F.
            //aadd(&sezione,linea)

            DO CASE
            CASE sezione == "ADECLARE"
               oWr:aStat[ 'Define' ] := .T.

            CASE sezione == "AHEAD"
               oWr:aStat[ 'Head' ]   := .T.

            CASE sezione == "ABODY"
               oWr:aStat[ 'Body' ]   := .T.

            CASE sezione == "AFEET"
               oWr:aStat[ 'Feet' ]   := .T.

            CASE sezione == "AEND"
               oWr:aStat[ 'Head' ]   := .F.
               oWr:aStat[ 'Feet' ]   := .F.
               oWr:aStat[ 'Body' ]   := .F.

            ENDCASE
         ELSEIF left(linea,1) == "!"
            cWord := upper(left(linea,10))
            DO CASE
            CASE cWord == "!MINIPRINT"
               oWr:prndrv := "MINI"

            CASE cWord == "!PDFPRINT"
               oWr:prndrv := "PDF"

            OTHERWISE
               oWr:prndrv := "HBPR"
            ENDCASE
            cWord := ''
         ENDIF
         DO CASE
         CASE Drv = "HBPR"
            oWr:prndrv := "HBPR"

         CASE Drv = "MINI"
            oWr:prndrv := "MINI"

         CASE Drv = "PDF"
            oWr:PrnDrv := "PDF"
         ENDCASE
         lcnt ++
         tokeninit(LINEA,";")       //set the command separator -> ONLY A COMMA /
         DO WHILE .NOT. tokenend()  //                             _____
            cWord := alltrim(tokennext(LINEA))
            //MSG(CWORD,[CWORD])
            _object_ := eval(oWr:aStat [ 'TrSpace' ], CWORD, .t., lcnt)
            // msg(cWord+crlf+_object_,[linea ]+str(lcnt))
            IF left(CWORD,1) != "#" .or. left(CWORD,1) != "[" .and. !empty(trim(_object_))
               IF !empty(_object_)
                  a1 := at("FONT", upper(_object_))
                  DO CASE
                  CASE oWr:aStat[ 'Define' ] == .T.
                     aadd(oWr:ADECLARE,{_object_,lcnt})

                  CASE oWr:aStat[ 'Head' ] == .T.
                     aadd(oWr:aHead,{_object_,lcnt})

                  CASE oWr:aStat[ 'Body' ] == .T.
                     aadd(oWr:ABody,{_object_,lcnt})

                  CASE oWr:aStat[ 'Feet' ] == .T.
                     aadd(oWr:Afeet,{_object_,lcnt})
                  ENDCASE
               ENDIF
            ENDIF
         ENDDO
      ENDDO
      RELEASE endof_file
      a1 := 0
      oWr:CountSect(.t.)
      // aeval(oWr:ahead,{|x,y|msg(x,[Ahead ]+zaps(y))})
      vsect  :={|x|{eval(oWr:Valore,oWr:aHead[1]),eval(oWr:Valore,oWr:aBody[1]),eval(oWr:Valore,oWr:aFeet[1]),nline,x}[at(x,"HBFL"+x)]}
      epar   :={|x|if( "(" $ X .or."->" $ x,&(X),val(eval(vsect,x)))}

      vpar   :={|x,y|if(ascan(x,[y])#0,y[ascan(x,[y])+1],NIL)}
      chblk  :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+1],''),'')}
      chblk2 :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+2],''),'')}
      chkArg :={|x|if(ascan(x,{|aVal,y| aVal[1]== y})> 0 ,x[ascan(x,{|aVal,y| aVal[1]==y})][2],'KKK')}

      //msgbox( zaps(ascan(_aAlign,{|aVal,y| upper(aVal[1])== Y})),"FGFGFG")
      //ie:  eval(chblk,arrypar,[WIDTH]) RETURN A PARAMETER OF WIDTH

      FCLOSE(handle)

      str1:=upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

      IF "ASKP"  $ Str1
         IF msgyesno(" Print ?",[])
            ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'owr:doPr()','oWr:doMiniPr()') )
         ENDIF
      ELSE
         ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'owr:doPr()','oWr:doMiniPr()') )
      ENDIF

      IF "ASKR" $ Str1
         DO WHILE msgYesno("Reprint ?") == .t.
            ritorna := oWr:splash(if (oWr:PrnDrv = "HBPR",'oWr:doPr()','oWr:doMiniPr()') )
         ENDDO
         filename := '' //release window all
      ENDIF

      SET( _SET_EXACT  , x_exact )
      RELEASE An_Vari,aend ,_aFnt,_Apaper,_abin ,_acharset,_aPen ,_aBrush ,_acolor
      RELEASE _aPoly ,_aBkmode ,_aRegion ,_aQlt,_aImgSty, Atutto ,Anext ,Aivarpt,ActIva
      RELEASE filtro ,string1,start, pagina ,_money, format, Atf, ritspl
      RELEASE _separator, _euro, atr, _t_font ,mx_ln_d,vsect ,epar,Vpar,chblk,chkArg
      RELEASE maxrow

      FOR n = 1 to len(nomevar)
         n_var:=nomevar[n]
         rele &n_var
      NEXT
      rele nomevar,SEPARATOR
   ENDIF

   RETURN ritorna
   /*
   */
   * Printing Procedure                //La Procedura di Stampa

FUNCTION StampeEsegui(_MainArea,_psd,db_arc,_prw)

   LOCAL oldrec   := recno(), rtv := .F. ,;
      landscape:=.F., lpreview :=.F., lselect  :=.F. ,;
      str1:=[] , StrFlt := [], ;
      ncpl , nfsize, aprinters, ;
      lbody := 0, miocont:= 0, miocnt:= 0 ,;
      Amx_pg := {}

   PRIVATE ONEATLEAST := .F., shd := .t., sbt := .t., sgh := .t., insgh:=.F.

   IF !empty(_MainArea)
      oWr:aStat [ 'area1' ]  := substr(_MainArea,at('(',_MainArea)+1)
      oWr:aStat [ 'FldRel' ] := substr(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])+2)
      oWr:aStat [ 'FldRel' ] := substr(oWr:aStat [ 'FldRel' ],1,if(at(')',oWr:aStat [ 'FldRel' ])>0,at(')',oWr:aStat [ 'FldRel' ])-1,len(oWr:aStat [ 'FldRel' ]))) //+(at("->",oWr:aStat [ 'area1' ])))
      oWr:aStat [ 'area1' ]  := left(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])-1)
   ELSE
      oWr:aStat [ 'area1' ]  := dbf()
      oWr:aStat [ 'FldRel' ] :=''
   ENDIF

   DO CASE

   CASE oWr:PrnDrv = "HBPR"
      INIT PRINTSYS
      oWr:CheckUnits()

      GET PRINTERS TO aprinters

   CASE oWr:PrnDrv = "MINI"
      aprinters := aprinters()

   CASE oWr:PrnDrv = "PFD"
      INIT PRINTSYS

   ENDCASE

   PRIVATE counter   := {} , Gcounter := {}
   PRIVATE grdemo    := .F., gcdemo   := .F.
   PRIVATE Align     :=  0
   PRIVATE GHstring  := "", GFstring  := {}, GTstring := {}
   PRIVATE GField    := ""
   PRIVATE s_head    := "", TTS       := "Totale"

   PRIVATE s_col     :=  0, t_col     :=  0,  wheregt :=  0
   PRIVATE gftotal   := {}, Gfexec    := .F., s_total := ""
   PRIVATE nline     :=  mx_pg        := 0
   PRIVATE nPag      :=  0, nPgr      := 0, Tpg       :=  0
   PRIVATE last_pag  := .F., eLine    := 0, GFline    := .F.
   PUBLIC  maxrow    := 0 ,  maxcol   := 0,  mncl     := 0, mxH := 0
   PRIVATE abort     := 0

   ncpl := eval(oWr:Valore,oWr:Adeclare[1])
   str1 := upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

   IF "LAND" $ Str1 ;landscape:=.t.; Endif
   IF "SELE" $ Str1 ;lselect :=.t. ; Endif
   IF "PREV" $ Str1 ;lpreview:=.t. ; else;lpreview := _prw ; Endif

   str1 := upper(substr(oWr:aBody[1,1],at("/",oWr:aBody[1,1])+1))
   flob := val(str1)

   IF ncpl = 0
      ncpl   :=80
      nfsize :=12
   ELSE
      DO CASE
      CASE ncpl= 80
         nfsize:=12
      CASE ncpl= 96
         nfsize=10
      CASE ncpl= 120
         nfsize:=8
      CASE ncpl= 140
         nfsize:=7
      CASE ncpl= 160
         nfsize:=6
      OTHERWISE
         nfsize:=12
      ENDCASE
   ENDIF
   IF lselect .and. lpreview
      hbprn:selectprinter("",.t.) // SELECT BY DIALOG PREVIEW
   ENDIF
   IF lselect .and. (!lpreview)
      hbprn:selectprinter("",.t.) // SELECT BY DIALOG
   ENDIF
   IF !lselect .and. lpreview
      IF ascan(aprinters,_PSD) > 0
         hbprn:selectprinter(_PSD,.t.) // SELECT PRINTER _PSD PREVIEW
      ELSE
         hbprn:selectprinter(NIL,.t.) // SELECT DEFAULT PREVIEW
      ENDIF
   ENDIF
   IF !lselect .and. !lpreview
      IF ascan(aprinters,_PSD) > 0
         hbprn:selectprinter(_psd,.F.) // SELECT PRINTER _PSD
      ELSE
         hbprn:selectprinter(NIL,.F.)   // SELECT default
      ENDIF
   ENDIF
   IF HBPRNERROR != 0
      r_mem()

      RETURN rtv
   ENDIF
   DEFINE FONT "Fx" NAME "COURIER NEW" SIZE NFSIZE
   DEFINE FONT "F0" NAME "COURIER NEW" SIZE NFSIZE
   DEFINE FONT "_F1_" NAME "HELVETICA" SIZE NFSIZE BOLD
   DEFINE FONT "_BC_" NAME "HELVETICA" SIZE 9 BOLD
   DEFINE FONT "_RULER_" NAME "HELVETICA" SIZE 6
   DEFINE BRUSH "_BC_" style BS_SOLID color 0x000000
   DEFINE PEN "WHITE" COLOR {255,255,255}
   DEFINE PEN "BLACK" STYLE BS_SOLID WIDTH 5 COLOR {0,0,0}

   IF landscape
      SET page orientation DMORIENT_LANDSCAPE font "F0"
   ELSE
      SET page orientation DMORIENT_PORTRAIT  font "F0"
   ENDIF

   SELECT font "F0"
   SELECT pen "P0"

   //start doc
   IF used()
      IF !empty(atf)
         SET filter to &atf
      ENDIF
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   ELSE
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   ENDIF

   aeval(oWr:adeclare,{|x,y|if(Y > 1 ,oWr:traduci(x[1],,x[2]),'')})
   maxrow := int(hbprn:devcaps[1]/Lstep)
   oWr:colstep(ncpl,)

   IF abort != 0
      r_mem()

      RETURN NIL
   ENDIF
   //msg(zaps(mx_pg)+CRLF+[oWr:Valore= ]+zaps(eval(oWr:Valore,oWr:aBody[1,1]))+CRLF+zaps(oWr:aStat[ 'end_pr' ]),[tutte])

   START DOC NAME oWr:aStat [ 'JobName' ]

   DO CASE
   CASE oWr:HB=0

   CASE empty(_MainArea)                // Mono Db List
      IF lastrec() > 0 .or. valtype(oWr:argm[3]) == "A"
         Lbody := eval(oWr:Valore,oWr:aBody[1])
         mx_pg := INT(oWr:aStat[ 'end_pr' ]/NOZERODIV(Lbody) )
         IF (mx_pg * lbody) # mx_pg
            mx_pg ++
         ENDIF
         mx_pg := ROUND( max(1,mx_pg), 0 )
         tpg   := mx_pg
         IF valtype(oWr:argm[3]) # "A"
            Dbgotop()
         ENDIF
         IF oWr:aStat [ 'end_pr' ] # 0
            WHILE !oWr:aStat [ 'EndDoc' ]
               oWr:TheHead()
               oWr:TheBody()
            ENDDO
         ENDIF
      ELSE
         msgStop("No data to print! ","Attention")
      ENDIF
   OTHERWISE                              // Two Db List
      sele (oWr:aStat [ 'area1' ])
      IF !empty(atf)
         SET filter to &atf
      ENDIF
      Dbgotop()
      IF lastrec()> 0
         lbody := eval(oWr:Valore,oWr:aBody[1])
         //              msgbox(StrFlt := oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ],"452")
         //              msgbox(alias()+CRLF+db_arc+CRLF+ordkey(ordbagname())+crlf+oWr:aStat [ 'area1' ]+CRLF+oWr:aStat [ 'FldRel' ],"453")

         WHILE !eof()
            sele (DB_ARC)
            StrFlt := oWr:aStat [ 'FldRel' ]+" = "+ oWr:aStat [ 'area1' ]+"->"+oWr:aStat [ 'FldRel' ]
            DBEVAL( {|| miocont++},{|| &strFLT} )
            miocnt := int(miocont/NOZERODIV(lbody))
            IF (miocnt * lbody) # miocont
               miocnt ++
            ENDIF
            tpg += miocnt
            aadd(Amx_pg,miocnt)
            miocont := 0
            sele (oWr:aStat [ 'area1' ])
            dbskip()
         ENDDO
         GO TOP
         IF valtype (atail(amx_pg)) == "N"
            WHILE !eof()
               sele (DB_ARC)
               SET filter to &strFLT
               miocont ++
               mx_pg  := aMx_pg[miocont]
               GO TOP
               nPgr := 0
               WHILE !eof()
                  oWr:TheHead()
                  oWr:TheBody()
               ENDDO
               oWr:aStat [ 'EndDoc' ]:=.F.
               last_pag := .F.
               SET filter to
               sele (oWr:aStat [ 'area1' ])
               dbskip()
            ENDDO
         ENDIF
      ELSE
         msgStop("No data to print! ","Attention")
      ENDIF
   ENDCASE

   IF oneatleast
      GO TOP
      oWr:TheHead()
      oWr:TheFeet()
   ENDIF
end doc
IF len(oWr:aStat [ 'ErrorLine' ]) > 0
   msgmulty(oWr:aStat [ 'ErrorLine' ],"Error summary report:")
ENDIF
hbprn:setdevmode(256,1)
IF used();dbgoto(oldrec);Endif
R_mem(.T.)

RETURN !rtv
/*
*/

FUNCTION R_mem(Last)

   DEFAULT last to .F.
   aeval(oWr:astat[ 'aImages' ],{|x| Ferase(x) })
   IF oWr:prndrv = "HBPR"
      hbprn:end()
   ENDIF
   IF ! last
      domethod("form_splash","HIDE")
   ENDIF
   domethod("form_splash","release")
   RELEASE miocont,counter,Gcounter,grdemo,gcdemo,Align,GField
   RELEASE s_head,s_col,gftotal,Gfexec,s_total,t_col,nline,nPag,nPgr,Tpg,last_pag,eLine,wheregt
   RELEASE GFline,mx_pg,maxrow,ONEATLEAST,shd,sbt,sgh,insgh,TTS, abort

   RETURN .F.
   /*
   */

FUNCTION Proper(interm)             //Created By Piersoft 01/04/95 KILLED Bugs!

   LOCAL outStr := '',capnxt := '', c_1

   DO WHILE chr(32) $ interm
      c_1 := substr(interm,1,at(chr(32),interm)-1)
      capnxt := capnxt+upper(left(c_1,1))+right(c_1,len(c_1)-1)+" "
      interm := substr(interm,len(c_1)+2,len(interm)-len(c_1))
   ENDDO
   outStr := capnxt+upper(left(interm,1))+right(interm,len(interm)-1)

   RETURN outStr
   /*
   */

FUNCTION Color(GR,GR1,GR2)

   LOCAL DATO

   IF PCOUNT()=1 .and. valtype(GR)=="C"
      IF "," $ GR
         gr :=  STRTRAN(gr,"{",'')
         gr :=  STRTRAN(gr,"}",'')
         tokeninit(GR,",")
         IF oWr:PrnDrv = "HBPR"
            DATO := rgb( VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)) )
         ELSE
            Dato := { VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)),VAL(tokENNEXT(GR)) }
         ENDIF
      ELSE
         dato := oWr:SetMyRgb(oWr:DXCOLORS(gr))
      ENDIF
   ELSEIF PCOUNT()=1 .and. VALtype(GR)=="A"
      DATO := rgb(GR[1],GR[2],GR[3])
   ELSEIF PCOUNT()=3
      DATO := rgb(GR,GR1,GR2)
   ENDIF

   RETURN DATO
   /*
   */

FUNCTION GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g)

   *                1        2      3       4        5        6       7       8

   RETURN oWr:GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g)
   /*
   */

PROCEDURE gridRow(arg1)

   DEFAULT arg1 to oWr:aStat ['r_paint']
   oWr:aStat ['r_paint'] := arg1
   m->grdemo  := .t.

   RETURN
   /*
   */

PROCEDURE gridCol(arg1)

   DEFAULT arg1 to oWr:aStat ['r_paint']
   oWr:aStat ['r_paint'] := arg1
   m->gcdemo := .t.

   RETURN
   /*
   */
   STATIC Funct AscArr(string)
   LOCAL aka :={}, cword := ''

   DEFAULT string to ""
   string := atrepl( "{",string,'')
   string := atrepl( "}",string,'')
   aka := HB_ATOKENS( string, "," )

   RETURN aka
   /*
   */

FUNCTION ed_g_pic

   parameter __arg1,__arg2
   LOCAL arg1, arg2

   DEFAULT __arg2 to .F.

   IF __arg2
      _euro:=.t.
   ENDIF

   IF Valtype(m->__arg1)="C"
      * MSG(VALtype(m->__arg1),[val1])
      *- make sure it fits on the screen
      arg1 := "@KS" + LTRIM(STR(MIN(LEN((m->__arg1)), 78)))
   ELSEIF VALTYPE(m->__arg1) = "N"
      *- convert to a string
      * MSG(VALtype(m->__arg1),[val2])
      arg2 := STR (__arg1)
      *- look for a decimal point
      IF ("." $ arg2)
         *- return a picture reflecting a decimal point
         arg1 := REPLICATE("9", AT(".", arg2) - 1)+[.]

         arg1 := eu_point(arg1)+[.]+ REPLICATE("9", LEN(arg2) - LEN(arg1))
      ELSE
         *- return a string of 9's a the picture
         arg1 := REPLICATE("9", LEN(arg2))
         arg1 := eu_point(arg1)+if( _money,".00","")
      ENDIF
   ELSE
      *- well I just don't know.
      arg1 := ""
   ENDIF

   RETURN arg1
   /*
   */

FUNCTION eu_point(valore)

   LOCAL tappo:='',sep_conto:=0,n

   FOR n = len(valore) to 1 step -1
      IF substr(valore,n,1)==[9]
         IF sep_conto = 3
            IF _separator
               tappo := ","+tappo
            ENDIF
            sep_conto := 0
         ENDIF
         tappo := substr(valore,n,1)+TAPPO
         sep_conto ++
      ENDIF
   NEXT
   IF _euro
      tappo:= "@E "+tappo
   ENDIF

   RETURN tappo
   /*
   */

PROCEDURE dbselect(area)

   IF valtype(area)="N"
      dbSelectArea( zaps(area) )
   ELSEIF valtype(area)="C"
      SELECT (area)
   ENDIF

   RETURN
   /*
   */

FUNCTION Divisor(arg1,arg2)

   DEFAULT arg2 to 1

   RETURN arg1/Nozerodiv(arg2)
   /*
   */

FUNCTION NoZeroDiv(nValue)

   RETURN IIF(nValue=0,1,nValue)
   /*
   */

PROCEDURE MsgMulty( xMesaj, cTitle ) // Created By Bicahi Esgici <esgici@gmail.com>

   loca cMessage := ""

   IF xMesaj # NIL

      IF cTitle == NIL
         cTitle := PROCNAME(1) + "\" +   NTrim( PROCLINE(1) )
      ENDIF

      IF VALTYPE( xMesaj  ) # "A"
         xMesaj := { xMesaj }
      ENDIF

      AEVAL( xMesaj, { | x1 | cMessage +=  Any2Strg( x1 ) + CRLF } )

      MsgInfo( cMessage, cTitle )

   ENDIF xMesaj # NIL

   RETU
   /*
   */
   FUNC Any2Strg( xAny )
      loca cRVal  := '???',;
         nType  :=  0,;
         aCases := { { "A", { |  | "{...}" } },;
         { "B", { |  | "{||}" } },;
         { "C", { | x | x }},;
         { "M", { | x | x   } },;
         { "D", { | x | DTOC( x ) } },;
         { "L", { | x | IF( x,"On","Off") } },;
         { "N", { | x | NTrim( x )  } },;
         { "O", { |  | ":Object:" } },;
         { "U", { |  | "<NIL>" } } }

      IF (nType := ASCAN( aCases, { | a1 | VALTYPE( xAny ) == a1[ 1 ] } ) ) > 0
         cRVal := EVAL( aCases[ nType, 2 ], xAny )
      ENDIF

      RETU cRVal

      #ifdef __XHARBOUR__
      /*
      */

FUNCTION DecToHexa(nNumber)

   LOCAL cNewString:=''
   LOCAL nTemp:=0

   WHILE(nNumber > 0)
   nTemp:=(nNumber%16)
   cNewString:=SubStr('0123456789ABCDEF',(nTemp+1),1)+cNewString
   nNumber:=Int((nNumber-nTemp)/16)
ENDDO

RETURN(cNewString)
/*
*/

FUNCTION HexaToDec(cString)

   LOCAL nNumber:=0,nX:=0
   LOCAL cNewString:=AllTrim(cString)
   LOCAL nLen:=Len(cNewString)

   FOR nX:=1 to nLen
      nNumber+=(At(SubStr(cNewString,nX,1),'0123456789ABCDEF')-1)*;
         (16**(nLen-nX))
   NEXT nX

   RETURN nNumber

   #endif
   /*
   */

FUNCTION Msgt (nTimeout, Message, Title, Flags)

   * Created at 04/20/2005 By Pierpaolo Martinello Italy                         *
   * Modified 15/08/2014                                                         *

   LOCAL rtv := 0 ,nFlag, nMSec

   DEFAULT Message TO "" , Title TO "", Flags  TO "MSGBOX"

   IF ValType (nTimeout) != 'U' .and. ValType (nTimeout) == 'C'
      Flags    := Title
      Title    := Message
      Message  := nTimeout
      nTimeout := 0
   ENDIF

   Flags := trans(Flags,"@!")

   nMSec := nTimeout * 1000

   Message+= if(empty(Message),"Empty string!",'')

   DO CASE

   CASE "RETRYCANCEL" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_RETRYCANCEL
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "OKCANCEL" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_OKCANCEL
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "YESNO" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNO
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "YESNO_ID" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNO
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "YESNO_CANCEL" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_YESNOCANCEL
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "INFO" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONINFORMATION
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "STOP" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONSTOP
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   CASE "EXCLAMATION" == FLAGS .or. "ALERT" == FLAGS
      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL + MB_ICONEXCLAMATION
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)

   OTHERWISE

      nFlag := MB_OK + MB_SETFOREGROUND + MB_SYSTEMMODAL
      RTV:= MessageBoxTimeout (Message, Title, nFlag, nMSec)
   ENDCASE

   RETURN rtv
   /*
   */

FUNCTION _dummy_( ... )

   RETURN NIL
   /*
   */

FUNCTION WRVersion( )

   RETURN "4.3"
   /*
   */

CREATE CLASS WREPORT

   DATA FILENAME         INIT ''
   DATA NREC             INIT 0
   DATA F_HANDLE         INIT 0 PROTECTED
   DATA aDeclare         INIT {}
   DATA AHead            INIT {}
   DATA ABody            INIT {}
   DATA AFeet            INIT {}
   DATA Hb               INIT 0
   DATA aCnt             INIT 0
   DATA Valore           INIT {|x|val(substr(x[1],at("]",x[1])+1))}
   DATA mx_ln_doc        INIT 0
   DATA PRNDRV           INIT "HBPR"
   DATA lSuccess         INIT .F.
   DATA Lmargin          INIT 0
   DATA argm             INIT {nil,nil, nil,nil}
   DATA aStat            INIT { 'Define'     => .F. , ;    // Define Section
   'Head'       => .F. , ;    // Head Section
   'Body'       => .F. , ;    // Body Section
   'Feet'       => .F. , ;    // Feet section
   'Filtro'     => .F. , ;
      'r_paint'    => .T. , ;
      'TempHead'   =>  '' , ;
      'Ghead'      => .F. , ;
      'P_F_E_G'    => .F. , ;
      'GHline'     => .F. , ;
      'TempFeet'   =>  '' , ;
      'end_pr'     =>  0  , ;
      'EndDoc'     => .F. , ;
      'EntroIF'    => .F. , ;
      'DelMode'    => .F. , ;
      'ElseStat'   => .F. , ;
      'ErrorLine'  =>  {} , ;
      'OneError'   => .F. , ;
      'area1'      =>  '' , ;
      'FldRel'     =>  '' , ;
      'ReadMemo'   =>  '' , ;
      'lblsplash'  =>  'Attendere......... Creazione stampe!' , ;
      'TrSpace'    => {|x,y,z|oWr:transpace(x,y,z)} , ;
      'Yes_Memo'   => .F. , ;
      'Yes_Array'  => .F. , ;
      'JobName'    => 'HbPrinter' , ;
      'JobPath'    => cFilePath(GetExeFileName())+"\" , ;
      'Test'       => "{|X| LTRIM( STR( X,20, IF( X == INT( X ), 0, 2 ) ))}" , ;
      'Control'    => .F. , ;
      'InlineSbt'  => .T. , ;
      'InlineTot'  => .T. , ;
      'aImages'    => {}  , ;
      'Memofont'   => {}  , ;
      'PdfFont'    => {{"",""}} , ;
      'cStep'      => 2.625 , ;
      'Units'      => "MM", ;    //
   'Orient'     =>  1 , ;   // default PORTRAIT
   'Duplex'     =>  1 , ;   // default NONE
   'Source'     =>  1 , ;   // default BIN_UPPER
   'Collate'    =>  0 , ;   // default FALSE
   'Res'        => -3 , ;   // default MEDIUM
   'PaperSize'  =>  9 , ;   // default A4
   'PaperLength'=> 0  , ;   // default 0
   'PaperWidth' => 0  , ;   // default 0
   'ColorMode'  => 1  , ;   // default MONOCHROME
   'Copies'     => 1  , ;   // default 1
   'Fname'      => "" , ;
      'Fsize'      => 0  , ;
      'FBold'      => .F., ;
      'Fita'       => .F., ;
      'Funder'     => .F., ;
      'Fstrike'    => .F., ;
      'Falign'     => .F., ;
      'Fangle'     => 0  , ;
      'Fcolor'     =>    , ;
      'HRuler'     => {0,.F.} ,;
      'VRuler'     => {0,.F.} ,;
      'DebugType'  => "LINE", ;
      'Hbcompatible'=> 0 ,;
      'MarginTop'   => 0 ,;
      'MarginLeft'  => 0 ;
      }

   DATA Ach              INIT  {;
      {"DMPAPER_FIRST",               1}; /*  */
   ,{"DMPAPER_LETTER",              1}; /*   Letter 8 1/2 x 11 in               */
   ,{"DMPAPER_LETTERSMALL",         2}; /*   Letter Small 8 1/2 x 11 in         */
   ,{"DMPAPER_TABLOID",             3}; /*   Tabloid 11 x 17 in                 */
   ,{"DMPAPER_LEDGER",              4}; /*   Ledger 17 x 11 in                  */
   ,{"DMPAPER_LEGAL",               5}; /*   Legal 8 1/2 x 14 in                */
   ,{"DMPAPER_STATEMENT",           6}; /*   Statement 5 1/2 x 8 1/2 in         */
   ,{"DMPAPER_EXECUTIVE",           7}; /*   Executive 7 1/4 x 10 1/2 in        */
   ,{"DMPAPER_A3",                  8}; /*   A3 297 x 420 mm                    */
   ,{"DMPAPER_A4",                  9}; /*   A4 210 x 297 mm                    */
   ,{"DMPAPER_A4SMALL",            10}; /*   A4 Small 210 x 297 mm              */
   ,{"DMPAPER_A5",                 11}; /*   A5 148 x 210 mm                    */
   ,{"DMPAPER_B4",                 12}; /*   B4 (JIS) 250 x 354                 */
   ,{"DMPAPER_B5",                 13}; /*   B5 (JIS) 182 x 257 mm              */
   ,{"DMPAPER_FOLIO",              14}; /*   Folio 8 1/2 x 13 in                */
   ,{"DMPAPER_QUARTO",             15}; /*   Quarto 215 x 275 mm                */
   ,{"DMPAPER_10X14",              16}; /*   10x14 in                           */
   ,{"DMPAPER_11X17",              17}; /*   11x17 in                           */
   ,{"DMPAPER_NOTE",               18}; /*   Note 8 1/2 x 11 in                 */
   ,{"DMPAPER_ENV_9",              19}; /*   Envelope #9 3 7/8 x 8 7/8          */
   ,{"DMPAPER_ENV_10",             20}; /*   Envelope #10 4 1/8 x 9 1/2         */
   ,{"DMPAPER_ENV_11",             21}; /*   Envelope #11 4 1/2 x 10 3/8        */
   ,{"DMPAPER_ENV_12",             22}; /*   Envelope #12 4 \276 x 11           */
   ,{"DMPAPER_ENV_14",             23}; /*   Envelope #14 5 x 11 1/2            */
   ,{"DMPAPER_CSHEET",             24}; /*   C size sheet                       */
   ,{"DMPAPER_DSHEET",             25}; /*   D size sheet                       */
   ,{"DMPAPER_ESHEET",             26}; /*   E size sheet                       */
   ,{"DMPAPER_ENV_DL",             27}; /*   Envelope DL 110 x 220mm            */
   ,{"DMPAPER_ENV_C5",             28}; /*   Envelope C5 162 x 229 mm           */
   ,{"DMPAPER_ENV_C3",             29}; /*   Envelope C3  324 x 458 mm          */
   ,{"DMPAPER_ENV_C4",             30}; /*   Envelope C4  229 x 324 mm          */
   ,{"DMPAPER_ENV_C6",             31}; /*   Envelope C6  114 x 162 mm          */
   ,{"DMPAPER_ENV_C65",            32}; /*   Envelope C65 114 x 229 mm          */
   ,{"DMPAPER_ENV_B4",             33}; /*   Envelope B4  250 x 353 mm          */
   ,{"DMPAPER_ENV_B5",             34}; /*   Envelope B5  176 x 250 mm          */
   ,{"DMPAPER_ENV_B6",             35}; /*   Envelope B6  176 x 125 mm          */
   ,{"DMPAPER_ENV_ITALY",          36}; /*   Envelope 110 x 230 mm              */
   ,{"DMPAPER_ENV_MONARCH",        37}; /*   Envelope Monarch 3.875 x 7.5 in    */
   ,{"DMPAPER_ENV_PERSONAL",       38}; /*   6 3/4 Envelope 3 5/8 x 6 1/2 in    */
   ,{"DMPAPER_FANFOLD_US",         39}; /*   US Std Fanfold 14 7/8 x 11 in      */
   ,{"DMPAPER_FANFOLD_STD_GERMAN", 40}; /*   German Std Fanfold 8 1/2 x 12 in   */
   ,{"DMPAPER_FANFOLD_LGL_GERMAN", 41}; /*   German Legal Fanfold 8 1/2 x 13 in */
   ,{"DMPAPER_ISO_B4",             42}; /*   B4 (ISO) 250 x 353 mm              */
   ,{"DMPAPER_JAPANESE_POSTCARD",  43}; /*   Japanese Postcard 100 x 148 mm     */
   ,{"DMPAPER_9X11",               44}; /*   9 x 11 in                          */
   ,{"DMPAPER_10X11",              45}; /*   10 x 11 in                         */
   ,{"DMPAPER_15X11",              46}; /*   15 x 11 in                         */
   ,{"DMPAPER_ENV_INVITE",         47}; /*   Envelope Invite 220 x 220 mm       */
   ,{"DMPAPER_RESERVED_48",        48}; /*   RESERVED--DO NOT USE               */
   ,{"DMPAPER_RESERVED_49",        49}; /*   RESERVED--DO NOT USE               */
   ,{"DMPAPER_LETTER_EXTRA",       50}; /*   Letter Extra 9 \275 x 12 in        */
   ,{"DMPAPER_LEGAL_EXTRA",        51}; /*   Legal Extra 9 \275 x 15 in         */
   ,{"DMPAPER_TABLOID_EXTRA",      52}; /*   Tabloid Extra 11.69 x 18 in        */
   ,{"DMPAPER_A4_EXTRA",           53}; /*   A4 Extra 9.27 x 12.69 in           */
   ,{"DMPAPER_LETTER_TRANSVERSE",  54}; /*   Letter Transverse 8 \275 x 11 in   */
   ,{"DMPAPER_A4_TRANSVERSE",      55}; /*   A4 Transverse 210 x 297 mm         */
   ,{"DMPAPER_LETTER_EXTRA_TRANSVERSE",56}; /* Letter Extra Transverse 9\275 x 12 in */
   ,{"DMPAPER_A_PLUS",             57};   /* SuperA/SuperA/A4 227 x 356 mm      */
   ,{"DMPAPER_B_PLUS",             58};   /* SuperB/SuperB/A3 305 x 487 mm      */
   ,{"DMPAPER_LETTER_PLUS",        59};   /* Letter Plus 8.5 x 12.69 in         */
   ,{"DMPAPER_A4_PLUS",            60};   /* A4 Plus 210 x 330 mm               */
   ,{"DMPAPER_A5_TRANSVERSE",      61};   /* A5 Transverse 148 x 210 mm         */
   ,{"DMPAPER_B5_TRANSVERSE",      62};   /* B5 (JIS) Transverse 182 x 257 mm   */
   ,{"DMPAPER_A3_EXTRA",           63};   /* A3 Extra 322 x 445 mm              */
   ,{"DMPAPER_A5_EXTRA",           64};   /* A5 Extra 174 x 235 mm              */
   ,{"DMPAPER_B5_EXTRA",           65};   /* B5 (ISO) Extra 201 x 276 mm        */
   ,{"DMPAPER_A2",                 66};   /* A2 420 x 594 mm                    */
   ,{"DMPAPER_A3_TRANSVERSE",      67};   /* A3 Transverse 297 x 420 mm         */
   ,{"DMPAPER_A3_EXTRA_TRANSVERSE",68};   /* A3 Extra Transverse 322 x 445 mm   */
   ,{"DMPAPER_DBL_JAPANESE_POSTCARD",69};  /* Japanese Double Postcard 200 x 148 mm */
   ,{"DMPAPER_A6",                  70 };  /*  A6 105 x 148 mm                 */
   ,{"DMPAPER_JENV_KAKU2",          71 };  /*  Japanese Envelope Kaku #2       */
   ,{"DMPAPER_JENV_KAKU3",          72 };  /*  Japanese Envelope Kaku #3       */
   ,{"DMPAPER_JENV_CHOU3",          73 };  /*  Japanese Envelope Chou #3       */
   ,{"DMPAPER_JENV_CHOU4",          74 };  /*  Japanese Envelope Chou #4       */
   ,{"DMPAPER_LETTER_ROTATED",      75 };  /*  Letter Rotated 11 x 8 1/2 11 in */
   ,{"DMPAPER_A3_ROTATED",          76 };  /*  A3 Rotated 420 x 297 mm         */
   ,{"DMPAPER_A4_ROTATED",          77 };  /*  A4 Rotated 297 x 210 mm         */
   ,{"DMPAPER_A5_ROTATED",          78 };  /*  A5 Rotated 210 x 148 mm         */
   ,{"DMPAPER_B4_JIS_ROTATED",      79 };  /*  B4 (JIS) Rotated 364 x 257 mm   */
   ,{"DMPAPER_B5_JIS_ROTATED",      80 };  /*  B5 (JIS) Rotated 257 x 182 mm   */
   ,{"DMPAPER_JAPANESE_POSTCARD_ROTATED",81};    /*Japanese Postcard Rotated 148 x 100 mm */
   ,{"DMPAPER_DBL_JAPANESE_POSTCARD_ROTATED",82};/*double Japanese Postcard Rotated 148 x 200 mm */
   ,{"DMPAPER_A6_ROTATED",          83 }; /*  A6 Rotated 148 x 105 mm         */
   ,{"DMPAPER_JENV_KAKU2_ROTATED",  84 }; /*  Japanese Envelope Kaku #2 Rotated */
   ,{"DMPAPER_JENV_KAKU3_ROTATED",  85 }; /*  Japanese Envelope Kaku #3 Rotated */
   ,{"DMPAPER_JENV_CHOU3_ROTATED",  86 }; /*  Japanese Envelope Chou #3 Rotated */
   ,{"DMPAPER_JENV_CHOU4_ROTATED",  87 }; /*  Japanese Envelope Chou #4 Rotated */
   ,{"DMPAPER_B6_JIS",              88 }; /*  B6 (JIS) 128 x 182 mm           */
   ,{"DMPAPER_B6_JIS_ROTATED",      89 }; /*  B6 (JIS) Rotated 182 x 128 mm   */
   ,{"DMPAPER_12X11",               90 }; /*  12 x 11 in                      */
   ,{"DMPAPER_JENV_YOU4",           91 }; /*  Japanese Envelope You #4        */
   ,{"DMPAPER_JENV_YOU4_ROTATED",   92 }; /*  Japanese Envelope You #4 Rotated*/
   ,{"DMPAPER_P16K",                93 }; /*  PRC 16K 146 x 215 mm            */
   ,{"DMPAPER_P32K",                94 }; /*  PRC 32K 97 x 151 mm             */
   ,{"DMPAPER_P32KBIG",             95 }; /*  PRC 32K(Big) 97 x 151 mm        */
   ,{"DMPAPER_PENV_1",              96 }; /*  PRC Envelope #1 102 x 165 mm    */
   ,{"DMPAPER_PENV_2",              97 }; /*  PRC Envelope #2 102 x 176 mm    */
   ,{"DMPAPER_PENV_3",              98 }; /*  PRC Envelope #3 125 x 176 mm    */
   ,{"DMPAPER_PENV_4",              99 }; /*  PRC Envelope #4 110 x 208 mm    */
   ,{"DMPAPER_PENV_5",              100}; /*  PRC Envelope #5 110 x 220 mm    */
   ,{"DMPAPER_PENV_6",              101}; /*  PRC Envelope #6 120 x 230 mm    */
   ,{"DMPAPER_PENV_7",              102}; /*  PRC Envelope #7 160 x 230 mm    */
   ,{"DMPAPER_PENV_8",              103}; /*  PRC Envelope #8 120 x 309 mm    */
   ,{"DMPAPER_PENV_9",              104}; /*  PRC Envelope #9 229 x 324 mm    */
   ,{"DMPAPER_PENV_10",             105}; /*  PRC Envelope #10 324 x 458 mm   */
   ,{"DMPAPER_P16K_ROTATED",        106}; /*  PRC 16K Rotated                 */
   ,{"DMPAPER_P32K_ROTATED",        107}; /*  PRC 32K Rotated                 */
   ,{"DMPAPER_P32KBIG_ROTATED",     108}; /*  PRC 32K(Big) Rotated            */
   ,{"DMPAPER_PENV_1_ROTATED",      109}; /*  PRC Envelope #1 Rotated 165 x 102 mm */
   ,{"DMPAPER_PENV_2_ROTATED",      110}; /*  PRC Envelope #2 Rotated 176 x 102 mm */
   ,{"DMPAPER_PENV_3_ROTATED",      111}; /*  PRC Envelope #3 Rotated 176 x 125 mm */
   ,{"DMPAPER_PENV_4_ROTATED",      112}; /*  PRC Envelope #4 Rotated 208 x 110 mm */
   ,{"DMPAPER_PENV_5_ROTATED",      113}; /*  PRC Envelope #5 Rotated 220 x 110 mm */
   ,{"DMPAPER_PENV_6_ROTATED",      114}; /*  PRC Envelope #6 Rotated 230 x 120 mm */
   ,{"DMPAPER_PENV_7_ROTATED",      115}; /*  PRC Envelope #7 Rotated 230 x 160 mm */
   ,{"DMPAPER_PENV_8_ROTATED",      116}; /*  PRC Envelope #8 Rotated 309 x 120 mm */
   ,{"DMPAPER_PENV_9_ROTATED",      117}; /*  PRC Envelope #9 Rotated 324 x 229 mm */
   ,{"DMPAPER_PENV_10_ROTATED",     118}; /*  PRC Envelope #10 Rotated 458 x 324 mm */
   ,{"DMPAPER_USER",                256};
      ,{"DMBIN_FIRST",          1};   /* bin selections */
   ,{"DMBIN_UPPER",          1};
      ,{"DMBIN_ONLYONE",        1};
      ,{"DMBIN_LOWER",          2};
      ,{"DMBIN_MIDDLE",         3};
      ,{"DMBIN_MANUAL",         4};
      ,{"DMBIN_ENVELOPE",       5};
      ,{"DMBIN_ENVMANUAL",      6};
      ,{"DMBIN_AUTO",           7};
      ,{"DMBIN_TRACTOR",        8};
      ,{"DMBIN_SMALLFMT",       9};
      ,{"DMBIN_LARGEFMT",      10};
      ,{"DMBIN_LARGECAPACITY", 11};
      ,{"DMBIN_CASSETTE",      14};
      ,{"DMBIN_FORMSOURCE",    15};
      ,{"DMBIN_LAST",          15};
      ,{"DMBIN_USER",         256};     /* device specific bins start here */
   ,{"ANSI_CHARSET",              0};  /*  _acharset :={; */
   ,{"DEFAULT_CHARSET",           1};
      ,{"SYMBOL_CHARSET",            2};
      ,{"SHIFTJIS_CHARSET",        128};
      ,{"HANGEUL_CHARSET",         129};
      ,{"HANGUL_CHARSET",          129};
      ,{"GB2312_CHARSET",          134};
      ,{"CHINESEBIG5_CHARSET",     136};
      ,{"OEM_CHARSET",             255};
      ,{"JOHAB_CHARSET",           130};
      ,{"HEBREW_CHARSET",          177};
      ,{"ARABIC_CHARSET",          178};
      ,{"GREEK_CHARSET",           161};
      ,{"TURKISH_CHARSET",         162};
      ,{"VIETNAMESE_CHARSET",      163};
      ,{"THAI_CHARSET",            222};
      ,{"EASTEUROPE_CHARSET",      238};
      ,{"RUSSIAN_CHARSET",         204};
      ,{"MAC_CHARSET",              77};
      ,{"BALTIC_CHARSET",          186};
      ,{"PS_SOLID",            0};       /* Pen Styles */
   ,{"PS_DASH",             1};       /* -------  */
   ,{"PS_DOT",              2};       /* .......  */
   ,{"PS_DASHDOT",          3};       /* _._._._  */
   ,{"PS_DASHDOTDOT",       4};       /* _.._.._  */
   ,{"PS_NULL",             5};
      ,{"PS_INSIDEFRAME",      6};
      ,{"PS_USERSTYLE",        7};
      ,{"PS_ALTERNATE",        8};
      ,{"PS_STYLE_MASK",       0x0000000F};
      ,{"BS_SOLID",            0};       /* Brush Styles */
   ,{"BS_NULL",             1};
      ,{"BS_HOLLOW",           1};
      ,{"BS_HATCHED",          2};
      ,{"BS_PATTERN",          3};
      ,{"BS_INDEXED",          4};
      ,{"BS_DIBPATTERN",       5};
      ,{"BS_DIBPATTERNPT",     6};
      ,{"BS_PATTERN8X8",       7};
      ,{"BS_DIBPATTERN8X8",    8};
      ,{"BS_MONOPATTERN",      9};
      ,{"ALTERNATE",            1}; /* PolyFill() Modes */
   ,{"WINDING",              2};
      ,{"POLYFILL_LAST",        2};
      ,{"TRANSPARENT",         1}; /* Background Modes */
   ,{"OPAQUE",              2};
      ,{"BKMODE_LAST",         2};
      ,{"TA_NOUPDATECP",       0}; /* Text Alignment Options */
   ,{"TA_UPDATECP",         1};
      ,{"TA_LEFT",             0};
      ,{"TA_RIGHT",            2};
      ,{"TA_CENTER",           6};
      ,{"LEFT",                0};
      ,{"RIGHT",               2};
      ,{"CENTER",              6};
      ,{"TA_TOP",              0};
      ,{"TA_BOTTOM",           8};
      ,{"TA_BASELINE",         24};
      ,{"TA_RTLREADING",       256};
      ,{"TA_MASK",       (TA_BASELINE+TA_CENTER+TA_UPDATECP+TA_RTLREADING)};
      ,{"RGN_AND",             1};  /* CombineRgn() Styles */
   ,{"RGN_OR",              2};
      ,{"RGN_XOR",             3};
      ,{"RGN_DIFF",            4};
      ,{"RGN_COPY",            5};
      ,{"RGN_MIN",       RGN_AND};
      ,{"RGN_MAX",      RGN_COPY};
      ,{"AND",                 1};
      ,{"OR",                  2};
      ,{"XOR",                 3};
      ,{"DIFF",                4};
      ,{"COPY",                5};
      ,{"MIN",           RGN_AND};
      ,{"MAX",          RGN_COPY};
      ,{"DMCOLOR_MONOCHROME", 1}; /* color enable/disable for color printers */
   ,{"DMCOLOR_COLOR",      2};
      ,{"MONO",               1};
      ,{"COLOR",              2};
      ,{"DMRES_DRAFT",    -1};  /* print qualities */
   ,{"DMRES_LOW",      -2};
      ,{"DMRES_MEDIUM",   -3};
      ,{"DMRES_HIGH",     -4};
      ,{"DRAFT",          -1};
      ,{"LOW",            -2};
      ,{"MEDIUM",         -3};
      ,{"HIGH",           -4};
      ,{"ILD_NORMAL",     0x0000}; /* IMAGELIST DRAWING STYLES */
   ,{"ILD_MASK",       0x0010};
      ,{"ILD_BLEND25",    0x0002};
      ,{"ILD_BLEND50",    0x0004};
      ,{"DMDUP_SIMPLEX"   ,1};   /* duplex enable */
   ,{"DMDUP_VERTICAL"  ,2};
      ,{"DMDUP_HORIZONTAL",3};
      ,{"OFF"             ,1};
      ,{"SIMPLEX"         ,1};
      ,{"VERTICAL"        ,2};
      ,{"HORIZONTAL"      ,3};
      ,{"DT_TOP"                 , 0x00000000};
      ,{"DT_LEFT"                , 0x00000000};
      ,{"DT_CENTER"              , 0x00000001};
      ,{"DT_RIGHT"               , 0x00000002};
      ,{"DT_VCENTER"             , 0x00000004};
      ,{"DT_BOTTOM"              , 0x00000008};
      ,{"DT_WORDBREAK"           , 0x00000010};
      ,{"DT_SINGLELINE"          , 0x00000020};
      ,{"DT_EXPANDTABS"          , 0x00000040};
      ,{"DT_TABSTOP"             , 0x00000080};
      ,{"DT_NOCLIP"              , 0x00000100};
      ,{"DT_EXTERNALLEADING"     , 0x00000200};
      ,{"DT_CALCRECT"            , 0x00000400};
      ,{"DT_NOPREFIX"            , 0x00000800};
      ,{"DT_INTERNAL"            , 0x00001000};
      ,{"DT_EDITCONTROL"         , 0x00002000};
      ,{"DT_PATH_ELLIPSIS"       , 0x00004000};
      ,{"DT_END_ELLIPSIS"        , 0x00008000};
      ,{"DT_MODIFYSTRING"        , 0x00010000};
      ,{"DT_RTLREADING"          , 0x00020000};
      ,{"DT_WORD_ELLIPSIS"       , 0x00040000};
      ,{"DT_NOFULLWIDTHCHARBREAK", 0x00080000};
      ,{"DT_HIDEPREFIX"          , 0x00100000};
      ,{"DT_PREFIXONLY"          , 0x00200000};
      ,{"HB_ZEBRA_FLAG_CHECKSUM" ,          1};
      ,{"HB_ZEBRA_FLAG_WIDE2"    ,       0x00};  // Dummy flag - default
   ,{"HB_ZEBRA_FLAG_WIDE2_5"  ,       0x40};
      ,{"HB_ZEBRA_FLAG_WIDE3"    ,       0x80};
      ,{"HB_ZEBRA_FLAG_PDF417_TRUNCATED"    , 0x0100};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL_MASK"   , 0xF000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL0"       , 0x1000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL1"       , 0x2000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL2"       , 0x3000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL3"       , 0x4000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL4"       , 0x5000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL5"       , 0x6000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL6"       , 0x7000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL7"       , 0x8000};
      ,{"HB_ZEBRA_FLAG_PDF417_LEVEL8"       , 0x9000};
      ,{"HB_ZEBRA_FLAG_DATAMATRIX_SQUARE"   , 0x0100};
      ,{"HB_ZEBRA_FLAG_DATAMATRIX_RECTANGLE", 0x0200};
      ,{"HB_ZEBRA_FLAG_QR_LEVEL_MASK"       , 0x0700};
      ,{"HB_ZEBRA_FLAG_QR_LEVEL_L"          , 0x0100};
      ,{"HB_ZEBRA_FLAG_QR_LEVEL_M"          , 0x0200};
      ,{"HB_ZEBRA_FLAG_QR_LEVEL_Q"          , 0x0300};
      ,{"HB_ZEBRA_FLAG_QR_LEVEL_H"          , 0x0400}}

METHOD New ()  CONSTRUCTOR

METHOD ISMONO(arg1)

METHOD SPLASH ()

METHOD CHOICEDRV()

METHOD DoPr ()

METHOD DoPdf ()

METHOD DoMiniPr ()

METHOD fGetline (handle)

METHOD Transpace ()

METHOD MACROCOMPILE ()

METHOD TRADUCI ()

METHOD LEGGIPAR ()

METHOD WHAT_ELE ()

METHOD MEMOSAY ()

METHOD PUTARRAY(row,col,arr,awidths,rowheight,vertalign,noframes,abrushes,apens,afonts,afontscolor,abitmaps,userfun)

METHOD HATCH ()

METHOD GROUP ()

METHOD GrHead ()

METHOD GFeet ()

METHOD UsaFont ()

METHOD Hgconvert ()

METHOD TheHead ()

METHOD TheBody ()

METHOD TheFeet ()

METHOD UsaColor ()

METHOD SETMYRGB ()

METHOD QUANTIREC ()

METHOD COUNTSECT (EXEC)

METHOD CheckUnits()

METHOD UseFLags(arg1)

METHOD Colstep(nfsize,width)

METHOD PgenSet()

METHOD JUSTIFICALINEA ()

METHOD CheckAlign(arrypar)

METHOD GestImage ( image )

METHOD MixMsay()

METHOD DrawBarcode( nRow,nCol,nHeight, nLineWidth, cType, cCode, nFlags )

METHOD Vruler ( pos )

METHOD Hruler ( pos )

METHOD DXCOLORS(par)

   /*

   METHOD SaveData()

   */

METHOD END()

   */

ENDCLASS

/*
*/

METHOD New() CLASS WREPORT

   RETURN self
   /*
   */

METHOD End() CLASS WREPORT

   RELEASE ::F_HANDLE,::aDeclare,::AHead,::ABody,::AFeet,::Hb,::Valore,::mx_ln_doc;
      ,       ::PRNDRV,::argm,::aStat
   RELEASE ::ach , ::filename

   RETURN NIL
   /*
   */

METHOD IsMono(arg1) CLASS WREPORT

   LOCAL en, rtv := .F.

   FOR EACH en in arg1
      IF valtype(en)=="A"
         EXIT
      ELSE
         rtv := .t.
         EXIT
      ENDIF
   NEXT

   RETURN rtv
   /*
   */

METHOD COUNTSECT(EXEC) CLASS WREPORT

   DEFAULT EXEC TO .F.
   IF EXEC
      ::HB := eval(::Valore,::aHead[1] );
         +  eval(::Valore,::aBody[1] )
      ::mx_ln_doc := ::hb + eval(::Valore,::aFeet[1])
   ENDIF

   RETURN NIL
   /*
   */

METHOD CheckUnits( arg1 ) CLASS WREPORT //returns the units used

   LOCAL aUnit:={{0,"RC"},{1,"MM"},{2,"IN"},{3,"PN"} }

   DO CASE
   CASE oWr:PrnDrv = "MINI"
      ::aStat [ 'Units' ] :="MM"

   CASE oWr:PrnDrv = "HBPR"
      DEFAULT arg1 to hbprn:units
      ::aStat [ 'Units' ] := aunit[ascan(aUnit,{|x|x[1]=arg1}),2]

   CASE oWr:PrnDrv = "PDF"
      ::aStat [ 'Units' ] :="MM"
   ENDCASE

   RETURN NIL
   /*
   */

METHOD UseFlags( arg1 ) CLASS WREPORT //returns the FLAGS

   LOCAL aFlg := "" , aSrc := 0, nn ,rtv := 0

   DEFAULT arg1 to ""
   aFlg := HB_ATOKENS(arg1,"+")
   FOR EACH nn in aFlg
      aSrc := ASCAN(::aCh, {|aVal| aVal[1] == alltrim(nn)})
      IF aSrc > 0  // sum the flags if necessary
         rtv += ::aCh[asrc,2]
      ENDIF
   NEXT

   RETURN rtv
   /*
   */

METHOD COLSTEP(nfsize,width) CLASS WREPORT

   LOCAL ncpl1 := eval(oWr:Valore,oWr:Adeclare[1])

   DEFAULT width to 1 , nfsize to 12

   DO CASE
   CASE ::aStat [ 'Units' ] = "RC"
      ::aStat [ 'cStep' ] := width / nfsize

   CASE ::aStat [ 'Units' ] = "MM"
      ::aStat [ 'cStep' ] := width / nfsize

   ENDCASE

   RETURN NIL
   /*
   */

METHOD pGenSet() CLASS WREPORT

   LOCAL Plist:= {'ORIENTATION','PAPERSIZE','PAPERLENGTH','PAPERWIDTH';
      ,'COPIES','BIN','DEFAULTSOURCE','QUALITY','COLORMODE','DUPLEX';
      ,'COLLATE'}
   LOCAL arrypar := {} , s , k
   LOCAL blso := {|x| if(val(x)> 0,min(val(x),1),if(x=".T.".or. x ="ON",1,0))}

   // return two array
   FOR EACH s IN oWr:aDeclare
      k := HB_enumindex(s)
      aeval(Plist,{|x| if(x $ upper(s[1]);
         , aadd(arrypar ;
         ,HB_ATOKENS(upper(::aDeclare[k][1]),chr(07),.T.,.F. ));
         ,NIL) } )
   NEXT
   // Set adeguate parameter
   FOR EACH s IN arrypar //Pi

      DO CASE
      CASE ascan(arrypar[HB_enumindex(s)],[ORIENTATION])=2   //SET ORIENTATION
         ::aStat[ 'Orient' ] := ;
            IF ([LAND] $ eval(chblk,arrypar[HB_enumindex(s)],[ORIENTATION]),2,1)
            //MSGBOX(VALTYPE(::aStat[ 'Orient' ]))

         CASE ascan(arryPar[HB_enumindex(s)],[PAPERSIZE])=2   //SET PAPERSIZE
            ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[PAPERSIZE]),::aCh,"_apaper")

         CASE ascan(arryPar[HB_enumindex(s)],[PAPERSIZE])=3   //SET PAPERSIZE
            ::aStat[ 'PaperSize' ]   := 0
            ::aStat[ 'PaperLength' ] := val(eval(chblk,arrypar[HB_enumindex(s)],[HEIGHT]))
            ::aStat[ 'PaperWidth' ]  := val(eval(chblk,arrypar[HB_enumindex(s)],[WIDTH] ))

         CASE ascan(arrypar[HB_enumindex(s)],[COPIE])= 2
            ::aStat[ 'Copies' ] := ;
               max(val(eval(chblk,arrypar[HB_enumindex(s)],[TO])) ,1 )

         CASE ascan(arrypar[HB_enumindex(s)],[BIN])= 2
            IF val(Arrypar[HB_enumindex(s),3])> 0
               ::aStat [ 'Source' ] := val(Arrypar[HB_enumindex(s),3])
            ELSE
               ::aStat [ 'Source' ] := ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[BIN]),::aCh,"_ABIN")
            ENDIF
            IF ::aStat [ 'Source' ] < 1
               ::aStat [ 'Source' ] := 1
            ENDIF

         CASE ascan(arrypar[HB_enumindex(s)],[QUALITY])= 2
            ::aStat [ 'Res' ] := ;
               ::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[QUALITY]),::aCh,"_aQlt")
            IF ::aStat [ 'Res' ] > -1
               ::aStat [ 'Res' ] := -3
            ENDIF

         CASE ascan(arrypar[HB_enumindex(s)],[COLORMODE])= 2
            ::aStat[ 'ColorMode' ] := ;
               if(val(arrypar[HB_enumindex(s),3])>0,val(arrypar[HB_enumindex(s),3]);
               ,if(arrypar[HB_enumindex(s),3]=".T.",2;
               ,::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[COLORMODE]),::aCh,"_acolor")))
            ::aStat[ 'ColorMode' ] := MIN (::aStat[ 'ColorMode' ] ,2)

         CASE ascan(arrypar[HB_enumindex(s)],[DUPLEX])= 2
            ::aStat[ 'Duplex' ] := ;
               max(::what_ele(eval(chblk,arrypar[HB_enumindex(s)],[DUPLEX]),::aCh,"_aDuplex"),1)

         CASE ascan(arrypar[HB_enumindex(s)],[COLLATE])= 2
            IF len(arrypar[HB_enumindex(s)])> 2
               ::aStat[ 'Collate' ] := ;
                  eval(blso,arrypar[HB_enumindex(s),3])
            ENDIF

         ENDCASE
      NEXT

      IF ::aStat[ 'PaperSize' ] > 0
         ::aStat[ 'PaperLength' ] := 0
         ::aStat[ 'PaperWidth'  ] := 0
      ENDIF
      IF ::aStat[ 'PaperLength' ] + ::aStat[ 'PaperWidth'  ] = 0
         ::aStat[ 'PaperSize' ] = 9 // A4 Default
      ELSE
         ::aStat[ 'PaperSize' ] = 256 // PAPER USER
      ENDIF
      IF (::aStat[ 'PaperLength' ] > 0 .and. ::aStat[ 'PaperWidth'  ] = 0) .or. ;
            (::aStat[ 'PaperWidth'  ] > 0 .and. ::aStat[ 'PaperLength' ] = 0)
         MsgExclamation("Incorrect page size !"+CRLF+"Please revise Heigth/width in your script.","Error")
      ENDIF

      RETURN NIL
      /*
      */

METHOD CheckAlign( arrypar, cmdline , section ) CLASS WREPORT //returns the correct alignment

   LOCAL vr:= "", _arg3, aAlign := {"CENTER","RIGHT","JUSTIFY"}

   empty(cmdline);empty(section)

   IF ASCAN(arryPar,[ALIGN]) > 0
      vr := rtrim(if("->" $ eval(chblk,arrypar,[ALIGN]) .or. [(] $ eval(chblk,arrypar,[ALIGN]),::MACROCOMPILE(eval(chblk,arrypar,[ALIGN]),.t.,cmdline,section),eval(chblk,arrypar,[ALIGN])))
   ELSE
      _arg3 := ascan( aAlign,atail (arrypar))
      IF _arg3 > 0
         vr := aAlign[_arg3]
      ELSE
         vr :=""
      ENDIF
   ENDIF

   RETURN vr
   /*
   */

METHOD Splash(prc_init,sezione,rit) CLASS WREPORT

   LOCAL rtv ,cbWork :={|x| x }
   PRIVATE ritspl

   DEFAULT sezione to ""
   DEFAULT prc_init to "_dummy_("+sezione+")"
   DEFAULT rit to .F.
   ritspl := rit
   IF _IsWIndowDefined ( "Form_splash" )
      Setproperty ("FORM_SPLASH","Label_1","VALUE", ::aStat [ 'lblsplash' ] )
      domethod("FORM_SPLASH","SHOW")
      ::choiceDrv()
      DOMETHOD("FORM_SPLASH","RELEASE")

      RETURN NIL
   ENDIF
   IF empty(::aStat[ 'lblsplash' ])
      DEFINE WINDOW FORM_SPLASH AT 140 , 235 WIDTH 0 HEIGHT 0 MODAL NOSHOW NOSIZE NOSYSMENU NOCAPTION ;
            ON INIT {||::choiceDrv()}

      ELSE
         DEFINE WINDOW FORM_SPLASH AT 140 , 235 WIDTH 550 HEIGHT 240 MODAL NOSIZE NOCAPTION ;
               ON INIT {||::choiceDrv()}

            DRAW RECTANGLE IN WINDOW Form_splash AT 2,2 TO 235, 548
         ENDIF
         DEFINE LABEL Label_1
            ROW    50
            COL    30
            WIDTH  480
            HEIGHT 122
            VALUE ::aStat[ 'lblsplash' ]
            FONTNAME "Times New Roman"
            FONTSIZE 36
            FONTBOLD .T.
            FONTCOLOR {255,0,0}
            CENTERALIGN .T.
         END LABEL

      END WINDOW

      CENTER WINDOW Form_Splash
      ACTIVATE WINDOW Form_Splash //NOWAIT
      rtv := ritspl
      RELEASE ritspl

      RETURN rtv
      /*
      */

METHOD DoPr() CLASS WREPORT

   *   ::argm:={_MainArea,_psd,db_arc,_prw}
   *   stampeEsegui(_MainArea,_psd,db_arc,_prw)
   CursorWait()
   ritspl := StampeEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
   CursorArrow()

   RETURN NIL
   /*
   */

METHOD DoMiniPr() CLASS WREPORT

   CursorWait()
   ritspl := PrminiEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
   CursorArrow()

   RETURN NIL
   /*
   */

METHOD DoPdf() CLASS WREPORT

   CursorWait()
   ritspl := PrPdfEsegui(::argm[1],::argm[2],::argm[3],::argm[4])
   CursorArrow()

   RETURN NIL
   /*
   */

METHOD ChoiceDrv() CLASS WREPORT

   DO CASE
   CASE oWr:PrnDrv = "HBPR"
      ::doPr()

   CASE oWr:PrnDrv = "MINI"
      ::doMiniPr()

   CASE oWr:PrnDrv = "PDF"
      ::dopdf()
   End

   RETURN NIL
   /*
   */

METHOD FgetLine(handle)  CLASS WREPORT

   LOCAL rt_line := '', chunk := '', bigchunk := '', at_chr13 :=0 , oldoffset := 0

   oldoffset := FSEEK(handle,0,1)
   DO WHILE .T.

      *- read in a chunk of the file
      chunk := ''
      chunk := Freadstr(handle,100)

      *- if we didn't read anything in, guess we're at the EOF
      IF LEN(chunk)=0
         endof_file := .T.

         IF !EMPTY(bigchunk)
            rt_line := bigchunk
         ENDIF
         EXIT
      ELSEIF len(bigchunk) > 1024
         EXIT
      ENDIF

      *- add this chunk to the big chunk
      bigchunk := bigchunk+chunk

      *- if we've got a CR , we've read in a line
      *- otherwise we'll loop again and read in another chunk
      IF AT(CHR(13),bigchunk) > 0
         at_chr13 := AT(CHR(13),bigchunk)

         *- go back to beginning of line
         FSEEK(handle,oldoffset)

         *- read in from here to next CR (-1)
         rt_line := Freadstr(handle,at_chr13-1)

         *- move the pointer 1 byte
         FSEEK(handle,1,1)

         EXIT
      ENDIF
   ENDDO

   *- move the pointer 1 byte
   *- this should put us at the beginning of the next line
   FSEEK(handle,1,1)

   RETURN rt_line

   /*
   */

METHOD Transpace(arg1,arg2,arg3) CLASS WREPORT // The core of parser

   LOCAL al1 := .F., al2 := .F., extFnc := .F. , tmpstr := '' , n
   LOCAL nr  := '', opp := 0 , pt := '', cdbl := .F., cdc := 0
   LOCAL last_func  := rat(")",arg1), last_sapex := rat(['],arg1)
   LOCAL last_Dapex := rat(["],arg1), last_codeb := rat([}],arg1)
   LOCAL arges := '' ;
      , aFsrc :={"SELECT"+CHR(7)+"FONT","DRAW"+CHR(7)+"TEXT","TEXTOUT"+CHR(7),"SAY"+CHR(7);
      ,"PRINT" +CHR(7),"GET"+CHR(7)+"TEXT","DEFINE"+CHR(7)+"FONT"}

   STATIC xcl := .F.
   DEFAULT arg2 to .T.
   arg1 := alltrim(arg1)
   arges := arg1
   // (#*&/) char exclusion
   IF left (arges,1) = chr(35) .or. left(arges,1) = chr(38); arges := '' ;Endif
   IF left (arges,2) = chr(47)+chr(47) ;arges := '' ;Endif
   IF left (arges,2) = chr(47)+chr(42) ; xcl := .T. ;Endif
   IF right(arges,2) = chr(42)+chr(47) ; xcl := .F. ;Endif
   IF left (arges,1) = chr(42) .or. empty(arges) .or. xcl

      RETURN ''
   ENDIF
   IF "SET SPLASH TO" $ arg1
      ::aStat [ 'lblsplash' ] := substr(arg1,at("TO",arg1)+2)
      // msgbox("|"+::aStat [ 'lblsplash' ]+"|" ,"Arges")

      RETURN ''
   ENDIF
   FOR n := 1 to len (arg1)
      pt := substr(arg1,n,1)
      IF pt <> chr(32)
         tmpstr := pt
         nr += pt
         IF tmpstr == chr(40) //.or. upper(substr(arg1,2,3)) = [VAR]  // (=chr(40)
            opp ++
            extFnc := .T.     // Interno a Funzione
         ENDIF
         IF tmpstr == chr(41) // ")"
            opp --
            extFnc := .F.    // Fine Funzione
         ENDIF
         IF tmpstr == '"' .or. tmpstr == '[' .or. tmpstr == ['] .or. tmpstr == [{]
            al1 := !al1
            IF tmpstr == '{'
               cdc ++
            ENDIF
         ENDIF
         IF tmpstr == "]" .or. n = last_Dapex .or. n = last_sapex .or. n = last_codeb  .or. tmpstr == [}]
            al1 := .F.
            IF tmpstr == [}]
               cdc --
            ENDIF
         ENDIF
         IF n >= last_func
            extFnc := .F.
            al2 := .F.
         ENDIF
         IF tmpstr = "|" .and. cdc > 0
            extfnc := .T.
         ELSEIF cdc < 1
            extfnc := .F.
         ENDIF
         IF Pt == ',' .and. extFnc == .F. .and. al1 == .F. .and. opp < 1
            nr := substr(nr,1,len(nr)-1) + chr(07)
         ENDIF
      ELSE
         IF extFnc == .F.        //esterno a funzione
            IF al1 == .F.
               IF opp < 1
                  nr += IIF(al2," ",chr(07)) //"/")
               ENDIF
            ELSE
               nr += pt
            ENDIF
         ELSE
            nr += pt
         ENDIF
      ENDIF
   NEXT
   nr := strtran(nr,chr(07)+chr(07),chr(07))
   tmpstr = left(ltrim(nr),1)
   DO CASE
   CASE tmpstr = chr(60) .or. tmpstr = "@" .or. tmpstr = chr(07) //"<" ex "{"
      nr := substr(nr,2)

   CASE left(nr,1) = chr(07) .or. left(nr,1) = chr(64)
      nr := substr(nr,2)

   CASE right(nr,1)=chr(62) //">" ex "}"
      nr := substr(nr,1,rat(">",nr)-1)

   CASE ")" == alltrim(nR) .or. "(" == alltrim(nR)
      nr := ''

   ENDCASE
   nr := STRTRAN(nr,chr(07)+chr(07),chr(07))
   IF arg2
      arg1 := upper(nr)
      aeval(aFsrc,{|x|if ( at(x,arg1) > 0, aadd(_aFnt,{upper(Nr),arg3}), Nil ) } )
   ENDIF

   RETURN nr
   /*
   */

METHOD MACROCOMPILE(cStr, lMesg,cmdline,section) CLASS WREPORT

   LOCAL bOld,xResult, dbgstr:='', lvl:= 0

   DEFAULT cmdline to 0, section to ''
   IF lMesg == NIL

      RETURN &(cStr)
   ENDIF
   bOld := ErrorBlock({|| break(NIL)})
   BEGIN SEQUENCE
      xResult := &(cStr)
   RECOVER
      IF lMesg
         //msgBox(alltrim(cStr),"Error in evaluation of:")
         errorblock (bOld)
         IF ::aStat [ 'Control' ]
            MsgMiniGuiError("Program Report Interpreter"+CRLF+"Section "+section+CRLF+"I have found error on line "+;
               ZAPs(cmdline)+CRLF+"Error is in: "+alltrim(cStr)+CRLF+"Please revise it!","MiniGUI Error")
            Break
         ELSE
            DO CASE
            CASE SECTION = "STAMPEESEGUI"
               SECTION :="DECLARE : "
            CASE SECTION = "PORT:THEBODY"
               SECTION :="BODY       : "
            CASE SECTION = "PORT:THEMINIBODY"
               SECTION :="BODY       : "
            CASE SECTION = "WREPORT_THEHEAD"
               SECTION :="HEAD       : "
            CASE SECTION = "WREPORT_THEFEET"
               SECTION :="FEET         : "
            ENDCASE

            dbgstr := section+" "+zaps(cmdline)+" With: "+cStr
            aeval(::aStat[ 'ErrorLine' ],{|x|if (dbgstr == x,  lvl:=1 ,'')} )
            IF lvl < 1 .and. cmdline > 0 //# ::aStat [ 'ErrorLine' ]
               MSGSTOP(dbgstr,"MiniGui Extended Report Interpreter Error")
               IF ascan( ::aStat [ 'ErrorLine' ] , dbgstr ) < 1
                  aadd(::aStat [ 'ErrorLine' ] , dbgstr )
               ENDIF
            ENDIF
            ::aStat [ 'OneError' ]  := .T.
            break
         ENDIF
      ENDIF
      xResult := "**Error**:"+cStr
   END SEQUENCE
   errorblock (bOld)

   RETURN xResult
   /*
   */

METHOD Traduci(elemento,ctrl,cmdline) CLASS WREPORT  // The interpreter

   LOCAL string, ritorno :=.F., ev1th, sSection, dbg := ''
   LOCAL TransPar:={}, ArryPar :={}, cWord
   LOCAL oErrAntes, oErr, lMyError := .F., ifc:='',IEXE := .F.

   sSection := iif(procname(1)="STAMPEESEGUI","DECLARE",substr(procname(1),4))
   DEFAULT ctrl to .F.
   string := alltrim(elemento)

   IF empty(string);return ritorno ;Endif

   DO CASE
   CASE upper(left(string,8))="DEBUG_ON"
      ::aStat [ 'Control' ] := .T.

      RETURN RITORNO
   CASE upper(left(string,8))="DEBUG_OF"
      ::aStat [ 'Control' ] := .F.
      ::aStat['DebugType'] := "LINE"
   CASE upper(left(string,9))=="SET"+chr(07)+"DEBUG"
      dbg := upper(right(string,4))
      ::aStat [ 'Control' ] := if(val(dbg)> 0,.t.,if(".T." $ dbg .or. "ON" $ Dbg ,.t.,.F.))
      IF "LINE" $ dbg
         ::aStat [ 'Control' ] := .t.
         ::aStat['DebugType'] := "LINE"
      ENDIF
      IF "STEP" $ dbg
         ::aStat [ 'Control' ] := .t.
         ::aStat['DebugType'] := "STEP"
      ENDIF

      RETURN RITORNO
   ENDCASE

   TOKENINIT(string,chr(07))    //set the command separator -> ONLY A BEL

   WHILE ! TOKENEND()           //                             ----
      cWord  :=  TOKENNEXT(String)
      IF left(cword,1)="[" .and. right(cword,1) <> "]"
         cword := substr(cword,2)+" "+TOKENNEXT(String)
         WHILE .t.
            IF right(cword,1)="]"
               cword := substr(cword,1,len(cword)-1)
               cword := strtran(cword,chr(4),"/")
               aadd(TransPar,cWord)
               EXIT
            ELSE
               cword += " "+TOKENNEXT(String)
            ENDIF
         end
      ELSEIF left(cword,1)="[" .AND. "]" $ cWord
         cWord := substr(cword,at("[",cWord)+1,rat("]",cword)-2)
         cword := strtran(cword,chr(4),"/")
         aadd(TransPar,cWord)
      ELSE
         IF "[" $ cWord .or. ["] $ cWord .or. ['] $ cWord
            cword := strtran(cword,chr(4),"/")
            aadd(TransPar,cWord)
         ELSE
            cword := strtran(cword,chr(4),"/")
            aadd(TransPar,upper(cWord))
         ENDIF
      ENDIF
   END

   IF "{" $ left(TransPar[1],2)
      ev1th := alltrim(substr(TransPar[1],at("||",TransPar[1])+2,at("}",Transpar[1])-4))
      IF empty(ev1th)
         MsgMiniGuiError("Program Report Interpreter"+CRLF+"Section: "+procname(1);
            +" command n› "+zaps(cmdline)+CRLF+"Program terminated","MiniGUI Error")
      ENDIF
      DO CASE
      CASE ev1th = ".T."
         adel(TransPar,1)

      CASE ev1th = ".F."
         adel(TransPar,1)

         RETURN ritorno
      OTHERWISE

         IF eval(epar,ev1th)
            adel(TransPar,1)
            ritorno := .F.
         ELSE
            IF sSEction=="HEAD"
               nline ++
            ENDIF
            ritorno := .t.
         ENDIF
      ENDCASE
   ENDIF
   ifc := alltrim( upper( TransPar[1] ) )
   oErrAntes := ERRORBLOCK({ |objErr| BREAK(objErr) } )
   BEGIN SEQUENCE
      IF ifc == "IF"     /// Start adaptation if else construct - 03/Feb/2008
         ::aStat [ 'EntroIF' ] := .T.
         ifc := substr(string,at(chr(07),string)+1 )
         IF &ifc //MACROCOMPILE(ifc,.t.,cmdline,ssection)
            // msgbox(ifc,"valido")
            ::aStat [ 'DelMode' ] := .F.
         ELSE
            // msgstop(ifc, "Non valido")
            ::aStat [ 'DelMode' ]:= .T.
         ENDIF
      ELSEIF "ENDI" $ ifc
         TransPar := {}
         ::aStat [ 'DelMode' ] := .F.
         ::aStat [ 'ElseStat' ] := .F.
      ELSEIF "ELSE" $ ifc
         ::aStat [ 'EntroIF' ] := .F.
         ::aStat [ 'ElseStat' ] := .T.
      ENDIF
      //msgbox(if( ::aStat [ 'DelMode' ]," ::aStat [ 'DelMode' ] .t.","::aStat [ 'DelMode' ] .F.")+crlf+if( ::aStat [ 'ElseStat' ]," ::aStat [ 'ElseStat' ] .t.","::aStat [ 'ElseStat' ] .F.")," risulta")
      IF !::aStat [ 'EntroIF' ] .and. !::aStat [ 'DelMode' ] // i am on false condition
         IF ::aStat [ 'ElseStat' ]
            //msginfo(ifc ,"Cancellato")
            adel(TransPar,1)    // i must erase else commands
         ENDIF
      ENDIF
      IF ::aStat [ 'EntroIF' ] .and. ::aStat [ 'DelMode' ] // i am on verified condition
         IF ::aStat [ 'DelMode' ] .and. !::aStat [ 'ElseStat' ]
            //msgbox(ifc ,"Cancellato")
            adel(TransPar,1)// i must erase if commands
         ENDIF
      ENDIF

      aeval(transpar,{|x| if(x # NIL,aadd(ArryPar,X), nil ) } )

      IF (::aStat [ 'Control' ] .and. (UPPER(LEFT(STRING,5)) <> "DEBUG") ) .and.  npag < 2
         IF ::aStat['DebugType'] = "LINE"
            MsgBox("Section "+ssection+" Line is n∞ "+zaps(cmdline)+CRLF+"String = "+string ;
               ,::Filename+[ Pag n∞]+zaps(npag))
         ELSEIF ::aStat['DebugType'] = "STEP"
            aeval(Arrypar,{|x,y|x:=nil,MsgBox("Section "+ssection+" Line is n∞ "+zaps(cmdline)+CRLF+"String =";
               +string+CRLF+CRLF+"Argument N∞-> "+zaps(y)+[ ]+ArryPar[y],::Filename+[ Pag n∞]+zaps(npag))})
         ENDIF
      ENDIF
      ::leggipar(Arrypar,cmdline,substr(procname(1),4))
   RECOVER USING oErr
      IF oErr <> NIL
         lMyError := .T.
         MyErrorFunc(oErr)
      ENDIF
   END
   ERRORBLOCK(oErrAntes)
   IF lMyError .and. ::aStat [ 'Control' ]
      MsgBox("Error in  line n∞ "+zaps(cmdline)+CRLF+string,+::Filename+[ Pag n∞]+zaps(npag) )
   ENDIF
   */

   RETURN ritorno
   /*
   */

METHOD Leggipar(ArryPar,cmdline,section) CLASS WREPORT // The core of  interpreter

   LOCAL _arg1,_arg2, _arg3,__elex ,aX:={} , _varmem ,;
      blse := {|x| if(val(x)> 0,.t.,if(x=".T.".or. x ="ON",.T.,.F.))}, al, _align;

   string1 := ''
   empty(_arg3)
   IF len (ArryPar) < 1 ;return .F. ;Endif

   DO CASE
   CASE ::PrnDrv = "MINI"
      //msginfo(arrypar[1],"Rmini")
      RMiniPar(ArryPar,cmdline,section)

   CASE ::PrnDrv = "PDF"
      //msginfo(arrypar[1],"Pdf")
      RPdfPar(ArryPar,cmdline,section)

   CASE ::PrnDrv = "HBPR"
      //msginfo(arrypar[1],"HBPRN")
      m->MaxCol := hbprn:maxcol
      //m->MaxRow := hbprn:maxrow
      DO CASE
      CASE ArryPar[1]=[VAR]
         _varmem := ArryPar[2]
         IF ! __MVEXIST ( ArryPar[2] )
            _varmem := ArryPar[2]
            PUBLIC &_varmem

            aadd(nomevar,_varmem)
         ENDIF
         DO CASE
         CASE ArryPar[3] == "C"
            &_varmem := xvalue(ArryPar[4],ArryPar[3])

         CASE ArryPar[3] == "N"
            &_varmem := xvalue(ArryPar[4],ArryPar[3])

         CASE ArryPar[3] == "A"
            &_varmem := ::MACROCOMPILE("("+ArryPar[4]+")",.t.,cmdline,section)

         CASE ArryPar[4] == "C"
            &_varmem := xvalue(ArryPar[3],ArryPar[4])

         CASE ArryPar[4] == "N"
            &_varmem := xvalue(ArryPar[3],ArryPar[4])

         CASE ArryPar[4] == "A"
            &_varmem := ::MACROCOMPILE("("+ArryPar[3]+")",.t.,cmdline,section)
         ENDCASE
         //msgmulty({&_varmem[1],valtype(&_varmem),_varmem})

      CASE arryPar[1]==[GROUP]
         Group(arryPar[2],arryPar[3],arryPar[4],arryPar[5],arryPar[6],arryPar[7],arryPar[8],arryPar[9])
         /* Alternate method
         aX:={} ; aeval(ArryPar,{|x,y|if (Y >1,aadd(aX,x),Nil)})
         Hb_execFromarray("GROUP",ax)
         asize(ax,0)
         */
      CASE arryPar[1]==[ADDLINE]
         nline ++

      CASE arryPar[1]==[SUBLINE]
         nline --

      CASE ascan(arryPar,[HBPRN ]) > 0
         HBPRNMAXROW:=hbprn:maxrow

      CASE len(ArryPar)=1
         //msgExclamation(arrypar[1],"int Traduci")
         IF "DEBUG_" != left(ArryPar[1],6) .and. "ELSE" != left(ArryPar[1],4)
            ::MACROCOMPILE(ArryPar[1],.t.,cmdline,section)
         ENDIF

      CASE ArryPar[1]+ArryPar[2]=[ENABLETHUMBNAILS]
         hbprn:thumbnails:=.t.

      CASE ArryPar[1]=[POLYBEZIER]
         hbprn:polybezier(&(arrypar[2]),eval(chblk,arrypar,[PEN]))

      CASE ArryPar[1]=[POLYBEZIERTO]
         hbprn:polybezierto(&(arrypar[2]),eval(chblk,arrypar,[PEN]))

      CASE ArryPar[1]+ArryPar[2]=[DEFINEBRUSH]
         hbprn:definebrush(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_abrush");
            ,::UsaColor(eval(chblk,arrypar,[COLOR])),::HATCH(eval(chblk,arrypar,[HATCH])))

      CASE ArryPar[1]+ArryPar[2]=[CHANGEBRUSH]
         hbprn:changebrush(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_abrush");
            ,color(eval(chblk,arrypar,[COLOR])),::HATCH(eval(chblk,arrypar,[HATCH])))

      CASE ArryPar[1]+ArryPar[2]=[CHANGEPEN]
         hbprn:modifypen(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_apen"),val(eval(chblk,arrypar,[WIDTH])),color(eval(chblk,arrypar,[COLOR])))

      CASE ArryPar[1]+ArryPar[2]=[DEFINEIMAGELIST]
         hbprn:defineimagelist(Arrypar[3],eval(chblk,arrypar,[PICTURE]),eval(chblk,arrypar,[ICONCOUNT]))

      CASE ascan(arrypar,[IMAGELIST]) > 0 .and. len(arrypar) > 6
         DO CASE
         CASE ascan(arryPar,[BLEND25]) > 0
            hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
               ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
               ,ILD_BLEND25,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

         CASE ascan(arryPar,[BLEND50]) > 0
            hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
               ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
               ,ILD_BLEND50,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

         CASE ascan(arryPar,[MASK]) > 0
            hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
               ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
               ,ILD_MASK,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

         OTHERWISE
            hbprn:drawimagelist(eval(chblk,arrypar,[IMAGELIST]),val(eval(chblk,arrypar,[ICON]));
               ,eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
               ,ILD_NORMAL,::UsaColor(eval(chblk,arrypar,[BACKGROUND])))

         ENDCASE

      CASE ArryPar[1]+ArryPar[2]=[DEFINEPEN]
         hbprn:definepen(Arrypar[3],::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_apen"),val(eval(chblk,arrypar,[WIDTH])),color(eval(chblk,arrypar,[COLOR])))

      CASE ArryPar[1]+ArryPar[2]=[DEFINERECT]
         hbprn:definerectrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
            ,val(Arrypar[7]),val(Arrypar[8]),val(Arrypar[9]))

      CASE ArryPar[1]+ArryPar[2]=[DEFINEROUNDRECT]
         hbprn:defineroundrectrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
            ,val(Arrypar[7]),val(Arrypar[8]),val(Arrypar[9]);
            ,eval(chblk,arrypar,[ELLIPSE]),Val(ArryPar[12]))

      CASE ArryPar[1]+ArryPar[2]=[DEFINEPOLYGON]
         hbprn:definepolygonrgn(eval(chblk,arrypar,[REGION]),&(eval(chblk,arrypar,[VERTEX]));
            ,eval(chblk,arrypar,[STYLE]))

      CASE ArryPar[1]+ArryPar[2]=[DEFINEELLIPTIC]
         hbprn:defineEllipticrgn(eval(chblk,arrypar,[REGION]),val(eval(chblk,arrypar,[AT]));
            ,eval(epar,ArryPar[7]),eval(epar,ArryPar[8]),eval(epar,ArryPar[9]))

      CASE ArryPar[1]+arryPar[2]=[DEFINEFONT]
         //                    1        2      3      4       5        6        7            8            9
         //hbprn:definefont(<cfont>,<cface>,<size>,<width>,<angle>,<.bold.>,<.italic.>,<.underline.>,<.strikeout.>)
         hbprn:definefont(if(ascan(arryPar,[FONT])=2,ArryPar[3],NIL);
            ,if(ascan(arryPar,[NAME])=4,ArryPar[5],NIL);
            ,if(ascan(arryPar,[SIZE])=6,VAL(ArryPar[7]),NIL);
            ,if(ascan(arryPar,[WIDTH])# 0, VAL(eval(chblk,arrypar,[WIDTH])),NIL);
            ,if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL);
            ,if(ascan(arryPar,[BOLD])# 0,1,"");
            ,if(ascan(arryPar,[ITALIC])# 0,1,"");
            ,if(ascan(arryPar,[UNDERLINE])# 0,1,"");
            ,if(ascan(arryPar,[STRIKEOUT])# 0,1,""))

      CASE ArryPar[1]+arryPar[2]=[CHANGEFONT]
         hbprn:modifyfont(if(ascan(arryPar,[FONT])=2,ArryPar[3],NIL);
            ,if(ascan(arryPar,[NAME])=4,ArryPar[5],NIL);
            ,if(ascan(arryPar,[SIZE])=6,VAL(ArryPar[7]),NIL);
            ,if(ascan(arryPar,[WIDTH])# 0, VAL(eval(chblk,arrypar,[WIDTH])),NIL);
            ,if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL);
            ,if(ascan(arryPar,[BOLD])#0,.T.,.F.);
            ,if(ascan(arryPar,[NOBOLD])#0,.T.,.F.);
            ,if(ascan(arryPar,[ITALIC])#0,.t.,.F.);
            ,if(ascan(arryPar,[NOITALIC])#0,.t.,.F.);
            ,if(ascan(arryPar,[UNDERLINE])#0,.t.,.F.);
            ,if(ascan(arryPar,[NOUNDERLINE])#0,.t.,.F.);
            ,if(ascan(arryPar,[STRIKEOUT])#0,.t.,.F.);
            ,if(ascan(arryPar,[NOSTRIKEOUT])#0,.t.,.F.))

      CASE ArryPar[1]+arryPar[2]=[COMBINEREGIONS]
         hbprn:combinergn(eval(chblk,arrypar,[TO]),ArryPar[3],ArryPar[4];
            ,if( val(ArryPar[8])>0,val(ArryPar[8]),::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_aRegion")))

      CASE ascan(arryPar,"SELECT")=1 .and. len(ArryPar)=3
         IF len(ArryPar)=3
            DO CASE
            CASE ascan(ArryPar,[PRINTER])=2
               hbprn:selectprinter(arrypar[3])

            CASE ascan(ArryPar,[FONT])=2
               hbprn:selectfont(arrypar[3])

            CASE ascan(ArryPar,[PEN])=2
               hbprn:selectpen(arrypar[3])

            CASE ascan(ArryPar,[BRUSH])=2
               hbprn:selectbrush(arrypar[3])

            ENDCASE
         ENDIF

      CASE ArryPar[1]+ArryPar[2]="SELECTCLIP" .and. len(ArryPar)=4
         hbprn:selectcliprgn(eval(chblk,arrypar,[REGION]))

      CASE ascan(arryPar,"DELETE")=1 .and. len(ArryPar)=4
         hbprn:deletecliprgn()

      CASE ascan(arryPar,"SET")=1
         DO CASE
         CASE ascan(arryPar,[VRULER])= 2
            ::astat ['VRuler'][1] := val(eval(chblk,arrypar,[VRULER]))
            IF len(arrypar) > 3
               ::astat ['VRuler'][2] := eval(blse,eval(chblk2,arrypar,[VRULER]))
            ELSE
               ::astat ['VRuler'][2] := .F.
            ENDIF

         CASE ascan(arryPar,[HRULER])= 2
            ::astat ['HRuler'][1] := val(eval(chblk,arrypar,[HRULER]))
            IF len(arrypar) > 3
               ::astat ['HRuler'][2] := eval(blse,eval(chblk2,arrypar,[HRULER]))
            ELSE
               ::astat ['HRuler'][2] := .F.
            ENDIF

         CASE ascan(arryPar,[COPIES])= 2
            ::aStat[ 'Copies' ] := val(eval(chblk,arrypar,[TO]))
            hbprn:setdevmode(256,::aStat[ 'Copies' ] )

         CASE ascan(arryPar,[JOB])= 2
            ::aStat [ 'JobName' ] := eval(chblk,arrypar,[NAME])

         CASE ascan(ArryPar,[PAGE])=2
            _arg1 :=eval(chblk,arrypar,[ORIENTATION])
            ::aStat[ 'Orient' ] := if([LAND]$ _arg1,2,1)
            ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar,[PAPERSIZE]),::aCh,"_apaper")
            _arg2 :=eval(chblk,arrypar,[FONT])
            hbprn:setpage(if(val(_arg1)>0,val(_arg1),::aStat[ 'Orient' ]);
               ,::aStat[ 'PaperSize' ],_arg2)

         CASE ascan(arryPar,[ALIGN])=3
            IF val(Arrypar[4])> 0
               _align := val(Arrypar[4])
            ELSE
               _align := ::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign")
            ENDIF
            hbprn:settextalign(_align)

         CASE ascan(arryPar,[RGB])=2
            &(eval(chblk,arrypar,[TO])):=hbprn:setrgb(arrypar[1],arrypar[2],arrypar[3])

         CASE ascan(arryPar,[SCALE])=3      //SET SCALE
            IF ascan(arryPar,[SCALE])> 0
               hbprn:previewscale:=(val(eval(chblk,arrypar,[SCALE])))
            ELSEIF ascan(arryPar,[RECT])> 0
               hbprn:previewrect:={eval(epar,arrypar[4]),eval(epar,arrypar[5]),eval(epar,arrypar[6]),eval(epar,arrypar[7])}
            ENDIF

         CASE ascan(ArryPar,[DUPLEX])=2
            ::aStat[ 'Duplex' ] := ::what_ele(eval(chblk,arrypar,[DUPLEX]),::aCh,"_aDuplex")
            hbprn:setdevmode(DM_DUPLEX,::aStat[ 'Duplex' ])

         CASE ascan(ArryPar,[PREVIEW])=2 .and. len(arrypar)= 3
            hbprn:PreviewMode := if(eval(chblk,arrypar,[PREVIEW])=[OFF],.F.,.T.)

         CASE ascan(arryPar,[BIN])=2
            IF val(Arrypar[3])> 0
               ::aStat [ 'Source' ] := val(Arrypar[3])
               hbprn:setdevmode(DM_DEFAULTSOURCE,val(Arrypar[3]))
            ELSE
               ::aStat [ 'Source' ] := ::what_ele(eval(chblk,arrypar,[BIN]),::aCh,"_ABIN")
               hbprn:setdevmode(DM_DEFAULTSOURCE,::aStat [ 'Source' ] )
            ENDIF

         CASE ascan(arryPar,[PAPERSIZE])=2   //SET PAPERSIZE
            ::aStat[ 'PaperSize' ] := ::what_ele(eval(chblk,arrypar,[PAPERSIZE]),::aCh,"_apaper")
            hbprn:setdevmode(DM_PAPERSIZE,::aStat[ 'PaperSize' ])

         CASE ascan(arryPar,[PAPERSIZE])=3   //SET PAPERSIZE
            ::aStat[ 'PaperLength' ] := val(eval(chblk,arrypar,[HEIGHT]))
            ::aStat[ 'PaperWidth' ]  := val(eval(chblk,arrypar,[WIDTH] ))
            // SET USER PAPERSIZE WIDTH <width> HEIGHT <height> => hbprn:setusermode(DMPAPER_USER,<width>,<height>)
            hbprn:setusermode(256,::aStat[ 'PaperWidth' ],::aStat[ 'PaperLength' ])

         CASE ascan(arryPar,[ORIENTATION])=2   //SET ORIENTATION
            IF [LAND] $ eval(chblk,arrypar,[ORIENTATION])
               oWr:aStat[ 'Orient' ] := 2
               hbprn:setdevmode(DM_ORIENTATION,DMORIENT_LANDSCAPE) //DMORIENT_LANDSCAPE
            ELSE
               oWr:aStat[ 'Orient' ] := 1
               hbprn:setdevmode(DM_ORIENTATION,DMORIENT_PORTRAIT) //DMORIENT_PORTRAIT
            ENDIF

         CASE ascan(arryPar,[UNITS])=2
            DO CASE
            CASE arryPar[3]==[ROWCOL] .OR. LEN(ArryPar)==2
               hbprn:setunits(0)

            CASE arryPar[3]==[MM]
               hbprn:setunits(1)

            CASE arryPar[3]==[INCHES]
               hbprn:setunits(2)

            CASE arryPar[3]==[PIXELS]
               hbprn:setunits(3)

            ENDCASE
            oWr:checkUnits(hbprn:units)

         CASE ascan(arryPar,[BKMODE])=2
            IF val(Arrypar[3])> 0
               hbprn:setbkmode(val(Arrypar[3]))
            ELSE
               hbprn:setbkmode(::what_ele(eval(chblk,arrypar,[BKMODE]),::aCh,"_aBkmode"))
            ENDIF

         CASE ascan(ArryPar,[CHARSET])=2
            hbprn:setcharset(::what_ele(eval(chblk,arrypar,[CHARSET]),::aCh,"_acharset"))

         CASE ascan(arryPar,[TEXTCOLOR])=2
            hbprn:settextcolor( ::UsaColor( eval( chblk,arrypar,[TEXTCOLOR] ) ) )

         CASE ascan(arryPar,[BACKCOLOR])=2
            hbprn:setbkcolor( ::UsaColor( eval( chblk,arrypar,[BACKCOLOR] ) ) )

         CASE ascan(arryPar,[ONEATLEAST])= 2
            ONEATLEAST :=eval(blse,arrypar[3])

         CASE ascan(arryPar,[THUMBNAILS])= 2
            hbprn:thumbnails:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[EURO])=2
            _euro:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[CLOSEPREVIEW])=2
            hbprn:closepreview(eval(blse,arrypar[3]))

         CASE ascan(arryPar,[SUBTOTALS])=2
            m->sbt := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[SHOWGHEAD])=2
            m->sgh := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[INLINESBT])=2
            ::aStat['InlineSbt'] := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[INLINETOT])=2
            ::aStat['InlineTot'] := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[TOTALSTRING])=2
            m->TTS := eval( chblk,arrypar,[TOTALSTRING] )

         CASE ascan(arryPar,[MONEY])=2
            _money:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[SEPARATOR])=2
            _separator:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[JUSTIFICATION])=3
            hbprn:settextjustification(val(ArryPar[4]))

         CASE ascan(arryPar,[MARGINS])=3
            hbprn:setviewportorg(val(eval(chblk,arrypar,[TOP])),val(eval(chblk,arrypar,[LEFT])))

         CASE (ascan(ArryPar,[POLYFILL])=2 .and. Arrypar[3]==[MODE])
            IF val(Arrypar[4])> 0
               hbprn:setpolyfillmode(val(Arrypar[4]))
            ELSE
               hbprn:setpolyfillmode(::what_ele(eval(chblk,arrypar,[MODE]),::aCh,"_apoly"))
            ENDIF

         CASE ascan(ArryPar,[POLYFILL])=2 .and. len(arrypar)=3
            hbprn:setpolyfillmode(::what_ele(eval(chblk,arrypar,[POLYFILL]),::aCh,"_aPoly"))

         CASE ascan(ArryPar,[VIEWPORTORG])=2
            hbprn:setviewportorg(val(Arrypar[3]),Val(arrypar[4]))

         CASE ascan(ArryPar,[TEXTCHAR])=2
            hbprn:settextcharextra(Val(eval(chblk,arrypar,[EXTRA])))

         CASE ArryPar[2]= [COLORMODE] //=1
            ::aStat[ 'ColorMode' ] :=;
               if(val(arrypar[3])>0,val(arrypar[3]),if(arrypar[3]=".T.",2;
               ,::what_ele(eval(chblk,arrypar,[COLORMODE]),::aCh,"_acolor")))
            hbprn:setdevmode(DM_COLOR,::aStat[ 'ColorMode'])

         CASE ArryPar[2]= [QUALITY]   //=1
            ::aStat [ 'Res' ] := ::what_ele(eval(chblk,arrypar,[QUALITY]),::aCh,"_aQlt")
            hbprn:setdevmode(DM_PRINTQUALITY,::aStat [ 'Res' ])

         ENDCASE

      CASE ascan(arryPar,"GET")=1

         DO CASE
         CASE ascan(arryPar,[TEXTCOLOR])> 0
            IF len(ArryPar)> 3
               &(eval(chblk,arrypar,[TO])):=hbprn:gettextcolor()
            ELSE
               &(eval(chblk,arrypar,[TEXTCOLOR])):=hbprn:gettextcolor()
            ENDIF

         CASE ascan(arryPar,[BACKCOLOR])> 0
            IF len(ArryPar)> 3
               &(eval(chblk,arrypar,[TO])):=hbprn:getbkcolor()
            ELSE
               &(eval(chblk,arrypar,[BACKCOLOR])):=hbprn:getbkcolor()
            ENDIF

         CASE ascan(arryPar,[BKMODE])> 0
            IF len(ArryPar)> 3
               &(eval(chblk,arrypar,[TO])):=hbprn:getbkmode()
            ELSE
               &(eval(chblk,arrypar,[BKMODE])):=hbprn:getbkmode()
            ENDIF

         CASE ascan(arryPar,[ALIGN])> 0
            IF len(ArryPar)> 4
               &(eval(chblk,arrypar,[TO])):=hbprn:gettextalign()
            ELSE
               &(eval(chblk,arrypar,[ALIGN])):=hbprn:gettextalign()
            ENDIF

         CASE ascan(arryPar,[EXTENT])> 0
            hbprn:gettextextent(eval(chblk,arrypar,[EXTENT]);
               ,&(eval(chblk,arrypar,[TO])),if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL))

         CASE ArryPar[1]+ArryPar[2]+ArryPar[3]+ArryPar[4]=[GETPOLYFILLMODETO]
            &(eval(chblk,arrypar,[TO])):=hbprn:getpolyfillmode()

         CASE ArryPar[2]+ArryPar[3]=[VIEWPORTORGTO]
            hbprn:getviewportorg()
            &(eval(chblk,arrypar,[TO])):=aclone(hbprn:viewportorg)

         CASE ascan(ArryPar,[TEXTCHAR])=2
            &(eval(chblk,arrypar,[TO])):=hbprn:gettextcharextra()

         CASE ascan(arryPar,[JUSTIFICATION])=3
            &(eval(chblk,arrypar,[TO])):=hbprn:gettextjustification()

         ENDCASE

      CASE ascan(arryPar,[START])=1 .and. len(ArryPar)=2
         IF ArryPar[2]=[DOC]
            hbprn:startdoc()
         ELSEIF ArryPar[2]=[PAGE]
            hbprn:startpage()
         ENDIF

      CASE ascan(arryPar,[END])=1 .and. len(ArryPar)=2
         IF ArryPar[2]=[DOC]
            hbprn:enddoc()
         ELSEIF ArryPar[2]=[PAGE]
            hbprn:endpage()
         ENDIF

      CASE ascan(arryPar,[POLYGON])=1
         hbprn:polygon(&(arrypar[2]),eval(chblk,arrypar,[PEN]);
            ,eval(chblk,arrypar,[BRUSH]),eval(chblk,arrypar,[STYLE]))

      CASE ascan(arryPar,[DRAW])=5 .and. ascan(arryPar,[TEXT])=6
         /*
         aeval(arrypar,{|x,y|msginfo(x,zaps(y)) } )
         #xcommand @ <row>,<col>,<row2>,<col2> DRAW TEXT <txt> [STYLE <style>] [FONT <cfont>];
         => hbprn:drawtext(<row>,<col>,<row2>,<col2>,<txt>,<style>,<cfont>)
         */
         //msgbox(zaps(::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE")),"GGGGG")
         al := ::UsaFont(arrypar)

         hbprn:drawtext(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]);
            ,eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),eval(chblk,arrypar,[TEXT]);
            ,::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE"), "Fx" )

         hbprn:settextalign( al[1] )
         hbprn:settexcolor ( al[2] )

      CASE ascan(arryPar,[RECTANGLE])=5
         //MSG([PEN=]+eval(chblk,arrypar,[PEN])+CRLF+[BRUSH=]+eval(chblk,arrypar,[BRUSH]),[RETTANGOLO])
         hbprn:rectangle(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
            ,eval(chblk,arrypar,[PEN]),eval(chblk,arrypar,[BRUSH]))

      CASE ascan(ArryPar,[FRAMERECT])=5 .OR. ascan(ArryPar,[FOCUSRECT])=5
         hbprn:framerect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
            ,eval(chblk,arrypar,[BRUSH]))

      CASE ascan(ArryPar,[FILLRECT])=5
         hbprn:fillrect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
            ,eval(chblk,arrypar,[BRUSH]))

      CASE ascan(ArryPar,[INVERTRECT])=5
         hbprn:invertrect(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]))

      CASE ascan(ArryPar,[ELLIPSE])=5
         hbprn:ellipse(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]);
            ,eval(chblk,arrypar,[PEN]), eval(chblk,arrypar,[BRUSH]))

      CASE ascan(arryPar,[RADIAL1])>0
         DO CASE
         CASE arrypar[5]=[ARC]
            hbprn:arc(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
               ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
               ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]))

         CASE arrypar[3]=[ARCTO]
            hbprn:arcto(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[5]);
               ,eval(epar,Arrypar[6]),eval(epar,Arrypar[8]),eval(epar,Arrypar[9]);
               ,eval(chblk,arrypar,[PEN]))

         CASE arrypar[5]=[CHORD]
            hbprn:chord(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
               ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
               ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]);
               ,eval(chblk,arrypar,[BRUSH]))

         CASE arrypar[5]=[PIE]
            hbprn:pie(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]);
               ,eval(epar,Arrypar[4]),eval(epar,Arrypar[7]),eval(epar,Arrypar[8]);
               ,eval(epar,Arrypar[10]),eval(epar,Arrypar[11]),eval(chblk,arrypar,[PEN]);
               ,eval(chblk,arrypar,[BRUSH]))

         ENDCASE

      CASE ASCAN(ArryPar,[LINETO])=3
         hbprn:lineto(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),if(ASCAN(ArryPar,[PEN])= 4,ArryPar[5],NIL))

      CASE ascan(ArryPar,[LINE])=5
         hbprn:line(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),if(ASCAN(ArryPar,[PEN])= 6,ArryPar[7],NIL))

      CASE ascan(ArryPar,[PICTURE])=3
         /*
         1     2       3      4     5     6     7       8      9      10
         #xcommand @<row>,<col> PICTURE <cpic> SIZE <row2>,<col2> [EXTEND <row3>,<col3>] ;
         => hbprn:picture(<row>,<col>,<row2>,<col2>,<cpic>,<row3>,<col3>)
         1     2     6      7      4      9      10
         */
         IF "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
            ArryPar[4]:= ::MACROCOMPILE(ArryPar[4],.t.,cmdline,section)
         ENDIF
         DO CASE
         CASE len(ArryPar)= 4
            hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),,,::Gestimage(ArryPar[4]))

         CASE len(ArryPar)= 7
            hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[6]),eval(epar,Arrypar[7]),::Gestimage(ArryPar[4]))

         CASE len(ArryPar)=10
            IF ascan(ArryPar,[EXTEND])=8
               hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[6]),eval(epar,Arrypar[7]),::Gestimage(ArryPar[4]),eval(epar,ArryPar[9]),eval(epar,ArryPar[10]))
            ENDIF

         ENDCASE

      CASE ascan(ArryPar,[IMAGE])= 4
         hbprn:picture(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),val(eval(chblk,arrypar,[WIDTH])),VAl(eval(chblk,arrypar,[HEIGHT])),::Gestimage(ArryPar[5]))

      CASE ascan(ArryPar,[ROUNDRECT])=5   //da rivedere
         /*
         @ <row>,<col>,<row2>,<col2> ROUNDRECT  [ROUNDR <tor>] [ROUNDC <toc>] [PEN <cpen>] [BRUSH <cbrush>];
         => hbprn:roundrect(<row>,<col>,<row2>,<col2>,<tor>,<toc>,<cpen>,<cbrush>)
         RoundRect(row,col,torow,tocol,widthellipse,heightellipse,defpen,defbrush)
         */
         SET exact on
         hbprn:roundrect( eval(epar,ArryPar[1]),eval(epar,ArryPar[2]),eval(epar,ArryPar[3]),eval(epar,ArryPar[4]);
            ,val(eval(chblk,arrypar,[ROUNDR])),val(eval(chblk,arrypar,[ROUNDC])),eval(chblk,arrypar,[PEN]),eval(chblk,arrypar,[BRUSH]))
         SET exact off

      CASE ascan(ArryPar,[TEXTOUT])=3

         al := ::UsaFont(arrypar)

         IF ascan(ArryPar,[FONT])=5
            IF "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
               __elex:=ArryPar[4]
               hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex),"FX")
            ELSE
               hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4],"Fx")
            ENDIF
         ELSEIF LEN(ArryPar)=4
            IF "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
               __elex:=ArryPar[4]
               hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex))
            ELSE
               hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4])
            ENDIF
         ENDIF

         hbprn:settextalign( al[1] )
         hbprn:settexcolor ( al[2] )

      CASE ascan(ArryPar,[PRINT])=3 .OR. ascan(ArryPar,[SAY])= 3

         al := ::UsaFont(arrypar,cmdline,section)
         /*
         if eval(chblk,arrypar,[FONT])="TIMES"
         msgmulty({eval(epar,arrypar[1]),eval(epar,arrypar[2]),hbprn:convert({eval(epar,arrypar[1]),eval(epar,arrypar[2])})[1],hbprn:convert({eval(epar,arrypar[1]),eval(epar,arrypar[2])})[2];
         ,"---",hbprn:devcaps[5],hbprn:devcaps[6],hbprn:devcaps[9],hbprn:devcaps[10]})
         Endif
         */
         hbprn:say(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
            ,if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],::MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
            ,if(ascan(hbprn:Fonts[2],eval(chblk,arrypar,[FONT]) )> 0,eval(chblk,arrypar,[FONT]),"FX")  ;
            ,if(ascan(arryPar,[COLOR])>0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);
            ,nil )
         //,if(ascan(arryPar,[ALIGN])>0,::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign"),NIL))

         hbprn:settextalign( al[1] )
         hbprn:settexcolor ( al[2] )

      CASE ascan(ArryPar,[MEMOSAY])=3

         al := ::UsaFont(arrypar)

         ::MemoSay(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            ,eval(epar,ArryPar[2]) ;
            ,::MACROCOMPILE(ArryPar[4],.t.,cmdline,section) ;
            ,if(ascan(arryPar,[LEN])>0,if(valtype(oWr:argm[3])=="A",;
            ::MACROCOMPILE(eval(chblk,arrypar,[LEN]),.t.,cmdline,section) , ;
            val(eval(chblk,arrypar,[LEN]))),NIL) ;
            ,if(ascan(arryPar,[FONT])>0,"FX",NIL);
            ,if(ascan(arryPar,[COLOR])>0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);
            ,NIL ;
            ;//,if(ascan(arryPar,[ALIGN])>0,::what_ele(eval(chblk,arrypar,[ALIGN]),::aCh,"_aAlign"),NIL);
            ,if(ascan(arryPar,[.F.])>0,".F.","");
            ,arrypar)

         hbprn:settextalign( al[1] )
         hbprn:settexcolor ( al[2] )

      CASE ascan(ArryPar,[PUTARRAY])=3

         al := ::UsaFont(arrypar)

         ::Putarray(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            ,eval(epar,ArryPar[2]) ;
            ,::MACROCOMPILE(ArryPar[4],.t.,cmdline,section)    ;            //arr
         ,if(ascan(arryPar,[LEN])>0,::macrocompile(eval(chblk,arrypar,[LEN])),NIL) ; //awidths
         ,nil                                                           ;      //rowheight
         ,nil                                                           ;      //vertalign
         ,(ascan(arryPar,[NOFRAME])>0)                                  ;      //noframes
         ,nil                                                           ;      //abrushes
         ,nil                                                           ;      //apens
         ,if(ascan(arryPar,[FONT])>0,NIL,NIL)                           ;      //afonts
         ,if(ascan(arryPar,[COLOR])> 0,::UsaColor(eval(chblk,arrypar,[COLOR])),NIL);//afontscolor
         ,NIL                                                           ;      //abitmaps
         ,nil )                                                                //userfun

         hbprn:settextalign( al[1] )
         hbprn:settexcolor ( al[2] )

      CASE ascan(ArryPar,[BARCODE])=3
         oWr:DrawBarcode(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
            , VAL(eval(chblk,arrypar,[HEIGHT]));
            , VAL(eval(chblk,arrypar,[WIDTH])) ;
            , eval(chblk,arrypar,[TYPE])  ;
            , if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],::MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
            , oWr:UseFlags(eval(chblk,arrypar,[FLAG]));
            ,(ascan(arryPar,[SUBTITLE])>0);
            ,(ascan(arryPar,[INTERNAL])< 1) ;
            , cmdline ;
            ,VAL(eval(chblk,arrypar,[VSH])) )

      CASE ascan(ArryPar,[NEWPAGE])=1 .or. ascan(ArryPar,[EJECT])=1
         hbprn:endpage()
         hbprn:startpage()

      ENDCASE
   ENDCASE

   RETURN .t.
   /*
   */

METHOD WHAT_ELE(Arg1,Arg2,Arg3) CLASS WREPORT

   LOCAL rtv ,sets:='',kl := 0 , ltemp := '' ,;
      Asr := {{"_APAPER","DMPAPER_A4"} ,{"_ABIN","DMBIN_AUTO"},{"_APEN","PS_SOLID"},;
      {"_ABRUSH","BS_SOLID"},{"_APOLY","ALTERNATE"},{"_ABKMODE","TRANSPARENT"},;
      {"_AALIGN","TA_LEFT"} ,{"_AREGION","RGN_AND"} ,{"_ACOLOR","MONO"}, ;
      {"_AQLT","DMRES_DRAFT"}, {"_STYLE","DT_TOP"}}
   DEFAULT arg3 to "_APAPER"
   Arg3:=upper(Arg3)
   aeval(aSr,{|x| if(x[1]== Arg3,ltemp:=x[2],'')})
   IF ! empty(ltemp)
      DEFAULT arg1 to ltemp
      IF arg3="_ACOLOR" .and. arg1 = ".F."
         arg1 := "MONO"
      ENDIF
   ENDIF

   rtv := ASCAN(arg2, {|aVal| aVal[1] == arg1})

   IF rtv > 0
      sets := arg2[rtv,1]
      rtv  := arg2[rtv,2]
   ELSE
      IF arg3 = "TEST" //_AQLT"
         FOR kl:=01 to len(arg2)
            msg(arg1+CRLF+arg2[kl,1]+CRLF+zaps(arg2[kl,2]),arg3)
         NEXT
      ENDIF
   ENDIF
   /*
   if arg3 = ""  //_ABKMODE"      //If you want test it ...
   msg({sets+" = "+zaps(rtv),CRLF,ARG1},arg3)
   Endif
   */

   RETURN rtv
   /*
   */

METHOD MEMOSAY(row,col,argm1,argl1,argf1,argcolor1,argalign,onlyone,arrypar) CLASS WREPORT

   LOCAL _Memo1:=argm1, mrow:=max(1,mlcount(_memo1,argl1)), arrymemo:={}, esci:=.F.
   LOCAL units := hbprn:UNITS, k, mcl ,ain, str :='', typa := .F.

   DEFAULT col to 0 ,row to 0, argl1 to 10, onlyone to ''

   IF valtype(argm1)=="A"
      typa := .t.
      arrymemo := {}
      IF ::IsMono(argm1)
         arrymemo := aclone(argm1)
      ELSE
         FOR EACH ain IN argm1
            aeval( ain,{|x,y| str += substr(hb_valtostr(x),1,argl1[y])+" " } )
            str := rtrim(str)
            aadd(arrymemo,str)
            STR := ""
         NEXT ain
      ENDIF
   ELSE
      FOR k := 1 to mrow
         aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
      NEXT
   ENDIF
   IF empty(onlyone)
      hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[1],argf1,argcolor1,argalign)
      ::aStat [ 'Yes_Memo' ]:= .t.
   ELSE
      FOR mcl := 2 to len(arrymemo)
         nline ++
         IF nline >= ::HB - 1
            ::TheFeet()
            ::TheHead()
            ::UsaFont(arrypar)
         ENDIF
         hbprn:say(if(UNITS > 0.and.units < 4,nline*lstep,nline),col,arrymemo[mcl],argf1,argcolor1,argalign)
      NEXT
      IF !typa
         dbskip()
      ENDIF
   ENDIF

   RETURN self
   /*
   */

METHOD PUTARRAY(row,col,arr,awidths,rowheight,vertalign,noframes,abrushes,apens,afonts,afontscolor,abitmaps,userfun) CLASS Wreport

   LOCAL j,ltc,lxc,lvh,lnf:=!noframes,lafoc,lafo,labr,lape,xlwh1,labmp,lcol,lwh,old_pfbu
   LOCAL IsMono,nw,align

   PRIVATE xlwh,xfo,xfc,xbr,xpe,xwa,xbmp

   DEFAULT afonts to ::Astat['Fname'],afontscolor to ::Astat['Fcolor']
   IF empty(arr)

      RETURN NIL
   ENDIF
   ::aStat [ 'Yes_Array' ]:= .t.
   DO CASE
   CASE oWr:PrnDrv = "HBPR"
      old_pfbu:={hbprn:PENS[hbprn:CURRPEN,2],hbprn:FONTS[hbprn:CURRFONT,2] ;
         ,hbprn:BRUSHES[hbprn:CURRBRUSH,2],hbprn:UNITS,hbprn:GetTextAlign()}

      afontscolor:=if(afontscolor==NIL,0,afontscolor)
      lafoc:=if(valtype(afontscolor)=="N",afill(array(len(arr[1])),afontscolor),afontscolor)

   OTHERWISE
      lafoc:=if(::IsMono(afontscolor),afill(array(len(arr[1])),afontscolor),afontscolor)
   ENDCASE

   afonts:=if(afonts==NIL,"",afonts)
   lafo:=if(valtype(afonts)=="C",afill(array(len(arr[1])),afonts),afonts)

   abitmaps:=if(abitmaps==NIL,"",abitmaps)
   labmp:=if(valtype(abitmaps)=="C",afill(array(len(arr[1])),abitmaps),abitmaps)

   abrushes:=if(abrushes==NIL,"",abrushes)
   labr:=if(valtype(abrushes)=="C",afill(array(len(arr[1])),abrushes),abrushes)

   apens:=if(apens==NIL,"BLACK",apens)
   lape:=if(valtype(apens)=="C",afill(array(len(arr[1])),apens),apens)
   ltc:=if(awidths==NIL,afill(array(len(arr[1])),10),awidths)

   lwh:=if(empty(rowheight),1,rowheight)
   lvh:=if(vertalign==NIL,0,vertalign)
   IsMono := ::Ismono(arr)

   DO CASE
   CASE lvh==TA_CENTER ; lvh:=rowheight/2-0.5
   CASE lvh==TA_BOTTOM ; lvh:=rowheight-1
   OTHERWISE           ; lvh:=0  // TA_TOP
   ENDCASE
   //  msgbox(lvh,"lvh2805")
   lxc   := col
   xlwh1 := 0
   nw := if (IsMono,1 ,len(arr[1]))

   FOR j:=1 to Nw
      xlwh := lwh
      xfo  := lafo[j]
      xfc  := lafoc[j]

      IF oWr:PrnDrv = "HBPR"
         xbr := labr[j]
         xpe := lape[j]
      ENDIF

      IF IsMono
         xwa := arr[::acnt]
      ELSE
         xwa := arr[::acnt,j]
      ENDIF

      xbmp := labmp[j]

      IF valtype(userfun)=="C"
         &userfun(::acnt,j,(nline*lstep),@xwa,@xlwh,@xfo,@xfc,@xbr,@xpe,@xbmp)
      ENDIF
      IF xlwh > xlwh1
         xlwh1 := xlwh
      ENDIF
      DO CASE
      CASE ::PrnDrv = "HBPR"
         IF lnf
            @row,lxc,(nline*lstep)+xlwh+5,lxc+ltc[j] rectangle brush xbr pen xpe
         ENDIF
         IF !empty(xbmp)
            @row,lxc picture xbmp size xlwh,ltc[j]
         ENDIF
         IF valtype(xwa)=="N"
            lcol := lxc+ltc[j]-0.5
            SET text align TA_RIGHT
         ELSE
            lcol :=lxc+1
            SET text align TA_LEFT
         ENDIF
         @row,lcol say xwa Font "FX" color xfc to print

      CASE ::PrnDrv = "MINI"
         IF lnf
            _HMG_PRINTER_H_RECTANGLE ( _hmg_printer_hdc , Row , lxc , (nline*lstep)+xlwh+5 , lxc+ltc[j] , 0.2 , 0 , 0 , 0 ,.T.) // <.lcolor.> , <.lfilled.> , <.lnoborder.> )
         ENDIF

         IF valtype(xwa)=="N"
            lcol  := lxc+ltc[j]-0.5
            Align := "RIGHT"
         ELSE
            lcol  :=lxc+1
            Align := "LEFT"
         ENDIF

         _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc ,row ,lcol ;
            , xfo , ::Astat['Fsize'] ,xfc[1] ,xfc[2] ,xfc[3] , xwa , ::Astat['FBold'] , ::Astat['Fita'] ,::Astat['Funder'] ,::Astat['Fstrike'] , .T. , .T. , .T. , align)

      CASE ::PrnDrv = "PDF"
         IF lnf
            _HMG_HPDF_RECTANGLE ( Row+.2 , lxc ,(nline*lstep)+xlwh-5 ,lxc+ltc[j] ,.2 , 0 , 0 , 0 ,.T.)
         ENDIF

         IF valtype(xwa)=="N"
            lcol  := lxc+ltc[j]-0.5
            Align := "RIGHT"
            xwa   := Any2Strg( xwa )
         ELSE
            xwa   := Any2Strg( xwa )
            lcol  := lxc+1
            Align := "LEFT"
         ENDIF
         _HMG_HPDF_PRINT ( row ,lcol , xfo , ::Astat['Fsize'] ,xfc[1] ,xfc[2] ,xfc[3] , xwa , ::Astat['FBold'] , ::Astat['Fita'] ,::Astat['Funder'] ,::Astat['Fstrike'] , .T. , .T. , .T. , align)

      ENDCASE
      lxc += ltc[j]
   NEXT
   IF oWr:PrnDrv = "HBPR"
      hbprn:selectpen(old_pfbu[1])
      hbprn:selectfont(old_pfbu[2])
      hbprn:selectbrush(old_pfbu[3])
      hbprn:setunits(old_pfbu[4])
      // hbprn:SetTextAlign(old_pfbu[5])
   ENDIF

   RETURN NIL
   /*
   */

METHOD MixMsay(arg1,arg2,argm1,argl1,argf1,argsize,abold,aita,aunder,astrike,argcolor1,argalign,onlyone) Class Wreport

   LOCAL _Memo1:=argm1, k, mcl ,maxrow:=max(1,mlcount(_memo1,argl1))
   LOCAL arrymemo:={} , esci:=.F. ,str :="" , ain, typa := .F., _arg5

   DEFAULT arg2 to 0 , arg1 to 0 , argl1 to 10, onlyone to "", argalign to "LEFT"

   IF valtype(argm1)=="A"
      typa := .t.
      arrymemo := {}
      IF oWr:IsMono(argm1)
         arrymemo := aclone(argm1)
      ELSE
         FOR EACH ain IN argm1
            aeval( ain,{|x,y| str += substr(hb_valtostr(x),1,argl1[y])+" " } )
            str := rtrim(str)
            aadd(arrymemo,str)
            STR := ""
         NEXT ain
      ENDIF
   ELSE
      FOR k:=1 to maxrow
         aadd(arrymemo,oWr:justificalinea(memoline(_memo1,argl1,k),argl1))
      NEXT
   ENDIF
   _arg5:= argSize*25.4/100
   IF empty(onlyone)
      _HMG_PRINTER_H_PRINT ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
         , arg1-oWr:aStat[ 'Hbcompatible' ]-_arg5 ;
         , arg2  ;
         , argf1 ;
         , argsize ;
         , argcolor1[1] ;
         , argcolor1[2] ;
         , argcolor1[3] ;
         , arrymemo[1] ;
         , abold;
         , aita;
         , aunder;
         , astrike;
         , if(valtype(argcolor1)=="A", .t.,.F.) ;
         , if(valtype(argf1)=="C", .t.,.F.) ;
         , if(valtype(argsize)=="N", .t.,.F.) ;
         , argalign )
      oWr:aStat [ 'Yes_Memo' ] :=.t.
   ELSE
      FOR mcl=2 to len(arrymemo)
         nline ++
         IF nline >= oWr:HB-1
            oWr:TheFeet()
            oWr:TheHead()
         ENDIF
         _HMG_PRINTER_H_PRINT ( if(MGSYS,_HMG_SYSDATA [ 374 ],_hmg_printer_hdc) ;
            , (nline*lstep)-oWr:aStat[ 'Hbcompatible' ]-_arg5 , arg2, argf1 , argsize , argcolor1[1], argcolor1[2], argcolor1[3] ;
            , arrymemo[mcl], abold, aita, aunder, astrike;
            , if(valtype(argcolor1)=="A", .t.,.F.) ;
            , if(valtype(argf1)=="C", .t.,.F.) ;
            , if(valtype(argsize)=="N", .t.,.F.) ;
            , argalign )
      NEXT
      IF !Typa
         dbskip()
      ENDIF
   ENDIF

   RETURN NIL

   /*
   */

METHOD HATCH(arg1) CLASS WREPORT

   LOCAL ritorno := 0 ,;
      Asr := {"HS_HORIZONTAL","HS_VERTICAL","HS_FDIAGONAL","HS_BDIAGONAL","HS_CROSS","HS_DIAGCROSS"}
   ritorno := max(0, ascan(Asr,arg1)-1 )

   RETURN ritorno
   /*
   */

METHOD GROUP(GField, s_head, s_col, gftotal, wheregt, s_total, t_col, p_f_e_g) CLASS WREPORT

   *                1        2      3       4        5        6       7       8
   LOCAL ritorno := if( indexord()> 0 ,.t.,.F. )
   LOCAL posiz   := 0, P1 := 0, P2 := 0, P3 := 0, cnt := 1
   LOCAL Aposiz  := {}, k, Rl, Rm, Rr, ghf:=''
   LOCAL db_arc:=dbf() , units , tgftotal , nk, EXV := {||NIL},EXT := {||NIL}

   IF ::PrnDrv = "HBPR"
      Units := hbprn:UNITS
   ELSE
      Units := 3
   ENDIF

   DEFAULT S_TOTAL TO '', s_head to '', gftotal to ''
   DEFAULT wheregt to [AUTO], s_col to [AUTO], t_col to 0
   DEFAULT P_F_E_G to .F.

   Asize(counter,0)

   IF valtype( s_col)== "N"; s_col:=zaps(s_col); Endif

   IF valtype(P_F_E_G) == "C"
      ::aStat [ 'P_F_E_G' ]  :=  (".T." $ upper(P_F_E_G))
   ELSEIF valtype(P_F_E_G) == "L"
      ::aStat [ 'P_F_E_G' ]  := P_F_E_G
   ENDIF

   IF !empty(gfield)
      ::aStat [ 'Ghead' ]   :=.t.
      ::aStat[ 'TempFeet' ] := trans((db_arc)->&(GField),"@!")
   ENDIF
   IF empty(GField)
      msgExclamation('Missing Field Name id Group declaration!')
      ritorno   := .F.
   ELSE
      m->GField := GField
   ENDIF

   IF !empty(s_head)
      ::aStat [ 'GHline' ]    := .t.
      m->s_head := s_head
      m->s_col  := val( s_col )
   ELSE
      m->s_head :=""
   ENDIF

   IF !empty(s_total)
      GFline     := .t.
      IF "{||" = LEFT(S_total,3)
         EXT := alltrim(substr(S_Total,at("||",S_Total)+2,at("}",S_Total)-4))
         m->s_total := ::macrocompile( EXT )
      ELSE
         m->s_total := s_total
      ENDIF
      m->t_col   := Val( t_col )
   ENDIF

   IF valtype(gftotal)== "C"    // sistemazione per conti su colonne multiple
      && make an array for gftotal
      gftotal := AscArr(upper( gftotal ) )
   ENDIF
   && make an array for counters
   Aeval(gftotal,{|| aadd( counter,0),aadd(Gcounter,0)})

   IF !empty(gftotal) .or. !empty(s_total)
      GFline    :=.t.
      m->gfexec :=.t.
      IF "{||" = LEFT(S_total,3)
         EXT := alltrim(substr(S_Total,at("||",S_Total)+2,at("}",S_Total)-4))
         // m->s_total := macrocompile("("+Any2Strg(eval({||EXT }))+ ")")
         m->s_total := ::macrocompile(EXT )
      ELSE
         m->s_total := s_total
      ENDIF

      m->t_col  := Val( t_col )
   ENDIF

   && make autoset for stringHead position
   Aeval(::aBody,{|x,y|if(upper(m->gfield) $ upper(x[1]),Posiz :=y,'')})

   IF posiz > 0  //IS A BODY DECLARED FIELD
      P1 := max (at("SAY",upper ( ::aBody[posiz,1] ))+3,at("PRINT", upper( ::aBody[posiz,1] ) )+5)
      P2 := at("FONT",upper( ::aBody[posiz,1] ) )-2
      IF "{||" = LEFT(S_HEAD,3)
         EXV := alltrim(substr(S_HEAD,at("||",S_HEAD)+2,at("}",S_HEAD)-4))
      ENDIF
      GHstring:=substr(::aBody[posiz,1],1,P1)+;
         IF("{||" = LEFT(S_HEAD,3), Any2Strg(eval({||exv })) ;
         ,"(["+ s_head+"]+"+::Hgconvert(substr(::aBody[posiz,1],P1+1,P2-p1))+")" ) ;
         +substr(::aBody[posiz,1],p2+1)
      IF upper(s_col) # [AUTO]
         GHstring:=left(::aBody[posiz,1],at(chr(07),::aBody[posiz,1]))+s_col+chr(07)+substr(Ghstring,at("SAY",Ghstring))
      ENDIF
   ELSE   // NOT DECLARED INTO BODY
      ghf := ::Hgconvert(gfield)
      Ghstring :=if (UNITS > 0 .and. units < 4 ,"(NLINE*LSTEP)","NLINE")+CHR(07)+zaps(M->S_COL)+CHR(07)
      Ghstring +="SAY"+CHR(07)+"(["+s_head+']+'+ghf+')'+CHR(07)+"FONT"+CHR(07)+"FNT01"
   ENDIF

   // Gestisce l'automatismo del posizionamento dei subtotali
   && make autoset for Counter(s) position
   tgftotal   := aclone(gftotal)
   m->gftotal := aclone(gftotal)

   FOR EACH k in ::aBody
      P1 := at( "SAY", upper( k[1] ) ); P2 := at( "PRINT", upper ( k[1] ) )
      P3 := at( "TEXTOUT", upper( k[1] ) )
      IF max(p3,max(p1,p2)) = p3
         P1 := P3 + 8
      ELSEIF p2 > p1
         P1 := max(p2,p1) + 6
      ELSEIF p2 < p1
         P1 := max(p2,p1) + 4
      ENDIF
      Rl := substr(k[1],1,p1-1)
      Rm := substr(substr(k[1],p1),1,at(chr(07),substr(k[1],p1))-1)
      Rr := substr(substr(k[1],p1),at(chr(07),substr(k[1],p1)))
      FOR nk = 1 to len(tgftotal)
         IF tgftotal[nk] $ upper(Rm)
            rm := upper(rm)
            IF upper(tgftotal[nk]) $ Rm    &&  Ë maiuscolo
               // msginfo(rm+CRLF+tgftotal[nk],"1")
               rm:= strtran(rm,tgftotal[nk],"m->counter["+zaps(cnt)+"]")
            ENDIF
            /*
            else
            msginfo(rm+CRLF+tgftotal[nk],"2")
            rm:= strtran(rm,lower(tgftotal[nk]),"m->counter["+zaps(cnt)+"]")
            Endif
            // msgbox(Rl+CRLF+Rm+CRLF+Rr,zaps(nk)+"-GFFFSTRING")
            */
            aadd(GFstring,Rl+Rm+Rr)
            tgftotal[nk]:=''
            cnt ++
         ENDIF
      NEXT
   NEXT
   //Aeval(gfstring,{|x| msgstop( zaps( len( gfstring ) ) +crlf+x,"Gfstring" ) })
   IF valtype( wheregt)== "N"
      wheregt:=zaps(wheregt)
   ENDIF

   // Grand Total
   Aeval(GFstring,{|x| aadd(GTstring,strtran(x,"counter[","gcounter["))})
   IF val(wheregt) > 0
      IF len(wheregt) < 2
         FOR k=1 to len(GFstring)
            GTstring[k]:=left(GTstring[k],at(chr(07),GTstring[k]))+wheregt+chr(07)+substr(Gtstring[k],at("SAY",Gtstring[k]))
         NEXT
      ELSE
         GTstring[1]:=left(GTstring[1],at(chr(07),GTstring[1]))+wheregt+chr(07)+substr(Gtstring[1],at("SAY",Gtstring[1]))
      ENDIF
   ENDIF

   RETURN ritorno
   /*
   */

METHOD GrHead() CLASS WREPORT

   LOCAL db_arc:=dbf()
   LOCAL ValSee:= if(!empty(gfield),trans((db_arc)->&(GField),"@!"),"")

   IF ValSee == ::aStat[ 'TempHead' ]
      ::aStat [ 'Ghead' ]    := .F.
   ELSE
      ::aStat [ 'Ghead' ]    := .T.
      ::aStat [ 'TempHead' ] := ValSee
   ENDIF

   RETURN ::aStat [ 'Ghead' ]
   /*
   */

METHOD GFeet() CLASS WREPORT

   LOCAL db_arc:=dbf(), Gfeet
   LOCAL ValSee:=if(!empty(gfield),trans((db_arc)->&(GField),"@!"),"")

   IF ValSee == ::aStat[ 'TempFeet' ]
      Gfeet := .F.
   ELSE
      Gfeet := .T.
      ::aStat[ 'TempFeet' ]:= ValSee
   ENDIF

   RETURN Gfeet
   /*
   */

METHOD UsaFont(arrypar, cmdline , section) CLASS WREPORT

   LOCAL al := { hbprn:gettextalign(), hbprn:gettexcolor() }

   empty(cmdline);empty(section)

   hbprn:modifyfont("Fx",;
      if("->" $ eval(chblk,arrypar,[FONT]) .or. [(] $ eval(chblk,arrypar,[FONT]),::MACROCOMPILE(eval(chblk,arrypar,[FONT]),.t.,cmdline,section),eval(chblk,arrypar,[FONT])) ,;
      if("->" $ eval(chblk,arrypar,[SIZE]) .or. [(] $ eval(chblk,arrypar,[SIZE]),::MACROCOMPILE(eval(chblk,arrypar,[SIZE]),.t.,cmdline,section),val(eval(chblk,arrypar,[SIZE]))) ,;
      val(eval(chblk,arrypar,[WIDTH]) ) ,;
      val(eval(chblk,arrypar,[ANGLE]) ) ,;
      (ascan(arryPar,[BOLD])>0),!(ascan(arryPar,[BOLD])>0) , ;
      (ascan(arryPar,[ITALIC])>0),!(ascan(arryPar,[ITALIC])>0) ,;
      (ascan(arryPar,[UNDERLINE])>0) ,!(ascan(arryPar,[UNDERLINE])>0) ,;
      (ascan(arryPar,[STRIKEOUT])>0),!(ascan(arryPar,[STRIKEOUT])>0) )

   IF ascan(arryPar,[COLOR]) > 0
      hbprn:settextcolor(::UsaColor(eval(chblk,arrypar,[COLOR])))
   ENDIF
   hbprn:settextalign(::what_ele(::CheckAlign( arrypar, cmdline , section),::aCh,"_AALIGN") )
   /*
   if eval(chblk,arrypar,[FONT])= "TIMES"
   asize:={0,0}
   LQ := (hbprn:gettextextent_mm(ArryPar[4],asize,"Fx")[1])
   // lq := _HMG_HPDF_Pixel2MM(GETTEXTHEIGHT( _hmg_printer_hdc, arrypar[4],FH ))
   msgmulty({arrypar[4],eval(chblk,ArryPar[4]),lq,eval(epar,ArryPar[1]),eval(epar,ArryPar[1])-lq} )
   msgmulty(arrypar)
   Endif
   */

   RETURN al
   /*
   */

METHOD UsaColor(arg1) CLASS WREPORT

   LOCAL ritorno:=arg1

   IF "X" $ upper(arg1)
      arg1 := substr( arg1,at("X",arg1)+1)
      IF ::PrnDrv = "HBPR"
         ritorno := Rgb(HEXATODEC(substr(arg1,-2));
            ,HEXATODEC(substr(arg1,5,2)),HEXATODEC(substr(arg1,3,2)) )
      ELSE
         ritorno := {HEXATODEC(substr(arg1,-2));
            ,HEXATODEC(substr(arg1,5,2) ),HEXATODEC(substr(arg1,3,2)) }
      ENDIF
   ELSE
      ritorno := color(arg1)
   ENDIF

   RETURN ritorno
   /*
   */

METHOD DXCOLORS(par) CLASS WREPORT

   LOCAL rgbColorNames:=;
      {{ "aliceblue",             0xfffff8f0 },;
      { "antiquewhite",          0xffd7ebfa },;
      { "aqua",                  0xffffff00 },;
      { "aquamarine",            0xffd4ff7f },;
      { "azure",                 0xfffffff0 },;
      { "beige",                 0xffdcf5f5 },;
      { "bisque",                0xffc4e4ff },;
      { "black",                 0xff000000 },;
      { "blanchedalmond",        0xffcdebff },;
      { "blue",                  0xffff0000 },;
      { "blueviolet",            0xffe22b8a },;
      { "brown",                 0xff2a2aa5 },;
      { "burlywood",             0xff87b8de },;
      { "cadetblue",             0xffa09e5f },;
      { "chartreuse",            0xff00ff7f },;
      { "chocolate",             0xff1e69d2 },;
      { "coral",                 0xff507fff },;
      { "cornflowerblue",        0xffed9564 },;
      { "cornsilk",              0xffdcf8ff },;
      { "crimson",               0xff3c14dc },;
      { "cyan",                  0xffffff00 },;
      { "darkblue",              0xff8b0000 },;
      { "darkcyan",              0xff8b8b00 },;
      { "darkgoldenrod",         0xff0b86b8 },;
      { "darkgray",              0xffa9a9a9 },;
      { "darkgreen",             0xff006400 },;
      { "darkkhaki",             0xff6bb7bd },;
      { "darkmagenta",           0xff8b008b },;
      { "darkolivegreen",        0xff2f6b55 },;
      { "darkorange",            0xff008cff },;
      { "darkorchid",            0xffcc3299 },;
      { "darkred",               0xff00008b },;
      { "darksalmon",            0xff7a96e9 },;
      { "darkseagreen",          0xff8fbc8f },;
      { "darkslateblue",         0xff8b3d48 },;
      { "darkslategray",         0xff4f4f2f },;
      { "darkturquoise",         0xffd1ce00 },;
      { "darkviolet",            0xffd30094 },;
      { "deeppink",              0xff9314ff },;
      { "deepskyblue",           0xffffbf00 },;
      { "dimgray",               0xff696969 },;
      { "dodgerblue",            0xffff901e },;
      { "firebrick",             0xff2222b2 },;
      { "floralwhite",           0xfff0faff },;
      { "forestgreen",           0xff228b22 },;
      { "fuchsia",               0xffff00ff },;
      { "gainsboro",             0xffdcdcdc },;
      { "ghostwhite",            0xfffff8f8 },;
      { "gold",                  0xff00d7ff },;
      { "goldenrod",             0xff20a5da },;
      { "gray",                  0xff808080 },;
      { "green",                 0xff008000 },;
      { "greenyellow",           0xff2fffad },;
      { "honeydew",              0xfff0fff0 },;
      { "hotpink",               0xffb469ff },;
      { "indianred",             0xff5c5ccd },;
      { "indigo",                0xff82004b },;
      { "ivory",                 0xfff0ffff },;
      { "khaki",                 0xff8ce6f0 },;
      { "lavender",              0xfffae6e6 },;
      { "lavenderblush",         0xfff5f0ff },;
      { "lawngreen",             0xff00fc7c },;
      { "lemonchiffon",          0xffcdfaff },;
      { "lightblue",             0xffe6d8ad },;
      { "lightcoral",            0xff8080f0 },;
      { "lightcyan",             0xffffffe0 },;
      { "lightgoldenrodyellow",  0xffd2fafa },;
      { "lightgreen",            0xff90ee90 },;
      { "lightgrey",             0xffd3d3d3 },;
      { "lightpink",             0xffc1b6ff },;
      { "lightsalmon",           0xff7aa0ff },;
      { "lightseagreen",         0xffaab220 },;
      { "lightskyblue",          0xffface87 },;
      { "lightslategray",        0xff998877 },;
      { "lightsteelblue",        0xffdec4b0 },;
      { "lightyellow",           0xffe0ffff },;
      { "lime",                  0xff00ff00 },;
      { "limegreen",             0xff32cd32 },;
      { "linen",                 0xffe6f0fa },;
      { "magenta",               0xffff00ff },;
      { "maroon",                0xff000080 },;
      { "mediumaquamarine",      0xffaacd66 },;
      { "mediumblue",            0xffcd0000 },;
      { "mediumorchid",          0xffd355ba },;
      { "mediumpurple",          0xffdb7093 },;
      { "mediumseagreen",        0xff71b33c },;
      { "mediumslateblue",       0xffee687b },;
      { "mediumspringgreen",     0xff9afa00 },;
      { "mediumturquoise",       0xffccd148 },;
      { "mediumvioletred",       0xff8515c7 },;
      { "midnightblue",          0xff701919 },;
      { "mintcream",             0xfffafff5 },;
      { "mistyrose",             0xffe1e4ff },;
      { "moccasin",              0xffb5e4ff },;
      { "navajowhite",           0xffaddeff },;
      { "navy",                  0xff800000 },;
      { "oldlace",               0xffe6f5fd },;
      { "olive",                 0xff008080 },;
      { "olivedrab",             0xff238e6b },;
      { "orange",                0xff00a5ff },;
      { "orangered",             0xff0045ff },;
      { "orchid",                0xffd670da },;
      { "palegoldenrod",         0xffaae8ee },;
      { "palegreen",             0xff98fb98 },;
      { "paleturquoise",         0xffeeeeaf },;
      { "palevioletred",         0xff9370db },;
      { "papayawhip",            0xffd5efff },;
      { "peachpuff",             0xffb9daff },;
      { "peru",                  0xff3f85cd },;
      { "pink",                  0xffcbc0ff },;
      { "plum",                  0xffdda0dd },;
      { "powderblue",            0xffe6e0b0 },;
      { "purple",                0xff800080 },;
      { "red",                   0xff0000ff },;
      { "rosybrown",             0xff8f8fbc },;
      { "royalblue",             0xffe16941 },;
      { "saddlebrown",           0xff13458b },;
      { "salmon",                0xff7280fa },;
      { "sandybrown",            0xff60a4f4 },;
      { "seagreen",              0xff578b2e },;
      { "seashell",              0xffeef5ff },;
      { "sienna",                0xff2d52a0 },;
      { "silver",                0xffc0c0c0 },;
      { "skyblue",               0xffebce87 },;
      { "slateblue",             0xffcd5a6a },;
      { "slategray",             0xff908070 },;
      { "snow",                  0xfffafaff },;
      { "springgreen",           0xff7fff00 },;
      { "steelblue",             0xffb48246 },;
      { "tan",                   0xff8cb4d2 },;
      { "teal",                  0xff808000 },;
      { "thistle",               0xffd8bfd8 },;
      { "tomato",                0xff4763ff },;
      { "turquoise",             0xffd0e040 },;
      { "violet",                0xffee82ee },;
      { "wheat",                 0xffb3def5 },;
      { "white",                 0xffffffff },;
      { "whitesmoke",            0xfff5f5f5 },;
      { "yellow",                0xff00ffff },;
      { "yellowgreen",           0xff32cd9a }}
   LOCAL ltemp:=0

   IF valtype(par)=="C"
      par:=lower(alltrim(par))
      aeval(rgbcolornames,{|x| if(x[1]==par,ltemp:=x[2],'')})
   ELSEIF valtype(par)=="N"
      ltemp := if(par<=len(rgbcolornames),rgbcolornames[par,2],0)
   ENDIF

   RETURN ltemp

   /*
   */

METHOD SetMyRgb(dato) CLASS WREPORT

   LOCAL HexNumber, r

   DEFAULT dato to 0
   hexNumber := DECTOHEXA(dato)
   IF ::PrnDrv = "HBPR"
      r := Rgb(HEXATODEC(substr(HexNumber,-2));
         ,HEXATODEC(substr(HexNumber,5,2)),HEXATODEC(substr(HexNumber,3,2)) )
   ELSE
      r:={HEXATODEC(substr(HexNumber,-2));
         ,HEXATODEC(substr(HexNumber,5,2)),HEXATODEC(substr(HexNumber,3,2)) }
   ENDIF

   RETURN r

   /*
   */

METHOD Hgconvert(ltxt) CLASS WREPORT

   DO CASE
   CASE valtype(&ltxt)$"MC" ; return if("trans" $ lower(ltxt),ltxt,'FIELD->'+ltxt)
   CASE valtype(&ltxt)=="N" ; return 'str(FIELD->'+ltxt+')'
   CASE valtype(&ltxt)=="D" ; return 'dtoc(FIELD->'+ltxt+')'
   CASE valtype(&ltxt)=="L" ; return 'if(FIELD->'+ltxt+',".T.",".F.")'
   ENDCASE

   RETURN ''
   /*
   */

METHOD TheHead() CLASS WREPORT

   LOCAL grd, nkol

   IF nPgr == mx_pg; last_pag:=.t. ;Endif
   DO CASE
   CASE oWr:PrnDrv = "MINI"
      START PRINTPAGE

      CASE oWr:PrnDrv = "PDF"
         _hmg_hpdf_startpage()

      CASE oWr:PrnDrv = "HBPR"
         START PAGE
      End

      nPgr ++ ; nPag ++ ; nline := 0

      // Top of Form //La Testa
      IF oWr:PrnDrv = "HBPR"
         hbprn:settextcolor(0)
         IF (grdemo .or. gcdemo) .and. nPgr < 2
            hbprn:modifypen("*",0,0.1,{255,255,255})
            IF grdemo
               FOR grd= 0 to ::mx_ln_doc -1
                  @grd,0 say grd to print
                  @grd+1,0,grd+1,hbprn:maxcol LINE
               NEXT
            ENDIF
            IF gcdemo
               FOR nkol = 0 to hbprn:maxcol
                  @ 0,nKol,::mx_ln_doc,nkol line
                  IF int(nkol/10)-(nkol/10) = 0
                     @0,nKol say [*] to print
                  ENDIF
               NEXT
            ENDIF
         ENDIF
      ENDIF
      IF ::aStat ['r_paint']        // La testa
         aeval(::aHead,{|x,y|if(Y>1 ,::traduci(x[1],,x[2]),'')})
      ENDIF
      nline := if(nPgr =1,if(flob < 1,eval(oWr:Valore,oWr:aHead[1])-1,flob),eval(oWr:Valore,oWr:aHead[1])-1)
      shd := .t.

      RETURN NIL
      /*
      */

METHOD TheBody() CLASS WREPORT

   LOCAL db_arc:=dbf(), noline:=.F., subcolor, nxtp :=.F., n, an, al
   LOCAL sstring := "NLINE"+if (::aStat [ 'Units' ] = "MM","*Lstep","")+chr(07) ;
      +NTrim(t_col*if (::aStat [ 'Units' ] = "MM",1,::aStat [ 'cStep' ] ))+chr(07)+"SAY"+chr(07)

   sstring += chr(05)+chr(07)+substr(ghstring,at("FONT",ghstring))
   IF valtype(::argm[3])=="A"
      al := len(::argm[3])
      FOR an = 1 to al
         ::aCnt := an
         FOR N = 2 TO LEN(::aBody)
            IF ::traduci(::aBody[N,1],.F.,::aBody[N,2]) //n-1)
               noline := .t.
            ENDIF
            IF "MEMOSAY" $ upper( ::aBody[N,1] )
               ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
            ENDIF
         NEXT

         IF  ::aStat [ 'Yes_Memo' ]    //memo Fields
            ::traduci(::aStat [ 'ReadMemo' ])
            IF !noline
               nline ++
            ENDIF
            noline := .F.
            an := al
         ELSE
            IF !noline
               nline ++
            ENDIF
            noline := .F.
         ENDIF
         IF an < al
            insgh := ( nline >= ::hb ) //head group checker
            // @0,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
            IF nline >= ::HB-1
               ::TheFeet()
               ::TheHead()
               nxtp := .t.
            ENDIF
         ELSE
            eline := nline
            IF eline < ::HB
               nline := ::HB -1
            ENDIF
            last_pag := .t.
            ::TheFeet(.t.)
         ENDIF
      NEXT
   ELSE

      DO WHILE if(used(),! (dbf())->(Eof()),nPgr < ::aStat [ 'end_pr' ] )
         ::aStat [ 'GHline' ] := if (sbt =.F.,sbt ,::aStat [ 'GHline' ] )

         IF nxtp .and. ::aStat [ 'GHline' ] .and. ::aStat ['r_paint'] .and. sgh // La seconda pagina
            ::traduci(Ghstring)
            // @nline,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
            nxtp := .F. ; nline ++
         ENDIF

         IF ::GrHead() //.and. ::aStat [ 'GHline' ]    // La testata
            IF ::aStat ['r_paint'] .and. (shd .or. sbt) .and. sgh .and. !insgh
               ::traduci(Ghstring)
               // @nline,0 say "@@"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
               nxtp := .F. ; nline ++
            ENDIF
            insgh:=.F.
         ELSE
            FOR N = 2 TO LEN(::aBody)
               IF grdemo .or. gcdemo
                  IF ::aStat ['r_paint']
                     IF ::traduci(::aBody[N,1],,n-1)
                        noline := .t.
                     ENDIF
                     IF "MEMOSAY" $ upper( ::aBody[N,1] )
                        ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
                     ENDIF
                  ENDIF
               ELSE
                  IF ::traduci(::aBody[N,1],.F.,::aBody[N,2]) //n-1)
                     noline := .t.
                  ENDIF
                  IF "MEMOSAY" $ upper( ::aBody[N,1] )
                     ::aStat [ 'ReadMemo' ] := ::aBody[n,1] + chr(07)+".F."
                  ENDIF
               ENDIF
            NEXT
            // qui i conteggi

            Aeval(GFtotal,{|x,y| counter[y] += (db_arc)->&(x)})
            IF  ::aStat [ 'Yes_Memo' ]    //memo Fields
               ::traduci(::aStat [ 'ReadMemo' ])
               IF !noline
                  nline ++
               ENDIF
               noline := .F.
            ELSE
               IF !noline
                  nline ++
               ENDIF
               noline := .F.
               dbskip()
            ENDIF

            IF Gfexec        // Display the subtotal of group
               IF ::GFeet()
                  IF gfline .and. sbt
                     //Rivedere
                     ::traduci(strtran(sstring,chr(05),"["+s_total+"]"))
                     IF ::aStat['InlineSbt']= .F.
                        nline ++
                     ENDIF
                     GET textcolor to subcolor
                     SET textcolor BLUE
                     // @nline,t_col say GFSTRING[1] to print    // ONLY FOR DEBUG!!!
                     Aeval(GFstring,{|x|::traduci(x)})
                     SET textcolor subcolor
                     nline ++
                  ENDIF

                  Aeval(counter,{|x,y| gcounter[y] += x })
                  IF ::aStat [ 'P_F_E_G' ]
                     eline := nline
                     ::TheFeet()
                     ::TheHead()
                  ENDIF
                  afill(Counter,0)
               ENDIF
            ENDIF

            IF !eof()
               insgh := ( nline >= ::hb ) //head group checker
               // @0,0 say "**"+if(m->insgh =.T.,[.T.],[.F.])  FONT "F1" to print
               IF nline >= ::HB-1
                  ::TheFeet()
                  ::TheHead()
                  nxtp := .t.
               ENDIF
            ELSE
               IF Gfexec  //display group total
                  IF len(m->tts) > 0
                     ::traduci(strtran(sstring,chr(05),"["+m->tts+"]"))
                     IF ::aStat['InlineTot']= .F.
                        NLINE ++
                     ENDIF
                     Aeval(GTstring,{|x|::traduci(x)})
                     nline++
                     nline++
                  ENDIF
               ENDIF
               eline := nline
               IF eline < ::HB
                  nline := ::HB -1
               ENDIF
               last_pag:=.t.
               ::TheFeet(.t.)
               afill(GCounter,0)
            ENDIF
         ENDIF
      ENDDO
   ENDIF

   RETURN NIL
   /*
   */

METHOD TheFeet(last) CLASS WREPORT            //Feet // IL Piede

   DEFAULT last to .F.
   IF !last_pag
      eline := nline // if (eval(::Valore,::aBody[1])+eval(::Valore,::aBody[1]) < nline,nline,eline)
   ENDIF
   aeval(::aFeet,{|x,y|if(Y>1 ,::traduci(x[1],if(!(grdemo .or. gcdemo),'',.F.),x[2]),'')})
   last_pag := last
   Last := .T.
   IF oWr:astat ['VRuler'] [2]
      ::VRuler(::astat ['VRuler'][1])
   ENDIF
   IF oWr:astat ['HRuler'][2]
      ::HRuler(::astat ['HRuler'][1])
   ENDIF

   DO CASE
   CASE ::PrnDrv = "HBPR"
   END PAGE

CASE ::PrnDrv = "MINI"
   IF ( _HMG_MINIPRINT [23] == .T. , _HMG_PRINTER_ENDPAGE_PREVIEW (_HMG_MINIPRINT [19]) , _HMG_PRINTER_ENDPAGE ( _HMG_MINIPRINT [19] ) )

   CASE ::PrnDrv = "PDF"
      _hmg_hpdf_endpage()

   ENDCASE
   IF last
      nPgr := 0
      ::aStat [ 'EndDoc' ] := .T.
      ONEATLEAST := .F.
   ENDIF

   RETURN NIL
   /*
   */

METHOD Quantirec(_MainArea) CLASS WREPORT     //count record that will be print

   LOCAL conta:=0 , StrFlt :="",Typ_i := (indexord() > 0)
   PRIVATE query_exp:=""

   StrFlt := ::aStat [ 'FldRel' ]+" = "+ ::aStat [ 'area1' ]+"->"+::aStat [ 'FldRel' ]
   IF valtype(::argm[3])=="A"     // {_MainArea,_psd,db_arc,_prw}

      RETURN len(::argm[3])
   ENDIF
   // msgExclamation(typ_i,"quantirec 3522")
   IF !EMPTY(dbfilter())
      query_exp := dbfilter()
      DBGOTOP()
      IF !empty(_MainArea)
         // msgbox(StrFlt)
         **count to conta FOR &StrFlt
         COUNT to conta FOR &(::aStat [ 'FldRel' ]) = (::aStat [ 'area1' ])->&(::aStat [ 'FldRel' ])
         //msgbox([conta= ]+zaps(conta)+CRLF+" "+CRLF+query_exp,[Trovati Cxx])
      ELSE
         IF left(query_exp,3)=="{||"  // codeblock
            DBEval( {|| conta  ++ }, &(query_exp) ,,,, .F. )
         ELSE
            DBEval( {|| conta  ++ }, {||&query_exp  } ,,,, .F. )
         ENDIF
      ENDIF
      DBGOTOP()
   ELSE
      IF valtype(::nrec)=="C"
         ::rec := val(::nrec)
      ENDIF
      conta := If (::NREC < 1, ordkeycount(), ::NREC )
   ENDIF
   // msgbox(zaps(conta)+" per ["+query_exp+"]",[step 3])

   RETURN conta
   /*
   */

METHOD JustificaLinea(WPR_LINE,WTOPE) CLASS WREPORT

   LOCAL I, SPACE1 := SPACE(1)
   LOCAL WLARLIN := LEN(TRIM(WPR_LINE))

   FOR I=1 TO WLARLIN
      IF WLARLIN = WTOPE
         EXIT
      ENDIF
      IF SUBSTR(WPR_LINE,I,1)=SPACE1 .AND. SUBSTR(WPR_LINE,I-1,1)#SPACE1 .AND. SUBSTR(WPR_LINE,I+1,1)#SPACE1
         WPR_LINE := LTRIM(SUBSTR(WPR_LINE,1,I-1))+SPACE(2)+LTRIM(SUBSTR(WPR_LINE,I+1,LEN(WPR_LINE)-I))
         WLARLIN++
      ENDIF
   NEXT I

   RETURN WPR_LINE
   /*
   */

METHOD GestImage ( cImage ) CLASS WREPORT

   LOCAL Savefile := GetTempFolder(), nh := nil

   cImage := upper(cImage)
   IF file( cImage )
      IF ".PNG" $ cImage .or. ".TIF" $ cImage
         Savefile += "\_"+cfilenoext(cimage)+"_.JPG"
         aadd(::aStat[ 'aImages' ],SaveFile)
         IF !file(Savefile)
            nh := BT_BitmapLoadFile (cimage)
            BT_BitmapSaveFile (nh, Savefile, BT_FILEFORMAT_JPG )
            BT_BitmapRelease (nh)
         ENDIF
      ELSE
         Savefile := cImage
      ENDIF
   ENDIF

   RETURN SaveFile
   /*
   */

METHOD DrawBarcode( nRow,nCol,nHeight, nLineWidth, cType, cCode, nFlags, SubTitle, Under, CmdLine ,Vsh) CLASS WREPORT

   LOCAL hZebra, Ctxt, asize := {0,0}, nSh := 2, kj , KL := 0 , KH := 0
   LOCAL ny := 10 ,uobj := .F. ,i, fh ,sF := 9, page
   LOCAL aError := {"INVALID CODE ","BAD CHECKSUM ","TOO LARGE ","ARGUMENT ERROR " }

   DEFAULT SubTitle to .F., UNDER TO .F. , vSh to 0

   SWITCH cType
   CASE "EAN13"      ; hZebra := hb_zebra_create_ean13( cCode, nFlags )   ; EXIT
   CASE "EAN8"       ; hZebra := hb_zebra_create_ean8( cCode, nFlags )    ; EXIT
   CASE "UPCA"       ; hZebra := hb_zebra_create_upca( cCode, nFlags )    ; EXIT
   CASE "UPCE"       ; hZebra := hb_zebra_create_upce( cCode, nFlags )    ; EXIT
   CASE "CODE39"     ; hZebra := hb_zebra_create_code39( cCode, nFlags )  ; EXIT
   CASE "ITF"        ; hZebra := hb_zebra_create_itf( cCode, nFlags )     ; EXIT
   CASE "MSI"        ; hZebra := hb_zebra_create_msi( cCode, nFlags )     ; EXIT
   CASE "CODABAR"    ; hZebra := hb_zebra_create_codabar( cCode, nFlags ) ; EXIT
   CASE "CODE93"     ; hZebra := hb_zebra_create_code93( cCode, nFlags )  ; EXIT
   CASE "CODE11"     ; hZebra := hb_zebra_create_code11( cCode, nFlags )  ; EXIT
   CASE "CODE128"    ; hZebra := hb_zebra_create_code128( cCode, nFlags ) ; EXIT
   CASE "PDF417"     ; hZebra := hb_zebra_create_pdf417( cCode, nFlags ); nHeight := nLineWidth * 3 ;Uobj :=.T.; EXIT
   CASE "DATAMATRIX" ; hZebra := hb_zebra_create_datamatrix( cCode, nFlags ); nHeight := nLineWidth ;Uobj :=.T.; EXIT
   CASE "QRCODE"     ; hZebra := hb_zebra_create_qrcode( cCode, nFlags ); nHeight := nLineWidth ;Uobj :=.T.; EXIT

   ENDSWITCH

   IF hZebra != NIL
      IF hb_zebra_geterror( hZebra ) == 0
         IF EMPTY( nHeight )
            nHeight := 10
         ENDIF
         IF nHeight < 10
            sF := 6
         ENDIF
         RELEASE FONT _BCF_
         DEFINE FONT _BCF_ FONTNAME 'HELVETICA' SIZE sF BOLD

         cTxt := hb_zebra_getcode( hZebra )
         IF empty(cTxt); cTxt := cCode ;Endif
         i := AScan( _HMG_aControlNames, "_BCF_" )
         IF i > 0 .AND. _HMG_aControlType [i] == "FONT"
            fH := _HMG_aControlFontHandle [i]
         ENDIF

         DO CASE

         CASE oWr:prndrv = "HBPR"  // hbprinter
            HBPRN:MODIFYFONT("_BC_","HELVETICA",SF,0,0,.T.,.F.,.F.,.T.,.F.,.T.,.F.,.T.)
            kj:= hb_zebra_draw_wapi( hZebra, "_BC_" , nCol,NRow,NLineWidth,nHeight)
            IF SubTitle
               hbprn:gettextextent_mm(" "+Ctxt+" ",asize,"_BC_")
               KL := (Kj[1]+nSh-ncol)/2 + nCol -(asize[2]/2)
               KH := (Kj[1]+nSh-ncol)/2 + nCol +(asize[2]/2)
               IF Uobj
                  HBPRN:SAY(kj[2]+2,(Kj[1]+nSh-ncol)/2+nCol,cTxt,"_BC_",{0,0,0},6)
               ELSE
                  IF under
                     HBPRN:SAY(nRow+nHeight+if(sf < 9,-1,.3)+vSh,(Kj[1]+nSh-ncol)/2+nCol,cTxt,"_BC_",{0,0,0},6)
                  ELSE
                     hbprn:rectangle(nRow+nHeight-asize[1]+.5,KL,nRow+nHeight,KH,"WHITE","B0")
                     HBPRN:SAY(nRow+nHeight-asize[1]+if(sf < 9,-1,.2)+vSh,(Kj[1]+nSh-ncol)/2+nCol,Ctxt,"_BC_",{0,0,0},6)
                  ENDIF
               ENDIF
            ENDIF

         CASE oWr:prndrv = "MINI" // miniprint
            kj:= hb_zebra_draw_wapi( hZebra, _hmg_printer_hdc , nCol,NRow,NLineWidth,nHeight)

            IF SubTitle
               asize[1] := _HMG_HPDF_Pixel2MM(GETTEXTHEIGHT( _hmg_printer_hdc, Ctxt,FH ))
               asize[2] := _HMG_HPDF_Pixel2MM(GETTEXTWIDTH( Nil, Ctxt,FH ))

               KL := (Kj[1]+nSh-ncol)/2 + nCol -(asize[2]/2)
               KH := (Kj[1]+nSh-ncol)/2 + nCol +(asize[2]/2)
               IF Uobj
                  _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc ,kj[2]+2 ,(kj[1]+nSh-nCol)/2+ncol  ;
                     , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
               ELSE
                  IF under
                     _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc , nRow+nHeight-if(sf < 9,0,-.5) ,(kj[1]+nSh-nCol)/2+ncol  ;
                        , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
                  ELSE
                     _HMG_PRINTER_H_RECTANGLE ( _hmg_printer_hdc , nrow+nHeight-asize[1]+2;
                        , KL , nRow+nHeight , KH , 0 , 255 , 255 , 255 , .T. , .T. , .T. , .T. )
                     _HMG_PRINTER_H_PRINT ( _hmg_printer_hdc , nRow+nHeight-asize[1]+if(sf < 9,1.5,2) ,(kj[1]+nSh-nCol)/2+ncol  ;
                        , "HELVETICA" , sF ,0 ,0 ,0 , cTxt , .T. , .F. , .F. , .F. , .F. , .T. , .T. , "CENTER" )
                  ENDIF
               ENDIF
            ENDIF

         CASE oWr:PrnDrv = "PDF"   // PdfPrint
            page := _HMG_HPDFDATA[ 1 ][ 7 ]

               nY := HPDF_Page_GetHeight( page ) - _HMG_HPDF_MM2Pixel(nrow)
               HPDF_Page_SetRGBFill( page, 0.0, 0.0, 0.0 )
               kj := hb_zebra_draw_wapi( hZebra, page ,_HMG_HPDF_MM2Pixel(nCol),nY, _HMG_HPDF_MM2Pixel(nLineWidth), -_HMG_HPDF_MM2Pixel( nHeight ) )

               IF SubTitle
                  HPDF_Page_SetFontAndSize( page , HPDF_GetFont( _HMG_HPDFDATA[ 1 ][ 1 ], "Helvetica-Bold", NIL ), sF )
                  asize[1] := GETTEXTHEIGHT( Nil, Ctxt, fH )
                  asize[2] := HPDF_Page_TextWidth( page, cTxt+"  " )

                  KL := (kj[1]-_HMG_HPDF_MM2Pixel(nCol)+_HMG_HPDF_MM2Pixel(nSh))/2 + _HMG_HPDF_MM2Pixel(nCol)-(asize[2]/2) //COL
                  KH :=  kj[2]-_HMG_HPDF_MM2Pixel(nheight)-aSize[1]+(Asize[1]/2)+sf   // ROW

                  IF Uobj
                     HPDF_Page_BeginText( page )
                     HPDF_Page_TextOut( page , KL , KH -2- sF , cTxt )
                     HPDF_Page_EndText( page )
                  ELSE
                     IF under
                        HPDF_Page_BeginText(page)
                        HPDF_Page_TextOut( page , KL , KH-2-sf , cTxt )
                     ELSE
                        HPDF_Page_SetRGBFill(page, 1, 1, 1) // for white rectangle
                        HPDF_Page_Rectangle( page, kl-2, KH-2, asize[2], sF )
                        HPDF_Page_Fill( page )

                        HPDF_Page_BeginText(page)
                        HPDF_Page_SetRGBFill( page, 0.0, 0.0, 0.0 )
                        HPDF_Page_TextOut( page , KL , KH-1 , cTxt )
                     ENDIF
                     HPDF_Page_EndText( page )
                  ENDIF
               ENDIF

            ENDCASE
         ELSE
            IF ascan(::aStat [ 'ErrorLine' ] , "Error on script line :"+ZAPS( cmdline ) ) < 1
               aadd(::aStat [ 'ErrorLine' ] , "Error on script line :"+ZAPS( cmdline ) )
            ENDIF
            ::aStat [ 'OneError' ]  := .T.
            MsgStop("Type "+ cType + " Code "+ cCode+CRLF+ "Error is: "+ aError[hb_zebra_geterror( hZebra )]+CRLF+"Barcode NOT generated!" )
         ENDIF
         hb_zebra_destroy( hZebra )
      ELSE
         IF ascan(::aStat [ 'ErrorLine' ] , "Error on script line :"+ZAPS( cmdline ) ) < 1
            aadd(::aStat [ 'ErrorLine' ] , "Error on script line :"+ZAPS( cmdline ) )
         ENDIF
         ::aStat [ 'OneError' ]  := .T.
         MsgStop( "Type "+ cType , "Invalid barcode type")
      ENDIF
      RELEASE FONT _BCF_

      RETURN SELF
      /*
      */

METHOD VRuler( vPos ) CLASS WREPORT

   LOCAL i1, mx, ounits

   DEFAULT vPos := 4

   DO CASE
   CASE oWr:prndrv = "HBPR"
      ounits:=hbprn:units
      hbprn:setunits(1)
      mx :=  hbprn:maxrow
      FOR i1 = 10 TO mx
         hbprn:line(000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007 ;
            ,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ),"BLACK" )
         hbprn:say((i1-3.5),vPos,IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), ""),"_RULER_",0)
      NEXT
      hbprn:setunits(ounits)

   CASE oWr:prndrv = "MINI"
      mx := _HMG_PRINTER_GETPRINTERHEIGHT(_HMG_MINIPRINT[19])
      FOR i1 = 10 TO mx
         _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , -2+i1 , vPos , , 6 , { 0 } , { 0 }, { 0 } , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , .F. , )
         _HMG_PRINTER_H_LINE ( _HMG_MINIPRINT[19] , 000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ) , .1 , { 128 } , { 128 } , { 128 } , .T. , .T. , .F. )
      NEXT

   CASE oWr:prndrv = "PDF"
      mx:= _HMG_HPDF_Pixel2MM(HPDF_Page_GetHeight(_HMG_HPDFDATA[ 1 ][ 7 ]))-5
      FOR i1=10 TO mx
         _HMG_HPDF_PRINT ( 000+i1 , vPos-1 , , 6 , 0 , 0 , 0 , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , )
         _HMG_HPDF_LINE  ( 000+i1 , vPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0", vPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", vPos+005, vPos+4 ) ) , .1 , 128 , 128 , 128 , .T. , .T. )
      NEXT
   ENDCASE

   RETURN  NIL
   /*
   */

METHOD HRuler( hPos ) CLASS WREPORT

   LOCAL i1, mx

   DEFAULT hPos := 4
   DO CASE
   CASE oWr:prndrv = "HBPR"
      mx :=  hbprn:maxcol
      FOR i1 = 10 TO mx
         hbprn:say(hPos-3,(000+i1)-1,IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), ""),"_RULER_",{0,0,0})
         hbprn:line(hpos,000+i1,IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007 ;
            ,IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ),000+i1,"BLACK" )
      NEXT
   CASE oWr:prndrv = "MINI"
      mx := _HMG_PRINTER_GETPRINTERWIDTH(_HMG_MINIPRINT[19])
      FOR i1 = 10 TO mx
         _HMG_PRINTER_H_PRINT ( _HMG_MINIPRINT[19] , hPos-2,-1+i1 , , 6 , { 0} , { 0 } , { 0 } , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , .F. , )
         _HMG_PRINTER_H_LINE ( _HMG_MINIPRINT[19] , hPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ) , 000+i1 , .1 , { 128 }, { 128 } , { 128 } , .T. , .T. , .F. )
      NEXT

   CASE oWr:prndrv = "PDF"
      mx:= _HMG_HPDF_Pixel2MM(HPDF_Page_Getwidth(_HMG_HPDFDATA[ 1 ][ 7 ]))-5
      FOR i1 = 10 TO mx
         _HMG_HPDF_PRINT ( hPos , (000+i1)-1 , , 6 , 0 , 0 , 0 , IF(RIGHT(STR(INT(i1)),1)="0",ALLTRIM(STR(i1)), "") , .F. , .F. , .F. , .F. , .T. , .F. , .T. , , )
         _HMG_HPDF_LINE  ( hPos , 000+i1 , IF( RIGHT( STR( INT( i1 ) ),1 )="0",hPos+007,  IF( RIGHT( STR( INT( i1 ) ),1 )="5", hPos+005, hPos+4 ) ) , 000+i1 , .1 , 128 , 128 , 128 , .T. , .T. )
      NEXT
   ENDCASE

   RETURN NIL

