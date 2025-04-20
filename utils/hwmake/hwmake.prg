//
// $Id: hwmake.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Win32 GUI library
//
// HwMake
// Copyright 2004 Sandro R. R. Freire <sandrorrfreire@yahoo.com.br>
// www - http://www.hwgui.net
//

#include "windows.ch"
#include "guilib.ch"

#DEFINE  ID_EXENAME     10001
#DEFINE  ID_LIBFOLDER   10002
#DEFINE  ID_INCFOLDER   10003
#DEFINE  ID_PRGFLAG     10004
#DEFINE  ID_CFLAG       10005
#DEFINE  ID_PRGMAIN     10006

#ifndef __XHARBOUR__

   ANNOUNCE HB_GTSYS
   REQUEST HB_GT_GUI_DEFAULT

   #xcommand TRY              => s_bError := errorBlock({|oErr|break(oErr)}) ;;
                                 BEGIN SEQUENCE
   #xcommand CATCH [<!oErr!>] => errorBlock(s_bError) ;;
                                 RECOVER [USING <oErr>] <-oErr-> ;;
                                 errorBlock(s_bError)
   #command FINALLY           => ALWAYS
   
#endif

FUNCTION Main
Local oFont
Local aBrowse1, aBrowse2, aBrowse3, aBrowse4
LOCAL oPasta  := DiskName() + ":\" + CurDir() + "\"
Local vGt1 := Space(80)
Local vGt2 := Space(80)
Local vGt3 := Space(80)
Local vGt4 := Space(80)
Local vGt5 := Space(80)
Local vGt6 := Space(80)
Local aFiles1 := {""}, aFiles2 := {""}, aFiles3 := {""}, aFiles4 := {""}

Local oBtBuild
Local oBtExit 
Local oBtOpen 
Local oBtSave 

Private cDirec := DiskName() + ":\" + CurDir() + "\"

IF !File(cDirec + "hwmake.ini")
  hwg_WriteIni("Config", "Dir_HwGUI", "C:\HwGUI", cDirec + "hwmake.ini")
  hwg_WriteIni("Config", "Dir_HARBOUR", "C:\xHARBOUR", cDirec + "hwmake.ini")
  hwg_WriteIni("Config", "Dir_BCC55", "C:\BCC55", cDirec + "hwmake.ini")
  hwg_WriteIni("Config", "Dir_OBJ", "OBJ", cDirec + "hwmake.ini")
ENDIF

Private oImgNew  := hbitmap():addResource("NEW")
Private oImgExit := hbitmap():addResource("EXIT")
Private oImgBuild := hbitmap():addResource("BUILD")
Private oImgSave := hbitmap():addResource("SAVE")
Private oImgOpen := hbitmap():addResource("OPEN")
Private oStatus
Private lSaved := .F.
Private oBrowse1, oBrowse2, oBrowse3
Private oDlg
Private oExeName, oLabel1, oLibFolder, oLabel2, oIncFolder, oLabel3, oPrgFlag, oLabel4, oCFlag, oLabel5, oMainPrg, oLabel6, oTab
Private oIcon := HIcon():AddResource("PIM")

   PREPARE FONT oFont NAME "MS Sans Serif" WIDTH 0 HEIGHT -12

   INIT DIALOG oDlg CLIPPER NOEXIT TITLE "HwGUI Build Projects for BCC55" ;
        AT 213, 195 SIZE 513, 295  font oFont ICON oIcon

   ADD STATUS oStatus TO oDlg ;
       PARTS oDlg:nWidth - 160, 150

   MENU OF oDlg
      MENU TITLE "&File"
         MENUITEM "&Build" ACTION BuildApp()
         MENUITEM "&Open"  ACTION ReadBuildFile()
         MENUITEM "&Save"  ACTION  SaveBuildFile() 
         SEPARATOR
         MENUITEM "&Exit"  ACTION EndDialog() 
      ENDMENU
      MENU TITLE "&Help"        
         MENUITEM "&About" ACTION OpenAbout()
         MENUITEM "&Version HwGUI" ACTION hwg_MsgInfo(HwG_Version())
      ENDMENU
   ENDMENU            
   
   @ 14, 16 TAB oTAB ITEMS {} SIZE 391, 242

   BEGIN PAGE "Config" Of oTAB
      @  20, 44 SAY oLabel1 CAPTION "Exe Name" TRANSPARENT SIZE 80, 22
      @ 136, 44 GET oExeName VAR vGt1 ID ID_EXENAME  SIZE 206, 24

      @  20, 74 SAY oLabel2 CAPTION "Lib Folder" TRANSPARENT SIZE 80, 22
      @ 136, 74 GET oLibFolder  VAR vGt2 ID ID_LIBFOLDER SIZE 234, 24

      @  20, 104 SAY oLabel3 CAPTION "Include Folder" TRANSPARENT SIZE 105, 22
      @ 136, 104 GET oIncFolder VAR vGt3 ID ID_INCFOLDER   SIZE 234, 24

      @  20, 134 SAY oLabel4 CAPTION "PRG Flags" TRANSPARENT SIZE 80, 22
      @ 136, 134 GET oPrgFlag VAR vGt4 ID ID_PRGFLAG  SIZE 234, 24

      @  20, 164 SAY oLabel5 CAPTION "C Flags" TRANSPARENT SIZE 80, 22
      @ 136, 164 GET oCFlag VAR vGt5  ID ID_CFLAG SIZE 234, 24

      @  20, 194 SAY oLabel6 CAPTION "Main PRG" TRANSPARENT SIZE 80, 22
      @ 136, 194 GET oMainPrg VAR vGt6 ID ID_PRGMAIN  SIZE 206, 24
      @ 347, 194 OWNERBUTTON    SIZE 24, 24   ;
          ON CLICK {||searchFileName("xBase Files *.prg ", oMainPrg, "*.prg")};//       FLAT;
          TEXT "..." ;//BITMAP "SEARCH" FROM RESOURCE TRANSPARENT COORDINATES 0, 0, 0, 0 ;
          TOOLTIP "Search main file" 

   END PAGE of oTAB
   BEGIN PAGE "Prg (Files)" of oTAB
      @ 21, 29 BROWSE oBrowse1 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse1, "*.prg")};
 	            STYLE WS_VSCROLL + WS_HSCROLL SIZE 341, 170  
      hwg_CreateArList(oBrowse1, aFiles1)
      obrowse1:acolumns[1]:heading := "File Names"
      obrowse1:acolumns[1]:length := 50
      oBrowse1:bcolorSel := hwg_VColor("800080")
      oBrowse1:ofont := HFont():Add("Arial", 0, -12)
      @ 10, 205 BUTTON "Add"     SIZE 60, 25  on click {||SearchFile(oBrowse1, "*.prg")}  
      @ 70, 205 BUTTON "Delete"  SIZE 60, 25  on click {||BrwdelIten(oBrowse1)}

   END PAGE of oTAB
   BEGIN PAGE "C (Files)" of oTAB
      @ 21, 29 BROWSE oBrowse2 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse2, "*.c")};
 	            STYLE WS_VSCROLL + WS_HSCROLL SIZE 341, 170
      hwg_CreateArList(oBrowse2, aFiles2)
      obrowse2:acolumns[1]:heading := "File Names"
      obrowse2:acolumns[1]:length := 50
      oBrowse2:bcolorSel := hwg_VColor("800080")
      oBrowse2:ofont := HFont():Add("Arial", 0, -12)
      @ 10, 205 BUTTON "Add"     SIZE 60, 25  on click {||SearchFile(oBrowse2, "*.c")}  
      @ 70, 205 BUTTON "Delete"  SIZE 60, 25  on click {||BrwdelIten(oBrowse2)}
   END PAGE of oTAB
   BEGIN PAGE "Lib (Files)" of oTAB
      @ 21, 29 BROWSE oBrowse3 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse3, "*.lib")};
 	            STYLE WS_VSCROLL + WS_HSCROLL SIZE 341, 170
      hwg_CreateArList(oBrowse3, aFiles3)
      obrowse3:acolumns[1]:heading := "File Names"
      obrowse3:acolumns[1]:length := 50
      oBrowse3:bcolorSel := hwg_VColor("800080")
      oBrowse3:ofont := HFont():Add("Arial", 0, -12)
      @ 10, 205 BUTTON "Add"     SIZE 60, 25  on click {||SearchFile(oBrowse3, "*.lib")}  
      @ 70, 205 BUTTON "Delete"  SIZE 60, 25  on click {||BrwdelIten(oBrowse3)}
   END PAGE of oTAB
   BEGIN PAGE "Resource (Files)" of oTAB
      @ 21, 29 BROWSE oBrowse4 ARRAY of oTAB ON CLICK {||SearchFile(oBrowse3, "*.rc")};
 	            STYLE WS_VSCROLL + WS_HSCROLL SIZE 341, 170  
      hwg_CreateArList(oBrowse4, aFiles4)
      obrowse4:acolumns[1]:heading := "File Names"
      obrowse4:acolumns[1]:length := 50
      oBrowse4:bcolorSel := hwg_VColor("800080")
      oBrowse4:ofont := HFont():Add("Arial", 0, -12)
      @ 10, 205 BUTTON "Add"     SIZE 60, 25  on click {||SearchFile(oBrowse4, "*.rc")}  
      @ 70, 205 BUTTON "Delete"  SIZE 60, 25  on click {||BrwdelIten(oBrowse4)}
   END PAGE of oTAB
   
   @ 419, 20 BUTTONex oBtBuild CAPTION "Build" BITMAP oImgBuild:Handle on Click {||BuildApp()}      SIZE 88, 52
   @ 419, 80 BUTTONex oBtExit  CAPTION "Exit"  BITMAP oImgExit:Handle  on Click {||EndDialog()}     SIZE 88, 52
   @ 419, 140 BUTTONex oBtOpen  CAPTION "Open"  BITMAP oImgOpen:Handle  on Click {||ReadBuildFile()} SIZE 88, 52
   @ 419, 200 BUTTONex oBtSave  CAPTION "Save"  BITMAP oImgSave:Handle  on Click {||SaveBuildFile()} SIZE 88, 52
 
   ACTIVATE DIALOG oDlg

RETURN

STATIC FUNCTION SearchFile(oBrow, oFile)
Local oTotReg := {}, i
Local aSelect := hwg_SelectMultipleFiles("xBase Files (" + oFile + ")", oFile)
IF len(aSelect) == 0
   RETURN NIL
ENDIF
IF Len(oBrow:aArray) == 1 .AND. obrow:aArray[1] == ""
   obrow:aArray := {}
ENDIF
For i := 1 to Len(oBrow:aArray)
  AADD(oTotReg, oBrow:aArray[i])
Next
For i := 1 to Len(aSelect)
  AADD(oTotReg, aSelect[i])
Next
obrow:aArray := oTotReg
obrow:refresh()
RETURN NIL

STATIC FUNCTION SearchFileName(nName, oGet, oFile)
Local oTextAnt := oGet:GetText()
Local fFile := hwg_SelectFile(nName + " (" + oFile + ")", oFile,,, .T.)
IF !Empty(oTextAnt)
   fFile := oTextAnt //
ENDIF
oGet:SetText(fFile)
oGet:Refresh()
RETURN NIL


FUNCTION ReadBuildFile()
Local cLibFiles, oBr1 := {}, oBr2 := {}, oBr3 := {}, oBr4 := {}, oSel1, oSel2, oSel3, i, oSel4
Local aPal := ""
Local cFolderFile := hwg_SelectFile("HwGUI File Build (*.bld)", "*.bld")
IF empty(cFolderFile)
   RETURN NIL
ENDIF
oStatus:SetTextPanel(1, cFolderFile)
oExeName:SetText(hwg_GetIni("Config", "ExeName", , cFolderFile))
oLibFolder:SetText(hwg_GetIni("Config", "LibFolder", , cFolderFile))
oIncFolder:SetText(hwg_GetIni("Config", "IncludeFolder", , cFolderFile))
oPrgFlag:SetText(hwg_GetIni("Config", "PrgFlags", , cFolderFile))
oCFlag:SetText(hwg_GetIni("Config", "CFlags", , cFolderFile))
oMainPrg:SetText(hwg_GetIni("Config", "PrgMain", , cFolderFile))

For i := 1 to 300
    oSel1 := hwg_GetIni("FilesPRG", Alltrim(Str(i)), , cFolderFile)
    IF !empty(oSel1) //.OR. oSel1#NIL
        AADD(oBr1, oSel1)
    ENDIF
Next


For i := 1 to 300
    oSel2 := hwg_GetIni("FilesC", Alltrim(Str(i)), , cFolderFile)
    IF !empty(oSel2) //.OR. oSel2#NIL
        AADD(oBr2, oSel2)
    ENDIF
Next

For i := 1 to 300
    oSel3 := hwg_GetIni("FilesLIB", Alltrim(Str(i)), , cFolderFile)
    IF !empty(oSel3) //.OR. oSel3#NIL
        AADD(oBr3, oSel3)
    ENDIF
Next

For i := 1 to 300
    oSel4 := hwg_GetIni("FilesRES", Alltrim(Str(i)), , cFolderFile)
    IF !empty(oSel4) //.OR. oSel4#NIL
        AADD(oBr4, oSel4)
    ENDIF
Next

oBrowse1:aArray := oBr1
oBrowse2:aArray := oBr2
oBrowse3:aArray := oBr3
oBrowse4:aArray := oBr4
oBrowse1:Refresh()
oBrowse2:Refresh()
oBrowse3:Refresh()
oBrowse4:Refresh()

RETURN NIL

*-------------------------------------------------------------------------------------
FUNCTION cPathNoFile(cArq)
*-------------------------------------------------------------------------------------
Local i
Local cDest := ""
Local cLetra
Local cNome := cFileNoPath(cArq)

cDest := AllTrim(StrTran(cArq, cNome, ""))

IF SubStr(cDest, -1, 1) == "\"
   cDest := SubStr(cDest, 1, Len(cDest) - 1)
ENDIF

RETURN cDest
*-------------------------------------------------------------------------------------
FUNCTION cFileNoExt(cArq)
*-------------------------------------------------------------------------------------
Local n
n := At(".", cArq)
IF n > 0
   RETURN SubStr(cArq, 1, n - 1)
ENDIF

RETURN cArq   

FUNCTION cFileNoPath(cArq)
Local i
Local cDest := ""
Local cLetra

For i := 1 to Len(cArq)
   
   cLetra := SubStr(cArq, i, 1)
   IF cLetra == "\"
      cDest := ""
   ELSE
      cDest += cLetra
   ENDIF
   
Next

RETURN cDest

FUNCTION SaveBuildFile()
Local cLibFiles, i, oNome, g
Local cFolderFile := hwg_SaveFile("*.bld", "HwGUI File Build (*.bld)", "*.bld")
IF empty(cFolderFile)
   RETURN NIL
ENDIF
IF file(cFolderFile)
   IF (hwg_MsgYesNo("File " + cFolderFile + " EXIT ..Replace?"))
     Erase(cFolderFile)
   ELSE
     hwg_MsgInfo("No file SAVED.", "HwMake")
     RETURN NIL
   ENDIF
ENDIF
hwg_WriteIni("Config", "ExeName", oExeName:GetText(), cFolderFile)
hwg_WriteIni("Config", "LibFolder", oLibFolder:GetText(), cFolderFile)
hwg_WriteIni("Config", "IncludeFolder", oIncFolder:GetText(), cFolderFile)
hwg_WriteIni("Config", "PrgFlags", oPrgFlag:GetText(), cFolderFile)
hwg_WriteIni("Config", "CFlags", oCFlag:GetText(), cFolderFile)
hwg_WriteIni("Config", "PrgMain", oMainPrg:GetText(), cFolderFile)
oNome := ""

IF Len(oBrowse1:aArray) >= 1
   for i := 1 to Len(oBrowse1:aArray)

      IF !empty(oBrowse1:aArray[i])

         hwg_WriteIni("FilesPRG", Alltrim(Str(i)), oBrowse1:aArray[i], cFolderFile)

      eNDiF

    Next

ENDIF

IF Len(oBrowse2:aArray) >= 1
   for i := 1 to Len(oBrowse2:aArray)
      IF !empty(oBrowse2:aArray[i])
         hwg_WriteIni("FilesC", Alltrim(Str(i)), oBrowse2:aArray[i], cFolderFile)
     ENDIF
   Next
ENDIF

IF Len(oBrowse3:aArray) >= 1
   for i := 1 to Len(oBrowse3:aArray)
      IF !empty(oBrowse3:aArray[i])
         hwg_WriteIni("FilesLIB", Alltrim(Str(i)), oBrowse3:aArray[i], cFolderFile)
      ENDIF
   Next
ENDIF

IF Len(oBrowse4:aArray) >= 1
   for i := 1 to Len(oBrowse4:aArray)
      IF !empty(oBrowse4:aArray[i])
         hwg_WriteIni("FilesRES", Alltrim(Str(i)), oBrowse4:aArray[i], cFolderFile)
     ENDIF
   Next
ENDIF

hwg_Msginfo("File " + cFolderFile + " saved", "HwGUI Build", "HwMake")
RETURN NIL

FUNCTION BuildApp() 
Local cExeHarbour
Local cHwGUI, cHarbour, cBCC55, cObj
LOCAL cObjFileAttr, nObjFileSize
LOCAL dObjCreateDate, nObjCreateTime
LOCAL dObjChangeDate, nObjChangeTime
Local cObjName, I
LOCAL cPrgFileAttr, nPrgFileSize
LOCAL dPrgCreateDate, nPrgCreateTime
LOCAL dPrgChangeDate, nPrgChangeTime
Local cPrgName
Local lAll := hwg_MsgYesNo("Build All Fontes?", "Attention")
Local lCompile
Local cList := ""
Local cMake
Local CRLF := Chr(13) + Chr(10)
Local cListObj := ""
Local cListRes := ""
Local cMainPrg := AllTrim(Lower(cFileNoPath(cFileNoExt(oMainPrg:GetText()))))
Local cPathFile
Local cRun 
Local cNameExe
Local nRep
Local cLogErro
Local cErrText
Local lEnd

cPathFile := cPathNoFile(oMainPrg:GetText())
IF !Empty(cPathFile)
   DirChange(cPathFile)
ENDIF

IF File(cDirec + "hwmake.Ini")
   cHwGUI  := Lower(AllTrim(hwg_GetIni("Config", "DIR_HwGUI", , cDirec + "hwmake.Ini")))
   cHarbour := Lower(AllTrim(hwg_GetIni("Config", "DIR_HARBOUR", , cDirec + "hwmake.Ini")))
   cBCC55  := Lower(AllTrim(hwg_GetIni("Config", "DIR_BCC55", , cDirec + "hwmake.Ini")))
   cObj    := Lower(AllTrim(hwg_GetIni("Config", "DIR_OBJ", , cDirec + "hwmake.Ini")))
ELSE
   cHwGUI  := "c:\hwgui"
   cHarbour := "c:\xharbour"
   cBCC55  := "c:\bcc55"
   cObj    := "obj"
ENDIF

cObj := Lower(AllTrim(cObj))
Makedir(cObj)

cExeHarbour := Lower(cHarbour + "\bin\harbour.exe")
//IF !File(cExeHarbour)
//   hwg_MsgInfo("Not exist " + cExeHarbour + "!!")
//   RETURN NIL
//ENDIF

//PrgFiles
i := Ascan(oBrowse1:aArray, {|x|At(cMainPrg, x) > 0})
IF i == 0
   AAdd(oBrowse1:aArray, AllTrim(oMainPrg:GetText()))
ENDIF

For Each i in oBrowse1:aArray 
   cObjName := cObj + "\" + cFileNoPath(cFileNoExt(i)) + ".c"
   cPrgName := i
   lCompile := .F.
   IF lAll
      lCompile := .T.
   ELSE
      IF File(cObjName)
         FileStats(cObjName, @cObjFileAttr, @nObjFileSize, @dObjCreateDate, @nObjCreateTime, @dObjChangeDate, @nObjChangeTime)
         FileStats(cPrgName, @cPrgFileAttr, @nPrgFileSize, @dPrgCreateDate, @nPrgCreateTime, @dPrgChangeDate, @nPrgChangeTime)
         IF dObjChangeDate <= dPrgChangeDate .AND.  nObjChangeTime <  nPrgChangeTime
            lCompile := .T.
         ENDIF
      ELSE
         lCompile := .T.
      ENDIF
   ENDIF

   IF lCompile
      cLogErro := cFileNoPath(cFileNoExt(cObjName)) + ".log"
      FErase(cLogErro)
      FErase(cObjName)
      FErase(cFileNoExt(cObjName) + ".obj")
      IF ExecuteCommand(cExeHarbour, cPrgName + " -o" + cObjName + " " + AllTrim(oPrgFlag:GetText()) + " -n -i" + cHarbour + "\include;" + cHwGUI + "\include" + IIf(!Empty(AllTrim(oIncFolder:GetText())), ";" + AllTrim(oIncFolder:GetText()), ""), cFileNoExt(cObjName) + ".log") != 0

         cErrText := Memoread(cLogErro)

         lEnd     := "C2006" $ cErrText .OR. "No code generated" $ cErrText .OR. "Error E" $ cErrText .OR. "Error F" $ cErrText
         IF lEnd
            ErrorPreview(Memoread(cLogErro))
            RETURN NIL
         ELSE
            IF File(cLogErro)
             //  FErase(cLogErro)
            ENDIF
         ENDIF
         RETURN NIL

      ENDIF

   ENDIF
   cList    += cObjName + " " 
   IF At(cMainPrg, cObjName) == 0
      cListObj += StrTran(cObjName, ".c", ".obj") + " " + CRLF
   ENDIF
   cRun := " -v -y -c " + AllTrim(oCFlag:GetText()) + " -O2 -tW -M -I" + cHarbour + "\include;" + cHwGUI + "\include;" + cBCC55 + "\include " + "-o" + StrTran(cObjName, ".c", ".obj") + " " + cObjName
   IF ExecuteCommand(cBCC55 + "\bin\bcc32.exe", cRun) != 0
      hwg_MsgInfo("No Created Object files!", "HwMake")
      RETURN NIL
   ENDIF

Next

cListObj := "c0w32.obj +" + CRLF + cObj + "\" + cMainPrg + ".obj, +" + CRLF + cListObj

FOR EACH i in oBrowse2:aArray     
   cList += i + " "
   cListObj += cObj + "\" + cFileNoPath(cFilenoExt(i)) + ".obj"
Next

                        
//ResourceFiles
For Each i in oBrowse4:aArray     
   IF ExecuteCommand(cBCC55 + "\bin\brc32", "-r " + cFileNoExt(i) + " -fo" + cObj + "\" + cFileNoPath(cFileNoExt(i))) != 0
      hwg_MsgInfo("Error in Resource File " + i + "!", "HwMake")
      RETURN NIL
   ENDIF
   cListRes += cObj + "\" + cFileNoPath(cFileNoExt(i)) + ".res +" + CRLF
Next
IF Len(cListRes) > 0
   cListRes := SubStr(cListRes, 1, Len(cListRes) - 3)
ENDIF
cMake := cListObj
cNameExe := AllTrim(lower(oExeName:GetText()))
IF At(".exe", cNameExe) == 0
   cNameExe += ".exe"
ENDIF

cMake += cNameExe + ", + " + CRLF
cMake += cFileNoExt(oExeName:GetText()) + ".map, + " + CRLF
cMake += RetLibrary(cHwGUI, cHarbour, cBcc55, oBrowse3:aArray)
//Add def File
//
cMake += IIf(!Empty(cListRes), ",," + cListRes, "")

IF File(cMainPrg + ".bc ")
   FErase(cMainPrg + ".bc ")
ENDIF

Memowrit(cMainPrg + ".bc ", cMake)

IF ExecuteCommand(cBCC55 + "\bin\ilink32", "-v -Gn -aa -Tpe @" + cMainPrg + ".bc") != 0
      hwg_MsgInfo("No link file " + cMainPrg + "!", "HwMake")
      RETURN NIL
ENDIF

IF File(cMainPrg + ".bc ")
   FErase(cMainPrg + ".bc ")
ENDIF

RETURN NIL


FUNCTION RetLibrary(cHwGUI, cHarbour, cBcc55, aLibs)
Local i, cLib, CRLF := " +" + Chr(179)
Local lMt := .F.
cLib := cHwGUI + "\lib\hwgui.lib " + CRLF
cLib += cHwGUI + "\lib\procmisc.lib " + CRLF
cLib += cHwGUI + "\lib\hbxml.lib " + CRLF
cLib += IIf(File(cHarbour + "\lib\rtl" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\rtl" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbrtl" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\hbrtl" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\vm" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\vm" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbvm.lib"), cHarbour + "\lib\hbvm.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\gtgui.lib"), cHarbour + "\lib\gtgui.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\gtwin.lib"), cHarbour + "\lib\gtwin.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\lang.lib"), cHarbour + "\lib\lang.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hblang.lib"), cHarbour + "\lib\hblang.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\codepage.lib"), cHarbour + "\lib\codepage.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbcpage.lib"), cHarbour + "\lib\hbcpage.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\macro" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\macro" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbmacro.lib"), cHarbour + "\lib\hbmacro.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\rdd" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\rdd" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbrdd.lib"), cHarbour + "\lib\hbrdd.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\dbfntx" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\dbfntx" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\rddntx.lib"), cHarbour + "\lib\rddntx.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\dbfcdx" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\dbfcdx" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\rddcdx.lib"), cHarbour + "\lib\rddcdx.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\dbffpt" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\dbffpt" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\rddfpt.lib"), cHarbour + "\lib\rddfpt.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\sixcdx" + IIf(lMt, cMt, "") + ".lib"), cHarbour + "\lib\sixcdx" + IIf(lMt, cMt, "") + ".lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbsix.lib"), cHarbour + "\lib\hbsix.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\common.lib"), cHarbour + "\lib\common.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbcommon.lib"), cHarbour + "\lib\hbcommon.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\debug.lib"), cHarbour + "\lib\debug.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbdebug.lib"), cHarbour + "\lib\hbdebug.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\pp.lib"), cHarbour + "\lib\pp.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbpp.lib"), cHarbour + "\lib\hbpp.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hsx.lib"), cHarbour + "\lib\hsx.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbhsx.lib"), cHarbour + "\lib\hbhsx.lib " + CRLF, "")
cLib += cHarbour + "\lib\hbsix.lib " + CRLF
cLib += IIf(File(cHarbour + "\lib\pcrepos.lib"), cHarbour + "\lib\pcrepos.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbpcre.lib"), cHarbour + "\lib\hbpcre.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\zlib.lib"), cHarbour + "\lib\zlib.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbzlib.lib"), cHarbour + "\lib\hbzlib.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbw32.lib"), cHarbour + "\lib\hbw32.lib " + CRLF, "")
cLib += IIf(File(cHarbour + "\lib\hbwin.lib"), cHarbour + "\lib\hbwin.lib " + CRLF, "")
cLib += cBcc55 + "\lib\cw32.lib " + CRLF
cLib += cBcc55 + "\lib\import32.lib" + CRLF
FOR EACH i in aLibs
   cLib += lower(i) + CRLF
Next

cLib := SubStr(AllTrim(cLib), 1, Len(AllTrim(cLib)) - 2)
cLib := StrTran(cLib, Chr(179), Chr(13) + Chr(10))
RETURN cLib

FUNCTION ExecuteCommand(cProc, cSend, cLog)
Local cFile := "execcom.bat"
Local nRet
IF cLog == NIL
   cLog := ""
ELSE
   cLog := " > " + cFileNoPath(cLog)
ENDIF
IF File(cFile)
   FErase(cFile)
ENDIF
Memowrit(cFile, cProc + " " + cSend + cLog)
nRet := hwg_WaitRun(cFile)
IF File(cFile)
   FErase(cFile)
ENDIF

RETURN nRet

FUNCTION BrwdelIten(oBrowse)
Adel(oBrowse:aArray, oBrowse:nCurrent)
ASize(oBrowse:aArray, Len(oBrowse:aArray) - 1)
RETURN oBrowse:Refresh()


FUNCTION OpenAbout
Local oModDlg, oFontBtn, oFontDlg
Local oBmp
Local oSay

   PREPARE FONT oFontDlg NAME "MS Sans Serif" WIDTH 0 HEIGHT -13
   PREPARE FONT oFontBtn NAME "MS Sans Serif" WIDTH 0 HEIGHT -13 ITALIC UNDERLINE

   INIT DIALOG oModDlg TITLE "About"     ;
   AT 190, 10  SIZE 360, 200               ;
   ICON oIcon                            ;
   FONT oFontDlg
 
        
   @ 20, 40 SAY "Hwgui Internacional Page"        ;
   LINK "http://www.hwgui.net" ;
       SIZE 230, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF") ;
        VISITCOLOR hwg_RGB(241, 249, 91)


   @ 20, 60 SAY "Hwgui Kresin Page"        ;
   LINK "http://kresin.belgorod.su/hwgui.html" ;
       SIZE 230, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF") ;
        VISITCOLOR hwg_RGB(241, 249, 91)

   @ 20, 80 SAY "Hwgui international Forum"        ;
   LINK "http://br.groups.yahoo.com/group/hwguibr" ;
       SIZE 230, 22 STYLE SS_CENTER  ;
        COLOR hwg_VColor("0000FF") ;
        VISITCOLOR hwg_RGB(241, 249, 91)
                             
   @ 40, 120 BUTTONex oBtExit  CAPTION "Close"  BITMAP oImgExit:Handle  on Click {||EndDialog()}    SIZE 180, 35  

   ACTIVATE DIALOG oModDlg
   
RETURN NIL


STATIC FUNCTION ErrorPreview(cMess)
Local oDlg, oEdit

   INIT DIALOG oDlg TITLE "Build Error" ;
        AT 92, 61 SIZE 500, 500

   @ 10, 10 EDITBOX oEdit CAPTION cMess SIZE 480, 440 STYLE WS_VSCROLL + WS_HSCROLL + ES_MULTILINE + ES_READONLY ;
        COLOR 16777088 BACKCOLOR 0 ;
        ON GETFOCUS {||hwg_SendMessage(oEdit:handle, EM_SETSEL, 0, 0)}

   @ 200, 460 BUTTON "Close" ON CLICK {||EndDialog()} SIZE 100, 32

   oDlg:Activate()
RETURN NIL