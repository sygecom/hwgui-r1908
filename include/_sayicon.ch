// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> ICON [ <oIco> SHOW ] <icon> ;
             [ <res: FROM RESOURCE> ]              ;
             [ OF <oParent> ]                      ;
             [ ID <nId> ]                          ;
             [ SIZE <nWidth>, <nHeight> ]          ;
             [ ON INIT <bInit> ]                   ;
             [ ON SIZE <bSize> ]                   ;
             [ ON CLICK <bClick> ]                 ;
             [ ON DBLCLICK <bDblClick> ]           ;
             [ TOOLTIP <cTooltip> ]                ;
             [ <oem: OEM> ]                        ;
             [ <class: CLASS> <classname> ]        ;
          => ;
          [ <oIco> := ] __IIF(<.class.>, <classname>, HSayIcon)():New(<oParent>, <nId>, <nX>, <nY>, <nWidth>, ;
             <nHeight>, <icon>, <.res.>, <bInit>, <bSize>, <cTooltip>, <.oem.>, <bClick>, <bDblClick>) ;;
          [ <oIco>:name := <(oIco)> ]

#xcommand REDEFINE ICON [ <oIco> SHOW ] <icon> ;
             [ <res: FROM RESOURCE> ]          ;
             [ OF <oParent> ]                  ;
             ID <nId>                          ;
             [ ON INIT <bInit> ]               ;
             [ ON SIZE <bSize> ]               ;
             [ TOOLTIP <cTooltip> ]            ;
          => ;
          [ <oIco> := ] HSayIcon():Redefine(<oParent>, <nId>, <icon>, <.res.>, ;
             <bInit>, <bSize>, <cTooltip>)
