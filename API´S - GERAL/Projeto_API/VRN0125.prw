#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
/*
/=========================================================================\
| Módulo      : Api Rest                                                  |
|=========================================================================|
| Programa    : VRN0125.PRW   | Responsável: César Grossl          		  |
|=========================================================================|
| Descricao   : Baixa de Títulos 	                                      |
|=========================================================================|
| Data        : 16/08/2020 						                          |
|=========================================================================|
| Programador : César Grossl                 	                          |
\=========================================================================/
*/

WSRESTFUL repbaixafin DESCRIPTION "Baixa financeira"

	WSMETHOD POST DESCRIPTION "Recebe variáveis pelo post" WSSYNTAX "/repbaixafin/ [ POST ]"

END WSRESTFUL


WSMETHOD POST WSSERVICE repbaixafin

	::SetContentType("application/json")
	Local cBody            := ::GetContent()
	local cExiste          := ""
	Local oJson            := JsonObject():New()
	local cErroTitulo      := ""
	local cErroAcessorio   := ""
	Local lOkAT            := .F.
	Local nYCV             := 0
	Local nZYp             := 0
	Local lCont            := .T.
	Local nVZT             := 0
	Private cBodyrT2       := ""
	Private oBaixa         := ""
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private oRoot          := JsonObject():New()
	Private oParams        := JsonObject():New()
	Private aData98        := {} // Array ADVPL
	Private oMsg           := JsonObject():New()
	Private nVZT2          := 0

	FWJsonDeserialize(DecodeUTF8(cBody),@oBaixa)

	FOR nVZT := 1 TO LEN(oBaixa:aDadosBaixa)

		lOkAT := .T.
		cExiste     := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:vaExiste)
		natureza    := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:natureza)

		vaNumTit    := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:vaNumTit)
		validaBw    := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:validaBw)
		prefixo     := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:prefixo)
		tipo        := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:tipo)
		parcela     := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:parcela)
		cliente     := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:cliente)
		nValorSaldo := oBaixa:aDadosBaixa[nVZT]:nValorSaldo
		cBanco      := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:cBanco)
		cAgencia    := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:cAgencia)
		cConta      := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:cConta)
		dDtBaixa    := ALLTRIM(oBaixa:aDadosBaixa[nVZT]:dDtBaixa)

		for nZYp := 1 to Len(oBaixa:aDadosBaixa[nVZT]:itens)
			vaFkcCod   :=  AllTrim(oBaixa:aDadosBaixa[nVZT]:itens[nZYp]:vaFkcCodigo)
			vaVlrImp :=  oBaixa:aDadosBaixa[nVZT]:itens[nZYp]:vaVlrImp
			IF lCont
				IF !EMPTY(vaFkcCod) .AND. !EMPTY(vaVlrImp)
					lCont := .T.
				ELSE
					lCont := .F.
				ENDIF
			ENDIF
		next nZYp

		IF !EMPTY(vaNumTit) .AND. !EMPTY(validaBw) .AND. !EMPTY(prefixo) .AND. !EMPTY(tipo);
				.AND. !EMPTY(parcela) .AND. !EMPTY(cliente) .AND. !EMPTY(nValorSaldo) .AND. !EMPTY(cBanco);
				.AND. !EMPTY(cAgencia) .AND. !EMPTY(cConta) .AND. !EMPTY(dDtBaixa)


			U_VRN0159('[BAIXA] - [VALORES ACESSORIOS] -> Importação - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')

			IF cExiste == "S"

				SE1->(DBSETORDER(1))
				SE1->(dbgotop())
				IF SE1->(DBSEEK(xfilial("SE1")+oBaixa:aDadosBaixa[nVZT]:prefixo+oBaixa:aDadosBaixa[nVZT]:vaNumTit+oBaixa:aDadosBaixa[nVZT]:parcela+oBaixa:aDadosBaixa[nVZT]:tipo))

					DDATABASE := stod(oBaixa:aDadosBaixa[nVZT]:dDtBaixa)
					aArray := {}
					aAdd(aArray,{"E1_FILIAL", SE1->E1_FILIAL	, nil})
					aAdd(aArray,{"E1_PREFIXO", oBaixa:aDadosBaixa[nVZT]:prefixo	, nil})
					aAdd(aArray,{"E1_NUM", oBaixa:aDadosBaixa[nVZT]:vaNumTit		, nil})
					aAdd(aArray,{"E1_PARCELA", oBaixa:aDadosBaixa[nVZT]:parcela	, nil})
					aAdd(aArray,{"E1_TIPO", oBaixa:aDadosBaixa[nVZT]:tipo			, nil})
					U_VRN0159('[BAIXA] - [VALORES ACESSORIOS] -> Titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
					aVAAuto := {}
					oJson["titulo"] := oBaixa:aDadosBaixa[nVZT]:vaNumTit
					oJson["valores_acessorios"] := {}

					for nYCV := 1 to Len(oBaixa:aDadosBaixa[nVZT]:itens)
						oVa := JSonObject():New()
						oVa['va_codigo'] := oBaixa:aDadosBaixa[nVZT]:itens[nYCV]:vaFkcCodigo
						oVa['va_valor'] := oBaixa:aDadosBaixa[nVZT]:itens[nYCV]:vaVlrImp
						aAdd(oJson["valores_acessorios"] , oVa)
						aAdd(aVAAuto,{oBaixa:aDadosBaixa[nVZT]:itens[nYCV]:vaFkcCodigo,oBaixa:aDadosBaixa[nVZT]:itens[nYCV]:vaVlrImp})
					next nYCV

					lMsErroAuto := .F.
					lValidaVa   := .F.

					MsExecAuto( { |x,y,z,w,k,a,b,c| FINA040(x,y,,,,,,c)}, aArray, 4,,,,,,aVAAuto) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
					if lMsErroAuto
						aAutoErro := GETAUTOGRLOG()
						cErroAcessorio := TXTERRO(aAutoErro)
						U_VRN0159('[BAIXA] - [ERRO 01] -> Valores Acessórios Titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
						U_VRN0159(cErroAcessorio)
						// oJson['status'] :=
						// oJson['retorno_baixa'] 	:= ""
						// oJson['msg']	:= cErroAcessorio
						MontjSZ('400',oBaixa:aDadosBaixa[nVZT]:vaNumTit,cErroAcessorio,"FINA040",nVZT)
					else
						lValidaVa := .T.
						Sleep( 3000 )
						// oJson['status'] := '200'
						// oJson['retorno_baixa'] 	:= ""
						// oJson['msg']	:= 'Importado com sucesso'
						MontjSZ('200',oBaixa:aDadosBaixa[nVZT]:vaNumTit,"Sucesso","FINA040",nVZT)
					endif

				else
					rRetornaBaixa := U_vRnBBaixa("rep_valida="+oBaixa:aDadosBaixa[nVZT]:validaBw+"&rep_nfe="+RTRIM(oBaixa:aDadosBaixa[nVZT]:vaNumTit)+"&val_sit=erro")
					U_VRN0159('[BAIXA] - [ERRO 03] -> Titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+', Não encontrado - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				endif
			else
				lValidaVa := .T.
			endif
			//TERMINO ROTINA DE VALORES ACESSORIOS;
			//INICIO ROTINA DE BAIXA;
			If lValidaVa

				U_VRN0159('[BAIXA] -> Iniciando baixa titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+' - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				cErroTitulo := "";
					//06051982 VERIFICAR SE lValidaVa ESTA COMO T, SE PROCESSO ANTERIOR FOI FEITO;
				SA6->(DBSETORDER(1))
				SA6->(DBSEEK("  "+oBaixa:aDadosBaixa[nVZT]:cBanco+oBaixa:aDadosBaixa[nVZT]:cAgencia+" "+oBaixa:aDadosBaixa[nVZT]:cConta+"     ")) //VERIFICAR DEPOIS COMO ESTÁ ISSO.
				_aCabec := {}
				Aadd(_aCabec, {"E1_PREFIXO"  , oBaixa:aDadosBaixa[nVZT]:prefixo			, nil})
				Aadd(_aCabec, {"E1_NUM"      , oBaixa:aDadosBaixa[nVZT]:vaNumTit			, nil})
				Aadd(_aCabec, {"E1_PARCELA"  , oBaixa:aDadosBaixa[nVZT]:parcela			, nil})
				Aadd(_aCabec, {"E1_TIPO"     , oBaixa:aDadosBaixa[nVZT]:tipo				, nil})
				Aadd(_aCabec, {"E1_CLIENTE"  , oBaixa:aDadosBaixa[nVZT]:cliente			, nil})
				Aadd(_aCabec, {"AUTMOTBX"    , oBaixa:aDadosBaixa[nVZT]:mtxbaixa          , nil})
				aadd(_aCabec, {"AUTBANCO"    , oBaixa:aDadosBaixa[nVZT]:cBanco          	, nil})
				aadd(_aCabec, {"AUTAGENCIA"  , oBaixa:aDadosBaixa[nVZT]:cAgencia        	, nil})
				aadd(_aCabec, {"AUTCONTA"    , oBaixa:aDadosBaixa[nVZT]:cConta          	, nil})
				Aadd(_aCabec, {"AUTDTBAIXA"  , stod(oBaixa:aDadosBaixa[nVZT]:dDtBaixa) 	, nil})
				Aadd(_aCabec, {"AUTDTCREDITO", stod(oBaixa:aDadosBaixa[nVZT]:dDtBaixa)  	, nil})
				Aadd(_aCabec, {"AUTVALREC"   , oBaixa:aDadosBaixa[nVZT]:nValorSaldo     	, nil,.T.})
				Aadd(_aCabec, {"AUTDESCONT"  , 0                        , nil,.T.})
				Aadd(_aCabec, {"AUTDECRESC"  , 0                        , nil,.T.})
				Aadd(_aCabec, {"AUTACRESC"   , 0                        , nil,.T.})
				Aadd(_aCabec, {"AUTMULTA"    , 0                        , nil,.T.})
				Aadd(_aCabec, {"AUTJUROS"    , 0                        , nil,.T.})
				Aadd(_aCabec, {"AUTTXMOEDA"  , 0                        , nil,.T.})
				//Aadd(_aCabec, {"AUTVALREC"   , 0                        , nil,.T.})
				lMsErroAuto := .F.

				MSExecAuto({|x,y| fina070(x,y)},_aCabec,3) //06051982 3-INCLUSAO;
				if lMsErroAuto
					aAutoErro := GETAUTOGRLOG()
					cErroTitulo := TXTERRO(aAutoErro)
					U_VRN0159(cErroTitulo)
					U_VRN0159('[BAIXA] - [ERRO 04] -> Titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+', problema na baixa - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
					rRetornaBaixa := U_vRnBBaixa("rep_valida="+oBaixa:aDadosBaixa[nVZT]:validaBw+"&rep_nfe="+RTRIM(oBaixa:aDadosBaixa[nVZT]:vaNumTit)+"&val_sit=erro")
					// oJson['status'] 	:= "400"
					// oJson['retorno_baixa'] 	:= rRetornaBaixa
					// oJson['msg']		:= 'fina070 :'+cErroTitulo

					MontjSZ('400',oBaixa:aDadosBaixa[nVZT]:vaNumTit,rRetornaBaixa,'FINA070:'+cErroTitulo,nVZT)

				else
					rRetornaBaixa := U_vRnBBaixa("rep_valida="+oBaixa:aDadosBaixa[nVZT]:validaBw+"&rep_nfe="+RTRIM(oBaixa:aDadosBaixa[nVZT]:vaNumTit)+"&val_sit=ok")
					U_VRN0159('[BAIXA] - [BAIXOU] -> Titulo: '+oBaixa:aDadosBaixa[nVZT]:vaNumTit+'- '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
					// oJson['status'] 	:= "200"
					// oJson['retorno_baixa'] 	:= rRetornaBaixa
					// oJson['msg']		:= 'Importado com sucesso!'
					MontjSZ('200',oBaixa:aDadosBaixa[nVZT]:vaNumTit,rRetornaBaixa,'FINA070-Sucesso',nVZT)
				endif

			Endif

		ELSE
			MontjSZ("400",vaNumTit,"","Verifique as tags obrigatorias nao enviadas!!",nVZT)
		ENDIF

	NEXT nVZT

	IF lOkAT

		cBodyrT2 += '   }' + CRLF
		cBodyrT2 += '  ]' + CRLF
		cBodyrT2 += ' }' + CRLF
		cBodyrT2 += '}' + CRLF
		cBodyrT2 := FWNoAccent(cBodyrT2)
		::SetResponse(EncodeUtf8(cBodyrT2))

	ELSE

		cBodyrT2 += '{' + CRLF
		cBodyrT2 += ' "jsonrpc": "2.0",' + CRLF
		cBodyrT2 += ' "params": {' + CRLF
		cBodyrT2 += '   "data": [' + CRLF
		cBodyrT2 += '   {' + CRLF
		cBodyrT2 += '     "status": "' + "400" + '",' + CRLF
		cBodyrT2 += '     "msg": "' + "O json enviado não atende aos requisitos!" + '"' + CRLF
		cBodyrT2 += '   }' + CRLF
		cBodyrT2 += '  ]' + CRLF
		cBodyrT2 += ' }' + CRLF
		cBodyrT2 += '}' + CRLF
		cBodyrT2 := FWNoAccent(cBodyrT2)
		::SetResponse(EncodeUtf8(cBodyrT2))
		cteste := ""

	Endif

Return .T.

//06051982 FUNÇÃO PARA CAPTURAR ERROS;
Static Function TXTERRO(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1
	FOR nX := 1 to Len(aAutoErro)
		cRet += AllTrim(aAutoErro[nX])+CHR(13)+CHR(10)
	NEXT nX
RETURN cRet


//06051982 FUNÇÃO PARA SALVAR RETORNO NO MYSQL;
user function vRnBBaixa(cParamGet)
	Local cUrl := "https://buddsp.buddemeyer.com.br/portal/ws/ws_baixa.php"
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadRet := ""
	Local sPostRet := ""
	aadd(aHeadOut,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
	aadd(aHeadOut,'Content-Type: application/x-www-form-urlencoded')
	sPostRet := HttpPost(cUrl,cParamGet, "chave=vRna@06@05@1982",nTimeOut,aHeadOut,@cHeadRet)
	if !empty(sPostRet)
		U_VRN0159("Retorno WS - Ok")
		varinfo("WebPage", sPostRet)
	else
		U_VRN0159("HttpPost Failed.")
		U_VRN0159("Retorno WS - ERRO")
	Endif
Return sPostRet

//DANIEL VICTOR DA ROSA - PERSONALTEIC
//08/07/2025
Static Function MontjSZ(cCodEr,ctitulo,cRetBaix,cMsgRet,nVZT)

	IF EMPTY(cBodyrT2)
		cBodyrT2 += '{' + CRLF
		cBodyrT2 += ' "jsonrpc": "2.0",' + CRLF
		cBodyrT2 += ' "params": {' + CRLF
		cBodyrT2 += '   "data": [' + CRLF
		cBodyrT2 += '  {' + CRLF
	ENDIF

	IF "Verifique as tags obrigatorias nao enviadas!!" <> cMsgRet

		IF nVZT2 <> nVZT
			cBodyrT2 += '   "RetItens'+AllTrim(Str(nVZT)+'"')+': [' + CRLF
			cBodyrT2 += '   {' + CRLF
			cBodyrT2 += '     "status": "' + cCodEr + '",' + CRLF
			cBodyrT2 += '     "vaNumTit": "' + ctitulo + '",' + CRLF
			cBodyrT2 += '     "RetBaixa": "' + cRetBaix + '",' + CRLF
			cBodyrT2 += '     "msg": "' + cMsgRet + '"' + CRLF
			cBodyrT2 += '   },' + CRLF
		ELSE
			cBodyrT2 += '   {' + CRLF
			cBodyrT2 += '     "status": "' + cCodEr + '",' + CRLF
			cBodyrT2 += '     "vaNumTit": "' + ctitulo + '",' + CRLF
			cBodyrT2 += '     "RetBaixa": "' + cRetBaix + '",' + CRLF
			cBodyrT2 += '     "msg": "' + cMsgRet + '"' + CRLF
			cBodyrT2 += '   }' + CRLF
			IF nVZT <> LEN(oBaixa:aDadosBaixa)
				cBodyrT2 += '  ],' + CRLF
			ELSE
				cBodyrT2 += '  ]' + CRLF
			ENDIF
		ENDIF

		nVZT2 := nVZT
	ELSE

		cBodyrT2 += '   "RetItens'+AllTrim(Str(nVZT)+'"')+': [' + CRLF
		cBodyrT2 += '   {' + CRLF
		cBodyrT2 += '     "status": "' + cCodEr + '",' + CRLF
		cBodyrT2 += '     "vaNumTit": "' + ctitulo + '",' + CRLF
		cBodyrT2 += '     "RetBaixa": "' + cRetBaix + '",' + CRLF
		cBodyrT2 += '     "msg": "' + cMsgRet + '"' + CRLF
		cBodyrT2 += '   }' + CRLF
		IF nVZT <> LEN(oBaixa:aDadosBaixa)
			cBodyrT2 += '  ],' + CRLF
		ELSE
			cBodyrT2 += '  ]' + CRLF
		ENDIF

	ENDIF

Return
