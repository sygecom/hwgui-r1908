//
// $Id: hdc.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HPAINTDC and HDC Classes
//
// Copyright 2005 Luiz Rafael Culik Guimaraes <culikr@brtrubo.com>
// www - http://sites.uol.com.br/culikr/
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HPAINTDC FROM HDC

   DATA m_ps

   METHOD New(nWnd)
   METHOD End()

   HIDDEN:
   DATA m_hWnd

ENDCLASS

METHOD HPaintDC:New(nWnd)

   ::Super:New()
   ::m_ps   := hwg_DefinePaintStru()
   ::m_hWnd := nWnd
   ::Attach(hwg_BeginPaint(::m_hWnd, ::m_ps))

   RETURN Self

METHOD HPaintDC:End()

   hwg_EndPaint(::m_hWnd, ::m_ps)
   ::m_hDC       := NIL
   ::m_hAttribDC := NIL

   RETURN NIL

CLASS HDC

   DATA m_hDC
   DATA m_hAttribDC

   METHOD New()
   METHOD SetAttribDC(hDC)
   METHOD ATTACH(hDc)
   METHOD MOVETO(x1, y1)
   METHOD LINETO(x1, y1)
   METHOD fillsolidrect(lpRect, clr)
   METHOD fillrect(lpRect, clr)
   METHOD SelectClipRgn(pRgn)
   METHOD SetTextcolor(xColor)
   METHOD SetBkMode(xMode)
   METHOD SetBkColor(clr) INLINE    hwg_SetBkColor(::m_hDC, clr)
   METHOD SelectObject(xMode)
   METHOD DrawText(strText, Rect, dwFlags)
   METHOD CreateCompatibleDc(x)
   METHOD patblt(a, s, d, f, g) INLINE hwg_PatBlt(::m_hDc, a, s, d, f, g)
   METHOD Savedc()
   METHOD RestoreDC(nSavedDC)
   METHOD SetMapMode(nMapMode)
   METHOD SetWindowOrg(x, y)
   METHOD SetWindowExt(x, y)
   METHOD SetViewportOrg(x, y)
   METHOD SetViewportExt(x, y)
   METHOD SetArcDirection(nArcDirection)
   METHOD GetTextMetric() INLINE hwg_GetTextMetric(::m_hDC)
   METHOD SetROP2(nDrawMode)
   METHOD BitBlt(x, y, nWidth, nHeight, pSrcDC, xSrc, ySrc, dwRop) INLINE hwg_BitBlt(::m_hDc, x, y, nWidth, nHeight, pSrcDC, xSrc, ySrc, dwRop)

   METHOD PIE(arect, apt1, apt2)
   METHOD DeleteDc()
ENDCLASS

METHOD HDC:New()

   ::m_hDC       := NIL
   ::m_hAttribDC := NIL

   RETURN Self

METHOD HDC:MOVETO(x1, y1)
   hwg_MoveTo(::m_hDC, x1, y1)
   RETURN Self

METHOD HDC:LINETO(x1, y1)
   hwg_LineTo(::m_hDC, x1, y1)
   RETURN Self

METHOD HDC:Attach(hDC)

   IF Empty(hDC)
      RETURN .F.
   ENDIF

   ::m_hDC := hDC

   ::SetAttribDC(::m_hDC)
   RETURN .T.

METHOD HDC:deletedc()
   hwg_DeleteDc(::m_hDC)
   ::m_hDC := NIL
   ::m_hAttribDC := NIL
   RETURN NIL

METHOD HDC:SetAttribDC(hDC)

   ::m_hAttribDC := hDC
   RETURN NIL

METHOD HDC:SelectClipRgn(pRgn)

   LOCAL nRetVal := - 1

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := hwg_SelectClipRgn(::m_hDC, pRgn)
   ENDIF

   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_SelectClipRgn(::m_hAttribDC, pRgn)
   ENDIF

   RETURN nRetVal

METHOD HDC:fillsolidrect(lpRect, clr)

   hwg_SetBkColor(::m_hDC, clr)
   hwg_ExtTextOut(::m_hDC, 0, 0, lpRect[1], lpRect[2], lpRect[3], lpRect[4], NIL)

   RETURN NIL

METHOD HDC:SetTextColor(xColor)

   RETURN hwg_SetTextColor(::m_hDc, xColor)

METHOD HDC:SetBkMode(xMode)

   RETURN hwg_SetBkMode(::m_hDc, xMode)

METHOD HDC:SelectObject(xMode)

   RETURN hwg_SelectObject(::m_hDc, xMode)

METHOD HDC:DrawText(strText, Rect, dwFlags)

   hwg_DrawText(::m_hDC, strText, Rect[1], Rect[2], Rect[3], Rect[4], dwFlags)

   RETURN NIL

METHOD HDC:fillrect(lpRect, clr)

   hwg_FillRect(::m_hDC, lpRect[1], lpRect[2], lpRect[3], lpRect[4], clr)

   RETURN NIL


METHOD HDC:CreateCompatibleDc(x)
   RETURN ::Attach(hwg_CreateCompatibleDC(x))

METHOD HDC:SAVEDC()
   LOCAL nRetVal := 0

   IF (!Empty(::m_hAttribDC))
      nRetVal := hwg_SaveDC(::m_hAttribDC)
   ENDIF
   IF (::m_hDC != ::m_hAttribDC .AND. hwg_SaveDC(::m_hDC) != 0)
      nRetVal := - 1   // -1 is the only valid restore value for complex DCs
   ENDIF
   RETURN nRetVal

METHOD HDC:RestoreDC(nSavedDC)

   // if two distinct DCs, nSavedDC can only be -1

   LOCAL bRetVal := .T.
   IF (::m_hDC != ::m_hAttribDC)
      bRetVal := hwg_RestoreDC(::m_hDC, nSavedDC)
   ENDIF
   IF (!Empty(::m_hAttribDC))
      bRetVal := (bRetVal .AND. hwg_RestoreDC(::m_hAttribDC, nSavedDC))
   ENDIF
   RETURN bRetVal

METHOD HDC:SetMapMode(nMapMode)

   LOCAL nRetVal := 0

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := ::SetMapMode(::m_hDC, nMapMode)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_SetMapMode(::m_hAttribDC, nMapMode)
   ENDIF
   RETURN nRetVal



METHOD HDC:SetWindowOrg(x, y)


   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_SetWindowOrgEx(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_SetWindowOrgEx(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point


METHOD HDC:SetWindowExt(x, y)


   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_SetWindowExtEx(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_SetWindowExtEx(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point


METHOD HDC:SetViewportOrg(x, y)


   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_SetViewportOrgEx(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_SetViewportOrgEx(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point


METHOD HDC:SetViewportExt(x, y)

   LOCAL point

   IF (::m_hDC != ::m_hAttribDC)
      hwg_SetViewportExtEx(::m_hDC, x, y, @point)
   ENDIF
   IF !Empty(::m_hAttribDC)
      hwg_SetViewportExtEx(::m_hAttribDC, x, y, @point)
   ENDIF
   RETURN point


METHOD HDC:SetArcDirection(nArcDirection)


   LOCAL nResult := 0
   IF (::m_hDC != ::m_hAttribDC)
      nResult := hwg_SetArcDirection(::m_hDC, nArcDirection)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nResult := hwg_SetArcDirection(::m_hAttribDC, nArcDirection)
   ENDIF
   RETURN nResult


METHOD HDC:PIE(arect, apt1, apt2)
   RETURN hwg_Pie(::m_hdc, arect[1], arect[2], arect[3], arect[4], apt1[1], apt1[2], apt2[1], apt2[2])

METHOD HDC:SetROP2(nDrawMode)


   LOCAL nRetVal := 0

   IF (::m_hDC != ::m_hAttribDC)
      nRetVal := hwg_SetROP2(::m_hDC, nDrawMode)
   ENDIF
   IF !Empty(::m_hAttribDC)
      nRetVal := hwg_SetROP2(::m_hAttribDC, nDrawMode)
   ENDIF
   RETURN nRetVal



CLASS HCLIENTDC FROM HDC

   METHOD New(nWnd)
   METHOD End()

   HIDDEN:
   DATA m_hWnd

ENDCLASS

METHOD HClientDC:New(nWnd)

   ::Super:New()
   ::m_hWnd := nWnd
   ::Attach(hwg_GetDC(::m_hWnd))

   RETURN Self

METHOD HClientDC:End()

   hwg_ReleaseDc(::m_hWnd, ::m_hDC)
   ::m_hDC       := NIL
   ::m_hAttribDC := NIL

   RETURN NIL
