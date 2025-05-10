//
// HWGUI - Harbour Win32 GUI library source code:
// HToolButton class
//
// Copyright 2004 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HToolButton INHERIT HObject

   DATA Name
   DATA id
   DATA nBitIp INIT -1
   DATA bState INIT TBSTATE_ENABLED
   DATA bStyle INIT 0x0000
   DATA tooltip
   DATA aMenu INIT {}
   DATA hMenu
   DATA Title
   DATA lEnabled INIT .T. HIDDEN
   DATA lChecked INIT .F. HIDDEN
   DATA lPressed INIT .F. HIDDEN
   DATA bClick
   DATA oParent
   //DATA oFont // not implemented

   METHOD New(oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu)
   METHOD Enable() INLINE ::oParent:EnableButton(::id, .T.)
   METHOD Disable() INLINE ::oParent:EnableButton(::id, .F.)
   METHOD Show() INLINE hwg_SendMessage(::oParent:handle, TB_HIDEBUTTON, INT(::id), hwg_MAKELONG(0, 0))
   METHOD Hide() INLINE hwg_SendMessage(::oParent:handle, TB_HIDEBUTTON, INT(::id), hwg_MAKELONG(1, 0))
   METHOD Enabled(lEnabled) SETGET
   METHOD Checked(lCheck) SETGET
   METHOD Pressed(lPressed) SETGET
   METHOD onClick()
   METHOD Caption(cText) SETGET

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:New(oParent, cName, nBitIp, nId, bState, bStyle, cText, bClick, ctip, aMenu)

   ::Name := cName
   ::iD := nId
   ::title := cText
   ::nBitIp := nBitIp
   ::bState := bState
   ::bStyle := bStyle
   ::tooltip := ctip
   ::bClick := bClick
   ::aMenu := amenu
   ::oParent := oParent
   __objAddData(::oParent, cName)
   ::oParent:&(cName) := Self

   //::oParent:oParent:AddEvent(BN_CLICKED, Self, {||::ONCLICK()}, , "click")

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:Caption(cText)

   IF cText != NIL
      ::Title := cText
      hwg_ToolBar_SetButtonInfo(::oParent:handle, ::id, cText)
   ENDIF

RETURN ::Title

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:onClick()

   IF hb_IsBlock(::bClick)
      Eval(::bClick, self, ::id)
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:Enabled(lEnabled)

   IF lEnabled != NIL
      IF lEnabled
         ::enable()
      ELSE
         ::disable()
      ENDIF
      ::lEnabled := lEnabled
   ENDIF

RETURN ::lEnabled

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:Pressed(lPressed)

   LOCAL nState

   IF lPressed != NIL
      nState := hwg_SendMessage(::oParent:handle, TB_GETSTATE, INT(::id), 0)
      hwg_SendMessage(::oParent:handle, TB_SETSTATE, INT(::id), ;
         hwg_MAKELONG(IIf(lPressed, HWG_BITOR(nState, TBSTATE_PRESSED), ;
         nState - HWG_BITAND(nState, TBSTATE_PRESSED)), 0))
      ::lPressed := lPressed
   ENDIF

RETURN ::lPressed

//-------------------------------------------------------------------------------------------------------------------//

METHOD HToolButton:Checked(lcheck)

   LOCAL nState

   IF lCheck != NIL
      nState := hwg_SendMessage(::oParent:handle, TB_GETSTATE, INT(::id), 0)
      hwg_SendMessage(::oParent:handle, TB_SETSTATE, INT(::id), ;
         hwg_MAKELONG(IIf(lCheck, HWG_BITOR(nState, TBSTATE_CHECKED), ;
         nState - HWG_BITAND(nState, TBSTATE_CHECKED)), 0))
      ::lChecked := lCheck
   ENDIF

RETURN ::lChecked

//-------------------------------------------------------------------------------------------------------------------//
