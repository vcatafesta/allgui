/*
* $Id: query.prg 2023 2013-04-19 06:24:23Z alkresin $
* DBCHW - DBC ( Harbour + HWGUI )
* SQL queries
* Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
* www - http://www.kresin.ru
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#ifdef RDD_ADS
#include "ads.ch"
#endif

STATIC cQuery := ""

FUNCTION OpenQuery

   LOCAL fname := hwg_Selectfile( "Query files( *.que )", "*.que", mypath )

   IF !Empty( fname )
      mypath := "\" + CURDIR() + IIF( EMPTY( CURDIR() ), "", "\" )
      cQuery := MemoRead( fname )
      Query( .T. )
   ENDIF

   RETURN NIL

FUNCTION Query( lEdit )

   LOCAL oDlg
   LOCAL bBtnSave := {||
   LOCAL fname := hwg_Savefile( "*.que","Query files( *.que )", "*.que", mypath )

   IF !Empty( fname )
      hb_MemoWrit( fname,cQuery )
   ENDIF
   }
   LOCAL oldArea := Alias(), tmpdriv, tmprdonly
   LOCAL id1
   LOCAL aChildWnd, hChild

   STATIC lConnected := .F.

   IF !lEdit
      cQuery := ""
   ENDIF

   INIT DIALOG oDlg TITLE Iif( lEdit, "Edit", "New" ) + " query" ;
      AT 0, 0         ;
      SIZE 420, 250   ;
      FONT oMainFont

   @ 10, 10 GET cQuery SIZE 410, 180 STYLE ES_MULTILINE + ES_AUTOVSCROLL
   Atail( oDlg:aControls ):Anchor := ANCHOR_TOPABS + ANCHOR_LEFTABS + ANCHOR_RIGHTABS

   @  30, 210 BUTTON "Execute" SIZE 100, 32 ON CLICK { ||oDlg:lResult := .T. , hwg_EndDialog() }
   @ 160, 210 BUTTON "Save" SIZE 100, 32 ON CLICK bBtnSave
   @ 290, 210 BUTTON "Cancel" SIZE 100, 32 ON CLICK { ||hwg_EndDialog() }

   oDlg:Activate()

   IF oDlg:lResult
      IF Empty( cQuery )

         RETURN NIL
      ENDIF

      IF numdriv == 2
         hwg_Msgstop( "You shoud switch to ADS_CDX or ADS_ADT to run query" )

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
         hwg_Msgstop( "Cannot create SQL statement" )
         IF !Empty( oldArea )
            Select( oldArea )
         ENDIF

         RETURN .F.
      ENDIF
      IF !AdsExecuteSqlDirect( cQuery )
         hwg_Msgstop( "SQL execution failed" )
         IF !Empty( oldArea )
            Select( oldArea )
         ENDIF

         RETURN .F.
      ELSE
         IF Alias() == "ADSSQL"
            improc := Select( "ADSSQL" )
            tmpdriv := numdriv; tmprdonly := lRdonly
            numdriv := 3; lRdonly := .T.
            nQueryWndHandle := OpenDbf( ,"ADSSQL",nQueryWndHandle )
            numdriv := tmpdriv; lRdonly := tmprdonly
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
            hwg_Msgstop( "Statement doesn't returns cursor" )

            RETURN .F.
         ENDIF
      ENDIF
#endif
   ENDIF

   RETURN NIL
