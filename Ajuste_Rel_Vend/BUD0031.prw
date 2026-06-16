#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
/=========================================================================\
|Módulo      : Vendas/Faturamento               	                   	  |
|=========================================================================|
|Programa    : BUD0031.PRW  | Responsável: Thiago Lucas Machado           |
|=========================================================================|
|Descricao   : Relatório de Vendas - Resumido                    	      |
|=========================================================================|
|Data        : 31/10/2013 												  |
|=========================================================================|
|Programador : Thiago Lucas Machado								          |
\=========================================================================/
*/

User Function BUD0031()

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatório de Vendas - Sintético"

	Private aReturn      := {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private wnrel     	 := ""
	Private m_pag    	 := 01
	Private limite       := 220
	Private nLastKey     := 0
	Private nTipo        := 18
	Private tamanho      := "M"

	Private cPedidos	 := ""

	// -- Cadastrado no Configurador
	If !Pergunte("BUD0031",.T.)
		Return
	EndIf

	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		Msgstop("Ocorreu um erro na tentativa gerar o relatório. Gentileza verifique os campos!")
		Return
	EndIf

	wnrel := SetPrint("SF2","BUD0031","",cDesc3,cDesc1,cDesc2,cDesc3,.F.,.F.,.T.,tamanho,,.F.,.F.,,,)
	//wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	//SetPrint - ( cAliascProgram [ cPergunte ] [ cTitle ] [ cDesc1 ] [ cDesc2 ] [ cDesc3 ] [ lDic ] [ aOrd ] [ lCompres ] [ cSize ] [ uParm12 ] [ lFilter ] [ lCrystal ] [ cNameDrv ] [ uParm16 ] [ lServer ] [ cPortPrint ] ) --> cReturn
	If nLastKey == 27
		Return
	Endif
	SetDefault(aReturn,"SF2")
	If nLastKey == 27
		Return
	Endif

	MsgRun("Aguarde, gerando o relatório...","Aguarde",{|| GeraRel() })

Return

Static Function GeraRel()

	Local Cabec1    	:= "Série     Número    Cliente                                                 Tickets               Quantidade              Valor "
	Local Cabec2    	:= "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345679801234567890123456789012345678901234567890"

	Local Cabec2    	:= ""
	Local nLin			:= 8

	Local nTotQuant	:= 0
	Local nTotValor	:= 0
	Local nValVen	:= 0
	Local nTotPed	:= 0

	Private cSerLjTemp := SuperGetMV("BD_SERTMP")

	Cabec("Relatório de Vendas de "+DtoC(MV_PAR01)+" até "+DtoC(MV_PAR02)+" ",Cabec1,Cabec2,"BUD0031","M",15)

	If (Select("TT0031A") <> 0)
		dbSelectArea("TT0031A")
		dbCloseArea()
	EndIf
	cQuery := "SELECT DISTINCT F2_SERIE, F2_DOC, A1_COD, A1_NOME, SUM(D2_QUANT) AS QTD, SUM(D2_TOTAL) AS VLR, F2_VALPROM, F2_EMISSAO, F2_FRETE "
	cQuery += "  FROM "+RetSqlName("SF2")+" (NOLOCK)  "
	cQuery += "INNER JOIN "+RetSqlName("SD2")+" (NOLOCK) ON "+RetSqlName("SD2")+".D_E_L_E_T_ = '' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA "
	cQuery += "INNER JOIN "+RetSqlName("SA1")+" (NOLOCK) ON "+RetSqlName("SA1")+".D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQuery += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON "+RetSqlName("SF4")+".D_E_L_E_T_ = '' AND F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D2_TES "
	cQuery += "WHERE "+RetSqlName("SF2")+".D_E_L_E_T_ = '' AND F2_FILIAL = '"+xFilial("SF2")+"' "
	cQuery += "AND F2_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
	cQuery += "AND D2_TES NOT IN ('515') " //não considerar consignação
	//cQuery += "AND D2_CF IN('5949','6949','5922','6922','5923','5912') "
	if MV_PAR04 == 1 /*Alterado para considerar as series do varejo facil Erik.N 23-11-2023*/
		cQuery += "AND F2_SERIE IN ("+cSerLjTemp+")"
		//cQuery += "AND F2_VEND1 = '000011' " // Quando empório este vendedor é só usado para vendas na loja temporária.
	ElseIf MV_PAR04 == 2
		cQuery += "AND F2_SERIE NOT IN ("+cSerLjTemp+")"
		//cQuery += "AND F2_VEND1 != '000011' "
	EndIf
	if MV_PAR09 == 2
		cQuery += "AND D2_TES <> '550' "
		cQuery += "AND D2_TES <> '902' "
		cQuery += "AND D2_TES <> '511' "
	EndIf

	if MV_PAR08 == 2
		cQuery += "	AND F4_ISS <> 'S' "
		cQuery += "AND ((F4_ESTOQUE = 'S' AND  F4_DUPLIC = 'S' )"
	else
		cQuery += "AND ((F4_ESTOQUE = 'S' AND  F4_DUPLIC = 'S' )"
		cQuery += "or (	 F4_ISS = 'S' and F4_ESTOQUE = 'N' AND  F4_DUPLIC = 'S')
	EndIf
	//cQuery += "AND (F4_ESTOQUE = 'S' OR F2_SERIE = 'XXX') AND F4_DUPLIC = 'S' "
	/*Gabriel - Tratativas para novos Filtros*/


	iF  MV_PAR09 == 1 // SIMPLES REMESSA
		cQuery += " OR ( (F4_DUPLIC = 'S') and (F4_ESTOQUE = 'N' )  and D2_CF IN('5922','6922')  )"
	ENDIF
	iF  MV_PAR10 == 1 //Venda Futura ?
		cQuery += " OR ( (F4_DUPLIC = 'N') and (F4_ESTOQUE = 'S' ) and D2_CF IN('5117','6117')  )"
	ENDIF
	iF  MV_PAR11 == 1 //Remessa Locacao
		cQuery += " OR( (F4_DUPLIC = 'N') and (F4_ESTOQUE = 'S' ) and D2_CF IN('5949','6949')  )"
	ENDIF
	cQuery += ")"
	iF  MV_PAR12 == 2 //Remessa Locacao
		cQuery += " AND SUBSTRING(A1_CGC,1,8) NOT IN ('04740770','07035484')"
	ENDIF
	//if MV_PAR06 == 1
	//	cQuery += "AND F4_ESTOQUE = 'S' "
	//	cQuery += "AND (F4_ESTOQUE = 'S' OR F2_SERIE = 'XXX' "
	//	if MV_PAR08 == 2
	//		cQuery += "	AND F4_ISS <> 'S' "
	//	EndIf
	//	cQuery += ") "
	//Elseif MV_PAR06 == 2
	//	cQuery += "AND F4_DUPLIC = 'S' "
	//Elseif MV_PAR06 == 3
	//	cQuery += "AND D2_TES <> '591' "
	//	cQuery += "AND( (F4_DUPLIC = 'S') "
	//	cQuery += " or (F4_ESTOQUE = 'S' OR F2_SERIE = 'XXX' "
	//	if MV_PAR08 == 1
	//		cQuery += "	OR F2_SERIE = 'UN' "
	//	EndIf
	//	cQuery += ") )"
	//EndIf
	cQuery += "AND (D2_PRCVEN > 0 OR D2_PVTOT > 0) "
	cQuery += "AND F2_TIPO = 'N' "
	//cQuery += "AND (NOT (F2_NFCUPOM <> '' AND F2_SERIE = '1')) "
	cQuery += "AND (NOT (F2_NFCUPOM <> '' AND F2_SERIE = '1')) "
	cQuery += "GROUP BY F2_SERIE, F2_DOC, A1_COD, A1_NOME, F2_VALPROM, F2_EMISSAO, F2_FRETE "

	// Alterada query da SD1 para considerar o valor do desconto na devolucao SUM((D1_TOTAL - D1_VALDESC) * (-1)) AS VLR, validado por Thais. Erik.N 08/03/2022
	If MV_PAR05 == 1
		cQuery += " UNION "
		cQuery += "SELECT DISTINCT F1_SERIE AS F2_SERIE, F1_DOC AS F2_DOC, A1_COD, A1_NOME, SUM(D1_QUANT * (-1)) AS QTD, SUM((D1_TOTAL - D1_VALDESC) * (-1)) AS VLR, 0 AS F2_VALPROM, F1_EMISSAO AS F2_EMISSAO, 0 AS F2_FRETE "
		cQuery += "  FROM "+RetSqlName("SF1")+" (NOLOCK)  "
		cQuery += "INNER JOIN "+RetSqlName("SD1")+" (NOLOCK) ON "+RetSqlName("SD1")+".D_E_L_E_T_ = '' AND D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
		cQuery += "INNER JOIN "+RetSqlName("SA1")+" (NOLOCK) ON "+RetSqlName("SA1")+".D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA "
		cQuery += "WHERE "+RetSqlName("SF1")+".D_E_L_E_T_ = '' AND F1_FILIAL = '"+xFilial("SF1")+"' "
		cQuery += "AND F1_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
		cQuery += "AND F1_TIPO = 'D' "
		if MV_PAR04 == 1 // Inserido para tratar a serie da devolucao se filtro atacado ou varejo Erik.N 23-11-2023
			cQuery += "AND F1_SERIE IN ("+cSerLjTemp+")"
		ElseIf MV_PAR04 == 2
			cQuery += "AND F1_SERIE NOT IN ("+cSerLjTemp+")"
		EndIf
		cQuery += "GROUP BY F1_SERIE, F1_DOC, A1_COD, A1_NOME, F1_EMISSAO "
	EndIf

	cQuery += "ORDER BY F2_EMISSAO ASC, F2_SERIE ASC, F2_DOC ASC "
	U_VRN0159(cQuery)

	TCQuery cQuery NEW ALIAS "TT0031A"

	MemoWrite("BUD0031.SQL", cQuery)
	DBSELECTAREA("TT0031A")
	While !TT0031A->(EOF())

		If nLin > 75
			Cabec("Relatório de Vendas de "+DtoC(MV_PAR01)+" até "+DtoC(MV_PAR02)+" ",Cabec1,Cabec2,"BUD0031","M",15)
			nLin	:= 8
		EndIf

		nValVen	:= TT0031A->VLR
		if MV_PAR03 == 1
			If !Empty(TT0031A->F2_VALPROM)
				nValVen	:= TT0031A->F2_VALPROM
			EndIf
		EndIf

		If MV_PAR07 == 1
			nValVen	+= TT0031A->F2_FRETE
		EndIf

		@nLin,000 PSAY TT0031A->F2_SERIE
		@nLin,010 PSAY TT0031A->F2_DOC
		@nLin,020 PSAY Substr(TT0031A->A1_NOME, 1, 40)
		@nLin,090 PSAY Transform(TT0031A->QTD, "@E 999,999,999")
		@nLin,112 PSAY Transform(nValVen, "@E 999,999,999.99")

		nTotQuant	+= TT0031A->QTD
		nTotValor	+= nValVen
		nTotPed		++

		nLin++
		TT0031A->(dbSkip())
	ENDDO
	DBCloseArea("TT0031A")

	nLin++
	nLin++
	@nLin,000 PSAY REPLICATE("-", 132)
	nLin++
	@nLin,000 PSAY "Total ->"
	@nLin,080 PSAY nTotPed
	@nLin,090 PSAY Transform(nTotQuant, "@E 999,999,999")
	@nLin,112 PSAY Transform(nTotValor, "@E 999,999,999.99")
	nLin++
	@nLin,000 PSAY REPLICATE("-", 132)
	nLin++

	Roda(0,"","M")
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()

Return
