#include "hwgui.ch"
// #include "listbox.ch"

FUNCTION Main()

   LOCAL oMainWindow

   INIT WINDOW oMainWindow MAIN TITLE "Example" ;
     AT 0, 0 SIZE hwg_GetDesktopWidth(), hwg_GetDesktopHeight() - 28

   MENU OF oMainWindow
      MENUITEM "&Exit" ACTION oMainWindow:Close()
      MENUITEM "&Teste" ACTION Teste()
   ENDMENU

   ACTIVATE WINDOW oMainWindow

RETURN NIL

FUNCTION Teste()

   LOCAL oModDlg
   LOCAL oFont := HFont():Add("MS Sans Serif", 0, -13)
   LOCAL oList
   LOCAL oItems := {"Item01", "Item02", "Item03", "Item04"}

   INIT DIALOG oModDlg TITLE "Test"  ;
   AT 0, 0 SIZE 450, 350   ;
   FONT oFont

   @ 10, 40 LISTBOX oList ITEMS oItems ;
             OF oModDlg                  ;
             INIT 1 ;
             SIZE 210, 220            ;
             ON INIT {||hwg_MsgInfo("Teste")} ;
             TOOLTIP "Test ListBox"

   @  10, 280 BUTTON "Ok" ID IDOK SIZE 50, 32
    ACTIVATE DIALOG oModDlg
    oFont:Release()

   IF oModDlg:lResult
    ENDIF

RETURN NIL
