// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> BROWSE [ <oBrw> ]  ;
             [ <lArr: ARRAY> ]          ;
             [ <lDb: DATABASE> ]        ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CLICK <bEnter> ]      ;
             [ ON RIGHTCLICK <bRClick> ] ;
             [ ON GETFOCUS <bGfocus> ][WHEN <bGfocus> ]   ;
             [ ON LOSTFOCUS <bLfocus> ][ VALID <bLfocus> ] ;
             [ STYLE <nStyle> ]         ;
             [ <lNoVScr: NO VSCROLL> ]  ;
             [ <lNoBord: NOBORDER> ]    ;
             [ FONT <oFont> ]           ;
             [ <lAppend: APPEND> ]      ;
             [ <lAutoedit: AUTOEDIT> ]  ;
             [ ON UPDATE <bUpdate> ]    ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON POSCHANGE <bPosChg> ] ;
             [ ON CHANGEROWCOL <bChgrowcol> ] ;
             [ <lMulti: MULTISELECT> ]  ;
             [ <lDescend: DESCEND> ]    ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ WHILE <bWhile> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ FIRST <bFirst> ]         ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ LAST <bLast> ]           ; // By Marcelo Sturm (marcelo.sturm@gmail.com)
             [ FOR <bFor> ]             ; // By Luiz Henrique dos Santos (luizhsantos@gmail.com)
             [ ON OTHER MESSAGES <bOther> ] ;
             [ ON OTHERMESSAGES <bOther>  ] ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oBrw> := ] __IIF(<.class.>, <classname>, HBrowse)():New(IIf(<.lDb.>, BRW_DATABASE, IIf(<.lArr.>, BRW_ARRAY, 0)), ;
             <oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize>, ;
             <bPaint>,<bEnter>,<bGfocus>,<bLfocus>,<.lNoVScr.>,<.lNoBord.>, <.lAppend.>, ;
             <.lAutoedit.>, <bUpdate>, <bKeyDown>, <bPosChg>, <.lMulti.>, <.lDescend.>, ;
             <bWhile>, <bFirst>, <bLast>, <bFor>, <bOther>, <color>, <bcolor>, <bRClick>,<bChgrowcol>, <cTooltip>) ;;
          [ <oBrw>:name := <(oBrw)> ]

#xcommand REDEFINE BROWSE [ <oBrw> ]   ;
             [ <lArr: ARRAY> ]          ;
             [ <lDb: DATABASE> ]        ;
             [ <lFlt: FILTER> ]        ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CLICK <bEnter> ]      ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ FONT <oFont> ]           ;
          => ;
          [ <oBrw> := ] HBrowse():Redefine(IIf(<.lDb.>, BRW_DATABASE, IIf(<.lArr.>, BRW_ARRAY, IIf(<.lFlt.>, BRW_FILTER, 0))), ;
             <oParent>,<nId>,<oFont>,<bInit>,<bSize>,<bPaint>,<bEnter>,<bGfocus>,<bLfocus>)
