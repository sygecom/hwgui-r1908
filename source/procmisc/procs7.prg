//
// Common procedures
//
// Author: Alexander S.Kresin <alex@belacy.belgorod.su>
//         www - http://kresin.belgorod.su
//

FUNCTION HWG_RDSTR(han, strbuf, poz, buflen)
LOCAL stro := "", rez, oldpoz, poz1

   oldpoz := poz
   poz    := At(Chr(10), SubStr(strbuf, poz))
   IF poz == 0
      IF han != NIL
         stro += SubStr(strbuf, oldpoz)
         rez  := Fread(han, @strbuf, buflen)
         IF rez == 0
            RETURN ""
         ELSEIF rez < buflen
            strbuf := SubStr(strbuf, 1, rez) + Chr(10) + Chr(13)
         ENDIF
         poz  := At(Chr(10), strbuf)
         stro += SubStr(strbuf, 1, poz)
      ELSE
         stro += RTrim(SubStr(strbuf, oldpoz))
         poz  := oldpoz + Len(stro)
         IF Len(stro) == 0
            RETURN ""
         ENDIF
      ENDIF
   ELSE
      stro += SubStr(strbuf, oldpoz, poz)
      poz  += oldpoz - 1
   ENDIF
   poz++
   poz1 := Len(stro)
   IF poz1 > 2 .AND. Right(stro, 1) $ Chr(13) + Chr(10)
      IF SubStr(stro, poz1 - 1, 1) $ Chr(13) + Chr(10)
         poz1--
      ENDIF
      stro := SubStr(stro, 1, poz1 - 1)
   ENDIF
RETURN stro

FUNCTION hwg_getNextVar(stroka, varValue)

LOCAL varName, iPosEnd, iPos3
   IF Empty(stroka)
      RETURN ""
   ELSE
      IF (iPosEnd := hwg_Find_Z(stroka)) == 0
         iPosEnd := IIf(Right(stroka, 1) = ";", Len(stroka), Len(stroka) + 1)
      ENDIF
      ipos3    := hwg_Find_Z(Left(stroka, iPosEnd - 1), ":")
      varName  := RTrim(LTrim(Left(stroka, IIf(ipos3 == 0, iPosEnd, iPos3) - 1)))
      varValue := IIf(iPos3 != 0, LTrim(SubStr(stroka, iPos3 + 2, iPosEnd - iPos3 - 2)), NIL)
      stroka   := SubStr(stroka, iPosEnd + 1)
   ENDIF
RETURN varName

FUNCTION HWG_FIND_Z(stroka, symb)

   LOCAL poz
   LOCAL poz1 := 1
   LOCAL i
   LOCAL j
   LOCAL ms1 := "(){}[]'" + '"'
   LOCAL ms2 := {0, 0, 0, 0, 0, 0, 0, 0}

   symb := IIf(symb == NIL, ",", symb)
   DO WHILE .T.
      poz := At(symb, SubStr(stroka, poz1))
      IF poz == 0
         EXIT
      ELSE
         poz := poz + poz1 - 1
      ENDIF
      FOR i := poz1 TO poz - 1
         IF (j := At(SubStr(stroka, i, 1), ms1)) != 0
            ms2[j]++
         ENDIF
      NEXT
      IF ms2[1] == ms2[2] .AND. ms2[3] == ms2[4] .AND. ;
                 ms2[5] == ms2[6] .AND. ms2[7] % 2 == 0 .AND. ms2[8] % 2 == 0
         EXIT
      ELSE
         IF (j := At(SubStr(stroka, poz, 1), ms1)) != 0
            ms2[j]++
         ENDIF
         poz1 := poz + 1
      ENDIF
   ENDDO
   RETURN poz

#ifdef __WINDOWS__

FUNCTION hwg_Fchoice()

   RETURN 1

#endif

FUNCTION hwg_CutExten(fname)

LOCAL i
RETURN IIf((i := Rat(".", fname)) == 0, fname, SubStr(fname, 1, i - 1))

FUNCTION hwg_FilExten(fname)

LOCAL i
RETURN IIf((i := Rat(".", fname)) == 0, "", SubStr(fname, i + 1))

FUNCTION hwg_FilePath(fname)

LOCAL i
RETURN IIf((i := Rat("\", fname)) == 0, ;
            IIf((i := Rat("/", fname)) == 0, "", Left(fname, i)), ;
            Left(fname, i))

FUNCTION hwg_CutPath(fname)

LOCAL i
RETURN IIf((i := Rat("\", fname)) == 0, ;
            IIf((i := Rat("/", fname)) == 0, fname, SubStr(fname, i + 1)), ;
            SubStr(fname, i + 1))

FUNCTION hwg_NextItem(stroka, lFirst, cSep)

STATIC nPos
LOCAL i, oldPos

   IF (lFirst != NIL .AND. lFirst) .OR. nPos == NIL
      nPos := 1
   ENDIF
   IF cSep == NIL
      cSep := ";"
   ENDIF
   IF nPos != 99999
      oldPos := nPos
      IF (i := At(cSep, SubStr(stroka, nPos))) == 0
         nPos := 99999
         RETURN LTrim(RTrim(SubStr(stroka, oldPos)))
      ELSE
         nPos += i
         RETURN LTrim(RTrim(SubStr(stroka, oldPos, i - 1)))
      ENDIF
   ENDIF
RETURN ""

#pragma BEGINDUMP

#include <hbapi.h>

#ifdef HWGUI_FUNC_TRANSLATE_ON
HB_FUNC_TRANSLATE(RDSTR, HWG_RDSTR);
HB_FUNC_TRANSLATE(GETNEXTVAR, HWG_GETNEXTVAR);
HB_FUNC_TRANSLATE(FIND_Z, HWG_FIND_Z);
#ifdef __WINDOWS__
HB_FUNC_TRANSLATE(FCHOICE, HWG_FCHOICE);
#endif
HB_FUNC_TRANSLATE(CUTEXTEN, HWG_CUTEXTEN);
HB_FUNC_TRANSLATE(FILEXTEN, HWG_FILEXTEN);
HB_FUNC_TRANSLATE(FILEPATH, HWG_FILEPATH);
HB_FUNC_TRANSLATE(CUTPATH, HWG_CUTPATH);
HB_FUNC_TRANSLATE(NEXTITEM, HWG_NEXTITEM);
#endif

#pragma ENDDUMP
