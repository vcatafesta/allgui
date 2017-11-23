#include <minigui.ch>

STATIC cIniFile
STATIC ApplicPath
STATIC aPrg

FUNCTION Main

   LOCAL bColor := { |val| if ( val[4] == '+' , RGB( 255,255,255 ) , RGB( 255,255,128 ) ) }

   cIniFile:='ProjAn.ini'
   ApplicPath:=cFilePath( GetExeFileName() )
   aPrg:={}
   cIniFile:=ApplicPath+"\"+cIniFile

   SET AUTOADJUST ON NOBUTTONS

   LOAD WINDOW wMain
   //Center Window wMain
   ACTIVATE WINDOW wMain

   RETURN NIL

STATIC FUNCTION wInit()

   LOCAL p, s, cFile:='ProjAn.txt'

   BEGIN INI FILE cIniFile
      GET p SECTION "wMain" ENTRY "wMainRow" DEFAULT 130
      wMain.Row:=p
      GET p SECTION "wMain" ENTRY "wMainCol" DEFAULT 240
      wMain.Col:=p
      GET s SECTION "Tuning" ENTRY "PrjFile" DEFAULT ''
      wMain.txt_PrjFile.Value:=s
   END INI
   IF file(cFile)
      wMain.Edit_3.Value:=MEMOREAD(cFile)
   ELSE
      wMain.Edit_3.Value:='Description file "'+cFile+'" is not found'
   ENDIF

   RETURN NIL

STATIC FUNCTION wClose()

   LOCAL s

   BEGIN INI FILE cIniFile
      SET SECTION "wMain" ENTRY "wMainRow" TO wMain.Row
      SET SECTION "wMain" ENTRY "wMainCol" TO wMain.Col
      s:=wMain.txt_PrjFile.Value
      SET SECTION "Tuning" ENTRY "PrjFile" to s
   END INI

   RETURN NIL

STATIC FUNCTION GetPrjFile()

   LOCAL c_File := GetFile({{'Hpj File','*.hpj'}, ;
      {'Mpm File','*.mpm'}, {'Hbp File','*.hbp'}, {'All Files','*.*'}}, ;
      'Select a project file', wMain.txt_PrjFile.Value)

   SET DEFAULT to (ApplicPath)
   IF empty(c_File)

      RETURN NIL
   ENDIF
   wMain.txt_PrjFile.Value:=c_File
   //clear
   wMain.PrBar_1.Value:=0
   wMain.PrBar_2.Value:=0
   wMain.List_1.DeleteAllItems
   wMain.Grid_1.DeleteAllItems

   RETURN NIL
   #ifndef __XHARBOUR__
   #xtranslate At(<a>,<b>,[<x,...>]) => hb_At(<a>,<b>,<x>)
   #endif

FUNCTION Start()

   LOCAL txt, PrjPath, cFile, aFmg:={}, n:=1, n1, n2, nstr
   LOCAL fn, fs, t, s, i, j, k

   wMain.PrBar_1.Value:=0
   wMain.PrBar_2.Value:=0
   wMain.List_1.DeleteAllItems
   wMain.Grid_1.DeleteAllItems

   aPrg:={}
   IF Empty(wMain.txt_PrjFile.Value)

      RETURN NIL
   ENDIF
   IF !File(wMain.txt_PrjFile.Value)
      Msgbox('File "'+wMain.txt_PrjFile.Value+'" is not found')

      RETURN NIL
   ENDIF
   IF empty(txt:=MEMOREAD(wMain.txt_PrjFile.Value))
      Msgbox('File "'+wMain.txt_PrjFile.Value+'" is wrong or empty')

      RETURN NIL
   ENDIF
   PrjPath:=cFilePath(wMain.txt_PrjFile.Value)
   //select and creating list of modules
   DO WHILE (n1:=at(CRLF,txt,n))>0
      t:=Substr(txt,n,n1-n)
      IF '<ProjectFolder>\' $ t
         t := StrTran(t,'<ProjectFolder>\','')
      ENDIF
      IF '/ ' $ t
         t := StrTran(t,'/ ','')
      ENDIF
      IF upper(right(t,4))='.PRG'
         aAdd(aPrg,{t,{},{}})
      ENDIF
      IF upper(right(t,4))='.FMG'
         aAdd(aFmg,t)
      ENDIF
      n:=n1+2
   ENDDO
   t:=Substr(txt,n)
   IF '<ProjectFolder>\' $ t
      t := StrTran(t,'<ProjectFolder>\','')
   ENDIF
   IF '/ ' $ t
      t := StrTran(t,'/ ','')
   ENDIF
   IF upper(right(t,4))='.PRG'
      aAdd(aPrg,{t,{},{}})
   ENDIF
   IF upper(right(t,4))='.FMG'
      aAdd(aFmg,t)
   ENDIF
   //list of modules is create
   //first pass - create list of functions
   wMain.PrBar_1.RangeMax:=len(aPrg)
   wMain.PrBar_1.RangeMin:=0
   wMain.PrBar_1.Value:=0
   FOR i:=1 to len(aPrg)
      wMain.PrBar_1.Value:=wMain.PrBar_1.Value+1
      do events
      cFile:=PrjPath+"\"+aPrg[i,1]
      IF !File(cFile)
         Msgbox('File "'+cFile+'" is not found')

         RETURN NIL
      ENDIF
      IF empty(txt:=MEMOREAD(cFile))
         Msgbox('File "'+cFile+'" is wrong or empty')

         RETURN NIL
      ENDIF
      nstr:=0
      n:=1
      DO WHILE (n1:=at(CRLF,txt,n))>0
         nstr++
         s:=upper(Substr(txt,n,n1-n))
         IF len(t:=GetFuncName(s))>0 //function definition in this string
            aAdd(t,nstr)
            aAdd(t,'')
            aAdd(aPrg[i,2],t)
         ENDIF
         n:=n1+2
      ENDDO
      // find for forms by command Load window ...
      txt:=upper(txt)
      n:=1
      DO WHILE (n1:=at('LOAD WINDOW ',txt,n))>0
         n2:=at(CRLF,txt,n1) //end of string
         s:=Substr(txt,n1+12,n2-n1-12) //form name
         aAdd(aPrg[i,3],s)
         n:=n2
      ENDDO
   NEXT
   //list of functions is create
   //second pass - search for unused functions
   wMain.PrBar_2.RangeMax:=len(aPrg)
   wMain.PrBar_2.RangeMin:=0
   wMain.PrBar_2.Value:=0
   FOR i:=1 to len(aPrg)
      wMain.PrBar_2.Value:=wMain.PrBar_2.Value+1
      do events
      FOR j:=1 to len(aPrg[i,2]) //touching functions
         fn:=aPrg[i,2,j,1] //name
         fs:=aPrg[i,2,j,2] //static
         IF !empty(fs) //static - check only module and calling windows
            IF FindFunc(fn,fs,PrjPath+"\"+aPrg[i,1])
               aPrg[i,2,j,4]:='+'
            ELSE
               FOR k:=1 to len(aPrg[i,3])
                  IF FindFunc(fn,fs,PrjPath+"\"+aPrg[i,3,k]+'.FMG')
                     aPrg[i,2,j,4]:='+'
                     EXIT
                  ENDIF
               NEXT
            ENDIF
         ELSE //check for all modules and windows
            FOR n:=1 to len(aPrg)
               IF FindFunc(fn,fs,PrjPath+"\"+aPrg[n,1])
                  aPrg[i,2,j,4]:='+'
               ELSE
                  FOR k:=1 to len(aPrg[n,3])
                     IF FindFunc(fn,fs,PrjPath+"\"+aPrg[n,3,k]+'.FMG')
                        aPrg[i,2,j,4]:='+'
                        EXIT
                     ENDIF
                  NEXT
               ENDIF
            NEXT
         ENDIF
      NEXT
   NEXT
   //Bezel
   wMain.List_1.DeleteAllItems
   FOR i:=1 to len(aPrg)
      wMain.List_1.AddItem(aPrg[i,1])
   NEXT
   wMain.List_1.Value:=1
   List_1_Change()

   RETURN NIL

FUNCTION GetFuncName(s)

   LOCAL aRet:={}, n1, n2, f:='', f1:=''

   s:=alltrim(s)
   IF left(s,4)='STAT'
      IF (n1:=at(' ',s))>0
         f1:=left(s,n1-1)
         IF f1='STAT' .or. f1='STATI' .or. f1='STATIC'
            s:=alltrim(substr(s,n1))
         ENDIF
      ENDIF
   ENDIF
   IF left(s,4)='FUNC' .or. left(s,4)='PROC'
      IF (n1:=at(' ',s))>0
         s:=strtran(s,' (','(')
         IF (n2:=at('(',s,n1))>0
            f:=substr(s,n1+1,n2-n1)
         ENDIF
      ENDIF
   ENDIF
   IF !empty(f)
      aRet:={f,f1}
   ENDIF

   RETURN aRet

FUNCTION List_1_Change()

   LOCAL i, n:=wMain.List_1.Value

   IF n > 0
      wMain.Grid_1.DisableUpdate
      wMain.Grid_1.DeleteAllItems
      FOR i:=1 to len(aPrg[n,2])
         wMain.Grid_1.AddItem ( {aPrg[n,2,i,1]+')',;
            if(len(aPrg[n,2,i,2])>0,left(aPrg[n,2,i,2],1),' '), ;
            alltrim(str(aPrg[n,2,i,3])),aPrg[n,2,i,4]} )
      NEXT
      wMain.Grid_1.EnableUpdate
   ENDIF

   RETURN NIL

FUNCTION List_1_Enter()

   LOCAL n:=wMain.List_1.Value
   LOCAL PrjPath:=cFilePath(wMain.txt_PrjFile.Value)

   EXECUTE FILE '"'+PrjPath+"\"+aPrg[n,1]+'"'

   RETURN NIL

FUNCTION FindFunc(fn,fs,filename)

   LOCAL txt:=upper(MEMOREAD(filename)), n, n1, ok:=.f.

   fs:=nil
   fn:=upper(fn)
   DO WHILE at('  ',txt)>0 //delete double spaces
      txt:=STRTRAN(txt, '  ', ' ')
   ENDDO
   n:=1
   DO WHILE (n1:=at(fn,txt,n))>0
      IF at('FUNC '+fn,txt)=n1-5 .or. ;
            at('FUNCT '+fn,txt)=n1-6 .or. ;
            at('FUNCTI '+fn,txt)=n1-7 .or. ;
            at('FUNCTIO '+fn,txt)=n1-8 .or. ;
            at('FUNCTION '+fn, txt)=n1-9
         //omit - string with function definition
      ELSE
         ok:=.t.
         EXIT
      ENDIF
      n:=n1+len(fn)
   ENDDO

   RETURN ok
