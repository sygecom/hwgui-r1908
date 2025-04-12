/*
 * $Id: XMLRUN.prg 1615 2011-02-18 13:53:35Z mlacecilia $
 *
 * The Runtime for xml (create from designer.exe)
 *
 * Build : batch file Bldxml.bat
 * Using xmlrun.exe (can be changed to any name what ever you like, ex: Inventory.exe )
 * Three way:
 *  a.Portable Runtime
 *    1.Create text file name xmlrun.def
 *    2.write <main.xml name> like :  inventory.xml
 *    3.Create sortcut
 *  b.Selection Style
 *    Just run xmlrun.exe and select the xml's file
 *  c.Direct Call
 *    xmlrun <file.xml>
 *
 * as a part of Hwgui Copyright 2004-2007 Alexander S.Kresin <alex@belacy.belgorod.su>
 * www - http://kresin.belgorod.su
*/


*/

#include "windows.ch"
#include "guilib.ch"
#include <hbextern.ch>
#include <hbclass.ch>
#include "hxml.ch"
#include <dbStruct.ch>
#include <Common.ch>
#include <inkey.ch>
#include <fileio.CH>

#DEFINE FALSE .F.
#DEFINE TRUE .T.
#define  MAX_RECENT_FILES  5

/*
REQUEST GETA_OFPAN, pINf, saveArray, RestArray, SureN, SureC, SureD
REQUEST RICHPERIODE, RICHSCOPE, RICHOPEN, SAVESESSION, RESTSESSION, GETBATASTGL, V_ONE
EXTERNAL RECURDEL, DSTAMPUSER
*/

REQUEST DBFCDX, DBFFPT
REQUEST ORDKEYNO, ORDKEYCOUNT, ORDSCOPE
REQUEST __RUN


REQUEST HCtrlTmpl, HFormTmpl

REQUEST HWG_DRAWEDGE
REQUEST HWG_DRAWICON
REQUEST HWG_ELLIPSE
REQUEST HWG_SETWINDOWFONT
REQUEST HWG_INITMONTHCALENDAR
REQUEST HWG_INITTRACKBAR
REQUEST BARCODE


EXTERNAL HTIMER,  HWG_SHELLABOUT, ENDDIALOG

REQUEST HMAINWINDOW

EXTERNAL HCHECKBUTTON, HEDIT, HRADIOBUTTON, HTREE
EXTERNAL HBROWSE, HPANEL, HCOMBOBOX, HOWNBUTTON, HPRINTER, HWG_CHECKMENUITEM, HWG_ISCHECKEDMENUITEM
EXTERNAL HWG_COPYSTRINGTOCLIPBOARD, HWG_ENABLEWINDOW, HWG_DESTROYWINDOW, HWG_HIDEWINDOW, HWG_SHOWWINDOW, HWG_ISWINDOWENABLED, HWG_SETWINDOWTEXT

EXTERNAL HWG_CREATEENHMETAFILE, HWG_CREATEMETAFILE, HWG_CLOSEENHMETAFILE, HWG_DELETEENHMETAFILE, HWG_PLAYENHMETAFILE
EXTERNAL HWG_SELECTFONT, HWG_SELECTFILE, HWG_SAVEFILE, HWG_PRINTSETUP
//EXTERNAL HWG_CONTEXTMENU

EXTERNAL HWG_RDINI, HWG_CHOOSECOLOR, HWG_OPENREPORT
EXTERNAL HSAYFIMAGE, HWG_MSGYESNO, HWG_MSGOKCANCEL, HWG_MSGEXCLAMATION, HUPDOWN
EXTERNAL HTAB, HDATEPICKER, HWG_SHELLEXECUTE, HWG_SETTOPMOST
EXTERNAL HWG_REMOVETOPMOST, HPROGRESSBAR, HRECT, HWG_GETDESKTOPWIDTH

//REQUEST HB_CODEPAGE_RU866
//REQUEST HB_CODEPAGE_RUKOI8
//REQUEST HB_CODEPAGE_RU1251

REQUEST HICON, HBITMAP
REQUEST __RUN

EXTERNAL DBCREATE, DBUSEAREA, DBCREATEINDEX, DBSEEK, DBCLOSEAREA, DBSELECTAREA, DBUNLOCK, DBUNLOCKALL
EXTERNAL BOF, EOF, DBF, DBAPPEND, DBCLOSEALL, DBCLOSEAREA, DBCOMMIT,DBCOMMITALL, DBCREATE
EXTERNAL DBDELETE, DBFILTER, DBGOBOTTOM, DBGOTO, DBGOTOP, DBRLOCK, DBRECALL, DBDROP, DBEXISTS
EXTERNAL DBRLOCKLIST, DBRUNLOCK,  LOCK, RECNO, RECLOCK, DBSETFILTER, DBFILEGET, DBFILEPUT
EXTERNAL DBSKIP, DBSTRUCT, DBTABLEEXT, DELETED, DBINFO, DBORDERINFO, DBRECORDINFO
EXTERNAL FCOUNT, FIELDDEC, FIELDGET, FIELDNAME, FIELDLEN, FIELDPOS, FIELDPUT
EXTERNAL FIELDTYPE, FLOCK, FOUND, HEADER, LASTREC, LUPDATE, NETERR, AFIELDS
EXTERNAL RECCOUNT, RECSIZE, SELECT, ALIAS, DBF2TEXT
EXTERNAL __DBZAP, USED, __RDDSETDEFAULT, __DBPACK, __DBAPP, __DBCOPY
EXTERNAL /*ADS,*/ DBFCDX, DBFFPT, SIXCDX

REQUEST  ORDKEYNO, ORDKEYCOUNT, ORDSCOPE, ORDCOUNT, ORDSETFOCUS, DBEVAL
EXTERNAL ORDBAGEXT, ORDBAGNAME, ORDCONDSET, ORDCREATE, ORDDESTROY, ORDFOR
EXTERNAL ORDKEY, ORDKEYCOUNT, ORDKEYNO, ORDKEYGOTO, ORDFINDREC, ORDSKIPRAW
EXTERNAL ORDSKIPUNIQUE, ORDKEYVAL, ORDKEYADD, ORDKEYDEL, ORDDESCEND, ORDISUNIQUE
EXTERNAL ORDCUSTOM, ORDWILDSEEK, ORDLISTADD, ORDLISTCLEAR, ORDLISTREBUILD, ORDNAME
EXTERNAL ORDNUMBER

EXTERNAL RDDSYS, RDDINFO, RDDLIST, RDDSETDEFAULT, RDDREGISTER, RDDNAME

EXTERNAL HWINPRN
EXTERNAL HSPLITTER, HWG_COS, HGRAPH
EXTERNAL HWG_GETDESKTOPHEIGHT, HLISTBOX, HXMLDOC
EXTERNAL HWG_SETMENUCAPTION, HSPLASH, HWG_SETTOOLTIPBALLOON, HWG_LOADRESOURCE
EXTERNAL HIPEDIT, RICHTEXT, HRICHEDIT, MSGRETRYCANCEL, HMONTHCALENDAR
EXTERNAL PRINTDOS, /*, BARCODE */ HSTATICLINK, CREATEOBJECT

//EXTERNAL TPQSERVER
//EXTERNAL PQEXEC
//EXTERNAL OSERVER
//EXTERNAL RUNSCRIPT

EXTERNAL HWG_SELECTFOLDER
REQUEST  PADL, OEMTOANSI


//REQUEST SQLCONNECT, SQLSELECTD, SQLQUERY, SQLGETERR, SQLCLOSE, SQLSTORER
//REQUEST SQLFETCHR, SQLNROWS, SQLDATAS, SQLGETERRNO, SQLlistdb, sqllisttbl, SQLLISTF
//REQUEST SQLFREER, SQLFICOU, SQLAFFROWS, SQLNUMFI, SQLFETCHR, SQLFETCHF
//REQUEST SQLHOSTINFO, SQLSRVINFO, DATATOSQL, FILETOSQLBINARY, SQLFSEEK

/*
EXTERNAL ADSGETRELKEYPOS, ADSSETRELKEYPOS
EXTERNAL ADSCUSTOMIZEAOF
EXTERNAL ADSTESTRECLOCKS
EXTERNAL ADSSetFileType, ADSSetServerType
EXTERNAL ADSSETDATEFORMAT, ADSSETEPOCH

EXTERNAL ADSAPPLICATIONEXIT
EXTERNAL ADSISSERVERLOADED
EXTERNAL ADSGETCONNECTIONTYPE
EXTERNAL ADSUNLOCKRECORD
EXTERNAL ADSGETTABLECONTYPE
EXTERNAL ADSGETSERVERTIME
EXTERNAL ADSISTABLELOCKED
EXTERNAL ADSISRECORDLOCKED
EXTERNAL ADSLOCKING
EXTERNAL ADSRIGHTSCHECK
EXTERNAL ADSSETCHARTYPE
EXTERNAL ADSGETTABLECHARTYPE
EXTERNAL ADSSETDEFAULT
EXTERNAL ADSSETSEARCHPATH
EXTERNAL ADSSETDELETED
EXTERNAL ADSSETEXACT
EXTERNAL ADSBLOB2FILE, ADSFILE2BLOB

EXTERNAL ADSKEYNO, ADSKEYCOUNT
EXTERNAL ADSADDCUSTOMKEY
EXTERNAL ADSDELETECUSTOMKEY


EXTERNAL ADSCLEARAOF, ADSEVALAOF, ADSGETAOFOPTLEVEL, ADSISRECORDINAOF
EXTERNAL ADSREFRESHAOF, ADSSETAOF

EXTERNAL ADSGETFILTER
EXTERNAL ADSGETTABLEALIAS
EXTERNAL ADSISRECORDVALID

EXTERNAL ADSENABLEENCRYPTION, ADSDISABLEENCRYPTION, ADSISENCRYPTIONENABLED
EXTERNAL ADSENCRYPTTABLE, ADSDECRYPTTABLE, ADSISTABLEENCRYPTED
EXTERNAL ADSENCRYPTRECORD, ADSDECRYPTRECORD, ADSISRECORDENCRYPTED
EXTERNAL ADSCONNECT, ADSDISCONNECT

EXTERNAL ADSCREATESQLSTATEMENT, ADSEXECUTESQLDIRECT
EXTERNAL ADSPREPARESQL, ADSEXECUTESQL

EXTERNAL ADSCLOSEALLTABLES, ADSWRITEALLRECORDS, ADSREFRESHRECORD
EXTERNAL ADSCOPYTABLE, ADSCONVERTTABLE
EXTERNAL ADSREGCALLBACK, ADSCLRCALLBACK

EXTERNAL ADSISINDEXED, ADSREINDEX
EXTERNAL ADSISEXPRVALID, ADSGETNUMINDEXES

EXTERNAL ADSCONNECTION, ADSGETHANDLETYPE
EXTERNAL ADSGETLASTERROR, ADSGETNUMOPENTABLES, ADSSHOWERROR
EXTERNAL ADSBEGINTRANSACTION, ADSCOMMITTRANSACTION
EXTERNAL ADSFAILEDTRANSACTIONRECOVERY, ADSINTRANSACTION, ADSROLLBACK


EXTERNAL ADSVERSION
EXTERNAL ADSCACHERECORDS, ADSCACHEOPENTABLES, ADSCACHEOPENCURSORS
EXTERNAL ADSGETNUMACTIVELINKS
EXTERNAL ADSDDADDTABLE, ADSDDADDUSERTOGROUP
EXTERNAL ADSCONNECT60, ADSDDCREATE, ADSDDCREATEUSER
EXTERNAL ADSDDGETDATABASEPROPERTY, ADSDDSETDATABASEPROPERTY, ADSDDGETUSERPROPERTY


EXTERNAL ADSTESTLOGIN
EXTERNAL ADSRESTRUCTURETABLE
EXTERNAL ADSCOPYTABLECONTENTS
EXTERNAL ADSDIRECTORY
EXTERNAL ADSCHECKEXISTENCE
EXTERNAL ADSDELETEFILE
EXTERNAL ADSSTMTSETTABLEPASSWORD
//EXTERNAL ADSCLOSECACHEDTABLES

EXTERNAL ADSMGCONNECT, ADSMGDISCONNECT, ADSMGGETINSTALLINFO
EXTERNAL ADSMGGETACTIVITYINFO, ADSMGGETCOMMSTATS, ADSMGRESETCOMMSTATS
EXTERNAL ADSMGGETUSERNAMES, ADSMGGETLOCKOWNER, ADSMGGETSERVERTYPE
//ADSMGGETOPENTABLES
EXTERNAL ADSMGKILLUSER, ADSMGGETHANDLE
*/

FUNCTION Main(fileXML)

   LOCAL cFile
   MEMVAR oForm
   PUBLIC oForm

 HWG_InitCommonControlsEx()

 rddRegister("DBFCDX", 1)
 rddsetdefault("DBFCDX")
 rddRegister("SIXCDX", 1)
 rddsetdefault("SIXCDX")

 //rddRegister("ADS", 1)
 //rddsetdefault("ADS")
 //AdsSetServerType(1)
 //adsSetFileType(2)

 SET EXCLUSIVE OFF
 SET DELETE ON
 SET CENTURY ON
 SET EPOCH TO 1960


 IF fileXML == NIL

    filexml:=""
    IF FILE("XMLRUN.DEF")
       filexml:=RTrim(MemoLine(MemoRead("XMLRUN.DEF"), 128, 1))
    ENDIF

    IF !FILE(filexml)
    filexml:=hwg_SelectFile("XML FILE (*.XML)", "*.XML")
    ENDIF

 ELSE
    IF  !("XML"$FILEXML)
   FILEXML+=".XML"
    ENDIF
 ENDIF

 IF !FILE(FILEXML)
     RETURN FALSE
 ENDIF

 oForm:=HFormTmpl():Read(filexml)
 oForm:Show()

 //oForm:Close()

RETURN TRUE


FUNCTION rmatch(c,f)
 RETURN (AllTrim(c) == "" .OR. Upper(AllTrim(c)) $ Upper(f))



#define NET_WAIT     0.5   // Seconds to wait between between retries
#define NET_SECS     2     // Number of seconds to continue retry




#xtranslate sx_SetScope(<n>[,<cScope>]) => OrdScope(<n>[,<cScope>])
#xtranslate sx_ClrScope(<n>)            => OrdScope(<n>)
#xtranslate sx_TableName()              => dbf()
#xtranslate sx_iNDexName()              => OrdName()
#xtranslate sx_SetPass(<cPassWord>)     => TONE(10)
#xtranslate sx_I_IndexName()            => OrdBagName()     // Show index name
#xtranslate xx_I_TagName()              => OrdName()

//#xtranslate Sx_KeysIncluded()         =>
//#xtranslate Sx_Step()                 =>
//#xtranslate Sx_TagCount()             =>
//#xtranslate Sx_TagInfo()              =>

#xtranslate Sx_Thermometer(nTag)      => TONE(10)
#xtranslate SwpRUnCmd(<cCommand>,<a>,<b>,<c>)      => __RUN(<cCommand>)
#xtranslate BliDemDte()                => date()+1000

 /*
 ordkeycount()
 ordname()
 ordkeyno()
 ordNumber()
 dbinfo()
 dbOrderinfo()
 dbfieldinfo()
 dbrecordinfo()
 dbfileget()
 dbfileput()
 dbdrop()
 dbexist()
 */



#command INDEX ON <key> TAG <(tag)> [OF <(cdx)>]                           ;
         [FOR <for>]                                                       ;
         [<all:   ALL>]                                                    ;
         [WHILE   <while>]                                                 ;
         [NEXT    <next>]                                                  ;
         [RECORD  <rec>]                                                   ;
         [<rest:  REST>]                                                   ;
         [<asc:   ASCENDING>]                                              ;
         [<dec:   DESCENDING>]                                             ;
         [<u:     UNIQUE>]                                                 ;
         [<empty: EMPTY>]                                                  ;
         [<cur:   USECURRENT>]                                             ;
         [<cur:   SUBINDEX>]                                               ;
         [EVAL    <opt> [EVERY <step>]]                                    ;
         [OPTION  <opt> [STEP <step>]]                                     ;
         [<add:   ADDITIVE>]                                               ;
         [<shad:  SHADOW>]                                                 ;
         [<filt:  FILTERON>]                                               ;
         [NOOPTIMIZE]                                                      ;
                                                                           ;
      => ordCondSet(<"for">, <{for}>,                                      ;
                      if( <.all.>, .T., NIL ),                             ;
                      <{while}>,                                           ;
                      <{opt}>, <step>    ,                                 ;
                      RECNO(), <next>, <rec>,                              ;
                      if( <.rest.>, .T., NIL ),                            ;
                      if( (<.dec.> .AND. !<.asc.>), .T., NIL ),            ;
                      .T., <(cdx)>, <.cur.>, <.empty.>, .F., <.add.>,      ;
                      <.shad.>, <.filt.>)                                  ;
       ; ordCreate(<(cdx)>, <(tag)>, <"key">, <{key}>, [<.u.>])



FUNCTION netuse(cDatabase, cAlias, lExclusive, nSeconds, cPassword)
   
   LOCAL lforever
   LOCAL lFirstPass := .T.

   if(nSeconds == NIL, nSeconds:=20,)

   lforever := (nSeconds == 0)
   keyboard chr(255)
   inkey()

   do while (lforever .OR. nSeconds > 0) .AND. lastkey() != K_ESC

      if !lfirstPass

	 /* => Koreksi Ke GUI
         @ maxrow()-2, 00 clear
         @ maxrow()-1, 00 say ;
         padc([Trying to open database. Will keep trying for ] ;
         + LTrim(Str(nSeconds, 4, 1))+[seconds], 80)
         @ maxrow(), 00 say padc([Hit Esc to abort], 80)
	 */

         lFirstPass := .F.

      endif

      if lExclusive
         use (cdatabase) alias (calias) /* via "ADS" */ exclusive new
      else
         use (cdatabase) alias (calias) /* via "ADS" */ shared new
      endif

      if !neterr()                     // USE SUCCEEDS
	 if cPassWord != NIL
	    sx_SetPass(cPassWord)
	 endif

	 RETURN .T.
      endif
      inkey(.5)                         // WAIT 1/2 SECOND
      nSeconds := nSeconds - .5
   enddo

   RETURN .F.                           // USE FAILS


FUNCTION filelock(nSeconds)

   LOCAL lforever

   lforever := (nSeconds == 0)
   if(nSeconds == NIL, nSeconds:=20,)

   IF Flock()
      RETURN .T.
   ENDIF

   do while (lforever .OR. nSeconds > 0) .AND. lastkey() != K_ESC
      if FLOCK()
         RETURN .T.                     // LOCKED
      endif
      inkey(.5)      // wait 1/2 second
      nSeconds := nSeconds - .5
      hwg_MsgStop("File is in use by another", alias())
   enddo


   hwg_MsgStop("File failed to locked", alias())

 RETURN .F.


FUNCTION reclock(nSeconds)

   LOCAL lforever
   LOCAL oldPos := Recno()

   if DBRLOCK(OldPos)
      RETURN .T.                        // LOCKED
   endif

   lforever := (nSeconds == 0)
   nSeconds *= 1.00

   keyboard chr(255)
   inkey()

   do while (lforever .OR. nSeconds > 0) .AND. lastkey() != K_ESC
      if DBRLOCK(OldPos)
         RETURN .T.                     // LOCKED
      endif
      hwg_MsgStop("Record is in use exclusive by another", alias()+" #"+Str(oldpos, 11))
      inkey(.5)      // wait 1/2 second
      nSeconds = nSeconds - .5
   enddo



   hwg_MsgStop("Record failed to locked", alias()+" #"+Str(oldpos, 11))

   RETURN .F.                           // NOT LOCKED

   // end function reclock()


FUNCTION addrec(nSeconds)
   
   LOCAL lforever
   LOCAL oldcolor

   append blank

   if !neterr()
      RETURN .T.												// APPEND SUCCESS
   endif

   nSeconds *= 1.00
   lforever := (nSeconds == 0)
   keyboard chr(255)
   inkey()

   do while (lforever .OR. nSeconds > 0) .AND. lastkey() != K_ESC

      /*
      @ maxrow()-2, 00 clear
      @ maxrow()-1, 00 say ;
      padc([Trying to add a record. Will keep trying for ] ;
      + LTrim(Str(nSeconds, 4, 1))+[seconds], 80)
      @ maxrow(), 00 say padc([Hit Esc to abort], 80)
      */

      append blank
      if !neterr()
         RETURN .T.
      endif
      inkey(.5)                         // WAIT 1/2 SECOND
      nSeconds := nSeconds  - .5
      hwg_MsgStop("Record is in use exclusive by another")

   enddo


   hwg_MsgStop("Record failed to locked", alias())

   RETURN .F.                           // NOT LOCKED



FUNCTION Usr2infStr(g,lKosong) && usr to informix str

   LOCAL dd := ""
   LOCAL mm := ""
   LOCAL yy
   LOCAL cpress := AllTrim(g:title)
   LOCAL nLen
   LOCAL c := ""
   LOCAL i
   LOCAL nPot := 2

 set date to french

 *** Default Boleh Kosong ***

 if Empty(cPress)

    if lKosong == NIL
       RETURN .T.
    endif

    hwg_MsgInfo("Tidak boleh kosong")
    RETURN .F.
    //RETURN IIf(lKosong == NIL,.T.,.F.)
 end


 //if (ctod(g:buffer)=ctod("  /  /  "))

      cpress:=StrTran(cPress, " ", "")
      cpress:=StrTran(cPress, ".", "")
      cpress:=StrTran(cpress, "-", "")
      cpress:=StrTran(cpress, "/", "")
      cpress:=StrTran(cpress, ",", "")
      nLen:=Len(cpress)

 *:minimum 6  &  max 9 char

 if ((nLen < 6) .OR. (nLen > 9))
     hwg_MsgStop("Pengisian Tanggal Belum Benar!!!")
     RETURN .F.
 end

 *:----------------6-------6-------7---------8----------9---
 *:kemungkinan   ddmmyy, dmmmyy, ddmmmyy, ddmmyyyy, ddmmmyyyy!
 *:     	 999999  9AAA99  99AAA99  99999999  99AAA9999

       c:=""

       for i:=1 to nLen
           c+= if(isdigit(subst(cPress, i, 1)), "9", "A")
       next

       *:Kalau 2 Char Pertama Adalah Angka
       cPress:= IIf(Left(c, 2) == "99", cPress, "0" + cPress)
            c:= IIf(Left(c, 2) == "99", c, "9" + c)

	*:isi Hari
        dd := Left(cPress, 2)+"."


	if subst(c, 3, 3)="AAA"

	   mm:=subst(cPress, 3, 3)
	   mm:=transform( Lower(mm), "!xx")

	   *:Koreksi untuk ejaan Inggris
	   mm:=StrTran( mm, "Peb", "Feb")
	   mm:=StrTran( mm, "May", "Mei")
	   mm:=StrTran( mm, "Aug", "Agt")
	   mm:=StrTran( mm, "Agu", "Agt")
	   mm:=StrTran( mm, "Nov", "Nop")
	   mm:=StrTran( mm, "Dec", "Des")
	   mm:=StrTran( mm, "Oct", "Okt")

           mm:=Str((at(mm, "JanFebMarAprMeiJunJulAgtSepOktNopDes") + 2) / 3, 2)+"."

	   nPot--

        else

	   mm:=subst(cpress, 3, 2)+"."

        end

	   yy := Right(cPress, ((Len(c) - Len(dd + mm)) + nPot))

	   if Len(yy) == 2
	      yy:= Left(dtos(date()), 2)+yy
	   endif

      if  !HB_IsDate(ctod(dd+mm+yy)) .OR. (ctod(dd+mm+yy) == ctod("  /  /  "))
          hwg_MsgStop("Pengisian Tanggal Belum Benar!!!")
          RETURN .F.
      else
       g:SetGet(d2infstr(ctod(dd + mm + yy)))
       g:refresh()
      end

 RETURN .T.





FUNCTION d2infstr(d) && date to informix style string

   LOCAL dd
   LOCAL mmm
   LOCAL yyyy

  if Empty(d); RETURN "           "; end

  dd := Right(dtos(d), 2);  yyyy := Left(dtos(d), 4)

  mmm:=subst("JanFebMarAprMeiJunJulAgtSepOktNopDes",month(d) * 3 - 2, 3)

 RETURN (dd+"-"+mmm+"-"+yyyy)





FUNCTION infstr2d(s) && informix string to date

   LOCAL dd := Left(s, 2)+"/"
   LOCAL yy := "/"+Right(s, 4)
   LOCAL mm

 mm := Str((At(subst(s, 4, 3), "JanFebMarAprMeiJunJulAgtSepOktNopDes") + 2) / 3, 2)

 RETURN ctod(dd+mm+yy)

