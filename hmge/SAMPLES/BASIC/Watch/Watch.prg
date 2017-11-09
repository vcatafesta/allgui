/*
* MINIGUI - Harbour Win32 GUI library
* Copyright 2002-2010 Roberto Lopez <harbourminigui@gmail.com>
* http://harbourminigui.googlepages.com/
* Watch Demo
* Copyright 2005-2013 Grigory Filatov <gfilatov@inbox.ru>
*/

#include "minigui.ch"

#define PROGRAM      'Watch'
#define VERSION      ' 1.2'
#define CLR_DEFAULT   0xff000000

STATIC nCount := 1

PROCEDURE Main()

   DEFINE WINDOW Form_1 AT 0,0 ;
         WIDTH 0 HEIGHT 0 MAIN ;
         TITLE PROGRAM + VERSION ;
         ICON "WATCH" TOPMOST ;
         NOMAXIMIZE NOSIZE ;
         ON INIT InitWatch()

      DEFINE IMAGELIST ImageList_1 ;
            OF Form_1 ;
            BUTTONSIZE 32, 48  ;
            IMAGE {'Nums.bmp'} ;
            COLORMASK CLR_DEFAULT;
            IMAGECOUNT 12 ;
            MASK

         @ 0,0 IMAGE Image_1 PICTURE "Dat1.bmp" WIDTH 200 HEIGHT 64

         DEFINE TIMER Timer_1 ;
            INTERVAL 2000 ;
            ACTION ( DrawNums( TIME() ), ProcessMessages() )

         DEFINE TIMER Timer_2 ;
            INTERVAL 1000 ;
            ACTION DrawDefis()

         ON KEY ESCAPE ACTION Form_1.Release

      END WINDOW

      Form_1.Activate

      RETURN

PROCEDURE InitWatch()

   LOCAL nWidth := Form_1.Image_1.Width + GetBorderWidth() - iif(IsSeven(), 2, 0)
   LOCAL nHeight := Form_1.Image_1.Height + GetTitleHeight() + GetBorderHeight() - iif(IsSeven(), 2, 0)

   Form_1.Width := nWidth
   Form_1.Height := nHeight
   Form_1.Col := GetDesktopWidth() - nWidth - iif(IsSeven(), GetBorderWidth(), 0)
   Form_1.Row := GetDesktopHeight() - GetTaskBarHeight() - nHeight - iif(IsSeven(), GetBorderHeight(), 0)

   DrawNums( TIME(), .t. )

   DO EVENTS

   DrawNums( TIME(), .t. )

   nCount := 0

   RETURN

PROCEDURE DrawDefis()

   LOCAL lSwitch := Empty(nCount)

   DRAW IMAGELIST ImageList_1 OF Form_1 AT 8, 20 + 2 * 32 IMAGEINDEX iif(lSwitch, 10, 11)
   nCount := iif(lSwitch, 1, 0)

   DO EVENTS

   RETURN

PROCEDURE DrawNums( cTime, lFirst )

   LOCAL r := 8, c := 20
   LOCAL n1 := Val(SubStr(cTime, 1, 1))
   LOCAL n2 := Val(SubStr(cTime, 2, 1))
   LOCAL n3 := Val(SubStr(cTime, 4, 1))
   LOCAL n4 := Val(SubStr(cTime, 5, 1))

   DEFAULT lFirst := .f.

   DRAW IMAGELIST ImageList_1 OF Form_1 AT r, c IMAGEINDEX n1

   DRAW IMAGELIST ImageList_1 OF Form_1 AT r, c+32 IMAGEINDEX n2
   IF lFirst
      DRAW IMAGELIST ImageList_1 OF Form_1 AT r, c + 2 * 32 IMAGEINDEX 11
   ENDIF
   DRAW IMAGELIST ImageList_1 OF Form_1 AT r, c + 3 * 32 IMAGEINDEX n3

   DRAW IMAGELIST ImageList_1 OF Form_1 AT r, c + 4 * 32 IMAGEINDEX n4

   RETURN

