#INCLUDE "TOPCONN.CH"
//#INCLUDE "colors.ch"
//#INCLUDE "winapi.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE NQTDSEG   1
#DEFINE NPERDA199 2
#DEFINE NPERDA299 3
#DEFINE NPERDA399 4
#DEFINE NPERDA499 5
#DEFINE NQTDLD    6
#DEFINE NPERDAPC  7
#DEFINE NRETALHO  8
#DEFINE NPERDA599 9
#DEFINE NPERDA699 10
#DEFINE DEFAULTSPACE 10
#DEFINE DEFAULTGETSPACE SPACE(60)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BUD744    º Autor ³Edinei Sanchez Milekº Data ³  28/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Programa para fazer apontamento de OPs                     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function BUD744(cOPRec, lAuto, nQtdRec)

	Local aObjects   	 := {}   // Array com os objetos
	Local aInfo      	 := {}   // Array com as dimensoes
	Local aPosObj    	 := {}   // Array com as dimensoes dos objetos
	Local aSize      	 := MsAdvSize(.F., .F.)				// Size da Dialog
	//Local bImpr          := {|| MsgRun("Configurando impressora","",{|| ConfigImpr() }), oGet1:SetFocus() }
	Local bReimpr        := {|| MsgRun("Reimprimir apontamento","",{|| Reimprimir() }), oGet1:SetFocus() }
	Local bEncerra       := {|| MsgRun("Gerando Apontamento e Encerrando a OP","",{|| CursorWait(), B744QtdApSeg(), CarregaSeg(), oContainer:Refresh(), B744Aponta() ,CursorArrow(), B744Encerra() }), oGet1:SetFocus() }
	Local bAponta        := {|| MsgRun("Gerando Apontamento da OP","",{|| CursorWait(), B744QtdApSeg(), CarregaSeg(), oContainer:Refresh(), B744Aponta() ,CursorArrow()}), oGet1:SetFocus() }

	Private cParamSeg
	Private lAutoFim	 := .F.

	Private oFont24		 := TFont():New( "Courier New"   ,,18,,.t.,,,,,.f. )
	Private oFont25		 := TFont():New( "Courier New"   ,,24,,.t.,,,,,.f. )
	Private oFont26		 := TFont():New( "Courier New"   ,,24,,.T.,,,,,.f. )
	Private oFont27		 := TFont():New( "Courier New"   ,,108,,.T.,,,,,.f. )

	Private lOPValida  	:= .T.
	Private lApontaZBV 	:= .F.
	Private cNumop     	:= space(13)
	Private cSeqBudd   	:= space(02)
	Private cCodBar    	:= Criavar("B1_CODBAR",.F.)
	Private cProduto   	:= Criavar("B1_COD",.F.)
	Private cTecido	   	:= Criavar("B1_COD",.F.)
	Private cTTecido   	:= Criavar("B1_COD",.F.)	// --- Tecido Thiago
	Private cDescricao 	:= Criavar("B1_DESC",.F.)
	Private cALmox     	:= Criavar("B1_LOCPAD",.F.)
	Private cUMProduto 	:= Criavar("B1_UM",.F.)
	Private nQtdPecas  	:= 0
	Private nMultiplo  	:= 0
	Private nMultItem  	:= 0
	Private nQtdSegunda	:= 0
	Private nQtdOP     	:= 0
	Private nQtdOPSal  	:= 0
	Private nQtdTot    	:= 0
	Private lFirst     	:= .T.
	Private lMultiplo  	:= .T.
	Private lAvulso    	:= .F.
	Private lRetOP     	:= .T.
	Private lFecha     	:= .F.
	Private aPerd      	:= {0,0,0,0,0,0,0,0,0,0}
	Private aPerdRet   	:= {}
	Private nPerdKg    	:= 0
	Private aRecSeg	   	:= {}
	Private aRecPer	   	:= {}
	Private aRecLD 	   	:= {}
	Private cCCusto    	:= ""
	Private cGrupo     	:= ""
	Private lClose     	:= .F.
	Private lLibera    	:= .F. // Alan
	Private cUsuAx, cSenhaAx // Alan
	Private lAltAlmox	:= .F.
	Private nPerdas    	:= 0
	Private cCodSaldo	:= "F0088888001001"
	Private lMsHelpAuto := .F.
	Private lMsErroAuto := .F.
	Private lNovoCons	:= .F. // Thiago 16/12/2010
	Private nQtdRetPc	:= 0	// Thiago 03/12/2014
	Private nQtdRetPr	:= 0	// Thiago 03/12/2014
	Private nQtdLiber	:= 0    // Quantidade de peças informadas acima daquela total da OP, para não consumir tecidos.
	Private lConfImpr	:= .F.

	Private oPecasSeg	// objeto a ser usado para carregar as peças de segunda qualidade apontadas.

	Private cLocSeg	    := AllTrim(SuperGetMv("BUD_LOCSEG")) // Local padrao origem para os produtos de segunda qualidade
	Private cLocSegP6	:= AllTrim(SuperGetMv("BUD_SEGTOA"))
	Private cLocSegP7	:= AllTrim(SuperGetMv("BUD_SEGROU"))
	Private cLockOP := ''
	Private nLockOP := 0
	Private nTimeOut 	:= 120
	Private aHeadOut 	:= {}
	Private cHeadRet 	:= ""
	Private sPostRet	:= ""

	// Variáveis ref. a identificação da gaiola:
	Private _oDlg, oContainer, oGet1, oSayG, oGet2, oGet3, oGet4, oGet5, oGet6, oGet7, oGet8, oGet9, oGet10, oGet11,oGetG, oSayE
	Private cSayE		:= ""
	Private lGaiolaObr	:= .F.
	Private oTmrGExp
	Private nExpGai		:= GetMv("BD_744EGA")
	Private cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])

	// Demais variáveis:
	Private oBtn0, oBtn1, oBtn2, oBtn5, oBtn6, oBtn7

	Default cOPRec 		:= Space(TamSx3('D3_OP')[1])
	Default nQtdRec		:= 0
	Default lAuto 		:= .F.

	Private __AUTO      := lAuto
	Private cFaccao
	Private cDataApont
	Private cMultiplos
	Private cQntMultpl := 0
	Private cQntAvulso
	Private cStatus
	Private cGaiola

	//Tamanho da tela FwDialogModal
	Private n_oDlgWidth  := 500
	Private n_oDlgHeight := 250

	cParamSeg		:= cOPRec
	If !Empty(cParamSeg)
		cNumop	:= cParamSeg
	EndIf

	If GetMV("BD_MODINVE")
		If !__AUTO
			MsgStop("Atenção. O modo inventário está ativado. Não será possível efetuar movimentações nesse momento!")
		Else
			U_BUD1427("Atencao. O modo inventario esta ativado. Nao sera possível efetuar movimentacoes nesse momento!")
		EndIf
		Return .F.
	EndIf

	If !Empty(cParamSeg)
		If (lMsErroAuto := B744AtuDados())
			If (lMsErroAuto := B744ValidOP())
				B744QtdApSeg()
				If !Empty(nQtdRec)
					nQtdPecas	:= nQtdRec
					lAutoFim	:= .T.
				EndIf
				lMsErroAuto := B744Aponta()
				Return (lMsErroAuto)
			Else
				Return (lMsErroAuto)
			EndIf
		Else
			Return (lMsErroAuto)
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divide a tela lateralmente                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObjects := {}
	AAdd( aObjects, { 100,  30, .T., .F., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .F., .F. } )
	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 }  //(Linha Inicial, Coluna Inicial, Linha Final, Coluna Final)
	aPosObj := MsObjSize( aInfo, aObjects, , .F. )

	While !lFecha

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta tela para apontamento da OP                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		_oDlg := FWDialogModal():New()
		_oDlg:SetFreeArea(n_oDlgWidth, n_oDlgHeight)
		_oDlg:SetEscClose(.F.)
		_oDlg:SetCloseButton(.F.)
		_oDlg:SetTitle("Apontamento da OP")
		_oDlg:SetBackground(.T.)
		_oDlg:EnableFormBar(.T.)
		_oDlg:CreateDialog()

		oContainer := _oDlg:GetPanelMain()

		//Numero da OP
		oSay1:= TSay():New(15,10,{|| "Número da OP: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet1:= TGet():New(10,80,bSetGet(cNumOP),oContainer,100,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet1:cF3:="SC2"
		oGet1:bValid:= {|| B744ValidOP() }
		oGet1:bLostFocus:={|| IIf(!Empty(cNumOP),B744AtuDados(),) }

		// Código da gaiola:
		oSayG:= TSay():New(15,203,{|| "Código da gaiola: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGetG:= TGet():New(10,250,bSetGet(cCodGaiola),oContainer,85,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		//oSayE:= TSay():New(27,250,{|| cSayE },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE,100,20)
		oGetG:cF3:="ZDT"
		oGetG:bValid:= {|| B744ValG() }
		oGetG:Disable()

		// Timer ref. a expiração do tempo para forçar a troca de gaiola:
		// If Empty(cParamSeg)
		// 	if nExpGai > 0
		// 		_oDlg:setTimer(1000, {|| ExpiraGa() })
		// 	EndIf
		// EndIf

		//Almoxarifado
		oSay2:= TSay():New(35,10,{|| "Almoxarifado: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet2:= TGet():New(30,80,bSetGet(cAlmox),oContainer,15,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet2:bValid:= {|| B744VldLoc() }
		oGet2:Disable()
		oBtn5:=TButton():New(30,100,"Alterar",oContainer,{|| B744AltAlmox()},40,17,,,,.T.,,"Alt.Almox.",,,,)

		//Codigo de barras
		oSay3:= TSay():New(55,10,{|| "Código de Barras: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet3:= TGet():New(50,80,bSetGet(cCodBar),oContainer,100,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet3:bValid:={|| B744ValidCodBar() }
		oGet3:Disable()

		//Produto
		oSay4:= TSay():New(75,10,{|| "Produto: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet4:= TGet():New(70,80,bSetGet(cProduto),oContainer,100,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet4:Disable()

		//Descricao
		oSay5:= TSay():New(95,10,{|| "Descrição: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet5:= TGet():New(90,80,bSetGet(cDescricao),oContainer,255,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet5:Disable()

		//Quant pecas
		oSay6:= TSay():New(135,10,{|| "Qtd. Peças: " },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE)
		oGet6:= TGet():New(130,80,bSetGet(nQtdPecas),oContainer,10,15,"@E 999,999",,CLR_RED,,oFont25,,,.T.,,,,,,,,,)
		oGet6:Disable()

		//Multiplos
		oSay7:= TSay():New(135,228,{|| "Múltiplo: " },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE)
		oGet7:= TGet():New(130,250,bSetGet(nMultiplo),oContainer,10,15,"@E 999,999",,,,oFont25,,,.T.,,,,,,,,,)
		oGet7:bValid:={|| B744ValidMult() }
		oGet7:Disable()

		//Pecas de segunda
		oSay8:= TSay():New(135,140,{|| "Peças Seg.: " },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE)
		oGet8:= TGet():New(130,170,bSetGet(nPerdas),oContainer,10,15,"@E 999,999",,,,oFont25,,,.T.,,,,,,,,,)
		oGet8:Disable()

		oSay9:= TSay():New(115,10,{|| "Qtd. Total OP: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet9:= TGet():New(110,80,bSetGet(nQtdTot),oContainer,10,15,"@E 999,999",,,,oFont26,,,.T.,,,,,,,,,)
		oGet9:Disable()

		oSay11:= TSay():New(115,140,{|| "Retalho: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet11:= TGet():New(110,170,bSetGet(nQtdRetPc),oContainer,10,15,"@E 999,999",,,,oFont26,,,.T.,,,,,,,,,)
		oGet11:Disable()

		oSay10:= TSay():New(115,228,{|| "Saldo: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet10:= TGet():New(110,250,bSetGet(nQtdOPSal),oContainer,10,15,"@E 999,999",,,,oFont26,,,.T.,,,,,,,,,)
		oGet10:Disable()

		// Criacao de Tabela (msnewgetdados) para trazer todos os lançamentos de produtos de segunda qualidade feitos para a OP
		fPecasSeg(aPosObj)

		/////// Botões ///////
		oBtn6 := TButton():Create()
		oBtn6:cName := "Reimprimir"
		oBtn6:cCaption := "Reimprimir"
		oBtn6:cTooltip := "Reimpressão de Etiquetas Pacote"
		oBtn6:blClicked := {|| Eval(bReimpr)}
		oBtn6:nWidth := 90
		oBtn6:nHeight := 35
		oBtn6:nLeft := oContainer:nWidth - (oBtn6:nWidth * 5) - 120  // Ajuste o valor 150 conforme necessário, para jogar todos os botõe para esquerda
		oBtn6:nTop := oContainer:nHeight - oBtn6:nHeight + 100

		// oBtn5 := TButton():Create()
		// oBtn5:cName := "Impressora"
		// oBtn5:cCaption := "Impressora"
		// oBtn5:cTooltip := "Configuração da Impressora de Etiquetas"
		// oBtn5:blClicked := {|| Eval(bImpr)}
		// oBtn5:nWidth := 90
		// oBtn5:nHeight := 35
		// oBtn5:nLeft := oBtn6:nLeft + oBtn6:nWidth + 15  // Adicione um espaço de 10 pixels entre os botões
		// oBtn5:nTop := oContainer:nHeight - oBtn5:nHeight + 100

		oBtn0 := TButton():Create()
		oBtn0:cName := "Encerra"
		oBtn0:cCaption := "Encerra"
		oBtn0:cTooltip := "Finaliza Ordem de Produção"
		oBtn0:blClicked := {|| Eval(bEncerra)}
		oBtn0:Disable()
		oBtn0:nWidth := 90
		oBtn0:nHeight := 35
		oBtn0:nLeft := oBtn6:nLeft + oBtn6:nWidth + 20  // Adicione um espaço de 10 pixels entre os botões
		oBtn0:nTop := oContainer:nHeight - oBtn0:nHeight + 100

		oBtn1 := TButton():Create()
		oBtn1:cName := "Confirma"
		oBtn1:cCaption := "Confirma"
		oBtn1:cTooltip := "Realiza o Apontamento de Produção"
		oBtn1:blClicked := {|| Eval(bAponta)}
		oBtn1:Disable()
		oBtn1:nWidth := 90
		oBtn1:nHeight := 35
		oBtn1:nLeft := oBtn0:nLeft + oBtn0:nWidth + 20  // Adicione um espaço de 10 pixels entre os botões
		oBtn1:nTop := oContainer:nHeight - oBtn1:nHeight + 100

		oBtn2 := TButton():Create()
		oBtn2:cName := "Cancela"
		oBtn2:cCaption := "Cancela"
		oBtn2:cTooltip := "Cancelamento do Apontamento de Produção"
		oBtn2:blClicked := {|| B744Cancela()}
		oBtn2:Disable()
		oBtn2:nWidth := 90
		oBtn2:nHeight := 35
		oBtn2:nLeft := oBtn1:nLeft + oBtn1:nWidth + 20  // Adicione um espaço de 10 pixels entre os botões
		oBtn2:nTop := oContainer:nHeight - oBtn2:nHeight + 100

		oBtn7 := TButton():Create()
		oBtn7:cName := "Sair"
		oBtn7:cCaption := "Sair"
		oBtn7:cTooltip := "Fechar Rotina de Apontamento"
		oBtn7:blClicked := {|| LimparCampos(.T.)}
		oBtn7:nWidth := 90
		oBtn7:nHeight := 35
		oBtn7:nLeft := oBtn2:nLeft + oBtn2:nWidth + 20  // Adicione um espaço de 10 pixels entre os botões
		oBtn7:nTop := oContainer:nHeight - oBtn7:nHeight + 100

		oBtn3:=TButton():New(130,305,"Avulso",oContainer,{|| B744ValidAvulso()},30,17,,,,.T.,,"Avulso",,,,)

		oBtn4:=TButton():New(110,305,"Atualiza",oContainer,{|| B744QtdApSeg(), CarregaSeg(), oContainer:Refresh(), oGet1:SetFocus() },30,17,,,,.T.,,"Atualiza",,,,)

		_oDlg:Activate()
	EndDo

Return(lMsErroAuto)

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * INÍCIO - Rotinas responsáveis pelo encaixotamento no CD Buddemeyer
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
// Efetua validação da gaiola/carrinho 24/09/2020 - Thiago Lucas Machado
Static Function B744ValG()
	Local lRet := .T.

	// Verifico obrigatoriedade:
	if Empty(cCodGaiola) .Or. !lGaiolaObr
		Return (lRet := .T.)
	EndIf

	// Verifico se o carrinho existe:
	If !Empty(cCodGaiola)
		// Verifico prefixo:
		If Left(cCodGaiola, 2) != "GL"
			B744TocaSom()
			MsgStop("Código ["+AllTrim(cCodGaiola)+"] está no formato errado! Gentileza verificar...")
			Return (lRet := .F.)
		EndIf

		If (Select("T744G") <> 0)
			DbSelectArea("T744G")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 ZDT_STATUS, ZDT_LOCFIS "
		cQuery += "FROM ZDT010 (NOLOCK) "
		cQuery += "WHERE ZDT_FILIAL = '' "
		cQuery += "AND ZDT_CODIGO = '"+StrTran(AllTrim(cCodGaiola), "GL", "")+"' "
		cQuery += "AND ZDT010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "T744G"
		IF !T744G->(Eof())
			// Verifico status da gaiola:
			if (AllTrim(T744G->ZDT_LOCFIS) != "SA")
				B744TocaSom()
				// Aqui preciso chamar uma mensagem de confirmação do supervisor, para permitir liberação da gaiola:
				lRet := .F.
				// Verificar função msgbox para colocar um ícone de erro:
				MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] não encontra-se na S/A! Gentileza verificar....")
			Elseif (AllTrim(T744G->ZDT_STATUS) == "ENDERECADO" .Or. AllTrim(T744G->ZDT_STATUS) == "TRANSITO" .Or. AllTrim(T744G->ZDT_STATUS) == "ORDEM GERADA")
				B744TocaSom()
				MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] está com status ["+AllTrim(T744G->ZDT_STATUS)+"]! Gentileza verificar...")
				lRet := .F.
			Else
				lRet := .T.
			EndIf
		Else
			B744TocaSom()
			MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] não cadastrada, gentileza verificar!")
			lRet := .F.
		EndIf
	EndIf

	// Prossigo para o próximo campo:
	if lRet
		// Reseto tempo de expiração:
		/*
		lGaiolaObr	:= .T.
		nExpGai		:= IIF(lGaiolaObr, GetMv("BD_744EGA"), 0)
		If Empty(cParamSeg)
			if nExpGai > 0
				oTmrGExp:Activate()
			EndIf
		EndIf
		*/

		// Retorno para o campo da OP:
		If Empty(cNumOP)
			oGet1:SetFocus()
			Return (lRet := .T.)
		EndIf
		// Retorno para o campo do código de barras do produto:
		If Empty(cCodBar)
			cCodBar := Space(TamSx3('B1_CODBAR')[1])
			oGet3:SetFocus()
			Return (lRet := .T.)
		EndIf
	EndIf

Return (lRet)

// Verifica se efetua expiração da gaiola 24/09/2020 - Thiago Lucas Machado
Static Function ExpiraGa()

	If !Empty(cParamSeg)
		Return
	EndIf

	// Verifico variáveis:
	If !lGaiolaObr .Or. Empty(cNumOP) .Or. nQtdPecas <= 0
		cSayE	:= ""
		oSayE:Refresh()
		Return
	EndIf

	// Verifico parâmetro:
	If GetMv("BD_744EGA") <= 0
		cSayE	:= ""
		oSayE:Refresh()
		Return
	EndIf

	// Verifico código da gaiola:
	If Empty(cCodGaiola)
		Return
	EndIf

	// Verifico expiração da gaiola:
	If nExpGai > 0
		cSayE		:= "Expira em " + AllTrim(Str(nExpGai)) + "s"
		nExpGai		-= 1
	Else
		nExpGai		:= GetMv("BD_744EGA")
		// Zero código da gaiola:
		cCodGaiola 	:= Space(TamSx3('ZDT_CODIGO')[1])
		cSayE		:= "Informe novamente o código da gaiola..."
		oGetG:SetFocus()
	EndIf

	// Refresh no componente:
	oSayE:Refresh()

Return

//  Efetuo inclusão do item na gaiola 24/09/2020 - Thiago Lucas Machado
Static Function InsGaiola()

	Local cSeqApon		:= '0001'
	Local cCodProdut	:= ''
	Local cCodCli		:= ''
	Local cLojaCli		:= ''
	Local cGrupCLi		:= ''
	Local cLocalCli		:= ''
	Local cPedCli		:= ''
	Private lAtuaPDA    := .T.

	// Busco sequencia do apontamento:
	If (Select("T744I") <> 0)
		DbSelectArea("T744I")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(MAX(ZDU_ITEMGA), '0000') AS SEQAPONT FROM ZDU010 (NOLOCK) WHERE ZDU_FILIAL = '' AND ZDU_CODGA = '"+AllTrim(cCodGaiola)+"' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU010.D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T744I"
	IF !T744I->(Eof())
		cSeqApon	:= Soma1(T744I->SEQAPONT)
	EndIf

	// Busco Código do produto:
	If (Select("T744I") <> 0)
		DbSelectArea("T744I")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery("SELECT DISTINCT TOP 1 B1_COD FROM "+RetSQLName("SB1")+" (NOLOCK) WHERE B1_FILIAL = '"+xFilial("SB1")+"' AND B1_CODBAR = '"+cCodBar+"' AND "+RetSQLName("SB1")+".D_E_L_E_T_ = '' ")
	TCQuery cQuery NEW ALIAS "T744I"
	IF !T744I->(Eof())
		cCodProdut	:= T744I->B1_COD
	EndIf

	// Busco dados do pedido:
	If (Select("T744I") <> 0)
		DbSelectArea("T744I")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 A1_COD, A1_LOJA, A1_GRUPO, C5_LOCAL, C5_NUM "
	cQuery += "FROM SC2010 (NOLOCK) "
	cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = C2_NUMPED AND SC5010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE C2_FILIAL = '01' "
	cQuery += "AND C2_NUM = '"+Left(cNumOP, 6)+"' "
	cQuery += "AND (C2_NUM+C2_ITEM+C2_SEQUEN) = '"+AllTrim(cNumOP)+"' "
	cQuery += "AND SC2010.D_E_L_E_T_ = '' "
	TCQuery cQuery NEW ALIAS "T744I"
	IF !T744I->(Eof())
		cCodCli		:= AllTrim(T744I->A1_COD)
		cLojaCli	:= AllTrim(T744I->A1_LOJA)
		cGrupCLi	:= AllTrim(T744I->A1_GRUPO)
		cLocalCli	:= AllTrim(T744I->C5_LOCAL)
		cPedCli		:= AllTrim(T744I->C5_NUM)
	EndIf

	// Efetuo inclusão na tabela ZDU:
	MsUnlockAll()
	DbSelectArea("ZDU")
	RecLock("ZDU",.T.)
	ZDU->ZDU_CODGA	:= AllTrim(cCodGaiola)
	ZDU->ZDU_NUMOP	:= AllTrim(cNumOP)
	ZDU->ZDU_ITEMGA	:= cSeqApon
	ZDU->ZDU_PRODUT	:= cCodProdut
	ZDU->ZDU_MULTIP	:= nMultiplo
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
	MsUnLock("ZDU")
	MsUnlockAll()

	// Atualizo status da gaiola:
	TCSQLEXEC("UPDATE ZDT010 SET ZDT_STATUS = 'UTILIZADO', ZDT_LOCFIS = 'SA', ZDT_OBS = 'UTILIZADO POR ["+AllTrim(Upper(cUserName))+"] DIA ["+DtoC(dDataBase)+"] PARA OP ["+AllTrim(cNumOP)+"]' WHERE ZDT_FILIAL = '' AND ZDT_CODIGO = '"+StrTran(cCodGaiola, "GL", "")+"' AND ZDT010.D_E_L_E_T_ = '' ")

	cCodGai := StrTran(cCodGaiola, "GL", "")
	U_BUD1516(.T.,cCodGai,"A","UTILIZADO","SA")

	// Verifico se efetua o agrupamento de múltiplos dos avulsos:
	If nMultiplo == 1 .And. nMultItem > 1
		If GetMv("BD_744AMUL")
			AgrupaMult(cCodProdut, cCodCli, cLojaCli, cLocalCli, cGrupCLi, cPedCli)
		EndIf
	EndIf
Return

// Efetuo agrupamento de múltiplo dos avulsos 02/10/2020 - Thiago Lucas Machado
Static Function AgrupaMult(cCodProdut, cCodCli, cLojaCli, cLocalCli, cGrupCLi, cPedCli)
	Local cQryCon	:= ""
	Local nRecAju	:= 0
	Local nMultAju	:= 0

	// Alimento condições padrão de consulta:
	cQryCon += "FROM ZDU010 (NOLOCK) "
	cQryCon += "WHERE ZDU_FILIAL = '' "
	cQryCon += "AND ZDU_STATUS IN ('EM ANDAMENTO', 'APONTAMENTO FINALIZADO') "
	cQryCon += "AND ZDU_LOCFIS = 'SA' "
	cQryCon += "AND ZDU_PRODUT = '"+cCodProdut+"' "
	cQryCon += "AND ZDU_CODGA = '"+AllTrim(cCodGaiola)+"' "
	cQryCon += "AND ZDU_MULTIP = '1' "
	cQryCon += "AND ZDU_CLI = '"+cCodCli+"' "
	cQryCon += "AND ZDU_LOJA = '"+cLojaCli+"' "
	cQryCon += "AND ZDU_LOCAL = '"+cLocalCli+"' "
	cQryCon += "AND ZDU_CLIGRU = '"+cGrupCLi+"' "
	cQryCon += "AND ZDU_PEDIDO = '"+cPedCli+"' "
	cQryCon += "AND ZDU_ESTAC = '"+Upper(AllTrim(ComputerName()))+"' "
	cQryCon += "AND ZDU010.D_E_L_E_T_ = '' "

	// Inicialmente, verifico se existem quantidades suficientes para realizar um agrupamento de apontamento:
	If (Select("T744I") <> 0)
		DbSelectArea("T744I")
		DbCloseArea()
	Endif
	cQuery := "SELECT ISNULL(SUM(ZDU_MULTIP), 0) AS QTD_BAIXO "
	cQuery += cQryCon
	TCQuery cQuery NEW ALIAS "T744I"
	// Verifico quantos registros existem abaixo do múltiplo do item do item:
	If !T744I->(Eof())
		// Caso não exista, eu saio da rotina:
		If T744I->QTD_BAIXO < nMultItem
			Return
		EndIf
	Else
		Return
	EndIf

	// Verifico registros para efetuar agrupamento:
	If (Select("T744I") <> 0)
		DbSelectArea("T744I")
		DbCloseArea()
	Endif
	cQuery := "SELECT ZDU010.R_E_C_N_O_ AS RECNO_ZDU, ZDU_MULTIP "
	cQuery += cQryCon
	cQuery += "ORDER BY RECNO_ZDU DESC"
	TCQuery cQuery NEW ALIAS "T744I"
	// Verifico quantos registros existem abaixo do múltiplo do item do item:
	While !T744I->(Eof())
		nMultAju++
		If nMultAju <= nMultItem
			// Verifico qual registro deverá ser corrigido o múltiplo:
			If nRecAju <= 0
				nRecAju	:= T744I->RECNO_ZDU
				// O primeiro recno eu efetuo o ajuste para a quantidade do múltiplo:
				TCSQLEXEC("UPDATE ZDU010 SET ZDU_MULTIP = '"+AllTrim(Str(nMultItem))+"' WHERE ZDU010.R_E_C_N_O_ = '"+AllTrim(Str(nRecAju))+"' ")
			Else
				// Os demais recnos, eu deleto do sistema e indico qual o recno que ele efetuou o agrupamento:
				TCSQLEXEC("UPDATE ZDU010 SET ZDU_LOCFIS = 'A_"+AllTrim(Str(nRecAju))+"', ZDU_STATUS = 'MULTIPLO AGRUPADO', D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZDU010.R_E_C_N_O_ = '"+AllTrim(Str(T744I->RECNO_ZDU))+"' ")
			EndIf
		Else
			Exit
		EndIf
		T744I->(dbSkip())
	EndDo

Return
/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * FIM - Rotinas responsáveis pelo encaixotamento no CD Buddemeyer
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// ## Função destinada para permitir o usuário a reimprimir algum apontamento:
Static Function Reimprimir()
	Local oFile := FWFileReader():New("C:\Imprime_Apontamento.txt")
	Local cPrinterName := ""
	local nlinha:= 1

	If Pergunte("BUD1315", .T.)

		If oFile:Open()
			Do While oFile:Hasline()
				cPrinterName := oFile:GetLine()
				nlinha++
			End Do

			oFile:Close()
		Else
			MsgStop("Não foi possível localizar a impressora na sua estação de trabalho para reimpressão. Gentileza entrar em contato com o líder!")
		EndIf

		If !Empty(cPrinterName)

			// Chamo tela para configurar impressora:
			//ConfigImpr()

			// Busco apontamentos conforme parâmetro:
			If (Select("TT1315") <> 0)
				DbSelectArea("TT1315")
				DbCloseArea()
			Endif
			cQuery := ""
			cQuery += "SELECT DISTINCT TOP 50 ZBV_OP, ZBV_DATA, ZBV_HORA, ZBV_OPERAD, ZBV_QTD, ZBV_CODGA, ZBV010.R_E_C_N_O_ AS CODETQ, ZBV_ALMOX  "
			cQuery += "FROM "+RetSqlName("ZBV")+" (NOLOCK) "
			cQuery += "WHERE ZBV_FILIAL = '"+xFilial("ZBV")+"' "
			cQuery += "AND ZBV_OP = '"+AllTrim(MV_PAR01)+"' "
			cQuery += "AND ZBV_DATA = '"+DtoS(MV_PAR02)+"' "

			//cQuery += "AND ZBV_DATA+ZBV_HORA >= '"+DtoS(dDataBase)+"' "

			cQuery += "AND "+RetSqlName("ZBV")+".D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1315"
			If !TT1315->(Eof())
				While !TT1315->(Eof())
					// Chamo rotina para efetuar a reimpressão:
					U_B1315Imp(TT1315->ZBV_OP, TT1315->ZBV_DATA, TT1315->ZBV_HORA, TT1315->ZBV_OPERAD, TT1315->ZBV_QTD, TT1315->CODETQ, TT1315->ZBV_CODGA, .F., cPrinterName,TT1315->ZBV_ALMOX)

					TT1315->(DbSkip())
				EndDo
			Else
				MsgStop("Atenção! Não será possível efetuar a reimpressão dessa OP, pois o código é inválido ou já ultrapassou o horário permitido para efetuar a reimpressão...")
			EndIf

		Else
			MsgStop("Atenção! Essa estação não está configurada para realizar impressão. Gentileza entrar em contato com o líder!")
		EndIf
	EndIf

Return

// ## Função destinada apenas para chamar a tela de configuração da impressora por usuário:
//Static Function ConfigImpr()

// //Local oPrn 		:= TMSPrinter():New()
// //Local oPrn := FwMSPrinter():New()
// oPrn := FwMsPrinter():New('NOME RELATORIO', IMP_SPOOL, .T.,,.T.,,,'\\kepler\IMP_TI_016')

// IF File("C:\Imprime_Apontamento.txt")
// 	oPrn:SetPortrait()
// 	oPrn:SetPaperSize(DMPAPER_A4)
// 	oPrn:Print('Texto que será impresso')
// 	oPrn:EndPage()
// Else
// 	MsgStop("Atenção! Essa estação não está configurada para realizar impressão. Gentileza entrar em contato com o líder!")
// EndIf

//Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744VALIDOPº Autor ³Edinei Sanchez Milekº Data ³ 28/10/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida OP                                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744ValidOP()

	Local lRet := .T.
	Local cAlias
	Local lApontSeg := .F.

	Local nFocus  := GetFocus()
	//Local lOPValida  := .T.

	If !Empty(cParamSeg)
		Return (.T.)
	EndIf

	// Não valido OP em branco:
	If Empty(cNumOP)
		Return (.T.)
	EndIf

	nCancela:= oBtn2:hwnd

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+cNumOP))
	If SC2->(Found())
		If !Empty(SC2->C2_DATRF)
			If	Empty(cParamSeg)
				B744TocaSom()
				MsgStop("Ordem de Produção já encerrada!!")
			endIf
			lOPValida := .F.
			Return (lRet := .F.)
		ElseIf	SC2->C2_SITAOP == '3' .and. (RTrim(cCCusto) == "71150" .or. RTrim(cCCusto) == "71160" .or. RTrim(cCCusto) == "71190" .Or. Empty(cCCusto))
			If	Empty(cParamSeg)
				B744TocaSom()
				MsgStop(OemToAnsi("Não é possível fazer Apontamento de OP em produção na FACÇÃO !!! "+Chr(13)+;
					"Verifique se já foi efetuado inclusão da NF de Retorno deste item !!!"))
			EndIf
			lOPValida := .F.
			Return (lRet := .F.)
		ElseIf SC2->C2_SITAOP == "0" .and. (RTrim(cCCusto) == "71150" .Or. Empty(cCCusto))
			If	Empty(cParamSeg)
				B744TocaSom()
				MsgStop("Essa OP precisa primeiro ser liberada pelo corte!")
			EndIf
			lOPValida := .F.
			Return (lRet := .F.)
		Else
			lOPValida := .T.
			If	Type("oBtn0") == "O"
				oBtn0:Enable()
			EndIf
			oBtn1:Enable()
			oBtn2:Enable()
		Endif
	Else
		If !Empty(cParamSeg)
			Return(lRet := .F.)
		EndIf

		If	Empty(cNumOP) .And. (nCancela == nFocus)
			Return(lRet := .T.)
		EndIf

		B744TocaSom()
		MsgStop("Ordem de Produção não encontrada!!")
		lOPValida := .F.
		Return (lRet := .F.)
	Endif

	// Solicitação da Madalena (28/10/2014) enviar mensagem conforme referências e locais repassado:
	If SC2->C2_LOCAL == 'PB'
		If	Empty(cParamSeg)
			B744TocaSom()
			MSGSTOP("ATENÇÃO! PRODUTO FRAPE BORDADO. NÃO DESCER PARA EXPEDIÇÃO.")
		EndIf
	ElseIf AllTrim(SC2->C2_LOCAL) == '06'
		/*If RTrim(cCCusto) == "71150"
		If ("14310" $ SC2->C2_PRODUTO .Or. "14309" $ SC2->C2_PRODUTO .Or. "13330" $ SC2->C2_PRODUTO .Or. "14307" $ SC2->C2_PRODUTO)
		B744TocaSom()
		MsgStop("Atenção! A orientação é não descer esse tipo de produto para a Expedição. Gentileza verificar!")
		EndIf
		EndIf*/
	EndIf

	// Incluir lógica para tratar as OP's dependentes da OP a ser apontada, todas devem estar com o campo C2_SITAOP = '5'
	// nos casos de apontamento de OP's recebidas de facção para evitar que seja feito consumo de estoque do material incorreto
	// para os produtos da linha de Kit de Matelasse que são enviados o matelasse apontado o kit e consumido e apontado as peças
	// do segundo nível da estrutura ou seja OP's que iniciam pela sequencia 002
	If	Select('TFAC')<> 0
		dbSelectArea('TFAC')
		dbCloseArea()
	EndIf

	cOP:= substr(cNumOP,1,6)
	BeginSql Alias 'TFAC'
		Column C2_DATRF as Date
		Column C2_QUANT as Numeric(14, 2)
		Column C2_QUJE as Numeric(14, 2)
		SELECT
			C2_NUM + C2_ITEM + C2_SEQUEN AS C2_NUMOP,
			C2_SEQUEN,
			C2_PRODUTO,
			C2_DATRF,
			C2_QUANT,
			C2_QUJE,
			C2_SITAOP
		FROM
			%Table:SC2% SC2 (NOLOCK)
		WHERE
			SC2.%NotDel%
			AND C2_FILIAL = %xFilial:SC2%
			AND C2_NUM = %Exp:cOP%
			AND C2_DATRF = ' '
	EndSql

	lSitFac := .F.
	cOPFac  := ''
	While !TFAC->(Eof())

		If	TFAC->C2_SEQUEN != '001' .And. TFAC->C2_SITAOP = '3'
			lSitFac := .T.
			If	!Empty(cOPFac)
				cOPFac += ' / '
			EndIf
			cOPFac += TFAC->C2_NUMOP
		EndIf

		TFAC->(DbSkip())

	EndDo

	If	lSitFac
		If	Empty(cParamSeg)
			B744TocaSom()
			MsgStop(OemToAnsi("Existem OP's dependentes desta que estão com Status bloqueando o Apontamento !!! "+Chr(13)+;
				"Verifique se já foi efetuado inclusão da NF de Retorno das mesmas "+cOPFac+" !!!"))
		EndIf
		lOPValida := .F.
		Return (lRet := .F.)
	EndIf

	// Valida a existencia de apontamento de segunda qtualidade - retalho / resíduo ou peças para qualquer uma das OP's
	// vinculadas aos dados da peça revisada onde pode ser feito a liberação de mais de uma OP

	cAlias := GetNextAlias()

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

	BeginSql Alias cAlias
		SELECT
			ZAB_OP
		FROM
			%Table:ZA9% ZA9 (NOLOCK)
		INNER JOIN %Table:ZAB% ZAB (NOLOCK)
		ON ZAB.%NotDel%
			AND ZAB_FILIAL = %xFilial:ZAB%
			AND ZAB_OP = ZA9_NUMOP
		WHERE
			ZA9.%NotDel%
			AND ZA9_FILIAL = %xFilial:ZA9%
			AND ZA9_CHAVE = (
				SELECT
					DISTINCT TOP 1 ZA91.ZA9_CHAVE
				FROM
					%Table:ZA9% ZA91
				WHERE
					ZA91.%NotDel%
					AND ZA91.ZA9_FILIAL = %xFilial:ZA9%
					AND ZA91.ZA9_NUMOP = %Exp:cNumOP%
			)
			AND ZA9.ZA9_CHAVE <> ' '
		GROUP BY
			ZAB_OP
	EndSql

	While !(cAlias)->(Eof())
		lApontSeg := .T.
		(cAlias)->(dbSkip())
	End

	// No caso de peça da costura, é necessário validar se existe lançamento de resíduo [399]:
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif
	BeginSql Alias cAlias
		SELECT
			DISTINCT TOP 1 C2_NUM,
			ZAB_OP
		FROM
			%Table:SC2% (NOLOCK)
		LEFT JOIN %Table:ZAB% (NOLOCK)
		ON ZAB_FILIAL = %xFilial:ZAB%
			AND ZAB_OP = (C2_NUM + C2_ITEM + C2_SEQUEN)
			AND ZAB_CODDEF = '399'
			AND ZAB010.%NotDel%
		WHERE
			C2_FILIAL = %xFilial:SC2%
			AND C2_NUM = %Exp:Substr(cNumOP,1,6)%
			AND C2_NUM + C2_ITEM + C2_SEQUEN = %Exp:cNumOP%
			AND C2_CC = '71150'
			AND ZAB_OP IS NULL
			AND SC2010.%NotDel%
	EndSql
	If !(cAlias)->(Eof())
		B744TocaSom()
		MsgStop("Não existe apontamento de resíduo da costura [399] para essa OP!!!")
		lOpValida := .F.
		Return (lRet := .F.)
	End If

	If !lApontSeg .and. rtrim(cCCusto) == "71150"
		If	Empty(cParamSeg)
			B744TocaSom()
			MsgStop("Não existe apontamento de segunda ou resíduos para essa OP!!")
		EndIf
		lOpValida := .F.
		Return (lRet := .F.)
	Endif

	If 	lOPValida .And. Empty(cParamSeg)
		oGet1:Disable()
	Endif

	If lRet
		B744QtdApSeg()
		nQtdOP := SC2->C2_QUANT - SC2->C2_QUJE
		nQtdTot:= (SC2->C2_QUANT)
		nQtdOPSal := (nQtdOp - nQtdRetPc - aPerd[NQTDSEG] - aPerd[NQTDLD] - aPerd[NPERDAPC])
		If nQtdOPSal < 0
			nQtdOPSal	:= 0
		EndIf
	Endif

	If	Empty(cParamSeg)
		CarregaSeg()
		oGet3:SetFocus()
	EndIf

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

	cCode := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
	If	Empty(cLockOP) .Or. (cLockOP != cCode)
		cLockOP := cCode
		nLockOP := 0
	EndIf

	nCount:= 0
	nLockOP++
	lLockOP := .T.

	If	nLockOP < 5

		While .T.
			If	MayIUseCode(cCode)
				cLockOP := cCode
				nLockOP := 0
				U_BUD1427('Criado controle de Apontamento de O.P. (BUD744) '+cCode+' para o usuário '+AllTrim(Substr(cUsuario,7,15))+' em '+Dtoc(MsDate())+' '+Substr(Time(),1,5)+' !!!')
				Exit
			Else
				MsAguarde({|| Sleep(1000) }, 'Reservar O.P. para Apontamento.', 'Aguarde tentativa Reservar O.P. em '+ALLTRIM(StrZero(nCount,2)+' segundos ...'))
				U_BUD1427('Tentativa de Reservar a O.P. '+cCode+' ... '+ALLTRIM(StrZero(nCount,2))+' segundos.')
			EndIf

			nCount++
			If	nCount > 30
				lRet    := .F.
				lLockOP := .F.
				Exit
			EndIf
		EndDo
	Else
		nLockOP := 0
		cLockOP := ''
		lLockOP := .T.
		Leave1Code(cCode)
		MayIUseCode(cCode)
		U_BUD1427('Criado controle de Apontamento de O.P. (BUD744) '+cCode+' para o usuário '+AllTrim(Substr(cUsuario,7,15))+' em '+Dtoc(MsDate())+' '+Substr(Time(),1,5)+' !!!')
	EndIf

	If	!lLockOP
		If	Empty(cParamSeg)
			oGet1:Enable()
			oGet1:SetFocus()
			Alert('Não foi possível Reservar a O.P. '+cCode+' para efetuar o apontamento de produção, pois já está em uso por outro usuário !!!')
		EndIf
		U_BUD1427('Não foi possível Reservar a O.P. '+cCode+' para efetuar o apontamento de produção, pois já está em uso por outro usuário !!!')
	EndIf

	// Parâmetros de obrigatoriedade de informar a gaiola:
	lGaiolaObr	:= .F.
	oGetG:Disable()
	oGetG:Refresh()

	// Verifico itens pendentes de apontamento:
	If Empty(cParamSeg) .And. lRet
		If !Empty(cNumOP)
			// Reseto tempo de expiração:
			nExpGai	:= IIF(lGaiolaObr, GetMv("BD_744EGA"), 0)

			If (Select("T744A") <> 0)
				DbSelectArea("T744A")
				DbCloseArea()
			Endif
			cQuery := ChangeQuery("SELECT DISTINCT TOP 1 ISNULL(SUM(ZDU_MULTIP), 0) AS QTDAPON, ZDU_USGERA FROM ZDU010 (NOLOCK) WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' GROUP BY ZDU_USGERA ")
			TCQuery cQuery NEW ALIAS "T744A"
			IF !T744A->(Eof())
				IF T744A->QTDAPON > 0
					If MsgYesNo("O sistema identificou ["+AllTrim(Str(T744A->QTDAPON))+"] peças lidas anteriormente pelo operador ["+AllTrim(T744A->ZDU_USGERA)+"], porém não apontadas ainda para essa OP. Deseja continuar o apontamento anterior?")
						// Colocar a quantidade apontada:
						nQtdPecas	+= T744A->QTDAPON
						nQtdOPSal	-= T744A->QTDAPON
					Else
						// Se o usuário deseja iniciar do zero, elimino todos os registros efetuados anteriormente daquela OP:
						nQtdPecas	:= 0
						//TCSQLEXEC("UPDATE ZDU010 SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' ")
						If (Select("T744B") <> 0)
							DbSelectArea("T744B")
							DbCloseArea()
						Endif
						BeginSql Alias "T744B"
							SELECT
								ZDU.R_E_C_N_O_ AS ZDU_RECNO
							FROM
								%Table:ZDU% ZDU
							WHERE
								ZDU_FILIAL = %xFilial:ZDU%
								AND ZDU_NUMOP = %EXP:cNumOP%
								AND ZDU_STATUS = 'EM ANDAMENTO'
								AND ZDU.%NotDel%
						EndSQL
						lLimpaZDU := .F.
						While !T744B->(Eof())
							lLimpaZDU := .T.
							ZDU->(DbGoto(T744B->ZDU_RECNO))
							Reclock("ZDU", .F.)
							DbDelete()
							MSUnlock()
							T744B->(dbSkip())
						EndDo
						If lLimpaZDU
							Alert("Excluido as peças da gaiola!")
						EndIf
					EndIf
				End If
			EndIf

			// Verifico se o parâmetro está habilitado:
			If (Select("T744A") <> 0)
				DbSelectArea("T744A")
				DbCloseArea()
			Endif
			cQuery := ChangeQuery("SELECT TOP 1 ZFC_PARAME FROM ZFC010 (NOLOCK) WHERE ZFC_FILIAL = '' AND ZFC_TIPO = 'ATIVADO' AND ZFC_PARAME = 'SIM' AND ZFC010.D_E_L_E_T_ = '' ")
			TCQuery cQuery NEW ALIAS "T744A"
			IF !T744A->(Eof())
				// Verifico cliente e tipo do produto:
				If (Select("T744A") <> 0)
					DbSelectArea("T744A")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 C5_CLIENTE, C2_PRODUTO REF_PROD FROM SC2010 (NOLOCK) "
				cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = C2_NUMPED AND SC5010.D_E_L_E_T_ = '' "
				cQuery += "INNER JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
				cQuery += "INNER JOIN SC6010 (NOLOCK) ON C6_FILIAL = '01' AND C6_NUM = C2_NUMPED AND C6_ITEM = C2_ITEMPED AND SC6010.D_E_L_E_T_ = '' "
				cQuery += "WHERE C2_FILIAL = '01' "
				cQuery += "AND C2_NUM = '"+Left(cNumOP, 6)+"' "
				cQuery += "AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+cNumOP+"' "
				// Necessário ter Codigo de encaixotamento no cadastro de cliente, quando for exportação não é necessário:
				cQuery += "AND ( "
				cQuery += "CASE "
				cQuery += "WHEN LEFT(A1_COD, 2) <> 'EX' THEN "
				cQuery += "CASE "
				cQuery += "WHEN A1_CODENCX <> '' THEN 1 "
				cQuery += "ELSE 0 "
				cQuery += "END "
				cQuery += "ELSE 1 "
				cQuery += "END "
				cQuery += ") = 1 "
				// Necessário o produto ser vendido como peça:
				cQuery += "AND C6_UM = 'PC' "
				cQuery += "AND SC2010.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "T744A"
				IF !T744A->(Eof())
					//06051982-> Verificação se cliente e produto estão liberados para uso da gaiola
					_cAlias := GetNextAlias()
					BeginSQL alias _cAlias
						SELECT
							TOP 1 PRO.PRC_REF
						FROM
							TB_PROCLICD PRO (NOLOCK)
						WHERE
							PRO.PRC_REF = %exp:AllTrim(T744A->REF_PROD)%
							AND PRO.PRC_CLIENTE = %exp:AllTrim(T744A->C5_CLIENTE)%
							AND PRO.PRC_ATIVO = 'S'
							AND PRO.D_E_L_E_T_ = ''
					EndSQL
					MemoWrite("BUD744.SQL",GetLastQuery()[2])
					If (_cAlias)->(!Eof())
						lGaiolaObr	:= .T.
						oGetG:Enable()
						oGetG:SetFocus()
					EndIf
					If SELECT(_cAlias) > 0
						(_cAlias)->(dbCloseArea())
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	fValidFaccao()
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744AtuDadosº Autor ³Edinei Sanchez Milekº Data ³ 28/10/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza dados                                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744AtuDados()

	Local lRet := .T.

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+cNumOP))
	If	SC2->(Found())

		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))

		cAlmox     := SC2->C2_LOCAL
		cProduto   := SB1->B1_COD
		cDescricao := SB1->B1_DESC
		cUMProduto := SB1->B1_UM
		cGrupo     := AllTrim(SB1->B1_GRUPO)
		cCCusto    := SC2->C2_CC
		If	RTrim(cCCusto) == '71150'
			cLocSeg := cLocSegP6
		Else
			cLocSeg := cLocSegP7
		EndIf
		If	Empty(cParamSeg)
			oGet3:Enable() //Habilito campo codigo de barras
			oGet7:Enable() //Habilito campo múltiplos
		EndIf
	Else
		Alert('Não existe a OP informada, Verifique !!!')
		If	Empty(cParamSeg)
			oGet1:SetFocus()
		EndIf
		lRet := .F.
	EndIf

Return lRet

/*/
*****************************************************************************
| Função: fValidFaccao 								Data: 15/04/21			|
|****************************************************************************
|Responsável: Milena Leite de Oliveira - COMPASSIO							|
|****************************************************************************
|Descricao:   Valida Se OP vem de Facção                                  	|
|****************************************************************************
| Parâmetro:                               								 	|
*****************************************************************************
/*/

Static Function fValidFaccao()

	Local lRet     	 := .T.
	Local aObjects 	 := {}
	Local aInfo	   	 := {}
	Local aSize    	 := MsAdvSize(.F., .F.) // Size da Dialog
	Local aPosObj  	 := {}
	Local cAlias   	 := GetNextAlias()
	Local nTotal   	 := 0
	Local cQntAvulso := 0
	Local cQntMultpl := 0
	Local cOP        := ''

	AAdd( aObjects, { 100,  30, .T., .F., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T., .T. } )
	AAdd( aObjects, { 100,  20, .T., .F., .F. } )
	aInfo   := { aSize[1], aSize[2], aSize[3], aSize[4], 2, 2 }  //(Linha Inicial, Coluna Inicial, Linha Final, Coluna Final)
	aPosObj := MsObjSize( aInfo, aObjects, , .F. )
	lHabiFac := .F.

	dbSelectArea("ZE8")
	BeginSql Alias cAlias
		SELECT
			ZE8_NUMOP,
			ZE8_USUARI,
			ZE8_DATA,
			ZE8_MULTIP,
			ZE8_QTDTOT,
			ZE8_STOP,
			ZE8_CODGAI
		FROM
			%Table:ZE8% (NOLOCK) ZE8
		WHERE
			ZE8.ZE8_NUMOP = %exp:cNumOP%
			AND ZE8.%NotDel%
	EndSQL

	While (!EoF())

		cOP        := (cAlias)->ZE8_NUMOP
		cFaccao    := (cAlias)->ZE8_USUARI
		cDataApont := (cAlias)->ZE8_DATA
		cMultiplos := (cAlias)->ZE8_MULTIP
		If (cAlias)->ZE8_MULTIP != 1
			cQntMultpl += (cAlias)->ZE8_QTDTOT
		Else
			cQntAvulso += (cAlias)->ZE8_QTDTOT
		EndIf
		cStatus    := (cAlias)->ZE8_STOP
		cGaiola    := (cAlias)->ZE8_CODGAI
		(cAlias)->(dbSkip())
	EndDo

	nTotal := cQntMultpl + cQntAvulso

	If !Empty( cOP )

		//*******************************************************************
		// Monta tela com informações do apontamento da facção, se hover    |
		//*******************************************************************

		//oGroup2:=TGroup():New(aPosObj[1,1]+10,aPosObj[2,2],aPosObj[3,3]-20,aPosObj[3,4],"", oContainer,,,.T.,.T.)

		oSay12:= TSay():New(10, 360,{|| "Facção: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet12:= TGet():New(20, 360, bSetGet(cFaccao), oContainer, 100, 15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet12:Disable()

		oSay13:= TSay():New(40,360,{|| "Código do carrinho: "},oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet13:= TGet():New(50,360,bSetGet(cGaiola),oContainer,100,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet13:Disable()

		oSay15:= TSay():New(70,360,{|| "Status: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet15:= TGet():New(80,360,bSetGet(cStatus),oContainer,100,15,"@!",,,,oFont24,,,.T.,,,,,,,,,)
		oGet15:Disable()

		oSay16:= TSay():New(100,360,{|| "Qtd. x:" + Str(cMultiplos, 1) },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE)
		oGet17:= TGet():New(110,360,bSetGet(cQntMultpl),oContainer,25,15,,,,,,,,.T.,,,,,,,,,)
		oGet17:Disable()

		oSay18:= TSay():New(100,390,{|| "Avulso: " },oContainer,,,,,,.T.,CLR_RED,CLR_WHITE)
		oGet19:= TGet():New(110,390,bSetGet(cQntAvulso),oContainer,25,15,,,,,,,,.T.,,,,,,,,,)
		oGet19:Disable()

		oSay21:= TSay():New(130,360,{|| "Qtd. Total: " },oContainer,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oGet21:= TGet():New(140,360,bSetGet(nTotal),oContainer,25,15,,,,,,,,.T.,,,,,,,,,)
		oGet21:Disable()

	EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744ValidCodBarº   ³Edinei Sanchez Milekº Data ³ 28/10/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida Codigo de Barras                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744ValidCodBar()

	Local lRet 			:= .T.
	Local lZB1			:= .F.
	Local lVldGaiola	:= .T.
	Local lFimAponta    := .F.

	// Reseto tempo de expiração:
	nExpGai	:= IIF(lGaiolaObr, GetMv("BD_744EGA"), 0)

	SC2->(dbSetOrder(1))
	SC2->(dbSeek(xFilial("SC2")+cNumOP))

	SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial("SB1")+SC2->C2_PRODUTO))

	If (Alltrim(cCodBar) != Alltrim(SB1->B1_CODBAR)) .and. !Empty(AllTrim(cCodBar))
		// Verifico código de barras auxiliar:
		If (Select("TT744A7") <> 0)
			dbSelectArea("TT744A7")
			dbCloseArea()
		EndIf

		BeginSql Alias "TT744A7"
			SELECT
				DISTINCT TOP 1 B1_CODBAR,
				A7_BARRA
			FROM
				%Table:SB1% (NOLOCK) SB1
			INNER JOIN %Table:SC2% (NOLOCK) SC2
			ON SC2.%NotDel%
				AND C2_FILIAL = %xFilial:SC2%
				AND C2_NUM = %exp:Left(cNumOP,6)%
				AND C2_PRODUTO = B1_COD
			INNER JOIN %Table:SC5% (NOLOCK) SC5
			ON SC5.%NotDel%
				AND C5_FILIAL = %xFilial:SC5%
				AND C5_NUM = C2_NUMPED
			INNER JOIN %Table:SA7% (NOLOCK) SA7
			ON SA7.%NotDel%
				AND A7_FILIAL = %xFilial:SA7%
				AND A7_CLIENTE = C5_CLIENTE
				AND A7_LOJA = C5_LOJACLI
				AND A7_PRODUTO = C2_PRODUTO
			WHERE
				SB1.%NotDel%
				AND B1_FILIAL = %xFilial:SB1%
				AND A7_CLIENTE = 'EX0380'
				AND B1_CODBAR <> ' '
				AND A7_BARRA <> ' '
				AND (C2_NUM + C2_ITEM + C2_SEQUEN) = %exp:cNumOP%
		EndSql


		If !Empty(TT744A7->A7_BARRA)
			cCodBar	:= AllTrim(TT744A7->A7_BARRA)
		EndIf


		If (Select("TT744C") <> 0)
			dbSelectArea("TT744C")
			dbCloseArea()
		EndIf

		BeginSql Alias "TT744C"
			SELECT
				DISTINCT TOP 1 B1_CODBAR
			FROM
				%Table:SB1% (NOLOCK) SB1
			INNER JOIN %Table:SC2% (NOLOCK) SC2
			ON SC2.%NotDel%
				AND C2_FILIAL = %xFilial:SC2%
				AND C2_NUM = %exp:Left(cNumOP,6)%
				AND C2_PRODUTO = B1_COD
			INNER JOIN %Table:SC5% (NOLOCK) SC5
			ON SC5.%NotDel%
				AND C5_FILIAL = %xFilial:SC5%
				AND C5_NUM = C2_NUMPED
			INNER JOIN %Table:SA7% (NOLOCK) SA7
			ON SA7.%NotDel%
				AND A7_FILIAL = %xFilial:SA7%
				AND A7_CLIENTE = C5_CLIENTE
				AND A7_LOJA = C5_LOJACLI
				AND A7_PRODUTO = C2_PRODUTO
			WHERE
				SB1.%NotDel%
				AND B1_FILIAL = %xFilial:SB1%
				AND (
					RTRIM(B1_CODBAR) = %exp:Alltrim(cCodBar)%
					OR RTRIM(A7_BARRA) = %exp:Alltrim(cCodBar)%
					OR RTRIM(A7_BARRA) = %exp:Alltrim(left(cCodBar,8))%
					OR RTRIM(A7_CODCLI) = %exp:Alltrim(cCodBar)%
					OR RTRIM(A7_CODCLI) = %exp:Alltrim(left(cCodBar,8))%
					OR (
						%exp:Alltrim(cCodBar)% LIKE A7_BARRA
						AND A7_BARRA LIKE '%%%'
						AND A7_BARRA <> ' '
					)
				)
				AND B1_CODBAR <> ' '
				AND A7_BARRA <> ' '
				AND (C2_NUM + C2_ITEM + C2_SEQUEN) = %exp:cNumOP%
		EndSql

		If !Empty(TT744C->B1_CODBAR)
			cCodBar	:= AllTrim(TT744C->B1_CODBAR)
		EndIf
		If Alltrim(cCodBar) != Alltrim(SB1->B1_CODBAR) .and. !Empty(cCodBar)
			If	Empty(cParamSeg)
				B744TocaSom()

				// Aqui verifico se esse código de barras pertence a outro produto (24/04/2017 - Thiago):
				If (Select("TT744E") <> 0)
					dbSelectArea("TT744E")
					dbCloseArea()
				EndIf
				BeginSql Alias "TT744E"
					SELECT
						DISTINCT TOP 1 B1_DESC,
						B1_CODBAR,
						B1_COD
					FROM
						%Table:SB1% (NOLOCK) SB1
					WHERE
						SB1.%NotDel%
						AND B1_FILIAL = %xFilial:SB1%
						AND RTRIM(B1_CODBAR) = %exp:Alltrim(cCodBar)%
						AND B1_CODBAR <> ' '
				EndSql
				If !TT744E->(Eof())
					// Se caso exista um produto com aquele código de barras, quer dizer que o usuário passou outro produto que não deveria
					// 		por isso, é necessário digitar o login e senha novamente:
					MsgStop("Esse código de barras pertence ao produto "+AllTrim(TT744E->B1_DESC)+"! Para continuar, é necessário digitar o login e senha novamente...")

					/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
					* Chama tela de login e senha para gravar usuário que bipou produto errado:                                               *
					* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
					cUsuAx		:= Space(24)
					cSenhaAx	:= Space(20)
					While .T.
						_oDlgLib := TDialog():New(0,0,200,250,"Produto divergente!",,,,,,,,,.T.,,,,,)
						_oDlgLib:lCentered := .T.
						_oDlgLib:lEscClose := .F.  	//nao fecha tela com esc
						_oDlgLib:nStyle:=128      	//sem x no canto superior direito
						TSay():New(20,10,{|| "Usuario: " },_oDlgLib,,,,,,.T.,CLR_BLACK,CLR_WHITE)
						oUsuAux		:= TGet():New(20,60,bSetGet(cUsuAx),_oDlgLib,60,10,,,,,,,,.T.,,,,,,,,,)
						TSay():New(35,10,{|| "Senha: " },_oDlgLib,,,,,,.T.,CLR_BLACK,CLR_WHITE)
						oSenhaAux	:= TGet():New(35,60,bSetGet(cSenhaAx),_oDlgLib,60,10,,,,,,,,.T.,,,,,,,,.T.,)
						SButton():New(60,20,01,{|| _oDlgLib:End() }, _oDlgLib,,"Confirma")
						_oDlgLib:Activate(,,,,,,)
						If B744Usuario(.F.)
							Exit
						EndIf
					EndDo
					MsAguarde({|| MailDiv(AllTrim(cUsuAx), AllTrim(TT744E->B1_COD), AllTrim(SC2->C2_PRODUTO), AllTrim(cNumOP)) }, 'Enviando e-mail...', 'Aguarde, enviando e-mail de divergência...')
					/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
					* Fim da verificação da tela                                                                                              *
					* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
				Else
					MsgStop("Código de barras inválido!")
				EndIf

			EndIf
			lRet := .F.
		EndIf
	ElseIf !Empty(cCodBar)
		lRetOP := .T.
		oBtn7:Disable() //Desativo botão fechar
	Endif

	// Valido novamente a situação da gaiola devido ao chamado: #65970 - 31/08:
	If lRet .And. lGaiolaObr .And. !Empty(cCodBar) .And. Empty(cParamSeg)
		If Empty(cCodGaiola)
			lVldGaiola	:= .F.
			B744TocaSom()
			MsgStop("O código da gaiola/carrinho é obrigatório para essa OP!")
		Else
			// Valido situação da gaiola:
			If (Select("T744G") <> 0)
				DbSelectArea("T744G")
				DbCloseArea()
			Endif
			cQuery := "SELECT TOP 1 ZDT_STATUS, ZDT_LOCFIS "
			cQuery += "FROM ZDT010 (NOLOCK) "
			cQuery += "WHERE ZDT_FILIAL = '' "
			cQuery += "AND ZDT_CODIGO = '"+StrTran(AllTrim(cCodGaiola), "GL", "")+"' "
			cQuery += "AND (ZDT_LOCFIS != 'SA' OR ZDT_STATUS IN ('ENDERECADO', 'TRANSITO', 'ORDEM GERADA')) "
			cQuery += "AND ZDT010.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "T744G"
			IF !T744G->(Eof())
				B744TocaSom()
				MsgStop("Gaiola ["+AllTrim(cCodGaiola)+"] está com status ["+AllTrim(T744G->ZDT_STATUS)+"]! Gentileza verificar...")
				lVldGaiola	:= .F.
			EndIf
		EndIf

		// No caso de erro da gaiola:
		If !lVldGaiola
			cCodBar 	:= Space(TamSx3('B1_CODBAR')[1])
			cCodGaiola	:= Space(TamSx3('ZDT_CODIGO')[1])
			oContainer:Refresh()
			// Atualizo campo:
			oGetG:Refresh()
			oGetG:SetFocus()
			// Retorno verdadeiro para sair do campo:
			Return (.T.)
		EndIf
	EndIf

	// Valido múltiplo do item no caso de gaiola:
	If lRet .And. lGaiolaObr
		If nMultiplo != nMultItem .And. nMultiplo != 1
			lRet := .F.
			B744TocaSom()
			MsgStop("Atenção: O sistema não permite esse múltiplo para essa operação!")
		EndIf
	EndIf

	If lRet .and. !Empty(cCodBar) .And. nMultiplo <= 0

		If lFirst .And. !lAvulso
			// Thiago dia 03/12/2014 (solicitado por Isabel - trazer o múltiplo do cartão);
			If AllTrim(SC2->C2_CC) == "71150"
				If (Select("TT744C") <> 0)
					dbSelectArea("TT744C")
					dbCloseArea()
				EndIf
				BeginSql Alias "TT744C"
					SELECT
						DISTINCT TOP 1 ZB1_NUM,
						ZB1_QTDPCT
					FROM
						%Table:ZB1% (NOLOCK) ZB1
					INNER JOIN %Table:ZA9% (NOLOCK) ZA9
					ON ZA9.%NotDel%
						AND ZA9_FILIAL = %xFilial:ZA9%
						AND ZA9_NUMOP = %Exp:cNumOP%
						AND ZB1_CLIENT = ZA9_CLIENT
						AND ZB1_LOJA = ZA9_LOJA
					WHERE
						ZB1.%NotDel%
						AND ZB1_FILIAL = %xFilial:ZB1%
						AND ZB1_COD = %exp:SC2->C2_PRODUTO%
						AND (
							ZB1_NUM = %exp:SC2->C2_NUMPED%
							OR ZB1_NUM = ' '
						)
					ORDER BY
						ZB1_NUM DESC
				EndSql

				If !Empty(TT744C->ZB1_QTDPCT)
					// Armazeno o múltiplo do item:
					nMultItem := TT744C->ZB1_QTDPCT

					nAviso		:= 3
					lMsHelpAuto := .F.
					while nAviso == 3
						nAviso	:= AVISO("Atenção", "Múltiplo igual a " + AllTrim(Str(TT744C->ZB1_QTDPCT)) + ", confirma?", {"Cancelar", "Confirma", "Escolha"}, 3)
						//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
					EndDo
					If nAviso == 2
						lZB1	  := .T.

						nMultiplo := TT744C->ZB1_QTDPCT
						lMultiplo := .F.
					Else
						nMultiplo := 0
					Endif

					lFirst 		:= .F.

				ElseIf	Empty(cParamSeg)
					MsgStop("Atenção! Não foi localizado a quantidade de múltiplo correto na ficha técnica. Gentileza entrar em contato com o supervisor!")
				EndIf
			EndIf

			If !lZB1 .Or. nMultiplo <= 0

				dbSelectArea("SB1")
				dbSetOrder(5)
				dbSeek(xFilial("SB1")+cCodBar)
				If Found()

					DbSelectArea("SZ7")
					DbSetOrder(1)
					DbSeek(xFilial("SZ7")+SB1->B1_CODMOD)
					If Found()
						// Armazeno o múltiplo de pacote do item:
						nMultItem := SZ7->Z7_QTDPCT

						nAviso		:= 3
						lMsHelpAuto := .F.
						while nAviso == 3
							nAviso	:= AVISO("Atenção", "Número do Múltiplo igual a " + StrZero(SZ7->Z7_QTDPCT,5) + ", Confirma?", {"Cancelar", "Confirma", "Escolha"}, 3)
							//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
						EndDo
						If nAviso == 2
							nMultiplo := SZ7->Z7_QTDPCT
							lMultiplo := .F.
						Else
							nMultiplo := 0
						Endif
					Endif
					lFirst := .F.

				Else

					//------------------------ ALTERADO POR PAULO EM 08.09.06 --------------------------
					dbSelectArea("SA7")
					dbSetOrder(3)
					If dbSeek(xFilial("SA7")+cCodbar+"EX3423"+"01")

						dbSelectArea("SB1")
						dbSetOrder(1)
						If dbSeek(xFilial("SB1")+SA7->A7_PRODUTO)

							DbSelectArea("SZ7")
							DbSetOrder(1)
							DbGoTop()
							DbSeek(xFilial("SZ7")+SB1->B1_CODMOD)
							If Found()
								// Armazeno o múltiplo de pacote do item:
								nMultItem := SZ7->Z7_QTDPCT

								nAviso		:= 3
								lMsHelpAuto := .F.
								while nAviso == 3
									nAviso	:= AVISO("Atenção", "Número do Múltiplo igual a " + StrZero(SZ7->Z7_QTDPCT,5) + ", Confirma?", {"Cancelar", "Confirma", "Escolha"}, 3)
									//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
								EndDo
								If nAviso == 2
									nMultiplo := SZ7->Z7_QTDPCT
									lMultiplo := .F.
								Else
									nMultiplo := 0
								Endif

							Endif

							lFirst := .F.

						Endif

					Endif

				Endif
			EndIf

		Endif

	Endif

	If lRet .and. lMultiplo .and. !Empty(cCodBar) .And. Empty(cParamSeg)

		oGet7:SetFocus()
		oContainer:Refresh()

	Endif

	If lRet .and. !lMultiplo .and. !Empty(cCodBar)
		//If (nQtdPecas + aPerd[NQTDSEG] + aPerd[NQTDLD] + (nMultiplo * 1) + aPerd[NPERDAPC]) == nQtdOP
		If (nQtdPecas + aPerd[NQTDSEG] + aPerd[NQTDLD] + (nMultiplo * 1) + aPerd[NPERDAPC]) == (nQtdOP - nQtdRetPc)

			nQtdPecas += (nMultiplo * 1)
			nQtdOPSal := (nQtdOp - nQtdRetPc - nQtdPecas - aPerd[NQTDSEG] - aPerd[NQTDLD] - aPerd[NPERDAPC])
			if nQtdOPSal < 0
				nQtdOPSal	:= 0
			EndIf

			// Adiciono gaiola:
			If Empty(cParamSeg) .And. lRet .And. lGaiolaObr
				InsGaiola()
			EndIf

			If	Empty(cParamSeg)
				oGet6:Refresh()
				B744TocaSom()

				nAviso		:= 3
				lMsHelpAuto := .F.
				while nAviso == 3
					nAviso	:= AVISO("Atenção", "Todas as peças foram processadas, deseja efetuar o apontamento da OP?", {"Cancelar", "Confirma", "Escolha"}, 3)
					//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
				EndDo
				If nAviso == 2
					MsgRun("Gerando Apontamento da OP","",{|| CursorWait(), B744Aponta() ,CursorArrow()})
					lFimAponta = .T.
				EndIf
			Endif

		ElseIf (nQtdPecas + aPerd[NQTDSEG]+ aPerd[NQTDLD] + (nMultiplo * 1) + aPerd[NPERDAPC]) > (nQtdOP - nQtdRetPc)

			If	Empty(cParamSeg)
				B744TocaSom()
			EndIf
			// Alan
			//If !lLibera .and. MsgYesNo("Já excedeu a quantidade de peças para a OP. Deseja apontar mais????")
			If !lLibera
				nAviso		:= 3
				lMsHelpAuto := .F.
				while nAviso == 3
					nAviso	:= AVISO("Atenção", "Já excedeu a quantidade de peças para a OP. Deseja apontar mais?", {"Cancelar", "Confirma", "Escolha"}, 3)
					//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
				EndDo
				If nAviso == 2

					lFechaLib := .F.
					lCancLib  := .F.
					cUsuAx		:= Space(24)
					cSenhaAx	:= Space(20)

					_oDlgLib := TDialog():New(0,0,200,250,"Liberacao",,,,,,,,,.T.,,,,,)
					_oDlgLib:lCentered := .T.
					_oDlgLib:lEscClose := .F.  //nao fecha tela com esc
					_oDlgLib:nStyle:=128      	//sem x no canto superior direito

					TSay():New(20,10,{|| "Usuario: " },_oDlgLib,,,,,,.T.,CLR_BLACK,CLR_WHITE)
					oUsuAux		:= TGet():New(20,60,bSetGet(cUsuAx),_oDlgLib,60,10,,,,,,,,.T.,,,,,,,,,)
					TSay():New(35,10,{|| "Senha: " },_oDlgLib,,,,,,.T.,CLR_BLACK,CLR_WHITE)
					oSenhaAux	:= TGet():New(35,60,bSetGet(cSenhaAx),_oDlgLib,60,10,,,,,,,,.T.,,,,,,,,.T.,)
					SButton():New(60,20,01,{|| (lFechaLib:=.T.,_oDlgLib:End()) }, _oDlgLib,,"Confirma")
					SButton():New(60,80,02,{|| (lCancLib := .T., lFechaLib := .T., _oDlgLib:End()) }, _oDlgLib,,"Cancela")
					_oDlgLib:Activate(,,,,,,)

					If !lCancLib
						lLibera := B744Usuario(.T.)
					EndIf

				EndIf
			End If

			If lLibera
				nQtdLiber += (nMultiplo * 1)
				nQtdPecas += (nMultiplo * 1)
				//nQtdOPSal := (nQtdOp - nQtdRetPr - nQtdPecas)
				nQtdOPSal := (nQtdOp - nQtdRetPc - nQtdPecas - aPerd[NQTDSEG] - aPerd[NQTDLD] - aPerd[NPERDAPC])
				if nQtdOPSal < 0
					nQtdOPSal	:= 0
				EndIf

				// Adiciono gaiola:
				If Empty(cParamSeg) .And. lRet .And. lGaiolaObr
					InsGaiola()
				EndIf

				If	Empty(cParamSeg)
					oGet6:Refresh()
				EndIf
			Else
				If	Empty(cParamSeg)
					oGet2:Disable()

					oGet7:Disable()
					oGet3:SetFocus()
					cCodBar:=CriaVar("B1_CODBAR",.F.)
					oContainer:Refresh()
				EndIf

				Return
			EndIf

		Else

			nQtdPecas += (nMultiplo * 1)
			//nQtdOPSal := (nQtdOp - nQtdRetPr - nQtdPecas)
			nQtdOPSal := (nQtdOp - nQtdRetPc - nQtdPecas - aPerd[NQTDSEG] - aPerd[NQTDLD] - aPerd[NPERDAPC])
			if nQtdOPSal < 0
				nQtdOPSal	:= 0
			EndIf

			// Adiciono gaiola:
			If Empty(cParamSeg) .And. lRet .And. lGaiolaObr
				InsGaiola()
			EndIf

		Endif

		//Precisa ver finalização da OP que cai nesse lugar
		If Empty(cParamSeg)
			//Se for final de apontamento:
			If lFimAponta
				oContainer:Refresh()
				oGet1:SetFocus()
				//Se não for:
			Else
				oGet7:Disable()
				oGet3:SetFocus()
				cCodBar:=CriaVar("B1_CODBAR",.F.)
				oContainer:Refresh()
			EndIf
		EndIf

	Endif

	If	Empty(cParamseg)
		oGet2:Disable()
	EndIf



Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744ValidMultº Autor ³Edinei Sanchez Milekº Data ³ 28/10/08º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida digitacao multiplo                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744ValidMult()

	Local lRet := .T.

	If nMultiplo == 0
		lRet := .F.
	Endif

	//Valida se for digitado valor maior do multiplo do que da peça do cartão. RobsonJP 20231031
	If nMultiplo > nQtdTot
		MsgStop("Não é permitido multiplo maior que a quantidade de peças da ordem de produção", "Atenção")
		nMultiplo := 0
		oContainer:Refresh()
		oGet7:SetFocus()
		lRet := .F.
	Endif

	If lRet
		// No caso da gaiola, eu não posso permitir multiplo diferente do item, ou diferente de 1:
		If lGaiolaObr
			If nMultiplo != nMultItem .And. nMultiplo != 1
				B744TocaSom()
				MsgStop("Atenção: O sistema não permite esse múltiplo para essa operação!")
				nMultiplo	:= nMultItem
				Return(lRet	:= .F.)
			EndIf
		EndIf

		nAviso		:= 3
		lMsHelpAuto := .F.
		while nAviso == 3
			nAviso	:= AVISO("Atenção", "Confirma digitação de "+str(nMultiplo,4)+" para múltiplo da peça?", {"Cancelar", "Confirma", "Escolha"}, 3)
			//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
		EndDo
		If nAviso == 2
			lMultiplo := .F.
			lRet:=B744ValidCodBar()
		Endif
	Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744ValidAvulsoº   ³Edinei Sanchez Milekº Data ³ 28/10/08  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida mudança para quantidade avulsa                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744ValidAvulso()

	nAviso		:= 3
	lMsHelpAuto := .F.
	while nAviso == 3
		nAviso	:= AVISO("Atenção", "Deseja mudar o múltiplo para 1 e informar peças avulsas?", {"Cancelar", "Confirma", "Escolha"}, 3)
		//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
	EndDo
	If nAviso == 2
		nMultiplo := 1
		lRet      := .T.
		lAvulso   := .T.
		If	Empty(cParamSeg)
			oContainer:Refresh()
			oGet3:SetFocus()
		EndIf
	Endif

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744QtdApSegº Autor ³Edinei Sanchez Milekº Data ³ 28/10/08 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se ha apontamento de segunda qualidade            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744QtdApSeg()

	Local cQuery
	Local cAlias
	aPerd  := {0,0,0,0,0,0,0,0,0,0}
	aPerdRet := {}
	aRecSeg	 := {}
	aRecLD	 := {}
	aRecPer	 := {}

	cAlias := GetNextAlias()
	// Quantidade de perdas em peça:
	If 	Rtrim(cCCusto) == "71150"
		cQuery := " SELECT SUM(ZAB_QTDPC) AS QTDRETPC "
		cQuery += " FROM "+RetSqlName("ZAB")
		cQuery += " WHERE ZAB_FILIAL = '"+xFilial("ZAB")+"' "
		cQuery += " AND ZAB_OP = '"+cNumOP+"' "
		cQuery += " AND ZAB_QTDPC > 0 "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		TCQUERY cQuery NEW ALIAS &cAlias
		If (cAlias)->(!Eof())
			nQtdRetPc := (cAlias)->QTDRETPC
		EndIf
	EndIf
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

	If 	Rtrim(cCCusto) == "71150"
		cQuery := " SELECT SUM(ZAB_QTDPC) AS QTDRETPC "
		cQuery += " FROM "+RetSqlName("ZAB")
		cQuery += " WHERE ZAB_FILIAL = '"+xFilial("ZAB")+"' "
		cQuery += " AND ZAB_OP = '"+cNumOP+"' "
		cQuery += " AND ZAB_QTDPC > 0 "
		cQuery += " AND ZAB_PROCES != 'S' "
		cQuery += " AND D_E_L_E_T_ = ' ' "
		TCQUERY cQuery NEW ALIAS &cAlias
		TCSETFIELD(cAlias,"QTDRETPC","N",12,04)
		If (cAlias)->(!Eof())
			nQtdRetPr := (cAlias)->QTDRETPC
		EndIf
	EndIf

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif
	// FIM - Quantidade de perdas em peça.

	cQuery := " SELECT ZAB_FILIAL, ZAB_OP, ZAB_ITEM, ZAB_CODDEF, ZAB_QUANT, ZAB_QTDPC, ZAB_RETALH, R_E_C_N_O_ AS ZAB_RECNO "
	cQuery += " FROM "+RetSqlName("ZAB")
	cQuery += " WHERE ZAB_FILIAL = '"+xFilial("ZAB")+"' "
	cQuery += " AND ZAB_OP = '"+cNumOP+"' "
	cQuery += " AND ZAB_PROCES != 'S' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif

	TCQUERY cQuery NEW ALIAS &cAlias

	TCSETFIELD(cAlias,"ZAB_QUANT","N",12,04)
	TCSETFIELD(cAlias,"ZAB_RECNO","N",12,00)

	While !(cAlias)->(Eof())

		If !Empty((cAlias)->ZAB_retalh)
			nPosRet	:= aScan(aPerdRet,{|x| x[1] == (cAlias)->ZAB_retalh })
			If Empty(nPosRet)
				aadd(aPerdRet,{(cAlias)->ZAB_retalh,(cAlias)->ZAB_quant})
			Else
				aPerdRet[nPosRet][2] += (cAlias)->ZAB_quant
			EndIf
			aPerd[NPERDAPC] += (cAlias)->ZAB_QTDPC
			If !Empty((cAlias)->ZAB_QTDPC)
				nPerdKg += (cAlias)->ZAB_quant
			EndIf
			aAdd(aRecSeg,(cAlias)->ZAB_RECNO)
		Else

			If ! (rtrim((cAlias)->ZAB_CODDEF) $ "199|299|399|499|599|699") .and. left((cAlias)->ZAB_CODDEF,1) $ "1|2|3|4"
				If rtrim(cCCusto) != "71160"
					aPerd[NQTDSEG] 	+= (cAlias)->ZAB_QUANT
					//aPerd[NPERDAPC] += (cAlias)->ZAB_QTDPC
				Else
					//aPerd[NQTDSEG] += (cAlias)->ZAB_QTDPC
					//aPerd[NPERDAPC]+= (cAlias)->ZAB_QUANT
					//aPerd[NRETALHO] += (cAlias)->ZAB_QUANT
					aPerd[NQTDSEG] 	+= (cAlias)->ZAB_QUANT
					aPerd[NPERDAPC] += (cAlias)->ZAB_QTDPC
				Endif
				aAdd(aRecSeg,(cAlias)->ZAB_RECNO)
			Endif

			If ! (rtrim((cAlias)->ZAB_CODDEF) $ "199|299|399|499|599|699") .and. left((cAlias)->ZAB_CODDEF,1) $ "5|6|7"
				aPerd[NQTDLD]  += (cAlias)->ZAB_QUANT
				aAdd(aRecLD,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "199"
				aPerd[NPERDA199] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "299"
				aPerd[NPERDA299] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "399"
				aPerd[NPERDA399] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "499"
				aPerd[NPERDA499] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "599"
				aPerd[NPERDA599] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

			If rtrim((cAlias)->ZAB_CODDEF) $ "699"
				aPerd[NPERDA699] += (cAlias)->ZAB_QUANT
				aAdd(aRecPer,(cAlias)->ZAB_RECNO)
			Endif

		EndIf

		dbSkip()

	End

	nPerdas := aPerd[NQTDSEG] + aPerd[NQTDLD] + aPerd[NPERDAPC]

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ B744Aviso  º Autor ³Edinei Sanchez Milekº Data ³ 07/04/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Mostra tela de aviso                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Static Function B744Aviso()

	Local nOpcao

	If ((nQtdPecas + aPerd[NQTDSEG] + aPerd[NQTDLD]) < (nQtdOP - nQtdRetPr))

		//If MsgYesNo("Não foram apontadas todas as peças, deseja encerrar a OP?")
		nAviso		:= 3
		lMsHelpAuto := .F.
		while nAviso == 3
			nAviso	:= AVISO("Atenção", "Não foram apontadas todas as peças, deseja encerrar a OP?", {"Cancelar", "Confirma", "Escolha"}, 3)
		EndDo
		If nAviso == 2
			nOpcao := 2
			//Return
		Endif

		//nOpcao := SAviso("Atenção","Não foram processadas todas as peças da OP, selecione uma opção: "+CRLF+CRLF+;
		//"1) Encerrar: Encerra a OP, não sendo possível fazer apontamentos posteriores."+CRLF+;
		//"2) Apontar: Aponta a quantidade processada, mas não encerra a OP, permitindo apontamentos posteriores."+CRLF+;
		//"3) Cancelar: Fecha essa janela e retorna para a tela anterior.",{"&Encerrar","&Apontar","&Cancelar"},3 ,"Opções")
		//ElseIf	((nQtdPecas + aPerd[NQTDSEG] + aPerd[NQTDLD]) >= nQtdOP)
		//		nOpcao := 2
	Endif

	If nOpcao == 1 .or. nOpcao == 2
		Eval({|| 	MsgRun("Gerando Apontamento da OP","", {|| CursorWait(), B744Aponta(nOpcao) ,CursorArrow()}), 	If (Empty(cParamSeg),oGet1:SetFocus(),) })
	Else
		Return
	Endif

Return
*/

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744Aponta º Autor ³Edinei Sanchez Milekº Data ³ 28/10/08  º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Faz o apontamento de producao                              º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ AP6 IDE                                                    º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744Aponta(nOpcao)
	Local aCab      := {}
	Local aItens    := {}
	Local cProdPerda:= cProduto
	Local cAlmoxOri := If(rtrim(cCCusto)=="71150","P6","P7")
	Local cProdOrig := Stuff(cProdPerda ,9,6,"000000")
	Local lEmpenho 	:= .F.
	Local _i		:= 0
	Local _x		:= 0
	Local j 		:= 0


	Local aSD3 := SD3->(GetArea())
	// Variavel incluida para controlar o total já consumido de resíduos/retalhos/tecidos já processados da peça - 27/04/16
	Local nQtdCons	:= 0

	//	Local cProdOrig := Stuff(cProdPerda ,9,3,"000") // JONAS  - 25/09/12
	Default nOpcao := 2

	// Inlcuido por Thiago (dia 26/01/2017) verificar flag:
	If	!IsInCallStack("U_BUD1193")
		//U_BUD1259(.T.)
	EndIf

	// Executa a função para prencher a sequencia a ser usada nas movimentações da OP
	B744Seq()

	dbSelectArea("SB1")
	dbSetOrder(1)

	// Posicionar na Ordem de Produção que está sendo produzida
	dbSelectArea('SC2')
	dbSetOrder(1)
	MsSeek(xFilial('SC2')+cNumOP)

	// Posicionar na OP gerada a partir da Peça da Tinturaria
	dbSelectArea('ZA9')
	dbSetOrder(6)
	MsSeek(xFilial('ZA9')+cNumOP)

	// Posicionar na Peça originada da Tinturaria
	dbSelectArea('ZA8')
	dbSetOrder(3)
	MsSeek(xFilial('ZA8')+ZA9->ZA9_CHAVE)

	PutMv("BD_1193FLA", Time())

	// Verificar se a OP apontada está com o Status de Retorno de Facção (5)
	lRetFac := IIf(SC2->C2_SITAOP == '5', .T., .F.)

	// Flag para ficar fora da transação, impressão das etiquetas de apontamento:
	lApontaZBV	:= .F.
	lMsErroAuto	:= .F.

	//Begin Transaction

	/* 11/2021
		// ** Verifica Tipo do SB2010:
		cB2_TIPO := Posicione('SB2',1,xFilial('SB2')+cProduto+cAlmox,'B2_TIPO')
		If cB2_TIPO <> '1'
			cQuery := ""
			cQuery += "UPDATE " + RETSQLNAME("SB2") + " SET B2_TIPO = '1' "
			cQuery += "WHERE D_E_L_E_T_ <> '*' "
			cQuery += "AND B2_TIPO <> '1' "
			cQuery += "AND B2_FILIAL = '"+xFilial("SB2")+"' "
			TCSQLEXEC(cQuery)
		EndIf
	*/

	// FAZER O APONTAMENTO DA PERDA
	// Só irá efetuar o consumo de Resíduos e Perdas de Tecido caso a OP não seja de retorno de Facção
	If (aPerd[NPERDA199] > 0 .or. aPerd[NPERDA299] > 0 .or. aPerd[NPERDA399] > 0 .or.;
			aPerd[NPERDA499] > 0 .or. aPerd[NPERDA599] > 0 .or. aPerd[NPERDA699] > 0 .or.;
			Len(aPerdRet) > 0) .And. !lRetFac

		If  Select('TZA8') > 0
			dbSelectArea('TZA8')
			dbCloseArea()
		EndIf

		If rtrim(cCCusto) == '71150' .OR. cGrupo == 'F500'   // GRUPO DE COLCHA QUE SAO GERADAS OP'S NO CENTRO DE CUSTO 71160 POREM AS PERDAS SAO
			// LANCADAS NA ZAB PELA ROTINA PADRAO DA COSTURA COM O TECIDO DA ZA8

			BeginSql Alias 'TZA8'
				%noparser%

				SELECT
					ZA8_COD,
					C2_PRODUTO,
					ZA8_CODTEC
				FROM
					%Table:ZA8% ZA8 (NOLOCK),%Table:ZA9% ZA9 (NOLOCK),%Table:SC2% SC2 (NOLOCK)
				WHERE
					ZA8_FILIAL = %xFilial:ZA8%
					AND ZA8.%NotDel%
					AND ZA9_FILIAL = %xFilial:ZA9%
					AND ZA9.%NotDel%
					AND C2_FILIAL = %xFilial:SC2%
					AND SC2.%NotDel%
					AND ZA9_NUMOP = %exp:cNumOP%
					AND ZA9_CHAVE = ZA8_NUM + ZA8_ITEM + ZA8_SEQ
					AND Substring(ZA8_COD, 9, 6) != '000000'
					AND ZA8_NUM + ZA8_ITEM + ZA8_SEQ = ZA9_CHAVE
					AND C2_NUM + C2_ITEM + C2_SEQUEN = ZA9_NUMOP
			EndSql

		ElseIf rtrim(cCCusto) == '71160'

			BeginSql Alias 'TZA8'
				%noparser%

				SELECT
					ZA9_TECIDO AS ZA8_COD,
					' ' AS C2_PRODUTO,
					' ' AS ZA8_CODTEC
				FROM
					%Table:ZA9% (NOLOCK)
				WHERE
					ZA9_FILIAL = %xFilial:ZA9%
					AND %NotDel%
					AND ZA9_NUMOP = %exp:cNumOP%
					AND ZA9_CHAVE = ' '
			EndSql

			If TZA8->(Eof())

				If  Select('TZA8') > 0
					dbSelectArea('TZA8')
					dbCloseArea()
				EndIf

				BeginSql Alias 'TZA8'
					%noparser%

					SELECT
						ZA8_COD,
						' ' AS C2_PRODUTO,
						ZA8_CODTEC
					FROM
						%Table:ZA8% ZA8 (NOLOCK),%Table:ZA9% ZA9 (NOLOCK)
					WHERE
						ZA8_FILIAL = %xFilial:ZA8%
						AND ZA8.%NotDel%
						AND ZA9_FILIAL = %xFilial:ZA9%
						AND ZA9.%NotDel%
						AND ZA9_NUMOP = %exp:cNumOP%
						AND ZA9_CHAVE = ZA8_NUM + ZA8_ITEM + ZA8_SEQ
				EndSql

			EndIf

		Else

			BeginSql Alias 'TZA8'
				%noparser%

				SELECT
					ZA8_COD,
					' ' AS C2_PRODUTO,
					ZA8_CODTEC
				FROM
					%Table:ZA8% ZA8 (NOLOCK),%Table:ZA9% ZA9 (NOLOCK)
				WHERE
					ZA8_FILIAL = %xFilial:ZA8%
					AND ZA8.%NotDel%
					AND ZA9_FILIAL = %xFilial:ZA9%
					AND ZA9.%NotDel%
					AND ZA9_NUMOP = %exp:cNumOP%
					AND ZA9_CHAVE = ZA8_NUM + ZA8_ITEM + ZA8_SEQ
			EndSql

		Endif

		If !TZA8->(Eof()) .and. rtrim(cCCusto) == '71150'
			cProdOrig := TZA8->ZA8_COD
			If	Substring(TZA8->ZA8_COD,9,6) != '000000'
				If	Left(TZA8->ZA8_COD,1) == 'V'
					cProdOrig := 'Q' + Substring(TZA8->ZA8_COD,2,29)
				Else
					cProdOrig := 'T' + Substring(TZA8->ZA8_COD,2,29)
				EndIf
			Else
				cProdOrig := TZA8->ZA8_CODTEC
			EndIf

			//cProdOrig := If(left(TZA8->ZA8_COD,1)=="F",'T','Q')+Substring(TZA8->ZA8_COD,2,29) // JONAS - 05/07/12 - 2,14
			If	Substring(TZA8->ZA8_COD,1,14) == cCodSaldo
				cProdOrig := TZA8->C2_PRODUTO
			EndIf

			If	!Empty(TZA8->ZA8_CODTEC)
				If	Substring(TZA8->ZA8_CODTEC,9,6) != '000000'
					If	Left(TZA8->ZA8_CODTEC,1) == 'V'
						cProdOrig := 'Q' + Substring(TZA8->ZA8_CODTEC,2,29)
					Else
						cProdOrig := 'T' + Substring(TZA8->ZA8_CODTEC,2,29)
					EndIf
				Else
					cProdOrig := TZA8->ZA8_CODTEC
				EndIf

				// Verifica se Existe Empenho do Produto Original, caso exista será limpado
				// o campo do Codigo do Produto Original para não efetuar baixa do estoque duplicado
				// somente pelo Empenho.

				SD4->(DbSetOrder(2))
				SD4->(MsSeek(xFilial('SD4')+cNumOP+cProdOrig+'P6'))
				If	SD4->(D4_FILIAL + D4_OP + D4_COD + D4_LOCAL) == xFilial('SD4') + cNumOP + cProdOrig + 'P6'
					lEmpenho := .T.
				EndIf

			EndIf
		Elseif !TZA8->(Eof()) .and. rtrim(cCCusto) == '71160'
			cProdOrig := TZA8->ZA8_COD
		ElseIf	!Empty(TZA8->ZA8_CODTEC)
			cProdOrig := TZA8->ZA8_CODTEC
		Else
			cProdOrig := Stuff(cProdPerda ,9,6,"000000")
		EndIf

		// Executado quando o campo ZA8_PESTIN ainda não estiver preenchido para gerar a perda da Tinturaria contra a OP da Toalha.
		// Incluido em 01/06/2016 - TSC109 - Marcos A. Schoeffel
		If Alltrim(cCCusto) = '71150' .And. Empty(ZA8->ZA8_PESTIN)

			nMV_Percen 	:= GetMv("MV_PERTINT")
			nPesoPer := Round((ZA8->ZA8_QTDPES * nMv_Percen) / 100,2)
			/*
				If	nPesoPer > 0
					aRequis := {}
					aAdd(aRequis,{"D3_TM"     	,'503'     				,Nil}) //Codigo do Tipo de Movimentacao
					aAdd(aRequis,{"D3_EMISSAO"  ,MsDate()              	,Nil}) //Data de Emissao
					aAdd(aRequis,{"D3_COD"		,cProdOrig     			,Nil}) //Codigo do Produto
					aAdd(aRequis,{"D3_UM"   	,SB1->B1_UM				,Nil}) //Unidade de medida
					aAdd(aRequis,{"D3_LOCAL"	,cAlmoxOri         		,Nil}) //Almoxarifado
					aAdd(aRequis,{"D3_QUANT"	,nPesoPer            	,Nil}) //Quantidade
					aAdd(aRequis,{"D3_SEQBUDD"	,cSeqBudd            	,Nil}) //Sequencia de Apontamento
					aAdd(aRequis,{"D3_OP"		,cNumOP					,Nil}) //Numero da O.P.

					/*
					11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
			*/
			/*lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.  //necessario a criacao, pois sera
					MSExecAuto({|x,y| MATA240(x,y)},aRequis,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Else
						RecLock('ZA8',.T.)
						ZA8->ZA8_PESTIN := nPesoPer
						ZA8->(MsUnlock()) //Alterado por Paulo Afonso em 10/08/2017
					Endif
				EndIf
			*/
			If	nPesoPer > 0

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,'503'				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,     		,Nil},;
					{"D3_QUANT" 	,nPesoPer        	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If (lMsErroAuto)
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				Else
					RecLock('ZA8',.T.)
					ZA8->ZA8_PESTIN := nPesoPer
					ZA8->(MsUnlock()) //Alterado por Paulo Afonso em 10/08/2017
				Endif
			EndIf

		EndIf

		// Verifica parametro se está setado para executar o apontamento de Perda
		// ou somente deverá ser feito o consumo por requisição simples
		If	SuperGetMv('BD_PERD744',.F.,.F.)

			aCab := {	{"BC_OP"      ,cNumOP 	,NIL},;
				{"BC_RECURSO" ,"" 			,NIL},;
				{"BC_OPERAC"  ,"" 			,NIL}}

			If Len(aPerdRet) > 0 .And. !Empty(cProdOrig)
				For _i := 1 To Len(aPerdRet)

					/* 11/2021
						// Não prossigo se o registro esteja travado:
						While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
							// Caso o registro esteja travado, não prossigo...
							U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
						EndDo
					*/
					aItens:= {}
					aItem :=  {{"BC_PRODUTO", cProdOrig  			,nil},;
						{"BC_LOCORIG", cAlmoxOri   			,nil},;
						{"BC_TIPO"   , "R"     				,nil},;
						{"BC_MOTIVO" , "FP"    				,nil},;
						{"BC_QUANT"  , aPerdRet[_i][2]		,nil},;
						{"BC_OPERADO", cUserName  			,nil},;
						{"BC_DATA"   , MsDate() 			,nil},;
						{"BC_SEQBUDD", cSeqBudd				,nil}}
					AAdd(aItens ,aItem)

					DbSelectArea('SB2')
					DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

					If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerdRet[_i][2]

						lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
						lMsErroAuto := .F.
						MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
						If (lMsErroAuto)
							DisarmTransaction()

							If !__AUTO
								MostraErro()
							Else
								cErro := "[BUD744] - ERRO - Erro na rotina"
								U_BUD1427(cErro)
							EndIf
						Endif
					EndIf

					B744Perda(aPerdRet[_i,1],cAlmoxOri,aPerdRet[_i,2],cUserName)
				Next _i
			EndIf
		ElseIf 	Len(aPerdRet) > 0 .And. !Empty(cProdOrig)

			dbSelectArea('SD3')
			aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
				{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
				{"D3_EMISSAO"	,MsDate()							,Nil}}

			aItens := {}

			//11/2021 - Retirado de dentro do For para não ficar processando sem necessidade
			SB1->(MsSeek(xFilial('SB1')+cProdOrig))

			For _x:= 1 To Len(aPerdRet)
				/* 11/2021
					SB1->(MsSeek(xFilial('SB1')+cProdOrig))
				*/

				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/
				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerdRet[_x][2]	,Nil},;
					{"D3_OP"		,cNumOp				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_CONTA" 	,SB1->B1_conta		,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

			Next _x

			If !Empty(Len(aItens))

				lMsHelpAuto := .T.
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf
			EndIf

		EndIf

		If aPerd[NPERDA199] > 0	 //Perda Felpa Tecelagem ou Veludo tecelagem

			cProdDest := If(left(cProdOrig,1)$"F/T",Alltrim(GETMV("MV_BUD7441"))+SPACE(12),Alltrim(GETMV("MV_BUD7442"))+SPACE(12)) // JONAS - 25/09/12

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)
				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/
				aItens:= {}
				aItem :=  {{"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA199]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////

				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA199]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA199],cUserName)
				EndIf

			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA199]        	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf
			EndIf
		EndIf

		If aPerd[NPERDA299] > 0  //Perda Felpa Tinturaria e Veludo Tinturaria

			cProdDest := If(left(cProdOrig,1)$"F/T",Alltrim(GETMV("MV_BUD7443"))+SPACE(12),Alltrim(GETMV("MV_BUD7444"))+SPACE(12)) // JONAS - 24/09/12

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)

				aItens:= {}
				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/
				aItem :=  {{"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA299]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////

				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA299]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA299],cUserName)
				EndIf
			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { {"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA299]       	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf
		Endif

		If aPerd[NPERDA399] > 0  //Perda Residuo Costura

			cProdDest := rtrim(GETMV("MV_BUD7445"))

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)

				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/

				aItens:= {}
				aItem :=  {{"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA399]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////
				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA399]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA399],cUserName)
				EndIf
			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA399]      	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf
		Endif

		If aPerd[NPERDA499] > 0  //Perda Felpa Costura e Veludo Costura

			cProdDest := If(left(cProdOrig,1)$"F/T",rtrim(GETMV("MV_BUD7446")),rtrim(GETMV("MV_BUD7447")))

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)

				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/

				aItens:= {}
				aItem :=  { {"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA499]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////

				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA499]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA499],cUserName)
				EndIf

			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA499]     	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf

		Endif

		If aPerd[NPERDA599] > 0  //Perda Residuo Tecelagem

			cProdDest := rtrim(GETMV("MV_BUD7445"))

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)
				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/

				aItens:= {}
				aItem :=  { {"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA599]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////
				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA599]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA599],cUserName)
				EndIf
			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA599]     	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf
		Endif

		If aPerd[NPERDA699] > 0  //Perda Residuo Tinturaria

			cProdDest := rtrim(GETMV("MV_BUD7445"))

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)

				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/

				aItens:= {}
				aItem :=  { {"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , aPerd[NPERDA699]		,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				//REALIZA APONTAMENTO DA PERDA
				/////////////////////
				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NPERDA699]

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,aPerd[NPERDA699],cUserName)
				EndIf
			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,aPerd[NPERDA699]    	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf
		Endif

	Endif

	//////////////////////////////////////////////////////////////////////////////////
	//Se for apontamento no roupao, a quantidade em KG de tecido é lancado como     //
	//perda e informado a quantidade em pecas para baixar da OP como perda tambem   //
	//Isso ocorre quando uma peca já pronta tiver algum defeito e for para retalho  //
	//////////////////////////////////////////////////////////////////////////////////
	If aPerd[NRETALHO] > 0 .and. aPerd[NPERDAPC] > 0 .and. rtrim(cCCusto) = "71160"

		If  Select('TZA8') > 0
			dbSelectArea('TZA8')
			dbCloseArea()
		EndIf

		BeginSql Alias 'TZA8'
			%noparser%

			SELECT
				ZA9_TECIDO AS ZA8_COD,
				' ' AS ZA8_CODTEC
			FROM
				%Table:ZA9% (NOLOCK)
			WHERE
				ZA9_FILIAL = %xFilial:ZA9%
				AND %NotDel%
				AND ZA9_NUMOP = %exp:cNumOP%
				AND ZA9_CHAVE = ' '
		EndSql

		If TZA8->(Eof())

			If  Select('TZA8') > 0
				dbSelectArea('TZA8')
				dbCloseArea()
			EndIf

			BeginSql Alias 'TZA8'
				%noparser%

				SELECT
					ZA8_COD,
					ZA8_CODTEC
				FROM
					%Table:ZA8% ZA8 (NOLOCK),%Table:ZA9% ZA9 (NOLOCK)
				WHERE
					ZA8_FILIAL = %xFilial:ZA8%
					AND ZA8.%NotDel%
					AND ZA9_FILIAL = %xFilial:ZA9%
					AND ZA9.%NotDel%
					AND ZA9_NUMOP = %exp:cNumOP%
					AND ZA9_CHAVE = ZA8_NUM + ZA8_ITEM + ZA8_SEQ
			EndSql

		EndIf

		If !TZA8->(Eof())
			cProdOrig := TZA8->ZA8_COD
		Endif

		// Verifica parametro se está setado para executar o apontamento de Perda
		// ou somente deverá ser feito o consumo por requisição simples
		If	SuperGetMv('BD_PERD744',.F.,.F.)

			aCab := {   {"BC_OP"      ,cNumOP 	,NIL},;
				{"BC_RECURSO" ,"" 		,NIL},;
				{"BC_OPERAC"  ,"" 		,NIL}}

			cProdDest := rtrim(GETMV("MV_BUD7445"))

			/* 11/2021
				// Não prossigo se o registro esteja travado:
				While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
					// Caso o registro esteja travado, não prossigo...
					U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
				EndDo
			*/

			aItens:= {}
			aItem :=  { {"BC_PRODUTO", cProdOrig  			,nil},;
				{"BC_LOCORIG", cAlmoxOri   			,nil},;
				{"BC_TIPO"   , "R"     				,nil},;
				{"BC_MOTIVO" , "FP"    				,nil},;
				{"BC_QUANT"  , aPerd[NRETALHO]		,nil},;
				{"BC_OPERADO", cUserName  			,nil},;
				{"BC_DATA"   , MsDate() 			,nil},;
				{"BC_SEQBUDD", cSeqBudd				,nil}}

			AAdd(aItens ,aItem)

			DbSelectArea('SB2')
			DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

			If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= aPerd[NRETALHO]

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.
				MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
				If (lMsErroAuto)
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				Endif

				B744Perda(cProdDest,cAlmoxOri,aPerd[NRETALHO],cUserName)
			EndIf
		Else

			aItens := {}
			aCab := {}

			dbSelectArea('SD3')
			aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
				{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
				{"D3_EMISSAO"	,MsDate()							,Nil}}


			aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
				{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
				{"D3_QUANT" 	,aPerd[NRETALHO]    	,Nil},;
				{"D3_OP"		,cNumOP				,Nil},;
				{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
				{"D3_SEQBUDD"	,cSeqBudd			,nil}})

			lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
			lMsErroAuto := .F.  //necessario a criacao, pois sera

			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
			If 	lMsErroAuto
				DisarmTransaction()

				If !__AUTO
					MostraErro()
				Else
					cErro := "[BUD744] - ERRO - Erro na rotina"
					U_BUD1427(cErro)
				EndIf
			EndIf


		EndIf
	Endif

	//////////////////////////////////////////////////////////////////////////////////
	//Se for apontamento no roupao, executa apontamento da perda dos tecidos				//
	//auxiliares da tabela ZAF																									    //
	//////////////////////////////////////////////////////////////////////////////////
	cProdAnt := cProduto
	If rtrim(cCCusto) = "71160"

		cAlias := GetNextAlias()
		cQuery := " SELECT ZA9_TECIDO AS ZA8_COD, ZAF_QUANT, ZAF_PERDA, ZAF.R_E_C_N_O_  AS ZAF_RECNO "
		cQuery += " FROM "+RetSqlName("ZAF")+" ZAF "
		cQuery += " INNER JOIN "+RetSqlName("ZA9")+" ZA9 ON (ZA9_FILIAL = '"+xFilial("ZA9")+"' AND ZA9_NUMOP =  ZAF_NUMOP AND ZA9_CHAVE = ' ' AND ZA9.D_E_L_E_T_ = ' ') "
		cQuery += " WHERE ZAF_FILIAL = '"+xFilial("ZAF")+"'
		cQuery += " AND ZAF_NUMOP = '"+cNumOp+"' "
		cQuery += " AND ZAF.D_E_L_E_T_ = '' "
		cQuery += " AND ZAF_PROCES != 'S' "

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

		TCQUERY cQuery NEW ALIAS &cAlias
		TcSetField(cAlias,"ZAF_QUANT","N",12,04)
		TcSetField(cAlias,"ZAF_PERDA","N",12,04)
		TcSetField(cAlias,"ZAF_RECNO","N",12,00)

		If (cAlias)->(Eof())
			cAlias := GetNextAlias()
			cQuery := " SELECT ZA8_COD, ZAF_QUANT, ZAF_PERDA, ZAF.R_E_C_N_O_  AS ZAF_RECNO "
			cQuery += " FROM "+RetSqlName("ZAF")+" ZAF "
			cQuery += " INNER JOIN "+RetSqlName("ZA8")+" ZA8 ON (ZA8_FILIAL = '"+xFilial("ZA8")+"' AND ZA8_NUM =  SUBSTRING(ZAF_PECA,1,6) AND ZA8_ITEM = SUBSTRING(ZAF_PECA,7,2) AND ZA8_SEQ = SUBSTRING(ZAF_PECA,9,2) AND ZA8.D_E_L_E_T_ = ' ') "
			cQuery += " WHERE ZAF_FILIAL = '"+xFilial("ZAF")+"'
			cQuery += " AND ZAF_NUMOP = '"+cNumOp+"' "
			cQuery += " AND ZAF.D_E_L_E_T_ = '' "
			cQuery += " AND ZAF_PROCES != 'S' "

			If Select(cAlias) > 0
				dbSelectArea(cAlias)
				dbCloseArea()
			Endif

			TCQUERY cQuery NEW ALIAS &cAlias
			TCSETFIELD(cAlias,"ZAF_QUANT","N",10,04)
			TCSETFIELD(cAlias,"ZAF_PERDA","N",10,04)
			TCSETFIELD(cAlias,"ZAF_RECNO","N",10,00)
		EndIf

		While !(cAlias)->(Eof())

			//REALIZA APONTAMENTO DA PERDA
			/////////////////////

			cProdDest := rtrim(GETMV("MV_BUD7445"))
			cProdOrig := (cAlias)->ZA8_COD

			// Verifica parametro se está setado para executar o apontamento de Perda
			// ou somente deverá ser feito o consumo por requisição simples
			If	SuperGetMv('BD_PERD744',.F.,.F.)

				aCab := {	{"BC_OP"      ,cNumOP 	,NIL},;
					{"BC_RECURSO" ,"" 		,NIL},;
					{"BC_DATA"    ,MsDate() ,NIL},;
					{"BC_OPERAC"  ,"" 		,NIL}}

				/* 11/2021
					// Não prossigo se o registro esteja travado:
					While U_zLockSB2(cProdOrig, cAlmoxOri, .T.)
						// Caso o registro esteja travado, não prossigo...
						U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdOrig)+"]/["+AllTrim(cAlmoxOri)+"] esta travado...")
					EndDo
				*/

				aItens:= {}
				aItem :=  { {"BC_PRODUTO", cProdOrig  			,nil},;
					{"BC_LOCORIG", cAlmoxOri   			,nil},;
					{"BC_TIPO"   , "R"     				,nil},;
					{"BC_MOTIVO" , "FP"    				,nil},;
					{"BC_QUANT"  , (cAlias)->ZAF_PERDA	,nil},;
					{"BC_OPERADO", cUserName  			,nil},;
					{"BC_DATA"   , MsDate() 			,nil},;
					{"BC_SEQBUDD", cSeqBudd				,nil}}

				AAdd(aItens ,aItem)

				DbSelectArea('SB2')
				DbSeek(xFilial('SB2')+cProdOrig+cAlmoxOri)

				If !Empty(cProdOrig) .And. SaldoSb2(,,,,,"SB2") >= (cAlias)->ZAF_PERDA

					lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
					lMsErroAuto := .F.
					MsExecAuto({|x,y,z|MATA685(x,y,z)},aCab,aItens,3)
					If (lMsErroAuto)
						DisarmTransaction()

						If !__AUTO
							MostraErro()
						Else
							cErro := "[BUD744] - ERRO - Erro na rotina"
							U_BUD1427(cErro)
						EndIf
					Endif

					B744Perda(cProdDest,cAlmoxOri,(cAlias)->ZAF_PERDA,cUserName)
				EndIf
			Else

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,cProdOrig			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cProdOrig,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,(cAlias)->ZAF_PERDA    	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,cAlmoxOri 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If 	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			EndIf

			//REALIZA CONSUMO DO TECIDO AUXILIAR
			////////////////////////////////////
			If (cAlias)->ZAF_QUANT > 0

				aItens := {}
				aCab := {}

				dbSelectArea('SD3')
				aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
					{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
					{"D3_CC" ,cCCusto, NIL},;
					{"D3_EMISSAO"	,MsDate()							,Nil}}


				aadd(aItens, {	{"D3_COD"		,(cAlias)->ZA8_COD			,Nil},;
					{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+(cAlias)->ZA8_COD,"SB1->B1_UM")    		,Nil},;
					{"D3_QUANT" 	,(cAlias)->ZAF_QUANT    	,Nil},;
					{"D3_OP"		,cNumOP				,Nil},;
					{"D3_LOCAL" 	,"P7" 			,Nil},;
					{"D3_SEQBUDD"	,cSeqBudd			,nil}})

				lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
				lMsErroAuto := .F.  //necessario a criacao, pois sera

				MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
				If	lMsErroAuto
					DisarmTransaction()

					If !__AUTO
						MostraErro()
					Else
						cErro := "[BUD744] - ERRO - Erro na rotina"
						U_BUD1427(cErro)
					EndIf
				EndIf

			Endif

			ZAF->(DbGoto((cAlias)->ZAF_RECNO))
			RecLock('ZAF',.F.)
			ZAF->ZAF_PROCES := 'S'
			ZAF->(MsUnlock()) //Alterado por Paulo Afonso em 10/08/2017

			dbSelectArea(cAlias)
			dbSkip()

		EndDo

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif
	Endif

	lRoupNovo := .F.
	If rtrim(cCCusto) == "71160"

		//////////////////////////////////////////////////////////////////////////////////
		//CONSUMO DO TECIDO PRINCIPAL																										//
		//////////////////////////////////////////////////////////////////////////////////
		cProduto := cProdAnt
		cAlias := GetNextAlias()
		cQuery := " SELECT ZA9_TECIDO AS ZA8_COD, ZA9_PESPRO "
		cQuery += " FROM "+RetSqlName("ZA9")
		cQuery += " WHERE ZA9_FILIAL = '"+xFilial("ZA9")+"' "
		cQuery += " AND ZA9_NUMOP = '"+cNumOP+"' AND ZA9_CHAVE = ' ' "
		cQuery += " AND D_E_L_E_T_ = ' ' "

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

		TCQUERY cQuery NEW ALIAS &cAlias
		TcSetField(cAlias,"ZA9_PESPRO","N",12,4)

		If !(cAlias)->(Eof())
			lRoupNovo := .T.
		EndIf

	EndIf

	If !lRoupNovo
		//////////////////////////////////////////////////////////////////////////////////
		//CONSUMO DO TECIDO PRINCIPAL																										//
		//////////////////////////////////////////////////////////////////////////////////
		cProduto := cProdAnt
		cAlias := GetNextAlias()
		cQuery := " SELECT ZA8_COD, ZA9_PESPRO, ZA8_CODTEC, ZA8_QTDPES, ZA8_PESTIN, ZA8_QTDPC1, ZA8_QTDPC2, ZA8_CODTEC "
		cQuery += " FROM "+RetSqlName("ZA9")+" ZA9 "
		cQuery += " INNER JOIN "+RetSqlName("ZA8")+" ZA8 ON (ZA8_FILIAL = '"+xFilial("ZA8")+"' AND ZA8_NUM =  SUBSTRING(ZA9_CHAVE,1,6) AND ZA8_ITEM = SUBSTRING(ZA9_CHAVE,7,2) AND ZA8_SEQ = SUBSTRING(ZA9_CHAVE,9,2) AND ZA8.D_E_L_E_T_ = '') "
		cQuery += " WHERE ZA9_FILIAL = '"+xFilial("ZA9")+"' "
		cQuery += " AND ZA9_NUMOP = '"+cNumOP+"' "
		cQuery += " AND ZA9.D_E_L_E_T_ = ' ' "

		If Select(cAlias) > 0
			dbSelectArea(cAlias)
			dbCloseArea()
		Endif

		TCQUERY cQuery NEW ALIAS &cAlias
	EndIf

	TCSETFIELD(cAlias,"ZA9_PESPRO","N",10,04)
	TCSETFIELD(cAlias,"ZA8_QTDPES","N",10,04)
	TCSETFIELD(cAlias,"ZA8_PESTIN","N",10,04)
	TCSETFIELD(cAlias,"ZA8_QTDPC1","N",10,00)
	TCSETFIELD(cAlias,"ZA8_QTDPC2","N",10,00)

	While !(cAlias)->(Eof())

		nD3_QUANT := 0

		If 	rtrim(cCCusto) == "71150" //.And. !lEmpenho

			If	!Empty((cAlias)->ZA8_CODTEC)
				If	U_CODNOVO((cAlias)->ZA8_CODTEC,4)!= '000000'
					If	Left((cAlias)->ZA8_CODTEC,1) == 'V'
						cTecido := 'Q'+Substr((cAlias)->ZA8_CODTEC,2,29)
					Else
						cTecido := 'T'+Substr((cAlias)->ZA8_CODTEC,2,29)
					EndIf
				Else
					cTecido := (cAlias)->ZA8_CODTEC
				EndIf

			ElseIf	U_CODNOVO((cAlias)->ZA8_COD,4)!= '000000'
				If Substr((cAlias)->ZA8_COD,1,1) == "F"
					cTecido := "T"+Substr((cAlias)->ZA8_COD,2,29)
				ElseIf Substr((cAlias)->ZA8_COD,1,1) == "V"
					cTecido := "Q"+Substr((cAlias)->ZA8_COD,2,29)
				EndIf

			Else
				cTecido := (cAlias)->ZA8_COD
			EndIf

			lTecido := .F.
			SB1->(dbSetOrder(1))
			If SB1->(dbSeek(xFilial("SB1")+cTecido))
				If	SB1->B1_TIPO == 'IF'
					lTecido := .T.
				EndIf
			EndIf

			// Verifica se Existe Empenho do Produto Original, caso exista será limpado
			// o campo do Codigo do Produto Original para não efetuar baixa do estoque duplicado
			// somente pelo Empenho.

			SD4->(DbSetOrder(2))
			SD4->(MsSeek(xFilial('SD4')+cNumOP+cTecido+'P6'))
			If	SD4->(D4_FILIAL + D4_OP + D4_COD + D4_LOCAL) == xFilial('SD4') + cNumOP + cTecido + 'P6'
				lEmpenho := .T.
			EndIf

			If	Select('TZA9') <> 0
				TZA9->(DbCloseArea())
			EndIf

			BeginSql Alias 'TZA9'
				SELECT
					ZA9_NUMOP
				FROM
					%Table:ZA9%
				WHERE
					ZA9_FILIAL = %xFilial:ZA9%
					AND %NotDel%
					AND ZA9_CHAVE = (
						SELECT
							ZA9_CHAVE
						FROM
							%Table:ZA9% ZA9
						WHERE
							ZA9.%NotDel%
							AND ZA9_FILIAL = %xFilial:ZA9%
							AND ZA9_NUMOP = %Exp:cNumOP%
					)
			EndSql

			cOPZA9 := ' '
			While !TZA9->(Eof())

				If	!Empty(cOPZA9)
					cOPZA9 += ', '
				EndIf

				cOPZA9 += "'" + TZA9->ZA9_NUMOP + "' "

				TZA9->(DbSkip())
			EndDo

			If	!Empty(cOPZA9)
				cOPZA9 := '( ' + cOPZA9 + ' )'
			EndIf

			cWhere := ''
			If	!Empty(cOPZA9)
				cWhere := '% (D3_OP IN ' + cOPZA9 + ' OR D3_OPBUDD IN ' + cOPZA9 + ' ) %'
			Else
				cWhere := "% (D3_OP = '" + cNumOP + "' OR D3_OPBUDD = '" + cNumOP + "') %'
			EndIf

			If	Select('TCONS') <> 0
				TCONS->(DbCloseArea())
			EndIf

			BeginSql Alias 'TCONS'
				Column D3_QUANT as Numeric(12, 4)
				SELECT
					SUM(D3_QUANT) AS D3_QUANT
				FROM
					%Table:SD3%
				WHERE
					%NotDel%
					AND D3_FILIAL = %xFilial:SD3%
					AND D3_CF IN ('RE0', 'RE1', 'RE5')
					AND D3_TIPO = 'IF'
					AND D3_ESTORNO = ' '
					AND D3_COD = %Exp:cTecido%
					AND %Exp:cWhere%
			EndSql

			nQtdCons := 0
			If	!TCONS->(Eof())
				nQtdCons := TCONS->D3_QUANT
			EndIf

			// Soma todas as peças registradas para este apontamento inclusive as de 2 Qualidade
			// para somar no total da OP a ser apontada.
			nTotPcs := nQtdPecas + aPerd[NQTDSEG] + aPerd[NQTDLD] + aPerd[NPERDAPC]

			If	((cAlias)->ZA8_QTDPES > nQtdCons) .And. !lRetFac .And. lTecido
				// TSC109 - Marcos - 30/05/2016
				// Deduzir as peças apontadas a mais do que o total da OP, que não devem consumir tecido
				SC2->(MsSeek(xFilial('SC2')+cNumOP))
				If	nQtdLiber > 0
					If	(nQtdLiber == nTotPcs)
						nQtdLiber := (nTotPcs + (SC2->C2_QUANT - (SC2->C2_QUJE - SC2->C2_PERDA)))
					EndIf
				EndIf

				If	nTotPcs > 0
					nD3_Quant := (((cAlias)->ZA8_QTDPES - (cAlias)->ZA8_PESTIN) / ((cAlias)->ZA8_QTDPC1 + (cAlias)->ZA8_QTDPC2)) * (Abs(nTotPcs - nQtdLiber))
				ElseIf	(nTotPcs == 0) .And. (nQtdRetPr > 0) .And. ((SC2->C2_QUJE + SC2->C2_PERDA + nQtdRetPr) == SC2->C2_QUANT)
					nD3_Quant := ((((cAlias)->ZA8_QTDPES - (cAlias)->ZA8_PESTIN) / ((cAlias)->ZA8_QTDPC1 + (cAlias)->ZA8_QTDPC2)) * nQtdRetPr)
				EndIf

				If	(nD3_Quant + nQtdCons) > (cAlias)->ZA8_QTDPES
					nD3_Quant := (cAlias)->ZA8_QTDPES - nQtdCons
				EndIf
			Else
				nD3_Quant := 0
			EndIf

		ElseIf	rtrim(cCCusto) = '71160'

			If	!lRetFac
				nD3_Quant := (cAlias)->ZA9_PESPRO
				cTecido   := (cAlias)->ZA8_COD
			Else
				nD3_Quant := 0
				cTecido   := Space(TamSx3('B1_COD')[1])
			EndIf

		Else

			nD3_Quant := 0
			cTecido	  := Space(TamSx3('B1_COD')[1])

		Endif

		//Manutenção - 11/2021
		//Retirado esse posicione pois não esta sendo usado, somente tomando tempo de processamento.
		//cLocPad := Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_LOCPAD") //SB1->B1_LOCPAD

		Do Case
			Case rtrim(cCCusto) == '71150'
				cLocPad	:= 'P6'
			Case rtrim(cCCusto) == '71160'
				cLocPad := 'P7'
		EndCase


		// Para o consumo do tecido, desconsidera o peso do apontamento de segunda qualidade
		// quando tiver peso e quantidade informada na ZAB. (Segunda Qualidade)
		/////////////////////////////////////////////////////////////////////////////////////////////
		If 	nD3_Quant >= nPerdKg
			nD3_Quant := (nD3_Quant - nPerdKg)
		EndIf

		dbSelectArea("SD3")
		If nD3_Quant > 0 .And. !lEmpenho

			aItens := {}
			aCab := {}

			dbSelectArea('SD3')
			aCab := { 	{"D3_TM"    	,GetMv("MV_TMCONST")				,Nil},;
				{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
				{"D3_CC" ,cCCusto, NIL},;
				{"D3_EMISSAO"	,MsDate()							,Nil}}


			aadd(aItens, {	{"D3_COD"		,cTecido			,Nil},;
				{"D3_UM"    	,Posicione("SB1",1,xFilial("SB1")+cTecido,"SB1->B1_UM")   		,Nil},;
				{"D3_QUANT" 	,nD3_Quant    	,Nil},;
				{"D3_OP"		,cNumOP				,Nil},;
				{"D3_LOCAL" 	,cLocPad			,Nil},;
				{"D3_SEQBUDD"	,cSeqBudd			,nil}})

			lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
			lMsErroAuto := .F.  //necessario a criacao, pois sera

			MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
			If lMsErroAuto
				DisarmTransaction()

				If !__AUTO
					MostraErro()
				Else
					cErro := "[BUD744] - ERRO - Erro na rotina"
					U_BUD1427(cErro)
				EndIf
			EndIf

		EndIf

		dbSelectArea(cAlias)
		(cAlias)->(dbSkip())

	EndDo

	cProduto := cProdAnt
	cData := Dtos(MsDate())
	cHora := Left(Time(),5)
	If rtrim(cCCusto) = "71150"
		nQtdAponta := nQtdPecas+aPerd[NQTDSEG]+aPerd[NQTDLD]
	Else
		nQtdAponta := nQtdPecas+aPerd[NQTDSEG]
	Endif

	//Begin Transaction

	// Sistema protheus não aceita encerrar a OP com quantidade inferior, para isso eu precis forçar a quantidade:
	If rtrim(cCCusto) = "71150" .And. nQtdRetPr > 0
		If nQtdTot > 0 .And. nQtdRetPc > 0
			/*
				cUpdate := "UPDATE "+RetSqlName("SC2")+" SET C2_QTDPCS = '"+AllTrim(Str(nQtdRetPc))+"' "
				cUpdate += "							   , C2_QTDRET = '"+AllTrim(Str(nQtdRetPc))+"' "
				cUpdate += "							   , C2_OBS = '"+AllTrim(Str(nQtdRetPc))+" RETALHO(S)' "
				cUpdate += "WHERE SC2010.D_E_L_E_T_ <> '*' "
				cUpdate += "AND C2_FILIAL = '"+xFilial("SC2")+"' "
				cUpdate += "AND (C2_NUM+C2_ITEM+C2_SEQUEN) = '"+cNumOP+"' "
				TCSQLEXEC(cUpdate)
			*/
			SC2->(dbSetOrder(1))
			SC2->(dbSeek(xFilial("SC2")+cNumOP))
			RecLock("SC2",.F.)
			SC2->C2_QTDPCS 	:= nQtdRetPc
			SC2->C2_QTDRET 	:= nQtdRetPc
			SC2->C2_OBS 	:= AllTrim(Str(nQtdRetPc))+" RETALHO(S)"
			SC2->(MsUnLock())
		EndIf
	EndIf

	//REALIZA O APONTAMENTO DA PRODUCAO
	If	(nQtdRetPr <> 0) .Or. (nQtdAponta <> 0)
		/* 11/2021
			// Não prossigo se o registro esteja travado:
			While U_zLockSB2(cProduto, cAlmox, .T.)
				// Caso o registro esteja travado, não prossigo...
				U_BUD1427("[BUD744] - Registro ["+AllTrim(cProduto)+"]/["+AllTrim(cAlmox)+"] esta travado...")
			EndDo
		*/

		aRot250 := {{"D3_TM"     	, "001"			 				, Nil},;
			{"D3_OP"     	, cNumOP     					, Nil},;
			{"D3_COD"    	, cProduto	 					, Nil},;
			{"D3_UM"    	, cUMProduto 					, Nil},;
			{"D3_QUANT"  	, nQtdAponta 					, Nil},;
			{"D3_LOCAL"  	, cAlmox		 				, Nil},;
			{"D3_EMISSAO"	, Stod(cData)					, Nil},;
			{"D3_PERDA"		, nQtdRetPr /*aPerd[NPERDAPC]*/	, Nil},;
			{"D3_USUARIO"	, cUserName	 					, Nil},;
			{"D3_SEQBUDD"  	, cSeqBudd						, Nil}}

		lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
		lMsErroAuto := .F.  // necessario a criacao, pois sera utilizado na verificacao do retorno da rotina
		MSExecAuto({|x,y| mata250(x,y)},aRot250,3)
		_libGaiola := .T.
		If lMsErroAuto
			_libGaiola := .F.
			DisarmTransaction()

			If !__AUTO
				/*Enviar o erro via e-mail*/
				////////////////////////////
				/*
					_aErro := GetAutoGrLog(MostraErro())
					For _nI := 1 To Len(_aErro)
						_cMsg += _aErro[_nI] + CRLF
					Next _nI
				*/
				_cMsg := MostraErro()
				_B744Mail(cNumOP,cProduto,cUserName,_cMsg)

				MsgStop("ATENÇÃO - APONTAMENTO NÃO REALIZADO. FAVOR TENTAR NOVAMENTE!")
				MostraErro()
			Else
				cErro := "[BUD744] - ERRO - Erro na rotina"
				U_BUD1427(cErro)
			EndIf
			//Break - Comentado por Paulo Afonso em 10/08/20177

			RestArea(aSD3)
			//Adicionado em função do travamento - 22/11/2022
			Break

		Else
			//****************************** limpar o D3
			RestArea(aSD3)
			If _libGaiola
				// Acrescenta quantidade produzida na SC6:
				cUpd := ""
				cUpd += "UPDATE SC6 SET C6_QTDPROD = (C6_QTDPROD + C2_QUJE) "
				cUpd += "FROM SC6010 SC6, SC2010 SC2 "
				cUpd += "WHERE C6_FILIAL = '01' "
				cUpd += "AND C2_FILIAL = '01' "
				cUpd += "AND C2_NUMPED <> '' "
				cUpd += "AND C2_NUMPED = C6_NUM "
				cUpd += "AND C2_ITEMPED = C6_ITEM "
				cUpd += "AND C2_PRODUTO = C6_PRODUTO "
				cUpd += "AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+AllTrim(cNumOP)+"' "
				cUpd += "AND SC6.D_E_L_E_T_ = '' "
				cUpd += "AND SC2.D_E_L_E_T_ = '' "
				TCSQLEXEC(cUpd)

				// Thiago 02/05/2014 - Forçar atualização do C2_SITAOP para Embalagem:
				SC2->(dbSetOrder(1))
				SC2->(dbSeek(xFilial("SC2")+cNumOP))
				If SC2->C2_SITAOP == "1" .Or. SC2->C2_SITAOP == "2"
					If SC2->(Found())
						RecLock("SC2",.F.)
						SC2->C2_SITAOP := "4"
						SC2->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
					EndIf
				EndIf
				// Fim - Thiago 02/05/2014 - Forçar atualização do C2_SITAOP para Embalagem:

				// Thiago 03/12/2014 - Atualizar a observação da OP:
				If AllTrim(SC2->C2_CC) == "71150"
					If ((SC2->C2_QUJE) < SC2->C2_QUANT .And. Empty(SC2->C2_DATRF) .And. SC2->C2_SITAOP <> '5')
						If SC2->(Found())
							RecLock("SC2",.F.)
							SC2->C2_OBS := "AGUARDADO POR " + AllTrim(cUserName)
							SC2->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
						EndIf
					EndIf

					// Alimento metragem consumida da embalagem:
					If  Empty(cParamSeg)

						SC2->(dbSetOrder(1))
						SC2->(dbSeek(xFilial("SC2")+cNumOP))
						RecLock("SC2",.F.)
						SC2->C2_OBSLIB := AllTrim(Str(nQtdAponta))+" PC(S) "+AllTrim(Str(U_BUD1256()))+"CM"
						SC2->(MsUnLock())

					EndIf
				EndIf

				if SC2->C2_QUJE > 0


					SC2->(dbSetOrder(1))
					SC2->(dbSeek(xFilial("SC2")+cNumOP))
					RecLock("SC2",.F.)
					SC2->C2_STCOLET := '0'
					SC2->(MsUnLock())

				EndIf

				If	Select('TSD3') > 0
					dbSelectArea('TSD3')
					dbCloseArea()
				EndIf

				nTotPec := nQtdPecas+aPerd[NQTDSEG]+aPerd[NQTDLD]
				BeginSql Alias 'TSD3'
					%noparser%

					SELECT
						D3_DOC
					FROM
						%Table:SD3%
					WHERE
						%NotDel%
						AND D3_FILIAL = %xFilial:SD3%
						AND D3_EMISSAO = %exp:cData%
						AND D3_OP = %exp:cNumOP%
						AND D3_QUANT = %exp:nTotPec%
						AND D3_USUARIO = %exp:cUserName%
						AND D3_TM = '001'
						AND D3_ESTORNO = ' '
						AND LEFT(D3_OP, 6) BETWEEN '400000' AND '5ZZZZZ'
						AND D3_HORA >= %exp:cHora%
				EndSql

				cD3_DOC := Space(TamSx3('D3_DOC')[1])
				If !TSD3->(Eof())
					cD3_DOC := TSD3->D3_DOC
					For j:=1 To Len(aRecSeg)
						ZAB->(dbGoto(aRecSeg[j]))
						RecLock("ZAB",.F.)
						ZAB->ZAB_PROCES := "S"
						ZAB->ZAB_DOC    := cD3_DOC
						If	ZAB->(FieldPos('ZAB_SEQBUD')) > 0
							ZAB->ZAB_SEQBUD := cSeqBudd
						EndIf
						ZAB->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
					Next j

					For j:=1 To Len(aRecLD)
						ZAB->(dbGoto(aRecLD[j]))
						RecLock("ZAB",.F.)
						ZAB->ZAB_PROCES := "S"
						ZAB->ZAB_DOC    := cD3_DOC
						If	ZAB->(FieldPos('ZAB_SEQBUD')) > 0
							ZAB->ZAB_SEQBUD := cSeqBudd
						EndIf
						ZAB->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
					Next j

					For j:=1 To Len(aRecPer)
						ZAB->(dbGoto(aRecPer[j]))
						RecLock("ZAB",.F.)
						ZAB->ZAB_PROCES := "S"
						ZAB->ZAB_DOC    := cD3_DOC
						If	ZAB->(FieldPos('ZAB_SEQBUD')) > 0
							ZAB->ZAB_SEQBUD := cSeqBudd
						EndIf
						ZAB->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
					Next j

				EndIf

				// Alan
				If lLibera
					ZA9->(dbSetOrder(2))
					ZA9->(dbSeek(xFilial("ZA9")+rtrim(cNumOp)))
					While ZA9->(!Eof()) .and. rtrim(ZA9->ZA9_NUMOP) == rtrim(cNumOp)
						RecLock("ZA9",.F.)
						ZA9->ZA9_USUAPR := cUsuAx
						ZA9->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
						ZA9->(dbSkip())
					End
				EndIf

				If (aPerd[NQTDSEG] > 0) .or. (aPerd[NQTDLD] > 0) .and. rtrim(cCCusto) = "71150"

					//ATUALIZA SALDO DA OP NA TABELA DE RELACIONAMENTO ZA9
					cNumRast	:= ""
					ZA9->(dbSetOrder(2))
					ZA9->(dbSeek(xFilial("ZA9")+rtrim(cNumOp)))
					While ZA9->(!Eof()) .and. rtrim(ZA9->ZA9_NUMOP) == rtrim(cNumOp)
						cNumRast	:= "ZA9|"+ZA9->ZA9_CHAVE
						RecLock("ZA9",.F.)
						ZA9->ZA9_QTPROD -= (aPerd[NQTDSEG]+aPerd[NQTDLD])
						ZA9->(MsUnLock()) //Alterado por Paulo Afonso em 10/08/2017
						ZA9->(dbSkip())
					EndDo

					If aPerd[NQTDSEG] > 0
						ZAA->(dbSetOrder(1))
						ZAA->(dbSeek(xFilial("ZAA")+cProduto+cAlmox+"1"))
						If !ZAA->(Found())
							ZAA->(dbSetOrder(1))
							ZAA->(dbSeek(xFilial("ZAA")+cProduto+space(2)+"1"))
						Endif

						If ZAA->(Found())
							SB2->(dbSetOrder(1))
							If	Empty(cLocSeg)
								If !SB2->(dbSeek(xFilial("SB2")+If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG)))
									CriaSB2(ZAA->ZAA_CODSEG,If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG))
								Endif
							Else
								If !SB2->(dbSeek(xFilial("SB2")+ZAA->ZAA_CODSEG+cLocSeg))
									CriaSB2(ZAA->ZAA_CODSEG,cLocSeg)
								Endif
							EndIf
							//Begin Transaction
							//If !lNovoCons 	// -- Thiago 16/12/2010. No novo consumo, já é efetuado o apontamento de Segunda acima.
							If	!Empty(cLocSeg)
								U_BUD745(cProduto,cAlmox,nil,ZAA->ZAA_CODSEG,cLocSeg,nil,aPerd[NQTDSEG],0,Stod(cData),.F., nil, "")
							Else
								U_BUD745(cProduto,cAlmox,nil,ZAA->ZAA_CODSEG,If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG),nil,aPerd[NQTDSEG],0,Stod(cData),.F., nil, "")
							EndIf
							//EndIf
							//End Transaction
							For j:=1 To Len(aRecSeg)
								ZAB->(dbGoto(aRecSeg[j]))
								RecLock('ZAB',.F.)
								ZAB->ZAB_CODSEG := ZAA->ZAA_CODSEG
								ZAB->(MsUnlock())
							Next j
						Endif
					Endif

					If aPerd[NQTDLD] > 0
						//msgalert("entrou no LD")
						ZAA->(dbSetOrder(1))
						ZAA->(dbSeek(xFilial("ZAA")+cProduto+cAlmox+"2"))
						If ZAA->(!Found())
							ZAA->(dbSetOrder(1))
							ZAA->(dbSeek(xFilial("ZAA")+cProduto+space(2)+"2"))
						Endif

						If ZAA->(Found())
							SB2->(dbSetOrder(1))
							If	Empty(cLocSeg)
								If !SB2->(dbSeek(xFilial("SB2")+If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG)))
									CriaSB2(ZAA->ZAA_CODSEG,If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG))
								Endif
							Else
								If !SB2->(dbSeek(xFilial("SB2")+ZAA->ZAA_CODSEG+cLocSeg))
									CriaSB2(ZAA->ZAA_CODSEG,cLocSeg)
								Endif
							EndIf
							//Begin Transaction
							//If !lNovoCons 	// -- Thiago 16/12/2010. No novo consumo, já é efetuado o apontamento de Segunda acima.
							If	!Empty(cLocSeg)
								U_BUD745(cProduto,cAlmox,nil,ZAA->ZAA_CODSEG,cLocSeg,nil,aPerd[NQTDLD],0,Stod(cData),.F., nil, "")
							Else
								U_BUD745(cProduto,cAlmox,nil,ZAA->ZAA_CODSEG,If(Empty(ZAA->ZAA_LOCSEG),cAlmox,ZAA->ZAA_LOCSEG),nil,aPerd[NQTDLD],0,Stod(cData),.F., nil, "")
							EndIf
							//EndIf
							//End Transaction
							For j:=1 To Len(aRecLD)
								ZAB->(dbGoto(aRecLD[j]))
								RecLock('ZAB',.F.)
								ZAB->ZAB_CODSEG := ZAA->ZAA_CODSEG
								ZAB->(MsUnlock()) //Alterado por Paulo Afonso em 10/08/2017
							Next j
						Endif
					Endif
				Endif

				If aPerd[NPERDAPC] > 0 .and. rtrim(cCCusto) = "71160"

					//ATUALIZA SALDO DA OP NA TABELA DE RELACIONAMENTO ZA9
					ZA9->(dbSetOrder(2))
					ZA9->(dbSeek(xFilial("ZA9")+rtrim(cNumOp)))
					While ZA9->(!Eof()) .and. rtrim(ZA9->ZA9_NUMOP) == rtrim(cNumOp)
						RecLock("ZA9",.F.)
						ZA9->ZA9_QTPROD -= (aPerd[NPERDAPC])
						ZA9->(MsUnLock())
						ZA9->(dbSkip())
					EndDo

				Endif

				// Thiago 09/08/2017:
				//U_BUD1278(cProduto, cAlmox)

				// Caso chegou até aqui, permito apontar a ZBV:
				lApontaZBV	:= .T.

				U_BUD1427(FunName()+' - Ordem de Producao Apontada nr. '+cNumOp)
			EndIf
		EndIf

		//End Transaction //Roberto Avaliar

		//Como a função abaixo foi comentada para não processar no hydra, Jonas repassou o bloco do Hydra
		//para dar update por dentro do Protheus  - 28/11/2022
		If !Empty(SC2->C2_DATRF)
			_cOpHydra := SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
			cUpd := "UPDATE ZA8010 "
			cUpd += "SET ZA8_STATUS = '9' "
			cUpd += "FROM ZA8010 ZA8, ZA9010 ZA9 "
			cUpd += "WHERE ZA8_FILIAL = '" + xFilial("ZA8") + "' "
			cUpd += "AND ZA8.D_E_L_E_T_ = '' "
			cUpd += "AND ZA8_NUM+ZA8_ITEM+ZA8_SEQ = ZA9_CHAVE "
			cUpd += "AND ZA9_FILIAL = '" + xFilial("ZA9") + "' "
			cUpd += "AND ZA9.D_E_L_E_T_ = '' "
			cUpd += "AND ZA9_NUMOP =  '"+_cOpHydra+"' "
			cUpd += "AND ZA8_STATUS != '5' "
			TCSQLEXEC(cUpd)
		EndIf

		//Adicionado em função do travamento - 22/11/2022
		If !lMsErroAuto

			cQuery := ""
			cQuery += " SELECT ZA9_CHAVE  "
			cQuery += " FROM ZA9010 "
			cQuery += " WHERE ZA9_FILIAL = '" + xFilial("ZA9") + "' "
			cQuery += " AND D_E_L_E_T_ = '' "
			cQuery += " AND RTRIM(ZA9_NUMOP) = '"+cNumOp+"' "

			If (Select("B44ZA9") <> 0)
				dbSelectArea("B44ZA9")
				dbCloseArea()
			EndIf

			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "B44ZA9"

			dbSelectArea("B44ZA9")
			dbGoTop()
			While !Eof()

				cOp		:= Left(AllTrim(B44ZA9->ZA9_CHAVE), 8)+"001"
				cSeq	:= Right(AllTrim(B44ZA9->ZA9_CHAVE), 2)

				cQuery := ""
				cQuery += "UPDATE " + RETSQLNAME("ZA3") + " SET ZA3_LOCATU = '"+cAlmox+"' "
				cQuery += "WHERE D_E_L_E_T_ <> '*' "
				cQuery += "AND ZA3_OP = '" + cOp + "' "
				cQuery += "AND ZA3_SEQ = '" + cSeq + "' "
				nStatus := TCSQLEXEC(cQuery)
				If	(nStatus < 0)
					U_BUD1427("Erro na Atualização do Local Atual da Peça " + cOP + "/" + cSeq + " - " + TCSQLError())
				EndIf

				dbSelectArea("B44ZA9")
				B44ZA9->(dbSkip())

			EndDo

			// Altero status dos itens da gaiola em andamento:
			If lGaiolaObr .And. !lMsErroAuto
				TCSQLEXEC("UPDATE ZDU010 SET ZDU_STATUS = 'APONTAMENTO FINALIZADO' WHERE ZDU_FILIAL = '' AND ZDU_NUMOP = '"+cNumOP+"' AND ZDU_STATUS = 'EM ANDAMENTO' AND ZDU010.D_E_L_E_T_ = '' ")
			EndIf

			IF lApontaZBV .And. !lMsErroAuto
				// Efetuo lançamento de apontamento 13/09/2018:
				// Definição das variáveis para apontamento e impressão:
				dDataAp	:= MsDate()
				cHoraAp	:= Substr(Time(),1,5)
				nQtdAp	:= nQtdPecas
				// Inclusão na tabela de controle:
				RecLock("ZBV", .T.)
				ZBV->ZBV_FILIAL 	:= xFilial("ZBV")
				ZBV->ZBV_OP		 	:= cNumOp
				ZBV->ZBV_DATA		:= dDataAp
				ZBV->ZBV_HORA		:= cHoraAp
				ZBV->ZBV_OPERAD		:= AllTrim(Upper(cUserName))
				ZBV->ZBV_QTD		:= nQtdAp
				ZBV->ZBV_STATUS		:= 'APONTAMENTO EFETUADO'
				ZBV->ZBV_CODGA 		:= cCodGaiola
				ZBV->ZBV_ALMOX      := cAlmox
				ZBV->(MsUnLock())

				// Atualizo código da gaiola:
				//TCSQLEXEC("UPDATE ZBV010 SET ZBV_CODGA = '"+cCodGaiola+"' WHERE ZBV010.R_E_C_N_O_ = (SELECT ISNULL(MAX(R_E_C_N_O_),0) FROM ZBV010 (NOLOCK)) ")

				// Chamo rotina para imprimir o código de barras:
				If !__AUTO
					U_BUD1315(cNumOp, dDataAp, cHoraAp, nQtdAp)
				EndIf
			EndIf

			If !lMsErroAuto
				U_BUD1393(cNumOp, "DESCIDA")
				//StartJob("U_B1393",GetEnvServer(),.F.,cNumOp,"DESCIDA")
			EndIf

			lLibera		:= .F.
			lAltAlmox	:= .F.
			If 	Empty(cParamSeg)
				oGet2:Disable()
				oGet1:Enable()
				oGet7:Enable()
				oGetG:Disable()
				oGet1:SetFocus()

				If	Type("oBtn0") == "O"
					oBtn0:Disable()
				EndIf
				oBtn1:Disable()
				oBtn2:Disable()

				lBEnc := .F.
				nProg	:= 1
				While !Empty(ProcName(nProg))
					If 	"BENCERRA" $ Upper(AllTrim(ProcName(nProg)))
						lBEnc := .T.
						Exit
					Endif
					nProg ++
				EndDo

				If	!lBEnc //!IsInCallStack('bEncerra')
					cNumop := space(13)
				EndIf
			EndIf

			LimparCampos()

			PutMv("BD_1193FLA", "")

			If !Empty(cParamSeg)
				lFecha	:= .T.
				B744Cancela()

				lClose := .T.
				lFecha := .T.
			else
				oGet1:SetFocus()
			EndIf
		EndIF
	EndIf

Return(lMsErroAuto)

/*
			ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
			±±ºPrograma  ³ B744Cancelaº Autor ³Edinei Sanchez Milekº Data ³ 28/10/08  º±±
			±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
			±±ºDescricao ³ Valida Cancelamento da tela de apontamento                 º±±
			±±º          ³                                                            º±±
			±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
			±±ºUso       ³ AP6 IDE                                                    º±±
			±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
			±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
			ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function B744Cancela()

	If nQtdPecas > 0 .and. (rtrim(cCCusto) != "71180" .or. rtrim(cCCusto) != "71190")
		lRet := .F.
		If	Empty(cParamSeg)
			B744TocaSom()
			nAviso		:= 3
			lMsHelpAuto := .F.
			while nAviso == 3
				nAviso	:= AVISO("Atenção", "Existem peças que já foram lidas, você precisa confirmar o apontamento. Você tem certeza que deseja sair e cancelar o apontamento?", {"Cancelar", "Confirma", "Escolha"}, 3)
				//OBS: a opção Escolha existe para o operador não confirmar a mensagem usando o leitor de codigo de barras por engano.
			EndDo
			If nAviso == 2
				//Gravo Log quando usuário confirmar cancelamento com peças lidas:
				_cNumOPLog 	  := Alltrim(cNumOP)
				_cQtdPecasLog := Alltrim(Str(nQtdPecas))
				_cNomeOperLog := Alltrim(UsrRetName(RetCodUsr()))
				If nQtdPecas > 1
					_B744Log('Foi cancelado apontamento da OP '+_cNumOPLog+', com a quantidade de '+_cQtdPecasLog+' peças lidas. Ação feita pelo operador ' + _cNomeOper)
				Else
					_B744Log('Foi cancelado apontamento da OP '+_cNumOPLog+', com a quantidade de '+_cQtdPecasLog+' peça lida. Ação feita pelo operador ' + _cNomeOper)
				EndIf

				lRet := .T.
				lClose := .T.
				lFecha := .T.
				LimparCampos()
				Return
			EndIf

			// If MsgYesNo("Existem peças que já foram lidas, que precisa confirmar o apontamento. Você tem certeza que deseja sair e cancelar o apontamento? ", "Atenção!")

			// 	//Gravo Log quando usuário confirmar cancelamento com peças lidas:
			// 	_cNumOPLog 	  := Alltrim(cNumOP)
			// 	_cQtdPecasLog := Alltrim(Str(nQtdPecas))
			// 	_cNomeOperLog := Alltrim(UsrRetName(RetCodUsr()))
			// 	If nQtdPecas > 1
			// 		_B744Log('Foi cancelado apontamento da OP '+_cNumOPLog+', com a quantidade de '+_cQtdPecasLog+' peças lidas. Ação feita pelo operador ' + _cNomeOper)
			// 	Else
			// 		_B744Log('Foi cancelado apontamento da OP '+_cNumOPLog+', com a quantidade de '+_cQtdPecasLog+' peça lida. Ação feita pelo operador ' + _cNomeOper)
			// 	EndIf

			// 	lRet := .T.
			// 	lClose := .T.
			// 	lFecha := .T.
			// 	LimparCampos()
			// 	//Leave1Code(cNumOP) //Leave1Code está dentro do LimparCampos()
			// 	//U_BUD1427('Liberação do Codigo de Apontamento de OP '+cNumOP)
			// 	Return
			// EndIf

			oGet3:SetFocus()

		EndIf
	Else
		//If	!IsInCallStack("U_BUD1193") .And. !IsInCallStack("U_BUD663") .And. !IsInCallStack("U_BD1391Proc") .And. !__AUTO .And. Empty(cParamSeg)
		LimparCampos()
		//EndIf
		lClose := .T.
		lFecha := .T.
	Endif

	// dbSelectArea('SC2')
	// dbSetOrder(1)
	// MsSeek(xFilial('SC2')+cNumOP)

	//Leave1Code(cNumOP) //Leave1Code está dentro do LimparCampos()
	//U_BUD1427('Liberação do Codigo de Apontamento de OP '+cNumOP)

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744Usuarioº Autor ³ Alan Leandro       º Data ³           º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Valida o usuario e senha do aprovador do apontamento.      º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744Usuario(lAdmin)
	/*****************************/
	Local lRet		:= .F., lOk, _i
	Local aUsrInf	:= {}

	If Empty(cUsuAx) .Or. Empty(cSenhaAx)
		Return (lRet := .F.)
	EndIf

	If	RetCodUsr() == '000000'
		Return (lRet := .T.)
	EndIf

	PswOrder(2)
	If PswSeek(cUsuAx,.T.)
		lOk := PswName(cSenhaAx)

		/* INCLUIDO ESTES USUÁRIOS COM O GRUPO EXISTENTE NO PARAMETRO MV_GRPAPON
		If (alltrim(upper(subs(cUsuario,7,5))) == "SUELI" .OR. alltrim(upper(subs(cUsuario,7,4))) == "JOSE" .OR. alltrim(upper(subs(cUsuario,7,6))) == "EDVANE")
		lRet := .T.
		Return lRet
		EndIf
		*/

		If lOk
			If lAdmin // Verifica se necessita mapear os grupos dos usuários:

				aUsrInf := PswRet()
				For _i := 1 To Len(aUsrInf[1][10])
					//If Upper(Alltrim(GrpRetName(aUsrInf[1][10][_i]))) $ Upper(GetMv("MV_GRPAPON"))
					If 	RTRim(Upper(AllTrim(aUsrInf[1][10][_i]))) $ Upper(GetMv("MV_GRPAPON"))
						lRet := .T.
						Exit
					EndIf
				Next _i

				If !lRet
					MsgStop("Usuário não autorizado!!!")
				EndIf
			Else
				lRet := .T.
			EndIf
		Else
			MsgStop("Senha Inválida!!!")
		EndIf
	Else
		MsgStop("Usuário Inválido!!!")
	EndIf

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744TocaSomº Autor ³Edinei Sanchez Milekº Data ³19/11/2008 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ toca som                                                   º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744TocaSom()
	//nRet := ShellExecute("Open","TADA.WAV","","C:\", 1 )

	If Empty(cParamSeg)
		nRet := ShellExecute("Open","C:\Som_Costura\Erro_Inv.exe","","C:\", 1 )
	EndIf

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744Encer  º Autor ³Marcos A Schoeffel  º Data ³06/06/2016 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Encerra OP                                                 º±±
	±±º          ³                                                            º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function B744Encerra()

	Local aArea  := GetArea()
	Local aAreaD3:= SD3->(GetArea())
	Local aAreaC2:= SC2->(GetArea())
	Local aAreaA9:= ZA9->(GetArea())
	Local cAlias := GetNextAlias()

	Local lFechaEnc := .F.
	Local lCancEnc  := .F.
	Local lRet		:= .F.

	Private cPriMatr  := Space(08)
	Private cSegMatr  := Space(08)

	While .T.
		_oDlgEnc := TDialog():New(0,0,200,250,"Autorizado Encerramento O.P.",,,,,,,,,.T.,,,,,)
		_oDlgEnc:lCentered := .T.
		_oDlgEnc:lEscClose := .F.  //nao fecha tela com esc
		_oDlgEnc:nStyle:=128      	//sem x no canto superior direito

		TSay():New(20,10,{|| "Matrícula     : " },_oDlgEnc,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oPriMatr := TGet():New(20,60,bSetGet(cPriMatr),_oDlgEnc,60,10,,,,,,,,.T.,,,,,,,,.T.,)
		oPriMatr:bValid := {|| lRet := B744VldMat(cPriMatr, cSegMatr, 1) }
		TSay():New(35,10,{|| "Conf.Matrícula: " },_oDlgEnc,,,,,,.T.,CLR_BLACK,CLR_WHITE)
		oSegMatr := TGet():New(35,60,bSetGet(cSegMatr),_oDlgEnc,60,10,,,,,,,,.T.,,,,,,,,.T.,)
		oSegMatr:bValid := {|| lRet := B744VldMat(cPriMatr, cSegMatr, 2)}
		SButton():New(60,20,01,{|| (lCancEnc := .F., lFechaEnc := .T., _oDlgEnc:End()) }, _oDlgEnc,,"Confirma")
		SButton():New(60,80,02,{|| (lCancEnc := .T., lFechaEnc := .T., _oDlgEnc:End()) }, _oDlgEnc,,"Cancela")

		_oDlgEnc:Activate(,,,,,,)

		If	lFechaEnc
			Exit
		EndIf
	EndDo

	If	!lCancEnc

		If	Select(cAlias) <> 0
			(cAlias)->(DbCloseArea())
		EndIf

		BeginSql Alias cAlias
			SELECT
				MAX(D3.R_E_C_N_O_) AS NREG
			FROM
				%Table:SC2% C2 (NOLOCK)
			INNER JOIN %Table:SD3% D3 (NOLOCK)
			ON D3_FILIAL = %xFilial:SD3%
				AND D3_OP = C2_NUM + C2_ITEM + C2_SEQUEN
				AND D3_TM = '001'
				AND D3_ESTORNO = ' '
				AND D3.%NotDel%
			WHERE
				C2.%NotDel%
				AND C2_FILIAL = %xFilial:SC2%
				AND (C2_NUM + C2_ITEM + C2_SEQUEN) = %Exp:RTrim(cNumOP)%
				AND C2_DATRF = ' '
		EndSql

		If	!(cAlias)->(Eof()) .And. !Empty((cAlias)->NREG)

			DbSelectArea('SD3')
			DbGoto((cAlias)->NREG)

			/* 11/2021
			// Não prossigo se o registro esteja travado:
			While U_zLockSB2(SD3->D3_COD, SD3->D3_LOCAL, .T.)
				// Caso o registro esteja travado, não prossigo...
				U_BUD1427("[BUD744] - Registro ["+AllTrim(SD3->D3_COD)+"]/["+AllTrim(SD3->D3_LOCAL)+"] esta travado...")
			EndDo
			*/

			aVetor  := {{"D3_TM",		SD3->D3_TM,			NIL},;
				{"D3_QUANT",				SD3->D3_QUANT,		NIL},;
				{"D3_DOC",					SD3->D3_DOC,		NIL},;
				{"D3_COD",					SD3->D3_COD,		NIL},;
				{"D3_LOCAL",				SD3->D3_LOCAL,		NIL},;
				{"D3_OP",					SD3->D3_OP,			NIL}}

			lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
			lMsErroAuto := .F.
			MSExecAuto({|x,y| mata250(x, y)}, aVetor, 7 )
			If (lMsErroAuto)
				//Comentado por Paulo Afonso em 10/08/2017
				DisarmTransaction()

				If !__AUTO
					MsgStop("ATENÇÃO - APONTAMENTO NÃO REALIZADO. FAVOR TENTAR NOVAMENTE!!!")
					MostraErro()
				Else
					cErro := "[BUD744] - ERRO - Erro na rotina"
					U_BUD1427(cErro)
				EndIf
			Else
				If	ZA9->(FieldPos('ZA9_USUENC')) <> 0
					ZA9->(DbSetOrder(6))
					ZA9->(MsSeek(xFilial('ZA9')+cNumop))
					If	ZA9->(Found())
						RecLock('ZA9',.F.)
						ZA9->ZA9_USUENC := cPriMatr
						ZA9->(MsUnlock()) //Alterado por Paulo Afonso em 10/08/2017
					EndIf
				EndIf
			Endif

		EndIf

	EndIf

	RestArea(aAreaA9)
	RestArea(aAreaC2)
	RestArea(aAreaD3)
	RestArea(aArea)

	cNumop := space(13)
	oGet1:SetFocus()

Return

Static Function B744VldMat(cPr, cSeg, nOrd)

	Local lRet := .T.
	Local cAutor := GetMv('BD_AUTOENC')

	If	!Empty(cAutor)
		If	(nOrd == 1)
			If	!Empty(cPr)
				If	!(cPr $ cAutor)
					Alert('Matrícula informada não está habilitada para Autorizar o Encerramento de OP !!!')
					lRet := .F.
				EndIf
			Else
				Alert('Verifique, Não foi preenchido corretamente o campo Matrícula !!!')
				lRet := .F.
			EndIf
		ElseIf	!Empty(cSeg)
			If	(cPr <> cSeg)
				Alert('A Matrícula informada no campo Conf.Matrícula não é igual a anterior, Corrija !!!')
				lRet := .F.
			EndIf
		Else
			Alert('É necessário o preenchimento de ambos os campos Matrícula e Conf.Matrícula com informação igual !!!')
			lRet := .F.
		EndIf
	Else
		Alert('Não existe nenhum matrícula cadastrada no parâmetro BD_AUTOENC. Favor verificar com o Administrador do Protheus !!!')
		lRet := .F.
	EndIf

Return lRet

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744AltAlmox Autor ³Alan Leandro        º Data ³           º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Chama tela para usuario e senha para liberar o campo      º±±
	±±º          ³ Almoxarifado para alteracao.                               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744AltAlmox()
	/******************************/
	Local lFechaAlm := .F.
	Local lCancAlm  := .F.
	Private cUsuAlm		:= Space(14)
	Private cSenhaAlm	:= Space(10)

	If lAltAlmox
		MsgStop("Campo já liberado para digitação!!!")
		Return
	EndIf

	_oDlgAlm := TDialog():New(0,0,200,250,"Liberacao",,,,,,,,,.T.,,,,,)
	_oDlgAlm:lCentered := .T.
	_oDlgAlm:lEscClose := .F.  //nao fecha tela com esc
	_oDlgAlm:nStyle:=128      	//sem x no canto superior direito

	TSay():New(20,10,{|| "Usuario: " },_oDlgAlm,,,,,,.T.,CLR_BLACK,CLR_WHITE)
	oUsuAux		:= TGet():New(20,60,bSetGet(cUsuAlm),_oDlgAlm,60,10,,,,,,,,.T.,,,,,,,,,)
	TSay():New(35,10,{|| "Senha: " },_oDlgAlm,,,,,,.T.,CLR_BLACK,CLR_WHITE)
	oSenhaAux	:= TGet():New(35,60,bSetGet(cSenhaAlm),_oDlgAlm,60,10,,,,,,,,.T.,,,,,,,,.T.,)
	SButton():New(60,20,01,{|| (lFechaAlm:=.T.,_oDlgAlm:End()) }, _oDlgAlm,,"Confirma")
	SButton():New(60,80,02,{|| (lCancAlm := .T., lFechaAlm := .T., _oDlgAlm:End()) }, _oDlgAlm,,"Cancela")
	_oDlgAlm:Activate(,,,,,,)

	If !lCancAlm
		lAltAlmox := B744UsuAlmox()
		If lAltAlmox
			oGet2:Enable()
			oGet2:SetFocus()
		EndIf
	EndIf

Return

/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744UsuAlmox       ³ Alan Leandro       º Data ³           º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Valida o usuario e senha que libera a alteracao do         º±±
	±±º          ³ campo almoxarifado no apontamento.                         º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B744UsuAlmox()
	/******************************/
	Local lRet		:= .F., lOk, _i
	Local aUsrInf	:= {}

	PswOrder(2)
	If PswSeek(cUsuAlm,.T.)
		lOk := PswName(cSenhaAlm)

		If lOk
			aUsrInf := PswRet()
			For _i := 1 To Len(aUsrInf[1][10])
				//If Upper(Alltrim(GrpRetName(aUsrInf[1][10][_i]))) $ Upper(GetMv("MV_GRPALMX"))
				If Upper(Alltrim(aUsrInf[1][10][_i])) $ Upper(GetMv("MV_GRPALMX"))
					lRet := .T.
					Exit
				EndIf
			Next _i

			If !lRet
				MsgStop("Usuario nao autorizado!!!")
			EndIf
		Else
			MsgStop("Senha Invalida!!!")
		EndIf
	Else
		MsgStop("Usuario Invalido!!!")
	EndIf

Return lRet


/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³ B744VldLoc  ³ Robson J. Pavanelli    º Data 23/11/2023 ³   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescricao ³ Valida almoxarifado na tabela NNR                          º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ BUD744                                                     º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function B744VldLoc()

	If	Select('TNNR')<> 0
		dbSelectArea('TNNR')
		dbCloseArea()
	EndIf

	BeginSql Alias 'TNNR'
		SELECT
			NNR_CODIGO
		FROM
			%Table:NNR% NNR (NOLOCK)
		WHERE
			NNR.%NotDel%
			AND NNR_FILIAL = %xFilial:NNR%
			AND NNR_CODIGO = %Exp:AllTrim(cAlmox)%
	EndSql

	If	Empty(TNNR->NNR_CODIGO)
		ALERT('Armazem '+cAlmox+' não localizado!')
		oGet2:SetFocus()
	Else
		oGet2:Disable()
		oGet3:SetFocus()
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³B744Perda ºAutor  ³Microsiga           º Data ³  11/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para realizar a devolucao da quantidade perda sem    º±±
±±º          ³custo para o sub-produto retalho/residuo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P10                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function B744Perda(cProdPer,cLocPer,nQtdPer,cUsuaPer)

	//Local aItem := {}
	/*
	aAdd(aItem,{"D3_TM"     	,GetMv("MV_TMPERDA")	,Nil}) //Codigo do Tipo de Movimentacao
	aAdd(aItem,{"D3_EMISSAO" ,MsDate()             ,Nil}) //Data de Emissao
	//aAdd(aItem,{"D3_CC"       ,cCCusto       				,Nil}) //Centro de Custo
	aAdd(aItem,{"D3_COD"		,cProdPer							,Nil}) //Codigo do Produto
	aAdd(aItem,{"D3_LOCAL"	,cLocPer         			,Nil}) //Almoxarifado
	aAdd(aItem,{"D3_QUANT"	,nQtdPer							,Nil}) //Quantidade
	aAdd(aItem,{"D3_USUARIO"	,cUsuaPer							,Nil}) //Ordem de producao

	/* 11/2021
	// Não prossigo se o registro esteja travado:
	While U_zLockSB2(cProdPer, cLocPer, .T.)
		// Caso o registro esteja travado, não prossigo...
		U_BUD1427("[BUD744] - Registro ["+AllTrim(cProdPer)+"]/["+AllTrim(cLocPer)+"] esta travado...")
	EndDo
	*/
	/*
	lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
	lMsErroAuto := .F.
	MSExecAuto({|x,y| MATA240(x,y)},aItem,3)
	If	lMsErroAuto
		DisarmTransaction()

		If !__AUTO
			MostraErro()
		Else
			cErro := "[BUD744] - ERRO - Erro na rotina"
			U_BUD1427(cErro)
		EndIf
	EndIf
	*/
	/////////////////////////////////////////////////
	aItens := {}
	aCab := {}
	SB1->(MsSeek(xFilial('SB1')+cProdPer))
	dbSelectArea('SD3')
	aCab := { 	{"D3_TM"    	,GetMv("MV_TMPERDA")	,Nil},;
		{"D3_DOC"    	,NextNumero("SD3",2,"D3_DOC",.T.)	,Nil},;
		{"D3_EMISSAO"	,MsDate()							,Nil}}


	aadd(aItens, {	{"D3_COD"		,cProdPer			,Nil},;
		{"D3_UM"    	,SB1->B1_UM    		,Nil},;
		{"D3_QUANT" 	,nQtdPer    	,Nil},;
		{"D3_OP"		,cNumOP				,Nil},;
		{"D3_LOCAL" 	,cLocPer			,Nil},;
		{"D3_USUARIO" 	,cUsuaPer			,Nil},;
		{"D3_SEQBUDD"	,cSeqBudd			,nil}})

	lMsHelpAuto := .T.  // se .t. direciona as mensagens de help
	lMsErroAuto := .F.  //necessario a criacao, pois sera

	MSExecAuto({|x,y,z| MATA241(x,y,z)},aCab,aItens,3)
	If	lMsErroAuto
		DisarmTransaction()

		If !__AUTO
			MostraErro()
		Else
			cErro := "[BUD744] - ERRO - Erro na rotina"
			U_BUD1427(cErro)
		EndIf
	EndIf

Return (lMsErroAuto)

//------------------------------------------------
Static Function fPecasSeg(aPosObj)
	//Define o tamanho da janela com relação a distacia sobre o container
	Local nTopAdicional := 160  // Distancia altura janela
	Local nLeftAdicional := 10  // Distancia lado esquerdo da janela
	Local nBottomAdicional := n_oDlgHeight - 10  // Distancia de baixo da janela
	Local nRightAdicional := n_oDlgWidth - 10  // Distancia lado direito da janela

	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFields := {"ZAB_ITEM","ZAB_CODDEF","ZAB_DESCDEF","ZAB_QUANT","ZAB_DATA","ZAB_HORA","ZAB_PROCES","ZAB_DOC","ZAB_INSPET"}
	Local aAlterFields := {}
	Local aFieldFill := {}

	Aadd(aHeaderEx,{" ","COLBMP"  ,	"@BMP",3,0,"",CHR(251),"C","","","",,"","V","","",.F.})

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Else
			Aadd(aHeaderEx, {'Descricao Defeito',aFields[nX],'@!',30,0,,"û",'C',,,,})
		Endif
	Next nX

	// Define field values
	aAdd(aFieldFill,'BR_BRANCO')
	If	Empty(aColsEx)
		For nX := 1 to Len(aFields)
			If DbSeek(aFields[nX])
				Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
			Else
				Aadd(aFieldFill, " ")
			Endif
		Next nX
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	EndIf

	// aPosObj[1,1]+130,aPosObj[2,2]+250
	//oPecasSeg := MsNewGetDados():New( aPosObj[1,1]+175, aPosObj[2,2]+10, aPosObj[3,3]-30,aPosObj[3,4]-40, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", , aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oContainer, aHeaderEx, aColsEx)
	oPecasSeg := MsNewGetDados():New(nTopAdicional, nLeftAdicional, nBottomAdicional, nRightAdicional, GD_UPDATE, "AllwaysTrue", "AllwaysTrue",, aAlterFields, , 999, "AllwaysTrue", "", "AllwaysTrue", oContainer, aHeaderEx, aColsEx)
	oPecasSeg:oBrowse:lAdjustColSize := .T.

Return

Static function CarregaSeg()

	oPecasSeg:aCols := {}

	If	Select('TPCSEG') <> 0
		TPCSEG->(DbCloseArea())
	EndIf

	BeginSql Alias 'TPCSEG'
		Column ZAB_QUANT as Numeric(14, 3)
		Column ZAB_DATA as Date
		SELECT
			ZAB_ITEM,
			ZAB_CODDEF,
			X5_DESCRI AS ZAB_DESCDEF,
			ZAB_QUANT,
			ZAB_DATA,
			ZAB_HORA,
			ZAB_PROCES,
			ZAB_DOC,
			ZAB_INSPET
		FROM
			%Table:ZAB% ZAB (NOLOCK)
		INNER JOIN %Table:SX5% SX5 (NOLOCK)
		ON SX5.%NotDel%
			AND X5_FILIAL = %xFilial:SX5%
			AND X5_TABELA = 'Z5'
			AND RTRIM(X5_CHAVE) = RTRIM(ZAB_CODDEF)
		WHERE
			ZAB.%NotDel%
			AND ZAB_FILIAL = %xFilial:ZAB%
			AND ZAB_OP = %Exp:cNumOP%
		ORDER BY
			ZAB_ITEM,
			ZAB_CODDEF,
			ZAB_DATA,
			ZAB_HORA
	EndSql

	While !TPCSEG->(Eof())

		aAdd(oPecasSeg:aCols,{IIf(TPCSEG->ZAB_PROCES='S','BR_VERMELHO','BR_VERDE'),TPCSEG->ZAB_ITEM, TPCSEG->ZAB_CODDEF, TPCSEG->ZAB_DESCDEF, TPCSEG->ZAB_QUANT, TPCSEG->ZAB_DATA, TPCSEG->ZAB_HORA, TPCSEG->ZAB_PROCES, TPCSEG->ZAB_DOC, TPCSEG->ZAB_INSPET, .F.})

		TPCSEG->(DbSkip())

	EndDo

	If	Empty(oPecasSeg:aCols)
		aAdd(oPecasSeg:aCols,{"BR_BRANCO","  ","   "," ",0,Stod("")," "," "," "," ",.F.})
	EndIf

	oPecasSeg:oBrowse:Refresh()

Return

/*
Função responsável para retornar a sequencia das movimentações de apontamento das OP's p Toalhas/Roupao/Cama/Matelasse
*/

Static Function B744Seq()

	If	Select('TSEQ') <> 0
		TSEQ->(DbCloseArea())
	EndIf

	BeginSql Alias 'TSEQ'
		SELECT
			MAX(D3_SEQBUDD) AS D3_SEQBUDD
		FROM
			%Table:SD3% D3
		WHERE
			D3.D3_FILIAL = %xFilial:SD3%
			AND D3.%NotDel%
			AND D3.D3_OP = %Exp:cNumOP%
			AND Left(D3.D3_CF, 2) = 'PR'
			AND D3.D3_ESTORNO = ' '
	EndSql

	If	!TSEQ->(Eof())
		If	!Empty(TSEQ->D3_SEQBUDD)
			cSeqBudd := Soma1(TSEQ->D3_SEQBUDD)
		Else
			cSeqBudd := '01'
		EndIf
	Else
		cSeqBudd := '01'
	EndIf

	If	Select('TSEQ') <> 0
		TSEQ->(DbCloseArea())
	EndIf

Return

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
* Envia e-mail de divergência conforme turnos repassados pelo Jairo:                                                              *
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
Static Function MailDiv(cUsuBip, cCodBip, cCodOP, cNumOP)

	Local cServer   := GETMV("MV_SERCONE")
	Local cAccount  := GETMV("MV_RELACNT")
	Local cPassword := GETMV("MV_RELPSW")
	Local cEnvia	:= "ti@buddemeyer.com.br"
	Local cRecebe   := ""
	Local cAssunto  := "Divergência de Códigos de Barras"
	Local cMensagem := ""
	Local lConectou := .T.

	// Validação de conteúdo:
	If Empty(cUsuBip) .Or. Empty(cCodBip) .Or. Empty(cCodOP) .Or. Empty(cNumOP)
		Return
	EndIf

	// Verificação de horário para envio:
	cHoraBip := Substr(Time(),1,5)
	if cHoraBip >= "05:01" .And. cHoraBip <= "13:30"
		// Primeiro turno:
		cRecebe   := AllTrim(GETMV("BD_DIV1TUR"))
	Elseif cHoraBip >= "13:31" .And. cHoraBip <= "22:00"
		// Segundo turno:
		cRecebe   := AllTrim(GETMV("BD_DIV2TUR"))
	Else
		// Terceiro turno
		cRecebe   := AllTrim(GETMV("BD_DIV3TUR"))
	EndIf

	// Se não existe:
	if Empty(cRecebe)
		Return
	EndIf

	cMensagem += "<html>"
	cMensagem += "<body style='font-size: 9pt'>"
	cMensagem += "<font face='Trebuchet MS'>Prezados, <br><br>Favor verificar o erro de bipagem de código de barras na descida:"
	cMensagem += "<br><hr noshade color='E9E9E9' size='1'>"
	cMensagem += "<br>"
	cMensagem += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse; font-size: 8pt; font-family: Arial" bordercolor="#EAEAEA" width="100%">'

	// Cabeçalho:
	cMensagem += "<tr bgcolor='#EAEAEA'>"
	cMensagem += "<td align='center'>"
	cMensagem += "<b>Cód. Bipado</b>"
	cMensagem += "</td>"
	cMensagem += "<td align='left'>"
	cMensagem += "<b>Desc. Bipado</b>"
	cMensagem += "</td>"
	cMensagem += "<td align='center'>"
	cMensagem += "<b>Cód. Produto</b>"
	cMensagem += "</td>"
	cMensagem += "<td align='left'>"
	cMensagem += "<b>Desc. Produto</b>"
	cMensagem += "</td>"
	cMensagem += "<td align='center'>"
	cMensagem += "<b>Número da OP</b>"
	cMensagem += "</td>"
	cMensagem += "</tr>"

	// Informação recebida:
	cMensagem += "<tr>"
	cMensagem += "<td align='center'>"
	cMensagem += cCodBip
	cMensagem += "</td>"
	cMensagem += "<td align='left'>"
	cMensagem += Posicione("SB1",1,xFilial("SB1")+cCodBip,"B1_DESC")
	cMensagem += "</td>"
	cMensagem += "<td align='center'>"
	cMensagem += cCodOP
	cMensagem += "</td>"
	cMensagem += "<td align='left'>"
	cMensagem += Posicione("SB1",1,xFilial("SB1")+cCodOP,"B1_DESC")
	cMensagem += "</td>"
	cMensagem += "<td align='center'>"
	cMensagem += cNumOP
	cMensagem += "</td>"
	cMensagem += "</tr>"

	cMensagem += "</table>"
	cMensagem += "<br><br><hr noshade color='E9E9E9' size='1'>"
	cMensagem += "Usuário: <b>"+AllTrim(cUsuBip)+"</b>. Data: "+Dtoc(MsDate())+". Hora: "+cHoraBip+". <br>"
	cMensagem += "</font>"
	cMensagem += "</body>"
	cMensagem += "</html>"

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword TIMEOUT 10 Result lConectou
	If (lConectou)
		SEND MAIL FROM cEnvia;
			TO cRecebe ;
			CC '' ;
			BCC '';
			SUBJECT cAssunto;
			BODY cMensagem;
			RESULT lEnviado
	EndIf
	If !lEnviado
		cMensagem := ""
		GET MAIL ERROR cMensagem
	Endif
	DISCONNECT SMTP SERVER Result lConectou

Return

/* Função para limpar os campos: */ //RobsonJP 20231030
Static Function LimparCampos(lFechar)

	Default lFechar := .F.

	//Limpa vinculo OP com usuário:
	Leave1Code(Alltrim(cNumOP))
	U_BUD1427('Liberação do Codigo de Apontamento de OP '+Alltrim(cNumOP))

	//Reseta as variaveis:
	cNumop      	:= space(13)
	cSeqBudd    	:= space(02)
	cCodBar    		:= Criavar("B1_CODBAR",.F.)
	cProduto   		:= Criavar("B1_COD",.F.)
	cDescricao 		:= Criavar("B1_DESC",.F.)
	cALmox     		:= Criavar("B1_LOCPAD",.F.)
	cUMProduto 		:= Criavar("B1_UM",.F.)
	nQtdPecas  		:= 0
	nMultiplo  		:= 0
	nMultItem  		:= 0
	lFirst     		:= .T.
	lMultiplo  		:= .T.
	lAvulso    		:= .F.
	lRetOP     		:= .T.
	nQtdOP     		:= 0
	nQtdOPSal  		:= 0
	nQtdLiber  		:= 0
	nQtdTot	   		:= 0
	nQtdRetPc  		:= 0
	nPerdas    		:= 0
	aPerd[NQTDSEG]  := 0
	aPerd[NQTDLD]   := 0
	aPerd[NPERDA199]:= 0
	aPerd[NPERDA299]:= 0
	aPerd[NPERDA399]:= 0
	aPerd[NPERDA499]:= 0
	aPerd[NPERDA599]:= 0
	aPerd[NPERDA699]:= 0
	aPerd[NPERDAPC] := 0
	aPerd[NRETALHO] := 0
	aRecSeg 		:= {}
	aRecLD			:= {}
	lGaiolaObr		:= .F.
	cCodGaiola 		:= Space(TamSx3('ZDT_CODIGO')[1])
	nExpGai			:= IIF(lGaiolaObr, GetMv("BD_744EGA"), 0)

	If 	Empty(cParamSeg)
		//Limpa o MsNewGetDados:
		oPecasSeg:aCols := {}
		If	Empty(oPecasSeg:aCols)
			aAdd(oPecasSeg:aCols,{"BR_BRANCO","  ","   "," ",0,Stod("")," "," "," "," ",.F.})
		EndIf
		oPecasSeg:oBrowse:Refresh()

		oContainer:Refresh()
		oGet1:Enable()  //Habilito input OP
		oBtn7:Enable()  //Habilito botão fechar
		oGet3:Disable() //Desativo campo codigo de barras
		oGet7:Disable() //Desativo campo múltiplos
		oBtn0:Disable() //Desativo botão Encerra
		oBtn1:Disable() //Desativo botão Confirma
		oBtn2:Disable() //Desativo botão Cancelar
		oGet1:SetFocus()
	EndIf

	//Tratativa abaixo apenas quando for encerramento da tela do apontamento
	iF lFechar .and. Empty(cParamSeg)
		lFecha := .T.
		_oDlg:DeActivate() //Fechou o FWDialogModal
	EndIf

Return Nil

/*Função para gerar Logs de cancelamento de apontamentom, com peças lidas*/ //RobsonJP 20231031
Static Function _B744Log(_cMsg)

	Local cArqTxt := "Cancelamento_Apontamento_BUD744.txt"
	Local nHdlog  := fOpen(cArqTxt,2)

	Static cEOL := CHR(13)+CHR(10)

	//caso não consiga abrir o arquivo...
	If nHdlog == -1
		//tenta cria-lo
		nHdlog := fCreate(cArqTxt,2)
		//se também der erro
		If 	nHdlog == -1
			U_BUD1427('Erro ao Gerar o Arquivo de Log do Cancelamento de Apontamento (BUD744) !!!')
			Return
		Else
			_cMsg := 'Cancelamento do Apontamento no BUD744 ' + cEOL
			fWrite(nHdlog, _cMsg, Len(_cMsg))

			_cMsg := '--------------------------------------------------' + cEOL
			fWrite(nHdlog, _cMsg, Len(_cMsg))
		EndIf
	Else
		//vai para o fim do arquivo
		fSeek(nHdlog,0,2)
	Endif

	_cMsg := DtoC(MsDate()) + " - " + Time() + " - " + _cMsg + cEOL

	fWrite(nHdlog,_cMsg,Len(_cMsg))

	fClose(nHdlog)

Return

/*ENVIO EMAIL DO ERRO DA ROTINA AUTOMATICA MATA250*/
Static Function _B744Mail(_NOP,_cProduto,_cUserName,_cMsg)

	Local cProcess := Space(6), cStatus := Space(6)

	cEmail := GetMv("BD_744MAIL")

	//Inicia processo de envio do e-mail
	cProcess := OemToAnsi("002010") // Numero do Processo
	cStatus  := OemToAnsi("002011")

	oProcess := TWFProcess():New(cProcess,OemToAnsi("BUD744 - ERRO APONTAMENTO ORDEM DE PRODUÇÃO"))

	oProcess:NewTask(cStatus,"\workflow\_B744MAIL.html")

	oProcess:cSubject := OemToAnsi("BUD744 - ERRO APONTAMENTO ORDEM DE PRODUÇÃO: " + _NOP )
	oProcess:cTo := cEmail


	AADD(oProcess:oHtml:ValByName("IT.OP"), _NOP)
	AADD(oProcess:oHtml:ValByName("IT.CODPROD"), _cProduto )
	AADD(oProcess:oHtml:ValByName("IT.DESCPROD"), _cUserName )

	oProcess:oHtml:ValByName("CC", _cMsg)

	oProcess:Start()
	oProcess:Finish()

	WFSendMail()

Return
