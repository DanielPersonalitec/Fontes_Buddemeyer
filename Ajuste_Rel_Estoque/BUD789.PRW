#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ BUD789 º Autor ³ Jonas Koslowski ³               29/05/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio Produtos em Estoque.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function BUD789()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP6 IDE                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("CPERG,TITULO,CDESC1,M_PAG")
	SetPrvt("CDESC2,CDESC3,TAMANHO,LIMITE,CSTRING")
	SetPrvt("ARETURN,NOMEPROG,NLASTKEY")
	SetPrvt("WNREL,LEND,CABEC1,CABEC2,lAbortPrint")

	cPerg := "BUD789"
	/*
	aRegistros := {}
	Aadd(aRegistros,{cPerg,"01","Produto de	      ?"	,"mv_ch1","C",15,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SB1"})
	Aadd(aRegistros,{cPerg,"02","Produto ate      ?"	,"mv_ch2","C",15,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","SB1"})
	Aadd(aRegistros,{cPerg,"03","Primeiro Local   ?"	,"mv_ch3","C",02,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"04","Segundo Local    ?"	,"mv_ch4","C",02,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"05","Tipo Prod. de	  ?"	,"mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"06","Tipo Prod. ate	  ?"	,"mv_ch6","C",02,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"07","Pedido de	      ?"	,"mv_ch7","C",06,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","",""})
	Aadd(aRegistros,{cPerg,"08","Pedido ate	      ?"	,"mv_ch8","C",06,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Imprime Saldo Zero       ?"  ,"mv_ch09","N",01,0,0,"C","","mv_par09","Nao","","","Sim","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Grupo de          ?","mv_ch10","C",04,0,0,"G","","mv_par10","","","","","","","","","","","","","","","SBM"})
	AADD(aRegistros,{cPerg,"11","Grupo ate         ?","mv_ch11","C",04,0,0,"G","","mv_par11","","","","","","","","","","","","","","","SBM"})
	CriaPerguntas(cPerg,aRegistros)
	*/

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as  perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	if !Pergunte(cPerg,.T.)
		Return
	EndIf

	titulo := "Compara Produtos em Estoque"
	cDesc1 := "Este relatorio comparar Produtos "
	cDesc2 := "no estoque."
	cDesc3 := ""
	nLin := 80
	tamanho:="G"
	limite := 80
	cString:="SC6"

	aReturn := { "Zebrado", 1,"Administracao", 1, 2, 1, "",1 }
	nomeprog:="BUD789"
	nLastKey := 0
	M_PAG := 1

	//cPerg   :="BUD789"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01            // A partir da data                      ³
	//³ mv_par02            // Ate a data                            ³
	//³ mv_par03            // Vendedor de                           ³
	//³ mv_par04 	      	// Vendedor ate                          ³
	//³ mv_par05	      	// Cliente de                            ³
	//³ mv_par06            // Cliente ate                           ³
	//³ mv_par07            // Salta pagina entre vendedores(Sim/Nao)³
	//³ mv_par08            // Considera Pedidos Cancelados (Sim/Nao)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia controle para a funcao SETPRINT                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel:="BUD789"            //Nome Default do relatorio em Disco

	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"")
	nomeprog := wnrel

	If  nLastKey==27
		Set Filter to
		Return
	Endif

	SetDefault(aReturn,cString)
	If nLastKey==27
		Set Filter to
		Return
	Endif

	Processa({|| GeraDados() }, titulo)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


Static Function GeraDados()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Definicao dos cabecalhos                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Incluido coluna Cod.Barras - Robson JP 11/04/2018
	titulo := " Compara Produtos em Estoque"
	cabec1 := "Produto              Cod.Barras            Descrição                                                 Local       Estoque       Vendido     Disponivel        Local         Estoque       Vendido    Disponivel"
	cabec2 := ""
	cC6Local := ""
	cB2Local := ""
	// cLocal := ""
	nLin   := 80

	If (Select("TT789") <> 0)
		dbSelectArea("TT789")
		dbCloseArea()
	EndIf

	// Criado filtro separado dos locais para SC6 e SB2. - RobsonJP 20241107
	If  !EMPTY(mv_par06)
		cC6Local := "% AND C6.C6_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') %"
		cB2Local := "% AND B2.B2_LOCAL IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') %"
		// cLocal := "% IN" +"('"+ AllTrim(mv_par03)+"'" +","+"'"+ AllTrim(mv_par04)+"') %"
	EndIf

	// Thiago 13/09/2016 inclusão de mais 3 filtros e retirado regra fixa do "K":
	cFilTES	:= "% %"
	If MV_PAR14 == 1
		cFilTES	:= "% AND F4_ESTOQUE = 'S' %"
	ElseIf MV_PAR14 == 2
		cFilTES	:= "% AND F4_DUPLIC = 'S' %"
	EndIf
	cFilPed	:= "% %"
	If !Empty(MV_PAR15) .And. !Empty(MV_PAR16)
		cFilPed	:= "% AND C6_NUM NOT IN '"+MV_PAR15+"' AND '"+MV_PAR16+"' %"
	EndIf

	BeginSql Alias "TT789"
		%noParser%

		Column ESTOQUE AS NUMERIC (14, 2)
		Column QTDVEN AS NUMERIC (14, 2)
		SELECT
			B2.B2_COD AS PRODUTO,
			B1.B1_CODBAR AS CODBARRAS,
			B1.B1_DESC AS DESCR,
			ISNULL(B5_FORCAO, '') AS COORD,
			B2.B2_LOCAL AS LOCAL1,
			B2.B2_QATU AS ESTOQUE,
			0 AS QTDVEN,
			' ' AS BLQ,
			'SB2' AS TAB
		FROM
			%Table:SB1% B1 (NOLOCK)
		LEFT JOIN %Table:SB5% (NOLOCK)
		ON B5_FILIAL = %xFilial:SB5%
			AND B5_COD = B1.B1_COD
			AND SB5010.%NotDel%
		JOIN %Table:SB2% B2 (NOLOCK)
		ON B2.%NotDel%
			AND B2.B2_FILIAL = %xFilial:SB2%
			AND B2.B2_COD = B1.B1_COD %Exp:cB2Local%
		WHERE
			B1.%NotDel%
			AND B1.B1_FILIAL = %xFilial:SB1%
			AND B1.B1_MSBLQL <> '1'
			AND B1.B1_TIPO BETWEEN %exp:mv_par05% AND %exp:mv_par06%
			AND B1.B1_GRUPO BETWEEN %exp:mv_par10% AND %exp:mv_par11%
			AND B1.B1_COD BETWEEN %exp:mv_par01% AND %exp:mv_par02%
		GROUP BY
			B2.B2_COD,
			B1.B1_DESC,
			B2.B2_LOCAL,
			B2.B2_QATU,
			B1.B1_CODBAR,
			B5_FORCAO
		UNION
		ALL
		SELECT
			C6.C6_PRODUTO AS PRODUTO,
			B1.B1_CODBAR AS CODBARRAS,
			B1.B1_DESC AS DESCR,
			ISNULL(B5_FORCAO, '') AS COORD,
			C6.C6_LOCAL AS LOCAL1,
			0 AS ESTOQUE,
			ISNULL(SUM(C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC), 0) AS QTDVEN,
			C6.C6_BLQ AS BLQ,
			'SC6' AS TAB
		FROM
			%Table:SB1% B1 (NOLOCK)
		LEFT JOIN %Table:SB5% (NOLOCK)
		ON B5_FILIAL = %xFilial:SB5%
			AND B5_COD = B1.B1_COD
			AND SB5010.%NotDel%
		JOIN %Table:SC6% C6 (NOLOCK)
		ON C6.%NotDel%
			AND C6.C6_FILIAL = %xFilial:SC6%
			AND C6.C6_PRODUTO = B1.B1_COD %Exp:cC6Local%
			AND C6.C6_NUM BETWEEN %exp:mv_par07% AND %exp:mv_par08%
			AND C6.C6_ENTREG BETWEEN %exp:DTOS(mv_par12)% AND %exp:DTOS(mv_par13)%
			AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0 %Exp:cFilPed%
		INNER JOIN %Table:SF4% (NOLOCK)
		ON %Table:SF4%.%NotDel%
			AND F4_FILIAL = %xFilial:SF4%
			AND F4_CODIGO = C6_TES
		WHERE
			B1.%NotDel%
			AND B1.B1_FILIAL = %xFilial:SB1%
			AND B1.B1_MSBLQL <> '1' %Exp:cFilTES%
			AND B1.B1_TIPO BETWEEN %exp:mv_par05% AND %exp:mv_par06%
			AND B1.B1_GRUPO BETWEEN %exp:mv_par10% AND %exp:mv_par11%
			AND B1.B1_COD BETWEEN %exp:mv_par01% AND %exp:mv_par02%
			AND (C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0
		GROUP BY
			C6.C6_PRODUTO,
			B1.B1_DESC,
			C6.C6_LOCAL,
			C6.C6_QTDVEN,
			C6.C6_BLQ,
			C6.C6_NUM,
			B1.B1_CODBAR,
			B5_FORCAO
		ORDER BY
			PRODUTO,
			LOCAL1,
			TAB
	EndSql

Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	dbSelectArea("TT789")
	dbGoTop()
	SetRegua(RecCount())
	While !TT789->(EOF())

		IncRegua("Imprimindo ...")

		If 	lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		If (Empty(TT789->PRODUTO)) .Or. (TT789->ESTOQUE == 0 .AND. TT789->QTDVEN == 0)
			dbSelectArea("TT789")
			dbSkip()
			Loop
		Endif

		IF 	nLin >60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho)
			nLin:=8
		EndIF

		cProd		:= TT789->PRODUTO
		cCodb       := TT789->CODBARRAS
		cDesc		:= TT789->DESCR
		If "OPORTUNIDADE" $ AllTrim(TT789->COORD)
			cDesc	:= AllTrim(cDesc)+" *OPORT.*"
			cDesc	:= Left(cDesc, 59)
		EndIf

		cLocal1	:= Space(2)
		nEstoq1 := 0
		nQtdVen1:= 0
		nSaldo1 := 0
		nDISP1  :=0

		cLocal2 := Space(2)
		nEstoq2 := 0
		nQtdVen2:= 0
		nSaldo2 := 0
		nDISP2  :=0

		While !TT789->(Eof()) .And. RTrim(TT789->PRODUTO) == RTrim(cProd)

			If	RTrim(TT789->LOCAL1) = RTrim(mv_par03)
				cLocal1 := TT789->LOCAL1
				nEstoq1	+= TT789->ESTOQUE
				nQtdVen1+= TT789->QTDVEN
			Else
				cLocal2 := TT789->LOCAL1
				nEstoq2	+= TT789->ESTOQUE
				nQtdVen2+= TT789->QTDVEN
			EndIf

			TT789->(dbSkip())

		EndDo

		nDISP1	+= nEstoq1 - nQtdVen1
		nDISP2	+= nEstoq2 - nQtdVen2
		IF MV_PAR09 == 1

			If	!Empty(cLocal1) .Or. !Empty(cLocal2)

				//@nLin, 000  PSAY cProd
				//@nLin, 017  PSAY cDesc
				IF 	(nEstoq1 - nQtdVen1)>0
					@nLin, 000  PSAY cProd
					@nLin, 022  PSAY cCodb //Incluido - RobsonJP 11/04/2018
					@nLin, 044  PSAY cDesc
					@nLin, 104  PSAY IIf	(!Empty(nEstoq1) .Or. !Empty(nQtdVen1) .Or. !Empty(nSaldo1), cLocal1, Space(02))
					@nLin, 106  PSAY IIf	(!Empty(nEstoq1)	,TRANSFORM(nEstoq1	,"@E 99,999,999.99"),Space(13))
					@nLin, 119  PSAY IIf	(!Empty(nQtdVen1)	,TRANSFORM(nQtdVen1	,"@E 99,999,999.99"),Space(13))
					nSaldo1	+= nEstoq1 - nQtdVen1
					@nLin, 132	PSAY IIf	(!Empty(nEstoq1).or. !empty(nQtdven1)	,TRANSFORM(nSaldo1	,"@E 99,999,999.99"),Space(13))
					nLin++
				ENDIF

				IF 	(nEstoq2 - nQtdVen2)>0
					@nLin, 000  PSAY cProd
					@nLin, 022  PSAY cCodb //Incluido - RobsonJP 11/04/2018
					@nLin, 044  PSAY cDesc
					@nLin, 157  PSAY IIf	(!Empty(nEstoq2) .Or. !Empty(nQtdVen2) .Or. !Empty(nSaldo2), cLocal2, Space(02))
					@nLin, 162  PSAY IIf	(!Empty(nEstoq2)	,TRANSFORM(nEstoq2	,"@E 99,999,999.99"),Space(13))
					@nLin, 175  PSAY IIf	(!Empty(nQtdVen2)	,TRANSFORM(nQtdVen2	,"@E 99,999,999.99"),Space(13))
					nSaldo2	+= nEstoq2 - nQtdVen2
					@nLin, 188  PSAY IIf (!Empty(nEstoq2).or. !empty(nQtdven2)	,TRANSFORM(nSaldo2	,"@E 99,999,999.99"),Space(13))
					nLin++
				ENDIF
				//nLin++
			endif
		Else
			If	!Empty(cLocal1) .Or. !Empty(cLocal2)

				@nLin, 000  PSAY cProd
				@nLin, 022  PSAY cCodb //Incluido - RobsonJP 11/04/2018
				@nLin, 044  PSAY cDesc
				@nLin, 104  PSAY IIf	(!Empty(nEstoq1) .Or. !Empty(nQtdVen1) .Or. !Empty(nSaldo1), cLocal1, Space(02))
				@nLin, 106  PSAY IIf	(!Empty(nEstoq1)	,TRANSFORM(nEstoq1	,"@E 99,999,999.99"),Space(13))
				@nLin, 119  PSAY IIf	(!Empty(nQtdVen1)	,TRANSFORM(nQtdVen1	,"@E 99,999,999.99"),Space(13))
				nSaldo1	+= nEstoq1 - nQtdVen1
				@nLin, 132	PSAY IIf	(!Empty(nEstoq1).or. !empty(nQtdven1)	,TRANSFORM(nSaldo1	,"@E 99,999,999.99"),Space(13))

				@nLin, 157  PSAY IIf	(!Empty(nEstoq2) .Or. !Empty(nQtdVen2) .Or. !Empty(nSaldo2), cLocal2, Space(02))
				@nLin, 162  PSAY IIf	(!Empty(nEstoq2)	,TRANSFORM(nEstoq2	,"@E 99,999,999.99"),Space(13))
				@nLin, 175  PSAY IIf	(!Empty(nQtdVen2)	,TRANSFORM(nQtdVen2	,"@E 99,999,999.99"),Space(13))
				nSaldo2	+= nEstoq2 - nQtdVen2
				@nLin, 188  PSAY IIf (!Empty(nEstoq2).or. !empty(nQtdven2)	,TRANSFORM(nSaldo2	,"@E 99,999,999.99"),Space(13))
				nLin++
			endif
			//Endif
			/*IF 	TT789->(EOF())
			EXIT
			EndIf*/
		Endif

	EndDo

	Roda(0,"",tamanho)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finaliza a execucao do relatorio...                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If 	aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

/*Static Function CriaPerguntas(cGrupo,aPer)
LOCAL aReg  := {}
DbSelectArea("SX1")
If (FCount() == 39)
For _l := 1 to Len(aPer)
Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
Next _l
Elseif (FCount() == 26)
aReg := aPer
Endif

DbSelectArea("SX1")
For _l := 1 to Len(aReg)
If !DbSeek(cGrupo+StrZero(_l,02,00))
RecLock("SX1",.T.)
For _m := 1 to FCount()
FieldPut(_m,aReg[_l,_m])
Next _m
MsUnlock("SX1")
Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
RecLock("SX1",.F.)
For _k := 1 to FCount()
FieldPut(_k,aReg[_l,_k])
Next _k
MsUnlock("SX1")
Endif
Next _l
Return*/
