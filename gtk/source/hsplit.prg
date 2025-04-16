//
// $Id: hsplit.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HSplitter class
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"
#include "gtk.ch"

CLASS HSplitter INHERIT HControl

   CLASS VAR winclass INIT "STATIC"

   DATA aLeft
   DATA aRight
   DATA lVertical
   DATA hCursor
   DATA lCaptured INIT .F.
   DATA lMoved INIT .F.
   DATA bEndDrag

   //METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, ;
   //               bSize, bPaint, color, bcolor, aLeft, aRight)
   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, ;
                  bSize, bDraw, color, bcolor, aLeft, aRight)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint(lpdis)
   METHOD Move(x1, y1, width, height)
   METHOD Drag(lParam)
   METHOD DragAll()

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, ;
                  bSize, bDraw, color, bcolor, aLeft, aRight) CLASS HSplitter

   ::Super:New(oWndParent, nId, WS_CHILD + WS_VISIBLE + SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight,,, ;
                  bSize, bDraw,, color, bcolor)

   ::title   := ""
   ::aLeft   := IIf(aLeft == NIL, {}, aLeft)
   ::aRight  := IIf(aRight == NIL, {}, aRight)
   ::lVertical := (::nHeight > ::nWidth)

   ::Activate()

RETURN Self

METHOD Activate() CLASS HSplitter
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateSplitter(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HSplitter

   HB_SYMBOL_UNUSED(wParam)

   IF msg == WM_MOUSEMOVE
      IF ::hCursor == NIL
         ::hCursor := hwg_LoadCursor(GDK_HAND1)
      ENDIF
      hwg_SetCursor(::hCursor, ::handle)
      IF ::lCaptured
         ::Drag(lParam)
      ENDIF
   ELSEIF msg == WM_PAINT
      ::Paint()
   ELSEIF msg == WM_LBUTTONDOWN
      hwg_SetCursor(::hCursor, ::handle)
      ::lCaptured := .T.
   ELSEIF msg == WM_LBUTTONUP
      ::DragAll()
      ::lCaptured := .F.
      IF ::bEndDrag != NIL
         Eval(::bEndDrag, Self)
      ENDIF
   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF

RETURN -1

METHOD Init() CLASS HSplitter

   IF !::lInit
      ::Super:Init()
      hwg_SetWindowObject(::handle, Self)
   ENDIF

RETURN NIL

METHOD Paint(lpdis) CLASS HSplitter
   
   LOCAL hDC
   
   HB_SYMBOL_UNUSED(lpdis)

   IF ::bPaint != NIL
      Eval(::bPaint, Self)
   ELSE
      hDC := hwg_GetDC(::handle)
      hwg_DrawButton(hDC, 0, 0, ::nWidth - 1, ::nHeight - 1, 6)
      hwg_releaseDC(::handle, hDC)
   ENDIF

RETURN NIL

METHOD Move(x1, y1, width, height) CLASS HSplitter

   ::Super:Move(x1, y1, width, height, .T.)
RETURN NIL

METHOD Drag(lParam) CLASS HSplitter
Local xPos := hwg_LOWORD(lParam), yPos := hwg_HIWORD(lParam)

   IF ::lVertical
      IF xPos > 32000
         xPos -= 65535
      ENDIF
      ::Move(::nLeft + xPos)
   ELSE
      IF yPos > 32000
         yPos -= 65535
      ENDIF
      ::Move(, ::nTop + yPos)
   ENDIF
   ::lMoved := .T.

RETURN NIL

METHOD DragAll() CLASS HSplitter
Local i, oCtrl, nDiff

   FOR i := 1 TO Len(::aRight)
      oCtrl := ::aRight[i]
      IF ::lVertical
         nDiff := ::nLeft + ::nWidth - oCtrl:nLeft
         oCtrl:Move(oCtrl:nLeft + nDiff, , oCtrl:nWidth - nDiff)
      ELSE
         nDiff := ::nTop + ::nHeight - oCtrl:nTop
         oCtrl:Move(, oCtrl:nTop + nDiff, , oCtrl:nHeight - nDiff)
      ENDIF   
   NEXT
   FOR i := 1 TO Len(::aLeft)
      oCtrl := ::aLeft[i]
      IF ::lVertical
         nDiff := ::nLeft - (oCtrl:nLeft + oCtrl:nWidth)
         oCtrl:Move(, , oCtrl:nWidth + nDiff)
      ELSE
         nDiff := ::nTop - (oCtrl:nTop + oCtrl:nHeight)
         oCtrl:Move(, , , oCtrl:nHeight + nDiff)
      ENDIF
   NEXT
   ::lMoved := .F.

RETURN NIL
