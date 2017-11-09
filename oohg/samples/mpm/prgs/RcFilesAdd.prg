/*
* $Id: RcFilesAdd.prg,v 1.1 2013/11/18 20:40:25 migsoft Exp $
*/

#include "oohg.ch"

PROCEDURE AddRcfiles

   LOCAL Files , x , i , Exists

   DECLARE WINDOW main
   DECLARE WINDOW MigMess

   Files :=  GetRcFiles( )
   FOR x := 1 To Len ( Files )
      DO EVENTS
      Exists := .F.
      FOR i := 1 To main.List_4.ItemCount
         DO EVENTS
         IF Upper(alltrim(Files [x])) == Upper(alltrim(main.List_4.Item(i)))
            Exists := .T.
            EXIT
         ENDIF
      NEXT i
      IF .Not. Exists
         main.List_4.AddItem ( Files [x] )
      ENDIF
   NEXT x

   RETURN

FUNCTION GetRcFiles()

   LOCAL RetVal := {} , BaseFolder, aFiles := {}

   IF Empty ( main.text_1.Value )
      MsgStop('You must select project base folder first','')

      RETURN ( {} )
   ENDIF

   cDirOld := GetCurrentFolder() // NIL
   cDirNew := GetFolder("Folder:",cDirOld)

   IF !EMPTY(cDirNew)
      cDirOld  :=cDirNew
      aFiles :=DIRECTORY(cDirNew + "\" +"*.RC")
      AEVAL(aFiles,{|x,y| aFiles[y] :=cDirNew + "\" + x[1]})

      aFiles :=ASORT(aFiles,{|x,y| UPPER(x) < UPPER(y)})

      DEFINE WINDOW GetRcFiles AT 0,0 WIDTH 533 HEIGHT 384 TITLE 'Select RC Files' ;
            ICON "mpm" MODAL NOMINIMIZE NOMAXIMIZE NOSIZE BACKCOLOR {255,255,255}

         DEFINE FRAME Frame_21
            ROW    0
            COL    10
            WIDTH  508
            HEIGHT 344
            OPAQUE .T.
         END FRAME

         DEFINE LISTBOX List_rc
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
            ONCLICK  ( RetVal := GetRcFilesOk( aFiles , GetRcFiles.List_rc.Value ) , GetRcFiles.Release )
         END BUTTON

         DEFINE BUTTON OK
            ROW 310
            COL 310
            WIDTH  100
            HEIGHT 28
            CAPTION  'Ok'
            ONCLICK  ( RetVal := GetRcFilesOk( aFiles , GetRcFiles.List_rc.Value ) , GetRcFiles.Release )
         END BUTTON

         DEFINE BUTTON CANCEL
            ROW    310
            COL    410
            WIDTH  100
            HEIGHT 28
            CAPTION "Cancel"
            ONCLICK  ( RetVal := {} , GetRcFiles.Release )
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

      CENTER WINDOW GetRcFiles
      GetRcFiles.Ok.Setfocus
      ACTIVATE WINDOW GetRcFiles

   ELSE
      MsgInfo("RC Files not found","RC Files")
      RetVal := {}
   ENDIF

   RETURN ( RetVal )

FUNCTION GetRcFilesOk( aFiles , aSelected )

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

PROCEDURE RemoveFileRc()

   LOCAL a_Mig := main.List_4.value

   IF !Empty(a_Mig)
      IF MsgYesNo('Remove File(s) ' + UPPER( main.List_4.Item( main.List_4.Value ) ) + ' From Project ?','Confirm')
         WHILE Len(a_Mig) > 0
            main.List_4.DeleteItem( a_Mig[ 1 ] )
            a_Mig := main.List_4.value
         ENDDO
      ENDIF
      IF main.list_4.ItemCount > 0
         main.List_4.value := {1}
      ENDIF
   ENDIF

   RETURN

