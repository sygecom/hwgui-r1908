// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> PAGER [ <oTool> ] ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ STYLE <nStyle> ]         ;
             [ <lVert: VERTICAL> ] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oTool> := ] __IIF(<.class.>, <classname>, HPager)():New( <oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,,<.lVert.>);;
          [ <oTool>:name := <(oTool)> ]
