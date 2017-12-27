/*
* MINIGUI - Harbour Win32 GUI library Demo
* Copyright 2002 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
*/

#include "minigui.ch"

#define APP_TITLE "MiniGUI Main Demo"
#define APP_ABOUT "Free GUI Library For Harbour"
#define IDI_MAIN 1001
#define MsgInfo( c ) MsgInfo( c, , , .f. )

FUNCTION Main

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 640 HEIGHT 480 ;
         TITLE 'Harbour MiniGUI Demo' ;
         ICON 'DEMO.ICO' ;
         MAIN ;
         FONT 'Arial' SIZE 10

      DEFINE STATUSBAR
         STATUSITEM 'HMG Power Ready!'
      END STATUSBAR

      ON KEY ALT+A ACTION MsgInfo('Alt+A Pressed')

      DEFINE MAIN MENU
         POPUP '&File'
            ITEM 'InputWindow Test'   ACTION InputWindow_Click()
            ITEM 'More Tests'   ACTION Modal_CLick()   NAME File_Modal
            ITEM 'Topmost WIndow'   ACTION Topmost_Click()  NAME File_TopMost
            ITEM 'Standard WIndow'   ACTION Standard_Click()
            ITEM 'Editable Grid Test' ACTION EditGrid_Click()
            ITEM 'Child Window Test' ACTION Child_Click()
            SEPARATOR
            POPUP 'More...'
               ITEM 'SubItem 1'   ACTION MsgInfo( 'SubItem Clicked' )
               ITEM 'SubItem 2'   ACTION MsgInfo( 'SubItem2 Clicked' )
            END POPUP
            SEPARATOR
            ITEM 'Multiple Window Activation'   ACTION MultiWin_Click()
            SEPARATOR
            ITEM 'Exit'      ACTION Form_1.release
         END POPUP
         POPUP 'F&older Functions'
            ITEM 'GetWindowsFolder()'   ACTION MsgInfo ( GetWindowsFolder() )
            ITEM 'GetSystemFolder()'   ACTION MsgInfo ( GetSystemFolder() )
            ITEM 'GetMyDocumentsFolder()'   ACTION MsgInfo ( GetMyDocumentsFolder() )
            ITEM 'GetDesktopFolder()'   ACTION MsgInfo ( GetDesktopFolder() )
            ITEM 'GetProgramFilesFolder()'   ACTION MsgInfo ( GetProgramFilesFolder())
            ITEM 'GetTempFolder()'      ACTION MsgInfo ( GetTempFolder() )
            SEPARATOR
            ITEM 'GetFolder()'      ACTION MsgInfo(GetFolder())
         END POPUP
         POPUP 'Common &Dialog Functions'
            ITEM 'GetFile()'   ACTION Getfile ( { {'Images','*.jpg'} } , 'Open Image' )
            ITEM 'PutFile()'   ACTION Putfile ( { {'Images','*.jpg'} } , 'Save Image' )
            ITEM 'GetFont()'   ACTION GetFont_Click()
            ITEM 'GetColor()'   ACTION GetColor_Click()
         END POPUP
         POPUP 'Sound F&unctions'
            ITEM 'PlayBeep()'    ACTION PlayBeep()
            ITEM 'PlayAsterisk()'    ACTION PlayAsterisk()
            ITEM 'PlayExclamation()' ACTION PlayExclamation()
            ITEM 'PlayHand()'    ACTION PlayHand()
            ITEM 'PlayQuestion()'    ACTION PlayQuestion()
            ITEM 'PlayOk()'       ACTION PlayOk()
         END POPUP
         POPUP 'M&isc'

            ITEM 'MemoryStatus() Function (Contributed by Grigory Filatov)' ACTION MemoryTest()
            ITEM 'ShellAbout() Function (Contributed by Manu Exposito)' ACTION ShellAbout( "About Main Demo" + "#" + APP_TITLE, ;
               APP_ABOUT + CRLF + "[x]Harbour Power Ready", LoadTrayIcon( GetInstance(), IDI_MAIN, 32, 32 ) )
            ITEM 'BackColor / FontColor Clauses (Contributed by Ismael Dutra)' ACTION Color_CLick()
            SEPARATOR
            ITEM 'Get Control Row Property'    ACTION    MsgInfo ( Str ( GetProperty ('Form_1','Button_1','Row')      ) , 'Maximize Button' )
            ITEM 'Get Control Col Property'    ACTION    MsgInfo ( Str ( GetProperty ('Form_1','Button_1','Col')      ) , 'Maximize Button' )
            ITEM 'Get Control Width Property'    ACTION    MsgInfo ( Str ( GetProperty ('Form_1','Button_1','Width')    ) , 'Maximize Button' )
            ITEM 'Get Control Hetight Property'    ACTION    MsgInfo ( Str ( GetProperty ('Form_1','Button_1','Height')   ) , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set Control Row Property'    ACTION SetProperty ('Form_1','Button_1','Row',35)
            ITEM 'Set Control Col Property'    ACTION SetProperty ('Form_1','Button_1','Col' , 40 )
            ITEM 'Set Control Width Property'    ACTION SetProperty ('Form_1','Button_1','Width', 150 )
            ITEM 'Set Control Hetight Property'    ACTION SetProperty ('Form_1','Button_1','Height', 50 )
            SEPARATOR
            ITEM 'Set Window Row Property'       ACTION SetProperty ('Form_1','Row'    , 10 )
            ITEM 'Set Window Col Property'       ACTION SetProperty ('Form_1','Col'    , 10 )
            ITEM 'Set Window Width Property'    ACTION SetProperty ('Form_1','Width'   , 550)
            ITEM 'Set Window Hetight Property'    ACTION SetProperty ('Form_1','Height'    , 400)
            SEPARATOR
            ITEM 'Get Window Row Property'       ACTION MsgInfo ( Str ( GetProperty ('Form_1','Row'   ) ) )
            ITEM 'Get Window Col Property'       ACTION MsgInfo ( Str ( GetProperty ('Form_1','Col'   ) ) )
            ITEM 'Get Window Width Property'    ACTION MsgInfo ( Str ( GetProperty ('Form_1','Width' ) ) )
            ITEM 'Get Window Hetight Property'    ACTION MsgInfo ( Str ( GetProperty ('Form_1','Height') ) )
            SEPARATOR
            ITEM 'Execute Command'          ACTION ExecTest()
            SEPARATOR
            ITEM 'Set Title Property'      ACTION SetProperty ( 'Form_1' , 'Title' , 'New Title' )
            ITEM 'Get Title Property'      ACTION MsgInfo ( GetProperty ( 'Form_1' , 'Title' ) )
            SEPARATOR
            ITEM 'Set Caption Property'      ACTION SetCaptionTest()
            ITEM 'Get Caption Property'      ACTION GetCaptionTest()
            SEPARATOR
            ITEM 'Get Picture Property'      ACTION MsgInfo ( GetProperty('Form_1','Image_1','Picture') , 'Image_1' )
            SEPARATOR
            ITEM 'Set ToolTip Property'      ACTION SetProperty ( 'Form_1' , 'Button_1' , 'ToolTip' , 'New ToolTip' )
            ITEM 'Get ToolTip Property'      ACTION MsgInfo ( GetProperty('Form_1','Button_1','ToolTip') , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set FontName Property'      ACTION SetProperty ('Form_1','Button_1','FontName','Verdana')
            ITEM 'Get FontName Property'      ACTION MsgInfo ( GetProperty('Form_1','Button_1','FontName') , 'Maximize Button' )
            SEPARATOR
            ITEM 'Set FontSize Property'      ACTION SetProperty( 'Form_1','Button_1','FontSize', 14 )
            ITEM 'Get FontSize Property'      ACTION MsgInfo ( Str ( GetProperty('Form_1','Button_1','FontSize' ) ) )
            SEPARATOR
            ITEM 'Set RangeMin Property'      ACTION SetProperty ( 'Form_1','Spinner_1','RangeMin',1 )
            ITEM 'Get RangeMin Property'      ACTION MsgInfo ( Str ( GetProperty('Form_1','Spinner_1','RangeMin') ) , 'Spinner_1')
            SEPARATOR
            ITEM 'Set RangeMax Property'      ACTION SetProperty ('Form_1','Spinner_1','RangeMax', 1000 )
            ITEM 'Get RangeMax Property'      ACTION MsgInfo ( Str ( GetProperty('Form_1','Spinner_1','RangeMax' ) ) ,'Spinner_1')
            SEPARATOR
            ITEM 'Set Grid Caption Property'   ACTION SetProperty ( 'Form_1' , 'Grid_1' , 'Caption', 1 , 'New Caption' )
            ITEM 'Get Grid Caption Property'   ACTION MsgInfo ( GetProperty ('Form_1','Grid_1','Caption', 1 ) )
            SEPARATOR
            ITEM 'Set RadioGroup Caption Property'   ACTION SetProperty ( 'Form_1' , 'Radio_1' , 'Caption', 1 , 'New Caption' )
            ITEM 'Get RadioGroup Caption Property'   ACTION MsgInfo ( GetProperty ( 'Form_1','Radio_1','Caption', 1 ) ,'Radio_1')
            SEPARATOR
            ITEM 'Set Tab Caption Property'   ACTION SetProperty ( 'Form_1','Tab_1','Caption', 1 , 'New Caption' )
            ITEM 'Get Tab Caption Property'   ACTION MsgInfo ( GetProperty('Form_1','Tab_1','Caption', 1 )  , 'Tab_1' )

         END POPUP
         POPUP 'H&elp'
            ITEM 'About'      ACTION MsgInfo ("Free GUI Library For Harbour","MiniGUI Main Demo")
         END POPUP
      END MENU

      DEFINE CONTEXT MENU
         ITEM 'Check File - More Tests Item'   ACTION Context1_Click()
         ITEM 'UnCheck File - More Test Item'   ACTION Context2_Click()
         ITEM 'Enable File - Topmost Window'   ACTION Context3_Click()
         ITEM 'Disable File - Topmost Window'   ACTION Context4_Click()
         SEPARATOR
         ITEM 'About'            ACTION MsgInfo ("Free GUI Library For Harbour","MiniGUI Main Demo")
      END MENU

      @ 5,450 LABEL Label_Color ;
         VALUE 'Right Click For Context Menu' ;
         WIDTH 170 ;
         HEIGHT 22 ;
         FONT 'Times New Roman' SIZE 10 ;
         FONTCOLOR BLUE

      @ 45,10 LABEL Label_Color_2 ;
         VALUE 'ALT+A HotKey Test' ;
         WIDTH 170 ;
         HEIGHT 22 ;
         FONT 'Times New Roman' SIZE 10 ;
         FONTCOLOR RED

      @ 200,140 CHECKBUTTON CheckButton_1 ;
         CAPTION 'CheckButton!' ;
         VALUE .T. ;
         TOOLTIP 'CheckButton'

      @ 200,250 BUTTON ImageButton_1 ;
         PICTURE 'button.bmp' ;
         ACTION MsgInfo('Click!') ;
         WIDTH 27 HEIGHT 27 TOOLTIP 'Print Preview' ;

      @ 200,285 CHECKBUTTON CheckButton_2 ;
         PICTURE 'open.bmp' WIDTH 27 HEIGHT 27 ;
         VALUE .F. ;
         TOOLTIP 'Graphical CheckButton'

      DEFINE TAB Tab_1 ;
            AT 5,195 ;
            WIDTH 430 ;
            HEIGHT 180 ;
            VALUE 1 ;
            TOOLTIP 'Tab Control'

         PAGE '&Grid'

            @ 30,10 GRID Grid_1 ;
               WIDTH 410 ;
               HEIGHT 140 ;
               HEADERS { '','Last Name','First Name'} ;
               WIDTHS { 0,220,220};
               ITEMS { { 0,'Simpson','Homer'} , {1,'Mulder','Fox'} } VALUE 1 ;
               TOOLTIP 'Grid Control' ;
               ON HEADCLICK { {|| MsgInfo('Header 1 Clicked !')} , { || MsgInfo('Header 2 Clicked !')} } ;
               IMAGE {"br_no","br_ok"} ;
               ON DBLCLICK MsgInfo ('DoubleClick!','Grid')

         END PAGE

         PAGE '&Misc.'

            @ 45,80 FRAME TabFrame_1 WIDTH 130 HEIGHT 110 OPAQUE

            @ 55,90 LABEL Label_1 ;
               VALUE '&This is a Label !!!' ;
               WIDTH 100 HEIGHT 27

            @ 80,90 CHECKBOX Check_1 ;
               CAPTION 'Check 1' ;
               VALUE .T. ;
               TOOLTIP 'CheckBox' ON CHANGE PLAYOK()

            @ 115,85 SLIDER Slider_1 ;
               RANGE 1,10 ;
               VALUE 5 ;
               TOOLTIP 'Slider'

            @ 45,240 FRAME TabFrame_2 WIDTH 125 HEIGHT 110 OPAQUE

            @ 50,260 RADIOGROUP Radio_1 ;
               OPTIONS { 'One' , 'Two' , 'Three', 'Four' } ;
               VALUE 1 ;
               WIDTH 100 ;
               TOOLTIP 'RadioGroup' ON CHANGE PLAYOK()

         END PAGE

         PAGE '&EditBox'
            @ 30,10 EDITBOX Edit_1 ;
               WIDTH 410 ;
               HEIGHT 140 ;
               VALUE 'EditBox!!' ;
               TOOLTIP 'EditBox' ;
               MAXLENGTH 255

         END PAGE

         PAGE '&ProgressBar'

            @ 80,120 PROGRESSBAR Progress_1 RANGE 0 , 65535

            @ 80,250 BUTTON Btn_Prg ;
               CAPTION '<- !!!' ;
               ACTION Animate_CLick() ;
               WIDTH 50 ;
               HEIGHT 28 ;
               TOOLTIP 'Animate Progressbar'

         END PAGE

      END TAB

      @ 10,10 DATEPICKER Date_1 ;
         VALUE CTOD('  / /  ') ;
         TOOLTIP 'DatePicker Control'

      @ 200,10 BUTTON Button_1 ;
         CAPTION 'Maximize' ;
         ACTION Maximize_Click() TOOLTIP 'Maximize'

      @ 230,10 BUTTON Button_2 ;
         CAPTION 'Minimize' ;
         ACTION Minimize_Click()

      @ 260,10 BUTTON Button_3 ;
         CAPTION 'Restore' ;
         ACTION Restore_Click()

      @ 290,10 BUTTON Button_4 ;
         CAPTION '&Hide' ;
         ACTION Hide_Click()

      @ 320,10 BUTTON Button_5 ;
         CAPTION 'Sho&w' ;
         ACTION Show_Click()

      @ 350,10 BUTTON Button_6 ;
         CAPTION 'SetFocus' ;
         ACTION Setfocus_Click()

      @ 230,140 BUTTON Button_7 ;
         CAPTION 'GetValue' ;
         ACTION GetValue_Click()

      @ 260,140 BUTTON Button_8 ;
         CAPTION 'SetValue' ;
         ACTION SetValue_Click()

      @ 290,140 BUTTON Button_9 ;
         CAPTION 'Enable' ;
         ACTION Enable_Click()

      @ 320,140 BUTTON Button_10 ;
         CAPTION 'Disable' ;
         ACTION Disable_Click()

      @ 350,140 BUTTON Button_11 ;
         CAPTION 'Delete All Items' ;
         ACTION DeleteAllItems_Click() ;
         WIDTH 150 HEIGHT 28

      @ 190,510 BUTTON Button_12 ;
         CAPTION 'Delete Item' ;
         ACTION DeleteItem_Click()

      @ 220,510 BUTTON Button_13 ;
         CAPTION 'Add Item' ;
         ACTION AddItem_Click()

      @ 250,510 BUTTON Button_14 ;
         CAPTION 'Messages' ;
         ACTION Msg_Click()

      @ 280,510 BUTTON Button_15 ;
         CAPTION 'Set Picture' ;
         ACTION SetPict()

      @ 190,315 FRAME Frame_1 CAPTION 'Frame' WIDTH 170 HEIGHT 200 ;

      @ 210,335 COMBOBOX Combo_1 ;
         ITEMS {'One','Two','Three'} ;
         VALUE 2 ;
         TOOLTIP 'ComboBox'

      @ 240,335 LISTBOX List_1 ;
         WIDTH 120 ;
         HEIGHT 50 ;
         ITEMS {'Andres','Analia','Item 3','Item 4','Item 5'} ;
         VALUE 2  ;
         TOOLTIP 'ListBox' ;
         ON DBLCLICK    MsgInfo('Double Click!','ListBox')

      @ 300,335 TEXTBOX Text_Pass ;
         VALUE 'Secret' ;
         PASSWORD ;
         TOOLTIP 'Password TextBox' ;
         MAXLENGTH 16 ;
         UPPERCASE

      @ 330,335 TEXTBOX Text_1 ;
         WIDTH 50 ;
         VALUE 'Hi!!!' ;
         TOOLTIP 'TextBox' ;
         MAXLENGTH 16 ;
         LOWERCASE ;
         ON LOSTFOCUS MsgInfo('Focus Lost!') ;
         ON ENTER MsgInfo('Enter pressed')

      @ 330,395 TEXTBOX MaskedText ;
         WIDTH 80 ;
         VALUE 1234.12 ;
         TOOLTIP "TextBox With Numeric And InputMask Clauses" ;
         NUMERIC ;
         INPUTMASK '9999.99' ;
         ON CHANGE PlayOk() ;
         ON ENTER MsgInfo('Enter pressed') ;
         RIGHTALIGN

      @ 360,335 TEXTBOX Text_2 ;
         VALUE 123 ;
         NUMERIC ;
         TOOLTIP 'Numeric TextBox' ;
         MAXLENGTH 16 RIGHTALIGN

      @ 100,10 SPINNER Spinner_1 ;
         RANGE 0,10 ;
         VALUE 5 ;
         WIDTH 100 ;
         TOOLTIP 'Range 1,65000'

      @ 378,15 LABEL Label_2 ;
         VALUE 'Timer Test:'

      @ 378,140 LABEL Label_3

      DEFINE TIMER Timer_1 ;
         INTERVAL 1000 ;
         ACTION SetProperty ( 'Form_1','Label_3','Value', Time() )

      @ 315,510 IMAGE Image_1 ;
         PICTURE 'Demo.BMP' ;
         WIDTH 90 ;
         HEIGHT 90

   END WINDOW

   DoMethod ( 'Form_1' , 'Center' )

   DoMethod ( 'Form_1' , 'Activate' )

   RETURN NIL

PROCEDURE SetPict()

   SetProperty ( 'Form_1' , 'Image_1' , 'Picture', 'Open.Bmp' )
   SetProperty ( 'Form_1' , 'ImageButton_1' , 'Picture' , 'Open.Bmp' )

   RETURN

PROCEDURE Maximize_CLick

   DoMethod ( 'Form_1','Maximize' )

   RETURN

PROCEDURE SetCaptionTest()

   SetProperty ( 'Form_1'   ,'Button_1'   ,'Caption', 'New Caption' )
   SetProperty ( 'Form_1'   ,'Check_1'   ,'Caption', 'New Caption' )
   SetProperty ( 'Form_1'   ,'CheckButton_1','Caption', 'New Caption' )
   SetProperty ( 'Form_1'   ,'Frame_1'   ,'Caption', 'New Caption' )

   RETURN

PROCEDURE GetCaptionTest()

   MsgInfo ( GetProperty('Form_1','Button_1','Caption' )      , 'Button_1' )
   MsgInfo ( GetProperty('Form_1','Check_1','Caption' )      , 'Check_1' )
   MsgInfo ( GetProperty('Form_1','CheckButton_1','Caption' )    , 'CheckButton_1' )
   MsgInfo ( GetProperty('Form_1','Frame_1','Caption ')      , 'Frame_1' )

   RETURN

PROCEDURE ExecTest()

   EXECUTE FILE "NOTEPAD.EXE"

   RETURN

PROCEDURE InputWindow_Click

   LOCAL Title , aLabels , aInitValues , aFormats , aResults

   Title       := 'InputWindow Test'

   aLabels    := { 'Field 1:'   , 'Field 2:'   ,'Field 3:'      ,'Field 4:'   ,'Field 5:'   ,'Field 6:' }
   aInitValues    := { 'Init Text', .t.       ,2         , Date()    , 12.34    ,'Init text' }
   aFormats    := { 20      , Nil       ,{'Option 1','Option 2'}, Nil       , '99.99'   , 50 }

   aResults    := InputWindow ( Title , aLabels , aInitValues , aFormats )

   IF aResults [1] == Nil

      MsgInfo ('Canceled','InputWindow')

   ELSE

      MsgInfo ( aResults [1] , aLabels [1] )
      MsgInfo ( iif ( aResults [2] ,'.T.','.F.' ) , aLabels [2] )
      MsgInfo ( Str ( aResults [3] ) , aLabels [3] )
      MsgInfo ( DTOC ( aResults [4] ) , aLabels [4] )
      MsgInfo ( Str ( aResults [5] ) , aLabels [5] )
      MsgInfo ( aResults [6] , aLabels [6] )

   ENDIF

   RETURN

PROCEDURE EditGrid_Click

   LOCAL aRows [20] [3]

   aRows [1]   := {'Simpson','Homer','555-5555'}
   aRows [2]   := {'Mulder','Fox','324-6432'}
   aRows [3]   := {'Smart','Max','432-5892'}
   aRows [4]   := {'Grillo','Pepe','894-2332'}
   aRows [5]   := {'Kirk','James','346-9873'}
   aRows [6]   := {'Barriga','Carlos','394-9654'}
   aRows [7]   := {'Flanders','Ned','435-3211'}
   aRows [8]   := {'Smith','John','123-1234'}
   aRows [9]   := {'Lopez','Roberto','000-0000'}
   aRows [10]   := {'Gomez','Juan','583-4832'}
   aRows [11]   := {'Fernandez','Raul','321-4332'}
   aRows [12]   := {'Borges','Javier','326-9430'}
   aRows [13]   := {'Alvarez','Alberto','543-7898'}
   aRows [14]   := {'Gonzalez','Ambo','437-8473'}
   aRows [15]   := {'Batistuta','Gol','485-2843'}
   aRows [16]   := {'Vinazzi','Amigo','394-5983'}
   aRows [17]   := {'Pedemonti','Flavio','534-7984'}
   aRows [18]   := {'Samarbide','Armando','854-7873'}
   aRows [19]   := {'Pradon','Alejandra','???-????'}
   aRows [20]   := {'Reyes','Monica','432-5836'}

   DEFINE WINDOW Form_Grid ;
         AT 0,0 ;
         WIDTH 430 HEIGHT 400 ;
         TITLE 'Editable Grid Test'  ;
         MODAL NOSIZE ;
         FONT 'Arial' SIZE 10

      @ 10,10 GRID Grid_1 ;
         WIDTH 405 ;
         HEIGHT 330 ;
         HEADERS {'Last Name','First Name','Phone'} ;
         WIDTHS {140,140,140};
         ITEMS aRows ;
         VALUE 1 ;
         TOOLTIP 'Editable Grid Control' ;
         EDIT

   END WINDOW

   SetProperty ( 'Form_Grid' , 'Grid_1' , 'Value', 20 )

   DoMethod ( 'Form_Grid' , 'Grid_1' , 'SetFocus' )

   DoMethod ( 'Form_Grid' , 'Center' )

   DoMethod ( 'Form_Grid' , 'Activate' )

   RETURN

PROCEDURE GetColor_Click

   LOCAL Color

   Color := GetColor()

   MsgInfo( Str(Color[1]) , "Red Value")
   MsgInfo( Str(Color[2]) , "Green Value")
   MsgInfo( Str(Color[3]) , "Blue Value")

   RETURN

PROCEDURE GetFont_Click

   LOCAL a

   a := GetFont ( 'Arial' , 12 , .f. , .t. , {0,0,255} , .f. , .f. , 0 )

   IF empty ( a [1] )

      MsgInfo ('Cancelled')

   ELSE

      MsgInfo( a [1] + Str( a [2] ) )

      IF  a [3] == .t.
         MsgInfo ("Bold")
      ELSE
         MsgInfo ("Non Bold")
      ENDIF

      IF  a [4] == .t.
         MsgInfo ("Italic")
      ELSE
         MsgInfo ("Non Italic")
      ENDIF

      MsgInfo ( str( a [5][1]) +str( a [5][2]) +str( a [5][3]), 'Color' )

      IF  a [6] == .t.
         MsgInfo ("Underline")
      ELSE
         MsgInfo ("Non Underline")
      ENDIF

      IF  a [7] == .t.
         MsgInfo ("StrikeOut")
      ELSE
         MsgInfo ("Non StrikeOut")
      ENDIF

      MsgInfo ( str ( a [8] ) , 'Charset' )

   ENDIF

   RETURN

PROCEDURE MultiWin_Click

   IF (.Not. IsWIndowActive (Form_4) ) .And. (.Not. IsWIndowActive (Form_5) )

      DEFINE WINDOW Form_4 ;
            AT 100,100 ;
            WIDTH 200 HEIGHT 150 ;
            TITLE "Window 1" ;
            TOPMOST

      END WINDOW
      DEFINE WINDOW Form_5 ;
            AT 300,300 ;
            WIDTH 200 HEIGHT 150 ;
            TITLE "Window 2" ;
            TOPMOST

      END WINDOW

      DoMethod ( {'Form_4', 'Form_5' } , 'Activate' )

   ENDIF

   RETURN

PROCEDURE Context1_Click

   SetProperty ( 'Form_1','File_Modal','Checked', .T. )
   MsgInfo ("File - More Tests Checked")

   RETURN

PROCEDURE Context2_Click

   SetProperty ( 'Form_1','File_Modal','Checked', .F. )
   MsgInfo ("File - Modal Window Unchecked")

   RETURN

PROCEDURE Context3_Click

   SetProperty ( 'Form_1','File_Topmost','Enabled', .T. )
   MsgInfo ("File - Topmost Window Enabled")

   RETURN

PROCEDURE Context4_Click

   SetProperty ( 'Form_1','File_Topmost','Enabled', .F. )
   MsgInfo ("File - Topmost Window Disabled")

   RETURN

PROCEDURE Animate_CLick

   LOCAL i

   FOR i = 0 To 65535 Step 25
      SetProperty ( 'Form_1','Progress_1','Value', i )
   NEXT i

   RETURN

PROCEDURE Modal_CLick

   DEFINE WINDOW Form_2 ;
         AT 0,0 ;
         WIDTH 430 HEIGHT 400 ;
         TITLE 'Modal Window & Multiselect Grid/List Test'  ;
         MODAL ;
         NOSIZE

      @ 10,30 BUTTON BUTTON_1 CAPTION 'List GetValue' ;
         ACTION MultiTest_GetValue()

      @ 40,30 BUTTON BUTTON_2 CAPTION 'List SetValue' ;
         ACTION SetProperty ( 'Form_2','List_1','Value', { 1 , 3 } )

      @ 70,30 BUTTON BUTTON_3 CAPTION 'List GetItem' ;
         ACTION Multilist_GetItem()

      @ 100,30 BUTTON BUTTON_4 CAPTION 'List SetItem' ;
         ACTION SetProperty ('Form_2','List_1','Item' , 1 , 'New Value!!' )

      @ 130,30 BUTTON BUTTON_10 CAPTION 'GetItemCount' ;
         ACTION MsgInfo ( Str ( GetProperty('Form_2','List_1','ItemCount') ) )

      @ 10,150 BUTTON BUTTON_5 CAPTION 'Grid GetValue' ;
         ACTION MultiGrid_GetValue()

      @ 40,150 BUTTON BUTTON_6 CAPTION 'Grid SetValue' ;
         ACTION SetProperty ( 'Form_2','Grid_1','Value', { 1 , 3 } )

      @ 70,150 BUTTON BUTTON_7 CAPTION 'Grid GetItem' ;
         ACTION MultiGrid_GetItem()

      @ 100,150 BUTTON BUTTON_8 CAPTION 'Grid SetItem' ;
         ACTION SetProperty ( 'Form_2','Grid_1','Item', 1 , {'Hi','All'} )

      @ 130,150 BUTTON BUTTON_9 CAPTION 'GetItemCount' ;
         ACTION MsgInfo ( Str (  GetProperty ( 'Form_2','Grid_1','ItemCount' ) ) )

      @ 180,30 LISTBOX List_1 ;
         WIDTH 100 ;
         HEIGHT 135 ;
         ITEMS { 'Row 1' , 'Row 2' , 'Row 3' , 'Row 4' , 'Row 5' } ;
         VALUE { 2 , 3 } ;
         FONT 'Arial' ;
         SIZE 10 ;
         TOOLTIP 'Multiselect ListBox (Ctrl+Click)' ;
         MULTISELECT

      @ 180,150 GRID Grid_1 ;
         WIDTH 250 ;
         HEIGHT 135 ;
         HEADERS {'Last Name','First Name'} ;
         WIDTHS {120,120};
         ITEMS { {'Simpson','Homer'} , {'Mulder','Fox'} , {'Smart','Max'} } ;
         VALUE { 2 , 3 } ;
         FONT 'Arial' ;
         SIZE 10 ;
         TOOLTIP 'Multiselect Grid Control (Ctrl+Click)' ;
         ON CHANGE PlayBeep() MULTISELECT

   END WINDOW

   DoMethod ( 'Form_2','Center' )

   DoMethod ( 'Form_2','Activate' )

   RETURN

PROCEDURE MultiTest_GetValue

   LOCAL a , i

   a := Form_2.List_1.Value

   FOR i := 1 to len (a)
      MsgInfo ( str( a[i] ) )
   NEXT i

   IF Len(a) == 0
      MsgInfo('No Selection')
   ENDIF

   RETURN

PROCEDURE MultiGrid_GetValue

   LOCAL a , i

   a := Form_2.Grid_1.Value

   FOR i := 1 to len (a)
      MsgInfo ( str( a[i] ) )
   NEXT i

   IF Len(a) == 0
      MsgInfo('No Selection')
   ENDIF

   RETURN

PROCEDURE multilist_getitem

   MsgInfo ( Form_2.List_1.Item ( 1 ) )

   RETURN

PROCEDURE MultiGrid_GetItem

   LOCAL a , i

   a := Form_2.Grid_1.Item ( 1 )

   FOR i := 1 to len (a)
      MsgInfo ( a[i] )
   NEXT i

   RETURN

PROCEDURE Standard_CLick

   IF .Not. IsWindowDefined ( Form_Std )

      DEFINE WINDOW Form_Std ;
            AT 100,100 ;
            WIDTH 200 HEIGHT 200 ;
            TITLE "Standard Window" ;
            ON INIT { || MsgInfo ("ON INIT Procedure Executing !!!") } ;
            ON RELEASE { || MsgInfo ("ON RELEASE Procedure Executing !!!") }

      END WINDOW

      DoMethod ( 'Form_Std','Activate' )

   ELSE
      MsgInfo ("Window Already Active","Warning!")
   ENDIF

   RETURN

PROCEDURE Topmost_CLick

   IF .Not. IsWIndowActive ( Form_3 )

      DEFINE WINDOW Form_3 ;
            AT 100,100 ;
            WIDTH 150 HEIGHT 150 ;
            TITLE "Topmost Window" ;
            TOPMOST

      END WINDOW

      DoMethod ( 'Form_3','Center' )

      DoMethod ( 'Form_3','Activate' )

   ENDIF

   RETURN

PROCEDURE Minimize_CLick

   DoMethod ( 'Form_1','Minimize' )

   RETURN

PROCEDURE Restore_CLick

   DoMethod ( 'Form_1','Restore' )

   RETURN

PROCEDURE Hide_CLick

   SetProperty ( 'Form_1','Image_1','Visible', .f. )
   SetProperty ( 'Form_1','Spinner_1','Visible', .f. )
   SetProperty ( 'Form_1','Tab_1','Visible', .f. )

   RETURN

PROCEDURE Show_CLick

   SetProperty ( 'Form_1','Image_1','Visible'    , .t. )
   SetProperty ( 'Form_1','Spinner_1','Visible' , .t.    )
   SetProperty ( 'Form_1','Tab_1','Visible'    , .t. )

   RETURN

PROCEDURE Setfocus_CLick

   DoMethod ( 'Form_1','MaskedText','SetFocus' )

   RETURN

PROCEDURE GetValue_CLick

   LOCAL s

   s =     "Grid:                " + Str ( GetProperty('Form_1','Grid_1','Value')     )   + chr(13) + chr(10)
   s = s + "TextBox:             " +     GetProperty('Form_1','Text_1','Value'    )   + chr(13) + chr(10)
   s = s + "EditBox:             " +     GetProperty('Form_1','Edit_1','Value' )      + chr(13) + chr(10)
   s = s + "RadioGroup:          " + Str ( GetProperty('Form_1','Radio_1','Value' )   )   + chr(13) + chr(10)
   s = s + "Tab:                 " + Str ( GetProperty('Form_1','Tab_1','Value' )   )   + chr(13) + chr(10)
   s = s + "ListBox:             " + Str ( GetProperty('Form_1','List_1','Value' )   )   + chr(13) + chr(10)
   s = s + "ComboBox:            " + Str ( GetProperty('Form_1','Combo_1','Value' )   )   + chr(13) + chr(10)
   s = s + "CheckBox:            " + Iif ( GetProperty('Form_1','Check_1','Value' ) , ".T.",".F."   ) + chr(13) + chr(10)
   s = s + "Numeric TextBox:     " + Str ( GetProperty('Form_1','Text_2','Value' )   )   + chr(13) + chr(10)
   s = s + "Password TextBox:    " +     GetProperty('Form_1','Text_Pass','Value'   )   + chr(13) + chr(10)
   s = s + "Slider:         " + Str ( GetProperty('Form_1','Slider_1','Value' )   )   + chr(13) + chr(10)
   s = s + "Spinner:             " + Str ( GetProperty('Form_1','Spinner_1','Value' )   )   + chr(13) + chr(10)
   s = s + "TextBox (InputMask): " + Str ( GetProperty('Form_1','MaskedText','Value')    )   + chr(13) + chr(10)
   s = s + "DatePicker:          " + Dtoc( GetProperty('Form_1','Date_1','Value' )   )

   MsgInfo ( s , "Get Control Values" )

   RETURN

PROCEDURE SetValue_CLick

   SetProperty ( 'Form_1', 'Grid_1'       , 'Value' , 2 )
   SetProperty ( 'Form_1','Text_1','Value'    , "New Text value" )
   SetProperty ( 'Form_1','Edit_1','Value'    , "New Edit Value" )
   SetProperty ( 'Form_1','Radio_1','Value'   , 4                )
   SetProperty ( 'Form_1','Tab_1','Value'       , 2                )
   SetProperty ( 'Form_1','Check_1','Value'    , .t.              )
   SetProperty ( 'Form_1','List_1','Value'    , 1                )
   SetProperty ( 'Form_1','Combo_1','Value'    , 1                )
   SetProperty ( 'Form_1','Date_1','Value'    , CTOD("02/02/2002") )
   SetProperty ( 'Form_1','Label_1','Value'    , "New Label Value"  )
   SetProperty ( 'Form_1','Text_2','Value'    , 999                )
   SetProperty ( 'Form_1','Timer_1','Value'    , 500                )
   SetProperty ( 'Form_1','MaskedText','Value'    , 12.34              )
   SetProperty ( 'Form_1','Spinner_1','Value'    , 6                  )

   RETURN

PROCEDURE Enable_CLick

   SetProperty ( 'Form_1','Button_1','Enabled'    , .T. )
   SetProperty ( 'Form_1','Button_2','Enabled'    , .T. )
   SetProperty ( 'Form_1','Button_3','Enabled'    , .T. )
   SetProperty ( 'Form_1','Button_4','Enabled'    , .T. )
   SetProperty ( 'Form_1','Button_5','Enabled'    , .T. )
   SetProperty ( 'Form_1','Button_6','Enabled'    , .T. )
   SetProperty ( 'Form_1','Timer_1','Enabled'    , .T. )
   SetProperty ( 'Form_1','Spinner_1','Enabled'    , .T. )
   SetProperty ( 'Form_1','Radio_1','Enabled'    , .T. )
   SetProperty ( 'Form_1','Tab_1','Enabled'    , .T. )

   RETURN

PROCEDURE Disable_CLick

   SetProperty ( 'Form_1','Button_1','Enabled'    , .F. )
   SetProperty ( 'Form_1','Button_2','Enabled'    , .F. )
   SetProperty ( 'Form_1','Button_3','Enabled'    , .F. )
   SetProperty ( 'Form_1','Button_4','Enabled'    , .F. )
   SetProperty ( 'Form_1','Button_5','Enabled'    , .F. )
   SetProperty ( 'Form_1','Button_6','Enabled'    , .F. )
   SetProperty ( 'Form_1','Timer_1','Enabled'    , .F. )
   SetProperty ( 'Form_1','Spinner_1','Enabled'    , .F. )
   SetProperty ( 'Form_1','Radio_1','Enabled'    , .F. )
   SetProperty ( 'Form_1','Tab_1','Enabled'    , .F. )

   RETURN

PROCEDURE DeleteAllItems_CLick

   DoMethod ( 'Form_1','Grid_1','DeleteAllItems' )
   DoMethod ( 'Form_1','List_1','DeleteAllItems' )
   DoMethod ( 'Form_1','Combo_1','DeleteAllItems')

   RETURN

PROCEDURE DeleteItem_CLick

   DoMethod ( 'Form_1','Grid_1','DeleteItem' , 1 )
   DoMethod ( 'Form_1','List_1','DeleteItem' , 1 )
   DoMethod ( 'Form_1','Combo_1','DeleteItem', 1 )

   RETURN

PROCEDURE AddItem_CLick

   DoMethod ( 'Form_1','Grid_1','AddItem' , { 1,"Kirk","James"} )
   DoMethod ( 'Form_1','List_1','AddItem' , "New List Item"  )
   DoMethod ( 'Form_1','Combo_1','AddItem' ,"New Combo Item" )

   RETURN

PROCEDURE Msg_CLick

   MsgBox      ("MessageBox Test","MsgBox")
   MsgInfo    ("MessageBox Test","MsgInfo")
   MsgStop    ("MessageBox Test","MsgStop")
   MsgExclamation    ("MessageBox Test","MsgExclamation")
   MsgYesNo   ("MessageBox Test","MsgYesNo")
   MsgOkCancel   ("MessageBox Test","MsgOkCancel")
   MsgRetryCancel  ("MessageBox Test","MsgRetryCancel")

   RETURN

PROCEDURE MemoryTest

   LOCAL cText := ""

   cText += "Total memory (in MB):" + str(MemoryStatus(1)) + CRLF
   cText += "Available memory (in MB):" + str(MemoryStatus(2)) + CRLF
   cText += "Total page memory (in MB):" + str(MemoryStatus(3)) + CRLF
   cText += "Used page memory (in MB):" + str(MemoryStatus(3)-MemoryStatus(4)) + CRLF
   cText += "Available virtual memory (in MB):" + str(MemoryStatus(6))
   MsgInfo(cText)

   RETURN

PROCEDURE Color_CLick

   DEFINE WINDOW Form_Color ;
         AT 100,100 ;
         WIDTH 200 HEIGHT 200 ;
         TITLE 'Color Window' ;
         BACKCOLOR RED

      @ 10,10 LABEL Label_9 ;
         VALUE 'A COLOR Label !!!' ;
         WIDTH 140 ;
         HEIGHT 30 ;
         FONT 'Times New Roman' SIZE 12 ;
         BACKCOLOR RED ;
         FONTCOLOR YELLOW ;
         BOLD

      @ 60,10 LABEL Label_99 ;
         VALUE 'Another COLOR Label !!!' ;
         WIDTH 180 ;
         HEIGHT 30 ;
         FONT 'Times New Roman' SIZE 10 ;
         BACKCOLOR WHITE ;
         FONTCOLOR RED ;
         BOLD

   END WINDOW

   DoMethod('Form_Color','Activate')

   RETURN

PROCEDURE Child_CLick

   DEFINE WINDOW ChildTest ;
         AT 100,100 ;
         WIDTH 200 HEIGHT 200 ;
         TITLE 'Child Window' ;
         CHILD

   END WINDOW

   DoMethod ( 'ChildTest','Activate' )

   RETURN