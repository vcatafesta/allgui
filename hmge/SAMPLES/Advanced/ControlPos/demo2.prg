/*
*/

#include "minigui.ch"

SET PROCEDURE TO _ControlPos_.prg

MEMVAR Op
MEMVAR _ControlPosFirst_

PROCEDURE Main

   LOCAL aRows [20] [3]

   PUBLIC Op

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

   DEFINE WINDOW Form_1 ;
         AT 0,0 ;
         WIDTH 630 ;
         HEIGHT 480 ;
         TITLE 'Hello World!' ;
         MAIN ;
         ON INIT ControlPos() ;
         FONT 'Arial' ;
         SIZE 9

      DEFINE LABEL Label_1
         ROW   10
         COL   10
         WIDTH   60
         VALUE 'Apellido:'
      END LABEL

      DEFINE TEXTBOX Text_1
         ROW   10
         COL   70
         WIDTH   80
      END TEXTBOX

      DEFINE LABEL Label_2
         ROW   10
         COL   160
         WIDTH   60
         VALUE   'Nombres:'
      END LABEL

      DEFINE TEXTBOX Text_2
         ROW   10
         COL   230
         WIDTH   80
      END TEXTBOX

      DEFINE LABEL Label_3
         ROW   10
         COL   320
         WIDTH   60
         VALUE   'Telefono:'
      END LABEL

      DEFINE TEXTBOX Text_3
         ROW   10
         COL   390
         WIDTH   80
      END TEXTBOX

      DEFINE BUTTON Button_A
         ROW   10
         COL   480
         WIDTH   55
         CAPTION   'Ok'
         ACTION   Ok()
      END BUTTON

      DEFINE BUTTON Button_B
         ROW   10
         COL   545
         WIDTH   55
         CAPTION   'Cancel'
         ACTION   Cancel()
      END BUTTON

      DEFINE GRID Grid_1
         ROW    40
         COL   10
         WIDTH   590
         HEIGHT   330
         HEADERS   { 'Apellido' , 'Nombres' , 'Telefono' }
         WIDTHS   { 185 , 185 , 185 }
         ITEMS   aRows
         VALUE   1
      END GRID

      DEFINE BUTTON Button_1
         ROW   380
         COL   10
         CAPTION   'Agregar'
         ACTION   Agregar()
      END BUTTON

      DEFINE BUTTON Button_2
         ROW   380
         COL   140
         CAPTION   'Eliminar'
         ACTION   Eliminar()
      END BUTTON

      DEFINE BUTTON Button_3
         ROW   380
         COL   270
         CAPTION   'Modificar'
         ACTION   Modificar()
      END BUTTON

   END WINDOW

   Form_1.Text_1.Enabled :=.f.
   Form_1.Text_2.Enabled :=.f.
   Form_1.Text_3.Enabled :=.f.

   Form_1.Button_A.Enabled :=.f.
   Form_1.Button_B.Enabled :=.f.

   ControlPosSTART()       // Control position

   CENTER WINDOW Form_1

   ACTIVATE WINDOW Form_1

   RETURN

PROCEDURE ControlPos()

   Form_1.Label_1.Row := 14
   Form_1.Label_1.Col := 12
   Form_1.Label_1.Width := 50
   Form_1.Label_1.Height := 18

   Form_1.Text_1.Row := 10
   Form_1.Text_1.Col := 70
   Form_1.Text_1.Width := 80
   Form_1.Text_1.Height := 24

   Form_1.Label_2.Row := 14
   Form_1.Label_2.Col := 160
   Form_1.Label_2.Width := 60
   Form_1.Label_2.Height := 18

   Form_1.Text_2.Row := 10
   Form_1.Text_2.Col := 230
   Form_1.Text_2.Width := 80
   Form_1.Text_2.Height := 24

   Form_1.Label_3.Row := 14
   Form_1.Label_3.Col := 320
   Form_1.Label_3.Width := 58
   Form_1.Label_3.Height := 18

   Form_1.Text_3.Row := 10
   Form_1.Text_3.Col := 390
   Form_1.Text_3.Width := 80
   Form_1.Text_3.Height := 24

   Form_1.Button_A.Row := 12
   Form_1.Button_A.Col := 480
   Form_1.Button_A.Width := 58
   Form_1.Button_A.Height := 21

   Form_1.Button_B.Row := 12
   Form_1.Button_B.Col := 545
   Form_1.Button_B.Width := 55
   Form_1.Button_B.Height := 21

   _ControlPosButtonGetClick_()

   RETURN

PROCEDURE Agregar()

   Op := 'AGREGAR'

   Form_1.Text_1.Enabled :=.t.
   Form_1.Text_2.Enabled :=.t.
   Form_1.Text_3.Enabled :=.t.

   Form_1.Button_1.Enabled :=.f.
   Form_1.Button_2.Enabled :=.f.
   Form_1.Button_3.Enabled :=.f.

   Form_1.Button_A.Enabled :=.t.
   Form_1.Button_B.Enabled :=.t.

   Form_1.Grid_1.Enabled := .f.

   Form_1.Text_1.SetFocus

   RETURN

PROCEDURE Eliminar()

   LOCAL i := Form_1.Grid_1.Value

   IF i != 0
      Form_1.Grid_1.DeleteItem(i)
   ENDIF

   RETURN

PROCEDURE Modificar()

   LOCAL i := Form_1.Grid_1.Value , aTemp

   Op := 'MODIFICAR'

   IF i != 0

      aTemp := Form_1.Grid_1.Item(i)

      Form_1.Text_1.Value := aTemp [1]
      Form_1.Text_2.Value := aTemp [2]
      Form_1.Text_3.Value := aTemp [3]

      Form_1.Text_1.Enabled :=.t.
      Form_1.Text_2.Enabled :=.t.
      Form_1.Text_3.Enabled :=.t.

      Form_1.Button_1.Enabled :=.f.
      Form_1.Button_2.Enabled :=.f.
      Form_1.Button_3.Enabled :=.f.

      Form_1.Button_A.Enabled :=.t.
      Form_1.Button_B.Enabled :=.t.

      Form_1.Grid_1.Enabled := .f.

      Form_1.Text_1.SetFocus

   ENDIF

   RETURN

PROCEDURE Ok()

   LOCAL aTemp := {} , i

   IF   Op == 'AGREGAR'

      Form_1.Grid_1.AddItem ( { Form_1.Text_1.Value , Form_1.Text_2.Value , Form_1.Text_3.Value } )
      Form_1.Grid_1.Value := Form_1.Grid_1.ItemCount

   ELSEIF   Op == 'MODIFICAR'

      i := Form_1.Grid_1.Value
      Form_1.Grid_1.Item (i) := { Form_1.Text_1.Value,Form_1.Text_2.Value ,Form_1.Text_3.Value }

   ENDIF

   Form_1.Text_1.Value := ''
   Form_1.Text_2.Value := ''
   Form_1.Text_3.Value := ''

   Form_1.Text_1.Enabled :=.f.
   Form_1.Text_2.Enabled :=.f.
   Form_1.Text_3.Enabled :=.f.

   Form_1.Button_1.Enabled :=.t.
   Form_1.Button_2.Enabled :=.t.
   Form_1.Button_3.Enabled :=.t.

   Form_1.Button_A.Enabled :=.f.
   Form_1.Button_B.Enabled :=.f.

   Form_1.Grid_1.Enabled := .t.

   Form_1.Grid_1.SetFocus

   RETURN

PROCEDURE Cancel()

   Form_1.Text_1.Value := ''
   Form_1.Text_2.Value := ''
   Form_1.Text_3.Value := ''

   Form_1.Text_1.Enabled :=.f.
   Form_1.Text_2.Enabled :=.f.
   Form_1.Text_3.Enabled :=.f.

   Form_1.Button_1.Enabled :=.t.
   Form_1.Button_2.Enabled :=.t.
   Form_1.Button_3.Enabled :=.t.

   Form_1.Button_A.Enabled :=.f.
   Form_1.Button_B.Enabled :=.f.

   Form_1.Grid_1.Enabled := .t.

   Form_1.Grid_1.SetFocus

   RETURN

