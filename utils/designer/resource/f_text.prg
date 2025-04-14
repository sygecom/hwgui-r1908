#SCRIPT TABLE
aCtrlTable := { { "STATIC", "label" }, { "BUTTON", "button" }, &&
    { "CHECKBOX", "checkbox" }, { "RADIOBUTTON", "radiobutton" },   &&
    { "EDITBOX", "editbox" }, { "GROUPBOX", "group" }, { "DATEPICKER", "datepicker" }, &&
    { "UPDOWN", "updown" }, { "COMBOBOX", "combobox" }, { "HLINE", "line" }, &&
    { "PANEL", "toolbar" }, { "OWNERBUTTON", "ownerbutton" }, &&
    { "BROWSE", "browse" } }
#ENDSCRIPT

#SCRIPT READ
FUNCTION STR2FONT
   
   PARAMETERS cFont
   PRIVATE oFont
   
   IF !Empty(cFont)
      oFont := HFont():Add(hwg_NextItem(cFont, .T., ","), &&
            Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), &&
            Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), &&
            Val(hwg_NextItem(cFont,, ",")), Val(hwg_NextItem(cFont,, ",")), &&
            Val(hwg_NextItem(cFont,, ",")))
   ENDIF
RETURN oFont
ENDFUNC

   PRIVATE strbuf := Space(512)
   PRIVATE poz := 513
   PRIVATE stroka
   PRIVATE nMode := 0
   PRIVATE itemName
   PRIVATE i
   PRIVATE han := FOPEN(oForm:path+oForm:filename)
   PRIVATE cCaption
   PRIVATE x
   PRIVATE y
   PRIVATE nWidth
   PRIVATE nHeight
   PRIVATE nStyle
   PRIVATE lClipper
   PRIVATE oFont
   PRIVATE tColor
   PRIVATE bColor
   PRIVATE cFont

   IF han == - 1
      hwg_MsgStop("Can't open "+oForm:path+oForm:filename)
      RETURN
   ENDIF
   DO WHILE .T.
      stroka := hwg_RDSTR(han, @strbuf, @poz, 512)
      IF Len(stroka) == 0
         EXIT
      ENDIF
      stroka := LTrim(stroka)
      IF nMode == 0
         IF Left(stroka, 1) == "#"
            IF Upper(SubStr(stroka, 2, 4)) == "FORM"
               stroka := LTrim(SubStr(stroka, 7))
               itemName := hwg_NextItem(stroka, .T.)
               IF Empty(oForm:name) .OR. Upper(itemName) == Upper(oForm:name)
                  x := hwg_NextItem(stroka)
                  y := hwg_NextItem(stroka)
                  nWidth := hwg_NextItem(stroka)
                  nHeight := hwg_NextItem(stroka)
                  nStyle := Val(hwg_NextItem(stroka))
                  oForm:lGet := (Upper(hwg_NextItem(stroka)) == "T")
                  lClipper := (Upper(hwg_NextItem(stroka)) == "T")
                  cFont := hwg_NextItem(stroka)
                  oFont := hwg_CallFunc("Str2Font", { cFont })
                  oForm:CreateDialog({ {"Left", x}, {"Top", y}, {"Width", nWidth}, {"Height", nHeight}, {"Caption", itemName}, {"Font", oFont} })
                  nMode := 1
               ENDIF
            ENDIF
         ENDIF
      ELSEIF nMode == 1
         IF Left(stroka, 1) == "#"
            IF Upper(SubStr(stroka, 2, 7)) == "ENDFORM"
               Exit
            ENDIF
         ELSE           
            itemName := CnvCtrlName(hwg_NextItem(stroka, .T.))
            IF itemName == NIL
               hwg_MsgStop("Wrong item name: " + hwg_NextItem(stroka, .T.))
               RETURN
            ENDIF
            cCaption := hwg_NextItem(stroka)
            hwg_NextItem(stroka)
            x := hwg_NextItem(stroka)
            y := hwg_NextItem(stroka)
            nWidth := hwg_NextItem(stroka)
            nHeight := hwg_NextItem(stroka)
            nStyle := Val(hwg_NextItem(stroka))
            cFont := hwg_NextItem(stroka)
            tColor := hwg_NextItem(stroka)
            bColor := hwg_NextItem(stroka)
            oFont := hwg_CallFunc("Str2Font", { cFont })
            HControlGen():New(oForm:oDlg, itemName, &&
             { { "Left", x }, { "Top", y }, { "Width", nWidth }, &&
             { "Height", nHeight }, { "Caption", cCaption }, &&
             { "TextColor", tColor }, { "BackColor", bColor }, {"Font", oFont} })
         ENDIF
      ENDIF
   ENDDO
   FClose(han)
RETURN
#ENDSCRIPT

#SCRIPT WRITE
   PRIVATE han
   PRIVATE fname := oForm:path + oForm:filename
   PRIVATE stroka
   PRIVATE oCtrl
   PRIVATE aControls := oForm:oDlg:aControls
   PRIVATE alen := Len(aControls)
   PRIVATE i

   han := FCreate(fname)
   FWrite(han, "#FORM " + oForm:name &&
       + ";" + LTrim(Str(oForm:oDlg:nLeft))    &&
       + ";" + LTrim(Str(oForm:oDlg:nTop))     &&
       + ";" + LTrim(Str(oForm:oDlg:nWidth))   &&
       + ";" + LTrim(Str(oForm:oDlg:nHeight)) &&
       + ";" + LTrim(Str(oForm:oDlg:style))    &&
       + ";" + IIf(oForm:lGet, "T", "F")           &&
       + ";" + IIf(oForm:oDlg:lClipper, "T", "F")  &&
       + ";" + IIf(oForm:oDlg:oFont != NIL,        &&
       oForm:oDlg:oFont:name + "," + LTrim(Str(oForm:oDlg:oFont:width)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:height)) + "," + LTrim(Str(oForm:oDlg:oFont:weight)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:charset)) + "," + LTrim(Str(oForm:oDlg:oFont:italic)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:underline)) + "," + LTrim(Str(oForm:oDlg:oFont:strikeout)) &&
       ,"") &&
       + _Chr(10) )
   i := 1
   DO WHILE i <= alen
      oCtrl := aControls[i]
      stroka := CnvCtrlName(oCtrl:cClass, .T.) + ";" + RTrim(oCtrl:title) &&
          + ";" + LTrim(Str(IIf(oCtrl:id < 34000, oCtrl:id, 0))) &&
          + ";" + LTrim(Str(oCtrl:nLeft))    &&
          + ";" + LTrim(Str(oCtrl:nTop))     &&
          + ";" + LTrim(Str(oCtrl:nWidth))   &&
          + ";" + LTrim(Str(oCtrl:nHeight)) &&
          + ";" + LTrim(Str(oCtrl:style))    &&
          + ";" + IIf(oCtrl:oFont != NIL,        &&
          oCtrl:oFont:name + "," + Ltrim(Str(oCtrl:oFont:width)) &&
          + "," + LTrim(Str(oCtrl:oFont:height)) + "," + LTrim(Str(oCtrl:oFont:weight)) &&
          + "," + LTrim(Str(oCtrl:oFont:charset)) + "," + LTrim(Str(oCtrl:oFont:italic)) &&
          + "," + LTrim(Str(oCtrl:oFont:underline)) + "," + LTrim(Str(oCtrl:oFont:strikeout)) &&
          , "")  &&
          + ";" + IIf(oCtrl:tcolor != NIL .AND. oCtrl:tcolor != 0, LTrim(Str(oCtrl:tcolor)), "") &&
          + ";" + IIf(oCtrl:bcolor != NIL, Ltrim(Str(oCtrl:bcolor)), "")
      FWrite(han, stroka + _Chr(10))
      i++
   ENDDO
   FWrite(han, "#ENDFORM ")
   FWrite(han, _Chr(10))
   FClose(han)
#ENDSCRIPT
