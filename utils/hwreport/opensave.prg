/*
 * Repbuild - Visual Report Builder
 * Open/save functions
 *
 * Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://www.geocities.com/alkresin/
*/

#include "windows.ch"
#include "guilib.ch"
#include "repbuild.h"
#include "repmain.h"
#include <fileio.ch>

#define SB_VERT         1

Memvar aPaintRep , mypath,aitemtypes

Function FileDlg( lOpen )
Local oDlg

   IF !lOpen .AND. ( aPaintRep == NIL .OR. Empty(aPaintRep[FORM_ITEMS]) )
      hwg_MsgStop( "Nothing to save" )
      RETURN NIL
   ELSEIF lOpen
      CloseReport()
   ENDIF

   INIT DIALOG oDlg FROM RESOURCE "DLG_FILE" ON INIT {|| InitOpen(lOpen) }
   DIALOG ACTIONS OF oDlg ;
        ON 0,IDOK         ACTION {|| EndOpen(lOpen)}  ;
        ON BN_CLICKED,IDC_RADIOBUTTON1 ACTION {||hwg_SetDlgItemText(oDlg:handle,IDC_TEXT1,"Report Name:")} ;
        ON BN_CLICKED,IDC_RADIOBUTTON2 ACTION {||hwg_SetDlgItemText(oDlg:handle,IDC_TEXT1,"Function Name:")} ;
        ON BN_CLICKED,IDC_BUTTONBRW ACTION {||BrowFile(lOpen)}
   oDlg:Activate()

RETURN NIL

Static Function InitOpen( lOpen )
Local hDlg := hwg_GetModalHandle()
   hwg_CheckRadioButton( hDlg,IDC_RADIOBUTTON1,IDC_RADIOBUTTON3,IDC_RADIOBUTTON1 )
   hwg_SetWindowText( hDlg, IIf(lOpen, "Open report", "Save report"))
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT1 ) )
RETURN .T.

Static Function BrowFile(lOpen)
Local hDlg := hwg_GetModalHandle()
Local fname, s1, s2
   IF hwg_IsDlgButtonChecked(hDlg, IDC_RADIOBUTTON1)
      s1 := "Report files( *.rpt )"
      s2 := "*.rpt"
   ELSE
      s1 := "Program files( *.prg )"
      s2 := "*.prg"
   ENDIF
   IF lOpen
      fname := hwg_SelectFile(s1, s2, mypath)
   ELSE
      fname := hwg_SaveFile(s2, s1, s2, mypath)
   ENDIF
   hwg_SetDlgItemText( hDlg, IDC_EDIT1, fname )
   hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT2 ) )
RETURN NIL

Static Function EndOpen( lOpen )
Local hDlg := hwg_GetModalHandle()
Local fname, repName
Local res := .T.

   fname := hwg_GetEditText( hDlg, IDC_EDIT1 )
   IF !Empty(fname)
      repName := hwg_GetEditText( hDlg, IDC_EDIT2 )

      IF lOpen
         IF ( res := OpenFile(fname, @repName) )
            aPaintRep[FORM_Y] := 0
            hwg_EnableMenuItem( , 1, .T., .F. )
            hwg_RedrawWindow( Hwindow():GetMain():handle, RDW_ERASE + RDW_INVALIDATE )
         ELSE
            aPaintRep := NIL
            hwg_EnableMenuItem( , 1, .F., .F. )
         ENDIF
      ELSE
         res := SaveRFile(fname, repName)
         aPaintRep[FORM_FILENAME] := fname
         aPaintRep[FORM_REPNAME] := repName
      ENDIF

      IF res
         EndDialog( hDlg )
      ENDIF
   ELSE
      hwg_SetFocus( hwg_GetDlgItem( hDlg, IDC_EDIT1 ) )
   ENDIF
RETURN .T.

Function CloseReport
Local i, aItem
   IF aPaintRep != NIL
      IF aPaintRep[FORM_CHANGED] == .T.
         IF hwg_MsgYesNo( "Report was changed. Are you want to save it ?" )
            SaveReport()
         ENDIF
      ENDIF
      FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
         aItem := aPaintRep[FORM_ITEMS,i]
         IF aItem[ITEM_PEN] != NIL
            aItem[ITEM_PEN]:Release()
         ENDIF
      NEXT
      aPaintRep := NIL
      hwg_ShowScrollBar( Hwindow():GetMain():handle,SB_VERT,.F. )
      hwg_RedrawWindow( Hwindow():GetMain():handle, RDW_ERASE + RDW_INVALIDATE )
      hwg_EnableMenuItem( , 1, .F., .F. )
   ENDIF
RETURN .T.

Function SaveReport
Local fname

   IF ( aPaintRep == NIL .OR. Empty(aPaintRep[FORM_ITEMS]) )
      hwg_MsgStop( "Nothing to save" )
      RETURN NIL
   ENDIF
   IF Empty(aPaintRep[FORM_FILENAME])
      FileDlg( .F. )
   ELSE
      SaveRFile(aPaintRep[FORM_FILENAME], aPaintRep[FORM_REPNAME])
   ENDIF

RETURN NIL

Static Function OpenFile(fname, repName)
LOCAL strbuf := Space(512), poz := 513, stroka, nMode := 0
Local han := FOPEN( fname, FO_READ + FO_SHARED )
Local i, itemName, aItem, res := .T., sFont
Local lPrg := ( Upper(hwg_FilExten(fname))=="PRG" ), cSource := "", vDummy, nFormWidth
   IF han != - 1
      DO WHILE .T.
         stroka := hwg_RDSTR(han, @strbuf, @poz, 512)
         IF Len(stroka) = 0
            EXIT
         ENDIF
         IF Left(stroka, 1) == ";"
            LOOP
         ENDIF
         IF nMode == 0
            IF lPrg
               IF Upper(Left(stroka, 8)) == "FUNCTION" .AND. ;
                   Upper(LTrim(SubStr(stroka, 10))) == Upper(repname)
                  nMode := 10
               ENDIF
            ELSE
               IF Left(stroka, 1) == "#"
                  IF Upper(SubStr(stroka, 2, 6)) == "REPORT"
                     stroka := LTrim(SubStr(stroka, 9))
                     IF Empty(repName) .OR. Upper(stroka) == Upper(repName)
                        IF Empty(repName)
                           repName := stroka
                        ENDIF
                        nMode := 1
                        aPaintRep := { 0, 0, 0, 0, 0,{},fname,repName,.F., 0,NIL }
                     ENDIF
                  ENDIF
               ENDIF
            ENDIF
         ELSEIF nMode == 1
            IF Left(stroka, 1) == "#"
               IF Upper(SubStr(stroka, 2, 6)) == "ENDREP"
                  Exit
               ELSEIF Upper(SubStr(stroka, 2, 6)) == "SCRIPT"
                  nMode := 2
                  IF aItem != NIL
                     aItem[ITEM_SCRIPT] := ""
                  ELSE
                     aPaintRep[FORM_VARS] := ""
                  ENDIF
               ENDIF
            ELSE
               IF ( itemName := hwg_NextItem( stroka,.T. ) ) == "FORM"
                  aPaintRep[FORM_WIDTH] := Val( hwg_NextItem( stroka ) )
                  aPaintRep[FORM_HEIGHT] := Val( hwg_NextItem( stroka ) )
                  nFormWidth := Val( hwg_NextItem( stroka ) )
               ELSEIF itemName == "TEXT"
                  AAdd(aPaintRep[FORM_ITEMS], { 1,hwg_NextItem(stroka),Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)),Val(hwg_NextItem(stroka)),NIL,hwg_NextItem(stroka), ;
                           Val(hwg_NextItem(stroka)), 0,NIL, 0 })
                  aItem := Atail( aPaintRep[FORM_ITEMS] )
                  aItem[ITEM_FONT] := HFont():Add(hwg_NextItem( aItem[ITEM_FONT],.T.,"," ), ;
                    Val(hwg_NextItem( aItem[ITEM_FONT],,"," )),Val(hwg_NextItem( aItem[ITEM_FONT],,"," )), ;
                    Val(hwg_NextItem( aItem[ITEM_FONT],,"," )),Val(hwg_NextItem( aItem[ITEM_FONT],,"," )), ;
                    Val(hwg_NextItem( aItem[ITEM_FONT],,"," )),Val(hwg_NextItem( aItem[ITEM_FONT],,"," )), ;
                    Val(hwg_NextItem( aItem[ITEM_FONT],,"," )))
                  IF aItem[ITEM_X1] == NIL .OR. aItem[ITEM_X1] == 0 .OR. ;
                     aItem[ITEM_Y1] == NIL .OR. aItem[ITEM_Y1] == 0 .OR. ;
                     aItem[ITEM_WIDTH] == NIL .OR. aItem[ITEM_WIDTH] == 0 .OR. ;
                     aItem[ITEM_HEIGHT] == NIL .OR. aItem[ITEM_HEIGHT] == 0
                     hwg_MsgStop( "Error: "+stroka )
                     res := .F.
                     EXIT
                  ENDIF
               ELSEIF itemName == "HLINE" .OR. itemName == "VLINE" .OR. itemName == "BOX"
                  AAdd(aPaintRep[FORM_ITEMS], { Iif(itemName=="HLINE", 2,Iif(itemName=="VLINE", 3, 4)), ;
                           "",Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), 0,hwg_NextItem(stroka),NIL, 0, 0,NIL, 0 })
                  aItem := Atail( aPaintRep[FORM_ITEMS] )
                  aItem[ITEM_PEN] := HPen():Add(Val(hwg_NextItem( aItem[ITEM_PEN],.T.,"," )), ;
                          Val(hwg_NextItem( aItem[ITEM_PEN],,"," )),Val(hwg_NextItem( aItem[ITEM_PEN],,"," )))
                  IF aItem[ITEM_X1] == NIL .OR. aItem[ITEM_X1] == 0 .OR. ;
                     aItem[ITEM_Y1] == NIL .OR. aItem[ITEM_Y1] == 0 .OR. ;
                     aItem[ITEM_WIDTH] == NIL .OR. aItem[ITEM_WIDTH] == 0 .OR. ;
                     aItem[ITEM_HEIGHT] == NIL .OR. aItem[ITEM_HEIGHT] == 0
                     hwg_MsgStop( "Error: "+stroka )
                     res := .F.
                     EXIT
                  ENDIF
               ELSEIF itemName == "BITMAP"
                  AAdd(aPaintRep[FORM_ITEMS], { 5, hwg_NextItem(stroka), ;
                           Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), 0,NIL,NIL, 0, 0,NIL, 0 })
                  aItem := Atail( aPaintRep[FORM_ITEMS] )
                  aItem[ITEM_BITMAP] := HBitmap():AddFile(aItem[ITEM_CAPTION])
                  IF aItem[ITEM_X1] == NIL .OR. aItem[ITEM_X1] == 0 .OR. ;
                     aItem[ITEM_Y1] == NIL .OR. aItem[ITEM_Y1] == 0 .OR. ;
                     aItem[ITEM_WIDTH] == NIL .OR. aItem[ITEM_WIDTH] == 0 .OR. ;
                     aItem[ITEM_HEIGHT] == NIL .OR. aItem[ITEM_HEIGHT] == 0
                     hwg_MsgStop( "Error: "+stroka )
                     res := .F.
                     EXIT
                  ENDIF
               ELSEIF itemName == "MARKER"
                  AAdd(aPaintRep[FORM_ITEMS], { 6, hwg_NextItem(stroka),Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), Val(hwg_NextItem(stroka)), ;
                           Val(hwg_NextItem(stroka)), Val(hwg_NextItem(stroka)), ;
                           NIL,NIL, 0, 0,NIL, 0 })
                  aItem := Atail( aPaintRep[FORM_ITEMS] )
               ENDIF
            ENDIF
         ELSEIF nMode == 2
            IF Left(stroka, 1) == "#" .AND. Upper(SubStr(stroka, 2, 6)) == "ENDSCR"
               nMode := 1
            ELSE
               IF aItem != NIL
                  aItem[ITEM_SCRIPT] += stroka+Chr(13)+chr(10)
               ELSE
                  aPaintRep[FORM_VARS] += stroka+Chr(13)+chr(10)
               ENDIF
            ENDIF
         ELSEIF nMode == 10
            IF Upper(Left(stroka, 15)) == "LOCAL APAINTREP"
               nMode := 11
            ELSE
               hwg_MsgStop( "Wrong function "+repname )
               FClose(han)
               RETURN .F.
            ENDIF
         ELSEIF nMode == 11
            IF Upper(Left(stroka, 6)) == "RETURN"
               Exit
            ELSE
               IF Right(stroka, 1) == ";"
                  cSource += LTrim(Rtrim(Left(stroka, Len(stroka) - 1)))
               ELSE
                  cSource += LTrim(RTrim(stroka))
                  // Writelog( cSource )
                  vDummy := &cSource
                  cSource := ""
               ENDIF
            ENDIF
         ENDIF
      ENDDO
      FClose(han)
   ELSE
      hwg_MsgStop( "Can't open "+fname )
      RETURN .F.
   ENDIF
   IF aPaintRep == NIL .OR. Empty(aPaintRep[FORM_ITEMS])
      hwg_MsgStop( repname+" not found or empty!" )
      res := .F.
   ELSE
      hwg_EnableMenuItem( ,IDM_CLOSE, .T., .T. )
      hwg_EnableMenuItem( ,IDM_SAVE, .T., .T. )
      hwg_EnableMenuItem( ,IDM_SAVEAS, .T., .T. )
      hwg_EnableMenuItem( ,IDM_PRINT, .T., .T. )
      hwg_EnableMenuItem( ,IDM_PREVIEW, .T., .T. )
      hwg_EnableMenuItem( ,IDM_FOPT, .T., .T. )

      aPaintRep[FORM_ITEMS] := Asort( aPaintRep[FORM_ITEMS],,, {|z,y|z[ITEM_Y1]<y[ITEM_Y1].OR.(z[ITEM_Y1]==y[ITEM_Y1].AND.z[ITEM_X1]<y[ITEM_X1]).OR.(z[ITEM_Y1]==y[ITEM_Y1].AND.z[ITEM_X1]==y[ITEM_X1].AND.(z[ITEM_WIDTH]<y[ITEM_WIDTH].OR.z[ITEM_HEIGHT]<y[ITEM_HEIGHT]))} )
      IF !lPrg
         hwg_RecalcForm( aPaintRep,nFormWidth )
      ENDIF

      hwg_WriteStatus( Hwindow():GetMain(), 2,Ltrim(Str(aPaintRep[FORM_WIDTH], 4))+"x"+ ;
                 Ltrim(Str(aPaintRep[FORM_HEIGHT], 4))+"  Items: "+Ltrim(Str(Len(aPaintRep[FORM_ITEMS]))) )
   ENDIF
RETURN res

Static Function SaveRFile(fname, repName)
LOCAL strbuf := Space(512), poz := 513, stroka, nMode := 0
Local han, hanOut, isOut := .F., res := .F.
Local lPrg := ( Upper(hwg_FilExten(fname))=="PRG" )

   IF File(fname)
      han := FOPEN( fname, FO_READWRITE + FO_EXCLUSIVE )
      IF han != - 1
         hanOut := FCreate(mypath + "__rpt.tmp")
         IF hanOut != - 1
            DO WHILE .T.
               stroka := hwg_RDSTR(han, @strbuf, @poz, 512)
               IF Len(stroka) = 0
                  EXIT
               ENDIF
               IF nMode == 0
                  IF ( lPrg .AND. Upper(Left(stroka, 8)) == "FUNCTION" ) ;
                        .OR. ( !lPrg .AND. Left(stroka, 1) == "#" .AND. ;
                           Upper(SubStr(stroka, 2, 6)) == "REPORT" )
                     IF Upper(LTrim(SubStr(stroka, 9))) == Upper(repName)
                        nMode := 1
                        isOut := .T.
                        LOOP
                     ENDIF
                  ENDIF
                  FWrite(hanOut, stroka + IIf(Asc(Right(stroka, 1)) < 20, "", Chr(10)))
               ELSEIF nMode == 1
                  IF ( lPrg .AND. Left(stroka, 6) == "RETURN" ) ;
                      .OR. ( !lPrg .AND. Left(stroka, 1) == "#" .AND. ;
                       Upper(SubStr(stroka, 2, 6)) == "ENDREP" )
                     nMode := 0
                     IF lPrg
                        WriteToPrg( hanOut, repName )
                     ELSE
                        WriteRep( hanOut, repName )
                     ENDIF
                  ENDIF
               ENDIF
            ENDDO
            IF isOut
               FClose(hanOut)
               FClose(han)
               IF FErase(fname) == -1 .OR. FRename(mypath + "__rpt.tmp", fname) == -1
                  hwg_MsgStop( "Can't rename __rpt.tmp" )
               ELSE
                  res := .T.
               ENDIF
            ELSE
               FSeek( han, 0, FS_END )
               FWrite(han, Chr(10))
               IF lPrg
                  WriteToPrg( han, repName )
               ELSE
                  WriteRep( hanOut, repName )
               ENDIF
               FClose(hanOut)
               FClose(han)
               res := .T.
            ENDIF
         ELSE
            hwg_MsgStop( "Can't create __rpt.tmp" )
            FClose(han)
         ENDIF
      ELSE
         hwg_MsgStop( "Can't open "+fname )
      ENDIF
   ELSE
      han := FCreate(fname)
      IF lPrg
         WriteToPrg( han, repName )
      ELSE
         WriteRep( han, repName )
      ENDIF
      FClose(han)
      res := .T.
   ENDIF
   IF res
      aPaintRep[FORM_CHANGED] := .F.
   ENDIF

RETURN res

Static Function WriteRep( han, repName )
Local i, aItem, oPen, oFont, hDCwindow, aMetr

   hDCwindow := hwg_GetDC(Hwindow():GetMain():handle)
   aMetr := hwg_GetDeviceArea(hDCwindow)
   hwg_ReleaseDC(Hwindow():GetMain():handle, hDCwindow)

   FWrite(han, "#REPORT " + repName + Chr(10))
   FWrite(han, "FORM;" + LTrim(Str(aPaintRep[FORM_WIDTH])) + ";" + ;
                         LTrim(Str(aPaintRep[FORM_HEIGHT])) + ";" + ;
                         LTrim(Str(aMetr[1] - XINDENT)) + Chr(10))
   WriteScript( han,aPaintRep[FORM_VARS] )

   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      aItem := aPaintRep[FORM_ITEMS,i]
      IF aItem[ITEM_TYPE] == TYPE_TEXT
         oFont := aItem[ITEM_FONT]
         FWrite(han, aItemTypes[aItem[ITEM_TYPE]] + ";" + aItem[ITEM_CAPTION] + ";" + ;
             LTrim(Str(aItem[ITEM_X1], 4)) + ";" + LTrim(Str(aItem[ITEM_Y1], 4)) + ";" + ;
             LTrim(Str(aItem[ITEM_WIDTH], 4)) + ";" + LTrim(Str(aItem[ITEM_HEIGHT], 4)) +;
             ";" + Str(aItem[ITEM_ALIGN], 1) + ";" + oFont:name ;
             + "," + LTrim(Str(oFont:width)) + "," + LTrim(Str(oFont:height)) ;
             + "," + LTrim(Str(oFont:weight)) + "," + LTrim(Str(oFont:charset)) ;
             + "," + LTrim(Str(oFont:italic)) + "," + LTrim(Str(oFont:underline)) ;
             + "," + LTrim(Str(oFont:strikeout)) + ";" + Str(aItem[ITEM_VAR], 1) + Chr(10))
         WriteScript( han,aItem[ITEM_SCRIPT] )
      ELSEIF aItem[ITEM_TYPE] == TYPE_HLINE .OR. aItem[ITEM_TYPE] == TYPE_VLINE .OR. aItem[ITEM_TYPE] == TYPE_BOX
         oPen := aItem[ITEM_PEN]
         FWrite(han, aItemTypes[aItem[ITEM_TYPE]] + ";" + ;
             LTrim(Str(aItem[ITEM_X1], 4)) + ";" + LTrim(Str(aItem[ITEM_Y1], 4)) + ";" + ;
             LTrim(Str(aItem[ITEM_WIDTH], 4)) + ";" + LTrim(Str(aItem[ITEM_HEIGHT], 4)) + ;
             ";" + LTrim(Str(oPen:style)) + "," + LTrim(Str(oPen:width)) + "," + LTrim(Str(oPen:color)) ;
             + Chr(10))
      ELSEIF aItem[ITEM_TYPE] == TYPE_BITMAP
         FWrite(han, aItemTypes[aItem[ITEM_TYPE]] + ";" + aItem[ITEM_CAPTION] + ";" + ;
             LTrim(Str(aItem[ITEM_X1], 4)) + ";" + LTrim(Str(aItem[ITEM_Y1], 4)) + ";" + ;
             LTrim(Str(aItem[ITEM_WIDTH], 4)) + ";" + LTrim(Str(aItem[ITEM_HEIGHT], 4)) + ;
             + Chr(10))
      ELSEIF aItem[ITEM_TYPE] == TYPE_MARKER
         FWrite(han, aItemTypes[aItem[ITEM_TYPE]] + ";" + aItem[ITEM_CAPTION] + ";" + ;
             LTrim(Str(aItem[ITEM_X1], 4)) + ";" + LTrim(Str(aItem[ITEM_Y1], 4)) + ";" + ;
             LTrim(Str(aItem[ITEM_WIDTH], 4)) + ";" + LTrim(Str(aItem[ITEM_HEIGHT], 4)) + ;
             ";" + Str(aItem[ITEM_ALIGN], 1) + Chr(10))
         WriteScript( han,aItem[ITEM_SCRIPT] )
      ENDIF
   NEXT
   FWrite(han, "#ENDREP "+Chr(10))
RETURN NIL

Static Function WriteToPrg( han, repName )
Local i, aItem, oPen, oFont, hDCwindow, aMetr, cItem, cQuote, cPen, cFont

   hDCwindow := hwg_GetDC(Hwindow():GetMain():handle)
   aMetr := hwg_GetDeviceArea(hDCwindow)
   hwg_ReleaseDC(Hwindow():GetMain():handle, hDCwindow)

   FWrite(han, "FUNCTION " + repName + Chr(10) + ;
         "LOCAL aPaintRep" + Chr(10))
   FWrite(han, "   cEnd:=Chr(13)+Chr(10)" + Chr(10))
   FWrite(han, "   aPaintRep := { " + LTrim(Str(aPaintRep[FORM_WIDTH])) + "," + ;
         LTrim(Str(aPaintRep[FORM_HEIGHT])) + ', 0, 0, 0,{},,"' + repName + '", .F., 0, NIL }' + Chr(10))
   IF aPaintRep[FORM_VARS] != NIL .AND. !Empty(aPaintRep[FORM_VARS])
      FWrite(han, "   aPaintRep[11] := ;" + Chr(10))
      WriteScript( han,aPaintRep[FORM_VARS],.T. )
   ENDIF

   FOR i := 1 TO Len(aPaintRep[FORM_ITEMS])
      aItem := aPaintRep[FORM_ITEMS,i]

      cItem := Ltrim(Str(aItem[ITEM_TYPE], 1)) + ","
      IF aItem[ITEM_TYPE]==TYPE_TEXT.OR.aItem[ITEM_TYPE]==TYPE_BITMAP ;
              .OR.aItem[ITEM_TYPE]==TYPE_MARKER
         cQuote := Iif(!( '"' $ aItem[ITEM_CAPTION]),'"', ;
                     Iif(!( "'" $ aItem[ITEM_CAPTION]),"'","["))
         cItem += cQuote + aItem[ITEM_CAPTION] + cQuote
      ENDIF
      cItem += ","+Ltrim(Str(aItem[ITEM_X1], 4)) + "," + Ltrim(Str(aItem[ITEM_Y1], 4)) + "," + ;
               Ltrim(Str(aItem[ITEM_WIDTH], 4)) + "," + Ltrim(Str(aItem[ITEM_HEIGHT], 4)) + ;
               "," + Str(aItem[ITEM_ALIGN], 1)
      IF aItem[ITEM_TYPE] == TYPE_HLINE .OR. aItem[ITEM_TYPE] == TYPE_VLINE ;
              .OR. aItem[ITEM_TYPE] == TYPE_BOX
         oPen := aItem[ITEM_PEN]
         cItem += ",HPen():Add(" + Ltrim(Str(oPen:style)) + "," + ;
                 Ltrim(Str(oPen:width)) + "," + Ltrim(Str(oPen:color)) + ")"
      ELSE
         cItem += ",0"
      ENDIF
      IF aItem[ITEM_TYPE] == TYPE_TEXT
         oFont := aItem[ITEM_FONT]
         cItem += ',HFont():Add( "' + oFont:name + ;
             + '",' + Ltrim(Str(oFont:width)) + "," + Ltrim(Str(oFont:height)) ;
             + "," + Ltrim(Str(oFont:weight)) + "," + Ltrim(Str(oFont:charset)) ;
             + "," + Ltrim(Str(oFont:italic)) + "," + Ltrim(Str(oFont:underline)) ;
             + "," + Ltrim(Str(oFont:strikeout)) + " )," + Str(aItem[ITEM_VAR], 1)
      ELSE
         cItem += ",0,0"
      ENDIF
      cItem += ",0,Nil,0"
      FWrite(han, "   AAdd(aPaintRep[6], { " + cItem + " })" + Chr(10))

      IF aItem[ITEM_SCRIPT] != NIL .AND. !Empty(aItem[ITEM_SCRIPT])
         FWrite(han, "   aPaintRep[6,Len(aPaintRep[6]),12] := ;" + Chr(10))
         WriteScript( han,aItem[ITEM_SCRIPT],.T. )
      ENDIF
   NEXT
   FWrite(han, "   hwg_RecalcForm( aPaintRep," + LTrim(Str(aMetr[1] - XINDENT)) + " )" + Chr(10))
   FWrite(han, "RETURN hwg_SetPaintRep( aPaintRep )" + Chr(10))
RETURN NIL

Static Function WriteScript( han,cScript,lPrg )
Local poz := 0, stroka, i
Local lastC := Chr(10), cQuote, lFirst := .T.

   IF lPrg == NIL; lPrg := .F.; ENDIF
   IF cScript != NIL .AND. !Empty(cScript)
      IF !lPrg
         FWrite(han, "#SCRIPT" + Chr(10))
      ENDIF
      DO WHILE .T.
         stroka := hwg_RDSTR(, cScript, @poz)
         IF Len(stroka) = 0
            IF lPrg
               FWrite(han, Chr(10))
            ENDIF
            EXIT
         ENDIF
         IF Left(stroka, 1) != Chr(10)
            IF lPrg
               cQuote := Iif(!( '"' $ stroka),'"', ;
                           Iif(!( "'" $ stroka),"'","["))
               FWrite(han, IIf(lFirst, "", ";" + Chr(10)) + Space(5) + ;
                     IIf(lFirst, "", "+ ") + cQuote + stroka + cQuote + "+cEnd")
               lFirst := .F.
            ELSE
               FWrite(han, IIf(Asc(lastC) < 20, "", Chr(10)) + stroka)
               lastC := Right(stroka, 1)
            ENDIF
         ENDIF
      ENDDO
      IF !lPrg
         FWrite(han, IIf(Asc(lastC) < 20, "", Chr(10)) + "#ENDSCRIPT" + Chr(10))
      ENDIF
   ENDIF
RETURN NIL
