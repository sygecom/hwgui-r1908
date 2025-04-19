// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> SAY [ <oSay> CAPTION ] <caption> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oSay> := ] __IIF(<.class.>, <classname>, HStatic)():New( <oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<cTooltip>, ;
             <color>,<bcolor>,<.lTransp.>,<bClick>,<bDblClick>,<bOther> );;
          [ <oSay>:name := <(oSay)> ]

#xcommand REDEFINE SAY   [ <oSay> CAPTION ] <cCaption>   ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON DBLCLICK <bDblClick> ];
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oSay> := ] HStatic():Redefine( <oParent>,<nId>,<cCaption>, ;
             <oFont>,<bInit>,<bSize>,<bDraw>,<cTooltip>,<color>,<bcolor>,<.lTransp.>,<bClick>,<bDblClick> )
