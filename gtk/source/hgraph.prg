//
// $Id: hgraph.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HGraph class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HGraph INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA aValues
   DATA nGraphs INIT 1
   DATA nType
   DATA lGrid   INIT .F.
   DATA scaleX, scaleY
   DATA ymaxSet
   DATA tbrush
   DATA colorCoor INIT 16777215
   DATA oPen, oPenCoor
   DATA xmax, ymax, xmin, ymin PROTECTED

   METHOD New(oWndParent, nId, aValues, nLeft, nTop, nWidth, nHeight, oFont, ;
                  bSize, ctoolt, tcolor, bcolor)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD CalcMinMax()
   //METHOD Paint()
   METHOD Paint(lpdis)
   //METHOD Rebuild(aValues)
   METHOD Rebuild(aValues, nType)

ENDCLASS

METHOD HGraph:New(oWndParent, nId, aValues, nLeft, nTop, nWidth, nHeight, oFont, ;
                  bSize, ctoolt, tcolor, bcolor)

   ::Super:New(oWndParent, nId, SS_OWNERDRAW, nLeft, nTop, nWidth, nHeight, oFont,, ;
                  bSize, {|o, lpdis|o:Paint(lpdis)}, ctoolt, ;
                  IIf(tcolor == NIL, hwg_VColor("FFFFFF"), tcolor), IIf(bcolor == NIL, 0, bcolor))

   ::aValues := aValues
   ::nType   := 1
   ::nGraphs := 1

   ::Activate()

RETURN Self

METHOD HGraph:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic(::oParent:handle, ::id, ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

METHOD HGraph:onEvent(msg, wParam, lParam)

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF msg == WM_PAINT
      ::Paint()
   ENDIF
RETURN 0

METHOD HGraph:CalcMinMax()

   LOCAL i
   LOCAL j
   LOCAL nLen

   ::xmax := ::xmin := ::ymax := ::ymin := 0
   IF ::ymaxSet != NIL .AND. ::ymaxSet != 0
      ::ymax := ::ymaxSet
   ENDIF
   FOR i := 1 TO ::nGraphs
      nLen := Len(::aValues[i])
      IF ::nType == 1
         FOR j := 1 TO nLen
            ::xmax := Max(::xmax, ::aValues[i, j, 1])
            ::xmin := Min(::xmin, ::aValues[i, j, 1])
            ::ymax := Max(::ymax, ::aValues[i, j, 2])
            ::ymin := Min(::ymin, ::aValues[i, j, 2])
         NEXT
      ELSEIF ::nType == 2
         FOR j := 1 TO nLen
            ::ymax := Max(::ymax, ::aValues[i, j, 2])
            ::ymin := Min(::ymin, ::aValues[i, j, 2])
         NEXT
         ::xmax := nLen
      ELSEIF ::nType == 3
         FOR j := 1 TO nLen
            ::ymax += ::aValues[i, j, 2]
         NEXT
      ENDIF
   NEXT

RETURN NIL

METHOD HGraph:Paint(lpdis)

   LOCAL hDC := hwg_GetDC(::handle)
   //LOCAL drawInfo := hwg_GetDrawItemInfo(lpdis)
   //LOCAL hDC := drawInfo[3]
   //LOCAL x1 := drawInfo[4]
   //LOCAL y1 := drawInfo[5]
   //LOCAL x2 := drawInfo[6]
   //LOCAL y2 := drawInfo[7]
   LOCAL x1 := 0
   LOCAL y1 := 0
   LOCAL x2 := ::nWidth
   LOCAL y2 := ::nHeight
   LOCAL i
   LOCAL j
   LOCAL nLen
   LOCAL px1
   LOCAL px2
   LOCAL py1
   LOCAL py2
   LOCAL nWidth

   HB_SYMNOL_UNUSED(lpdis)

   IF ::xmax == NIL
      ::CalcMinMax()
   ENDIF
   i := Round((x2 - x1) / 10, 0)
   x1 += i
   x2 -= i
   i := Round((y2 - y1) / 10, 0)
   y1 += i
   y2 -= i

   IF ::nType < 3
      ::scaleX := (::xmax - ::xmin) / (x2-x1)
      ::scaleY := (::ymax - ::ymin) / (y2-y1)
   ENDIF

   IF ::oPenCoor == NIL
      ::oPenCoor := HPen():Add(PS_SOLID, 1, ::colorCoor)
   ENDIF
   IF ::oPen == NIL
      ::oPen := HPen():Add(PS_SOLID, 2, ::tcolor)
   ENDIF

   hwg_FillRect(hDC, 0, 0, ::nWidth, ::nHeight, ::brush:handle)
   IF ::nType != 3
      hwg_SelectObject(hDC, ::oPenCoor:handle)
      hwg_Drawline(hDC, x1 + (0 - ::xmin) / ::scaleX, 3, x1 + (0 - ::xmin) / ::scaleX, ::nHeight - 3)
      hwg_Drawline(hDC, 3, y2 - (0 - ::ymin) / ::scaleY, ::nWidth - 3, y2 - (0 - ::ymin) / ::scaleY)
   ENDIF
   IF ::ymax == ::ymin .AND. ::ymax == 0
      RETURN NIL
   ENDIF

   hwg_SelectObject(hDC, ::oPen:handle)
   FOR i := 1 TO ::nGraphs
      nLen := Len(::aValues[i])
      IF ::nType == 1  
         FOR j := 2 TO nLen
            px1 := Round(x1 + (::aValues[i, j - 1, 1] - ::xmin) / ::scaleX, 0)
            py1 := Round(y2 - (::aValues[i, j - 1, 2] - ::ymin) / ::scaleY, 0)
            px2 := Round(x1 + (::aValues[i, j, 1] - ::xmin) / ::scaleX, 0)
            py2 := Round(y2 - (::aValues[i, j, 2] - ::ymin) / ::scaleY, 0)
            IF px2 != px1 .OR. py2 != py1
               hwg_Drawline(hDC, px1, py1, px2, py2)
            ENDIF   
         NEXT
      ELSEIF ::nType == 2
         IF ::tbrush == NIL
            ::tbrush := HBrush():Add(::tcolor)
         ENDIF
         nWidth := Round((x2 - x1) / (nLen * 2 + 1), 0)
         FOR j := 1 TO nLen
            px1 := Round(x1 + nWidth * (j * 2 - 1), 0)
            py1 := Round(y2 - (::aValues[i, j, 2] - ::ymin) / ::scaleY, 0)
            hwg_FillRect(hDC, px1, py1, px1 + nWidth, y2 - 2, ::tbrush:handle)
         NEXT
      ELSEIF ::nType == 3
         hwg_DrawButton(hDC, 5, 5, 80, 30, 5)
         hwg_DrawButton(hDC, 5, 35, 80, 55, 6)
         /*
         IF ::tbrush == NIL
            ::tbrush := HBrush():Add(::tcolor)
         ENDIF
         hwg_SelectObject(hDC, ::oPenCoor:handle)
         hwg_SelectObject(hDC, ::tbrush:handle)
         hwg_pie(hDC, x1 + 10, y1 + 10, x2 - 10, y2 - 10, x1, round(y1 + (y2 - y1) / 2, 0), round(x1 + (x2 - x1) / 2, 0), y1)
	 */
      ENDIF
   NEXT
   hwg_releaseDC(::handle, hDC)
   
RETURN NIL

METHOD HGraph:Rebuild(aValues, nType)

   ::aValues := aValues
   IF nType != NIL
      ::nType := nType
   ENDIF
   ::CalcMinMax()
   hwg_RedrawWindow(::handle, RDW_ERASE + RDW_INVALIDATE + RDW_INTERNALPAINT + RDW_UPDATENOW)

RETURN NIL
