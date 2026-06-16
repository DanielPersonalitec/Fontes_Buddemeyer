#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
/*
/=========================================================================\
| Mdulo      : Api Rest                                                  |
|=========================================================================|
| Programa    : VRN0124.PRW   | Responsvel: Cesar Grossl         		  |
|=========================================================================|
| Descricao   : Movimento bancário		                                  |
|=========================================================================|
| Data        : 16/08/2020 						                          |
|=========================================================================|
| Programador : Cesar Grossl                 	                          |
\=========================================================================/
*/

WSRESTFUL repmovimentofin DESCRIPTION "Movimento bancario"

	WSMETHOD POST DESCRIPTION "Recebe variveis pelo post" WSSYNTAX "/repmovimentofin/ [ POST ]"

END WSRESTFUL


WSMETHOD POST WSSERVICE repmovimentofin

	::SetContentType("application/json")
	Local cBody              := ::GetContent()
	Local cFlag              := ""
	Local cAcao              := ""
	Local nY                 := ""
	Local cPedido            := ""
	Local cMotivo            := ""
	Local nProcessa1         := 0
	Local nProcessa2         := 0
	Local cLinha             := ""
	Local cTitulo            := ""
	Private lMsErroAuto      := .F.
	Private lAutoErrNoFile   := .T.
	Private lOkAT            := .F.
	Private cBodyrT3         := ""
	Private nVZT2            := 0
	Private oMovimento       := JsonObject():New()
	Private oItens           := JsonObject():New()
	FWJsonDeserialize(DecodeUTF8(cBody),@oMovimento)

	dDataBase := stod(oMovimento:dDtBaixa)
	cflag     := ALLTRIM(oMovimento:cflag)
	cMotivo   := ALLTRIM(oMovimento:motivo)
	cAcao     := ALLTRIM(oMovimento:cAcao)

	If Empty(AllTrim(cAcao))
		oItens['lac_status'] 		:= '400'
		oItens['lac_retorno_api'] 	:= ""
		oItens['lac_processo'] 		:= 'A'
		oItens['lac_linha'] 		:= cLinha
		oItens['lac_msg_mov']		:= "Favor enviar a Tag cAcao preenchida."
		cBodyRt3 := FWJsonSerialize(oItens)
		cBodyRt3 := FWNoAccent(cBodyRt3)
		::SetResponse(EncodeUtf8(cBodyRt3))
		return
	EndIf

	//paramentro de lançamento a pagar ou receber;
	If (cFlag == "P")
		nProcessa1 := 3
		nProcessa2 := 4
	Else
		nProcessa1 := 4
		nProcessa2 := 3
	EndIf

	//Caso ação for I vai fazer primeiro processo
	if cAcao == "INDIVIDUAL"

		U_VRN0159('[MOVIMENTO BANCÁRIO] - [INICIO] -> Importação Flag '+cFlag+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
		//Insiro todos os itens idividualmente no movimento;
		For nY := 1 to Len(oMovimento:itens)

			cPedido := oMovimento:itens[nY]:vaNumPed
			cTitulo := oMovimento:itens[nY]:vaNumTit
			cLinha 	:= oMovimento:itens[nY]:id_linha
			U_VRN0159('[MOVIMENTO BANCÁRIO] - [ITENS] -> Importação  linha: '+cLinha+', Pedido: '+cPedido+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
			aFINA100 := {}
			aFINA100 := {  	{"E5_DATA"     	,stod(oMovimento:dDtBaixa)	,Nil},;
				{"E5_VENCTO"   	,stod(oMovimento:dDtBaixa)				,Nil},;
				{"E5_FILIAL"   	,""										,Nil},;
				{"E5_MOEDA"    	,"M1"                     				,Nil},;
				{"E5_VALOR"    	,oMovimento:itens[nY]:mvVlrImp 			,Nil},;
				{"E5_TIPODOC"   ,"DH"							 		,Nil},;
				{"E5_NATUREZ"  	,oMovimento:natureza       				,Nil},;
				{"E5_BENEF"  	,"MOV. BCO"                				,Nil},;
				{"E5_BANCO"    	,oMovimento:banco_desc     				,Nil},;
				{"E5_AGENCIA"  	,oMovimento:banco_agencia  				,Nil},;
				{"E5_CONTA"    	,oMovimento:banco_conta  				,Nil},;
				{"E5_PREFIXO"  	,oMovimento:prefixo         			,Nil},;
				{"E5_NUMERO"   	,cTitulo								,Nil},;
				{"E5_PARCELA"  	,""             						,Nil},;
				{"E5_TIPO"      ,oMovimento:tipo             			,Nil},;
				{"E5_DOCUMEN"   ,"Ped."+cPedido+" Tit."+cTitulo			,Nil},;
				{"E5_HISTOR"   	,oMovimento:itens[nY]:mvDesc  			,Nil},;
				{"NCTBONLINE"   ,1                    					,Nil} }

			lMsErroAuto := .F.
			MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,nProcessa1)//06051982 3 PAGAR, 4 RECEBER
			If lMsErroAuto
				aAutoErro := GETAUTOGRLOG()
				cErro := TXTERRO(aAutoErro)
				U_VRN0159('[MOVIMENTO BANCÁRIO] - [ERRO 01] -> Importação  linha: '+cLinha+', Pedido: '+cPedido+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				U_VRN0159(cErro)
				rRetornaBaixa := U_vRnBMovimento("id_linha="+cLinha+"&rep_valida="+oMovimento:validaBw+"&rep_nfe="+RTRIM(cTitulo)+"&val_sit=erro")
				MontjSZ('400',rRetornaBaixa,'A',clinha,cErro,nY)
			Else
				U_VRN0159('[MOVIMENTO BANCÁRIO] - [IMPORTADO] -> Importação  linha: '+cLinha+', Pedido: '+cPedido+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				rRetornaBaixa := U_vRnBMovimento("id_linha="+cLinha+"&rep_valida="+oMovimento:validaBw+"&rep_nfe="+RTRIM(cTitulo)+"&val_sit=ok")
				MontjSZ('200',rRetornaBaixa,'A',clinha,'Importado com sucesso!',nY)
			EndIf
		next Ny
	EndIf
	//Caso ação for F, somente quando finaliza o repasse faz as transferencias
	If(cMotivo != "CVD" .AND. cAcao == 'AGRUPADO')
		//Insero uma lançamento agrupado no banco dos lançamentos acima
		U_VRN0159('[MOVIMENTO BANCÁRIO] - [INICIO PARTE B] -> Importação   - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
		aFINA100R := {}
		aFINA100R := { 	{"E5_DATA"      ,stod(oMovimento:dDtBaixa)					,Nil},;
			{"E5_VENCTO"    ,stod(oMovimento:dDtBaixa)					,Nil},;
			{"E5_MOEDA"    	,"M1"                     					,Nil},;
			{"E5_TIPODOC"   ,"DH"										,Nil},;
			{"E5_VALOR"    	,oMovimento:nValorReceber 					,Nil},;
			{"E5_NATUREZ"  	,oMovimento:natureza       					,Nil},;
			{"E5_FILIAL"    ,""											,Nil},;
			{"E5_BANCO"    	,oMovimento:banco_desc     					,Nil},;
			{"E5_BENEF"  	,"MOV. BCO"                 			 	,Nil},;
			{"E5_AGENCIA"  	,oMovimento:banco_agencia  					,Nil},;
			{"E5_CONTA"    	,oMovimento:banco_conta  					,Nil},;
			{"E5_PREFIXO"   ,oMovimento:prefixo         			 	,Nil},;
			{"E5_TIPO"    	,oMovimento:tipo            			 	,Nil},;
			{"E5_DOCUMEN"   ,oMovimento:nomeArq							,Nil},;
			{"E5_HISTOR"   	, "TOTAL DE DESPESAS "+oMovimento:nomeArq  	,Nil},;
			{"NCTBONLINE"   ,1                    						,Nil} }

		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100R,nProcessa2)
		If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
			cErro := TXTERRO(aAutoErro)
			U_VRN0159(cErro)
			U_VRN0159('[MOVIMENTO BANCÁRIO] - [ERRO B]  - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
			MontjSZ('400',"aFINA100R",'B',"",cErro,99998)
		Else
			U_VRN0159('[MOVIMENTO BANCÁRIO] - [IMPORTADO B]  - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
			MontjSZ('200',"aFINA100R",'B',"",'Importado com sucesso!',99998)
		EndIf

		//Insero uma lançamento agrupado no banco no banco bradesco
		U_VRN0159('[MOVIMENTO BANCÁRIO] - [INICIO PARTE C] -> Importação  - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
		aFINA100B := {}
		aFINA100B := { 	{"E5_DATA"    	,stod(oMovimento:dDtBaixa)					,Nil},;
			{"E5_VENCTO"    ,stod(oMovimento:dDtBaixa)					,Nil},;
			{"E5_MOEDA"    	,"M1"                     					,Nil},;
			{"E5_VALOR"    	,oMovimento:nValorReceber 					,Nil},;
			{"E5_TIPODOC"   ,"DH"										,Nil},;
			{"E5_NATUREZ"  	,oMovimento:natureza       					,Nil},;
			{"E5_BANCO"    	,"237"                    					,Nil},;
			{"E5_FILIAL"    ,""											,Nil},;
			{"E5_BENEF"  	,"MOV. BCO"                  				,Nil},;
			{"E5_AGENCIA"  	,"2693 "                  					,Nil},;
			{"E5_CONTA"    	,"84255     "             					,Nil},;
			{"E5_PREFIXO"   ,oMovimento:prefixo          				,Nil},;
			{"E5_TIPO"    	,oMovimento:tipo             				,Nil},;
			{"E5_DOCUMEN"   ,oMovimento:nomeArq							,Nil},;
			{"E5_HISTOR"   	, "TOTAL DE DESPESAS "+oMovimento:nomeArq 	,Nil},;
			{"NCTBONLINE"   ,1                    						,Nil} }
		//06051982 TERMINO CONTAS A RECEBER;
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100B,nProcessa1)
		If lMsErroAuto
			aAutoErro := GETAUTOGRLOG()
			cErro := TXTERRO(aAutoErro)
			U_VRN0159(cErro)
			U_VRN0159('[MOVIMENTO BANCÁRIO] - [ERRO C]  - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
			MontjSZ(400,"aFINA100B",'C',"",cErro,99999)
		Else
			U_VRN0159('[MOVIMENTO BANCÁRIO] - [IMPORTADO C]  - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
			MontjSZ("200","aFINA100B",'C',"",'Importado com sucesso!',99999)
		EndIf
	Endif


	IF lOkAT

		cBodyrT3 += '   }' + CRLF
		cBodyrT3 += '  ]' + CRLF
		cBodyrT3 += ' }' + CRLF
		cBodyrT3 += '}' + CRLF
		cBodyrT3 := FWNoAccent(cBodyrT3)
		::SetResponse(EncodeUtf8(cBodyrT3))

	ELSE

		cBodyrT3 += '{' + CRLF
		cBodyrT3 += ' "jsonrpc": "2.0",' + CRLF
		cBodyrT3 += ' "params": {' + CRLF
		cBodyrT3 += '   "data": [' + CRLF
		cBodyrT3 += '   {' + CRLF
		cBodyrT3 += '     "status": "' + "400" + '",' + CRLF
		cBodyrT3 += '     "msg": "' + "O json enviado não atende aos requisitos!" + '"' + CRLF
		cBodyrT3 += '   }' + CRLF
		cBodyrT3 += '  ]' + CRLF
		cBodyrT3 += ' }' + CRLF
		cBodyrT3 += '}' + CRLF
		cBodyrT3 := FWNoAccent(cBodyrT3)
		::SetResponse(EncodeUtf8(cBodyrT3))

	Endif

	U_VRN0159('[MOVIMENTO BANCÁRIO] - [FINALIZADO] -> '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
	U_VRN0159(EncodeUtf8(cBodyrT3))


Return .T.

// RETORNAR ERRO SEM MOSTRAR NA TELA;
Static Function TXTERRO(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1
	FOR nX := 1 to Len(aAutoErro)
		cRet += AllTrim(aAutoErro[nX])+CHR(13)+CHR(10)
	NEXT nX
RETURN cRet

// SALVAR RETORNO NO MYSQL;
user function vRnBMovimento(cParamGet)
	Local cUrl := "https://buddsp.buddemeyer.com.br/portal/ws/ws_movimento.php"
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local sPostRet := ""
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
	sPostRet := HttpPost(cUrl,cParamGet, "chave=vRna@06@05@1982",nTimeOut,aHeadOut,@cHeadRet)
	if !empty(sPostRet)
		U_VRN0159("Movimento Ok")
		varinfo("WebPage", sPostRet)
	else
		U_VRN0159("HttpPost Failed.")
		U_VRN0159("Movimento ERRO")
	Endif
Return sPostRet


//DANIEL VICTOR DA ROSA - PERSONALTEIC
//08/07/2025
Static Function MontjSZ(cCodEr,cRetApi,cprocesso,clinha,cMsgRet,nVZT)

	lOkAT := .T.

	IF EMPTY(cBodyrT3)
		cBodyrT3 += '{' + CRLF
		cBodyrT3 += ' "jsonrpc": "2.0",' + CRLF
		cBodyrT3 += ' "params": {' + CRLF
		cBodyrT3 += '   "data": [' + CRLF
		cBodyrT3 += '  {' + CRLF
		cBodyrT3 += '   "RetItens": [' + CRLF
		nVZT2 := Len(oMovimento:itens)
	ENDIF

	IF "Verifique as tags obrigatorias nao enviadas!!" <> cMsgRet

		IF nVZT2 <> nVZT .AND. nVZT <> 99999 .AND. nVZT <> 99998


			cBodyrT3 += '   {' + CRLF
			cBodyrT3 += '     "lac_linha": "' + clinha + '",' + CRLF
			cBodyrT3 += '     "lac_status": "' + cCodEr + '",' + CRLF
			cBodyrT3 += '     "lac_retorno_api": "' + cRetApi + '",' + CRLF
			cBodyrT3 += '     "lac_processo": "' + cprocesso + '",' + CRLF
			cBodyrT3 += '     "lac_msg_mov": "' + cMsgRet + '"' + CRLF
			cBodyrT3 += '   },' + CRLF

		elseif  nVZT == 99999 .OR. nVZT == 99998

			cBodyrT3 += '   "RetExec'+cRetApi+'"'+': [' + CRLF
			cBodyrT3 += '   {' + CRLF
			cBodyrT3 += '     "lac_status": "' + cCodEr + '",' + CRLF
			cBodyrT3 += '     "lac_retorno_api": "' + cRetApi + '",' + CRLF
			cBodyrT3 += '     "lac_processo": "' + cprocesso + '",' + CRLF
			cBodyrT3 += '     "lac_linha": "' + clinha + '",' + CRLF
			cBodyrT3 += '     "lac_msg_mov": "' + cMsgRet + '"' + CRLF
			cBodyrT3 += '   }' + CRLF

			IF nVZT <> 99999
				cBodyrT3 += '  ],' + CRLF
			ELSE
				cBodyrT3 += '  ]' + CRLF
			ENDIF

		ELSE

			cBodyrT3 += '   {' + CRLF
			cBodyrT3 += '     "lac_linha": "' + clinha + '",' + CRLF
			cBodyrT3 += '     "lac_status": "' + cCodEr + '",' + CRLF
			cBodyrT3 += '     "lac_retorno_api": "' + cRetApi + '",' + CRLF
			cBodyrT3 += '     "lac_processo": "' + cprocesso + '",' + CRLF
			cBodyrT3 += '     "lac_msg_mov": "' + cMsgRet + '"' + CRLF
			cBodyrT3 += '   }' + CRLF
			cBodyrT3 += '  ],' + CRLF

		ENDIF

	ELSE

		cBodyrT3 += '   "RetItens'+AllTrim(Str(nVZT)+'"')+': [' + CRLF
		cBodyrT3 += '   {' + CRLF
		cBodyrT3 += '     "lac_status": "' + cCodEr + '",' + CRLF
		cBodyrT3 += '     "lac_retorno_api": "' + cRetApi + '",' + CRLF
		cBodyrT3 += '     "lac_processo": "' + cprocesso + '",' + CRLF
		cBodyrT3 += '     "lac_linha": "' + clinha + '",' + CRLF
		cBodyrT3 += '     "lac_msg_mov": "' + cMsgRet + '"' + CRLF
		cBodyrT3 += '   }' + CRLF
		IF nVZT <> LEN(oBaixa:aDadosBaixa)
			cBodyrT3 += '  ],' + CRLF
		ELSE
			cBodyrT3 += '  ]' + CRLF
		ENDIF

	ENDIF

Return
