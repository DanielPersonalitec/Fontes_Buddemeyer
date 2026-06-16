#Include "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#include "FwBrowse.ch"
#include "FwMvcDef.ch"
#include 'fileio.ch'

#define DS_MODALFRAME 128

Static cDirArq  := '\EtiqJG\' // Caminho de arquivos dos layout's dos arquivos
Static ENTER 	  := CHR(13)+CHR(10)

//--------------------------------------------------------------
/*/{Protheus.doc} BUD1204
Description Rotina que irá ser utilizada para apontamento de produção de Jogos
com possibilidade de reserva (SC0) caso seja indicado esta opção na OP aberta, para
pedido de vendas específico ou entao somente para a quantidade geral apontada.

@param xParam Parameter Description
@return xRet Return Description
@author Marcos Alberto Schoeffel
@since 29/06/2015
/*/
//--------------------------------------------------------------
User Function BUD1204()

	Local oFont1 := TFont():New("Microsoft Sans Serif",,026,,.T.,,,,,.F.,.F.)
	Local oFont2 := TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
	Local oFont3 := TFont():New("MS Sans Serif",,020,,.F.,,,,,.F.,.F.)
	Local oFont4 := TFont():New("Courier New",,026,,.F.,,,,,.F.,.F.)
	Local oFont5 := TFont():New("Courier New",,020,,.F.,,,,,.F.,.F.)
	Local oFont6 := TFont():New("MS Sans Serif",,015,,.T.,,,,,.F.,.F.)

	Local oGroup1
	Local oGroup2
	Local oGroup3

	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	//Local oSay5
	Local oSay6
	//Local oSay7
	Local oSay8
	Local oSay9
	Local oSay10
	Local oSay11
	Local oSay12
	Local oSay13
	Local oSay14
	Local oSay15

	Private oItensEmp
	Private aCols		:= {}
	Private aHeaderEx 	:= {}
	Private aFieldFill 	:= {}
	Private aFields 	:= {"B1_CODBAR","B1_DESC","C6_EIQTPCT","Z7_QTDPCT","D4_QUANT","B2_QATU","D4_LOCAL"}
	Private aAlterFields := {}

	Private oSaySens
	Private cSaySens 	:= ""
	Private lFlagTmr	:= .T.

	Private oTmrGExp
	Private nExpGai		:= GetMv("BD_744EGA")

	Private cSensLer	:= AllTrim(GetMv("BD_1204SEN"))
	Private cPortaSen	:= AllTrim(GetMv("BD_1204POR"))
	Private cIPSens		:= Space(TamSx3('ZDV_IP')[1])
	Private cCodBar 	:= Space(TamSx3('D3_OP')[1])
	Private cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])

	Private dEmisOP 	:= Stod('')
	Private cDescJg 	:= Space(TamSx3('B1_DESC')[1])
	Private cNumPV  	:= Space(TamSx3('C5_NUM')[1])
	Private cItemPv 	:= Space(TamSx3('C6_ITEM')[1])
	Private dDtEntr 	:= Stod('')
	Private cCliente	:= Space(TamSx3('A1_COD')[1])+'/'+Space(TamSx3('A1_LOJA')[1])+' - '+Space(TamSx3('A1_NOME')[1])
	Private cObserv 	:= Space(TamSx3('C2_OBS')[1])
	Private cEndAvu 	:= Space(TamSx3('C2_OBS')[1])
	Private cEndJG  	:= Space(TamSx3('C2_OBS')[1])
	Private nQtdOP  	:= 0
	Private nQtdProd	:= 0
	Private cCodPro 	:= Space(TamSx3('B1_CODBAR')[1])
	Private cProduto	:= Space(TamSx3('B1_COD')[1])
	Private cParamSeg 	:= ''
	Private lGaiolaObr	:= .F.
	Private lEnvioFlw	:= .F.
	Private lLibGaiola	:= .F.
	Private lSerialON	:= .F.
	Private oTimer
	Private oTmrFocus
	Private nAtuSens	:= 0
	Private nErrSens	:= 0
	Private nMultJG		:= 1

	Private oEmpJG
	Private cEmpJG  	:= ''

	Private cNumOP  	:= ''
	Private nQtdApo 	:= 0
	Private nTotPcs 	:= 0
	Private aToalhas	:= {}
	Private aCores  	:= {}

	Private oCodBar
	Private oCodGaiola
	Private oEmisOP
	Private oDescJg
	Private oPedido
	Private oItem
	Private oDtEntr
	Private oCliente
	Private oObserv
	Private oEndAvu
	Private oEndJG
	Private oQtdOP
	Private oQtdProd
	Private oQtdApo
	Private oCodPro

	Private lEmpenho := .T.
	Private aEmpenho := {}

	Private oLimpar
	Private oOk
	Private oSair
	Private oPrint
	Private oFoto

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Apontamento Produção Jogos" FROM C(000), C(000)  TO C(480), C(800) COLORS 0, 16777215 PIXEL Style DS_MODALFRAME
	oDlg:lEscClose := .F. // desabilitar para não deixar fechar a tela com esc

	@ C(001), C(007) GROUP oGroup1 TO C(118), C(390) PROMPT "Ordem Produção" OF oDlg COLOR 255, 16777215 PIXEL

	// Primeira linha:
	@ C(010), C(014) SAY oSay1 PROMPT "Ordem de Produção:" SIZE C(091), C(016) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(006), C(080) MSGET oCodBar Var cCodBar F3 "SC2" Valid B1204Val() SIZE C(70), C(015) OF oDlg COLORS 16711680, 16777215 FONT oFont1 PIXEL

	@ C(010), C(152) SAY oSay14 PROMPT "Gaiola:" SIZE C(091), C(016) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(006), C(177) MSGET oCodGaiola Var cCodGaiola F3 "ZDT" Valid B1204ValG() SIZE C(50), C(015) OF oDlg COLORS 16711680, 16777215 FONT oFont1 PIXEL
	@ C(008), C(230) SAY oSaySens PROMPT cSaySens SIZE C(065), C(020) OF oDlg FONT oFont6 PIXEL COLORS 255, 16777215

	@ C(010), C(300) SAY oSay2 PROMPT "Emissão:" SIZE C(040), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(010), C(345) SAY oEmisOP Var dEmisOP SIZE C(060), C(015) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	@ C(020), C(300) SAY oSay6 PROMPT "Data Entrega:" SIZE C(060), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(020), C(345) SAY oDtEntr Var dDtEntr SIZE C(060), C(012) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	// Demais linhas:
	@ C(030), C(014) SAY oSay3 PROMPT "Descrição :" SIZE C(051), C(016) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(030), C(050) SAY oDescJg Var cDescJg SIZE C(319), C(013) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	@ C(045), C(014) SAY oSay4 PROMPT "Pedido :" SIZE C(035), C(015) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(045), C(050) SAY oPedido Var cNumPV SIZE C(040), C(014) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	//@ C(045), C(100) SAY oSay5 PROMPT "Item :" SIZE C(026), C(011) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	//@ C(045), C(090) SAY oItem Var cItemPv SIZE C(020), C(014) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	//@ C(060), C(014) SAY oSay7 PROMPT "Cliente :" SIZE C(035), C(009) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(045), C(090) SAY oCliente Var cCliente SIZE C(325), C(013) OF oDlg FONT oFont1 COLORS 16711680, 16777215 PIXEL

	@ C(060), C(014) SAY oSay8 PROMPT "Observação :" SIZE C(059), C(011) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(060), C(065) GET oObserv Var cObserv MEMO When .F. SIZE C(150), C(050) OF oDlg COLORS /*8388608*/ 16777215,255 FONT oFont2 PIXEL

	// Locais dos produtos (Thiago dia 08/06/2018):
	@ C(060), C(220) SAY oSay13 PROMPT "Local dos Avulsos :" SIZE C(059), C(011) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(070), C(220) GET oEndAvu Var cEndAvu MEMO When .F. SIZE C(80), C(040) OF oDlg COLORS /*8388608*/ 16777215,255 FONT oFont2 PIXEL

	@ C(060), C(305) SAY oSay13 PROMPT "Local do Jogo :" SIZE C(059), C(011) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(070), C(305) GET oEndJG Var cEndJG MEMO When .F. SIZE C(80), C(040) OF oDlg COLORS /*8388608*/ 16777215,255 FONT oFont2 PIXEL

	@ C(120), C(007) GROUP oGroup2 TO C(183), C(390) PROMPT "Itens Empenhados" OF oDlg COLOR 255, 16777215 PIXEL

	/*
	fItensEmp()
	oItensEmp := MsNewGetDados():New( C(126), C(014), C(180), C(385), GD_UPDATE, "AllwaysTrue", "AllwaysTrue", , aAlterFields,, 999, "AllwaysTrue", "", "AllwaysFalse", oDlg, aHeaderEx, aCols)
	oItensEmp:oBrowse:lAdjustColSize := .T.
	oItensEmp:oBrowse:lJustific := .T.
	oItensEmp:oBrowse:lHitTop := .T.
	oItensEmp:oBrowse:Refresh()
	*/
	@ C(126), C(014) GET oEmpJG Var cEmpJG MEMO When .F. SIZE C(370), C(055) OF oDlg COLORS /*8388608*/ 16777215,255 FONT oFont2 PIXEL

	@ C(185), C(007) GROUP oGroup3 TO C(225), C(390) PROMPT "Quantidades" OF oDlg COLOR 255, 16777215 PIXEL

	@ C(195), C(014) SAY oSay9 PROMPT "Quant. Total O.P." SIZE C(077), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(205), C(014) MSGET oQtdOP Var nQtdOP When .F. SIZE C(048), C(015) OF oDlg FONT oFont1 PICTURE "@E 9,999,999" COLORS 16711680, 16777215 PIXEL

	@ C(195), C(094) SAY oSay10 PROMPT "Quant.Produzida" SIZE C(077), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(205), C(094) MSGET oQtdProd Var nQtdProd When .F. SIZE C(045), C(015) OF oDlg FONT oFont1 PICTURE "@E 9,999,999" COLORS 16711680, 16777215 PIXEL

	@ C(195), C(174) SAY oSay11 PROMPT "Quant.Apontada" SIZE C(077), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(205), C(174) MSGET oQtdApo Var nQtdApo When .F. SIZE C(045), C(015) OF oDlg FONT oFont1 PICTURE "@E 9,999,999" COLORS 16711680, 16777215 PIXEL

	@ C(195), C(254) SAY oSay12 PROMPT "Leitura Código Barras Jogo" SIZE C(077), C(012) OF oDlg FONT oFont2 COLORS 8388608, 16777215 PIXEL
	@ C(205), C(254) MSGET oCodPro VAR cCodPro Valid B1204Val() SIZE C(090), C(015) OF oDlg PICTURE "@!" COLORS 128, 16777215 FONT oFont4 PIXEL

	@ C(228), C(008) SAY oSay15 PROMPT "ESTAÇÃO ["+Upper(AllTrim(ComputerName()))+"]" SIZE C(200), C(012) OF oDlg FONT oFont5 PIXEL
	@ C(228), C(190) BUTTON oOk     PROMPT "Confirmar" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action (B1204Ok())
	//@ C(228), C(230) BUTTON oPrint  PROMPT "Imprimir" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action (B1204Print())
	@ C(228), C(230) BUTTON oPrint  PROMPT "Imprimir" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action (U_B1204VeImp(cCodBar, .F.))

	@ C(228), C(270) BUTTON oFoto   PROMPT "Foto" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action (B1204Foto())

	@ C(228), C(310) BUTTON oLimpar PROMPT "Limpar" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action B1204Limpar()
	@ C(228), C(350) BUTTON oSair   PROMPT "Sair" SIZE C(036), C(012) OF oDlg FONT oFont3 PIXEL Action (B1204Sair())

	// Inicio timer ref. ao sensor da gaiola:
	if cSensLer == "B" .Or. cSensLer == "W" .Or. cSensLer == "S"
		oTimer := TTimer():New(2000, {|| BuscaSensor(.F.) }, oDlg )
		oTimer:Activate()
	ElseIf nExpGai > 0 .And. cSensLer == "T"
		oTmrGExp := TTimer():New(1000, {|| ExpiraGa() }, oDlg )
		oTmrGExp:Activate()
	EndIf

	ACTIVATE MSDIALOG oDlg CENTERED

	// Ao fechar o sistema, preciso liberar a porta serial:
	If lSerialON
		MsClosePort(0)
		lSerialON	:= .F.
	EndIf

Return

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Função para expirar a gaiola depois de um determinado tempo:
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
Static Function ExpiraGa()

	If !Empty(cParamSeg)
		Return
	EndIf

	// Verifico variáveis:
	If !lGaiolaObr .Or. Empty(cCodBar) .Or. nQtdProd <= 0
		cSaySens	:= ""
		oSaySens:Refresh()
		Return
	EndIf

	// Verifico parâmetro:
	If GetMv("BD_744EGA") <= 0
		cSaySens	:= ""
		oSaySens:Refresh()
		Return
	EndIf

	// Verifico código da gaiola:
	If Empty(cCodGaiola)
		Return
	EndIf

	// Verifico expiração da gaiola:
	If nExpGai > 0
		cSaySens		:= "Expira em " + AllTrim(Str(nExpGai)) + "s"
		nExpGai			-= 1
	Else
		nExpGai			:= GetMv("BD_744EGA")
		// Zero código da gaiola:
		cCodGaiola 		:= Space(TamSx3('ZDT_CODIGO')[1])
		cSaySens		:= "Informe novamente o código da gaiola..."
		oCodGaiola:Refresh()
		oCodGaiola:SetFocus()
	EndIf

	// Refresh no componente:
	oSaySens:Refresh()

Return

//------------------------------------------------
/*
Static Function fItensEmp()
	//------------------------------------------------
	Local nX

	aCols 			:= {}
	aHeaderEx 		:= {}
	aFieldFill 		:= {}
	aFields 		:= {"B1_CODBAR","B1_DESC","C6_EIQTPCT","Z7_QTDPCT","D4_QUANT","B2_QATU","D4_LOCAL"}
	aAlterFields 	:= {}
	cEmpJG			:= ""

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aCols, aFieldFill)


Return
*/

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Rotinas responsáveis pelo encaixotamento no CD Buddemeyer
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
// Permite liberar inclusão de OP na gaiola que já encontra-se no CD através de permissão de usuário 09/04/2020 - Thiago Lucas Machado
Static Function LibGaiola()

	Local oFBtnLib		:= TFont():New("Tahoma",,012,,.F.,,,,,.F.,.F.)
	Local oFMatric		:= TFont():New("Tahoma",,050,,.T.,,,,,.F.,.F.)
	Local cCDMatri		:= Space(TamSx3('CB1_MATRIC')[1])
	Local oBtnOKLib
	Local oBtnCanLib
	Private oCDMatri
	Private oDlgLib 	:= TDialog():New(0,0,0,0,"Utilização da Gaiola",,,,,,,,oDlg,.T.,,,,410,200,.F.)

	// Formulário de liberação:
	oDlgLib:SetColor(0, 16777215)
	oDlgLib:lCentered := .T.
	oDlgLib:lEscClose := .T.
	oDlgLib:nStyle:=128

	@ 005, 005 GROUP oGrLib TO 070, 200 PROMPT "Matrícula" OF oDlgLib COLOR 0, 16777215 PIXEL
	@ 015, 010 SAY oTitLib PROMPT "Informe sua matrícula:" SIZE 200, 050 OF oDlgLib COLORS CLR_BLACK PIXEL
	@ 025, 010 MSGET oCDMatri VAR cCDMatri SIZE 185, 035 OF PIXEL FONT oFMatric COLORS CLR_BLACK PIXEL
	@ 075, 135 BUTTON oBtnOKLib PROMPT "OK" SIZE 030, 015 OF oDlgLib FONT oFBtnLib PIXEL Action (lLibGaiola := VerMatrCD(cCDMatri))
	@ 075, 170 BUTTON oBtnCanLib PROMPT "Cancelar" SIZE 030, 015 OF oDlgLib FONT oFBtnLib PIXEL Action oDlgLib:End()

	oDlgLib:Activate(,,,.T.,,,)

Return (lLibGaiola)

// Verifica se a matrícula do operador é administrador para permitir liberação manual do encaixotamento CD:
Static Function VerMatrCD(cCDMatri)
	Local lVldMatr	:= .F.

	// Vazio simplismente ignoro:
	If Empty(cCDMatri)
		Return (.F.)
	EndIf

	// Chamo rotina de verificação:
	MsAguarde({|| lVldMatr := AdmOperCD(cCDMatri) }, "Aguarde", "Verificando matrícula...")

	// Tratar em caso positivo:
	If lVldMatr
		oDlgLib:End()
	Else
		&('StaticCall(BUD744, B744TocaSom)')
		MsgStop("Matrícula inválida, gentileza verificar!!!")
		oCDMatri:SetFocus()
		oCDMatri:Refresh()
		oDlgLib:Refresh()
	EndIf

	// Validação da matrícula:
Return (lVldMatr)
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
	cQuery += "AND ((CB1_ESTINT = '1' AND CB1_ADMINT = '1') OR (CB1_ROTINA LIKE '%BUD1204%')) "
	cQuery += "AND CB1_STATUS = '1' "
	cQuery += "AND CB1010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1120"
	If !TT1120->(Eof())
		lVldMatr	:= .T.
	EndIf

Return (lVldMatr)

// Busca informação do sensor 09/03/2020 - Thiago Lucas Machado
Static Function BuscaSensor(lRefresh)
	Local cRetCOM		:= ""
	Local cRetDIS		:= ""
	Local cFlagCOM		:= ""

	cSaySens	:= ""

	// Verifico obrigatoriedade de se utilizar carrinho:
	If !lGaiolaObr
		Return
	EndIf

	// Verifico se existe OP:
	If Empty(cCodBar)
		Return
	EndIf

	// Verifico se o parâmetro está habilitado:
	if cSensLer == "D" .Or. cSensLer == ""
		Return
	EndIf

	// Verifico flag, se desabilitada, não executo rotina:
	If !lFlagTmr
		Return
	EndIf
	// Desativo flag:
	lFlagTmr	:= .F.

	// Busco diretamente da tabela:
	if cSensLer == "B"
		/* CASO A OPERAÇÃO SEJA DIRETO DO BANCO */
		If (Select("T1204S") <> 0)
			DbSelectArea("T1204S")
			DbCloseArea()
		Endif
		cQuery := "SELECT ZDV_VLRATU, ZDV_DTSINC, ZDV_HRSINC "
		cQuery += "FROM "+RetSQLName("ZDV")+" (NOLOCK) "
		cQuery += "WHERE ZDV_FILIAL = '' "
		cQuery += "AND ZDV_ESTACA = '"+Upper(AllTrim(ComputerName()))+"' "
		cQuery += "AND ZDV_DTSINC >= '"+DtoS(dDataBase)+"' "
		cQuery += "AND ZDV_HRSINC >= '"+DecTime(Time(), 0, 1, 0)+"' "
		cQuery += "AND "+RetSQLName("ZDV")+".D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "T1204S"
		IF !T1204S->(Eof())
			// Tratativas do retorno do sensor:
			If AllTrim(T1204S->ZDV_VLRATU) == "N"
				cSaySens	:= "GENTILEZA, POSICIONE A GAIOLA..."
				cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				oCodGaiola:Refresh()
				oCodGaiola:SetFocus()
			ElseIf AllTrim(T1204S->ZDV_VLRATU) == "S"
				cSaySens	:= "OK, A GAIOLA ESTÁ POSICIONADA."
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 8388608
				If Empty(cCodGaiola)
					oCodGaiola:SetFocus()
					cSaySens	:= "INFORME O CÓDIGO DA GAIOLA..."
					oSaySens:nClrPane 	:= 16777215
					oSaySens:nClrText	:= CLR_MAGENTA
				EndIf
			Else
				cSaySens	:= "# ERRO SENSOR ["+T1204S->ZDV_VLRATU+"] #"
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
			EndIf
			oSaySens:Refresh()
			oDlg:Refresh()
		Else
			cSaySens	:= "# SENSOR OFF #"
			oSaySens:nClrPane 	:= 16777215
			oSaySens:nClrText	:= 255
			oSaySens:Refresh()
			oDlg:Refresh()
		EndIf
	Elseif cSensLer == "W"
		/* CASO A OPERAÇÃO SEJA VIA WEBSERVICE */
		// Busco IP do sensor:
		If Empty(cIPSens) .Or. lRefresh
			If (Select("T1204S") <> 0)
				DbSelectArea("T1204S")
				DbCloseArea()
			Endif
			cQuery := "SELECT DISTINCT TOP 1 ZDV_IP "
			cQuery += "FROM "+RetSQLName("ZDV")+" (NOLOCK) "
			cQuery += "WHERE ZDV_FILIAL = '' "
			cQuery += "AND ZDV_ESTACA = '"+Upper(AllTrim(ComputerName()))+"' "
			cQuery += "AND ZDV_DTSINC >= '"+DtoS(dDataBase)+"' "
			cQuery += "AND ZDV_HRSINC >= '"+DecTime(Time(), 0, 2, 0)+"' "
			cQuery += "AND "+RetSQLName("ZDV")+".D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "T1204S"
			IF !T1204S->(Eof())
				cIPSens		:= T1204S->ZDV_IP
				cSaySens	:= AllTrim(cIPSens)
				oSaySens:Refresh()
				oDlg:Refresh()
			Else
				cSaySens			:= "SENSOR OFF"
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				oSaySens:Refresh()
				oDlg:Refresh()
			EndIf
		EndIf

		// Busco informação do sensor:
		cIPSens = AllTrim(cIPSens)
		If !Empty(cIPSens)
			// Verifico status do sensor (o mesmo é um servidor web e responde pela porta 80):
			aHeadOut 	:= {}
			cHeadRet 	:= ""
			cCaminho	:= cIPSens
			aadd(aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
			aadd(aHeadOut, 'Content-Type: application/x-www-form-urlencoded')
			cRetSens 	:= AllTrim(HttpPost(cCaminho, "", "", 2, aHeadOut, @cHeadRet))
			// Verifico retorno:
			If cRetSens == ""
				cSaySens	:= "# ERRO SENSOR [1]["+cIPSens+"] #"
				cIPSens		:= ""
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				oSaySens:Refresh()
				oDlg:Refresh()
			ElseIf Left(cRetSens, 2) != "OK"
				cIPSens		:= ""
				cSaySens	:= cRetSens
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				oSaySens:Refresh()
				oDlg:Refresh()
			Else
				// Efetuo tratativas de troca de gaiolas:
				cSaySens	:= cRetSens
				aRetSens	:= StrTokArr(cRetSens, "|")
				If Len(aRetSens) == 5
					cSaySens	:= aRetSens[1]
					// Segundo parâmetro em "0" significa sem carrinho, então eu zero a variável do carrinho:
					If aRetSens[2] == "N"
						cSaySens	:= "AGUARDANDO POSICIONAMENTO DA GAIOLA..."
						cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])
						oSaySens:nClrPane 	:= 16777215
						oSaySens:nClrText	:= 255
						oCodGaiola:Refresh()
						oCodGaiola:SetFocus()
					ElseIf aRetSens[2] == "S"
						cSaySens	:= "OK, A GAIOLA ESTÁ POSICIONADA..."
						oSaySens:nClrPane 	:= 16777215
						oSaySens:nClrText	:= 8388608
						If Empty(cCodGaiola)
							oCodGaiola:SetFocus()
							cSaySens	:= "INFORME O CÓDIGO DA GAIOLA..."
							oSaySens:nClrPane 	:= 16777215
							oSaySens:nClrText	:= CLR_MAGENTA
						EndIf
					Else
						cSaySens	:= "# ERRO SENSOR ["+aRetSens[2]+"]["+cIPSens+"] #"
						oSaySens:nClrPane 	:= 16777215
						oSaySens:nClrText	:= 255
					EndIf
				Else
					cSaySens	:= "# ERRO SENSOR [2]["+cIPSens+"] #"
					cIPSens		:= ""
					oSaySens:nClrPane 	:= 16777215
					oSaySens:nClrText	:= 255
				EndIf
				oSaySens:Refresh()
				oDlg:Refresh()
			EndIf
		EndIf
	Elseif cSensLer == "S"
		/* CASO A OPERAÇÃO SEJA VIA SERIAL */
		// Abro conexão com a serial:
		If !lSerialON
			lSerialON	:= MsOpenPort(0, cPortaSen+":9600,n,8,1")
			cSaySens	:= "ABRINDO COMUNICACAO ["+cPortaSen+"]..."
			oSaySens:nClrPane 	:= 16777215
			oSaySens:nClrText	:= CLR_BLACK
			If !lSerialON
				cSaySens	:= "# NAO FOI POSSIVEL ABRIR COMUNICACAO NA PORTA ["+cPortaSen+"] #"
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
			EndIf
			// Aguardo sensor estabilizar:
			oTimer:DeActivate()
			oTimer:nInterval := 5000
			oTimer:Activate()
		Else
			// Seto intervalo menor para comunicação serial:
			oTimer:nInterval := 1000

			// Efetuo leitura da serial:
			MsRead(0, @cRetCOM)

			// Efetuo tratativas de retorno:
			cFlagCOM 	:= IIF('S' $ cRetCOM, "S",  IIF('N' $ cRetCOM, "N", IIF('E' $ cRetCOM, "E", IIF('I' $ cRetCOM, "I", IIF('L' $ cRetCOM, "L", "")))))

			// Efetuo atualização do sensor a cada 5 ciclos do timer:
			nAtuSens++
			If  nAtuSens >= 5
				// Se não existe, é necessário efetuar uma inclusão com dados inicias:
				If (Select("T1204S") <> 0)
					DbSelectArea("T1204S")
					DbCloseArea()
				Endif
				cQuery := ChangeQuery("SELECT ZDV_ESTACA FROM ZDV010 (NOLOCK) WHERE ZDV_FILIAL = '' AND ZDV_ESTACA = '"+Upper(AllTrim(ComputerName()))+"' AND ZDV010.D_E_L_E_T_ = '' ")
				TCQuery cQuery NEW ALIAS "T1204S"
				IF T1204S->(Eof())
					// Caso não exista, eu incluo o registro vazio:
					MsUnlockAll()
					DbSelectArea("ZDV")
					RecLock("ZDV", .T.)
					ZDV->ZDV_ESTACA	:= Upper(AllTrim(ComputerName()))
					MsUnLock("ZDV")
					MsUnlockAll()
				EndIf

				// Depois é efetuado a atualização no registro do sensor:
				cUpd := ""
				cUpd += "UPDATE ZDV010 SET ZDV_DTSINC = '"+DtoS(dDataBase)+"' "
				cUpd += "				 , ZDV_HRSINC = '"+Time()+"' "
				cUpd += "				 , ZDV_IP = '"+Alltrim(GetClientIP())+"' "
				cUpd += "				 , ZDV_VLRATU = '"+cFlagCOM+"' "
				cUpd += "				 , ZDV_SINAL = '"+AllTrim(cPortaSen)+"' "
				cUpd += "WHERE ZDV_FILIAL = '' "
				cUpd += "AND ZDV_ESTACA = '"+Upper(AllTrim(ComputerName()))+"' "
				cUpd += "AND ZDV010.D_E_L_E_T_ = '' "
				TCSQLEXEC(cUpd)

				// Zero contador de atualização:
				nAtuSens := 0
			EndIf

			// Tratativas do retorno do sensor:
			If AllTrim(cFlagCOM) == "N"
				// Caso exista apontamento pendente, na retirada da gaiola, eu forço o processamento da pela:
				If nQtdApo > 0 .And. !Empty(cCodBar) .And. !Empty(cCodGaiola)
					B1204Ok()
				EndIf
				// Informo usuário para posicionar a gaiola:
				nErrSens	:= 0
				cSaySens	:= "GENTILEZA, POSICIONE A GAIOLA"+cRetDIS+"..."
				cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				oCodGaiola:Refresh()
				oCodGaiola:SetFocus()
			ElseIf AllTrim(cFlagCOM) == "S"
				nErrSens	:= 0
				cSaySens	:= "OK, A GAIOLA ESTÁ POSICIONADA"+cRetDIS+"."
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 8388608
				If Empty(cCodGaiola)
					oCodGaiola:SetFocus()
					cSaySens	:= "INFORME O CÓDIGO DA GAIOLA"+cRetDIS+"..."
					oSaySens:nClrPane 	:= 16777215
					oSaySens:nClrText	:= CLR_MAGENTA
				EndIf
			ElseIf AllTrim(cFlagCOM) == "I"
				nErrSens	:= 0
				cSaySens	:= "INICIANDO SENSOR..."
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= CLR_BLACK
			Else
				nErrSens++
				cSaySens	:= "# ERRO SENSOR ["+cRetCOM+" | "+cPortaSen+" | "+AllTrim(Str(nErrSens))+"] #"
				oSaySens:nClrPane 	:= 16777215
				oSaySens:nClrText	:= 255
				if nErrSens >= 10
					MsClosePort(0)
					lSerialON	:= .F.
					nErrSens	:= 0
				EndIf
			EndIf
		EndIf

		oSaySens:Refresh()
		oDlg:Refresh()
	EndIf

	// Reativo flag:
	lFlagTmr	:= .T.

Return

// Efetua validação da gaiola/carrinho 05/03/2020 - Thiago Lucas Machado
Static Function B1204ValG()
	Local lRet := .T.

	// Verifico obrigatoriedade:
	if Empty(cCodGaiola)
		Return (lRet := .T.)
	EndIf

	// Verifico se o carrinho existe:
	If !Empty(cCodGaiola)
		// Verifico prefixo:
		If Left(cCodGaiola, 2) != "GL"
			&('StaticCall(BUD744, B744TocaSom)')
			MsgStop("Código ["+AllTrim(cCodGaiola)+"] está no formato errado! Gentileza verificar...")
			Return (lRet := .F.)
		EndIf

		// Seto flag para não liberada:
		lLibGaiola	:= .F.

		If (Select("T1204G") <> 0)
			DbSelectArea("T1204G")
			DbCloseArea()
		Endif
		cQuery := "SELECT DISTINCT TOP 1 ZDT_STATUS, ZDT_LOCFIS "
		cQuery += "FROM ZDT010 (NOLOCK) "
		cQuery += "WHERE ZDT_FILIAL = '' "
		cQuery += "AND ZDT_CODIGO = '"+StrTran(AllTrim(cCodGaiola), "GL", "")+"' "
		cQuery += "AND ZDT010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "T1204G"
		IF !T1204G->(Eof())
			// Verifico status da gaiola:
			if (AllTrim(T1204G->ZDT_LOCFIS) != "SA")
				&('StaticCall(BUD744, B744TocaSom)')
				// Aqui preciso chamar uma mensagem de confirmação do supervisor, para permitir liberação da gaiola:
				lRet := .F.
				// Verificar função msgbox para colocar um ícone de erro:
				IF MsgBox("Gaiola ["+AllTrim(cCodGaiola)+"] parece não se encontrar na S/A! Deseja liberar ela mesmo assim para adiocionar mais itens?", "Erro", "YESNO")
					lRet := LibGaiola()
				EndIf
			Elseif ((AllTrim(T1204G->ZDT_STATUS) == "ENDERECADO" .Or. AllTrim(T1204G->ZDT_STATUS) == "TRANSITO" .Or. AllTrim(T1204G->ZDT_STATUS) == "ORDEM GERADA") .And. AllTrim(T1204G->ZDT_LOCFIS) != "SA")
				&('StaticCall(BUD744, B744TocaSom)')
				MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] está com status ["+AllTrim(T1204G->ZDT_STATUS)+"]! Gentileza verificar...")
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			&('StaticCall(BUD744, B744TocaSom)')
			MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] não cadastrada, gentileza verificar!")
			lRet := .F.
		EndIf
	EndIf

	// Prossigo para o próximo campo:
	if lRet
		// Retorno para o campo da OP:
		If Empty(cCodBar)
			oCodBar:SetFocus()
			Return (lRet := .T.)
		EndIf
		// Retorno para o campo do código de barras do produto:
		If Empty(cCodPro)
			oCodPro:SetFocus()
			Return (lRet := .T.)
		EndIf
	EndIf

Return (lRet)

// Efetua validação da quantidade inserida na OP da gaiola - 27/08/2020 - Thiago Lucas Machado
Static Function ValQtdOP()
	Local nQtdZDU	:= 0
	Local nQtdSC2	:= 0

	// Verifico quantidade total da OP nas gaiolas:
	If (Select("T1204G") <> 0)
		DbSelectArea("T1204G")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(SUM(ZDU_MULTIP), 0) AS QTD_ZDU FROM ZDU010 (NOLOCK) WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU_LOCFIS IN ('SA', 'FL', 'CD') AND ZDU010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T1204G"
	IF !T1204G->(Eof())
		nQtdZDU	:= T1204G->QTD_ZDU
	EndIf

	// Verifico quantidade total apontada:
	If (Select("T1204G") <> 0)
		DbSelectArea("T1204G")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(C2_QUJE, 0) AS QTD_SC2 FROM SC2010 (NOLOCK) WHERE C2_FILIAL = '"+xFilial("SC2")+"' AND C2_NUM = '"+Left(cNumOp, 6)+"' AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+cNumOP+"' AND SC2010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T1204G"
	IF !T1204G->(Eof())
		nQtdSC2	:= T1204G->QTD_SC2
	EndIf

	// Caso a quantidade seja superior, emito mensagem para usuário:
	If nQtdZDU > (nQtdSC2 + nMultJG)
		MsgStop("Atenção: A quantidade inserida na gaiola está superior a quantidade apontada na OP. Gentileza anotar essa observação na ficha....")
	EndIf

Return

// Efetuo inclusão do item na gaiola 12/03/2020 - Thiago Lucas Machado
Static Function InsGaiola()

	Local cSeqApon		:= '0001'
	//Local cCodProdut	:= ''
	Local cCodCli		:= ''
	Local cLojaCli		:= ''
	Local cGrupCLi		:= ''
	Local cLocalCli		:= ''
	Local cPedCli		:= ''

	// Busco sequencia do apontamento:
	If (Select("T1204I") <> 0)
		DbSelectArea("T1204I")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(MAX(ZDU_ITEMGA), '0000') AS SEQAPONT FROM ZDU010 (NOLOCK) WHERE ZDU_FILIAL = '' AND ZDU_CODGA = '"+AllTrim(cCodGaiola)+"' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T1204I"
	IF !T1204I->(Eof())
		cSeqApon	:= Soma1(T1204I->SEQAPONT)
	EndIf

	IF lEnvioFlw
		// No caso da VRN, busco dados dos parâmtros:
		cCodCli		:= AllTrim(U_B1391Param("FLOW_RACK", "G2_CODCLI"))
		cLojaCli	:= AllTrim(U_B1391Param("FLOW_RACK", "G2_CODLOJA"))
		cLocalCli	:= AllTrim(U_B1391Param("FLOW_RACK", "G2_LOCAL"))
	Else
		// Busco dados do pedido:
		If (Select("T1204I") <> 0)
			DbSelectArea("T1204I")
			DbCloseArea()
		Endif
		cQuery := "SELECT DISTINCT TOP 1 A1_COD, A1_LOJA, A1_GRUPO, C5_LOCAL, C5_NUM "
		cQuery += "FROM SC2010 (NOLOCK) "
		cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = C2_NUMPED AND SC5010.D_E_L_E_T_ = '' "
		cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE C2_FILIAL = '01' "
		cQuery += "AND C2_NUM = '"+Left(cNumOP, 6)+"' "
		cQuery += "AND (C2_NUM+C2_ITEM+C2_SEQUEN) = '"+AllTrim(cNumOP)+"' "
		cQuery += "AND SC2010.D_E_L_E_T_ = '' "
		TCQuery cQuery NEW ALIAS "T1204I"
		IF !T1204I->(Eof())
			cCodCli		:= AllTrim(T1204I->A1_COD)
			cLojaCli	:= AllTrim(T1204I->A1_LOJA)
			cGrupCLi	:= AllTrim(T1204I->A1_GRUPO)
			cLocalCli	:= AllTrim(T1204I->C5_LOCAL)
			cPedCli		:= AllTrim(T1204I->C5_NUM)
		EndIf
	EndIf

	// Efetuo inclusão na tabela ZDU:
	//MsUnlockAll()
	//DbSelectArea("ZDU")
	RecLock("ZDU",.T.)
	ZDU->ZDU_CODGA	:= AllTrim(cCodGaiola)
	ZDU->ZDU_NUMOP	:= AllTrim(cNumOP)
	ZDU->ZDU_ITEMGA	:= cSeqApon
	ZDU->ZDU_PRODUT	:= cProduto
	ZDU->ZDU_MULTIP	:= nMultJG
	ZDU->ZDU_ESTAC	:= Upper(AllTrim(ComputerName()))
	ZDU->ZDU_DTGERA	:= MsDate()
	ZDU->ZDU_HRGERA	:= Time()
	ZDU->ZDU_USGERA	:= Upper(AllTrim(cUserName))
	ZDU->ZDU_STATUS	:= 'EM ANDAMENTO'
	ZDU->ZDU_LOCFIS	:= 'SA'
	ZDU->ZDU_CLI	:= cCodCli
	ZDU->ZDU_LOJA	:= cLojaCli
	ZDU->ZDU_LOCAL	:= cLocalCli
	ZDU->ZDU_CLIGRU	:= cGrupCLi
	ZDU->ZDU_PEDIDO	:= cPedCli
	//MsUnLock("ZDU")
	ZDU->(MsUnlock())
	//MsUnlockAll()

	// Atualizo status da gaiola:
	If lLibGaiola
		// Se a gaiola foi liberada, eu apenas altero o status para acrescentar:
		TCSQLEXEC("UPDATE ZDT010 SET ZDT_STATUS = 'ACRESCENTADO', ZDT_OBS = 'ACRESCENTADO ITEM POR ["+AllTrim(Upper(cUserName))+"] DIA ["+DtoC(dDataBase)+"] PARA OP ["+AllTrim(cNumOP)+"]' WHERE ZDT_FILIAL = '' AND ZDT_CODIGO = '"+StrTran(cCodGaiola, "GL", "")+"' AND ZDT010.D_E_L_E_T_ = '' ")

		cCodGai := StrTran(cCodGaiola, "GL", "")
		U_BUD1516(.T.,cCodGai,"A","ACRESCENTADO")

	Else
		// Se a gaiola é OK, efetuo alteração do local fiscal:
		TCSQLEXEC("UPDATE ZDT010 SET ZDT_STATUS = 'UTILIZADO', ZDT_LOCFIS = 'SA', ZDT_OBS = 'UTILIZADO POR ["+AllTrim(Upper(cUserName))+"] DIA ["+DtoC(dDataBase)+"] PARA OP ["+AllTrim(cNumOP)+"]' WHERE ZDT_FILIAL = '' AND ZDT_CODIGO = '"+StrTran(cCodGaiola, "GL", "")+"' AND ZDT010.D_E_L_E_T_ = '' ")

		cCodGai := StrTran(cCodGaiola, "GL", "")
		U_BUD1516(.T.,cCodGai,"A","UTILIZADO",'SA')

	EndIf
Return
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FIM - Rotinas responsáveis pelo encaixotamento no CD Buddemeyer
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// Valida tanto código de barras quanto o normal:
Static Function B1204Val()

	Local lRet   	:= .T.
	Local cCampo 	:= ReadVar()
	Local cCto   	:= &(ReadVar())
	Local lNumOP 	:= .T.
	Local nFocus 	:= GetFocus()
	Local nLimpar	:= oLimpar:hwnd
	Local nSair		:= oSair:hwnd
	Local nOk		:= oOk:hwnd
	Local lGaiolaIns:= .F.

	// Vazio saio da rotina:
	If Empty(cCto)
		Return (lRet := .T.)
	EndIf

	// Reseto tempo de expiração:
	nExpGai	:= IIF(lGaiolaObr, GetMv("BD_744EGA"), 0)

	// Verifico se trata-se de um código de gaiola:
	If Left(Upper(cCto), 2) == "GL"
		oCodGaiola:SetFocus()
		cCodGaiola	:= AllTrim(Upper(cCto))
		B1204ValG()
		Return (lRet := .T.)
	EndIF

	If	!Empty(cCodBar)
		// Posiciona na Ordem de Produção indicado pelo código de barras
		SC2->(DbSeek(xFilial('SC2')+cCodBar))
		// Posiciona no Produto que está registrado a Ordem de Produção
		SB1->(DbSeek(xFilial('SB1')+SC2->C2_PRODUTO))

	EndIf

	If	AllTrim(Upper(cCampo)) == 'CCODBAR'
		lNumOP := .T.
		If	Empty(cCto)
			If	(nSair == nFocus)
				Return (lRet := .T.)
			Else
				&('StaticCall(BUD744, B744TocaSom)')
				Alert('CÓDIGO DE ORDEM DE PRODUÇÃO NÃO INFORMADO. VERIFIQUE !!!')
				Return (lRet := .F.)
			EndIf
		EndIf
	ElseIf	AllTrim(Upper(cCampo)) == 'CCODPRO'
		lNumOP := .F.
		If	Empty(cCto)
			If	(nSair == nFocus) .And. Empty(nQtdApo)
				Return (lRet := .T.)
			ElseIf	(nLimpar == nFocus) .And. !Empty(nQtdApo)
				&('StaticCall(BUD744, B744TocaSom)')
				If	MsgYesNo('EXISTEM QUANTIDADES REGISTRADAS, DESEJA EFETUAR A PRODUÇÃO DELAS AGORA ?')
					Return (lRet := .T.)
				Else
					Return (lRet := .F.)
				EndIf
			ElseIf	(nOk == nFocus) .And. Empty(nQtdApo)
				&('StaticCall(BUD744, B744TocaSom)')
				Alert('NÃO FORAM INFORMADOS QUANTIDADES PARA O APONTAMENTO DESTA ORDEM DE PRODUÇÃO. VERIFIQUE !!!')
				Return (lRet := .F.)
			EndIf
		EndIf
	EndIf

	If	lNumOP
		If	Empty(nQtdApo)
			cNumOP := cCto
			SC2->(DbSeek(xFilial('SC2')+cNumOP))
			If	SC2->(Found())
				SB1->(DbSeek(xFilial('SB1')+SC2->C2_PRODUTO))
				If	!Empty(SC2->C2_DATRF)
					lRet := .F.
					&('StaticCall(BUD744, B744TocaSom)')
					Alert('ORDEM DE PRODUÇÃO '+cCto+' JÁ ENCERRADA !!!')
				ElseiF (AllTrim(SB1->B1_TIPO) != 'AF' .Or. AllTrim(SB1->B1_UM) != 'JG')
					lRet := .F.
					&('StaticCall(BUD744, B744TocaSom)')
					Alert('A ORDEM DE PRODUÇÃO NÃO É DE UM PRODUTO JOGO OU DE PRODUTO ACABADO AF !!!')

				Else
					/*
					------------------------------------------------------------------------
					Retirada a validação abaixo, pois deixamos que a rotina MATA250 controle
					no padrão o que pode ou não ser lançado de acordo com estoque / empenho
					Chamado do portal: #73983
					------------------------------------------------------------------------
					*/
					/*
					SD4->(DbSetOrder(2))
					SD4->(DbSeek(xFilial('SD4')+cCto,.T.))
					If	!SD4->(Found())
						lRet := .F.
						&('StaticCall(BUD744, B744TocaSom)')
						Alert('NÃO EXISTEM EMPENHOS DE PRODUTOS PARA ESTA ORDEM DE PRODUÇÃO DE JOGO, VERIFIQUE !!!')
					Else
						If	!(lRet := B1204Empenho(cCto))
							&('StaticCall(BUD744, B744TocaSom)')
							Alert('EXISTEM PRODUTOS EMPENHADOS PARA ESTA ORDEM DE PRODUÇÃO QUE JÁ FORAM BAIXADOS TOTALMENTE, FAVOR VERIFICAR NA TELA DE EMPENHOS !!! ')
						EndIf
					EndIf
					*/
				EndIf
			Else
				lRet := .F.
				&('StaticCall(BUD744, B744TocaSom)')
				Alert('ORDEM DE PRODUÇÃO '+cCto+' NÃO EXISTE !!!')
			EndIf
		Else
			oDlg:Refresh()
			MsgInfo('EXISTEM '+AllTrim(Str(nQtdApo))+' JOGOS INFORMADOS QUE AINDA NÃO FORAM APONTADOS, CONFIRME PARA CONTINUAR !!!')
			If	B1204Ok()
				B1204Limpar()
			EndIf
		EndIf
	Else
		If	(SB1->B1_CODBAR != cCto) .And. !Empty(cCto)
			If	(nLimpar != nFocus)

				// Adicionado LIKE para encontrar cdigos de barras que esto dentro de cdigo maiores como o do Riachuelo (#91609) - Joao Gebauer - 05/06/2024
				cFiltroBarra := "%(A7_BARRA = '"+cCto+"' OR A7_CODCLI = '"+cCto+"')%"

				SC5->(DbSeek(xFilial('SC5')+cNumPV))
				If	SC5->(Found())
					If SC5->C5_CLIENTE $ '200056' // Codigo para Riachuelo
						cFiltroBarra := "%((A7_BARRA <> '' AND '"+cCto+"' LIKE '%'+LTRIM(RTRIM(A7_BARRA))+'%') OR (A7_CODCLI <> '' AND '"+cCto+"' LIKE '%'+LTRIM(RTRIM(A7_CODCLI))+'%'))%"
					EndIf
				EndIf

				// Verifico qual é o código de barras que deverá ser usado se o padrao do produto ou algum específico do cliente
				If (Select("TTT1204") <> 0)
					dbSelectArea("TTT1204")
					dbCloseArea()
				EndIf
				BeginSql Alias "TTT1204"
					SELECT
						TOP 1 A7_BARRA,
						A7_CODCLI,
						A7_CLIENTE
					FROM
						%Table:SC6% (NOLOCK) SC6
					INNER JOIN %Table:SA7% (NOLOCK) SA7
					ON SA7.%NotDel%
						AND A7_FILIAL = %xFilial:SA7%
						AND (
							(
								A7_CLIENTE = C6_CLI
								AND A7_LOJA = C6_LOJA
							)
							OR (
								A7_CLIENTE = %Exp:SC2->C2_CODCLI%
								AND A7_LOJA = %Exp:SC2->C2_LOJCLI%
							)
						)
						AND A7_PRODUTO = C6_PRODUTO
						AND %Exp:cFiltroBarra%
					WHERE
						SC6.%NotDel%
						AND C6_FILIAL = %xFilial:SC6%
						AND C6_PRODUTO = %Exp:SC2->C2_PRODUTO%
						AND C6_NUM = %Exp:SC2->C2_NUMPED%
				EndSql
				If TTT1204->(Eof())
					lRet := .F.
					&('StaticCall(BUD744, B744TocaSom)')
					Alert('CÓDIGO DE BARRAS DO PRODUTO INFORMADO NÃO ENCONTRADO NA ORDEM PRODUÇÃO !!!')
				Else
					nQtdApo += nMultJG
					lGaiolaIns	:= .T.
				EndIf
			EndIf
		ElseIf	!Empty(cCto)
			// Verifico a obrigatoriedade de se informar o código da gaiola:
			If lGaiolaObr .And. Empty(cCodGaiola)
				// Mensagem de erro:
				&('StaticCall(BUD744, B744TocaSom)')
				MsgStop("O código da gaiola/carrinho é obrigatório para essa OP!")
				// Atualizo tela:
				oDlg:Refresh()
				// Limpo campos do produto:
				cCodPro	:= ''
				cCto	:= ''
				// Atualizo campo:
				oCodPro:Refresh()
				// Seto Focus:
				oCodGaiola:SetFocus()
				// Retorno verdadeiro para sair do campo:
				Return (.T.)
			End If
			nQtdApo += nMultJG
			lGaiolaIns	:= .T.
		EndIf

	EndIf

	If	lRet .And. lNumOP
		dEmisOP 	:= SC2->C2_EMISSAO
		nMultJG		:= Posicione('SZ7', 1, xFilial('SZ7')+SB1->B1_CODMOD, 'Z7_QTDPCT')
		cDescJg 	:= AllTrim(SB1->B1_DESC) + " x"+AllTrim(Str(nMultJG))
		If	!Empty(SC2->C2_NUMPED)
			cNumPV  := SC2->C2_NUMPED
			cItemPv := SC2->C2_ITEMPED

			SC5->(DbSeek(xFilial('SC5')+cNumPV))
			If	SC5->(Found())
				cCliente := SC5->C5_CLIENTE + '/' + SC5->C5_LOJACLI + ' - ' + AllTrim(Posicione('SA1',1,xFilial('SA1')+SC5->(C5_CLIENTE+C5_LOJACLI),'A1_NOME'))
			Else
				cCliente:= Space(TamSx3('A1_COD')[1])+'/' + Space(TamSx3('A1_LOJA')[1]) + ' - ' + Space(TamSx3('A1_NOME')[1])
				// Não deixo seguir se o número do pedido for inválido:
				If lGaiolaObr
					&('StaticCall(BUD744, B744TocaSom)')
					MsgStop("O número do pedido não foi informado!")
					Return (lRet := .F.)
				EndIf
			EndIf
		Else
			cNumPV  := SC2->C2_PEDIDO
			cItemPv := SC2->C2_ITEMPV

			SC5->(DbSeek(xFilial('SC5')+cNumPV))
			If	SC5->(Found())
				cCliente := SC5->C5_CLIENTE + '/' + SC5->C5_LOJACLI + ' - ' + AllTrim(Posicione('SA1',1,xFilial('SA1')+SC5->(C5_CLIENTE+C5_LOJACLI),'A1_NOME'))
			Else
				cCliente:= Space(TamSx3('A1_COD')[1])+'/' + Space(TamSx3('A1_LOJA')[1]) + ' - ' + Space(TamSx3('A1_NOME')[1])
			EndIf
		EndIf
		dDtEntr 	:= SC2->C2_DATPRF
		cObserv 	:= IIf(SC2->(FieldPos('C2_OBSJGS'))<>0,SC2->C2_OBSJGS, SC2->C2_OBS)
		nQtdOP  	:= SC2->C2_QUANT
		nQtdProd	:= SC2->C2_QUJE
		cProduto	:= SC2->C2_PRODUTO
		cCodPro := Space(TamSx3('B1_CODBAR')[1])

		// Verifico itens pendentes de apontamento:
		If !Empty(cNumOP)
			If (Select("T1204A") <> 0)
				DbSelectArea("T1204A")
				DbCloseArea()
			Endif
			cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(SUM(ZDU_MULTIP), 0) AS QTDAPON FROM ZDU010 (NOLOCK) WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cCto+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' ")
			TCQuery cQuery NEW ALIAS "T1204A"
			IF !T1204A->(Eof())
				IF T1204A->QTDAPON > 0
					If MsgYesNo("O sistema identificou ["+AllTrim(Str(T1204A->QTDAPON))+"] peças lidas anteriormente, porém não apontadas ainda para essa OP. Deseja continuar o apontamento anterior?")
						nQtdApo		:= T1204A->QTDAPON
						nQtdProd	+= T1204A->QTDAPON
					Else
						// Se o usuário deseja iniciar do zero, elimino todos os registros efetuados anteriormente daquela OP:
						nQtdApo	:= 0
						TCSQLEXEC("UPDATE ZDU010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cCto+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' ")
					EndIf
				End If
			EndIf
		EndIF

		// Atualiza variável da OP:
		cNumOP	 := cCodBar

		// Busco produtos endereçados:
		Busca_Endereco(SB1->B1_COD)

		// Verifica impressão do código de barras:
		U_B1204VeImp(cNumOP, .T.)

		// Verifico possibilidade de envio da mercadoria para o Flow Rack:
		If !Empty(cNumOP) .And. lNumOP
			lEnvioFlw	:= .F.
			If AllTrim(U_B1391Param("FLOW_RACK", "G2_CODCLI")) == AllTrim(SC2->C2_CODCLI) .And. ;
					AllTrim(U_B1391Param("FLOW_RACK", "G2_CODLOJA")) == AllTrim(SC2->C2_LOJCLI) .And. ;
					AllTrim(U_B1391Param("FLOW_RACK", "G2_LOCAL")) == AllTrim(SC2->C2_LOCAL)

				If AllTrim(U_B1391Param("FLOW_RACK", "G2_JGENV")) == "M3"
					MsAguarde({|| lEnvioFlw := CheckVRN(cNumOP) }, "Aguarde", "Verificando disponibilidade de envio para VRN...")
				ElseIf AllTrim(U_B1391Param("FLOW_RACK", "G2_JGENV")) == "SEMPRE"
					lEnvioFlw	:= .T.
				ElseIf AllTrim(U_B1391Param("FLOW_RACK", "G2_JGENV")) == "NUNCA"
					lEnvioFlw	:= .F.
				EndIf

				// Verifico se envia para VRN:
				If lEnvioFlw
					cCliente	:= "DESTINO => VRN MARKETPLACES!!!"
				EndIf
			EndIf
		EndIf

		// Inicio - Atualizado verificação para o uso da gaiola (#90119) - Joao Gebauer - 13/06/2024
		// Se requisição vier do Flow Rack
		If lEnvioFlw
			lGaiolaObr	:= .T.
			oCodGaiola:Enable()
			oCodGaiola:SetFocus()
		Else
			// Busca o pedido
			If !Empty(SC2->C2_NUMPED)
				cNumPV := SC2->C2_NUMPED
			Else
				cNumPV := SC2->C2_PEDIDO
			EndIf

			SC5->(DbSeek(xFilial('SC5')+cNumPV))

			// Se encontrar o pedido
			If SC5->(Found())
				// Verifica se o cliente e produto estão liberados para uso da gaiola
				If (Select("PROCLI") <> 0)
					DbSelectArea("PROCLI")
					DbCloseArea()
				EndIf

				BeginSql Alias "PROCLI"
					SELECT
						TOP 1 PRC_REF
					FROM
						TB_PROCLICD (NOLOCK)
					WHERE
						%NotDel%
						AND PRC_ATIVO = 'S'
						AND PRC_REF = %exp:AllTrim(SC2->C2_PRODUTO)%
						AND PRC_CLIENTE = %exp:AllTrim(SC5->C5_CLIENTE)%
				EndSql

				// Se estiver liberado
				If PROCLI->(!Eof())
					lGaiolaObr := .T.
					oCodGaiola:Enable()
					oCodGaiola:SetFocus()

				Else
					lGaiolaObr := .F.
					oCodGaiola:Disable()
					oCodPro:SetFocus()
				EndIf
			EndIf
		EndIf
		// Fim - Atualizado verificação para o uso da gaiola (#90119) - Joao Gebauer - 13/06/2024

		//oItensEmp:oBrowse:Refresh()
		oDlg:Refresh()
	EndIf

	If	lRet .And. !lNumOP .And. !Empty(cCto)
		If	(nQtdApo > (SC2->C2_QUANT - SC2->C2_QUJE - SC2->C2_PERDA))
			lGaiolaIns	:= .F.
			lRet := .F.
			nQtdApo -= nMultJG
			oQtdApo:Refresh()
			oDlg:Refresh()
			If	(nLimpar != nFocus)
				&('StaticCall(BUD744, B744TocaSom)')
				If	MsgYesNo('QUANTIDADE DE JOGOS INFORMADOS É MAIOR QUE A QUANTIDADE EXISTENTE NA ORDEM DE PRODUÇÃO, FINALIZAR ?')
					lRet := .T.
					If	B1204Ok()
						oCodBar:SetFocus()
					EndIf
				EndIf
			Else
				If	(nLimpar != nFocus)
					oCodPro:SetFocus()
				EndIf
			EndIf
		Else
			// Verifico se insiro registro na gaiola:
			If lRet .And. lGaiolaIns .And. !Empty(cCodGaiola) .And. lGaiolaObr
				InsGaiola()
			EndIf

			lNovo := .F.
			nQtdProd += nMultJG
			oQtdProd:Refresh()
			oDlg:Refresh()
			If	(nQtdProd == (SC2->C2_QUANT - SC2->C2_PERDA))
				&('StaticCall(BUD744, B744TocaSom)')
				MsgInfo('FOI REGISTRADO O TOTAL DE PEÇAS PARA ESTA O.P. A MESMA SERÁ FINALIZADA !!!!')
				If	B1204Ok()
					B1204Limpar()
					lNovo := .T.
				EndIf
			EndIf

			If	(nLimpar != nFocus) .And. !lNovo
				oCodPro:SetFocus()
			EndIf

			// Retorno focus para a OP:
			If lNovo
				cCodBar := Space(TamSx3('D3_OP')[1])
				cCodPro := Space(TamSx3('B1_CODBAR')[1])
				oCodPro:Refresh()
				oCodBar:Refresh()
				oCodBar:SetFocus()
				oDlg:Refresh()
				// Forço focus:
				//oTmrFocus := TTimer():New(500, {|| oCodBar:SetFocus(), oTmrFocus:DeActivate() }, oDlg )
				//oTmrFocus:Activate()
				Return (lRet)
			EndIf
		EndIf

		cCodPro := Space(TamSx3('B1_CODBAR')[1])
		oCodPro:Refresh()
	EndIf

	oDlg:Refresh()

Return lRet

// Verifica disponibilidade de mercadoria para recebimento no Flow Rack:
Static Function CheckVRN(cNumOP)

	Local aHeader 			:= {}
	Local oRestClient
	Local oResponse
	Local cEndereco			:= AllTrim(U_B1391Param("FLOW_RACK", "API_TREND"))
	Local cEndPoint			:= AllTrim(U_B1391Param("FLOW_RACK", "API_TRCAP"))
	Local lVRNOK			:= .F.

	// Busco produto e quantidade para validação:
	If (Select("T1204A") <> 0)
		DbSelectArea("T1204A")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT TOP 1 C2_PRODUTO, C2_QUANT FROM SC2010 (NOLOCK) WHERE C2_FILIAL = '01' AND C2_NUM = '"+Left(cNumOP, 6)+"' AND (C2_NUM+C2_ITEM+C2_SEQUEN) = '"+AllTrim(cNumOP)+"' AND SC2010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T1204A"
	IF !T1204A->(Eof())
		// Verifico capacidade disponível:
		oRestClient := FWRest():New(cEndereco)
		oRestClient:setPath("/?a="+AllTrim(cEndPoint)+"&pr="+AllTrim(T1204A->C2_PRODUTO)+"&qt="+AllTrim(Str(T1204A->C2_QUANT)))
		Aadd(aHeader, "Content-Type: application/json")
		Aadd(aHeader, "x-access-token: "+AllTrim(U_B1391Param("FLOW_RACK", "API_TRTTKN")))
		Aadd(aHeader, "x-api-key: "+AllTrim(U_B1391Param("FLOW_RACK", "API_TRKTKN")))
		If oRestClient:Get(aHeader)
			FWJsonDeserialize(DecodeUtf8(oRestClient:GetResult()), @oResponse)
			If oResponse:status == "OK"
				lVRNOK	:= .T.
			EndIf
		EndIf
	EndIf

Return lVRNOK

// Imprime código de barras do jogo:
User Function B1204VeImp(cNumOP, lInicio)

	If Empty(cNumOP)
		Return
	EndIf

	// Verifico se está liberado:
	If !SuperGetMv('BD_1204IMP')
		Return
	EndIf

	// Verifico quantidade a ser impressa:
	SC2->(DbSeek(xFilial('SC2')+cNumOP))
	If	SC2->(Found())
		nQtdEtq		:= (SC2->C2_QUANT - SC2->C2_QUJE - SC2->C2_QTDETQ)
		cCodBar		:= AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO, 'B1_CODBAR'))
		cDescPro	:= AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO, 'B1_DESC'))
		cDescJG		:= AllTrim(Posicione('SB1', 1, xFilial('SB1')+SC2->C2_PRODUTO, 'B1_DESCETQ'))

		//nQtdEtq	:= 2
		If nQtdEtq <= 0
			If lInicio
				// Caso seja chamado do início, e não tenha mais saldo para impressão de etiquetas, eu saio da rotina:
				Return
			Else
				// Caso não seja chamado pelo início, eu imprimo apenas uma etiqueta:
				nQtdEtq	:= 1
			EndIf
		EndIf
		// Verifico se existe impressão a ser efetuada:
		If nQtdEtq > 0
			// Verifico código de barras:
			If Empty(cCodBar)
				If !lInicio
					MsgStop("Não foi possível localizar o código de barras do jogo para impressão do código de barras!")
				EndIf
				Return
			EndIf
			// Verifico descrição do produto:
			If Empty(cDescJG)
				If !lInicio
					MsgStop("Esse código de barras não está cadastrado para efetuar a impressão pelo sistema. Gentileza solicitar as etiquetas para o setor responsável!")
				EndIf
				Return
			EndIf
			// Pergunto para o usuário se tem a necessidade de efetuar a impressão:
			IF MsgBox("Deseja imprimir ["+AllTrim(Str(nQtdEtq))+"] etiqueta(s) para esse jogo?", "Imprimir", "YESNO")
				MsgRun("Imprimindo ["+AllTrim(Str(nQtdEtq))+"] etiqueta(s) da OP ["+AllTrim(cNumOP)+"]", "Aguarde...", {|| B1204Impr(nQtdEtq, cCodBar, cDescPro, cDescJG) })
				// Atualizo quantidade gerada de etiqueta no campo:
				SC2->(DbSeek(xFilial('SC2')+cNumOP))
				If	SC2->(Found())
					RecLock('SC2',.F.)
					SC2->C2_QTDETQ += nQtdEtq
					MsUnlock()
				EndIf
			EndIf
		EndIf
	EndIf

Return

// Imprime código de barras do jogo:
Static Function B1204Impr(nQtdEtq, cCodBar, cDescPro, cDescJG)

	Local cImpr		:= 'ZEBRA'									// Nome da impressora compartilhada
	Local cPorta	:= 'LPT1'									// Porta que está mapeada
	Local cDirEtq	:= '\EtiqJG\'								// Caminho dentro do Protheus_Data que estão as etiquetas .prn
	Local nTamEtq	:= 1200										// Tamanho da etiqueta em milímetros
	Local cCmdZPL	:= ''  										// Variável que receberá as informações ZPL para ser enviadas para a impressora
	Local nQtdPapel	:= 2										// Quantidade de etiqueta por papel
	Local nQtdImpr	:= 0										// Quantidade a ser impressa
	Local cArquivo	:= cDirEtq + AllTrim(cCodBar) + '.prn'		// Caminho + nome do arquivo completo para buscar as informações do .prn
	Local _x 		:= 0

	// Verifico a quantidade de impressão:
	nQtdImpr	:= Ceiling(nQtdEtq / nQtdPapel)

	// Verifico se o arquivo existe:
	If !File(cArquivo)
		MsgStop("Atenção, não foi possível localizar o arquivo PRN ["+cArquivo+"]! Gentileza solicitar para liberação das etiquetas...")
		Return
	EndIf

	// Verifico quantidade e ser impressa:
	If nQtdImpr <= 0
		MsgStop("Atenção, não existem quantidades suficientes a serem impressas!")
		Return
	EndIf

	// Abro o arquivo:
	nHandle := FOpen(cArquivo, FO_READ)
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
		// Envio para impressora:
		MSCBPRINTER(cImpr, cPorta, , , .F.)
		MSCBCHKSTATUS(.F.)
		MSCBINFOETI("CODIGO_JOGO", "CODIGO_JOGO")

		For _x := 1 To nQtdImpr
			MSCBBEGIN(1, 6, nTamEtq)
			MSCBWrite(cCmdZPL)
			MSCBEND()
		Next _x
		MSCBCLOSEPRINTER()
	Else
		// Mensagem de erro:
		MsgStop("Atenção, não foi possível encontrar nenhuma informação dentro do arquivo ["+cArquivo+"]!")
	EndIf

Return

Static Function B1204Ok()

	Local lRet 		:= .T.
	Local cTrRet	:= ""

	If	Empty(nQtdApo) .Or. Empty(cNumOP)
		Return (lRet := .T.)
	EndIf

	dbSelectArea('SC2')
	dbseek(xFilial('SC2')+cNumOP)
	If	!Found()
		&('StaticCall(BUD744, B744TocaSom)')
		Alert('Ordem de Produção não existe !!!')
		Return (lRet := .T.)
	EndIf

	dbSelectArea('SB1')
	dbseek(xFilial('SB1')+SC2->C2_PRODUTO)
	If	!Found()
		&('StaticCall(BUD744, B744TocaSom)')
		Alert('Não existe Cadastro do Produto da Ordem de Produção !!!')
		Return (lRet := .T.)
	EndIf

	// Verifico obrigatoriedade de se utilizar gaiola:
	If lGaiolaObr .And. Empty(cCodGaiola)
		&('StaticCall(BUD744, B744TocaSom)')
		MsgStop("O código da gaiola/carrinho é obrigatório para essa OP!")
		Return (lRet := .T.)
	EndIf

	/* Grava o apontamento da produção do jogo pelo código de barras informado */
	Begin Transaction

		MsAguarde({|| lRet := B1204Grava() }, 'Gravando', 'Aguarde, Apontamento ' + RTrim(SB1->B1_COD) + '...')
		If	lRet
			If	!Empty(SC2->C2_NUMPED)
				MsAguarde({|| B1204Email() }, 'Enviando', 'Aguarde, Enviando E-mail Apontamento O.P. ' + RTrim(SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)) + '...')
			EndIf
			If	SC2->(FieldPos('C2_RESERV')) <> 0 .And. lRet
				If	SC2->C2_RESERV == 'S'
					MsAguarde({|| lRet := B1204Reserva() }, 'Gravando', 'Aguarde, Reservando ' + RTrim(SB1->B1_COD) + '...')
				EndIf
			EndIf

			// Altero status dos itens da gaiola em andamento:
			If lGaiolaObr
				TCSQLEXEC("UPDATE ZDU010 SET ZDU_STATUS = 'APONTAMENTO FINALIZADO' WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' ")
				// Chama agrupamento por quantidade de pacote:
				MsAguarde({|| U_B1204ZDUGr(cNumOP, AllTrim(SB1->B1_COD)) }, 'Múltiplos', 'Aguarde, ajustando agrupamento de pacotes na gaiola...')
			EndIf
		Else
			DisarmTransaction()
		EndIf
	End Transaction

	// Verifico quantidade das OPs:
	If lGaiolaObr .And. lRet
		ValQtdOP()
	EndIf

	// Efetuar movimentação de entrada no CD:
	If lGaiolaObr .And. lRet .And. lLibGaiola .And. !Empty(cCodGaiola)
		IF MsgBox("Deseja efetuar transferência direta para o CD sem nota fiscal?", "Transferir", "YESNO")
			MsAguarde({|| cTrRet := &('StaticCall(BUD1120, BuscaWS, "&a=entradadir", "&g="+AllTrim(cCodGaiola)') }, "Transferindo", "Transferindo saldo para o CD...")
			// Verifico retorno:
			if Left(cTrRet, 2) != "OK"
				MsgStop("Erro ao dar entrada no CD: " + cTrRet)
			EndIf
		EndIf
	EndIf

	// Efetua lançamento de pré-reserva 30/04/2021:
	If lRet
		U_BUD1393(cNumOp, "JOGOS")

		// Chama rotina de abatimento de projeção 19/05/2021:
		If !Empty(SC2->C2_CLVL)
			// MsAguarde({|| U_BUD1307C(SC2->C2_CODMKT, "", cNumOP, "", 0, SC2->C2_LOCAL, "") }, "Cancelamento", "Aguarde, efetuando cancelamento dos pedidos de projecao...")
		EndIf
	EndIf

	If	lRet
		nQtdApo := 0
		SC2->(DbSeek(xFilial('SC2')+cCodBar))
		If	SC2->(Found())
			// Aqui efetuo reserva automática do pedido:
			If lGaiolaObr
				If !Empty(SC2->C2_NUMPED)
					MsAguarde({|| BuscaWS("&p="+AllTrim(SC2->C2_NUMPED), "") }, "Reserva", "Aguarde, reservando pedido ["+AllTrim(SC2->C2_NUMPED)+"]...")
				EndIf
			EndIf

			If	Empty(SC2->C2_DATRF)
				nQtdProd:= SC2->C2_QUJE
				cCodPro := Space(TamSx3('B1_CODBAR')[1])
				lRet    := B1204Empenho(cCodBar)
				oCodPro:SetFocus()
				//oTmrFocus := TTimer():New(500, {|| oCodPro:SetFocus(), oTmrFocus:DeActivate() }, oDlg )
				//oTmrFocus:Activate()
			Else
				B1204Limpar()
				oCodBar:SetFocus()
				//oTmrFocus := TTimer():New(500, {|| oCodBar:SetFocus(), oTmrFocus:DeActivate() }, oDlg )
				//oTmrFocus:Activate()
			EndIf
		EndIf
		cNumOP := cCodBar
		//oItensEmp:oBrowse:Refresh()
		//oDlg:Refresh()
		//oCodPro:SetFocus()
	Else
		&('StaticCall(BUD744, B744TocaSom)')
		MsgInfo('Ocorreu um problema no apontamento da Produção do Jogo, Verifique !!!')
		oCodPro:SetFocus()
	EndIf

Return lRet

// Função para realizar o agrupamento por quantidade de pacote na ZDU:
User Function B1204ZDUGr(cNumOP, cProduto)

	Local nQtGai	:= 0
	Local nQtdAcum	:= 0

	// Para homologação:
	//RpcSetEnv('01','01',,,,"SIGAEST",,)

	// Verifico as gaiolas envolvidas na OP:
	If (Select("TT1204A") <> 0)
		DbSelectArea("TT1204A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 15 ZCN_QTDPCT, C2_QUJE, ZDU_NUMOP, ZDU_CODGA, AVG(ZDU_MULTIP) AS QMULT, SUM(ZDU_MULTIP) AS QGAI "
	cQuery += "FROM ZDU010 (NOLOCK) "
	cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = ZDU_CLI AND A1_LOJA = ZDU_LOJA AND SA1010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN ZCN010 (NOLOCK) ON ZCN_FILIAL = '' AND ZCN_CODIGO = A1_CODENCX AND ZCN_REF = '"+Left(cProduto, 8)+"' AND ZCN_TAM = '"+Right(cProduto, 4)+"' AND ZCN010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZDU_NUMOP, 6) AND C2_NUM+C2_ITEM+C2_SEQUEN = ZDU_NUMOP AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZDU_FILIAL = '' "
	cQuery += "AND ZDU_NUMOP = '"+cNumOP+"' "
	cQuery += "AND ZDU_LOCFIS = 'SA' AND ZDU_STATUS = 'APONTAMENTO FINALIZADO' " // Comentar em homologação
	cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY ZCN_QTDPCT, C2_QUJE, ZDU_CODGA, ZDU_NUMOP "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1204A"
	If !TT1204A->(Eof())
		While !TT1204A->(Eof())
			If TT1204A->C2_QUJE <= 0 .Or. TT1204A->QGAI <= 0 .Or. TT1204A->QMULT >= TT1204A->ZCN_QTDPCT
				TT1204A->(dbSkip())
				Loop
			EndIf

			nQtGai	:= TT1204A->QGAI
			if TT1204A->C2_QUJE < nQtGai
				nQtGai	:= TT1204A->C2_QUJE
			EndIf

			// Atualizo quantidade de múltiplo na gaiola conforme grade:
			cUPD := "UPDATE ZDU010 SET ZDU_MULTIP = '"+AllTrim(Str(TT1204A->ZCN_QTDPCT))+"' "
			cUPD += "WHERE ZDU_FILIAL = '' "
			cUPD += "AND ZDU_CODGA = '"+TT1204A->ZDU_CODGA+"' "
			cUPD += "AND ZDU_NUMOP = '"+TT1204A->ZDU_NUMOP+"' "
			cUPD += "AND ZDU_MULTIP <> '"+AllTrim(Str(TT1204A->ZCN_QTDPCT))+"' "
			cUPD += "AND ZDU_LOCFIS = 'SA' AND ZDU_STATUS = 'APONTAMENTO FINALIZADO' " // Comentar em homologação
			cUPD += "AND ZDU010.D_E_L_E_T_ = '' "
			TcSQLExec(cUPD)

			// Elimino demais itens da gaiola da OP para fechar com a quantidade original que estava a gaiola:
			nQtdAcum	:= 0
			If (Select("TT1204B") <> 0)
				DbSelectArea("TT1204B")
				DbCloseArea()
			Endif
			cQuery := "SELECT TOP 1000 ZDU_NUMOP, ZDU_CODGA, ZDU_MULTIP, ZDU_ITEMGA, ZDU_PRODUT, ZDU010.R_E_C_N_O_ AS RECNOAGR "
			cQuery += "FROM ZDU010 (NOLOCK) "
			cQuery += "WHERE ZDU_FILIAL = '' "
			cQuery += "AND ZDU_CODGA = '"+TT1204A->ZDU_CODGA+"' "
			cQuery += "AND ZDU_NUMOP = '"+cNumOP+"' "
			cQuery += "AND ZDU_LOCFIS = 'SA' AND ZDU_STATUS = 'APONTAMENTO FINALIZADO' " // Comentar em homologação
			cQuery += "AND ZDU010.D_E_L_E_T_ = '' "
			cQuery += "ORDER BY ZDU_ITEMGA ASC"
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1204B"
			If !TT1204B->(Eof()) .And. nQtGai > TT1204A->ZCN_QTDPCT
				While !TT1204B->(Eof())
					nQtdAcum	+= TT1204B->ZDU_MULTIP

					// Caso a quantidade já fechou, elimino o saldo restante:
					if nQtdAcum >= nQtGai
						cDEL := "UPDATE ZDU010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
						cDEL += ", ZDU_STATUS = 'MULTIPLO AGRUPADO' "
						cDEL += "WHERE ZDU_FILIAL = '' "
						cDEL += "AND ZDU_CODGA = '"+TT1204B->ZDU_CODGA+"' "
						cDEL += "AND ZDU_NUMOP = '"+TT1204B->ZDU_NUMOP+"' "
						cDEL += "AND ZDU_ITEMGA > '"+TT1204B->ZDU_ITEMGA+"' "
						cDEL += "AND ZDU_PRODUT = '"+TT1204B->ZDU_PRODUT+"' "
						cDEL += "AND ZDU_LOCFIS = 'SA' AND ZDU_STATUS = 'APONTAMENTO FINALIZADO' " // Comentar em homologação
						cDEL += "AND ZDU_LOCFIS IN ('CD', 'SA') "
						cDEL += "AND ZDU010.D_E_L_E_T_ = '' "
						TcSQLExec(cDEL)

						// Saio do loop dos itens da gaiola:
						nQtGai	:= 999999
						Exit
					EndIf

					TT1204B->(dbSkip())
				EndDo
			EndIf

			TT1204A->(dbSkip())
		EndDo
	EndIf

	// Para homologação:
	//RpcClearEnv()

Return

// Função WS padrão para chamar a rotina de reserva automática do Hydra::
Static Function BuscaWS(cParamGet, cParamPost)

	Local aHeadOut 	:= {}
	Local cHeadRet 	:= ""
	Local cCaminho	:= "http://hydra.buddemeyer.com.br/reserva/wf_reserva_auto_projeto.php"
	Local cRetWS	:= ""
	Local cChave	:= "hydra@987"
	// Adiciono cabeçalho:
	aadd(aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut, 'Content-Type: application/x-www-form-urlencoded')
	// Efetuo post no endereço:
	cRetWS 	:= AllTrim(HttpPost(cCaminho, ("w="+Upper(AllTrim(ComputerName()))+cParamGet), ("c="+cChave+cParamPost), 5, aHeadOut, @cHeadRet))

Return cRetWS

Static function B1204Sair()

	If	!Empty(nQtdApo)
		&('StaticCall(BUD744, B744TocaSom)')
		If	MsgYesNo('EXISTEM '+AllTrim(Str(nQtdApo))+' JOGOS APONTADOS QUE AINDA NÃO FORAM FINALIZADOS, CONFIRMA APONTAMENTO ? ')
			If	!B1204Ok()
				Return
			EndIf
		Else
			oCodPro:SetFocus()
			Return
		EndIf
	EndIf

	oDlg:End()

Return

Static Function B1204Limpar()

	cCodBar 	:= Space(TamSx3('D3_OP')[1])
	cNumOP	 	:= cCodBar
	dEmisOP 	:= Stod('')
	cDescJg 	:= Space(TamSx3('B1_DESC')[1])
	cNumPV  	:= Space(TamSx3('C5_NUM')[1])
	cItemPv 	:= Space(TamSx3('C6_ITEM')[1])
	dDtEntr 	:= Stod('')
	cCliente	:= Space(TamSx3('A1_COD')[1])+'/'+Space(TamSx3('A1_LOJA')[1])+' - '+Space(TamSx3('A1_NOME')[1])
	cObserv 	:= Space(TamSx3('C2_OBS')[1])
	cEndAvu 	:= Space(TamSx3('C2_OBS')[1])
	cEndJG  	:= Space(TamSx3('C2_OBS')[1])
	nQtdOP  	:= 0
	nQtdProd	:= 0
	nQtdApo 	:= 0
	cCodPro 	:= Space(TamSx3('B1_CODBAR')[1])
	cCodGaiola	:= Space(TamSx3('ZDT_CODIGO')[1])
	lGaiolaObr	:= .F.
	lLibGaiola	:= .F.
	cSaySens	:= ''

	//fItensEmp()

	//oItensEmp:aCols := {}
	cEmpJG			:= ""

	//oItensEmp:oBrowse:Refresh()
	oDlg:Refresh()
	oCodBar:SetFocus()

Return

Static Function B1204Grava()

	Local lRet     := .T.
	Local cDoc     := CriaVar('D3_DOC')
	//Local cTime    := Substr(Time(),1,5)
	Local cParcTot := IIf((SC2->C2_QUJE+nQtdApo) == SC2->C2_QUANT, 'T','P')
	Local cTm		 := '001'

	SF5->(dbSeek(xfilial('SF5')+'003')) // Código de apontamento de Produção de Jogos para liberação de PV automaticamente
	If	SF5->(Found())
		cTm	:= SF5->F5_CODIGO
	EndIf

	dbSelectArea('SD3')
	dbGotop()

	aAreaSD3:=GetArea()
	dbSetOrder(2)
	If 	dbSeek(xFilial("SD3")+Padr(cNumOP,Len(cDoc)))
		cDoc := NextNumero("SD3",2,"D3_DOC",.T.)
		cDoc := A261RetINV(cDoc)
	Else
		cDoc := Padr(cNumOP,Len(cDoc))
	EndIf
	RestArea(aAreaSD3)

	//cDoc := NextNumero("SD3",2,"D3_DOC",.T.)

	// Não prossigo se o registro esteja travado:
	/*
	While U_zLockSB2(SB1->B1_COD, SC2->C2_LOCAL, .F.)
		// Caso o registro esteja travado, não prossigo...
		U_BUD1427("[BUD1204] - Registro ["+AllTrim(SB1->B1_COD)+"]/["+AllTrim(SC2->C2_LOCAL)+"] esta travado...")
	EndDo
	*/

	aRot250 := {	{"D3_OP"		, cNumOp 		, Nil},;
		{"D3_TM"		, cTm  					, Nil},;
		{"D3_COD"    	, SB1->B1_COD				, Nil},;
		{"D3_DOC"    	, cDoc    					, Nil},;
		{"D3_QUANT"  	, nQtdApo        			, Nil},;
		{"D3_UM"     	, SB1->B1_um				, Nil},;
		{"D3_LOCAL"  	, SC2->C2_LOCAL 			, Nil},;
		{"D3_EMISSAO"	, dDataBase				, Nil},;
		{"D3_USUARIO"	, Substr(cUsuario,7,15)	, Nil},;
		{"D3_PARCTOT"	, cParcTot					, Nil}}

	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	//Begin Transaction
	MsExecAuto({|x,y| Mata250(x,y)},aRot250,3)
	If 	(lMsErroAuto)
		lRet := .F.
		&('StaticCall(BUD744, B744TocaSom)')
		Aviso("Rotina Abortada","Erro na geracao do apontamento da Op!!! Favor salvar a tela e enviar para o Administrador do sistema!!!",{"OK"})
		//DisarmTransaction()
		MostraErro()
	Else
		// Somo quantidade a empenhar:
		If lEnvioFlw
			cUpd := "UPDATE SB2010 SET B2_AEMPENH = (B2_AEMPENH + "+AllTrim(Str(nQtdApo))+") "
			cUpd += "WHERE B2_FILIAL = '"+xFilial("SB2")+"' "
			cUpd += "AND B2_COD = '"+SB1->B1_COD+"' "
			cUpd += "AND B2_LOCAL = '"+SC2->C2_LOCAL+"' "
			cUpd += "AND SB2010.D_E_L_E_T_ = '' "
			TCSQLEXEC(cUpd)
		EndIf

		// Thiago 09/08/2017:
		U_BUD1278(SB1->B1_COD, SC2->C2_LOCAL)
	EndIf
	//End Transaction

Return lRet

Static Function B1204Reserva()

	Local cAliasRes := 'RES1204'
	Local cC0_NUM	  := CriaVar('C0_NUM',.F.)
	Local nC0_QUANT := nQtdApo
	Local lRet		  := .T.

	If	!Empty(SC2->C2_NUMRES)
		cRestxt := " C0_NUM = '"+SC2->C2_NUMRES+"' "
	Else
		cRestxt := ''
	EndIf

	If	!Empty(SC2->C2_NUMPED)
		cNumtxt := " C0_DOCRES = '"+SC2->C2_NUMPED+"' "
	Else
		cNumtxt := ''
	EndIf

	If	Empty(cRestxt) .And. Empty(cNumtxt)
		cQuery := '% '
	EndIf

	If	!Empty(cRestxt)
		cQuery := '% AND '+cRestxt
	EndIf

	If	!Empty(cNumtxt)
		If	!Empty(cRestxt)
			cQuery += ' AND ' + cNumtxt
		Else
			cQuery += '% AND ' + cNumtxt
		EndIf
	EndIf

	cQuery += ' %'

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
			AND C0_PRODUTO = %Exp:SC2->C2_Produto%
			AND C0_LOCAL = %Exp:SC2->C2_Local%
			AND C0_QUANT > 0 %Exp:cQuery%
	EndSql

	//Begin Transaction

	If	!Empty((cAliasRes)->C0_RECNO)
		SC0->(DbGoto((cAliasRes)->C0_RECNO))
		cC0_NUM   := SC0->C0_NUM
		nC0_QUANT += SC0->C0_QUANT
		A430Reserv ( { 3, 'PD', SC0->C0_DOCRES, cUserName, cFilial} , SC0->C0_NUM, SC0->C0_Produto, SC0->C0_Local, SC0->C0_QUANT, {'','','',''})
	ElseIf	!Empty(SC2->C2_NUMRES)
		cC0_NUM := SC2->C2_NUMRES
	Else
		cC0_NUM := B1204NumRes()
	EndIf

	A430Reserv ( { 1, 'PD', SC2->C2_NUMPED, cUserName, cFilial} , cC0_NUM, SC2->C2_Produto, SC2->C2_Local, nC0_QUANT, {'','','',''})

	SC0->(DbSeek(xFilial('SC0')+cC0_NUM+SC2->C2_PRODUTO+SC2->C2_LOCAL))
	If	SC0->(Found())

		RecLock('SC2',.F.)
		SC2->C2_NUMRES := cC0_NUM
		MsUnlock()
	EndIf

	//End Transaction

Return lRet

Static Function B1204NumRes()

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

Static Function B1204Empenho(cCto)

	Local lRet := .T.

	nRecSB1  		  := SB1->(Recno())
	//oItensEmp:aCols   := {}
	aCols   		  := {}
	aToalhas		  := {}
	aCores			  := {}
	nTotPcs		  	  := 0
	cEmpJG			  := ''

	SD4->(DbSetOrder(2))
	SD4->(DbSeek(xFilial('SD4')+cCto,.T.))
	While !SD4->(Eof()) .And. SD4->(D4_FILIAL+D4_OP) == xFilial('SD4')+cCto

		If	Empty(SD4->D4_QUANT)
			lRet := .F.
		EndIf

		SB1->(DbSeek(xFilial('SB1')+SD4->D4_COD))
		If	SB1->(Found())
			cDesc := SB1->B1_DESC
		Else
			cDesc := 'Produto Empenhado não Cadastrado !!!'
		EndIf

		SB2->(DbSeek(xFilial('SB2')+SD4->D4_COD+SD4->D4_LOCAL))
		If	SB2->(Found())
			nQatu := SB2->B2_QATU
		Else
			nQatu := 0
		EndIf

		// Verifico qual é o código de barras que deverá ser usado se o padrao do produto ou algum específico do cliente
		If (Select("TT1204") <> 0)
			dbSelectArea("TT1204")
			dbCloseArea()
		EndIf

		BeginSql Alias "TT1204"
			SELECT
				DISTINCT TOP 1 B1_CODBAR,
				ISNULL(A7_BARRA, '') AS A7_BARRA,
				ISNULL(A7_CODCLI, '') AS A7_CODCLI
			FROM
				%Table:SB1% (NOLOCK) SB1
			LEFT JOIN %Table:SC5% (NOLOCK) SC5
			ON SC5.%NotDel%
				AND C5_FILIAL = %xFilial:SC5%
				AND (
					C5_NUM = %EXP:SC2->C2_NUMPED%
					OR C5_NUM = %EXP:SC2->C2_PEDIDO%
				)
			LEFT JOIN %Table:SA7% (NOLOCK) SA7
			ON SA7.%NotDel%
				AND A7_FILIAL = %xFilial:SA7%
				AND (
					(
						A7_CLIENTE = C5_CLIENTE
						AND A7_LOJA = C5_LOJACLI
					)
					OR (
						A7_CLIENTE = %EXP:SC2->C2_CODCLI%
						AND A7_LOJA = %EXP:SC2->C2_LOJCLI%
					)
				)
				AND A7_PRODUTO = B1_COD
			WHERE
				SB1.%NotDel%
				AND B1_FILIAL = %xFilial:SB1%
				AND B1_COD = %exp:SD4->D4_COD%
		EndSql

		If !Empty(TT1204->A7_CODCLI)
			cCodigo := AllTrim(TT1204->A7_CODCLI)
		ElseIf	!Empty(TT1204->A7_BARRA)
			cCodigo := AllTrim(TT1204->A7_BARRA)
		ElseIf	!Empty(TT1204->B1_CODBAR)
			cCodigo := TT1204->B1_CODBAR
		Else
			cCodigo := SB1->B1_CODBAR
		EndIf

		// Busco a quantidade de peças por pacote para os produtos empenhados
		If (Select("TT1204") <> 0)
			dbSelectArea("TT1204")
			dbCloseArea()
		EndIf

		BeginSql Alias "TT1204"
			SELECT
				DISTINCT TOP 1 ISNULL(ZB1_QTDPCT, 0) AS ZB1_QTDPCT
			FROM
				%Table:ZB1% (NOLOCK) ZB1
			LEFT JOIN %Table:SC5% (NOLOCK) SC5
			ON SC5.%NotDel%
				AND C5_FILIAL = %xFilial:SC5%
				AND (
					C5_NUM = %exp:SC2->C2_NUMPED%
					OR C5_NUM = %exp:SC2->C2_PEDIDO%
				)
			INNER JOIN %Table:SA1% (NOLOCK) SA1
			ON SA1.%NotDel%
				AND A1_FILIAL = %xFilial:SA1%
				AND (
					(
						A1_COD = C5_CLIENTE
						AND A1_LOJA = C5_LOJACLI
					)
					OR (
						A1_COD = %EXP:SC2->C2_CODCLI%
						AND A1_LOJA = %EXP:SC2->C2_LOJCLI%
					)
				)
			WHERE
				ZB1.%NotDel%
				AND ZB1_FILIAL = %xFilial:ZB1%
				AND ZB1_COD = %exp:SD4->D4_COD%
				AND (
					ZB1_NUM = C5_NUM
					OR ZB1_NUM = ' '
				)
			GROUP BY
				ZB1_QTDPCT
		EndSql

		If	TT1204->(Bof()) .And. TT1204->(Eof())
			SZ7->(DbSeek(xFilial("SZ7")+SB1->B1_CODMOD))
			If 	SZ7->(Found())
				nQtdPcs := SZ7->Z7_QTDPCT
			Else
				nQtdPcs := 0
			EndIf
		Else
			nQtdPcs := TT1204->ZB1_QTDPCT
		EndIf

		nQtdPct := Round(SD4->D4_QUANT/nQtdPcs,0)
		If	(nQtdPct * nQtdPcs) < SD4->D4_QUANT
			nQtdPct++
		EndIf

		//aAdd(oItensEmp:aCols,{cCodigo, cDesc, nQtdPct, nQtdPcs, SD4->D4_QUANT ,nQatu, SD4->D4_LOCAL, .F.})
		cEmpJG	+= AllTrim(cDesc) + " - " + AllTrim(Str(SD4->D4_QUANT)) + " peça(s)" + Chr(13)+Chr(10)

		SB1->(DbSeek(xFilial('SB1')+SD4->D4_COD))
		If	SB1->(Found())

			SZ3->(DbSeek(xFilial('SZ3')+Right(RTrim(SB1->B1_COD),4)))
			If	SZ3->(Found())
				nQtd := (SD4->D4_QTDEORI / SC2->C2_QUANT)
				cDescGru := SZ3->Z3_DESCGRU

				If	nQtd > 1
					If	(nPos := At('TOALHA',cDescGru)) > 0
						cDescGru := Stuff(cDescGru, nPos, 6, 'TOALHAS')
					EndIf
				EndIf

				aAdd(aToalhas,{SZ3->Z3_COD, ;
					AllTrim(Str(nQtd)) + ' ' + AllTrim(cDescGru) + ": ", ;
					AllTrim(Str(SZ3->Z3_LARG*100)) + 'cm x ' + ;
					IIf(Int(SZ3->Z3_COMP)>0,AllTrim(Str(SZ3->Z3_COMP))+'m',AllTrim(Str(SZ3->Z3_COMP*100))+'cm') })
			EndIf
			nTotPcs += (nQtd)

			If	aScan(aCores, Substr(SB1->B1_COD,11,4)) == 0
				aAdd(aCores, Substr(SB1->B1_COD,11,4))
			EndIf

		EndIf

		SD4->(DbSkip())
	EndDo

	//oItensEmp:Gotop()
	SB1->(DbGoto(nRecSB1))

Return lRet

Static Function B1204Email()

	Local cPara	:= SuperGetMv('BUD_EMAILJ')
	Local cUsuario:= RTrim(UsrFullName( RetCodUsr() ))

	// INICIA PROCESSO
	oProcess := TWFProcess():New("000001","Apontamento Produção Jogos")
	oProcess:NewTask("000002","\WORKFLOW\WFAPOJGS.HTML")
	oProcess:cSubject := "Ref. Apontamento Produção Jogos "
	oProcess:cTo:= cPara

	oHTML := oProcess:oHTML

	_DataExtenso := strzero(day(dDatabase),2)    + " de " + MesExtenso(month(dDataBase)) + " de " +strzero(year(dDataBase),4)

	_cData := Capital(SM0->M0_CIDCOB)+", "+_DataExtenso

	// Empresa
	oHtml:ValByName("EMPRESA",Capital(SM0->M0_NOMECOM))

	// Data
	oHtml:ValByName("DATA"	,_cData)

	// Data
	oHtml:ValByName("HORA"	,Substr(Time(),1,5))

	//	Operador
	oHtml:ValByName("USUARIO",cUsuario)

	// 	Observacao
	oHtml:ValByName("OBS", SC2->C2_OBSJGS)

	//Itens
	AADD((oHtml:ValByName("IT.NUMOP")) 	,SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
	AADD((oHtml:ValByName("IT.PRODUTO")),SC2->C2_PRODUTO)
	AADD((oHtml:ValByName("IT.DESC"))   ,SB1->B1_DESC)
	AADD((oHtml:ValByName("IT.QUANT"))	,Transform(SC2->C2_QUANT,"@E 999,999.99"))
	AADD((oHtml:ValByName("IT.QUJE"))	,Transform(SC2->C2_QUJE,"@E 999,999.99"))
	AADD((oHtml:ValByName("IT.QTDAPO"))	,Transform(nQtdApo,"@E 999,999.99"))
	If	Empty(SC2->C2_PEDIDO)
		If	!Empty(SC2->C2_NUMPED)
			AADD((oHtml:ValByName("IT.PEDIDO")) ,SC2->C2_NUMPED)
			AADD((oHtml:ValByName("IT.ITEMPV")) ,SC2->C2_ITEMPED)
		EndIf
	ElseIf	!Empty(SC2->C2_PEDIDO)
		AADD((oHtml:ValByName("IT.PEDIDO")) ,SC2->C2_PEDIDO)
		AADD((oHtml:ValByName("IT.ITEMPV")) ,SC2->C2_ITEMPV)
	Else
		AADD((oHtml:ValByName("IT.PEDIDO")) ,Space(TamSx3('C2_PEDIDO')[1]))
		AADD((oHtml:ValByName("IT.ITEMPV")) ,Space(TamSx3('C2_ITEMPV')[1]))
	EndIf

	//FINALIZA O PROCESSO
	oProcess:Start()
	oProcess:Finish()

Return

/*
Static Function B1204Print()

	//Local cPath	:= '\\127.0.0.1\ZEBRAZT' // definir nome
	Local cPorta:= "LPT1"
	Local cPerg	:= "BUD1204"
	Local nX	:= 0

	If	Empty(cCodBar)
		Return (.F.)
	EndIf

	PutSx1(cPerg,"01","Quantidade Etiquetas   ?","Quantidade Etiquetas   ?","Quantidade Etiquetas   ?","mv_ch1",;
		"N",04,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",;
		{"Informe a quantidade de etiquetas   ",;
		"do Produto da OP que deseja imprimir "},{ },{ })

	SX1->(DbSeek(cPerg+Space(03)+'01'))
	If	SX1->(Found())
		RecLock('SX1',.F.)
		SX1->X1_CNT01 := AllTrim(Str(SC2->C2_QUANT - SC2->C2_QUJE - SC2->C2_PERDA))
		MsUnlock()
	EndIf

	If	!Pergunte(cPerg,.T.)
		Return (lRet := .F.)
	EndIf

	// Posiciona na Ordem de Produção do Jogo informado
	SC2->(DbSeek(xFilial('SC2')+cCodBar))

	// Posiciona no cadastro de Produto da Ordem de Produção
	SB1->(DbSeek(xFilial('SB1')+SC2->C2_PRODUTO))

	cDescJg := RTrim(SB1->B1_REFERJG)

	cDesCor := 'TOALHAS CORES '
	For nX:=1 To Len(aCores)
		cDesCor += aCores[nX]
		If	(nX + 1) <= Len(aCores)
			cDesCor += '/'
		EndIf
	Next nX

	cDesPcs := AllTrim(Str(nTotPcs))

	cQtd1Pc := IIf(Len(aToalhas) >=1,aToalhas[1,2],'')
	cQtd2Pc := IIf(Len(aToalhas) >=2,aToalhas[2,2],'')
	cQtd3Pc := IIf(Len(aToalhas) >=3,aToalhas[3,2],'')

	cTam1Pc := IIf(Len(aToalhas) >=1,aToalhas[1,3],'')
	cTam2Pc := IIf(Len(aToalhas) >=1,aToalhas[2,3],'')
	cTam3Pc := IIf(Len(aToalhas) >=1,aToalhas[3,3],'')

	cBarrJg := SB1->B1_CODBAR

	cArqIni 	:= 'ETQJOGOS_' + AllTrim(Len(aToalhas)) +'.TXT'
	nHandle  	:= 0
	cArqIni	:= cDirArq+cArqIni
	If (nHandle := FT_FUSE(AllTrim(cArqIni))) == -1
		MsgStop('Não foi encontrado arquivo de configuração para este Cliente, '+cArqIni+' Verifique !!!')
		Return .F.
	EndIf

	MSCBPRINTER("ZEBRAZT",cPorta, , ,.F.)
	MSCBCHKSTATUS(.F.)

	/////////////////////////IMPRESSAO MODELO ZEBRA ZT230
	/// 2300 (ZPL)///////////////////////////////////
	MSCBINFOETI("Etiquetas Expedição ","PRODUÇÃO JOGOS")
	MSCBBEGIN(1,6,800) // 800

	For nX:= 1 To Len(mv_par01)

		cLinha	:= ""
		nTot	:= FT_FLASTREC()
		FT_FGOTOP()
		While !FT_FEOF()

			cLinha := FT_FREADLN()
			If	Substr(cLinha,1,4) == '^PQ1'
				MSCBWrite('^FN1^FD' + cDescJg + '^FS') // nome do jogo
				MSCBWrite('^FN2^FD' + cDesCor + '^FS') // tipo e cores
				MSCBWrite('^FN3^FD' + cDesPcs + '^FS') // quantidade de peças

				MSCBWrite('^FN4^FD' + cQtd1Pc + '^FS') // qtd da 1 toalha
				MSCBWrite('^FN5^FD' + cQtd2Pc + '^FS') // qtd da 2 toalha
				MSCBWrite('^FN6^FD' + cQtd3Pc + '^FS') // qtd da 3 toalha

				MSCBWrite('^FN7^FD' + cTam1Pc + '^FS') // tamanho da 1 toalha
				MSCBWrite('^FN8^FD' + cTam2Pc + '^FS') // tamanho da 2 toalha
				MSCBWrite('^FN9^FD' + cTam3Pc + '^FS') // tamanho da 3 toalha

				MSCBWrite('^FNA^FD' + cBarrJg + '^FS') // código de barras
			EndIf
			MSCBWrite(cLinha)

			FT_FSKIP()

		EndDo

	Next

	FT_FUSE()

	MSCBEND()
	MSCBCLOSEPRINTER()

Return
*/

Static Function B1204Foto()

	Local oPnlSep1, cBmp, oBit
	Local aSize := FWGetDialogSize( oMainWnd )

	If	!Empty(cCodBar)
		SC2->(DbSeek(xFilial('SC2')+cCodBar))
		If	SC2->(Found())
			cCodJg := SC2->C2_PRODUTO + SC2->C2_LOCAL
		EndIf
	EndIf

	If	Empty(cCodJg)
		Return
	EndIf

	oJpgDlg := TDialog():New(aSize[1],aSize[2],aSize[3]*.8,aSize[4]*.8,"Foto do Jogo - "+cCodJg,,,,,,,,,.T.,,,,aSize[4]*.8,aSize[3]*.8)
	oPnlSep1 := TPanel():New(0,0,"",oJpgDlg,,,,,,100,100,,)
	oPnlSep1:Align := CONTROL_ALIGN_TOP
	oPnlSep1:nHeight := 3

	cBMP := "\FIGURAS\"+ALLTRIM(cCodJg)+".jpg"
	If !File(cBMP)
		cBMP := "\FIGURAS\noimage.jpg"
	EndIf

	oBit := TBitMap():New(0, 0, 10, 10,,cBMP,.t., , , ,,.t. , , , , , .t.)
	oBit:Align 	:=  CONTROL_ALIGN_ALLCLIENT
	oBit:cBMPFile	:= cBMP
	oBit:Load(cBMP)
	oBit:refresh()

	oJpgDlg:bInit := {|| EnchoiceBar(oJpgDlg,{|| oJpgDlg:End()},{|| oJpgDlg:End()},.F.,)}
	oJpgDlg:Activate(,,,.T.,,,)

Return

Static Function Busca_Endereco(cCodJG)

	// Busco endereço do jogo:
	cEndJG	:= ""
	If (Select("TT1204") <> 0)
		dbSelectArea("TT1204")
		dbCloseArea()
	EndIf
	cQuery := "SELECT DISTINCT ZD3_ENDERE "
	cQuery += "FROM "+RetSqlName("ZD3")+" (NOLOCK)  "
	cQuery += "WHERE "+RetSqlName("ZD3")+".D_E_L_E_T_ = '' "
	cQuery += "AND ZD3_FILIAL = '01' "
	cQuery += "AND ZD3_CODPRO = '"+cCodJG+"'  "
	cQuery += "AND ZD3_ENDERE <> '' "
	cQuery += "ORDER BY ZD3_ENDERE ASC "
	TCQuery cQuery NEW ALIAS "TT1204"
	If !TT1204->(EOF())
		While !TT1204->(Eof())
			cEndJG	+= AllTrim(TT1204->ZD3_ENDERE) + Chr(13)+Chr(10)
			TT1204->(dbSkip())
		EndDo
	Else
		cEndJG	:= "* NÃO ENDEREÇADO *"
	EndIf

	// Busco endereço dos avulsos:
	cEndAvu	:= ""
	If (Select("TT1204") <> 0)
		dbSelectArea("TT1204")
		dbCloseArea()
	EndIf
	cQuery := "SELECT DISTINCT ZD3_ENDERE, LEFT(ZN_DESCRI, 1) PRE_TAM "
	cQuery += "FROM "+RetSqlName("ZD3")+" (NOLOCK)  "
	cQuery += "INNER JOIN "+RetSqlName("SG1")+" (NOLOCK) ON G1_FILIAL = '01' AND G1_COMP = ZD3_CODPRO AND "+RetSqlName("SG1")+".D_E_L_E_T_ = ''  "
	cQuery += "INNER JOIN "+RetSqlName("SB1")+" (NOLOCK) ON B1_FILIAL = ''   AND B1_COD = ZD3_CODPRO AND "+RetSqlName("SB1")+".D_E_L_E_T_ = ''  "
	cQuery += "INNER JOIN "+RetSqlName("SZN")+" (NOLOCK) ON ZN_FILIAL = ''   AND ZN_CODTAM = B1_CODTAM AND "+RetSqlName("SZN")+".D_E_L_E_T_ = ''  "
	cQuery += "WHERE "+RetSqlName("ZD3")+".D_E_L_E_T_ = '' "
	cQuery += "AND ZD3_FILIAL = '01' "
	cQuery += "AND G1_COD = '"+cCodJG+"'  "
	cQuery += "AND ZD3_ENDERE <> '' "
	cQuery += "ORDER BY ZD3_ENDERE ASC "
	TCQuery cQuery NEW ALIAS "TT1204"
	If !TT1204->(EOF())
		While !TT1204->(Eof())
			cEndAvu	+= AllTrim(TT1204->ZD3_ENDERE) + " - " + AllTrim(TT1204->PRE_TAM) + Chr(13)+Chr(10)
			TT1204->(dbSkip())
		EndDo
	Else
		cEndAvu	:= "* NÃO ENDEREÇADO *"
	EndIf

Return

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
