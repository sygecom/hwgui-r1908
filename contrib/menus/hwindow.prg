//
// $Id: hwindow.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// Window class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "windows.ch"
#include <HBClass.ch>
#include "guilib.ch"

#define FIRST_MDICHILD_ID     501
#define MAX_MDICHILD_WINDOWS   18
//#define WM_NOTIFYICON         WM_USER + 1000 // defined in windows.ch
#define ID_NOTIFYICON           1

//#define WM_MENUSELECT   287 // defined in windows.ch
#define MF_HILITE       128

CLASS HObject
   // DATA classname
ENDCLASS

CLASS HCustomWindow INHERIT HObject
   CLASS VAR oDefaultParent SHARED
   DATA handle  INIT 0
   DATA oParent
   DATA title
   DATA type
   DATA nTop, nLeft, nWidth, nHeight
   DATA tcolor, bcolor, brush
   DATA style
   DATA extStyle  INIT 0
   DATA lHide INIT .F.
   DATA oFont
   DATA aEvents   INIT {}
   DATA aNotify   INIT {}
   DATA aControls INIT {}
   DATA bInit
   DATA bDestroy
   DATA bSize
   DATA bPaint
   DATA bGetFocus
   DATA bLostFocus
   DATA bOther
   DATA cargo
   
   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, nId, bAction, lNotify) ;
      INLINE AAdd(IIf(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), {nEvent, nId, bAction})
   METHOD FindControl(nId, nHandle)
   METHOD Hide() INLINE (::lHide := .T., hwg_HideWindow(::handle))
   METHOD Show() INLINE (::lHide := .F., hwg_ShowWindow(::handle))
   METHOD Restore() INLINE hwg_SendMessage(::handle, WM_SYSCOMMAND, SC_RESTORE, 0)
   METHOD Maximize() INLINE hwg_SendMessage(::handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0)
   METHOD Minimize() INLINE hwg_SendMessage(::handle, WM_SYSCOMMAND, SC_MINIMIZE, 0)
ENDCLASS

METHOD FindControl(nId, nHandle) CLASS HCustomWindow
Local i := IIf(nId != NIL, AScan(::aControls, {|o|o:id == nId}), ;
                       AScan(::aControls, {|o|o:handle == nHandle}))
RETURN IIf(i == 0, NIL, ::aControls[i])

METHOD DelControl(oCtrl) CLASS HCustomWindow
Local h := oCtrl:handle
Local i := Ascan(::aControls, {|o|o:handle == h})

   hwg_SendMessage(h, WM_CLOSE, 0, 0)
   IF i != 0
      Adel(::aControls, i)
      ASize(::aControls, Len(::aControls) - 1)
   ENDIF
RETURN NIL

CLASS HWindow INHERIT HCustomWindow

   CLASS VAR aWindows   INIT {}
   CLASS VAR szAppName  SHARED INIT "HwGUI_App"

   DATA menu, nMenuPos, oPopup, hAccel
   DATA oIcon, oBmp
   DATA oNotifyIcon, bNotify, oNotifyMenu
   DATA lClipper
   DATA lTray INIT .F.
   DATA aOffset
   DATA lMaximize INIT .F.

   METHOD New(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, ;
          bInit, bExit, bSize, bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, lMaximize)
   METHOD Activate(lShow)
   METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu)
   METHOD AddItem(oWnd)
   METHOD DelItem(oWnd)
   METHOD FindWindow(hWnd)
   METHOD GetMain()
   METHOD GetMdiActive()
   METHOD Close()	INLINE hwg_EndWindow()
ENDCLASS

METHOD NEW(lType, oIcon, clr, nStyle, x, y, width, height, cTitle, cMenu, nPos, oFont, ;
                  bInit, bExit, bSize, ;
                  bPaint, bGfocus, bLfocus, bOther, cAppName, oBmp, lMaximize) CLASS HWindow
   Local hParent
   Local oWndClient

   // ::classname := "HWINDOW"
   ::oDefaultParent := Self
   ::type     := lType
   ::title    := cTitle
   ::style    := IIf(nStyle == NIL, 0, nStyle)
   ::nMenuPos := nPos
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
   ::lMaximize  := lMaximize
   IF cAppName != NIL
      ::szAppName := cAppName
   ENDIF
   // ::lClipper   := IIf(lClipper == NIL, .F., lClipper)
   ::aOffset := Array(4)
   Afill(::aOffset, 0)

   ::AddItem(Self)
   IF lType == WND_MAIN

      ::handle := hwg_InitMainWindow(::szAppName, cTitle, cMenu, ;
              IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), ::Style, ::nLeft, ;
              ::nTop, ::nWidth, ::nHeight)

   ELSEIF lType == WND_MDI

      // Register MDI frame  class
      // Create   MDI frame  window -> aWindows[0]
      hwg_InitMdiWindow(::szAppName, cTitle, cMenu, ;
              IIf(oIcon != NIL, oIcon:handle, NIL), clr, ;
              nStyle, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::handle = hwg_GetWindowHandle(1)

   ELSEIF lType == WND_CHILD // Janelas modeless que pertencem a MAIN - jamaj

      ::oParent := HWindow():GetMain()
      IF HB_IsObject(::oParent)
          ::handle := hwg_InitChildWindow(::szAppName, cTitle, cMenu, ;
             IIf(oIcon != NIL, oIcon:handle, NIL), IIf(oBmp != NIL, -1, clr), nStyle, ::nLeft, ;
             ::nTop, ::nWidth, ::nHeight, ::oParent:handle)
      ELSE
          hwg_MsgStop("Nao eh possivel criar CHILD sem primeiro criar MAIN")
          RETURN (NIL)
      ENDIF

   ELSEIF lType == WND_MDICHILD //
      ::szAppName := "MDICHILD" + Alltrim(Str(hwg_GETNUMWINDOWS()))
      // Registra a classe
      hwg_InitMdiChildWindow(::szAppName, cTitle, cMenu, ;
              IIf(oIcon != NIL, oIcon:handle, NIL), clr, ;
              nStyle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

       // Cria a window
       ::handle := hwg_CreateMdiChildWindow(Self)
       // Janela pai = janela cliente MDI
       oWndClient := HWindow():FindWindow(hwg_GetWindowHandle(2))
       ::oParent := oWndClient

   ENDIF

RETURN Self
// Alterado por jamaj - added WND_CHILD support
METHOD Activate(lShow) CLASS HWindow
   Local oWndClient
   Local oWnd := SELF

   IF ::type == WND_MDICHILD


   ELSEIF ::type == WND_MDI
      hwg_InitClientWindow(oWnd:nMenuPos, oWnd:nLeft, oWnd:nTop + 60, oWnd:nWidth, oWnd:nHeight)

      oWndClient := HWindow():New(0,,, oWnd:style, oWnd:title,, oWnd:nMenuPos, oWnd:bInit, oWnd:bDestroy, oWnd:bSize, ;
                              oWnd:bPaint, oWnd:bGetFocus, oWnd:bLostFocus, oWnd:bOther)

      oWndClient:handle := hwg_GetWindowHandle(2)
      oWndClient:oParent := HWindow():GetMain()

      hwg_ActivateMdiWindow((lShow == NIL .OR. lShow), ::hAccel)
   ELSEIF ::type == WND_MAIN
      hwg_ActivateMainWindow((lShow == NIL .OR. lShow), ::hAccel)
   ELSEIF ::type == WND_CHILD
      hwg_ActivateChildWindow(::handle)
   ELSE

   ENDIF

RETURN NIL

METHOD InitTray(oNotifyIcon, bNotify, oNotifyMenu, cTooltip) CLASS HWindow

   ::bNotify     := bNotify
   ::oNotifyMenu := oNotifyMenu
   ::oNotifyIcon := oNotifyIcon
   hwg_ShellNotifyIcon(.T., ::handle, oNotifyIcon:handle, cTooltip)
   ::lTray := .T.

RETURN NIL

METHOD AddItem(oWnd) CLASS HWindow
   AAdd(::aWindows, oWnd)
RETURN NIL

METHOD DelItem(oWnd) CLASS HWindow
Local i, h := oWnd:handle
   IF (i := Ascan(::aWindows, {|o|o:handle == h})) > 0
      Adel(::aWindows, i)
      ASize(::aWindows, Len(::aWindows) - 1)
   ENDIF
RETURN NIL

METHOD FindWindow(hWnd) CLASS HWindow
Local i := Ascan(::aWindows, {|o|o:handle == hWnd})
RETURN IIf(i == 0, NIL, ::aWindows[i])

METHOD GetMain CLASS HWindow
RETURN IIf(Len(::aWindows) > 0, ;
	 IIf(::aWindows[1]:type == WND_MAIN, ;
	   ::aWindows[1], ;
	   IIf(Len(::aWindows) > 1, ::aWindows[2], NIL)), NIL)

METHOD GetMdiActive() CLASS HWindow 
RETURN ::FindWindow (hwg_SendMessage(::GetMain():handle, WM_MDIGETACTIVE, 0, 0))

FUNCTION DefWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem

   // WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("DefWndProc -Inicio", 40) + "|")
   IF (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("Message: wrong window handle " + Str(hWnd) + "/" + Str(msg), "Error!")
      IF msg == WM_CREATE
         IF Len(HWindow():aWindows) != 0 .AND. ;
              (oWnd := HWindow():aWindows[Len(HWindow():aWindows)]) != NIL .AND. ;
              oWnd:handle == 0
            oWnd:handle := hWnd
            IF oWnd:bInit != NIL
               Eval(oWnd:bInit, oWnd)
            ENDIF
         ENDIF
      ENDIF
      RETURN -1
   ENDIF
   IF msg == WM_COMMAND
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - COMMAND", 40) + "|")
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
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
           (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
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
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != NIL
         RETURN Eval(oWnd:bPaint, oWnd)
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3] - aControls[1]
      oWnd:nHeight := aControls[4] - aControls[2]
      IF HB_IsBlock(oWnd:bSize)
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd) + "--" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd) + "==" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3] - oWnd:aOffset[1] - oWnd:aOffset[3], aControls[4] - oWnd:aOffset[2] - oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle) + "::" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          RETURN 0
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM

      IF (oBtn := oWnd:FindControl(wParam)) != NIL
          IF HB_IsBlock(oBtn:bPaint)
             Eval(oBtn:bPaint, oBtn, lParam)
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   ELSEIF msg == WM_ENTERIDLE
      DlgEnterIdle(oWnd, wParam, lParam)

   ELSEIF msg == WM_CLOSE
      hwg_ReleaseAllWindows(oWnd, hWnd)

   ELSEIF msg == WM_DESTROY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR EACH oItem IN aControls
             IF __ObjHasMsg(oItem, "END")
                oItem:End()
             ENDIF
         NEXT
      #else
         FOR i := 1 TO nControls
             IF __ObjHasMsg(aControls[i], "END")
                aControls[i]:End()
             ENDIF
         NEXT
      #endif
      HWindow():DelItem(oWnd)
      hwg_PostQuitMessage(0)
      RETURN 0
   ELSEIF msg == WM_SYSCOMMAND
      IF wParam == SC_CLOSE
          IF HB_IsBlock(oWnd:bDestroy)
             i := Eval(oWnd:bDestroy, oWnd)
             i := IIf(HB_IsLogical(i), i, .T.)
             IF !i
                RETURN 0
             ENDIF
          ENDIF
          IF oWnd:oNotifyIcon != NIL
             hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
          ENDIF
          IF oWnd:hAccel != NIL
             hwg_DestroyAcceleratorTable(oWnd:hAccel)
          ENDIF
      ELSEIF wParam == SC_MINIMIZE
          IF oWnd:lTray
             oWnd:Hide()
             RETURN 0
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
          IF lParam == WM_LBUTTONDOWN
             IF HB_IsBlock(oWnd:bNotify)
                Eval(oWnd:bNotify)
             ENDIF
          ELSEIF lParam == WM_RBUTTONDOWN
             IF oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             ENDIF
          ENDIF
      ENDIF
   ELSEIF msg == WM_MENUSELECT
      IF NumAnd(hwg_HIWORD(wParam), MF_HILITE) != 0 // hwg_HIWORD(wParam) = FLAGS , function NUMAND of the LIBCT.LIB
         IF HB_IsArray(oWnd:menu)
            IF (aMenu := hwg_FindMenuItem(oWnd:menu, hwg_LOWORD(wParam), @iCont)) != NIL
               IF aMenu[1, iCont, 2][2] != NIL
                  hwg_WriteStatus(oWnd, 1, aMenu[1, iCont, 2][2]) // show message on StatusBar
               ELSE
                  hwg_WriteStatus(oWnd, 1, "") // clear message
               ENDIF
            ELSE
               hwg_WriteStatus(oWnd, 1, "") // clear message
            ENDIF
         ENDIF
      ENDIF
      RETURN 0
   ELSE
      IF msg == WM_MOUSEMOVE
          hwg_DlgMouseMove()
      ENDIF
      IF HB_IsBlock(oWnd:bOther)
          Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      ENDIF
   ENDIF

RETURN -1

FUNCTION DefChildWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem

   //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("DefChildWndProc -Inicio", 40) + "|")
   IF (oWnd := HWindow():FindWindow(hWnd)) == NIL
      IF msg == WM_CREATE
         IF Len(HWindow():aWindows) != 0 .AND. ;
               (oWnd := HWindow():aWindows[Len(HWindow():aWindows)]) != NIL .AND. ;
            oWnd:handle == 0
            oWnd:handle := hWnd
            IF oWnd:bInit != NIL
            Eval(oWnd:bInit, oWnd)
            ENDIF
         ENDIF
      ENDIF
      RETURN 0
   ENDIF
   IF msg == WM_COMMAND
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - COMMAND", 40) + "|")
      IF wParam == SC_CLOSE
          //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - Close", 40) + "|")
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
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
         (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
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
      RETURN 1
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != NIL
          //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - DefWndProc -Fim", 40) + "|")
          RETURN Eval(oWnd:bPaint, oWnd)
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3] - aControls[1]
      oWnd:nHeight := aControls[4] - aControls[2]
      IF oWnd:bSize != NIL
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd) + "--" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd) + "==" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3] - oWnd:aOffset[1] - oWnd:aOffset[3], aControls[4] - oWnd:aOffset[2] - oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle) + "::" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          RETURN 1
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM
      IF (oBtn := oWnd:FindControl(wParam)) != NIL
          IF oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, lParam)
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   ELSEIF msg == WM_ENTERIDLE
      IF wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
        .AND. oItem:handle == lParam .AND. !oItem:lActivated
          oItem:lActivated := .T.
          IF oItem:bActivate != NIL
             Eval(oItem:bActivate, oItem)
          ENDIF
      ENDIF
   ELSEIF msg == WM_DESTROY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
     #ifdef __XHARBOUR__
      FOR EACH oItem IN aControls
          IF __ObjHasMsg(oItem, "END")
             oItem:End()
          ENDIF
      NEXT
     #else
      FOR i := 1 TO nControls
          IF __ObjHasMsg(aControls[i], "END")
             aControls[i]:End()
          ENDIF
      NEXT
     #endif
      HWindow():DelItem(oWnd)

      // RETURN 0  // Default

      hwg_PostQuitMessage(0)
      RETURN 1

   ELSEIF msg == WM_SYSCOMMAND
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - SysCommand", 40) + "|")
      IF wParam == SC_CLOSE
          //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - SysCommand - Close", 40) + "|")
          IF oWnd:bDestroy != NIL
             IF !Eval(oWnd:bDestroy, oWnd)
                RETURN 1
             ENDIF
             IF oWnd:oNotifyIcon != NIL
                hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
             ENDIF
             IF oWnd:hAccel != NIL
                hwg_DestroyAcceleratorTable(oWnd:hAccel)
             ENDIF
          ENDIF
      ELSEIF wParam == SC_MINIMIZE
          IF oWnd:lTray
             oWnd:Hide()
             RETURN 1
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
          IF lParam == WM_LBUTTONDOWN
             IF oWnd:bNotify != NIL
                Eval(oWnd:bNotify)
             ENDIF
          ELSEIF lParam == WM_RBUTTONDOWN
             IF oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             ENDIF
          ENDIF
      ENDIF
   ELSE
      IF msg == WM_MOUSEMOVE
          hwg_DlgMouseMove()
      ENDIF
      IF oWnd:bOther != NIL
          Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      ENDIF
   ENDIF

   //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Child - DefChildWndProc -Fim", 40) + "|")

RETURN 0

FUNCTION DefMdiChildProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont
Local iParHigh, iParLow, oWnd, oBtn, oitem
Local nReturn
Local oWndBase   :=  HWindow():aWindows[1]
Local oWndClient :=  HWindow():aWindows[2]
Local hJanBase   :=  oWndBase:handle
Local hJanClient :=  oWndClient:handle
Local aMenu, hMenu, hSubMenu, nPosMenu

   // WriteLog("|DefMDIChild  " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
   IF msg == WM_NCCREATE
      // WriteLog("|DefMDIChild  " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10) + " WM_CREATE")
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF HB_IsObject(oWnd)

         oWnd:handle := hWnd
         hwg_InitControls(oWnd)
      ELSE

         hwg_MsgStop("DefMDIChild wrong hWnd : " + Str(hWnd, 10), "Create Error!")
         QUIT
         nReturn := 0
         RETURN (nReturn)
      ENDIF

   ENDIF

   IF (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("MDI child: wrong window handle " + Str(hWnd) + "| " + Str(msg), "Error!")
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE
      RETURN NIL
   ENDIF

   IF msg == WM_COMMAND
      IF wParam == SC_CLOSE
          IF Len(HWindow():aWindows) > 2 .AND. (nHandle := hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIGETACTIVE, 0, 0)) > 0
             hwg_SendMessage(HWindow():aWindows[2]:handle, WM_MDIDESTROY, nHandle, 0)
          ENDIF
      ENDIF
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
            (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
         Eval(oWnd:aEvents[iItem, 3])
      ENDIF
      nReturn := 1
      RETURN (nReturn)
   ELSEIF msg == WM_MOUSEMOVE
      oBtn := SetOwnBtnSelected()
      IF oBtn != NIL
          oBtn:state := OBTN_NORMAL
          InvalidateRect(oBtn:handle, 0)
          hwg_PostMessage(oBtn:handle, WM_PAINT, 0, 0)
          SetOwnBtnSelected(NIL)
      ENDIF
   ELSEIF msg == WM_PAINT

      IF HB_ISObject(oWnd) .AND. HB_IsBlock(oWnd:bPaint)

         // WriteLog("|DefMDIChild Paint" + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))

         nReturn := Eval(oWnd:bPaint, oWnd)
         // Writelog("Saida: " + Valtype(nReturn))
         // RETURN (nReturn)

      ENDIF

   ELSEIF msg == WM_SIZE
      IF HB_IsObject(oWnd)
         aControls := oWnd:aControls
         nControls := Len(aControls)
         #ifdef __XHARBOUR__
               FOR EACH oItem in aControls
                   IF oItem:bSize != NIL
                      Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
                   ENDIF
               NEXT
         #else
               FOR iCont := 1 TO nControls
                   IF aControls[iCont]:bSize != NIL
                      Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
                   ENDIF
               NEXT
         #endif
     ENDIF
   ELSEIF msg == WM_NCACTIVATE
      //WriteLog("|DefMDIChild" + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
      IF HB_IsObject(oWnd)
         IF wParam = 1 // Ativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd, 10))
            // Pega o menu atribuido
            aMenu := oWnd:menu
            //hMenu := aMenu[5]
            nPosMenu := 0
            //hSubMenu := GetSubMenu(hMenu, nPosMenu)

            // hwg_SendMessage(hJanClient, WM_MDISETMENU, hmenu, 0)
            hwg_DrawMenuBar(hJanBase)

            IF  oWnd:bGetFocus != NIL
               Eval(oWnd:bGetFocus, oWnd)
            ENDIF
         ELSE   // Desativando
            // WriteLog("WM_NCACTIVATE" + " -> " + "Desativando" + " Wnd: " + Str(hWnd, 10))
            IF  oWnd:bLostFocus != NIL
               Eval(oWnd:bLostFocus, oWnd)
            ENDIF
         ENDIF
      ENDIF

      nReturn := 0
      RETURN (nReturn)

   ELSEIF msg == WM_MDIACTIVATE

      IF wParam == 1
            // WriteLog("WM_MDIACTIVATE" + " -> " + "Ativando" + " Wnd: " + Str(hWnd, 10))
            // Pega o menu atribuido
            aMenu := oWnd:menu
            hMenu := aMenu[5]

            hwg_SendMessage(hJanBase, WM_MDISETMENU, hMenu, 0)
            hwg_DrawMenuBar(hJanBase)
      ENDIF

      nReturn := 0
      RETURN (nReturn)

   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
      /*
      IF (oBtn := oWnd:FindControl(, lParam)) != NIL
          IF oBtn:tcolor != NIL
             hwg_SetTextColor(wParam, oBtn:tcolor)
          ENDIF
          IF oBtn:bcolor != NIL
             hwg_SetBkColor(wParam, oBtn:bcolor)
             RETURN oBtn:brush:handle
          ENDIF
          nReturn := 0
          RETURN (nReturn)
      ENDIF
      */
   ELSEIF msg == WM_DRAWITEM
      IF (oBtn := oWnd:FindControl(wParam)) != NIL
          IF oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, wParam, lParam)
          ENDIF
      ENDIF

   ELSEIF msg == WM_NCDESTROY
      IF HB_IsObject(oWnd)
        HWindow():DelItem(oWnd)
      ELSE
        hwg_MsgStop("oWnd nao e objeto! em NC_DESTROY!", "DefMDIChildProc")
      ENDIF
   ELSEIF msg == WM_DESTROY
      IF HB_IsObject(oWnd)
         IF HB_IsBlock(oWnd:bDestroy)
             Eval(oWnd:bDestroy, oWnd)
         ENDIF
         aControls := oWnd:aControls
         nControls := Len(aControls)
         #ifdef __XHARBOUR__
            FOR each oItem in aControls
                IF __ObjHasMsg(oItem, "END")
                   oItem:End()
                ENDIF
            NEXT
         #else
            FOR i := 1 TO nControls
                IF __ObjHasMsg(aControls[i], "END")
                   aControls[i]:End()
                ENDIF
            NEXT
         #endif
         // HWindow():DelItem(oWnd)  -> alterado por jamaj
         // Temos que eliminar em NC_DESTROY
      ENDIF
      nReturn := 1
      RETURN (nReturn)
   ELSEIF msg == WM_CREATE
      IF HB_IsBlock(oWnd:bInit)
         Eval(oWnd:bInit, oWnd)
      ENDIF
   ELSE
      IF HB_IsObject(oWnd) .AND. HB_IsBlock(oWnd:bOther)
         Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
      ENDIF
   ENDIF
   nReturn := NIL
RETURN (nReturn)

FUNCTION hwg_ReleaseAllWindows(oWnd, hWnd)
Local oItem, iCont, nCont

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
 
   FOR iCont := 1 TO nCont

      IF HWindow():aWindows[iCont]:oParent != NIL .AND. ;
              HWindow():aWindows[iCont]:oParent:handle == hWnd
          hwg_SendMessage(HWindow():aWindows[iCont]:handle, WM_CLOSE, 0, 0)
      ENDIF

   NEXT
   #endif
   
   IF HWindow():GetMain() == oWnd
      hwg_ExitProcess(0)
   ENDIF

RETURN NIL

// Processamento da janela frame (base) MDI

FUNCTION DefMDIWndProc(hWnd, msg, wParam, lParam)
Local i, iItem, nHandle, aControls, nControls, iCont, hWndC, aMenu
Local iParHigh, iParLow
Local oWnd, oBtn, oitem
Local xRet, nReturn
Local oWndClient

   // WriteLog("|DefMDIWndProc" + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
   IF msg == WM_NCCREATE
      // WriteLog("|DefMDIWndProc" + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10) + " WM_CREATE")
      // Procura objecto window com handle = 0
      oWnd := HWindow():FindWindow(0)

      IF HB_IsObject(oWnd)
         oWnd:handle := hWnd
      ELSE

         hwg_MsgStop("DefMDIWndProc wrong hWnd : " + Str(hWnd, 10), "Create Error!")
         QUIT
         nReturn := 0
         RETURN (nReturn)

      ENDIF

   ENDIF


   IF (oWnd := HWindow():FindWindow(hWnd)) == NIL
      // hwg_MsgStop("MDI wnd: wrong window handle " + Str(hWnd) + "| " + Str(msg), "Error!")
      // Deve entrar aqui apenas em WM_GETMINMAXINFO, que vem antes de WM_NCCREATE
      RETURN NIL
   ENDIF

   IF msg == WM_CREATE
        IF HB_IsBlock(oWnd:bInit)
            Eval(oWnd:bInit, oWnd)
        ENDIF
   ELSEIF msg == WM_COMMAND
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - COMMAND", 40) + "|")
      IF wParam == SC_CLOSE
          //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - Close", 40) + "|")
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
      iParHigh := hwg_HIWORD(wParam)
      iParLow := hwg_LOWORD(wParam)
      IF oWnd:aEvents != NIL .AND. ;
         (iItem := Ascan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
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
      RETURN 1
   ELSEIF msg == WM_PAINT
      IF oWnd:bPaint != NIL
         //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("DefWndProc -Inicio", 40) + "|")
         RETURN Eval(oWnd:bPaint, oWnd)
      ENDIF
   ELSEIF msg == WM_MOVE
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nLeft := aControls[1]
      oWnd:nTop  := aControls[2]
   ELSEIF msg == WM_SIZE
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR each oItem in aControls
             IF oItem:bSize != NIL
                Eval(oItem:bSize, oItem, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #else
         FOR iCont := 1 TO nControls
             IF aControls[iCont]:bSize != NIL
                Eval(aControls[iCont]:bSize, aControls[iCont], hwg_LOWORD(lParam), hwg_HIWORD(lParam))
             ENDIF
         NEXT
      #endif
      aControls := hwg_GetWindowRect(hWnd)
      oWnd:nWidth  := aControls[3] - aControls[1]
      oWnd:nHeight := aControls[4] - aControls[2]
      IF oWnd:bSize != NIL
          Eval(oWnd:bSize, oWnd, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      ENDIF
      IF oWnd:type == WND_MDI .AND. Len(HWindow():aWindows) > 1
          // writelog(str(hWnd) + "--" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          aControls := hwg_GetClientRect(hWnd)
          // writelog(str(hWnd) + "==" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          hwg_MoveWindow(HWindow():aWindows[2]:handle, oWnd:aOffset[1], oWnd:aOffset[2], aControls[3] - oWnd:aOffset[1] - oWnd:aOffset[3], aControls[4] - oWnd:aOffset[2] - oWnd:aOffset[4])
          // aControls := hwg_GetClientRect(HWindow():aWindows[2]:handle)
          // writelog(str(HWindow():aWindows[2]:handle) + "::" + str(aControls[1]) + str(aControls[2]) + str(aControls[3]) + str(aControls[4]))
          RETURN 1
      ENDIF
   ELSEIF msg == WM_CTLCOLORSTATIC .OR. msg == WM_CTLCOLOREDIT .OR. msg == WM_CTLCOLORBTN
      RETURN DlgCtlColor(oWnd, wParam, lParam)
   ELSEIF msg == WM_ERASEBKGND
      IF oWnd:oBmp != NIL
          hwg_SpreadBitmap(wParam, oWnd:handle, oWnd:oBmp:handle)
          RETURN 1
      ENDIF
   ELSEIF msg == WM_DRAWITEM

      IF (oBtn := oWnd:FindControl(wParam)) != NIL
          IF oBtn:bPaint != NIL
             Eval(oBtn:bPaint, oBtn, lParam)
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - Notify", 40) + "|")
      RETURN DlgNotify(oWnd, wParam, lParam)
   ELSEIF msg == WM_ENTERIDLE
      IF wParam == 0 .AND. (oItem := Atail(HDialog():aModalDialogs)) != NIL ;
	    .AND. oItem:handle == lParam .AND. !oItem:lActivated
       oItem:lActivated := .T.
       IF oItem:bActivate != NIL
          Eval(oItem:bActivate, oItem)
       ENDIF
      ENDIF

   ELSEIF msg == WM_CLOSE
      hwg_ReleaseAllWindows(oWnd, hWnd)

   ELSEIF msg == WM_DESTROY
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - DESTROY", 40) + "|")
      aControls := oWnd:aControls
      nControls := Len(aControls)
      #ifdef __XHARBOUR__
         FOR EACH oItem IN aControls
             IF __ObjHasMsg(oItem, "END")
                oItem:End()
             ENDIF
         NEXT
      #else
         FOR i := 1 TO nControls
             IF __ObjHasMsg(aControls[i], "END")
                aControls[i]:End()
             ENDIF
         NEXT
      #endif
      // HWindow():DelItem(oWnd)

      IF HB_IsBlock(oWnd:bDestroy)
          Eval(oWnd:bDestroy, oWnd)
      ENDIF

      hwg_PostQuitMessage(0)

      // RETURN 0
      RETURN 1

   ELSEIF msg == WM_NCDESTROY
      IF HB_IsObject(oWnd)
        HWindow():DelItem(oWnd)
      ELSE
        hwg_MsgStop("oWnd nao e objeto! em NC_DESTROY!", "DefMDIWndProc")
      ENDIF

   ELSEIF msg == WM_SYSCOMMAND
      //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - SysCommand", 40) + "|")
      IF wParam == SC_CLOSE
          //WriteLog("|Window: " + Str(hWnd, 10) + "|" + Str(msg, 6) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10)  + "|" + PadR("Main - SysCommand - Close", 40) + "|")
          IF oWnd:bDestroy != NIL
             xRet := Eval(oWnd:bDestroy, oWnd)
             xRet := IIf(HB_IsLogical(xRet), xRet, .T.)
             IF !xRet
                RETURN 1
             ENDIF
          ENDIF

          IF oWnd:oNotifyIcon != NIL
             hwg_ShellNotifyIcon(.F., oWnd:handle, oWnd:oNotifyIcon:handle)
          ENDIF
          IF oWnd:hAccel != NIL
             hwg_DestroyAcceleratorTable(oWnd:hAccel)
          ENDIF
          RETURN 0
      ELSEIF wParam == SC_MINIMIZE
          IF oWnd:lTray
             oWnd:Hide()
             RETURN 1
          ENDIF
      ENDIF
   ELSEIF msg == WM_NOTIFYICON
      IF wParam == ID_NOTIFYICON
          IF lParam == WM_LBUTTONDOWN
             IF oWnd:bNotify != NIL
                Eval(oWnd:bNotify)
             ENDIF
          ELSEIF lParam == WM_RBUTTONDOWN
             IF oWnd:oNotifyMenu != NIL
                i := hwg_GetCursorPos()
                oWnd:oNotifyMenu:Show(oWnd, i[1], i[2])
             ENDIF
          ENDIF
      ENDIF
   ELSE
      IF HB_IsObject(oWnd)
         IF msg == WM_MOUSEMOVE
             hwg_DlgMouseMove()
         ENDIF
         IF HB_IsBlock(oWnd:bOther)
             Eval(oWnd:bOther, oWnd, msg, wParam, lParam)
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

FUNCTION GetChildWindowsNumber
RETURN Len(HWindow():aWindows) - 2
