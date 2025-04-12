/*
 * DBCHW - DBC ( Harbour + HWGUI )
 * Database structure handling
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

memvar mypath, obrwfont, improc,msfile

FUNCTION StruMan( lNew )
Local oModDlg
Local at := { "Character", "Numeric", "Date", "Logical", "Memo" }
LOCAL af, oBrw

   IF lNew
      af := { {"", "", 0, 0} }
   ELSE
      af := dbStruct()
   ENDIF

   INIT DIALOG oModDlg FROM RESOURCE "DLG_STRU"

   REDEFINE BROWSE oBrw ARRAY OF oModDlg ID ID_BROWSE  ;
       ON CLICK {|o|SetField(o)}
   REDEFINE COMBOBOX at OF oModDlg ID IDC_COMBOBOX2

   DIALOG ACTIONS OF oModDlg ;
          ON 0,IDOK        ACTION {|o| EndStru(o,lNew)}   ;
          ON BN_CLICKED,IDC_PUSHBUTTON2 ACTION {|| ModiStru(1) }  ;
          ON BN_CLICKED,IDC_PUSHBUTTON3 ACTION {|| ModiStru(2) }  ;
          ON BN_CLICKED,IDC_PUSHBUTTON4 ACTION {|| ModiStru(3) }  ;
          ON BN_CLICKED,IDC_PUSHBUTTON5 ACTION {|| ModiStru(4) }

   oBrw:aArray := af
   oBrw:AddColumn( HColumn():New( "Name",{|value,o|o:aArray[o:nCurrent, 1] }, "C", 10, 0  ) )
   oBrw:AddColumn( HColumn():New( "Type",{|value,o|o:aArray[o:nCurrent, 2] }, "C", 4, 0  ) )
   oBrw:AddColumn( HColumn():New( "Length",{|value,o|o:aArray[o:nCurrent, 3] }, "N", 4, 0  ) )
   oBrw:AddColumn( HColumn():New( "Dec",{|value,o|o:aArray[o:nCurrent, 4] }, "N", 2, 0  ) )
   oBrw:bcolorSel := hwg_VColor( "800080" )
   oBrw:ofont      := oBrwFont

   oModDlg:Activate()
RETURN NIL

STATIC FUNCTION SetField(oBrw)
Local hDlg := hwg_GetModalHandle(), i
   hwg_SetDlgItemText( hDlg, IDC_EDIT2, oBrw:aArray[oBrw:nCurrent, 1] )
   IF ( i := At( oBrw:aArray[oBrw:nCurrent, 2], "CNDLM" ) ) != 0
      hwg_ComboSetString( hwg_GetDlgItem( hDlg, IDC_COMBOBOX2 ), i )
   ENDIF
   hwg_SetDlgItemText( hDlg, IDC_EDIT3, LTrim(Str(oBrw:aArray[oBrw:nCurrent, 3])) )
   hwg_SetDlgItemText( hDlg, IDC_EDIT4, LTrim(Str(oBrw:aArray[oBrw:nCurrent, 4])) )
RETURN NIL

STATIC FUNCTION ModiStru( nOper )
Local oDlg := hwg_GetModalDlg(), hDlg := oDlg:handle
Local oBrowse := oDlg:FindControl( ID_BROWSE )
Local cName, cType, nLen, nDec := 0

   IF nOper < 4
      cName := hwg_GetDlgItemText( hDlg, IDC_EDIT2, 10 )
      IF Empty(cName)
         hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT2 ) )
         RETURN NIL
      ENDIF
      cType := Left(hwg_GetDlgItemText( hDlg, IDC_COMBOBOX2, 10 ), 1)
      IF Empty(cType)
         hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_COMBOBOX2 ) )
         RETURN NIL
      ENDIF
      IF cType == "D" 
         nLen := 8
      ELSEIF cType == "L" 
         nLen := 1
      ELSEIF cType == "M" 
         nLen := 10
      ELSE
         nLen  := Val( hwg_GetDlgItemText( hDlg, IDC_EDIT3, 10 ) )
         IF nLen == 0
            hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT3 ) )
            RETURN NIL
         ENDIF
         IF cType == "N" 
            nDec  := Val( hwg_GetDlgItemText( hDlg, IDC_EDIT4, 10 ) )
         ENDIF
      ENDIF
      IF nOper == 3 .OR. ( oBrowse:nRecords == 1 .AND. Empty(oBrowse:aArray[1, 1]) )
         oBrowse:aArray[oBrowse:nCurrent] := { cName, cType, nLen, nDec }
      ELSEIF nOper == 1
         AAdd(oBrowse:aArray, {cName, cType, nLen, nDec})
         oBrowse:nRecords ++
      ELSEIF nOper == 2
         AAdd(oBrowse:aArray, NIL)
         Ains( oBrowse:aArray, oBrowse:nCurrent )
         oBrowse:aArray[oBrowse:nCurrent] := { cName, cType, nLen, nDec }
         oBrowse:nRecords ++
      ENDIF
   ELSEIF nOper == 4
      Adel( oBrowse:aArray,oBrowse:nCurrent )
      ASize(oBrowse:aArray, Len(oBrowse:aArray) - 1)
      oBrowse:nRecords --
   ENDIF
   hwg_RedrawWindow( oBrowse:handle, RDW_ERASE + RDW_INVALIDATE )
RETURN NIL

STATIC FUNCTION EndStru( oDlg,lNew )
Local fname, alsname
Local A1,A2,A3,A4,B1,B2,B3,B4,C1,C2
Local fi1, kolf, i, j
Local oBrowse := oDlg:FindControl( ID_BROWSE )
Local oWindow, aControls
Local oPBar, nSch := 0

   IF lNew
      IF Empty(fname := hwg_SaveFile("*.dbf", "xBase files( *.dbf )", "*.dbf", mypath))
         RETURN NIL
      ENDIF
      mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
      DBCreate(fname, oBrowse:aArray)
      OpenDbf(fname)
   ELSE
      alsname := Alias()
      kolf := Fcount()
      A1   := ARRAY( kolf )
      A2   := ARRAY( kolf )
      A3   := ARRAY( kolf )
      A4   := ARRAY( kolf )
      AFIELDS( A1, A2, A3, A4 )
      SELECT 20
      fi1 := mypath + "a0_new"
      DBCreate(fi1, oBrowse:aArray)
      USE ( fi1 )
      kolf := Fcount()
      B1   := ARRAY( kolf )
      B2   := ARRAY( kolf )
      B3   := ARRAY( kolf )
      B4   := ARRAY( kolf )
      C1   := ARRAY( kolf )
      C2   := ARRAY( kolf )
      AFIELDS( B1, B2, B3, B4 )
      FOR i := 1 TO kolf
         j := ASCAN( A1, B1[i] )
         IF j > 0
            C2[i] = j
            IF B2[i] = A2[j] .AND. B3[i] = A3[j] .AND. B4[i] = A4[j]
               IF C1[i] = NIL
                  C1[i] := &( "{|param|param}" )
               ENDIF
            ELSE
               IF C1[i] = NIL
                  DO CASE
                  CASE A2[j] = "C" .AND. B2[i] = "N"
                     C1[i] := &( "{|param|VAL(param)}" )
                  CASE A2[j] = "N" .AND. B2[i] = "C"
                     C1[i] := &( "{|param|LTRIM(STR(param," + LTrim(Str(A3[j], 2)) + "," + LTrim(Str(A4[j], 2)) + "))}" )
                  CASE A2[j] = "C" .AND. B2[i] = "C"
                     C1[i] := &( "{|param|SUBSTR(param,1," + LTrim(Str(A3[j], 4)) + ")}" )
                  CASE A2[j] = "N" .AND. B2[i] = "N"
                     C1[i] := &( "{|param|param}" )
                  OTHERWISE
                     //           C1[i] := &("{|param|param}")
                  ENDCASE
               ENDIF
            ENDIF
         ENDIF
      NEXT
      SELECT( improc )
      oPBar := HProgressBar():NewBox( "Structure updating ...",,,,, 10,RecCount() )
      GO TOP
      DO WHILE !EOF()
         SELECT 20
         APPEND BLANK
         FOR i := 1 TO kolf
            IF C1[i] != NIL
               FIELDPUT( i, Eval(C1[i], (alsname)->(FIELDGET(C2[i]))))
            ENDIF
         NEXT
         SELECT( improc )
         SKIP
         oPBar:Step()
      ENDDO
      oPBar:Close()
      SELECT( improc )
      USE
      SELECT 20
      USE
      fi1 := hwg_Cutexten( msfile[improc] )
      ERASE &(fi1+".bak")
      FRename(fi1 + ".dbf", fi1 + ".bak")
      FRename(mypath + "a0_new.DBF", fi1 + ".dbf")
      IF FILE(mypath + "a0_new.fpt")
         FRename(mypath + "a0_new.fpt", fi1 + ".fpt")
      ENDIF
      SELECT( improc )
      USE (fi1)

      oWindow := HMainWindow():GetMdiActive()
      IF oWindow != NIL
         aControls := oWindow:aControls
         IF ( i := Ascan( aControls, {|o|o:classname() == "HBROWSE"} ) ) > 0
            oBrowse := aControls[i]
            hwg_CreateList( oBrowse, .T. )
         ENDIF
      ENDIF
   ENDIF
   EndDialog( hwg_GetModalHandle() )
RETURN NIL

