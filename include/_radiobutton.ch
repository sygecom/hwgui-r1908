// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> RADIOBUTTON [ <oRadio> CAPTION ] <caption> ;
             [ OF <oParent> ]                                     ;
             [ ID <nId> ]                                         ;
             [ SIZE <nWidth>, <nHeight> ]                         ;
             [ COLOR <color> ]                                    ;
             [ BACKCOLOR <bcolor> ]                               ;
             [ <lTransp: TRANSPARENT> ]                           ;
             [ ON INIT <bInit> ]                                  ;
             [ ON SIZE <bSize> ]                                  ;
             [ ON PAINT <bPaint> ]                                ;
             [ ON CLICK <bClick> ]                                ;
             [ ON GETFOCUS <bWhen> ]                              ;
             [ STYLE <nStyle> ]                                   ;
             [ FONT <oFont> ]                                     ;
             [ TOOLTIP <cTooltip> ]                               ;
             [ <class: CLASS> <classname> ]                       ;
          => ;
          [ <oRadio> := ] __IIF(<.class.>, <classname>, HRadioButton)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, ;
             <nWidth>, <nHeight>, <caption>, <oFont>, <bInit>, <bSize>, <bPaint>, <bClick>, ;
             <cTooltip>, <color>, <bcolor>, <bWhen>, <.lTransp.>) ;;
          [ <oRadio>:name := <(oRadio)> ]

#xcommand REDEFINE RADIOBUTTON [ <oRadio> ] ;
             [ OF <oParent> ]               ;
             ID <nId>                       ;
             [ COLOR <color> ]              ;
             [ BACKCOLOR <bcolor> ]         ;
             [ <lTransp: TRANSPARENT> ]     ;
             [ ON INIT <bInit> ]            ;
             [ ON SIZE <bSize> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON CLICK <bClick> ]          ;
             [ ON GETFOCUS <bWhen> ]        ;
             [ FONT <oFont> ]               ;
             [ TOOLTIP <cTooltip> ]         ;
             [ GROUP <oGroup>]              ;
          => ;
          [ <oRadio> := ] HRadioButton():Redefine(<oParent>, <nId>, <oFont>, <bInit>, <bSize>, ;
             <bPaint>, <bClick>, <cTooltip>, <color>, <bcolor>, <bWhen>, <.lTransp.>, <oGroup>)
