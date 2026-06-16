#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1520
    Funcao para integrar dados de distribuicao no WMS (Importados).
    Sera acionada juntamente com a API de Recebimento (BUD1498) no caso de
    recebimento de Importado. Envia informacoes da caixa e dos produtos.

    Endpoint: POST /api/Integration/DistribuicaoV2

    VINCULO ENTRE TABELAS:
    ----------------------
    SF2 (F2_DOC / F2_SERIE)
     -> ZCQ (ZCQ_DOC = F2_DOC, ZCQ_SERIE = F2_SERIE) -> ZCQ_NUMROM (romaneio)
         -> ZZ5 (ZZ5_ROMENV = ZCQ_NUMROM) -> dados de caixas e produtos
    SC5 (C5_NOTA = F2_DOC, C5_SERIE = F2_SERIE) -> dados do pedido
    SB1 (B1_COD = ZZ5_PRODUT) -> cor, tamanho, grife, colecao
    SA1 (A1_COD = C5_CLIENTE)  -> grupo do cliente
    SM0 -> descricao da filial

    @type function
    @author Caique
    @since 12/05/2026 BUD1520.prw
/*/
User Function BUD1520()

    Local oRest             := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath             := "/api/Integration/DistribuicaoV2"
    Local aHeader           := {}
    Local oAuth             := Nil
    Local oJsonRet          := JsonObject():New()
    Local cJsonRet          := ""
    Local cJsonBody         := ""
    Local cQuery            := ""
    Local cQueryRom         := ""
    Local cQueryDist        := ""
    Local nTotal            := 0
    Local nProcessados      := 0
    Local nIgnorados        := 0
    Local cRomaneio         := ""
    Local aItens            := {}
    Local oItem             := Nil
    Local QRY_SF2           := ""
    Local nCaixaSeq         := 0

    If IsBlind()
        RPCSETENV("01", "01")
    EndIf

    // ===============================
    // Autenticacao
    // ===============================
    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    // ===============================
    // Query principal: Notas fiscais de importado nao integradas
    // F2_ESPECI1 = '107' (Pallet) - Importados
    // ===============================
    cQuery := " SELECT SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, "
    cQuery += "        SC5.C5_NOTA, SC5.C5_SERIE, "
    cQuery += "        SA1.A1_GRUPO, "
    cQuery += "        SF2.F2_DOC, SF2.F2_SERIE AS F2_SERIE, SF2.F2_ESPECI1, "
    cQuery += "        SC5.R_E_C_N_O_ AS REC "
    cQuery += " FROM " + RetSQLName("SF2") + " SF2 (NOLOCK) "
    cQuery += " INNER JOIN " + RetSQLName("SC5") + " SC5 (NOLOCK) "
    cQuery += "   ON SC5.C5_NOTA    = SF2.F2_DOC "
    cQuery += "  AND SC5.C5_SERIE   = SF2.F2_SERIE "
    cQuery += "  AND SC5.C5_FILIAL  = SF2.F2_FILIAL "
    cQuery += "  AND SC5.D_E_L_E_T_ = ' ' "
    cQuery += " LEFT JOIN " + RetSQLName("SA1") + " SA1 (NOLOCK) "
    cQuery += "   ON SA1.A1_COD     = SC5.C5_CLIENTE "
    cQuery += "  AND SA1.A1_LOJA    = SC5.C5_LOJACLI "
    cQuery += "  AND SA1.A1_FILIAL  = SC5.C5_FILIAL "
    cQuery += "  AND SA1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE SF2.D_E_L_E_T_ = ' ' "
    cQuery += "   AND SF2.F2_ESPECI1 = '107' "
    cQuery += "   AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "' "
    cQuery += "   AND SC5.C5_EMISSAO > '20260101' "
    //cQuery += "   AND SC5.C5_INTDIS  = ' ' "               // somente nao integradas (distribuicao)
    cQuery += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC "

    If Select("QRY_SF2") > 0
        QRY_SF2->(DbCloseArea())
    EndIf

    QRY_SF2 := GETNEXTALIAS()
    MPSysOpenQuery(cQuery, QRY_SF2)

    // ==========================================================================
    // LOOP PRINCIPAL: processa cada nota fiscal
    // ==========================================================================
    While (QRY_SF2)->(!Eof())

        nTotal++
        aItens    := {}
        cRomaneio := ""

        // ----------------------------------------------------------------------
        // BUSCA DO ROMANEIO via tabela ZCQ
        // ----------------------------------------------------------------------
        cQueryRom := " SELECT TOP 1 ZCQ_NUMROM "
        cQueryRom += " FROM " + RetSQLName("ZCQ") + " ZCQ (NOLOCK) "
        cQueryRom += " WHERE ZCQ.D_E_L_E_T_ = ' ' "
        cQueryRom += "   AND ZCQ.ZCQ_DOC    = " + ValToSql(AllTrim((QRY_SF2)->C5_NOTA))
        cQueryRom += "   AND ZCQ.ZCQ_SERIE  = " + ValToSql(AllTrim((QRY_SF2)->C5_SERIE))
        cQueryRom += "   AND LTRIM(RTRIM(ZCQ.ZCQ_NUMROM)) <> '' "

        If Select("QRY_ROM") > 0
            QRY_ROM->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryRom, "QRY_ROM")

        If !(QRY_ROM)->(Eof())
            cRomaneio := AllTrim((QRY_ROM)->ZCQ_NUMROM)
        EndIf
        QRY_ROM->(DbCloseArea())

        // Se nao encontrou romaneio, pula para proxima nota
        If Empty(cRomaneio)
            ConOut("[BUD1520 DIST] Romaneio nao encontrado para nota " + AllTrim((QRY_SF2)->C5_NOTA))
            nIgnorados++
            (QRY_SF2)->(DbSkip())
            Loop
        EndIf

        // ----------------------------------------------------------------------
        // BUSCA DOS ITENS DE DISTRIBUICAO via ZZ5 (caixas/produtos)
        //
        // Monta query que busca todos os itens do romaneio com dados complementares:
        //   ZZ5 -> caixa, produto, quantidade
        //   SB1 -> cor, tamanho, grife, colecao
        //   SA1 -> grupo (via SC5)
        //   SM0 -> descricao da filial
        // ----------------------------------------------------------------------
        cQueryDist := " SELECT ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT, "
        cQueryDist += "        SUM(ZZ5.ZZ5_QTDENC) AS ZZ5_QTDENC, "
        cQueryDist += "        MAX(ISNULL(SB1.B1_CODCOR,  ''))  AS B1_CODCOR, "
        cQueryDist += "        MAX(ISNULL(SB1.B1_CODTAM,  ''))  AS B1_CODTAM, "
        cQueryDist += "        MAX(ISNULL(SB1.B1_CODMOD,  ''))  AS B1_CODMOD, "
        cQueryDist += "        MAX(ISNULL(SB1.B1_GRIFE,   ''))  AS B1_GRIFE, "
        cQueryDist += "        MAX(ISNULL(SB1.B1_COLECAO, ''))  AS B1_COLECAO, "
        cQueryDist += "        MAX(ISNULL(ZDU.ZDU_CAIXA,  ''))  AS ZDU_CAIXA, "
        cQueryDist += "        ROW_NUMBER() OVER (ORDER BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT) AS SEQCAIXA "
        cQueryDist += " FROM " + RetSQLName("ZZ5") + " ZZ5 (NOLOCK) "
        cQueryDist += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
        cQueryDist += "   ON SB1.B1_COD     = ZZ5.ZZ5_PRODUT "
        cQueryDist += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
        cQueryDist += "  AND SB1.D_E_L_E_T_ = ' ' "
        cQueryDist += " LEFT JOIN " + RetSQLName("ZDU") + " ZDU (NOLOCK) "
        cQueryDist += "   ON ZDU.ZDU_PRODUT  = ZZ5.ZZ5_PRODUT "
        cQueryDist += "  AND ZDU.ZDU_ROMENV  = ZZ5.ZZ5_ROMENV "
        cQueryDist += "  AND ZDU.D_E_L_E_T_  = ' ' "
        cQueryDist += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
        cQueryDist += "   AND ZZ5.ZZ5_ROMENV = " + ValToSql(cRomaneio)
        cQueryDist += " GROUP BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "
        cQueryDist += " ORDER BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "

        If Select("QRY_DST") > 0
            QRY_DST->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryDist, "QRY_DST")

        // ----------------------------------------------------------------------
        // Monta array de itens (JSON flat: cada registro = 1 item)
        // ----------------------------------------------------------------------
        nCaixaSeq := 0

        While (QRY_DST)->(!Eof())

            oItem := JsonObject():New()

            // Pedido e Filial
            oItem["pedido"]       := AllTrim((QRY_SF2)->C5_NUM)
            oItem["codigoFilial"] := AllTrim((QRY_SF2)->C5_FILIAL)

            // Caixa - codigo numerico sequencial e nome
            nCaixaSeq++
            oItem["codigoCaixa"] := nCaixaSeq

            // Prioridade: ZZ5_CODBOX -> ZDU_CAIXA -> placeholder
            If !Empty(AllTrim((QRY_DST)->ZZ5_CODBOX))
                oItem["caixa"]     := AllTrim((QRY_DST)->ZZ5_CODBOX)
                oItem["caixaNome"] := AllTrim((QRY_DST)->ZZ5_CODBOX)
            ElseIf !Empty(AllTrim((QRY_DST)->ZDU_CAIXA))
                oItem["caixa"]     := AllTrim((QRY_DST)->ZDU_CAIXA)
                oItem["caixaNome"] := AllTrim((QRY_DST)->ZDU_CAIXA)
            Else
                oItem["caixa"]     := "CX" + StrZero(nCaixaSeq, 4)
                oItem["caixaNome"] := "CX" + StrZero(nCaixaSeq, 4)
            EndIf

            // Codigo de distribuicao (romaneio como referencia)
            oItem["codigoDistribuicao"] := cRomaneio

            // Produto
            oItem["produto"] := AllTrim((QRY_DST)->ZZ5_PRODUT)

            // Cor
            If !Empty(AllTrim((QRY_DST)->B1_CODCOR))
                oItem["cor"] := AllTrim((QRY_DST)->B1_CODCOR)
            Else
                oItem["cor"] := ""
            EndIf

            // Tamanho
            If !Empty(AllTrim((QRY_DST)->B1_CODTAM))
                oItem["tamanho"] := AllTrim((QRY_DST)->B1_CODTAM)
            Else
                oItem["tamanho"] := ""
            EndIf

            // Grade (codigo do modelo)
            If !Empty(AllTrim((QRY_DST)->B1_CODMOD))
                oItem["grade"] := AllTrim((QRY_DST)->B1_CODMOD)
            Else
                oItem["grade"] := ""
            EndIf

            // Quantidade
            oItem["quantidade"] := (QRY_DST)->ZZ5_QTDENC

            // Grupo do cliente
            If !Empty(AllTrim((QRY_SF2)->A1_GRUPO))
                oItem["grupo"] := AllTrim((QRY_SF2)->A1_GRUPO)
            Else
                oItem["grupo"] := ""
            EndIf

            // Grife
            If !Empty(AllTrim((QRY_DST)->B1_GRIFE))
                oItem["grife"] := AllTrim((QRY_DST)->B1_GRIFE)
            Else
                oItem["grife"] := ""
            EndIf

            // Colecao
            If !Empty(AllTrim((QRY_DST)->B1_COLECAO))
                oItem["colecao"] := AllTrim((QRY_DST)->B1_COLECAO)
            Else
                oItem["colecao"] := ""
            EndIf

            // Cabide (vazio por enquanto - ajustar conforme tabela origem)
            oItem["cabide"] := ""

            // Codigo Rota (vazio por enquanto - ajustar conforme tabela origem)
            oItem["codigoRota"] := ""

            // Descricao da Filial
            oItem["descricaoFilial"] := FWFilialName()

            AAdd(aItens, oItem)

            (QRY_DST)->(DbSkip())

        End

        If Select("QRY_DST") > 0
            QRY_DST->(DbCloseArea())
        EndIf

        // ----------------------------------------------------------------------
        // Se nao encontrou itens, pula para proxima nota
        // ----------------------------------------------------------------------
        If Len(aItens) == 0
            ConOut("[BUD1520 DIST] Nenhum item encontrado para romaneio " + cRomaneio + " nota " + AllTrim((QRY_SF2)->C5_NOTA))
            nIgnorados++
            (QRY_SF2)->(DbSkip())
            Loop
        EndIf

        // ----------------------------------------------------------------------
        // ENVIO PARA A API REST
        // Endpoint: POST /api/Integration/DistribuicaoV2
        // Body: array de objetos JSON (flat)
        // ----------------------------------------------------------------------
        cJsonBody := FWJsonSerialize(aItens)

        ConOut("[BUD1520 DIST] JSON ENVIADO - Nota: " + AllTrim((QRY_SF2)->C5_NOTA) + " - " + cJsonBody)

        oRest:SetPath(cPath)
        oRest:SetPostParams(cJsonBody)
        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        oJsonRet := JsonObject():New()
        If !Empty(cJsonRet)
            cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
            oJsonRet:FromJson(cJsonRet)
        EndIf

        // Atualiza status de integracao no SC5
        SC5->(DbSetOrder(1))
        SC5->(DBGoTo((QRY_SF2)->REC))

        If Empty(cJsonRet) .OR. oJsonRet["badRequest"] == .T.
            nIgnorados++
            ConOut("[BUD1520 DIST] Erro ao integrar distribuicao nota: " + AllTrim((QRY_SF2)->C5_NOTA))

            If AllTrim(SC5->C5_NUM) == AllTrim((QRY_SF2)->C5_NUM)
                SC5->(Reclock("SC5", .F.))
                SC5->C5_INTDIS := "E"
                SC5->(MsUnLock())
            EndIf
        Else
            nProcessados++
            ConOut("[BUD1520 DIST] Distribuicao integrada com sucesso nota: " + AllTrim((QRY_SF2)->C5_NOTA))

            If AllTrim(SC5->C5_NUM) == AllTrim((QRY_SF2)->C5_NUM)
                SC5->(Reclock("SC5", .F.))
                SC5->C5_INTDIS := "S"
                SC5->(MsUnLock())
            EndIf
        EndIf

        (QRY_SF2)->(DbSkip())

    End

    If Select("QRY_SF2") > 0
        QRY_SF2->(DbCloseArea())
    EndIf

    // ===============================
    // LOG: Resumo final
    // ===============================
    ConOut("[BUD1520 DIST] Total: " + cValToChar(nTotal) + ;
        " | OK: "   + cValToChar(nProcessados) + ;
        " | Erro: " + cValToChar(nIgnorados))

    If IsBlind()
        RpcClearEnv()
    EndIf

Return .T.
