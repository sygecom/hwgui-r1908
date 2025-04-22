// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand SET TIMER <oTimer>  ;
             [ OF <oParent> ] ;
             [ ID <id> ]      ;
             VALUE <value>    ;
             ACTION <bAction> ;
          => ;
          <oTimer> := HTimer():New(<oParent>, <id>, <value>, <bAction>) ;;
          [ <oTimer>:name := <(oTimer)> ]
