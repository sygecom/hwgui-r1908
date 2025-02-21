#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL cGet1 := "get1"
   LOCAL cGet2 := "get2"
   LOCAL cGet3 := "get3"

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 40, 40 GET cGet1 SIZE 130, 30 WHEN {||hwg_MsgInfo("get1 getfocus"), .T.} VALID {||hwg_MsgInfo("get1 lostfocus"), .T.}

   @ 40, 80 GET cGet2 SIZE 130, 30 ON GETFOCUS {||hwg_MsgInfo("get2 getfocus"), .T.} ON LOSTFOCUS {||hwg_MsgInfo("get2 lostfocus"), .T.}

   @ 40, 120 GET cGet3 SIZE 130, 30 ON GETFOCUS {||hwg_MsgInfo("get3 getfocus"), .T.} VALID {||hwg_MsgInfo("get3 lostfocus"), .T.}

   ACTIVATE DIALOG oDialog

   hwg_MsgInfo(cGet1, "Info")
   hwg_MsgInfo(cGet2, "Info")
   hwg_MsgInfo(cGet3, "Info")

RETURN NIL
