// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BUTTONEX [ <oBut> CAPTION ] <caption> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ BITMAP <hbit> ]          ;
             [ BSTYLE <nBStyle> ]       ;
             [ PICTUREMARGIN <nMargin> ];
             [ ICON <hIco> ]          ;
             [ <lTransp: TRANSPARENT> ] ;
             [ <lnoTheme: NOTHEMES> ]   ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oBut> := ] __IIF(<.class.>, <classname>, HButtonEx)():New( <oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<color>,<bcolor>,<hbit>, ;
             <nBStyle>,<hIco>, <.lTransp.>,<bGfocus>,<nMargin>,<.lnoTheme.>, <bOther> );;
          [ <oBut>:name := <(oBut)> ]

#xcommand REDEFINE BUTTONEX [ <oBut> ]   ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ CAPTION <cCaption> ]     ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ TOOLTIP <cTooltip> ]       ;
             [ BITMAP <hbit> ]          ;
             [ BSTYLE <nBStyle> ]       ;
             [ PICTUREMARGIN <nMargin> ];
          => ;
          [<oBut> := ] HButtonEx():Redefine( <oParent>,<nId>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bClick>,<cTooltip>,<color>,<bcolor>,<cCaption>,<hbit>,<nBStyle>,<bGfocus>,<nMargin>  )
