#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
/=========================================================================\
| Execução    : Execução da rotina via schedule                           |
|=========================================================================|
| Programa    : VRN0160.PRW   | Responsável: Gabriel Araujo | Cesar Gross |
|=========================================================================|
| Descricao   : Varejo Facil, Importação de cupons fiscais                |
|=========================================================================|
| Data        : 10/2023	     					                          |
|=========================================================================|
| Programador : 06051982 Cesar Grossl  		                              |
\=========================================================================/

ID Loja 3 Donato | 1 Rio Negro | 2 Tijuco
*/

User Function VRN0160(cIDVenda, aRet, lApi)

	DEFAULT cIDVenda := NIL
	DEFAULT lApi := .f.
	DEFAULT aRet := array(2)

	U_VRN0159("cIDVenda "+ cvaltochar(cIDVenda)+funname())
	aRet :=  array(2)

	VRN0160B(cIDVenda,@aRet,.t., lApi)

Return .T.

Static Function VRN0160B(cIDVnd,aRet,lPrcCan, lApip)
	DEFAULT cIDVnd := NIL
	DEFAULT lApip := .f.
	DEFAULT aRet := NIL
	DEFAULT lPrcCan := .f.
	lReproc := .f.
	U_VRN0159("cIDVnd "+ cvaltochar(cIDVnd)+funname())
	//Processo de importação de cupons fiscais!
	Local  cParam1  := "MV_VFDTPRC" // data do ulktimlo processamento
	Local  cParam2  := "MV_VFIDPRC" // id do ultimo processamento
	Local cStPrc    := "3"          // status de processado  e disponivel para o gravabatch
	Local cStInPrc  := "1"          // status de em processamento
	Local cSt701    := "2"          // chamou o execauto
	Local cStIni    := "0"          // Iniciando
	Local cStER     := "E"          // ERRO
	Local cStCan    := "C"          // ERRO
	Local cEmpresa  :=  NIL         //supergetmv("MV_VFIDLJ",.F.,"3")
	Local nIdx
	Local nVendaIdx
	Local cEndPoint :=  NIL         //SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local oCupons   := JsonObject():New()
	Local cParser   := ""
	Local cCliPad   := NIL
	Local cLojPad   := NIL
	Local cVendPad  := NIL
	Local cTiposDoc := NIL          // AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	Local cSLGEst   := NIL          // supergetmv("MV_ZCDSLG",.F.,"004")  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	Local cOpera    := NIL          //supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	Local cArmVnd   := NIL          //supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA
	Local oCuponsFiscais :=  NIL
	Local nSl4     := 0
	Local nParc    := 0
	Local nForRS   := 0.00
	Local nForNCC  := 0.00
	Local nForCC   := 0.00
	Local nForOut  := 0.00
	Local nTotICMS := 0.00
	Local nERR     := 0
	Local i, cbandeiraLocal := "", credeAdquirenteLocal := ""
	Local aFinalizacoes := Nil
	Local lCancel  := .F.
	Local cAlias   := GetNextAlias()
	Local cEol     := chr(10)

	Private lMsErroAuto     := .F.  //Variavel que informa a ocorrência de erros no ExecAuto
	private lAutoErrNoFile  := .T.

	cEmpresa     := supergetmv("MV_VFIDLJ",.F.,"3",cFilAnt)
	cEndPoint    := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	cCliPad      := PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	cLojPad      := PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	cVendPad     := PADR(alltrim( SuperGetMV("MV_VENDPAD",.F.,"",cFilAnt)),getsx3cache("LQ_VEND","X3_TAMANHO"))
	cTiposDoc 	 := AllTrim( SuperGetMv( 'MV_ESPECIE' ,.f.,,cFilAnt) )
	cSLGEst      := supergetmv("MV_ZCDSLG",.F.,IIF(cEmpAnt =="14","003","004"),cFilAnt)  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	cOpera       := supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"),cFilAnt)  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	cArmVnd      := supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETRO PARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA

	If lApip
		BeginSQL alias cAlias
			SELECT
				TOP 1 CONVERT(VARCHAR(MAX), CONVERT(VARBINARY(MAX), ZV1_JSON)) AS ZV1_JSON
			FROM
				ZV1140(NOLOCK)
			WHERE
				ZV1_FILIAL = %xfilial:ZV1%
				AND CAST(ZV1_IDVEND AS INT) = %exp:cIDVnd%
				AND D_E_L_E_T_ = ''
		EndSQL
		(cAlias)->(dbGoTop())
		While (cAlias)->(!Eof())
			oCuponsFiscais := ALLTRIM((cAlias)->ZV1_JSON)
			cParser := oCupons:FromJson(oCuponsFiscais)
			aFinalizacoes := oCupons:GetJSonObject("finalizacoes")
			// Iterar sobre o array para capturar os campos desejados
			For i := 1 To Len(aFinalizacoes)
				credeAdquirenteLocal := aFinalizacoes[i]:GetJSonObject("redeAdquirente")
				cbandeiraLocal := aFinalizacoes[i]:GetJSonObject("bandeira")
			Next
			(cAlias)->(dbSkip())
		EndDo
		If SELECT(cAlias) > 0
			(cAlias)->(dbCloseArea())
		EndIf
	EndIf

	oCuponsFiscais := BuscaCupons(cEmpresa, cEndPoint,cIDVnd)
	cParser := oCupons:FromJson(oCuponsFiscais)
	aItenJson := oCupons:GetJSonObject('items')

	chkfile("ZV1")
	aAdmin := fGetAdm()

	U_VRN0159("VRN0160B - Inicio Processamento itens")

	If valtype(aItenJson) != "A"
		oCuponsFiscais :='{"items":['+oCuponsFiscais+']}'
		oCupons:FromJson(oCuponsFiscais)
		aItenJson := oCupons:GetJSonObject('items')
	EndIf
	For nIdx := 1 To Len(aItenJson)
		lProc    := .t.
		lUseNFCE := .F.
		cSerChv  := ""
		/*Cabeçalho do cupom,  SL1*/
		cChvNfce    := aItenJson[nIdx]['chaveEletronica']
		U_VRN0159("[IMP SL1] - Inicio, Cabecalho Cupons")
		/*PESQUISO A SERIE CONFORME CADASTRO DE ESTAÇÕES TABELA SLG LG_SERIE*/
		DbSelectArea("SLG")
		SLG->(DbSetOrder(1))
		If SLG->(DbSeek(xFilial("SLG")+padr(cSLGEst,getsx3cache("LG_CODIGO","X3_TAMANHO"))))
			cSerie   := SLG->LG_SERIE
			cPdv     := SLG->LG_PDV
			cSerSat  := SLG->LG_SERSAT
			lUseSAT  := SLG->LG_USESAT
			lUseNFCE := SLG->LG_NFCE
		endif
		if  lUseNFCE // caso seja SAT Busca a Chave da SLG (SAT  tem a serie do equipamento)
			cDocCHV   :=  PADR(padl(cvaltochar(Val(SubStr(cChvNfce,29,6))),6,'0'),9) //PADR(padl(cvaltochar(aItenJson[nIdx]['coo']),6,'0'),9)
			cSerChv   := PADR(cvaltochar(Val(SubStr( cChvNfce,23,3)))	,3)	// Série da nota conforme manual Nota Fiscal Eletrônica
		elseif lUseSAT
			cDocCHV   :=   PADR(padl(cvaltochar(Val(SubStr(cChvNfce,32,6))),6,'0'),9)
			cSerChv   := SLG->LG_SERIE
		endif
		dDataVnd    := stod(STRTRAN(SUBSTR(aItenJson[nIdx]['data'],1,10), "-", ""))
		dDatabase   := dDataVnd
		/*Caso a serie esteja em branco nao processa as vendas*/
		IF  alltrim(aItenJson[nIdx]['statusXMLNota']) =="PENDENTE"
			aParZV1:= {;
				aItenJson[nIdx]['identificadorId'],;
				cDocCHV,;
				cSerChv,;
				cPdv   ,;
				dDataVnd}
			fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.

			U_VRN0159("[IMP SL1] -VENDA NAO AUTORIZADA ")
			lProc := .f.
			loop
		ENDIF

		nValor      := aItenJson[nIdx]['valor']
		nVlrDesc    := aItenJson[nIdx]['desconto']
		cCgcCli     := aItenJson[nIdx]['valcpfConsumidoror']
		cSerie      := ""
		cHrVend     := substr(aItenJson[nIdx]['dataHoraFechamentoCupom'],12,8)
		cHrTEF      := StrTran( substr(aItenJson[nIdx]['dataHoraFechamentoCupom'],12,8),":","")

		//DEFINE A SERIE DO DOCUMENTO
		cEspecie := LjNfEspeci(cSerChv, cTiposDoc)
		/*Caso a serie esteja em branco nao processa as vendas*/
		IF EMPTY(cSerChv)
			U_VRN0159("[IMP SL1] - Sem cadastro de estação ou Serie em branco ")
			lProc := .f.
			loop
		ENDIF
		nPosID := 1
		nPosDoc := 2
		nPosSer := 3
		nPosDtVd := 5
		nPosSLG := 4
		cStatus := "0"
		U_VRN0159("DOC "+cDocCHV+" | Serie "+cSerChv+" | PDV "+cPdv)
		if alltrim(cDocCHV)=="000000"

			U_VRN0159("identificadorId  "+cvaltochar( aItenJson[nIdx]['identificadorId']))
		endif
		aParZV1:= {;
			aItenJson[nIdx]['identificadorId'],;
			cDocCHV,;
			cSerChv,;
			cPdv   ,;
			dDataVnd}

		ZV1->(DbSetOrder(1))
		If !ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aItenJson[nIdx]['identificadorId'],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
			fPutZV1(.t.,aParZV1,cStIni,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"
		else
			lReproc := .t.
		endif


		lCancel := .F.
		if alltrim(aItenJson[nIdx]['statusXMLNota']) =="CANCELADA" .AND. !lPrcCan
			U_VRN0159("CANCELADA DOC "+cDocCHV+" | Serie "+cSerChv+" | PDV "+cPdv)
			fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.
			lCancel := .T.
			IF Valtype(aRet) == "A"
				aRet[1] := 404
				aRet[2] := "Venda Cancelada "
			ENDIF
		ENDIF

		if aItenJson[nIdx]['cancelada'] .AND. !lPrcCan
			U_VRN0159("CANCELADA DOC 2 "+cDocCHV+" | Serie "+cSerChv+" | PDV "+cPdv)
			//   lProc := .f.
			fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.
			IF Valtype(aRet) == "A"
				aRet[1] := 404
				aRet[2] := "Venda Cancelada "
			ENDIF
			//loop
		ENDIF

		U_VRN0159("Valida se ja existe")
		//***********************************
		// Monta cabeçalho do orçamento (SLQ)
		//***********************************

		/*1 ) ProcuRa se a venda ja ´se encontra na SL1 para nao ter chave duplicada
            Caso encontre nao processa porem valida o SL1 lL1_SITUA PARA ATUALIZAÇÃO DA TABELA DE CONTROLE
		*/
		DbSelectArea("SL1")
		SL1->(DbSetOrder(2)) //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV, R_E_C_N_O_, D_E_L_E_T_
		IF  SL1->(MsSeek(xFilial("SL1")+cSerChv+cDocCHV+cPdv))
			U_VRN0159("Venda Ja existe "+ SL1->L1_SITUA)
			U_VRN0159("lReproc "+CVALTOCHAR(lReproc))
			fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['data'],1,10))
			fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['identificadorId']))
			if SL1->L1_SITUA == "OK"
				if aItenJson[nIdx]['cancelada']
					fPutZV1(.f.,aParZV1,cStPrc,aItenJson[nIdx],.T.)     //cStPrc := "3 - PROCESSADO"
				ELSE
					fPutZV1(.f.,aParZV1,cStPrc,aItenJson[nIdx])     //cStPrc := "3 - PROCESSADO"
				ENDIF
				IF Valtype(aRet) == "A"
					aRet[1] := 202
					aRet[2] := "Venda Já Processada "
				ENDIF
			ELSEIF  SL1->L1_SITUA  == "RX"
				fPutZV1(.f.,aParZV1,cSt701,aItenJson[nIdx])     //cSt701 := "2 - CHAMOU EXECAUTO"
				IF Valtype(aRet) == "A"
					aRet[1] := 201
					aRet[2] := "Aguardando Processamento do Gravabatch
				ENDIF
			ELSEIF  SL1->L1_SITUA  == "ER"
				cMsgerr :=    "  Erro no Processamento do Gravabatch "+ cEol
				fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx],,cMsgerr)      //cStER  := "E" - ERRO
				IF Valtype(aRet) == "A"
					aRet[1] := 414
					aRet[2] := "Erro no Processamento.Venda com erro no Gravabatch "
				ENDIF
			endif
			U_VRN0159("[IMP SL1] - DOCUMENTO JA IMPORTADO ")
			loop
		ENDIF

		DbSelectArea("SA1")
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(MsSeek(xFilial("SA1")+cCliPad+cLojPad))
		cTipoCli := SA1->A1_TIPO
		_aCab := {}
		cVendPad := "000001"
		nTotICMS := 0.00

		aAdd( _aCab, {"LQ_CLIENTE", cCliPad	 , NIL} )
		aAdd( _aCab, {"LQ_LOJA",    cLojPad	 , NIL} )
		aAdd( _aCab, {"LQ_NOMCLI",    SA1->A1_NOME	 , NIL} )
		aAdd( _aCab, {"LQ_VEND"     , cVendPad    , NIL} )
		aAdd( _aCab, {"LQ_OPERADO", cOpera	 , NIL} )
		aAdd( _aCab, {"LQ_EMISSAO", dDataVnd	 , NIL} )
		aAdd( _aCab, {"LQ_HORA",    cHrVend	 , NIL} )
		aAdd( _aCab, {"LQ_EMISNF",  dDataVnd	 , NIL} )
		aAdd( _aCab, {"LQ_DTLIM",  dDataVnd 	 , NIL} )
		aAdd( _aCab, {"LQ_NUMMOV",  ""	 , NIL} ) //verificar
		aAdd( _aCab, {"LQ_NUMCFIS", cDocCHV	 , NIL} )
		aAdd( _aCab, {"LQ_DOC",  cDocCHV   	 , NIL} )
		aAdd( _aCab, {"LQ_SERIE", cSerChv   	 , NIL} )
		aAdd( _aCab, {"LQ_SERPDV", "0" 	 , NIL} )
		aAdd( _aCab, {"LQ_SERSAT",  cSerSat	 , NIL} )
		aAdd( _aCab, {"LQ_KEYNFCE", cChvNfce	 , NIL} )
		aAdd( _aCab, {"LQ_COMIS",   0.00	 , NIL} )
		aAdd( _aCab, {"LQ_VLRTOT",  nValor	+nVlrDesc , NIL} )
		aAdd( _aCab, {"LQ_VALBRUT", nValor		+nVlrDesc , NIL} )
		aAdd( _aCab, {"LQ_VLRLIQ",  nValor	 	+nVlrDesc, NIL} )
		aAdd( _aCab, {"LQ_VALMERC", nValor		+nVlrDesc , NIL} )
		aAdd( _aCab, {"LQ_DESCONT", nVlrDesc	 , NIL} )
		aAdd( _aCab, {"LQ_DESPESA", 0.00	 , NIL} )
		aAdd( _aCab, {"LQ_FRETE",   0.00	 , NIL} )
		aAdd( _aCab, {"LQ_SEGURO",  0.00	 , NIL} )
		aAdd( _aCab, {"LQ_ORIGEM", "N" 	 , NIL} )
		aAdd( _aCab, {"LQ_CGCCLI",  cCgcCli	 , NIL} )
		aAdd( _aCab, {"LQ_CONDPG",  "001"	 , NIL} )
		aAdd( _aCab, {"LQ_SITUA",   "IP"	 , NIL} )
		aAdd( _aCab, {"LQ_TIPO",    "V"	 , NIL} )
		aAdd( _aCab, {"LQ_TIPOCLI", cTipoCli	 , NIL} )
		aAdd( _aCab, {"LQ_ESPECIE", cEspecie	 , NIL} )
		aAdd( _aCab, {"LQ_PDV",     cPdv	 , NIL} )
		aAdd( _aCab, {"LQ_ESTACAO", cSLGEst	 , NIL} )
		aAdd( _aCab, {"LQ_INDPRES", ""	 , NIL} )
		If lCancel
			aAdd( _aCab, {"LQ_STORC", "C"	 , NIL} )
		EndIf
		aAdd( _aCab, {"LQ_TROCO1",  0.00	 , NIL} )

		/*Itens do cupon, SL2*/
		U_VRN0159("[IMP SL2] - Inicio, Itens Cupons")
		aVendas := aItenJson[nIdx]['itensVenda']
		aSl2 := {}
		cIdVenda :=     aItenJson[nIdx]['id']
		oImpVend:= fGetImp(cIdVenda)
		U_VRN0159("[IMP SL2] - Inicio, Itens Cupons")
		For nVendaIdx := 1 To Len(aVendas)

			/*TRATATIVA PARA QUANDO ITEM ESTA BLOQUEADO*/
			IF VALTYPE(aVendas[nVendaIdx]['tipo']) !="U"
				IF aVendas[nVendaIdx]['tipo']=="2"
					loop
				ENDIF
			ENDIF

			/*BUSCA DO CODIGO DE PRODUTO*/
			aRetPrd := fGetPrd(aVendas[nVendaIdx]['produtoId'])
			DbSelectArea("SB1")
			SB1->(DbSetOrder(aRetPrd[2])) // B1_FILIAL + B1_CODBAR
			If !SB1->(DbSeek(xFilial("SB1")+aRetPrd[1] ))
				lProc := .f.
				cMsgerr :=    "  Produto Não Encontrado "+ cEol
				cMsgerr +="produtoId: "+cvaltochar(aVendas[nVendaIdx]['produtoId']) + cEol
				U_VRN0159("[IMP SL1] -Produto Não Encontrado ")
				fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx],,cMsgerr)  //cStER  := "E" - ERRO
				if !lReproc
					fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['data'],1,10))
					fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['identificadorId']))
				endif
				IF Valtype(aRet) == "A"
					aRet[1] := 412
					aRet[2] := "Erro no Processamento. Produto nao encontrado "+cvaltochar(aVendas[nVendaIdx]['produtoId'])
				ENDIF
				loop
			ENDIF

			_aItem :={}
			nQtdVen  := aVendas[nVendaIdx]['quantidadeVenda']
			nVlrUni  := aVendas[nVendaIdx]['valorUnidade']
			nVlrTot  := aVendas[nVendaIdx]['valorTotal']
			nVlrTab  := aVendas[nVendaIdx]['precoVenda']
			nVlrDesc := aVendas[nVendaIdx]['valorDesconto']
			cCSTPis  := aVendas[nVendaIdx]['cstPIS']
			cCSTCof  := aVendas[nVendaIdx]['cstCOFINS']
			vAliqICM := aVendas[nVendaIdx]['tributacaoAliquota']
			vAliqPis := aVendas[nVendaIdx]['aliquotaPIS']
			vAliqCof := aVendas[nVendaIdx]['aliquotaCOFINS']
			vAliqFec := aVendas[nVendaIdx]['tributacaoAliquotaFecop']
			vFecop   := oImpVend['items'][nVendaIdx]['valorFecop']
			vBSICMS  := oImpVend['items'][nVendaIdx]['baseCalculoIcms']
			vBSPCOF  := oImpVend['items'][nVendaIdx]['baseCalculoPisCofins']
			nVlIcms  := ROUND(vBSICMS*(vAliqICM/100),GETSX3CACHE("LR_VALICM","X3_DECIMAL"))
			cCFOP    := aVendas[nVendaIdx]['cfop']
			nTotICMS += nVlIcms
			if ((vBSICMS-nVlIcms) - vBSPCOF) < 1
				vBSPCOF  :=(vBSICMS-nVlIcms)
			endif
			nVlPis := ROUND(vBSPCOF*(vAliqPis/100),GETSX3CACHE("LR_VALPS2","X3_DECIMAL") )
			nVlCof := ROUND(vBSPCOF*(vAliqCof/100),GETSX3CACHE("LR_VALCF2","X3_DECIMAL"))
			// DbSelectArea("SB2")
			// SB2->(DbSetOrder(1))
			// If  !( SB2->(DbSeek( xfilial("SL2")+  SB1->B1_COD +cArmVnd)))
			// 	nOldMod := nModulo // 05
			// 	cOldMod := cModulo // FAT
			// 	nModulo := 04
			// 	cModulo := "EST"
			// 	criaSB2(SB1->B1_COD , cArmVnd)
			// 	nModulo :=	nOldMod
			// 	cModulo :=	cOldMod
			// endif
			//  criaSB2(SB1->B1_COD , "01")
			aAdd( _aItem, {"LR_FILIAL",  xfilial("SL2")	, nil})	                                        //         "01",
			aAdd( _aItem, {"LR_ITEM",   STRZERO( nVendaIdx,GETSX3CACHE("L2_ITEM","X3_TAMANHO"))	, nil})	//       "01",
			aAdd( _aItem, {"LR_PRODUTO",  SB1->B1_COD 	, .F.})	                                        //          "F43215170010110112",
			aAdd( _aItem, {"LR_POSIPI",  SB1->B1_POSIPI	, nil})	                                        //         "63026000",
			aAdd( _aItem, {"LR_DESCRI",  SB1->B1_DESC	, nil})	                                        //         "TOALHA ROSTO TUTTI DUAL AIR 4880 COR 1011",
			aAdd( _aItem, {"LR_QUANT",   nQtdVen	, nil})	                                            //        2,
			aAdd( _aItem, {"LR_VRUNIT",  nVlrUni	, nil})	                                            //         36.9,
			aAdd( _aItem, {"LR_PRCTAB",  nVlrTab	, nil})	                                            //         45.9,
			aAdd( _aItem, {"LR_VLRITEM", nVlrTot	, nil})	                                            //          73.8,
			aAdd( _aItem, {"LR_LOCAL",   cArmVnd	, nil})	                                            //        "01",
			aAdd( _aItem, {"LR_UM",      SB1->B1_UM 	, nil})	                                        //     "PC",
			aAdd( _aItem, {"LR_VALDESC", nVlrDesc	, nil})	                                            //          18,
			aAdd( _aItem, {"LR_DESCPRO", 0.00	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_DESPESA",0.00 	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_VALIPI",0.00 	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_TES",   SB1->B1_TS   	, nil})	                                        //      "501",
			aAdd( _aItem, {"LR_DOC",   cDocCHV  	, nil})	                                                //      "002502",
			aAdd( _aItem, {"LR_SERIE",   cSerChv	, nil})	                                                //        "613",
			aAdd( _aItem, {"LR_ESPECIE", cEspecie 	, nil})	                                            //          "SATCE",
			aAdd( _aItem, {"LR_EMISSAO", dDataVnd	, nil})	                                            //          "20231021",
			aAdd( _aItem, {"LR_VEND",cVendPad    	, nil})	                                            //       "0251  ",
			aAdd( _aItem, {"LR_CF",   cCFOP   	, nil})	                                                //     "5102",
			aAdd( _aItem, {"LR_MODBC",    "0"	, nil})	                                                //        "0",
			aAdd( _aItem, {"LR_ORIGEM",  SB1->B1_ORIGEM	, nil})	                                        //         "1",
			aAdd( _aItem, {"LR_CSTPIS",  cCSTPis	, nil})	                                            //         "01",
			aAdd( _aItem, {"LR_CSTCOF",  cCSTCof	, nil})	                                            //         "01",
			//aAdd( _aItem, {"LR_VALCOFI", 0.00	, nil})	                                                //          0,
			IF nVlPis >0
				aAdd( _aItem, {"LR_BASEPS2",vBSPCOF	, nil})	                                                 //          0,
				aAdd( _aItem, {"LR_ALIQPS2", vAliqPis	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_VALPS2",nVlPis	, nil})
			ENDIF
			IF nVlCof >0.00
				aAdd( _aItem, {"LR_BASECF2",vBSPCOF	, nil})	                                                 //          0,
				aAdd( _aItem, {"LR_ALIQCF2", vAliqCof	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_VALCF2",nVlCof	, nil})
			ENDIF
			IF nVlIcms >0
				aAdd( _aItem, {"LR_BASEICM", vBSICMS	, nil})	                                                //         0,
				aAdd( _aItem, {"LR_PICM", vAliqICM	, nil})
				aAdd( _aItem, {"LR_VALICM",nVlIcms	, nil})
			ENDIF
			aAdd( _aItem, {"LR_ALQFECP", vAliqFec	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_VALFECP", vFecop	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_ALQFCST", 0.00	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_VFECPST", 0.00	, nil})	                                                //          0,
			aAdd( _aItem, {"LR_PREDIC",  0.00	, nil})	                                                //         0

			aadd(aSl2,_aItem)

		Next nVendaIdx

		/*formas de pagamento, SL4*/
		U_VRN0159("[IMP SL4] - Inicio, Formas de Pagamento Cupons")
		aFinalizacoes := aItenJson[nIdx]['finalizacoes']
		aSl4 := {}

		For nSl4 := 1 To Len(aFinalizacoes)
			nvalor := aFinalizacoes[nSl4]['valor']
			nQtdpar := VAL(aFinalizacoes[nSl4]['quantidadeParcelas'])
			cFormPg :=Posicione("SX5",1,xFilial("SX5")+"Z2"+CVALTOCHAR(aFinalizacoes[nSl4]['finalizadoraId']),"X5_DESCRI")

			cAdmDesc := CRIAVAR("L4_ADMINIS")
			cNsu    := CRIAVAR("L4_NSUTEF")
			cCdBan  := CRIAVAR("L4_BANDEIR")
			cCdRede := CRIAVAR("L4_REDEAUT")
			// cCdRede := CRIAVAR("L4_REDEAUT")
			// cCdRede := CRIAVAR("L4_REDEAUT")
			if aFinalizacoes[nSl4]['finalizadoraId'] == 1 //DINHEIRO
				nForRS += nvalor
				if (!empty(aFinalizacoes[nSl4]['troco']))
					nvalor -=  aFinalizacoes[nSl4]['troco']
				EndIf
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 2   //CARTAO CREDITO
				nForCC +=nvalor
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 3 .or. aFinalizacoes[nSl4]['finalizadoraId'] == 5  //CARTAO DEBITO
				nForCC +=nvalor
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 4   //POS 1X
				nForCC +=nvalor
				nQtdpar := 1
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 7   //POS 2X
				nForCC +=nvalor
				nQtdpar := 2
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 8   //POS 3X
				nForCC +=nvalor
				nQtdpar := 3
			elseif aFinalizacoes[nSl4]['finalizadoraId'] == 100  //CREDITO
				nForNCC +=nvalor
			ELSE
				nForOut +=nvalor
			ENDIF
			//MDE0603	MDE_FILIAL, MDE_TIPO, MDE_CODSIT, R_E_C_N_O_, D_E_L_E_T_
			IF ALLTRIM(cFormPg) $ "CD_CC"

				cCdBan  := aFinalizacoes[nSl4]['bandeira']
				cCdRede := aFinalizacoes[nSl4]['redeAdquirente']

				If lApip
					cCdBan  := cbandeiraLocal
					cCdRede := credeAdquirenteLocal
				EndIf

				if aFinalizacoes[nSl4]['finalizadoraId'] == 4
					// cCdBan  := "00002"
					//cCdRede := "00005"
					//**************************
					// cCdBan  := "00004"
					//cCdRede := "00005"
				EndIf

				if ALLTRIM(cCdRede) $ "00004_00008_00006_00005_00000" //tratativa para quando a venda foi paga via POS
					cCdRede := "00005"
					if cCdBan == "00033"
						cCdBan := "00031"
					endif
					if cCdBan == "0000," .AND. ALLTRIM(cDocCHV) =="003718"
						cCdBan := "00001"
					endif
					if cCdBan == "00000" .AND. ALLTRIM(cDocCHV) $ "000025_000613_000107_000108"
						cCdBan := "00001"
					endif

				endif
				cMDEBan  := Posicione("MDE",3,xFilial("MDE")+ALLTRIM(cFormPg)+cCdBan,"MDE_CODIGO")
				cMDEDsBan  := Posicione("MDE",3,xFilial("MDE")+ALLTRIM(cFormPg)+cCdBan,"MDE_CODIGO")
				cMDERede := Posicione("MDE",3,xFilial("MDE")+padr(ALLTRIM("RD"),GETSX3CACHE("MDE_TIPO","X3_TAMANHO"))  +cCdRede,"MDE_CODIGO")
				cDscRede := Posicione("MDE",3,xFilial("MDE")+padr(ALLTRIM("RD"),GETSX3CACHE("MDE_TIPO","X3_TAMANHO"))  +cCdRede,"MDE_DESC")
				cNsu     := aFinalizacoes[nSl4]['nsu']
				cNsuAut  := aFinalizacoes[nSl4]['nsuAutorizacao']
				cAutCar  := aFinalizacoes[nSl4]['autorizacaoCartao']
				cNumCart := aFinalizacoes[nSl4]['numeroBinCartao']
				nPosAdm  := 	aSCAN(aAdmin,{|x| ALLTRIM(x[9]) + ALLTRIM(x[10]) ==cCdBan+cCdRede })
				IF nPosAdm >0
					cAdm     := aAdmin[nPosAdm][1]
					cAdmDesc := aAdmin[nPosAdm][3]
				ELSE
					lProc := .f.
					U_VRN0159("["+ cDocCHV+" / "+cSerChv+"]  NAO ENCONTROU ADM FINANCEIRA ")
					cMsgerr :=    "NAO ENCONTROU ADM FINANCEIRA"+ cEol
					cMsgerr +="redeAdquirente: "+cCdRede + cEol
					cMsgerr +="bandeira: "+cCdBan
					fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx],,cMsgerr)  //cStER  := "E" - ERRO
					if !lReproc
						fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['data'],1,10))
						fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['identificadorId']))
					endif
					IF Valtype(aRet) == "A"
						aRet[1] := 411
						aRet[2] := "Erro no Prcessamento. Não encontrou a Admnistradora Financeira"
					ENDIF
				endif
			endif

			if nQtdpar <= 1
				_aParcelas := {}
				aAdd( _aParcelas, {"L4_FILIAL"   , xFilial("SL4")    , NIL} )
				aAdd( _aParcelas, {"L4_FORMA"  , cFormPg      , NIL} )
				aAdd( _aParcelas, {"L4_TROCO"  , 0.00       , NIL} )
				aAdd( _aParcelas, {"L4_DATA"   , dDatabase    , NIL} )
				aAdd( _aParcelas, {"L4_VALOR"  , nvalor       , NIL} )
				IF ALLTRIM(cFormPg) $ "CD_CC"
					aAdd( _aParcelas, {"L4_ADMINIS", cAdmDesc     , NIL} )
					aAdd( _aParcelas, {"L4_AUTORIZ", cAutCar      , NIL} )
					aAdd( _aParcelas, {"L4_NSUTEF" , cNsu         , NIL} )
					aAdd( _aParcelas, {"L4_BANDEIR", cCdBan       , NIL} )
					aAdd( _aParcelas, {"L4_PARCTEF"  , "001"         , NIL} )
					aAdd( _aParcelas, {"L4_REDEAUT", cCdRede      , NIL} )
					aAdd( _aParcelas, {"L4_DATATEF", DTOS(dDatabase)      , NIL} )
					aAdd( _aParcelas, {"L4_HORATEF", cHrVend      , NIL} )
					aAdd( _aParcelas, {"L4_DOCTEF" , cNsuAut      , NIL} )
					aAdd( _aParcelas, {"L4_NUMCART", cNumCart     , NIL} )
					cNmCli:=        PADR("RD "+ALLTRIM(cDscRede)+" / BD: "+ALLTRIM(cAdmDesc),GETSX3CACHE("L4_NOMECLI","X3_TAMANHO"))
					aAdd( _aParcelas, {"L4_NOMECLI", cNmCli     , NIL} )
				ELSE
					aAdd( _aParcelas, {"L4_ADMINIS", CRIAVAR("L4_ADMINIS")     , NIL} )
				ENDIF
				cObs := padr(cvaltochar(nSl4),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
				aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
				aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(nSl4)     , NIL} )
				U_VRN0159( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nSl4) )
				aadd(aSl4,_aParcelas)
			else
				nVlrPar := round(nvalor/nQtdpar,GETSX3CACHE("L4_VALOR","X3_DECIMAL"))
				//    nVlrDif := nvalor%nQtdpar
				For nParc := 1 To nQtdpar
					_aParcelas :={}
					aAdd( _aParcelas, {"L4_FILIAL"   , xFilial("SL4")    , NIL} )
					aAdd( _aParcelas, {"L4_FORMA"  , cFormPg      , NIL} )
					aAdd( _aParcelas, {"L4_TROCO"  , 0.00       , NIL} )
					aAdd( _aParcelas, {"L4_ADMINIS", cAdmDesc     , NIL} )
					aAdd( _aParcelas, {"L4_DATA"   , dDatabase    , NIL} )
					if nParc == nQtdpar
						nVlrDif := nvalor-(nVlrPar*nQtdpar)
						aAdd( _aParcelas, {"L4_VALOR"  , nVlrPar  +nVlrDif     , NIL} )
					else
						aAdd( _aParcelas, {"L4_VALOR"  , nVlrPar       , NIL} )
					endif
					aAdd( _aParcelas, {"L4_AUTORIZ", cAutCar      , NIL} )
					aAdd( _aParcelas, {"L4_NSUTEF" , cNsu         , NIL} )
					aAdd( _aParcelas, {"L4_BANDEIR", cCdBan       , NIL} )
					aAdd( _aParcelas, {"L4_PARCTEF"  , STRZERO(nQtdpar,3)        , NIL} )
					aAdd( _aParcelas, {"L4_REDEAUT", cCdRede      , NIL} )
					aAdd( _aParcelas, {"L4_DATATEF", DTOS(dDatabase)      , NIL} )
					aAdd( _aParcelas, {"L4_HORATEF", cHrVend      , NIL} )
					aAdd( _aParcelas, {"L4_DOCTEF" , cNsuAut      , NIL} )
					aAdd( _aParcelas, {"L4_NUMCART", cNumCart     , NIL} )
					aAdd( _aParcelas, {"L4_SITUA", "RX"     , NIL} )
					aAdd( _aParcelas, {"L4_INSTITU", cDscRede   , NIL} )
					aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(nSl4)        , NIL} )
					cObs := padr(cvaltochar(nSl4),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
					aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
					aadd(aSl4,_aParcelas)
					U_VRN0159( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nSl4) )
				next nParc
			endif

		Next nSl4

		if nForNCC >0
			aAdd( _aCab, {"LQ_CREDITO", nForNCC	 , NIL} )
		endif

		if lProc .AND. LEN(_aCab)>0 .AND. LEN(aSL2)>0 .AND. LEN(aSl4)>0
			lMsErroAuto    := .F.
			lAutoErrNoFile := .T.

			IF nTotICMS > 0
				aAdd( _aCab, {"LQ_VALICM ", nTotICMS	 , NIL} )
			ENDIF

			U_VRN0159("["+ alltrim(cDocCHV)+" / "+cSerChv+"]  VAI CHAMAR O EXECAUTO")
			U_VRN0159("["+ cDocCHV+" / "+cSerChv+"]  VAI CHAMAR O EXECAUTO")
			SetFunName("LOJA701")
			MSExecAuto({|a,b,c,d,e,f,g,h,i,j| Loja701(a,b,c,d,e,f,g,h,i,j)}, .F., 3, "", "", {}, _aCab, aSL2,aSl4,.F.,.T.)
			If lMsErroAuto

				cErro := ""
				aErro := GetAutoGRLog()

				For nERR := 1 To Len(aErro)
					cErro += aErro[nERR]
				Next nERR

				LjGrvLog(alltrim(cDocCHV)+" / "+cSerChv, "Erro na execução da MSExecAuto - LOJA701", cErro) //"Erro na execução da MSExecAuto - LOJA701"

				fPutZV1(.F.,aParZV1,cStER,aItenJson[nIdx],,"Erro no execauto LOJA701"+cErro)    //cStER  := "E" - ERRO

				IF Valtype(aRet) == "A"
					aRet[1] := 410
					aRet[2] := "Erro no execauto LOJA701"+cErro
				ENDIF
				loop
			else

				fPutZV1(.F.,aParZV1,cStInPrc,aItenJson[nIdx])    //cStInPrc := "1" - EM PROCESSAMENTO
				ConfirmSx8()

				RecLock("SL1", .F.)
				SL1->L1_SITUA := "RX"
				SL1->(MsUnLock())
				IF Valtype(aRet) == "A"
					aRet[1] := 200
					aRet[2] := "Reprocessado com Sucesso, aguardar o Gravabatch"
				ENDIF
			ENDIF
		ENDIF
	Next nIdx

	U_VRN0159("Final Processamento")
	//  RESET ENVIRONMENT

	// 1 Rio Negro, SP, Empresa 14 Filial 1
	// 3 Donato São Pedro, BH, Empresa 11 Filial 1
	// Verificar se vamos usar cliente padrão;
	// SAT até 10 mil reais
	//Inicio processo de importaçao de cupons fiscais para tabelas:

Return

/*/{Protheus.doc} BuscaCupons
Busco dados dos cupons fiscais
@type function
@since 10/30/2023
@param cEmpresa, character,
@param cNumeroCupom, character, Numero do Cupom Fiscal
@param cEndPoint, character, Endereço do Endpoint
@return variant, oCuponsFiscais
/*/
Static Function BuscaCupons(cEmpresa,cEndPoint,cIDVnd)

	Local  cDtPrc := alltrim(SuperGetMV("MV_VFDTPRC",.f.))
	Local  cIDPrc := alltrim(SuperGetMV("MV_VFIDPRC",.f.))
	Local cToken := BuscaToken(cEndPoint)
	Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=500&q=lojaId==' + cEmpresa

	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	DEFAULT cIDVnd := Nil

	//cIDVnd := "26370"
	U_VRN0159("cIDVnd "+ cvaltochar(cIDVnd)+funname())
	IF Valtype(cIDVnd) == "U"
		cURL +=';data=ge='+cDtPrc
		cURL +=';identificadorId=ge='+cIDPrc
	ELSE
		cURL +=';identificadorId=='+cvaltochar(cIDVnd)

	ENDIF
	cURL +='&sort=data,id'
	U_VRN0159(cURL)
	// cURL := cEndPoint + '/v1/venda/cupons-fiscais/000087-001-1700103600000-3'
	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
	if !empty(cResponse)
		U_VRN0159("[OK 02] - Buscou cupons")
	Else
		U_VRN0159("[ERRO 02] - cupons")
	EndIf
Return  cResponse

/*/{Protheus.doc} BuscaToken
Busca token de acesso.
@type function
@version
@since 10/30/2023
@param cEndPoint, character, param_description
@return variant, return_description
/*/
Static Function BuscaToken(cEndPoint)
	Local cUrl := cEndPoint + "/auth"
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cPostParms := '{"username": "api_bud", "password": "ABud3356@5s"}'
	Local cHeadGet := ""
	Local cResponse := ""
	Local cParser := ""
	Local oJson := JsonObject():New()

	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Accept: application/json')
	cResponse := HttpPost(cUrl,"", cPostParms, nTimeOut,aHeadOut,@cHeadGet)
	if !empty(cResponse)
		U_VRN0159("[OK 01] - Resposta da requisição POST")
		cParser := oJson:FromJson(cResponse)
		Return oJson:GetJsonObject('accessToken')
	Else
		U_VRN0159("[ERRO 01] - Resposta da requisição POST")
		Return ""
	EndIf
Return


/*/{Protheus.doc} fGetImp
Retorna produtoId
@type function
@version
@since 10/30/2023
@param cIdPrd, character, param_description
@return variant, return_description
/*/
static function fGetImp(cIdVenda)

	Local cEndPoint := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local cToken := BuscaToken(cEndPoint)
	// Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=100000&q=dataVenda==' + dDataAtual + ';lojaId==' + cEmpresa
	Local cURL := cEndPoint + '/v1/venda/cupons-fiscais/'+cIdVenda+"/impostos"
	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	Local oImpVenda := JsonObject():New()
	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
	cParser := oImpVenda:FromJson(cResponse)
	//cProdOrig := oImpVenda:GetJSonObject('identificadorDeOrigem')
	if !empty(cResponse)
		U_VRN0159("[OK 02] - Buscou cupons")
	Else
		U_VRN0159("[ERRO 02] - cupons")
	EndIf
Return  oImpVenda

/*/{Protheus.doc} fGetPrd
Retorna produtoId
@type function
@version
@since 10/30/2023
@param cIdPrd, character, param_description
@return variant, return_description
/*/
static function fGetPrd(cIdPrd)

	Local cEndPoint := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local cToken := BuscaToken(cEndPoint)
	//Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=100000&q=dataVenda==' + dDataAtual + ';lojaId==' + cEmpresa
	Local cURL := cEndPoint + '/v1/produto/produtos/'+CVALTOCHAR(cIdPrd)
	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	Local oProds := JsonObject():New()
	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
	cParser := oProds:FromJson(cResponse)
	cProdOrig := oProds:GetJSonObject('identificadorDeOrigem')
	if !empty(cResponse)
		U_VRN0159("[OK 02] - Buscou cupons")
	Else
		U_VRN0159("[ERRO 02] - cupons")
	EndIf
Return  {cProdOrig,1}

/*/{Protheus.doc} fGetAdm
Busca dados da Administradora de Cartão.
@since 30/10/2023
@type function
@return aADMCart, Dados do ADM de Cartões
/*/
STATIC FUNCTION fGetAdm()

	Local aADMCart := {}
	Local aArea	:= GetArea()             //WorkArea Ativa
	Local aAreaSAE := SAE->(GetArea())	 //WorkArea Anteriror SAE
	Local aAreaMDE := MDE->(GetArea())   //WorkArea Anterior MDE
	Local nParcDe := 0                   //Parcela De
	Local nParcAte := 0                  //Parcela Ate
	Local lAEREDEAUT	:= SAE->(ColumnPos("AE_REDEAUT")) > 0
	Local cBandSITEF	:= ""
	Local cDesBandMDE 	:= ""
	Local cRedeSITEF	:= ""
	Local cDesRedeMDE 	:= ""

	DbSelectArea("MDE")
	MDE->(DbSetOrder(1))  //MDE_FILIAL+MDE_CODIGO
	DbSelectArea("SAE")
	DbSetOrder(1) //AE_FILIAL+AE_COD
	DbSeek(xFilial("SAE"))
	//To: Verificar a possibilidade de filtrar pela forma de pagamento CC/CD

	While !SAE->(Eof()) .AND. SAE->AE_FILIAL == xFilial("SAE")
		nParcDe := SAE->AE_PARCDE
		nParcAte := SAE->AE_PARCATE

		//Se parcela De/Ate vier em branco configua 1 a 99
		If nParcDe = 0 .AND. nParcAte = 0
			nParcDe := 1
			nParcAte := Val(Replicate("9", SAE->(TamSx3("AE_PARCATE")[1])))
		EndIf

		If !Empty(SAE->AE_ADMCART) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_ADMCART ))
			cBandSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Bandeira (Retornado pelo SITEF)
			cDesBandMDE := MDE->MDE_DESC	//Descricao da Bandeira
		Else
			cBandSITEF	:= ""
			cDesBandMDE := SAE->AE_DESC
		EndIf

		If lAEREDEAUT //Controle pela Rede que autorizou a transacao TEF
			If !Empty(SAE->AE_REDEAUT) .And. MDE->(DbSeek(xFilial("MDE")+SAE->AE_REDEAUT ))
				cRedeSITEF	:= AllTrim(MDE->MDE_CODSIT) 	//Codigo da Rede autorizadora da transação TEF (Retornado pelo SITEF)
				cDesRedeMDE := MDE->MDE_DESC	//Descricao da Rede
			Else
				cRedeSITEF	:= ""
				cDesRedeMDE := ""
			EndIf
		Else
			cRedeSITEF	:= ""
		EndIf

		AAdd(aADMCart, {	SAE->AE_COD											,; //01-Codifo da Adm. Financeira
			AllTrim(SAE->AE_TIPO)								,; //02-Tipo (CC,CD,...)
			SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))	,; //03-Codigo e Nome da Adm. Financeira. (Ex. 001 - VISA)
			nParcDe												,; //04-Parcela Inicial
			nParcAte											,; //05-Parcela Final
			SAE->AE_ADMCART										,; //06-Codigo Relacionado a tabela MDE para a Bandeira
			SAE->AE_REDEAUT										,; //07-AUTORIZADORA
			cDesBandMDE											,; //08-Descricao da Bandeira
			cBandSITEF 											,; //09-Codigo da Bandeira(campo MDE_CODSIT)
			cRedeSITEF											,; //10-Codigo da Rede (Campo MDE_CODSIT)
			cDesRedeMDE 										}) //10-Descricao da Rede (campo MDE_DESC)

		SAE->(DbSkip())
	End

	RestArea(aAreaSAE)
	RestArea(aAreaMDE)
	RestArea(aArea)

Return aADMCart

/*/{Protheus.doc} fVFPutSX6
Altera Parametro Global
@type function
@since 10/30/2023
@param cParam, character, Id do Parâmetro
@param xCont, variant, Conteúdo do Parâmetro
@return variant, return_description
/*/
Static Function fVFPutSX6(cParam,xCont)

	dbSelectArea("SX6")
	PutMv(cParam, xCont)

return

/*/{Protheus.doc} fPutZV1
Alimenta Vendas Varejo Fácil.
@type function
@since 30/10/2023
@param lInc, logical, Operação Inclusão/Alteração.
@param aParam, array, Dados da Venda.
@param cStatus, character, Status do processo.
@param oJson, object, Json de integração.
@param lCanc, boolean, Indica se é alteração de cancelamento.
@return variant, return_description
/*/
Static function fPutZV1(lInc,aParam,cStatus,oJson, lCanc,cMsgErr)

	Local nPosID := 1
	Local nPosDoc := 2
	Local nPosSer := 3
	Local nPosDtVd := 5
	Local nPosSLG := 4
	DEFAULT lCanc := .F.
	DEFAULT cMsgErr := ""

	If lInc
		Reclock("ZV1",.T.)
		ZV1->ZV1_FILIAL  := Xfilial("ZV1")
		ZV1->ZV1_IDVEND  := STRZERO(aParam[nPosID],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )
		ZV1->ZV1_STATUS  := cStatus
		ZV1->ZV1_DTVEND  := aParam[nPosDtVd]
		ZV1->ZV1_DOC     := aParam[nPosDoc]
		ZV1->ZV1_SERIE   := aParam[nPosSer]
		ZV1->ZV1_ESTSLG  := aParam[nPosSLG]
		ZV1->ZV1_JSON    := oJson:toJson()

		ZV1->( MsUnlock() )
	Else
		IF lCanc
			DbSelectArea("ZV1")
			ZV1->(DbSetOrder(1))
			If ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aParam[nPosID],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
				Reclock("ZV1",.F.)
				ZV1->ZV1_STACAN  := cStatus
				ZV1->( MsUnlock() )
			ENDIF
		else
			DbSelectArea("ZV1")
			ZV1->(DbSetOrder(1))
			If ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aParam[nPosID],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
				Reclock("ZV1",.F.)
				ZV1->ZV1_STATUS  := cStatus
				if !empty(cMsgErr)
					ZV1->ZV1_MSGERR    := cMsgErr
				endif
				ZV1->( MsUnlock() )
			ENDIF
		endif
	ENDIF
Return

/*/{Protheus.doc} JsonText
(transforma json em string)
@type  Function
@since 28/09/2022
@param cJson, character, variável contendo o Json
@return cJson, String, string contendo o Json em formato de texto
/*/
Static Function Jsontext(cJson)
	Local oJsonContent := JsonObject():new()
	Local aNome        := {}
	Local nCount       := 0

	cJson:=lower(cJson)

	oJsonContent:FromJson(cJson)
	aNome	:= oJsonContent:getnames()

	For nCount := 1 to Len(aNome)
		cJson  := StrTran( cJson, aNome[nCount], LOWER(aNome[nCount]) )
	Next nCount


	FreeObj(oJsonContent)
Return cJson

User Function VRNX160()
	lOCAL nSl4 := 0
	Local cEol := chr(10)
	cSql :=" SELECT E1_NUM,E1_PREFIXO,L1_NUM,COUNT(DISTINCT L4_PARCTEF) QTDPAR,   ZV1.ZV1_IDVEND " + cEol
	cSql +=" FROM " + RetSqlName("SE1") + " (NOLOCK) TBL1 " + cEol
	cSql +="   JOIN " + RetSqlName("SL1") + "  SL1 " + cEol
	cSql +="        ON SL1.D_E_L_E_T_ = '' " + cEol
	cSql +="        AND L1_FILIAL = E1_FILORIG " + cEol
	cSql +="        AND E1_NUM = L1_DOC " + cEol
	cSql +="        AND E1_PREFIXO = L1_SERIE " + cEol
	cSql +=" JOIN " + RetSqlName("SL4") + "  SL4 " + cEol
	cSql +="        ON SL4.D_E_L_E_T_ = ''  " + cEol
	cSql +="        AND L1_FILIAL = L4_FILIAL  " + cEol
	cSql +="        AND L1_NUM = L4_NUM  " + cEol
	cSql +="        AND L4_FORMA IN ( 'CC', 'CD' )  " + cEol
	cSql +=" JOIN " + RetSqlName("ZV1") + "  ZV1 (NOLOCK) " + cEol
	cSql +="        ON ZV1.D_E_L_E_T_ = '' " + cEol
	cSql +="        AND ZV1_FILIAL    = E1_FILORIG " + cEol
	cSql +="        AND ZV1_DOC       = E1_NUM " + cEol
	cSql +="        AND ZV1_SERIE     = E1_PREFIXO " + cEol
	cSql +=" WHERE TBL1.D_E_L_E_T_ = '' " + cEol
	cSql +="        AND E1_EMISSAO >= '20231001' " + cEol
	cSql +="        AND E1_PREFIXO = '503' " + cEol
	cSql +="        AND E1_TIPO IN ( 'CC', 'CD' ) " + cEol
	cSql +="        AND E1_SALDO > 0 " + cEol
	cSql +=" GROUP BY E1_NUM,E1_PREFIXO,L1_NUM,ZV1.ZV1_IDVEND " + cEol
	cSql +=" HAVING COUNT(DISTINCT L4_PARCTEF) = 1  " + cEol
	cSql +=" ORDER BY 4"

	If (Select("TMPFIN") <> 0)
		dbSelectArea("TMPFIN")
		dbCloseArea()
	Endif
	//U_VRN0159(cSql)
	//    lGet := .t.
	TCQuery cSql NEW ALIAS "TMPFIN"
	dbSelectarea("ZV1")

	while TMPFIN->(!Eof())


		oJsonZV1 := JsonObject():New()
		cSeekZV1 := xFILIAL("ZV1")+TMPFIN->ZV1_IDVEND

		ZV1->( DbSetOrder(1) )
		IF   ZV1->( DbSeek( cSeekZV1))
			cJson :=  ZV1->ZV1_JSON
			oJsonZV1:FromJson(cJson)
			aFinalizacoes :=  oJsonZV1:GetJSonObject('finalizacoes')
			nSl4 := 0
			// aFinalizacoes := aItenJson[nIdx]['finalizacoes']
			For nSl4 := 1 To Len(aFinalizacoes)
				cFormPg :=alltrim(Posicione("SX5",1,xFilial("SX5")+"Z2"+CVALTOCHAR(aFinalizacoes[nSl4]['finalizadoraId']),"X5_DESCRI"))

				IF aFinalizacoes[nSl4]['finalizadoraId'] == 2  .OR. aFinalizacoes[nSl4]['finalizadoraId'] == 3 .or. aFinalizacoes[nSl4]['finalizadoraId'] == 5  //CARTAO DEBITO
					cNsu     := aFinalizacoes[nSl4]['nsu']
					cNsuAut  := aFinalizacoes[nSl4]['nsuAutorizacao']
					cAutCar  := aFinalizacoes[nSl4]['autorizacaoCartao']
					cNumCart := aFinalizacoes[nSl4]['numeroBinCartao']
					cUpd1 := "UPDATE " + RetSqlName("SL4") + " SET  " + cEol
					cUpd1 += " L4_DOCTEF  = "+VALTOSQL(cNsuAut ) + cEol
					cUpd1 += " , L4_NSUTEF  =  "+VALTOSQL(cNsu  ) + cEol
					cUpd1 += " , L4_AUTORIZ =  "+VALTOSQL(cAutCar  ) + cEol
					cUpd1 += "WHERE D_E_L_E_T_ = ''  " + cEol
					cUpd1 += "AND  L4_FILIAL = "+VALTOSQL(xFilial("SL4") ) + cEol
					cUpd1 += "AND  L4_NUM = "+VALTOSQL(TMPFIN->L1_NUM)  + cEol
					cUpd1 += "AND  L4_FORMA = "+VALTOSQL(cFormPg)   + cEol
					cUpd1 += " AND (L4_DOCTEF  != "+VALTOSQL(cNsuAut ) + cEol
					cUpd1 += " OR L4_NSUTEF  !=  "+VALTOSQL(cNsu  ) + cEol
					cUpd1 += " OR  L4_AUTORIZ !=  "+VALTOSQL(cAutCar  ) + cEol
					cUpd1 += " ) "
					nRet :=    TCSQLEXEC(cUpd1)
					if nRet < 0
						U_VRN0159("TCSQLError() 1" + TCSQLError())
					endif
					cUpd2 := "update " + RetSqlName("SE1") + " SET  " + cEol
					cUpd2 += "   E1_DOCTEF  = "+VALTOSQL(cNsuAut) + cEol
					cUpd2 += " , E1_NSUTEF  = "+VALTOSQL(cNsu  ) + cEol
					cUpd2 += " , E1_CARTAUT = "+VALTOSQL(cAutCar ) + cEol
					cUpd2 += " WHERE D_E_L_E_T_ = '' " + cEol
					cUpd2 += " AND  E1_FILIAL  = "+VALTOSQL( XFILIAL("SE1") ) + cEol
					cUpd2 += " AND  E1_FILORIG = "+VALTOSQL('01') + cEol
					cUpd2 += " AND  E1_NUM     = "+VALTOSQL(TMPFIN->E1_NUM)  + cEol
					cUpd2 += " AND  E1_TIPO    = "+VALTOSQL(cFormPg)  + cEol
					cUpd2 += " AND  E1_PREFIXO = '503' " + cEol
					cUpd2 += " AND E1_SALDO >0 " + cEol
					cUpd2 += " AND (E1_DOCTEF  != "+VALTOSQL(cNsuAut) + cEol
					cUpd2 += " OR E1_NSUTEF  != "+VALTOSQL(cNsu  ) + cEol
					cUpd2 += " OR E1_CARTAUT != "+VALTOSQL(cAutCar ) + cEol
					cUpd2 += " ) "
					nRet :=    TCSQLEXEC(cUpd2)
					if nRet < 0
						U_VRN0159("TCSQLError() 2" + TCSQLError())
					endif
				ENDIF
			NEXT nSl4
			U_VRN0159("VRNX160")

		ENDIF
		TMPFIN->( DbSkip())

	EndDo

return

Static Function SchedDef()
	Local aParam
	Local aOrd     := {}

	aParam := { "P",;      // Tipo R para relatorio P para processo
		"",;	// Pergunte do relatorio, caso nao use passar ParamDef
		"",;  	// Alias
		aOrd,;   	// Array de ordens
		""}

Return aParam
