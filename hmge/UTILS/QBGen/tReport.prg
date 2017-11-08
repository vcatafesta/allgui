/*******************************************************************************
    Filename        : tReport.prg
    URL             : \\ServerName\Minigui\UTILS\QBGen\tReport.prg

    Created         : 26 October 2017 (13:15:11)
    Created by      : Pierpaolo Martinello

    Last Updated    : 27 October 2017 (16:29:39)
    Updated by      : Pierpaolo

    Comments        : RetEditArr                  Line 209
*******************************************************************************/
#include <hmg.ch>
#include "i_winuser.ch"
#include "dbstruct.ch"

#define GDER      GRID_JTFY_RIGHT
#define GIZQ      GRID_JTFY_LEFT
#define GCEN      GRID_JTFY_CENTER

#define HDN_ITEMCHANGINGA       (HDN_FIRST-0)
#define HDN_ITEMCHANGEDA        (HDN_FIRST-1)

#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#TRANSLATE ZAPS(<X>) => ALLTRIM(STR(<X>))
#define msgtest( c ) MSGSTOP( "Procedura: "+Procname()+CRLF+c, hb_ntos(procline()))
#define COMMA if (!Ton,' ;','')

*-----------------------------------------------------------------------------*
PROCEDURE URE(aHdr1,alen1)
*-----------------------------------------------------------------------------*
Local ahdr :={'       Fields ->'} , aLen := {105}, ni
Local  aH1 := {"Header 1"} ,        aH2  := {"Header 2"}, aRows :={}
Local aW   := {"Width"} ,           aTot := {"Totals"} , aFo    := {"nFormats"}
Local sBL1 := {{||.F.}} ,           IBL  := { {} },      bValid := {{||cKFld()} }
Local aValM:= {""} , Mlen := 0 ,    Bk4  ,mF := len( aHdr1 )
LOCAL nMax,  cTf ,  apaper:= aclone(apapeles) , aEdit3 ,   aGrp3:={"None","EVERY PAGE"}

LOCAL aEdit:={;           // types for 'DYNAMIC'
         { 'TEXTBOX','CHARACTER'}                ,;
         { 'TEXTBOX','CHARACTER'}                ,;
         { 'TEXTBOX','NUMERIC','9,999.99'}          ,;
         { 'CHECKBOX' , 'Yes' , 'No' }           ,;
         { 'TEXTBOX','CHARACTER'} }

LOCAL bBlock :={ |r,c| RetEditArr(aEdit, r, c) }
LOCAL bBlock3:={ |r,c| RetEditArr2(aEdit3, r, c) }

local aRows3 := {;
                { 'Image '         ,"" ,0 ,0,0,0 },;
                { 'Multiple'       ,.F.,"","Image","Every","Page" },;
                { 'Lpp'            ,50 ,"","Default 50","","" },;
                { 'Cpl'            ,80 ,"","Default 80","","" },;
                { 'Left Margin'    ,3  ,"","Default  0 ","",""},;
                { 'Top Margin'     ,3  ,"","Default  1 ","","" },;
                { 'Papersize'      ,9  ,"","Default     ","Letter","" },;
                { 'Dosmode'        ,.F.,"","Default No","","" },;
                { 'Preview'        ,.T.,"","Default Yes","","" } ,;
                { 'Select Printer' ,.F. ,"","Default No","",""},;
                { 'Grouped By'     ,1  ,"","Default     ","None","" },;
                { 'Group Header'   ,"" ,"","","","" },;
                { 'Orientation'    ,1  ,"","Default     ","Portrait","" },;
                { 'NoDateTimeStamp',.F.,"","Default No","","" } }

aeval (apaper,{|x,y| apaper[y]:=substr(x,9,len(x) )} ) // remove "DMPAPER_"
aeval(aLen1, {|e,i| aLen1[i] := e/8})

if "iif" $ aHdr1[1]
   hb_adel(aHdr1,1,.T.)
   mf --
Endif

for ni = 1 to mf
    ctf  := tFld(aHdr1[ni])  // return a type of field
    aadd (aHdr,aHdr1[ni])
    aadd (aGrp3,aHdr1[ni])
    aadd (sbl1,{||.T.} )
    aadd (bValid,{||cKFld()})
    aadd (aValm,"You can not sum this field !")
    aadd (IBL , { 'DYNAMIC', bBlock } )
    aadd ( aH1,"" )
    aadd ( aH2,aHdr1[ni] )
    aadd ( aW, aLen1[ni] )
    aadd ( aTot ,if ( "N" $ ctf,.t.,.F.) )
    aadd ( aFo,tFld(aHdr1[ni],.T.) )
    // Grid Width
    nMax := GetTextWidth( 0, aHdr[ni] )
    nMax := Max( nMax, 50 )
    aadd (aLen,nMax)
Next

 aEdit3:={;           // types for 'DYNAMIC'  Grid 3
         { 'TEXTBOX','CHARACTER'}                ,;      //    'Image ',"","","
         { 'CHECKBOX' , 'Yes' , 'No' }           ,;      //    'Multiple',"",""
         { 'TEXTBOX','NUMERIC'}                  ,;      //    'Lpp',"","","","
         { 'TEXTBOX','NUMERIC'}                  ,;      //    'Cpl',"","","","
         { 'TEXTBOX','NUMERIC'}                  ,;      //    'Lmargin',"","",
         { 'TEXTBOX','NUMERIC'}                  ,;      //    'Tmargin',"","",
         { 'COMBOBOX',apaper }                   ,;      //    'Papersize',"","
         { 'CHECKBOX' , 'Yes' , 'No' }           ,;      //    'Dosmode',"","",
         { 'CHECKBOX' , 'Yes' , 'No' }           ,;      //    'Preview',"","",
         { 'CHECKBOX' , 'Yes' , 'No' }           ,;      //    'Select' ,"","",
         { 'COMBOBOX',aGrp3 }                    ,;      //    'Grouped By',"",
         { 'TEXTBOX','CHARACTER'}                ,;      //    'Headrgrp',"",""
         { 'COMBOBOX', {"Portrait","Landscape"} },;      //    'Landscape',"","
         { 'CHECKBOX' , 'Yes' , 'No' } }                 //    'Nodatetimestamp

bk4 := Getsyscolor( COLOR_APPWORKSPACE )

AADD( aRows, aH1 )
AADD( aRows, AH2 )
AADD( aRows, aW )
AADD( aRows, aTot )
AADD( aRows, aFo )

aeval(alen,{|x|mlen += x })
mlen += 20
Mlen := min (mlen,GetDesktopWidth ()-5)

if IsWindowDefined("Form_2")
   Domethod( 'Form_2', 'Setfocus')
   Return
Endif

        DEFINE WINDOW Form_2 ;
                AT 100,10 ;
                WIDTH mlen ;
                HEIGHT 510 ;
                TITLE "URE: User Report Editor" ;
                WINDOWTYPE STANDARD ;
                ON RELEASE EventRemoveAll () ;
                ON MAXIMIZE OnResize() ;
                ON SIZE OnResize()

                DEFINE LABEL Title_1
                       COL 5
                       ROW 4
                       VALUE  "Title:"
                       WIDTH 40
                       HEIGHT 25
                END LABEL

                @ 4, 40 TEXTBOX TITLE1 PARENT Win_1 WIDTH 230 HEIGHT 16 VALUE "" BACKCOLOR WHITE FONTCOLOR BLACK  FONT 'Arial' SIZE 9 ToolTip '' NOBORDER

                DEFINE LABEL Title_2
                       COL 280
                       ROW 4
                       VALUE  "Subtitle:"
                       WIDTH 45
                       HEIGHT 25
                END LABEL

                @ 4, 330 TEXTBOX TITLE2 PARENT Win_1 WIDTH 230 HEIGHT 16 VALUE "" BACKCOLOR WHITE FONTCOLOR BLACK  FONT 'Arial' SIZE 9 ToolTip '' NOBORDER

                @ 29,0 GRID Grid_2 ;
                WIDTH mlen ;
                HEIGHT 138 ;
                HEADERS ahdr ;
                WIDTHS aLen ;
                ITEMS aRows ;
                EDIT ;
                INPLACE ibl ;
                COLUMNVALID bValid ;
                COLUMNWHEN sbl1 ;
                VALIDMESSAGES aValm ;
                CELLNAVIGATION ;
                VALUE {1, 2} ;

                @ 166,0 GRID Grid_3 ;
                WIDTH 565 ;
                HEIGHT 312 ;
                HEADERS { "     Options","       Value","AT <Row>","At <Col> ","TO <Row>","To <Col>" } ;
                WIDTHS  { 110,170,70,70,70,70} ;
                ITEMS aRows3 ;
                VALUE {1, 2} ;
                EDIT ;
                INPLACE { { } ,{ 'DYNAMIC',Bblock3 }, { 'DYNAMIC',Bblock3 } ,{ 'DYNAMIC',Bblock3 },{ 'DYNAMIC',Bblock3 },{ 'DYNAMIC',Bblock3 } } ;
                COLUMNWHEN { {||.F.},{||ckfld2()},{||CKFLD2()},{||CKFLD2()},{||CKFLD2()},{||CKFLD2()} } ;
                CELLNAVIGATION ;
                JUSTIFY {GIZQ,GIZQ,GCEN,GCEN,GCEN,GCEN} ;
                DYNAMICBACKCOLOR { nil, nil, { || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } ;
                                            ,{ || iif( This.CellRowIndex > 1 , bk4 , { 255,255,255 } ) } }

                @ 0, (ThisWindow.width -40) ButtonEx BL PARENT Form_2 CAPTION "" ACTION MOVE_COL(1)  WIDTH 30 FONT 'Arial' SIZE 9  Picture "Go_First" TOOLTIP "" NOTABSTOP
                @ 0, (ThisWindow.width -10) ButtonEx BR PARENT Form_2 CAPTION "" ACTION MOVE_COL(2)  WIDTH 30 FONT 'Arial' SIZE 9  Picture "Go_Last" TOOLTIP ""  NOTABSTOP

                DEFINE LABEL Mcol
                       COL ThisWindow.width -10
                       ROW 0
                       VALUE  "Move Fields"
                       WIDTH 40
                       HEIGHT 25
                       FONTNAME 'Arial'
                       FONTSIZE 8
                END LABEL


                @ 240, ThisWindow.width-100 Button B1 PARENT Form_2 CAPTION "Import" ACTION Treport("IMPORT")   WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
                @ 275, ThisWindow.width-100 Button B2 PARENT Form_2 CAPTION "Test"   ACTION Treport( )       WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
                @ 310, ThisWindow.width-100 Button B3 PARENT Form_2 CAPTION "Save"   ACTION Treport("SAVE")  WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""

                Form_2.grid_2.ColumnsAutoFitH

                UpdateStatus ( )

                CREATE EVENT PROCNAME EventHandler()

                ON KEY ESCAPE ACTION ThisWindow.Release

        END WINDOW

        Form_2.CENTER ;Form_2.ACTIVATE

RETURN

// Function used by codeblock from 'DYNAMIC' type return normal array used in INPLACE EDIT
*-----------------------------------------------------------------------------*
FUNCTION RetEditArr( aEdit, r, c )  // FOR GRID_2
*-----------------------------------------------------------------------------*
LOCAL aRet

   IF c > 1 .AND. r >= 1 .AND. r <= LEN(aEdit)
      aRet := aEdit[r]
   ELSE
     aRet := {"TEXTBOX","CHARACTER"}
   ENDIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION RetEditArr2( aEdit3, r, c )  // FOR GRID_3
*-----------------------------------------------------------------------------*
LOCAL aRet

   IF c == 2 .AND. r >= 1 .AND. r <= LEN(aEdit3)
      aRet:=aEdit3[r]
   ELSEif R=1 .and. C > 2
      aRet :=  { 'TEXTBOX','NUMERIC','9,999.99'}
   Else
      aRet := {"TEXTBOX","CHARACTER"}
   ENDIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
Procedure UpdateStatus()
*-----------------------------------------------------------------------------*
Local Ni, mlen := 0, h, Cols

     h := Form_2.Grid_2.HANDLE
  Cols := max(12, ListView_GetColumnCount ( h ) )

  for ni = 1 to Cols
      mLen += Form_2.grid_2.ColumnWIDTH(ni)
  Next
  Form_2.Width := mlen+20

RETURN
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ckfld( )       // avoid sum on non numeric fields
*-----------------------------------------------------------------------------*
LOCAL aRet := .t. , cFldt
local nCol := This.CellColIndex
local nRow := This.CellRowIndex

   IF nRow = 4
      cFldt := DBFIELDINFO(DBS_TYPE, FieldPos(Form_2.grid_2.header(ncol)) )
      if cFldt != "N" .and. This.CellValue = .T.
         aRet := .F.
      Endif
   ENDIF

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION ckfld2( )       // avoid use  of unused cells
*-----------------------------------------------------------------------------*
LOCAL aRet := .t., cImgFilName
local nCol := This.CellColIndex
local nRow := This.CellRowIndex

   if nRow > 1 .and. nCol > 2
      aRet := .F.
   Elseif nRow = 1 .and. Ncol = 2
      cImgFilName := Getfile( { {'All images','*.jpg; *.bmp; *.gif'},;    // acFilter
                                {'JPG Files', '*.jpg'},;
                                {'BMP Files', '*.bmp'},;
                                {'GIF Files', '*.gif'} },;
                                 'Open Image' )
      IF ! EMPTY( cImgFilName ) .OR. FILE( cImgFilName )
           Form_2.Grid_3.cell(1,2):= cImgFilName
           aRet := .F.
      Endif
   Endif

RETURN aRet
/*
*/
*-----------------------------------------------------------------------------*
Procedure OnResize()
*-----------------------------------------------------------------------------*

    IF Form_2.Width < 684
       Form_2.Width := 684
    ENDIF
    IF Form_2.Height < IF(IsXPThemeActive(), 523, 520)
       Form_2.Height := IF(IsXPThemeActive(), 515, 507)
    ENDIF

    ERASE WINDOW Form_2

    Form_2.Grid_2.Width  := Form_2.WIDTH //-IF(IsXPThemeActive(), 5, 5)

    Form_2.BL.col   := Form_2.width -125
    Form_2.BR.col   := Form_2.width -45
    Form_2.Mcol.col := Form_2.width -85
    Form_2.B1.col   := Form_2.width -110
    Form_2.B2.col   := Form_2.width -110
    Form_2.B3.col   := Form_2.width -110

Return
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION EventHandler(nHWnd, nMsg, nWParam, nLParam)
*-----------------------------------------------------------------------------*
Local Hndl

  HB_SYMBOL_UNUSED( nHWnd )
  HB_SYMBOL_UNUSED( nWParam )

  if IsWindowDefined("Form_2")
     hndl := Form_2.Grid_2.HANDLE
  Endif

  IF nMsg == WM_NOTIFY

     IF GetHWNDFrom( nLParam ) == ListView_GetHeader( Hndl )

        IF GetNotifyCode( nLParam ) == HDN_ITEMCHANGEDA
           UpdateStatus()
        ENDIF

     ENDIF

  ENDIF

RETURN NIL
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION tFld(cFld, LFmt)   // return a correct transform format template
*-----------------------------------------------------------------------------*
local cRval:="" , nFmt , nf ,dc :=0 , cFldt := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
Local nLimit := DBFIELDINFO(DBS_LEN, FieldPos( cFld ))

DEFAULT Lfmt to .f.

nLimit := int (nLimit+nLimit/2 )
if lFmt
   do case
      case cFldt = "N"
           nFmt := DBFIELDINFO(DBS_DEC, FieldPos( cFld ))
           for nf = 1 to nLimit
               cRval += "9"
               if ++dc = 3
                  cRval += ","
                  dc := 0
               Endif
           next
           cRval := CHARMIRR( cRval )
           if Left( cRval, 1 ) = ","
              cRval := SubStr( cRval, 2 )
           Endif
           if nFmt > 0
              cRval += "." + repl( "9", nFmt )
           Endif
           cRval := "@E "+ cRval
      case cFldt = "L"
           cRval := "Y"
   Endcase
Else
   cRval := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
Endif
REturn cRval
/*
*/
*-----------------------------------------------------------------------------*
procedure Treport(act)   // Test the Report
*-----------------------------------------------------------------------------*
local h,cols, aHeaders1, aHeaders2 ,a := {} ,awidths ,ato,cSaveFile, cstr:='',ni
Local aFormats , aGrpby := {,"EVERY PAGE"}, cGraphic:= NIL , Title, aSrc := {}
Local Cstr2 := '', cFileimp, Ton, spt := space(3)

DEFAULT act to "EXEC"

   h := Form_2.Grid_2.HANDLE
   Cols := ListView_GetColumnCount ( h )
   aHeaders1 := Form_2.Grid_2.Item (1)
   hb_adel(aHeaders1,1,.t.)
   aHeaders2 := Form_2.Grid_2.Item (2)
   hb_adel(aHeaders2,1,.t.)
   aWidths := Form_2.Grid_2.Item (3)
   hb_adel(aWidths,1,.t.)
   aTo := Form_2.Grid_2.Item (4)
   hb_adel(aTo,1,.t.)
   aFormats := Form_2.Grid_2.Item (5)
   hb_adel(aFormats,1,.t.)

   for ni = 2 to Cols
       aadd ( a, Form_2.Grid_2.Header( ni ) )
       aadd ( aGrpby, Form_2.Grid_2.Header( ni ) )
   Next

   Title :=  Form_2.Title1.value

   if !empty(Form_2.Grid_3.Cell( 1, 2 ) )
      cGraphic := Form_2.Grid_3.Cell( 1, 2 )
   Endif

   if !empty( Form_2.Title2.value )
      Title := Form_2.Title1.value+"|"+Form_2.title2.value
   Endif

   ( alias() )->( dbgotop() )

  Do Case
     Case act ="EXEC"
          easyreport ( ;
                 Title     ,;                                                 // Title
                 aheaders1 ,;                                                 // Header 1
                 aheaders2 ,;                                                 // Header 2
                 a         ,;                                                 // Fields
                 awidths   ,;                                                 // Widths
                 ato       ,;                                                 // Totals
                 Form_2.Grid_3.Cell( 3, 2 ) ,;                                // LPP
                 Form_2.Grid_3.Cell( 8, 2 ) ,;                                // Dos Mode
                 .T., ; // Form_2.Grid_3.Cell( 9, 2 ) ,;                      // Preview
                 cGraphic  ,;                                                 // Image
                 Form_2.Grid_3.Cell( 1, 3 ) , Form_2.Grid_3.Cell( 1, 4 ) ,;   // At Row, At Col
                 Form_2.Grid_3.Cell( 1, 5 ) , Form_2.Grid_3.Cell( 1, 6 ) ,;   // To Row, To Ccol
                 Form_2.Grid_3.Cell( 2, 2 ) ,;                                // Multiple Image
                 aGrpby[Form_2.Grid_3.Cell( 11, 2 )] ,;                       // Group By
                 Form_2.Grid_3.Cell( 12, 2 ) ,;                               // Header Group
                 Form_2.Grid_3.Cell( 13, 2 )>1 ,;                             // Orientation
                 Form_2.Grid_3.Cell(  4, 2 ) ,;                               // Cpl
                 Form_2.Grid_3.Cell( 10, 2 ) ,;                               // Select Printer
                 Alias()   ,;                                                 // Workarea
                 Form_2.Grid_3.Cell(  5, 2 ) ,;                               // Margin Left
                 aformats  ,;                                                 // Formats
                 Form_2.Grid_3.Cell( 7, 2 ) ,;                                // Papersize
                 Form_2.Grid_3.Cell(  6, 2 ) ,;                               // Margin Top
                 Form_2.Grid_3.Cell( 14, 2 ) )                                // NoDateTimeStamp

    Case act = "IMPORT"
          cFileimp := Getfile( { {'All report','*.rpt'},;    // acFilter
                                {'RPT Files', '*.rpt'} },;
                                 'Open Image' )

      IF !EMPTY( cFileimp ) .OR. FILE( cFileimp )
           rReport( cFileimp , a )
      else
          return
      Endif

    Case act ="SAVE"

         Ton := Msgyesno(padc("Save as template ?",55)+CRLF+'(Otherwise will be created as standard code.)')
         if Ton
            spt := space(7)
         Endif

         cSaveFile := cFilePath(GetExeFileName())+ "\" + SubStr(Alias(),1,4) + '.Rpt'
         cSaveFile := PutFile( { {"Report files (*.Rpt)", "*.rpt"}, {"All files (*.*)", "*.*"} }, , , ,cSaveFile , 1 )

         IF EMPTY( cSaveFile )
            return
         Endif

         IF File(cSaveFile)
            DELETE FILE &(cSaveFile)
         Endif
         if Ton
            aadd(aSrc,'DEFINE REPORT TEMPLATE ')
         Else
            aadd(aSrc,'DO REPORT ;')
         Endif
         aadd(aSrc,spt+'TITLE    '+[']+Title+[']+COMMA )
         aeval(aHeaders1,{|x| cStr +=[']+x+[',]} )
         aeval(aHeaders2,{|x| cStr2 +=[']+x+[',]} )
         aadd(aSrc,spt+'HEADERS  {' +REMRIGHT(cStr,',')+'} , {'+ REMRIGHT(cStr2,',')+'}'+COMMA )
         cStr :=''
         aeval(a,{|x| cStr +=[']+x+[',]} )
         aadd(aSrc,spt+'FIELDS   {'+REMRIGHT( cStr ,',')+'}'+COMMA )
         cStr :=''
         aeval( awidths, {|x|cstr += NTrim(x)+',' } )
         aadd(aSrc,spt+'WIDTHS   {'+REMRIGHT(cStr,",")+"}"+COMMA )
         cStr :=''
         aeval (ato,{|x| cStr += iif(x,'.T.','.F.')+[,]} )
         aadd(aSrc,spt+'TOTALS   {'+REMRIGHT(cStr,",")+"}"+COMMA )
         cStr :=''
         aeval(aFormats,{|x| cStr +=[']+x+[',]} )
         aadd(aSrc,spt+'NFORMATS {'+REMRIGHT( cStr ,',')+'}'+COMMA)
         aadd(aSrc,spt+'WORKAREA '+Alias()+ COMMA )
         aadd(aSrc,spt+'LPP      '+NTrim(Form_2.Grid_3.Cell( 3, 2 ))+COMMA )
         aadd(aSrc,spt+'CPL      '+NTrim(Form_2.Grid_3.Cell( 4, 2 ))+COMMA )
         aadd(aSrc,spt+'LMARGIN  '+NTrim(Form_2.Grid_3.Cell( 5, 2 ))+COMMA )
         aadd(aSrc,spt+'TMARGIN  '+NTrim(Form_2.Grid_3.Cell( 6, 2 ))+COMMA )
         aadd(aSrc,spt+'PAPERSIZE '+apapeles[Form_2.Grid_3.Cell( 7, 2 )]+COMMA )

         if Form_2.Grid_3.Cell( 8, 2 )
            aadd(aSrc,spt+'DOSMODE' +COMMA )
         Endif

         if Form_2.Grid_3.Cell(  9, 2 )
            aadd(aSrc,spt+'PREVIEW'+COMMA )
         Endif

         if Form_2.Grid_3.Cell( 10, 2 )
            aadd(aSrc,spt+'SELECT'+COMMA )
         Endif

         if !empty( cGraphic )
         aadd(aSrc,spt+'IMAGE    {"'+cGraphic+'",'+NTrim(Form_2.Grid_3.Cell( 1, 3 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 4 )) ;
                                                 +','+NTrim(Form_2.Grid_3.Cell( 1, 5 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 6 ))+"}"+COMMA )
         Endif

         if Form_2.Grid_3.Cell(  2, 2 )
            aadd(aSrc,spt+'MULTIPLE'+COMMA )
         Endif

         if Form_2.Grid_3.Cell( 11, 2 ) > 1
            aadd(aSrc,spt+'GROUPED BY '+[']+aGrpby[Form_2.Grid_3.Cell( 11, 2 )]+[']+COMMA )
            aadd(aSrc,spt+'HEADRGRP '+[']+Form_2.Grid_3.Cell( 12, 2 )+[']+COMMA )
         Endif

         if Form_2.Grid_3.Cell( 13, 2 ) > 1
            aadd(aSrc,spt+'LANDSCAPE'+COMMA )
         Endif

         if Form_2.Grid_3.Cell(  14, 2 )
            aadd(aSrc,spt+'NODATETIMESTAMP'+COMMA)
         Endif


         if Ton
            aadd(aSrc,'END REPORT')
         Else
            aadd(aSrc,'')
         Endif

         aeval(aSrc,{|x| STRFILE( x+CRLF, cSaveFile, .T.) } )
         // WriteFile(cSaveFile,aSrc)
         MessageBoxTimeout ('File was created...', '', MB_OK, 1000 )

     Endcase

Return
/*
*/
*-----------------------------------------------------------------------------*
procedure rReport( cFile,nF )   // Import the File Report
*-----------------------------------------------------------------------------*
local Hf:= hb_ATokens( MemoRead( cFile ), CRLF ), cObj, uVal, cTmp, nfl
local aTrue :={".T.","T","TRUE","Y","S","1"}, aGrpby := {"NONE","EVERY PAGE"}
// local aFalse:={".N.","N","FALSE","0"}
aeval(hf,{|x,y|hf[y] := trim(x)})
aeval(nf,{|x|aadd(aGrpby,x) } )
nfl := len( nf )


// Set defaults
Form_2.Grid_3.Cell( 1, 2 ):= ''         // Image
Form_2.Grid_3.Cell( 1, 3 ):= 0          // AT ROW
Form_2.Grid_3.Cell( 1, 4 ):= 0          // AT COL
Form_2.Grid_3.Cell( 1, 5 ):= 0          // TO ROW
Form_2.Grid_3.Cell( 1, 6 ):= 0          // TO COL
Form_2.Grid_3.Cell( 2, 2 ):= .F.        // Multiple
Form_2.Grid_3.Cell( 3, 2 ):= 50         // Lpp
Form_2.Grid_3.Cell( 4, 2 ):= 80         // Cpl
Form_2.Grid_3.Cell( 5, 2 ):= 0          // Left Margin
Form_2.Grid_3.Cell( 6, 2 ):= 0          // Top Margin
Form_2.Grid_2.Cell( 5, 2 ):= 1          // Papersize LETTER
Form_2.Grid_3.Cell( 8, 2 ):= .F.        // Dosmode
Form_2.Grid_3.Cell( 9, 2 ):= .T.        // Preview
Form_2.Grid_3.Cell(10, 2 ):= .F.        // Select  Printer
Form_2.Grid_3.Cell(11, 2 ):= 1          // Group By
Form_2.Grid_3.Cell(12, 2 ):= ""         // Group Header
Form_2.Grid_2.Cell(13, 2 ):= 1          // Orientation PORTRAIT
Form_2.Grid_2.Cell(14, 2 ):= .F.        // NodateTimeStamp

For Each cObj in hf
    cObj := alltrim(REMRIGHT(cObj,';'))
    uVal := alltrim(substr(cObj ,rAt(" ",cObj) ) )

    Do Case
       Case "TITLE" $ cObj
            cTmp := alltrim(substr(ltrim(cobj),6))
            cTmp := ReplLeft(cTmp," ","'")
            cTmp := alltrim(ReplRight(cTmp," ","'"))

            if "|" $ uVal
              Form_2.title1.value := substr(cTmp,1,at("|",cTmp)-1)
              Form_2.title2.value := substr(cTmp,at("|",cTmp)+1,len(cTmp)-1)
            Else
              Form_2.title1.value := cTmp
              Form_2.title2.value := ""
            Endif

       Case "HEADERS" $ cObj
           cTmp:= SUBSTR(cObj,at("{",cObj) )
           uVal := at("}",cTmp )
           cTmp:= &(SUBSTR(cTmp,1,uVal ) )
           if len( ctmp ) > nFl
              msgstop("Error: Unproper Report","Forced Exit in Headers")
              exit
           Endif
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 1, y+1 ):= x })
           cTmp:= SUBSTR(cObj,rat("{",cObj) )
           uVal := rat("}",cTmp )
           cTmp:= &(SUBSTR(cTmp,1,uVal ) )
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 2, y+1 ):= x })

        Case "FIELDS" $ cObj
           cTmp:= &(SUBSTR(REMRIGHT( cObj ,';'),at("{",cObj) ))
           if len( ctmp ) > nFl
              msgstop("Error: Unproper Report","Forced Exit in Fields")
              exit
           Endif
           aeval(cTmp, {|x,y|Form_2.Grid_2.HEADER(y+1 ):= x })

       Case "WIDTHS" $ cObj
           cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
           if len( ctmp ) > nFl
              msgstop("Error: Unproper Report","Forced Exit in Widths")
              exit
           Endif
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 3, y+1 ):= x })

       Case "TOTALS" $ cObj
           cTmp:= &(uVal)
           if len( ctmp ) > nFl
              msgstop("Error: Unproper Report","Forced Exit in Totals")
              exit
           Endif
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 4, y+1 ):= x })

       Case "NFORMATS" $ cObj
           cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
           if len( ctmp ) > nFl
              msgstop("Error: Unproper Report","Forced Exit in Nformats")
              exit
           Endif
           aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 5, y+1 ):= x })

       Case "WORKAREA" $ cObj  //unused in this case
            // wArea := uval

       Case "LPP" $ cObj
            Form_2.Grid_3.Cell( 3, 2 ):= val(uval)

       Case "CPL" $ cObj
            Form_2.Grid_3.Cell( 4, 2 ):= val(uval)

       Case "LMARGIN" $ cObj
            Form_2.Grid_3.Cell( 5, 2 ):= val(uval)

       Case "TMARGIN" $ cObj
            Form_2.Grid_3.Cell( 6, 2 ):= val(uval)

       Case "PAPERSIZE" $ cObj
            Form_2.Grid_3.Cell( 7, 2 ):= ascan(apapeles,uval)

       Case "PREVIEW" $ cObj
            Form_2.Grid_3.Cell( 9, 2 ):= if (upper(uVal)="PREVIEW",.T.,ascan(aTrue,uVal) > 0)

       case "SELECT" $ cObj
            Form_2.Grid_3.Cell( 10, 2 ):= if (upper(uVal)="SELECT",.T.,ascan(aTrue,uVal) > 0)

       case "IMAGE" $ cObj
            cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
            aeval(cTmp, {|x,y|Form_2.Grid_3.Cell(1,y+1):= x })

       Case "MULTIPLE" $ cObj
            Form_2.Grid_3.Cell( 2, 2 ):= if (upper(uVal)="MULTIPLE",.T.,ascan(aTrue,uVal) > 0)

       Case "DOSMODE" $ cObj
            Form_2.Grid_3.Cell( 8, 2 ):= if (upper(uVal)="DOSMODE",.T.,ascan(aTrue,uVal) > 0)

       Case "LANDSCAPE" $ cObj
            Form_2.Grid_3.Cell( 13, 2 ):= if (upper(uVal)="LANDSCAPE",1,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

       Case "PORTRAIT" $ cObj
            Form_2.Grid_3.Cell( 13, 2 ):= if (upper(uVal)="PORTRAIT",1,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

       Case "NODATETIMESTAMP" $ cObj
            Form_2.Grid_3.Cell( 14, 2 ):= if (upper(uVal)="NODATETIMESTAMP",.T.,ascan(aTrue,uVal) > 0)

       Case "GROUPED" $ cObj
            cTmp := upper(REMLEFT(REMRIGHT(SUBSTR(cObj,at("BY",cObj)+3),"'"),"'"))
            Form_2.Grid_3.Cell(11, 2 ):= ascan(aGrpby,ctmp)

       Case "HEADRGRP" $ cObj
            Form_2.Grid_3.Cell(12, 2 ):= REMLEFT(REMRIGHT(UVAL,"'"),"'")

    EndCase
next
*/
Return
/*
*/
*-----------------------------------------------------------------------------*
PROCEDURE MOVE_Col (action)
*-----------------------------------------------------------------------------*
LOCAL aux, nCol_Disp, cCnt
LOCAL Grid_col ,aCv := Array(5),cv , aVt := Array(5),aHo, aHd

    IF Form_2.Grid_2.Itemcount = 0
       RETURN
    ENDIF

    aux      := Form_2.Grid_2.Value
    Grid_col := aux[2]
    cCnt     := GRID_ColumnCount ("Grid_2","Form_2")

    IF Grid_col < 2 .OR. Grid_col > cCnt
       RETURN
    ENDIF

    nCol_Disp := GRID_GetColumnDisplayPos ("Grid_2", "Form_2", Grid_Col)

    IF action = 1
       nCol_Disp --  // Move column: LEFT
    ELSE             // = 2
       nCol_Disp ++  // Move column: RIGTH
    ENDIF

    IF nCol_Disp >= 2 .AND. nCol_Disp <= cCnt
       // Move Header
       aho := Form_2.Grid_2.HEADER(nCol_disp)
       aHd := Form_2.Grid_2.HEADER( nCol_disp+ if(action=1,1,-1))
       Form_2.Grid_2.HEADER(nCol_disp):= aHd
       Form_2.Grid_2.HEADER( nCol_disp+ if(action=1,1,-1)):= aHo

       // Move Columns
       for each cv in aCv
           aCv[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp )
           aVt[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ if(action=1,1,-1) )
           Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp ):= aVt[cv:__enumIndex()]
           Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ if(action=1,1,-1) ) := aCv[cv:__enumIndex()]
       Next
       Form_2.Grid_2.setfocus

       if action = 1
          _pushkey( VK_LEFT )
       Else
          _pushKey( VK_RIGHT )
       Endif
    ENDIF

    Form_2.Grid_2.Refresh
RETURN
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GRID_GetColumnDisplayPos ( cControlName, cParentForm, nColIndex )
*-----------------------------------------------------------------------------*
   LOCAL nPos, ArrayOrder
   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   ENDIF

   // LISTVIEW_GETCOLUMNORDERARRAY: Low-level function in C (see the end of this file)
   ArrayOrder := LISTVIEW_GETCOLUMNORDERARRAY ( GetControlHandle ( cControlName, cParentForm ), GRID_ColumnCount ( cControlName, cParentForm ) )
   nPos := AScan ( ArrayOrder, nColIndex )

RETURN nPos
/*
*/
*-----------------------------------------------------------------------------*
FUNCTION GRID_ColumnCount ( cControlName, cParentForm )
*-----------------------------------------------------------------------------*
   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   ENDIF

RETURN LISTVIEW_GETCOLUMNCOUNT ( GetControlHandle ( cControlName, cParentForm ) )

#pragma BEGINDUMP

#include <mgdefs.h>
#include <commctrl.h>

// ListView_GetHeader( hWnd )
HB_FUNC ( LISTVIEW_GETHEADER )
{
   HB_RETNL( ( LONG_PTR ) ListView_GetHeader( ( HWND ) HB_PARNL( 1 ) ) );
}

HB_FUNC ( LISTVIEW_GETCOLUMNORDERARRAY )
{
   int i, *p;
   p = (int*) GlobalAlloc (GMEM_FIXED | GMEM_ZEROINIT, sizeof(int)*hb_parni(2));
   ListView_GetColumnOrderArray ((HWND) hb_parnl(1), hb_parni(2), (int*) p);
   hb_reta (hb_parni(2));
   for( i= 0; i < hb_parni(2); i++ )
        HB_STORNI( (int)(*(p+i))+1, -1, i+1);
   GlobalFree (p);
}

#pragma ENDDUMP
