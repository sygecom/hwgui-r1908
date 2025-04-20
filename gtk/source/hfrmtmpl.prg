//
// $Id: hfrmtmpl.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library source code:
// HFormTmpl Class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#ifdef __XHARBOUR__
#xtranslate HB_AT(<x,...>) => AT(<x>)
#endif

STATIC s_aClass := {"label", "button", "checkbox", ;
                  "radiobutton", "editbox", "group", "radiogroup", ;
                  "bitmap", "icon", ;
                  "richedit", "datepicker", "updown", "combobox", ;
                  "line", "toolbar", "ownerbutton", "browse", ;
                  "monthcalendar", "trackbar", "page", "tree", ;
                  "status", "menu", "animation" ;
                }
STATIC s_aCtrls := { ;
  "HStatic():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,ctooltip,TextColor,BackColor,lTransp)", ;
  "HButton():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,onClick,ctooltip,TextColor,BackColor)", ;
  "HCheckButton():New(oPrnt,nId,lInitValue,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,onClick,ctooltip,TextColor,BackColor,bwhen)", ;
  "HRadioButton():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,onClick,ctooltip,TextColor,BackColor)", ;
  "HEdit():New(oPrnt,nId,cInitValue,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,onPaint,onGetFocus,onLostFocus,ctooltip,TextColor,BackColor,cPicture,lNoBorder,nMaxLength,lPassword)", ;
  "HGroup():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,TextColor,BackColor)", ;
  "hwg_RadioNew(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,caption,oFont,onInit,onSize,onPaint,TextColor,BackColor,nInitValue,bSetGet)", ;
  "HSayBmp():New(oPrnt,nId,nLeft,nTop,nWidth,nHeight,Bitmap,lResource,onInit,onSize,ctooltip)", ;
  "HSayIcon():New(oPrnt,nId,nLeft,nTop,nWidth,nHeight,Icon,lResource,onInit,onSize,ctooltip)", ;
  "HRichEdit():New(oPrnt,nId,cInitValue,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,onPaint,onGetFocus,onLostFocus,ctooltip,TextColor,BackColor)", ;
  "HDatePicker():New(oPrnt,nId,dInitValue,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onGetFocus,onLostFocus,onChange,ctooltip,TextColor,BackColor)", ;
  "HUpDown():New(oPrnt,nId,nInitValue,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,onPaint,onGetFocus,onLostFocus,ctooltip,TextColor,BackColor,nUpDWidth,nLower,nUpper)", ;
  "HComboBox():New(oPrnt,nId,nInitValue,bSetGet,nStyle,nLeft,nTop,nWidth,nHeight,Items,oFont,onInit,onSize,onPaint,onChange,cTooltip,lEdit,lText,bWhen)", ;
  "HLine():New(oPrnt,nId,lVertical,nLeft,nTop,nLength,onSize)", ;
  "HPanel():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,onInit,onSize,onPaint,lDocked)", ;
  "HOwnButton():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,onInit,onSize,onPaint,onClick,flat,caption,TextColor,oFont,TextLeft,TextTop,widtht,heightt,BtnBitmap,lResource,BmpLeft,BmpTop,widthb,heightb,lTr,trColor,cTooltip)", ;
  "Hbrowse():New(BrwType,oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,onPaint,onEnter,onGetfocus,onLostfocus,lNoVScroll,lNoBorder,lAppend,lAutoedit,onUpdate,onKeyDown,onPosChg )", ;
  "HMonthCalendar():New(oPrnt,nId,dInitValue,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onChange,cTooltip,lNoToday,lNoTodayCircle,lWeekNumbers)", ;
  "HTrackBar():New(oPrnt,nId,nInitValue,nStyle,nLeft,nTop,nWidth,nHeight,onInit,onSize,bPaint,cTooltip,onChange,onDrag,nLow,nHigh,lVertical,TickStyle,TickMarks)", ;
  "HTab():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,onPaint,Tabs,onChange,aImages,lResource)", ;
  "HTree():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,oFont,onInit,onSize,TextColor,BackColor,aImages,lResource,lEditLabels,onTreeClick)", ;
  "HStatus():New(oPrnt,nId,nStyle,oFont,aParts,onInit,onSize)", ;
  ".F.", ;
  "HAnimation():New(oPrnt,nId,nStyle,nLeft,nTop,nWidth,nHeight,Filename,AutoPlay,Center,Transparent)" ;
                }

#include <hbclass.ch>
#include "hwgui.ch"
#include "hxml.ch"

#define CONTROL_FIRST_ID   34000

STATIC s_aPenType  := {"SOLID", "DASH", "DOT", "DASHDOT", "DASHDOTDOT"}
STATIC s_aJustify  := {"Left", "Center", "Right"}

REQUEST HSTATIC
REQUEST HBUTTON
REQUEST HCHECKBUTTON
REQUEST HRADIOBUTTON
REQUEST HEDIT
REQUEST HGROUP
REQUEST HSAYBMP
REQUEST HSAYICON
#ifndef __LINUX__
REQUEST HRICHEDIT
REQUEST HDATEPICKER
#endif
REQUEST HUPDOWN
REQUEST HCOMBOBOX
REQUEST HLINE
REQUEST HPANEL
REQUEST HOWNBUTTON
REQUEST HBROWSE
#ifndef __LINUX__
REQUEST HMONTHCALENDAR
REQUEST HTRACKBAR
REQUEST HANIMATION
REQUEST HTREE
#endif
REQUEST HTAB

REQUEST DBUSEAREA
REQUEST RECNO
REQUEST DBSKIP
REQUEST DBGOTOP
REQUEST DBCLOSEAREA

CLASS HCtrlTmpl

   DATA cClass
   DATA oParent
   DATA nId
   DATA aControls INIT {}
   DATA aProp, aMethods

   METHOD New(oParent) INLINE (::oParent := oParent, AAdd(oParent:aControls, Self), Self)
   METHOD F(nId)
ENDCLASS

METHOD F(nId) CLASS HCtrlTmpl
Local i, aControls := ::aControls, nLen := Len(aControls), o

   FOR i := 1 TO nLen
      IF aControls[i]:nId == nId
         RETURN aControls[i]
      ELSEIF !Empty(aControls[i]:aControls) .AND. (o := aControls[i]:F(nId)) != NIL
         RETURN o
      ENDIF
   NEXT

RETURN NIL


CLASS HFormTmpl

   CLASS VAR aForms   INIT {}
   CLASS VAR maxId    INIT 0
   DATA oDlg
   DATA aControls     INIT {}
   DATA aProp
   DATA aMethods
   DATA aVars         INIT {}
   DATA aNames        INIT {}
   DATA aFuncs
   DATA id
   DATA cId
   DATA nContainer    INIT 0
   DATA nCtrlId       INIT CONTROL_FIRST_ID
   DATA cargo

   METHOD Read(fname, cId)
   //METHOD Show(nMode, params)
   METHOD Show(nMode, p1, p2, p3)
   METHOD ShowMain(params) INLINE ::Show(1, params)
   METHOD ShowModal(params) INLINE ::Show(2, params)
   METHOD Close()
   METHOD F(id, n)
   METHOD Find(cId)

ENDCLASS

METHOD Read(fname, cId) CLASS HFormTmpl
Local oDoc
Local i, j, nCtrl := 0, aItems, o, aProp := {}, aMethods := {}
Local cPre

   IF cId != NIL .AND. (o := HFormTmpl():Find(cId)) != NIL
      RETURN o
   ENDIF
   IF Left(fname, 5) == "<?xml"
      oDoc := HXMLDoc():ReadString(fname)
   ELSE
      oDoc := HXMLDoc():Read(fname)
   ENDIF

   IF Empty(oDoc:aItems)
      hwg_MsgStop("Can't open " + fname)
      RETURN NIL
   ELSEIF oDoc:aItems[1]:title != "part" .OR. oDoc:aItems[1]:GetAttribute("class") != "form"
      hwg_MsgStop("Form description isn't found")
      RETURN NIL
   ENDIF

   ::maxId ++
   ::id := ::maxId
   ::cId := cId
   ::aProp := aProp
   ::aMethods := aMethods

   __pp_init()
   AAdd(::aForms, Self)
   aItems := oDoc:aItems[1]:aItems
   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               IF !Empty(o:aItems)
                  AAdd(aProp, {Lower(o:GetAttribute("name")), o:aItems[1]})
               ENDIF
            ENDIF
         NEXT
      ELSEIF aItems[i]:title == "method"
         AAdd(aMethods, {Lower(aItems[i]:GetAttribute("name")), CompileMethod(aItems[i]:aItems[1]:aItems[1], Self)})
         IF aMethods[(j := Len(aMethods)), 1] == "common"
            ::aFuncs := ::aMethods[j, 2, 2]
            FOR j := 1 TO Len(::aFuncs[2])
               cPre := "#xtranslate " + ::aFuncs[2, j, 1] + ;
                     "( <params,...> ) => hwg_callfunc('"  + ;
                     Upper(::aFuncs[2, j, 1]) + "',\{ <params> \}, oDlg:oParent:aFuncs )"
               __Preprocess(cPre)
               cPre := "#xtranslate " + ::aFuncs[2, j, 1] + ;
                     "() => hwg_callfunc('"  + ;
                     Upper(::aFuncs[2, j, 1]) + "',, oDlg:oParent:aFuncs )"
               __Preprocess(cPre)
            NEXT
         ENDIF
      ELSEIF aItems[i]:title == "part"
         nCtrl ++
         ::nContainer := nCtrl
         ReadCtrl(aItems[i], Self, Self)
      ENDIF
   NEXT
   __pp_free()

RETURN Self

METHOD Show(nMode, p1, p2, p3) CLASS HFormTmpl
Local i, j, cType
Local nLeft, nTop, nWidth, nHeight, cTitle, oFont, lClipper := .F., lExitOnEnter := .F.
Local xProperty, block, bFormExit, nstyle
Local lModal := .F.
Local lMdi :=.F.
Local lMdiChild := .F.
//Local lval := .F. // variable not used
Local cBitmap := NIL
Local oBmp := NIL 
Memvar oDlg
Private oDlg

   nStyle := DS_ABSALIGN + WS_VISIBLE + WS_SYSMENU + WS_SIZEBOX

   FOR i := 1 TO Len(::aProp)
      xProperty := hfrm_GetProperty(::aProp[i, 2])
      
      IF ::aProp[i, 1] == "geometry"
         nLeft   := Val(xProperty[1])
         nTop    := Val(xProperty[2])
         nWidth  := Val(xProperty[3])
         nHeight := Val(xProperty[4])
      ELSEIF ::aProp[i, 1] == "caption"
         cTitle := xProperty
      ELSEIF ::aProp[i, 1] == "font"
         oFont := hfrm_FontFromxml(xProperty)
      ELSEIF ::aProp[i, 1] == "lclipper"
         lClipper := xProperty
      ELSEIF ::aProp[i, 1] == "lexitonenter"
         lExitOnEnter := xProperty
      ELSEIF ::aProp[i, 1] == "exstyle"
         nStyle := xProperty
      ELSEIF ::aProp[i, 1] == "modal"
         lModal := xProperty
      ELSEIF ::aProp[i, 1] == "formtype"
         IF nMode == NIL
            lMdi := AT("mdimain", Lower(xProperty)) > 0
            lMdiChild := AT("mdichild", Lower(xProperty)) > 0
            nMode := if(left(xProperty, 3) == "dlg", 2, 1)
         ENDIF
      ELSEIF ::aProp[i, 1] == "variables"
         FOR j := 1 TO Len(xProperty)
            __mvPrivate(xProperty[j])
         NEXT
      // Styles below
      ELSEIF ::aProp[i, 1] == "systemMenu"
         IF !xProperty 
            nStyle := hwg_bitandinverse(nStyle, WS_SYSMENU)
         ENDIF
      ELSEIF ::aProp[i, 1] == "minimizebox"
         IF xProperty 
            nStyle += WS_MINIMIZEBOX
         ENDIF
      ELSEIF ::aProp[i, 1] == "maximizebox"
         IF xProperty 
            nStyle += WS_MAXIMIZEBOX
         ENDIF
      ELSEIF ::aProp[i, 1] == "absalignent"
         IF !xProperty 
            nStyle := hwg_bitandinverse(nStyle, DS_ABSALIGN)
         ENDIF
      ELSEIF ::aProp[i, 1] == "sizeBox"
         IF !xProperty 
            nStyle := hwg_bitandinverse(nStyle, WS_SIZEBOX)
         ENDIF
      ELSEIF ::aProp[i, 1] == "visible"
         IF !xProperty 
            nStyle := hwg_bitandinverse(nStyle, WS_VISIBLE)
         ENDIF
      ELSEIF ::aProp[i, 1] == "3dLook"
         IF xProperty 
            nStyle += DS_3DLOOK
         ENDIF
      ELSEIF ::aProp[i, 1] == "clipsiblings"
         IF xProperty
            nStyle += WS_CLIPSIBLINGS
         ENDIF
      ELSEIF ::aProp[i, 1] == "clipchildren"
         IF xProperty
            nStyle += WS_CLIPCHILDREN
         ENDIF
      ELSEIF ::aProp[i, 1] == "fromstyle"
         IF Lower(xProperty) == "popup"
            nStyle += WS_POPUP + WS_CAPTION
         ELSEIF Lower(xProperty) == "child"
            nStyle += WS_CHILD
         ENDIF

      ELSEIF ::aProp[i, 1] == "bitmap"
         cBitmap := xProperty
      ENDIF
   NEXT

   FOR i := 1 TO Len(::aNames)
      __mvPrivate(::aNames[i])
   NEXT
   FOR i := 1 TO Len(::aVars)
      __mvPrivate(::aVars[i])
   NEXT


   oBmp := IIf(!Empty(cBitmap), HBitmap():addfile(cBitmap, NIL), NIL)

   IF nMode == NIL .OR. nMode == 2
      INIT DIALOG ::oDlg TITLE cTitle         ;
          AT nLeft, nTop SIZE nWidth, nHeight ;
          STYLE nStyle ;
          FONT oFont ;
          BACKGROUND BITMAP oBmp
      ::oDlg:lClipper := lClipper
      ::oDlg:lExitOnEnter := lExitOnEnter
      ::oDlg:oParent  := Self

   ELSEIF nMode == 1

#ifndef __LINUX__
      IF lMdi
         INIT WINDOW ::oDlg MDI TITLE cTitle    ;
         AT nLeft, nTop SIZE nWidth, nHeight ;
         STYLE IIF(nStyle > 0, nStyle, NIL) ;
         FONT oFont;
         BACKGROUND BITMAP oBmp
      ELSEIF lMdiChild
         INIT WINDOW ::oDlg  MDICHILD TITLE cTitle    ;
         AT nLeft, nTop SIZE nWidth, nHeight ;
         STYLE IIf(nStyle > 0, nStyle, NIL) ;
         FONT oFont ;
         BACKGROUND BITMAP oBmp
      ELSE
#endif
      INIT WINDOW ::oDlg MAIN TITLE cTitle    ;
          AT nLeft, nTop SIZE nWidth, nHeight ;
          FONT oFont;
          BACKGROUND BITMAP oBmp;
          STYLE IIf(nStyle > 0, nStyle, NIL)
#ifndef __LINUX__
      ENDIF
#endif
   ENDIF

   oDlg := ::oDlg

   FOR i := 1 TO Len(::aMethods)
      IF (cType := ValType(::aMethods[i, 2])) == "B"
         block := ::aMethods[i, 2]
      ELSEIF cType == "A"
         block := ::aMethods[i, 2, 1]
      ENDIF
      IF ::aMethods[i, 1] == "ondlginit"
         ::oDlg:bInit := block
      ELSEIF ::aMethods[i, 1] == "onforminit"
         Eval(block, Self, p1, p2, p3)
      ELSEIF ::aMethods[i, 1] == "onpaint"
         ::oDlg:bPaint := block
      ELSEIF ::aMethods[i, 1] == "ondlgexit"
         ::oDlg:bDestroy := block
      ELSEIF ::aMethods[i, 1] == "onformexit"
         bFormExit := block
      ENDIF
   NEXT

   j := Len(::aControls)
   IF j > 0 .AND. ::aControls[j]:cClass == "status"
      CreateCtrl(::oDlg, ::aControls[j], Self)
      j--
   ENDIF
      
   FOR i := 1 TO j
      CreateCtrl(::oDlg, ::aControls[i], Self)
   NEXT

   ::oDlg:Activate(lModal)

   IF bFormExit != NIL
      RETURN Eval(bFormExit)
   ENDIF

RETURN NIL

METHOD F(id, n) CLASS HFormTmpl
Local i := AScan(::aForms, {|o|o:id == id})

   IF i != 0 .AND. n != NIL
      RETURN ::aForms[i]:aControls[n]
   ENDIF
RETURN IIf(i == 0, NIL, ::aForms[i])

METHOD Find(cId) CLASS HFormTmpl
Local i := AScan(::aForms, {|o|o:cId != NIL .AND. o:cId == cId})
RETURN IIf(i == 0, NIL, ::aForms[i])

METHOD Close() CLASS HFormTmpl
Local i := AScan(::aForms, {|o|o:id == ::id})

   IF i != 0
      ADel(::aForms, i)
      ASize(::aForms, Len(::aForms) - 1)
   ENDIF
RETURN NIL

// ------------------------------

STATIC FUNCTION ReadTree(oForm, aParent, oDesc)
Local i, aTree := {}, oNode, subarr

   FOR i := 1 TO Len(oDesc:aItems)
      oNode := oDesc:aItems[i]
      IF oNode:type == HBXML_TYPE_CDATA
         aParent[1] := CompileMethod(oNode:aItems[1], oForm)
      ELSE
         AAdd(aTree, {NIL, oNode:GetAttribute("name"), Val(oNode:GetAttribute("id")), .T.})
         IF !Empty(oNode:aItems)
            IF (subarr := ReadTree(oForm, ATail(aTree), oNode)) != NIL
               aTree[Len(aTree), 1] := subarr
            ENDIF
         ENDIF
      ENDIF
   NEXT

RETURN IIf(Empty(aTree), NIL, aTree)

FUNCTION hwg_ParseMethod(cMethod)
Local arr := {}, nPos1, nPos2, cLine

   IF (nPos1 := At(Chr(10), cMethod)) == 0
      AAdd(arr, AllTrim(cMethod))
   ELSE
      AAdd(arr, AllTrim(Left(cMethod, nPos1 - 1)))
      DO WHILE .T.
         IF (nPos2 := hb_At(Chr(10), cMethod, nPos1 + 1)) == 0
            cLine := AllTrim(SubStr(cMethod, nPos1 + 1))
         ELSE
            cLine := AllTrim(SubStr(cMethod, nPos1 + 1, nPos2 - nPos1 - 1))
         ENDIF
         IF !Empty(cLine)
            AAdd(arr, cLine)
         ENDIF
         IF nPos2 == 0 .OR. Len(arr) > 2
            EXIT
         ELSE
            nPos1 := nPos2
         ENDIF
      ENDDO
   ENDIF
   IF Right(arr[1], 1) < " "
      arr[1] := Left(arr[1], Len(arr[1]) - 1)
   ENDIF
   IF Len(arr) > 1 .AND. Right(arr[2], 1) < " "
      arr[2] := Left(arr[2], Len(arr[2]) - 1)
   ENDIF

RETURN arr

STATIC FUNCTION CompileMethod(cMethod, oForm, oCtrl)
Local arr, arrExe, nContainer := 0, cCode1, cCode, bOldError, bRes

   IF cMethod == NIL .OR. Empty(cMethod)
      RETURN NIL
   ENDIF
   IF oCtrl != NIL .AND. Left(oCtrl:oParent:Classname(), 2) == "HC"
      // writelog(oCtrl:cClass + " " + oCtrl:oParent:cClass + " " + oCtrl:oParent:oParent:Classname())
      nContainer := oForm:nContainer
   ENDIF
   arr := hwg_ParseMethod(cMethod)
   IF Len(arr) == 1
      cCode := IIf(Lower(Left(arr[1], 6)) == "return", LTrim(SubStr(arr[1], 8)), arr[1])
      bOldError := ERRORBLOCK({|e|CompileErr(e, cCode)})
      BEGIN SEQUENCE
         bRes := &("{||" + __Preprocess(cCode) + "}")
      END SEQUENCE
      ERRORBLOCK(bOldError)
      RETURN bRes
   ELSEIF Lower(Left(arr[1], 11)) == "parameters "
      IF Len(arr) == 2
         cCode := IIf(Lower(Left(arr[2], 6)) == "return", LTrim(SubStr(arr[2], 8)), arr[2])
         cCode := "{|" + LTrim(SubStr(arr[1], 12)) + "|" + __Preprocess(cCode) + "}"
         bOldError := ERRORBLOCK({|e|CompileErr(e, cCode)})
         BEGIN SEQUENCE
            bRes := &cCode
         END SEQUENCE
         ERRORBLOCK(bOldError)
         RETURN bRes
      ELSE
         cCode1 := IIf(nContainer == 0, ;
               "aControls[" + LTrim(Str(Len(oForm:aControls))) + "]", ;
               "F(" + LTrim(Str(oCtrl:nId)) + ")")
         arrExe := Array(2)
         arrExe[2] := hwg_RdScript(, cMethod, 1, .T.)
         cCode :=  "{|" + LTrim(SubStr(arr[1], 12)) + ;
            "|hwg_DoScript(HFormTmpl():F(" + LTrim(Str(oForm:id)) + IIf(nContainer != 0, "," + LTrim(Str(nContainer)), "") + "):" + ;
            IIf(oCtrl == NIL, "aMethods[" + LTrim(Str(Len(oForm:aMethods) + 1)) + ",2,2],{", ;
                   cCode1 + ":aMethods[" + ;
                   LTrim(Str(Len(oCtrl:aMethods) + 1)) + ",2,2],{") + ;
                   LTrim(SubStr(arr[1], 12)) + "})" + "}"
         arrExe[1] := &cCode
         RETURN arrExe
      ENDIF
   ENDIF

   cCode1 := IIf(nContainer == 0, ;
         "aControls[" + LTrim(Str(Len(oForm:aControls))) + "]", ;
         "F(" + LTrim(Str(oCtrl:nId)) + ")")
   arrExe := Array(2)
   arrExe[2] := hwg_RdScript(, cMethod,, .T.)
   cCode :=  "{||hwg_DoScript(HFormTmpl():F(" + LTrim(Str(oForm:id)) + IIf(nContainer != 0, "," + LTrim(Str(nContainer)), "") + "):" + ;
      IIf(oCtrl == NIL, "aMethods[" + LTrim(Str(Len(oForm:aMethods) + 1)) + ",2,2])", ;
             cCode1 + ":aMethods[" + ;
             LTrim(Str(Len(oCtrl:aMethods) + 1)) + ",2,2])") + "}"
   arrExe[1] := &cCode

RETURN arrExe

//STATIC FUNCTION CompileErr(e, stroka)
STATIC PROCEDURE CompileErr(e, stroka)

   //LOCAL n // variable not used

   hwg_MsgStop(hwg_ErrorMessage(e) + Chr(10)+Chr(13) + "in" + Chr(10)+Chr(13) + ;
          AllTrim(stroka), "Script compiling error")
   BREAK
//RETURN .T. // unreachable code

STATIC FUNCTION ReadCtrl(oCtrlDesc, oContainer, oForm)
Local oCtrl := HCtrlTmpl():New(oContainer)
Local i, j, o, cName, aProp := {}, aMethods := {}, aItems := oCtrlDesc:aItems

   oCtrl:nId      := oForm:nCtrlId
   oForm:nCtrlId ++
   oCtrl:cClass   := oCtrlDesc:GetAttribute("class")
   oCtrl:aProp    := aProp
   oCtrl:aMethods := aMethods

   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               IF (cName := Lower(o:GetAttribute("name"))) == "varname"
                  AAdd(oForm:aVars, hfrm_GetProperty(o:aItems[1]))
               ELSEIF cName == "name"
                  AAdd(oForm:aNames, hfrm_GetProperty(o:aItems[1]))
               ENDIF
               IF cName == "atree"
                  AAdd(aProp, {cName, ReadTree(oForm, , o)})
               ELSE
                  AAdd(aProp, {cName, IIf(Empty(o:aItems), "", o:aItems[1])})
               ENDIF
            ENDIF
         NEXT
      ELSEIF aItems[i]:title == "method"
         AAdd(aMethods, {Lower(aItems[i]:GetAttribute("name")), CompileMethod(aItems[i]:aItems[1]:aItems[1], oForm, oCtrl)})
      ELSEIF aItems[i]:title == "part"
         ReadCtrl(aItems[i], oCtrl, oForm)
      ENDIF
   NEXT

RETURN NIL

//#define TBS_AUTOTICKS                1 // defined in windows.ch
//#define TBS_TOP                      4 // defined in windows.ch
//#define TBS_BOTH                     8 // defined in windows.ch
//#define TBS_NOTICKS                 16 // defined in windows.ch

STATIC FUNCTION CreateCtrl(oParent, oCtrlTmpl, oForm)

   LOCAL i
   LOCAL j
   LOCAL oCtrl
   LOCAL stroka
   LOCAL varname
   LOCAL xProperty
   //LOCAL block // variable not used
   LOCAL cType
   LOCAL cPName
   LOCAL nCtrl := AScan(s_aClass, oCtrlTmpl:cClass)
   LOCAL xInitValue
   LOCAL cInitName
   LOCAL cVarName

MEMVAR oPrnt, nId, nInitValue, cInitValue, dInitValue, nStyle, nLeft, nTop
MEMVAR onInit, onSize, onPaint, onEnter, onGetfocus, onLostfocus, lNoVScroll, lAppend, lAutoedit, bUpdate, onKeyDown, onPosChg
MEMVAR nWidth, nHeight, oFont, lNoBorder, bSetGet
MEMVAR name, nMaxLines, nLength, lVertical, brwType, TickStyle, TickMarks, Tabs, tmp_nSheet
MEMVAR aImages, lEditLabels, aParts

   IF nCtrl == 0
      IF Lower(oCtrlTmpl:cClass) == "pagesheet"
         tmp_nSheet ++
         oParent:StartPage(Tabs[tmp_nSheet])
         FOR i := 1 TO Len(oCtrlTmpl:aControls)
            CreateCtrl(oParent, oCtrlTmpl:aControls[i], oForm)
         NEXT
         oParent:EndPage()
      ENDIF
      RETURN NIL
   ENDIF

   /* Declaring of variables, which are in the appropriate 'New()' function */
   stroka := s_aCtrls[nCtrl]
   IF (i := At("New(", stroka)) != 0
      i += 4
      DO WHILE .T.
         IF (j := hb_At(",", stroka, i)) != 0 .OR. (j := hb_At(")", stroka, i)) != 0
            IF j - i > 0
               varname := SubStr(stroka, i, j - i)
               __mvPrivate(varname)
               IF SubStr(varname, 2) == "InitValue"
                  cInitName  := varname
                  xInitValue := IIf(Left(varname, 1) == "n", 1, IIf(Left(varname, 1) == "c", "", .F.))
               ENDIF
               stroka := Left(stroka, i - 1) + "m->" + SubStr(stroka, i)
               i := j + 4
            ELSE
               i := j + 1
            ENDIF
         ELSE
            EXIT
         ENDIF
      ENDDO
   ENDIF
   oPrnt  := oParent
   nId    := oCtrlTmpl:nId
   nStyle := 0

   FOR i := 1 TO Len(oCtrlTmpl:aProp)
      xProperty := hfrm_GetProperty(oCtrlTmpl:aProp[i, 2])
      cPName := oCtrlTmpl:aProp[i, 1]
      IF cPName == "geometry"
         nLeft   := Val(xProperty[1])
         nTop    := Val(xProperty[2])
         nWidth  := Val(xProperty[3])
         nHeight := Val(xProperty[4])
         IF __ObjHasMsg(oParent, "ID")
            nLeft -= oParent:nLeft
            nTop -= oParent:nTop
            IF __ObjHasMsg(oParent:oParent, "ID")
               nLeft -= oParent:oParent:nLeft
               nTop -= oParent:oParent:nTop
            ENDIF
         ENDIF
      ELSEIF cPName == "font"
         oFont := hfrm_FontFromxml(xProperty)
      ELSEIF cPName == "border"
         IF xProperty
            nStyle += WS_BORDER
         ELSE
            lNoBorder := .T.
         ENDIF
      ELSEIF cPName == "justify"
         nStyle += IIf(xProperty == "Center", SS_CENTER, IIf(xProperty == "Right", SS_RIGHT, 0))
      ELSEIF cPName == "multiline"
         IF xProperty
            nStyle += ES_MULTILINE
         ENDIF
      ELSEIF cPName == "password"
         IF xProperty
            nStyle += ES_PASSWORD
         ENDIF
      ELSEIF cPName == "autohscroll"
         IF xProperty
            nStyle += ES_AUTOHSCROLL
         ENDIF
      ELSEIF cPName == "autovscroll"
         IF xProperty
            nStyle += ES_AUTOVSCROLL
         ENDIF
      ELSEIF cPName == "3dlook"
         IF xProperty
            nStyle += DS_3DLOOK
         ENDIF

      ELSEIF cPName == "atree"
         hwg_BuildMenu(xProperty, oForm:oDlg:handle, oForm:oDlg)
      ELSE
        IF cPName == "tooltip"
            cPName := "c" + cPName
        ELSEIF cPName == "name"
           __mvPrivate(cPName)
        ENDIF
         /* Assigning the value of the property to the variable with
            the same name as the property */
         __mvPut(cPName, xProperty)

         IF cPName == "varname"
            cVarName := xProperty
            bSetGet := &("{|v|Iif(v==NIL," + xProperty + "," + xProperty + ":=v)}")
            IF __mvGet(xProperty) == NIL
               /* If the variable with 'varname' name isn't initialized
                  while onFormInit procedure, we assign her the init value */
               __mvPut(xProperty, xInitValue)
            ELSEIF cInitName != NIL
               /* If it is initialized, we assign her value to the 'init'
                  variable ( cInitValue, nInitValue, ... ) */
               __mvPut(cInitName, __mvGet(xProperty))
            ENDIF
         ELSEIF SubStr(cPName, 2) == "initvalue"
            xInitValue := xProperty
         ENDIF
      ENDIF
   NEXT
   FOR i := 1 TO Len(oCtrlTmpl:aMethods)
      IF (cType := ValType(oCtrlTmpl:aMethods[i, 2])) == "B"
         __mvPut(oCtrlTmpl:aMethods[i, 1], oCtrlTmpl:aMethods[i, 2])
      ELSEIF cType == "A"
         __mvPut(oCtrlTmpl:aMethods[i, 1], oCtrlTmpl:aMethods[i, 2, 1])
      ENDIF
   NEXT

   IF oCtrlTmpl:cClass == "combobox"
#ifndef __LINUX__
      IF (i := AScan(oCtrlTmpl:aProp, {|a|Lower(a[1]) == "nmaxlines"})) > 0
         HB_SYMBOL_UNUSED(i)
         nHeight := nHeight * nMaxLines
      ELSE
         nHeight := nHeight * 4
      ENDIF
#endif
   ELSEIF oCtrlTmpl:cClass == "line"
      nLength := IIf(lVertical == NIL .OR. !lVertical, nWidth, nHeight)
   ELSEIF oCtrlTmpl:cClass == "browse"
      brwType := IIf(brwType == NIL .OR. brwType == "Dbf", BRW_DATABASE, BRW_ARRAY)
   ELSEIF oCtrlTmpl:cClass == "trackbar"
      IF TickStyle == NIL .OR. TickStyle == "Auto"
         TickStyle := TBS_AUTOTICKS
      ELSEIF TickStyle == "None"
         TickStyle := TBS_NOTICKS
      ELSE
         TickStyle := 0
      ENDIF
      IF TickMarks == NIL .OR. TickMarks == "Bottom"
         TickMarks := 0
      ELSEIF TickMarks == "Both"
         TickMarks := TBS_BOTH
      ELSE
         TickMarks := TBS_TOP
      ENDIF
   ELSEIF oCtrlTmpl:cClass == "status"
      IF aParts != NIL
         FOR i := 1 TO Len(aParts)
            aParts[i] := Val(aParts[i])
         NEXT
      ENDIF
      onInit := {|o|o:Move(,, o:nWidth - 1)}
   ENDIF
   oCtrl := &stroka
   IF cVarName != NIL
      oCtrl:cargo := cVarName
   ENDIF
   IF Type("m->name") == "C"
      // writelog(oCtrlTmpl:cClass + " " + name)
      __mvPut(name, oCtrl)
      name := NIL
   ENDIF
   IF !Empty(oCtrlTmpl:aControls)
      IF oCtrlTmpl:cClass == "page"
         __mvPrivate("tmp_nSheet")
         __mvPut("tmp_nSheet", 0)
      ENDIF
      FOR i := 1 TO Len(oCtrlTmpl:aControls)
         CreateCtrl(IIf(oCtrlTmpl:cClass == "group" .OR. oCtrlTmpl:cClass == "radiogroup", oParent, oCtrl), oCtrlTmpl:aControls[i], oForm)
      NEXT
      IF oCtrlTmpl:cClass == "radiogroup"
         HRadioGroup():EndGroup()
      ENDIF
   ENDIF

RETURN NIL

FUNCTION hwg_RadioNew(oPrnt, nId, nStyle, nLeft, nTop, nWidth, nHeight, caption, oFont, onInit, onSize, onPaint, TextColor, BackColor, nInitValue, bSetGet)
Local oCtrl := HGroup():New(oPrnt, nId, nStyle, nLeft, nTop, nWidth, nHeight, caption, oFont, onInit, onSize, onPaint, TextColor, BackColor)
   HRadioGroup():New(nInitValue, bSetGet)
RETURN oCtrl


FUNCTION hwg_Font2XML(oFont)
Local aAttr := {}

   AAdd(aAttr, {"name", oFont:name})
   AAdd(aAttr, {"width", LTrim(Str(oFont:width, 5))})
   AAdd(aAttr, {"height", LTrim(Str(oFont:height, 5))})
   IF oFont:weight != 0
      AAdd(aAttr, {"weight", LTrim(Str(oFont:weight, 5))})
   ENDIF
   IF oFont:charset != 0
      AAdd(aAttr, {"charset", LTrim(Str(oFont:charset, 5))})
   ENDIF
   IF oFont:Italic != 0
      AAdd(aAttr, {"italic", LTrim(Str(oFont:Italic, 5))})
   ENDIF
   IF oFont:Underline != 0
      AAdd(aAttr, {"underline", LTrim(Str(oFont:Underline, 5))})
   ENDIF

RETURN HXMLNode():New("font", HBXML_TYPE_SINGLE, aAttr)

FUNCTION hfrm_FontFromXML(oXmlNode)
Local width  := oXmlNode:GetAttribute("width")
Local height := oXmlNode:GetAttribute("height")
Local weight := oXmlNode:GetAttribute("weight")
Local charset := oXmlNode:GetAttribute("charset")
Local ita   := oXmlNode:GetAttribute("italic")
Local under := oXmlNode:GetAttribute("underline")

  IF width != NIL
     width := Val(width)
  ENDIF
  IF height != NIL
     height := Val(height)
  ENDIF
  IF weight != NIL
     weight := Val(weight)
  ENDIF
  IF charset != NIL
     charset := Val(charset)
  ENDIF
  IF ita != NIL
     ita := Val(ita)
  ENDIF
  IF under != NIL
     under := Val(under)
  ENDIF

RETURN HFont():Add(oXmlNode:GetAttribute("name"), width, height, weight, charset, ita, under)

FUNCTION hfrm_Str2Arr(stroka)
Local arr := {}, pos1 := 2, pos2 := 1

   IF Len(stroka) > 2
      DO WHILE pos2 > 0
         DO WHILE SubStr(stroka, pos1, 1) <= " "
            pos1++
         ENDDO
         pos2 := hb_At(",", stroka, pos1)
         AAdd(arr, Trim(SubStr(stroka, pos1, IIf(pos2 > 0, pos2 - pos1, hb_At("}", stroka, pos1) - pos1))))
         pos1 := pos2 + 1
      ENDDO
   ENDIF

RETURN arr

FUNCTION hfrm_Arr2Str(arr)
Local stroka := "{", i, cType

   FOR i := 1 TO Len(arr)
      IF i > 1
         stroka += ","
      ENDIF
      cType := ValType(arr[i])
      IF cType == "C"
         stroka += arr[i]
      ELSEIF cType == "N"
         stroka += LTrim(Str(arr[i]))
      ENDIF
   NEXT

RETURN stroka + "}"

FUNCTION hfrm_GetProperty(xProp)
Local c

   IF HB_IsChar(xProp)
      c := Left(xProp, 1)
      IF c == "["
         xProp := SubStr(xProp, 2, Len(xProp) - 2)
      ELSEIF c == "."
         xProp := (SubStr(xProp, 2, 1) == "T")
      ELSEIF c == "{"
         xProp := hfrm_Str2Arr(xProp)
      ELSE
         xProp := Val(xProp)
      ENDIF
   ENDIF

RETURN xProp

// ---------------------------------------------------- //

CLASS HRepItem

   DATA cClass
   DATA oParent
   DATA aControls INIT {}
   DATA aProp, aMethods
   DATA oPen, obj
   DATA lPen INIT .F.
   DATA y2
   DATA lMark INIT .F.

   METHOD New(oParent) INLINE (::oParent := oParent, AAdd(oParent:aControls, Self), Self)
ENDCLASS

CLASS HRepTmpl

   CLASS VAR aReports INIT {}
   CLASS VAR maxId    INIT 0
   CLASS VAR aFontTable
   DATA aControls     INIT {}
   DATA aProp
   DATA aMethods
   DATA aVars         INIT {}
   DATA aFuncs
   DATA id
   DATA cId

   DATA nKoefX, nKoefY, nKoefPix
   DATA nTOffset, nAOffSet, ny
   DATA lNextPage, lFinish
   DATA oPrinter

   METHOD Read(fname, cId)
   METHOD Print(printer, lPreview, p1, p2, p3)
   METHOD PrintItem(oItem)
   METHOD ReleaseObj(aControls)
   METHOD Find(cId)
   METHOD Close()

ENDCLASS

METHOD Read(fname, cId) CLASS HRepTmpl
Local oDoc
Local i, j, aItems, o, aProp := {}, aMethods := {}
Local cPre

   IF cId != NIL .AND. (o := HRepTmpl():Find(cId)) != NIL
      RETURN o
   ENDIF

   IF Left(fname, 5) == "<?xml"
      oDoc := HXMLDoc():ReadString(fname)
   ELSE
      oDoc := HXMLDoc():Read(fname)
   ENDIF

   IF Empty(oDoc:aItems)
      hwg_MsgStop("Can't open " + fname)
      RETURN NIL
   ELSEIF oDoc:aItems[1]:title != "part" .OR. oDoc:aItems[1]:GetAttribute("class") != "report"
      hwg_MsgStop("Report description isn't found")
      RETURN NIL
   ENDIF

   ::maxId ++
   ::id := ::maxId
   ::cId := cId
   ::aProp := aProp
   ::aMethods := aMethods

   __pp_init()
   AAdd(::aReports, Self)
   aItems := oDoc:aItems[1]:aItems
   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               IF !Empty(o:aItems)
                  AAdd(aProp, {Lower(o:GetAttribute("name")), hfrm_GetProperty(o:aItems[1])})
               ENDIF
            ENDIF
         NEXT
      ELSEIF aItems[i]:title == "method"
         AAdd(aMethods, {Lower(aItems[i]:GetAttribute("name")), hwg_RdScript(, aItems[i]:aItems[1]:aItems[1], , .T.)})
         IF aMethods[(j := Len(aMethods)), 1] == "common"
            ::aFuncs := ::aMethods[j, 2]
            FOR j := 1 TO Len(::aFuncs[2])
               cPre := "#xtranslate " + ::aFuncs[2, j, 1] + ;
                     "( <params,...> ) => hwg_callfunc('"  + ;
                     Upper(::aFuncs[2, j, 1]) + "',\{ <params> \}, oReport:aFuncs )"
               __Preprocess(cPre)
               cPre := "#xtranslate " + ::aFuncs[2, j, 1] + ;
                     "() => hwg_callfunc('"  + ;
                     Upper(::aFuncs[2, j, 1]) + "',, oReport:aFuncs )"
               __Preprocess(cPre)
            NEXT
         ENDIF
      ELSEIF aItems[i]:title == "part"
         ReadRepItem(aItems[i], Self)
      ENDIF
   NEXT
   __pp_free()

RETURN Self

METHOD Print(printer, lPreview, p1, p2, p3) CLASS HRepTmpl
Local oPrinter := IIf(printer != NIL, IIf(HB_IsObject(printer), printer, HPrinter():New(printer, .T.)), HPrinter():New(, .T.))
Local i, j, aMethod, xProperty, oFont, xTemp, nPWidth, nPHeight, nOrientation := 1
Memvar oReport
Private oReport := Self

   IF oPrinter == NIL
      RETURN NIL
   ENDIF
   FOR i := 1 TO Len(::aProp)
      IF ::aProp[i, 1] == "paper size"
         IF Lower(::aProp[i, 2]) == "a4"
            nPWidth  := 210
            nPHeight := 297
         ELSEIF Lower(::aProp[i, 2]) == "a3"
            nPWidth  := 297
            nPHeight := 420
         ENDIF
      ELSEIF ::aProp[i, 1] == "orientation"
         IF Lower(::aProp[i, 2]) != "portrait"
            xTemp    := nPWidth
            nPWidth  := nPHeight
            nPHeight := xTemp
            nOrientation := 2
         ENDIF
      ELSEIF ::aProp[i, 1] == "font"
         xProperty := ::aProp[i, 2]
      ELSEIF ::aProp[i, 1] == "variables"
         FOR j := 1 TO Len(::aProp[i, 2])
            __mvPrivate(::aProp[i, 2][j])
         NEXT
      ENDIF
   NEXT
#ifdef __LINUX__
   xTemp := hwg_gp_GetDeviceArea(oPrinter:hDC)
#else
   xTemp := hwg_GetDeviceArea(oPrinter:hDCPrn)
#endif
   ::nKoefPix := ((xTemp[1] / xTemp[3] + xTemp[2] / xTemp[4]) / 2) / 3.8
   oPrinter:SetMode(nOrientation)
   ::nKoefX := oPrinter:nWidth / nPWidth
   ::nKoefY := oPrinter:nHeight / nPHeight
   IF (aMethod := aGetSecond(::aMethods, "onrepinit")) != NIL
      hwg_DoScript(aMethod, {p1, p2, p3})
   ENDIF
   IF xProperty != NIL
      oFont := hrep_FontFromxml(oPrinter, xProperty, aGetSecond(::aProp, "fonth") * ::nKoefY)
   ENDIF

   oPrinter:StartDoc(lPreview) // ,"/tmp/a1.ps")
   ::lNextPage := .F.

   ::lFinish := .T.
   ::oPrinter := oPrinter
   DO WHILE .T.

      oPrinter:StartPage()
      IF oFont != NIL
         oPrinter:SetFont(oFont)
      ENDIF
      ::nTOffset := ::nAOffSet := ::ny := 0
      // Writelog("Print-1 " + str(oPrinter:nPage))
      FOR i := 1 TO Len(::aControls)
         ::PrintItem(::aControls[i])
      NEXT
      oPrinter:EndPage()
      IF ::lFinish
         EXIT
      ENDIF
   ENDDO

   oPrinter:EndDoc()
   ::ReleaseObj(::aControls)
   IF oFont != NIL
      oFont:Release()
   ENDIF
   IF (aMethod := aGetSecond(::aMethods, "onrepexit")) != NIL
      hwg_DoScript(aMethod)
   ENDIF
   IF lPreview != NIL .AND. lPreview
      oPrinter:Preview()
   ENDIF
   oPrinter:End()

RETURN NIL

METHOD PrintItem(oItem) CLASS HRepTmpl
Local aMethod, lRes := .T., i, nPenType, nPenWidth
Local x, y, x2, y2, cText, nJustify, xProperty, nLines, dy, nFirst, ny
Memvar lLastCycle, lSkipItem

   IF oItem:cClass == "area"
      cText := aGetSecond(oItem:aProp, "areatype")
      IF cText == "DocHeader"
         IF ::oPrinter:nPage > 1
            ::nAOffSet := Val(aGetSecond(oItem:aProp, "geometry")[4]) * ::nKoefY
            RETURN NIL
         ENDIF
      ELSEIF cText == "DocFooter"
         IF ::lNextPage
            RETURN NIL
         ENDIF
      ELSEIF cText == "Table" .AND. ::lNextPage
         Private lSkipItem := .T.
      ENDIF
   ENDIF
   IF !__mvExist("LSKIPITEM") .OR. !lSkipItem
      IF (aMethod := aGetSecond(oItem:aMethods, "onbegin")) != NIL
         hwg_DoScript(aMethod)
      ENDIF
      IF (aMethod := aGetSecond(oItem:aMethods, "condition")) != NIL
         lRes := hwg_DoScript(aMethod)
         IF !lRes .AND. oItem:cClass == "area"
            ::nAOffSet += Val(aGetSecond(oItem:aProp, "geometry")[4]) * ::nKoefY
         ENDIF
      ENDIF
   ENDIF
   IF lRes
      xProperty := aGetSecond(oItem:aProp, "geometry")
      x   := Val(xProperty[1]) * ::nKoefX
      y   := Val(xProperty[2]) * ::nKoefY
      x2  := Val(xProperty[5]) * ::nKoefX
      y2  := Val(xProperty[6]) * ::nKoefY
      // writelog(xProperty[1] + " " + xProperty[2])

      IF oItem:cClass == "area"
         oItem:y2 := y2
         // writelog("Area: " + cText + " " + IIf(::lNextPage, "T", "F"))
         IF (xProperty := aGetSecond(oItem:aProp, "varoffset")) == NIL ;
                .OR. !xProperty
            ::nTOffset := ::nAOffSet := 0
         ENDIF
         IF cText == "Table"
            Private lLastCycle := .F.
            ::lFinish := .F.
            DO WHILE !lLastCycle
               ::ny := 0
               FOR i := 1 TO Len(oItem:aControls)
                  IF !::lNextPage .OR. oItem:aControls[i]:lMark
                     oItem:aControls[i]:lMark := ::lNextPage := .F.
                     IF __mvExist("LSKIPITEM")
                        lSkipItem := .F.
                     ENDIF
                     ::PrintItem(oItem:aControls[i])
                     IF ::lNextPage
                        RETURN NIL
                     ENDIF
                  ENDIF
               NEXT
               IF ::lNextPage
                  EXIT
               ELSE
                  ::nTOffset := ::ny - y
                  IF (aMethod := aGetSecond(oItem:aMethods, "onnextline")) != NIL
                     hwg_DoScript(aMethod)
                  ENDIF
               ENDIF
            ENDDO
            IF lLastCycle
               // writelog("--> " + str(::nAOffSet) + str(y2 - y + 1 - (::ny - y)))
               ::nAOffSet += y2 - y + 1 - (::ny - y)
               ::nTOffset := 0
               ::lFinish := .T.
            ENDIF
         ELSE
            FOR i := 1 TO Len(oItem:aControls)
               ::PrintItem(oItem:aControls[i])
            NEXT
         ENDIF
         lRes := .F.
      ENDIF
   ENDIF

   IF lRes

      y  -= ::nAOffSet
      y2 -= ::nAOffSet
      IF ::nTOffset > 0
         y  += ::nTOffset
         y2 += ::nTOffset
         IF y2 > oItem:oParent:y2
            oItem:lMark := .T.
            ::lNextPage := .T.
            ::nTOffset := ::nAOffSet := 0
            // writelog("::lNextPage := .T. " + oItem:cClass)
            RETURN NIL
         ENDIF
      ENDIF

      IF oItem:lPen .AND. oItem:oPen == NIL
         IF (xProperty := aGetSecond(oItem:aProp, "pentype")) != NIL
            nPenType := AScan(s_aPenType, xProperty) - 1
         ELSE
            nPenType := 0
         ENDIF
         IF (xProperty := aGetSecond(oItem:aProp, "penwidth")) != NIL
            nPenWidth := Round(xProperty * ::nKoefPix, 0)
         ELSE
            nPenWidth := Round(::nKoefPix, 0)
         ENDIF
#ifdef __LINUX__
         oItem:oPen := HGP_Pen():Add(nPenWidth)
#else
         oItem:oPen := HPen():Add(nPenType, nPenWidth)
#endif
         // writelog(str(nPenWidth) + " " + str(::nKoefY))
      ENDIF
      IF oItem:cClass == "label"
         IF (aMethod := aGetSecond(oItem:aMethods, "expression")) != NIL
            cText := hwg_DoScript(aMethod)
         ELSE
            cText := aGetSecond(oItem:aProp, "caption")
         ENDIF
         IF HB_IsChar(cText)
            IF (xProperty := aGetSecond(oItem:aProp, "border")) != NIL ;
                   .AND. xProperty
               ::oPrinter:Box(x, y, x2, y2)
               x += 0.5
               y += 0.5
            ENDIF
            IF (xProperty := aGetSecond(oItem:aProp, "justify")) == NIL
               nJustify := 0
            ELSE
               nJustify := AScan(s_aJustify, xProperty) - 1
            ENDIF
            IF oItem:obj == NIL
               IF (xProperty := aGetSecond(oItem:aProp, "font")) != NIL
                  oItem:obj := hrep_FontFromxml(::oPrinter, xProperty, aGetSecond(oItem:aProp, "fonth") * ::nKoefY)
               ENDIF
            ENDIF
            // hwg_SetTransparentMode(::oPrinter:hDC, .T.)
            IF (xProperty := aGetSecond(oItem:aProp, "multiline")) != NIL ;
                   .AND. xProperty
               nLines := i := 1
               DO WHILE (i := hb_At(";", cText, i)) > 0
                  i ++
                  nLines ++
               ENDDO
               dy := (y2 - y) / nLines
               nFirst := i := 1
               ny := y
               DO WHILE (i := hb_At(";", cText, i)) > 0
                  ::oPrinter:Say(SubStr(cText, nFirst, i - nFirst), x, ny, x2, ny + dy, nJustify, oItem:obj)
                  i ++
                  nFirst := i
                  ny += dy
               ENDDO
               ::oPrinter:Say(SubStr(cText, nFirst, Len(cText) - nFirst + 1), x, ny, x2, ny + dy, nJustify, oItem:obj)
            ELSE
               ::oPrinter:Say(cText, x, y, x2, y2, nJustify, oItem:obj)
            ENDIF
            // hwg_SetTransparentMode(::oPrinter:hDC, .F.)
            // Writelog(str(x) + " " + str(y) + " " + str(x2) + " " + str(y2) + " " + str(::nAOffSet) + " " + str(::nTOffSet) + " Say: " + cText)
         ENDIF
      ELSEIF oItem:cClass == "box"
         ::oPrinter:Box(x, y, x2, y2, oItem:oPen)
         // writelog("Draw " + str(x) + " " + str(x + width - 1))
      ELSEIF oItem:cClass == "vline"
         ::oPrinter:Line(x, y, x, y2, oItem:oPen)
      ELSEIF oItem:cClass == "hline"
         ::oPrinter:Line(x, y, x2, y, oItem:oPen)
      ELSEIF oItem:cClass == "bitmap"
/*
         IF oItem:obj == NIL
            oItem:obj := hwg_OpenBitmap(aGetSecond(oItem:aProp, "bitmap"), ::oPrinter:hDC)
         ENDIF
         ::oPrinter:Bitmap(x, y, x2, y2,, oItem:obj)
*/
      ENDIF
      ::ny := Max(::ny, y2 + ::nAOffSet)
   ENDIF

   IF (aMethod := aGetSecond(oItem:aMethods, "onend")) != NIL
      hwg_DoScript(aMethod)
   ENDIF

RETURN NIL

METHOD ReleaseObj(aControls) CLASS HRepTmpl
Local i

   FOR i := 1 TO Len(aControls)
      IF !Empty(aControls[i]:aControls)
         ::ReleaseObj(aControls[i]:aControls)
      ELSE
         IF aControls[i]:obj != NIL
            IF aControls[i]:cClass == "bitmap"
/*
               hwg_DeleteObject(aControls[i]:obj)
*/
               aControls[i]:obj := NIL
            ELSEIF aControls[i]:cClass == "label"
               aControls[i]:obj:Release()
               aControls[i]:obj := NIL
            ENDIF
         ENDIF
         IF aControls[i]:oPen != NIL
            aControls[i]:oPen:Release()
            aControls[i]:oPen := NIL
         ENDIF
      ENDIF
   NEXT

RETURN NIL

METHOD Find(cId) CLASS HRepTmpl
Local i := AScan(::aReports, {|o|o:cId != NIL .AND. o:cId == cId})
RETURN IIf(i == 0, NIL, ::aReports[i])

METHOD Close() CLASS HRepTmpl
Local i := AScan(::aReports, {|o|o:id == ::id})

   IF i != 0
      ADel(::aReports, i)
      ASize(::aReports, Len(::aReports) - 1)
   ENDIF
RETURN NIL

STATIC FUNCTION ReadRepItem(oCtrlDesc, oContainer)

   LOCAL oCtrl := HRepItem():New(oContainer)
   LOCAL i
   LOCAL j
   LOCAL o
   //LOCAL cName // variable not used
   LOCAL aProp := {}
   LOCAL aMethods := {}
   LOCAL aItems := oCtrlDesc:aItems
   LOCAL xProperty
   //LOCAL nPenWidth // variable not used
   //LOCAL nPenType // variable not used

   oCtrl:cClass   := oCtrlDesc:GetAttribute("class")
   oCtrl:aProp    := aProp
   oCtrl:aMethods := aMethods

   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               AAdd(aProp, {Lower(o:GetAttribute("name")), IIf(Empty(o:aItems), "", hfrm_GetProperty(o:aItems[1]))})
            ENDIF
         NEXT
      ELSEIF aItems[i]:title == "method"
         AAdd(aMethods, {Lower(aItems[i]:GetAttribute("name")), hwg_RdScript(, aItems[i]:aItems[1]:aItems[1], , .T.)})
      ELSEIF aItems[i]:title == "part"
         ReadRepItem(aItems[i], IIf(oCtrl:cClass == "area", oCtrl, oContainer))
      ENDIF
   NEXT
   IF oCtrl:cClass $ "box.vline.hline" .OR. (oCtrl:cClass == "label" .AND. ;
      (xProperty := aGetSecond(oCtrl:aProp, "border")) != NIL .AND. xProperty)
      oCtrl:lPen := .T.
   ENDIF

RETURN NIL

STATIC FUNCTION aGetSecond(arr, xFirst)
Local i := AScan(arr, {|a|a[1] == xFirst})

RETURN IIf(i == 0, NIL, arr[i, 2])

STATIC FUNCTION hrep_FontFromXML(oPrinter, oXmlNode, height)
Local weight := oXmlNode:GetAttribute("weight")
Local charset := oXmlNode:GetAttribute("charset")
Local ita   := oXmlNode:GetAttribute("italic")
Local under := oXmlNode:GetAttribute("underline")
Local name  := oXmlNode:GetAttribute("name"), i

  IF HB_IsArray(HRepTmpl():aFontTable)
     IF (i := AScan(HRepTmpl():aFontTable, {|a|Lower(a[1]) == Lower(name)})) != 0
        name := HRepTmpl():aFontTable[i, 2]
     ENDIF
  ENDIF
  weight := IIf(weight != NIL, Val(weight), 400)
  IF charset != NIL
     charset := Val(charset)
  ENDIF
  ita    := IIf(ita != NIL, Val(ita), 0)
  under  := IIf(under != NIL, Val(under), 0)

RETURN oPrinter:AddFont(name, height, (weight > 400), (ita > 0), (under > 0), charset)

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(PARSEMETHOD, HWG_PARSEMETHOD);
HB_FUNC_TRANSLATE(RADIONEW, HWG_RADIONEW);
HB_FUNC_TRANSLATE(FONT2XML, HWG_FONT2XML);
#endif

#pragma ENDDUMP
