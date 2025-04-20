// TODO: work with xharbour, but dont work with harbour

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMyMainWindow

   INIT WINDOW oMyMainWindow TITLE "Test" SIZE 800, 600 CLASS MyMainWindow

   ACTIVATE WINDOW oMyMainWindow

   hwg_MsgInfo("oMyMainWindow:ClassName() = " + oMyMainWindow:ClassName(), "Info")

RETURN NIL

#include <hbclass.ch>

CLASS MyMainWindow FROM HMainWindow
END CLASS
