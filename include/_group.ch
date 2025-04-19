// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GROUPBOX [ <oGroup> CAPTION ] <caption> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ <lTransp: TRANSPARENT> ]   ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ STYLE <nStyle> ]         ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oGroup> := ] __IIF(<.class.>, <classname>, HGroup)():New(<oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<caption>,<oFont>,<bInit>,<bSize>,<bPaint>,<color>,<bcolor>,<.lTransp.>) ;;
          [ <oGroup>:name := <(oGroup)> ]
