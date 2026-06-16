#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1519
    Função para integrar grade de encaixotamentos no WMS.
    @type function
    @author Caique
    @since 15/03/2026
/*/
User Function BUD1519()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Grade/Encaixotamentos"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""
    Local cQuery        := ""
    Local nTotal        := 0
    Local nProcessados  := 0
    Local nIgnorados    := 0

    If IsBlind()
        RPCSETENV("01","01")
    EndIf

    // ===============================
    // LOG: Início da integração
    // ===============================
    oLogger:Gravar(PDALogEntry():New("ZCN", "INICIO", "", "Inicio integracao de Grade Encaixotamentos"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    // ===============================
    // Monta Query SQL
    // ===============================
    cQuery := " SELECT ZCN_CODEMB, ZCN_CODIGO, ZCN_QTDE, ZCN_QTDPCT, "
    cQuery += "        ZCN_REF, ZCN_TAM, R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("ZCN") + " ZCN (NOLOCK) "
    cQuery += " WHERE ZCN.D_E_L_E_T_ = ' ' "
    //cQuery += " AND ZCN_INTWMS = ' ' "
    cQuery += " ORDER BY ZCN_CODEMB, ZCN_REF "

    If Select("QRY_ZCN") > 0
        QRY_ZCN->(DbCloseArea())
    EndIf

    QRY_ZCN := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_ZCN)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_ZCN)->(!Eof())

        nTotal++

        // ===============================
        // Validação de campos obrigatórios
        // ZCN_CODIGO = Codigo da Grade
        // ===============================
        If Empty(AllTrim((QRY_ZCN)->ZCN_CODIGO))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZCN", "IGNORADO", ;
                AllTrim((QRY_ZCN)->ZCN_CODIGO) + "/" + AllTrim((QRY_ZCN)->ZCN_REF), ;
                "Encaixotamento sem Codigo Grade"))
            (QRY_ZCN)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_ZCN)->ZCN_REF))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZCN", "IGNORADO", ;
                AllTrim((QRY_ZCN)->ZCN_CODIGO) + "/" + AllTrim((QRY_ZCN)->ZCN_REF), ;
                "Encaixotamento sem Produto"))
            (QRY_ZCN)->(DbSkip())
            Loop
        EndIf

        // ===============================
        // Monta JSON
        // ZCN_CODIGO = Codigo da Grade | ZCN_CODEMB = Codigo da Embalagem
        // ===============================
        oJsonRequest := JsonObject():New()

        oJsonRequest["codigoGrade"]     := AllTrim((QRY_ZCN)->ZCN_CODIGO)
        oJsonRequest["codigoEmbalagem"] := IIf(Empty(AllTrim((QRY_ZCN)->ZCN_CODEMB)), Nil, AllTrim((QRY_ZCN)->ZCN_CODEMB))
        oJsonRequest["produto"]         := AllTrim((QRY_ZCN)->ZCN_REF)
        oJsonRequest["tamanho"]         := IIf(Empty(AllTrim((QRY_ZCN)->ZCN_TAM)),    Nil, AllTrim((QRY_ZCN)->ZCN_TAM))
        oJsonRequest["qtdePorCaixa"]    := IIf((QRY_ZCN)->ZCN_QTDE   == 0, Nil, (QRY_ZCN)->ZCN_QTDE)
        oJsonRequest["qtdePorPacote"]   := IIf((QRY_ZCN)->ZCN_QTDPCT == 0, Nil, (QRY_ZCN)->ZCN_QTDPCT)

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        ZCN->(DbSetOrder(1))
        ZCN->(DBGoTo((QRY_ZCN)->REC))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZCN", "ERRO", ;
                AllTrim((QRY_ZCN)->ZCN_CODIGO) + "/" + AllTrim((QRY_ZCN)->ZCN_REF), ;
                "Erro ao integrar encaixotamento cod: " + AllTrim((QRY_ZCN)->ZCN_CODIGO) + " produto: " + AllTrim((QRY_ZCN)->ZCN_REF)))

            If AllTrim(ZCN->ZCN_CODIGO) == AllTrim((QRY_ZCN)->ZCN_CODIGO)
                ZCN->(Reclock("ZCN", .F.))
                ZCN->ZCN_INTWMS := "E"
                ZCN->(MsUnLock())
            EndIf

        Else

            nProcessados++
            oLogger:Gravar(PDALogEntry():New("ZCN", "INCLUSAO", ;
                AllTrim((QRY_ZCN)->ZCN_CODIGO) + "/" + AllTrim((QRY_ZCN)->ZCN_REF), ;
                "Encaixotamento integrado com sucesso"))

            If AllTrim(ZCN->ZCN_CODIGO) == AllTrim((QRY_ZCN)->ZCN_CODIGO)
                ZCN->(Reclock("ZCN", .F.))
                ZCN->ZCN_INTWMS := "S"
                ZCN->(MsUnLock())
            EndIf

        EndIf

        (QRY_ZCN)->(DbSkip())

    End

    If Select("QRY_ZCN") > 0
        QRY_ZCN->(DbCloseArea())
    EndIf

    // ===============================
    // LOG: Resumo final
    // ===============================
    oLogger:Gravar(PDALogEntry():New("ZCN", "INFO", "", ;
        "Total: " + cValToChar(nTotal) + ;
        " | OK: "   + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados)))

    oLogger:Gravar(PDALogEntry():New("ZCN", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
