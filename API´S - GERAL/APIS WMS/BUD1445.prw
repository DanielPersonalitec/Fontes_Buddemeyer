#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Protheus.ch'
#Include 'parmtype.ch'

/*
/=========================================================================\
| Modulo      : ApiRest                                                   |
|=========================================================================|
| Programa    : BUD1445.PRW   | Resposavel: Robson		        		  |
|=========================================================================|
| Descricao   : Transferencia entre estoques			 		          |
|=========================================================================|
| Data        : 08/01/2023 						                          |
|=========================================================================|
| Programador : Cesar Grossl, Joao Gebauer          	                  |
\=========================================================================/
*/

WSRESTFUL api_transferencia DESCRIPTION "Transferencia entre estoques"

	WSDATA cNumGuia AS STRING

	WSMETHOD GET GetEstoque DESCRIPTION "Retorna dados da Guia" PATH "/api_transferencia/{cNumGuia}/{cLocalOrigem}";
		TTALK "v1";
		WSSYNTAX "/api_transferencia/{cNumGuia}/{cLocalOrigem}"

	WSMETHOD POST DESCRIPTION "Transferencia entre estoques" PATH "/api_transferencia";
		TTALK "v2";
		WSSYNTAX "/api_transferencia/"

	// Novos endpoints - PDA (origem BUD1520)
	WSMETHOD GET Listar DESCRIPTION "Lista produtos disponiveis para transferencia em um local" PATH "/api_transferencia/listar/{cLocal}";
		TTALK "v1";
		WSSYNTAX "/api_transferencia/listar/{cLocal}"

	WSMETHOD PUT Atualizar DESCRIPTION "Transferencia de estoque por produto" PATH "/api_transferencia/atualizar";
		TTALK "v1";
		WSSYNTAX "/api_transferencia/atualizar"

	WSMETHOD POST Cadastrar DESCRIPTION "Cadastra entrada de transferencia no SD3" PATH "/api_transferencia/cadastrar";
		TTALK "v1";
		WSSYNTAX "/api_transferencia/cadastrar"

	WSMETHOD DELETE Deletar DESCRIPTION "Estorna movimento de transferencia" PATH "/api_transferencia/deletar";
		TTALK "v1";
		WSSYNTAX "/api_transferencia/deletar"

END WSRESTFUL

::SetContentType("application/json")
::SetHeader('Access-Control-Allow-Credentials' , "true")

WSMETHOD GET GetEstoque WSRECEIVE cNumGuia WSSERVICE api_transferencia

	Local cLocalDest := ""

	Private oRetorno := JsonObject():New()
	Private jJsonItem := JSonObject():New()

	oRetorno["retorno"] := {}

  	// Valida parametros em branco
  	If Empty(SELF:AURLPARMS[1])
    	jJsonItem['code'] := 1
    	jJsonItem['message'] := "Nao foram informadas a(s) guia(s)!"
		ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	ElseIf Empty(SELF:AURLPARMS[2])
    	jJsonItem['code'] := 2
    	jJsonItem['message'] := "Nao foi informado o local de origem!"
		ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

  	Else
		/*==============================================\
		|            Busca os dados da guia             |
		\==============================================*/

		// Se o local de origem for P1
		If SELF:AURLPARMS[2] == "P1"
			cLocalDest := "P2"
		
		// Se o local de origem for P2
		Else
			cLocalDest := "P1"
		EndIf
		
		B1445Dados(SELF:AURLPARMS[1], SELF:AURLPARMS[2], cLocalDest)
		ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)
  	EndIf

	// Adiciona resposta da API
	Self:SetContentType('application/json')
    Self:SetResponse(EncodeUtf8(oRetorno:toJson()))
	
Return .T.

WSMETHOD POST WSSERVICE api_transferencia

	Local cBody := ""
	Local oTransf := JsonObject():new()
	Local aTransf := {}
	Local lPost := .F.
	Local cDoc := ""
	Local cProd := ""
	Local cObserva := ""
	Local cDesc := ""
	Local cUnid := ""
	Local cLocalOrig := ""
	Local cLocalDest := ""
	Local cNumReg := "0000000000"
	Local nOperacao := 0
	Local nX := 0
	Local nQtd := 0
	Local aBody := {}
	Local aLinha := {}
	Local cGuiaAntiga := ""

  	Private cGuia := ""
	Private cUsuario := ""

	Private cFuncaoPai := "BUD1445"
	Private PrivalMsHelpAuto := .T.
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

   	Public oRetorno := JsonObject():New() as Object
	Public jJsonItem := JsonObject():New() as Json

	oRetorno["retorno"] := {}

	cBody := oRest:getBodyRequest()

	oTransf:fromJson(DecodeUTF8(cBody))

	// Valida campos informados
	If !oTransf:HasProperty("fwtransf")
		jJsonItem['message'] := "O campo (fwtransf) nao foi informado!"
		jJsonItem['code'] := 3
		ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	Else
		// Recebe as informacoes de transferencia
		aTransf := oTransf["fwtransf"]

		// Valida parametros em branco
		If Len(aTransf) == 0
			jJsonItem['code'] := 4
			jJsonItem['message'] := "Nao foram informadas a(s) transferencia(s)!"
			ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			aAdd(oRetorno["retorno"], jJsonItem)

		Else
			// Para cada transferencia recebida
			For nX := 1 to Len(aTransf)
				lPost := .F.
            	jJsonItem := JsonObject():New()

				// Valida campos informados
				If !aTransf[nX]:HasProperty("fwusuario")
					jJsonItem['message'] := "O campo (fwusuario) nao foi informado!"
					jJsonItem['code'] := 5

				ElseIf !aTransf[nX]:HasProperty("fwqtd")
					jJsonItem['message'] := "O campo (fwqtd) nao foi informado!"
					jJsonItem['code'] := 6

				ElseIf !aTransf[nX]:HasProperty("fwlocalorig")
					jJsonItem['message'] := "O campo (fwlocalorig) nao foi informado!"
					jJsonItem['code'] := 7

				Else
					cUsuario := aTransf[nX]["fwusuario"]
					nQtd := aTransf[nX]["fwqtd"]
					cLocalOrig := aTransf[nX]["fwlocalorig"]
					
					// Valida parametros em branco
					If Empty(cUsuario)
						jJsonItem['code'] := 8
						jJsonItem['message'] := "Nao foi informado o usuario!"

					ElseIf Empty(nQtd)
						jJsonItem['code'] := 9
						jJsonItem['message'] := "Nao foi informado a quantidade!"

					ElseIf Empty(cLocalOrig)
						jJsonItem['code'] := 10
						jJsonItem['message'] := "Nao foi informado o local de origem!"

					Else
						// Define o tipo de transferencia
						If aTransf[nX]:HasProperty("fwguia")
							cGuia := aTransf[nX]["fwguia"]
							
							// Valida parametro em branco
							If Empty(cGuia)
								jJsonItem['code'] := 12
								jJsonItem['message'] := "Nao foi informado a guia!"

							Else
								cObserva := "TRANSF. VIA APP GUIA " + cGuia
								
								// Se for uma guia antiga
								If Len(cGuia) > 6
									cGuiaAntiga := SubStr(cGuia, 5, Len(cGuia) - 5)
								EndIf
								
								// Controle de execucao com mesma guia
								If !MayIUseCode(cGuia)
									jJsonItem['code'] := 13
									jJsonItem['message'] := "Ja existe uma transferencia sendo executado com a guia: " + cGuia + "!"

								Else
									// Declara as variaveis
									aBody := {}
									aLinha := {}

									// Se o local de origem for P1
									If cLocalOrig == "P1"
										// Busca as informacoes da guia no P2
										If (Select("GUIASD3") <> 0)
											dbSelectArea("GUIASD3")
											dbCloseArea()
										EndIf

										BeginSql alias 'GUIASD3'
											SELECT DISTINCT D3_DOC, B1_COD, B1_DESC, B1_UM
												FROM %Table:SD3% (NOLOCK) AS SD3
											INNER JOIN %Table:SB1% (NOLOCK) AS SB1
												ON B1_FILIAL = %xFilial:SB1%
												AND B1_COD = D3_COD
												AND SB1.%NotDel%
											WHERE D3_FILIAL = %xFilial:SD3%
												AND D3_ESTORNO = ' '
												AND D3_CF = 'PR0'
												AND (D3_LOTEFIO = %Exp:cGuia% OR D3_LOTEFIO = %Exp:cGuiaAntiga%) // N�O DEIXAREI ASSIM, � APENAS AT� TODAS AS GUIAS ANTIGAS SEREM TRANSFERIDAS, AP�S ISSO, VOLTAR� A PESQUISA ANTERIOR
												AND SD3.%NotDel%
										EndSql

										// Se existir
										If !GUIASD3->(Eof())
											lPost := .T.
											
											// Para cada informacao
											While !GUIASD3->(Eof())
												// Recebe as informacoes da guia
												cProd := GUIASD3->B1_COD
												cDesc := GUIASD3->B1_DESC
												cUnid := GUIASD3->B1_UM

												cDoc := GetSxENum("SD3", "D3_DOC", 1)
												cLocalDest := "P2"
												nOperacao := 3

												// Procura o estoque do produto no local de destino
												dbSelectArea("SB2")
												dbSetOrder(1)
												dbGoTop()
												dbSeek(xFilial("SB2") + cProd + cLocalDest)

												// Se nao encontrar
												If !SB2->(Found())
													// Cria registro no SB2
													CriaSB2(cProd, cLocalDest)
												EndIf
												
												// Monta requisicao
												aAdd(aBody, {cDoc, dDataBase}) // Cabecalho

												// Origem
												aAdd(aLinha, {"ITEM",		"001",					   Nil})
												aAdd(aLinha, {"D3_COD", 	cProd, 				   Nil})
												aAdd(aLinha, {"D3_DESCRI", 	cDesc, 				   Nil})
												aAdd(aLinha, {"D3_UM", 		cUnid, 				   Nil})
												aAdd(aLinha, {"D3_LOCAL", 	cLocalOrig, 				   Nil})
												aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
												// Destino
												aAdd(aLinha, {"D3_COD", 	cProd, 				   Nil})
												aAdd(aLinha, {"D3_DESCRI", 	cDesc, 				   Nil})
												aAdd(aLinha, {"D3_UM", 		cUnid, 				   Nil})
												aAdd(aLinha, {"D3_LOCAL", 	cLocalDest, 			   Nil})
												aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
												// Outros
												aAdd(aLinha, {"D3_NUMSERI", CriaVar("D3_NUMSERI",.F.), Nil})
												aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
												aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
												aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
												aAdd(aLinha, {"D3_POTENCI", CriaVar("D3_POTENCI",.F.), Nil})
												aAdd(aLinha, {"D3_QUANT", 	nQtd, 		   		   	   Nil})
												aAdd(aLinha, {"D3_OBSERVA", cObserva, 				   Nil})
												aAdd(aLinha, {"D3_QTSEGUM", CriaVar("D3_QTSEGUM",.F.), Nil})
												aAdd(aLinha, {"D3_ESTORNO", CriaVar("D3_ESTORNO",.F.), Nil})
												aAdd(aLinha, {"D3_NUMSEQ" , CriaVar("D3_NUMSEQ",.F.),  Nil})
												aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
												aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
												aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
												aAdd(aLinha, {"D3_ITEMGRD", CriaVar("D3_ITEMGRD",.F.), Nil})
												
												aAdd(aBody, aLinha)
												Exit
											EndDo
										EndIf

									// Se o local de origem for P2
									Else
										// Busca as informacoes da guia no P2
										If (Select("GUIASD3") <> 0)
											dbSelectArea("GUIASD3")
											dbCloseArea()
										EndIf

										BeginSql alias 'GUIASD3'
											SELECT DISTINCT D3_DOC, B1_COD, B1_DESC, B1_UM
												FROM %Table:SD3% (NOLOCK) AS SD3
											INNER JOIN %Table:SB1% (NOLOCK) AS SB1
												ON B1_FILIAL = %xFilial:SB1%
												AND B1_COD = D3_COD
												AND SB1.%NotDel%
											WHERE D3_FILIAL = %xFilial:SD3%
												AND D3_ESTORNO = ' '
												AND D3_CF = 'DE4'
												AND (D3_LOTEFIO = %Exp:cGuia% OR D3_LOTEFIO = %Exp:cGuiaAntiga%) // N�O DEIXAREI ASSIM, � APENAS AT� TODAS AS GUIAS ANTIGAS SEREM TRANSFERIDAS, AP�S ISSO, VOLTAR� A PESQUISA ANTERIOR
												AND SD3.%NotDel%
										EndSql

										// Se existir
										If !GUIASD3->(Eof())
											lPost := .T.

											// Para cada informacao
											While !GUIASD3->(Eof())
												// Recebe as informacoes da guia
												cProd := GUIASD3->B1_COD
												cDesc := GUIASD3->B1_DESC
												cUnid := GUIASD3->B1_UM

												cDoc := GUIASD3->D3_DOC
												cLocalDest := "P1"
												nOperacao := 6

												// Procura o estoque do produto no local de destino
												dbSelectArea("SB2")
												dbSetOrder(1)
												dbGoTop()
												dbSeek(xFilial("SB2") + cProd + cLocalDest)

												// Se nao encontrar
												If !SB2->(Found())
													// Cria registro no SB2
													CriaSB2(cProd, cLocalDest)
												EndIf
												
												// Busca o registro da guia no SD3
												DbSelectArea("SD3")
												DbSetOrder(2)
												DbSeek(xFilial("SD3") + cDoc + cProd)

												// Monta requisicao (Informacoes encontradas no SD3, por isso aBody e passado em branco)
												aBody := {}
												Exit
											EndDo
										EndIf
									EndIf

									// Se encontrou a movimentacao
									If lPost
										// Verifica se a guia possui estoque suficiente no local de origem para realizar a transferencia para o local de destino
										lPost := B1445Dados(cGuia, cLocalOrig, cLocalDest)

										// Se existir
										If lPost
											// Chama a rotina padrao
											lPost := B1445Mata(aBody, nOperacao)

											If lPost
												jJsonItem['ret_prod'] := AllTrim(cProd)
												jJsonItem['ret_desc'] := AllTrim(cDesc)
												jJsonItem['ret_um'] := AllTrim(cUnid)
												jJsonItem['ret_guia'] := cGuia
												jJsonItem['ret_local'] := cLocalOrig
												jJsonItem['ret_localdest'] := cLocalDest
												jJsonItem['ret_usu'] := cUsuario
												jJsonItem['ret_estguia'] := nQtd
												jJsonItem['code'] := 200
												jJsonItem['message'] := "Transferido a guia: " + cGuia + " do " + cLocalOrig + " para o " + cLocalDest + " com sucesso!"

												// Busca a guia
												dbSelectArea("ZGE")
												dbSetOrder(1)

												// Se for uma guia antiga
												If Len(cGuia) == 6
													cGuia := "FP" + PadL(cGuia, 8, "0") + "A"
												EndIf

												// Se existir
												If dbSeek(xFilial("ZGE") + cGuia)
													If (Select("MAXREG") <> 0)
														dbSelectArea("MAXREG")
														dbCloseArea()
													EndIf

													BeginSql Alias 'MAXREG'
														SELECT ISNULL(MAX(ZGK_COD), '0000000000') AS ZGK_COD
															FROM %Table:ZGK% (NOLOCK)
														WHERE ZGK_FILIAL = %xFilial:ZGK%
													EndSql

													If !MAXREG->(Eof())
														cNumReg := Soma1(MAXREG->ZGK_COD)
													EndIf
													
													If cLocalDest == 'P2'
														// Atualiza na tabela ZGE
														(RecLock("ZGE", .F.))
														ZGE->ZGE_STATUS = "ESTOQUE"
														ZGE->ZGE_LOCAL = "P2"
														ZGE->(MsUnlock())

														dbSelectArea("ZGK")
														DbGoTop()

														// Atualiza na tabela ZGK
														(RecLock("ZGK", .T.))
														ZGK->ZGK_FILIAL = xFilial("ZGK")
														ZGK->ZGK_COD = cNumReg
														ZGK->ZGK_ORIGEM = SubStr(cGuia, 1, 2)
														ZGK->ZGK_GUIA = SubStr(cGuia, 3, Len(cGuia) - 3)
														ZGK->ZGK_SEQ = SubStr(cGuia, Len(cGuia))
														ZGK->ZGK_TIPO = "TRANSFERIDO"
														ZGK->ZGK_DATA = dDataBase
														ZGK->ZGK_HORA = Time()
														ZGK->ZGK_USER = cUsuario
														ZGK->(MsUnlock())

													Else
														// Atualiza na tabela ZGE
														(RecLock("ZGE", .F.))
														ZGE->ZGE_STATUS = "APONTADO"
														ZGE->ZGE_LOCAL = "P1"
														ZGE->(MsUnlock())

														dbSelectArea("ZGK")
														DbGoTop()

														// Atualiza na tabela ZGK
														(RecLock("ZGK", .T.))
														ZGK->ZGK_FILIAL = xFilial("ZGK")
														ZGK->ZGK_COD = cNumReg
														ZGK->ZGK_ORIGEM = SubStr(cGuia, 1, 2)
														ZGK->ZGK_GUIA = SubStr(cGuia, 3, Len(cGuia) - 3)
														ZGK->ZGK_SEQ = SubStr(cGuia, Len(cGuia))
														ZGK->ZGK_TIPO = "ESTORNO TRANSF."
														ZGK->ZGK_DATA = dDataBase
														ZGK->ZGK_HORA = Time()
														ZGK->ZGK_USER = cUsuario
														ZGK->(MsUnlock())
													EndIf

												Else
													jJsonItem['code'] := 15
													jJsonItem['message'] := "A transferencia foi realizada, porem nao foi encontrada a guia para ser atualizada, favor verificar com o TI!"
												EndIf
											EndIf
										EndIf

										// Libera executacao com a mesma guia
										Leave1Code(cGuia)
										
									Else
										jJsonItem['code'] := 14
										jJsonItem['message'] := "A guia: " + cGuia + " nao foi encontrada no " + cLocalOrig + " para ser realizado a transferencia, favor verificar!"
									EndIf
								EndIf
							EndIf

						ElseIf aTransf[nX]:HasProperty("fwproduto")
							cProd := AvKey(aTransf[nX]["fwproduto"], "B2_COD")

							// Valida campo informado
							If !aTransf[nX]:HasProperty("fwlocaldest")
								jJsonItem['message'] := "O campo (fwlocaldest) nao foi informado!"
								jJsonItem['code'] := 16
								
							Else
								cLocalDest := aTransf[nX]["fwlocaldest"]

								// Valida parametros em branco
								If Empty(cProd)
									jJsonItem['code'] := 17
									jJsonItem['message'] := "Nao foi informado o produto!"

								ElseIf Empty(cLocalDest)
									jJsonItem['code'] := 18
									jJsonItem['message'] := "Nao foi informado o local de destino!"

								Else
									// Busca o produto
									dbSelectArea("SB1")
									dbSetOrder(1)
									dbGoTop()

									// Se encontrar o produto
									If dbSeek(xFilial("SB1") + cProd)
										// Recebe as informacoes da guia
										cDesc := SB1->B1_DESC
										cUnid := SB1->B1_UM

										cDoc := GetSxENum("SD3", "D3_DOC", 1)

										// Procura o estoque do produto no local de destino
										dbSelectArea("SB2")
										dbSetOrder(1)
										dbGoTop()
										dbSeek(xFilial("SB2") + cProd + cLocalDest)

										// Se nao encontrar
										If !SB2->(Found())
											// Cria registro no SB2
											CriaSB2(cProd, cLocalDest)
										EndIf
										
										// Se a quantidade disponivel em estoque no SB2 for menor do que a quantidade da guia
										If (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP) < nQtd
											jJsonItem['code'] := 20
											jJsonItem['message'] := "A quantidade " + AllTrim(Str(nQtd)) + " solicitada e maior do que a quantidade em estoque " + AllTrim(Str(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP)) + ", no local de origem: " + cLocalOrig + ", favor verificar!"
										
										Else
											// Monta requisicao
											aAdd(aBody, {cDoc, dDataBase}) // Cabecalho

											// Origem
											aAdd(aLinha, {"ITEM",		"001",					   Nil})
											aAdd(aLinha, {"D3_COD", 	cProd, 				   	   Nil})
											aAdd(aLinha, {"D3_DESCRI", 	cDesc, 				   	   Nil})
											aAdd(aLinha, {"D3_UM", 		cUnid, 				   	   Nil})
											aAdd(aLinha, {"D3_LOCAL", 	cLocalOrig, 			   Nil})
											aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
											// Destino
											aAdd(aLinha, {"D3_COD", 	cProd, 				   	   Nil})
											aAdd(aLinha, {"D3_DESCRI", 	cDesc, 				   	   Nil})
											aAdd(aLinha, {"D3_UM", 		cUnid, 				       Nil})
											aAdd(aLinha, {"D3_LOCAL", 	cLocalDest, 			   Nil})
											aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
											// Outros
											aAdd(aLinha, {"D3_NUMSERI", CriaVar("D3_NUMSERI",.F.), Nil})
											aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
											aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
											aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
											aAdd(aLinha, {"D3_POTENCI", CriaVar("D3_POTENCI",.F.), Nil})
											aAdd(aLinha, {"D3_QUANT", 	nQtd, 		   		   	   Nil})
											aAdd(aLinha, {"D3_OBSERVA", cObserva, 				   Nil})
											aAdd(aLinha, {"D3_QTSEGUM", CriaVar("D3_QTSEGUM",.F.), Nil})
											aAdd(aLinha, {"D3_ESTORNO", CriaVar("D3_ESTORNO",.F.), Nil})
											aAdd(aLinha, {"D3_NUMSEQ" , CriaVar("D3_NUMSEQ",.F.),  Nil})
											aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
											aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
											aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
											aAdd(aLinha, {"D3_ITEMGRD", CriaVar("D3_ITEMGRD",.F.), Nil})
											
											aAdd(aBody, aLinha)

											// Chama a rotina padrao
											lPost := B1445Mata(aBody, 3)

											If lPost
												jJsonItem['code'] := 200
												jJsonItem['message'] := "Operacao realizada com sucesso!"
											EndIf
										EndIf

									Else
										jJsonItem['code'] := 19
										jJsonItem['message'] := "O produto: " + AllTrim(cProd) + " nao foi encontrado, favor verificar!"
									EndIf
								EndIf
							EndIf

						Else
							jJsonItem['code'] := 11
							jJsonItem['message'] := "Informe um produto ou uma guia para realizar a transferencia!"
						EndIf
					EndIf
				EndIf

				// Adiciona o code ao retorno
				aAdd(oRetorno["retorno"], jJsonItem)
                ConOut("[API TRANSF. ESTOQUE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			Next nX
		EndIf
	EndIf

	// Adiciona resposta da API
	Self:SetContentType('application/json')
    Self:SetResponse(EncodeUtf8(oRetorno:toJson()))

Return .T.

/*
/==================================================================================\
| Metodo  : GET Listar                                                             |
|==================================================================================|
| Descricao: Lista todos os produtos com saldo disponivel em um local              |
|==================================================================================|
| URL: GET /api/pda/api_transferencia/listar/{cLocal}                              |
|==================================================================================|
| Retorno (array "itens"):                                                         |
|   ret_prod    : Codigo do produto                                                |
|   ret_desc    : Descricao do produto                                             |
|   ret_um      : Unidade de medida                                                |
|   ret_local   : Local consultado                                                 |
|   ret_saldo   : Saldo disponivel (B2_QATU - B2_RESERVA - B2_QEMP)               |
\==================================================================================/
*/

WSMETHOD GET Listar WSRECEIVE cLocal WSSERVICE api_transferencia

	Local cLocalFiltro := ""
	Local jItem        := Nil

	Private oRetorno  := JsonObject():New()
	Private jJsonItem := JsonObject():New()

	oRetorno["retorno"] := {}
	oRetorno["itens"]   := {}

	If Empty(SELF:AURLPARMS[1])
		jJsonItem['code']    := 2
		jJsonItem['message'] := "Nao foi informado o local!"
		ConOut("[BUD1445 GET Listar] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	Else
		cLocalFiltro := AllTrim(SELF:AURLPARMS[1])

		If (Select("LISTASB2") <> 0)
			dbSelectArea("LISTASB2")
			dbCloseArea()
		EndIf

		BeginSql alias 'LISTASB2'
			SELECT SB2.B2_COD,
			       B1_DESC,
			       B1_UM,
			       SB2.B2_LOCAL,
			       (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP) AS SALDO
			FROM %Table:SB2% (NOLOCK) AS SB2
			INNER JOIN %Table:SB1% (NOLOCK) AS SB1
				ON B1_FILIAL = %xFilial:SB1%
				AND B1_COD   = SB2.B2_COD
				AND SB1.%NotDel%
			WHERE SB2.B2_FILIAL = %xFilial:SB2%
				AND SB2.B2_LOCAL  = %Exp:cLocalFiltro%
				AND (SB2.B2_QATU - SB2.B2_RESERVA - SB2.B2_QEMP) > 0
				AND SB2.%NotDel%
			ORDER BY SB2.B2_COD
		EndSql

		If !LISTASB2->(Eof())
			While !LISTASB2->(Eof())
				jItem              := JsonObject():New()
				jItem['ret_prod']  := AllTrim(LISTASB2->B2_COD)
				jItem['ret_desc']  := AllTrim(LISTASB2->B1_DESC)
				jItem['ret_um']    := AllTrim(LISTASB2->B1_UM)
				jItem['ret_local'] := AllTrim(LISTASB2->B2_LOCAL)
				jItem['ret_saldo'] := LISTASB2->SALDO
				aAdd(oRetorno["itens"], jItem)
				LISTASB2->(dbSkip())
			EndDo

			jJsonItem['code']    := 200
			jJsonItem['message'] := "Listagem realizada com sucesso!"
		Else
			jJsonItem['code']    := 22
			jJsonItem['message'] := "Nenhum produto com saldo disponivel no local " + cLocalFiltro + "!"
		EndIf

		ConOut("[BUD1445 GET Listar] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(EncodeUtf8(oRetorno:toJson()))

Return .T.

/*
/==================================================================================\
| Metodo  : PUT Atualizar                                                          |
|==================================================================================|
| Descricao: Realiza transferencia de estoque entre locais por produto             |
|            Chama MATA261 operacao 3 (saida de transferencia)                     |
|==================================================================================|
| Body JSON:                                                                       |
|   { "fwtransf": [{                                                               |
|       "fwusuario":   "COD_USUARIO",                                              |
|       "fwqtd":       1.0,                                                        |
|       "fwlocalorig": "P1",                                                       |
|       "fwproduto":   "000001",                                                   |
|       "fwlocaldest": "P2"                                                        |
|   }] }                                                                           |
\==================================================================================/
*/

WSMETHOD PUT Atualizar WSSERVICE api_transferencia

	Local cBody     := ""
	Local oTransf   := JsonObject():New()
	Local aTransf   := {}
	Local lPost     := .F.
	Local cProd     := ""
	Local cDesc     := ""
	Local cUnid     := ""
	Local cLocalOrig:= ""
	Local cLocalDest:= ""
	Local cDoc      := ""
	Local cObserva  := ""
	Local nQtd      := 0
	Local nX        := 0
	Local aBody     := {}
	Local aLinha    := {}

	Private cUsuario       := ""
	Private cFuncaoPai     := "BUD1445"
	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	Public oRetorno  := JsonObject():New() as Object
	Public jJsonItem := JsonObject():New() as Json

	oRetorno["retorno"] := {}

	cBody := oRest:getBodyRequest()
	oTransf:fromJson(DecodeUTF8(cBody))

	If !oTransf:HasProperty("fwtransf")
		jJsonItem['code']    := 3
		jJsonItem['message'] := "O campo (fwtransf) nao foi informado!"
		ConOut("[BUD1445 PUT] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	Else
		aTransf := oTransf["fwtransf"]

		If Len(aTransf) == 0
			jJsonItem['code']    := 4
			jJsonItem['message'] := "Nao foram informadas transferencias no array (fwtransf)!"
			ConOut("[BUD1445 PUT] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			aAdd(oRetorno["retorno"], jJsonItem)

		Else
			For nX := 1 To Len(aTransf)
				lPost     := .F.
				jJsonItem := JsonObject():New()
				aBody     := {}
				aLinha    := {}

				If !aTransf[nX]:HasProperty("fwusuario")
					jJsonItem['code']    := 5
					jJsonItem['message'] := "O campo (fwusuario) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwqtd")
					jJsonItem['code']    := 6
					jJsonItem['message'] := "O campo (fwqtd) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocalorig")
					jJsonItem['code']    := 7
					jJsonItem['message'] := "O campo (fwlocalorig) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwproduto")
					jJsonItem['code']    := 16
					jJsonItem['message'] := "O campo (fwproduto) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocaldest")
					jJsonItem['code']    := 18
					jJsonItem['message'] := "O campo (fwlocaldest) nao foi informado!"

				Else
					cUsuario  := AllTrim(aTransf[nX]["fwusuario"])
					nQtd      := aTransf[nX]["fwqtd"]
					cLocalOrig:= AllTrim(aTransf[nX]["fwlocalorig"])
					cProd     := AvKey(AllTrim(aTransf[nX]["fwproduto"]), "B2_COD")
					cLocalDest:= AllTrim(aTransf[nX]["fwlocaldest"])

					If Empty(cUsuario)
						jJsonItem['code']    := 8
						jJsonItem['message'] := "Nao foi informado o usuario!"

					ElseIf Empty(nQtd)
						jJsonItem['code']    := 9
						jJsonItem['message'] := "Nao foi informada a quantidade!"

					ElseIf Empty(cLocalOrig)
						jJsonItem['code']    := 10
						jJsonItem['message'] := "Nao foi informado o local de origem!"

					ElseIf Empty(cProd)
						jJsonItem['code']    := 17
						jJsonItem['message'] := "Nao foi informado o produto!"

					ElseIf Empty(cLocalDest)
						jJsonItem['code']    := 18
						jJsonItem['message'] := "Nao foi informado o local de destino!"

					ElseIf cLocalOrig == cLocalDest
						jJsonItem['code']    := 25
						jJsonItem['message'] := "O local de origem e o local de destino nao podem ser iguais!"

					Else
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbGoTop()

						If dbSeek(xFilial("SB1") + cProd)
							cDesc := AllTrim(SB1->B1_DESC)
							cUnid := AllTrim(SB1->B1_UM)

							dbSelectArea("SB2")
							dbSetOrder(1)
							dbGoTop()
							dbSeek(xFilial("SB2") + cProd + cLocalDest)
							If !SB2->(Found())
								CriaSB2(cProd, cLocalDest)
							EndIf

							cDoc     := GetSxENum("SD3", "D3_DOC", 1)
							cObserva := "TRANSF. PDA PRODUTO " + cProd

							aAdd(aBody, {cDoc, dDataBase})

							// Origem
							aAdd(aLinha, {"ITEM",       "001",                     Nil})
							aAdd(aLinha, {"D3_COD",     cProd,                     Nil})
							aAdd(aLinha, {"D3_DESCRI",  cDesc,                     Nil})
							aAdd(aLinha, {"D3_UM",      cUnid,                     Nil})
							aAdd(aLinha, {"D3_LOCAL",   cLocalOrig,                Nil})
							aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
							// Destino
							aAdd(aLinha, {"D3_COD",     cProd,                     Nil})
							aAdd(aLinha, {"D3_DESCRI",  cDesc,                     Nil})
							aAdd(aLinha, {"D3_UM",      cUnid,                     Nil})
							aAdd(aLinha, {"D3_LOCAL",   cLocalDest,                Nil})
							aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
							// Complementares
							aAdd(aLinha, {"D3_NUMSERI", CriaVar("D3_NUMSERI",.F.), Nil})
							aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
							aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
							aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
							aAdd(aLinha, {"D3_POTENCI", CriaVar("D3_POTENCI",.F.), Nil})
							aAdd(aLinha, {"D3_QUANT",   nQtd,                      Nil})
							aAdd(aLinha, {"D3_OBSERVA", cObserva,                  Nil})
							aAdd(aLinha, {"D3_QTSEGUM", CriaVar("D3_QTSEGUM",.F.), Nil})
							aAdd(aLinha, {"D3_ESTORNO", CriaVar("D3_ESTORNO",.F.), Nil})
							aAdd(aLinha, {"D3_NUMSEQ",  CriaVar("D3_NUMSEQ",.F.),  Nil})
							aAdd(aLinha, {"D3_ITEMGRD", CriaVar("D3_ITEMGRD",.F.), Nil})
							aAdd(aBody, aLinha)

							lPost := B1445Mata(aBody, 3)

							If lPost
								jJsonItem['code']         := 200
								jJsonItem['message']      := "Transferencia do produto " + cProd + " realizada com sucesso!"
								jJsonItem['ret_prod']     := cProd
								jJsonItem['ret_desc']     := cDesc
								jJsonItem['ret_um']       := cUnid
								jJsonItem['ret_local']    := cLocalOrig
								jJsonItem['ret_localdest']:= cLocalDest
								jJsonItem['ret_qtd']      := nQtd
								jJsonItem['ret_usu']      := cUsuario
							EndIf
						Else
							jJsonItem['code']    := 19
							jJsonItem['message'] := "Produto " + cProd + " nao encontrado, favor verificar!"
						EndIf
					EndIf
				EndIf

				aAdd(oRetorno["retorno"], jJsonItem)
				ConOut("[BUD1445 PUT] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			Next nX
		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(EncodeUtf8(oRetorno:toJson()))

Return .T.

/*
/==================================================================================\
| Metodo  : POST Cadastrar                                                         |
|==================================================================================|
| Descricao: Cadastra entrada de transferencia no SD3 (CF=DE4, TM=499)            |
|            Chama MATA261 operacao 1 (inclusao simples)                           |
|==================================================================================|
| Body JSON:                                                                       |
|   { "fwtransf": [{                                                               |
|       "fwusuario":   "COD_USUARIO",                                              |
|       "fwqtd":       1.0,                                                        |
|       "fwlocalorig": "P1",                                                       |
|       "fwproduto":   "000001",                                                   |
|       "fwlocaldest": "P2"                                                        |
|   }] }                                                                           |
\==================================================================================/
*/

WSMETHOD POST Cadastrar WSSERVICE api_transferencia

	Local cBody     := ""
	Local oTransf   := JsonObject():New()
	Local aTransf   := {}
	Local lPost     := .F.
	Local cProd     := ""
	Local cDesc     := ""
	Local cUnid     := ""
	Local cLocalOrig:= ""
	Local cLocalDest:= ""
	Local cDoc      := ""
	Local cObserva  := ""
	Local nQtd      := 0
	Local nX        := 0
	Local aBody     := {}
	Local aLinha    := {}

	Private cUsuario       := ""
	Private cFuncaoPai     := "BUD1445"
	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	Public oRetorno  := JsonObject():New() as Object
	Public jJsonItem := JsonObject():New() as Json

	oRetorno["retorno"] := {}

	cBody := oRest:getBodyRequest()
	oTransf:fromJson(DecodeUTF8(cBody))

	If !oTransf:HasProperty("fwtransf")
		jJsonItem['code']    := 3
		jJsonItem['message'] := "O campo (fwtransf) nao foi informado!"
		ConOut("[BUD1445 POST Cadastrar] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	Else
		aTransf := oTransf["fwtransf"]

		If Len(aTransf) == 0
			jJsonItem['code']    := 4
			jJsonItem['message'] := "Nao foram informadas transferencias no array (fwtransf)!"
			ConOut("[BUD1445 POST Cadastrar] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			aAdd(oRetorno["retorno"], jJsonItem)

		Else
			For nX := 1 To Len(aTransf)
				lPost     := .F.
				jJsonItem := JsonObject():New()
				aBody     := {}
				aLinha    := {}

				If !aTransf[nX]:HasProperty("fwusuario")
					jJsonItem['code']    := 5
					jJsonItem['message'] := "O campo (fwusuario) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwqtd")
					jJsonItem['code']    := 6
					jJsonItem['message'] := "O campo (fwqtd) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocalorig")
					jJsonItem['code']    := 7
					jJsonItem['message'] := "O campo (fwlocalorig) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwproduto")
					jJsonItem['code']    := 16
					jJsonItem['message'] := "O campo (fwproduto) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocaldest")
					jJsonItem['code']    := 18
					jJsonItem['message'] := "O campo (fwlocaldest) nao foi informado!"

				Else
					cUsuario  := AllTrim(aTransf[nX]["fwusuario"])
					nQtd      := aTransf[nX]["fwqtd"]
					cLocalOrig:= AllTrim(aTransf[nX]["fwlocalorig"])
					cProd     := AvKey(AllTrim(aTransf[nX]["fwproduto"]), "B2_COD")
					cLocalDest:= AllTrim(aTransf[nX]["fwlocaldest"])

					If Empty(cUsuario)
						jJsonItem['code']    := 8
						jJsonItem['message'] := "Nao foi informado o usuario!"

					ElseIf Empty(nQtd)
						jJsonItem['code']    := 9
						jJsonItem['message'] := "Nao foi informada a quantidade!"

					ElseIf Empty(cLocalOrig)
						jJsonItem['code']    := 10
						jJsonItem['message'] := "Nao foi informado o local de origem!"

					ElseIf Empty(cProd)
						jJsonItem['code']    := 17
						jJsonItem['message'] := "Nao foi informado o produto!"

					ElseIf Empty(cLocalDest)
						jJsonItem['code']    := 18
						jJsonItem['message'] := "Nao foi informado o local de destino!"

					ElseIf cLocalOrig == cLocalDest
						jJsonItem['code']    := 25
						jJsonItem['message'] := "O local de origem e o local de destino nao podem ser iguais!"

					Else
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbGoTop()

						If dbSeek(xFilial("SB1") + cProd)
							cDesc := AllTrim(SB1->B1_DESC)
							cUnid := AllTrim(SB1->B1_UM)

							dbSelectArea("SB2")
							dbSetOrder(1)
							dbGoTop()
							dbSeek(xFilial("SB2") + cProd + cLocalDest)
							If !SB2->(Found())
								CriaSB2(cProd, cLocalDest)
							EndIf

							cDoc     := GetSxENum("SD3", "D3_DOC", 1)
							cObserva := "ENTRADA TRANSF. PDA PRODUTO " + cProd

							aAdd(aBody, {cDoc, dDataBase})

							// Linha de entrada (CF=DE4 / TM=499)
							aAdd(aLinha, {"ITEM",       "001",                     Nil})
							aAdd(aLinha, {"D3_COD",     cProd,                     Nil})
							aAdd(aLinha, {"D3_DESCRI",  cDesc,                     Nil})
							aAdd(aLinha, {"D3_UM",      cUnid,                     Nil})
							aAdd(aLinha, {"D3_CF",      "DE4",                     Nil})
							aAdd(aLinha, {"D3_TM",      "499",                     Nil})
							aAdd(aLinha, {"D3_LOCAL",   cLocalDest,                Nil})
							aAdd(aLinha, {"D3_LOCALIZ", CriaVar("D3_LOCALIZ",.F.), Nil})
							aAdd(aLinha, {"D3_NUMSERI", CriaVar("D3_NUMSERI",.F.), Nil})
							aAdd(aLinha, {"D3_LOTECTL", CriaVar("D3_LOTECTL",.F.), Nil})
							aAdd(aLinha, {"D3_NUMLOTE", CriaVar("D3_NUMLOTE",.F.), Nil})
							aAdd(aLinha, {"D3_DTVALID", CriaVar("D3_DTVALID",.F.), Nil})
							aAdd(aLinha, {"D3_POTENCI", CriaVar("D3_POTENCI",.F.), Nil})
							aAdd(aLinha, {"D3_QUANT",   nQtd,                      Nil})
							aAdd(aLinha, {"D3_OBSERVA", cObserva,                  Nil})
							aAdd(aLinha, {"D3_QTSEGUM", CriaVar("D3_QTSEGUM",.F.), Nil})
							aAdd(aLinha, {"D3_ESTORNO", CriaVar("D3_ESTORNO",.F.), Nil})
							aAdd(aLinha, {"D3_NUMSEQ",  CriaVar("D3_NUMSEQ",.F.),  Nil})
							aAdd(aLinha, {"D3_ITEMGRD", CriaVar("D3_ITEMGRD",.F.), Nil})
							aAdd(aBody, aLinha)

							// Operacao 1 = Inclusao simples
							lPost := B1445Mata(aBody, 1)

							If lPost
								jJsonItem['code']         := 200
								jJsonItem['message']      := "Entrada de transferencia do produto " + cProd + " cadastrada com sucesso!"
								jJsonItem['ret_doc']      := cDoc
								jJsonItem['ret_prod']     := cProd
								jJsonItem['ret_desc']     := cDesc
								jJsonItem['ret_um']       := cUnid
								jJsonItem['ret_cf']       := "DE4"
								jJsonItem['ret_tm']       := "499"
								jJsonItem['ret_local']    := cLocalOrig
								jJsonItem['ret_localdest']:= cLocalDest
								jJsonItem['ret_qtd']      := nQtd
								jJsonItem['ret_usu']      := cUsuario
							EndIf
						Else
							jJsonItem['code']    := 19
							jJsonItem['message'] := "Produto " + cProd + " nao encontrado, favor verificar!"
						EndIf
					EndIf
				EndIf

				aAdd(oRetorno["retorno"], jJsonItem)
				ConOut("[BUD1445 POST Cadastrar] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			Next nX
		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(EncodeUtf8(oRetorno:toJson()))

Return .T.

/*
/==================================================================================\
| Metodo  : DELETE Deletar                                                         |
|==================================================================================|
| Descricao: Estorna ultimo movimento de transferencia do produto via MATA261      |
|            Chama MATA261 operacao 7 (estorno)                                    |
|            Busca chave: fwproduto + fwlocalorig + fwlocaldest                    |
|==================================================================================|
| Body JSON:                                                                       |
|   { "fwtransf": [{                                                               |
|       "fwusuario":   "COD_USUARIO",                                              |
|       "fwproduto":   "000001",                                                   |
|       "fwlocalorig": "P1",                                                       |
|       "fwlocaldest": "P2"                                                        |
|   }] }                                                                           |
\==================================================================================/
*/

WSMETHOD DELETE Deletar WSSERVICE api_transferencia

	Local cBody     := ""
	Local oTransf   := JsonObject():New()
	Local aTransf   := {}
	Local lPost     := .F.
	Local cProd     := ""
	Local cLocalOrig:= ""
	Local cLocalDest:= ""
	Local nX        := 0
	Local aBody     := {}

	Private cUsuario       := ""
	Private cFuncaoPai     := "BUD1445"
	Private lMsHelpAuto    := .T.
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.

	Public oRetorno  := JsonObject():New() as Object
	Public jJsonItem := JsonObject():New() as Json

	oRetorno["retorno"] := {}

	cBody := oRest:getBodyRequest()
	oTransf:fromJson(DecodeUTF8(cBody))

	If !oTransf:HasProperty("fwtransf")
		jJsonItem['code']    := 3
		jJsonItem['message'] := "O campo (fwtransf) nao foi informado!"
		ConOut("[BUD1445 DELETE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
		aAdd(oRetorno["retorno"], jJsonItem)

	Else
		aTransf := oTransf["fwtransf"]

		If Len(aTransf) == 0
			jJsonItem['code']    := 4
			jJsonItem['message'] := "Nao foram informados itens para estorno no array (fwtransf)!"
			ConOut("[BUD1445 DELETE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			aAdd(oRetorno["retorno"], jJsonItem)

		Else
			For nX := 1 To Len(aTransf)
				lPost     := .F.
				jJsonItem := JsonObject():New()
				aBody     := {}

				If !aTransf[nX]:HasProperty("fwusuario")
					jJsonItem['code']    := 5
					jJsonItem['message'] := "O campo (fwusuario) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwproduto")
					jJsonItem['code']    := 16
					jJsonItem['message'] := "O campo (fwproduto) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocalorig")
					jJsonItem['code']    := 7
					jJsonItem['message'] := "O campo (fwlocalorig) nao foi informado!"

				ElseIf !aTransf[nX]:HasProperty("fwlocaldest")
					jJsonItem['code']    := 18
					jJsonItem['message'] := "O campo (fwlocaldest) nao foi informado!"

				Else
					cUsuario  := AllTrim(aTransf[nX]["fwusuario"])
					cProd     := AvKey(AllTrim(aTransf[nX]["fwproduto"]), "B2_COD")
					cLocalOrig:= AllTrim(aTransf[nX]["fwlocalorig"])
					cLocalDest:= AllTrim(aTransf[nX]["fwlocaldest"])

					If Empty(cUsuario)
						jJsonItem['code']    := 8
						jJsonItem['message'] := "Nao foi informado o usuario!"

					ElseIf Empty(cProd)
						jJsonItem['code']    := 17
						jJsonItem['message'] := "Nao foi informado o produto!"

					ElseIf Empty(cLocalOrig)
						jJsonItem['code']    := 10
						jJsonItem['message'] := "Nao foi informado o local de origem!"

					ElseIf Empty(cLocalDest)
						jJsonItem['code']    := 18
						jJsonItem['message'] := "Nao foi informado o local de destino!"

					ElseIf cLocalOrig == cLocalDest
						jJsonItem['code']    := 25
						jJsonItem['message'] := "O local de origem e o local de destino nao podem ser iguais!"

					Else
						If (Select("ESTSD3") <> 0)
							dbSelectArea("ESTSD3")
							dbCloseArea()
						EndIf

						BeginSql alias 'ESTSD3'
							SELECT TOP 1 D3_DOC, D3_COD, D3_QUANT
								FROM %Table:SD3% (NOLOCK)
							WHERE D3_FILIAL   = %xFilial:SD3%
								AND D3_COD    = %Exp:cProd%
								AND D3_LOCAL  = %Exp:cLocalOrig%
								AND D3_CF     = 'DE4'
								AND D3_TM     = '499'
								AND D3_ESTORNO = ' '
								AND %NotDel%
							ORDER BY D3_DOC DESC
						EndSql

						If !ESTSD3->(Eof())
							DbSelectArea("SD3")
							DbSetOrder(2)
							DbSeek(xFilial("SD3") + AllTrim(ESTSD3->D3_DOC) + cProd)

							If SD3->(Found())
								// Operacao 7 = Estorno de transferencia
								lPost := B1445Mata(aBody, 7)

								If lPost
									jJsonItem['code']         := 200
									jJsonItem['message']      := "Estorno do produto " + cProd + " realizado com sucesso!"
									jJsonItem['ret_prod']     := cProd
									jJsonItem['ret_doc']      := AllTrim(ESTSD3->D3_DOC)
									jJsonItem['ret_local']    := cLocalOrig
									jJsonItem['ret_localdest']:= cLocalDest
									jJsonItem['ret_qtd']      := ESTSD3->D3_QUANT
									jJsonItem['ret_usu']      := cUsuario
								EndIf
							Else
								jJsonItem['code']    := 26
								jJsonItem['message'] := "Movimento SD3 encontrado porem nao foi possivel posicionar o registro para estorno!"
							EndIf
						Else
							jJsonItem['code']    := 27
							jJsonItem['message'] := "Nao foi encontrado movimento de transferencia do produto " + cProd + " no local " + cLocalOrig + " para estornar!"
						EndIf
					EndIf
				EndIf

				aAdd(oRetorno["retorno"], jJsonItem)
				ConOut("[BUD1445 DELETE] - " + AllTrim(Str(jJsonItem["code"])) + " - " + jJsonItem["message"])
			Next nX
		EndIf
	EndIf

	Self:SetContentType('application/json')
	Self:SetResponse(EncodeUtf8(oRetorno:toJson()))

Return .T.

// Retorna o erro sem mostrar na tela
Static Function TxtErro(aAutoErro)

	Local cRet := ""
	Local nX := 1

	For nX := 1 to Len(aAutoErro)
		cRet += AllTrim(aAutoErro[nX])+Chr(13)+Chr(10)
	Next nX

Return cRet

Static Function B1445Mata(_body, _operacao)

	Local lRet := .F.

	lMsHelpAuto := .T.
	lMsErroAuto := .F.
	lAutoErrNoFile := .T.
	
	// Transfere a guia
	MSExecAuto({|x,y| MATA261(x,y)}, _body, _operacao)

	// Se ocorrer algum erro
	If lMsErroAuto
		aAutoErro := GetAutoGrLog()
		cRetorno := TxtErro(aAutoErro) 
		
		jJsonItem['code'] := 21
		jJsonItem['message'] := EncodeUtf8("Erro na rotina padrao de transferencia: " + cRetorno)

	// Se nao ocorrer algum erro
	Else
		lRet := .T.
	EndIf

Return lRet

/*
/==================================================================================\
|Nome              : Dados da guia                                                 |
|==================================================================================|
|Descricao         : Esta funcao retorna os dados da(s) guia(s)                    |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 10/06/2024                                                    |
\==================================================================================/
*/

Static Function B1445Dados(_guia, _localOrig, _localDest)

	Local lPost := .F.
	Local cProd := ""
	Local cDescProd := ""
	Local nQtd := 0
	Local cGuiaAntiga := _guia
	
	// Se for uma guia antiga
	If Len(_guia) > 6
		cGuiaAntiga := SubStr(_guia, 5, Len(_guia) - 5)
	EndIf
	
	// Busca as informacoes da producao no local de origem
	If (Select("RETSD3") <> 0)
		dbSelectArea("RETSD3")
		dbCloseArea()
	EndIf

	BeginSql alias 'RETSD3'
		SELECT TOP 1 D3_COD, D3_QUANT
			FROM %Table:SD3% (NOLOCK)
		WHERE D3_FILIAL = %xFilial:SD3%
			AND D3_ESTORNO = ''
			AND D3_CF IN ('PR0', 'DE4')
			AND D3_TM IN ('001', '004', '499')
			AND D3_LOCAL = %Exp:_localOrig%
			AND (D3_LOTEFIO = %Exp:_guia% OR D3_LOTEFIO = %Exp:cGuiaAntiga%) // N�O DEIXAREI ASSIM, � APENAS AT� TODAS AS GUIAS ANTIGAS SEREM TRANSFERIDAS, AP�S ISSO, VOLTAR� A PESQUISA ANTERIOR
			AND %NotDel%
	EndSql

	// Se existir
	If !RETSD3->(Eof())
		// Para cada um
		While !RETSD3->(Eof())
			// Recebe os valores
			cProd := RETSD3->D3_COD
			nQtd := RETSD3->D3_QUANT

			// Procura o estoque do produto no local de destino
			dbSelectArea("SB2")
			dbSetOrder(1)
			dbGoTop()
			dbSeek(xFilial("SB2") + cProd + _localOrig)

			// Se nao encontrar
			If !SB2->(Found())
				// Cria registro no SB2
				CriaSB2(cProd, _localDest)
			EndIf
			
			// Se a quantidade disponivel em estoque no SB2 for menor do que a quantidade da guia
			If (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP) < nQtd
				jJsonItem['code'] := 23
				jJsonItem['message'] := "A quantidade " + AllTrim(Str(nQtd)) + ", da guia: " + _guia + " e maior do que a quantidade em estoque " + AllTrim(Str(SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP)) + ", no local de origem: " + _localOrig + ", favor verificar!"
			
			Else
				cDescProd := AllTrim(Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_DESC"))
				
				// Verifica se existe alguma transferencia/devolucao com essa guia
				lPost := B1445VerTransf(_guia, _localDest)

				// Se nao existir
				If lPost
					jJsonItem['ret_guia'] := _guia
					jJsonItem['ret_local'] := _localOrig
					jJsonItem['ret_localdest'] := _localDest
					jJsonItem['ret_desc'] := AllTrim(cDescProd)
					jJsonItem['ret_estprod'] := (SB2->B2_QATU - SB2->B2_RESERVA - SB2->B2_QEMP)
					jJsonItem['ret_estguia'] := nQtd
					jJsonItem['ret_prod'] := AllTrim(cProd)
					jJsonItem['code'] := 200
					jJsonItem['message'] := "Existe estoque suficiente no " + _localOrig + " para realizar a transferencia para o " + _localDest + "!"
				
				// Se existir
				Else
					jJsonItem['code'] := 24
					jJsonItem['message'] := "Ja existe uma transferencia para o local " + _localDest + ", favor verificar!"
				EndIf
			EndIf

			Exit
		EndDo
		
	// Se nao existir producao no local de origem
	Else
		jJsonItem['code'] := 22
		jJsonItem['message'] := "Nao foi encontrado producao da guia: " + _guia + " para o " + _localOrig + ", favor verificar!"
	EndIf

Return lPost

/*
/============================================================================\
|Nome              : Verifica transferencia/devolucao              			 |
|============================================================================|
|Descricao         : Essa funcao verifica se existe alguma transferencia  	 |
|				   : ou devolucao com essa guia							     |
|============================================================================|
|Autor             : Joao Gebauer                                            |
|============================================================================|
|Data de Criacao   : 10/06/2024                                              |
\============================================================================/
*/

Static Function B1445VerTransf(_guia, _localDest)

  	Local lPost := .T.
	Local cGuiaAntiga := _guia
	
	// Se for uma guia antiga
	If Len(_guia) > 6
		cGuiaAntiga := SubStr(_guia, 5, Len(_guia) - 5)
	EndIf

	// Verifica se existe alguma transferencia/devolucao com essa guia
	If (Select("TRFSD3") <> 0)
		dbSelectArea("TRFSD3")
		dbCloseArea()
	EndIf

	BeginSql alias 'TRFSD3'
		SELECT TOP 1 D3_COD, D3_QUANT
			FROM %Table:SD3% (NOLOCK)
		WHERE %NotDel%
			AND D3_FILIAL = %xFilial:SD3%
			AND D3_CF = 'DE4'
			AND D3_TM = '499' 
			AND D3_ESTORNO = ''
			AND D3_LOCAL = %Exp:_localDest%
			AND (D3_LOTEFIO = %Exp:_guia% OR D3_LOTEFIO = %Exp:cGuiaAntiga%) // N�O DEIXAREI ASSIM, � APENAS AT� TODAS AS GUIAS ANTIGAS SEREM TRANSFERIDAS, AP�S ISSO, VOLTAR� A PESQUISA ANTERIOR
	EndSql

	If !TRFSD3->(Eof())
		lPost := .F.
	EndIf

Return lPost
