// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> LISTBOX [ <oListbox> ITEMS ] <aItems> ;
             [ OF <oParent> ]                 ;
             [ ID <nId> ]                  ;
             [ INIT <nInit> ]              ;
             [ SIZE <nWidth>, <nHeight> ]    ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]           ;
             [ ON SIZE <bSize> ]           ;
             [ ON PAINT <bDraw> ]          ;
             [ ON CHANGE <bChange> ]       ;
             [ STYLE <nStyle> ]            ;
             [ FONT <oFont> ]              ;
             [ TOOLTIP <cTooltip> ]          ;
             [ ON GETFOCUS <bGfocus> ]     ;
             [ ON LOSTFOCUS <bLfocus> ]    ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oListbox> := ] __IIF(<.class.>, <classname>, HListBox)():New( <oParent>,<nId>,<nInit>,,<nStyle>,<nX>,<nY>,<nWidth>, ;
             <nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>,<bChange>,<cTooltip>,;
             <color>,<bcolor>, <bGfocus>,<bLfocus>,<bKeyDown>,<bDblClick>,<bOther> ) ;;
          [ <oListbox>:name := <(oListbox)> ]

#xcommand REDEFINE LISTBOX [ <oListbox> ITEMS ] <aItems> ;
             [ OF <oParent> ]                 ;
             ID <nId>                      ;
             [ INIT <nInit>    ]           ;
             [ ON INIT <bInit> ]           ;
             [ ON SIZE <bSize> ]           ;
             [ ON PAINT <bDraw> ]          ;
             [ ON CHANGE <bChange> ]       ;
             [ FONT <oFont> ]              ;
             [ TOOLTIP <cTooltip> ]          ;
             [ ON GETFOCUS <bGfocus> ]     ;
             [ ON LOSTFOCUS <bLfocus> ]    ;
             [ ON KEYDOWN <bKeyDown> ]     ;
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
          => ;
          [<oListbox> := ] HListBox():Redefine( <oParent>,<nId>,<nInit>,,<aItems>,<oFont>,<bInit>, ;
             <bSize>,<bDraw>,<bChange>,<cTooltip>,<bGfocus>,<bLfocus>, <bKeyDown>,<bOther> )

#xcommand @ <nX>, <nY> GET LISTBOX [ <oListbox> VAR ]  <vari> ;
             ITEMS  <aItems>            ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON INIT <bInit> ]        ;
             [ ON SIZE <bSize> ]        ;
             [ ON PAINT <bDraw> ]       ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ WHEN <bGFocus> ]         ;
             [ VALID <bLFocus> ]        ;
             [ ON KEYDOWN <bKeyDown> ]  ;
             [ ON DBLCLICK <bDblClick> ];
             [[ON OTHER MESSAGES <bOther>][ON OTHERMESSAGES <bOther>]] ;
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oListbox> := ] __IIF(<.class.>, <classname>, HListBox)():New( <oParent>,<nId>,<vari>,;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,<aItems>,<oFont>,<bInit>,<bSize>,<bDraw>, ;
             <bChange>,<cTooltip>,<color>,<bcolor>,<bGFocus>,<bLFocus>,<bKeyDown>,<bDblClick>,<bOther>);;
          [ <oListbox>:name := <(oListbox)> ]
