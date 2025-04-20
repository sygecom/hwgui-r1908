//
// $Id: hcontrol.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HControl, HStatus, HStatic, HButton, HGroup, HLine classes
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//
// ButtonEx class
//
// Copyright 2008 Luiz Rafael Culik Guimaraes <luiz at xharbour.com.br >
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include "hwgui.ch"

REQUEST HWG_ENDWINDOW

#define CONTROL_FIRST_ID   34000

//- HControl

CLASS HControl INHERIT HCustomWindow

   DATA id
   DATA tooltip
   DATA lInit    INIT .F.
   //DATA name // TODO: duplicated
   DATA Anchor          INIT 0
   DATA   xName           HIDDEN
   ACCESS Name INLINE ::xName
   ASSIGN Name(cName) INLINE ::AddName(cName)


   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor)
   METHOD Init()
   METHOD AddName(cName) HIDDEN
   METHOD SetColor(tcolor, bcolor, lRepaint)
   METHOD NewId()

   METHOD Disable() INLINE hwg_EnableWindow(::handle, .F.)
   METHOD Enable() INLINE hwg_EnableWindow(::handle, .T.)
   METHOD IsEnabled() INLINE hwg_IsWindowEnabled(::Handle)
   METHOD SetFocus() INLINE hwg_EnableWindow(::handle, .T.)
   //METHOD Move(x1, y1, width, height)
   METHOD Move(x1, y1, width, height, lMoveParent)
   /*
   METHOD GetText() INLINE hwg_GetWindowText(::handle)
   METHOD SetText(c) INLINE hwg_SetWindowText(::Handle, c)
   */
   METHOD onAnchor(x, y, w, h)
   METHOD End()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor) CLASS HControl

   ::oParent := IIf(oWndParent == NIL, ::oDefaultParent, oWndParent)
   ::id      := IIf(nId == NIL, ::NewId(), nId)
   ::style   := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_VISIBLE + WS_CHILD)
   ::oFont   := oFont
   ::nLeft   := nLeft
   ::nTop    := nTop
   ::nWidth  := nWidth
   ::nHeight := nHeight
   ::bInit   := bInit
   ::bSize   := bSize
   ::bPaint  := bPaint
   ::tooltip := ctoolt
   ::SetColor(tcolor, bcolor)

   ::oParent:AddControl(Self)

RETURN Self

METHOD NewId() CLASS HControl
Local nId := CONTROL_FIRST_ID + Len(::oParent:aControls)

   IF AScan(::oParent:aControls, {|o|o:id == nId}) != 0
      nId --
      DO WHILE nId >= CONTROL_FIRST_ID .AND. AScan(::oParent:aControls, {|o|o:id == nId}) != 0
         nId --
      ENDDO
   ENDIF
RETURN nId

METHOD AddName(cName) CLASS HControl

   IF !Empty(cName) .AND. HB_IsChar(cName) .AND. ! ":" $ cName .AND. ! "[" $ cName
      ::xName := cName
			__objAddData(::oParent, cName)
	    ::oParent: & (cName) := Self
   ENDIF	    
   
RETURN NIL

METHOD INIT() CLASS HControl
Local o

   IF !::lInit
      hwg_AddToolTip(::oParent:handle, ::handle, ::tooltip)
      IF ::oFont != NIL
         hwg_SetCtrlFont(::handle, ::oFont:handle)
      ELSEIF ::oParent:oFont != NIL
         hwg_SetCtrlFont(::handle, ::oParent:oFont:handle)
      ENDIF
      IF HB_IsBlock(::bInit)
         Eval(::bInit, Self)
      ENDIF
      o := ::oParent
      DO WHILE o != NIL .AND. !__ObjHasMsg(o, "LACTIVATED")
         o := o:oParent
      ENDDO
      IF ::tcolor != NIL
            hwg_SETFGCOLOR(::handle, ::tcolor)
      ENDIF

      
      IF o != NIL .AND. o:lActivated
         hwg_ShowAll(o:handle)
      ENDIF
      ::lInit := .T.
   ENDIF
RETURN NIL

METHOD SetColor(tcolor, bcolor, lRepaint) CLASS HControl

   IF tcolor != NIL
      ::tcolor  := tcolor
      IF bColor == NIL .AND. ::bColor == NIL
         // bColor := hwg_GetSysColor(COLOR_3DFACE)
      ENDIF
   ENDIF

   IF bcolor != NIL
      ::bcolor  := bcolor
      IF ::brush != NIL
         ::brush:Release()
      ENDIF
      ::brush := HBrush():Add(bcolor)
   ENDIF

   IF lRepaint != NIL .AND. lRepaint
      hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)
   ENDIF

RETURN NIL

METHOD Move(x1, y1, width, height, lMoveParent) CLASS HControl
Local lMove := .F., lSize := .F.

   IF x1 != NIL .AND. x1 != ::nLeft
      ::nLeft := x1
      lMove := .T.
   ENDIF   
   IF y1 != NIL .AND. y1 != ::nTop
      ::nTop := y1
      lMove := .T.
   ENDIF
   IF width != NIL .AND. width != ::nWidth
      ::nWidth := width
      lSize := .T.
   ENDIF   
   IF height != NIL .AND. height != ::nHeight
      ::nHeight := height
      lSize := .T.
   ENDIF
   IF lMove .OR. lSize
      hwg_MoveWidget(::handle, IIf(lMove, ::nLeft, NIL), IIf(lMove, ::nTop, NIL), ;
          IIf(lSize, ::nWidth, NIL), IIf(lSize, ::nHeight, NIL), lMoveParent)
   ENDIF
RETURN NIL

METHOD End() CLASS HControl

   ::Super:End()
   IF ::tooltip != NIL
      // hwg_DelToolTip(::oParent:handle, ::handle)
      ::tooltip := NIL
   ENDIF
RETURN NIL

METHOD onAnchor(x, y, w, h) CLASS HControl
   LOCAL nAnchor, nXincRelative, nYincRelative, nXincAbsolute, nYincAbsolute
   LOCAL x1, y1, w1, h1, x9, y9, w9, h9

   nAnchor := ::anchor
   x9 := ::nLeft
   y9 := ::nTop
   w9 := ::nWidth
   h9 := ::nHeight

   x1 := ::nLeft
   y1 := ::nTop
   w1 := ::nWidth
   h1 := ::nHeight
  *- calculo relativo
   nXincRelative :=  w / x
   nYincRelative :=  h / y
    *- calculo ABSOLUTE
   nXincAbsolute := (w - x)
   nYincAbsolute := (h - y)

   IF nAnchor >= ANCHOR_VERTFIX
    *- vertical fixed center
      nAnchor := nAnchor - ANCHOR_VERTFIX
      y1 := y9 + Int((h - y) * ((y9 + h9 / 2) / y))
   ENDIF                             
   IF nAnchor >= ANCHOR_HORFIX
    *- horizontal fixed center
      nAnchor := nAnchor - ANCHOR_HORFIX
      x1 := x9 + Int((w - x) * ((x9 + w9 / 2) / x))
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTREL
      && relative - RIGHT RELATIVE
      nAnchor := nAnchor - ANCHOR_RIGHTREL
      x1 := w - Int((x - x9 - w9) * nXincRelative) - w9
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMREL
      && relative - BOTTOM RELATIVE
      nAnchor := nAnchor - ANCHOR_BOTTOMREL
      y1 := h - Int((y - y9 - h9) * nYincRelative) - h9
   ENDIF
   IF nAnchor >= ANCHOR_LEFTREL
      && relative - LEFT RELATIVE
      nAnchor := nAnchor - ANCHOR_LEFTREL
      IF x1 != x9
         w1 := x1 - (Int(x9 * nXincRelative)) + w9
      ENDIF
      x1 := Int(x9 * nXincRelative)
   ENDIF
   IF nAnchor >= ANCHOR_TOPREL
      && relative  - TOP RELATIVE
      nAnchor := nAnchor - ANCHOR_TOPREL
      IF y1 != y9
         h1 := y1 - (Int(y9 * nYincRelative)) + h9
      ENDIF
      y1 := Int(y9 * nYincRelative)
   ENDIF
   IF nAnchor >= ANCHOR_RIGHTABS
      && Absolute - RIGHT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_RIGHTABS
      IF x1 != x9
         w1 := x1 - (x9 +  Int(nXincAbsolute)) + w9
      ENDIF
      x1 := x9 +  Int(nXincAbsolute)
   ENDIF
   IF nAnchor >= ANCHOR_BOTTOMABS
      && Absolute - BOTTOM ABSOLUTE
      nAnchor := nAnchor - ANCHOR_BOTTOMABS
      IF y1 != y9
         h1 := y1 - (y9 +  Int(nYincAbsolute)) + h9
      ENDIF
      y1 := y9 +  Int(nYincAbsolute)
   ENDIF
   IF nAnchor >= ANCHOR_LEFTABS
      && Absolute - LEFT ABSOLUTE
      nAnchor := nAnchor - ANCHOR_LEFTABS
      IF x1 != x9
         w1 := x1 - x9 + w9
      ENDIF
      x1 := x9
   ENDIF
   IF nAnchor >= ANCHOR_TOPABS
      && Absolute - TOP ABSOLUTE
      //nAnchor := nAnchor - 1
      IF y1 != y9
         h1 := y1 - y9 + h9
      ENDIF
      y1 := y9
   ENDIF
   hwg_InvalidateRect(::oParent:handle, 1, ::nLeft, ::nTop, ::nWidth, ::nHeight)
   ::Move(::handle, x1, y1, w1, h1)
   ::nLeft := x1
   ::nTop := y1
   ::nWidth := w1
   ::nHeight := h1
   hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE)

   RETURN NIL



//- HStatus
CLASS HStatus INHERIT HControl

   CLASS VAR winclass   INIT "msctls_statusbar32"
   DATA aParts
   METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint)
   METHOD Activate()
   METHOD Init()
   method SetText(t, n) inline  hwg_STATUSBARSETTEXT(::handle, n, t)

ENDCLASS

METHOD New(oWndParent, nId, nStyle, oFont, aParts, bInit, bSize, bPaint) CLASS HStatus

   bSize := IIf(bSize != NIL, bSize, {|o, x, y|hwg_MoveWindow(o:handle, 0, y - 20, x, y)})
   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE + WS_OVERLAPPED + WS_CLIPSIBLINGS)
   ::Super:New(oWndParent, nId, nStyle, 0, 0, 0, 0, oFont, bInit, bSize, bPaint)

   ::aParts  := aParts
   ::Activate()

RETURN Self

METHOD Activate() CLASS HStatus

   //LOCAL aCoors // variable not used

   IF !Empty(::oParent:handle)

      ::handle := hwg_CreateStatusWindow(::oParent:handle, ::id)

      ::Init()
//      IF __ObjHasMsg(::oParent, "AOFFSET")
//         aCoors := hwg_GetWindowRect(::handle)
//         ::oParent:aOffset[4] := aCoors[4] - aCoors[2]
//      ENDIF
   ENDIF
RETURN NIL

METHOD Init() CLASS HStatus
   IF !::lInit
      ::Super:Init()
   ENDIF
RETURN  NIL

//- HStatic

CLASS HStatic INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor, lTransp)
   METHOD Activate()
   METHOD SetValue(value) INLINE hwg_static_SetText(::handle, value)
   METHOD SetText(value) INLINE hwg_static_SetText(::handle, value)
ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor, lTransp) CLASS HStatic

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title   := cCaption
   IF lTransp != NIL .AND. lTransp
      ::extStyle += WS_EX_TRANSPARENT
   ENDIF

   ::Activate()

RETURN Self

METHOD Activate() CLASS HStatic
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle, ::title)
      ::Init()
   ENDIF
RETURN NIL

//- HButton

CLASS HButton INHERIT HControl

   CLASS VAR winclass   INIT "BUTTON"
   DATA  bClick
   
   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, oFont, ;
                  bInit, bSize, bPaint, bClick, ctoolt, tcolor, bcolor) CLASS HButton

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_PUSHBUTTON)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, IIf(nWidth == NIL, 90, nWidth), ;
              IIf(nHeight == NIL, 30, nHeight), oFont, bInit, ;
              bSize, bPaint, ctoolt, tcolor, bcolor)

   ::title   := cCaption
   ::Activate()

   IF ::id == IDOK
      bClick := {||::oParent:lResult := .T., ::oParent:Close()}
   ELSEIF ::id == IDCANCEL
      bClick := {||::oParent:Close()}
   ENDIF
   IF bClick != NIL
      // ::oParent:AddEvent(0, ::id, bClick)
      ::bClick := bClick
      hwg_SetSignal(::handle, "clicked", WM_LBUTTONUP, 0, 0)
   ENDIF

RETURN Self

METHOD Activate() CLASS HButton
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

#if 0 // old code for reference (to be deleted)
METHOD onEvent(msg, wParam, lParam) CLASS HButton

   IF msg == WM_LBUTTONUP
      IF ::bClick != NIL
         Eval(::bClick, Self)
      ENDIF
   ENDIF

RETURN  NIL
#else
METHOD onEvent(msg, wParam, lParam) CLASS HButton

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   SWITCH msg
   CASE WM_LBUTTONUP
      IF ::bClick != NIL
         Eval(::bClick, Self)
      ENDIF
   ENDSWITCH

RETURN  NIL
#endif

CLASS HButtonEX INHERIT HButton

   Data hBitmap
   DATA hIcon

   //METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
   //cCaption, oFont, bInit, bSize, bPaint, cTooltip, tcolor, ;
   //bColor, lTransp, hBitmap, hIcon)
   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
               cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
               tcolor, bColor, hBitmap, iStyle, hicon, Transp)

METHOD Activate
END CLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
               cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
               tcolor, bColor, hBitmap, iStyle, hicon, Transp) CLASS HButtonEx
               
   HB_SYMBOL_UNUSED(iStyle)
   HB_SYMBOL_UNUSED(Transp)


   ::hBitmap                            := hBitmap
   ::hIcon                              := hIcon

   ::super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, ;
                cCaption, oFont, bInit, bSize, bPaint, bClick, cTooltip, ;
                tcolor, bColor)

RETURN Self

METHOD Activate CLASS HButtonEX
   IF !Empty(::oParent:handle)
      IF !Empty(::hBitmap)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title, ::hBitmap)
      ELSEIF !Empty(::hIcon)
            ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title, ::hIcon)
      ELSE
            ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title, NIL)
      ENDIF
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

//- HGroup

CLASS HGroup INHERIT HControl

   CLASS VAR winclass   INIT "BUTTON"
   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
                  oFont, bInit, bSize, bPaint, tcolor, bcolor)
   METHOD Activate()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
                  oFont, bInit, bSize, bPaint, tcolor, bcolor) CLASS HGroup

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), BS_GROUPBOX)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint,, tcolor, bcolor)

   ::title   := cCaption
   ::Activate()

RETURN Self

METHOD Activate() CLASS HGroup
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateButton(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::title)
      ::Init()
   ENDIF
RETURN NIL

// hline

CLASS HLine INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA lVert

   METHOD New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize)
   METHOD Activate()

ENDCLASS


METHOD New(oWndParent, nId, lVert, nLeft, nTop, nLength, bSize) CLASS hline

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop,,,,, bSize, {|o, lp|o:Paint(lp)})

   ::title := ""
   ::lVert := IIf(lVert == NIL, .F., lVert)
   IF ::lVert
      ::nWidth  := 10
      ::nHeight := IIf(nLength == NIL, 20, nLength)
   ELSE
      ::nWidth  := IIf(nLength == NIL, 20, nLength)
      ::nHeight := 10
   ENDIF

   ::Activate()

RETURN Self

METHOD Activate() CLASS hline
   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateSep(::oParent:handle, ::lVert, ::nLeft, ::nTop, ;
                                 ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL
