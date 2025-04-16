//
// $Id: hpanel.prg 1615 2011-02-18 13:53:35Z mlacecilia $
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


METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  bInit, bSize, bPaint, lDocked) CLASS HPanel

   LOCAL oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   
   HB_SYMBOL_UNUSED(lDocked)

   nStyle := SS_OWNERDRAW
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, IIf(nWidth == NIL, 0, nWidth), ;
                  nHeight, oParent:oFont, bInit, ;
                  bSize, bPaint)

   ::bPaint  := bPaint

   ::Activate()

RETURN Self

METHOD Activate() CLASS HPanel

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreatePanel(::oParent:handle, ::id, ;
                   ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HPanel

   IF msg == WM_PAINT
      ::Paint()
   ELSE
      RETURN ::Super:onEvent(msg, wParam, lParam)
   ENDIF

RETURN 0

METHOD Init() CLASS HPanel

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

METHOD Paint() CLASS HPanel

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

METHOD Move(x1, y1, width, height) CLASS HPanel

   ::Super:Move(x1, y1, width, height, .T.)
RETURN NIL

