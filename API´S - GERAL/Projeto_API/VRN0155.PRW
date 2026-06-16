#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
/*
/=========================================================================\
| Mdulo      : Api Rest                                                   |
|=========================================================================|
| Programa    : VRN0155.PRW   | Responsvel: Cesar Grossl         		  |
|=========================================================================|
| Descricao   : Compensação Financeira	                                  |
|=========================================================================|
| Data        : 21/06/2023						                          |
|=========================================================================|
| Programador : 06051982 Cesar Grossl          	                          |
\=========================================================================/
*/

WSRESTFUL repcompensacaofin DESCRIPTION "Compensação Financeira, Repasses MKTP"

	WSMETHOD POST DESCRIPTION "Recebe variáveis pelo post" WSSYNTAX "/repcompensacaofin/ [ POST ]"

END WSRESTFUL

WSMETHOD POST WSSERVICE repcompensacaofin
	::SetContentType("application/json")
	//Rotina Compensação - CR - FINA330
	//Conforme documentação do TDN em 20-06-2023 -> https://tdn.totvs.com/display/public/PROT/FIN0023_CREC_Compensacao_receber_execauto

	Local cBody := ::GetContent()

	//Local oJson := JsonObject():New()
	Local aArea  := GetArea()
	Local nTaxaCM := 0
	Local lRetExe := .F.
	Local aTxMoeda := {}
	Local _nValor := 0
	Local cNfe := ""
	Local cValida := ""
	Local cNcc := ""
	Local lOkAA := .F.
	Local nJsoSe2  := 0
	Private nRecnoRA := 0
	Private nRecnoE1 := 0
	Private cBodyret := ""
	Private oComp

	U_VRN0159('[COMPENSAÇÃO] - [INICIO] - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
	FWJsonDeserialize(DecodeUTF8(cBody),@oComp)

	//FAZER UM FOR AQUI E RODAR TODOS OS INTENS DO JSON.
	FOR nJsoSe2 := 1 TO LEN(oComp:ADADOSCOM)

		lOkAA := .T.

		dDataBase := stod(oComp:ADADOSCOM[nJsoSe2]:dDtBaixa)
		cNfe := ALLTRIM(oComp:ADADOSCOM[nJsoSe2]:nfe)
		cValida := ALLTRIM(oComp:ADADOSCOM[nJsoSe2]:valida)
		nRecnoRA := oComp:ADADOSCOM[nJsoSe2]:nfe_recno
		cNcc := ALLTRIM(oComp:ADADOSCOM[nJsoSe2]:ncc)
		nRecnoE1 := oComp:ADADOSCOM[nJsoSe2]:ncc_recno
		_nValor := oComp:ADADOSCOM[nJsoSe2]:nfe_saldo


		IF EMPTY(dDataBase) .AND. EMPTY(cNfe) .AND. EMPTY(cValida)  .AND. EMPTY(nRecnoRA) .AND. EMPTY(cNcc) .AND. EMPTY(nRecnoE1) .AND. EMPTY(_nValor)
			MontJsRet("400",cNfe, "","Verifique as tags obrigatórias nao enviadas!!",nJsoSe2)
		ELSE

			If(nRecnoRA == 0 .AND. nRecnoE1 == 0)
				U_VRN0159('[COMPENSAÇÃO] - [ERRO RECNO EM BRANCO] - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				// oJson['status'] := "400"
				// oJson["titulo"] := cNfe
				// oJson['portal'] := ""
				// oJson['msg']	:= "Não identificado título ou ncc!"
				MontJsRet("400",cNfe, "","Não identificado título ou ncc!",nJsoSe2)
				//::SetResponse(EncodeUtf8(oJson:toJson()))
				//return
			EndIf

			PERGUNTE("FIN330",.F.)
			lContabiliza    := (MV_PAR09 == 1) // Contabiliza On Line ?
			lDigita         := (MV_PAR07 == 1) // Mostra Lanc Contab ?
			lAglutina       := .F.
			nTaxaCM := RecMoeda(dDataBase,"1")
			aAdd(aTxMoeda, {1, 1} )
			aAdd(aTxMoeda, {2, nTaxaCM} )
			DBSelectArea("SE1")
			SE1->(dbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_FORNECE+E1_LOJA
			SE1->(dbGoTo(nRecnoRA))
			SE1->(dbGoTo(nRecnoE1))
			aRecRA := { nRecnoRA }
			aRecSE1 := { nRecnoE1 }
			
			//DESCOMENTAR !!!!!!!
			//lRetExe := MaIntBxCR(3,aRecSE1,,aRecRA,,{.F.,.T.,.F.,.F.,.F.,.F.}, , , , , _nValor)

			If lRetExe
				U_VRN0159('[COMPENSAÇÃO] - [OK] - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				rComp := U_vCompensacao("rep_valida="+cValida+"&rep_nfe="+RTRIM(cNfe)+"&val_sit=ok")
				// oJson['status'] := "200"
				// oJson["titulo"] := cNfe
				// oJson['portal'] := rComp
				// oJson['msg']	:= "Compensação realizada com sucesso!"
				MontJsRet("200",cNfe, rComp ,"Compensação realizada com sucesso!",nJsoSe2)
			Else
				U_VRN0159('[COMPENSAÇÃO] - [ERRO 01] - '+Dtoc(MsDate()) + ' - '+ Time()+' ...')
				rComp := U_vCompensacao("rep_valida="+cValida+"&rep_nfe="+RTRIM(cNfe)+"&val_sit=erro")
				// oJson['status'] := "400"
				// oJson["titulo"] := cNfe
				// oJson['portal'] := rComp
				// oJson['msg']	:= cRetExe
				MontJsRet("400",cNfe, rComp,cRetExe,nJsoSe2)
			Endif
		Endif

	NEXT nJsoSe2

	IF lOkAA
		cBodyret += '  ]' + CRLF
		cBodyret += ' }' + CRLF
		cBodyret += '}' + CRLF
		::SetResponse(EncodeUtf8(cBodyret))
	ELSE
		cBodyret += '{' + CRLF
		cBodyret += ' "jsonrpc": "2.0",' + CRLF
		cBodyret += ' "params": {' + CRLF
		cBodyret += '   "data": [' + CRLF
		cBodyret += '   {' + CRLF
		cBodyret += '     "status": "' + "400" + '",' + CRLF
		cBodyret += '     "msg": "' + "O json enviado não atende aos requisitos!" + '"' + CRLF
		cBodyret += '   }' + CRLF
		cBodyret += '  ]' + CRLF
		cBodyret += ' }' + CRLF
		cBodyret += '}' + CRLF
		::SetResponse(EncodeUtf8(cBodyret))
	Endif

	RestArea(aArea)

Return .T.


// RETORNAR ERRO SEM MOSTRAR NA TELA;
Static Function TXTERRO(aAutoErro)
	LOCAL cRet := ""
	LOCAL nX := 1
	FOR nX := 1 to Len(aAutoErro)
		cRet += AllTrim(aAutoErro[nX])+CHR(13)+CHR(10)
	NEXT nX
RETURN cRet

//06051982 FUNÇÃO PARA SALVAR RETORNO NO MYSQL;
user function vCompensacao(cParamGet)
	Local cUrl := "https://buddsp.buddemeyer.com.br/portal/ws/ws_compensacao.php"
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
Static Function MontJsRet(cCodEr,cNfe,cPortal,cMsgRet,nSeqFr)

	IF EMPTY(cBodyret)
		cBodyret += '{' + CRLF
		cBodyret += ' "jsonrpc": "2.0",' + CRLF
		cBodyret += ' "params": {' + CRLF
		cBodyret += '   "data": [' + CRLF
	ENDIF

	cBodyret += '   {' + CRLF
	cBodyret += '     "status": "' + cCodEr + '",' + CRLF
	cBodyret += '     "titulo": "' + cNfe + '",' + CRLF
	cBodyret += '     "portal": "' + cPortal + '",' + CRLF
	cBodyret += '     "msg": "' + cMsgRet + '"' + CRLF
	IF nSeqFr <> LEN(oComp:ADADOSCOM)
		cBodyret += '   },' + CRLF
	ELSE
		cBodyret += '   }' + CRLF
	ENDIF

Return
