#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 CLASS MyDialog

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo("oDialog:ClassName() = " + oDialog:ClassName(), "Info")

RETURN NIL

#include <hbclass.ch>

CLASS MyDialog FROM HDialog
END CLASS
