
MEMVAR  _HMG_SYSDATA

#include 'hmg.ch'
#include 'hbclass.ch'
#include 'common.ch'

CREATE CLASS TPRINT

   DATA cprintlibrary      INIT "MINIPRINT"  PROTECTED
   DATA nmhor              INIT (10)/4.75    PROTECTED
   DATA nmver              INIT (10)/2.45    PROTECTED
   DATA nhfij              INIT (12/3.70)    PROTECTED
   DATA nvfij              INIT (12/1.65)    PROTECTED
   DATA cunits             INIT "ROWCOL"     PROTECTED
   DATA cprinter           INIT ""           PROTECTED

   DATA aprinters          INIT {}           PROTECTED
   DATA aports             INIT {}           PROTECTED

   DATA lprerror           INIT .F.
   DATA exit               INIT .F.          PROTECTED
   DATA acolor             INIT {1,1,1}      PROTECTED
   DATA cfontname          INIT "courier new" PROTECTED
   DATA nfontsize          INIT 10            PROTECTED
   DATA nwpen              INIT 0.1   PROTECTED //// ancho del pen
   DATA tempfile           INIT gettempdir()+"T"+ALLTRIM(STR(int(hb_random(999999)),8))+".prn" PROTECTED
   DATA impreview          INIT .F. PROTECTED
   DATA cversion            INIT "V1.2" PROTECTED

   METHOD init()
   METHOD begindoc()
   METHOD enddoc()
   METHOD printdos()
   METHOD beginpage()
   METHOD condendos()
   METHOD NORMALDOS()
   METHOD endpage()
   METHOD release()
   METHOD printdata()
   METHOD printimage
   METHOD printline
   METHOD printrectangle
   METHOD selprinter()
   METHOD getdefprinter()
   METHOD setcolor()
   METHOD setpreviewsize()
   METHOD setunits()   ////// mm o rowcol
   METHOD printroundrectangle()
   METHOD version()  INLINE ::cversion

   ENDCLASS

METHOD condenDOS() CLASS TPRINT

   IF ::cprintlibrary="DOS"
      @ prow(), pcol() say CHR(15)
   ENDIF

   RETURN NIL

METHOD normaldos() CLASS TPRINT

   IF ::cprintlibrary="DOS"
      @ prow(), pcol() say CHR(18)
   ENDIF

   RETURN NIL

METHOD setpreviewsize(ntam)

   IF ntam=NIL .or. ntam>5
      ntam=1
   ENDIF

   RETURN NIL

METHOD release() CLASS TPRINT

   IF ::exit

      RETURN NIL
   ENDIF
   DO CASE
   ENDCASE

   RETURN NIL

METHOD init(clibx) CLASS TPRINT

   clibx := NIL   // ADD

   IF _IsWindowDefined ( "_HMG_PRINTER_SHOWPREVIEW" )
      msgstop("Print preview pending, close first")
      ::exit:=.T.

      RETURN NIL
   ENDIF

   ::aprinters:=aprinters()

   DO CASE

   CASE ::cprintlibrary="DOS"
      ::impreview:=.F.
   ENDCASE

   RETURN NIL

METHOD selprinter( lselect , lpreview, llandscape , npapersize ,cprinterx) CLASS TPRINT

   LOCAL Worientation, lsucess := .T.

   IF ::exit
      ::lprerror:=.T.

      RETURN NIL
   ENDIF

   SETPRC(0,0)

   DEFAULT llandscape to .F.

   DO CASE

   CASE ::cprintlibrary="MINIPRINT"

      IF llandscape
         Worientation:= PRINTER_ORIENT_LANDSCAPE
      ELSE
         Worientation:= PRINTER_ORIENT_PORTRAIT
      ENDIF

      IF lselect .and. lpreview .and. cprinterx = NIL
         ::cPrinter := GetPrinter()
         IF Empty (::cPrinter)
            ::lprerror:=.T.

            RETURN NIL
         ENDIF

         IF npapersize#NIL
            SELECT PRINTER ::cprinter to lsucess ;
               ORIENTATION worientation ;
               PAPERSIZE npapersize       ;
               PREVIEW
         ELSE
            SELECT PRINTER ::cprinter to lsucess ;
               ORIENTATION worientation ;
               PREVIEW
         ENDIF
      ENDIF

      IF (.not. lselect) .and. lpreview .and. cprinterx = NIL

         IF npapersize#NIL
            SELECT PRINTER DEFAULT TO lsucess ;
               ORIENTATION worientation  ;
               PAPERSIZE npapersize       ;
               PREVIEW
         ELSE
            SELECT PRINTER DEFAULT TO lsucess ;
               ORIENTATION worientation  ;
               PREVIEW
         ENDIF
      ENDIF

      IF (.not. lselect) .and. (.not. lpreview) .and. cprinterx = NIL

         IF npapersize#NIL
            SELECT PRINTER DEFAULT TO lsucess  ;
               ORIENTATION worientation  ;
               PAPERSIZE npapersize
         ELSE
            SELECT PRINTER DEFAULT TO lsucess  ;
               ORIENTATION worientation
         ENDIF
      ENDIF

      IF lselect .and. .not. lpreview .and. cprinterx = NIL
         ::cPrinter := GetPrinter()
         IF Empty (::cPrinter)
            ::lprerror:=.T.

            RETURN NIL
         ENDIF

         IF npapersize#NIL
            SELECT PRINTER ::cprinter to lsucess ;
               ORIENTATION worientation ;
               PAPERSIZE npapersize
         ELSE
            SELECT PRINTER ::cprinter to lsucess ;
               ORIENTATION worientation
         ENDIF
      ENDIF

      IF cprinterx # NIL .AND. lpreview
         IF Empty (cprinterx)
            ::lprerror:=.T.

            RETURN NIL
         ENDIF

         IF npapersize#NIL
            SELECT PRINTER cprinterx to lsucess ;
               ORIENTATION worientation ;
               PAPERSIZE npapersize ;
               PREVIEW
         ELSE
            SELECT PRINTER cprinterx to lsucess ;
               ORIENTATION worientation ;
               PREVIEW
         ENDIF
      ENDIF

      IF cprinterx # NIL .AND. .not. lpreview
         IF Empty (cprinterx)
            ::lprerror:=.T.

            RETURN NIL
         ENDIF

         IF npapersize#NIL
            SELECT PRINTER cprinterx to lsucess ;
               ORIENTATION worientation ;
               PAPERSIZE npapersize
         ELSE
            SELECT PRINTER cprinterx to lsucess ;
               ORIENTATION worientation
         ENDIF
      ENDIF

      IF .NOT. lsucess
         ::lprerror:=.T.

         RETURN NIL
      ENDIF

   CASE ::cprintlibrary="DOS"
      DO WHILE file(::tempfile)
         ::tempfile:=gettempdir()+"T"+ALLTRIM(STR(int(hb_random(999999)),8))+".prn"
      ENDDO
      IF lpreview
         ::impreview:=.T.
      ENDIF
   ENDCASE

   RETURN NIL

METHOD BEGINDOC(cdoc) CLASS TPRINT

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      START PRINTDOC NAME cDoc   //// modificaicon en esta linea
      CASE ::cprintlibrary="DOS"
         SET PRINTER TO &(::tempfile)
         SET DEVICE TO PRINT
      ENDCASE

      RETURN self

METHOD ENDDOC() CLASS TPRINT

   LOCAL _nhandle,wr

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
   END PRINTDOC
CASE ::cprintlibrary="DOS"
   SET DEVICE TO SCREEN
   SET PRINTER TO
   _nhandle:=FOPEN(::tempfile,0+64)
   IF ::impreview
      wr:= HB_MemoRead ((::tempfile))   // ADD
      DEFINE WINDOW PRINT_PREVIEW  ;
            AT 10,10 ;
            WIDTH 640 HEIGHT 480 ;
            TITLE 'Preview -----> ' + ::tempfile ;
            MODAL

         @ 0,0 EDITBOX EDIT_P ;
            OF PRINT_PREVIEW ;
            WIDTH 590 ;
            HEIGHT 440 ;
            VALUE WR ;
            READONLY ;
            FONT 'Courier new' ;
            SIZE 10

         @ 10,600 button but_4 caption "X" width 30 action ( print_preview.release() )
         @ 110,600 button but_1 caption "+ +" width 30 action zoom("+")
         @ 210,600 button but_2 caption "- -" width 30 action zoom("-")
         @ 310,600 button but_3 caption "P" width 30 action (::printdos())

      END WINDOW

      CENTER WINDOW PRINT_PREVIEW
      ACTIVATE WINDOW PRINT_PREVIEW

   ELSE

      ::PRINTDOS()

   ENDIF

   IF FILE(::tempfile)
      fclose(_nhandle)
      ERASE &(::tempfile)
   ENDIF
ENDCASE

RETURN self

METHOD SETCOLOR(atColor) CLASS TPRINT

   ::acolor:=atColor

   RETURN NIL

METHOD beginPAGE() CLASS TPRINT

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      START PRINTPAGE
      CASE ::cprintlibrary="DOS"
         @ 0,0 SAY ""
      ENDCASE

      RETURN self

METHOD ENDPAGE() CLASS TPRINT

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
   END PRINTPAGE
CASE ::cprintlibrary="DOS"
   EJECT
ENDCASE

RETURN self

METHOD getdefprinter() CLASS TPRINT

   LOCAL cdefprinter

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      cdefprinter:=GetDefaultPrinter()
   ENDCASE

   RETURN cdefprinter

METHOD setunits(cunitsx) CLASS TPRINT

   IF cunitsx="MM"
      ::cunits:="MM"
   ELSE
      ::cunits:="ROWCOL"
   ENDIF

   RETURN NIL

METHOD printdata(nlin,ncol,data,cfont,nsize,lbold,acolor,calign,nlen) CLASS TPRINT

   LOCAL ctext,cspace

   // Local i,caux
   DO CASE
   CASE valtype(data)=='C'
      ctext:=data
   CASE valtype(data)=='N'
      ctext:=ALLTRIM(STR(data))
   CASE valtype(data)=='D'
      ctext:=dtoc(data)
   CASE valtype(data)=='L'
      ctext:= iif(data,'T','F')
   CASE valtype(data)=='M'
      ctext:=data
   OTHERWISE
      ctext:=""
   ENDCASE

   DEFAULT calign to "L"

   DEFAULT nlen to 15

   DO CASE
   CASE calign = "C"
      cspace=  space( (int(nlen)-HMG_LEN(ctext))/2 )
   CASE calign = "R"
      cspace = space(int(nlen)-HMG_LEN(ctext))
   OTHERWISE
      cspace:=""
   ENDCASE

   DEFAULT nlin to 1

   DEFAULT ncol to 1

   DEFAULT ctext to ""

   DEFAULT lbold to .F.

   DEFAULT cfont to ::cfontname

   DEFAULT nsize to ::nfontsize

   DEFAULT acolor to ::acolor

   IF ::cunits="MM"
      ::nmver:=1
      ::nvfij:=0
      ::nmhor:=1
      ::nhfij:=0
   ELSE
      ::nmhor  := (::nfontsize)/4.75
      ::nmver  := (::nfontsize)/2.45
      ::nvfij  := (12/1.65)
      ::nhfij  := (12/3.70)
   ENDIF

   ctext:= cspace + ctext

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      IF .not. lbold
         IF calign="R"

            @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2  +((nlen+1)*nsize/4.75) PRINT (ctext) font cfont size nsize COLOR ::acolor RIGHT
         ELSE
            @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2 PRINT (ctext) font cfont size nsize COLOR ::acolor
         ENDIF
      ELSE
         IF calign="R"
            @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2+((nlen+1)*nsize/4.75) PRINT (ctext) font cfont size nsize  BOLD COLOR ::acolor RIGHT
         ELSE
            @ nlin*::nmver+::nvfij, ncol*::nmhor+ ::nhfij*2 PRINT (ctext) font cfont size nsize  BOLD COLOR ::acolor
         ENDIF
      ENDIF

   CASE ::cprintlibrary="DOS"
      IF .not. lbold
         @ nlin,ncol say (ctext)
      ELSE
         @ nlin,ncol say (ctext)
         @ nlin,ncol say (ctext)
      ENDIF
   ENDCASE

   RETURN self

METHOD printimage(nlin,ncol,nlinf,ncolf,cimage) CLASS TPRINT

   DEFAULT nlin to 1

   DEFAULT ncol to 1

   DEFAULT cimage to ""

   DEFAULT nlinf to 4

   DEFAULT ncolf to 4

   IF ::cunits="MM"
      ::nmver:=1
      ::nvfij:=0
      ::nmhor:=1
      ::nhfij:=0
   ELSE
      ::nmhor  := (::nfontsize)/4.75
      ::nmver  := (::nfontsize)/2.45
      ::nvfij  := (12/1.65)
      ::nhfij  := (12/3.70)
   ENDIF
   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      @  nlin*::nmver+::nvfij , ncol*::nmhor+::nhfij*2 PRINT IMAGE cimage WIDTH ((ncolf - ncol-1)*::nmhor + ::nhfij) HEIGHT ((nlinf+0.5 - nlin)*::nmver+::nvfij)
   ENDCASE

   RETURN NIL

METHOD printline(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT

   DEFAULT nlin to 1

   DEFAULT ncol to 1

   DEFAULT nlinf to 4

   DEFAULT ncolf to 4

   DEFAULT atcolor to ::acolor

   DEFAULT ntwpen to ::nwpen

   IF ::cunits="MM"
      ::nmver:=1
      ::nvfij:=0
      ::nmhor:=1
      ::nhfij:=0
   ELSE
      ::nmhor  := (::nfontsize)/4.75
      ::nmver  := (::nfontsize)/2.45
      ::nvfij  := (12/1.65)
      ::nhfij  := (12/3.70)
   ENDIF

   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      @  (nlin+.2)*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT LINE TO  (nlinf+.2)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2  COLOR atcolor PENWIDTH ntwpen  //// CPEN
   CASE ::cprintlibrary="DOS"
      IF nlin=nlinf
         @ nlin,ncol say REPLICATE("-",ncolf-ncol+1)
      ENDIF
   ENDCASE

   RETURN NIL

METHOD printrectangle(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT

   DEFAULT nlin to 1

   DEFAULT ncol to 1

   DEFAULT nlinf to 4

   DEFAULT ncolf to 4

   DEFAULT atcolor to ::acolor

   DEFAULT ntwpen to ::nwpen

   IF ::cunits="MM"
      ::nmver:=1
      ::nvfij:=0
      ::nmhor:=1
      ::nhfij:=0
   ELSE
      ::nmhor  := (::nfontsize)/4.75
      ::nmver  := (::nfontsize)/2.45
      ::nvfij  := (12/1.65)
      ::nhfij  := (12/3.70)
   ENDIF
   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT RECTANGLE TO  (nlinf+0.5)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2 COLOR atcolor  PENWIDTH ntwpen  //// CPEN
   ENDCASE

   RETURN NIL

METHOD printroundrectangle(nlin,ncol,nlinf,ncolf,atcolor,ntwpen ) CLASS TPRINT

   DEFAULT nlin to 1

   DEFAULT ncol to 1

   DEFAULT nlinf to 4

   DEFAULT ncolf to 4

   DEFAULT atcolor to ::acolor

   DEFAULT ntwpen to ::nwpen

   IF ::cunits="MM"
      ::nmver:=1
      ::nvfij:=0
      ::nmhor:=1
      ::nhfij:=0
   ELSE
      ::nmhor  := (::nfontsize)/4.75
      ::nmver  := (::nfontsize)/2.45
      ::nvfij  := (12/1.65)
      ::nhfij  := (12/3.70)
   ENDIF
   DO CASE
   CASE ::cprintlibrary="MINIPRINT"
      @  nlin*::nmver+::nvfij,ncol*::nmhor+::nhfij*2 PRINT RECTANGLE TO  (nlinf+0.5)*::nmver+::nvfij,ncolf*::nmhor+::nhfij*2 COLOR atcolor  PENWIDTH ntwpen  ROUNDED //// CPEN
   ENDCASE

   RETURN NIL

METHOD printdos() CLASS TPRINT

   LOCAL cbat, nHdl

   cbat:='b'+ALLTRIM(STR(random(999999),6))+'.bat'
   nHdl := FCREATE( cBat )
   FWRITE( nHdl, "copy " + ::tempfile + " prn" + CHR( 13 ) + CHR( 10 ) )
   FWRITE( nHdl, "rem comando auxiliar de impresion" + CHR( 13 ) + CHR( 10 ) )
   FCLOSE( nHdl )
   WAITrun( cBat, 0 )
   ERASE &cbat

   RETURN NIL

STATIC FUNCTION zoom(cOp)

   IF cop="+" .and. print_preview.edit_p.fontsize <= 24
      print_preview.edit_p.fontsize:=  print_preview.edit_p.fontsize + 2
   ENDIF

   IF cop="-" .and. print_preview.edit_p.fontsize > 7
      print_preview.edit_p.fontsize:=  print_preview.edit_p.fontsize - 2
   ENDIF

   RETURN NIL
