//
// HWGUI - Harbour Win32 GUI library source code:
// C level dialog boxes functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

// #define OEMRESOURCE
#include "hwingui.h"

#if defined(__MINGW32__) || defined(__MINGW64__) || defined(__WATCOMC__)
#include <prsht.h>
#endif
#if defined(__DMC__)
#define GetWindowLongPtr GetWindowLong
#endif

#include <hbapiitm.h>
#include <hbvm.h>

#define WM_PSPNOTIFY WM_USER + 1010

static LRESULT CALLBACK s_ModalDlgProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_DlgProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_PSPProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_PSPProcRelease(HWND, UINT, LPPROPSHEETPAGE);

// NOTE: defined in guilib.h
//#define WND_DLG_RESOURCE 10
//#define WND_DLG_NORESOURCE 11

HWND *aDialogs = HWG_NULLPTR;
static int s_nDialogs = 0;
int iDialogs = 0;

/*
HWG_DIALOGBOX() --> NIL
*/
HB_FUNC(HWG_DIALOGBOX)
{
  PHB_ITEM pObject = hb_param(2, HB_IT_OBJECT);
  PHB_ITEM pData = GetObjectVar(pObject, "XRESOURCEID");
  void *hResource;
  LPCTSTR lpResource = HB_ITEMGETSTR(pData, &hResource, HWG_NULLPTR);

  if (!lpResource && HB_IS_NUMERIC(pData))
  {
    lpResource = MAKEINTRESOURCE(hb_itemGetNI(pData));
  }

  DialogBoxParam(hModule, lpResource, hwg_par_HWND(1), (DLGPROC)s_ModalDlgProc, (LPARAM)pObject);

  hb_strfree(hResource);
}

/*  Creates modeless dialog
    CreateDialog(hParentWindow, aDialog)
*/

/*
HWG_CREATEDIALOG(HWND, oP2) --> HWND
*/
HB_FUNC(HWG_CREATEDIALOG)
{
  PHB_ITEM pObject = hb_param(2, HB_IT_OBJECT);
  HWND hDlg;
  PHB_ITEM pData = GetObjectVar(pObject, "XRESOURCEID");
  void *hResource;
  LPCTSTR lpResource = HB_ITEMGETSTR(pData, &hResource, HWG_NULLPTR);
  if (!lpResource && HB_IS_NUMERIC(pData))
  {
    lpResource = MAKEINTRESOURCE(hb_itemGetNI(pData));
  }
  hDlg = CreateDialogParam(hModule, lpResource, hwg_par_HWND(1), (DLGPROC)s_DlgProc, (LPARAM)pObject);
  hb_strfree(hResource);
  ShowWindow(hDlg, SW_SHOW);
  hwg_ret_HWND(hDlg);
}

/*
HWG_ENDDIALOG() --> NIL
*/
HB_FUNC(HWG_ENDDIALOG)
{
  EndDialog(hwg_par_HWND(1), TRUE);
}

/*
GETDLGITEM(HWND, nId) --> HWND
*/
HB_FUNC(HWG_GETDLGITEM)
{
  hwg_ret_HWND(GetDlgItem(hwg_par_HWND(1), hwg_par_int(2)));
}

/*
GETDLGCTRLID(HWND) --> nId
*/
HB_FUNC(HWG_GETDLGCTRLID)
{
  hwg_ret_int(GetDlgCtrlID(hwg_par_HWND(1)));
}

/*
HWG_SETDLGITEMTEXT(HWND, nId, cText) --> NIL
*/
HB_FUNC(HWG_SETDLGITEMTEXT)
{
  void *hText;
  SetDlgItemText(hwg_par_HWND(1), hwg_par_int(2), HB_PARSTR(3, &hText, HWG_NULLPTR));
  hb_strfree(hText);
}

/*
SETDLGITEMINT(HWND, nId, nValue, lSigned) --> NIL
*/
HB_FUNC(HWG_SETDLGITEMINT)
{
  SetDlgItemInt(hwg_par_HWND(1), hwg_par_int(2), hwg_par_UINT(3),
                (hb_pcount() < 4 || HB_ISNIL(4) || !hb_parl(4)) ? FALSE : TRUE);
}

/*
GETDLGITEMTEXT(HWND, nId, nLen) --> cText
*/
HB_FUNC(HWG_GETDLGITEMTEXT)
{
  int iLen = hb_parni(3);
  LPTSTR lpText = (LPTSTR)hb_xgrab((iLen + 1) * sizeof(TCHAR));
  GetDlgItemText(hwg_par_HWND(1), hwg_par_int(2), lpText, iLen);
  HB_RETSTR(lpText);
  hb_xfree(lpText);
}

/*
GETEDITTEXT(HWND, nId) --> cText
*/
HB_FUNC(HWG_GETEDITTEXT)
{
  HWND hDlg = hwg_par_HWND(1);
  int id = hwg_par_int(2);
  USHORT uiLen = (USHORT)SendMessage(GetDlgItem(hDlg, id), WM_GETTEXTLENGTH, 0, 0);
  LPTSTR lpText = (LPTSTR)hb_xgrab((uiLen + 2) * sizeof(TCHAR));
  GetDlgItemText(hDlg, id, lpText, uiLen + 1);
  HB_RETSTR(lpText);
  hb_xfree(lpText);
}

/*
HWG_CHECKDLGBUTTON(HWND, nId, lChecked) --> NIL
*/
HB_FUNC(HWG_CHECKDLGBUTTON)
{
  CheckDlgButton(hwg_par_HWND(1), hwg_par_int(2), hb_parl(3) ? BST_CHECKED : BST_UNCHECKED); // TODO: retorno � BOOL
}

/*
HWG_CHECKRADIOBUTTON(HWND, nIdFirstButton, nIdLastButton, nIdCheckButton) --> NIL
*/
HB_FUNC(HWG_CHECKRADIOBUTTON)
{
  CheckRadioButton(hwg_par_HWND(1), hwg_par_int(2), hwg_par_int(3), hwg_par_int(4)); // TODO: retorno � BOOL
}

/*
HWG_ISDLGBUTTONCHECKED(HWND, nId) --> .T./.F.
*/
HB_FUNC(HWG_ISDLGBUTTONCHECKED)
{
  hb_retl(IsDlgButtonChecked(hwg_par_HWND(1), hwg_par_int(2)) == BST_CHECKED);
}

/*
HWG_COMBOADDSTRING(HWND, cText) --> NIL
*/
HB_FUNC(HWG_COMBOADDSTRING)
{
  void *hText;
  SendMessage(hwg_par_HWND(1), CB_ADDSTRING, 0, (LPARAM)HB_PARSTR(2, &hText, HWG_NULLPTR));
  hb_strfree(hText);
}

/*
HWG_COMBOINSERTSTRING(HWND, nIndex, cText) --> NIL
*/
HB_FUNC(HWG_COMBOINSERTSTRING)
{
  void *hText;
  SendMessage(hwg_par_HWND(1), CB_INSERTSTRING, hwg_par_WPARAM(2), (LPARAM)HB_PARSTR(3, &hText, HWG_NULLPTR));
  hb_strfree(hText);
}

/*
HWG_COMBOSETSTRING(HWND, nIndex) --> NIL
*/
HB_FUNC(HWG_COMBOSETSTRING)
{
  SendMessage(hwg_par_HWND(1), CB_SETCURSEL, hwg_par_WPARAM(2) - 1, 0);
}

/*
HWG_GETNOTIFYCODEFROM() -->
*/
HB_FUNC(HWG_GETNOTIFYCODEFROM)
{
  hwg_ret_HWND(((NMHDR *)HB_PARHANDLE(1))->hwndFrom);
}

/*
HWG_GETNOTIFYIDFROM() -->
*/
HB_FUNC(HWG_GETNOTIFYIDFROM)
{
  hwg_ret_UINT_PTR(((NMHDR *)HB_PARHANDLE(1))->idFrom);
}

/*
HWG_GETNOTIFYCODE(handle) --> nCode
*/
HB_FUNC(HWG_GETNOTIFYCODE)
{
  hwg_ret_UINT(((NMHDR *)HB_PARHANDLE(1))->code);
}

static LPWORD s_lpwAlign(LPWORD lpIn)
{
  ULONG_PTR ul;

  ul = (ULONG_PTR)lpIn;
  ul += 3;
  ul >>= 2;
  ul <<= 2;
  return (LPWORD)ul;
}

static HB_SIZE s_nCopyAnsiToWideChar(LPWORD lpWCStr, PHB_ITEM pItem, HB_SIZE size)
{
#if defined(HB_HAS_STR_FUNC)
  return hb_itemCopyStrU16(pItem, HB_CDP_ENDIAN_NATIVE, (HB_WCHAR *)lpWCStr, size) + 1;
#else
  return MultiByteToWideChar(GetACP(), 0, hb_itemGetCPtr(pItem), -1, (LPWSTR)lpWCStr, size);
#endif
}

static int s_nWideStringLen(PHB_ITEM pItem)
{
#if defined(HB_HAS_STR_FUNC)
  return (int)hb_itemCopyStrU16(pItem, HB_CDP_ENDIAN_NATIVE, HWG_NULLPTR, 0) + 1;
#else
  return MultiByteToWideChar(GetACP(), 0, hb_itemGetCPtr(pItem), -1, HWG_NULLPTR, 0);
#endif
}

static LPDLGTEMPLATE s_CreateDlgTemplate(PHB_ITEM pObj, int x1, int y1, int dwidth, int dheight, ULONG ulStyle)
{
  HGLOBAL hgbl;
  PWORD p, pend;
  PHB_ITEM pControls, pControl, temp;
  LONG baseUnit = GetDialogBaseUnits();
  int baseunitX = LOWORD(baseUnit), baseunitY = HIWORD(baseUnit);
  long lTemplateSize = 15;
  LONG lExtStyle;
  ULONG ul, ulControls;

  x1 = (x1 * 4) / baseunitX;
  dwidth = (dwidth * 4) / baseunitX;
  y1 = (y1 * 8) / baseunitY;
  dheight = (dheight * 8) / baseunitY;

  /* clear styles which needs different dialog template */
  ulStyle &= ~(DS_SETFONT | DS_SHELLFONT);

  pControls = hb_itemNew(GetObjectVar(pObj, "ACONTROLS"));
  ulControls = (ULONG)hb_arrayLen(pControls);

  lTemplateSize += s_nWideStringLen(GetObjectVar(pObj, "TITLE"));
  lTemplateSize += lTemplateSize & 1;

  for (ul = 1; ul <= ulControls; ul++)
  {
    pControl = hb_arrayGetItemPtr(pControls, ul);
    lTemplateSize += 13;
    lTemplateSize += s_nWideStringLen(GetObjectVar(pControl, "WINCLASS"));
    lTemplateSize += s_nWideStringLen(GetObjectVar(pControl, "TITLE"));
    lTemplateSize += lTemplateSize & 1;
  }
  lTemplateSize += 2; /* 2 to keep DWORD boundary block size */

  hgbl = GlobalAlloc(GMEM_ZEROINIT, lTemplateSize * sizeof(WORD));
  if (!hgbl)
  {
    return HWG_NULLPTR;
  }

  p = (PWORD)GlobalLock(hgbl);
  pend = p + lTemplateSize;

  *p++ = 1;      // DlgVer
  *p++ = 0xFFFF; // Signature
  *p++ = 0;      // LOWORD HelpID
  *p++ = 0;      // HIWORD HelpID
  *p++ = 0;      // LOWORD (lExtendedStyle)
  *p++ = 0;      // HIWORD (lExtendedStyle)
  *p++ = LOWORD(ulStyle);
  *p++ = HIWORD(ulStyle);
  *p++ = (WORD)(UINT)ulControls; // NumberOfItems // TODO: cast para UINT ?
  *p++ = (WORD)x1;               // x
  *p++ = (WORD)y1;               // y
  *p++ = (WORD)dwidth;           // cx
  *p++ = (WORD)dheight;          // cy
  *p++ = 0;                      // Menu
  *p++ = 0;                      // Class

  // Copy the title of the dialog box.
  p += s_nCopyAnsiToWideChar(p, GetObjectVar(pObj, "TITLE"), pend - p);

  for (ul = 1; ul <= ulControls; ul++)
  {
    pControl = hb_arrayGetItemPtr(pControls, ul);

    temp = HB_PUTHANDLE(HWG_NULLPTR, -1);
    SetObjectVar(pControl, "_HANDLE", temp);
    hb_itemRelease(temp);

    p = s_lpwAlign(p);

    ulStyle = (ULONG)hb_itemGetNL(GetObjectVar(pControl, "STYLE"));
    lExtStyle = hb_itemGetNL(GetObjectVar(pControl, "EXTSTYLE"));
    x1 = (hb_itemGetNI(GetObjectVar(pControl, "NLEFT")) * 4) / baseunitX;
    dwidth = (hb_itemGetNI(GetObjectVar(pControl, "NWIDTH")) * 4) / baseunitX;
    y1 = (hb_itemGetNI(GetObjectVar(pControl, "NTOP")) * 8) / baseunitY;
    dheight = (hb_itemGetNI(GetObjectVar(pControl, "NHEIGHT")) * 8) / baseunitY;

    *p++ = 0;                 // LOWORD (lHelpID)
    *p++ = 0;                 // HIWORD (lHelpID)
    *p++ = LOWORD(lExtStyle); // LOWORD (lExtendedStyle)
    *p++ = HIWORD(lExtStyle); // HIWORD (lExtendedStyle)
    *p++ = LOWORD(ulStyle);
    *p++ = HIWORD(ulStyle);
    *p++ = (WORD)x1;                                         // x
    *p++ = (WORD)y1;                                         // y
    *p++ = (WORD)dwidth;                                     // cx
    *p++ = (WORD)dheight;                                    // cy
    *p++ = (WORD)hb_itemGetNI(GetObjectVar(pControl, "ID")); // LOWORD (Control ID)
    *p++ = 0;                                                // HOWORD (Control ID)

    // class name
    p += s_nCopyAnsiToWideChar(p, GetObjectVar(pControl, "WINCLASS"), pend - p);

    // Caption
    p += s_nCopyAnsiToWideChar(p, GetObjectVar(pControl, "TITLE"), pend - p);

    *p++ = 0; // Advance pointer over nExtraStuff WORD.
  }

  p = s_lpwAlign(p);
  *p = 0; // Number of bytes of extra data.

  hb_itemRelease(pControls);

  GlobalUnlock(hgbl);

  return (LPDLGTEMPLATE)hgbl;
}

static void s_ReleaseDlgTemplate(LPDLGTEMPLATE pdlgtemplate)
{
  GlobalFree((HGLOBAL)pdlgtemplate);
}

/*
HWG_CREATEDLGTEMPLATE() -->
*/
HB_FUNC(HWG_CREATEDLGTEMPLATE)
{
  hb_retnint((LONG_PTR)s_CreateDlgTemplate(hb_param(1, HB_IT_OBJECT), hb_parni(2), hb_parni(3), hb_parni(4),
                                           hb_parni(5), (ULONG)hb_parnl(6)));
}

/*
HWG_RELEASEDLGTEMPLATE() -->
*/
HB_FUNC(HWG_RELEASEDLGTEMPLATE)
{
  s_ReleaseDlgTemplate((LPDLGTEMPLATE)(LONG_PTR)hb_parnint(1));
}

/*
 *  _CreatePropertySheetPage(aDlg, x1, y1, nWidth, nHeight, nStyle) --> hPage
 */

/*
HWG__CREATEPROPERTYSHEETPAGE() -->
*/
HB_FUNC(HWG__CREATEPROPERTYSHEETPAGE)
{
  PROPSHEETPAGE psp;
  PHB_ITEM pObj = hb_param(1, HB_IT_OBJECT), temp;
  void *hTitle = HWG_NULLPTR;
  LPDLGTEMPLATE pdlgtemplate;

  memset((void *)&psp, 0, sizeof(PROPSHEETPAGE));

  psp.dwSize = sizeof(PROPSHEETPAGE);
  psp.hInstance = HWG_NULLPTR;
  psp.pszTitle = HWG_NULLPTR;
  psp.pfnDlgProc = (DLGPROC)s_PSPProc;
  psp.lParam = (LPARAM)hb_itemNew(pObj);
  psp.pfnCallback = (LPFNPSPCALLBACK)s_PSPProcRelease;
  psp.pcRefParent = 0;
#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
  psp.hIcon = 0;
#else
  psp.DUMMYUNIONNAME2.hIcon = 0;
#endif

  if (hb_itemGetNI(GetObjectVar(pObj, "TYPE")) == WND_DLG_RESOURCE)
  {
    LPCTSTR lpTitle;

    psp.dwFlags = 0 | PSP_USECALLBACK;

    temp = GetObjectVar(pObj, "XRESOURCEID");
    if (HB_IS_STRING(temp))
    {
      lpTitle = HB_ITEMGETSTR(temp, &hTitle, HWG_NULLPTR);
    }
    else if (HB_IS_NUMERIC(temp))
    {
      lpTitle = MAKEINTRESOURCE(hb_itemGetNL(temp));
    }
    else
    {
      lpTitle = HWG_NULLPTR;
    }
#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
    psp.pszTemplate = lpTitle;
#else
    psp.DUMMYUNIONNAME.pszTemplate = lpTitle;
#endif
  }
  else
  {
    pdlgtemplate = (LPDLGTEMPLATE)(LONG_PTR)hb_parnl(2);

    psp.dwFlags = PSP_DLGINDIRECT | PSP_USECALLBACK;
#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
    psp.pResource = pdlgtemplate;
#else
    psp.DUMMYUNIONNAME.pResource = pdlgtemplate;
#endif
  }

  hwg_ret_HPROPSHEETPAGE(CreatePropertySheetPage(&psp));
  // if (pdlgtemplate)
  //    s_ReleaseDlgTemplate(pdlgtemplate);
  hb_strfree(hTitle);
}

/*
 * _PropertySheet(hWndParent, aPageHandles, nPageHandles, cTitle, [lModeless], [lNoApply], [lWizard]) --> hPropertySheet
 */

/*
HWG__PROPERTYSHEET() -->
*/
HB_FUNC(HWG__PROPERTYSHEET)
{
  PHB_ITEM pArr = hb_param(2, HB_IT_ARRAY);
  int nPages = hb_parni(3), i;
  HPROPSHEETPAGE psp[10];
  PROPSHEETHEADER psh;
  void *hCaption;
  DWORD dwFlags = (hb_pcount() < 5 || HB_ISNIL(5) || !hb_parl(5)) ? 0 : PSH_MODELESS;

  if (hb_pcount() > 5 && !HB_ISNIL(6) && hb_parl(6))
  {
    dwFlags |= PSH_NOAPPLYNOW;
  }
  if (hb_pcount() > 6 && !HB_ISNIL(7) && hb_parl(7))
  {
    dwFlags |= PSH_WIZARD;
  }
  for (i = 0; i < nPages; i++)
  {
    psp[i] = (HPROPSHEETPAGE)(LONG_PTR)hb_arrayGetNL(pArr, i + 1);
  }
  
  psh.dwSize = sizeof(PROPSHEETHEADER);
  psh.dwFlags = dwFlags;
  psh.hwndParent = hwg_par_HWND(1);
  psh.hInstance = HWG_NULLPTR;
#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
  psh.pszIcon = HWG_NULLPTR;
#else
  psh.DUMMYUNIONNAME.pszIcon = HWG_NULLPTR;
#endif
  psh.pszCaption = HB_PARSTR(4, &hCaption, HWG_NULLPTR);
  psh.nPages = nPages;
#if !defined(__BORLANDC__) || (__BORLANDC__ > 1424)
  psh.nStartPage = 0;
  psh.phpage = psp;
#else
  psh.DUMMYUNIONNAME2.nStartPage = 0;
  psh.DUMMYUNIONNAME3.phpage = psp;
#endif
  psh.pfnCallback = HWG_NULLPTR;

  HB_RETHANDLE(PropertySheet(&psh));
  hb_strfree(hCaption);
}

/* Hwg_CreateDlgIndirect(hParentWnd, pArray, x1, y1, nWidth, nHeight, nStyle)
 */

/*
HWG_CREATEDLGINDIRECT() -->
*/
HB_FUNC(HWG_CREATEDLGINDIRECT)
{
  LPDLGTEMPLATE pdlgtemplate;
  PHB_ITEM pObject = hb_param(2, HB_IT_OBJECT);
  BOOL fFree = FALSE;

  if (hb_pcount() > 7 && !HB_ISNIL(8))
  {
    pdlgtemplate = (LPDLGTEMPLATE)(LONG_PTR)hb_parnl(8);
  }
  else
  {
    ULONG ulStyle = ((hb_pcount() > 6 && !HB_ISNIL(7))
                         ? (ULONG)hb_parnl(7)
                         : WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU | WS_SIZEBOX); // | DS_SETFONT;

    pdlgtemplate = s_CreateDlgTemplate(pObject, hb_parni(3), hb_parni(4), hb_parni(5), hb_parni(6), ulStyle);
    fFree = TRUE;
  }

  CreateDialogIndirectParam(hModule, pdlgtemplate, hwg_par_HWND(1), (DLGPROC)s_DlgProc, (LPARAM)pObject);

  if (fFree)
  {
    s_ReleaseDlgTemplate(pdlgtemplate);
  }
}

/* Hwg_DlgBoxIndirect(hParentWnd, pArray, x1, y1, nWidth, nHeight, nStyle)
 */

/*
HWG_DLGBOXINDIRECT() -->
*/
HB_FUNC(HWG_DLGBOXINDIRECT)
{
  PHB_ITEM pObject = hb_param(2, HB_IT_OBJECT);
  ULONG ulStyle =
      ((hb_pcount() > 6 && !HB_ISNIL(7)) ? (ULONG)hb_parnl(7)
                                         : WS_POPUP | WS_VISIBLE | WS_CAPTION | WS_SYSMENU); // | DS_SETFONT;
  int x1 = hb_parni(3), y1 = hb_parni(4), dwidth = hb_parni(5), dheight = hb_parni(6);
  LPDLGTEMPLATE pdlgtemplate = s_CreateDlgTemplate(pObject, x1, y1, dwidth, dheight, ulStyle);

  DialogBoxIndirectParam(hModule, pdlgtemplate, hwg_par_HWND(1), (DLGPROC)s_ModalDlgProc, (LPARAM)pObject);
  s_ReleaseDlgTemplate(pdlgtemplate);
}

/*
HWG_DIALOGBASEUNITS() --> numeric
*/
HB_FUNC(HWG_DIALOGBASEUNITS)
{
  hwg_ret_long(GetDialogBaseUnits());
}

static LRESULT CALLBACK s_ModalDlgProc(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  // PHB_DYNS pSymTest;
  LRESULT res;
  PHB_ITEM pObject;

  if (uMsg == WM_INITDIALOG)
  {
    PHB_ITEM temp;

    temp = hb_itemPutNL(HWG_NULLPTR, 1);
    SetObjectVar((PHB_ITEM)lParam, "_NHOLDER", temp);
    hb_itemRelease(temp);

    temp = HB_PUTHANDLE(HWG_NULLPTR, hDlg);
    SetObjectVar((PHB_ITEM)lParam, "_HANDLE", temp);
    hb_itemRelease(temp);

    SetWindowObject(hDlg, (PHB_ITEM)lParam);
  }
  pObject = (PHB_ITEM)GetWindowLongPtr(hDlg, GWLP_USERDATA);

  if (!pSym_onEvent)
  {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hwg_vmPushUINT(uMsg);
    hwg_vmPushWPARAM(wParam);
    hwg_vmPushLPARAM(lParam);
    hb_vmSend(3);
#ifdef HWG_USE_POINTER_ITEM
    if (uMsg == WM_CTLCOLORSTATIC || uMsg == WM_CTLCOLOREDIT || uMsg == WM_CTLCOLORBTN || uMsg == WM_CTLCOLORLISTBOX ||
        uMsg == WM_CTLCOLORDLG)
    {
      res = hb_parptr(-1);
      return (INT_PTR)res; // TODO: revisar
    }
    else
#endif
      res = hwg_par_LRESULT(-1);
    return (res == -1) ? FALSE : res;
  }
  else
  {
    return FALSE;
  }
}

static LRESULT CALLBACK s_DlgProc(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  LRESULT res;
  PHB_ITEM pObject;

  if (uMsg == WM_INITDIALOG)
  {
    PHB_ITEM temp;

    temp = hb_itemPutNL(HWG_NULLPTR, 1);
    SetObjectVar((PHB_ITEM)lParam, "_NHOLDER", temp);
    hb_itemRelease(temp);

    temp = HB_PUTHANDLE(HWG_NULLPTR, hDlg);
    SetObjectVar((PHB_ITEM)lParam, "_HANDLE", temp);
    hb_itemRelease(temp);

    SetWindowObject(hDlg, (PHB_ITEM)lParam);

    if (iDialogs == s_nDialogs)
    {
      s_nDialogs += 16;
      if (s_nDialogs == 16)
      {
        aDialogs = (HWND *)hb_xgrab(sizeof(HWND) * s_nDialogs);
      }
      else
      {
        aDialogs = (HWND *)hb_xrealloc(aDialogs, sizeof(HWND) * s_nDialogs);
      }
    }
    aDialogs[iDialogs++] = hDlg;
  }
  else if (uMsg == WM_DESTROY)
  {
    int i;
    for (i = 0; i < iDialogs; i++)
    {
      if (aDialogs[i] == hDlg)
      {
        break;
      }
    }
    iDialogs--;
    for (; i < iDialogs; i++)
    {
      aDialogs[i] = aDialogs[i + 1];
    }
  }

  pObject = (PHB_ITEM)GetWindowLongPtr(hDlg, GWLP_USERDATA);

  if (!pSym_onEvent)
  {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hwg_vmPushUINT(uMsg);
    hwg_vmPushWPARAM(wParam);
    hwg_vmPushLPARAM(lParam);
    hb_vmSend(3);
#ifdef HWG_USE_POINTER_ITEM
    if (uMsg == WM_CTLCOLORSTATIC || uMsg == WM_CTLCOLOREDIT || uMsg == WM_CTLCOLORBTN || uMsg == WM_CTLCOLORLISTBOX ||
        uMsg == WM_CTLCOLORDLG)
    {
      res = hb_parptr(-1);
      return (INT_PTR)res; // TODO: revisar
    }
    else
#endif

      res = hwg_par_LRESULT(-1);
    return (res == -1) ? FALSE : res;
  }
  else
  {
    return FALSE;
  }
}

static LRESULT CALLBACK s_PSPProc(HWND hDlg, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  LRESULT res;
  PHB_ITEM pObject;

  if (uMsg == WM_INITDIALOG)
  {
    PHB_ITEM pObj, temp;

    pObj = (PHB_ITEM)(((PROPSHEETPAGE *)lParam)->lParam);

    temp = hb_itemPutNL(HWG_NULLPTR, 1);
    SetObjectVar(pObj, "_NHOLDER", temp);
    hb_itemRelease(temp);

    temp = HB_PUTHANDLE(HWG_NULLPTR, hDlg);
    SetObjectVar(pObj, "_HANDLE", temp);
    hb_itemRelease(temp);

    SetWindowObject(hDlg, pObj);

    if (iDialogs == s_nDialogs)
    {
      s_nDialogs += 16;
      if (s_nDialogs == 16)
      {
        aDialogs = (HWND *)hb_xgrab(sizeof(HWND) * s_nDialogs);
      }
      else
      {
        aDialogs = (HWND *)hb_xrealloc(aDialogs, sizeof(HWND) * s_nDialogs);
      }
    }
    aDialogs[iDialogs++] = hDlg;
    // hb_itemRelease(pObj);
  }
  else if (uMsg == WM_NOTIFY)
  {
    uMsg = WM_PSPNOTIFY;
  }
  else if (uMsg == WM_DESTROY)
  {
    int i;
    for (i = 0; i < iDialogs; i++)
    {
      if (aDialogs[i] == hDlg)
      {
        break;
      }
    }
    iDialogs--;
    for (; i < iDialogs; i++)
    {
      aDialogs[i] = aDialogs[i + 1];
    }
  }

  pObject = (PHB_ITEM)GetWindowLongPtr(hDlg, GWLP_USERDATA);

  if (!pSym_onEvent)
  {
    pSym_onEvent = hb_dynsymFindName("ONEVENT");
  }

  if (pSym_onEvent && pObject)
  {
    hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEvent));
    hb_vmPush(pObject);
    hwg_vmPushUINT(uMsg);
    hwg_vmPushWPARAM(wParam);
    hwg_vmPushLPARAM(lParam);
    hb_vmSend(3);
    res = hwg_par_LRESULT(-1);
    return (res == -1) ? FALSE : res;
  }
  else
  {
    return FALSE;
  }
}

/*
HWG_EXITPROC() --> NIL
*/
HB_FUNC(HWG_EXITPROC)
{
  if (aDialogs)
  {
    hb_xfree(aDialogs);
  }
}
static LRESULT CALLBACK s_PSPProcRelease(HWND hwnd, UINT uMsg, LPPROPSHEETPAGE ppsp)
{
  HB_SYMBOL_UNUSED(hwnd);

  if (uMsg == PSPCB_CREATE)
  {
    return 1;
  }
  if (uMsg == PSPCB_RELEASE)
  {
    hb_itemRelease((PHB_ITEM)ppsp->lParam);
  }

  return 0;
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(GETDLGITEM, HWG_GETDLGITEM);
HB_FUNC_TRANSLATE(GETDLGCTRLID, HWG_GETDLGCTRLID);
HB_FUNC_TRANSLATE(SETDLGITEMTEXT, HWG_SETDLGITEMTEXT);
HB_FUNC_TRANSLATE(SETDLGITEMINT, HWG_SETDLGITEMINT);
HB_FUNC_TRANSLATE(GETDLGITEMTEXT, HWG_GETDLGITEMTEXT);
HB_FUNC_TRANSLATE(GETEDITTEXT, HWG_GETEDITTEXT);
HB_FUNC_TRANSLATE(CHECKDLGBUTTON, HWG_CHECKDLGBUTTON);
HB_FUNC_TRANSLATE(CHECKRADIOBUTTON, HWG_CHECKRADIOBUTTON);
HB_FUNC_TRANSLATE(ISDLGBUTTONCHECKED, HWG_ISDLGBUTTONCHECKED);
HB_FUNC_TRANSLATE(COMBOADDSTRING, HWG_COMBOADDSTRING);
HB_FUNC_TRANSLATE(COMBOINSERTSTRING, HWG_COMBOINSERTSTRING);
HB_FUNC_TRANSLATE(COMBOSETSTRING, HWG_COMBOSETSTRING);
HB_FUNC_TRANSLATE(GETNOTIFYCODEFROM, HWG_GETNOTIFYCODEFROM);
HB_FUNC_TRANSLATE(GETNOTIFYIDFROM, HWG_GETNOTIFYIDFROM);
HB_FUNC_TRANSLATE(GETNOTIFYCODE, HWG_GETNOTIFYCODE);
HB_FUNC_TRANSLATE(CREATEDLGTEMPLATE, HWG_CREATEDLGTEMPLATE);
HB_FUNC_TRANSLATE(RELEASEDLGTEMPLATE, HWG_RELEASEDLGTEMPLATE);
HB_FUNC_TRANSLATE(_CREATEPROPERTYSHEETPAGE, HWG__CREATEPROPERTYSHEETPAGE);
HB_FUNC_TRANSLATE(_PROPERTYSHEET, HWG__PROPERTYSHEET);
HB_FUNC_TRANSLATE(DIALOGBASEUNITS, HWG_DIALOGBASEUNITS);
#endif
