//
// $Id: hradio.prg 1868 2012-08-27 17:33:11Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HRadioGroup class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//#DEFINE TRANSPARENT 1 // defined in windows.ch

CLASS HRadioGroup INHERIT HControl //HObject

   CLASS VAR winclass   INIT "STATIC"
   CLASS VAR oGroupCurrent
   DATA aButtons
   DATA nValue  INIT 1
   DATA bSetGet
   DATA oHGroup
   DATA lEnabled  INIT .T.
   DATA bClick

   METHOD New(vari, bSetGet, bInit, bClick, bGFocus, nStyle)
   METHOD Newrg(oWndParent, nId, nStyle, vari, bSetGet, nLeft, nTop, nWidth, nHeight, ;
              cCaption, oFont, bInit, bSize, tcolor, bColor, bClick, ;
              bGFocus, lTransp)
   METHOD EndGroup(nSelected)
   METHOD SetValue(nValue)
   METHOD GetValue() INLINE ::nValue
   METHOD Value(nValue) SETGET
   METHOD Refresh()
   //METHOD IsEnabled() INLINE ::lEnabled
   METHOD Enable()
   METHOD Disable()
   //METHOD Enabled(lEnabled) SETGET
   METHOD Init()
   METHOD Activate() VIRTUAL

ENDCLASS

METHOD HRadioGroup:New(vari, bSetGet, bInit, bClick, bGFocus, nStyle)

   ::oGroupCurrent := Self
   ::aButtons := {}
   ::oParent := IIf(HWindow():GetMain() != NIL, HWindow():GetMain():oDefaultParent, NIL)

   ::lEnabled :=  !hwg_BitAnd(nStyle, WS_DISABLED) > 0

   ::Super:New(::oParent, ,, ,,,,, bInit)

   ::bInit := bInit
   ::bClick := bClick
   ::bGetFocus := bGfocus


   IF vari != NIL
      IF hb_IsNumeric(vari)
         ::nValue := vari
      ENDIF
      //::bSetGet := bSetGet
   ENDIF
   ::bSetGet := bSetGet

   RETURN Self

METHOD HRadioGroup:NewRg(oWndParent, nId, nStyle, vari, bSetGet, nLeft, nTop, nWidth, nHeight, ;
             cCaption, oFont, bInit, bSize, tcolor, bColor, bClick, ;
             bGFocus, lTransp)

   ::oGroupCurrent := Self
   ::aButtons := {}
   ::lEnabled :=  !hwg_BitAnd(nStyle, WS_DISABLED) > 0

   ::Super:New(::oParent, , , nLeft, nTop, nWidth, nHeight, oFont, bInit)
   ::oHGroup := HGroup():New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, cCaption, ;
                              oFont, bInit, bSize, , tcolor, bColor, lTransp, Self)

   ::lInit := .T.
   ::bInit := bInit
   ::bClick := bClick
   ::bGetFocus := bGfocus

   IF vari != NIL
      IF hb_IsNumeric(vari)
         ::nValue := vari
      ENDIF
   ENDIF
   ::bSetGet := bSetGet

   RETURN Self


METHOD HRadioGroup:EndGroup(nSelected)
   LOCAL nLen

   IF ::oGroupCurrent != NIL .AND. (nLen := Len(::oGroupCurrent:aButtons)) > 0

      nSelected := IIf(nSelected != NIL .AND. nSelected <= nLen .AND. nSelected > 0, ;
                        nSelected, ::oGroupCurrent:nValue)
      IF nSelected != 0 .AND. nSelected <= nLen
         IF ::oGroupCurrent:aButtons[nLen]:handle > 0
            hwg_CheckRadioButton(::oGroupCurrent:aButtons[nLen]:oParent:handle, ;
                             ::oGroupCurrent:aButtons[1]:id, ;
                             ::oGroupCurrent:aButtons[nLen]:id, ;
                             ::oGroupCurrent:aButtons[nSelected]:id)
         ELSE
            ::oGroupCurrent:aButtons[nLen]:bInit := ;
               &("{|o|hwg_CheckRadioButton(o:oParent:handle," + ;
               LTrim(Str(::oGroupCurrent:aButtons[1]:id)) + "," + ;
               LTrim(Str(::oGroupCurrent:aButtons[nLen]:id)) + "," + ;
               LTrim(Str(::oGroupCurrent:aButtons[nSelected]:id)) + ")}")
         ENDIF
      ENDIF
      IF Empty(::oParent)
         ::oParent := ::oGroupCurrent:aButtons[nLen]:oParent //hwg_GetParentForm()
      ENDIF
      //::Init()
   ENDIF
   ::oGroupCurrent := NIL
   RETURN NIL

METHOD HRadioGroup:Init()

   IF !::lInit
      /*
      IF ::oHGroup != NIL
        ::id := ::oHGroup:id
        ::handle := ::oHGroup:handle
      ENDIF
      */
      ::super:init()
   ENDIF
   RETURN  NIL

METHOD HRadioGroup:SetValue(nValue)
   LOCAL nLen

   IF (nLen := Len(::aButtons)) > 0 .AND. nValue > 0 .AND. nValue <= nLen
      hwg_CheckRadioButton(::aButtons[nLen]:oParent:handle, ;
                       ::aButtons[1]:id, ;
                       ::aButtons[nLen]:id, ;
                       ::aButtons[nValue]:id)
      ::nValue := nValue
      IF hb_IsBlock(::bSetGet)
         Eval(::bSetGet, ::nValue)
      ENDIF
   ELSEIF nLen > 0
      hwg_CheckRadioButton(::aButtons[nlen]:oParent:handle, ;
            ::aButtons[1]:id, ;
            ::aButtons[nLen]:id, ;
            0)
   ENDIF
   RETURN NIL
   
METHOD HRadioGroup:Value(nValue)

   IF nValue != NIL
       ::SetValue(nValue)
   ENDIF
    RETURN ::nValue
   

METHOD HRadioGroup:Refresh()
   LOCAL vari

   IF hb_IsBlock(::bSetGet)
     vari := Eval(::bSetGet,, Self)
     IF vari == NIL .OR. !hb_IsNumeric(vari)
         vari := ::nValue
      ENDIF
      ::SetValue(vari)
   ENDIF
   RETURN NIL

METHOD HRadioGroup:Enable()
   LOCAL i, nLen := Len(::aButtons)

   FOR i := 1 TO nLen
       ::aButtons[i]:Enable()
    NEXT
   RETURN NIL

METHOD HRadioGroup:Disable()
   LOCAL i, nLen := Len(::aButtons)

   FOR i := 1 TO nLen
       ::aButtons[i]:Disable()
    NEXT
   RETURN NIL
