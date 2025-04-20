// TODO: work with xharbour, but dont work with harbour

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMyMainWindow

   INIT WINDOW oMyMainWindow TITLE "Test" SIZE 800, 600 CLASS MyMainWindow ;
      ON INIT {||oMyMainWindow:BuildMenu()}

   ACTIVATE WINDOW oMyMainWindow

   hwg_MsgInfo("oMyMainWindow:ClassName() = " + oMyMainWindow:ClassName(), "Info")

RETURN NIL

#include <hbclass.ch>

CLASS MyMainWindow FROM HMainWindow

   METHOD BuildMenu

END CLASS

METHOD BuildMenu() CLASS MyMainWindow

   MENU OF SELF
      MENU TITLE "Menu A"
         MENUITEM "Option A1" ACTION hwg_MsgInfo("A1")
         MENUITEM "Option A2" ACTION hwg_MsgInfo("A2")
         MENUITEM "Option A3" ACTION hwg_MsgInfo("A3")
         SEPARATOR
         MENUITEM "Exit" ACTION hwg_EndWindow()
      ENDMENU
      MENU TITLE "Menu B"
         MENUITEM "Option B1" ACTION hwg_MsgInfo("B1")
         MENUITEM "Option B2" ACTION hwg_MsgInfo("B2")
         MENUITEM "Option B3" ACTION hwg_MsgInfo("B3")
      ENDMENU
      MENU TITLE "Menu C"
         MENUITEM "Option C1" ACTION hwg_MsgInfo("C1")
         MENUITEM "Option C2" ACTION hwg_MsgInfo("C2")
         MENUITEM "Option C3" ACTION hwg_MsgInfo("C3")
      ENDMENU
   ENDMENU

RETURN SELF
