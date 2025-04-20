//
// $Id: hedit.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HEdit class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hblang.ch"
#include "hwgui.ch"

#ifndef DLGC_WANTARROWS
#define DLGC_WANTARROWS     1      /* Control wants arrow keys         */
#define DLGC_WANTTAB        2      /* Control wants tab keys           */
#define DLGC_WANTCHARS    128      /* Want WM_CHAR messages            */
#endif

#define GDK_BackSpace       0xFF08
#define GDK_Tab             0xFF09
#define GDK_Return          0xFF0D
#define GDK_Escape          0xFF1B
#define GDK_Delete          0xFFFF
#define GDK_Home            0xFF50
#define GDK_Left            0xFF51
#define GDK_Up              0xFF52
#define GDK_Right           0xFF53
#define GDK_Down            0xFF54
#define GDK_End             0xFF57
#define GDK_Insert          0xFF63

#define GDK_Shift_L         0xFFE1
#define GDK_Shift_R         0xFFE2
#define GDK_Control_L       0xFFE3
#define GDK_Control_R       0xFFE4
#define GDK_Alt_L           0xFFE9
#define GDK_Alt_R           0xFFEA

CLASS HEdit INHERIT HControl

   CLASS VAR winclass   INIT "EDIT"
   DATA lMultiLine   INIT .F.
   DATA cType INIT "C"
   DATA bSetGet
   DATA bValid
   DATA bAnyEvent
   DATA cPicFunc, cPicMask
   DATA lPicComplex  INIT .F.
   DATA lFirst       INIT .T.
   DATA lChanged     INIT .F.
   DATA lMaxLength   INIT NIL
   DATA nLastKey     INIT 0

   //METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
   //      oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, tcolor, bcolor, cPicture, lNoBorder, lMaxLength)
   METHOD New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, ;
                  tcolor, bcolor, cPicture, lNoBorder, lMaxLength, lPassword)
   METHOD Activate()
   METHOD onEvent(msg, wParam, lParam)
   METHOD Init()
   METHOD SetGet(value) INLINE Eval(::bSetGet, value, self)
   METHOD Refresh()
   METHOD SetText(c)
   METHOD GetText() INLINE hwg_Edit_GetText(::handle)

ENDCLASS

METHOD HEdit:New(oWndParent, nId, vari, bSetGet, nStyle, nLeft, nTop, nWidth, nHeight, ;
                  oFont, bInit, bSize, bPaint, bGfocus, bLfocus, ctoolt, ;
                  tcolor, bcolor, cPicture, lNoBorder, lMaxLength, lPassword)

   nStyle := hwg_BitOr(iIf(nStyle == NIL, 0, nStyle), ;
                WS_TABSTOP + IIf(lNoBorder == NIL .OR. !lNoBorder, WS_BORDER, 0)+;
                IIf(lPassword == NIL .OR. !lPassword, 0, ES_PASSWORD))

   ::Super:New(oWndParent, nId, nStyle, nLeft, nTop, nWidth, nHeight, oFont, bInit, ;
                  bSize, bPaint, ctoolt, tcolor, bcolor)

   IF vari != NIL
      ::cType   := ValType(vari)
   ENDIF
   IF bSetGet == NIL
      ::title := vari
   ENDIF
   ::bSetGet := bSetGet

   IF hwg_BitAnd(nStyle, ES_MULTILINE) != 0
      ::style := hwg_BitOr(::style, ES_WANTRETURN)
      ::lMultiLine := .T.
   ENDIF

   IF !Empty(cPicture) .OR. cPicture == NIL .And. lMaxLength != NIL .OR. !Empty(lMaxLength)
      ::lMaxLength := lMaxLength
   ENDIF
/*   IF ::lMaxLength != NIL .AND. !Empty(::lMaxLength)
      IF !Empty(cPicture) .OR. cPicture == NIL
         cPicture := Replicate("X", ::lMaxLength)
      ENDIF
   ENDIF                        ----------------- commented out by Maurizio la Cecilia */

   ParsePict(Self, cPicture, vari)
   ::Activate()

   ::bGetFocus := bGFocus
   ::bLostFocus := bLFocus
   hwg_SetEvent(::handle, "focus_in_event", WM_SETFOCUS, 0, 0)
   hwg_SetEvent(::handle, "focus_out_event", WM_KILLFOCUS, 0, 0)
   hwg_SetEvent(::handle, "key_press_event", 0, 0, 0)

RETURN Self

METHOD HEdit:Activate()

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateEdit(::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight)
      hwg_SetWindowObject(::handle, Self)
      ::Init()
   ENDIF
RETURN NIL

METHOD HEdit:onEvent(msg, wParam, lParam)

   LOCAL oParent := ::oParent
   LOCAL nPos
   //LOCAL nctrl // variable not used
   //LOCAL cKeyb // variable not used

   // WriteLog("Edit: " + Str(msg, 10) + "|" + Str(wParam, 10) + "|" + Str(lParam, 10))
   IF ::bAnyEvent != NIL .AND. Eval(::bAnyEvent, Self, msg, wParam, lParam) != 0
      RETURN 0
   ENDIF

   IF msg == WM_KEYUP
      IF wParam != 16 .AND. wParam != 17 .AND. wParam != 18
         DO WHILE oParent != NIL .AND. !__ObjHasMsg(oParent, "GETLIST")
            oParent := oParent:oParent
         ENDDO
         IF oParent != NIL .AND. !Empty(oParent:KeyList)
	    /*
            cKeyb := hwg_GetKeyboardState()
            nctrl := IIf(Asc(SubStr(cKeyb, VK_CONTROL + 1, 1)) >= 128, FCONTROL, IIf(Asc(SubStr(cKeyb, VK_SHIFT + 1, 1)) >= 128, FSHIFT, 0))
            IF (nPos := AScan(oParent:KeyList, {|a|a[1] == nctrl .AND. a[2] == wParam})) > 0
               Eval(oParent:KeyList[nPos, 3])
            ENDIF
	    */
         ENDIF
      ENDIF
   ELSEIF msg == WM_SETFOCUS
      IF ::bSetGet == NIL
         IF ::bGetFocus != NIL
            Eval(::bGetFocus, hwg_Edit_GetText(::handle), Self)
         ENDIF
      ELSE
         __When(Self)
      ENDIF
   ELSEIF msg == WM_KILLFOCUS
      IF ::bSetGet == NIL
         IF ::bLostFocus != NIL
            Eval(::bLostFocus, hwg_Edit_GetText(::handle), Self)
         ENDIF
      ELSE
         __Valid(Self)
      ENDIF
   ELSEIF msg == WM_DESTROY
      ::End()
   ENDIF
   
   IF ::bSetGet == NIL
      ::Title := ::GetText()
      RETURN 0
   ENDIF

   IF !::lMultiLine
      IF msg == WM_KEYDOWN
         ::nLastKey := wParam
         IF wParam == GDK_BackSpace
            ::lFirst := .F.
            SetGetUpdated(Self)
            IF ::lPicComplex
               DeleteChar(Self, .T.)
               RETURN 1
            ENDIF
            RETURN 0
         ELSEIF wParam == GDK_Down     // KeyDown
            IF lParam == 0
               hwg_GetSkip(oParent, ::handle, 1)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Up     // KeyUp
            IF lParam == 0
               hwg_GetSkip(oParent, ::handle, -1)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Right     // KeyRight
            IF lParam == 0
               ::lFirst := .F.
               RETURN KeyRight(Self)
            ENDIF
         ELSEIF wParam == GDK_Left     // KeyLeft
               ::lFirst := .F.
               RETURN KeyLeft(Self)
         ELSEIF wParam == GDK_Home     // Home
               ::lFirst := .F.
               hwg_edit_SetPos(::handle, 0)
               RETURN 1
         ELSEIF wParam == GDK_End     // End
               ::lFirst := .F.
               IF ::cType == "C"
                  nPos := Len(Trim(::title))
		  hwg_edit_SetPos(::handle, nPos)
                  RETURN 1
               ENDIF
         ELSEIF wParam == GDK_Insert     // Insert
            IF lParam == 0
               Set(_SET_INSERT, ! Set(_SET_INSERT))
            ENDIF
         ELSEIF wParam == GDK_Delete     // Del
            ::lFirst := .F.
            SetGetUpdated(Self)
            IF ::lPicComplex
               DeleteChar(Self, .F.)
               RETURN 1
            ENDIF
         ELSEIF wParam == GDK_Tab     // Tab
            IF hwg_CheckBit(lParam, 1)
               hwg_GetSkip(oParent, ::handle, -1)
            ELSE
               hwg_GetSkip(oParent, ::handle, 1)
            ENDIF
            RETURN 1
         ELSEIF wParam == GDK_Return  // Enter
            IF !hwg_GetSkip(oParent, ::handle, 1, .T.) .AND. ::bSetGet != NIL
	       __Valid(Self)
	    ENDIF
            RETURN 1
         ELSEIF wParam >= 32 .AND. wParam < 65000
            RETURN GetApplyKey(Self, Chr(wParam))
	 ELSE
	    RETURN 1
         ENDIF
      ENDIF

   ELSE

      IF msg == WM_MOUSEWHEEL
         nPos := hwg_HIWORD(wParam)
         nPos := IIf(nPos > 32768, nPos - 65535, nPos)
         HB_SYMBOL_UNUSED(nPos)
         // hwg_SendMessage(::handle, EM_SCROLL, IIf(nPos > 0, SB_LINEUP, SB_LINEDOWN), 0)
         // hwg_SendMessage(::handle, EM_SCROLL, IIf(nPos > 0, SB_LINEUP, SB_LINEDOWN), 0)
      ENDIF

   ENDIF
 
RETURN 0

METHOD HEdit:Init()

   IF !::lInit
      ::Super:Init()
      ::Refresh()
   ENDIF

RETURN NIL

METHOD HEdit:Refresh()
Local vari

   IF ::bSetGet != NIL
      vari := Eval(::bSetGet, , self)

      IF !Empty(::cPicFunc) .OR. !Empty(::cPicMask)
         vari := Transform(vari, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
      ELSE
         vari := IIf(::cType == "D", DToC(vari), IIf(::cType == "N", Str(vari), IIf(::cType == "C", vari, "")))
      ENDIF
      ::title := vari
      hwg_Edit_SetText(::handle, vari)
   ELSE
      hwg_Edit_SetText(::handle, ::title)
   ENDIF

RETURN NIL

METHOD HEdit:SetText(c)

  IF c != NIL
     IF HB_IsObject(c)
        //in run time return object
        RETURN NIL
     ENDIF
     IF !Empty(::cPicFunc) .OR. !Empty(::cPicMask)
        ::title := Transform(c, ::cPicFunc + IIf(Empty(::cPicFunc), "", " ") + ::cPicMask)
     ELSE
        ::title := c
     ENDIF
     hwg_Edit_SetText(::handle, ::title)
     IF ::bSetGet != NIL
       Eval(::bSetGet, c, self)
     ENDIF
  ENDIF

RETURN NIL

STATIC FUNCTION ParsePict(oEdit, cPicture, vari)
Local nAt, i, masklen, cChar

   IF oEdit:bSetGet == NIL
      RETURN NIL
   ENDIF
   oEdit:cPicFunc := oEdit:cPicMask := ""
   IF cPicture != NIL
      IF Left(cPicture, 1) == "@"
         nAt := At(" ", cPicture)
         IF nAt == 0
            oEdit:cPicFunc := Upper(cPicture)
            oEdit:cPicMask := ""
         ELSE
            oEdit:cPicFunc := Upper(SubStr(cPicture, 1, nAt - 1))
            oEdit:cPicMask := SubStr(cPicture, nAt + 1)
         ENDIF
         IF oEdit:cPicFunc == "@"
            oEdit:cPicFunc := ""
         ENDIF
      ELSE
         oEdit:cPicFunc   := ""
         oEdit:cPicMask   := cPicture
      ENDIF
   ENDIF

   IF Empty(oEdit:cPicMask)
      IF oEdit:cType == "D"
         oEdit:cPicMask := StrTran(DToC(CToD(Space(8))), " ", "9")
      ELSEIF oEdit:cType == "N"
         vari := Str(vari)
         IF (nAt := At(".", vari)) > 0
            oEdit:cPicMask := Replicate("9", nAt - 1) + "." + ;
                  Replicate("9", Len(vari) - nAt)
         ELSE
            oEdit:cPicMask := Replicate("9", Len(vari))
         ENDIF
      ENDIF
   ENDIF

   IF !Empty(oEdit:cPicMask)
      masklen := Len(oEdit:cPicMask)
      FOR i := 1 TO masklen
         cChar := SubStr(oEdit:cPicMask, i, 1)
         IF !cChar $ "!ANX9#"
            oEdit:lPicComplex := .T.
            EXIT
         ENDIF
      NEXT
   ENDIF

//                                         ------------ added by Maurizio la Cecilia

   IF oEdit:lMaxLength != NIL .AND. !Empty(oEdit:lMaxLength) .AND. Len(oEdit:cPicMask) < oEdit:lMaxLength
      oEdit:cPicMask := PadR(oEdit:cPicMask, oEdit:lMaxLength, "X")
   ENDIF

//                                         ------------- end of added code

RETURN NIL

STATIC FUNCTION IsEditable(oEdit, nPos)
Local cChar

   IF Empty(oEdit:cPicMask)
      RETURN .T.
   ENDIF
   IF nPos > Len(oEdit:cPicMask)
      RETURN .F.
   ENDIF

   cChar := SubStr(oEdit:cPicMask, nPos, 1)

   IF oEdit:cType == "C"
      RETURN cChar $ "!ANX9#"
   ELSEIF oEdit:cType == "N"
      RETURN cChar $ "9#$*"
   ELSEIF oEdit:cType == "D"
      RETURN cChar == "9"
   ELSEIF oEdit:cType == "L"
      RETURN cChar $ "TFYN"
   ENDIF

RETURN .F.

STATIC FUNCTION KeyRight(oEdit, nPos)

   //LOCAL i // variable not used
   LOCAL masklen
   LOCAL newpos
   //LOCAL vari // variable not used

   IF oEdit == NIL
      RETURN 0
   ENDIF
   IF nPos == NIL
      nPos := hwg_edit_Getpos(oEdit:handle) + 1
   ENDIF
   IF oEdit:cPicMask == NIL .OR. Empty(oEdit:cPicMask)
      hwg_edit_Setpos(oEdit:handle, nPos)
   ELSE
      masklen := Len(oEdit:cPicMask)
      DO WHILE nPos <= masklen
         IF IsEditable(oEdit, ++nPos)
            // writelog("KeyRight - 2 " + str(nPos))
            hwg_edit_Setpos(oEdit:handle, nPos - 1)
            EXIT
         ENDIF
       ENDDO
   ENDIF

   //Added By Sandro Freire

   IF !Empty(oEdit:cPicMask)
        newPos := Len(oEdit:cPicMask)
        //writelog("KeyRight - 2 " + str(nPos) + " " + str(newPos))
        IF nPos>newPos .AND. !Empty(Trim(oEdit:Title))
            hwg_edit_Setpos(oEdit:handle, newPos)
        ENDIF
   ENDIF

RETURN 1

STATIC FUNCTION KeyLeft(oEdit, nPos)

   //LOCAL i // variable not used

   IF oEdit == NIL
      RETURN 0
   ENDIF
   IF nPos == NIL
      nPos := hwg_edit_Getpos(oEdit:handle) + 1
   ENDIF
   IF oEdit:cPicMask == NIL .OR. Empty(oEdit:cPicMask)
      hwg_edit_Setpos(oEdit:handle, nPos - 2)
   ELSE
      DO WHILE nPos >= 1
         IF IsEditable(oEdit, --nPos)
            hwg_edit_Setpos(oEdit:handle, nPos - 1)
            EXIT
         ENDIF
      ENDDO
   ENDIF
RETURN 1

STATIC FUNCTION DeleteChar(oEdit, lBack)
Local nPos := hwg_edit_Getpos(oEdit:handle) + IIf(!lBack, 1, 0)
Local nGetLen := Len(oEdit:cPicMask), nLen

   FOR nLen := 0 TO nGetLen
      IF !IsEditable(oEdit, nPos + nLen)
         Exit
      ENDIF
   NEXT
   IF nLen == 0
      DO WHILE nPos >= 1
         nPos --
         nLen ++
         IF IsEditable(oEdit, nPos)
            EXIT
         ENDIF
      ENDDO
   ENDIF
   IF nPos > 0
      oEdit:title := PadR(Left(oEdit:title, nPos - 1) + ;
                  SubStr(oEdit:title, nPos + 1, nLen - 1) + " " + ;
                  SubStr(oEdit:title, nPos + nLen), nGetLen)
      hwg_edit_Settext(oEdit:handle, oEdit:title)
      hwg_edit_Getpos(oEdit:handle, nPos - 1)
   ENDIF
   
RETURN NIL

STATIC FUNCTION Input(oEdit, cChar, nPos)
Local cPic

   IF !Empty(oEdit:cPicMask) .AND. nPos > Len(oEdit:cPicMask)
      RETURN NIL
   ENDIF
   IF oEdit:cType == "N"
      IF cChar == "-"
         IF nPos != 1
            RETURN NIL
         ENDIF
         // ::minus := .T.
      ELSEIF !(cChar $ "0123456789")
         RETURN NIL
      ENDIF

   ELSEIF oEdit:cType == "D"

      IF !(cChar $ "0123456789")
         RETURN NIL
      ENDIF

   ELSEIF oEdit:cType == "L"

      IF !(Upper(cChar) $ "YNTF")
         RETURN NIL
      ENDIF

   ENDIF

   IF !Empty(oEdit:cPicFunc)
      cChar := Transform(cChar, oEdit:cPicFunc)
   ENDIF

   IF !Empty(oEdit:cPicMask)
      cPic  := SubStr(oEdit:cPicMask, nPos, 1)

      cChar := Transform(cChar, cPic)
      IF cPic == "A"
         IF !IsAlpha(cChar)
            cChar := NIL
         ENDIF
      ELSEIF cPic == "N"
         IF !IsAlpha(cChar) .AND. !IsDigit(cChar)
            cChar := NIL
         ENDIF
      ELSEIF cPic == "9"
         IF ! IsDigit(cChar) .AND. cChar != "-"
            cChar := NIL
         ENDIF
      ELSEIF cPic == "#"
         IF ! IsDigit(cChar) .AND. !(cChar == " ") .AND. !(cChar $ "+-")
            cChar := NIL
         ENDIF
      ENDIF
   ENDIF

RETURN cChar

STATIC FUNCTION GetApplyKey(oEdit, cKey)

   LOCAL nPos
   LOCAL nGetLen
   LOCAL nLen
   LOCAL vari
   LOCAL i
   LOCAL x
   LOCAL newPos

   x := hwg_edit_Getpos(oEdit:handle)
   HB_SYMBOL_UNUSED(x)

   // writelog("GetApplyKey " + str(asc(ckey)))
   oEdit:title := hwg_edit_Gettext(oEdit:handle)
   IF oEdit:cType == "N" .AND. cKey $ ".," .AND. ;
                     (nPos := At(".", oEdit:cPicMask)) != 0
      IF oEdit:lFirst
         vari := 0
      ELSE
         vari := Trim(oEdit:title)
         FOR i := 2 TO Len(vari)
            IF !IsDigit(SubStr(vari, i, 1))
               vari := Left(vari, i - 1) + SubStr(vari, i + 1)
            ENDIF
         NEXT
         vari := Val(vari)
      ENDIF
      IF !Empty(oEdit:cPicFunc) .OR. !Empty(oEdit:cPicMask)
         oEdit:title := Transform(vari, oEdit:cPicFunc + IIf(Empty(oEdit:cPicFunc), "", " ") + oEdit:cPicMask)
      ENDIF
      hwg_edit_Settext(oEdit:handle, oEdit:title)
      KeyRight(oEdit, nPos - 1)
   ELSE

      IF oEdit:cType == "N" .AND. oEdit:lFirst
         nGetLen := Len(oEdit:cPicMask)
         IF (nPos := At(".", oEdit:cPicMask)) == 0
            oEdit:title := Space(nGetLen)
         ELSE
            oEdit:title := Space(nPos - 1) + "." + Space(nGetLen - nPos)
         ENDIF
         nPos := 1
      ELSE
         nPos := hwg_edit_Getpos(oEdit:handle) + 1
      ENDIF
      cKey := Input(oEdit, cKey, nPos)
      IF cKey != NIL
         SetGetUpdated(oEdit)
         IF Set(_SET_INSERT) // .OR. hwg_HIWORD(x) != hwg_LOWORD(x)
            IF oEdit:lPicComplex
               nGetLen := Len(oEdit:cPicMask)
               FOR nLen := 0 TO nGetLen
                  IF !IsEditable(oEdit, nPos + nLen)
                     Exit
                  ENDIF
               NEXT
               oEdit:title := Left(oEdit:title, nPos - 1) + cKey + ;
                  SubStr(oEdit:title, nPos, nLen - 1) + SubStr(oEdit:title, nPos + nLen)
            ELSE
               oEdit:title := Left(oEdit:title, nPos - 1) + cKey + ;
                  SubStr(oEdit:title, nPos)
            ENDIF

            IF !Empty(oEdit:cPicMask) .AND. Len(oEdit:cPicMask) < Len(oEdit:title)
               oEdit:title := Left(oEdit:title, nPos - 1) + cKey + SubStr(oEdit:title, nPos + 1)
            ENDIF
         ELSE
            oEdit:title := Left(oEdit:title, nPos - 1) + cKey + SubStr(oEdit:title, nPos + 1)
         ENDIF
         hwg_edit_Settext(oEdit:handle, oEdit:title)
         // writelog("GetApplyKey " + oEdit:title + str(nPos - 1))
         KeyRight(oEdit, nPos)
         //Added By Sandro Freire
         IF oEdit:cType == "N"
            IF !Empty(oEdit:cPicMask)
                newPos := Len(oEdit:cPicMask) - 3
                IF "E" $ oEdit:cPicFunc .AND. nPos == newPos
                    GetApplyKey(oEdit, ",")
                ENDIF
            ENDIF
         ENDIF

      ENDIF
   ENDIF
   oEdit:lFirst := .F.

RETURN 1

STATIC FUNCTION __When(oCtrl)
Local res

   oCtrl:Refresh()
   oCtrl:lFirst := .T.
   IF oCtrl:bGetFocus != NIL 
      res := Eval(oCtrl:bGetFocus, oCtrl:title, oCtrl)
      IF !res
         hwg_GetSkip(oCtrl:oParent, oCtrl:handle, 1)
      ENDIF
      RETURN res
   ENDIF

RETURN .T.

STATIC FUNCTION __valid(oCtrl)
Local vari, oDlg

    IF oCtrl:bSetGet != NIL
      IF (oDlg := hwg_ParentGetDialog(oCtrl)) == NIL .OR. oDlg:nLastKey != 27
         vari := UnTransform(oCtrl, hwg_Edit_GetText(oCtrl:handle))
         oCtrl:title := vari
         IF oCtrl:cType == "D"
            IF IsBadDate(vari)
               hwg_SetFocus(oCtrl:handle)
	       hwg_edit_SetPos(oCtrl:handle, 0)
               RETURN .F.
            ENDIF
            vari := Ctod(vari)
         ELSEIF oCtrl:cType == "N"
            vari := Val(LTrim(vari))
            oCtrl:title := Transform(vari, oCtrl:cPicFunc + IIf(Empty(oCtrl:cPicFunc), "", " ") + oCtrl:cPicMask)
            hwg_edit_Settext(oCtrl:handle, oCtrl:title)
         ENDIF
         Eval(oCtrl:bSetGet, vari, oCtrl)

         IF oDlg != NIL
            oDlg:nLastKey := 27
         ENDIF
         IF oCtrl:bLostFocus != NIL .AND. !Eval(oCtrl:bLostFocus, vari, oCtrl)
            hwg_SetFocus(oCtrl:handle)
	      hwg_edit_SetPos(oCtrl:handle, 0)
            IF oDlg != NIL
               oDlg:nLastKey := 0
            ENDIF
            RETURN .F.
         ENDIF
         IF oDlg != NIL
            oDlg:nLastKey := 0
         ENDIF
      ENDIF
   ENDIF

RETURN .T.

STATIC FUNCTION Untransform(oEdit, cBuffer)
Local xValue, cChar, nFor, minus

   IF oEdit:cType == "C"

      IF "R" $ oEdit:cPicFunc
         FOR nFor := 1 to Len(oEdit:cPicMask)
            cChar := SubStr(oEdit:cPicMask, nFor, 1)
            IF !cChar $ "ANX9#!"
               cBuffer := SubStr(cBuffer, 1, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
         cBuffer := StrTran(cBuffer, Chr(1), "")
      ENDIF

      xValue := cBuffer

   ELSEIF oEdit:cType == "N"
      minus := (Left(LTrim(cBuffer), 1) == "-")
      cBuffer := Space(FirstEditable(oEdit) - 1) + SubStr(cBuffer, FirstEditable(oEdit), LastEditable(oEdit) - FirstEditable(oEdit) + 1)

      IF "D" $ oEdit:cPicFunc
         FOR nFor := FirstEditable(oEdit) to LastEditable(oEdit)
            IF !IsEditable(oEdit, nFor)
               cBuffer = Left(cBuffer, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
      ELSE
         IF "E" $ oEdit:cPicFunc
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) +           ;
                        StrTran(SubStr(cBuffer, FirstEditable(oEdit), ;
                           LastEditable(oEdit) - FirstEditable(oEdit) + 1), ;
                           ".", " ") + SubStr(cBuffer, LastEditable(oEdit) + 1)
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) +           ;
                        StrTran(SubStr(cBuffer, FirstEditable(oEdit), ;
                           LastEditable(oEdit) - FirstEditable(oEdit) + 1), ;
                           ",", ".") + SubStr(cBuffer, LastEditable(oEdit) + 1)
         ELSE
            cBuffer := Left(cBuffer, FirstEditable(oEdit) - 1) +        ;
                        StrTran(SubStr(cBuffer, FirstEditable(oEdit), ;
                        LastEditable(oEdit) - FirstEditable(oEdit) + 1), ;
                         ",", " ") + SubStr(cBuffer, LastEditable(oEdit) + 1)
         ENDIF

         FOR nFor := FirstEditable(oEdit) to LastEditable(oEdit)
            IF !IsEditable(oEdit, nFor) .AND. SubStr(cBuffer, nFor, 1) != "."
               cBuffer = Left(cBuffer, nFor - 1) + Chr(1) + SubStr(cBuffer, nFor + 1)
            ENDIF
         NEXT
      ENDIF

      cBuffer := StrTran(cBuffer, Chr(1), "")

      cBuffer := StrTran(cBuffer, "$", " ")
      cBuffer := StrTran(cBuffer, "*", " ")
      cBuffer := StrTran(cBuffer, "-", " ")
      cBuffer := StrTran(cBuffer, "(", " ")
      cBuffer := StrTran(cBuffer, ")", " ")

      cBuffer := PadL(StrTran(cBuffer, " ", ""), Len(cBuffer))

      IF minus
         FOR nFor := 1 to Len(cBuffer)
            IF IsDigit(SubStr(cBuffer, nFor, 1))
               exit
            ENDIF
         NEXT
         nFor--
         IF nFor > 0
            cBuffer := Left(cBuffer, nFor - 1) + "-" + SubStr(cBuffer, nFor + 1)
         ELSE
            cBuffer := "-" + cBuffer
         ENDIF
      ENDIF

      xValue := cBuffer

   ELSEIF oEdit:cType == "L"

      cBuffer := Upper(cBuffer)
      xValue := "T" $ cBuffer .OR. "Y" $ cBuffer .OR. hb_langmessage(HB_LANG_ITEM_BASE_TEXT + 1) $ cBuffer

   ELSEIF oEdit:cType == "D"

      IF "E" $ oEdit:cPicFunc
         cBuffer := SubStr(cBuffer, 4, 3) + SubStr(cBuffer, 1, 3) + SubStr(cBuffer, 7)
      ENDIF
      xValue := cBuffer

   ENDIF

RETURN xValue

STATIC FUNCTION FirstEditable(oEdit)
Local nFor, nMaxLen := Len(oEdit:cPicMask)

   IF IsEditable(oEdit, 1)
      RETURN 1
   ENDIF

   FOR nFor := 2 to nMaxLen
      IF IsEditable(oEdit, nFor)
         RETURN nFor
      ENDIF
   NEXT

RETURN 0

STATIC FUNCTION  LastEditable(oEdit)
Local nFor, nMaxLen := Len(oEdit:cPicMask)

   FOR nFor := nMaxLen to 1 step -1
      IF IsEditable(oEdit, nFor)
         RETURN nFor
      ENDIF
   NEXT

RETURN 0

STATIC FUNCTION IsBadDate(cBuffer)
Local i, nLen

   IF !Empty(CToD(cBuffer))
      RETURN .F.
   ENDIF
   nLen := len(cBuffer)
   FOR i := 1 to nLen
      IF IsDigit(SubStr(cBuffer, i, 1))
         RETURN .T.
      ENDIF
   NEXT
RETURN .F.

FUNCTION hwg_CreateGetList(oDlg)
Local i, j, aLen1 := Len(oDlg:aControls), aLen2

   FOR i := 1 TO aLen1
      IF __ObjHasMsg(oDlg:aControls[i], "BSETGET") .AND. oDlg:aControls[i]:bSetGet != NIL
         AAdd(oDlg:GetList, oDlg:aControls[i])
      ELSEIF !Empty(oDlg:aControls[i]:aControls)
         aLen2 := Len(oDlg:aControls[i]:aControls)
         FOR j := 1 TO aLen2
            IF __ObjHasMsg(oDlg:aControls[i]:aControls[j], "BSETGET") .AND. oDlg:aControls[i]:aControls[j]:bSetGet != NIL
               AAdd(oDlg:GetList, oDlg:aControls[i]:aControls[j])
            ENDIF
         NEXT
      ENDIF
   NEXT
RETURN NIL

FUNCTION hwg_GetSkip(oParent, hCtrl, nSkip, lClipper)
Local i, aLen

   DO WHILE oParent != NIL .AND. !__ObjHasMsg(oParent, "GETLIST")
      oParent := oParent:oParent
   ENDDO
   IF oParent == NIL .OR. (lClipper != NIL .AND. lClipper .AND. !oParent:lClipper)
      RETURN .F.
   ENDIF
   IF hCtrl == NIL
      i := 0
   ENDIF
   IF hCtrl == NIL .OR. (i := AScan(oParent:Getlist, {|o|o:handle == hCtrl})) != 0
      IF (aLen := Len(oParent:Getlist)) > 1
         IF nSkip > 0
            DO WHILE (i := i + nSkip) <= aLen
               IF !oParent:Getlist[i]:lHide .AND. hwg_IsWindowEnabled(oParent:Getlist[i]:Handle) // Now tab and enter goes trhow the check, combo, etc...
                  hwg_SetFocus(oParent:Getlist[i]:handle)
                  IF oParent:Getlist[i]:winclass == "EDIT"
       	         hwg_edit_SetPos(oParent:Getlist[i]:handle, 0)
                  ENDIF
                  RETURN .T.
               ENDIF
            ENDDO
         ELSE
            DO WHILE (i := i + nSkip) > 0
               IF !oParent:Getlist[i]:lHide .AND. hwg_IsWindowEnabled(oParent:Getlist[i]:Handle)
                  hwg_SetFocus(oParent:Getlist[i]:handle)
                  IF oParent:Getlist[i]:winclass == "EDIT"
   	               hwg_edit_SetPos(oParent:Getlist[i]:handle, 0)
                  ENDIF
                  RETURN .T.
               ENDIF
            ENDDO
         ENDIF
      ENDIF
   ENDIF

RETURN .F.

FUNCTION SetGetUpdated(o)

   o:lChanged := .T.
   IF (o := hwg_ParentGetDialog(o)) != NIL
      o:lUpdated := .T.
   ENDIF

RETURN NIL

FUNCTION hwg_ParentGetDialog(o)
   DO WHILE .T.
      o := o:oParent
      IF o == NIL
         EXIT
      ELSE
         IF __ObjHasMsg(o, "GETLIST")
            EXIT
         ENDIF
      ENDIF
   ENDDO
RETURN o

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(CREATEGETLIST, HWG_CREATEGETLIST);
HB_FUNC_TRANSLATE(GETSKIP, HWG_GETSKIP);
HB_FUNC_TRANSLATE(PARENTGETDIALOG, HWG_PARENTGETDIALOG);
#endif

#pragma ENDDUMP
