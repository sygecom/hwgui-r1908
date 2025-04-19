// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> EDITBOX [ <oEdit> CAPTION ] <caption> ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ ON CHANGE <bChange>]     ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [<lPassword: PASSWORD>]    ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oEdit> := ] __IIF(<.class.>, <classname>, HEdit)():New( <oParent>,<nId>,<caption>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<oFont>,<bInit>,<bSize>,<bPaint>,<bGfocus>, ;
             <bLfocus>,<cTooltip>,<color>,<bcolor>,,<.lnoborder.>,,<.lPassword.>,<bKeyDown>, <bChange>,<bOther> );;
          [ <oEdit>:name := <(oEdit)> ]

#xcommand REDEFINE EDITBOX [ <oEdit> ] ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bPaint> ]       ;
             [ ON GETFOCUS <bGfocus> ]  ;
             [ ON LOSTFOCUS <bLfocus> ] ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ TOOLTIP <cTooltip> ]       ;
          => ;
          [<oEdit> := ] HEdit():Redefine( <oParent>,<nId>,,,<oFont>,<bInit>,<bSize>,<bPaint>, ;
             <bGfocus>,<bLfocus>,<cTooltip>,<color>,<bcolor>,,,,<bKeyDown> )

/* SAY ... GET system     */
#ifdef __SYGECOM__
#xcommand @ <nX>, <nY> GET [ <oEdit> VAR ]  <vari>  ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ <focusin: WHEN, ON GETFOCUS>  <bGfocus> ]        ;
             [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ]        ;
             [<lPassword: PASSWORD>]    ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
             [ ON KEYDOWN <bKeyDown>   ];
             [ ON CHANGE <bChange> ]    ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oEdit> := ] __IIF(<.class.>, <classname>, HEdit)():New( <oParent>,<nId>,<vari>,               ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},             ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize> ,,  ;
             <bGfocus>,<bLfocus>,IIf(!EMPTY(<cTooltip>),<cTooltip>,),<color>,<bcolor>,<cPicture>,;
             <.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange>,<bOther>);;
          [ <oEdit>:name := <(oEdit)> ]

#else
#xcommand @ <nX>, <nY> GET [ <oEdit> VAR ]  <vari>  ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ <focusin: WHEN, ON GETFOCUS>  <bGfocus> ]        ;
             [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ]        ;
             [<lPassword: PASSWORD>]    ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ STYLE <nStyle> ]         ;
             [<lnoborder: NOBORDER>]    ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
             [ ON KEYDOWN <bKeyDown>   ];
             [ ON CHANGE <bChange> ]    ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oEdit> := ] __IIF(<.class.>, <classname>, HEdit)():New( <oParent>,<nId>,<vari>,               ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},             ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<oFont>,<bInit>,<bSize> ,,  ;
             <bGfocus>,<bLfocus>,<cTooltip>,<color>,<bcolor>,<cPicture>,;
             <.lnoborder.>,<nMaxLength>,<.lPassword.>,<bKeyDown>,<bChange>,<bOther>);;
          [ <oEdit>:name := <(oEdit)> ]
#endif
/* Added MULTILINE: AJ: 11-03-2007*/
#xcommand REDEFINE GET [ <oEdit> VAR ] <vari>  ;
             [ OF <oParent> ]              ;
             ID <nId>                   ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ PICTURE <cPicture> ]     ;
             [ <focusin: WHEN, ON GETFOCUS>  <bGfocus> ]        ;
             [ <focusout: VALID, ON LOSTFOCUS> <bLfocus> ]        ;
             [ MAXLENGTH <nMaxLength> ] ;
             [ FONT <oFont> ]           ;
             [ ON INIT <bInit> ]        ;
             [ TOOLTIP <cTooltip> ]       ;
             [<lMultiLine: MULTILINE>]  ;
             [ ON KEYDOWN <bKeyDown>]   ;
             [ ON CHANGE <bChange> ]    ;
          => ;
          [<oEdit> := ] HEdit():Redefine( <oParent>,<nId>,<vari>, ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},    ;
             <oFont>,,,,<{bGfocus}>,<{bLfocus}>,<cTooltip>,<color>,<bcolor>,<cPicture>,<nMaxLength>,<.lMultiLine.>,<bKeyDown>, <bChange>)
