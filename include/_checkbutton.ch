// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> CHECKBOX [ <oCheck> CAPTION ] <caption> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ INIT <lInit> ]           ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <lEnter: ENTER> ]        ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oCheck> := ] __IIF(<.class.>, <classname>, HCheckButton)():New( <oParent>,<nId>,<lInit>,,<nStyle>,<nX>,<nY>, ;
             <nWidth>,<nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bDraw>,<bClick>, ;
             <cTooltip>,<color>,<bcolor>,<bGfocus>,<.lEnter.>,<.lTransp.> );;
          [ <oCheck>:name := <(oCheck)> ]

#xcommand REDEFINE CHECKBOX [ <oCheck> ] ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <lInit>    ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CLICK <bClick> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():Redefine( <oParent>,<nId>,<lInit>,,<oFont>, ;
             <bInit>,<bSize>,<bDraw>,<bClick>,<cTooltip>,<color>,<bcolor>,<bGfocus>,<.lEnter.> )

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             CAPTION  <caption>         ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [<lTransp: TRANSPARENT>]   ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bLfocus> ]        ;
             [ <lEnter: ENTER> ]        ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oCheck> := ] __IIF(<.class.>, <classname>, HCheckButton)():New( <oParent>,<nId>,<vari>,              ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},                   ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<caption>,<oFont>, ;
             <bInit>,<bSize>,,<bClick>,<cTooltip>,<color>,<bcolor>,<bWhen>,<.lEnter.>,<.lTransp.>,<bLfocus>);;
          [ <oCheck>:name := <(oCheck)> ]

#xcommand REDEFINE GET CHECKBOX [ <oCheck> VAR ] <vari>  ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <valid: VALID, ON CLICK> <bClick> ] ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ WHEN <bWhen> ]           ;
             [ <lEnter: ENTER> ]        ;
          => ;
          [<oCheck> := ] HCheckButton():Redefine( <oParent>,<nId>,<vari>, ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},           ;
             <oFont>,,,,<bClick>,<cTooltip>,<color>,<bcolor>,<bWhen>,<.lEnter.>)
