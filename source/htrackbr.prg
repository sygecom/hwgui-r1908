//
// $Id: htrackbr.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HTrackBar class
//
// Copyright 2004 Marcos Antonio Gambeta <marcosgambeta AT outlook DOT com>
// www - http://github.com/marcosgambeta/
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HTrackBar INHERIT HControl

   CLASS VAR winclass INIT "msctls_trackbar32"

   DATA value
   DATA bChange
   DATA bThumbDrag
   DATA nLow
   DATA nHigh
   DATA hCursor

   METHOD New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, bPaint, ;
              cTooltip, bChange, bDrag, nLow, nHigh, lVertical, TickStyle, TickMarks)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD SetValue(nValue)
   METHOD GetValue()
   METHOD GetNumTics() INLINE hwg_SendMessage(::handle, TBM_GETNUMTICS, 0, 0)

ENDCLASS

METHOD HTrackBar:New(oWndParent, nId, vari, nStyle, nLeft, nTop, nWidth, nHeight, bInit, bSize, bPaint, ;
           cTooltip, bChange, bDrag, nLow, nHigh, lVertical, TickStyle, TickMarks)

   IF TickStyle == NIL
      TickStyle := TBS_AUTOTICKS
   ENDIF
   IF TickMarks == NIL
      TickMarks := 0
   ENDIF
   IF bPaint != NIL
      TickStyle := hwg_BitOr(TickStyle, TBS_AUTOTICKS)
   ENDIF
   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_TABSTOP)
   nStyle += IIf(lVertical != NIL .AND. lVertical, TBS_VERT, 0)
   nStyle += TickStyle + TickMarks

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, , bInit, bSize, bPaint, cTooltip)

   ::value := IIf(hb_IsNumeric(vari), vari, 0)
   ::bChange := bChange
   ::bThumbDrag := bDrag
   ::nLow := IIf(nLow == NIL, 0, nLow)
   ::nHigh := IIf(nHigh == NIL, 100, nHigh)

   HWG_InitCommonControlsEx()
   ::Activate()

RETURN Self

METHOD HTrackBar:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_InitTrackBar(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
                               ::nLow, ::nHigh)
      ::Init()
   ENDIF

RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD HTrackBar:onEvent(msg, wParam, lParam)

   LOCAL aCoors

   IF msg == WM_PAINT
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
         RETURN 0
      ENDIF

   ELSEIF msg == WM_MOUSEMOVE
      IF ::hCursor != NIL
         hwg_SetCursor(::hCursor)
      ENDIF

   ELSEIF msg == WM_ERASEBKGND
      IF ::brush != NIL
         aCoors := hwg_GetClientRect(::handle)
         hwg_FillRect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
         RETURN 1
      ENDIF

   ELSEIF msg == WM_DESTROY
      ::END()

   ELSEIF msg == WM_CHAR
      IF wParam == VK_TAB
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ENDIF

   ELSEIF msg == WM_KEYDOWN
      IF hwg_ProcKeyList(Self, wParam)
         RETURN 0
      ENDIF

   ELSEIF hb_IsBlock(::bOther)
      RETURN Eval(::bOther, Self, msg, wParam, lParam)

   ENDIF

RETURN -1
#else
METHOD HTrackBar:onEvent(msg, wParam, lParam)

   LOCAL aCoors

   SWITCH msg

   CASE WM_PAINT
      IF hb_IsBlock(::bPaint)
         Eval(::bPaint, Self)
         RETURN 0
      ENDIF
      EXIT

   CASE WM_MOUSEMOVE
      IF ::hCursor != NIL
         hwg_SetCursor(::hCursor)
      ENDIF
      EXIT

   CASE WM_ERASEBKGND
      IF ::brush != NIL
         aCoors := hwg_GetClientRect(::handle)
         hwg_FillRect(wParam, aCoors[1], aCoors[2], aCoors[3] + 1, aCoors[4] + 1, ::brush:handle)
         RETURN 1
      ENDIF
      EXIT

   CASE WM_DESTROY
      ::END()
      EXIT

   CASE WM_CHAR
      IF wParam == VK_TAB
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ENDIF
      EXIT

   CASE WM_KEYDOWN
      IF hwg_ProcKeyList(Self, wParam)
         RETURN 0
      ENDIF
      EXIT

#ifdef __XHARBOUR__
   DEFAULT
#else
   OTHERWISE
#endif
      IF hb_IsBlock(::bOther)
         RETURN Eval(::bOther, Self, msg, wParam, lParam)
      ENDIF

   ENDSWITCH

   RETURN -1
#endif

METHOD HTrackBar:Init()

   IF !::lInit
      ::Super:Init()
      hwg_TrackBarSetRange(::handle, ::nLow, ::nHigh)
      hwg_SendMessage(::handle, TBM_SETPOS, 1, ::value)
      IF ::bPaint != NIL
         ::nHolder := 1
         hwg_SetWindowObject(::handle, Self)
         hwg_InitTrackProc(::handle)
      ENDIF
   ENDIF

RETURN NIL

METHOD HTrackBar:SetValue(nValue)

   IF hb_IsNumeric(nValue)
      hwg_SendMessage(::handle, TBM_SETPOS, 1, nValue)
      ::value := nValue
   ENDIF

RETURN NIL

METHOD HTrackBar:GetValue()

   ::value := hwg_SendMessage(::handle, TBM_GETPOS, 0, 0)

RETURN ::value

#pragma BEGINDUMP

#include "hwingui.h"
#include <commctrl.h>

HB_FUNC(HWG_INITTRACKBAR)
{
  hwg_ret_HWND(CreateWindowEx(0, TRACKBAR_CLASS, 0, hwg_par_DWORD(3), hwg_par_int(4), hwg_par_int(5), hwg_par_int(6),
                              hwg_par_int(7), hwg_par_HWND(1), hwg_par_HMENU_ID(2), GetModuleHandle(NULL), NULL));
}

HB_FUNC(HWG_TRACKBARSETRANGE)
{
  SendMessage(hwg_par_HWND(1), TBM_SETRANGE, TRUE, MAKELONG(hb_parni(2), hb_parni(3)));
}

#pragma ENDDUMP
