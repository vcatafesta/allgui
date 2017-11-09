#include 'hmg.ch'

MEMVAR nPage
MEMVAR aItems
MEMVAR cPage
MEMVAR cText
MEMVAR cLabel
MEMVAR cCombo

FUNCTION Main

   LOCAL nWidthWindow  := int(( GetDesktopWidth()  / 2 ))
   LOCAL nHeightWindow := int(( GetDesktopHeight() / 2 ))
   LOCAL cUser         := "User : "    + getenv("UserName")
   LOCAL cPc           := "Station : " + getenv("ComputerName")
   LOCAL i

   PUBLIC nPage        := 0
   PUBLIC aItems       := {}
   PUBLIC cPage        := "Page"  + ltrim(str(nPage))
   PUBLIC cText        := "Text"  + ltrim(str(nPage))
   PUBLIC cLabel       := "Label" + ltrim(str(nPage))
   PUBLIC cCombo       := "Combo" + ltrim(str(nPage))

   FOR i=1 to 1000
      aadd(aItems, "$" + ltrim(str(i)))
   NEXT

   SET NAVIGATION EXTENDED
   SET MENUSTYLE EXTENDED
   SetMenuBitmapHeight( BmpSize( "delete.bmp" )[ 1 ] )

   DEFINE WINDOW Principal                        ;
         AT 0, 0                             ;
         WIDTH nWidthWindow                  ;
         HEIGHT nHeightWindow                ;
         TITLE "Example of using Method AddPage, AddControl and BackColor in TAB" ;
         ICON "pc.ico"                       ;
         ON SIZE  SizeTest()                 ;
         ON INIT AddNewPage()                ;
         ON MOUSECLICK AddNewPage()          ;
         NOMAXIMIZE                          ;
         MAIN                                ;
         BACKCOLOR TEAL

      DEFINE TAB Container_Tab                   ;
            AT 2, 2                             ;
            WIDTH  Principal.Width  - 10        ;
            HEIGHT Principal.Height - 60        ;
            VALUE 1                             ;
            FONT "Arial"                        ;
            SIZE 9                              ;
            ON CHANGE AddNewPage()              ;
            HOTTRACK                            ;
            BACKCOLOR TEAL
      END TAB

      DEFINE STATUSBAR
         STATUSITEM cPC   WIDTH 100 ICON "pc.ico"
         STATUSITEM cUser WIDTH 300 ICON "User.ico"
      END STATUSBAR

      DEFINE CONTEXT MENU
         MENUITEM "Delete Select Page" ACTION DeletePage() NAME delete IMAGE "delete.bmp"
      END MENU

   END WINDOW

   Principal.Center
   Principal.Activate

   RETURN NIL

PROCEDURE DeletePage()

   LOCAL nDelete

   nDelete:= Principal.Container_Tab.Value
   cLabel := "Label" + ltrim(str(nDelete))
   cText  := "Text"  + ltrim(str(nDelete))
   cCombo := "Combo" + ltrim(str(nDelete))

   IF nDelete == Principal.Container_Tab.ItemCount - 1 .and. iscontroldefined(&cLabel,Principal)
      Principal.&(cLabel).Release
      Principal.&(cText).Release
      Principal.&(cCombo).Release
      Principal.Container_Tab.DeletePage(nDelete)
      nPage--
      IF nPage == 1
         AddNewPage()
      ENDIF
   ELSE
      MsgInfo( "No se puede borrar el PAGE '"+Principal.Container_Tab.Caption(nDelete)+"'", "   Info  " )
   ENDIF

   RETURN

FUNCTION AddNewPage()

   IF nPage == 1
      cPage := 'Page'+ltrim(str(nPage))
      Principal.Container_Tab.AddPage ( nPage, cPage )
      AddControls()
      nPage++
      Principal.Container_Tab.Value := nPage - 1

      RETURN NIL
   ENDIF

   IF Principal.Container_Tab.Value == nPage
      IF nPage >= 2
         cPage := 'Page'+ltrim(str(nPage))
         Principal.Container_Tab.DeletePage(nPage)
         Principal.Container_Tab.AddPage ( nPage, cPage )
         AddControls()
         nPage++
         Principal.Container_Tab.AddPage ( nPage, 'Add+', 'New.bmp', 'Click over Add+ add new Page' )
         Principal.Container_Tab.Value  := nPage - 1
      ELSE
         nPage++
         cPage := 'Page'+ltrim(str(nPage))
         Principal.Container_Tab.AddPage ( nPage, cPage )
         AddControls()
         nPage++
         Principal.Container_Tab.AddPage ( nPage, 'Add+', 'New.bmp', 'Click over Add+ add new Page' )
         Principal.Container_Tab.Value  := 1
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION AddControls()

   cLabel := "Label" + ltrim(str(nPage))
   cText  := "Text"  + ltrim(str(nPage))
   cCombo := "Combo" + ltrim(str(nPage))

   @ 50 , 10  LABEL &cLabel  PARENT Principal  ;
      VALUE cLabel ;
      TRANSPARENT AUTOSIZE

   @ 46 , 70  TEXTBOX &cText PARENT Principal  ;
      VALUE cText ;
      MAXLENGTH 10

   @ 80 , 20 COMBOBOX &cCombo PARENT Principal ;
      ITEMS aItems ;
      VALUE 500+nPage

   Principal.Container_Tab.AddControl(cLabel, nPage, 50 , 20 )
   Principal.Container_Tab.AddControl(cText , nPage, 46 , 70 )
   Principal.Container_Tab.AddControl(cCombo, nPage, 80 , 20 )

   RETURN NIL

PROCEDURE SizeTest()

   Principal.Container_Tab.Width := Principal.Width - 10
   Principal.Container_Tab.Height := Principal.Height - 60

   RETURN

