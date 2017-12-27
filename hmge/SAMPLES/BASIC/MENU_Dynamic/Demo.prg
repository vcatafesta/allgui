#include "hmg.ch"

MEMVAR aMenu

FUNCTION Main

   PRIVATE aMenu := {{'File',            'Archivo'},;
      {'Open',            'Abrir'},;
      {'Save',            'Guardar'},;
      {'Print',           'Imprimir'},;
      {'Save As...',      'Guardar como...'},;
      {'SPANISH/ENGLISH', 'INGLES/ESPANOL'}}

   SET MENUSTYLE EXTENDED

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Dynamic Menu Demo' ;
         ICON "MAIN.ICO" ;
         NOTIFYICON "STOP.ICO" ;
         MAIN ;
         FONT 'Arial' SIZE 10

      Create_MAIN_Menu (1)

      DEFINE TOOLBAR ToolBar_1 BUTTONSIZE 45,40 /*IMAGESIZE 22,22*/ FONT 'Arial' SIZE 8  FLAT
         BUTTON Button_1   CAPTION 'Undo'   PICTURE 'button4.bmp'   ACTION MsgInfo('Click! 1')
         BUTTON Button_2   CAPTION 'Save'   PICTURE 'button5.bmp'                                WHOLEDROPDOWN
         BUTTON Button_3   CAPTION 'Close'  PICTURE 'button6.bmp'   ACTION MsgInfo('Click! 3')   DROPDOWN
      END TOOLBAR

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

   // MAIN MENU

PROCEDURE Create_MAIN_Menu (i)

   IF IsMainMenuDefined ('Form_1')
      RELEASE MAIN MENU OF Form_1
   ENDIF
   DEFINE MAIN MENU OF Form_1

      POPUP aMenu [1,i]
         ITEM  aMenu [2,i]   ACTION MsgInfo ('Item 1') IMAGE 'Check.Bmp'
         ITEM  aMenu [3,i]   ACTION MsgInfo ('Item 2') IMAGE 'Free.Bmp'
         ITEM  aMenu [4,i]   ACTION MsgInfo ('Item 3') IMAGE 'Info.Bmp'
         ITEM  aMenu [5,i]   ACTION MsgInfo ('Item 4')
         SEPARATOR
         ITEM  aMenu [6,i]   ACTION Set_Language_Menu_File() IMAGE 'Exit.Bmp'
      END POPUP

      POPUP '&Create Menu'
         ITEM 'Create  Menu Button_2'   ACTION   Create_Menu_Button_2 ()     NAME Menu_a1   CHECKED
         ITEM 'Release Menu Button_2'   ACTION   Release_Menu_Button_2 ()    NAME Menu_a2   CHECKED
         SEPARATOR
         ITEM 'Create  Menu Button_3'   ACTION   Create_Menu_Button_3 ()     NAME Menu_b1   CHECKED
         ITEM 'Release Menu Button_3'   ACTION   Release_Menu_Button_3 ()    NAME Menu_b2   CHECKED
         SEPARATOR
         ITEM 'Create  NOTIFY Menu'     ACTION   Create_NOTIFY_Menu ()       NAME Menu_c1   CHECKED
         ITEM 'Release NOTIFY Menu'     ACTION   Release_NOTIFY_Menu ()      NAME Menu_c2   CHECKED
         SEPARATOR
         ITEM 'Create  CONTEXT Menu'    ACTION   Create_CONTEXT_Menu ()      NAME Menu_d1   CHECKED
         ITEM 'Release CONTEXT Menu'    ACTION   Release_CONTEXT_Menu ()     NAME Menu_d2   CHECKED
      END POPUP

   END MENU

   Form_1.Menu_a1.CHECKED := .F.
   Form_1.Menu_b1.CHECKED := .F.
   Form_1.Menu_c1.CHECKED := .F.
   Form_1.Menu_d1.CHECKED := .F.

   RETURN

PROCEDURE Set_Language_Menu_File ()

   STATIC nLang := 1

   IF nLang == 1
      nLang := 2
   ELSE
      nLang := 1
   ENDIF

   Create_MAIN_Menu (nLang)

   RETURN

   // DROPDOWN MENU BUTTON Button_2

PROCEDURE Create_Menu_Button_2 ()

   IF IsDropDownMenuDefined ( "Button_2" ) == .T.
      MsgInfo ("DropDown Menu of 'Button_2' is defined")

      RETURN
   ENDIF

   IsDropDownMenuDefined ( "Button_2" , .T. )
   DEFINE DROPDOWN MENU BUTTON Button_2 OF Form_1
      ITEM 'Item.1'   ACTION MsgInfo ("ToolBar - Button_2 - Item.1")
      ITEM 'Item.2'   ACTION MsgInfo ("ToolBar - Button_2 - Item.2")
   END MENU

   Form_1.Menu_a1.CHECKED := .T.
   Form_1.Menu_a2.CHECKED := .F.

   RETURN

PROCEDURE Release_Menu_Button_2 ()

   IF IsDropDownMenuDefined ( "Button_2" ) == .F.
      MsgInfo ("DropDown Menu of 'Button_2' Not defined")

      RETURN
   ENDIF

   RELEASE DROPDOWN MENU BUTTON Button_2 OF Form_1
   IsDropDownMenuDefined ( "Button_2" , .F. )

   Form_1.Menu_a1.CHECKED := .F.
   Form_1.Menu_a2.CHECKED := .T.

   RETURN

   // DROPDOWN MENU BUTTON Button_3

PROCEDURE Create_Menu_Button_3 ()

   IF IsDropDownMenuDefined ( "Button_3" ) == .T.
      MsgInfo ("DropDown Menu of 'Button_3' is defined")

      RETURN
   ENDIF

   IsDropDownMenuDefined ( "Button_3" , .T. )
   DEFINE DROPDOWN MENU BUTTON Button_3 OF Form_1
      ITEM 'Item.1'   ACTION MsgInfo ("ToolBar - Button_3 - Item.1")
      ITEM 'Item.2'   ACTION MsgInfo ("ToolBar - Button_3 - Item.2")
      SEPARATOR
      ITEM 'Item.3'   ACTION MsgInfo ("ToolBar - Button_3 - Item.3")
   END MENU

   Form_1.Menu_b1.CHECKED := .T.
   Form_1.Menu_b2.CHECKED := .F.

   RETURN

PROCEDURE Release_Menu_Button_3 ()

   IF IsDropDownMenuDefined ( "Button_3" ) == .F.
      MsgInfo ("DropDown Menu of 'Button_3' Not defined")

      RETURN
   ENDIF

   RELEASE DROPDOWN MENU BUTTON Button_3 OF Form_1
   IsDropDownMenuDefined ( "Button_3" , .F. )

   Form_1.Menu_b1.CHECKED := .F.
   Form_1.Menu_b2.CHECKED := .T.

   RETURN

   // NOTIFY MENU

PROCEDURE Create_NOTIFY_Menu ()

   IF IsNotifyMenuDefined () == .T.
      MsgInfo("Notify Menu is defined")

      RETURN
   ENDIF

   IsNotifyMenuDefined ( .T. )
   DEFINE NOTIFY MENU OF Form_1
      ITEM 'NOTIFY 1'   ACTION MsgInfo('Notify Menu - Item 1')
      ITEM 'NOTIFY 2'   ACTION MsgInfo('Notify Menu - Item 2')
      ITEM 'NOTIFY 3'   ACTION MsgInfo('Notify Menu - Item 3')
      SEPARATOR
      ITEM 'NOTIFY 4'   ACTION MsgInfo('Notify Menu - Item 4')
   END MENU

   Form_1.Menu_c1.CHECKED := .T.
   Form_1.Menu_c2.CHECKED := .F.

   RETURN

PROCEDURE Release_NOTIFY_Menu ()

   IF IsNotifyMenuDefined () == .F.
      MsgInfo("Notify Menu Not defined")

      RETURN
   ENDIF

   IsNotifyMenuDefined ( .F. )
   RELEASE NOTIFY MENU OF Form_1

   Form_1.Menu_c1.CHECKED := .F.
   Form_1.Menu_c2.CHECKED := .T.

   RETURN

   // CONTEXT MENU

PROCEDURE Create_CONTEXT_Menu ()

   IF IsContextMenuDefined () == .T.
      MsgInfo ("Context Menu is defined")

      RETURN
   ENDIF

   IsContextMenuDefined ( .T. )
   DEFINE CONTEXT MENU OF Form_1
      ITEM 'Context - Item 1'   ACTION MsgInfo ('Context - Item 1')
      ITEM 'Context - Item 2'   ACTION MsgInfo ('Context - Item 2')
      SEPARATOR
      ITEM 'Context - Item 3'   ACTION MsgInfo ('Context - Item 3')
   END MENU

   Form_1.Menu_d1.CHECKED := .T.
   Form_1.Menu_d2.CHECKED := .F.

   RETURN

PROCEDURE Release_CONTEXT_Menu ()

   IF IsContextMenuDefined () == .F.
      MsgInfo ("Context Menu not defined")

      RETURN
   ENDIF

   IsContextMenuDefined ( .F. )
   RELEASE CONTEXT MENU OF Form_1

   Form_1.Menu_d1.CHECKED := .F.
   Form_1.Menu_d2.CHECKED := .T.

   RETURN

FUNCTION IsDropDownMenuDefined ( cCtrl, lNewValue )

   STATIC IsDropDownMenu_2 := .F.
   STATIC IsDropDownMenu_3 := .F.
   LOCAL lOldValue

   IF Val(Right(cCtrl, 1)) == 2
      lOldValue := IsDropDownMenu_2
      IF ISLOGICAL(lNewValue)
         IsDropDownMenu_2 := lNewValue
      ENDIF
   ELSE
      lOldValue := IsDropDownMenu_3
      IF ISLOGICAL(lNewValue)
         IsDropDownMenu_3 := lNewValue
      ENDIF
   ENDIF

   RETURN lOldValue

FUNCTION IsNotifyMenuDefined (lNewValue)

   STATIC IsNotifyMenuDefined := .F.
   LOCAL lOldValue := IsNotifyMenuDefined

   IF ISLOGICAL(lNewValue)
      IsNotifyMenuDefined := lNewValue
   ENDIF

   RETURN lOldValue

FUNCTION IsContextMenuDefined (lNewValue)

   STATIC IsContextMenuDefined := .F.
   LOCAL lOldValue := IsContextMenuDefined

   IF ISLOGICAL(lNewValue)
      IsContextMenuDefined := lNewValue
   ENDIF

   RETURN lOldValue
