//
// HWGUI - Harbour Win32 GUI library source code:
// HButtonEx class
//
// Copyright 2007 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

#translate :hBitmap       => :m_csbitmaps\[1\]
//#translate :dwWidth       => :m_csbitmaps\[2\] // not used
//#translate :dwHeight      => :m_csbitmaps\[3\] // not used
//#translate :hMask         => :m_csbitmaps\[4\] // not used
//#translate :crTransparent => :m_csbitmaps\[5\] // not used

//#define TRANSPARENT 1 // defined in windows.ch
#define BTNST_COLOR_BK_IN     1            // Background color when mouse is INside
#define BTNST_COLOR_FG_IN     2            // Text color when mouse is INside
#define BTNST_COLOR_BK_OUT    3             // Background color when mouse is OUTside
#define BTNST_COLOR_FG_OUT    4             // Text color when mouse is OUTside
#define BTNST_COLOR_BK_FOCUS  5           // Background color when the button is focused
#define BTNST_COLOR_FG_FOCUS  6            // Text color when the button is focused
#define BTNST_MAX_COLORS      6
//#define WM_SYSCOLORCHANGE               0x0015 // defined in windows.ch
#define BS_TYPEMASK SS_TYPEMASK
#define OFS_X   10 // distance from left/right side to beginning/end of text

// TODO: alterar para funcionar com ponteiros

//-------------------------------------------------------------------------------------------------------------------//

CLASS HButtonEX INHERIT HButton

   DATA hBitmap
   DATA hIcon
   DATA m_dcBk
   DATA m_bFirstTime INIT .T.
   DATA Themed INIT .F.
   //DATA lnoThemes  INIT .F. HIDDEN
   DATA m_crColors INIT Array(6)
   DATA m_crBrush INIT Array(6)
   DATA hTheme
   // DATA Caption
   DATA state
   DATA m_bIsDefault INIT .F.
   DATA m_nTypeStyle INIT 0
   DATA m_bSent
   DATA m_bLButtonDown
   DATA m_bIsToggle
   DATA m_rectButton           // button rect in parent window coordinates
   DATA m_dcParent INIT hdc():new()
   DATA m_bmpParent
   DATA m_pOldParentBitmap
   DATA m_csbitmaps INIT {,,,,}
   DATA m_bToggled INIT .F.
   DATA PictureMargin INIT 0
   DATA m_bDrawTransparent INIT .F.
   DATA iStyle
   DATA m_bmpBk
   DATA m_pbmpOldBk
   DATA bMouseOverButton INIT .F.

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, hBitmap, iStyle, hicon, Transp, bGFocus, nPictureMargin, lnoThemes, bOther)
   METHOD Paint(lpDis)
   METHOD SetBitmap(hBitMap)
   METHOD SetIcon(hIcon)
   METHOD Init()
   METHOD onevent(msg, wParam, lParam)
   METHOD CancelHover()
   METHOD End()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption, hBitmap, ;
      iStyle, hIcon, bGFocus, nPictureMargin)
   METHOD PaintBk(hdc)
   METHOD SetColor(tcolor, bcolor) INLINE ::SetDefaultColor(tcolor, bcolor) //, ::SetDefaultColor(.T.)
   METHOD SetDefaultColor(tColor, bColor, lPaint)
   //METHOD SetDefaultColor(lRepaint)
   METHOD SetColorEx(nIndex, nColor, lPaint)
   //METHOD SetText(c) INLINE ::title := c, ::caption := c, ;
   METHOD SetText(c) INLINE ;
      ::title := c, ;
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE), ;
      IIf(::oParent != NIL .AND. hwg_IsWindowVisible(::handle), ;
          hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight),), ;
      hwg_SetWindowText(::handle, ::title)
   //METHOD SaveParentBackground()

END CLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ;
   cTooltip, tcolor, bColor, hBitmap, iStyle, hicon, Transp, bGFocus, nPictureMargin, lnoThemes, bOther)

   DEFAULT iStyle TO ST_ALIGN_HORIZ
   DEFAULT Transp TO .T.
   #ifdef __SYGECOM__
   DEFAULT nPictureMargin TO 1
   #else
   DEFAULT nPictureMargin TO 0
   #endif
   DEFAULT lnoThemes  TO .F.

   ::m_bLButtonDown := .F.
   ::m_bSent := .F.
   ::m_bLButtonDown := .F.
   ::m_bIsToggle := .F.

   cCaption := IIf(cCaption == NIL, "", cCaption)
   ::Caption := cCaption
   ::iStyle := iStyle
   ::hBitmap := IIf(Empty(hBitmap), NIL, hBitmap)
   ::hicon := IIf(Empty(hicon), NIL, hIcon)
   ::m_bDrawTransparent := Transp
   ::PictureMargin := nPictureMargin
   ::lnoThemes := lnoThemes
   ::bOther := bOther
   bPaint := {|o, p|o:paint(p)}

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, bSize, bPaint, bClick, ;
      cTooltip, tcolor, bColor, bGFocus)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption, hBitmap, ;
   iStyle, hIcon, bGFocus, nPictureMargin)

   DEFAULT iStyle TO ST_ALIGN_HORIZ
   DEFAULT nPictureMargin TO 0
   bPaint := {|o, p|o:paint(p)}
   ::m_bLButtonDown := .F.
   ::m_bIsToggle := .F.

   ::m_bLButtonDown := .F.
   ::m_bSent := .F.

   ::title := cCaption

   ::Caption := cCaption
   ::iStyle := iStyle
   ::hBitmap := hBitmap
   ::hIcon := hIcon
   ::m_crColors[BTNST_COLOR_BK_IN] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_IN] := hwg_GetSysColor(COLOR_BTNTEXT)
   ::m_crColors[BTNST_COLOR_BK_OUT] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_OUT] := hwg_GetSysColor(COLOR_BTNTEXT)
   ::m_crColors[BTNST_COLOR_BK_FOCUS] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_FOCUS] := hwg_GetSysColor(COLOR_BTNTEXT)
   ::PictureMargin := nPictureMargin

   ::Super:Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, cTooltip, tcolor, bColor, cCaption, ;
      hBitmap, iStyle, hIcon, bGFocus)
   ::title := cCaption

   ::Caption := cCaption

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:SetBitmap(hBitMap)

   DEFAULT hBitmap TO ::hBitmap

   IF hb_IsNumeric(hBitmap) // TODO: verificar
      ::hBitmap := hBitmap
      hwg_SendMessage(::handle, BM_SETIMAGE, IMAGE_BITMAP, ::hBitmap)
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT)
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:SetIcon(hIcon)

   DEFAULT hIcon TO ::hIcon

   IF hb_IsNumeric(::hIcon) // TODO: verificar
      ::hIcon := hIcon
      hwg_SendMessage(::handle, BM_SETIMAGE, IMAGE_ICON, ::hIcon)
      hwg_RedrawWindow(::handle, RDW_NOERASE + RDW_INVALIDATE + RDW_INTERNALPAINT)
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:End()

   ::Super:End()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:Init()

   LOCAL nbs

   IF !::lInit
      ::nHolder := 1
      //hwg_SetWindowObject(::handle, Self)
      //HWG_INITBUTTONPROC(::handle)
      // call in HBUTTON CLASS

      //::SetDefaultColor(, , .F.)
      IF hb_IsNumeric(::handle) .AND. ::handle > 0 // TODO: verificar
         nbs := hwg_GetWindowStyle(::handle)

         ::m_nTypeStyle := hwg_GetTheStyle(nbs, BS_TYPEMASK)

         // Check if this is a checkbox

         // Set initial default state flag
         IF ::m_nTypeStyle == BS_DEFPUSHBUTTON

            // Set default state for a default button
            ::m_bIsDefault := .T.

            // Adjust style for default button
            ::m_nTypeStyle := BS_PUSHBUTTON
         ENDIF
         nbs := hwg_ModStyle(nbs, BS_TYPEMASK, BS_OWNERDRAW)
         hwg_SetWindowStyle(::handle, nbs)

      ENDIF

      ::Super:Init()
      ::SetBitmap()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

// Caso tenha problemas com o novo código usando SWITCH,
// altere '#if 0' para '#if 1' para usar o código original.
// Se possível, informe o problema encontrado em 'Issues' no
// GitHub.

#if 0 // old code for reference (to be deleted)
METHOD HButtonEx:onEvent(msg, wParam, lParam)

   LOCAL pt := {,}
   LOCAL rectButton
   LOCAL acoor
   LOCAL pos
   LOCAL nID
   LOCAL oParent
   LOCAL nEval

   IF msg == WM_THEMECHANGED
      IF ::Themed
         IF hb_IsPointer(::hTheme)
            hwg_CloseThemeData(::htheme)
            ::hTheme := NIL
            //::m_bFirstTime := .T.
         ENDIF
         ::Themed := .F.
      ENDIF
      ::m_bFirstTime := .T.
      hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)
      RETURN 0
   ELSEIF msg == WM_ERASEBKGND
      RETURN 0
   ELSEIF msg == BM_SETSTYLE
      RETURN hwg_ButtonExOnSetStyle(wParam, lParam, ::handle, @::m_bIsDefault)

   ELSEIF msg == WM_MOUSEMOVE
      IF wParam == MK_LBUTTON
         pt[1] := hwg_LOWORD(lParam)
         pt[2] := hwg_HIWORD(lParam)
         acoor := hwg_ClientToScreen(::handle, pt[1], pt[2])
         rectButton := hwg_GetWindowRect(::handle)
         IF !hwg_PtInRect(rectButton, acoor)
            hwg_SendMessage(::handle, BM_SETSTATE, ::m_bToggled, 0)
            ::bMouseOverButton := .F.
            RETURN 0
         ENDIF
      ENDIF
      IF(!::bMouseOverButton)
         ::bMouseOverButton := .T.
         hwg_InvalidateRect(::handle, .F.)
         hwg_TrackMousEvent(::handle)
      ENDIF
      RETURN 0
   ELSEIF msg == WM_MOUSELEAVE
      ::CancelHover()
      RETURN 0
   ENDIF

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != -1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF

   IF msg == WM_KEYDOWN

#ifdef __XHARBOUR__
      IF hb_BitIsSet(hwg_PtrToUlong(lParam), 30)  // the key was down before ?
#else
      IF hb_BitTest(lParam, 30)   // the key was down before ?
#endif
         RETURN 0
      ENDIF
      IF wParam == VK_SPACE .OR. wParam == VK_RETURN
         /*
         IF ::GetParentForm(Self):Type < WND_DLG_RESOURCE
            hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         ELSE
            hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         ENDIF
         */
         hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         RETURN 0
      ENDIF
      IF wParam == VK_LEFT .OR. wParam == VK_UP
         hwg_GetSkip(::oParent, ::handle, , -1)
         RETURN 0
      ELSEIF wParam == VK_RIGHT .OR. wParam == VK_DOWN
         hwg_GetSkip(::oParent, ::handle, , 1)
         RETURN 0
      ELSEIF wParam == VK_TAB
         hwg_GetSkip(::oparent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
      ENDIF
      hwg_ProcKeyList(Self, wParam)

   ELSEIF msg == WM_SYSKEYUP .OR. (msg == WM_KEYUP .AND. ;
                     AScan({VK_SPACE, VK_RETURN, VK_ESCAPE}, wParam) == 0)
     IF hwg_CheckBit(lParam, 23) .AND. (wParam > 95 .AND. wParam < 106)
        wParam -= 48
     ENDIF
     IF !Empty(::title) .AND. (pos := At("&", ::title)) > 0 .AND. wParam == Asc(Upper(SubStr(::title, ++pos, 1)))
        IF hb_IsBlock(::bClick) .OR. ::id < 3
           hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::id, BN_CLICKED), ::handle)
        ENDIF
     ELSEIF (nID := AScan(::oparent:acontrols, {|o|IIf(hb_IsChar(o:title), (pos := At("&", o:title)) > 0 .AND. ;
              wParam == Asc(Upper(SubStr(o:title, ++pos, 1))),)})) > 0
        IF __ObjHasMsg(::oParent:aControls[nID], "BCLICK") .AND. ;
           hb_IsBlock(::oParent:aControls[nID]:bClick) .OR. ::oParent:aControls[nID]:id < 3
           hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::oParent:aControls[nID]:id, BN_CLICKED), ::oParent:aControls[nID]:handle)
        ENDIF
     ENDIF
     IF msg != WM_SYSKEYUP
         RETURN 0
     ENDIF

   ELSEIF msg == WM_KEYUP
      IF wParam == VK_SPACE .OR. wParam == VK_RETURN
         ::bMouseOverButton := .T.
         hwg_SendMessage(::handle, WM_LBUTTONUP, 0, hwg_MAKELPARAM(1, 1))
         ::bMouseOverButton := .F.
         RETURN 0
      ENDIF

   ELSEIF msg == WM_LBUTTONUP
      ::m_bLButtonDown := .F.
      IF ::m_bSent
         hwg_SendMessage(::handle, BM_SETSTATE, 0, 0)
         ::m_bSent := .F.
      ENDIF
      IF ::m_bIsToggle
         pt[1] := hwg_LOWORD(lParam)
         pt[2] := hwg_HIWORD(lParam)
         acoor := hwg_ClientToScreen(::handle, pt[1], pt[2])

         rectButton := hwg_GetWindowRect(::handle)

         IF !hwg_PtInRect(rectButton, acoor)
            ::m_bToggled := !::m_bToggled
            hwg_InvalidateRect(::handle, 0)
            hwg_SendMessage(::handle, BM_SETSTATE, 0, 0)
            ::m_bLButtonDown := .T.
         ENDIF
      ENDIF
      IF !::bMouseOverButton
         hwg_SetFocus(0)
         ::SETFOCUS()
         RETURN 0
      ENDIF
      RETURN -1

   ELSEIF msg == WM_LBUTTONDOWN
      ::m_bLButtonDown := .T.
      IF ::m_bIsToggle
         ::m_bToggled := !::m_bToggled
         hwg_InvalidateRect(::handle, 0)
      ENDIF
      RETURN -1

   ELSEIF msg == WM_LBUTTONDBLCLK

      IF ::m_bIsToggle

         // for toggle buttons, treat doubleclick as singleclick
         hwg_SendMessage(::handle, BM_SETSTATE, ::m_bToggled, 0)

      ELSE

         hwg_SendMessage(::handle, BM_SETSTATE, 1, 0)
         ::m_bSent := .T.

      ENDIF
      RETURN 0

   ELSEIF msg == WM_GETDLGCODE
         IF wParam == VK_ESCAPE .AND. (hwg_GetDlgMessage(lParam) == WM_KEYDOWN .OR. hwg_GetDlgMessage(lParam) == WM_KEYUP)
           oParent := ::GetParentForm()
           IF !hwg_ProcKeyList(Self, wParam) .AND. (oParent:Type < WND_DLG_RESOURCE .OR. !oParent:lModal)
              hwg_SendMessage(oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, 0), ::handle)
           ELSEIF oParent:FindControl(IDCANCEL) != NIL .AND. !oParent:FindControl(IDCANCEL):IsEnabled() .AND. oParent:lExitOnEsc
              hwg_SendMessage(oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, 0), ::handle)
              RETURN 0
           ENDIF
        ENDIF
      RETURN IIf(wParam == VK_ESCAPE, -1, hwg_ButtonGetDlgCode(lParam))

   ELSEIF msg == WM_SYSCOLORCHANGE
      ::SetDefaultColors()
   ELSEIF msg == WM_CHAR
      IF wParam == VK_RETURN .OR. wParam == VK_SPACE
         IF ::m_bIsToggle
            ::m_bToggled := !::m_bToggled
            hwg_InvalidateRect(::handle, 0)
         ELSE
            hwg_SendMessage(::handle, BM_SETSTATE, 1, 0)
            //::m_bSent := .T.
         ENDIF
         // remove because repet click  2 times
         //hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::id, BN_CLICKED), ::handle)
      ELSEIF wParam == VK_ESCAPE
         hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, BN_CLICKED), ::handle)
      ENDIF
      RETURN 0
   ENDIF

RETURN -1
#else
METHOD HButtonEx:onEvent(msg, wParam, lParam)

   LOCAL pt := {,}
   LOCAL rectButton
   LOCAL acoor
   LOCAL pos
   LOCAL nID
   LOCAL oParent
   LOCAL nEval

   SWITCH msg

   CASE WM_THEMECHANGED
      IF ::Themed
         IF hb_IsPointer(::hTheme)
            hwg_CloseThemeData(::htheme)
            ::hTheme := NIL
            //::m_bFirstTime := .T.
         ENDIF
         ::Themed := .F.
      ENDIF
      ::m_bFirstTime := .T.
      hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)
      RETURN 0

   CASE WM_ERASEBKGND
      RETURN 0

   CASE BM_SETSTYLE
      RETURN hwg_ButtonExOnSetStyle(wParam, lParam, ::handle, @::m_bIsDefault)

   CASE WM_MOUSEMOVE
      IF wParam == MK_LBUTTON
         pt[1] := hwg_LOWORD(lParam)
         pt[2] := hwg_HIWORD(lParam)
         acoor := hwg_ClientToScreen(::handle, pt[1], pt[2])
         rectButton := hwg_GetWindowRect(::handle)
         IF !hwg_PtInRect(rectButton, acoor)
            hwg_SendMessage(::handle, BM_SETSTATE, ::m_bToggled, 0)
            ::bMouseOverButton := .F.
            RETURN 0
         ENDIF
      ENDIF
      IF !::bMouseOverButton
         ::bMouseOverButton := .T.
         hwg_InvalidateRect(::handle, .F.)
         hwg_TrackMousEvent(::handle)
      ENDIF
      RETURN 0

   CASE WM_MOUSELEAVE
      ::CancelHover()
      RETURN 0

   CASE WM_KEYDOWN
      #ifdef __XHARBOUR__
      IF hb_BitIsSet(hwg_PtrToUlong(lParam), 30)  // the key was down before ?
      #else
      IF hb_BitTest(lParam, 30)   // the key was down before ?
      #endif
         RETURN 0
      ENDIF
      SWITCH wParam
      CASE VK_SPACE
      CASE VK_RETURN
         /*
         IF ::GetParentForm(Self):Type < WND_DLG_RESOURCE
            hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         ELSE
            hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         ENDIF
         */
         hwg_SendMessage(::handle, WM_LBUTTONDOWN, 0, hwg_MAKELPARAM(1, 1))
         RETURN 0
      CASE VK_LEFT
      CASE VK_UP
         hwg_GetSkip(::oParent, ::handle, , -1)
         RETURN 0
      CASE VK_RIGHT
      CASE VK_DOWN
         hwg_GetSkip(::oParent, ::handle, , 1)
         RETURN 0
      CASE VK_TAB
         hwg_GetSkip(::oparent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
      ENDSWITCH
      hwg_ProcKeyList(Self, wParam)
      EXIT

   CASE WM_SYSKEYUP
      IF hwg_CheckBit(lParam, 23) .AND. (wParam > 95 .AND. wParam < 106)
         wParam -= 48
      ENDIF
      IF !Empty(::title) .AND. (pos := At("&", ::title)) > 0 .AND. wParam == Asc(Upper(SubStr(::title, ++pos, 1)))
         IF hb_IsBlock(::bClick) .OR. ::id < 3
            hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::id, BN_CLICKED), ::handle)
         ENDIF
      ELSEIF (nID := AScan(::oparent:acontrols, {|o|IIf(hb_IsChar(o:title), (pos := At("&", o:title)) > 0 .AND. ;
              wParam == Asc(Upper(SubStr(o:title, ++pos, 1))),)})) > 0
         IF __ObjHasMsg(::oParent:aControls[nID], "BCLICK") .AND. ;
            hb_IsBlock(::oParent:aControls[nID]:bClick) .OR. ::oParent:aControls[nID]:id < 3
            hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::oParent:aControls[nID]:id, BN_CLICKED), ::oParent:aControls[nID]:handle)
         ENDIF
     ENDIF
     EXIT

   CASE WM_KEYUP
      IF AScan({VK_SPACE, VK_RETURN, VK_ESCAPE}, wParam) == 0
         IF hwg_CheckBit(lParam, 23) .AND. (wParam > 95 .AND. wParam < 106)
            wParam -= 48
         ENDIF
         IF !Empty(::title) .AND. (pos := At("&", ::title)) > 0 .AND. wParam == Asc(Upper(SubStr(::title, ++pos, 1)))
            IF hb_IsBlock(::bClick) .OR. ::id < 3
               hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::id, BN_CLICKED), ::handle)
            ENDIF
         ELSEIF (nID := AScan(::oparent:acontrols, {|o|IIf(hb_IsChar(o:title), (pos := At("&", o:title)) > 0 .AND. ;
                 wParam == Asc(Upper(SubStr(o:title, ++pos, 1))),)})) > 0
            IF __ObjHasMsg(::oParent:aControls[nID], "BCLICK") .AND. ;
               hb_IsBlock(::oParent:aControls[nID]:bClick) .OR. ::oParent:aControls[nID]:id < 3
               hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::oParent:aControls[nID]:id, BN_CLICKED), ::oParent:aControls[nID]:handle)
            ENDIF
         ENDIF
         RETURN 0
      ENDIF
      IF wParam == VK_SPACE .OR. wParam == VK_RETURN
         ::bMouseOverButton := .T.
         hwg_SendMessage(::handle, WM_LBUTTONUP, 0, hwg_MAKELPARAM(1, 1))
         ::bMouseOverButton := .F.
         RETURN 0
      ENDIF
      EXIT

   CASE WM_LBUTTONUP
      ::m_bLButtonDown := .F.
      IF ::m_bSent
         hwg_SendMessage(::handle, BM_SETSTATE, 0, 0)
         ::m_bSent := .F.
      ENDIF
      IF ::m_bIsToggle
         pt[1] := hwg_LOWORD(lParam)
         pt[2] := hwg_HIWORD(lParam)
         acoor := hwg_ClientToScreen(::handle, pt[1], pt[2])
         rectButton := hwg_GetWindowRect(::handle)
         IF !hwg_PtInRect(rectButton, acoor)
            ::m_bToggled := !::m_bToggled
            hwg_InvalidateRect(::handle, 0)
            hwg_SendMessage(::handle, BM_SETSTATE, 0, 0)
            ::m_bLButtonDown := .T.
         ENDIF
      ENDIF
      IF !::bMouseOverButton
         hwg_SetFocus(0)
         ::SETFOCUS()
         RETURN 0
      ENDIF
      RETURN -1

   CASE WM_LBUTTONDOWN
      ::m_bLButtonDown := .T.
      IF ::m_bIsToggle
         ::m_bToggled := !::m_bToggled
         hwg_InvalidateRect(::handle, 0)
      ENDIF
      RETURN -1

   CASE WM_LBUTTONDBLCLK
      IF ::m_bIsToggle
         // for toggle buttons, treat doubleclick as singleclick
         hwg_SendMessage(::handle, BM_SETSTATE, ::m_bToggled, 0)
      ELSE
         hwg_SendMessage(::handle, BM_SETSTATE, 1, 0)
         ::m_bSent := .T.
      ENDIF
      RETURN 0

   CASE WM_GETDLGCODE
      IF wParam == VK_ESCAPE .AND. (hwg_GetDlgMessage(lParam) == WM_KEYDOWN .OR. hwg_GetDlgMessage(lParam) == WM_KEYUP)
         oParent := ::GetParentForm()
         IF !hwg_ProcKeyList(Self, wParam) .AND. (oParent:Type < WND_DLG_RESOURCE .OR. !oParent:lModal)
            hwg_SendMessage(oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, 0), ::handle)
         ELSEIF oParent:FindControl(IDCANCEL) != NIL .AND. !oParent:FindControl(IDCANCEL):IsEnabled() .AND. oParent:lExitOnEsc
            hwg_SendMessage(oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, 0), ::handle)
            RETURN 0
         ENDIF
      ENDIF
      RETURN IIf(wParam == VK_ESCAPE, -1, hwg_ButtonGetDlgCode(lParam))

   CASE WM_SYSCOLORCHANGE
      ::SetDefaultColors()
      EXIT

   CASE WM_CHAR
      SWITCH wParam
      CASE VK_RETURN
      CASE VK_SPACE
         IF ::m_bIsToggle
            ::m_bToggled := !::m_bToggled
            hwg_InvalidateRect(::handle, 0)
         ELSE
            hwg_SendMessage(::handle, BM_SETSTATE, 1, 0)
            //::m_bSent := .T.
         ENDIF
         // remove because repet click  2 times
         //hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(::id, BN_CLICKED), ::handle)
         EXIT
      CASE VK_ESCAPE
         hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(IDCANCEL, BN_CLICKED), ::handle)
      ENDSWITCH
      RETURN 0

   ENDSWITCH

   IF hb_IsBlock(::bOther)
      IF (nEval := Eval(::bOther, Self, msg, wParam, lParam)) != -1 .AND. nEval != NIL
         RETURN 0
      ENDIF
   ENDIF

RETURN -1
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:CancelHover()

   IF ::bMouseOverButton .AND. ::id != IDOK //NANDO
      ::bMouseOverButton := .F.
      IF !::lflat
         hwg_InvalidateRect(::handle, .F.)
      ELSE
         hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:SetDefaultColor(tColor, bColor, lPaint)

   DEFAULT lPaint TO .F.

   IF !Empty(tColor)
      ::tColor := tColor
   ENDIF
   IF !Empty(bColor)
      ::bColor := bColor
   ENDIF
   ::m_crColors[BTNST_COLOR_BK_IN] := IIf(::bColor == NIL, hwg_GetSysColor(COLOR_BTNFACE), ::bColor)
   ::m_crColors[BTNST_COLOR_FG_IN] := IIf(::tColor == NIL, hwg_GetSysColor(COLOR_BTNTEXT), ::tColor)
   ::m_crColors[BTNST_COLOR_BK_OUT] := IIf(::bColor == NIL, hwg_GetSysColor(COLOR_BTNFACE), ::bColor)
   ::m_crColors[BTNST_COLOR_FG_OUT] := IIf(::tColor == NIL, hwg_GetSysColor(COLOR_BTNTEXT), ::tColor)
   ::m_crColors[BTNST_COLOR_BK_FOCUS] := IIf(::bColor == NIL, hwg_GetSysColor(COLOR_BTNFACE), ::bColor)
   ::m_crColors[BTNST_COLOR_FG_FOCUS] := IIf(::tColor == NIL, hwg_GetSysColor(COLOR_BTNTEXT), ::tColor)
   //
   ::m_crBrush[BTNST_COLOR_BK_IN] := HBrush():Add(::m_crColors[BTNST_COLOR_BK_IN])
   ::m_crBrush[BTNST_COLOR_BK_OUT] := HBrush():Add(::m_crColors[BTNST_COLOR_BK_OUT])
   ::m_crBrush[BTNST_COLOR_BK_FOCUS] := HBrush():Add(::m_crColors[BTNST_COLOR_BK_FOCUS])
   /*
   ::m_crColors[BTNST_COLOR_BK_IN] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_IN] := hwg_GetSysColor(COLOR_BTNTEXT)
   ::m_crColors[BTNST_COLOR_BK_OUT] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_OUT] := hwg_GetSysColor(COLOR_BTNTEXT)
   ::m_crColors[BTNST_COLOR_BK_FOCUS] := hwg_GetSysColor(COLOR_BTNFACE)
   ::m_crColors[BTNST_COLOR_FG_FOCUS] := hwg_GetSysColor(COLOR_BTNTEXT)
   */
   IF lPaint
      hwg_InvalidateRect(::handle, .F.)
   ENDIF

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:SetColorEx(nIndex, nColor, lPaint)

   DEFAULT lPaint TO .F.

   IF nIndex > BTNST_MAX_COLORS
      RETURN -1
   ENDIF

   ::m_crColors[nIndex] := nColor

   IF lPaint
      hwg_InvalidateRect(::handle, .F.)
   ENDIF

RETURN 0

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:Paint(lpDis)

   LOCAL drawInfo := hwg_GetDrawItemInfo(lpDis)
   LOCAL dc := drawInfo[3]
   LOCAL bIsPressed := HWG_BITAND(drawInfo[9], ODS_SELECTED) != 0
   LOCAL bIsFocused := HWG_BITAND(drawInfo[9], ODS_FOCUS) != 0
   LOCAL bIsDisabled := HWG_BITAND(drawInfo[9], ODS_DISABLED) != 0
   LOCAL bDrawFocusRect := !HWG_BITAND(drawInfo[9], ODS_NOFOCUSRECT) != 0
   LOCAL focusRect
   LOCAL captionRect
   LOCAL centerRect
   LOCAL bHasTitle
   LOCAL itemRect := hwg_CopyRect({drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7]})
   LOCAL state
   LOCAL crColor
   LOCAL brBackground
   LOCAL br
   LOCAL brBtnShadow
   LOCAL uState
   LOCAL captionRectHeight
   LOCAL centerRectHeight
   //LOCAL captionRectWidth
   //LOCAL centerRectWidth
   LOCAL uAlign
   LOCAL uStyleTmp
   LOCAL aTxtSize := IIf(!Empty(::caption), hwg_TxtRect(::caption, Self), {0, 0})
   LOCAL aBmpSize := IIf(!Empty(::hbitmap), hwg_GetBitmapSize(::hbitmap), {0, 0})
   LOCAL itemRectOld
   LOCAL saveCaptionRect
   LOCAL bmpRect
   LOCAL itemRect1
   LOCAL captionRect1
   LOCAL fillRect
   LOCAL lMultiLine
   LOCAL nHeight := 0

   IF ::m_bFirstTime
      ::m_bFirstTime := .F.
      IF hwg_IsThemedLoad()
         IF hb_IsPointer(::hTheme)
            hwg_CloseThemeData(::htheme)
         ENDIF
         ::hTheme := NIL
         IF ::WindowsManifest
            ::hTheme := hwg_OpenThemeData(::handle, "BUTTON")
         ENDIF
      ENDIF
   ENDIF
   IF !Empty(::hTheme) .AND. !::lnoThemes
      ::Themed := .T.
   ENDIF

   hwg_SetBkMode(dc, WINAPI_TRANSPARENT)
   IF ::m_bDrawTransparent
//        ::PaintBk(DC)
   ENDIF

   // Prepare draw... paint button background

   IF ::Themed

      IF bIsDisabled
         state := PBS_DISABLED
      ELSE
         state := IIf(bIsPressed, PBS_PRESSED, PBS_NORMAL)
      ENDIF
      IF state == PBS_NORMAL
         IF bIsFocused
            state := PBS_DEFAULTED
         ENDIF
         IF ::bMouseOverButton .OR. ::id == IDOK
            state := PBS_HOT
         ENDIF
      ENDIF
      IF !::lFlat
         hwg_DrawThemeBackground(::hTheme, dc, BP_PUSHBUTTON, state, itemRect, NIL)
      ELSEIF bIsDisabled
         hwg_FillRect(dc, itemRect[1] + 1, itemRect[2] + 1, itemRect[3] - 1, itemRect[4] - 1, hwg_GetSysColorBrush(hwg_GetSysColor(COLOR_BTNFACE)))
      ELSEIF ::bMouseOverButton .OR. bIsFocused
         hwg_DrawThemeBackground(::hTheme, dc, BP_PUSHBUTTON, state, itemRect, NIL) // + PBS_DEFAULTED
      ENDIF
   ELSE

      IF bIsFocused .OR. ::id == IDOK
         br := HBRUSH():Add(hwg_RGB(1, 1, 1))
         hwg_FrameRect(dc, itemRect, br:handle)
         hwg_InflateRect(@itemRect, -1, -1)
      ENDIF
      crColor := hwg_GetSysColor(COLOR_BTNFACE)
      brBackground := HBRUSH():Add(crColor)
      hwg_FillRect(dc, itemRect, brBackground:handle)

      IF bIsPressed
         brBtnShadow := HBRUSH():Add(hwg_GetSysColor(COLOR_BTNSHADOW))
         hwg_FrameRect(dc, itemRect, brBtnShadow:handle)
      ELSE
         IF !::lFlat .OR. ::bMouseOverButton
            uState := HWG_BITOR(HWG_BITOR(DFCS_BUTTONPUSH, IIf(::bMouseOverButton, DFCS_HOT, 0)), ;
               IIf(bIsPressed, DFCS_PUSHED, 0))
            hwg_DrawFrameControl(dc, itemRect, DFC_BUTTON, uState)
         ELSEIF bIsFocused
            uState := HWG_BITOR(HWG_BITOR(DFCS_BUTTONPUSH + DFCS_MONO, ; // DFCS_FLAT, ;
               IIf(::bMouseOverButton, DFCS_HOT, 0)), IIf(bIsPressed, DFCS_PUSHED, 0))
            hwg_DrawFrameControl(dc, itemRect, DFC_BUTTON, uState)
         ENDIF
      ENDIF
   ENDIF

//      IF ::iStyle ==  ST_ALIGN_HORIZ
//         uAlign := DT_RIGHT
//      ELSE
//         uAlign := DT_LEFT
//      ENDIF
//
//      IF !hb_IsNumeric(::hbitmap)
//         uAlign := DT_CENTER
//      ENDIF

   uAlign := 0 //DT_LEFT
   IF hb_IsNumeric(::hbitmap) .OR. hb_IsNumeric(::hicon)
      uAlign := DT_CENTER + DT_VCENTER
   ENDIF
   /*
   IF hb_IsNumeric(::hicon)
      uAlign := DT_CENTER
   ENDIF
   */
   IF uAlign != DT_CENTER + DT_VCENTER
      uAlign := IIf(HWG_BITAND(::Style, BS_TOP) != 0, DT_TOP, DT_VCENTER)
      uAlign += IIf(HWG_BITAND(::Style, BS_BOTTOM) != 0, DT_BOTTOM - DT_VCENTER, 0)
      uAlign += IIf(HWG_BITAND(::Style, BS_LEFT) != 0, DT_LEFT, DT_CENTER)
      uAlign += IIf(HWG_BITAND(::Style, BS_RIGHT) != 0, DT_RIGHT - DT_CENTER, 0)
   ELSE   
      uAlign := IIf(uAlign == 0, DT_CENTER + DT_VCENTER, uAlign)
   ENDIF   


//             DT_CENTER | DT_VCENTER | DT_SINGLELINE
//   uAlign += DT_WORDBREAK + DT_CENTER + DT_CALCRECT +  DT_VCENTER + DT_SINGLELINE  // DT_SINGLELINE + DT_VCENTER + DT_WORDBREAK
 //  uAlign += DT_VCENTER
   uStyleTmp := hwg_GetWindowStyle(::handle)
   itemRectOld := aclone(itemRect)
   IF hb_BitAnd(uStyleTmp, BS_MULTILINE) != 0 .AND. !Empty(::caption) .AND. ;
      INT(aTxtSize[2]) !=  INT(hwg_DrawText(dc, ::caption, itemRect[1], itemRect[2], ;
          itemRect[3] - IIf(::iStyle == ST_ALIGN_VERT, 0, aBmpSize[1] + 8), ;
          itemRect[4], DT_CALCRECT + uAlign + DT_WORDBREAK, itemRectOld))
      //-INT(aTxtSize[2]) !=  INT(hwg_DrawText(dc, ::caption, itemRect, DT_CALCRECT + uAlign + DT_WORDBREAK))
      uAlign += DT_WORDBREAK
      lMultiline := .T.
      drawInfo[4] += 2
      drawInfo[6] -= 2
      itemRect[1] += 2
      itemRect[3] -= 2
      aTxtSize[1] := itemRectold[3] - itemRectOld[1] + 1
      aTxtSize[2] := itemRectold[4] - itemRectold[2] + 1
   ELSE
      uAlign += DT_SINGLELINE
      lMultiline := .F.
   ENDIF

   captionRect := {drawInfo[4], drawInfo[5], drawInfo[6], drawInfo[7]}
   //
   IF (hb_IsNumeric(::hbitmap) .OR. hb_IsNumeric(::hicon)) .AND. lMultiline
      IF ::iStyle == ST_ALIGN_HORIZ
         captionRect := {drawInfo[4] + ::PictureMargin, drawInfo[5], drawInfo[6], drawInfo[7]}
      ELSEIF ::iStyle == ST_ALIGN_HORIZ_RIGHT
         captionRect := {drawInfo[4], drawInfo[5], drawInfo[6] - ::PictureMargin, drawInfo[7]}
      ELSEIF ::iStyle == ST_ALIGN_VERT
      ENDIF
   ENDIF

   itemRectOld := AClone(itemRect)

   IF !Empty(::caption) .AND. !Empty(::hbitmap)  //.AND.!Empty(::hicon)
      nHeight := aTxtSize[2] //nHeight := IIf(lMultiLine, hwg_DrawText(dc, ::caption, itemRect, DT_CALCRECT + uAlign + DT_WORDBREAK), aTxtSize[2])
      IF ::iStyle == ST_ALIGN_HORIZ
          itemRect[1] := IIf(::PictureMargin == 0, (((::nWidth - aTxtSize[1] - aBmpSize[1] / 2) / 2)) / 2, ::PictureMargin)
         itemRect[1] := IIf(itemRect[1] < 0, 0, itemRect[1])
      ELSEIF ::iStyle == ST_ALIGN_HORIZ_RIGHT
      ELSEIF ::iStyle == ST_ALIGN_VERT .OR. ::iStyle == ST_ALIGN_OVERLAP
         nHeight := IIf(lMultiLine, hwg_DrawText(dc, ::caption, itemRect, DT_CALCRECT + DT_WORDBREAK), aTxtSize[2])
         ::iStyle := ST_ALIGN_OVERLAP
         itemRect[1] := (::nWidth - aBmpSize[1]) /  2
         itemRect[2] := IIf(::PictureMargin == 0, (((::nHeight - (nHeight + aBmpSize[2] + 1)) / 2)), ::PictureMargin)
      ENDIF
   ELSEIF !Empty(::caption)
      nHeight := aTxtSize[2] //nHeight := IIf(lMultiLine, hwg_DrawText(dc, ::caption, itemRect, DT_CALCRECT + DT_WORDBREAK), aTxtSize[2])
   ENDIF

   bHasTitle := hb_IsChar(::caption) .AND. !Empty(::Caption)

   //   hwg_DrawTheIcon(::handle, dc, bHasTitle, @itemRect, @captionRect, bIsPressed, bIsDisabled, ::hIcon, ::hbitmap, ::iStyle)
   IF hb_IsNumeric(::hbitmap) .AND. ::m_bDrawTransparent .AND. (!bIsDisabled .OR. ::istyle == ST_ALIGN_HORIZ_RIGHT)
      bmpRect := hwg_PrepareImageRect(::handle, dc, bHasTitle, @itemRect, @captionRect, bIsPressed, ::hIcon, ::hbitmap, ::iStyle)
      IF ::istyle == ST_ALIGN_HORIZ_RIGHT
         bmpRect[1] -= ::PictureMargin
         captionRect[3] -= ::PictureMargin
      ENDIF
      IF !bIsDisabled
          hwg_DrawTransparentBitmap(dc, ::hbitmap, bmpRect[1], bmpRect[2])
      ELSE
          hwg_DrawGrayBitmap(dc, ::hbitmap, bmpRect[1], bmpRect[2])
      ENDIF
   ELSEIF hb_IsNumeric(::hbitmap) .OR. hb_IsNumeric(::hicon)
       IF ::istyle == ST_ALIGN_HORIZ_RIGHT             
         captionRect[3] -= ::PictureMargin 
       ENDIF
       hwg_DrawTheIcon(::handle, dc, bHasTitle, @itemRect, @captionRect, bIsPressed, bIsDisabled, ::hIcon, ::hbitmap, ::iStyle)
   ELSE
       hwg_InflateRect(@captionRect, - 3, - 3)       
   ENDIF
   itemRect1 := aclone(itemRect)
   captionRect1 := aclone(captionRect)
   itemRect := aclone(itemRectOld)

   IF bHasTitle

      // If button is pressed then "press" title also
      IF bIsPressed .AND. !::Themed
         hwg_OffsetRect(@captionRect, 1, 1)
      ENDIF

      // Center text
      centerRect := hwg_CopyRect(captionRect)

      IF hb_IsNumeric(::hicon) .OR. hb_IsNumeric(::hbitmap)
          IF !lmultiline .AND. ::iStyle != ST_ALIGN_OVERLAP
             // hwg_DrawText(dc, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], uAlign + DT_CALCRECT, @captionRect)
          ELSEIF !Empty(::caption)
             // figura no topo texto em baixo
             IF ::iStyle == ST_ALIGN_OVERLAP //ST_ALIGN_VERT
                captionRect[2] := itemRect1[2] + aBmpSize[2] //+ 1
                uAlign -= ST_ALIGN_OVERLAP + 1
             ELSE
                captionRect[2] := (::nHeight - nHeight) / 2 + 2
             ENDIF
             savecaptionRect := aclone(captionRect)
             hwg_DrawText(dc, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], uAlign, @captionRect)
          ENDIF
      ELSE
         //- uAlign += DT_CENTER
      ENDIF

      //captionRectWidth := captionRect[3] - captionRect[1]
      captionRectHeight := captionRect[4] - captionRect[2]
      //centerRectWidth := centerRect[3] - centerRect[1]
      centerRectHeight := centerRect[4] - centerRect[2]
//ok      hwg_OffsetRect(@captionRect, (centerRectWidth - captionRectWidth) / 2, (centerRectHeight - captionRectHeight) / 2)
//      hwg_OffsetRect(@captionRect, (centerRectWidth - captionRectWidth) / 2, (centerRectHeight - captionRectHeight) / 2)
//      hwg_OffsetRect(@captionRect, (centerRectWidth - captionRectWidth) / 2, (centerRectHeight - captionRectHeight) / 2)
      hwg_OffsetRect(@captionRect, 0, (centerRectHeight - captionRectHeight) / 2)


/*      hwg_SetBkMode(dc, WINAPI_TRANSPARENT)
      IF bIsDisabled

         hwg_OffsetRect(@captionRect, 1, 1)
         hwg_SetTextColor(DC, hwg_GetSysColor(COLOR_3DHILIGHT))
         hwg_DrawText(DC, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], DT_WORDBREAK + DT_CENTER, @captionRect)
         hwg_OffsetRect(@captionRect, -1, -1)
         hwg_SetTextColor(DC, hwg_GetSysColor(COLOR_3DSHADOW))
         hwg_DrawText(DC, ::caption, captionRect[1], captionRect[2], captionRect[3], captionRect[4], DT_WORDBREAK + DT_VCENTER + DT_CENTER, @captionRect)

      ELSE

         IF ::bMouseOverButton .OR. bIsPressed

            hwg_SetTextColor(DC, ::m_crColors[BTNST_COLOR_FG_IN])
            hwg_SetBkColor(DC, ::m_crColors[BTNST_COLOR_BK_IN])

         ELSE

            IF bIsFocused

               hwg_SetTextColor(DC, ::m_crColors[BTNST_COLOR_FG_FOCUS])
               hwg_SetBkColor(DC, ::m_crColors[BTNST_COLOR_BK_FOCUS])

            ELSE

               hwg_SetTextColor(DC, ::m_crColors[BTNST_COLOR_FG_OUT])
               hwg_SetBkColor(DC, ::m_crColors[BTNST_COLOR_BK_OUT])
            ENDIF
         ENDIF
      ENDIF
  */

      IF ::Themed

         IF hb_IsNumeric(::hicon) .OR. hb_IsNumeric(::hbitmap)
            IF lMultiLine .OR. ::iStyle == ST_ALIGN_OVERLAP
               captionRect := aclone(savecaptionRect)
            ENDIF
         ELSEIF lMultiLine
            captionRect[2] := (::nHeight  - nHeight) / 2 + 2
         ENDIF

         hwg_DrawThemeText(::hTheme, dc, BP_PUSHBUTTON, IIf(bIsDisabled, PBS_DISABLED, PBS_NORMAL), ::caption, ;
            uAlign + DT_END_ELLIPSIS, 0, captionRect)

      ELSE

         hwg_SetBkMode(dc, WINAPI_TRANSPARENT)

         IF bIsDisabled

            hwg_OffsetRect(@captionRect, 1, 1)
            hwg_SetTextColor(dc, hwg_GetSysColor(COLOR_3DHILIGHT))
            hwg_DrawText(dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign)
            hwg_OffsetRect(@captionRect, -1, -1)
            hwg_SetTextColor(dc, hwg_GetSysColor(COLOR_3DSHADOW))
            hwg_DrawText(dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign)
            // if
         ELSE

            //hwg_SetTextColor(dc, hwg_GetSysColor(COLOR_BTNTEXT))
            //hwg_SetBkColor(dc, hwg_GetSysColor(COLOR_BTNFACE))
            //hwg_DrawText(dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign)
            IF ::bMouseOverButton .OR. bIsPressed
               hwg_SetTextColor(dc, ::m_crColors[BTNST_COLOR_FG_IN])
               hwg_SetBkColor(dc, ::m_crColors[BTNST_COLOR_BK_IN])
               fillRect := hwg_CopyRect(itemRect)
               IF bIsPressed
                  hwg_DrawButton(dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], 6)
               ENDIF
               hwg_InflateRect(@fillRect, - 2, - 2)
               hwg_FillRect(dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_IN]:handle)
            ELSE
               IF bIsFocused
                  hwg_SetTextColor(dc, ::m_crColors[BTNST_COLOR_FG_FOCUS])
                  hwg_SetBkColor(dc, ::m_crColors[BTNST_COLOR_BK_FOCUS])
                  fillRect := hwg_CopyRect(itemRect)
                  hwg_InflateRect(@fillRect, - 2, - 2)
                  hwg_FillRect(dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_FOCUS]:handle)
               ELSE
                  hwg_SetTextColor(dc, ::m_crColors[BTNST_COLOR_FG_OUT])
                  hwg_SetBkColor(dc, ::m_crColors[BTNST_COLOR_BK_OUT])
                  fillRect := hwg_CopyRect(itemRect)
                  hwg_InflateRect(@fillRect, - 2, - 2)
                  hwg_FillRect(dc, fillRect[1], fillRect[2], fillRect[3], fillRect[4], ::m_crBrush[BTNST_COLOR_BK_OUT]:handle)
               ENDIF
            ENDIF
            IF hb_IsNumeric(::hbitmap) .AND. ::m_bDrawTransparent
               hwg_DrawTransparentBitmap(dc, ::hbitmap, bmpRect[1], bmpRect[2])
            ELSEIF hb_IsNumeric(::hbitmap) .OR. hb_IsNumeric(::hicon)
               hwg_DrawTheIcon(::handle, dc, bHasTitle, @itemRect1, @captionRect1, bIsPressed, bIsDisabled, ::hIcon, ::hbitmap, ::iStyle)
            ENDIF

            IF hb_IsNumeric(::hicon) .OR. hb_IsNumeric(::hbitmap)
               IF lmultiline .OR. ::iStyle == ST_ALIGN_OVERLAP
                  captionRect := aclone(savecaptionRect)
               ENDIF
            ELSEIF lMultiLine
               captionRect[2] := (::nHeight  - nHeight) / 2 + 2
            ENDIF

            hwg_DrawText(dc, ::caption, @captionRect[1], @captionRect[2], @captionRect[3], @captionRect[4], uAlign)

         ENDIF
      ENDIF
   ENDIF

   // Draw the focus rect
   IF bIsFocused .AND. bDrawFocusRect .AND. hwg_BitaND(::sTyle, WS_TABSTOP) != 0
      focusRect := hwg_CopyRect(itemRect)
      hwg_InflateRect(@focusRect, - 3, - 3)
      hwg_DrawFocusRect(dc, focusRect)
   ENDIF

   hwg_DeleteObject(br)
   hwg_DeleteObject(brBackground)
   hwg_DeleteObject(brBtnShadow)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HButtonEx:PAINTBK(hdc)

   LOCAL clDC := HclientDc():New(::oparent:handle)
   LOCAL rect
   LOCAL rect1

   rect := hwg_GetClientRect(::handle)

   rect1 := hwg_GetWindowRect(::handle)
   hwg_ScreenToClient(::oparent:handle, rect1)

   IF ValType(::m_dcBk) == "U"
      ::m_dcBk := hdc():New()
      ::m_dcBk:CreateCompatibleDC(clDC:m_hDC)
      ::m_bmpBk := hwg_CreateCompatibleBitmap(clDC:m_hDC, rect[3] - rect[1], rect[4] - rect[2])
      ::m_pbmpOldBk := ::m_dcBk:SelectObject(::m_bmpBk)
      ::m_dcBk:BitBlt(0, 0, rect[3] - rect[1], rect[4] - rect[4], clDC:m_hDc, rect1[1], rect1[2], SRCCOPY)
   ENDIF

   hwg_BitBlt(hdc, 0, 0, rect[3] - rect[1], rect[4] - rect[4], ::m_dcBk:m_hDC, 0, 0, SRCCOPY)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//
