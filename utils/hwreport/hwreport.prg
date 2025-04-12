/*
 * $Id: hwreport.prg 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * Repbuild - Visual Report Builder
 * Main file
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include "windows.ch"
#include "guilib.ch"
#include "repbuild.h"
#include "repmain.h"

#define SB_VERT         1
#define IDCW_STATUS  2001

STATIC s_nAddItem := 0
STATIC s_nMarkerType := 0
STATIC s_crossCursor
STATIC s_vertCursor
STATIC s_horzCursor
STATIC s_itemPressed := 0
STATIC s_mPos := { 0, 0 }
STATIC s_itemBorder := 0
STATIC s_itemSized := 0
STATIC s_resizeDirection := 0
STATIC s_aInitialSize := { { 50, 20 }, { 60, 4 }, { 4, 60 }, { 60, 40 }, { 40, 40 }, { 16, 10 } }
STATIC s_aMarkers := { "PH", "SL", "EL", "PF", "EPF", "DF" }
STATIC s_oPenDivider
STATIC s_oPenLine

Memvar mypath
Memvar aPaintRep
Memvar oPenBorder, oFontSmall, oFontStandard, lastFont
Memvar aItemTypes

FUNCTION Main()
Local oMainWindow, aPanel, oIcon := HIcon():AddResource("ICON_1")
Public mypath := "\" + CurDir() + IIf(Empty(CurDir()), "", "\")
Public aPaintRep := NIL
Public oPenBorder, oFontSmall, oFontStandard, lastFont := NIL
Public aItemTypes := { "TEXT", "HLINE", "VLINE", "BOX", "BITMAP", "MARKER" }

   SET DECIMALS TO 4
   s_crossCursor := hwg_LoadCursor( IDC_CROSS )
   s_horzCursor := hwg_LoadCursor( IDC_SIZEWE )
   s_vertCursor := hwg_LoadCursor( IDC_SIZENS )
   oPenBorder := HPen():Add(PS_SOLID, 1, hwg_VColor("800080"))
   s_oPenLine   := HPen():Add(PS_SOLID, 1, hwg_VColor("000000"))
   s_oPenDivider := HPen():Add(PS_DOT, 1, hwg_VColor("C0C0C0"))
   oFontSmall := HFont():Add("Small fonts", 0, -8)
   oFontStandard := HFont():Add("Arial", 0, -13, 400, 204)

   INIT WINDOW oMainWindow MAIN TITLE "Visual Report Builder"  ;
       ICON oIcon COLOR COLOR_3DSHADOW                         ;
       ON PAINT {|o|PaintMain(o)} ON EXIT {||CloseReport()}    ;
       ON OTHER MESSAGES {|o, m, wp, lp|MessagesProc(o, m, wp, lp)}

   ADD STATUS TO oMainWindow ID IDCW_STATUS PARTS 240, 180, 0

   MENU OF oMainWindow
      MENU TITLE "&File"
         MENUITEM "&New" ID IDM_NEW ACTION NewReport(oMainWindow)
         MENUITEM "&Open" ID IDM_OPEN ACTION FileDlg(.T.)
         MENUITEM "&Close" ID IDM_CLOSE ACTION CloseReport()
         SEPARATOR
         MENUITEM "&Save" ID IDM_SAVE ACTION SaveReport()
         MENUITEM "Save &as..." ID IDM_SAVEAS ACTION FileDlg(.F.)
         SEPARATOR
         MENUITEM "&Print static" ID IDM_PRINT ACTION PrintRpt()
         MENUITEM "&Print full" ID IDM_PREVIEW ACTION (hwg_ClonePaintRep(aPaintRep), hwg_PrintReport(,, .T.))
         SEPARATOR
         MENUITEM "&Exit" ID IDM_EXIT ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "&Items"
         MENUITEM "&Text" ID IDM_ITEMTEXT ACTION s_nAddItem:=TYPE_TEXT
         MENUITEM "&Horizontal Line" ID IDM_ITEMHLINE ACTION s_nAddItem:=TYPE_HLINE
         MENUITEM "&Vertical Line" ID IDM_ITEMVLINE ACTION s_nAddItem:=TYPE_VLINE
         MENUITEM "&Box" ID IDM_ITEMBOX ACTION s_nAddItem:=TYPE_BOX
         MENUITEM "B&itmap" ID IDM_ITEMBITM ACTION s_nAddItem:=TYPE_BITMAP
         SEPARATOR
         MENU TITLE "&Markers"
            MENUITEM "&Page Header" ID IDM_ITEMPH ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_PH)
            MENUITEM "&Start line" ID IDM_ITEMSL ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_SL)
            MENUITEM "&End line" ID IDM_ITEMEL ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_EL)
            MENUITEM "Page &Footer" ID IDM_ITEMPF ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_PF)
            MENUITEM "E&nd of Page Footer" ID IDM_ITEMEPF ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_EPF)
            MENUITEM "&Document Footer" ID IDM_ITEMDF ACTION (s_nAddItem:=TYPE_MARKER, s_nMarkerType:=MARKER_DF)
         ENDMENU
         SEPARATOR
         MENUITEM "&Delete item" ID IDM_ITEMDEL ACTION DeleteItem()
      ENDMENU
      MENU TITLE "&Options"
         MENUITEM "&Form options" ID IDM_FOPT ACTION FormOptions()
         MENUITEM "&Preview" ID IDM_VIEW1 ACTION (hwg_ShowScrollBar(oMainWindow:handle, SB_VERT, hwg_IsCheckedMenuItem(, IDM_VIEW1)), hwg_CheckMenuItem(, IDM_VIEW1, !hwg_IsCheckedMenuItem(, IDM_VIEW1)), IIf(hwg_IsCheckedMenuItem(, IDM_VIEW1), DeselectAll(),), hwg_RedrawWindow(Hwindow():GetMain():handle, RDW_ERASE+RDW_INVALIDATE))
         // MENUITEM "&Preview" ID IDM_VIEW1 ACTION (hwg_ShowScrollBar(oMainWindow:handle, SB_VERT, hwg_IsCheckedMenuItem(, IDM_VIEW1)), hwg_CheckMenuItem(, IDM_VIEW1, !hwg_IsCheckedMenuItem(, IDM_VIEW1)), IIf(hwg_IsCheckedMenuItem(, IDM_VIEW1), DeselectAll(), .F.), hwg_RedrawWindow(Hwindow():GetMain():handle, RDW_ERASE+RDW_INVALIDATE))
         MENUITEM "&Mouse limit" ID IDM_MOUSE2 ACTION (hwg_CheckMenuItem(, IDM_MOUSE2, !hwg_IsCheckedMenuItem(, IDM_MOUSE2)))
      ENDMENU
      MENUITEM "&About" ID IDM_ABOUT ACTION About()
   ENDMENU

   hwg_EnableMenuItem( , IDM_CLOSE, .F., .T. )
   hwg_EnableMenuItem( , IDM_SAVE, .F., .T. )
   hwg_EnableMenuItem( , IDM_SAVEAS, .F., .T. )
   hwg_EnableMenuItem( , IDM_PRINT, .F., .T. )
   hwg_EnableMenuItem( , IDM_PREVIEW, .F., .T. )
   hwg_EnableMenuItem( , IDM_FOPT, .F., .T. )
   hwg_EnableMenuItem( , 1, .F., .F. )
   hwg_CheckMenuItem( , IDM_MOUSE2, .T. )

   oMainWindow:Activate()

RETURN NIL

FUNCTION About
Local aModDlg, oFont

   INIT DIALOG aModDlg FROM RESOURCE "ABOUTDLG"
   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -13 ITALIC UNDERLINE

   REDEFINE SAY "HWREPORT" OF aModDlg ID 101 COLOR hwg_VColor("0000FF")
   REDEFINE OWNERBUTTON OF aModDlg ID IDC_OWNB1 ON CLICK {|| EndDialog( hwg_GetModalHandle() )} ;
       FLAT TEXT "Close" COLOR hwg_VColor("0000FF") FONT oFont

   aModDlg:Activate()
RETURN NIL

STATIC FUNCTION NewReport( oMainWindow )
Local oDlg

   INIT DIALOG oDlg FROM RESOURCE "DLG_NEWREP" ON INIT {||hwg_CheckRadioButton( oDlg:handle, IDC_RADIOBUTTON1, IDC_RADIOBUTTON2, IDC_RADIOBUTTON1)}
   DIALOG ACTIONS OF oDlg ;
        ON 0, IDOK  ACTION {|| EndNewrep(oMainWindow, oDlg)}

   oDlg:Activate()

RETURN NIL

STATIC FUNCTION EndNewrep( oMainWindow, oDlg )

   aPaintRep := { 0, 0, 0, 0, 0, {}, "", "", .F., 0, NIL }
   IF hwg_IsDlgButtonChecked(oDlg:handle, IDC_RADIOBUTTON1)
      aPaintRep[FORM_WIDTH] := 210 ; aPaintRep[FORM_HEIGHT] := 297
   ELSE
      aPaintRep[FORM_WIDTH] := 297 ; aPaintRep[FORM_HEIGHT] := 210
   ENDIF

   aPaintRep[FORM_Y] := 0
   hwg_EnableMenuItem( , 1, .T., .F. )
   hwg_WriteStatus( oMainWindow, 2, Ltrim(Str(aPaintRep[FORM_WIDTH], 4))+"x"+ ;
                 Ltrim(Str(aPaintRep[FORM_HEIGHT], 4))+"  Items: "+Ltrim(Str(Len(aPaintRep[FORM_ITEMS]))) )
   hwg_RedrawWindow( oMainWindow:handle, RDW_ERASE + RDW_INVALIDATE )

   EndDialog()
RETURN NIL

STATIC FUNCTION PaintMain( oWnd )
Local pps, hDC, hWnd := oWnd:handle
Local x1 := LEFT_INDENT, y1 := TOP_INDENT, x2, y2, oldBkColor, aMetr, nWidth, nHeight, lPreview := .F.
Local n1cm, xt, yt
Local i, j, aItem
Local aCoors
Local step, kolsteps, nsteps

   IF aPaintRep == NIL
      RETURN -1
   ENDIF

   pps := hwg_DefinePaintStru()
   hDC := hwg_BeginPaint( hWnd, pps )
   aCoors := hwg_GetClientRect( hWnd )

   IF aPaintRep[FORM_XKOEFCONST] == 0
      aMetr := hwg_GetDeviceArea(hDC)
      aPaintRep[FORM_XKOEFCONST] := ( aMetr[1]-XINDENT )/aPaintRep[FORM_WIDTH]
   ENDIF

   IF hwg_IsCheckedMenuItem( , IDM_VIEW1 )
      lPreview := .T.
      aPaintRep[FORM_Y] := 0
      IF aPaintRep[FORM_WIDTH] > aPaintRep[FORM_HEIGHT]
         nWidth := aCoors[3] - aCoors[1] - XINDENT
         nHeight := Round(nWidth * aPaintRep[FORM_HEIGHT] / aPaintRep[FORM_WIDTH], 0)
         IF nHeight > aCoors[4] - aCoors[2] - YINDENT
            nHeight := aCoors[4] - aCoors[2] - YINDENT
            nWidth := Round(nHeight * aPaintRep[FORM_WIDTH] / aPaintRep[FORM_HEIGHT], 0)
         ENDIF
      ELSE
         nHeight := aCoors[4] - aCoors[2] - YINDENT
         nWidth := Round(nHeight * aPaintRep[FORM_WIDTH] / aPaintRep[FORM_HEIGHT], 0)
         IF nWidth > aCoors[3] - aCoors[1] - XINDENT
            nWidth := aCoors[3] - aCoors[1] - XINDENT
            nHeight := Round(nWidth * aPaintRep[FORM_HEIGHT] / aPaintRep[FORM_WIDTH], 0)
         ENDIF
      ENDIF
      aPaintRep[FORM_XKOEF] := nWidth/aPaintRep[FORM_WIDTH]
   ELSE
      aPaintRep[FORM_XKOEF] := aPaintRep[FORM_XKOEFCONST]
   ENDIF

   x2 := x1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0)-1
   y2 := y1+Round(aPaintRep[FORM_HEIGHT]*aPaintRep[FORM_XKOEF], 0)-aPaintRep[FORM_Y]-1
   n1cm := Round(aPaintRep[FORM_XKOEF]*10, 0)
   step := n1cm*2
   nsteps := Round(aPaintRep[FORM_Y]/step, 0)

   hwg_FillRect( hDC, 0, 0, aCoors[3], TOP_INDENT-5, COLOR_HIGHLIGHTTEXT+1 )
   hwg_FillRect( hDC, 0, 0, LEFT_INDENT-12, aCoors[4], COLOR_3DLIGHT+1 )
   i := 0
   hwg_SelectObject( hDC, s_oPenLine:handle )
   hwg_SelectObject( hDC, IIf(lPreview, oFontSmall:handle, oFontStandard:handle) )
   oldBkColor := hwg_SetBkColor( hDC, hwg_GetSysColor(COLOR_3DLIGHT) )
   DO WHILE i <= aPaintRep[FORM_WIDTH]/10 .AND. i*n1cm < (aCoors[3]-aCoors[1]-LEFT_INDENT)
      xt := x1+i*n1cm
      hwg_DrawLine(hDC, xt + Round(n1cm / 4, 0), 0, xt + Round(n1cm / 4, 0), 4)
      hwg_DrawLine(hDC, xt + Round(n1cm / 2, 0), 0, xt + Round(n1cm / 2, 0), 8)
      hwg_DrawLine(hDC, xt + Round(n1cm * 3 / 4, 0), 0, xt + Round(n1cm * 3 / 4, 0), 4)
      hwg_DrawLine(hDC, xt, 0, xt, 12 )
      IF i > 0 .AND. i < aPaintRep[FORM_WIDTH]/10
         hwg_DrawText( hDC, Ltrim(Str(i, 2)), xt-15, 12, xt+15, TOP_INDENT-5, DT_CENTER )
      ENDIF
      i++
   ENDDO
   i := 0
   DO WHILE i <= aPaintRep[FORM_HEIGHT]/10 .AND. i*n1cm < (aCoors[4]-aCoors[2]-TOP_INDENT)
      yt := y1+i*n1cm
      hwg_DrawLine(hDC, 0, yt + Round(n1cm / 4, 0), 4, yt + Round(n1cm / 4, 0))
      hwg_DrawLine(hDC, 0, yt + Round(n1cm / 2, 0), 8, yt + Round(n1cm / 2, 0))
      hwg_DrawLine(hDC, 0, yt + Round(n1cm * 3/ 4, 0), 4, yt + Round(n1cm * 3 / 4, 0))
      hwg_DrawLine(hDC, 0, yt, 12, yt)
      IF i > 0 .AND. i < aPaintRep[FORM_HEIGHT]/10
         hwg_DrawText( hDC, Ltrim(Str(i+nsteps*2, 2)), 12, yt-10, LEFT_INDENT-12, yt+10, DT_CENTER )
      ENDIF
      i++
   ENDDO
   hwg_FillRect( hDC, LEFT_INDENT-12, y1, x1, y2, COLOR_3DSHADOW+1 )
   hwg_FillRect( hDC, x1, y1, x2, y2, COLOR_WINDOW+1 )
   hwg_SetBkColor( hDC, hwg_GetSysColor(COLOR_WINDOW) )
   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      IF aPaintRep[FORM_ITEMS, i, ITEM_TYPE] != TYPE_BITMAP
         PaintItem( hDC, aPaintRep[FORM_ITEMS, i], aCoors, lPreview )
      ENDIF
   NEXT
   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      IF aPaintRep[FORM_ITEMS, i, ITEM_TYPE] == TYPE_BITMAP
         PaintItem( hDC, aPaintRep[FORM_ITEMS, i], aCoors, lPreview )
      ENDIF
   NEXT
   hwg_SetBkColor( hDC, oldBkColor )

   kolsteps := Round((Round(aPaintRep[FORM_HEIGHT] * aPaintRep[FORM_XKOEF], 0) - ;
      (aCoors[4] - aCoors[2] - TOP_INDENT)) / step, 0) + 1
   IF lPreview
      hwg_SetScrollInfo( hWnd, SB_VERT, 1 )
   ELSE
      hwg_SetScrollInfo( hWnd, SB_VERT, 1, nSteps+1, 1, kolsteps+1 )
   ENDIF

   hwg_EndPaint( hWnd, pps )
RETURN 0

STATIC FUNCTION PaintItem( hDC, aItem, aCoors, lPreview )
Local x1 := LEFT_INDENT + aItem[ITEM_X1], y1 := TOP_INDENT + aItem[ITEM_Y1] - aPaintRep[FORM_Y]
Local x2 := x1+aItem[ITEM_WIDTH]-1, y2 := y1+aItem[ITEM_HEIGHT]-1

   IF lPreview
      x1 := LEFT_INDENT + aItem[ITEM_X1]*aPaintRep[FORM_XKOEF]/aPaintRep[FORM_XKOEFCONST]
      x2 := LEFT_INDENT + (aItem[ITEM_X1]+aItem[ITEM_WIDTH]-1)*aPaintRep[FORM_XKOEF]/aPaintRep[FORM_XKOEFCONST]
      y1 := TOP_INDENT + aItem[ITEM_Y1]*aPaintRep[FORM_XKOEF]/aPaintRep[FORM_XKOEFCONST]
      y2 := TOP_INDENT + (aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-1)*aPaintRep[FORM_XKOEF]/aPaintRep[FORM_XKOEFCONST]
   ENDIF
   IF y1 >= TOP_INDENT .AND. y1 <= aCoors[4]
      IF aItem[ITEM_STATE] == STATE_SELECTED .OR. aItem[ITEM_STATE] == STATE_PRESSED
         hwg_FillRect( hDC, x1-3, y1-3, x2+3, y2+3, COLOR_3DLIGHT+1 )
         hwg_SelectObject( hDC, oPenBorder:handle )
         hwg_Rectangle(hDC, x1 - 3, y1 - 3, x2 + 3, y2 + 3)
         hwg_Rectangle(hDC, x1 - 1, y1 - 1, x2 + 1, y2 + 1)
      ENDIF
      IF aItem[ITEM_TYPE] == TYPE_TEXT
         IF Empty(aItem[ITEM_CAPTION])
            hwg_FillRect( hDC, x1, y1, x2, y2, COLOR_3DSHADOW+1 )
         ELSE
      hwg_SelectObject( hDC, IIf(lPreview, oFontSmall:handle, aItem[ITEM_FONT]:handle) )
            hwg_DrawText( hDC, aItem[ITEM_CAPTION], x1, y1, x2, y2, ;
              IIf(aItem[ITEM_ALIGN] == 0, DT_LEFT, IIf(aItem[ITEM_ALIGN] == 1, DT_RIGHT, DT_CENTER)) )
         ENDIF
      ELSEIF aItem[ITEM_TYPE] == TYPE_HLINE
         hwg_SelectObject( hDC, aItem[ITEM_PEN]:handle )
         hwg_DrawLine(hDC, x1, y1, x2, y1)
      ELSEIF aItem[ITEM_TYPE] == TYPE_VLINE
         hwg_SelectObject( hDC, aItem[ITEM_PEN]:handle )
         hwg_DrawLine(hDC, x1, y1, x1, y2)
      ELSEIF aItem[ITEM_TYPE] == TYPE_BOX
         hwg_SelectObject( hDC, aItem[ITEM_PEN]:handle )
         hwg_Rectangle(hDC, x1, y1, x2, y2)
      ELSEIF aItem[ITEM_TYPE] == TYPE_BITMAP
         IF aItem[ITEM_BITMAP] == NIL
            hwg_FillRect( hDC, x1, y1, x2, y2, COLOR_3DSHADOW+1 )
         ELSE
            hwg_DrawBitmap( hDC, aItem[ITEM_BITMAP]:handle, SRCAND, x1, y1, x2-x1+1, y2-y1+1 )
         ENDIF
      ELSEIF aItem[ITEM_TYPE] == TYPE_MARKER
         hwg_SelectObject( hDC, s_oPenDivider:handle )
         hwg_DrawLine(hDC, LEFT_INDENT, y1, LEFT_INDENT - 1 + Round(aPaintRep[FORM_WIDTH] * aPaintRep[FORM_XKOEF], 0), y1)
         hwg_SelectObject( hDC, oFontSmall:handle )
         hwg_DrawText( hDC, aItem[ITEM_CAPTION], x1, y1, x2, y2, DT_CENTER )
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION MessagesProc(oWnd, msg, wParam, lParam)
Local i, aItem, hWnd := oWnd:handle

   IF msg == WM_VSCROLL
      Vscroll( hWnd, hwg_LOWORD(wParam), hwg_HIWORD(wParam) )
   ELSEIF msg == WM_MOUSEMOVE
      MouseMove(wParam, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
   ELSEIF msg == WM_LBUTTONDOWN
      LButtonDown( hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
   ELSEIF msg == WM_LBUTTONUP
      LButtonUp( hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
   ELSEIF msg == WM_LBUTTONDBLCLK
      LButtonDbl( hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
   ELSEIF msg == WM_KEYDOWN
      IF wParam == 46
         DeleteItem()
      ELSEIF wParam == 34    // PageDown
        VScroll( hWnd, SB_LINEDOWN )
      ELSEIF wParam == 33    // PageUp
        VScroll( hWnd, SB_LINEUP )
      ENDIF
   ELSEIF msg == WM_KEYUP
      IF wParam == 40        // Down
         FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
            IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED
               aItem := aPaintRep[FORM_ITEMS, i]
               IF aItem[ITEM_Y1]+aItem[ITEM_HEIGHT] < aPaintRep[FORM_HEIGHT]*aPaintRep[FORM_XKOEFCONST]
                  aItem[ITEM_Y1] ++
                  aPaintRep[FORM_CHANGED] := .T.
                  WriteItemInfo( aItem )
                  hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                           TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-4, ;
                           LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                           TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
                  IF aItem[ITEM_TYPE] == TYPE_MARKER
                     hwg_InvalidateRect( hWnd, 0, LEFT_INDENT, ;
                              TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y], ;
                              LEFT_INDENT-1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0), ;
                              TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] )
                  ENDIF
                  hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
               ENDIF
            ENDIF
         NEXT
      ELSEIF wParam == 38    // Up
         FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
            IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED
               aItem := aPaintRep[FORM_ITEMS, i]
               IF aItem[ITEM_Y1] > 1
                  aItem[ITEM_Y1] --
                  aPaintRep[FORM_CHANGED] := .T.
                  WriteItemInfo( aItem )
                  hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                           TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                           LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                           TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+4 )
                  IF aItem[ITEM_TYPE] == TYPE_MARKER
                     hwg_InvalidateRect( hWnd, 0, LEFT_INDENT, ;
                              TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y], ;
                              LEFT_INDENT-1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0), ;
                              TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] )
                  ENDIF
                  hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
               ENDIF
            ENDIF
         NEXT
      ELSEIF wParam == 39    // Right
         FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
            IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED
               aItem := aPaintRep[FORM_ITEMS, i]
               IF aItem[ITEM_TYPE] != TYPE_MARKER .AND. ;
                    aItem[ITEM_X1]+aItem[ITEM_WIDTH] < aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEFCONST]
                  aItem[ITEM_X1] ++
                  aPaintRep[FORM_CHANGED] := .T.
                  WriteItemInfo( aItem )
                  hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-4, ;
                           TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                           LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                           TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
                  hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
               ENDIF
            ENDIF
         NEXT
      ELSEIF wParam == 37    // Left
         FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
            IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED
               aItem := aPaintRep[FORM_ITEMS, i]
               IF aItem[ITEM_TYPE] != TYPE_MARKER .AND. aItem[ITEM_X1] > 1
                  aItem[ITEM_X1] --
                  aPaintRep[FORM_CHANGED] := .T.
                  WriteItemInfo( aItem )
                  hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                           TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                           LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+4, ;
                           TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
                  hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
               ENDIF
            ENDIF
         NEXT
      ENDIF
   ENDIF
RETURN -1

STATIC FUNCTION VSCROLL( hWnd, nScrollCode, nNewPos )
Local step  := Round(aPaintRep[FORM_XKOEF]*10, 0)*2, nsteps := aPaintRep[FORM_Y]/step, kolsteps
Local aCoors := hwg_GetClientRect( hWnd )

   IF nScrollCode == SB_LINEDOWN
      kolsteps := Round((Round(aPaintRep[FORM_HEIGHT] * aPaintRep[FORM_XKOEF], 0) - ;
         (aCoors[4] - aCoors[2] - TOP_INDENT)) / step, 0) + 1
      IF nsteps < kolsteps
         aPaintRep[FORM_Y] += step
         nsteps ++
         IF nsteps>=kolsteps
            hwg_RedrawWindow( hWnd, RDW_ERASE + RDW_INVALIDATE )
         ELSE
            hwg_InvalidateRect( hWnd, 0, 0, TOP_INDENT, aCoors[3], aCoors[4] )
            hwg_SendMessage(hWnd, WM_PAINT, 0, 0)
         ENDIF
      ENDIF
   ELSEIF nScrollCode == SB_LINEUP
      IF nsteps > 0
         aPaintRep[FORM_Y] -= step
         hwg_InvalidateRect( hWnd, 0, 0, TOP_INDENT, aCoors[3], aCoors[4] )
         hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
      ENDIF
   ELSEIF nScrollCode == SB_THUMBTRACK
      IF --nNewPos != nsteps
         kolsteps := Round((Round(aPaintRep[FORM_HEIGHT] * aPaintRep[FORM_XKOEF], 0) - ;
            (aCoors[4] - aCoors[2] - TOP_INDENT)) / step, 0) + 1
         aPaintRep[FORM_Y] := nNewPos * step
         IF aPaintRep[FORM_Y]/step>=kolsteps
            hwg_RedrawWindow( hWnd, RDW_ERASE + RDW_INVALIDATE )
         ELSE
            hwg_InvalidateRect( hWnd, 0, 0, TOP_INDENT, aCoors[3], aCoors[4] )
            hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
         ENDIF
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION MouseMove(wParam, xPos, yPos)
Local x1 := LEFT_INDENT, y1 := TOP_INDENT, x2, y2
Local hWnd
Local aItem, i, dx, dy

   IF aPaintRep == NIL .OR. hwg_IsCheckedMenuItem( , IDM_VIEW1 )
      RETURN .T.
   ENDIF
   s_itemBorder := 0
   x2 := x1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0)-1
   y2 := y1+Round(aPaintRep[FORM_HEIGHT]*aPaintRep[FORM_XKOEF], 0)-aPaintRep[FORM_Y]-1
   IF s_nAddItem > 0 
      IF xPos > x1 .AND. xPos < x2 .AND. yPos > y1 .AND. yPos < y2
         hwg_SetCursor( s_crossCursor )
      ENDIF
   ELSEIF s_itemPressed > 0
      IF hwg_IsCheckedMenuItem(, IDM_MOUSE2) .AND. Abs(xPos - s_mPos[1]) < 3 .AND. Abs(yPos - s_mPos[2]) < 3
         RETURN NIL
      ENDIF
      aItem := aPaintRep[FORM_ITEMS, s_itemPressed]
      IF hwg_CheckBit( wParam, MK_LBUTTON )
         hWnd := Hwindow():GetMain():handle
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                  TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                  LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                  TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         IF aItem[ITEM_TYPE] == TYPE_MARKER
            hwg_InvalidateRect( hWnd, 0, LEFT_INDENT, ;
                     TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y], ;
                     LEFT_INDENT-1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0), ;
                     TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] )
         ELSE
            aItem[ITEM_X1] += (xPos - s_mPos[1])
         ENDIF
         aItem[ITEM_Y1] += (yPos - s_mPos[2])
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                  TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                  LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                  TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         IF aItem[ITEM_TYPE] == TYPE_MARKER
            hwg_InvalidateRect( hWnd, 0, LEFT_INDENT, ;
                     TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y], ;
                     LEFT_INDENT-1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0), ;
                     TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] )
         ENDIF
         s_mPos[1] := xPos; s_mPos[2] := yPos
         aPaintRep[FORM_CHANGED] := .T.
         WriteItemInfo( aItem )
         hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
      ELSE
         aItem[ITEM_STATE] := STATE_SELECTED
         s_itemPressed := 0
      ENDIF
   ELSEIF s_itemSized > 0
      aItem := aPaintRep[FORM_ITEMS, s_itemSized]
      IF hwg_CheckBit( wParam, MK_LBUTTON )
         dx := xPos - s_mPos[1]
         dy := yPos - s_mPos[2]
         hWnd := Hwindow():GetMain():handle
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                  TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                  LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                  TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         IF s_resizeDirection == 1
            IF aItem[ITEM_WIDTH] - dx > 10
               aItem[ITEM_WIDTH] -= dx
               aItem[ITEM_X1] += dx
            ENDIF
         ELSEIF s_resizeDirection == 2
            IF aItem[ITEM_HEIGHT] - dy > 7
               aItem[ITEM_HEIGHT] -= dy
               aItem[ITEM_Y1] += dy
            ENDIF
         ELSEIF s_resizeDirection == 3
            IF aItem[ITEM_WIDTH] + dx > 10
               aItem[ITEM_WIDTH] += dx
            ENDIF
         ELSEIF s_resizeDirection == 4
            IF aItem[ITEM_HEIGHT] + dy > 7
               aItem[ITEM_HEIGHT] += dy
            ENDIF
         ENDIF
         s_mPos[1] := xPos; s_mPos[2] := yPos
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                  TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                  LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                  TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         aPaintRep[FORM_CHANGED] := .T.
         WriteItemInfo( aItem )
         hwg_SetCursor( IIf(s_resizeDirection == 1 .OR. s_resizeDirection == 3, s_horzCursor, s_vertCursor))
         hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
      ENDIF
   ELSE
      FOR i := Len(aPaintRep[FORM_ITEMS]) TO 1 STEP -1
         aItem := aPaintRep[FORM_ITEMS, i]
         IF aItem[ITEM_STATE] == STATE_SELECTED
            IF xPos >= LEFT_INDENT-2+aItem[ITEM_X1] .AND. ;
                xPos < LEFT_INDENT+1+aItem[ITEM_X1] .AND. ;
                yPos >= TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] .AND. yPos < TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT]
               IF aItem[ITEM_TYPE] != TYPE_VLINE .AND. aItem[ITEM_TYPE] != TYPE_MARKER
                  hwg_SetCursor( s_horzCursor )
                  s_itemBorder := i
                  s_resizeDirection := 1
               ENDIF
            ELSEIF xPos >= LEFT_INDENT-1+aItem[ITEM_X1]+aItem[ITEM_WIDTH] .AND. ;
                xPos < LEFT_INDENT+2+aItem[ITEM_X1]+aItem[ITEM_WIDTH] .AND. ;
                yPos >= TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] .AND. yPos < LEFT_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT]
               IF aItem[ITEM_TYPE] != TYPE_VLINE .AND. aItem[ITEM_TYPE] != TYPE_MARKER
                  hwg_SetCursor( s_horzCursor )
                  s_itemBorder := i
                  s_resizeDirection := 3
               ENDIF
            ELSEIF yPos >= TOP_INDENT-2+aItem[ITEM_Y1]-aPaintRep[FORM_Y] .AND. ;
                yPos < TOP_INDENT+1+aItem[ITEM_Y1]-aPaintRep[FORM_Y] .AND. ;
                xPos >= LEFT_INDENT+aItem[ITEM_X1] .AND. xPos < LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]
               IF aItem[ITEM_TYPE] != TYPE_HLINE .AND. aItem[ITEM_TYPE] != TYPE_MARKER
                  hwg_SetCursor( s_vertCursor )
                  s_itemBorder := i
                  s_resizeDirection := 2
               ENDIF
            ELSEIF yPos >= TOP_INDENT-1+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT] .AND. ;
                yPos < TOP_INDENT+2+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT] .AND. ;
                xPos >= LEFT_INDENT+aItem[ITEM_X1] .AND. xPos < LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]
               IF aItem[ITEM_TYPE] != TYPE_HLINE .AND. aItem[ITEM_TYPE] != TYPE_MARKER
                  hwg_SetCursor( s_vertCursor )
                  s_itemBorder := i
                  s_resizeDirection := 4
               ENDIF
            ENDIF
            IF s_itemBorder != 0
               EXIT
            ENDIF
         ENDIF
      NEXT
   ENDIF
RETURN NIL

STATIC FUNCTION LButtonDown( xPos, yPos )
Local i, aItem, res := .F.
Local hWnd := Hwindow():GetMain():handle
   IF aPaintRep == NIL .OR. hwg_IsCheckedMenuItem( , IDM_VIEW1 )
      RETURN .T.
   ENDIF
   IF s_nAddItem > 0
   ELSEIF s_itemBorder != 0
      s_itemSized := s_itemBorder
      s_mPos[1] := xPos; s_mPos[2] := yPos
      hwg_SetCursor( IIf(s_resizeDirection == 1 .OR. s_resizeDirection == 3, s_horzCursor, s_vertCursor))
   ELSE
      IF ( i := DeselectAll() ) != 0
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aPaintRep[FORM_ITEMS, i, ITEM_X1]-3, ;
            TOP_INDENT+aPaintRep[FORM_ITEMS, i, ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
            LEFT_INDENT+aPaintRep[FORM_ITEMS, i, ITEM_X1]+aPaintRep[FORM_ITEMS, i, ITEM_WIDTH]+3, ;
            TOP_INDENT+aPaintRep[FORM_ITEMS, i, ITEM_Y1]+aPaintRep[FORM_ITEMS, i, ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         res := .T.
      ENDIF
      hwg_WriteStatus( Hwindow():GetMain(), 1, "" )
      FOR i := Len(aPaintRep[FORM_ITEMS]) TO 1 STEP -1
         aItem := aPaintRep[FORM_ITEMS, i]
         IF xPos >= LEFT_INDENT+aItem[ITEM_X1] ;
              .AND. xPos < LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH] ;
              .AND. yPos > TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y] ;
              .AND. yPos < TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]+aItem[ITEM_HEIGHT]
            aPaintRep[FORM_ITEMS, i, ITEM_STATE] := STATE_PRESSED
            s_itemPressed := i
            s_mPos[1] := xPos; s_mPos[2] := yPos
            WriteItemInfo( aItem )
            hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                     TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                     LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                     TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
            res := .T.
            EXIT
         ENDIF
      NEXT
      IF res
         hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
      ENDIF
   ENDIF
RETURN NIL

STATIC FUNCTION LButtonUp( xPos, yPos )
Local x1 := LEFT_INDENT, y1 := TOP_INDENT, x2, y2, aItem
Local hWnd := Hwindow():GetMain():handle
   IF aPaintRep == NIL .OR. hwg_IsCheckedMenuItem( , IDM_VIEW1 )
      RETURN .T.
   ENDIF
   x2 := x1+Round(aPaintRep[FORM_WIDTH]*aPaintRep[FORM_XKOEF], 0)-1
   y2 := y1+Round(aPaintRep[FORM_HEIGHT]*aPaintRep[FORM_XKOEF], 0)-aPaintRep[FORM_Y]-1
   IF s_nAddItem > 0 .AND. xPos > x1 .AND. xPos < x2 .AND. yPos > y1 .AND. yPos < y2
      AAdd(aPaintRep[FORM_ITEMS], { s_nAddItem, "", xPos-x1, ;
           yPos-y1+aPaintRep[FORM_Y], s_aInitialSize[s_nAddItem, 1], ;
           s_aInitialSize[s_nAddItem, 2], 0, NIL, NIL, 0, 0, NIL, STATE_SELECTED })
      aItem := Atail( aPaintRep[FORM_ITEMS] )
      IF s_nAddItem == TYPE_HLINE .OR. s_nAddItem == TYPE_VLINE .OR. s_nAddItem == TYPE_BOX
         aItem[ITEM_PEN] := HPen():Add()
      ELSEIF s_nAddItem == TYPE_TEXT
         aItem[ITEM_FONT] := IIf(lastFont == NIL, HFont():Add("Arial", 0, -13), lastFont)
      ELSEIF s_nAddItem == TYPE_MARKER
         aItem[ITEM_X1] := -s_aInitialSize[s_nAddItem, 1]
         aItem[ITEM_CAPTION] := s_aMarkers[s_nMarkerType]
      ENDIF
      DeselectAll( Len(aPaintRep[FORM_ITEMS]) )
      aPaintRep[FORM_CHANGED] := .T.
      WriteItemInfo( Atail( aPaintRep[FORM_ITEMS] ) )
      hwg_WriteStatus( Hwindow():GetMain(), 2, Ltrim(Str(aPaintRep[FORM_WIDTH], 4))+"x"+ ;
         Ltrim(Str(aPaintRep[FORM_HEIGHT], 4))+"  Items: "+Ltrim(Str(Len(aPaintRep[FORM_ITEMS]))) )
      hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
               TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
               LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
               TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
      hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
      IF Len(aPaintRep[FORM_ITEMS]) == 1
         hwg_EnableMenuItem( , IDM_CLOSE, .T., .T. )
         hwg_EnableMenuItem( , IDM_SAVE, .T., .T. )
         hwg_EnableMenuItem( , IDM_SAVEAS, .T., .T. )
         hwg_EnableMenuItem( , IDM_PRINT, .T., .T. )
         hwg_EnableMenuItem( , IDM_PREVIEW, .T., .T. )
         hwg_EnableMenuItem( , IDM_FOPT, .T., .T. )
      ENDIF
   ELSEIF s_itemPressed > 0
      aPaintRep[FORM_ITEMS, s_itemPressed, ITEM_STATE] := STATE_SELECTED
   ENDIF
   IF s_itemPressed > 0 .OR. s_itemSized > 0 .OR. s_nAddItem > 0
      aPaintRep[FORM_ITEMS] := Asort( aPaintRep[FORM_ITEMS],,, {|z, y|z[ITEM_Y1]<y[ITEM_Y1].OR.(z[ITEM_Y1] == y[ITEM_Y1].AND.z[ITEM_X1]<y[ITEM_X1]).OR.(z[ITEM_Y1] == y[ITEM_Y1].AND.z[ITEM_X1] == y[ITEM_X1].AND.(z[ITEM_WIDTH]<y[ITEM_WIDTH].OR.z[ITEM_HEIGHT]<y[ITEM_HEIGHT]))} )
   ENDIF
   s_itemPressed := s_itemSized := s_itemBorder := s_nAddItem := 0
RETURN NIL

STATIC FUNCTION DeleteItem()
Local hWnd := Hwindow():GetMain():handle
Local i, aItem
   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED
         aItem := aPaintRep[FORM_ITEMS, i]
         IF aItem[ITEM_PEN] != NIL
            aItem[ITEM_PEN]:Release()
         ENDIF
         hwg_InvalidateRect( hWnd, 0, LEFT_INDENT+aItem[ITEM_X1]-3, ;
                  TOP_INDENT+aItem[ITEM_Y1]-aPaintRep[FORM_Y]-3, ;
                  LEFT_INDENT+aItem[ITEM_X1]+aItem[ITEM_WIDTH]+3, ;
                  TOP_INDENT+aItem[ITEM_Y1]+aItem[ITEM_HEIGHT]-aPaintRep[FORM_Y]+3 )
         Adel( aPaintRep[FORM_ITEMS], i )
         ASize(aPaintRep[FORM_ITEMS], Len(aPaintRep[FORM_ITEMS]) - 1)
         aPaintRep[FORM_CHANGED] := .T.
         hwg_WriteStatus( Hwindow():GetMain(), 1, "" )
         hwg_WriteStatus( Hwindow():GetMain(), 2, Ltrim(Str(aPaintRep[FORM_WIDTH], 4))+"x"+ ;
                 Ltrim(Str(aPaintRep[FORM_HEIGHT], 4))+"  Items: "+Ltrim(Str(Len(aPaintRep[FORM_ITEMS]))) )
         IF Len(aPaintRep[FORM_ITEMS]) == 0
            hwg_EnableMenuItem( , IDM_CLOSE, .F., .T. )
            hwg_EnableMenuItem( , IDM_SAVE, .F., .T. )
            hwg_EnableMenuItem( , IDM_SAVEAS, .F., .T. )
            hwg_EnableMenuItem( , IDM_PRINT, .F., .T. )
            hwg_EnableMenuItem( , IDM_PREVIEW, .F., .T. )
            hwg_EnableMenuItem( , IDM_FOPT, .F., .T. )
         ENDIF
         hwg_PostMessage(hWnd, WM_PAINT, 0, 0)
         EXIT
      ENDIF
   NEXT
RETURN NIL

STATIC FUNCTION DeselectAll( iSelected )
Local i, iPrevSelected := 0
   iSelected := IIf(iSelected == NIL, 0, iSelected)
   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      IF aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_SELECTED .OR. ;
           aPaintRep[FORM_ITEMS, i, ITEM_STATE] == STATE_PRESSED
         iPrevSelected := i
      ENDIF
      IF iSelected != i
         aPaintRep[FORM_ITEMS, i, ITEM_STATE] := STATE_NORMAL
      ENDIF
   NEXT
RETURN iPrevSelected

STATIC FUNCTION WriteItemInfo( aItem )
   hwg_WriteStatus( Hwindow():GetMain(), 1, " x1: "+Ltrim(Str(aItem[ITEM_X1]))+", y1: " ;
          +Ltrim(Str(aItem[ITEM_Y1]))+", cx: "+Ltrim(Str(aItem[ITEM_WIDTH])) ;
          +", cy: "+Ltrim(Str(aItem[ITEM_HEIGHT])) )
RETURN NIL
