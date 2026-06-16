#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1506
    Função para integrar fornecedores no WMS.
    @type function
    @author Caique
    @since 18/02/2026
/*/
User Function BUD1506()


    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Fornecedor"
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
        RPCSETENV("01", "01")
    EndIf


    // ===============================
    // LOG: Início da integração
    // ===============================
    oLogger:Gravar(PDALogEntry():New("SA2", "INICIO", "", "Inicio integracao de fornecedores"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    // ===============================
    // Monta Query SQL
    // ===============================
    cQuery := " SELECT TOP 2000 A2_COD, A2_LOJA, A2_CGC, A2_NOME, R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("SA2") + " SA2 (NOLOCK) "
    cQuery += " WHERE SA2.D_E_L_E_T_ = ' ' "
    //cQuery += " AND A2_INTWMS = ' ' "
    cQuery += " ORDER BY A2_COD, A2_LOJA "

    If Select("QRY_SA2") > 0
        QRY_SA2->(DbCloseArea())
    EndIf

    QRY_SA2 := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_SA2)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_SA2)->(!Eof())

        nTotal++

        // ===============================
        // Validação de campos obrigatórios
        // ===============================
        If Empty(AllTrim((QRY_SA2)->A2_COD))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA2", "IGNORADO", ;
                AllTrim((QRY_SA2)->A2_COD) + "/" + AllTrim((QRY_SA2)->A2_LOJA), ;
                "Fornecedor sem Codigo"))
            (QRY_SA2)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_SA2)->A2_CGC))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA2", "IGNORADO", ;
                AllTrim((QRY_SA2)->A2_COD) + "/" + AllTrim((QRY_SA2)->A2_LOJA), ;
                "Fornecedor sem CPF/CNPJ"))
            (QRY_SA2)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_SA2)->A2_NOME))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA2", "IGNORADO", ;
                AllTrim((QRY_SA2)->A2_COD) + "/" + AllTrim((QRY_SA2)->A2_LOJA), ;
                "Fornecedor sem Nome"))
            (QRY_SA2)->(DbSkip())
            Loop
        EndIf

        // Campos obrigatórios
        oJsonRequest["codigoFornecedor"] := AllTrim((QRY_SA2)->A2_COD)
        oJsonRequest["cpfCnpj"]          := StrTran(StrTran(StrTran(AllTrim((QRY_SA2)->A2_CGC), ".", ""), "/", ""), "-", "")
        oJsonRequest["nome"]             := AllTrim((QRY_SA2)->A2_NOME)

        // Campo opcional
        oJsonRequest["loja"] := IIf(Empty(AllTrim((QRY_SA2)->A2_LOJA)), Nil, AllTrim((QRY_SA2)->A2_LOJA))

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        SA2->(DbSetOrder(1))
        SA2->(DBGoTo((QRY_SA2)->REC))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA2", "ERRO", ;
                AllTrim((QRY_SA2)->A2_COD) + "/" + AllTrim((QRY_SA2)->A2_LOJA), ;
                "Erro ao integrar fornecedor cod: " + AllTrim((QRY_SA2)->A2_COD) + " loja: " + AllTrim((QRY_SA2)->A2_LOJA)))

            If AllTrim(SA2->A2_COD) == AllTrim((QRY_SA2)->A2_COD)
                //A2->(Reclock("SA2", .F.))
                //2->A2_INTWMS := "E"
                //A2->(MsUnLock())
            EndIf

        Else

            nProcessados++
            oLogger:Gravar(PDALogEntry():New("SA2", "INCLUSAO", ;
                AllTrim((QRY_SA2)->A2_COD) + "/" + AllTrim((QRY_SA2)->A2_LOJA), ;
                "Fornecedor integrado com sucesso"))

            If AllTrim(SA2->A2_COD) == AllTrim((QRY_SA2)->A2_COD)
                //2->(Reclock("SA2", .F.))
                //A2->A2_INTWMS := "S"
                //A2->(MsUnLock())
            EndIf

        EndIf

        (QRY_SA2)->(DbSkip())

    End

    // ===============================
    // LOG: Resumo final
    // ===============================
    oLogger:Gravar(PDALogEntry():New("SA2", "INFO", "", ;
        "Total: " + cValToChar(nTotal) + ;
        " | OK: "   + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados)))

    oLogger:Gravar(PDALogEntry():New("SA2", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
