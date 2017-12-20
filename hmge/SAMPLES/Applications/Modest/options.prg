#include "Modest.ch"
#include "MiniGUI.ch"

MEMVAR aStat

/******
*       Options()
*       Setting of typical params
*/

PROCEDURE Options

   LOAD WINDOW Options as wOptions

   wOptions.Title := APPNAME + ' - Options'

   wOptions.txbName.Value := aStat[ 'DefName' ]
   wOptions.cmbType.Value := aStat[ 'DefType' ]
   wOptions.spnLen.Value  := aStat[ 'DefLen'  ]
   wOptions.spnDec.Value  := aStat[ 'DefDec'  ]

   wOptions.cmbRDD.Value        := Iif( ( aStat[ 'RDD' ] == 'DBFCDX' ), 2, 1 )
   wOptions.txbExpression.Value := aStat[ 'Expression' ]

   On key Escape of wOptions Action wOptions.Release
   On key Alt+X of wOptions Action { || Done(), ReleaseAllWindows() }

   CENTER WINDOW wOptions
   ACTIVATE WINDOW wOptions

   RETURN

   ****** End of Options ******

   /******
   *       DoSave()
   *       Save of params
   */

STATIC PROCEDURE DoSave

   LOCAL cValue

   aStat[ 'RDD' ] := Iif( ( wOptions.cmbRDD.Value == 2 ), 'DBFCDX', 'DBFNTX' )

   cValue := AllTrim( wOptions.txbName.Value )
   aStat[ 'DefName' ] := Iif( !Empty( cValue ), cValue, 'NEW' )
   aStat[ 'DefType' ] := wOptions.cmbType.Value
   aStat[ 'DefLen'  ] := wOptions.spnLen.Value
   aStat[ 'DefDec'  ] := wOptions.spnDec.Value

   cValue := AllTrim( wOptions.txbExpression.Value )
   aStat[ 'Expression' ] :=  Iif( !Empty( cValue ), cValue, THIS_VALUE )

   BEGIN INI FILE MODEST_INI

      // Common parameters

      SET SECTION 'Common' Entry 'RDD'        to aStat[ 'RDD' ]
      SET SECTION 'Common' Entry 'Expression' to aStat[ 'Expression' ]

      // Field characterizations which are used at the new fields creation

      SET SECTION 'Field' Entry 'Field_Name' to aStat[ 'DefName' ]
      SET SECTION 'Field' Entry 'Field_Type' to aStat[ 'DefType' ]
      SET SECTION 'Field' Entry 'Field_Len'  to aStat[ 'DefLen'  ]
      SET SECTION 'Field' Entry 'Field_Dec'  to aStat[ 'DefDec'  ]

   END INI

   // Show selected RDD name in status row

   SetRDDName()

   RETURN

   ****** End of DoSave ******
