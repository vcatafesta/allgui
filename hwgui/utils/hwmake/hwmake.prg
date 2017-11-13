/*
*$Id: hwmake.prg 2012 2013-03-07 09:03:56Z alkresin $
* HWGUI - Harbour Win32 GUI library
* HwMake
* Copyright 2004 Sandro R. R. Freire <sandrorrfreire@yahoo.com.br>
* www - http://www.hwgui.net
*/

#include "windows.ch"
#include "guilib.ch"

#define  ID_EXENAME     10001
#define  ID_LIBFOLDER   10002
#define  ID_INCFOLDER   10003
#define  ID_PRGFLAG     10004
#define  ID_CFLAG       10005
#define  ID_PRGMAIN     10006

#ifndef __XHARBOUR__

ANNOUNCE HB_GTSYS
REQUEST HB_GT_GUI_DEFAULT

#xcommand TRY              => s_bError := errorBlock( {|oErr| break( oErr ) } ) ;;
   BEGIN SEQUENCE
   #xcommand CATCH [<!oErr!>] => errorBlock( s_bError ) ;;
   RECOVER [USING <oErr>] <-oErr-> ;;
      errorBlock( s_bError )
   #command FINALLY           => ALWAYS

   #endif

FUNCTION Main

   LOCAL oFont
   LOCAL aBrowse1, aBrowse2, aBrowse3, aBrowse4
   LOCAL oPasta  := DiskName()+":\"+CurDir()+"\"
   LOCAL vGt1:=Space(80)
   LOCAL vGt2:=Space(80)
   LOCAL vGt3:=Space(80)
   LOCAL vGt4:=Space(80)
   LOCAL vGt5:=Space(80)
   LOCAL vGt6:=Space(80)
   LOCAL aFiles1:={""}, aFiles2:={""}, aFiles3:={""}, aFiles4:={""}

   LOCAL oBtBuild
   LOCAL oBtExit
   LOCAL oBtOpen
   LOCAL oBtSave

   PRIVATE cDirec:=DiskName()+":\"+CurDir()+"\"

   IF !File(cDirec+"hwmake.ini")
      Hwg_WriteIni( 'Config', 'Dir_HwGUI', "C:\HwGUI", cDirec+"hwmake.ini" )
      Hwg_WriteIni( 'Config', 'Dir_HARBOUR', "C:\xHARBOUR", cDirec+"hwmake.ini" )
      Hwg_WriteIni( 'Config', 'Dir_BCC55', "C:\BCC55", cDirec+"hwmake.ini" )
      Hwg_WriteIni( 'Config', 'Dir_OBJ', "OBJ", cDirec+"hwmake.ini" )
   ENDIF

   PRIVATE oImgNew  := hbitmap():addResource("NEW")
   PRIVATE oImgExit := hbitmap():addResource("EXIT")
   PRIVATE oImgBuild:= hbitmap():addResource("BUILD")
   PRIVATE oImgSave := hbitmap():addResource("SAVE")
   PRIVATE oImgOpen := hbitmap():addResource("OPEN")
   PRIVATE oStatus
   PRIVATE lSaved:=.F.
   PRIVATE oBrowse1, oBrowse2, oBrowse3
   PRIVATE oDlg
   PRIVATE oExeName, oLabel1, oLibFolder, oLabel2, oIncFolder, oLabel3, oPrgFlag, oLabel4, oCFlag, oLabel5, oMainPrg, oLabel6, oTab
   PRIVATE oIcon := HIcon():AddResource("PIM")

   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -12

   INIT DIALOG oDlg CLIPPER NOEXIT TITLE "HwGUI Build Projects for BCC55" ;
      AT 213,195 SIZE 513,295  font oFont ICON oIcon

   ADD STATUS oStatus TO oDlg ;
      PARTS oDlg:nWidth-160,150

   MENU OF oDlg
   MENU TITLE "&File"
   MENUITEM "&Build" ACTION BuildApp()
   MENUITEM "&Open"  ACTION ReadBuildFile()
   MENUITEM "&Save"  ACTION  SaveBuildFile()
   SEPARATOR
   MENUITEM "&Exit"  ACTION hwg_EndDialog()
   ENDMENU
   MENU TITLE "&Help"
   MENUITEM "&About" ACTION OpenAbout()
   MENUITEM "&Version HwGUI" ACTION hwg_Msginfo(HwG_Version())
   ENDMENU
   ENDMENU

   @ 14,16 TAB oTAB ITEMS {} SIZE 391,242

   BEGIN PAGE "Config" Of oTAB
      @  20,44 SAY oLabel1 CAPTION "Exe Name" TRANSPARENT SIZE 80,22
      @ 136,44 GET oExeName VAR vGt1 ID ID_EXENAME  SIZE 206,24

      @  20,74 SAY oLabel2 CAPTION "Lib Folder" TRANSPARENT SIZE 80,22
      @ 136,74 GET oLibFolder  VAR vGt2 ID ID_LIBFOLDER SIZE 234,24

      @  20,104 SAY oLabel3 CAPTION "Include Folder" TRANSPARENT SIZE 105,22
      @ 136,104 GET oIncFolder VAR vGt3 ID ID_INCFOLDER   SIZE 234,24

      @  20,134 SAY oLabel4 CAPTION "PRG Flags" TRANSPARENT SIZE 80,22
      @ 136,134 GET oPrgFlag VAR vGt4 ID ID_PRGFLAG  SIZE 234,24

      @  20,164 SAY oLabel5 CAPTION "C Flags" TRANSPARENT SIZE 80,22
      @ 136,164 GET oCFlag VAR vGt5  ID ID_CFLAG SIZE 234,24

      @  20,194 SAY oLabel6 CAPTION "Main PRG" TRANSPARENT SIZE 80,22
      @ 136,194 GET oMainPrg VAR vGt6 ID ID_PRGMAIN  SIZE 206,24
      @ 347,194 OWNERBUTTON    SIZE 24,24   ;
         ON CLICK {||searchFileName("xBase Files *.prg ", oMainPrg, "*.prg")};//       FLAT;
         TEXT "..." ;//BITMAP "SEARCH" FROM RESOURCE TRANSPARENT COORDINATES 0,0,0,0 ;
         TOOLTIP "Search main file"

   END PAGE of oTAB
   BEGIN PAGE "Prg (Files)" of oTAB
      @ 21,29 BROWSE oBrowse1 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse1,"*.prg")};
         STYLE WS_VSCROLL + WS_HSCROLL   SIZE 341,170
      hwg_CREATEARLIST(oBrowse1,aFiles1)
      obrowse1:acolumns[1]:heading := "File Names"
      obrowse1:acolumns[1]:length := 50
      oBrowse1:bcolorSel := hwg_VColor( "800080" )
      oBrowse1:ofont := HFont():Add( 'Arial',0,-12 )
      @ 10, 205 BUTTON "Add"     SIZE 60,25  on click {||SearchFile(oBrowse1, "*.prg")}
      @ 70, 205 BUTTON "Delete"  SIZE 60,25  on click {||BrwdelIten(oBrowse1)}

   END PAGE of oTAB
   BEGIN PAGE "C (Files)" of oTAB
      @ 21,29 BROWSE oBrowse2 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse2, "*.c")};
         STYLE WS_VSCROLL + WS_HSCROLL   SIZE 341,170
      hwg_CREATEARLIST(oBrowse2,aFiles2)
      obrowse2:acolumns[1]:heading := "File Names"
      obrowse2:acolumns[1]:length := 50
      oBrowse2:bcolorSel := hwg_VColor( "800080" )
      oBrowse2:ofont := HFont():Add( 'Arial',0,-12 )
      @ 10, 205 BUTTON "Add"     SIZE 60,25  on click {||SearchFile(oBrowse2, "*.c")}
      @ 70, 205 BUTTON "Delete"  SIZE 60,25  on click {||BrwdelIten(oBrowse2)}
   END PAGE of oTAB
   BEGIN PAGE "Lib (Files)" of oTAB
      @ 21,29 BROWSE oBrowse3 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse3, "*.lib")};
         STYLE WS_VSCROLL + WS_HSCROLL   SIZE 341,170
      hwg_CREATEARLIST(oBrowse3,aFiles3)
      obrowse3:acolumns[1]:heading := "File Names"
      obrowse3:acolumns[1]:length := 50
      oBrowse3:bcolorSel := hwg_VColor( "800080" )
      oBrowse3:ofont := HFont():Add( 'Arial',0,-12 )
      @ 10, 205 BUTTON "Add"     SIZE 60,25  on click {||SearchFile(oBrowse3, "*.lib")}
      @ 70, 205 BUTTON "Delete"  SIZE 60,25  on click {||BrwdelIten(oBrowse3)}
   END PAGE of oTAB
   BEGIN PAGE "Resource (Files)" of oTAB
      @ 21,29 BROWSE oBrowse4 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse3, "*.rc")};
         STYLE WS_VSCROLL + WS_HSCROLL   SIZE 341,170
      hwg_CREATEARLIST(oBrowse4,aFiles4)
      obrowse4:acolumns[1]:heading := "File Names"
      obrowse4:acolumns[1]:length := 50
      oBrowse4:bcolorSel := hwg_VColor( "800080" )
      oBrowse4:ofont := HFont():Add( 'Arial',0,-12 )
      @ 10, 205 BUTTON "Add"     SIZE 60,25  on click {||SearchFile(oBrowse4, "*.rc")}
      @ 70, 205 BUTTON "Delete"  SIZE 60,25  on click {||BrwdelIten(oBrowse4)}
   END PAGE of oTAB

   @ 419, 20 BUTTONex oBtBuild CAPTION "Build" BITMAP oImgBuild:Handle on Click {||BuildApp()}      SIZE 88,52
   @ 419, 80 BUTTONex oBtExit  CAPTION "Exit"  BITMAP oImgExit:Handle  on Click {||hwg_EndDialog()}     SIZE 88,52
   @ 419,140 BUTTONex oBtOpen  CAPTION "Open"  BITMAP oImgOpen:Handle  on Click {||ReadBuildFile()} SIZE 88,52
   @ 419,200 BUTTONex oBtSave  CAPTION "Save"  BITMAP oImgSave:Handle  on Click {||SaveBuildFile()} SIZE 88,52

   ACTIVATE DIALOG oDlg

   RETURN

STATIC FUNCTION SearchFile(oBrow, oFile)

   LOCAL oTotReg:={}, i
   LOCAL aSelect:=hwg_SelectMultipleFiles("xBase Files ("+oFile+")", oFile )

   IF len(aSelect) ==0

      RETURN NIL
   ENDIF
   IF LEN(oBrow:aArray) == 1 .and. obrow:aArray[1]==""
      obrow:aArray := {}
   ENDIF
   FOR i:=1 to Len(oBrow:aArray)
      AADD(oTotReg, oBrow:aArray[i])
   NEXT
   FOR i:=1 to Len(aSelect)
      AADD(oTotReg, aSelect[i])
   NEXT
   obrow:aArray := oTotReg
   obrow:refresh()

   RETURN NIL

STATIC FUNCTION SearchFileName(nName, oGet, oFile)

   LOCAL oTextAnt:=oGet:GetText()
   LOCAL fFile:=hwg_SelectFile(nName+" ("+oFile+")", oFile,,,.T. )

   IF !Empty(oTextAnt)
      fFile:=oTextAnt //
   ENDIF
   oGet:SetText(fFile)
   oGet:Refresh()

   RETURN NIL

FUNCTION ReadBuildFile()

   LOCAL cLibFiles, oBr1:={}, oBr2:={}, oBr3:={}, oBr4:={}, oSel1, oSel2, oSel3, i, oSel4
   LOCAL aPal:=""
   LOCAL cFolderFile:=hwg_SelectFile("HwGUI File Build (*.bld)", "*.bld" )

   IF empty(cFolderFile); Return Nil; Endif
   oStatus:SetTextPanel(1,cFolderFile)
   oExeName:SetText( Hwg_GetIni( 'Config', 'ExeName' , , cFolderFile ))
   oLibFolder:SetText(Hwg_GetIni( 'Config', 'LibFolder' , , cFolderFile ))
   oIncFolder:SetText(Hwg_GetIni( 'Config', 'IncludeFolder' , , cFolderFile ))
   oPrgFlag:SetText(Hwg_GetIni( 'Config', 'PrgFlags' , , cFolderFile ))
   oCFlag:SetText(Hwg_GetIni( 'Config', 'CFlags' , , cFolderFile ))
   oMainPrg:SetText(Hwg_GetIni( 'Config', 'PrgMain' , , cFolderFile ))

   FOR i:=1 to 300
      oSel1:=Hwg_GetIni( 'FilesPRG', Alltrim(Str(i)) , , cFolderFile )
      IF !empty(oSel1) //.or. oSel1#Nil
         AADD(oBr1, oSel1)
      ENDIF
   NEXT

   FOR i:=1 to 300
      oSel2:=Hwg_GetIni( 'FilesC', Alltrim(Str(i)) , , cFolderFile )
      IF !empty(oSel2) //.or. oSel2#Nil
         AADD(oBr2, oSel2)
      ENDIF
   NEXT

   FOR i:=1 to 300
      oSel3:=Hwg_GetIni( 'FilesLIB', Alltrim(Str(i)) , , cFolderFile )
      IF !empty(oSel3) //.or. oSel3#Nil
         AADD(oBr3, oSel3)
      ENDIF
   NEXT

   FOR i:=1 to 300
      oSel4:=Hwg_GetIni( 'FilesRES', Alltrim(Str(i)) , , cFolderFile )
      IF !empty(oSel4) //.or. oSel4#Nil
         AADD(oBr4, oSel4)
      ENDIF
   NEXT

   oBrowse1:aArray:=oBr1
   oBrowse2:aArray:=oBr2
   oBrowse3:aArray:=oBr3
   oBrowse4:aArray:=oBr4
   oBrowse1:Refresh()
   oBrowse2:Refresh()
   oBrowse3:Refresh()
   oBrowse4:Refresh()

   RETURN NIL

FUNCTION cPathNoFile( cArq )

   LOCAL i
   LOCAL cDest := ""
   LOCAL cLetra
   LOCAL cNome := cFileNoPath( cArq )

   cDest := Alltrim( StrTran( cArq, cNome, "" ) )

   IF Substr( cDest, -1, 1 ) == "\"
      cDest := Substr( cDest, 1, Len( cDest ) -1 )
   ENDIF

   RETURN cDest

FUNCTION cFileNoExt( cArq )

   LOCAL n

   n:=At( ".", cArq )
   IF n > 0

      RETURN Substr( cArq, 1, n - 1 )
   ENDIF

   RETURN cArq

FUNCTION cFileNoPath( cArq )

   LOCAL i
   LOCAL cDest := ""
   LOCAL cLetra

   FOR i:=1 to Len( cArq )

      cLetra := Substr( cArq, i, 1 )
      IF cLetra == "\"
         cDest := ""
      ELSE
         cDest += cLetra
      ENDIF

   NEXT

   RETURN cDest

FUNCTION SaveBuildFile()

   LOCAL cLibFiles, i, oNome, g
   LOCAL cFolderFile:=hwg_SaveFile("*.bld", "HwGUI File Build (*.bld)", "*.bld" )

   IF empty(cFolderFile); Return Nil; Endif
   IF file(cFolderFile)
      If(hwg_Msgyesno("File "+cFolderFile+" EXIT ..Replace?"))
      ERASE( cFolderFile )
   ELSE
      hwg_Msginfo("No file SAVED.", "HwMake")

      RETURN NIL
   ENDIF
ENDIF
Hwg_WriteIni( 'Config', 'ExeName'       ,oExeName:GetText(), cFolderFile )
Hwg_WriteIni( 'Config', 'LibFolder'     ,oLibFolder:GetText(), cFolderFile )
Hwg_WriteIni( 'Config', 'IncludeFolder' ,oIncFolder:GetText(), cFolderFile )
Hwg_WriteIni( 'Config', 'PrgFlags'      ,oPrgFlag:GetText(), cFolderFile )
Hwg_WriteIni( 'Config', 'CFlags'        ,oCFlag:GetText(), cFolderFile )
Hwg_WriteIni( 'Config', 'PrgMain'       ,oMainPrg:GetText(), cFolderFile )
oNome:=""

IF Len(oBrowse1:aArray)>=1
   FOR i:=1 to Len(oBrowse1:aArray)

      IF !empty(oBrowse1:aArray[i])

         Hwg_WriteIni( 'FilesPRG', Alltrim(Str(i)),oBrowse1:aArray[i], cFolderFile )

      ENDIF

   NEXT

ENDIF

IF Len(oBrowse2:aArray)>=1
   FOR i:=1 to Len(oBrowse2:aArray)
      IF !empty(oBrowse2:aArray[i])
         Hwg_WriteIni( 'FilesC', Alltrim(Str(i)),oBrowse2:aArray[i], cFolderFile )
      ENDIF
   NEXT
ENDIF

IF Len(oBrowse3:aArray)>=1
   FOR i:=1 to Len(oBrowse3:aArray)
      IF !empty(oBrowse3:aArray[i])
         Hwg_WriteIni( 'FilesLIB', Alltrim(Str(i)),oBrowse3:aArray[i], cFolderFile )
      ENDIF
   NEXT
ENDIF

IF Len(oBrowse4:aArray)>=1
   FOR i:=1 to Len(oBrowse4:aArray)
      IF !empty(oBrowse4:aArray[i])
         Hwg_WriteIni( 'FilesRES', Alltrim(Str(i)),oBrowse4:aArray[i], cFolderFile )
      ENDIF
   NEXT
ENDIF

hwg_Msginfo("File "+cFolderFile+" saved","HwGUI Build", "HwMake")

RETURN NIL

FUNCTION BuildApp()

   LOCAL cExeHarbour
   LOCAL cHwGUI,cHarbour,cBCC55, cObj
   LOCAL cObjFileAttr  , nObjFileSize
   LOCAL dObjCreateDate, nObjCreateTime
   LOCAL dObjChangeDate, nObjChangeTime
   LOCAL cObjName, I
   LOCAL cPrgFileAttr  , nPrgFileSize
   LOCAL dPrgCreateDate, nPrgCreateTime
   LOCAL dPrgChangeDate, nPrgChangeTime
   LOCAL cPrgName
   LOCAL lAll := hwg_Msgyesno("Build All Fontes?", "Attention" )
   LOCAL lCompile
   LOCAL cList := ""
   LOCAL cMake
   LOCAL CRLF := Chr(13) + Chr(10)
   LOCAL cListObj := ""
   LOCAL cListRes := ""
   LOCAL cMainPrg := Alltrim( Lower( cFileNoPath( cFileNoExt( oMainPrg:GetText() ) ) ) )
   LOCAL cPathFile
   LOCAL cRun
   LOCAL cNameExe
   LOCAL nRep
   LOCAL cLogErro
   LOCAL cErrText
   LOCAL lEnd

   cPathFile := cPathNoFile( oMainPrg:GetText() )
   IF !Empty( cPathFile )
      DirChange( cPathFile )
   ENDIF

   IF File(cDirec+"hwmake.Ini")
      cHwGUI  := lower( alltrim( Hwg_GetIni( 'Config', 'DIR_HwGUI'   , , cDirec+"hwmake.Ini" ) ) )
      cHarbour:= lower( alltrim( Hwg_GetIni( 'Config', 'DIR_HARBOUR' , , cDirec+"hwmake.Ini")  ) )
      cBCC55  := lower( alltrim( Hwg_GetIni( 'Config', 'DIR_BCC55'   , , cDirec+"hwmake.Ini" ) ) )
      cObj    := lower( alltrim( Hwg_GetIni( 'Config', 'DIR_OBJ'     , , cDirec+"hwmake.Ini" ) ) )
   ELSE
      cHwGUI  :="c:\hwgui"
      cHarbour:="c:\xharbour"
      cBCC55  :="c:\bcc55"
      cObj    :="obj"
   ENDIF

   cObj := Lower( Alltrim( cObj ) )
   Makedir( cObj )

   cExeHarbour := Lower( cHarbour+"\bin\harbour.exe" )
   //If !File( cExeHarbour )
   //   hwg_Msginfo( "Not exist " + cExeHarbour +"!!" )
   //   Return Nil
   //EndIf

   //PrgFiles
   i := Ascan( oBrowse1:aArray, {|x| At( cMainPrg, x ) > 0 } )
   IF i == 0
      AADD(  oBrowse1:aArray, Alltrim( oMainPrg:GetText() ) )
   ENDIF

   FOR EACH i in oBrowse1:aArray
      cObjName := cObj+"\"+cFileNoPath( cFileNoExt( i ) ) + ".c"
      cPrgName := i
      lCompile := .F.
      IF lAll
         lCompile := .T.
      ELSE
         IF File( cObjName  )
            FileStats( cObjName, @cObjFileAttr  , @nObjFileSize, @dObjCreateDate, @nObjCreateTime, @dObjChangeDate, @nObjChangeTime  )
            FileStats( cPrgName, @cPrgFileAttr  , @nPrgFileSize, @dPrgCreateDate, @nPrgCreateTime, @dPrgChangeDate, @nPrgChangeTime  )
            IF dObjChangeDate <= dPrgChangeDate .and.  nObjChangeTime <  nPrgChangeTime
               lCompile := .T.
            ENDIF
         ELSE
            lCompile := .T.
         ENDIF
      ENDIF

      IF lCompile
         cLogErro := cFileNoPath( cFileNoExt( cObjName ) ) + ".log"
         fErase( cLogErro )
         fErase( cObjName )
         fErase( cFileNoExt( cObjName ) + ".obj" )
         IF ExecuteCommand(  cExeHarbour, cPrgName + " -o" + cObjName + " " + Alltrim( oPrgFlag:GetText() ) + " -n -i"+cHarbour+"\include;"+cHwGUI+"\include"+If( !Empty(Alltrim( oIncFolder:GetText() ) ), ";"+Alltrim( oIncFolder:GetText() ), ""),  cFileNoExt( cObjName ) + ".log" ) <> 0

            cErrText := Memoread( cLogErro )

            lEnd     := 'C2006' $ cErrText .OR. 'No code generated' $ cErrText .or. "Error E" $ cErrText .or. "Error F" $ cErrText
            IF lEnd
               ErrorPreview( Memoread( cLogErro ) )

               RETURN NIL
            ELSE
               IF File( cLogErro )
                  //  fErase( cLogErro )
               ENDIF
            ENDIF

            RETURN NIL

         ENDIF

      ENDIF
      cList    += cObjName + " "
      IF At( cMainPrg,cObjName ) == 0
         cListObj += StrTran( cObjName, ".c", ".obj" ) + " " + CRLF
      ENDIF
      cRun := " -v -y -c " +Alltrim( oCFlag:GetText() ) + " -O2 -tW -M -I"+cHarbour+"\include;"+cHwGUI+"\include;"+cBCC55+"\include " + "-o"+StrTran( cObjName, ".c", ".obj" ) + " " + cObjName
      IF ExecuteCommand( cBCC55 + "\bin\bcc32.exe", cRun ) <> 0
         hwg_Msginfo("No Created Object files!", "HwMake" )

         RETURN NIL
      ENDIF

   NEXT

   cListObj := "c0w32.obj +" + CRLF + cObj + "\" + cMainPrg + ".obj, +" + CRLF + cListObj

   FOR EACH i in oBrowse2:aArray
      cList += i + " "
      cListObj += cObj+"\"+cFileNoPath( cFilenoExt( i ) ) + ".obj"
   NEXT

   //ResourceFiles
   FOR EACH i in oBrowse4:aArray
      IF ExecuteCommand( cBCC55 + "\bin\brc32", "-r "+cFileNoExt(i)+" -fo"+cObj+"\"+cFileNoPath( cFileNoExt( i ) ) ) <> 0
         hwg_Msginfo("Error in Resource File " + i + "!", "HwMake" )

         RETURN NIL
      ENDIF
      cListRes += cObj+"\"+cFileNoPath( cFileNoExt( i ) ) + ".res +" + CRLF
   NEXT
   IF Len( cListRes ) > 0
      cListRes := Substr( cListRes, 1, Len( cListRes ) - 3 )
   ENDIF
   cMake := cListObj
   cNameExe := Alltrim( lower( oExeName:GetText() ) )
   IF At( ".exe", cNameExe ) == 0
      cNameExe += ".exe"
   ENDIF

   cMake += cNameExe + ", + " + CRLF
   cMake += cFileNoExt( oExeName:GetText() ) + ".map, + " + CRLF
   cMake += RetLibrary( cHwGUI, cHarbour, cBcc55, oBrowse3:aArray )
   //Add def File
   cMake += If( !Empty( cListRes ), ",," + cListRes, "" )

   IF File( cMainPrg + ".bc ")
      fErase( cMainPrg + ".bc " )
   ENDIF

   Memowrit( cMainPrg + ".bc ", cMake )

   IF ExecuteCommand( cBCC55 + "\bin\ilink32", "-v -Gn -aa -Tpe @"+cMainPrg + ".bc" ) <> 0
      hwg_Msginfo("No link file " + cMainPrg +"!", "HwMake" )

      RETURN NIL
   ENDIF

   IF File( cMainPrg + ".bc ")
      fErase( cMainPrg + ".bc " )
   ENDIF

   RETURN NIL

FUNCTION RetLibrary( cHwGUI, cHarbour, cBcc55, aLibs )

   LOCAL i, cLib, CRLF := " +" + Chr(179)
   LOCAL lMt := .F.

   cLib := cHwGUI + "\lib\hwgui.lib " + CRLF
   cLib += cHwGUI + "\lib\procmisc.lib " + CRLF
   cLib += cHwGUI + "\lib\hbxml.lib " + CRLF
   cLib += If( File(  cHarbour + "\lib\rtl"+If(lMt, cMt, "" )+".lib" ) ,  cHarbour + "\lib\rtl"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbrtl"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\hbrtl"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\vm"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\vm"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbvm.lib" )  ,  cHarbour + "\lib\hbvm.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\gtgui.lib" )  ,  cHarbour + "\lib\gtgui.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\gtwin.lib" )  ,  cHarbour + "\lib\gtwin.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\lang.lib" )  ,  cHarbour + "\lib\lang.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hblang.lib" )  ,  cHarbour + "\lib\hblang.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\codepage.lib" )  ,  cHarbour + "\lib\codepage.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbcpage.lib" )  ,  cHarbour + "\lib\hbcpage.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\macro"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\macro"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbmacro.lib" )  ,  cHarbour + "\lib\hbmacro.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\rdd"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\rdd"+If(lMt, cMt, "" )+".lib " + CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbrdd.lib") ,  cHarbour + "\lib\hbrdd.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\dbfntx"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\dbfntx"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\rddntx.lib" ) ,  cHarbour + "\lib\rddntx.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\dbfcdx"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\dbfcdx"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\rddcdx.lib") ,  cHarbour + "\lib\rddcdx.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\dbffpt"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\dbffpt"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\rddfpt.lib") ,  cHarbour + "\lib\rddfpt.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\sixcdx"+If(lMt, cMt, "" )+".lib" )  ,  cHarbour + "\lib\sixcdx"+If(lMt, cMt, "" )+".lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbsix.lib") ,  cHarbour + "\lib\hbsix.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\common.lib") ,  cHarbour + "\lib\common.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbcommon.lib") ,  cHarbour + "\lib\hbcommon.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\debug.lib") ,  cHarbour + "\lib\debug.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbdebug.lib") ,  cHarbour + "\lib\hbdebug.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\pp.lib") ,  cHarbour + "\lib\pp.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbpp.lib" ),  cHarbour + "\lib\hbpp.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hsx.lib") ,  cHarbour + "\lib\hsx.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbhsx.lib") ,  cHarbour + "\lib\hbhsx.lib "+ CRLF, "" )
   cLib += cHarbour + "\lib\hbsix.lib "+ CRLF
   cLib += If( File(  cHarbour + "\lib\pcrepos.lib" ),  cHarbour + "\lib\pcrepos.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbpcre.lib" ),  cHarbour + "\lib\hbpcre.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\zlib.lib" ),  cHarbour + "\lib\zlib.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbzlib.lib" ),  cHarbour + "\lib\hbzlib.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbw32.lib" ),  cHarbour + "\lib\hbw32.lib "+ CRLF, "" )
   cLib += If( File(  cHarbour + "\lib\hbwin.lib" ),  cHarbour + "\lib\hbwin.lib "+ CRLF, "" )
   cLib += cBcc55 + "\lib\cw32.lib " + CRLF
   cLib += cBcc55 + "\lib\import32.lib" + CRLF
   FOR EACH i in aLibs
      cLib += lower(i) + CRLF
   NEXT

   cLib := Substr( Alltrim( cLib ), 1, Len( Alltrim( cLib ) ) - 2 )
   cLib := StrTran( cLib, Chr(179), Chr(13) + Chr(10 ) )

   RETURN cLib

FUNCTION ExecuteCommand( cProc, cSend, cLog )

   LOCAL cFile := "execcom.bat"
   LOCAL nRet

   IF cLog == Nil
      cLog := ""
   ELSE
      cLog := " > " + cFileNoPath( cLog )
   ENDIF
   IF File( cFile )
      fErase( cFile )
   ENDIF
   Memowrit( cFile, cProc + " " + cSend + cLog )
   nRet := hwg_WAITRUN( cFile )
   IF File( cFile )
      fErase( cFile )
   ENDIF

   RETURN nRet

FUNCTION BrwdelIten( oBrowse )

   Adel(oBrowse:aArray, oBrowse:nCurrent)
   ASize( oBrowse:aArray, Len( oBrowse:aArray ) - 1 )

   RETURN oBrowse:Refresh()

FUNCTION OpenAbout

   LOCAL oModDlg, oFontBtn, oFontDlg
   LOCAL oBmp
   LOCAL oSay

   PREPARE FONT oFontDlg NAME "MS Sans Serif" WIDTH 0 HEIGHT -13
   PREPARE FONT oFontBtn NAME "MS Sans Serif" WIDTH 0 HEIGHT -13 ITALIC UNDERLINE

   INIT DIALOG oModDlg TITLE "About"     ;
      AT 190,10  SIZE 360,200               ;
      ICON oIcon                            ;
      FONT oFontDlg

   @ 20,40 SAY "Hwgui Internacional Page"        ;
      LINK "http://www.hwgui.net" ;
      SIZE 230, 22 STYLE SS_CENTER  ;
      COLOR hwg_VColor("0000FF") ;
      VISITCOLOR hwg_Rgb(241,249,91)

   @ 20,60 SAY "Hwgui Kresin Page"        ;
      LINK "http://kresin.belgorod.su/hwgui.html" ;
      SIZE 230, 22 STYLE SS_CENTER  ;
      COLOR hwg_VColor("0000FF") ;
      VISITCOLOR hwg_Rgb(241,249,91)

   @ 20,80 SAY "Hwgui international Forum"        ;
      LINK "http://br.groups.yahoo.com/group/hwguibr" ;
      SIZE 230, 22 STYLE SS_CENTER  ;
      COLOR hwg_VColor("0000FF") ;
      VISITCOLOR hwg_Rgb(241,249,91)

   @ 40, 120 BUTTONex oBtExit  CAPTION "Close"  BITMAP oImgExit:Handle  on Click {||hwg_EndDialog()}    SIZE 180,35

   ACTIVATE DIALOG oModDlg

   RETURN NIL

STATIC FUNCTION ErrorPreview( cMess )

   LOCAL oDlg, oEdit

   INIT DIALOG oDlg TITLE "Build Error" ;
      AT 92,61 SIZE 500,500

   @ 10,10 EDITBOX oEdit CAPTION cMess SIZE 480,440 STYLE WS_VSCROLL+WS_HSCROLL+ES_MULTILINE+ES_READONLY ;
      COLOR 16777088 BACKCOLOR 0 ;
      ON GETFOCUS {||hwg_Sendmessage(oEdit:handle,EM_SETSEL,0,0)}

   @ 200,460 BUTTON "Close" ON CLICK {||hwg_EndDialog()} SIZE 100,32

   oDlg:Activate()

   RETURN NIL

