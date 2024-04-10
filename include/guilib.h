/*
 *$Id: guilib.h 1625 2011-08-05 13:14:50Z druzus $
 */

#include "hbapi.h"

#define WND_DLG_RESOURCE      10
#define WND_DLG_NORESOURCE    11
#define ST_ALIGN_HORIZ        0     // Icon/bitmap on the left, text on the right
#define ST_ALIGN_VERT         1     // Icon/bitmap on the top, text on the bottom
#define ST_ALIGN_HORIZ_RIGHT  2     // Icon/bitmap on the right, text on the left
#define ST_ALIGN_OVERLAP      3     // Icon/bitmap on the same space as text

#ifdef HWG_USE_POINTER_ITEM
   #define HB_RETHANDLE( h )        hb_retptr( ( void * ) ( h ) )
   #define HB_PARHANDLE( n )        hb_parptr( n )
   #define HB_STOREHANDLE( h, n )   hb_storptr( ( void * ) ( h ), n )
   #define HB_PUTHANDLE( i, h )     hb_itemPutPtr( i, ( void * ) ( h ) )
   #define HB_GETHANDLE( i )        hb_itemGetPtr( i )
   #define HB_GETPTRHANDLE( i ,n )  hb_arrayGetPtr( i , n )
   #define HB_PUSHITEM( i )         hb_vmPushPointer( ( void * )i )
#else
   //#ifdef __XHARBOUR__
      #define HB_RETHANDLE( h )        hb_retnl( ( LONG ) ( h ) )
      #define HB_PARHANDLE( n )        ( ( LONG ) hb_parnl( n ) )
      #define HB_STOREHANDLE( h, n )   hb_stornl( ( LONG ) ( h ), n )
      #define HB_PUTHANDLE( i, h )     hb_itemPutNL( i, ( LONG ) ( h ) )
      #define HB_GETHANDLE( i )        ( ( LONG ) hb_itemGetNL( i ) )
      #define HB_GETPTRHANDLE( i ,n )  hb_arrayGetNL( i , n )
      #define HB_PUSHITEM( i )         hb_vmPushLong( ( LONG )i )
   //#else
   //   #define HB_RETHANDLE( h )        hb_retnint( ( HB_PTRUINT ) ( h ) )
   //   #define HB_PARHANDLE( n )        ( ( HB_PTRUINT ) hb_parnint( n ) )
   //   #define HB_STOREHANDLE( h, n )   hb_stornint( ( HB_PTRUINT ) ( h ), n )
   //   #define HB_PUTHANDLE( i, h )     hb_itemPutNInt( i, ( HB_PTRUINT ) ( h ) )
   //   #define HB_GETHANDLE( i )        ( ( HB_PTRUINT ) hb_itemGetNInt( i ) )
   //   #define HB_GETPTRHANDLE( i ,n )  hb_arrayGetNInt( i , n )
   //   #define HB_PUSHITEM( i )         hb_vmPushNumInt( ( HB_PTRUINT )i )
   //#endif
#endif

#ifndef HB_SIZEOFARRAY
   #define HB_SIZEOFARRAY( var )    ( sizeof( var ) / sizeof( *var ) )
#endif

#if defined( HARBOUR_2005 )
   #define hb_dynsymSymbol( h )     ( ( h )->pSymbol )
#endif
#if defined( HARBOUR_2005 ) || \
    ( defined( __XHARBOUR__ ) && !defined( hb_itemPutCLPtr ) )
   #define hb_dynsymIsFunction( h ) ( ( h )->pSymbol->value.pFunPtr != NULL )
   #define hb_itemPutCLPtr( pItem, szText, ulLen ) hb_itemPutCPtr( pItem, szText, ulLen )
#endif

#ifndef HB_PATH_MAX
   #define HB_PATH_MAX 264
#endif

#if !defined( FHANDLE ) && ( __HARBOUR__ - 0 < 0x020000 )
   typedef FHANDLE HB_FHANDLE;
#endif
#if defined( __XHARBOUR__ ) || ( __HARBOUR__ - 0 < 0x020000 )
   #define hb_storvni      hb_storni

   #define HB_LONG         LONG
   #define HB_ULONG        ULONG

   typedef unsigned char   HB_BYTE;
   typedef int             HB_BOOL;
   typedef unsigned short  HB_USHORT;
   typedef ULONG           HB_SIZE;
#endif

#if !defined( HB_FALSE )
   #define HB_FALSE      0
#endif
#if !defined( HB_TRUE )
   #define HB_TRUE       (!0)
#endif
#if !defined( HB_ISNIL )
   #define HB_ISNIL( n )         ISNIL( n )
   #define HB_ISCHAR( n )        ISCHAR( n )
   #define HB_ISNUM( n )         ISNUM( n )
   #define HB_ISLOG( n )         ISLOG( n )
   #define HB_ISDATE( n )        ISDATE( n )
   #define HB_ISMEMO( n )        ISMEMO( n )
   #define HB_ISBYREF( n )       ISBYREF( n )
   #define HB_ISARRAY( n )       ISARRAY( n )
   #define HB_ISOBJECT( n )      ISOBJECT( n )
   #define HB_ISBLOCK( n )       ISBLOCK( n )
   #define HB_ISPOINTER( n )     ISPOINTER( n )
   #define HB_ISHASH( n )        ISHASH( n )
   #define HB_ISSYMBOL( n )      ISSYMBOL( n )
#endif
