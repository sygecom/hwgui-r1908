//
// HWGUI - Harbour Win32 GUI library source code:
// HToolBarEx class
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HToolBarEx INHERIT HToolBar

   //METHOD onevent()
   METHOD init()
   METHOD ExecuteTool(nid)
   DESTRUCTOR MyDestructor

END CLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolBarEx:init()

   ::Super:init()
   hwg_SetWindowObject(::handle, Self)
   hwg_SetToolHandle(::handle)
   hwg_Sethook()

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

#if 0
METHOD HToolBarEx:onEvent(msg, w, l)

   LOCAL nId
   LOCAL nPos

   IF msg == WM_KEYDOWN
      RETURN -1
   ELSEIF msg == WM_KEYUP
      hwg_UnsetHook()
      RETURN -1
   ENDIF

RETURN 0
#endif

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolBarEx:ExecuteTool(nid)

   IF nid > 0
      hwg_SendMessage(::oParent:handle, WM_COMMAND, hwg_MAKEWPARAM(nid, BN_CLICKED), ::handle)
      RETURN 0
   ENDIF

RETURN -200

//-------------------------------------------------------------------------------------------------------------------//

/*
STATIC FUNCTION IsAltShift(lAlt)

   LOCAL cKeyb := hwg_GetKeyboardState()

   IF lAlt == NIL
      lAlt := .T.
   ENDIF

RETURN (lAlt .AND. (Asc(SubStr(cKeyb, VK_MENU + 1, 1)) >= 128))
*/

//-------------------------------------------------------------------------------------------------------------------//

PROCEDURE MyDestructor() CLASS HToolBarEx

   hwg_UnsetHook()

RETURN

//-------------------------------------------------------------------------------------------------------------------//
