//
// $Id: hprogres.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HProgressBar class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//
// Copyright 2008 Luiz Rafal Culik Guimaraes <luiz at xharbour.com.br>
// port for linux version
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HProgressBar INHERIT HControl

   CLASS VAR winclass   INIT "ProgressBar"
   DATA  maxPos
   DATA  lNewBox
   DATA  nCount INIT 0
   DATA  nLimit

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip)
   METHOD NewBox(cTitle, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bExit, bInit, bSize, bPaint, ctooltip)
   METHOD Activate()
   METHOD Increment() INLINE hwg_UpdateProgressBar(::handle)
   METHOD Step()
   METHOD Set(cTitle, nPos)
   METHOD Close()

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bInit, bSize, bPaint, ctooltip) CLASS HProgressBar

   ::Super:New(oWndParent, nId,, nLeft, nTop, nWidth, nHeight,, bInit, bSize, bPaint, ctooltip)

   ::maxPos  := IIf(maxPos == NIL, 20, maxPos)
   ::lNewBox := .F.
   ::nLimit := IIf(nRange != NIL, Int(nRange / ::maxPos), 1)

   ::Activate()

RETURN Self

METHOD NewBox(cTitle, nLeft, nTop, nWidth, nHeight, maxPos, nRange, bExit) CLASS HProgressBar

   // ::classname := "HPROGRESSBAR"
   ::style   := WS_CHILD+WS_VISIBLE
   nWidth := IIf(nWidth == NIL, 220, nWidth)
   nHeight := IIf(nHeight == NIL, 60, nHeight)
   nLeft   := IIf(nLeft == NIL, 0, nLeft)
   nTop    := IIf(nTop == NIL, 0, nTop)
   nWidth  := IIf(nWidth == NIL, 220, nWidth)
   nHeight := IIf(nHeight == NIL, 60, nHeight)
   ::nLeft := 20
   ::nTop  := 25
   ::nWidth  := nWidth-40
   ::nheight  := 20
   ::maxPos  := IIf(maxPos == NIL, 20, maxPos)
   ::lNewBox := .T.
   ::nLimit := IIf(nRange != NIL, Int(nRange / ::maxPos), 1)

   INIT DIALOG ::oParent TITLE cTitle       ;
        AT nLeft, nTop SIZE nWidth, nHeight   ;
        STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + IIf(nTop == 0, DS_CENTER, 0) + DS_SYSMODAL

   IF bExit != NIL
      ::oParent:bDestroy := bExit
   ENDIF

   ACTIVATE DIALOG ::oParent NOMODAL

   ::id := ::NewId()
   ::Activate()
   ::oParent:AddControl(Self)

RETURN Self

METHOD Activate CLASS HProgressBar

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateProgressBar(::oParent:handle, ::maxPos, ;
                  ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF
RETURN NIL

METHOD Step()

   ::nCount ++
   IF ::nCount == ::nLimit
      ::nCount := 0
      hwg_UpdateProgressBar(::handle)
   ENDIF

RETURN NIL

METHOD Set(cTitle, nPos) CLASS HProgressBar

   IF cTitle != NIL
      hwg_SetWindowText(::oParent:handle, cTitle)
   ENDIF
   IF nPos != NIL
      hwg_SetProgressBar(::handle, nPos)
   ENDIF

RETURN NIL

METHOD Close()

   HWG_DestroyWindow(::handle)
   IF ::lNewBox
      EndDialog(::oParent:handle)
   ENDIF

RETURN NIL

