// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> TAB [ <oTab> ITEMS ] <aItems> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CHANGE <bChange> ]    ;
             [ ON CLICK <bClick> ]      ;
             [ ON RIGHTCLICK <bRClick> ] ;
             [ ON GETFOCUS <bGetFocus> ] ;
             [ ON LOSTFOCUS <bLostFocus>] ;
             [ BITMAP <aBmp> [ <res: FROM RESOURCE> ] [ BITCOUNT <nBC> ] ]  ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oTab> := ] __IIF(<.class.>, <classname>, HTab)():New(<oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bPaint>,<aItems>,<bChange>, <aBmp>, <.res.>,<nBC>, ;
             <bClick>, <bGetFocus>, <bLostFocus>, <bRClick>) ;;
          [ <oTab>:name := <(oTab)> ]

#xcommand BEGIN PAGE <cname> OF <oTab> ;
            [ <enable: DISABLED> ]     ;
            [ COLOR <tcolor>]          ;
            [ BACKCOLOR <bcolor>]      ; 
            [ TOOLTIP <cTooltip> ]       ;
          =>;
          <oTab>:StartPage(<cname>, ,! <.enable.> ,<tcolor>,<bcolor>, <cTooltip>)

#xcommand END PAGE OF <oTab> => <oTab>:EndPage()

#xcommand ENDPAGE OF <oTab> => <oTab>:EndPage()

#xcommand REDEFINE TAB <oSay> ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON CHANGE <bChange> ]    ;
          => ;
          [ <oSay> := ] Htab():Redefine(<oParent>,<nId>,,  ,<bInit>,<bSize>,<bPaint>, , , , ,<bChange>)
