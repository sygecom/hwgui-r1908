#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL oSayWidth
   LOCAL oSayHeight

   INIT WINDOW oMainWindow MAIN TITLE "Test" SIZE 800, 600 ;
      ON SIZE {||oSayWidth:SetValue(Str(oMainWindow:nWidth)), oSayHeight:SetValue(Str(oMainWindow:nHeight))}

   @ 20, 20 SAY "Width:" SIZE 100, 30
   @ 130, 20 SAY oSayWidth CAPTION "0" SIZE 100, 30

   @ 20, 60 SAY "Height:" SIZE 100, 30
   @ 130, 60 SAY oSayHeight CAPTION "0" SIZE 100, 30

   ACTIVATE WINDOW oMainWindow

RETURN NIL
