// DO NOT USE THIS FILE DIRECTLY - USED BY GUILIB.CH

#xcommand @ <nX>, <nY>, <X2>, <Y2> RECT <oRect> [<lPress: PRESS>] [OF <oParent>] [RECT_STYLE <nST>];
          => <oRect> := HRect():New(<oParent>,<nX>,<nY>,<X2>,<Y2>, <.lPress.>, <nST> )
          //  [ <oRect>:name := <(oRect)> ]
