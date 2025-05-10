//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HPanel class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HPanel INHERIT HControl

   DATA winclass   INIT "PANEL"

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  bInit, bSize, bPaint, lDocked)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD Paint()
   METHOD Move(x1, y1, width, height)

ENDCLASS


METHOD HPanel:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  bInit, bSize, bPaint, lDocked)

   LOCAL oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   
   HB_SYMBOL_UNUSED(lDocked)

   nStyle := SS_OWNERDRAW
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, IIf(nWidth == NIL, 0, nWidth), ;
                  nHeight, oParent:oFont, bInit, ;
                  bSize, bPaint)

   ::bPaint  := bPaint

   ::Activate()

RETURN Self

METHOD HPanel:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreatePanel(::oParent:handle, ::id, ;
                   ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL

METHOD HPanel:onEvent(msg, wParam, lParam)

   IF msg == WM_PAINT
      ::Paint()
   ELSE
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN 0

METHOD HPanel:Init()

   IF !::lInit
      IF ::bSize == NIL
         IF ::nHeight!=0 .AND. (::nWidth>::nHeight .OR. ::nWidth == 0)
            ::bSize := {|o, x, y|o:Move(, IIf(::nTop > 0, y - ::nHeight, 0), x, ::nHeight)}
         ELSEIF ::nWidth!=0 .AND. (::nHeight>::nWidth .OR. ::nHeight == 0)
            ::bSize := {|o, x, y|o:Move(IIf(::nLeft > 0, x - ::nLeft, 0), , ::nWidth, y)}
         ENDIF
      ENDIF

      ::Super:Init()
      hwg_SetWindowObject(::handle, Self)
   ENDIF

RETURN NIL

METHOD HPanel:Paint()

   LOCAL hDC
   //LOCAL aCoors // variable not used
   //LOCAL oPenLight // variable not used
   //LOCAL oPenGray // variable not used

   IF ::bPaint != NIL
      Eval(::bPaint, Self)
   ELSE
      hDC := hwg_GetDC(::handle)
      hwg_DrawButton(hDC, 0, 0, ::nWidth - 1, ::nHeight - 1, 5)
      hwg_releaseDC(::handle, hDC)
   ENDIF

RETURN NIL

METHOD HPanel:Move(x1, y1, width, height)

   ::Super:Move(x1, y1, width, height, .T.)
RETURN NIL

