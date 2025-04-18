// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> DATEPICKER [ <oPick> ]  ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <dInit> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [<lShowTime: SHOWTIME>]    ;
          => ;
          [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<dInit>,,<nStyle>,<nX>,<nY>, ;
             <nWidth>,<nHeight>,<oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>, ;
             <color>,<bcolor>,<.lShowTime.>  );;
          [ <oPick>:name := <(oPick)> ]

#xcommand REDEFINE DATEPICKER [ <oPick> VAR  ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ INIT <dInit> ]           ;
             [ ON SIZE <bSize>]         ;
             [ ON INIT <bInit> ]        ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON CHANGE <bChange> ]    ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [<lShowTime: SHOWTIME>]    ;
          => ;
          [<oPick> :=] HDatePicker():redefine( <oWnd>,<nId>,<dInit>,{|v|IIf(v == NIL,<vari>,<vari>:=v)}, ;
             <oFont>,<bSize>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>, ;
             <color>,<bcolor>,<.lShowTime.>  )

/* SAY ... GET system     */

#xcommand @ <nX>, <nY> GET DATEPICKER [ <oPick> VAR ] <vari> ;
             [ OF <oWnd> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ <focusin: WHEN, ON GETFOCUS> <bGfocus> ]         ;
             [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ]        ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [<lShowTime: SHOWTIME>]    ;
          => ;
          [<oPick> :=] HDatePicker():New( <oWnd>,<nId>,<vari>,    ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <oFont>,<bInit>,<bGfocus>,<bLfocus>,<bChange>,<cTooltip>,<color>,<bcolor>,<.lShowTime.>  );;
          [ <oPick>:name := <(oPick)> ]
