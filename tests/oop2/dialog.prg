#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog

   WITH OBJECT oDialog := HDialog():new()
      :title   := "Test"
      :nWidth  := 800
      :nHeight := 600
      :activate()
   ENDWITH

RETURN NIL
