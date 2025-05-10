//
// HWGUI - Harbour Win32 GUI library source code:
// Prg level menu functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "windows.ch"
#include <HBClass.ch>
#include "guilib.ch"

#define MENU_FIRST_ID   32000
#define CONTEXTMENU_FIRST_ID   32900

STATIC _aMenuDef, _oWnd, _aAccel, _nLevel, _Id, _oMenu

CLASS HMenu INHERIT HObject
   DATA handle
   DATA aMenu 
   METHOD New() INLINE Self
   METHOD End() INLINE hwg_DestroyMenu(::handle)
   METHOD Show(oWnd, xPos, yPos, lWnd)
ENDCLASS

METHOD Show(oWnd, xPos, yPos, lWnd) CLASS HMenu
Local aCoor

   oWnd:oPopup := Self
   IF Pcount() == 1 .OR. lWnd == NIL .OR. !lWnd
      IF Pcount() == 1
         aCoor := hwg_GetCursorPos()
         xPos  := aCoor[1]
         yPos  := aCoor[2]
      ENDIF
      hwg_trackmenu(::handle, xPos, yPos, oWnd:handle)
   ELSE
      aCoor := hwg_ClientToScreen(oWnd:handle, xPos, yPos)
      hwg_trackmenu(::handle, aCoor[1], aCoor[2], oWnd:handle)
   ENDIF

RETURN NIL

FUNCTION hwg_CreateMenu
Local hMenu

   IF (hMenu := hwg__CreateMenu()) == 0
      RETURN NIL
   ENDIF

RETURN {{},,, hMenu}

FUNCTION hwg_SetMenu(oWnd, aMenu)

   IF oWnd:type == WND_MDICHILD
      oWnd:menu := aMenu

   ELSEIF oWnd:type == WND_MDI
      IF hwg__SetMenu(oWnd:handle, aMenu[5])
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF

   ELSEIF oWnd:type == WND_MAIN
      IF hwg__SetMenu(oWnd:handle, aMenu[5])
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF

   ELSEIF oWnd:type == WND_CHILD
      IF hwg__SetMenu(oWnd:handle, aMenu[5])
         oWnd:menu := aMenu
      ELSE
         RETURN .F.
      ENDIF

   ENDIF


RETURN .T.

/*
 *  AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, [bItem] [, nPos [, lPos]]) --> aMenuItem
 *
 *  If nPos is omitted, the function adds menu item to the end of menu,
 *  else if lPos is omitted or TRUE, it inserts menu item in nPos position,
 *  else if lPos is FALSE - before item with ID == nPos
 */
FUNCTION hwg_AddMenuItem(aMenu, cItem, nMenuId, lSubMenu, bItem, nPos, lPos)
Local hSubMenu

   IF nPos == NIL
      nPos := Len(aMenu[1]) + 1
      lPos := .T.
   ELSEIF lPos == NIL
      lPos := .F.
   ENDIF
   IF !lPos
      IF (aMenu := hwg_FindMenuItem(aMenu, nMenuId, @nPos)) == NIL
         RETURN NIL
      ENDIF
   ENDIF
   hSubMenu := aMenu[5]
   hSubMenu := hwg__AddMenuItem(hSubMenu, cItem, nPos, .T., nMenuId,, lSubMenu)
   /*
   IF !hwg__AddMenuItem(hSubMenu, cItem, nPos, .T., nMenuId)
      RETURN NIL
   ENDIF
   IF lSubmenu
      IF (hSubMenu := hwg__CreateSubMenu(hSubMenu, nMenuId)) == 0
         RETURN NIL
      ENDIF
   ENDIF
   */
   IF nPos > Len(aMenu[1])
      IF lSubmenu
         AAdd(aMenu[1], {{}, cItem, nMenuId, hSubMenu})
      ELSE
         AAdd(aMenu[1], {bItem, cItem, nMenuId})
      ENDIF
      RETURN ATail(aMenu[1])
   ELSE
      AAdd(aMenu[1], NIL)
      AIns(aMenu[1], nPos)
      IF lSubmenu
         aMenu[1, nPos] := {{}, cItem, nMenuId, hSubMenu}
      ELSE
         aMenu[1, nPos] := {bItem, cItem, nMenuId}
      ENDIF
      RETURN aMenu[1, nPos]
   ENDIF
RETURN NIL

FUNCTION hwg_FindMenuItem(aMenu, nId, nPos)
Local nPos1, aSubMenu
   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1, npos, 3] == nId
         RETURN aMenu
      ELSEIF Len(aMenu[1, npos]) > 4
         IF (aSubMenu := hwg_FindMenuItem(aMenu[1, nPos], nId, @nPos1)) != NIL
            nPos := nPos1
            RETURN aSubMenu
         ENDIF
      ENDIF
      nPos ++
   ENDDO
RETURN NIL

FUNCTION hwg_GetSubMenuHandle(aMenu, nId)
Local nPos
   IF (aMenu := hwg_FindMenuItem(aMenu, nId, nPos)) != NIL
      RETURN aMenu[1, nPos, 5]
   ENDIF
RETURN 0

FUNCTION hwg_BuildMenu(aMenuInit, hWnd, oWnd, nPosParent, lPopup)
Local hMenu, nPos, aMenu

   IF nPosParent == NIL
      IF lPopup == NIL .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := {aMenuInit,,,, hMenu}
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len(aMenuInit[1])
      aMenu := aMenuInit[1, nPosParent]
      //hMenu := hwg__AddMenuItem(hMenu, aMenu[2], nPos + 1, .T., aMenu[3], aMenu[4], .T.)
      hMenu := hwg__AddMenuItem(hMenu, aMenu[2][1], nPos + 1, .T., aMenu[3], aMenu[4], .T.)
      /*
      hwg__AddMenuItem(hMenu, aMenu[2], nPos + 1, .T., aMenu[3])
      hMenu := hwg__CreateSubMenu(hMenu, aMenu[3])
      */
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF hb_IsArray(aMenu[1, nPos, 1])
         hwg_BuildMenu(aMenu,,, nPos)
      ELSE
         //hwg__AddMenuItem(hMenu, aMenu[1, npos, 2], nPos, .T., aMenu[1, nPos, 3], ;
         //          aMenu[1, npos, 4], .F.)
         hwg__AddMenuItem(hMenu, aMenu[1, npos, 2][1], nPos, .T., aMenu[1, nPos, 3], ;
                   aMenu[1, npos, 4], .F.)
      ENDIF
      nPos ++
   ENDDO
   IF hWnd != NIL .AND. oWnd != NIL
      hwg_SetMenu(oWnd, aMenu)
   ELSEIF _oMenu != NIL
      _oMenu:handle := aMenu[5]
      _oMenu:aMenu := aMenu
   ENDIF
RETURN NIL

FUNCTION hwg_BeginMenu(oWnd, nId, cTitle)
Local aMenu, i
   IF oWnd != NIL
      _aMenuDef := {}
      _aAccel   := {}
      _oWnd     := oWnd
      _oMenu    := NIL
      _nLevel   := 0
      _Id       := IIf(nId == NIL, MENU_FIRST_ID, nId)
   ELSE
      nId   := IIf(nId == NIL, ++_Id, nId)
      aMenu := _aMenuDef
      FOR i := 1 TO _nLevel
         aMenu := Atail(aMenu)[1]
      NEXT
      _nLevel++
      //AAdd(aMenu, {{}, cTitle, nId, .T.})
      AAdd(aMenu, {{}, {cTitle, NIL}, nId, .T.})
   ENDIF
RETURN .T.

FUNCTION hwg_ContextMenu()
   _aMenuDef := {}
   _oWnd := NIL
   _nLevel := 0
   _Id := CONTEXTMENU_FIRST_ID
   _oMenu := HMenu():New()
RETURN _oMenu

FUNCTION hwg_EndMenu()
   IF _nLevel > 0
      _nLevel --
   ELSE
      hwg_BuildMenu(Aclone(_aMenuDef), IIf(_oWnd != NIL, _oWnd:handle, NIL), ;
                   _oWnd,, IIf(_oWnd != NIL, .F., .T.))
      IF _oWnd != NIL .AND. _aAccel != NIL .AND. !Empty(_aAccel)
         _oWnd:hAccel := hwg_CreateAcceleratorTable(_aAccel)
      ENDIF
      _aMenuDef := NIL
      _aAccel   := NIL
      _oWnd     := NIL
      _oMenu    := NIL
   ENDIF
RETURN .T.

//FUNCTION hwg_DefineMenuItem(cItem, nId, bItem, lDisabled, accFlag, accKey)
FUNCTION hwg_DefineMenuItem(cItem, nId, bItem, lDisabled, accFlag, accKey, cMessage)
Local aMenu, i
   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL .AND. cItem != NIL, ++_Id, nId)
   //AAdd(aMenu, {bItem, cItem, nId, IIf(lDisabled == NIL, .T., !lDisabled)})
   AAdd(aMenu, {bItem, {cItem, cMessage}, nId, IIf(lDisabled == NIL, .T., !lDisabled)})
   IF accFlag != NIL .AND. accKey != NIL
      AAdd(_aAccel, {accFlag, accKey, nId})
   ENDIF
RETURN .T.
