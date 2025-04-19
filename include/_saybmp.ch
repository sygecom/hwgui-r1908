// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BITMAP [ <oBmp> SHOW ] <bitmap> ;
             [ <res: FROM RESOURCE> ]     ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STRETCH <nStretch>]      ;
             [ <lTransp: TRANSPARENT> ]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ] ;
             [ TOOLTIP <cTooltip> ]       ;
             [ STYLE <nStyle> ]         ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oBmp> := ] __IIF(<.class.>, <classname>, HSayBmp)():New(<oParent>,<nId>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<bitmap>,<.res.>,<bInit>,<bSize>,<cTooltip>,<bClick>,<bDblClick>, <.lTransp.>,<nStretch>, <nStyle>) ;;
          [ <oBmp>:name := <(oBmp)> ]

#xcommand REDEFINE BITMAP [ <oBmp> SHOW ] <bitmap> ;
             [ <res: FROM RESOURCE> ]     ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ <lTransp: TRANSPARENT> ]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [ <oBmp> := ] HSayBmp():Redefine(<oParent>,<nId>,<bitmap>,<.res.>, ;
             <bInit>,<bSize>,<cTooltip>,<.lTransp.>)
