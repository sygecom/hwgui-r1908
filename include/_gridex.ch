// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GRIDEX <oGrid>        ;
             [ OF <oParent> ]               ;
             [ ID <nId> ]                ;
             [ STYLE <nStyle> ]          ;
             [ SIZE <nWidth>, <nHeight> ]  ;
             [ FONT <oFont> ]            ;
             [ ON INIT <bInit> ]         ;
             [ ON SIZE <bSize> ]         ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CLICK <bEnter> ]       ;
             [ ON GETFOCUS <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ]  ;
             [ ON KEYDOWN <bKeyDown> ]   ;
             [ ON POSCHANGE <bPosChg> ]  ;
             [ ON DISPINFO <bDispInfo> ] ;
             [ ITEMCOUNT <nItemCount> ]  ;
             [ <lNoScroll: NOSCROLL> ]   ;
             [ <lNoBord: NOBORDER> ]     ;
             [ <lNoLines: NOGRIDLINES> ] ;
             [ COLOR <color> ]           ;
             [ BACKCOLOR <bkcolor> ]     ;
             [ <lNoHeader: NO HEADER> ]  ;
             [ BITMAP <aBit> ] ;
             [ ITEMS <a>] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          <oGrid> := __IIF(<.class.>, <classname>, HGridEx)():New(<oParent>, <nId>, <nStyle>, <nX>, <nY>, <nWidth>, <nHeight>, ;
             <oFont>, <{bInit}>, <{bSize}>, <{bPaint}>, <{bEnter}>, ;
             <{bGfocus}>, <{bLfocus}>, <.lNoScroll.>, <.lNoBord.>, ;
             <{bKeyDown}>, <{bPosChg}>, <{bDispInfo}>, <nItemCount>, ;
             <.lNoLines.>, <color>, <bkcolor>, <.lNoHeader.> ,<aBit>,<a>) ;;
          [ <oGrid>:name := <(oGrid)> ]

#xcommand REDEFINE GRID  <oSay>  ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ITEM <aitem> ] ;
          => ;
          [ <oSay> := ] HGRIDex():Redefine(<oParent>,<nId>,,  ,<bInit>,<bSize>,<bPaint>, , , , ,<aitem>)
