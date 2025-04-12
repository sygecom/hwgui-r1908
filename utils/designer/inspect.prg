/*
 * $Id: inspect.prg 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * Designer
 * Object Inspector
 *
 * Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/

#include <fileio.ch>
#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"
#include <common.ch>

#xcommand @ <x>,<y> PBROWSE [ <oBrw> ] ;
            [ <lArr: ARRAY> ]          ;
            [ <lDb: DATABASE> ]        ;
            [ OF <oWnd> ]              ;
            [ ID <nId> ]               ;
            [ SIZE <width>, <height> ] ;
            [ ON INIT <bInit> ]        ;
            [ ON SIZE <bSize> ]        ;
            [ ON PAINT <bDraw> ]       ;
            [ ON CLICK <bEnter> ]      ;
            [ ON GETFOCUS <bGfocus> ]  ;
            [ ON LOSTFOCUS <bLfocus> ] ;
            [ STYLE <nStyle> ]         ;
            [ <lNoVScr: NO VSCROLL> ]  ;
            [ <lNoBord: NOBORDER> ]    ;
            [ FONT <oFont> ]           ;
            [ <lAppend: APPEND> ]      ;
            [ <lAutoedit: AUTOEDIT> ]  ;
            [ ON UPDATE <bUpdate> ]    ;
            [ ON KEYDOWN <bKeyDown> ]  ;
          => ;
    [<oBrw> :=] PBrowse():New( IIf(<.lDb.>,BRW_DATABASE,IIf(<.lArr.>,BRW_ARRAY, 0)),;
        <oWnd>,<nId>,<nStyle>,<x>,<y>,<width>,<height>,<oFont>,<bInit>,<bSize>, ;
        <bDraw>,<bEnter>,<bGfocus>,<bLfocus>,<.lNoVScr.>,<.lNoBord.>, <.lAppend.>,;
        <.lAutoedit.>, <bUpdate>, <bKeyDown> )

STATIC oCombo, oBrw1, oBrw2
STATIC aProp := {}, aMethods := {}
STATIC oTab , oMenuisnp

CLASS PBrowse INHERIT HBrowse

   METHOD New( lType,oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont, ;
                  bInit,bSize,bPaint,bEnter,bGfocus,bLfocus,lNoVScroll,     ;
                  lNoBorder,lAppend,lAutoedit,bUpdate,bKeyDown )
   METHOD Edit()
   METHOD HeaderOut( hDC )
ENDCLASS

METHOD New( lType,oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont, ;
               bInit,bSize,bPaint,bEnter,bGfocus,bLfocus,lNoVScroll,     ;
               lNoBorder,lAppend,lAutoedit,bUpdate,bKeyDown ) CLASS PBrowse

   ::Super:New( lType,oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont, ;
               bInit,bSize,bPaint,bEnter,bGfocus,bLfocus,lNoVScroll,       ;
               lNoBorder,lAppend,lAutoedit,bUpdate,bKeyDown )
RETURN Self

METHOD Edit( wParam,lParam ) CLASS PBrowse
   
   MEMVAR oDesigner

   LOCAL varbuf
   LOCAL x1
   LOCAL y1
   LOCAL nWidth
   LOCAL j
   LOCAL cName
   LOCAL aCtrlProp
   LOCAL aDataDef := oDesigner:aDataDef
   LOCAL lRes := .F.
   LOCAL oColumn
   LOCAL nChoic
   LOCAL oGet
   LOCAL oBtn
   LOCAL aItems
   // : LFB
   LOCAL aItemsaux
   LOCAL k
   LOCAL cAlias
   LOCAL i
   // : END LFB
   MEMVAR Value
   MEMVAR oCtrl
   PRIVATE value
   PRIVATE oCtrl := IIf(oCombo:value == 1, HFormGen():oDlgSelected, GetCtrlSelected(HFormGen():oDlgSelected))

   HB_SYMBOL_UNUSED(wParam)
   HB_SYMBOL_UNUSED(lParam)

   IF ::SetColumn() == 1 .AND. ::bEnter == NIL
      RETURN NIL
   ENDIF
   ::cargo := Eval(::bRecno, Self)
   IF oTab:GetActivePage() == 2
      IF ( value := EditMethod(aMethods[::cargo, 1],aMethods[::cargo, 2]) ) != NIL ;
          .AND. !( aMethods[::cargo, 2] == value )
         aMethods[::cargo, 2] := value
         IF oCombo:value == 1
            HFormGen():oDlgSelected:oParent:aMethods[::cargo, 2] := value
         ELSE
            GetCtrlSelected(HFormGen():oDlgSelected):aMethods[::cargo, 2] := value
         ENDIF
         HFormGen():oDlgSelected:oParent:lChanged := .T.
         oBrw2:lUpdated := .T.
         oBrw2:Refresh()
      ENDIF
      RETURN NIL
   ENDIF
   IF oCombo:value == 1
      aCtrlProp := oCtrl:oParent:aProp
   ELSE
      aCtrlProp := oCtrl:aProp
   ENDIF
   oColumn := ::aColumns[2]
   cName := Lower(aProp[::cargo, 1])
   j := AScan(aDataDef, {|a|a[1] == cName})
   varbuf := Eval(oColumn:block, , Self, 2)

   IF ( j != 0 .AND. aDataDef[j, 5] != NIL ) .OR. aCtrlProp[oBrw1:cargo, 3] == "A"
      IF j != 0 .AND. aDataDef[j, 5] != NIL
         IF aDataDef[j, 5] == "color"
            varbuf := hwg_ChooseColor( Val(varbuf),.F. )
            IF varbuf != NIL
               varbuf := LTrim(Str(varbuf))
               lRes := .T.
            ENDIF
         ELSEIF aDataDef[j, 5] == "font"
            varbuf := HFont():Select( varbuf )
            IF varbuf != NIL
               lRes := .T.
            ENDIF
         ELSEIF aDataDef[j, 5] == "file"
            // :LFB
            x1  := ::x1 + ::aColumns[1]:width - 2
               y1 := ::y1 + ( ::height+1 ) * ( ::rowPos - 1 )
            nWidth := Min( ::aColumns[2]:width, ::x2 - x1 - 1 )
            ReadExit( .T. )

           obrw1:bPosChanged:={|| VldBrwGet(oGet,oBtn)}
           @ x1+14,y1-2 GET oGet VAR varbuf OF oBrw1  ;
            SIZE nWidth, ::height+6        ;
            STYLE ES_AUTOHSCROLL           ;
            FONT ::oFont                   ;
            WHEN {||hwg_PostMessage(oBtn:handle, WM_CLOSE, 0, 0), OgET:REFRESH(), .T.}

           @ x1,y1-2 BUTTON oBtn CAPTION "..." OF oBrw1;
            SIZE 13,::height+6  ;
            ON CLICK {|| (varbuf := IIF (aDataDef[j, 1] == "filename",;
                    hwg_SelectFile("Animation Files( *.avi )", "*.avi"), IIf(aDataDef[j, 1] == "filedbf", ;
                    hwg_SelectFile({"xBase Files( *.dbf)", " All Files( *.*)"}, {"*.dbf", "*.*"}), ;
                    hwg_SelectFile("Imagens Files( *.jpg;*.gif;*.bmp;*.ico )", ;
                      "*.jpg;*.gif;*.bmp;*.ico")))), ;
                   IIf(!Empty(varbuf),oGet:refresh(),NIL)} //,;
                  *   VldBrwGet(oGet)} //,   hwg_PostMessage(oBtn:handle, WM_CLOSE, 0, 0)}
                  // : END LFB
            //varbuf := hwg_SelectFile("All files ( *.* )", "*.*")
            //
            hwg_SetFocus( obtn:handle )
            IF varbuf != NIL
               lRes := .T.
            ENDIF
         ENDIF
      ELSE
         varbuf := EditArray( varbuf )
         IF varbuf != NIL
            lRes := .T.
         ENDIF
      ENDIF

      IF lRes
         cName := Lower(aProp[oBrw1:cargo, 1])
         j := AScan(aDataDef, {|a|a[1] == cName})
         value := aProp[oBrw1:cargo, 2] := varbuf
         aCtrlProp[oBrw1:cargo, 2] := value
         IF j != 0 .AND. aDataDef[j, 3] != NIL
            EvalCode(aDataDef[j, 3])
            IF aDataDef[j, 4] != NIL
               EvalCode(aDataDef[j, 4])
            ENDIF
         ENDIF
         hwg_RedrawWindow( oCtrl:handle, 5 )
         HFormGen():oDlgSelected:oParent:lChanged := .T.
         oBrw1:lUpdated := .T.
         oBrw1:Refresh()
      ENDIF
   ELSE
      x1  := ::x1 + ::aColumns[1]:width - 2
      y1 := ::y1 + ( ::height+1 ) * ( ::rowPos - 1 )
      nWidth := Min( ::aColumns[2]:width, ::x2 - x1 - 1 )

      ReadExit( .T. )
      IF ( j != 0 .AND. aDataDef[j, 6] != NIL ) .OR. aCtrlProp[oBrw1:cargo, 3] == "L"

         // : LFB - CAMPOS PARA AS COLUNAS
         IF ( j != 0 .AND. aDataDef[j, 6] != NIL .AND.aDataDef[j, 6][1] = "@afields" )// funcao
            //cAlias := LEFT(hwg_CutPath( value ),AT(".",hwg_CutPath( value ))-1)
            aItems := {" "}
            FOR i = 1 to 200
               cAlias := ALIAS(i)
               IF !Empty(ALIAS(i))
                  aItemsaux  := ARRAY(&(alias(i))->(FCOUNT()) )
                  &(alias(i))->(Afields(aItemsAux))
                  FOR k = 1 TO Len(aItemsaux)
                     AAdd(aitems, ALIAS(i) + "->" + aItemsAux[k])
                      //AAdd(aitems, aItemsAux[k])
                  NEXT
               ENDIF
            NEXT
         //
         ELSEIF ( j != 0 .AND. aDataDef[j, 6] != NIL .AND.aDataDef[j, 6][1] = "@atags" )// funcao
               i := 1
                 aItems := {" "}
                 IF select(alias()) > 0
                    DO WHILE !Empty(ORDNAME(i))
                        AAdd(aItems, ORDNAME(i++))
                     ENDDO
                  ENDIF
             ELSE
             aItems := IIf(j != 0 .AND. aDataDef[j, 6] != NIL, aDataDef[j, 6], {"True", "False"})
         ENDIF
         varbuf := AllTrim(varbuf)
         nChoic := AScan(aItems, varbuf)

         @ x1,y1-2 COMBOBOX oGet           ;
            ITEMS aItems                   ;
            INIT nChoic                    ;
            OF oBrw1                       ;
            SIZE nWidth, ::height + 6      ;
            FONT ::oFont                   ;
            STYLE WS_VSCROLL               ;
            ON LOSTFOCUS {||VldBrwGet(oGet)}
      ELSE
         @ x1,y1-2 GET oGet VAR varbuf OF oBrw1  ;
            SIZE nWidth, ::height+6        ;
            STYLE ES_AUTOHSCROLL           ;
            FONT ::oFont                   ;
            VALID {||VldBrwGet(oGet)}
      ENDIF
      hwg_SetFocus( oGet:handle )
   ENDIF
RETURN NIL

METHOD HeaderOut( hDC ) CLASS PBrowse

   LOCAL i
   LOCAL x
   LOCAL fif
   LOCAL xSize
   LOCAL nRows := Min( ::nRecords,::rowCount )
   LOCAL oColumn
   LOCAL oPen := HPen():Add(PS_SOLID, 1,::sepColor)
   LOCAL oPenLight := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DHILIGHT))
   LOCAL oPenGray  := HPen():Add(PS_SOLID, 1, hwg_GetSysColor(COLOR_3DSHADOW))

   x := ::x1
   fif := IIf(::freeze > 0, 1, ::nLeftCol)

   DO WHILE x < ::x2 - 2
      oColumn := ::aColumns[fif]
      xSize := oColumn:width
      if fif == Len(::aColumns)
         xSize := Max( ::x2 - x, xSize )
      endif
      if x > ::x1
         hwg_SelectObject( hDC, oPenLight:handle )
         hwg_DrawLine(hDC, x - 1, ::y1 + 1, x - 1, ::y1 + (::height + 1) * nRows)
         hwg_SelectObject( hDC, oPenGray:handle )
         hwg_DrawLine(hDC, x - 2, ::y1 + 1, x - 2, ::y1 + (::height + 1) * nRows)
      endif
      x += xSize
      fif := IIf(fif = ::freeze, ::nLeftCol, fif + 1)
      if fif > Len(::aColumns)
         exit
      endif
   ENDDO

   hwg_SelectObject( hDC, oPen:handle )
   FOR i := 1 to nRows
      hwg_DrawLine(hDC, ::x1, ::y1 + (::height + 1) * i, IIf(::lAdjRight, ::x2, x), ::y1 + (::height + 1) * i)
   NEXT

   oPen:Release()

RETURN NIL


// -----------------------------

STATIC FUNCTION VldBrwGet( oGet ,oBtn)

   LOCAL vari
   LOCAL j
   LOCAL cName
   MEMVAR Value
   MEMVAR oCtrl
   MEMVAR oDesigner
   PRIVATE value
   PRIVATE oCtrl := IIf(oCombo:value == 1, HFormGen():oDlgSelected, GetCtrlSelected(HFormGen():oDlgSelected))

   cName := Lower(aProp[oBrw1:cargo, 1])

   j := AScan(oDesigner:aDataDef, {|a|a[1] == cName})

   IF oGet:Classname() == "HCOMBOBOX"
      vari := hwg_SendMessage(oGet:handle, CB_GETCURSEL, 0, 0) + 1
      value := aProp[oBrw1:cargo, 2] := oGet:aItems[vari]
   ELSE
      vari := Trim(oGet:GetText())   // :LFB -  COLOCOU TRIM
      value := aProp[oBrw1:cargo, 2] := vari
   ENDIF
   IF oCombo:value == 1
      oCtrl:oParent:aProp[oBrw1:cargo, 2] := value
   ELSE
      oCtrl:aProp[oBrw1:cargo, 2] := value
   ENDIF
   IF j != 0 .AND. oDesigner:aDataDef[j, 3] != NIL
      // pArray := oDesigner:aDataDef[j, 6]
      EvalCode(oDesigner:aDataDef[j, 3])
      IF oDesigner:aDataDef[j, 4] != NIL
         EvalCode(oDesigner:aDataDef[j, 4])
      ENDIF
   ENDIF
   hwg_RedrawWindow( oCtrl:handle, 5 )
   HFormGen():oDlgSelected:oParent:lChanged := .T.
   oBrw1:lUpdated := .T.
   oBrw1:aEvents := {}
   oBrw1:aNotify := {}
   oBrw1:aControls := {}
   hwg_PostMessage(oGet:handle, WM_CLOSE, 0, 0)
   // :LFB POS
   IF HB_IsObject(obtn)
     hwg_PostMessage(oBtn:handle, WM_CLOSE, 0, 0)
   ENDIF
   obrw1:bPosChanged:= NIL
   // : END LFB

   // oBrw1:DelControl( oGet )
   // oBrw1:Refresh()
RETURN .T.

FUNCTION InspOpen(lShow)

   LOCAL nStilo := 0
   MEMVAR oDesigner
   // PRIVATE oMenuDlg := 0

   *FONT oDesigner:oMainWnd:oFonti
   *STYLE WS_POPUP+WS_VISIBLE+WS_CAPTION+WS_SIZEBOX+WS_SYSMENU;
   lShow := IIf(ValType(lShow) != "U",lShow, .T.)
   nStilo := WS_CAPTION+WS_SIZEBOX+MB_USERICON + WS_VISIBLE
   //  IIf(lShow,WS_VISIBLE, 0) //DS_SYSMODAL
   INIT DIALOG oDesigner:oDlgInsp TITLE "Object Inspector" ;
      AT 0, 280 SIZE 220, 300       ;
      FONT HFont():Add("MS Sans Serif", 0, -12, 400, , ,)  ;
      STYLE nStilo;
      ON INIT {||IIf(!lshow,oDesigner:oDlgInsp:hide(),),hwg_MoveWindow(oDesigner:oDlgInsp:handle, 0, 134, 280, 410)}   ;
      ON GETFOCUS {|o| o:show(),.T.};
      ON EXIT {||oDesigner:oDlgInsp := NIL,hwg_CheckMenuItem(oDesigner:oMainWnd:handle, 1010,.F.),.T.} ;
      ON OTHER MESSAGES {|o,m,wp,lp|MessagesOthers(o,m,wp,lp)}

   @ 0, 0 COMBOBOX oCombo ITEMS {} SIZE 220, 22 ;
          STYLE WS_VSCROLL                     ;
          ON SIZE {|o,x|hwg_MoveWindow(o:handle, 0, 0, x, 250)} ;
          ON CHANGE {||ComboOnChg()}

   @ 0, 28 TAB oTab ITEMS {} SIZE 220, 250 ;
      ON SIZE {|o,x,y|hwg_MoveWindow(o:handle, 0, 28, x, y - 28)}

   BEGIN PAGE "Properties" OF oTab
      @ 2, 30 PBROWSE oBrw1 ARRAY SIZE 214, 218 STYLE WS_VSCROLL ;
         ON SIZE {|o,x,y|hwg_MoveWindow(o:handle, 2, 30, x-6, y-32)}
         hwg_SetDlgKey(oDesigner:oDlgInsp, 0, VK_DELETE,{|| ResetToDefault(oBrw1)} )

      oBrw1:tColor := hwg_GetSysColor( COLOR_BTNTEXT )
      oBrw1:tColorSel := 8404992
      oBrw1:bColor := oBrw1:bColorSel := hwg_GetSysColor( COLOR_BTNFACE )
      oBrw1:freeze := 1
      oBrw1:lDispHead := .F.
      oBrw1:lSep3d := .T.
      oBrw1:sepColor  := hwg_GetSysColor( COLOR_BTNSHADOW )
      oBrw1:aArray := aProp
      oBrw1:AddColumn( HColumn():New( ,{|v,o| HB_SYMBOL_UNUSED(v),IIf(Empty(o:aArray[o:nCurrent, 1]),"","  "+o:aArray[o:nCurrent, 1])},"C", 12, 0, .T. ) )
      oBrw1:AddColumn( HColumn():New( ,hwg_ColumnArBlock(),"U", 100, 0, .T. ) )
   END PAGE OF oTab

   BEGIN PAGE "Events" OF oTab
      @ 2, 30 PBROWSE oBrw2 ARRAY SIZE 214, 218 STYLE WS_VSCROLL ;
         ON SIZE {|o,x,y|hwg_MoveWindow(o:handle, 2, 30, x-6, y-32)}
      oBrw2:tColor := hwg_GetSysColor( COLOR_BTNTEXT )
      oBrw2:tColorSel := 8404992
      oBrw2:bColor := oBrw2:bColorSel := hwg_GetSysColor( COLOR_BTNFACE )
      oBrw2:freeze := 1
      oBrw2:lDispHead := .F.
      oBrw2:lSep3d := .T.
      oBrw2:sepColor  := hwg_GetSysColor( COLOR_BTNSHADOW )
      oBrw2:aArray := aMethods
      oBrw2:AddColumn( HColumn():New( ,{|v,o|HB_SYMBOL_UNUSED(v),IIf(Empty(o:aArray[o:nCurrent, 1]),"","  "+o:aArray[o:nCurrent, 1])},"C", 12, 0,.T. ) )
      oBrw2:AddColumn( HColumn():New( ,{|v,o|HB_SYMBOL_UNUSED(v),IIf(Empty(o:aArray[o:nCurrent, 2]),"",":"+o:aArray[o:nCurrent, 1])},"C", 100, 0,.T. ) )
   END PAGE OF oTab

     // : LFB POS
   @ 190, 25 BUTTON "Close" SIZE 50, 23     ;
       ON SIZE {|o,x|o:Move(x-52,,,)};
       ON CLICK {|| oDesigner:oDlgInsp:close()}
   // : LFB

   CONTEXT MENU oMenuisnp
      MENUITEM "AlwaysOnTop" ACTION ActiveTopMost( oDesigner:oDlgInsp:Handle, .T. )
         //{||oDesigner:oDlgInsp:Close(),inspOpen(.F.)}
      MENUITEM "Normal" ACTION ActiveTopMost( oDesigner:oDlgInsp:Handle, .F. )
         //{||oDesigner:oDlgInsp:Close(),inspOpen(0)}
      MENUITEM "Hide" ACTION oDesigner:oDlgInsp:close()
    ENDMENU

   ACTIVATE DIALOG oDesigner:oDlgInsp NOMODAL
   hwg_CheckMenuItem(oDesigner:oMainWnd:handle, 1010,.T.)

   InspSetCombo()

   oDesigner:oDlgInsp:AddEvent( 0,IDOK,{||DlgOk()} )
   oDesigner:oDlgInsp:AddEvent( 0,IDCANCEL,{||DlgCancel()} )

RETURN NIL


STATIC FUNCTION DlgOk()

   IF !Empty(oBrw1:aControls)
      VldBrwGet( oBrw1:aControls[1] )
   ENDIF
RETURN NIL

STATIC FUNCTION DlgCancel()

   IF !Empty(oBrw1:aControls)
      oBrw1:aEvents := {}
      oBrw1:aNotify := {}
      hwg_PostMessage(oBrw1:aControls[1]:handle, WM_CLOSE, 0, 0)
      oBrw1:aControls := {}
      // oBrw1:DelControl( oBrw1:aControls[1] )
      // oBrw1:Refresh()
   ENDIF
RETURN NIL

FUNCTION InspSetCombo()

   LOCAL i
   LOCAL aControls
   LOCAL oCtrl
   LOCAL n := -1
   LOCAL oDlg := HFormGen():oDlgSelected
   MEMVAR oDesigner

   oCombo:aItems := {}
   IF oDlg != NIL
      n := 0
      AAdd(oCombo:aItems, "Form." + oDlg:title)
      oCtrl := GetCtrlSelected(oDlg)
      aControls := IIf(oDesigner:lReport, oDlg:aControls[1]:aControls[1]:aControls, oDlg:aControls)
      FOR i := 1 TO Len(aControls)
        if ( oDesigner:lReport )
            AAdd(oCombo:aItems, aControls[i]:cClass + "." + IIf(aControls[i]:title != NIL, Left(aControls[i]:title, 15), LTrim(Str(aControls[i]:id))))
        else
            AAdd(oCombo:aItems, aControls[i]:cClass + "." + aControls[i]:GetProp("Name", 2))
        endif
        IF oCtrl != NIL .AND. oCtrl:handle == aControls[i]:handle
            n := i
        ENDIF
      NEXT
   ENDIF
   oCombo:Requery()
   oCombo:SetItem(n + 1)
   /*
   oCombo:value := n + 1
   oCombo:Refresh()
   */
   InspSetBrowse()
RETURN NIL

FUNCTION InspUpdCombo( n )

   LOCAL aControls
   LOCAL i
   MEMVAR oDesigner

   IF n > 0
      aControls := IIf(oDesigner:lReport, ;
         HFormGen():oDlgSelected:aControls[1]:aControls[1]:aControls, ;
         HFormGen():oDlgSelected:aControls)
      i := Len(aControls)
      IF i >= Len(oCombo:aItems)
   if ( oDesigner:lReport )
      AAdd(oCombo:aItems, aControls[i]:cClass + "." + IIf(aControls[i]:title != NIL, Left(aControls[i]:title, 15), LTrim(Str(aControls[i]:id))))
   else
      AAdd(oCombo:aItems, aControls[i]:cClass + "." + aControls[i]:GetProp("Name", 2))
   endif

      ELSEIF i + 1 < Len(oCombo:aItems)
         RETURN InspSetCombo()
      ENDIF
   ENDIF
   oCombo:Requery()
   oCombo:SetItem(n + 1)
   /*
   oCombo:value := n + 1
   oCombo:Refresh()
   */
   InspSetBrowse()
RETURN NIL

STATIC FUNCTION ComboOnChg()

   MEMVAR oDesigner
   LOCAL oDlg := HFormGen():oDlgSelected
   LOCAL oCtrl
   LOCAL n
   LOCAL aControls := IIf(oDesigner:lReport, oDlg:aControls[1]:aControls[1]:aControls, oDlg:aControls)

   oCombo:value := hwg_SendMessage(oCombo:handle, CB_GETCURSEL, 0, 0) + 1
   IF oDlg != NIL
      n := oCombo:value - 1
      oCtrl := GetCtrlSelected(oDlg)
      IF n == 0
         IF oCtrl != NIL
            SetCtrlSelected(oDlg)
         ENDIF
      ELSEIF n > 0
         IF oCtrl == NIL .OR. oCtrl:handle != aControls[n]:handle
            SetCtrlSelected(oDlg, aControls[n], n)
         ENDIF
      ENDIF
   ENDIF
RETURN .T.

STATIC FUNCTION InspSetBrowse()

   LOCAL i
   LOCAL o
   LOCAL nRow := 1

   IF oBrw1 != NIL
          nRow:=oBrw1:rowPos
    ENDIF
   aProp := {}
   aMethods := {}

   IF oCombo:value > 0
      o := IIf(oCombo:value == 1, HFormGen():oDlgSelected:oParent, GetCtrlSelected(HFormGen():oDlgSelected))
      FOR i := 1 TO Len(o:aProp)
         IF Len(o:aProp[i]) == 3
            AAdd(aProp, { o:aProp[i, 1], o:aProp[i, 2] })
         ENDIF
      NEXT
      FOR i := 1 TO Len(o:aMethods)
         AAdd(aMethods, { o:aMethods[i, 1], o:aMethods[i, 2] })
      NEXT
   ENDIF

   oBrw1:aArray := aProp
   oBrw2:aArray := aMethods

   Eval(oBrw1:bGoTop, oBrw1)
   Eval(oBrw2:bGoTop, oBrw2)
   oBrw1:rowPos := 1 //IIf(nrow > Len(APROP), 1,NROW-1) //1
   oBrw2:rowPos := 1
   oBrw1:Refresh()
   oBrw2:Refresh()

RETURN NIL

FUNCTION InspUpdBrowse()

   LOCAL i
   LOCAL lChg := .F.
   MEMVAR value
   MEMVAR oCtrl
   MEMVAR oDesigner
   PRIVATE value
   PRIVATE oCtrl

   IF oCombo == NIL
      RETURN NIL
   ENDIF

   oCtrl := IIf(oCombo:value == 1, HFormGen():oDlgSelected, GetCtrlSelected(HFormGen():oDlgSelected))
   IF oDesigner:oDlgInsp != NIL
      FOR i := 1 TO Len(aProp)
         value := IIf(oCombo:value == 1,oCtrl:oParent:aProp[i, 2], oCtrl:aProp[i, 2])
         IF !HB_IsObject(aProp[i, 2]) .AND. !HB_IsArray(aProp[i, 2]) ;
               .AND. ( aProp[i, 2] == NIL .OR. !( aProp[i, 2] == value ) )
            aProp[i, 2] := value
            lChg := .T.
         ENDIF
      NEXT
      IF lChg .AND. !oBrw1:lHide
         oBrw1:Refresh()
         // : LFB pos
         statusbarmsg(,"x: "+LTrim(Str(oCtrl:nLeft))+"  y: "+LTrim(Str(oCtrl:nTop)),;
         "w: "+LTrim(Str(oCtrl:nWidth))+" h: "+LTrim(Str(oCtrl:nHeight)))
         // : LFB
      ENDIF
   ENDIF

RETURN NIL

FUNCTION InspUpdProp( cName, xValue )

   LOCAL i

   cName := Lower(cName)
   IF ( i := AScan(aProp, {|a|Lower(a[1]) == Lower(cName)}) ) > 0
      aProp[i, 2] := xValue
      oBrw1:Refresh()
   ENDIF

RETURN NIL

STATIC FUNCTION EditArray( arr )

    LOCAL oDlg
    LOCAL oBrw
    LOCAL nRec := Eval(oBrw1:bRecno, oBrw1)
    LOCAL arrold := {}
    MEMVAR oDesigner

   IF arr == NIL
      arr := {}
   ENDIF
   IF Empty(arr)
      AAdd(arr,".....")
   ENDIF
   arrold := arr
   INIT DIALOG oDlg TITLE "Edit "+aProp[nRec, 1]+" array" ;
        AT 300, 280 SIZE 400, 300 FONT oDesigner:oMainWnd:oFont

   @ 0, 0 BROWSE oBrw ARRAY SIZE 400, 255  ;
       ON SIZE {|o,x,y|o:Move(,,x,y-45)}
    oBrw:acolumns:={}
   oBrw:bcolor := 15132390
   oBrw:bcolorSel := hwg_VColor( "008000" )
   oBrw:lAppable := .T.
   oBrw:aArray := arr
   oBrw:AddColumn( HColumn():New( ,{|v,o|IIf(v != NIL,o:aArray[o:nCurrent]:=v,o:aArray[o:nCurrent])},"C", 100, 0,.T. ) )
  // 30 - 35
   @ 21, 265 BUTTON "Delete Item"  SIZE 110, 26 ;
       ON SIZE {|o,x,y|HB_SYMBOL_UNUSED(x),o:Move(,y-30,,)};
       ON CLICK {|| onclick_deleteItem(oBrw)}
   @ 151, 265 BUTTON "Ok" SIZE 110, 26     ;
       ON SIZE {|o,x,y|HB_SYMBOL_UNUSED(x),o:Move(,y-30,,)}  ;
       ON CLICK {||oDlg:lResult:=.T.,EndDialog()}
   @ 276, 265 BUTTON "Cancel" ID IDCANCEL SIZE 110, 26 ;
       ON SIZE {|o,x,y|HB_SYMBOL_UNUSED(x),o:Move(,y-30,,)}

   ACTIVATE DIALOG oDlg

   IF oDlg:lResult
      IF Len(arr) == 1 .AND. arr[1] == "....."
         arr := NIL //{} NANDO POS
      ENDIF
      RETURN arr
   ENDIF

RETURN NIL

// : LFB
STATIC FUNCTION onclick_deleteitem(oBrw)
  IF oBrw:nCurrent = 1 .AND. oBrw:aArray[oBrw:nCurrent] = ".."
    RETURN NIL
  ENDIF
  IF Len(obrw:aArray) > 0 .AND. hwg_MsgYesNo("Confirm item deleted : [ "+oBrw:aArray[oBrw:nCurrent]+" ] ?","Items")
     oBrw:aArray := ADel(obrw:aArray, oBrw:nCurrent)
     obrw:aArray := ASize(obrw:aArray, Len(obrw:aArray) - 1)
     obrw:refresh()
  ENDIF
RETURN NIL

FUNCTION ObjInspector(oObject )
*****************************************************************************
   LOCAL opForm
   LOCAL oBrw
   LOCAL oBrw2
   LOCAL nLeft := 0
   LOCAL nTop
   LOCAL nLin
   LOCAL oPage1,i
   LOCAL oBtn1
   LOCAL cType
   LOCAL aClassMsgMtdo
   LOCAL aClassMsgProp

   IF oObject = NIL
      oObject := HFormGen():oDlgSelected
   ENDIF
   //lData := .T.
   aClassMsgMtdo := __objGetMethodList(oObject)
#ifndef __XHARBOUR__
   aClassMsgProp := __objGetProperties( oObject, .T. )
#else
   aClassMsgProp := __ObjGetValueDiff(oObject)
#endif
   For i = 1 to Len(aClassMsgProp)
     ctype := ValType(aClassMsgProp[i, 2])
     do case
       CASE ctype="C"
       CASE ctype="N"
       aClassMsgProp[i, 2] := Str(aClassMsgProp[i, 2])
       CASE ctype="L"
       aClassMsgProp[i, 2] := IIf(aClassMsgProp[i, 2],"True","False")
       otherwise
       aClassMsgProp[i, 2] := ctype
     endcase
   Next

   INIT DIALOG opForm ;
      NOEXIT ;
      TITLE "Methods and Properties" ;
      FONT HFont():Add("Arial", 0, -11) ;
      AT 0, 0 ;
      SIZE 600, 400 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

    nTop = 4
   nLeft += 15
   @ nLeft, nTop button oBtn1 ;
      caption "&Exit" ;
      size 80, 25 ;
      on click { || EndDialog() }

  @ nLeft + 150, ntop+2 SAY "Object: " + "oObject"  SIZE 200, 24
   nLin = nTop + 30

  @ 6,nlin-5 TAB oPage1 ITEMS {} SIZE 580, 360
  BEGIN PAGE " Properties " OF oPage1
   @ 010, nLin BROWSE oBrw ARRAY ;
      SIZE 570, 300 ;
      STYLE WS_VSCROLL + WS_HSCROLL

   hwg_CreateArList( oBrw, aClassMsgProp )

   oBrw:aColumns[1]:length = 30
   oBrw:aColumns[1]:heading = " Property "
   oBrw:aColumns[2]:length = 10
   oBrw:aColumns[2]:heading = " Value "

   END PAGE OF oPage1

   BEGIN PAGE " Methods " OF oPage1
      @ 010, nLin browse oBrw2 array ;
      SIZE 570, 300 ;
      STYLE WS_VSCROLL + WS_HSCROLL

   hwg_CreateArList( oBrw2, aClassMsgMtdo )

   oBrw2:aColumns[1]:length = 10
   oBrw2:aColumns[1]:heading = "Methods"

    END PAGE OF oPage1

   opForm:Activate()

   RETURN NIL


STATIC FUNCTION MessagesOthers( oDlg, msg, wParam, lParam )
   
   MEMVAR oDesigner

HB_SYMBOL_UNUSED(lParam)

   // writelog( Str(msg)+Str(wParam)+Str(lParam) )
   IF msg == WM_MOUSEMOVE
     * MouseMove(oDlg, wParam, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      RETURN 1
   ELSEIF msg == WM_LBUTTONDOWN
     * LButtonDown( oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
      RETURN 1
   ELSEIF msg == WM_LBUTTONUP
     * LButtonUp( oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
      RETURN 1
   ELSEIF msg == WM_RBUTTONUP
      *RButtonUp( oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam) )
        oMenuisnp:Show( oDlg,oDlg:nTop+5,oDlg:nLeft+15,.T. )
      RETURN 1
   ELSEIF msg == WM_LBUTTONDBLCLK
      oDlg:hide()
      *hwg_MsgInfo("Futura a‡Æo dos Eventos")
      RETURN 1
   ELSEIF msg == WM_MOVE
   ELSEIF msg == WM_KEYDOWN
      IF wParam == 46    // Del
         DeleteCtrl()
      ENDIF
   ELSEIF msg == WM_KEYUP
   ENDIF

RETURN -1

FUNCTION ActiveTopMost( nHandle, lActive )

   LOCAL lSucess   // ,nHandle
  nHandle:=hwg_GetActiveWindow()

  IF lActive
       lSucess := hwg_SetTopMost(nHandle)    // Set TopMost
  ELSE
       lSucess := hwg_RemoveTopMost(nHandle) // Remove TopMost
  ENDIF

RETURN lSucess

STATIC FUNCTION resettodefault(oBrw1)

   LOCAL j
   LOCAL cName
   MEMVAR oDesigner
   MEMVAR value
   MEMVAR oCtrl
   PRIVATE value
   PRIVATE oCtrl := IIf(oCombo:value == 1, HFormGen():oDlgSelected, GetCtrlSelected(HFormGen():oDlgSelected))

     cName := Lower(aProp[oBrw1:nCurrent, 1])
     j := AScan(oDesigner:aDataDef, {|a|a[1] == cName})
     IF j = 0 .OR. aProp[oBrw1:nCurrent, 2] = NIL
       RETURN NIL
     ENDIF
     IF LTrim(oBrw1:aArray[oBrw1:nCurrent, 1]) = "Font"
        value := aProp[oBrw1:nCurrent, 2]
        value:name := ""
     ELSE
        value := aProp[oBrw1:nCurrent, 2]
        //aProp[oBrw1:nCurrent, 2] := NIL //value
     ENDIF
     IF j != 0 .AND. oDesigner:aDataDef[j, 3] != NIL
        EvalCode(oDesigner:aDataDef[j, 3])
        IF oDesigner:aDataDef[j, 4] != NIL
           EvalCode(oDesigner:aDataDef[j, 4])
        ENDIF
     ENDIF
     hwg_RedrawWindow( oCtrl:handle, 5 )
     HFormGen():oDlgSelected:oParent:lChanged := .T.
     oBrw1:lUpdated := .T.
     oBrw1:Refresh()

 RETURN NIL

  // :END LFB

