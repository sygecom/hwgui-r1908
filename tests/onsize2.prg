#include "hwgui.ch"

FUNCTION Main()

   LOCAL oDialog
   LOCAL oSayWidth
   LOCAL oSayHeight

   INIT DIALOG oDialog TITLE "Test" SIZE 800, 600 STYLE WS_SIZEBOX ;
      ON SIZE {||oSayWidth:SetValue(Str(oDialog:nWidth)), oSayHeight:SetValue(Str(oDialog:nHeight))}

   @ 20, 20 SAY "Width:" SIZE 100, 30
   @ 130, 20 SAY oSayWidth CAPTION "0" SIZE 100, 30

   @ 20, 60 SAY "Height:" SIZE 100, 30
   @ 130, 60 SAY oSayHeight CAPTION "0" SIZE 100, 30

   ACTIVATE DIALOG oDialog

RETURN NIL
