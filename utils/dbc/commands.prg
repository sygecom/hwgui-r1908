/*
 * DBCHW - DBC ( Harbour + HWGUI )
 * Commands ( Replace, delete, ... )
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "dbchw.h"
// #include "ads.ch"

MEMVAR finame, cValue, cFor, nSum, mypath, improc, msmode
/* -----------------------  Replace --------------------- */

Function C_REPL
Local aModDlg
Local af := Array( Fcount() )
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

STATIC Function RecNumberEdit
Local hDlg := hwg_GetModalHandle()
Local hEdit := hwg_GetDlgItem( hDlg,IDC_EDITRECN )
   hwg_SendMessage(hEdit, WM_ENABLE, 1, 0)
   hwg_SetDlgItemText( hDlg, IDC_EDITRECN, "1" )
   hwg_SetFocus( hEdit )
RETURN NIL

STATIC Function RecNumberDisable
Local hEdit := hwg_GetDlgItem( hwg_GetModalHandle(),IDC_EDITRECN )
   hwg_SendMessage(hEdit, WM_ENABLE, 0, 0)
RETURN NIL

STATIC Function InitRepl()
Local hDlg := hwg_GetModalHandle()

   RecNumberDisable()
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_COMBOBOX1 ) )
RETURN NIL

STATIC Function EndRepl()
Local hDlg := hwg_GetModalHandle()
Local nrest, nrec
Local oWindow, aControls, i
Private finame, cValue, cFor

   oWindow := HMainWindow():GetMdiActive()

   finame := hwg_GetDlgItemText( hDlg, IDC_COMBOBOX1, 12 )
   IF Empty(finame)
      hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_COMBOBOX1 ) )
      RETURN NIL
   ENDIF
   cValue := hwg_GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF Empty(cValue)
      hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT7 ) )
      RETURN NIL
   ENDIF
   cFor := hwg_GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF !Empty(cFor) .AND. TYPE(cFor) != "L"
      hwg_MsgStop( "Wrong expression!" )
   ELSE
      IF Empty(cFor)
         cFor := ".T."
      ENDIF
      nrec := Recno()
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
         REPLACE ALL &finame WITH &cValue FOR &cFor
      ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
         nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
         REPLACE NEXT nrest &finame WITH &cValue FOR &cFor
      ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
         REPLACE REST &finame WITH &cValue FOR &cFor
      ENDIF
      Go nrec
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Done !" )
      IF oWindow != NIL
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
            aControls[i]:Refresh()
         ENDIF
      ENDIF
   ENDIF
RETURN NIL

/* -----------------------  Delete, recall, count --------------------- */

Function C_DELE(nAct)
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_DEL" ON INIT {|| InitDele(nAct) }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndDele(nAct)}   ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() )}  ;
        ON BN_CLICKED,IDC_RADIOBUTTON7 ACTION {|| RecNumberEdit() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON6 ACTION {|| RecNumberDisable() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON8 ACTION {|| RecNumberDisable() }
   aModDlg:Activate()

RETURN NIL

STATIC Function InitDele(nAct)
Local hDlg := hwg_GetModalHandle()
   IF nAct == 2
      hwg_SetWindowText( hDlg,"Recall")
   ELSEIF nAct == 3
      hwg_SetWindowText( hDlg,"Count")
   ENDIF
   RecNumberDisable()
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDITFOR ) )
RETURN NIL

STATIC Function EndDele(nAct)
Local hDlg := hwg_GetModalHandle()
Local nrest, nsum, nRec := Recno()
Local oWindow, aControls, i
Private cFor

   oWindow := HMainWindow():GetMdiActive()

   cFor := hwg_GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF !Empty(cFor) .AND. TYPE(cFor) != "L"
      hwg_MsgStop( "Wrong expression!" )
   ELSE
      IF Empty(cFor)
         cFor := ".T."
      ENDIF
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      IF nAct == 1
         IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
            DELETE ALL FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
            nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            DELETE NEXT nrest FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
            DELETE REST FOR &cFor
         ENDIF
      ELSEIF nAct == 2
         IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
            RECALL ALL FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
            nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            RECALL NEXT nrest FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
            RECALL REST FOR &cFor
         ENDIF
      ELSEIF nAct == 3
         IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
            COUNT TO nsum ALL FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
            nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
            COUNT TO nsum NEXT nrest FOR &cFor
         ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
            COUNT TO nsum REST FOR &cFor
         ENDIF
         hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Result: "+Str(nsum) )
         Go nrec
         RETURN NIL
      ENDIF
      Go nrec
      hwg_WriteStatus( oWindow, 3,"Done" )
      IF oWindow != NIL
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
            hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
         ENDIF
      ENDIF
   ENDIF

   EndDialog( hDlg )
RETURN NIL

/* -----------------------  Sum --------------------- */

Function C_SUM()
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_SUM" ON INIT {|| InitSum() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndSum()}   ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() )}  ;
        ON BN_CLICKED,IDC_RADIOBUTTON7 ACTION {|| RecNumberEdit() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON6 ACTION {|| RecNumberDisable() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON8 ACTION {|| RecNumberDisable() }
   aModDlg:Activate()

RETURN NIL

STATIC Function InitSum()
Local hDlg := hwg_GetModalHandle()
   RecNumberDisable()
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON6,IDC_RADIOBUTTON8,IDC_RADIOBUTTON6 )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT7 ) )
RETURN NIL

STATIC Function EndSum()
Local hDlg := hwg_GetModalHandle()
Local cSumf, cFor, nrest, blsum, blfor, nRec := Recno()
Private nsum := 0

   cSumf := hwg_GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF Empty(cSumf)
      hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT7 ) )
      RETURN NIL
   ENDIF

   cFor := hwg_GetDlgItemText( hDlg, IDC_EDITFOR, 60 )
   IF ( !Empty(cFor) .AND. TYPE(cFor) != "L" ) .OR. TYPE(cSumf) != "N"
      hwg_MsgStop( "Wrong expression!" )
   ELSE
      IF Empty(cFor)
         cFor := ".T."
      ENDIF
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
      blsum := &( "{||nsum:=nsum+" + cSumf + "}" )
      blfor := &( "{||" + cFor + "}" )
      IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
         DBEval(blsum, blfor)
      ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
         nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
         DBEval(blsum, blfor, , nrest)
      ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
         DBEval(blsum, blfor, , , , .T.)
      ENDIF
      Go nrec
      hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Result: "+Str(nsum) )
      RETURN NIL
   ENDIF

   EndDialog( hDlg )
RETURN NIL

/* -----------------------  Append from --------------------- */

Function C_APPEND()
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_APFROM" ON INIT {|| InitApp() }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndApp()}  ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() )}  ;
        ON BN_CLICKED,IDC_BUTTONBRW ACTION {||hwg_SetDlgItemText( hwg_GetModalHandle(), IDC_EDIT7, hwg_SelectFile("xBase files( *.dbf )", "*.dbf", mypath) ) } ;
        ON BN_CLICKED,IDC_RADIOBUTTON11 ACTION {|| DelimEdit() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON10 ACTION {|| DelimDisable() } ;
        ON BN_CLICKED,IDC_RADIOBUTTON9 ACTION {|| DelimDisable() }
   aModDlg:Activate()

RETURN NIL

STATIC Function DelimEdit
Local hDlg := hwg_GetModalHandle()
Local hEdit := hwg_GetDlgItem( hDlg,IDC_EDITDWITH )
   hwg_SendMessage(hEdit, WM_ENABLE, 1, 0)
   hwg_SetDlgItemText( hDlg, IDC_EDITDWITH, " " )
   hwg_SetFocus( hEdit )
RETURN NIL

STATIC Function DelimDisable
Local hEdit := hwg_GetDlgItem( hwg_GetModalHandle(),IDC_EDITDWITH )
   hwg_SendMessage(hEdit, WM_ENABLE, 0, 0)
RETURN NIL

STATIC Function InitApp()
Local hDlg := hwg_GetModalHandle()
   DelimDisable()
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON9,IDC_RADIOBUTTON9,IDC_RADIOBUTTON11 )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT7 ) )
RETURN NIL

STATIC Function EndApp()
Local hDlg := hwg_GetModalHandle()
Local fname, nRec := Recno()

   fname := hwg_GetDlgItemText( hDlg, IDC_EDIT7, 60 )
   IF Empty(fname)
      hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT7 ) )
      RETURN NIL
   ENDIF

   hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
   IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON6)
      // DBEval(blsum, blfor)
   ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON7)
      // nrest := Val( hwg_GetDlgItemText( hDlg, IDC_EDITRECN, 10 ) )
      // DBEval(blsum, blfor, , nrest)
   ELSEIF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON8)
      // DBEval(blsum, blfor, , , , .T.)
   ENDIF
   Go nrec

   EndDialog( hDlg )
RETURN NIL

/* -----------------------  Reindex, pack, zap --------------------- */

Function C_RPZ( nAct )
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_OKCANCEL" ON INIT {|| InitRPZ(nAct) }
   DIALOG ACTIONS OF aModDlg ;
        ON 0,IDOK         ACTION {|| EndRPZ(nAct)}   ;
        ON 0,IDCANCEL     ACTION {|| EndDialog( hwg_GetModalHandle() ) }
   aModDlg:Activate()

RETURN NIL

STATIC Function InitRPZ( nAct )
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText( hDlg, IDC_TEXTHEAD, IIf(nAct == 1, "Reindex ?", ;
                                       IIf(nAct == 2, "Pack ?", "Zap ?")) )
RETURN NIL

STATIC Function EndRPZ( nAct )
Local hDlg := hwg_GetModalHandle()
Local hWnd, oWindow, aControls, i

   IF !msmode[improc, 1]
      IF !FileLock()
         EndDialog( hDlg )
         RETURN NIL
      ENDIF
   ENDIF
   hwg_SetDlgItemText( hDlg, IDC_TEXTMSG, "Wait ..." )
   IF nAct == 1
      Reindex
   ELSEIF nAct == 2
      Pack
   ELSEIF nAct == 3
      Zap
   ENDIF

   hWnd := hwg_SendMessage(HWindow():GetMain():handle, WM_MDIGETACTIVE, 0, 0)
   oWindow := HWindow():FindWindow( hWnd )
   IF oWindow != NIL
      aControls := oWindow:aControls
      IF ( i := Ascan( aControls, {|o|o:ClassName()=="HBROWSE"} ) ) > 0
         hwg_RedrawWindow( aControls[i]:handle, RDW_ERASE + RDW_INVALIDATE )
      ENDIF
   ENDIF

   EndDialog( hDlg )
RETURN NIL
