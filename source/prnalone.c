//
// C level print functions
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
#ifdef __XHARBOUR__
#include <hbfast.h>
#endif

HB_FUNC(HWG_PRINTSETUP)
{
  PRINTDLG pd;

  memset((void *)&pd, 0, sizeof(PRINTDLG));

  pd.lStructSize = sizeof(PRINTDLG);
  pd.Flags = PD_RETURNDC;
  pd.hwndOwner = GetActiveWindow();
  pd.nFromPage = 1;
  pd.nToPage = 1;
  pd.nCopies = 1;

  if (PrintDlg(&pd)) {
    hwg_ret_HDC(pd.hDC);
  } else {
    hwg_ret_HDC(HWG_NULLPTR);
  }
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(PRINTSETUP, HWG_PRINTSETUP);
#endif

HB_FUNC(OPENPRINTER)
{
  void *hStr;
  hwg_ret_HDC(CreateDC(HWG_NULLPTR, HB_PARSTR(1, &hStr, HWG_NULLPTR), HWG_NULLPTR, HWG_NULLPTR));
  hb_strfree(hStr);
}

HB_FUNC(OPENDEFAULTPRINTER)
{
  DWORD dwNeeded, dwReturned;
  HDC hDC;
  PRINTER_INFO_4 *pinfo4;
  PRINTER_INFO_5 *pinfo5;

  if (GetVersion() & 0x80000000) // Windows 98
  {
    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

    pinfo5 = hb_xgrab(dwNeeded);

    EnumPrinters(PRINTER_ENUM_DEFAULT, HWG_NULLPTR, 5, (PBYTE)pinfo5, dwNeeded, &dwNeeded, &dwReturned);
    hDC = CreateDC(HWG_NULLPTR, pinfo5->pPrinterName, HWG_NULLPTR, HWG_NULLPTR);

    hb_xfree(pinfo5);
  } else // Windows NT
  {
    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, HWG_NULLPTR, 0, &dwNeeded, &dwReturned);

    pinfo4 = hb_xgrab(dwNeeded);

    EnumPrinters(PRINTER_ENUM_LOCAL, HWG_NULLPTR, 4, (PBYTE)pinfo4, dwNeeded, &dwNeeded, &dwReturned);
    hDC = CreateDC(HWG_NULLPTR, pinfo4->pPrinterName, HWG_NULLPTR, HWG_NULLPTR);

    hb_xfree(pinfo4);
  }
  hwg_ret_HDC(hDC);
}

HB_FUNC(STARTDOC)
{
  void *hStr;
  DOCINFO di;

  di.cbSize = sizeof(DOCINFO);
  di.lpszDocName = HB_PARSTR(2, &hStr, HWG_NULLPTR);
  di.lpszOutput = HWG_NULLPTR;
  di.lpszDatatype = HWG_NULLPTR;
  di.fwType = 0;

  hb_retnl((LONG)StartDoc(hwg_par_HDC(1), &di));

  hb_strfree(hStr);
}

HB_FUNC(ENDDOC)
{
  EndDoc(hwg_par_HDC(1));
}

HB_FUNC(STARTPAGE)
{
  hb_retnl((LONG)StartPage(hwg_par_HDC(1)));
}

HB_FUNC(ENDPAGE)
{
  hb_retnl((LONG)EndPage(hwg_par_HDC(1)));
}

HB_FUNC(HWG_DELETEDC)
{
  DeleteDC(hwg_par_HDC(1));
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(DELETEDC, HWG_DELETEDC);
#endif

HB_FUNC(HWG_GETDEVICEAREA)
{
  HDC hDC = hwg_par_HDC(1);
  PHB_ITEM temp;
  PHB_ITEM aMetr = hb_itemArrayNew(9);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, HORZRES));
  hb_itemArrayPut(aMetr, 1, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, VERTRES));
  hb_itemArrayPut(aMetr, 2, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, HORZSIZE));
  hb_itemArrayPut(aMetr, 3, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, VERTSIZE));
  hb_itemArrayPut(aMetr, 4, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, LOGPIXELSX));
  hb_itemArrayPut(aMetr, 5, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, LOGPIXELSY));
  hb_itemArrayPut(aMetr, 6, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, RASTERCAPS));
  hb_itemArrayPut(aMetr, 7, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALWIDTH));
  hb_itemArrayPut(aMetr, 8, temp);
  hb_itemRelease(temp);

  temp = hb_itemPutNL(HWG_NULLPTR, GetDeviceCaps(hDC, PHYSICALHEIGHT));
  hb_itemArrayPut(aMetr, 9, temp);
  hb_itemRelease(temp);

  hb_itemReturnRelease(aMetr);
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(GETDEVICEAREA, HWG_GETDEVICEAREA);
#endif

HB_FUNC(DRAWTEXT)
{
  void *hText;
  HB_SIZE nSize;
  LPCTSTR lpText = HB_PARSTR(2, &hText, &nSize);

  if (lpText) {
    RECT rc;

    rc.left = hb_parni(3);
    rc.top = hb_parni(4);
    rc.right = hb_parni(5);
    rc.bottom = hb_parni(6);

    DrawText(hwg_par_HDC(1), // handle of device context
             lpText,         // address of string
             nSize,          // number of characters in string
             &rc, hb_parni(7));
  }
  hb_strfree(hText);
}
