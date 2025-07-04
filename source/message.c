//
// HWGUI - Harbour Win32 GUI library source code:
// C level messages functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "hwingui.h"
#include <commctrl.h>
#include <richedit.h>

static int s_msgbox(UINT uType)
{
  void *hText, *hTitle;
  int iResult;

  iResult = MessageBox(GetActiveWindow(), HB_PARSTR(1, &hText, HWG_NULLPTR), HB_PARSTRDEF(2, &hTitle, HWG_NULLPTR), uType);
  hb_strfree(hText);
  hb_strfree(hTitle);

  return iResult;
}

HB_FUNC(HWG_MSGINFO)
{
  s_msgbox(MB_OK | MB_ICONINFORMATION);
}

HB_FUNC(HWG_MSGSTOP)
{
  s_msgbox(MB_OK | MB_ICONSTOP);
}

HB_FUNC(HWG_MSGOKCANCEL)
{
  hb_retni(s_msgbox(MB_OKCANCEL | MB_ICONQUESTION));
}

HB_FUNC(HWG_MSGYESNO)
{
  hb_retl(s_msgbox(MB_YESNO | MB_ICONQUESTION) == IDYES);
}

HB_FUNC(HWG_MSGNOYES)
{
  hb_retl(s_msgbox(MB_YESNO | MB_ICONQUESTION | MB_DEFBUTTON2) == IDYES);
}

HB_FUNC(HWG_MSGYESNOCANCEL)
{
  hb_retni(s_msgbox(MB_YESNOCANCEL | MB_ICONQUESTION));
}

HB_FUNC(HWG_MSGEXCLAMATION)
{
  s_msgbox(MB_ICONEXCLAMATION | MB_OK | MB_SYSTEMMODAL);
}

HB_FUNC(HWG_MSGRETRYCANCEL)
{
  hb_retni(s_msgbox(MB_RETRYCANCEL | MB_ICONQUESTION | MB_ICONQUESTION));
}

HB_FUNC(HWG_MSGBEEP)
{
  MessageBeep((hb_pcount() == 0) ? (LONG)0xFFFFFFFF : hb_parnl(1));
}

HB_FUNC(HWG_MSGTEMP)
{
  char cres[60];
  LPCTSTR msg;

#if __HARBOUR__ - 0 >= 0x010100
  hb_snprintf(cres, sizeof(cres), "WS_OVERLAPPEDWINDOW: %lx NM_FIRST: %d ", (LONG)WS_OVERLAPPEDWINDOW, NM_FIRST);
#else
  sprintf(cres, "WS_OVERLAPPEDWINDOW: %lx NM_FIRST: %d ", (LONG)WS_OVERLAPPEDWINDOW, NM_FIRST);
#endif
  {
#ifdef UNICODE
    TCHAR wcres[60];
    MultiByteToWideChar(CP_ACP, 0, cres, -1, wcres, HB_SIZEOFARRAY(wcres));
    msg = wcres;
#else
    msg = cres;
#endif
    hb_retni(MessageBox(GetActiveWindow(), msg, TEXT("DialogBaseUnits"), MB_OKCANCEL | MB_ICONQUESTION));
  }
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(MSGINFO, HWG_MSGINFO)
HB_FUNC_TRANSLATE(MSGSTOP, HWG_MSGSTOP)
HB_FUNC_TRANSLATE(MSGOKCANCEL, HWG_MSGOKCANCEL)
HB_FUNC_TRANSLATE(MSGYESNO, HWG_MSGYESNO)
HB_FUNC_TRANSLATE(MSGNOYES, HWG_MSGNOYES)
HB_FUNC_TRANSLATE(MSGYESNOCANCEL, HWG_MSGYESNOCANCEL)
HB_FUNC_TRANSLATE(MSGEXCLAMATION, HWG_MSGEXCLAMATION)
HB_FUNC_TRANSLATE(MSGRETRYCANCEL, HWG_MSGRETRYCANCEL)
HB_FUNC_TRANSLATE(MSGBEEP, HWG_MSGBEEP)
HB_FUNC_TRANSLATE(MSGTEMP, HWG_MSGTEMP)
#endif
