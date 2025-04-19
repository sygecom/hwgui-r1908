// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
             [ TYPE <ctype>     ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oImage> := ] __IIF(<.class.>, <classname>, HSayFImage)():New( <oParent>,<nId>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<image>,<bInit>,<bSize>,<cTooltip>,<ctype> );;
          [ <oImage>:name := <(oImage)> ]

#xcommand REDEFINE IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oImage> := ] HSayFImage():Redefine( <oParent>,<nId>,<image>, ;
             <bInit>,<bSize>,<cTooltip> )
