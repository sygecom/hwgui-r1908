// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SAY [ <oSay> CAPTION ] <caption> ;
             [ OF <oParent> ]                           ;
             LINK <cLink>                               ;
             [ ID <nId> ]                               ;
             [ SIZE <nWidth>, <nHeight> ]               ;
             [ COLOR <color> ]                          ;
             [ BACKCOLOR <bcolor> ]                     ;
             [ <lTransp: TRANSPARENT> ]                 ;
             [ ON INIT <bInit> ]                        ;
             [ ON SIZE <bSize> ]                        ;
             [ ON PAINT <bPaint> ]                      ;
             [ ON CLICK <bClick> ]                      ;
             [ STYLE <nStyle> ]                         ;
             [ FONT <oFont> ]                           ;
             [ TOOLTIP <cTooltip> ]                     ;
             [ BITMAP <hbit> ]                          ;
             [ VISITCOLOR <vcolor> ]                    ;
             [ LINKCOLOR <lcolor> ]                     ;
             [ HOVERCOLOR <hcolor> ]                    ;
             [ <class: CLASS> <classname> ]             ;
          => ;
          [ <oSay> := ] __IIF(<.class.>, <classname>, HStaticLink)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, ;
             <nHeight>, <caption>, <oFont>, <bInit>, <bSize>, <bPaint>, <cTooltip>, ;
             <color>, <bcolor>, <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor>, <hbit>, <bClick>) ;;
          [ <oSay>:name := <(oSay)> ]

#xcommand REDEFINE SAY [ <oSay> CAPTION ] <cCaption> ;
             [ OF <oParent> ]                        ;
             ID <nId>                                ;
             LINK <cLink>                            ;
             [ COLOR <color> ]                       ;
             [ BACKCOLOR <bcolor> ]                  ;
             [ <lTransp: TRANSPARENT> ]              ;
             [ ON INIT <bInit> ]                     ;
             [ ON SIZE <bSize> ]                     ;
             [ ON PAINT <bPaint> ]                   ;
             [ FONT <oFont> ]                        ;
             [ TOOLTIP <cTooltip> ]                  ;
             [ VISITCOLOR <vcolor> ]                 ;
             [ LINKCOLOR <lcolor> ]                  ;
             [ HOVERCOLOR <hcolor> ]                 ;
          => ;
          [ <oSay> := ] HStaticLink():Redefine(<oParent>, <nId>, <cCaption>, ;
             <oFont>, <bInit>, <bSize>, <bPaint>, <cTooltip>, <color>, <bcolor>, ;
             <.lTransp.>, <cLink>, <vcolor>, <lcolor>, <hcolor>)
