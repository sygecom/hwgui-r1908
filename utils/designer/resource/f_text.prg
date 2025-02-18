#SCRIPT TABLE
aCtrlTable := { { "STATIC","label" }, { "BUTTON","button" }, &&
    { "CHECKBOX","checkbox" }, { "RADIOBUTTON","radiobutton" },   &&
    { "EDITBOX","editbox" }, { "GROUPBOX","group" }, { "DATEPICKER","datepicker" }, &&
    { "UPDOWN","updown" }, { "COMBOBOX","combobox" }, { "HLINE","line" }, &&
    { "PANEL","toolbar" }, { "OWNERBUTTON","ownerbutton" }, &&
    { "BROWSE","browse" } }
#ENDSCRIPT

#SCRIPT READ
FUNCTION STR2FONT
   
   PARAMETERS cFont
   PRIVATE oFont
   
   IF !Empty(cFont)
      oFont := HFont():Add( NextItem( cFont,.T.,"," ), &&
            Val(NextItem( cFont,,"," )),Val(NextItem( cFont,,"," )), &&
            Val(NextItem( cFont,,"," )),Val(NextItem( cFont,,"," )), &&
            Val(NextItem( cFont,,"," )),Val(NextItem( cFont,,"," )), &&
            Val(NextItem( cFont,,"," )) )
   ENDIF
Return oFont
ENDFUNC

   PRIVATE strbuf := Space(512)
   PRIVATE poz := 513
   PRIVATE stroka
   PRIVATE nMode := 0
   PRIVATE itemName
   PRIVATE i
   PRIVATE han := FOPEN( oForm:path+oForm:filename )
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
      hwg_MsgStop( "Can't open "+oForm:path+oForm:filename )
      Return
   ENDIF
   DO WHILE .T.
      stroka := RDSTR( han,@strbuf,@poz, 512 )
      IF Len(stroka) == 0
         EXIT
      ENDIF
      stroka := LTrim(stroka)
      IF nMode == 0
         IF Left(stroka, 1) == "#"
            IF Upper(SubStr(stroka, 2, 4)) == "FORM"
               stroka := LTrim(SubStr(stroka, 7))
               itemName := NextItem( stroka,.T. )
               IF Empty(oForm:name) .OR. Upper(itemName) == Upper(oForm:name)
                  x := NextItem( stroka )
                  y := NextItem( stroka )
                  nWidth := NextItem( stroka )
                  nHeight := NextItem( stroka )
                  nStyle := Val( NextItem( stroka ) )
                  oForm:lGet := ( Upper(NextItem(stroka)) == "T" )
                  lClipper := ( Upper(NextItem(stroka)) == "T" )
                  cFont := NextItem( stroka )
                  oFont := CallFunc( "Str2Font", { cFont } )
                  oForm:CreateDialog( { {"Left",x}, {"Top",y},{"Width",nWidth},{"Height",nHeight},{"Caption",itemName},{"Font",oFont} } )
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
            itemName := CnvCtrlName( NextItem( stroka,.T. ) )
            IF itemName == Nil
               hwg_MsgStop( "Wrong item name: " + NextItem( stroka,.T. ) )
               Return
            ENDIF
            cCaption := NextItem( stroka )
            NextItem( stroka )
            x := NextItem( stroka )
            y := NextItem( stroka )
            nWidth := NextItem( stroka )
            nHeight := NextItem( stroka )
            nStyle := Val( NextItem( stroka ) )
            cFont := NextItem( stroka )
            tColor := NextItem( stroka )
            bColor := NextItem( stroka )
            oFont := CallFunc( "Str2Font", { cFont } )
            HControlGen():New( oForm:oDlg,itemName, &&
             { { "Left",x }, { "Top",y }, { "Width",nWidth }, &&
             { "Height",nHeight }, { "Caption",cCaption }, &&
             { "TextColor",tColor }, { "BackColor",bColor },{"Font",oFont} } )
         ENDIF
      ENDIF
   ENDDO
   Fclose( han )
Return
#ENDSCRIPT

#SCRIPT WRITE
   PRIVATE han
   PRIVATE fname := oForm:path + oForm:filename
   PRIVATE stroka
   PRIVATE oCtrl
   PRIVATE aControls := oForm:oDlg:aControls
   PRIVATE alen := Len(aControls)
   PRIVATE i

   han := Fcreate( fname )
   Fwrite( han, "#FORM " + oForm:name &&
       + ";" + LTrim(Str(oForm:oDlg:nLeft))    &&
       + ";" + LTrim(Str(oForm:oDlg:nTop))     &&
       + ";" + LTrim(Str(oForm:oDlg:nWidth))   &&
       + ";" + LTrim(Str(oForm:oDlg:nHeight)) &&
       + ";" + LTrim(Str(oForm:oDlg:style))    &&
       + ";" + IIf(oForm:lGet, "T", "F")           &&
       + ";" + IIf(oForm:oDlg:lClipper, "T", "F")  &&
       + ";" + IIf(oForm:oDlg:oFont != Nil,        &&
       oForm:oDlg:oFont:name + "," + LTrim(Str(oForm:oDlg:oFont:width)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:height)) + "," + LTrim(Str(oForm:oDlg:oFont:weight)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:charset)) + "," + LTrim(Str(oForm:oDlg:oFont:italic)) &&
       + "," + LTrim(Str(oForm:oDlg:oFont:underline)) + "," + LTrim(Str(oForm:oDlg:oFont:strikeout)) &&
       ,"") &&
       + _Chr(10) )
   i := 1
   DO WHILE i <= alen
      oCtrl := aControls[i]
      stroka := CnvCtrlName( oCtrl:cClass,.T. ) + ";" + RTrim(oCtrl:title) &&
          + ";" + LTrim(Str(IIf(oCtrl:id < 34000, oCtrl:id, 0))) &&
          + ";" + LTrim(Str(oCtrl:nLeft))    &&
          + ";" + LTrim(Str(oCtrl:nTop))     &&
          + ";" + LTrim(Str(oCtrl:nWidth))   &&
          + ";" + LTrim(Str(oCtrl:nHeight)) &&
          + ";" + LTrim(Str(oCtrl:style))    &&
          + ";" + IIf(oCtrl:oFont != Nil,        &&
          oCtrl:oFont:name + "," + Ltrim(Str(oCtrl:oFont:width)) &&
          + "," + LTrim(Str(oCtrl:oFont:height)) + "," + LTrim(Str(oCtrl:oFont:weight)) &&
          + "," + LTrim(Str(oCtrl:oFont:charset)) + "," + LTrim(Str(oCtrl:oFont:italic)) &&
          + "," + LTrim(Str(oCtrl:oFont:underline)) + "," + LTrim(Str(oCtrl:oFont:strikeout)) &&
          ,"")  &&
          + ";" + IIf(oCtrl:tcolor != Nil .AND. oCtrl:tcolor != 0, LTrim(Str(oCtrl:tcolor)), "") &&
          + ";" + IIf(oCtrl:bcolor != Nil, Ltrim(Str(oCtrl:bcolor)), "")
      Fwrite( han, stroka + _Chr(10) )
      i++
   ENDDO
   Fwrite( han, "#ENDFORM " )
   Fwrite( han, _Chr(10 ) )
   Fclose( han )
#ENDSCRIPT
