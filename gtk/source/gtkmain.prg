//
// $Id: gtkmain.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// Main prg level functions
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include "hwgui.ch"

FUNCTION hwg_EndWindow()
   IF HWindow():GetMain() != NIL
      HWindow():aWindows[1]:Close()
   ENDIF
RETURN NIL

FUNCTION hwg_VColor( cColor )
Local i,res := 0, n := 1, iValue
   cColor := Trim(cColor)
   for i := 1 to Len(cColor)
      iValue := Asc(SubStr(cColor, Len(cColor) - i + 1, 1))
      if iValue < 58 .AND. iValue > 47
         iValue -= 48
      elseif iValue >= 65 .AND. iValue <= 70
         iValue -= 55
      elseif iValue >= 97 .AND. iValue <= 102
         iValue -= 87
      else
        RETURN 0
      endif
      res += iValue * n
      n *= 16
   next
RETURN res

FUNCTION hwg_MsgGet( cTitle, cText, nStyle, x, y, nDlgStyle )
Local oModDlg, oFont := HFont():Add("Sans", 0, 12)
Local cRes := ""

   nStyle := IIf(nStyle == NIL, 0, nStyle)
   x := IIf(x == NIL, 210, x)
   y := IIf(y == NIL, 10, y)
   nDlgStyle := IIf(nDlgStyle == NIL, 0, nDlgStyle)

   INIT DIALOG oModDlg TITLE cTitle AT x,y SIZE 300, 140 ;
        FONT oFont CLIPPER STYLE WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + nDlgStyle

   @ 20, 10 SAY cText SIZE 260, 22
   @ 20, 35 GET cres  SIZE 260, 26 STYLE WS_DLGFRAME + WS_TABSTOP + nStyle

   @ 20, 95 BUTTON "Ok" ID IDOK SIZE 100, 32 ON CLICK {||oModDlg:lResult:=.T.,EndDialog()}
   @ 180, 95 BUTTON "Cancel" ID IDCANCEL SIZE 100, 32 ON CLICK {||EndDialog()}

   ACTIVATE DIALOG oModDlg

   oFont:Release()
   IF oModDlg:lResult
      RETURN Trim(cRes)
   ELSE
      cRes := ""
   ENDIF

RETURN cRes

FUNCTION hwg_WChoice(arr, cTitle, nLeft, nTop, oFont, clrT, clrB, clrTSel, clrBSel)
Local oDlg, oBrw
Local nChoice := 0, i, aLen := Len(arr), nLen := 0, addX := 20, addY := 30
Local hDC, aMetr, width, height, screenh

   IF cTitle == NIL; cTitle := ""; ENDIF
   IF nLeft == NIL; nLeft := 10; ENDIF
   IF nTop == NIL; nTop := 10; ENDIF
   IF oFont == NIL; oFont := HFont():Add("Times", 0, 12); ENDIF

   IF HB_IsArray( arr[1] )
      FOR i := 1 TO aLen
         nLen := Max( nLen,Len(arr[i, 1]) )
      NEXT
   ELSE
      FOR i := 1 TO aLen
         nLen := Max( nLen,Len(arr[i]) )
      NEXT
   ENDIF

   hDC := hwg_GetDC(hwg_GetActiveWindow())
   hwg_SelectObject( hDC, ofont:handle )
   aMetr := hwg_GetTextMetric(hDC)
   hwg_ReleaseDC(hwg_GetActiveWindow(), hDC)
   height := (aMetr[1]+1)*aLen+4+addY
   screenh := hwg_GETDESKTOPHEIGHT()
   IF height > screenh * 2/3
      height := Int( screenh *2/3 )
      addX := addY := 0
   ENDIF
   width := (Round((aMetr[3] + aMetr[2]) / 2, 0) + 3) * nLen + addX

   INIT DIALOG oDlg TITLE cTitle ;
         AT nLeft,nTop           ;
         SIZE width,height  ;
         FONT oFont

   @ 0, 0 BROWSE oBrw ARRAY          ;
       SIZE  width,height           ;
       FONT oFont                   ;
       STYLE WS_BORDER              ;
       ON SIZE {|o,x,y|o:Move(,,x,y)} ;
       ON CLICK {|o|nChoice:=o:nCurrent,EndDialog(o:oParent:handle)}

   IF HB_IsArray( arr[1] )
      oBrw:AddColumn( HColumn():New( ,{|value,o|o:aArray[o:nCurrent, 1]},"C",nLen ) )
   ELSE
      oBrw:AddColumn( HColumn():New( ,{|value,o|o:aArray[o:nCurrent]},"C",nLen ) )
   ENDIF
   hwg_CreateArList( oBrw, arr )
   oBrw:lDispHead := .F.
   IF clrT != NIL
      oBrw:tcolor := clrT
   ENDIF
   IF clrB != NIL
      oBrw:bcolor := clrB
   ENDIF
   IF clrTSel != NIL
      oBrw:tcolorSel := clrTSel
   ENDIF
   IF clrBSel != NIL
      oBrw:bcolorSel := clrBSel
   ENDIF

   oDlg:Activate()
   oFont:Release()

RETURN nChoice


INIT PROCEDURE GTKINIT()
   hwg_gtk_init()
RETURN

/*
EXIT PROCEDURE GTKEXIT()
   hwg_gtk_exit()
RETURN
*/

FUNCTION hwg_RefreshAllGets( oDlg )

   AEval(oDlg:GetList, {|o|o:Refresh()})
RETURN NIL

FUNCTION HWG_Version(oTip)
RETURN "HwGUI " + HWG_VERSION + IIf(oTip == 1, " " + Version(), "")

FUNCTION hwg_WriteStatus( oWnd, nPart, cText, lRedraw )
Local aControls, i
   aControls := oWnd:aControls
   IF ( i := AScan(aControls, {|o|o:ClassName() == "HSTATUS"}) ) > 0
      hwg_WriteStatusWindow( aControls[i]:handle,nPart-1,cText )

   ENDIF
RETURN NIL

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(ENDWINDOW, HWG_ENDWINDOW);
HB_FUNC_TRANSLATE(VCOLOR, HWG_VCOLOR);
HB_FUNC_TRANSLATE(MSGGET, HWG_MSGGET);
HB_FUNC_TRANSLATE(WCHOICE, HWG_WCHOICE);
HB_FUNC_TRANSLATE(REFRESHALLGETS, HWG_REFRESHALLGETS);
HB_FUNC_TRANSLATE(WRITESTATUS, HWG_WRITESTATUS);
#endif

#pragma ENDDUMP
