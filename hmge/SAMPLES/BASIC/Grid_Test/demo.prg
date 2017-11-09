/*
HMG Grid Demo
(c) 2010 Roberto Lopez
(c) 2011-2016 Grigory Filatov
*/

#include "minigui.ch"
#include "i_winuser.ch"

STATIC showheader := .t.
STATIC bColor
STATIC fColor

FUNCTION Main

   LOCAL aRows [20] [7]

   bColor := { || if ( This.CellRowIndex/2 == int(This.CellRowIndex/2) , { 222,222,222 } , { 255,255,255 } ) }
   fColor := { || if ( This.CellRowIndex/2 == int(This.CellRowIndex/2) , { 255,0,0 } , { 0,0,255 } ) }

   SET DATE german
   SET CENTURY ON

   aRows [1]   := {'Simpson',1500.00,ctod('23/05/1989'),.t.,date(),12,1}
   aRows [2]   := {'Mulder',2000.00,ctod('12/06/1989'),.f.,date(),15,2}
   aRows [3]   := {'Smart',340,date(),.t.,date(),13,3}
   aRows [4]   := {'Grillo',323.60,date(),.f.,date(),1,4}
   aRows [5]   := {'Kirk',120,date(),.t.,date(),2,5}
   aRows [6]   := {'Barriga',0,date(),.f.,date(),45,6}
   aRows [7]   := {'Flanders',0,date(),.t.,date(),35,7}
   aRows [8]   := {'Smith',128,date(),.f.,date(),45,8}
   aRows [9]   := {'Pedemonti',12.5,date(),.t.,date(),34,9}
   aRows [10]   := {'Gomez',-4,date(),.f.,date(),57,10}
   aRows [11]   := {'Simpson',1500.00,ctod('23/05/1989'),.t.,date(),12,1}
   aRows [12]   := {'Mulder',2000.00,ctod('12/06/1989'),.f.,date(),15,2}
   aRows [13]   := {'Smart',340,date(),.t.,date(),13,3}
   aRows [14]   := {'Grillo',323.60,date(),.f.,date(),1,4}
   aRows [15]   := {'Kirk',120,date(),.t.,date(),2,5}
   aRows [16]   := {'Barriga',0,date(),.f.,date(),45,6}
   aRows [17]   := {'Flanders',0,date(),.t.,date(),35,7}
   aRows [18]   := {'Smith',128,date(),.f.,date(),45,8}
   aRows [19]   := {'Pedemonti',12.5,date(),.t.,date(),34,9}
   aRows [20]   := {'Gomez',-4,date(),.f.,date(),57,10}

   DEFINE WINDOW oWindow            ;
         At 10 , 10            ;
         Width   650            ;
         Height   400            ;
         Title   'HMG Grid Demo'         ;
         Main

      DEFINE MAIN MENU

         DEFINE POPUP "&Properties"
            MenuItem "Get Item (2,3)"                  action MsgInfo(oWindow.oGrid.Cell(2,3))
            MenuItem "Set Item (2,2)"                  action oWindow.oGrid.Cell(2,2) := 1250.5
            MenuItem "Get Item (2,7)"                  action MsgInfo(oWindow.oGrid.Cell(2,7))
            MenuItem "Set Item (2,7)"                  action oWindow.oGrid.Cell(2,7) := 8
            MenuItem "Get ItemCount"                   action MsgInfo(oWindow.oGrid.ItemCount)
            Separator
            MenuItem "Get Item (4)"                    action ShowItems(4)
            MenuItem "Set Item (4)"                    action Aeval(aRows [9],{|x,i| oWindow.oGrid.Cell(4, i) := x})
            MenuItem "Get Header (3)"                  action MsgInfo(oWindow.oGrid.Header(3))
            MenuItem "Set Header (3)"                  action oWindow.oGrid.Header(3) := "New Header"
            Separator
            MenuItem "Show/Hide Headers"               action (showheader:=!showheader,LoadGrid({},isGridMultiSelect('oGrid','oWindow'),isgridcelled('oGrid','oWindow'),isgrideditable('oGrid','oWindow')))
            MenuItem "Toggle Grid Lines"               action setgridlines('oGrid','oWindow',!isgridlines('oGrid','oWindow'))
            MenuItem "Toggle MultiSelect"              action LoadGrid({},!isGridMultiSelect('oGrid','oWindow'),isgridcelled('oGrid','oWindow'),isgrideditable('oGrid','oWindow'))
            MenuItem "Toggle CellNavigation"           action LoadGrid({},isGridMultiSelect('oGrid','oWindow'),!isgridcelled('oGrid','oWindow'),isgrideditable('oGrid','oWindow'))
            MenuItem "Toggle AllowEdit"                action LoadGrid({},isGridMultiSelect('oGrid','oWindow'),isgridcelled('oGrid','oWindow'),!isgrideditable('oGrid','oWindow'))
            Separator
            MenuItem "Get Value"                       action ShowGridValue()
            MenuItem "Set Value"                       action SetGridValue()
            Separator
            MenuItem "Get All Items List"              action ShowAllItems()
         End PopUp

         DEFINE POPUP "&Events"
            MenuItem "Change OnChange Event"           action oWindow.oGrid.onChange := {|| MsgInfo("OnChange event now changed!")}
            MenuItem "Change OnDblClick Event"         action iif(isgrideditable('oGrid','oWindow'),nil,oWindow.oGrid.onDblClick := {|| MsgInfo("OnDblClick event now changed!")})
         End PopUp

         DEFINE POPUP "&Methods"
            MenuItem "AddItem()"                       action AddNewRow()
            MenuItem "DeleteItem(3)"                   action oWindow.oGrid.DeleteItem(3)
            MenuItem "DeleteAllItems()"                action oWindow.oGrid.DeleteAllItems()
            Separator
            MenuItem "AddColumn(2)"                    action AddNewColumn('oGrid','oWindow',2)
            MenuItem "DeleteColumn(2)"                 action DeleteColumn('oGrid','oWindow',2)
            Separator
            MenuItem "AddColumn(8)"                    action AddNewColumn('oGrid','oWindow',8)
         End PopUp

      End Menu

   END WINDOW

   _HMG_GridSelectedCellBackColor   := { 122,163,204 }
   _HMG_GridSelectedRowBackColor   := { 193,224,255 }
   LoadGrid(aRows,.f.,.t.,.t.)

   oWindow.Center()
   ACTIVATE WINDOW oWindow

   RETURN NIL

FUNCTION LoadGrid(aRows,lmultiselect,lcelled,leditable)

   LOCAL aItems, i

   IF iscontroldefined(oGrid,oWindow)
      aItems := {}
      IF oWindow.oGrid.ItemCount > 0
         FOR i := 1 to oWindow.oGrid.ItemCount
            aAdd(aItems, oWindow.oGrid.Item(i))
         NEXT i
      ENDIF
      aRows := aItems
      oWindow.oGrid.release
      do events
      IF lmultiselect
         lcelled := .f.
      ENDIF
   ENDIF

   DEFINE GRID oGrid
      Row      20
      Col      10
      Width      615
      Height      300
      Parent      oWindow
      Widths      {150,60,70,40,90,40,100}
      Headers      {'Column 1','Column 2','Column 3','Column 4','Column 5','Column 6','Column 7'}
      Items      aRows
      Value      if (lmultiselect, { 1 }, if (lcelled, { 1 , 1 }, 1))
      AllowEdit   leditable
      CellNavigation   lcelled
      MultiSelect   lmultiselect
      Justify      {0,1,0,0,0,1,0}
      ColumnControls   {{'TEXTBOX','CHARACTER'},;
         {'TEXTBOX','NUMERIC','9,999.99'},;
         {'TEXTBOX','DATE'},;
         {'CHECKBOX','Yes','No'},;
         {"DATEPICKER","UPDOWN"},{"SPINNER",1,1000},;
         {"COMBOBOX",{"January","February","March","April","May","June","July","August","September","October","November","December"}};
         }
      ColumnWhen {{||.f.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.};
         }
      ColumnValid {{||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||.t.},;
         {||msgyesno('Is this valid ?','Confirm')};
         }
      OnDblClick MsgInfo("Double Click event!")
      DYNAMICBackColor {bColor,bColor,bColor,bColor,bColor,bColor,bColor}
      DYNAMICForeColor {fColor,fColor,fColor,fColor,fColor,fColor,fColor}
      HeaderImages {'help.bmp','help.bmp'}
      OnHeadClick {{||MsgInfo("Header1 Clicked!")},{||MsgInfo("Header2 Clicked!")},{||MsgInfo("Header3 Clicked!")},{||MsgInfo("Header4 Clicked!")},{||MsgInfo("Header5 Clicked!")},{||MsgInfo("Header6 Clicked!")},{||MsgInfo("Header7 Clicked!")}}
      ShowHeaders showheader
   END GRID

   AEVAL( Array(7), { | n, i | oWindow.oGrid.HeaderImage( i ):={1, i==2.or.i==6}, n:=nil } )
   IF showheader
      oWindow.oGrid.ColumnsAutoFitH
   ENDIF
   oWindow.oGrid.Setfocus

   RETURN NIL

FUNCTION ShowItems(nItem)

   LOCAL cStr := '', i
   LOCAL aLine := oWindow.oGrid.Item(nItem)

   FOR i := 1 to len(aLine)
      cStr += ' ' + DataToStr( aLine[i] )
   NEXT i
   MsgInfo(cStr)

   RETURN NIL

FUNCTION ShowAllItems

   LOCAL i, j
   LOCAL cStr, aLine, aStr := {}

   FOR i := 1 to oWindow.oGrid.ItemCount
      cStr := ''
      aLine := oWindow.oGrid.Item( i )
      FOR j := 1 to len(aLine)
         cStr += ' ' + DataToStr( aLine[j] )
      NEXT j
      Aadd(aStr, cStr)
   NEXT i
   MsgDebug(aStr)

   RETURN NIL

FUNCTION ShowGridValue

   LOCAL cStr := '', i
   LOCAL aValue := oWindow.oGrid.Value

   IF isGridMultiSelect('oGrid','oWindow')
      cStr := "Selected Lines are : ("
      FOR i := 1 to len(aValue)
         cStr += alltrim(str(aValue[i]))
         IF i < len(aValue)
            cStr += ","
         ENDIF
      NEXT i
      cStr += ")"
   ELSE
      IF isgridcelled('oGrid','oWindow')
         cStr := "Value is : ("+alltrim(str(aValue[1]))+","+alltrim(str(aValue[2]))+")"
      ELSE
         cStr := "Value is :"+str(oWindow.oGrid.Value)
      ENDIF
   ENDIF
   MsgInfo(cStr)

   RETURN NIL

FUNCTION SetGridValue

   IF isGridMultiSelect('oGrid','oWindow')
      oWindow.oGrid.Value := {1,3,5,7}
   ELSE
      IF isgridcelled('oGrid','oWindow')
         oWindow.oGrid.Value := {1,2}
      ELSE
         oWindow.oGrid.Value := 5
      ENDIF
   ENDIF

   RETURN NIL

FUNCTION SetLastValue

   IF isGridMultiSelect('oGrid','oWindow')
      oWindow.oGrid.Value := {(oWindow.oGrid.ItemCount)}
   ELSE
      IF isgridcelled('oGrid','oWindow')
         oWindow.oGrid.Value := {(oWindow.oGrid.ItemCount),1}
      ELSE
         oWindow.oGrid.Value := (oWindow.oGrid.ItemCount)
      ENDIF
   ENDIF

   RETURN NIL

STATIC FUNCTION DataToStr( xValue )

   SWITCH ValType( xValue )
   CASE 'N'

      RETURN str( xValue )
   CASE 'D'

      RETURN dToc( xValue )
   CASE 'L'

      RETURN If( xValue, 'T', 'F' )
   ENDSWITCH

   RETURN xValue

FUNCTION AddNewRow

   LOCAL i := getcontrolindex("oGrid", "oWindow")
   LOCAL adbc, n, aEditcontrols
   LOCAL bColor2 := { |val, rowindex| if( empty(val[1]), { 193,224,255 }, ;
      if( RowIndex/2 == int(RowIndex/2) , { 222,222,222 } , { 255,255,255 } )) }
   LOCAL aValue := {}

   adbc := _HMG_aControlMiscData1 [i] [12]
   AEval( adbc, {| val,nColumn| adbc[nColumn] := bColor2, val:=nil} )
   _HMG_aControlMiscData1 [i] [12] := adbc
   aEditcontrols := _HMG_aControlMiscData1 [i] [13]
   FOR n := 1 to Len(aEditcontrols)
      aAdd( aValue, CtrlToData( aEditcontrols[n] ) )
   NEXT n

   oWindow.oGrid.AddItem(aValue)
   SetLastValue()

   RETURN NIL

STATIC FUNCTION CtrlToData( aValue )

   DO CASE
   CASE 'TEXTBOX' $ aValue[1]
      IF 'CHARACTER' $ aValue[2]

         RETURN ""
      ELSEIF 'NUMERIC' $ aValue[2]

         RETURN 0
      ELSEIF 'DATE' $ aValue[2]

         RETURN CToD( "" )
      ENDIF
   CASE 'DATE' $ aValue[1]

      RETURN CToD( "" )
   CASE 'CHECKBOX' $ aValue[1]

      RETURN .F.
   CASE 'SPINNER' $ aValue[1] .or. 'COMBOBOX' $ aValue[1]

      RETURN 0
   ENDCASE

   RETURN ""

FUNCTION isgridmultiselect(control,form)

   RETURN ( "MULTI" $ getcontroltype(control,form) )

FUNCTION isgrideditable(control,form)

   LOCAL i:=getcontrolindex(control,form)

   RETURN _HMG_aControlSpacing [i]

FUNCTION isgridcelled(control,form)

   LOCAL i:=getcontrolindex(control,form)

   RETURN _HMG_aControlFontColor [i]

FUNCTION isgridlines(control,form)

   LOCAL i:=getcontrolindex(control,form)

   RETURN _HMG_aControlMiscData1 [i][7]

FUNCTION setgridlines(control,form,nogrid)

   LOCAL i:=getcontrolindex(control,form)
   LOCAL ControlHandle:=getcontrolhandle(control,form)

   SendMessage( ControlHandle, LVM_SETEXTENDEDLISTVIEWSTYLE, 0, iif( nogrid, 0, 1 )+ LVS_EX_FULLROWSELECT )
   _HMG_aControlMiscData1 [i][7] := nogrid

   RETURN NIL

FUNCTION AddNewColumn(control, form, nColumn)

   LOCAL i:=getcontrolindex(control, form), aRow, Value
   LOCAL aItems := {}, n, adbc, adfc, aEditcontrols
   LOCAL bColor2 := { || { 193,224,255 } }

   IF GetProperty( form, control, "ItemCount" ) > 0
      Value := GetProperty( form, control, "Value" )
      FOR n := 1 to GetProperty( form, control, "ItemCount" )
         aAdd(aItems, GetProperty( form, control, "Item", n ))
      NEXT n
      adfc := _HMG_aControlMiscData1 [i] [11]
      aIns(adfc, nColumn, fColor, .t.)
      _HMG_aControlMiscData1 [i] [11] := adfc
      adbc := _HMG_aControlMiscData1 [i] [12]
      aIns(adbc, nColumn, bColor2, .t.)
      _HMG_aControlMiscData1 [i] [12] := adbc
      aEditcontrols := _HMG_aControlMiscData1 [i] [13]
      aIns(aEditcontrols, nColumn, {'TEXTBOX','CHARACTER'}, .t.)
      _HMG_aControlMiscData1 [i] [13] := aEditcontrols
   ENDIF

   _AddGridColumn(control, form, nColumn, 'New Column', 100, 1)

   IF Len(aItems) > 0
      SetProperty( form, control, "Value", 0 )
      Domethod( form, control, "DisableUpdate" )
      FOR i := 1 to Len(aItems)
         aRow := aItems[i]
         aIns(aRow, nColumn, "", .t.)
         Domethod( form, control, "AddItem", aRow )
      NEXT i
      Domethod( form, control, "EnableUpdate" )
      SetProperty( form, control, "Value", Value )
   ENDIF

   RETURN NIL

FUNCTION DeleteColumn(control, form, nColumn)

   LOCAL i:=getcontrolindex( control, form ), aRow, Value
   LOCAL aItems := {}, n, aEditcontrols, adbc

   IF GetProperty( form, control, "ItemCount" ) > 0
      Value := GetProperty( form, control, "Value" )
      FOR n := 1 to GetProperty( form, control, "ItemCount" )
         aAdd( aItems, GetProperty( form, control, "Item", n ) )
      NEXT n
      adbc := _HMG_aControlMiscData1 [i] [12]
      aDel(adbc, nColumn, .t.)
      _HMG_aControlMiscData1 [i] [12] := adbc
      aEditcontrols := _HMG_aControlMiscData1 [i] [13]
      aDel(aEditcontrols, nColumn, .t.)
      _HMG_aControlMiscData1 [i] [13] := aEditcontrols
   ENDIF

   Domethod( form, control, "DeleteColumn", nColumn )

   IF Len(aItems) > 0
      SetProperty( form, control, "Value", 0 )
      Domethod( form, control, "DisableUpdate" )
      FOR i := 1 to Len(aItems)
         aRow := aItems[i]
         aDel(aRow, nColumn, .t.)
         Domethod( form, control, "AddItem", aRow )
      NEXT i
      Domethod( form, control, "EnableUpdate" )
      SetProperty( form, control, "Value", Value )
   ENDIF

   RETURN NIL

