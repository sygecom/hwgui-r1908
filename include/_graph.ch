// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GRAPH [ <oGraph> DATA ] <aData> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON SIZE <bSize> ]        ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oGraph> := ] __IIF(<.class.>, <classname>, HGraph)():New( <oParent>,<nId>,<aData>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bSize>,<cTooltip>,<color>,<bcolor> );;
          [ <oGraph>:name := <(oGraph)> ]
