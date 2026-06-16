#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"


// /=========================================================================\
// | Execução    : Execução da rotina via schedule                           |
// |=========================================================================|
// | Programa    : VRN0164.PRW   | Responsável: Gabriel Araujo | Cesar Gross |
// |=========================================================================|
// | Descricao   : Varejo Facil, Importação de Documentos 	                 |
// |=========================================================================|
// | Data        : 10/2023	 - 07/2025				                         |
// |=========================================================================|
// | Programador : 06051982 Cesar Grossl - Daniel Victor da Rosa Personalitec|
// \=========================================================================/

User Function VRN0164()

	Local oButton1
	Local oButton2
	Local oGet1
	Local oSay1
	Local oSay3
	Local oComboBo1
	Private cComboBo1 := ""
	Private cGet1 := SPACE(44)
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "IMPORTAR NFE/VENDAS, bonificacao, doacao ou brinde" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL

	//@ 010, 061 SAY oSay1 PROMPT "Atenção: O Número da nota deve estar igual ao XML." SIZE 123, 014 OF oDlg COLORS 0, 16777215 PIXEL
	@ 033, 041 SAY oSay3 PROMPT "CHAVE DA NFE:" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 041 MSGET oGet1 VAR cGet1 SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 041 MSCOMBOBOX oComboBo1 VAR cComboBo1 ITEMS {"1-Importar Nota","2-Integrar Nota"} SIZE 0100, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 108, 160 BUTTON oButton1 PROMPT "IMPORTAR" SIZE 037, 009 OF oDlg ACTION ProcDocN(cGet1,cComboBo1) PIXEL
	@ 108, 206 BUTTON oButton2 PROMPT "SAIR" SIZE 037, 009 OF oDlg ACTION oDlg:end() PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcDocN
	(long_description)
	@Função para apenas facilitar o processamento.
	@Daniel Victor da Rosa
	@since 30/06/2025
/*/
Static Function ProcDocN(cGet1,cOpc)

	Private lZt := .F.
	private cMsgErr2 := ""

	cGet1 := cValtoChar(VAL(SUBSTR(cGet1,26,9)))

	if  cOpc == "1-Importar Nota"
		//PROCESSA O DOCUMENTO E INTEGRA NA TABELA CUSTOMIZADA.
		FWMsgRun(, {||  fProcZV1() }, "Importando","Aguarde Processando xml" )
		IF lZt == .T.
			MsgInfo("Nota importada, favor preencher a forma de pagamento no portal.","Atencao!!!")
		ELSE
			MsgInfo("Erro ao integrar a Nota de venda.."+cMsgErr2 ,"Atencao!!!")
			cMsgErr2 := ""
		ENDIF
	elseif  cOpc == "2-Integrar Nota"
		//PROCESSA A TABELA CUSTOMIZADA E INTEGRA O DOCUMENTO NO PROTHEUS.
		FWMsgRun(, {||  fPutSL1() }, "Importando","Aguarde Processando xml" )
		IF lZt == .T.
			MsgInfo("Nota de Venda Integrada.","Atencao!!!")
		ELSE
			MsgInfo("Erro ao integrar a Nota de venda.."+cMsgErr2 ,"Atencao!!!")
			cMsgErr2 := ""
		ENDIF
	elseif  cOpc == ""
		fProcNFE()
		fPutSL1()
	endif

Return


Static Function fPutSL1()
	Local cEol      := chr(10)
	Local oCupons   := JsonObject():New()
	Local oPgto     := JsonObject():New()
	Local cStPrc    := "3" // status de processado  e disponivel para o gravabatch
	Local cStInPrc  := "1" // status de em processamento
	Local cSt701    := "2" // chamou o execauto
	Local cStIni    := "0" // Iniciando
	Local cStER     := "E"  // ERRO
	Local cStCan    := "C" // ERRO
	Local cDocNot      :=  alltrim(SubStr(cGet1,26,9)) //DANIEL ROSA - PERSONALITEC - ADICIONADO PARA QUE SEJA POSSIVEL ACHAR A NOTA. - StrTran foi removido pois ficava "190" e não acha o cupom, apenas "000190 e "000000190"
	Local cNumeroCupom :=  alltrim(SubStr(cGet1,26,9)) //DANIEL ROSA - PERSONALITEC - ADICIONADO PARA QUE SEJA POSSIVEL ACHAR A NOTA. - StrTran foi removido pois ficava "190" e não acha o cupom, apenas "000190 e "000000190"
	Local i
	Local cEol      := chr(10)
	Local nVendaIdx := 0
	Local nParc     := 0
	Local nPgto     := 0
	Local nERR      := 0
	Local nIdx      := 0
	cEmpresa        := supergetmv("MV_VFIDLJ",.F.,"3")
	cEndPoint       := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	cCliPad         := PADR("07035484" ,getsx3cache("A1_COD","X3_TAMANHO")) // PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	cLojPad         := PADR("0001",getsx3cache("A1_LOJA","X3_TAMANHO"))	 //PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	cVendPad        := PADR(alltrim( SuperGetMV("MV_VENDPAD")),getsx3cache("LQ_VEND","X3_TAMANHO"))
	cTiposDoc 	    := AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	cSLGEst         := supergetmv("MV_ZCDSLG",.F.,IIF(cEmpAnt =="14","003","004"))  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	cOpera          := supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	cArmVnd         := supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA

	//PESQUISO A SERIE CONFORME CADASTRO DE ESTAÇÕES TABELA SLG LG_SERIE
	DbSelectArea("SLG")
	SLG->(DbSetOrder(1))
	If SLG->(DbSeek(xFilial("SLG")+padr(cSLGEst,getsx3cache("LG_CODIGO","X3_TAMANHO"))))
		cSerie  := alltrim(SLG->LG_SERNFIS)
		cPdv    := SLG->LG_PDV
		cSerSat := SLG->LG_SERSAT
	endif

	cSql := "SELECT R_E_C_N_O_ RECZV1, ZV1_MSGPRC " + cEol
	cSql += "FROM dbo."+RetSqlName("ZV1")+" (NOLOCK)  ZV1   " + cEol
	cSql += "WHERE ZV1.D_E_L_E_T_ = ''  " + cEol
	cSql += "AND ZV1.ZV1_SERIE="+valtosql(cSerie)   + cEol
	cSql += "AND ZV1.ZV1_FILIAL="+valtosql(XFILIAL("ZV1"))   + cEol
	cSql += "AND ZV1.ZV1_DOC = "+valtosql(StrZero(Val(cDocNot), 6)) + cEol

	If (Select("TZV1") <> 0)
		dbSelectArea("TZV1")
		dbCloseArea()
	Endif

	TCQuery cSql NEW ALIAS "TZV1"
	dbSelectarea("ZV1")
	while TZV1->(!Eof())

		oJsonZV1 := JsonObject():New()
		oCuponsFiscais := JsonObject():New()

		ZV1->(DbGoto(TZV1->RECZV1))

		cJson  := ZV1->ZV1_MSGPRC
		oJsonZV1:FromJson(cJson)
		oCuponsFiscais := BuscaCupons(cEmpresa,  cDocNot, cSerie, cEndPoint)

		cParser := oCupons:FromJson(oCuponsFiscais)
		aItenJson := oCupons:GetJSonObject('items')

		chkfile("ZV1")
		aAdmin := fGetAdm()

		CONOUT("STOP")


		If valtype(aItenJson) != "A"
			oCuponsFiscais :='{"items":['+oCuponsFiscais+']}'
			oCupons:FromJson(oCuponsFiscais)
			aItenJson := oCupons:GetJSonObject('items')
		EndIf

		IF aItenJson == NIL .OR. LEN(aItenJson) == 0
			cMsgErr2 :=  "- não foram encontrados cupons para serem importados"
		ENDIF

		For nIdx := 1 To Len(aItenJson)

			lProc := .t.
			//Caso a serie esteja em branco nao processa as vendas
			IF  alltrim(aItenJson[nIdx]['situacao']) =="PENDENTE"

				U_VRN0159("[IMP SL1] -VENDA NAO AUTORIZADA ")
				lProc := .f.
				cMsgErr2 := "- Venda Nao Autorizada"
				loop

			ELSEIF alltrim(aItenJson[nIdx]['situacao']) =="INUTILIZADA"

				U_VRN0159("[IMP SL1] -VENDA INUTILIZADA ")
				lProc := .f.
				cMsgErr2 := "- Venda Inutilizada"
				loop

			ENDIF

			//Cabeçalho do cupom,  SL1
			U_VRN0159("[IMP SL1] - Inicio, Cabecalho Cupons")
			cChvNfce    := aItenJson[nIdx]['chaveDaNfe']

			cDoc        :=  PADR( STRZERO(Val(SubStr(cChvNfce,26,9)),6),9)
			nValor      := aItenJson[nIdx]['valorDoDocumento']
			cCgcCli     := aItenJson[nIdx]['valcpfConsumidor']
			cSerie      :=  PADR(alltrim(aItenJson[nIdx]['serie']),3)
			dDataVnd    := stod(STRTRAN(SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10), "-", ""))
			dDatabase   := dDataVnd
			cHrVend     := substr(aItenJson[nIdx]['dataOperacao'],12,8)
			cIdCliente	:= aItenJson[nIdx]:GetJSonObject('clienteId')


			//Caso a serie esteja em branco nao processa as vendas
			IF EMPTY(cSerie)
				U_VRN0159("[IMP SL1] - Sem cadastro de estacao ou Serie em branco ")
				lProc := .f.
				cMsgErr2 := "- Sem cadastro de estacao ou Serie em branco"
				loop
			ENDIF
			nPosID := 1
			nPosDoc := 2
			nPosSer := 3
			nPosDtVd := 5
			nPosSLG := 4
			cStatus := "0"

			aParZV1:= {;
				aItenJson[nIdx]['id'],;
				cDoc,;
				cSerie,;
				cPdv   ,;
				dDataVnd}

			ZV1->(DbSetOrder(1))
			If !ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aItenJson[nIdx]['id'],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
				fPutZV1(.t.,aParZV1,cStIni,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"

			endif

			if alltrim(aItenJson[nIdx]['situacao']) =="CANCELADA"

				//       alert("Cancelada, Debugar")
				fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.

			ENDIF


			cEspecie := LjNfEspeci(cSerie, cTiposDoc)
			CONOUT("STOP")

			// Monta cabeçalho do orçamento (SLQ)

			//1 ) Procuta se a venda ja ´se encontra na SL1 para nao ter chave duplicada
			//Caso encontre nao processa porem valida o SL1 lL1_SITUA PARA ATUALIZAÇÃO DA TABELA DE CONTROLE

			cQuerySL := " SELECT L1_SERIE , L1_DOC  FROM "+RETSQLNAME('SL1')+" (NOLOCK) s "
			cQuerySL +=  " WHERE D_E_L_E_T_ = ' ' "
			cQuerySL += " AND L1_NUM = "+valtosql(cDoc)
			cQuerySL += " AND L1_SERIE = "+valtosql(cSerie)
			cQuerySL += " AND L1_PDV = "+valtosql(cPdv)

			IF (Select("cAlisSZ") <> 0)
				dbSelectArea("cAlisSZ")
				dbCloseArea()
			Endif

			cAlisSZ := GetNextAlias()

			MPSysOpenQuery(cQuerySL, cAlisSZ)

			IF (cAlisSZ)->(!Eof())

				lProc := .f.
				//if !lReproc
				//PutSX6(cParam1,SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10))
				//PutSX6(cParam2,cvaltochar(aItenJson[nIdx]['id']))
				if SL1->L1_SITUA == "OK"
					fPutZV1(.f.,aParZV1,cStPrc,aItenJson[nIdx])     //cStPrc := "3 - PROCESSADO"
				ELSEIF  SL1->L1_SITUA  == "RX"
					fPutZV1(.f.,aParZV1,cSt701,aItenJson[nIdx])     //cSt701 := "2 - CHAMOU EXECAUTO"
				ELSEIF  SL1->L1_SITUA  == "ER"
					fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx])      //cStER  := "E" - ERRO

				endif
				cMsgErr2 := "Documento ja importado - SL1"
				U_VRN0159("[IMP SL1] - DOCUMENTO JA IMPORTADO ")
				loop

			ENDIF

			aRetCli := zExistCli(cvaltochar(cIdCliente), cEndpoint )
			lretCli := aRetCli[1]
			if aRetCli[1] == .T. //Se existe o cliente

				aRecnoCli := aRetCli[3]

				DBSELECTAREA( "SA1" )
				lCadCli := .T.
				for i:= 1 to len(aRetCli[3])
					SA1->(DBGOTOP())
					SA1->(DBGOTO(aRetCli[3][i]))

					// Se existe na Base e CPF / CNPJ  exista na base e o CEP seja igual A1_CEP e  SE LOGRADOURO (ORIGEM API) Pertence a A1_END
					//RETORNA A1_COD / A1_LOJA PARA SER UTILIZADO COMO CLIENTE NA Nota
					IF SA1->A1_CEP == strtran(aRetCli[2]['enderecos'][1]['cep'],'-','')
						//.and. alltrim(FwCutOff(decodeutf8(upper(aRetCli[2]['enderecos'][1]['logradouro'] )),.t.) ) $  alltrim(FwCutOff(upper( SA1->A1_END   ),.t.) )

						cCliPad	:= SA1->A1_COD
						cLojPad	:= SA1->A1_LOJA

						lCadCli := .F.

						EXIT
					ENDIF
				next

				if lCadCli
					conout('inserir cliente')
					lretCli := 		zCadCli(aRetCli[2])
				ENDIF

			else
				conout('inserir cliente')
				lretCli := 	zCadCli(aRetCli[2])
			endif

			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
			SA1->(MsSeek(xFilial("SA1")+cCliPad+cLojPad))
			cTipoCli := SA1->A1_TIPO
			_aCab := {}
			cVendPad := "000001"
			aAdd( _aCab, {"LQ_CLIENTE", cCliPad	 , NIL} )
			aAdd( _aCab, {"LQ_LOJA",    cLojPad	 , NIL} )
			aAdd( _aCab, {"LQ_NOMCLI",   padr(SA1->A1_NOME,GETSX3CACHE("LQ_NOMCLI","X3_TAMANHO") )	 , .F.} )
			//aAdd( _aCab, {"LQ_NOMCLI",   padr("",GETSX3CACHE("LQ_NOMCLI","X3_TAMANHO") )	 , .F.} )
			aAdd( _aCab, {"LQ_VEND"     , cVendPad    , NIL} )
			aAdd( _aCab, {"LQ_OPERADO", cOpera	 , NIL} )
			aAdd( _aCab, {"LQ_EMISSAO", dDataVnd	 , NIL} )
			aAdd( _aCab, {"LQ_HORA",    cHrVend	 , NIL} )
			aAdd( _aCab, {"LQ_EMISNF",  dDataVnd	 , NIL} )
			aAdd( _aCab, {"LQ_DTLIM",  dDataVnd 	 , NIL} )
			aAdd( _aCab, {"LQ_NUMMOV",  ""	 , NIL} ) //verificar
			aAdd( _aCab, {"LQ_NUMCFIS", cDoc	 , NIL} )
			aAdd( _aCab, {"LQ_DOC",  cDoc   	 , NIL} )
			aAdd( _aCab, {"LQ_SERIE", cSerie   	 , NIL} )
			aAdd( _aCab, {"LQ_SERPDV", "0" 	 , NIL} )
			aAdd( _aCab, {"LQ_SERSAT",  cSerSat	 , NIL} )
			aAdd( _aCab, {"LQ_KEYNFCE", cChvNfce	 , NIL} )
			aAdd( _aCab, {"LQ_COMIS",   0.00	 , NIL} )
			aAdd( _aCab, {"LQ_VLRTOT",  nValor	 , NIL} )
			aAdd( _aCab, {"LQ_VALBRUT", nValor	 , NIL} )
			aAdd( _aCab, {"LQ_VLRLIQ",  nValor	 , NIL} )
			aAdd( _aCab, {"LQ_VALMERC", nValor	 , NIL} )
			aAdd( _aCab, {"LQ_DESCONT", 0.00	 , NIL} )
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
			aAdd( _aCab, {"LQ_TROCO1",  0.00	 , NIL} )


			//Itens do cupon, SL2
			U_VRN0159("[IMP SL2] - Inicio, Itens Cupons")
			aVendas := aItenJson[nIdx]['itens']
			aSl2 := {}
			For nVendaIdx := 1 To Len(aVendas)
				aRetPrd := fGetPrd(aVendas[nVendaIdx]['produtoId'])
				//aRetPrd[1]:="F6099999001S020042            "
				//aRetPrd[2]:=1
				DbSelectArea("SB1")
				SB1->(DbSetOrder(aRetPrd[2])) // B1_FILIAL + B1_CODBAR
				If !SB1->(DbSeek(xFilial("SB1")+aRetPrd[1] ))
					lProc := .f.
					U_VRN0159("[IMP SL1] -Produto Não Encontrado ")
					fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx])  //cStER  := "E" - ERRO
					fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['data'],1,10))
					fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['identificadorId']))
					cMsgErr2 := "Produto nao encontrado: "+aRetPrd[1]
					loop
				ENDIF
				_aItem   :={}
				nQtdVen  := aVendas[nVendaIdx]['quantidade']
				nVlrUni  := aVendas[nVendaIdx]['valorDaEmbalagem']
				nVlrTot  := aVendas[nVendaIdx]['valorTotalDoItem']
				nVlrTab  := aVendas[nVendaIdx]['valorDaEmbalagem']
				nVlrDesc := aVendas[nVendaIdx]['valorDoDescontoTributado']
				cCSTPis  := StrZero(aVendas[nVendaIdx]['cstDoPISId'] ,2)
				cCSTCof  := StrZero(aVendas[nVendaIdx]['cstDoCOFINSId'],2 )

				cCFOP    := cValtoChar(aVendas[nVendaIdx]['cfopId'])

				criaSB2(SB1->B1_COD , cArmVnd)
				criaSB2(SB1->B1_COD , "01")


				IF '910' $ cCFOP // CASO SEJA CFOOP 5910 OU 6910 É BRINDE
					IF cEmpAnt =='11'
						cTes := "559"
					else
						cTes := "560"
					endif
				ELSE
					cTes :=  SB1->B1_TS
				EndIf

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
				aAdd( _aItem, {"LR_TES",  cTes 	, nil})	                                                    //      "501",
				aAdd( _aItem, {"LR_DOC",   cDoc  	, nil})	                                                //      "002502",
				aAdd( _aItem, {"LR_SERIE",   cSerie	, nil})	                                                //        "613",
				aAdd( _aItem, {"LR_ESPECIE", cEspecie 	, nil})	                                            //          "SATCE",
				aAdd( _aItem, {"LR_EMISSAO", dDataVnd	, nil})	                                            //          "20231021",
				aAdd( _aItem, {"LR_VEND",cVendPad    	, nil})	                                            //       "0251  ",
				aAdd( _aItem, {"LR_CF",   cCFOP   	, nil})	                                                //     "5102",
				aAdd( _aItem, {"LR_MODBC",    "0"	, nil})	                                                //        "0",
				aAdd( _aItem, {"LR_ORIGEM",  SB1->B1_ORIGEM	, nil})	                                        //         "1",
				aAdd( _aItem, {"LR_CSTPIS",  cCSTPis	, nil})	                                            //         "01",
				aAdd( _aItem, {"LR_CSTCOF",  cCSTCof	, nil})	                                            //         "01",



				//IMPOSTOS GABRIEL
				aAdd( _aItem, {"LR_VALICM"	, aVendas[nVendaIdx]['valorDoICMS']				, nil})	         //          0,
				aAdd( _aItem, {"LR_BASEICM"	, aVendas[nVendaIdx]['baseDeCalculoDoICMS']		, nil})	    	 //          0,
				aAdd( _aItem, {"LR_PICM"	, aVendas[nVendaIdx]['aliquotaDoICMS']			, nil})	    	 //          0,
				aAdd( _aItem, {"LR_BASEPS2"	, aVendas[nVendaIdx]['baseDeCalculoDoPIS']		, nil})	    	 //          0,
				aAdd( _aItem, {"LR_ALIQPS2"	, aVendas[nVendaIdx]['aliquotaDoPIS']			, nil})	    	 //          0,
				aAdd( _aItem, {"LR_VALPS2 "	, aVendas[nVendaIdx]['valorDoPIS']				, nil})	    	 //          0,
				aAdd( _aItem, {"LR_VALCF2"	, aVendas[nVendaIdx]['valorDoCOFINS']			, nil})	    	 //          0,
				aAdd( _aItem, {"LR_ALIQCF2"	, aVendas[nVendaIdx]['aliquotaDoCOFINS']		, nil})	    	 //          0,
				aAdd( _aItem, {"LR_BASECF2"	, aVendas[nVendaIdx]['baseDeCalculoDoCOFINS']	, nil})	    	 //          0,
				aAdd( _aItem, {"LR_BRICMS",  0.00	, nil})	                                                //         0,
				aAdd( _aItem, {"LR_ICMSRET", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_BASFECP", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_ALQFECP", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_VALFECP", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_ALQFCST", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_VFECPST", 0.00	, nil})	                                                //          0,
				aAdd( _aItem, {"LR_PREDIC",  0.00	, nil})	                                                //         0

				aadd(aSl2,_aItem)

			Next nVendaIdx

			//formas de pagamento, SL4
			U_VRN0159("[IMP SL4] - Inicio, Formas de Pagamento Cupons")

			aPgtos := oJsonZV1:GetJSonObject('items')
			aSl4 := {}

			IF!( '910' $ cCFOP)

				IF EMPTY(alltrim(cJson))
					cMsgErr2 := "Favor preencher a forma de pagamento no portal."
					Return
				ENDIF

				For nPgto := 1 To len(aPgtos)
					cCDFormPg :=  aPgtos[nPgto]['descForma']
					cFormPg :=  aPgtos[nPgto]['descForma']
					nvalor :=  aPgtos[nPgto]['valorForma']
					if alltrim(cFormPg) $"CC_CD"
						if alltrim(cFormPg) $"CC"
							nQtdpar := aPgtos[nPgto]['qtdParcelas']
						ELSE
							nQtdpar := 1
						ENDIF
						dbSelectArea("SAE")
						SAE->(dbSetOrder(1))
						SAE->(dbSeek(XFILIAL("SAE")+cCDFormPg))
						cAdmDesc:=    SAE->AE_COD + " - " + AllTrim(Upper(SAE->AE_DESC))
						//MDE_FILIAL, MDE_TIPO, MDE_CODSIT, R_E_C_N_O_, D_E_L_E_T_
						cDscRede := Posicione("MDE",3,xFilial("MDE")+padr(ALLTRIM("RD"),GETSX3CACHE("MDE_TIPO","X3_TAMANHO"))  +SAE->AE_REDEAUT,"MDE_DESC")
						cNsu     := aPgtos[nPgto]['nsu']
						cNsuAut  := aPgtos[nPgto]['nsuAutorizacao']
						cAutCar  := aPgtos[nPgto]['autorizacaoCartao']
						cCdBan 	 := SAE->AE_ADMCART
						cCdRede  := SAE->AE_REDEAUT
						cNumCart	:=  CRIAVAR("L4_NUMCART")
					ELSE
						nQtdpar := 1
					ENDIF

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
						cObs := padr(cvaltochar(nPgto),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
						aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
						aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(nPgto)     , NIL} )
						//	conout( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nPgto) )
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
							aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(nPgto)        , NIL} )
							cObs := padr(cvaltochar(nPgto),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
							aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
							aadd(aSl4,_aParcelas)
							//conout( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nPgto) )
						next nParc
					endif
				next nPgto
			ELSE
				aSl4 := {}
				_aParcelas := {}
				cFormPg :=  padr("R$",GETSX3CACHE("L4_FORMA","X3_TAMANHO"))
				aAdd( _aParcelas, {"L4_FILIAL"   , xFilial("SL4")    , NIL} )
				aAdd( _aParcelas, {"L4_FORMA"  , cFormPg      , NIL} )
				aAdd( _aParcelas, {"L4_TROCO"  , 0.00       , NIL} )
				aAdd( _aParcelas, {"L4_DATA"   , dDatabase    , NIL} )
				aAdd( _aParcelas, {"L4_VALOR"  , nvalor       , NIL} )
				cObs := padr(cvaltochar(1),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
				aAdd( _aParcelas, {"L4_OBS", CRIAVAR("L4_OBS")        , NIL} )
				aAdd( _aParcelas, {"L4_ADMINIS", CRIAVAR("L4_ADMINIS")      , NIL} )
				aAdd( _aParcelas, {"L4_FORMAID", CRIAVAR("L4_FORMAID")      , NIL} )
				//	conout( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nPgto) )
				aadd(aSl4,_aParcelas)
			endif
			if lProc .AND. LEN(_aCab)>0 .AND. LEN(aSL2)>0 .AND. LEN(aSl4)>0
				private  	lMsErroAuto := .F.
				private 	lAutoErrNoFile := .T.

				U_VRN0159("["+ alltrim(cDoc)+" / "+cSerie+"]  VAI CHAMAR O EXECAUTO")
				conout("["+ cDoc+" / "+cSerie+"]  VAI CHAMAR O EXECAUTO")
				SetFunName("LOJA701")
				MSExecAuto({|a,b,c,d,e,f,g,h,i,j| Loja701(a,b,c,d,e,f,g,h,i,j)}, .F., 3, "", "", {}, _aCab, aSL2,aSl4,.F.,.T.)
				If lMsErroAuto
					//    MOSTRAERRO()
					//    cErroAuto := MostraErro()
					cErro := ""
					aErro := GetAutoGRLog()

					For nERR := 1 To Len(aErro)
						cErro += aErro[nERR]
					Next nERR
					LjGrvLog(alltrim(cDoc)+" / "+cSerie, "Erro na execução da MSExecAuto - LOJA701", cErro) //"Erro na execução da MSExecAuto - LOJA701"

					fPutZV1(.F.,aParZV1,cStER,aItenJson[nIdx],,"ERRO NO EXECAUTO "+cErro)    //cStER  := "E" - ERRO
					//lProc := .f.
					cMsgErr2 := cRetErEx(cErro)
					loop
				else
					fPutZV1(.f.,aParZV1,"3",aItenJson[nIdx])
					ConfirmSx8()

					lZt := .T.
					RecLock("SL1", .F.)
					SL1->L1_SITUA := "RX"
					SL1->(MsUnLock())

				ENDIF
			ENDIF
		Next nIdx

		TZV1->( DbSkip())

	EndDo
Return



//#########################################################################################
// Funcao : fProcNFE
// Objetivo: Faz o processamento para validar se o Cliente foi cadastrado
//#########################################################################################

Static Function fProcNFE()
	//Processo de importação de cupons fiscais!
	Local  cParam1 := "MV_BCDTPRC" // data do ultimo processamento
	Local  cParam2 := "MV_BCIDPRC" // id do ultimo processamento
	Local cStPrc := "3" // status de processado  e disponivel para o gravabatch
	Local cStInPrc := "1" // status de em processamento
	Local cSt701 := "2" // chamou o execauto
	Local cStIni := "0" // Iniciando
	Local cStER := "E"  // ERRO
	Local cStCan := "C" // ERRO


	Local cEmpresa :=  NIL //supergetmv("MV_VFIDLJ",.F.,"3")
	Local nIdx
	Local nVendaIdx
	Local nFinalizacoesIdx
	Local cNumeroCupom := alltrim(SubStr(cGet1,26,9)) //DANIEL ROSA - PERSONALITEC - ADICIONADO PARA QUE SEJA POSSIVEL ACHAR A NOTA.  StrTran foi removido pois ficava "190" e não acha o cupom, apenas "000190 e "000000190"
	Local cEndPoint :=  NIL //SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local oCupons := JsonObject():New()
	Local cParser := ""
	Local cNumOrc := ""
	Local cCliPad   := NIL //PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	Local cLojPad   := NIL //PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	Local cVendPad  := NIL //PADR(alltrim( SuperGetMV("MV_VENDPAD")),getsx3cache("LQ_VEND","X3_TAMANHO"))
	lOCAL cTiposDoc 	:= NIL // AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	Local cSLGEst := NIL // supergetmv("MV_ZCDSLG",.F.,"004")  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	Local cOpera :=  NIL //supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	Local cArmVnd :=  NIL //supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA
	Local oCuponsFiscais :=  NIL //BuscaCupons(cEmpresa, cNumeroCupom, cEndPoint)

	Local  nSl4   := 0
	Local  nParc  := 0
	lOCAL nForRS  := 0.00
	lOCAL nForCD  := 0.00
	lOCAL nForCC  := 0.00
	lOCAL nForPix := 0.00
	lOCAL nForOut := 0.00
	lOCAL oTEF20  := NIL
	Local nERR    := 0
	Local lReproc := .F.

	Local nRecnoCli := 0
	Local aRetCli   := {}
	Local aRecnoCli := {}
	Local lCadCli   := .T.
	Local i := 1

	Private lMsErroAuto     := .F.  //Variavel que informa a ocorrência de erros no ExecAuto
	//Private lAutoErrNoFile  := .T.  //Habilita a gravacao do erro da rotina automatica
	//Private lMsHelpAuto     := .T.TOT

	cEmpresa  :=  supergetmv("MV_VFIDLJ",.F.,"3")
	cEndPoint :=  SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	cCliPad   :=  PADR("07035484" ,getsx3cache("A1_COD","X3_TAMANHO")) // PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	cLojPad   :=  PADR("0001",getsx3cache("A1_LOJA","X3_TAMANHO"))	 //PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	cVendPad  :=  PADR(alltrim( SuperGetMV("MV_VENDPAD")),getsx3cache("LQ_VEND","X3_TAMANHO"))
	cTiposDoc :=  AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	cSLGEst   := supergetmv("MV_ZCDSLG",.F.,IIF(cEmpAnt =="14","003","004"))  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	cOpera    := supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	cArmVnd   := supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA

	//PESQUISO A SERIE CONFORME CADASTRO DE ESTAÇÕES TABELA SLG LG_SERIE
	DbSelectArea("SLG")
	SLG->(DbSetOrder(1))
	If SLG->(DbSeek(xFilial("SLG")+padr(cSLGEst,getsx3cache("LG_CODIGO","X3_TAMANHO"))))
		cSerie  := alltrim(SLG->LG_SERNFIS)
		cPdv    := SLG->LG_PDV
		cSerSat := SLG->LG_SERSAT
	endif

	oCuponsFiscais := BuscaCupons(cEmpresa, cNumeroCupom, cSerie, cEndPoint)
	cParser := oCupons:FromJson(oCuponsFiscais)
	aItenJson := oCupons:GetJSonObject('items')

	chkfile("ZV1")
	aAdmin := fGetAdm()

	CONOUT("STOP")


	If valtype(aItenJson) != "A"
		oCuponsFiscais :='{"items":['+oCuponsFiscais+']}'
		oCupons:FromJson(oCuponsFiscais)
		aItenJson := oCupons:GetJSonObject('items')
	EndIf

	IF aItenJson == NIL .OR. LEN(aItenJson) == 0
		cMsgErr2 := "- não foram encontrados cupons para serem importados"
	ENDIF

	For nIdx := 1 To Len(aItenJson)

		lProc := .t.
		//Caso a serie esteja em branco nao processa as vendas
		IF  alltrim(aItenJson[nIdx]['situacao']) =="PENDENTE"

			U_VRN0159("[IMP SL1] -VENDA NAO AUTORIZADA ")
			lProc := .f.
			cMsgErr2 := "- Venda nao autorizada"
			loop

		ELSEIF alltrim(aItenJson[nIdx]['situacao']) =="INUTILIZADA"

			U_VRN0159("[IMP SL1] -VENDA INUTILIZADA ")
			lProc := .f.
			cMsgErr2 := "- Venda Inutilizada"
			loop

		ENDIF

		//Cabeçalho do cupom,  SL1
		U_VRN0159("[IMP SL1] - Inicio, Cabecalho Cupons")
		cChvNfce    := aItenJson[nIdx]['chaveDaNfe']

		cDoc   :=  PADR( STRZERO(Val(SubStr(cChvNfce,26,9)),6),9)
		nValor      := aItenJson[nIdx]['valorDoDocumento']
		cCgcCli     := aItenJson[nIdx]['valcpfConsumidor']
		cSerie      :=  PADR(alltrim(aItenJson[nIdx]['serie']),3)
		dDataVnd    := stod(STRTRAN(SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10), "-", ""))
		dDatabase   := dDataVnd
		cHrVend     := substr(aItenJson[nIdx]['dataOperacao'],12,8)
		cIdCliente	:= aItenJson[nIdx]:GetJSonObject('clienteId')


		//Caso a serie esteja em branco nao processa as vendas
		IF EMPTY(cSerie)

			U_VRN0159("[IMP SL1] - Sem cadastro de estacao ou Serie em branco ")
			lProc := .f.
			cMsgErr2 := "Sem cadastro de estacao ou Serie em branco"
			loop
		ENDIF
		nPosID := 1
		nPosDoc := 2
		nPosSer := 3
		nPosDtVd := 5
		nPosSLG := 4
		cStatus := "0"

		aParZV1:= {;
			aItenJson[nIdx]['id'],;
			cDoc,;
			cSerie,;
			cPdv   ,;
			dDataVnd}

		ZV1->(DbSetOrder(1))
		If !ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aItenJson[nIdx]['id'],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
			fPutZV1(.t.,aParZV1,cStIni,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"
		endif

		if alltrim(aItenJson[nIdx]['situacao']) =="CANCELADA"
			//alert("Cancelada, Debugar")
			fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.

		ENDIF

		cEspecie := LjNfEspeci(cSerie, cTiposDoc)
		CONOUT("STOP")

		// Monta cabeçalho do orçamento (SLQ)
		//1 ) Procuta se a venda ja ´se encontra na SL1 para nao ter chave duplicada
		//Caso encontre nao processa porem valida o SL1 lL1_SITUA PARA ATUALIZAÇÃO DA TABELA DE CONTROLE

		DbSelectArea("SL1")
		SL1->(DbSetOrder(2)) //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV, R_E_C_N_O_, D_E_L_E_T_
		IF  SL1->(MsSeek(xFilial("SL1")+cSerie+cDoc+cPdv))
			lProc := .f.
			if !lReproc
				fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10))
				fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['id']))
				if SL1->L1_SITUA == "OK"
					fPutZV1(.f.,aParZV1,cStPrc,aItenJson[nIdx])     //cStPrc := "3 - PROCESSADO"
				ELSEIF  SL1->L1_SITUA  == "RX"
					fPutZV1(.f.,aParZV1,cSt701,aItenJson[nIdx])     //cSt701 := "2 - CHAMOU EXECAUTO"
				ELSEIF  SL1->L1_SITUA  == "ER"
					fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx])      //cStER  := "E" - ERRO

				endif
			endif
			U_VRN0159("[IMP SL1] - DOCUMENTO JA IMPORTADO ")
			cMsgErr2 := "Documento ja importado - SL1"
			loop
		ENDIF

		aRetCli := zExistCli(cvaltochar(cIdCliente), cEndpoint )
		lretCli := aRetCli[1]
		if aRetCli[1] == .T. //Se existe o cliente

			aRecnoCli := aRetCli[3]
			DBSELECTAREA( "SA1" )

			for i:= 1 to len(aRetCli[3])
				SA1->(DBGOTOP())
				SA1->(DBGOTO(aRetCli[3][i]))

				// Se existe na Base e CPF / CNPJ  exista na base e o CEP seja igual A1_CEP e  SE LOGRADOURO (ORIGEM API) Pertence a A1_END
				//RETORNA A1_COD / A1_LOJA PARA SER UTILIZADO COMO CLIENTE NA Nota
				IF SA1->A1_CEP == strtran(aRetCli[2]['enderecos'][1]['cep'],'-','') .and. aRetCli[2]['enderecos'][1]['logradouro'] $ SA1->A1_END
					cCliPad	:= SA1->A1_COD
					cLojPad	:= SA1->A1_LOJA
					lCadCli := .F.
					EXIT
				ENDIF
			next

			if lCadCli
				conout('inserir cliente')
				lretCli := 		zCadCli(aRetCli[2])
			ENDIF

		else
			conout('inserir cliente')
			lretCli := 	zCadCli(aRetCli[2])
		endif
		if lretCli
			fPutZV1(.T.,aParZV1,cStInPrc,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"
			fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10))
			fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['id']))
		else
			fPutZV1(.f.,aParZV1,"E",aItenJson[nIdx],,"Não foi possivel cadastrar o Cliente") //cStIni := "0 - INICIANDO"
			lProc := .f.
			cMsgErr2 := "Nao foi possivel cadastrar o Cliente"
			loop
		endif


	Next nIdx

	conout("stop")
	//  RESET ENVIRONMENT
	// 1 Rio Negro, SP, Empresa 14 Filial 1
	// 3 Donato São Pedro, BH, Empresa 11 Filial 1
	// Verificar se vamos usar cliente padrão;
	// SAT até 10 mil reais
	//Inicio processo de importaçao de cupons fiscais para tabelas:

Return
//###########################################################################################################
// Funcao : FPROCZV1
// Objetivo: Faz a busca na api do varejo facil  	https://buddemeyer.varejofacil.com/api/v1/venda/notas-fiscais
// com base no ultimo documento importado que é atrave dos parametros MV_BCDTPRC / MV_BCIDPRC,
// feito isso ele arazena na tabela zv1
//###########################################################################################################


Static Function fProcZV1()
	//Processo de importação de cupons fiscais!
	Local  cParam1 := "MV_BCDTPRC" // data do ultimo processamento
	Local  cParam2 := "MV_BCIDPRC" // id do ultimo processamento
	Local cStPrc := "3" // status de processado  e disponivel para o gravabatch
	Local cStInPrc := "1" // status de em processamento
	Local cSt701 := "2" // chamou o execauto
	Local cStIni := "0" // Iniciando
	Local cStER := "E"  // ERRO
	Local cStCan := "C" // ERRO


	Local cEmpresa :=  NIL //supergetmv("MV_VFIDLJ",.F.,"3")
	Local nIdx
	Local nVendaIdx
	Local nFinalizacoesIdx
	Local cNumeroCupom := alltrim(SubStr(cGet1,26,9)) //DANIEL ROSA - PERSONALITEC - ADICIONADO PARA QUE SEJA POSSIVEL ACHAR A NOTA.  StrTran foi removido pois ficava "190" e não acha o cupom, apenas "000190 e "000000190"
	Local cEndPoint :=  NIL //SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local oCupons := JsonObject():New()
	Local cParser := ""
	Local cNumOrc := ""
	Local cCliPad   := NIL //PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	Local cLojPad   := NIL //PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	Local cVendPad  := NIL //PADR(alltrim( SuperGetMV("MV_VENDPAD")),getsx3cache("LQ_VEND","X3_TAMANHO"))
	lOCAL cTiposDoc 	:= NIL // AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	Local cSLGEst := NIL // supergetmv("MV_ZCDSLG",.F.,"004")  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	Local cOpera :=  NIL //supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	Local cArmVnd :=  NIL //supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA
	Local oCuponsFiscais :=  NIL //BuscaCupons(cEmpresa, cNumeroCupom, cEndPoint)

	Local  nSl4 := 0
	Local  nParc := 0
	lOCAL nForRS :=0.00
	lOCAL nForCD :=0.00
	lOCAL nForCC :=0.00
	lOCAL nForPix :=0.00
	lOCAL nForOut :=0.00
	lOCAL oTEF20 := NIL
	Local nERR := 0
	Local lReproc := .F.

	Local nRecnoCli :=0
	Local aRetCli := {}
	Local aRecnoCli := {}
	Local lCadCli := .T.
	Local i := 1

	Private lMsErroAuto       := .F.  //Variavel que informa a ocorrência de erros no ExecAuto
	//Private lAutoErrNoFile  := .T.  //Habilita a gravacao do erro da rotina automatica
	//Private lMsHelpAuto     := .T.TOT

	cEmpresa  := supergetmv("MV_VFIDLJ",.F.,"3")
	cEndPoint := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	cCliPad   :=  PADR("07035484" ,getsx3cache("A1_COD","X3_TAMANHO")) // PADR(alltrim( SuperGetMV( "MV_CLIPAD",,"000001" )),getsx3cache("A1_COD","X3_TAMANHO"))	// Cliente Padrao
	cLojPad   := PADR("0001",getsx3cache("A1_LOJA","X3_TAMANHO"))	 //PADR(alltrim( SuperGetMV( "MV_LOJAPAD",,"01" )),getsx3cache("A1_LOJA","X3_TAMANHO"))		// Loja do Cliente Padrao
	cVendPad  :=  PADR(alltrim( SuperGetMV("MV_VENDPAD")),getsx3cache("LQ_VEND","X3_TAMANHO"))
	cTiposDoc := AllTrim( SuperGetMv( 'MV_ESPECIE' ) )
	cSLGEst   := supergetmv("MV_ZCDSLG",.F.,IIF(cEmpAnt =="14","003","004"))  // PARAMETRO QUE CONTROLA QUAL A ESTAÇÃO CODIGO SLG SERA CONSIDERADO POR FILIAL
	cOpera    := supergetmv("MV_ZCDOPE",.F., IIF(cEmpAnt =="14","C01","C02"))  // PARAMETRO QUE CONTROLA QUAL O CODIGO DO OPERADOR
	cArmVnd   := supergetmv("MV_ZARMVND",.F.,'10')  // PARAMETROPARA DEFINIR QUAL O ALMOXARIFADO PADRAO DA VENDA

	//PESQUISO A SERIE CONFORME CADASTRO DE ESTAÇÕES TABELA SLG LG_SERIE
	DbSelectArea("SLG")
	SLG->(DbSetOrder(1))
	If SLG->(DbSeek(xFilial("SLG")+padr(cSLGEst,getsx3cache("LG_CODIGO","X3_TAMANHO"))))
		cSerie  := alltrim(SLG->LG_SERNFIS)
		cPdv    := SLG->LG_PDV
		cSerSat := SLG->LG_SERSAT
	endif

	oCuponsFiscais := BuscaCupons(cEmpresa, cNumeroCupom, cSerie, cEndPoint)
	cParser := oCupons:FromJson(oCuponsFiscais)
	aItenJson := oCupons:GetJSonObject('items')

	chkfile("ZV1")
	aAdmin := fGetAdm()

	CONOUT("STOP")

	If valtype(aItenJson) != "A"
		oCuponsFiscais :='{"items":['+oCuponsFiscais+']}'
		oCupons:FromJson(oCuponsFiscais)
		aItenJson := oCupons:GetJSonObject('items')
	EndIf

	IF aItenJson == NIL .OR. LEN(aItenJson) == 0
		cMsgErr2 :=  "- não foram encontrados cupons para serem importados"
	ENDIF

	For nIdx := 1 To Len(aItenJson)
		lZt := .T.
		lProc := .t.
		//Caso a serie esteja em branco nao processa as vendas
		IF  alltrim(aItenJson[nIdx]['situacao']) == "PENDENTE"

			U_VRN0159("[IMP SL1] -VENDA NAO AUTORIZADA ")
			lProc := .f.
			cMsgErr2 := "- Venda nao autorizada"
			loop

		ELSEIF alltrim(aItenJson[nIdx]['situacao']) =="INUTILIZADA"

			U_VRN0159("[IMP SL1] -VENDA INUTILIZADA ")
			lProc := .f.
			cMsgErr2 := "Venda Inutilizada"
			loop

		ENDIF

		//Cabeçalho do cupom,  SL1
		U_VRN0159("[IMP SL1] - Inicio, Cabecalho Cupons")
		cChvNfce    := aItenJson[nIdx]['chaveDaNfe']

		cDoc   :=  PADR( STRZERO(Val(SubStr(cChvNfce,26,9)),6),9)
		nValor      := aItenJson[nIdx]['valorDoDocumento']
		cCgcCli     := aItenJson[nIdx]['valcpfConsumidor']
		cSerie      :=  PADR(alltrim(aItenJson[nIdx]['serie']),3)
		dDataVnd    := stod(STRTRAN(SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10), "-", ""))
		dDatabase   := dDataVnd
		cHrVend     := substr(aItenJson[nIdx]['dataOperacao'],12,8)
		cIdCliente	:= aItenJson[nIdx]:GetJSonObject('clienteId')

		//Caso a serie esteja em branco nao processa as vendas
		IF EMPTY(cSerie)

			U_VRN0159("[IMP SL1] - Sem cadastro de estação ou Serie em branco ")
			lProc := .f.
			cMsgErr2 := "- Sem cadastro de estação ou Serie em branco "
			loop
		ENDIF
		nPosID := 1
		nPosDoc := 2
		nPosSer := 3
		nPosDtVd := 5
		nPosSLG := 4
		cStatus := "0"

		aParZV1:= {;
			aItenJson[nIdx]['id'],;
			cDoc,;
			cSerie,;
			cPdv   ,;
			dDataVnd}

		ZV1->(DbSetOrder(1))
		If !ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aItenJson[nIdx]['id'],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
			fPutZV1(.t.,aParZV1,cStIni,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"

		endif

		if alltrim(aItenJson[nIdx]['situacao']) =="CANCELADA"

			//alert("Cancelada, Debugar")
			fPutZV1(.F.,aParZV1,cStCan,aItenJson[nIdx], .T.)   //cStCan := "C" CANCELADO  e lCanc := .T.

		ENDIF


		cEspecie := LjNfEspeci(cSerie, cTiposDoc)
		CONOUT("STOP")

		// Monta cabeçalho do orçamento (SLQ)

		//1 ) Procuta se a venda ja ´se encontra na SL1 para nao ter chave duplicada
		//Caso encontre nao processa porem valida o SL1 lL1_SITUA PARA ATUALIZAÇÃO DA TABELA DE CONTROLE

		DbSelectArea("SL1")
		SL1->(DbSetOrder(2)) //L1_FILIAL, L1_SERIE, L1_DOC, L1_PDV, R_E_C_N_O_, D_E_L_E_T_
		IF  SL1->(MsSeek(xFilial("SL1")+cSerie+cDoc+cPdv))
			lProc := .f.
			if !lReproc
				fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10))
				fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['id']))
				if SL1->L1_SITUA == "OK"
					fPutZV1(.f.,aParZV1,cStPrc,aItenJson[nIdx])     //cStPrc := "3 - PROCESSADO"
				ELSEIF  SL1->L1_SITUA  == "RX"
					fPutZV1(.f.,aParZV1,cSt701,aItenJson[nIdx])     //cSt701 := "2 - CHAMOU EXECAUTO"
				ELSEIF  SL1->L1_SITUA  == "ER"
					fPutZV1(.f.,aParZV1,cStER,aItenJson[nIdx])      //cStER  := "E" - ERRO

				endif
			endif
			lZt := .F.
			U_VRN0159("[IMP SL1] - DOCUMENTO JA IMPORTADO ")
			cMsgErr2 := "Documento ja importado - SL1"
			loop
		ENDIF

		aRetCli := zExistCli(cvaltochar(cIdCliente), cEndpoint )
		lretCli := aRetCli[1]
		if aRetCli[1] == .T. //Se existe o cliente

			aRecnoCli := aRetCli[3]

			DBSELECTAREA( "SA1" )

			for i:= 1 to len(aRetCli[3])
				SA1->(DBGOTOP())
				SA1->(DBGOTO(aRetCli[3][i]))

				// Se existe na Base e CPF / CNPJ  exista na base e o CEP seja igual A1_CEP e  SE LOGRADOURO (ORIGEM API) Pertence a A1_END
				//RETORNA A1_COD / A1_LOJA PARA SER UTILIZADO COMO CLIENTE NA Nota
				IF SA1->A1_CEP == strtran(aRetCli[2]['enderecos'][1]['cep'],'-','')
					//.and. aRetCli[2]['enderecos'][1]['logradouro'] $ SA1->A1_END

					cCliPad	:= SA1->A1_COD
					cLojPad	:= SA1->A1_LOJA

					lCadCli := .F.

					EXIT
				else
					cCliPad	:= SA1->A1_COD
					cLojPad	:= SA1->A1_LOJA
					lCadCli := .t.
				ENDIF
			next

			if lCadCli
				conout('inserir cliente')
				lretCli := 		zCadCli(aRetCli[2])
			ENDIF

		else
			conout('inserir cliente')
			lretCli := 	zCadCli(aRetCli[2])
		endif
		//lretCli :=.t.
		if lretCli
			ZV1->(DbSetOrder(1))
			If !ZV1->(DbSeek(xFilial("ZV1")+STRZERO(aItenJson[nIdx]['id'],getsx3cache("ZV1_IDVEND","X3_TAMANHO") )))
				fPutZV1(.T.,aParZV1,cStInPrc,aItenJson[nIdx]) //cStIni := "0 - INICIANDO"
			endif
			fVFPutSX6(cParam1,SUBSTR(aItenJson[nIdx]['dataEmissao'],1,10))
			fVFPutSX6(cParam2,cvaltochar(aItenJson[nIdx]['id']))
		else
			fPutZV1(.f.,aParZV1,"E",aItenJson[nIdx],,"Não foi possivel cadastrar o Cliente") //cStIni := "0 - INICIANDO"
			lProc := .f.
			cMsgErr2 := " - Nao foi possivel cadastrar o Cliente"
			loop
		endif


	Next nIdx

	conout("stop")
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
Static Function BuscaCupons(cEmpresa, cNumeroCupom, cSerie, cEndPoint)
	DEFAULT cNumeroCupom := ""
	//Local dDataAtual := DToS(Date(), "YYYY-MM-DD")
	// '=ge='
	Local  cDtPrc := alltrim(SuperGetMV("MV_BCDTPRC",.f.))
	Local  cIDPrc := alltrim(SuperGetMV("MV_BCIDPRC",.f.,"0"))
	Local dDataAtual := cDtPrc

	Local cURL := ""

	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	SLEEP(10)
	cIDPrc := "55310"
	cToken := BuscaToken(cEndPoint)
	cURL := cEndPoint + '/v1/venda/notas-fiscais?count=100&q=lojaId==' + cEmpresa
	if empty(cNumeroCupom)
		cURL +=';id=ge='+cIDPrc
		//cURL +=';dataEmissao=ge='+dDataAtual
	else
		cURL +=';numeroNota=='+ CVALTOCHAR(val(cNumeroCupom))
	endif
	cURL +=';tipoDeOperacao==SAIDA'

	//cURL +=';dataEmissao=le=2024-02-29'
	//
	cURL +=';serie=='+ALLTRIM(cSerie)+'&sort=id'
	// cURL := cEndPoint + '/v1/venda/cupons-fiscais/000087-001-1700103600000-3'
	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cURL, "", nTimeOut,aHeadOut,@cHeadGet)
	if !empty(cResponse)// .AND.  !("erro interno" $   cResponse)
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

/*/{Protheus.doc} fGetPrd
Retorna produtoId
    @type function
    @version
    @since 10/30/2023
    @param cIdPrd, character, param_description
    @return variant, return_description
/*/
static function fGetPrd(cIdPrd)
	Local dDataAtual := "2023-10-06"
	Local cEndPoint := SuperGetMV( "MV_ENDPNT",,"https://buddemeyer.varejofacil.com/api" )
	Local cToken := BuscaToken(cEndPoint)
	// Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=100000&q=dataVenda==' + dDataAtual + ';lojaId==' + cEmpresa
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

		AAdd(aADMCart, {	SAE->AE_COD						    ,; //01-Codifo da Adm. Financeira
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
		oJson:DelName("itens")
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

//Busco Cliente
Static Function BuscaCliente(cEmpresa, cEndPoint, cIdCliente)
	Local oJson := JsonObject():New()
	Local  cDtPrc := alltrim(SuperGetMV("MV_VFDTPRC",.f.))
	Local  cIDPrc := alltrim(SuperGetMV("MV_VFIDPRC",.f.))
	Local dDataAtual := cDtPrc
	Local cToken := BuscaToken(cEndPoint)
	//Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=100000&q=dataVenda==' + dDataAtual + ';lojaId==' + cEmpresa
	Local cURL := cEndPoint + "/v1/pessoa/clientes"
	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	Local cParser := ""

	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
	if !empty(cResponse)
		U_VRN0159("[OK 02] - Buscou clientes")
		cParser := oJson:FromJson(cResponse)
		cResponse:= oJson:GetJsonObject('items')
	Else
		U_VRN0159("[ERRO 02] - clientes")
	EndIf
Return  cResponse

//Busco Cliente por Id
Static Function BuscaCliId(cEmpresa, cEndPoint, cIdCliente)
	Local oJson := JsonObject():New()
	Local  cDtPrc := alltrim(SuperGetMV("MV_VFDTPRC",.f.))
	Local  cIDPrc := alltrim(SuperGetMV("MV_VFIDPRC",.f.))
	Local dDataAtual := cDtPrc
	Local cToken := BuscaToken(cEndPoint)
	//Local cURL := cEndPoint + '/v1/venda/cupons-fiscais?count=100000&q=dataVenda==' + dDataAtual + ';lojaId==' + cEmpresa
	Local cURL := cEndPoint + "/v1/pessoa/clientes/"+cIdCliente
	Local cResponse := ''
	Local nTimeOut := 30
	Local aHeadOut := {}
	Local cHeadGet := ""
	Local cParser := ""

	AAdd(aHeadOut, 'Content-Type: application/json' )
	Aadd(aHeadOut,'Authorization:' + ctoken)
	cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
	if !empty(cResponse)
		U_VRN0159("[OK 02] - Buscou clientes")
		cParser := oJson:FromJson(cResponse)
		//cResponse:= oJson:GetJsonObject('items')
	Else
		U_VRN0159("[ERRO 02] - clientes")
	EndIf
Return  oJson

STATIC FUNCTION zExistCli(cIdCliente, cEndPoint)

	Local cEmpresa := cEmpAnt
	Local oCliente := BuscaCliId(cEmpresa, cEndPoint, cIdCliente)
	Local lExiste := .F.
	Local aRecno := {}
	Local aRet	:={}

	private nRecnoCli := 0

	//Procura na base e verifica se tem o mesmo endereço
	cQuery:=""
	cQuery+="SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_NOME, A1_CGC, A1_CEP, A1_END, A1_PFISICA, SA1.R_E_C_N_O_ AS RECNO FROM "+Retsqlname("SA1")+" SA1"
	cQuery+=" WHERE SA1.D_E_L_E_T_=''"
	cQuery+=" AND SA1.A1_CGC='"+oCliente['numeroDoDocumento']+"'"

	MPSysOpenQuery( cQuery, 'TEMP' )

	TEMP->(dbgotop())
	while TEMP->(!eof())
		If !EMPTY(TEMP->A1_COD)
			lExiste := .T.	//Cliente existe na base!!!
			aadd(aRecno, TEMP->RECNO)
			conout('O Cliente Existe na Base!')
		endif
		TEMP->(Dbskip())
	end

	TEMP->(dbcloseArea())

	aRet:={lExiste, oCliente, aRecno}

return aRet

/*/{Protheus.doc} VRN0164T
Utilizado para chamar a função u_VRN0164 via RPC.
	@type function
	@since 11/1/2023
	@return variant, return_description
/*/
User function VRN0164T()

	RpcSetType(3)
	RpcSetEnv( "14", "01")
	u_VRN0164()
	RpcCLearEnv()

Return


static function zCadCli(oCliente)

	Local aSA1Auto  := {}
	Local aAI0Auto  := {}
	lOCAL aErro :={}
	Local nY:=1
	Local cLog:=''
	Local clog1:=''
	Local nOpcAuto  := 3
	LOCAL cErro:=''
	Local lRet := .T.
	Local aDados := {}
	Local nERR := 0
	cEmpresa := cEmpAnt
	Private lMsErroAuto        := .F.
	//TRATAMENTO aDados
	aadd( aDados,	{ "A1_TIPO"   	,	IIF(oCliente:GetJsonObject('tipoContribuinte') == 'CONTRIBUINTE','R','F' )})
	aadd( aDados,	{ "A1_COD"    	,	""	})
	aadd( aDados,	{ "A1_LOJA"   	,	""	})
	aadd( aDados,	{ "A1_NOME"   	,	oCliente:GetJsonObject('nome')})
	aadd( aDados,	{ "A1_NREDUZ" 	,	oCliente:GetJsonObject('fantasia')})
	aadd( aDados,	{ "A1_END"    	,	decodeutf8(alltrim(oCliente["enderecos"][1]:GetJsonObject('logradouro'))+', '+alltrim(oCliente["enderecos"][1]:GetJsonObject('numero')))})
	aadd( aDados,	{ "A1_EST"    	,	oCliente["enderecos"][1]:GetJsonObject('uf')})
	aadd( aDados,	{ "A1_MUN"    	,	decodeutf8(oCliente["enderecos"][1]:GetJsonObject('municipio'))})
	aadd( aDados,	{ "A1_NATUREZ"	,	'00101'})
	aadd( aDados,	{ "A1_PAIS"		,	IIF(oCliente["enderecos"][1]:GetJsonObject('codigoDoPais') == NIL, '', cValtochar(oCliente["enderecos"][1]:GetJsonObject('codigoDoPais')))})
	aadd( aDados,	{ "A1_CONTA"	,	'112010015'})
	aadd( aDados,	{ "A1_CODPAIS"	,	'01058'})

	// /*CAMPOS ABAIXO NÃO OBRIGATÓRIOS NO PROTHEUS E SEM OBRIGATORIEDADE NO FRONT, VALIDADOS COM IIF == NIL */
	aadd( aDados,	{ "A1_COD_MUN"	,	IIF( oCliente["enderecos"][1]:GetJsonObject('codigoIbge') == NIL, 	'', 	SUBSTR(cValtoChar(oCliente["enderecos"][1]:GetJsonObject('codigoIbge')),3,5))})
	aadd( aDados,	{ "A1_CEP"		,	IIF( oCliente["enderecos"][1]:GetJsonObject('cep') == NIL,			'', 	STRTRAN(oCliente["enderecos"][1]:GetJsonObject('cep'),'-',''))})
	aadd( aDados,	{ "A1_BAIRRO" 	,	IIF( oCliente["enderecos"][1]:GetJsonObject('bairro') == NIL,		'', 	decodeutf8(oCliente["enderecos"][1]:GetJsonObject('bairro')))})
	aadd( aDados,	{ "A1_COMPLEM" 	,	IIF( oCliente["enderecos"][1]:GetJsonObject('complemento') == NIL, 	'',		decodeutf8(oCliente["enderecos"][1]:GetJsonObject('complemento')))})
	aadd( aDados,	{ "A1_TEL" 		,	IIF( oCliente:GetJsonObject('telefone1') == NIL, 					'', 	SUBSTR(oCliente:GetJsonObject('telefone1'),3,9))})
	aadd( aDados,	{ "A1_CELULAR" 	,	IIF( oCliente:GetJsonObject('telefone2') == NIL,					'', 	SUBSTR(oCliente:GetJsonObject('telefone2'),3,9))})
	aadd( aDados,	{ "A1_EMAIL" 	,	IIF( oCliente:GetJsonObject('email') == NIL, 						'', 	LOWER(oCliente:GetJsonObject('email')))})
	aadd( aDados,	{ "A1_CONTRIB"	,	IIF( oCliente:GetJsonObject('tipoContribuinte') == NIL,				'', 	IF(oCliente:GetJsonObject('tipoContribuinte') == "NAO_CONTRIBUINTE", '2','1'))})
	aadd( aDados,	{ "A1_ENDCOB" 	,	IIF( len(oCliente["enderecos"]) > 1, 	Alltrim(oCliente["enderecos"][2]:GetJsonObject('logradouro'))+', '+alltrim(oCliente["enderecos"][2]:GetJsonObject('numero')),Alltrim(oCliente["enderecos"][1]:GetJsonObject('logradouro'))+', '+alltrim(oCliente["enderecos"][1]:GetJsonObject('numero')))})
	aadd( aDados,	{ "A1_PFISICA" 	,	IIF( oCliente:GetJsonObject('numeroDeIdentificacao') == NIL, 		'', 	oCliente:GetJsonObject('numeroDeIdentificacao'))})
	aadd( aDados,	{ "A1_CGC" 		,	IIF( oCliente:GetJsonObject('numeroDoDocumento') == NIL, 			'', 	oCliente:GetJsonObject('numeroDoDocumento'))})
	IF oCliente:GetJsonObject('tipoDePessoa') =="FISICA"
		cA1Pessoa := "F"
	ELSE
		cA1Pessoa := "J"
	ENDIF
	aadd( aDados,	{ "A1_PESSOA" 	,	cA1Pessoa})
	aadd( aDados,	{ "A1_DDD" 		,	IIF(oCliente:GetJsonObject('telefone1') == NIL, 					'', 	SUBSTR(oCliente:GetJsonObject('telefone1'),1,2))})
	aadd( aDados,	{ "A1_RISCO" 	,	'A'})
	aadd( aDados,	{ "A1_DDDCEL" 	,	IIF(oCliente:GetJsonObject('telefone2') == NIL, 					'', 	SUBSTR(oCliente:GetJsonObject('telefone2'),1,2))})
	aadd( aDados,	{ "A1_TABELA" 	,	'001'})

	cZloja := "01"

	cQuer61 := " SELECT A1_LOJA FROM "+RetSqlName("SA1")+ " s "
	cQuer61 += " WHERE D_E_L_E_T_ = ' ' "
	cQuer61 += " AND A1_CGC = "+valtosql(PADR(aDados[23][2]    	,FWSX3Util():GetFieldStruct( ("A1_CGC"))[3]) )
	cQuer61 += " ORDER BY R_E_C_N_O_ DESC

	cAlias61 := GetNextAlias()

	MPSysOpenQuery(cQuer61,cAlias61)

	IF (cAlias61)->(!EOF())
		cZloja := soma1(alltrim((cAlias61)->A1_LOJA))
	ENDIF
	//----------------------------------
	// Dados do Cliente
	//----------------------------------
	aSA1Auto:={}
	aAdd(aSA1Auto,{"A1_TIPO"            ,PADR(aDados[1][2]  	,FWSX3Util():GetFieldStruct( ("A1_TIPO"))[3])         	,Nil})
	aAdd(aSA1Auto,{"A1_CGC"         	,PADR(aDados[23][2]    	,FWSX3Util():GetFieldStruct( ("A1_CGC"))[3])      		,Nil})
	//aAdd(aSA1Auto,{"A1_COD"             ,PADR(aDados[2][2]  	,FWSX3Util():GetFieldStruct( ("A1_COD"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_LOJA"            ,PADR(cZloja  	,FWSX3Util():GetFieldStruct( ("A1_LOJA"))[3])         	,Nil})
	aAdd(aSA1Auto,{"A1_NOME"            ,PADR(aDados[4][2]  	,FWSX3Util():GetFieldStruct( ("A1_NOME"))[3])         	,Nil})
	aAdd(aSA1Auto,{"A1_NREDUZ"          ,PADR(aDados[5][2]  	,FWSX3Util():GetFieldStruct( ("A1_NREDUZ"))[3])       	,Nil})
	aAdd(aSA1Auto,{"A1_END"             ,PADR(aDados[6][2]  	,FWSX3Util():GetFieldStruct( ("A1_END"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_EST"             ,PADR(aDados[7][2]  	,FWSX3Util():GetFieldStruct( ("A1_EST"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_MUN"             ,PADR(aDados[8][2]  	,FWSX3Util():GetFieldStruct( ("A1_MUN"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_NATUREZ"         ,PADR(aDados[9][2]  	,FWSX3Util():GetFieldStruct( ("A1_NATUREZ"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_PAIS   "         ,PADR(aDados[10][2]   	,FWSX3Util():GetFieldStruct( ("A1_PAIS"))[3])         	,Nil})
	aAdd(aSA1Auto,{"A1_CONTA  "         ,PADR(aDados[11][2]   	,FWSX3Util():GetFieldStruct( ("A1_CONTA"))[3])        	,Nil})
	aAdd(aSA1Auto,{"A1_CODPAIS"         ,PADR(aDados[12][2]    	,FWSX3Util():GetFieldStruct( ("A1_CODPAIS"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_COD_MUN"         ,PADR(aDados[13][2]    	,FWSX3Util():GetFieldStruct( ("A1_COD_MUN"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_CEP"         	,PADR(aDados[14][2]    	,FWSX3Util():GetFieldStruct( ("A1_CEP"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_BAIRRO"         	,PADR(aDados[15][2]    	,FWSX3Util():GetFieldStruct( ("A1_BAIRRO"))[3])       	,Nil})
	aAdd(aSA1Auto,{"A1_COMPLEM"       	,PADR(aDados[16][2]    	,FWSX3Util():GetFieldStruct( ("A1_COMPLEM"))[3])    	,Nil})
	aAdd(aSA1Auto,{"A1_TEL"         	,PADR(aDados[17][2]    	,FWSX3Util():GetFieldStruct( ("A1_TEL"))[3])          	,Nil})
	aAdd(aSA1Auto,{"A1_CELULAR"         ,PADR(aDados[18][2]    	,FWSX3Util():GetFieldStruct( ("A1_CELULAR"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_EMAIL"         	,PADR(aDados[19][2]    	,FWSX3Util():GetFieldStruct( ("A1_EMAIL"))[3])        	,Nil})
	aAdd(aSA1Auto,{"A1_CONTRIB"         ,PADR(aDados[20][2]    	,FWSX3Util():GetFieldStruct( ("A1_CONTRIB"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_ENDCOB"         	,PADR(aDados[21][2]    	,FWSX3Util():GetFieldStruct( ("A1_ENDCOB"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_PFISICA"         ,PADR(aDados[22][2]    	,FWSX3Util():GetFieldStruct( ("A1_PFISICA"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_PESSOA"         	,PADR(aDados[24][2]    	,FWSX3Util():GetFieldStruct( ("A1_PESSOA"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_DDD"         	,PADR(aDados[25][2]    	,FWSX3Util():GetFieldStruct( ("A1_DDD"))[3])      		,Nil})
	aAdd(aSA1Auto,{"A1_RISCO"         	,PADR(aDados[26][2]    	,FWSX3Util():GetFieldStruct( ("A1_RISCO"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_DDDCEL"         	,PADR(aDados[27][2]    	,FWSX3Util():GetFieldStruct( ("A1_DDDCEL"))[3])      	,Nil})
	aAdd(aSA1Auto,{"A1_TABELA"         	,PADR(aDados[28][2]    	,FWSX3Util():GetFieldStruct( ("A1_TABELA"))[3])      	,Nil})
	aCliente := FWVetByDic(aSA1Auto,"SA1",.F.)
	lMsErroAuto := .F.
	//private lAutoErrNoFile := .T.

	//------------------------------------
	// Chamada para cadastrar o cliente.
	//------------------------------------
	MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aCliente, nOpcAuto, aAI0Auto)

	If lMsErroAuto
		lRet := .F.
		Conout("U_VRN0162 - Erro ao gravar cliente "+ aDados[4][2] +"! Empresa:"+FWGrpCompany())

		cErro := ""
		//	MOSTRAERRO()
		//aErro := GetAutoGRLog()

		//For nERR := 1 To Len(aErro)
		//	cErro += aErro[nERR]
		//Next nERR

	Else
		Conout("U_VRN0162 - Cadastrado com sucesso! Cliente "+ aDados[4][2]+" Empresa:"+FWGrpCompany())

	EndIf

return lRet


Static Function fPutSL4D()
	lOCAL nParc := 0
	aSl4:= {}
	_aParcelas := {}
	cFormPg := "CC "
	nvalor := 6026.00
	nQtdpar := 3
	nVlrPar := round(nvalor/nQtdpar,GETSX3CACHE("L4_VALOR","X3_DECIMAL"))
	//    nVlrDif := nvalor%nQtdpar
	cAdmDesc := "103 - VISA-REDE     "
	//"FORMA DE PAGAMENTO:CARTAO DE CREDITO VISA 3X POS DOC 17742936 AUT 674232",
	/*
	24/04/2024	17742936	         	674232	406669******9678	2.008,66
25/03/2024	17742936	         	674232	406669******9678	2.008,68
24/05/2024	17742936	         	674232	406669******9678	2.008,66

	*/

	cAutCar  :="674232"
	cNsu 	 :=""
	cCdBan   :="00001"
	cCdRede  :="00005"
	cHrVend  := "101742"
	cNsuAut  :="17742936"
	cNumCart :=""
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
		// aAdd( _aParcelas, {"L4_INSTITU", cDscRede   , NIL} )
		aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(1)        , NIL} )
		cObs := padr(cvaltochar(1),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
		aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
		aadd(aSl4,_aParcelas)
		//	conout( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nSl4) )
	next nParc
Return aSl4




Static Function fPutSL4R()
	lOCAL nParc := 0
	aSl4:= {}
	_aParcelas := {}
	cFormPg := "CC "
	nvalor := 410.00
	nQtdpar := 1
	IF nQtdpar > 1
		nVlrPar := round(nvalor/nQtdpar,GETSX3CACHE("L4_VALOR","X3_DECIMAL"))
	ELSE
		nVlrPar := nvalor
	ENDIF
	//    nVlrDif := nvalor%nQtdpar
	cAdmDesc := "102 - MASTERCARD-RED"
	//"FORMA DE PAGAMENTO:CARTAO DE CREDITO VISA 3X POS DOC 17742936 AUT 674232",
	/*
	24/04/2024	17742936	         	674232	406669******9678	2.008,66
25/03/2024	17742936	         	674232	406669******9678	2.008,68
24/05/2024	17742936	         	674232	406669******9678	2.008,66

	*/

	cAutCar  :="203185"
	cNsu 	 :=""
	cCdBan   :="00002"
	cCdRede  :="00005"
	cHrVend  := "101742"
	cNsuAut  :="25621518"
	cNumCart :=""
	For nParc := 1 To nQtdpar
		_aParcelas :={}

		aAdd( _aParcelas, {"L4_FILIAL"   , xFilial("SL4")    , NIL} )
		aAdd( _aParcelas, {"L4_FORMA"  , cFormPg      , NIL} )
		aAdd( _aParcelas, {"L4_TROCO"  , 0.00       , NIL} )
		aAdd( _aParcelas, {"L4_ADMINIS", cAdmDesc     , NIL} )
		aAdd( _aParcelas, {"L4_DATA"   , dDatabase    , NIL} )
		if nParc == nQtdpar .AND. nParc >1
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
		// aAdd( _aParcelas, {"L4_INSTITU", cDscRede   , NIL} )
		aAdd( _aParcelas, {"L4_FORMAID", cvaltochar(1)        , NIL} )
		cObs := padr(cvaltochar(1),GETSX3CACHE("L4_OBS","X3_TAMANHO"))
		aAdd( _aParcelas, {"L4_OBS", cObs     , NIL} )
		aadd(aSl4,_aParcelas)
		//	conout( cDocCHV + " - " + ALLTRIM(cFormPg)+  "  cvaltochar(nSl4)  "+cvaltochar(nSl4) )
	next nParc
Return aSl4



/*
/============================================================================\
|Nome              : CriaRetJson                                            |
|============================================================================|
|Descricao         : Função para gerar o Retorno do Json Desmontagem         |
|============================================================================|
|Autor             : Daniel Victor da Rosa - Personalitec                    |
|============================================================================|
|Data de Criacao   : 11/09/2025                                              |
\============================================================================/
*/
Static Function cRetErEx(cMsg)

	Local aLinhas  := StrTokArr(cMsg, Chr(13)+Chr(10))
	Local nIZ8    := 0
	Local nNZY    := 0
	Local cMensFin  := ""

	For nIZ8 := 1 To LEN(aLinhas)
		nNZY++
		cMensFin += AllTrim(aLinhas[nIZ8])
		IF nNZY == 2
			Exit
		ENDIF
	Next nIZ8

	For nIZ8 := 1 To Len(aLinhas)
		If At("< --", aLinhas[nIZ8]) > 0 .OR.  At("< ", aLinhas[nIZ8]) > 0
			cMensFin += " - CAMPO :" + AllTrim(SubStr(aLinhas[nIZ8], At("-", aLinhas[nIZ8]) + 1, 20))
			Exit
		EndIf
	Next nIZ8

Return cMensFin
