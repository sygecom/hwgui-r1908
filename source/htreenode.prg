//
// HWGUI - Harbour Win32 GUI library source code:
// HTreeNode class
//
// Copyright 2002 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

CLASS HTreeNode INHERIT HObject

   DATA handle
   DATA oTree, oParent
   DATA aItems INIT {}
   DATA bAction, bClick
   DATA cargo
   DATA title
   DATA image1, image2
   DATA lchecked INIT .F.

   METHOD New(oTree, oParent, oPrev, oNext, cTitle, bAction, aImages, lchecked, bClick)
   METHOD AddNode(cTitle, oPrev, oNext, bAction, aImages)
   METHOD Delete(lInternal)
   METHOD FindChild(h)
   METHOD GetText() INLINE hwg_TreeGetNodeText(::oTree:handle, ::handle)
   METHOD SetText(cText) INLINE hwg_TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_TEXT, cText), ::title := cText
   METHOD Checked(lChecked)  SETGET
   METHOD GetLevel(h)

ENDCLASS

METHOD HTreeNode:New(oTree, oParent, oPrev, oNext, cTitle, bAction, aImages, lchecked, bClick)

   LOCAL aItems
   LOCAL i
   LOCAL h
   LOCAL im1
   LOCAL im2
   LOCAL cImage
   LOCAL op
   LOCAL nPos

   ::oTree    := oTree
   ::oParent  := oParent
   ::Title    := cTitle
   ::bAction  := bAction
   ::bClick   := bClick
   ::lChecked := IIf(lChecked == NIL, .F., lChecked)

   IF aImages == NIL
      IF oTree:Image1 != NIL
         im1 := oTree:Image1
         IF oTree:Image2 != NIL
            im2 := oTree:Image2
         ENDIF
      ENDIF
   ELSE
      FOR i := 1 TO Len(aImages)
         cImage := Upper(aImages[i])
         IF (h := AScan(oTree:aImages, cImage)) == 0
            AAdd(oTree:aImages, cImage)
            aImages[i] := IIf(oTree:Type, hwg_LoadBitmap(aImages[i]), hwg_OpenBitmap(aImages[i]))
            hwg_Imagelist_Add(oTree:himl, aImages[i])
            h := Len(oTree:aImages)
         ENDIF
         h--
         IF i == 1
            im1 := h
         ELSE
            im2 := h
         ENDIF
      NEXT
   ENDIF
   IF im2 == NIL
      im2 := im1
   ENDIF

   nPos := IIf(oPrev == NIL, 2, 0)
   IF oPrev == NIL .AND. oNext != NIL
      op := IIf(oNext:oParent == NIL, oNext:oTree, oNext:oParent)
      FOR i := 1 TO Len(op:aItems)
         IF op:aItems[i]:handle == oNext:handle
            EXIT
         ENDIF
      NEXT
      IF i > 1
         oPrev := op:aItems[i - 1]
         nPos := 0
      ELSE
         nPos := 1
      ENDIF
   ENDIF
   ::handle := hwg_TreeAddNode(Self, oTree:handle, ;
                            IIf(oParent == NIL, NIL, oParent:handle), ;
                            IIf(oPrev == NIL, NIL, oPrev:handle), nPos, cTitle, im1, im2)

   aItems := IIf(oParent == NIL, oTree:aItems, oParent:aItems)
   IF nPos == 2
      AAdd(aItems, Self)
   ELSEIF nPos == 1
      AAdd(aItems, NIL)
      AIns(aItems, 1)
      aItems[1] := Self
   ELSE
      AAdd(aItems, NIL)
      h := oPrev:handle
      IF (i := AScan(aItems, {|o|o:handle == h})) == 0
         aItems[Len(aItems)] := Self
      ELSE
         AIns(aItems, i + 1)
         aItems[i + 1] := Self
      ENDIF
   ENDIF
   ::image1 := im1
   ::image2 := im2

   RETURN Self

METHOD HTreeNode:AddNode(cTitle, oPrev, oNext, bAction, aImages)
   
   LOCAL oParent := Self
   LOCAL oNode := HTreeNode():New(::oTree, oParent, oPrev, oNext, cTitle, bAction, aImages)

   RETURN oNode

METHOD HTreeNode:Delete(lInternal)
   
   LOCAL h := ::handle
   LOCAL j
   LOCAL alen
   LOCAL aItems

   IF !Empty(::aItems)
      alen := Len(::aItems)
      FOR j := 1 TO alen
         ::aItems[j]:Delete(.T.)
         ::aItems[j] := NIL
      NEXT
   ENDIF
   hwg_Tree_ReleaseNode(::oTree:handle, ::handle)
   hwg_SendMessage(::oTree:handle, TVM_DELETEITEM, 0, ::handle)
   IF lInternal == NIL
      aItems := IIf(::oParent == NIL, ::oTree:aItems, ::oParent:aItems)
      j := AScan(aItems, {|o|o:handle == h})
      ADel(aItems, j)
      ASize(aItems, Len(aItems) - 1)
   ENDIF
   // hwg_DecreaseHolders(::handle)

   RETURN NIL

METHOD HTreeNode:FindChild(h)
   
   LOCAL aItems := ::aItems
   LOCAL i
   LOCAL alen := Len(aItems)
   LOCAL oNode

   FOR i := 1 TO alen
      IF aItems[i]:handle == h
         RETURN aItems[i]
      ELSEIF !Empty(aItems[i]:aItems)
         IF (oNode := aItems[i]:FindChild(h)) != NIL
            RETURN oNode
         ENDIF
      ENDIF
   NEXT
   RETURN NIL

METHOD HTreeNode:Checked(lChecked)
   
   LOCAL state

   IF lChecked != NIL
      hwg_TreeSetItem(::oTree:handle, ::handle, TREE_SETITEM_CHECK, IIf(lChecked, 2, 1))
      ::lChecked := lChecked
   ELSE
      state := hwg_SendMessage(::oTree:handle, TVM_GETITEMSTATE, ::handle,, TVIS_STATEIMAGEMASK) - 1
      ::lChecked := int(state / 4092) == 2
   ENDIF
   RETURN ::lChecked

METHOD HTreeNode:GetLevel(h)

   LOCAL iLevel := 1
   LOCAL oNode := IIf(Empty(h), Self, h)

   DO WHILE (oNode:oParent) != NIL
       oNode := oNode:oParent
       iLevel++
   ENDDO
   RETURN iLevel
