//
// $Id: drawwidg.prg 1740 2011-09-23 12:06:53Z LFBASSO $
//
// HWGUI - Harbour Win32 GUI library source code:
// Bitmaps handling
//
// Copyright 2001 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://www.geocities.com/alkresin/
//

#include <hbclass.ch>
#include "hwgui.ch"

//-------------------------------------------------------------------------------------------------------------------//

CLASS HBitmap INHERIT HObject

   CLASS VAR aBitmaps INIT {}

   DATA handle
   DATA name
   DATA nWidth
   DATA nHeight
   DATA nCounter INIT 1

   METHOD AddResource(name, nFlags, lOEM, nWidth, nHeight)
   METHOD AddStandard(nId)
   METHOD AddFile(name, hDC, lTranparent, nWidth, nHeight)
   METHOD AddWindow(oWnd, lFull)
   METHOD Draw(hDC, x1, y1, width, height) INLINE hwg_DrawBitmap(hDC, ::handle, SRCCOPY, x1, y1, width, height)
   METHOD Release()

ENDCLASS

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBitmap:AddResource(name, nFlags, lOEM, nWidth, nHeight)

   LOCAL lPreDefined := .F.
   LOCAL item
   LOCAL aBmpSize

   IF nFlags == NIL
      nFlags := LR_DEFAULTCOLOR
   ENDIF
   IF lOEM == NIL
      lOEM := .F.
   ENDIF
   IF hb_IsNumeric(name)
      name := LTrim(Str(name))
      lPreDefined := .T.
   ENDIF
   FOR EACH item IN ::aBitmaps
      IF item:name == name .AND. (nWidth == NIL .OR. nHeight == NIL)
         item:nCounter++
         RETURN item
      ENDIF
   NEXT
   IF lOEM
      ::handle := hwg_LoadImage(0, Val(name), IMAGE_BITMAP, NIL, NIL, hwg_bitor(nFlags, LR_SHARED))
   ELSE
      //::handle := hwg_LoadImage(NIL, IIf(lPreDefined, Val(name), name), IMAGE_BITMAP, NIL, NIL, nFlags)
      ::handle := hwg_LoadImage(NIL, IIf(lPreDefined, Val(name), name), IMAGE_BITMAP, nWidth, nHeight, nFlags)
   ENDIF
   ::name := name
   aBmpSize := hwg_GetBitmapSize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBitmap:AddStandard(nId)

   LOCAL item
   LOCAL aBmpSize
   LOCAL name := "s" + LTrim(Str(nId))

   FOR EACH item IN ::aBitmaps
      IF item:name == name
         item:nCounter++
         RETURN item
      ENDIF
   NEXT
   ::handle := hwg_LoadBitmap(nId, .T.)
   ::name := name
   aBmpSize := hwg_GetBitmapSize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBitmap:AddFile(name, hDC, lTranparent, nWidth, nHeight)

   LOCAL item
   LOCAL aBmpSize
   LOCAL cname
   LOCAL cCurDir

   cname := hwg_CutPath(name)

   FOR EACH item IN ::aBitmaps
      IF item:name == name .AND. (nWidth == NIL .OR. nHeight == NIL)
         item:nCounter++
         RETURN item
      ENDIF
   NEXT

   name := IIf(!File(name) .AND. FILE(hwg_CutPath(name)), hwg_CutPath(name), name)

   IF !File(name)
      cCurDir := DiskName() + ":\" + CurDir()
      name := hwg_SelectFile("Image Files( *.jpg;*.gif;*.bmp;*.ico )", hwg_CutPath(name), hwg_FilePath(name), "Locate " + name) // "*.jpg;*.gif;*.bmp;*.ico"
      DirChange(cCurDir)
   ENDIF

   IF Lower(Right(name, 4)) != ".bmp" .OR. (nWidth == NIL .AND. nHeight == NIL .AND. lTranparent == NIL)
      IF Lower(Right(name, 4)) == ".bmp"
         ::handle := hwg_OpenBitmap(name, hDC)
      ELSE
         ::handle := hwg_OpenImage(name)
      ENDIF
   ELSE
      IF lTranparent != NIL .AND. lTranparent
         ::handle := hwg_LoadImage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE + LR_LOADTRANSPARENT + LR_LOADMAP3DCOLORS)
      ELSE
         ::handle := hwg_LoadImage(NIL, name, IMAGE_BITMAP, nWidth, nHeight, LR_LOADFROMFILE)
      ENDIF
   ENDIF
   IF Empty(::handle)
      RETURN NIL
   ENDIF
   ::name := cname
   aBmpSize := hwg_GetBitmapSize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBitmap:AddWindow(oWnd, lFull)

   LOCAL aBmpSize

   ::handle := hwg_Window2Bitmap(oWnd:handle, lFull)
   ::name := LTrim(hb_valToStr(oWnd:handle)) // TODO: verificar o que ocorre quando for tipo P
   aBmpSize := hwg_GetBitmapSize(::handle)
   ::nWidth := aBmpSize[1]
   ::nHeight := aBmpSize[2]
   AAdd(::aBitmaps, SELF)

RETURN SELF

//-------------------------------------------------------------------------------------------------------------------//

METHOD HBitmap:Release()

   LOCAL item
   LOCAL nlen := Len(::aBitmaps)

   ::nCounter--
   IF ::nCounter == 0
      FOR EACH item IN ::aBitmaps
         IF item:handle == ::handle
            hwg_DeleteObject(::handle)
            #ifdef __XHARBOUR__
            ADel(::aBitmaps, hb_enumIndex())
            #else
            ADel(::aBitmaps, item:__enumIndex())
            #endif
            ASize(::aBitmaps, nlen - 1)
            EXIT
         ENDIF
      NEXT
   ENDIF

RETURN NIL

//-------------------------------------------------------------------------------------------------------------------//

EXIT PROCEDURE hwg_CleanDrawWidgHBitmap

   LOCAL item

   FOR EACH item IN HBitmap():aBitmaps
      hwg_DeleteObject(item:handle)
   NEXT

RETURN

//-------------------------------------------------------------------------------------------------------------------//
