#include <hmg.ch>

MEMVAR _cAnywhereSearchStr

FUNCTION _HMGAnywhereSearch( cControlName, cWindowName, lAnywhereSearch )

   LOCAL lFound := .f.
   LOCAL cText := ''
   LOCAL nLineNo := 0
   LOCAL nItemCount := 0, i

   DEFAULT lAnywhereSearch := .f.

   _HMGAnywhereSearchUpdate( cWindowName )
   nItemCount := GetProperty( cWindowName, cControlName, 'ITEMCOUNT' )

   FOR i := 1 to nItemCount
      // first check in the starting chars... or anywhere searching if enabled
      cText := _HMGAnywhereSearchGetText( cWindowName, cControlName, i )
      IF upper( _cAnywhereSearchStr ) == left( upper( cText ), len( _cAnywhereSearchStr ) ) .or. i > _HMGAnywhereSearchGetRow( cWindowName, cControlName ) .and. if( lAnyWhereSearch, at( upper( _cAnywhereSearchStr ), upper( cText )  ) > 0, .f. )
         lFound := .t.
         _HMGAnywhereSearchSetRow( cWindowName, cControlName, i )
         EXIT
      ENDIF
   NEXT i
   IF .not. lFound
      playbeep()
      _cAnywhereSearchStr := left( _cAnywhereSearchStr, max( 0, ( len( _cAnywhereSearchStr ) - 1 ) ) )
      _HMGAnywhereSearchUpdate( cWindowName )

      RETURN 0
   ENDIF

   RETURN 1

FUNCTION _HMGAnywhereSearchUpdate( cWindowName )

   IF iscontroldefined( _anywherelabel, &cWindowName )
      IF len( alltrim( _cAnywhereSearchStr ) ) > 0
         setproperty( cWindowName, '_anywherelabel', 'VISIBLE', .t. )
      ELSE
         setproperty( cWindowName, '_anywherelabel', 'VISIBLE', .f. )
      ENDIF
      setproperty( cWindowName, '_anywherelabel', 'VALUE', _cAnywhereSearchStr )
   ENDIF

   RETURN NIL

FUNCTION _HMGAnywhereSearchClear( )

   LOCAL cWindowName := thiswindow.name

   _cAnywhereSearchStr := ''
   setproperty( cWindowName, '_anywherelabel', 'VALUE', _cAnywhereSearchStr )

   RETURN NIL

FUNCTION _HMGAnywhereSearchGetRow( cWindowName, cControlName )

   LOCAL cType := ''
   LOCAL nLineNo := 0
   LOCAL aValue := {}
   LOCAL aLineData := {}
   LOCAL i := 0

   cType := GetControlType( cControlName, cWindowName )
   DO CASE
   CASE cType == 'GRID'
      IF getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         IF len( aValue ) > 0
            nLineNo := aValue[ 1 ]
         ENDIF
      ELSE
         nLineNo := getproperty( cWindowName, cControlName, 'VALUE' )
      ENDIF
   CASE cType == 'MULTIGRID'
      IF getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         IF len( aValue ) > 0
            IF len( aValue[ 1 ] ) > 0
               nLineNo := aValue[ 1 ][ 1 ]
            ENDIF
         ENDIF
      ELSE
         aValue := getproperty( cWindowName, cControlName, 'VALUE' )
         IF len( aValue ) > 0
            nLineNo := aValue[ 1 ]
         ENDIF
      ENDIF
   CASE cType == 'TREE'
      // careful! Trees can be with ITEMIDs too! Find ItemIDs position
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      FOR i := 1 to len( aValue )
         IF aValue[ i ] == GetProperty( cWindowName, cControlName, 'VALUE' )
            // yes! this is the current position
            nLineNo := i
            EXIT
         ENDIF
      NEXT i
   CASE cType == 'COMBO' .or. cType == 'LIST'
      nLineNo := getproperty( cWindowName, cControlName, 'VALUE' )
   CASE cType == 'MULTILIST'
      aValue := getproperty( cWindowName, cControlName, 'VALUE' )
      IF len( aValue ) > 0
         nLineNo := aValue[ 1 ]
      ENDIF
   ENDCASE

   RETURN nLineNo

FUNCTION _HMGAnywhereSearchGetText( cWindowName, cControlName, nRow, nCol )

   LOCAL cText := ''
   LOCAL cType := ''
   LOCAL aValue := {}
   LOCAL aLineData := {}

   DEFAULT nCol := 1
   cType := GetControlType( cControlName, cWindowName )
   DO CASE
   CASE cType == 'GRID' .or. cType == 'MULTIGRID'
      cText := getproperty( cWindowName, cControlName, 'CELL', nRow, nCol )
   CASE cType == 'TREE'
      // careful! Trees can be with ITEMIDs too! Find ItemID and get the text
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      cText := GetProperty( cWindowName, cControlName, 'ITEM', aValue[ nRow ] )
   CASE cType == 'COMBO' .or. cType == 'LIST' .or. cType == 'MULTILIST'
      cText := getproperty( cWindowName, cControlName, 'ITEM', nRow )
   ENDCASE

   RETURN cText

FUNCTION _HMGAnywhereSearchSetRow( cWindowName, cControlName, nRow, nCol )

   LOCAL cType := ''
   LOCAL nLineNo := 0
   LOCAL aValue := {}
   LOCAL aLineData := {}

   DEFAULT nCol := 1
   cType := GetControlType( cControlName, cWindowName )
   DO CASE
   CASE cType == 'GRID'
      IF getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         Setproperty( cWindowName, cControlName, 'VALUE', { nRow, 1 } )
      ELSE
         setproperty( cWindowName, cControlName, 'VALUE', nRow )
      ENDIF
   CASE cType == 'MULTIGRID'
      IF getgridproperty( cWindowName, cControlName, 'CELLNAVIGATION' )
         setproperty( cWindowName, cControlName, 'VALUE', { { nRow, 1 } } )
      ELSE
         setproperty( cWindowName, cControlName, 'VALUE', { nRow } )
      ENDIF
   CASE cType == 'TREE'
      // careful! Trees can be with ITEMIDs too! Find ItemID and get the text
      aValue := GetTreeProperty( cWindowName, cControlName, 'ALLVALUE' )
      SetProperty( cWindowName, cControlName, 'VALUE', aValue[ nRow ] )
      //      msginfo( str( aValue[ nRow ] ) + ', ' + str( nRow ) )
   CASE cType == 'COMBO' .or. cType == 'LIST'
      Setproperty( cWindowName, cControlName, 'VALUE', nRow )
   CASE cType == 'MULTILIST'
      setproperty( cWindowName, cControlName, 'VALUE', { nRow } )
   ENDCASE

   RETURN NIL

STATIC FUNCTION getgridproperty( cWindowName, cControlName )

   LOCAL cType := ''
   LOCAL idx := 0

   idx := GetControlIndex( cControlName, cWindowName )
   cType := GetControlType( cControlName, cWindowName )
   DO CASE
   CASE cType == 'GRID' .or. cType == 'MULTIGRID'

      RETURN _HMG_aControlFontColor[idx]
   ENDCASE

   RETURN .f.

STATIC FUNCTION gettreeproperty( cWindowName, cControlName )

   RETURN TreeItemGetAllValue ( cControlName , cWindowName )

FUNCTION TreeItemGetAllValue ( ControlName , ParentForm )

   LOCAL k, aAllValues := {}
   LOCAL i := GetControlIndex  ( ControlName , ParentForm )

   IF i > 0 .AND. GetProperty ( ParentForm, ControlName, "ItemCount" ) > 0
      IF _HMG_aControlInputMask [i] == .F.
         FOR k = 1 TO GetProperty ( ParentForm, ControlName, "ItemCount" )
            AADD (aAllValues, k)
         NEXT
      ELSE
         aAllValues := _HMG_aControlPicture [i]   // nTreeItemID
      ENDIF
   ENDIF

   RETURN IF (EMPTY(aAllValues), NIL, aAllValues)

