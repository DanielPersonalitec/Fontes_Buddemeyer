#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BUD1471 บ Daniel Victor da Rosa - Personalitec             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Produtos em Estoque.                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ REL-  02-10-2025                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
User Function BUD1471() //BUD789

	Local   oReport	:= Nil
	Private cTT789 := ""
	Private nTotalZ1 := 0
	Private cPerg := ""
	Private cTitulo := "Compara Produtos em Estoque"

	cPerg := "BUD789"

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica as  perguntas selecionadas                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	if !Pergunte(cPerg,.T.)
		Return
	EndIf

	oReport:= ReportDef() //(cAlias, cPergunte)
	//Dialogo do TReport
	RptStatus({|| oReport:PrintDialog() },cTitulo)

Return


Static Function ReportDef()

	Local oProd	as Object

	oReport := TReport():New('BUD1471',"Compara Produtos em Estoque",,{|oReport| PrintReport(oReport)},'Este relatorio comparar Produtos no Estoque.')

	oReport:SetLandscape() //layout horizontal
	oReport:nLineHeight := 40 //altura da linha
	//oReport:SetColSpace(1) //espaรงamento da coluna
	//oReport:SetTotalInLine(.t.) //totalizador de colunas
	oReport:nFontBody := 9
	oReport:cFontBody := "Arial"

	oProd :=  TRSection():New( oReport , "BUD1471" ,{"SB1","SB2","SB5","SC6"} , /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ ,;
		/*<uTotalText>*/ , /*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , .T./*<lLineBreak>*/ ,;
		/*<nLeftMargin>*/ , /*<lLineStyle>*/ , /*<nColSpace>*/ , .T./*<lAutoSize>*/ , /*<cCharSeparator>*/ , 2/*<nLinesBefore>*/ ,;
		/*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ )

	TRCell():New(oProd,"PRODSB1"   ,"BUD0156Z" ,"Produto"          ,/*Picture*/,20/*Tamanho do dado na Sx3*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,,.T./*Negrito*/)
	TRCell():New(oProd,"CODBAR"    ,"BUD0156Z" ,"Cod.Barras"       ,/*Picture*/,18,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"DESCRI"    ,"BUD0156Z" ,"Descri็ใo"        ,/*Picture*/,30,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"LOCAL"     ,"BUD0156Z" ,"Local"            ,/*Picture*/,4 ,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"QTDATU"    ,"BUD0156Z" ,"Estoque"          ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"QTDVEND"   ,"BUD0156Z" ,"Vendido"          ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"QTDDIS"    ,"BUD0156Z" ,"Disponivel"       ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"QTDALC"    ,"BUD0156Z" ,"Aloc. Jogo"       ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oProd,"QTDDPF"    ,"BUD0156Z" ,"Disponivel Final" ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

Static Function PrintReport(oReport)

	Local cQuery1  := ""
	Local cB2Local := ""
	Local cC6Local := ""
	Local nContImp := 0
	Local nCount   := 0
	Local nEstAloq := 0
	Local nEstRel  := 0
	Local nZYIa    := 0
	Local aDadoVal := {}
	Local oProd    := oReport:Section(1)

	FWMsgRun(, {||  aDadoVal := RetQtEtq() }, "Carregando dados dos Jogos","Aguarde Processando" )

	If (Select("cTT789") <> 0)
		dbSelectArea("cTT789")
		dbCloseArea()
	EndIf

	cTT789 := GetNextAlias()

	If  !EMPTY(mv_par06)
		cC6Local := " AND C6.C6_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') "
		cB2Local := " AND B2.B2_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') "
	EndIf

	cFilTES	:= ""
	If MV_PAR14 == 1
		cFilTES	:= " AND F4_ESTOQUE = 'S' "
	ElseIf MV_PAR14 == 2
		cFilTES	:= " AND F4_DUPLIC = 'S' "
	EndIf
	cFilPed	:= ""
	If !Empty(MV_PAR15) .And. !Empty(MV_PAR16)
		cFilPed	:= " AND C6_NUM NOT IN '"+MV_PAR15+"' AND '"+MV_PAR16+"' "
	EndIf

	cQuery1 := " SELECT "
	cQuery1 += " B1.B1_UM AS UNIDAMED, "
	cQuery1 += " B2.B2_COD AS PRODUTO, "
	cQuery1 += " B1.B1_CODBAR AS CODBARRAS, "
	cQuery1 += " B1.B1_DESC AS DESCR, "
	cQuery1 += " ISNULL(B5_FORCAO, '') AS COORD, "
	cQuery1 += " B2.B2_LOCAL AS LOCAL1, "
	cQuery1 += " B2.B2_QATU AS ESTOQUE, "
	cQuery1 += " 0 AS QTDVEN, "
	cQuery1 += " ' ' AS BLQ, "
	cQuery1 += " 'SB2' AS TAB "
	cQuery1 += " FROM " + RetSqlName("SB1") + " B1 (NOLOCK) "
	cQuery1 += " LEFT JOIN " + RetSqlName("SB5") + " SB5 (NOLOCK) "
	cQuery1 += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cQuery1 += " AND SB5.B5_COD = B1.B1_COD "
	cQuery1 += " AND SB5.D_E_L_E_T_ = ' ' "
	cQuery1 += " JOIN " + RetSqlName("SB2") + " B2 (NOLOCK) "
	cQuery1 += " ON B2.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND B2.B2_FILIAL = '" + xFilial("SB2") + "' "
	cQuery1 += " AND B2.B2_COD = B1.B1_COD " + cB2Local
	cQuery1 += " WHERE B1.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery1 += " AND B1.B1_MSBLQL <> '1' "
	cQuery1 += " AND B1.B1_TIPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery1 += " AND B1.B1_GRUPO BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
	cQuery1 += " AND B1.B1_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery1 += " GROUP BY B2.B2_COD, B1.B1_DESC, B2.B2_LOCAL, B2.B2_QATU, "
	cQuery1 += " B1.B1_CODBAR, B5_FORCAO, B1.B1_UM "
	cQuery1 += " UNION ALL " //UNION
	cQuery1 += " SELECT "
	cQuery1 += " B1.B1_UM AS UNIDAMED, "
	cQuery1 += " C6.C6_PRODUTO AS PRODUTO, "
	cQuery1 += " B1.B1_CODBAR AS CODBARRAS, "
	cQuery1 += " B1.B1_DESC AS DESCR, "
	cQuery1 += " ISNULL(B5_FORCAO, '') AS COORD, "
	cQuery1 += " C6.C6_LOCAL AS LOCAL1, "
	cQuery1 += " 0 AS ESTOQUE, "
	cQuery1 += " ISNULL(SUM(C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC),0) AS QTDVEN, "
	cQuery1 += " C6.C6_BLQ AS BLQ, "
	cQuery1 += " 'SC6' AS TAB "
	cQuery1 += " FROM " + RetSqlName("SB1") + " B1 (NOLOCK) "
	cQuery1 += " LEFT JOIN " + RetSqlName("SB5") + " SB5 (NOLOCK) "
	cQuery1 += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cQuery1 += " AND SB5.B5_COD = B1.B1_COD "
	cQuery1 += " AND SB5.D_E_L_E_T_ = ' ' "
	cQuery1 += " JOIN " + RetSqlName("SC6") + " C6 (NOLOCK) "
	cQuery1 += " ON C6.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cQuery1 += " AND C6.C6_PRODUTO = B1.B1_COD " + cC6Local
	cQuery1 += " AND C6.C6_NUM BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	cQuery1 += " AND C6.C6_ENTREG BETWEEN '" + DtoS(mv_par12) + "' AND '" + DtoS(mv_par13) + "' "
	cQuery1 += " AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0 " + cFilPed
	cQuery1 += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) "
	cQuery1 += " ON SF4.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
	cQuery1 += " AND SF4.F4_CODIGO = C6.C6_TES "
	cQuery1 += " WHERE B1.D_E_L_E_T_ = ' ' "
	cQuery1 += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery1 += " AND B1.B1_MSBLQL <> '1' " + cFilTES
	cQuery1 += " AND B1.B1_TIPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cQuery1 += " AND B1.B1_GRUPO BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
	cQuery1 += " AND B1.B1_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery1 += " AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0 "
	cQuery1 += " GROUP BY C6.C6_PRODUTO, B1.B1_DESC, C6.C6_LOCAL, C6.C6_QTDVEN, "
	cQuery1 += " C6.C6_BLQ, C6.C6_NUM, B1.B1_CODBAR, B5_FORCAO, B1.B1_UM "
	cQuery1 += " ORDER BY PRODUTO, LOCAL1, UNIDAMED, TAB "

	DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery1), "cTT789", .F., .T.)

	Count to nTotalZ1
	ProcRegua(nTotalZ1)
	cTT789->(DbGoTop())

	While cTT789->(!EOF())

		nCount++
		IncProc("Imprimindo registro " + cValToChar(nCount) + " de " + cValToChar(nTotalZ1) + "...")

		If (Empty(cTT789->PRODUTO)) .Or. (cTT789->ESTOQUE == 0 .AND. cTT789->QTDVEN == 0)
			dbSelectArea("cTT789")
			cTT789->(dbSkip())
			Loop
		Endif

		cProd := cTT789->PRODUTO
		cCodb := cTT789->CODBARRAS
		cDesc := cTT789->DESCR

		If "OPORTUNIDADE" $ AllTrim(cTT789->COORD)
			cDesc	:= AllTrim(cDesc)+" *OPORT.*"
			cDesc	:= Left(cDesc, 59)
		EndIf

		cLocal1	 := Space(2)
		nEstoq1  := 0
		nQtdVen1 := 0
		nSaldo1  := 0

		While cTT789->(!Eof()) .And. RTrim(cTT789->PRODUTO) == RTrim(cProd)
			cLocal1 := cTT789->LOCAL1
			nEstoq1	+= cTT789->ESTOQUE
			nQtdVen1+= cTT789->QTDVEN
			cTT789->(dbSkip())
		EndDo

		oProd:Init()

		nEstP := ""
		FOR nZYIa := 1 TO LEN(aDadoVal)
			IF ALLTRIM(cProd) == aDadoVal[nZYIa][2]
				nEstAloq +=  aDadoVal[nZYIa][3]
				nEstP +=  Alltrim(STR(nZYIa)) + " | "
			ENDIF
		NEXT nZYIa

		nSaldo1	+= nEstoq1 - nQtdVen1

		IF nEstAloq <> 0
			nEstRel := nEstAloq + IIf(!Empty(nEstoq1).or. !empty(nQtdven1)	, nSaldo1, 0)
		ELSE
			nEstRel := 0
		ENDIF

		IF MV_PAR09 == 1 .OR. MV_PAR09 == 2
			If	!Empty(cLocal1)
				nContImp++
				oProd:Cell("PRODSB1"):SetValue(cProd)
				oProd:Cell("CODBAR"):SetValue(cCodb)
				oProd:Cell("DESCRI"):SetValue(cDesc)
				oProd:Cell("LOCAL"):SetValue(IIf(!Empty(nEstoq1) .Or. !Empty(nQtdVen1) .Or. !Empty(nSaldo1), cLocal1, Space(02)))
				oProd:Cell("QTDATU"):SetValue(IIf(!Empty(nEstoq1)	,TRANSFORM(nEstoq1	,"@E 99,999,999.99"),Space(13)))
				oProd:Cell("QTDVEND"):SetValue(IIf(!Empty(nQtdVen1)	,TRANSFORM(nQtdVen1	,"@E 99,999,999.99"),Space(13)))
				oProd:Cell("QTDDIS"):SetValue(IIf(!Empty(nEstoq1).or. !empty(nQtdven1)	,TRANSFORM(nSaldo1	,"@E 99,999,999.99"),Space(13)))
				oProd:Cell("QTDALC"):SetValue(IIF(nEstAloq == 0  ,Space(13),TRANSFORM(nEstAloq	,"@E 99,999,999.99")))
				oProd:Cell("QTDDPF"):SetValue(IIF(nEstRel == 0  ,Space(13),TRANSFORM(nEstRel	,"@E 99,999,999.99")))
				oProd:PrintLine()
				nEstRel  := 0
				nEstAloq := 0
			endif
		Endif

	EndDo

	cTT789->(DbCloseArea())
	oProd:Finish()

Return

/*/{Protheus.doc} RetQtEtq()
	@FUNวรO RESPONSมVEL POR PEGAR A QUANTIDADE NECESSมRIA DE PRODUTOS
	@PARA MONTAR 1 KIT/JOGO/PACK
	@DANIEL VICTOR DA ROSA - PERSONALITEC
	@since 02/10/2025
/*/
Static Function RetQtEtq()

	Local cRetQry   := ""
	Local cRetQZY   := ""
	Local cTT7MZ    := ""
	Local nTotalZ2  := 0
	Local nTotalZ3  := 0
	Local cTT7ZY    := ""
	Local aDadosEst := {}

	If (Select("cTT7ZY") <> 0)
		dbSelectArea("cTT7ZY")
		dbCloseArea()
	EndIf

	cTT7ZY := GetNextAlias()

	cC6Local := ""
	cB2Local := ""
	If  !EMPTY(mv_par06)
		cC6Local := " AND C6.C6_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') "
		cB2Local := " AND B2.B2_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') "
	EndIf

	cFilTES	:= ""
	If MV_PAR14 == 1
		cFilTES	:= " AND F4_ESTOQUE = 'S' "
	ElseIf MV_PAR14 == 2
		cFilTES	:= " AND F4_DUPLIC = 'S' "
	EndIf
	cFilPed	:= ""
	If !Empty(MV_PAR15) .And. !Empty(MV_PAR16)
		cFilPed	:= " AND C6_NUM NOT IN '"+MV_PAR15+"' AND '"+MV_PAR16+"' "
	EndIf

	cRetQry := " SELECT "
	cRetQry += " B1.B1_UM AS UNIDAMED, "
	cRetQry += " B2.B2_COD AS PRODUTO, "
	cRetQry += " B1.B1_CODBAR AS CODBARRAS, "
	cRetQry += " B1.B1_DESC AS DESCR, "
	cRetQry += " ISNULL(B5_FORCAO, '') AS COORD, "
	cRetQry += " B2.B2_LOCAL AS LOCAL1, "
	cRetQry += " B2.B2_QATU AS ESTOQUE, "
	cRetQry += " 0 AS QTDVEN, "
	cRetQry += " ' ' AS BLQ, "
	cRetQry += " 'SB2' AS TAB "
	cRetQry += " FROM " + RetSqlName("SB1") + " B1 (NOLOCK) "
	cRetQry += " LEFT JOIN " + RetSqlName("SB5") + " SB5 (NOLOCK) "
	cRetQry += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cRetQry += " AND SB5.B5_COD = B1.B1_COD "
	cRetQry += " AND SB5.D_E_L_E_T_ = ' ' "
	cRetQry += " JOIN " + RetSqlName("SB2") + " B2 (NOLOCK) "
	cRetQry += " ON B2.D_E_L_E_T_ = ' ' "
	cRetQry += " AND B2.B2_FILIAL = '" + xFilial("SB2") + "' "
	cRetQry += " AND B2.B2_COD = B1.B1_COD " + cB2Local
	cRetQry += " WHERE B1.D_E_L_E_T_ = ' ' "
	cRetQry += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cRetQry += " AND B1.B1_MSBLQL <> '1' "
	cRetQry += " AND B1.B1_TIPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cRetQry += " AND B1.B1_GRUPO BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
	cRetQry += " AND B1.B1_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cRetQry += " AND B1.B1_UM = 'JG' "
	cRetQry += " GROUP BY B2.B2_COD, B1.B1_DESC, B2.B2_LOCAL, B2.B2_QATU, "
	cRetQry += " B1.B1_CODBAR, B5_FORCAO, B1.B1_UM "
	cRetQry += " UNION ALL " //UNION
	cRetQry += " SELECT "
	cRetQry += " B1.B1_UM AS UNIDAMED, "
	cRetQry += " C6.C6_PRODUTO AS PRODUTO, "
	cRetQry += " B1.B1_CODBAR AS CODBARRAS, "
	cRetQry += " B1.B1_DESC AS DESCR, "
	cRetQry += " ISNULL(B5_FORCAO, '') AS COORD, "
	cRetQry += " C6.C6_LOCAL AS LOCAL1, "
	cRetQry += " 0 AS ESTOQUE, "
	cRetQry += " ISNULL(SUM(C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC),0) AS QTDVEN, "
	cRetQry += " C6.C6_BLQ AS BLQ, "
	cRetQry += " 'SC6' AS TAB "
	cRetQry += " FROM " + RetSqlName("SB1") + " B1 (NOLOCK) "
	cRetQry += " LEFT JOIN " + RetSqlName("SB5") + " SB5 (NOLOCK) "
	cRetQry += " ON SB5.B5_FILIAL = '" + xFilial("SB5") + "' "
	cRetQry += " AND SB5.B5_COD = B1.B1_COD "
	cRetQry += " AND SB5.D_E_L_E_T_ = ' ' "
	cRetQry += " JOIN " + RetSqlName("SC6") + " C6 (NOLOCK) "
	cRetQry += " ON C6.D_E_L_E_T_ = ' ' "
	cRetQry += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "' "
	cRetQry += " AND C6.C6_PRODUTO = B1.B1_COD " + cC6Local
	cRetQry += " AND C6.C6_NUM BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' "
	cRetQry += " AND C6.C6_ENTREG BETWEEN '" + DtoS(mv_par12) + "' AND '" + DtoS(mv_par13) + "' "
	cRetQry += " AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0 " + cFilPed
	cRetQry += " INNER JOIN " + RetSqlName("SF4") + " SF4 (NOLOCK) "
	cRetQry += " ON SF4.D_E_L_E_T_ = ' ' "
	cRetQry += " AND SF4.F4_FILIAL = '" + xFilial("SF4") + "' "
	cRetQry += " AND SF4.F4_CODIGO = C6.C6_TES "
	cRetQry += " WHERE B1.D_E_L_E_T_ = ' ' "
	cRetQry += " AND B1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cRetQry += " AND B1.B1_MSBLQL <> '1' " + cFilTES
	cRetQry += " AND B1.B1_TIPO BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' "
	cRetQry += " AND B1.B1_GRUPO BETWEEN '" + mv_par10 + "' AND '" + mv_par11 + "' "
	cRetQry += " AND B1.B1_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cRetQry += " AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0 "
	cRetQry += " AND B1.B1_UM = 'JG' "
	cRetQry += " GROUP BY C6.C6_PRODUTO, B1.B1_DESC, C6.C6_LOCAL, C6.C6_QTDVEN, "
	cRetQry += " C6.C6_BLQ, C6.C6_NUM, B1.B1_CODBAR, B5_FORCAO, B1.B1_UM "
	cRetQry += " ORDER BY PRODUTO DESC, LOCAL1, UNIDAMED, TAB "

	DbUseArea(.T., "TOPCONN", TCGenQry( , , cRetQry), "cTT7ZY", .F., .T.)

	Count to nTotalZ2
	cTT7ZY->(DbGoTop())

	While cTT7ZY->(!EOF())

		If (Empty(cTT7ZY->PRODUTO)) .Or. (cTT7ZY->ESTOQUE == 0 .AND. cTT7ZY->QTDVEN == 0)
			dbSelectArea("cTT7ZY")
			cTT7ZY->(dbSkip())
			Loop
		Endif

		cProd := cTT7ZY->PRODUTO
		cDesc := cTT7ZY->DESCR

		If "OPORTUNIDADE" $ AllTrim(cTT7ZY->COORD)
			cDesc	:= AllTrim(cDesc)+" *OPORT.*"
			cDesc	:= Left(cDesc, 59)
		EndIf

		nEstoq1  := 0
		nQtdVen1 := 0
		nSaldo1  := 0

		While cTT7ZY->(!Eof()) .And. RTrim(cTT7ZY->PRODUTO) == RTrim(cProd)
			nEstoq1	+= cTT7ZY->ESTOQUE
			nQtdVen1+= cTT7ZY->QTDVEN
			cTT7ZY->(dbSkip())
		EndDo

		nSaldo1 := nEstoq1 - nQtdVen1

		IF nSaldo1 < 0

			If (Select("cTT7MZ") <> 0)
				dbSelectArea("cTT7MZ")
				dbCloseArea()
			EndIf

			cTT7MZ := GetNextAlias()

			cRetQZY := " SELECT G1_COD, G1_COMP, G1_QUANT  FROM "+RETSQLNAME('SG1') +" (NOLOCK) s "
			cRetQZY += " WHERE D_E_L_E_T_ =  ' ' "
			cRetQZY += " AND G1_COD = "+valtosql(alltrim(cProd))

			DbUseArea(.T., "TOPCONN", TCGenQry( , , cRetQZY), "cTT7MZ", .F., .T.)

			Count to nTotalZ3
			cTT7MZ->(DbGoTop())

			While cTT7MZ->(!Eof())
				Aadd(aDadosEst, {alltrim(cTT7MZ->G1_COD), alltrim(cTT7MZ->G1_COMP), cTT7MZ->G1_QUANT * nSaldo1})
				cTT7MZ->(dbSkip())
			EndDo
		ENDIF
	End

Return aDadosEst
