// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> LINE [ <oLine> ]   ;
             [ LENGTH <length> ]       ;
             [ HEIGHT <nHeight> ]      ;
             [ OF <oParent> ]             ;
             [ ID <nId> ]              ;
             [ COLOR <color> ]         ;
             [ LINESLANT <cSlant> ]    ;
             [ BORDERWIDTH <nBorder> ] ;
             [<lVert: VERTICAL>]       ;
             [ ON INIT <bInit> ]       ;
             [ ON SIZE <bSize> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oLine> := ] __IIF(<.class.>, <classname>, HLine)():New( <oParent>,<nId>,<.lVert.>,<nX>,<nY>,<length>,<bSize>, <bInit>,;
					              <color>, <nHeight>, <cSlant>,<nBorder>  );;
          [ <oLine>:name := <(oLine)> ]

