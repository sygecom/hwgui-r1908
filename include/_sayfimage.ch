// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
             [ TYPE <ctype>     ]       ;
          => ;
          [<oImage> := ] HSayFImage():New( <oWnd>,<nId>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<image>,<bInit>,<bSize>,<cTooltip>,<ctype> );;
          [ <oImage>:name := <(oImage)> ]

#xcommand REDEFINE IMAGE [ <oImage> SHOW ] <image> ;
             [ OF <oWnd> ]              ;
             ID <nId>                   ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oImage> := ] HSayFImage():Redefine( <oWnd>,<nId>,<image>, ;
             <bInit>,<bSize>,<cTooltip> )
