//
// HWGUI - Harbour Win32 GUI library source code:
// C level text functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#define OEMRESOURCE
#include "hwingui.h"
#include <commctrl.h>
#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>

HB_FUNC_EXTERN(HB_OEMTOANSI);
HB_FUNC_EXTERN(HB_ANSITOOEM);

// HWG_DEFINEPAINTSTRU(PAINTSTRUCT) -->
HB_FUNC(HWG_DEFINEPAINTSTRU)
{
  hwg_ret_PAINTSTRUCT((PAINTSTRUCT *)hb_xgrab(sizeof(PAINTSTRUCT)));
}

// HWG_BEGINPAINT(HWND, PAINTSTRUCT) -->
HB_FUNC(HWG_BEGINPAINT)
{
  hwg_ret_HDC(BeginPaint(hwg_par_HWND(1), hwg_par_PAINTSTRUCT(2)));
}

// HWG_ENDPAINT(HWND, PAINTSTRUCT) -->
HB_FUNC(HWG_ENDPAINT)
{
  PAINTSTRUCT *pps = hwg_par_PAINTSTRUCT(2);
  EndPaint(hwg_par_HWND(1), pps); // TODO: o retorno é BOOL
  hb_xfree(pps);
}

// HWG_DELETEDC(HDC) -->
HB_FUNC(HWG_DELETEDC)
{
  DeleteDC(hwg_par_HDC(1)); // TODO: o retorno é BOOL
}

// HWG_TEXTOUT(HDC, nX, nY, cString) -->
HB_FUNC(HWG_TEXTOUT)
{
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(4, &hText, &nLen);
  TextOut(hwg_par_HDC(1), hwg_par_int(2), hwg_par_int(3), lpText, (int)nLen); // TODO: o retorno é BOOL
  hb_strfree(hText);
}

// HWG_DRAWTEXT(HDC, cText, nLeft, nTop, nRight, nBottom, nFormat, p8) --> numeric
// HWG_DRAWTEXT(HDC, cText, aRect, nFormat, p8) --> numeric
HB_FUNC(HWG_DRAWTEXT)
{
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
  RECT rc;
  UINT uFormat = hb_pcount() == 4 ? hwg_par_UINT(4) : hwg_par_UINT(7);
  // int uiPos = (hb_pcount() == 4 ? 3 : hb_parni(8));
  int heigh;

  if (hb_pcount() > 4) {
    rc.left = hb_parni(3);
    rc.top = hb_parni(4);
    rc.right = hb_parni(5);
    rc.bottom = hb_parni(6);
  } else {
    Array2Rect(hb_param(3, HB_IT_ARRAY), &rc);
  }

  heigh = DrawText(hwg_par_HDC(1), lpText, (int)nLen, &rc, uFormat);
  hb_strfree(hText);

  // if (HB_ISBYREF(uiPos))
  if (HB_ISARRAY(8)) {
    hb_storvni(rc.left, 8, 1);
    hb_storvni(rc.top, 8, 2);
    hb_storvni(rc.right, 8, 3);
    hb_storvni(rc.bottom, 8, 4);
  }
  hwg_ret_int(heigh); // TODO: remover variável heigh
}

// HWG_GETTEXTMETRIC(HDC) --> array[8]
HB_FUNC(HWG_GETTEXTMETRIC)
{
  TEXTMETRIC tm;
  PHB_ITEM aMetr = hb_itemArrayNew(8);
  PHB_ITEM temp;

  GetTextMetrics(hwg_par_HDC(1), &tm);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmHeight);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmAveCharWidth);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmMaxCharWidth);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmExternalLeading);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmInternalLeading);
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmAscent);
  hb_itemArrayPut(aMetr, 6, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmDescent);
  hb_itemArrayPut(aMetr, 7, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, tm.tmWeight);
  hb_itemArrayPut(aMetr, 8, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

// HWG_GETTEXTSIZE(HDC, cText) -->
HB_FUNC(HWG_GETTEXTSIZE)
{
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(2, &hText, &nLen);
  SIZE sz;
  PHB_ITEM aMetr = hb_itemArrayNew(2);
  PHB_ITEM temp;

  GetTextExtentPoint32(hwg_par_HDC(1), lpText, (int)nLen, &sz); // TODO: o retorno é BOOL
  hb_strfree(hText);

  temp = hb_itemPutNL(HWG_NULLPTR, sz.cx);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, sz.cy);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

// HWG_GETCLIENTRECT(HWND) --> aRect[4]
HB_FUNC(HWG_GETCLIENTRECT)
{
  RECT rc;
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  GetClientRect(hwg_par_HWND(1), &rc); // TODO: o retorno é BOOL

  temp = hb_itemPutNL(HWG_NULLPTR, rc.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

// GETWINDOWRECT(HWND) --> aRect[4]
HB_FUNC(HWG_GETWINDOWRECT)
{
  RECT rc;
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  GetWindowRect(hwg_par_HWND(1), &rc); // TODO: o retorno é BOOL

  temp = hb_itemPutNL(HWG_NULLPTR, rc.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, rc.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

// HWG_GETCLIENTAREA(PAINTSTRUCT) --> aRect[4]
HB_FUNC(HWG_GETCLIENTAREA)
{
  PAINTSTRUCT *pps = hwg_par_PAINTSTRUCT(1);
  PHB_ITEM aMetr = hb_itemArrayNew(4);
  PHB_ITEM temp;

  temp = hb_itemPutNL(HWG_NULLPTR, pps->rcPaint.left);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, pps->rcPaint.top);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, pps->rcPaint.right);
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, pps->rcPaint.bottom);
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

// HWG_SETTEXTCOLOR(HDC, COLORREF) --> COLORREF
HB_FUNC(HWG_SETTEXTCOLOR)
{
  hwg_ret_COLORREF(SetTextColor(hwg_par_HDC(1), hwg_par_COLORREF(2)));
}

// HWG_SETBKCOLOR(HDC, COLORREF) --> COLORREF
HB_FUNC(HWG_SETBKCOLOR)
{
  hwg_ret_COLORREF(SetBkColor(hwg_par_HDC(1), hwg_par_COLORREF(2)));
}

// HWG_SETTRANSPARENTMODE(HDC, lTransparent) --> .T.|.F.
HB_FUNC(HWG_SETTRANSPARENTMODE)
{
  int iMode = SetBkMode(hwg_par_HDC(1), hb_parl(2) ? TRANSPARENT : OPAQUE);
  hb_retl(iMode == TRANSPARENT);
}

// HWG_GETTEXTCOLOR(HDC) --> COLORREF
HB_FUNC(HWG_GETTEXTCOLOR)
{
  hwg_ret_COLORREF(GetTextColor(hwg_par_HDC(1)));
}

// HWG_GETBKCOLOR(HDC) --> COLORREF
HB_FUNC(HWG_GETBKCOLOR)
{
  hwg_ret_COLORREF(GetBkColor(hwg_par_HDC(1)));
}

/*
HB_FUNC(GETTEXTSIZE)
{
  HDC hdc = GetDC(hwg_par_HWND(1));
  SIZE size;
  PHB_ITEM aMetr = hb_itemArrayNew(2);
  PHB_ITEM temp;
  void *hString;

  GetTextExtentPoint32(hdc, HB_PARSTR(2, &hString, HWG_NULLPTR),
    lpString,         // address of text string
    strlen(cbString), // number of characters in string
    &size            // address of structure for string size
  );
  hb_strfree(hString);

  temp = hb_itemPutNI(HWG_NULLPTR, size.cx);
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNI(HWG_NULLPTR, size.cy);
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}
*/

// HWG_EXTTEXTOUT(HDC, nX, nY, nLeft, nTop, nRight, nBottom, cText) -->
HB_FUNC(HWG_EXTTEXTOUT)
{
  RECT rc;
  void *hText;
  HB_SIZE nLen;
  LPCTSTR lpText = HB_PARSTR(8, &hText, &nLen);
  rc.left = hb_parni(4);
  rc.top = hb_parni(5);
  rc.right = hb_parni(6);
  rc.bottom = hb_parni(7);
  ExtTextOut(hwg_par_HDC(1), hwg_par_int(2), hwg_par_int(3), ETO_OPAQUE, &rc, lpText, (UINT)nLen, HWG_NULLPTR);
  hb_strfree(hText);
}

// HWG_WRITESTATUSWINDOW(HWND, nIndex) -->
HB_FUNC(HWG_WRITESTATUSWINDOW)
{
  void *hString;
  SendMessage(hwg_par_HWND(1), SB_SETTEXT, hwg_par_WPARAM(2), (LPARAM)HB_PARSTR(3, &hString, HWG_NULLPTR));
  hb_strfree(hString);
}

// HWG_WINDOWFROMDC(HDC) --> HWND
HB_FUNC(HWG_WINDOWFROMDC)
{
  hwg_ret_HWND(WindowFromDC(hwg_par_HDC(1)));
}

// hwg_CreateFont(fontName, nWidth, hHeight [,fnWeight] [,fdwCharSet], [,fdwItalic] [,fdwUnderline] [,fdwStrikeOut])

// HWG_CREATEFONT(cFontName, nWidth, nHeight, nWeight, nCharSet, nItalic, nUnderline, nStrikeOut) --> HFONT
HB_FUNC(HWG_CREATEFONT)
{
  HFONT hFont;
  int fnWeight = (HB_ISNIL(4)) ? 0 : hwg_par_int(4);
  DWORD fdwCharSet = (HB_ISNIL(5)) ? 0 : hwg_par_DWORD(5);
  DWORD fdwItalic = (HB_ISNIL(6)) ? 0 : hwg_par_DWORD(6);
  DWORD fdwUnderline = (HB_ISNIL(7)) ? 0 : hwg_par_DWORD(7);
  DWORD fdwStrikeOut = (HB_ISNIL(8)) ? 0 : hwg_par_DWORD(8);
  void *hString;
  hFont = CreateFont(hwg_par_int(3), hwg_par_int(2), 0, 0, fnWeight, fdwItalic, fdwUnderline, fdwStrikeOut, fdwCharSet,
                     0, 0, 0, 0, HB_PARSTR(1, &hString, HWG_NULLPTR));
  hb_strfree(hString);
  hwg_ret_HFONT(hFont);
}

// hwg_SetCtrlFont(hWnd, ctrlId, hFont)

// HWG_SETCTRLFONT(HWND, nID, HFONT) -->
HB_FUNC(HWG_SETCTRLFONT)
{
  SendDlgItemMessage(hwg_par_HWND(1), hwg_par_int(2), WM_SETFONT, (WPARAM)hwg_par_HFONT(3), 0);
}

// OEMTOANSI() ->
HB_FUNC(OEMTOANSI)
{
  HB_FUNC_EXEC(HB_OEMTOANSI);
}

// ANSITOOEM ->
HB_FUNC(ANSITOOEM)
{
  HB_FUNC_EXEC(HB_ANSITOOEM);
}

// HWG_CREATERECTRGN(nX1, nY1, nX2, nY2) --> HRGN
HB_FUNC(HWG_CREATERECTRGN)
{
  hwg_ret_HRGN(CreateRectRgn(hwg_par_int(1), hwg_par_int(2), hwg_par_int(3), hwg_par_int(4)));
}

// HWG_CREATERECTRGNINDIRECT(NIL, nLeft, nTop, nRight, nBottom) --> HRGN
HB_FUNC(HWG_CREATERECTRGNINDIRECT)
{
  RECT rc;
  rc.left = hb_parni(2);
  rc.top = hb_parni(3);
  rc.right = hb_parni(4);
  rc.bottom = hb_parni(5);
  hwg_ret_HRGN(CreateRectRgnIndirect(&rc));
}

// HWG_EXTSELECTCLIPRGN(HDC, HRGN, nMode) --> numeric
HB_FUNC(HWG_EXTSELECTCLIPRGN)
{
  hwg_ret_int(ExtSelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2), hwg_par_int(3)));
}

// HWG_SELECTCLIPRGN(HDC, HRGN) --> numeric
HB_FUNC(HWG_SELECTCLIPRGN)
{
  hwg_ret_int(SelectClipRgn(hwg_par_HDC(1), hwg_par_HRGN(2)));
}

// HWG_CREATEFONTINDIRECT(cFontName, nWeight, nHeight, nQuality) --> HFONT
HB_FUNC(HWG_CREATEFONTINDIRECT)
{
  LOGFONT lf;
  HFONT f;
  memset(&lf, 0, sizeof(LOGFONT));
  lf.lfQuality = hwg_par_BYTE(4);
  lf.lfHeight = hwg_par_LONG(3);
  lf.lfWeight = hwg_par_LONG(2);
  HB_ITEMCOPYSTR(hb_param(1, HB_IT_ANY), lf.lfFaceName, HB_SIZEOFARRAY(lf.lfFaceName));
  lf.lfFaceName[HB_SIZEOFARRAY(lf.lfFaceName) - 1] = '\0';
  f = CreateFontIndirect(&lf);
  hwg_ret_HFONT(f);
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(DEFINEPAINTSTRU, HWG_DEFINEPAINTSTRU);
HB_FUNC_TRANSLATE(BEGINPAINT, HWG_BEGINPAINT);
HB_FUNC_TRANSLATE(ENDPAINT, HWG_ENDPAINT);
HB_FUNC_TRANSLATE(DELETEDC, HWG_DELETEDC);
HB_FUNC_TRANSLATE(TEXTOUT, HWG_TEXTOUT);
HB_FUNC_TRANSLATE(GETTEXTMETRIC, HWG_GETTEXTMETRIC);
HB_FUNC_TRANSLATE(GETTEXTSIZE, HWG_GETTEXTSIZE);
HB_FUNC_TRANSLATE(GETCLIENTRECT, HWG_GETCLIENTRECT);
HB_FUNC_TRANSLATE(GETWINDOWRECT, HWG_GETWINDOWRECT);
HB_FUNC_TRANSLATE(GETCLIENTAREA, HWG_GETCLIENTAREA);
HB_FUNC_TRANSLATE(SETTEXTCOLOR, HWG_SETTEXTCOLOR);
HB_FUNC_TRANSLATE(SETBKCOLOR, HWG_SETBKCOLOR);
HB_FUNC_TRANSLATE(SETTRANSPARENTMODE, HWG_SETTRANSPARENTMODE);
HB_FUNC_TRANSLATE(GETTEXTCOLOR, HWG_GETTEXTCOLOR);
HB_FUNC_TRANSLATE(GETBKCOLOR, HWG_GETBKCOLOR);
HB_FUNC_TRANSLATE(EXTTEXTOUT, HWG_EXTTEXTOUT);
HB_FUNC_TRANSLATE(WRITESTATUSWINDOW, HWG_WRITESTATUSWINDOW);
HB_FUNC_TRANSLATE(WINDOWFROMDC, HWG_WINDOWFROMDC);
HB_FUNC_TRANSLATE(CREATEFONT, HWG_CREATEFONT);
HB_FUNC_TRANSLATE(SETCTRLFONT, HWG_SETCTRLFONT);
HB_FUNC_TRANSLATE(CREATERECTRGN, HWG_CREATERECTRGN);
HB_FUNC_TRANSLATE(CREATERECTRGNINDIRECT, HWG_CREATERECTRGNINDIRECT);
HB_FUNC_TRANSLATE(EXTSELECTCLIPRGN, HWG_EXTSELECTCLIPRGN);
HB_FUNC_TRANSLATE(SELECTCLIPRGN, HWG_SELECTCLIPRGN);
HB_FUNC_TRANSLATE(CREATEFONTINDIRECT, HWG_CREATEFONTINDIRECT);
#endif
