// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

// Contribution ATZCT" <atzct@obukhov.kiev.ua
#xcommand @ <nX>, <nY> PROGRESSBAR <oPBar>  ;
             [ OF <oParent> ]               ;
             [ ID <nId> ]                   ;
             [ SIZE <nWidth>, <nHeight> ]   ;
             [ ON INIT <bInit> ]            ;
             [ ON PAINT <bPaint> ]          ;
             [ ON SIZE <bSize> ]            ;
             [ BARWIDTH <maxpos> ]          ;
             [ QUANTITY <nRange> ]          ;
             [ <lVert: VERTICAL>]           ;
             [ ANIMATION <nAnimat> ]        ;
             [ TOOLTIP <cTooltip> ]         ;
             [ <class: CLASS> <classname> ] ;
          => ;
          <oPBar> :=  __IIF(<.class.>, <classname>, HProgressBar)():New(<oParent>,<nId>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<maxpos>,<nRange>, <bInit>,<bSize>,<bPaint>,<cTooltip>,<nAnimat>,<.lVert.>) ;;
          [ <oPBar>:name := <(oPBar)> ]
