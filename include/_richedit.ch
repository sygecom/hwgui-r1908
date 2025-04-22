// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> RICHEDIT [ <oEdit> TEXT ] <vari> ;
             [ OF <oParent> ]                           ;
             [ ID <nId> ]                               ;
             [ SIZE <nWidth>, <nHeight> ]               ;
             [ COLOR <color> ]                          ;
             [ BACKCOLOR <bcolor> ]                     ;
             [ <lallowtabs: ALLOWTABS> ]                ;
             [ ON INIT <bInit> ]                        ;
             [ ON SIZE <bSize> ]                        ;
             [ ON PAINT <bPaint> ]                      ;
             [ ON GETFOCUS <bGfocus> ]                  ;
             [ ON LOSTFOCUS <bLfocus> ]                 ;
             [ ON CHANGE <bChange>]                     ;
             [                                          ;
                [ ON OTHER MESSAGES <bOther> ]          ;
                [ ON OTHERMESSAGES <bOther> ]           ;
             ]                                          ;
             [ STYLE <nStyle> ]                         ;
             [ FONT <oFont> ]                           ;
             [ TOOLTIP <cTooltip> ]                     ;
             [ <class: CLASS> <classname> ]             ;
          => ;
          [ <oEdit> := ] __IIF(<.class.>, <classname>, HRichEdit)():New(<oParent>,<nId>,<vari>,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bPaint>,<bGfocus>, ;
             <bLfocus>,<cTooltip>,<color>,<bcolor>,<bOther>, <.lallowtabs.>,<bChange>) ;;
          [ <oEdit>:name := <(oEdit)> ]
