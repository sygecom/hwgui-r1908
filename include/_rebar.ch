// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> REBAR [ <oTool> ]    ;
             [ OF <oParent> ]               ;
             [ ID <nId> ]                   ;
             [ SIZE <nWidth>, <nHeight> ]   ;
             [ STYLE <nStyle> ]             ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [ <oTool> := ] __IIF(<.class.>, <classname>, HREBAR)():New(<oParent>,<nId>,<nStyle>,<nX>,<nY>,<nWidth>, <nHeight>,,,,,,,,) ;;
          [ <oTool>:name := <(oTool)> ]
