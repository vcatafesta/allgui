/*
* DO REPORT Command support procedures For HMG Library.
* (c) Ciro vargas Clemow [gerente@sistemascvc.com]

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA (or
visit the web site http://www.gnu.org/).

As a special exception, you have permission for additional uses of the text
contained in this file.

The exception is that, if you link this code with other
files to produce an executable, this does not by itself cause the resulting
executable to be covered by the GNU General Public License.
Your use of that executable is in no way restricted on account of linking
this code into it.

*/
MEMVAR _HMG_SYSDATA

#include 'hbclass.ch'
#include 'common.ch'
#include 'hmg.ch'

MEMVAR CLINEA
MEMVAR OPRINT
MEMVAR LNOPROP
MEMVAR CLINEA1
MEMVAR CLINEA2
MEMVAR NSPACE
MEMVAR TI
MEMVAR NMEMO
MEMVAR WFIELDT
MEMVAR _HMG_PRINTLIBRARY
MEMVAR SWMEMO

MEMVAR NPOS
MEMVAR NPOS1
MEMVAR NPOS2
MEMVAR LIN
MEMVAR SW
MEMVAR SW1
MEMVAR CREPORT
MEMVAR cgraphicalt
MEMVAR WLARLIN
MEMVAR AFIELDS
MEMVAR LSELECT
MEMVAR LDOS
MEMVAR NGRPBY
MEMVAR LLANDSCAPE
MEMVAR AHEADERS1
MEMVAR AHEADERS2
MEMVAR CTITLE
MEMVAR CGRAPHIC
MEMVAR WFIELD
MEMVAR WFIELDA
MEMVAR ATOTALS
MEMVAR AFORMATS
MEMVAR AWIDTHS
MEMVAR NPOSGRP
MEMVAR NLLMARGIN
MEMVAR CROMPE
MEMVAR CHDRGRP
MEMVAR WFILEREPO
MEMVAR CALIAS
MEMVAR NLPP
MEMVAR NCPL
MEMVAR LPREVIEW
MEMVAR CFILEREPO
MEMVAR LMUL
MEMVAR PAGE
MEMVAR EXT
MEMVAR NFI
MEMVAR NCI
MEMVAR NFF
MEMVAR NCF
MEMVAR Npapersize
MEMVAR Apapeles
MEMVAR ipaper
MEMVAR repobject
MEMVAR sicvar
MEMVAR ctitle1
MEMVAR cheader
MEMVAR _HMG_activeprintlibrary
MEMVAR _sw_report
MEMVAR CPRINTER
MEMVAR WORIENTATION
MEMVAR LSUCESS
MEMVAR CBAT

FUNCTION easyreport(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,lnoprop)

   LOCAL cheader
   PRIVATE ctitle1,sicvar,_sw_report

   IF lnoprop=NIL
      lnoprop=.F.
   ENDIF

   IF nlpp=NIL
      nlpp:=58
   ENDIF
   IF ncpl=NIL
      ncpl:=80
   ENDIF

   ctitle1:=HMG_LOWER(HB_USUBSTR(ctitle,HB_UAT('|',ctitle)+1))+'...'

   cheader:=''

   _sw_report:=.F.

   action_timer(CTITLE,AHEADERS1,AHEADERS2,AFIELDS,AWIDTHS,ATOTALS,NLPP,LDOS,LPREVIEW,CGRAPHIC,NFI,NCI,NFF,NCF,LMUL,CGRPBY,CHDRGRP,LLANDSCAPE,NCPL,LSELECT,CALIAS,NLLMARGIN,AFORMATS,NPAPERSIZE,CHEADER,lnoprop)

   RETURN NIL

FUNCTION action_timer(CTITLE,AHEADERS1,AHEADERS2,AFIELDS,AWIDTHS,ATOTALS,NLPP,LDOS,LPREVIEW,CGRAPHIC,NFI,NCI,NFF,NCF,LMUL,CGRPBY,CHDRGRP,LLANDSCAPE,NCPL,LSELECT,CALIAS,NLLMARGIN,AFORMATS,NPAPERSIZE,CHEADER,lnoprop)

   IF .not. _sw_report
      _sw_report:=.T.
      _LISTREPORT(CTITLE,AHEADERS1,AHEADERS2,AFIELDS,AWIDTHS,ATOTALS,NLPP,LDOS,LPREVIEW,CGRAPHIC,NFI,NCI,NFF,NCF,LMUL,CGRPBY,CHDRGRP,LLANDSCAPE,NCPL,LSELECT,CALIAS,NLLMARGIN,AFORMATS,NPAPERSIZE,CHEADER,lnoprop)
   ENDIF

   RETURN NIL

FUNCTION _listreport(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,cheader,lnoprop)

   PRIVATE repobject,sicvar

   repobject:=_HMG_REPORT()
   sicvar:=_HMG_SYSDATA [ 339 ]
   SET INTERACTIVECLOSE ON
   repobject:easyreport1(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,cheader,lnoprop)
   _HMG_SYSDATA [ 339 ]:=sicvar
   RELEASE repobject

   RETURN NIL

FUNCTION extreport(cfilerep,cheader)

   PRIVATE repobject

   repobject:=_HMG_REPORT()
   repobject:extreport1(cfilerep,cheader)
   RELEASE repobject

   RETURN NIL

FUNCTION JUSTIFICALINEA(WPR_LINE,WTOPE)

   LOCAL I,WLARLIN

   // Local j,ncount
   WLARLIN=HMG_LEN(RTRIM(WPR_LINE))
   FOR I=1 TO WLARLIN
      IF wlarlin=wtope
         EXIT
      ENDIF
      IF HB_USUBSTR(WPR_LINE,I,1)=SPACE(1) .AND. HB_USUBSTR(WPR_LINE,I-1,1)#SPACE(1) //////// .AND. HB_USUBSTR(WPR_LINE,I+1,1)#SPACE(1)
         WPR_LINE=LTRIM(HB_USUBSTR(WPR_LINE,1,I-1))+SPACE(2)+LTRIM(HB_USUBSTR(WPR_LINE,I+1,HMG_LEN(WPR_LINE)-I))
         WLARLIN=WLARLIN+1
      ENDIF
   NEXT I

   RETURN WPR_LINE

CREATE CLASS _HMG_REPORT

   PRIVATE oprint

   VAR npager    INIT 0
   VAR angrpby   INIT {}
   VAR nlmargin  INIT 0
   VAR nfsize    INIT 0
   VAR swt       INIT .F.
   VAR nmhor     INIT 0
   VAR nmver     INIT 0
   VAR nhfij     INIT 0
   VAR nvfij     INIT 0

   VAR aline     INIT {}

   METHOD easyreport1(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,cheader)

   METHOD headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader)

   METHOD extreport1(cfilerep)

   METHOD leadato(cName,cPropmet,cDefault)

   METHOD leaimage(cName,cPropmet,cDefault)

   METHOD leadatoh(cName,cPropmet,cDefault,npar)

   METHOD leadatologic(cName,cPropmet,cDefault)

   METHOD clean(cfvalue)

   METHOD learowi(cname,npar)

   METHOD leacoli(cname,npar)

   ENDCLASS

METHOD easyreport1(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,cheader,lnoprop) CLASS _HMG_REPORT

   LOCAL nlin,i,ncol,aresul,lmode,swt:=0,grpby,k,ncvcopt
   PRIVATE  wfield

   IF nllmargin = NIL
      repobject:nlmargin:=0
   ELSE
      repobject:nlmargin:=nllmargin
   ENDIF
   IF aformats==NIL
      aformats:=array(HMG_LEN(afields))
      FOR i:=1 to HMG_LEN(afields)
         aformats[i]:=NIL
      NEXT i
   ENDIF
   IF atotals==NIL
      atotals:=array(HMG_LEN(afields))
      FOR i:=1 to HMG_LEN(afields)
         atotals[i]:=.F.
      NEXT i
   ENDIF
   repobject:npager:=0
   grpby:=cgrpby
   aresul:=array(HMG_LEN(afields))
   repobject:angrpby:=array(HMG_LEN(afields))
   FOR i:=1 to HMG_LEN(afields)
      afields[i]:=HMG_UPPER(afields[i])
   NEXT i
   IF grpby<>NIL
      grpby:=HMG_UPPER(grpby)
   ENDIF
   select(calias)
   lmode:=.T.
   IF nlpp= NIL
      nlpp=50
   ENDIF
   setprc(0,0)
   IF ncpl = NIL
      ncpl:=80
      repobject:nfsize=12
   ENDIF
   oprint:=TPRINT()
   oprint:normaldos()
   DO CASE
   CASE ncpl= 80
      ncvcopt:=1
      repobject:nfsize:=12
      IF lnoprop
         oprint:nfontsize:=12
      ENDIF
   CASE ncpl= 96
      ncvcopt:=2
      repobject:nfsize=10
      IF lnoprop
         oprint:nfontsize:=10
      ENDIF
   CASE ncpl= 120
      ncvcopt:=3
      repobject:nfsize:=8
      IF lnoprop
         oprint:nfontsize:=8
      ENDIF
   CASE ncpl= 140
      ncvcopt:=4
      repobject:nfsize:=7
      IF lnoprop
         oprint:nfontsize:=7
      ENDIF
   CASE ncpl= 160
      ncvcopt:=5
      repobject:nfsize:=6
      IF lnoprop
         oprint:nfontsize:=6
      ENDIF
   OTHERWISE
      ncvcopt:=1
      repobject:nfsize:=12
      IF lnoprop
         oprint:nfontsize:=12
      ENDIF
   ENDCASE

   *****************=======================================

   IF ldos
      oprint:init("DOS")
      IF ncpl<= 80
         oprint:normaldos()
      ELSE
         oprint:condendos()
      ENDIF
   ELSE
      IF type("_hmg_printlibrary")="U"
         _hmg_PRINTLIBRARY="HBPRINTER"
      ENDIF
      oprint:init(_HMG_printlibrary)
      IF _hmg_PRINTLIBRARY="DOS"
         IF ncpl<=80
            oprint:normaldos()
         ELSE
            oprint:condendos()
         ENDIF
      ENDIF
   ENDIF

   oprint:selprinter(lselect,lpreview,llandscape,npapersize)
   IF oprint:lprerror
      oprint:release()

      RETURN NIL
   ENDIF
   oprint:begindoc()
   oprint:beginpage()
   nlin:=1
   IF cgraphic<>NIL
      IF .not. File(cgraphic)
         msgstop('graphic file not found','error')
      ELSE
         oprint:printimage(nfi,nci+repobject:nlmargin,nff,ncf+repobject:nlmargin,cgraphic)
      ENDIF
   ENDIF
   ngrpby:=0
   nlin:=repobject:headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader)
   FOR i:=1 to HMG_LEN(afields)
      aresul[i]:=0
      repobject:angrpby[i]:=0
   NEXT i
   IF grpby<> NIL
      crompe:=&grpby
   ENDIF
   DO WHILE .not. eof()
      do events
      ////   ncol:=repobject:nlmargin
      swt:=0
      IF grpby<>NIL
         IF .not.(&grpby = crompe)
            IF ascan(atotals,.T.)>0
               oprint:printdata(nlin,repobject:nlmargin, '** Subtotal **',,repobject:nfsize,.T.)
               nlin++
            ENDIF
            clinea:=""
            FOR i:=1 to HMG_LEN(afields)
               IF atotals[i]
                  clinea:=clinea +iif(.not.(aformats[i]==NIL),space(awidths[i]-HMG_LEN(transform(repobject:angrpby[i],aformats[i])))+transform(repobject:angrpby[i],aformats[i]),STR(repobject:angrpby[i],awidths[i]))+ space(awidths[i] -   HMG_LEN(  iif(.not.(aformats[i]==''),space(awidths[i]-HMG_LEN(transform(repobject:angrpby[i],aformats[i])))+transform(repobject:angrpby[i],aformats[i]),STR(repobject:angrpby[i],awidths[i])))   )+" "
               ELSE
                  clinea:=clinea+ space(awidths[i])+" "
               ENDIF
            NEXT i
            oprint:printdata(nlin,0+repobject:nlmargin,clinea,,repobject:nfsize ,.T.)

            FOR i:=1 to HMG_LEN(afields)
               repobject:angrpby[i]:=0
            NEXT i
            crompe:=&grpby
            nlin++
            oprint:printdata(nlin,repobject:nlmargin,  '** ' +hb_oemtoansi(chdrgrp)+' ** '+hb_oemtoansi(&grpby),,repobject:nfsize,.T.)
            nlin++
         ENDIF
      ENDIF
      ///   ncol:=0+repobject:nlmargin
      clinea:=""
      swmemo:=.F.
      FOR i:=1 to HMG_LEN(afields)
         wfielda:=afields[i]
         wfield:=&(wfielda)
         IF type('&wfielda')=='M'
            swmemo=.T.
            wfieldt:=wfield
            ti:=i
         ENDIF
         DO CASE
         CASE type('&wfielda')=='C'
            clinea:=clinea+HB_USUBSTR(wfield,1,awidths[i])+space(awidths[i]-HMG_LEN(HB_USUBSTR(wfield,1,awidths[i]) ))+" "
         CASE type('&wfielda')=='N'
            clinea:=clinea + iif(.not.(aformats[i]==NIL),space(awidths[i]-HMG_LEN(transform(wfield,aformats[i])))+transform(wfield,aformats[i]),STR(wfield,awidths[i]))+ space(awidths[i] -   HMG_LEN(  iif(.not.(aformats[i]==''),space(awidths[i]-HMG_LEN(transform(wfield,aformats[i])))+transform(wfield,aformats[i]),STR(wfield,awidths[i])))   )+" "
         CASE type('&wfielda')=='D'
            clinea:=clinea+ HB_USUBSTR(dtoc(wfield),1,awidths[i])+space(awidths[i]-HMG_LEN(HB_USUBSTR(dtoc(wfield),1,awidths[i])) )+" "
         CASE type('&wfielda')=='L'
            IF &wfielda
               clinea:=clinea+".T."+" "
            ELSE
               clinea:=clinea+".F."+" "
            ENDIF
         CASE type('&wfielda')=='M' .or. type('&wfielda')=='C' //// ojo no quitar la a
            nmemo:=mlcount(RTRIM(wfield),awidths[i])
            IF nmemo>0
               clinea:=clinea + RTRIM(justificalinea(memoline(RTRIM(wfield),awidths[i] ,1),awidths[i]))+space(awidths[i]-HMG_LEN(RTRIM(justificalinea(memoline(RTRIM(wfield),awidths[i] ,1),awidths[i])) ) )+" "
            ELSE
               clinea:=clinea + space(awidths[i])+" "
            ENDIF
         OTHERWISE
            clinea:=clinea+REPLICATE('_',awidths[i])+" "
         ENDCASE
         IF atotals[i]
            aresul[i]:=aresul[i]+wfield
            swt:=1
            IF grpby<>NIL
               repobject:angrpby[i]:=repobject:angrpby[i]+wfield
            ENDIF
         ENDIF
      NEXT i
      oprint:printdata(nlin,repobject:nlmargin,clinea,,repobject:nfsize)
      nlin++
      IF nlin>nlpp
         nlin:=1
         IF .not. ldos
            oprint:endpage()
            oprint:beginpage()
            IF cgraphic<>NIL .and. lmul
               IF .not. File(cgraphic)
                  msgstop('graphic file not found','error')
               ELSE
                  oprint:printimage(nfi,nci+repobject:nlmargin,nff,repobject:nfc,cgraphic )
               ENDIF
            ENDIF
         ENDIF
         nlin:=repobject:headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader)
      ENDIF
      **************resto de memo
      IF swmemo
         IF nmemo > 1
            clinea:=""
            nspace:=0
            FOR k:=1 to ti-1
               nspace:=nspace+awidths[k]+1
            NEXT k
            FOR k:=2 to nmemo
               clinea:=space(nspace)+justificalinea(memoline(RTRIM(wfieldt),awidths[ti] ,k),awidths[ti] )
               oprint:printdata(nlin,0+repobject:nlmargin,clinea , , repobject:nfsize ,  )
               nlin++
               IF nlin>nlpp
                  nlin:=1
                  oprint:endpage()
                  oprint:beginpage()
                  IF cgraphic<>NIL .and. lmul
                     IF .not. File(cgraphic)
                        msgstop('graphic file not found','error')
                     ELSE
                        oprint:printimage(nfi,nci+repobject:nlmargin,nff,repobject:nfc,cgraphic )
                     ENDIF
                  ENDIF
                  nlin:=repobject:headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader)
               ENDIF
            NEXT k
            ////    nlin--
         ENDIF
      ENDIF
      SKIP
   ENDDO

   IF swt==1
      ncol:=0+repobject:nlmargin
      IF grpby<>NIL
         IF .not.(&grpby == crompe)
            IF ascan(atotals,.T.)>0
               oprint:printdata(nlin,repobject:nlmargin,  '** Subtotal **',,repobject:nfsize,.T.)
               **** ojo
               nlin++
            ENDIF
            clinea:=""
            FOR i:=1 to HMG_LEN(afields)
               IF atotals[i]
                  clinea:=clinea +iif(.not.(aformats[i]==NIL),space(awidths[i]-HMG_LEN(transform(repobject:angrpby[i],aformats[i])))+transform(repobject:angrpby[i],aformats[i]),STR(repobject:angrpby[i],awidths[i]))+ space(awidths[i] -   HMG_LEN(  iif(.not.(aformats[i]==''),space(awidths[i]-HMG_LEN(transform(repobject:angrpby[i],aformats[i])))+transform(repobject:angrpby[i],aformats[i]),STR(repobject:angrpby[i],awidths[i])))   )+" "
               ELSE
                  clinea:=clinea+ space(awidths[i])+" "
               ENDIF
               /////                ncol:=ncol+awidths[i]+1
            NEXT i
            oprint:printdata(nlin,repobject:nlmargin, clinea , ,repobject:nfsize ,.T. )
            FOR i:=1 to HMG_LEN(afields)
               repobject:angrpby[i]:=0
            NEXT i
            crompe:=&grpby
         ENDIF
      ENDIF
      nlin++
      /////   ncol:=0+repobject:nlmargin
      IF nlin>nlpp
         nlin:=1
         oprint:endpage()
         oprint:beginpage()
         nlin:=repobject:headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader)
      ENDIF
      IF ascan(atotals,.T.)>0
         oprint:printdata(nlin, 0+repobject:nlmargin,'*** Total ***',,repobject:nfsize,.T.)
      ENDIF
      nlin++
      clinea:=""
      FOR i:=1 to HMG_LEN(afields)
         IF atotals[i]
            clinea:=clinea +iif(.not.(aformats[i]==NIL),space(awidths[i]-HMG_LEN(transform(aresul[i],aformats[i])))+transform(aresul[i],aformats[i]),STR(aresul[i],awidths[i]))+ space(awidths[i] -   HMG_LEN(  iif(.not.(aformats[i]==''),space(awidths[i]-HMG_LEN(transform(aresul[i],aformats[i])))+transform(aresul[i],aformats[i]),STR(aresul[i],awidths[i])))   )+" "
         ELSE
            clinea:=clinea+ space(awidths[i])+" "
         ENDIF
      NEXT i
      oprint:printdata(nlin,0+repobject:nlmargin,clinea, ,repobject:nfsize ,.T.)
      nlin++
      oprint:printdata(nlin,repobject:nlmargin," ")
   ENDIF
   oprint:endpage()
   oprint:enddoc()
   oprint:release()
   ****release nlmargin

   RETURN NIL

METHOD headers(aheaders1,aheaders2,awidths,nlin,ctitle,lmode,grpby,chdrgrp,cheader) CLASS _HMG_REPORT

   LOCAL i,nsum,ncenter,ncenter2,npostitle,ctitle1,ctitle2

   nsum:=0

   lmode := NIL   // ADD

   FOR i:=1 to HMG_LEN(awidths)
      nsum:=nsum+awidths[i]
   NEXT i
   npostitle:=HB_UAT('|',ctitle)
   ctitle1:=ctitle2:=''
   IF npostitle>0
      ctitle1:=HB_ULEFT(ctitle,npostitle-1)
      ctitle2:=TRIM(HB_USUBSTR(ctitle,npostitle+1,HMG_LEN(ctitle)))
   ELSE
      ctitle1:=ctitle
   ENDIF

   ctitle1:=TRIM(ctitle1)+cheader
   ncenter:=((nsum-HMG_LEN(ctitle1))/2)-1
   IF HMG_LEN(ctitle2)>0
      ncenter2:=((nsum-HMG_LEN(ctitle2))/2)-1
   ENDIF
   repobject:npager++
   clinea:=TRIM( _HMG_SYSDATA [ 331 ] [8])+ space(6-HMG_LEN(TRIM( _HMG_SYSDATA [ 331 ] [8]))) + STR(repobject:npager,4)
   clinea1:=space(ncenter)+ctitle1
   clinea2:=space(nsum+HMG_LEN(awidths)-11)+dtoc(date())
   oprint:printdata(nlin,repobject:nlmargin , clinea,,repobject:nfsize )
   oprint:printdata(nlin,repobject:nlmargin , clinea1,,repobject:nfsize+1,.T. )
   oprint:printdata(nlin,repobject:nlmargin , clinea2,,repobject:nfsize )

   IF HMG_LEN(ctitle2)>0
      nlin++
      clinea1:=space(ncenter2)+ctitle2
      clinea2:=space(nsum+HMG_LEN(awidths)-11)+time()
      oprint:printdata(nlin,repobject:nlmargin, clinea1,,repobject:nfsize+1,.T. )
      oprint:printdata(nlin,repobject:nlmargin, clinea2,,repobject:nfsize )
   ELSE
      nlin++
      clinea2:=space(nsum+HMG_LEN(awidths)-11)+time()
      oprint:printdata(nlin,repobject:nlmargin , clinea2,,repobject:nfsize )
   ENDIF

   nlin++
   nlin++
   clinea:=""
   FOR i:=1 to  HMG_LEN(awidths)
      clinea:=clinea+ REPLICATE('-',awidths[i])+" "
   NEXT i
   oprint:printdata(nlin,repobject:nlmargin, clinea,,repobject:nfsize  )
   nlin++

   clinea:=""
   FOR i:=1 to HMG_LEN(awidths)
      clinea:= clinea + HB_USUBSTR(aheaders1[i],1,awidths[i] ) + space( awidths[i]-HMG_LEN(aheaders1[i] )) +" "
   NEXT i
   oprint:printdata(nlin,repobject:nlmargin, clinea,,repobject:nfsize ,.T.)
   nlin++

   clinea:=""
   FOR i:=1 to HMG_LEN(awidths)
      clinea:= clinea + HB_USUBSTR(aheaders2[i],1,awidths[i] ) + space( awidths[i]-HMG_LEN(aheaders2[i] )) +" "
   NEXT i
   oprint:printdata(nlin,repobject:nlmargin, clinea,,repobject:nfsize ,.T.)
   nlin++

   clinea:=""
   FOR i:=1 to  HMG_LEN(awidths)
      clinea:=clinea + REPLICATE('-',awidths[i])+" "
   NEXT i
   oprint:printdata(nlin,repobject:nlmargin, clinea,,repobject:nfsize   )
   nlin:=nlin+2

   IF grpby<>NIL
      oprint:printdata(nlin,repobject:nlmargin, '** ' +chdrgrp+' ** '+   &grpby , ,repobject:nfsize ,.T.   )
      nlin++
   ENDIF
   _HMG_SYSDATA [ 339 ]:=sicvar

   RETURN nlin

METHOD extreport1(cfilerep,cheader) CLASS _HMG_REPORT

   LOCAL nContlin,i,ctitle,aheaders1,aheaders2,afields,awidths,atotals,aformats
   LOCAL nlpp,ncpl,nllmargin,calias,ldos,lpreview,lselect,cgraphic,lmul,nfi,nci
   LOCAL nff,ncf,cgrpby,chdrgrp,llandscape

   IF .not. file(cfilerep+'.rpt')
      msginfo('('+cfilerep+'.rpt)  File not found','Information')

      RETURN NIL
   ENDIF

   creport:= HB_MemoRead (cfilerep+'.rpt')   // ADD
   nContlin:=mlcount(Creport)
   FOR i:=1 to nContlin
      aAdd (repobject:Aline,memoline(Creport,500,i))
   NEXT i
   ctitle:=repobject:leadato('REPORT','TITLE','')
   IF HMG_LEN(ctitle)>0
      ctitle:=&ctitle
   ENDIF
   aheaders1:=repobject:leadatoh('REPORT','HEADERS','{}',1)
   aheaders1:=&aheaders1
   aheaders2:=repobject:leadatoh('REPORT','HEADERS','{}',2)
   aheaders2:=&aheaders2
   afields:=repobject:leadato('REPORT','FIELDS','{}')
   IF HMG_LEN(afields)=0
      msginfo('Fields not defined','Information')

      RETURN NIL
   ENDIF
   afields:=&afields
   awidths:=repobject:leadato('REPORT','WIDTHS','{}')
   IF HMG_LEN(awidths)=0
      msginfo('Widths not defined','Information')

      RETURN NIL
   ENDIF
   awidths:=&awidths
   atotals:=repobject:leadato('REPORT','TOTALS',NIL)
   IF atotals<>NIL
      atotals:=&atotals
   ENDIF
   aformats:=repobject:leadato('REPORT','NFORMATS',NIL)
   IF aformats<>NIL
      aformats:=&aformats
   ENDIF
   nlpp:=val(repobject:leadato('REPORT','LPP',''))
   ncpl:=val(repobject:leadato('REPORT','CPL',''))
   nllmargin:=val(repobject:leadato('REPORT','LMARGIN','0'))
   npapersize:=repobject:leadato('REPORT','PAPERSIZE','DMPAPER_LETTER')
   IF npapersize='DMPAPER_USER'
      npapersize=255
   ENDIF
   IF HMG_LEN(npapersize)=0
      npapersize:=NIL
   ELSE
      ipaper := ascan ( apapeles , npapersize )
      IF ipaper=0
         ipaper=1
      ENDIF
      npapersize:=ipaper
   ENDIF
   calias:=repobject:leadato('REPORT','WORKAREA','')
   ldos:=repobject:leadatologic('REPORT','DOSMODE',.F.)
   lpreview:=repobject:leadatologic('REPORT','PREVIEW',.F.)
   lselect:=repobject:leadatologic('REPORT','SELECT',.F.)
   lmul:=repobject:leadatologic('REPORT','MULTIPLE',.F.)
   lnoprop:=repobject:leadatologic('REPORT','NOFIXED',.F.)

   cgraphic:=repobject:clean(repobject:leaimage('REPORT','IMAGE',''))
   IF HMG_LEN(cgraphic)==0
      cgraphic:=NIL
   ENDIF
   nfi:=val((repobject:learowi('IMAGE',1)))
   nci:=val((repobject:leacoli('IMAGE',1)))
   nff:=val((repobject:learowi('IMAGE',2)))
   ncf:=val((repobject:leacoli('IMAGE',2)))
   cgraphicalt:=(repobject:leadato('DEFINE REPORT','IMAGE',''))
   IF HMG_LEN(cgraphicalt)>0  &&& para sintaxis DEFINE REPORT
      cgraphicalt:=&cgraphicalt
      cgraphic:=cgraphicalt[1]
      nfi:=cgraphicalt[2]
      nci:=cgraphicalt[3]
      nff:=cgraphicalt[4]
      ncf:=cgraphicalt[5]
   ENDIF
   cgrpby:=repobject:leadato('REPORT','GROUPED BY','')
   IF HMG_LEN(cgrpby)=0
      cgrpby=NIL
   ENDIF
   chdrgrp:=repobject:clean(repobject:leadato('REPORT','HEADRGRP',''))
   llandscape:=repobject:leadatologic('REPORT','LANDSCAPE',.F.)
   easyreport(ctitle,aheaders1,aheaders2,afields,awidths,atotals,nlpp,ldos,lpreview,cgraphic,nfi,nci,nff,ncf,lmul,cgrpby,chdrgrp,llandscape,ncpl,lselect,calias,nllmargin,aformats,npapersize,cheader,lnoprop)

   RETURN NIL

METHOD leadato(cName,cPropmet,cDefault) CLASS _HMG_REPORT

   LOCAL i,sw,cfvalue

   sw:=0
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF .not. HB_UAT(HMG_UPPER(cname)+' ',HMG_UPPER(repobject:aline[i]))==0
         sw:=1
      ELSE
         IF sw==1
            npos:=HB_UAT(HMG_UPPER(cPropmet)+' ',HMG_UPPER(repobject:aline[i]))
            IF HMG_LEN(TRIM(repobject:aline[i]))==0
               i=HMG_LEN(repobject:aline)+1

               RETURN cDefault
            ENDIF
            IF npos>0
               cfvalue:=HB_USUBSTR(repobject:aline[i],npos+HMG_LEN(Cpropmet),HMG_LEN(repobject:aline[i]))
               i:=HMG_LEN(repobject:aline)+1
               cfvalue:=TRIM(cfvalue)
               IF HB_URIGHT(cfvalue,1)=';'
                  cfvalue:=HB_USUBSTR(cfvalue,1,HMG_LEN(cfvalue)-1)
               ELSE
                  cfvalue:=HB_USUBSTR(cfvalue,1,HMG_LEN(cfvalue))
               ENDIF

               RETURN ALLTRIM(cfvalue)
            ENDIF
         ENDIF
      ENDIF
   NEXT i

   RETURN cDefault

METHOD leaimage(cName,cPropmet,cDefault) CLASS _HMG_REPORT

   LOCAL i,sw1,npos1,npos2

   sw1:=0
   lin:=0
   cname:=''
   cpropmet:=''
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF HB_UAT(HMG_UPPER('IMAGE'),repobject:aline[i])>0
         npos1:=HB_UAT(HMG_UPPER('IMAGE'),HMG_UPPER(repobject:aline[i]))+6
         npos2:=HB_UAT(HMG_UPPER('HB_UAT'),HMG_UPPER(repobject:aline[i]))-1
         lin:=i
         i:=HMG_LEN(repobject:aline)+1
         sw1:=1
      ENDIF
   NEXT i
   IF sw1=1

      RETURN HB_USUBSTR(repobject:aline[lin],npos1,npos2-npos1+1)
   ENDIF

   RETURN cDefault

METHOD leadatoh(cName,cPropmet,cDefault,npar) CLASS _HMG_REPORT

   LOCAL i,npos1,npos2,sw1

   sw1:=0
   lin:=0
   cName:=''
   cPropmet:=''
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF HB_UAT(HMG_UPPER('HEADERS'),repobject:aline[i])>0
         IF npar=1
            npos1:=HB_UAT(HMG_UPPER('{'),HMG_UPPER(repobject:aline[i]))
            npos2:=HB_UAT(HMG_UPPER('}'),HMG_UPPER(repobject:aline[i]))
         ELSE
            npos1:=HB_UTF8RAT(HMG_UPPER('{'),HMG_UPPER(repobject:aline[i]))
            npos2:=HB_UTF8RAT(HMG_UPPER('}'),HMG_UPPER(repobject:aline[i]))
         ENDIF
         lin:=i
         i:=HMG_LEN(repobject:aline)+1
         sw1:=1
      ENDIF
   NEXT i
   IF sw1=1

      RETURN HB_USUBSTR(repobject:aline[lin],npos1,npos2-npos1+1)
   ENDIF

   RETURN cDefault

METHOD leadatologic(cName,cPropmet,cDefault) CLASS _HMG_REPORT

   LOCAL i,sw

   sw:=0
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF HB_UAT(HMG_UPPER(cname)+' ',HMG_UPPER(repobject:aline[i]))#0
         sw:=1
      ELSE
         IF sw==1
            IF HB_UAT(HMG_UPPER(cPropmet)+' ',HMG_UPPER(repobject:aline[i]))>0

               RETURN .T.
            ENDIF
            IF HMG_LEN(TRIM(repobject:aline[i]))==0
               i=HMG_LEN(repobject:aline)+1

               RETURN cDefault
            ENDIF
         ENDIF
      ENDIF
   NEXT i

   RETURN cDefault

METHOD clean(cfvalue) CLASS _HMG_REPORT

   cfvalue:=HB_UTF8STRTRAN(cfvalue,'"','')
   cfvalue:=HB_UTF8STRTRAN(cfvalue,"'","")

   RETURN cfvalue

METHOD learowi(cname,npar) CLASS _HMG_REPORT

   LOCAL i,npos1,nrow

   sw:=0
   nrow:='0'
   cname:=''
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF HB_UAT(HMG_UPPER('IMAGE')+' ',HMG_UPPER(repobject:aline[i]))#0
         IF npar=1
            npos1:=HB_UAT("HB_UAT",HMG_UPPER(repobject:aline[i]))
         ELSE
            npos1:=HB_UAT("TO",HMG_UPPER(repobject:aline[i]))
         ENDIF
         nrow:=HB_USUBSTR(repobject:aline[i],npos1+3,4)
         i:=HMG_LEN(repobject:aline)
      ENDIF
   NEXT i

   RETURN nrow

METHOD leacoli(cname,npar) CLASS _HMG_REPORT

   LOCAL i,npos,ncol

   ncol:='0'
   cname:=''
   FOR i:=1 to HMG_LEN(repobject:aline)
      IF HB_UAT(HMG_UPPER('IMAGE')+' ',HMG_UPPER(repobject:aline[i]))#0
         IF npar=1
            npos:=HB_UAT(",",repobject:aline[i])
         ELSE
            npos:=HB_UTF8RAT(",",repobject:aline[i])
         ENDIF
         ncol:=HB_USUBSTR(repobject:aline[i],npos+1,4)
         i:=HMG_LEN(repobject:aline)
      ENDIF
   NEXT i

   RETURN ncol
