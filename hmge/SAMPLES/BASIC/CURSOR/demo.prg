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
         ROW 0 ;
         COL 0 ;
         WIDTH 430 ;
         HEIGHT 450 ;
         TITLE 'HMG Cursor Demo' ;
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
         ROW       40
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'Arrow Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorArrow()
      END LABEL

      DEFINE LABEL Lbl_1
         ROW       40
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'UpArrow Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorUpArrow()
      END LABEL

      DEFINE LABEL Lbl_2
         ROW       80
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE      'Cross Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorCross()
      END LABEL

      DEFINE LABEL Lbl_3
         ROW       80
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'Wait Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorWait()
      END LABEL

      DEFINE LABEL Lbl_4
         ROW       120
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'IBeam Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorIBeam()
      END LABEL

      DEFINE LABEL Lbl_5
         ROW       120
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'SizeVer Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeNS()
      END LABEL

      DEFINE LABEL Lbl_6
         ROW       160
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'SizeHor Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeWE()
      END LABEL

      DEFINE LABEL Lbl_7
         ROW       160
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'SizeBDiag Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizenEsW()
      END LABEL

      DEFINE LABEL Lbl_8
         ROW       200
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'SizeFDiag Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizenWsE()
      END LABEL

      DEFINE LABEL Lbl_9
         ROW       200
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'SizeAll Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorSizeAll()
      END LABEL

      DEFINE LABEL Lbl_10
         ROW       240
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'Forbidden Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorNo()
      END LABEL

      DEFINE LABEL Lbl_11
         ROW       240
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'WhatsThis Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorHelp()
      END LABEL

      DEFINE LABEL Lbl_12
         ROW       280
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'Pointing Hand Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorHand()
      END LABEL

      DEFINE LABEL Lbl_13
         ROW       280
         COL       220
         WIDTH     180
         HEIGHT    30
         VALUE     'Busy Cursor'
         BACKCOLOR CLR_BACK
         CenterAlign .t.
         OnMouseHover CursorAppStarting()
      END LABEL

      DEFINE LABEL Lbl_14
         ROW       320
         COL       10
         WIDTH     180
         HEIGHT    30
         VALUE     'image = write.cur'
         BACKCOLOR CLR_BACK
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
