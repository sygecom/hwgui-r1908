/*
 *  Editor de Codigos Fontes                 xHarbour/HwGUI
 *
 *  Editor.prg           Novembro de  2003
 *
 *  Copyright (c) Rodnei Hernandes Lino <lhr@enetec.com.br>
 *  By HwGUI for Alexander Kresin
 *
 */
*--------------------------------------------------------------------
#define HB_OS_WIN_32_USED
#define _WIN32_WINNT 0x0400
#define _WIN32_IE    0x0400
#define OEMRESOURCE
#define ID_TEXTO  300
#include "windows.ch"
#include "guilib.ch"
#include "fileio.ch"
#include 'common.ch'
#define IDC_STATUS  2001
#define false .F.
#define true  .T.
//
//WM_USER=120
#define EM_SETBKGNDCOLOR 1091
#define FT_MATCHCASE = 4
#define FT_WHOLEWORD = 2
#define EM_FINDTEXT = 199
*****************
FUNCTION Main()
*****************
local oPanel ,oIcon := HIcon():AddRESOURCE( "MAINICON" )
public alterado:=.F.,;
       ID_COLORB:=8454143,;
       ID_COLORF:=0,;
       ID_FONT:=HFont():Add("Courier New", 0, -12)
Set(_SET_INSERT)
//
private oMainWindow,;
        maxi:=.F.,;
        oText,;
        tExto:= '',;
        vText,;
        aTermMetr := { 800 },;
        auto:=5001,;
        oIconchild := HIcon():AddFile( "prg.ico" ),;
        form_panel,;
        cfontenome:='Courier New',;
        texto:=''

//
// variaveis para indiomas
public ID_indioma:=8001,;
       m_arquivo,;
       m_novo,;
       m_abrir,;
       m_salvar,;
       m_salvarcomo,;
       m_fechar,;
       m_sair,;
       m_config,;
       m_fonte,;
       m_color_b,;
       m_indioma,;
       reiniciar,;
       m_janela,;
       m_lado,;
       m_ajuda,;
       m_sobre,;
       desenvolvimento,;
       Bnovo,;
       babrir,;
       Bsalvar,;
       m_pesquisa,;
       m_linha,;
       m_site

// carregando as variaveis de configuracoes
if ! file('config.dat')
     save all like ID_* to config.dat
endif
restore from config.dat additive
//// efetivando
if ID_indioma = 8002
   m_arquivo:='File'
   m_novo   :='New'
   m_abrir  :='Open'
   m_salvar :='Save'
   m_salvarcomo:='Save as..'
   m_fechar :='Close'
   m_sair   :='Exit'
   //
   m_config:='Config'
   m_fonte:='Font'
   m_colorb:='Color Background'
   m_colorf:='Color Font'
   m_indioma:='Language'
   //
   reiniciar:='It is necessary To restart '+chr(13)+chr(10)+'to be loaded the new configurations '
   //
   m_janela:='Windows'
   m_lado:='Title Vertical'
   //
   m_ajuda:='Help'
   m_sobre:='About'
   m_Site:='Internet'
   //
   desenvolvimento:='In development'
   //
   Bnovo:='New'
   babrir:='Open'
   Bsalvar:='Save'
   //
   m_pesquisa:='Search'
   m_localizar:='Find'
   m_Linha:='Goto Line'
   //
   m_editar:='Edit'
   m_seleciona:='Select all'
   m_pesq:='Find all files'

elseif ID_indioma = 8001
   m_arquivo:='Arquivo'
   m_novo   :='Novo'
   m_abrir  :='Abrir'
   m_salvar :='Salvar'
   m_salvarcomo:='Salvar Como..'
   m_fechar :='Fechar'
   m_sair   :='Sair'
   //
   m_config:='Configura��es'
   m_fonte:='Fonte'
   m_colorb:='Cor de Fundo'
   m_colorf:='Cor da Fonte'
   m_indioma:='Idioma'
   //
   reiniciar:='� necess�rio Reiniciar o Editor'+chr(13)+chr(10)+'Para ser carregado as novas configura��es'
   //
   m_janela:='Janelas'
   m_lado:='Lado a lado'
   //
   m_ajuda:='Ajuda'
   m_sobre:='Sobre'
   m_Site:='Pagina na Internet'
   //
   desenvolvimento:='Em desenvolvimento'
   //
   Bnovo:='Novo'
   babrir:='Abrir'
   Bsalvar:='Salvar'
   //
   m_pesquisa:='Localizar'
   m_localizar:='Procurar'
   m_Linha:='Linha'
   m_pesq:='Pesquisar em todos os arquivos'
   //
   m_editar:='Editar'
   m_seleciona:='Selecionar tudo'
 endif

SET CENTURY on
public funcoes:={}
///
 INIT WINDOW oMainWindow MDI;
        ICON oIcon;
        TITLE "HwEDIT for [x]Harbour/Hwgui" ;
        MENUPOS 4

   MENU OF oMainWindow

    ///
     MENU TITLE  "&"+m_arquivo
        MENUITEM "&"+m_novo+chr(9)+'CTRL+N' ACTION novo();
                ACCELERATOR FCONTROL,Asc("N")
        MENUITEM "&"+m_abrir ACTION texto()
        MENUITEM "&"+m_salvar+chr(9)+'CTRL+S' ACTION Salvar_Projeto(1);
              ACCELERATOR FCONTROL,Asc("S")
        SEPARATOR
        MENUITEM "&"+m_salvarcomo ACTION Salvar_Projeto(2)
        MENUITEM "&"+m_fechar ACTION Fecha_texto()
        SEPARATOR
        MENUITEM "&"+m_sair ACTION endwindow()

     ENDMENU
     MENU TITLE "&"+m_editar
         MENUITEM "&"+m_seleciona+chr(9)+'CTRL+A' ACTION {||seleciona()} //;               ACCELERATOR FCONTROL,Asc("A")
     ENDMENU


     MENU TITLE "&"+m_Pesquisa
         MENUITEM "&"+m_localizar+chr(9)+'CTRL+F' ACTION {|o,m,wp,lp|Pesquisa(o,m,wp,lp)} ;
              ACCELERATOR FCONTROL,Asc("F")
         MENUITEM "&"+m_Linha+chr(9)+'CTRL+J' ACTION {||vai()} ;
              ACCELERATOR FCONTROL,Asc("J")
         MENUITEM "&"+m_pesq+chr(9)+'CTRL+G' ACTION {||pesquisaglobal()} ;
              ACCELERATOR FCONTROL,Asc("G")


     ENDMENU

     MENU TITLE "&"+m_config
         MENUITEM "&"+m_fonte ACTION ID_FONT:=HFont():Select(ID_FONT);ID_FONT:Release();save all like ID_* to config.dat
         MENUITEM "&"+m_colorb ACTION cor_fundo()
         MENUITEM "&"+m_colorf ACTION cor_fonte()
         MENU TITLE "&"+m_indioma
             MENUITEM "&Portugues Brazil " ID 8001 ACTION indioma(8001)
             MENUITEM "&Ingles " ID 8002  ACTION indioma(8002)
         ENDMENU
     ENDMENU
     MENU TITLE "&"+m_janela
         MENUITEM "&"+m_lado  ;
            ACTION SendMessage(HWindow():GetMain():handle, WM_MDITILE, MDITILE_HORIZONTAL, 0)
      ENDMENU

     MENU TITLE "&"+m_ajuda
         MENUITEM "&"+m_sobre ACTION aguarde()
         MENUITEM "&"+m_site ACTION ajuda('www.lumainformatica.com.br')
     ENDMENU
   ENDMENU
   //
   painel(oMainWindow)
   SET TIMER tp1 OF oMainWindow ID 1001 VALUE 30 ACTION {||funcao()}
   //
   //ADD STATUS TO oMainWindow ID IDC_STATUS 50, 50, 400, 12, 90, 95, 90
   CheckMenuItem( ,id_indioma, !IsCheckedMenuItem( ,id_indioma ) )
 ACTIVATE WINDOW oMainWindow
Return Nil
****************
FUNCTION novo(tipo)
****************
 private vText:=''
 alterado:=.F.
 i:=alltrim(str(auto))
 oFunc:={}
 private vText&i:=Memoread(vText),;
         oEdit&i
 //
 INIT  window o&i MDICHILD TITLE 'Novo Arquivo-'+i //STYLE WS_VISIBLE + WS_MAXIMIZE
    painel2(o&I,oFunc)
    //
    //@ 650, 2 get COMBOBOX oCombo ITEMS oFunc SIZE 140, 20
    //
    @ 01, 31 richedit oEdit&i TEXT vText&i SIZE 799, 451;
       OF o&I ID ID_TEXTO BACKCOLOR ID_COLORB FONT ID_FONT ;
       STYLE WS_HSCROLL+WS_VSCROLL+ES_LEFT+ES_MULTILINE+ES_AUTOVSCROLL+ES_AUTOHSCROLL
    //
    //
    auto++
    oEdit&i:bOther := {|o,m,wp,lp|richeditProc(o,m,wp,lp)}
    oEdit&i:lChanged := .F.
    //
    ADD STATUS TO o&I ID IDC_STATUS PARTS 50, 50, 400, 12, 90, 95, 90
 o&I:ACTIVATE()
 WriteStatus(  HMainWIndow():GetMdiActive(), 3,'Novo Arquivo')
 WriteStatus( HMainWIndow():GetMdiActive(), 1,'Lin:      0')
 WriteStatus(  HMainWIndow():GetMdiActive(), 2,'Col:      0')
 SendMessage( oEdit&i:Handle, WM_ENABLE, 1, 0 )
 hwg_SetFocus( oEdit&i:Handle )
 SendMessage(oEdit&i:Handle, EM_SETBKGNDCOLOR, 0,ID_COLORB)  // cor de fundo
 re_SetDefault( oEdit&i:handle,ID_COLORF,ID_FONT,,) // cor e fonte padrao
RETURN (.T.)
*****************
FUNCTION Texto()
*****************
 local oIcone := HIcon():AddFile( "CHILD.ico" )
 LOCAL cBuffer   := ''
 LOCAL NPOS      := 0
 LOCAL nlenpos,;
 oCombo
 m_a001:={}
 vText:=SELECTFile("Arquivos Texto","*.PRG",CURDIR())
 oFunc:={}
 oLinha:={}
 if empty(vText)
    return (.T.)
 endif
 i:=alltrim(str(auto))
 private vText&i:=Memoread(vText)
 private oEdit&i
 // pegado funcoes e procedures/////////////////////////////////////
 arq:=FT_FUSE(vText)
 s_lEof:=.F.
 rd_lin:=0
 oCaracter:=0
 r_linha:=0
 linhas:={}
 while ! ft_FEOF()
      linha :=allTrim(Substr( FT_FReadLn( @s_lEof ), 1 ) )
      //
      if len(linha) # 0
        aadd(linhas,len(Substr( FT_FReadLn( @s_lEof ), 1 )))
        //
        if subs(upper(linha), 1, 4)=='FUNC' .or. subs(upper(linha), 1, 4)=='PROC'
           fun:=''
           for f:= 1 to len(linha)+1
              oCaracter++
             if subs(linha,f, 1)= ' '
                for g = f+1 to len(linha)
                       oCaracter++
                    if subs(linha,g, 1)<> ' ' .and. subs(linha,g, 1)<> '(' .and. ! empty(subs(linha,g, 1))
                        fun:=fun+subs(linha,g, 1)
                    elseif  g = len(linha)
                       aadd(oFunc,fun)
                       aadd(funcoes,rd_lin)
                       aadd(oLinha,{rd_lin,r_linha})
                       exit
                    else
                       aadd(oFunc,fun)
                       aadd(oLinha,{rd_lin,r_linha})
                       aadd(funcoes,rd_lin)
                       exit
                    endif
                next g
                exit
             endif
           next f
         endif
      endif
      rd_lin++
      FT_FSKIP( )
 enddo
//
 alterado:=.F.
 //
 INIT  WINDOW o&i MDICHILD TITLE vText
      painel2(o&I,oFunc)
      //
      @ 01, 31 RichEdit oEdit&i TEXT vText&i SIZE 799, 451 ; // 481 ;
      OF o&I ID ID_TEXTO;
      STYLE WS_HSCROLL+WS_VSCROLL+ES_LEFT+ES_MULTILINE+ES_AUTOVSCROLL+ES_AUTOHSCROLL
      //
      oEdit&i:bOther := {|o,m,wp,lp|richeditProc(o,m,wp,lp)}
      //
      oEdit&i:lChanged := .F.
      //
      ADD STATUS TO o&I ID IDC_STATUS PARTS 50, 50, 400, 12, 90, 95, 90
      //
      hwg_SetFocus( GetDlgItem( oEdit&i, ID_TEXTO ) )
   auto++
 o&I:ACTIVATE()
 WriteStatus( o&I, 3,vText)
 WriteStatus( o&I, 1,'Lin:      0')
 WriteStatus( o&I, 2,'Col:      0')
 SendMessage( oEdit&i:Handle, WM_ENABLE, 1, 0 )
 hwg_SetFocus(oEdit&i:Handle )
 // colocando cores nas funcoes
 re_SetDefault( oEdit&i:handle,ID_COLORF,ID_FONT,,) // cor e fonte padrao
 /*
 for f = 1 to len(linhas)
    for g := 0 to linhas[f]
             hwg_MsgInfo(re_GetTextRange(oEdit&i,g, 1))
    next f

   //re_SetCharFormat(oEdit&i:handle, 6, olinha[f, 2], 255, , , .T.)
 next f
 */
 hwg_SetFocus( oEdit&i:Handle )
 SendMessage(oEdit&i:Handle, EM_SETBKGNDCOLOR, 0,ID_COLORB)  // cor de fundo
RETURN
*******************
FUNCTION funcao()
*******************

if maxi
  //SendMessage( oMainWindow:handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0 )
  oMainWindow:Maximize()
endif
 if  HMainWIndow():GetMdiActive() != nil
    dats:=dtoc(date())
    WriteStatus(HMainWIndow():GetMdiActive(), 6, "Data: " + dats)
    WriteStatus(HMainWIndow():GetMdiActive(), 7, "Hora: " + time())
    if ! set(_SET_INSERT )
       strinsert:='INSERT ON '
    else
        strinsert:='INSERT OFF '
    endif
    WriteStatus( HMainWIndow():GetMdiActive(), 5, strinsert )

 endif

***************************
FUNCTION painel(wmdi)
***************************
   @ 0, 0 PANEL oPanel of wmdi SIZE 150, 30

   //
   @ 2, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||novo()} ;
       SIZE 24, 24 FLAT               ;
       BITMAP "BMP_NEW" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP bnovo
   //
   @ 26, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||texto()} ;
       SIZE 24, 24 FLAT                ;
       BITMAP "BMP_OPEN" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP babrir
   //
   @ 50, 3 OWNERBUTTON OF oPanel       ;
       ON CLICK {||Salvar_Projeto(1)} ;
       SIZE 24, 24 FLAT                ;
       BITMAP "BMP_SAVE" FROM RESOURCE COORDINATES 0, 4, 0, 0 ;
       TOOLTIP bsalvar
retu nil
*******************************
FUNCTION fecha_texto()
*******************************
Local h := HMainWIndow():GetMdiActive():handle
    if alterado
        hwg_MsgYesNo('Deseja Salvar o arquivo')
    endif
    SendMessage(h, WM_CLOSE, 0, 0)
retu (.T.)
*******************************
FUNCTION richeditProc(oEdit, msg, wParam, lParam)
*******************************
Local nVirtCode,strinsert:=''
Local oParent, nPos

 if msg == WM_KEYDOWN
 endif
 IF msg == WM_KEYUP
     nVirtCode := wParam
     if  wParam == 45
          Set( _SET_INSERT, ! Set( _SET_INSERT ) )
     ENDIF
     if ! set(_SET_INSERT )
        strinsert:='INSERT ON '
     else
        strinsert:='INSERT OFF '
     endif
    // pega linha e coluna
     coluna := Loword(SendMessage(oEdit:Handle, EM_GETSEL, 0, 0))
     Linha := SendMessage(oEdit:Handle, EM_LINEFROMCHAR, coluna, 0)
     coluna :=coluna - SendMessage(oEdit:Handle, EM_LINEINDEX, -1, 0)
     //
     WriteStatus( HMainWIndow():GetMdiActive(), 5,strinsert )
     WriteStatus( HMainWIndow():GetMdiActive(), 1,'Lin:'+str(linha, 6))
     WriteStatus( HMainWIndow():GetMdiActive(), 2,'Col:'+str(coluna, 6))
      //
     if oEdit:lChanged
          WriteStatus( HMainWIndow():GetMdiActive(), 4,"*" )
          alterado:=.T.
     else
         WriteStatus( HMainWIndow():GetMdiActive(), 4," " )
     endif
     //
     if nvirtCode = 27
         if oEdit:lChanged
           hwg_MsgYesNo('Deseja Salvar o arquivo')
         endif
         h := HMainWIndow():GetMdiActive():handle
         SendMessage(h, WM_CLOSE, 0, 0)
     endif
     //
     if nvirtCode = 32 .or. nvirtCode = 13 .or. nvirtCode = 8
         hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
         oWindow:=HMainWIndow():GetMdiActive():aControls
         IF oWindow != Nil 

            aControls := oWindow
            
            SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 ) // focando janela
            hwg_SetFocus(aControls[hWnd]:Handle )
             //
             pos := SendMessage( oEdit:handle, EM_GETSEL, 0, 0 )
             pos1 := Loword(pos)
             //
             //hwg_MsgInfo(str(pos1))
             //hwg_MsgInfo(str(len(texto)))
             if sintaxe(texto)

                re_SetCharFormat( aControls[hWnd]:Handle,{{,,,,,,},{(pos1-len(texto)),len(texto), 255,,, .T.}})
             else
                re_SetCharFormat(aControls[hWnd]:Handle, pos1, pos1, 0, , , .T.)
             endif
            //
            SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 ) // focando janela
            hwg_SetFocus(aControls[hWnd]:Handle )
         endif
         texto:=''
     else
        texto:=texto+chr(nvirtCode)
     endif
ENDIF
Return -1
***********************
FUNCTION indioma(rd_ID)
***********************
for f := 8001 to 8002
  if IsCheckedMenuItem( ,f )
    CheckMenuItem( ,f, !IsCheckedMenuItem( ,f ) )
  endif
next f
CheckMenuItem( ,rd_ID, !IsCheckedMenuItem( ,rd_ID ) )
 ID_indioma:=rd_id
 save all like ID_* to config.dat
hwg_MsgInfo(reiniciar)
return (.T.)
***********************
FUNCTION aguarde()
***********************
hwg_MsgInfo(desenvolvimento)
retu .T.
****************************
FUNCTION Pesquisa()

local pesq,get01
local flags:=1
Local hWnd, oWindow, aControls, i
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     //
     INIT DIALOG pesq clipper TITLE  "Pesquisar" ;
          AT 113, 214 SIZE 345, 103 STYLE DS_CENTER
     @ 80, 17 SAY "Insira o Texto a Pesquisar" SIZE 173, 30
     @ 13, 39 get get01 SIZE 319, 24
     readexit(.T.)
     ACTIVATE DIALOG pesq
     if pesq:lResult
         IF oWindow != Nil
             aControls := oWindow
             SendMessage( aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
             hwg_SetFocus( aControls[hWnd]:Handle )
             //
             SendMessage(aControls[hWnd]:Handle, 176, 2, alltrim(get01))
             //
             SendMessage( aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
             hwg_SetFocus( aControls[hWnd]:Handle )
         endif
     endif
 endif
return .T.
***************************
FUNCTION painel2(wmdi, array)
***************************
local oCombo
   @ 0, 0 PANEL oPanel of wmdi SIZE 150, 30
   @ 650, 2 GET COMBOBOX oCombo ITEMS oFunc SIZE 140, 200 of oPanel ON CHANGE {|| buscafunc(oCombo)}
retu nil
***************************
FUNCTION Ajuda(rArq)
***************************
local vpasta:=curdir()
oIE := TOleAuto():GetActiveObject( "InternetExplorer.Application" )

IF Ole2TxtError() != "S_OK"
      oIE := TOleAuto():New( "InternetExplorer.Application" )
ENDIF

IF Ole2TxtError() != "S_OK"
    hwg_MsgInfo( "ERRO! IExplorer nao Localizado" )
    RETURN
ENDIF

oIE:Visible := .T.

oIE:Navigate(rArq )

RETURN

****************************
FUNCTION Vai(oEdit)
****************************
local pesq,get01
local flags:=1
Local hWnd, oWindow, aControls, i
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     INIT DIALOG pesq clipper TITLE  "Linha" ;
          AT 113, 214 SIZE 345, 103 STYLE DS_CENTER
     @ 80, 17 SAY "Digite a linha " SIZE 173, 30
     @ 13, 39 get get01 SIZE 319, 24
     readexit(.T.)
     ACTIVATE DIALOG pesq
     if pesq:lResult
         IF oWindow != Nil
             pos_y := val(get01)
             aControls := oWindow
             SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
             hwg_SetFocus(aControls[hWnd]:Handle )
             //
             SendMessage(aControls[hWnd]:Handle, EM_SCROLLCARET, 0, 0)
             Sendmessage(aControls[hWnd]:Handle, EM_LINESCROLL, 0, pos_y - 1)
             //
             SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
             hwg_SetFocus(aControls[hWnd]:Handle )
             //
         ENDIF
     endif
 endif

return .T.
**********************
FUNCTION seleciona()
**********************
Local hWnd, oWindow, aControls, i
 hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
 oWindow:=HMainWIndow():GetMdiActive():aControls
 IF oWindow != Nil
    aControls := oWindow
    SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
    hwg_SetFocus(aControls[hWnd]:Handle )
    SendMessage(aControls[hWnd]:handle, EM_SETSEL, 0, 0)
    SendMessage(aControls[hWnd]:handle, EM_SETSEL, 100000, 0)
 ENDIF
retu .T.
*******************************
FUNCTION Salvar_Projeto(oOpcao)
*******************************
Local fName, fTexto, fSalve
Local hWnd, oWindow, aControls, i
local cfile :="temp"
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     //
     
    nHandle =FCREATE( cFile, FC_NORMAL )
    IF( nHandle > 0 )
//      FWRITE( nHandle, EditorGetText(oEdit) )

        FCLOSE( nHandle )

     IF oWindow != Nil
        aControls := oWindow
        If Empty(vText) .or. oOpcao=2
            fName:=SaveFile("*.prg","Arquivos de Programa (*.prg)","*.prg",curdir())
        Else
            fName:=vText
        Endif

        fSalve:=fCreate(fName) //Cria o arquivo
        fWrite(fSalve,aControls[hWnd]:vari)
        fClose(fSalve) //fecha o arquivo e grava
     endif

   endif
 else
   hwg_MsgInfo('Nada para salvar')
 endif
Return Nil
*********************
FUNCTION buscafunc(linha)
*********************
Local hWnd, oWindow, aControls, i
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     IF oWindow != Nil
         pos_y := funcoes[linha]                                         
         aControls := oWindow
         SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0 )
         hwg_SetFocus(aControls[hWnd]:Handle )
         //
         SendMessage(aControls[hWnd]:Handle, EM_SCROLLCARET, 0, 0)
         Sendmessage(aControls[hWnd]:Handle, EM_LINESCROLL, 0, pos_y - 1)
         //
         SendMessage(aControls[hWnd]:Handle, WM_ENABLE, 1, 0)
         hwg_SetFocus(aControls[hWnd]:Handle)
         //
      ENDIF
  endif
return (.T.)
*************************
FUNCTION cor_fundo()
*************************
Local hWnd, oWindow, aControls, i
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     aControls := oWindow
     ID_COLORB:=Hwg_ChooseColor(ID_COLORB, .T.)
     SendMessage(aControls[hWnd]:Handle, EM_SETBKGNDCOLOR, 0,ID_COLORB)  // cor de fundo
     save all like ID_* to config.dat
 else
   hwg_MsgInfo('Abra um documento Primeiro')
 endif
 hwg_SetFocus(aControls[hWnd]:Handle )
retu .T.
*************************
FUNCTION cor_Fonte()
*************************
Local hWnd, oWindow, aControls, i
 if  HMainWIndow():GetMdiActive() != nil
     hWnd :=Ascan(HMainWIndow():GetMdiActive():aControls, {|o|o:winclass=="RichEdit20A"} )
     oWindow:=HMainWIndow():GetMdiActive():aControls
     aControls := oWindow
     ID_COLORF:=Hwg_ChooseColor(ID_COLORF, .T.)
     re_SetDefault( aControls[hWnd]:Handle,ID_COLORF,ID_FONT,,) // cor e fonte padrao
     save all like ID_* to config.dat
 else
   hwg_MsgInfo('Abra um documento Primeiro')
 endif
 hwg_SetFocus(aControls[hWnd]:Handle )
retu .T.

*************************
FUNCTION sintaxe(comando)
*************************
local comand:=upper(alltrim(comando))
local ret := .T.
  //hwg_MsgInfo(comand)
if comand =='FOR'
   ret:=.T.
elseif comand =='NEXT'
   ret:=.T.
elseif comand =='IF'
   ret:=.T.
elseif comand =='ENDIF'
   ret:=.T.
elseif comand =='WHILE'
   ret:=.T.
elseif comand =='ENDDO'
   ret:=.T.
elseif comand =='ELSEIF'
   ret:=.T.
else
  ret:=.F.
endif

retu ret

