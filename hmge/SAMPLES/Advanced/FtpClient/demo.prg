/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002-07 Roberto Lopez <harbourminigui@gmail.com>
* Based upon program MINIGUI\SAMPLES\ADVANCED\FILEMAN
* Copyright 2003-2007 Grigory Filatov <gfilatov@inbox.ru>
* Used functions desencri() and encri() by Gustavo C. Asborno <gcasborno@yahoo.com.ar>
* Used functions of sample ftplite on group harbourminigui_es by Juan Castillo A. <juan_casarte@yahoo.es>
* Copyright 2007 Walter Formigoni <walter.formigoni@uol.com.br>
*/

#include <minigui.ch>
#include "Dbstruct.ch"
#include "tip.ch"

STATIC aDirectory, aSubDirectory, aOldPos
STATIC aNivel := { 1, 1 }, aBack := { .t., .t. }, aGridWidth, nGridFocus := 1, bBlock, lBlock := .f.
STATIC cRunCommand := "", aWinVer, aSortCol := { 2, 2 }

MEMVAR lfirst, oClient, oUrl
MEMVAR newRecord

FUNCTION main()

   LOCAL nScrWidth := GetDesktopWidth(), nScrHeight := GetDesktopHeight(), nWidth, nHeight, nGridHeight, nGridWidth
   LOCAL cButton,cDrive

   LOCAL nWnd := 1
   PUBLIC lfirst := .t.
   PUBLIC oClient, oUrl

   IF !file("sites.dbf")
      CreateTable()
   ENDIF

   USE sites alias sites

   WHILE IsExeRunning( cFileNoPath( HB_ArgV( 0 ) ) + "_" + Ltrim(Str(nWnd)) )
      nWnd++
   END

   aWinVer := WindowsVersion()

   SET CENTURY ON
   SET DATE GERMAN

   aDirectory := ARRAY( 2 )
   aSubDirectory := ARRAY( 2, 64 )
   aOldPos := ARRAY( 2, 64 )

   aSubDirectory[1][1] := 'C:'
   aSubDirectory[2][1] := 'C:'

   nWidth := IF(nScrWidth >= 1024, 800, IF(nScrWidth >= 800, 700, 600))
   nHeight := IF(nScrHeight >= 768, 600, IF(nScrHeight >= 600, 540, 480))
   nGridHeight := IF(nHeight = 600, 360, IF(nHeight = 540, 299, 240))
   nGridWidth := IF(nWidth = 800, 380, IF(nWidth = 700, 330, 280))
   aGridWidth := IF(nHeight = 600, {0, 145, 80, 74, 60 }, IF(nHeight = 540, {0, 115, 80, 60, 54 }, {0, 85, 70, 60, 45 }))

   LOAD WINDOW ftp
   fillcombo()
   ftp.combo_1.value := 1
   ftp.button_4.enabled := .f.
   ftp.button_5.enabled := .f.
   ftp.button_6.enabled := .f.
   ftp.button_7.enabled := .f.
   CENTER WINDOW ftp
   ACTIVATE WINDOW ftp

   RETURN NIL

FUNCTION sitemanager()

   IF IsWindowDefined("sitemanager")
      Domethod( 'sitemanager', 'SETFOCUS')

      RETURN NIL
   ENDIF

   LOAD WINDOW sitemanager
   CENTER WINDOW sitemanager
   ACTIVATE WINDOW sitemanager

   RETURN NIL

FUNCTION sitemanagerexit()

   RELEASE WINDOW sitemanager

   RETURN NIL

FUNCTION editsite(param)

   PUBLIC newRecord

   LOAD WINDOW editsitemanager
   IF param = NIL
      newRecord := .f.
      sites->(dbgoto(sitemanager.browse_1.value))
      editsitemanager.text_1.value := sites->name
      editsitemanager.text_2.value  :=sites->address
      editsitemanager.text_3.value := sites->user
      editsitemanager.text_4.value :=  desencri(sites->password)  && decript
   ELSE
      newRecord := .t.
   ENDIF

   CENTER WINDOW editsitemanager
   ACTIVATE WINDOW editsitemanager

   RETURN NIL

FUNCTION ftppropcancel()

   RELEASE WINDOW editsitemanager

   RETURN NIL

FUNCTION ftpdelete()

   IF msgyesno('Are You Sure?','Delete Record') == .f.

      RETURN NIL
   ENDIF
   sites->(dbdelete(sitemanager.browse_1.value))
   sites->(__dbpack())
   sitemanager.browse_1.refresh
   fillcombo()

   RETURN NIL

FUNCTION ftppropsave()

   IF newRecord = .t.
      sites->(dbappend())
   ENDIF
   sites->name := editsitemanager.text_1.value
   sites->address := editsitemanager.text_2.value
   sites->user := editsitemanager.text_3.value
   sites->password := encrip(editsitemanager.text_4.value) && encript
   sitemanager.browse_1.refresh
   fillcombo()
   RELEASE WINDOW editsitemanager

   RETURN NIL

FUNCTION fillcombo()

   LOCAL x

   ftp.combo_1.deleteallitems
   FOR x = 1 to sites->(reccount())
      ftp.combo_1.additem(sites->name)
      sites->(dbskip())
   NEXT x

   RETURN NIL

FUNCTION ftpconn1()

   IF sites->(reccount()) > 0
      sites->(dbgoto(ftp.combo_1.value))
      ftpconnect()
   ELSE
      msgalert("No available sites", "Alert")
   ENDIF

   RETURN NIL

FUNCTION ftpconn2()

   sites->(dbgoto(sitemanager.browse_1.value))
   ftp.combo_1.value := sitemanager.browse_1.value
   ftpconnect()
   RELEASE WINDOW sitemanager

   RETURN NIL

FUNCTION ftpConnect()

   LOCAL cUser     := sites->user
   LOCAL cPassWord := desencri(sites->password)
   LOCAL cServer   := sites->address

   LOCAL cProtocol := "ftp://"
   LOCAL cUrl

   cUrl := cProtocol + Alltrim( cUser )+":"+ Alltrim( cPassWord ) +"@"+  alltrim( cServer)

   oUrl := tURL():New( cUrl )
   IF Empty( oUrl )

      RETURN NIL
   ENDIF
   oClient := TIpClientFtp():new( oUrl, .T. ) && PARAM .T. TO LOG
   IF Empty( oClient )

      RETURN NIL
   ENDIF
   oClient:nConnTimeout := 20000
   oClient:bUsePasv     := .T.

   // Comprobamos si el usuario contiene una @ para forzar el userid
   IF At( "@", cUser ) > 0
      oClient:oUrl:cServer   := cServer
      oClient:oUrl:cUserID   := cUser
      oClient:oUrl:cPassword := cPassword
   ENDIF

   IF oClient:Open()
      IF Empty( oClient:cReply )
         oClient:Pasv()
      ELSE
         oClient:Pasv()
      ENDIF
      ftp.button_4.enabled := .t.
      ftp.button_5.enabled := .f.
      ftp.button_6.enabled := .f.
      ftp.button_7.enabled := .f.
      ftp.button_3.enabled := .f.
      FTPFILLGRID()
   ELSE
      msgalert("Connection is not opened", "Alert")
   ENDIF

   RETURN NIL

FUNCTION FTPFILLGRID()

   LOCAL ctext, cSepChar, nPos, acDir, cLine, x, avalues, xpesq, xpos, cvalue, cvalue1
   LOCAL nX, cFileName, nDirImg

   ctext := oClient:List()
   oClient:reset()
   cSepChar := CRLF
   nPos := At( cSepChar, ctext )
   IF nPos == 0
      IF ! Empty( ctext )  // single line, just one file, THEREFORE there won't be any CRLF's!
         ctext += CRLF
      ELSE
         cSepChar := Chr(10)
      ENDIF
      nPos := At( cSepChar, ctext )
   ENDIF
   acDir := {}
   DO WHILE nPos > 0 &&.and. ! Eval( ::bAbort )
      cLine := AllTrim( Left( ctext, nPos - 1 ) )
      ctext := SubStr( ctext, nPos + Len( cSepChar ) )
      cLine := AllTrim( StrTran( cLine, Chr(0), "" ) )

      If( ! Empty( cLine ), AAdd( acDir, cLine ), Nil )

      nPos := At( cSepChar, ctext )
      DO EVENTS
   ENDDO

   ftp.Grid_2.DisableUpdate
   ftp.Grid_2.DeleteAllItems

   nPos := If( len(acDir)>0 .and. acDir[1]=="[..]", 2, 1 )
   FOR x = nPos to len(acDir)
      avalues := {}
      xpesq := alltrim(acDir[x])
      DO WHILE .t.
         xpos := at(' ',xpesq)
         IF xpos = 0
            aadd(avalues,xpesq)
            cFileName := ""
            FOR nX := 10 to len(avalues)
               cFileName += avalues[nX]+' '
            NEXT
            cFileName := If( substr(avalues[1],1,1) = 'l', substr(cFileName, 1, at('->', cFileName) - 1), rtrim(cFileName) )
            nDirImg := If( substr(avalues[1],1,1) = 'd', 0, 1 )
            ftp.Grid_2.AddItem( {nDirImg,cFileName,avalues[5],avalues[7]+'.'+ALLTRIM(STR(nMONTH(avalues[6])))+'.'+avalues[8],avalues[9],avalues[1]} )
            EXIT
         ENDIF
         cvalue := substr(xpesq,1,xpos-1)
         xpesq := Ltrim(substr(xpesq,xpos+1,len(xpesq)))
         IF len(avalues) < 7 .or. len(avalues) > 8
            aadd(avalues,cvalue)
         ELSE
            IF at(':',cvalue) > 0
               cvalue1 := alltrim(str(year(date())))
               aadd(avalues,cvalue1) && year
               aadd(avalues,cvalue)  && time
            ELSE
               aadd(avalues,cvalue) && year
               aadd(avalues,"")  && time
            ENDIF
         ENDIF
      ENDDO

   NEXT x

   ftp.Grid_2.EnableUpdate

   RETURN NIL

FUNCTION LOCALMKDIR()

   LOCAL cfile := INPUTBOX('NEW DIR NAME ?')

   createfolder(getcurrentfolder() + '\'+cfile)
   GetDirectory(getcurrentfolder() + '\*.*', 1)

   RETURN NIL

FUNCTION LOCALREN()

   LOCAL cFileOld := getcurrentfolder()+'\'+getcolvalue("GRID_1","FTP",2)
   LOCAL cFileNew := INPUTBOX('NEW FILE NAME ?')

   cFileNew := getcurrentfolder()+'\'+cFileNew
   RENAME (cFileOld) TO (cFileNew)
   GetDirectory(getcurrentfolder() + '\*.*', 1)

   RETURN NIL

FUNCTION LOCALDEL()

   LOCAL ctype
   LOCAL cFile := getcurrentfolder() + '\'+getcolvalue("GRID_1","FTP",2)

   IF .NOT. EMPTY(cFile)
      ctype := getcolvalue("GRID_1","FTP",3)
      IF alltrim(ctype) = '<DIR>'
         cfile := strtran(cfile,'[','')
         cfile := strtran(cfile,']','')
         removefolder(cfile)
      ELSE
         ERASE (cFile)
      ENDIF

      GetDirectory(getcurrentfolder() + '\*.*', 1)
   ENDIF

   RETURN NIL

FUNCTION FTPCWD()

   LOCAL lresp, cpath, cfolder
   LOCAL ctype := substr(getcolvalue("GRID_2","FTP",6),1,1)

   IF ctype = 'd'
      lresp :=  oClient:PWD
      cpath := oClient:cReply
      IF cpath == '/'
         cfolder := '/'+getcolvalue("GRID_2","FTP",2)
      ELSE
         cfolder := cpath+'/'+getcolvalue("GRID_2","FTP",2)
      ENDIF
      lresp := oClient:CWD(cfolder)
      FTPFILLGRID()
   ENDIF

   RETURN NIL

FUNCTION FTPCLOSE()

   LOCAL lresp := oClient:CLOSE()

   ftp.Grid_2.DeleteAllItems
   ftp.button_4.enabled := .f.
   ftp.button_5.enabled := .f.
   ftp.button_6.enabled := .f.
   ftp.button_7.enabled := .f.
   ftp.button_3.enabled := .t.

   RETURN NIL

FUNCTION FTPREN()

   LOCAL cFileOld := getcolvalue("GRID_2","FTP",2)
   LOCAL cFileNew := INPUTBOX('NEW FILE NAME ?')
   LOCAL lresp := oClient:RENAME( cFileOld,cFileNew )

   FTPFILLGRID()

   RETURN NIL

FUNCTION FTPMKDIR()

   LOCAL cFile := INPUTBOX('NEW DIR NAME ?')
   LOCAL lresp := oClient:MKD( cFile )

   FTPFILLGRID()

   RETURN NIL

FUNCTION FTPDEL()

   LOCAL ctype, lresp
   LOCAL cFile := getcolvalue("GRID_2","FTP",2)

   IF .NOT. EMPTY(cFile)
      ctype := substr(getcolvalue("GRID_2","FTP",6),1,1)
      IF ctype = 'd'
         lresp := oClient:RMD( cFile )
      ELSE
         lresp := oClient:Dele( cFile )
      ENDIF
      ftpfillgrid()
   ENDIF

   RETURN NIL

FUNCTION FTPDOWN()

   LOCAL lresp
   LOCAL cFile := getcolvalue("GRID_2","FTP",2)

   IF ftp.grid_1.cell(1,2) # '[..]'
      setcurrentfolder('c:\')
   ENDIF
   IF ISOBJECT(oClient)
      lresp := oClient:DownloadFile( cFile )
      GetDirectory(getcurrentfolder() + '\*.*', 1)
      IF valtype(lresp) = "L"
         IF lresp != .t.
            msgstop('Error was arised at downloading!')
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION FTPUP()

   LOCAL lresp
   LOCAL cFile := getcolvalue("GRID_1","FTP",2)
   LOCAL cFile1 := getcurrentfolder()+'\'+cFile

   IF ftp.grid_1.cell(1,2) # '[..]'
      cFile1 := 'C:\'+cFile
   ENDIF
   IF file(cFile1)
      IF ISOBJECT(oClient)
         //         oClient:TypeA()
         oClient:bUsePasv := .T.

         lresp := oClient:UploadFile( cFile1 )
         //         ftpfillgrid()

         IF valtype(lresp) = "L"
            IF lresp = .t.
               ftpfillgrid()
            ELSE
               msgstop('Error was arised at uploading!')
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION GetColValue( xObj, xForm, nCol )

   LOCAL nPos:= GetProperty(xForm, xObj, 'Value')
   LOCAL aRet:= GetProperty(xForm, xObj, 'Item', nPos)

   RETURN aRet[nCol]

FUNCTION initgrid()

   GetDirectory(aSubDirectory[1][1] + '\*.*', 1)
   lfirst := .f.

   RETURN NIL

FUNCTION nMonth(param)

   LOCAL RETVAL := 0

   IF upper(param) = 'JAN'
      RETVAL := 1
   ELSEIF upper(param) = 'FEB'
      RETVAL := 2
   ELSEIF upper(param) = 'MAR'
      RETVAL := 3
   ELSEIF upper(param) = 'APR'
      RETVAL := 4
   ELSEIF upper(param) = 'MAY'
      RETVAL := 5
   ELSEIF upper(param) = 'JUN'
      RETVAL := 6
   ELSEIF upper(param) = 'JUL'
      RETVAL := 7
   ELSEIF upper(param) = 'AUG'
      RETVAL := 8
   ELSEIF upper(param) = 'SEP'
      RETVAL := 9
   ELSEIF upper(param) = 'OCT'
      RETVAL := 10
   ELSEIF upper(param) = 'NOV'
      RETVAL := 11
   ELSEIF upper(param) = 'DEC'
      RETVAL := 12
   ENDIF

   return(RETVAL)

PROCEDURE Head_click( nCol )

   LOCAL nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value ), ;
      nOldCol := aSortCol[nGridFocus]

   IF nCol = 2
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[3]) # "N" .AND. valtype(b[3]) # "N", ;
         SUBSTR(a[2],2) < SUBSTR(b[2],2), if(valtype(a[3]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
   ELSEIF nCol = 3
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
   ELSEIF nCol = 4
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
   ELSEIF nCol = 5
      Asort(aDirectory[nGridFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], ;
         if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
   ENDIF

   IF nGridFocus = 1
      _SetGridCaption( "Grid_1", "FTP", nOldCol, ;
         Substr( ftp.Grid_1.Header(nOldCol), 2, Len(ftp.Grid_1.Header(nOldCol)) - 2 ), ;
         if(nOldCol=1, BROWSE_JTFY_LEFT, if(nOldCol=2, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
   ENDIF

   aSortCol[nGridFocus] := nCol

   IF nGridFocus = 1
      ftp.Grid_1.DisableUpdate
      ftp.Grid_1.DeleteAllItems
      Aeval(aDirectory[nGridFocus], {|e| ftp.Grid_1.AddItem( {if(valtype(e[2])="N", 0,1), e[1], ;
         if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
      _SetGridCaption( "Grid_1", "FTP", nCol, "[" + ftp.Grid_1.Header(nCol) + "]", if(nCol=2, BROWSE_JTFY_LEFT, if(nCol=3, BROWSE_JTFY_RIGHT, BROWSE_JTFY_CENTER )))
      ftp.Grid_1.Value := if(Empty(nPos), 1, nPos)
      ftp.Grid_1.EnableUpdate
   ENDIF

   RETURN

FUNCTION GetDirectory( cVar, nFocus )

   LOCAL aDir:= {}, aAux := {}, nSortCol
   LOCAL cDir, i := 1, j := 1

   cDir := Alltrim( cVar )
   aDir := Directory( cDir, 'D' )

   IF ( i := Ascan( aDir, {|e| Alltrim( e[1] ) = "."} ) ) > 0
      Adel( aDir, i )
      Asize( aDir, Len( aDir ) - 1 )
   ENDIF
   IF Len( aDir ) = 0
      AADD( aDir,  { "..", 0, Date(), Time() }  )
   ENDIF

   aDirectory[nFocus] := aDir

   FOR i = 1 to Len( aDirectory[nFocus] )

      FOR j = 1 TO Len( aDirectory[nFocus] )

         IF Lower( aDirectory[nFocus][i][1] ) <= Lower( aDirectory[nFocus][j][1] )

            IF SubStr( aDirectory[nFocus][i][1], 2, 1) <> '.' .AND. SubStr( aDirectory[nFocus][j][1], 2, 1) <> '.'

               aAux            := aDirectory[nFocus][i]
               aDirectory[nFocus][i]   := aDirectory[nFocus][j]
               aDirectory[nFocus][j]   := aAux
               aAux            := {}
            ENDIF
         ENDIF

      NEXT
   NEXT

   Aeval(aDirectory[nFocus], {|e| if(e[2] = 0 .AND. AT(".SWP", e[1]) = 0, (e[1] := "[" + UPPER(e[1]) + "]", e[2] := "<DIR>"), e[1] := LOWER(e[1]))})

   nSortCol := aSortCol[nFocus]
   IF nSortCol = 1
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[1] < b[1])))})
   ELSEIF nSortCol = 2
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[2] < b[2])))})
   ELSEIF nSortCol = 3
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N",  ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[3] < b[3])))})
   ELSE
      Asort(aDirectory[nFocus], , , {|a,b| if(valtype(a[2]) # "N" .AND. valtype(b[2]) # "N", ;
         SUBSTR(a[1],2) < SUBSTR(b[1],2), if(valtype(a[2]) # "N", SUBSTR(a[1],2) < CHR(254)+b[1], if(valtype(b[2]) # "N", CHR(254)+a[1] < SUBSTR(b[1],2), a[4] < b[4])))})
   ENDIF

   IF nFocus = 1
      ftp.Grid_1.DisableUpdate
      ftp.Grid_1.DeleteAllItems
      Aeval(aDirectory[nFocus], {|e| ftp.Grid_1.AddItem( {if(valtype(e[2])="N", 1,0), e[1], if(valtype(e[2])="N", STR(e[2]), e[2]), DTOC(e[3]), e[4] } )})
      ftp.Grid_1.Value := if(aBack[nFocus], aOldPos[nFocus][aNivel[nFocus]], 1)
      ftp.Grid_1.EnableUpdate

   ENDIF

   RETURN NIL

FUNCTION Verify()

   LOCAL nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value )
   LOCAL cDirectory := aSubDirectory[nGridFocus][1], i, cPath, cFile, cExt, cExe

   IF !Empty( nPos )
      IF Len( aDirectory[nGridFocus] ) > 0
         IF Alltrim(aDirectory[nGridFocus][ nPos, 1 ] ) <> '[..]' .AND. Valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N"
            aOldPos[nGridFocus][aNivel[nGridFocus]] := nPos
            aNivel[nGridFocus] ++
            aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := '\' + Substr(aDirectory[nGridFocus][ nPos, 1 ], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 1)

            FOR i = 2 TO aNivel[nGridFocus]
               cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
            NEXT
            setcurrentfolder(cdirectory)
            aBack[nGridFocus] := .f.
            GetDirectory( cDirectory + '\*.*', nGridFocus )

         ELSEIF ALLTRIM(aDirectory[nGridFocus][ nPos, 1 ] ) = '[..]'
            aSubDirectory[nGridFocus][ aNivel[nGridFocus] ] := ""
            IF aNivel[nGridFocus] > 1
               aNivel[nGridFocus] --
            ENDIF
            FOR i = 2 TO aNivel[nGridFocus]
               cDirectory += Substr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
            NEXT
            setcurrentfolder(cdirectory)
            aBack[nGridFocus] := .t.
            GetDirectory( cDirectory + '\*.*', nGridFocus )
         ELSE
            cPath := GetFull()
            cFile := GetName()
            cExt := GetExt()
            IF cExt = 'EXE' .or. cExt = 'BAT' .or. cExt = 'COM'
               _Execute ( 0, , cFile, , cPath, 5 )
            ELSE
               cExe := GetOpenCommand(cExt)
               IF !Empty(cExe)
                  cFile := cPath+'\'+cFile
                  _Execute ( 0, , cExe, IF(At(" ", cFile) > 0, '"'+cFile+'"', cFile), cPath, 5 )
               ELSE
                  MsgAlert( 'Error executing program!', "Alert" )
               ENDIF
            ENDIF
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION CurrentDirectory(param)

   LOCAL cPath := GetFull(), cName := GetName()
   LOCAL cText := cPath + '\' + cName

   IF param # NIL
      nGridFocus := param
   ENDIF
   IF nGridFocus = 1
      ftp.Label_3.Value := cText
   ENDIF

   RETURN NIL

FUNCTION GetExt()

   LOCAL cExtension := "", cFile := GetName()
   LOCAL nPosition  := Rat( '.', Alltrim(cFile) )

   IF nPosition > 0
      cExtension := SubStr( cFile, nPosition + 1, Len( Alltrim(cFile) ) )
   ENDIF

   RETURN Upper(cExtension)

FUNCTION GetName()

   LOCAL cText := "", nPos

   IF ( nPos := IF( nGridFocus = 1, ftp.Grid_1.Value, ftp.Grid_2.Value ) ) > 0
      cText:= IF( valtype(aDirectory[nGridFocus][ nPos, 2 ]) # "N", ;
         Substr(aDirectory[nGridFocus][ nPos, 1], 2, Len(aDirectory[nGridFocus][ nPos, 1 ]) - 2), ;
         aDirectory[nGridFocus][ nPos, 1] )
   ENDIF

   RETURN ALLTRIM( cText )

FUNCTION GetFull()

   LOCAL cText := aSubDirectory[nGridFocus][1], i

   FOR i = 2 TO aNivel[nGridFocus]
      cText += SubStr(aSubDirectory[nGridFocus][ i ], 1, Len(aSubDirectory[nGridFocus][ i ]) - 1)
   NEXT

   RETURN cText

STATIC FUNCTION GetOpenCommand( cExt )

   LOCAL oReg, cVar1 := "", cVar2 := "", nPos

   IF ! ValType( cExt ) == "C"

      RETURN ""
   ENDIF

   IF ! Left( cExt, 1 ) == "."
      cExt := "." + cExt
   ENDIF

   oReg := TReg32():New( HKEY_CLASSES_ROOT, cExt, .f. )
   cVar1 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) ) // i.e look for (Default) key
   oReg:close()

   IF ! Empty( cVar1 )
      oReg := TReg32():New( HKEY_CLASSES_ROOT, cVar1 + "\shell\open\command", .f. )
      cVar2 := RTrim( StrTran( oReg:Get( Nil, "" ), Chr(0), " " ) )  // i.e look for (Default) key
      oReg:close()

      IF ( nPos := RAt( " %1", cVar2 ) ) > 0        // look for param placeholder without the quotes (ie notepad)
         cVar2 := SubStr( cVar2, 1, nPos )
      ELSEIF ( nPos := RAt( '"%', cVar2 ) ) > 0     // look for stuff like "%1", "%L", and so forth (ie, with quotes)
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      ELSEIF ( nPos := RAt( '%', cVar2 ) ) > 0      // look for stuff like "%1", "%L", and so forth (ie, without quotes)
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      ELSEIF ( nPos := RAt( ' /', cVar2 ) ) > 0     // look for stuff like "/"
         cVar2 := SubStr( cVar2, 1, nPos - 1 )
      ENDIF
   ENDIF

   RETURN RTrim( cVar2 )

FUNCTION _SetGridCaption ( ControlName, ParentForm , Column , Value , nJustify )

   LOCAL i , h , t

   i := GetControlIndex ( ControlName, ParentForm )

   h := _HMG_aControlhandles [i]

   t := GetControlType ( ControlName, ParentForm )

   _HMG_aControlCaption [i] [Column] := Value

   IF t == 'GRID'
      SETGRIDCOLUMNHEADER ( h , Column , Value , nJustify )
   ENDIF

   RETURN NIL

PROCEDURE CreateTable

   LOCAL aDbf[4][4]
   FIELD NAME, ADDRESS, USER, PASSWORD

   aDbf[1][ DBS_NAME ] := "Name"
   aDbf[1][ DBS_TYPE ] := "Character"
   aDbf[1][ DBS_LEN ]  := 60
   aDbf[1][ DBS_DEC ]  := 0
   aDbf[2][ DBS_NAME ] := "Address"
   aDbf[2][ DBS_TYPE ] := "Character"
   aDbf[2][ DBS_LEN ]  := 100
   aDbf[2][ DBS_DEC ]  := 0
   aDbf[3][ DBS_NAME ] := "User"
   aDbf[3][ DBS_TYPE ] := "Character"
   aDbf[3][ DBS_LEN ]  := 60
   aDbf[3][ DBS_DEC ]  := 0
   aDbf[4][ DBS_NAME ] := "Password"
   aDbf[4][ DBS_TYPE ] := "Character"
   aDbf[4][ DBS_LEN ]  := 20
   aDbf[4][ DBS_DEC ]  := 0

   DBCREATE("Sites", aDbf)

   RETURN

FUNCTION Encrip(pepe)

   LOCAL pala:='', let, a, conv
   LOCAL enc:=len(pepe)

   FOR a=1 to enc
      let:=substr(pepe,a,1)
      conv:=asc(let)+100+a
      pala+=chr(conv)
   NEXT

   return(pala)

FUNCTION Desencri(pepe)

   LOCAL pala:='', let, a, conv
   LOCAL enc:=len(alltrim(pepe))

   FOR a=1 to enc
      let:=substr(pepe,a,1)
      conv:=asc(let)-100-a
      pala+=chr(conv)
   NEXT

   return(pala)
