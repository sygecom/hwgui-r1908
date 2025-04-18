#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oButtonOk
   LOCAL oButtonCancel

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ (320 - 100) / 2, 280 BUTTONEX oButtonOk CAPTION "&Ok" OF oDialog ID IDOK SIZE 100, 32 ;
      COLOR 0xFFFFFF BACKCOLOR 0xFF0000 STYLE WS_TABSTOP CLASS MyButtonEx

   @ (320 - 100) / 2 + 320, 280 BUTTONEX oButtonCancel CAPTION "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32 ;
      COLOR 0xFFFFFF BACKCOLOR 0xFF0000 STYLE WS_TABSTOP CLASS MyButtonEx

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo("oButtonOk:ClassName() = " + oButtonOk:ClassName(), "Info")
   hwg_MsgInfo("oButtonCancel:ClassName() = " + oButtonCancel:ClassName(), "Info")

   IF oDialog:lResult
      hwg_MsgInfo("OK", "Info")
   ELSE
      hwg_MsgInfo("CANCEL", "Info")
   ENDIF

RETURN NIL


#include <hbclass.ch>

CLASS MyButtonEx FROM HButtonEx
END CLASS
