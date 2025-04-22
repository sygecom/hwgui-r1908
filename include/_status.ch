// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand ADD STATUS [ <oStat> ] [ TO <oParent> ] ;
             [ ID <nId> ]                         ;
             [ HEIGHT <nHeight> ]                 ;
             [ ON INIT <bInit> ]                  ;
             [ ON SIZE <bSize> ]                  ;
             [ ON PAINT <bPaint> ]                ;
             [ ON DBLCLICK <bDblClick> ]          ;
             [ ON RIGHTCLICK <bRClick> ]          ;
             [ STYLE <nStyle> ]                   ;
             [ FONT <oFont> ]                     ;
             [ PARTS <aparts, ...> ]              ;
          => ;
          [ <oStat> := ] HStatus():New(<oParent>,<nId>,<nStyle>,<oFont>,\{<aparts>\},<bInit>, ;
             <bSize>,<bPaint>, <bRClick>, <bDblClick>, <nHeight>) ;;
          [ <oStat>:name := <(oStat)> ]

#xcommand REDEFINE STATUS <oSay>      ;
             [ OF <oParent> ]         ;
             ID <nId>                 ;
             [ ON INIT <bInit> ]      ;
             [ ON SIZE <bSize> ]      ;
             [ ON PAINT <bPaint> ]    ;
             [ PARTS <bChange, ...> ] ;
          => ;
          [ <oSay> := ] HStatus():Redefine(<oParent>,<nId>,,  ,<bInit>,<bSize>,<bPaint>, , , , ,\{<bChange>\})
