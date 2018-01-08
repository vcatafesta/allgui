
#include "oohg.ch"

FUNCTION Main()

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 320 HEIGHT 240 ;
         TITLE 'ooHG Common Dialog Demo' ;
         MAIN ;
         FONT 'Arial' SIZE 10

      DEFINE STATUSBAR
         STATUSITEM 'ooHG Power Ready!'
      END STATUSBAR

      DEFINE MAIN MENU
         POPUP 'Common &Dialog Functions'
            ITEM 'GetFile()'  ACTION getfile_Click()
            ITEM 'PutFile()'  ACTION Putfile ( { {'Images','*.jpg'} } , 'Save Image' , 'C:\' )
            ITEM 'GetFont()'  ACTION GetFont_Click()
            ITEM 'GetColor()' ACTION GetColor_Click()
            ITEM 'GetFolder()' ACTION Getfolder_Click()
         END POPUP

         POPUP 'H&elp'
            ITEM 'About'      ACTION MsgInfo ("Free GUI Library For Harbour","ooHG Demo")
         END POPUP
      END MENU

   END WINDOW

   Form_1.Center()

   Form_1.Activate()

   RETURN NIL

PROCEDURE GetFolder_Click

   LOCAL a:=GetFolder("Title")

   IF empty(a)
      msginfo("cancelled")
   ELSE
      msginfo(a)
   ENDIF

   RETURN

PROCEDURE Getfile_click

   LOCAL a:=(Getfile ( { {'Images','*.jpg'} } , 'Open Image' ))

   IF empty(a)
      msginfo("cancelled")
   ELSE
      msginfo(a)
   ENDIF

   RETURN

PROCEDURE GetColor_Click

   LOCAL Color

   Color := GetColor()

   IF  Color[1] <> NIL
      AutoMsgInfo( (Color[1]) , "Red Value")
      AutoMsgInfo( (Color[2]) , "Green Value")
      AutoMsgInfo( (Color[3]) , "Blue Value")
   ELSE
      Msginfo("cancelled")
   ENDIF

   RETURN

PROCEDURE GetFont_Click

   LOCAL a

   a := GetFont ( 'Arial' , 12 , .t. , .t. , {0,0,255} , .f. , .f. , 0 )
   IF empty ( a [1] )
      MsgInfo ('Cancelled')
   ELSE
      MsgInfo( a [1] + Str( a [2] ) )
      IF  a [3]
         MsgInfo ("Bold")
      ELSE
         MsgInfo ("Non Bold")
      ENDIF

      IF  a [4]
         MsgInfo ("Italic")
      ELSE
         MsgInfo ("Non Italic")
      ENDIF

      MsgInfo ( str( a [5][1]) +str( a [5][2]) +str( a [5][3]), 'Color' )

      IF  a [6]
         MsgInfo ("Underline")
      ELSE
         MsgInfo ("Non Underline")
      ENDIF

      IF  a [7]
         MsgInfo ("StrikeOut")
      ELSE
         MsgInfo ("Non StrikeOut")
      ENDIF

      MsgInfo ( str ( a [8] ) , 'Charset' )
   ENDIF

   RETURN
