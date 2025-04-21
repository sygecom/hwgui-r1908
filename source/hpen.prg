//
// $Id: drawwidg.prg 1740 2011-09-23 12:06:53Z LFBASSO $
//
// HWGUI - Harbour Win32 GUI library source code:
// Pens handling
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HPen INHERIT HObject

   CLASS VAR aPens INIT {}

   DATA handle
   DATA style
   DATA width
   DATA color
   DATA nCounter INIT 1

   METHOD Add(nStyle, nWidth, nColor)
   METHOD Get(nStyle, nWidth, nColor)
   METHOD Release()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HPen:Add(nStyle, nWidth, nColor)

   LOCAL item

   nStyle := IIf(nStyle == NIL, BS_SOLID, nStyle)
   nWidth := IIf(nWidth == NIL, 1, nWidth)
   nColor := IIf(nColor == NIL, 0, nColor)

   FOR EACH item IN ::aPens
      IF item:style == nStyle .AND. ;
         item:width == nWidth .AND. ;
         item:color == nColor
         item:nCounter++
         RETURN item
      ENDIF
   NEXT

   ::handle := hwg_CreatePen(nStyle, nWidth, nColor)
   ::style := nStyle
   ::width := nWidth
   ::color := nColor
   AAdd(::aPens, Self)

RETURN Self

//-------------------------------------------------------------------------------------------------------------------//

METHOD HPen:Get(nStyle, nWidth, nColor)

   LOCAL item

   nStyle := IIf(nStyle == NIL, PS_SOLID, nStyle)
   nWidth := IIf(nWidth == NIL, 1, nWidth)
   nColor := IIf(nColor == NIL, 0, nColor)

   FOR EACH item IN ::aPens
      IF item:style == nStyle .AND. ;
         item:width == nWidth .AND. ;
         item:color == nColor
         RETURN item
      ENDIF
   NEXT

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

METHOD HPen:Release()

   LOCAL item
   LOCAL nlen := Len(::aPens)

   ::nCounter--
   IF ::nCounter == 0
      FOR EACH item IN ::aPens
         IF item:handle == ::handle
            hwg_DeleteObject(::handle)
            #ifdef __XHARBOUR__
            ADel(::aPens, hb_EnumIndex())
            #else
            ADel(::aPens, item:__EnumIndex())
            #endif
            ASize(::aPens, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE hwg_CleanDrawWidgHPen

   LOCAL item

   FOR EACH item IN HPen():aPens
      hwg_DeleteObject(item:handle)
   NEXT

RETURN

//-------------------------------------------------------------------------------------------------------------------//
