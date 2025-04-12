/*
 * DBCHW - DBC ( Harbour + HWGUI )
 * SQL queries
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
#ifdef RDD_ADS
#include "ads.ch"
#endif

memvar mypath, numdriv
STATIC cQuery := ""

FUNCTION OpenQuery
Local fname := hwg_SelectFile("Query files( *.que )", "*.que", mypath)

   IF !Empty(fname)
      mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
      cQuery := MemoRead(fname)
      Query( .T. )
   ENDIF

RETURN NIL

FUNCTION Query( lEdit )
Local aModDlg

   IF !lEdit
      cQuery := ""
   ENDIF

   INIT DIALOG aModDlg FROM RESOURCE "DLG_QUERY" ON INIT {|| InitQuery() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDCANCEL     ACTION {|| EndQuery(.F.) }  ;
        ON BN_CLICKED, IDC_BTNEXEC ACTION {|| EndQuery(.T.) } ;
        ON BN_CLICKED, IDC_BTNSAVE ACTION {|| QuerySave() }
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitQuery()
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText( hDlg, IDC_EDITQUERY, cQuery )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDITQUERY ) )
RETURN NIL

STATIC FUNCTION EndQuery( lOk )
Local hDlg := hwg_GetModalHandle()
Local oldArea := Alias(), tmpdriv, tmprdonly
Local id1
Local aChildWnd, hChild
STATIC lConnected := .F.

   IF lOk
      cQuery := hwg_GetEditText( hDlg, IDC_EDITQUERY )
      IF Empty(cQuery)
         hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDITQUERY ) )
         RETURN NIL
      ENDIF

      IF numdriv == 2
         hwg_MsgStop( "You shoud switch to ADS_CDX or ADS_ADT to run query" )
         RETURN .F.
      ENDIF
#ifdef RDD_ADS
      IF !lConnected
         IF Empty(mypath)
            AdsConnect( "\" + CurDir() + IIf(Empty(CurDir()), "", "\") )
         ELSE
            AdsConnect( mypath )
         ENDIF
         lConnected := .T.
      ENDIF
      IF Select( "ADSSQL" ) > 0
         Select ADSSQL
         USE
      ELSE
         SELECT 0
      ENDIF
      IF !AdsCreateSqlStatement( , IIf(numdriv == 1, 2, 3) )
         hwg_MsgStop( "Cannot create SQL statement" )
         IF !Empty(oldArea)
            Select( oldArea )
         ENDIF
         RETURN .F.
      ENDIF
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF !AdsExecuteSqlDirect( cQuery )
         hwg_MsgStop( "SQL execution failed" )
         IF !Empty(oldArea)
            Select( oldArea )
         ENDIF
         RETURN .F.
      ELSE
         IF Alias() == "ADSSQL"
            improc := Select( "ADSSQL" )
            tmpdriv := numdriv; tmprdonly := prrdonly
            numdriv := 3; prrdonly := .T.
            // Fiopen()
            nQueryWndHandle := OpenDbf(, "ADSSQL", nQueryWndHandle)
            numdriv := tmpdriv; prrdonly := tmprdonly
            /*
            SET CHARTYPE TO ANSI
            __dbCopy( mypath+"_dbc_que.dbf",,,,,, .F. )
            SET CHARTYPE TO OEM
            FiClose()
            nQueryWndHandle := OpenDbf(mypath + "_dbc_que.dbf", "ADSSQL", nQueryWndHandle)
            */
         ELSE
            IF !Empty(oldArea)
               Select( oldArea )
            ENDIF
            hwg_MsgStop( "Statement doesn't returns cursor" )
            RETURN .F.
         ENDIF
      ENDIF
#endif
   ENDIF

   EndDialog( hDlg )
RETURN .T.

FUNCTION QuerySave
Local fname := hwg_SaveFile("*.que", "Query files( *.que )", "*.que", mypath)
   cQuery := hwg_GetDlgItemText( hwg_GetModalHandle(), IDC_EDITQUERY, 400 )
   IF !Empty(fname)
      MemoWrit( fname, cQuery )
   ENDIF
RETURN NIL
