// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TRACKBAR [ <oTrackBar> ] ;
             [ OF <oParent> ]                   ;
             [ ID <nId> ]                       ;
             [ SIZE <nWidth>, <nHeight> ]       ;
             [ RANGE <nLow>,<nHigh> ]           ;
             [ INIT <nInit> ]                   ;
             [ ON INIT <bInit> ]                ;
             [ ON SIZE <bSize> ]                ;
             [ ON PAINT <bPaint> ]              ;
             [ ON CHANGE <bChange> ]            ;
             [ ON DRAG <bDrag> ]                ;
             [ STYLE <nStyle> ]                 ;
             [ TOOLTIP <cTooltip> ]             ;
             [ <vertical : VERTICAL> ]          ;
             [ <autoticks : AUTOTICKS> ]        ;
             [ <noticks : NOTICKS> ]            ;
             [ <both : BOTH> ]                  ;
             [ <top : TOP> ]                    ;
             [ <left : LEFT> ]                  ;
             [ <class: CLASS> <classname> ]     ;
          => ;
          [ <oTrackBar> := ] __IIF(<.class.>, <classname>, HTrackBar)():New(<oParent>,<nId>,<nInit>,<nStyle>,<nX>,<nY>,      ;
             <nWidth>,<nHeight>,<bInit>,<bSize>,<bPaint>,<cTooltip>,<bChange>,<bDrag>,<nLow>,<nHigh>,<.vertical.>, ;
             IIf(<.autoticks.>, 1, IIf(<.noticks.>, 16, 0)), ;
             IIf(<.both.>, 8, IIf(<.top.> .OR. <.left.>, 4, 0))) ;;
          [ <oTrackBar>:name := <(oTrackBar)> ]
