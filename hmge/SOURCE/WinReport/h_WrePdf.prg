#include 'minigui.ch'
#include "hbclass.ch"
#include "harupdf.ch"
#include "BosTaurus.CH"

#translate MSG   => MSGBOX
#translate ZAPS(<X>) => ALLTRIM(STR(<X>))
#define NTRIM( n ) LTrim( Str( n ) )
#translate Test( <c> ) => MsgInfo( <c>, [<c>] )
#define MsgInfo( c ) MsgInfo( c, , , .f. )
#define MsgAlert( c ) MsgEXCLAMATION( c, , , .f. )
#define MsgStop( c ) MsgStop( c, , , .f. )

#define MGSYS  .F.

MEMVAR nomevar
MEMVAR _money
MEMVAR _separator
MEMVAR _euro
MEMVAR epar
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
MEMVAR last_pag
MEMVAR s_col, t_col,  wheregt
MEMVAR gftotal, Gfexec, s_total
MEMVAR nline
MEMVAR nPag, nPgr, Tpg
MEMVAR eLine, GFline
MEMVAR maxrow, maxcol, mncl, mxH
MEMVAR abort
MEMVAR flob
MEMVAR lstep, atf, mx_pg

MEMVAR oWr
MEMVAR _HMG_HPDFDATA

* Printing Procedure                //La Procedura di Stampa

FUNCTION PrPdfEsegui(_MainArea,_psd,db_arc,_prw)

   LOCAL oldrec   := recno()
   LOCAL landscape:=.f.
   LOCAL lpreview :=.f.
   LOCAL lselect  :=.f.
   LOCAL str1:=[]
   LOCAL ncpl, nfsize
   LOCAL condition:=[]
   LOCAL StrFlt:=""
   LOCAL lbody := 0, miocont := 0, miocnt := 0
   LOCAL Amx_pg :={}
   LOCAL cdrive := curdrive()
   LOCAL rtv := .F.
   PRIVATE ONEATLEAST := .F., shd := .t., sbt := .t., sgh := .t., insgh:=.F.

   valtype(_psd)
   chblk  :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+1],''),'')}
   chblk2 :={|x,y|if(ascan(x,y)>0,if(len(X)>ascan(x,y),x[ascan(x,y)+2],''),'')}
   chkArg :={|x|if(ascan(x,{|aVal,y| aVal[1]== y})> 0 ,x[ascan(x,{|aVal,y| aVal[1]==y})][2],'KKK')}

   IF !empty(_MainArea)
      oWr:aStat [ 'area1' ]  :=substr(_MainArea,at('(',_MainArea)+1)
      oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])+2)
      oWr:aStat [ 'FldRel' ] :=substr(oWr:aStat [ 'FldRel' ],1,if(at(')',oWr:aStat [ 'FldRel' ])>0,at(')',oWr:aStat [ 'FldRel' ])-1,len(oWr:aStat [ 'FldRel' ]))) //+(at("->",oWr:aStat [ 'area1' ])))
      oWr:aStat [ 'area1' ]  :=left(oWr:aStat [ 'area1' ],at("->",oWr:aStat [ 'area1' ])-1)
   ELSE
      oWr:aStat [ 'area1' ]:=dbf()
      oWr:aStat [ 'FldRel' ]:=''
   ENDIF

   PRIVATE counter   := {}  , Gcounter  := {}

   PRIVATE grdemo    := .F. , Gcdemo    := .F.

   PRIVATE Align     :=  0  , GHstring  := ""
   PRIVATE GFstring  := {}  , GTstring  := {}
   PRIVATE GField    := ""  , S_head    := ""
   PRIVATE TTS       := "Totale"
   PRIVATE s_col     :=  0  , Gftotal   := {}
   PRIVATE Gfexec    := .F. , S_total   := ""
   PRIVATE t_col     :=  0  , nline     := oWr:mx_ln_doc
   PRIVATE nPag      :=  0  , mx_pg     := 0
   PRIVATE nPgr      :=  0  , Tpg       := 0
   PRIVATE last_pag  := .F. , eLine     :=  0
   PRIVATE wheregt   :=  0  , GFline    := .F.
   PRIVATE abort     := 0
   PRIVATE maxcol    := 0,  maxrow :=0, mncl :=0, mxH :=0

   ncpl := eval(oWr:Valore,oWr:Adeclare[1])
   str1 := upper(substr(oWr:Adeclare[1,1],at("/",oWr:Adeclare[1,1])+1))

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

   IF "LAND" $ Str1 ;landscape:=.t.; endif
   IF "SELE" $ Str1 ;lselect :=.t. ; endif
   IF "PREV" $ Str1
      lpreview := .t.
   ELSE
      lpreview := _prw
   ENDIF

   str1 := upper(substr(oWr:ABody[1,1],at("/",oWr:aBody[1,1])+1))
   flob := val(str1)
   oWr:aStat [ 'Units' ]:= "MM"
   oWr:Lmargin := 0
   IF lselect
      // msgstop(cFilePath(GetExeFileName())+"\")
      oWr:astat[ 'JobPath' ] := c_BrowseForFolder(NIL,[Indicare il percorso dove esportare:];
         ,BIF_EDITBOX + BIF_VALIDATE + BIF_NEWDIALOGSTYLE,CSIDL_DRIVES,oWr:astat[ 'JobPath' ])
      IF right(oWr:astat[ 'JobPath' ],1)<> "\"
         oWr:astat[ 'JobPath' ] += "\"
      ENDIF
      IF oWr:astat[ 'JobPath' ] = "\"
         msgstop("Invalid file Path Error!")
         r_mem()

         RETURN rtv
      ENDIF
      oWr:aStat [ 'JobName' ] =+ oWr:astat[ 'JobPath' ]+"PdfPrinter.pdf"
   ELSE
      oWr:aStat [ 'JobName' ] := "PdfPrinter.pdf"
   ENDIF
   _HMG_HPDF_INIT ( "", , , , )

   aeval(oWr:adeclare,{|x,y|if(Y>1 ,oWr:traduci(x[1],,x[2]),'')})

   maxrow := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 5 ] ) -4 //  are presumed to be about 4 mm, margin physical
   maxcol := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 4 ] ) -4 //  are presumed to be about 4 mm, margin physical
   IF used()
      IF !empty(atf)
         SET filter to &atf
      ENDIF
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   ELSE
      oWr:aStat[ 'end_pr' ] := oWr:quantirec( _mainarea )
   ENDIF

   IF file(oWr:aStat [ 'JobName' ])
      Ferase(oWr:aStat [ 'JobName' ])
   ENDIF

   _hmg_hpdf_startdoc( oWr:aStat [ 'JobName' ] )

   oWr:COUNTSECT(.t.)

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
               oWr:aStat [ 'EndDoc' ]:=.f.
               last_pag := .f.
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
   _hmg_hpdf_enddoc()

   IF len(oWr:aStat [ 'ErrorLine' ]) > 0
      msgmulty(oWr:aStat [ 'ErrorLine' ],"Error summary report:")
   ELSE
      IF lpreview =.t. .and. file(oWr:astat[ 'JobPath' ]+oWr:aStat [ 'JobName' ])
         EXECUTE FILE oWr:astat[ 'JobPath' ]+oWr:aStat [ 'JobName' ]
         /*
         IF ShellExecute(0, "OPEN", oWr:aStat [ 'JobName' ], oWr:astat[ 'JobPath' ], ,1) <=32
         MSGINFO("There is no program associated with PDF"+HB_OsNewLine()+HB_OsNewLine()+ ;
         "File recorded in:"+HB_OsNewLine()+oWr:aStat [ 'JobPath' ])
         ENDIF
         */
      ENDIF
   ENDIF
   IF used();dbgoto(oldrec);endif
   R_mem(.T.)
   RELEASE _HMG_HPDFDATA

   RETURN !rtv
   /*
   */

STATIC FUNCTION pdfmemosay(arg1,arg2,argm1,argl1,argf1,argsize,abold,aita,aunder,astrike,argcolor1,argalign,onlyone)

   LOCAL _Memo1:=argm1, k, mcl ,maxrow:=max(1,mlcount(_memo1,argl1))
   LOCAL arrymemo:={} , esci:=.f. ,str :="" , ain, typa := .f.

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
   IF empty(onlyone)
      _HMG_HPDF_PRINT( ;
         arg1+oWr:aStat[ 'Hbcompatible' ] ;
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
         , if(valtype(argcolor1)=="A", .t.,.f.) ;
         , if(valtype(argf1)=="C", .t.,.f.) ;
         , if(valtype(argsize)=="N", .t.,.f.) ;
         , argalign ;
         , NIL ) // angle not used here!

      oWr:aStat [ 'Yes_Memo' ] :=.t.
   ELSE
      FOR mcl=2 to len(arrymemo)
         nline ++
         IF nline >= oWr:HB-1
            oWr:TheFeet()
            oWr:TheHead()
         ENDIF

         _HMG_HPDF_PRINT ( ;
            (nline*lstep)+oWr:aStat[ 'Hbcompatible' ] , arg2, argf1 , argsize , argcolor1[1], argcolor1[2], argcolor1[3] ;
            , arrymemo[mcl], abold, aita, aunder, astrike;
            , if(valtype(argcolor1)=="A", .t.,.f.) ;
            , if(valtype(argf1)=="C", .t.,.f.) ;
            , if(valtype(argsize)=="N", .t.,.f.) ;
            , argalign,NIL )
      NEXT
      IF !Typa
         dbskip()
      ENDIF
   ENDIF

   RETURN NIL
   /*
   */

FUNCTION RPdfPar(ArryPar,cmdline,section) // The core of Pff interpreter

   LOCAL _arg1,_arg2, _arg3,_arg4, aX:={} , _varmem , Aclr , _varexec ,;
      blse := {|x| if(val(x)> 0,.t.,if(x=".T.".or. x ="ON",.T.,.F.))}, al, _align
   LOCAL string1 := ''

   IF len (ArryPar) < 1 ;return .F. ;endif
   DO CASE
   CASE oWr:PrnDrv = "MINI"
      //msginfo(arrypar[1],"Rmini")
      RMiniPar(ArryPar,cmdline,section)

   CASE oWr:PrnDrv = "PDF"
      *m->MaxCol := hbprn:maxcol
      *m->MaxRow := hbprn:maxrow
      // m->maxcol := _HMG_HPDF_Pixel2MM( _HMG_HPDFDATA[ 1 ][ 4 ] ) -4 //  are presumed to be about 4 mm, margin physical
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
            &_varmem := oWr:MACROCOMPILE("("+ArryPar[4]+")",.t.,cmdline,section)

         CASE ArryPar[4] == "C"
            &_varmem := xvalue(ArryPar[3],ArryPar[4])

         CASE ArryPar[4] == "N"
            &_varmem := xvalue(ArryPar[3],ArryPar[4])

         CASE ArryPar[4] == "A"
            &_varmem := oWr:MACROCOMPILE("("+ArryPar[3]+")",.t.,cmdline,section)
         ENDCASE

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

      CASE len(ArryPar)=1

         IF "DEBUG_" != left(ArryPar[1],6) .and. "ELSE" != left(ArryPar[1],4)
            oWr:MACROCOMPILE(ArryPar[1],.t.,cmdline,section)
         ENDIF

      CASE ArryPar[1]+ArryPar[2]=[ENABLETHUMBNAILS]

      CASE ascan(arryPar,[PAGELINK]) > 0
         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))

         IF "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
            ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
         ENDIF

         _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
         _arg2 := oWr:CheckAlign( arrypar )
         _HMG_HPDF_SetPageLink( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2])  ;
            , arrypar[4] ;
            , val(eval(chblk,arrypar,[TO])) ;
            , _arg1 ;
            , if(ascan(arryPar,[SIZE])#0,val(eval(chblk,arrypar,[SIZE])) ,_HMG_HPDFDATA[ 1 ][9]);
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , _arg2 ;
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
            , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
            , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
            , if(ascan(arryPar,[BORDER])#0,.t.,.f.);
            , if(ascan(arryPar,[WIDTH])#0,.t.,.f.);
            , if(ascan(arryPar,[WIDTH])# 0,VAL(eval(chblk,arrypar,[WIDTH])),NIL) )

      CASE ascan(arryPar,[URLLINK]) > 0
         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         IF "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
            ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
         ENDIF

         _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
         _arg2 := oWr:CheckAlign( arrypar )

         _HMG_HPDF_SetURLLink( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2])  ;
            , arrypar[4] ;
            , eval(chblk,arrypar,[TO]) ;
            , _arg1 ;
            , if(ascan(arryPar,[SIZE])#0,val(eval(chblk,arrypar,[SIZE])) ,_HMG_HPDFDATA[ 1 ][9]);
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , _arg2 ;
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
            , if(ascan(arryPar,[FONT]) >0, .t.,.f.) ;
            , if(ascan(arryPar,[SIZE]) >0, .t.,.f.) )

      CASE ascan(arryPar,[TOOLTIP]) > 0
         _HMG_HPDF_SetTextAnnot(  ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2]) ;
            , eval(chblk,arrypar,[TOOLTIP]) ;
            , eval(chblk,arrypar,[ICON]) )

      CASE ascan(arryPar,[SET])=1

         DO CASE
         CASE ascan(arryPar,[VRULER])= 2
            oWr:astat ['VRuler'][1] := val(eval(chblk,arrypar,[VRULER]))
            IF len(arrypar) > 3
               oWr:astat ['VRuler'][2] := eval(blse,eval(chblk2,arrypar,[VRULER]))
            ELSE
               oWr:astat ['VRuler'][2] := .F.
            ENDIF

         CASE ascan(arryPar,[HRULER])= 2
            oWr:astat ['HRuler'][1] := val(eval(chblk,arrypar,[HRULER]))
            IF len(arrypar) > 3
               oWr:astat ['HRuler'][2] := eval(blse,eval(chblk2,arrypar,[HRULER]))
            ELSE
               oWr:astat ['HRuler'][2] := .F.
            ENDIF

         CASE ascan(arryPar,[HRULER])= 2
            oWr:astat ['HRuler'] := val(eval(chblk,arrypar,[HRULER]))

         CASE ascan(arryPar,[HPDFDOC])= 2
            DO CASE
            CASE ascan(arryPar,[COMPRESS]) > 0
               _HMG_HPDF_SetCompression( eval(chblk,arrypar,[COMPRESS]) )

            CASE ascan(arryPar,[PASSWORD]) > 0
               _HMG_HPDF_SetPassword( eval(chblk,arrypar,[OWNER]), eval(chblk,arrypar,[USER] ) )

            CASE ascan(arryPar,[PERMISSION]) > 0
               _HMG_HPDF_SetPermission( eval(chblk,arrypar,[TO]) )

            CASE ascan(arryPar,[PAGEMODE]) > 0
               _HMG_HPDF_SetPageMode( eval(chblk,arrypar,[TO]) )

            CASE ascan(arryPar,[PAGENUMBERING]) > 0

               _HMG_HPDF_SetPageLabel( ;
                  MAX(val(eval(chblk,arrypar,[FROM])),1) ; // <nPage>;
                  ,eval(chblk,arrypar,[STYLE]) ;           // <"cStyle">;
                  ,IF (ASCAN(ARRYPAR,[UPPER])>0,"UPPER","LOWER") ;// <"cCase">;
                  ,eval(chblk,arrypar,[PREFIX]) )          // ;<cPrefix> )

            CASE ascan(arryPar,[ENCODING]) > 0
               _HMG_HPDF_SetEncoding( eval(chblk,arrypar,[TO]) )

            CASE ascan(arryPar,[ROOTOUTLINE]) > 0
               _HMG_HPDF_RootOutline( eval(chblk,arrypar,[TITLE]), eval(chblk,arrypar,[NAME]), eval(chblk,arrypar,[PARENT]) )

            CASE ascan(arryPar,[PAGEOUTLINE]) > 0

               _HMG_HPDF_PageOutline( eval(chblk,arrypar,[TITLE]), eval(chblk,arrypar,[NAME]), eval(chblk,arrypar,[PARENT]) )

            CASE ascan(arryPar,[PDF/A]) > 0
               // msgbox("Pdf/a","527Wrepdf")
               // MSGBOX(HPDF_PDFA_SETPDFACONFORMANCE(_HMG_HPDFDATA[1][1], 1))

            END CASE

         CASE ascan(arryPar,[HPDFPAGE])= 2
            DO CASE

            CASE ascan(arryPar,[LINESPACING]) > 0

               _HMG_HPDF_SetLineSpacing( val(eval(chblk,arrypar,[TO])) )

            CASE ascan(arryPar,[DASH]) > 0

               _HMG_HPDF_SetDash( val(eval(chblk,arrypar,[TO])) )

            ENDCASE

         CASE ascan(arryPar,[HPDFINFO])= 2
            _arg1 := eval(chblk,arrypar,[TO])
            _arg2 := eval(chblk,arrypar,[TIME])
            IF ascan(arrypar,[DATE] ) > 0
               IF "DATE()" $ _arg1
                  _arg1 := date()
                  _arg2 := ''
               ELSE
                  _arg1 := ctod(_arg1)
               ENDIF
            ENDIF
            IF ascan(arrypar,[TIME] ) > 0
               IF "TIME()" $ _arg2
                  _arg2 := time()
               ENDIF
            ENDIF
            _HMG_HPDF_SetInfo( eval(chblk,arrypar,arrypar[2]),_arg1, _arg2 )

         CASE ascan(arryPar,[COPIE])= 2

         CASE ascan(arryPar,[HBPCOMPATIBLE])= 3
            _ARG1:= VAL(eval(chblk,arrypar,[HBPCOMPATIBLE]))
            IF _ARG1 # 0
               oWr:aStat[ 'Hbcompatible' ] := _ARG1
            ELSE
               oWr:aStat[ 'Hbcompatible' ] := 3
            ENDIF

         CASE ascan(arryPar,[JOB])= 2
            _arg3 := eval(chblk,arrypar,[NAME])
            _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,oWr:MACROCOMPILE( _arg3),_arg3 )
            IF ".pdf" $ _arg3
               oWr:aStat [ 'JobName' ] := _arg3
            ELSEIF empty(_arg3)
               oWr:aStat [ 'JobName' ] := "PdfPrinter.pdf"
            ELSE
               oWr:aStat [ 'JobName' ] := _arg3+".Pdf"
            ENDIF
            _HMG_HPDFDATA[1][2] := oWr:aStat [ 'JobPath' ] +oWr:aStat [ 'JobName' ]

         CASE ascan(ArryPar,[PAGE])=2

            _arg1:=eval(chblk,arrypar,[ORIENTATION])
            _arg2:=eval(chblk,arrypar,[PAPERSIZE])
            _arg3:=eval(chblk,arrypar,[FONT])

         CASE ascan(arryPar,[ALIGN])=3

            IF val(Arrypar[4])> 0
               _align := val(Arrypar[4])
            ELSE
               _align := oWr:what_ele(eval(chblk,arrypar,[ALIGN]),oWr:aCh,"_aAlign")
            ENDIF

         CASE ascan(arryPar,[PAPERSIZE])=2   //SET PAPERSIZE
            _arg3:= oWr:what_ele(eval(chblk,arrypar,[PAPERSIZE]),oWr:aCh,"_apaper")
            _HMG_HPDFDATA[ 1 ][ 3 ]:= _arg3
            _HMG_HPDF_INIT_PAPERSIZE( _arg3 )
            */
         CASE ascan(arryPar,[PAPERSIZE])=3   //SET PAPERSIZE
            // SET USER PAPERSIZE WIDTH <width> HEIGHT <height> => //hbprn:setusermode(DMPAPER_USER,<width>,<height>)
            _HMG_HPDFDATA[ 1 ][ 4 ] := _HMG_HPDF_MM2Pixel( val(eval(chblk,arrypar,[WIDTH] )) )
            _HMG_HPDFDATA[ 1 ][ 5 ] := _HMG_HPDF_MM2Pixel( val(eval(chblk,arrypar,[HEIGHT])) )

         CASE ascan(arryPar,[ORIENTATION])=2   //SET ORIENTATION
            ax:= {_HMG_HPDFDATA[ 1 ][ 4 ] ,_HMG_HPDFDATA[ 1 ][ 5 ] }
            IF [LAND] $ eval(chblk,arrypar,[ORIENTATION])
               _HMG_HPDFDATA[ 1 ][ 4 ] := ax[2]
               _HMG_HPDFDATA[ 1 ][ 5 ] := ax[1]
            ELSE
               _HMG_HPDFDATA[ 1 ][ 4 ]  := ax[1]
               _HMG_HPDFDATA[ 1 ][ 5 ]  := ax[2]
            ENDIF

         CASE ascan(arryPar,[UNITS])=2
            DO CASE
            CASE arryPar[3]==[ROWCOL] .OR. LEN(ArryPar)==2
               oWr:aStat [ 'Units' ]:= "RC"

            CASE arryPar[3]==[MM]
               oWr:aStat [ 'Units' ]:= "MM"

            CASE arryPar[3]==[INCHES]
               oWr:aStat [ 'Units' ]:= "IN"

            CASE arryPar[3]==[PIXELS]
               oWr:aStat [ 'Units' ]:= "PI"

            ENDCASE

         CASE ascan(arryPar,[BKMODE])=2
            IF val(Arrypar[3])> 0
            ELSE
            ENDIF
            */
         CASE ascan(ArryPar,[CHARSET])=2
            /* Tentative for Miras! */
            _hmg_hpdf_setencoding( "CP1250" )

         CASE ascan(arryPar,[TEXTCOLOR])=2

         CASE ascan(arryPar,[BACKCOLOR])=2

         CASE ascan(arryPar,[ONEATLEAST])= 2
            ONEATLEAST :=eval(blse,arrypar[3])

         CASE ascan(arryPar,[THUMBNAILS])= 2

         CASE ascan(arryPar,[EURO])=2
            _euro:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[CLOSEPREVIEW])=2

         CASE ascan(arryPar,[SUBTOTALS])=2
            m->sbt := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[SHOWGHEAD])=2
            m->sgh := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[INLINESBT])=2
            oWr:aStat['InlineSbt'] := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[INLINETOT])=2
            oWr:aStat['InlineTot'] := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[TOTALSTRING])=2
            m->TTS := eval( chblk,arrypar,[TOTALSTRING] )

         CASE ascan(arryPar,[GROUPBOLD])=2
            Owr:aStat['GroupBold'] := (eval(blse,arrypar[3]))

         CASE ascan(arryPar,[HGROUPCOLOR])=2
            oWr:aStat['HGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[HGROUPCOLOR]))

         CASE ascan(arryPar,[GTGROUPCOLOR])=2
            oWr:aStat['GTGroupColor'] := oWr:UsaColor(eval(chblk,arrypar,[GTGROUPCOLOR]))

         CASE ascan(arryPar,[MONEY])=2
            _money:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[SEPARATOR])=2
            _separator:=eval(blse,arrypar[3])

         CASE ascan(arryPar,[JUSTIFICATION])=3

         CASE ascan(arryPar,[MARGINS])=3
            oWr:aStat['MarginTop'] := val(eval(chblk,arrypar,[TOP]))
            oWr:aStat['MarginLeft'] := val(eval(chblk,arrypar,[LEFT]))

         CASE (ascan(ArryPar,[POLYFILL])=2 .and. Arrypar[3]==[MODE])
            IF val(Arrypar[4])> 0
            ELSE
            ENDIF

         CASE ascan(ArryPar,[POLYFILL])=2 .and. len(arrypar)=3

         CASE ascan(ArryPar,[VIEWPORTORG])=2

         CASE ascan(ArryPar,[TEXTCHAR])=2
            HPDF_Page_SetCharSpace(_HMG_HPDFDATA[ 1 ][ 7 ] ,_HMG_HPDF_MM2Pixel(Val(eval(chblk,arrypar,[EXTRA]))) )

         CASE ArryPar[2]= [COLORMODE] //=1

         CASE ArryPar[2]= [QUALITY]   //=1

         ENDCASE

      CASE ascan(arryPar,"GET")=1

         DO CASE
         CASE ascan(arryPar,[TEXTCOLOR])> 0
            IF len(ArryPar)> 3

            ELSE

            ENDIF

         CASE ascan(arryPar,[BACKCOLOR])> 0
            IF len(ArryPar)> 3

            ELSE

            ENDIF

         CASE ascan(arryPar,[BKMODE])> 0
            IF len(ArryPar)> 3

            ELSE

            ENDIF

         CASE ascan(arryPar,[ALIGN])> 0
            IF len(ArryPar)> 4
            ELSE
            ENDIF

         CASE ascan(arryPar,[EXTENT])> 0

         CASE ArryPar[1]+ArryPar[2]+ArryPar[3]+ArryPar[4]=[GETPOLYFILLMODETO]

         CASE ArryPar[2]+ArryPar[3]=[VIEWPORTORGTO]

         CASE ascan(ArryPar,[TEXTCHAR])=2

         CASE ascan(arryPar,[JUSTIFICATION])=3

         ENDCASE

      CASE ascan(arryPar,[START])=1 .and. len(ArryPar)=2

         IF ArryPar[2]=[DOC]
            _hmg_hpdf_startdoc()
         ELSEIF ArryPar[2]=[PAGE]
            _hmg_hpdf_startpage()
         ENDIF

      CASE ascan(arryPar,[END])=1 .and. len(ArryPar)=2

         IF ArryPar[2]=[DOC]
            _hmg_hpdf_enddoc()
         ELSEIF ArryPar[2]=[PAGE]
            _hmg_hpdf_endpage()
         ENDIF

      CASE ascan(arryPar,[POLYGON])=1

      CASE ascan(arryPar,[DRAW])=5 .and. ascan(arryPar,[TEXT])=6
         // al := oWr:UsaFont(arrypar)
         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         _arg3 := eval(chblk,arrypar,[FONT])
         _arg4 := eval(chblk,arrypar,[SIZE])

         _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,&_arg3 ,_arg3 )
         _arg4 := if("->" $ _arg4 .or. [(] $ _arg4 ,oWr:MACROCOMPILE( _arg4),val(_arg4) )

         //_arg5 := 3 //_arg4 *2.54/7.2

         _varexec := Arrypar[4]

         IF "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
            ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
         ENDIF

         IF ValType (ArryPar[4]) == "N"
            ArryPar[4] := AllTrim(Str(ArryPar[4]))
         ELSEIF ValType (ArryPar[4]) == "D"
            ArryPar[4] := dtoc (ArryPar[4])
         ELSEIF ValType (ArryPar[4]) == "L"
            ArryPar[4] := iif ( ArryPar[4] == .T. , M->_hmg_printer_usermessages [24] , M->_hmg_printer_usermessages [25] )
         ENDIF

         _arg1 := CheckFont( _arg3 )

         _arg2 := owr:what_ele(eval(chblk,arrypar,[STYLE]),owr:aCh,"_STYLE")
         // msgbox(_arg2,"779")
         //                         if val(eval(chblk,arrypar,[1]))+ val(eval(chblk2,arrypar,[TO]))> 0 ///require multiline
         /*
         aeval(arrypar,{|x,y|msginfo(x,zaps(y)) } )
         #xcommand @ <row>,<col>,<row2>,<col2> DRAW TEXT <txt> [STYLE <style>] [FONT <cfont>];
         => hbprn:drawtext(<row>,<col>,<row2>,<col2>,<txt>,<style>,<cfont>)

         //msgbox(zaps(::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE")),"GGGGG")
         al := ::UsaFont(arrypar)

         hbprn:drawtext(eval(epar,ArryPar[1]),eval(epar,ArryPar[2]);
         ,eval(epar,ArryPar[3]),eval(epar,Arrypar[4]),eval(chblk,arrypar,[TEXT]);
         ,::what_ele(eval(chblk,arrypar,[STYLE]),::aCh,"_STYLE"), "Fx" )

         */
         _HMG_HPDF_MULTILINE_PRINT( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;
            , eval(epar,ArryPar[2])  ;
            , val(eval(chblk,arrypar,[TO])) ;
            , val(eval(chblk2,arrypar,[TO])) ;
            , _arg1 ;
            , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , arrypar[4] ;
            , if(ascan(arryPar,[BOLD])#0,.T.,.f.);
            , if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
            , if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
            , if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
            , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
            , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
            , _arg2 ;
            , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo

      CASE ascan(arryPar,[RECTANGLE])=5

         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         // msgmulty({val(eval(chblk,arrypar,[PENWIDTH])),val(eval(chblk,arrypar,[WIDTH]))} )
         _HMG_HPDF_RECTANGLE ( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2]) ;
            , eval(epar,ArryPar[3]) ;
            , eval(epar,ArryPar[4]) ;
            , val(eval(chblk,arrypar,[PENWIDTH])) ;
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
            , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

      CASE ascan(ArryPar,[FRAMERECT])=5 .OR. ascan(ArryPar,[FOCUSRECT])=5

      CASE ascan(ArryPar,[FILLRECT])=5

      CASE ascan(ArryPar,[INVERTRECT])=5

      CASE ascan(ArryPar,[ELLIPSE])=5

      CASE ascan(arryPar,[RADIAL1])>0
         DO CASE
         CASE arrypar[5]=[ARC]

         CASE arrypar[3]=[ARCTO]

         CASE arrypar[5]=[CHORD]

         CASE arrypar[5]=[PIE]

         ENDCASE

      CASE ASCAN(ArryPar,[LINETO])=3

      CASE ascan(ArryPar,[LINE])=5

         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         _HMG_HPDF_LINE ( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2]) ;
            , if([LINE]$ Arrypar[3],&(Arrypar[3]),eval(epar,ArryPar[3])) ;
            , eval(epar,ArryPar[4]) ;
            , val(eval(chblk,arrypar,[PENWIDTH])) ;
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

      CASE ascan(ArryPar,[PICTURE])=3

         _WR_IMAGE_PDF ( eval(chblk,arrypar,[PICTURE]);
            , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2]) ;
            , val(eval(chblk,arrypar,[SIZE]));
            , val(eval(chblk2,arrypar,[SIZE]));
            , if(ascan(ArryPar,[STRETCH])> 0,.t.,.f.))

      CASE ascan(ArryPar,[ROUNDRECT])=5

         _ARG1 := INT(MIN(eval(epar,ArryPar[4])-eval(epar,ArryPar[2]),eval(epar,ArryPar[3])-eval(epar,ArryPar[1]))/2)
         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         _HMG_HPDF_ROUNDRECTANGLE ( ;
            if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            , eval(epar,ArryPar[2]) ;
            , eval(epar,ArryPar[3]) ;
            , eval(epar,ArryPar[4]) ;
            , val(eval(chblk,arrypar,[PENWIDTH])) ;
            , Aclr[1] ;
            , Aclr[2] ;
            , Aclr[3] ;
            , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
            , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
            , if(ascan(arryPar,[FILLED])>0, .t.,.f.) ;
            , MIN(VAL(eval(chblk2,arrypar,[ROUNDR])),_ARG1) )  // CURVE value is aprox 1/3 ROUNDR
         /*
         case ascan(ArryPar,[TEXTOUT])=3000

         al := oWr:UsaFont(arrypar)

         if ascan(ArryPar,[FONT])=5
         if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
         __elex:=ArryPar[4]
         //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex),"FX")
         else
         //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4],"Fx")
         endif
         elseif LEN(ArryPar)=4
         if "->" $ ArryPar[4] .or. "(" $ ArryPar[4]
         __elex:=ArryPar[4]
         //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),&(__elex))
         else
         //hbprn:textout(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]),ArryPar[4])
         endif
         ENDIF
         */
      CASE ascan(ArryPar,[PRINT])= 3 .OR. ascan(ArryPar,[SAY])= 3 .OR. ascan(ArryPar,[TEXTOUT])= 3
         Aclr := oWr:UsaColor(eval(chblk,arrypar,[COLOR]))
         DO CASE

         CASE ASCAN(ArryPar,[IMAGE]) > 0

            _WR_IMAGE_PDF ( eval(chblk,arrypar,[IMAGE]);
               , if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , val(eval(chblk,arrypar,[HEIGHT]));
               , val(eval(chblk,arrypar,[WIDTH]));
               , if(ascan(ArryPar,[STRETCH])> 0,.t.,.f.))

         CASE ASCAN(ArryPar,[LINE]) > 0

            _HMG_HPDF_LINE ( ;
               if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , if([LINE]$ Arrypar[6],&(Arrypar[6]),eval(epar,ArryPar[6])) ;
               , eval(epar,ArryPar[7]) ;
               , val(eval(chblk,arrypar,[PENWIDTH])) ;
               , Aclr[1] ;
               , Aclr[2] ;
               , Aclr[3] ;
               , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
               , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

         CASE ASCAN(ArryPar,[RECTANGLE]) > 0

            IF ASCAN(ArryPar,[ROUNDED]) > 0
               _HMG_HPDF_ROUNDRECTANGLE ( ;
                  if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                  , eval(epar,ArryPar[2]) ;
                  , eval(epar,ArryPar[6]) ;
                  , eval(epar,ArryPar[7]) ;
                  , val(eval(chblk,arrypar,[PENWIDTH])) ;
                  , Aclr[1] ;
                  , Aclr[2] ;
                  , Aclr[3] ;
                  , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                  , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[FILLED])>0, .t.,.f.) ;
                  , VAL(eval(chblk,arrypar,[CURVE])) )
            ELSE
               _HMG_HPDF_RECTANGLE ( ;
                  if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
                  , eval(epar,ArryPar[2]) ;
                  , eval(epar,ArryPar[6]) ;
                  , eval(epar,ArryPar[7]) ;
                  , val(eval(chblk,arrypar,[PENWIDTH])) ;
                  , Aclr[1] ;
                  , Aclr[2] ;
                  , Aclr[3] ;
                  , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
                  , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

            ENDIF

         CASE ASCAN(ArryPar,[CIRCLE]) > 0

            _HMG_HPDF_CIRCLE ( ;
               if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , val(eval(chblk,arrypar,[RADIUS])) ;
               , val(eval(chblk,arrypar,[PENWIDTH])) ;
               , Aclr[1] ;
               , Aclr[2] ;
               , Aclr[3] ;
               , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
               , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
               , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

         CASE len(arrypar) > 4 .and. ArryPar[4]+ArryPar[5]=[CURVEFROM]

            _HMG_HPDF_CURVE ( ;
               if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , val(eval(chblk,arrypar,[FROM])) ;
               , val(eval(chblk2,arrypar,[FROM])) ;
               , val(eval(chblk,arrypar,[TO])) ;
               , val(eval(chblk2,arrypar,[TO])) ;
               , val(eval(chblk,arrypar,[PENWIDTH])) ;
               , Aclr[1] ;
               , Aclr[2] ;
               , Aclr[3] ;
               , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
               , if(ascan(arryPar,[COLOR])>0, .t.,.f.) )

         CASE ASCAN(ArryPar,[ARC]) > 0

            _HMG_HPDF_ARC ( ;
               if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , val(eval(chblk2,arrypar,[ARC])) ;
               , val(eval(chblk2,arrypar,[ANGLE])) ;
               , val(eval(chblk,arrypar,[TO])) ;
               , val(eval(chblk,arrypar,[PENWIDTH])) ;
               , Aclr[1] ;
               , Aclr[2] ;
               , Aclr[3] ;
               , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
               , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
               , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

         CASE ASCAN(ArryPar,[ELLIPSE]) > 0

            _HMG_HPDF_ELLIPSE ( ;
               if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
               , eval(epar,ArryPar[2]) ;
               , val(eval(chblk2,arrypar,[HORIZONTAL])) ;
               , val(eval(chblk2,arrypar,[VERTICAL])) ;
               , val(eval(chblk,arrypar,[PENWIDTH])) ;
               , Aclr[1] ;
               , Aclr[2] ;
               , Aclr[3] ;
               , if(ascan(arryPar,[PENWIDTH])>0, .t.,.f.);
               , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
               , if(ascan(arryPar,[FILLED])>0, .t.,.f.) )

         OTHERWISE

            _arg3 := eval(chblk,arrypar,[FONT])
            _arg4 := eval(chblk,arrypar,[SIZE])

            _arg3 := if("->" $ _arg3 .or. [(] $ _arg3 ,&_arg3 ,_arg3 )
            _arg4 := if("->" $ _arg4 .or. [(] $ _arg4 ,oWr:MACROCOMPILE( _arg4),val(_arg4) )

            //_arg5 := 3 //_arg4 *2.54/7.2

            _varexec := Arrypar[4]

            IF "->" $ ArryPar[4] .or. [(] $ ArryPar[4]
               ArryPar[4]:= trans(eval(epar,ArryPar[4]),"@A")
            ENDIF

            IF ValType (ArryPar[4]) == "N"
               ArryPar[4] := AllTrim(Str(ArryPar[4]))
            ELSEIF ValType (ArryPar[4]) == "D"
               ArryPar[4] := dtoc (ArryPar[4])
            ELSEIF ValType (ArryPar[4]) == "L"
               ArryPar[4] := iif ( ArryPar[4] == .T. , M->_hmg_printer_usermessages [24] , M->_hmg_printer_usermessages [25] )
            ENDIF

            _arg1 := CheckFont( _arg3 )

            _arg2 := oWr:CheckAlign( arrypar )

            IF ascan(arryPar,[TO]) > 4 .and. val(eval(chblk,arrypar,[TO]))+ val(eval(chblk2,arrypar,[TO]))> 0 ///require multiline

               _HMG_HPDF_MULTILINE_PRINT( ;
                  if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;
                  , eval(epar,ArryPar[2])  ;
                  , val(eval(chblk,arrypar,[TO])) ;
                  , val(eval(chblk2,arrypar,[TO])) ;
                  , _arg1 ;
                  , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
                  , Aclr[1] ;
                  , Aclr[2] ;
                  , Aclr[3] ;
                  , arrypar[4] ;
                  , if(ascan(arryPar,[BOLD])#0,.T.,.f.);
                  , if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
                  , if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
                  , if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
                  , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
                  , _arg2 ;
                  , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo

            ELSE

               _HMG_HPDF_PRINT( ;
                  if([LINE]$ Arrypar[1],&(Arrypar[1])+oWr:aStat[ 'Hbcompatible' ],eval(epar,ArryPar[1])+oWr:aStat[ 'Hbcompatible' ]) ;  // row
                  , eval(epar,ArryPar[2])  ;                                                // col
                  , _arg1 ;
                  , if(ascan(arryPar,[SIZE])#0,min(_arg4,300) ,_HMG_HPDFDATA[ 1 ][9]);
                  , Aclr[1] ;
                  , Aclr[2] ;
                  , Aclr[3] ;
                  , arrypar[4] ;
                  , if(ascan(arryPar,[BOLD])#0,.T.,.f.);
                  , if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
                  , if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
                  , if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
                  , if(ascan(arryPar,[COLOR])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[FONT])>0, .t.,.f.) ;
                  , if(ascan(arryPar,[SIZE])>0, .t.,.f.) ;
                  , _arg2 ;
                  , if(ascan(arryPar,[ANGLE])# 0,VAL(eval(chblk,arrypar,[ANGLE])),NIL) ) // angolo
            ENDIF

         ENDCASE

      CASE ascan(ArryPar,[MEMOSAY])=3

         _arg1 := CheckFont( eval(chblk,arrypar,[FONT]) )
         _arg2 := oWr:CheckAlign( arrypar )

         pdfmemosay(if([LINE]$ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1]) ) ,eval(epar,ArryPar[2]) ,&(ArryPar[4]) ;
            ,if(ascan(arryPar,[LEN])>0,if(valtype(oWr:argm[3])=="A", ;
            oWr:MACROCOMPILE(eval(chblk,arrypar,[LEN]),.t.,cmdline,section) , ;
            val(eval(chblk,arrypar,[LEN]))),NIL) ;
            ,_arg1 ;//if(ascan(arryPar,[FONT])>0,eval(chblk,arrypar,[FONT]),NIL);
            ,if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),NIL );
            ,if(ascan(arryPar,[BOLD])#0,.T.,.f.);
            ,if(ascan(arryPar,[ITALIC])#0,.t.,.f.) ;
            ,if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.);
            ,if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.);
            ,if(ascan(arryPar,[COLOR])>0,oWr:usacolor(eval(chblk,arrypar,[COLOR])),NIL);
            ,_arg2 ;//,if(ascan(arryPar,[ALIGN])>0,oWr:what_ele(eval(chblk,arrypar,[ALIGN]),_aAlign,"_aAlign"),NIL);
            ,if(ascan(arryPar,[.F.])>0,".F.",""))

      CASE ascan(ArryPar,[PUTARRAY])=3

         al := CheckFont( eval(chblk,arrypar,[FONT]) )

         if(ascan(arryPar,[FONT])>0,oWr:Astat['Fname']:= al,NIL)
         oWr:Astat['Fsize']   := if(ascan(arryPar,[SIZE])>0,val( eval(chblk,arrypar,[SIZE] ) ),oWr:Astat['Fsize'] )
         oWr:Astat['FBold']   := if(ascan(arryPar,[BOLD])#0,.T.,.f.)
         oWr:Astat['Fita']    := if(ascan(arryPar,[ITALIC])#0,.t.,.f.)
         oWr:Astat['Funder']  := if(ascan(arryPar,[UNDERLINE])#0,.t.,.f.)
         oWr:Astat['Fstrike'] := if(ascan(arryPar,[STRIKEOUT])#0,.t.,.f.)
         oWr:Astat['Falign']  := oWr:CheckAlign( arrypar )
         oWr:Astat['Fangle']  := val(eval(chblk,arrypar,[ANGLE]))
         oWr:Astat['Fcolor']  := if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL)
         */
         oWr:Putarray(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])) ;
            ,eval(epar,ArryPar[2]) ;
            ,oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section)    ;            //arr
            ,if(ascan(arryPar,[LEN])>0,oWr:macrocompile(eval(chblk,arrypar,[LEN])),NIL) ; //awidths
            ,nil                                                           ;      //rowheight
            ,nil                                                           ;      //vertalign
            ,(ascan(arryPar,[NOFRAME])>0)                                  ;      //noframes
            ,nil                                                           ;      //abrushes
            ,nil                                                           ;      //apens
            ,if(ascan(arryPar,[FONT])>0,NIL,NIL)                           ;      //afonts
            ,if(ascan(arryPar,[COLOR])> 0,oWr:UsaColor(eval(chblk,arrypar,[COLOR])),NIL);//afontscolor
            ,NIL                                                           ;      //abitmaps
            ,nil )                                                                //userfun

      CASE ascan(ArryPar,[BARCODE])=3
         oWr:DrawBarcode(if([LINE] $ Arrypar[1],&(Arrypar[1]),eval(epar,ArryPar[1])),eval(epar,ArryPar[2]);
            , VAL(eval(chblk,arrypar,[HEIGHT]));
            , VAL(eval(chblk,arrypar,[WIDTH])) ;
            , eval(chblk,arrypar,[TYPE])  ;
            , if("->" $ ArryPar[4] .or. [(] $ ArryPar[4],oWr:MACROCOMPILE(ArryPar[4],.t.,cmdline,section),ArryPar[4]);
            , oWr:UseFlags( upper(eval(chblk,arrypar,[FLAG]))) ;
            ,(ascan(arryPar,[SUBTITLE])> 0)  ;
            ,(ascan(arryPar,[INTERNAL])< 1) ;
            , cmdline )

      CASE ascan(ArryPar,[NEWPAGE])=1 .or. ascan(ArryPar,[EJECT])=1

         _hmg_hpdf_EndPage()
         _hmg_hpdf_StartPage()
      ENDCASE
   ENDCASE

   RETURN .t.
   /*
   */

FUNCTION CheckFont( cFontName)  //returns the name and path

   LOCAL nPos := 0 , cFont := ''
   LOCAL aHpdf_Font := {'Courier',;
      'Courier-Bold',;
      'Courier-Oblique',;
      'Courier-BoldOblique',;
      'Helvetica',;
      'Helvetica-Bold',;
      'Helvetica-Oblique',;
      'Helvetica-BoldOblique',;
      'Times-Roman',;
      'Times-Bold',;
      'Times-Italic',;
      'Times-BoldItalic',;
      'Symbol',;
      'ZapfDingbats'}

   aeval( aHpdf_Font,{|x,y| if(upper(x)==cFontname,npos:= y,NIL )})
   IF npos > 0
      cFont := aHpdf_Font[nPos]
   ELSE
      IF ".TTF" $ upper(cFontname)
         IF file(oWr:astat[ 'JobPath' ]+cFontname)
            cFont:= oWr:astat[ 'JobPath' ]+cFontname
         ELSE
            cfontname:=cFilenopath(cfontname)
            IF file(oWr:astat[ 'JobPath' ]+cFontname)
               cfont:= oWr:astat[ 'JobPath' ]+cFontname
            ELSEIF file(GetWindowsFolder ( )+"\Fonts\"+cfontname)
               cfont := GetWindowsFolder ( )+"\Fonts\"+cfontname
            ENDIF
         ENDIF
      ELSE
         IF "COURIER NEW" $ cfontname
            cfontname := "COUR"
         ENDIF
         IF file(GetWindowsFolder ( )+"\Fonts\"+cfontname+".TTF")
            cfont := GetWindowsFolder ( )+"\Fonts\"+cfontname+".TTF"
         ENDIF
      ENDIF
   ENDIF

   RETURN cFont
   /*
   */

FUNCTION _HMG_HPDF_SetFont( cFontName, lBold, lItalic )

   LOCAL nPos := 0 , cFont := '', jld :=''
   LOCAL aHpdf_Font := {'Courier',;
      'Courier-Bold',;
      'Courier-Oblique',;
      'Courier-BoldOblique',;
      'Helvetica',;
      'Helvetica-Bold',;
      'Helvetica-Oblique',;
      'Helvetica-BoldOblique',;
      'Times-Roman',;
      'Times-Bold',;
      'Times-Italic',;
      'Times-BoldItalic',;
      'Symbol',;
      'ZapfDingbats'}

   DEFAULT lBold := .f., lItalic := .f.

   IF len( alltrim( cFontName ) ) == 0
      cFont := _HMG_HPDFDATA[ 1 ][ 8 ]
      IF lBold .and. lItalic
         cFont += '-BoldOblique'
      ELSEIF lBold
         cFont += '-Bold'
      ELSEIF lItalic
         cFont += '-Oblique'
      ENDIF
   ELSEIF (nPos := AScan(aHpdf_Font, {|cFont| At(cFontName, cFont) > 0 })) > 0
      cFont := aHpdf_Font[nPos]
      IF (nPos := At('-',cFont)) > 0 .and. At('-',cFontName) == 0
         cfont := SubStr(cFont, 1, nPos-1)
      ENDIF
      IF SubStr(cFont, 1, 5) == 'Times'
         IF lBold .and. lItalic
            cFont += '-BoldItalic'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Italic'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ELSE
               cFont := 'Times-Roman'
            ENDIF
         ENDIF
      ELSEIF alltrim( cFontName ) == "Symbol" .or. alltrim( cFontName ) == "ZapfDingbats"

      ELSE
         IF lBold .and. lItalic
            cFont += '-BoldOblique'
         ELSEIF lBold
            cFont += '-Bold'
         ELSEIF lItalic
            cFont += '-Oblique'
         ELSE
            IF At('-',cFontName) != 0
               cFont := cFontName
            ENDIF
         ENDIF
      ENDIF
   ELSEIF upper( substr( cFontName, len( cFontName ) - 3 ) ) == '.TTF' // load ttf font
      cFont := substr( cFontName, 1, len( cFontName ) - 4 )
      IF lBold .and. lItalic
         cFontName := cFont + 'bi.ttf'
      ELSEIF lBold
         cFontName := cFont + 'bd.ttf'
      ELSEIF lItalic
         cFontName := cFont + 'i.ttf'
      ENDIF
      * controlla se il font è già stato creato
      * check if the font has already been created
      aeval(oWR:astat[ 'PdfFont' ],{|x| if(x[1]==UPPER(cFontname),jld:=x[2],'')})
      IF empty(jld)  // a new font is required
         cFont := HPDF_LOADTTFONTFROMFILE( _HMG_HPDFDATA[ 1 ][ 1 ], cFontName, .t. )
         * memorizzare il nome del font caricato
         * store the name of the loaded font
         aadd(oWR:astat[ 'PdfFont' ], {UPPER(cFontname),cfont} )
      ELSE
         cFont := jld
      ENDIF
      IF len( alltrim( cFont ) ) == 0

         RETURN ''
      ENDIF
   ELSE
      cFont := cFontName
   ENDIF

   RETURN cFont
   /*
   */

FUNCTION _WR_IMAGE_PDF ( cImage, nRow, nCol, nImageheight, nImageWidth, lStretch )

   LOCAL nWidth := _HMG_HPDFDATA[ 1 ][ 4 ]
   LOCAL nHeight := _HMG_HPDFDATA[ 1 ][ 5 ]
   LOCAL nxPos := _HMG_HPDF_MM2Pixel( nCol )
   LOCAL nyPos := nHeight - _HMG_HPDF_MM2Pixel( nRow )
   LOCAL oImage ,cExt
   LOCAL nh := nil
   LOCAL Savefile := GetTempFolder()

   DEFAULT lStretch := .f.
   cImage:= upper(cImage)

   IF _HMG_HPDFDATA[ 1 ][ 1 ] == nil // PDF object not found!
      _HMG_HPDF_Error( 3 )

      RETURN NIL
   ENDIF
   IF _HMG_HPDFDATA[ 1 ][ 7 ] == nil // PDF Page object not found!
      _HMG_HPDF_Error( 5 )

      RETURN NIL
   ENDIF
   IF file( cImage )
      hb_FNameSplit( cImage, , , @cExt )
      cExt := upper(cExt)
      DO CASE
      CASE cExt == ".PNG"
         oImage := HPDF_LoadPngImageFromFile2( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )
      CASE cExt == ".JPG"
         oImage := HPDF_LoadJPEGImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], cImage )

      OTHERWISE

         Savefile += "\_"+cfilenoext(cimage)+"_.Png"

         IF !file(Savefile)
            nh := BT_BitmapLoadFile (cimage)
            BT_BitmapSaveFile (nh, Savefile, BT_FILEFORMAT_PNG )
            BT_BitmapRelease (nh)
         ENDIF
         oImage := HPDF_LoadPngImageFromFile( _HMG_HPDFDATA[ 1 ][ 1 ], Savefile )
         ferase(Savefile)

      ENDCASE

   ELSE
      _HMG_HPDF_Error( 7 )

      RETURN NIL
   ENDIF
   IF empty( oImage )
      _HMG_HPDF_Error( 7 )

      RETURN NIL
   ENDIF
   IF lstretch
      nImageHeight := _HMG_HPDF_Pixel2MM( nypos )
      nImageWidth  := _HMG_HPDF_Pixel2MM( nWidth - nxpos )
   ENDIF
   HPDF_Page_DrawImage( _HMG_HPDFDATA[ 1 ][ 7 ], oImage, nxPos, nyPos - _HMG_HPDF_MM2Pixel( nImageHeight ), _HMG_HPDF_MM2Pixel( nImageWidth ), _HMG_HPDF_MM2Pixel( nImageHeight ) )

   RETURN NIL
