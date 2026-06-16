#include "rwmake.ch"
#include "protheus.ch"
#include "colors.ch"
#include "topconn.ch"
#include "ap5mail.ch"

/*SIGAVILLE
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Cliente      ³ Microsiga                                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Programa     ³ SF2460I.PRX      ³ Responsavel ³ Cristiano Novak        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡„o    ³ Gravar Percentual Desconto Financeiro em titulos        ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Data        ³ 28/01/99         ³ Implantacao ³ 28/01/99               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Programador ³ Cristiano Novak                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Objetivos   ³ Gravar Percentual de desconto financeiro do cabecalho   ³±±
	±±³             ³ do pedido nos titulos gerados no financeiro quando da   ³±±
	±±³             ³ preparacao da nota fiscDataValidaal                               ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Arquivos    ³ SD2    SE1    SC5                                       ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Indices     ³ SD2(3) SE1(1) SC5(1)                                    ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Parametros  ³                                                         ³±±
	±±³             ³                                                         ³±±
	±±³             ³                                                         ³±±
	±±³             ³                                                         ³±±
	±±³             ³                                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Observacoes ³                                                         ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Cuidados na ³                                                         ³±±
	±±³ Atualizacao ³                                                         ³±±
	±±³ de versao   ³                                                         ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	- 12-06-2024 - Alterações referente transmissão GNRE Budd.
*/

User Function SF2460I()


	Local aArea 	  := GetArea()
	Local aAreaSF2 	  := SF2 -> ( GetArea("SF2") )
	Local aGrpUser    := {}
	Local cServer     := SuperGetMv("MV_SERCONE",.T.,'') //GETMV("MV_RELSERV")
	Local cConta      := GetMV("MV_RELACNT")
	Local cSenhaMail  := GetMV("MV_RELPSW")
	Local aFatura     := {}
	Local nDIFAL      := 0
	Local nFECCP      := 0
	Local nParcelas	  := 0
	Local nValParc	  := 0
	Local nTotParc	  := 0
	Local nRecnoSD2   := 0
	Local aParcelas	  := {}
	Local aArea 	  := GetArea()
	Local aAreaSF2 	  := SF2 -> ( GetArea("SF2") )
	Local nInc		  := 0
	Local _codRec 	  := space(tamSx3('F6_CODREC')[1])
	Local cNumConv    := space(tamSx3('F6_NUMCONV')[1])
	Local lGDifal     := .F.
	Local lGFcpDif    := .F.
	Local cNomForn    := ''
	Local lGuiaFecp   := .F.
	Local lGuiaDifal  := .F.

	SetPrvt("NDESCFIN,NVLFAT")
	Private cFatura:= Space(06)
	Private cSeqFat:= Space(02)
	Private lDesc  := SuperGetMv("MV_DESCBUD",.T.,.F.)
	Private cTESDesc:=  SuperGetMv("MV_DESCTES",.T.,.F.)
	Private cMVFATCX  := GetMV("MV_FATCX")
	Private cNumSe2:=''
	Private nDESCZFR:=0
	Private nDESCZFP:=0
	Private nDESCZFC:=0
	Private cDesc:=" "

	Private cPrcBruto	:= SuperGetMV("MV_PRCBRUT")

	If cEmpAnt == '03'
		Return (nil)
	EndIf

	Reclock("SF2",.F.)

	If	LEFT(SF2->F2_CLIENTE,2) == 'EX'
		If	(Select('TTSF2')<> 0)
			dbSelectArea('TTSF2')
			dbCloseArea()
		EndIf

		//, ZZ1_QTDCXA
		BeginSql Alias 'TTSF2'
			%noparser%

			SELECT
				ZZ1_PEDIDO,
				ZZ1_PBRUTO,
				ZZ1_PLIQUI,
				F2_PLIQUI,
				F2_PBRUTO
			FROM
				%Table:ZZ1% ZZ1 (NOLOCK),%Table:ZZ2% ZZ2 (NOLOCK),%Table:SD2% SD2 (NOLOCK),%Table:SF2% SF2 (NOLOCK)
			WHERE
				ZZ1.%NotDel%
				AND ZZ1_FILIAL = %xFilial:ZZ1%
				AND ZZ2.%NotDel%
				AND ZZ2_FILIAL = %xFilial:ZZ2%
				AND SD2.%NotDel%
				AND D2_FILIAL = %xFilial:SD2%
				AND SF2.%NotDel%
				AND F2_FILIAL = %xFilial:SF2%
				AND F2_DOC = %exp:SF2->F2_DOC%
				AND F2_SERIE = %exp:SF2->F2_SERIE%
				AND F2_DOC = D2_DOC
				AND F2_SERIE = D2_SERIE
				AND ZZ1_NUMPAC = ZZ2_NUMPAC
				AND ZZ1_PEDIDO = D2_PEDIDO
				AND ZZ2_ITEPV = D2_ITEMPV
				AND ZZ1_NUMPAC = D2_NUMPAC
			GROUP BY
				F2_PLIQUI,
				F2_PBRUTO,
				ZZ1_PBRUTO,
				ZZ1_PLIQUI,
				ZZ1_PEDIDO
		EndSql
		//, ZZ1_QTDCXA

		TCSetField("TTSF2","ZZ1_PBRUTO","N",TamSx3('ZZ1_PBRUTO')[1],TamSx3('ZZ1_PBRUTO')[2])
		TCSetField("TTSF2","ZZ1_PLIQUI","N",TamSx3('ZZ1_PLIQUI')[1],TamSx3('ZZ1_PLIQUI')[2])
		TCSetField("TTSF2","F2_PLIQUI" ,"N",TamSx3('F2_PLIQUI' )[1],TamSx3('F2_PLIQUI' )[2])
		TCSetField("TTSF2","F2_PBRUTO" ,"N",TamSx3('F2_PBRUTO' )[1],TamSx3('F2_PBRUTO' )[2])
		//TCSetField("TTSF2","ZZ1_QTDCXA","N",TamSx3('ZZ1_QTDCXA')[1],TamSx3('ZZ1_QTDCXA')[2])

		nPLiqui := 0
		nPBruto := 0
		//nVolume1:= 0
		IF TTSF2->(Eof())
			If	(Select('TTSF2B')<> 0)
				dbSelectArea('TTSF2B')
				dbCloseArea()
			EndIf
			BeginSql Alias 'TTSF2B'
				%noparser%

				SELECT
					C5.C5_PESOL,
					C5.C5_PBRUTO
				FROM
					%Table:SF2% F2 (NOLOCK)
				INNER JOIN %Table:SD2% D2 (NOLOCK)
				ON D2.D2_FILIAL = %xFilial:SD2%
					AND D2.D2_DOC = F2.F2_DOC
					AND D2.D2_SERIE = F2.F2_SERIE
					AND D2.%NotDel%
				INNER JOIN %Table:SC5% C5 (NOLOCK)
				ON C5.C5_FILIAL = %xFilial:SC5%
					AND C5.C5_NUM = D2.D2_PEDIDO
					AND C5.%NotDel%
				WHERE
					F2.F2_FILIAL = %xFilial:SF2%
					AND F2.%NotDel%
					AND F2_DOC = %exp:SF2->F2_DOC%
					AND F2_SERIE = %exp:SF2->F2_SERIE%
				GROUP BY
					C5.C5_PESOL,
					C5.C5_PBRUTO
			EndSql
			TTSF2B->(DBGOTOP())
			nPLiqui := TTSF2B->C5_PESOL
			nPBruto := TTSF2B->C5_PBRUTO

		ELSE

			While !TTSF2->(Eof())
				nPLiqui += TTSF2->ZZ1_PLIQUI
				nPBruto += TTSF2->ZZ1_PBRUTO
				//nVolume1+= TTSF2->ZZ1_QTDCXA
				TTSF2->(dbSkip())
			End
		ENDIF
		SF2->F2_PLIQUI := nPLiqui
		SF2->F2_PBRUTO := nPBruto
		//SF2->F2_VOLUME1:= nVolume1

	ELSE

		If	(Select('TTSF2A')<> 0)
			dbSelectArea('TTSF2A')
			dbCloseArea()
		EndIf
		BeginSql Alias 'TTSF2A'
			%noparser%

			SELECT
				F2_PLIQUI,
				F2_PBRUTO,
				C5.C5_VOLUME1,
				EE5.EE5_PESO
			FROM
				%Table:SF2% F2 (NOLOCK)
			INNER JOIN %Table:SD2% D2 (NOLOCK)
			ON D2.D2_FILIAL = %xFilial:SD2%
				AND D2.D2_DOC = F2.F2_DOC
				AND D2.D2_SERIE = F2.F2_SERIE
				AND D2.%NotDel%
			INNER JOIN %Table:SC5% C5 (NOLOCK)
			ON C5.C5_FILIAL = %xFilial:SC5%
				AND C5.C5_NUM = D2.D2_PEDIDO
				AND C5.%NotDel%
			INNER JOIN %Table:EE5% EE5 (NOLOCK)
			ON EE5.EE5_FILIAL = %xFilial:EE5%
				AND EE5.%NotDel%
				AND EE5.EE5_CODEMB = F2.F2_ESPECI1
			WHERE
				F2.F2_FILIAL = %xFilial:SF2%
				AND F2.%NotDel%
				AND F2.F2_DOC = %exp:SF2->F2_DOC%
				AND F2.F2_SERIE = %exp:SF2->F2_SERIE%
			GROUP BY
				F2_PLIQUI,
				F2_PBRUTO,
				C5.C5_VOLUME1,
				EE5.EE5_PESO
		EndSql

		TCSetField("TTSF2A","F2_PLIQUI" ,"N",TamSx3('F2_PLIQUI' )[1],TamSx3('F2_PLIQUI' )[2])
		TCSetField("TTSF2A","F2_PBRUTO" ,"N",TamSx3('F2_PBRUTO' )[1],TamSx3('F2_PBRUTO' )[2])
		TCSetField("TTSF2A","C5_VOLUME1" ,"N",TamSx3('C5_VOLUME1' )[1],TamSx3('C5_VOLUME1' )[2])
		TCSetField("TTSF2A","EE5_PESO" ,"N",TamSx3('EE5_PESO' )[1],TamSx3('EE5_PESO' )[2])

		nPLiqui1 := 0
		nPBruto1 := 0
		nTOTBruto := 0
		//nVolume1:= 0
		While !TTSF2A->(Eof())

			//nPBruto1 := (TTSF2A->C5_VOLUME1*TTSF2A->EE5_PESO)
			// Thiago (16/03/2020 para buscar direto do SC5)
			nPBruto1 := 0

			//Rodrigo - 19/12/12
			IF nPBruto1 == 0
				If	(Select('TTSF2B')<> 0)
					dbSelectArea('TTSF2B')
					dbCloseArea()
				EndIf
				BeginSql Alias 'TTSF2B'
					%noparser%

					SELECT
						C5.C5_PESOL,
						C5.C5_PBRUTO
					FROM
						%Table:SF2% F2 (NOLOCK)
					INNER JOIN %Table:SD2% D2 (NOLOCK)
					ON D2.D2_FILIAL = %xFilial:SD2%
						AND D2.D2_DOC = F2.F2_DOC
						AND D2.D2_SERIE = F2.F2_SERIE
						AND D2.%NotDel%
					INNER JOIN %Table:SC5% C5 (NOLOCK)
					ON C5.C5_FILIAL = %xFilial:SC5%
						AND C5.C5_NUM = D2.D2_PEDIDO
						AND C5.%NotDel%
					WHERE
						F2.F2_FILIAL = %xFilial:SF2%
						AND F2.%NotDel%
						AND F2_DOC = %exp:SF2->F2_DOC%
						AND F2_SERIE = %exp:SF2->F2_SERIE%
					GROUP BY
						C5.C5_PESOL,
						C5.C5_PBRUTO
				EndSql
				TTSF2B->(DBGOTOP())

				nTOTBruto := nPBruto := TTSF2B->C5_PBRUTO
			ELSE
				//Fim Rodrigo
				nTOTBruto := (nPBruto1 + SF2->F2_PLIQUI)
			ENDIF

			TTSF2A->(dbSkip())
		End
		SF2->F2_PBRUTO := nTOTBruto
		SF2->F2_PELCAL := SF2->F2_PLIQUI
		SF2->F2_PEBCALC := SF2->F2_PBRUTO
	ENDIF

	SF2->F2_userbud := Substr(cUsuario,7,15)
	SF2->(MsUnLock())

	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGotop()
	DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)

	///////////// JONAS - 26/11/2012                                                            ///////
	///////////// CONTROLE DE DESCONTO - CONFORME SOLICITAÇÃO DA AREA CONTABIL/FISCAL          ///////
	///////////// ESTA MUDANÇA É DE RESPONSABILIDADE DA AREA FISCAL(ANELORE) E CONTABIL(ORLY) ///////
	///////////// CONFORME PENDENCIA CAD. NO HELP-DESK                                       ///////
	IF EMPTY(SA1->A1_SUFRAMA)
		IF lDesc

			If (Select('DESCF2')<> 0)
				dbSelectArea('DESCF2')
				dbCloseArea()
			EndIf
			BeginSql Alias 'DESCF2'
				%noparser%

				SELECT
					F2_DOC,
					F2_SERIE,
					D2_COD,
					D2_CLIENTE,
					D2_LOJA,
					D2_ITEM
				FROM
					%Table:SF2% F2 (NOLOCK)
				INNER JOIN %Table:SD2% D2 (NOLOCK)
				ON D2.D2_FILIAL = %xFilial:SD2%
					AND D2.D2_DOC = F2.F2_DOC
					AND D2.D2_SERIE = F2.F2_SERIE
					AND D2.%NotDel%
				INNER JOIN %Table:SC6% C6 (NOLOCK)
				ON C6.C6_FILIAL = %xFilial:SC6%
					AND C6.C6_NUM = D2.D2_PEDIDO
					AND C6_ITEM = D2_ITEMPV
					AND C6.%NotDel%
				WHERE
					F2.F2_FILIAL = %xFilial:SF2%
					AND F2.%NotDel%
					AND F2_DOC = %exp:SF2->F2_DOC%
					AND F2_SERIE = %exp:SF2->F2_SERIE%
					AND C6.C6_VALDESC != ' '
					AND D2.D2_TES != %exp:cTESDesc%
				GROUP BY
					F2_DOC,
					F2_SERIE,
					D2_COD,
					D2_CLIENTE,
					D2_LOJA,
					D2_ITEM
			EndSql

			While !DESCF2->(Eof())

				IF !EMPTY(DESCF2->F2_DOC)


					DbSelectArea("SD2")
					DbSetOrder(3)
					DbGotop()
					IF DbSeek(xFilial("SD2")+DESCF2->F2_DOC+DESCF2->F2_SERIE+DESCF2->D2_CLIENTE+DESCF2->D2_LOJA+DESCF2->D2_COD+DESCF2->D2_ITEM)
						Reclock("SD2",.F.)
						IF EMPTY(SD2->D2_DESCBUD)
							SD2->D2_DESCBUD := SD2->D2_DESCON
						ENDIF
						SD2->D2_DESCON := 0
						SD2->(MsUnLock())
					ENDIF
				ENDIF
				DESCF2->(DBSKIP())
			ENDDO
		ENDIF
	ENDIF


	/////////////////////////////////////// Tratativa para gravar quantidades em caixas////////////////////////////////////////
	/////////////////////////////////////// que sera emetido para a NFe como unidade  caixa////////////////////////////////////
	If	SF2->F2_TIPO == 'N'

		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGotop()
		IF DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA)
			IF SA1->A1_TPFAT=='2'//If SF2->F2_CLIENTE $ +'"'+ cMVFATCX +'"'

				If (Select('FATCX')<> 0)
					dbSelectArea('FATCX')
					dbCloseArea()
				EndIf
				BeginSql Alias 'FATCX'
					SELECT
						D2_DOC,
						D2_SERIE,
						D2_CLIENTE,
						D2_LOJA,
						D2_COD,
						D2_ITEM,
						COUNT(*) AS QTDCX,
						(D2_PRCVEN * ZCN_QTDE) AS PRCCX
					FROM
						%Table:SD2% D2 (NOLOCK)
					INNER JOIN %Table:ZZ5% ZZ5
					ON ZZ5_FILIAL = %xFilial:ZZ5%
						AND ZZ5_PEDIDO = D2_PEDIDO
						AND ZZ5_PRODUT = D2_COD
						AND ZZ5_ITEM = D2_ITEMPV
						AND ZZ5_DOC = ''
						AND ZZ5.%NotDel%
					INNER JOIN %Table:SB1% B1
					ON B1_FILIAL = %xFilial:SB1%
						AND B1_COD = D2_COD
						AND B1.%NotDel%
					INNER JOIN %Table:SA1% A1
					ON A1_FILIAL = %xFilial:SA1%
						AND A1_COD = D2_CLIENTE
						AND A1_LOJA = D2_LOJA
						AND A1.%NotDel%
					INNER JOIN %Table:ZCN% ZN
					ON ZCN_FILIAL = ''
						AND ZCN_CODIGO = A1_CODENCX
						AND ZCN_REF = SUBSTRING(D2_COD, 1, 8)
						AND ZCN_TAM = SUBSTRING(D2_COD, 15, 4)
						AND ZN.%NotDel%
					WHERE
						D2.%NotDel%
						AND D2.D2_FILIAL = %xFilial:SD2%
						AND D2_DOC = %exp:SF2->F2_DOC%
						AND D2_SERIE = %exp:SF2->F2_SERIE%
					GROUP BY
						D2_DOC,
						D2_SERIE,
						D2_CLIENTE,
						D2_LOJA,
						D2_COD,
						D2_ITEM,
						D2_PRCVEN,
						ZCN_QTDE
				EndSql

				While !FATCX->(Eof())

					DbSelectArea("SD2")
					DbSetOrder(3)
					DbGotop()
					IF DbSeek(xFilial("SD2")+FATCX->D2_DOC+FATCX->D2_SERIE+FATCX->D2_CLIENTE+FATCX->D2_LOJA+FATCX->D2_COD+FATCX->D2_ITEM)
						Reclock("SD2",.F.)
						SD2->D2_QTDCX := FATCX->QTDCX
						SD2->D2_PRCCX := FATCX->PRCCX
						SD2->(MsUnLock())
					ENDIF

					FATCX->(DBSKIP())
				ENDDO
			EndIf
		EndIf
	EndIf

	/////////////////////////////////////Fim da tratativa//////////////////////////////////////////////////////////////////////


	///////////////////// Tratativa para clientes que possuem o valor bruto  unitário em nota fiscal (WBR IND.) ///////////////////

	If SF2->F2_CLIENTE $ cPrcBruto


		If (Select('FATDESC')<> 0)
			dbSelectArea('FATDESC')
			dbCloseArea()
		EndIf

		// BeginSql Alias 'FATDESC'
		// 	SELECT
		// 		D2_DOC,
		// 		D2_SERIE,
		// 		D2_CLIENTE,
		// 		D2_LOJA,
		// 		D2_COD,
		// 		D2_ITEM,
		// 		D2_PRUNIT,
		// 		D2_VALBRUT,
		// 		SUM(D2_PICM / 100) AS PERCICMS,
		// 		SUM(D2_ALQIMP5 / 100) AS PERCIMP5,
		// 		SUM(D2_ALQIMP6 / 100) AS PERCIMP6,
		// 		SUM(D2_PICM / 100) *(
		// 			SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
		// 		) AS VALICMS,
		// 		(
		// 			SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
		// 		) * SUM(D2_ALQIMP5 / 100) AS VALIMP5,
		// 		(
		// 			SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
		// 		) * sum(D2_ALQIMP6 / 100) AS VALIMP6,
		// 		SUM(D2_QUANT * D2_PRUNIT) AS TOTAL,
		// 		SUM(C5_DESC1 / 100) AS PERC,
		// 		SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100) AS DESCONTO,
		// 		ROUND(
		// 			(
		// 				SUM(D2_QUANT * D2_PRUNIT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
		// 			),
		// 			2
		// 		) AS VALBRUT,
		// 		ROUND((D2_TOTAL - D2_DESCBUD), 2) AS DIFICM,
		// 		ROUND((D2_VALBRUT -(D2_TOTAL - D2_DESCBUD)), 6) AS DIF
		// 	FROM
		// 		%Table:SD2% D2 (NOLOCK)
		// 	INNER JOIN %Table:SC5% (NOLOCK) C5
		// 	ON C5_FILIAL = %xFilial:SC5%
		// 		AND C5_NUM = D2_PEDIDO
		// 		AND C5.%NotDel%
		// 	WHERE
		// 		D2.%NotDel%
		// 		AND D2_FILIAL = %xFilial:SD2%
		// 		AND D2_DOC = %exp:SF2->F2_DOC%
		// 		AND D2_SERIE = %exp:SF2->F2_SERIE%
		// 	GROUP BY
		// 		D2_DOC,
		// 		D2_SERIE,
		// 		D2_CLIENTE,
		// 		D2_LOJA,
		// 		D2_COD,
		// 		D2_ITEM,
		// 		D2_PRUNIT,
		// 		D2_VALBRUT,
		// 		D2_TOTAL,
		// 		D2_DESCBUD
		// EndSql

		cQueryZV := " SELECT D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, D2.D2_COD, D2.D2_ITEM, D2.D2_PRUNIT, D2.D2_VALICM, D2.D2_VALBRUT, "
		cQueryZV += " SUM(D2.D2_PICM / 100) AS PERCICMS, "
		cQueryZV += " SUM(D2.D2_ALQIMP5 / 100) AS PERCIMP5, "
		cQueryZV += " SUM(D2.D2_ALQIMP6 / 100) AS PERCIMP6, "
		cQueryZV += " ROUND( SUM(D2.D2_PICM / 100) * (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))), 2 ) AS VALICMS, "
		cQueryZV += " (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))) * SUM(D2.D2_ALQIMP5 / 100) AS VALIMP5, "
		cQueryZV += " (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))) * SUM(D2.D2_ALQIMP6 / 100) AS VALIMP6, "
		cQueryZV += " SUM(D2.D2_QUANT * D2.D2_PRUNIT) AS TOTAL, "
		cQueryZV += " SUM(C5.C5_DESC1 / 100) AS PERC, "
		cQueryZV += " SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100) AS DESCONTO, "
		cQueryZV += " ROUND( (SUM(D2.D2_QUANT * D2.D2_PRUNIT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))), 3 ) AS VALBRUT, "
		cQueryZV += " ROUND((D2.D2_TOTAL - D2.D2_DESCBUD), 2) AS DIFICM, "
		cQueryZV += " ROUND((D2.D2_VALBRUT - (D2.D2_TOTAL - D2.D2_DESCBUD)), 6) AS DIF "
		cQueryZV += " FROM "+RETSQLNAME("SD2")+" D2 (NOLOCK) "
		cQueryZV += " INNER JOIN "+RETSQLNAME("SC5")+" C5 (NOLOCK) "
		cQueryZV += " ON C5.C5_FILIAL = '01' AND C5.C5_NUM = D2.D2_PEDIDO AND C5.D_E_L_E_T_ = '' "
		cQueryZV += " WHERE D2.D_E_L_E_T_ = '' "
		cQueryZV += " AND D2.D2_FILIAL = "+valtosql(xFilial('SF2'))+ " "
		cQueryZV += " AND D2.D2_DOC = "+valtosql(SF2->F2_DOC)+ " "
		cQueryZV += " AND D2.D2_SERIE = "+valtosql(SF2->F2_SERIE)+ " "
		cQueryZV += " GROUP BY D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, D2.D2_COD, D2.D2_ITEM, D2.D2_PRUNIT, D2.D2_VALBRUT, D2.D2_TOTAL, D2.D2_DESCBUD, D2.D2_VALICM "

		FATDESC := Getnextalias()
		MPSysOpenQuery(cQueryZV,FATDESC)

		nTotal		:= 0
		nDesc		:= 0
		nTotDesc   := 0
		nDif		:= 0
		nValBrut	:= 0
		nValICMS	:= 0
		nBaseICMS	:= 0
		nBasimp5	:= 0
		nBasimp6	:= 0
		nValimp5	:= 0
		nValimp6	:= 0
		nRecnoSD2 	:= 0
		nVALDIF := 0

		While !(FATDESC)->(Eof())
			nVALDIF += (FATDESC)->DIF
			(FATDESC)->(DBSKIP())
		ENDDO

		(FATDESC)->(dbGoTop())
		While !(FATDESC)->(Eof())

			nTotal+=    (FATDESC)->TOTAL
			nDesc+=     (FATDESC)->DESCONTO
			nValBrut+=  (FATDESC)->VALBRUT
			nValICMS+=  (FATDESC)->VALICMS
			nBaseICMS+= (FATDESC)->VALBRUT
			nBasimp5+=  ((FATDESC)->VALBRUT - (FATDESC)->VALICMS)
			nBasimp6+=  ((FATDESC)->VALBRUT - (FATDESC)->VALICMS)
			nValimp5+=  nBasimp5*0.0760 ///(((FATDESC)->VALIMP5  ))
			nValimp6+=  nBasimp6*0.0165 //(((FATDESC)->VALIMP6  ))
			nValicmz := (FATDESC)->VALBRUT
			nValicmy := (FATDESC)->VALICMS


			DbSelectArea("SD2")
			DbSetOrder(3)
			DbGotop()
			IF DbSeek(xFilial("SD2")+(FATDESC)->D2_DOC+(FATDESC)->D2_SERIE+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_COD+(FATDESC)->D2_ITEM)
				SD2->(Reclock("SD2",.F.))

				SD2->D2_PRCVEN  := (FATDESC)->D2_PRUNIT
				SD2->D2_TOTAL   := (FATDESC)->TOTAL
				SD2->D2_DESCBUD := ((FATDESC)->DESCONTO)
				If SD2->D2_ITEM  = "01"
					SD2->D2_BASEICM := nValicmz  //(nValicmz - 0.01) //(((FATDESC)->TOTAL - (FATDESC)->DESCONTO)) - ((FATDESC)->DIF)
				Else
					SD2->D2_BASEICM := nValicmz
				EndIf
				SD2->D2_VALBRUT := NOROUND((FATDESC)->TOTAL - (FATDESC)->DESCONTO)
				SD2->D2_VALICM  := nValicmy
				SD2->D2_BASIMP5 := nValicmz- nValicmy//((FATDESC)->TOTAL - ((FATDESC)->DESCONTO))
				SD2->D2_BASIMP6 := nValicmz- nValicmy//((FATDESC)->TOTAL - ((FATDESC)->DESCONTO))
				SD2->D2_VALIMP5 := (nValicmz- nValicmy)*0.0760
				SD2->D2_VALIMP6 := (nValicmz- nValicmy)*0.0165

				SD2->(MsUnLock())

				/////////////////////////////////////////////////////////////////////////////////////////////////
				//AJUSTE NO CD2
				DbSelectArea("CD2")
				DbSetOrder(1)
				DbGotop()
				IF DbSeek(xFilial("CD2")+'S'+(FATDESC)->D2_SERIE+(FATDESC)->D2_DOC+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_ITEM+'  '+(FATDESC)->D2_COD+'ICM   ')
					//If CD2->CD2_ITEM == "01  "
					CD2-> ( Reclock("CD2",.F.) )
					If SD2->D2_ITEM  = "01"
						CD2->CD2_BC := nValicmz ///(SD2->D2_BASEICM - 0.01) // ((FATDESC)->TOTAL - (FATDESC)->DESCONTO) - ((FATDESC)->DIF)
					Else
						CD2->CD2_BC := nValicmz ///(FATDESC)->DIFICM  //SD2->D2_BASEICM //(((FATDESC)->TOTAL - (FATDESC)->DESCONTO)) - ((FATDESC)->DIF)
					EndIf
					CD2->CD2_VLTRIB := (nValicmy)
					CD2->(MsUnLock())

					//ENDIF
				ENDIF
				IF DbSeek(xFilial("CD2")+'S'+(FATDESC)->D2_SERIE+(FATDESC)->D2_DOC+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_ITEM+'  '+(FATDESC)->D2_COD+'PS2   ')
					CD2->( Reclock("CD2",.F.) )
					CD2->CD2_BC :=  (nValicmz - nValicmy) ///((FATDESC)->TOTAL - ((FATDESC)->DESCONTO))
					CD2->CD2_VLTRIB := (nValicmz- nValicmy)*0.0165
					CD2->(MsUnLock())
				ENDIF
				IF DbSeek(xFilial("CD2")+'S'+(FATDESC)->D2_SERIE+(FATDESC)->D2_DOC+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_ITEM+'  '+(FATDESC)->D2_COD+'CF2   ')
					CD2->( Reclock("CD2",.F.) )
					CD2->CD2_BC := (nValicmz- nValicmy) ///((FATDESC)->TOTAL - ((FATDESC)->DESCONTO))
					CD2->CD2_VLTRIB := (nValicmz- nValicmy)*0.0760
					CD2->(MsUnLock())
				ENDIF

				/////////////////////////////////////////////////////////////////////////////////////////////////

				If nRecnoSD2 == 0
					nRecnoSD2 := SD2->(RecNo())	//Pega o primeiro item
				EndIf
			ENDIF

			//FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
			SFT->(DbSetOrder(1))
			SFT->(DbGotop())
			IF SFT->(DbSeek(xFilial("SFT")+AvKey("S", "FT_TIPOMOV")+(FATDESC)->D2_SERIE+(FATDESC)->D2_DOC+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_ITEM+(FATDESC)->D2_COD))
				SFT->(Reclock("SFT",.F.))
				SFT->FT_VALCONT := nValicmz
				SFT->FT_BASEICM := nValicmz
				SFT->FT_OUTRIPI := nValicmz
				SFT->FT_TOTAL   := nValicmz
				SFT->FT_BASEDES := nValicmz
				SFT->FT_BSICMOR := nValicmz
				SFT->FT_VALICM  := nValicmy
				SFT->(MsUnLock())
			ENDIF

			(FATDESC)->(DBSKIP())
		ENDDO

		//Acerta arredondamento no primeiro item
		If ( ( nTotal - nValBrut ) <> nDesc )
			SD2-> ( dbGoto( nRecnoSD2 ) )
			SD2 -> ( Reclock("SD2",.F.) )
			SD2->D2_DESCBUD := SD2->D2_DESCBUD + ( ( nTotal - nValBrut ) - nDesc )

			SD2->(MsUnLock())
		EndIf

		SF2-> ( Reclock("SF2",.F.) )
		SF2->F2_VALBRUT := nValBrut
		SF2->F2_BASEICM := nValBrut
		SF2->F2_VALICM  := nValICMS
		SF2->F2_VALMERC := nValBrut
		SF2->F2_VALFAT  := nValBrut
		SF2->F2_BASIMP5 := nBasimp5
		SF2->F2_BASIMP6 := nBasimp6
		SF2->F2_VALIMP5 := nValimp5
		SF2->F2_VALIMP6 := nValimp6
		SF2->(MsUnLock())

		//F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SDOC
		SF3->(DbSetOrder(10))
		SF3->(DbGotop())
		IF SF3->(DbSeek(xFilial("SF3")+(FATDESC)->D2_CLIENTE+(FATDESC)->D2_LOJA+(FATDESC)->D2_DOC+(FATDESC)->D2_SERIE))
			SF3->(Reclock("SF3",.F.))
			SF3->F3_VALCONT  := nValBrut
			SF3->F3_BASEICM  := nValBrut
			SF3->F3_OUTRIPI  := nValBrut
			SF3->F3_BASEDES  := nValBrut
			SF3->F3_BSICMOR  := nValBrut
			SF3->F3_VALICM   := nValICMS
			SF3->(MsUnLock())
		ENDIF

		////////////////////////////////////////////////////////Valido os valores calculados
		//////////////////////////////////////SD2
		_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		/*IF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
        While !SD2->(Eof()) .And. SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_DOC+SD2->D2_SERIE
                //_nTot += SD2->D2_TOTAL
                _nBICM += SD2->D2_BASEICM
                _nVICM += SD2->D2_VALICM
                _nICOF += SD2->D2_VALIMP5
                _nIPIS += SD2->D2_VALIMP6
				SD2->(DbSkip() )
			EndDo
		EndIf*/
		/*If _nBICM <> nValBrut
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
     	SD2->(Reclock("SD2",.F.))
     	SD2->D2_BASEICM :=  SD2->D2_BASEICM - (_nBICM-nValBrut)
     	SD2->D2_VALICM  := ROUND(SD2->D2_VALICM + (nValICMS - _nVICM),2)// SD2->D2_VALICM + (_nVICM-nValICMS)
     	SD2->D2_BASIMP5 := SD2->D2_BASEICM
     	SD2->D2_BASIMP6 := SD2->D2_BASEICM
		If _nIPIS <> nValimp6
		SD2->D2_VALIMP5 := ROUND(SD2->D2_VALIMP5 + (nValimp5 - _nICOF),2)
		SD2->D2_VALIMP6 := ROUND(SD2->D2_VALIMP6 + (nValimp6 - _nIPIS),2)
        EndIf
		SD2->(MsUnLock())
		EndIf*/
		/////////////////////////////////////SFT
		_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		DbSelectArea("SFT")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !SFT->(Eof()) .And. SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				_nBICM += SFT->FT_BASEICM
				_nVICM += SFT->FT_VALICM
				_nICOF += SFT->FT_VALCOF
				_nIPIS += SFT->FT_VALPIS
				SFT->(DbSkip() )
			EndDo
		EndIf
		If _nBICM <> nValBrut
			DbSelectArea("SD2")
			DbSetOrder(3)
			DbGotop()
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)

			DbSelectArea("SFT")
			DbSetOrder(1)
			DbGotop()
			DbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)
			SFT->(Reclock("SFT",.F.))
			SFT->FT_BASEICM := SD2->D2_BASEICM
			SFT->FT_VALCONT := SD2->D2_BASEICM
			SFT->FT_TOTAL   := SD2->D2_BASEICM
			SFT->FT_VALICM  := SD2->D2_VALICM
			SFT->FT_BASECOF := SD2->D2_BASIMP5
			SFT->FT_BASEPIS := SD2->D2_BASIMP6
			If _nIPIS <> nValimp6
				SFT->FT_VALCOF := ROUND(SFT->FT_VALCOF + (nValimp5 - _nICOF),2)
				SFT->FT_VALPIS := ROUND(SFT->FT_VALPIS + (nValimp6 - _nIPIS),2)
			EndIf
			SFT->(MsUnLock())
		EndIf

		/////////////////////////////////////SF3
		_cDoc := SF2->F2_DOC
		_cSerie:= SF2->F2_SERIE
		cQuery	:= "SELECT D2_CF, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_SERIE, SUM(D2_BASEICM) AS BASEICMS, SUM(D2_VALICM) AS VALORICMS, D2_FILIAL, F3_FILIAL, D2_EMISSAO, D2_PICM "
		cQuery	+= "FROM "+RetSqlName("SD2")+" D2, " +RetSqlName("SF3")+" F3 "
		cQuery	+= "WHERE D2.D_E_L_E_T_ = '' "
		cQuery	+= "AND F3.D_E_L_E_T_ = '' "
		cQuery	+= "AND D2_DOC = '"+_cDoc+"' "
		cQuery	+= "AND D2_SERIE = '"+_cSerie+"' "
		cQuery	+= "AND D2_DOC = F3_NFISCAL "
		cQuery	+= "AND D2_SERIE = F3_SERIE "
		cQuery	+= "AND D2_CF = F3_CFO "
		cQuery	+= "AND D2_CLIENTE = F3_CLIEFOR "
		cQuery	+= "AND D2_LOJA = F3_LOJA "
		cQuery	+= "AND D2_FILIAL = F3_FILIAL "
		cQuery	+= "AND D2_PICM = F3_ALIQICM "
		cQuery	+= "GROUP BY D2_CF, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_SERIE, D2_FILIAL, F3_FILIAL, D2_EMISSAO, D2_PICM "

		If (Select("_TRB")<>0)
			dbSelectArea("_TRB")
			dbCloseArea()
		End

		cQuery := changequery(cQuery)
		TCQuery cQuery NEW ALIAS "_TRB"

		While !_TRB->(Eof())

			DbSelectArea("SF3")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SF3")+_TRB->D2_EMISSAO+_TRB->D2_DOC+_TRB->D2_SERIE+_TRB->D2_CLIENTE+_TRB->D2_LOJA+_TRB->D2_CF+STR(_TRB->D2_PICM,5,2))
				SF3->(Reclock("SF3",.F.))
				SF3->F3_BASEICM := _TRB->BASEICMS
				SF3->F3_VALICM  := _TRB->VALORICMS
				SF3->F3_VALCONT := _TRB->BASEICMS
				SF3->F3_BASEDES := _TRB->BASEICMS
				SF3->F3_BSICMOR := _TRB->BASEICMS

				SF3->(MsUnLock())
			EndIf
			_TRB->(dbSkip())
		EndDo


		//SF2 ESTA SETADO NA AREA - POSICIONADO.
		/*	SF2-> ( Reclock("SF2",.F.) )
		SF2->F2_BASEICM :=  nBaseICMS //_nBICM
		SF2->F2_VALICM  := _nVICM
		SF2->(MsUnLock()) */

		////////////////////////////////////CD2
		/*_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		_nIBCOF := 0
		_nIBPIS := 0*/
		DbSelectArea("CD2")
		DbSetOrder(1)
		DbGotop()
		/*IF DbSeek(xFilial("CD2")+'S'+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !CD2->(Eof()) .And. CD2->CD2_SERIE+CD2->CD2_DOC+CD2->CD2_CODCLI+CD2->CD2_LOJCLI == SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
                If CD2->CD2_IMP == "ICM   " .AND. CD2->CD2_TPMOV == "S"
                _nBICM += CD2->CD2_BC
                _nVICM += CD2->CD2_VLTRIB
               	EndIf

                If CD2->CD2_IMP == "CF2   " .AND. CD2->CD2_TPMOV == "S"
                _nBICM += CD2->CD2_BC
                _nICOF += CD2->CD2_VLTRIB
               	EndIf

                If CD2->CD2_IMP == "PS2   " .AND. CD2->CD2_TPMOV == "S"
                _nBICM += CD2->CD2_BC
                _nIPIS += CD2->CD2_VLTRIB
               	EndIf

               	CD2->(DbSkip() )
			EndDo
		EndIf*/
		//// ACERTA VALOR NA CD2
		/*DbSelectArea("CD2")
			DbSetOrder(1)
			DbGotop()
			IF DbSeek(xFilial("CD2")+'S'+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+'  '+SD2->D2_COD+'ICM   ')

				CD2 -> ( Reclock("CD2",.F.) )
			  	CD2->CD2_BC := SD2->D2_BASEICM
				CD2->CD2_VLTRIB :=(SD2->D2_VALICM)
				CD2->(MsUnLock())

		    ENDIF
			IF DbSeek(xFilial("CD2")+'S'+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+'  '+SD2->D2_COD+'PS2   ')
				CD2->( Reclock("CD2",.F.) )
				CD2->CD2_BC :=  SD2->D2_BASEICM
				CD2->CD2_VLTRIB := (SD2->D2_VALICM) *0.0165
				CD2->(MsUnLock())
			ENDIF
			IF DbSeek(xFilial("CD2")+'S'+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+'  '+SD2->D2_COD+'CF2   ')
				CD2->( Reclock("CD2",.F.) )
				CD2->CD2_BC := SD2->D2_BASEICM
				CD2->CD2_VLTRIB := (SD2->D2_VALICM)*0.0760
				CD2->(MsUnLock())
		ENDIF*/

		////////////////////////////////// fim validacao valores

		// ExecReproc(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO)	//Executa reprocessamento da NF


		//SF2 -> ( RestArea(aAreaSF2) )

		/*SF3->( dbSetOrder(04) )	//F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
        If SF3 -> ( DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE) )
			While ! SF3 -> ( Eof() ) .And. SF3->(F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE) == xFilial("SF3")+SF2->(F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE)
				SF3-> ( Reclock("SF3",.F.) )
				SF3->F3_VALCONT	:= SF3->F3_BASEICM
				SF3->F3_OUTRIPI	:= SF3->F3_BASEICM
				SF3->F3_BSICMOR	:= SF3->F3_BASEICM
				SF3->F3_REPROC	:= "N"
				SF3-> ( MsUnLock() )
				SF3-> ( DbSkip() )
			EndDo
		EndIf */


		nParcelas	  := 0
		nValParc	  := 0
		nTotParc	  := 0
		aParcelas	  := {}
		SE1 -> ( dbSetOrder(02) )	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If SE1->(dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))
			While ! SE1->(Eof()) .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SF2->F2_CLIENTE == SE1->E1_CLIENTE .And. SF2->F2_LOJA == SE1->E1_LOJA .And.;
					SF2->F2_SERIE == SE1->E1_PREFIXO .And. SF2->F2_DOC == SE1->E1_NUM

				nParcelas 	++
				aadd(aParcelas,SE1->(RecNo()))

				SE1->(DbSkip ())
			EndDo
		EndIf

		nTotParc := SF2->F2_VALBRUT
		nValParc := Round( nTotParc / nParcelas , 2 )

		For nInc := 1 To nParcelas
			If nInc == nParcelas	//Se for a ultima parcela, precisa calcular a diferença das parcelas
				nValParc := nValParc + ( nTotParc - (nValParc * nParcelas) )
			EndIf
			SE1-> ( dbGoto( aParcelas[nInc] ) )
			SE1-> ( Reclock("SE1",.F.) )
			SE1->E1_VALOR	:= nValParc
			SE1->E1_SALDO	:= nValParc
			SE1->E1_BASCOM1	:= nValParc
			SE1->E1_VLCRUZ	:= nValParc
			SE1-> ( MsUnLock() )
		Next nInc

	EndIf

	///////////////////// Fim da tratativa /////////////////////////////////////////////////////////////////////////////

	/////// PROTHEUS ESTÁ SOMANDO O VALOR DE DESC. SUFRAMA SOBRE A BASE DE ICMS.ALTERADO PARA  NÃO CONSIDERAR.

	////////////////////////////// TRATATIVA PARA PROCESSE DE ALGODAO //////////////////////////

	IF cTESDesc== SD2->D2_TES

		nParcelas	  := 0
		nValParc	  := 0
		nTotParc	  := 0
		aParcelas	  := {}
		SE1 -> ( dbSetOrder(02) )	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E
		If SE1->(dbSeek(xFilial("SE1")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_SERIE+SF2->F2_DOC))
			While ! SE1->(Eof()) .And. xFilial("SE1") == SE1->E1_FILIAL .And.;
					SF2->F2_CLIENTE == SE1->E1_CLIENTE .And. SF2->F2_LOJA == SE1->E1_LOJA .And.;
					SF2->F2_SERIE == SE1->E1_PREFIXO .And. SF2->F2_DOC == SE1->E1_NUM

				nParcelas 	++
				aadd(aParcelas,SE1->(RecNo()))

				SE1->(DbSkip ())
			EndDo
		EndIf

		nTotParc := SF2->F2_VALBRUT
		nValParc := Round( nTotParc / nParcelas , 2 )

		For nInc := 1 To nParcelas
			If nInc == nParcelas	//Se for a ultima parcela, precisa calcular
				nValParc := nValParc + ( nTotParc - (nValParc * nParcelas) )
			EndIf
			SE1-> ( dbGoto( aParcelas[nInc] ) )
			SE1-> ( Reclock("SE1",.F.) )
			SE1->E1_VALOR	:= nValParc
			SE1->E1_SALDO	:= nValParc
			SE1->E1_BASCOM1	:= nValParc
			SE1->E1_VLCRUZ	:= nValParc
			SE1-> ( MsUnLock() )
		Next nInc
	ENDIF


	///////////////////////////////FIM DA TRATATIVA/////////////////////////////////////////////

	IF !EMPTY(SA1->A1_SUFRAMA)

		If (Select('FATDESCZF')<> 0)
			dbSelectArea('FATDESCZF')
			dbCloseArea()
		EndIf

		BeginSql Alias 'FATDESCZF'
			SELECT
				D2_DOC,
				D2_SERIE,
				D2_CLIENTE,
				D2_LOJA,
				D2_COD,
				D2_ITEM,
				D2_PRUNIT,
				D2_VALICM,
				D2_VALBRUT,
				D2_PRCMPED,
				D2_QUANT,
				D2_PICM,
				D2_DESCZFR,
				D2_TOTAL,
				SUM(D2_PICM / 100) AS PERCICMS,
				SUM(D2_ALQIMP5 / 100) AS PERCIMP5,
				SUM(D2_ALQIMP6 / 100) AS PERCIMP6,
				SUM(D2_PICM / 100) *(
					SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
				) AS VALICMS,
				(
					SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
				) * SUM(D2_ALQIMP5 / 100) AS VALIMP5,
				(
					SUM(D2_PRUNIT * D2_QUANT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
				) * sum(D2_ALQIMP6 / 100) AS VALIMP6,
				SUM(D2_QUANT * D2_PRUNIT) AS TOTAL,
				SUM(C5_DESC1 / 100) AS PERC,
				SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100) AS DESCONTO,
				(
					SUM(D2_QUANT * D2_PRUNIT) -(SUM(D2_QUANT * D2_PRUNIT) * SUM(C5_DESC1 / 100))
				) AS VALBRUT,
				ROUND((D2_VALBRUT -(D2_TOTAL - D2_DESCBUD)), 6) AS DIF,
				((D2_BASIMP5 * 0.0760)) AS DESCZFC,
				((D2_BASIMP6 * 0.0165)) AS DESCZFP,
				(SUM(D2_TOTAL + D2_DESCZFR) - D2_VALICM) AS BASESUF,
				CASE
					WHEN D2_VALICM = 0
						THEN ISNULL(D2_BASIMP5 * 0.07, 0)
				END AS ICMDIF,
				(D2_DESCZFP + D2_DESCZFC) AS DESCZFR
			FROM
				%Table:SD2% D2 (NOLOCK)
			INNER JOIN %Table:SC5% (NOLOCK) C5
			ON C5_FILIAL = %xFilial:SC5%
				AND C5_NUM = D2_PEDIDO
				AND C5.%NotDel%
			WHERE
				D2.%NotDel%
				AND D2_FILIAL = %xFilial:SD2%
				AND D2_DOC = %exp:SF2->F2_DOC%
				AND D2_SERIE = %exp:SF2->F2_SERIE% //AND D2_DESCON<>''
			GROUP BY
				D2_DOC,
				D2_SERIE,
				D2_CLIENTE,
				D2_LOJA,
				D2_COD,
				D2_ITEM,
				D2_PRUNIT,
				D2_TOTAL,
				D2_VALICM,
				D2_VALBRUT,
				D2_PRCMPED,
				D2_QUANT,
				D2_PICM,
				D2_DESCZFR,
				D2_TOTAL,
				D2_DESCBUD,
				D2_BASIMP5,
				D2_BASIMP6,
				D2_DESCZFP,
				D2_DESCZFC
		EndSql

		nTotal		:= 0
		nDesc		:= 0
		nTotDesc   := 0
		nDif		:= 0
		nValBrut	:= 0
		nValICMS	:= 0
		nBaseICMS	:= 0
		nBasimp5	:= 0
		nBasimp6	:= 0
		nValimp5	:= 0
		nValimp6	:= 0
		nRecnoSD   := 0
		nDescSuf   := 0
		nBaseSuf   := 0




		FATDESCZF->(dbGoTop())
		While !FATDESCZF->(Eof())




			DbSelectArea("SD2")
			DbSetOrder(3)
			DbGotop()
			IF DbSeek(xFilial("SD2")+FATDESCZF->D2_DOC+FATDESCZF->D2_SERIE+FATDESCZF->D2_CLIENTE+FATDESCZF->D2_LOJA+FATDESCZF->D2_COD+FATDESCZF->D2_ITEM)

				SD2 -> ( Reclock("SD2",.F.) )

				SD2->D2_BASEICM := IIF(FATDESCZF->D2_PICM <> 7,(FATDESCZF->D2_PRCMPED*FATDESCZF->D2_QUANT),SD2->D2_BASEICM)
				SD2->D2_VALICM  := IIF(FATDESCZF->D2_PICM <> 7,(((FATDESCZF->D2_PRCMPED)*FATDESCZF->D2_QUANT))*(FATDESCZF->D2_PICM/100),SD2->D2_VALICM)
				//SD2->D2_BASIMP5:=  FATDESCZF->BASESUF
				//SD2->D2_BASIMP6:=  FATDESCZF->BASESUF
				//SD2->D2_DESCZFC:=  FATDESCZF->DESCZFC
				//SD2->D2_DESCZFP:=  FATDESCZF->DESCZFP
				// SD2->D2_DESCZFR:=  (FATDESCZF->ICMDIF+FATDESCZF->DESCZFR)
				SD2->(MsUnLock())

				/////////////////////////////////////////////////////////////////////////////////////////////////
				//AJUSTE NO CD2


				nValICMS+=  SD2->D2_VALICM
				nBaseICMS+= (SD2->D2_BASEICM)
				nBasimp5+=  FATDESCZF->BASESUF //(SD2->D2_BASIMP5)
				nBasimp6+=  FATDESCZF->BASESUF //(SD2->D2_BASIMP6)


				DbSelectArea("CD2")
				DbSetOrder(1)
				DbGotop()
				IF DbSeek(xFilial("CD2")+'S'+FATDESCZF->D2_SERIE+FATDESCZF->D2_DOC+FATDESCZF->D2_CLIENTE+FATDESCZF->D2_LOJA+FATDESCZF->D2_ITEM+'  '+FATDESCZF->D2_COD+'ICM   ')


					IF FATDESCZF->D2_PICM <> 7
						CD2 -> ( Reclock("CD2",.F.) )
						CD2->CD2_BC := (((FATDESCZF->D2_PRCMPED)*FATDESCZF->D2_QUANT))
						CD2->CD2_VLTRIB := (((FATDESCZF->D2_PRCMPED)*FATDESCZF->D2_QUANT))*(FATDESCZF->D2_PICM/100)
						CD2->(MsUnLock())
					EndIf


				ENDIF

				/*IF DbSeek(xFilial("CD2")+'S'+FATDESCZF->D2_SERIE+FATDESCZF->D2_DOC+FATDESCZF->D2_CLIENTE+FATDESCZF->D2_LOJA+FATDESCZF->D2_ITEM+'  '+FATDESCZF->D2_COD+'CF2   ')


				   CD2 -> ( Reclock("CD2",.F.) )
				   CD2->CD2_BC := FATDESCZF->BASESUF
				   CD2->(MsUnLock())

				ENDIF*/

				/*IF DbSeek(xFilial("CD2")+'S'+FATDESCZF->D2_SERIE+FATDESCZF->D2_DOC+FATDESCZF->D2_CLIENTE+FATDESCZF->D2_LOJA+FATDESCZF->D2_ITEM+'  '+FATDESCZF->D2_COD+'PS2   ')

				CD2 -> ( Reclock("CD2",.F.) )
				   CD2->CD2_BC := FATDESCZF->BASESUF
				CD2->(MsUnLock())

				ENDIF	*/

				/*IF DbSeek(xFilial("CD2")+'S'+FATDESCZF->D2_SERIE+FATDESCZF->D2_DOC+FATDESCZF->D2_CLIENTE+FATDESCZF->D2_LOJA+FATDESCZF->D2_ITEM+'  '+FATDESCZF->D2_COD+'ZFM   ')

				CD2 -> ( Reclock("CD2",.F.) )
				   CD2->CD2_BC := (FATDESCZF->ICMDIF+FATDESCZF->DESCZFR)
				CD2->(MsUnLock())

				ENDIF*/



			ENDIF

			SFT -> ( dbSetOrder(01) )	//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
			If SFT -> ( dbSeek(xFilial("SFT")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM+'  '+SD2->D2_COD))
				While ! SFT -> ( Eof() ) .And. SFT->(FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+SFT->FT_ITEM+SFT->FT_PRODUTO) == xFilial("SFT")+"S"+SD2->(D2_SERIE+D2_DOC+D2_CLIENTE+D2_LOJA+SD2->D2_ITEM+'  '+SD2->D2_COD)
					SFT-> ( Reclock("SFT",.F.) )

					SFT->FT_BASEICM := ((SD2->D2_BASEICM))
					SFT->FT_VALICM  := SD2->D2_VALICM
					SFT->FT_BASECOF := FATDESCZF->BASESUF
					SFT->FT_BASEPIS := FATDESCZF->BASESUF

					SFT-> ( MsUnLock() )
					SFT-> ( DbSkip() )

				EndDo
			EndIf
			FATDESCZF->(DBSKIP())
		ENDDO

		_nBICM1 := 0
		_nVICM1 := 0
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		IF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !SD2->(Eof()) .And. SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_DOC+SD2->D2_SERIE

				_nBICM1 += SD2->D2_BASEICM
				_nVICM1 += SD2->D2_VALICM

				SD2->(DbSkip() )
			EndDo
		EndIf


		SF2-> ( Reclock("SF2",.F.) )
		SF2->F2_BASEICM := _nBICM1//SD2->D2_BASEICM
		SF2->F2_VALICM  := _nVICM1//SD2->D2_VALICM
		SF2->(MsUnLock())
		_nBICM1 := 0
		_nVICM1 := 0
		////////////////////////////////////////////////////////Valido os valores calculados//////////////////////////////////////SD2
		_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		IF DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !SD2->(Eof()) .And. SF2->F2_DOC+SF2->F2_SERIE == SD2->D2_DOC+SD2->D2_SERIE

				_nBICM += SD2->D2_BASEICM
				_nVICM += SD2->D2_VALICM

				SD2->(DbSkip() )
			EndDo
		EndIf

		/////////////////////////////////////SFT
		_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		DbSelectArea("SFT")
		DbSetOrder(1)
		DbGotop()
		If DbSeek(xFilial("SFT")+"S"+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !SFT->(Eof()) .And. SFT->FT_NFISCAL+SFT->FT_SERIE+SFT->FT_CLIEFOR+SFT->FT_LOJA == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				_nBICM += SFT->FT_BASEICM
				_nVICM += SFT->FT_VALICM

				SFT->(DbSkip() )
			EndDo
		EndIf

		/////////////////////////////////////SF3

		_cDoc := SF2->F2_DOC
		_cSerie:= SF2->F2_SERIE
		cQuery	:= "SELECT D2_CF, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_SERIE, SUM(D2_BASEICM) AS BASEICMS, SUM(D2_VALICM) AS VALORICMS, D2_FILIAL, F3_FILIAL, D2_EMISSAO, D2_PICM "
		cQuery	+= "FROM "+RetSqlName("SD2")+" D2, " +RetSqlName("SF3")+" F3 "
		cQuery	+= "WHERE D2.D_E_L_E_T_ = '' "
		cQuery	+= "AND F3.D_E_L_E_T_ = '' "
		cQuery	+= "AND D2_DOC = '"+_cDoc+"' "
		cQuery	+= "AND D2_SERIE = '"+_cSerie+"' "
		cQuery	+= "AND D2_DOC = F3_NFISCAL "
		cQuery	+= "AND D2_SERIE = F3_SERIE "
		cQuery	+= "AND D2_CF = F3_CFO "
		cQuery	+= "AND D2_CLIENTE = F3_CLIEFOR "
		cQuery	+= "AND D2_LOJA = F3_LOJA "
		cQuery	+= "AND D2_FILIAL = F3_FILIAL "
		cQuery	+= "AND D2_PICM = F3_ALIQICM "
		cQuery	+= "GROUP BY D2_CF, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_SERIE, D2_FILIAL, F3_FILIAL, D2_EMISSAO, D2_PICM "

		If (Select("_TRB")<>0)
			dbSelectArea("_TRB")
			dbCloseArea()
		End

		cQuery := changequery(cQuery)
		TCQuery cQuery NEW ALIAS "_TRB"

		While !_TRB->(Eof())

			DbSelectArea("SF3")
			DbSetOrder(1)
			DbGotop()
			If DbSeek(xFilial("SF3")+_TRB->D2_EMISSAO+_TRB->D2_DOC+_TRB->D2_SERIE+_TRB->D2_CLIENTE+_TRB->D2_LOJA+_TRB->D2_CF+STR(_TRB->D2_PICM,5,2))
				SF3->(Reclock("SF3",.F.))
				SF3->F3_BASEICM := _TRB->BASEICMS
				SF3->F3_VALICM := _TRB->VALORICMS
				SF3->(MsUnLock())
			EndIf
			_TRB->(dbSkip())
		EndDo


		/////////////////////////////////////SF3



		////////////////////////////////////CD2
		_nBICM := 0
		_nVICM := 0
		_nIPIS := 0
		_nICOF := 0
		_nIBCOF := 0
		_nIBPIS := 0
		DbSelectArea("CD2")
		DbSetOrder(1)
		DbGotop()
		IF DbSeek(xFilial("CD2")+'S'+SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA)
			While !CD2->(Eof()) .And. CD2->CD2_SERIE+CD2->CD2_DOC+CD2->CD2_CODCLI+CD2->CD2_LOJCLI == SF2->F2_SERIE+SF2->F2_DOC+SF2->F2_CLIENTE+SF2->F2_LOJA
				If CD2->CD2_IMP == "ICM   " .AND. CD2->CD2_TPMOV == "S"
					_nBICM += CD2->CD2_BC
					_nVICM += CD2->CD2_VLTRIB
				EndIf

				If CD2->CD2_IMP == "CF2   " .AND. CD2->CD2_TPMOV == "S"
					_nBICM += CD2->CD2_BC

				EndIf

				If CD2->CD2_IMP == "PS2   " .AND. CD2->CD2_TPMOV == "S"
					_nBICM += CD2->CD2_BC

				EndIf

				CD2->(DbSkip() )
			EndDo
		EndIf

		////////////////////////////////// fim validacao valores

		// ExecReproc(SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO)	//Executa reprocessamento da NF


		//SF2 -> ( RestArea(aAreaSF2) )



	EndIf

	/////////////////////////// FIM TRATATIVA DE VALOR DE DESC. SUFRAMA SOBRE A BASE DE ICMS ////////////////////////////////////


	If	SF2->F2_TIPO == 'C' .And. Left(SF2->F2_CLIENTE,2) == 'EX'
		Fatura()
	EndIf

	// INICIO: INCLUIDO POR VALDECIR EM 09.06.03
	If SF2->F2_TIPO == "N" .And. LEFT(SF2->F2_CLIENTE,2) == 'EX'

		lPrim		:= .T.
		nComiss  := 0
		nComisZZI:= 0
		nComisSD2:= 0
		nItensSD2:= 0
		nItem    := 0
		DbSelectArea("SD2")
		DbSetOrder(3)
		DbGotop()
		DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)
		While !Eof() 	.And. SD2->D2_FILIAL == xFilial("SD2");
				.And. SD2->D2_DOC	   == SF2->F2_DOC;
				.And. SD2->D2_SERIE  == SF2->F2_SERIE

			If lPrim
				lPrim := .F.
				If	SUBSTR(SD2->D2_CLIENTE,1,2) == 'EX' .And. Alltrim(SD2->D2_CF) $ ('7101_7102_7105_7106_7127')
					If !Fatura()
						Exit
					Else
						If	Empty(SF2->F2_FATURA)
							aAdd(aFatura,{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_EMISSAO,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_VALFAT})
						EndIf
					EndIf
					cQuery := "SELECT COUNT(D2_FILIAL) AS ITENS FROM "+RetSqlName("SD2")
					cQuery += " WHERE D2_FILIAL = '"+xFilial("SD2")+"' AND D_E_L_E_T_ <> '*' AND D2_DOC = '"+SF2->F2_DOC+"' AND D2_FILIAL = '"+xFilial("SD2")+"' "
					If ( Select ( "TSD2" ) <> 0 )
						DbSelectArea ( "TSD2" )
						DbCloseArea ()
					EndIf
					cQuery := ChangeQuery(cQuery)
					TCQuery cQuery New Alias "TSD2"
					TCSetField("TSD2","ITENS","N",03,00)
					While !TSD2->(Eof())
						nItensSD2 := TSD2->ITENS
						Exit
					EndDo
					nComisZZI := Posicione("ZZI",1,xFilial("ZZI")+cFatura+cSeqFat,"ZZI_COMISS")
				EndIf
			EndIf

			If	SUBSTR(SD2->D2_CLIENTE,1,2) == 'EX' .And. Alltrim(SD2->D2_CF) $ ('7101_7102_7105_7106_7127')
				nItem++
				nComiss := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_COMIS1")
				If	nComiss > 0
					RecLock("SD2",.F.)
					SD2->D2_COMIS1 := nComiss
					If	nItem == nItensSD2
						SD2->D2_VLCOMIS := (nComisZZI - nComisSD2)
					Else
						SD2->D2_VLCOMIS:= Round(SD2->D2_TOTAL * SD2->D2_COMIS1,2) / 100
						nComisSD2	   += SD2->D2_VLCOMIS
					EndIf
					MsUnlock()
				EndIf
			EndIf

			DbSelectArea("SD2")
			SD2->(DbSkip())
		Enddo

		cChave  := "E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO"
		nIndice := 0
		DbSelectArea("SIX")
		DbSeek("SE1")
		While !Eof() .And. SIX->INDICE == "SE1"
			nIndice := nIndice + 1
			If alltrim(cChave) == alltrim(SIX->chave)
				Exit
			EndIf
			DbSkip()
		End

		DbSelectArea("SE1")
		DbSetOrder(nIndice)
		DbGotop()
		DbSeek(xFilial("SE1")+SF2->F2_SERIE+SF2->F2_DOC,.T.)
		While !Eof() .And. SE1->E1_FILIAL 	== xFilial("SE1");
				.And. SE1->E1_PREFIXO 	== SF2->F2_SERIE;
				.And. SE1->E1_NUM		== SF2->F2_DOC


			DbSelectArea("SE1")
			RecLock("SE1",.F.)
			SE1->E1_COMISSA := nComiss
			SE1->E1_VALCOM1 := nComisZZI
			MsUnLock("SE1")

			DbSelectArea("SE1")
			SE1->(DbSkip())
		EndDo
	EndIf
	// FIM: INCLUIDO POR VALDECIR EM 09.06.03


	nDESCFIN := 0.00
	nVLFAT   := 0.00
	SELE SD2
	DBSETORDER(3)
	DBSEEK(xFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
	WHILE !EOF() .AND. xFILIAL("SD2")==SD2->D2_FILIAL  .AND.;
			SF2->F2_DOC     == SD2->D2_DOC  .AND.;
			SF2->F2_SERIE   == SD2->D2_SERIE  .AND.;
			SF2->F2_CLIENTE == SD2->D2_CLIENTE .AND.;
			SF2->F2_LOJA    == SD2->D2_LOJA

		SELE SF4
		DBSETORDER(1)
		IF DBSEEK(xFILIAL("SF4")+SD2->D2_TES) .AND. SF4->F4_DUPLIC=="S"
			nVLFAT := nVLFAT + (SD2->D2_PRCMPED*SD2->D2_QUANT)
		ENDIF

		SELE SD2
		SKIP
		LOOP
	END
	SELE SD2
	DBSETORDER(3)
	IF DBSEEK(xFILIAL("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		SELE SC5
		DBSETORDER(1)
		IF DBSEEK(xFILIAL("SC5")+SD2->D2_PEDIDO)
			nDESCFIN := SC5->C5_DESCFI
		ENDIF
	ENDIF

	//Sensus-Denis | 17/07/2015: Tratamento para gravação de guia de recolhimento
	lTem := .F. //variavel de controle para executar apenas uma vez o bloco de gravacao
	if type('lC2F6OK') <> 'U'
		lTem := .T.
	endif

	//	if !empty(sf2->f2_icmsret) .and. sf2->f2_tipo == 'N' .and. alltrim(sf2->f2_est) <> 'SC'
	If (SF2->F2_ICMSRET > 0) .And. SF2->F2_TIPO == 'N' .And. SuperGetMV("MV_ESTADO")<>SF2->F2_EST
		//Verifica se foi gerado título financeiro
		If Empty(SF2->F2_NFICMST)
			If !lTem

				cNumSe2 := 'ICM' + GeraTitIcm()

				SF2->(RecLock('SF2', .F.))
				SF2->F2_NFICMST := cNumSe2
				SF2->(MsUnlock())

			EndIf
		Else
			cNumSe2 := SF2->F2_NFICMST
		EndIf

		AtuSE2(cNumSe2)

		//Verificar a existencia da nota no CDC//Referente implantação GNRE no padrao PERSONALITEC
		/*dbSelectArea('CDC')
		dbSetorder(1) //1 - CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
		If !lTem .and. !dbSeek(xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
			If CDC->CDC_FILIAL+CDC->CDC_TPMOV+CDC->CDC_DOC+CDC->CDC_SERIE+CDC->CDC_CLIFOR+CDC->CDC_LOJA+CDC->CDC_UF <> xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_EST
				RecLock('CDC', .T.)
				CDC->CDC_FILIAL := xFilial('CDC')
				CDC->CDC_TPMOV	:= 'S'
				CDC->CDC_DOC	:= SF2->F2_DOC
				CDC->CDC_SERIE	:= SF2->F2_SERIE
				CDC->CDC_CLIFOR	:= SF2->F2_CLIENTE
				CDC->CDC_LOJA	:= SF2->F2_LOJA
				CDC->CDC_GUIA	:= cNumSe2 //sf2->f2_doc
				CDC->CDC_UF		:= SF2->F2_EST
				CDC->CDC_IFCOMP	:= 'ZZZ0'
				msUnlock('CDC')
			Endif
		Endif

		dbSelectArea('SF6')
		dbSetorder(3)
		if !lTem .and. !dbSeek(xFilial('SF6')+'2'+sf2->f2_tipo+sf2->f2_doc+sf2->f2_serie+sf2->f2_cliente+sf2->f2_loja)
			dDtult	 := LastDay( dDatabase, 0)
			dDtAux	 := dDtult+1
			dDtuti	 := LastDay( dDtAux, 1)
			//	_codRec := U_C2INIREC()
			Do Case  // Jefferson descomentou //descontinuado ja esta sendo tratado no fonte C2INIREC -  Sensus Tecnologia - 19/10/2015 - Fabricio E. Reche
				Case SF2->F2_EST == "ES"
				_codRec := '1228'
				Case SF2->F2_EST <> "SC"
				_codRec := '100099'  //todos exceto SC e ES
			EndCase
			cNumConv := 'PROTOCOLO 190/196-2010'

			Reclock('SF6',.t.)
			SF6->F6_FILIAL := xFilial('SF6')
			SF6->F6_NUMERO	:= cNumSe2//sf2->f2_doc
			SF6->F6_EST		:= SF2->F2_EST
			SF6->F6_TIPOIMP	:= '3'
			SF6->F6_VALOR	:= SF2->F2_ICMSRET
			SF6->F6_INSC	:= SM0->M0_INSC
			SF6->F6_DTARREC	:= SF2->F2_EMISSAO
			SF6->F6_DTVENC	:= DataValida(SF2->F2_EMISSAO+1)
			SF6->F6_DTPAGTO	:= DataValida(SF2->F2_EMISSAO+1)
			SF6->F6_MESREF	:= month(SF2->F2_EMISSAO)
			SF6->F6_ANOREF	:= year(SF2->F2_EMISSAO)
			SF6->F6_CODREC	:= _codRec
			SF6->F6_DOC		:= SF2->F2_DOC
			SF6->F6_SERIE	:= SF2->F2_SERIE
			SF6->F6_CLIFOR	:= SF2->F2_CLIENTE
			SF6->F6_LOJA	:= SF2->F2_LOJA
			SF6->F6_OPERNF	:= '2'
			SF6->F6_TIPODOC	:= SF2->F2_TIPO
			SF6->F6_PROCESS	:= '2'
			/*
			Sensus Tecnologia - 19/10/2015 - Fabricio E. Reche
			Adicionado campos com valores vindos do inicializador padrão
		*//*
		SF6->F6_CLAVENC := CriaVar('F6_CLAVENC')
		SF6->F6_NUMCONV := cNumConv
		SF6->F6_BANCO   := CriaVar('F6_BANCO')
		SF6->F6_AGENCIA := CriaVar('F6_AGENCIA')
		/* FIM */
		/*SF6->(msUnlock())
		Else
			reclock('SF6',.f.)
			SF6->F6_DTPAGTO	:= SF6->F6_DTVENC
			SF6->F6_INSC	:= iif(empty(SF6->F6_INSC),SM0->M0_INSC,SF6->F6_INSC)
			SF6->F6_TIPODOC	:= iif(empty(SF6->F6_TIPODOC),SF2->F2_TIPO,SF6->F6_TIPODOC)
			SF6->(msUnlock())
		Endif

		//Ajuste da GUIA no CDC
		dbSelectArea('CDC')
		dbSetorder(1)
		dbSeek(xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.T.)
		If CDC->CDC_FILIAL+CDC->CDC_TPMOV+CDC->CDC_DOC+CDC->CDC_SERIE+CDC->CDC_CLIFOR+CDC->CDC_LOJA+CDC->CDC_UF == xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_EST
			reclock('CDC',.F.)
			CDC->CDC_GUIA	:= cNumSe2 //sf2->f2_doc
			CDC->(msUnlock())
		Endif*///Referente implantação GNRE no padrao PERSONALITEC
	Endif

	//-----------------------------------------------
	// Inicio Jefferson Guermandi - Sensus - 05/01/16
	//-----------------------------------------------

	//tratamento icms complementar DIFAL
	If Empty(IESubTrib(SF2->F2_EST)) .And. SF2->F2_TIPOCLI == 'F' .And. SuperGetMV("MV_ESTADO")<>SF2->F2_EST .And. SF3->F3_DIFAL > 0
		lGDifal	:= Iif(ValType(MV_PAR24)<>"N",.F.,(mv_par24==1))
		lGFcpDif	:= Iif(ValType(MV_PAR25)<>"N",.F.,(mv_par25==1))
		cNomForn    := ''
		lGuiaDifal  := .T.

		If Empty(SF2->F2_GNRDIF)
			If lGDifal
				cNumSe2 := 'ICM' + GerTitICC()

				SF2->(RecLock('SF2', .F.))
				SF2->F2_GNRDIF := cNumSe2
				SF2->(MsUnlock())
			EndIf
		Else
			cNumSe2 := SF2->F2_GNRDIF
		EndIf
		/*	If lGDifal
		cNumSe2 := 'ICM' + GerTitICC()

		SF2->(RecLock('SF2', .F.))
		SF2->F2_NFICMST := cNumSe2
		SF2->(MsUnlock())
		EndIf              */

		//Verificar a existencia da nota no CDC
		/*dbSelectArea('CDC')
		dbSetorder(1) //1 - CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
		If !lTem .and. !dbSeek(xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.t.)
			If CDC->CDC_FILIAL+CDC->CDC_TPMOV+CDC->CDC_DOC+CDC->CDC_SERIE+CDC->CDC_CLIFOR+CDC->CDC_LOJA+CDC->CDC_UF <> xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_EST
				reclock('CDC', .T.)
				CDC->CDC_FILIAL := xFilial('CDC')
				CDC->CDC_TPMOV	:= 'S'
				CDC->CDC_DOC	:= SF2->F2_DOC
				CDC->CDC_SERIE	:= SF2->F2_SERIE
				CDC->CDC_CLIFOR	:= SF2->F2_CLIENTE
				CDC->CDC_LOJA	:= SF2->F2_LOJA
				CDC->CDC_guia	:= cNumSe2
				CDC->CDC_UF		:= SF2->F2_EST
				CDC->CDC_IFCOMP	:= 'ZZZ7'
				msUnlock('CDC')
			Endif
		Endif

		nDIFAL := 0
		nFECCP := 0
		//posicionar na SD2 e pegar os valores dos impostos ICMS complementar e FEC
		dbSelectArea('SD2')
		dbSetorder(3)
		dbSeek(xFilial('SD2')+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
		While !EOF() .And. xFilial("SD2")==SD2->D2_FILIAL .And.;
		SD2->D2_DOC     == SF2->F2_DOC .And.;
		SD2->D2_SERIE   == SF2->F2_SERIE .And.;
		SD2->D2_CLIENTE == SF2->F2_CLIENTE .And.;
		SD2->D2_LOJA    == SF2->F2_LOJA

			nDIFAL      += SD2->D2_DIFAL
			nFECCP      += SD2->D2_VFCPDIF
			dbSkip()
		End

		dbSelectArea('SF6')
		dbSetorder(3)
		if !lTem .and. !dbSeek(xFilial('SF6')+'2'+SF2->F2_TIPO+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
			dDtult	 := LastDay( dDatabase, 0)
			dDtAux	 := dDtult+1
			dDtuti	 := LastDay( dDtAux, 1)

			_codRec  := '100102'
			Do Case
				Case SF2->F2_EST == "ES"
				_codRec := '386-7'
				//Case SF2->F2_EST == "SP"
				//_codRec := '10002'
				//Case SF2->F2_EST == "RJ"
				//	_codRec := '063-9'
			EndCase

			cNumConv := 'CONVENIO 93/2015'

			//Registro do ICC
			Reclock('SF6',.t.)
			SF6->F6_FILIAL := xFilial('SF6')
			SF6->F6_NUMERO	:= cNumSe2
			SF6->F6_EST		:= SF2->F2_EST
			SF6->F6_TIPOIMP	:= 'B'
			SF6->F6_VALOR	:= nDIFAL
			SF6->F6_INSC	:= SM0->M0_INSC
			SF6->F6_DTARREC	:= SF2->F2_EMISSAO
			SF6->F6_DTVENC	:= DataValida(SF2->F2_EMISSAO+1)
			SF6->F6_DTPAGTO	:= DataValida(SF2->F2_EMISSAO+1)
			SF6->F6_MESREF	:= month(SF2->F2_EMISSAO)
			SF6->F6_ANOREF	:= year(SF2->F2_EMISSAO)
			SF6->F6_CODREC	:= _codRec
			SF6->F6_DOC		:= SF2->F2_DOC
			SF6->F6_SERIE	:= SF2->F2_SERIE
			SF6->F6_CLIFOR	:= SF2->F2_CLIENTE
			SF6->F6_LOJA	:= SF2->F2_LOJA
			SF6->F6_OPERNF	:= '2'
			SF6->F6_TIPODOC	:= SF2->F2_TIPO
			SF6->F6_PROCESS	:= '2'
			SF6->F6_NUMCONV := cNumConv
			SF6->F6_COBREC  := '003'
			SF6->F6_BANCO   := CriaVar('F6_BANCO')
			SF6->F6_AGENCIA := CriaVar('F6_AGENCIA')
		/* FIM */
		//SF6->(msUnlock())
		/*Else
			reclock('SF6',.f.)
			SF6->F6_DTPAGTO	:= SF6->F6_DTVENC
			SF6->F6_INSC	:= iif(empty(SF6->F6_INSC),SM0->M0_INSC,SF6->F6_INSC)
			SF6->F6_TIPODOC	:= iif(empty(SF6->F6_TIPODOC),SF2->F2_TIPO,SF6->F6_TIPODOC)
			SF6->(msUnlock())
		Endif

		AtuSE2(cNumSe2,.F.,'',.T.)

		// update na tabela CDC do numero da guia  caso não tenha atualizado
		dbSelectArea('CDC')
		dbSetorder(2)	   //2- CDC_FILIAL + CDC_GUIA+CDC_UF
		If (dbSeek(xFilial('CDC')+cNumSe2+SF2->F2_EST))
			reclock('CDC',.f.)
			CDC->CDC_GUIA	:= cNumSe2
			msUnlock('CDC')
		EndIf

		//	If  SF3->F3_VFCPDIF > 0 .And. lGFcpDif .And. SF3->F3_DIFAL > 0
		If  SF3->F3_VFCPDIF > 0 //.And. lGFcpDif .And. nDIFAL > 0

			/*	   Desativado pois foi criado campo na F2 que grava o numero do FECP     - Jefferson 03/02/16
			/*
			//Posicionar na SE2 do DIFAL para buscar o numero do titulo lo FECP
			dbSelectArea('SE2')
			dbSetorder(1)
			dbSeek(xFilial('SE2')+cNumSe2+' TX ')

			// Buscar numero do titulo da fecp
			dbSelectArea('SE2')
			dbSetorder(2)
			dbSeek(xFilial('SE2')+'FECP      '+SE2->E2_NOMFOR+SE2->E2_PREFIXO)

			cNomForn := SE2->E2_NOMFOR
			lGuiaFecp:= .T.

			If Empty(Alltrim(SE2->E2_NUM))
			cNumSe2 := 'ICM' + GerTitFECCP()
			Else
			cNumSe2 := 'ICM' + Alltrim(SE2->E2_NUM)
		EndIf                  */

		/*lGuiaFecp:= .T.

			If Empty(SF2->F2_GNRFECP)
				If lGDifal
					cNumSe2 := 'ICM' + GerTitICC()

					SF2->(RecLock('SF2', .F.))
					SF2->F2_GNRFECP := cNumSe2
					SF2->(MsUnlock())
				EndIf
			Else
				cNumSe2 := SF2->F2_GNRFECP
			EndIf

			//Verificar a existencia da nota no CDC
			dbSelectArea('CDC')
			dbSetorder(1) //1- CDC_FILIAL+CDC_TPMOV+CDC_DOC+CDC_SERIE+CDC_CLIFOR+CDC_LOJA+CDC_GUIA+CDC_UF
			If !dbSeek(xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+cNumSe2+SF2->F2_EST,.t.)
				If CDC->CDC_FILIAL+CDC->CDC_TPMOV+CDC->CDC_DOC+CDC->CDC_SERIE+CDC->CDC_CLIFOR+CDC->CDC_LOJA+cNumSe2+CDC->CDC_UF <> xFilial('CDC')+'S'+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_EST
					reclock('CDC', .T.)
					CDC->CDC_FILIAL := xFilial('CDC')
					CDC->CDC_TPMOV	:= 'S'
					CDC->CDC_DOC	:= SF2->F2_DOC
					CDC->CDC_SERIE	:= SF2->F2_SERIE
					CDC->CDC_CLIFOR	:= SF2->F2_CLIENTE
					CDC->CDC_LOJA	:= SF2->F2_LOJA
					CDC->CDC_guia	:= cNumSe2
					CDC->CDC_UF		:= SF2->F2_EST
					CDC->CDC_IFCOMP	:= 'ZZZ7'
					msUnlock('CDC')
				Endif
			Endif

			dbSelectArea('SF6')
			dbSetorder(3)
			if !lTem //.and. !dbSeek(xFilial('SF6')+'2'+sf2->f2_tipo+sf2->f2_doc+sf2->f2_serie+sf2->f2_cliente+sf2->f2_loja)
				dDtult	 := LastDay( dDatabase, 0)
				dDtAux	 := dDtult+1
				dDtuti	 := LastDay( dDtAux, 1)

				_codRec  := '100129'
				Do Case
					Case SF2->F2_EST == "ES"
					_codRec := '162-7'
					//	Case SF2->F2_EST == "RJ"
					//	_codRec := '750-1'
				EndCase

				cNumConv := 'CONVENIO 93/2015'

				//Registro do ICC
				Reclock('SF6',.t.)
				SF6->F6_FILIAL := xFilial('SF6')
				SF6->F6_NUMERO	:= cNumSe2
				SF6->F6_EST		:= SF2->F2_EST
				SF6->F6_TIPOIMP	:= 'B'
				SF6->F6_VALOR	:= nFECCP
				SF6->F6_INSC	:= SM0->M0_INSC
				SF6->F6_DTARREC	:= SF2->F2_EMISSAO
				SF6->F6_DTVENC	:= DataValida(SF2->F2_EMISSAO+1)
				SF6->F6_DTPAGTO	:= DataValida(SF2->F2_EMISSAO+1)
				SF6->F6_MESREF	:= month(SF2->F2_EMISSAO)
				SF6->F6_ANOREF	:= year(SF2->F2_EMISSAO)
				SF6->F6_CODREC	:= _codRec
				SF6->F6_DOC		:= SF2->F2_DOC
				SF6->F6_SERIE	:= SF2->F2_SERIE
				SF6->F6_CLIFOR	:= SF2->F2_CLIENTE
				SF6->F6_LOJA	:= SF2->F2_LOJA
				SF6->F6_OPERNF	:= '2'
				SF6->F6_TIPODOC	:= SF2->F2_TIPO
				SF6->F6_PROCESS	:= '2'
				SF6->F6_NUMCONV := cNumConv
				SF6->F6_COBREC  := '006'
				SF6->F6_BANCO   := CriaVar('F6_BANCO')
				SF6->F6_AGENCIA := CriaVar('F6_AGENCIA')
		/* FIM */
		//SF6->(msUnlock())
		/*Else
				reclock('SF6',.f.)
				SF6->F6_DTPAGTO	:= SF6->F6_DTVENC
				SF6->F6_INSC	:= iif(empty(SF6->F6_INSC),SM0->M0_INSC,SF6->F6_INSC)
				SF6->F6_TIPODOC	:= iif(empty(SF6->F6_TIPODOC),SF2->F2_TIPO,SF6->F6_TIPODOC)
				SF6->(msUnlock())
			Endif
			AtuSE2(cNumSe2,lGuiaFecp,cNomForn,.F.)

			// update na tabela CDC do numero da guia  caso não tenha atualizado
			dbSelectArea('CDC')
			dbSetorder(2)	   //2- CDC_FILIAL + CDC_GUIA+CDC_UF
			If (dbSeek(xFilial('CDC')+cNumSe2+SF2->F2_EST))
				reclock('CDC',.f.)
				CDC->CDC_GUIA	:= cNumSe2
				msUnlock('CDC')
			EndIf

		EndIf	*///Referente implantação GNRE no padrao PERSONALITEC
	Endif

	//-----------------------------------------------
	// Fim Jefferson Guermandi - Sensus - 05/01/16
	//-----------------------------------------------

	lC2F6OK 	:= NIL
	nC2F6Tela	:= NIL	//Adicionado Murilo - Goone - 24/04/2018
	//----------------------------------------------------------------------------------

	// Comentado em 03.03.05 por Valdecir .
	// Foi necessario comentar esta linha, pois a variavel nVlfat, esta recebendo o valor
	// na moeda estrangeira, mas o valor do frete estava na moeda corrente, por isto,
	// o valor faturado estava ficando a maior.
	/*
	IF SUBS(SF2->F2_CLIENTE,1,2)=="EX"
	RECLOCK("SF2",.F.)
	SF2->F2_VALFAT := nVLFAT + SF2->F2_FRETE+SF2->F2_DESPESA+SF2->F2_SEGURO
	MSUNLOCK("SF2")
	ENDIF
	*/
	SELE SE1
	DBSETORDER(1)
	DBSEEK(xFILIAL("SE1")+SF2->F2_SERIE+SF2->F2_DOC)
	WHILE ! EOF() .AND. xFILIAL("SE1")==SE1->E1_FILIAL .AND.;
			SE1->E1_PREFIXO==SF2->F2_SERIE .AND.;
			SE1->E1_NUM==SF2->F2_DOC
		IF SE1->E1_CLIENTE #SF2->F2_CLIENTE
			SELE SE1
			SKIP
			LOOP
		ENDIF
		RECLOCK("SE1",.F.)
		If !Empty(nDESCFIN)
			SE1->E1_DESCFIN := nDESCFIN
			SE1->E1_TIPODES := '1'
		EndIf

		// JULIANA - 20.05.08 -  Para gravar percentual de comissao na primeira parcela
		//                       dos titulos gerados pelas notas que nao tem subs tributaria.
		IF SF2->F2_ICMSRET == 0 .AND. SUBS(SF2->F2_CLIENTE,1,2)<>"EX" .AND. ALLTRIM(SE1->E1_PARCELA)=="A" .OR. EMPTY(SE1->E1_PARCELA)

			DbSelectArea("SD2")
			DbSetOrder(3)
			DbGotop()
			DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.T.)

			SE1->E1_COMIS1 := SD2->D2_COMIS1
		ENDIF
		/*****/


		// Comentado em 03.03.05 por Valdecir .
		// Foi necessario comentar esta linha, pois a variavel nVlfat, esta recebendo o valor
		// na moeda estrangeira, mas o valor do frete estava na moeda corrente, por isto,
		// o valor faturado estava ficando a maior.
		//
		//IF SUBS(SE1->E1_CLIENTE,1,2)=="EX"
		//   SE1->E1_VALOR := SF2->F2_VALFAT
		//   SE1->E1_SALDO := SF2->F2_VALFAT
		//ENDIF
		//
		MSUNLOCK("SE1")
		SELE SE1
		SKIP
		LOOP
	END

	/// APAGA ESPELHO DE ETIQUETAS QUANDO A NOTA E' FATURADA ///

	SELE SZO
	DBSETORDER(1)
	DBSEEK(xFILIAL("SZO")+SC5->C5_NUM)
	WHILE !EOF() .AND. SZO->ZO_PEDIDO == SC5->C5_NUM
		RECLOCK("SZO",.F.)
		DBDELETE()
		MSUNLOCK("SZO")
		SELE SZO
		DBSKIP()
	END

	/// FIM ///

	If	Len(aFatura) > 0
		cMailTo   := "jonas@buddemeyer.com.br;vivian@buddemeyer.com.br"
		aUsuario  := pswret()
		cMailFrom := "cpd@buddemeyer.com.br"

		cAssunto  := "Notas Fiscais de Exportação sem Número de Fatura "

		//{SF2->F2_SERIE,SF2->F2_DOC,SF2->F2_EMISSAO,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_VALFAT}
		cMensagem := "<table class=MsoTableGrid border=1 cellspacing=0 cellpadding=0"
		cMensagem += " style='border-collapse:collapse;border:none'>"
		cMensagem +=" <tr>"
		cMensagem +="<td width=47 valign=top style='width:35.6pt;border:solid windowtext 1.0pt;"
		cMensagem +="padding:0cm 5.4pt 0cm 5.4pt'>"
		cMensagem +="<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
		cMensagem +="font-family:Arial'>Série <o:p></o:p></span></font></p>"
		cMensagem +="</td>"
		cMensagem +="<td width=84 valign=top style='width:63.0pt;border:solid windowtext 1.0pt;"
		cMensagem +="border-left:none;padding:0cm 5.4pt 0cm 5.4pt'>"
		cMensagem +="<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
		cMensagem +="font-family:Arial'>Nota Fiscal<o:p></o:p></span></font></p>"
		cMensagem +="</td>"
		cMensagem +="<td width=84 valign=top style='width:63.0pt;border:solid windowtext 1.0pt;"
		cMensagem +="border-left:none;padding:0cm 5.4pt 0cm 5.4pt'>"
		cMensagem +="<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
		cMensagem +="font-family:Arial'>Data Emissão<o:p></o:p></span></font></p>"
		cMensagem +="</td>"
		cMensagem +="<td width=96 valign=top style='width:72.0pt;border:solid windowtext 1.0pt;"
		cMensagem +="border-left:none;padding:0cm 5.4pt 0cm 5.4pt'>"
		cMensagem +="<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
		cMensagem +="font-family:Arial'>Cliente<o:p></o:p></span></font></p>"
		cMensagem +="</td>"
		cMensagem +="<td width=108 valign=top style='width:81.0pt;border:solid windowtext 1.0pt;"
		cMensagem +="border-left:none;padding:0cm 5.4pt 0cm 5.4pt'>"
		cMensagem +="<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
		cMensagem +="font-family:Arial'>Valor Faturado<o:p></o:p></span></font></p>"
		cMensagem +="</td>"
		cMensagem +="</tr>"

		For i:=1 To Len(aFatura)
			cMensagem +="<tr>"
			cMensagem +="<td width=47 valign=top style='width:35.6pt;border:solid windowtext 1.0pt;"
			cMensagem +="border-top:none;padding:0cm 5.4pt 0cm 5.4pt'>"
			cMensagem += "<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;font-family:Arial'>"
			cMensagem += aFatura[i,1]
			cMensagem += "<o:p></o:p></span></font></p></td>"

			cMensagem += "<td width=84 valign=top style='width:63.0pt;border-top:none;border-left:none;"
			cMensagem += "border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;"
			cMensagem += "padding:0cm 5.4pt 0cm 5.4pt'>"
			cMensagem += "<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
			cMensagem += "font-family:Arial'>"
			cMensagem += aFatura[i,2]
			cMensagem += "<o:p></o:p></span></font></p></td>"

			cMensagem += "<td width=84 valign=top style='width:63.0pt;border-top:none;border-left:none;"
			cMensagem += "border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;"
			cMensagem += "padding:0cm 5.4pt 0cm 5.4pt'>"
			cMensagem += "<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
			cMensagem += "font-family:Arial'>"
			cMensagem += Dtoc(aFatura[i,3])
			cMensagem += "<o:p></o:p></span></font></p></td>"

			cMensagem += "<td width=96 valign=top style='width:72.0pt;border-top:none;border-left:none;"
			cMensagem += "border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;"
			cMensagem += "padding:0cm 5.4pt 0cm 5.4pt'>"
			cMensagem += "<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
			cMensagem += "font-family:Arial'>"
			cMensagem += aFatura[i,4]+"/"+aFatura[i,5]
			cMensagem += "<o:p></o:p></span></font></p></td>"

			cMensagem += "<td width=108 valign=top style='width:81.0pt;border-top:none;border-left:"
			cMensagem += "none;border-bottom:solid windowtext 1.0pt;border-right:solid windowtext 1.0pt;"
			cMensagem += "padding:0cm 5.4pt 0cm 5.4pt'>"
			cMensagem += "<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;"
			cMensagem += "font-family:Arial'>"
			cMensagem += Transform(aFatura[i,6],"@E 9,999,999.99")
			cMensagem += "<o:p></o:p></span></font></p></td>"

			cMensagem += "</td>"
			cMensagem += "</tr>"
			cMensagem += "<tr>"
		Next
		cMensagem += "</table>"
		cMensagem += "<p class=MsoNormal><font size=3 face="+"Times New Roman"+"><span style='font-size:"
		cMensagem += "12.0pt'><br>"
		cMensagem += "Faturista - "+Substr(cUsuario,7,15)+"<br>"
		cMensagem += "Data - "+Dtoc(dDataBase)+"  Hora  - "+Substr(Time(),1,5)+"</span></font><font size=2 face=Arial><span"
		cMensagem += "style='font-size:10.0pt;font-family:Arial'><o:p></o:p></span></font></p>	"

		CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenhaMail RESULT lResult
		SEND MAIL FROM cMailFrom TO cMailTo SUBJECT cAssunto BODY cMensagem RESULT lResult

		DISCONNECT SMTP SERVER
	EndIf

	SF2 -> ( RestArea(aAreaSF2) )
	RestArea(aArea)
Return(nil)        // incluido pelo assistente de conversao do AP6 IDE em 24/04/02

Static Function Fatura()

	// Variaveis Private da Funcao
	Private lRet := .F.
	Private oFatura
	Private oSeqFat
	Private oNota
	Private oSerie
	Private _oDlg				// Dialog Principal
	Private lClose := .F.
	// Variaveis que definem a Acao do Formulario

	DEFINE MSDIALOG _oDlg TITLE OemToAnsi("Número da Fatura Exportacao") FROM C(285),C(283) TO C(468),C(716) PIXEL

	// Cria as Groups do Sistema
	@ C(004),C(005) TO C(075),C(212) LABEL "" PIXEL OF _oDlg

	// Cria Componentes Padroes do Sistema
	@ C(020),C(020) Say "Nota Fiscal" Size C(028),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
	@ C(020),C(071) MsGet oNota Var SF2->F2_DOC Size C(038),C(009) COLOR CLR_BLACK PIXEL OF _oDlg When .F.
	@ C(020),C(112) MsGet oSerie Var SF2->F2_SERIE Size C(019),C(009) COLOR CLR_BLACK PIXEL OF _oDlg When .F.
	@ C(040),C(020) Say "Fatura / Sequencia" Size C(048),C(008) COLOR CLR_RED PIXEL OF _oDlg
	@ C(040),C(072) MsGet oFatura Var cFatura Size C(038),C(009) COLOR CLR_RED PIXEL OF _oDlg Valid ValFat()
	@ C(040),C(112) MsGet oSeqFat Var cSeqFat Size C(019),C(009) COLOR CLR_RED PIXEL OF _oDlg Valid ValFat()
	@ C(077),C(132) Button "Gravar" Size C(037),C(012) PIXEL OF _oDlg Action(GravaSF2())
	@ C(077),C(174) Button "Cancelar" Size C(037),C(012) PIXEL OF _oDlg Action(_oDlg:End())

	ACTIVATE MSDIALOG _oDlg CENTERED// Valid lClose

Return .T. // lRet

Static Function ValFat()

	cCampo := ReadVar()
	cConteu:= (&(ReadVar()))

	If cCampo == 'CFATURA'
		/*
		If Empty(cConteu)
		Alert(OemToAnsi("Número da Fatura Obrigatório para Notas de Exportação"))
		oFatura:SetFocus()
		Return .F.
		Else
		If Empty(Posicione("ZZI",1,xFilial("ZZI")+cConteu+"00","ZZI_SEQFAT"))
		Alert(OemToAnsi("Fatura não Existente na Tabela ZZI !!!"))
		oFatura:SetFocus()
		Return .F.
		EndIf
		EndIf
		*/

		If !Empty(cConteu)
			If Empty(Posicione("ZZI",1,xFilial("ZZI")+cConteu+"00","ZZI_SEQFAT"))
				Alert(OemToAnsi("Fatura não Existente na Tabela ZZI !!!"))
				oFatura:SetFocus()
				Return .F.
			EndIf
		EndIf

	ElseIf	cCampo == 'CSEQFAT'

		If !Empty(cConteu)
			If Empty(Posicione("ZZI",1,xFilial("ZZI")+cFatura+cConteu,"ZZI_SEQFAT"))
				Alert(OemToAnsi("Não existe esta Seqüência nesta fatura !!!"))
				oFatura:SetFocus()
				Return .F.
			EndIf
		EndIf

		/*
		If Empty(cConteu)
		Alert(OemToAnsi("Número da Seqüência da Fatura Obrigatório para Notas de Exportação"))
		oSeqFat:SetFocus()
		Return .F.
		Else
		If Empty(Posicione("ZZI",1,xFilial("ZZI")+cFatura+cConteu,"ZZI_SEQFAT"))
		Alert(OemToAnsi("Não existe esta Seqüência nesta fatura !!!"))
		oFatura:SetFocus()
		Return .F.
		EndIf
		EndIf
		*/
	EndIf

	If	!Empty(cFatura) .And. !Empty(cSeqFat)
		cCliente  := Posicione("ZZI",1,xFilial("ZZI")+cFatura+cSeqFat,"ZZI_CLIENT")
		cLoja     := Posicione("ZZI",1,xFilial("ZZI")+cFatura+cSeqFat,"ZZI_LOJA")
		If	(SF2->F2_CLIENTE != cCliente) .Or. (SF2->F2_LOJA != cLoja)
			Alert(OemToAnsi("Esta Fatura não pertence a este Cliente."+Chr(13)+Chr(10)+"Verifique !!!"))
			oFatura:SetFocus()
			cFatura := space(06)
			cSeqFat := space(02)
			_oDlg:Refresh()
			Return .T.
		EndIf
	EndIf

Return .T.

Static Function GravaSF2()

	If	!Empty(cFatura) .And. !Empty(cSeqFat)
		cCliente  := Posicione("ZZI",1,xFilial("ZZI")+cFatura+cSeqFat,"ZZI_CLIENT")
		cLoja     := Posicione("ZZI",1,xFilial("ZZI")+cFatura+cSeqFat,"ZZI_LOJA")
		If	(SF2->F2_CLIENTE == cCliente) .And. (SF2->F2_LOJA == cLoja)
			lClose := .T.
			RECLOCK("SF2",.F.)
			SF2->F2_FATURA := cFatura
			SF2->F2_SEQFAT := cSeqFat
			MSUNLOCK("SF2")
			_oDlg:End()
			lRet := .T.
		EndIf
	EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
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

//Função para gerar titulo financeiro para a guia do ICMS ST - Sensus Tecnologia - 19/10/2015 - Fabricio E. Reche
Static Function GeraTitIcm

	Local aArea    := GetArea()
	Local cNumero  := ""
	Local nVlrIcm  := SF2->F2_ICMSRET
	Local nMes     := Month(SF2->F2_EMISSAO)
	Local nAno     := Year(SF2->F2_EMISSAO)
	Local aDatas   := DetDatas(nMes, nAno, 3, 1)
	Local dDtIni   := aDatas[1]
	Local dDtFim   := aDatas[2]
	Local dDtVenc  := DataValida(aDatas[2]+1, .T.)
	Local lLancCont:= IIF(Type("Mv_Par03")<>"N", .F., Mv_Par03 == 1)
	Local cLcPadTit:= Substr(GetNewPar("MV_LPADICM", ""),1,3)
	Local aGNRE    := {}
	Local aRecTit  := {}
	Local aDSF2    := {}
	Local lConfTit := .F.

	AADD(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST})

	GravaTit(.F., nVlrIcm, "ICMS", "IC", cLcPadTit, dDtIni, dDtFim, dDtVenc, 1, .F., nMes, nAno, nVlrIcm, 0, "MATA460A", lLancCont, @cNumero, @aGNRE,,,,,,,, @aRecTit, @lConfTit, 0, aDSF2)

	RestArea(aArea)

Return cNumero


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GerTitICC   ºAutor  ³Jefferson Guermandi º Data ³  06/01/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para gerar titulo financeiro para a guia do ICC     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GerTitICC

	Local aArea    := GetArea()
	Local cNumero  := ""
	Local nVlrDifal:= SF3->F3_DIFAL
	Local nMes     := Month(SF2->F2_EMISSAO)
	Local nAno     := Year(SF2->F2_EMISSAO)
	Local aDatas   := DetDatas(nMes, nAno, 3, 1)
	Local dDtIni   := aDatas[1]
	Local dDtFim   := aDatas[2]
	Local dDtVenc  := DataValida(aDatas[2]+1, .T.)
	Local lLancCont:= Iif(ValType(MV_PAR03)<>"N",.F.,(mv_par03==1)) //IIF(Type("Mv_Par03")<>"N", .F., Mv_Par03 == 1)
	Local cLcPadTit:= Substr(SuperGetMv("MV_LPADICM"),1,3)
	Local aGNRE    := {}
	Local aRecTit  := {}
	Local aDSF2    := {}
	Local lConfTit := .F.
	Local lGDifal:= Iif(ValType(MV_PAR24)<>"N",.F.,(mv_par24==1))

	AADD(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_TIPOCLI})

	GravaTit(Iif(ValType(MV_PAR17)<>"N",.F.,(mv_par17==1)),nVlrdifal,"DIFAL","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGDifal,nMes,nAno,nVlrdifal,0,"MATA460A",lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,,.T.,,@aRecTit,@lConfTit,0,aDSF2)

	RestArea(aArea)

Return cNumero



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GerTit      ºAutor  ³Jefferson Guermandi º Data ³  07/01/16 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para gerar titulo financeiro para a guia do FECCP   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GerTitFECCP

	Local aArea    := GetArea()
	Local cNumero  := ""
	Local nDifFecp  := SF3->F3_VFCPDIF
	Local nMes     := Month(SF2->F2_EMISSAO)
	Local nAno     := Year(SF2->F2_EMISSAO)
	Local aDatas   := DetDatas(nMes, nAno, 3, 1)
	Local dDtIni   := aDatas[1]
	Local dDtFim   := aDatas[2]
	Local dDtVenc  := DataValida(aDatas[2]+1, .T.)
	Local lLancCont:= Iif(ValType(MV_PAR03)<>"N",.F.,(mv_par03==1)) //IIF(Type("Mv_Par03")<>"N", .F., Mv_Par03 == 1)
	Local cLcPadTit:= Substr(GetNewPar("MV_LPADICM", ""),1,3)
	Local aGNRE    := {}
	Local aRecTit  := {}
	Local aDSF2    := {}
	Local lConfTit := .F.
	Local lGFcpDif	:= Iif(ValType(MV_PAR25)<>"N",.F.,(mv_par25==1))

	AADD(aDSF2,{SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_CLIENTE,SF2->F2_LOJA,SF2->F2_TIPO,"2",SF2->F2_EST,SF2->F2_TIPOCLI})

	GravaTit(Iif(ValType(MV_PAR17)<>"N",.F.,(mv_par17==1)),nDifFecp,"ICMS","IC",cLcPadTit,dDtIni,dDtFim,dDtVenc,1,lGFcpDif,nMes,nAno,nDifFecp,0,"MATA460A",lLancCont,@cNumero,@aGNRE,,,SF2->F2_EST,,.T.,,,@aRecTit,@lConfTit,0,aDSF2)

	RestArea(aArea)

Return cNumero


//Função para atualizar o título passado por parâmetro
Static Function AtuSE2(cNumero, lGuiaFecp, cNomForn, lGuiaDifal)

	Local aAreaSE2 := SE2->(GetArea()) //Integridade relacional
	Local cFornece := StrTran(AllTrim(GetNewPar("MV_RECST"+SF2->F2_EST, "")), ";", "") //Parâmetro do estado atual
	Local cPrefixo := Padr('ICM', TamSx3("E2_PREFIXO")[1]) //Prefixo padrão gerado pelo Protheus

	Default lGuiaFecp = .F.
	Default lGuiaDifal = .F.
	Default cNomForn := ''

	//Caso não tenha o prefixo no número
	If cPrefixo != Left(cNumero, Len(cPrefixo))
		cNumero := cPrefixo + cNumero
	EndIf

	//Atualiza o Histórico, a Natureza, Conta Deb. e o Vencimento do titulo
	/*	If lGuiaFecp
	SE2->(DbSetOrder(2))// E2_FILIAL+E2_NATUREZ+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE
	If SE2->(DbSeek(xFilial("SE2")+Padr('FECP', Len(SE2->E2_NATUREZ))+Padr(cNomForn, Len(SE2->E2_NOMFOR))+Padr(cNumero, Len(SE2->E2_PREFIXO+SE2->E2_NUM))+Space(Len(SE2->E2_PARCELA))+Padr('TX', Len(SE2->E2_TIPO))+cFornece))
	RecLock("SE2", .F.)
	SE2->E2_HIST    := "GNRE FECP UF DESTINO NF " + SF2->F2_DOC
	SE2->E2_NATUREZ := "60101"
	SE2->E2_DEBITO  := "320103015"
	SE2->E2_VENCTO  := DataValida(SE2->E2_EMISSAO+1)
	SE2->E2_VENCREA := DataValida(SE2->E2_EMISSAO+1)
	SE2->E2_VENCORI := DataValida(SE2->E2_EMISSAO+1)
	MsUnlock()
	EndIf
	Else  */
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	If SE2->(DbSeek(xFilial("SE2")+cNumero+Space(Len(SE2->E2_PARCELA))+Padr('TX', Len(SE2->E2_TIPO))+cFornece))
		RecLock("SE2", .F.)
		If lGuiaDifal
			SE2->E2_HIST        := "DIFAL DEST NF " + SF2->F2_DOC
			SE2->E2_DEBITO      := "320103014"
		Else
			If lGuiaFecp
				SE2->E2_HIST    := "FECP DEST NF " + SF2->F2_DOC
				SE2->E2_DEBITO  := "320103015"
			Else
				SE2->E2_HIST    := "GNRE ICMS-ST NF " + SF2->F2_DOC
				SE2->E2_DEBITO  := "210401020"
			EndIf
		EndIf

		SE2->E2_NATUREZ := "60101"
		SE2->E2_VENCTO  := DataValida(SE2->E2_EMISSAO+1)
		SE2->E2_VENCREA := DataValida(SE2->E2_EMISSAO+1)
		SE2->E2_VENCORI := DataValida(SE2->E2_EMISSAO+1)
		MsUnlock()
	EndIf
	//	EndIf

	//Integridade relacional
	SE2->(RestArea(aAreaSE2))
Return

Static Function ExecReproc(cDoc,cSerie,dDtEmissao)
	Local aParam  := array(11)
	Local lRotAut := .T.

	aParam[1]  := dToc(dDtEmissao) //Data Inicial
	aParam[2]  := dToc(dDtEmissao) //Data Final
	aParam[3]  := 2      //1-Entrada 2-Saída 3-Ambos
	aParam[4]  := cDoc   //Nota Fiscal Incial
	aParam[5]  := cDoc   //Nota Fiscal Final
	aParam[6]  := cSerie         //Série Incial
	aParam[7]  := cSerie      //Série Final
	aParam[8]  := ''         //Cli/For Inicial
	aParam[9]  := 'ZZZZZZ'   //Cli/For Final
	aParam[10] := ''         //Loja Incial
	aParam[11] := 'ZZ'       //Loja Final

	MATA930(lRotAut,aParam)

Return
