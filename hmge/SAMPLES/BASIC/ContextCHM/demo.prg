#include "MiniGUI.ch"

ANNOUNCE RDDSYS

// Topics
#define HLP_1      100
#define HLP_2      200
#define HLP_INDEX   10000

PROCEDURE Main

   SET HELPFILE TO 'Demo.chm'

   DEFINE WINDOW wDemo ;
         At 0, 0 ;
         Width 550 Height 350 ;
         Title 'Usage Help File in Format CHM' ;
         Main ;
         NoMaximize ;
         NoSize

      DEFINE MAIN MENU
         DEFINE POPUP 'File'
            ITEM '&Welcome'      ACTION DISPLAY HELP MAIN
            ITEM '&Item 2'      ACTION DisplayHelpTopic( HLP_2 )
            ITEM '&Fast Cars'      ACTION DisplayHelpTopic( "fastcars.htm" )
            ITEM '&Expensive Cars'   ACTION DisplayHelpTopic( 'expensivecars.htm' )
            SEPARATOR
            ITEM 'E&xit'      ACTION wDemo.Release
         End Popup
         DEFINE POPUP 'Help'
            ITEM '&Context'      ACTION DISPLAY HELP CONTEXT HLP_1
            ITEM '&Index'      ACTION DISPLAY HELP CONTEXT HLP_INDEX
         End Popup
      End Menu

      DEFINE BUTTON b1
         row 20
         col 20
         caption 'Press me'
         onclick DisplayHelpTopic( "helpindex.htm" )
      END BUTTON

      DEFINE STATUSBAR
         StatusItem 'F1 - Help' Action DISPLAY HELP MAIN
      END STATUSBAR

   END WINDOW

   CENTER WINDOW wDemo
   ACTIVATE WINDOW wDemo

   RETURN
