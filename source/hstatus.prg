//
// HWGUI - Harbour Win32 GUI library source code:
// HStatus class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include <common.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HStatus INHERIT HControl

   CLASS VAR winclass INIT "msctls_statusbar32"

   DATA aParts
   DATA nStatusHeight INIT 0
   DATA bDblClick
   DATA bRClick

   METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight)
   METHOD Activate()
   METHOD Init()
   METHOD Notify(lParam)
   METHOD Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, aParts)
   METHOD SetTextPanel(nPart, cText, lRedraw)
   METHOD GetTextPanel(nPart)
   METHOD SetIconPanel(nPart, cIcon, nWidth, nHeight)
   METHOD StatusHeight(nHeight)
   METHOD Resize(xIncrSize)

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint, bRClick, bDblClick, nHeight)

   bSize := IIf(bSize != NIL, bSize, {|o, x, y|o:Move(0, y - ::nStatusHeight, x, ::nStatusHeight)})
   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS)
   ::Super:New(oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint)

   //::nHeight := nHeight
   ::nStatusHeight := IIf(nHeight == NIL, ::nStatusHeight, nHeight)
   ::aParts := aParts
   ::bDblClick := bDblClick
   ::bRClick := bRClick

   ::Activate()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatusWindow(::oParent:handle, ::id)
      ::StatusHeight(::nStatusHeight)
      ::Init()
      /*
      IF __ObjHasMsg(::oParent, "AOFFSET")
         aCoors := hwg_GetWindowRect(::handle)
         ::oParent:aOffset[4] := aCoors[4] - aCoors[2]
      ENDIF
      */
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:Init()

   IF !::lInit
      IF !Empty(::aParts)
         hwg_InitStatus(::oParent:handle, ::handle, Len(::aParts), ::aParts)
      ENDIF
      ::Super:Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:Redefine(oWndParent, nId, cCaption, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor, lTransp, ;
   aParts)

   HB_SYMBOL_UNUSED(cCaption)
   HB_SYMBOL_UNUSED(lTransp)

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0, oFont, bInit, bSize, bPaint, ctooltip, tcolor, bcolor)
   HWG_InitCommonControlsEx()
   ::style := ::nLeft := ::nTop := ::nWidth := ::nHeight := 0
   ::aParts := aParts

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:Notify(lParam)

   LOCAL nCode := hwg_GetNotifyCode(lParam)
   LOCAL nParts := hwg_GetNotifySBParts(lParam) - 1

   SWITCH nCode

   //CASE NM_CLICK

   CASE NM_DBLCLK
      IF hb_IsBlock(::bdblClick)
         Eval(::bdblClick, Self, nParts)
      ENDIF
      EXIT

   CASE NM_RCLICK
      IF hb_IsBlock(::bRClick)
         Eval(::bRClick, Self, nParts)
      ENDIF

   ENDSWITCH

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:StatusHeight(nHeight)

   LOCAL aCoors

   IF nHeight != NIL
      aCoors := hwg_GetWindowRect(::handle)
      IF nHeight != 0
         IF ::lInit .AND. __ObjHasMsg(::oParent, "AOFFSET")
            ::oParent:aOffset[4] -= (aCoors[4] - aCoors[2])
         ENDIF
         hwg_SendMessage(::handle, SB_SETMINHEIGHT, nHeight, 0)
         hwg_SendMessage(::handle, WM_SIZE, 0, 0)
         aCoors := hwg_GetWindowRect(::handle)
      ENDIF
      ::nStatusHeight := (aCoors[4] - aCoors[2]) - 1
      IF __ObjHasMsg(::oParent, "AOFFSET")
         ::oParent:aOffset[4] += (aCoors[4] - aCoors[2])
      ENDIF
   ENDIF

RETURN ::nStatusHeight

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:GetTextPanel(nPart)

   LOCAL ntxtLen
   LOCAL cText := ""

   ntxtLen := hwg_SendMessage(::handle, SB_GETTEXTLENGTH, nPart - 1, 0)
   cText := Replicate(Chr(0), ntxtLen)
   hwg_SendMessage(::handle, SB_GETTEXT, nPart - 1, @cText)

RETURN cText

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:SetTextPanel(nPart, cText, lRedraw)

   //hwg_WriteStatusWindow(::handle, nPart - 1, cText)
   hwg_SendMessage(::handle, SB_SETTEXT, nPart - 1, cText)
   IF lRedraw != NIL .AND. lRedraw
      hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:SetIconPanel(nPart, cIcon, nWidth, nHeight)

   LOCAL oIcon

   DEFAULT nWidth TO 16
   DEFAULT nHeight TO 16
   DEFAULT cIcon TO ""

   IF hb_IsNumeric(cIcon) .OR. At(".", cIcon) == 0
      oIcon := HIcon():addResource(cIcon, nWidth, nHeight)
   ELSE
      oIcon := HIcon():addFile(cIcon, nWidth, nHeight)
   ENDIF
   IF !Empty(oIcon)
      hwg_SendMessage(::handle, SB_SETICON, nPart - 1, oIcon:handle)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HStatus:Resize(xIncrSize)

   LOCAL i

   IF !Empty(::aParts)
      FOR i := 1 TO Len(::aParts)
         ::aParts[i] := Round(::aParts[i] * xIncrSize, 0)
      NEXT
      hwg_InitStatus(::oParent:handle, ::handle, Len(::aParts), ::aParts)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//
