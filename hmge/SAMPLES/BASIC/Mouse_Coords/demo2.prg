/*
* MINIGUI - Harbour Win32 GUI library Demo
* Based upon MOUSEMOVE demo by Jacek Kubica <kubica@wssk.wroc.pl>
* Author: Krzysztof Stankiewicz <ks@nsm.pl>
* Revised by Grigory Filatov, 25/12/2007
*/

#include "MiniGUI.ch"

MEMVAR zot, zy, zx, zyt, zxt, xy

PROCEDURE Main()

   PRIVATE zot := .f., zy, zx, zyt, zxt, xy := 30

   DEFINE FONT font_0 FONTNAME "Arial" SIZE 16 BOLD

   DEFINE WINDOW Form_1 ;
         AT 0,0 WIDTH 348 HEIGHT 176 ;
         MAIN ;
         TITLE "Mouse Test" ;
         ON MOUSEMOVE DisplayCoords()

      @ 100,100 IMAGE I1 PICTURE "001.jpg" WIDTH xy HEIGHT xy
      @ 100,140 IMAGE I2 PICTURE "002.jpg" WIDTH xy HEIGHT xy
      @ 100,180 IMAGE I3 PICTURE "003.jpg" WIDTH xy HEIGHT xy
   END WINDOW

   DEFINE WINDOW TEM ;
         AT 0,0 WIDTH 300 HEIGHT 300 ;
         CHILD ;
         TOPMOST NOMINIMIZE NOMAXIMIZE NOSYSMENU NOCAPTION

      @ 0,0 IMAGE ImagePhoto PICTURE "" WIDTH 300 HEIGHT 300
      @ 10,100 LABEL ImageLabel VALUE "" FONT 'font_0' TRANSPARENT AUTOSIZE
   END WINDOW

   CENTER WINDOW Form_1
   ACTIVATE WINDOW ALL

   RETURN

PROCEDURE DisplayCoords()

   LOCAL aCoords := GetCursorPos()

   zy := aCoords[1]
   zx := aCoords[2]

   ZYT := aCoords[1]-Form_1.Row-GetTitleHeight()-GetBorderHeight()
   ZXT := aCoords[2]-Form_1.Col-GetBorderWidth()

   Form_1.Title:= "Pos y: "+str(zyt,4)+" Pos x: "+ str(zxt,4)+'  Sys. y: '+str(zy,5)+' x: '+str(zx,5)

   IF GetActiveWindow() == GetFormHandle('Form_1') .or. GetActiveWindow() == GetFormHandle('TEM')
      DO CASE
      CASE (zyt > 100) .and. (zyt < 130) .and. (zxt > 100) .and. (zxt < 130)
         pokaz('001.jpg')
      CASE (zyt > 100) .and. (zyt < 130) .and. (zxt > 140) .and. (zxt < 170)
         pokaz('002.jpg')
      CASE (zyt > 100) .and. (zyt < 130) .and. (zxt > 180) .and. (zxt < 210)
         pokaz('003.jpg')
      OTHERWISE
         IF zot = .t.
            tem.hide
            zot := .f.
         ENDIF
      ENDCASE
   ENDIF

   RETURN

PROCEDURE pokaz(obraz)

   IF zot == .f.
      TEM.ImagePhoto.Picture := (obraz)
      TEM.ImageLabel.Value := (obraz)
      zot := .t.
   ELSE
      IF zy > 310
         setproperty('tem','row',zy-310)
      ELSE
         setproperty('tem','row',zy+10)
      ENDIF
      IF zx > 150
         setproperty('tem','col',zx-150)
      ELSE
         setproperty('tem','col',0)
      ENDIF
      TEM.show
   ENDIF

   RETURN

