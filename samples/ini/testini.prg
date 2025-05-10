//
// HwGUI Samples
// testini.prg - Test to use files ini
//

#include "hwgui.ch"

FUNCTION Main()

   LOCAL oMainWindow
   LOCAL cIniFile := "HwGui.ini"

   //Create the inifile
   IF !file(cIniFile)

      hwg_WriteIni("Config", "WallParer", "No Paper", cIniFile)
      hwg_WriteIni("Config", "DirHwGUima", "C:\HwGUI", cIniFile)
      hwg_WriteIni("Print", "Spoll", "Epson LX 80", cIniFile)

    ENDIF

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 200, 0 SIZE 400, 150

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION hwg_EndWindow()
      MENUITEM "&Read Ini" ACTION ReadIni()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION ReadIni()

   LOCAL cIniFile := "HwGui.ini"

   hwg_MsgInfo(hwg_GetIni("Config", "WallParer", , cIniFile))
   hwg_MsgInfo(hwg_GetIni("Config", "DirHwGUima", , cIniFile))
   hwg_MsgInfo(hwg_GetIni("Print", "Spoll", , cIniFile))

RETURN NIL
