// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> PANEL [ <oPanel> ] ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ STYLE <nStyle> ]         ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oPanel> :=] __IIF(<.class.>, <classname>, HPanel)():New( <oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<bInit>,<bSize>,<bPaint>,<bcolor> );;
          [ <oPanel>:name := <(oPanel)> ]

#xcommand REDEFINE PANEL [ <oPanel> ]  ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ HEIGHT <nHeight> ]       ;
             [ WIDTH <nWidth> ]         ;
          => ;
          [<oPanel> :=] HPanel():Redefine( <oParent>,<nId>,<nWidth>,<nHeight>,<bInit>,<bSize>,<bPaint>, <bcolor> )
