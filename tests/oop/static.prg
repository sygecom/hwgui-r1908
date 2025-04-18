#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oSay1
   LOCAL oSay2
   LOCAL oSay3
   LOCAL oSay4
   LOCAL oSay5

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600

   @ 20, 20 SAY oSay1 CAPTION "Label 1" SIZE 130, 30 CLASS MyStatic
   @ 20, 60 SAY oSay2 CAPTION "Label 2" SIZE 130, 30 COLOR 0xFF00FF CLASS MyStatic
   @ 20, 100 SAY oSay3 CAPTION "Label 3" SIZE 130, 30 BACKCOLOR 0x00FF00 CLASS MyStatic
   @ 20, 140 SAY oSay4 CAPTION "Label 4" SIZE 130, 30 TRANSPARENT CLASS MyStatic
   @ 20, 180 SAY oSay5 CAPTION "Label 5" SIZE 130, 30 STYLE SS_CENTER FONT HFont():Add("Courier New", 0, -15) CLASS MyStatic

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo("oSay1:ClassName() = " + oSay1:ClassName(), "Info")
   hwg_MsgInfo("oSay2:ClassName() = " + oSay2:ClassName(), "Info")
   hwg_MsgInfo("oSay3:ClassName() = " + oSay3:ClassName(), "Info")
   hwg_MsgInfo("oSay4:ClassName() = " + oSay4:ClassName(), "Info")
   hwg_MsgInfo("oSay5:ClassName() = " + oSay5:ClassName(), "Info")

RETURN NIL

#include <hbclass.ch>

CLASS MyStatic FROM HStatic
END CLASS
