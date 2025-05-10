//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HComboBox class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#define CB_ERR              (-1)
#ifndef CBN_SELCHANGE
#define CBN_SELCHANGE       1
#define CBN_DBLCLK          2
#define CBN_SETFOCUS        3
#define CBN_KILLFOCUS       4
#define CBN_EDITCHANGE      5
#define CBN_EDITUPDATE      6
#define CBN_DROPDOWN        7
#define CBN_CLOSEUP         8
#define CBN_SELENDOK        9
#define CBN_SELENDCANCEL    10
#endif

CLASS HComboBox INHERIT HControl

   CLASS VAR winclass   INIT "COMBOBOX"
   DATA aItems
   DATA bSetGet
   DATA value    INIT 1
   DATA bChangeSel
   DATA lText    INIT .F.
   DATA lEdit    INIT .F.
   DATA hEdit

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  aItems, oFont, bInit, bSize, bPaint, bChange, cToolt, lEdit, lText, bGFocus, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   //METHOD Init(aCombo, nCurrent)
   METHOD Init()
   METHOD Refresh()
   METHOD Setitem(nPos)
   METHOD End()
ENDCLASS

METHOD HComboBox:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, aItems, oFont, ;
                  bInit, bSize, bPaint, bChange, cToolt, lEdit, lText, bGFocus, tcolor, bcolor)

   IF lEdit == NIL
      lEdit := .F.
   ENDIF
   IF lText == NIL
      lText := .F.
   ENDIF

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), IIf(lEdit, CBS_DROPDOWN, CBS_DROPDOWNLIST) + WS_TABSTOP)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, bSize, bPaint, ctoolt, tcolor, bcolor)

   ::lEdit := lEdit
   ::lText := lText

   IF lEdit
      ::lText := .T.
   ENDIF

   IF ::lText
      ::value := IIf(vari == NIL .OR. !hb_IsChar(vari), "", vari)
   ELSE
      ::value := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
   ENDIF
   
   ::bSetGet := bSetGet
   ::aItems  := aItems

   ::Activate()
/*
   IF bSetGet != NIL
      ::bChangeSel := bChange
      ::bGetFocus  := bGFocus
      ::oParent:AddEvent(CBN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
      ::oParent:AddEvent(CBN_SELCHANGE, ::id, {|o, id|__Valid(o:FindControl(id))})
   ELSEIF bChange != NIL
      ::oParent:AddEvent(CBN_SELCHANGE, ::id, bChange)
   ENDIF
   
   IF bGFocus != NIL .AND. bSetGet == NIL
      ::oParent:AddEvent(CBN_SETFOCUS, ::id, {|o, id|__When(o:FindControl(id))})
   ENDIF
*/
   ::bGetFocus := bGFocus
   ::bLostFocus := bChange

   hwg_SetEvent(::hEdit, "focus_in_event", EN_SETFOCUS, 0, 0)
   hwg_SetEvent(::hEdit, "focus_out_event", EN_KILLFOCUS, 0, 0)

RETURN Self

METHOD HComboBox:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateCombo(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::hEdit := hwg_ComboGetEdit(::handle)
      ::Init()
      hwg_SetWindowObject(::hEdit, Self)
   ENDIF
RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD HComboBox:onEvent(msg, wParam, lParam)

   IF msg == EN_SETFOCUS
      IF ::bSetGet == NIL
         IF ::bGetFocus != NIL
            Eval(::bGetFocus, hwg_Edit_GetText(::hEdit), Self)
         ENDIF
      ELSE
         __When(Self)
      ENDIF
   ELSEIF msg == EN_KILLFOCUS
      IF ::bSetGet == NIL
         IF ::bLostFocus != NIL
            Eval(::bLostFocus, hwg_Edit_GetText(::hEdit), Self)
         ENDIF
      ELSE
         __Valid(Self)
      ENDIF

   ENDIF

RETURN 0
#else
METHOD HComboBox:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   SWITCH msg
   CASE EN_SETFOCUS
      IF ::bSetGet == NIL
         IF ::bGetFocus != NIL
            Eval(::bGetFocus, hwg_Edit_GetText(::hEdit), Self)
         ENDIF
      ELSE
         __When(Self)
      ENDIF
      EXIT
   CASE EN_KILLFOCUS
      IF ::bSetGet == NIL
         IF ::bLostFocus != NIL
            Eval(::bLostFocus, hwg_Edit_GetText(::hEdit), Self)
         ENDIF
      ELSE
         __Valid(Self)
      ENDIF
   ENDSWITCH

RETURN 0
#endif

METHOD HComboBox:Init()

   //LOCAL i // variable not used

   IF !::lInit
      ::Super:Init()
      IF ::aItems != NIL
	 hwg_ComboSetArray(::handle, ::aItems)
         IF ::value == NIL
            IF ::lText
                ::value := ::aItems[1]
            ELSE
                ::value := 1                                                     
            ENDIF                
         ENDIF
         IF ::lText
            hwg_edit_Settext(::hEdit, ::value)
         ELSE
            hwg_edit_Settext(::hEdit, ::aItems[::value])
         ENDIF
      ENDIF
   ENDIF
RETURN NIL

METHOD HComboBox:Refresh()

   LOCAL vari
   //LOCAL i // variable not used

   IF ::bSetGet != NIL
      vari := Eval(::bSetGet, , Self)
      IF ::lText
         ::value := IIf(vari == NIL .OR. !hb_IsChar(vari), "", vari)
      ELSE
         ::value := IIf(vari == NIL .OR. !hb_IsNumeric(vari), 1, vari)
      ENDIF
   ENDIF

   hwg_ComboSetArray(::handle, ::aItems)
   
   IF ::lText
      hwg_edit_Settext(::hEdit, ::value)
   ELSE
      hwg_edit_Settext(::hEdit, ::aItems[::value])
   ENDIF

RETURN NIL

METHOD HComboBox:SetItem(nPos)

   IF ::lText
      ::value := ::aItems[nPos]
   ELSE
      ::value := nPos
   ENDIF

   hwg_edit_Settext(::hEdit, ::aItems[nPos])

   IF ::bSetGet != NIL
      Eval(::bSetGet, ::value, self)
   ENDIF

   IF ::bChangeSel != NIL
      Eval(::bChangeSel, ::value, Self)
   ENDIF

RETURN NIL

METHOD HComboBox:End()

   hwg_ReleaseObject(::hEdit)
   ::Super:End()

RETURN NIL


STATIC FUNCTION __Valid(oCtrl)

   LOCAL vari := hwg_edit_Gettext(oCtrl:hEdit)

   IF oCtrl:lText
      oCtrl:value := vari
   ELSE
      oCtrl:value := AScan(oCtrl:aItems, vari)
   ENDIF

   IF oCtrl:bSetGet != NIL
      Eval(oCtrl:bSetGet, oCtrl:value, oCtrl)
   ENDIF
   IF oCtrl:bChangeSel != NIL
      Eval(oCtrl:bChangeSel, oCtrl:value, oCtrl)
   ENDIF
RETURN .T.

STATIC FUNCTION __When(oCtrl)

   LOCAL res

   // oCtrl:Refresh()

   IF oCtrl:bGetFocus != NIL
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, , oCtrl), oCtrl)
      IF !res
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
      ENDIF
      RETURN res
   ENDIF

RETURN .T.

