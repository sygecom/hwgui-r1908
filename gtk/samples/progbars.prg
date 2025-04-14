//
// $Id: progbars.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library
// Sample of using HProgressBar class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
// Copyright 2004 Rodrigo Moreno <rodrigo_moreno@yahoo.com>
//

#include "windows.ch"
#include "guilib.ch"

STATIC oMain, oForm, oFont, oBar := NIL
STATIC n :=0
FUNCTION Main()

        INIT WINDOW oMain MAIN TITLE "Progress Bar Sample"

        MENU OF oMain
             MENUITEM "&Exit" ACTION oMain:Close()
             MENUITEM "&Demo" ACTION Test()
        ENDMENU

        ACTIVATE WINDOW oMain MAXIMIZED
RETURN NIL

FUNCTION Test()
Local cMsgErr := "Bar doesn't exist"

        PREPARE FONT oFont NAME "Courier New" WIDTH 0 HEIGHT -11

        INIT DIALOG oForm CLIPPER NOEXIT TITLE "Progress Bar Demo";
             FONT oFont ;
             AT 0, 0 SIZE 700, 425 ;
             STYLE DS_CENTER + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU ;
             ON EXIT {||IIf(oBar == NIL, .T., (oBar:Close(), .T.))}

             @ 380, 395 BUTTON 'Step Bar'   SIZE 75, 25 ON CLICK {|| n+=10, IIf(oBar == NIL, hwg_MsgStop(cMsgErr), oBar:Set(, n / 100))}
             @ 460, 395 BUTTON 'Create Bar' SIZE 75, 25 ON CLICK {|| oBar := HProgressBar():NewBox("Testing ...",,,,, 10, 100)}
             @ 540, 395 BUTTON 'Close Bar'  SIZE 75, 25 ON CLICK {|| IIf(oBar == NIL, hwg_MsgStop(cMsgErr), (oBar:Close(), oBar := NIL))}
             @ 620, 395 BUTTON 'Close'      SIZE 75, 25 ON CLICK {|| oForm:Close()}

        ACTIVATE DIALOG oForm

RETURN NIL

