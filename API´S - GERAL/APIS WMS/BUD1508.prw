#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} pdaProduto
    Função para integrar produtos no WMS.
    @type function
    @author Caique
    @since 18/02/2026
    @version 1.1 - 11/05/2026 - Adicionado modo ponto de entrada (lA010Z)
/*/
User Function BUD1508(lA010Z)

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Produto"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oBarra        := JsonObject():New()
    Local oModelo       := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    //Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""
    Local cQuery        := ""
    Local nTotal        := 0
    Local nProcessados  := 0
    Local nIgnorados    := 0
    default lA010Z      := .F.

    If IsBlind()
        RPCSETENV("01", "01")
    EndIf

    // ===============================
    // LOG: Início da integração
    // ===============================
    // oLogger:Gravar(PDALogEntry():New("SB1", "INICIO", "", "Inicio integracao de produtos"))

    // ===============================
    // Autenticação
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    IF !lA010Z

    // ===============================
    // Monta Query SQL
    // JOIN com SZ7 via B1_CODMOD = Z7_COD
    // ===============================
    cQuery := " SELECT SB1.B1_FILIAL, SB5.R_E_C_N_O_ AS RECB5, SB1.B1_COD, SB1.B1_DESC, SB1.B1_CODBAR, SB1.B1_UM, SB1.B1_PESO, "
    cQuery += "        SB1.B1_CODLIN, SB1.B1_CODART, SB1.B1_CODTAM, SB1.B1_CODCOR, SB1.B1_CODMOD, "
    cQuery += "        SB1.B1_TIPO, SB1.B1_POSIPI, SB1.R_E_C_N_O_ AS REC, "
    cQuery += "        SZ7.Z7_COD, SZ7.Z7_DESC, SZ7.Z7_QTDPCT, SZ7.Z7_QTDCAIX, "
    cQuery += "        SZ7.Z7_QTDCOM, SZ7.Z7_MCOMP, SZ7.Z7_MLARG, SZ7.Z7_MALT, "
    cQuery += "        SZ7.Z7_COMP, SZ7.Z7_LARG, SZ7.Z7_ALT, "
    cQuery += "        (SELECT TOP 1 B2_LOCAL FROM " + RetSQLName("SB2") + " (NOLOCK) WHERE B2_COD = SB1.B1_COD AND B2_FILIAL = SB1.B1_FILIAL AND D_E_L_E_T_ = ' ' ORDER BY B2_LOCAL) AS B2_LOCAL "
    cQuery += " FROM " + RetSQLName("SB1") + " SB1 (NOLOCK) "
    cQuery += " LEFT JOIN " + RetSQLName("SZ7") + " SZ7 (NOLOCK) "
    cQuery += "   ON SZ7.Z7_COD = SB1.B1_CODMOD "
    cQuery += "  AND SZ7.D_E_L_E_T_ = ' ' "
    cQuery += "  INNER JOIN " + RetSQLName("SB5") + " SB5 (NOLOCK) ON SB5.B5_FILIAL = SB1.B1_FILIAL AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' AND SB5.B5_INTWMS = 'E' "
    cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SB1.B1_MSBLQL <> '1' "
    cQuery += "   AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
    cQuery += " AND SB1.B1_COD IN ( SELECT D2_COD  FROM SD2010 s WHERE D_E_L_E_T_ = ' 'AND D2_EMISSAO > '20250101'GROUP BY D2_COD ) "
    cQuery += " ORDER BY SB1.B1_FILIAL, SB1.B1_COD DESC "

    If Select("QRY_SB1") > 0
        QRY_SB1->(DbCloseArea())
    EndIf

    QRY_SB1 := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_SB1)

    // ===============================
    // Loop de leitura e envio
    // ===============================
    While (QRY_SB1)->(!Eof())

        nTotal++

        // ===============================
        // Validação de campos obrigatórios
        // ===============================
        If Empty(AllTrim((QRY_SB1)->B1_COD))
            nIgnorados++
            // oLogger:Gravar(PDALogEntry():New("SB1", "IGNORADO", ;
            //     AllTrim((QRY_SB1)->B1_COD), ;
            //     "Produto sem Codigo"))
            (QRY_SB1)->(DbSkip())
            Loop
        EndIf

        If Empty(AllTrim((QRY_SB1)->B1_DESC))
            nIgnorados++
            // oLogger:Gravar(PDALogEntry():New("SB1", "IGNORADO", ;
            //     AllTrim((QRY_SB1)->B1_COD), ;
            //     "Produto sem Descricao"))
            (QRY_SB1)->(DbSkip())
            Loop
        EndIf

        // ===============================
        // Monta JSON do produto
        // ===============================
        oJsonRequest := JsonObject():New()

        // Campos obrigatórios
        oJsonRequest["codigo_Produto"] := AllTrim((QRY_SB1)->B1_COD)
        oJsonRequest["desc_Produto"]   := AllTrim((QRY_SB1)->B1_DESC)

        // Campos opcionais
        oJsonRequest["altura"]         := IIf((QRY_SB1)->Z7_ALT == 0, Nil, (QRY_SB1)->Z7_ALT)
        oJsonRequest["largura"]        := IIf((QRY_SB1)->Z7_LARG == 0, Nil, (QRY_SB1)->Z7_LARG)
        oJsonRequest["comprimento"]    := IIf((QRY_SB1)->Z7_COMP == 0, Nil, (QRY_SB1)->Z7_COMP)
        oJsonRequest["unidade_Medida"] := IIf(Empty(AllTrim((QRY_SB1)->B1_UM)),     Nil, AllTrim((QRY_SB1)->B1_UM))
        oJsonRequest["tipo"]           := IIf(Empty(AllTrim((QRY_SB1)->B1_TIPO)),   Nil, AllTrim((QRY_SB1)->B1_TIPO))
        oJsonRequest["peso"]           := IIf((QRY_SB1)->B1_PESO == 0,              Nil, (QRY_SB1)->B1_PESO)
        oJsonRequest["categoria_01"]   := IIf(Empty(AllTrim((QRY_SB1)->B1_CODLIN)), Nil, AllTrim((QRY_SB1)->B1_CODLIN))
        oJsonRequest["categoria_02"]   := IIf(Empty(AllTrim((QRY_SB1)->B1_CODART)), Nil, AllTrim((QRY_SB1)->B1_CODART))
        oJsonRequest["deposito"]       := IIf(Empty(AllTrim((QRY_SB1)->B2_LOCAL)),  Nil, AllTrim((QRY_SB1)->B2_LOCAL))

        // ===============================
        // Array barras
        // ===============================
        oBarra := JsonObject():New()
        oBarra["codigo_Barra"] := IIf(Empty(AllTrim((QRY_SB1)->B1_CODBAR)), Nil, AllTrim((QRY_SB1)->B1_CODBAR))
        oBarra["codigoModelo"] := IIf(Empty(AllTrim((QRY_SB1)->B1_CODMOD)), Nil, AllTrim((QRY_SB1)->B1_CODMOD))
        oBarra["cor_Produto"]  := IIf(Empty(AllTrim((QRY_SB1)->B1_CODCOR)), Nil, AllTrim((QRY_SB1)->B1_CODCOR))
        oBarra["tamanho"]      := IIf(Empty(AllTrim((QRY_SB1)->B1_CODTAM)), Nil, AllTrim((QRY_SB1)->B1_CODTAM))
        oBarra["quantidade"]   := IIf((QRY_SB1)->Z7_QTDPCT == 0,           Nil, (QRY_SB1)->Z7_QTDPCT)

        oJsonRequest["barras"] := {oBarra}

        // ===============================
        // Array lotes — vazio por enquanto
        // ===============================
        oJsonRequest["lotes"] := {}

        // ===============================
        // Array modelos (dados da SZ7 via JOIN)

        oModelo := JsonObject():New()
        oModelo["codigoModelo"]            := IIf(Empty(AllTrim((QRY_SB1)->Z7_COD)),  Nil, AllTrim((QRY_SB1)->Z7_COD))
        oModelo["descricao"]               := IIf(Empty(AllTrim((QRY_SB1)->Z7_DESC)), Nil, AllTrim((QRY_SB1)->Z7_DESC))
        oModelo["quantidadePack"]          := IIf((QRY_SB1)->Z7_QTDPCT  == 0, Nil, (QRY_SB1)->Z7_QTDPCT)
        oModelo["quantodadePackNaCaixa"]   := IIf((QRY_SB1)->Z7_QTDCAIX == 0, Nil, (QRY_SB1)->Z7_QTDCAIX) // typo mantido conforme API
        oModelo["quantidadePackImportado"] := IIf((QRY_SB1)->Z7_QTDCOM  == 0, Nil, (QRY_SB1)->Z7_QTDCOM)
        oModelo["codigoEmbalagem"]         := IIf(Empty(AllTrim((QRY_SB1)->Z7_COD)),  Nil, AllTrim((QRY_SB1)->Z7_COD))
        oModelo["comprimentoMovimentacao"] := IIf((QRY_SB1)->Z7_MCOMP == 0, Nil, (QRY_SB1)->Z7_MCOMP)
        oModelo["larguraMovimentacao"]     := IIf((QRY_SB1)->Z7_MLARG == 0, Nil, (QRY_SB1)->Z7_MLARG)
        oModelo["alturaMovimentacao"]      := IIf((QRY_SB1)->Z7_MALT == 0, Nil, (QRY_SB1)->Z7_MALT)

        oJsonRequest["modelos"] := {oModelo}

        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

        ConOut("JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        SB5->(DbSetOrder(1))
        SB5->(DBGoTo((QRY_SB1)->RECB5))

        If oJsonRet["badRequest"] == .T.

            nIgnorados++
            // oLogger:Gravar(PDALogEntry():New("SB1", "ERRO", ;
            //     AllTrim((QRY_SB1)->B1_COD), ;
            //     "Erro ao integrar produto cod: " + AllTrim((QRY_SB1)->B1_COD)))

            If AllTrim(SB5->B5_COD) == AllTrim((QRY_SB1)->B1_COD)
                SB5->(Reclock("SB5", .F.))
                SB5->B5_INTWMS := "E"
                SB5->(MsUnLock())
            EndIf

        Else

            nProcessados++
            // oLogger:Gravar(PDALogEntry():New("SB1", "INCLUSAO", ;
            //     AllTrim((QRY_SB1)->B1_COD), ;
            //     "Produto integrado com sucesso"))

            If AllTrim(SB5->B5_COD) == AllTrim((QRY_SB1)->B1_COD)
                SB5->(Reclock("SB5", .F.))
                SB5->B5_INTWMS := "S"
                SB5->(MsUnLock())
            EndIf

        EndIf

        (QRY_SB1)->(DbSkip())

    End

    If Select("QRY_SB1") > 0
        QRY_SB1->(DbCloseArea())
    EndIf

    // // ===============================
    // // LOG: Resumo final
    // // ===============================
    // oLogger:Gravar(PDALogEntry():New("SB1", "INFO", "", ;
    //     "Total: " + cValToChar(nTotal) + ;
    //     " | OK: "   + cValToChar(nProcessados) + ;
    //     " | Erro: " + cValToChar(nIgnorados)))

    // oLogger:Gravar(PDALogEntry():New("SB1", "INCLUSAO", cValToChar(nProcessados), "Integracao concluida"))

    Else

        // ===============================
        // Modo ponto de entrada (A010TOK)
        // ===============================
        Local cCod     := AllTrim(M->B1_COD)
        Local cDesc    := AllTrim(M->B1_DESC)
        Local cCodBar  := AllTrim(M->B1_CODBAR)
        Local cUM      := AllTrim(M->B1_UM)
        Local nPeso    := M->B1_PESO
        Local cCodLin  := AllTrim(M->B1_CODLIN)
        Local cCodArt  := AllTrim(M->B1_CODART)
        Local cCodTam  := AllTrim(M->B1_CODTAM)
        Local cCodCor  := AllTrim(M->B1_CODCOR)
        Local cCodMod  := AllTrim(M->B1_CODMOD)
        Local cTipo    := AllTrim(M->B1_TIPO)

        If Empty(cCod) .Or. Empty(cDesc)
            ConOut("BUD1508 PE: Ignorado - Campo obrigatorio vazio: cod=[" + cCod + "] desc=[" + cDesc + "]")
            lSuces := .F.
        Else

            oJsonRequest := JsonObject():New()
            oJsonRequest["codigo_Produto"] := cCod
            oJsonRequest["desc_Produto"]   := cDesc
            oJsonRequest["unidade_Medida"] := IIf(Empty(cUM),     Nil, cUM)
            oJsonRequest["tipo"]           := IIf(Empty(cTipo),   Nil, cTipo)
            oJsonRequest["peso"]           := IIf(nPeso == 0,     Nil, nPeso)
            oJsonRequest["categoria_01"]   := IIf(Empty(cCodLin), Nil, cCodLin)
            oJsonRequest["categoria_02"]   := IIf(Empty(cCodArt), Nil, cCodArt)

            // Busca dados do modelo (SZ7) via B1_CODMOD
            Local nAltMod  := 0
            Local nLargMod := 0
            Local nCompMod := 0
            Local cZ7Desc  := ""
            Local nZ7Pct   := 0
            Local nZ7Caix  := 0
            Local nZ7Com   := 0
            Local nMComp   := 0
            Local nMLarg   := 0
            Local nMAlt    := 0

            If !Empty(cCodMod)
                Local cQryMod := ""
                cQryMod := " SELECT Z7_DESC, Z7_QTDPCT, Z7_QTDCAIX, Z7_QTDCOM, "
                cQryMod += "        Z7_MCOMP, Z7_MLARG, Z7_MALT, "
                cQryMod += "        Z7_COMP, Z7_LARG, Z7_ALT "
                cQryMod += " FROM " + RetSQLName("SZ7") + " (NOLOCK) "
                cQryMod += " WHERE Z7_COD = '" + cCodMod + "' "
                cQryMod += "   AND D_E_L_E_T_ = ' ' "

                If Select("QRY_Z7") > 0
                    QRY_Z7->(DbCloseArea())
                EndIf

                QRY_Z7 := GETNEXTALIAS()
                MPSysOpenQuery(cQryMod, QRY_Z7)

                If !(QRY_Z7)->(Eof())
                    cZ7Desc  := AllTrim((QRY_Z7)->Z7_DESC)
                    nZ7Pct   := (QRY_Z7)->Z7_QTDPCT
                    nZ7Caix  := (QRY_Z7)->Z7_QTDCAIX
                    nZ7Com   := (QRY_Z7)->Z7_QTDCOM
                    nMComp   := (QRY_Z7)->Z7_MCOMP
                    nMLarg   := (QRY_Z7)->Z7_MLARG
                    nMAlt    := (QRY_Z7)->Z7_MALT
                    nCompMod := (QRY_Z7)->Z7_COMP
                    nLargMod := (QRY_Z7)->Z7_LARG
                    nAltMod  := (QRY_Z7)->Z7_ALT
                EndIf

                If Select("QRY_Z7") > 0
                    QRY_Z7->(DbCloseArea())
                EndIf
            EndIf

            // Busca armazem do produto (SB2)
            Local cDeposito := ""
            Local cQryB2    := ""
            cQryB2 := " SELECT TOP 1 B2_LOCAL "
            cQryB2 += " FROM " + RetSQLName("SB2") + " (NOLOCK) "
            cQryB2 += " WHERE B2_COD = '" + cCod + "' "
            cQryB2 += "   AND B2_FILIAL = '" + xFilial("SB2") + "' "
            cQryB2 += "   AND D_E_L_E_T_ = ' ' "
            cQryB2 += " ORDER BY B2_LOCAL "

            If Select("QRY_B2") > 0
                QRY_B2->(DbCloseArea())
            EndIf

            QRY_B2 := GETNEXTALIAS()
            MPSysOpenQuery(cQryB2, QRY_B2)

            If !(QRY_B2)->(Eof())
                cDeposito := AllTrim((QRY_B2)->B2_LOCAL)
            EndIf

            If Select("QRY_B2") > 0
                QRY_B2->(DbCloseArea())
            EndIf

            oJsonRequest["altura"]      := IIf(nAltMod == 0,  Nil, nAltMod)
            oJsonRequest["largura"]     := IIf(nLargMod == 0, Nil, nLargMod)
            oJsonRequest["comprimento"] := IIf(nCompMod == 0, Nil, nCompMod)
            oJsonRequest["deposito"]    := IIf(Empty(cDeposito), Nil, cDeposito)

            // Array barras
            oBarra := JsonObject():New()
            oBarra["codigo_Barra"] := IIf(Empty(cCodBar), Nil, cCodBar)
            oBarra["codigoModelo"] := IIf(Empty(cCodMod), Nil, cCodMod)
            oBarra["cor_Produto"]  := IIf(Empty(cCodCor), Nil, cCodCor)
            oBarra["tamanho"]      := IIf(Empty(cCodTam), Nil, cCodTam)
            oBarra["quantidade"]   := IIf(nZ7Pct == 0,    Nil, nZ7Pct)

            oJsonRequest["barras"] := {oBarra}
            oJsonRequest["lotes"]  := {}

            // Array modelos
            oModelo := JsonObject():New()
            oModelo["codigoModelo"]            := IIf(Empty(cCodMod), Nil, cCodMod)
            oModelo["descricao"]               := IIf(Empty(cZ7Desc), Nil, cZ7Desc)
            oModelo["quantidadePack"]          := IIf(nZ7Pct  == 0, Nil, nZ7Pct)
            oModelo["quantodadePackNaCaixa"]   := IIf(nZ7Caix == 0, Nil, nZ7Caix)
            oModelo["quantidadePackImportado"] := IIf(nZ7Com  == 0, Nil, nZ7Com)
            oModelo["codigoEmbalagem"]         := IIf(Empty(cCodMod), Nil, cCodMod)
            oModelo["comprimentoMovimentacao"] := IIf(nMComp == 0, Nil, nMComp)
            oModelo["larguraMovimentacao"]     := IIf(nMLarg == 0, Nil, nMLarg)
            oModelo["alturaMovimentacao"]      := IIf(nMAlt == 0,  Nil, nMAlt)

            oJsonRequest["modelos"] := {oModelo}

            oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")

            ConOut("BUD1508 PE JSON ENVIADO: [" + oJsonRequest:ToJson() + "]")

            oRest:Post(aHeader)

            cJsonRet := oRest:GetResult()

            If !Empty(cJsonRet)
                cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
                oJsonRet:FromJson(cJsonRet)
            EndIf

            IF cJsonRet <> "true"
                ConOut("BUD1508 PE: Erro ao integrar produto cod: " + cCod + " desc: " + cDesc)
                lSuces := .F.
            Else
                ConOut("BUD1508 PE: Produto integrado com sucesso: " + cCod + " - " + cDesc)
                lSuces := .T.
            EndIf

        EndIf

        nTotal := 1

    EndIf

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
