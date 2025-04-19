// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand ADD STATUS [<oStat>] [ TO <oParent> ] ;
             [ ID <nId> ]           ;
             [ HEIGHT <nHeight> ]   ;
             [ ON INIT <bInit> ]    ;
             [ ON SIZE <bSize> ]    ;
             [ ON PAINT <bDraw> ]   ;
             [ ON DBLCLICK <bDblClick> ];
             [ ON RIGHTCLICK <bRClick> ];
             [ STYLE <nStyle> ]     ;
             [ FONT <oFont> ]       ;
             [ PARTS <aparts,...> ] ;
          => ;
          [ <oStat> := ] HStatus():New( <oParent>,<nId>,<nStyle>,<oFont>,\{<aparts>\},<bInit>,;
             <bSize>,<bDraw>, <bRClick>, <bDblClick>, <nHeight> );;
          [ <oStat>:name := <(oStat)> ]

#xcommand REDEFINE STATUS  <oSay>  ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ PARTS <bChange,...> ]    ;
          => ;
          [<oSay> := ] HStatus():Redefine( <oParent>,<nId>,,  ,<bInit>,<bSize>,<bDraw>, , , , ,\{<bChange>\} )
