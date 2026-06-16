#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#Include "HBUTTON.CH"
#Include "XMLXFUN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#include "FwBrowse.ch"
#include "FwMvcDef.ch"
#include "TOTVS.CH"
#include 'fileio.ch'

/////////// ROTINA DE IMPRESSAO DE ETIQUETAS - PROJETOS ESPECIAL

Static cDirArq  := GetNewPar("BUD_ETQESP",'\EtiqPrjEsp\') // Caminho de arquivos dos layout's dos arquivos
Static cArqConf := 'CONFIG.INI' // Arquivo de configuração de modelos/arquivos de etiquetas por cliente
Static cArqCont := 'MODOCONT.TXT'
Static cArqPall := 'PALLET.TXT'
Static ENTER 	:= CHR(13)+CHR(10)

//--------------------------------------------------------------
/*{Protheus.doc} MyFunction
Description

@param xParam Parameter Description
@return xRet Return Description
@author Marcos Alberto Schoeffel - marcos.alberto@totvs.com.br
@Jonas Koslowski
@since 18/11/2013
/*/
//--------------------------------------------------------------
User Function BUD1120()

	Local oCliente
	Local oItem
	Local oSCor
	Local oProduto
	Local nListBox1 := 0
	Local nListBox2 := 0
	Local oSBar
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7

	Local oFont1 := TFont():New("Courier New",,018,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("Calibri",,017,,.F.,,,,,.F.,.F.)

	Local oGroup1
	Local oGroup2
	Local oGroup3
	Local oGroup4
	Local oGroup5

	Local oSaldo

	Local oReimprime

	Private oFont3 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)
	Private oFont4 := TFont():New("MS Sans Serif",,018,,.T.,,,,,.F.,.F.)

	Private oSair
	Private oLimpar
	Private oPallet

	Private oBTGai
	Private oBTEnd

	Private oFim
	Private oFimCaixa
	Private oOrdem

	Private lReserva 	:= .T.
	Private lAbaixoM 	:= .F.
	Private lLiberac 	:= .F.
	Private lDistrPed   := .F.
	Private cColEmpDs     := 'C6_QTDEMP'

	Private cGPallet 	:= ''
	Private cZZ5_TPETQ	:= 'PP'

	// Variaveis utilizadas para controlar se deverao ou não controlar pallet para impressao de etiqueta
	Private lCampos := (ZZ5->(FieldPos("ZZ5_PALLET")) <> 0 .And. ZZ5->(FieldPos("ZZ5_IMPALL")) <> 0)
	Private lPallet := .F.
	Private cPallet := ''
	Private oSPallet
	Private cSayPall
	//
	Private aTipPed := RetSx3Box( Posicione("SX3", 2,"C5_TIPOPED","X3CBox()"),,,1)

	Private cMascQtd := PesqPict('SC6','C6_QTDVEN')

	Private oC5_Num
	Private cC5_Num 	:= Space(TamSx3('C5_NUM')[1])
	Private cC5_NumAnt  := Space(TamSx3('C5_NUM')[1])
	Private cC5_PedNum := ""
	Private cC6_ProCl := ""

	Private oC5_CLIENTE
	Private cC5_CLIENTE := Criavar("C5_CLIENTE",.F.)
	Private cC5_LOJACLI := Criavar("C5_LOJACLI",.F.)

	Private oA1_NOME
	Private cA1_NOME := Criavar("A1_NOME",.F.)
	Private cA1_MUN
	Private cA1_EST
	Private oC6_ITEM
	Private cC6_ITEM
	Private oGCor
	Private cGCor
	Private oC6_PRODUTO
	Private cC6_PRODUTO
	Private oB1_DESC
	Private cB1_DESC
	Private oTpCxa
	Private cTpCxa
	Private cDsCxa:=""
	Private cCodCxa
	Private oC6_LOCAL
	Private cC6_LOCAL
	Private dC5_DTENT
	Private nSaldoSB2
	Private cDescP :=""
	Private cDescA :=""
	Private cDescL :=""
	Private cCorL :=""
	Private cDesccor :=""
	Private cCODCor :=""
	Private cCodInt :=""

	Private oLBEmbal
	Private aEmbal := {'','','',''}
	Private oLBQuant
	Private aQuant := {'','','','',''}

	Private oCodBar
	Private cCodBar
	Private cCodBarAnt
	Private cCBAux

	Private oQtdPcs
	Private nQtdPcs := 0
	Private nQtdPcte:= 0
	Private oPcsCxa
	Private nPcsCxa := 0

	Private oTotCxa
	Private nTotCxa := 0

	Private nQtdEnc := 0
	Private nQtdRes := 0
	Private nQtdSal := 0
	Private lPrim	 := .T.
	Private lPrimVol := .T.
	Private lPrimV1  := .T.
	Private lGerou   := .F.
	Private lDun14   := .T.
	Private lTPJG    := .F.
	Private lGravPal := .T.

	Private oNumCxa
	Private cDescCxa
	Private cNumCxa
	Private cNumCxaLe
	Private cVOLR :='000000'
	Private cVOLPRI
	Private cVOLIni
	Private cVOLIniA
	Private cVOLFim
	Private cTotCxa
	Private cTotCxaR
	Private cSemaPed    := '' // riachuelo
	Private cCorProd    := '' // riachuelo
	Private cCDLoja    := '' // riachuelo
	Private cPedcLI    := '' // riachuelo
	Private cPedcLIM    := '' // MONTREAL
	Private cCodP:=''
	Private cMatric:= ''
	Private cDUN14:= 0
	Private cGet1:= ""
	Private nLETOTCX:= 0

	Private oOperador
	Private oZZ5_1ACOND
	Private oZZ5_1OPERA
	Private cZZ5_1ACOND	:= Space(TamSx3('ZZ5_ACONDI')[1] + 1)
	Private cZZ5_1OPERA	:= Space(TamSx3('ZZ5_OPERAD')[1] + 1)

	Private oOperador2
	Private oZZ5_2ACOND
	Private oZZ5_2OPERA
	Private cZZ5_2ACOND := Space(TamSx3('ZZ5_ACONDI')[1] + 1)
	Private cZZ5_2OPERA := Space(TamSx3('ZZ5_OPERAD')[1] + 1)
	Private lFinalizar	:= .F.
	Private lSairSem	:= .F.

	Private lCodAnt		:= .F.

	Private aVetor  := {}
	Private aStru   :={}
	Private aCpoBro := {}

	// Variáveis utilizadas no encaixotamento do CD Buddemeyer:
	Private lCDBudd 	:= .F.
	Private lRFObri 	:= .T.
	Private lSairCD		:= .F.
	Private lTimer		:= .F.
	Private oDlgCD
	Private oTmrCD
	Private oNumPedCD
	Private oCliPedCD
	Private oDatPedCD
	Private oObsPedCD
	Private oGaiolaCD
	Private oEndereCD
	Private oGaiola
	Private oSGaiola
	Private oBtnOKCD
	Private oBtnImpCD
	Private cPrBuff		:= ""
	Private cPallBuff	:= ""
	// aCols do saldo:
	Private oLstSaldo
	Private aAltSld		:= {}
	Private aCabeSld	:= {}
	Private aColsSld	:= {}
	// Variáveis a serem populadas pelo WS:
	Private cNumPedCD 	:= "..."
	Private cCliPedCD	:= "Aguarde, buscando pedido da lista..."
	Private cCDTitGai 	:= "Informe o código da gaiola:"
	Private cDatPedCD	:= ""
	Private cObsPedCD	:= ""
	Private cGaiolaCD	:= ""
	Private cTipoCDGr	:= ""
	Private cPrefCDGa	:= ""
	Private cGaiolaVa	:= ""
	Private cGaiola		:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	Private cSayGai		:= ""
	Private cEndereCD	:= ""
	Private cCDItemGa	:= ""
	Private nRecnoZDU	:= 0
	Private nRecnoZDY	:= 0
	Private cCDNumOP	:= ""
	Private cCDEstacao	:= "Estacao"
	Private cEnderEst	:= ""
	Private aEnderPes	:= {}
	Private oSItnGa
	Private cSItnGa		:= ""
	Private cIMG        := ""
	Private oDlgRFID
	Private oCDVin
	// Declaração dos objetos de status de cores:
	Private oVerde  	:= LoadBitmap(GetResources(), "BR_VERDE")
	Private oAzul  		:= LoadBitmap(GetResources(), "BR_AZUL")
	Private oVermelho	:= LoadBitmap(GetResources(), "BR_VERMELHO")
	Private oAmarelo	:= LoadBitmap(GetResources(), "BR_AMARELO")

	Static oDlg

	aCpoBro	:= {{"OK"        ,, ""          ,"@!"},;
		{ "PEDIDO"     ,, "PEDIDO"     ,"@!"},;
		{ "PRODUTO"    ,, "PRODUTO"    ,"@1!"},;
		{ "DESCPROD"   ,, "DESCRICAO"  ,"@1!"},;
		{ "QTD"        ,, "QTD ENCAIX"  ,"@X"},;
		{ "VOLUME"     ,, "VOLUME"     ,"@X"}}

	//////////////////CRIA TABELA TEMPORARIA

	AADD(aStru,{"OK"      ,"C", 02,0})
	AADD(aStru,{"PEDIDO"  ,"C", 06,0})
	AADD(aStru,{"ITEM"    ,"C", 02,0})
	AADD(aStru,{"PRODUTO" ,"C", 18,0})
	AADD(aStru,{"DESCPROD","C", 40,0})
	AADD(aStru,{"SEQENC"  ,"C", 02,0})
	AADD(aStru,{"PCSCXA"  ,"N", 08,0})
	AADD(aStru,{"TOTCXA"  ,"C", 08,0})
	AADD(aStru,{"QTD"     ,"N", 06,0})
	AADD(aStru,{"VOLUME"  ,"C", 08,0})

	IF (SELECT("TRB1120") <> 0)
		DBSELECTAREA("TRB1120")
		DBCLOSEAREA()
	ENDIF
	cArq:=Criatrab(aStru,.T.)
	DBUSEAREA(.t.,,carq,"TRB1120",.F.,.F.)
	IndRegua("TRB1120",Left(cArq,7)+'A',"PRODUTO",,,"Selecionando Registros...")

	////////////////////////////////////////

	/*
	cIdUsr := RetCodUsr()
	CB1->(DbSetOrder(2))
	CB1->(DbSeek(xFilial('CB1')+cIdUsr))
	If	CB1->(Found())
		If	Empty(CB1->CB1_MATRIC)
			Alert('Usuário não possui matrícula registrada no Cadastrado de Operadores (CB1), Contactar Administrador do Sistema !!!')
			Return
		Else
			cMatric := CB1->CB1_MATRIC
		EndIf
	ElseIf	cIdUsr != '000000'
		Alert('Usuário não Cadastrado como Operador/Encaixotador (CB1), Contactar Administrador do Sistema !!!')
		Return
	EndIf
	*/

	// Verifico se o encaixotamento é no CD ou normal:
	If AllTrim(U_B1391Param("CD", "ESTA_01")) == "*" .Or. (Upper(AllTrim(ComputerName())) $ AllTrim(U_B1391Param("CD", "ESTA_01")+","+U_B1391Param("CD", "ESTA_02"))) .Or. Empty(U_B1391Param("CD", "ESTA_01"))
		lCDBudd		:= .T.
		lRFObri		:= .F.
	EndIf

	B1120Limpar(.T.)

	//DEFINE MSDIALOG oDlg TITLE "Encaixotamento Projeto Especial" FROM 000, 000  TO 600, 800 COLORS 0, 16777215 PIXEL

	oDlg := TDialog():New(0,0,600,800,"Encaixotamento Projeto Especial",,,,,,,,,.T.,,,,,)
	oDlg:SetColor(0, 16777215)
	oDlg:lCentered := .T.
	oDlg:lEscClose := .F.
	oDlg:nStyle:=128

	@ 008, 008 GROUP oGroup1 TO 047, 200 PROMPT "Dados do Pedido / Cliente" OF oDlg COLOR 0, 16777215 PIXEL
	@ 019, 013 SAY oSay1 PROMPT "Num.Pedido" SIZE 033, 008 OF oDlg COLORS 0, 16777215 PIXEL
	@ 017, 045 MSGET oC5_Num VAR cC5_Num SIZE 046, 011 OF oDlg PICTURE "@S6" Valid B1120Ped() COLORS 0, 16777215 FONT oFont2 F3 "SC5" PIXEL
	@ 017, 093 BUTTON oSaldo PROMPT "Saldo Pedido" SIZE 041, 011 OF oDlg FONT oFont2 PIXEL Action B1120Saldo()
	If lCDBudd
		@ 019, 137 SAY oSay7 PROMPT "[CD]" SIZE 100, 008 OF oDlg COLORS 16711680, 16777215 PIXEL
	Else
		@ 019, 137 SAY oSay7 PROMPT "[S/A]" SIZE 100, 008 OF oDlg PIXEL
	EndIf

	@ 032, 013 SAY oCliente PROMPT "Cliente" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 031, 045 MSGET oC5_CLIENTE VAR cC5_CLIENTE SIZE 046, 011 OF oDlg PICTURE "@S6" COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oC5_CLIENTE:Disable()
	@ 031, 092 MSGET oA1_NOME VAR cA1_NOME SIZE 105, 011 OF oDlg PICTURE "@S55" COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oA1_NOME:Disable()

	// Informações do operador:
	@ 008, 205 GROUP oGroup5 TO 047, 393 PROMPT "Dados do Operador / Ajudante / " + Upper(AllTrim(ComputerName())) OF oDlg COLOR 0, 16777215 PIXEL
	// Operador 1:
	@ 019, 209 SAY oOperador PROMPT "Operador" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 017, 241 MSGET oZZ5_1ACOND VAR cZZ5_1ACOND SIZE 046, 011 OF oDlg PICTURE "@S6" Valid B1120Oper(cZZ5_1ACOND, 'cZZ5_1OPERA') COLORS 0, 16777215 FONT oFont2 F3 "CB1" PIXEL
	@ 017, 287 MSGET oZZ5_1OPERA VAR cZZ5_1OPERA SIZE 100, 011 OF oDlg PICTURE "@S55" COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oZZ5_1OPERA:Disable()
	// Operador 2:
	@ 032, 209 SAY oOperador2 PROMPT "Ajudante" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 031, 241 MSGET oZZ5_2ACOND VAR cZZ5_2ACOND SIZE 046, 011 OF oDlg PICTURE "@S6" Valid B1120Oper(cZZ5_2ACOND, 'cZZ5_2OPERA') COLORS 0, 16777215 FONT oFont2 F3 "CB1" PIXEL
	@ 031, 287 MSGET oZZ5_2OPERA VAR cZZ5_2OPERA SIZE 100, 011 OF oDlg PICTURE "@S55" COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oZZ5_2OPERA:Disable()

	@ 052, 008 GROUP oGroup2 TO 105, 393 PROMPT "Dados Item Pedido" OF oDlg COLOR 0, 16777215 PIXEL

	@ 063, 013 SAY oItem PROMPT "Item" SIZE 017, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 048 MSGET oC6_ITEM VAR cC6_ITEM SIZE 014, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oC6_ITEM:Disable()

	@ 062, 089 SAY oSCor PROMPT "Cor Produto" SIZE 034, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 059, 128 MSGET oGCor VAR cGCor SIZE 054, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oGCor:Disable()

	@ 075, 013 SAY oProduto PROMPT "Produto" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 074, 048 MSGET oC6_PRODUTO VAR cC6_PRODUTO SIZE 080, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oC6_Produto:Disable()

	@ 074, 129 MSGET oB1_DESC VAR cB1_DESC SIZE 147, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oB1_DESC:Disable()

	@ 091, 013 SAY oSay5 PROMPT "Tipo de Caixa" SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, 048 MSGET oTpCxa VAR cTpCxa SIZE 117, 011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oTpCxa:Disable()

	@ 091, 170 SAY oSay6 PROMPT "Local " SIZE 042, 007 OF oDlg COLORs 0, 16777215 PIXEL
	@ 090, 218 MSGET oC6_LOCAL VAR cC6_LOCAL SIZE 020,011 OF oDlg COLORS 0, 16777215 FONT oFont2 When .F. READONLY PIXEL
	oC6_LOCAL:Disable()

	@ 107, 008 GROUP oGroup3 TO 172, 170 PROMPT "Quantidades" OF oDlg COLOR 0, 16777215 PIXEL
	@ 116, 012 LISTBOX oLBQuant VAR nListBox1 ITEMS aQuant SIZE 150, 050 OF oDlg COLORS 16711680, 16777215 FONT oFont1 When .F. PIXEL

	@ 107, 175 GROUP oGroup4 TO 172, 335 PROMPT "Dados Embalagem" OF oDlg COLOR 0, 16777215 PIXEL
	@ 116, 179 LISTBOX oLBEmbal VAR nListBox2 ITEMS aEmbal SIZE 150, 050 OF oDlg COLORS 16711680, 16777215 FONT oFont1 When .F. PIXEL

	@ 185, 008 SAY oSBar PROMPT "Código Barras Produto" SIZE 083, 010 OF oDlg FONT oFont3 COLORS 255, 16777215 PIXEL
	@ 184, 101 MSGET oCodBar VAR cCodBar SIZE 082, 012 OF oDlg PICTURE "@S30" Valid B1120CodBar() COLORS 255, 16777215 FONT oFont3 PIXEL
	oCodBar:Disable()

	@ 205, 008 SAY oSay3 PROMPT "Quantidade Leitura    " SIZE 089, 010 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 204, 101 MSGET oQtdPcs VAR nQtdPcs SIZE 049, 012 OF oDlg PICTURE "@E 9,999" COLORS 0, 16777215 FONT oFont3 When .F. READONLY PIXEL
	oQtdPcs:Disable()
	@ 204, 150 BUTTON oFimCaixa PROMPT "Etq. Parc." SIZE 032, 014 OF oDlg FONT oFont2 PIXEL Action GravaImpr(.T.)
	oFimCaixa:Disable()

	@ 255, 290 SAY oSPallet PROMPT cSayPall SIZE 083, 010 OF oDlg FONT oFont3 COLORS 255, 16777215 PIXEL

	// Incluir o número da gaiola, permitir trocar de gaiola:
	If lCDBudd

	EndIf
	// Código da gaiola:
	@ 265, 290 SAY oSGaiola PROMPT cSayGai SIZE 120, 010 OF oDlg FONT oFont3 COLORS 255, 16777215 PIXEL
	// Descrição do item a ser coletado na gaiola:
	@ 188, 190 SAY oSItnGa PROMPT cSItnGa SIZE 200, 050 OF oDlg FONT oFont4 COLORS CLR_MAGENTA PIXEL

	@ 225, 008 SAY oSay4 PROMPT "Quantidade Peças Caixa" SIZE 086, 010 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 224, 101 MSGET oPcsCxa VAR nPcsCxa SIZE 049, 012 OF oDlg PICTURE "@E 9,999" COLORS 0, 16777215 FONT oFont3 When .F. READONLY PIXEL
	oPcsCxa:Disable()

	@ 250, 008 SAY oNumCxa PROMPT cDescCxa SIZE 108, 010 OF oDlg FONT oFont3 COLORS 255, 16777215 PIXEL

	// Incluir a opção para visualizar ou alterar o endereço de saída do pallet:
	If lCDBudd
		@ 255, 009 SAY oSay2 PROMPT "Endereço de Saída" SIZE 083, 010 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
		@ 255, 101 BUTTON oBTEnd PROMPT cEnderEst SIZE 082, 012 OF oDlg FONT oFont2 PIXEL Action MsAguarde({|| VerEndEst("NOVO") }, "Endereco", "Aguarde, verificando endereço disponível...")
	EndIf

	@ 279, 009 SAY oSay2 PROMPT "Total Caixas do Item" SIZE 076, 008 OF oDlg FONT oFont3 COLORS 0, 16777215 PIXEL
	@ 278, 101 MSGET oTotCxa VAR nTotCxa SIZE 034, 012 OF oDlg PICTURE "@E 9,999.9" COLORS 0, 16777215 FONT oFont3 When .F. READONLY PIXEL
	oTotCxa:Disable()

	//@ 278, 196 BUTTON oReimpall  PROMPT "Reimp.Pallet" SIZE 040, 012 OF oDlg FONT oFont2 PIXEL Action U_BUD1214(	cC5_Num,Space(06),'ZZZZZZ',.T.)
	If lCDBudd
		@ 278, 143 BUTTON oBTGai PROMPT "Pedidos" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action TrocaGai(.T.)
	EndIf
	@ 278, 176 BUTTON oFim		 PROMPT "Finalizar" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action U_B1120Fim(cC5_Num)
	@ 278, 209 BUTTON oOrdem	 PROMPT "Ordem" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action B1120Ord()
	@ 278, 242 BUTTON oReimprime PROMPT "Reimpr." SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action Reimpre()
	@ 278, 275 BUTTON oLimpar    PROMPT "Limpar" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action B1120Limpar()
	@ 278, 308 BUTTON oPallet    PROMPT "Pallet" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action (B1120Pallet())
	@ 278, 341 BUTTON oSair      PROMPT "Sair" SIZE 032, 012 OF oDlg FONT oFont2 PIXEL Action Fechar() //(oDlg:End())

	oSplitter := tSplitter():New( 245,008,oDlg,385,002,0)
	oPanel1:= tPanel():New(245,002,,oSplitter,,,,CLR_YELLOW,CLR_BLUE,385,002)

	// Caso seja encaixotamento do CD, ativo rotina que busca o pedido:
	If lCDBudd
		// Antes de iniciar eu limpo etiquetas não existentes:
		MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando etiquetas não finalizadas...")
		// Eu também preciso validar se a estação está vinculada a algum endereço:
		MsAguarde({|| VerEstac(.F.) }, "Estação", "Verificando vinculo de endereço...")
		// Também verifico o que precisa ser processado previamente:
		MsAguarde({|| BuscaWS("&a=transfere", "") }, "Transferindo", "Transferindo itens CD...")
		// Chamo tela do CD:
		TelaCD(.F.)
	EndIf

	// Verifico se é CD e não foi informado gaiola:
	If lCDBudd .And. Empty(cGaiola)
		lSairCD	:= .T.
	EndIf

	// Se não for ativado a opção de sair, ativo o formulário:
	If !lSairCD
		oDlg:Activate(,,,.T.,,,)
	EndIf

	// Verifico se foi fechado painel e não foi finalizado:
	/*
	If lFinalizar .And. !Empty(cC5_Num) .And. !lSairCD
		lSairSem	:= .T.
		While !U_B1120Fim(cC5_Num)
			// Enquanto o usuário for tentando cancelar, eu volto a perguntar
		EndDo
	EndIf
	*/

Return

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Rotinas responsáveis pelo encaixotamento no CD Buddemeyer - Busca pedidos através das gaiolas endereçadas:
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
// Montagem da tela:
Static Function TelaCD(lContinua)

	Local oGrCli
	Local oGrPro
	Local oBtnCD
	Local oItnSLDCD

	/*
	Local oFPedido	:= TFont():New("Tahoma",,020,,.T.,,,,,.F.,.F.)
	Local oFItnGa	:= TFont():New("Tahoma",,020,,.T.,,,,,.F.,.F.)
	Local oFCliente	:= TFont():New("Tahoma",,025,,.F.,,,,,.F.,.F.)
	Local oFObserva	:= TFont():New("Tahoma",,020,,.F.,,,,,.F.,.F.)
	*/

	Local oFPedido	:= TFont():New("Tahoma",,040,,.T.,,,,,.F.,.F.)
	Local oFItnGa	:= TFont():New("Tahoma",,030,,.T.,,,,,.F.,.F.)
	Local oFCliente	:= TFont():New("Tahoma",,035,,.F.,,,,,.F.,.F.)
	Local oFObserva	:= TFont():New("Tahoma",,020,,.F.,,,,,.F.,.F.)

	/*
	Local oFPedido	:= TFont():New("Tahoma",,050,,.T.,,,,,.F.,.F.)
	Local oFItnGa	:= TFont():New("Tahoma",,040,,.T.,,,,,.F.,.F.)
	Local oFCliente	:= TFont():New("Tahoma",,035,,.F.,,,,,.F.,.F.)
	Local oFObserva	:= TFont():New("Tahoma",,020,,.F.,,,,,.F.,.F.)
	*/

	// Verifico se é um pedido de encaixotamento no CD:
	if !lCDBudd
		Return
	EndIf

	// Formulário padrão:
	oDlgCD 	:= TDialog():New(0,0,600,800,"Pedido para encaixotar no CD Buddemeyer",,,,,,,,,.T.,,,,,)
	oDlgCD:SetColor(0, 16777215)
	oDlgCD:lCentered := .T.
	oDlgCD:lEscClose := .F.
	oDlgCD:nStyle:=128

	// Grupo de dados do pedido e do cliente:
	@ 005, 005 GROUP oGrCli TO 120, 395 PROMPT "Pedido definido para encaixotar" OF oDlgCD COLOR 0, 16777215 PIXEL
	@ 015, 010 SAY oNumPedCD PROMPT cNumPedCD SIZE 385, 050 OF oGrCli FONT oFPedido COLORS CLR_MAGENTA PIXEL
	@ 040, 010 SAY oCliPedCD PROMPT cCliPedCD SIZE 385, 050 OF oGrCli FONT oFCliente COLORS CLR_BLACK PIXEL
	@ 060, 010 SAY oDatPedCD PROMPT cDatPedCD SIZE 385, 050 OF oGrCli FONT oFCliente COLORS CLR_BLACK PIXEL
	@ 080, 010 SAY oObsPedCD PROMPT cObsPedCD SIZE 385, 200 OF oGrCli FONT oFObserva COLORS CLR_GRAY PIXEL

	// Grupo da definição do endereçamento da gaiola:
	@ 125, 005 GROUP oGrPro TO 260, 395 PROMPT "Gaiola / Caixa / Endereço" OF oDlgCD COLOR 0, 16777215 PIXEL
	@ 140, 010 SAY oGaiolaCD PROMPT cGaiolaCD SIZE 180, 050 OF oGrPro FONT oFItnGa COLORS CLR_BLUE PIXEL
	@ 160, 010 SAY oEndereCD PROMPT cEndereCD SIZE 180, 050 OF oGrPro FONT oFItnGa COLORS CLR_CYAN PIXEL

	// Separador:
	oSpl := tSplitter():New(190,008,oDlgCD,175,001,0)
	oPan := tPanel():New(190,002,,oSpl,,,,CLR_YELLOW,CLR_BLUE,175,001)
	// Entrada do código da gaiola obrigatório:
	@ 200, 010 SAY oCDTitGai PROMPT cCDTitGai SIZE 180, 050 OF oGrPro PIXEL
	@ 210, 010 MSGET oGaiola VAR cGaiola SIZE 150, 035 OF oGrPro FONT oFPedido COLORS CLR_BLACK VALID (VerGaiola(lContinua)) PIXEL

	// Lista dos itens necessários:
	@ 135, 190 SAY oItnSLDCD PROMPT "Itens necessários:" SIZE 180, 050 OF oGrPro PIXEL
	// Definindo variáveis dos itens para serem coletados e encaixotados:
	aCabeSld := {}
	aColsSld := {}
	Aadd(aCabeSld, {"Qtd."			,"QTD"	,"@!"	,4						,0,"","","N","","R","",""})
	Aadd(aCabeSld, {"Mult."			,"MULT"	,""		,3						,0,"","","C","","R","",""})
	Aadd(aCabeSld, {"Produto"		,"PROD"	,"@!"	,TamSx3('B1_DESC')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeSld, {"Cód. Barras"	,"BARRA","@!"	,TamSx3('B1_CODBAR')[1]	,0,"","","C","","R","",""})
	oLstSaldo := MsNewGetDados():New(142, 190, 240, 394, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aAltSld, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oGrPro, aCabeSld, aColsSld)
	oLstSaldo:Enable()
	// Botões de ações para os itens necessários:
	@ 242, 190 BUTTON oBtnOKCD PROMPT "OK" SIZE 030, 013 OF oGrPro PIXEL Action OKSldCD(lContinua)
	@ 242, 222 BUTTON oBtnImpCD PROMPT "Imprimir" SIZE 030, 013 OF oGrPro PIXEL Action MsAguarde({|| ImpColCD() }, "Imprimir", "Imprimindo coleta...")
	@ 242, 254 BUTTON oBtnMultCD PROMPT "Alterar" SIZE 030, 013 OF oGrPro PIXEL Action AlteraMult()

	oBtnOKCD:Disable()
	oBtnImpCD:Disable()

	// Botões de ação da gaiola:
	@ 270, 010 BUTTON oBtnCD PROMPT "Buscar" SIZE 050, 020 OF oDlgCD PIXEL Action AtualizCD()

	@ 270, 065 BUTTON oBtnCD PROMPT "Gerar Mult. Pct." SIZE 050, 020 OF oDlgCD PIXEL Action GerMultPCT(.T.)
	@ 270, 120 BUTTON oBtnCD PROMPT "Transferir Saldo" SIZE 050, 020 OF oDlgCD PIXEL Action TraSaldoCD()
	@ 270, 175 BUTTON oBtnCD PROMPT cCDEstacao SIZE 050, 020 OF oDlgCD PIXEL Action VerEstac(.T.)
	@ 270, 230 BUTTON oBtnCD PROMPT "Consultar Gaiola" SIZE 050, 020 OF oDlgCD PIXEL Action ConsGai()
	@ 270, 285 BUTTON oBtnCD PROMPT "Liberar" SIZE 050, 020 OF oDlgCD PIXEL Action LiberarCD()
	@ 270, 340 BUTTON oBtnCD PROMPT "Sair" SIZE 050, 020 OF oDlgCD PIXEL Action SairCD()

	// Ativo timer para ficar atualizando qual pedido deverá ser carregado:
	//oTmrCD := TTimer():New(Randomize(53000, 87000), {|| VerPedCD(lContinua, "") }, oDlgCD)
	//If !lContinua
	//	oTmrCD:Activate()
	//EndIf
	MsAguarde({|| VerPedCD(lContinua, "") }, "Pedido", "Verificando pedido...")

	// Ativo formulário:
	oDlgCD:Activate(,,,.T.,,,)

Return

// Efetua alteração do múltiplo conforme existente no físico:
Static Function AlteraMult()

	Local _x		:= 0
	Local nQtd		:= 0
	Local nMult		:= 0
	Local cCodBar	:= ""
	Local cCodOrig	:= "MNT_E_"+DtoS(MsDate())+"-"+StrTran(Time(), ":", "")

	// Validações:
	If Empty(cGaiolaVa)
		MsgStop("Código da gaiola/saldo não informado!")
		Return (.F.)
	EndIf
	If Empty(oLstSaldo:nAt)
		MsgStop("Gentileza selecione o item que deseja efetuar alteração!")
		Return (.F.)
	EndIf
	If Left(cGaiolaVa, 4) <> "SLD-"
		MsgStop("Somente habilitado alteração para caixas de saldos!")
		Return (.F.)
	EndIf

	// Busco ionformação do item selecionado:
	nQtd	:= aColsSld[oLstSaldo:nAt][1]
	nMult	:= Val(StrTran(aColsSld[oLstSaldo:nAt][2], "x", ""))
	cCodBar	:= AllTrim(aColsSld[oLstSaldo:nAt][4])

	//  Solicita quantidades:
	If !Pergunte("BUD1120", .T.)
		Return (.F.)
	EndIf
	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		MsgStop("Gentileza informe os parâmetros corretamente!")
		Return (.F.)
	EndIf

	// Verifico se o usuário logado é administrador do CD:
	If (Select("TT1120B") <> 0)
		dbSelectArea("TT1120B")
		dbCloseArea()
	EndIf
	cQuery := "SELECT TOP 1 CB1_CODUSR "
	cQuery += "FROM CB1010 (NOLOCK) "
	cQuery += "WHERE CB1_FILIAL = '01' "
	cQuery += "AND CB1_CODUSR = '"+RetCodUsr()+"' "
	cQuery += "AND CB1_CODUSR <> '' "
	cQuery += "AND CB1_ADMINT = '1' "
	cQuery += "AND CB1010.D_E_L_E_T_ = ''"
	TCQuery cQuery NEW ALIAS "TT1120B"
	If TT1120B->(Eof())
		MsgStop("Usuário não autorizado!")
		Return (.F.)
	EndIf

	// Verifico o registro selecionado:
	If (Select("TT1120B") <> 0)
		dbSelectArea("TT1120B")
		dbCloseArea()
	EndIf
	cQuery := "SELECT TOP 1 A1_NOME, ZDY_CODCXA, ZDY_PEDORI, ZDY_ORIG, ZDY_PEDORI, ZDY_ITEORI, ZDY_PRODUT, ZDY_ENDERE, ZDY_CLI, ZDY_LOJA, ZDY_LOCAL, ZDY_CLIGRU "
	cQuery += "FROM ZDY010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDY_PRODUT AND SB1010.D_E_L_E_T_ = ''"
	cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = ZDY_CLI AND A1_LOJA = ZDY_LOJA AND SA1010.D_E_L_E_T_ = ''"
	cQuery += "WHERE ZDY_FILIAL = '' "
	cQuery += "AND ZDY_CODCXA = '"+cGaiolaVa+"' "
	cQuery += "AND ZDY_LOCFIS = 'CD' "
	cQuery += "AND ZDY_MULTIP = '"+AllTrim(Str(nMult))+"' "
	cQuery += "AND B1_CODBAR = '"+cCodBar+"' "
	cQuery += "AND ZDY010.D_E_L_E_T_ = ''"
	TCQuery cQuery NEW ALIAS "TT1120B"
	If !TT1120B->(Eof())
		If MsgBox("Deseja realmente alterar para ["+AllTrim(Str(MV_PAR01 * MV_PAR02))+" peca(s)] na caixa de saldo ["+cGaiolaVa+"] para o cliente ["+AllTrim(TT1120B->A1_NOME)+"]?", "Alterar pacotes ["+AllTrim(TT1120B->ZDY_PEDORI)+"]?", "YESNO")
			// Efetuo inclusão do saldo:
			For _x := 1 To MV_PAR02
				RecLock("ZDY", .T.)
				ZDY->ZDY_CODCXA	:= TT1120B->ZDY_CODCXA
				ZDY->ZDY_ORIG	:= cCodOrig
				ZDY->ZDY_PEDORI	:= TT1120B->ZDY_PEDORI
				ZDY->ZDY_ITEORI	:= TT1120B->ZDY_ITEORI
				ZDY->ZDY_PRODUT	:= TT1120B->ZDY_PRODUT
				ZDY->ZDY_MULTIP	:= MV_PAR01
				ZDY->ZDY_DTGER	:= MsDate()
				ZDY->ZDY_HRGER	:= Time()
				ZDY->ZDY_USGER	:= Upper(AllTrim(cUserName))
				ZDY->ZDY_ENDERE	:= TT1120B->ZDY_ENDERE
				ZDY->ZDY_LOCFIS	:= 'CD'
				ZDY->ZDY_CLI	:= TT1120B->ZDY_CLI
				ZDY->ZDY_LOJA	:= TT1120B->ZDY_LOJA
				ZDY->ZDY_LOCAL	:= TT1120B->ZDY_LOCAL
				ZDY->ZDY_CLIGRU	:= TT1120B->ZDY_CLIGRU
				MsUnLock("ZDY")
			Next _x

			// Efetuo exclusão dos itens do saldo:
			cUpd := "UPDATE ZDY010 SET D_E_L_E_T_ = '*' "
			cUpd += ", R_E_C_D_E_L_ = R_E_C_N_O_ "
			cUpd += ", ZDY_LOCFIS = 'AL' "
			cUpd += ", ZDY_DCVINS = '"+cCodOrig+"' "
			cUpd += ", ZDY_DCVINE = '"+cCodOrig+"' "
			cUpd += "WHERE ZDY_FILIAL = '' "
			cUpd += "AND ZDY_CODCXA = '"+TT1120B->ZDY_CODCXA+"' "
			cUpd += "AND ZDY_PEDORI = '"+TT1120B->ZDY_PEDORI+"' "
			cUpd += "AND ZDY_ITEORI = '"+TT1120B->ZDY_ITEORI+"' "
			cUpd += "AND ZDY_PRODUT = '"+TT1120B->ZDY_PRODUT+"' "
			cUpd += "AND ZDY_ENDERE = '"+TT1120B->ZDY_ENDERE+"' "
			cUpd += "AND ZDY_CLI = '"+TT1120B->ZDY_CLI+"' "
			cUpd += "AND ZDY_LOJA = '"+TT1120B->ZDY_LOJA+"' "
			cUpd += "AND ZDY_LOCAL = '"+TT1120B->ZDY_LOCAL+"' "
			cUpd += "AND ZDY_LOCFIS = 'CD' "
			cUpd += "AND ZDY_MULTIP = '"+AllTrim(Str(MV_PAR01))+"' "
			cUpd += "AND ZDY010.D_E_L_E_T_ = ''"
			TcSQLExec(cUpd)
		Else
			Return (.F.)
		EndIf
	Else
		MsgStop("Não foi localizado o registro na caixa de saldo corretamente, gentileza verificar!")
		Return (.F.)
	EndIf

	// Finalização do processo:
	MsgBox('Processo concluído com sucesso!', 'Êxito!', 'INFO')
	ItensNec()

Return (.T.)

// Função para realizar a montagem do múltiplo de pacote:
Static Function GerMultPCT(lTelaInc)

	Local oGrPCT
	Local oGrLsPCT
	Local oFGra			:= TFont():New("Calibri",,017,,.T.,,,,,.F.,.F.)

	// Campos que serão manipulados:
	Private oDlgCDPCT
	Private	oPrPCT
	Private	cPrPCT		:= Space(TamSx3('B1_CODBAR')[1] + 1)
	Private oPCTCod
	Private cPCTCod		:= Space(TamSx3('B1_CODBAR')[1])
	Private nQtdMult	:= 0
	Private nQtdBeep	:= 0
	Private cCodBarVld	:= Space(TamSx3('B1_CODBAR')[1])

	Private	oCliPCT
	Private	cCliPCT		:= Space(TamSx3('ZDY_CLI')[1] + 1)
	Private oPedPCT
	Private cPedPCT		:= Space(TamSx3('ZDY_PEDORI')[1])

	Private oLocPCT
	Private cLocPCT		:= Space(TamSx3('ZDY_LOCAL')[1])

	Private oPCTOrig
	Private cPCTOrig	:= Space(TamSx3('ZDY_CODCXA')[1])

	Private oPCTDest
	Private cPCTDest	:= Space(TamSx3('ZDY_CODCXA')[1])

	Private cPCTSt		:= "..."
	Private cPCTTot		:= ""
	Private oPCTSt
	Private lAltSld 	:= .F.

	// GetDados caixa de saldo:
	Private oLstPacote
	Private aAltPCT		:= {}
	Private aCabePCT	:= {}
	Private aColsPCT	:= {}

	// Verifico se é um pedido de encaixotamento no CD:
	if !lCDBudd
		Return
	EndIf

	// Formulário padrão:
	oDlgCDPCT := TDialog():New(0,0,600,800,"Packing de Avulsos",,,,,,,,,.T.,,,,,)
	oDlgCDPCT:SetColor(0, 16777215)
	oDlgCDPCT:lCentered := .T.
	oDlgCDPCT:lEscClose := .F.
	oDlgCDPCT:nStyle:=128

	// Grupo de dados do packing:
	@ 005, 005 GROUP oGrPCT TO 050, 395 PROMPT "Pesquisar Avulsos" OF oDlgCDPCT COLOR 0, 16777215 PIXEL

	@ 018, 015 SAY oSAProd PROMPT "Código de barras:" SIZE 060, 010 OF oGrPCT COLORS CLR_BLACK PIXEL
	@ 025, 015 MSGET oPrPCT VAR cPrPCT SIZE 060, 015 OF oGrPCT F3 "SB1" VALID PCTBuscaPr() COLORS CLR_BLACK PIXEL

	@ 018, 080 SAY oSAProd PROMPT "Cliente:" SIZE 060, 010 OF oGrPCT COLORS CLR_BLACK PIXEL
	@ 025, 080 MSGET oCliPCT VAR cCliPCT SIZE 060, 015 OF oGrPCT F3 "SA1CLI" COLORS CLR_BLACK PIXEL

	@ 018, 145 SAY oSAProd PROMPT "Pedido:" SIZE 060, 010 OF oGrPCT COLORS CLR_BLACK PIXEL
	@ 025, 145 MSGET oPedPCT VAR cPedPCT SIZE 060, 015 OF oGrPCT F3 "SC5" COLORS CLR_BLACK PIXEL

	@ 018, 210 SAY oSAProd PROMPT "Local:" SIZE 060, 010 OF oGrPCT COLORS CLR_BLACK PIXEL
	@ 025, 210 MSGET oLocPCT VAR cLocPCT SIZE 060, 015 OF oGrPCT COLORS CLR_BLACK PIXEL

	@ 018, 275 SAY oSAProd PROMPT "Caixa de origem:" SIZE 060, 010 OF oGrPCT COLORS CLR_BLACK PIXEL
	@ 025, 275 MSGET oPCTOrig VAR cPCTOrig SIZE 060, 015 OF oGrPCT COLORS CLR_BLACK PIXEL

	@ 025, 360 BUTTON oBtnSa PROMPT "OK" SIZE 030, 015 OF oDlgCDPCT PIXEL Action PCTBuscaPr()

	// Grupo de dados para demonstrar itens dentro da caixa de saldo:
	@ 055, 005 GROUP oGrLsPCT TO 215, 395 PROMPT "Avulsos nas caixas de saldo" OF oDlgCDPCT COLOR 0, 16777215 PIXEL

	// Definindo cabeçalho:
	Aadd(aCabePCT, {""				,"IMG"	,"@BMP"	,3						,0,"","","C","","R","",""})
	Aadd(aCabePCT, {"Caixa"			,"CAIXA","@!"	,10						,0,"","","C","","R","",""})
	Aadd(aCabePCT, {"Cód. Barras"	,"BARRA","@!"	,15						,0,"","","C","","R","",""})
	Aadd(aCabePCT, {"Produto"		,"PROD"	,"@!"	,TamSx3('B1_DESC')[1]	,0,"","","C","","R","",""})
	Aadd(aCabePCT, {"Múltiplo"		,"MULT"	,"@!"	,TamSx3('ZDY_MULTIP')[1],TamSx3('ZDU_MULTIP')[2],"","","N","","R","",""})
	Aadd(aCabePCT, {"Registro"		,"RECNO","@!"	,8						,0,"","","N","","R","",""})

	// Itens da gaiola:
	oLstPacote := MsNewGetDados():New(065, 010, 200, 390, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aAltPCT, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oGrLsPCT, aCabePCT, aColsPCT)
	@ 202, 315 SAY oPCTTot PROMPT cPCTTot SIZE 200, 010 OF oGrLsPCT COLORS CLR_HRED FONT oFGra PIXEL

	// Grupo de dados para efetuar inclusão do código do produto::
	@ 220, 005 GROUP oGrPro TO 260, 395 PROMPT "Destino" OF oDlgCDPCT COLOR 0, 16777215 PIXEL

	@ 237, 015 SAY oSaSld PROMPT "Caixa de destino:" SIZE 200, 010 OF oGrLsPCT COLORS CLR_BLUE FONT oFGra PIXEL
	@ 230, 075 MSGET oPCTDest VAR cPCTDest SIZE 100, 020 OF oGrPCT VALID BpAvulso('CAIXA') PIXEL

	@ 237, 190 SAY oSaSld PROMPT "Código do avulso:" SIZE 200, 010 OF oGrLsPCT COLORS CLR_BLUE FONT oFGra PIXEL
	@ 230, 250 MSGET oPCTCod VAR cPCTCod SIZE 100, 020 OF oGrPCT F3 "SB1BAR" VALID BpAvulso('PRODUTO') PIXEL
	@ 233, 355 BUTTON oBtnSa PROMPT "OK" SIZE 030, 015 OF oGrPCT PIXEL Action ProcAvulso()

	// Botões de ação:
	@ 270, 340 BUTTON oBtnSa PROMPT "Limpar" SIZE 050, 020 OF oDlgCDPCT PIXEL Action AvuLimpar()
	@ 275, 010 SAY oPCTSt PROMPT cPCTSt SIZE 250, 050 OF oGrLsPCT COLORS CLR_GRAY FONT oFGra PIXEL

	// Efetuo atualização de saldo:
	//MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando etiquetas não finalizadas...")

	// Efetuo validação:
	AvuLimpar()

	// Ativo formulário:
	oDlgCDPCT:Activate(,,,.T.,,,)

Return (.T.)

// Funçõa para limpar a tela de avulsos e iniciar novamente:
Static Function AvuLimpar()
	Local oTmrFocus

	// Limpo variáveis:
	cPrPCT		:= Space(TamSx3('B1_CODBAR')[1] + 1)
	cPCTDest	:= Space(TamSx3('ZDY_CODCXA')[1])
	cPCTSt		:= "..."
	nQtdMult	:= 0
	nQtdBeep	:= 0

	// Atualizo grid:
	PCTBuscaPr()

	// Retorno focus:
	oPrPCT:SetFocus()
	oTmrFocus := TTimer():New(500, {|| oPrPCT:SetFocus(), oTmrFocus:DeActivate() }, oDlgCDPCT)
	oTmrFocus:Activate()

Return (.T.)

// Função para buscar os itens na caixa:
Static Function PCTBuscaPr()

	Local nQtdSld	:= 0
	Local lExiste	:= .F.

	// Zero acols inicialmente:
	aColsPCT := {}

	// Verifico itens dentro da gaiola para ser efetuado transferência do saldo:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT ZDY_DTGER, ZDY_HRGER, ZDY_CODCXA, B1_CODBAR, B1_DESC, ZDY_MULTIP, "
	cQuery += "ISNULL((SELECT TOP 1 ZCN_QTDPCT "
	cQuery += "FROM ZCN010 (NOLOCK) "
	cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_CODENCX = ZCN_CODIGO AND SA1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZCN_FILIAL = '' "
	cQuery += "AND ZCN_REF = LEFT(ZDY_PRODUT, 8) "
	cQuery += "AND ZCN_TAM = RIGHT(RTRIM(ZDY_PRODUT), 4) "
	cQuery += "AND A1_COD = ZDY_CLI "
	cQuery += "AND A1_LOJA = ZDY_LOJA "
	cQuery += "AND ZCN_QTDPCT > 0 "
	cQuery += "AND ZCN010.D_E_L_E_T_ = ''), Z7_QTDPCT) AS Z7_QTDPCT, "
	cQuery += "ZDY010.R_E_C_N_O_ AS RECNOZDY "
	cQuery += "FROM ZDY010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDY_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SZ7010 (NOLOCK) ON Z7_FILIAL = '' AND Z7_COD = B1_CODMOD AND SZ7010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDY_FILIAL = '' "
	cQuery += "AND B1_CODBAR = '"+cPrPCT+"' "
	cQuery += "AND ZDY_LOCFIS = 'CD' "
	cQuery += "AND ZDY_CAIXA = '' "
	cQuery += "AND ZDY_MULTIP < ISNULL((SELECT TOP 1 ZCN_QTDPCT "
	cQuery += "FROM ZCN010 (NOLOCK) "
	cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_CODENCX = ZCN_CODIGO AND SA1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZCN_FILIAL = '' "
	cQuery += "AND ZCN_REF = LEFT(ZDY_PRODUT, 8) "
	cQuery += "AND ZCN_TAM = RIGHT(RTRIM(ZDY_PRODUT), 4) "
	cQuery += "AND A1_COD = ZDY_CLI "
	cQuery += "AND A1_LOJA = ZDY_LOJA "
	cQuery += "AND ZCN_QTDPCT > 0 "
	cQuery += "AND ZCN010.D_E_L_E_T_ = ''), Z7_QTDPCT) "
	cQuery += "AND ZDY_MULTIP = 1 "
	cQuery += "AND ZDY_DCVINS = '' "
	if !Empty(cCliPCT)
		cQuery += "AND ZDY_CLI = '"+AllTrim(cCliPCT)+"' "
	EndIf
	if !Empty(cPedPCT)
		cQuery += "AND ZDY_PEDORI = '"+AllTrim(cPedPCT)+"' "
	EndIf
	if !Empty(cLocPCT)
		cQuery += "AND ZDY_LOCAL = '"+AllTrim(cLocPCT)+"' "
	EndIf
	if !Empty(cPCTOrig)
		cQuery += "AND ZDY_CODCXA LIKE '%"+AllTrim(cPCTOrig)+"%' "
	EndIf
	cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY ZDY_CODCXA ASC, ZDY_DTGER ASC, ZDY_HRGER ASC"
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		While !TT1120->(Eof())
			// Adiciono na aCols da GetDados:
			Aadd(aColsPCT, {oVerde, AllTrim(TT1120->ZDY_CODCXA), AllTrim(TT1120->B1_CODBAR), AllTrim(TT1120->B1_DESC), TT1120->ZDY_MULTIP, TT1120->RECNOZDY, .F.})

			// Conto apenas os disponíveis para transferência:
			nQtdSld		+= TT1120->ZDY_MULTIP

			// Preencho o múltiplo e código:
			nQtdMult	:= TT1120->Z7_QTDPCT
			cCodBarVld	:= AllTrim(TT1120->B1_CODBAR)

			// Verifico se já passou do múltiplo:
			if TT1120->Z7_QTDPCT <= nQtdSld
				lExiste	:= .T.
				Exit
			EndIf

			TT1120->(dbSkip())
		EndDo
	EndIf

	// Atualizo componente:
	cPCTTot := "TOTAL AVULSO: " + AllTrim(Str(nQtdSld))
	oLstPacote:SetArray(aColsPCT, .F.)
	oLstPacote:ForceRefresh()

	// Verifico se efetuo liberação do campo para o usuário poder prosseguir:
	If lExiste
		cPCTSt	:= "GENTILEZA INFORME A CAIXA DE DESTINO"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText	:= CLR_GRAY
		oPCTDest:SetFocus()
	Else
		if !Empty(cPrPCT)
			cPCTSt	:= "NÃO EXISTEM AVULSOS PARA SEREM MONTADOS PARA ESSE ITEM!"
			oPCTSt:nClrPane := 16777215
			oPCTSt:nClrText	:= CLR_RED
		else
			cPCTSt	:= "GENTILEZA INFORME O CÓDIGO DE BARRAS DO ITEM"
			oPCTSt:nClrPane := 16777215
			oPCTSt:nClrText	:= CLR_GRAY
		EndIf
	EndIf

Return (.T.)

// Função para bipar o avulso para montagem do pacote:
Static Function BpAvulso(cOrig)
	// Valido campos:
	If Empty(cPrPCT)
		cPCTSt	:= "INFORME QUAL PRODUTO DESEJA EMPACOTAR"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_GRAY
		oPrPCT:SetFocus()
		Return(.T.)
	EndIf

	If Empty(cPCTDest)
		cPCTSt	:= "POR GENTILEZA, INFORME O CÓDIGO DA CAIXA DE DESTINO"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_GRAY
		if cOrig != "CAIXA"
			oPCTDest:SetFocus()
		EndIf
		Return(.T.)
	EndIf

	If Empty(cPCTCod)
		cPCTSt	:= "POR GENTILEZA, INFORME O CÓDIGO DO PRODUTO"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_GRAY
		if cOrig != "PRODUTO"
			oPCTCod:SetFocus()
		EndIf
		Return(.T.)
	EndIf

	// Valida código da caixa:
	If Left(cPCTDest, 3) != "SLD"
		cPCTSt	:= "GENTILEZA, VERIFIQUE O CÓDIGO DE CAIXA DE DESTINO"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_RED
		oPCTDest:SetFocus()
		Return(.T.)
	EndIf

	// Valida código do produto:
	if AllTrim(cCodBarVld) != AllTrim(cPCTCod)
		cPCTSt	:= "CÓDIGO DE BARRAS INVÁLIDO!"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_RED
		oPCTCod:SetFocus()
		Return(.T.)
	EndIf

	// Desconta bipagem e atualiza status:
	nQtdBeep++
	cPCTTot := "TOTAL AVULSO: " + AllTrim(Str(nQtdMult - nQtdBeep))

	// Efetuo atualização da grid:
	If Len(aColsPCT) >= nQtdBeep
		aColsPCT[nQtdBeep][1]	:= oVermelho
	EndIf
	oLstPacote:SetArray(aColsPCT, .F.)
	oLstPacote:ForceRefresh()

	if nQtdBeep < nQtdMult
		cPCTSt	:= "POR GENTILEZA, INFORME O CÓDIGO DO PRODUTO"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_GRAY
	Else
		nQtdBeep	:= nQtdMult
		cPCTTot 	:= "PACOTE FINALIZADO!"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_GREEN
		// Chamo processamento do saldo:
		MsAguarde({|| ProcAvulso() }, "Pacote", "Montando pacote...")
	EndIf

	// Zero código:
	cPCTCod	:= Space(TamSx3('B1_CODBAR')[1])
	oPCTCod:SetFocus()

Return (.T.)

// Função para processar a montagem do avulso:
Static Function ProcAvulso()

	Local cRetPCT	:= ""
	Local cReg		:= ""
	Local _x		:= 0

	// Efetua validações:
	if Empty(cPCTDest)
		cPCTSt	:= "NECESSÁRIO INFORMAR O DESTINO!"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_RED
		Return (.T.)
	EndIf

	If Len(aColsPCT) <= 0
		cPCTSt	:= "NÃO EXISTEM AVULSOS PARA SEREM MONTADO COMO PACOTES!"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_RED
		Return (.T.)
	EndIf

	if nQtdBeep < nQtdMult
		cPCTSt	:= "FAVOR BIPAR OS AVULSOS DE ACORDO COM O MÚLTIPLO DO ITEM!"
		oPCTSt:nClrPane := 16777215
		oPCTSt:nClrText := CLR_RED
		Return (.T.)
	EndIf

	// Retiro registros:
	For _x := 1 To Len(aColsPCT)
		cReg	+= AllTrim(Str(aColsPCT[_x][6]))+";"
	Next _x

	// Efetua montagem do pacote:
	cRetPCT	:= BuscaWS("&a=pacote", "&d="+AllTrim(cPCTDest)+"&r={"+cReg+"}&u="+AllTrim(cUserName))

	// Verifico retorno:
	if Left(cRetPCT, 2) != "OK"
		MsgStop("Ocorreu um erro na tentativa de montar o pacote: " + cRetPCT)
	Else
		MsgBox(cRetPCT, "Êxito", "INFO")
		AvuLimpar()
	EndIf

Return (.T.)

// Função para consultar a gaiola em si:
Static Function ConsGai()

	Local oGrTra
	Local oGrGai
	Local oFGra		:= TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)

	// Campos que serão manipulados:
	Private oConsCmGa
	Private cConsGa		:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	Private cConsGaUlt	:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	Private cEndGa		:= Space(TamSx3('ZDU_ENDERE')[1] + 1)
	Private oDlgCDCons

	// GetDados gaiola:
	Private oLstGaCons
	Private aCabeGaiCs	:= {}
	Private aColsGaiCs	:= {}

	// Formulário padrão:
	oDlgCDCons := TDialog():New(0,0,600,800,"Consulta de Gaiola",,,,,,,,,.T.,,,,,)
	oDlgCDCons:SetColor(0, 16777215)
	oDlgCDCons:lCentered := .T.
	oDlgCDCons:lEscClose := .F.
	oDlgCDCons:nStyle:=128

	// Grupo de dados da transferência:
	@ 005, 005 GROUP oGrTra TO 050, 395 PROMPT "Dados de Consulta" OF oDlgCDCons COLOR 0, 16777215 PIXEL
	@ 018, 015 SAY oConsGa PROMPT "Gaiola:" SIZE 100, 010 OF oGrTra COLORS CLR_BLACK PIXEL
	@ 025, 015 MSGET oConsCmGa VAR cConsGa SIZE 100, 015 OF oGrTra F3 "ZDUCD" VALID ConsGaiItn(cConsGa) COLORS CLR_RED PIXEL
	@ 029, 120 SAY oConsGa PROMPT cEndGa SIZE 100, 010 OF oGrTra FONT oFGra COLORS CLR_GREEN PIXEL

	// Grupo de dados para demonstrar itens dentro da gaiola:
	@ 055, 005 GROUP oGrGai TO 265, 395 PROMPT "Itens da Gaiola" OF oDlgCDCons COLOR 0, 16777215 PIXEL

	// Definindo cabeçalho:
	Aadd(aCabeGaiCs, {"Cód. Barras"		,"BARRA","@!"	,TamSx3('B1_CODBAR')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGaiCs, {"Produto"			,"PROD"	,"@!"	,TamSx3('B1_DESC')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGaiCs, {"Qtd."			,"QTD"	,"@!"	,TamSx3('C6_QTDVEN')[1],TamSx3('C6_QTDVEN')[2],"","","N","","R","",""})

	// Itens da gaiola:
	oLstGaCons := MsNewGetDados():New(065, 010, 260, 390, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", {}, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oGrGai, aCabeGaiCs, aColsGaiCs)

	// Botões de ação:
	@ 270, 340 BUTTON oBtnSa PROMPT "Sair" SIZE 050, 020 OF oDlgCDCons PIXEL Action oDlgCDCons:End()

	// Ativo formulário:
	oDlgCDCons:Activate(,,,.T.,,,)

Return (.T.)

// Função para popular os itens de consulta da gaiola:
Static Function ConsGaiItn(cConsGa)

	// Vazio:
	if Empty(cConsGa)
		Return(.T.)
	EndIf
	If cConsGaUlt == cConsGa
		Return(.T.)
	EndIf
	cConsGaUlt := cConsGa

	// Zero acols inicial:
	aColsGaiCs	:= {}
	cEndGa		:= ""

	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	// Busca gaiolas ZDU:
	cQuery := "SELECT B1_CODBAR, B1_DESC, SUM(ZDU_MULTIP) AS QTD, MAX(ZDU_ENDERE) AS ENDERECO "
	cQuery += "FROM ZDU010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDU_FILIAL = '' "
	cQuery += "AND ZDU_CODGA = '"+ IIF(Left(AllTrim(cConsGA), 2) != "GL", "GL"+AllTrim(cConsGA), AllTrim(cConsGA))+"' "
	cQuery += "AND ZDU_LOCFIS = 'CD' "
	cQuery += "AND ZDU_PEDCXA = '' "
	cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	// Junção das tabelas:
	cQuery += "UNION "
	// Busca saldos ZDY:
	cQuery += "SELECT B1_CODBAR, B1_DESC, SUM(ZDY_MULTIP) AS QTD, MAX(ZDY_ENDERE) AS ENDERECO "
	cQuery += "FROM ZDY010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDY_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDY_FILIAL = '' "
	cQuery += "AND ZDY_CODCXA = '"+AllTrim(cConsGa)+"' "
	cQuery += "AND ZDY_LOCFIS = 'CD' "
	cQuery += "AND ZDY_PEDCXA = '' "
	cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		While !TT1120->(Eof())
			// Atualizo aCols dos itens:
			Aadd(aColsGaiCs, {TT1120->B1_CODBAR, TT1120->B1_DESC, TT1120->QTD, .F.})

			// Populo endereço:
			cEndGa	:= "ENDEREÇO ["+AllTrim(TT1120->ENDERECO)+"]"

			// Próximo registro:
			TT1120->(dbSkip())
		EndDo
	Else
		// Não localizada:
		MsgStop("Gaiola ["+AllTrim(cConsGa)+"] não foi localizada no CD ou já encontra-se vazia!")
		// Zero variável:
		cConsGa	:= Space(TamSx3('ZDU_CODGA')[1] + 1)
		oConsCmGa:Refresh()
	EndIf

	// Atualizo aCols dos itens:
	oLstGaCons:SetArray(aColsGaiCs, .F.)
	oLstGaCons:ForceRefresh()

	// Retorno focus:
	oConsCmGa:SetFocus()

Return (.T.)

// Função para verificar qual item deverá ser encaixotado:
Static Function ItemGaiola()

	// Limpo variável:
	cSItnGa	:= ''

	If Empty(cGaiolaVa) .Or. Empty(cC5_Num)
		Return (.T.)
	EndIf

	// Busco item dentro da gaiola:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	if cTipoCDGr == "GAIOLA"
		// Busca gaiolas ZDU:
		cQuery := "SELECT SUM(ZDU_MULTIP) AS QTD_EST, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, MAX(ZDU_ENDERE) AS ENDERECO "
		cQuery += "FROM ZDU010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDU_FILIAL = '' "
		cQuery += "AND ZDU_CODGA = 'GL"+cGaiolaVa+"' "
		cQuery += "AND ZDU_LOCFIS = 'CD' "
		cQuery += "AND ZDU_PEDCXA = '' "
		cQuery += "AND ZDU_ENDERE <> '' "
		If cPrBuff != ""
			cQuery += "AND (ZDU_PRODUT = '"+Alltrim(cPrBuff)+"' OR B1_CODBAR = '"+Alltrim(cPrBuff)+"')  "
		EndIF
		cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	Elseif cTipoCDGr == "SALDO"
		// Busca saldos ZDY:
		cQuery := "SELECT SUM(ZDY_MULTIP) AS QTD_EST, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, MAX(ZDY_ENDERE) AS ENDERECO "
		cQuery += "FROM ZDY010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDY_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDY_FILIAL = '' "
		cQuery += "AND ZDY_CODCXA = '"+cGaiolaVa+"' "
		cQuery += "AND ZDY_LOCFIS = 'CD' "
		cQuery += "AND ZDY_PEDCXA = '' "
		cQuery += "AND ZDY_ENDERE <> '' "
		If cPrBuff != ""
			cQuery += "AND (ZDY_PRODUT = '"+Alltrim(cPrBuff)+"' OR B1_CODBAR = '"+Alltrim(cPrBuff)+"')  "
		EndIF
		cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	Elseif cTipoCDGr == "ORDEM"
		// Busca item na ZBL:
		cQuery := "SELECT SUM(ZBL_QTDPRO) AS QTD_EST, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, MAX(ZBL_ENDTRA) AS ENDERECO "
		cQuery += "FROM ZBL010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZBL_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZBL_FILIAL = '' "
		cQuery += "AND ZBL_CODIGO = '"+cGaiolaVa+"' "
		cQuery += "AND ZBL_QTDRET > 0 "
		If cPrBuff != ""
			cQuery += "AND (ZBL_PRODUT = '"+Alltrim(cPrBuff)+"' OR B1_CODBAR = '"+Alltrim(cPrBuff)+"')  "
		EndIF
		cQuery += "AND ZBL010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	EndIf
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		While !TT1120->(Eof())
			if TT1120->QTD_ENC > 0
				cSItnGa	:= "["+AllTrim(TT1120->B1_CODBAR)+"]"+Chr(13)+Chr(10)
				cSItnGa	+= "["+AllTrim(TT1120->B1_DESC)+"]"+Chr(13)+Chr(10)
				cSItnGa	+= "[x"+AllTrim(Str(TT1120->QTD_EST))+" | x"+AllTrim(Str(TT1120->QTD_ENC))+"] peça(s)"
				cSItnGa	+= "[x"+AllTrim(Str(TT1120->QTD_EST))+" | x"+AllTrim(Str(TT1120->QTD_ENC))+"] peça(s)"+Chr(13)+Chr(10)
				cSItnGa	+= "["+AllTrim(cGaiolaVa)+" - "+AllTrim(TT1120->ENDERECO)+"]"
				oSItnGa:Refresh()
			EndIf
			TT1120->(dbSkip())
		EndDo
	EndIf

Return (.T.)

// Função que efetua impressão dos itens a serem coletados:
Static Function ImpColCD()

	Local cImprCD	:= 'ZEBRAZT'								// Nome da impressora compartilhada
	Local cPortaCD	:= 'LPT1'									// Porta que está mapeada
	Local cDirEtqCD	:= '\EtiqPrjEsp\'							// Caminho dentro do Protheus_Data que estão as etiquetas .prn
	Local nTamEtq	:= 1200										// Tamanho da etiqueta em milímetros
	Local cCmdZPL	:= ''  										// Variável que receberá as informações ZPL para ser enviadas para a impressora
	Local cArqCD	:= cDirEtqCD + 'Coleta_CD.prn'				// Caminho + nome do arquivo completo para buscar as informações do .prn
	Local cZPLItn	:= ""
	Local nLinZPL	:= 335
	Local _x 		:= 0

	// Verifico se existe conteúdo para ser impresso:
	If Empty(cNumPedCD) .Or. Empty(cGaiolaCD) .Or. Empty(cEndereCD) .Or. Len(aColsSld) <= 0
		Return
	EndIf

	// Verifico se o arquivo existe:
	If !File(cArqCD)
		MsgStop("Atenção, não foi possível localizar o arquivo PRN ["+cArqCD+"]! Gentileza solicitar para liberação das etiquetas...")
		Return
	EndIf
	// Abro o arquivo:
	nHandle := FOpen(cArqCD, FO_READ)
	If nHandle == -1
		MsgStop('Erro ao abrir o arquivo: '+Str(FError(), 4))
		Return
	EndIf
	// Efetuo a leitura do arquivo:
	FRead(nHandle, cCmdZPL, 65000)
	// Fecho o arquivo:
	FClose(nHandle)

	// Caso tenha algum conteúdo:
	If cCmdZPL <> ''
		// Efetuo atualização das variáveis:
		cCmdZPL	:= StrTran(cCmdZPL, "%NUM_PEDIDO%", "PEDIDO: "+AllTrim(cNumPedCD)+"")
		cCmdZPL	:= StrTran(cCmdZPL, "%TIPO_EMB%", " "+Upper(AllTrim(cGaiolaCD))+" ")
		cCmdZPL	:= StrTran(cCmdZPL, "%ENDERECO%", " "+Upper(AllTrim(StrTran(cEndereCD, "ç", "c")))+" ")

		// Busco itens da aCols:
		cZPLItn = ""
		For _x := 1 to Len(aColsSld)
			// Campo de quantidade:
			cZPLItn += "^FT46,"+AllTrim(Str(nLinZPL))+"^A0N,25,20^FH\^FD"+AllTrim(Str(aColsSld[_x][1]))+"^FS"
			// Campo da descrição do produto:
			cZPLItn += "^FT91,"+AllTrim(Str(nLinZPL))+"^A0N,25,20^FH\^FD"+AllTrim(aColsSld[_x][2])+" ["+AllTrim(aColsSld[_x][3])+"]^FS"
			// Incremento da linha:
			nLinZPL += 50
		Next _x
		// Atualizo itens do corpo:
		cCmdZPL	:= StrTran(cCmdZPL, "%A_CORPO%", cZPLItn)
		// Atualizo rodapé:
		cCmdZPL	:= StrTran(cCmdZPL, "%DADOS_IMP%", Upper(AllTrim(cUserName))+" ["+DtoC(dDataBase)+" "+Time()+"] " + Upper(AllTrim(ComputerName())))

		// Envio para impressora:
		MSCBPRINTER(cImprCD, cPortaCD, , , .F.)
		MSCBCHKSTATUS(.F.)
		MSCBINFOETI("LISTA_ITENS", "LISTA_ITENS")
		MSCBBEGIN(1, 6, nTamEtq)
		MSCBWrite(cCmdZPL)
		MSCBEND()
		MSCBCLOSEPRINTER()
	Else
		// Mensagem de erro:
		MsgStop("Atenção, não foi possível encontrar nenhuma informação dentro do arquivo ["+cArqCD+"]!")
	EndIf

Return (.T.)

// Função para confirmar a coleta dos itens solicitados:
Static Function OKSldCD(lContinua)

	IF MsgBox("Confirma coleta dos itens acima?", "Coleta", "YESNO")
		// Preencho conforme a validação solicita:
		cGaiola	:= cPrefCDGa+cGaiolaVa
		// Envio para confirmação da gaiola:
		VerGaiola(lContinua)
	EndIf

Return

// Função para atualizar a tela do CD:
Static Function AtualizCD()
	// Limpo código da gaiola:
	cGaiola	:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	// Atualizo tela:
	MsAguarde({|| VerPedCD(IIF(Empty(cNumPedCD), .F., .T.), "") }, "Atualizando", "Verificando pedido...")
	// Ativo timer:
	//oTmrCD:Activate()
Return

// Função para verificar o pedido que precisa se encaixotado e está na fila:
Static Function VerPedCD(lContinua, cFilAdic)
	Local cRetWS		:= ""
	Local cPedCon		:= ""
	Local lRetPed		:= .T.
	Local oTmrFocus
	Default cFilAdic	:= ""

	// Verifico se existe objeto:
	/*
	If ValType(oDlgCD) != "O"
		If ValType(oTmrCD) == "O"
			oTmrCD:DeActivate()
		EndIf
		Return (lRetPed	:= .F.)
	EndIf

	// Verifico flag em andamento:
	If lTimer
		Return (lRetPed	:= .F.)
	EndIf
	lTimer	:= .T.
	*/

	// Primeiramente limpos as variáveis do CD:
	LimpaCD()

	// Preciso fazer a tratativa para a continuação do encaixotamento no caso de troca de gaiola:
	cPedCon	:= IIF(lContinua, "&p="+cC5_NUM+"&pr="+cPrBuff, "")

	// Efetuo busca no WS:
	If !Empty(cTipoCDGr)
		cCDTitGai 	:= "Informe o código da "+Lower(cTipoCDGr)+" [...]:"
	Else
		cCDTitGai 	:= "Aguarde, pesquisando..."
	Endif
	oCDTitGai:Refresh()
	oGaiola:Disable()
	cGaiola		:= "Aguarde..."
	cRetWS 		:= BuscaWS("&a=buscaped", cPedCon+cFilAdic)
	cGaiola		:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	oGaiola:Enable()

	// Zero itens da aCols:
	aColsSld := {}
	//oLstSaldo:SetArray(aColsSld, .F.)
	//oLstSaldo:ForceRefresh()

	// Trato retorno do WS:
	if cRetWS == ""
		// No caso de não haver retorno do servidor:
		cNumPedCD	:= "ERRO [1]"
		cCliPedCD	:= "Sem retorno do servidor..."
		cObsPedCD	:= "Ocorreu um erro na tentativa de localizar o pedido..."
		lRetPed		:= .F.
	Elseif Left(cRetWS, 2) != "OK"
		// No caso de haver um erro no retorno do servidor:
		cNumPedCD	:= "ERRO [2]"
		cCliPedCD	:= "Erro:"
		cObsPedCD	:= cRetWS
		lRetPed		:= .F.
	ElseIf cRetWS == "OK|VAZIO"
		// Caso não exista nenhum pedido para ser encaixotado:
		cNumPedCD	:= ""
		cCliPedCD	:= "Nenhum pedido..."
		cObsPedCD	:= "Não existe nenhum pedido a ser encaixotado no momento ["+Time()+"]"
		lRetPed		:= .F.
		oGaiola:Disable()
		// Reativo timer:
		/*
		If ValType(oTmrCD) == "O"
			// Preciso zerar variáveis:
			oTmrCD:Activate()
		EndIf
		*/
	Else
		// No caso de existir pedido a ser encaixotado:
		aRetWS	:= StrTokArr(cRetWS, "|")
		If Len(aRetWS) == 8
			// Caso o retorno esteja OK:
			cNumPedCD	:= aRetWS[2]
			cCliPedCD	:= aRetWS[3]
			cDatPedCD	:= aRetWS[4]
			cObsPedCD	:= aRetWS[5]
			cTipoCDGr	:= aRetWS[6]
			cGaiolaCD	:= cTipoCDGr+": "+aRetWS[7]
			cPrefCDGa	:= IIF(cTipoCDGr == "GAIOLA", "GL", "")
			cGaiolaVa	:= aRetWS[7]
			cEndereCD	:= "Endereço: "+aRetWS[8]
			// Busco itens necessários dentro da gaiola:
			ItensNec()
			// Retorno positivo:
			lRetPed		:= .T.
		Else
			// Caso o retorno esteja fora do padrão:
			cNumPedCD	:= "ERRO [3]"
			cCliPedCD	:= "O retorno não está no formato esperado ["+AllTrim(Str(Len(aRetWS)))+"]..."
			cObsPedCD	:= cRetWS
			lRetPed		:= .F.
		EndIf
	EndIf

	// Informativo:
	If !Empty(cTipoCDGr)
		cCDTitGai 	:= "Informe o código de "+Lower(cTipoCDGr)+" ["+DtoC(dDataBase)+" "+Time()+"]:"
	Else
		cCDTitGai 	:= "Nenhuma gaiola/caixa disponível no momento ["+DtoC(dDataBase)+" "+Time()+"]:"
	EndIf

	// Refresh nos campos necessários:
	oDlgCD:SetFocus()
	oNumPedCD:Refresh()
	oCliPedCD:Refresh()
	oDatPedCD:Refresh()
	oObsPedCD:Refresh()
	oGaiolaCD:Refresh()
	oEndereCD:Refresh()
	oGaiola:Refresh()
	oCDTitGai:Refresh()
	oDlgCD:Refresh()

	// Seto focus:
	oGaiola:SetFocus()
	oTmrFocus := TTimer():New(100, {|| oGaiola:SetFocus(), oTmrFocus:DeActivate() }, oDlgCD)
	oTmrFocus:Activate()

	// Libero flag:
	lTimer := .F.
Return (lRetPed)

// Busca itens necessários que estão dentro da gaiola/caixa de saldo:
Static Function ItensNec()

	Local nQtd 		:= 0
	Local lAltBuff	:= .T.
	Local cNvBuff	:= ""

	// Zero aCols inicialmente para popular depois:
	aColsSld := {}
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif

	// Verifico se é pedido de distrbuição:
	VerPedDistr(cNumPedCD)

	oBtnImpCD:Disable()
	if cTipoCDGr == "GAIOLA"
		// No caso de gaiola, eu desativo o botão de OK, forçando o operador a bipar o código:
		oBtnOKCD:Disable()
		// Busca gaiolas ZDU:
		cQuery := "SELECT SUM(ZDU_MULTIP) AS QTD_EST, ZDU_MULTIP AS Q_MULT, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, B1_COD "
		cQuery += "FROM ZDU010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		//cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND C2_NUM+C2_ITEM+C2_SEQUEN = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDU_FILIAL = '' "
		cQuery += "AND ZDU_CODGA = 'GL"+cGaiolaVa+"' "
		cQuery += "AND ZDU_LOCFIS = 'CD' "
		cQuery += "AND ZDU_CLI = '"+Posicione("SC5", 1, xFilial("SC5")+cNumPedCD, "C5_CLIENTE")+"' "
		cQuery += "AND ZDU_LOCFIS = 'CD' "
		cQuery += "AND ZDU_PEDCXA = '' "
		cQuery += "AND ZDU_ENDERE <> '' "
		cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD, ZDU_MULTIP"
	Elseif cTipoCDGr == "ORDEM"
		// No caso de ordem, verifico itens que foram transferidos pela ordem de coleta:
		oBtnOKCD:Enable()
		// Busca itens da ordem ZBL:
		cQuery := "SELECT SUM(IIF(ZBC_QATU < ZBL_QTDPRO, ZBC_QATU, ZBL_QTDPRO)) AS QTD_EST, AVG(ZBL_QTDCAI) AS Q_MULT, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, B1_COD "
		cQuery += "FROM ZBL010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZBL_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN ZBC010 (NOLOCK) ON ZBC_FILIAL = '' AND ZBC_ENDERE = ZBL_ENDTRA AND ZBC_PRODUT = ZBL_PRODUT AND ZBC010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZBL_FILIAL = '' "
		cQuery += "AND ZBL_CODIGO = '"+cGaiolaVa+"' "
		cQuery += "AND ZBL_QTDRET > 0 "
		cQuery += "AND ZBL010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD "
	Elseif cTipoCDGr == "SALDO"
		oBtnOKCD:Enable()
		// Busca saldos ZDY:
		cQuery := "SELECT SUM(ZDY_MULTIP) AS QTD_EST, ZDY_MULTIP AS Q_MULT, (SELECT ISNULL(SUM("+cColEmpDs+" - C6_QTDENCX), 0) FROM SC6010 (NOLOCK) WHERE C6_FILIAL = '01' AND C6_NUM = '"+cNumPedCD+"' AND C6_PRODUTO = B1_COD AND SC6010.D_E_L_E_T_ = '') AS QTD_ENC, B1_DESC, B1_CODBAR, B1_COD "
		cQuery += "FROM ZDY010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDY_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDY_FILIAL = '' "
		cQuery += "AND ZDY_CODCXA = '"+cGaiolaVa+"' "
		cQuery += "AND ZDY_LOCFIS = 'CD' "
		cQuery += "AND ZDY_CLI = '"+Posicione("SC5", 1, xFilial("SC5")+cNumPedCD, "C5_CLIENTE")+"' "
		cQuery += "AND ZDY_PEDCXA = '' "
		cQuery += "AND ZDY_ENDERE <> '' "
		cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
		cQuery += "GROUP BY B1_DESC, B1_CODBAR, B1_COD, ZDY_MULTIP "
	EndIf
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		oBtnImpCD:Enable()
		While !TT1120->(Eof())
			// Alimento produto a ser alterado no bufffer posterior:
			cNvBuff	:= IIF(Empty(cNvBuff), AllTrim(TT1120->B1_COD), "")

			// Verifico se algum item na grade, é igual ao buffer anterior:
			IF AllTrim(TT1120->B1_COD) == AllTrim(cPrBuff)
				// Caso algum item da grid, seja igual ao buffer anterior, eu não preciso efetuar alteração:
				lAltBuff	:= .F.
			EndIf

			// Considero somente o que existe para encaixotar ainda:
			nQtd := IIf(TT1120->QTD_EST > TT1120->QTD_ENC, TT1120->QTD_ENC, TT1120->QTD_EST)
			If nQtd > 0
				// Adiciono na aCols de visualização:
				Aadd(aColsSld, {nQtd, "x"+AllTrim(Str(TT1120->Q_MULT)), AllTrim(TT1120->B1_DESC), AllTrim(TT1120->B1_CODBAR), .F.})
			EndIf
			TT1120->(dbSkip())
		EndDo
	EndIf

	// Caso exista necessidade de alteração do código do buffer do produto, eu faço nesse momento:
	If lAltBuff .Or. Empty(cPrBuff)
		cPrBuff	:= cNvBuff
	EndIf

	// Atualizo aCols dos itens:
	oLstSaldo:SetArray(aColsSld, .F.)
	oLstSaldo:ForceRefresh()

Return (.T.)

// Função para validar a gaiola de acordo com o pedido, e efetuar inicialização do encaixotamento:
Static Function VerGaiola(lContinua)
	Local lRetWS	:= .F.

	// Vazio ignoro:
	if Empty(cGaiola) .Or. Empty(cNumPedCD) .Or. Len(cGaiola) < 6
		Return (.T.)
	EndIf

	// Ao iniciar a validação da gaiola, eu paro o timer:
	//If !lContinua
	//	oTmrCD:DeActivate()
	//EndIf

	// Verifico se a gaiola está OK:
	If AllTrim(cGaiola) != cPrefCDGa+AllTrim(cGaiolaVa)
		// Verifico se existe outra gaiola do mesmo pedido para realizar a consulta:
		lRetWS := VerPedCD(.F., "&p="+AllTrim(cNumPedCD)+"&gp="+AllTrim(cGaiola))

		// Retorno negativo:
		If !lRetWS
			B1120Alert()
			MsgStop("Código incorreto,  gentileza verificar!")
			/*
			If !lContinua
				oTmrCD:Activate()
			EndIf
			*/
			Return (.F.)
		Else
			cCDTitGai 	:= "Favor bipar novamente a gaiola..."
			oCDTitGai:Refresh()
			oGaiola:SetFocus()
			Return(.T.)
		EndIF
	EndIf

	// Verifico se o pedido já não foi carregado por outra estação:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT DISTINCT TOP 1 ZCA_IDCOLE "
	cQuery += "FROM ZCA010 (NOLOCK) "
	cQuery += "WHERE ZCA_FILIAL = '' "
	cQuery += "AND ZCA_PEDIDO = '"+cNumPedCD+"' "
	cQuery += "AND ZCA_CSTAT IN ('CARREGADO', 'ENCAIXOTANDO') "
	cQuery += "AND ZCA_IDCOLE <> '"+Upper(AllTrim(ComputerName()))+"' "
	cQuery += "AND ZCA_DCREC >= '"+DtoS(dDataBase)+"' "
	cQuery += "AND ZCA_IDCOLE <> '' "
	cQuery += "AND ZCA010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		cGaiola	:= Space(TamSx3('ZDU_CODGA')[1] + 1)
		B1120Alert()
		MsgStop("Atenção. Esse pedido está sendo encaixotado por: ["+AllTrim(TT1120->ZCA_IDCOLE)+"]! Gentileza verificar...")
		oGaiola:Refresh()
		Return (.T.)
	EndIf

	// Caso esteja tudo OK, eu saio da rotina e prossigo com o encaixotamento normal:
	oDlgCD:End()

	// Atualizo código da gaiola:
	cSayGai 	:= "Código de "+Trim(Lower(cTipoCDGr))+" - "+StrTran(cGaiola, cPrefCDGa, "", 1, 1)
	oSGaiola:Refresh()

	// Somente atualizo informações caso não seja uma continuação de encaixotamento ref. ao mesmo pedido:
	cC5_Num	:= cNumPedCD
	oC5_Num:Refresh()
	oC5_Num:Disable()

	// Chamo rotina de validação:
	If B1120Ped()
		// Efetuo atualização na ZCA:
		cUpd := ""
		cUpd += "UPDATE ZCA010 SET ZCA_CSTAT = 'CARREGADO' "
		cUpd += "				 , ZCA_STATUS = 'ENCAIXOTANDO' "
		cUpd += "				 , ZCA_DTATU = '"+DtoS(dDataBase)+"' "
		cUpd += "				 , ZCA_HRATU = '"+Substr(Time(), 1, 5)+"' "
		cUpd += "				 , ZCA_IPCOLE = '"+Alltrim(GetClientIP())+"' "
		cUpd += "				 , ZCA_IDCOLE = '"+Upper(AllTrim(ComputerName()))+"' "
		cUpd += "				 , ZCA_DCREC = '"+DtoS(dDataBase)+"' "
		cUpd += "				 , ZCA_HCREC = '"+Substr(Time(), 1, 5)+"' "
		cUpd += "				 , ZCA_STFAT = '' "
		cUpd += "				 , ZCA_STCORT = '' "
		cUpd += "WHERE ZCA_FILIAL = '"+xFilial("ZCA")+"' "
		cUpd += "AND ZCA_PEDIDO = '"+cC5_Num+"' "
		cUpd += "AND ZCA010.D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpd)

		// Atualizo status no pedido:
		U_BUD1162(cC5_Num, 'INICIANDO ENCAIXOTAMENTO NO CD ['+cTipoCDGr+' - '+AllTrim(StrTran(cGaiola, cPrefCDGa, "", 1, 1))+']')

		// No caso do pedido ser de origem de uma ordem de coleta, efetuo a atualização do status na ZFB:
		if cTipoCDGr == "ORDEM"
			TCSQLEXEC("UPDATE ZFB010 SET ZFB_STENCX = 'ENCAIXOTANDO' WHERE ZFB_FILIAL = '"+xFilial("ZFB")+"' AND ZFB_PEDIDO = '"+cC5_Num+"' AND ZFB010.D_E_L_E_T_ = '' ")
		EndIf
	EndIf

	//Verifico onde preciso posicionar o focus:
	If Empty(cC5_Num)
		oC5_Num:SetFocus()
		Return (.T.)
	EndIf
	If Empty(cZZ5_1ACOND)
		oZZ5_1ACOND:SetFocus()
		Return (.T.)
	EndIf
	If Empty(cZZ5_2ACOND)
		oZZ5_2ACOND:SetFocus()
		Return (.T.)
	EndIf
	If Empty(cCodBar)
		oCodBar:SetFocus()
		Return (.T.)
	EndIf

Return (.T.)

// Função para estornar etiquetas não finalizadas anteriormente:
Static Function EstornoETQ()

	// Não efetua estorno do vínculo:
	If AllTrim(GetMv("BD_1120EXC")) == "N"
		Return
	EndIf

	// Retorno status da ZDU para local CD, das etiquetas que por algum motivo (queda de sistema - exemplo) não foram geradas/finalizadas anteriormente:
	cUpd := "UPDATE ZDU010 SET ZDU_PEDCXA = '' "
	cUpd += "			     , ZDU_ESTCXA = '' "
	cUpd += "  				 , ZDU_CAIXA = '' "
	cUpd += "			     , ZDU_DTCXA = '' "
	cUpd += "			     , ZDU_HRCXA = '' "
	cUpd += "			     , ZDU_USCXA = '' "
	cUpd += "			     , ZDU_PALLET = '' "
	cUpd += "			     , ZDU_ITECXA = '' "
	cUpd += "			     , ZDU_STATUS = 'ENDERECADO' "
	cUpd += "			     , ZDU_LOCFIS = 'CD' "
	cUpd += "FROM ZDU010 (NOLOCK) "
	cUpd += "	LEFT JOIN ZZ5010 (NOLOCK) ON ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = ZDU_PEDCXA AND ZZ5_NUMETQ = ZDU_CAIXA AND ZZ5010.D_E_L_E_T_ = '' "
	cUpd += "WHERE ZDU_FILIAL = '' "
	cUpd += "	AND ZDU_LOCFIS = 'XX' "
	cUpd += "	AND ZDU_CAIXA <> '' "
	cUpd += "	AND LEFT(ZDU_PEDCXA, 2) NOT LIKE '%"+AllTrim(GetMv("BD_PREFEXP"))+"%' "
	cUpd += "	AND ZDU_DTCXA >= '"+DtoS(dDataBase - 65)+"' "
	cUpd += "	AND ZDU_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"' "
	// Verifico critério de exclusão dos vínculos:
	If AllTrim(GetMv("BD_1120EXC")) == "M"
		cUpd += " AND ZDU_DCVINS = '' "
		cUpd += " AND ZDU_DCVINE = '' "
	EndIf
	cUpd += "	AND ZZ5_PEDIDO IS NULL "
	cUpd += "	AND LEFT(ZDU_PEDIDO, 2) NOT LIKE '%"+AllTrim(GetMv("BD_PREFEXP"))+"%' "
	cUpd += "	AND ZDU010.D_E_L_E_T_ = '' "
	TCSQLEXEC(cUpd)

	// Também preciso fazer o estorno também na ZDY:
	cUpd := "UPDATE ZDY010 SET ZDY_PEDCXA = '' "
	cUpd += "			     , ZDY_ESTCXA = '' "
	cUpd += "  				 , ZDY_CAIXA = '' "
	cUpd += "			     , ZDY_DTCXA = '' "
	cUpd += "			     , ZDY_HRCXA = '' "
	cUpd += "			     , ZDY_USCXA = '' "
	cUpd += "			     , ZDY_PALLET = '' "
	cUpd += "			     , ZDY_ITECXA = '' "
	cUpd += "			     , ZDY_LOCFIS = 'CD' "
	cUpd += "FROM ZDY010 (NOLOCK) "
	cUpd += "	LEFT JOIN ZZ5010 (NOLOCK) ON ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = ZDY_PEDCXA AND ZZ5_NUMETQ = ZDY_CAIXA AND ZZ5010.D_E_L_E_T_ = '' "
	cUpd += "WHERE ZDY_FILIAL = '' "
	cUpd += "	AND ZDY_LOCFIS = 'XX' "
	cUpd += "	AND ZDY_CAIXA <> '' "
	cUpd += "	AND LEFT(ZDY_PEDCXA, 2) NOT LIKE '%"+AllTrim(GetMv("BD_PREFEXP"))+"%' "
	cUpd += "	AND ZDY_DTCXA >= '"+DtoS(dDataBase - 65)+"' "
	cUpd += "	AND ZDY_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"' "
	// Verifico critério de exclusão dos vínculos:
	If AllTrim(GetMv("BD_1120EXC")) == "M"
		cUpd += " AND ZDY_DCVINS = '' "
		cUpd += " AND ZDY_DCVINE = '' "
	EndIf
	cUpd += "	AND ZZ5_PEDIDO IS NULL "
	cUpd += "	AND ZDY010.D_E_L_E_T_ = '' "
	TCSQLEXEC(cUpd)

	// Preciso retirar as ZDU que existem ZDY no CD:
	cUpd := ""
	cUpd += "UPDATE ZDU010 SET ZDU_PALLET = ZDY_PALLET "
	cUpd += "			     , ZDU_LOCFIS = 'XX' "
	cUpd += "			     , ZDU_STATUS = 'TRANSFERIDO PARA SALDO' "
	cUpd += "FROM ZDU010 (NOLOCK) "
	cUpd += "	INNER JOIN ZDY010 (NOLOCK) ON ZDY_FILIAL = '' AND ZDY_ORIG = 'ZDU_'+LTRIM(RTRIM(STR(ZDU010.R_E_C_N_O_))) AND ZDY_LOCFIS = 'CD' AND ZDY010.D_E_L_E_T_ = '' "
	cUpd += "WHERE ZDU_FILIAL = '' "
	cUpd += "	AND ZDU_LOCFIS = 'CD' "
	cUpd += "	AND ZDU010.D_E_L_E_T_ = '' "
	TCSQLEXEC(cUpd)

Return

// Função para permitir a troca de gaiola:
Static Function TrocaGai(lContinua)

	// Desativo timer:
	/*
	If ValType(oTmrCD) == "O"
		oTmrCD:DeActivate()
	EndIf
	*/

	// Verifico se é necessário abrir a tela:
	If lContinua
		TelaCD(.T.)
		Return (.T.)
	EndIf

	// Após abrir a tela, eu atualizo com uma gaiola diferente:
	If !lSairCD
		VerPedCD(.T., "&g="+cPrefCDGa+cGaiolaVa)
	EndIf

Return (.T.)

// Função para liberar encaixotamento sem vínculo:
Static Function LiberarCD()

	Local oFBtnLib	:= TFont():New("Tahoma",,012,,.F.,,,,,.F.,.F.)
	Local oFMatric	:= TFont():New("Tahoma",,050,,.T.,,,,,.F.,.F.)
	Local cCDMatri	:= Space(TamSx3('CB1_MATRIC')[1])
	Local oBtnOKLib
	Local oBtnCanLib
	Private oCDMatri
	Private oDlgLib := TDialog():New(0,0,0,0,"Liberação de Encaixotamento",,,,,,,,oDlgCD,.T.,,,,410,200,.F.)

	// Formulário de liberação:
	oDlgLib:SetColor(0, 16777215)
	oDlgLib:lCentered := .T.
	oDlgLib:lEscClose := .T.
	oDlgLib:nStyle:=128

	@ 005, 005 GROUP oGrLib TO 070, 200 PROMPT "Matrícula" OF oDlgLib COLOR 0, 16777215 PIXEL
	@ 015, 010 SAY oTitLib PROMPT "Informe a matrícula do supervisor:" SIZE 200, 050 OF oDlgLib COLORS CLR_BLACK PIXEL
	@ 025, 010 MSGET oCDMatri VAR cCDMatri SIZE 185, 035 OF PIXEL FONT oFMatric COLORS CLR_BLACK PIXEL
	@ 075, 135 BUTTON oBtnOKLib PROMPT "OK" SIZE 030, 015 OF oDlgLib FONT oFBtnLib PIXEL Action VerMatrCD(cCDMatri)
	@ 075, 170 BUTTON oBtnCanLib PROMPT "Cancelar" SIZE 030, 015 OF oDlgLib FONT oFBtnLib PIXEL Action oDlgLib:End()

	oDlgLib:Activate(,,,.T.,,,)

Return

// Verifica se a matrícula do operador é administrador para permitir liberação manual do encaixotamento CD:
Static Function VerMatrCD(cCDMatri)

	Local lVldMatr	:= .F.

	// Vazio simplismente ignoro:
	If Empty(cCDMatri)
		Return (.T.)
	EndIf

	// Chamo rotina de verificação:
	MsAguarde({|| lVldMatr := AdmOperCD(cCDMatri) }, "Aguarde", "Verificando matrícula...")

	// Tratar em caso positivo:
	If lVldMatr
		oDlgLib:End()
		oDlgCD:End()
		lCDBudd	:= .F.
		oC5_Num:Enable()
		oC5_Num:Refresh()
	Else
		B1120Alert()
		MsgStop("Matrícula inválida, gentileza verificar!!!")
		oCDMatri:SetFocus()
		oCDMatri:Refresh()
		oDlgLib:Refresh()
	EndIf

	// Validação da matrícula:
Return (.T.)
Static Function AdmOperCD(cCDMatri)
	Local lVldMatr	:= .F.

	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT DISTINCT TOP 1 CB1_NOME "
	cQuery += "FROM CB1010 (NOLOCK) "
	cQuery += "WHERE CB1_FILIAL = '01' "
	cQuery += "AND CB1_MATRIC = '"+cCDMatri+"' "
	cQuery += "AND ((CB1_ESTINT = '1' AND CB1_ADMINT = '1') OR (CB1_ROTINA LIKE '%BUD1120%')) "
	cQuery += "AND CB1_STATUS = '1' "
	cQuery += "AND CB1010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		lVldMatr	:= .T.
	EndIf

Return (lVldMatr)

// Verifico endereço livre para pós encaixotamento pallet:
Static Function VerEndEst(cPedPallet)

	Local nOpcAviso		:= 0
	Local cFilEndere	:= ""
	Local _z			:= 0
	Local lUsuario		:= .F.

	// Verifico ação:
	If cPedPallet == "NOVO" .Or. Left(cPedPallet, 7) == "PROXIMO"
		lUsuario	:= .T.

		// Se estiver pesquisando pelo próximo endereço:
		If cPedPallet == "PROXIMO"
			If Len(aEnderPes) > 0
				cFilEndere += " AND BE_LOCALIZ NOT IN ("

				For _z := 1 To Len(aEnderPes)
					cFilEndere += "'" + aEnderPes[_z] + "'"
					If _z < Len(aEnderPes)
						cFilEndere += ", "
					EndIf
				Next _z
				cFilEndere += ")"

			EndIf

		EndIf

		// Armazeno pedido atual:
		cPedPallet	:= cC5_num+AllTrim(cPallet)
	EndIf

	// Se for a primeira caixa, efetuo pausa para evitar conflitos de utilizações simultâneas:
	if cNumCxa == "000001"
		Sleep(Randomize(5000, 15000))
	EndIf

	// Consulta do endereço disponível:
	If (Select("TT1120R") <> 0)
		DbSelectArea("TT1120R")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 "

	// Endereços utilizados do pallet atual:
	cQuery += " (ISNULL((SELECT TOP 1 ZBM_ENDERE FROM ZBM010 (NOLOCK) WHERE ZBM_FILIAL = '' AND ZBM_PALLET = '"+cPedPallet+"' AND ZBM_PALLET <> '' AND ZBM_QTDTOT > 0 AND ZBM010.D_E_L_E_T_ = '' ORDER BY IIF(ZBM_ENDERE LIKE 'PE%', 'A', 'B') ASC), '')) AS END_ATUAL, "
	cQuery += " (ISNULL((SELECT TOP 1 ZBD_ENDERE FROM ZBD010 (NOLOCK) WHERE ZBD_FILIAL = '' AND ZBD_PALVIN = '"+cPedPallet+"' AND ZBD_PALVIN <> '' AND ZBD_TIPOMO = 'E' AND ZBD010.D_E_L_E_T_ = '' ORDER BY IIF(ZBD_ENDERE LIKE 'PE%', 'A', 'B') ASC, ZBD_DATA ASC, ZBD_HORA ASC), '')) AS END_ANTER, "

	// Endereços livres:
	cQuery += " (SELECT TOP 1 IIF(ISNULL(SUM(ZBM_QTDTOT), 0) <= 0, 'A', 'B') FROM ZBM010 (NOLOCK) WHERE ZBM_FILIAL = '' AND ZBM_ENDERE = BE_LOCALIZ AND ZBM_QTDTOT > 0 AND ZBM010.D_E_L_E_T_ = '') AS LIVRE_PALLET, "
	cQuery += " (IIF(BE_STATUS = '1', 'A', 'B')) AS LIVRE_ENDERECO, "

	// Endereços recentementes gerados etiqueta:
	cQuery += " (IIF((SELECT TOP 1 ZZ5_ENDERE FROM ZZ5010 (NOLOCK) "
	cQuery += "WHERE ZZ5_FILIAL = '01' "
	cQuery += "AND ZZ5_IMPRES = 'S' "
	cQuery += "AND ZZ5_TPETQ = 'PP' "
	cQuery += "AND ZZ5_DTRET >= '"+DtoS(dDataBase - 1)+"' "
	cQuery += "AND (ZZ5_DTRET + ZZ5_HRRET) >= IIF(ZZ5_ORDEM = '', FORMAT(DATEADD(HOUR, -24, GETDATE()), 'yyyyMMddHH:mm'), FORMAT(DATEADD(MINUTE, -35, GETDATE()), 'yyyyMMddHH:mm')) "
	cQuery += "AND ZZ5_ENDERE = BE_LOCALIZ "
	cQuery += "AND ZZ5_PEDIDO <> '"+cC5_Num+"' "
	cQuery += "AND ZZ5010.D_E_L_E_T_ = '') IS NULL, 'A', 'B')) AS ENDERECO_RECENTE, "

	// Endereços com movimentação recente:
	cQuery += " (IIF((SELECT TOP 1 ZBD_ENDERE FROM ZBD010 (NOLOCK) "
	cQuery += "WHERE ZBD_FILIAL = '' "
	cQuery += "AND ZBD_TIPOMO = 'E' "
	cQuery += "AND ZBD_ENDERE = BE_LOCALIZ "
	cQuery += "AND ZBD_PALVIN <> '"+cPedPallet+"' "
	cQuery += "AND ZBD_DATA >= '"+DtoS(dDataBase - 1)+"' "
	cQuery += "AND (ZBD_DATA + ZBD_HORA) >= FORMAT(DATEADD(MINUTE, -47, GETDATE()), 'yyyyMMddHH:mm') "
	cQuery += "AND ZBD010.D_E_L_E_T_ = '') IS NULL, 'A', 'B')) AS MOVIMENTACAO_RECENTE, "

	// Endereço sugerido:
	cQuery += " BE_LOCALIZ AS END_SUG "

	cQuery += "FROM SBE010 (NOLOCK) "
	cQuery += "LEFT JOIN ZDX010 (NOLOCK) ON ZDX_FILIAL = '' AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' AND ZDX_ENDERE <> '' AND ZDX010.D_E_L_E_T_ = '' "
	cQuery += "WHERE BE_FILIAL = '01' "
	cQuery += "AND BE_TIPODES = 'ENDERECAR' "
	cQuery += "AND BE_LOCALIZ LIKE 'PE%' "
	cQuery += cFilEndere
	cQuery += "AND SBE010.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY END_ATUAL DESC, END_ANTER DESC, LIVRE_PALLET ASC, LIVRE_ENDERECO ASC, ENDERECO_RECENTE ASC, IIF(LEFT(BE_LOCALIZ, 3) = LEFT(ZDX_ENDERE, 3), 'A', 'B') ASC, LEN(BE_LOCALIZ) ASC, BE_LOCALIZ ASC"
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120R"
	If !TT1120R->(Eof())
		// [3] Enderço sugerido:
		If !Empty(TT1120R->END_SUG)
			cEnderEst	:= AllTrim(TT1120R->END_SUG)
		EndIf

		// [2] Caso o pallet foi endereçado anteriormente em algum outro endereço, eu considero ele:
		If !Empty(TT1120R->END_ANTER)
			cEnderEst	:= AllTrim(TT1120R->END_ANTER)
		EndIf

		// [1] Caso o pallet tenha saldo em algum endereço eu considero ele:
		If !Empty(TT1120R->END_ATUAL)
			cEnderEst	:= AllTrim(TT1120R->END_ATUAL)
		EndIf
	Else
		If lUsuario
			aEnderPes	:= {}
			MsgStop("Nenhum endereço disponível para endereçamento do pallet ["+cPedPallet+"]!")
		EndIf
	EndIf

	// Atualizo endereço informativo:
	oBTEnd:SetText(cEnderEst)
	oBTEnd:Refresh()

	// Confirma endereço de saída do pallet:
	If lUsuario
		If Empty(cEnderEst)
			nOpcAviso	:= Aviso("Atenção", "Nenhum Endereço sugerido localizado!"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Deseja efetuar nova busca ou informar o endereço?", {"Buscar Novamente", "Informar"}, 2)
		Else
			nOpcAviso	:= Aviso("Atenção", "Endereço sugerido localizado: ["+cEnderEst+"]"+Chr(13)+Chr(10)+Chr(13)+Chr(10)+Chr(13)+Chr(10)+"Deseja utilizar esse endereço para o pallet?", {"Buscar Próximo", "Informar", "Utilizar ["+cEnderEst+"]"}, 2)
		EndIf

		// Buscar próximo endereço:
		If nOpcAviso == 1
			// Incluo endereço rejeitado na pesquisa:
			AAdd(aEnderPes, cEnderEst)

			// Buscar próximo endereço:
			MsAguarde({|| VerEndEst("PROXIMO") }, "Endereço", "Aguarde, verificando próximo endereço disponível...")
			Return
		EndIf

		// Solicitar para o usuário informar o endereço:
		If nOpcAviso == 2
			aEnderPes	:= {}
			cEnderEst 	:= FWInputBox("Informe o endereço para o pallet ["+cPedPallet+"]:", cEnderEst)

			If Empty(cEnderEst)
				MsgStop("O endereço de saída precisa ser informado!")
				MsAguarde({|| VerEndEst("NOVO") }, "Endereço", "Aguarde, verificando endereço disponível...")
				Return
			EndIf

			// Valido e o endereço informado é valido na SBE:
			If (Select("TT1120E") <> 0)
				DbSelectArea("TT1120E")
				DbCloseArea()
			Endif
			cQuery := ChangeQuery("SELECT TOP 1 BE_LOCALIZ FROM SBE010 (NOLOCK) WHERE BE_FILIAL = '01' AND BE_LOCALIZ = '"+cEnderEst+"' AND SBE010.D_E_L_E_T_ = ''")
			TCQuery cQuery NEW ALIAS "TT1120E"
			If TT1120E->(Eof())
				cEnderEst	:= ""
				MsgStop("O endereço informado é inválido, gentileza verificar!")
				MsAguarde({|| VerEndEst("NOVO") }, "Endereço", "Aguarde, verificando endereço disponível...")
				Return
			EndIf

			// Atualizo endereço informativo:
			oBTEnd:SetText(cEnderEst)
			oBTEnd:Refresh()
		EndIf

		// Segue utilizando o endereço sugerido:
		If nOpcAviso == 3
			aEnderPes	:= {}
		EndIf
	Else
		// Caso seja feita uma busca automática, limpo o array de endereços pesquisados:
		aEnderPes	:= {}
	EndIF

Return

// Verifico estação vinculada:
Static Function VerEstac(lTipoVer)
	Local lTelaVinc	:= .F.

	// Verifico qual estação está vinculada:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT TOP 1 ZDX_ENDERE "
	cQuery += "FROM ZDX010 (NOLOCK) "
	cQuery += "WHERE ZDX_FILIAL = '' "
	cQuery += "AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' "
	cQuery += "AND ZDX_ENDERE <> '' "
	cQuery += "AND ZDX010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		cCDEstacao	:= AllTrim(TT1120->ZDX_ENDERE)
		// Busca endereço livre para enviar os itens após encaixotados:
		VerEndEst("")
	Else
		lTelaVinc	:= .T.
	EndIf

	// Verifico se é necessário chamar a tela de cadastramento de vínculo nesse momento:
	If lTelaVinc .Or. lTipoVer
		// Chamo tela em qualquer base sob a situação acima:
		TelaVincCD()
		// Continuo chamando a tela caso o usuário não informe corretamente o endereço vinculado a estação:
		While (Empty(cCDEstacao) .Or. Upper(AllTrim(cCDEstacao)) == "ESTACAO")
			TelaVincCD()
		EndDo
	EndIf
Return
Static Function TelaVincCD()

	Local oFBtnVin	:= TFont():New("Tahoma",,012,,.F.,,,,,.F.,.F.)
	Local oFEstac	:= TFont():New("Tahoma",,050,,.T.,,,,,.F.,.F.)
	Local oBtnOKVin
	Private oCDEstac
	Private oDlgVin := TDialog():New(0,0,0,0,"Vincular Endereço",,,,,,,,oDlgCD,.T.,,,,410,200,.F.)

	// Formulário de vinculação do endereço com a estação:
	oDlgVin:SetColor(0, 16777215)
	oDlgVin:lCentered := .T.
	oDlgVin:lEscClose := .F.
	oDlgVin:nStyle:=128

	// Aqui eu deixo a variável vazia para permitir preenchimento:
	cCDEstacao	:= IIF(Upper(AllTrim(cCDEstacao)) == "ESTACAO", Space(TamSx3('ZDX_ESTAC')[1]), cCDEstacao)

	@ 005, 005 GROUP oGrLib TO 070, 200 PROMPT "Estação ["+Upper(AllTrim(ComputerName()))+"]" OF oDlgVin COLOR 0, 16777215 PIXEL
	@ 015, 010 SAY oTitLib PROMPT "Por gentileza, informe o endereço a ser vinculado:" SIZE 200, 050 OF oDlgVin COLORS CLR_BLACK PIXEL
	@ 025, 010 MSGET oCDEstac VAR cCDEstacao SIZE 185, 035 OF PIXEL FONT oFEstac F3 "SBEVIN" PIXEL
	@ 075, 170 BUTTON oBtnOKVin PROMPT "OK" SIZE 030, 015 OF oDlgVin FONT oFBtnVin PIXEL Action MsAguarde({|| VerEstacCD() }, "Aguarde", "Verificando endereço...")

	// É obrigatório efetuar o cadastramento da estação
	oDlgVin:Activate(,,,.T.,,,)
Return
// Função para validar os endereços de vínculo:
Static Function VerEstacCD()

	// Limpo variável:
	cCDEstacao	:= AllTrim(Upper(cCDEstacao))

	// Efetuo validação do endereço na SBE e caso der negativo, obrigatóriamente coloco a variável cCDEstacao para vazio:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT DISTINCT TOP 1 BE_LOCALIZ "
	cQuery += "FROM SBE010 (NOLOCK) "
	cQuery += "WHERE BE_FILIAL = '01' "
	cQuery += "AND BE_LOCALIZ = '"+cCDEstacao+"' "
	cQuery += "AND BE_TIPODES = 'ENDERECAR' "
	cQuery += "AND SBE010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If TT1120->(Eof())
		cCDEstacao	:= Space(TamSx3('BE_LOCALIZ')[1])
	EndIf

	// Aqui efetuo inclusão do registro:
	If Empty(cCDEstacao) .Or. Upper(AllTrim(cCDEstacao)) == "ESTACAO"
		B1120Alert()
		MsgStop("Endereço informado é inválido, gentileza verificar!")
		oDlgVin:Refresh()
		oCDEstac:SetFocus()
		oCDEstac:Refresh()
		Return (.F.)
	EndIf

	// Efetuo vínculo do endereço à estação através da tabela ZDX:
	cUpd := "UPDATE ZDX010 SET ZDX_ENDERE = '"+cCDEstacao+"' WHERE ZDX_FILIAL = '' AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' AND ZDX010.D_E_L_E_T_ = ''; "
	cUpd += "IF @@ROWCOUNT = 0 "
	cUpd += "	BEGIN "
	cUpd += "		INSERT INTO ZDX010 "
	cUpd += "			(	ZDX_ESTAC, ZDX_ENDERE, ZDX_VIRFID, R_E_C_N_O_) "
	cUpd += "				VALUES "
	cUpd += "			( "
	cUpd += "				'"+Upper(AllTrim(ComputerName()))+"', "
	cUpd += "				'"+cCDEstacao+"', "
	cUpd += "				'SIM', "
	cUpd += "				(SELECT ISNULL(MAX(R_E_C_N_O_)+1,1) FROM ZDX010) "
	cUpd += "			); "
	cUpd += "		END "
	TCSQLEXEC(cUpd)

	// Finalmente fecho o formulário prosseguindo com a rotina...
	oCDEstac:Refresh()
	oDlgVin:End()

Return (.T.)

// Limpa variáveis do CD:
Static Function LimpaCD()

	// Limpo as variáveis:
	cNumPedCD 	:= ""
	cCliPedCD	:= ""
	cDatPedCD	:= ""
	cObsPedCD	:= ""
	cGaiolaCD	:= ""
	cTipoCDGr	:= ""
	cGaiolaVa	:= ""
	cEndereCD	:= ""
	cGaiola		:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	cCDTitGai	:= "Informe o código:"
	cNumPedCD	:= ""

Return

// Função para efetuar validação de saldo da gaiola por item:
Static Function SaldoCDGA(cProduto, lEncaix)
	Local nQtdAEnc	:= 0
	Local nQtdGaio	:= 0

	// Verifico preenchimento das variáveis:
	If Empty(cC5_Num) .Or. Empty(cProduto)
		Return (.T.)
	EndIf

	// Verifico quantidade ainda à encaixotar do pedido:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT TOP 1 SUM("+cColEmpDs+" - C6_QTDENCX) AS QTD_A_ENCX "
	cQuery += "FROM SC6010 (NOLOCK) "
	cQuery += "WHERE C6_FILIAL = '01' "
	cQuery += "AND C6_NUM = '"+cC5_Num+"' "
	cQuery += "AND C6_PRODUTO = '"+cProduto+"' "
	cQuery += "AND SC6010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		nQtdAEnc	:= TT1120->QTD_A_ENCX
	EndIf

	// Verifico quantidade de saldo ainda daquele item na gaiola:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT TOP 1 SUM(ZDU_MULTIP) AS QTD_GAIOLA "
	cQuery += "FROM ZDU010 (NOLOCK) "
	//cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDU_FILIAL = '' "
	cQuery += "AND ZDU_PRODUT = '"+cProduto+"' "
	cQuery += "AND ZDU_CODGA = '"+AllTrim(cGaiola)+"' "
	cQuery += "AND ZDU_LOCFIS = 'CD' "
	cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		nQtdGaio	:= TT1120->QTD_GAIOLA
	EndIf

	// Caso a quantidade da gaiola seja superior a encaixotar do item, preciso chamar a rotina de transferência de saldo:
	if lEncaix
		If nQtdGaio > nQtdAEnc
			// Efetuo transferência das etiquetas geradas nesse momento:
			MsAguarde({|| BuscaWS("&a=transfere", "&p="+AllTrim(cC5_Num))+"&g="+AllTrim(cGaiola) }, "Transferindo", "Transferindo itens CD...")
			// Gero etiqueta pallet:
			B1120Pallet()

			if cTipoCDGr == "GAIOLA"
				// Mensagem para o usuário buscar caixa de saldo:
				MsgBox("O item foi finalizado! Favor transferir o saldo restante para a caixa de saldo...", "Saldo", 'INFO')
				// No caso do saldo da gaiola for maior, abro tela de transferência:
				TraSaldoCD()
			Else
				MsgBox('O item foi finalizado!', 'Êxito!', 'INFO')
			EndIf
			// Limpo códigos:
			cCodBar := Space(TamSx3('B1_CODBAR')[1])
			// Chamo novamente a rotina:
			TelaCD(.F.)
			// Retorno:
			Return (.F.)
		Else
			// Gero etiqueta pallet:
			B1120Pallet()
			// Mensagem para usuário:
			MsgBox('O item foi finalizado!', 'Êxito!', 'INFO')
			// Limpo código:
			cCodBar := Space(TamSx3('B1_CODBAR')[1])

			// Chamo novamente a rotina:
			TelaCD(.F.)

			// Retorno:
			Return (.F.)
		EndIf
	EndIf

Return (.T.)

// Verifico saldo da gaiola no CD:
Static Function SaldoCD(cProduto, lNovaGai)
	Local lExiste	:= .F.

	// Zero os dois recnos:
	nRecnoZDU	:= 0
	nRecnoZDY	:= 0

	if cTipoCDGr == "ORDEM"
		// No caso do tipo do encaixotamento ser de uma ordem, eu ignoro essa validação de saldo
		Return (.T.)
	Elseif cTipoCDGr == "GAIOLA"
		// Verifico se existe gaiola com saldo disponível no CD:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		// Busco últimos itens inseridos, possivelmente serão os primeiros a serem retirados da gaiola (FOFI):
		cQuery := ""
		cQuery += "SELECT TOP 1 "
		cQuery += "	ZDU_NUMOP, "
		cQuery += "	ZDU_ITEMGA, "
		cQuery += "	ZDU_MULTIP, "
		cQuery += "	R_E_C_N_O_ AS RECNO_ZDU "
		cQuery += "FROM ZDU010 (NOLOCK) "
		cQuery += "WHERE "
		cQuery += "	D_E_L_E_T_ = '' "
		cQuery += "	AND ZDU_FILIAL = '' "
		cQuery += "	AND ZDU_PRODUT = '"+cProduto+"' "
		cQuery += "	AND ZDU_CODGA = '"+AllTrim(cGaiola)+"' "
		cQuery += "	AND ZDU_LOCFIS = 'CD' "
		if !Empty(cC5_CLIENTE)
			cQuery += "AND ZDU_CLI = '"+cC5_CLIENTE+"' "
		EndIf
		cQuery += "	AND ZDU_MULTIP = '"+AllTrim(Str(nQtdPcte))+"' "
		cQuery += "	AND EXISTS ( "
		cQuery += "SELECT 1 "
		cQuery += "FROM SC5010 (NOLOCK) "
		cQuery += "WHERE "
		cQuery += "	C5_FILIAL = '01' "
		cQuery += "	AND D_E_L_E_T_ = '' "
		cQuery += "	AND C5_CLIENTE = ZDU010.ZDU_CLI "
		cQuery += "	AND C5_LOCAL = ZDU010.ZDU_LOCAL "
		cQuery += "	AND C5_NUM IN (ZDU_PEDIDO, '"+cC5_Num+"') "
		cQuery += ") "
		cQuery += "ORDER BY ZDU_DTGERA ASC, ZDU_HRGERA ASC"
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			lExiste		:= .T.
			cCDItemGa	:= TT1120->ZDU_ITEMGA
			cCDNumOP	:= TT1120->ZDU_NUMOP
			nRecnoZDU	:= TT1120->RECNO_ZDU
		EndIf
	Elseif cTipoCDGr == "SALDO"
		// Verifico se existe caixa com saldo disponível no CD:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		// Busco primeiros itens a serem retirados:
		cQuery := ""
		cQuery += "SELECT TOP 1 ZDY_ORIG, ZDY_MULTIP, ZDY010.R_E_C_N_O_ AS RECNO_ZDY "
		cQuery += "FROM ZDY010 (NOLOCK) "
		cQuery += "WHERE ZDY_FILIAL = '' "
		cQuery += "AND ZDY_PRODUT = '"+cProduto+"' "
		cQuery += "AND ZDY_CODCXA = '"+AllTrim(cGaiola)+"' "
		cQuery += "AND ZDY_LOCFIS = 'CD' "
		cQuery += "AND ZDY_MULTIP = '"+AllTrim(Str(nQtdPcte))+"' "
		// Efetua filtro por cliente:
		if !Empty(cC5_CLIENTE)
			cQuery += "AND ZDY_CLI = '"+cC5_CLIENTE+"' "
		EndIf
		cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY ZDY_MULTIP DESC, ZDY_DTGER ASC, ZDY_HRGER ASC "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			lExiste		:= .T.
			cCDItemGa	:= AllTrim(TT1120->ZDY_ORIG)
			cCDNumOP	:= ""
			nRecnoZDY	:= TT1120->RECNO_ZDY
		EndIf
	EndIf

	// Aqui eu preciso verificar se existe saldo do produto em gaiola ou caixa:
	If !lExiste
		// Verifico se existe itens abaixo do múltiplo na gaiola em questão:
		if cTipoCDGr == "GAIOLA"
			If (Select("TT1120") <> 0)
				DbSelectArea("TT1120")
				DbCloseArea()
			Endif
			// Busco últimos itens inseridos, possivelmente serão os primeiros a serem retirados da gaiola (FOFI):
			cQuery := ""
			cQuery += "SELECT TOP 1 ZDU_NUMOP "
			cQuery += "FROM ZDU010 (NOLOCK) "
			cQuery += "WHERE ZDU_FILIAL = '' "
			cQuery += "AND ZDU_PRODUT = '"+cProduto+"' "
			cQuery += "AND ZDU_CODGA = '"+AllTrim(cGaiola)+"' "
			cQuery += "AND ZDU_LOCFIS = 'CD' "
			cQuery += "AND ZDU_MULTIP < '"+AllTrim(Str(nQtdPcte))+"' "
			cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1120"
			If !TT1120->(Eof())
				B1120Alert()
				IF MsgBox("Existem pacotes abaixo do múltiplo na gaiola ["+AllTrim(cGaiola)+"]. Deseja transferir para saldo?", "Transferir", "YESNO")
					TraSaldoCD()	// Chamo transferência de saldo
				End If
			EndIf
		EndIf

		// Verifico se existe outra gaiola/caixa disponível:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ""
		// Verifico se existe em outra gaiola:
		cQuery += "SELECT TOP 1 ZDU_CODGA "
		cQuery += "FROM ZDU010 (NOLOCK) "
		//cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM IN (ZDU_PEDIDO, '"+cC5_Num+"') AND SC5010.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDU_FILIAL = '' "
		cQuery += "AND ZDU_PRODUT = '"+cProduto+"' "
		cQuery += "AND ZDU_CODGA <> '"+AllTrim(cGaiola)+"' "
		cQuery += "AND ZDU_LOCFIS = 'CD' "
		//cQuery += "AND ((ZDU_CLIGRU = A1_GRUPO AND ZDU_CLIGRU <> '') OR (A1_COD = ZDU_CLI)) "
		cQuery += "AND ZDU_CLIGRU = A1_GRUPO "
		cQuery += "AND ZDU_LOCAL IN (C5_LOCAL) "
		cQuery += "AND ZDU_MULTIP = '"+AllTrim(Str(nQtdPcte))+"' "
		cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
		// Verifico se existe na caixa de saldo:
		cQuery += "UNION "
		cQuery += "SELECT TOP 1 ZDY_CODCXA "
		cQuery += "FROM ZDY010 (NOLOCK) "
		cQuery += "WHERE ZDY_FILIAL = '' "
		cQuery += "AND ZDY_PRODUT = '"+cProduto+"' "
		cQuery += "AND ZDY_CODCXA <> '"+AllTrim(cGaiola)+"' "
		cQuery += "AND ZDY_LOCFIS = 'CD' "
		cQuery += "AND ZDY_MULTIP = '"+AllTrim(Str(nQtdPcte))+"' "
		cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		// Caso exista, solicito nova bipagem:
		If !TT1120->(Eof())
			// Chamo nova tela do CD:
			If lNovaGai
				TelaCD(.T.)
				Return (.T.)
			EndIf
		Else
			B1120Alert()
			if nQtdPcs > 0
				// Se caso tiver quantidade, deverá fazer a transferência para o saldo:
				if cTipoCDGr == "GAIOLA"
					IF MsgBox("Sem saldo no CD para efetuar encaixotamento desse item ["+AllTrim(cProduto)+" X "+AllTrim(cGaiola)+" X "+AllTrim(Str(nQtdPcte))+"][1]. Deseja transferir os itens para o saldo?", "Transferir", "YESNO")
						B1120Pallet()	// Gero pallet com o que foi passado
						B1120Limpar()	// Limpo tela
						TraSaldoCD()	// Chamo transferência de saldo
						TelaCD(.F.)		// Chamo tela do CD para passar outro pedido
					End If
				Else
					MsgStop("Sem saldo no CD para efetuar encaixotamento desse item ["+AllTrim(cProduto)+" X "+AllTrim(cGaiola)+" X "+AllTrim(Str(nQtdPcte))+"][2]!")
				EndIf
			Else
				MsgStop("Sem saldo no CD para efetuar encaixotamento desse item ["+AllTrim(cProduto)+" X "+AllTrim(cGaiola)+" X "+AllTrim(Str(nQtdPcte))+"][3]!")
			End If
			Return (.F.)
		EndIf
	EndIf

Return (.T.)

// Rotina para transferir o restante do saldo da gaiola para a caixa de saldo:
Static Function TraSaldoCD()

	Local oGrTra
	Local oGrGai
	Local oFGra		:= TFont():New("Calibri",,020,,.T.,,,,,.F.,.F.)

	// Campos que serão manipulados:
	Private oDlgCDSld
	Private	oSldGa
	Private oSldCx
	Private oSldPr
	Private oSldCli
	Private cSldGa		:= Space(TamSx3('ZDU_CODGA')[1] + 1)
	Private cSldCa		:= Space(TamSx3('ZDY_CODCXA')[1] + 1)
	Private cSldPed		:= Space(TamSx3('C5_NUM')[1] + 1)
	Private cSldPro		:= Space(TamSx3('B1_CODBAR')[1])
	Private cSldCliPed	:= Space(TamSx3('A1_NOME')[1])
	Private cSldCli 	:= "..."
	Private cSldSta		:= "..."
	Private cSldTot		:= ""
	Private oSaSldSt
	Private lAltSld 	:= .F.
	Private cPedSldH	:= ""
	Private cEndSldH	:= ""
	Private lSldCanc	:= .F.
	Private lSldEfet	:= .F.
	Private nQtdGai		:= 0
	Private oCheckAvul
	Private lCheckAvul	:= .F.

	// GetDados gaiola:
	Private oLstGaiola
	Private aAltGai		:= {}
	Private aCabeGai	:= {}
	Private aColsGai	:= {}

	// Verifico se é um pedido de encaixotamento no CD:
	if !lCDBudd
		Return
	EndIf

	// Formulário padrão:
	oDlgCDSld := TDialog():New(0,0,600,800,"Transferência de Saldos",,,,,,,,,.T.,,,,,)
	oDlgCDSld:SetColor(0, 16777215)
	oDlgCDSld:lCentered := .T.
	oDlgCDSld:lEscClose := .F.
	oDlgCDSld:nStyle:=128

	// Efetuo preenchimento da gaiola, caso exista:
	cSldGa	:= cGaiola

	// Grupo de dados da transferência:
	@ 005, 005 GROUP oGrTra TO 050, 395 PROMPT "Dados da Transferência" OF oDlgCDSld COLOR 0, 16777215 PIXEL

	@ 018, 015 SAY oSaSld PROMPT "DA Gaiola:" SIZE 100, 010 OF oGrTra COLORS CLR_RED PIXEL
	@ 025, 015 MSGET oSldGa VAR cSldGa SIZE 100, 015 OF oGrTra F3 "ZDUCD" VALID SldBuscaTr() COLORS CLR_RED PIXEL

	@ 029, 120 SAY oSaSld PROMPT ">>" SIZE 100, 010 OF oGrTra FONT oFGra PIXEL

	@ 018, 135 SAY oSaSld PROMPT "PARA Caixa/Endereço:" SIZE 100, 010 OF oGrTra COLORS CLR_BLUE PIXEL
	@ 025, 135 MSGET oSldCx VAR cSldCa SIZE 100, 015 OF oGrTra F3 "SBESLD" VALID SldBuscaTr() COLORS CLR_BLUE PIXEL

	// Inclusão do filtro do cliente/pedido para filtrar os itens da gaiola:
	@ 018, 240 SAY oSaSld PROMPT "Cliente/Pedido:" SIZE 100, 010 OF oGrTra PIXEL
	@ 025, 240 MSGET oSldCli VAR cSldCliPed SIZE 100, 015 OF oGrTra PIXEL

	@ 025, 345 BUTTON oBtnSa PROMPT "OK" SIZE 030, 015 OF oDlgCDSld PIXEL Action SldBuscaTr()

	// Grupo de dados para demonstrar itens dentro da gaiola:
	@ 055, 005 GROUP oGrGai TO 215, 395 PROMPT "Itens da Gaiola" OF oDlgCDSld COLOR 0, 16777215 PIXEL

	// Definindo cabeçalho:
	Aadd(aCabeGai, {""				,"IMG"	,"@BMP"	,3						,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Origem"		,"OP"	,"@!"	,TamSx3('ZDU_NUMOP')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Pedido"		,"PEDI"	,"@!"	,TamSx3('C5_NUM')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Nome Cliente"	,"PEDI"	,"@!"	,TamSx3('A1_NOME')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Item"			,"ITEM"	,"@!"	,TamSx3('ZDU_ITEMGA')[1],0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Cód. Barras"	,"BARRA","@!"	,TamSx3('B1_CODBAR')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Produto"		,"PROD"	,"@!"	,TamSx3('B1_DESC')[1]	,0,"","","C","","R","",""})
	Aadd(aCabeGai, {"Múltiplo"		,"MULT"	,"@!"	,TamSx3('ZDU_MULTIP')[1],TamSx3('ZDU_MULTIP')[2],"","","N","","R","",""})
	Aadd(aCabeGai, {"Registro"		,"RECNO","@!"	,8						,0,"","","N","","R","",""})

	// Itens da gaiola:
	oLstGaiola := MsNewGetDados():New(065, 010, 200, 390, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aAltGai, 0, 999, "AllwaysTrue", "", "AllwaysTrue", oGrGai, aCabeGai, aColsGai)
	@ 202, 010 BUTTON oBtnSa PROMPT "Estornar Item" SIZE 050, 010 OF oDlgCDSld PIXEL Action EstSaldo()
	@ 202, 062 BUTTON oBtnSa PROMPT "Transferir Tudo" SIZE 050, 010 OF oDlgCDSld PIXEL Action SldTotal()
	@ 202, 315 SAY oSaSld PROMPT cSldTot SIZE 200, 010 OF oGrGai COLORS CLR_HRED FONT oFGra PIXEL

	// Grupo de dados para efetuar inclusão do código do produto::
	@ 220, 005 GROUP oGrPro TO 260, 395 PROMPT "Transferir" OF oDlgCDSld COLOR 0, 16777215 PIXEL
	@ 237, 020 SAY oSaSld PROMPT "CÓDIGO DO PRODUTO:" SIZE 200, 010 OF oGrGai COLORS CLR_GREEN FONT oFGra PIXEL
	@ 231, 110 MSGET oSldPr VAR cSldPro SIZE 150, 020 OF oGrTra F3 "SB1BAR" VALID InsSaldo(.F.) PIXEL
	@ 237, 270 CHECKBOX oCheckAvul Var lCheckAvul Prompt "Avulso" Size 150, 020 PIXEL OF oDlgCDSld

	// Botões de ação:
	@ 270, 285 BUTTON oBtnSa PROMPT "Cancelar" SIZE 050, 020 OF oDlgCDSld PIXEL Action (lSldCanc := .T., oDlgCDSld:End())
	@ 270, 340 BUTTON oBtnSa PROMPT "OK" SIZE 050, 020 OF oDlgCDSld PIXEL Action (lSldEfet := .T., InsSaldo(.F.), oDlgCDSld:End())
	@ 275, 010 SAY oSaSldSt PROMPT cSldSta SIZE 250, 050 OF oGrGai COLORS CLR_GRAY FONT oFGra PIXEL

	// Efetuo atualização de saldo:
	//MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando etiquetas não finalizadas...")

	// Efetuo validação:
	SldBuscaTr()

	// Ativo formulário:
	oDlgCDSld:Activate(,,,.T.,,,)

	If lAltSld
		// Atualizo histórico do pedido:
		If !Empty(cPedSldH)
			MsAguarde({|| U_BUD1162(cPedSldH, 'SALDO DE ENCAIXOTAMENTO NO ENDERECO ['+AllTrim(cEndSldH)+']') }, "Histórico", "Gravando histórico do pedido...")
		EndIf
		// Verifico se houve alteração para mandar processar WS:
		MsAguarde({|| BuscaWS("&a=saldo", "&g="+AllTrim(cSldGa)) }, "Saldos", "Transferindo saldos...")
	EndIf

Return (.T.)

// Rotina para efetuar transferência do saldo e devidas validações ao bipar o código do produto:
Static Function InsSaldo(lTotal)
	Local lVldPr 		:= .F.
	Local cFilProd		:= ""
	Local cFilTot		:= ""
	Local cFilAgr		:= " AND 0 = 1 "
	Local _x			:= 0
	Local nSldQtdTra	:= 0
	Local cSldMensag	:= ""
	Local lAvulsoOK		:= .T.

	// Verifico filtro do produto:
	If !lTotal .And. !lSldEfet
		// Vazio:
		If Empty(cSldPro)
			Return(.T.)
		EndIf
		oSaSldSt:nClrPane 	:= 16777215
		oSaSldSt:nClrText	:= CLR_GRAY
	EndIf

	// Valido campos:
	If Empty(cSldGa)
		cSldSta	:= "POR GENTILEZA, INFORME O CÓDIGO GAIOLA..."
		oSaSldSt:nClrPane := 16777215
		oSaSldSt:nClrText := CLR_HRED
		oSldGa:SetFocus()
		Return(.T.)
	EndIf
	If Empty(cSldCa)
		cSldSta	:= "POR GENTILEZA, INFORME A CAIXA/ENDEREÇO..."
		oSaSldSt:nClrPane := 16777215
		oSaSldSt:nClrText := CLR_HRED
		oSaSldSt:SetFocus()
		Return(.T.)
	Else
		// Verifico se o endereço existe:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 BE_LOCALIZ FROM SBE010 (NOLOCK) WHERE BE_FILIAL = '01' AND BE_LOCALIZ = '"+cSldCa+"' AND BE_TIPODES = 'CAIXA' AND SBE010.D_E_L_E_T_ = '' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If TT1120->(Eof())
			B1120Alert()
			cSldSta	:= "A CAIXA/ENDEREÇO INFORMADO NÃO EXISTE!"
			oSaSldSt:nClrPane := 16777215
			oSaSldSt:nClrText := CLR_HRED
			oSaSldSt:SetFocus()
			Return(.T.)
		EndIf
	EndIf

	// Mensagem de confirmação quando clicado no OK:
	If lSldEfet
		cFilAgr	:= " AND ZDU010.R_E_C_N_O_ IN ("
		For _x := 1 To Len(aColsGai)
			If aColsGai[_x][1] == oAmarelo
				cFilAgr		+= "'"+AllTrim(Str(aColsGai[_x][9]))+"', "
				nSldQtdTra	+= aColsGai[_x][8]
			EndIf
		Next _x
		cFilAgr	+= "'-1') "

		// Não existe item marcado para transferência:
		If nSldQtdTra <= 0
			Return(.T.)
		EndIf

		// Verifico se existe apenas um cliente e um produto, nesse caso eu altero a mensagem:
		cSldMensag	:= "Confirma a transferência de "+AllTrim(Str(nSldQtdTra))+" peça(s) da "+AllTrim(cSldGa)+" para "+AllTrim(cSldCa)+"?"
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 ISNULL(MIN(B1_DESC), '') AS DESC_PROD, ISNULL(MAX(A1_NREDUZ), '') AS DESC_CLI, "
		cQuery += "COUNT(DISTINCT ZDU_PRODUT) AS QTD_PROD, COUNT(DISTINCT ZDU_CLI) AS QTD_CLI "
		cQuery += "FROM ZDU010 (NOLOCK) "
		cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
		cQuery += "LEFT  JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = ZDU_CLI AND A1_LOJA = ZDU_LOJA AND SA1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZDU_FILIAL = '' "
		cQuery += "AND ZDU_LOCFIS = 'CD' "
		cQuery += "AND ZDU_CODGA = '"+cSldGa+"' "
		cQuery += cFilAgr
		cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
		cQuery 	:= ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			// Altero mensagem:
			If TT1120->QTD_PROD <= 1 .And. TT1120->QTD_CLI <= 1 .And. !Empty(TT1120->DESC_PROD) .And. !Empty(TT1120->DESC_CLI)
				cSldMensag	:= "Confirma a transferência de "+AllTrim(Str(nSldQtdTra))+" peça(s) do produto "+AllTrim(TT1120->DESC_PROD)+" do cliente "+AllTrim(TT1120->DESC_CLI)+" da "+AllTrim(cSldGa)+" para "+AllTrim(cSldCa)+"?"
			EndIf
		EndIf

		// Mensagem de confirmação conforme solicitado no chamado #78049:
		If !MsgBox(cSldMensag, "Transferir", "YESNO")
			Return(.T.)
		EndIf
	EndIf

	// Verifico se o código de barras existe:
	If !lTotal .And. !lSldEfet
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 B1_CODBAR FROM SB1010 (NOLOCK) WHERE B1_FILIAL = '' AND B1_CODBAR = '"+cSldPro+"' AND SB1010.D_E_L_E_T_ = '' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If TT1120->(Eof())
			B1120Alert()
			cSldSta	:= "O CÓDIGO DE BARRAS É INVÁLIDO!"
			oSaSldSt:nClrPane := 16777215
			oSaSldSt:nClrText := CLR_HRED
			oSldPr:SetFocus()
			Return(.T.)
		Else
			// Se for parcial, seto filtro para transferir somente aquele item:
			cFilProd	:= "AND B1_CODBAR = '"+cSldPro+"' "
			cFilTot		:= "TOP 1"
		EndIf
	EndIf

	// Verifico se localizou o item e seto para agrupamento e lançamento posterior:
	If !lTotal .And. !lSldEfet
		For _x := 1 To Len(aColsGai)
			lAvulsoOK	:= IIF((lCheckAvul 	.And. aColsGai[_x][8] == 1), 	.T., .F.)			// Se o avulso tiver marcado somente é permitido múltiplos de x1
			lAvulsoOK	:= IIF((!lCheckAvul	.And. aColsGai[_x][8] > 1), 	.T., lAvulsoOK)		// Se o avulso tiver desmarcado somente é permitido múltiplos de x1

			If AllTrim(aColsGai[_x][6]) == AllTrim(cSldPro) .And. aColsGai[_x][1] == oVerde .And. lAvulsoOK
				lSldEfet := .F.
				aColsGai[_x][1]	:= oAmarelo
				oLstGaiola:SetArray(aColsGai, .F.)
				oLstGaiola:ForceRefresh()

				cSldSta	:= "ITEM MARCADO PARA TRANSFERÊNCIA, CLIQUE EM OK PARA EFETIVAR..."
				oSaSldSt:nClrPane := 16777215
				oSaSldSt:nClrText := CLR_MAGENTA

				nQtdGai		-= aColsGai[_x][8]
				nQtdGai		:= IIF(nQtdGai < 0, 0, nQtdGai)
				cSldTot 	:= "TOTAL SALDO: " + AllTrim(Str(nQtdGai))

				cSldPro	:= Space(TamSx3('B1_CODBAR')[1])
				oSldPr:SetFocus()
				Return(.T.)
			EndIf
		Next _x

		// Caso chegou aqui e não localizou nada:
		B1120Alert()
		cSldSta	:= "PRODUTO NÃO LOCALIZADO PARA REALIZAR A TRANSFERÊNCIA!"
		oSaSldSt:nClrPane := 16777215
		oSaSldSt:nClrText := CLR_HRED
		oSldPr:SetFocus()
		Return(.T.)
	EndIf

	// Verifico se existe saldo disponível para efetuar transferência:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery	:= "SELECT "+cFilTot+" ZDU010.R_E_C_N_O_ AS ZDURECNO, C6_NUM, C6_ITEM, ZDU_PRODUT, ZDU_MULTIP, ZDU_CLI, ZDU_LOJA, ZDU_LOCAL, ZDU_CLIGRU  "
	cQuery	+= "FROM ZDU010 (NOLOCK)  "
	cQuery	+= "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	//cQuery	+= "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
	cQuery	+= "INNER JOIN SC6010 (NOLOCK) ON C6_FILIAL = '01' AND C6_NUM IN (ZDU_PEDIDO, '"+cC5_Num+"') AND C6_PRODUTO = ZDU_PRODUT AND C6_QTDVEN > 0 AND SC6010.D_E_L_E_T_ = '' "
	cQuery	+= "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1010.D_E_L_E_T_ = '' "
	cQuery	+= "WHERE ZDU_FILIAL = ''  "
	cQuery	+= "AND ZDU_CODGA = '"+cSldGa+"' "
	cQuery	+= cFilProd
	cQuery	+= "AND ZDU_LOCFIS = 'CD' "
	// Verifico se o usuário deseja transferir os itens de um cliente específico:
	if !Empty(cSldCliPed)
		cQuery += "AND (A1_NOME LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR A1_NREDUZ LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR ZDU_CLI LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR ZDU_PEDIDO LIKE '%"+AllTrim(Upper(cSldCliPed))+"%') "
	EndIf
	cQuery	+= cFilAgr
	cQuery	+= "AND ZDU010.D_E_L_E_T_ = '' "
	cQuery	+= "ORDER BY ZDURECNO ASC "
	cQuery 	:= ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		lAltSld	:= .T.
		lVldPr	:= .T.

		// Corrigir para inserir múltiplos:
		While !TT1120->(Eof())
			// Certifico que o registro realmente não existe:
			If (Select("TT1120A") <> 0)
				DbSelectArea("TT1120A")
				DbCloseArea()
			Endif
			cQuery	:= "SELECT TOP 1 ZDY_ORIG FROM ZDY010 (NOLOCK) WHERE ZDY_FILIAL = '' AND ZDY_ORIG = 'ZDU_"+AllTrim(Str(TT1120->ZDURECNO))+"' AND ZDY010.D_E_L_E_T_ = '' "
			cQuery 	:= ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1120A"
			If TT1120A->(Eof())
				// Efetuo inclusão na ZDY:
				MsUnlockAll()
				RecLock("ZDY",.T.)
				ZDY->ZDY_CODCXA	:= AllTrim(Upper(cSldCa))
				ZDY->ZDY_ORIG	:= 'ZDU_'+AllTrim(Str(TT1120->ZDURECNO))
				ZDY->ZDY_PEDORI	:= AllTrim(TT1120->C6_NUM)
				ZDY->ZDY_ITEORI	:= AllTrim(TT1120->C6_ITEM)
				ZDY->ZDY_PRODUT	:= AllTrim(TT1120->ZDU_PRODUT)
				ZDY->ZDY_MULTIP	:= TT1120->ZDU_MULTIP
				ZDY->ZDY_DTGER	:= MsDate()
				ZDY->ZDY_HRGER	:= Time()
				ZDY->ZDY_USGER	:= Upper(AllTrim(cUserName))
				ZDY->ZDY_ENDERE	:= AllTrim(Upper(cSldCa))
				ZDY->ZDY_LOCFIS	:= 'CD'
				ZDY->ZDY_CLI	:= AllTrim(TT1120->ZDU_CLI)
				ZDY->ZDY_LOJA	:= AllTrim(TT1120->ZDU_LOJA)
				ZDY->ZDY_LOCAL	:= AllTrim(TT1120->ZDU_LOCAL)
				ZDY->ZDY_CLIGRU	:= AllTrim(TT1120->ZDU_CLIGRU)
				MsUnLock("ZDY")
				MsUnlockAll()
			EndIf

			// Efetuo baixa na ZDU:
			TcSQLExec("UPDATE ZDU010 SET ZDU_LOCFIS = 'XX', ZDU_PALLET = '"+AllTrim(Upper(cSldCa))+"', ZDU_STATUS = 'TRANSFERIDO PARA SALDO' WHERE R_E_C_N_O_ = "+AllTrim(Str(TT1120->ZDURECNO)))

			// Alimento variável para incluir no histórico do pedido posterior:
			cPedSldH := AllTrim(TT1120->C6_NUM)
			cEndSldH := AllTrim(Upper(cSldCa))

			TT1120->(dbSkip())
		EndDo

		// Atualizo tela:
		SldBuscaTr()

		// Limpo e atualizo tela:
		cSldSta	:= "OK, TRANSFERÊNCIA EFETUADA COM SUCESSO!"
		oSaSldSt:nClrPane := 16777215
		oSaSldSt:nClrText := CLR_GREEN

		// Limpo campo:
		cSldPro	:= Space(TamSx3('B1_CODBAR')[1])
		oSldPr:SetFocus()
		Return(.T.)
	Else
		B1120Alert()
		cSldSta	:= "NÃO EXISTE SALDO EM GAIOLA DISPONÍVEL! GENTILEZA SOLICITAR NOVA OP PARA O ITEM ["+AllTrim(cSldPro)+"] GAIOLA ["+AllTrim(cSldGa)+"]..."
		oSaSldSt:nClrPane := 16777215
		oSaSldSt:nClrText := CLR_HRED
		oSldPr:SetFocus()
		Return(.T.)
	EndIf
Return (lVldPr)

// Rotina para transferir todo o saldo da gaiola para a caixa:
Static Function SldTotal()

	// Confirmação para usuário:
	IF MsgBox("Deseja transferir todos os produtos dessa gaiola para saldo?", "Transferir", "YESNO")
		MsAguarde({|| InsSaldo(.T.) }, "Saldos", "Transferindo saldo total...")
	EndIf

Return

// Rotina para permitir estornar transferência de saldo:
Static Function EstSaldo()
	Local nRecZDU := 0

	// Busco linha selecionada:
	If oLstGaiola:nAt <= 0
		// Caso não esteja selecionado nada:
		MsgAlert("Por gentileza selecione um item da gaiola para efetuar o estorno...", "Estorno")
		Return
	Else
		// Verifico se o item pode ser estornado:
		If aColsGai[oLstGaiola:nAt][aScan(aCabeGai,{|x| Alltrim(x[2]) == "IMG"})] != oVermelho
			MsgAlert("Esse item não poderá ser estornado...", "Estorno")
			Return
		EndIf

		// Busco aqui o recno do registro:
		nRecZDU	:= aColsGai[oLstGaiola:nAt][aScan(aCabeGai,{|x| Alltrim(x[2]) == "RECNO"})]

		// Verifico se o registro pode ser estornado:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery 	:= ChangeQuery("SELECT TOP 1 ZDU_DCVINS, ZDU_DCVINE FROM ZDU010 (NOLOCK) WHERE R_E_C_N_O_ = '"+AllTrim(Str(nRecZDU))+"' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			// Verifico se existe movimentação de saída:
			If !Empty(TT1120->ZDU_DCVINS)
				B1120Alert()
				MsgStop("Esse item não poderá ser estornado, pois possui movimentação de saída ["+AllTrim(TT1120->ZDU_DCVINS)+"]")
				Return
			EndIf
			// Verifico se existe movimentação de entrada:
			If !Empty(TT1120->ZDU_DCVINE)
				B1120Alert()
				MsgStop("Esse item não poderá ser estornado, pois possui movimentação de entrada ["+AllTrim(TT1120->ZDU_DCVINE)+"]")
				Return
			EndIf
		EndIf

		IF MsgBox("Deseja efetuar o estorno da movimentação ["+AllTrim(Str(nRecZDU))+"] de saldo?", "Estornar", "YESNO")
			lAltSld	:= .T.
			// Efetuo exclusão na ZDU:
			TcSQLExec("UPDATE ZDU010 SET ZDU_LOCFIS = 'CD', ZDU_STATUS = 'ENDERECADO', ZDU_PALLET = '' WHERE R_E_C_N_O_ = "+AllTrim(Str(nRecZDU)))
			// Efetuo atualização na ZDY:
			TcSQLExec("UPDATE ZDY010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZDY_FILIAL = '' AND LTRIM(RTRIM(ZDY_ORIG)) = 'ZDU_"+AllTrim(Str(nRecZDU))+"' AND ZDY010.D_E_L_E_T_ = '' ")
			// Atualizo a tela:
			SldBuscaTr()
		EndIf
	EndIf

Return

// Rotina para buscar as informações dentro da gaiola:
Static Function SldBuscaTr()
	Local lLibera 	:= .F.
	//Local cValCam	:= &(ReadVar())

	// Cancelar:
	If lSldCanc
		Return(.T.)
	EndIf

	// Vazio eu ignoro:
	//If Empty(cValCam)
	//	Return(.T.)
	//EndIf
	oSaSldSt:nClrPane 	:= 16777215
	oSaSldSt:nClrText	:= CLR_GRAY

	// Inicialmente desativo o código do produto:
	oSldPr:Disable()

	// Inicialmente verifico campos que devem ser preenchidos:
	If Empty(cSldGa)
		cSldSta	:= "POR GENTILEZA, INFORME O CÓDIGO GAIOLA..."
		oSldGa:SetFocus()
		Return(.T.)
	EndIf
	If Empty(cSldCa)
		cSldSta	:= "POR GENTILEZA, INFORME O CÓDIGO DA CAIXA/ENDEREÇO..."
		oSldCx:SetFocus()
		Return(.T.)
	EndIf

	// Posso efetuar carregamento das informações:
	MsAguarde({|| lLibera := SldGaiola() }, "Gaiola", "Verificando gaiola...")

	// E posiciono o cursor no produto:
	If lLibera
		cSldSta	:= "INFORME O CÓDIGO DO PRODUTO"
		cSldPro	:= Space(TamSx3('B1_CODBAR')[1])
		oSldPr:Enable()
		oSldPr:SetFocus()
	EndIf

Return (.T.)

// Rotina para preencher a acols da gaiola:
Static Function SldGaiola()
	Local lExiste 	:= .F.
	Local oStatus

	// Zero acols inicialmente:
	aColsGai 	:= {}
	nQtdGai		:= 0

	// Verifico itens dentro da gaiola para ser efetuado transferência do saldo:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT DISTINCT ZDU_NUMOP, ZDU_PEDIDO, A1_NOME, ZDU_ITEMGA, B1_CODBAR, B1_DESC, ZDU_MULTIP, ZDU_DCVINS, ZDU_LOCFIS, ZDU010.R_E_C_N_O_ AS RECNOZDU "
	cQuery += "FROM ZDU010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZDU_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	//cQuery += "LEFT  JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = ZDU_PEDIDO AND SC5010.D_E_L_E_T_ = '' "
	cQuery += "LEFT JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND C5_CLIENT = A1_COD AND A1_LOJA =  C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDU_FILIAL = '' "
	cQuery += "AND ZDU_CODGA = '"+cSldGa+"' "
	cQuery += "AND (ZDU_LOCFIS = 'CD' OR (ZDU_LOCFIS = 'XX' AND ZDU_DCVINS = '')) "
	cQuery += "AND ZDU_PEDCXA = '' "
	cQuery += "AND ZDU_ENDERE <> '' "
	// Verifico se o usuário deseja transferir os itens de um cliente específico:
	if !Empty(cSldCliPed)
		cQuery += "AND (A1_NOME LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR A1_NREDUZ LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR ZDU_CLI LIKE '%"+AllTrim(Upper(cSldCliPed))+"%' OR ZDU_PEDIDO LIKE '%"+AllTrim(Upper(cSldCliPed))+"%') "
	EndIf
	cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
	cQuery += "ORDER BY ZDU_LOCFIS ASC, ZDU_DCVINS ASC, ZDU_PEDIDO, ZDU_NUMOP ASC, ZDU_ITEMGA ASC "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		While !TT1120->(Eof())
			// Verifico o que está disponível para transferência:
			oStatus := IIF(Empty(TT1120->ZDU_DCVINS) .And. AllTrim(TT1120->ZDU_LOCFIS) == 'XX', oVermelho, oVerde)
			// Adiciono na aCols da GetDados:
			Aadd(aColsGai, {oStatus, AllTrim(TT1120->ZDU_NUMOP), AllTrim(TT1120->ZDU_PEDIDO), AllTrim(TT1120->A1_NOME), AllTrim(TT1120->ZDU_ITEMGA), AllTrim(TT1120->B1_CODBAR), AllTrim(TT1120->B1_DESC), TT1120->ZDU_MULTIP, TT1120->RECNOZDU, .F.})
			// Conto apenas os disponíveis para transferência:
			nQtdGai	+= IIF(oStatus == oVerde, TT1120->ZDU_MULTIP, 0)
			TT1120->(dbSkip())
		EndDo
	EndIf

	// Atualizo componente:
	cSldTot := "TOTAL SALDO: " + AllTrim(Str(nQtdGai))
	oLstGaiola:SetArray(aColsGai, .F.)
	oLstGaiola:ForceRefresh()

	// Verifico se efetuo liberação do campo para o usuário poder prosseguir:
	If nQtdGai > 0
		lExiste := .T.
	Else
		cSldSta	:= "NÃO EXISTEM MAIS ITENS PARA TRANSFERIR DESSA GAIOLA!"
		oSaSldSt:nClrPane 	:= 16777215
		oSaSldSt:nClrText	:= CLR_GRAY
	EndIf

Return (lExiste)

// Rotina para verificar se existe algum pallet parcial daquele item para dar continuidade:
Static Function VerPallPar(cC5_NUM, cC6_PRODUTO, cPallet)

	Local oFBtnPall		:= TFont():New("Tahoma",,012,,.F.,,,,,.F.,.F.)
	Local oFPall		:= TFont():New("Tahoma",,050,,.T.,,,,,.F.,.F.)
	Local oFTitPall		:= TFont():New("Tahoma",,030,,.T.,,,,,.F.,.F.)
	Local oFTitProd		:= TFont():New("Tahoma",,020,,.F.,,,,,.F.,.F.)
	Local oBtnOKPall
	Local cPallPar		:= Space(TamSx3('ZZ5_PEDIDO')[1] + TamSx3('ZZ5_PALLET')[1])
	Local cPallExi		:= ""

	Private oGPallPar
	Private oDlgPall

	// Verifico se o parâmetro está habilitado:
	If !GetMv("BD_1120PAR")
		Return (.T.)
	EndIf

	// Verifico parâmetros:
	If Empty(cC5_NUM) .Or. Empty(cC6_PRODUTO) .Or. Empty(cPallet)
		Return (.T.)
	EndIf

	// Primeiramente verifico se o pallet atual já é parcial:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	// Verifico se existe algum pallet parcial em aberto daquele item, para continuar o encaixotamento a partir dele:
	cQuery := "SELECT TOP 1 ZZ5_PEDIDO "
	cQuery += "FROM ZZ5010 (NOLOCK) "
	cQuery += "WHERE ZZ5_FILIAL = '01' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_PRODUT = '"+cC6_PRODUTO+"' "
	cQuery += "AND ZZ5_PALLET = '"+cPallet+"' "
	cQuery += "AND ZZ5_PAPALL = 'P' "
	cQuery += "AND ZZ5010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		// Caso o pallet atual já seja parcial, eu saio da rotina:
		Return (.T.)
	EndIf

	// Verifico se existe algum pallet parcial em aberto daquele item, para continuar o encaixotamento a partir dele:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZZ5_PEDIDO, ZZ5_PALLET, ZBM_ENDERE, B1_CODBAR, B1_DESC "
	cQuery += "FROM ZZ5010 (NOLOCK) "
	cQuery += "INNER JOIN ZBM010 (NOLOCK) ON ZBM_FILIAL = '' AND ZBM_PALLET = (ZZ5_PEDIDO+ZZ5_PALLET) AND ZBM_QTDTOT > 0 AND ZBM010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SBE010 (NOLOCK) ON BE_FILIAL = '01' AND BE_LOCALIZ = ZBM_ENDERE AND BE_TIPODES IN ('ENDERECAR', 'ACONDICIONAR') AND SBE010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZZ5_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZZ5_FILIAL = '01' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_PRODUT = '"+cC6_PRODUTO+"' "
	cQuery += "AND ZZ5_DOC = '' "
	cQuery += "AND ZZ5_PAPALL = 'P' "
	cQuery += "AND ZBM_ENDERE <> '' "
	cQuery += "AND ZZ5_PALLET <> '"+cPallet+"' "
	cQuery += "AND ZZ5_PALLET <> '' "
	cQuery += "AND ZZ5010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		// Pergunto para o usuário se o mesmo deseja efetuar a continuação do pallet parcial:
		If !MsgBox("O sistema identificou o um pallet parcial em aberto ["+AllTrim(TT1120->ZZ5_PALLET)+"]. Deseja continuar o encaixotamento a partir dele?", "Pallet Parcial", "YESNO")
			Return (.T.)
		EndIf

		oDlgPall 	:= TDialog():New(0,0,0,0,"Continuar Pallet",,,,,,,,oDlg,.T.,,,,410,300,.F.)

		// Solicito bipagem do pallet para continuar o encaixotamento:
		cPallExi 	:= AllTrim(TT1120->ZZ5_PEDIDO)+AllTrim(TT1120->ZZ5_PALLET)

		// Caso o pallet exigido seja o mesmo do último bipado, já trago o mesmo preenchido:
		cPallPar	:= IIF(AllTrim(cPallExi) == AllTrim(cPallBuff), AllTrim(cPallBuff), cPallPar)

		oDlgPall:SetColor(0, 16777215)
		oDlgPall:lCentered := .T.
		oDlgPall:lEscClose := .F.
		oDlgPall:nStyle:=128

		@ 010, 005 SAY oPalPar PROMPT "Pallet: "+cPallExi+"" SIZE 200, 050 OF oDlgPall FONT oFTitPall COLORS CLR_GREEN PIXEL
		@ 030, 005 SAY oEndPar PROMPT "Endereço: "+AllTrim(TT1120->ZBM_ENDERE)+"" SIZE 200, 050 OF oDlgPall FONT oFTitPall COLORS CLR_BLUE PIXEL
		@ 050, 005 SAY oProPar PROMPT AllTrim(TT1120->B1_DESC)+" ["+AllTrim(TT1120->B1_CODBAR)+"]" SIZE 200, 050 OF oDlgPall FONT oFTitProd COLORS CLR_MAGENTA PIXEL

		@ 075, 005 SAY oTitPar PROMPT "Por gentileza, informe o pallet:" SIZE 200, 050 OF oDlgPall COLORS CLR_BLACK PIXEL
		@ 085, 005 MSGET oGPallPar VAR cPallPar SIZE 195, 035 OF oDlgPall PIXEL FONT oFPall PIXEL VALID ValPalParc(cPallExi, cPallPar)
		@ 130, 135 BUTTON oBtnOKPall PROMPT "OK" SIZE 030, 015 OF oDlgPall FONT oFBtnPall PIXEL Action ValPalParc(cPallExi, cPallPar)
		If !Empty(cPallet)
			@ 130, 170 BUTTON oBtnCaPall PROMPT "Cancelar" SIZE 030, 015 OF oDlgPall FONT oFBtnPall PIXEL Action oDlgPall:End()
		EndIf
		oGPallPar:SetFocus()

		// É obrigatório efetuar o cadastramento da estação
		oDlgPall:Activate(,,,.T.,,,)
	EndIf
Return (.T.)
// Efetua validação do pallet exigido:
Static Function ValPalParc(cPallExi, cPallPar)

	If Empty(cPallPar)
		Return(.T.)
	EndIf

	// Caso o código seja igual, ou em branco, eu aceito como verdadeiro:
	If (AllTrim(cPallExi) == AllTrim(cPallPar) .And. !Empty(cPallPar) .And. !Empty(cPallExi))
		// Caso verdadeiro, eu atualizo o código do pallet:
		cPallBuff	:= cPallPar
		cPallet		:= Right(Upper(AllTrim(cPallPar)), 4)
		lPallet 	:= .T.
		cSayPall	:= "Número do Pallet - "+cPallet

		// Também marco o pallet como não impresso:
		TCSQLEXEC("UPDATE ZZ5010 SET ZZ5_IMPALL = 'N' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+AllTrim(cPallet)+"' AND ZZ5010.D_E_L_E_T_ = '' ")

		VerEndEst(cC5_Num+AllTrim(cPallet))

		oDlgPall:End()
		If ValType(oSPallet) == "O"
			oSPallet:Refresh()
		EndIf
	Else
		// Caso negativo, erro de pallet:
		B1120Alert()
		MsgStop("Pallet ["+AllTrim(cPallPar)+"] inválido! O pallet solicitado é: "+AllTrim(cPallExi) + ". Gentileza verificar...")
		oDlgPall:SetFocus()
		oGPallPar:SetFocus()
		oDlgPall:Refresh()
		oGPallPar:Refresh()
	EndIf

Return (.T.)

// Rotina para efetuar saída do sistema através do CD:
Static Function SairCD()

	lSairCD := .T.
	oDlgCD:End()

	// Fecho também formulário ativo:
	If ValType(oDlg) != NIL
		oDlg:End()
	EndIf

Return

// Função para realizar o vínculo da etiqueta RFID do pallet através do código de barras:
Static Function VinRFID(cAcao, cPedPallet, cRFID)

	Local lRetRF	:= !lRFObri

	Local oFBtnVin	:= TFont():New("Tahoma",,012,,.F.,,,,,.F.,.F.)
	Local oFRFIDVin	:= TFont():New("Tahoma",,030,,.T.,,,,,.F.,.F.)
	Local oBtnOKVin
	Local cCDRFID	:= Space(TamSx3('ZC7_RFID')[1])
	Local cRetRFID	:= ""

	// Criação da tela de solicitação do vínculo:
	if cAcao == 'SOLICITA'
		oDlgRFID 	:= TDialog():New(0,0,0,0,"Vincular etiqueta RFID",,,,,,,,oDlgCD,.T.,,,,410,200,.F.)

		// Formulário de vinculação do endereço com a estação:
		oDlgRFID:SetColor(0, 16777215)
		oDlgRFID:lCentered 		:= .T.
		oDlgRFID:lEscClose 		:= .F.

		@ 005, 005 GROUP oGrLib TO 070, 200 PROMPT "Pallet ["+AllTrim(cPedPallet)+"]" OF oDlgRFID COLOR 0, 16777215 PIXEL
		@ 015, 010 SAY oTitLib PROMPT "Por gentileza, informe o código RFID a ser vinculado:" SIZE 200, 050 OF oDlgRFID COLORS CLR_BLACK PIXEL
		@ 025, 010 MSGET oCDVin VAR cCDRFID SIZE 185, 035 OF PIXEL FONT oFRFIDVin PIXEL
		@ 075, 170 BUTTON oBtnOKVin PROMPT "OK" SIZE 030, 015 OF oDlgRFID FONT oFBtnVin PIXEL Action MsAguarde({|| lRetRF := VinRFID("VINCULA", cPedPallet, cCDRFID) }, "Aguarde", "Verificando código...")

		oDlgRFID:Activate(,,,.T.,,,)
	EndIf

	// Executa o vínculo da etiqueta pallet:
	if cAcao == 'VINCULA'
		// Comando para fechar a janela sem efetuar o vínculo:
		If !Empty(GetMv("BD_1120RFX")) .And. AllTrim(cRFID) == AllTrim(GetMv("BD_1120RFX")) // CANCELAR@25RF
			oDlgRFID:End()
			Return (.T.)
		EndIf

		cRetRFID := BuscaWS("&a=vinrfid", "&c_matricula="+AllTrim(cZZ5_2ACOND)+"&c_codigo="+AllTrim(cPedPallet)+"&c_rfid="+AllTrim(cRFID))
		oDlgRFID:End()

		// Verifico retorno do RFID:
		cRetRFID	:= AllTrim(cRetRFID)
		If Left(cRetRFID, 2) != "OK"
			cRetRFID := IIF(cRetRFID == "", "Erro desconhecido ao efetuar o vínculo da etiqueta RFID. Gentileza tentar novamente e caso o problema persista entre em contato com o suporte...", cRetRFID)
			MsgStop(cRetRFID, "Erro")
			lRetRF	:= .F.
		Else
			lRetRF	:= .T.
		EndIf
	EndIF

Return (lRetRF)

// Função para verificar o leitor RFID:
Static Function LerRFID()

	Local cCamRFID		:= AllTrim(GetMv("BD_1120RF"))
	Local lRet			:= .F.
	Local cCodRFID		:= ''
	Local cRetRFID		:= ''

	/*
	// Verifico se é necessário efetuar o vínculo da etiqueta do pallet RFID:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT TOP 1 ZDX_VIRFID FROM ZDX010 (NOLOCK) WHERE ZDX_FILIAL = '' AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' AND ZDX_VIRFID = 'LEI' AND ZDX010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		lRet := VinRFID("SOLICITA", AllTrim(cC5_Num)+AllTrim(cPallet), "")
		Return (lRet)
	EndIf
	*/
	// Alterado para efetuar a solicitação do vínculo RFID para todas as estações:
	If Empty(cPallet)
		Return (.T.)
	EndIf
	lRet := VinRFID("SOLICITA", AllTrim(cC5_Num)+AllTrim(cPallet), "")

Return (lRet)
// A partir daqui, o código abaixo não será mais executado pois não está sendo utilizado o leitor RFID:

// Necessário posicionar o RFID do pallet quando encaixotamento no CD:
if lCDBudd .And. !Empty(cCamRFID) .And. !Empty(cPallet)
	// Verifico se o caminho do executável existe:
	If File(cCamRFID + ".exe")
		// Excluo o arquivo temporario de leitura caso exista:
		If File(cCamRFID + ".tmp")
			FErase(cCamRFID + ".tmp")
		EndIf
		// Executo executável que faz a leitura serial com a antena:
		WaitRun(cCamRFID + ".exe" + " /FECHAR", 10)
		// Verifico arquivo gerado:
		If File(cCamRFID + ".tmp")
			// Verifico conteúdo do arquivo:
			If FT_FUse(cCamRFID + ".tmp") == -1
				MsgStop("Ocorreu um erro ao efetuar a leitura do código. Código do erro: [3]")
			Else
				While !FT_FEOF()
					cCodRFID	:= FT_FReadLn()
					FT_FSKIP()
				End
				FT_FUSE()
			EndIF
			// Tudo OK, retorno positivo:
			If !Empty(cCodRFID)
				// Depois de efetuar a leitura do código, efetuo o vínculo do código RFID no sistema via WS:
				cRetRFID := BuscaWS("&a=vinrfid", "&c_matricula="+AllTrim(cZZ5_2ACOND)+"&c_codigo="+AllTrim(cC5_Num)+AllTrim(cPallet)+"&c_rfid="+AllTrim(cCodRFID))
				// Verifico retorno do RFID:
				If Left(cRetRFID, 2) != "OK"
					MsgStop("Código do erro: [5]. " + cRetRFID, "Erro!")
					lRet	:= .F.
				Else
					lRet	:= .T.
				EndIf
			Else
				MsgStop("Código RFID inválido. Código do erro: [4]")
			EndIf
		Else
			// Caso o o arquivo não foi gerado:
			MsgStop("Ocorreu um erro ao efetuar a leitura do código. Código do erro: [1]")
		EndIf
	Else
		// Verifico obrigatoriedade de se utilizar o leitor dependendo da estação:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 ZDX_VIRFID FROM ZDX010 (NOLOCK) WHERE ZDX_FILIAL = '' AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' AND ZDX_VIRFID <> 'SIM' AND ZDX010.D_E_L_E_T_ = '' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			// Caso a obrigatoriedade não esteja cadastrada como, eu retorno OK para não necessitar leitura:
			lRet	:= .T.
		Else
			// Se o programa não está instalado, porém a ZDX está com obrigatoriedade de se vincular o RFID, retorno erro:
			MsgStop("Atenção! O RFID não está configurado corretamente nessa estação ["+cCamRFID+"]. Gentileza entrar em contato com o suporte! Código do erro: [2]")
		EndIf
	EndIf
Else
	lRet	:= .T.
EndIf

Return (lRet)

// Função para vincular o apontamento da etiqueta as origens do CD:
Static Function VinculaCD()

	Local lRetVin	:= .F.
	Local nStErro	:= 0
	//Local cPallPar	:= "0000"

	If cTipoCDGr == "GAIOLA"
		// Verifico RECNO RECEBIDO:
		If Empty(nRecnoZDU) .Or. nRecnoZDU <= 0
			MsgStop("Ocorreu um erro [0] na tentativa de vincular o item à gaiola. Gentileza começar a caixa novamente ["+AllTrim(Str(nRecnoZDU))+"]!")
			B1120Limpar()
			Return (.T.)
		EndIf

		// Verifico se o registro está pronto para ser gravado:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 ZDU_LOCFIS FROM ZDU010 (NOLOCK) WHERE R_E_C_N_O_ = '"+AllTrim(Str(nRecnoZDU))+"' AND ZDU_LOCFIS = 'CD' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If TT1120->(Eof())
			MsgStop("Ocorreu um erro [1] na tentativa de vincular o item à gaiola. Gentileza começar a caixa novamente ["+AllTrim(Str(nRecnoZDU))+"]!")
			B1120Limpar()
			Return (.T.)
		EndIf

		// Efetuo atualização na ZDU e baixo o saldo
		cUpd := ""
		cUpd += "UPDATE ZDU010 SET ZDU_LOCFIS = 'XX', "
		cUpd += "				   ZDU_PEDCXA = '"+AllTrim(cC5_Num)+"', "
		cUpd += "				   ZDU_ITECXA = '"+AllTrim(cC6_Item)+"', "
		cUpd += "				   ZDU_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"', "
		cUpd += "			 	   ZDU_CAIXA = '"+AllTrim(cNumCxa)+"', "
		cUpd += "				   ZDU_DTCXA = '"+DtoS(dDataBase)+"', "
		cUpd += "				   ZDU_HRCXA = '"+Time()+"', "
		cUpd += "				   ZDU_USCXA = '"+Left(AllTrim(cZZ5_1OPERA), 20)+"', "
		cUpd += "				   ZDU_PALLET = '"+AllTrim(cC5_Num)+AllTrim(cPallet)+"', "
		cUpd += "				   ZDU_STATUS = 'ENCAIXOTADO' "
		cUpd += "WHERE R_E_C_N_O_ = '"+AllTrim(Str(nRecnoZDU))+"' "
		// Tratativa de erro do update:
		nStErro	:= TCSQLEXEC(cUpd)
		IF nStErro < 0
			MsgStop("Ocorreu um erro [2] na tentativa de vincular o item à gaiola. Gentileza começar a caixa novamente ["+TCSQLError()+"]!")
			B1120Limpar()
			Return (.T.)
		EndIf


		// Confirmo gravação de registro:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 ZDU_LOCFIS FROM ZDU010 (NOLOCK) WHERE R_E_C_N_O_ = '"+AllTrim(Str(nRecnoZDU))+"' AND ZDU_LOCFIS = 'XX' AND ZDU_PALLET = '"+AllTrim(cC5_Num)+AllTrim(cPallet)+"' ")
		TCQuery cQuery NEW ALIAS "TT1120"
		If TT1120->(Eof())
			MsgStop("Ocorreu um erro [3] na tentativa de vincular o item à gaiola. Gentileza começar a caixa novamente ["+AllTrim(Str(nRecnoZDU))+"]!")
			B1120Limpar()
			Return (.T.)
		EndIf

		// Libero RECNO:
		nRecnoZDU	:= 0
	ElseIf cTipoCDGr == "SALDO"
		// Efetuo atualização na ZDY e baixo o saldo:
		cUpd := ""
		cUpd += "UPDATE ZDY010 SET ZDY_LOCFIS = 'XX', "
		cUpd += "				   ZDY_PEDCXA = '"+AllTrim(cC5_Num)+"', "
		cUpd += "				   ZDY_ITECXA = '"+AllTrim(cC6_Item)+"', "
		cUpd += "				   ZDY_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"', "
		cUpd += "			 	   ZDY_CAIXA = '"+AllTrim(cNumCxa)+"', "
		cUpd += "				   ZDY_DTCXA = '"+DtoS(dDataBase)+"', "
		cUpd += "				   ZDY_HRCXA = '"+Time()+"', "
		cUpd += "				   ZDY_USCXA = '"+Left(AllTrim(cZZ5_1OPERA), 20)+"', "
		cUpd += "				   ZDY_PALLET = '"+AllTrim(cC5_Num)+AllTrim(cPallet)+"' "
		cUpd += "WHERE R_E_C_N_O_ = '"+AllTrim(Str(nRecnoZDY))+"' "
		// Tratativa de erro:
		nStErro	:= TCSQLEXEC(cUpd)
		IF nStErro < 0
			MsgStop("Ocorreu um erro na tentativa de vincular o item à CAIXA. Gentileza começar a caixa novamente ["+TCSQLError()+"]")
			B1120Limpar()
			Return (.T.)
		EndIf
	EndIf

	// Ao identificar mudança de item para o mesmo pallet, o sistema gera a etiqueta anterior previamente:
	If !Empty(cPallet)
		If (Select("TT1120") <> 0)
			dbSelectArea("TT1120")
			dbCloseArea()
		EndIf
		cQuery := "SELECT TOP 1 ZZ5_ITEM FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_ITEM <> '"+cC6_Item+"' AND ZZ5_PALLET = '"+cPallet+"' AND ZZ5010.D_E_L_E_T_ = '' "
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(EOF())

			// Caso exista itens divergentes para o mesmo pallet:
			B1120Alert()
			MsgBox('Identificado itens divergentes para o pallet ['+cPallet+']. Gentileza iniciar novamente essa caixa!', 'Novo pallet', 'INFO')

			// Então, primeiramete eu seto esse pallet como impresso:
			cUpd := "UPDATE ZZ5010 SET ZZ5_IMPALL = 'S' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+cPallet+"' AND ZZ5010.D_E_L_E_T_ = '' "
			nStErro	:= TCSQLEXEC(cUpd)
			IF nStErro < 0
				MsgStop("Ocorreu um erro na tentativa de efetuar o ROLLBACK na ZZ5 ["+TCSQLError()+"]!")
			EndIf

			// Preparo a tela para o operador iniciar novamente a caixa:
			B1120Limpar()

			// Busco último pallet gerado para esse pedido:
			If (Select("TT1120A") <> 0)
				dbSelectArea("TT1120A")
				dbCloseArea()
			EndIf
			cQuery := "SELECT TOP 1 ISNULL(MAX(ZZ5_PALLET), '0000') AS N_PALLET FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET <> '' AND ZZ5010.D_E_L_E_T_ = '' "
			TCQuery cQuery NEW ALIAS "TT1120A"
			If !TT1120A->(EOF())
				cPallet	 := AllTrim(TT1120A->N_PALLET)
			EndIf

			// Acrescento sequência no pallet:
			cPallet		:= Soma1(cPallet)

			// Verifico endereço para o pallet:
			If lCDBudd
				VerEndEst(cC5_Num+AllTrim(cPallet))
			EndIf

			// Ajusto variáveis do pallet para seguir:
			lPallet 	:= .T.
			cSayPall	:= "Número do Pallet - "+cPallet
			If ValType(oSPallet) == "O"
				oSPallet:Refresh()
			EndIf
		EndIf
	EndIf

	// Verifica item:
	ItemGaiola()

Return (lRetVin)

// Função para validar a ZZ5 com a ZDU+ZDY:
Static Function ValidaEtq(cC5_Num, cNumCxa, cC6_Item)

	Local lRetEtq	:= .F.
	Local nStErro	:= 0
	Local nQtdZZ5	:= 0
	Local nQtdVin	:= 0

	// Validações:
	If Empty(cC5_Num) .Or. Empty(cNumCxa) .Or. !lCDBudd .Or. cTipoCDGr == "ORDEM" .Or. Empty(cC6_Item)
		Return (.T.)
	EndIf

	// Busco quantidade encaixotada na ZZ5:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT ISNULL(SUM(ZZ5_QTDENC), 0) AS QTD_ENCX "
	cQuery += "FROM ZZ5010 (NOLOCK) "
	cQuery += "WHERE ZZ5_FILIAL = '01' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_NUMETQ = '"+cNumCxa+"' "
	cQuery += "AND ZZ5_ITEM = '"+cC6_Item+"' "
	cQuery += "AND ZZ5010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		nQtdZZ5	:= TT1120->QTD_ENCX
	EndIF

	// Busco a quantidade encaixotada na ZDU+ZDY:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	// Busco da tabela de gaiolas:
	cQuery := ""
	cQuery += "SELECT ISNULL(SUM(ZDU_MULTIP), 0) AS QTD_ENCX "
	cQuery += "FROM ZDU010 (NOLOCK) "
	cQuery += "WHERE ZDU_FILIAL = '' "
	cQuery += "AND ZDU_PEDCXA = '"+cC5_Num+"' "
	cQuery += "AND ZDU_CAIXA = '"+cNumCxa+"' "
	cQuery += "AND ZDU_ITECXA = '"+cC6_Item+"' "
	cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
	// Busco da tabela de caixa de saldos:
	cQuery += "UNION ALL "
	cQuery += "SELECT ISNULL(SUM(ZDY_MULTIP), 0) AS QTD_ENCX "
	cQuery += "FROM ZDY010 (NOLOCK) "
	cQuery += "WHERE ZDY_FILIAL = '' "
	cQuery += "AND ZDY_PEDCXA = '"+cC5_Num+"' "
	cQuery += "AND ZDY_CAIXA = '"+cNumCxa+"' "
	cQuery += "AND ZDY_ITECXA = '"+cC6_Item+"' "
	cQuery += "AND ZDY010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		While !TT1120->(Eof())
			nQtdVin	+= TT1120->QTD_ENCX
			TT1120->(dbSkip())
		EndDo
	EndIF

	// Caso seja diferente é necessário refazer a caixa:
	If nQtdVin == nQtdZZ5 .And. nQtdVin > 0 .And. nQtdZZ5 > 0
		lRetEtq	:= .T.
	Else
		lRetEtq	:= .F.

		// Mensagem de erro para o usuário:
		B1120Alert()
		MsgStop("ATENÇÃO: Infelizmente não foi possível processar a caixa ["+AllTrim(cNumCxa)+"] no sistema! Será necessário refazer a mesma...")

		// Então, primeiramete eu excluo o a caixa da ZZ5:
		cUpd := "UPDATE ZZ5010 SET D_E_L_E_T_ = '*' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_NUMETQ = '"+cNumCxa+"' AND ZZ5_ITEM = '"+cC6_Item+"' AND ZZ5010.D_E_L_E_T_ = '' "
		// Tratativa de erro do update:
		nStErro	:= TCSQLEXEC(cUpd)
		IF nStErro < 0
			MsgStop("Ocorreu um erro na tentativa de efetuar o ROLLBACK na ZZ5 ["+TCSQLError()+"]!")
		Else
			MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando vinculos de encaixotamento nas gaiolas e saldos...")
		EndIf

		// Depois, preparo a tela para o operador iniciar novamente a caixa:
		B1120Limpar()

		// Verifica item:
		ItemGaiola()

		// Retorno focus obrigatório:
		oDlg:Refresh()
		oDlg:SetFocus()
		oCodBar:SetFocus()
		oCodBar:Refresh()

		// Chamo obrigatóriamente a tela de bipagem da gaiola:
		TelaCD(.T.)
	EndIf

Return (lRetEtq)

// Função WS padrão para buscar informações do Hydra:
Static Function BuscaWS(cParamGet, cParamPost)

	Local aHeadOut 	:= {}
	Local cHeadRet 	:= ""
	Local cCaminho	:= AllTrim(GetMv("BD_1120CWS"))

	Local cRetWS	:= ""
	Local cChave	:= "hydra@987"
	// Adiciono cabeçalho:
	aadd(aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut, 'Content-Type: application/x-www-form-urlencoded')
	// Efetuo post no endereço:
	cRetWS 	:= AllTrim(HttpPost(cCaminho, ("w="+Upper(AllTrim(ComputerName()))+cParamGet), ("c="+cChave+cParamPost), GetMv("BD_1120TIM"), aHeadOut, @cHeadRet))

Return cRetWS
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FIM - Rotinas responsáveis pelo encaixotamento no CD Buddemeyer - Busca pedidos através das gaiolas endereçadas
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Busca operadores cadastrados na CB1:
Static Function B1120Oper(cOperad, cCampoDesc)
	If Empty(cOperad)
		&(cCampoDesc)	:= ''
		Return (.F.)
	EndIf

	// Verifico operador:
	cOperNome	:= Posicione("CB1", 3, xFilial("CB1")+cOperad, "CB1_NOME")
	If !Empty(cOperNome)
		&(cCampoDesc)	:= cOperNome
	Else
		MsgStop("Operador não localizado!")
		Return (.F.)
	EndIf

	// Verifico focus:
	If Empty(cC5_NUM)
		MsgStop("Por favor informe o pedido!")
		oC5_Num:SetFocus()
	ElseIf Empty(cZZ5_1ACOND)
		oZZ5_1ACOND:SetFocus()
	ElseIf Empty(cZZ5_2ACOND)
		oZZ5_2ACOND:SetFocus()
	Else
		oCodBar:SetFocus()
	EndIf
Return (.T.)

// Mostra a ordem de embalagem gerada pelo sistema de reserva:
Static Function B1120Ord()
	// Vazio:
	If Empty(cC5_Num)
		MsgStop("Por favor informe o pedido!")
		oC5_Num:SetFocus()
		Return
	EndIf

	// Chamo o pedido no Hydra:
	cChave := Str(Year(DATE()))
	cChave += StrZero(Month(DATE()), 2, 0)
	cChave += StrZero(Day(DATE()), 2, 0)
	cChave := AllTrim(Str((Val(cChave) * 23)))
	cCaminho = 'https://hydra.buddemeyer.com.br/reserva/ordem_embalagem.php?p='+AllTrim(cC5_Num)+'&c='+cChave+'&u='+AllTrim(cUserName)+'&o=PROJETO'
	ShellExecute ("Open", cCaminho, "", "C:\", 1)
Return

// Finalizar encaixotamento:
User Function B1120Fim(cPedFim)
	Local nOpcFim	:= 0
	Local cTitulo	:= ''
	Local cPergun	:= ''
	Local lIncons	:= .F.
	Local cUpdZCA	:= ''

	// Vazio:
	If Empty(cPedFim)
		oC5_Num:SetFocus()
		Return (.T.)
	EndIf

	// Verifico focus:
	If Empty(cZZ5_1ACOND)
		MsgStop("Favor informe a matrícula do operador!")
		oZZ5_1ACOND:SetFocus()
		Return (.T.)
	ElseIf Empty(cZZ5_2ACOND)
		MsgStop("Favor informe a matrícula do ajudante!")
		oZZ5_2ACOND:SetFocus()
		Return (.T.)
	EndIf

	// Mensagem para o usuário:
	cTitulo	:= "Pedido ["+AllTrim(cPedFim)+"]?"
	cPergun	:= "Deseja finalizar o encaixotamento do pedido com qual opção?"

	// Defino tipo para usuário:
	//nOpcFim	:= Aviso(cTitulo, cPergun, {"Parcial", "Total", "Cancelar"}, 2)
	nOpcFim := 1
	IF MsgBox("Deseja finalizar o pedido TOTAL?", cTitulo, "YESNO")
		nOpcFim := 2
	EndIf

	// Caso o usuário cancele, continuo o encaixotamento:
	If nOpcFim == 3
		If !lSairSem
			oCodBar:SetFocus()
			Return (.F.)
		Else
			MsgStop("Por favor, informe o tipo de finalização do pedido!")
			Return (.F.)
		EndIf
	EndIf

	// Libero flag:
	lFinalizar	:= .F.

	If nOpcFim == 1
		// Encaixotamento parcial:
		cUpdZCA	:= ", ZCA_CSTAT = 'ENVIADO PARA MAQUINA' "
		cUpdZCA	+= ", ZCA_STCORT = 'PARCIAL' "
		cUpdZCA	+= ", ZCA_DTCORT = '"+DtoS(MsDate())+"' "
		cUpdZCA	+= ", ZCA_HRCORT = '"+Substr(Time(), 1, 5)+"' "
		cUpdZCA	+= ", ZCA_USUCOR = '"+AllTrim(Upper(cUserName))+"' "
		// Histórico pedido:
		U_BUD1162(cPedFim, 'ENCAIXOTAMENTO PARCIAL')
	ElseIf nOpcFim == 2
		// Encaixotamento total:
		cUpdZCA	:= ", ZCA_CSTAT = 'RECEBIDO MAQUINA' "

		// Verifico se teve inconsistência:
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		cQuery := ""
		cQuery += "SELECT DISTINCT C9_ITEM "
		cQuery += "FROM "+RetSqlName("SC9")+" (NOLOCK) "
		cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
		cQuery += "AND C9_PEDIDO = '"+cPedFim+"' "
		cQuery += "AND C9_NFISCAL = '' "
		cQuery += "AND C9_QTDLIB <> C9_QTDENC "
		cQuery += "AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			lIncons	:= .T.
			// Com inconsistência:
			cUpdZCA	:= ", ZCA_STCORT = 'PENDENTE' "
			cUpdZCA	+= ", ZCA_STATUS = 'INCONSISTENCIA' "
			cUpdZCA	+= ", ZCA_DTCORT = '"+DtoS(MsDate())+"' "
			cUpdZCA	+= ", ZCA_HRCORT = '"+Substr(Time(), 1, 5)+"' "
			cUpdZCA	+= ", ZCA_USUCOR = '"+AllTrim(Upper(cUserName))+"' "
			// Histórico pedido:
			U_BUD1162(cPedFim, 'AGUARDANDO VERIFICACAO DE INCONS.')
		Else
			// Sem inconsistência:
			cUpdZCA	+= ", ZCA_STCORT = '' "
			cUpdZCA	+= ", ZCA_DTCORT = '' "
			cUpdZCA	+= ", ZCA_HRCORT = '' "
			cUpdZCA	+= ", ZCA_USUCOR = '' "
			// Seto permissão de faturamento:
			cUpd := ""
			cUpd += "UPDATE ZCA010 SET ZCA_STFAT = 'LIBERADO FATURAMENTO' "
			cUpd += "WHERE ZCA010.D_E_L_E_T_ = '' "
			cUpd += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"' "
			cUpd += "AND ZCA_PEDIDO = '"+cPedFim+"' "
			cUpd += "AND ZCA_STENCA LIKE '%FATURAMENTO%' "
			TCSQLEXEC(cUpd)
			// Histórico pedido:
			U_BUD1162(cPedFim, 'RECEBIDO MAQUINA')
		EndIf
	EndIf

	// Atualizo status para ZCA:
	cUpd := ""
	cUpd += "UPDATE ZCA010 SET ZCA_COPER = '"+Upper(AllTrim(cZZ5_1OPERA))+"' "
	cUpd += "				 , ZCA_DCRET = '"+DtoS(MsDate())+"' "
	cUpd += "				 , ZCA_HCRET = '"+Substr(Time(),1,5)+"' "
	cUpd += "				 , ZCA_IPCOLE = '"+Alltrim(GetClientIP())+"' "
	cUpd += cUpdZCA
	cUpd += "WHERE ZCA010.D_E_L_E_T_ = '' "
	cUpd += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cUpd += "AND ZCA_PEDIDO = '"+cPedFim+"' "
	TCSQLEXEC(cUpd)

	// Caso pedido foi encaixotado para faturar:
	cUpd := ""
	cUpd += "UPDATE ZCA010 SET ZCA_STENCA = 'RECEBIDO MAQUINA' "
	cUpd += "			 	 , ZCA_STATUS = 'APTO A FATURAR' "
	cUpd += "WHERE ZCA010.D_E_L_E_T_ = '' "
	cUpd += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cUpd += "AND ZCA_PEDIDO = '"+cPedFim+"' "
	cUpd += "AND ZCA_STENCA LIKE '%FATURAMENTO%' "
	TCSQLEXEC(cUpd)

	// Caso pedido foi encaixotado para reserva:
	cUpd := ""
	cUpd += "UPDATE ZCA010 SET ZCA_STENCA = 'RECEBIDO MAQUINA' "
	cUpd += "			 	 , ZCA_STATUS = 'RECEBIDO MAQUINA' "
	cUpd += "WHERE ZCA010.D_E_L_E_T_ = '' "
	cUpd += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cUpd += "AND ZCA_PEDIDO = '"+cPedFim+"' "
	cUpd += "AND ZCA_STENCA NOT LIKE '%FATURAMENTO%' "
	cUpd += "AND ZCA_STENCA <> 'RECEBIDO MAQUINA' "
	TCSQLEXEC(cUpd)

	// Atualizo retorno da SC9:
	cUpd := ""
	cUpd += "UPDATE " + RETSQLNAME("SC9") + " SET C9_CTRETQ = '', C9_COLETOR = '' "
	cUpd += "WHERE "+RETSQLNAME("SC9")+".D_E_L_E_T_ = '' "
	cUpd += "AND C9_FILIAL = '"+xFilial("SC9")+"' "
	cUpd += "AND C9_PEDIDO = '"+cPedFim+"' "
	cUpd += "AND C9_NFISCAL = '' "
	TCSQLEXEC(cUpd)

	// Atualizo quantidade encaixotada na SC6:
	cUpd := ""
	cUpd += "UPDATE SC6010 SET C6_QTDENCX = ISNULL((SELECT SUM(ZZ5_QTDENC) FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = C6_NUM AND ZZ5_ITEM = C6_ITEM AND ZZ5_DOC = '' AND ZZ5010.D_E_L_E_T_ = ''), 0)  "
	cUpd += "WHERE "+RETSQLNAME("SC6")+".D_E_L_E_T_ = '' "
	cUpd += "AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cUpd += "AND C6_NUM = '"+cPedFim+"' "
	TCSQLEXEC(cUpd)

	// Atualizo quantidade de volume na SC5:
	cUpd := ""
	cUpd += "UPDATE SC5010 SET C5_VOLUME1 = ISNULL((SELECT SUM(ZZ5_QTDENC) FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = C5_NUM AND ZZ5_DOC = '' AND ZZ5010.D_E_L_E_T_ = ''), 0)  "
	cUpd += "				 , C5_ESPECI1 = ISNULL((SELECT MAX(ZZ5_EPVOL)  FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = C5_NUM AND ZZ5_DOC = '' AND ZZ5010.D_E_L_E_T_ = ''), '') "
	cUpd += "WHERE "+RETSQLNAME("SC5")+".D_E_L_E_T_ = '' "
	cUpd += "AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cUpd += "AND C5_NUM = '"+cPedFim+"' "
	TCSQLEXEC(cUpd)

	// Enviar e-mail de inconsistência:
	If nOpcFim == 2
		If lLiberac
			If lIncons
				MsAguarde({|| U_B1120Inco(cPedFim) }, 'E-mail', 'Aguarde... Enviando e-mail de inconsistência...')
			Else
				MsAguarde({|| U_B1120EConc(cPedFim) }, 'E-mail', 'Aguarde... Enviando e-mail para carregamento...')
			EndIf
		EndIf
	EndIf

	// Aqui limpo a tela e o pedido:
	If !lSairSem .And. !lCDBudd
		cC5_Num		:= Space(TamSx3('C5_NUM')[1])
		cC5_CLIENTE	:= Space(TamSx3('C5_CLIENTE')[1])
		cC5_LOJACLI	:= Space(TamSx3('C5_LOJACLI')[1])
		cA1_NOME	:= Space(TamSx3('A1_NOME')[1])
		B1120Limpar()
		oC5_Num:SetFocus()
	EndIf

Return (.T.)

Static Function B1120Ped()

	Local lRet	 		:= .T.
	Local cDescTipo 	:= ' Não Cadastrado !!!'
	Local cAliasPed 	:= 'PED1120'
	Local cNArqUs		:= ""
	Local cNArqPer1		:= ""
	Local cNArqPer2		:= ""
	//Local aFile3		:= ""
	Local lMarcPallet	:= .F.
	Local cLinha := ""
	Local nPos := 0
	Local cEtiqueta := ""
	//06051982 ALTERADO PARA TRATAR ALTERAÇÃO NOME ARQUIVO;
	Private cDir		:= Alltrim("\EtiqPrjEsp\Pernambucanas\")
	Private cDirEtqM	:= Alltrim("\EtiqPrjEsp\Marisa\")
	Private aFiles		:= {}

	// Caso esteja bipando a ordem de embalagem:
	cC5_Num	:= Upper(Substr(cC5_Num, 1, 6))

	oCodBar:Disable()
	dbSelectArea("SC5")
	dbSeek(xFilial("SC5")+cC5_Num)
	cC5_PedNum:= SC5->C5_PEDCLI

	If	Empty(cC5_Num)
		Return (lRet := .T.)
	EndIf

	// Verifico se está tentando trocar de pedido:
	If lFinalizar
		if (cC5_Num != cC5_NumAnt .And. cC5_NumAnt != "")
			If lCDBudd
				U_B1120Fim(cC5_NumAnt)
			Else
				Return(U_B1120Fim(cC5_NumAnt))
			EndIf
		EndIf
	EndIF
	cC5_NumAnt	:= cC5_Num

	// Libero flag a cada alteração de pedido:
	lFinalizar	:= .F.

	SC5->(DbSeek(xFilial('SC5')+cC5_Num))
	If	!SC5->(Found())
		lRet := ExistCpo('SC5',cC5_Num)
	EndIf

	If	lRet
		// Verifico se o cliente efetua reserva ou não (pedido reserva):
		lReserva	:= .T.
		lCliente	:= .F.
		If AllTrim(SC5->C5_CLIENTE) == AllTrim(GetMv("BD_1120RES"))
			lReserva	:= .F.
			lCliente	:= .T.
		EndIf

		oFimCaixa:Disable()

		// Verifico se o pedido foi reservado através da rotina nova de reserva:
		lAbaixoM	:= .F.
		lLiberac	:= .F.
		cGPallet	:= ''
		If !Empty(SC5->C5_CODENCX)
			lReserva	:= .F.
			lLiberac	:= .T.
			cGPallet	:= SC5->C5_GPALLET

			// Verifico se o pedido aceita múltiplo abaixo da grade:
			If AllTrim(SC5->C5_PMULT) == "S"
				lAbaixoM	:= .T.
			EndIf

			// Botões para auxiliar na liberação:
			oFim:Enable()
			oOrdem:Enable()
		ElseIf !lCliente
			// Verifico se existe alguma etiqueta gerada para aquele pedido:
			If Select("ZZ5EX") <> 0
				ZZ5EX->(DbCloseArea())
			EndIf
			BeginSql Alias "ZZ5EX"
				SELECT
					ZZ5_PEDIDO
				FROM
					%Table:ZZ5%
				WHERE
					%NotDel%
					AND ZZ5_FILIAL = %xFilial:ZZ5%
					AND ZZ5_PEDIDO = %Exp:cC5_Num%
			EndSql
			If ZZ5EX->(Eof())
				// Caso não exista etiqueta gerada, não deixo reservar se o C5_CODENCX não estiver preenchido:
				MsgStop("Esse pedido não foi reservado! Gentileza verificar com o responsável pela liberação...")
				Return (lRet := .F.)
			EndIf

			oFim:Disable()
			oOrdem:Disable()
		EndIf

		// É necessário efetuar validação do cliente x encaixotamento CD:
		If !lCDBudd
			if ((AllTrim(SC5->C5_CLIENTE) $ AllTrim(GetMv("BD_1204CGA"))) .Or. Empty(GetMv("BD_1204CGA")) .Or. AllTrim(GetMv("BD_1204CGA")) == "*")
				// Verifico se existe ZDU em aberto no CD:
				If (Select("TT1120") <> 0)
					DbSelectArea("TT1120")
					DbCloseArea()
				Endif
				cQuery := ""
				cQuery += "SELECT TOP 1 ZDU_ENDERE, ZDU_CODGA "
				cQuery += "FROM ZDU010 (NOLOCK) "
				//cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
				cQuery += "WHERE ZDU_FILIAL = '' "
				cQuery += "AND ZDU_PEDIDO = '"+cC5_Num+"' "
				cQuery += "AND ZDU_LOCFIS = 'CD' "
				cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TT1120"
				If !TT1120->(Eof())
					// Liberar pedido para ser encaixotado na logística também ou não:
					B1120Alert()
					IF !MsgBox("Atenção: Esse pedido deverá ser encaixotado somente no CD pois os itens estão endereçados no local ["+AllTrim(TT1120->ZDU_ENDERE)+"] na gaiola ["+AllTrim(TT1120->ZDU_CODGA)+"]. Deseja ignorar a mensagem e encaixotar mesmo assim?", "Encaixotamento", "YESNO")
						Return (lRet := .F.)
					Else
						// Histórico de encaixotamento:
						U_BUD1162(cC5_Num, 'INICIANDO ENCAIXOTAMENTO EM LOCAL NAO INDICADO')
					EndIf
				EndIf
			EndIf
		EndIf

		If	(((SC5->C5_TIPOPED $ 'C/F/K') .OR. SC5->C5_LOCAL == '04' .Or. Empty(SC5->C5_TIPOPED)) .And. SC5->C5_LOCAL != '16' .And. lReserva)
			If Empty(SC5->C5_TIPOPED)
				MsgStop("Atenção: O tipo comercial do pedido não foi informado! Gentileza verificar com o setor comercial!")
			Else
				nAscan := Ascan( aTipPed, { |e| e[2] = SC5->C5_TIPOPED } )
				If 	nAscan > 0
					cDescTipo  := AllTrim( aTipPed[nAscan, 3] )
				Endif
				MsgStop('O pedido é do Tipo Comercial '+ SC5->C5_TIPOPED + '-' + cDescTipo + ' e não pode ser usado nesta rotina !!!')
			EndIf
			If lCDBudd
				TelaCD(.T.)
			EndIf
			Return (lRet := .F.)
		EndIf

		//////////////////////////////////////////////////////////////////// VERIFICA DE EXISTE ARQUIVOS DA PERNAMBUCANAS - JONAS - 28/08/2014

		cNArqUs3   	:= ""
		cNArqUs		:= ""
		cNArqPer1	:= cDir+"F"+ALLTRIM(SC5->C5_PEDCLI)+".TXT"
		cNArqPer2	:= cDir+"F"+PadL(ALLTRIM(SC5->C5_PEDCLI), 10, "0")+".TXT"

		// Primeiramente, efetua a tentativa com o arquivo original:
		If FILE(cNArqPer2)
			cNArqUs	:= cNArqPer2
		Else
			cNArqUs	:= cNArqPer1
		EndIf

		ADIR(cNArqUs, aFiles)
		AEVAL(aFiles, { |element| QOUT(element) })
		nCount := Len( aFiles )

		If 	SC5->C5_CLIENTE == "099834"

			IF  nCount== 0
				cARQ:=""
			ELSE
				cARQ:=Alltrim(aFiles[1])
			ENDIF
			//06051982 RETIRADO CAMINHO DA VARIÁVEL;
			cNArqUs3 := StrTran(cNArqUs, "\EtiqPrjEsp\Pernambucanas\","")
			If cNArqUs3 <> cARQ
				MSGSTOP("Não existe arquivo da Pernambucanas para este Pedido. Favor verificar com o setor ADM da Logistica.")
				finaL()
			EndIf
		EndIf

		///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		lGravPal := .T.

		SA1->(DbSeek(xFilial('SA1')+SC5->(C5_CLIENTE+C5_LOJACLI)))
		If	!(lRet := (SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ) .Or. (!SC5->C5_BLQ $ '1/2')))
			MsgAlert('Pedido já Encerrado ou Bloqueado por regra ou verba !!!')
		Else
			lFim := .T.
			lResiduo := .F.
			If	Select(cAliasPed) <> 0
				(cAliasPed)->(DbCloseArea())
			EndIf

			B1120Carga(@cAliasPed)
			While !(cAliasPed)->(Eof())

				If	((cAliasPed)->C6_QUANT > 0) .And. ((cAliasPed)->ZZ5_QTDENC < (cAliasPed)->(C6_QTDVEN-C6_QTDCANC)) //((cAliasPed)->ZZ5_QTDENC < (cAliasPed)->C6_QUANT)
					//If Empty((cAliasPed)->C6_BLQ)
					lFim := .F.
					//Else
					//lResiduo := .T.
					//MsgAlert('Há item para este Pedido que foi cancelado, favor Entrar em Contato com o Depto Comercial !!!')
					//EndIf
					Exit
				EndIf

				(cAliasPed)->(DbSkip())

			EndDo

			If	Select(cAliasPed) <> 0
				(cAliasPed)->(DbCloseArea())
			EndIf

			// Linha criada para impressao de teste da etiqueta de pallet
			//If	(cC5_num = 'NB0312') .And. ('ADMIN' $ Upper(Substr(cUsuario,7,15)))
			//	lFim := .F.
			//EndIf

			If	lFim
				// Verifico se o pedido foi finalizado realmente, ou se não foi liberado:
				If (Select("TT1120") <> 0)
					DbSelectArea("TT1120")
					DbCloseArea()
				Endif
				cQuery := ""
				cQuery += "SELECT DISTINCT TOP 1 C6_ITEM "
				cQuery += "FROM "+RetSqlName("SC6")+" (NOLOCK) "
				cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
				cQuery += "AND C6_NUM = '"+cC5_Num+"' "
				cQuery += "AND "+cColEmpDs+" > 0 "
				cQuery += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TT1120"
				If !TT1120->(Eof())
					//IF MsgBox("O pedido de vendas já foi finalizado. Deseja finalizar o encaixotamento?", "Finalizado", "YESNO")
					/*
					nAviso		:= 3
					lMsHelpAuto := .F.
					while nAviso == 3
						nAviso	:= AVISO("Atenção", "O pedido de vendas já foi finalizado. Deseja finalizar o encaixotamento?", {"Cancelar", "Confirma", "Escolha"}, 3)
					EndDo
					If nAviso == 2
						U_B1120Fim()
					End If
					*/
					// Mensagem obrigatória para o pedido:
					MsgBox('O pedido de vendas foi totalmente finalizado!', 'Êxito!', 'INFO')
					U_B1120Fim(cC5_Num)
				Else
					MsgStop("Esse pedido não foi liberado para encaixotamento ou já foi totalmente faturado! Gentileza verificar...")
				EndIf
				If lCDBudd
					TelaCD(.T.)
				EndIf
				Return (lRet := .F.)
			EndIf

			// Verifico encaixotamento CD:
			If lCDBudd
				// No caso de encaixotamento no CD, é obrigatório geração do pallet:
				cGPallet := "S"
				// Atualiza item:
				ItemGaiola()
			EndIf

			//	If 	lResiduo
			//	MsgAlert('O Produto para este Pedido foi cancelado, favor Entrar em Contato com o Depto Comercial !!!')
			//	Return (lRet := .F.)
			//EndIf

			cC5_CLIENTE 	:= SC5->C5_CLIENTE
			cC5_LOJACLI		:= SC5->C5_LOJACLI
			cA1_NOME	  	:= SA1->A1_NOME
			cA1_MUN	  		:= SA1->A1_MUN
			cA1_EST	  		:= SA1->A1_EST
			dC5_DTENT		:= SC5->C5_DTENT
			cSemaPed  		:= SC5->C5_SEMAPED
			cCDLoja			:= IIf(SA1->(FieldPos('A1_CDLOJA'))<>0,SA1->A1_CDLOJA,SA1->A1_LOJA)
			cPedCli			:= SC5->C5_PEDCLI
			oCodBar:Enable()

			// Verifica se o arquivo de configuração existe
			If (nHandle := FT_FUSE(AllTrim(cDirArq + cArqConf))) == -1
				MsgStop('Não foi encontrado o arquivo de configuração de Etiquetas, Contate o Administrador !!!')
				Final()
			Else
				// Posiciona na primeria linha
				FT_FGoTop()
				// Retorna o número de linhas do arquivo
				nLast := FT_FLastRec()
				While !FT_FEOF()
					cLinha  := FT_FReadLn()

					// Procura a linha que contém o código de cliente e o "="
					nPos := At(cC5_CLIENTE + "=", cLinha)
					If nPos > 0
						// Extrai o nome da etiqueta após o "="
						cEtiqueta := SubStr(cLinha, nPos + Len(cC5_CLIENTE) + 1)

						// Extrai somente o nome do arquivo, até o primeiro espaço vazio:
						aEtiqueta := STRTOKARR(cEtiqueta, " ")
						If Len(aEtiqueta) > 0
							cEtiqueta = aEtiqueta[1]
						EndIf

						cEtiqueta := AllTrim(cEtiqueta) // Remove espaços em branco e quebras de linha
						Exit
					EndIf

					// Pula para próxima linha
					FT_FSKIP()
				End
				// Fecha o Arquivo
				FT_FUSE()

				/*
				// Abre o arquivo para leitura
				nHandle := FOpen(AllTrim(cDirArq + cArqConf), 0)
				If nHandle >= 0
					// Obtém o tamanho do arquivo

					cFile := FWFileReader():New(AllTrim(cDirArq + cArqConf))
					if cFile:Open()
						nSize := cFile:GetFileSize()
						cFile:Close()
					EndIf

					// Lê todo o arquivo
					While FRead(nHandle, @cLinha, nSize) > 0
						// Procura a linha que contém o código de cliente e o "="
						nPos := At(cC5_CLIENTE + "=", cLinha)
						If nPos > 0
							// Extrai o nome da etiqueta após o "="
							cEtiqueta := SubStr(cLinha, nPos + Len(cC5_CLIENTE) + 1)
							cEtiqueta := AllTrim(cEtiqueta) // Remove espaços em branco e quebras de linha
							Exit
						EndIf
					EndDo

					FClose(nHandle) // Fecha o arquivo após a leitura
				Else
					MsgStop('Erro ao abrir o arquivo de configuração de etiquetas.')
					Final()
				EndIf
				*/
			EndIf

			// Verifica se encontrou a etiqueta para o cliente
			If Empty(cEtiqueta)
				MsgStop('Não existe etiqueta configurada para este cliente. Favor entrar em contato com comercial !!!')
				Final()
			EndIf

			// Verifico focus:
			If Empty(cZZ5_1ACOND)
				oZZ5_1ACOND:SetFocus()
			ElseIf Empty(cZZ5_2ACOND)
				oZZ5_2ACOND:SetFocus()
			Else
				oCodBar:SetFocus()
			EndIf
		EndIf
	EndIf

	oC5_Cliente:Refresh()
	oA1_Nome:Refresh()

	cSayPall := Space(24)

	/*oSPallet:cCaption := Space(24)
	oSPallet:Refresh()*/

	If cGPallet	!= 'N'
		If	lRet .And. lCampos
			If	Select('TPAL')<>0
				TPAL->(DbCloseArea())
			EndIf
			BeginSql Alias 'TPAL'
				SELECT
					DISTINCT TOP 1 ZZ5_PALLET,
					ZZ5_IMPALL
				FROM
					%Table:ZZ5%
				WHERE
					%NotDel%
					AND ZZ5_FILIAL = %xFilial:ZZ5%
					AND ZZ5_PEDIDO = %Exp:cC5_Num%
				ORDER BY
					ZZ5_PALLET DESC
			EndSql
			If	TPAL->(Eof()) .Or. Empty(TPAL->ZZ5_PALLET)
				If lGravPal
					If cGPallet == 'S'
						lRetPal 	:= .T.
						lGravPal	:= .T.
					Else
						//lRetPal 	:= MsgYesNo('Deseja Armazenar as Etiquetas a serem geradas para Montagem de Pallet ?')
						lRetPal		:= .F.
						nAviso		:= 3
						lMsHelpAuto := .F.
						//while nAviso == 3
						//	nAviso	:= AVISO("Atenção", "Deseja Armazenar as Etiquetas a serem geradas para Montagem de Pallet ?", {"Cancelar", "Confirma", "Escolha"}, 3)
						//EndDo
						nAviso		:= 1
						IF MsgBox("Deseja armazenar as etiquetas a serem geradas para Montagem de Pallet?", "Pallet", "YESNO")
							nAviso		:= 2
						EndIf
						If nAviso == 2
							lRetPal	:= .T.
						End If
						lGravPal	:= lRetPal
					EndIf
				EndIf
			Else
				lRetPal := .T.
			EndIf

			If	lRetPal
				oPallet:Enable()

				cPallet := '0001'
				lPallet := .T.

				If	!TPAL->(Eof())
					If	!Empty(TPAL->ZZ5_PALLET)
						cPallet := Soma1(TPAL->ZZ5_PALLET)
					EndIf

					If	TPAL->ZZ5_IMPALL == 'N'
						// Verifico se o pallet já não teve geração de romaneio (Thiago 30/08/2016):
						lNovoPal	:= .T.
						If Select("PALLROM") <> 0
							PALLROM->(DbCloseArea())
						EndIf
						BeginSql Alias "PALLROM"
							SELECT
								DISTINCT TOP 1 ZZ5_ROMENV,
								ZZ5_ROMRET
							FROM
								%Table:ZZ5%
							WHERE
								%NotDel%
								AND ZZ5_FILIAL = %xFilial:ZZ5%
								AND ZZ5_PEDIDO = %Exp:cC5_Num%
								AND ZZ5_PALLET = %Exp:TPAL->ZZ5_PALLET%
								AND ZZ5_ROMENV != ' '
						EndSql
						If !PALLROM->(Eof())
							lNovoPal	:= .F.
						EndIf

						// Somento permito continuar do último pallet caso o romaneio não tinha sido gerado:
						If lNovoPal
							If lCDBudd
								// Verifico se o pallet já não foi endereçado:
								lMarcPallet	:= .F.
								If (Select("TT1120") <> 0)
									DbSelectArea("TT1120")
									DbCloseArea()
								Endif
								cQuery := "SELECT TOP 1 ZBM_PALLET "
								cQuery += "FROM ZBM010 (NOLOCK) "
								cQuery += "INNER JOIN SBE010 (NOLOCK) ON BE_FILIAL = '01' AND BE_LOCALIZ = ZBM_ENDERE AND BE_TIPODES NOT IN ('ENDERECAR', 'ACONDICIONAR') AND SBE010.D_E_L_E_T_ = '' "
								cQuery += "WHERE ZBM_FILIAL = '' "
								cQuery += "AND ZBM_PALLET = '"+cC5_Num+AllTrim(TPAL->ZZ5_PALLET)+"' "
								cQuery += "AND ZBM_QTDTOT > 0 "
								cQuery += "AND ZBM010.D_E_L_E_T_ = '' "
								cQuery := ChangeQuery(cQuery)
								TCQuery cQuery NEW ALIAS "TT1120"
								If TT1120->(Eof())
									// No caso do CD, somente faço a pergunta se o pallet não foi endereçado ainda anteriormente:
									nAviso		:= 3
									lMsHelpAuto := .F.
									//while nAviso == 3
									//	nAviso	:= AVISO("Atenção", 'Deseja continuar o carregamento no último pallet ['+AllTrim(TPAL->ZZ5_PALLET)+'] com etiqueta não impressa?', {"Cancelar", "Confirma", "Escolha"}, 3)
									//EndDo
									IF MsgBox('Deseja continuar o carregamento no último pallet ['+AllTrim(TPAL->ZZ5_PALLET)+'] com etiqueta não impressa?', "Pallet", "YESNO")
										nAviso := 2
									EndIf

									// Continua do pallet anterior:
									If nAviso == 2
										cPallet := TPAL->ZZ5_PALLET
									Else
										// Caso não continua do pallet anterior, marco ele como impresso:
										lMarcPallet	:= .T.
									EndIf
								Else
									lMarcPallet	:= .T.
								EndIf
								// Marco pallet antigo como já impresso:
								If lMarcPallet
									TCSQLEXEC("UPDATE ZZ5010 SET ZZ5_IMPALL = 'S' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+AllTrim(TPAL->ZZ5_PALLET)+"' AND ZZ5010.D_E_L_E_T_ = '' ")
								EndIf
							Else
								nAviso		:= 3
								lMsHelpAuto := .F.
								//while nAviso == 3
								//nAviso	:= AVISO("Atenção", 'Deseja continuar o carregamento no último pallet ['+AllTrim(TPAL->ZZ5_PALLET)+'] com etiqueta não impressa?', {"Cancelar", "Confirma", "Escolha"}, 3)
								//EndDo
								IF MsgBox('Deseja continuar o carregamento no último pallet ['+AllTrim(TPAL->ZZ5_PALLET)+'] com etiqueta não impressa?', "Pallet", "YESNO")
									nAviso := 2
								EndIf

								// Continua do pallet anterior:
								If nAviso == 2
									cPallet := TPAL->ZZ5_PALLET
								EndIf
							EndIf
						EndIf
					Else
						// Verifico pallet parcial:
						If lCDBudd .And. !Empty(cC6_PRODUTO)
							VerPallPar(cC5_NUM, cC6_PRODUTO, cPallet)
						EndIf
					EndIf
				EndIf

				cSayPall := "Número do Pallet - "+cPallet
			Else
				oPallet:Disable()
			EndIf
		EndIf
	Else
		cPallet := ''
		oPallet:Disable()
	End If

	// Verifico o endereço para o pallet:
	If lCDBudd
		VerEndEst(cC5_Num+AllTrim(cPallet))
	EndIf

	// Caso negativo e CD, volto para a tela inicial:
	If lCDBudd .And. !lRet
		TelaCD(.T.)
	EndIf

Return lRet

Static Function B1120Alert()
	Local cArqErr	:= "C:\Som_Exped\Erro_Inv.exe"

	// Tratativa para somente abrir o erro quando existir o arquivo:
	if File(cArqErr)
		nRet := ShellExecute("Open", cArqErr, "", "C:\", 1)
	EndIf

Return

// Função para deixar passar produtos com cadastro de código de cores antigas:
Static Function CodigoAnt()
	//Chumbei pra passar - Rodrigo
Return (lRet := .T.)

// Verifico se existe código antigo cadastrado no sistema:
If Empty(cCodBar)
	Return
EndIf

lCodAnt	:= .F.
If (Select("TT1120") <> 0)
	DbSelectArea("TT1120")
	DbCloseArea()
Endif
cQuery := ""
cQuery += "SELECT DISTINCT TOP 1 B1_CODBAR "
cQuery += "FROM "+RetSqlName("SC6")+" (NOLOCK) "
cQuery += "INNER JOIN "+RetSqlName("SA7")+" (NOLOCK) ON A7_FILIAL = '"+xFilial("SA7")+"' AND A7_CLIENTE = C6_CLI AND A7_LOJA = C6_LOJA AND A7_PRODUTO = C6_PRODUTO AND "+RetSqlName("SA7")+".D_E_L_E_T_ = '' "
cQuery += "INNER JOIN "+RetSqlName("SB1")+" (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' AND RTRIM(B1_CODBAR) = RTRIM(A7_CODCLI) AND "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += "AND C6_NUM = '"+cC5_Num+"' "
cQuery += "AND C6_CLI IN ('015006') "
cQuery += "AND A7_CODCLI <> '' "
cQuery += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
cQuery := ChangeQuery(cQuery)
TCQuery cQuery NEW ALIAS "TT1120"
If !TT1120->(Eof())
	lCodAnt	:= .T.
	// Verifico qual é o código que preciso substituir:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT DISTINCT B1_CODBAR "
	cQuery += "FROM "+RetSqlName("SC6")+" (NOLOCK) "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" (NOLOCK) ON B1_FILIAL = '"+xFilial("SB1")+"' AND B1_COD = C6_PRODUTO AND "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN "+RetSqlName("SA7")+" (NOLOCK) ON A7_FILIAL = '"+xFilial("SA7")+"' AND A7_CLIENTE = C6_CLI AND A7_LOJA = C6_LOJA AND A7_PRODUTO = C6_PRODUTO AND "+RetSqlName("SA7")+".D_E_L_E_T_ = '' "
	cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += "AND C6_NUM = '"+cC5_Num+"' "
	cQuery += "AND A7_CODCLI = '"+cCodBar+"' "
	cQuery += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		cCodBar	:= TT1120->B1_CODBAR
		cCodBar	:= Upper(AllTrim(cCodBar))
	Else
		MsgStop('O código de barras para esse cliente deve ser o antigo!')
		Return (lRet := .F.)
	EndIf
EndIf

Return (.T.)

// Valida o código de barras do produto informado e carrega os dados do mesmo para a tela cfe o item do pedido de vendas posicionado
Static Function B1120CodBar()

	Local lRet 			:= .T.
	Local cAliasBar 	:= 'BAR1120'
	Local nTotRes		:= 0
	Local cA7_PRODUTO	:= ""
	Local cFiltro := ""
	Local cCliCod := ""
	Local cCliLoja := ""

	Local lRetVin	:= .F.

	If cCodBarAnt != cCodBar
		lPrim	:= .T.
	End If
	cCodBarAnt	:= cCodBar

	If Empty(cCodBar)
		Return (lRet := .T.)
	End If

	// Verifico focus:
	If Empty(cC5_NUM)
		MsgStop("Por favor informe o pedido!")
		oC5_Num:SetFocus()
		Return (lRet := .T.)
	ElseIf Empty(cZZ5_1ACOND)
		MsgStop("Por favor informe o operador!")
		oZZ5_1ACOND:SetFocus()
		Return (lRet := .T.)
	ElseIf Empty(cZZ5_2ACOND)
		MsgStop("Por favor informe o ajudante!")
		oZZ5_2ACOND:SetFocus()
		Return (lRet := .T.)
	EndIf

	cCodBar	:= Upper(AllTrim(cCodBar))

	// Verifico se permite encaixotamento pelo código do cliente:
	If cC5_CLIENTE $ AllTrim(GetMv("BD_1120BAR"))
		// Verifico se existe registro do A7 BARRA cadastrado:
		//SA7->(DbSetOrder(4))
		//A7Barra := SA7->(DbSeek(xFilial('SA7')+cCodBar+cC5_CLIENTE+cC5_LOJACLI))
		If (Select("TT1120") <> 0)
			DbSelectArea("TT1120")
			DbCloseArea()
		Endif
		If SC5->C5_CLIENTE $ '200056'
			If !Empty(cCodBar)
				cFiltro := " OR ((A7_BARRA <> '' AND '"+cCodBar+"' LIKE '%'+LTRIM(RTRIM(A7_BARRA))+'%') OR (A7_CODCLI <> '' AND '"+cCodBar+"' LIKE '%'+LTRIM(RTRIM(A7_CODCLI))+'%'))"
				//cFiltro = " OR (A7_BARRA = '"+LEFT(cCodBar, 12)+"')  "
			EndIf
		EndIf
		cQuery := "SELECT TOP 1 A7_BARRA, A7_PRODUTO "
		cQuery += "FROM SA7010 (NOLOCK) "
		cQuery += "WHERE A7_FILIAL = '' "
		cQuery += "AND ( "
		cQuery += " (A7_BARRA = '"+cCodBar+"')  " + cFiltro
		cQuery += " OR "
		//cQuery += " ('"+cCodBar+"' LIKE A7_BARRA AND A7_BARRA LIKE '%%%' AND A7_BARRA <> '') " comentado  no dia 19/03/2025 - Jonas
		cQuery += " ('"+cCodBar+"' LIKE A7_BARRA AND A7_BARRA LIKE '%' + A7_BARRA + '%') " /// adicionado 19/03/2025 - Jonas
		cQuery += ") "
		//cQuery += "AND RTRIM(A7_BARRA) = LEFT('"+cCodBar+"', LEN(RTRIM(A7_BARRA))) "
		cQuery += "AND A7_CLIENTE = '"+cC5_CLIENTE+"' "
		cQuery += "AND A7_LOJA = '"+cC5_LOJACLI+"' "
		cQuery += "AND A7_BARRA <> '' "
		cQuery += "AND SA7010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1120"
		If !TT1120->(Eof())
			cA7_PRODUTO	:= TT1120->A7_PRODUTO
			cCodBar	:= TT1120->A7_BARRA
		EndIf
	EndIf

	// Verifica se o codigo de barras informado e do Protheus
	SB1->(DbSetOrder(5))
	SB1->(DbSeek(xFilial('SB1')+cCodBar))

	// Se nao encontrar
	If	!SB1->(Found())
		// Verifica se o codigo de barras informado e do produto x cliente
		SA7->(DbSetOrder(4))
		SA7->(DbSeek(xFilial('SA7') + PadR(cCodBar, TAMSX3("A7_BARRA")[1]) + PadR(cC5_CLIENTE, TAMSX3("A7_CLIENTE")[1]) + cC5_LOJACLI))

		// Se nao encontrar
		If	!SA7->(Found())
			MsgStop('Código de Barras de Produto não Cadastrado !!!!')
			Return (lRet := .F.)

		Else
			// Recebe o codigo do produto
			cA7_PRODUTO	:= SA7->A7_PRODUTO

			// Verifica se o produto existe no Protheus
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial('SB1') + cA7_PRODUTO))

			// Se nao existir
			If	!SB1->(Found())
				MsgStop('Código de Barras de Produto não Cadastrado !')
				Return (lRet := .F.)

				// Se existir
			Else
				cCodBar := SB1->B1_CODBAR
			EndIf
		EndIf
	EndIf

	// Verifica código antigo:
	//If !CodigoAnt()
	//	Return (lRet := .F.)cCBAux
	//EndIf


	If	Empty(cCBAux)
		cCBAux := cCodBar
	ElseIf	cCBAux != cCodBar
		If	GetFocus() == oLimpar:hwnd
			IF SC5->C5_CLIENTE <> '200056' .OR. lPrimVol
				lPrim := .T.
			Endif
			Return (lRet := .T.)
		ElseIf Empty(cA7_PRODUTO)
			//	IF SC5->C5_CLIENTE <> '233389'
			MsgStop('Código de Barras lido é diferente do que está em processo de encaixotamento. Favor encerrar a caixa do produto '+AllTrim(cCBAux)+ ' x '+AllTrim(cCodBar)+' !!!')
			Return (lRet := .F.)
			//Endif
		EndIf
	EndIf

	If	Empty(cCodBar)
		If	Empty(cC6_ITEM)
			Return (lRet := .T.)
		Else
			If !MsgYesNo('Existe Item encaixotado parcial, Confirma eliminação de Dados do mesmo ?')
				Return (lRet := .F.)
			Else
				B1120Limpar(.F.)
				Return (lRet := .T.)
			EndIf
		EndIf
	EndIf

	If Empty(cA7_PRODUTO)
		SB1->(DbSetOrder(5))
		SB1->(DbSeek(xFilial('SB1')+cCodBar))
		If	!SB1->(Found())
			MsgStop('Código de Barras de Produto não Cadastrado !!')
			Return (lRet := .F.)
		EndIf
	Else
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial('SB1')+cA7_PRODUTO))
		If	!SB1->(Found())
			MsgStop('Código de Barras de Produto não Cadastrado !!!')
			Return (lRet := .F.)
		EndIf
	EndIf

	// Se não for cliente Rio Negro
	If SC5->C5_CLIENTE != '638545' .And. !Empty(cPallet)
		cCliCod := SC5->C5_CLIENTE
		cCliLoja := SC5->C5_LOJACLI

		// Se o pallet deste pedido já foi gerado na tabela ZZ5
		ZZ5->(DbSetOrder(4))
		If ZZ5->(DbSeek(xFilial('ZZ5')+cC5_NUM+cPallet))
			// Verifica se a referencia + cor é do pallet atual
			If (Select("VRFPAL") <> 0)
				dbSelectArea("VRFPAL")
				dbCloseArea()
			EndIf

			// Realizo a consulta
			BeginSql alias 'VRFPAL'
				SELECT
					DISTINCT ZZ5.ZZ5_PRODUT
				FROM
					%Table:ZZ5% (NOLOCK) AS ZZ5
				INNER JOIN %Table:SB1% (NOLOCK) AS SB1
				ON SB1.B1_FILIAL = %xFilial:SB1%
					AND ZZ5.ZZ5_PRODUT BETWEEN SB1.B1_COD AND SB1.B1_COD + 'Z'
					AND SB1.%notDel%
				LEFT JOIN %Table:SA7% (NOLOCK) AS SA7
				ON SA7.A7_FILIAL = %xFilial:SA7%
					AND SA7.A7_CLIENTE = %Exp:cCliCod%
					AND SA7.A7_LOJA = %Exp:cCliLoja%
					AND SA7.A7_PRODUTO = SB1.B1_COD
					AND SA7.%notDel%
				WHERE
					ZZ5.ZZ5_FILIAL = %xFilial:ZZ5%
					AND ZZ5.ZZ5_PEDIDO = %Exp:cC5_NUM%
					AND ZZ5.ZZ5_PALLET = %Exp:cPallet%
					AND (
						SB1.B1_CODBAR = %Exp:cCodBar%
						OR SA7.A7_BARRA = %Exp:cCodBar%
					)
					AND ZZ5.%notDel%
			EndSql

			// Se não for
			If VRFPAL->(Eof())
				MsgStop('Não é possível imprimir a etiqueta de um produto/cor que não faz parte do pallet atual, gentileza finalizar o pallet primeiro !!!')
				Return (lRet := .F.)
			EndIf
		EndIf
	EndIf

	// Preencho buffer do produto:
	cPrBuff	:= SB1->B1_COD

	If lReserva
		SC6->(DbSetOrder(2)) //// JONAS - 24-03-2016
		SC6->(DbSeek(xFilial('SC6')+SB1->B1_COD+cC5_Num))
		If	SC6->(Found()) .AND. SC6->C6_LOCAL $'03/04/A4/A6'
			MsgStop('NÃO É PERMITIDO PASSAR ITEM DO MERCADO NACIONAL !!!')
			Return (lRet := .F.)
		EndIf
	End If

	If !Empty(cA7_PRODUTO)
		cWhere := "% C5_NUM = '" + cC5_Num + "' AND B1_COD = '" + cA7_PRODUTO + "' %"
	Else
		cWhere := "% C5_NUM = '" + cC5_Num + "' AND B1_CODBAR = '" + cCodBar + "' %"
	EndIf
	B1120Carga(@cAliasBar, cWhere)

	If	!(cAliasBar)->(Eof())

		If (cAliasBar)->C5_CLIENTE == "477066"
			If Empty((cAliasBar)->A7_CODCLI)
				MsgStop("Atenção. Para este cliente é necessário o código do Produto do Cliente, Verifique !!! " + AllTrim(SB1->B1_COD))
				Return (lRet := .F.)
			EndIf
		EndIf

		cCodEmb  := (cAliasBar)->C6_CODTPCX
		if(Empty(cCodEmb))
			cCodEmb  := AllTrim(GetMv("BD_1120CPA"))
		EndIf
		nQtdPcte := (cAliasBar)->Z7_QTDPCT

		nQtdPCxa := (cAliasBar)->Z7_QTDCAIX

		If Select("PROD") <> 0
			PROD->(DbCloseArea())
		EndIf
		BeginSql Alias "PROD"
			SELECT
				DISTINCT TOP 1 B1_COD
			FROM
				%Table:SB1010%
			WHERE
				%NotDel%
				AND B1_FILIAL = %xFilial:SB1%
				AND B1_COD = %Exp:SB1->B1_COD%
				AND B1_DESC LIKE 'TRAVESSEIRO%'
		EndSql
		If !PROD->(Eof())
			lPROD	:= .T.
		ELSE
			lPROD	:= .F.
		EndIf

		ZCN->(DbSetOrder(2))
		ZCN->(DbSeek(xFilial('ZCN')+SA1->A1_CODENCX+Left(SB1->B1_COD,8)+SUBSTR(SB1->B1_COD,15,4)))
		If	ZCN->(Found())

			// Somente preencho o código da embalagem, caso exista a mesma no EE5:
			EE5->(dbSeek(xFilial("EE5")+ZCN->ZCN_CODEMB))
			If	EE5->(Found())
				cCodEmb := ZCN->ZCN_CODEMB
			End If

			nQtdPCxa:= ZCN->ZCN_QTDE
			If AllTrim(SC5->C5_CLIENTE) $ AllTrim(GetMv("BD_1120CMT")) .And. !Empty(ZCN->ZCN_QTDPCT)
				nQtdPcte:= ZCN->ZCN_QTDPCT
			ENDIF

			If lPROD .And. !Empty(ZCN->ZCN_QTDPCT)
				nQtdPcte:= ZCN->ZCN_QTDPCT
			ENDIF

			// Permite quantidade por caixa abaixo da grade:
			nQtdSalPr	:= (cAliasBar)->C6_QUANT - (cAliasBar)->ZZ5_QTDENC
			If nQtdSalPr < nQtdPCxa .And. nQtdSalPr > 0
				nQtdPCxa:= nQtdSalPr
			EndIf

			// Quantidade zerada:
			If nQtdPCxa <= 0
				MsgAlert('Atenção: O cadastro da grade de encaixotamento para este item está incorreto!')
				Return (lRet := .F.)
			End If
		EndIf

		nC0_Quant := 0
		// Não controla reserva:
		If lReserva
			If	Select('Reserv')<>0
				Reserv->(DbCloseArea())
			EndIf

			BeginSql Alias 'Reserv'
				SELECT
					SUM(ISNULL(C0_QUANT, 0)) AS C0_QUANT
				FROM
					%Table:SC0% SC0 (NOLOCK)
				WHERE
					SC0.%NotDel%
					AND C0_FILIAL = %xFilial:SC0%
					AND C0_DOCRES = %Exp:cC5_NUM%
					AND C0_PRODUTO = %Exp:SB1->B1_COD%
					AND C0_QUANT > 0
			EndSql

			If	!Reserv->(Eof())
				nC0_Quant := Reserv->C0_QUANT
			EndIf
		End IF

		// Verificação de saldo de encaixotamento no CD:
		If lCDBudd
			// Verifica saldo antes de bipar:
			If !SaldoCD(cPrBuff, .F.)
				Return (lRet := .F.)
			EndIf
		EndIf

		cC6_ITEM 	:= (cAliasBar)->C6_ITEM
		cGCor 		:= (cAliasBar)->ZT_COD + ' - ' + (cAliasBar)->ZT_DESCRI
		cC6_PRODUTO	:= (cAliasBar)->C6_PRODUTO
		cC6_LOCAL	:= (cAliasBar)->C6_LOCAL
		cB1_DESC	:= (cAliasBar)->B1_DESC
		cCodCxa		:= cCodEmb
		cTpCxa 		:= cCodCxa + ' - ' + AllTrim((cAliasBar)->EE5_DESC)
		cDsCxa 		:= AllTrim((cAliasBar)->EE5_DESC)
		If SC5->C5_CLIENTE $ '200056
			nTotCxa := Round((cAliasBar)->C6_QTDVEN /  nQtdPcte,1) //(cAliasBar)->Z7_QTDCAIX,1)
		else
			nTotCxa := Round((cAliasBar)->C6_QTDVEN /  nQtdPCxa,1) //(cAliasBar)->Z7_QTDCAIX,1)

		Endif
		aQuant[1] := "Reservada          - " + Transform((cAliasBar)->C6_QTDEMP + (cAliasBar)->C6_QTDRESE + nC0_QUANT, cMascQtd)
		aQuant[2] := "A Entregar do Item - " + Transform((cAliasBar)->C6_QUANT, cMascQtd)
		aQuant[4] := "------------------------------------"

		If	lPrim
			nQtdEnc   	:= (cAliasBar)->ZZ5_QTDENC
			nQtdSal   	:= IIF ( (cAliasBar)->C6_QUANT <=(cAliasBar)->ZZ5_QTDENC, ((cAliasBar)->C6_QTDVEN - (cAliasBar)->ZZ5_QTDENC),((cAliasBar)->C6_QUANT - (cAliasBar)->ZZ5_QTDENC))
			If lLiberac
				nQtdSal   	:= ((cAliasBar)->C6_QUANT - (cAliasBar)->ZZ5_QTDENC)
			EndIf

			nQtdRes   	:= ((cAliasBar)->C6_QTDEMP + (cAliasBar)->C6_QTDRESE + nC0_QUANT)
			cNumCxa   	:= B1120NumEtq() // Soma1((cAliasBar)->ZZ5_NUMETQ)
			cDescCxa  	:= 'Número da Caixa - ' + cNumCxa
			//cTotCxa	:= StrZero(((cAliasBar)->C6_QTDVEN - (cAliasBar)->C6_QTDCANC) / (cAliasBar)->QTDCAIXA,3)
			IF (((cAliasBar)->C6_QTDVEN - (cAliasBar)->C6_QTDCANC) / nQtdPCxa) >= 1000
				cTotCxa	:= StrZero(((cAliasBar)->C6_QTDVEN - (cAliasBar)->C6_QTDCANC) / nQtdPCxa,4)
			ELSE
				cTotCxa	:= StrZero(((cAliasBar)->C6_QTDVEN - (cAliasBar)->C6_QTDCANC) / nQtdPCxa,4)
			ENDIF

			If SC5->C5_CLIENTE $ '200056'
				cTotCxa	:= StrZero(((cAliasBar)->C6_QTDVEN - (cAliasBar)->C6_QTDCANC) / nQtdPcte,4)
			EndIf

			aEmbal[1] := "Qtd.Pcs. p/Pacote  - " + Transform(/*(cAliasBar)->Z7_QTDPCT*/nQtdPcte, "@E 9,999")
			aEmbal[2] := "Qtd.Pcs. p/Caixa   - " + Transform(/*(cAliasBar)->QTDCAIXA*/nQtdPCxa,"@E 9,999")
			aEmbal[3] := "Qtd.de Pacotes     - " + Transform(nQtdPCxa/nQtdPcte,"@E 9,999")
			//aEmbal[2] := "Qtd. por Caixa   - " + Transform((cAliasBar)->Z7_QTDCAIX,"@E 9,999")

			dbSelectArea('SB2')
			dbSetOrder(1)
			dbSeek(xFilial('SB2')+(cAliasBar)->(C6_PRODUTO+C6_LOCAL))

			If lLiberac
				nSaldoSB2:=(SB2->B2_QATU - SB2->B2_QEMP)
			Else
				nSaldoSB2:=SaldoSB2(,,,,,)
			EndIf

			aEmbal[4] := "Saldo em Estoque   - "+ AllTrim(Transform(nSaldoSB2, PesqPict('SB2','B2_QATU')))

			oLBEmbal:aItems 	:= aClone(aEmbal)

			lPrim     := .F.

			// Verifico o pallet a ser continuado aqui:
			If lCDBudd
				MsAguarde({|| VerPallPar(cC5_NUM, cC6_PRODUTO, cPallet) }, "Parcial", "Verificando pallet parcial...")
			EndIf
		EndIf

		If lAbaixoM
			oFimCaixa:Enable()
		EndIf

		nQtdPcs ++
		nQtdEnc += nQtdPcte //(cAliasBar)->Z7_QTDPCT
		nQtdSal -= nQtdPcte //(cAliasBar)->Z7_QTDPCT

		aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
		aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)

		nPcsCxa += nQtdPcte //(cAliasBar)->Z7_QTDPCT

		oLBQuant:aItems := aClone(aQuant)

		oC6_ITEM:Refresh()
		oGCor:Refresh()
		oC6_PRODUTO:Refresh()
		oB1_DESC:Refresh()
		oTpCxa:Refresh()
		oNumCxa:Refresh()
		oTotCxa:Refresh()

		If	nSaldoSb2 < nPcsCxa
			nQtdEnc -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdSal += nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nPcsCxa -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdPcs --
			aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
			aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)
			oLBQuant:aItems := aClone(aQuant)
			oLBQuant:Refresh()
			oPcsCxa:Refresh()
			oQtdPcs:Refresh()
			MsgAlert('Saldo em Estoque do Produto não é suficiente para este encaixotamento ['+AllTrim(Str(nSaldoSb2))+' x '+AllTrim(Str(nPcsCxa))+']!!!')
			Return (lRet := .F.)
		EndIf

		// Verifica quantidade encaixotada maior do que o estoque:
		nTotEnc	:= 0
		nTotRes	:= 0
		If (Select("TC1120") <> 0)
			dbSelectArea("TC1120")
			dbCloseArea()
		EndIf

		cQuery := "SELECT DISTINCT TOP 1 SUM(C6_QTDENCX) AS TOT_ENC, SUM("+cColEmpDs+") AS TOT_RES "
		cQuery += " FROM "+RetSqlName("SC6")+" (NOLOCK) "
		cQuery += " INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S' AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
		cQuery += " WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
		cQuery += " AND C6_NUM = '"+cC5_Num+"' "
		cQuery += " AND C6_LOCAL = '"+cC6_LOCAL+"' "
		cQuery += " AND C6_PRODUTO = '"+cC6_PRODUTO+"' "
		cQuery += " AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
		TCQuery cQuery NEW ALIAS "TC1120"
		If !TC1120->(EOF())
			nTotEnc := (TC1120->TOT_ENC + nQtdPcte)
			nTotRes	:= (TC1120->TOT_RES)
		EndIf
		nTotEst	:= 0
		If (Select("TC1120") <> 0)
			dbSelectArea("TC1120")
			dbCloseArea()
		EndIf
		cQuery := " SELECT DISTINCT TOP 1 B2_QATU "
		cQuery += " FROM "+RetSqlName("SB2")+" (NOLOCK) "
		cQuery += " WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
		cQuery += " AND B2_LOCAL = '"+cC6_LOCAL+"' "
		cQuery += " AND B2_COD = '"+cC6_PRODUTO+"' "
		cQuery += " AND "+RetSqlName("SB2")+".D_E_L_E_T_ = '' "
		TCQuery cQuery NEW ALIAS "TC1120"
		If !TC1120->(EOF())
			nTotEst := (TC1120->B2_QATU)
		EndIf
		// Caso a quantidade encaixotada seja superior a em estoque:
		IF (nTotEnc > nTotEst) .And. !lDistrPed
			MsgStop("Atenção! A quantidade encaixotada está superior à quantidade em estoque, gentileza verificar com a liberação!")
			nQtdEnc -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdSal += nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nPcsCxa -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdPcs --
			aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
			aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)
			oLBQuant:aItems := aClone(aQuant)
			oLBQuant:Refresh()
			oPcsCxa:Refresh()
			oQtdPcs:Refresh()
			Return (lRet := .F.)
		EndIf
		// Caso a quantidade seja superior a reservada:
		IF (nTotEnc > nTotRes)
			MsgStop("Atenção! A quantidade encaixotada está superior à quantidade reservada [Local: "+cC6_LOCAL+"], gentileza verificar com a liberação!")
			nQtdEnc -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdSal += nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nPcsCxa -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
			nQtdPcs --
			aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
			aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)
			oLBQuant:aItems := aClone(aQuant)
			oLBQuant:Refresh()
			oPcsCxa:Refresh()
			oQtdPcs:Refresh()
			Return (lRet := .F.)
		EndIf

		If (nQtdEnc > (cAliasBar)->C6_QUANT)

			If	(nQtdSal < 0)
				nQtdEnc -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
				nQtdSal += nQtdPcte //(cAliasBar)->Z7_QTDPCT
				If	((cAliasBar)->C6_QUANT - (cAliasBar)->ZZ5_QTDENC) == (nPcsCxa - nQtdPcte /*(cAliasBar)->Z7_QTDPCT*/) .And. (nQtdPcs > 1)
					nPcsCxa -= nQtdPcte //(cAliasBar)->Z7_QTDPCT
					nQtdPcs --
					aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
					aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)
					oLBQuant:aItems := aClone(aQuant)
					oLBQuant:Refresh()
					oPcsCxa:Refresh()
					oQtdPcs:Refresh()
				Else
					MsgAlert("Quantidade Total 'A Entregar do Item' já foi encaixotada !!!")
					lPrim := .T.
					nPcsCxa -= nQtdPcte  //(cAliasBar)->Z7_QTDPCT
					nQtdPcs --
					aQuant[3] := "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
					aQuant[5] := "Saldo              - " + Transform(nQtdSal, cMascQtd)
					oLBQuant:aItems := aClone(aQuant)
					oLBQuant:Refresh()
					oPcsCxa:Refresh()
					oQtdPcs:Refresh()
					Return (lRet := .F.)
				EndIf
			EndIf
		EndIf

		//If nPcsCxa != nQtdPCxa
		lConfirma := .F.
		If	((cAliasBar)->C6_QUANT == 0) .Or. (nQtdEnc == (cAliasBar)->C6_QUANT)
			//lConfirma := MsgYesNo('Deseja finalizar o encaixotamento Parcial do Item !!!')
			lConfirma := .T.
		EndIf
		//End IF

		If SC5->C5_CLIENTE == '200056'
			If	Select('VOLUME')<>0
				VOLUME->(DbCloseArea())
			EndIf

			BeginSql Alias 'VOLUME'
				SELECT
					MAX(ZZ5_VOLINI) AS ZZ5_VOLINI,
					MAX(ZZ5_VOLFIM) AS ZZ5_VOLFIM
				FROM
					%Table:ZZ5% ZZ5 (NOLOCK)
				WHERE
					ZZ5.%NotDel%
					AND ZZ5_FILIAL = %xFilial:ZZ5%
					AND ZZ5_PEDIDO = %Exp:cC5_NUM%
					AND ZZ5_PRODUT = %Exp:SB1->B1_COD%
			EndSql

			lGerou:=.F.
			If !empty(VOLUME->ZZ5_VOLINI)

				If !empty(VOLUME->ZZ5_VOLFIM)

					If lPrimV1
						cVolIniA:= VOLUME->ZZ5_VOLFIM //Soma1((cAliasBar)->ZZ5_VOLFIM)
						lPrimV1:=.F.
					Endif
					cVolIniA:= Soma1(cVolIniA)
				Else
					If lPrimV1
						cVolIniA:= VOLUME->ZZ5_VOLINI
						lPrimV1:=.F.
					Endif
					cVolIniA:= Soma1(cVolIniA)
				EndIf
			Else

				cVOLR   	:= Soma1(cVOLR)

			EndIf

			If lPrimVol
				If !empty(cVolINIA)
					cVolPRI:= cVolIniA
				Else
					cVolPRI:= cVOLR
				EndIf
				lPrimVol:=.F.
			Endif

			// Thiago/Jonas (06/03/2023) - Verifica se imprime a etiqueta do pacote Riachuelo:
			If AllTrim(cA1_EST) $ AllTrim(GetMv("BD_1120RUF")) .Or. AllTrim(GetMv("BD_1120RUF")) == '*'
				cB1_UM	:= Posicione("SB1", 1, xFilial("SB1")+cC6_PRODUTO, "B1_UM")
				If AllTrim(cB1_UM) $ AllTrim(GetMv("BD_1120RUM")) .Or. AllTrim(GetMv("BD_1120RUM")) == '*'
					//oDlg:Refresh()
					///////// CONFORME SOLICITAÇÃO DO SR. JAIRO. IRÁ IMPRIMIR ETQ DO PACOTE SOMENTE QUANDO O PROD. MAIOR QUE 1 PC NO PCTO. - JONAS  13/05/2021
					If	Select('QTDPCT')<>0
						QTDPCT->(DbCloseArea())
					EndIf

					BeginSql Alias 'QTDPCT'
						SELECT
							DISTINCT Z7_QTDPCT
						FROM
							%Table:SC5% C5 (NOLOCK)
						INNER JOIN %Table:SC6% C6 (NOLOCK)
						ON C6_FILIAL = %xFilial:SC6%
							AND C6_NUM = C5_NUM
							AND C6.%NotDel%
						INNER JOIN %Table:SB1% B1 (NOLOCK)
						ON B1_FILIAL = %xFilial:SB1%
							AND B1_COD = C6_PRODUTO
							AND B1.%NotDel%
						INNER JOIN %Table:SZ7% Z7 (NOLOCK)
						ON Z7_FILIAL = %xFilial:SZ7%
							AND Z7_COD = B1_CODMOD
							AND Z7_QTDPCT = 1
							AND Z7.%NotDel%
						WHERE
							C6.%NotDel%
							AND C6_FILIAL = %xFilial:SC6%
							AND C5_NUM = %Exp:cC5_NUM%
					EndSql

					If empty(QTDPCT->Z7_QTDPCT)
						/* Será efetuado a impressao da etiqueta na impressora termica */
						MsAguarde({|| U_B1120PrtR(cC5_Num, cC6_Item, cC6_PRODUTO, iif(!empty(cVolINIA),cVolINIA,cVOLR), ZZ5->ZZ5_SeqEnc, SC5->C5_CLIENTE, SC5->C5_LOJACLI, nPcsCxa, cTotCxa, .F.) }, 'Imprimindo', 'Aguarde ... Imprimindo Etiqueta ' + cNumCxa + '...')
					EndIf
				EndIf

			EndIf

		Endif

		// Efetuo vinculo ZDU e ZDY:
		if lCDBudd
			// Tratativa para vincular o código a gaiola, ou a caixa de saldo:
			MsAguarde({|| lRetVin := VinculaCD() }, 'Vinculando', 'Efetuando vinculo com gaiola/caixa...')
			// Caso retorne positivo, é necessário sair da rotina:
			If lRetVin
				Return(.T.)
			EndIf
		EndIf

		If	(nPcsCxa >= nQtdPCxa /*(cAliasBar)->QTDCAIXA*/) .Or. lConfirma
			//If	(nPcsCxa == (cAliasBar)->Z7_QTDCAIX) .Or. lConfirma
			oDlg:Refresh()

			// Chamo rotina para gravação:
			GravaImpr(.F.)

			// Verificar necessidade de transferir itens da gaiola para a caixa de saldos:
			If lConfirma
				If lCDBudd
					If !SaldoCDGA(cPrBuff, .T.)
						Return (lRet := .T.)
					EndIf
				Else
					MsgBox('O item foi finalizado!', 'Êxito!', 'INFO')
				EndIf
			EndIf
		EndIf

		// Verifico necessidade de trocar de gaiola:
		If lCDBudd .And. !lConfirma
			// Verifica saldo depois de bipar:
			If !SaldoCD(cPrBuff, .T.)
				Return (lRet := .F.)
			EndIf
		EndIf
	Else
		lRet := .F.
	EndIf

	If lRet
		// Caso o operador efetuou qualquer alteração, deverá finalizar o pedido obrigatóriamente:
		lFinalizar	:= .T.
	EndIf

	If	Select(cAliasBar) <> 0
		(cAliasBar)->(DbCloseArea())
	EndIf

	cCodBar := Space(TamSx3('B1_CODBAR')[1])
	//oDlg:Refresh()
	//oDlg:SetFocus()
	oCodBar:SetFocus()
	//oCodBar:Refresh()

Return (lRet)

Static Function GravaImpr(lEtqParc)

	// Verifico mensagem de confirmação:
	If lEtqParc
		//IF !MsgBox("Deseja efetuar a impressão da etiqueta ["+AllTrim(cNumCxa)+"] parcial com "+AllTrim(Str(nPcsCxa))+" peça(s)?", "Impressão", "YESNO")
		nAviso		:= 3
		lMsHelpAuto := .F.
		//while nAviso == 3
		//	nAviso	:= AVISO("Atenção", "Deseja efetuar a impressão da etiqueta ["+AllTrim(cNumCxa)+"] parcial com "+AllTrim(Str(nPcsCxa))+" peça(s)?", {"Cancelar", "Confirma", "Escolha"}, 3)
		//EndDo
		IF MsgBox("Deseja efetuar a impressão da etiqueta ["+AllTrim(cNumCxa)+"] parcial com "+AllTrim(Str(nPcsCxa))+" peça(s)?", "Atenção", "YESNO")
			nAviso := 2
		EndIf
		If nAviso <> 2
			Return
		EndIf
	EndIf

	cVolFim:= iif(!empty(cVolINIA),cVolINIA,cVOLR)
	/* Grava os dados dos produtos encaixotados para geração de etiqueta e impressão */
	MsAguarde({|| B1120Grava() }, 'Gravando', 'Aguarde ... Gravando Etiqueta ' + cNumCxa + '...')
	//B1120Grava()

	// Valida quantidade na caixa na ZDU/ZDY:
	If lCDBudd
		If !ValidaEtq(cC5_Num, cNumCxa, cC6_Item)
			Return
		EndIF
	EndIf

	/* Grava os dados dos produtos encaixotados para geração de etiqueta e impressão */
	MsAguarde({|| B1120Reserv() }, 'Reservas', cC5_Num+'-'+cC6_Item+'/'+AllTrim(cC6_Produto) + '...')
	//B1120Reserv()
	lPrimVol:=.t.

	// Efetua impressão:
	//If Upper(AllTrim(ComputerName())) != "CPD10"
	MsAguarde({|| U_B1120Print(cC5_Num, cC6_Item, cC6_PRODUTO, cNumCxa, ZZ5->ZZ5_SeqEnc, SC5->C5_CLIENTE, SC5->C5_LOJACLI, nPcsCxa, cTotCxa, .F.) }, 'Imprimindo', 'Aguarde ... Imprimindo Etiqueta ' + cNumCxa + '...')
	//EndIf

	// Rotinas CD após impressão da etiqueta:
	If lCDBudd .Or. GetMv("BD_1120IPL")
		// Efetuo transferência:
		//MsAguarde({|| BuscaWS("&a=transfere", "&p="+AllTrim(cC5_Num)+"&l="+AllTrim(cC5_Num)+AllTrim(cPallet))+"&g="+AllTrim(cGaiola)+"&x="+AllTrim(cNumCxa) }, "Transferindo", "Transferindo itens CD...")
		// Verifico padrão do pallet:
		MsAguarde({|| U_B1120VPadr(cC5_Num, cPallet, cC6_Item) }, 'Aguarde...', 'Verificando pallet...')
	EndIf

	/* Executar a função para limpar todas as variáveis de tela */
	MsAguarde({|| B1120Limpar() }, 'Iniciando', 'Aguarde ... Iniciando Variáveis ...')

	lPrim     := .T.
	If SC5->C5_CLIENTE == '200056'
		B1120Alert()
		lGerou:=.T.
		lPrimV1:=.T.
		lPrimVol:=.T.
		cVOLR:='000000'
		cVolFim:= ''
		cVolPri:=''
		cVolIniA:=''
	EndIf

	If lCDBudd
		// Verifica item:
		ItemGaiola()
	EndIf

	// Retorno focus obrigatório:
	//oDlg:Refresh()
	//oDlg:SetFocus()
	//oCodBar:SetFocus()
	//oCodBar:Refresh()

Return

Static Function Fechar()

	If SC5->C5_CLIENTE == '200056' .AND. !lGerou

		B1120Alert()
		MsgStop("ATENÇÃO. DEVERÁ FINALIZAR A CAIXA ANTES DE FECHAR O SISTEMA!")
		oCodBar:SetFocus()
		RETURN()
	Else
		// Verifico se deseja finalizar o pedido:
		If lFinalizar
			// Chamo rotina de finalização:
			If U_B1120Fim(cC5_Num)
				(oDlg:End())
			EndIf
		Else
			(oDlg:End())
		EndIf

	EndIf
Return

Static Function B1120Limpar(lInicial)

	Default lInicial := .F.
	IF !lInicial
		IF SC5->C5_CLIENTE =='200056' .AND. !lPrimVol
			cCodBar	:= Criavar("B1_CODBAR",.F.)
			oCodBar:SetFocus()
			RETURN()
		ENDIF

		// No caso de encaixotamento no CD, preciso estornar os vinculos efetuados de etiquetas não finalizadas:
		//If lCDBudd
		//	MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando etiquetas não finalizadas...")
		//EndIf
	ENDIF

	lPrim	:= .T.

	nSaldoSB2 := CriaVar("B2_QATU",.F.)
	cCodBar	:= Criavar("B1_CODBAR",.F.)
	cCBAux		:= CriaVar("B1_CODBAR",.F.)
	cC6_ITEM 	:= Criavar("C6_ITEM",.F.)
	cGCor 		:= Space(TamSx3('ZT_COD')[1] + 3 + TamSx3('ZT_DESCRI')[1])
	cC6_PRODUTO:= Criavar("C6_PRODUTO",.F.)
	cB1_DESC	:= Criavar("B1_DESC",.F.)
	cCodCxa	:= Criavar("C6_CODTPCX",.F.)
	//	cCodCxa	:= Criavar("EE5_CODEMB",.F.)
	cC6_LOCAL	:= CriaVar("C6_LOCAL",.F.)
	cTpCxa 	:= Space(Len(cCodCxa) + 3 + TamSx3('Z7_TPCX')[1])
	cTotCxa	:= ' '
	//IF SC5->C5_CLIENTE == '233389' .AND.  cDUN14== nLETOTCX
	// cNumCxa	:= ' '
	//ENDIF
	cDescCxa	:= ''
	nQtdPcs	:= 0
	nTotCxa 	:= 0
	nQtdEnc   	:= 0
	nQtdRes	:= 0
	nQtdSal   	:= 0
	nPcsCxa 	:= 0
	//	lDun14:=.T.



	//cVolINI:= ''
	//cVolFim:= ''
	//cVolINIA:=''
	//cVOLR := ''
	// lPrimVol:=.T.
	//lPrimV1:=.T.

	aEmbal[1] 	:= "Qtd.Pcs. p/Pacote  - "
	aEmbal[2] 	:= "Qtd.Pcs. p/Caixa   - "
	aEmbal[3]	:= "Saldo em Estoque   - "
	aEmbal[4]	:= "Qtd.de Pacotes     - "

	aQuant[1] 	:= "Reservada          - " + Transform(nQtdEnc, cMascQtd)
	aQuant[2] 	:= "A Entregar do Item - " + Transform(nQtdEnc, cMascQtd)
	aQuant[3] 	:= "Encaixotada        - " + Transform(nQtdEnc, cMascQtd)
	aQuant[4] 	:= "------------------------------------"
	aQuant[5] 	:= "Saldo              - " + Transform(nQtdSal, cMascQtd)

	If	!lInicial
		oLBEmbal:aItems := aClone(aEmbal)
		oLBQuant:aItems := aClone(aQuant)
		oDlg:Refresh()
		oCodBar:SetFocus()
	EndIf

Return

User Function B1120Print(cPedido, cItem, cProduto, cCaixa, cSeqEnc, cCliente, cLoja, nQuant, cCxaTot, lReimpressao)

	Local aAreaSB1 		:= SB1->(GetArea())
	Local aAreaSA1 		:= SA1->(GetArea())
	Local aAreaSA7 		:= SA7->(GetArea())
	Local aAreaSC5 		:= SC5->(GetArea())
	Local aAreaSC6 		:= SC6->(GetArea())
	Local cPath	 		:= '\\127.0.0.1\ZEBRAZT'
	Local cPorta 		:= "LPT1"
	Local cDirEtq		:= Alltrim("\EtiqPrjEsp\Marisa\zpl\")
	Local cArquivo		:= ""   //cDirEtq + AllTrim(cCodBar) + '.prn'
	Local _i			:= 0
	Local cEtiqueta 	:= ""
	Local cEtiquetaZEG  := ""

	Private cTam		:=''
	Private cDescP 		:=""
	Private cDescA 		:=""
	Private cBarraCli   :=""
	Private cSapCode    :=""
	Private cCorProdCli :=""
	Private cTamProdCli :=""
	Private cDescL 		:=""
	Private cCorL 		:=""
	Private cDesccor	:=""
	Private cCODCor		:=""
	Private cCodInt		:=""
	Private cSemaPed	:= ''
	Private cC5_Num 	:=''
	Private cCodPVA 	:='' /// jonas
	Private cCodP		:=''
	Private cVolCxaR	:=''
	Private cRef		:=''
	Private cPacks		:=0

	Private nQtdPCxa	:=0
	Private nSOBRA		:=0
	Private cPISO		:=''
	Private cBANHO		:=''
	Private cJOGO		:=''
	Private cROSTO		:=''
	Private cCabTam1	:='' /// tipos de tamanho cama e banho
	Private cCabTam2	:=''
	Private cCabTam3	:=''
	Private cCabTam4	:=''
	Private cDep		:=''

	Private cSolt		:=''
	Private cCasalQ		:=''
	Private cCasalk		:=''
	Private cCasalSk	:=''
	Private cTpTaman	:=''
	Private cProdtorra	:=''
	Private cEtqCamicado:=''
	Private lLiberac 	:= .T.

	Default nQtdPcte	:= 0
	Default cPedido 	:= Space(TamSx3('C5_NUM')[1])
	Default cItem		:= Space(TamSx3('C6_ITEM' )[1])
	Default cProduto	:= Space(TamSx3('C6_PRODUTO')[1])
	Default cCaixa		:= Space(TamSx3('ZZ5_NUMETQ')[1])
	Default cSeqEnc		:= Space(TamSx3('ZZ5_SEQENC')[1])
	Default cCliente	:= Space(TamSx3('C5_CLIENTE')[1])
	Default cLoja		:= Space(TamSx3('C5_LOJACLI')[1])
	Default nQuant		:= 0
	Default cCxaTot		:= Space(3)
	Default cZZ5_TPETQ	:= 'PP'

	SB1->(DbSetOrder(1))
	lSB1 := SB1->(DbSeek(xFilial('SB1')+cProduto))

	SA1->(DbSetOrder(1))
	lSA1 := SA1->(DbSeek(xFilial('SA1')+cCliente+cLoja))

	SC5->(DbSetOrder(1))
	lSC5 := SC5->(DbSeek(xFilial('SC5')+cPedido))

	SC6->(DbSetOrder(1))
	lSC6 := SC6->(DbSeek(xFilial('SC6')+cPedido+cItem+cProduto))

	SA7->(DbSetOrder(1))
	lSA7 := SA7->(DbSeek(xFilial('SA7')+cCliente+cLoja+cProduto))

	ZZ5->(DbSetOrder(2))
	ZZ5->(xFilial("ZZ5")+cPedido+cSeqEnc+cCaixa+cItem)


	If (WinExec('net use '+cPorta+' '+cPath+' /persistent:yes exit')) != 0
		MsgStop('Erro ao executar comando Net Use para a porta '+cPorta+' no caminho '+cPath+' !!!')
		Return
	EndIf

	If !EMPTY(SC5->C5_CLIENTE)
		cC5_PedNum:= SC5->C5_PEDCLI
	EndIf

	// Verifico se existe código antigo cadastrado:
	If lCodAnt
		If !Empty(SA7->A7_CODCLI)
			// Verifico se esse código antigo está no cadastro de produtos:
			SB1->(DbSetOrder(5))
			SB1->(DbSeek(xFilial('SB1')+AllTrim(SA7->A7_CODCLI)))
			If SB1->(Found())
				cProduto	:= SB1->B1_COD
				// Caso esteja, eu considero impressão para aquele produto antigo:
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial('SB1')+cProduto))
			Endif
		EndIf
	EndIf

	If SC5->C5_CLIENTE $ '099834'
		SA7->(DbSetOrder(1))
		SA7->(DbSeek(xFilial('SA7')+cCliente+cLoja+cProduto))
		cC6_ProCl:= ALLTRIM(SA7->A7_CODCLI)
		If EMPTY(cC6_ProCl)
			MsgStop("PRODUTO X CLIENTE NÃO ENCONTRADO. FAVOR ENTRAR EM CONTATO COM A AREA COMERCIAL. APÓS INCLUSÃO DO PRODUTO, FAZER A REIMPRESSÃO DA ETIQUETA")
			Return
		EndIf

		cC5_PedNum:= SC5->C5_PEDCLI
		cCodPVA:= EtiqPern(ALLTRIM(cC5_PedNum),cC6_ProCl)
	EndIf

	nConfig 	:= 0
	If (nHandle := FT_FUSE(AllTrim(cDirArq+cArqConf))) == -1
		MsgStop('Não foi encontrado o arquivo de configuração de Etiquetas, Contate o Administrador !!!')
		Final()
	EndIf

	cArqIni := ''
	nTot	 := FT_FLASTREC()

	FT_FGOTOP()
	While !FT_FEOF()

		cLinCfg := FT_FREADLN()

		If SC5->C5_CLIENTE =='200056'
			If	Substr(cLinCfg,1,6) == cCliente
				If GetMv("BD_1120RCH")
					cArqIni := 'RCH_NOVO.TXT' // Jonas - 17/02/2023
				Else
					cArqIni := 'BUD_RCH.TXT'//AllTrim(Substr(cLinCfg,9,12))
				EndIf
				Exit
			EndIf
			//ELSEIF SC5->C5_CLIENTE == '233389a'
			//If	Substr(cLinCfg,1,6) == cCliente
			//  cArqIni := 'DUN14.TXT'//AllTrim(Substr(cLinCfg,9,12))
			//Exit
			//EndIf
		ELSE
			If	Substr(cLinCfg,1,6) == cCliente
				// Extrai o nome da etiqueta após o "="
				aEtiqueta := STRTOKARR(cLinCfg, "=")
				If Len(aEtiqueta) > 1
					cEtiqueta = aEtiqueta[2]

					// Busca o nome do arquivo de etiquetas do cliente:
					aEtiqueta := STRTOKARR(cEtiqueta, " ")
					If Len(aEtiqueta) > 0
						cEtiqueta = aEtiqueta[1]
					EndIf
				EndIf

				cArqIni := AllTrim(cEtiqueta) // Remove espaços em branco e quebras de linha
				Exit
			EndIf
		ENDIF
		FT_FSKIP()

	EndDo

	nHandle  	:= 0
	cArqIni		:= cDirArq+cArqIni
	If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
		If lLiberac
			// No caso de pedidos reservados, se não existir arquivo de configuração, utilizo o EAN13 parão:
			cArqIni	:= 'EAN13.TXT'
		Else
			MsgStop('Não foi encontrado arquivo de configuração para este Cliente, '+cArqIni+' Verifique !!!')
			Final()
		EndIf
	EndIf

	cNomeClie 	:= AllTrim(SA1->A1_NOME)
	cNomeReduz 	:= AllTrim(SA1->A1_NREDUZ)
	cEndereco 	:= AllTrim(SA1->A1_END) //+ ' - ' + AllTrim(SA1->A1_BAIRRO)
	cCEP 		:= Transform(SA1->A1_CEP, PesqPict("SA1","A1_CEP"))
	cMun 		:= AllTrim(SA1->A1_MUN)
	cUF			:= AllTrim(SA1->A1_EST)
	cTelefone	:= AllTrim(SA1->A1_TEL)
	cDataEmbal	:= DtoC(ZZ5->ZZ5_DATA)
	cProduto	:= PadC(AllTrim(SB1->B1_COD),18,' ')
	cDescri	:= AllTrim(SC6->C6_DESCRI)
	cQuant		:= AllTrim(Transform(nQuant, '@E 999,999'))
	cCodBar		:= AllTrim(SB1->B1_CODBAR)
	cCodCli	:= ''
	cDescCli	:= ''
	cDescCor	:= ''
	cCodEmb	:= ''
	cPedCliP	:= ''
	cCodPV		:= ''
	cCodBR		:= ''
	cProdutoP	:= ''
	cCodBarR 	:= ''
	cQuantR 	:= '' // riachuelo
	//cCxaTot 	:= '' // riachuelo
	cCod3		:= ''
	cCodT		:= ''
	cVolTot  	:= ''
	cDesccx    := ''

	// --- Código do Produto do Cliente
	// -- Etna, Avenida, Ascis, SS COM. DE COSMETICOS, Calvin Klein
	If cCliente == "477066" /*.Or. cCliente == "249017"*/.Or. cCliente == "094114" .Or. cCliente == "819201" .Or. cCliente == "278350" .Or. cCliente == "296319" .Or. cCliente == "214549" .Or. cCliente == "685030" .Or. cCliente == "418806"
		cProduto	:= AllTrim(SA7->A7_CODCLI)
		cProdtorra	:= AllTrim(SA7->A7_PRODUTO)
	EndIf

	If	!Empty(SA7->A7_DESCCLI)	// --- Código do Produto do Cliente
		cDescri	:= AllTrim(SA7->A7_DESCCLI)
	EndIf

	//06051982 ETIQUETA LINS FERRAO
	/*If cCliente == "345021"
		cDescri	:= AllTrim(SA7->A7_CODCLI)+" "+AllTrim(SA7->A7_DESCCLI)+" "+AllTrim(SA7->A7_COR)
	EndIf*/
	//06051982 TERMINO

	If cCliente == "278350" .Or. cCliente == "296319" //SS COM. DE COSMETICOS, Calvin Klein
		cCorC	:= AllTrim(SA7->A7_COR)
	EndIf

	IF cCliente $ '296319' // Calvin Klein
		cCodBar := AllTrim(SA7->A7_BARRA)
	ENDIF

	IF cCliente $ '473223' // Cliente Dakotton
		cProduto    := ALLTRIM(SA7->A7_BARRA)
		cDescri 	:= ALLTRIM(SA7->A7_DESCCLI)
		cRef        := ALLTRIM(SA7->A7_DESCETQ)

	ENDIF

	// ------- Thiago para Imprimir Etiquetas Zelo:
	If cCliente $ '558342' // -- Somente ZELO:
		nVolume := GetMv("MV_NUMZELO")
		cDescCor	:= ""
		cDescri 	:= ALLTRIM(SC6->C6_DESCRI)
		cCodCli		:= ALLTRIM(SC6->C6_PROCLI)

		If Empty(cCodCli) .And. !Empty(SA7->A7_CODCLI)
			// Caso no C6_PROCLI não esteja preenchido, busco do SA7 e efetuo alteração no SC6:
			cCodCli	:= AllTrim(SA7->A7_CODCLI)
			TCSQLEXEC("UPDATE SC6010 SET C6_PROCLI = '"+AllTrim(cCodCli)+"' WHERE C6_FILIAL = '01' AND C6_NUM = '"+SC6->C6_NUM+"' AND C6_ITEM = '"+SC6->C6_ITEM+"' AND SC6010.D_E_L_E_T_ = '' ")
		EndIf
		cCodBar	:= ALLTRIM(SB1->B1_CODBAR)

		//Rodrigo - Se B1_CODCOR em branco busca pelo codigo do produto
		If !Empty(Alltrim(SB1->B1_CODCOR))
			SZT->(DbSetOrder(3))
			SZT->(DbSeek(xFilial('SZT')+xFilial('SZT')+SB1->B1_CODCOR))
			If	SZT->(Found())
				cDescCor	:= ALLTRIM(SZT->ZT_DESCRI)
				If ALLTRIM(cDescCor) == "PADRAO" //Se cor for PADRAO trazer a referencia, conforme solicitado pela Tatiane
					cDescCor := "P."+ALLTRIM(SZT->ZT_REF)
				EndIf
			EndIf
		Else
			SZT->(DbSetOrder(2))
			SZT->(DbSeek(xFilial('SZT')+xFilial('SZT')+SUBSTRING(SB1->B1_COD,11,4)))
			If	SZT->(Found())
				cDescCor  := ALLTRIM(SZT->ZT_DESCRI)
				If 	ALLTRIM(cDescCor) == "PADRAO"//Se cor for PADRAO trazer a referencia, conforme solicitado pela Tatiane
					cDescCor := "P."+ALLTRIM(SZT->ZT_REF)
				EndIf
			EndIf
		Endif
		//Fim Rodrigo

		If !Empty(cDescCor)
			cDescCli	+= " (" + cDescCor + ")"
		EndIf

		cCNPJ		:= "86047198"
		cQtd 		:= Replicate("0",3 - Len(Alltrim(Str(nQuant))))+Alltrim(Str(nQuant))
		cQtdVer	:= ALLTRIM(Str(nQuant))

		If !Empty(nQuant)
			nVolume := nVolume + 1
			PutMv('MV_NUMZELO',nVolume)
		EndIf

		cVolume	:= Replicate("0",8 - Len(Alltrim(Str(nVolume))))+Alltrim(Str(nVolume))
		cCodBar	:= '>;' + cCNPJ + cVolume + cQtd + cCodBar
		cDescCli	:= "PRD: " + cCodCli  + " - QTD: " + cQtdVer  + " - VOL: " + cVolume
		cProduto	:= PadC(AllTrim(cCodCli),18,' ')
	EndIf

	ZCN->(DbSetOrder(2))
	ZCN->(DbSeek(xFilial('ZCN')+SA1->A1_CODENCX+Left(SB1->B1_COD,8)+SUBSTR(SB1->B1_COD,15,4)))
	If	ZCN->(Found())
		cCodEmb := ZCN->ZCN_CODEMB
		nQtdPCxa:= ZCN->ZCN_QTDE
		If SC5->C5_CLIENTE == '200056' .And. !Empty(ZCN->ZCN_QTDPCT)
			nQtdPcte:= ZCN->ZCN_QTDPCT
		ENDIF
	EndIf




	//////////////////////////////////////////////////// Pernanbucanas///////////////////////////////////////////////////
	If 	cCliente $ '099834' // Pernambucanas:

		cPedCliP := AllTrim(SC5->C5_PEDCLI) + '-' + SC6->C6_ITEM
		//Private cC5_Num := Space(TamSx3('C5_NUM')[1])
		//	cDescP := ''
		//	cCodP	:= ''
		If	lSA7
			cDescP		:= AllTrim(SA7->A7_DESCETQ)
			If Empty(cDescP)
				cDescP	:= AllTrim(SA7->A7_DESCCLI)
			EndIf
			cCodP		:= LEFT(ALLTRIM(SA7->A7_CODCLI), 6)
			//cCodP		:= LEFT(ALLTRIM(SA7->A7_BARRA), 6)
		EndIf

		//cCodP		+= "0000010"
		//cCodP		:= "0"+cCodP
		//cCodPV		:= Transform(Str(Val(cCodP),13), "@R 999999.99.99.99.9" )
		//	cProdutoP	:= ALLTRIM(cDescP)
		//If 	Empty(cProdutoP)
		//	cProdutoP	:= "Problema com Tabela Cliente x Produto"
		//EndIf
		//// ALTERADO PARA LER O ARQUIVO DA PERNAMBUCANAS PARA GERAR O ARTIGO E DESCRIÇÃO - JONAS - 28/08/2014

		//cCodPVA:= EtiqPern(cC5_Num)
		cCodPV:= substr(cCodPVA,1,13)
		cCodBR:= substr(cCodPV,1,6)+ "-"+substr(cCodPV,8,2)+"-"+substr(cCodPV,10,2)+"-"+substr(cCodPV,11,2)+"-"+substr(cCodPV,13,1)
		cProdutoP:= substr(cCodPVA,14,29)
		//cProdutoP:= substr(cCodPVA,14,29)

		cCodBar:= ALLTRIM('0'+cCodPV)
		//		cCodBar:= '>;' + ALLTRIM(cCodPV)
		//cCodBar:= '>;' + ALLTRIM(cCodP)
	Endif
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	If	cCliente $ '200056/819201/418806' // Riachuelo
		//Default cCaixa	:= cVolr//Space(TamSx3('ZZ5_EPVOLS')[1])
		Private cCorProd    := '' // riachuelo
		Default cC5_Num := Space(TamSx3('C5_NUM')[1])
		cC5_Num := Space(TamSx3('C5_NUM')[1])
		SC5->(DbSeek(xFilial('SC5')+cPedido))
		cProduto := AllTrim(SA7->A7_CODCLI)
		cCodBarR := '>:' + AllTrim(SA7->A7_CODCLI) + iif(len(cCxaTot)=4,StrZero(Val(cCaixa),4),StrZero(Val(cCaixa),3)) + cCxaTot
		cQuantR  := '['+StrZero(Val(cQuant),4)+']'
		cVolTot  := iif(len(cCxaTot)=4,StrZero(Val(cCaixa),4),StrZero(Val(cCaixa),3))+'/'+cCxaTot
		//		cVolTot  := StrZero(Val(cCaixa),5)+'/'+cCxaTot
		cSemaPed := SC5->C5_SEMAPED
		cPedCli:= SC5->C5_PEDCLI
		cCDLoja:= SA1->A1_CDLOJA
		cCorProd := ALLTRIM(SA7->A7_COR)
		if ((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa) - int(((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa)) == 0
			cTotCxaR:= StrZero((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa,6)
		else
			nSOBRA:=  ((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa) - int(((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa))
			nSOBRA:=  ((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa) - nSOBRA

			//cTotCxaR:= STR(((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa))
			cTotCxaR:= (nSOBRA) +1
			cTotCxaR:= STRZERO(cTotCxaR,6)
		endif
		cVolCxaR:= cCaixa +'/'+ cTotCxaR //IIF(EMPTY(nSOBRA),STRZERO(cTotCxaR,6),cTotCxaR)
		cPacks:=0
		If VAL(cQuant) < nQtdPCxa
			cPacks:= VAL(cQuant)
		Endif

		If GetMv("BD_1120RCH")
			//// BUSCAR INFORMAÇÕES DA ETIQUETA RIACHUELO - JONAS 24/08/2021
			If (Select('VOL')<> 0)
				dbSelectArea('VOL')
				dbCloseArea()
			EndIf

			IF !lReimpressao
				cVolEtq:=' '
			Else
				cVolEtq:=  cCaixa
			EndIf

			BeginSql Alias 'VOL'
				%noparser%

				SELECT
					TOP 1 ZRR_VOLUME,
					ZRR_BARRCD,
					C6_PROCLI,
					C5_PEDCLI,
					ZRR.R_E_C_N_O_ AS REC,
					CAST(
						SUBSTRING(ZRR_VOLUME, 1, CHARINDEX('/', ZRR_VOLUME) - 1) AS INT
					) SEQ1,
					CAST(
						SUBSTRING(
							ZRR_VOLUME,
							CHARINDEX('/', ZRR_VOLUME) + 1,
							LEN(ZRR_VOLUME)
						) AS INT
					) AS SEQ2
				FROM
					%Table:SC5% C5 (NOLOCK)
				INNER JOIN %Table:SC6% C6 (NOLOCK)
				ON C6_FILIAL = %xFilial:SC6%
					AND C6_NUM = C5_NUM
					AND C6.%NotDel%
				INNER JOIN %Table:ZRR% ZRR (NOLOCK)
				ON ZRR_FILIAL = %xFilial:ZRR%
					AND ZRR_ARTIGO = C6_PROCLI
					AND ZRR_NRAUXI = C5_PEDCLI
					AND ZRR.%NotDel%
				INNER JOIN %Table:ZZ5% ZZ5 (NOLOCK)
				ON ZZ5_FILIAL = %xFilial:ZZ5%
					AND ZZ5_PEDIDO = C6_NUM
					AND ZZ5_PRODUT = C6_PRODUTO
					AND ZZ5_ITEM = C6_ITEM
					AND ZZ5.%NotDel%
				WHERE
					C5.%NotDel%
					AND C5_FILIAL = %xFilial:SC5%
					AND C5_NUM = %Exp:cPedido%
					AND C6_PROCLI = %Exp:cProduto%
					AND ZRR_NUMETQ = %Exp:cVolEtq%
				ORDER BY
					SEQ1,
					SEQ2
			EndSql
			dbSelectArea('VOL')
			IF !lReimpressao
				cQuery := ""
				cQuery += "UPDATE " + RETSQLNAME("ZRR") + " SET ZRR_NUMETQ  = '"+cCaixa+"' "
				cQuery += "WHERE D_E_L_E_T_ = '' "
				cQuery += "AND R_E_C_N_O_ = '"+ALLTRIM(STR(VOL->REC))+"' "
				cQuery += "AND ZRR_VOLUME = '"+ALLTRIM(VOL->ZRR_VOLUME)+"' "
				cQuery += "AND ZRR_BARRCD = '"+ALLTRIM(VOL->ZRR_BARRCD)+"' "
				cQuery += "AND ZRR_NRAUXI = '"+ALLTRIM(VOL->C5_PEDCLI)+"' "
				cQuery += "AND ZRR_CDMERC = '"+ALLTRIM(VOL->C6_PROCLI)+"' "
				TCSQLEXEC(cQuery)
			EndIf

			If (Select('ETQRCH')<> 0)
				dbSelectArea('ETQRCH')
				dbCloseArea()
			EndIf

			BeginSql Alias 'ETQRCH'
				SELECT
					ZRR_ITEM,
					ZRR_VOLUME,
					ZRR_CDMERC,
					ZRR_BARRCD,
					ZRR_FLUXO,
					ZRR_QTD,
					ZRR_DCO,
					ZRR_CEPDES,
					ZRR_DTBARR,
					ZRR_CNPJ,
					ZRR_ENDREC,
					ZRR_TPPROD,
					ZRR_NRAUXI,
					ZRR_ARTIGO,
					ZRR_DEST,
					ZRR_LOJA
				FROM
					%Table:SC5% C5 (NOLOCK)
				INNER JOIN %Table:SC6% C6
				ON C6_FILIAL = %xFilial:SC6%
					AND C6_NUM = C5_NUM
					AND C6.%NotDel%
				INNER JOIN %Table:ZRR% ZRR
				ON ZRR_FILIAL = %xFilial:ZRR%
					AND ZRR_CDMERC = C6_PROCLI
					AND ZRR_NRAUXI = C5_PEDCLI
					AND ZRR.%NotDel%
				WHERE
					C5.%NotDel%
					AND C5_FILIAL = %xFilial:SC5%
					AND C5_PEDCLI = %Exp:ALLTRIM(VOL->C5_PEDCLI)%
					AND C6_PROCLI = %Exp:ALLTRIM(VOL->C6_PROCLI)%
					AND ZRR_VOLUME = %Exp:ALLTRIM(VOL->ZRR_VOLUME)%
					AND ZRR_BARRCD = %Exp:ALLTRIM(VOL->ZRR_BARRCD)%
			EndSql

			cDest      := ALLTRIM(ETQRCH->ZRR_LOJA)
			cTPProd    := ALLTRIM(ETQRCH->ZRR_TPPROD)
			nVolRCH    := ALLTRIM(ETQRCH->ZRR_VOLUME)
			nDCO       := ALLTRIM(ETQRCH->ZRR_DCO)
			cCodBarRCH := ALLTRIM(ETQRCH->ZRR_DTBARR)
			IF ALLTRIM(SUBSTR(ETQRCH->ZRR_BARRCD,1,2)) =='LG'
				cCDBarArt  := ALLTRIM(SUBSTR(ETQRCH->ZRR_BARRCD,2,30))
			Else
				cCDBarArt  := ALLTRIM(SUBSTR(ETQRCH->ZRR_BARRCD,1,30))
			EndIf
			cArtigo    := ALLTRIM(ETQRCH->ZRR_ARTIGO)
			CPedRCH    := ALLTRIM(ETQRCH->ZRR_NRAUXI)
			cENDREC    := ALLTRIM(ETQRCH->ZRR_ENDREC)
			cCEPDES    := ALLTRIM(ETQRCH->ZRR_CEPDES)
			nCNPJ      := ALLTRIM(ETQRCH->ZRR_CNPJ)
			nQuantR    := ETQRCH->ZRR_QTD
			///////////////////////////////////////////////
		EndIf
	EndIf

	If	cCliente == '079117' // Alpargatas
		cBarraCli := AllTrim(SA7->A7_DUN14)
		cCorProdCli := ALLTRIM(SA7->A7_CDCOLOR)
		cSapCode := AllTrim(SA7->A7_SAPCODE)
		cTamProdCli := ALLTRIM(SA7->A7_SIZE)
	EndIf

	If cCliente == '732175'

		cCodP:= ALLTRIM(SA7->A7_BARRA)
		cCod1:= substr(cCodP,1,1)
		cCod2:= substr(cCodP,2,2)
		cCod3:= substr(cCodP,4,6)
		cCod4:= substr(cCodP,10,1)
		cCodT:= (cCod1 + '.' + cCod2 +'  '+ cCod3 + '.' + cCod4)

		cDescA		:= AllTrim(SA7->A7_DESCETQ)
		cDescP	    := AllTrim(SA7->A7_DESCCLI)
		cProduto    := AllTrim(SA7->A7_CODCLI)

	Endif


	If cCliente $ '094114/819201'

		If	Select('C0R')<>0
			COR->(DbCloseArea())
		EndIf

		BeginSql Alias 'COR'
			SELECT
				ZT_COD,
				ZT_DESCRI,
				ZT_COD + '-' + ZT_DESCRI AS COR,
				A7_DESCETQ
			FROM
				%Table:SA7% A7 (NOLOCK)
			INNER JOIN %Table:SB1% B1
			ON B1_COD = A7_PRODUTO
				AND B1.%NotDel%
			INNER JOIN %Table:SZT% ZT
			ON ZT.ZT_CODCOR = B1.B1_CODCOR
				AND ZT.D_E_L_E_T_ = ''
			WHERE
				A7.%NotDel%
				AND A7_CLIENTE IN ('094114', '819201')
				AND A7_PRODUTO = %Exp:SB1->B1_COD%
		EndSql

		While !COR->(Eof())
			cDescA := AllTrim(COR->A7_DESCETQ)
			cCorL  := Alltrim(COR->COR)
			cCODCor:= ALLTRIM(COR->ZT_COD)
			cDesccor:= Alltrim(COR->ZT_DESCRI)
			COR->(DbSkip())
		ENDDO
		COR->(DbCloseArea())
	Endif

	IF cCliente $ '819201'

		If	Select('TAMANHO')<>0
			dbSelectArea('TAMANHO')
			dbCloseArea()
		EndIf

		BeginSql Alias 'TAMANHO'
			%noparser%

			SELECT
				B1_COD,
				B1_TIPO,
				CASE
					WHEN SB1.B1_DESC LIKE '%PES%'
						THEN 'PISO'
					WHEN SB1.B1_DESC LIKE '%BANHO%'
						THEN 'BANHO'
					WHEN SB1.B1_DESC LIKE '%ROSTO%'
						THEN 'ROSTO'
					WHEN SB1.B1_DESC LIKE '%JOGO%'
						THEN 'JOGO-BANHO'
					ELSE 'UNICO'
				END AS DESCRI
			FROM
				%Table:SB1% SB1 (NOLOCK)
			WHERE
				SB1.%NotDel%
				AND SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = %exp:SB1->B1_COD%
				AND B1_UM IN ('PC', 'JG')
				AND B1_TIPO = 'AF'
		EndSql

		if !empty(TAMANHO->DESCRI)
			cCabTam1:="UNICO"
			cCabTam2:="B"
			cCabTam3:="R"
			cCabTam4:="P"
			cTpTaman:= "LINHA - BANHO"
			cDep:="72"
		endif

		if (TAMANHO->DESCRI)== 'JOGO-BANHO'
			cCabTam1:="JOGO"
			cCabTam2:="B"
			cCabTam3:="R"
			cCabTam4:="P"
			cTpTaman:= "LINHA - BANHO"
			cDep:="72"
		endif

		IF ALLTRIM(TAMANHO->DESCRI) == 'PISO'
			cPISO:= "X"

		ELSEIF ALLTRIM(TAMANHO->DESCRI) == 'BANHO'
			cBANHO:= "X"

		ELSEIF ALLTRIM(TAMANHO->DESCRI) == 'ROSTO'
			cROSTO:= "X"
		ELSEIF ALLTRIM(TAMANHO->DESCRI) == 'JOGO-BANHO'
			cJOGO:= "X"

		ENDIF


		If	Select('CAMA')<>0
			dbSelectArea('CAMA')
			dbCloseArea()
		EndIf

		BeginSql Alias 'CAMA'
			%noparser%

			SELECT
				B1_COD,
				B1_TIPO,
				CASE
					WHEN SB1.B1_DESC LIKE '%QUEEN%'
						THEN 'CASALQ'
					WHEN SB1.B1_DESC LIKE '%SUPER KING%'
						THEN 'CASALSK'
					WHEN SB1.B1_DESC LIKE '%S.KING%'
						THEN 'CASALSK'
					WHEN (
						SB1.B1_DESC LIKE '%KING%'
						AND SB1.B1_DESC NOT LIKE '%COLCHA KING%'
					) THEN 'CASALK'
					WHEN SB1.B1_DESC LIKE '%JOGO DE CAMA CASAL%'
						THEN 'CASALK'
					WHEN SB1.B1_DESC LIKE '%SOLTEIRO%'
						THEN 'SOLT'
					WHEN SB1.B1_DESC LIKE '%220/240%'
						THEN 'CASALK'
					WHEN SB1.B1_DESC LIKE '%240/260%'
						THEN 'CASALQ'
					WHEN SB1.B1_DESC LIKE '%260/280%'
						THEN 'CASALSK'
					WHEN SB1.B1_DESC LIKE '%280/260%'
						THEN 'CASALSK'
					WHEN SB1.B1_DESC LIKE '%260/240%'
						THEN 'CASALQ'
					WHEN SB1.B1_DESC LIKE '%180/240%'
						THEN 'SOLT'
					WHEN SB1.B1_DESC LIKE '%COLCHA KING%'
						THEN 'CASALSK'
					WHEN SB1.B1_DESC LIKE '%COLCHA CASAL%'
						THEN 'CASALK'
					WHEN SB1.B1_DESC LIKE '%COLCHA SOLTEIRO%'
						THEN 'SOLT'
					ELSE 'OUTROS'
				END AS DESCRI,
				(
					SELECT
						'50/70'
					FROM
						%Table:SB1% SB1 (NOLOCK)
					WHERE
						SB1.B1_FILIAL = %xFilial:SB1%
						AND SB1.%NotDel%
						AND SB1.B1_COD = %exp:SB1->B1_COD%
						AND B1_DESC LIKE '%50/70%'
						AND LEFT(B1_DESC, 11) LIKE '%TRAVESSEIRO%'
				) AS DESCTRAV1,
				(
					SELECT
						'50/90'
					FROM
						%Table:SB1% SB1 (NOLOCK)
					WHERE
						SB1.B1_FILIAL = %xFilial:SB1%
						AND SB1.%NotDel%
						AND SB1.B1_COD = %exp:SB1->B1_COD%
						AND B1_DESC LIKE '%50/90%'
						AND LEFT(B1_DESC, 11) LIKE '%TRAVESSEIRO%'
				) AS DESCTRAV2
			FROM
				%Table:SB1% SB1 (NOLOCK)
			WHERE
				SB1.%NotDel%
				AND SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_COD = %exp:SB1->B1_COD%
				AND B1_UM IN ('JG', 'PC')
		EndSql

		if !empty(CAMA->DESCRI) .AND. CAMA->DESCRI<>'OUTROS'
			cTpTaman:= "LINHA - CAMA"
			cCabTam1:="SOLT."
			cCabTam2:="Q"
			cCabTam3:="C"
			cCabTam4:="SK"
			cDep:="62"
		endif

		if !EMPTY(CAMA->DESCTRAV1)
			cTpTaman:= "LINHA - CAMA"
			cCabTam1:= CAMA->DESCTRAV1
			cDep:="62"
		endif

		if !empty(CAMA->DESCTRAV2)
			cTpTaman:= "LINHA - CAMA"
			cCabTam1:= CAMA->DESCTRAV2
			cDep:="62"
		endif

		IF ALLTRIM(CAMA->DESCRI) == 'SOLT' .OR.  ALLTRIM(CAMA->DESCTRAV1)== '50/70' .OR. ALLTRIM(CAMA->DESCTRAV2)== '50/90'
			cSolt:= "X"

		ELSEIF ALLTRIM(CAMA->DESCRI) == 'CASALQ'
			cCasalq:= "X"

		ELSEIF ALLTRIM(CAMA->DESCRI) == 'CASALK'
			cCasalK:= "X"

		ELSEIF ALLTRIM(CAMA->DESCRI) == 'CASALSK'
			cCasalsk:= "X"

		ENDIF
	EndIf

	If cCliente $ '960950/015006/200418/945684/917624/152403/508411'

		cCodInt	:= SC5->C5_NUM + "-" + StrZero(val(cCaixa), 6) + "-" + cItem
		EE5->(dbSeek(xFilial("EE5")+SC6->C6_CODTPCX))

		cDesccx:= ALLTRIM(SUBSTR(EE5->EE5_DESC,1,8))
	EndIf

	If	cCliente == '002339'
		cEtqCamicado	:= U_BUD1158(cPedido, cItem, cProduto, cCaixa, cSeqEnc, cCliente, cLoja, nQuant, cCxaTot, lReimpressao)

		// Caso não encontre a etiqueta da camicado:
		if AllTrim(cEtqCamicado) == ""

			MsgStop("Não foi encontrado o arquivo de etiquetas que deve ser enviado pelo cliente! Gentileza entrar em contato com o comercial.")

			// Excluo a atual etiqueta gerada em caso de erro:
			cQuery := ""
			cQuery += "UPDATE " + RETSQLNAME("ZZ5") + " SET D_E_L_E_T_ = '*' "
			cQuery += "WHERE "+RETSQLNAME("ZZ5")+".D_E_L_E_T_ = '' "
			cQuery += "AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
			cQuery += "AND ZZ5_PEDIDO = '"+cPedido+"' "
			cQuery += "AND ZZ5_ITEM = '"+cItem+"' "
			cQuery += "AND ZZ5_NUMETQ = '"+cCaixa+"' "
			cQuery += "AND ZZ5_PRODUT = '"+cProduto+"' "
			TCSQLEXEC(cQuery)

			Final()
			Return
		Else
			// Busco código de barras camicado (solicitação Sr. Jairo):
			If (Select("TC1120") <> 0)
				dbSelectArea("TC1120")
				dbCloseArea()
			EndIf
			cQuery := " SELECT DISTINCT TOP 1 ZCP_CCODBA "
			cQuery += " FROM "+RetSqlName("ZCP")+" "
			cQuery += " WHERE ZCP_FILIAL = '"+xFilial("ZCP")+"' "
			cQuery += " AND ZCP_PEDIDO = '"+cPedido+"' "
			cQuery += " AND ZCP_ITEM = '"+cItem+"' "
			cQuery += " AND ZCP_PRODUT = '"+cProduto+"' "
			cQuery += " AND ZCP_CODCAI = '"+cCaixa+"' "
			cQuery += " AND "+RetSqlName("ZCP")+".D_E_L_E_T_ = '' "
			TCQuery cQuery NEW ALIAS "TC1120"
			If !TC1120->(EOF())
				cCodBar	:= '>;' + AllTrim(TC1120->ZCP_CCODBA)
			EndIf
		EndIf
	EndIf

	If cCliente $ '189288' ///Marisa - JONAS KOSLOWSKI 08/04/2022

		cArq	:= cDirEtq + AllTrim(cCodBar) + '.prn'
		cDir	:= cDirEtq
		aFile  	:= {}
		cCODTam:= Posicione("SB1", 5, xFilial("SB1")+cCodBar, "B1_CODTAM")
		cTam:= Posicione("SZN", 4, xFilial("SZN")+cCODTam, "ZN_DESCRI")
		aFile  	:= Directory(cDir+AllTrim(cCodBar) + '.prn')
		cCodCli		:= ALLTRIM(SC6->C6_PROCLI)

		_i 		:= 0

		For _i := 1 To Len(aFile)

			// Variaveis utilizadas na Leitura do Arquivo Texto.
			// nHandle  := 0
			nHandle := FT_FUse(cArq)
			cArquivo := Alltrim(aFile[_i][1])
			cLinha   := ""
			lprin:=.F.

			If (nHandle := FT_FUSE(AllTrim(cDir+cArquivo))) == -1
				Return
			EndIf

			Procregua(RecCount())
			FT_FGOTOP()
			cIMG:=''
			While !FT_FEOF()

				cLinha := FT_FREADLN()
				//cIMG:=''

				If  Substr(cLinha,1,12) <> "^FO32,32^GFA" .AND. !lprin
					FT_FSKIP()
					Loop

				EndIf


				If Substr(cLinha,1,14) == "^FO21,16^GB736"
					FT_FSKIP()
					exit
				EndIf

				If  Substr(cLinha,1,12) == "^FO32,32^GFA" .OR. Substr(cLinha,1,12) == "^FO64,32^GFA"

					lprin:=.T.
				EndIF

				If lprin
					cIMG+=cLinha
				EndIF
				FT_FSKIP()
			Enddo
			FT_FUSE()

		Next _i
	EndIF


	IF cCliente $ '189288'

		nConfig 	:= 0
		If (nHandle := FT_FUSE(AllTrim(cDirArq+cArqConf))) == -1
			MsgStop('Não foi encontrado o arquivo de configuração de Etiquetas, Contate o Administrador !!!')
			Final()
		EndIf

		cArqIni := ''
		nTot	 := FT_FLASTREC()

		FT_FGOTOP()
		While !FT_FEOF()

			cLinCfg := FT_FREADLN()


			If	Substr(cLinCfg,1,6) == cCliente
				cArqIni := AllTrim(Substr(cLinCfg,8,10))
				Exit
			EndIf

			FT_FSKIP()

		EndDo

		nHandle  	:= 0
		cArqIni		:= cDirArq+cArqIni
		If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
			If lLiberac
				// No caso de pedidos reservados, se não existir arquivo de configuração, utilizo o EAN13 parão:
				cArqIni	:= 'EAN13.TXT'
			Else
				MsgStop('Não foi encontrado arquivo de configuração para este Cliente, '+cArqIni+' Verifique !!!')
				Final()
			EndIf
		EndIf

	ENDIF


	//06051982 CLIENTES QUE NÃO DEVEM GERAR A NOSSA ETIQUETA, ALTERADO EM 15072021 #524;
	If !cCliente $ AllTrim(GetMv("BD_1120ETQ"))
		MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
		MSCBCHKSTATUS(.F.)

		/////////////////////////IMPRESSAO MODELO ZEBRA ZT230
		/// 2300 (ZPL)///////////////////////////////////
		MSCBINFOETI("Etiquetas Expedição - Projeto Especial ","PROJETO ESPECIAL")
		MSCBBEGIN(1,6,800) // 800

		cLinha   	:= ""
		nTot		:= FT_FLASTREC()
		//Private cCorProd    := '' // riachuelo
		//Private cCodP:=''

		cCorProd    := '' // riachuelo
		cCodP:=''

		SC5->(DbSeek(xFilial('SC5')+cPedido))
		cCDLoja:= SA1->A1_CDLOJA
		cPedCli:= SC5->C5_PEDCLI
		SB1->(DbSetOrder(5))
		SB1->(DbSeek(xFilial('SB1')+cCodBar))
		If	cCliente $'451932/087323/251285/418806'
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial('SC6')+cPedido+cItem+cProduto))
			cCodCli	:= AllTrim(SA7->A7_CODCLI)
			cCorL:= Posicione("SZT", 3, xFilial("SZT")+SB1->B1_CODCOR, "ZT_DESCRI")
			cPedcLIM:= SC6->C6_NUMPCOM
			cCODTam:= Posicione("SB1", 5, xFilial("SB1")+cCodBar, "B1_CODTAM")
			cTam:= Posicione("SZN", 4, xFilial("SZN")+cCODTam, "ZN_DESCRI")
			cVolTot  := iif(len(cCxaTot)=4,StrZero(Val(cCaixa),4),StrZero(Val(cCaixa),3))+'/'+cCxaTot

		ENDIF

		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()

			// Imprime código da etiqueta:
			cLinha	:= StrTran(cLinha, "%COD_ETIQUETA%", AllTrim(cZZ5_TPETQ)+"-"+AllTrim(cPedido)+"-"+AllTrim(cCaixa))

			// Alimenta variáveis do azrquivo:
			If	Substr(cLinha,1,4) == '^PQ1'
				MSCBWrite('^FN1^FD' + cNomeClie + '^FS')
				MSCBWrite('^FN2^FD' + cPedido + '^FS')
				MSCBWrite('^FN3^FD' + cEndereco + '^FS')
				MSCBWrite('^FN18^FD' + cCEP + ' - ' + cMun + ' - ' + cUF + '^FS')
				MSCBWrite('^FN4^FD' + cTelefone + '^FS')
				MSCBWrite('^FN5^FD' + cDataEmbal+ '^FS')
				MSCBWrite('^FN6^FD' + cItem + '^FS')
				MSCBWrite('^FN7^FD' + cProduto  + '^FS')
				MSCBWrite('^FN8^FD' + cDescri   + '^FS')
				MSCBWrite('^FN9^FD' + cQuant + '^FS')
				MSCBWrite('^FN10^FD' + cCodBar + '^FS')
				MSCBWrite('^FN11^FD' + '>;' + B1120Dun14(cCodBar) + '^FS') // Codigo de Barras da Embalagem Havan
				MSCBWrite('^FN12^FD' + AllTrim(ZZ5->ZZ5_ACONDI) + '^FS')
				MSCBWrite('^FN13^FD' + cCaixa + '^FS') // volume
				MSCBWrite('^FN14^FD' + cDescCli + '^FS')
				MSCBWrite('^FN15^FD' + cPedCliP + '^FS') // pernanbucanas
				MSCBWrite('^FN16^FD' + cCodBR + '^FS')   // pernanbucanas
				MSCBWrite('^FN17^FD' + cProdutoP + '^FS') // pernanbucanas
				MSCBWrite('^FN19^FD>:'+ cCodBarR + '^FS') // riachuelo
				MSCBWrite('^FN20^FD' + cQuantR + '^FS') // riachuelo
				MSCBWrite('^FN21^FD' + cVolTot + '^FS') // riachuelo
				IF SB1->B1_UM=='PC' .AND. cCliente == '732175'
					MSCBWrite('^FN59^FD' + cCodT + '^FS') // Stok
					MSCBWrite('^FN60^FD' + ALLTRIM(SA7->A7_BARRA)+'^FS') // Tok&Stok
				ELSEIF SB1->B1_UM=='JG' .AND. cCliente == '732175'
					MSCBWrite('^FN23^FD' + B1120Dun14(cCodBar)+'^FS') // Tok&Stok
					MSCBWrite('^FN57^FD' + ALLTRIM(SA7->A7_BARRA)+'^FS') // Tok&Stok
					MSCBWrite('^FN58^FD' + B1120Dun14(cCodBar)+'^FS') // Tok&Stok
					MSCBWrite('^FN22^FD' + cCodT + '^FS') // Stok
				ELSE
					MSCBWrite('^FN22^FD' + cCodT + '^FS') // Stok
					MSCBWrite('^FN23^FD' + ALLTRIM(SA7->A7_BARRA)+'^FS') // Tok&Stok
				ENDIF
				//			MSCBWrite('^FN23^FD' + '0000' + cCod3 + '^FS') // Tok&Stok
				MSCBWrite('^FN24^FD' + cDescP + '^FS') // Tok&Stok
				MSCBWrite('^FN25^FD' + cQuant + ' Pecas' + '^FS') // Tok&Stok
				MSCBWrite('^FN26^FD' + '000'+(cQuant) + '^FS') // Tok&Stok
				MSCBWrite('^FN27^FD' + cSemaPed + '^FS') // riachuelo
				MSCBWrite('^FN28^FD' + cCorProd + '^FS') // riachuelo
				MSCBWrite('^FN29^FD' + AllTrim(cCDLoja) + '^FS') // riachuelo
				MSCBWrite('^FN30^FD' + cPedCli + '^FS') // riachuelo
				MSCBWrite('^FN31^FD' + cDescA + '^FS') // Tok&Stok
				MSCBWrite('^FN32^FD' + cCodInt + '^FS') // CONTROLE INTERNO BUD
				MSCBWrite('^FN33^FD' + cDesccx + '^FS') // CONTROLE INTERNO BUD
				MSCBWrite('^FN34^FD' + cPedCli + '^FS') // ORDEM DE COMPRA
				MSCBWrite('^FN35^FD' + cCorL + '^FS') // COR DO PROD
				MSCBWrite('^FN36^FD' + STR(nQtdPcte) + '^FS') // RIACHUELO nQtdPCxa  nQtdPcte
				MSCBWrite('^FN37^FD' + STR(IIF(EMPTY(cPacks),nQtdPCxa,cPacks)/nQtdPcte) + '^FS') // RIACHUELO
				MSCBWrite('^FN38^FD' + cVolCxaR + '^FS') // RIACHUELO
				MSCBWrite('^FN39^FD' + cCODCor + '^FS') // LOJAS AVENIDA
				MSCBWrite('^FN40^FD' + (cDesccor) + '^FS') // LOJAS AVENIDA
				MSCBWrite('^FN41^FD' + (cVolCxaR) + '^FS') // LOJAS AVENIDA
				If 	cTpTaman == "LINHA - BANHO"
					MSCBWrite('^FN42^FD' + cPISO    + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN57^FD' + cJOGO    + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN43^FD' + cBANHO   + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN44^FD' + cROSTO   + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN50^FD' + cCabTam1 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN51^FD' + cCabTam2 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN52^FD' + cCabTam3 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN53^FD' + cCabTam4 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN54^FD' + cTpTaman + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN55^FD' + cDep     + '^FS') // LOJAS AVENIDA

				Else
					MSCBWrite('^FN42^FD' + cCasalSK  + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN43^FD' + cCasalQ  + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN44^FD' + cCasalk  + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN49^FD' + csolt    + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN50^FD' + cCabTam1 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN51^FD' + cCabTam2 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN52^FD' + cCabTam3 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN56^FD' + cCabTam4 + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN54^FD' + cTpTaman + '^FS') // LOJAS AVENIDA
					MSCBWrite('^FN55^FD' + cDep     + '^FS') // LOJAS AVENIDA
				Endif
				MSCBWrite('^FN45^FD' + cProdtorra + '^FS') // LOJAS AVENIDA
				MSCBWrite('^FN47^FD' + cPedCli + '^FS') // LOJAS AVENIDA
				MSCBWrite('^FN48^FD' + cC5_PedNum + '^FS') // PEDIDO CLIENTE
				MSCBWrite('^FN61^FD' + cCodCli + '^FS') // PEDIDO CLIENTE
				If	cCliente $'451932/087323/251285'
					MSCBWrite('^FN62^FD' + cPedcLIM + '^FS') // PEDIDO CLIENTE
				ENDIF

				If cCliente $ '189288'

					MSCBWrite('%IMAGEM%' + cIMG ) // PEDIDO CLIENTE
					MSCBWrite('^FN63^FD' + ALLTRIM(cTam) + '^FS') // TAMANHO DO PRODUTO
					MSCBWrite('^FN61^FD' + ALLTRIM(cCodCli) + '^FS') // TAMANHO DO PRODUTO
				Endif
				MSCBWrite('^FN63^FD' + ALLTRIM(cTam) + '^FS') // TAMANHO DO PRODUTO
				MSCBWrite('^FN76^FD' + ALLTRIM(cRef) + '^FS') // Referencia do produto

				If cCliente $ '200056/819201'
					If GetMv("BD_1120RCH")
						MSCBWrite('^FN63^FD' + 'Lojas Riachuelo S.A.' + '^FS')
						MSCBWrite('^FN64^FD' + cTPProd + '^FS')
						MSCBWrite('^FN65^FD' + nVolRCH + '^FS')
						MSCBWrite('^FN66^FD' + nDCO + '^FS')
						MSCBWrite('^FN67^FD' + cCodBarRCH + '^FS')
						MSCBWrite('^FN68^FD' + cCDBarArt + '^FS')
						MSCBWrite('^FN69^FD' + cArtigo + '^FS')
						MSCBWrite('^FN70^FD' + cPedRCH + '^FS')
						MSCBWrite('^FN71^FD' + cENDREC + '^FS')
						MSCBWrite('^FN72^FD' + cCEPDES + '^FS')
						MSCBWrite('^FN73^FD' + nCNPJ + '^FS')
						MSCBWrite('^FN74^FD' + cDest + '^FS')
						MSCBWrite('^FN75^FD' + ALLTRIM(STR(nQuantR)) + '^FS')
					EndIf
				Endif

				If cCliente $ '380141' // Cliente Ferreira Costa
					// Se não foi definido a caixa
					If !EE5->(Found())
						// Procura a embalagem padrão do produto
						ZCN->(DbSetOrder(2))
						ZCN->(DbSeek(xFilial('ZCN')+SA1->A1_CODENCX+Left(cProduto,8)+SubStr(cProduto,15,4)))

						// Se encontrar
						If ZCN->(Found())
							// Busco as informações da caixa
							EE5->(dbSeek(xFilial("EE5")+ZCN->ZCN_CODEMB))
						EndIf
					EndIf
					MSCBWrite('^FN80^FD' + ALLTRIM(EE5->EE5_DIMENS) + '^FS') // Dimensoes da caixa
					MSCBWrite('^FN81^FD' + ALLTRIM(Str(EE5->EE5_PESO + (SB1->B1_PESO * Val(cQuant)))) + '^FS') // Peso bruto (Peso do caixa + peso do produto)

					If cCliente $ '079117' // Cliente Alpargatas
						MSCBWrite('^FN11^FD' + '>;' + cBarraCli + '^FS') // Codigo de Barras da DUN14 do cliente

					Else
						MSCBWrite('^FN11^FD' + '>;' + ALLTRIM(B1120Dun14(cCodBar)) + '^FS') // Codigo de Barras da DUN14
					EndIf
				Endif

				If cCliente $ '079117' // Cliente Alpargatas
					MSCBWrite('^FN1^FD' + cNomeReduz + '^FS') // Nome do cliente
					MSCBWrite('^FN81^FD' + cCaixa + '^FS') // Volume De
					MSCBWrite('^FN86^FD' + cSapCode + '^FS') // Sap Code
					MSCBWrite('^FN87^FD' + cCorProdCli + '^FS') // Cor
					MSCBWrite('^FN88^FD' + cTamProdCli + '^FS') // Tamanho
				Endif

			EndIf

			If cCliente != "079117"
				MSCBWrite(cLinha)

			Else
				cEtiquetaZEG += cLinha
			EndIf

			FT_FSKIP()

		EndDo

		If cCliente $ '079117' // Cliente Alpargatas
			// Posiciona na tabela ZEG
			ZEG->(dbSetOrder(1))

			// Se ja existir a etiqueta na tabela ZEG
			IF ZEG->(dbSeek(xFilial("ZEG") + PadR(cPedido, TAMSX3("ZEG_PEDIDO")[1]) + cCaixa))
				RecLock("ZEG", .F.)

				// Se ainda nao existir a etiqueta na tabela ZEG
			Else
				RecLock("ZEG", .T.)
				ZEG->ZEG_FILIAL := xFilial("ZEG")
				ZEG->ZEG_PEDIDO := cPedido
				ZEG->ZEG_NUMETQ := cCaixa
				ZEG->ZEG_STATUS := 'GERADO'
			EndIf

			ZEG->ZEG_DTINC 	:= dDataBase
			ZEG->ZEG_HRINC 	:= Time()
			ZEG->ZEG_USINC 	:= cUserName
			ZEG->ZEG_ZPL   	:= cEtiquetaZEG
			ZEG->(MsUnlock())
		EndIf

		FT_FUSE()

		// Se não for o cliente Alpargatas
		If AllTrim(SC5->C5_CLIENTE) != '079117'
			MSCBEND()

		Else
			MsgStop('Para o cliente Alpargatas, nao sera impresso etiqueta por caixa, esse processo devera ser realizado posteriormente!')
		EndIf

		MSCBCLOSEPRINTER()
	EndIf
	//End Transaction

	// Atualizo o preenchimento do campo ZZ5_IMPRES para já impresso
	cQuery := "UPDATE " + RETSQLNAME("ZZ5") + " SET ZZ5_IMPRES = 'S' "
	cQuery += "WHERE "+RETSQLNAME("ZZ5")+".D_E_L_E_T_ = '' "
	cQuery += "AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "AND ZZ5_PEDIDO = '"+cPedido+"' "
	cQuery += "AND ZZ5_NUMETQ = '"+cCaixa+"' "
	If	TCSQLEXEC(cQuery) < 0
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	// Thiago 23/07/2014 (cliente Camicado já envia as etiquetas prontas, devem ser impressas de acordo com o arquivo deles):
	If	cCliente == '002339'
		if AllTrim(cEtqCamicado) != "" .And. AllTrim(cEtqCamicado) != "MISTA"
			// Envio comando para a impressora:
			MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
			MSCBCHKSTATUS(.F.)

			MSCBINFOETI("Etiquetas Expedição - Projeto Especial ","PROJETO ESPECIAL")
			MSCBBEGIN(1,6,800)

			MSCBWrite(cEtqCamicado)

			MSCBEND()
			MSCBCLOSEPRINTER()

			//End Transaction
		Endif
	EndIf
	// Fim - Etiquetas Camicado.

	If cCliente $ '379491' // Cliente HAVAN - BUSCA DADOS VIA API. ROBSONJP 20240528

		EtqHavan(cPedido, cProduto, cCaixa, cCxaTot)

	EndIf

	///////////////////////////////////////////////////////////////////////////////////////////
	RestArea(aAreaSA7)
	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Return

/*
/============================================================================\
|Nome              : EtiquetaHavan()                                         |
|============================================================================|
|Descricao         : Função especifica para cliente Havan, busca informações |
|					 da API da Havan.           					         |
|============================================================================|
|Autor             : Robson José Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 02/07/2024                                              |
\============================================================================/
*/

Static Function EtqHavan(_cPedido, _cProduto, _cCaixa, _cCxaTot)
	Local cUrlApi := GetMv("MV_HAVANUR")
	Local cKeyApi := GetMv("MV_HAVANKE")
	Local aHeader := {}
	Local oBody
	Local oRest
	Local oRetorno
	Local i
	Local cDirEtqH := Alltrim("\EtiqPrjEsp\")
	Local cTxtEtq  := ""
	Local cTxtBkp  := ""
	Local cVolTot  := ""
	Local cPorta   := "LPT1"
	Local cNomeProdutoZPL := ""
	Local nCaixa  := Val(_cCaixa)

	// Variáveis para armazenar os dados da API
	Local aEpcDun14 := {}
	Local cProdutoNome := ""
	Local cCodigoProduto := ""
	Local cProdutoReferencia := ""
	Local nQuantidadeEmbalagem := 0
	Local cCodigoEAN := ""
	Local cVariacaoNome := ""
	Local cFamiliaProdutoNome := ""
	Local cFamiliaCapacidadeNome := ""
	Local cFornecedorNome := ""

	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial('SC5')+_cPedido))
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial('SB1')+_cProduto))

	// Cabecalho de requisicao
	Aadd(aHeader, "Content-Type: application/json")

	// Corpo da requisicao
	oBody := JSonObject():New()
	oBody["accessKey"] := cKeyApi
	oBody["codigodeBarras"] := ALLTRIM(SB1->B1_CODBAR)
	oBody["quantidadeEtiquetas"] := "1"

	// Requisicao
	oRest := FWRest():New(cUrlApi)
	oRest:SetPostParams(oBody:toJson())
	oRest:setPath("/")
	oRest:SetChkStatus(.F.)
	oRest:Post(aHeader)

	// Verificar o status da requisição
	If oRest:GetHTTPCode() == '200'

		// Processar a resposta JSON
		FWJsonDeserialize(oRest:GetResult(),@oRetorno)

		// Extrair dados do JSON e gravar em variáveis
		aEpcDun14 			   := oRetorno:epcDun14
		cProdutoNome 		   := oRetorno:produtoNome
		cCodigoProduto 		   := oRetorno:codigoProduto
		cProdutoReferencia 	   := oRetorno:produtoReferencia
		nQuantidadeEmbalagem   := oRetorno:quantidadeEmbalagem
		cCodigoEAN 			   := oRetorno:codigoEAN
		cVariacaoNome 		   := oRetorno:variacaoCodigoNome
		cFamiliaProdutoNome	   := oRetorno:familiaProdutoNome
		cFamiliaCapacidadeNome := oRetorno:familiaCapacidadeNome
		cFornecedorNome		   := oRetorno:fornecedorNome

		cArq := cDirEtqH + 'HAVAN.TXT'

		If !FILE(cArq)
			ApMsgStop("Ocorreu um erro na leitura do layout da etiqueta Havan!")
			Return
		EndIf

		nHandle := FOPEN(cArq,0)
		FREAD(nHandle,cTxtEtq,65000)
		FCLOSE(nHandle)

		cTxtBkp := cTxtEtq

		// Envio comando para a impressora:
		MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
		MSCBCHKSTATUS(.F.)

		MSCBINFOETI("Etiqueta HAVAN")
		MSCBBEGIN(1,6,800)

		//cVolTot  := ALLTRIM(STR(nCaixa))+'/'+ALLTRIM(STR(nCxaTot))
		cVolTot := ALLTRIM(STR(nCaixa))

		aNomeProduto := WrapText(ALLTRIM(cCodigoProduto+' - '+cProdutoNome), 30)
		nYPos := 760
		nLineHeight := 50

		cTxtEtq := cTxtBkp
		cTxtEtq := STRTRAN(cTxtEtq,"%QRCODE%"            , ALLTRIM(ArrayToStr(aEpcDun14))) 	//Busca da API tag epcDun14
		cTxtEtq := STRTRAN(cTxtEtq,"%PRODUTOFAMILIA%"    , ALLTRIM(cFamiliaProdutoNome))    //Busca da API tag familiaProdutoNome
		cTxtEtq := STRTRAN(cTxtEtq,"%CAPACIDADEFAMILIA%" , ALLTRIM(cFamiliaCapacidadeNome)) //Busca da API tag familiaCapacidadeNome

		// Substituição da tag %NOMEPRODUTO% com as linhas quebradas
		For i := 1 To LEN(aNomeProduto)
			cNomeProdutoZPL += "^FT020," + STR(nYPos) + "^A0N,40,40^FH^FD" + aNomeProduto[i] + "^FS\n"
			nYPos += nLineHeight
		Next

		cTxtEtq := STRTRAN(cTxtEtq,"%NOMEPRODUTO%"       , cNomeProdutoZPL)
		cTxtEtq := STRTRAN(cTxtEtq,"%REFERENCIAPRODUTO%" , ALLTRIM(cProdutoReferencia)) 	   //Busca da API tag produtoReferencia

		// cTxtEtq := STRTRAN(cTxtEtq,"%PEDIDOCLIENTE%"     , ALLTRIM(SC5->C5_PEDCLI))     	   //Busca pedido do cliente da C5_PEDCLI -> Solicitado remoção do pedido cliente, pelo pessoal de desenvolvimenta da Havan (15/07/2024)
		// Removido esta linha aqui da etiqueta ZPL: ORDEM COMPRA:  ^FT020,890^A0N,30,30^FH^FDPedido: %PEDIDOCLIENTE%^FS

		cTxtEtq := STRTRAN(cTxtEtq,"%FORNECEDORNOME%"    , ALLTRIM(cFornecedorNome)) 		   //Busca da API tag fornecedorNome
		cTxtEtq := STRTRAN(cTxtEtq,"%VARIACAOCODNOME%"   , ALLTRIM(cVariacaoNome)) 	    	   //Busca da API tag variacaoCodigoNome
		cTxtEtq := STRTRAN(cTxtEtq,"%QTDEMBALAGEM%"      , ALLTRIM(STR(nQuantidadeEmbalagem))) //Busca da API tag quantidadeEmbalagem
		cTxtEtq := STRTRAN(cTxtEtq,"%VOLUME%"            , ALLTRIM(cVolTot))        		   //Busca volume da caixa, ex: 1 de 10...
		cTxtEtq := STRTRAN(cTxtEtq,"%CODIGOBARRAS%"      , ALLTRIM(cCodigoEAN)) 		 	   //Busca da API tag codigoEAN

		MSCBWrite(cTxtEtq)

		MSCBEND()
		MSCBCLOSEPRINTER()
	Else
		ApMsgStop("Erro API Havan: " +oRest:GetHTTPCode())
	EndIf

Return

/*
/============================================================================\
|Nome              : WrapText()                                              |
|============================================================================|
|Descricao         : Função para quebrar texto						         |
|============================================================================|
|Autor             : Robson José Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 02/07/2024                                              |
\============================================================================/
*/

Static Function WrapText(cText, nWidth)
	Local aLines := {}
	Local cLine := ""
	Local nPos := 1

	While LEN(cText) > nWidth
		nPos := RAT(" ", SUBSTR(cText, 1, nWidth))
		If nPos == 0
			nPos := nWidth
		EndIf
		cLine := SUBSTR(cText, 1, nPos)
		AADD(aLines, cLine)
		cText := ALLTRIM(SUBSTR(cText, nPos + 1))
	EndDo

	If !Empty(cText)
		AADD(aLines, cText)
	EndIf

Return aLines

/////////////////////////////////////////////////////////////Especifico Riachuelo////////////////////////////////////////////////////////////
User Function B1120PrtR(cPedido, cItem, cProduto, cCaixa, cSeqEnc, cCliente, cLoja, nQuant, cCxaTot, lReimpressao)

	Local aAreaSB1 := SB1->(GetArea())
	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaSA7 := SA7->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSC6 := SC6->(GetArea())
	//Local cPath	 := '\\%COMPUTERNAME%\ZEBRAZT'
	Local cPath	 := '\\127.0.0.1\ZEBRAZT'
	Local cPorta 	 := "LPT1"
	Local cProdAux	 := cProduto
	Private cDescP 		:=""
	Private cDescA 		:=""
	Private cDescL 		:=""
	Private cCorL 		:=""
	Private cCodInt		:=""
	Private cSemaPed    := ''
	Private cC5_Num     :=''
	Private cCodPVA :='' /// jonas
	Private cCodP:=''
	Default cPedido 	:= Space(TamSx3('C5_NUM')[1])
	Default cItem		:= Space(TamSx3('C6_ITEM' )[1])
	Default cProduto	:= Space(TamSx3('C6_PRODUTO')[1])
	Default cCaixa	:= Space(TamSx3('ZZ5_NUMETQ')[1])
	Default cSeqEnc	:= Space(TamSx3('ZZ5_SEQENC')[1])
	Default cCliente	:= Space(TamSx3('C5_CLIENTE')[1])
	Default cLoja		:= Space(TamSx3('C5_LOJACLI')[1])
	Default nQuant	:= 0
	Default cCxaTot	:= Space(3)

	cProdAux := cProduto

	SB1->(DbSetOrder(1))
	lSB1 := SB1->(DbSeek(xFilial('SB1')+cProduto))

	SA1->(DbSetOrder(1))
	lSA1 := SA1->(DbSeek(xFilial('SA1')+cCliente+cLoja))

	SC5->(DbSetOrder(1))
	lSC5 := SC5->(DbSeek(xFilial('SC5')+cPedido))

	SC6->(DbSetOrder(1))
	lSC6 := SC6->(DbSeek(xFilial('SC6')+cPedido+cItem+cProduto))

	SA7->(DbSetOrder(1))
	lSA7 := SA7->(DbSeek(xFilial('SA7')+cCliente+cLoja+cProduto))

	If (WinExec('net use '+cPorta+' '+cPath+' /persistent:yes exit')) != 0
		MsgStop('Erro ao executar comando Net Use para a porta '+cPorta+' no caminho '+cPath+' !!!')
		Return
	EndIf

	nConfig 	:= 0
	If (nHandle := FT_FUSE(AllTrim(cDirArq+cArqConf))) == -1
		MsgStop('Não foi encontrado o arquivo de configuração de Etiquetas, Contate o Administrador !!!')
		Final()
	EndIf

	cArqIni := ''
	nTot	 := FT_FLASTREC()
	FT_FGOTOP()
	While !FT_FEOF()

		cLinCfg := FT_FREADLN()
		If	Substr(cLinCfg,1,6) == cCliente
			cArqIni := AllTrim(Substr(cLinCfg,8,11))
			Exit
		EndIf

		FT_FSKIP()

	EndDo

	nHandle  	:= 0
	cArqIni	:= cDirArq+cArqIni
	If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
		MsgStop('Não foi encontrado arquivo de configuração para este Cliente, '+cArqIni+' Verifique !!!')
		Final()
	EndIf

	cNomeClie 	:= AllTrim(SA1->A1_NOME)
	cEndereco 	:= AllTrim(SA1->A1_END) //+ ' - ' + AllTrim(SA1->A1_BAIRRO)
	cCEP 		:= Transform(SA1->A1_CEP, PesqPict("SA1","A1_CEP"))
	cMun 		:= AllTrim(SA1->A1_MUN)
	cUF			:= AllTrim(SA1->A1_EST)
	cTelefone	:= AllTrim(SA1->A1_TEL)
	cDataEmbal	:= DtoC(ZZ5->ZZ5_DATA)
	cProduto	:= PadC(AllTrim(ZZ5->ZZ5_PRODUT),18,' ')
	cDescri		:= AllTrim(SC6->C6_DESCRI)
	cQuant		:= AllTrim(Transform(nQuant, '@E 999,999'))
	//	cCodBar	:= AllTrim(ZZ5->ZZ5_CODBAR)
	cCodCli	:= ''
	cDescCli	:= ''
	cDescCor	:= ''
	cCodEmb	:= ''
	cPedCliP	:= ''
	cCodPV		:= ''
	cCodBR		:= ''
	cProdutoP	:= ''
	//	cCodBarR 	:= ''
	cQuantR 	:= '' // riachuelo
	//cCxaTot 	:= '' // riachuelo
	cCod3		:= ''
	cCodT		:= ''
	cVolTot  	:= ''
	cDesccx    := ''

	// --- Código do Produto do Cliente
	// -- Etna, Avenida, Ascis, SS COM. DE COSMETICOS, Calvin Klein
	If	!Empty(SA7->A7_DESCCLI)	// --- Código do Produto do Cliente
		cDescri	:= AllTrim(SA7->A7_DESCCLI)
	EndIf

	If	cCliente == '200056' // Riachuelo
		Default cCaixa	:= cVolr//Space(TamSx3('ZZ5_EPVOLS')[1])
		Private cCorProd    := '' // riachuelo
		//Private cC5_Num := Space(TamSx3('C5_NUM')[1])
		Default cC5_Num := Space(TamSx3('C5_NUM')[1])
		SC5->(DbSeek(xFilial('SC5')+cPedido))
		cProduto := AllTrim(SA7->A7_CODCLI)
		cCodBarR := '>:' + AllTrim(SA7->A7_CODCLI) + iif(len(cCxaTot)=4,StrZero(Val(cCaixa),4),StrZero(Val(cCaixa),3)) + cCxaTot
		cQuantR  := '['+StrZero(Val(cQuant),4)+']'
		cVolTot  := iif(len(cCxaTot)=4,StrZero(Val(cCaixa),4),StrZero(Val(cCaixa),3))+'/'+cCxaTot
		//		cVolTot  := StrZero(Val(cCaixa),5)+'/'+cCxaTot
		cSemaPed := SC5->C5_SEMAPED
		cPedCli:= SC5->C5_PEDCLI
		cCDLoja:= SA1->A1_CDLOJA
		cCorProd := ALLTRIM(SA7->A7_COR)
		cTotCxaR:= StrZero((SC6->C6_QTDVEN - SC6->C6_QTDCANC) / nQtdPCxa,4)
		cVolCxaR:= cCaixa +' / '+ cTotCxaR
	EndIf

	MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
	MSCBCHKSTATUS(.F.)

	/////////////////////////IMPRESSAO MODELO ZEBRA ZT230
	/// 2300 (ZPL)///////////////////////////////////
	MSCBINFOETI("Etiquetas Expedição - Projeto Especial ","PROJETO ESPECIAL")
	MSCBBEGIN(1,6,800) // 800

	cLinha   	:= ""
	nTot		:= FT_FLASTREC()
	Default cCorProd    := '' // riachuelo
	Default cCodP:=''
	//	cCodBar	:= AllTrim(ZZ5->ZZ5_CODBAR)
	SC5->(DbSeek(xFilial('SC5')+cPedido))
	cCDLoja:= SA1->A1_CDLOJA
	cPedCli:= SC5->C5_PEDCLI
	FT_FGOTOP()
	While !FT_FEOF()

		cLinha := FT_FREADLN()
		If	Substr(cLinha,1,4) == '^PQ1'
			MSCBWrite('^FN1^FD' + cNomeClie + '^FS')
			MSCBWrite('^FN2^FD' + cPedido + '^FS')
			MSCBWrite('^FN3^FD' + cEndereco + '^FS')
			MSCBWrite('^FN18^FD' + cCEP + ' - ' + cMun + ' - ' + cUF + '^FS')
			MSCBWrite('^FN4^FD' + cTelefone + '^FS')
			MSCBWrite('^FN5^FD' + cDataEmbal+ '^FS')
			MSCBWrite('^FN6^FD' + cItem + '^FS')
			MSCBWrite('^FN7^FD' + cProduto  + '^FS')
			MSCBWrite('^FN8^FD' + cDescri   + '^FS')
			MSCBWrite('^FN9^FD' + cQuant + '^FS')
			//	MSCBWrite('^FN10^FD' + cCodBar + '^FS')
			//MSCBWrite('^FN11^FD' + '>;' + B1120Dun14(cCodBar) + '^FS') // Codigo de Barras da Embalagem Havan
			MSCBWrite('^FN12^FD' + AllTrim(ZZ5->ZZ5_ACONDI) + '^FS')
			MSCBWrite('^FN13^FD' + cCaixa + '^FS') // volume
			MSCBWrite('^FN14^FD' + cDescCli + '^FS')
			MSCBWrite('^FN15^FD' + cPedCliP + '^FS') // pernanbucanas
			MSCBWrite('^FN16^FD' + cCodBR + '^FS')   // pernanbucanas
			MSCBWrite('^FN17^FD' + cProdutoP + '^FS') // pernanbucanas
			MSCBWrite('^FN19^FD>:'+ cCodBarR + '^FS') // riachuelo
			MSCBWrite('^FN20^FD' + cQuantR + '^FS') // riachuelo
			MSCBWrite('^FN21^FD' + cVolTot + '^FS') // riachuelo
			MSCBWrite('^FN22^FD' + cCodT + '^FS') // Stok
			MSCBWrite('^FN23^FD' + ALLTRIM(SA7->A7_BARRA)+'^FS') // Tok&Stok
			//			MSCBWrite('^FN23^FD' + '0000' + cCod3 + '^FS') // Tok&Stok
			MSCBWrite('^FN24^FD' + cDescP + '^FS') // Tok&Stok
			MSCBWrite('^FN25^FD' + cQuant + ' Pecas' + '^FS') // Tok&Stok
			MSCBWrite('^FN26^FD' + '   ' + cQuant + '^FS') // Tok&Stok
			MSCBWrite('^FN27^FD' + cSemaPed + '^FS') // riachuelo
			MSCBWrite('^FN28^FD' + cCorProd + '^FS') // riachuelo
			MSCBWrite('^FN29^FD' + AllTrim(cCDLoja) + '^FS') // riachuelo
			MSCBWrite('^FN30^FD' + cPedCli + '^FS') // riachuelo
			MSCBWrite('^FN31^FD' + cDescA + '^FS') // Tok&Stok
			MSCBWrite('^FN32^FD' + cCodInt + '^FS') // CONTROLE INTERNO BUD
			MSCBWrite('^FN33^FD' + cDesccx + '^FS') // CONTROLE INTERNO BUD
			MSCBWrite('^FN34^FD' + cPedCli + '^FS') // ORDEM DE COMPRA
			MSCBWrite('^FN35^FD' + cCorL + '^FS') // COR DO PROD
			MSCBWrite('^FN36^FD' + cPedCli + '^FS') // numero pedido cliente

		EndIf
		MSCBWrite(cLinha)

		FT_FSKIP()

	EndDo

	FT_FUSE()

	// Quando o cliente for Riachuelo estará imprimindo em etiqueta de tamanho 7,5 x 20,5 e tipo de Formulario continuo
	// para não apresentar problema para a impressão de outras etiquetas no tamanho padrao 10 x 10, deverá ser executado
	// o arquivo com a mudança de configuração para o reconhecimento da etiqueta por ranhura.

	/*
	If	cCliente == '200056'

	cCont 	:= 0
	If (nHdlCon := FT_FUSE(AllTrim(cDirArq+cArqCont))) == -1
	MsgStop('Não foi encontrado o arquivo para posicionamento de Etiqueta Continua, Contate o Administrador !!!')
	Final()
	EndIf

	FT_FGOTOP()
	While !FT_FEOF()

	cLinCon := FT_FREADLN()
	MSCBWrite(cLinCon)

	FT_FSKIP()

	EndDo

	EndIf
	*/
	MSCBEND()
	MSCBCLOSEPRINTER()


	// Atualizo o preenchimento do campo ZZ5_IMPRES para já impresso
	cQuery := "UPDATE " + RETSQLNAME("ZZ5") + " SET ZZ5_IMPRES = 'S' "
	cQuery += "WHERE "+RETSQLNAME("ZZ5")+".D_E_L_E_T_ = '' "
	cQuery += "AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "AND ZZ5_PEDIDO = '"+cPedido+"' "
	cQuery += "AND ZZ5_NUMETQ = '"+cCaixa+"' "
	If	TCSQLEXEC(cQuery) < 0
		MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	///////////////////////////////////////////////////////////////////////////////////////////
	RestArea(aAreaSA7)
	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Return

/* /////////////////////////////////////////////////////////////Especifico Lebiscuit////////////////////////////////////////////////////////////
Static Function B1120Prtleb(cPedido, cNumCxa,cCliente,cCaixa, lReimpressao)

	//Local aAreaSB1 := SB1->(GetArea())
	//Local aAreaSA1 := SA1->(GetArea())
	//Local aAreaSA7 := SA7->(GetArea())
	//Local aAreaSC5 := SC5->(GetArea())
	//Local aAreaSC6 := SC6->(GetArea())
	//Local cPath	 := '\\%COMPUTERNAME%\ZEBRAZT'
	Local cPath	 := '\\127.0.0.1\ZEBRAZT'
	Local cPorta 	 := "LPT1"
	Default cProdAux	 := ''
	Private cDescP 		:=""
	Private cDescA 		:=""
	Private cDescL 		:=""
	Private cCorL 		:=""
	Private cCodInt		:=""
	Private cSemaPed    := ''
	Private cC5_Num     :=''
	Private cCodPVA :='' /// jonas
	Private cCodP:=''
	//	Default cPedido 	:= Space(TamSx3('C5_NUM')[1])





	//SA7->(DbSetOrder(1))
	//lSA7 := SA7->(DbSeek(xFilial('SA7')+cCliente+cLoja+cProduto))

	If (WinExec('net use '+cPorta+' '+cPath+' /persistent:yes exit')) != 0
		Alert('Erro ao executar comando Net Use para a porta '+cPorta+' no caminho '+cPath+' !!!')
		Return
	EndIf



	If (Select("LEZZ5") <> 0)
		dbSelectArea("LEZZ5")
		dbCloseArea()
	EndIf

	BeginSql Alias 'LEZZ5'
	SELECT *
	FROM %Table:ZZ5% ZZ5 (NOLOCK)
	WHERE ZZ5.%NotDel% AND
	ZZ5_FILIAL  = %xFilial:ZZ5% AND
	ZZ5_PEDIDO  = %Exp:cPedido% AND
	ZZ5_NUMETQ  = %Exp:cNumCxa%  AND
	ZZ5_DATA  = %Exp:dtos(dDataBase)%

	EndSql

	nConfig 	:= 0

	If (nHandle := FT_FUSE(AllTrim(cDirArq+cArqConf))) == -1
		MsgStop('Não foi encontrado o arquivo de configuração de Etiquetas, Contate o Administrador !!!')
		Final()
	EndIf

	cArqIni := ''
	nTot	 := FT_FLASTREC()
	FT_FGOTOP()
	While !FT_FEOF()

		cLinCfg := FT_FREADLN()
		If	Substr(cLinCfg,1,6) == cCliente
			cArqIni := AllTrim(Substr(cLinCfg,8,11))
			Exit
		EndIf

		FT_FSKIP()

	EndDo

	nHandle  	:= 0
	cArqIni	:= cDirArq+cArqIni
	If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
		MsgStop('Não foi encontrado arquivo de configuração para este Cliente, '+cArqIni+' Verifique !!!')
		Final()
	EndIf

	cNomeClie 	:= AllTrim(SA1->A1_NOME)
	cEndereco 	:= AllTrim(SA1->A1_END) //+ ' - ' + AllTrim(SA1->A1_BAIRRO)
	cCEP 		:= Transform(SA1->A1_CEP, PesqPict("SA1","A1_CEP"))
	cMun 		:= AllTrim(SA1->A1_MUN)
	cUF			:= AllTrim(SA1->A1_EST)
	cTelefone	:= AllTrim(SA1->A1_TEL)
	cDataEmbal	:= DtoC(ZZ5->ZZ5_DATA)
	cProduto	:= PadC(AllTrim(ZZ5->ZZ5_PRODUT),18,' ')
	cDescri	:= AllTrim(SC6->C6_DESCRI)
	//	cQuant		:= AllTrim(Transform(nQuant, '@E 999,999'))
	//	cCodBar	:= AllTrim(ZZ5->ZZ5_CODBAR)
	cCodCli	:= ''
	cDescCli	:= ''
	cDescCor	:= ''
	cCodEmb	:= ''
	cPedCliP	:= ''
	cCodPV		:= ''
	cCodBR		:= ''
	cProdutoP	:= ''
	//	cCodBarR 	:= ''
	cQuantR 	:= '' // riachuelo
	//cCxaTot 	:= '' // riachuelo
	cCod3		:= ''
	cCodT		:= ''
	cVolTot  	:= ''
	cDesccx    := ''
	cCDBAR:=''

	// --- Código do Produto do Cliente
	// -- Etna, Avenida, Ascis, SS COM. DE COSMETICOS, Calvin Klein





	MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
	MSCBCHKSTATUS(.F.)

	/////////////////////////IMPRESSAO MODELO ZEBRA ZT230
	/// 2300 (ZPL)///////////////////////////////////
	MSCBINFOETI("Etiquetas Expedição - Projeto Especial ","PROJETO ESPECIAL")
	MSCBBEGIN(1,6,800) // 800

	cLinha   	:= ""
	nTot		:= FT_FLASTREC()
	Private cCorProd    := '' // riachuelo
	Default cCodP:=''
	//	cCodBar	:= AllTrim(ZZ5->ZZ5_CODBAR)
	SC5->(DbSeek(xFilial('SC5')+cPedido))
	cCDLoja:= SA1->A1_CDLOJA
	cPedCli:= SC5->C5_PEDCLI
	cVolTot  := SUBSTR(cNumCxa,3,4)
	FT_FGOTOP()
	While !FT_FEOF()

		cLinha := FT_FREADLN()
		If	Substr(cLinha,1,4) == '^PQ1'

			dbSelectArea("LEZZ5")
			dbGoTop()


			While !LEZZ5->(EOF())

				MSCBWrite('^FN1^FD' + cNomeClie + '^FS')
				MSCBWrite('^FN2^FD' + cPedido + '^FS')
				MSCBWrite('^FN3^FD' + cEndereco + '^FS')
				MSCBWrite('^FN4^FD' + cCEP + ' - ' + cMun + ' - ' + cUF + '^FS')
				MSCBWrite('^FN5^FD' + cTelefone + '^FS')
				MSCBWrite('^FN6^FD' + cDataEmbal+ '^FS')

				//	MSCBWrite('^FN10^FD' + cCodBar + '^FS')
				//MSCBWrite('^FN11^FD' + '>;' + B1120Dun14(cCodBar) + '^FS') // Codigo de Barras da Embalagem Havan
				MSCBWrite('^FN7^FD' + AllTrim(ZZ5->ZZ5_ACONDI) + '^FS')
				MSCBWrite('^FN8^FD' + SUBSTR(cNumCxa,3,4)+ '^FS') // volume

				cZZ5_SEQENC	:= LEZZ5->ZZ5_SEQENC
				cZZ5_NUMETQ := LEZZ5->ZZ5_NUMETQ
				cITEM:= LEZZ5->ZZ5_ITEM

				nItem:= 0
				While !LEZZ5->(EOF()) .And. LEZZ5->ZZ5_SEQENC == cZZ5_SEQENC .And. LEZZ5->ZZ5_NUMETQ == cZZ5_NUMETQ
					nItem:= nItem + 1
					SB1->(DbSetOrder(5))
					SB1->(DbSeek(xFilial('SB1')+ALLTRIM(LEZZ5->ZZ5_CODBAR)))

					SZT->(DbSetOrder(3))
					SZT->(DbSeek(xFilial('SZT')+ALLTRIM(SB1->B1_CODCOR)))
					If	SZT->(Found())
						cDescCor	:= ALLTRIM(SZT->ZT_DESCRI)
						If ALLTRIM(cDescCor) == "PADRAO"
							cDescCor := "P."+ALLTRIM(SZT->ZT_REF)
						EndIf
					EndIf


					IF nItem == 1
						//			 IF ALLTRIM(LEZZ5->ZZ5_ITEM)=='01'

						MSCBWrite('^FN9^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN10^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN11^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN12^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN13^FD' + cDescCor + '^FS') // COR DO PROD

					ELSEIF nItem == 2

						MSCBWrite('^FN14^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN15^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN16^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN17^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN18^FD' + cDescCor + '^FS') // COR DO PROD

					ELSEIF nItem == 3

						MSCBWrite('^FN19^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN20^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN21^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN22^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN23^FD' + cDescCor + '^FS') // COR DO PROD

					ELSEIF nItem == 4

						MSCBWrite('^FN24^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN25^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN26^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN27^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN28^FD' + cDescCor + '^FS') // COR DO PROD

					ELSEIF nItem == 5

						MSCBWrite('^FN29^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN30^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN31^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN32^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN33^FD' + cDescCor + '^FS') // COR DO PROD

					ELSEIF nItem == 6

						MSCBWrite('^FN34^FD' + LEZZ5->ZZ5_ITEM + '^FS')
						MSCBWrite('^FN35^FD' + LEZZ5->ZZ5_PRODUT  + '^FS')
						MSCBWrite('^FN36^FD' + SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+LEZZ5->ZZ5_PRODUT,"B1_DESC"),1,30)+ '^FS')
						MSCBWrite('^FN37^FD' + STRZERO(LEZZ5->ZZ5_QTDENC,2) + '^FS')
						MSCBWrite('^FN38^FD' + cDescCor + '^FS') // COR DO PROD
					ENDIF

					If (Select("IMPDUN14") <> 0)
						dbSelectArea("IMPDUN14")
						dbCloseArea()
					EndIf

					IF EMPTY(cGet1)
						cGet1:= '000001'
					ENDIF

					BeginSql Alias 'IMPDUN14'
					SELECT DISTINCT ZRG_DUN14
					FROM %Table:ZRG% ZRG (NOLOCK)
					WHERE ZRG.%NotDel% AND
					ZRG_CODCLI  = %Exp:SC5->C5_CLIENTE% AND
					ZRG_CDCOMB  = %Exp:SUBSTR(cGet1,1,6)%

					EndSql
					dbSelectArea("IMPDUN14")


					IF !EMPTY(cGet1)
						cCDBAR:= IMPDUN14->ZRG_DUN14 //POSICIONE("ZRG",3,XFILIAL("ZRG")+ SUBSTR(cGet1,1,6)+LEZZ5->ZZ5_CODBAR,"ZRG_DUN14")
					ELSE
						cCDBAR:= IMPDUN14->ZRG_DUN14 //POSICIONE("ZRG",3,XFILIAL("ZRG")+ LEZZ5->ZZ5_CODBAR,"ZRG_DUN14")
					EndIf
					MSCBWrite('^FN39^FD' + cVolTot + '^FS') // riachuelo
					MSCBWrite('^FN40^FD' + cCDBAR +'^FS') // Tok&Stok

					LEZZ5->(DbSkip())
				ENDDO

			ENDDO
		EndIf
		lDun14:=.T.
		MSCBWrite(cLinha)

		FT_FSKIP()

	EndDo

	FT_FUSE()

	// Quando o cliente for Riachuelo estará imprimindo em etiqueta de tamanho 7,5 x 20,5 e tipo de Formulario continuo
	// para não apresentar problema para a impressão de outras etiquetas no tamanho padrao 10 x 10, deverá ser executado
	// o arquivo com a mudança de configuração para o reconhecimento da etiqueta por ranhura.


	//If	cCliente == '233389'

	cCont 	:= 0
	If (nHdlCon := FT_FUSE(AllTrim(cDirArq+cArqCont))) == -1
		MsgStop('Não foi encontrado o arquivo para posicionamento de Etiqueta Continua, Contate o Administrador !!!')
		Final()
	EndIf

	FT_FGOTOP()
	While !FT_FEOF()

		cLinCon := FT_FREADLN()
		MSCBWrite(cLinCon)

		FT_FSKIP()

	EndDo

	//	EndIf

	MSCBEND()
	MSCBCLOSEPRINTER()

	/*
	// Atualizo o preenchimento do campo ZZ5_IMPRES para já impresso
	cQuery := "Begin Tran EtqProjEsp ; "+ENTER
	cQuery += "UPDATE " + RETSQLNAME("ZZ5") + " SET ZZ5_IMPRES = 'S' "
	cQuery += "WHERE "+RETSQLNAME("ZZ5")+".D_E_L_E_T_ = '' "
	cQuery += "AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "AND ZZ5_PEDIDO = '"+cPedido+"' "
	cQuery += "AND ZZ5_ITEM   = '"+cItem+"' "
	cQuery += "AND ZZ5_NUMETQ = '"+cCaixa+"' "
	cQuery += "AND ZZ5_PRODUT = '"+cProdAux+"' ; "+ENTER
	cQuery += "Commit Tran EtqProjEsp ; "+ENTER
	If	TCSQLEXEC(cQuery) < 0
	MsgStop("TCSQLError() " + TCSQLError())
	EndIf

	///////////////////////////////////////////////////////////////////////////////////////////
	RestArea(aAreaSA7)
	RestArea(aAreaSA1)
	RestArea(aAreaSB1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Return
*/

// Função responsavel para impressao de etiqueta de pallet quando setado pelo usuario no inicio da rotina
Static Function B1120Pallet(lReimp, lPalletSort)

	Local cAliasPal 	:= GetNextAlias()
	Local cAliasCxa		:= GetNextAlias()
	Local aDescPal  	:= {}
	Local cDescPal1 	:= ''
	Local cDescPal2 	:= ''
	Local cDescPal3 	:= ''
	Local cDescPal4 	:= ''
	Local cDescEnd		:= ''
	Local cPorta 	  	:= "LPT1"
	Local nTotCxa	  	:= 0
	Local cTpPall	  	:= ''
	Local x			  	:= 0

	Local c2ACOND 		:= ''
	Local c2OPERA 		:= ''

	Default lReimp 		:= .F.
	Default lPalletSort := .F.
	Default lCDBudd		:= .F.
	Default cEnderEst	:= ''

	// Verificar numeração do pallet:
	If Empty(cPallet)
		Return
	EndIf

	// Verifico quantidade de caixa no pallet:
	If (Select("TC1120") <> 0)
		dbSelectArea("TC1120")
		dbCloseArea()
	EndIf
	cQuery := "SELECT DISTINCT TOP 1 ISNULL(COUNT(ZZ5_NUMETQ), 0) AS QTD_CAIXA FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+cPallet+"' AND ZZ5010.D_E_L_E_T_ = '' "
	TCQuery cQuery NEW ALIAS "TC1120"
	If !TC1120->(EOF())
		nTotCxa := TC1120->QTD_CAIXA
	EndIf

	// Pallet vazio, saio da rotina:
	if Empty(nTotCxa) .Or. nTotCxa <= 0
		Return
	EndIf

	SC5->(DbSetOrder(1))
	lSC5 := SC5->(DbSeek(xFilial('SC5')+cC5_Num))

	SA1->(DbSetOrder(1))
	lSA1 := SA1->(DbSeek(xFilial('SA1')+SC5->(C5_CLIENTE+C5_LOJACLI)))

	nHandle  	:= 0
	cArqIni	:= cDirArq+cArqPall
	If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
		MsgStop('Não foi encontrado arquivo para impressão de etiqueta de PALLET, '+cArqIni+' Verifique !!!')
		Final()
	EndIf

	// Chama rotina de transferência:
	/* Levado a rotina para realizar transferência após a marcação de pallet impresso (mais abaixo)
	If	!lReimp
		if lCDBudd
			// Efetuando transferência dis itens de saída para entrada via pallet no CD:
			MsAguarde({|| BuscaWS("&a=transfere", "&p="+AllTrim(cC5_Num)+"&l="+AllTrim(cC5_Num)+AllTrim(cPallet)+"&tp="+cTipoCDGr ) }, "Transferindo", "Transferindo itens CD...")
		EndIf
	EndIf
	*/

	// Padrão pallet:
	MsAguarde({|| U_B1120Padr(cC5_Num, cPallet) }, 'Pallet', 'Verificando padrão do pallet...')

	BeginSql Alias cAliasPal
		Column QTDCXA as Numeric(10, 0)
		Column QTD as Numeric(10, 0)
		SELECT
			BM_DESC AS DESCR,
			SUM(ZZ5_QTDENC) AS QTD,
			SUBSTRING(ZZ5_PRODUT, 9, 6) AS COR,
			COUNT(DISTINCT ZZ5_NUMETQ) AS QTDCXA,
			MAX(ZZ5_ENDERE) AS ENDPALL,
			MAX(ZZ5_PAPALL) AS TPPALL
		FROM
			%Table:ZZ5% ZZ5
		INNER JOIN %Table:SB1% B1 (NOLOCK)
		ON B1.%NotDel%
			AND B1_FILIAL = %xFilial:SB1%
			AND B1_COD = ZZ5_PRODUT
		INNER JOIN %Table:SBM% BM (NOLOCK)
		ON BM.%NotDel%
			AND BM_FILIAL = %xFilial:SBM%
			AND BM_GRUPO = B1_GRUPO
		WHERE
			ZZ5.%NotDel%
			AND ZZ5_FILIAL = %xFilial:ZZ5%
			AND ZZ5_PEDIDO = %Exp:cC5_Num%
			AND ZZ5_PALLET = %Exp:cPallet%
		GROUP BY
			BM_DESC,
			SUBSTRING(ZZ5_PRODUT, 9, 6)
		ORDER BY
			BM_DESC,
			SUBSTRING(ZZ5_PRODUT, 9, 6)
	EndSql

	nTotCxa	:= 0
	While !(cAliasPal)->(Eof())
		aAdd(aDescPal, AllTrim(Str((cAliasPal)->QTD)) + ' ' + Capital(AllTrim((cAliasPal)->DESCR)) + ' ' + (cAliasPal)->COR)

		// Endereço do pallet:
		cDescEnd := IIF((Empty(cEnderEst) .Or. lReimp), AllTrim((cAliasPal)->ENDPALL), cEnderEst)

		// Tipo do pallet:
		cTpPall	:= AllTrim((cAliasPal)->TPPALL)

		nTotCxa += (cAliasPal)->QTDCXA
		(cAliasPal)->(DbSkip())
	EndDo

	// Adiciono tipo do pallet:
	aAdd(aDescPal, 'Pallet ['+IIF(cTpPall == 'C', 'COMPLETO', 'PARCIAL')+']')

	// Thiago 19/07/2016 - Buscar quantidade de caixas distintas:
	IF lPalletSort
		BeginSql Alias cAliasCxa
			Column QTDCXA as Numeric(10, 0)
			Column QTD as Numeric(10, 0)
			SELECT
				TOP 1 COUNT(DISTINCT ZZ5_NUMETQ) AS QTDCXA
			FROM
				%Table:ZZ5% ZZ5
			INNER JOIN %Table:SB1% B1 (NOLOCK)
			ON B1.%NotDel%
				AND B1_FILIAL = %xFilial:SB1%
				AND B1_COD = ZZ5_PRODUT
			INNER JOIN %Table:SBM% BM (NOLOCK)
			ON BM.%NotDel%
				AND BM_FILIAL = %xFilial:SBM%
				AND BM_GRUPO = B1_GRUPO
			WHERE
				ZZ5.%NotDel%
				AND ZZ5_FILIAL = %xFilial:ZZ5%
				AND ZZ5_PEDIDO = %Exp:cC5_Num%
				AND ZZ5_PALLET = %Exp:cPallet%
		EndSql
		While !(cAliasCxa)->(Eof())
			nTotCxa := (cAliasCxa)->QTDCXA
			(cAliasCxa)->(DbSkip())
		EndDo
	EndIf

	If lReimp
		If (Select("TTACOND") <> 0)
			DbSelectArea("TTACOND")
			DbCloseArea()
		Endif
		cQuery := ""
		cQuery += "SELECT TOP 1 ZZ5_ACOND2, ZZ5_OPERA2 "
		cQuery += "FROM "+RetSqlName("ZZ5")+" (NOLOCK) "
		cQuery += "WHERE ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
		cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
		cQuery += "AND ZZ5_PALLET = '"+cPallet+"' "
		cQuery += "AND ZZ5_ACOND2 <> ' ' AND ZZ5_OPERA2 <> ' ' "
		cQuery += "AND "+RetSqlName("ZZ5")+".D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TTACOND"
		If !TTACOND->(Eof())
			c2ACOND := TTACOND->ZZ5_ACOND2
			c2OPERA := TTACOND->ZZ5_OPERA2
		EndIf
	Else
		c2ACOND := cZZ5_2ACOND
		c2OPERA := cZZ5_2OPERA
	EndIf

	For	x:=1 To Len(aDescPal)

		If	x==1
			cDescPal1 := 'Contem '+aDescPal[x]
		ElseIf	x==2
			cDescPal2 := aDescPal[x]
		ElseIf x==3
			cDescPal3 := aDescPal[x]
		ElseIf	x==4
			cDescPal4 := aDescPal[x]
		ElseIf	x==5
			cDescPal4 += ' e Outros'
			Exit
		EndIf

	Next x

	// Retirado para testes:
	If Upper(AllTrim(ComputerName())) != "CPD10"
		MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
		MSCBCHKSTATUS(.F.)

		/////////////////////////IMPRESSAO MODELO ZEBRA S4M
		/// 2300 (ZPL)///////////////////////////////////
		MSCBINFOETI("Etiquetas Expedição - Projeto Especial ","PROJETO ESPECIAL")
		MSCBBEGIN(1,6,800) // 800

		cLinha   	:= ""
		nTot		:= FT_FLASTREC()
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha  := FT_FREADLN()

			// Alteração Thiago (05/08/2018) - Impressão invertida solicitado por Gaúcho - problema de algumas impressoras:
			cLinha	:= StrTran(cLinha, "FN91", "FD"+AllTrim(cPallet))
			cLinha	:= StrTran(cLinha, "FN92", "FD"+AllTrim(cC5_Num))
			cLinha	:= StrTran(cLinha, "FN93", "FD"+AllTrim(SA1->A1_NOME)+' / '+ AllTrim(SA1->A1_COD))
			cLinha	:= StrTran(cLinha, "FN94", "FD"+Dtoc(MsDate()))
			cLinha	:= StrTran(cLinha, "FN95", "FD"+Substr(Time(),1,5))
			cLinha	:= StrTran(cLinha, "FN96", "FD"+AllTrim(c2ACOND)+' / '+AllTrim(c2OPERA))
			cLinha	:= StrTran(cLinha, "FN971", "FD"+AllTrim(cDescPal1))
			cLinha	:= StrTran(cLinha, "FN972", "FD"+AllTrim(cDescPal2))
			cLinha	:= StrTran(cLinha, "FN973", "FD"+AllTrim(cDescPal3))
			cLinha	:= StrTran(cLinha, "FN974", "FD"+AllTrim(cDescPal4))
			cLinha	:= StrTran(cLinha, "FN98", "FD"+AllTrim(cC5_Num+AllTrim(cPallet)))
			cLinha	:= StrTran(cLinha, "FN99", "FD"+AllTrim(Str(nTotCxa)))
			If !Empty(cDescEnd)
				cLinha	:= StrTran(cLinha, "FN100", "FD"+"Endereco: "+AllTrim(cDescEnd))
			EndIf

			If	Substr(cLinha,1,4) == '^PQ1'
				MSCBWrite('^LRY^FO10,145^GB1136,0,445^FS^LRN')
			EndIf
			MSCBWrite(cLinha)
			FT_FSKIP()
		EndDo

		FT_FUSE()

		MSCBEND()
		MSCBCLOSEPRINTER()
	EndIf

	// Marco pallet como impresso:
	TcSqlExec("UPDATE ZZ5010 SET ZZ5_IMPALL = 'S' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+AllTrim(cPallet)+"' AND ZZ5010.D_E_L_E_T_ = '' ")
	// Atualizo endereço da etiqueta:
	If !Empty(cEnderEst)
		TcSqlExec("UPDATE ZZ5010 SET ZZ5_ENDERE = '"+cEnderEst+"' WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+AllTrim(cPallet)+"' AND ZZ5010.D_E_L_E_T_ = '' ")
	EndIf

	If	!lReimp
		// Após marcar como impresso, efetuo transferência no CD:
		if lCDBudd
			// Efetuando transferência dis itens de saída para entrada via pallet no CD:
			MsAguarde({|| BuscaWS("&a=transfere", "&p="+AllTrim(cC5_Num)+"&l="+AllTrim(cC5_Num)+AllTrim(cPallet)+"&tp="+cTipoCDGr ) }, "Transferindo", "Transferindo itens CD...")
		EndIf

		// Efetuo atualização de quantidade encaixotada no SC9 devido a possíveis estornos de reservas efetuados anteriormente em demais itens:
		If lLiberac
			cUpd := ""
			cUpd += "UPDATE " + RETSQLNAME("SC9") + " SET C9_QTDENC = ISNULL((SELECT SUM(ZZ5_QTDENC) FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = C9_PEDIDO AND ZZ5_ITEM = C9_ITEM AND ZZ5_DOC = '' AND ZZ5010.D_E_L_E_T_ = ''), 0) "
			cUpd += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
			cUpd += "AND C9_PEDIDO = '"+cC5_Num+"' "
			cUpd += "AND C9_NFISCAL = '' "
			cUpd += "AND "+RETSQLNAME("SC9")+".D_E_L_E_T_ = '' "
			TCSQLEXEC(cUpd)
		EndIf

		// Seto status do pedido para fins fiscal:
		cUpd := "UPDATE "+RETSQLNAME("SC5")+" SET C5_LOCFIS = 'GERADO PALLET' "
		cUpd += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
		cUpd += "AND C5_NUM = '"+cC5_Num+"' "
		cUpd += "AND "+RETSQLNAME("SC5")+".D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpd)

		// Altero status logística:
		U_BUD1162(cC5_Num, 'GERADO PALLET ['+AllTrim(cPallet)+'] COM ['+AllTrim(Str(nTotCxa))+'] CAIXA(S)')

		// Efetuo vinculo com RFID:
		if !Empty(cPallet)
			While !LerRFID()
				// No caso de erro:
				Sleep(1000)
			EndDo
		EndIf

		if lCDBudd .And. !Empty(cPallet)
			// No caso de encaixotamento no CD, preciso estornar os vinculos efetuados de etiquetas não finalizadas:
			MsAguarde({|| EstornoETQ() }, "Estornando", "Estornando etiquetas não finalizadas...")

			// Busco o último pallet gerado:
			If (Select("TT1120A") <> 0)
				dbSelectArea("TT1120A")
				dbCloseArea()
			EndIf
			cQuery := "SELECT TOP 1 ISNULL(MAX(ZZ5_PALLET), '0000') AS N_PALLET FROM ZZ5010 (NOLOCK) WHERE ZZ5_FILIAL = '01' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET <> '' AND ZZ5010.D_E_L_E_T_ = '' "
			TCQuery cQuery NEW ALIAS "TT1120A"
			If !TT1120A->(EOF())
				cPallet	 := AllTrim(TT1120A->N_PALLET)
			EndIf
		EndIf

		// Busco próximo pallet:
		cPallet := Soma1(cPallet)

		// Depois de gerar o pallet novo, verifico endereço livre:
		if lCDBudd
			VerEndEst(cC5_Num+AllTrim(cPallet))
		EndIf

		// Atualizo variáveis:
		cSayPall := "Número do Pallet - "+cPallet

		// Seto focus para continuar encaixotamento:
		oCodBar:SetFocus()
	EndIf

Return

// Função para verificar se a etiqueta já não foi emitida por outra estação anteriormente:
Static Function VerEtqEmit()
	Local cBuffCx   := cNumCxa

	// Verifico se a etiqueta com essa numeração já foi utilizada:
	If (Select("TT1120A") <> 0)
		DbSelectArea("TT1120A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZZ5_NUMETQ "
	cQuery += "FROM ZZ5010 (NOLOCK) "
	cQuery += "WHERE ZZ5_FILIAL = '01' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_NUMETQ = '"+cNumCxa+"' "
	cQuery += "AND ZZ5010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120A"
	If !TT1120A->(Eof())
		// Caso identificou uma etiqueta já gerada anteriormente, é necessário buscar a próxima sequência:
		cNumCxa := B1120NumEtq()

		// Após atualizar o número de caixa, efetuo correção também nas tabelas de vínculo:
		if cTipoCDGr == "GAIOLA"
			cUpd := "UPDATE ZDU010 SET ZDU_CAIXA = '"+cNumCxa+"' "
			cUpd += "FROM ZDU010 (NOLOCK) "
			cUpd += "WHERE ZDU_FILIAL = '' "
			cUpd += "	AND ZDU_PEDCXA = '"+cC5_Num+"' "
			cUpd += "	AND ZDU_CAIXA = '"+cBuffCx+"' "
			cUpd += "	AND ZDU_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"' "
			cUpd += "	AND ZDU010.D_E_L_E_T_ = '' "
			TCSQLEXEC(cUpd)
		Elseif cTipoCDGr == "SALDO"
			cUpd := "UPDATE ZDY010 SET ZDY_CAIXA = '"+cNumCxa+"' "
			cUpd += "FROM ZDY010 (NOLOCK) "
			cUpd += "WHERE ZDY_FILIAL = '' "
			cUpd += "	AND ZDY_PEDCXA = '"+cC5_Num+"' "
			cUpd += "	AND ZDY_CAIXA = '"+cBuffCx+"' "
			cUpd += "	AND ZDY_ESTCXA = '"+Upper(AllTrim(ComputerName()))+"' "
			cUpd += "	AND ZDY010.D_E_L_E_T_ = '' "
			TCSQLEXEC(cUpd)
		EndIf
	EndIf

Return (.T.)

Static Function B1120Grava()
	Local cOrigemCD	:= ""

	If lCDBudd
		// Inicialmente verifico se a etiqueta já não foi gravada:
		VerEtqEmit()

		// Na primeira caixa ou se o parâmetro estiver habilitado, efetua validação de endereço disponível:
		if cNumCxa == "000001" .Or. GetMv("BD_1120VED")
			MsAguarde({|| VerEndEst(cC5_Num+AllTrim(cPallet)) }, "Endereco", "Aguarde, verificando endereço disponível...")
		EndIf
	EndIf

	// Caso o operador efetuou qualquer alteração, deverá finalizar o pedido obrigatóriamente:
	lFinalizar	:= .T.

	MsUnlockAll()
	RecLock('ZZ5',.T.)
	ZZ5->ZZ5_FILIAL	:= xFilial('ZZ5')
	ZZ5->ZZ5_PEDIDO	:= cC5_Num
	ZZ5->ZZ5_ITEM	:= cC6_Item
	ZZ5->ZZ5_SEQENC	:= B1120Prox()
	ZZ5->ZZ5_NUMETQ	:= cNumCxa
	ZZ5->ZZ5_PRODUT	:= cC6_Produto
	ZZ5->ZZ5_CODBAR	:= Posicione("SB1", 1, xFilial("SB1")+cC6_Produto, "B1_CODBAR")
	ZZ5->ZZ5_QTDENC	:= nPcsCxa
	ZZ5->ZZ5_DATA	:= MsDate()
	ZZ5->ZZ5_COLETO	:= ''
	ZZ5->ZZ5_DOC	:= ''
	ZZ5->ZZ5_SERIE	:= ''
	ZZ5->ZZ5_EPVOL	:= cCodCxa
	ZZ5->ZZ5_EPVOLS	:= ''
	ZZ5->ZZ5_ESP	:= 'S'
	ZZ5->ZZ5_TPETQ	:= cZZ5_TPETQ
	ZZ5->ZZ5_IMPRES	:= 'N'
	ZZ5->ZZ5_VolIni := cVolPRI //iif (!empty(cVolINI),cVolIni,cVolIniA)
	ZZ5->ZZ5_VolFim := cVolFim
	ZZ5->ZZ5_CDCOMB:= SUBSTR(cGet1,1,6)
	If	lPallet
		ZZ5->ZZ5_PALLET  := AllTrim(cPallet)
		ZZ5->ZZ5_IMPALL  := 'N'
	EndIf
	// No caso de utilização de liberação:
	If lLiberac
		ZZ5->ZZ5_QTDLIB	:= nPcsCxa
	Else
		ZZ5->ZZ5_QTDLIB	:= 0
	EndIf
	// Dados do operador e do ajudante:
	ZZ5->ZZ5_ACONDI	:= cZZ5_1ACOND
	ZZ5->ZZ5_OPERAD	:= cZZ5_1OPERA
	ZZ5->ZZ5_ACOND2	:= cZZ5_2ACOND
	ZZ5->ZZ5_OPERA2	:= cZZ5_2OPERA
	// Adiciono vínculo efetuado quando efetuado encaixotamento no CD:
	If lCDBudd
		// Verifico origem do lançamento:
		cOrigemCD	+= IIF(!Empty(cTipoCDGr), "["+AllTrim(cTipoCDGr)+"]", "")
		cOrigemCD	+= IIF(!Empty(cGaiola), "["+AllTrim(cGaiola)+"]", "")
		cOrigemCD	+= IIF(!Empty(cCDItemGa), "["+AllTrim(cCDItemGa)+"]", "")
		cOrigemCD	+= IIF(!Empty(cCDNumOP), "["+AllTrim(cCDNumOP)+"]", "")

		// Armazeno no código do box:
		ZZ5->ZZ5_CODBOX	:= cOrigemCD
		ZZ5->ZZ5_ENDERE := cEnderEst
	EndIf
	// Dados técnicos para log de registro:
	ZZ5->ZZ5_CODIMP	:= Upper(AllTrim(ComputerName()))
	ZZ5->ZZ5_IDCOLE := Upper(AllTrim(ComputerName()))
	ZZ5->ZZ5_DTRET	:= MsDate()
	ZZ5->ZZ5_HRRET	:= Substr(Time(),1,5)
	MsUnlock()
	MsUnlockAll()

	// Retirar vinculo da gaiola:
	if lCDBudd
		// Efetuo atualização na gaiola:
		IF cPrefCDGa == "GL"
			TCSQLEXEC("UPDATE ZDT010 SET ZDT_STATUS = 'ENCAIXOTANDO', ZDT_OBS = 'ENCAIXOTANDO POR ["+AllTrim(Upper(cUserName))+"] DIA ["+DtoC(dDataBase)+"] OP ["+AllTrim(cCDNumOP)+"]' WHERE ZDT_FILIAL = '' AND ZDT_CODIGO = '"+StrTran(cGaiola, cPrefCDGa, "")+"' AND "+RetSQLName("ZDT")+".D_E_L_E_T_ = '' ")

			cCodGai := StrTran(cGaiola, cPrefCDGa, "")
			U_BUD1516(.T.,cCodGai,"A","ENCAIXOTANDO")

		ENDIF

	EndIf
	// Efetuo atualização na ZDX:
	TCSQLEXEC("UPDATE ZDX010 SET ZDX_IP = '"+Alltrim(GetClientIP())+"', ZDX_DTATU = '"+DtoS(dDataBase)+"', ZDX_HRATU = '"+Time()+"', ZDX_PEDIDO = '"+cC5_Num+"', ZDX_USUARI = '"+Upper(AllTrim(cUserName))+"' WHERE ZDX_FILIAL = '' AND ZDX_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' AND ZDX010.D_E_L_E_T_ = '' ")

	aAdd(aVetor,{cC5_Num, cC6_Item, cC6_PRODUTO, cB1_DESC, cNumCxa, ZZ5->ZZ5_SeqEnc, SC5->C5_CLIENTE, SC5->C5_LOJACLI, nPcsCxa, cTotCxa})

Return

Static Function B1120Prox()
	cC9_SEQENC	:= '00'
	If lLiberac
		// No caso quando existe liberação prévia:
		If	Select('SEQENC') <> 0
			SEQENC->(DbCloseArea())
		EndIf
		BeginSql Alias 'SEQENC'
			SELECT
				MAX(ISNULL(C9_SEQENC, '00')) AS C9_SEQENC
			FROM
				%Table:SC9% SC9 (NOLOCK)
			WHERE
				SC9.%NotDel%
				AND C9_FILIAL = %xFilial:SC9%
				AND C9_PEDIDO = %Exp:cC5_NUM%
				AND C9_NFISCAL = ' '
				AND C9_ITEM = %Exp:cC6_Item%
				AND C9_PRODUTO = %Exp:cC6_Produto%
		EndSql
		cC9_SEQENC	:= SEQENC->C9_SEQENC
	Else
		If	Select('SEQENC') <> 0
			SEQENC->(DbCloseArea())
		EndIf
		BeginSql Alias 'SEQENC'
			SELECT
				MAX(ISNULL(C9_SEQENC, '00')) AS C9_SEQENC
			FROM
				%Table:SC9% SC9 (NOLOCK)
			WHERE
				SC9.%NotDel%
				AND C9_FILIAL = %xFilial:SC9%
				AND C9_PEDIDO = %Exp:cC5_NUM%
		EndSql
		cC9_SEQENC	:= Soma1(SEQENC->C9_SEQENC)
	End If

Return (cC9_SEQENC)

Static Function B1120Reserv()

	Local cAliasRes := 'RES1120'
	Local cC0_NUM	  := CriaVar('C0_NUM',.F.)
	Local nC0_QUANT := nPcsCxa

	// Somente se efetua reserva:
	If lReserva
		If	Select(cAliasRes) <> 0
			(cAliasRes)->(DbCloseArea())
		EndIf

		BeginSql Alias cAliasRes
			Column C0_RECNO as Numeric(12, 0)
			SELECT
				ISNULL(SC0.R_E_C_N_O_, 0) AS C0_RECNO
			FROM
				%Table:SC0% SC0 (NOLOCK)
			WHERE
				SC0.%NotDel%
				AND C0_FILIAL = %xFilial:SC0%
				AND C0_DOCRES = %Exp:cC5_NUM%
				AND C0_PRODUTO = %Exp:cC6_Produto%
				AND C0_LOCAL = %Exp:cC6_LOCAL%
				AND C0_QUANT > 0
		EndSql

		If	!Empty((cAliasRes)->C0_RECNO)
			SC0->(DbGoto((cAliasRes)->C0_RECNO))
			cC0_NUM   := SC0->C0_NUM
			nC0_QUANT += SC0->C0_QUANT
			A430Reserv ( { 3, 'PD', SC0->C0_DOCRES, cUserName, cFilial} , SC0->C0_NUM, SC0->C0_Produto, SC0->C0_Local, SC0->C0_QUANT, {'','','',''})
		Else
			cC0_NUM := B1120NumRes()
		EndIf

		A430Reserv ( { 1, 'PD', cC5_Num, cUserName, cFilial} , cC0_NUM, cC6_Produto, cC6_LOCAL, nC0_QUANT, {'','','',''})
	End If

	// Atualiza Status pedido Logística (01/12/2015 - Thiago):
	U_BUD1162(cC5_Num, 'ENCAIXOTANDO')
	// Fim - Atualiza Status pedido Logística (01/12/2015 - Thiago):

	// Thiago 25/01/2015 para atualizar a quantidade encaixotada solicitada pelo fiscal:
	nC6_QTDENCX	:= 0

	// Busco quantiadde no ZZ5:
	If Select("ZZ5QTD") <> 0
		ZZ5QTD->(DbCloseArea())
	EndIf
	BeginSql Alias "ZZ5QTD"
		SELECT
			DISTINCT TOP 1 SUM(ZZ5_QTDENC) AS QTD_ENC
		FROM
			%Table:ZZ5%
		WHERE
			%NotDel%
			AND ZZ5_FILIAL = %xFilial:ZZ5%
			AND ZZ5_PEDIDO = %Exp:cC5_Num%
			AND ZZ5_ITEM = %Exp:cC6_Item%
			AND ZZ5_PRODUT = %Exp:cC6_Produto%
			AND ZZ5_DOC = ' '
	EndSql
	If !ZZ5QTD->(Eof())
		nC6_QTDENCX	:= ZZ5QTD->QTD_ENC
	EndIf

	// Atualizo para o SC6 quantidade total encaixotada:
	cUpd := ""
	cUpd += "UPDATE " + RETSQLNAME("SC6") + " SET C6_QTDENCX = '"+AllTrim(Str(nC6_QTDENCX))+"' "
	cUpd += "WHERE "+RETSQLNAME("SC6")+".D_E_L_E_T_ = '' "
	cUpd += "AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cUpd += "AND C6_NUM = '"+cC5_Num+"' "
	cUpd += "AND C6_ITEM = '"+cC6_Item+"' "
	cUpd += "AND C6_PRODUTO = '"+cC6_Produto+"' "
	TCSQLEXEC(cUpd)

	// Caso esteja trabalhando com reserva no SC9:
	If lLiberac
		nC9_QTDENC	:= 0

		// Busco quantiadde no ZZ5 que não foi faturada:
		If Select("ZZ5QTD") <> 0
			ZZ5QTD->(DbCloseArea())
		EndIf
		BeginSql Alias "ZZ5QTD"
			SELECT
				DISTINCT TOP 1 SUM(ZZ5_QTDENC) AS QTD_ENC
			FROM
				%Table:ZZ5%
			WHERE
				%NotDel%
				AND ZZ5_FILIAL = %xFilial:ZZ5%
				AND ZZ5_PEDIDO = %Exp:cC5_Num%
				AND ZZ5_PRODUT = %Exp:cC6_Produto%
				AND ZZ5_ITEM = %Exp:cC6_Item%
				AND ZZ5_DOC = ' '
		EndSql
		If !ZZ5QTD->(Eof())
			nC9_QTDENC	:= ZZ5QTD->QTD_ENC
		EndIf

		// EFetuo atualização no SC9:
		cUpd := ""
		cUpd += "UPDATE " + RETSQLNAME("SC9") + " SET C9_QTDENC = '"+AllTrim(Str(nC9_QTDENC))+"' "
		cUpd += " 									, C9_CTRETQ = 'E' "
		cUpd += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
		cUpd += "AND C9_PEDIDO = '"+cC5_Num+"' "
		cUpd += "AND C9_ITEM = '"+cC6_Item+"' "
		cUpd += "AND C9_PRODUTO = '"+cC6_Produto+"' "
		cUpd += "AND C9_NFISCAL = '' "
		cUpd += "AND "+RETSQLNAME("SC9")+".D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpd)

		// Atualizo status para ZCA:
		cUpd := ""
		cUpd += "UPDATE ZCA010 SET ZCA_STATUS = 'ENCAIXOTANDO' "
		cUpd += "				 , ZCA_CSTAT = 'CARREGADO' "
		cUpd += "				 , ZCA_DCREC = '"+DtoS(MsDate())+"' "
		cUpd += "				 , ZCA_HCREC = '"+Substr(Time(),1,5)+"' "
		cUpd += "WHERE ZCA010.D_E_L_E_T_ = '' "
		cUpd += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"' "
		cUpd += "AND ZCA_PEDIDO = '"+cC5_Num+"' "
		TCSQLEXEC(cUpd)
	EndIf

Return

Static Function B1120NumRes()

	If	Select('NUMRES') <> 0
		NUMRES->(DbCloseArea())
	EndIf

	BeginSql Alias 'NUMRES'
		SELECT
			MAX(ISNULL(C0_NUM, '000000')) AS C0_NUM
		FROM
			%Table:SC0%
		WHERE
			C0_FILIAL = %xFilial:SC0%
			AND %NotDel%
	EndSql

Return ( Soma1(NUMRES->C0_NUM) )

Static Function B1120Saldo()

	Local aCampos		:= {'C6_ITEM','B1_CODBAR','B1_DESC','ZT_DESCRI','C6_LOCAL','C6_QTDVEN','C6_QTDENT','C6_QTDEMP','C6_QTDRESE','C0_QUANT','ZZ5_QTDENC','EE5_CODEMB','EE5_DESC','Z7_QTDPCT','Z7_QTDCAIX','ZZ5_NUMETQ'}
	Local aPosObj  	:= {}   // Array com as dimensoes dos objetos
	Local aSizeT   	:= MsAdvSize(.F., .F.)				// Size da Dialog
	Local aObjects   	:= {}   // Array com os objetos
	Local aInfo      	:= {}   // Array com as dimensoes
	Local aButtons   	:= {}
	Local nOpc			:= 2
	Local x := 0

	Private aCols 	:= {}
	Private aHeader 	:= {}
	Private aRotina 	:= { {"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}

	SX3->(dbSetOrder(2))
	For x:=1 to Len(aCampos)

		If	aCampos[x] == 'C6_QTDEMP'
			Aadd(aHeader,{'Saldo','C6_QUANT',cMascQtd,TamSx3('C6_QTDVEN')[1],TamSx3('C6_QTDVEN')[2],.T.,,'N',,})
		EndIf

		SX3->(dbSeek(aCampos[x]))
		If	AllTrim(SX3->X3_CAMPO) == 'C0_QUANT'
			Aadd(aHeader,{'Qtd.Reservada', SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				.T., SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		Else
			Aadd(aHeader,{TRIM(X3TITULO()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				.T., SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		EndIf

	Next

	// Cria Fonte
	oFont := TFont():New("Arial",,16,,.T.,,,,,.F.)

	B1120Carga()

	/* Divide a tela lateralmente */
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T., .F. } ) // Dados da Enchoice
	AAdd( aObjects, { 100, 100, .T., .T., .T. } ) // Dados da GetDados
	AAdd( aObjects, { 100,  15, .T., .F., .F. } )
	aInfo   := { aSizeT[1], aSizeT[2], aSizeT[3], aSizeT[4], 2, 2 }  //(Linha Inicial, Coluna Inicial, Linha Final, Coluna Final)
	aPosObj := MsObjSize( aInfo, aObjects,  , .F. )

	oDlgSld := TDialog():New(aSizeT[7],0,aSizeT[6]-100,aSizeT[5]-200,"Informações do Pedido Selecionado",,,,,,,,,.T.,,,,,)
	oDlgSld:lCentered := .T.

	// Cria a Enchoice
	bCancel := { || oDlgSld:End() }
	bOK 	 := { || oDlgSld:End() }

	// Adiciona botão de pesquisa de Etiquetas
	aAdd(aButtons,{"PEDIDO",{|| MsAguarde({|| U_B1120Etiq(cC5_Num, GdFieldGet('C6_ITEM',n), AllTrim(Posicione('SB1',5,xFilial('SB1')+GdFieldGet('B1_CODBAR',n),'B1_COD')) +' - '+;
		AllTrim(Posicione('SB1',5,xFilial('SB1')+GdFieldGet('B1_CODBAR',n),'B1_DESC')),;
		cA1_Nome, cA1_Mun, cA1_Est, GdFieldGet('B1_CODBAR',n), dC5_DtEnt)},;
		OemToAnsi("Filtrando Etiquetas do Item do Pedido ..."),OemToansi("Aguarde, Filtrando Etiquetas......"),.F.) }    ,"Etiquetas"})

	// Adiciona botão de visualização das Reservas
	aAdd(aButtons,{"FORM",{|| MsAguarde({|| B1120SC0()()},OemToAnsi("Filtrando Reservas do Item do Pedido ..."),OemToansi("Aguarde, Filtrando Reservas ......"),.F.) }    ,"Reservas"})

	// Cria visualizacao de codigo e descricao do Tecido
	TSay():New(08,08,{|| "Pedido: " }, oDlgSld,,oFont,,,,.T.,CLR_RED,)
	oSay1 := TSay():New(08,035,{|| cC5_NUM  }, oDlgSld,,oFont,,,,.T.,CLR_RED,)
	oSay2 := TSay():New(08,060,{|| cA1_NOME }, oDlgSld,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas já alocadas
	TSay():New(08,310,{|| "Data Entrega: " }, oDlgSld,,oFont,,,,.T.,CLR_RED,)
	oSay3 := TSay():New(08,355,{|| dC5_DTENT }, oDlgSld,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas disponíveis
	TSay():New(08,410,{|| "Cidade/UF : " }, oDlgSld,,oFont,,,,.T.,CLR_RED,)
	oSay4 := TSay():New(08,445,{|| RTrim(cA1_MUN)+'/'+cA1_EST }, oDlgSld,,oFont,,,,.T.,CLR_RED,)

	oGetSld := MsGetDados():New(aPosObj[1,1]+15,aPosObj[2,2],aPosObj[3,3]-60,aPosObj[3,4]-100,nOpc,,,,.T.,{},,.F.,Len(aCols),,,,"",oDlgSld)

	ACTIVATE MSDIALOG oDlgSld ON INIT (EnchoiceBar(oDlgSld,bOk,bCancel,,aButtons)) CENTERED

Return

// Função para verificar se o pedido é de distribuição:
Static Function VerPedDistr(cPedVer)

	// Inicialmente, verifico se trata-se de um pedido de reserva de distribuição futura:
	If (Select("TD1120A") <> 0)
		dbSelectArea("TD1120A")
		dbCloseArea()
	EndIf
	cQuery := "SELECT TOP 1 C5_DISTRIB "
	cQuery += "FROM SC5010 (NOLOCK) "
	cQuery += "WHERE C5_FILIAL = '01' "
	cQuery += "AND C5_NUM = '"+cPedVer+"' "
	cQuery += "AND C5_DISTRIB = 'R' "
	cQuery += "AND SC5010.D_E_L_E_T_ = '' "
	TCQuery cQuery NEW ALIAS "TD1120A"
	lDistrPed   := .F.
	If !TD1120A->(Eof())
		// Pedidos reserva, serão cancelados anteriormente, portanto, deverão permitir encaixotamento em cima da quantidade original:
		lDistrPed   := .T.
		cColEmpDs   := 'C6_QTDVEN'
	EndIf

Return lDistrPed

Static Function B1120Carga(cAlias, cWhere)

	Local aArea := GetArea()
	Local cQtdC	:= "% C6_QTDCANC %"
	Local cQtdR	:= "% C6_QTDEMP %"
	Local cQtdE	:= "% (C6_QTDVEN - C6_QTDENT - C6_QTDCANC) %"
	local cQtdW	:= "% ((C6_QTDVEN - C6_QTDCANC) > 0) AND %"
	Local nC0_Quant := 0
	Local x := 0
	Local y := 0

	Default cWhere := "% C5_NUM = '"+cC5_Num+"' %"
	//Default cAlias := GetNextAlias()
	Default cAlias := "TT1120A"

	// Verifica pedido de distribuição:
	If VerPedDistr(cC5_Num)
		cQtdE	    := "% (C6_QTDVEN - C6_QTDENT) %"
		cQtdW	    := "% ((C6_QTDVEN) > 0) AND %"
		cQtdC	    := "% 0 AS C6_QTDCANC %"
		cQtdR	    := "% C6_QTDVEN AS C6_QTDEMP %"
	EndIf

	If	Select(cAlias) <> 0
		(cAlias)->(DbCloseArea())
	EndIf

	If lLiberac .And. !lDistrPed
		// Caso o pedido seja reservado antes (existente no SC9):
		cQtdE	:= "% (C6_QTDEMP) %"
		cQtdW	:= "% (C6_QTDEMP > 0) AND %"
	EndIf

	BeginSql Alias cAlias
		Column Z7_QTDPCT as Numeric(05, 0)
		Column Z7_QTDCAIX as Numeric(05, 0)
		Column C6_QTDVEN as Numeric(16, 4)
		Column C6_QTDENT as Numeric(16, 4)
		Column C6_QTDCANC as Numeric(16, 4)
		Column C6_QTDEMP as Numeric(16, 4)
		Column C6_QTDRESE as Numeric(16, 4)
		Column ZZ5_QTDENC as Numeric(09, 2)
		Column Z7_QTDMIN as Numeric(05, 0)
		SELECT
			B1_CODBAR,
			C6_ITEM,
			C6_PRODUTO,
			B1_DESC,
			C6_LOCAL,
			EE5_CODEMB,
			EE5_DESC,
			Z7_QTDPCT,
			Z7_QTDCAIX,
			Z7_QTDMIN,
			%Exp:cQtdE% AS C6_QUANT,%Exp:cQtdR%,
			C6_QTDVEN,
			C6_QTDENT,
			C6_QTDRESE,
			C6_QTDENCX,
			MAX(ISNULL(ZZ5_NUMETQ, '000000')) AS ZZ5_NUMETQ,
			SUM(ISNULL(ZZ5_QTDENC, 0)) AS ZZ5_QTDENC,
			ZT_COD,
			ZT_DESCRI,
			C5_CLIENTE,
			C5_LOJACLI,
			%Exp:cQtdC%,
			C6_BLQ,
			ISNULL(A7_CODCLI, ' ') AS A7_CODCLI,
			ISNULL(A7_DESCCLI, ' ') AS A7_DESCCLI,
			ISNULL(A7_BARRA, ' ') AS A7_BARRA,
			C6_CODTPCX,
			ROUND(SUM(EE5_M3 * 1000) / SUM(Z7_M3 * 1000), 0) AS QTDCAIXA
		FROM
			%Table:SC5% SC5
		INNER JOIN %Table:SC6% SC6 (NOLOCK)
		ON C6_NUM = C5_NUM
		INNER JOIN %Table:SB1% SB1 (NOLOCK)
		ON B1_COD = C6_PRODUTO
		INNER JOIN %Table:SZ7% SZ7 (NOLOCK)
		ON Z7_COD = C6_CODMOD
		LEFT JOIN %Table:EE5% EE5 (NOLOCK)
		ON EE5.%NotDel%
			AND EE5_FILIAL = %xFilial:EE5%
			AND EE5_CODEMB = C6_CODTPCX // JONAS - 17/02/2014
			//LEFT  JOIN %Table:EE5% EE5 (NOLOCK)
		ON EE5.%NotDel%
			AND EE5_FILIAL = %xFilial:EE5%
			AND EE5_CODEMB = Z7_TPCX
		LEFT JOIN %Table:ZZ5% ZZ5 (NOLOCK)
		ON ZZ5.%NotDel%
			AND ZZ5_FILIAL = %xFilial:ZZ5%
			AND ZZ5_PEDIDO = C5_NUM
			AND ZZ5_ITEM = C6_ITEM
			AND ZZ5_DOC = ' '
		LEFT JOIN %Table:SZT% SZT (NOLOCK)
		ON SZT.%NotDel%
			AND ZT_FILIAL = %xFilial:SZT%
			AND ZT_COD = SUBSTRING(C6_PRODUTO, 11, 4)
		LEFT JOIN %Table:SA7% SA7 (NOLOCK)
		ON SA7.%NotDel%
			AND A7_FILIAL = %xFilial:SA7%
			AND A7_CLIENTE = C5_CLIENTE
			AND A7_LOJA = C5_LOJACLI
			AND C6_PRODUTO = A7_PRODUTO
		WHERE
			%Exp:cQtdW% SC5.%NotDel%
			AND C5_FILIAL = %xFilial:SC5%
			AND SC6.%NotDel%
			AND C6_FILIAL = %xFilial:SC6%
			AND SB1.%NotDel%
			AND B1_FILIAL = %xFilial:SB1%
			AND SZ7.%NotDel%
			AND Z7_FILIAL = %xFilial:SZ7%
			AND %Exp:cWhere%
		GROUP BY
			C6_ITEM,
			C6_PRODUTO,
			C6_LOCAL,
			C6_QTDVEN,
			C6_QTDEMP,
			C6_QTDENT,
			C6_QTDRESE,
			C6_QTDENCX,
			C6_CODMOD,
			EE5_CODEMB,
			C5_CLIENTE,
			C5_LOJACLI,
			EE5_DESC,
			Z7_QTDPCT,
			Z7_QTDCAIX,
			B1_CODBAR,
			ZT_COD,
			ZT_DESCRI,
			B1_DESC,
			C6_QTDCANC,
			A7_CODCLI,
			A7_DESCCLI,
			A7_BARRA,
			C6_CODTPCX,
			Z7_QTDMIN,
			C6_BLQ
		ORDER BY
			C6_ITEM
	EndSql

	If	IsInCallStack('B1120SALDO')

		While !(cAlias)->(Eof())

			aAdd(aCols,Array(Len(aHeader)+1))
			nPos 		:= Len(aCols)
			nC0_Quant 	:= 0

			For	x:= 1 To Len(aHeader)

				cCampo := aHeader[x,2]
				If	AllTrim(cCampo) == 'C0_QUANT' .And. nC0_Quant > 0
					aCols[nPos,x] := nC0_Quant
					Loop
				EndIf

				If lReserva
					For	y:=1 To (cAlias)->(FCount())

						If	AllTrim(cCampo) $ AllTrim((cAlias)->(FieldName( y )))
							aCols[nPos,x] := (cAlias)->(FieldGet( y ) )

							If	AllTrim(cCampo) $ 'B1_CODBAR'

								If	Select('Reserv')<>0
									Reserv->(DbCloseArea())
								EndIf

								BeginSql Alias 'Reserv'
									SELECT
										SUM(ISNULL(C0_QUANT, 0)) AS C0_QUANT
									FROM
										%Table:SB1% SB1 (NOLOCK)
									LEFT JOIN %Table:SC0% SC0 (NOLOCK)
									ON SC0.%NotDel%
										AND C0_FILIAL = %xFilial:SC0%
										AND C0_DOCRES = %Exp:cC5_NUM%
										AND C0_PRODUTO = B1_COD
									WHERE
										SB1.%NotDel%
										AND B1_FILIAL = %xFilial:SB1%
										AND B1_CODBAR = %Exp:aCols[nPos,x]%
								EndSql

								If	!Reserv->(Eof())
									nC0_Quant := Reserv->C0_QUANT
								EndIf

							EndIf
							Exit
						EndIf

					Next y
				Else
					nC0_Quant := 0
				End If

				If	Empty(aCols[nPos,GdFieldPos('C0_QUANT')])
					aCols[nPos,GdFieldPos('C0_QUANT')] := 0
				EndIf

			Next x

			aCols[nPos,Len(aHeader)+1] := .F.

			(cAlias)->(DbSkip())

		EndDo

		If	Select(cAlias)<>0
			(cAlias)->(DbCloseArea())
		EndIf

	EndIf

	RestArea(aArea)

Return

User Function B1120Etiq(cNum, cItem, cProduto, cNome, cMun, cEst, cCodBar1, dDtEnt)

	Local aColsAux 	:= aClone(aCols)
	Local aHeadAux 	:= aClone(aHeader)
	Local nAux		 	:= n
	Local aRotAux  	:= aClone(aRotina)
	Local bCancel		:= { || oDlgEtq:End() }
	Local bOk			:= { || oDlgEtq:End() }

	Local aCampos		:= {'ZZ5_NUMETQ','ZZ5_SEQENC','ZZ5_DATA','ZZ5_QTDENC','ZZ5_QTDLIB','ZZ5_EPVOL','EE5_DESC','Z7_QTDPCT','Z7_QTDCAIX','ZZ5_ACONDI','ZZ5_SERIE','ZZ5_DOC'}
	Local aPosObj  	:= {}   // Array com as dimensoes dos objetos
	Local aSizeT   	:= MsAdvSize(.F., .F.)				// Size da Dialog
	Local aObjects   	:= {}   // Array com os objetos
	Local aInfo      	:= {}   // Array com as dimensoes
	Local aButtons   	:= {}
	Local nOpc			:= 2
	Local x				:= 0
	Local y				:= 0

	Private aCols		:= {}
	Private aHeader	:= {}
	Private aRotina 	:= { {"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}

	SX3->(dbSetOrder(2))
	For x:=1 to Len(aCampos)

		SX3->(dbSeek(aCampos[x]))
		If	SX3->(Found())
			Aadd(aHeader,{TRIM(X3TITULO()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				.T., SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		EndIf

	Next

	If	Select('TETQ') <> 0
		TETQ->(DbCloseArea())
	EndIf

	BeginSql Alias 'TETQ'
		Column ZZ5_DATA as Date
		Column ZZ5_QTDENC as Numeric(12, 0)
		Column ZZ5_QTDLIB as Numeric(12, 0)
		SELECT
			ZZ5_PEDIDO,
			ZZ5_ITEM,
			ZZ5_NUMETQ,
			ZZ5_SEQENC,
			ZZ5_DATA,
			ZZ5_QTDENC,
			ZZ5_EPVOL,
			ZZ5_ACONDI,
			EE5_DESC,
			Z7_QTDPCT,
			Z7_QTDCAIX,
			ZZ5_SERIE,
			ZZ5_DOC,
			ZZ5_QTDLIB,
			C6_CODTPCX,
			ROUND(SUM(EE5_M3 * 1000) / SUM(Z7_M3 * 1000), 0) AS QTDCAIXA
		FROM
			%Table:ZZ5% ZZ5 (NOLOCK)
		INNER JOIN %Table:SC6% SC6 (NOLOCK)
		ON SC6.%NotDel%
			AND C6_FILIAL = %xFilial:SC6%
			AND C6_NUM = ZZ5_PEDIDO
			AND C6_PRODUTO = ZZ5_PRODUT
			AND C6_ITEM = ZZ5_ITEM
		INNER JOIN %Table:SB1% SB1 (NOLOCK)
		ON SB1.%NotDel%
			AND B1_FILIAL = %xFilial:SB1%
			AND B1_COD = ZZ5_PRODUT
		INNER JOIN %Table:SZ7% SZ7 (NOLOCK)
		ON Z7_COD = C6_CODMOD
		LEFT JOIN %Table:EE5% EE5 (NOLOCK)
		ON EE5.%NotDel%
			AND EE5_FILIAL = %xFilial:EE5%
			AND EE5_CODEMB = C6_CODTPCX // JONAS - 17/02/2014
			//LEFT  JOIN %Table:EE5% EE5 (NOLOCK)
		ON EE5.%NotDel%
			AND EE5_FILIAL = %xFilial:EE5%
			AND EE5_CODEMB = Z7_TPCX
		WHERE
			ZZ5.%NotDel%
			AND ZZ5_FILIAL = %xFilial:ZZ5%
			AND ZZ5_PEDIDO = %Exp:cNum%
			AND ZZ5_ITEM = %Exp:cItem%
		GROUP BY
			ZZ5_PEDIDO,
			ZZ5_ITEM,
			ZZ5_PRODUT,
			B1_DESC,
			ZZ5_NUMETQ,
			ZZ5_SEQENC,
			ZZ5_CODBAR,
			ZZ5_DATA,
			ZZ5_QTDENC,
			ZZ5_EPVOL,
			ZZ5_ACONDI,
			EE5_DESC,
			Z7_QTDPCT,
			Z7_QTDCAIX,
			ZZ5_SERIE,
			ZZ5_DOC,
			ZZ5_QTDLIB,
			C6_CODTPCX
	EndSql

	If	TETQ->(Eof())
		MsgInfo('Para o Produto - '+cProduto+' Item '+cItem+' do Pedido ' + cNUM + ' ainda não foi incluido nenhuma caixa !!!')
		Return
	EndIf

	While !TETQ->(Eof())

		aAdd(aCols,Array(Len(aHeader)+1))
		nPos 		:= Len(aCols)

		For	x:= 1 To Len(aHeader)

			cCampo := aHeader[x,2]

			For	y:=1 To TETQ->(FCount())

				If	AllTrim(cCampo) $ AllTrim(TETQ->(FieldName( y )))
					aCols[nPos,x] := TETQ->(FieldGet( y ) )
				EndIf

			Next

		Next

		aCols[nPos,Len(aHeader)+1] := .F.

		TETQ->(DbSkip())

	EndDo

	/* Divide a tela lateralmente */
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T., .F. } ) // Dados da Enchoice
	AAdd( aObjects, { 100, 100, .T., .T., .T. } ) // Dados da GetDados
	AAdd( aObjects, { 100,  15, .T., .F., .F. } )
	aInfo   := { aSizeT[1], aSizeT[2], aSizeT[3], aSizeT[4], 2, 2 }  //(Linha Inicial, Coluna Inicial, Linha Final, Coluna Final)
	aPosObj := MsObjSize( aInfo, aObjects,  , .F. )

	oDlgEtq := TDialog():New(aSizeT[7],0,aSizeT[6]-100,aSizeT[5]-200,"Etiquetas do Item "+cItem+" do Pedido "+ cNum,,,,,,,,,.T.,,,,,)
	oDlgEtq:lCentered := .T.

	// Cria visualizacao de codigo e descricao do Tecido
	TSay():New(30,08,{|| "Pedido/Item: " }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)
	oSay1 := TSay():New(30,045,{|| cNUM+'/'+cItem  }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)
	oSay2 := TSay():New(30,080,{|| cNOME }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas já alocadas
	TSay():New(30,310,{|| "Data Entrega: " }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)
	oSay3 := TSay():New(30,355,{|| dDTENT }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas disponíveis
	TSay():New(30,410,{|| "Cidade/UF : " }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)
	oSay4 := TSay():New(30,445,{|| RTrim(cMUN)+'/'+cEST }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas disponíveis
	TSay():New(38,08,{|| "Produto : " }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)
	oSay5 := TSay():New(38,045,{|| cProduto+' - '+cCodBar1 }, oDlgEtq,,oFont,,,,.T.,CLR_RED,)

	oGetEtq := MsGetDados():New(aPosObj[1,1]+45,aPosObj[2,2],aPosObj[3,3]-60,aPosObj[3,4]-100,nOpc,,,,.T.,{},,.F.,Len(aCols),,,,,oDlgEtq)

	ACTIVATE MSDIALOG oDlgEtq ON INIT (EnchoiceBar(oDlgEtq,bOk,bCancel,,aButtons)) CENTERED

	aCols 	:= aClone(aColsAux)
	aHeader	:= aClone(aHeadAux)
	aRotina	:= aClone(aRotAux)
	n	    := nAux

Return

Static Function B1120SC0()

	Local aColsAux 	:= aClone(aCols)
	Local aHeadAux 	:= aClone(aHeader)
	Local nAux		 	:= n
	Local aRotAux  	:= aClone(aRotina)
	Local bCancel		:= { || oDlgRes:End() }
	Local bOk			:= { || oDlgRes:End() }
	Local cLocal		:= GdFieldGet('C6_LOCAL',n)
	Local cItem		:= GdFieldGet('C6_ITEM',n)
	Local cCodBar1	:= GdFieldGet('B1_CODBAR',n)
	Local cCod			:= AllTrim(Posicione('SB1',5,xFilial('SB1')+GdFieldGet('B1_CODBAR',n),'B1_COD'))
	Local cProduto	:= cCod +' - '+;
		AllTrim(Posicione('SB1',5,xFilial('SB1')+GdFieldGet('B1_CODBAR',n),'B1_DESC'))

	Local aCampos		:= {'C0_NUM','C0_DOCRES','C0_EMISSAO','C0_LOCAL','C0_QUANT','C0_QTDORIG','C0_SOLICIT'}
	Local aPosObj  	:= {}   // Array com as dimensoes dos objetos
	Local aSizeT   	:= MsAdvSize(.F., .F.)				// Size da Dialog
	Local aObjects   	:= {}   // Array com os objetos
	Local aInfo      	:= {}   // Array com as dimensoes
	Local aButtons   	:= {}
	Local nOpc			:= 2
	Local x				:= 0
	Local y				:= 0

	Private aCols		:= {}
	Private aHeader	:= {}
	Private aRotina 	:= { {"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}

	SX3->(dbSetOrder(2))
	For x:=1 to Len(aCampos)

		SX3->(dbSeek(aCampos[x]))
		If	SX3->(Found())
			Aadd(aHeader,{TRIM(X3TITULO()), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL,;
				.T., SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		EndIf

	Next

	If	Select('TRES') <> 0
		TRES->(DbCloseArea())
	EndIf

	BeginSql Alias 'TRES'
		Column C0_EMISSAO as Date
		Column C0_QUANT as Numeric(12, 0)
		Column C0_QTDORIG as Numeric(12, 0)
		SELECT
			C0_NUM,
			C0_DOCRES,
			C0_EMISSAO,
			C0_LOCAL,
			C0_QUANT,
			C0_QTDORIG,
			C0_SOLICIT
		FROM
			%Table:SC0% SC0 (NOLOCK)
		INNER JOIN %Table:SC6% SC6 (NOLOCK)
		ON SC6.%NotDel%
			AND C6_FILIAL = %xFilial:SC6%
			AND C6_NUM = C0_DOCRES
			AND C6_PRODUTO = C0_PRODUTO
			AND C6_ITEM = %Exp:cItem%
		INNER JOIN %Table:SB1% SB1 (NOLOCK)
		ON SB1.%NotDel%
			AND B1_FILIAL = %xFilial:SB1%
			AND B1_COD = C0_PRODUTO
		INNER JOIN %Table:SZ7% SZ7 (NOLOCK)
		ON SZ7.%NotDel%
			AND Z7_FILIAL = %xFilial:SZ7%
			AND Z7_COD = C6_CODMOD
		LEFT JOIN %Table:EE5% EE5 (NOLOCK)
		ON EE5.%NotDel%
			AND EE5_FILIAL = %xFilial:EE5%
			AND EE5_CODEMB = C6_CODTPCX //Z7_TPCX
		WHERE
			SC0.%NotDel%
			AND C0_FILIAL = %xFilial:SC0%
			AND C0_DOCRES = %Exp:cC5_NUM%
			AND C0_PRODUTO = %Exp:cCod%
			AND C0_LOCAL = %Exp:cLocal%
		GROUP BY
			C0_NUM,
			C0_DOCRES,
			C0_EMISSAO,
			C0_LOCAL,
			C0_QUANT,
			C0_QTDORIG,
			C0_SOLICIT
	EndSql

	If	TRES->(Eof())
		MsgInfo('Para o Produto - '+cProduto+' Item '+cItem+' do Pedido ' + cC5_NUM + ' ainda não foi processado nenhuma Reserva !!!')
		Return
	EndIf

	While !TRES->(Eof())

		aAdd(aCols,Array(Len(aHeader)+1))
		nPos 		:= Len(aCols)

		For	x:= 1 To Len(aHeader)

			cCampo := aHeader[x,2]

			For	y:=1 To TRES->(FCount())

				If	AllTrim(cCampo) $ AllTrim(TRES->(FieldName( y )))
					aCols[nPos,x] := TRES->(FieldGet( y ) )
				EndIf

			Next

		Next

		aCols[nPos,Len(aHeader)+1] := .F.

		TRES->(DbSkip())

	EndDo


	/* Divide a tela lateralmente */
	aObjects := {}
	AAdd( aObjects, { 100, 100, .T., .T., .F. } ) // Dados da Enchoice
	AAdd( aObjects, { 100, 100, .T., .T., .T. } ) // Dados da GetDados
	AAdd( aObjects, { 100,  15, .T., .F., .F. } )
	aInfo   := { aSizeT[1], aSizeT[2], aSizeT[3], aSizeT[4], 2, 2 }  //(Linha Inicial, Coluna Inicial, Linha Final, Coluna Final)
	aPosObj := MsObjSize( aInfo, aObjects,  , .F. )

	oDlgRes := TDialog():New(aSizeT[7],0,aSizeT[6]-100,aSizeT[5]-200,"Reservas do Item "+cItem+" do Pedido "+ cC5_Num,,,,,,,,,.T.,,,,,)
	oDlgRes:lCentered := .T.

	// Cria visualizacao de codigo e descricao do Tecido
	TSay():New(08,08,{|| "Pedido/Item: " }, oDlgRes,,oFont,,,,.T.,CLR_RED,)
	oSay1 := TSay():New(08,045,{|| cC5_NUM+'/'+cItem  }, oDlgRes,,oFont,,,,.T.,CLR_RED,)
	oSay2 := TSay():New(08,080,{|| cA1_NOME }, oDlgRes,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas já alocadas
	TSay():New(08,310,{|| "Data Entrega: " }, oDlgRes,,oFont,,,,.T.,CLR_RED,)
	oSay3 := TSay():New(08,355,{|| dC5_DTENT }, oDlgRes,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas disponíveis
	TSay():New(08,410,{|| "Cidade/UF : " }, oDlgRes,,oFont,,,,.T.,CLR_RED,)
	oSay4 := TSay():New(08,445,{|| RTrim(cA1_MUN)+'/'+cA1_EST }, oDlgRes,,oFont,,,,.T.,CLR_RED,)

	// Cria visualizacao da quantidade de pecas disponíveis
	TSay():New(16,08,{|| "Produto : " }, oDlgRes,,oFont,,,,.T.,CLR_RED,)
	oSay5 := TSay():New(16,045,{|| cProduto+' - '+cCodBar1 }, oDlgRes,,oFont,,,,.T.,CLR_RED,)

	oGetRes := MsGetDados():New(aPosObj[1,1]+25,aPosObj[2,2],aPosObj[3,3]-60,aPosObj[3,4]-100,nOpc,,,,.T.,{},,.F.,Len(aCols),,,,"",oDlgRes)

	ACTIVATE MSDIALOG oDlgRes ON INIT (EnchoiceBar(oDlgRes,bOk,bCancel,,aButtons)) CENTERED

	aCols 		:= aClone(aColsAux)
	aHeader	:= aClone(aHeadAux)
	aRotina	:= aClone(aRotAux)
	n	    	:= nAux

Return

//===================================== Tratativa DUN-14 ==================================
Static Function B1120Dun14(cCodBar)

	//Cálculo do dígito verficador
	nImpar := 0
	nImpar += VAL(SUBSTR(cCodBar,01,1))
	nImpar += VAL(SUBSTR(cCodBar,03,1))
	nImpar += VAL(SUBSTR(cCodBar,05,1))
	nImpar += VAL(SUBSTR(cCodBar,07,1))
	nImpar += VAL(SUBSTR(cCodBar,09,1))
	nImpar += VAL(SUBSTR(cCodBar,11,1))
	nImpar += VAL(SUBSTR(cCodBar,13,1))

	nImpar := nImpar * 3

	nPar := 0
	nPar += VAL(SUBSTR(cCodBar,02,1))
	nPar += VAL(SUBSTR(cCodBar,04,1))
	nPar += VAL(SUBSTR(cCodBar,06,1))
	nPar += VAL(SUBSTR(cCodBar,08,1))
	nPar += VAL(SUBSTR(cCodBar,10,1))
	nPar += VAL(SUBSTR(cCodBar,12,1))

	nDig := 0
	nDig := nImpar + nPar
	nDig := 10 - Mod(nDig,10)

	If nDig == 10
		nDig := 0
	EndIf

	///    TRATATIVA PARA DUN14(GS1) JONAS - 12/09/2018
	cCdCli:= SC5->C5_CLIENTE //SA1->A1_COD
	cCDLoja:= SC5->C5_LOJACLI //SA1->A1_LOJA
	cGrade:= Posicione("SA1", 1, xFilial("SA1")+cCdCli+cCDLoja, "A1_CODENCX")
	IF  ALLTRIM(SC5->C5_OBLOGI2)<>'DUN14OLD'

		If	Select('BUDDUN14')<>0
			BUDDUN14->(DbCloseArea())
		EndIf

		BeginSql Alias 'BUDDUN14'
			SELECT
				DISTINCT LK_CODBAR
			FROM
				%Table:ZCN% ZCN (NOLOCK)
			INNER JOIN %Table:DA1% DA1
			ON LEFT(DA1_CODPRO, 8) = ZCN_REF
				AND SUBSTRING(DA1_CODPRO, 15, 4) = ZCN_TAM
				AND DA1.%NotDel%
			INNER JOIN %Table:SB1% B1
			ON LEFT(B1_COD, 8) = ZCN_REF
				AND SUBSTRING(B1_COD, 15, 4) = ZCN_TAM
				AND B1.%NotDel%
			INNER JOIN %Table:SLK% LK
			ON LK_CODIGO = B1_COD
				AND LK.%NotDel%
			WHERE
				ZCN.%NotDel%
				AND ZCN_QTDE > 0
				AND LK_TPBAR = '2'
				AND ZCN_CODIGO = %Exp:cGrade%
				AND B1_CODBAR = %Exp:cCodBar%
				AND LK_QUANT = ZCN_QTDE
		EndSql
		cBarDun14:= BUDDUN14->LK_CODBAR
	ELSE
		cBarDun14 := Alltrim(cCodBar) + ALLTRIM(STR(nDig))
	ENDIF
	//	cBarDun14 := Alltrim(cCodBar) + ALLTRIM(STR(nDig))
	//Fim cálculo

Return cBarDun14

Static Function Reimpre()

	///MsgRun(OemToAnsi("Aguarde! Selecionando Registros..."),,{||fGetDados1()})
	Local aSize           := {}
	//Local oObjects        := {}
	LocaL aInfo            := {}
	Local _x			:= 0
	Private _oDlg
	Private lInverte := .F.
	Private cMarca  := GetMark()
	Private oMark

	IF Empty(cC5_Num)
		MsgAlert('Não há etiquetas a serem reimpressas.!!!')
		Return (lRet := .F.)
	EndIf

	dbSelectArea("TRB1120")
	dbSetOrder(1)
	__DbZap()

	For _x:=1 To Len(aVetor)

		RecLock("TRB1120",.T.)
		TRB1120->PEDIDO     :=  aVetor[_x,1]
		TRB1120->ITEM	    :=  aVetor[_x,2]
		TRB1120->PRODUTO    :=  aVetor[_x,3]
		TRB1120->DESCPROD   :=  aVetor[_x,4]
		TRB1120->QTD        :=  aVetor[_x,9]
		TRB1120->VOLUME     :=  aVetor[_x,5]
		TRB1120->ITEM       :=  aVetor[_x,2]
		TRB1120->SEQENC     :=  aVetor[_x,6]
		TRB1120->PCSCXA     :=  aVetor[_x,9]
		TRB1120->TOTCXA     :=  aVetor[_x,10]
		MsunLock()
	NEXT _x

	TRB1120->(DbGotop())

	aObjects := {}
	aSize := MsAdvSize()
	AAdd( aObjects, { 013, 019, .T., .T. } ) // Dados da Enchoice
	AAdd( aObjects, { 200, 200, .T., .T. } ) // Dados da getdados
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	_oDlg := TDialog():New(c(180),c(186),c(544),c(939),"REIMPRESSAO DE ETIQUETA",,,,,,,,,.T.,,,,,)
	_oDlg:lCentered := .T.

	oMark := MsSelect():New("TRB1120","OK",,aCpoBro,@lInverte,@cMarca,{aPosObj[2,1]-25,aPosObj[2,2],aPosObj[2,3]-65,aPosObj[2,3]+207},,,_oDlg,,'' )
	oMark:oBrowse:lHasMark		:= .T.
	oMark:oBrowse:lCanAllmark	:= .T.
	oMark:oBrowse:lAdjustColSize:= .T.
	oMark:oBrowse:lJustific     := .F.

	DEFINE FONT oFont1 NAME "Tahoma" SIZE 0, -11 BOLD
	DEFINE FONT oFont2 NAME "Tahoma" SIZE 0, -11 BOLD

	// Cria Componentes Padroes do Sistema
	//	@ C(010),C(005) TO C(052),C(365) LABEL "" PIXEL OF _oDlg
	@ C(165),C(229) Button "&Imprimir (F5)" Size C(037),C(012) PIXEL OF _oDlg  ACTION MsgRun(OemToAnsi("Aguarde! Liberando Pedido(s)..."),,{||Imp()})
	@ C(165),C(333) Button "&Fechar" Size C(037),C(012) PIXEL OF _oDlg ACTION _oDlg:End()//(TTRB1120->(DbCloseArea())

	_oDlg:Activate(,,,.T.,,,)

Return

Static Function Imp()

	dbSelectArea("TRB1120")
	dbGoTop()

	While TRB1120->(!Eof())       //aVetor,{cC5_Num, cC6_Item, cC6_PRODUTO, cB1_DESC, cNumCxa, ZZ5->ZZ5_SeqEnc, SC5->C5_CLIENTE, SC5->C5_LOJACLI, nPcsCxa, cTotCxa})

		IF  !EMPTY(TRB1120->OK)

			MsAguarde({|| U_B1120Print(cC5_Num, TRB1120->ITEM, TRB1120->PRODUTO, TRB1120->VOLUME, ZZ5->ZZ5_SeqEnc, SC5->C5_CLIENTE, SC5->C5_LOJACLI, TRB1120->PCSCXA, TRB1120->TOTCXA, .T.) }, 'Reimpressao', 'Aguarde ... Reimprimindo Etiqueta ' + cNumCxa + '...')

		EndIf

		TRB1120->(dbSkip())
	EndDo

	TRB1120->(dbGoTop())
	oMark:oBrowse:Refresh()

Return

Static Function EtiqPern(cPed,cC6_ProCl)
	Local _i :=0

	cDir	:= Alltrim("\EtiqPrjEsp\Pernambucanas\")
	aFile  	:= {}
	aFile2  := {}
	cArquivo:=''
	cArtDesc:=" "
	/*06051982 INSERIDO TRATIVA ALTERAÇÃO NUMERAÇÃO*/
	aFile  	:= cDir+"F"+cPed+".TXT"
	aFile2  := cDir+"F"+PadL(cPed, 10, "0")+".TXT"
	If FILE(aFile2)
		aFile := Directory(cDir+"F"+PadL(cPed, 10, "0")+".TXT")
	Else
		aFile := Directory(cDir+"F"+cPed+".TXT")
	EndIf

	For _i := 1 To Len(aFile)

		// Variaveis utilizadas na Leitura do Arquivo Texto.
		nHandle  := 0
		cArquivo := Alltrim(aFile[_i][1])
		cLinha   := ""

		If (nHandle := FT_FUSE(AllTrim(cDir+cArquivo))) == -1
			Return
		EndIf

		Procregua(RecCount())

		FT_FGOTOP()

		While !FT_FEOF()

			cLinha := FT_FREADLN()

			If Substr(cLinha,1,2) <> "19"
				FT_FSKIP()
				Loop
			EndIf

			If  substr(cLinha,1,2)$ "19"  .AND. Substr(cLinha,11,6)== cC6_ProCl

				cArt:= Substr(cLinha,11,13)
				cDesc:= Substr(cLinha,24,30)
				cArtDesc:= (ALLTRIM(cArt)+ALLTRIM(cDesc))

			EndIF

			FT_FSKIP()
		Enddo

		FT_FUSE()
		//Rename(cArquivo)
	Next _i

	FClose(cDir+cArquivo)
	//Rename(cArquivo)

Return cArtDesc

Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8/11/12" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

Static Function B1120NumEtq()

	If	Select('TTNUMETQ')<>0
		TTNUMETQ->(DbCloseArea())
	EndIf

	BeginSql Alias 'TTNUMETQ'
		SELECT
			TOP 1 MAX(ISNULL(ZZ5_NUMETQ, '000000')) AS ZZ5_NUMETQ
		FROM
			%Table:ZZ5%
		WHERE
			%NotDel%
			AND ZZ5_FILIAL = %xFilial:ZZ5%
			AND ZZ5_PEDIDO = %Exp:cC5_Num%
		ORDER BY
			ZZ5_NUMETQ DESC
	EndSql

Return(IIf (!TTNUMETQ->(Eof()), Soma1(TTNUMETQ->ZZ5_NUMETQ), '000001'))

/*******************************************************************************************
 * Função para validar padrão de pallet                                                    *
*******************************************************************************************/
User Function B1120VPadr(cC5_Num, cPallet, cC6_Item)
	Local nQtdMin	:= GetMv("BD_1120MPA")		// Quantidade mínima de caixas por pallet
	Local lItemFim	:= .F.

	// Parâmetros:
	If Empty(cC5_Num) .Or. Empty(cPallet) .Or. Empty(cC6_Item) .Or. nQtdMin <= 0
		Return
	EndIf

	// Verifico se o item atual já foi totalmente encaixotado:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 SUM(C6_QTDENCX) AS QTD_ENC, SUM(C6_QTDEMP) AS QTD_RES "
	cQuery += "FROM "+RetSqlName("SC6")+" (NOLOCK) "
	cQuery += "WHERE C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery += "AND C6_NUM = '"+cC5_Num+"' "
	cQuery += "AND C6_ITEM = '"+cC6_Item+"' "
	cQuery += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		If (TT1120->QTD_ENC >= TT1120->QTD_RES) .And. (TT1120->QTD_ENC > 0 .And. TT1120->QTD_RES > 0)
			lItemFim	:= .T.
		EndIf
	EndIf

	// Verifico o pallet atual:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT "
	cQuery += "COUNT(DISTINCT ZZ5_NUMETQ) AS QTD_CAIXA, "		// Quantidade de caixas no pallet
	cQuery += "MAX(EE5_QPALLE) AS QTD_MAX " 					// Quantidade de caixas por pallets cadastrado previamente
	cQuery += "FROM "+RetSqlName("ZZ5")+" (NOLOCK) "
	cQuery += "INNER JOIN "+RetSqlName("EE5")+" (NOLOCK) ON EE5_FILIAL = '"+xFilial("EE5")+"' AND EE5_CODEMB = ZZ5_EPVOL AND "+RetSqlName("EE5")+".D_E_L_E_T_ = '' "
	cQuery += "WHERE ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_PALLET = '"+cPallet+"' "
	cQuery += "AND ZZ5_EPVOL <> '' "
	cQuery += "AND EE5_QPALLE > 0 "
	cQuery += "AND "+RetSqlName("ZZ5")+".D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		// Verifico se a quantidade está acima da mínima:
		If (TT1120->QTD_CAIXA < nQtdMin) .And. !lItemFim
			Return(.T.)
		EndIf

		// Verifico se teve cadastro de quantidade de caixas por pallet previamente:
		If (TT1120->QTD_MAX <= 0)
			Return(.T.)
		EndIf

		// Caso a quantidade de caixas seja superior a cadastrada por embalagem previamente:
		If (TT1120->QTD_CAIXA >= TT1120->QTD_MAX) .Or. lItemFim
			If lCDBudd
				// Para o CD é impresso automaticamente:
				MsgBox('A etiqueta do pallet ['+AllTrim(cPallet)+'] será gerada automaticamente!', 'Etiqueta Pallet', 'INFO')
				B1120Pallet()
			ElseIf GetMv("BD_1120IPL")
				// Para a S/A solicito confirmação de impressão:
				If MsgBox("Quantidade de caixas atingiu o limite configurado. Deseja imprimir a etiqueta do pallet ["+AllTrim(cPallet)+"] nesse momento?", "Pallet", "YESNO")
					B1120Pallet()
				EndIf
			EndIf
		EndIf
	EndIf

Return (.T.)

/*******************************************************************************************
 * Função para incluir padrão de pallet                                                    *
*******************************************************************************************/
User Function B1120Padr(cC5_Num, cPallet)
	Local nQtdCxa		:= 0
	Local nQtdTot		:= 0
	Local nQtdSld		:= 0
	Local nPerTol		:= 0
	Local cTpPall		:= "C"
	Local cSlPall		:= ""
	Local lExiORD		:= .F.
	Local lExiAPO		:= .F.
	Local lExiGUI		:= .F.

	Default lDistrPed	:= .F.

	// Parâmetros:
	If Empty(cC5_Num) .Or. Empty(cPallet)
		Return
	EndIf

	// Primeiramente deleto o pallet caso exista:
	TCSQLEXEC("UPDATE ZC4010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZC4_FILIAL = '"+xFilial("ZC4")+"' AND ZC4_PEDIDO = '"+cC5_Num+"' AND ZC4_PALLET = '"+cPallet+"' AND ZC4010.D_E_L_E_T_ = ''")

	// Verifico se teve mistura de caixas no pallet:
	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 "
	cQuery += "COUNT(DISTINCT ZZ5_EPVOL) AS TP_CAIXA, "
	cQuery += "COUNT(DISTINCT ZZ5_NUMETQ) AS QTD_CAIXA, "
	cQuery += "MAX(EE5_QPALLE) AS QTD_CX_TOT, "
	cQuery += "MAX(EE5_QPALLS) AS QTD_SL_TOT, "
	cQuery += "MAX(EE5_TPALLE) AS QTD_TOL, "
	cQuery += "MAX(EE5_CODEMB) AS TP_EMB, "
	cQuery += "MAX(EE5_LETRA) AS LE_EMB, "
	cQuery += "MAX(ZZ5_PRODUT) AS COD_PRODUT "
	cQuery += "FROM "+RetSqlName("ZZ5")+" (NOLOCK) "
	cQuery += "INNER JOIN "+RetSqlName("EE5")+" (NOLOCK) ON EE5_FILIAL = '"+xFilial("EE5")+"' AND EE5_CODEMB = ZZ5_EPVOL AND "+RetSqlName("EE5")+".D_E_L_E_T_ = '' "
	cQuery += "WHERE ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "AND ZZ5_PEDIDO = '"+cC5_Num+"' "
	cQuery += "AND ZZ5_PALLET = '"+cPallet+"' "
	cQuery += "AND ZZ5_EPVOL <> '' "
	cQuery += "AND "+RetSqlName("ZZ5")+".D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		// Aqui eu preciso efetuar verificação para fazer a inclusão do tipo do pallet, se é parcial ou total. No caso: ZZ5_PAPALL ('P', 'C'):
		nQtdCxa	:= TT1120->QTD_CAIXA
		nQtdTot	:= TT1120->QTD_CX_TOT
		nQtdSld := TT1120->QTD_SL_TOT
		nPerTol	:= IIF(TT1120->QTD_TOL > 0, TT1120->QTD_TOL, 100)

		// Algumas verificações para serem consideradas, quando o pallet for parcial (quantidade de caixa abaixo da tolerância permitida):
		If nQtdCxa < (nQtdTot * nPerTol / 100)
			cTpPall	:= "P"

			// Busco quantidade em aberto ainda do item:
			If cTpPall == "P"
				If (Select("TA1120") <> 0)
					DbSelectArea("TA1120")
					DbCloseArea()
				Endif
				if lDistrPed
					cQuery := "SELECT TOP 1 SUM(C6_QTDVEN - C6_QTDENT) AS QTD_ABE, SUM(C6_QTDENCX) AS QTD_ENC FROM "+RetSqlName("SC6")+" (NOLOCK) WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+cC5_Num+"' AND C6_PRODUTO = '"+TT1120->COD_PRODUT+"' AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
				Else
					cQuery := "SELECT TOP 1 SUM(C6_QTDVEN - C6_QTDENT - C6_QTDCANC) AS QTD_ABE, SUM(C6_QTDENCX) AS QTD_ENC FROM "+RetSqlName("SC6")+" (NOLOCK) WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = '"+cC5_Num+"' AND C6_PRODUTO = '"+TT1120->COD_PRODUT+"' AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
				EndIf
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TA1120"
				If !TA1120->(Eof())
					// Caso a quantidade em aberta seja igual ou inferior a encaixotada, eu considero como pallet completo:
					If TA1120->QTD_ABE <= TA1120->QTD_ENC
						cTpPall	:= "C"
					EndIf
				EndIf
			EndIf

			// Verifico se para aquele produto existe alguma OP em aberto no sistema:
			If cTpPall == "P" .And. Left(cC5_Num, 2) != 'NP'
				If (Select("TA1120") <> 0)
					DbSelectArea("TA1120")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 C2_NUM FROM "+RetSqlName("SC2")+" (NOLOCK) WHERE C2_FILIAL = '"+xFilial("SC2")+"' AND C2_PRODUTO = '"+TT1120->COD_PRODUT+"' AND C2_DATRF = '' AND (C2_QUANT > C2_QUJE) AND "+RetSqlName("SC2")+".D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TA1120"
				If !TA1120->(Eof())
					lExiORD	:= .T.
				EndIf

				// Verifico se existe algum apontamento ainda pendente a ser enviado para o CD:
				If (Select("TA1120") <> 0)
					DbSelectArea("TA1120")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 ZDU_NUMOP  "
				cQuery += "FROM ZDU010 (NOLOCK) "
				//cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZDU_NUMOP AND ZDU_PRODUT = C2_PRODUTO AND SC2010.D_E_L_E_T_ = '' "
				cQuery += "WHERE ZDU_FILIAL = '' "
				cQuery += "AND ZDU_PRODUT = '"+TT1120->COD_PRODUT+"' "
				cQuery += "AND ZDU_LOCFIS = 'SA' "
				cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TA1120"
				If !TA1120->(Eof())
					lExiAPO	:= .T.
				EndIf

				// Verifico se a origem é via guia:
				If (Select("TA1120") <> 0)
					DbSelectArea("TA1120")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 ZDU_NUMOP  "
				cQuery += "FROM ZDU010 (NOLOCK) "
				cQuery += "WHERE ZDU_FILIAL = '' "
				cQuery += "AND ZDU_PEDCXA = '"+cC5_Num+"' "
				cQuery += "AND ZDU_PALLET = '"+cC5_Num+cPallet+"' "
				cQuery += "AND ZDU_ESTAC LIKE '%-gi%' "
				cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TA1120"
				If !TA1120->(Eof())
					lExiGUI	:= .T.
				EndIf

				// Se não existe mais nenhum dos três acima, considero como pallet completo:
				If !lExiORD .And. !lExiAPO .And. !lExiGUI
					cTpPall	:= "C"
				EndIf
			EndIf

			// (A) Verifico se é uma pallet de saldo quando pallet completo:
			If AllTrim(GetMv("BD_1120TPP")) == "A"
				If cTpPall == "C"
					// Se a quantidade de caixa estiver inferior a quantidade cadastrada, considero como pallet de saldo:
					If nQtdSld > 0 .And. nQtdCxa <= nQtdSld
						cSlPall	:= "S"
					EndIf
				EndIf
			EndIf

			// (B) Verifico se é um pallet de saldo caso a quantidade de caixa esteja inferior a quantidade setada, independente se o mesmo é parcial ou não:
			If AllTrim(GetMv("BD_1120TPP")) == "B"
				If nQtdSld > 0 .And. nQtdCxa <= nQtdSld
					cSlPall	:= "S"
				EndIf
			EndIf
		EndIf

		// (C) Verifico se é um pallet de saldo caso a quantidade de caixa esteja inferior a quantidade setada, independente da quantidade desejável de caixa no pallet:
		If AllTrim(GetMv("BD_1120TPP")) == "C"
			If nQtdSld > 0 .And. nQtdCxa <= nQtdSld
				cSlPall	:= "S"
			EndIf
		EndIf

		// (D) Verifico se é um pallet de saldo caso a quantidade de caixa esteja inferior a quantidade setada, independente da quantidade desejável de caixa no pallet, porém sem ser parcial:
		If AllTrim(GetMv("BD_1120TPP")) == "D"
			If cTpPall == "C"
				If nQtdSld > 0 .And. nQtdCxa <= nQtdSld
					cSlPall	:= "S"
				EndIf
			EndIf
		EndIf

		// Verifico se tem pallet com caixas mistas:
		If TT1120->TP_CAIXA != 1 .And. !Empty(cZZ5_2ACOND)
			// Efetuo inclusão do log de padrodnização:
			RecLock("ZC4",.T.)
			ZC4->ZC4_FILIAL	:= xFilial("ZC4")
			ZC4->ZC4_DATA	:= MsDate()
			ZC4->ZC4_HORA	:= Substr(Time(),1,5)
			ZC4->ZC4_PEDIDO := cC5_Num
			ZC4->ZC4_PALLET := cPallet
			ZC4->ZC4_OPERAD := cZZ5_2ACOND
			ZC4->ZC4_DOPERA	:= cZZ5_2OPERA
			ZC4->ZC4_CODCAI	:= TT1120->TP_EMB
			ZC4->ZC4_DESCAI	:= TT1120->LE_EMB
			ZC4->ZC4_QTDCAI	:= TT1120->QTD_CAIXA
			ZC4->ZC4_PADRAO	:= cTpPall
			MsUnLock("ZC4")
		EndIf

		// Efetuo atualização do tipo do pallet na ZZ5:
		TCSQLEXEC("UPDATE ZZ5010 SET ZZ5_PAPALL = '"+cTpPall+"', ZZ5_SAPALL = '"+cSlPall+"' WHERE ZZ5_FILIAL = '"+xFilial("ZZ5")+"' AND ZZ5_PEDIDO = '"+cC5_Num+"' AND ZZ5_PALLET = '"+cPallet+"' AND ZZ5010.D_E_L_E_T_ = ''")
	EndIf

Return

/*******************************************************************************************
 * Função para enviar e-mail quando o encaixotamento foi concluído:                        *
*******************************************************************************************/
User Function B1120EConc(cNumPed)

	//Local cStatus	:= ''
	Local cConteu	:= ''

	Local cServer     := GETMV("MV_SERCONE") //GETMV("MV_RELSERV")
	Local cConta      := GetMV("MV_RELACNT")
	Local cSenhaMail  := GetMV("MV_RELPSW")
	Local cMailFrom   := "no-reply@buddemeyer.com.br"
	Local cAssunto    := "Pedido ["+cNumPed+"] " + AllTrim(cA1_NOME) + " foi finalizado!"
	Local cMailTo	  := GetMV("BD_1120CON")

	If Empty(cNumPed) .Or. Empty(cA1_NOME) .Or. Empty(cMailTo)
		Return
	EndIf

	// Cabeçalho do e-mail:
	cConteu := "<html>"
	cConteu += "<body style='font-family: Arial; font-size: 10pt'>"
	cConteu += "Prezado,<br><br>"
	cConteu += "O pedido <b>"+AllTrim(cNumPed)+" - "+AllTrim(cA1_NOME)+"</b> foi finalizado dia "+DtoC(MsDate())+" às "+Substr(Time(), 1, 5)+":<br><br>"

	// Chamo o pedido no Hydra:
	cChave := Str(Year(DATE()))
	cChave := AllTrim(Str((Val(cChave) * 23)))
	cCaminho = 'https://hydra.buddemeyer.com.br/reserva/ordem_carregamento.php?p='+AllTrim(cNumPed)+'&c='+cChave+'&u='+AllTrim(cUserName)+'&o=PROJETO'

	// Corpo do e-mail:
	cConteu += "<a href='"+cCaminho+"' target='_blank'>"
	cConteu += "<b>CLIQUE AQUI PARA GERAR A ORDEM DE CARREGAMENTO</b>"
	cConteu += "</a>"

	// Rodapé:
	cConteu += "<br><br>"
	cConteu += "Gentileza verificar."
	cConteu += "</body>"
	cConteu += "</html>"

	// Efetua envio do e-mail:
	CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenhaMail RESULT lResult
	SEND MAIL FROM cMailFrom TO cMailTo SUBJECT cAssunto BODY cConteu RESULT lResult
	DISCONNECT SMTP SERVER

Return

/*******************************************************************************************
 * Função para enviar e-mail de inconsistência:                                            *
*******************************************************************************************/
User Function B1120Inco(cNumPed)

	Local cStatus	:= ''
	Local cConteu	:= ''

	Local cServer     := GETMV("MV_SERCONE") //GETMV("MV_RELSERV")
	Local cConta      := GetMV("MV_RELACNT")
	Local cSenhaMail  := GetMV("MV_RELPSW")
	Local cMailFrom   := "no-reply@buddemeyer.com.br"
	Local cAssunto    := "Ref. Inconsistencias Retorno Maquina - " + AllTrim(cZZ5_1ACOND) + " / " + AllTrim(cZZ5_2ACOND)
	Local cMailTo	  := GetMV("BUD_RETCOL")

	If (Select("TT1120") <> 0)
		DbSelectArea("TT1120")
		DbCloseArea()
	Endif
	cQuery := ""
	cQuery += "SELECT DISTINCT C9_PEDIDO, C9_ITEM, C9_SEQENC, B1_COD, B1_DESC, C9_QTDLIB, C9_QTDENC "
	cQuery += "FROM "+RetSqlName("SC9")+" (NOLOCK), "+RetSqlName("SB1")+" (NOLOCK) "
	cQuery += "WHERE C9_FILIAL = '"+xFilial("SC9")+"' "
	cQuery += "AND C9_PEDIDO = '"+cNumPed+"' "
	cQuery += "AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
	cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
	cQuery += "AND B1_COD = C9_PRODUTO "
	cQuery += "AND C9_NFISCAL = '' "
	cQuery += "AND C9_QTDLIB <> C9_QTDENC "
	cQuery += "AND "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		// Cabeçalho do e-mail:
		cConteu := "<html>"
		cConteu += "<body style='font-family: Arial; font-size: 10pt'>"
		cConteu += "Prezado,<br><br>"
		cConteu += "Foi gerado inconsistência no retorno da máquina pelos usuários <b>"+AllTrim(cZZ5_1OPERA)+" / "+AllTrim(cZZ5_2OPERA)+" - "+DtoC(MsDate())+" às "+Substr(Time(), 1, 5)+"</b>:<br><br>"
		cConteu += "<table border='1' width='100%' style='border-collapse: collapse; font-size: 8pt; font-family: Arial' bordercolor='#d1d1d1' cellpadding='5'>"
		cConteu += "<tr bgcolor='#dfdfdf'>"
		cConteu += "<td align='center'>"
		cConteu += "<b>Pedido</b>"
		cConteu += "</td>"
		cConteu += "<td align='center'>"
		cConteu += "<b>Item</b>"
		cConteu += "</td>"
		cConteu += "<td align='center'>"
		cConteu += "<b>Seq. Enc.</b>"
		cConteu += "</td>"
		cConteu += "<td align='center'>"
		cConteu += "<b>Produto</b>"
		cConteu += "</td>"
		cConteu += "<td align='left'>"
		cConteu += "<b>Descrição</b>"
		cConteu += "</td>"
		cConteu += "<td align='right'>"
		cConteu += "<b>Qtd. Liberada</b>"
		cConteu += "</td>"
		cConteu += "<td align='right'>"
		cConteu += "<b>Qtd. Enc.</b>"
		cConteu += "</td>"
		cConteu += "<td align='left'>"
		cConteu += "<b>Situação</b>"
		cConteu += "</td>"
		cConteu += "</tr>"
		While !TT1120->(Eof())
			// Montagem dos itens:
			If TT1120->C9_QTDENC <= 0
				cStatus := 'Nao Retornou da Maquina - ' + AllTrim(cZZ5_1ACOND) + " / " + AllTrim(cZZ5_2ACOND)
			Else
				cStatus	:= 'Retornou da Maquina com Divergencia - ' + AllTrim(cZZ5_1ACOND) + " / " + AllTrim(cZZ5_2ACOND)
			EndIf
			cConteu += "<tr>"
			cConteu += "<td align='center'>"
			cConteu += AllTrim(cNumPed)
			cConteu += "</td>"
			cConteu += "<td align='center'>"
			cConteu += AllTrim(TT1120->C9_ITEM)
			cConteu += "</td>"
			cConteu += "<td align='center'>"
			cConteu += AllTrim(TT1120->C9_SEQENC)
			cConteu += "</td>"
			cConteu += "<td align='center'>"
			cConteu += AllTrim(TT1120->B1_COD)
			cConteu += "</td>"
			cConteu += "<td align='left'>"
			cConteu += AllTrim(TT1120->B1_DESC)
			cConteu += "</td>"
			cConteu += "<td align='right'>"
			cConteu += Transform(TT1120->C9_QTDLIB, "@E 9,999")
			cConteu += "</td>"
			cConteu += "<td align='right'>"
			cConteu += Transform(TT1120->C9_QTDENC, "@E 9,999")
			cConteu += "</td>"
			cConteu += "<td align='left'>"
			cConteu += cStatus
			cConteu += "</td>"
			cConteu += "</tr>"

			// Efetuo inclusão no ZZ9:
			RecLock("ZZ9",.T.)
			ZZ9->ZZ9_FILIAL	:= xFilial("ZZ9")
			ZZ9->ZZ9_TIPO	:= 'RET'
			ZZ9->ZZ9_PEDIDO := AllTrim(cNumPed)
			ZZ9->ZZ9_ITEM 	:= AllTrim(TT1120->C9_ITEM)
			ZZ9->ZZ9_SEQENC := AllTrim(TT1120->C9_SEQENC)
			ZZ9->ZZ9_DESC 	:= AllTrim(TT1120->B1_COD)
			ZZ9->ZZ9_QTDLIB := TT1120->C9_QTDLIB
			ZZ9->ZZ9_QTDENC := TT1120->C9_QTDENC
			ZZ9->ZZ9_ARQUIVO:= DtoS(MsDate())
			If (ZZ9->ZZ9_QTDLIB == ZZ9->ZZ9_QTDENC)
				cValid	:= "Retornou da Maquina sem Divergencia - " + cZZ5_1ACOND
			ElseIf ((ZZ9->ZZ9_QTDLIB <> 0) .And. (ZZ9->ZZ9_QTDENC == 0))
				cValid	:= "Nao Retornou da Maquina - " + cZZ5_1ACOND
			ElseIf ((ZZ9->ZZ9_QTDLIB <> ZZ9->ZZ9_QTDENC) .And. (ZZ9->ZZ9_QTDENC <> 0))
				cValid	:= "Retornou da Maquina com Divergencia - " + cZZ5_1ACOND
			EndIf
			ZZ9->ZZ9_SITUAC	:= cValid
			ZZ9->ZZ9_ERRO 	:= 'S'
			ZZ9->ZZ9_CODOPE := cZZ5_1ACOND
			ZZ9->ZZ9_OPERAD	:= cZZ5_1OPERA
			ZZ9->ZZ9_DTARQ	:= MsDate()
			ZZ9->ZZ9_HORARQ	:= Substr(Time(),1,5)
			MsUnLock("ZZ9")

			TT1120->(DbSkip())
		EndDo

		// Rodapé:
		cConteu += "</table>"
		cConteu += "<br>"
		cConteu += "Gentileza verificar."
		cConteu += "</body>"
		cConteu += "</html>"

		// Efetua envio do e-mail:
		CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenhaMail RESULT lResult
		SEND MAIL FROM cMailFrom TO cMailTo SUBJECT cAssunto BODY cConteu RESULT lResult
		DISCONNECT SMTP SERVER
	EndIf

Return
