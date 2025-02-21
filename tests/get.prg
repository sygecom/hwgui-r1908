#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL cGet1 := "get1"
   LOCAL cGet2 := "get2"
   LOCAL cGet3 := "get3"

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 40, 40 GET cGet1 SIZE 130, 30

   @ 40, 80 GET cGet2 SIZE 130, 30

   @ 40, 120 GET cGet3 SIZE 130, 30

   @ (320 - 100) / 2, 280 BUTTON "&Ok" OF oDialog ID IDOK SIZE 100, 32

   @ (320 - 100) / 2 + 320, 280 BUTTON "&Cancel" OF oDialog ID IDCANCEL SIZE 100, 32

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(cGet1, "Info")
   hwg_MsgInfo(cGet2, "Info")
   hwg_MsgInfo(cGet3, "Info")

RETURN NIL
