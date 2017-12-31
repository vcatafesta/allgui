/*
* HMG Cursor Demo
*/

#include "minigui.ch"

/*
ArrowCursor           // The standard arrow cursor.
UpArrowCursor         // An arrow pointing upwards toward the top of the screen.
CrossCursor           // A crosshair cursor, typically used to help the user accurately select a point on the screen.
WaitCursor            // An hourglass or watch cursor, usually shown during operations that prevent the user from interacting with the application.
IBeamCursor           // A caret or ibeam cursor, indicating that a widget can accept and display text input.
SizeVerCursor         // A cursor used for elements that are used to vertically resize top-level windows.
SizeHorCursor         // A cursor used for elements that are used to horizontally resize top-level windows.
SizeBDiagCursor       // A cursor used for elements that are used to diagonally resize top-level windows at their top-right and bottom-left corners.
SizeFDiagCursor       // A cursor used for elements that are used to diagonally resize top-level windows at their top-left and bottom-right corners.
SizeAllCursor         // A cursor used for elements that are used to resize top-level windows in any direction.
PointingHandCursor    // A pointing hand cursor that is typically used for clickable elements such as hyperlinks.
ForbiddenCursor       // A slashed circle cursor, typically used during drag and drop operations to indicate that dragged content cannot be dropped on particular widgets or inside certain regions.
WhatsThisCursor       // An arrow with a question mark, typically used to indicate the presence of What's This? help for a widget.
BusyCursor            // An hourglass or watch cursor, usually shown during operations that allow the user to interact with the application while they are performed in the background.
*/

#define CLR_BACK   { 225, 225, 225 }

FUNCTION Main

   DEFINE WINDOW Win_1 ;
         Row 0 ;
         Col 0 ;
         Width 430 ;
         Height 450 ;
         Title 'HMG Cursor Demo' ;
         WindowType MAIN

      DEFINE MAIN MENU

         DEFINE POPUP "Tests"
            MENUITEM "Set Cursor Arrow"     Action SetArrowCursor( Application.Handle )
            MENUITEM "Set Cursor Hand"      Action SetHandCursor( Application.Handle )
            MENUITEM "Set Cursor Wait"      Action SetWaitCursor( Application.Handle )
            MENUITEM "Set Cursor write.cur" Action Win_1.Cursor := 'write.cur'
            SEPARATOR
            MENUITEM "Set Cursor Pos"       Action SetCursorPos( 380+Win_1.Col+GetBorderWidth(), 195+Win_1.Row+GetTitleHeight()+GetBorderHeight() )
            MENUITEM "Put Mouse to label 7" Action PutMouse("Lbl_7",,{165,60})
            MENUITEM "Get Cursor Row"       Action MsgInfo( GetCursorRow()-Win_1.Row-GetTitleHeight()-GetBorderHeight() )
            MENUITEM "Get Cursor Col"       Action MsgInfo( GetCursorCol()-Win_1.Col-GetBorderWidth() )
         END POPUP

      END MENU

      DEFINE LABEL Lbl_0
         Row       40
         Col       10
         Width     180
         Height    30
         Value     'Arrow Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorArrow()
      END LABEL

      DEFINE LABEL Lbl_1
         Row       40
         Col       220
         Width     180
         Height    30
         Value     'UpArrow Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorUpArrow()
      END LABEL

      DEFINE LABEL Lbl_2
         Row       80
         Col       10
         Width     180
         Height    30
         Value      'Cross Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorCross()
      END LABEL

      DEFINE LABEL Lbl_3
         Row       80
         Col       220
         Width     180
         Height    30
         Value     'Wait Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorWait()
      END LABEL

      DEFINE LABEL Lbl_4
         Row       120
         Col       10
         Width     180
         Height    30
         Value     'IBeam Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorIBeam()
      END LABEL

      DEFINE LABEL Lbl_5
         Row       120
         Col       220
         Width     180
         Height    30
         Value     'SizeVer Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeNS()
      END LABEL

      DEFINE LABEL Lbl_6
         Row       160
         Col       10
         Width     180
         Height    30
         Value     'SizeHor Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeWE()
      END LABEL

      DEFINE LABEL Lbl_7
         Row       160
         Col       220
         Width     180
         Height    30
         Value     'SizeBDiag Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizenEsW()
      END LABEL

      DEFINE LABEL Lbl_8
         Row       200
         Col       10
         Width     180
         Height    30
         Value     'SizeFDiag Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizenWsE()
      END LABEL

      DEFINE LABEL Lbl_9
         Row       200
         Col       220
         Width     180
         Height    30
         Value     'SizeAll Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeAll()
      END LABEL

      DEFINE LABEL Lbl_10
         Row       240
         Col       10
         Width     180
         Height    30
         Value     'Forbidden Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorNo()
      END LABEL

      DEFINE LABEL Lbl_11
         Row       240
         Col       220
         Width     180
         Height    30
         Value     'WhatsThis Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorHelp()
      END LABEL

      DEFINE LABEL Lbl_12
         Row       280
         Col       10
         Width     180
         Height    30
         Value     'Pointing Hand Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorHand()
      END LABEL

      DEFINE LABEL Lbl_13
         Row       280
         Col       220
         Width     180
         Height    30
         Value     'Busy Cursor'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorAppStarting()
      END LABEL

      DEFINE LABEL Lbl_14
         Row       320
         Col       10
         Width     180
         Height    30
         Value     'image = write.cur'
         BackColor CLR_BACK
         CenterAlign .t.
         OnMouseHover FileCursor( 'write.cur' )
      END LABEL

   END WINDOW

   CENTER WINDOW Win_1

   ACTIVATE WINDOW Win_1

   RETURN NIL

PROCEDURE PutMouse( obj, form, rect )

   LOCAL ocol, orow

   DEFAULT form TO ThisWindow.name, rect TO {20,40}

   ocol  := GetProperty( Form, "col" ) + GetProperty( Form, obj, "Col" ) + rect [1]
   orow  := GetProperty( Form, "row" ) + GetProperty( Form, obj, "row" ) + rect [2]

   _SETFOCUS( obj, FORM )
   SETCURSORPOS( ocol, orow )

   RETURN
