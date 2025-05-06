#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog

   INIT DIALOG oDialog TITLE "Test" SIZE 640, 480

   @ 20, 20 ANIMATION FILE "../sample.avi" SIZE 194, 52 AUTOPLAY CENTER TRANSPARENT CLASS MyAnimation

   ACTIVATE DIALOG oDialog

RETURN NIL

#include <hbclass.ch>

CLASS MyAnimation FROM HAnimation
END CLASS
