//
// Repbuild - Visual Report Builder
// Edit properties of items
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "windows.ch"
#include "guilib.ch"
#include "repbuild.h"
#include "repmain.h"

#define UDS_SETBUDDYINT     2
#define UDS_ALIGNRIGHT      4

STATIC s_aPenStyles := {"SOLID", "DASH", "DOT", "DASHDOT", "DASHDOTDOT"}
STATIC s_aVariables := {"Static", "Variable"}
memvar apaintrep, mypath
FUNCTION LButtonDbl(xPos, yPos)
Local i, aItem

   FOR i := Len(aPaintRep[FORM_ITEMS]) TO 1 STEP -1
      aItem := aPaintRep[FORM_ITEMS, i]
      IF xPos >= LEFT_INDENT+aItem[ITEM_X1] ;
           .AND. xPos < LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH] ;
           .AND. yPos > TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] ;
           .AND. yPos < TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT]
         aPaintRep[FORM_ITEMS, i, ITEM_STATE] := STATE_SELECTED
         IF aItem[ITEM_TYPE] == TYPE_TEXT
            StaticDlg(aItem)
         ELSEIF aItem[ITEM_TYPE] == TYPE_HLINE .OR. aItem[ITEM_TYPE] == TYPE_VLINE .OR. aItem[ITEM_TYPE] == TYPE_BOX
            LineDlg(aItem)
         ELSEIF aItem[ITEM_TYPE] == TYPE_BITMAP
            BitmapDlg(aItem)
         ELSEIF aItem[ITEM_TYPE] == TYPE_MARKER
            IF aItem[ITEM_CAPTION] == "SL" .OR. aItem[ITEM_CAPTION] == "EL"
               MarkLDlg(aItem)
            ELSEIF aItem[ITEM_CAPTION] == "DF"
               MarkFDlg(aItem)
            ENDIF
         ENDIF
         EXIT
      ENDIF
   NEXT
RETURN NIL

STATIC FUNCTION StaticDlg(aItem)
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE  "DLG_STATIC" ON INIT {||InitStatic(aItem)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndStatic(aItem)}  ;
        ON BN_CLICKED, IDC_PUSHBUTTON1 ACTION {||SetItemFont(aItem)}
   REDEFINE COMBOBOX s_aVariables OF aModDlg ID IDC_COMBOBOX3 INIT aItem[ITEM_VAR]+1
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitStatic(aItem)
Local hDlg := hwg_GetModalHandle()
Local oFont := aItem[ITEM_FONT]
   hwg_CheckRadioButton(hDlg, IDC_RADIOBUTTON1, IDC_RADIOBUTTON3, ;
     IIf(aItem[ITEM_ALIGN] == 0, IDC_RADIOBUTTON1, IIf(aItem[ITEM_ALIGN] == 1, IDC_RADIOBUTTON2, IDC_RADIOBUTTON3)))
   hwg_SetDlgItemText(hDlg, IDC_EDIT1, aItem[ITEM_CAPTION])
   IF aItem[ITEM_SCRIPT] != NIL
      hwg_SetDlgItemText(hDlg, IDC_EDIT3, aItem[ITEM_SCRIPT])
   ENDIF
   // SetComboBox(hDlg, IDC_COMBOBOX3, s_aVariables, aItem[ITEM_VAR]+1)
   hwg_SetDlgItemText(hDlg, IDC_TEXT1, oFont:name+","+Ltrim(Str(oFont:width))+","+Ltrim(Str(oFont:height)))
   hwg_SetFocus(hwg_GetDlgItem(hDlg, IDC_EDIT1))
RETURN .T.

STATIC FUNCTION EndStatic(aItem)
Local hDlg := hwg_GetModalHandle()

   aItem[ITEM_CAPTION] := hwg_GetEditText(hDlg, IDC_EDIT1)
   aItem[ITEM_ALIGN] := IIf(hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON1), 0, ;
                          IIf(hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON2), 1, 2))
   aItem[ITEM_VAR] := AScan(s_aVariables, hwg_GetDlgItemText(hDlg, IDC_COMBOBOX3, 12)) - 1
   aItem[ITEM_SCRIPT] := hwg_GetEditText(hDlg, IDC_EDIT3)
   aPaintRep[FORM_CHANGED] := .T.
   EndDialog(hDlg)
RETURN .T.

STATIC FUNCTION SetItemFont(aItem)
Local hDlg := hwg_GetModalHandle()
Local oFont := HFont():Select()
   IF oFont != NIL
      aItem[ITEM_FONT] := oFont
      hwg_SetDlgItemText(hDlg, IDC_TEXT1, oFont:name+","+Ltrim(Str(oFont:width))+","+Ltrim(Str(oFont:height)))
   ENDIF
RETURN .T.

STATIC FUNCTION LineDlg(aItem)
Local aModDlg
Local oPen := aItem[ITEM_PEN]

   INIT DIALOG aModDlg FROM RESOURCE "DLG_LINE" ON INIT {||InitLine(aItem)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndLine(aItem)}
   REDEFINE COMBOBOX s_aPenStyles OF aModDlg ID IDC_COMBOBOX1 INIT oPen:style+1
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitLine(aItem)
Local hDlg := hwg_GetModalHandle()
Local oPen := aItem[ITEM_PEN]
   // SetComboBox(hDlg, IDC_COMBOBOX1, s_aPenStyles, aPen[1]+1)
   IF aItem[ITEM_TYPE] == TYPE_BOX
   ELSE
      hwg_SendMessage(hwg_GetDlgItem(hDlg, IDC_COMBOBOX2), WM_ENABLE, 0, 0)
   ENDIF
   hwg_SetDlgItemText(hDlg, IDC_EDIT1, Str(oPen:width, 1))
RETURN .T.

STATIC FUNCTION EndLine(aItem)
Local hDlg := hwg_GetModalHandle()
Local nWidth := Val(hwg_GetEditText(hDlg, IDC_EDIT1))
Local cType := hwg_GetDlgItemText(hDlg, IDC_COMBOBOX1, 12), i
Local oPen := aItem[ITEM_PEN]
   i := Ascan(s_aPenStyles, cType)
   IF oPen:style != i-1 .OR. oPen:width != nWidth
      oPen:Release()
      aItem[ITEM_PEN] := HPen():Add(i - 1, nWidth, 0)
      aPaintRep[FORM_CHANGED] := .T.
   ENDIF
   EndDialog(hDlg)
RETURN .T.

FUNCTION BitmapDlg(aItem)
Local aModDlg, res := .T.

   INIT DIALOG aModDlg FROM RESOURCE "DLG_BITMAP" ON INIT {||InitBitmap(aItem)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndBitmap(aItem)}  ;
        ON 0, IDCANCEL     ACTION {||res := .F., EndDialog(hwg_GetModalHandle())} ;
        ON BN_CLICKED, IDC_BUTTONBRW ACTION {||OpenBmp(aItem, hwg_SelectFile("Bitmap files( *.bmp )", "*.bmp", mypath))} ;
        ON EN_CHANGE, IDC_EDIT3 ACTION {||UpdateProcent(aItem)}
   aModDlg:Activate()

RETURN res

STATIC FUNCTION OpenBmp(aItem, fname)
Local hDlg := hwg_GetModalHandle()
   Local aBmpSize
   hwg_SetDlgItemText(hDlg, IDC_EDIT1, fname)
   IF !Empty(fname)
      IF aItem[ITEM_BITMAP] != NIL
         hwg_DeleteObject(aItem[ITEM_BITMAP]:handle)
      ENDIF
      aItem[ITEM_CAPTION] := fname
      aItem[ITEM_BITMAP] := HBitmap():AddFile(fname)
      aBmpSize := hwg_GetBitmapSize(aItem[ITEM_BITMAP]:handle)
      aItem[ITEM_WIDTH] :=  aItem[ITEM_BITMAP]:nWidth
      aItem[ITEM_HEIGHT] := aItem[ITEM_BITMAP]:nHeight
      hwg_SetDlgItemText(hDlg, IDC_TEXT1, Ltrim(Str(aBmpSize[1]))+"x"+Ltrim(Str(aBmpSize[2])))
      hwg_SetDlgItemText(hDlg, IDC_TEXT2, Ltrim(Str(aItem[ITEM_WIDTH]))+"x"+Ltrim(Str(aItem[ITEM_HEIGHT])))
   ENDIF
RETURN NIL

STATIC FUNCTION UpdateProcent(aItem)
Local hDlg := hwg_GetModalHandle()
Local nValue := Val(hwg_GetEditText(hDlg, IDC_EDIT3))
Local aBmpSize
   IF aItem[ITEM_BITMAP] != NIL
      aBmpSize := hwg_GetBitmapSize(aItem[ITEM_BITMAP]:handle)
      hwg_SetDlgItemText(hDlg, IDC_TEXT2, Ltrim(Str(Round(aBmpSize[1]*nValue/100, 0)))+"x"+Ltrim(Str(Round(aBmpSize[2]*nValue/100, 0))))
   ENDIF
RETURN NIL

STATIC FUNCTION InitBitmap(aItem)
Local hDlg := hwg_GetModalHandle()
Local aBmpSize, hUp
   hUp := hwg_CreateUpDownControl(hDlg, 120, UDS_ALIGNRIGHT+UDS_SETBUDDYINT, 0, 0, 12, 0, hwg_GetDlgItem(hDlg, IDC_EDIT3), 500, 1, 100)
   IF aItem[ITEM_BITMAP] != NIL
      aBmpSize := hwg_GetBitmapSize(aItem[ITEM_BITMAP]:handle)
      hwg_SetDlgItemText(hDlg, IDC_EDIT1, aItem[ITEM_CAPTION])
      hwg_SetDlgItemText(hDlg, IDC_TEXT1, Ltrim(Str(aBmpSize[1]))+"x"+Ltrim(Str(aBmpSize[2])))
      hwg_SetDlgItemText(hDlg, IDC_TEXT2, Ltrim(Str(aItem[ITEM_WIDTH]))+"x"+Ltrim(Str(aItem[ITEM_HEIGHT])))
      hwg_SetUpDown(hUp, Round(aItem[ITEM_WIDTH]*100/aBmpSize[1], 0))
   ENDIF
RETURN .T.

STATIC FUNCTION EndBitmap(aItem)
Local hDlg := hwg_GetModalHandle()
Local nValue := Val(hwg_GetEditText(hDlg, IDC_EDIT3))
Local aBmpSize := hwg_GetBitmapSize(aItem[ITEM_BITMAP]:handle)

   aItem[ITEM_WIDTH] := Round(aBmpSize[1]*nValue/100, 0)
   aItem[ITEM_HEIGHT] := Round(aBmpSize[2]*nValue/100, 0)
   aPaintRep[FORM_CHANGED] := .T.
   EndDialog(hDlg)
RETURN .T.

FUNCTION MarkLDlg(aItem)
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKL" ON INIT {||InitMarkL(aItem)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndMarkL(aItem)}  ;
        ON 0, IDCANCEL     ACTION {||EndDialog(hwg_GetModalHandle())}
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitMarkL(aItem)
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText(hDlg, IDC_TEXT1, "Script:")
   IF HB_IsChar(aItem[ITEM_SCRIPT])
      hwg_SetDlgItemText(hDlg, IDC_EDIT1, aItem[ITEM_SCRIPT])
   ENDIF
RETURN .T.

STATIC FUNCTION EndMarkL(aItem)
Local hDlg := hwg_GetModalHandle()
   aItem[ITEM_SCRIPT] := hwg_GetEditText(hDlg, IDC_EDIT1)
   aPaintRep[FORM_CHANGED] := .T.
   EndDialog(hDlg)
RETURN .T.

FUNCTION MarkFDlg(aItem)
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKF" ON INIT {||InitMarkF(aItem)}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndMarkF(aItem)}  ;
        ON 0, IDCANCEL     ACTION {||EndDialog(hwg_GetModalHandle())}
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitMarkF(aItem)
Local hDlg := hwg_GetModalHandle()
   hwg_CheckRadioButton(hDlg, IDC_RADIOBUTTON1, IDC_RADIOBUTTON2, ;
      IIf(aItem[ITEM_ALIGN] == 0, IDC_RADIOBUTTON1, IDC_RADIOBUTTON2))
RETURN .T.

STATIC FUNCTION EndMarkF(aItem)
Local hDlg := hwg_GetModalHandle()
   aItem[ITEM_ALIGN] := IIf(hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON1), 0, 1)
   aPaintRep[FORM_CHANGED] := .T.
   EndDialog(hDlg)
RETURN .T.

FUNCTION FormOptions()
Local aModDlg

   INIT DIALOG aModDlg FROM RESOURCE "DLG_MARKL" ON INIT {||InitFOpt()}
   DIALOG ACTIONS OF aModDlg ;
        ON 0, IDOK         ACTION {||EndFOpt()}  ;
        ON 0, IDCANCEL     ACTION {||EndDialog(hwg_GetModalHandle())}
   aModDlg:Activate()

RETURN NIL

STATIC FUNCTION InitFOpt()
Local hDlg := hwg_GetModalHandle()
   hwg_SetDlgItemText(hDlg, IDC_TEXT1, "Variables:")
   IF HB_IsChar(aPaintRep[FORM_VARS])
      hwg_SetDlgItemText(hDlg, IDC_EDIT1, aPaintRep[FORM_VARS])
   ENDIF
RETURN .T.

STATIC FUNCTION EndFOpt(aItem)
Local hDlg := hwg_GetModalHandle()
   aPaintRep[FORM_VARS] := hwg_GetEditText(hDlg, IDC_EDIT1)
   aPaintRep[FORM_CHANGED] := .T.
   EndDialog(hDlg)
RETURN .T.

