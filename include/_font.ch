// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand PREPARE FONT <oFont>       ;
             NAME <cName>            ;
             [ WIDTH <nWidth> ]      ;
             [ HEIGHT <nHeight> ]    ;
             [ WEIGHT <nWeight> ]    ;
             [ CHARSET <charset> ]   ;
             [ <ita: ITALIC> ]       ;
             [ <under: UNDERLINE> ]  ;
             [ <strike: STRIKEOUT> ] ;
          => ;
          <oFont> := HFont():Add(<cName>, <nWidth>, <nHeight>, <nWeight>, <charset>, ;
             IIf(<.ita.>, 1, 0), IIf(<.under.>, 1, 0), IIf(<.strike.>, 1, 0))
