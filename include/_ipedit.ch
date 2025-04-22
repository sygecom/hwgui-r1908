// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GET IPADDRESS [ <oIp> VAR ] <vari> ;
             [ OF <oParent> ]                             ;
             [ ID <nId> ]                                 ;
             [ SIZE <nWidth>, <nHeight> ]                 ;
             [ BACKCOLOR <bcolor> ]                       ;
             [ STYLE <nStyle> ]                           ;
             [ FONT <oFont> ]                             ;
             [ ON GETFOCUS <bGfocus> ]                    ;
             [ ON LOSTFOCUS <bLfocus> ]                   ;
             [ <class: CLASS> <classname> ]               ;
          => ;
          [ <oIp> := ] __IIF(<.class.>, <classname>, HIpEdit)():New(<oParent>,<nId>,<vari>,{|v|IIf(v == NIL, <vari>, <vari> := v)},<nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>, <bGfocus>, <bLfocus>) ;;
          [ <oIp>:name := <(oIp)> ]
