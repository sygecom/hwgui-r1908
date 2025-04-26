//
// $Id: hwindow.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HWindow class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

REQUEST HWG_ENDWINDOW

#define FIRST_MDICHILD_ID     501
#define MAX_MDICHILD_WINDOWS   18
//#define WM_NOTIFYICON         WM_USER + 1000 // defined in windows.ch
#define ID_NOTIFYICON           1

STATIC FUNCTION onSize(oWnd, wParam, lParam)

   // writelog("OnSize: " + Str(oWnd:nWidth) + " " + Str(oWnd:nHeight) + " " + Str(hwg_LOWORD(lParam)) + " " + Str(hwg_HIWORD(lParam)))

   oWnd:Super:onEvent(WM_SIZE, wParam, lParam)

   oWnd:nWidth  := hwg_LOWORD(lParam)
   oWnd:nHeight := hwg_HIWORD(lParam)

   IF HB_IsBlock(oWnd:bSize)
       Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
   ENDIF

RETURN 0

STATIC FUNCTION onDestroy(oWnd)

   oWnd:Super:onEvent(WM_DESTROY)
   HWindow():DelItem(oWnd)
   hwg_gtk_exit()  

RETURN 0

CLASS HWindow INHERIT HCustomWindow

   CLASS VAR aWindows   SHARED INIT {}
   CLASS VAR szAppName  SHARED INIT "HwGUI_App"

   DATA fbox
   DATA menu, oPopup, hAccel
   DATA oIcon, oBmp
   DATA lUpdated INIT .F.     // TRUE, if any GET is changed
   DATA lClipper INIT .F.
   DATA GetList  INIT {}      // The array of GET items in the dialog
   DATA KeyList  INIT {}      // The array of keys ( as Clipper's SET KEY )
   DATA nLastKey INIT 0

   DATA aOffset

   //METHOD New(Icon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
   //       bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, cHelp, nHelpId)
   METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                  bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                  cAppName, oBmp, cHelp, nHelpId)
   METHOD AddItem(oWnd)
   METHOD DelItem(oWnd)
   METHOD FindWindow(hWnd)
   METHOD GetMain()
   METHOD Restore() INLINE hwg_WindowRestore(::handle)
   METHOD Maximize() INLINE hwg_WindowMaximize(::handle)
   METHOD Minimize() INLINE hwg_WindowMinimize(::handle)
   METHOD Close() INLINE hwg_DestroyWindow(::handle)
ENDCLASS

METHOD HWindow:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                  bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                  cAppName, oBmp, cHelp, nHelpId)

   HB_SYMBOL_UNUSED(clr)
   HB_SYMBOL_UNUSED(cMenu)
   HB_SYMBOL_UNUSED(cHelp)

   ::oDefaultParent := Self
   ::title    := cTitle
   ::style    := IIf(nStyle == NIL, 0, nStyle)
   ::oIcon    := oIcon
   ::oBmp     := oBmp
   ::nTop     := IIf(y == NIL, 0, y)
   ::nLeft    := IIf(x == NIL, 0, x)
   ::nWidth   := IIf(width == NIL, 0, width)
   ::nHeight  := IIf(height == NIL, 0, height)
   ::oFont    := oFont
   ::bInit    := bInit
   ::bDestroy := bExit
   ::bSize    := bSize
   ::bPaint   := bPaint
   ::bGetFocus  := bGFocus
   ::bLostFocus := bLFocus
   ::bOther     := bOther
   IF cAppName != NIL
      ::szAppName := cAppName
   ENDIF
   
   IF hwg_BitAnd(::style, DS_CENTER) > 0
      ::nLeft := Int((hwg_GetDesktopWidth() - ::nWidth) / 2)
      ::nTop  := Int((hwg_GetDesktopHeight() - ::nHeight) / 2)
   ENDIF 
   
   IF nHelpId != NIL
      ::HelpId := nHelpId
   END
   
   ::aOffset := Array(4)
   Afill(::aOffset, 0)

   ::AddItem(Self)

RETURN Self

METHOD HWindow:AddItem(oWnd)
   AAdd(::aWindows, oWnd)
RETURN NIL

METHOD HWindow:DelItem(oWnd)

   LOCAL i

   IF (i := AScan(::aWindows, {|o|o == oWnd})) > 0
      ADel(::aWindows, i)
      ASize(::aWindows, Len(::aWindows) - 1)
   ENDIF
RETURN NIL

METHOD HWindow:FindWindow(hWnd)
//LOCAL i := AScan(::aWindows, {|o|o:handle == hWnd})
//RETURN IIf(i == 0, NIL, ::aWindows[i])
RETURN hwg_GetWindowObject(hWnd)

METHOD HWindow:GetMain()
RETURN IIf(Len(::aWindows) > 0, ;
	 IIf(::aWindows[1]:type == WND_MAIN, ;
	   ::aWindows[1], ;
	   IIf(Len(::aWindows) > 1, ::aWindows[2], NIL)), NIL)



CLASS HMainWindow INHERIT HWindow

   CLASS VAR aMessages INIT { ;
      {WM_COMMAND, WM_ERASEBKGND, WM_MOVE, WM_SIZE, WM_SYSCOMMAND, ;
       WM_NOTIFYICON, WM_ENTERIDLE, WM_CLOSE, WM_DESTROY}, ;
      { ;
         {|o, w, l|onCommand(o, w, l)}, ;
         {|o, w|onEraseBk(o, w)}, ;
         {|o, w, l|onMove(o, w, l)}, ;
         {|o, w, l|onSize(o, w, l)}, ;
         {|o, w|onSysCommand(o, w)}, ;
         {|o, w, l|onNotifyIcon(o, w, l)}, ;
         {|o, w, l|onEnterIdle(o, w, l)}, ;
         {|o|hwg_ReleaseAllWindows(o:handle)}, ;
         {|o|onDestroy(o)} ;
      } ;
   }
   DATA nMenuPos
   DATA oNotifyIcon, bNotify, oNotifyMenu
   DATA lTray       INIT .F.
   DATA lActivated  INIT .F.

   METHOD New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, ;
                     oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                     cAppName, oBmp, cHelp, nHelpId)
   //METHOD Activate(lShow)
   METHOD Activate(lShow, lMaximize, lMinimize)
   METHOD onEvent(msg, wParam, lParam)
   // METHOD GetMdiActive() INLINE ::FindWindow(hwg_SendMessage(::GetMain():handle, WM_MDIGETACTIVE, 0, 0))

ENDCLASS

METHOD HMainWindow:New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, ;
                     oFont, bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                     cAppName, oBmp, cHelp, nHelpId)

   HB_SYMBOL_UNUSED(nPos)

   ::Super:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                  bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                  cAppName, oBmp, cHelp, nHelpId)
   ::type := lType

   IF lType == WND_MDI
/*
      ::nMenuPos := nPos
      ::handle := hwg_InitMdiWindow(Self, ::szAppName, cTitle, cMenu, ;
                    IIf(oIcon != NIL, oIcon:handle, NIL), clr, ;
                    nStyle, ::nLeft, ::nTop, ::nWidth, ::nHeight)
*/
   ELSEIF lType == WND_MAIN

      ::handle := hwg_InitMainWindow(Self, ::szAppName, cTitle, cMenu, ;
              IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), ::Style, ::nLeft, ;
              ::nTop, ::nWidth, ::nHeight)
    
   ENDIF
   IF ::bInit != NIL
      Eval(::bInit, Self)
   ENDIF

RETURN Self

METHOD HMainWindow:Activate(lShow, lMaximize, lMinimize)

   //LOCAL oWndClient // variable not used
   //LOCAL handle // variable not used
   
   HB_SYMBOL_UNUSED(lShow)

   // hwg_CreateGetList(Self)

   IF ::type == WND_MDI
/*
      oWndClient := HWindow():New(,,, ::style, ::title,, ::bInit, ::bDestroy, ::bSize, ;
                              ::bPaint, ::bGetFocus, ::bLostFocus, ::bOther)
      handle := hwg_InitClientWindow(oWndClient, ::nMenuPos, ::nLeft, ::nTop + 60, ::nWidth, ::nHeight)
      oWndClient:handle = handle
      hwg_ActivateMdiWindow((lShow == NIL .OR. lShow), ::hAccel, ::lMaximize)
*/
   ELSEIF ::type == WND_MAIN

      ::lActivated := .T.
      hwg_ActivateMainWindow(::handle, ::hAccel, lMaximize, lMinimize)

   ENDIF

RETURN NIL

METHOD HMainWindow:onEvent(msg, wParam, lParam)

   LOCAL i

   // writelog("On Event" + str(msg) + str(wParam) + Str(lParam))
   IF (i := AScan(::aMessages[1], msg)) != 0
      RETURN Eval(::aMessages[2, i], Self, wParam, lParam)
   ELSE
      IF msg == WM_HSCROLL .OR. msg == WM_VSCROLL
         // hwg_OnTrackScroll(Self, wParam, lParam)
      ENDIF
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN 0

/*
CLASS HMDIChildWindow INHERIT HWindow

   CLASS VAR aMessages INIT { ;
      {WM_CREATE, WM_COMMAND, WM_MOVE, WM_SIZE, WM_NCACTIVATE, ;
       WM_SYSCOMMAND, WM_DESTROY}, ;
      { ;
         {|o, w, l|onMdiCreate(o, l)}, ;
         {|o, w|onMdiCommand(o, w)}, ;
         {|o, w, l|onMove(o, w, l)}, ;
         {|o, w, l|onSize(o, w, l)}, ;
         {|o, w|onMdiNcActivate(o, w)}, ;
         {|o, w|onSysCommand(o, w)}, ;
         {|o|onDestroy(o)} ;
      } ;
   }

   METHOD Activate(lShow)
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

METHOD HMDIChildWindow:Activate(lShow)

   hwg_CreateGetList(Self)
   // hwg_CreateMdiChildWindow(Self)
   
   ::handle := hwg_CreateMdiChildWindow(Self)
   hwg_InitControls(Self)
   IF ::bInit != NIL
      Eval(::bInit, Self)
   ENDIF  

RETURN NIL

METHOD HMDIChildWindow:onEvent(msg, wParam, lParam)

   LOCAL i

   IF (i := AScan(::aMessages[1], msg)) != 0
      RETURN Eval(::aMessages[2, i], Self, wParam, lParam)
   ELSE
      IF msg == WM_HSCROLL .OR. msg == WM_VSCROLL
         hwg_OnTrackScroll(Self, wParam, lParam)
      ENDIF
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN -1


CLASS HChildWindow INHERIT HWindow

   METHOD New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                     bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                     cAppName, oBmp, cHelp, nHelpId)
   METHOD Activate(lShow)
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

METHOD HChildWindow:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                  bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                  cAppName, oBmp, cHelp, nHelpId)

   ::Super:New(oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, oFont, ;
                  bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, ;
                  cAppName, oBmp, cHelp, nHelpId)
   ::oParent := HWindow():GetMain()
   IF HB_IsObject(::oParent)
       ::handle := hwg_InitChildWindow(Self, ::szAppName, cTitle, cMenu, ;
          IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), nStyle, ::nLeft, ;
          ::nTop, ::nWidth, ::nHeight, ::oParent:handle)
   ELSE
       hwg_MsgStop("Create Main window first !", "HChildWindow():New()")
       RETURN NIL
   ENDIF
   IF ::bInit != NIL
      Eval(::bInit, Self)
   ENDIF

RETURN Self

METHOD HChildWindow:Activate(lShow)

   hwg_CreateGetList(Self)
   hwg_ActivateChildWindow((lShow == NIL .OR. lShow), ::handle)

RETURN NIL

METHOD HChildWindow:onEvent(msg, wParam, lParam)

   LOCAL i

   IF (i := AScan(HMainWindow():aMessages[1], msg)) != 0
      RETURN Eval(HMainWindow():aMessages[2, i], Self, wParam, lParam)
   ELSE
      IF msg == WM_HSCROLL .OR. msg == WM_VSCROLL
         hwg_OnTrackScroll(Self, wParam, lParam)
      ENDIF
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN -1
*/

FUNCTION hwg_ReleaseAllWindows(hWnd)

   //LOCAL oItem // variable not used
   //LOCAL iCont // variable not used
   //LOCAL nCont // variable not used
   
   HB_SYMBOL_UNUSED(hWnd)

/*
   //  Vamos mandar destruir as filhas
   // Destroi as CHILD's desta MAIN
   #ifdef __XHARBOUR__
   FOR EACH oItem IN HWindow():aWindows
      IF oItem:oParent != NIL .AND. oItem:oParent:handle == hWnd
          hwg_SendMessage(oItem:handle, WM_CLOSE, 0, 0)
      ENDIF
   NEXT
   #else
   nCont := Len(HWindow():aWindows)

   FOR iCont := nCont TO 1 STEP -1

      IF HWindow():aWindows[iCont]:oParent != NIL .AND. ;
              HWindow():aWindows[iCont]:oParent:handle == hWnd
          hwg_SendMessage(HWindow():aWindows[iCont]:handle, WM_CLOSE, 0, 0)
      ENDIF

   NEXT
   #endif

   IF HWindow():aWindows[1]:handle == hWnd
      hwg_PostQuitMessage(0)
   ENDIF
*/
RETURN -1

STATIC FUNCTION onCommand(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL iCont
   LOCAL aMenu
   LOCAL iParHigh
   LOCAL iParLow
   //LOCAL nHandle // variable not used

   HB_SYMBOL_UNUSED(lParam)

/*
   IF wParam == SC_CLOSE
       IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
       ENDIF
   ELSEIF wParam == SC_RESTORE
       IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIRESTORE, nHandle, 0)
       ENDIF
   ELSEIF wParam == SC_MAXIMIZE
       IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
          hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIMAXIMIZE, nHandle, 0)
       ENDIF
   ELSEIF wParam >= FIRST_MDICHILD_ID .AND. wparam < FIRST_MDICHILD_ID + MAX_MDICHILD_WINDOWS
       nHandle := HWindow():aWindows[wParam - FIRST_MDICHILD_ID + 3]:handle
       hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIACTIVATE, nHandle, 0)
   ENDIF
*/
   iParHigh := hwg_HIWORD(wParam)
   iParLow := hwg_LOWORD(wParam)
   IF oWnd:aEvents != NIL .AND. ;
        (iItem := AScan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
        Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ELSEIF HB_IsArray(oWnd:menu) .AND. ;
        (aMenu := hwg_FindMenuItem(oWnd:menu, iParLow, @iCont)) != NIL ;
        .AND. aMenu[1, iCont, 1] != NIL
      Eval(aMenu[1, iCont, 1])
   ELSEIF oWnd:oPopup != NIL .AND. ;
        (aMenu := hwg_FindMenuItem(oWnd:oPopup:aMenu, wParam, @iCont)) != NIL ;
        .AND. aMenu[1, iCont, 1] != NIL
      Eval(aMenu[1, iCont, 1])
   ELSEIF oWnd:oNotifyMenu != NIL .AND. ;
        (aMenu := hwg_FindMenuItem(oWnd:oNotifyMenu:aMenu, wParam, @iCont)) != NIL ;
        .AND. aMenu[1, iCont, 1] != NIL
      Eval(aMenu[1, iCont, 1])
   ENDIF

RETURN 0

STATIC FUNCTION onMove(oWnd, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)

   // writelog("onMove: " + str(oWnd:nLeft) + " " + str(oWnd:nTop) + " -> " + str(hwg_LOWORD(lParam)) + str(hwg_HIWORD(lParam)))
   oWnd:nLeft := hwg_LOWORD(lParam)
   oWnd:nTop  := hwg_HIWORD(lParam)

RETURN 0

STATIC FUNCTION onEraseBk(oWnd, wParam)

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(wParam)

/*
   IF oWnd:oBmp != NIL
       hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
       RETURN 1
   ENDIF
*/
RETURN 0

STATIC FUNCTION onSysCommand(oWnd, wParam)

   //LOCAL i // variable not used

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(wParam)

/*
   IF wParam == SC_CLOSE
       IF HB_IsBlock(oWnd:bDestroy)
          i := Eval(oWnd:bDestroy, oWnd)
          i := IIf(HB_IsLogical(i), i, .T.)
          IF !i
             RETURN 0
          ENDIF
       ENDIF
       IF __ObjHasMsg(oWnd, "ONOTIFYICON") .AND. oWnd:oNotifyIcon != NIL
          hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
       ENDIF
       IF __ObjHasMsg(oWnd, "HACCEL") .AND. oWnd:hAccel != NIL
          hwg_DestroyAcceleratorTable(oWnd:hAccel)
       ENDIF
   ELSEIF wParam == SC_MINIMIZE
       IF __ObjHasMsg(oWnd, "LTRAY") .AND. oWnd:lTray
          oWnd:Hide()
          RETURN 0
       ENDIF
   ENDIF
*/
RETURN 0

STATIC FUNCTION onNotifyIcon(oWnd, wParam, lParam)

   //LOCAL ar // variable not used

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

/*
   IF wParam == ID_NOTIFYICON
       IF lParam == WM_LBUTTONDOWN
          IF HB_IsBlock(oWnd:bNotify)
             Eval(oWnd:bNotify)
          ENDIF
       ELSEIF lParam == WM_RBUTTONDOWN
          IF oWnd:oNotifyMenu != NIL
             ar := hwg_GetCursorPos()
             oWnd:oNotifyMenu:Show(oWnd, ar[1], ar[2])
          ENDIF
       ENDIF
   ENDIF
*/
RETURN 0

#if 0 // static function never used
STATIC FUNCTION onMdiCreate(oWnd, lParam)

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(lParam)

/*
   hwg_InitControls(oWnd)
   IF oWnd:bInit != NIL
      Eval(oWnd:bInit, oWnd)
   ENDIF
*/
RETURN 0
#endif

#if 0 // static function never used
STATIC FUNCTION onMdiCommand(oWnd, wParam)

   //LOCAL iParHigh // variable not used
   //LOCAL iParLow // variable not used
   //LOCAL iItem // variable not used

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(wParam)

/*
   IF wParam == SC_CLOSE
      hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, oWnd:handle, 0)
   ENDIF
   iParHigh := hwg_HIWORD(wParam)
   iParLow := hwg_LOWORD(wParam)
   IF oWnd:aEvents != NIL .AND. ;
      (iItem := AScan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ENDIF
*/
RETURN 0
#endif

#if 0 // static function never used
STATIC FUNCTION onMdiNcActivate(oWnd, wParam)

   HB_SYMBOL_UNUSED(oWnd)
   HB_SYMBOL_UNUSED(wParam)

/*
   IF wParam == 1 .AND. oWnd:bGetFocus != NIL
      Eval(oWnd:bGetFocus, oWnd)
   ELSEIF wParam == 0 .AND. oWnd:bLostFocus != NIL
      Eval(oWnd:bLostFocus, oWnd)
   ENDIF
*/
RETURN 0
#endif

STATIC FUNCTION onEnterIdle(oDlg, wParam, lParam)

   //LOCAL oItem // variable not used

   HB_SYMBOL_UNUSED(oDlg)
   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

/*
   IF wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
         .AND. oItem:handle == lParam .AND. !oItem:lActivated
      oItem:lActivated := .T.
      IF oItem:bActivate != NIL
         Eval(oItem:bActivate, oItem)
      ENDIF
   ENDIF
*/   
RETURN 0

FUNCTION hwg_CenterWindow(oWnd)

   oWnd:nLeft := Int((hwg_GetDesktopWidth() - oWnd:nWidth) / 2)
   oWnd:nTop  := Int((hwg_GetDesktopHeight() - oWnd:nHeight) / 2)
   hwg_MoveWindow(oWnd:handle, oWnd:nLeft, oWnd:nTop)

RETURN NIL

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(RELEASEALLWINDOWS, HWG_RELEASEALLWINDOWS);
#endif

#pragma ENDDUMP
