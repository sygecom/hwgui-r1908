//
// $Id: hsayimg.prg 1615 2011-02-18 13:53:35Z mlacecilia $
//
// HWGUI - Harbour Linux (GTK) GUI library source code:
// HSayImage class
//
// Copyright 2005 Alexander S.Kresin <alex@belacy.belgorod.su>
// www - http://kresin.belgorod.su
//

#include <hbclass.ch>
#include "hwgui.ch"

//- HSayImage

CLASS HSayImage INHERIT HControl

   CLASS VAR winclass   INIT "STATIC"
   DATA  oImage

   METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,bInit, ;
                  bSize,ctoolt )
   METHOD Activate()
   METHOD End() INLINE ( ::Super:End(),IIf(::oImage != NIL, ::oImage:Release(), ::oImage := NIL),::oImage := Nil )

ENDCLASS

METHOD New( oWndParent,nId,nStyle,nLeft,nTop,nWidth,nHeight,bInit, ;
                  bSize,ctoolt ) CLASS HSayImage

   ::Super:New( oWndParent,nId,nStyle,nLeft,nTop,               ;
               IIf(nWidth != NIL, nWidth, 0),IIf(nHeight != NIL, nHeight, 0),, ;
               bInit,bSize,,ctoolt )

   ::title   := ""

Return Self

METHOD Activate CLASS HSayImage

   IF !Empty(::oParent:handle)
      ::handle := hwg_CreateStatic( ::oParent:handle, ::id, ;
                  ::style, ::nLeft, ::nTop, ::nWidth, ::nHeight )
      ::Init()
   ENDIF
Return Nil
