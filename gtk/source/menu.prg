//
// $Id: menu.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Prg level menu functions
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

#define  MENU_FIRST_ID   32000
#define  CONTEXTMENU_FIRST_ID   32900
#define  FLAG_DISABLED   1
#define  FLAG_CHECK      2

STATIC _aMenuDef, _oWnd, _aAccel, _nLevel, _Id, _oMenu, _oBitmap

CLASS HMenu INHERIT HObject
   DATA handle
   DATA aMenu 
   METHOD New() INLINE Self
   METHOD End() INLINE hwg_DestroyMenu(::handle)
   METHOD Show( oWnd,xPos,yPos,lWnd )
ENDCLASS

METHOD Show( oWnd,xPos,yPos,lWnd ) CLASS HMenu
Local aCoor
/*
   oWnd:oPopup := Self
   IF Pcount() == 1 .OR. lWnd == NIL .OR. !lWnd
      IF Pcount() == 1
         aCoor := hwg_GetCursorPos()
         xPos  := aCoor[1]
         yPos  := aCoor[2]
      ENDIF
      hwg_trackmenu( ::handle,xPos,yPos,oWnd:handle )
   ELSE
      aCoor := hwg_ClientToScreen( oWnd:handle,xPos,yPos )
      hwg_trackmenu( ::handle,aCoor[1],aCoor[2],oWnd:handle )
   ENDIF
*/
Return NIL

Function hwg_CreateMenu
Local hMenu

   IF ( Empty(hMenu := hwg__CreateMenu()) )
      Return NIL
   ENDIF

Return { {},,, hMenu }

Function hwg_SetMenu( oWnd, aMenu )

   IF !Empty(oWnd:handle)
      IF hwg__SetMenu( oWnd:handle, aMenu[5] )
         oWnd:menu := aMenu
      ELSE
         Return .F.
      ENDIF
   ELSE
      oWnd:menu := aMenu
   ENDIF

Return .T.

/*
 *  AddMenuItem( aMenu,cItem,nMenuId,lSubMenu,[bItem] [,nPos] ) --> aMenuItem
 *
 *  If nPos is omitted, the function adds menu item to the end of menu,
 *  else it inserts menu item in nPos position.
 */
Function hwg_AddMenuItem( aMenu,cItem,nMenuId,lSubMenu,bItem,nPos )
Local hSubMenu

   IF nPos == NIL
      nPos := Len(aMenu[1]) + 1
   ENDIF

   hSubMenu := aMenu[5]
   hSubMenu := hwg__AddMenuItem( hSubMenu, cItem, nPos-1, hwg_GetActiveWindow(), nMenuId,,lSubMenu )

   IF nPos > Len(aMenu[1])
      IF lSubmenu
         AAdd(aMenu[1], {{}, cItem, nMenuId, 0, hSubMenu})
      ELSE
         AAdd(aMenu[1], {bItem, cItem, nMenuId, 0, hSubMenu})
      ENDIF
      Return ATail( aMenu[1] )
   ELSE
      AAdd(aMenu[1], NIL)
      Ains( aMenu[1],nPos )
      IF lSubmenu
         aMenu[1,nPos] := { {},cItem,nMenuId, 0,hSubMenu }
      ELSE
         aMenu[1,nPos] := { bItem,cItem,nMenuId, 0,hSubMenu }
      ENDIF
      Return aMenu[1,nPos]
   ENDIF

Return NIL

Function hwg_FindMenuItem( aMenu, nId, nPos )
Local nPos1, aSubMenu
   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF aMenu[1,npos, 3] == nId
         Return aMenu
      ELSEIF HB_IsArray( aMenu[1,npos, 1] )
         IF ( aSubMenu := hwg_FindMenuItem( aMenu[1,nPos] , nId, @nPos1 ) ) != NIL
            nPos := nPos1
            Return aSubMenu
         ENDIF
      ENDIF
      nPos ++
   ENDDO
Return NIL

Function hwg_GetSubMenuHandle(aMenu, nId)
Local aSubMenu := hwg_FindMenuItem( aMenu, nId )

Return IIf(aSubMenu == NIL, 0, aSubMenu[5])

Function hwg_BuildMenu( aMenuInit, hWnd, oWnd, nPosParent,lPopup )
Local hMenu, nPos, aMenu, i, oBmp

   IF nPosParent == NIL   
      IF lPopup == NIL .OR. !lPopup
         hMenu := hwg__CreateMenu()
      ELSE
         hMenu := hwg__CreatePopupMenu()
      ENDIF
      aMenu := { aMenuInit,,,,hMenu }
   ELSE
      hMenu := aMenuInit[5]
      nPos := Len(aMenuInit[1])
      aMenu := aMenuInit[1,nPosParent]
      hMenu := hwg__AddMenuItem( hMenu, aMenu[2], nPos+1, hWnd, aMenu[3],aMenu[4],.T. )
      IF Len(aMenu) < 5
         AAdd(aMenu, hMenu)
      ELSE
         aMenu[5] := hMenu
      ENDIF
   ENDIF

   nPos := 1
   DO WHILE nPos <= Len(aMenu[1])
      IF HB_IsArray( aMenu[1,nPos, 1] )
         hwg_BuildMenu( aMenu,hWnd,,nPos )
      ELSE 
         IF aMenu[1,nPos, 1] == NIL .OR. aMenu[1,nPos, 2] != NIL
            IF Len(aMenu[1, npos]) == 4
               AAdd(aMenu[1, npos], NIL)
            ENDIF
            aMenu[1,npos, 5] := hwg__AddMenuItem( hMenu, aMenu[1,npos, 2], ;
                          nPos, hWnd, aMenu[1,nPos, 3], aMenu[1,npos, 4],.F. )
         Endif
      ENDIF
      nPos ++
   ENDDO
   IF hWnd != NIL .AND. oWnd != NIL
      hwg_SetMenu( oWnd, aMenu )
   ELSEIF _oMenu != NIL
      _oMenu:handle := aMenu[5]
      _oMenu:aMenu := aMenu
   ENDIF
Return NIL

Function hwg_BeginMenu( oWnd,nId,cTitle )
Local aMenu, i
   IF oWnd != NIL
      _aMenuDef := {}
      _aAccel   := {}
      _oBitmap  := {}
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
      if !Empty(cTitle)
         cTitle := StrTran(cTitle, "\t", "")
         cTitle := StrTran(cTitle, "&", "_")
      endif
      AAdd(aMenu, {{}, cTitle, nId, 0})
   ENDIF
Return .T.

Function hwg_ContextMenu()
   _aMenuDef := {}
   _oBitmap  := {}
   _oWnd := NIL
   _nLevel := 0
   _Id := CONTEXTMENU_FIRST_ID
   _oMenu := HMenu():New()
Return _oMenu

Function hwg_EndMenu()
   IF _nLevel > 0
      _nLevel --
   ELSE
      hwg_BuildMenu( Aclone(_aMenuDef), IIf(_oWnd != NIL,_oWnd:handle, NIL), ;
                   _oWnd,,IIf(_oWnd != NIL, .F., .T.) )
      IF _oWnd != NIL .AND. _aAccel != NIL .AND. !Empty(_aAccel)
         // _oWnd:hAccel := hwg_CreateAcceleratorTable(_aAccel)
      ENDIF
      _aMenuDef := NIL
      _oBitmap  := NIL
      _aAccel   := NIL
      _oWnd     := NIL
      _oMenu    := NIL
   ENDIF
Return .T.

Function hwg_DefineMenuItem( cItem, nId, bItem, lDisabled, accFlag, accKey, lBitmap, lResource, lCheck )
Local aMenu, i, oBmp, nFlag

   lCheck := IIf(lCheck == NIL, .F., lCheck)
   lDisabled := IIf(lDisabled == NIL, .T., !lDisabled)
   nFlag := hwg_BitOr( IIf(lCheck, FLAG_CHECK, 0), IIf(lDisabled, 0, FLAG_DISABLED) )

   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL .AND. cItem != NIL, ++_Id, nId)
   if !Empty(cItem)
      cItem := StrTran(cItem, "\t", "")
      cItem := StrTran(cItem, "&", "_")
   endif
   AAdd(aMenu, {bItem, cItem, nId, nFlag, 0})
   /*
   IF lBitmap != NIL .OR. !Empty(lBitmap)
      if lResource == NIL ;lResource:=.F.; Endif         
      if !lResource 
         oBmp:=HBitmap():AddFile(lBitmap)
      else
         oBmp:=HBitmap():AddResource(lBitmap)
      endif
      AAdd(_oBitmap, {.T., oBmp:Handle, cItem, nId})
   Else   
      AAdd(_oBitmap, {.F., "", cItem, nID})
   Endif         
   IF accFlag != NIL .AND. accKey != NIL
      AAdd(_aAccel, {accFlag, accKey, nId})
   ENDIF
   */
Return .T.

/*
Function hwg_DefineAccelItem( nId, bItem, accFlag, accKey )
Local aMenu, i
   aMenu := _aMenuDef
   FOR i := 1 TO _nLevel
      aMenu := Atail(aMenu)[1]
   NEXT
   nId := IIf(nId == NIL, ++_Id, nId)
   AAdd(aMenu, {bItem, NIL, nId, .T.})
   AAdd(_aAccel, {accFlag, accKey, nId})
Return .T.


Function hwg_SetMenuItemBitmaps( aMenu, nId, abmp1, abmp2 )
Local aSubMenu := hwg_FindMenuItem( aMenu, nId )
Local oMenu:=aSubMenu
IIf(aSubMenu == NIL, oMenu := 0, oMenu := aSubMenu[5])
SetMenuItemBitmaps( oMenu, nId, abmp1, abmp2 )
Return NIL

Function hwg_InsertBitmapMenu( aMenu, nId, lBitmap, oResource )
Local aSubMenu := hwg_FindMenuItem( aMenu, nId )
Local oMenu:=aSubMenu, oBmp
If !oResource .OR. oResource == NIL
     oBmp:=HBitmap():AddFile(lBitmap)
else
     oBmp:=HBitmap():AddResource(lBitmap)
endif
IIf(aSubMenu == NIL, oMenu := 0, oMenu := aSubMenu[5])
HWG__InsertBitmapMenu( oMenu, nId, obmp:handle )
Return NIL

Function hwg_SearchPosBitmap( nPos_Id )

   Local nPos := 1, lBmp:={.F.,""}

   IF _oBitmap != NIL
      DO WHILE nPos<=Len(_oBitmap)

         if _oBitmap[nPos][4] == nPos_Id
            lBmp:={_oBitmap[nPos][1], _oBitmap[nPos][2],_oBitmap[nPos][3]}     
         Endif

         nPos ++

      ENDDO
   ENDIF

Return lBmp
*/ 

Static Function GetMenuByHandle(hWnd)
Local i, aMenu, oDlg

   IF hWnd == NIL
      aMenu := HWindow():GetMain():menu
   ELSE
      IF ( oDlg := HDialog():FindDialog(hWnd) ) != NIL
         aMenu := oDlg:menu
      ELSEIF ( i := AScan(HDialog():aModalDialogs, {|o|o:handle == hWnd}) ) != NIL
         aMenu := HDialog():aModalDialogs[i]:menu
      ELSEIF ( i := AScan(HWindow():aWindows, {|o|o:handle == hWnd}) ) != NIL
         aMenu := HWindow():aWindows[i]:menu
      ENDIF
   ENDIF

Return aMenu

// TODO: adição do prefixo HWG_ conflita com função já existente
Function CheckMenuItem( hWnd, nId, lValue )
Local aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle(hWnd)
   IF aMenu != NIL
      IF ( aSubMenu := hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg_CheckMenuItem( aSubmenu[1,nPos, 5], lValue )
      ENDIF
   ENDIF

Return NIL

// TODO: adição do prefixo HWG_ conflita com função já existente
Function IsCheckedMenuItem( hWnd, nId )
Local aMenu, aSubMenu, nPos, lRes := .F.
   
   aMenu := GetMenuByHandle(hWnd)
   IF aMenu != NIL
      IF ( aSubMenu := hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         lRes := hwg_IsCheckedMenuItem( aSubmenu[1,nPos, 5] )
      ENDIF   
   ENDIF
   
Return lRes

// TODO: adição do prefixo HWG_ conflita com função já existente
Function EnableMenuItem( hWnd, nId, lValue )
Local aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle(IIf(hWnd == NIL, HWindow():GetMain():handle, hWnd))
   IF aMenu != NIL
      IF ( aSubMenu := hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg_EnableMenuItem( aSubmenu[1,nPos, 5], lValue )
      ENDIF
   ENDIF

Return NIL

// TODO: adição do prefixo HWG_ conflita com função já existente
Function IsEnabledMenuItem( hWnd, nId )
Local aMenu, aSubMenu, nPos

   aMenu := GetMenuByHandle(IIf(hWnd == NIL, HWindow():GetMain():handle, hWnd))
   IF aMenu != NIL
      IF ( aSubMenu := hwg_FindMenuItem( aMenu, nId, @nPos ) ) != NIL
         hwg_IsEnabledMenuItem( aSubmenu[1,nPos, 5] )
      ENDIF   
   ENDIF
   
Return NIL

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(BUILDMENU, HWG_BUILDMENU);
#endif

#pragma ENDDUMP
