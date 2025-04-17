//
// $Id: hformgen.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// Designer
// HFormGen class
//
// Copyright 2004 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <fileio.ch>
#include "windows.ch"
#include <hbclass.ch>
#include "guilib.ch"
#include "hxml.ch"
#include <common.ch>

#include "designer.ch"

#define  LEFT_INDENT   40
#define  TOP_INDENT    30
//NANDO
STATIC oPenDivider, oPenLine
//*-
STATIC aG := {"left", "top", "width", "height", "right", "bottom"}

STATIC aStaticTypes := {{SS_LEFT, "SS_LEFT"}, {SS_CENTER, "SS_CENTER"}, ;
    {SS_RIGHT, "SS_RIGHT"}, {SS_BLACKFRAME, "SS_BLACKFRAME"}, ;
    {SS_GRAYFRAME, "SS_GRAYFRAME"}, {SS_WHITEFRAME, "SS_WHITEFRAME"}, ;
    {SS_BLACKRECT, "SS_BLACKRECT"}, {SS_GRAYRECT, "SS_GRAYRECT"}, ;
    {SS_WHITERECT, "SS_WHITERECT"}, {SS_ETCHEDFRAME, "SS_ETCHEDFRAME"}, ;
    {SS_ETCHEDHORZ, "SS_ETCHEDHORZ"}, {SS_ETCHEDVERT, "SS_ETCHEDVERT"}, ;
    {SS_OWNERDRAW, "SS_OWNERDRAW"}}

STATIC aStyles := {{WS_POPUP, "WS_POPUP"}, {WS_CHILD, "WS_CHILD"}, {WS_VISIBLE, "WS_VISIBLE"}, ;
    {WS_DISABLED, "WS_DISABLED"}, {WS_CLIPSIBLINGS, "WS_CLIPSIBLINGS"}, {WS_BORDER, "WS_BORDER"}, ;
    {WS_DLGFRAME, "WS_DLGFRAME"}, {WS_VSCROLL, "WS_VSCROLL"}, {WS_HSCROLL, "WS_HSCROLL"}, ;
    {WS_SYSMENU, "WS_SYSMENU"}, {WS_THICKFRAME, "WS_THICKFRAME"}, {WS_GROUP, "WS_GROUP"}, ;
    {WS_TABSTOP, "WS_TABSTOP"}, {BS_PUSHBUTTON, "BS_PUSHBUTTON"}, {BS_CHECKBOX, "BS_CHECKBOX"}, ;
    {BS_AUTORADIOBUTTON, "BS_AUTORADIOBUTTON"}, {ES_AUTOHSCROLL, "ES_AUTOHSCROLL"}, ;
    {ES_AUTOVSCROLL, "ES_AUTOVSCROLL"}, {ES_MULTILINE, "ES_MULTILINE"}, {BS_GROUPBOX, "BS_GROUPBOX"}, ;
    {CBS_DROPDOWNLIST, "CBS_DROPDOWNLIST"}, {SS_OWNERDRAW, "SS_OWNERDRAW"}}

CLASS HFormGen INHERIT HObject

   CLASS VAR aForms INIT {}
   CLASS VAR oDlgSelected
   DATA oParent
   DATA cEncoding
   DATA oDlg
   DATA name
   DATA handle
   DATA filename, path
   DATA type  INIT 1
   DATA lGet  INIT .T.
   DATA oCtrlSelected
   DATA lChanged  INIT .F.
   DATA aProp         INIT {}
   DATA aMethods      INIT {}

   DATA nPWidth, nPHeight, nKoeff
   DATA nYOffset      INIT 0
   DATA nXOffset      INIT 0

   METHOD New() CONSTRUCTOR
   METHOD Open() CONSTRUCTOR
   METHOD OpenR() CONSTRUCTOR
   METHOD Save(lAs)
   METHOD CreateDialog(aProp)
   METHOD GetProp(cName)
   METHOD SetProp(xName, xValue)
   METHOD SetPaper(cType, nOrientation)
   METHOD End()

ENDCLASS

METHOD New() CLASS HFormGen

   LOCAL i := 1
   LOCAL name
   LOCAL hDCwindow := hwg_GetDC(hwg_GetActiveWindow())
   LOCAL aTermMetr := hwg_GetDeviceArea(hDCwindow)

   hwg_DeleteDC(hDCwindow)
   DO WHILE .T.
      name := "Form" + LTrim(Str(i))
      IF AScan(::aForms, {|o|o:name == name}) == 0
        Exit
      ENDIF
      i ++
   ENDDO

   ::type := 1
   ::name := name
   //::CreateDialog({{"Left", LTrim(Str(aTermMetr[1] - 500))}, //{"Top", "120"}, {"Width", "500"}, {"Height", "400"}, {"Caption", name}})
   //::CreateDialog({{"Left", "325"}, {"Top", "060"}, {"Width", "498"}, {"Height", "470"}, {"Caption", name}})
   IF hwg_Getdesktopwidth() < 1024
     ::CreateDialog({{"Left", "225"}, {"Top", "110"}, {"Width", "550"}, {"Height", "400"}, {"Caption", name}})
   ELSE
     ::CreateDialog({{"Left", "125"}, {"Top", "150"}, {"Width", "750"}, {"Height", "600"}, {"Caption", name}})
   ENDIF
   ::filename := ""

   AAdd(::aForms, Self)
   // : LFB
   statusbarmsg(name)
   // :END LFB
RETURN Self

METHOD OpenR(fname) CLASS HFormGen
   
   LOCAL oForm := ::aForms[1]
   MEMVAR oDesigner
   IF !hwg_MsgYesNo("The form will be opened INSTEAD of current ! Do you agree ?", "Designer")
      RETURN NIL
   ENDIF
   oDesigner:lSingleForm := .F.
   oForm:lChanged := .F.
   oForm:End()
   oDesigner:lSingleForm := .T.

RETURN ::Open(fname)

METHOD Open(fname, cForm) CLASS HFormGen

   MEMVAR oDesigner
   LOCAL aFormats := oDesigner:aFormats
   MEMVAR oForm
   MEMVAR aCtrlTable
   MEMVAR cCurDir
   PRIVATE oForm := Self
   PRIVATE aCtrlTable

   IF fname != NIL
      ::path := hwg_Filepath(fname)
      ::filename := hwg_CutPath(fname)
   ENDIF
   IF fname != NIL .OR. cForm != NIL .OR. FileDlg(Self, .T.)
      IF ::type == 1
         ReadForm(Self, cForm)
      ELSE
         IF HB_IsChar(aFormats[::type, 4])
            aFormats[::type, 4] := hwg_OpenScript(cCurDir + aFormats[::type, 3], aFormats[::type, 4])
         ENDIF
         IF HB_IsChar(aFormats[::type, 6])
            aFormats[::type, 6] := hwg_OpenScript(cCurDir + aFormats[::type, 3], aFormats[::type, 6])
         ENDIF
         IF HB_IsArray(aFormats[::type, 6])
            hwg_DoScript(aFormats[::type, 6])
         ENDIF
         IF HB_IsArray(aFormats[::type, 4])
            hwg_DoScript(aFormats[::type, 4])
         ENDIF
      ENDIF
      IF ::oDlg != NIL
         ::name := ::oDlg:title
         AAdd(::aForms, Self)
         // NANDO TIROU
             InspSetCombo()
      ENDIF
      IF ::oDlg == NIL .OR. Empty(::oDlg:aControls)
         hwg_MsgStop("Can't load the form", "Designer")
      ELSEIF !oDesigner:lSingleForm .AND. fname != NIL
         AddRecent(Self)
      ENDIF
   ENDIF
    // : LFB
    statusbarmsg(fname)
    // : END LFB
RETURN Self

METHOD End(lDlg, lCloseDes) CLASS HFormGen

   LOCAL i
   LOCAL j
   LOCAL name := ::name
   LOCAL oDlgSel
   MEMVAR oDesigner

   IF lDlg == NIL; lDlg := .F.; ENDIF
   IF ::lChanged
      IF hwg_MsgYesNo(::name + " was changed. Save it ?", "Designer")
         ::Save()
      ENDIF
   ENDIF

   FOR i := 1 TO Len(HFormGen():aForms)
      IF HFormGen():aForms[i]:oDlg:handle != ::oDlg:handle
         oDlgSel := HFormGen():aForms[i]:oDlg
      ELSE
         j := i
      ENDIF
   NEXT
   IF oDlgSel != NIL
      SetDlgSelected(oDlgSel)
   ELSE
      HFormGen():oDlgSelected := NIL
      IF oDesigner:oDlgInsp != NIL
         oDesigner:oDlgInsp:Close()
         // InspSetCombo()
      ENDIF
     // : LFB
      statusbarmsg("")
      // :END LFB
   ENDIF

   ADel(::aForms, j)
   ASize(::aForms, Len(::aForms) - 1)
   IF !lDlg
      ::oDlg:bDestroy := NIL
      EndDialog(::oDlg:handle)
   ENDIF
   IF oDesigner:lSingleForm .AND. (lCloseDes == NIL .OR. lCloseDes)
      oDesigner:oMainWnd:Close()
   ENDIF
RETURN .T.

METHOD Save(lAs) CLASS HFormGen

   MEMVAR oDesigner
   MEMVAR cCurDir
   LOCAL aFormats := oDesigner:aFormats
   LOCAL aControls
   MEMVAR oForm
   MEMVAR aCtrlTable
   PRIVATE oForm := Self
   PRIVATE aCtrlTable

   IF lAs == NIL; lAs := .F.; ENDIF
   IF !::lChanged .AND. !lAs
      hwg_MsgStop("Nothing to save", "Designer")
      RETURN NIL
   ENDIF

   IF (oDesigner:lSingleForm .AND. !lAs) .OR. ;
   ((Empty(::filename) .OR. lAs) .AND. FileDlg(Self, .F.)) .OR. !Empty(::filename)
      FrmSort(Self, IIf(oDesigner:lReport, ::oDlg:aControls[1]:aControls[1]:aControls, ::oDlg:aControls))
      IF ::type == 1
         aControls := WriteForm(Self)
         /*
         // : LFB
             //  salvar PRG diretamente sem necessidade de ficar mudando
         ::type := 3
         ::filename := StrTran(::filename, "xml", "prg")
         IF HB_IsChar(aFormats[::type, 5])
            aFormats[::type, 5] := hwg_OpenScript(cCurDir + aFormats[::type, 3], aFormats[::type, 5])
         ENDIF
         IF HB_IsArray(aFormats[::type, 5])
            hwg_DoScript(aFormats[::type, 5])
         ENDIF
         ::type := 1
         ::filename := StrTran(::filename, "prg", "xml")
        // :END LFB
        */
      ELSE
         IF HB_IsChar(aFormats[::type, 5])
            aFormats[::type, 5] := hwg_OpenScript(cCurDir + aFormats[::type, 3], aFormats[::type, 5])
         ENDIF
         IF HB_IsChar(aFormats[::type, 6])
            aFormats[::type, 6] := hwg_OpenScript(cCurDir + aFormats[::type, 3], aFormats[::type, 6])
         ENDIF
         IF HB_IsArray(aFormats[::type, 6])
            hwg_DoScript(aFormats[::type, 6])
         ENDIF
         IF HB_IsArray(aFormats[::type, 5])
            hwg_DoScript(aFormats[::type, 5])
         ENDIF
      ENDIF
      IF !oDesigner:lSingleForm .AND. !(::filename == "__tmp.xml")
         AddRecent(Self)
      ENDIF
   ENDIF
   IF !lAs
      ::lChanged := .F.
   ENDIF

RETURN NIL

METHOD CreateDialog(aProp) CLASS HFormGen

   MEMVAR oDesigner
   LOCAL i
   LOCAL j
   LOCAL cPropertyName
   LOCAL xProperty
   LOCAL oFormDesc := oDesigner:oFormDesc
   LOCAL hDC
   LOCAL aMetr
   LOCAL oPanel
   MEMVAR value
   MEMVAR oCtrl
   PRIVATE value
   PRIVATE oCtrl

   INIT DIALOG ::oDlg                         ;
          STYLE DS_ABSALIGN + WS_POPUP + WS_VISIBLE + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX ;
          ON SIZE  {|o, h, w|dlgOnSize(o, h, w)}  ;
          ON PAINT {|o|PaintDlg(o)}           ;
          ON EXIT  {|o|o:oParent:End(.T.)}    ;
          ON GETFOCUS {|o|SetDlgSelected(o)}

   ::oDlg:oParent := Self
   ::handle := oDesigner:oMainWnd:handle

   oCtrl := ::oDlg
   IF oFormDesc != NIL
      FOR i := 1 TO Len(oFormDesc:aItems)
         IF oFormDesc:aItems[i]:title == "property"
            IF !Empty(oFormDesc:aItems[i]:aItems)
               IF HB_IsChar(oFormDesc:aItems[i]:aItems[1]:aItems[1])
                  oFormDesc:aItems[i]:aItems[1]:aItems[1] := &("{||" + oFormDesc:aItems[i]:aItems[1]:aItems[1] + "}")
               ENDIF
               xProperty := Eval(oFormDesc:aItems[i]:aItems[1]:aItems[1])
            ELSE
               xProperty := oFormDesc:aItems[i]:GetAttribute("value")
            ENDIF
            AAdd(::aProp, {oFormDesc:aItems[i]:GetAttribute("name"), ;
                             xProperty, ;
                             oFormDesc:aItems[i]:GetAttribute("type")})
            IF oFormDesc:aItems[i]:GetAttribute("hidden") != NIL
               AAdd(ATail(::aProp), .T.)
            ENDIF
         ELSEIF oFormDesc:aItems[i]:title == "method"
            AAdd(::aMethods, {oFormDesc:aItems[i]:GetAttribute("name"), ""})
         ENDIF
      NEXT
   ENDIF
   IF aProp != NIL
      FOR i := 1 TO Len(aProp)
         cPropertyName := Lower(aProp[i, 1])
         IF (j := AScan(::aProp, {|a|Lower(a[1]) == cPropertyName})) != 0
            IF !Empty(aProp[i, 2])
               ::aProp[j, 2] := aProp[i, 2]
            ENDIF
         ELSE
            // AAdd(::aProp, {aProp[i, 1], aProp[i, 2]})
         ENDIF
      NEXT
   ENDIF
   FOR i := 1 TO Len(::aProp)
      value := ::aProp[i, 2]
      IF value != NIL // .AND. !Empty(value)
         cPropertyName := Lower(::aProp[i, 1])
         j := AScan(oDesigner:aDataDef, {|a|a[1] == cPropertyName})
         IF j != 0 .AND. oDesigner:aDataDef[j, 3] != NIL
            EvalCode(oDesigner:aDataDef[j, 3])
         ENDIF
      ENDIF
   NEXT

   IF oDesigner:lReport
      hDC := hwg_GetDC(hwg_GetActiveWindow())
      aMetr := hwg_GetDeviceArea(hDC)
      // writelog(Str(aMetr[1]) + Str(aMetr[2]) + Str(aMetr[3]) + Str(aMetr[4]) + Str(aMetr[5]) + Str(aMetr[6]) + Str(aMetr[7]) + Str(aMetr[8]) + Str(aMetr[9]))
      ::nKoeff := (aMetr[1] / aMetr[3] + aMetr[2] / aMetr[4]) / 2
      // writelog(Str(::nKoeff))
      hwg_ReleaseDC(hwg_GetActiveWindow(), hDC)
      ::SetPaper(::GetProp("Paper Size"), ::GetProp("Orientation"))
      IF ::oDlg:oFont == NIL
         ::oDlg:oFont := HFont():Add("Arial", 0, -13)
      ENDIF
      ::oDlg:style := hwg_BitOr(::oDlg:style, WS_VSCROLL + WS_HSCROLL + WS_MAXIMIZEBOX)

      @ LEFT_INDENT, TOP_INDENT PANEL oPanel ;
        SIZE Round(::nPWidth * ::nKoeff, 0)-1, Round(::nPHeight * ::nKoeff, 0)-1 ;
        ON SIZE {||.T.} ON PAINT {|o|PaintPanel(o)}
      oPanel:brush := 0
      @ 0, 0 PANEL OF oPanel SIZE oPanel:nWidth, oPanel:nHeight ;
        ON SIZE {|o, x, y|o:Move(,, x, y)} ON PAINT {|o|PaintPanel(o)}
      oPanel:aControls[1]:brush := HBrush():Add(16777215)
      oPanel:aControls[1]:bOther := {|o, m, wp, lp|MessagesProc(o, m, wp, lp)}
      oPanel:bOther := {|o, m, wp, lp|IIf(m == WM_KEYUP, MessagesProc(o, m, wp, lp), -1)}
      ::oDlg:bOther := {|o, m, wp, lp|ScrollProc(o, m, wp, lp)}
   ELSE
      ::oDlg:bOther := {|o, m, wp, lp|MessagesProc(o, m, wp, lp)}
   ENDIF

   ::oDlg:Activate(.T.)

   IF oDesigner:oDlgInsp == NIL
     //
      InspOpen(IIf(hwg_Getdesktopwidth() > 800, .T., .F.))
      IF hwg_Getdesktopwidth() <= 800
             oDesigner:oDlgInsp:HIDE()
          ENDIF
         //  NANDO escondeu ele
   ENDIF

RETURN NIL

METHOD GetProp(cName) CLASS HFormGen
   
   LOCAL i
  cName := Lower(cName)
  i := AScan(::aProp, {|a|Lower(a[1]) == cName})
RETURN IIf(i == 0, NIL, ::aProp[i, 2])

METHOD SetProp(xName, xValue) CLASS HFormGen

   IF HB_IsChar(xName)
      xName := Lower(xName)
      xName := AScan(::aProp, {|a|Lower(a[1]) == xName})
   ENDIF
   IF xName != 0
      ::aProp[xName, 2] := xValue
   ENDIF
RETURN NIL

METHOD SetPaper(cType, cOrientation) CLASS HFormGen
   
   LOCAL ntemp
   LOCAL nx := ::nPWidth
   LOCAL ny := ::nPHeight

   IF Lower(cType) == "a4"
      ::nPWidth  := 210
      ::nPHeight := 297
   ELSEIF Lower(cType) == "a3"
      ::nPWidth  := 297
      ::nPHeight := 420
   ENDIF
   IF Lower(cOrientation) != "portrait"
      ntemp :=   ::nPWidth
      ::nPWidth  := ::nPHeight
      ::nPHeight := ntemp
   ENDIF
   IF !Empty(::oDlg:aControls) .AND. (nx != ::nPWidth .OR. ny != ::nPHeight)
      ::oDlg:aControls[1]:Move(, , Round(::nPWidth * ::nKoeff, 0) - 1, Round(::nPHeight * ::nKoeff, 0) - 1)
   ENDIF

RETURN NIL

// ------------------------------------------

STATIC FUNCTION dlgOnSize(oDlg, h, w)

   LOCAL aCoors := hwg_GetClientRect(oDlg:handle)
   MEMVAR oDesigner

   // Writelog("dlgOnSize " + Str(h) + Str(w))
   IF !oDesigner:lReport
     // : LFB
      IF  h=aCoors[3] .AND. w=aCoors[4]
         oDlg:oParent:SetProp("Width", LTrim(Str(oDlg:nWidth := aCoors[3])))
         oDlg:oParent:SetProp("Height", LTrim(Str(oDlg:nHeight := aCoors[4])))
         //oDlg:oParent:SetProp("Height", LTrim(Str(oDlg:nHeight := aCoors[4] + 21 - 21)))
     ELSE
       hwg_RedrawWindow(oDlg:handle, RDW_ERASE + RDW_INVALIDATE)
       oDlg:show()
     ENDIF
      InspUpdBrowse()
      oDlg:oParent:lChanged := .T.
   ENDIF
RETURN NIL

STATIC FUNCTION SetDlgSelected(oDlg)
   
   MEMVAR oDesigner

   IF HFormGen():oDlgSelected == NIL .OR. HFormGen():oDlgSelected:handle != oDlg:handle
      HFormGen():oDlgSelected := oDlg
      IF oDesigner:oDlgInsp != NIL
         InspSetCombo()
        // :LFB
        IF odlg:oParent:filename != NIL
           statusbarmsg(IIf(odlg:oParent:path != NIL, odlg:oParent:path, "") + oDlg:oParent:filename, "", "")
         ENDIF
        // :END LFB
      ENDIF
   ENDIF
RETURN .T.

FUNCTION CnvCtrlName(cName, l2)

   LOCAL i
   MEMVAR aCtrlTable

   IF aCtrlTable == NIL
      RETURN cName
   ENDIF
   IF l2 == NIL
      l2 := .F.
   ENDIF
   IF l2
      i := AScan(aCtrlTable, {|a|a[2] == cName})
   ELSE
      i := AScan(aCtrlTable, {|a|a[1] == cName})
   ENDIF
RETURN IIf(i == 0, NIL, IIf(l2, aCtrlTable[i, 1], aCtrlTable[i, 2]))

STATIC FUNCTION FileDlg(oFrm, lOpen)

   MEMVAR oDesigner
   LOCAL oDlg
   LOCAL aFormats := oDesigner:aFormats
   LOCAL aCombo := {}
   LOCAL af := {}
   LOCAL oEdit1
   LOCAL oEdit2
   LOCAL nType := 1
   LOCAL fname := IIf(lOpen .OR. oFrm:filename == NIL, "", oFrm:filename)
   LOCAL formname := IIf(lOpen, "", oFrm:name)
   LOCAL i

   FOR i := 1 TO Len(aFormats)
      IF i == 1 .OR. (lOpen .AND. aFormats[i, 4] != NIL) .OR. ;
                     (!lOpen .AND. aFormats[i, 5] != NIL)
         AAdd(aCombo, aFormats[i, 1])
         AAdd(af, i)
         IF !lOpen .AND. oFrm:type == i
            nType := Len(af)
         ENDIF
      ENDIF
   NEXT

   INIT DIALOG oDlg TITLE IIf(lOpen, "Open form", "Save form") ;
       AT 50, 100 SIZE 310, 250 FONT oDesigner:oMainWnd:oFont

   @ 10, 20 GET COMBOBOX nType ITEMS aCombo SIZE 140, 24 ;
       ON CHANGE {||IIf(lOpen, .F.,(fname := hwg_CutExten(fname) + IIf(!Empty(fname), "." + aFormats[af[nType], 2], ""), oEdit1:Refresh()))}

   @ 10, 70 GET oEdit1 VAR fname  ;
        STYLE ES_AUTOHSCROLL      ;
        SIZE 200, 26

   @ 210, 70 BUTTON "Browse" SIZE 80, 26   ;
        ON CLICK {||BrowFile(lOpen, af[nType], oEdit1, oEdit2)}

   @ 10, 110 SAY "Form name:" SIZE 80, 22

   @ 10, 135 GET oEdit2 VAR formname SIZE 140, 26

   @ 20, 200 BUTTON "Ok" ID IDOK  SIZE 100, 32
   @ 180, 200 BUTTON "Cancel" ID IDCANCEL  SIZE 100, 32

   oDlg:Activate()

   IF oDlg:lResult
      oFrm:type := af[nType]
      oFrm:filename := hwg_CutPath(fname)
      IF Empty(hwg_FilExten(oFrm:filename))
         oFrm:filename += "." + aFormats[af[nType], 2]
      ENDIF
      oFrm:path := IIf(Empty(hwg_FilePath(fname)), oDesigner:ds_mypath, hwg_FilePath(fname))
      RETURN .T.
   ENDIF

RETURN .F.

STATIC FUNCTION BrowFile(lOpen, nType, oEdit1, oEdit2)

   MEMVAR oDesigner
   LOCAL fname
   LOCAL s1
   LOCAL s2
   LOCAL l_ds_mypath

   s2 := "*." + oDesigner:aFormats[nType, 2]
   s1 := oDesigner:aFormats[nType, 1] + "( " + s2 + " )"

   IF lOpen
      fname := hwg_SelectFile({s1, "All files"}, {s2, "*.*"}, oDesigner:ds_mypath)
   ELSE
      fname := hwg_SaveFile(s2, s1, s2, oDesigner:ds_mypath)
   ENDIF
   IF !Empty(fname)
      l_ds_mypath := Lower(hwg_FilePath(fname))
      IF !(oDesigner:ds_mypath == l_ds_mypath)
         oDesigner:ds_mypath := l_ds_mypath
         oDesigner:lChgPath  := .T.
      ENDIF
      fname := hwg_CutPath(fname)
      oEdit1:SetGet(fname)
      oEdit1:Refresh()
      hwg_SetFocus(oEdit2:handle)
   ENDIF

RETURN NIL

STATIC FUNCTION ReadTree(aParent, oDesc)

   LOCAL i
   LOCAL aTree := {}
   LOCAL oNode

   FOR i := 1 TO Len(oDesc:aItems)
      oNode := oDesc:aItems[i]
      IF oNode:type == HBXML_TYPE_CDATA
         aParent[4] := oNode:aItems[1]
      ELSE
         AAdd(aTree, {NIL, oNode:GetAttribute("name"), ;
                 Val(oNode:GetAttribute("id")), NIL})
         IF !Empty(oNode:aItems)
            aTree[Len(aTree), 1] := ReadTree(ATail(aTree), oNode)
         ENDIF
      ENDIF
   NEXT

RETURN IIf(Empty(aTree), NIL, aTree)

STATIC FUNCTION ReadCtrls(oDlg, oCtrlDesc, oContainer, nPage)

   LOCAL i
   LOCAL j
   LOCAL o
   LOCAL aRect
   LOCAL aProp := {}
   LOCAL aItems := oCtrlDesc:aItems
   LOCAL oCtrl
   LOCAL cName
   LOCAL cProperty
   LOCAL cPropertyName
   MEMVAR oDesigner

   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               cPropertyName := o:GetAttribute("name")
               IF Lower(cPropertyName) == "geometry"
                  aRect := hfrm_Str2Arr(o:aItems[1])
                  AAdd(aProp, {"Left", aRect[1]})
                  AAdd(aProp, {"Top", aRect[2]})
                  AAdd(aProp, {"Width", aRect[3]})
                  AAdd(aProp, {"Height", aRect[4]})
                  IF oDesigner:lReport
                     AAdd(aProp, {"Right", aRect[5]})
                     AAdd(aProp, {"Bottom", aRect[6]})
                  ENDIF
               ELSEIF Lower(cPropertyName) == "font"
                  AAdd(aProp, {cPropertyName, hfrm_FontFromxml(o:aItems[1])})
               ELSEIF Lower(cPropertyName) == "atree"
                  AAdd(aProp, {cPropertyName, ReadTree(, o)})
               ELSEIF !Empty(o:aItems)
                  cProperty := Left(o:aItems[1], 1)
                  IF cProperty == "["
                     cProperty := SubStr(o:aItems[1], 2, Len(o:aItems[1]) - 2)
                  ELSEIF cProperty == "."
                     cProperty := IIf(SubStr(o:aItems[1], 2, 1) == "T", "True", "False")
                  ELSEIF cProperty == "{"
                     cProperty := hfrm_Str2Arr(o:aItems[1])
                  ELSE
                     cProperty := o:aItems[1]
                  ENDIF
                  AAdd(aProp, {cPropertyName, cProperty})
               ENDIF
            ENDIF
         NEXT
         IF AScan(aProp, {|a|a[1] == "Name"}) == 0
            AAdd(aProp, {"Name", ""})
         ENDIF
         oCtrl := HControlGen():New(oDlg, oCtrlDesc:GetAttribute("class"), aProp)
         IF oContainer != NIL
            oContainer:AddControl(oCtrl)
            oCtrl:oContainer := oContainer
         ENDIF
         IF (cProperty := oCtrlDesc:GetAttribute("options")) != NIL .AND. ;
            "embed" $ cProperty
            oCtrl:lEmbed := .T.
         ENDIF
         IF nPage != NIL
            oCtrl:nPage := nPage
         ENDIF
      ELSEIF aItems[i]:title == "method"
         cName := aItems[i]:GetAttribute("name")
         IF (j := AScan(oCtrl:aMethods, {|a|a[1] == cName})) != 0
            oCtrl:aMethods[j, 2] := aItems[i]:aItems[1]:aItems[1]
         ENDIF
      ELSEIF aItems[i]:title == "part"
         IF Lower(aItems[i]:GetAttribute("class")) == "pagesheet"
            FOR j := 1 TO Len(aItems[i]:aItems)
               ReadCtrls(oDlg, aItems[i]:aItems[j], oCtrl, Val(aItems[i]:GetAttribute("page")))
            NEXT
         ELSE
            ReadCtrls(oDlg, aItems[i], oCtrl)
         ENDIF
         IF oCtrl != NIL .AND. Lower(oCtrl:cClass) == "page"
            aRect := oCtrl:GetProp("Tabs")
            IF aRect != NIL .AND. !Empty(aRect)
               Page_Upd(oCtrl, aRect)
               Page_Select(oCtrl, 1, .T.)
            ENDIF
         ENDIF
      ENDIF
   NEXT

RETURN NIL

STATIC FUNCTION ReadForm(oForm, cForm)

   LOCAL oDoc := IIf(cForm != NIL, HXMLDoc():ReadString(cForm), HXMLDoc():Read(oForm:path + oForm:filename))
   LOCAL i
   LOCAL j
   LOCAL aItems
   LOCAL o
   LOCAL aProp := {}
   LOCAL cPropertyName
   LOCAL aRect
   LOCAL cProperty
   MEMVAR oDesigner

   IF Empty(oDoc:aItems)
      hwg_MsgStop("Can't open " + oForm:path + oForm:filename, "Designer")
      RETURN NIL
   ELSEIF oDoc:aItems[1]:title != "part" .OR. oDoc:aItems[1]:GetAttribute("class") != IIf(oDesigner:lReport, "report", "form")
      hwg_MsgStop("Form description isn't found", "Designer")
      RETURN NIL
   ENDIF
   oForm:cEncoding := oDoc:GetAttribute("encoding")
   aItems := oDoc:aItems[1]:aItems
   FOR i := 1 TO Len(aItems)
      IF aItems[i]:title == "style"
         FOR j := 1 TO Len(aItems[i]:aItems)
            o := aItems[i]:aItems[j]
            IF o:title == "property"
               cPropertyName := o:GetAttribute("name")
               IF Lower(cPropertyName) == "geometry"
                  aRect := hfrm_Str2Arr(o:aItems[1])
                  AAdd(aProp, {"Left", aRect[1]})
                  AAdd(aProp, {"Top", aRect[2]})
                  AAdd(aProp, {"Width", aRect[3]})
                  AAdd(aProp, {"Height", aRect[4]})
               ELSEIF Lower(cPropertyName) == "font"
                  AAdd(aProp, {cPropertyName, hfrm_FontFromxml(o:aItems[1])})
               ELSEIF !Empty(o:aItems)
                  cProperty := Left(o:aItems[1], 1)
                  IF cProperty == "["
                     cProperty := SubStr(o:aItems[1], 2, Len(o:aItems[1]) - 2)
                  ELSEIF cProperty == "."
                     cProperty := IIf(SubStr(o:aItems[1], 2, 1) == "T", "True", "False")
                  ELSEIF cProperty == "{"
                     cProperty := hfrm_Str2Arr(o:aItems[1])
                  ELSE
                     cProperty := o:aItems[1]
                  ENDIF
                  AAdd(aProp, {cPropertyName, cProperty})
               ENDIF
            ENDIF
         NEXT
         oForm:CreateDialog(aProp)
      ELSEIF aItems[i]:title == "method"
         cPropertyName := aItems[i]:GetAttribute("name")
         IF (j := AScan(oForm:aMethods, {|a|a[1] == cPropertyName})) != 0
            oForm:aMethods[j, 2] := aItems[i]:aItems[1]:aItems[1]
         ENDIF
      ELSEIF aItems[i]:title == "part"
         ReadCtrls(IIf(oDesigner:lReport, oForm:oDlg:aControls[1]:aControls[1], oForm:oDlg), aItems[i])
      ENDIF
   NEXT
RETURN NIL

FUNCTION IsDefault(oCtrl, aPropItem)

   LOCAL j1
   LOCAL aItems := oCtrl:oXMLDesc:aItems
   LOCAL xProperty
   LOCAL cPropName := Lower(aPropItem[1])

   FOR j1 := 1 TO Len(aItems)
      IF aItems[j1]:title == "property" .AND. ;
                   Lower(aItems[j1]:GetAttribute("name")) == cPropName

         IF !Empty(aItems[j1]:aItems)
            IF HB_IsChar(aItems[j1]:aItems[1]:aItems[1])
               aItems[j1]:aItems[1]:aItems[1] := &("{||" + aItems[j1]:aItems[1]:aItems[1] + "}")
            ENDIF
            xProperty := Eval(aItems[j1]:aItems[1]:aItems[1])
         ELSE
            xProperty := aItems[j1]:GetAttribute("value")
         ENDIF

         IF xProperty != NIL .AND. xProperty == aPropItem[2]
            RETURN .T.
         ENDIF
      ENDIF
   NEXT

RETURN .F.

STATIC FUNCTION WriteTree(aTree, oParent)

   LOCAL i
   LOCAL oNode
   LOCAL type

   FOR i := 1 TO Len(aTree)
      IF aTree[i, 4] != NIL .OR. (HB_IsArray(aTree[i, 1]) .AND. !Empty(aTree[i, 1]))
         type := HBXML_TYPE_TAG
      ELSE
         type := HBXML_TYPE_SINGLE
      ENDIF
      oNode := oParent:Add(HXMLNode():New("item", type, ;
             {{"name", aTree[i, 2]}, {"id", LTrim(Str(aTree[i, 3]))}}))
      IF aTree[i, 4] != NIL
         oNode:Add(HXMLNode():New(, HBXML_TYPE_CDATA,, aTree[i, 4]))
      ENDIF
      IF HB_IsArray(aTree[i, 1]) .AND. !Empty(aTree[i, 1])
         WriteTree(aTree[i, 1], oNode)
      ENDIF
   NEXT
RETURN NIL

STATIC FUNCTION WriteCtrl(oParent, oCtrl, lRoot)

   LOCAL i
   LOCAL j
   LOCAL oNode
   LOCAL oNode1
   LOCAL oStyle
   LOCAL oMeth
   LOCAL aItems
   LOCAL cPropertyName
   LOCAL lDef
   LOCAL cProperty
   MEMVAR oDesigner

   IF !lRoot .OR. oCtrl:oContainer == NIL
      aItems := oCtrl:oXMLDesc:aItems
      oNode := oParent:Add(HXMLNode():New("part",, {{"class", oCtrl:cClass}}))
      IF oCtrl:lEmbed
         oNode:SetAttribute("options", "embed")
      ENDIF
      oStyle := oNode:Add(HXMLNode():New("style"))
      IF oDesigner:lReport
         oStyle:Add(HXMLNode():New("property",, {{"name", "Geometry"}}, ;
          hfrm_Arr2Str({oCtrl:GetProp("Left"), oCtrl:GetProp("Top"), oCtrl:GetProp("Width"), oCtrl:GetProp("Height"), oCtrl:GetProp("Right"), oCtrl:GetProp("Bottom")})))
      ELSE
         oStyle:Add(HXMLNode():New("property",, {{"name", "Geometry"}}, ;
          hfrm_Arr2Str({oCtrl:GetProp("Left"), oCtrl:GetProp("Top"), oCtrl:GetProp("Width"), oCtrl:GetProp("Height")})))
      ENDIF
      FOR j := 1 TO Len(oCtrl:aProp)
         cPropertyName := Lower(oCtrl:aProp[j, 1])
         IF AScan(aG, cPropertyName) != 0
            lDef := .T.
         /*
         ELSEIF (cPropertyName == "textcolor" .AND. oCtrl:tColor == 0) .OR. ;
                (cPropertyName == "backcolor" .AND. oCtrl:bColor == hwg_GetSysColor(COLOR_3DFACE))
            lDef := .T.
         */
         ELSEIF (cPropertyName == "name" .AND. Empty(oCtrl:aProp[j, 2]))
            lDef := .T.
         ELSE
            lDef := IsDefault(oCtrl, oCtrl:aProp[j])
         ENDIF
         IF !lDef
            IF Lower(oCtrl:aProp[j, 1]) == "font"
               IF oCtrl:oFont != NIL
                  oNode1 := oStyle:Add(HXMLNode():New("property",, {{"name", "font"}}))
                  oNode1:Add(hwg_Font2XML(oCtrl:oFont))
               ENDIF
            ELSEIF Lower(oCtrl:aProp[j, 1]) == "atree"
               oNode1 := oStyle:Add(HXMLNode():New("property",, {{"name", "atree"}}))
               WriteTree(oCtrl:aProp[j, 2], oNode1)
            ELSEIF oCtrl:aProp[j, 2] != NIL
               IF oCtrl:aProp[j, 3] == "C"
                  cProperty := "[" + oCtrl:aProp[j, 2] + "]"
               ELSEIF oCtrl:aProp[j, 3] == "N"
                  cProperty := oCtrl:aProp[j, 2]
               ELSEIF oCtrl:aProp[j, 3] == "L"
                  cProperty := IIf(Lower(oCtrl:aProp[j, 2]) == "true", ".T.", ".F.")
               ELSEIF oCtrl:aProp[j, 3] == "A"
                  cProperty := hfrm_Arr2Str(oCtrl:aProp[j, 2])
               ELSE
                  cProperty := ""
               ENDIF
               oStyle:Add(HXMLNode():New("property",, {{"name", oCtrl:aProp[j, 1]}}, cProperty))
            ENDIF
         ENDIF
      NEXT
      FOR j := 1 TO Len(oCtrl:aMethods)
         IF !Empty(oCtrl:aMethods[j, 2])
            oMeth := oNode:Add(HXMLNode():New("method",, {{"name", oCtrl:aMethods[j, 1]}}))
            oMeth:Add(HXMLNode():New(, HBXML_TYPE_CDATA,, oCtrl:aMethods[j, 2]))
         ENDIF
      NEXT
      IF !Empty(oCtrl:aControls)
         IF Lower(oCtrl:cClass) == "page" .AND. ;
              (aItems := oCtrl:GetProp("Tabs")) != NIL .AND. ;
              !Empty(aItems)
            FOR j := 1 TO Len(aItems)
               oNode1 := oNode:Add(HXMLNode():New("part",, {{"class", "PageSheet"}, {"page", LTrim(Str(j))}}))
               FOR i := 1 TO Len(oCtrl:aControls)
                  IF oCtrl:aControls[i]:nPage == j
                     WriteCtrl(oNode1, oCtrl:aControls[i], .F.)
                  ENDIF
               NEXT
            NEXT
         ELSE
            FOR i := 1 TO Len(oCtrl:aControls)
               WriteCtrl(oNode, oCtrl:aControls[i], .F.)
            NEXT
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION WriteForm(oForm)

   LOCAL oDoc := HXMLDoc():New(oForm:cEncoding)
   LOCAL oNode
   LOCAL oNode1
   LOCAL oStyle
   LOCAL i
   LOCAL oMeth
   LOCAL cProperty
   LOCAL aControls
   MEMVAR oDesigner

   oNode := oDoc:Add(HXMLNode():New("part",, {{"class", IIf(oDesigner:lReport, "report", "form")}}))
   oStyle := oNode:Add(HXMLNode():New("style"))
   oStyle:Add(HXMLNode():New("property",, {{"name", "Geometry"}}, ;
       hfrm_Arr2Str({oForm:oDlg:nLeft, oForm:oDlg:nTop, oForm:oDlg:nWidth, oForm:oDlg:nHeight})))
   FOR i := 1 TO Len(oForm:aProp)
      IF AScan(aG, Lower(oForm:aProp[i, 1])) == 0
         IF Lower(oForm:aProp[i, 1]) == "font"
            IF oForm:oDlg:oFont != NIL
               oNode1 := oStyle:Add(HXMLNode():New("property",, {{"name", oForm:aProp[i, 1]}}))
               oNode1:Add(hwg_Font2XML(oForm:oDlg:oFont))
            ENDIF
         ELSEIF oForm:aProp[i, 2] != NIL
            IF oForm:aProp[i, 3] == "C"
               cProperty := "[" + oForm:aProp[i, 2] + "]"
            ELSEIF oForm:aProp[i, 3] == "N"
               cProperty := oForm:aProp[i, 2]
            ELSEIF oForm:aProp[i, 3] == "L"
               cProperty := IIf(Lower(oForm:aProp[i, 2]) == "true", ".T.", ".F.")
            ELSEIF oForm:aProp[i, 3] == "A"
               cProperty := hfrm_Arr2Str(oForm:aProp[i, 2])
            ELSE
               cProperty := ""
            ENDIF
            oStyle:Add(HXMLNode():New("property",, {{"name", oForm:aProp[i, 1]}}, cProperty))
         ENDIF
      ENDIF
   NEXT
   FOR i := 1 TO Len(oForm:aMethods)
      IF !Empty(oForm:aMethods[i, 2])
         oMeth := oNode:Add(HXMLNode():New("method",, {{"name", oForm:aMethods[i, 1]}}))
         oMeth:Add(HXMLNode():New(, HBXML_TYPE_CDATA,, oForm:aMethods[i, 2]))
      ENDIF
   NEXT
   aControls := IIf(oDesigner:lReport, oForm:oDlg:aControls[1]:aControls[1]:aControls, oForm:oDlg:aControls)
   FOR i := 1 TO Len(aControls)
      WriteCtrl(oNode, aControls[i], .T.)
   NEXT

   IF oDesigner:lSingleForm
      oDesigner:cResForm := oDoc:Save()
   ELSE
      oDoc:Save(oForm:path + oForm:filename)
   ENDIF
RETURN NIL

STATIC FUNCTION PaintDlg(oDlg)

   LOCAL pps
   LOCAL hDC
   LOCAL aCoors
   LOCAL oCtrl := GetCtrlSelected(oDlg)
   LOCAL oForm := oDlg:oParent
   LOCAL x1 := LEFT_INDENT
   LOCAL y1 := TOP_INDENT
   LOCAL i
   LOCAL n1cm
   LOCAL xt
   LOCAL yt
   LOCAL oldBkColor
   LOCAL nTop
   LOCAL nLeft
   LOCAL nRight
   LOCAL nBottom
   MEMVAR oDesigner

   pps := hwg_DefinePaintStru()
   hDC := hwg_BeginPaint(oDlg:handle, pps)

   // aCoors := hwg_GetClientRect(oDlg:handle)
   // hwg_FillRect(hDC, aCoors[1], aCoors[2], aCoors[3], aCoors[4], oDlg:brush:handle)
   IF oDesigner:lReport
      aCoors := hwg_GetClientRect(oDlg:handle)
      // x2 := x1 + Round(oForm:nPWidth * oForm:nKoeff, 0) - 1
      // y2 := y1 + Round(oForm:nPHeight * oForm:nKoeff, 0) - 1
      n1cm := Round(oForm:nKoeff * 10, 0)

      hwg_FillRect(hDC, 0, 0, aCoors[3], TOP_INDENT - 5, COLOR_3DLIGHT + 1)
      hwg_FillRect(hDC, 0, 0, LEFT_INDENT - 12, aCoors[4], COLOR_3DLIGHT + 1)
      i := 0
      // hwg_SelectObject(hDC, oPenLine:handle)
      hwg_SelectObject(hDC, oDlg:oFont:handle)
      oldBkColor := hwg_SetBkColor(hDC, hwg_GetSysColor(COLOR_3DLIGHT))
      DO WHILE i * n1cm < (aCoors[3] - aCoors[1] - LEFT_INDENT)
         xt := x1 + i * n1cm
         hwg_DrawLine(hDC, xt + Round(n1cm / 4, 0), 0, xt + Round(n1cm / 4, 0), 4)
         hwg_DrawLine(hDC, xt + Round(n1cm / 2, 0), 0, xt + Round(n1cm / 2, 0), 8)
         hwg_DrawLine(hDC, xt + Round(n1cm * 3 / 4, 0), 0, xt + Round(n1cm * 3 / 4, 0), 4)
         hwg_DrawLine(hDC, xt, 0, xt, 12)
         IF i > 0
            hwg_DrawText(hDC, LTrim(Str(i + oForm:nXOffset / 10, 2)), xt - 15, 12, xt + 15, TOP_INDENT - 5, DT_CENTER)
         ENDIF
         i++
      ENDDO
      i := 0
      DO WHILE i * n1cm < (aCoors[4] - aCoors[2] - TOP_INDENT)
         yt := y1 + i * n1cm
         hwg_DrawLine(hDC, 0, yt + Round(n1cm / 4, 0), 4, yt + Round(n1cm / 4, 0))
         hwg_DrawLine(hDC, 0, yt + Round(n1cm / 2, 0), 8, yt + Round(n1cm / 2, 0))
         hwg_DrawLine(hDC, 0, yt + Round(n1cm * 3 / 4, 0), 4, yt + Round(n1cm * 3 / 4, 0))
         hwg_DrawLine(hDC, 0, yt, 12, yt)
         IF i > 0
            hwg_DrawText(hDC, LTrim(Str(i + oForm:nYOffset / 10, 2)), 12, yt - 10, LEFT_INDENT - 12, yt + 10, DT_CENTER)
         ENDIF
         i++
      ENDDO
      // hwg_FillRect(hDC, LEFT_INDENT - 12, y1, x1, y2, COLOR_3DSHADOW + 1)
      hwg_SetScrollInfo(oDlg:handle, SB_HORZ, 1, oForm:nXOffset / 10 + 1, 1, Round((oForm:nPWidth - (aCoors[3] - LEFT_INDENT) / oForm:nKoeff) / 10, 0) + 1)
      hwg_SetScrollInfo(oDlg:handle, SB_VERT, 1, oForm:nYOffset / 10 + 1, 1, Round((oForm:nPHeight - (aCoors[4] - TOP_INDENT) / oForm:nKoeff) / 10, 0) + 1)
   ELSE

      if oDesigner:lShowGrid
          aCoors := hwg_GetClientRect(oDlg:handle)
          nTop   := aCoors[1]
          nLeft  := aCoors[2]
          nRight := aCoors[3]
          nBottom := aCoors[4]           *  PS_DOT
          // : LFB
          hwg_SetROP2(hDC, 9)
          oPenDivider := HPen():Add(PS_DOT, 1, hwg_VColor("606060"))
          hwg_SelectObject(hDC, oPenDivider:handle)
          // :END LFB
          for i := nLeft + oDesigner:nPixelGrid to nRight step oDesigner:nPixelGrid
              hwg_DrawLine(hDC, i, nTop, i, nBottom)  //v
          next
          for i := nTop + oDesigner:nPixelGrid to nBottom step oDesigner:nPixelGrid
             hwg_DrawLine(hDC, nLeft + 2, i, nRight, i)    //h
          next
          // : LFB
          hwg_SetROP2(hDC, 13)
          oPenDivider := HPen():Add(PS_SOLID, 1, hwg_VColor("0"))
          hwg_SelectObject(hDC, oPenDivider:handle)
          // :END LFB
      endif

      IF oCtrl != NIL .AND. oCtrl:nTop >= 0
             // : LFB tirei a borda do objeto selecionado
         //hwg_Rectangle(hDC, oCtrl:nLeft - 3, oCtrl:nTop - 3, oCtrl:nLeft + oCtrl:nWidth + 2, oCtrl:nTop + oCtrl:nHeight + 2)
         hwg_Rectangle(hDC, oCtrl:nLeft - 1, oCtrl:nTop - 1, oCtrl:nLeft + oCtrl:nWidth, oCtrl:nTop + oCtrl:nHeight)

      ENDIF
/*
      oDesigner:addItem := NIL
      IF hwg_IsCheckedMenuItem(oDesigner:oMainWnd:handle, 1050)
        i := 0
        aCoors := hwg_GetClientRect(oDlg:handle)
        n1cm := oDesigner:nPixelGrid
        x1 := n1cm
        DO WHILE x1 < (aCoors[3] - aCoors[1])
          y1 := n1cm
          DO WHILE y1 < (aCoors[4] - aCoors[2])
            hwg_DrawLine(hDC, x1, y1, x1 + 1, y1 + 1)
       y1 += n1cm
          ENDDO
          x1 += n1cm
        ENDDO
      ENDIF
*/
   ENDIF

   hwg_EndPaint(oDlg:handle, pps)

RETURN NIL

STATIC FUNCTION PaintPanel(oPanel)

   LOCAL pps
   LOCAL hDC

   pps := hwg_DefinePaintStru()
   hDC := hwg_BeginPaint(oPanel:handle, pps)

   IF oPanel:oParent:Classname() == "HPANEL"
   ENDIF

   hwg_EndPaint(oPanel:handle, pps)

RETURN NIL

STATIC FUNCTION MessagesProc(oDlg, msg, wParam, lParam)

   LOCAL oCtrl
   LOCAL aCoors
   LOCAL nShift
   LOCAL nKshift
   LOCAL asels
   LOCAL i
   MEMVAR oDesigner
   // writelog(Str(msg) + Str(wParam) + Str(lParam))

   IF msg == WM_MOUSEMOVE
      MouseMove(oDlg, wParam, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      RETURN 1
   ELSEIF msg == WM_LBUTTONDOWN
      StatusBarMsg(, "", "")  //
      LButtonDown(oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      RETURN 1
   ELSEIF msg == WM_LBUTTONUP
      LButtonUp(oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      RETURN 1
   ELSEIF msg == WM_RBUTTONUP
      RButtonUp(oDlg, hwg_LOWORD(lParam), hwg_HIWORD(lParam))
      RETURN 1
   ELSEIF msg == WM_LBUTTONDBLCLK
         nkShift := hwg_GetKeyState(VK_MENU)
         IF nkShift < 0  .OR. GetCtrlSelected(IIf(oDlg:oParent:Classname() == "HDIALOG", oDlg:oParent, oDlg))!= NIL
             IIf(oDesigner:oDlgInsp == NIL, InspOpen(), InspShow())
          ELSE
            socontroles()
         ENDIF
      RETURN 1
   ELSEIF msg == WM_MOVE
      IF !oDesigner:lReport
         aCoors := hwg_GetWindowRect(oDlg:handle)
         oDlg:oParent:SetProp("Left", LTrim(Str(oDlg:nLeft := aCoors[1])))
         oDlg:oParent:SetProp("Top", LTrim(Str(oDlg:nTop  := aCoors[2])))
         InspUpdBrowse()
         oDlg:oParent:lChanged := .T.
      ENDIF
   ELSEIF msg == WM_KEYDOWN
      IF wParam == 46    // Del
         DeleteCtrl()
      ENDIF
      IF wParam == 34 .OR. wParam == 33       // PGDown /PGUP
        oCtrl := GetCtrlSelected(IIf(oDlg:oParent:Classname() == "HDIALOG", oDlg:oParent, oDlg))
        IF oCtrl != NIL
           asels := aselCtrls()
              FOR i = 1 to IIf(Len(asels) > 0, Len(asels), 1)
                 oCtrl := asels[i]
               SetBDown(, 0, 0, 0)
               CtrlMove(oCtrl, 0, IIf(wParam == 34, 1, -1), .F.)
             NEXT
           RETURN 1
        ENDIF
         ENDIF
      IF wParam == 35 .OR. wParam == 36       // HOME END
        oCtrl := GetCtrlSelected(IIf(oDlg:oParent:Classname() == "HDIALOG", oDlg:oParent, oDlg))
        IF oCtrl != NIL
           asels := aselCtrls()
              FOR i = 1 to IIf(Len(asels) > 0, Len(asels), 1)
                 oCtrl := asels[i]
               SetBDown(, 0, 0, 0)
               CtrlMove(oCtrl, IIf(wParam == 35, 1, -1), 0, .F.)
             NEXT
            RETURN 1
        ENDIF
         ENDIF

   ELSEIF msg == WM_KEYUP
      nkShift := hwg_GetKeyState(VK_SHIFT)
      nShift := IIf(hwg_GetKeyState(17) < 0, 10, 1)
      oCtrl := GetCtrlSelected(IIf(oDlg:oParent:Classname() == "HDIALOG", oDlg:oParent, oDlg))
      IF wParam == 40        // Down
         IF oCtrl != NIL
           IF nKshift >= 0
                  SetBDown(, 0, 0, 0)
                 CtrlMove(oCtrl, 0, nShift, .F.)
                 RETURN 1
           ELSE
               SetBDown(, oCtrl:nLeft, oCtrl:nTop, 4)
             CtrlResize(OCTRL, oCtrl:nLeft, oCtrl:nTop + 1)
             RETURN 1
           ENDIF
         ENDIF
      ELSEIF wParam == 38    // Up
         IF oCtrl != NIL
           IF nKshift >= 0
                 SetBDown(, 0, 0, 0)
                CtrlMove(oCtrl, 0, -nShift, .F.)
                 RETURN 1
           ELSE
               SetBDown(, oCtrl:nLeft, oCtrl:nTop, 4)
             CtrlResize(OCTRL, oCtrl:nLeft, oCtrl:nTop - 1)
             RETURN 1
           ENDIF
         ENDIF
      ELSEIF wParam == 39    // Right
         IF oCtrl != NIL
             IF nKshift >= 0
             SetBDown(, 0, 0, 0)
             CtrlMove(oCtrl, nShift, 0, .F.)
           ELSE
               SetBDown(, oCtrl:nLeft, oCtrl:nTop, 3)
             CtrlResize(OCTRL, oCtrl:nLeft + 1, oCtrl:nTop)
             RETURN 1
           ENDIF
         ENDIF
      ELSEIF wParam == 37    // Left
         IF oCtrl != NIL
           IF nKshift >= 0
             SetBDown(, 0, 0, 0)
             CtrlMove(oCtrl, -nShift, 0, .F.)
           ELSE
               SetBDown(, oCtrl:nLeft, oCtrl:nTop, 3)
             CtrlResize(OCTRL, oCtrl:nLeft - 1, oCtrl:nTop)
             RETURN 1
           ENDIF
           ENDIF
      ENDIF
      // :LFB
      IF oCtrl != NIL
         statusbarmsg(, "x: " + lTrim(Str(oCtrl:nLeft)) + "  y: " + LTrim(Str(oCtrl:nTop)), ;
         "w: " + LTrim(Str(oCtrl:nWidth)) + "  h: " + LTrim(Str(oCtrl:nHeight)))
      ELSE
         statusbarmsg(, "", "")
         ENDIF
      // : END LFB
   ENDIF

RETURN -1

STATIC FUNCTION ScrollProc(oDlg, msg, wParam, lParam)

   LOCAL nScrollCode := hwg_LOWORD(wParam)
   LOCAL nNewPos := hwg_HIWORD(wParam)
   LOCAL oPanel := oDlg:aControls[1]:aControls[1]
   LOCAL aCoors
   LOCAL nSize
   LOCAL x

   HB_SYMBOL_UNUSED(lParam)

   // writelog("> " + Str(msg) + Str(wParam) + Str(lParam))
   IF msg == WM_VSCROLL
      x := oDlg:oParent:nYOffset
      aCoors := hwg_GetClientRect(oDlg:handle)
      nSize  := (aCoors[4] - TOP_INDENT) / oDlg:oParent:nKoeff
      IF nScrollCode == SB_LINEDOWN
         IF oDlg:oParent:nYOffset + nSize < oDlg:oParent:nPHeight
            oDlg:oParent:nYOffset += 10
         ENDIF
      ELSEIF nScrollCode == SB_LINEUP
         IF oDlg:oParent:nYOffset > 0
            oDlg:oParent:nYOffset -= 10
         ENDIF
      ELSEIF nScrollCode == SB_THUMBTRACK
         IF --nNewPos != oDlg:oParent:nYOffset / 10
            oDlg:oParent:nYOffset := nNewPos * 10
         ENDIF
      ENDIF
      IF x != oDlg:oParent:nYOffset
         oPanel:Move(, -Round(oDlg:oParent:nYOffset * oDlg:oParent:nKoeff, 0))
         IF oDlg:oParent:nYOffset + nSize >= oDlg:oParent:nPHeight
            hwg_RedrawWindow(oDlg:handle, RDW_ERASE + RDW_INVALIDATE)
         ELSE
            hwg_InvalidateRect(oDlg:handle, 0, 0, TOP_INDENT, aCoors[3], aCoors[4])
            hwg_SendMessage(oDlg:handle, WM_PAINT, 0, 0)
         ENDIF
      ENDIF

   ELSEIF msg == WM_HSCROLL
      x := oDlg:oParent:nXOffset
      aCoors := hwg_GetClientRect(oDlg:handle)
      nSize  := (aCoors[3] - LEFT_INDENT) / oDlg:oParent:nKoeff
      IF nScrollCode == SB_LINEDOWN
         IF oDlg:oParent:nXOffset + nSize < oDlg:oParent:nPWidth
            oDlg:oParent:nXOffset += 10
         ENDIF
      ELSEIF nScrollCode == SB_LINEUP
         IF oDlg:oParent:nXOffset > 0
            oDlg:oParent:nXOffset -= 10
         ENDIF
      ELSEIF nScrollCode == SB_THUMBTRACK
         IF --nNewPos != oDlg:oParent:nXOffset / 10
            oDlg:oParent:nXOffset := nNewPos * 10
         ENDIF
      ENDIF
      IF x != oDlg:oParent:nXOffset
         oPanel:Move(-Round(oDlg:oParent:nXOffset * oDlg:oParent:nKoeff, 0))
         IF oDlg:oParent:nXOffset + nSize >= oDlg:oParent:nPWidth
            hwg_RedrawWindow(oDlg:handle, RDW_ERASE + RDW_INVALIDATE)
         ELSE
            hwg_InvalidateRect(oDlg:handle, 0, LEFT_INDENT, 0, aCoors[3], aCoors[4])
            hwg_SendMessage(oDlg:handle, WM_PAINT, 0, 0)
         ENDIF
      ENDIF
   /*
   ELSEIF msg == WM_KEYDOWN .OR. msg == WM_KEYUP
      RETURN MessagesProc(oDlg, msg, wParam, lParam)
   */
   ENDIF

RETURN -1


STATIC FUNCTION MouseMove(oDlg, wParam, xPos, yPos)

   LOCAL aBDown
   LOCAL oCtrl
   LOCAL resizeDirection
   MEMVAR oDesigner
   MEMVAR crossCursor
   MEMVAR horzCursor
   MEMVAR VertCursor
   MEMVAR handCursor

   HB_SYMBOL_UNUSED(wParam)

   IF oDesigner:addItem != NIL
      hwg_SetCursor(crossCursor)
   ELSE

       aBDown := GetBDown()
       // : LFB
      IF aBDown[BDOWN_OCTRL]:CLASSNAME()="HDIALOG" .OR. aBDown[BDOWN_OCTRL]:CLASSNAME()="HPANEL"
        hwg_SetCursor(handCursor)
        RegionSelect(odlg, aBDown[BDOWN_XPOS], aBDown[BDOWN_YPOS], xpos, ypos)
        RETURN NIL
      ENDIF
      // : END LFB
      IF aBDown[BDOWN_OCTRL] != NIL
         IF aBDown[BDOWN_NBORDER] > 0
            IF aBDown[BDOWN_NBORDER] == 1 .OR. aBDown[BDOWN_NBORDER] == 3
               hwg_SetCursor(horzCursor)
            ELSEIF aBDown[BDOWN_NBORDER] == 2 .OR. aBDown[BDOWN_NBORDER] == 4
               hwg_SetCursor(vertCursor)
            ENDIF
            CtrlResize(aBDown[BDOWN_OCTRL], xPos, yPos)
         ELSE
            CtrlMove(aBDown[BDOWN_OCTRL], xPos, yPos, .T.)
         ENDIF
      ELSE
         IF (oCtrl := GetCtrlSelected(oDlg)) != NIL
            IF (resizeDirection := CheckResize(oCtrl, xPos, yPos)) == 1 .OR. resizeDirection == 3
               hwg_SetCursor(horzCursor)
            ELSEIF resizeDirection == 2 .OR. resizeDirection == 4
               hwg_SetCursor(vertCursor)
            ENDIF
            SetvBDown(NIL, xPos - oCtrl:nLeft, yPos - oCtrl:nTop, 0)
         ENDIF
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION LButtonDown(oDlg, xPos, yPos)

   LOCAL oCtrl := GetCtrlSelected(oDlg)
   LOCAL resizeDirection
   LOCAL flag
   LOCAL i
   MEMVAR oDesigner
   MEMVAR crossCursor
   MEMVAR horzCursor
   MEMVAR VertCursor
   MEMVAR handCursor

    // : LFB
      IF oCtrl == NIL .AND. oDesigner:addItem == NIL
         hwg_SetCursor(handCursor)
         SetBDown(oDlg, xPos, yPos)  //, resizeDirection)
      // fazer o desenho da marca‡Æo
      ENDIF
      // : END LFB

   IF oDesigner:addItem != NIL
      RETURN NIL
   ENDIF

   IF oCtrl != NIL .AND. ;
        (resizeDirection := CheckResize(oCtrl, xPos, yPos)) > 0
      IF resizeDirection == 1 .OR. resizeDirection == 3
         i := AScan(oCtrl:aProp, {|a|Lower(a[1]) == "height"})
         IF i != 0 .AND. (Len(oCtrl:aProp[i]) == 3 .OR. oDesigner:lReport)
            SetBDown(oCtrl, xPos, yPos, resizeDirection)
            hwg_SetCursor(horzCursor)
         ENDIF
      ELSEIF resizeDirection == 2 .OR. resizeDirection == 4
         i := AScan(oCtrl:aProp, {|a|Lower(a[1]) == "width"})
         IF i != 0 .AND. (Len(oCtrl:aProp[i]) == 3 .OR. oDesigner:lReport)
            SetBDown(oCtrl, xPos, yPos, resizeDirection)
            hwg_SetCursor(vertCursor)
         ENDIF
      ENDIF
   ELSE
      IF (oCtrl := CtrlByPos(oDlg, xPos, yPos)) != NIL
         IF oCtrl:Adjust == 0
            SetBDown(oCtrl, xPos, yPos, 0)
         ELSE
            SetCtrlSelected(oCtrl:oParent, oCtrl)
             ENDIF
      ELSEIF (oCtrl := GetCtrlSelected(oDlg)) != NIL
         // : LFB seleciona o DIALOG desmarcar todos
         SetCtrlSelected(oDlg)
         hwg_SetCursor(handCursor)
         // :END LFB
      ENDIF
   ENDIF
   IF oCtrl != NIL .AND. Lower(oCtrl:cClass) == "page"
      i := hwg_Tab_HitTest(oCtrl:handle,,, @flag)
      IF i >= 0 .AND. flag == 4 .OR. flag == 6
         Page_Select(oCtrl, i + 1)
      ENDIF
   ENDIF
   // :LFB
   IF oCtrl != NIL
     statusbarmsg(, "x: " + LTrim(Str(oCtrl:nLeft)) + "  y: " + LTrim(Str(oCtrl:nTop)), ;
         "w: " + LTrim(Str(oCtrl:nWidth)) + "  h: " + LTrim(Str(oCtrl:nHeight)))
   ENDIF
   // :ENDLFB

RETURN NIL

STATIC FUNCTION LButtonUp(oDlg, xPos, yPos, nShift)

   LOCAL aBDown
   LOCAL oCtrl
   LOCAL oContainer
   LOCAL i
   LOCAL aProp
   LOCAL j
   LOCAL name
   MEMVAR oDesigner

   HB_SYMBOL_UNUSED(nShift)

   IF oDesigner:addItem == NIL
      aBDown := GetBDown()
      oCtrl := aBDown[BDOWN_OCTRL]
      // :LFB - selecionar objetos com o mouse
      IF oCtrl:CLASSNAME() = "HDIALOG" .OR. oCtrl:CLASSNAME() = "HPANEL"
        selsobjetos(odlg, aBDown[BDOWN_XPOS], aBDown[BDOWN_YPOS], xpos, ypos)
        hwg_InvalidateRect(odlg:handle, 1, ;
              0, 0, oDlg:nWidth, oDlg:nHeight)
        SetBDown(NIL, 0, 0, 0)
         RETURN -1
      endif
      // :END LFB
      IF oCtrl != NIL
         IF aBDown[BDOWN_NBORDER] > 0
            CtrlResize(oCtrl, xPos, yPos)
         ELSE
            // writelog("LButtonUp-1 " + Str(xpos) + Str(abdown[2]) + Str(ypos) + Str(abdown[3]))
            CtrlMove(oCtrl, xPos, yPos, .T.)
            Container(oDlg, oCtrl)
         ENDIF
         SetBDown(NIL, 0, 0, 0)
      ENDIF
   ELSE
      oContainer := CtrlByPos(oDlg, xPos, yPos)
      IF oDesigner:addItem:classname() == "HCONTROLGEN"
         aProp := AClone(oDesigner:addItem:aProp)
         j := 0
         FOR i := Len(aProp) TO 1 STEP -1
            IF (name := Lower(aProp[i, 1])) == "name" .OR. name == "varname"
               ADel(aProp, i)
               j ++
            ELSEIF name == "left"
               aProp[i, 2] := LTrim(Str(IIf(oDesigner:lReport, Round(xPos / oDlg:oParent:oParent:oParent:nKoeff, 1), xPos)))
            ELSEIF name == "top"
               aProp[i, 2] := LTrim(Str(IIf(oDesigner:lReport, Round(yPos / oDlg:oParent:oParent:oParent:nKoeff, 1), yPos)))
            ENDIF
            IF oDesigner:lReport
               IF name == "right" .OR. name == "bottom"
                  aProp[i, 2] := "0"
               ENDIF
            ENDIF
         NEXT
         IF j > 0
            ASize(aProp, Len(aProp) - j)
         ENDIF
         oCtrl := HControlGen():New(oDlg, oDesigner:addItem:oXMLDesc, aProp)
         IF oDesigner:lReport
            oCtrl:SetCoor("Right", oCtrl:nLeft + oCtrl:nWidth - 1)
            oCtrl:SetCoor("Bottom", oCtrl:nTop + oCtrl:nHeight - 1)
         ENDIF
      ELSE
         IF oDesigner:lReport
            oCtrl := HControlGen():New(oDlg, oDesigner:addItem, { ;
              {"Left", LTrim(Str(Round(xPos / oDlg:oParent:oParent:oParent:nKoeff, 1)))}, ;
              {"Top", LTrim(Str(Round(yPos / oDlg:oParent:oParent:oParent:nKoeff, 1)))}})
            oCtrl:SetCoor("Right", oCtrl:nLeft + oCtrl:nWidth - 1)
            oCtrl:SetCoor("Bottom", oCtrl:nTop + oCtrl:nHeight - 1)
         ELSE
            oCtrl := HControlGen():New(oDlg, oDesigner:addItem, { ;
              {"Left", LTrim(Str(xPos))}, ;
              {"Top", LTrim(Str(yPos))}})
         ENDIF
      ENDIF
      IF oContainer != NIL .AND. ( ;
          oCtrl:nLeft + oCtrl:nWidth <= oContainer:nLeft + oContainer:nWidth .AND. ;
          oCtrl:nTop + oCtrl:nHeight <= oContainer:nTop + oContainer:nHeight)
         oContainer:AddControl(oCtrl)
         oCtrl:oContainer := oContainer
         IF Lower(oContainer:cClass) == "page"
            oCtrl:nPage := hwg_GetCurrentTab(oContainer:handle)
            IF oCtrl:nPage == 0
               oCtrl:nPage ++
            ENDIF
         ENDIF
      ENDIF

      SetCtrlSelected(oDlg, oCtrl)
      IF oDesigner:lReport
         oDlg:oParent:oParent:oParent:lChanged := .T.
      ELSE
         oDlg:oParent:lChanged := .T.
      ENDIF
      IF oDesigner:oBtnPressed != NIL
         oDesigner:oBtnPressed:Release()
      ENDIF
      oDesigner:addItem := NIL
      IF hwg_IsCheckedMenuItem(oDesigner:oMainWnd:handle, 1011)
         AdjustCtrl(oCtrl)
      ENDIF
   ENDIF

RETURN -1

STATIC FUNCTION RButtonUp(oDlg, xPos, yPos)

   LOCAL oCtrl
   MEMVAR oDesigner

   IF oDesigner:addItem == NIL
      IF (oCtrl := CtrlByPos(oDlg, xPos, yPos)) != NIL
         SetCtrlSelected(oDlg, oCtrl)
         IF Lower(oCtrl:cClass) == "page"
            oDesigner:oTabMenu:Show(oDlg, xPos, yPos, .T.)
         ELSE
            IF oDesigner:lReport .AND. Lower(oCtrl:cClass) $ "hline.vline" ;
               .AND. oCtrl:oContainer != NIL .AND. Lower(oCtrl:oContainer:cClass) == "box"
               hwg_EnableMenuItem(oDesigner:oCtrlMenu, 1030, .T.)
               IF oCtrl:lEmbed
                  hwg_CheckMenuItem(oDesigner:oCtrlMenu, 1030, .T.)
               ELSE
                  hwg_CheckMenuItem(oDesigner:oCtrlMenu, 1030, .F.)
               ENDIF
            ELSE
               hwg_EnableMenuItem(oDesigner:oCtrlMenu, 1030, .F.)
            ENDIF
            oDesigner:oCtrlMenu:Show(IIf(oDesigner:lReport, oDlg:oParent:oParent, oDlg), xPos, yPos, .T.)
         ENDIF
      ELSE
         oDesigner:oDlgMenu:Show(IIf(oDesigner:lReport, oDlg:oParent:oParent, oDlg), xPos, yPos, .T.)
      ENDIF
   ENDIF

RETURN NIL

FUNCTION Container(oDlg, oCtrl)

   LOCAL i
   LOCAL nLeft := oCtrl:nLeft
   LOCAL oContainer

   oCtrl:nLeft := 9999
   oContainer := CtrlByRect(oDlg, nLeft, oCtrl:nTop, nLeft + oCtrl:nWidth, oCtrl:nTop + oCtrl:nHeight)
   oCtrl:nLeft := nLeft

   IF oCtrl:oContainer != NIL
      IF oContainer != NIL .AND. oContainer:handle == oCtrl:oContainer:handle
         RETURN NIL
      ELSE
         i := AScan(oCtrl:oContainer:aControls, {|o|o:handle == oCtrl:handle})
         IF i != 0
            ADel(oCtrl:oContainer:aControls, i)
            ASize(oCtrl:oContainer:aControls, Len(oCtrl:oContainer:aControls) - 1)
         ENDIF
         oCtrl:oContainer := NIL
         oCtrl:lEmbed := .F.
      ENDIF
   ENDIF

   IF oContainer != NIL
      oContainer:AddControl(oCtrl)
      oCtrl:oContainer := oContainer
      IF Lower(oContainer:cClass) == "page"
         oCtrl:nPage := hwg_GetCurrentTab(oContainer:handle)
         IF oCtrl:nPage == 0
            oCtrl:nPage ++
         ENDIF
      ENDIF
      IF (i := AScan(oDlg:aControls, {|o|o:handle == oCtrl:handle})) ;
         < AScan(oDlg:aControls, {|o|o:handle == oContainer:handle})
         hwg_DestroyWindow(oCtrl:handle)
         ADel(oDlg:aControls, i)
         oDlg:aControls[Len(oDlg:aControls)] := oCtrl
         oCtrl:lInit := .F.
         oCtrl:Activate()
      ENDIF
   ENDIF

RETURN NIL

STATIC FUNCTION CtrlByRect(oDlg, xPos1, yPos1, xPos2, yPos2)

   LOCAL i := 1
   LOCAL j := 0
   LOCAL aControls := oDlg:aControls
   LOCAL alen := Len(aControls)
   LOCAL oCtrl

   DO WHILE i <= alen
     IF !aControls[i]:lHide .AND. xPos1 >= aControls[i]:nLeft .AND. ;
           xPos2 <= (aControls[i]:nLeft + aControls[i]:nWidth) .AND. ;
           yPos1 >= aControls[i]:nTop .AND.                         ;
           yPos2 <= (aControls[i]:nTop + aControls[i]:nHeight)
        oCtrl := aControls[i]
        IF j == 0
           j := i
        ENDIF
        aControls := oCtrl:aControls
        i := 0
        alen := Len(aControls)
     ENDIF
     i ++
   ENDDO
   IF oCtrl != NIL
      aControls := oDlg:aControls
      alen := Len(aControls)
      i := j + 1
      DO WHILE i <= alen
         IF !aControls[i]:lHide .AND. xPos1 >= aControls[i]:nLeft .AND. ;
               xPos2 <= (aControls[i]:nLeft + aControls[i]:nWidth) .AND. ;
               yPos1 >= aControls[i]:nTop .AND.                         ;
               yPos2 <= (aControls[i]:nTop + aControls[i]:nHeight) .AND. ;
               aControls[i]:nLeft > oCtrl:nLeft .AND. aControls[i]:nTop > oCtrl:nTop
            oCtrl := aControls[i]
            EXIT
         ENDIF
         i ++
      ENDDO
   ENDIF
RETURN oCtrl

STATIC FUNCTION CtrlByPos(oDlg, xPos, yPos)

   LOCAL i := 1
   LOCAL j := 0
   LOCAL aControls := oDlg:aControls
   LOCAL alen := Len(aControls)
   LOCAL oCtrl

   // writelog("CtrlByPos:" + Str(xpos) + Str(ypos))
   DO WHILE i <= alen
     // writelog("> " + aControls[i]:cclass + " " + Str(aControls[i]:nLeft) + " " + Str(aControls[i]:nTop) + Str(aControls[i]:nWidth) + Str(aControls[i]:nHeight))
     IF !aControls[i]:lHide .AND. xPos >= aControls[i]:nLeft .AND. ;
           xPos < (aControls[i]:nLeft + aControls[i]:nWidth) .AND. ;
           yPos >= aControls[i]:nTop .AND.                         ;
           yPos < (aControls[i]:nTop + aControls[i]:nHeight)
        oCtrl := aControls[i]
        // writelog("> " + aControls[i]:cclass + " " + Str(aControls[i]:nLeft) + " " + Str(aControls[i]:nTop) + Str(aControls[i]:nWidth) + Str(aControls[i]:nHeight))
        IF j == 0
           j := i
        ENDIF
        aControls := oCtrl:aControls
        i := 0
        alen := Len(aControls)
     ENDIF
     i ++
   ENDDO
   IF oCtrl != NIL
      aControls := oDlg:aControls
      alen := Len(aControls)
      i := j + 1
      DO WHILE i <= alen
         IF !aControls[i]:lHide .AND. xPos >= aControls[i]:nLeft .AND. ;
               xPos < (aControls[i]:nLeft + aControls[i]:nWidth) .AND. ;
               yPos >= aControls[i]:nTop .AND.                         ;
               yPos < (aControls[i]:nTop + aControls[i]:nHeight) .AND. ;
               aControls[i]:nLeft > oCtrl:nLeft .AND. aControls[i]:nTop > oCtrl:nTop
            oCtrl := aControls[i]
            EXIT
         ENDIF
         i ++
      ENDDO
   ENDIF
RETURN oCtrl

STATIC FUNCTION FrmSort(oForm, aControls, lSub)

   LOCAL i
   LOCAL nLeft
   LOCAL nTop
   LOCAL lSorted := .T.
   LOCAL aTabs

   FOR i := 1 TO Len(aControls)
      IF i > 1 .AND. aControls[i]:nTop * 10000 + aControls[i]:nLeft < nTop * 10000 + nLeft
         lSorted := .F.
         EXIT
      ENDIF
      nLeft := aControls[i]:nLeft
      nTop  := aControls[i]:nTop
   NEXT

   IF !lSorted .AND. (lSub == NIL .OR. !lSub)
      FOR i := Len(aControls) TO 1 STEP -1
         hwg_DestroyWindow(aControls[i]:handle)
      NEXT
   ENDIF
   IF !lSorted
      /*
      IF oDesigner:lReport
         ASort(aControls, , , {|z, y|Round(z:nTop / oForm:nKoeff, 1) * 10000 + Round(z:nLeft / oForm:nKoeff, 1) < Round(y:nTop / oForm:nKoeff, 1) * 10000 + Round(y:nLeft / oForm:nKoeff, 1)})
      ELSE
      */
      ASort(aControls, , , {|z, y|z:nTop * 10000 + z:nLeft < y:nTop * 10000 + y:nLeft})
      // ENDIF
   ENDIF
   FOR i := 1 TO Len(aControls)
      IF !Empty(aControls[i]:aControls)
         FrmSort(oForm, aControls[i]:aControls, .T.)
      ENDIF
   NEXT
   IF !lSorted .AND. (lSub == NIL .OR. !lSub)
      FOR i := 1 TO Len(aControls)
         aControls[i]:lInit := .F.
         aControls[i]:Activate()
         aControls[i]:lHide := .F.
      NEXT
      FOR i := 1 TO Len(aControls)
         IF Lower(aControls[i]:cClass) == "page" .AND. ;
                   (aTabs := aControls[i]:GetProp("Tabs")) != NIL .AND. ;
                   !Empty(aTabs)
            Page_Upd(aControls[i], aTabs)
            Page_Select(aControls[i], 1, .T.)
         ENDIF
      NEXT
   ENDIF
RETURN NIL

FUNCTION DoPreview()

   LOCAL oForm
   LOCAL cTemp1
   LOCAL cTemp2
   LOCAL lc := .F.
   LOCAL oTmpl
   MEMVAR oDesigner

   IF HFormGen():oDlgSelected == NIL
      hwg_MsgStop("No Form in use!", "Designer")
      RETURN NIL
   ENDIF

   oForm := HFormGen():oDlgSelected:oParent
   IF oForm:lChanged .OR. oForm:type > 1 .OR. oForm:path == NIL
      lc := .T.
      cTemp1 := oForm:filename; cTemp2 := oForm:path
      oForm:filename := "__tmp.xml"
      oForm:path     := ""
      oForm:type     := 1
      oForm:lChanged := .T.
      oForm:Save()
   ENDIF

   oTmpl := IIf(oDesigner:lReport, HRepTmpl():Read(oForm:path + oForm:filename), ;
               HFormTmpl():Read(oForm:path + oForm:filename))

   IF lc
      oForm:filename := cTemp1
      oForm:path     := cTemp2
      oForm:lChanged := .T.
   ENDIF

   IF oDesigner:lReport
      oTmpl:Print(, .T.)
   ELSE
      oTmpl:Show()
   ENDIF
   oTmpl:Close()

RETURN NIL

FUNCTION _CHR(n)
RETURN CHR(n)

