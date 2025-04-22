// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> UPDOWN [ <oUpd> INIT ] <nInit> ;
             RANGE <nLower>, <nUpper>                 ;
             [ OF <oParent> ]                         ;
             [ ID <nId> ]                             ;
             [ SIZE <nWidth>, <nHeight> ]             ;
             [ WIDTH <nUpDWidth> ]                    ;
             [ INCREMENT <nIncr> ]                    ;
             [ COLOR <color> ]                        ;
             [ BACKCOLOR <bcolor> ]                   ;
             [ ON INIT <bInit> ]                      ;
             [ ON SIZE <bSize> ]                      ;
             [ ON PAINT <bPaint> ]                    ;
             [ ON GETFOCUS <bGfocus> ]                ;
             [ ON LOSTFOCUS <bLfocus> ]               ;
             [ STYLE <nStyle> ]                       ;
             [ FONT <oFont> ]                         ;
             [ TOOLTIP <cTooltip> ]                   ;
             [ <class: CLASS> <classname> ]           ;
          => ;
          [ <oUpd> := ] __IIF(<.class.>, <classname>, HUpDown)():New(<oParent>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bPaint>,<bGfocus>,         ;
             <bLfocus>,<cTooltip>,<color>,<bcolor>,<nUpDWidth>,<nLower>,<nUpper>,<nIncr>) ;;
          [ <oUpd>:name := <(oUpd)> ]

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET UPDOWN [ <oUpd> VAR ] <vari> ;
             RANGE <nLower>, <nUpper>                   ;
             [ OF <oParent> ]                           ;
             [ ID <nId> ]                               ;
             [ SIZE <nWidth>, <nHeight> ]               ;
             [ INCREMENT <nIncr> ]                      ;
             [ WIDTH <nUpDWidth> ]                      ;
             [ MAXLENGTH <nMaxLength> ]                 ;
             [ COLOR <color> ]                          ;
             [ BACKCOLOR <bcolor> ]                     ;
             [ PICTURE <cPicture> ]                     ;
             [ WHEN <bGfocus> ]                         ;
             [ VALID <bLfocus> ]                        ;
             [ STYLE <nStyle> ]                         ;
             [ FONT <oFont> ]                           ;
             [ <lnoborder: NOBORDER> ]                  ;
             [ TOOLTIP <cTooltip> ]                     ;
             [ ON INIT <bInit> ]                        ;
             [ ON KEYDOWN <bKeyDown> ]                  ;
             [ ON CHANGE <bChange> ]                    ;
             [                                          ;
                [ ON OTHER MESSAGES <bOther> ]          ;
                [ ON OTHERMESSAGES <bOther> ]           ;
             ]                                          ;
          => ;
          [ <oUpd> := ] HUpDown():New(<oParent>,<nId>,<vari>,{|v|IIf(v == NIL, <vari>, <vari> := v)}, ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,,, ;
             <bGfocus>,<bLfocus>,<cTooltip>,<color>,<bcolor>, ;
             <nUpDWidth>,<nLower>,<nUpper>,<nIncr>,<cPicture>,<.lnoborder.>, ;
             <nMaxLength>,<bKeyDown>,<bChange>,<bOther>,,) ;;
          [ <oUpd>:name := <(oUpd)> ]
