//
// HWGUI - Harbour Win32 GUI library source code:
// HAnimation class
//
// Copyright 2004 Marcos Antonio Gambeta <marcos_gambeta@hotmail.com>
// www - http://geocities.yahoo.com.br/marcosgambeta/
//

#include <hbclass.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HAnimation INHERIT HControl

   CLASS VAR winclass INIT "SysAnimate32"

   DATA cFileName
   DATA xResID

   METHOD New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cFilename, lAutoPlay, lCenter, lTransparent, ;
      xResID)
   METHOD Activate()
   METHOD Init()
   METHOD Open(cFileName)
   METHOD Play(nFrom, nTo, nRep)
   METHOD Seek(nFrame)
   METHOD Stop()
   METHOD Close()
   METHOD Destroy()
   METHOD End() INLINE ::Destroy()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cFilename, lAutoPlay, lCenter, lTransparent, ;
   xResID)

   nStyle := hwg_BitOr(IIf(nStyle == NIL, 0, nStyle), WS_CHILD + WS_VISIBLE)
   nStyle := nStyle + IIf(lAutoPlay == NIL .OR. lAutoPlay, ACS_AUTOPLAY, 0)
   nStyle := nStyle + IIf(lCenter == NIL .OR. !lCenter, 0, ACS_CENTER)
   nStyle := nStyle + IIf(lTransparent == NIL .OR. !lTransparent, 0, ACS_TRANSPARENT)
   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight)
   ::xResID := xResID
   ::cFilename := cFilename
   ::brush := ::oParent:brush
   ::bColor := ::oParent:bColor
   HWG_InitCommonControlsEx()
   ::Activate()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_Animate_Create(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      ::Init()
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Init()

   IF !::lInit
      ::Super:Init()
      IF ::xResID != NIL
         hwg_Animate_OpenEx(::handle, hwg_GetResources(), ::xResID)
      ELSEIF ::cFileName != NIL
         hwg_Animate_Open(::handle, ::cFileName)
      ENDIF
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Open(cFileName)

   IF cFileName != NIL
      ::cFileName := cFileName
      hwg_Animate_Open(::handle, ::cFileName)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Play(nFrom, nTo, nRep)

   nFrom := IIf(nFrom == NIL, 0, nFrom)
   nTo := IIf(nTo == NIL, -1, nTo)
   nRep := IIf(nRep == NIL, -1, nRep)
   hwg_Animate_Play(::handle, nFrom, nTo, nRep)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Seek(nFrame)

   nFrame := IIf(nFrame == NIL, 0, nFrame)
   hwg_Animate_Seek(::handle, nFrame)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Stop()

   hwg_Animate_Stop(::handle)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Close()

   hwg_Animate_Close(::handle)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HAnimation:Destroy()

   hwg_Animate_Destroy(::handle)

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//
