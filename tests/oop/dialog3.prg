#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMyDialog

   INIT DIALOG oMyDialog TITLE "Test" SIZE 640, 480 ;
      FONT HFont():Add("Courier New", 0, -13) ;
      ON EXIT {||hwg_MsgYesNo("Confirm exit ?")} CLASS MyDialog

   ACTIVATE DIALOG oMyDialog ON ACTIVATE {||oMyDialog:Configure()}

   IF oMyDialog:lResult
      hwg_MsgInfo("OK", "Info")
      hwg_MsgInfo("oMyDialog:ClassName() = " + oMyDialog:ClassName(), "Info")
      hwg_MsgInfo("oMyDialog:cGet1 = " + oMyDialog:cGet1, "Info")
      hwg_MsgInfo("oMyDialog:cGet2 = " + oMyDialog:cGet2, "Info")
      hwg_MsgInfo("oMyDialog:cGet3 = " + oMyDialog:cGet3, "Info")
   ELSE
      hwg_MsgInfo("CANCEL", "Info")
   ENDIF

RETURN NIL

#include <hbclass.ch>

CLASS MyDialog FROM HDialog

   DATA oGet1
   DATA oGet2
   DATA oGet3

   DATA cGet1 INIT "get1"
   DATA cGet2 INIT "get2"
   DATA cGet3 INIT "get3"

   METHOD Configure()

END CLASS

METHOD Configure() CLASS MyDialog

   @ 20, 40 SAY "Field&1 (ALT+1):" SIZE 130, 26
   @ 160, 40 GET ::oGet1 VAR ::cGet1 SIZE 130, 30

   @ 20, 80 SAY "Field&2 (ALT+2):" SIZE 130, 26
   @ 160, 80 GET ::oGet2 VAR ::cGet2 SIZE 130, 30

   @ 20, 120 SAY "Field&3 (ALT+3):" SIZE 130, 26
   @ 160, 120 GET ::oGet3 VAR ::cGet3 SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTON "&Ok" ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" ID IDCANCEL SIZE 100, 32

   ::oGet1:SetFocus()

RETURN SELF
