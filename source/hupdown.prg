//
// HWGUI - Harbour Win32 GUI library source code:
// HUpDown class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HUpDown INHERIT HControl

   CLASS VAR winclass   INIT "EDIT"

   DATA bSetGet
   DATA nValue
   DATA bValid
   DATA hwndUpDown, idUpDown, styleUpDown
   DATA bkeydown, bkeyup, bchange
   DATA bClickDown, bClickUp
   DATA nLower       INIT -9999  //0
   DATA nUpper       INIT 9999  //999
   DATA nUpDownWidth INIT 10
   DATA lChanged     INIT .F.
   DATA Increment    INIT 1
   DATA nMaxLength   INIT NIL
   DATA lNoBorder
   DATA cPicture
   DATA oEditUpDown
   DATA bColorOld   HIDDEN

   DATA lCreate    INIT .F. HIDDEN //

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
              oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, ;
              nUpDWidth, nLower, nUpper, nIncr, cPicture, lNoBorder, nMaxLength, ;
              bKeyDown, bChange, bOther, bClickUp, bClickDown)

   METHOD Activate()
   METHOD Init()
   METHOD CreateUpDown()
   METHOD SetValue(nValue)
   METHOD Value(Value) SETGET
   METHOD Refresh()
   METHOD SetColor(tColor, bColor, lRedraw) INLINE ::super:SetColor(tColor, bColor, lRedraw), IIf(::oEditUpDown != NIL, ;
                                             ::oEditUpDown:SetColor(tColor, bColor, lRedraw),)
   METHOD DisableBackColor(DisableBColor) SETGET
   METHOD Hide() INLINE (::lHide := .T., hwg_HideWindow(::handle), hwg_HideWindow(::hwndUpDown))
   METHOD Show() INLINE (::lHide := .F., hwg_ShowWindow(::handle), hwg_ShowWindow(::hwndUpDown))
   METHOD Enable() INLINE (::Super:Enable(), hwg_EnableWindow(::hwndUpDown, .T.), hwg_InvalidateRect(::hwndUpDown, 0))
                          //hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nLeft + ::nWidth, ::nTop + ::nHeight))
   METHOD Disable() INLINE (::Super:Disable(), hwg_EnableWindow(::hwndUpDown, .F.))
   METHOD Valid()
   METHOD SetRange(nLower, nUpper)
   METHOD Move(x1, y1, width, height, nRepaint) INLINE ;                             // + hwg_GetClientRect(::hwndUpDown)[3] - 1
                              ::Super:Move(x1, y1, IIf(width != NIL, width, ::nWidth), height, nRepaint), ;
                              hwg_SendMessage(::hwndUpDown, UDM_SETBUDDY, ::oEditUpDown:handle, 0), ;
                              IIf(::lHide, ::Hide(), ::Show())

ENDCLASS

METHOD HUpDown:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
           oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, ;
           nUpDWidth, nLower, nUpper, nIncr, cPicture, lNoBorder, nMaxLength, ;
           bKeyDown, bChange, bOther, bClickUp, bClickDown)

   HB_SYMBOL_UNUSED(bOther)

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP + IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0))

   IF !hb_IsNumeric(vari)
      vari := 0
      Eval(bSetGet, vari)
   ENDIF
   IF bSetGet == NIL
      bSetGet := {|v|IIf(v == NIL, ::nValue, ::nValue := v)}
   ENDIF

   ::nValue := Vari
   ::title := Str(vari)
   ::bSetGet := bSetGet
   ::bColorOld := bColor
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
               bSize, bPaint, ctooltip, tcolor, bcolor)

   ::idUpDown := ::id //::NewId()

   ::Increment := IIf(nIncr == NIL, 1, nIncr)
   ::styleUpDown := UDS_ALIGNRIGHT  + UDS_ARROWKEYS + UDS_NOTHOUSANDS //+ UDS_SETBUDDYINT //+ UDS_HORZ
   IF nLower != NIL
      ::nLower := nLower
   ENDIF
   IF nUpper != NIL
      ::nUpper := nUpper
   ENDIF
   // width of spinner
   IF nUpDWidth != NIL
      ::nUpDownWidth := nUpDWidth
   ENDIF
   ::nMaxLength :=  nMaxLength //= NIL, 4, nMaxLength)
   ::cPicture := IIf(cPicture == NIL, Replicate("9", 4), cPicture)
   ::lNoBorder := lNoBorder
   ::bkeydown := bkeydown
   ::bchange  := bchange
   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus

   ::Activate()

   ::bClickDown := bClickDown
   ::bClickUp := bClickUp

   IF bSetGet != NIL
      ::bValid := bLFocus
   ELSE
      IF bGfocus != NIL
         ::lnoValid := .T.
      ENDIF
   ENDIF

  RETURN Self

METHOD HUpDown:Activate()

   IF !Empty(::oParent:handle)
      ::lCreate := .T.
      ::oEditUpDown := HEditUpDown():New(::oParent, ::id, val(::title), ::bSetGet, ::Style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ;
           ::oFont, ::bInit, ::bSize, ::bPaint, ::bGetfocus, ::bLostfocus, ::tooltip, ::tcolor, ::bcolor, ::cPicture, ;
           ::lNoBorder, ::nMaxLength, , ::bKeyDown, ::bChange, ::bOther, ::controlsource)
      ::oEditUpDown:Name := "oEditUpDown"
      ::SetColor(::tColor, ::oEditUpDown:bColor)
      ::Init()
   ENDIF

   RETURN NIL

METHOD HUpDown:Init()

   IF !::lInit
      ::Super:Init()
      ::Createupdown()
      ::DisableBackColor := ::DisablebColor
      ::Refresh()
   ENDIF
   RETURN NIL


METHOD HUpDown:CREATEUPDOWN()

   ///IF Empty(::handle)
   //   RETURN NIL
    //ENDIF
   ::nHolder := 0
   IF !::lCreate
       ::Activate()
       hwg_AddToolTip(::GetParentForm():handle, ::oEditUpDown:handle, ::tooltip)
       ::oEditUpDown:SetFont(::oFont)
       ::oEditUpDown:DisableBrush := ::DisableBrush  
       hwg_SetWindowPos(::oEditUpDown:handle, ::handle, 0, 0, 0, 0, SWP_NOSIZE +  SWP_NOMOVE)
       hwg_DestroyWindow(::handle)
   ELSEIF ::getParentForm():Type < WND_DLG_RESOURCE .AND. ::oParent:ClassName = "HTAB" //!Empty(::oParent:oParent)
      // MDICHILD WITH TAB
      ::nHolder := 1
      hwg_SetWindowObject(::oEditUpDown:handle, ::oEditUpDown)
      hwg_InitEditProc(::oEditUpDown:handle)
    ENDIF
   ::handle := ::oEditUpDown:handle
   ::hwndUpDown := hwg_CreateUpDownControl(::oParent:handle, ::idUpDown, ;
                                     ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, -2147483647, 2147483647, Val(::title))
                                    // ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, ::nLower, ::nUpper, Val(::title))
   ::oEditUpDown:oUpDown := Self
   ::oEditUpDown:lInit := .T.
   IF ::nHolder == 0
      ::nHolder := 1
      hwg_SetWindowObject(::handle, ::oEditUpDown)
      hwg_InitEditProc(::handle)
   ENDIF
   RETURN NIL

METHOD HUpDown:DisableBackColor(DisableBColor)

    IF DisableBColor != NIL
       ::Super:DisableBackColor(DisableBColor)
       IF ::oEditUpDown != NIL
          ::oEditUpDown:DisableBrush := ::DisableBrush
       ENDIF
    ENDIF
    RETURN ::DisableBColor

METHOD HUpDown:SetRange(nLower, nUpper)
   
   ::nLower := IIf(nLower != NIL, nLower, ::nLower)
   ::nUpper := IIf(nUpper != NIL, nUpper, ::nUpper)
   hwg_SetRangeUpDown(::nLower, ::nUpper)

   RETURN NIL

METHOD HUpDown:Value(Value)

   IF Value != NIL .AND. ::oEditUpDown != NIL
       ::SetValue(Value)
       ::oEditUpDown:Title :=  ::Title
       ::oEditUpDown:Refresh()
   ENDIF
   RETURN ::nValue

METHOD HUpDown:SetValue(nValue)

   IF nValue < ::nLower .OR. nValue > ::nUpper
       nValue := ::nValue
   ENDIF
   ::nValue := nValue
   ::title := Str(::nValue)
   hwg_SetUpDown(::hwndUpDown, ::nValue)
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::nValue, Self)
   ENDIF

   RETURN ::nValue

METHOD HUpDown:Refresh()

   IF hb_IsBlock(::bSetGet) //.AND. ::nValue != NIL
      ::nValue := Eval(::bSetGet, , Self)
      IF Str(::nValue) != ::title
         //::title := Str(::nValue)
         //hwg_SetUpDown(::hwndUpDown, ::nValue)
         ::SetValue(::nValue)
      ENDIF
   ELSE
      hwg_SetUpDown(::hwndUpDown, Val(::title))
   ENDIF
   ::oEditUpDown:Title :=  ::Title
   ::oEditUpDown:Refresh()
   IF hwg_SelfFocus(::handle)
      hwg_InvalidateRect(::hwndUpDown, 0)
   ENDIF

   RETURN NIL

METHOD HUpDown:Valid()
   LOCAL res

   /*
   ::title := hwg_GetEditText(::oParent:handle, ::oEditUpDown:id)
   ::nValue := Val(LTrim(::title))
   IF hb_IsBlock(::bSetGet)
      Eval(::bSetGet, ::nValue)
   ENDIF
   */
   res :=  ::nValue <= ::nUpper .AND. ::nValue >= ::nLower
   IF !res
      ::nValue := IIf(::nValue > ::nUpper, Min(::nValue, ::nUpper), Max(::nValue, ::nLower))
      ::SetValue(::nValue)
      ::oEditUpDown:Refresh()
      hwg_SendMessage(::oEditUpDown:handle, EM_SETSEL, 0, -1)
      ::SetFocus()
      RETURN res
   ENDIF
   RETURN res

// -----------------------------------------------------------------
CLASS HEditUpDown INHERIT HEdit

    //DATA Value

    METHOD Init()
    METHOD Notify(lParam)
    METHOD Refresh()
    METHOD Move()  VIRTUAL

ENDCLASS

METHOD HEditUpDown:Init()

   IF !::lInit
      IF ::bChange != NIL
         ::oParent:AddEvent(EN_CHANGE, self, {||::onChange()}, , "onChange")
      ENDIF
   ENDIF
   RETURN NIL

METHOD HEditUpDown:Notify(lParam)
   Local nCode := hwg_GetNotifyCode(lParam)
   Local iPos := hwg_GetNotifyDeltaPos(lParam, 1)
   Local iDelta := hwg_GetNotifyDeltaPos(lParam, 2)
   Local vari, res

   //iDelta := IIf(iDelta < 0, 1, -1) // IIf(::oParent:oParent == NIL, -1, 1)

     IF ::oUpDown == NIL .OR. hwg_BitAnd(hwg_GetWindowLong(::handle, GWL_STYLE), ES_READONLY) != 0 .OR. ;
         hwg_GetFocus() != ::handle .OR. ;
       (::oUpDown:bGetFocus != NIL .AND. !Eval(::oUpDown:bGetFocus, ::oUpDown:nValue, ::oUpDown))
        RETURN 0
   ENDIF

   vari := Val(LTrim(::UnTransform(::title)))

   IF (vari <= ::oUpDown:nLower .AND. iDelta < 0) .OR. ;
       (vari >= ::oUpDown:nUpper .AND. iDelta > 0) .OR. ::oUpDown:Increment == 0
       ::SetFocus()
       RETURN 0
   ENDIF
   vari :=  vari + (::oUpDown:Increment * idelta)
   ::Title := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
   hwg_SetDlgItemText(::oParent:handle, ::id, ::title)
   ::oUpDown:Title := ::Title
   ::oUpDown:SetValue(vari)
   ::SetFocus()
   IF nCode == UDN_DELTAPOS .AND. (::oUpDown:bClickUp != NIL .OR. ::oUpDown:bClickDown != NIL)
      ::oparent:lSuspendMsgsHandling := .T.
      IF iDelta < 0 .AND. ::oUpDown:bClickDown != NIL
         res := Eval(::oUpDown:bClickDown, ::oUpDown, ::oUpDown:nValue, iDelta, ipos)
      ELSEIF iDelta > 0 .AND. ::oUpDown:bClickUp != NIL
         res := Eval(::oUpDown:bClickUp, ::oUpDown, ::oUpDown:nValue, iDelta, ipos)
      ENDIF
      ::oparent:lSuspendMsgsHandling := .F.
      IF hb_IsLogical(res) .AND. !res
         RETURN 0
      ENDIF
   ENDIF
   IF nCode == UDN_FIRST

   ENDIF
   RETURN 0

METHOD HEditUpDown:Refresh()
   LOCAL vari

   vari := ::Value
   IF ::bSetGet != NIL .AND. ::title != NIL
      ::Title := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
   ENDIF
   hwg_SetDlgItemText(::oParent:handle, ::id, ::title)

   RETURN NIL

// ------------------ END NEW CLASS UPDOWN

/*
CLASS HUpDown INHERIT HControl

CLASS VAR winclass   INIT "EDIT"
   DATA bSetGet
   DATA value
   DATA bValid
   DATA hUpDown, idUpDown, styleUpDown
   DATA nLower INIT 0
   DATA nUpper INIT 999
   DATA nUpDownWidth INIT 12
   DATA lChanged    INIT .F.

   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
               oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, nUpDWidth, nLower, nUpper)
   METHOD Activate()
   METHOD Init()
   METHOD OnEvent(msg, wParam, lParam)
   METHOD Refresh()
   METHOD Hide() INLINE (::lHide := .T., hwg_HideWindow(::handle), hwg_HideWindow(::hwndUpDown))
   METHOD Show() INLINE (::lHide := .F., hwg_ShowWindow(::handle), hwg_ShowWindow(::hwndUpDown))

ENDCLASS

METHOD HUpDown:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
            oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctooltip, tcolor, bcolor, ;
            nUpDWidth, nLower, nUpper)

   nStyle   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_TABSTOP + WS_BORDER + ES_RIGHT)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
              bSize, bPaint, ctooltip, tcolor, bcolor)

   ::idUpDown := ::NewId()
   IF !hb_IsNumeric(vari)
      vari := 0
      Eval(bSetGet, vari)
   ENDIF
   ::title := Str(vari)
   ::bSetGet := bSetGet

   ::styleUpDown := UDS_SETBUDDYINT + UDS_ALIGNRIGHT

   IF nLower != NIL
      ::nLower := nLower
   ENDIF
   IF nUpper != NIL
      ::nUpper := nUpper
   ENDIF
   IF nUpDWidth != NIL
      ::nUpDownWidth := nUpDWidth
   ENDIF

   ::Activate()

   IF bSetGet != NIL
      ::bGetFocus := bGfocus
      ::bLostFocus := bLfocus
      ::bValid := bLfocus
      ::lnoValid := bGfocus != NIL
      ::oParent:AddEvent(EN_SETFOCUS, Self, {|o, id|__When(o:FindControl(id))},, "onGotFocus")
      ::oParent:AddEvent(EN_KILLFOCUS, Self, {|o, id|__Valid(o:FindControl(id))},, "onLostFocus")
   ELSE
      IF bGfocus != NIL
         ::lnoValid := .T.
         ::oParent:AddEvent(EN_SETFOCUS, Self, {|o, id|__When(o:FindControl(id))},, "onGotFocus")
         //::oParent:AddEvent(EN_SETFOCUS, self, bGfocus, , "onGotFocus")
      ENDIF
      IF bLfocus != NIL
         // ::oParent:AddEvent(EN_KILLFOCUS, self, bLfocus, , "onLostFocus")
         ::oParent:AddEvent(EN_KILLFOCUS, Self, {|o, id|__Valid(o:FindControl(id))},, "onLostFocus")
      ENDIF
   ENDIF

   RETURN Self

METHOD HUpDown:Activate()
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateEdit(::oParent:handle, ::id, ;
                             ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF
   RETURN NIL

METHOD HUpDown:Init()
   IF !::lInit
      ::Super:Init()
      ::nHolder := 1
      hwg_SetWindowObject(::handle, Self)
      HWG_INITUpDownPROC(::handle)
      ::hwndUpDown := hwg_CreateUpDownControl(::oParent:handle, ::idUpDown, ;
                                        ::styleUpDown, 0, 0, ::nUpDownWidth, 0, ::handle, ::nUpper, ::nLower, Val(::title))
   ENDIF
   RETURN NIL

METHOD HUpDown:OnEvent(msg, wParam, lParam)

   IF hb_IsBlock(::bOther)
      IF Eval(::bOther, Self, msg, wParam, lParam) != -1
         RETURN 0
      ENDIF
   ENDIF
   IF msg == WM_CHAR
      IF wParam == VK_TAB
          hwg_GetSkip(::oParent, ::handle, , IIf(hwg_IsCtrlShift(.F., .T.), -1, 1))
          RETURN 0
      ELSEIF wParam == VK_RETURN
          hwg_GetSkip(::oParent, ::handle, , 1)
          RETURN 0
        ENDIF

    ELSEIF msg == WM_KEYDOWN

        hwg_ProcKeyList(Self, wParam)

   ELSEIF msg == WM_VSCROLL
    ENDIF

RETURN -1

METHOD HUpDown:Refresh()

   IF hb_IsBlock(::bSetGet)
      ::value := Eval(::bSetGet)
      IF Str(::value) != ::title
         ::title := Str(::value)
         hwg_SetUpDown(::hwndUpDown, ::value)
      ENDIF
   ELSE
      hwg_SetUpDown(::hwndUpDown, Val(::title))
   ENDIF

   RETURN NIL

STATIC FUNCTION __When(oCtrl)
   LOCAL res := .T., oParent, nSkip

   IF !hwg_CheckFocus(oCtrl, .F.)
      RETURN .T.
   ENDIF
   IF oCtrl:bGetFocus != NIL
      oCtrl:Refresh()
      oCtrl:lnoValid := .T.
      oCtrl:oParent:lSuspendMsgsHandling := .T.
      res := Eval(oCtrl:bGetFocus, Eval(oCtrl:bSetGet, , oCtrl), oCtrl)
      oCtrl:oParent:lSuspendMsgsHandling := .F.
      oCtrl:lnoValid := !res
      IF !res
         oParent := hwg_ParentGetDialog(oCtrl)
         IF oCtrl == ATail(oParent:GetList)
            nSkip := - 1
         ELSEIF oCtrl == oParent:getList[1]
            nSkip := 1
         ENDIF
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, , nSkip)
      ENDIF
   ENDIF
   RETURN res

STATIC FUNCTION __Valid(oCtrl)
   LOCAL res := .T., hctrl, nSkip, oDlg
   LOCAL ltab :=  hwg_GetKeyState(VK_TAB) < 0

   IF !hwg_CheckFocus(oCtrl, .T.) .OR. oCtrl:lnoValid
      RETURN .T.
   ENDIF
   nSkip := IIf(hwg_GetKeyState(VK_SHIFT) < 0, -1, 1)
   oCtrl:title := hwg_GetEditText(oCtrl:oParent:handle, oCtrl:id)
   oCtrl:value := Val(LTrim(oCtrl:title))
   IF oCtrl:bSetGet != NIL
      Eval(oCtrl:bSetGet, oCtrl:value)
   ENDIF
   oCtrl:oparent:lSuspendMsgsHandling := .T.
   hctrl := hwg_GetFocus()
   oDlg := hwg_ParentGetDialog(oCtrl)
   IF oCtrl:bLostFocus != NIL
      res := Eval(oCtrl:bLostFocus, oCtrl:value, oCtrl)
      res := IIf(res, oCtrl:value <= oCtrl:nUpper .AND. ;
                  oCtrl:value >= oCtrl:nLower, res)
      IF !res
         hwg_SetFocus(oCtrl:handle)
         IF oDlg != NIL
            oDlg:nLastKey := 0
         ENDIF
      ENDIF
   ENDIF
   IF ltab .AND. hctrl == hwg_GetFocus() .AND. res
      IF oCtrl:oParent:CLASSNAME = "HTAB"
         hwg_GetSkip(oCtrl:oparent, oCtrl:handle, , nSkip)
      ENDIF
   ENDIF
   oCtrl:oparent:lSuspendMsgsHandling := .F.
   IF Empty(hwg_GetFocus()) //= 0
      hwg_GetSkip(octrl:oParent, octrl:handle, , octrl:nGetSkip)
   ENDIF

   RETURN res

   */