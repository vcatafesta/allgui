/*******************************************************************************
Filename        : tReport.prg
URL             : \\ServerName\MiniGUI\UTILS\QBGen\tReport.prg

Created         : 26 October 2017 (13:15:11)
Created by      : Pierpaolo Martinello

Last Updated    : 04 November 2017 (18:08:17)
Updated by      : Pierpaolo

Comments        : RetEditArr                  Line 209
*******************************************************************************/
#include <hmg.ch>
#include "i_winuser.ch"
#include "dbstruct.ch"
//#include "Winprint.ch"

#define GDER      GRID_JTFY_RIGHT
#define GIZQ      GRID_JTFY_LEFT
#define GCEN      GRID_JTFY_CENTER

#define HDN_ITEMCHANGINGA       (HDN_FIRST-0)
#define HDN_ITEMCHANGEDA        (HDN_FIRST-1)

// ** CONSTANTS (nControl) ***
#define _GRID_COLUMNCAPTION_    -1   // _HMG_aControlPageMap   [i]
#define _GRID_ONHEADCLICK_      -2   // _HMG_aControlHeadClick [i]
#define _GRID_COLUMNWIDTH_       2   // _HMG_aControlMiscData1 [i,2]
#define _GRID_COLUMNJUSTIFY_     3   // _HMG_aControlMiscData1 [i,3]
#define _GRID_DYNAMICFORECOLOR_ 11   // _HMG_aControlMiscData1 [i,11]
#define _GRID_DYNAMICBACKCOLOR_ 12   // _HMG_aControlMiscData1 [i,12]
#define _GRID_COLUMNCONTROLS_   13   // _HMG_aControlMiscData1 [i,13]
#define _GRID_COLUMNVALID_      14   // _HMG_aControlMiscData1 [i,14]
#define _GRID_COLUMNWHEN_       15   // _HMG_aControlMiscData1 [i,15]

#define NTrim( n ) LTRIM( STR( n,20, IF( n == INT( n ), 0, set(_SET_DECIMALS) ) ))
#translate ZAPS(<X>) => ALLTRIM(STR(<X>))
#define msgtest( c ) MSGSTOP( "Procedura: "+Procname()+CRLF+c, hb_ntos(procline()))
#define COMMA IF (!Ton,' ;','')

PROCEDURE URE( aHdr1,alen1 )

   LOCAL ahdr :={'       Fields ->'} , aLen := {105}, ni
   LOCAL  aH1 := {"Header 1"} ,        aH2  := {"Header 2"}, aRows :={}
   LOCAL aW   := {"Width"} ,           aTot := {"Totals"} , aFo    := {"nFormats"}
   LOCAL sBL1 := {{||.F.}} ,           IBL  := { {} },      bValid := {{||cKFld()} }
   LOCAL aValM:= {""} , Mlen := 0 , Bk4 ,mF := len( aHdr1 ) , OnHc
   LOCAL nMax,  cTf ,  apaper:= aclone(apapeles) , aEdit3 ,   aGrp3:={"None","EVERY PAGE"}

   LOCAL aEdit:={;           // types for 'DYNAMIC'
      { 'TEXTBOX','CHARACTER'}                ,;
      { 'TEXTBOX','CHARACTER'}                ,;
      { 'TEXTBOX','NUMERIC','9,999.99'}          ,;
      { 'CHECKBOX' , 'Yes' , 'No' }           ,;
      { 'TEXTBOX','CHARACTER'} }

   LOCAL bBlock :={ |r,c| RetEditArr(aEdit, r, c) }
   LOCAL bBlock3:={ |r,c| RetEditArr2(aEdit3, r, c) }
   LOCAL bBlock4:={ |r| SetFocusColumn( r ) }

   LOCAL aRows3 := {;
      { 'Image '         ,"" ,0 ,0,0,0 },;
      { 'Multiple'       ,.F.,"Image","Every","Page","Default No" },;
      { 'Lpp'            ,50 ,"Default 50","","","" },;
      { 'Cpl'            ,80 ,"Valid        ","80 - 96","120 - 140","160"},;
      { 'Left Margin'    ,3  ,"Default  0 ","","",""},;
      { 'Top Margin'     ,3  ,"Default  1 ","","","" },;
      { 'Papersize'      ,9  ,"Default     ","Letter","","" },;
      { 'Dosmode'        ,.F.,"Default No","","","" },;
      { 'Preview'        ,.T.,"Default Yes","","","" } ,;
      { 'Select Printer' ,.F.,"Default No","","",""},;
      { 'Grouped By'     ,1  ,"Default     ","NONE","","" },;
      { 'Group Header'   ,"" ,"","","","" },;
      { 'Orientation'    ,1  ,"Default     ","Portrait","","" },;
      { 'NoDateTimeStamp',.F.,"Default No","","","" } }

   REQUEST DBFCDX
   RDDSETDEFAULT("DBFCDX")

   aeval (apaper,{|x,y| apaper[y]:=substr(x,9,len(x) )} ) // remove "DMPAPER_"
   aeval(aLen1, {|e,i| aLen1[i] := e/8})

   IF "iif" $ aHdr1[1]
      hb_adel(aHdr1,1,.T.)
      mf --
   ENDIF
   OnHc :={ bBlock4 }

   FOR ni = 1 to mf
      ctf  := tFld(aHdr1[ni])  // return a type of field
      aadd (OnHc, bblock4 )
      aadd (aHdr,aHdr1[ni])
      aadd (aGrp3,aHdr1[ni])
      aadd (sbl1,{||.T.} )
      aadd (bValid,{||cKFld()})
      aadd (aValm,"You can not sum this field !")
      aadd (IBL , { 'DYNAMIC', bBlock } )
      aadd ( aH1,"" )
      aadd ( aH2,aHdr1[ni] )
      aadd ( aW, aLen1[ni] )
      aadd ( aTot ,IF ( "N" $ ctf,.t.,.F.) )
      aadd ( aFo,tFld(aHdr1[ni],.T.) )
      // Grid Width
      nMax := GetTextWidth( 0, aHdr[ni] )
      nMax := Max( nMax, 50 )
      aadd (aLen,nMax)
   NEXT

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

   IF IsWindowDefined("Form_2")
      Domethod( 'Form_2', 'Setfocus')

      RETURN
   ENDIF

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
         ON HEADCLICK OnHc ;
         EDIT ;
         INPLACE ibl ;
         COLUMNVALID bValid ;
         COLUMNWHEN sbl1 ;
         VALIDMESSAGES aValm ;
         CELLNAVIGATION ;
         VALUE {1, 2} ;

      DEFINE CONTEXT MENU CONTROL Grid_2 of Form_2
         MENUITEM "Delete a focused column. " ACTION DELETE_Col()
      END MENU

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

      @ 240, ThisWindow.width-100 Button B1 PARENT Form_2 CAPTION "&Import" ACTION Treport("IMPORT")   WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
      @ 275, ThisWindow.width-100 Button B2 PARENT Form_2 CAPTION "&Test"   ACTION Treport( )       WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""
      @ 310, ThisWindow.width-100 Button B3 PARENT Form_2 CAPTION "&Save"   ACTION Treport("SAVE")  WIDTH 80 FONT 'Arial' SIZE 9  TOOLTIP ""

      Form_2.grid_2.ColumnsAutoFitH

      UpdateStatus ( )

      CREATE EVENT PROCNAME EventHandler()

      ON KEY ESCAPE ACTION ThisWindow.Release

   END WINDOW

   Form_2.CENTER ;Form_2.ACTIVATE

   RETURN
   // Function used by codeblock bBlock4

PROCEDURE SetFocusColumn ( r )  // FOR GRID_2

   Form_2.Grid_2.VAlue := { 1, r }

   RETURN

   // Function used by codeblock bBlock from 'DYNAMIC' type return normal array used in INPLACE EDIT

FUNCTION RetEditArr( aEdit, r, c )  // FOR GRID_2

   LOCAL aRet

   IF c > 1 .AND. r >= 1 .AND. r <= LEN(aEdit)
      aRet := aEdit[r]
   ELSE
      aRet := {"TEXTBOX","CHARACTER"}
   ENDIF

   RETURN aRet
   /*
   */
   // Function used by codeblock bBlock3

FUNCTION RetEditArr2( aEdit3, r, c )  // FOR GRID_3

   LOCAL aRet

   IF c == 2 .AND. r >= 1 .AND. r <= LEN(aEdit3)
      aRet:=aEdit3[r]
   ELSEIF R=1 .and. C > 2
      aRet :=  { 'TEXTBOX','NUMERIC','9,999.99'}
   ELSE
      aRet := {"TEXTBOX","CHARACTER"}
   ENDIF

   RETURN aRet
   /*
   */

PROCEDURE UpdateStatus()

   LOCAL Ni, mlen := 0, h, Cols

   h := Form_2.Grid_2.HANDLE
   Cols := max(12, ListView_GetColumnCount ( h ) )

   FOR ni = 1 to Cols
      mLen += Form_2.grid_2.ColumnWIDTH(ni)
   NEXT
   Form_2.Width := mlen+20

   RETURN
   /*
   */

FUNCTION ckfld( )       // avoid sum on non numeric fields

   LOCAL aRet := .t. , cFldt
   LOCAL nCol := This.CellColIndex
   LOCAL nRow := This.CellRowIndex

   IF nRow = 4
      cFldt := DBFIELDINFO(DBS_TYPE, FieldPos(Form_2.grid_2.header(ncol)) )
      IF cFldt != "N" .and. This.CellValue = .T.
         aRet := .F.
      ENDIF
   ENDIF

   RETURN aRet
   /*
   */

FUNCTION ckfld2( )       // avoid use  of unused cells

   LOCAL aRet := .t., cImgFilName
   LOCAL nCol := This.CellColIndex
   LOCAL nRow := This.CellRowIndex

   IF nRow > 1 .and. nCol > 2
      aRet := .F.
   ELSEIF nRow = 1 .and. Ncol = 2
      cImgFilName := Getfile( { {'All images','*.jpg; *.bmp; *.gif'},;    // acFilter
         {'JPG Files', '*.jpg'},;
         {'BMP Files', '*.bmp'},;
         {'GIF Files', '*.gif'} },;
         'Open Image',.F.,.T. )
      IF ! EMPTY( cImgFilName ) .OR. FILE( cImgFilName )
         Form_2.Grid_3.cell(1,2):= cImgFilName
         aRet := .F.
      ENDIF
   ENDIF

   RETURN aRet
   /*
   */

PROCEDURE OnResize()

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

   RETURN
   /*
   */

FUNCTION EventHandler(nHWnd, nMsg, nWParam, nLParam)

   LOCAL Hndl

   HB_SYMBOL_UNUSED( nHWnd )
   HB_SYMBOL_UNUSED( nWParam )

   IF IsWindowDefined("Form_2")
      hndl := Form_2.Grid_2.HANDLE
   ENDIF

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

FUNCTION tFld(cFld, LFmt)   // return a correct transform format template

   LOCAL cRval:="" , nFmt , nf ,dc :=0 , cFldt := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
   LOCAL nLimit := DBFIELDINFO(DBS_LEN, FieldPos( cFld ))

   DEFAULT Lfmt to .f.

   nLimit := 1+ int (nLimit+nLimit/2 )
   IF lFmt
      DO CASE
      CASE cFldt = "N"
         nFmt := DBFIELDINFO(DBS_DEC, FieldPos( cFld ))
         FOR nf = 1 to nLimit
            cRval += "9"
            IF ++dc = 3
               cRval += ","
               dc := 0
            ENDIF
         NEXT
         cRval := CHARMIRR( cRval )
         IF Left( cRval, 1 ) = ","
            cRval := SubStr( cRval, 2 )
         ENDIF
         IF nFmt > 0
            cRval += "." + repl( "9", nFmt )
         ENDIF
         cRval := "@E "+ cRval
      CASE cFldt = "L"
         cRval := "Y"
      ENDCASE
   ELSE
      cRval := DBFIELDINFO(DBS_TYPE, FieldPos( cFld ))
   ENDIF

   RETURN cRval
   /*
   */

PROCEDURE Treport(act)   // Test the Report

   LOCAL h,cols, aHeaders1, aHeaders2 ,a := {} ,awidths ,ato,cSaveFile, cstr:='',ni
   LOCAL aFormats , aGrpby := {,"EVERY PAGE"}, cGraphic:= NIL , Title, aSrc := {}
   LOCAL Cstr2 := '', cFileimp, Ton, spt := space(3), nWrpt, Inde_On, aVo

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

   FOR ni = 2 to Cols
      aadd ( a, Form_2.Grid_2.Header( ni ) )
      aadd ( aGrpby, Form_2.Grid_2.Header( ni ) )
   NEXT

   Inde_On := aGrpby[Form_2.Grid_3.Cell( 11, 2 )]
   TITLE :=  Form_2.Title1.value

   IF !empty(Form_2.Grid_3.Cell( 1, 2 ) )
      cGraphic := Form_2.Grid_3.Cell( 1, 2 )
   ENDIF

   IF !empty( Form_2.Title2.value )
      TITLE := Form_2.Title1.value+"|"+Form_2.title2.value
   ENDIF

   FOR EACH ni in aHeaders1
      IF Form_2.Grid_2.ColumnWidth(ni:__enumIndex()) = 0
         hb_adel(a,ni:__enumIndex()-1,.T.)
         hb_adel(aHeaders1,ni:__enumIndex()-1,.T.)
         hb_adel(aHeaders2,ni:__enumIndex()-1,.T.)
         hb_adel(awidths,ni:__enumIndex()-1,.T.)
         hb_adel(aTo,ni:__enumIndex()-1,.T.)
         hb_adel(aformats,ni:__enumIndex()-1,.T.)
      ENDIF
   NEXT

   ( alias() )->( dbgotop() )

   DO CASE
   CASE act ="EXEC"
      check_db_Index ( Inde_On , Form_2.Grid_3.Cell( 11, 2 ) )
      nWrpt  := hb_DirScan(cFilePath( GetExeFileName() ), "*.Wrpt" )
      IF len(nWrpt) > 0
         IF msgyesno( "Do you want use a Winreport Interpreter Template ?" ;
               ,"Question",.T. )
            MessageBoxTimeout ('   Do you have saved your latest change ?', 'Remember', MB_OK, 1000 )
            cFileimp := Getfile( { {'Windows Report Interpreter','*.Wrpt'}} ;
               ,'Open Report Template', GetcurrentFolder() ,.f., .t. )
            IF !EMPTY( cFileimp )
               Winrepint( cFileimp )
            ENDIF

            RETURN
         ENDIF
      ENDIF
      EasyReport (      ;
         TITLE     ,;                                                 // Title
         aheaders1 ,;                                                 // Header 1
         aheaders2 ,;                                                 // Header 2
         a         ,;                                                 // Fields
         awidths   ,;                                                 // Widths
         ato       ,;                                                 // Totals
         Form_2.Grid_3.Cell( 3, 2 ) ,;                                // LPP
         Form_2.Grid_3.Cell( 8, 2 ) ,;                                // Dos Mode
         .T., ; // Form_2.Grid_3.Cell( 9, 2 ) ,;                      // Preview ALWAIS ACTIVE FOR TESTING
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

   CASE act = "IMPORT"
      cFileimp := Getfile( { {'All report','*.rpt'},;
         {'RPT Files', '*.rpt'} },;
         'Open Report Template' ,GetcurrentFolder() ,.f., .t.)

      IF !EMPTY( cFileimp ) .OR. FILE( cFileimp )
         rReport( cFileimp , a )
      ELSE

         RETURN
      ENDIF

   CASE act ="SAVE"

      aVo := InputWindow ( 'Enter choice for ', {'Output format :'},{1}, {{"Form Template","Standard Prg","W-R-Int. (as RowCol)"}} )
      IF aVo [1] = Nil

         RETURN
      ENDIF

      Ton := (aVo[1] = 1)

      IF Ton
         spt := space(7)
      ENDIF

      cSaveFile := cFilePath(GetExeFileName())+ "\" + SubStr(Alias(),1,4) + IF(aVo[1] >= 3 ,'.Wrpt','.Rpt')

      IF aVo[1] < 3
         cSaveFile := PutFile( { {"Report files (*.Rpt)", "*.Rpt"} ;
            ,{"Win Report Interpreter  (*.wrpt)","*.Wrpt"} ;
            ,{"All files (*.*)", "*.*"} }, , , ,cSaveFile , 1 )
      ELSE
         cSaveFile := PutFile( { {"Win Report Interpreter  (*.wrpt)","*.Wrpt"}  ;
            ,{"Report files (*.Rpt)", "*.Rpt"} ;
            ,{"All files (*.*)", "*.*"} }, , , ,cSaveFile , 1 )
      ENDIF
      IF Empty( cSaveFile )

         RETURN
      ENDIF

      IF File(cSaveFile)
         DELETE FILE &(cSaveFile)
      ENDIF

      IF aVo[1] >= 3       // WinReport Interpreter
         WrExport(cSavefile,aheaders1,aheaders2, aFormats ,a,aWidths,ato, Inde_On )

         RETURN
      ENDIF

      IF Ton
         aadd(aSrc,'DEFINE REPORT TEMPLATE ')
      ELSE
         aadd(aSrc,'DO REPORT ;')
      ENDIF
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

      IF Form_2.Grid_3.Cell( 8, 2 )
         aadd(aSrc,spt+'DOSMODE' +COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell(  9, 2 )
         aadd(aSrc,spt+'PREVIEW'+COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell( 10, 2 )
         aadd(aSrc,spt+'SELECT'+COMMA )
      ENDIF

      IF !empty( cGraphic )
         aadd(aSrc,spt+'IMAGE    {"'+cGraphic+'",'+NTrim(Form_2.Grid_3.Cell( 1, 3 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 4 )) ;
            +','+NTrim(Form_2.Grid_3.Cell( 1, 5 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 6 ))+"}"+COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell(  2, 2 )
         aadd(aSrc,spt+'MULTIPLE'+COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell( 11, 2 ) > 1
         aadd(aSrc,spt+'GROUPED BY '+[']+aGrpby[Form_2.Grid_3.Cell( 11, 2 )]+[']+COMMA )
         aadd(aSrc,spt+'HEADRGRP '+[']+Form_2.Grid_3.Cell( 12, 2 )+[']+COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell( 13, 2 ) > 1
         aadd(aSrc,spt+'LANDSCAPE'+COMMA )
      ENDIF

      IF Form_2.Grid_3.Cell(  14, 2 )
         aadd(aSrc,spt+'NODATETIMESTAMP'+COMMA)
      ENDIF

      IF Ton
         aadd(aSrc,'END REPORT')
      ELSE
         aadd(aSrc,'')
      ENDIF

      WriteFile(cSaveFile,aSrc)

      MessageBoxTimeout ('File was created...', '', MB_OK, 1000 )

   ENDCASE

   RETURN
   /*
   */

PROCEDURE rReport( cFile,nF )   // Import the File Report

   LOCAL Hf:= hb_ATokens( MemoRead( cFile ), CRLF ), cObj, uVal, cTmp, nfl
   LOCAL aTrue :={".T.","T","TRUE","Y","S","1"}, aGrpby := {"NONE","EVERY PAGE"}

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

   FOR EACH cObj in hf
      cObj := alltrim(REMRIGHT(cObj,';'))
      uVal := alltrim(substr(cObj ,rAt(" ",cObj) ) )

      DO CASE
      CASE "TITLE" $ cObj
         cTmp := alltrim(substr(ltrim(cobj),6))
         cTmp := ReplLeft(cTmp," ","'")
         cTmp := alltrim(ReplRight(cTmp," ","'"))

         IF "|" $ uVal
            Form_2.title1.value := substr(cTmp,1,at("|",cTmp)-1)
            Form_2.title2.value := substr(cTmp,at("|",cTmp)+1,len(cTmp)-1)
         ELSE
            Form_2.title1.value := cTmp
            Form_2.title2.value := ""
         ENDIF

      CASE "HEADERS" $ cObj
         cTmp:= SUBSTR(cObj,at("{",cObj) )
         uVal := at("}",cTmp )
         cTmp:= &(SUBSTR(cTmp,1,uVal ) )
         IF len( ctmp ) > nFl
            msgstop("Error: Unproper Report","Forced Exit in Headers")
            EXIT
         ENDIF
         aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 1, y+1 ):= x })
         cTmp:= SUBSTR(cObj,rat("{",cObj) )
         uVal := rat("}",cTmp )
         cTmp:= &(SUBSTR(cTmp,1,uVal ) )
         aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 2, y+1 ):= x })

      CASE "FIELDS" $ cObj
         cTmp:= &(SUBSTR(REMRIGHT( cObj ,';'),at("{",cObj) ))
         IF len( ctmp ) > nFl
            msgstop("Error: Unproper Report","Forced Exit in Fields")
            EXIT
         ENDIF
         aeval(cTmp, {|x,y|Form_2.Grid_2.HEADER(y+1 ):= x })

      CASE "WIDTHS" $ cObj
         cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
         IF len( ctmp ) > nFl
            msgstop("Error: Unproper Report","Forced Exit in Widths")
            EXIT
         ENDIF
         aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 3, y+1 ):= x })

      CASE "TOTALS" $ cObj
         cTmp:= &(uVal)
         IF len( ctmp ) > nFl
            msgstop("Error: Unproper Report","Forced Exit in Totals")
            EXIT
         ENDIF
         aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 4, y+1 ):= x })

      CASE "NFORMATS" $ cObj
         cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
         IF len( ctmp ) > nFl
            msgstop("Error: Unproper Report","Forced Exit in Nformats")
            EXIT
         ENDIF
         aeval(cTmp, {|x,y|Form_2.Grid_2.Cell( 5, y+1 ):= x })

      CASE "WORKAREA" $ cObj  //unused in this case
         // wArea := uval

      CASE "LPP" $ cObj
         Form_2.Grid_3.Cell( 3, 2 ):= val(uval)

      CASE "CPL" $ cObj
         Form_2.Grid_3.Cell( 4, 2 ):= val(uval)

      CASE "LMARGIN" $ cObj
         Form_2.Grid_3.Cell( 5, 2 ):= val(uval)

      CASE "TMARGIN" $ cObj
         Form_2.Grid_3.Cell( 6, 2 ):= val(uval)

      CASE "PAPERSIZE" $ cObj
         Form_2.Grid_3.Cell( 7, 2 ):= ascan(apapeles,uval)

      CASE "PREVIEW" $ cObj
         Form_2.Grid_3.Cell( 9, 2 ):= IF (upper(uVal)="PREVIEW",.T.,ascan(aTrue,uVal) > 0)

      CASE "SELECT" $ cObj
         Form_2.Grid_3.Cell( 10, 2 ):= IF (upper(uVal)="SELECT",.T.,ascan(aTrue,uVal) > 0)

      CASE "IMAGE" $ cObj
         cTmp:= &(SUBSTR(cObj,at("{",cObj) ))
         aeval(cTmp, {|x,y|Form_2.Grid_3.Cell(1,y+1):= x })

      CASE "MULTIPLE" $ cObj
         Form_2.Grid_3.Cell( 2, 2 ):= IF (upper(uVal)="MULTIPLE",.T.,ascan(aTrue,uVal) > 0)

      CASE "DOSMODE" $ cObj
         Form_2.Grid_3.Cell( 8, 2 ):= IF (upper(uVal)="DOSMODE",.T.,ascan(aTrue,uVal) > 0)

      CASE "LANDSCAPE" $ cObj
         Form_2.Grid_3.Cell( 13, 2 ):= IF (upper(uVal)="LANDSCAPE",2,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

      CASE "PORTRAIT" $ cObj
         Form_2.Grid_3.Cell( 13, 2 ):= IF (upper(uVal)="PORTRAIT",1,IF(ascan(aTrue,UPPER(uVal))>0,1,2) )

      CASE "NODATETIMESTAMP" $ cObj
         Form_2.Grid_3.Cell( 14, 2 ):= IF (upper(uVal)="NODATETIMESTAMP",.T.,ascan(aTrue,uVal) > 0)

      CASE "GROUPED" $ cObj
         cTmp := upper(REMLEFT(REMRIGHT(SUBSTR(cObj,at("BY",cObj)+3),"'"),"'"))
         Form_2.Grid_3.Cell(11, 2 ):= ascan(aGrpby,ctmp)

      CASE "HEADRGRP" $ cObj
         Form_2.Grid_3.Cell(12, 2 ):= REMLEFT(REMRIGHT(UVAL,"'"),"'")

      ENDCASE
   NEXT
   */

   RETURN
   /*
   */

PROCEDURE MOVE_Col (action)

   LOCAL aux,nCol_Disp, cCnt, aCv := Array(5),cv , aVt := Array(5),aHo, aHd
   LOCAL NoCln := 1

   aux := get_col()
   IF aux [1] > 0
      nCol_Disp := aux [1]
      cCnt := aux[2]
   ELSE

      RETURN
   ENDIF

   IF action = 1
      nCol_Disp := nCol_Disp - noCln  // Move column: LEFT
   ELSE             // = 2
      nCol_Disp := nCol_Disp + Nocln  // Move column: RIGTH
   ENDIF

   IF Form_2.Grid_2.ColumnWidth(nCol_Disp) = 0    // Emulate Column deletion
      NoCln := 2
      IF action = 1
         nCol_Disp --  // Move column: LEFT
      ELSE             // = 2
         nCol_Disp ++  // Move column: RIGTH
      ENDIF
   ENDIF
   */
   IF nCol_Disp >= 2 .AND. nCol_Disp <= cCnt
      // Move Header
      aho := Form_2.Grid_2.HEADER(nCol_disp)                                   // Colum destination
      aHd := Form_2.Grid_2.HEADER( nCol_disp+ IF(action=1,NoCln,-NoCln))       // Column to move

      Form_2.Grid_2.HEADER(nCol_disp):= aHd
      Form_2.Grid_2.HEADER( nCol_disp+ IF(action=1,NoCln,-NoCln)):= aHo

      // Move Columns
      FOR EACH cv in aCv
         aCv[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp )
         aVt[cv:__enumIndex()]:=Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ IF(action=1,NoCln,-NoCln))
         Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp ):= aVt[cv:__enumIndex()]
         Form_2.Grid_2.Cell( cv:__enumIndex(), nCol_disp+ IF(action=1,NoCln,-NoCln) ) := aCv[cv:__enumIndex()]
      NEXT
      */
      Form_2.Grid_2.setfocus
      Form_2.Grid_2.VAlue := {1,nCol_Disp }

   ENDIF

   Form_2.Grid_2.Refresh

   RETURN
   /*
   */

FUNCTION GRID_GetColumnDisplayPos ( cControlName, cParentForm, nColIndex )

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

FUNCTION GRID_ColumnCount ( cControlName, cParentForm )

   IF ValType ( cParentForm ) == "U"
      cParentForm := ThisWindow.Name
   ENDIF

   RETURN LISTVIEW_GETCOLUMNCOUNT ( GetControlHandle ( cControlName, cParentForm ) )
   /*
   */

PROCEDURE DELETE_Col ()

   LOCAL Tval := get_col()

   // nCol := tVal[1]
   // TotalColumns := tVal[2]
   IF tVal[1] > 0
      IF MsgYesNo("Are you sure ?","Deleting Column "+Form_2.Grid_2.HEADER( tVal[1] ) )
         // It is not a real deletion but it only hides the affected column
         // Following zero-width columns will be discarded by the processing
         Form_2.Grid_2.ColumnWidth(tVal[1]):= 0
         // Reposition the focus on grid
         IF tVal[1] < tVAl[2]
            _pushKey( VK_RIGHT )
         ELSE
            _pushKey( VK_LEFT )
         ENDIF
      ENDIF
   ENDIF

   RETURN
   /*
   */

FUNCTION Get_Col ()

   LOCAL aux, nCol_Disp, cCnt, Grid_col

   IF Form_2.Grid_2.Itemcount = 0

      RETURN {0,0}
   ENDIF

   aux      := Form_2.Grid_2.Value

   Grid_col := aux[2]
   cCnt     := GRID_ColumnCount ("Grid_2","Form_2")

   IF Grid_col < 2 .OR. Grid_col > cCnt
      msgstop("Please select a valid column!")

      RETURN {0,0}
   ENDIF

   nCol_Disp := GRID_GetColumnDisplayPos ("Grid_2", "Form_2", Grid_Col)

   RETURN {nCol_disp,cCnt}
   /*
   */

FUNCTION WrExport (cSavefile,aheaders1,aheaders2,aFormats,a,awidths, atot ,inde_on)

   LOCAL asrc := {}, cTmp , _dummy, cNF, nCol := 80, tFld, nCip := 0
   LOCAL ntotalchar ,aFsize := {80,96,120,140,160}, anFsize := {12,10,8,7,6}
   LOCAL nlmargin := Form_2.Grid_3.Cell( 5, 2 ) , ntoprow := Form_2.Grid_3.Cell( 6, 2 )
   LOCAL Mxrow, Hbprn, StrTot := '{', uTot := ascan(aTot,.T. ) > 0
   LOCAL eTot   := {},ISEVERYPAGE := (Form_2.Grid_3.Cell( 11, 2 )=2 )
   LOCAL WFsize ,isGroup := (Form_2.Grid_3.Cell( 11, 2 )> 2 ), eSH, sSplash
   LOCAL cLang := hb_userlang()

   DEFAULT inde_on to "NONE"

   DO CASE

   CASE "it" $ cLang
      sSplash := 'Attendere......... Creazione stampe!' //ITALIAN

   CASE "fr" $ cLang
      sSplash := "S’il vous plaît patienter...... Création d’impressions !" //FRENCH

   CASE "es" $ cLang
      sSplash := '... Por favor espere ...    Trabajo en proceso' //SPANISH

   CASE "pt" $ cLang
      sSplash := '... Aguarde ......... Criando impressões!'   //PORTUGUESE

   CASE "de" $ cLang
      sSplash := '... Warten Sie bitte...    Arbeiten Sie im Gange' //GERMAN

   CASE "el" $ cLang
      sSplash := "?e??µ??ete ......... ??µ??????a e?t?p?se??!" // GREEK

   CASE "ru" $ cLang
      sSplash := 'Ïîäîæäèòå ......... Èäåò îáðàáîòêà!' // RUSSIAN

   CASE "uk" $ cLang
      sSplash := "Çà÷åêàéòå ......... Âèêîíóþ îáðîáêó!"// UKRAINIAN

   CASE "pl" $ cLang
      sSplash := "Poczekaj ......... Tworzenie wydruków!" // POLISH

   CASE "sl" $ cLang
      sSplash := "Pocakaj ......... Ustvarjanje tiskalnikov!" // SLOVENIAN

   CASE "sr" $ cLang
      sSplash := 'Simama ......... Kuunda Prints!'//C SERBIAN

   CASE "bg" $ cLang
      sSplash := "????????? ......... ????????? ?? ??????????!" // BULGARIAN

   CASE "hu" $ cLang
      sSplash := "Várj ... Nyomtatás létrehozása!" // HUNGARIAN

   CASE "cs" $ cLang
      sSplash := "Cekaj ... ... Stvaranje ispisa!" // CZECH

   CASE "sk" $ cLang
      sSplash :=  "Pockajte ......... Vytváranie výtlackov!" //SLOVAK

   CASE "nl" $ cLang
      sSplash := 'Wacht ......... Prints maken!' // DUTCH

   CASE "fi" $ cLang
      sSplash := "Odota ......... Tulosten luominen!" // FINNISH

   CASE "sv" $ cLang
      sSplash := "Vänta ......... Skapa bilder!" // SWEDISH

   OTHERWISE
      sSplash :=  '... Please wait ...    Work in Progress'

   ENDCASE

   aadd(aSrc,'!HBPRINT')
   aadd(aSrc,'# REPORT.MOD This Line Will be ignored!' )
   aadd(aSrc,'# case ncpl= 80    nfsize:=12 ' )
   aadd(aSrc,'# case ncpl= 96    nfsize:=10 ' )
   aadd(aSrc,'# case ncpl= 120   nfsize:=8  ' )
   aadd(aSrc,'# case ncpl= 140   nfsize:=7  ' )
   aadd(aSrc,'# case ncpl= 160   nfsize:=6  ' )
   aadd(aSrc,'')

   cTmp := ' ['
   aeval(aheaders1,{|x,y| cTmp += repl('-',awidths[y])+' ',_dummy := x } )

   ntotalchar := len(cTmp)                                     // Retrieve MaxLenght
   aeval(aFsize,{|x| IF( x <= ntotalchar, nCol := x , ) } )    // SET automatic CPL

   // Calculate MaxRow
   Hbprn := Hbprinter():New
   IF Form_2.Grid_3.Cell( 10, 2 )
      hbprn:selectprinter("" ,Form_2.Grid_3.Cell(  9, 2 )) // Select printer
   ELSE
      hbprn:selectprinter( ,Form_2.Grid_3.Cell(  9, 2 ))   // Printer default
   ENDIF
   IF Hbprn:Error != 0
      MessageBoxTimeout ("An error occurred in the printer's management", 'Export failed', MB_OK, 1000 )

      RETURN NIL
   ENDIF
   hbprn:setdevmode( 0x00000002 ,Form_2.Grid_3.Cell( 7, 2 ) ) // Set Papaersize
   hbprn:definefont("_xT_","Courier New",AnFsize[ascan(aFsize,ncol)],,,.F.,.F.,.F.,.F.) //Need a font
   Hbprn:Setpage( Form_2.Grid_3.Cell( 13, 2 ),Form_2.Grid_3.Cell( 7, 2 ),"_xT_"  )  // Set Orientation
   Mxrow := Hbprn:maxrow
   Hbprn:End()

   WFsize := NTrim(anFsize[ascan(aFsize,nCol)])

   // Declare
   aadd(aSrc,'[DECLARE]'+NTrim( nCol )+ IF(Form_2.Grid_3.Cell( 10, 2 ),'/SELE','') )
   aadd(aSrc,'SET PAPERSIZE '+apapeles[Form_2.Grid_3.Cell( 7, 2 )] )
   aadd(aSrc,'SET UNITS ROWCOL')
   // only  for unit mm or pdf ?
   //  aadd(aSrc,'SET PRINT MARGINS TOP '+ NTrim( ntoprow) +' LEFT '+NTrim( nlmargin ) )
   aadd(aSrc,'SET ORIENTATION '+IF(Form_2.Grid_3.Cell( 13, 2 ) > 1,'LANDSCAPE','PORTRAIT') )
   aadd(aSrc,'SET PREVIEW '+IF (Form_2.Grid_3.Cell(  9, 2 ),'ON','OFF') )
   aadd(aSrc,'SET CHARSET ANSI_CHARSET')
   aadd(aSrc,'SET SPLASH TO '+sSplash)
   aadd(aSrc,'DEFINE FONT Fb  NAME [COURIER NEW] SIZE '+WFsize+' BOLD' )
   aadd(aSrc,'DEFINE FONT Ft  NAME [COURIER NEW] SIZE '+NTrim(anFsize[ascan(aFsize,nCol)]+2 )+' BOLD' )
   aadd(aSrc,'Var _ML '+NTrim(nlmargin)+' N' )

   IF uTot           // Need a separate counter
      IF isgroup
         aeval(aTot,{|x,y| IF(x ,StrTot += a[y]+',', )} )
      ELSE
         aeval(aTot,{|x| IF(x ,StrTot += '0,', )} )
      ENDIF
      StrTot := remRight (StrTot,',')+'}'
      IF !isgroup
         aadd(aSrc,'Var aC '+StrTot +' A')
      ENDIF
   ENDIF
   aadd(aSrc,'')

   IF isgroup
      tFld := DBFIELDINFO(DBS_TYPE, FieldPos( Inde_On ))

      SWITCH tFld

      CASE "C"  // Char
         eSH := 'Ltrim('+inde_on+')'
         EXIT

      CASE "N"  // Number
         eSH := 'TRANSFORM ('+Inde_On+',"'+ aformats[ascan(a,inde_on)] +'" )'
         EXIT

      CASE "M"  // Memo
         Msgstop("You can not group on MEMO Fields !", "Error" )

         RETURN NIL

      CASE "D"  // Date
         eSh := 'TRANSFORM ('+Inde_On+',"@D")'
         EXIT

      CASE "L"  // Logical
         eSH := 'TRANSFORM ('+Inde_On+',"L")'
         EXIT

      ENDSWITCH

      aadd(aSrc,'// (GroupField, Head string, Column string, count total for, where the gtotal, total string, total column, paper_feed_every_group')
      aadd(aSrc,'// total for = Fieldname or array with multiple fieldname')
      aadd(aSrc,'// Example: Example: GROUP first {||rtrim(first)+space(1)+"***"} AUTO {CODE,INCOMING} AUTO [** Subtotal **] 6 .T.')
      aadd(aSrc,'')

      IF uTot  // need a counter
         aadd(aSrc,'SET TOTALSTRING space(_ML)+[*** Total ***]')
         aadd(aSrc,'SET INLINESBT .F.')
         aadd(aSrc,'SET INLINETOT .F.')
         aadd(aSrc,'SET SUBTOTALS .T.')
         aadd(aSrc,'SET GROUPBOLD .T.')
         aadd(aSrc,'// SET SHOWGHEAD .T.')
         aadd(aSrc,'// SET GTGROUPCOLOR BLACK')
         aadd(aSrc,'// SET HGROUPCOLOR RED')
         aadd(aSrc,'')
         aadd(aSrc,'GROUP '+ Inde_On +' {||([**  ** ]+'+ eSH +')} (_ML) '+StrTot+' AUTO  space(_ML)+[** Subtotal **] AUTO .F. ')
      ELSE    // No Count
         aadd(aSrc,'SET TOTALSTRING space(_ML)')
         aadd(aSrc,'SET INLINESBT .F.')
         aadd(aSrc,'SET INLINETOT .F.')
         aadd(aSrc,'SET SUBTOTALS .F.')
         aadd(aSrc,'SET GROUPBOLD .T.')
         aadd(aSrc,'// SET SHOWGHEAD .T.')
         aadd(aSrc,'// SET GTGROUPCOLOR BLACK')
         aadd(aSrc,'// SET HGROUPCOLOR RED')
         aadd(aSrc,'')
         aadd(aSrc,'GROUP '+ Inde_On +' {||([**  ** ]+'+ eSH +')} (_ML) {} AUTO [] AUTO .F. ')
      ENDIF

      aadd(aSrc,'')

   ENDIF
   // The Head definitions
   aadd(aSrc,'[HEAD]'+NTrim(9+ntoprow) )
   aadd(aSrc,'( nline +='+ NTrim(ntoprow)+' )' )
   aadd(aSrc,'nline,   (_ML)     SAY ['+_HMG_MESSAGE [9]+'] Font [COURIER NEW] SIZE '+WFsize)
   aadd(aSrc,'nline,   '+NTrim(ntotalchar/2)+'        SAY ['+ Form_2.Title1.value +'] Font Ft ALIGN CENTER')
   aadd(aSrc,'nline+1, '+NTrim(ntotalchar/2)+'        SAY ['+ Form_2.Title2.value +'] Font Ft ALIGN CENTER')
   IF Form_2.Grid_3.Cell( 14, 2 ) = .F.   // Print Date and Time
      aadd(aSrc,'nline,   ('+NTrim(len(cTmp)-10-nlmargin) +'+_ML) SAY date() Font [COURIER NEW] SIZE '+WFsize )
      aadd(aSrc,'nline+1, ('+NTrim(len(cTmp)-10-nlmargin) +'+_ML) SAY time() Font [COURIER NEW] SIZE '+WFsize )
   ENDIF
   aadd(aSrc,'nline,   (5+_ML)   SAY hb_ntos( npag ) Font [COURIER NEW] SIZE '+WFsize )

   aadd(aSrc,'nline+3, (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize )
   cTmp := ' ['
   aeval(aheaders1,{|x,y| cTmp += x+repl(' ',awidths[y]-len(x))+' '} )
   aadd(aSrc,'nline+4, (_ML) SAY '+cTmp+'] Font fb ')
   cTmp := ' ['
   aeval(aheaders2,{|x,y| cTmp += x+repl(' ',awidths[y]-len(x))+' '} )
   aadd(aSrc,'nline+5, (_ML) SAY '+cTmp+'] Font fb ')
   cTmp := ' ['
   aeval(aheaders1,{|x,y| cTmp += repl('-',awidths[y])+' ',_dummy := x } )
   aadd(aSrc,'nline+6, (_ML) SAY '+cTmp+'] Font [COURIER NEW] SIZE '+WFsize )

   IF !empty( Form_2.Grid_3.Cell( 1, 2 ) )
      IF !Form_2.Grid_3.Cell( 2, 2 )
         aadd(aSrc, 'IF ( npag = 1 )')
      ENDIF
      aadd(aSrc, '   @ '+NTrim(Form_2.Grid_3.Cell( 1, 3 ))+','+NTrim(Form_2.Grid_3.Cell( 1, 4 )+2) ;
         +' PICTURE '+ Form_2.Grid_3.Cell( 1, 2 )+' SIZE ' ;
         +NTrim(Form_2.Grid_3.Cell( 1, 5 )-Form_2.Grid_3.Cell( 1, 3 )-4 )+',';
         +NTrim(Form_2.Grid_3.Cell( 1, 6 )-Form_2.Grid_3.Cell( 1, 4 )-3 ) )
      IF !Form_2.Grid_3.Cell( 2, 2 )
         aadd(aSrc, 'EndIF')
      ENDIF

   ENDIF
   aadd(aSrc,'')

   // The Body Definitions
   // Add Adaptative Body Height     normal -12  with every and (!utot ,-2 ,-3 )
   aadd(aSrc,'[BODY]'+NTrim(max(Form_2.Grid_3.Cell( 3, 2 ),mxrow) -IF(ISEVERYPAGE,if(utot,15,14),12) ) )

   IF Utot .and. !isgroup
      FOR EACH cNf in aTot
         IF cNF
            nCip ++
            aadd(aSrc,'(aC['+NTrim(nCip)+'] += Field->'+A[cNf:__enumIndex()]+')')
         ENDIF
      NEXT
   ENDIF
   nCol := nLmargin
   FOR EACH cNf in a
      tFld := DBFIELDINFO(DBS_TYPE, FieldPos( cNf ))
      SWITCH tFld

      CASE "C"  // Char
         aadd(aSrc,'nline, '+NTrim( nCol )+' SAY (substr(field->'+cNf+',1,'+NTrim(int(awidths[cNf:__enumIndex()] ) )+') ) Font [COURIER NEW] SIZE '+WFsize )
         EXIT

      CASE "N"  // Number
         aadd(aSrc,'nline, '+NTrim( nCol )+' SAY TRANS(Field->'+cNf+',"'+aformats[cNf:__enumIndex()]+'") Font [COURIER NEW] SIZE '+WFsize )
         IF aTot[cNf:__enumIndex()]
            aadd (eTot,'   @ eline+1, '+NTrim( nCol )+' SAY IF(.T.,TRANS(ac[|],"'+aformats[cNf:__enumIndex()]+'"),[]) Font Fb ')
         ENDIF
         EXIT

      CASE "M"  // Memo
         aadd(aSrc,'nline, '+NTrim( nCol )+' MEMOSAY Field->'+cNf+' LEN '+NTrim(int(awidths[cNf:__enumIndex()] ) )+' Font [COURIER NEW] SIZE '+WFsize )
         EXIT

      CASE "D"  // Date
      CASE "L"  // Logical
         aadd(aSrc,'nline, '+NTrim( nCol )+' SAY field->'+cNf+' Font [COURIER NEW] SIZE '+WFsize )
         EXIT

      ENDSWITCH
      nCol += int(awidths[cNf:__enumIndex()] )+1
   NEXT
   aadd(aSrc,'')

   // The Feet definitions
   aadd(aSrc,'[FEET]2')
   IF uTot .and. !isGroup
      aadd(aSrc,'   @ Eline,(_ML) SAY IF(Last_pag, [*** Total ***],[])  Font FB')
      FOR EACH cNf in ETot
         CnF := STRTRAN(cNf,"|",NTrim(cNf:__enumIndex()) )
         IF ! ISEVERYPAGE
            CnF := STRTRAN(cNf,".T.","Last_Pag" )
         ENDIF
         aadd(aSrc,cNf)
      NEXT
   ENDIF
   aadd(aSrc,'[END]')

   writefile(cSavefile,aSrc)  // WriteFile is more fast than  StrFile

   MessageBoxTimeout ('File was created...', '', MB_OK, 1000 )

   RETURN NIL
   /*
   */

PROCEDURE Writefile(filename,arrayname)

   LOCAL f_handle

   * open file and position pointer at the end of file
   IF VALTYPE(filename) == "C"
      f_handle := FOPEN(filename,2)
      *- IF not joy opening file, create one
      IF Ferror() <> 0
         f_handle := Fcreate(filename,0)
      ENDIF
      FSEEK(f_handle,0,2)
   ELSE
      f_handle := filename
      FSEEK(f_handle,0,2)
   ENDIF

   IF VALTYPE(arrayname) == "A"
      * IF its an array, do a loop to write it out
      * msginfo(str(len(arrayname)),"FKF")
      aeval( Arrayname,{|x|FWRITE(f_handle,x+CRLF )} )
   ELSE
      * must be a character string - just write it
      FWRITE(f_handle,arrayname+CRLF )
      //msgbox(Arrayname,"Array")
   ENDIF

   * close the file
   IF VALTYPE(filename)=="C"
      Fclose(f_handle)
   ENDIF

   RETURN
   /*
   */

PROCEDURE Check_db_Index ( Arg1,Lvl )

   IF lvl > 2
      IF ! File ( cFilePath( GetExeFileName() )+'\'+Alias()+'.Cdx' )
         MsgExclamation("The function require an "+Alias()+".Cdx","File Missing: Aborting.")

         RETURN
      ENDIF
      ORDLISTADD(ALIAS())
      (alias())->(ORDSETFOCUS('I'+ arg1))
      (alias())->(dbgotop())

      RETURN
   ENDIF

   RETURN
   /*
   */
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
