//
// Harbour Project source code:
// Registry functions for Harbour
//
// Copyright 2001-2002 Luiz Rafael Culik<culikr@uol.com.br>
// www - http://www.harbour-project.org
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2, or (at your option)
// any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
// Boston, MA 02111-1307 USA (or visit the web site http://www.gnu.org/).
//
// As a special exception, the Harbour Project gives permission for
// additional uses of the text contained in its release of Harbour.
//
// The exception is that, if you link the Harbour libraries with other
// files to produce an executable, this does not by itself cause the
// resulting executable to be covered by the GNU General Public License.
// Your use of that executable is in no way restricted on account of
// linking the Harbour library code into it.
//
// This exception does not however invalidate any other reasons why
// the executable file might be covered by the GNU General Public License.
//
// This exception applies only to the code released by the Harbour
// Project under the name Harbour.  If you copy code from other
// Harbour Project or Free Software Foundation releases into a copy of
// Harbour, as the General Public License permits, the exception does
// not apply to the code that you add in this way.  To avoid misleading
// anyone as to the status of such modified files, you must delete
// this exception notice from them.
//
// If you write modifications of your own for Harbour, it is your choice
// whether to permit this exception to apply to your modifications.
// If you do not wish that, delete this exception notice.
//

// Registry interface

#include "hwingui.h"
#include <shlobj.h>
// #include <commctrl.h>

#include <hbvm.h>
#include <hbstack.h>
#include <hbapiitm.h>
#include <winreg.h>

#if defined(__DMC__)
__inline long PtrToLong(const void *p)
{
  return (long)p;
}
#endif

#define hwg_par_HKEY(n) (HKEY)(ULONG_PTR) hb_parnint(n)

// HWG_REGCLOSEKEY(HKEY) --> numeric
HB_FUNC(HWG_REGCLOSEKEY)
{
  if (RegCloseKey(hwg_par_HKEY(1)) == ERROR_SUCCESS) {
    hb_retnl(ERROR_SUCCESS);
  } else {
    hb_retnl(-1);
  }
}

// HWG_REGOPENKEYEX(HKEY, cSubKey) --> numeric
HB_FUNC(HWG_REGOPENKEYEX)
{
  void *hValue;
  LONG lError;
  HKEY phwHandle;

  lError = RegOpenKeyEx(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR), 0, KEY_ALL_ACCESS, &phwHandle);
  if (lError > 0) {
    hb_retni(-1);
  } else {
    hb_stornl(PtrToLong(phwHandle), 5);
    hb_retni(0);
  }
  hb_strfree(hValue);
}

// HWG_REGQUERYVALUEEX(HKEY, cValueName, NIL, nType, cData) --> numeric
HB_FUNC(HWG_REGQUERYVALUEEX)
{
  HKEY hwKey = hwg_par_HKEY(1);
  LONG lError;
  DWORD lpType = hwg_par_DWORD(4);
  DWORD lpcbData = 0;
  void *hValue;
  LPCTSTR lpValue = HB_PARSTRDEF(2, &hValue, HWG_NULLPTR);

  lError = RegQueryValueEx(hwKey, lpValue, HWG_NULLPTR, &lpType, HWG_NULLPTR, &lpcbData);
  if (lError == ERROR_SUCCESS) {
    BYTE *lpData = (BYTE *)memset(hb_xgrab(lpcbData + 1), 0, lpcbData + 1);
    lError = RegQueryValueEx(hwKey, lpValue, HWG_NULLPTR, &lpType, lpData, &lpcbData);
    if (lError > 0) {
      hb_retni(-1);
    } else {
      hb_storc((char *)lpData, 5);
      hb_retni(0);
    }

    hb_xfree(lpData);
  }
  hb_strfree(hValue);
}

// HWG_REGENUMKEYEX(HKEY, nIndex, cBuffer, nBufferSize, NIL, cClass, nClassBufferSize) --> numeric
HB_FUNC(HWG_REGENUMKEYEX)
{
  FILETIME ft;
  long nErr;
  TCHAR Buffer[255];
  DWORD dwBuffSize = 255;
  TCHAR Class[255];
  DWORD dwClass = 255;

  nErr = RegEnumKeyEx(hwg_par_HKEY(1), hwg_par_DWORD(2), Buffer, &dwBuffSize, HWG_NULLPTR, Class, &dwClass, &ft);

  if (nErr == ERROR_SUCCESS) {
    HB_STORSTR(Buffer, 3);
    hb_stornl((long)dwBuffSize, 4);
    HB_STORSTR(Class, 6);
    hb_stornl((long)dwClass, 7);
  }
  hb_retnl(nErr);
}

// HWG_REGSETVALUEEX(HKEY, cValueName, NIL, nType, cData) --> numeric
HB_FUNC(HWG_REGSETVALUEEX)
{
  void *hValue;
  hb_retnl(RegSetValueEx(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR), 0, hwg_par_DWORD(4),
                         (const BYTE *)hb_parcx(5), (DWORD)hb_parclen(5) + 1));
  hb_strfree(hValue);
}

// HWG_REGCREATEKEY(HKEY, cSubKey, nHKResult) --> numeric
HB_FUNC(HWG_REGCREATEKEY)
{
  HKEY hKey;
  LONG nErr;
  void *hValue;
  nErr = RegCreateKey(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR), &hKey);
  if (nErr == ERROR_SUCCESS) {
    hb_stornl(PtrToLong(hKey), 3);
  }
  hb_retnl(nErr);
  hb_strfree(hValue);
}

// HWG_REGCREATEKEYEX(HKEY, cSubKey, NIL, cClass, nOptions, nSamDesired, cSecurityAttributes, nHKResult, nDisposition) --> numeric
HB_FUNC(HWG_REGCREATEKEYEX)
{
  HKEY hkResult;
  DWORD dwDisposition;
  LONG nErr;
  SECURITY_ATTRIBUTES *sa = HWG_NULLPTR;
  void *hValue, *hClass;

  if (HB_ISCHAR(7)) {
    sa = (SECURITY_ATTRIBUTES *)hb_parc(7);
  }

  nErr = RegCreateKeyEx(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR), 0,
                        (LPTSTR)HB_PARSTRDEF(4, &hClass, HWG_NULLPTR), hwg_par_DWORD(5), (REGSAM)hb_parnl(6), sa,
                        &hkResult, &dwDisposition);

  if (nErr == ERROR_SUCCESS) {
    hb_stornint((LONG_PTR)hkResult, 8);
    hb_stornl((LONG)dwDisposition, 9);
  }
  hb_retnl(nErr);
  hb_strfree(hValue);
  hb_strfree(hClass);
}

// HWG_REGDELETEKEY(HKEY, cKey) --> numeric
HB_FUNC(HWG_REGDELETEKEY)
{
  void *hValue;
  hb_retni(RegDeleteKey(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR)) == ERROR_SUCCESS ? 0 : -1);
  hb_strfree(hValue);
}

//  For strange reasons this function is not working properly
//  May be I am missing something. Pritpal Bedi.

// HWG_REGDELETEVALUE(HKEY, cValueName) --> numeric
HB_FUNC(HWG_REGDELETEVALUE)
{
  void *hValue;
  hb_retni(RegDeleteValue(hwg_par_HKEY(1), HB_PARSTRDEF(2, &hValue, HWG_NULLPTR)) == ERROR_SUCCESS ? 0 : -1);
  hb_strfree(hValue);
}

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(REGCLOSEKEY, HWG_REGCLOSEKEY);
HB_FUNC_TRANSLATE(REGOPENKEYEX, HWG_REGOPENKEYEX);
HB_FUNC_TRANSLATE(REGQUERYVALUEEX, HWG_REGQUERYVALUEEX);
HB_FUNC_TRANSLATE(REGENUMKEYEX, HWG_REGENUMKEYEX);
HB_FUNC_TRANSLATE(REGSETVALUEEX, HWG_REGSETVALUEEX);
HB_FUNC_TRANSLATE(REGCREATEKEY, HWG_REGCREATEKEY);
HB_FUNC_TRANSLATE(REGCREATEKEYEX, HWG_REGCREATEKEYEX);
HB_FUNC_TRANSLATE(REGDELETEKEY, HWG_REGDELETEKEY);
HB_FUNC_TRANSLATE(REGDELETEVALUE, HWG_REGDELETEVALUE);
#endif
