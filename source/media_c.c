//
// HWGUI - Harbour Win32 GUI library source code:
// C level media functions
//
// Copyright 2003 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include "hwingui.h"
#include <commctrl.h>

#include <hbapiitm.h>
#include <hbvm.h>
#include <hbstack.h>

/*
 *  hwg_PlaySound(cName, lSync, lLoop)
 */
HB_FUNC(HWG_PLAYSOUND)
{
  void *hSound;
  LPCTSTR lpSound = HB_PARSTR(1, &hSound, HWG_NULLPTR);
  HMODULE hmod = HWG_NULLPTR;
  DWORD fdwSound = SND_NODEFAULT | SND_FILENAME;

  if (hb_parl(2))
  {
    fdwSound |= SND_SYNC;
  }
  else
  {
    fdwSound |= SND_ASYNC;
  }

  if (hb_parl(3))
  {
    fdwSound |= SND_LOOP;
  }
  if (!lpSound)
  {
    fdwSound |= SND_PURGE;
  }

  hwg_ret_BOOL(PlaySound(lpSound, hmod, fdwSound) != 0); // TODO: != 0 desnecessário
  hb_strfree(hSound);
}

HB_FUNC(HWG_MCISENDSTRING)
{
  TCHAR cBuffer[256] = {0};
  void *hCommand;

  hb_retnl((LONG)mciSendString(HB_PARSTR(1, &hCommand, HWG_NULLPTR), cBuffer, HB_SIZEOFARRAY(cBuffer),
                               (HB_ISNIL(3)) ? GetActiveWindow() : hwg_par_HWND(3)));
  if (!HB_ISNIL(2))
  {
    HB_STORSTR(cBuffer, 2);
  }
  hb_strfree(hCommand);
}

/* Functions bellow for play video's and wav's*/

HB_FUNC(HWG_MCISENDCOMMAND) // ()
{
  hb_retnl(mciSendCommand(hb_parni(1),             // Device ID
                          hb_parni(2),             // Command Message
                          hb_parnl(3),             // Flags
                          (DWORD_PTR)hb_parc(4))); // Parameter Block
}

//----------------------------------------------------------------------------//

HB_FUNC(HWG_MCIGETERRORSTRING) // ()
{
  TCHAR cBuffer[256] = {0};

  hwg_ret_BOOL(mciGetErrorString(hb_parnl(1), // Error Code
                                 cBuffer, HB_SIZEOFARRAY(cBuffer)));
  HB_STORSTR(cBuffer, 2);
}

//----------------------------------------------------------------------------//

HB_FUNC(HWG_NMCIOPEN)
{
  MCI_OPEN_PARMS mciOpenParms;
  DWORD dwFlags = MCI_OPEN_ELEMENT;
  void *hDevice, *hName;

  memset(&mciOpenParms, 0, sizeof(mciOpenParms));

  mciOpenParms.lpstrDeviceType = HB_PARSTR(1, &hDevice, HWG_NULLPTR);
  mciOpenParms.lpstrElementName = HB_PARSTR(2, &hName, HWG_NULLPTR);
  if (mciOpenParms.lpstrElementName)
  {
    dwFlags |= MCI_OPEN_TYPE;
  }

  hb_retnl(mciSendCommand(0, MCI_OPEN, dwFlags, (DWORD_PTR)(LPMCI_OPEN_PARMS)&mciOpenParms));

  hb_storni(mciOpenParms.wDeviceID, 3);
  hb_strfree(hDevice);
  hb_strfree(hName);
}

//----------------------------------------------------------------------------//

HB_FUNC(HWG_NMCIPLAY)
{
  MCI_PLAY_PARMS mciPlayParms;
  DWORD dwFlags = 0;

  memset(&mciPlayParms, 0, sizeof(mciPlayParms));

  if ((mciPlayParms.dwFrom = hb_parnl(2)) != 0)
  {
    dwFlags |= MCI_FROM;
  }

  if ((mciPlayParms.dwTo = hb_parnl(3)) != 0)
  {
    dwFlags |= MCI_TO;
  }

  //   if( ( mciPlayParms.dwCallback = ( DWORD_PTR ) hb_parnint(4) ) != 0 )
  //      dwFlags |= MCI_NOTIFY;

  hb_retnl(mciSendCommand(hb_parni(1), // Device ID
                          MCI_PLAY, dwFlags, (DWORD_PTR)(LPMCI_PLAY_PARMS)&mciPlayParms));
}

//----------------------------------------------------------------------------//

HB_FUNC(HWG_NMCIWINDOW)
{
  MCI_ANIM_WINDOW_PARMS mciWindowParms;
  HWND hWnd = hwg_par_HWND(2);

  mciWindowParms.hWnd = hWnd;

  hb_retnl(mciSendCommand(hb_parni(1), MCI_WINDOW, MCI_ANIM_WINDOW_HWND | MCI_ANIM_WINDOW_DISABLE_STRETCH,
                          (LONG_PTR)(LPMCI_ANIM_WINDOW_PARMS)&mciWindowParms));
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(PLAYSOUND, HWG_PLAYSOUND);
HB_FUNC_TRANSLATE(MCISENDSTRING, HWG_MCISENDSTRING);
HB_FUNC_TRANSLATE(MCISENDCOMMAND, HWG_MCISENDCOMMAND);
HB_FUNC_TRANSLATE(MCIGETERRORSTRING, HWG_MCIGETERRORSTRING);
HB_FUNC_TRANSLATE(NMCIOPEN, HWG_NMCIOPEN);
HB_FUNC_TRANSLATE(NMCIPLAY, HWG_NMCIPLAY);
HB_FUNC_TRANSLATE(NMCIWINDOW, HWG_NMCIWINDOW);
#endif
