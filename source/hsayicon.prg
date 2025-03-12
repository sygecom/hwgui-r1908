//
// $Id: hsayicon.prg 1899 2012-09-19 12:35:34Z lfbasso $
//
// HWGUI - Harbour Win32 GUI library source code:
// HSayIcon class
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"

#define STM_SETIMAGE        370    // 0x0172

//- HSayIcon

CLASS HSayIcon INHERIT HSayImage

   METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
               bSize, ctooltip, lOEM, bClick, bDblClick)
   METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip)
   METHOD Init()
   METHOD REFRESH() INLINE hwg_SendMessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)

ENDCLASS

METHOD New(oWndParent, nId, nLeft, nTop, nWidth, nHeight, Image, lRes, bInit, ;
            bSize, ctooltip, lOEM, bClick, bDblClick) CLASS HSayIcon

   ::Super:New(oWndParent, nId, SS_ICON, nLeft, nTop, nWidth, nHeight, bInit, bSize, ctooltip, bClick, bDblClick)

   IF lRes == NIL
      lRes := .F.
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   IF ::oImage == NIL
      ::oImage := IIf(lRes .OR. hb_IsNumeric(Image),  ;
                       HIcon():AddResource(Image, , , , lOEM), ;
                       IIf(hb_IsChar(Image), ;
                            HIcon():AddFile(Image), Image))
   ENDIF
   ::Activate()

   RETURN Self

METHOD Redefine(oWndParent, nId, xImage, lRes, bInit, bSize, ctooltip) CLASS HSayIcon

   ::Super:Redefine(oWndParent, nId, bInit, bSize, ctooltip)

   IF lRes == NIL
      lRes := .F.
   ENDIF
   IF ::oImage == NIL
      ::oImage := IIf(lRes .OR. hb_IsNumeric(xImage), ;
                       HIcon():AddResource(xImage), ;
                       IIf(hb_IsChar(xImage), ;
                            HIcon():AddFile(xImage), xImage))
   ENDIF
   RETURN Self

METHOD Init() CLASS HSayIcon

   IF !::lInit
      ::Super:Init()
      hwg_SendMessage(::handle, STM_SETIMAGE, IMAGE_ICON, ::oImage:handle)
   ENDIF
   RETURN NIL
