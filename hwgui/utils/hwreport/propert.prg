/*
* Repbuild - Visual Report Builder
* Edit properties of items
* Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://www.geocities.com/alkresin/
*/

#include "windows.ch"
#include "guilib.ch"
#include "repbuild.h"
#include "repmain.h"

#define UDS_SETBUDDYINT     2
#define UDS_ALIGNRIGHT      4

STATIC aPenStyles := { "SOLID","DASH","DOT","DASHDOT","DASHDOTDOT" }
STATIC aVariables := { "Static", "Variable" }
MEMVAR apaintrep, mypath

FUNCTION LButtonDbl( xPos, yPos )

   LOCAL i, aItem

   FOR i := Len( aPaintRep[FORM_ITEMS] ) TO 1 STEP -1
      aItem := aPaintRep[FORM_ITEMS,i]
      IF xPos >= LEFT_INDENT+aItem[ITEM_X1] ;
            .AND. xPos < LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH] ;
            .AND. yPos > TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] ;
            .AND. yPos < TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT]
         aPaintRep[FORM_ITEMS,i,ITEM_STATE] := STATE_SELECTED
         IF aItem[ITEM_TYPE] == TYPE_TEXT
            STATICDlg( aItem )
         ELSEIF aItem[ITEM_TYPE] == TYPE_HLINE .OR. aItem[ITEM_TYPE] == TYPE_VLINE .OR. aItem[ITEM_TYPE] == TYPE_BOX
            LineDlg( aItem )
         ELSEIF aItem[ITEM_TYPE] == TYPE_BITMAP
            BitmapDlg( aItem )
         ELSEIF aItem[ITEM_TYPE] == TYPE_MARKER
            IF aItem[ITEM_CAPTION] == "SL" .OR. aItem[ITEM_CAPTION] == "EL"
               MarkLDlg( aItem )
            ELSEIF aItem[ITEM_CAPTION] == "DF"
               MarkFDlg( aItem )
            ENDIF
         ENDIF
         EXIT
      ENDIF
   NEXT

   RETURN NIL

STATIC FUNCTION StaticDlg( aItem )

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE  "DLG_STATIC" ON INIT {|| InitStatic(aItem) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndStatic(aItem)}  ;
      ON BN_CLICKED,IDC_PUSHBUTTON1 ACTION {||SetItemFont(aItem)}
   REDEFINE COMBOBOX aVariables OF aModDlg ID IDC_COMBOBOX3 INIT aItem[ITEM_VAR]+1
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitStatic( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL oFont := aItem[ITEM_FONT]

   CheckRadioButton( hDlg,IDC_RADIOBUTTON1,IDC_RADIOBUTTON3, ;
      Iif(aItem[ITEM_ALIGN]==0,IDC_RADIOBUTTON1,Iif(aItem[ITEM_ALIGN]==1,IDC_RADIOBUTTON2,IDC_RADIOBUTTON3)) )
   SetDlgItemText( hDlg, IDC_EDIT1, aItem[ITEM_CAPTION] )
   IF aItem[ITEM_SCRIPT] != Nil
      SetDlgItemText( hDlg, IDC_EDIT3, aItem[ITEM_SCRIPT] )
   ENDIF
   // SetComboBox( hDlg, IDC_COMBOBOX3, aVariables, aItem[ITEM_VAR]+1 )
   SetDlgItemText( hDlg, IDC_TEXT1, oFont:name+","+Ltrim(Str(oFont:width))+","+Ltrim(Str(oFont:height)) )
   SetFocus( GetDlgItem( hDlg, IDC_EDIT1 ) )

   RETURN .T.

STATIC FUNCTION EndStatic( aItem )

   LOCAL hDlg := getmodalhandle()

   aItem[ITEM_CAPTION] := GetEditText( hDlg, IDC_EDIT1 )
   aItem[ITEM_ALIGN] := Iif( IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON1 ),0, ;
      Iif( IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON2 ),1,2 ))
   aItem[ITEM_VAR] := Ascan( aVariables,GetDlgItemText( hDlg, IDC_COMBOBOX3, 12 ) ) - 1
   aItem[ITEM_SCRIPT] := GetEditText( hDlg, IDC_EDIT3 )
   aPaintRep[FORM_CHANGED] := .T.
EndDialog( hDlg )

RETURN .T.

STATIC FUNCTION SetItemFont( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL oFont := HFont():Select()

   IF oFont != Nil
      aItem[ITEM_FONT] := oFont
      SetDlgItemText( hDlg, IDC_TEXT1, oFont:name+","+Ltrim(Str(oFont:width))+","+Ltrim(Str(oFont:height)) )
   ENDIF

   RETURN .T.

STATIC FUNCTION LineDlg( aItem )

   LOCAL aModDlg
   LOCAL oPen := aItem[ITEM_PEN]

   INIT DIALOG aModDlg FROM RESOURCE "DLG_LINE" ON INIT {|| InitLine(aItem) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndLine(aItem)}
   REDEFINE COMBOBOX aPenStyles OF aModDlg ID IDC_COMBOBOX1 INIT oPen:style+1
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitLine( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL oPen := aItem[ITEM_PEN]

   // SetComboBox( hDlg, IDC_COMBOBOX1, aPenStyles, aPen[1]+1 )
   IF aItem[ITEM_TYPE] == TYPE_BOX
   ELSE
      SendMessage( GetDlgItem( hDlg,IDC_COMBOBOX2 ), WM_ENABLE, 0, 0 )
   ENDIF
   SetDlgItemText( hDlg, IDC_EDIT1, Str(oPen:width,1) )

   RETURN .T.

STATIC FUNCTION EndLine( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL nWidth := Val( GetEditText( hDlg, IDC_EDIT1 ) )
   LOCAL cType := GetDlgItemText( hDlg, IDC_COMBOBOX1, 12 ), i
   LOCAL oPen := aItem[ITEM_PEN]

   i := Ascan( aPenStyles,cType )
   IF oPen:style != i-1 .OR. oPen:width != nWidth
      oPen:Release()
      aItem[ITEM_PEN] := HPen():Add( i-1,nWidth,0 )
      aPaintRep[FORM_CHANGED] := .T.
   ENDIF
EndDialog( hDlg )

RETURN .T.

FUNCTION BitmapDlg( aItem )

   LOCAL aModDlg, res := .T.

   INIT DIALOG aModDlg FROM RESOURCE "DLG_BITMAP" ON INIT {|| InitBitmap(aItem) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndBitmap(aItem)}  ;
      ON 0,IDCANCEL     ACTION {|| res := .F.,EndDialog( getmodalhandle() )} ;
      ON BN_CLICKED,IDC_BUTTONBRW ACTION {||OpenBmp(aItem,SelectFile("Bitmap files( *.bmp )", "*.bmp",mypath))} ;
      ON EN_CHANGE,IDC_EDIT3 ACTION {||UpdateProcent(aItem)}
   aModDlg:Activate()

   RETURN res

STATIC FUNCTION OpenBmp( aItem,fname )

   LOCAL hDlg := getmodalhandle()
   LOCAL aBmpSize

   SetDlgItemText( hDlg, IDC_EDIT1, fname )
   IF !Empty( fname )
      IF aItem[ITEM_BITMAP] != Nil
         DELETEObject( aItem[ITEM_BITMAP]:handle )
      ENDIF
      aItem[ITEM_CAPTION] := fname
      aItem[ITEM_BITMAP] := HBitmap():AddFile( fname )
      aBmpSize := GetBitmapSize( aItem[ITEM_BITMAP]:handle )
      aItem[ITEM_WIDTH] :=  aItem[ITEM_BITMAP]:nWidth
      aItem[ITEM_HEIGHT] := aItem[ITEM_BITMAP]:nHeight
      SetDlgItemText( hDlg, IDC_TEXT1, Ltrim(Str(aBmpSize[1]))+"x"+Ltrim(Str(aBmpSize[2])) )
      SetDlgItemText( hDlg, IDC_TEXT2, Ltrim(Str(aItem[ITEM_WIDTH]))+"x"+Ltrim(Str(aItem[ITEM_HEIGHT])) )
   ENDIF

   RETURN NIL

STATIC FUNCTION UpdateProcent( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL nValue := Val( GetEditText( hDlg,IDC_EDIT3 ) )
   LOCAL aBmpSize

   IF aItem[ITEM_BITMAP] != Nil
      aBmpSize := GetBitmapSize( aItem[ITEM_BITMAP]:handle )
      SetDlgItemText( hDlg, IDC_TEXT2, Ltrim(Str(Round(aBmpSize[1]*nValue/100,0)))+"x"+Ltrim(Str(Round(aBmpSize[2]*nValue/100,0))) )
   ENDIF

   RETURN NIL

STATIC FUNCTION InitBitmap( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL aBmpSize, hUp

   hUp := CreateUpDownControl( hDlg,120,UDS_ALIGNRIGHT+UDS_SETBUDDYINT,0,0,12,0,GetDlgItem(hDlg,IDC_EDIT3),500,1,100 )
   IF aItem[ITEM_BITMAP] != Nil
      aBmpSize := GetBitmapSize( aItem[ITEM_BITMAP]:handle )
      SetDlgItemText( hDlg, IDC_EDIT1, aItem[ITEM_CAPTION] )
      SetDlgItemText( hDlg, IDC_TEXT1, Ltrim(Str(aBmpSize[1]))+"x"+Ltrim(Str(aBmpSize[2])) )
      SetDlgItemText( hDlg, IDC_TEXT2, Ltrim(Str(aItem[ITEM_WIDTH]))+"x"+Ltrim(Str(aItem[ITEM_HEIGHT])) )
      SetUpDown( hUp, Round(aItem[ITEM_WIDTH]*100/aBmpSize[1],0) )
   ENDIF

   RETURN .T.

STATIC FUNCTION EndBitmap( aItem )

   LOCAL hDlg := getmodalhandle()
   LOCAL nValue := Val( GetEditText( hDlg,IDC_EDIT3 ) )
   LOCAL aBmpSize := GetBitmapSize( aItem[ITEM_BITMAP]:handle )

   aItem[ITEM_WIDTH] := Round(aBmpSize[1]*nValue/100,0)
   aItem[ITEM_HEIGHT] := Round(aBmpSize[2]*nValue/100,0)
   aPaintRep[FORM_CHANGED] := .T.
EndDialog( hDlg )

RETURN .T.

FUNCTION MarkLDlg( aItem )

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKL" ON INIT {|| InitMarkL(aItem) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndMarkL(aItem)}  ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitMarkL( aItem )

   LOCAL hDlg := getmodalhandle()

   SetDlgItemText( hDlg, IDC_TEXT1, "Script:" )
   IF Valtype(aItem[ITEM_SCRIPT]) == "C"
      SetDlgItemText( hDlg, IDC_EDIT1, aItem[ITEM_SCRIPT] )
   ENDIF

   RETURN .T.

STATIC FUNCTION EndMarkL( aItem )

   LOCAL hDlg := getmodalhandle()

   aItem[ITEM_SCRIPT] := GetEditText( hDlg, IDC_EDIT1 )
   aPaintRep[FORM_CHANGED] := .T.
EndDialog( hDlg )

RETURN .T.

FUNCTION MarkFDlg( aItem )

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKF" ON INIT {|| InitMarkF(aItem) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndMarkF(aItem)}  ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitMarkF( aItem )

   LOCAL hDlg := getmodalhandle()

   CheckRadioButton( hDlg,IDC_RADIOBUTTON1,IDC_RADIOBUTTON2, ;
      Iif(aItem[ITEM_ALIGN]==0,IDC_RADIOBUTTON1,IDC_RADIOBUTTON2 ) )

   RETURN .T.

STATIC FUNCTION EndMarkF( aItem )

   LOCAL hDlg := getmodalhandle()

   aItem[ITEM_ALIGN] := Iif( IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON1 ),0,1 )
   aPaintRep[FORM_CHANGED] := .T.
EndDialog( hDlg )

RETURN .T.

FUNCTION FormOptions()

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKL" ON INIT {|| InitFOpt() }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndFOpt()}  ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitFOpt()

   LOCAL hDlg := getmodalhandle()

   SetDlgItemText( hDlg, IDC_TEXT1, "Variables:" )
   IF Valtype(aPaintRep[FORM_VARS]) == "C"
      SetDlgItemText( hDlg, IDC_EDIT1, aPaintRep[FORM_VARS] )
   ENDIF

   RETURN .T.

STATIC FUNCTION EndFOpt( aItem )

   LOCAL hDlg := getmodalhandle()

   aPaintRep[FORM_VARS] := GetEditText( hDlg, IDC_EDIT1 )
   aPaintRep[FORM_CHANGED] := .T.
EndDialog( hDlg )

RETURN .T.

