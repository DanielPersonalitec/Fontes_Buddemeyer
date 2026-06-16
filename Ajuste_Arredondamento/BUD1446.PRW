#INCLUDE "tbiconn.ch"
#INCLUDE "protheus.ch"   



/*
/=========================================================================\
| Módulo      : Entrada de Notas Varejo Facil                             |
|=========================================================================|
| Programa    : BUD1446.PRW   | Responsável: ces        		  |
|=========================================================================|
| Descricao   : Importação de Notas de Lojas Temporárias Varejo Fácil     |
|=========================================================================|
| Data        : 08/01/2023 						                          |
|=========================================================================|
| Programador : César Grossl          	                                  |
\=========================================================================/
*/


User Function BUD1446()
	Local cChaveNfe := ""
	Local cLocal := ""
	If !Pergunte("BUD1446",.T.)
		Return
	Else
        // Alimento chave NFe  na variável global:
        cChaveNfe    := ALLTRIM(MV_PAR01)
		cLocal		 := ALLTRIM(MV_PAR02)
		If(empty(cChaveNfe))
			MsgStop("Atenção 01: Chave da nota fiscal está em branca!")
			Return
		EndIf
		If(empty(cLocal))
			MsgStop("Atenção 02: Local/Armazem deve ser preenchido!")
			Return
		EndIf
		If ((cLocal != "D1") .AND. (cLocal != "D2"))
			MsgStop("Atenção 02: Local Incorreto!")
			Return
		EndIf
		If	MsgYesNo('Confirma importação das Notas Fiscais?')
			MsAguarde({|| ImpVarejo(cChaveNfe, cLocal)}, 'Aguarde','IMPORTANDO, AGUARDE PODE DEMORAR...')
		EndIf
    EndIf
Return()

Static Function ImpVarejo(cChaveNfe, cLocal)

 	Local aDadosNota := BuscaDados(cChaveNfe)
  	Local nIdx
	Local cParser := ""
	Local cCnpj := ""
	Local cCodCli := ""
	Local cCodFilial := ""
	Local cCodTrans := ""
	Local cData := ""
	Local cNota := ""
	Local cSerie := ""
	Local cStatus := ""
	Local nPeso := 0
	Local nVolume := 0
	Local aAutoCab		:= {}
	Local aAutoItens	:= {}
    Local oJson := JsonObject():New()
    cParser := oJson:FromJson(aDadosNota)
    aItenJson := oJson:GetJSonObject('itens')

	//Verifico se ocorreu algum erro, valida no endpoint, se ocorrer erro apresento msg
 	cStatus 	:= ALLTRIM(oJson["xml_status"])
	If  !empty(cStatus)
		MsgStop(cStatus)
		Return
	EndIf
	//Informações do cabecalho da nota
	cCnpj 		:= oJson["xml_cnpj"]
	cCodCli 	:= oJson["xml_codcli"]
	cCodFilial 	:= oJson["xml_codfilial"]
	cCodTrans 	:= oJson["xml_codtrans"]
	cData 		:= oJson["xml_data"]
	cNota 		:= oJson["xml_nfe"]
	cSerie 		:= oJson["xml_serie"]
	nPeso 		:= val(oJson["xml_peso"])
	nVolume 	:= val(oJson["xml_vol"])

	If (Empty(cCnpj) .OR. Empty(cCodCli) .OR. Empty(cData) .OR. Empty(cNota) .OR. Empty(cSerie) )
		MsgStop("Atenção 02: Alguns dos campos principais em branco!")
		Return
	EndIf

    //Monto os itens
    For nIdx := 1 To Len(aItenJson)
        // nValor := aItenJson[nIdx]["qtd_dev_cada"] * val(aItenJson[nIdx]["valor_unit"])
		aReg := {}
		aadd(aReg,{"D1_COD"    	, aItenJson[nIdx]["codProduto"]				, Nil})
		aadd(aReg,{"D1_LOCAL"	, cLocal									, Nil})
		aadd(aReg,{"D1_QUANT"  	, aItenJson[nIdx]["qtdReferencia"]			, Nil})
		aadd(aReg,{"D1_VUNIT"  	, aItenJson[nIdx]["vUnitarioNota"]			, Nil})
		aadd(aReg,{"D1_TOTAL"  	, aItenJson[nIdx]["vTotalRef"]				, Nil})
		aadd(aReg,{"D1_TES"		, aItenJson[nIdx]["tesProduto"]				, Nil})
		aadd(aReg,{"D1_NFORI"  	, aItenJson[nIdx]["nfProtheus"]	  			, Nil})
		aadd(aReg,{"D1_SERIORI"	, padr(aItenJson[nIdx]["serieProtheus"],GETSX3CACHE("D1_SERIORI","X3_TAMANHO") ) , Nil})
		aadd(aReg,{"D1_ITEMORI"	, padr(aItenJson[nIdx]["itemNfProtheus"],GETSX3CACHE("D1_ITEMORI","X3_TAMANHO") ) 	, Nil})
		aadd(aReg,{"AUTDELETA" 	, "N"  																				, Nil})
		aAdd(aAutoItens, aReg)
    Next nIdx

	//Cabecalho
	AAdd(aAutoCab, { "F1_FORMUL" 	, 'N'     						, Nil } ) // Formulario
	AAdd(aAutoCab, { "F1_DOC"    	, cNota							, Nil } ) // Numero da NF : Obrigatorio
	AAdd(aAutoCab, { "F1_SERIE"   	, cSerie						, Nil } ) // Serie da NF  : Obrigatorio
	AAdd(aAutoCab, { "F1_TIPO"    	, 'D' 							, Nil } ) // Tipo da NF   : Obrigatorio
	AAdd(aAutoCab, { "F1_FORNECE"	, cCodCli     					, Nil } ) // Codigo do Fornecedor : Obrigatorio
	AAdd(aAutoCab, { "F1_LOJA"    	, cCodFilial        			, Nil } ) // Loja do Fornecedor   : Obrigatorio
	AAdd(aAutoCab, { "F1_EMISSAO"	, STOD(cData)					, Nil } ) // Emissao da NF        : Obrigatorio
	AAdd(aAutoCab, { "F1_ESPECIE" 	, 'SPED' 						, Nil } ) // Especie
	AAdd(aAutoCab, { "F1_COND"   	, '030'	   	 					, Nil } ) // Condicao do Pagamento
	If (!empty(cCodTrans))
		AAdd(aAutoCab, { "F1_TRANSP"  	, cCodTrans	 				, Nil } ) // Transportadora
		AAdd(aAutoCab, { "F1_TPFRETE" 	, 'C'	   	 				, Nil } ) // Tipo do Frete
	EndIf
	AAdd(aAutoCab, { "F1_USERBUD" 	,  cUserName   					, Nil } ) // Usuário responsável
	//AAdd(aAutoCab, { "F1_TEXT1" 	, "047"		   					, Nil } )
	AAdd(aAutoCab, { "F1_PLIQUI" 	, nPeso							, Nil } )
	AAdd(aAutoCab, { "F1_PBRUTO" 	, nPeso							, Nil } ) //tag vol do xml
	//AAdd(aAutoCab, { "F1_ESPECI1" 	, "CAIXA"		   			, Nil } )
	AAdd(aAutoCab, { "F1_VOLUME1" 	, nVolume		   				, Nil } ) //tag vol do xml
	AAdd(aAutoCab, { "F1_CHVNFE" 	, cChaveNfe						, Nil } ) // chave da nota
	
	//Executa o Mata103
	Mata103(aAutoCab, aAutoItens, 3, .T.)


Return

//Busco Informações da nota, será subistituiro pelo busca no varejo facil, mas de momento não está vindo informações das chaves referenciadas!
Static Function BuscaDados(cChaveNfe)
    Local cUrl := "https://tars.buddemeyer.com.br/nucleo/ws/ws_vfxml.php?token=2024V04c@&g=ok&chavenfe="+cChaveNfe
    Local nTimeOut := 60
	Local aHeadOut := {}
	Local cHeadGet := ""
	Local cResponse := ""
    AAdd(aHeadOut, 'Content-Type: application/json')
    cResponse := HttpGet(cUrl, "", nTimeOut,aHeadOut,@cHeadGet)
Return cResponse
