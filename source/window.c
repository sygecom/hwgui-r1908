//
// HWGUI - Harbour Win32 GUI library source code:
// C level windows functions
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#define OEMRESOURCE
#include "hwingui.h"
#include <commctrl.h>
#if defined(__DMC__)
#include "missing.h"
#endif

#include <hbapifs.h>
#include <hbapiitm.h>
#include <hbapicdp.h>
#include <hbvm.h>
#include <hbstack.h>
#if !defined(__XHARBOUR__)
#include <hbapicls.h>
#endif

#include <math.h>
#include <float.h>
#include <limits.h>

#define FIRST_MDICHILD_ID 501
#define WND_MDICHILD 3

static LRESULT CALLBACK s_MainWndProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_FrameWndProc(HWND, UINT, WPARAM, LPARAM);
static LRESULT CALLBACK s_MDIChildWndProc(HWND, UINT, WPARAM, LPARAM);

static HWND s_hMytoolMenu = HWG_NULLPTR;
static HHOOK s_OrigDockHookProc;

HWND aWindows[2] = {0, 0};
PHB_DYNS pSym_onEvent = HWG_NULLPTR;
PHB_DYNS pSym_onEven_Tool = HWG_NULLPTR;

static LPCTSTR s_szChild = TEXT("MDICHILD");

static void s_doEvents(void)
{
  MSG msg;

  while (PeekMessage(&msg, HWG_NULLPTR, 0, 0, PM_REMOVE))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  };
}

static void s_ClearKeyboard(void)
{
  MSG msg;

  // For keyboard
  while (PeekMessage(&msg, HWG_NULLPTR, WM_KEYFIRST, WM_KEYLAST, PM_REMOVE))
    ;
  // For Mouse
  while (PeekMessage(&msg, HWG_NULLPTR, WM_MOUSEFIRST, WM_MOUSELAST, PM_REMOVE))
    ;
}

/* Consume all queued events, useful to update all the controls... I split in 2 parts because I feel
 * that s_doEvents should be called internally by some other functions...
 */
HB_FUNC(HWG_DOEVENTS)
{
  s_doEvents();
}

/*  Creates main application window
    InitMainWindow(szAppName, cTitle, cMenu, hIcon, nBkColor, nStyle, nLeft, nTop, nWidth, nHeight)
*/

HB_FUNC(HWG_INITMAINWINDOW)
{
  HWND hWnd = HWG_NULLPTR;
  WNDCLASS wndclass;
  HANDLE hInstance = GetModuleHandle(HWG_NULLPTR);
  DWORD ExStyle = 0;
  PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT), temp;
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, HWG_NULLPTR);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, HWG_NULLPTR);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, HWG_NULLPTR);
  DWORD nStyle = hwg_par_DWORD(7);
  int width = hwg_par_int(10);
  int height = hwg_par_int(11);

  if (!aWindows[0])
  {
    wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
    wndclass.lpfnWndProc = s_MainWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = (HINSTANCE)hInstance;
    wndclass.hIcon = (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon((HINSTANCE)hInstance, TEXT(""));
    wndclass.hCursor = LoadCursor(HWG_NULLPTR, IDC_ARROW);
    wndclass.hbrBackground = (((hb_pcount() > 5 && !HB_ISNIL(6)) ? ((hb_parnl(6) == -1) ? HWG_NULLPTR : hwg_par_HBRUSH(6))
                                                                 : (HBRUSH)(COLOR_WINDOW + 1)));
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    if (RegisterClass(&wndclass))
    {
      hWnd = CreateWindowEx(ExStyle, lpAppName, lpTitle, WS_OVERLAPPEDWINDOW | nStyle, hwg_par_int(8), hwg_par_int(9),
                            (!width) ? (LONG)CW_USEDEFAULT : width, (!height) ? (LONG)CW_USEDEFAULT : height, HWG_NULLPTR,
                            HWG_NULLPTR, (HINSTANCE)hInstance, HWG_NULLPTR);

      temp = hb_itemPutNL(HWG_NULLPTR, 1);
      SetObjectVar(pObject, "_NHOLDER", temp);
      hb_itemRelease(temp);
      SetWindowObject(hWnd, pObject);

      aWindows[0] = hWnd;
    }
  }
  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);

  hwg_ret_HWND(hWnd);
}

HB_FUNC(HWG_CENTERWINDOW)
{
  RECT rect, rectcli;
  int w, h, x, y;

  GetWindowRect(hwg_par_HWND(1), &rect);

  if (hb_parni(2) == WND_MDICHILD)
  {
    GetWindowRect(aWindows[1], &rectcli);
    x = rectcli.right - rectcli.left;
    y = rectcli.bottom - rectcli.top;
    w = rect.right - rect.left;
    h = rect.bottom - rect.top;
  }
  else
  {
    w = rect.right - rect.left;
    h = rect.bottom - rect.top;
    x = GetSystemMetrics(SM_CXSCREEN);
    y = GetSystemMetrics(SM_CYSCREEN);
  }
  SetWindowPos(hwg_par_HWND(1), HWND_TOP, (x - w) / 2, (y - h) / 2, 0, 0,
               SWP_NOSIZE + SWP_NOACTIVATE + SWP_FRAMECHANGED + SWP_NOSENDCHANGING);
}

void ProcessMessage(MSG msg, HACCEL hAcceler, BOOL lMdi)
{
  int i;
  HWND hwndGoto;

  for (i = 0; i < iDialogs; i++)
  {
    hwndGoto = aDialogs[i];
    if (IsWindow(hwndGoto) && IsDialogMessage(hwndGoto, &msg))
    {
      break;
    }
  }

  if (i == iDialogs)
  {
    if (lMdi && TranslateMDISysAccel(aWindows[1], &msg))
    {
      return;
    }

    if (!hAcceler || !TranslateAccelerator(aWindows[0], hAcceler, &msg))
    {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
  }
}

void ProcessMdiMessage(HWND hJanBase, HWND hJanClient, MSG msg, HACCEL hAcceler)
{
  if (!TranslateMDISysAccel(hJanClient, &msg) && !TranslateAccelerator(hJanBase, hAcceler, &msg))
  {
    TranslateMessage(&msg);
    DispatchMessage(&msg);
  }
}

/*
 *  HWG_ACTIVATEMAINWINDOW(lShow, hAccel, lMaximize, lMinimize)
 */
HB_FUNC(HWG_ACTIVATEMAINWINDOW)
{
  HACCEL hAcceler = (HB_ISNIL(2)) ? HWG_NULLPTR : (HACCEL)(LONG_PTR)hb_parnl(2);
  MSG msg;

  if (hb_parl(1))
  {
    ShowWindow(aWindows[0], (HB_ISLOG(3) && hb_parl(3))
                                ? SW_SHOWMAXIMIZED
                                : ((HB_ISLOG(4) && hb_parl(4)) ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
  }

  while (GetMessage(&msg, HWG_NULLPTR, 0, 0))
  {
    ProcessMessage(msg, hAcceler, 0);
  }
}

HB_FUNC(HWG_PROCESSMESSAGE)
{
  MSG msg;
  BOOL lMdi = (HB_ISNIL(1)) ? 0 : hb_parl(1);
  int nSleep = (HB_ISNIL(2)) ? 1 : hb_parni(2);

  if (PeekMessage(&msg, HWG_NULLPTR, 0, 0, PM_REMOVE))
  {
    ProcessMessage(msg, 0, lMdi);
  }

  SleepEx(nSleep, TRUE);
}

/* 22/09/2005 - <maurilio.longo@libero.it>
      It can be used to see if there are messages awaiting of a certain
      type, but it does not retrieve them
*/
HB_FUNC(HWG_PEEKMESSAGE)
{
  MSG msg;

  hwg_ret_BOOL(PeekMessage(&msg, hwg_par_HWND(1), // handle of window whose message queue will be searched
                           hwg_par_UINT(2),       // wMsgFilterMin,
                           hwg_par_UINT(3),       // wMsgFilterMax,
                           PM_NOREMOVE));
}

HB_FUNC(HWG_INITCHILDWINDOW)
{
  HWND hWnd = HWG_NULLPTR;
  WNDCLASS wndclass;
  HMODULE /*HANDLE*/ hInstance = GetModuleHandle(HWG_NULLPTR);
  PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT), temp;
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, HWG_NULLPTR);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, HWG_NULLPTR);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, HWG_NULLPTR);
  DWORD nStyle = hwg_par_DWORD(7);
  int width = hwg_par_int(10);
  int height = hwg_par_int(11);
  HWND hParent = hwg_par_HWND(12);
  BOOL fRegistered = TRUE;

  if (!GetClassInfo(hInstance, lpAppName, &wndclass))
  {
    wndclass.style = CS_OWNDC | CS_VREDRAW | CS_HREDRAW | CS_DBLCLKS;
    wndclass.lpfnWndProc = s_MainWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = (HINSTANCE)hInstance;
    wndclass.hIcon = (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon((HINSTANCE)hInstance, TEXT(""));
    wndclass.hCursor = LoadCursor(HWG_NULLPTR, IDC_ARROW);
    wndclass.hbrBackground = (((hb_pcount() > 5 && !HB_ISNIL(6)) ? ((hb_parnl(6) == -1) ? HWG_NULLPTR : hwg_par_HBRUSH(6))
                                                                 : (HBRUSH)(COLOR_WINDOW + 1)));
    /*
       wndclass.hbrBackground = ( ( (hb_pcount()>5 && !HB_ISNIL(6))?
       ( (hb_parnl(6)==-1)? (HBRUSH)(COLOR_WINDOW+1) :
       CreateSolidBrush( hb_parnl(6) ) )
       : (HBRUSH)(COLOR_WINDOW+1) ) );
     */
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    // UnregisterClass(lpAppName, (HINSTANCE)hInstance);
    if (!RegisterClass(&wndclass))
    {
      fRegistered = FALSE;
#ifdef __XHARBOUR__
      MessageBox(GetActiveWindow(), lpAppName, TEXT("Register Child Wnd Class"), MB_OK | MB_ICONSTOP);
#endif
    }
  }

  if (fRegistered)
  {
    hWnd = CreateWindowEx(WS_EX_MDICHILD, lpAppName, lpTitle, WS_OVERLAPPEDWINDOW | nStyle, hwg_par_int(8),
                          hwg_par_int(9), (!width) ? (LONG)CW_USEDEFAULT : width,
                          (!height) ? (LONG)CW_USEDEFAULT : height, hParent, HWG_NULLPTR, (HINSTANCE)hInstance, HWG_NULLPTR);

    temp = hb_itemPutNL(HWG_NULLPTR, 1);
    SetObjectVar(pObject, "_NHOLDER", temp);
    hb_itemRelease(temp);
    SetWindowObject(hWnd, pObject);
  }

  hwg_ret_HWND(hWnd);

  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);
}

HB_FUNC(HWG_ACTIVATECHILDWINDOW)
{
  // ShowWindow((HWND) HB_PARHANDLE(2), hb_parl(1) ? SW_SHOWNORMAL : SW_HIDE);
  ShowWindow(hwg_par_HWND(2), (HB_ISLOG(3) && hb_parl(3))
                                  ? SW_SHOWMAXIMIZED
                                  : ((HB_ISLOG(4) && hb_parl(4)) ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
}

/*  Creates frame MDI and client window
    InitMainWindow(cTitle, cMenu, cBitmap, hIcon, nBkColor, nStyle, nLeft, nTop, nWidth, nHeight)
*/
HB_FUNC(HWG_INITMDIWINDOW)
{
  HWND hWnd;
  WNDCLASS wndclass, wc;
  HANDLE hInstance = GetModuleHandle(HWG_NULLPTR);
  PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT), temp;
  void *hAppName, *hTitle, *hMenu;
  LPCTSTR lpAppName = HB_PARSTR(2, &hAppName, HWG_NULLPTR);
  LPCTSTR lpTitle = HB_PARSTR(3, &hTitle, HWG_NULLPTR);
  LPCTSTR lpMenu = HB_PARSTR(4, &hMenu, HWG_NULLPTR);
  int width = hwg_par_int(10);
  int height = hwg_par_int(11);

  if (aWindows[0])
  {
    hb_retni(-1);
  }
  else
  {
    // Register frame window
    wndclass.style = 0;
    wndclass.lpfnWndProc = s_FrameWndProc;
    wndclass.cbClsExtra = 0;
    wndclass.cbWndExtra = 0;
    wndclass.hInstance = (HINSTANCE)hInstance;
    wndclass.hIcon = (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon((HINSTANCE)hInstance, TEXT(""));
    wndclass.hCursor = LoadCursor(HWG_NULLPTR, IDC_ARROW);
    wndclass.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1);
    wndclass.lpszMenuName = lpMenu;
    wndclass.lpszClassName = lpAppName;

    if (!RegisterClass(&wndclass))
    {
      hb_retni(-2);
    }
    else
    {
      // Register client window
      wc.lpfnWndProc = (WNDPROC)s_MDIChildWndProc;
      wc.hIcon = (hb_pcount() > 4 && !HB_ISNIL(5)) ? hwg_par_HICON(5) : LoadIcon((HINSTANCE)hInstance, TEXT(""));
      wc.hbrBackground = (hb_pcount() > 5 && !HB_ISNIL(6)) ? hwg_par_HBRUSH(6) : (HBRUSH)(COLOR_WINDOW + 1);
      wc.lpszMenuName = HWG_NULLPTR;
      wc.cbWndExtra = 0;
      wc.lpszClassName = s_szChild;
      wc.cbClsExtra = 0;
      wc.hInstance = (HINSTANCE)hInstance;
      wc.hCursor = LoadCursor(HWG_NULLPTR, IDC_ARROW);
      wc.style = 0;

      if (!RegisterClass(&wc))
      {
        hb_retni(-3);
      }
      else
      {
        // Create frame window
        hWnd = CreateWindowEx(0, lpAppName, lpTitle, WS_OVERLAPPEDWINDOW, hwg_par_int(8), hwg_par_int(9),
                              (!width) ? (LONG)CW_USEDEFAULT : width, (!height) ? (LONG)CW_USEDEFAULT : height, HWG_NULLPTR,
                              HWG_NULLPTR, (HINSTANCE)hInstance, HWG_NULLPTR);
        if (!hWnd)
        {
          hb_retni(-4);
        }
        else
        {
          temp = hb_itemPutNL(HWG_NULLPTR, 1);
          SetObjectVar(pObject, "_NHOLDER", temp);
          hb_itemRelease(temp);
          SetWindowObject(hWnd, pObject);

          aWindows[0] = hWnd;
          hwg_ret_HWND(hWnd);
        }
      }
    }
  }
  hb_strfree(hAppName);
  hb_strfree(hTitle);
  hb_strfree(hMenu);
}

HB_FUNC(HWG_INITCLIENTWINDOW)
{
  HWND hWnd;
  CLIENTCREATESTRUCT ccs;
  int nPos = (hb_pcount() > 1 && !HB_ISNIL(2)) ? hb_parni(2) : 0;

  // Create client window
  ccs.hWindowMenu = GetSubMenu(GetMenu(aWindows[0]), nPos);
  ccs.idFirstChild = FIRST_MDICHILD_ID;

  hWnd = CreateWindowEx(0, TEXT("MDICLIENT"), HWG_NULLPTR, WS_CHILD | WS_CLIPCHILDREN | MDIS_ALLCHILDSTYLES, hwg_par_int(3),
                        hwg_par_int(4), hwg_par_int(5), hwg_par_int(6), aWindows[0], HWG_NULLPTR, GetModuleHandle(HWG_NULLPTR),
                        (LPVOID)&ccs);

  aWindows[1] = hWnd;
  hwg_ret_HWND(hWnd);
}

HB_FUNC(HWG_ACTIVATEMDIWINDOW)
{
  HACCEL hAcceler = (HB_ISNIL(2)) ? HWG_NULLPTR : (HACCEL)(LONG_PTR)hb_parnl(2);
  MSG msg;

  if (hb_parl(1))
  {
    ShowWindow(aWindows[0], (HB_ISLOG(3) && hb_parl(3))
                                ? SW_SHOWMAXIMIZED
                                : ((HB_ISLOG(4) && hb_parl(4)) ? SW_SHOWMINIMIZED : SW_SHOWNORMAL));
    ShowWindow(aWindows[1], SW_SHOW);
  }

  while (GetMessage(&msg, HWG_NULLPTR, 0, 0))
  {
    // ProcessMessage(msg, hAcceler, 0);
    ProcessMdiMessage(aWindows[0], aWindows[1], msg, hAcceler);
  }
}

/*  Creates child MDI window
    CreateMdiChildWindow(aChildWindow)
    aChildWindow = {cWindowTitle, Nil, aActions, Nil, nStatusWindowID, bStatusWrite}
    aActions = {{nMenuItemID, bAction}, ...}
*/

HB_FUNC(HWG_CREATEMDICHILDWINDOW)
{
  HWND hWnd = HWG_NULLPTR;
  PHB_ITEM pObj = hb_param(1, HB_IT_OBJECT);
  DWORD style = (DWORD)hb_itemGetNL(GetObjectVar(pObj, "STYLE"));
  int y = (int)hb_itemGetNL(GetObjectVar(pObj, "NTOP"));
  int x = (int)hb_itemGetNL(GetObjectVar(pObj, "NLEFT"));
  int width = (int)hb_itemGetNL(GetObjectVar(pObj, "NWIDTH"));
  int height = (int)hb_itemGetNL(GetObjectVar(pObj, "NHEIGHT"));
  void *hTitle;
  LPCTSTR lpTitle = HB_ITEMGETSTR(GetObjectVar(pObj, "TITLE"), &hTitle, HWG_NULLPTR);

  // if( !style )
  //    style = WS_VISIBLE | WS_OVERLAPPEDWINDOW | WS_MAXIMIZE;

  if (!style)
  {
    style = WS_CHILD | WS_OVERLAPPEDWINDOW | (int)hb_parnl(2); // WS_VISIBLE | WS_MAXIMIZE;
  }
  else
  {
    style = style | (int)hb_parnl(2);
  }

  if (aWindows[0])
  {
    hWnd = CreateMDIWindow(
#if (((defined(_MSC_VER) && (_MSC_VER <= 1200)) || defined(__DMC__)) && !defined(__XCC__) && !defined(__POCC__))
        (LPSTR)s_szChild, // pointer to registered child class name
        (LPSTR)lpTitle,   // pointer to window name
#else
        s_szChild, // pointer to registered child class name
        lpTitle,   // pointer to window name
#endif
        style,                 // window style
        x,                     // horizontal position of window
        y,                     // vertical position of window
        width,                 // width of window
        height,                // height of window
        aWindows[1],           // handle to parent window (MDI client)
        GetModuleHandle(HWG_NULLPTR), // handle to application instance
        (LPARAM)&pObj          // application-defined value
    );
  }
  hwg_ret_HWND(hWnd);
  hb_strfree(hTitle);
}

HB_FUNC(HWG_SENDMESSAGE)
{
  void *hText;
  LPCTSTR lpText = HB_PARSTR(4, &hText, HWG_NULLPTR);

  hb_retnl((LONG)SendMessage(hwg_par_HWND(1),   // handle of destination window
                             hwg_par_UINT(2),   // message to send
                             hwg_par_WPARAM(3), // first message parameter
                             lpText            ? (LPARAM)lpText
                             : HB_ISPOINTER(4) ? (LPARAM)HB_PARHANDLE(4)
                                               : hwg_par_LPARAM(4) // second message parameter
                             ));
  hb_strfree(hText);
}

HB_FUNC(HWG_POSTMESSAGE)
{

  hb_retnl((LONG)PostMessage(hwg_par_HWND(1), // handle of destination window
                             hwg_par_UINT(2), // message to send
                             HB_ISPOINTER(3) ? (WPARAM)HB_PARHANDLE(3) : hwg_par_WPARAM(3), // first message parameter
                             hwg_par_LPARAM(4)                                              // second message parameter
                             ));
}

HB_FUNC(HWG_SETFOCUS)
{
  hwg_ret_HWND(SetFocus(hwg_par_HWND(1)));
}

HB_FUNC(HWG_GETFOCUS)
{
  hwg_ret_HWND(GetFocus());
}

HB_FUNC(HWG_SELFFOCUS)
{
  HWND hWnd = HB_ISNIL(2) ? GetFocus() : hwg_par_HWND(2);
  hb_retl(hwg_par_HWND(1) == hWnd);
}

HB_FUNC(HWG_SETWINDOWOBJECT)
{
  SetWindowObject(hwg_par_HWND(1), hb_param(2, HB_IT_OBJECT));
}

void SetWindowObject(HWND hWnd, PHB_ITEM pObject)
{
  SetWindowLongPtr(hWnd, GWLP_USERDATA, pObject ? (LPARAM)hb_itemNew(pObject) : 0);
}

HB_FUNC(HWG_GETWINDOWOBJECT)
{
  hb_itemReturn((PHB_ITEM)GetWindowLongPtr(hwg_par_HWND(1), GWLP_USERDATA));
}

HB_FUNC(HWG_SETWINDOWTEXT)
{
  void *hText;

  SetWindowText(hwg_par_HWND(1), HB_PARSTR(2, &hText, HWG_NULLPTR));
  hb_strfree(hText);
}

HB_FUNC(HWG_GETWINDOWTEXT)
{
  HWND hWnd = hwg_par_HWND(1);
  ULONG ulLen = (ULONG)SendMessage(hWnd, WM_GETTEXTLENGTH, 0, 0);
  LPTSTR cText = (TCHAR *)hb_xgrab((ulLen + 1) * sizeof(TCHAR));

  ulLen = (ULONG)SendMessage(hWnd, WM_GETTEXT, (WPARAM)(ulLen + 1), (LPARAM)cText);

  HB_RETSTRLEN(cText, ulLen);
  hb_xfree(cText);
}

HB_FUNC(HWG_SETWINDOWFONT)
{
  SendMessage(hwg_par_HWND(1), WM_SETFONT, hwg_par_WPARAM(2), MAKELPARAM((HB_ISNIL(3)) ? 0 : hb_parl(3), 0));
}

HB_FUNC(HWG_ENABLEWINDOW)
{
  HWND hWnd = hwg_par_HWND(1);
  BOOL lEnable = hb_parl(2);

  // ShowWindow(hWnd, (lEnable)? SW_SHOWNORMAL:SW_HIDE);
  EnableWindow(hWnd,   // handle to window
               lEnable // flag for enabling or disabling input
  );
}

HB_FUNC(HWG_DESTROYWINDOW)
{
  DestroyWindow(hwg_par_HWND(1));
}

HB_FUNC(HWG_HIDEWINDOW)
{
  ShowWindow(hwg_par_HWND(1), SW_HIDE);
}

HB_FUNC(HWG_SHOWWINDOW)
{
  ShowWindow(hwg_par_HWND(1), (HB_ISNIL(2)) ? SW_SHOW : hb_parni(2));
}

HB_FUNC(HWG_RESTOREWINDOW)
{
  ShowWindow(hwg_par_HWND(1), SW_RESTORE);
}

HB_FUNC(HWG_ISICONIC)
{
  hwg_ret_BOOL(IsIconic(hwg_par_HWND(1)));
}

HB_FUNC(HWG_ISWINDOWENABLED)
{
  hwg_ret_BOOL(IsWindowEnabled(hwg_par_HWND(1)));
}

HB_FUNC(HWG_ISWINDOWVISIBLE)
{
  hwg_ret_BOOL(IsWindowVisible(hwg_par_HWND(1)));
}

HB_FUNC(HWG_GETACTIVEWINDOW)
{
  hwg_ret_HWND(GetActiveWindow());
}

HB_FUNC(HWG_GETINSTANCE)
{
  hb_retnint((LONG_PTR)GetModuleHandle(HWG_NULLPTR));
}

HB_FUNC(HWG_SETWINDOWSTYLE)
{
  hb_retnint(SetWindowLongPtr(hwg_par_HWND(1), GWL_STYLE, hb_parnl(2)));
}

HB_FUNC(HWG_GETWINDOWSTYLE)
{
  hb_retnint(GetWindowLongPtr(hwg_par_HWND(1), GWL_STYLE));
}

HB_FUNC(HWG_SETWINDOWEXSTYLE)
{
  hb_retnint(SetWindowLongPtr(hwg_par_HWND(1), GWL_EXSTYLE, hb_parnl(2)));
}

HB_FUNC(HWG_GETWINDOWEXSTYLE)
{
  hb_retnint(GetWindowLongPtr(hwg_par_HWND(1), GWL_EXSTYLE));
}

HB_FUNC(HWG_FINDWINDOW)
{
  void *hClassName, *hWindowName;

  hwg_ret_HWND(FindWindow(HB_PARSTR(1, &hClassName, HWG_NULLPTR), HB_PARSTR(2, &hWindowName, HWG_NULLPTR)));
  hb_strfree(hClassName);
  hb_strfree(hWindowName);
}

HB_FUNC(HWG_SETFOREGROUNDWINDOW)
{
  hwg_ret_BOOL(SetForegroundWindow(hwg_par_HWND(1)));
}

HB_FUNC(HWG_BRINGWINDOWTOTOP)
{
  hwg_ret_BOOL(BringWindowToTop(hwg_par_HWND(1)));
}

// HB_FUNC(HWG_SETACTIVEWINDOW)
//{
//    hb_retnl(SetActiveWindow((HWND) HB_PARHANDLE(1)));
// }

HB_FUNC(HWG_RESETWINDOWPOS)
{
  RECT rc;

  GetWindowRect(hwg_par_HWND(1), &rc);
  MoveWindow(hwg_par_HWND(1), rc.left, rc.top, rc.right - rc.left + 1, rc.bottom - rc.top, 0);
}

/*
   s_MainWndProc alteradas na HWGUI. Agora as funcoes em hWindow.prg
   retornam 0 para indicar que deve ser usado o processamento default.
*/
static LRESULT CALLBACK s_MainWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  LRESULT res;
  PHB_ITEM pObject = (PHB_ITEM)GetWindowLongPtr(hWnd, GWLP_USERDATA);

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
    return (res == -1) ? DefWindowProc(hWnd, uMsg, wParam, lParam) : res;
  }
  else
  {
    return DefWindowProc(hWnd, uMsg, wParam, lParam);
  }
}

static LRESULT CALLBACK s_FrameWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  LRESULT res;
  PHB_ITEM pObject = (PHB_ITEM)GetWindowLongPtr(hWnd, GWLP_USERDATA);

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
    return (res == -1) ? DefFrameProc(hWnd, aWindows[1], uMsg, wParam, lParam) : res;
  }
  else
  {
    return DefFrameProc(hWnd, aWindows[1], uMsg, wParam, lParam);
  }
}

static LRESULT CALLBACK s_MDIChildWndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
  LRESULT res;
  PHB_ITEM pObject;

  if (uMsg == WM_NCCREATE)
  {
    LPMDICREATESTRUCT cs = (LPMDICREATESTRUCT)(((LPCREATESTRUCT)lParam)->lpCreateParams);
    PHB_ITEM *pObj = (PHB_ITEM *)(cs->lParam);
    PHB_ITEM temp;

    temp = hb_itemPutNL(HWG_NULLPTR, 1);
    SetObjectVar(*pObj, "_NHOLDER", temp);
    hb_itemRelease(temp);

    temp = HB_PUTHANDLE(HWG_NULLPTR, hWnd);
    SetObjectVar(*pObj, "_HANDLE", temp);
    hb_itemRelease(temp);

    SetWindowObject(hWnd, *pObj);
  }

  pObject = (PHB_ITEM)GetWindowLongPtr(hWnd, GWLP_USERDATA);

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
    return (res == -1) ? DefMDIChildProc(hWnd, uMsg, wParam, lParam) : res;
  }
  else
  {
    return DefMDIChildProc(hWnd, uMsg, wParam, lParam);
  }
}

PHB_ITEM GetObjectVar(PHB_ITEM pObject, const char *varname)
{
  /* ( char * ) casting is a hack for old [x]Harbour versions
   * which used wrong hb_objSendMsg() declaration
   */
  return hb_objSendMsg(pObject, (char *)varname, 0);
}

void SetObjectVar(PHB_ITEM pObject, const char *varname, PHB_ITEM pValue)
{
  /* ( char * ) casting is a hack for old [x]Harbour versions
   * which used wrong hb_objSendMsg() declaration
   */
  hb_objSendMsg(pObject, (char *)varname, 1, pValue);
}

#if !defined(HB_HAS_STR_FUNC)

/* these are simple wrapper functions for xHarbour and older Harbour
 * versions which do not support automatic UNICODE conversions
 */

static const char s_szConstStr[1] = {0};

const char *hwg_strnull(const char *str)
{
  return str ? str : "";
}

const char *hwg_strget(PHB_ITEM pItem, void **phStr, HB_SIZE *pnLen)
{
  const char *pStr;

  if (pItem && HB_IS_STRING(pItem))
  {
    *phStr = (void *)s_szConstStr;
    pStr = hb_itemGetCPtr(pItem);
    if (pnLen)
    {
      *pnLen = hb_itemGetCLen(pItem);
    }
  }
  else
  {
    *phStr = HWG_NULLPTR;
    pStr = HWG_NULLPTR;
    if (pnLen)
    {
      *pnLen = 0;
    }
  }
  return pStr;
}

HB_SIZE hwg_strcopy(PHB_ITEM pItem, char *pStr, HB_SIZE nLen)
{
  if (pItem && HB_IS_STRING(pItem))
  {
    HB_SIZE size = hb_itemGetCLen(pItem);

    if (pStr)
    {
      if (size > nLen)
      {
        size = nLen;
      }
      if (size)
      {
        memcpy(pStr, hb_itemGetCPtr(pItem), size);
      }
      if (size < nLen)
      {
        pStr[size] = '\0';
      }
    }
    else if (nLen && size > nLen)
    {
      size = nLen;
    }
    return size;
  }
  else if (pStr && nLen)
  {
    pStr[0] = '\0';
  }

  return 0;
}

char *hwg_strunshare(void **phStr, const char *pStr, HB_SIZE nLen)
{
  if (pStr == HWG_NULLPTR || phStr == HWG_NULLPTR || *phStr == HWG_NULLPTR)
  {
    return HWG_NULLPTR;
  }

  if (*phStr == (void *)s_szConstStr && nLen > 0)
  {
    char *pszDest = (char *)hb_xgrab((nLen + 1) * sizeof(char));
    memcpy(pszDest, pStr, nLen * sizeof(char));
    pszDest[nLen] = 0;
    *phStr = (void *)pszDest;

    return pszDest;
  }

  return (char *)pStr;
}

void hwg_strfree(void *hString)
{
  if (hString && hString != (void *)s_szConstStr)
  {
    hb_xfree(hString);
  }
}
#endif /* !HB_HAS_STR_FUNC */

#if !defined(HB_EMULATE_STR_API)

static int s_iVM_CP = CP_ACP; /* CP_OEMCP */

static const wchar_t s_wszConstStr[1] = {0};

const wchar_t *hwg_wstrnull(const wchar_t *str)
{
  return str ? str : L"";
}

const wchar_t *hwg_wstrget(PHB_ITEM pItem, void **phStr, HB_SIZE *pnLen)
{
  const wchar_t *pStr;

  if (pItem && HB_IS_STRING(pItem))
  {
    HB_SIZE nLen = hb_itemGetCLen(pItem), nDest = 0;
    const char *pszText = hb_itemGetCPtr(pItem);

    if (nLen)
    {
      nDest = MultiByteToWideChar(s_iVM_CP, 0, pszText, (int)nLen, HWG_NULLPTR, 0);
    }

    if (nDest == 0)
    {
      *phStr = (void *)s_wszConstStr;
      pStr = s_wszConstStr;
    }
    else
    {
      wchar_t *pResult = (wchar_t *)hb_xgrab((nDest + 1) * sizeof(wchar_t));

      pResult[nDest] = 0;
      nDest = MultiByteToWideChar(s_iVM_CP, 0, pszText, (int)nLen, pResult, (int)nDest);
      *phStr = (void *)pResult;
      pStr = pResult;
    }
    if (pnLen)
    {
      *pnLen = nDest;
    }
  }
  else
  {
    *phStr = HWG_NULLPTR;
    pStr = HWG_NULLPTR;
    if (pnLen)
    {
      *pnLen = 0;
    }
  }
  return pStr;
}

void hwg_wstrlenset(PHB_ITEM pItem, const wchar_t *pStr, HB_SIZE nLen)
{
  if (pItem)
  {
    HB_SIZE nDest = 0;

    if (pStr != HWG_NULLPTR && nLen > 0)
    {
      nDest = WideCharToMultiByte(s_iVM_CP, 0, pStr, (int)nLen, HWG_NULLPTR, 0, HWG_NULLPTR, HWG_NULLPTR);
    }

    if (nDest)
    {
      char *pResult = (char *)hb_xgrab(nDest + 1);

      nDest = WideCharToMultiByte(s_iVM_CP, 0, pStr, (int)nLen, pResult, (int)nDest, HWG_NULLPTR, HWG_NULLPTR);
      hb_itemPutCLPtr(pItem, pResult, nDest);
    }
    else
    {
      hb_itemPutC(pItem, HWG_NULLPTR);
    }
  }
}

PHB_ITEM hwg_wstrlenput(PHB_ITEM pItem, const wchar_t *pStr, HB_SIZE nLen)
{
  if (pItem == HWG_NULLPTR)
  {
    pItem = hb_itemNew(HWG_NULLPTR);
  }

  hwg_wstrlenset(pItem, pStr, nLen);

  return pItem;
}

PHB_ITEM hwg_wstrput(PHB_ITEM pItem, const wchar_t *pStr)
{
  return hwg_wstrlenput(pItem, pStr, pStr ? wcslen(pStr) : 0);
}

void hwg_wstrset(PHB_ITEM pItem, const wchar_t *pStr)
{
  hwg_wstrlenset(pItem, pStr, pStr ? wcslen(pStr) : 0);
}

HB_SIZE hwg_wstrcopy(PHB_ITEM pItem, wchar_t *pStr, HB_SIZE nLen)
{
  if (pItem && HB_IS_STRING(pItem))
  {
    const char *text = hb_itemGetCPtr(pItem);
    HB_SIZE size = hb_itemGetCLen(pItem);

    if (pStr)
    {
      size = MultiByteToWideChar(s_iVM_CP, 0, text, (int)size, pStr, (int)nLen);
      if (size < nLen)
      {
        pStr[size] = '\0';
      }
    }
    else
    {
      size = MultiByteToWideChar(s_iVM_CP, 0, text, (int)size, HWG_NULLPTR, 0);
      if (nLen && size > nLen)
      {
        size = nLen;
      }
    }
    return size;
  }
  else if (pStr && nLen)
  {
    pStr[0] = '\0';
  }

  return 0;
}

wchar_t *hwg_wstrunshare(void **phStr, const wchar_t *pStr, HB_SIZE nLen)
{
  if (pStr == HWG_NULLPTR || phStr == HWG_NULLPTR || *phStr == HWG_NULLPTR)
  {
    return HWG_NULLPTR;
  }

  if (*phStr == (void *)s_wszConstStr && nLen > 0)
  {
    wchar_t *pszDest = (wchar_t *)hb_xgrab((nLen + 1) * sizeof(wchar_t));
    memcpy(pszDest, pStr, nLen * sizeof(wchar_t));
    pszDest[nLen] = 0;
    *phStr = (void *)pszDest;

    return pszDest;
  }

  return (wchar_t *)pStr;
}

void hwg_wstrfree(void *hString)
{
  if (hString && hString != (void *)s_wszConstStr)
  {
    hb_xfree(hString);
  }
}

#endif /* HB_EMULATE_STR_API */

HB_FUNC(HWG_SETUTF8)
{
#if defined(HB_EMULATE_STR_API)
  s_iVM_CP = CP_UTF8;
#elif !defined(__XHARBOUR__)
  PHB_CODEPAGE cdp = hb_cdpFindExt("UTF8");

  if (cdp)
  {
    hb_vmSetCDP(cdp);
  }
#endif
}

HB_FUNC(HWG_EXITPROCESS)
{
  ExitProcess(0);
}

HB_FUNC(HWG_DECREASEHOLDERS)
{
  /*
     PHB_ITEM pObject = hb_param(1, HB_IT_OBJECT);
     #ifndef  UIHOLDERS
     if( pObject->item.asArray.value->ulHolders )
        pObject->item.asArray.value->ulHolders--;
     #else
     if( pObject->item.asArray.value->uiHolders )
        pObject->item.asArray.value->uiHolders--;
     #endif
  */
  HWND hWnd = hwg_par_HWND(1);
  PHB_ITEM pObject = (PHB_ITEM)GetWindowLongPtr(hWnd, GWLP_USERDATA);

  if (pObject)
  {
    hb_itemRelease(pObject);
    SetWindowLongPtr(hWnd, GWLP_USERDATA, 0);
  }
}

HB_FUNC(HWG_SETTOPMOST)
{
  hwg_ret_BOOL(SetWindowPos(hwg_par_HWND(1), HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE));
}

HB_FUNC(HWG_REMOVETOPMOST)
{
  hwg_ret_BOOL(SetWindowPos(hwg_par_HWND(1), HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE));
}

HB_FUNC(HWG_CHILDWINDOWFROMPOINT)
{
  HWND hWnd = hwg_par_HWND(1);
  HWND child;
  POINT pt;

  pt.x = hb_parnl(2);
  pt.y = hb_parnl(3);
  child = ChildWindowFromPoint(hWnd, pt);

  hwg_ret_HWND(child);
}

HB_FUNC(HWG_WINDOWFROMPOINT)
{
  HWND hWnd = hwg_par_HWND(1);
  HWND child;
  POINT pt;

  pt.x = hb_parnl(2);
  pt.y = hb_parnl(3);
  ClientToScreen(hWnd, &pt);
  child = WindowFromPoint(pt);

  hwg_ret_HWND(child);
}

HB_FUNC(HWG_MAKEWPARAM)
{
  WPARAM p;

  p = MAKEWPARAM((WORD)hb_parnl(1), (WORD)hb_parnl(2));
  hb_retnl((LONG)p);
}

HB_FUNC(HWG_MAKELPARAM)
{
  LPARAM p;

  p = MAKELPARAM((WORD)hb_parnl(1), (WORD)hb_parnl(2));
  HB_RETHANDLE(p);
}

HB_FUNC(HWG_SETWINDOWPOS)
{
  HWND hWnd = (HB_ISNUM(1) || HB_ISPOINTER(1)) ? hwg_par_HWND(1) : HWG_NULLPTR;
  HWND hWndInsertAfter = (HB_ISNUM(2) || HB_ISPOINTER(2)) ? hwg_par_HWND(2) : HWG_NULLPTR;
  int X = hb_parni(3);
  int Y = hb_parni(4);
  int cx = hb_parni(5);
  int cy = hb_parni(6);
  UINT uFlags = hb_parni(7);

  hwg_ret_BOOL(SetWindowPos(hWnd, hWndInsertAfter, X, Y, cx, cy, uFlags));
}

HB_FUNC(HWG_SETASTYLE)
{
#define MAP_STYLE(src, dest)                                                                                           \
  if (dwStyle & (src))                                                                                                 \
  dwText |= (dest)
#define NMAP_STYLE(src, dest)                                                                                          \
  if (!(dwStyle & (src)))                                                                                              \
  dwText |= (dest)

  DWORD dwStyle = hb_parnl(1), dwText = 0;

  MAP_STYLE(SS_RIGHT, DT_RIGHT);
  MAP_STYLE(SS_CENTER, DT_CENTER);
  MAP_STYLE(SS_CENTERIMAGE, DT_VCENTER | DT_SINGLELINE);
  MAP_STYLE(SS_NOPREFIX, DT_NOPREFIX);
  MAP_STYLE(SS_WORDELLIPSIS, DT_WORD_ELLIPSIS);
  MAP_STYLE(SS_ENDELLIPSIS, DT_END_ELLIPSIS);
  MAP_STYLE(SS_PATHELLIPSIS, DT_PATH_ELLIPSIS);

  NMAP_STYLE(SS_LEFTNOWORDWRAP | SS_CENTERIMAGE | SS_WORDELLIPSIS | SS_ENDELLIPSIS | SS_PATHELLIPSIS, DT_WORDBREAK);

  hb_stornl(dwStyle, 1);
  hb_stornl(dwText, 2);
}

HB_FUNC(HWG_BRINGTOTOP)
{
  HWND hWnd = hwg_par_HWND(1);
  // DWORD ForegroundThreadID;
  // DWORD    ThisThreadID;
  // DWORD      timeout;
  // BOOL Res = FALSE;
  if (IsIconic(hWnd))
  {
    ShowWindow(hWnd, SW_RESTORE);
    hb_retl(TRUE);
    return;
  }

  // ForegroundThreadID = GetWindowThreadProcessID(GetForegroundWindow(),HWG_NULLPTR);
  // ThisThreadID = GetWindowThreadPRocessId(hWnd, HWG_NULLPTR);
  //    if (AttachThreadInput(ThisThreadID, ForegroundThreadID, TRUE) )
  //     {

  BringWindowToTop(hWnd); // IE 5.5 related hack
  SetForegroundWindow(hWnd);
  //    AttachThreadInput(ThisThreadID, ForegroundThreadID,FALSE);
  //    Res = (GetForegroundWindow() == hWnd);
  //    }
  // hb_retl(Res);
}

HB_FUNC(HWG_UPDATEWINDOW)
{
  HWND hWnd = hwg_par_HWND(1);
  UpdateWindow(hWnd);
}

LONG GetFontDialogUnits(HWND h, HFONT f)
{
  HFONT hFont;
  HFONT hFontOld;
  LONG avgWidth;
  HDC hDc;
  LPCTSTR tmp = TEXT("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz");
  SIZE sz;

  HB_SYMBOL_UNUSED(f);

  // get the hdc to the main window
  hDc = GetDC(h);

  // with the current font attributes, select the font
  // hFont = f;//GetStockObject(ANSI_VAR_FONT)   ;
  hFont = (HFONT)GetStockObject(ANSI_VAR_FONT);
  hFontOld = (HFONT)SelectObject(hDc, hFont);

  // get its length, then calculate the average character width

  GetTextExtentPoint32(hDc, tmp, 52, &sz);
  avgWidth = (sz.cx / 52);

  // re-select the previous font & delete the hDc
  SelectObject(hDc, hFontOld);
  DeleteObject(hFont);
  ReleaseDC(h, hDc);

  return avgWidth;
}

HB_FUNC(HWG_GETFONTDIALOGUNITS)
{
  hb_retnl(GetFontDialogUnits(hwg_par_HWND(1), hwg_par_HFONT(2)));
}

LRESULT CALLBACK KbdHook(int code, WPARAM wp, LPARAM lp)
{
  int nId, nBtnNo;
  UINT uId;
  BOOL bPressed;

  if (code < 0)
  {
    return CallNextHookEx(s_OrigDockHookProc, code, wp, lp);
  }

  switch (code)
  {
  case HC_ACTION:
    nBtnNo = (int)SendMessage(s_hMytoolMenu, TB_BUTTONCOUNT, 0, 0);
    nId = (int)SendMessage(s_hMytoolMenu, TB_GETHOTITEM, 0, 0);

    bPressed = (HIWORD(lp) & KF_UP) ? FALSE : TRUE;

    if ((wp == VK_F10 || wp == VK_MENU) && nId == -1 && bPressed)
    {
      SendMessage(s_hMytoolMenu, TB_SETHOTITEM, 0, 0);
      return -100;
    }

    if (wp == VK_LEFT && nId != -1 && nId != 0 && bPressed)
    {
      SendMessage(s_hMytoolMenu, TB_SETHOTITEM, (WPARAM)nId - 1, 0);
      break;
    }

    if (wp == VK_RIGHT && nId != -1 && nId < nBtnNo && bPressed)
    {
      SendMessage(s_hMytoolMenu, TB_SETHOTITEM, (WPARAM)nId + 1, 0);
      break;
    }

    if (SendMessage(s_hMytoolMenu, TB_MAPACCELERATOR, (WPARAM)wp, (LPARAM)&uId) != 0 && nId != -1)
    {
      LRESULT Res = -200;
      PHB_ITEM pObject = (PHB_ITEM)GetWindowLongPtr(s_hMytoolMenu, GWLP_USERDATA);

      if (!pSym_onEven_Tool)
      {
        pSym_onEven_Tool = hb_dynsymFindName("EXECUTETOOL");
      }

      if (pSym_onEven_Tool && pObject)
      {
        hb_vmPushSymbol(hb_dynsymSymbol(pSym_onEven_Tool));
        hb_vmPush(pObject);
        hb_vmPushLong((LONG)uId);

        hb_vmSend(1);
        Res = hb_parnl(-1);
        if (Res == 0)
        {
          SendMessage(s_hMytoolMenu, WM_KEYUP, VK_MENU, 0);
          SendMessage(s_hMytoolMenu, WM_KEYUP, wp, 0);
        }
      }
      return Res;
    }

  default:
    break;
  }
  return CallNextHookEx(s_OrigDockHookProc, code, wp, lp);
}

HB_FUNC(HWG_SETTOOLHANDLE)
{
  HWND h = hwg_par_HWND(1);

  s_hMytoolMenu = h;
}

HB_FUNC(HWG_SETHOOK)
{
  s_OrigDockHookProc = SetWindowsHookEx(WH_KEYBOARD, KbdHook, GetModuleHandle(0), 0);
}

HB_FUNC(HWG_UNSETHOOK)
{
  if (s_OrigDockHookProc)
  {
    UnhookWindowsHookEx(s_OrigDockHookProc);
    s_OrigDockHookProc = 0;
  }
}

HB_FUNC(HWG_GETTOOLBARID)
{
  HWND hMytoolMenu = hwg_par_HWND(1);
  WPARAM wp = hwg_par_WPARAM(2);
  UINT uId;

  if (SendMessage(hMytoolMenu, TB_MAPACCELERATOR, (WPARAM)wp, (LPARAM)&uId) != 0)
  {
    hb_retnl(uId);
  }
  else
  {
    hb_retnl(-1);
  }
}

HB_FUNC(HWG_ISWINDOW)
{
  hwg_ret_BOOL(IsWindow(hwg_par_HWND(1)));
}

HB_FUNC(HWG_MINMAXWINDOW)
{
  MINMAXINFO *lpMMI = (MINMAXINFO *)HB_PARHANDLE(2);
  DWORD m_fxMin;
  DWORD m_fyMin;
  DWORD m_fxMax;
  DWORD m_fyMax;

  m_fxMin = (HB_ISNIL(3)) ? lpMMI->ptMinTrackSize.x : hb_parni(3);
  m_fyMin = (HB_ISNIL(4)) ? lpMMI->ptMinTrackSize.y : hb_parni(4);
  m_fxMax = (HB_ISNIL(5)) ? lpMMI->ptMaxTrackSize.x : hb_parni(5);
  m_fyMax = (HB_ISNIL(6)) ? lpMMI->ptMaxTrackSize.y : hb_parni(6);
  lpMMI->ptMinTrackSize.x = m_fxMin;
  lpMMI->ptMinTrackSize.y = m_fyMin;
  lpMMI->ptMaxTrackSize.x = m_fxMax;
  lpMMI->ptMaxTrackSize.y = m_fyMax;

  //   SendMessage((HWND) HB_PARHANDLE(1),           // handle of window
  //               WM_GETMINMAXINFO, 0, (LPARAM) lpMMI)  ;
}

HB_FUNC(HWG_GETWINDOWPLACEMENT)
{
  HWND hWnd = hwg_par_HWND(1);
  WINDOWPLACEMENT wp;

  wp.length = sizeof(WINDOWPLACEMENT);

  if (GetWindowPlacement(hWnd, &wp))
  {
    hb_retnl(wp.showCmd);
  }
  else
  {
    hb_retnl(-1);
  }
}

HB_FUNC(HWG_FLASHWINDOW)
{
  HWND hWnd = hwg_par_HWND(1);
  int itrue = hb_parni(2);
  FlashWindow(hWnd, itrue);
}

HB_FUNC(HWG_ANSITOUNICODE)
{
  void *hText = (TCHAR *)hb_xgrab((1024 + 1) * sizeof(TCHAR));
#if !defined(__XHARBOUR__)
  hb_parstr_u16(1, HB_CDP_ENDIAN_NATIVE, &hText, HWG_NULLPTR);
#else
  hwg_wstrget(hb_param(1, HB_IT_ANY), &hText, HWG_NULLPTR);
#endif
#if defined(__HARBOURPP__)
  HB_RETSTRLEN((const char *)hText, 1024);
#else
  HB_RETSTRLEN(hText, 1024);
#endif
  hb_strfree(hText);
}

HB_FUNC(HWG_CLEARKEYBOARD)
{
  s_ClearKeyboard();
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(SENDMESSAGE, HWG_SENDMESSAGE);
HB_FUNC_TRANSLATE(POSTMESSAGE, HWG_POSTMESSAGE);
HB_FUNC_TRANSLATE(SETFOCUS, HWG_SETFOCUS);
HB_FUNC_TRANSLATE(GETFOCUS, HWG_GETFOCUS);
HB_FUNC_TRANSLATE(SELFFOCUS, HWG_SELFFOCUS);
HB_FUNC_TRANSLATE(SETWINDOWOBJECT, HWG_SETWINDOWOBJECT);
HB_FUNC_TRANSLATE(GETWINDOWOBJECT, HWG_GETWINDOWOBJECT);
HB_FUNC_TRANSLATE(GETWINDOWTEXT, HWG_GETWINDOWTEXT);
HB_FUNC_TRANSLATE(SETWINDOWFONT, HWG_SETWINDOWFONT);
HB_FUNC_TRANSLATE(ENABLEWINDOW, HWG_ENABLEWINDOW);
HB_FUNC_TRANSLATE(DESTROYWINDOW, HWG_DESTROYWINDOW);
HB_FUNC_TRANSLATE(HIDEWINDOW, HWG_HIDEWINDOW);
HB_FUNC_TRANSLATE(SHOWWINDOW, HWG_SHOWWINDOW);
HB_FUNC_TRANSLATE(ISWINDOWENABLED, HWG_ISWINDOWENABLED);
HB_FUNC_TRANSLATE(ISWINDOWVISIBLE, HWG_ISWINDOWVISIBLE);
HB_FUNC_TRANSLATE(GETACTIVEWINDOW, HWG_GETACTIVEWINDOW);
HB_FUNC_TRANSLATE(GETINSTANCE, HWG_GETINSTANCE);
HB_FUNC_TRANSLATE(RESETWINDOWPOS, HWG_RESETWINDOWPOS);
HB_FUNC_TRANSLATE(EXITPROCESS, HWG_EXITPROCESS);
HB_FUNC_TRANSLATE(SETTOPMOST, HWG_SETTOPMOST);
HB_FUNC_TRANSLATE(REMOVETOPMOST, HWG_REMOVETOPMOST);
HB_FUNC_TRANSLATE(CHILDWINDOWFROMPOINT, HWG_CHILDWINDOWFROMPOINT);
HB_FUNC_TRANSLATE(WINDOWFROMPOINT, HWG_WINDOWFROMPOINT);
HB_FUNC_TRANSLATE(MAKEWPARAM, HWG_MAKEWPARAM);
HB_FUNC_TRANSLATE(MAKELPARAM, HWG_MAKELPARAM);
HB_FUNC_TRANSLATE(SETWINDOWPOS, HWG_SETWINDOWPOS);
HB_FUNC_TRANSLATE(SETASTYLE, HWG_SETASTYLE);
HB_FUNC_TRANSLATE(BRINGTOTOP, HWG_BRINGTOTOP);
HB_FUNC_TRANSLATE(UPDATEWINDOW, HWG_UPDATEWINDOW);
HB_FUNC_TRANSLATE(GETFONTDIALOGUNITS, HWG_GETFONTDIALOGUNITS);
HB_FUNC_TRANSLATE(SETTOOLHANDLE, HWG_SETTOOLHANDLE);
HB_FUNC_TRANSLATE(SETHOOK, HWG_SETHOOK);
HB_FUNC_TRANSLATE(UNSETHOOK, HWG_UNSETHOOK);
HB_FUNC_TRANSLATE(GETTOOLBARID, HWG_GETTOOLBARID);
HB_FUNC_TRANSLATE(ISWINDOW, HWG_ISWINDOW);
HB_FUNC_TRANSLATE(MINMAXWINDOW, HWG_MINMAXWINDOW);
HB_FUNC_TRANSLATE(GETWINDOWPLACEMENT, HWG_GETWINDOWPLACEMENT);
HB_FUNC_TRANSLATE(FLASHWINDOW, HWG_FLASHWINDOW);
HB_FUNC_TRANSLATE(ANSITOUNICODE, HWG_ANSITOUNICODE);
HB_FUNC_TRANSLATE(CLEARKEYBOARD, HWG_CLEARKEYBOARD);
#endif
