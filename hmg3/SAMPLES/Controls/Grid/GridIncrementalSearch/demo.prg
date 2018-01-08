

#include "hmg.ch"

FUNCTION Main

   SET CODEPAGE TO UNICODE

   PUBLIC aRows [21] [3]

   aRows [1]    := {'Simpson','Homer','555-5555'}
   aRows [2]    := {'Mulder','Fox','324-6432'}
   aRows [3]    := {'Smart','Max','432-5892'}
   aRows [4]    := {'Grillo','Pepe','894-2332'}
   aRows [5]    := {'Kirk','James','346-9873'}
   aRows [6]    := {'Barriga','Carlos','394-9654'}
   aRows [7]    := {'Flanders','Ned','435-3211'}
   aRows [8]    := {'Smith','John','123-1234'}
   aRows [9]    := {'Pedemonti','Flavio','000-0000'}
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
   aRows [21]   := {'Fernández','two','0000-0000'}

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 800 ;
         HEIGHT 650 ;
         TITLE "Incremental search in grid" ;
         MAIN

      @  10, 10 Label L1 ;
         WIDTH 80;
         HEIGHT 20;
         VALUE "Search string:"

      @  10, 100 Label Label_WhatToSearch ;
         WIDTH 600;
         HEIGHT 20;
         VALUE "???";
         autosize

      @  40, 10 Label L2 ;
         WIDTH 120;
         HEIGHT 20;
         VALUE "Last pressed char:"

      @  40, 140 Label Label_PressedChar ;
         WIDTH 120;
         HEIGHT 20;
         VALUE ""

      @ 80,10 GRID Grid_1 ;
         WIDTH 760 ;
         HEIGHT 500 ;
         HEADERS {'Last Name','First Name','Phone'} ;
         WIDTHS {140,140,140};
         ITEMS aRows ;
         VALUE 1;
         EDIT;
         JUSTIFY { GRID_JTFY_LEFT,GRID_JTFY_LEFT, GRID_JTFY_RIGHT };
         ON KEY Proc_GridSearchString()

   END WINDOW

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

FUNCTION Proc_GridSearchString   // New version (April 2014)

   STATIC nRow := 0
   STATIC cPublicSearchString := ""
   LOCAL ch, i, k, cLocalSearchString

   ch := HMG_GetLastCharacter()

   IF HMG_GetLastVirtualKeyDown() == VK_BACK   //   backspace
      HMG_CleanLastVirtualKeyDown()
      cPublicSearchString := HB_ULEFT (cPublicSearchString, max(0,HMG_LEN(cPublicSearchString)-1))
      cLocalSearchString := cPublicSearchString
   ELSE
      IF EventMsg() <> WM_CHAR

         RETURN NIL   // enable processing the current message
      ENDIF
      cLocalSearchString := cPublicSearchString + ch
   ENDIF

   i := 0
   FOR k = 1 TO Form_1.Grid_1.ItemCOUNT
#define COL_SEARCH   1
      IF HMG_UPPER(HB_ULEFT(Form_1.Grid_1.CellEx(k,COL_SEARCH), HMG_LEN(cLocalSearchString))) == HMG_UPPER(cLocalSearchString)
         i := k
         nRow := k   // remember last found string
         EXIT
      ENDIF
   NEXT

   IF i > 0
      Form_1.Grid_1.Value := i                    // found - move pointer of grid
      cPublicSearchString := cLocalSearchString   // remember found string
   ELSE
      Form_1.Grid_1.Value := nRow                 // not found - move pointer of the last found string
   ENDIF

   Form_1.Label_PressedChar.Value := ch
   Form_1.Label_WhatToSearch.Value := cPublicSearchString
   // Form_1.Grid_1.SetFocus

   RETURN 1   // prevents the processing of the current message
