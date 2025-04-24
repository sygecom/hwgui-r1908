// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BUTTON [ <oBut> CAPTION ] <caption> ;
             [ OF <oParent> ]                              ;
             [ ID <nId> ]                                  ;
             [ SIZE <nWidth>, <nHeight> ]                  ;
             [ COLOR <color> ]                             ;
             [ BACKCOLOR <bcolor> ]                        ;
             [ ON INIT <bInit> ]                           ;
             [ ON SIZE <bSize> ]                           ;
             [ ON PAINT <bPaint> ]                         ;
             [ ON CLICK <bClick> ]                         ;
             [ ON GETFOCUS <bGfocus> ]                     ;
             [ STYLE <nStyle> ]                            ;
             [ FONT <oFont> ]                              ;
             [ TOOLTIP <cTooltip> ]                        ;
             [ <class: CLASS> <classname> ]                ;
          => ;
          [ <oBut> := ] __IIF(<.class.>, <classname>, HButton)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, ;
             <nHeight>, <caption>, <oFont>, <bInit>, <bSize>, <bPaint>, <bClick>, <cTooltip>, <color>, <bcolor>, <bGfocus>) ;;
          [ <oBut>:name := <(oBut)> ]

#xcommand REDEFINE BUTTON [ <oBut> ]   ;
             [ OF <oParent> ]          ;
             ID <nId>                  ;
             [ CAPTION <cCaption> ]    ;
             [ COLOR <color> ]         ;
             [ BACKCOLOR <bcolor> ]    ;
             [ FONT <oFont> ]          ;
             [ ON INIT <bInit> ]       ;
             [ ON SIZE <bSize> ]       ;
             [ ON PAINT <bPaint> ]     ;
             [ ON CLICK <bClick> ]     ;
             [ ON GETFOCUS <bGfocus> ] ;
             [ TOOLTIP <cTooltip> ]    ;
          => ;
          [ <oBut> := ] HButton():Redefine(<oParent>, <nId>, <oFont>, <bInit>, <bSize>, <bPaint>, ;
             <bClick>, <cTooltip>, <color>, <bcolor>, <cCaption>, <bGfocus>)
