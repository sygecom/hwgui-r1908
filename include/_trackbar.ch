// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TRACKBAR [ <oTrackBar> ]  ;
             [ OF <oWnd> ]                 ;
             [ ID <nId> ]                  ;
             [ SIZE <nWidth>, <nHeight> ]    ;
             [ RANGE <nLow>,<nHigh> ]      ;
             [ INIT <nInit> ]              ;
             [ ON INIT <bInit> ]           ;
             [ ON SIZE <bSize> ]           ;
             [ ON PAINT <bDraw> ]          ;
             [ ON CHANGE <bChange> ]       ;
             [ ON DRAG <bDrag> ]           ;
             [ STYLE <nStyle> ]            ;
             [ TOOLTIP <cTooltip> ]        ;
             [ < vertical : VERTICAL > ]   ;
             [ < autoticks : AUTOTICKS > ] ;
             [ < noticks : NOTICKS > ]     ;
             [ < both : BOTH > ]           ;
             [ < top : TOP > ]             ;
             [ < left : LEFT > ]           ;
          => ;
          [<oTrackBar> :=] HTrackBar():New( <oWnd>,<nId>,<nInit>,<nStyle>,<nX>,<nY>,      ;
             <nWidth>,<nHeight>,<bInit>,<bSize>,<bDraw>,<cTooltip>,<bChange>,<bDrag>,<nLow>,<nHigh>,<.vertical.>,;
             IIf(<.autoticks.>, 1,IIf(<.noticks.>, 16, 0)), ;
             IIf(<.both.>, 8,IIf(<.top.>.or.<.left.>, 4, 0)) );;
          [ <oTrackBar>:name := <(oTrackBar)> ]

