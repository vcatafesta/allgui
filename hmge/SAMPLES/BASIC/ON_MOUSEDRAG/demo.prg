/*
* MINIGUI - Harbour Win32 GUI library Demo
* MOUSEDRAG demo
* (C) 2012 Andrey Sermyagin <super@freemail.hu>
*/

#include "minigui.ch"

#define DRAGAREAWIDTH 10

STATIC nMouseX:=0       // Click X
STATIC time:=1*30       // Timer
STATIC nDraggedMouseX:=0      // Used in timer event

FUNCTION Main()

   LOCAL aRows [20] [3]

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 450 ;
         HEIGHT 400 ;
         TITLE 'MouseDrag Demo' ;
         ON MOUSECLICK SetClickPoint() ;
         ON MOUSEDRAG ResizeObjects() ;
         ON MOUSEMOVE StopDrag() ;
         ON SIZE SizeIt() ;
         MAIN

      aRows [1]   := {'Simpson','Homer','555-5555'}
      aRows [2]   := {'Mulder','Fox','324-6432'}
      aRows [3]   := {'Smart','Max','432-5892'}
      aRows [4]   := {'Grillo','Pepe','894-2332'}
      aRows [5]   := {'Kirk','James','346-9873'}
      aRows [6]   := {'Barriga','Carlos','394-9654'}
      aRows [7]   := {'Flanders','Ned','435-3211'}
      aRows [8]   := {'Smith','John','123-1234'}
      aRows [9]   := {'Pedemonti','Flavio','000-0000'}
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

      @ 10,10 GRID Grid_1 ;
         WIDTH 200 ;
         HEIGHT 330 ;
         HEADERS {'Last Name','First Name','Phone'} ;
         WIDTHS {140,140,140};
         ITEMS aRows ;
         VALUE 1 ;
         TOOLTIP 'Editable Grid Control' ;
         EDIT ;
         JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_RIGHT, BROWSE_JTFY_RIGHT }

      @ 10,210+DRAGAREAWIDTH GRID Grid_2 ;
         WIDTH 200 ;
         HEIGHT 330 ;
         HEADERS {'Last Name','First Name','Phone'} ;
         WIDTHS {140,140,140};
         ITEMS aRows ;
         VALUE 1 ;
         TOOLTIP 'Editable Grid Control' ;
         ON HEADCLICK { {||MsgInfo('Click 1')} , {||MsgInfo('Click 2')} , {||MsgInfo('Click 3')} } ;
         JUSTIFY { BROWSE_JTFY_LEFT,BROWSE_JTFY_CENTER, BROWSE_JTFY_CENTER }

      DEFINE MAIN MENU
         POPUP 'File'
            ITEM 'Exit'   ACTION Form_1.Release
         END POPUP
      END MENU

      DEFINE TIMER Timer_1 OF Form_1 INTERVAL time ACTION DragControl()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN NIL

PROCEDURE StopDrag()

   LOCAL ZXT := GetMouseCoordX()

   IF IsClickInDragArea(ZXT)
      CursorSizeWE()
      Form_1.Title:= "You can drag ..."
   ELSE
      DisplayCoords()
   ENDIF
   nMouseX:=0

   RETURN

FUNCTION ClickLeft(nPos)

   RETURN ( nPos < (Form_1.Grid_1.col+Form_1.Grid_1.width) )

FUNCTION ClickRight(nPos)

   RETURN ( nPos > Form_1.Grid_2.col )

FUNCTION IsClickInDragArea(nPos)

   RETURN !( ClickLeft(nPos) .or. ClickRight(nPos) )

FUNCTION GetMouseCoordX()

   LOCAL aCoords := GetCursorPos()

   RETURN ( aCoords[2]-Form_1.Col-GetBorderWidth() )

FUNCTION GetMouseCoordY()

   LOCAL aCoords := GetCursorPos()

   RETURN ( aCoords[1]-Form_1.Row-GetTitleHeight()-GetBorderHeight() )

PROCEDURE SetClickPoint()

   LOCAL ZXT := GetMouseCoordX()

   IF IsClickInDragArea(ZXT)
      IF EMPTY(nMouseX)
         nMouseX:=ZXT
      ENDIF
   ELSE
      nMouseX:=0
   ENDIF

   RETURN

FUNCTION IsDrag()

   RETURN !EMPTY(nMouseX)

FUNCTION IsDragLeft(nPos)

   RETURN ( nPos < nMouseX )

FUNCTION IsDragRight(nPos)

   RETURN ( nPos > nMouseX )

PROCEDURE ResizeObjects()

   LOCAL zx := GetMouseCoordX()

   IF !IsDrag()

      RETURN
   ENDIF
   CursorSizeWE()

   Form_1.Grid_1.Width:=zx - Form_1.Grid_1.Col - DRAGAREAWIDTH / 2
   Form_1.Grid_2.col:=zx + DRAGAREAWIDTH / 2
   SizeIt()

   IF IsDragLeft(zx)
      Form_1.Grid_2.Visible:=.T.
      Form_1.Grid_1.Visible:=.F.
   ELSEIF IsDragRight(zx)
      Form_1.Grid_1.Visible:=.T.
      Form_1.Grid_2.Visible:=.F.
   ENDIF

   nMouseX:=zx

   RETURN

PROCEDURE SizeIt()

   LOCAL nWidth

   nWidth:=Thiswindow.Width-Form_1.Grid_1.Width- 2* GetBorderWidth()-26
   Form_1.Grid_2.Width:=nWidth

   RETURN

FUNCTION IsSlowDrag()

   LOCAL zx := GetMouseCoordX()

   RETURN ( ABS(nDraggedMouseX -zx) < 2 )

PROCEDURE DragControl()

   LOCAL zx := GetMouseCoordX()

   IF IsSlowDrag()
      Form_1.Grid_1.Visible:=.T.
      Form_1.Grid_2.Visible:=.T.
   ENDIF

   nDraggedMouseX:=zx

   RETURN

PROCEDURE DisplayCoords()

   LOCAL aCoords := GetCursorPos()

   Form_1.Title:= "Pos y: "+ PADL(aCoords[1]-Form_1.Row-GetTitleHeight()-GetBorderHeight(), 4) + ;
      " Pos x: "+ PADL(aCoords[2]-Form_1.Col-GetBorderWidth(), 4)

   RETURN
