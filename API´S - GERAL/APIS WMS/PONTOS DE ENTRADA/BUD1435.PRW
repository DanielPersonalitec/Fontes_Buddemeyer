#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*
/============================================================================\
| Nome              : API Grade Encaixotamento                               |
|============================================================================|
| Descricao         : API para gerar solicita��o para logistica aprovar      |
|                     grade de encaixotamento a partir do preechimento da    |
|                     tabela de pre�o, no BudPedidos.                        |
|============================================================================|
| Respons�vel       : Robson Jos� Pavanelli                                  |
|============================================================================|
| Autor             : Robson Jos� Pavanelli                                  |
|============================================================================|
| Data de Criacao   : 01/12/2023                                             |
\============================================================================/
*/

WSRESTFUL api_grade_enc DESCRIPTION "Gerar solicita��o para logistica cadastrar grade de encaixotamento, via api"
WSMETHOD POST DESCRIPTION "Recebe vari�veis pelo post" WSSYNTAX "/api_grade_enc/ [ POST ]"
END WSRESTFUL

::SetContentType("application/json")

WSMETHOD POST WSSERVICE api_grade_enc

Local lPost         := .T.
Local lLogRet       := .F.
Local cBody         := ::GetContent()
Local oSolic
Local oJson
Local cGrade        := ""
Local cReferencia   := ""
Local cTamanho      := ""
Local cItemMax      := ""
Local lToken        := "xdSUZ,XP.svH_5BW92cEb8Cm6TQK.ALh,rq3tjuJY.7fMwVNp_gD4GzRe"
Local cDescrLog     := ""
Local nId           := ""

FWJsonDeserialize(cBody,@oSolic)

cGrade      := oSolic:fwgrade
cReferencia := oSolic:fwref
cTamanho    := oSolic:fwtam

oJson := JsonObject():New()

ZCM->(dbSetOrder(1))
ZCM->(dbSeek(xFilial("ZCM")+cGrade))

If Empty(cGrade)
    oJson['ret_code']   := "ERRO 001"
    oJson['ret_status'] := EncodeUtf8("N�o foi possivel identificar a grade do cliente!")
    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - ERRO 001 - N�o foi possivel identificar a grade do cliente!")
    ::SetResponse(oJson:toJson())
    lPost := .F.
    Return lPost
ElseIf Empty(cReferencia)
    oJson['ret_code']   := "ERRO 002"
    oJson['ret_status'] := EncodeUtf8("N�o foi possivel identificar a referencia do produto!")
    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - ERRO 002 - N�o foi possivel identificar a referencia do produto!")
    ::SetResponse(oJson:toJson())
    lPost := .F.
    Return lPost
ElseIf Empty(cTamanho)
    oJson['ret_code']   := "ERRO 003"
    oJson['ret_status'] := EncodeUtf8("N�o foi possivel identificar o codigo de tamanho do produto!")
    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - ERRO 003 - N�o foi possivel identificar o codigo de tamanho do produto!")
    ::SetResponse(oJson:toJson())
    lPost := .F.
    Return lPost
ElseIF !ZCM->(Found()) //Se a grade n�o existe:
    oJson['ret_code']   := "ERRO 004"
    oJson['ret_status'] := EncodeUtf8("A grade "+cGrade+" n�o existe em nossa base!")
    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - ERRO 004 - A grade "+cGrade+" n�o existe em nossa base!")
    ::SetResponse(oJson:toJson())
    lPost := .F.
    Return lPost
Else

    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - Gerando solicita��o para cadastro da grade de encaixotamento - Grade: " +cGrade+ ", refer�ncia: " +cReferencia+ "("+Time()+")")
    cItemMax := B1435ProxItem(cGrade) //Validar se o proximo item existe na grade, caso contrario soma mais 1 na function.

    DbSelectArea("ZCN")
    DbSetOrder(2)
    DbGotop()
    IF !DbSeek(xFilial("ZCN")+cGrade+cReferencia+cTamanho)

        //Insiro registro na tabela ZCN:
        Reclock("ZCN",.T.)
        ZCN->ZCN_CODIGO := cGrade
        ZCN->ZCN_REF := cReferencia
        ZCN->ZCN_TAM := cTamanho
        ZCN->ZCN_ITEM := cItemMax
        ZCN->ZCN_STATUS := "PENDENTE"
        ZCN->(MsUnLock())
        
        //Grava o log da solicita��o:
        nId := cGrade+"_"+cReferencia+"_"+cTamanho
        cDescrLog := "O Produto "+cReferencia+" com tamanho "+cTamanho+" foi adicionado a grade "+cGrade+". Aguardando aprovacao da logistica!"
        lLogRet := LogGradeEnc("t="+lToken+"&descricao="+cDescrLog+"&acao=inserir&id="+nId+"&email=solicitacao")

        //Retorno da API:
        U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - Criado solicita��o para grade "+cGrade+", da refer�ncia "+cReferencia+" com tamanho "+cTamanho+"!")

        // Integracao WMS - Grade de Encaixotamento
        U_BUD1519()

        oJson['ret_code']   := "OK 001"
        oJson['ret_status'] := EncodeUtf8("Criado solicita��o para grade "+cGrade+", da refer�ncia "+cReferencia+" com tamanho "+cTamanho+"!")
    else
        U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - Produto j� existe na grade "+cGrade+" com a refer�ncia "+cReferencia+", tamanho "+cTamanho+"!")
        oJson['ret_code']   := "OK 002"
        oJson['ret_status'] := EncodeUtf8("Produto j� existe na grade "+cGrade+" com a refer�ncia "+cReferencia+", tamanho "+cTamanho+"!")
    ENDIF

    // Envia JSON como resposta
    ::SetResponse(oJson:toJson())
        
EndIf

Return lPost

/*
/============================================================================\
|Nome              : Item da grade de encaixotamento (B1435ProxItem)         |
|============================================================================|
|Descricao         : Essa function valida a proxima numera��o do item que    |
|                    est� na grade, para n�o ser repetido                    |
|============================================================================|
|Autor             : Robson Jos� Pavanelli                                   |
|============================================================================|
|Data de Criacao   : 04/12/2023                                              |
\============================================================================/
*/

Static Function B1435ProxItem(cCodGrade)

    Local cMaxItem := ""
    Local cCGrade  := cCodGrade

    //Pegar proximo item do produto na grade:
    If (Select("MAXITEM") <> 0)
    DbSelectArea("MAXITEM")
    DbCloseArea()
    Endif

    cQuery := ""
    cQuery += "SELECT MAX(ZCN_ITEM) AS ZCN_ITEM "
    cQuery += "FROM "+RetSqlName("ZCN")+" (NOLOCK) "
    cQuery += "WHERE ZCN_FILIAL = '"+xFilial("ZCN")+"' "
    cQuery += "AND ZCN_CODIGO = '"+cCGrade+"' "
    cQuery += "AND "+RetSqlName("ZCN")+".D_E_L_E_T_ = '' "
    TCQuery cQuery NEW ALIAS "MAXITEM"

    If EMPTY(MAXITEM->ZCN_ITEM)
        cMaxItem := "0001"
    else
        cMaxItem := SOMA1(MAXITEM->ZCN_ITEM)
    EndIf

    U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - Gerado item " + cMaxItem + "na grade" + cCGrade)

Return(cMaxItem)

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
		U_BUD1427("[GRADE DE ENCAIXOTAMENTO] - Feito grava��o do log!")
        lLogRet := .T.
	else
        lLogRet := .F.
        lPost := .F.
	Endif
Return(lLogRet)
