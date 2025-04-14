//
// $Id: hradio.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HRadioButton class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HRadioGroup INHERIT HObject
   CLASS VAR oGroupCurrent
   DATA handle INIT 0
   DATA aButtons
   DATA value  INIT 1
   DATA bSetGet

   METHOD New(vari, bSetGet)
   METHOD EndGroup(nSelected)
   METHOD SetValue(nValue)
   METHOD Refresh() INLINE IIf(::bSetGet != NIL, ::SetValue(Eval(::bSetGet)), .T.)
ENDCLASS

METHOD New(vari, bSetGet) CLASS HRadioGroup
   ::oGroupCurrent := Self
   ::aButtons := {}

   IF vari != NIL
      IF HB_IsNumeric(vari)
         ::value := vari
      ENDIF
      ::bSetGet := bSetGet
   ENDIF

RETURN Self

METHOD EndGroup(nSelected)  CLASS HRadioGroup
Local nLen

   IF ::oGroupCurrent != NIL .AND. (nLen := Len(::oGroupCurrent:aButtons)) > 0

      nSelected := IIf(nSelected != NIL .AND. nSelected <= nLen .AND. nSelected > 0, ;
                       nSelected, ::oGroupCurrent:value)
      IF nSelected != 0 .AND. nSelected <= nlen
         hwg_CheckButton(::oGroupCurrent:aButtons[nSelected]:handle, .T.)
      ENDIF
   ENDIF
   ::oGroupCurrent := NIL
RETURN NIL

METHOD SetValue(nValue)  CLASS HRadioGroup
Local nLen

   IF (nLen := Len(::aButtons)) > 0 .AND. nValue > 0 .AND. nValue <= nLen
      hwg_CheckButton(::aButtons[nValue]:handle, .T.)
   ENDIF
RETURN NIL


CLASS HRadioButton INHERIT HControl

   CLASS VAR winclass   INIT "BUTTON"
   DATA  oGroup

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor) CLASS HRadioButton

   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := IIf(nId == NIL, ::NewId(), nId)
   ::title   := cCaption
   ::oGroup  := HRadioGroup():oGroupCurrent
   ::style   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_AUTORADIOBUTTON+;
                     WS_CHILD+WS_VISIBLE+ ;
                     IIf(::oGroup != NIL .AND. Empty(::oGroup:aButtons), WS_GROUP, 0))
   ::oFont   := oFont
   ::nLeft   := nLeft
   ::nTop    := nTop
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::bInit   := bInit
   ::bSize   := bSize
   ::bPaint  := bPaint
   ::tooltip := ctoolt
   ::tcolor  := tcolor
   /*
   IF tColor != NIL .AND. bColor == NIL
      bColor := hwg_GetSysColor(COLOR_3DFACE)
   ENDIF
   ::bcolor  := bcolor
   IF bColor != NIL
      ::brush := HBrush():Add(bcolor)
   ENDIF
   */

   ::Activate()
   ::oParent:AddControl(Self)
   ::bLostFocus := bClick
   IF bClick != NIL .AND. (::oGroup == NIL .OR. ::oGroup:bSetGet == NIL)
      hwg_SetSignal(::handle, "released", WM_LBUTTONUP, 0, 0)
   ENDIF
   IF ::oGroup != NIL
      AAdd(::oGroup:aButtons, Self)
      IF ::oGroup:bSetGet != NIL
         hwg_SetSignal(::handle, "released", WM_LBUTTONUP, 0, 0)
      ENDIF
   ENDIF

RETURN Self

METHOD Activate CLASS HRadioButton
Local groupHandle := ::oGroup:handle

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, @groupHandle, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::oGroup:handle := groupHandle
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

METHOD onEvent(msg, wParam, lParam) CLASS HRadioButton

   IF msg == WM_LBUTTONUP
      IF ::oGroup:bSetGet == NIL
         Eval(::bLostFocus, ::oGroup:value, Self)
      ELSE
         __Valid(Self)
      ENDIF
   ENDIF
RETURN NIL


STATIC FUNCTION __Valid(oCtrl)

   oCtrl:oGroup:value := AScan(oCtrl:oGroup:aButtons, {|o|o:id == oCtrl:id})
   IF oCtrl:oGroup:bSetGet != NIL
      Eval(oCtrl:oGroup:bSetGet, oCtrl:oGroup:value)
   ENDIF
   IF oCtrl:bLostFocus != NIL
      Eval(oCtrl:bLostFocus, oCtrl:oGroup:value, oCtrl)
   ENDIF

RETURN .T.
