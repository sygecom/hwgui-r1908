// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> MONTHCALENDAR [ <oMonthCalendar> ] ;
             [ OF <oWnd> ]                              ;
             [ ID <nId> ]                               ;
             [ SIZE <nWidth>,<nHeight> ]                ;
             [ INIT <dInit> ]                           ;
             [ ON INIT <bInit> ]                        ;
             [ ON CHANGE <bChange> ]                    ;
             [ ON SELECT <bSelect> ]                   ;
             [ STYLE <nStyle> ]                         ;
             [ FONT <oFont> ]                           ;
             [ TOOLTIP <cTooltip> ]                     ;
             [ < notoday : NOTODAY > ]                  ;
             [ < notodaycircle : NOTODAYCIRCLE > ]      ;
             [ < weeknumbers : WEEKNUMBERS > ]          ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oMonthCalendar> :=] __IIF(<.class.>, <classname>, HMonthCalendar)():New( <oWnd>,<nId>,<dInit>,<nStyle>,;
             <nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bChange>,<cTooltip>,;
             <.notoday.>,<.notodaycircle.>,<.weeknumbers.>,<bSelect> );;
          [ <oMonthCalendar>:name := <(oMonthCalendar)> ]
