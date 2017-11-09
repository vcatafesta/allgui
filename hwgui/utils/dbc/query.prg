/*
* DBCHW - DBC ( Harbour + HWGUI )
* SQL queries
* Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#ifdef RDD_ADS
#include "ads.ch"
#endif

MEMVAR mypath, numdriv

STATIC cQuery := ""

FUNCTION OpenQuery

   LOCAL fname := SelectFile( "Query files( *.que )", "*.que", mypath )

   IF !Empty( fname )
      mypath := "\" + CURDIR() + IIF( EMPTY( CURDIR() ), "", "\" )
      cQuery := MemoRead( fname )
      Query( .T. )
   ENDIF

   RETURN NIL

FUNCTION Query( lEdit )

   LOCAL aModDlg

   IF !lEdit
      cQuery := ""
   ENDIF

   INIT DIALOG aModDlg FROM RESOURCE "DLG_QUERY" ON INIT {|| InitQuery() }
   DIALOG ACTIONS OF aModDlg ;
      ON 0,IDCANCEL     ACTION {|| EndQuery(.F.) }  ;
      ON BN_CLICKED,IDC_BTNEXEC ACTION {|| EndQuery(.T.) } ;
      ON BN_CLICKED,IDC_BTNSAVE ACTION {|| QuerySave() }
   aModDlg:Activate()

   RETURN NIL

STATIC FUNCTION InitQuery()

   LOCAL hDlg := getmodalhandle()

   SetDlgItemText( hDlg, IDC_EDITQUERY, cQuery )
   SetFocus( GetDlgItem( hDlg, IDC_EDITQUERY ) )

   RETURN NIL

STATIC FUNCTION EndQuery( lOk )

   LOCAL hDlg := getmodalhandle()
   LOCAL oldArea := Alias(), tmpdriv, tmprdonly
   LOCAL id1
   LOCAL aChildWnd, hChild

   STATIC lConnected := .F.

   IF lOk
      cQuery := GetEditText( hDlg, IDC_EDITQUERY )
      IF Empty( cQuery )
         SetFocus( GetDlgItem( hDlg, IDC_EDITQUERY ) )

         RETURN NIL
      ENDIF

      IF numdriv == 2
         MsgStop( "You shoud switch to ADS_CDX or ADS_ADT to run query" )

         RETURN .F.
      ENDIF
      #ifdef RDD_ADS
      IF !lConnected
         IF Empty( mypath )
            AdsConnect( "\" + CURDIR() + IIF( EMPTY( CURDIR() ), "", "\" ) )
         ELSE
            AdsConnect( mypath )
         ENDIF
         lConnected := .T.
      ENDIF
      IF Select( "ADSSQL" ) > 0
         SELECT ADSSQL
         USE
      ELSE
         SELECT 0
      ENDIF
      IF !AdsCreateSqlStatement( ,Iif( numdriv==1,2,3 ) )
         MsgStop( "Cannot create SQL statement" )
         IF !Empty( oldArea )
            Select( oldArea )
         ENDIF

         RETURN .F.
      ENDIF
      SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF !AdsExecuteSqlDirect( cQuery )
         MsgStop( "SQL execution failed" )
         IF !Empty( oldArea )
            Select( oldArea )
         ENDIF

         RETURN .F.
      ELSE
         IF Alias() == "ADSSQL"
            improc := Select( "ADSSQL" )
            tmpdriv := numdriv; tmprdonly := prrdonly
            numdriv := 3; prrdonly := .T.
            // Fiopen()
            nQueryWndHandle := OpenDbf( ,"ADSSQL",nQueryWndHandle )
            numdriv := tmpdriv; prrdonly := tmprdonly
            /*
            SET CHARTYPE TO ANSI
            __dbCopy( mypath+"_dbc_que.dbf",,,,,, .F. )
            SET CHARTYPE TO OEM
            FiClose()
            nQueryWndHandle := OpenDbf( mypath+"_dbc_que.dbf","ADSSQL",nQueryWndHandle )
            */
         ELSE
            IF !Empty( oldArea )
               Select( oldArea )
            ENDIF
            MsgStop( "Statement doesn't returns cursor" )

            RETURN .F.
         ENDIF
      ENDIF
      #endif
   ENDIF

EndDialog( hDlg )

RETURN .T.

FUNCTION QuerySave

   LOCAL fname := SaveFile( "*.que","Query files( *.que )", "*.que", mypath )

   cQuery := GetDlgItemText( getmodalhandle(), IDC_EDITQUERY, 400 )
   IF !Empty( fname )
      MemoWrit( fname,cQuery )
   ENDIF

   RETURN NIL

