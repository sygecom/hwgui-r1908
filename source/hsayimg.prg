//
// $Id: hsayimg.prg 1899 2012-09-19 12:35:34Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HSayImage class
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"

#define STM_SETIMAGE        370    // 0x0172
#define TRANSPARENT 1

//- HSayImage

CLASS HSayImage INHERIT HControl

CLASS VAR winclass   INIT "STATIC"
   DATA  oImage
   DATA bClick, bDblClick

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, ;
               bSize, ctooltip, bClick, bDblClick)
   METHOD Redefine(oWndParent, nId, bInit, bSize, ctooltip)
   METHOD Activate()
   METHOD END() INLINE (::Super:END(), IIf(::oImage != NIL, ::oImage:Release(), ::oImage := NIL), ::oImage := NIL)
   METHOD onClick()
   METHOD onDblClick()

ENDCLASS

METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, bInit, ;
            bSize, ctooltip, bClick, bDblClick) CLASS HSayImage

   nStyle := hwg_BitOr(nStyle, IIf(hb_IsBlock(bClick) .OR. hb_IsBlock(bDblClick), SS_NOTIFY , 0))
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop,               ;
              IIf(nWidth != NIL, nWidth, 0), IIf(nHeight != NIL, nHeight, 0),, ;
              bInit, bSize,, ctooltip)

   ::title   := ""

   ::bClick := bClick
   ::oParent:AddEvent(STN_CLICKED, Self, {||::onClick()})

   ::bDblClick := bDblClick
   ::oParent:AddEvent(STN_DBLCLK, Self, {||::onDblClick()})

   RETURN Self

METHOD Redefine(oWndParent, nId, bInit, bSize, ctooltip) CLASS HSayImage

   ::Super:New(oWndParent, nId, 0, 0, 0, 0, 0,, bInit, bSize,, ctooltip)

   RETURN Self

METHOD Activate() CLASS HSayImage

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ;
                                ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight, ::extStyle)
      ::Init()
   ENDIF
   RETURN NIL

METHOD onClick() CLASS HSayImage
   IF hb_IsBlock(::bClick)
      ::oParent:lSuspendMsgsHandling := .T.
      Eval(::bClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF
   RETURN NIL

METHOD onDblClick() CLASS HSayImage
   IF hb_IsBlock(::bDblClick)
      ::oParent:lSuspendMsgsHandling := .T.
      Eval(::bDblClick, Self, ::id)
      ::oParent:lSuspendMsgsHandling := .F.
   ENDIF
   RETURN NIL
