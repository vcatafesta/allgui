/*
* DBCHW - DBC ( Harbour + HWGUI )
* Commands ( Replace, delete, ... )
* Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
// #include "ads.ch"

MEMVAR finame, cValue, cFor, nSum, mypath, improc, msmode

/* -----------------------  Replace --------------------- */

FUNCTION C_REPL

   LOCAL aModDlg
   LOCAL af := Array( Fcount() )

   Afields( af )

   INIT DIALOG aModDlg FROM RESOURCE "DLG_REPLACE" ON INIT {|| InitRepl() }

   REDEFINE COMBOBOX af OF aModDlg ID IDC_COMBOBOX1

   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndRepl()}   ;
      ON BN_CLICKED,IDC_RADIOBUTTON7 ACTION {|| RecNumberEdit() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON6 ACTION {|| RecNumberDisable() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON8 ACTION {|| RecNumberDisable() }

   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION RecNumberEdit

   LOCAL hDlg := getmodalhandle()
   LOCAL hEdit := GetDlgItem( hDlg,IDC_EDITRECN )

   SendMessage( hEdit, WM_ENABLE, 1, 0 )
   SetDlgItemText( hDlg, IDC_EDITRECN, "1" )
   SetFocus( hEdit )

   RETURN NIL

STATIC FUNCTION RecNumberDisable

   LOCAL hEdit := GetDlgItem( getmodalhandle(),IDC_EDITRECN )

   SendMessage( hEdit, WM_ENABLE, 0, 0 )

   RETURN NIL

STATIC FUNCTION InitRepl()

   LOCAL hDlg := getmodalhandle()

   RecNumberDisable()
   CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   SetFocus( GetDlgItem( hDlg, IDC_COMBOBOX1 ) )

   RETURN NIL

STATIC FUNCTION EndRepl()

   LOCAL hDlg := getmodalhandle()
   LOCAL nrest, nrec
   LOCAL oWindow, aControls, i
   PRIVATE finame, cValue, cFor

   oWindow := HMainWindow():GetMdiActive()

   finame := GetDlgItemText( hDlg, IDC_COMBOBOX1, 12 )
   IF Empty( finame )
      SetFocus( GetDlgItem( hDlg, IDC_COMBOBOX1 ) )

      RETURN NIL
   ENDIF
   cValue := GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF Empty( cValue )
      SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )

      RETURN NIL
   ENDIF
   cFor := GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF .NOT. EMPTY( cFor ) .AND. TYPE( cFor ) <> "L"
      MsgStop( "Wrong expression!" )
   ELSE
      IF EMPTY( cFor )
         cFor := ".T."
      ENDIF
      nrec := Recno()
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
         REPLACE ALL &finame WITH &cValue FOR &cFor
      ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
         nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
         REPLACE NEXT nrest &finame WITH &cValue FOR &cFor
      ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
         REPLACE REST &finame WITH &cValue FOR &cFor
      ENDIF
      Go nrec
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Done !" )
      IF oWindow != Nil
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
            aControls[i]:Refresh()
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL

   /* -----------------------  Delete, recall, count --------------------- */

FUNCTION C_DELE( nAct )

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_DEL" ON INIT {|| InitDele(nAct) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndDele(nAct)}   ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}  ;
      ON BN_CLICKED,IDC_RADIOBUTTON7 ACTION {|| RecNumberEdit() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON6 ACTION {|| RecNumberDisable() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON8 ACTION {|| RecNumberDisable() }
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitDele(nAct)

   LOCAL hDlg := getmodalhandle()

   IF nAct == 2
      SetWindowText( hDlg,"Recall")
   ELSEIF nAct == 3
      SetWindowText( hDlg,"Count")
   ENDIF
   RecNumberDisable()
   CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   SetFocus( GetDlgItem( hDlg, IDC_EDITFOR ) )

   RETURN NIL

STATIC FUNCTION EndDele( nAct )

   LOCAL hDlg := getmodalhandle()
   LOCAL nrest, nsum, nRec := Recno()
   LOCAL oWindow, aControls, i
   PRIVATE cFor

   oWindow := HMainWindow():GetMdiActive()

   cFor := GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF .NOT. EMPTY( cFor ) .AND. TYPE( cFor ) <> "L"
      MsgStop( "Wrong expression!" )
   ELSE
      IF EMPTY( cFor )
         cFor := ".T."
      ENDIF
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF nAct == 1
         IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
            DELETE ALL FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
            nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            DELETE NEXT nrest FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
            DELETE REST FOR &cFor
         ENDIF
      ELSEIF nAct == 2
         IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
            RECALL ALL FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
            nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            RECALL NEXT nrest FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
            RECALL REST FOR &cFor
         ENDIF
      ELSEIF nAct == 3
         IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
            COUNT TO nsum ALL FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
            nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            COUNT TO nsum NEXT nrest FOR &cFor
         ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
            COUNT TO nsum REST FOR &cFor
         ENDIF
         SetDlgItemText( hDlg, IDC_TEXTMSG, "Result: "+Str( nsum ) )
         Go nrec

         RETURN NIL
      ENDIF
      Go nrec
      WriteStatus( oWindow,3,"Done" )
      IF oWindow != Nil
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
            RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
         ENDIF
      ENDIF
   ENDIF

EndDialog( hDlg )

RETURN NIL

/* -----------------------  Sum --------------------- */

FUNCTION C_SUM()

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_SUM" ON INIT {|| InitSum() }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndSum()}   ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}  ;
      ON BN_CLICKED,IDC_RADIOBUTTON7 ACTION {|| RecNumberEdit() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON6 ACTION {|| RecNumberDisable() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON8 ACTION {|| RecNumberDisable() }
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitSum()

   LOCAL hDlg := getmodalhandle()

   RecNumberDisable()
   CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )

   RETURN NIL

STATIC FUNCTION EndSum()

   LOCAL hDlg := getmodalhandle()
   LOCAL cSumf, cFor, nrest, blsum, blfor, nRec := Recno()
   PRIVATE nsum := 0

   cSumf := GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF EMPTY( cSumf )
      SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )

      RETURN NIL
   ENDIF

   cFor := GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF ( !EMPTY( cFor ) .AND. TYPE( cFor ) <> "L" ) .OR. TYPE( cSumf ) <> "N"
      MsgStop( "Wrong expression!" )
   ELSE
      IF EMPTY( cFor )
         cFor := ".T."
      ENDIF
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      blsum := &( "{||nsum:=nsum+" + cSumf + "}" )
      blfor := &( "{||" + cFor + "}" )
      IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
         DBEVAL( blsum, blfor )
      ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
         nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
         DBEVAL( blsum, blfor,, nrest )
      ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
         DBEVAL( blsum, blfor,,,, .T. )
      ENDIF
      Go nrec
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Result: "+Str( nsum ) )

      RETURN NIL
   ENDIF

EndDialog( hDlg )

RETURN NIL

/* -----------------------  Append from --------------------- */

FUNCTION C_APPEND()

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_APFROM" ON INIT {|| InitApp() }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndApp()}  ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() )}  ;
      ON BN_CLICKED,IDC_BUTTONBRW ACTION {||SetDlgItemText( getmodalhandle(), IDC_EDIT7, SelectFile( "xBase files( *.dbf )", "*.dbf", mypath ) ) } ;
      ON BN_CLICKED,IDC_RADIOBUTTON11 ACTION {|| DelimEdit() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON10 ACTION {|| DelimDisable() } ;
      ON BN_CLICKED,IDC_RADIOBUTTON9 ACTION {|| DelimDisable() }
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION DelimEdit

   LOCAL hDlg := getmodalhandle()
   LOCAL hEdit := GetDlgItem( hDlg,IDC_EDITDWITH )

   SendMessage( hEdit, WM_ENABLE, 1, 0 )
   SetDlgItemText( hDlg, IDC_EDITDWITH, " " )
   SetFocus( hEdit )

   RETURN NIL

STATIC FUNCTION DelimDisable

   LOCAL hEdit := GetDlgItem( getmodalhandle(),IDC_EDITDWITH )

   SendMessage( hEdit, WM_ENABLE, 0, 0 )

   RETURN NIL

STATIC FUNCTION InitApp()

   LOCAL hDlg := getmodalhandle()

   DelimDisable()
   CheckRadioButton( hDlg,IDC_RADIOBUTTON9,IDC_RADIOBUTTON9,IDC_RADIOBUTTON11 )
   SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )

   RETURN NIL

STATIC FUNCTION EndApp()

   LOCAL hDlg := getmodalhandle()
   LOCAL fname, nRec := Recno()

   fname := GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF EMPTY( fname )
      SetFocus( GetDlgItem( hDlg, IDC_EDIT7 ) )

      RETURN NIL
   ENDIF

   SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
   IF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON6 )
      // DBEVAL( blsum, blfor )
   ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON7 )
      // nrest := Val( GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
      // DBEVAL( blsum, blfor,, nrest )
   ELSEIF IsDlgButtonChecked( hDlg,IDC_RADIOBUTTON8 )
      // DBEVAL( blsum, blfor,,,, .T. )
   ENDIF
   Go nrec

EndDialog( hDlg )

RETURN NIL

/* -----------------------  Reindex, pack, zap --------------------- */

FUNCTION C_RPZ( nAct )

   LOCAL aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_OKCANCEL" ON INIT {|| InitRPZ(nAct) }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDOK         ACTION {|| EndRPZ(nAct)}   ;
      ON 0,IDCANCEL     ACTION {|| EndDialog( getmodalhandle() ) }
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitRPZ( nAct )

   LOCAL hDlg := getmodalhandle()

   SetDlgItemText( hDlg, IDC_TEXTHEAD, Iif( nAct==1,"Reindex ?", ;
      Iif( nAct==2,"Pack ?", "Zap ?" ) ) )

   RETURN NIL

STATIC FUNCTION EndRPZ( nAct )

   LOCAL hDlg := getmodalhandle()
   LOCAL hWnd, oWindow, aControls, i

   IF .NOT. msmode[ improc, 1 ]
      IF .NOT. FileLock()
      EndDialog( hDlg )

      RETURN NIL
   ENDIF
ENDIF
SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
IF nAct == 1
   REINDEX
ELSEIF nAct == 2
   PACK
ELSEIF nAct == 3
   ZAP
ENDIF

hWnd := SendMessage( HWindow():GetMain():handle, WM_MDIGETACTIVE,0,0 )
oWindow := HWindow():FindWindow( hWnd )
IF oWindow != Nil
   aControls := oWindow:aControls
   IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
      RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
   ENDIF
ENDIF

EndDialog( hDlg )

RETURN NIL

