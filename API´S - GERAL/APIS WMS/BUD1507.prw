#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1507
    Função para integrar clientes no WMS.
    @type function
    @author Caique
    @since 16/02/2026
/*/
User Function BUD1507()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Client"
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
    oLogger:Gravar(PDALogEntry():New("SA1", "INICIO", "", "Inicio integracao de clientes"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    // ===============================
    // Monta Query SQL
    // ===============================
    cQuery := " SELECT A1_FILIAL, A1_COD, A1_LOJA, A1_CGC, A1_GRUPO, A1_NOME, A1_TEL, "
    cQuery += " A1_END, A1_BAIRRO, A1_MUN, A1_EST, A1_CEP, A1_COMPLEM, A1_CODENCX, R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("SA1") + " SA1 (NOLOCK) "
    cQuery += " WHERE SA1.D_E_L_E_T_ = ' ' "
    cQuery += " AND A1_INTWMS = ' ' "
    cQuery += " ORDER BY A1_FILIAL, A1_COD, A1_LOJA "

    If Select("QRY_SA1") > 0
        QRY_SA1->(DbCloseArea())
    EndIf

    QRY_SA1 := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_SA1)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_SA1)->(!Eof())

        nTotal++

        // ===============================
        // Validação de campos obrigatórios
        // ===============================
        If Empty(AllTrim((QRY_SA1)->A1_COD))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA1", "IGNORADO", ;
                AllTrim((QRY_SA1)->A1_COD) + "/" + AllTrim((QRY_SA1)->A1_LOJA), ;
                "Cliente sem Codigo"))
            (QRY_SA1)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_SA1)->A1_CGC))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA1", "IGNORADO", ;
                AllTrim((QRY_SA1)->A1_COD) + "/" + AllTrim((QRY_SA1)->A1_LOJA), ;
                "Cliente sem CPF/CNPJ"))
            (QRY_SA1)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_SA1)->A1_NOME))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA1", "IGNORADO", ;
                AllTrim((QRY_SA1)->A1_COD) + "/" + AllTrim((QRY_SA1)->A1_LOJA), ;
                "Cliente sem Nome"))
            (QRY_SA1)->(DbSkip())
            Loop
        EndIf

        // Campos obrigatórios
        oJsonRequest["codigoClienteErp"] := AllTrim((QRY_SA1)->A1_COD)
        oJsonRequest["cpfCnpj"]          := StrTran(StrTran(StrTran(AllTrim((QRY_SA1)->A1_CGC),".",""),"/",""),"-","")
        oJsonRequest["nome"]             := AllTrim((QRY_SA1)->A1_NOME)

        // Campos opcionais - envia NIL se estiver vazio
        oJsonRequest["telefone"]                 := IIf(Empty(AllTrim((QRY_SA1)->A1_TEL)),     Nil, AllTrim((QRY_SA1)->A1_TEL))
        oJsonRequest["rua"]                      := IIf(Empty(AllTrim((QRY_SA1)->A1_END)),     Nil, AllTrim((QRY_SA1)->A1_END))
        oJsonRequest["bairro"]                   := IIf(Empty(AllTrim((QRY_SA1)->A1_BAIRRO)),  Nil, AllTrim((QRY_SA1)->A1_BAIRRO))
        oJsonRequest["cidade"]                   := IIf(Empty(AllTrim((QRY_SA1)->A1_MUN)),     Nil, AllTrim((QRY_SA1)->A1_MUN))
        oJsonRequest["uf"]                       := IIf(Empty(AllTrim((QRY_SA1)->A1_EST)),     Nil, AllTrim((QRY_SA1)->A1_EST))
        oJsonRequest["cep"]                      := IIf(Empty(AllTrim((QRY_SA1)->A1_CEP)),     Nil, StrTran(AllTrim((QRY_SA1)->A1_CEP),"-",""))
        oJsonRequest["complemento"]              := IIf(Empty(AllTrim((QRY_SA1)->A1_COMPLEM)), Nil, AllTrim((QRY_SA1)->A1_COMPLEM))
        oJsonRequest["loja"]                     := IIf(Empty(AllTrim((QRY_SA1)->A1_LOJA)),    Nil, AllTrim((QRY_SA1)->A1_LOJA))
        oJsonRequest["grupo"]                    := IIf(Empty(AllTrim((QRY_SA1)->A1_GRUPO)),   Nil, AllTrim((QRY_SA1)->A1_GRUPO))
        oJsonRequest["codigoGradeEncaixotamento"] := IIf(Empty(AllTrim((QRY_SA1)->A1_CODENCX)),Nil, AllTrim((QRY_SA1)->A1_CODENCX))

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        SA1->(DbSetOrder(1))
        SA1->(DBGoTo((QRY_SA1)->REC))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA1", "ERRO", ;
                AllTrim((QRY_SA1)->A1_COD) + "/" + AllTrim((QRY_SA1)->A1_LOJA), ;
                "Erro ao integrar cliente cod: " + AllTrim((QRY_SA1)->A1_COD) + " loja: " + AllTrim((QRY_SA1)->A1_LOJA)))

            If AllTrim(SA1->A1_COD) == AllTrim((QRY_SA1)->A1_COD)
                SA1->(Reclock("SA1", .F.))
                SA1->A1_INTWMS := "E"
                SA1->(MsUnLock())
            EndIf

        Else

            nProcessados++
            oLogger:Gravar(PDALogEntry():New("SA1", "INCLUSAO", ;
                AllTrim((QRY_SA1)->A1_COD) + "/" + AllTrim((QRY_SA1)->A1_LOJA), ;
                "Cliente integrado com sucesso"))

            If AllTrim(SA1->A1_COD) == AllTrim((QRY_SA1)->A1_COD)
                SA1->(Reclock("SA1", .F.))
                SA1->A1_INTWMS := "S"
                SA1->(MsUnLock())
            EndIf

        EndIf

        (QRY_SA1)->(DbSkip())

    End

    // ===============================
    // LOG: Resumo final
    // ===============================
    oLogger:Gravar(PDALogEntry():New("SA1", "INFO", "", ;
        "Total: " + cValToChar(nTotal) + ;
        " | OK: "  + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados)))

    oLogger:Gravar(PDALogEntry():New("SA1", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
