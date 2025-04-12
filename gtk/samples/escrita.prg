
request HB_CODEPAGE_PTISO,HB_CODEPAGE_PT850
#include "hwgui.ch"

FUNCTION Main()
Local oModDlg, oEditbox, onome,obar
Local meditbox := "", mnome:= space(50)
//hb_settermcp("PT850", "PTISO")
INIT DIALOG oModDlg TITLE "Teste da Acentuação" ;
   AT 210, 10  SIZE 300, 300       on init {||otool:refresh(),hwg_Enablewindow(oTool:aItem[2, 11],.F.)}
//hwg_CreateToolBar(omodDlg:handle, 0, 0, 20, 20)
   @ 0, 0 toolbar oTool of oModDlg size 50, 100 ID 700
   TOOLBUTTON  otool ;
           ID 701 ;
           BITMAP "../../image/new.bmp";
           STYLE 0 ;
           STATE 4;
           TEXT "teste1"  ;
           TOOLTIP "ola" ;
           
           ON CLICK {|x,y|hwg_msginfo("ola"),hwg_Enablewindow(oTool:aItem[2, 11],.T.) ,hwg_Enablewindow(oTool:aItem[1, 11],.F.)}

   TOOLBUTTON  otool ;
          ID 702 ;
           BITMAP "../../image/book.bmp";
           STYLE 0 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x,y|hwg_msginfo("ola1"),hwg_Enablewindow(oTool:aItem[1, 11],.T.),hwg_Enablewindow(oTool:aItem[2, 11],.F.)}

   TOOLBUTTON  otool ;
          ID 703 ;
           BITMAP "../../image/ok.ico";
           STYLE 0 ;
           STATE 4;
           TEXT "asdsa"  ;
           TOOLTIP "ola3" ;
           ON CLICK {|x,y|hwg_msginfo("ola2")}
   TOOLBUTTON  otool ;
          ID 702 ;
           STYLE 1 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x,y|hwg_msginfo("ola3")}
   TOOLBUTTON  otool ;
          ID 702 ;
           BITMAP "../../image/tools.bmp";
           STYLE 0 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x,y|hwg_msginfo("ola4")}

   TOOLBUTTON  otool ;
          ID 702 ;
           BITMAP "../../image/cancel.ico";
           STYLE 0 ;
           STATE 4;
           TEXT "teste2"  ;
           TOOLTIP "ola2" ;
           ON CLICK {|x,y|hwg_msginfo("ola5")}
	   


   @ 20, 35 EDITBOX oEditbox CAPTION ""    ;
        STYLE WS_DLGFRAME              ;
        SIZE 260, 26
        
   @ 20, 75 GET onome VAR mnome SIZE 260, 26

   @ 20, 105 progressbar obar size 260, 26  barwidth 100

   ACTIVATE DIALOG oModDlg

hwg_MsgInfo( meditbox )
hwg_MsgInfo( OEDITBOX:TITLE )
hwg_MsgInfo( mnome )


RETURN NIL

