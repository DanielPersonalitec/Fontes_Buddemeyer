#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1514
    Fun��o para integrar grupos de clientes no WMS.
    @type function
    @author Caique
    @since 10/03/2026
/*/
User Function BUD1514()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Grupo"
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
    oLogger:Gravar(PDALogEntry():New("ZZ7", "INICIO", "", "Inicio integracao de Grupos Clientes"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    // ===============================
    // Monta Query SQL
    // ===============================
    cQuery := " SELECT ZZ7_CODIGO, ZZ7_DESCRI, R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("ZZ7") + " ZZ7 (NOLOCK) "
    cQuery += " WHERE ZZ7.D_E_L_E_T_ = ' ' "
    //cQuery += " AND ZZ7_INTWMS = ' ' "
    cQuery += " ORDER BY ZZ7_CODIGO, ZZ7_DESCRI "

    If Select("QRY_ZZ7") > 0
        QRY_ZZ7->(DbCloseArea())
    EndIf

    QRY_ZZ7 := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_ZZ7)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_ZZ7)->(!Eof())

        nTotal++

        // ===============================
        // Validação de campos obrigatórios
        // ===============================
        If Empty(AllTrim((QRY_ZZ7)->ZZ7_CODIGO))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZZ7", "IGNORADO", ;
                AllTrim((QRY_ZZ7)->ZZ7_CODIGO) + "/" + AllTrim((QRY_ZZ7)->ZZ7_DESCRI), ;
                "Grupo sem Codigo"))
            (QRY_ZZ7)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_ZZ7)->ZZ7_DESCRI))
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZZ7", "IGNORADO", ;
                AllTrim((QRY_ZZ7)->ZZ7_CODIGO) + "/" + AllTrim((QRY_ZZ7)->ZZ7_DESCRI), ;
                "Grupo sem Descricao"))
            (QRY_ZZ7)->(DbSkip())
            Loop
        EndIf

        // Campos obrigatórios
        oJsonRequest["codigo"] := AllTrim((QRY_ZZ7)->ZZ7_CODIGO)
        oJsonRequest["descricao"] := AllTrim((QRY_ZZ7)->ZZ7_DESCRI)

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        ZZ7->(DbSetOrder(1))
        ZZ7->(DBGoTo((QRY_ZZ7)->REC))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("ZZ7", "ERRO", ;
                AllTrim((QRY_ZZ7)->ZZ7_CODIGO) + "/" + AllTrim((QRY_ZZ7)->ZZ7_DESCRI), ;
                "Erro ao integrar grupo cod: " + AllTrim((QRY_ZZ7)->ZZ7_CODIGO) + " descricao: " + AllTrim((QRY_ZZ7)->ZZ7_DESCRI)))

            If AllTrim(ZZ7->ZZ7_CODIGO) == AllTrim((QRY_ZZ7)->ZZ7_CODIGO)
                ZZ7->(Reclock("ZZ7", .F.))
                ZZ7->ZZ7_INTWMS := "E"
                ZZ7->(MsUnLock())
            EndIf

        Else

            nProcessados++
            oLogger:Gravar(PDALogEntry():New("ZZ7", "INCLUSAO", ;
                AllTrim((QRY_ZZ7)->ZZ7_CODIGO) + "/" + AllTrim((QRY_ZZ7)->ZZ7_DESCRI), ;
                "Grupo integrado com sucesso"))

            If AllTrim(ZZ7->ZZ7_CODIGO) == AllTrim((QRY_ZZ7)->ZZ7_CODIGO)
                ZZ7->(Reclock("ZZ7", .F.))
                ZZ7->ZZ7_INTWMS := "S"
                ZZ7->(MsUnLock())
            EndIf

        EndIf

        (QRY_ZZ7)->(DbSkip())

    End

    // ===============================
    // LOG: Resumo final
    // ===============================
    oLogger:Gravar(PDALogEntry():New("ZZ7", "INFO", "", ;
        "Total: " + cValToChar(nTotal) + ;
        " | OK: "   + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados)))

    oLogger:Gravar(PDALogEntry():New("ZZ7", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
