//
// $Id: hcwindow.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HCustomWindow class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

STATIC s_aCustomEvents := { ;
      {WM_NOTIFY, WM_PAINT, WM_CTLCOLORSTATIC, WM_CTLCOLOREDIT, WM_CTLCOLORBTN, ;
        WM_COMMAND, WM_DRAWITEM, WM_SIZE, WM_DESTROY}, ;
      { ;
        {|o, w, l|onNotify(o, w, l)}, ;
        {|o, w|IIf(o:bPaint != NIL, Eval(o:bPaint, o, w), -1)}, ;
        {|o, w, l|onCtlColor(o, w, l)}, ;
        {|o, w, l|onCtlColor(o, w, l)}, ;
        {|o, w, l|onCtlColor(o, w, l)}, ;
        {|o, w, l|HB_SYMBOL_UNUSED(l), onCommand(o, w)}, ;
        {|o, w, l|onDrawItem(o, w, l)}, ;
        {|o, w, l|onSize(o, w, l)}, ;
        {|o|onDestroy(o)} ;
      } ;
                        }

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
   DATA HelpId   INIT 0
   DATA nCurWidth    INIT 0
   DATA nCurHeight   INIT 0
   DATA nScrollPos   INIT 0
   DATA rect
   DATA nScrollBars INIT -1
   DATA minWidth   INIT - 1
   DATA maxWidth   INIT - 1
   DATA minHeight  INIT - 1
   DATA maxHeight  INIT - 1

   
   
   METHOD AddControl(oCtrl) INLINE AAdd(::aControls, oCtrl)
   METHOD DelControl(oCtrl)
   METHOD AddEvent(nEvent, nId, bAction, lNotify) ;
      INLINE AAdd(IIf(lNotify == NIL .OR. !lNotify, ::aEvents, ::aNotify), {nEvent, nId, bAction})
   METHOD FindControl(nId, nHandle)
   METHOD Hide() INLINE (::lHide := .T., hwg_HideWindow(::handle))
   METHOD Show() INLINE (::lHide := .F., hwg_ShowWindow(::handle))
   METHOD Move(x1, y1, width, height)
   METHOD onEvent(msg, wParam, lParam)
   METHOD End()
   METHOD Anchor(oCtrl, x, y, w, h)

ENDCLASS

METHOD HCustomWindow:FindControl(nId, nHandle)
Local i := IIf(nId != NIL, AScan(::aControls, {|o|o:id == nId}), ;
                           AScan(::aControls, {|o|o:handle == nHandle}))
RETURN IIf(i == 0, NIL, ::aControls[i])

METHOD HCustomWindow:DelControl(oCtrl)
Local id := oCtrl:id, h
Local i := AScan(::aControls, {|o|o == oCtrl})

   IF oCtrl:ClassName() == "HPANEL"
      hwg_DestroyPanel(oCtrl:handle)
   ELSE
      hwg_DestroyWindow(oCtrl:handle)
   ENDIF
   IF i != 0
      ADel(::aControls, i)
      ASize(::aControls, Len(::aControls) - 1)
   ENDIF
   h := 0
   FOR i := Len(::aEvents) TO 1 STEP -1
      IF ::aEvents[i, 2] == id
         ADel(::aEvents, i)
         h ++
      ENDIF
   NEXT
   IF h > 0
      ASize(::aEvents, Len(::aEvents) - h)
   ENDIF
   h := 0
   FOR i := Len(::aNotify) TO 1 STEP -1
      IF ::aNotify[i, 2] == id
         ADel(::aNotify, i)
         h ++
      ENDIF
   NEXT
   IF h > 0
      ASize(::aNotify, Len(::aNotify) - h)
   ENDIF
RETURN NIL

METHOD HCustomWindow:Move(x1, y1, width, height)

   IF x1 != NIL
      ::nLeft := x1
   ENDIF
   IF y1 != NIL
      ::nTop  := y1
   ENDIF
   IF width != NIL
      ::nWidth := width
   ENDIF
   IF height != NIL
      ::nHeight := height
   ENDIF
   hwg_MoveWindow(::handle, ::nLeft, ::nTop, ::nWidth, ::nHeight)

RETURN NIL

METHOD HCustomWindow:onEvent(msg, wParam, lParam)
Local i

   // Writelog("== " + ::Classname() + Str(msg) + IIf(wParam != NIL, Str(wParam), "NIL") + IIf(lParam != NIL, Str(lParam), "NIL"))
   IF (i := AScan(s_aCustomEvents[1], msg)) != 0
      RETURN Eval(s_aCustomEvents[2, i], Self, wParam, lParam)
   ELSEIF ::bOther != NIL
      RETURN Eval(::bOther, Self, msg, wParam, lParam)
   ENDIF

RETURN 0

METHOD HCustomWindow:Anchor(oCtrl, x, y, w, h)

   LOCAL nlen
   LOCAL i
   LOCAL x1
   LOCAL y1

   nlen := Len(oCtrl:aControls)
   FOR i = 1 TO nlen
      IF __ObjHasMsg(oCtrl:aControls[i], "ANCHOR") .AND. oCtrl:aControls[i]:anchor > 0
         x1 := oCtrl:aControls[i]:nWidth // assigned but not used
         y1 := oCtrl:aControls[i]:nHeight // assigned but not used
         HB_SYMBOL_UNUSED(x1)
         HB_SYMBOL_UNUSED(y1)
         oCtrl:aControls[i]:onAnchor(x, y, w, h)
         IF Len(oCtrl:aControls[i]:aControls) > 0
            //::Anchor(oCtrl:aControls[i], x1, y1, oCtrl:nWidth, oCtrl:nHeight)
            ::Anchor(oCtrl:aControls[i], x, y, oCtrl:nWidth, oCtrl:nHeight)
         ENDIF
      ENDIF
   NEXT
   RETURN .T.


METHOD HCustomWindow:End()
Local aControls := ::aControls
Local i, nLen := Len(aControls)

   FOR i := 1 TO nLen
       aControls[i]:End()
   NEXT

   hwg_ReleaseObject(::handle)

RETURN NIL

STATIC FUNCTION onNotify(oWnd, wParam, lParam)

   LOCAL iItem
   LOCAL oCtrl := oWnd:FindControl(wParam)
   LOCAL nCode
   LOCAL res
   //LOCAL handle // variable not used
   //LOCAL oItem // variable not used

   IF oCtrl != NIL
      IF oCtrl:ClassName() == "HTAB"
         DO CASE
         CASE (nCode := hwg_GetNotifyCode(lParam)) == TCN_SELCHANGE
            IF oCtrl != NIL .AND. oCtrl:bChange != NIL
               Eval(oCtrl:bChange, oCtrl, hwg_GetCurrentTab(oCtrl:handle))
            ENDIF
         CASE (nCode := hwg_GetNotifyCode(lParam)) == TCN_CLICK
              IF oCtrl != NIL .AND. oCtrl:bAction != NIL
                 Eval(oCtrl:bAction, oCtrl, hwg_GetCurrentTab(oCtrl:handle))
              ENDIF
         CASE (nCode := hwg_GetNotifyCode(lParam)) == TCN_SETFOCUS
              IF oCtrl != NIL .AND. oCtrl:bGetFocus != NIL
                 Eval(oCtrl:bGetFocus, oCtrl, hwg_GetCurrentTab(oCtrl:handle))
              ENDIF
         CASE (nCode := hwg_GetNotifyCode(lParam)) == TCN_KILLFOCUS
              IF oCtrl != NIL .AND. oCtrl:bLostFocus != NIL
                 Eval(oCtrl:bLostFocus, oCtrl, hwg_GetCurrentTab(oCtrl:handle))
              ENDIF
        ENDCASE
      ELSEIF oCtrl:ClassName() == "HQHTM"
         RETURN oCtrl:Notify(oWnd, lParam)
      ELSEIF oCtrl:ClassName() == "HTREE"
         RETURN hwg_TreeNotify(oCtrl, lParam)
      ELSEIF oCtrl:ClassName() == "HGRID"         
         RETURN hwg_ListViewNotify(oCtrl, lParam)
      ELSE
         nCode := hwg_GetNotifyCode(lParam)
         // writelog("Code: " + str(nCode))
         IF nCode == EN_PROTECTED
            RETURN 1
         ELSEIF oWnd:aNotify != NIL .AND. ;
            (iItem := AScan(oWnd:aNotify, {|a|a[1] == nCode .AND. a[2] == wParam})) > 0
            IF (res := Eval(oWnd:aNotify[iItem, 3], oWnd, wParam)) != NIL
               RETURN res
            ENDIF
         ENDIF
      ENDIF
   ENDIF

RETURN 0

STATIC FUNCTION onDestroy(oWnd)
   oWnd:End()

RETURN 0

STATIC FUNCTION onCtlColor(oWnd, wParam, lParam)
Local oCtrl  := oWnd:FindControl(, lParam)

   IF oCtrl != NIL
      IF oCtrl:tcolor != NIL
         hwg_SetTextColor(wParam, oCtrl:tcolor)
      ENDIF
      IF oCtrl:bcolor != NIL
         hwg_SetBkColor(wParam, oCtrl:bcolor)
         RETURN oCtrl:brush:handle
      ENDIF
   ENDIF

RETURN -1

STATIC FUNCTION onDrawItem(oWnd, wParam, lParam)
Local oCtrl

   IF wParam != 0 .AND. (oCtrl := oWnd:FindControl(wParam)) != NIL .AND. ;
         oCtrl:bPaint != NIL
      Eval(oCtrl:bPaint, oCtrl, lParam)
      RETURN 1
   ENDIF

RETURN 0

STATIC FUNCTION onCommand(oWnd, wParam)
Local iItem, iParHigh := hwg_HIWORD(wParam), iParLow := hwg_LOWORD(wParam)

   IF oWnd:aEvents != NIL .AND. ;
      (iItem := AScan(oWnd:aEvents, {|a|a[1] == iParHigh .AND. a[2] == iParLow})) > 0
      Eval(oWnd:aEvents[iItem, 3], oWnd, iParLow)
   ENDIF

RETURN 1

STATIC FUNCTION onSize(oWnd, wParam, lParam)

   LOCAL aControls := oWnd:aControls
   LOCAL nControls := Len(aControls)
   //LOCAL oItem // variable not used
   LOCAL iCont

   HB_SYMBOL_UNUSED(wParam)

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

RETURN 0

#if 0 // old code for reference (to be deleted)
FUNCTION hwg_onTrackScroll(oWnd, wParam, lParam)
Local oCtrl := oWnd:FindControl(, lParam), msg

   IF oCtrl != NIL
      msg := hwg_LOWORD(wParam)
      IF msg == TB_ENDTRACK
         IF HB_IsBlock(oCtrl:bChange)
            Eval(oCtrl:bChange, oCtrl)
            RETURN 0
         ENDIF
      ELSEIF msg == TB_THUMBTRACK .OR. msg == TB_PAGEUP .OR. msg == TB_PAGEDOWN
         IF HB_IsBlock(oCtrl:bThumbDrag)
            Eval(oCtrl:bThumbDrag, oCtrl)
            RETURN 0
         ENDIF
      ENDIF
   ENDIF

RETURN 0
#else
FUNCTION hwg_onTrackScroll(oWnd, wParam, lParam)
Local oCtrl := oWnd:FindControl(, lParam), msg

   IF oCtrl != NIL
      msg := hwg_LOWORD(wParam)
      SWITCH msg
      CASE TB_ENDTRACK
         IF HB_IsBlock(oCtrl:bChange)
            Eval(oCtrl:bChange, oCtrl)
            RETURN 0
         ENDIF
         EXIT
      CASE TB_THUMBTRACK
      CASE TB_PAGEUP
      CASE TB_PAGEDOWN
         IF HB_IsBlock(oCtrl:bThumbDrag)
            Eval(oCtrl:bThumbDrag, oCtrl)
            RETURN 0
         ENDIF
      ENDSWITCH
   ENDIF

RETURN 0
#endif

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(ONTRACKSCROLL, HWG_ONTRACKSCROLL);
#endif

#pragma ENDDUMP
