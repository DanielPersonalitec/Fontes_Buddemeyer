#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/* 
/============================================================================\
| Nome              : API gera DUN14 - Grade de Encaixotamento               |
|============================================================================|
| Descricao         : API para gerar DUN14 a partir do cadastro na grade de  |
|                     encaixotamento no portal.                              |
|============================================================================|
| Respons�vel       : Robson Jos� Pavanelli                                  |
|============================================================================|
| Autor             : Robson Jos� Pavanelli                                  |
|============================================================================|
| Data de Criacao   : 04/12/2023                                             |
\============================================================================/
*/

WSRESTFUL api_dun14 DESCRIPTION "Gerar DUN14 a partir do cadastro da quantidade na grade de encaixotamento"
WSMETHOD POST DESCRIPTION "Recebe vari�veis pelo post" WSSYNTAX "/api_dun14/ [ POST ]"
END WSRESTFUL

::SetContentType("application/json")

WSMETHOD POST WSSERVICE api_dun14

	Local lPost         := .T.
	Local lLogRet       := .F.
	Local lDun14Max8    := .F.
	Local cBody         := ::GetContent()
	Local oDun14
	Local oJson
	Local cGrade        := ""
	Local cReferencia   := ""
	Local cTamanho      := ""
	Local cCodProd      := ""
	Local cToken        := "xdSUZ,XP.svH_5BW92cEb8Cm6TQK.ALh,rq3tjuJY.7fMwVNp_gD4GzRe"
	Local cDescrLog     := ""
	Local cOperacao     := ""
	Local aDun14 		:= {}
	Local nQtd          := 0
	Local nX            := 1

	Private lVerificaPreco := .F.
	Private lVerificaGrade := .F.

	FWJsonDeserialize(cBody, @oDun14)

	cOperacao := oDun14:fwoperacao

	// Se for para gerar DUN14
	If Upper(cOperacao) == "GERAR"

		aDun14 := oDun14:fwarray

		// Para cada informacao passada
		For nX := 1 to Len(aDun14)

			// Recebe as variaveis
			cGrade      := aDun14[nX]:fwgrade
			cReferencia := aDun14[nX]:fwref
			cTamanho    := aDun14[nX]:fwtam
			nQtd    	:= aDun14[nX]:fwqtd
			cCodProd    := aDun14[nX]:fwcodprod

			oJson := JsonObject():New()

			// Posiciona no cabecalho da grade, para validar grade que gera DUN14:
			ZCM->(dbSetOrder(1))
			ZCM->(dbSeek(xFilial("ZCM")+cGrade))

			If Empty(cGrade)

				oJson['code'] := 2
				oJson['message'] := EncodeUtf8("Nao foi possivel identificar a grade do cliente!")
				ConOut("[API DUN14] - ERRO 002 - Nao foi possivel identificar a grade do cliente!")
				::SetResponse(oJson:toJson())
				Return .F.

			ElseIf Empty(cReferencia)

				oJson['code'] := 3
				oJson['message'] := EncodeUtf8("Nao foi possivel identificar a referencia do produto!")
				ConOut("[API DUN14] - ERRO 003 - Nao foi possivel identificar a referencia do produto!")
				::SetResponse(oJson:toJson())
				Return .F.

			ElseIf Empty(cTamanho)

				oJson['code'] := 4
				oJson['message'] := EncodeUtf8("Nao foi possivel identificar o codigo de tamanho do produto!")
				ConOut("[API DUN14] - ERRO 004 - Nao foi possivel identificar o codigo de tamanho do produto!")
				::SetResponse(oJson:toJson())
				Return .F.

			ElseIf ZCM->ZCM_DUN14 == '1' //Se a grade gera DUN14, chama a fun��o para gerar:

				ConOut("[API DUN14] - Gerando DUN14 da referencia/tamanho " +cReferencia+ "/"+cTamanho+", cadastrado na grade grade: " +cGrade+ " ("+Time()+")")

				// Verifico se o cliente � exporta��o
				If (Select("CEX1") <> 0)
					dbSelectArea("CEX1")
					dbCloseArea()
				EndIF

				BeginSql Alias 'CEX1'
					SELECT A1_CODENCX
						FROM %Table:SA1% (NOLOCK)
					WHERE A1_FILIAL = %xFilial:SA1%
						AND LEFT(A1_COD, 2) = 'EX'
						AND A1_CODENCX = %Exp:cGrade%
						AND %NotDel%
				EndSql

				// Valida se o produto est� cadastrado na tabela de pre�o DA1
				lVerificaPreco = VerificaPreco(cReferencia, cTamanho, cCodProd)
				
				// Se o produto estiver na tabela de pre�o ou o cliente for de exporta��o
				If lVerificaPreco .Or. !Empty(CEX1->A1_CODENCX)

					// Valida se a referencia/tamanho existe cadastrado na grade informada no parametro cGrade
					lVerificaGrade = VerificaGrade(cReferencia, cTamanho, cGrade)
					
					If lVerificaGrade

						lDun14Max8 := GeraDun14(cReferencia, cTamanho, cGrade, cCodProd, nQtd)

						//Se passar a quantidade de 8 varia��oes do codigo DUN14 para o mesmo produto:
						If lDun14Max8

							cDescrLog := "Nao foi possivel gerar DUN14 para referencia "+cReferencia+" com tamanho "+cTamanho+", pois ja existe 8 variacoes do codigo de barras para o produto!"
							lLogRet := LogGradeEnc("t="+cToken+"&descricao="+cDescrLog+"&acao=atualizar&id="+cGrade+"_"+cReferencia+"_"+cTamanho)

							oJson['code'] := 8
							oJson['message'] := EncodeUtf8("Nao e possivel gerar DUN14 para ref�rencia " +cReferencia+ "/"+cTamanho+", consulta o log para mais detalhes!")
							ConOut("[API DUN14] - ERRO 008 - Nao e possivel gerar DUN14 para referencia " +cReferencia+ "/"+cTamanho+" ("+Time()+")")

						Else
							
							cDescrLog := "Gerado DUN14 do produto "+cReferencia+" com tamanho "+cTamanho+"!"
							lLogRet := LogGradeEnc("t="+cToken+"&descricao="+cDescrLog+"&acao=atualizar&id="+cGrade+"_"+cReferencia+"_"+cTamanho)

							oJson['code'] := 200
							oJson['message'] := EncodeUtf8("Item atualizado com sucesso! Aguarde o redirecionamento...!")
							ConOut("[API DUN14] - SUCESSO - Item atualizado com sucesso! Aguarde o redirecionamento... ("+Time()+")")

							// Integracao WMS - Grade de Encaixotamento
							U_BUD1519()

						EndIf

					Else

						cDescrLog := "Nao foi possivel gerar DUN14 para referencia "+cReferencia+" com tamanho "+cTamanho+", pois o mesmo nao esta cadastrado na grade "+cGrade+". Verifique!"
						lLogRet := LogGradeEnc("t="+cToken+"&descricao="+cDescrLog+"&acao=atualizar&id="+cGrade+"_"+cReferencia+"_"+cTamanho)

						oJson['code'] := 7
						oJson['message'] := EncodeUtf8("Nao e possivel gerar DUN14 para ref�rencia " +cReferencia+ "/"+cTamanho+", consulta o log para mais detalhes!")
						ConOut("[API DUN14] - ERRO 007 - Nao e possivel gerar DUN14 para referencia " +cReferencia+ "/"+cTamanho+" ("+Time()+")")

					EndIf

				Else

					cDescrLog := "Nao foi possivel gerar DUN14 para referencia "+cReferencia+" com tamanho "+cTamanho+", pois nao tem tabela de preco cadastrada para esse produto. Verifique com o setor comercial!"
					lLogRet := LogGradeEnc("t="+cToken+"&descricao="+cDescrLog+"&acao=atualizar&id="+cGrade+"_"+cReferencia+"_"+cTamanho)

					oJson['code'] := 6
					oJson['message'] := EncodeUtf8("Nao e possivel gerar DUN14 para ref�rencia " +cReferencia+ "/"+cTamanho+", consulta o log para mais detalhes!")
					ConOut("[API DUN14] - ERRO 006 - Nao e possivel gerar DUN14 para referencia " +cReferencia+ "/"+cTamanho+" ("+Time()+")")

				EndIf

				// Envia JSON como resposta
				::SetResponse(oJson:toJson())

			Else

				oJson['code'] := 5
				oJson['message'] := EncodeUtf8("A grade "+cGrade+" Nao est� habilitada para gerar DUN14!")
				ConOut("[API DUN14] - ERRO 005 - A grade "+cGrade+" Nao est� habilitada para gerar DUN14!")
				::SetResponse(oJson:toJson())
				Return .F.

			EndIf

		Next

	ElseIf Upper(cOperacao) == "AJUSTAR"

		// Recebe as variaveis
		cReferencia := oDun14:fwref
		cTamanho := oDun14:fwtam
		cGrade := oDun14:fwgrade

		oJson := JsonObject():New()

		If Empty(cGrade)

			oJson['code'] := 9
			oJson['message'] := EncodeUtf8("Nao foi possivel identificar a grade do produto!")
			ConOut("[API DUN14] - ERRO 009 - Nao foi possivel identificar a grade do produto!")
			::SetResponse(oJson:toJson())
			Return .F.

		Else

			lDun14Max8 := AjustarDun14(cGrade, cReferencia, cTamanho)

			//Se passar a quantidade de 8 varia��oes do codigo DUN14 para o mesmo produto:
			If lDun14Max8

				oJson['code'] := 10
				oJson['message'] := EncodeUtf8("Nao foram encontrados DUN14s duplicados para ajustar!")
				ConOut("[API DUN14] - ERRO 010 - Nao foram encontrados DUN14s duplicados para ajustar ("+Time()+")")

			Else
				
				cDescrLog := "Foram ajustados os DUN14s duplicados da grade "+cGrade+"!"
				lLogRet := LogGradeEnc("t="+cToken+"&descricao="+cDescrLog+"&acao=atualizar&id="+cGrade+"_"+cReferencia+"_"+cTamanho)

				oJson['code'] := 200
				oJson['message'] := EncodeUtf8("Foram ajustados os DUN14s duplicados com sucesso!")
				ConOut("[API DUN14] - SUCESSO - Foram ajustados os DUN14s duplicados com sucesso ("+Time()+")")

				// Integracao WMS - Grade de Encaixotamento
				U_BUD1519()

			EndIf

			// Envia JSON como resposta
			::SetResponse(oJson:toJson())

		EndIf

	Else

		oJson['code'] := 1
		oJson['message'] := EncodeUtf8("Nao foi possivel identificar a operacao!")
		ConOut("[API DUN14] - ERRO 001 - Nao foi possivel identificar a operacao!")
		::SetResponse(oJson:toJson())
		Return .F.

	EndIf

Return lPost

/*
/============================================================================\
|Nome              : Gera DUN14 na SLK (GeraDun14)                           |
|============================================================================|
|Descricao         : Essa function gera e salva o codigo DUN14 na tabela SLK |
|                    Fun��o baseada no processo antigo da rotina BUD1317.    |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 04/12/2023                                              |
\============================================================================/
*/

Static Function GeraDun14(_ref, _tam, _grade, _produto, _qtd)

	Local lDun14Max8 := .F.
	Local nOldDUN14 := ""
	Local cFiltro := ""
	Local cSeq := ""
	Local nEAN13 := 0
	Local nDUN14 := 0

	// Se for passado o codigo do produto
	If !Empty(_produto)
		cQuery	:= "SELECT DISTINCT B1_COD AS COD,rtrim(B1_CODBAR) AS EAN13, ZCN_QTDE AS QTD "
		cQuery	+= "FROM "+RetSqlName("SB1")+ " B1 , "+RetSqlName("ZCN")+" ZCN, "+RetSqlName("ZCM")+" ZCM "
		cQuery	+= "WHERE B1.D_E_L_E_T_ = '' AND B1_FILIAL= ' ' "
		cQuery	+= "AND ZCN.D_E_L_E_T_ = '' AND ZCN_FILIAL= ' ' "
		cQuery	+= "AND ZCM.D_E_L_E_T_ = '' AND ZCM_FILIAL= ' ' "
		cQuery	+= "AND B1_COD = '"+_produto+"' "
		cQuery	+= "AND B1_CODBAR != '' "
		cQuery	+= "AND B1_MSBLQL<>'1' "
		cQuery	+= "AND ZCM_CODIGO = '"+_grade+"' "
		cQuery	+= "AND ZCM_DUN14 = '1' "
		cQuery	+= "AND ZCN_CODIGO = ZCM_CODIGO "
		cQuery	+= "AND ZCN_QTDE >= 1 "
		cQuery	+= "AND ZCN_REF = LEFT(B1_COD,8) "
		cQuery	+= "AND ZCN_TAM = SUBSTRING(B1_COD,15,4) "
		cQuery	+= "ORDER BY QTD "
	
	// Se nao for passado o codigo do produto
	Else
		// Busca a linha e tamanho nas grades
		If (Select("BFILT") <> 0)
			dbSelectArea("BFILT")
			dbCloseArea()
		EndIf

		BeginSql alias 'BFILT'
			SELECT ZCN_CODIGO
				FROM %Table:ZCN% (NOLOCK)
			WHERE ZCN_FILIAL = %xFilial:ZCN%
				AND ZCN_CODIGO = %Exp:_grade%
				AND ZCN_REF = %Exp:_ref%
				AND ZCN_TAM = %Exp:_tam%
				AND ZCN_QTDE = %Exp:_qtd%
				AND %notDel%
		EndSql

		// Se encontrar a linha e tamanho nas grades e a quantidade nao estiver sendo alterada
		If !BFILT->(Eof())
			cFiltro := "AND LK.LK_CODBAR IS NULL "
		
		Else
			cFiltro := ""
		EndIf

		// Verifica se o cliente e exportacao
		If (Select("CEX2")<>0)
			dbSelectArea("CEX2")
			dbCloseArea()
		EndIF

		BeginSql Alias 'CEX2'
			SELECT A1_CODENCX
				FROM %Table:SA1% (NOLOCK)
			WHERE A1_FILIAL = %xFilial:SA1%
				AND LEFT(A1_COD, 2) = 'EX'
				AND A1_CODENCX = %Exp:_grade%
				AND %NotDel%
		EndSql

		// Se o cliente for exportacao
		IF !Empty(CEX2->A1_CODENCX)
			cQuery	:= "SELECT DISTINCT B1_COD AS COD,rtrim(B1_CODBAR) AS EAN13, ZCN_QTDE AS QTD, ISNULL(LK.LK_CODBAR, '') AS DUN14 "
			cQuery	+= "FROM "+RetSqlName("ZCN")+" ZCN "
			cQuery	+= "INNER JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ = '' AND B1.B1_FILIAL = '' AND LEFT(B1_COD,8) = ZCN_REF AND SUBSTRING(B1_COD,15,4) = ZCN_TAM AND B1_MSBLQL <> '1' AND B1_CODBAR != '' "
			cQuery	+= "INNER JOIN "+RetSqlName("ZCM")+" ZCM ON ZCM.D_E_L_E_T_ = '' AND ZCM.ZCM_FILIAL = '' AND ZCM_CODIGO = ZCN_CODIGO AND ZCM_DUN14 = '1' "
			cQuery	+= "LEFT JOIN "+RetSqlName("SLK")+" LK ON LK.D_E_L_E_T_ = '' AND LK.LK_FILIAL = '01' AND LK.LK_CODIGO = B1.B1_COD AND LK.LK_QUANT = ZCN.ZCN_QTDE "
			cQuery	+= "WHERE ZCN.D_E_L_E_T_ = '' "
			cQuery	+= "AND ZCN_FILIAL= ' ' "
			cQuery	+= "AND ZCN_STATUS = 'FINALIZADO' "
			cQuery	+= "AND ZCN_REF = '"+_ref+"' "
			cQuery	+= "AND ZCN_TAM = '"+_tam+"' "
			cQuery	+= "AND ZCN_CODIGO = '"+_grade+"' "
			cQuery	+= cFiltro
			cQuery	+= "ORDER BY QTD "
		
		// Se o cliente nao for exportacao
		Else
			cQuery	:= "SELECT DISTINCT B1_COD AS COD, RTRIM(B1_CODBAR) AS EAN13, ZCN_QTDE AS QTD, ISNULL(LK.LK_CODBAR, '') AS DUN14 "
			cQuery	+= "FROM "+RetSqlName("ZCN")+" ZCN "
			cQuery	+= "INNER JOIN "+RetSqlName("SB1")+" B1 ON B1.D_E_L_E_T_ = '' AND B1.B1_FILIAL = '' AND B1.B1_MSBLQL <> '1' AND B1.B1_CODBAR != '' AND LEFT(B1.B1_COD, 8) = ZCN.ZCN_REF AND SUBSTRING(B1.B1_COD, 15, 4) = ZCN.ZCN_TAM "
			cQuery	+= "INNER JOIN "+RetSqlName("DA1")+" DA1 ON DA1.D_E_L_E_T_ = '' AND DA1.DA1_FILIAL = '' AND DA1.DA1_CODPRO = B1.B1_COD "
			cQuery	+= "INNER JOIN "+RetSqlName("ZCM")+" ZCM ON ZCM.D_E_L_E_T_ = '' AND ZCM.ZCM_FILIAL = '' AND ZCM.ZCM_DUN14 = '1' AND ZCM.ZCM_CODIGO = ZCN.ZCN_CODIGO "
			cQuery	+= "LEFT JOIN "+RetSqlName("SLK")+" LK ON LK.D_E_L_E_T_ = '' AND LK.LK_FILIAL = '01' AND LK.LK_CODIGO = B1.B1_COD AND LK.LK_QUANT = ZCN.ZCN_QTDE AND LK.LK_TPBAR <> '1'"
			cQuery	+= "WHERE ZCN.D_E_L_E_T_ = '' "
			cQuery	+= "AND ZCN.ZCN_FILIAL = '' "
			cQuery	+= "AND ZCN.ZCN_REF = '"+_ref+"' " 
			cQuery	+= "AND ZCN.ZCN_TAM = '"+_tam+"' " 
			cQuery	+= "AND ZCN.ZCN_CODIGO = '"+_grade+"' "
			cQuery	+= cFiltro
			cQuery	+= "ORDER BY QTD "
		EndIf
	EndIf

	// Busca todas as cores de acordo com a linha, tamanho e grade passado
	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	End

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TRB"

	ProcRegua(RecCount())

	// Para cada cor da linha + tamanho na grade passada
	While !TRB->(Eof())
		IncProc("Processando Produto: " + TRB->COD )
		
		// Busca o DUN14 do produto iterado que possua a mesma quantidade
		nOldDUN14 := ValidaExistentes(TRB->COD, AllTrim(Str(_qtd)))

		// Se encontrar
		If !Empty(nOldDUN14)
		
			// Busca tabela ZCN
			DbSelectArea("ZCN")
			ZCN->(DbSetOrder(2))
			DbGoTop()

			// Busca a linha + tamanho em questao na grade
			If DbSeek(xFilial("ZCN") + _grade + _ref + _tam)

				// Atualiza a tabela ZCN
				(RecLock("ZCN", .F.))
				ZCN->ZCN_QTDE := _qtd
				ZCN->(MsUnlock())
			
			EndIf

		// Se nao encontrar
		Else
			/*// Busca o DUN14 do produto iterado que nao esteja em nenhuma grade
			nOldDUN14 := ValidaExistentes(TRB->COD, "")

			// Se encontrar
			If !Empty(nOldDUN14)

				// Busca tabela SLK
				DbSelectArea("SLK")
				SLK->(DbSetOrder(2))
				DbGotop()

				// Busca o produto que tenha o DUN14 que nao esteja sendo usado
				If DbSeek(xFilial("SLK") + TRB->COD + nOldDUN14)

					// Atualiza a tabela SLK
					(RecLock("SLK", .F.))
					SLK->LK_QUANT := _qtd
					SLK->(MsUnlock())

					// Busca tabela ZCN
					DbSelectArea("ZCN")
					ZCN->(DbSetOrder(2))
					DbGoTop()

					// Busca a linha + tamanho em questao na grade
					If DbSeek(xFilial("ZCN") + _grade + _ref + _tam)

						// Atualiza a tabela ZCN
						(RecLock("ZCN", .F.))
						ZCN->ZCN_QTDE := _qtd
						ZCN->(MsUnlock())
					
					EndIf

				EndIf
			
			// Se nao encontrar
			Else*/
				// Verifica se existe alguma sequencia de DUN14 disponivel
				cSeq := BuscarSeq(TRB->COD)

				// Se a quantidade de codigo DUN14 exceder mais que 8 varia��o para o mesmo produto, Nao deixa gerar DUN14 novo:
				If cSeq == "9"

					dbSelectArea("TRB")
					TRB->(dbSkip())

					lDun14Max8 := .T.

				Else
					// Gera o EAN13 e o DUN14
					nEAN13 := (cSeq + SubStr(TRB->EAN13, 1, 12))
					nDUN14 := GeraDig(nEAN13)
					
					// Busca tabela SLK
					DbSelectArea("SLK")
					SLK->(DbSetOrder(2))
					DbGotop()

					// Busca o produto em questao
					If !DbSeek(xFilial("SLK") + TRB->COD + nDUN14)

						// Busca o produto com a quantidade passada na tabela SLK
						If (Select("TRE") <> 0)
							dbSelectArea("TRE")
							dbCloseArea()
						EndIf
						
						BeginSql Alias 'TRE'
							SELECT MAX(LK_CODBAR) AS DUN14
								FROM %Table:SLK% LK (NOLOCK)
							WHERE LK_FILIAL = %xFilial:SLK%
								AND LK_CODIGO = %Exp:TRB->COD%
								AND LK_QUANT = %Exp:_qtd%
								AND LK_TPBAR = '2'
								AND LK.%NotDel%
						EndSql

						// Se nao existir o produto em questao com a quantidade passada na tabela SLK
						If Empty(TRE->DUN14)
						
							// Insere na tabela SLK
							RecLock("SLK", .T.)
							SLK->LK_FILIAL:= xFilial("SLK")
							SLK->LK_CODIGO:= TRB->COD
							SLK->LK_CODBAR:= ALLTRIM(nDUN14)
							SLK->LK_QUANT:= _qtd
							SLK->LK_IMPDUN := 'N'
							SLK->LK_TPBAR := '2'
							MsUnLock("SLK")

							// Busca tabela ZCN
							DbSelectArea("ZCN")
							ZCN->(DbSetOrder(2))
							DbGoTop()

							// Busca a linha + tamanho em questao na grade
							If DbSeek(xFilial("ZCN") + _grade + _ref + _tam)

								// Atualiza a tabela ZCN
								(RecLock("ZCN", .F.))
								ZCN->ZCN_QTDE := _qtd
								ZCN->(MsUnlock())
							
							EndIf

						// Se existir o produto em questao com a quantidade passada na tabela SLK
						Else
							// Busca tabela ZCN
							DbSelectArea("ZCN")
							ZCN->(DbSetOrder(2))
							DbGoTop()

							// Busca a linha + tamanho em questao na grade
							If DbSeek(xFilial("ZCN") + _grade + _ref + _tam)

								// Atualiza a tabela ZCN
								(RecLock("ZCN", .F.))
								ZCN->ZCN_QTDE := _qtd
								ZCN->(MsUnlock())
							
							EndIf

						EndIf

					EndIf

				EndIf

			//EndIf

		EndIf

		dbSelectarea("TRB")
		TRB->(dbSkip())

	EndDo

Return lDun14Max8

/*
/============================================================================\
|Nome              : Funcao AjustarDun14()                             		 |
|============================================================================|
|Descricao         : Essa funcao busca os produtos que tem mais do que 1     |
|                    DUN14 e ajusta-os.               						 |
|============================================================================|
|Autor             : Joao Gebauer                            		         |
|============================================================================|
|Data de Criacao   : 29/04/2025                                              |
\============================================================================/
*/

Static Function AjustarDun14(_grade, _ref, _tam)

	Local cFiltroRef := "%1 = 1%"
	Local cFiltroTam := "%1 = 1%"
	Local cCodigo := ""
	Local lRetorno := .F.

	If !Empty(_ref)
		cFiltroRef := "%ZCN.ZCN_REF = '"+_ref+"'%"
	EndIf

	If !Empty(_tam)
		cFiltroTam := "%ZCN.ZCN_TAM = '"+_tam+"'%"
	EndIf

	// Busca os cadastros duplicados
	If (Select("BCADD") <> 0)
		dbSelectArea("BCADD")
		dbCloseArea()
	EndIf

	BeginSql alias 'BCADD'
		SELECT B1_COD, EAN13, ZCN_QTDE, ZCN_CODIGO
			FROM (
				SELECT DISTINCT SB1.B1_COD, RTRIM(SB1.B1_CODBAR) AS EAN13, ZCN.ZCN_QTDE, ISNULL(SLK.LK_CODBAR, '') AS DUN14, ZCN.ZCN_CODIGO
					FROM %Table:ZCN% (NOLOCK) AS ZCN 
				INNER JOIN %Table:SB1% (NOLOCK) AS SB1 
					ON SB1.B1_FILIAL = %xFilial:SB1%
					AND SB1.B1_MSBLQL <> '1' 
					AND SB1.B1_CODBAR <> '' 
					AND LEFT(SB1.B1_COD, 8) = ZCN.ZCN_REF 
					AND SUBSTRING(SB1.B1_COD, 15, 4) = ZCN.ZCN_TAM 
					AND SB1.%notDel%
				INNER JOIN %Table:DA1% (NOLOCK) AS DA1 
					ON DA1.DA1_FILIAL = %xFilial:DA1%
					AND DA1.DA1_CODPRO = SB1.B1_COD 
					AND DA1.%notDel%
				INNER JOIN %Table:ZCM% (NOLOCK) AS ZCM 
					ON ZCM.ZCM_FILIAL = %xFilial:ZCM%
					AND ZCM.ZCM_DUN14 = '1' 
					AND ZCM.ZCM_CODIGO = ZCN.ZCN_CODIGO 
					AND ZCM.%notDel%
				LEFT JOIN %Table:SLK% (NOLOCK) AS SLK 
					ON SLK.LK_FILIAL = %xFilial:SLK%
					AND SLK.LK_CODIGO = SB1.B1_COD 
					AND SLK.LK_QUANT = ZCN.ZCN_QTDE 
					AND SLK.LK_TPBAR <> '1'
					AND SLK.%notDel%
				WHERE ZCN.ZCN_FILIAL = %xFilial:ZCN%
					AND ZCN.ZCN_CODIGO = %Exp:_grade%
					AND %Exp:cFiltroRef%
					AND %Exp:cFiltroTam%
					AND ZCN.%notDel%
			) AS SUB
		GROUP BY B1_COD, EAN13, ZCN_QTDE, ZCN_CODIGO
			HAVING COUNT(*) > 1
		ORDER BY B1_COD
	EndSql

	// Para cada cadastro
	While !BCADD->(Eof())
	
		// Recebe o codigo do produto
		cCodigo := BCADD->B1_COD

		// Busca o DUN14 duplicado mais novo
		If (Select("BDUND") <> 0)
			dbSelectArea("BDUND")
			dbCloseArea()
		EndIf

		BeginSql alias 'BDUND'
			SELECT TOP 1 SLK.R_E_C_N_O_ AS RECNO
				FROM %Table:ZCN% (NOLOCK) AS ZCN 
			INNER JOIN %Table:SB1% (NOLOCK) AS SB1 
				ON SB1.B1_FILIAL = %xFilial:SB1%
				AND SB1.B1_MSBLQL <> '1' 
				AND SB1.B1_CODBAR <> '' 
				AND LEFT(SB1.B1_COD, 8) = ZCN.ZCN_REF 
				AND SUBSTRING(SB1.B1_COD, 15, 4) = ZCN.ZCN_TAM 
				AND SB1.%notDel%
			INNER JOIN %Table:DA1% (NOLOCK) AS DA1 
				ON DA1.DA1_FILIAL = %xFilial:DA1%
				AND DA1.DA1_CODPRO = SB1.B1_COD 
				AND DA1.%notDel%
			INNER JOIN %Table:ZCM% (NOLOCK) AS ZCM 
				ON ZCM.ZCM_FILIAL = %xFilial:ZCM%
				AND ZCM.ZCM_DUN14 = '1' 
				AND ZCM.ZCM_CODIGO = ZCN.ZCN_CODIGO 
				AND ZCM.%notDel%
			LEFT JOIN %Table:SLK% (NOLOCK) AS SLK 
				ON SLK.LK_FILIAL = %xFilial:SLK%
				AND SLK.LK_CODIGO = SB1.B1_COD 
				AND SLK.LK_QUANT = ZCN.ZCN_QTDE 
				AND SLK.LK_TPBAR <> '1'
				AND SLK.%notDel%
			WHERE ZCN.ZCN_FILIAL = %xFilial:ZCN%
				AND SLK.LK_CODIGO = %Exp:cCodigo%
				AND ZCN.ZCN_CODIGO = %Exp:_grade%
				AND ZCN.%notDel%
            ORDER BY SLK.R_E_C_N_O_ DESC
		EndSql

		// Para cada um
		If !BDUND->(Eof())
		
			lRetorno := .T.

			// Busca o registro duplicado na SLK
			DbSelectArea("SLK")
			DbGoTo(BDUND->RECNO)

			// Remove o registro duplicado da SLK
			SLK->(RecLock("SLK", .F.))
			SLK->(DbDelete())
			SLK->(MsUnlock())

		EndIf

		BCADD->(dbSkip())

	EndDo

Return lRetorno

/*
/============================================================================\
|Nome              : Criar numera��o DUN14 (GeraDig)                         |
|============================================================================|
|Descricao         : Essa function calcula numera��o do DUN14, com base ao   |
|                    EAN13 do produto.                                       |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 04/12/2023                                              |
\============================================================================/
*/

Static Function GeraDig(cCodBar)

	//cCodBar:='2789166172992'
	//C�lculo do d�gito verficador
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


	cBarDun14 := Alltrim(cCodBar) + ALLTRIM(STR(nDig))

Return (cBarDun14)

/*
/============================================================================\
|Nome              : Log grade de encaixotamento (LogGradeEnc)               |
|============================================================================|
|Descricao         : Essa function grava log de solicita��o da grade de      |
|                    encaixotamento.                                         |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 04/12/2023                                              |
\============================================================================/
*/

Static Function LogGradeEnc(cParamPost)
	Local cUrl := "https://tars.buddemeyer.com.br/grades_encaixotamento/ws_salvar_log.php"
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local sPostRet := ""
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
	sPostRet := HttpPost(cUrl,"", cParamPost,nTimeOut,aHeadOut,@cHeadRet)
	if !empty(sPostRet)
		ConOut("[API DUN14] - Feito grava��o do log!")
        lLogRet := .T.
	else
        lLogRet := .F.
        lPost := .F.
	Endif
Return(lLogRet)

/*
/============================================================================\
|Nome              : Funcao VerificaPreco()                                    |
|============================================================================|
|Descricao         : Essa funcao verifica se o produto tem tabela de pre�o   |
|                    cadastrado na DA1.                                      |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 27/06/2024                                              |
\============================================================================/
*/

Static Function VerificaPreco(_referencia, _tamanho, _produto)
	Local lVerificaPreco := .F.
	Local _filtro := ""

	If !EMPTY(_produto)
		_filtro := "%AND DA1_CODPRO = '"+_produto+"'%"
	else
		_filtro := "%AND LEFT(DA1_CODPRO,8) = '"+_referencia+"' AND SUBSTRING(DA1_CODPRO,15,4) = '"+_tamanho+"'%"
	EndIf

	If (Select("DA1") <> 0)
		dbSelectArea("DA1")
		dbCloseArea()
	EndIf

	BeginSql alias 'DA1'
        SELECT DA1_CODTAB
            FROM %table:DA1% (NOLOCK) DA1
        WHERE DA1.%notDel%
            AND DA1_FILIAL  = %xFilial:DA1%
            %Exp:_filtro%
	EndSql

	If !DA1->(Eof()) .Or. !Empty(DA1->DA1_CODTAB)
		lVerificaPreco := .T.
	EndIf
Return lVerificaPreco

/*
/============================================================================\
|Nome              : Funcao VerificaGrade()                                  |
|============================================================================|
|Descricao         : Essa funcao verifica se o produto esta na grade que �   |
|                    passada por parametro.                                  |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 03/07/2024                                              |
\============================================================================/
*/

Static Function VerificaGrade(_referencia, _tamanho, _grade)
	Local lVerificaGrade := .F.

	If (Select("VGZCN") <> 0)
		dbSelectArea("VGZCN")
		dbCloseArea()
	EndIf

	BeginSql alias 'VGZCN'
        SELECT ZCN_CODIGO
            FROM %table:ZCN% (NOLOCK) ZCN
        WHERE ZCN.%notDel%
            AND ZCN_FILIAL = %xFilial:ZCN%
            AND ZCN_CODIGO = %Exp:_grade%
			AND ZCN_REF = %Exp:_referencia%
			AND ZCN_TAM = %Exp:_tamanho%
	EndSql

	If !VGZCN->(Eof()) .Or. !Empty(VGZCN->ZCN_CODIGO)
		lVerificaGrade := .T.
	EndIf
Return lVerificaGrade

/*
/============================================================================\
|Nome              : Funcao ValidaExistentes()                               |
|============================================================================|
|Descricao         : Essa funcao verifica se para os DUN14s do produto,      |
|                    existe algum que nao esteja sendo usado.                |
|============================================================================|
|Autor             : Joao Gebauer                            		         |
|============================================================================|
|Data de Criacao   : 29/04/2025                                              |
\============================================================================/
*/

Static Function ValidaExistentes(_produto, _quant)

	Local cRetorno := ""
	Local cFiltro := "%ZCN.ZCN_CODIGO IS NULL%"

	If !Empty(_quant)
		cFiltro := "%SLK.LK_QUANT = '"+_quant+"'%"
	EndIf

	If (Select("VLDEX") <> 0)
		dbSelectArea("VLDEX")
		dbCloseArea()
	EndIf

	BeginSql alias 'VLDEX'
		SELECT DISTINCT SLK.LK_CODBAR
			FROM %Table:SLK% (NOLOCK) SLK
		LEFT JOIN %Table:ZCN% (NOLOCK) ZCN
			ON ZCN.ZCN_FILIAL = %xFilial:ZCN%
			AND ZCN.ZCN_REF = LEFT(SLK.LK_CODIGO, 8)
			AND ZCN.ZCN_TAM = SUBSTRING(SLK.LK_CODIGO, 15,4)
			AND ZCN.ZCN_QTDE = SLK.LK_QUANT
			AND ZCN.%notDel%
		WHERE SLK.LK_FILIAL = %xFilial:SLK%
			AND SLK.LK_TPBAR = '2'
			AND SLK.LK_CODIGO = %Exp:_produto%
			AND %Exp:cFiltro%
			AND SLK.%notDel%
	EndSql

	If !VLDEX->(Eof())
		cRetorno := VLDEX->LK_CODBAR
	EndIf

Return cRetorno

/*
/============================================================================\
|Nome              : Funcao BuscarSeq()                                    |
|============================================================================|
|Descricao         : Essa funcao verifica se existe uma sequencia de 1 ao 8  |
|                    que nao esteja sendo usada.    			             |
|============================================================================|
|Autor             : Joao Gebauer		                                     |
|============================================================================|
|Data de Criacao   : 10/12/2024                                              |
\============================================================================/
*/

Static Function BuscarSeq(_cod)
	Local cRetorno := "9"
	Local nX := 1

	// Verifica se existem DUN14 sobrando
	For nX := 1 To 8
		If (Select("BUSSEQ") <> 0)
			dbSelectArea("BUSSEQ")
			dbCloseArea()
		EndIf

		BeginSql alias 'BUSSEQ'
			SELECT LK_CODBAR
				FROM %Table:SLK% (NOLOCK)
			WHERE LK_FILIAL = %xFilial:SLK%
				AND LK_CODIGO = %Exp:_cod%
				AND LK_TPBAR = '2' 
				AND LEFT(LK_CODBAR, 1) = %Exp:nX%
				AND %notDel%
		EndSql

		// Se nao encontrar inicial do DUN14 com o nX atual
		If BUSSEQ->(Eof())
			cRetorno := cValToChar(nX)
			Exit
		EndIf
	Next nX
Return cRetorno
