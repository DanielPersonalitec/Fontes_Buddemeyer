#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc}  BUD1518
    Função para integrar embalagens no WMS.
    @type function
    @author Caique
    @since 10/03/2026
/*/
User Function  BUD1518()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Embalagem"
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
    oLogger:Gravar(PDALogEntry():New("EE5", "INICIO", "", "Inicio integracao de Embalagens"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    // ===============================
    // Monta Query SQL
    // ===============================
    cQuery := " SELECT EE5_CODEMB, EE5_DESC, EE5_M3, EE5_LETRA, "
    cQuery += "        EE5_HALT, EE5_LLARG, EE5_CCOM, "
    cQuery += "        EE5_TPALLE, EE5_QPALLE, R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("EE5") + " EE5 (NOLOCK) "
    cQuery += " WHERE EE5.D_E_L_E_T_ = ' ' "
    //cQuery += " AND EE5_INTWMS = ' ' "
    cQuery += " ORDER BY EE5_CODEMB, EE5_DESC "

    If Select("QRY_EE5") > 0
        QRY_EE5->(DbCloseArea())
    EndIf

    QRY_EE5 := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_EE5)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_EE5)->(!Eof())

        nTotal++

        // ===============================
        // ValidaÃ§Ã£o de campos obrigatÃ³rios
        // ===============================
        If Empty(AllTrim((QRY_EE5)->EE5_CODEMB))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("EE5", "IGNORADO", ;
                AllTrim((QRY_EE5)->EE5_CODEMB) + "/" + AllTrim((QRY_EE5)->EE5_DESC), ;
                "Grupo sem Codigo"))
            (QRY_EE5)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_EE5)->EE5_DESC))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("EE5", "IGNORADO", ;
                AllTrim((QRY_EE5)->EE5_CODEMB) + "/" + AllTrim((QRY_EE5)->EE5_DESC), ;
                "Grupo sem Descricao"))
            (QRY_EE5)->(DbSkip())
            Loop
        EndIf

        // Campos obrigatÃ³rios
        // Campos obrigatórios
        oJsonRequest["Codigo"]   := AllTrim((QRY_EE5)->EE5_CODEMB)
        oJsonRequest["Descricao"] := AllTrim((QRY_EE5)->EE5_DESC)

        // Campos opcionais — string
        oJsonRequest["Letra"] := IIf(Empty(AllTrim((QRY_EE5)->EE5_LETRA)), Nil, AllTrim((QRY_EE5)->EE5_LETRA))

        // Campos opcionais — numéricos
        oJsonRequest["M3"]                     := IIf((QRY_EE5)->EE5_M3     == 0, Nil, (QRY_EE5)->EE5_M3)
        oJsonRequest["Altura"]                 := IIf((QRY_EE5)->EE5_HALT   == 0, Nil, (QRY_EE5)->EE5_HALT)
        oJsonRequest["Largura"]                := IIf((QRY_EE5)->EE5_LLARG  == 0, Nil, (QRY_EE5)->EE5_LLARG)
        oJsonRequest["Comprimento"]            := IIf((QRY_EE5)->EE5_CCOM   == 0, Nil, (QRY_EE5)->EE5_CCOM)
        oJsonRequest["QuantidadeMaximaPalete"] := IIf((QRY_EE5)->EE5_TPALLE == 0, Nil, (QRY_EE5)->EE5_TPALLE)
        oJsonRequest["QuantidadeMinimaPalete"] := IIf((QRY_EE5)->EE5_QPALLE == 0, Nil, (QRY_EE5)->EE5_QPALLE)

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        EE5->(DbSetOrder(1))
        EE5->(DBGoTo((QRY_EE5)->REC))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("EE5", "ERRO", ;
                AllTrim((QRY_EE5)->EE5_CODEMB) + "/" + AllTrim((QRY_EE5)->EE5_DESC), ;
                "Erro ao integrar grupo cod: " + AllTrim((QRY_EE5)->EE5_CODEMB) + " descricao: " + AllTrim((QRY_EE5)->EE5_DESC)))

            If AllTrim(EE5->EE5_CODEMB) == AllTrim((QRY_EE5)->EE5_CODEMB)
                EE5->(Reclock("EE5", .F.))
                EE5->EE5_INTWMS := "E"
                EE5->(MsUnLock())
            EndIf

        Else

            nProcessados++
            oLogger:Gravar(PDALogEntry():New("EE5", "INCLUSAO", ;
                AllTrim((QRY_EE5)->EE5_CODEMB) + "/" + AllTrim((QRY_EE5)->EE5_DESC), ;
                "Grupo integrado com sucesso"))

            If AllTrim(EE5->EE5_CODEMB) == AllTrim((QRY_EE5)->EE5_CODEMB)
                EE5->(Reclock("EE5", .F.))
                EE5->EE5_INTWMS := "S"
                EE5->(MsUnLock())
            EndIf

        EndIf

        (QRY_EE5)->(DbSkip())

    End

    // ===============================
    // LOG: Resumo final
    // ===============================
    oLogger:Gravar(PDALogEntry():New("EE5", "INFO", "", ;
        "Total: " + cValToChar(nTotal) + ;
        " | OK: "   + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados)))

    oLogger:Gravar(PDALogEntry():New("EE5", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
