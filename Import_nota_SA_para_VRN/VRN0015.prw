#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
/=========================================================================\
|Módulo      : Compras/Estoque                  	                   	  |
|=========================================================================|
|Programa    : VRN0015.PRW   | Responsável: Thiago Lucas Machado.         |
|=========================================================================|
|Descricao   : | Gera nota fiscal de entrada (Buddemeyer)            	  |
|=========================================================================|
|Data        : 28/01/2014 												  |
|=========================================================================|
|Programador : Thiago Lucas Machado     								  |
\=========================================================================/
*/

User Function VRN0015()
	// Cadastrado no Configurador
	If !Pergunte("VRN0015",.T.)
		Return
	EndIf

	IF MV_PAR03 == 1
		MV_PAR03 := "01"
	ELSEIF MV_PAR03 == 2
		MV_PAR03 := "10"
	ENDIF

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR03)
		Msgstop("Ocorreu um erro na tentativa buscar as informações. Gentileza verifique os campos!")
		Return
	EndIf

	LjMsgRun(OemToAnsi('Buscando informações da nota fiscal... Aguarde...'),,{|| BuscaInfo() } )

Return

Static Function BuscaInfo()

	Local aAutoCab		:= {}
	Local aAutoItens	:= {}
	Local C103TIPO		:= "N"
	Local C103FORM		:= "N"
	Local lEstoque 		:= .F.
	Local CNFISCAL		:= Alltrim(MV_PAR01)
	Local CSERIE		:= Alltrim(MV_PAR02)
	Local CESPECIE		:= "SPED"
	//Local CUFORIG		:= "SC"
	Local CCONDICAO		:= SuperGetMv("BD_CONDPAG",.F.,"25D") // EMPORIO "022" // VRN E DEMAIS "25D"
	Local cCliVRN		:= Substr(SM0->M0_CGC,3,6)
	Local cCNPJ			:= IIF(MV_PAR03 =="01",'86047198000184', '86047198001075')  //DANIEL PERSONALITEC 18/06/2025 - ADICIONADO POIS AGORA TEM A FILIAL 10 TAMBÉM
	Local cLojasEstoque := GetMv("BD_EMPTEM") // Verificar se deve importar no local loja temporaria
	Local cDA1_PRCLIQ   := 0
	Local cDA1_PRCVEN	:= 0
	Private CA100FOR 	:= "86047198"
	Private CLOJA	   	:= IIF(MV_PAR03 =="01","0001", "0010") //DANIEL PERSONALITEC 18/06/2025 - ADICIONADO POIS AGORA TEM A FILIAL 10 TAMBÉM
	Private	lAuto 		:= .F.
	Private nTimeOut 	:= 10
	Private cNovosPro	:= ""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	If	Select('FORNEC') <> 0
		FORNEC->(DbCloseArea())
	EndIf

	BeginSql Alias 'FORNEC'
		SELECT
			A2_COD AS COD,
			A2_LOJA AS LOJA
		FROM
			%Table:SA2%
		WHERE
			%NotDel%
			AND A2_FILIAL = %xFilial:SA2%
			AND A2_CGC = %Exp:cCNPJ%
	EndSql

	If 	FORNEC->(Eof()) .And. FORNEC->(Bof())
		MsgInfo('Não existe o Cadastrado do Fornecedor Buddemeyer CNPJ 86.047.198/0001-84 para esta empresa/filial !!!')
		Return
	EndIf

	CA100FOR := FORNEC->COD
	CLOJA 	 := FORNEC->LOJA

	If	Select('NFENT') <> 0
		NFENT->(DbCloseArea())
	EndIf

	BeginSql Alias 'NFENT'
		SELECT
			F1_SERIE + F1_DOC AS NOTA
		FROM
			%Table:SF1%
		WHERE
			%NotDel%
			AND F1_FILIAL = %xFilial:SF1%
			AND F1_SERIE = %Exp:CSERIE%
			AND F1_DOC = %Exp:CNFISCAL%
			AND F1_FORNECE = %EXP:CA100FOR%
			AND F1_LOJA = %EXP:CLOJA%
	EndSql

	If !NFENT->(Eof()) .And. !NFENT->(Bof())
		MsgInfo('A nota fiscal '+CSERIE+'/'+CNFISCAL+' informada nos parâmetros já foi lançada para esta empresa/filial !!!')
		Return
	EndIf

	If (Select("TT0015G") <> 0)
		dbSelectArea("TT0015G")
		dbCloseArea()
	EndIf
	cQuery := ""
	cQuery += "SELECT TOP 1 A1_CGC  "
	cQuery += "FROM [BANCO].[DADOSADV].[dbo].[SF2010] F2(NOLOCK) "
	cQuery += "INNER JOIN [BANCO].[DADOSADV].[dbo].[SA1010] A1(NOLOCK) ON A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA AND A1.D_E_L_E_T_ = '' "
	cQuery += "WHERE F2.D_E_L_E_T_ = '' AND RTRIM(F2_DOC) = '"+CNFISCAL+"' "
	cQuery += "AND RTRIM(F2_SERIE) = '"+CSERIE+"' "
	cQuery += "AND F2_FILIAL = '"+MV_PAR03+"' " //DANIEL PERSONALITEC 18/06/2025 - ADICIONADO POIS AGORA TEM A FILIAL 10 TAMBÉM
	TCQuery cQuery NEW ALIAS "TT0015G"
	If TT0015G->(Eof())
		MSGSTOP("Essa NF não foi faturada para essa empresa, favor verificar os parâmetros!")
		Return
	Else
		If Alltrim(TT0015G->A1_CGC) <> Alltrim(SM0->M0_CGC)
			MSGSTOP("Essa NF não foi faturada para essa empresa, favor verificar os parâmetros!")
			Return
		EndIf
	EndIf

	//Verifico se é entrada de loja temporaria de desconto, pedido deve estar com tabela **LTD**
	if ((AllTrim(cEmpAnt) $ AllTrim(cLojasEstoque)))
		If (Select("TT0015L") <> 0)
			dbSelectArea("TT0015L")
			dbCloseArea()
		EndIf
		cQuery := ""
		cQuery += "SELECT TOP 1 C5_NUM "
		cQuery += "FROM [BANCO].[DADOSADV].[dbo].[SC5010] C5(NOLOCK) "
		cQuery += "INNER JOIN [BANCO].[DADOSADV].[dbo].[SC6010] C6(NOLOCK) ON C6_FILIAL = '01' AND C6_NUM = C5_NUM AND C6.D_E_L_E_T_ = '' "
		cQuery += "WHERE C5_FILIAL = '01' "
		cQuery += "AND C5_PEDCLI LIKE 'LTD%' AND C5_CLIENTE = '"+cCliVRN+"' "
		cQuery += "AND C6_NOTA = '"+CNFISCAL+"' AND C6_SERIE = '"+CSERIE+"' "
		cQuery += "AND C5.D_E_L_E_T_ = '' "
		TCQuery cQuery NEW ALIAS "TT0015L"
		If !TT0015L->(Eof())
			lEstoque := .T.
		EndIf

	EndIf

	//Busco nota fiscal a ser importada
	If (Select("TT0015H") <> 0)
		dbSelectArea("TT0015H")
		dbCloseArea()
	EndIf
	cQuery := ""
	cQuery += "SELECT TOP 1 F2_DOC, F2_PLIQUI, F2_PBRUTO, F2_CHVNFE, F2_EMISSAO  "
	cQuery += "FROM [BANCO].[DADOSADV].[dbo].[SF2010] F2(NOLOCK) "
	cQuery += "WHERE F2.D_E_L_E_T_ = '' AND RTRIM(F2_DOC) = '"+CNFISCAL+"' "
	cQuery += "AND RTRIM(F2_SERIE) = '"+CSERIE+"' "
	cQuery += "AND F2_FILIAL = '"+MV_PAR03+"' " //DANIEL PERSONALITEC 18/06/2025 - ADICIONADO POIS AGORA TEM A FILIAL 10 TAMBÉM
	TCQuery cQuery NEW ALIAS "TT0015H"
	If TT0015H->(Eof())
		Msgstop("Nenhuma NF encontrada com esses parâmetros! ")
	Else
		nF1_PLIQUI := TT0015H->F2_PLIQUI
		If empty(nF1_PLIQUI)
			nF1_PLIQUI 	:= 0
		EndIF
		nF1_PBRUTO := TT0015H->F2_PBRUTO
		If empty(nF1_PBRUTO)
			nF1_PBRUTO 	:= 0
		EndIF
		cF1_CHVNFE := TT0015H->F2_CHVNFE
		cF1_EMISSAO := StoD(TT0015H->F2_EMISSAO)

		// Cabeçalho:
		AAdd( aAutoCab, { "F1_FORMUL" 	, C103FORM     		, Nil } ) // Formulario
		AAdd( aAutoCab, { "F1_DOC"    	, CNFISCAL	  		, Nil } ) // Numero da NF : Obrigatorio
		AAdd( aAutoCab, { "F1_SERIE"   	, CSERIE		  	, Nil } ) // Serie da NF  : Obrigatorio
		AAdd( aAutoCab, { "F1_TIPO"    	, C103TIPO 			, Nil } ) // Tipo da NF   : Obrigatorio
		AAdd( aAutoCab, { "F1_FORNECE"	, CA100FOR     		, Nil } ) // Codigo do Fornecedor : Obrigatorio
		AAdd( aAutoCab, { "F1_LOJA"    	, CLOJA        		, Nil } ) // Loja do Fornecedor   : Obrigatorio
		AAdd( aAutoCab, { "F1_EMISSAO"	, cF1_EMISSAO	  	, Nil } ) // Emissao da NF        : Obrigatorio
		AAdd( aAutoCab, { "F1_ESPECIE" 	, CESPECIE 			, Nil } ) // Especie
		AAdd( aAutoCab, { "F1_COND"   	, CCONDICAO	   		, Nil } ) // Condicao do Pagamento
		AAdd( aAutoCab, { "F1_PLACA"   	, ""     			, Nil } ) // Placa do Caminhao
		AAdd( aAutoCab, { "F1_PLIQUI"  	, nF1_PLIQUI	 	, Nil } ) // Peso liquido
		AAdd( aAutoCab, { "F1_PBRUTO" 	, nF1_PBRUTO	 	, Nil } ) // Peso liquido
		AAdd( aAutoCab, { "F1_CHVNFE" 	, cF1_CHVNFE	 	, Nil } ) // Chave da NF Eletronica

		// Itens:
		If (Select("TT0015I") <> 0)
			dbSelectArea("TT0015I")
			dbCloseArea()
		EndIf
		cQuery := ""
		cQuery += "SELECT  D2_COD, D2_QUANT, D2_PRCVEN, D2_TOTAL, D2_IPI, D2_PICM, B1_CODBAR "
		cQuery += "FROM [BANCO].[DADOSADV].[dbo].[SD2010] D2(NOLOCK) "
		cQuery += "INNER JOIN [BANCO].[DADOSADV].[dbo].[SB1010] B1(NOLOCK) ON B1_FILIAL = '' AND B1_COD = D2_COD  AND B1.D_E_L_E_T_ = ''  "
		cQuery += "WHERE D2.D_E_L_E_T_ = '' AND D2_FILIAL  = '"+MV_PAR03+"' "////DANIEL PERSONALITEC 18/06/2025 - ADICIONADO POIS AGORA TEM A FILIAL 10 TAMBÉM
		cQuery += "AND  RTRIM(D2_DOC) = '"+CNFISCAL+"' AND RTRIM(D2_SERIE) = '"+CSERIE+"' "
		cQuery += "AND D2_CLIENTE = '"+cCliVRN+"' "
		TCQuery cQuery NEW ALIAS "TT0015I"
		If !TT0015I->(Eof())
			While !TT0015I->(Eof())
				cD1_COD := TT0015I->D2_COD
				cB1_CODBAR := TT0015I->B1_CODBAR
				// Verifico se o produto existe se não eu importo:
				If (Select("TT0015B") <> 0)
					dbSelectArea("TT0015B")
					dbCloseArea()
				EndIf
				cQuery := "SELECT DISTINCT TOP 1 B1_COD, B1_TE  "
				cQuery += "FROM "+RetSqlName("SB1")+" (NOLOCK) "
				cQuery += "WHERE "+RetSqlName("SB1")+".D_E_L_E_T_ = '' "
				cQuery += "AND B1_FILIAL = '"+xFilial("SB1")+"' "
				cQuery += "AND (B1_COD LIKE '%"+AllTrim(cD1_COD)+"%') "
				cQuery += "AND B1_COD <> '' "
				TCQuery cQuery NEW ALIAS "TT0015B"
				If TT0015B->(Eof())
					lRet	:= PreImpPro(cB1_CODBAR, cD1_COD)
					If !lRet
						Msgstop("Ocorreu um erro na tentativa de importar o produto, gentileza verificar!")
						Return
					Else
						cB1_TE := Posicione("SB1",1,xFilial("SB1")+cD1_COD,"B1_TE")
					EndIf
				Else
					// Incluido linha para retornar o campo de Tipo de Entrada do Cadastro de Produto - 01/04/2015
					cB1_TE := TT0015B->B1_TE
				EndIf

				//Verificar tabela de preços - 16/11/2016 - Rodrigo
				If(cEmpAnt == "06" .AND. cFilAnt == "09")
					cCodTab := "005"
				Else
					cCodTab := "007"
				EndIf
				If	(cEmpAnt != '11') .And. (cEmpAnt != '14')
					If (Select("TT0015C") <> 0)
						dbSelectArea("TT0015C")
						dbCloseArea()
					EndIf
					// Processo tabela de preço
					cQuery := "SELECT DISTINCT TOP 1 DA1_ITEM FROM "+RetSqlName("DA1")+" (NOLOCK) WHERE "+RetSqlName("DA1")+".D_E_L_E_T_ = '' AND DA1_CODTAB = '"+cCodTab+"' AND DA1_CODPRO = '"+AllTrim(cD1_COD)+"' AND DA1_FILIAL = '"+xFilial('DA1')+"'"
					TCQuery cQuery NEW ALIAS "TT0015C"
					If TT0015C->(Eof())
						// MAX no item da tabela
						If (Select("TT0015D") <> 0)
							dbSelectArea("TT0015D")
							dbCloseArea()
						EndIf
						cQuery := "SELECT MAX(DA1_ITEM) AS ITEM FROM "+RetSqlName("DA1")+" (NOLOCK) WHERE D_E_L_E_T_ = '' AND DA1_CODTAB = '"+cCodTab+"' AND DA1_FILIAL = '"+xFilial('DA1')+"' "
						TCQuery cQuery NEW ALIAS "TT0015D"
						cItem := soma1(TT0015D->ITEM)

						// Tabela de preços da SA
						If (Select("TT0015J") <> 0)
							dbSelectArea("TT0015J")
							dbCloseArea()
						EndIf
						cQuery := ""
						cQuery += "SELECT DISTINCT TOP 1 DA1_PRCSUG, DA1_PRCPRM  "
						cQuery += "FROM [BANCO].[DADOSADV].[dbo].[DA1010] DA(NOLOCK) "
						cQuery += "WHERE DA.D_E_L_E_T_ = '' AND DA1_FILIAL = ''   "
						cQuery += "AND DA1_CODTAB = 'P09'  "
						cQuery += "AND DA1_CODPRO = '"+AllTrim(cD1_COD)+"'  "
						TCQuery cQuery NEW ALIAS "TT0015J"
						If !TT0015J->(Eof())
							cDA1_PRCVEN := TT0015J->DA1_PRCSUG
							cDA1_PRCLIQ := TT0015J->DA1_PRCPRM
						EndIf
						//DA1_DESCTO
						If(cDA1_PRCLIQ > 0 .AND. cDA1_PRCVEN > 0)
							cDA1_DESCTO := 100-((cDA1_PRCLIQ/cDA1_PRCVEN)*100)
						Else
							cDA1_DESCTO := 0
						EndIf

						//Inserir na tabela de preços
						RecLock('DA1',.T.)
						DA1->DA1_FILIAL := xFilial('DA1')
						DA1->DA1_CODTAB	:= cCodTab
						DA1->DA1_ITEM	:= cItem
						DA1->DA1_CODPRO	:= AllTrim(cD1_COD)
						DA1->DA1_PRCVEN	:= cDA1_PRCVEN
						DA1->DA1_PRCLIQ := cDA1_PRCLIQ
						DA1->DA1_DESCTO := cDA1_DESCTO
						DA1->DA1_ATIVO	:= '1'
						DA1->DA1_TPOPER := '4'
						DA1->DA1_QTDLOT := 999999.99
						DA1->DA1_MOEDA 	:= 1
						DA1->DA1_DATVIG := ddatabase
						MsUnlock()

					EndIf
				EndIf
				// Fim processo tabela de preços

				nD1_QUANT	:= TT0015I->D2_QUANT
				nD1_VUNIT	:= TT0015I->D2_PRCVEN
				nD1_TOTAL	:= TT0015I->D2_TOTAL
				nD1_IPI		:= TT0015I->D2_IPI
				nD1_PICM	:= TT0015I->D2_PICM

				aReg := {}
				aadd(aReg,{"D1_COD"    	, cD1_COD  		,Nil})
				aadd(aReg,{"D1_QUANT"  	, nD1_QUANT  	,Nil})
				aadd(aReg,{"D1_VUNIT"  	, nD1_VUNIT  	,Nil})

				// Incluido nova condição devido a necessidade de que as notas de entrada na filial 09
				// sejam utilizados Tipo de Entrada que não gerem crédito de ICMS na Entrada
				// Data 10/2021
				If	cFilAnt == '09'
					If	cB1_TE = '001'
						aadd(aReg,{"D1_TES"		, '069'		,Nil})
					Elseif	cB1_TE = '002'
						aadd(aReg,{"D1_TES"		, '070'		,Nil})
					Else
						aadd(aReg,{"D1_TES"		, cB1_TE	,Nil})
					EndIf
				Else
					aadd(aReg,{"D1_TES"		, cB1_TE		,Nil})
				EndIf
				IF MV_PAR03 == "10"
					aadd(aReg,{"D1_OPER "		, "51"		,Nil})
				ENDIF
				aadd(aReg,{"D1_IPI"  	, nD1_IPI  		,Nil})
				aadd(aReg,{"D1_PICM"  	, nD1_PICM  	,Nil})
				// Caso for loja temporaria de desconto entra no local 10, estoque varejo facil
				If lEstoque
					aadd(aReg,{"D1_LOCAL" , '10'  	,Nil})
				EndIf
				aadd(aReg,{"D1_TOTAL"  	, nD1_TOTAL  	,Nil})
				aadd(aReg,{"AUTDELETA" 	,"N"     		,Nil}) // Incluir sempre no último elemento do array de cada item

				aAdd(aAutoItens,aClone(aReg))
				TT0015I->(DbSkip())
			EndDo
		EndIf

		Mata103(aAutoCab, aAutoItens, 3, .T.)

		If !Empty(cNovosPro)
			Aviso("Novos Produtos Importados",AllTrim(cNovosPro),{"OK"},3)
		EndIf

	EndIf

Return


// Rotina que prepara importação do produto automática:
Static Function PreImpPro(cB1_CODBAR, cB1_COD)

	Local aAutoPro 		:= {}
	Local lRet			:= .T.
	Private cAutoBar	:= cB1_CODBAR
	// cB1_CODBAR  := Substr(cB1_CODBAR, 1, 12)

	AAdd( aAutoPro, { "B1_TIPO" 	, "ME"     			, Nil } )
	AAdd( aAutoPro, { "B1_PROC"    	, CA100FOR	  		, Nil } )
	AAdd( aAutoPro, { "B1_CODBAR"  	, cB1_CODBAR	  	, Nil } )

	lMsErroAuto := .F.
	Begin Transaction
		MSExecAuto({|x,y|Mata010(x,y)}, aAutoPro, 3)
		If lMsErroAuto
			lRet	:= .F.
			MostraErro()
			RollBackSX8()
			DisarmTransaction()
			break
		Else
			cNovosPro	+= cB1_COD + Chr(13) + Chr(10)

			//DANIEL VICTOR DA ROSA - 18/06/2025 REALIZANDO O AJUSTADO DE TE E GRTRIB CONFORME REGRAS REPASSADAS. INICIO
			SB1->(DBSetOrder(1))
			IF SB1->(DBSEEK(xFilial('SB1')+cB1_COD))

				oModel := FWLoadModel("MATA010")
				oModel:SetOperation(4)
				oModel:Activate()

				IF AllTrim(SB1->B1_POSIPI) == "33051000" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","019")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "33059000" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","020")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "33072010" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","021")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "33019030" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","022")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "34011900" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","023")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "34013000" //NÃO ALTERA B1_TE

					oModel:SetValue("SB1MASTER","B1_GRTRIB","024")

				ELSEIF AllTrim(SB1->B1_POSIPI) == "33074900"

					oModel:SetValue("SB1MASTER","B1_TE","053") //NÃO ALTERA B1_GRTRIB

				ENDIF

				If oModel:VldData()
					oModel:CommitData()
				EndIf

				oModel:DeActivate()
			Else
				//"Registro NAO LOCALIZADO!"
			EndIf
			//DANIEL VICTOR DA ROSA - 18/06/2025 FIM

		Endif
	End Transaction

Return lRet
