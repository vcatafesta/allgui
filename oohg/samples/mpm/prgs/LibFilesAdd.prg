/*
* $Id: LibFilesAdd.prg,v 1.1 2013/11/18 20:40:25 migsoft Exp $
*/

#include "oohg.ch"

PROCEDURE AddLibfiles

   LOCAL Files , x , i , Exists

   DECLARE WINDOW main
   DECLARE WINDOW MigMess

   Files :=  GetLibFiles( )
   FOR x := 1 To Len ( Files )
      DO EVENTS
      Exists := .F.
      FOR i := 1 To main.List_2.ItemCount
         DO EVENTS
         IF Upper(alltrim(Files [x])) == Upper(alltrim(main.List_2.Item(i)))
            Exists := .T.
            EXIT
         ENDIF
      NEXT i
      IF .Not. Exists
         main.List_2.AddItem ( Files [x] )
      ENDIF
   NEXT x

   RETURN

FUNCTION GetLibFiles()

   LOCAL RetVal := {} , LibFolder

   IF Empty ( main.text_1.Value )
      MsgStop('You must select project base folder first','')

      RETURN ( {} )
   ENDIF

   cDirOld := GetCurrentFolder() // NIL
   cDirNew := GetFolder("Folder:",cDirOld)

   IF !Empty(cDirNew)
      cDirOld  :=cDirNew

      IF (main.RadioGroup_6.value = 1)
         aFiles :=DIRECTORY(cDirNew + "\" +"*.a")
         AEVAL(aFiles,{|x,y| aFiles[y] :=cDirNew + "\" + x[1]})
      ELSE
         aFiles :=DIRECTORY(cDirNew + "\" +"*.Lib")
         AEVAL(aFiles,{|x,y| aFiles[y] :=cDirNew + "\" + x[1]})
      ENDIF

      IF Len(aFiles)>0

         aFiles :=ASORT(aFiles,{|x,y| UPPER(x) < UPPER(y)})

         DEFINE WINDOW GetLibFiles AT 0,0 WIDTH 533 HEIGHT 384 TITLE 'Select LIB Files' ;
               ICON "ampm" MODAL NOMINIMIZE NOMAXIMIZE NOSIZE BACKCOLOR {255,255,255}

            DEFINE FRAME Frame_21
               ROW    0
               COL    10
               WIDTH  508
               HEIGHT 344
               OPAQUE .T.
            END FRAME

            DEFINE LISTBOX List_Lib
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
               ONCLICK  ( RetVal := GetLibFilesOk( aFiles , GetLibFiles.List_Lib.Value ) , GetLibFiles.Release )
            END BUTTON

            DEFINE BUTTON OK
               ROW 310
               COL 310
               WIDTH  100
               HEIGHT 28
               CAPTION  'Ok'
               ONCLICK  ( RetVal := GetLibFilesOk( aFiles , GetLibFiles.List_Lib.Value ) , GetLibFiles.Release )
            END BUTTON

            DEFINE BUTTON CANCEL
               ROW    310
               COL    410
               WIDTH  100
               HEIGHT 28
               CAPTION "Cancel"
               ONCLICK  ( RetVal := {} , GetLibFiles.Release )
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

         CENTER WINDOW GetLibFiles
         GetLibFiles.Ok.Setfocus
         ACTIVATE WINDOW GetLibFiles

      ELSE
         MsgInfo("(*.Lib or *.a ) Files not found","Libraries files")
         RetVal := {}
      ENDIF

   ENDIF

   RETURN ( RetVal )

FUNCTION GetLibFilesOk( aFiles , aSelected )

   LOCAL aNew := {} , i

   IF Empty( aSelected )
      aNew := aFiles
   ELSE
      FOR i := 1 To Len ( aSelected )
         DO EVENTS
         aadd ( aNew , aFiles [ aSelected [i] ] )
      NEXT i
   ENDIF

   RETURN( aNew )

PROCEDURE RemoveLibFile()

   LOCAL a_Mig := main.List_2.value

   IF !Empty(a_Mig)
      IF MsgYesNo('Remove File(s) ' + UPPER( main.List_2.Item( main.List_2.Value ) ) + ' From Project ?','Confirm')
         WHILE Len(a_Mig) > 0
            main.List_2.DeleteItem( a_Mig[ 1 ] )
            a_Mig := main.List_2.value
         ENDDO
      ENDIF
      IF main.list_2.ItemCount > 0
         main.List_2.value := {1}
      ENDIF
   ENDIF

   RETURN

