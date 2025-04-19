// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY> GET COMBOBOXEX [ <oCombo> VAR ] <vari> ;
             ITEMS  <aItems>            ;
             [ OF <oParent> ]              ;
             [ ID <nId> ]               ;
             [ SIZE <nWidth>, <nHeight> ] ;
             [ DISPLAYCOUNT <nDisplay>] ;
             [ ITEMHEIGHT <nhItem>    ] ;
             [ COLUMNWIDTH <ncWidth>  ] ;
             [ COLOR <color> ]          ;
             [ BACKCOLOR <bcolor> ]     ;
             [ ON CHANGE <bChange> ]    ;
             [ STYLE <nStyle> ]         ;
             [ FONT <oFont> ]           ;
             [ TOOLTIP <cTooltip> ]       ;
             [ <edit: EDIT> ]           ;
             [ <text: TEXT> ]           ;
             [ WHEN <bWhen> ]           ;
             [ VALID <bValid> ]         ;
             [CHECK <acheck>];
             [ <class: CLASS> <classname> ] ;
          => ;
          [<oCombo> := ] __IIF(<.class.>, <classname>, HCheckComboBox)():New( <oParent>,<nId>,<vari>,    ;
             {|v|IIf(v == NIL,<vari>,<vari>:=v)},      ;
             <nStyle>,<nX>,<nY>,<nWidth>,<nHeight>,      ;
             <aItems>,<oFont>,,,,<bChange>,<cTooltip>, ;
             <.edit.>,<.text.>,<bWhen>,<color>,<bcolor>, ;
						 <bValid>,<acheck>,<nDisplay>,<nhItem>,<ncWidth>);;
          [ <oCombo>:name := <(oCombo)> ]
