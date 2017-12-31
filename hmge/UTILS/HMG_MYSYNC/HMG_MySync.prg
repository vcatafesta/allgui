/*
* Proyecto: MySync
* Descripción: Folders Synchronization
* Autor: Brunello Pulix
* Fecha: 12/24/2012
* Adapted and revised by Grigory Filatov <gfilatov@inbox.ru>
* 12/27/2012
*/
#include <hmg.ch>
#include <Directry.ch>
#define _NAME  1
#define _SIZE  2
#define _DATE  3
#define _TIME  4
STATIC lOpz
STATIC aOptions
STATIC abFunctions

FUNCTION Main

   LOCAL nType,nLimit

   REQUEST DBFCDX
   RDDSETDEFAULT( "DBFCDX" )
   SET DELETED ON
   SET BROWSESYNC ON
   lOpz        := .F.
   aOptions    := {}
   abFunctions := {}
   aadd(aOptions,'HBZipFile'         ); aadd(abFunctions,{|cFile,cOrigin| ZipWithHbZipFile(cFile,cOrigin) })
   aadd(aOptions,'HBZipArc with pass'); aadd(abFunctions,{|cFile,cOrigin| ZipWithHBZipArc(cFile,cOrigin) })
   aadd(aOptions,'7Zip'              ); aadd(abFunctions,{|cFile,cOrigin| ZipWith7Zip(cFile,cOrigin) })
   aadd(aOptions,'Windows Zip'       ); aadd(abFunctions,{|cFile,cOrigin| ZipWithShell(cFile,cOrigin) })
   aadd(aOptions,'CAB (only XP)'     ); aadd(abFunctions,{|cFile,cOrigin| ZipWithCab(STRTRAN(cFile,'.ZIP','.CAB'),cOrigin) })
   *aadd(aOptions,'XZIP'             ); aadd(abFunctions,{|cFile,cOrigin| ZipWithXZip(cFile,cOrigin) })
   IF !File("CFG.INI")
      PutIni('CFG.INI','setup','zip_limit',5)
      PutIni('CFG.INI','setup','zip_type' ,1)
   ENDIF
   OpenDbf()
   DEFINE WINDOW MAIN               ;
         WIDTH  840                       ;
         HEIGHT 550                       ;
         TITLE "Folders Synchronization"  ;
         MAIN                             ;
         ON RELEASE CloseDbf()
      DEFINE TAB Tab_1 AT 6,20 Width 795 Height 440
         DEFINE PAGE 'Planning'
            @ 45,20 BROWSE Grid_1 ;
               WIDTH  750         ;
               HEIGHT 320         ;
               HEADERS {'Active','Folders Origin','Folders Target','Type'} ;
               WIDTHS {50,300,300,50}           ;
               VALUE 1 ;
               ON DBLCLICK {|| Properties() };
               WORKAREA MySync ;
               FIELDS {;
               [if( Field->Active == .T. , 'ON' , 'OFF' )],;
               'Field->Origin',;
               'Target',;
               [if(Field->Flag2 == 0, 'INC',if(Field->Flag2 == 1,'FULL','ZIP') )]}
            JUSTIFY {BROWSE_JTFY_CENTER, BROWSE_JTFY_LEFT,BROWSE_JTFY_LEFT, BROWSE_JTFY_CENTER }
            @ 390,20  Button  NewButton  caption 'New Record'  Width 100 Height 30 Action {|| NewRecord() }
            @ 390,120 Button  PropButton caption 'Properties'  Width 100 Height 30 Action {|| Properties(.F.) }
            @ 390,220 Button  DelButton  caption 'Delete'      Width 100 Height 30 Action {|| DeleteRecord() }
            @ 390,320 Button  InvButton  caption 'Invert'      Width 100 Height 30 Action {|| Invert() }
            @ 390,420 Button  SortButton caption 'Sort DBF'    Width 100 Height 30 Action {|| SortDbf() }
         END PAGE
         DEFINE PAGE 'Backup'
            DEFINE PROGRESSBAR Progress_1
               ROW    45
               COL    20
               WIDTH  750
               HEIGHT 30
               RANGEMIN 1
               RANGEMAX 100
               VALUE 0
            END PROGRESSBAR
            DEFINE LISTBOX List_1
               ROW    75
               COL    20
               WIDTH  750
               HEIGHT 300
               ITEMS {""}
               VALUE 1
               SORT .F.
               FONTNAME 'Courier New'
            END LISTBOX
            DEFINE CHECKBOX Check_1
               ROW    380
               COL    20
               WIDTH  200
               HEIGHT 30
               CAPTION "delete files that no longer exist"
               VALUE .F.
            END CHECKBOX
            DEFINE CHECKBOX Check_2
               ROW    405
               COL    20
               WIDTH  200
               HEIGHT 30
               CAPTION "delete folders that no longer exist"
               VALUE .F.
            END CHECKBOX
            @ 390,548  Button  ClearButton caption 'Clear'  Width 100 Height 30 Action Main.List_1.DeleteAllItems()
            @ 390,668  Button  SaveButton  caption 'Save'   Width 100 Height 30 Action {|| SaveFolders() }
         END PAGE
         DEFINE PAGE 'Zip Folder'
            DEFINE PROGRESSBAR Progress_2
               ROW    45
               COL    20
               WIDTH  750
               HEIGHT 30
               RANGEMIN 1
               RANGEMAX 100
               VALUE 0
            END PROGRESSBAR
            DEFINE LISTBOX List_2
               ROW    75
               COL    20
               WIDTH  750
               HEIGHT 300
               ITEMS {""}
               VALUE 1
               SORT .F.
               ON DBLCLICK OpenZip()
            END LISTBOX
            @ 390,20   Button  RunButton     caption 'Open Folder'  Width 100 Height 30 Action {|| Openzip() }
            @ 390,120  Button  DeleteButton  caption 'Delete'       Width 100 Height 30 Action {|| DeleteFile() }
            @ 390,668  Button  SaveZipButton caption 'Compress'     Width 100 Height 30 Action {|| SaveZip() }
         END PAGE
         DEFINE PAGE 'Settings'
            DEFINE LABEL Label_1
               ROW    75
               COL    20
               WIDTH  100
               HEIGHT 20
               VALUE  "max zip files"
            END LABEL
            DEFINE LABEL Label_2
               ROW    75
               COL    140
               WIDTH  100
               HEIGHT 20
               VALUE  "Type zip"
            END LABEL
            DEFINE SPINNER Spinner_1
               ROW   95
               COL   20
               RANGEMIN 1
               RANGEMAX 10
               VALUE 5
               WIDTH 100
               HEIGHT 20
               INCREMENT 1
               On Change Change_Cfg(1)
            END SPINNER
            DEFINE LISTBOX List_3
               Row 95
               Col 140
               Items aOptions
               value 1
               Width 200
               On Change Change_Cfg(2)
            END ListBox
            DEFINE HYPERLINK H1
               ROW             370
               COL             25
               VALUE           'brunellopulix@yahoo.it'
               FONTNAME        'Arial'
               FONTSIZE        9
               AUTOSIZE        .T.
               ADDRESS         'brunellopulix@yahoo.it'
               HANDCURSOR      .T.
            END HYPERLINK
         END PAGE
      END TAB
      @ 460,690  Button  ExitButton  caption 'Exit'  Width 100 Height 30 Action {|| Thiswindow.Release }
   END WINDOW
   SetProperty('Main','List_1','Fontname','COURIER NEW')
   SetProperty('Main','List_2','Fontname','COURIER NEW')
   SetProperty('Main','List_3','Fontname','COURIER NEW')
   Fill_List_2()
   nlimit := GetIni('CFG.INI','setup','zip_limit',{|x| val(x) })
   nType  := GetIni('CFG.INI','setup','zip_type' ,{|x| val(x) })
   SetProperty('Main','Spinner_1','Value',nLimit)
   SetProperty('Main','List_3'   ,'Value',nType)
   lOpz := .T.
   InitWaitWindow()
   DoMethod('Main','Center')
   DoMethod('Main','Activate')

   RETURN NIL

PROCEDURE OpenDbf()

   LOCAL aDbf

   *Local obj
   MakeDir('DB')
   MakeDir('ZIP')
   IF !File('.\DB\MySync.Dbf')
      aDbf := {;
         {'ORIGIN','C',100,0},;
         {'TARGET','C',100,0},;
         {'ACTIVE','L',  1,0},;
         {'FLAG1' ,'L',  1,0},;
         {'FLAG2' ,'N',  1,0}}
      DBCREATE('.\DB\MySync.Dbf',aDbf,'DBFCDX')
   ENDIF
   DBUSEAREA(.T.,'DBFCDX','.\DB\MySync.Dbf','MySync',.F.)
   /*
   If !File('XZIP_REG.BAT')
   MemoWrit('XZIP_REG.BAT','Regsvr32.exe XZIP.DLL /S')
   Endif
   obj := CreateObject("WScript.Shell.1")
   If empty(obj:RegRead('HKLM\SOFTWARE\Classes\CLSID\{13D6BDE3-46AA-4FF2-A622-EBC43110D95C}\ProgID\'))
   obj:Run('XZIP_REG.BAT',2,.T.)
   Endif
   obj := nil
   */

   RETURN

PROCEDURE CloseDbf()

   dbclosearea('MySync')

   RETURN

PROCEDURE NewRecord()

   Properties(.T.)

   RETURN

PROCEDURE Properties(lNew)

   LOCAL cTitle,aTemp

   DEFAULT lNew To .F.
   IF !lNew .and. Eof()
      lNew := .T.
   ENDIF
   aTemp := array(4)
   IF lNew
      aTemp[1] := .F.
      aTemp[2] := Space(100)
      aTemp[3] := Space(100)
      aTemp[4] := 1
      cTitle := [New Record - Properties]
   ELSE
      aTemp[1] := MySync->Active
      aTemp[2] := Field->Origin
      aTemp[3] := Field->Target
      aTemp[4] := Field->Flag2+1
      cTitle := [Properties]
   ENDIF
   DEFINE WINDOW Win_2 AT 0,0 Width  540 Height 250 Title cTitle Modal
      @  20, 70  CheckBox Check_1  Caption 'Active' Value aTemp[1]
      @  50, 20  Label    Label_1  Value 'Origin'
      @  50, 70  TextBox  Text_1   Width 400 Height 20 Value aTemp[2]
      @  50,470  Button   Button_1  caption '...' Action Get_Folders(1)  Width 20 Height 20

      @  80, 20  Label    Label_2 Value 'Target'
      @  80, 70  TextBox  Text_2 Width 400 Height 20 Value aTemp[3]
      @  80,470  Button   Button_2  caption '...' Action Get_Folders(2) Width 20 Height 20
      @ 110,70   RadioGroup RadioGroup_1  ;
         Options {'incremental','full','zip'} value aTemp[4] Width 90 spacing 10 Horizontal ;
         On Change Change_RGroup()
      @ 150,275  Button   CancelButton  caption 'Cancel' Action Thiswindow.Release Width 100 Height 30
      @ 150,395  Button   SaveButton    caption 'Save'   Action SaveProperties(lNew) Width 100 Height 30
   END WINDOW
   DoMethod('Win_2','Center')
   DoMethod('Win_2','Activate')

   RETURN

PROCEDURE SaveProperties(lNew)

   LOCAL aTemp

   DEFAULT lNew To .F.
   aTemp := Array(4)
   aTemp[1] := Win_2.Check_1.Value
   aTemp[2] := Win_2.Text_1.Value
   aTemp[3] := Win_2.Text_2.Value
   aTemp[4] := Win_2.RadioGroup_1.Value
   ThisWindow.Release
   Main.SetFocus()
   IF Empty(aTemp[2]) .and. Empty(aTemp[3])

      RETURN
   ENDIF
   IF lNew
      dbappend()
   ENDIF
   REPLACE Active with aTemp[1]
   REPLACE Origin with aTemp[2]
   REPLACE Target with aTemp[3]
   REPLACE Flag2  with aTemp[4]-1
   Main.Grid_1.Refresh

   RETURN

PROCEDURE Get_Folders(Opz)

   LOCAL cFolder

   cFolder := GetFolder(If(Opz==1,'Origin','Target'))
   IF Empty(cFolder)

      RETURN
   ENDIF
   SetProperty('Win_2','Text_'+ntrim(Opz),'Value',cFolder)

   RETURN

PROCEDURE Change_RGroup()

   IF This.Value == 3 //.and. empty(Win_2.Text_2.Value)
      Win_2.Text_2.Value := workdir()+'ZIP'
   ENDIF

   RETURN

PROCEDURE DeleteRecord()

   LOCAL nRec1
   LOCAL nRec2

   IF MsgYesNo('Sure Confirm delete?','Alert!')
      nRec1 := RECNO()
      DBSKIP(-1)
      IF !BOF()
         nRec2 := RECNO()
      ELSE
         nRec2 := 0
      ENDIF
      DBGOTO(nRec1)
      IF DBRLOCK()
         DBDELETE()
         DBUNLOCK()
      ENDIF
      DBGOBOTTOM()
      IF nRec2 > 0
         DBGOTO(nRec2)
      ENDIF
      Main.Grid_1.Refresh
   ENDIF

   RETURN

PROCEDURE Invert()

   LOCAL c1
   LOCAL c2

   c1 := Field->Target
   c2 := Field->Origin
   IF MsgYesNo([Origin => ]+c1+CHR(10)+[Target => ]+c2+CHR(10)+[Duplicate and Reverse registration?],'Alert!')
      dbAppend()
      REPLACE Target with c2
      REPLACE Origin with c1
      Main.Grid_1.Refresh
   ENDIF

   RETURN

PROCEDURE SaveZip()

   LOCAL nRec

   Main.RunButton.Enabled      := .F.
   Main.DeleteButton.Enabled   := .F.
   Main.SaveZipButton.Enabled  := .F.
   Main.ExitButton.Enabled     := .F.
   nRec := Recno()
   dbGoTop()
   DO WHILE !Eof()
      IF Field->Active
         IF Field->Flag2 == 2
            Zippy()
         ENDIF
         REPLACE Active with .F.
      ENDIF
      dbskip()
   ENDDO
   dbgoto(nRec)
   Main.Grid_1.Refresh
   Main.RunButton.Enabled      := .T.
   Main.DeleteButton.Enabled   := .T.
   Main.SaveZipButton.Enabled  := .T.
   Main.ExitButton.Enabled     := .T.

   RETURN

PROCEDURE SaveFolders()

   LOCAL nRec
   LOCAL c1
   LOCAL i
   LOCAL a1

   Lock_Controls()
   Main.List_1.DeleteAllItems()
   nRec := Recno()
   dbGoTop()
   DO WHILE !Eof()
      IF Field->Active
         IF Field->Flag2 != 2
            IF !Empty(Field->Origin) .and. !Empty(Field->Target)
               a1 := StToAr(Trim(Field->Target),'\')
               c1 := a1[1]
               FOR i := 2 TO Len(a1)
                  c1 += '\'+a1[i]
                  MakeDir(c1)
               NEXT
               SaveFiles(;
                  Trim(Field->Origin),;
                  Trim(Field->Target),;
                  Field->Flag1,;
                  Main.Check_1.Value,;
                  Main.Check_2.Value)
            ENDIF
         ENDIF
         REPLACE Active with .F.
      ENDIF
      dbskip()
   ENDDO
   dbgoto(nRec)
   Main.Grid_1.Refresh
   UnLock_Controls()

   RETURN

PROCEDURE Out_List_1(c)

   Main.List_1.AddItem(c)
   Main.List_1.Value := Main.List_1.ItemCount

   RETURN

STATIC FUNCTION Scandir3(cDir,aRay,aPath)

   LOCAL i
   LOCAL a1
   LOCAL a2
   LOCAL nLen
   LOCAL c1

   nLen := Len(cDir)+1
   a1 := ReadDir3({cDir+'\'},aRay,nLen)
   FOR i := 1 TO Len(a1)
      c1 := SubStr(a1[i],nLen)
      c1 := Left(c1,Len(c1)-1)
      AAdd(aPath,c1)
   NEXT
   DO WHILE .T.
      a2 := ReadDir3(a1,aRay,nLen)
      IF Empty(a2)
         EXIT
      ENDIF
      a1 := AClone(a2)
      FOR i := 1 TO Len(a1)
         c1 := SubStr(a1[i],nLen)
         c1 := Left(c1,Len(c1)-1)
         AAdd(aPath,c1)
      NEXT
   ENDDO

   RETURN NIL

STATIC FUNCTION ReadDir3(a,aRay,nLen)

   LOCAL i
   LOCAL j
   LOCAL aDirTmp
   LOCAL aFiles

   aDirTmp := {}
   FOR j := 1 TO Len(a)
      aFiles := Directory(a[j]+'','DH')
      FOR i := 1 TO Len(aFiles)
         IF 'D' $ aFiles[i,F_ATTR].and. Left(aFiles[i,F_NAME],1) != '.'
            AAdd(aDirTmp,a[j]+aFiles[i,F_NAME]+'\')
         ELSEIF Left(aFiles[i,F_NAME],1) != '.'
            AAdd(aRay,{;
               SubStr(a[j]+aFiles[i,F_NAME],nLen),;
               aFiles[i,F_SIZE],;
               Val(DToS(aFiles[i,F_DATE])),;
               Secs(aFiles[i,F_TIME]),;
               .F.,;
               Val(DToS(aFiles[i,F_DATE])+StrZero(Secs(aFiles[i,F_TIME]),5))})
         ENDIF
      NEXT
   NEXT

   RETURN aDirTmp

PROCEDURE Fill_List_2()

   LOCAL aFiles,i,aTemp

   Main.List_2.DeleteAllItems()
   aTemp := {}
   aFiles := Directory(workdir()+'ZIP\*.*')
   IF !Empty(aFiles)
      asort(aFiles,,,{|x,y| x[1]<y[1]})
      FOR i := 1 To Len(aFiles)
         Main.List_2.AddItem(afiles[i,1])
         aadd(aTemp,{i,;
            Val(DToS(aFiles[i,F_DATE])+StrZero(Secs(aFiles[i,F_TIME]),5))})
      NEXT
      asort(aTemp,,,{|x,y| x[1]<y[1]})
      Main.List_2.Value := aTemp[Len(aTemp),1]
   ENDIF

   RETURN

PROCEDURE OpenZip()

   LOCAL cFile,nIndex

   nIndex := Main.List_2.Value
   cFile  := Main.List_2.Item(nIndex)
   EXECUTE FILE workdir()+'ZIP\'

   RETURN

PROCEDURE UnLock_Controls()

   Main.ClearButton.Enabled := .T.
   Main.SaveButton.Enabled  := .T.
   Main.Check_1.Enabled     := .T.
   Main.Check_2.Enabled     := .T.
   Main.Spinner_1.Enabled   := .T.
   Main.ExitButton.Enabled  := .T.

   RETURN

PROCEDURE Lock_Controls()

   Main.ClearButton.Enabled  := .F.
   Main.SaveButton.Enabled   := .F.
   Main.Check_1.Enabled      := .F.
   Main.Check_2.Enabled      := .F.
   Main.Spinner_1.Enabled    := .F.
   Main.ExitButton.Enabled   := .F.

   RETURN

PROCEDURE SortDbf()

   __dbPack()
   SORT TO ".\DB\_MySync.dbf" ON "Origin"
   __dbZap()
   APPEND From ".\DB\_MySync.dbf"
   FErase(WorkDir()+".\DB\_MySync.dbf")
   Main.Grid_1.Refresh

   RETURN

STATIC FUNCTION StToAr(cList,cDelim)

   LOCAL aArray := {}, nPos

   DO WHILE .T.
      nPos := AT( cDelim, cList )
      IF nPos > 0
         aadd( aArray, SubStr( cList, 1, nPos - 1 ))
         cList := SubStr( cList, nPos + 1 )
      ELSE
         EXIT
      ENDIF
   ENDDO
   aadd( aArray, cList )

   RETURN aArray

PROCEDURE SaveFiles(cSourge,cTarget,lForce,lFolders,lFiles)

   LOCAL aFolders1
   LOCAL aFolders2
   LOCAL n1
   LOCAL n2
   LOCAL i
   LOCAL a3
   LOCAL a4
   LOCAL a5
   LOCAL a6
   LOCAL a7
   LOCAL a7b
   LOCAL a3b
   LOCAL a8
   LOCAL a9
   LOCAL Tot1
   LOCAL Tot2
   LOCAL nDiskFree
   LOCAL nBytes
   LOCAL nToday
   LOCAL aSourge
   LOCAL aTarget
   LOCAL nPos
   LOCAL lChange

   DEFAULT lForce To .F.
   Main.List_1.DeleteAllItems()
   Out_List_1('TYPE BACKUP '+if(lForce,'FULL','INCREMENTAL'))
   Out_List_1('**********************************************')
   Out_List_1('Day..................: '+DToC(date())+' Time '+Time())
   Out_List_1('Folder Origin........: '+cSourge)
   Out_List_1('Folder Target........: '+cTarget)
   Out_List_1('**********************************************')
   aSourge     := {}
   aTarget     := {}
   Tot1        := 0
   Tot2        := 0
   a3          := {}
   a4          := {}
   a5          := {}
   a6          := {}
   a7          := {}
   a3b         := {}
   a7b         := {}
   a8          := {}
   a9          := {}
   aFolders1   := {}
   aFolders2   := {}
   nBytes      := 0
   nToday      := Val(DToS(date()))
   nDiskFree   := HB_DiskSpace(Left(cTarget,2))
   Out_List_1('Wait...data readings.......')
   n1 := 0
   n2 := 0
   Scandir3(cSourge,ASourge,aFolders1)
   Scandir3(cTarget,aTarget,aFolders2)
   FOR i := 1 TO Len(aFolders1)
      MakeDir(cTarget+aFolders1[i])
   NEXT
   Out_List_1('Check Changes to be made on Folder '+cTarget)
   Out_List_1('Wait...........')
   Main.Progress_1.RangeMin  :=  1
   Main.Progress_1.RangeMax  :=  Len(aSourge)
   Main.Progress_1.Value     :=  0
   FOR i := 1 TO Len(aSourge)
      Main.Progress_1.Value := i
      Tot2 += aSourge[i,_SIZE]
      nPos := AScan(aTarget,{|_a| Upper(_a[1]) == Upper(aSourge[i,_NAME]) })
      IF nPos == 0
         AAdd(a7,{cSourge+aSourge[i,1],cTarget+aSourge[i,1]})
         n1++
         Tot1 += aSourge[i,_SIZE]
      ELSE
         aTarget[nPos,5] := .T.
         lChange := .F.
         IF aSourge[I,6] > aTarget[nPos,6]
            lChange := .T.
         ENDIF
         IF lForce
            lChange := .T.
         ENDIF
         IF lChange
            AAdd(a3,{cSourge+aSourge[i,_NAME],cTarget+aSourge[i,_NAME]})
            n2++
            AAdd(a5,Str(ASourge[I,_SIZE],10)+'-'+Str(ASourge[I,_DATE],10)+'-'+Str(ASourge[I,_TIME],5)+'-'+ASourge[I,_NAME])
            AAdd(a5,Str(ATarget[nPos,_SIZE],10)+'-'+Str(ATarget[nPos,_DATE],10)+'-'+Str(ATarget[nPos,_TIME],5)+'-'+ATarget[nPos,_NAME])
         ENDIF
         ArrayDel(aTarget,nPos)
      ENDIF
   NEXT
   Main.Progress_1.Value     :=  0
   IF lFiles
      Out_List_1('Delete files that are no longer...')
      FOR i := 1 TO Len(aTarget)
         IF aTarget[i,5] == .F.
            IF File(cTarget+aTarget[i,1])
               AAdd(a4,cTarget+aTarget[i,1])
               FErase(cTarget+aTarget[i,1])
            ENDIF
         ENDIF
      NEXT
   ENDIF
   IF lFolders
      Out_List_1('Delete folders that are no longer...')
      FOR i := 1 TO Len(aFolders2)
         nPos := AScan(aFolders1,{|_a| Upper(_a) == Upper(aFolders2[i]) })
         IF nPos == 0
            AAdd(a6,cTarget+Upper(aFolders2[i]))
         ENDIF
      NEXT
      ASort(a6,,,{|x,y| Len(x) < Len(y) })
   ENDIF
   IF Empty(a3) .and. Empty(a7)
      IF !Empty(a4) .or. !Empty(a6)
         Out_List_1('**********Files Deleted**********')
         FOR i := 1 TO Len(a4)
            Out_List_1(a4[i])
         NEXT
         Out_List_1('**********Folders Deleted********')
         FOR i := Len(a6) TO 1 STEP -1
            IF DirRemove(a6[i]) == 0
               Out_List_1(a6[i])
            ENDIF
         NEXT
         Out_List_1('')
         Out_List_1('**********operation completed successfully!**********')
         Out_List_1('')
         Out_List_1('Day '+DToC(date())+' Time '+Time()+' - '+'Folder: '+cTarget)
      ELSE
         Out_List_1('No data to update the folder '+cTarget)
         Out_List_1('')
         Out_List_1('**********operation completed successfully!**********')
         Out_List_1('')
         Out_List_1('Day '+DToC(date())+' Time '+Time()+' - '+'Folder: '+cTarget)
      ENDIF
   ELSE
      IF nDiskFree < (Tot1-Tot2)
         MsgInfo('Insufficient space on Drive '+Left(cTarget,2))
      ELSE
         IF !Empty(a7)
            Out_List_1('Copy new files')
            Main.Progress_1.RangeMax := Len(a7)
            FOR i := 1 TO Len(a7)
               Main.Progress_1.Value := i
               CopyFileOK(a7[i,1],a7[i,2])
               IF File(a7[i,2])
                  Out_List_1(a7[i,2])
               ELSE
                  AAdd(a7b,a7[i,2])
               ENDIF
            NEXT
            Main.Progress_1.Value := 0
         ENDIF
         IF !Empty(a3)
            Out_List_1('Copy files changed')
            Main.Progress_1.Value    := 0
            Main.Progress_1.RangeMax := Len(a3)
            FOR i := 1 TO Len(a3)
               Main.Progress_1.Value := i
               CopyFileOK(a3[i,1],a3[i,2])
               IF File(a3[i,2])
                  Out_List_1(a3[i,2])
               ELSE
                  AAdd(a3b,a3[i,2])
               ENDIF
            NEXT
            Main.Progress_1.Value := 0
         ENDIF
         Out_List_1('**********New Files NOT Copied**********')
         FOR i := 1 TO Len(a7b)
            Out_List_1(a7b[i])
         NEXT
         Out_List_1('**********Files Changed NOT Copied**********')
         FOR i := 1 TO Len(a3b)
            Out_List_1(a3b[i])
         NEXT
         Out_List_1('**********Files Deleted**********')
         FOR i := 1 TO Len(a4)
            Out_List_1(a4[i])
         NEXT
         Out_List_1('**********Folders Deleted*******')
         FOR i := Len(a6) TO 1 STEP -1
            IF DirRemove(a6[i]) == 0
               Out_List_1(a6[i])
            ENDIF
         NEXT
         Out_List_1('')
         FOR i := 1 TO Len(a3)
            IF !File(a3[i,2])
               AAdd(a8,{a3[i,1],a3[i,2]})
            ENDIF
         NEXT
         FOR i := 1 TO Len(a7)
            IF !File(a7[i,2])
               AAdd(a8,{a7[i,1],a7[i,2]})
            ENDIF
         NEXT
         IF Empty(a8)
            Out_List_1('')
            Out_List_1('**********operation completed successfully!**********')
            Out_List_1('')
            Out_List_1('Day '+DToC(date())+' Time '+Time()+' - '+'Folder: '+cTarget)
         ELSE
            FOR i := 1 TO Len(a8)
               CopyFileOK(a8[i,1],a8[i,2])
            NEXT
            FOR i := 1 TO Len(a8)
               IF !File(a8[i,2])
                  AAdd(a9,a8[i,2])
               ENDIF
            NEXT
            Out_List_1('')
            Out_List_1('This files Have not been written to disk:')
            FOR i := 1 TO Len(a9)
               Out_List_1(a9[i])
            NEXT
            Out_List_1('')
            Out_List_1([**********it is advisable to repeat!**********])
            Out_List_1('')
            Out_List_1('Day '+DToC(date())+' Time '+Time()+' - '+'Folder: '+cTarget)
         ENDIF
      ENDIF
   ENDIF

   RETURN

FUNCTION CopyFileOK( src, dst )

   IF !('\' $ src)
      src := SET(_SET_DEFAULT) + '\' + src
   ENDIF
   IF !('\' $ dst)
      dst := SET(_SET_DEFAULT) + '\' + dst
   ENDIF

   RETURN __CopyFile( src, dst)

STATIC FUNCTION ArrayDel(aTarget,dwPosition)

   ADel(aTarget,dwPosition)
   ASize(aTarget,Len(aTarget)-1)

   RETURN aTarget

FUNCTION Ntrim(x)

   RETURN Ltrim(str(x))

FUNCTION workdir()

   RETURN GetStartupFolder()+'\'

PROCEDURE DeleteFile()

   LOCAL cFile,nIndex

   nIndex := Main.List_2.Value
   cFile  := Main.List_2.Item(nIndex)
   IF MsgYesNo('Sure Confirm delete?','Alert!')
      Ferase(workdir()+'ZIP\'+cFile)
      Fill_List_2()
   ENDIF

   RETURN

STATIC FUNCTION Scandir(cDir,aExclude,cOpz)

   LOCAL a1
   LOCAL a2
   LOCAL cString

   hb_Default(@cOpz,'S')
   hb_Default(@aExclude,{})
   IF Right(cDir,1) != '\'
      cDir += '\'
   ENDIF
   IF cOpz == 'A'
      cString := {}
   ELSE
      cString := ''
   ENDIF
   a1    := ReadDir({cDir},@cString,aExclude)
   DO WHILE .T.
      a2 := ReadDir(a1,@cString,aExclude)
      IF Empty(a2)
         EXIT
      ENDIF
      a1 := AClone(a2)
   ENDDO

   RETURN cString

STATIC FUNCTION ReadDir(a,cString,aExc)

   LOCAL i
   LOCAL j
   LOCAL aDirTmp
   LOCAL aFiles

   aDirTmp := {}
   FOR j := 1 TO Len(a)
      aFiles := Directory(a[j],'DH')
      FOR i := 1 TO Len(aFiles)
         IF 'D' $ aFiles[i,F_ATTR].and. Left(aFiles[i,F_NAME],1) != '.'
            AAdd(aDirTmp,a[j]+aFiles[i,F_NAME]+'\')
         ELSEIF Left(aFiles[i,F_NAME],1) != '.' .and. AScan(aExc,{|_1| Upper(Right(aFiles[i,F_NAME],Len(_1))) == Upper(_1) }) == 0
            IF ValType(cString) == 'A'
               AAdd(cString,a[j]+aFiles[i,F_NAME])
            ELSE
               cString += a[j]+aFiles[i,F_NAME]+' '
            ENDIF
         ENDIF
      NEXT
   NEXT

   RETURN aDirTmp

PROCEDURE Pack_Zips(cName,nLimit)

   LOCAL a1,aFiles,i,nMaxZip

   nMaxZip := nLimit
   a1 := {}
   aFiles := Directory(workdir()+'ZIP\*.ZIP')
   FOR i := 1 To Len(aFiles)
      IF upper(Left(aFiles[i,1],Len(cName))) == upper(cName)
         aadd(a1,afiles[i,1])
      ENDIF
   NEXT
   asort(a1,,,{|x,y|  x < y  })
   IF Len(a1) > nMaxZip
      DO WHILE .T.
         FErase(workdir()+'ZIP\'+a1[1])
         ADel(a1,1)
         ASize(a1,Len(a1)-1)
         IF Len(a1) == nMaxZip
            EXIT
         ENDIF
      ENDDO
   ENDIF

   RETURN

PROCEDURE Zippy()

   LOCAL cOrigin,cTarget,cName,cNum,cFile,nType,nLimit

   nlimit := GetIni('CFG.INI','setup','zip_limit',{|x| val(x) })
   nType  := GetIni('CFG.INI','setup','zip_type' ,{|x| val(x) })
   cOrigin := Trim(Field->Origin)
   cName   := SubStr(cOrigin,RAt('\',cOrigin)+1)
   cNum    := '_'+DToS(Date())+'_'+StrZero(Seconds(),5)
   cTarget := Trim(Field->Target)+'\'
   cFile := cTarget+cName+cNum+'.ZIP'
   eval(abFunctions[nType],cFile,cOrigin)
   Pack_Zips(cName,nLimit)
   Fill_List_2()

   RETURN

PROCEDURE ZipWithShell(cZip,cFolder)

   LOCAL obj,oFolder,n

   n := 1
   IF n == 1
      WAIT WINDOW '..........Compressing with Shell Window............' NOWAIT
      Make_Vbs(cZip,cFolder)
      obj := CreateObject("WScript.Shell.1")
      obj:Run('RUN.VBS',2,.T.)
      Ferase('RUN.VBS')
      WAIT CLEAR
   ELSE
      MemoWrit(cZip,"PK"+Chr(5)+Chr(6)+Replicate(Chr(0),18) )
      obj := CreateObject( "Shell.Application" )
      *obj:NameSpace( cZip ):CopyHere( obj:NameSpace( cFolder ):Items ,0x4)
      oFolder := obj:NameSpace( cZip )
      oFolder:CopyHere( obj:NameSpace( cFolder ):Items )
      DO WHILE obj:NameSpace( cZip ):Items:Count != obj:NameSpace( cFolder ):Items:Count
      ENDDO
   ENDIF

   RETURN

PROCEDURE ZipWithXZip(cZip,cFolder)

   LOCAL oZip,i,aFiles

   aFiles := Scandir(cFolder,{'.ZIP'},'A')
   Main.Progress_2.RangeMin := 1
   Main.Progress_2.RangeMax := len(aFiles)
   Main.Progress_2.Value    := 0
   oZip := CreateObject('XStandard.Zip.1')
   FOR i := 1 TO Len(aFiles)
      Main.Progress_2.Value := i
      oZip:pack( aFiles[i] ,cZip, .T. , , 5 )
   NEXT
   Main.Progress_2.Value := 0

   RETURN

PROCEDURE ZipWith7Zip(cZip,cFolder)

   LOCAL obj,cFiles,c7zip

   c7zip := '"'+GetProgramFilesFolder()+'\7-zip\7z.exe'+'"'
   IF !File(c7zip)
      c7zip := strtran(c7zip,' (x86)')
   ENDIF
   IF !File(c7zip)
      cFiles := Scandir(cFolder,{'.ZIP'},'C')
      WAIT WINDOW '..........Compressing With 7Zip............' NOWAIT
      Memowrit('Zip.Bat',c7zip+' a -r0 -tzip '+cZip+' '+cFiles)
      obj := CreateObject("WScript.Shell.1")
      obj:Run('ZIP.Bat',0,.T.)
      WAIT CLEAR
      Ferase('ZIP.BAT')
   ELSE
      MsgInfo('Error! 7Zip.exe Non Found!!')
   ENDIF

   RETURN

PROCEDURE ZipWithHBZipFile(cZip,cFolder)

   LOCAL aFiles

   aFiles := Scandir(cFolder,{'.ZIP'},'A')
   Main.Progress_2.RangeMin := 1
   Main.Progress_2.RangeMax := len(aFiles)
   Main.Progress_2.Value    := 0
   HB_ZipFile(cZip, aFiles, 8, {|cFile,nPos| Main.Progress_2.Value := nPos  },,,.T.,,)
   *[ <lSuccess> := ] hb_ZipFile( <zipfile> , <afiles> , <level> , <block> , <.ovr.> , <password> , <.srp.> , , <fileblock> )
   Main.Progress_2.Value    := 0

   RETURN

PROCEDURE ZipWithHBZipArc(cZip,cFolder)

   LOCAL aFiles

   aFiles := Scandir(cFolder,{'.ZIP'},'A')
   Main.Progress_2.RangeMin := 1
   Main.Progress_2.RangeMax := len(aFiles)
   Main.Progress_2.Value    := 0
   hb_ZipFile( cZip,aFiles,8,;
      {|cFile,nPos| Main.Progress_2.Value := nPos  },;
      .T.,'pass',.T.,.F.,,.T.,nil)
   Main.Progress_2.Value    := 0

   RETURN

PROCEDURE ZipWithCab(cCab,cFolder)

   LOCAL oCab,aFiles,i

   IF _HMG_IsXP
      aFiles := Scandir(cFolder,{'.ZIP'},'A')
      oCab := CreateObject("MakeCab.MakeCab.1")
      oCab:CreateCab(cCab,.F.,.F.,.F.)
      Main.Progress_2.RangeMin := 1
      Main.Progress_2.RangeMax := len(aFiles)
      Main.Progress_2.Value    := 0
      FOR i := 1 To Len(aFiles)
         Main.Progress_2.Value    := i
         oCab:AddFile(;
            aFiles[i]    ,;  // filename
            substr(aFiles[i],AT('\',aFiles[i])+1)) // folders+filename
      NEXT
      oCab:CloseCab()
      Main.Progress_2.Value    := 0
   ELSE
      MsgInfo('Error! Make CAB in XP only!!')
   ENDIF

   RETURN

PROCEDURE Make_Vbs(cZip,cFolder)

   LOCAL c1

   c1 := [Option Explicit]+CRLF
   c1 += []+CRLF
   c1 += [Dim arrResult]+CRLF
   c1 += []+CRLF
   c1 += [arrResult = ZipFolder( "]+cFolder+[", "]+cZip+[" )]+CRLF
   *  c1 += [If arrResult(0) <> 0 Then]+CRLF
   *  c1 += [    WScript.Echo "ERROR " & Join( arrResult, vbCrLf )]+CRLF
   *  c1 += [End If]+CRLF
   *  c1 += []+CRLF
   c1 += [Function ZipFolder( myFolder, myZipFile )]+CRLF
   c1 += [Dim objApp, objFSO, objTxt]+CRLF
   c1 += [Const ForWriting = 2]+CRLF
   c1 += [Const cDir = "BSEURO\"]+CRLF
   c1 += []+CRLF
   c1 += [If Right( myFolder, 1 ) <> "\" Then]+CRLF
   c1 += [   myFolder = myFolder & "\"]+CRLF
   c1 += [End If]+CRLF
   c1 += []+CRLF
   c1 += [On Error Resume Next]+CRLF
   c1 += []+CRLF
   c1 += [Set objFSO = CreateObject( "Scripting.FileSystemObject" )]+CRLF
   c1 += [Set objTxt = objFSO.OpenTextFile( myZipFile, ForWriting, True )]+CRLF
   c1 += [objTxt.Write "PK" & Chr(5) & Chr(6) & String( 18, Chr(0) )]+CRLF
   c1 += [objTxt.Close]+CRLF
   c1 += [Set objTxt = Nothing]+CRLF
   c1 += [Set objFSO = Nothing]+CRLF
   c1 += []+CRLF
   *  c1 += [If Err Then]+CRLF
   *  c1 += [   ZipFolder = Array( Err.Number, Err.Source, Err.Description )]+CRLF
   *  c1 += [   Err.Clear]+CRLF
   *  c1 += [   On Error Goto 0]+CRLF
   *  c1 += [   Exit Function]+CRLF
   *  c1 += [End If]+CRLF
   *  c1 += [    ]+CRLF
   c1 += [Set objApp = CreateObject( "Shell.Application" )]+CRLF
   c1 += [objApp.NameSpace( myZipFile ).CopyHere objApp.NameSpace( myFolder ).Items , 4]+CRLF
   *  c1 += [If Err Then]+CRLF
   *  c1 += [   ZipFolder = Array( Err.Number, Err.Source, Err.Description )]+CRLF
   *  c1 += [   Set objApp = Nothing]+CRLF
   *  c1 += [   Err.Clear]+CRLF
   *  c1 += [   On Error Goto 0]+CRLF
   *  c1 += [   Exit Function]+CRLF
   *  c1 += [End If]+CRLF
   c1 += []+CRLF
   c1 += [Do Until objApp.NameSpace( myZipFile ).Items.Count _]+CRLF
   c1 += [   = objApp.NameSpace( myFolder  ).Items.Count]+CRLF
   *  c1 += [   'WScript.Sleep 200]+CRLF
   c1 += [Loop]+CRLF
   c1 += [Set objApp = Nothing]+CRLF
   c1 += []+CRLF
   *  c1 += [If Err Then]+CRLF
   *  c1 += [   ZipFolder = Array( Err.Number, Err.Source, Err.Description )]+CRLF
   *  c1 += [   Err.Clear]+CRLF
   *  c1 += [   On Error Goto 0]+CRLF
   *  c1 += [   Exit Function]+CRLF
   *  c1 += [End If]+CRLF
   *  c1 += [On Error Goto 0]+CRLF
   *  c1 += [ZipFolder = Array( 0, "", "" )]+CRLF
   c1 += [End Function ]+CRLF
   MemoWrit('RUN.VBS',c1)

   RETURN

PROCEDURE Change_Cfg(n)

   IF lOpz
      IF n == 1
         PutIni('CFG.INI','setup','zip_limit',ntrim(Main.Spinner_1.Value))
      ELSE
         PutIni('CFG.INI','setup','zip_type' ,ntrim(Main.List_3.Value))
      ENDIF
   ENDIF

   RETURN

FUNCTION GetIni(cIniFile,cSectName,cParam,Opz)

   LOCAL i          := 0
   LOCAL cValue     := ""
   LOCAL cIni       := ""
   LOCAL cSect      := ""
   LOCAL nLen       := 0
   LOCAL xSect      := ""
   LOCAL nLines     := 0
   LOCAL cLine      := ""

   DEFAULT cIniFile To 'CFG.INI'
   IF !File(cIniFile)
      Memowrit(cInifile,"["+cSectName+']'+CRLF)
   ENDIF
   cIni      := MemoRead(cIniFile)
   cSect     := "["+upper(cSectName)+']'
   nLen      := Len(cParam)
   xSect     := ""
   nLines    := MLCount(cIni)
   FOR i := 1 TO nLines
      cLine := trim(MemoLine(cIni,120,i))
      IF Left(cLine,1) == '['
         xSect   := upper(cLine)
      ENDIF
      IF xSect == cSect
         IF upper(cLine) != xSect
            IF upper(Left(cLine,nLen)) == upper(cParam)
               cValue  := Substr(cLine,nLen+2)
            ENDIF
         ENDIF
      ENDIF
      IF !Empty(cValue)
         EXIT
      ENDIF
   NEXT
   IF Valtype(Opz) != 'NIL'
      IF Valtype(Opz) == 'B'
         cValue := Eval(Opz,cValue)
      ELSEIF Opz == 'N'
         cValue := val(cValue)
      ELSEIF Opz == 'D'
         cValue := ctod(cValue)
      ENDIF
   ENDIF

   RETURN cValue

FUNCTION PutIni(cIniFile,cSectName,cParam,xValue)

   LOCAL i          := 0
   LOCAL cNewValue  := ""
   LOCAL cIni       := ""
   LOCAL cSect      := ""
   LOCAL nLen       := 0
   LOCAL nLines     := 0
   LOCAL cLine      := ""
   LOCAL xSect      := ""
   LOCAL nHandle    := 0
   LOCAL OldSect    := ""
   LOCAL TempIni    := "~"+strzero(Seconds(),5)+'.$$$'

   DEFAULT cInifile To 'CFG.INI'
   IF valtype(xValue) == 'N'
      xValue := ntrim(xValue)
   ELSEIF valtype(xValue) == 'D'
      xValue := dtoc(xValue)
   ELSE
      xValue := trim(xValue)
   ENDIF
   IF !File(cIniFile)
      MemoWrit(cInifile,"["+cSectName+']'+CRLF)
   ENDIF
   cIni      := MemoRead(cIniFile)
   cSect     := "["+upper(cSectName)+']'
   cNewValue := cParam+'='+xValue
   nLen      := Len(cParam)
   xSect     := ""
   OldSect   := ""
   nHandle   := FCreate(TempIni,0)
   nLines    := MLCount(cIni)
   FOR i := 1 TO nLines
      cLine := trim(MemoLine(cIni,120,i))
      IF Left(cLine,1) == '[' .or. empty(cLine)  && Inizio o termine Sezione
         IF (!empty(cNewValue) .and. !Empty(OldSect)) .and. xSect == cSect
            // aggiunge il parametro se non Š stato ancora aggiunto
            // se non Š ancora all'inizio
            // e la Sezione corrisponde a quella prevista
            FWrite(nHandle,cNewValue+CRLF)
            // svuota la variabile
            cNewValue := ""
            IF !empty(cLine)
               // aggiunge una riga vuota
               FWrite(nHandle,CRLF)
            ENDIF
         ENDIF
         IF empty(cLine)
            FWrite(nHandle,CRLF)
            LOOP
         ELSE
            OldSect := xSect         && Sezione precedente
            xSect   := upper(cLine)  && Nuova Sezione
         ENDIF
      ENDIF
      IF xSect == cSect
         IF cLine != xSect
            IF upper(Left(cLine,nLen)) == upper(cParam)
               // modifica il valore
               cLine     := Left(cLine,nLen+1)+xValue
               // svuota la variabile
               cNewValue := ""
            ENDIF
         ENDIF
      ENDIF
      // riscrive la riga
      FWrite(nHandle,cLine+CRLF)
   NEXT
   IF !empty(cNewValue)
      IF xSect != cSect
         // Sezione diversa e quindi NON esistente
         // la aggiunge
         FWrite(nHandle,CRLF+"["+cSectName+']' +CRLF)
      ENDIF
      // aggiunge il parametro
      FWrite(nHandle,cNewValue+CRLF)
   ENDIF
   FClose(nHandle)
   Ferase(cIniFile)
   Frename(TempIni,cIniFile)

   RETURN NIL

FUNCTION InitWaitWindow()

   DEFINE WINDOW _HMG_CHILDWAITWINDOW ;
         AT   0,0   ;
         WIDTH   500   ;
         HEIGHT   40   ;
         TITLE   ''   ;
         CHILD      ;
         NOSHOW      ;
         NOSYSMENU   ;
         NOCAPTION

      DEFINE LABEL Message
         ROW      5
         COL      10
         WIDTH      480
         HEIGHT      25
         VALUE      ''
         CENTERALIGN   .T.
      END LABEL

   END WINDOW

   _HMG_CHILDWAITWINDOW.CENTER

   RETURN NIL

FUNCTION ShowWaitWindow( cMessage )

   _HMG_CHILDWAITWINDOW.MESSAGE.VALUE := cMessage

   _HMG_CHILDWAITWINDOW.SHOW

   RETURN NIL

FUNCTION HideWaitWindow()

   _HMG_CHILDWAITWINDOW.HIDE

   RETURN NIL

FUNCTION WaitWindow ( cMessage , lNoWait )

   IF pcount() > 0

      IF ValType ( lNoWait ) == 'L'

         IF   lNoWait == .T.

            ShowWaitWindow( cMessage )

         ENDIF

      ENDIF

   ELSE

      HideWaitWindow()

   ENDIF

   RETURN NIL
