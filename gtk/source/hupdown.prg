//
// $Id: hupdown.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HUpDown class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#ifndef UDS_SETBUDDYINT
#define UDS_SETBUDDYINT     2
#define UDS_ALIGNRIGHT      4
#endif

CLASS HUpDown INHERIT HControl

   CLASS VAR winclass   INIT "EDIT"
   DATA bSetGet
   DATA value
   DATA nLower INIT 0
   DATA nUpper INIT 999
   DATA nUpDownWidth INIT 12
   DATA lChanged    INIT .F.

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
         oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, tcolor, bcolor, nUpDWidth, nLower, nUpper)
   METHOD Activate()
   METHOD Refresh()

ENDCLASS

METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
         oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, tcolor, bcolor,   ;
         nUpDWidth, nLower, nUpper) CLASS HUpDown

   nStyle   := hwg_BitOr(iIf(nStyle == NIL, 0, nStyle), WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor)

   IF vari != NIL
      IF !HB_IsNumeric(vari)
         vari := 0
         Eval(bSetGet, vari)
      ENDIF
      ::title := Str(vari)
   ENDIF
   ::bSetGet := bSetGet

   IF nLower != NIL ; ::nLower := nLower ; ENDIF
   IF nUpper != NIL ; ::nUpper := nUpper ; ENDIF
   IF nUpDWidth != NIL ; ::nUpDownWidth := nUpDWidth ; ENDIF

   ::Activate()

   IF bSetGet != NIL
      ::bGetFocus := bGFocus
      ::bLostFocus := bLFocus
      ::oParent:AddEvent(EN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
      ::oParent:AddEvent(EN_KILLFOCUS, ::id, {|o, id|__Valid(o:FindControl(id))})
   ELSE
      IF bGfocus != NIL
         ::oParent:AddEvent(EN_SETFOCUS, ::id, bGfocus)
      ENDIF
      IF bLfocus != NIL
         ::oParent:AddEvent(EN_KILLFOCUS, ::id, bLfocus)
      ENDIF
   ENDIF

RETURN Self

METHOD Activate() CLASS HUpDown
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateUpDownControl(::oParent:handle, ;
          ::nLeft, ::nTop, ::nWidth, ::nHeight, Val(::title), ::nLower, ::nUpper)
      ::Init()
   ENDIF
RETURN NIL

METHOD Refresh() CLASS HUpDown

   //LOCAL vari // variable not used

   IF ::bSetGet != NIL
      ::value := Eval(::bSetGet)
      IF Str(::value) != ::title
         ::title := Str(::value)
         hwg_SetUpDown(::handle, ::value)
      ENDIF
   ELSE
      hwg_SetUpDown(::handle, Val(::title))
   ENDIF

RETURN NIL

STATIC FUNCTION __When(oCtrl)

   oCtrl:Refresh()
   IF oCtrl:bGetFocus != NIL 
      RETURN Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet), oCtrl)
   ENDIF

RETURN .T.

STATIC FUNCTION __Valid(oCtrl)

   oCtrl:value := hwg_SetUpDown(oCtrl:handle)
   oCtrl:title := Str(oCtrl:value)
   IF oCtrl:bSetGet != NIL
      Eval(oCtrl:bSetGet, oCtrl:value)
   ENDIF
   IF oCtrl:bLostFocus != NIL .AND. !Eval(oCtrl:bLostFocus, oCtrl:value, oCtrl) .OR. ;
         oCtrl:value > oCtrl:nUpper .OR. oCtrl:value < oCtrl:nLower
      hwg_SetFocus(oCtrl:handle)
   ENDIF

RETURN .T.
