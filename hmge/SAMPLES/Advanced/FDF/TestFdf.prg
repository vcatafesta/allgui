/*******************************************************************************
Filename        : TestFdf.prg

Created         : 27 October 2008 (10:14:56)
Created by      : Pierpaolo Martinello

Last Updated    : 18 April 2009 (10:43:52)
Updated by      : Pierpaolo

Comments      :
*******************************************************************************/
/*
Copyright 2007-2009 Pierpaolo Martinello <pier.martinello [at] alice.it>

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this software; see the file COPYING. If not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
(or visit the web site http://www.gnu.org/).

Parts of this project are based upon:

MINIGUI
Harbour MiniGUI: Free xBase Win32/GUI Development System
(c) 2002-2007 Roberto Lopez
Mail: harbourminigui@gmail.com

(c) 2007-2009 Pierpaolo Martinello <pier.martinello [at] alice.it>
.Prg donated to public domain
*/

/*
*/
#include 'hbclass.ch'
#include "minigui.ch"
#include "tsbrowse.ch"
#include 'inkey.ch'
#include 'fileio.ch'
#include 'Dbstruct.ch'

#ifndef __XHARBOUR__
#include "hbusrrdd.ch"
#xcommand TRY              => bError := errorBlock( {|oErr| break( oErr ) } ) ;;
   BEGIN SEQUENCE
   #xcommand CATCH [<!oErr!>] => errorBlock( bError ) ;;
   RECOVER [USING <oErr>] <-oErr-> ;;
      errorBlock( bError )
   #else
   #include "usrrdd.ch"
   #endif

   #translate Zaps(<x>) => Zapit(<x>)

   #define IDI_MAIN 1001
   #define VERSIONEFDF "%FDF-1.2"
   #define CRLF   CHR(13)+CHR(10)

   MEMVAR FDF
   MEMVAR oBrw1, aData_Source, Stampanti

FUNCTION Main()

   SET CENTURY ON
   SET DATE FRENCH
   PUBLIC FDF := FDF()
   PUBLIC oBrw1, aData_Source, Stampanti := Asort(Aprinters())

   FdF:NEWFdF()
   FdF:end()

   RETURN NIL
   /*
   */

CREATE CLASS FdF

   DATA aPdf             INIT {}
   DATA aEnAct           INIT {}
   DATA Action           INIT .F.
   DATA F_HANDLE         INIT 0 PROTECTED
   DATA Nomefile         INIT 'TestFDF.FDF'
   DATA PdfTemplate      INIT "Scheda.pdf"
   DATA DirPrg           INIT ''
   DATA cFileName        INIT ''
   DATA IniFile          INIT ''
   DATA DirTemplate      INIT ''
   DATA DirSpool         INIT ''
   DATA DirData          INIT ''
   DATA DataSource       INIT ''
   DATA aUndo            INIT {}
   DATA AcroPath         INIT ''
   DATA AcroPrinter      INIT ''
   DATA AcroPrPort       INIT ''  // Not used Yet

   METHOD NewFdF()  CONSTRUCTOR
   METHOD SaveData()
   METHOD ClearDefs()
   METHOD LoadData()
   METHOD FdFHEAD()
   METHOD AddFLD()
   METHOD FdFFeet()
   METHOD ListIniField()
   METHOD SaveIniField()
   METHOD ACompare()
   METHOD SPLIT( elstr, separator )
   METHOD SetIni()
   METHOD SetForm()
   METHOD GetForm()
   METHOD SetFLD(arg1)
   METHOD Crea_file(Filename)
   METHOD WriteFdF(Filename,arrayname,action)
   METHOD Writefile(Filename,arrayname)
   METHOD CloseAcrobat()
   METHOD END()

ENDCLASS

/*
*/

METHOD NewFdF() CLASS FdF

   SET NAVIGATION EXTENDED
   ::SETFLD(.T.)
   ::DirPrg      := DirPrg()
   IF ::SetIni()
      ::DirTemplate := ::DirPrg //+"Template\"
      ::DirSpool    := ::DirPrg //+"Spool\"
      ::DirData     := ::DirPrg //+"Data\"
   ENDIF

   LOAD WINDOW TPDF
   CENTER WINDOW TPDF
   ::SETFORM()
   TPDF.TextBox_1.SETFOCUS
   TPDF.ACTIVATE

   RETURN NIL
   /*
   */

METHOD SetForm() //CLASS FdF

   tpdf.TextBox_1.value := ::DirTemplate+::PdfTemplate
   tpdf.TextBox_2.value := ::DirData+::Datasource
   tpdf.TextBox_3.value := ::DirSpool
   tpdf.GetBox_4.value     := ::AcroPath
   tpdf.ComboBoxEX_1.value := Ch_Pr( )

   RETURN NIL
   /*
   */

METHOD GetForm() CLASS FdF

   ::PdfTemplate   := MyGetFileName(tpdf.TextBox_1.value)
   ::Datasource    := MyGetFileName(tpdf.TextBox_2.value)
   ::DirSpool      := tpdf.TextBox_3.value
   ::NomeFile      := Proper(substr(::PdfTemplate,1,at(".",::PdfTemplate)))+"FdF"
   ::AcroPath      := tpdf.GetBox_4.value
   ::AcroPrinter   := Stampanti[GetProperty ( "TPDF", "ComboBoxEX_1", "Value" )]

   RETURN NIL
   /*
   */

METHOD SetIni() CLASS FdF

   LOCAL rtv := .T.

   ::cFilename := cFileNoExt( GetExeFileName() )
   ::IniFile   := ::DirPrg + Lower(::cFileName) + ".Ini"
   IF File(::IniFile)
      rtv := .F.
      IF msgYesno("Load a Previous Fields Definition ?",::NOMEFILE)
         ::LoadData()
      ELSE
         ::CLEARDEFS()
         ::PdfTemplate := ''
         ::Datasource  := ''
         ::Dirspool    := ::DirPrg
      ENDIF
   ELSE
      ::SaveData()
   ENDIF

   RETURN rtv
   /*
   */

METHOD Crea_file(Filename,chk) CLASS FdF

   LOCAL pdc

   DEFAULT Filename to ::DirSpool+::Nomefile, chk to .f.
   pdc := len(Filename)+34
   IF chk
      IF File(Filename)
         IF msgYesNo("The file "+ Filename+" already exist!"+CRLF;
               +padc("Do you want overwrite It?",pdc),"Question...")
            IF Ferase(::DirSpool+::Nomefile) < 0
               msgstop("The file "+ ::Nomefile +" can not be erased!","Error")

               RETURN NIL
            ENDIF
         ELSE

            RETURN NIL
         ENDIF
      ENDIF
   ENDIF
   ::aPdf :={}
   ::FdFHEAD(Filename)
   ::SetFld()
   ::FdFFeet(Filename)

   RETURN NIL
   /*
   */

METHOD FdFHEAD(Filename) CLASS FdF

   //  FdF HEAD
   LOCAL pdst:="/"+strtran(::DirTemplate+::PdfTemplate,":","")

   DEFAULT Filename to ::DirSpool+::NomeFile
   pdst := strtran(pdst,"\","/")
   ::WriteFdF ("Start",Filename,.t.) //crea il File
   ::WriteFdF (VERSIONEFDF)
   ::WriteFdF ("1 0 obj")
   ::WriteFdF ("<</FDF" )
   ::WriteFdF ("<</F ("+pdst+")/Fields[" )

   RETURN NIL
   /*
   */

METHOD SetFld(arg1) CLASS FdF

   DEFAULT arg1 to .f.
   IF arg1
      ::addFld("TXTINDIRIZZO",["TxtIndirizzo"] )
      ::AddFld("TXTCITTA",["TxtCitta"] )
      ::AddFld("TXTCOGNOME",["TxtCognome"] )
      ::AddFld("TXTNOME",["TxtNome"] )
      ::AddFld("TXTTELEFONO",["TxtTelefono"] )
   ELSE
      IF file(::DirData+::DataSource)
         sele 1
         USE &(::DirData+::DataSource) shared alias USEIT
         aEval( ::aEnact, {|x,y| if(! empty(trim(x[2])),;
            aadd(::aPdf,"<</T("+ alltrim(x[1]) +")/V("+ (macrocompile(x[2])) +")>>" );
            ,'') } )
         dbcloseall()
      ENDIF
   ENDIF

   RETURN NIL
   /*
   */

METHOD FdFFeeT(Filename) CLASS FdF

   //  FdF FEET
   DEFAULT Filename to ::DirSpool+::NomeFile
   ::WriteFdF ("]>>>>")
   ::WriteFdF ("endobj")
   ::WriteFdF ("trailer")
   ::WriteFdF ("<</Root 1 0 R>>")
   //  CLOSE FdF
   ::WriteFdF ("%%EOF")  // last row
   ::WriteFdF ("END",Filename,.t.) //close file

   RETURN NIL
   /*
   */

METHOD AddFLD(Fld, Value) CLASS FdF

   aadd(::aPdf,"<</T("+ Fld +")/V("+ Value +")>>" )
   aadd(::aEnAct ,{ Fld , Value })

   RETURN NIL
   /*
   */

METHOD WriteFdF(Arrayname, Filename, Act ) CLASS FdF

   DEFAULT Act to .f., Filename to ''

   IF !EMPTY(Filename) .OR. Act
      FdF:Writefile(Filename,::aPdf)
      FdF:aPdf := {}
   ELSE
      aadd(::aPdf,Arrayname)
   ENDIF

   RETURN NIL
   /*
   */

METHOD Writefile(filename,arrayname) CLASS FdF

   //private f_handle
   //filename := cFilePath( GetModuleFileName( GetInstance() ) )+filename
   * open file and position pointer at the end of file
   IF VALTYPE(filename)=="C"
      FdF:f_handle := FOPEN(filename,2)
      *- if not joy opening file, create one
      IF Ferror() <> 0
         FdF:f_handle := Fcreate(filename,0)
      ENDIF
      FSEEK(FdF:f_handle,0,2)
   ELSE
      FdF:f_handle := filename
      FSEEK(FdF:f_handle,0,2)
   ENDIF

   IF VALTYPE(arrayname) == "A"
      * if its an array, do a loop to write it out
      * msginfo(str(len(arrayname)),"FKF")
      aeval(Arrayname,{|x|FWRITE(FdF:f_handle,x+CRLF )})
   ELSE
      * must be a character string - just write it
      FWRITE(FdF:f_handle,arrayname+CRLF )
      //msgbox(Arrayname,"Array")
   ENDIF

   * close the file
   IF VALTYPE(filename)=="C"
      Fclose(FdF:f_handle)
   ENDIF

   RETURN NIL
   /*
   */

METHOD CloseAcrobat() CLASS FdF

   LOCAL Hwnl := MAX( FindWindow(fdf:Pdftemplate+" - Adobe Reader"),FindWindow("Adobe Reader"))

   IF Hwnl > 0
      SendMessage(hWnl,WM_CLOSE)
   ENDIF

   RETURN NIL
   /*
   */

METHOD END() CLASS FdF

   ::CloseAcrobat()
   Tpdf.release

   RETURN self
   /*
   */

PROCEDURE ViewFdf(preview,Filename)

   LOCAL Filex := GetInstallAcrobat() , param, Hwnl

   DEFAULT preview to .F., Filename to Fdf:Nomefile
   param := '/t "'+fdf:Dirspool+MyGetFileName(Filename)+'" "'+Fdf:AcroPrinter+'"'
   Filex := Substr(Filex,2,at(".exe",Filex)+2)
   IF !file (fdf:Dirspool+MyGetFileName(Filename))
      msgStop("Please Make a FdF First.")

      RETURN
   ENDIF
   IF Preview
      EXECUTE FILE filex PARAMETERS fdf:Dirspool+MyGetFileName(Filename)
   ELSE
      EXECUTE FILE filex PARAMETERS param HIDE
   ENDIF

   RETURN
   /*
   */

STATIC FUNCTION DirPrg()

   RETURN cFilePath(GetModuleFileName(GetInstance()))
   /*
   */

STATIC FUNCTION cFilePath( cPathMask )

   LOCAL n := RAt( "\", cPathMask )

   RETURN If( n > 0, Upper( Left( cPathMask, n ) ), Left( cPathMask, 2 ) + "\" )
   /*
   */

METHOD ClearDefs() CLASS FdF

   LOCAL aRt :=_GetSection( "Fields",::IniFile )

   BEGIN INI FILE ::IniFile
      aEval(aRt ,{ |x,y| _DelIniEntry( "Fields", x[1]) } )
   END INI

   RETURN NIL
   /*
   */

METHOD SaveData() CLASS FdF

   BEGIN INI FILE ::IniFile
      // Main Setting
      SET SECTION "Folder" ENTRY "Root      " to ::DirPrg
      SET SECTION "Folder" ENTRY "Template  " to ::DirTemplate
      SET SECTION "Folder" ENTRY "Target    " to ::DirSpool
      SET SECTION "Folder" ENTRY "DataSource" to ::DirData
      SET SECTION "Folder" ENTRY "AcroPath  "  to ::DirData
      SET SECTION "Folder" ENTRY "AcroPath"    to ::AcroPath
      SET SECTION "Folder" ENTRY "AcroPrinter" to ::AcroPrinter

      SET SECTION "Files"  ENTRY "Template  " to ::PdfTemplate
      SET SECTION "Files"  ENTRY "Target    " to ::NomeFile
      SET SECTION "Files"  ENTRY "DataSource" to ::DataSource

   END INI
   FdF:SaveIniField()

   RETURN NIL
   /*
   */

METHOD SaveIniField() CLASS FdF

   LOCAL tmp:= {}

   BEGIN INI FILE ::IniFile
      // Fields definitions
      SET SECTION "Fields" ENTRY "_Ghost_" to ""
      DEL SECTION "Fields" ENTRY "_Ghost_"
      tmp := FdF:aCompare()
      aeval(tmp, {|x| _DelIniEntry( "Fields", x ) } )
      aeval(::aEnAct,{ |x,y| _SetIni( "Fields", alltrim( x[1] ), alltrim( x[2] ) ) } )
   END INI

   RETURN NIL
   /*
   */

METHOD ACompare() CLASS FdF

   LOCAL tmp:={},tmp2:={},ncol:= 2

   FOR nx = 1 to len (::aUndo)
      IF ascan(::aEnact,{|x,y| x[1]==::aUndo[nx,1]} ) = 0
         aadd(tmp,::aUndo[nx,1])
         aadd(tmp,::aUndo[nx,1]+"="+ ::aUndo[nx,2])
      ENDIF
   NEXT

   RETURN tmp
   /*
   */

METHOD LoadData() CLASS FdF

   BEGIN INI FILE ::IniFile

      GET ::DirPrg      SECTION "Folder" ENTRY "Root      "
      GET ::DirTemplate SECTION "Folder" ENTRY "Template  "
      GET ::DirSpool    SECTION "Folder" ENTRY "Target    "
      GET ::DirData     SECTION "Folder" ENTRY "DataSource"
      GET ::AcroPath    SECTION "Folder" ENTRY "AcroPath"
      GET ::AcroPrinter SECTION "Folder" ENTRY "AcroPrinter"

      GET ::PdfTemplate SECTION "Files"  ENTRY "Template  "
      GET ::NomeFile    SECTION "Files"  ENTRY "Target    "
      GET ::DataSource  SECTION "Files"  ENTRY "DataSource"

   END INI
   FdF:aEnact := FdF:ListIniField()
   FdF:aUndo  := aclone(FdF:aEnact)

   RETURN NIL
   /*
   */

METHOD ListIniField() CLASS FdF

   LOCAL aFld := {}, cLine:= '', sw:=.f., nx := 0, aRtv := {}

   IF FILE( FdF:IniFile )

      oFile := TFileRead():New( FdF:IniFile )

      oFile:Open()

      IF oFile:Error()

         MsgStop( oFile:ErrorMsg( "FileRead: " ), "Error" )
      ELSE
         WHILE oFile:MoreToRead()
            cLine := oFile:ReadLine()
            IF SUBSTR(cLine, 1, 1) # "$" .AND. !EMPTY(SUBSTR(cLine, 1, 1)) ;
                  .AND. AT(CHR(26), cLine) = 0
               IF upper(rtrim(cline))="["
                  SW := upper(rtrim(cline))="[FIELDS]"
               ENDIF
            ENDIF
            IF SW .and. upper(rtrim(cline))# "["
               AADD(aFld, cLine)
            ENDIF
         END WHILE

         oFile:Close()
      ENDIF
   ENDIF

   IF len(afld) > 0
      FOR nx = 1 to len(afld)
         Mylist := FdF:split(afld[nx], "=" )
         IF len(Mylist) = 2
            aadd(aRtv,{ AddSpace(UPPER( Mylist[1] ) ,18), AddSpace( Mylist[2],120)})
         ENDIF
      NEXT
   ELSE
      aadd(aRtv,{ Space(18), Space(120)})
   ENDIF

   RETURN aRtv
   /*
   */

FUNCTION Ch_Pr( ) //CLASS FdF

   LOCAL P_report := GetDefaultPrinter(), Pos := ascan(m->Stampanti,P_report)

   if!empty(FDF:AcroPrinter)
   Pos:= ascan(Stampanti,FDF:AcroPrinter)
ENDIF

RETURN Pos
/*
*/

METHOD SPLIT( elstr, separator ) CLASS FdF

   LOCAL aElems := {}, Elem, _sep := IIF( ! EMPTY( separator ), separator, " " )
   LOCAL nSepPos := 0

   IF !EMPTY(elstr)
      elstr := alltrim( elstr )
      DO WHILE AT( _sep, elstr ) > 0
         nSepPos := AT( _sep, elstr )
         IF nSepPos > 0
            Elem  := LEFT( elstr, nSepPos - 1 )
            elstr := SUBSTR( elstr, LEN( Elem ) + 2 )
            AADD( aElems, Elem )
         ENDIF
      ENDDO
      AADD( aElems, elstr )
   ENDIF

   RETURN ( aElems )
   /*
   */

STATIC FUNCTION IniEdit()

   LOAD WINDOW INIEDIT
   EDITA()
   CENTER WINDOW INIEDIT
   INIEDIT.ACTIVATE

   RETURN NIL
   /*
   */

STATIC FUNCTION MyGetFileName(rsFileName)

   LOCAL i := 0,_FileName:=""

   FOR i = Len(rsFileName) TO 1 STEP -1
      IF SUBSTR(rsFileName, i, 1) $ "\/"
         EXIT
      END IF
   NEXT
   _FileName := SUBSTR(rsFileName, i + 1)

   RETURN _FileName
   /*
   */
   STATIC Proc SeleTemplate()
      LOCAL O_Spool,cpos

      IF empty(trim(TPDF.TextBox_2.Value))
         cpos:=DirPrg()
      ELSE
         cpos:=cFilePath( TPDF.TextBox_2.Value )
      ENDIF
      o_spool := Getfile ( { {'Pdf files ','*.Pdf'} } , 'Select a Template file for merging',cpos )
      IF len(O_Spool) > 0
         Fdf:DirTemplate      := cFilepath(O_Spool)
         TPDF.Textbox_1.Value := O_Spool
         FDF:PdfTemplate      := MyGetFileName(O_Spool)
      ELSE
         IF empty(TPDF.Textbox_1.Value)
            msgExclamation( "Invalid entry!!!" )
         ENDIF
      ENDIF

      RETURN
      /*
      */
      STATIC Proc SeleData()
         LOCAL OpenDb,dbName,cpos

         IF empty(trim(TPDF.TextBox_2.Value))
            cpos:=DirPrg()
         ELSE
            cpos:=cFilePath( TPDF.TextBox_2.Value )
         ENDIF
         OpenDB := Getfile ( { {'Dbf files ','*.DBF'} } ,'Select a DataSource for merging',cpos )
         IF len(OpenDb) > 0
            FDF:DirData := cFilepath(OpenDb)
            dbName := lower(MyGetFileName(OpenDb))
            IF upper(dbName) # "DEF2PDF.DBF" .and. upper(dbName) # "USEIT.DBF"
               TPDF.TextBox_2.Value := Opendb
               FdF:Datasource := Proper(dbName)
            ELSE
               msgstop( "This File is used by this application!";
                  + CRLF +"       Please select an other DBF!" )
            ENDIF
         ENDIF

         RETURN
         /*
         */
         STATIC Proc AcroPath()
            LOCAL OpenPh,Location := GetInstallAcrobat()

            Location := Substr(Location,2,at(".exe",Location)+2)
            OpenPh := Getfile ( { {'Acrobat exe file','Acro*.exe'} } ;
               ,'Select a Acrobat executable',Location )
            IF len(OpenPh) > 0
               TPDF.GetBox_4.Value := OpenPh
            ENDIF

            RETURN
            /*
            */
            STATIC Proc SeleSpool()
               LOCAL O_Spool
               O_Spool := BrowseForFolder(NIL,BIF_EDITBOX + BIF_VALIDATE + BIF_NEWDIALOGSTYLE ;
                  ,"Please select a location to store data files", TPDF.Textbox_3.Value)
               O_Spool += "\"
               IF len(O_Spool) > 0
                  // FDF:
                  TPDF.Textbox_3.Value := O_Spool
               ELSE
                  IF empty(TPDF.Textbox_3.Value)
                     msgExclamation( "Invalid entry!!!" )
                  ENDIF
               ENDIF

               RETURN
               /*
               */

STATIC FUNCTION lIsDir( cDir )

   LOCAL lExist := .T.

   IF DIRCHANGE( cDir ) > 0
      lExist := .F.
   ELSE
      DIRCHANGE( DirPrg() )
   ENDIF

   RETURN lExist
   /*
   */

STATIC FUNCTION PROPER(interm)      //Created By Piersoft 01/04/95 KILLED Bugs!

   LOCAL outstring:='',capnxt:=''

   DO WHILE chr(32) $ interm
      c_1:=substr(interm,1,at(chr(32),interm)-1)
      capnxt:=capnxt+upper(left(c_1,1))+right(c_1,len(c_1)-1)+" "
      interm:=substr(interm,len(c_1)+2,len(interm)-len(c_1))
   ENDDO
   outstring=capnxt+upper(left(interm,1))+right(interm,len(interm)-1)

   RETURN outstring
   /*
   */

FUNCTION AddSpace(st,final_len)

   RETURN SUBST(st+REPL(' ',final_len-LEN(st)),1,final_len)
   /*
   */

FUNCTION edita()

   aData_Source := FdF:aEnact
   IF !_IsControlDefined ("oBrw1", "IniEdit")

      DEFINE TBROWSE oBrw1 ;
         AT 10,10 ;
         OF IniEdit ;
         WIDTH 505 ;
         HEIGHT 140 ;
         CELLED ;
         FONT "Verdana" ;
         SIZE 10 ;

      oBrw1:SetArray( FdF:aEnact,,.f. )

      ADD COLUMN TO TBROWSE oBrw1 ;
         DATA ARRAY ELEMENT 1;
         PICTURE "@!" ;
         TITLE "Pdf Field" SIZE 150 EDITABLE

      ADD COLUMN TO TBROWSE oBrw1 ;
         DATA ARRAY ELEMENT 2;
         PICTURE "@X" ;
         TITLE "Espression" SIZE 350 EDITABLE

      oBrw1:nFreeze := 1
      oBrw1:nHeightCell += 10
      oBrw1:SetAppendMode( .T. )
      oBrw1:SetDeleteMode( .T., .T.)

   End TBROWSE
ENDIF
obrw1:refresh()

RETURN NIL
/*
*/

FUNCTION DbView()

   PRIVATE Brw_Db, nf := 0 ,hXpr := "{"

   IF !IsWIndowDefined (Dbview)
      IF file(FdF:DirData+Fdf:DataSource)
         sele 1
         USE &(FdF:DirData+FDF:DataSource) shared alias USEIT
         FOR nf =1 to Fcount()
            hXpr += "{||Showfield("+ ltrim(str(nf))+")},"
         NEXT
         hXpr := substr(hXpr, 1, len(hXpr)-1) +"}"
         Hact := macrocompile(hXpr)
      ELSE
         MsgStop("No data available for this script.")

         RETURN NIL
      ENDIF
      DEFINE WINDOW DbView ;
            AT 50,22 ;
            WIDTH 530 HEIGHT 275 ;
            TITLE "DbView";
            CHILD NOSIZE

         DEFINE STATUSBAR
            STATUSITEM '' DEFAULT
         END STATUSBAR

         DEFINE TBROWSE Brw_Db AT 0,0 ALIAS "USEIT" ;
            WIDTH 523 HEIGHT 220 ;
            MESSAGE 'Double Click on headers to copy FieldName '+;
            'in Espression List';
            ON HEADCLICK Hact

         Brw_Db:LoadFields()

      END TBROWSE
      */
   END WINDOW
   ACTIVATE WINDOW DbView
ELSE
   RESTORE WINDOW DbView
ENDIF
RELEASE Brw_db, nf ,hXpr

RETURN NIL
/*
*/

FUNCTION ShowField(arg1)

   LOCAL nx := 0, rtv := Hgconvert( DBFIELDINFO(DBS_NAME ,arg1) )

   rtv := Addspace(rtv,120)
   FdF:aEnact[oBrw1:nAt,2] := rtv
   oBrw1:refresh()

   RETURN  NIL

   /*
   */

FUNCTION InsertSpace(st,spaces)

   LOCAL nx := 0, rtv:=''

   DEFAULT spaces to 0, st to ''
   st:=alltrim(st)
   FOR nx = 1 to len(st)
      rtv += substr(st,nx,1)+ repl(' ',spaces)
   NEXT

   RETURN rtv
   /*
   */

STATIC FUNCTION NUMTOLET(nume)  // Italian Version

   LOCAL unita   :="uno    due    tre    quattrocinque sei    sette  otto   nove   "
   LOCAL decina1 := "dieci      undici     dodici     tredici    quattordici"+;
      "quindici   sedici     diciassettediciotto   diciannove "
   LOCAL decine  := "dieci    venti    trenta   quaranta cinquantasessanta "+;
      "settanta ottanta  novanta  "
   LOCAL attributi := "miliardimilioni mila    "
   LOCAL parole,cifre,gruppo,stringa,tre_cifre, DecTrue:=.t., valdec:="00"

   DO CASE

      * filtrazione dei casi particolari (valori 0 e 1)
   CASE nume=0
      parole = "zero"

      * conversione generalizzata del numero
   OTHERWISE

      * conversione da numero a caratteri
      cifre = STR(ABS(nume),12,2)
      valdec:=substr(cifre,at(".",cifre)+1)
      DecTrue :=if(val(valdec) > 0,.t.,.f.)
      cifre = substr(cifre,1,at(".",cifre)-1)
      cifre =space(12-len(cifre))+ cifre

      parole = ""

      * ciclo di analisi dei 4 gruppi di 3 cifre ciascuno, da destra verso
      * sinistra; il gruppo 1 Š quello dei miliardi
      gruppo = 4
      DO WHILE gruppo#0

         * estrazione delle tre cifre del gruppo
         tre_cifre = SUBSTR(cifre,(gruppo-1)*3+1,3)
         stringa = ""
         DO CASE

            * verifica della condizione di fine ciclo prematura
         CASE tre_cifre=SPACE(3)
            EXIT

            * filtrazione del caso anomalo di valore del gruppo uguale a 1
         CASE VAL(tre_cifre)=1
            DO CASE
            CASE gruppo=4
               stringa = "uno"
            CASE gruppo=3
               stringa = "mille"
            CASE gruppo=2
               stringa = "unmilione"
            CASE gruppo=1
               stringa = "unmiliardo"
            ENDCASE

            * conversione generalizzata del valore del gruppo diverso da 0
         CASE VAL(tre_cifre)>1

            * analisi della prima cifra a sinistra (centinaia)
            cifra = VAL(SUBSTR(tre_cifre,1,1))
            IF cifra#0
               IF cifra>1
                  stringa = TRIM(SUBSTR(unita,(cifra-1)*7+1,7))
               ENDIF
               stringa = stringa+"cento"

               * controllo dell'eccezione "CENTOOTTANTA"
               IF SUBSTR(tre_cifre,2,1)="8"
                  stringa = LEFT(stringa,LEN(stringa)-1)
               ENDIF
            ENDIF

            * analisi della cifra centrale (decine)
            cifra = VAL(SUBSTR(tre_cifre,2,1))
            IF cifra=1

               * caso della prima decina
               cifra = VAL(SUBSTR(tre_cifre,3,1))
               stringa = stringa+TRIM(SUBSTR(decina1,cifra*11+1,11))

            ELSE

               * caso della decine successive alla prima
               IF cifra>1
                  stringa = stringa+TRIM(SUBSTR(decine,(cifra-1)*9+1,9))

                  * controllo delle eccezioni del tipo "VENTIUNO" e "VENTIOTTO"
                  IF SUBSTR(tre_cifre,3,1)$"18"
                     stringa = LEFT(stringa,LEN(stringa)-1)
                  ENDIF
               ENDIF

               * analisi dell'ultima cifra a destra (unit…)
               cifra = VAL(SUBSTR(tre_cifre,3,1))
               IF cifra>0
                  stringa = stringa+TRIM(SUBSTR(unita,(cifra-1)*7+1,7))
               ENDIF
            ENDIF

            * aggiunta dell'attributo del gruppo (miliardi, milioni,
            * mila); il primo a destra deve essere escluso
            IF gruppo#4
               stringa = stringa+TRIM(SUBSTR(attributi,(gruppo-1)*8+1,8))
            ENDIF
         ENDCASE

         * composizione dei gruppi convertiti, con esclusione del valore 0
         IF LEN(stringa)#0
            parole = stringa+parole
         ENDIF

         * decremento dell'indice del ciclo
         gruppo = gruppo-1
      ENDDO
   ENDCASE
   parole := Proper(parole)
   IF DecTrue
      parole += [ e ]+ numtolet( val( valdec ) )+" centesimi"
   ENDIF

   RETURN(parole)
   /*
   */

FUNCTION ZapIt(arg_in,sep,euro,money)

   LOCAL arg1, arg2

   DEFAULT SEP TO .T., EURO TO .T., MONEY TO .F.

   IF Valtype(arg_in)== "C"
      *- make sure it fits on the screen
      arg1 = "@KS" + LTRIM(STR(MIN(LEN((alltrim(arg_in))), 78)))
   ELSEIF VALTYPE(arg_in) == "N"
      *- convert to a string
      arg2 := ltrim( STR (arg_in) )
      *- look for a decimal point
      IF ("." $ arg2)
         *- return a picture reflecting a decimal point
         arg1 := REPLICATE("9", AT(".", arg2) - 1)+[.]
         arg1 := eu_point(arg1,sep,euro)+[.]+ REPLICATE("9", LEN(arg2) - LEN(arg1))
      ELSE
         *- return a string of 9's a the picture
         arg1 := REPLICATE("9", LEN(arg2))
         arg1 := eu_point(arg1,sep,euro)+if( money,".00","")
      ENDIF
   ELSEIF VALTYPE(arg_in) == "D"
      arg_in := dtoc(arg_in)
      IF !sep
         arg_in := strtran(arg_in,"/","")
         arg_in := strtran(arg_in,"-","")
      ENDIF
      arg1:="@KS"+ LTRIM(STR(MIN(LEN((alltrim(arg_in))), 78)))
   ELSE
      *- well I just don't know.
      arg1 := ""
   ENDIF

   RETURN trans(arg_in,arg1)
   /*
   */

STATIC FUNCTION eu_point(valore,sep,euro)

   LOCAL TAPPO :='',sep_conto:=0, nv

   DEFAULT sep to .t., euro to .t.
   FOR nv= len(valore) to 1 step -1
      IF substr( valore,nv,1 )== [9]
         IF sep_conto = 3
            IF sep
               TAPPO := ","+TAPPO
            ENDIF
            sep_conto := 0
         ENDIF
         tappo := substr(valore,nv,1)+TAPPO
         sep_conto ++
      ENDIF
   NEXT
   IF euro
      TAPPO := "@E "+TAPPO
   ENDIF

   RETURN TAPPO

   /*
   */

STATIC FUNCTION MACROCOMPILE(cStr, lMesg,cmdline,section)

   LOCAL bOld, xResult, control :=.F.

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
         IF control
            MsgMiniGuiError("Program FdF Manager"+CRLF+"Section "+section+CRLF+"I have found error on line "+;
               zaps(cmdline)+CRLF+"Error is in: "+alltrim(cStr)+CRLF+"Please revise it!","MiniGUI Error")
            Break
         ELSE
            MsgStop("I have found error on line "+;
               zaps(cmdline)+CRLF+"Error is in: "+alltrim(cStr)+CRLF+"Please revise it!","Program FdF Manager Error")
         ENDIF
      ENDIF
      xResult := cStr
   END SEQUENCE
   errorblock (bOld)

   RETURN xResult
   /*
   */

FUNCTION Test()

   IF file(FdF:DirData+FDF:DataSource)
      sele 1
      USE &(FdF:DirData+FDF:DataSource) shared alias USEIT
      aeval(FdF:aEnact,{|x,y| if(! empty(trim(x[2]));
         ,MsgBox(macrocompile( x[2],.F. ),ltrim(str(y)));
         ,MsgExclamation("Definition of field "+trim(x[1])+;
         ' is empty!'+CRLF+'Please revise It.', ltrim(str(y))) ) } )
   ELSE
      MsgStop("No data available in this folder.")
   ENDIF

   RETURN NIL
   /*
   */

STATIC FUNCTION Hgconvert(ltxt)

   DO CASE
   CASE valtype(&ltxt)$ "MC" ;  return 'FIELD->'+ltxt
   CASE valtype(&ltxt)$ "ND" ;  return 'ZapIt(FIELD->'+ltxt+',.T.,.T.)'
   CASE valtype(&ltxt)=="L"  ;  return 'if(FIELD->'+ltxt+',".T.",".F.")'
   ENDCASE

   RETURN ''

FUNCTION BrowseForFolder( nfolder, nflag, cTitle, cInitPath, lCenter )

   RETURN HB_BrowseForFolder( NIL, cTitle, nflag, nfolder, cInitPath, lCenter )

STATIC FUNCTION GetInstallAcrobat(hKey)

   LOCAL aInst := {}, oReg, cReg := "", oKey, cFile, ;
      cName := "", nId:= 0,cPathRes := ''

   hKey := IF(hKey == NIL, HKEY_LOCAL_MACHINE, hKey)
   //  Verify if acrobat is installed
   oReg := TReg32():New( hKey, "Software\Microsoft\Windows\CurrentVersion\Uninstall" )

   WHILE RegEnumKey( oReg:nHandle, nId++, @cReg ) == 0
      oKey := TReg32():New( hKey, "Software\Microsoft\Windows\CurrentVersion\Uninstall\" + cReg )
      cName := oKey:Get("DisplayName")
      IF !empty(cname) .and. "ADOBE READER" == left(upper(cname),12)
         cPathRes := cname
      ENDIF
      oKey:Close()
   End

   IF !empty(CpathRes)  // acrobat installed!
      Open registry oReg key HKEY_CLASSES_ROOT Section 'AcroExch.FDFDoc\shell\Printto\command'
      GET value CpathRes Name '' of oReg
      CLOSE registry oReg
   ENDIF

   RETURN cpathRes

   #ifdef __XHARBOUR__
   #include <fileread.prg>
   #endif

#pragma BEGINDUMP

#define _WIN32_WINNT   0x0400
#include <shlobj.h>

#include <windows.h>
#include <commctrl.h>
#include "hbapi.h"

#ifndef __XHARBOUR__
   #define ISCHAR( n )           HB_ISCHAR( n )
   #define ISNIL( n )            HB_ISNIL( n )
#endif

static BOOL s_bCntrDialog = FALSE;

void CenterDialog( HWND hwnd )
{
   RECT  rect;
   int   w, h, x, y;

   GetWindowRect( hwnd, &rect );
   w = rect.right - rect.left;
   h = rect.bottom - rect.top;
   x = GetSystemMetrics( SM_CXSCREEN );
   y = GetSystemMetrics( SM_CYSCREEN );
   MoveWindow( hwnd, (x - w) / 2, (y - h) / 2, w, h, TRUE );
}

int CALLBACK BrowseCallbackProc( HWND hWnd, UINT uMsg, LPARAM lParam, LPARAM lpData )
{
   TCHAR szPath[MAX_PATH];
   switch( uMsg )
   {
      case BFFM_INITIALIZED:  if( lpData ){ SendMessage( hWnd, BFFM_SETSELECTION, TRUE, lpData ); if( s_bCntrDialog ) CenterDialog( hWnd );} break;
      case BFFM_SELCHANGED:   SHGetPathFromIDList( (LPITEMIDLIST) lParam, szPath ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) szPath ); break;
      case BFFM_VALIDATEFAILED:  MessageBeep( MB_ICONHAND ); SendMessage( hWnd, BFFM_SETSTATUSTEXT, NULL, (LPARAM) "Bad Directory" ); return 1;
   }

   return 0;
}

HB_FUNC( HB_BROWSEFORFOLDER )  // Syntax: HB_BROWSEFORFOLDER([<hWnd>],[<cTitle>],<nFlags>,[<nFolderType>],[<cInitPath>],[<lCenter>])
{
   HWND           hWnd = ISNIL( 1 ) ? GetActiveWindow() : ( HWND ) hb_parnl( 1 );
   BROWSEINFO     BrowseInfo;
   char           *lpBuffer = ( char * ) hb_xgrab( MAX_PATH + 1 );
   LPITEMIDLIST   pidlBrowse;

   SHGetSpecialFolderLocation( hWnd, ISNIL(4) ? CSIDL_DRIVES : hb_parni(4), &pidlBrowse );

   BrowseInfo.hwndOwner = hWnd;
   BrowseInfo.pidlRoot = pidlBrowse;
   BrowseInfo.pszDisplayName = lpBuffer;
   BrowseInfo.lpszTitle = ISNIL( 2 ) ? "Select a Folder" : hb_parc( 2 );
   BrowseInfo.ulFlags = hb_parni( 3 );
   BrowseInfo.lpfn = BrowseCallbackProc;
   BrowseInfo.lParam = ISCHAR( 5 ) ? (LPARAM) (char *) hb_parc( 5 ) : 0;
   BrowseInfo.iImage = 0;

   s_bCntrDialog = ISNIL(6) ? FALSE : hb_parl( 6 );

   pidlBrowse = SHBrowseForFolder( &BrowseInfo );

   if( pidlBrowse )
   {
      SHGetPathFromIDList( pidlBrowse, lpBuffer );
      hb_retc( lpBuffer );
   }
   else
   {
      hb_retc( "" );
   }

   hb_xfree( lpBuffer );
}

HB_FUNC ( REGENUMKEY )
{
   BYTE buffer[ 128 ];
   hb_retnl( RegEnumKey( ( HKEY ) hb_parnl( 1 ), hb_parnl( 2 ), buffer, 128 ) );
   hb_storc( buffer, 3 );
}

HB_FUNC ( FINDWINDOW )
{
   hb_retnl( ( LONG ) FindWindow( 0, hb_parc( 1 ) ) );
}

#pragma ENDDUMP
