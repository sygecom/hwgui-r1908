//
// HWGUI - Harbour Win32 GUI library source code:
// HColumn class - browse databases and arrays
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

// Modificaciones y Agregados. 27.07.2002, WHT.de la Argentina ///////////////
// 1) En el metodo HColumn se agregaron las DATA: "nJusHead" y "nJustLin",  //
//    para poder justificar los encabezados de columnas y tambien las       //
//    lineas. Por default es DT_LEFT                                        //
//    0-DT_LEFT, 1-DT_RIGHT y 2-DT_CENTER. 27.07.2002. WHT.                 //
// 2) Ahora la variable "cargo" del metodo Hbrowse si es codeblock          //
//    ejectuta el CB. 27.07.2002. WHT                                       //
// 3) Se agreg¢ el Metodo "ShowSizes". Para poder ver la "width" de cada   //
//    columna. 27.07.2002. WHT.                                             //
//////////////////////////////////////////////////////////////////////////////

#include <hbclass.ch>
#include <common.ch>
#include <inkey.ch>
#include <dbstruct.ch>
#include "hwgui.ch"

//----------------------------------------------------//
CLASS HColumn INHERIT HObject

   DATA oParent
   DATA block, heading, footing, width, Type
   DATA length INIT 0
   DATA dec, cargo
   DATA nJusHead, nJusLin, nJusFoot        // Para poder Justificar los Encabezados
   // de las columnas y lineas.
   DATA tcolor, bcolor, brush
   DATA oFont
   DATA lEditable INIT .F.       // Is the column editable
   DATA aList                    // Array of possible values for a column -
   // combobox will be used while editing the cell
   DATA aBitmaps
   DATA bValid, bWhen, bclick    // When and Valid codeblocks for cell editing
   DATA bEdit                    // Codeblock, which performs cell editing, if defined
   DATA cGrid                    // Specify border for Header (SNWE), can be
   // multiline if separated by ;
   DATA lSpandHead INIT .F.
   DATA lSpandFoot INIT .F.
   DATA Picture
   DATA bHeadClick
   DATA bHeadRClick
   DATA bColorFoot               //   bColorFoot must return an array containing two colors values
   //   oBrowse:aColumns[1]:bColorFoot := {||IF (nNumber < 0, ;
   //      {textColor, backColor}, ;
   //      {textColor, backColor})}

   DATA bColorBlock              //   bColorBlock must return an array containing four colors values
   //   oBrowse:aColumns[1]:bColorBlock := {||IF (nNumber < 0, ;
   //      {textColor, backColor, textColorSel, backColorSel}, ;
   //      {textColor, backColor, textColorSel, backColorSel})}
   DATA headColor                // Header text color
   DATA FootFont                // Footing font

   DATA lHeadClick   INIT .F.
   DATA lHide INIT .F. // HIDDEN
   DATA Column
   DATA nSortMark INIT 0
   DATA Resizable INIT .T.
   DATA ToolTip
   DATA aHints INIT {}
   DATA Hint INIT .F.

   METHOD New(cHeading, block, Type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick, tcolor, bColor, bClick)
   METHOD Visible(lVisible) SETGET
   METHOD Hide()
   METHOD Show()
   METHOD SortMark(nSortMark) SETGET
   METHOD Value(xValue) SETGET
   METHOD Editable(lEditable) SETGET

ENDCLASS

//----------------------------------------------------//
METHOD HColumn:New(cHeading, block, Type, length, dec, lEditable, nJusHead, nJusLin, cPict, bValid, bWhen, aItem, bColorBlock, bHeadClick, tcolor, bcolor, bClick)

   ::heading := IIf(cHeading == NIL, "", cHeading)
   ::block := block
   ::Type := IIf(Type != NIL, Upper(Type), Type)
   ::length := length
   ::dec := dec
   ::lEditable := IIf(lEditable != NIL, lEditable, ::lEditable)
   ::nJusHead := IIf(nJusHead == NIL, DT_LEFT, nJusHead) + DT_VCENTER + DT_SINGLELINE // Por default
   ::nJusLin := nJusLin //IIf(nJusLin  == NIL, DT_LEFT, nJusLin) + DT_VCENTER + DT_SINGLELINE // Justif.Izquierda
   ::nJusFoot := IIf(nJusLin == NIL, DT_LEFT, nJusLin)
   ::picture := cPict
   ::bValid := bValid
   ::bWhen := bWhen
   ::aList := aItem
   ::bColorBlock := bColorBlock
   ::bHeadClick := bHeadClick
   ::footing := ""
   ::tcolor := tcolor
   ::bcolor := bcolor
   ::bClick := bClick

RETURN Self

METHOD HColumn:Visible(lVisible)

   IF lVisible != NIL
      IF !lVisible
         ::Hide()
      ELSE
         ::Show()
      ENDIF
      ::lHide := !lVisible
   ENDIF

RETURN !::lHide

METHOD HColumn:Hide()

   ::lHide := .T.
   ::oParent:Refresh()

RETURN ::lHide

METHOD HColumn:Show()

   ::lHide := .F.
   ::oParent:Refresh()

RETURN ::lHide

METHOD HColumn:Editable(lEditable)

   IF lEditable != NIL
      ::lEditable := lEditable
      ::oParent:lEditable := lEditable .OR. AScan(::oParent:aColumns, {|c|c:lEditable}) > 0
      hwg_RedrawWindow(::oParent:handle, RDW_INVALIDATE + RDW_INTERNALPAINT)
   ENDIF

RETURN ::lEditable

METHOD HColumn:SortMark(nSortMark)

    IF nSortMark != NIL
      AEval(::oParent:aColumns, {|c|c:nSortMark := 0})
      ::oParent:lHeadClick := .T.
      hwg_InvalidateRect(::oParent:handle, 0, ::oParent:x1, ::oParent:y1 - ::oParent:nHeadHeight * ::oParent:nHeadRows, ::oParent:x2, ::oParent:y1)
      ::oParent:lHeadClick := .F.
      ::nSortMark := nSortMark
    ENDIF

RETURN ::nSortMark

METHOD HColumn:Value(xValue)

   Local varbuf

   IF xValue != NIL
      varbuf := xValue
      IF ::oParent:Type == BRW_DATABASE
         IF (::oParent:Alias)->(RLock())
            (::oParent:Alias)->(Eval(::block, varbuf, ::oParent, ::Column))
            (::oParent:Alias)->(DBUnlock())
            #ifdef __SYGECOM__   
            (::oParent:Alias)->(DBcommit())
            #endif
         ELSE
             hwg_MsgStop("Can't lock the record!")
         ENDIF
      ELSEIF ::oParent:nRecords  > 0
         Eval(::block, varbuf, ::oParent, ::Column)
      ENDIF
      // Execute block after changes are made
      IF ::oParent:bUpdate != NIL .AND. !::oParent:lSuspendMsgsHandling
         ::oParent:lSuspendMsgsHandling := .T.
         Eval(::oParent:bUpdate, ::oParent, ::Column)
         ::oParent:lSuspendMsgsHandling := .F.
      END
   ELSE
      IF ::oParent:Type == BRW_DATABASE
         varbuf := (::oParent:Alias)->(Eval(::block, , ::oParent, ::Column))
      ELSEIF ::oParent:nRecords  > 0
         varbuf := Eval(::block,, ::oParent, ::Column)
      ENDIF
   ENDIF

RETURN varbuf
