/*
* $Id: PrgFilesAdd.prg
* (c) migsoft 2013-11-18
*/

#include "oohg.ch"
#include "mpm.ch"

PROCEDURE Addprgfiles

   LOCAL Files , x , i , Exists

   DECLARE WINDOW main
   DECLARE WINDOW MigMess

   Files :=  GetPrgFiles( )
   FOR x := 1 To Len ( Files )
      DO EVENTS
      Exists := .F.
      FOR i := 1 To main.List_1.ItemCount
         DO EVENTS
         IF Upper(alltrim(Files [x])) == Upper(alltrim(main.List_1.Item(i)))
            Exists := .T.
            EXIT
         ENDIF
      NEXT i
      IF .Not. Exists
         main.List_1.AddItem ( Files [x] )
      ENDIF
   NEXT x

   RETURN

FUNCTION GetPrgFiles()

   LOCAL RetVal := {} , BaseFolder, aFiles := {}

   IF Empty ( main.text_1.Value )
      MsgStop('You must select project base folder first','')
      RETURN ( {} )
   ENDIF

   cDirOld := GetCurrentFolder() //NIL
   cDirNew := GetFolder("Folder:",cDirOld)

   IF !EMPTY(cDirNew)
      cDirOld  :=cDirNew
      aFiles :=DIRECTORY(cDirNew + "\" +"*.PRG")
      AEVAL(aFiles,{|x,y| aFiles[y] :=cDirNew + "\" + x[1]})

      IF Len(aFiles)>0

         aFiles :=ASORT(aFiles,{|x,y| UPPER(x) < UPPER(y)})

         DEFINE WINDOW GetPrgFiles AT 0,0 WIDTH 533 HEIGHT 384 TITLE 'Select PRG Files' ;
               ICON "ampm" MODAL NOMINIMIZE NOMAXIMIZE NOSIZE BACKCOLOR {255,255,255}

            DEFINE FRAME Frame_21
               ROW    0
               COL    10
               WIDTH  508
               HEIGHT 344
               OPAQUE .T.
            END FRAME

            DEFINE LISTBOX List_prg
               ITEMS aFiles
               ROW   20
               COL   20
               WIDTH 490
               HEIGHT 284
               FONTNAME "Segoe UI"
               ONGOTFOCUS This.BackColor := {211,237,250}
               ONLOSTFOCUS This.BackColor := {255,255,225}
               BACKCOLOR {255,255,225}
               MULTISELECT   .T.
            END LISTBOX

            DEFINE BUTTON ALL
               ROW 310
               COL 210
               WIDTH  100
               HEIGHT 28
               CAPTION  'All'
               ONCLICK  ( RetVal := GetPrgFilesOk( aFiles , GetPrgFiles.List_prg.Value ) , GetPrgFiles.Release )
            END BUTTON

            DEFINE BUTTON OK
               ROW 310
               COL 310
               WIDTH  100
               HEIGHT 28
               CAPTION  'Ok'
               ONCLICK  ( RetVal := GetPrgFilesOk( aFiles , GetPrgFiles.List_prg.Value ) , GetPrgFiles.Release )
            END BUTTON

            DEFINE BUTTON CANCEL
               ROW    310
               COL    410
               WIDTH  100
               HEIGHT 28
               CAPTION "Cancel"
               ONCLICK  ( RetVal := {} , GetPrgFiles.Release )
            END BUTTON

            DEFINE LABEL Label_1
               ROW    315
               COL    40
               WIDTH  120
               HEIGHT 24
               VALUE "Select ( Ctrl + Click )"
               TRANSPARENT .T.
            END LABEL

         END WINDOW

         CENTER WINDOW GetPrgFiles
         GetPrgFiles.Ok.Setfocus
         ACTIVATE WINDOW GetPrgFiles

      ELSE
         MsgInfo("PRG Files not found","PRG Files")
         RetVal := {}
      ENDIF

   ENDIF

   RETURN ( RetVal )

FUNCTION GetPrgFilesOk( aFiles , aSelected )

   LOCAL aNew := {} , i

   IF Empty( aSelected )
      aNew := aFiles
   ELSE
      FOR i := 1 To Len ( aSelected )
         DO EVENTS
         aadd ( aNew , aFiles [ aSelected [i] ] )
      NEXT i
   ENDIF

   RETURN ( aNew )

PROCEDURE RemoveFilePrg()

   LOCAL a_Mig := main.List_1.value

   IF !Empty(a_Mig)
      IF MsgYesNo('Remove File(s) ' + UPPER( main.List_1.Item( main.List_1.Value ) ) + ' From Project ?','Confirm')
         WHILE Len(a_Mig) > 0
            main.List_1.DeleteItem( a_Mig[ 1 ] )
            a_Mig := main.List_1.value
         ENDDO
      ENDIF
      IF main.list_1.ItemCount > 0
         main.List_1.value := {1}
      ENDIF
   ENDIF

   RETURN
