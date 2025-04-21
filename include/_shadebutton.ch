// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SHADEBUTTON [ <oShBtn> ]  ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ EFFECT <shadeID> ;
               [ PALETTE <palet> ]             ;
               [ GRANULARITY <granul> ] ;
               [ HIGHLIGHT <highl> ] ;
               [ COLORING <coloring> ] ;
               [ SHCOLOR <shcolor> ] ;
             ] ;
             [ ON INIT <bInit> ]     ;
             [ ON SIZE <bSize> ]     ;
             [ ON DRAW <bDraw> ]     ;
             [ ON CLICK <bClick> ]   ;
             [ STYLE <nStyle> ]      ;
             [ <flat: FLAT> ]        ;
             [ <enable: DISABLED> ]  ;
             [ TEXT <cText>          ;
               [ COLOR <color>] ;
               [ FONT <font> ] ;
               [ COORDINATES <xt>, <yt> ] ;
             ] ;
             [ BITMAP <bmp> ;
               [ <res: FROM RESOURCE> ] ;
               [ <ltr: TRANSPARENT> [ COLOR <trcolor> ] ] ;
               [ COORDINATES <xb>, <yb>, <widthb>, <heightb> ] ;
             ] ;
             [ TOOLTIP <cTooltip> ]    ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oShBtn> := ] __IIF(<.class.>, <classname>, HSHADEBUTTON)():New(<oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<bInit>,<bSize>,<bDraw>,<bClick>,<.flat.>,<cText>,<color>, ;
             <font>,<xt>,<yt>,<bmp>,<.res.>,<xb>,<yb>,<widthb>,<heightb>,<.ltr.>, ;
             <trcolor>,<cTooltip>,!<.enable.>,<shadeID>,<palet>,<granul>,<highl>, ;
             <coloring>,<shcolor>) ;;
          [ <oShBtn>:name := <(oShBtn)> ]
