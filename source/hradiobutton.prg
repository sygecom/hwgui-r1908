//
// $Id: hradio.prg 1868 2012-08-27 17:33:11Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HRadioButton class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//#DEFINE TRANSPARENT 1 // defined in windows.ch

CLASS HRadioButton INHERIT HControl

CLASS VAR winclass   INIT "BUTTON"
   DATA oGroup
   DATA lWhen  INIT .F.

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
              bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp)
   METHOD Activate()
   METHOD Init()
   METHOD Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp)
   METHOD GetValue() INLINE (hwg_SendMessage(::handle, BM_GETCHECK, 0, 0) == 1)
  // METHOD Notify(lParam)
   METHOD onevent(msg, wParam, lParam)
   METHOD onGotFocus()
   METHOD onClick()
   METHOD Valid(nKey)
   METHOD When()


ENDCLASS

METHOD HRadioButton:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
            bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp)

   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)

   ::id      := IIf(nId == NIL, ::NewId(), nId)
   ::title   := cCaption
   ::oGroup  := HRadioGroup():oGroupCurrent
   ::Enabled := !hwg_BitAnd(nStyle, WS_DISABLED) > 0
   ::style   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_RADIOBUTTON + ; // BS_AUTORADIOBUTTON+;
                        BS_NOTIFY + ;  // WS_CHILD + WS_VISIBLE
                       IIf(::oGroup != NIL .AND. Empty(::oGroup:aButtons), WS_GROUP, 0))

   ::Super:New(oWndParent, nId, ::Style, nLeft, nTop, nWidth, nHeight, ;
              oFont, bInit, bSize, bPaint, ctooltip, tcolor, bColor)

   ::backStyle :=  IIf(lTransp != NIL .AND. lTransp, WINAPI_TRANSPARENT, OPAQUE)

   ::Activate()
   //::SetColor(tcolor, bColor, .T.)

   //::oParent:AddControl(Self)

   IF ::oGroup != NIL
      bClick := IIf(bClick != NIL, bClick, ::oGroup:bClick)
      bGFocus := IIf(bGFocus != NIL, bGFocus, ::oGroup:bGetFocus)
   ENDIF
   IF bClick != NIL .AND. (::oGroup == NIL .OR. ::oGroup:bSetGet == NIL)
      ::bLostFocus := bClick
   ENDIF
   ::bGetFocus  := bGFocus
   IF bGFocus != NIL
      ::oParent:AddEvent(BN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))},, "onGotFocus")
      //::oParent:AddEvent(BN_SETFOCUS, Self, {|o, id|__When(o:FindControl(id))},, "onGotFocus")
      ::lnoValid := .T.
   ENDIF

   ::oParent:AddEvent(BN_KILLFOCUS, Self, {||hwg_CheckFocus(Self, .T.)})

   IF ::oGroup != NIL
      AAdd(::oGroup:aButtons, Self)
      // IF ::oGroup:bSetGet != NIL
      ::bLostFocus := bClick
      //- ::oParent:AddEvent(BN_CLICKED, self, {|o, id|::Valid(o:FindControl(id))},, "onClick")
      ::oParent:AddEvent(BN_CLICKED, self, {||::onClick()}, , "onClick")
      // ENDIF
   ENDIF

   RETURN Self

METHOD HRadioButton:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                               ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HRadioButton:Init()
   IF !::lInit
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      HWG_INITBUTTONPROC(::handle)
      ::Enabled :=  ::oGroup:lEnabled .AND. ::Enabled
      ::Super:Init()
   ENDIF
RETURN NIL

METHOD HRadioButton:Redefine(oWndParent, nId, oFont, bInit, bSize, bPaint, bClick, ctooltip, tcolor, bcolor, bGFocus, lTransp)
   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := nId
   ::oGroup  := HRadioGroup():oGroupCurrent
   ::style   := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::oFont   := oFont
   ::bInit   := bInit
   ::bSize   := bSize
   ::bPaint  := bPaint
   ::tooltip := ctooltip
   /*
   ::tcolor  := tcolor
   IF tColor != NIL .AND. bColor == NIL
      bColor := hwg_GetSysColor(COLOR_3DFACE)
   ENDIF
   */
   ::backStyle :=  IIf(lTransp != NIL .AND. lTransp, WINAPI_TRANSPARENT, OPAQUE)
   ::setcolor(tColor, bColor, .T.)
   ::oParent:AddControl(Self)

   ::oParent:AddControl(Self)

   IF bClick != NIL .AND. (::oGroup == NIL .OR. ::oGroup:bSetGet == NIL)
      //::oParent:AddEvent(0, self, bClick, , "onClick")
      ::bLostFocus := bClick
      //::oParent:AddEvent(0, self, {|o, id|__Valid(o:FindControl(id))}, , "onClick")
   ENDIF
   ::bGetFocus  := bGFocus
   IF bGFocus != NIL
      ::oParent:AddEvent(BN_SETFOCUS, self, {|o, id|::When(o:FindControl(id))},, "onGotFocus")
      ::lnoValid := .T.
   ENDIF
   //::oParent:AddEvent(BN_KILLFOCUS, Self, {||::Notify(WM_KEYDOWN)})
   ::oParent:AddEvent(BN_KILLFOCUS, Self, {||hwg_CheckFocus(Self, .T.)})
   IF ::oGroup != NIL
      AAdd(::oGroup:aButtons, Self)
      // IF ::oGroup:bSetGet != NIL
      ::bLostFocus := bClick
      //::oParent:AddEvent(BN_CLICKED, self, {|o, id|::Valid(o:FindControl(id))},, "onClick")
      ::oParent:AddEvent(BN_CLICKED, self, {||::onClick()}, , "onClick")
      // ENDIF
   ENDIF
   RETURN Self

#if 0 // old code for reference
METHOD HRadioButton:onEvent(msg, wParam, lParam)
    LOCAL oCtrl

   IF hb_IsBlock(::bOther)
      IF Eval(::bOther, Self, msg, wParam, lParam) != -1
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_GETDLGCODE //.AND. !Empty(wParam)
       IF wParam == VK_RETURN .AND. hwg_ProcOkCancel(Self, wParam, ::GetParentForm():Type >= WND_DLG_RESOURCE)
         RETURN 0
      ELSEIF wParam == VK_ESCAPE .AND. ;
                  (oCtrl := ::GetParentForm:FindControl(IDCANCEL)) != NIL .AND. !oCtrl:IsEnabled()
         RETURN DLGC_WANTMESSAGE
       ELSEIF (wParam != VK_TAB .AND. hwg_GetDlgMessage(lParam) == WM_CHAR) .OR. hwg_GetDlgMessage(lParam) == WM_SYSCHAR .OR. ;
               wParam == VK_ESCAPE
         RETURN -1
      ELSEIF hwg_GetDlgMessage(lParam) == WM_KEYDOWN .AND. wParam == VK_RETURN  // DIALOG
         ::VALID(VK_RETURN)   // dialog funciona
         RETURN DLGC_WANTARROWS
      ENDIF
      RETURN DLGC_WANTMESSAGE
   ELSEIF msg == WM_KEYDOWN
      //IF hwg_ProcKeyList(Self, wParam)
      IF wParam == VK_LEFT .OR. wParam == VK_UP
         hwg_GetSkip(::oparent, ::handle, , -1)
         RETURN 0
      ELSEIF wParam == VK_RIGHT .OR. wParam == VK_DOWN
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN 0
      ELSEIF wParam == VK_TAB //.AND. nType < WND_DLG_RESOURCE
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      ENDIF
      IF (wParam == VK_RETURN)
         ::VALID(VK_RETURN)
         RETURN 0
      ENDIF
   ELSEIF msg == WM_KEYUP
      hwg_ProcKeyList(Self, wParam)   // working in MDICHILD AND DIALOG
      IF (wParam == VK_RETURN)
         RETURN 0
      ENDIF
   ELSEIF msg == WM_NOTIFY
   ENDIF

   RETURN -1
#else
METHOD HRadioButton:onEvent(msg, wParam, lParam)

   LOCAL oCtrl

   IF hb_IsBlock(::bOther)
      IF Eval(::bOther, Self, msg, wParam, lParam) != -1
         RETURN 0
      ENDIF
   ENDIF

   SWITCH msg

   CASE WM_GETDLGCODE //.AND. !Empty(wParam)
      IF wParam == VK_RETURN .AND. hwg_ProcOkCancel(Self, wParam, ::GetParentForm():Type >= WND_DLG_RESOURCE)
         RETURN 0
      ELSEIF wParam == VK_ESCAPE .AND. (oCtrl := ::GetParentForm:FindControl(IDCANCEL)) != NIL .AND. !oCtrl:IsEnabled()
         RETURN DLGC_WANTMESSAGE
      ELSEIF (wParam != VK_TAB .AND. hwg_GetDlgMessage(lParam) == WM_CHAR) .OR. hwg_GetDlgMessage(lParam) == WM_SYSCHAR .OR. ;
         wParam == VK_ESCAPE
         RETURN -1
      ELSEIF hwg_GetDlgMessage(lParam) == WM_KEYDOWN .AND. wParam == VK_RETURN  // DIALOG
         ::VALID(VK_RETURN)   // dialog funciona
         RETURN DLGC_WANTARROWS
      ENDIF
      RETURN DLGC_WANTMESSAGE

   CASE WM_KEYDOWN
      //IF hwg_ProcKeyList(Self, wParam)
      SWITCH wParam
      CASE VK_LEFT
      CASE VK_UP
         hwg_GetSkip(::oparent, ::handle, , -1)
         RETURN 0
      CASE VK_RIGHT
      CASE VK_DOWN
         hwg_GetSkip(::oparent, ::handle, , 1)
         RETURN 0
      CASE VK_TAB //.AND. nType < WND_DLG_RESOURCE
         hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
         RETURN 0
      CASE VK_RETURN
         ::VALID(VK_RETURN)
         RETURN 0
      ENDSWITCH
      EXIT

   CASE WM_KEYUP
      hwg_ProcKeyList(Self, wParam)   // working in MDICHILD AND DIALOG
      IF wParam == VK_RETURN
         RETURN 0
      ENDIF
      EXIT

   CASE WM_NOTIFY

   ENDSWITCH

RETURN -1
#endif

#if 0
METHOD HRadioButton:Notify(lParam)
   LOCAL ndown := hwg_GetKeyState(VK_RIGHT) + hwg_GetKeyState(VK_DOWN) + hwg_GetKeyState(VK_TAB)
   LOCAL nSkip := 0

   IF !hwg_CheckFocus(Self, .T.)
      RETURN 0
   ENDIF

   IF hwg_PtrToUlong(lParam) == WM_KEYDOWN
      IF hwg_GetKeyState(VK_RETURN) < 0 //.AND. ::oGroup:value < Len(::oGroup:aButtons)
         ::oParent:lSuspendMsgsHandling := .T.
         __VALID(Self)
         ::oParent:lSuspendMsgsHandling := .F.
      ENDIF
      IF ::oParent:classname = "HTAB"
         IF hwg_GetKeyState(VK_LEFT) + hwg_GetKeyState(VK_UP) < 0 .OR. ;
            (hwg_GetKeyState(VK_TAB) < 0 .AND. hwg_GetKeyState(VK_SHIFT) < 0)
            nSkip := -1
         ELSEIF ndown < 0
            nSkip := 1
         ENDIF
         IF nSkip != 0
            //hwg_SetFocus(::oParent:handle)
            ::oParent:SETFOCUS()
            hwg_GetSkip(::oparent, ::handle, , nSkip)
         ENDIF
      ENDIF
   ENDIF

   RETURN NIL
#endif

METHOD HRadioButton:onGotFocus()
   RETURN ::When()

METHOD HRadioButton:onClick()
   ::lWhen := .F.
   ::lnoValid := .F.
   RETURN ::Valid(0)

METHOD HRadioButton:When()
   LOCAL res := .T., nSkip

   IF !hwg_CheckFocus(Self, .F.)
      RETURN .T.
   ENDIF
   nSkip := IIf(hwg_GetKeyState(VK_UP) < 0 .OR. (hwg_GetKeyState(VK_TAB) < 0 .AND. hwg_GetKeyState(VK_SHIFT) < 0), - 1, 1)
   ::lwhen := hwg_GetKeyState(VK_UP)  + hwg_GetKeyState(VK_DOWN) + hwg_GetKeyState(VK_RETURN) + hwg_GetKeyState(VK_TAB) < 0
   IF hb_IsBlock(::bGetFocus)
      ::lnoValid := .T.
      ::oParent:lSuspendMsgsHandling := .T.
      res := Eval(::bGetFocus, ::oGroup:nValue, Self)
      ::lnoValid := !res
      ::oparent:lSuspendMsgsHandling := .F.
      IF !res
         hwg_WhenSetFocus(Self, nSkip)
      ELSE
         ::SETfOCUS()   
      ENDIF
   ENDIF
   RETURN res


METHOD HRadioButton:Valid(nKey)
   LOCAL nEnter := IIf(nKey == NIL, 1, nkey)
   LOCAL hctrl, iValue

   IF ::lnoValid .OR. hwg_GetKeyState(VK_LEFT) + hwg_GetKeyState(VK_RIGHT) + hwg_GetKeyState(VK_UP) + ;
       hwg_GetKeyState(VK_DOWN) + hwg_GetKeyState(VK_TAB) < 0 .OR. ::oGroup == NIL .OR. ::lwhen
      ::lwhen := .F.
      RETURN .T.
   ELSE
      ::oParent:lSuspendMsgsHandling := .T.
       iValue := AScan(::oGroup:aButtons, {|o|o:id == ::id})
      IF nEnter == VK_RETURN //< 0
         //-iValue := AScan(::oGroup:aButtons, {|o|o:id == ::id})
         IF !::GetValue()
            ::oGroup:nValue  := iValue
             ::oGroup:SetValue(::oGroup:nValue)      
            ::SetFocus(.T.)
         ENDIF
      ELSEIF nEnter == 0 .AND. !hwg_GetKeyState(VK_RETURN) < 0
         IF !::GetValue()
             ::oGroup:nValue := AScan(::oGroup:aButtons, {|o|o:id == ::id})
             ::oGroup:SetValue(::oGroup:nValue)
         ENDIF 
      ENDIF
   ENDIF
   IF ::oGroup:bSetGet != NIL
      Eval(::oGroup:bSetGet, ::oGroup:nValue)
   ENDIF
   hCtrl := hwg_GetFocus()
   IF hb_IsBlock(::bLostFocus) .AND. (nEnter == 0 .OR. iValue == Len(::oGroup:aButtons))
      Eval(::bLostFocus, Self, ::oGroup:nValue)
   ENDIF
   IF nEnter == VK_RETURN .AND. hwg_SelfFocus(hctrl)
       hwg_GetSkip(::oParent, hCtrl, , 1)
   ENDIF
   ::oParent:lSuspendMsgsHandling := .F.  
   
   RETURN .T.
