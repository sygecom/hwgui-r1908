#define CRLF Chr(13) + Chr(10)
*------------------------------------------------------------------------------------------------------------------------------------
Function Main
*------------------------------------------------------------------------------------------------------------------------------------
   
   LOCAL aFiles := Directory( "*.xml" )
   LOCAL i
   LOCAL cFile
   LOCAL cText
   
   For i:= 1 to Len(aFiles)
   
      cFile:= StrTran( Lower(Alltrim(aFiles[i, 1])), "xml", "frm" )
      
      If File(cFile)
         FErase(cFile)
      EndIF

      cText := "/*" + CRLF + "FORM HwGUI Designer : " + cFile + CRLF + "Date: " + DTOC (Date() ) + CRLF + "*/" + CRLF
      
      cText += "Function " + StrTran( cFile, ".frm", "" ) + CRLF
      cText += "   Local cXml " + CRLF + CRLF
      cText += "   TEXT INTO cXml " + CRLF
      cText += Memoread(AllTrim(aFiles[i, 1])) + CRLF
      cText += "   ENDTEXT " + CRLF + CRLF
      cText += "Return cXml"+ CRLF
      
      
      Memowrit( cFile, cText )
      
      ? "Created " + cFile 
          
   Next
   
Return NIL   
   
   
   
   