#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUDPALE
    Funcao responsavel por integrar as notas fiscais faturadas (Pallet e Gaiola)
    com o sistema WMS PDA HUB, enviando os dados de recebimento via API REST.

    FLUXO GERAL:
    ------------
    1. Busca notas nao integradas em SF2/SC5 com F2_ESPECI1 IN ('107','066')
    2. Para cada nota, busca o romaneio via tabela ZCQ (ZCQ_DOC=F2_DOC / ZCQ_SERIE=F2_SERIE)
    3. Monta o JSON de recebimento conforme estrutura da API
    4. Se F2_ESPECI1 = '107' -> tipo PALLET -> busca estrutura na ZZ5 (pallets > caixas > itens)
    5. Se F2_ESPECI1 = '066' -> tipo GAIOLA -> busca estrutura na ZDU (gaiolas > itens)
    6. Busca as caixas fisicas na ZZ5 (por romaneio, agrupado por caixa)
    7. Itens da NF (SD2) so sao enviados se UnidadeArmazenagem estiver vazia
    8. Campo "xml" e sempre omitido (API possui XmlDocument que nao aceita [null])
    9. Envia JSON via POST para /api/Integration/Recebimento
    9. Atualiza C5_INTWMS = 'S' (sucesso) ou 'E' (erro) no SC5

    VINCULO ENTRE TABELAS:
    ----------------------
    SF2 (F2_DOC / F2_SERIE)
     -> ZCQ (ZCQ_DOC = F2_DOC, ZCQ_SERIE = F2_SERIE) -> ZCQ_NUMROM (romaneio)
         -> ZZ5 (ZZ5_ROMENV = ZCQ_NUMROM) -> dados de pallets e caixas
         -> ZDU (ZDU_ROMENV = ZCQ_NUMROM) -> dados de gaiolas

    REGRAS DA API (recomendacoes do fornecedor):
    --------------------------------------------
    1. CAMPOS NULOS: nao enviar o campo quando o valor for nulo ou vazio.
       Omitir o campo do JSON e preferivel a enviar null ou "".
    2. UNIDADE DE ARMAZENAGEM x ITENS: se UnidadeArmazenagem estiver preenchida,
       NAO enviar o array "itens". Enviar ambos causa inconsistencia no processamento.


    @type function
    @author Daniel Victor da Rosa / Caique Silva - Personalitec
    @since 30/01/2026
/*/
User Function BUD1498()

    Local oRest             := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath             := "/api/Integration/Recebimento"
    Local aHeader           := {}
    Local oAuth             := Nil
    //Local oLogger           := PDALogger():New()
    Local oJsonRequest      := Nil
    Local oJsonRet          := JsonObject():New()
    Local cJsonRet          := ""
    Local cJsonBody         := ""
    Local cCurl             := ""
    Local cAuthHdr          := ""
    Local nH                := 0
    Local cQuery            := ""
    Local cQueryC6          := ""
    Local cQueryRom         := ""     // query do romaneio (ZCQ)
    Local cQueryPallet      := ""     // query dos pallets (ZZ5)
    Local cQueryGaiola      := ""     // query das gaiolas (ZDU)
    Local cQueryCaixas      := ""     // query das caixas fisicas (ZZ5)
    Local nTotal            := 0      // total de notas encontradas na query
    Local nProcessados      := 0      // notas integradas com sucesso
    Local nIgnorados        := 0      // notas com erro na integracao
    Local cRomaneio         := ""     // numero do romaneio obtido via ZCQ
    Local cEmissaoUTC       := ""     // data de emissao da NF em formato UTC (API exige)
    Local cDtEntUTC         := ""     // data de entrega em formato UTC
    Local cEspeci1          := ""     // codigo do tipo: "107"=Pallet / "066"=Gaiola
    Local lTemArmazenagem   := .F.    // .T. se UnidadeArmazenagem foi preenchida com dados
    Local oPedVenda         := Nil    // objeto "pedidoVenda" do JSON
    Local oUnidArm          := Nil    // objeto "UnidadeArmazenagem" (Pallet ou Gaiola)
    Local oPallet           := Nil    // objeto de um pallet individual
    Local oCaixaVenda       := Nil
    Local oItemCX           := Nil
    Local oGaiola           := Nil
    Local oCaixa            := Nil
    Local oItemCaixa        := Nil
    Local oItem             := Nil
    Local aPallets          := {}     // lista de pallets do pedido
    Local aGaiolas          := {}     // lista de gaiolas do pedido
    Local aCaixas           := {}     // lista de caixas fisicas do pedido
    Local aItensCaixaVenda  := {}     // itens acumulados da caixa dentro do pallet
    Local aItensGaiola      := {}     // itens acumulados da gaiola
    Local aItensCaixa       := {}     // itens acumulados da caixa fisica
    Local cPalletAtual      := ""     // codigo do pallet em processamento
    Local cCaixaVendaAtual  := ""     // codigo da caixa do pallet em processamento (resolvido: apos fallback)
    Local cCaixaVendaRaw   := "###"  // valor bruto de ZZ5_CODBOX para deteccao de quebra de grupo
    Local cGaiolaAtual      := ""     // codigo da gaiola em processamento
    Local cCaixaAtual       := ""     // codigo da caixa fisica em processamento (resolvido: apos fallback)
    Local cCaixaRaw        := "###"  // valor bruto de ZZ5_CODBOX para deteccao de quebra de grupo (caixas fisicas)
    Local nCaixaSeq         := 0      // sequencial para placeholder de caixa sem codigo
    Local QRY_SC5           := ""     // alias da query principal (SF2/SC5) - dinamico
    Local QRY_SC6           := ""     // alias da query de itens SD2 - dinamico
    Local QRY_ROM           := "QRY_ROM"   // alias fixo da query ZCQ (romaneio)
    Local QRY_PAL           := "QRY_PAL"   // alias fixo da query ZZ5 (pallets)
    Local QRY_GAI           := "QRY_GAI"   // alias fixo da query ZDU (gaiolas)
    Local QRY_CXS           := "QRY_CXS"   // alias fixo da query ZZ5 (caixas fisicas)
    Local cQueryImp      := ""
    Local cQueryImpItens := ""
    Local cQueryImpRom   := ""
    Local cQueryImpDist  := ""
    Local nTotalImp      := 0
    Local nProcessImp    := 0
    Local nIgnoradosImp  := 0
    Local cRomaneioImp   := ""
    Local cEmissaoImpUTC := ""
    Local cDtEntImpUTC   := ""
    Local cPedidoImp     := ""
    Local oJsonReqImp    := Nil
    Local oJsonRetImp    := Nil
    Local cJsonRetImp    := ""
    Local cJsonBodyImp   := ""
    Local oItemImp       := Nil
    Local cPathDist      := "/api/Integration/DistribuicaoV2"
    Local aItensDist     := {}
    Local oItemDist      := Nil
    Local oJsonRetDist   := Nil
    Local cJsonRetDist   := ""
    Local cJsonBodyDist  := ""
    Local nCaixaSeqImp   := 0
    Local nI             := 0
    Local cCaixaImp      := ""
    Local cCorNorm       := ""
    Local cTamNorm       := ""

    //oLogger:Gravar(PDALogEntry():New("SC5", "INICIO", "", "Inicio integracao BUDPALE"))

    RPCSETENV("01", "01")


    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    cQuery := " SELECT SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJACLI, "
    cQuery += "        SC5.C5_PEDCLI, SC5.C5_EMISSAO, SC5.C5_DTENT, "
    cQuery += "        SC5.C5_NOTA, SC5.C5_SERIE, SC5.C5_TIPO1, SC5.C5_DTFAT, "
    cQuery += "        SA1.A1_GRUPO, "
    cQuery += "        SF2.F2_CHVNFE, SF2.F2_DOC, SF2.F2_SERIE AS F2_SERIE, SF2.F2_ESPECI1, "
    cQuery += "        SC5.R_E_C_N_O_ AS REC "   // RECNO do SC5 para atualizar C5_INTWMS ao final
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
    cQuery += "   AND SF2.F2_ESPECI1 = '066' "   // 107=Pallet, 066=Gaiola
    cQuery += "   AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "' "
    cQuery += "   AND SC5.C5_EMISSAO > '20260101' "
    //cQuery += "   AND SC5.C5_INTWMS  = ' ' "               // somente nao integradas
    //cQuery += "   AND SF2.F2_DOC     = '000000031' "        // FILTRO DE TESTE - remover em producao
    cQuery += " ORDER BY SF2.F2_FILIAL, SF2.F2_DOC "

    // Garante que o alias nao existe antes de abrir (evita erro de alias duplicado)
    If Select("QRY_SC5") > 0
        QRY_SC5->(DbCloseArea())
    EndIf

    // Abre a query com alias dinamico (GETNEXTALIAS gera nome unico)
    QRY_SC5 := GETNEXTALIAS()
    MPSysOpenQuery(cQuery, QRY_SC5)

    // Verifica se encontrou alguma nota para integrar
    If (QRY_SC5)->(Eof())
        MsgAlert("Nenhuma nota encontrada para integrar! Verifique os filtros.", "ATENCAO")
        RpcClearEnv()
        Return .F.
    EndIf

    // Diagnostico visual: exibe a primeira nota encontrada antes de iniciar o loop
    MsgInfo("Nota encontrada: " + AllTrim((QRY_SC5)->C5_NOTA) + ;
        " | Pedido: "  + AllTrim((QRY_SC5)->C5_NUM)    + ;
        " | Tipo: "    + AllTrim((QRY_SC5)->F2_ESPECI1), "Diagnostico SC5")

    // ==========================================================================
    // LOOP PRINCIPAL: processa cada nota fiscal encontrada
    // ==========================================================================
    While (QRY_SC5)->(!Eof())

        nTotal++
        lTemArmazenagem := .F.   // reinicia flag de armazenagem para cada nota

        // ----------------------------------------------------------------------
        // Converte as datas para formato UTC exigido pela API
        // FWTimeStamp(3, data, hora) -> "YYYY-MM-DDTHH:MM:SS"
        // Formato final com milissegundos e fuso: "YYYY-MM-DDTHH:MM:SS.000Z"
        // ----------------------------------------------------------------------
        cEmissaoUTC := FWTimeStamp(3, STOD((QRY_SC5)->C5_EMISSAO), "00:00:00") + ".000Z"
        cDtEntUTC   := ""
        If !Empty(AllTrim((QRY_SC5)->C5_DTENT))
            cDtEntUTC := FWTimeStamp(3, STOD((QRY_SC5)->C5_DTENT), "00:00:00") + ".000Z"
        EndIf

        // ----------------------------------------------------------------------
        // BUSCA DO ROMANEIO via tabela ZCQ
        //
        // O romaneio e o vinculo central entre a NF e os dados de armazenagem:
        //   SF2 (F2_DOC / F2_SERIE) -> ZCQ (ZCQ_DOC / ZCQ_SERIE) -> ZCQ_NUMROM
        //
        // IMPORTANTE: ZCQ_FILIAL e SEMPRE VAZIO nesta base de dados.
        //   Filtrar por ZCQ_FILIAL = '01' retornaria zero registros.
        //   Por isso o filtro de filial e omitido na query ZCQ.
        //
        // TOP 1: garante que pega apenas o primeiro romaneio caso haja multiplos
        // LTRIM/RTRIM <> '': garante que o romaneio nao esteja em branco
        // ----------------------------------------------------------------------
        cRomaneio   := ""
        cQueryRom   := " SELECT TOP 1 ZCQ_NUMROM "
        cQueryRom   += " FROM " + RetSQLName("ZCQ") + " ZCQ (NOLOCK) "
        cQueryRom   += " WHERE ZCQ.D_E_L_E_T_ = ' ' "
        cQueryRom   += "   AND ZCQ.ZCQ_DOC    = " + ValToSql(AllTrim((QRY_SC5)->C5_NOTA))
        cQueryRom   += "   AND ZCQ.ZCQ_SERIE   = " + ValToSql(AllTrim((QRY_SC5)->C5_SERIE))
        // ZCQ_FILIAL e sempre vazio nessa tabela - nao filtra por filial
        cQueryRom   += "   AND LTRIM(RTRIM(ZCQ.ZCQ_NUMROM)) <> '' "

        If Select("QRY_ROM") > 0
            QRY_ROM->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryRom, "QRY_ROM")   // alias fixo "QRY_ROM"

        // Obtem o numero do romaneio se encontrado
        If !(QRY_ROM)->(Eof())
            cRomaneio := AllTrim((QRY_ROM)->ZCQ_NUMROM)
        EndIf
        QRY_ROM->(DbCloseArea())

        // Se nao encontrou romaneio, nao e possivel vincular a nota -> pula para proxima
        If Empty(cRomaneio)
            MsgAlert("Romaneio nao encontrado para a nota " + AllTrim((QRY_SC5)->C5_NOTA) + ;
                ". Nota ignorada.", "ATENCAO - Romaneio")
            (QRY_SC5)->(DbSkip())
            Loop
        EndIf

        // Diagnostico visual: confirma o romaneio obtido
        MsgInfo("Romaneio: " + cRomaneio + " | Nota: " + AllTrim((QRY_SC5)->C5_NOTA), "Romaneio OK")

        // ----------------------------------------------------------------------
        // MONTAGEM DO JSON RAIZ
        //
        // REGRA - CAMPOS NULOS: campos vazios/nulos NAO sao adicionados ao JSON.
        // O campo e omitido quando nao ha valor, evitando o envio de "" ou null.
        // Somente campos com valor efetivo sao incluidos no payload.
        // ----------------------------------------------------------------------
        oJsonRequest := JsonObject():New()

        // Campos obrigatorios - sempre presentes
        oJsonRequest["codigoPedido"]  := AllTrim((QRY_SC5)->C5_NUM)
        oJsonRequest["notaFiscal"]    := AllTrim((QRY_SC5)->C5_NOTA)
        oJsonRequest["serie"]         := AllTrim((QRY_SC5)->C5_SERIE)
        oJsonRequest["emissao"]       := cEmissaoUTC
        oJsonRequest["codigoFilial"]  := AllTrim((QRY_SC5)->C5_FILIAL)
        oJsonRequest["romaneio"]      := cRomaneio
        // Campo "xml" OMITIDO intencionalmente.


        // Campos opcionais - somente adicionados se tiverem valor
        If !Empty(AllTrim((QRY_SC5)->C5_PEDCLI))
            oJsonRequest["referenciaPedido"] := AllTrim((QRY_SC5)->C5_PEDCLI)
        EndIf
        If !Empty(AllTrim((QRY_SC5)->F2_CHVNFE))
            oJsonRequest["chaveNfe"] := AllTrim((QRY_SC5)->F2_CHVNFE)
        EndIf
        If !Empty(AllTrim((QRY_SC5)->C5_TIPO1))
            oJsonRequest["tipoEntrada"] := AllTrim((QRY_SC5)->C5_TIPO1)
        EndIf
        If !Empty(cDtEntUTC)
            oJsonRequest["dataEntegra"] := cDtEntUTC
        EndIf
        // Campos: codigoFornecedorErp, sequenciaErp, codigoFilialAvaria,
        //         codigoFilialDivergencia, campanha, dataEntregaLimite
        //         -> omitidos pois nao possuem valor nesta integracao

        // ==========================================================================
        // UNIDADE DE ARMAZENAGEM
        // Define o tipo de armazenagem com base no campo F2_ESPECI1 da nota fiscal:
        //   "107" -> PALLET: estrutura hierarquica Pallet > CaixaVenda > ItensCaixaVenda
        //   "066" -> GAIOLA: estrutura hierarquica Gaiola > ItensGaiola
        // ==========================================================================
        cEspeci1 := AllTrim((QRY_SC5)->F2_ESPECI1)
        aPallets  := {}    // reinicia array de pallets para esta nota
        aGaiolas  := {}    // reinicia array de gaiolas para esta nota
        oUnidArm  := JsonObject():New()

        If cEspeci1 == "107"

            // ------------------------------------------------------------------
            // TIPO PALLET (F2_ESPECI1 = '107')
            //
            // Tabela: ZZ5 (vinculada pelo romaneio: ZZ5_ROMENV = cRomaneio)
            //
            // Estrutura hierarquica (3 niveis):
            //   Nivel 1 (Pallet):    ZZ5_PALLET  -> oPallet  -> aPallets
            //   Nivel 2 (CaixaVenda):ZZ5_CODBOX  -> oCaixaVenda -> CaixasVenda[]
            //   Nivel 3 (Item):      ZZ5_PRODUT  -> oItemCX  -> itensCaixaVenda[]
            //
            // GROUP BY ZZ5_PALLET, ZZ5_CODBOX, ZZ5_PRODUT:
            //   Necessario para evitar linhas duplicadas na ZZ5, que causariam
            //   loop infinito e contagem errada de quantidade. O SUM(ZZ5_QTDENC)
            //   consolida a quantidade total do produto por caixa/pallet.
            //
            // Filtro AND ZZ5_PALLET <> '':
            //   Ignora registros sem pallet identificado.
            //
            // JOIN SB1: busca cor, tamanho e modelo do produto
            // JOIN SZ7: busca quantidade por pack (Z7_QTDPCT) via codigo do modelo
            // ------------------------------------------------------------------
            cQueryPallet := " SELECT ZZ5.ZZ5_PALLET, ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT, "
            cQueryPallet += "        SUM(ZZ5.ZZ5_QTDENC)                    AS ZZ5_QTDENC, "
            // ISNULL garante que LEFT JOIN sem correspondencia retorne '' em vez de NULL
            // NULL causa "Invalid TMemoryStream::ReadMSString" no AllTrim() do AdvPL
            cQueryPallet += "        MAX(ISNULL(SB1.B1_CODCOR,  ''))        AS B1_CODCOR, "
            cQueryPallet += "        MAX(ISNULL(SB1.B1_CODTAM,  ''))        AS B1_CODTAM, "
            cQueryPallet += "        MAX(ISNULL(SB1.B1_CODMOD,  ''))        AS B1_CODMOD, "
            cQueryPallet += "        MAX(ISNULL(SZ7.Z7_QTDPCT,  0))         AS Z7_QTDPCT, "
            // ZDU_CAIXA: fallback para codigoCaixaVenda quando ZZ5_CODBOX estiver vazio
            cQueryPallet += "        MAX(ISNULL(ZDU.ZDU_CAIXA,  ''))        AS ZDU_CAIXA, "
            cQueryPallet += "        MAX(ISNULL((SELECT TOP 1 B2_LOCAL FROM " + RetSQLName("SB2") + " (NOLOCK) WHERE B2_COD = ZZ5.ZZ5_PRODUT AND B2_FILIAL = '" + xFilial("SB2") + "' AND D_E_L_E_T_ = ' ' ORDER BY B2_LOCAL), '')) AS B2_LOCAL "
            cQueryPallet += " FROM " + RetSQLName("ZZ5") + " ZZ5 (NOLOCK) "
            cQueryPallet += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
            cQueryPallet += "   ON SB1.B1_COD     = ZZ5.ZZ5_PRODUT "
            cQueryPallet += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
            cQueryPallet += "  AND SB1.D_E_L_E_T_ = ' ' "
            cQueryPallet += " LEFT JOIN " + RetSQLName("SZ7") + " SZ7 (NOLOCK) "
            cQueryPallet += "   ON SZ7.Z7_COD     = SB1.B1_CODMOD "
            cQueryPallet += "  AND SZ7.D_E_L_E_T_ = ' ' "
            // JOIN ZDU: busca ZDU_CAIXA como fallback quando ZZ5_CODBOX estiver vazio
            cQueryPallet += " LEFT JOIN " + RetSQLName("ZDU") + " ZDU (NOLOCK) "
            cQueryPallet += "   ON ZDU.ZDU_PRODUT  = ZZ5.ZZ5_PRODUT "
            cQueryPallet += "  AND ZDU.ZDU_ROMENV  = ZZ5.ZZ5_ROMENV "
            cQueryPallet += "  AND ZDU.D_E_L_E_T_  = ' ' "
            cQueryPallet += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
            cQueryPallet += "   AND ZZ5.ZZ5_ROMENV = " + ValToSql(cRomaneio)
            cQueryPallet += "   AND LTRIM(RTRIM(ZZ5.ZZ5_PALLET)) <> '' "   // somente com pallet preenchido
            cQueryPallet += " GROUP BY ZZ5.ZZ5_PALLET, ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "
            cQueryPallet += " ORDER BY ZZ5.ZZ5_PALLET, ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "

            If Select("QRY_PAL") > 0
                QRY_PAL->(DbCloseArea())
            EndIf
            MPSysOpenQuery(cQueryPallet, "QRY_PAL")   // alias fixo "QRY_PAL"

            If (QRY_PAL)->(Eof())
                MsgAlert("Nenhum pallet encontrado para o romaneio " + cRomaneio, "ATENCAO - Pallet")
            Else
                // Diagnostico visual: exibe o primeiro pallet encontrado
                MsgInfo("Pallet OK - Pallet: " + AllTrim((QRY_PAL)->ZZ5_PALLET) + ;
                    " | Produto: " + AllTrim((QRY_PAL)->ZZ5_PRODUT), "Pallet ZZ5")

                // Inicializa sentinelas de quebra de grupo
                // "###" garante que o PRIMEIRO registro sempre crie um novo grupo,
                // mesmo que ZZ5_PALLET ou ZZ5_CODBOX estejam vazios
                cPalletAtual     := "###"
                cCaixaVendaAtual := "###"
                cCaixaVendaRaw   := "###"   // sentinela bruta: compara o ZZ5_CODBOX puro (antes do fallback)
                oPallet          := Nil
                oCaixaVenda      := Nil
                aItensCaixaVenda := {}

                While (QRY_PAL)->(!Eof())

                    // ----------------------------------------------------------
                    // QUEBRA NIVEL 1: Pallet (ZZ5_PALLET)
                    // Quando o codigo do pallet muda, fecha o grupo anterior
                    // e abre um novo grupo de pallet
                    // ----------------------------------------------------------
                    If AllTrim((QRY_PAL)->ZZ5_PALLET) <> cPalletAtual

                        // Fecha a caixa anterior (se existir) antes de fechar o pallet
                        If oCaixaVenda != Nil
                            // Atribui o array nativo ao JsonObject somente no fechamento
                            // (nao usar AAdd direto em oJson["chave"] -> causa erro de subscriptor)
                            oCaixaVenda["itensCaixaVenda"] := aItensCaixaVenda
                            AAdd(oPallet["CaixasVenda"], oCaixaVenda)
                        EndIf
                        // Adiciona o pallet fechado ao array de pallets
                        If oPallet != Nil
                            AAdd(aPallets, oPallet)
                        EndIf

                        // Abre novo grupo de pallet
                        cPalletAtual     := AllTrim((QRY_PAL)->ZZ5_PALLET)
                        cCaixaVendaAtual := "###"    // reinicia sentinela de caixa para o novo pallet
                        cCaixaVendaRaw   := "###"    // reinicia sentinela bruta de caixa para o novo pallet
                        oPallet          := JsonObject():New()
                        oPallet["codigoPalete"] := cPalletAtual
                        oPallet["CaixasVenda"]  := {}   // array de caixas deste pallet
                        oCaixaVenda      := Nil
                        aItensCaixaVenda := {}

                    EndIf

                    // ----------------------------------------------------------
                    // QUEBRA NIVEL 2: Caixa de Venda (ZZ5_CODBOX)
                    // Quando o codigo da caixa muda, fecha o grupo anterior
                    // e abre uma nova caixa dentro do pallet atual.
                    //
                    // ATENCAO: a comparacao usa cCaixaVendaRaw (valor bruto do banco),
                    // NAO cCaixaVendaAtual (valor ja resolvido pelo fallback).
                    // Motivo: quando ZZ5_CODBOX esta vazio, o fallback resolve para
                    // "CX0001", "CX0002" etc. Se compararmos o bruto "" contra o
                    // resolvido "CX0001", qualquer linha seguinte com "" dispararia
                    // uma nova quebra, criando uma caixa por produto em vez de agrupar.
                    // ----------------------------------------------------------
                    If AllTrim((QRY_PAL)->ZZ5_CODBOX) <> cCaixaVendaRaw

                        // Fecha a caixa anterior (se existir)
                        If oCaixaVenda != Nil
                            oCaixaVenda["itensCaixaVenda"] := aItensCaixaVenda
                            AAdd(oPallet["CaixasVenda"], oCaixaVenda)
                        EndIf

                        // Registra o valor bruto para futuras comparacoes de quebra
                        cCaixaVendaRaw   := AllTrim((QRY_PAL)->ZZ5_CODBOX)

                        // Abre nova caixa de venda
                        // Prioridade: ZZ5_CODBOX -> ZDU_CAIXA -> placeholder sequencial
                        cCaixaVendaAtual := cCaixaVendaRaw
                        If Empty(cCaixaVendaAtual)
                            cCaixaVendaAtual := AllTrim((QRY_PAL)->ZDU_CAIXA)
                        EndIf
                        If Empty(cCaixaVendaAtual)
                            nCaixaSeq++
                            cCaixaVendaAtual := "CX" + StrZero(nCaixaSeq, 4)
                        EndIf
                        oCaixaVenda      := JsonObject():New()
                        oCaixaVenda["codigoCaixaVenda"] := cCaixaVendaAtual
                        aItensCaixaVenda := {}   // reinicia array de itens para a nova caixa

                    EndIf

                    // ----------------------------------------------------------
                    // NIVEL 3: Item da Caixa de Venda (ZZ5_PRODUT)
                    // Monta o objeto do item e acumula no array nativo aItensCaixaVenda
                    // Campos opcionais: somente adicionados se tiverem valor
                    // ----------------------------------------------------------
                    oItemCX := JsonObject():New()
                    oItemCX["produto"]    := AllTrim((QRY_PAL)->ZZ5_PRODUT)
                    If !Empty(AllTrim((QRY_PAL)->B1_CODCOR))
                        oItemCX["cor"]        := AllTrim((QRY_PAL)->B1_CODCOR)
                    EndIf
                    If !Empty(AllTrim((QRY_PAL)->B1_CODTAM))
                        oItemCX["tamanho"]    := AllTrim((QRY_PAL)->B1_CODTAM)
                    EndIf
                    oItemCX["quantidade"]     := (QRY_PAL)->ZZ5_QTDENC
                    If (QRY_PAL)->Z7_QTDPCT != 0
                        oItemCX["quantidadePack"] := (QRY_PAL)->Z7_QTDPCT
                    EndIf
                    If !Empty(AllTrim((QRY_PAL)->B2_LOCAL))
                        oItemCX["deposito"] := AllTrim((QRY_PAL)->B2_LOCAL)
                    EndIf
                    AAdd(aItensCaixaVenda, oItemCX)   // acumula no array nativo

                    (QRY_PAL)->(DbSkip())

                End  // While QRY_PAL

                // Fecha a ultima caixa e o ultimo pallet (nao ha mais quebra apos o ultimo registro)
                If oCaixaVenda != Nil
                    oCaixaVenda["itensCaixaVenda"] := aItensCaixaVenda
                    AAdd(oPallet["CaixasVenda"], oCaixaVenda)
                EndIf
                If oPallet != Nil
                    AAdd(aPallets, oPallet)
                EndIf

            EndIf

            QRY_PAL->(DbCloseArea())

            // Preenche o objeto UnidadeArmazenagem para Pallet
            oUnidArm["Tipo"]   := "Palete"   // tipo exigido pela API
            oUnidArm["Palete"] := aPallets   // array com todos os pallets montados
            // Campo "Gaiola" omitido pois e Pallet (nao enviar campo nulo)

            // Marca flag: armazenagem preenchida se ha ao menos um pallet
            lTemArmazenagem := (Len(aPallets) > 0)

        Else

            // ------------------------------------------------------------------
            // TIPO GAIOLA (F2_ESPECI1 = '066')
            //
            // Tabela: ZDU (vinculada pelo romaneio: ZDU_ROMENV = cRomaneio)
            //
            // Estrutura hierarquica (2 niveis):
            //   Nivel 1 (Gaiola): ZDU_CODGA  -> oGaiola  -> aGaiolas
            //   Nivel 2 (Item):   ZDU_PRODUT -> oItemGA  -> ItensGaiola[]
            //
            // IMPORTANTE: ZDU_FILIAL e SEMPRE VAZIO nesta base de dados.
            //   Filtrar por ZDU_FILIAL = '01' retornaria zero registros.
            //   Por isso o filtro de filial e omitido na query ZDU.
            //
            // GROUP BY ZDU_CODGA, ZDU_PRODUT:
            //   Necessario para evitar duplicatas. SUM(ZDU_MULTIP) consolida
            //   a quantidade total do produto por gaiola.
            //
            // JOIN SB1: busca cor, tamanho e modelo do produto
            // JOIN SZ7: busca quantidade por pack (Z7_QTDPCT) via codigo do modelo
            // ------------------------------------------------------------------
            // ------------------------------------------------------------------
            cQueryGaiola := " SELECT ZDU.ZDU_CODGA, ZDU.ZDU_PRODUT, "
            cQueryGaiola += "        MAX(ZDU.R_E_C_N_O_)              AS ZDUREC, "
            cQueryGaiola += "        SUM(ZDU.ZDU_MULTIP)              AS ZDU_MULTIP, "
            cQueryGaiola += "        MAX(ISNULL(SB1.B1_CODCOR,''))   AS B1_CODCOR, "
            cQueryGaiola += "        MAX(ISNULL(SB1.B1_CODTAM,''))   AS B1_CODTAM, "
            cQueryGaiola += "        MAX(ISNULL(SZ7.Z7_QTDPCT,0))    AS Z7_QTDPCT, "
            cQueryGaiola += "        ISNULL(B2.B2_LOCAL,'')          AS B2_LOCAL "
            cQueryGaiola += " FROM " + RetSQLName("ZDU") + " ZDU WITH(NOLOCK) "
            cQueryGaiola += " LEFT JOIN " + RetSQLName("SB1") + " SB1 WITH(NOLOCK) "
            cQueryGaiola += "   ON SB1.B1_COD     = ZDU.ZDU_PRODUT "
            cQueryGaiola += "  AND SB1.D_E_L_E_T_ = ' ' "
            cQueryGaiola += " LEFT JOIN " + RetSQLName("SZ7") + " SZ7 WITH(NOLOCK) "
            cQueryGaiola += "   ON SZ7.Z7_COD     = SB1.B1_CODMOD "
            cQueryGaiola += "  AND SZ7.D_E_L_E_T_ = ' ' "
            cQueryGaiola += " OUTER APPLY ( "
            cQueryGaiola += "     SELECT TOP 1 B2.B2_LOCAL "
            cQueryGaiola += "     FROM " + RetSQLName("SB2") + " B2 WITH(NOLOCK) "
            cQueryGaiola += "     WHERE B2.B2_COD     = ZDU.ZDU_PRODUT "
            cQueryGaiola += "       AND B2.B2_FILIAL  = '" + xFilial("SB2") + "' "
            cQueryGaiola += "       AND B2.D_E_L_E_T_ = ' ' "
            cQueryGaiola += "     ORDER BY B2.B2_LOCAL "
            cQueryGaiola += " ) B2 "
            cQueryGaiola += " WHERE ZDU.D_E_L_E_T_ = ' ' "
            cQueryGaiola += "   AND ZDU.ZDU_ROMENV = " + ValToSql(cRomaneio)
            cQueryGaiola += " GROUP BY ZDU.ZDU_CODGA, ZDU.ZDU_PRODUT, B2.B2_LOCAL "
            cQueryGaiola += " ORDER BY ZDU.ZDU_CODGA, ZDU.ZDU_PRODUT "

            If Select("QRY_GAI") > 0
                QRY_GAI->(DbCloseArea())
            EndIf
            MPSysOpenQuery(cQueryGaiola, "QRY_GAI")   // alias fixo "QRY_GAI"

            If (QRY_GAI)->(Eof())
                MsgAlert("Nenhuma gaiola encontrada para o romaneio " + cRomaneio, "ATENCAO - Gaiola")
            Else
                // Diagnostico visual: exibe a primeira gaiola encontrada
                MsgInfo("Gaiola OK - Gaiola: " + AllTrim((QRY_GAI)->ZDU_CODGA) + ;
                    " | Produto: " + AllTrim((QRY_GAI)->ZDU_PRODUT), "Gaiola ZDU")

                // Inicializa sentinela de quebra de grupo para gaiola
                // "###" garante que o PRIMEIRO registro crie um novo grupo
                cGaiolaAtual  := "###"
                oGaiola       := Nil
                aItensGaiola  := {}

                While (QRY_GAI)->(!Eof())

                    // ----------------------------------------------------------
                    // QUEBRA NIVEL 1: Gaiola (ZDU_CODGA)
                    // Quando o codigo da gaiola muda, fecha o grupo anterior
                    // e abre uma nova gaiola
                    // ----------------------------------------------------------
                    If AllTrim((QRY_GAI)->ZDU_CODGA) <> cGaiolaAtual

                        // Fecha a gaiola anterior (se existir) antes de abrir a nova
                        If oGaiola != Nil
                            // Atribui o array nativo ao JsonObject no fechamento do grupo
                            oGaiola["ItensGaiola"] := aItensGaiola
                            AAdd(aGaiolas, oGaiola)
                        EndIf

                        // Abre nova gaiola
                        cGaiolaAtual := AllTrim((QRY_GAI)->ZDU_CODGA)
                        oGaiola      := JsonObject():New()
                        oGaiola["codigoGaiola"] :=  SubStr(AllTrim(cGaiolaAtual), 3,4)
                        aItensGaiola := {}   // reinicia array de itens para a nova gaiola

                    EndIf

                    // ----------------------------------------------------------
                    // NIVEL 2: Item da Gaiola (ZDU_PRODUT)
                    // Monta o objeto do item e acumula no array nativo aItensGaiola
                    // Campos opcionais: somente adicionados se tiverem valor
                    // ----------------------------------------------------------
                    oItemGA := JsonObject():New()
                    oItemGA["produto"]    := AllTrim((QRY_GAI)->ZDU_PRODUT)
                    oItemGA["quantidade"] := (QRY_GAI)->ZDU_MULTIP   // quantidade consolidada pelo SUM
                    If !Empty(AllTrim((QRY_GAI)->B1_CODCOR))
                        oItemGA["cor"]    := AllTrim((QRY_GAI)->B1_CODCOR)
                    EndIf
                    If !Empty(AllTrim((QRY_GAI)->B1_CODTAM))
                        oItemGA["tamanho"] := AllTrim((QRY_GAI)->B1_CODTAM)
                    EndIf
                    // grade omitido: nao utilizam grade nesta integracao
                    If (QRY_GAI)->Z7_QTDPCT != 0
                        oItemGA["quantidadePack"] := (QRY_GAI)->Z7_QTDPCT
                    EndIf
                    If !Empty(AllTrim((QRY_GAI)->B2_LOCAL))
                        oItemGA["deposito"] := AllTrim((QRY_GAI)->B2_LOCAL)
                    EndIf
                    AAdd(aItensGaiola, oItemGA)   // acumula no array nativo

                    (QRY_GAI)->(DbSkip())

                End  // While QRY_GAI

                // Fecha a ultima gaiola (nao ha mais quebra apos o ultimo registro)
                If oGaiola != Nil
                    oGaiola["ItensGaiola"] := aItensGaiola
                    AAdd(aGaiolas, oGaiola)
                EndIf

            EndIf

            // Preenche o objeto UnidadeArmazenagem para Gaiola
            oUnidArm["Tipo"]   := "Gaiola"   // tipo exigido pela API
            oUnidArm["Gaiola"] := aGaiolas   // array com todas as gaiolas montadas
            // Campo "Palete" omitido pois e Gaiola (nao enviar campo nulo)

            // Marca flag: armazenagem preenchida se ha ao menos uma gaiola
            lTemArmazenagem := (Len(aGaiolas) > 0)

        EndIf

       //DANIEL AJUSTE FEITO CONFORME SOLICITAÇÕA EM REUNIÃO.

        (QRY_GAI)->(DBGoTop())
        ZDU->(DBSetOrder(1))
        ZDU->(DBGoTo((QRY_GAI)->ZDUREC))  // busca pelo romaneio

        oPedVenda := JsonObject():New()
        oPedVenda["codigoPedidoVenda"]  := AllTrim(ZDU->ZDU_PEDIDO) //ZDU_PEDIDO
        oPedVenda["codigoCliente"]      := AllTrim(ZDU->ZDU_CLI) //ZDU_CLI
        oPedVenda["codigoLoja"]         := AllTrim(ZDU->ZDU_LOJA) //ZDU_LOJA
        oPedVenda["codigoGrupo"] := AllTrim(ZDU->ZDU_CLIGRU) //ZDU_CLIGRU
        oPedVenda["depositoErp"] := AllTrim(ZDU->ZDU_LOCAL) //ZDU_LOCAL
        IF !Empty(AllTrim(ZDU->ZDU_PEDIDO))
            cHora := Time()
            cDataFat := SubStr((QRY_SC5)->C5_DTFAT,1,4) + "-" +  SubStr((QRY_SC5)->C5_DTFAT,5,2) + "-" + SubStr((QRY_SC5)->C5_DTFAT,7,2) + "T" +  cHora + ".000Z"
            oPedVenda["dataFaturamento"] := cDataFat
        Else

            cQueryUi += " SELECT TOP 1 C5_DTFAT "
            cQueryUi += " FROM " + RetSQLName("SC5") + " SC5 WITH(NOLOCK) "
            cQueryUi += " WHERE SC5.C5_CLIENTE = ZDU.ZDU_CLI "
            cQueryUi += "   AND SC5.C5_LOJACLI = ZDU.ZDU_LOJA "
            cQueryUi += "   AND SC5.C5_DTFAT <> '' "
            cQueryUi += "   AND SC5.D_E_L_E_T_ = ' ' "
            cQueryUi += " ORDER BY SC5.R_E_C_N_O_ DESC "

            If Select(cAliasUI) > 0
                (cAliasUI)->(DbCloseArea())
            EndIf
            cAliasUI := GetNextAlias()
            MPSysOpenQuery(cQueryUi,cAliasUI)
            If !(cAliasUI)->(Eof())
                cHora := Time()
                cDataFat := ;
                    SubStr((cAliasUI)->C5_DTFAT,1,4) + "-" + ;
                    SubStr((cAliasUI)->C5_DTFAT,5,2) + "-" + ;
                    SubStr((cAliasUI)->C5_DTFAT,7,2) + "T" + ;
                    cHora + ".000Z"
                oPedVenda["dataFaturamento"] := cDataFat
            EndIf
        EndIf


        
        oPedVenda["UnidadeArmazenagem"] := {oUnidArm}   // array com o objeto de armazenagem (Pallet ou Gaiola)
        QRY_GAI->(DbCloseArea())
        If !Empty(AllTrim((QRY_SC5)->C5_TIPO1))
            oPedVenda["tipoPedidoVenda"] := AllTrim((QRY_SC5)->C5_TIPO1)
        EndIf
        // Campos: OrdemProducao -> omitido pois nao possui valor nesta integracao

        // pedidoVenda e um array no JSON da API: [{codigoPedidoVenda, ..., UnidadeArmazenagem}]
        oJsonRequest["pedidoVenda"] := {oPedVenda}

        // ----------------------------------------------------------------------
        // CAIXAS FISICAS (ZZ5 via ZZ5_ROMENV = cRomaneio)
        //
        // Secao "Caixas" do JSON: lista as caixas fisicas e seus itens.
        // Diferente das CaixasVenda (dentro do pallet), esta secao lista
        // todas as caixas do romaneio independente de pallet.
        //
        // Estrutura hierarquica (2 niveis):
        //   Nivel 1 (Caixa):  ZZ5_CODBOX -> oCaixa -> aCaixas
        //   Nivel 2 (Item):   ZZ5_PRODUT -> oItemCaixa -> itensCaixa[]
        //
        // GROUP BY ZZ5_CODBOX, ZZ5_PRODUT: consolida quantidade por caixa/produto
        // Sentinela "###": garante criacao do primeiro grupo mesmo com CODBOX vazio
        // Campos opcionais: somente adicionados se tiverem valor
        // ----------------------------------------------------------------------
        aCaixas      := {}
        cCaixaAtual  := "###"   // sentinela: forcara criacao do primeiro grupo (valor resolvido apos fallback)
        cCaixaRaw    := "###"   // sentinela bruta: compara ZZ5_CODBOX puro (antes do fallback)
        oCaixa       := Nil
        aItensCaixa  := {}

        cQueryCaixas := " SELECT ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT, "
        cQueryCaixas += "        SUM(ZZ5.ZZ5_QTDENC)             AS ZZ5_QTDENC, "
        cQueryCaixas += "        MAX(ISNULL(SB1.B1_CODCOR,''))  AS B1_CODCOR, "
        cQueryCaixas += "        MAX(ISNULL(SB1.B1_CODTAM,''))  AS B1_CODTAM, "
        cQueryCaixas += "        MAX(ISNULL(SZ7.Z7_QTDPCT,0))   AS Z7_QTDPCT, "
        cQueryCaixas += "        MAX(ISNULL(ZDU.ZDU_CAIXA,''))  AS ZDU_CAIXA, "
        cQueryCaixas += "        ISNULL(SB2.B2_LOCAL,'')        AS B2_LOCAL "
        cQueryCaixas += " FROM " + RetSQLName("ZZ5") + " ZZ5 (NOLOCK) "
        cQueryCaixas += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
        cQueryCaixas += "   ON SB1.B1_COD     = ZZ5.ZZ5_PRODUT "
        cQueryCaixas += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
        cQueryCaixas += "  AND SB1.D_E_L_E_T_ = ' ' "
        cQueryCaixas += " LEFT JOIN " + RetSQLName("SZ7") + " SZ7 (NOLOCK) "
        cQueryCaixas += "   ON SZ7.Z7_COD     = SB1.B1_CODMOD "
        cQueryCaixas += "  AND SZ7.D_E_L_E_T_ = ' ' "
        cQueryCaixas += " LEFT JOIN " + RetSQLName("ZDU") + " ZDU (NOLOCK) "
        cQueryCaixas += "   ON ZDU.ZDU_PRODUT = ZZ5.ZZ5_PRODUT "
        cQueryCaixas += "  AND ZDU.ZDU_ROMENV = ZZ5.ZZ5_ROMENV "
        cQueryCaixas += "  AND ZDU.D_E_L_E_T_ = ' ' "
        cQueryCaixas += " LEFT JOIN ( "
        cQueryCaixas += "      SELECT B2_COD, MIN(B2_LOCAL) AS B2_LOCAL "
        cQueryCaixas += "      FROM " + RetSQLName("SB2") + " (NOLOCK) "
        cQueryCaixas += "      WHERE B2_FILIAL = '" + xFilial("SB2") + "' "
        cQueryCaixas += "        AND D_E_L_E_T_ = ' ' "
        cQueryCaixas += "      GROUP BY B2_COD "
        cQueryCaixas += " ) SB2 "
        cQueryCaixas += "   ON SB2.B2_COD = ZZ5.ZZ5_PRODUT "
        cQueryCaixas += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
        cQueryCaixas += "   AND ZZ5.ZZ5_ROMENV = " + ValToSql(cRomaneio)
        cQueryCaixas += " GROUP BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT, SB2.B2_LOCAL "
        cQueryCaixas += " ORDER BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "

        If Select("QRY_CXS") > 0
            QRY_CXS->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryCaixas, "QRY_CXS")   // alias fixo "QRY_CXS"

        While (QRY_CXS)->(!Eof())

            // Quebra de grupo por caixa (ZZ5_CODBOX)
            // ATENCAO: comparacao usa cCaixaRaw (valor bruto do banco), NAO cCaixaAtual
            // (valor resolvido pelo fallback). Mesma razao do pallet: impede quebra
            // falsa quando ZZ5_CODBOX esta vazio em todas as linhas.
            If AllTrim((QRY_CXS)->ZZ5_CODBOX) <> cCaixaRaw

                // Fecha a caixa anterior (se existir)
                If oCaixa != Nil
                    oCaixa["itensCaixa"] := aItensCaixa
                    AAdd(aCaixas, oCaixa)
                EndIf

                // Registra o valor bruto para futuras comparacoes de quebra
                cCaixaRaw := AllTrim((QRY_CXS)->ZZ5_CODBOX)

                // Abre nova caixa
                // Prioridade: ZZ5_CODBOX -> ZDU_CAIXA -> placeholder sequencial
                cCaixaAtual := cCaixaRaw
                If Empty(cCaixaAtual)
                    cCaixaAtual := AllTrim((QRY_CXS)->ZDU_CAIXA)
                EndIf
                If Empty(cCaixaAtual)
                    nCaixaSeq++
                    cCaixaAtual := "CX" + StrZero(nCaixaSeq, 4)
                EndIf
                oCaixa      := JsonObject():New()
                oCaixa["codigoCaixa"] := cCaixaAtual
                aItensCaixa := {}

            EndIf

            // Item da caixa fisica - campos opcionais omitidos se vazios
            oItemCaixa := JsonObject():New()
            oItemCaixa["produto"]    := AllTrim((QRY_CXS)->ZZ5_PRODUT)
            oItemCaixa["quantidade"] := (QRY_CXS)->ZZ5_QTDENC
            If !Empty(AllTrim((QRY_CXS)->B1_CODCOR))
                oItemCaixa["cor"]    := AllTrim((QRY_CXS)->B1_CODCOR)
            EndIf
            If !Empty(AllTrim((QRY_CXS)->B1_CODTAM))
                oItemCaixa["tamanho"] := AllTrim((QRY_CXS)->B1_CODTAM)
            EndIf
            // grade omitido: nao utilizam grade nesta integracao
            If (QRY_CXS)->Z7_QTDPCT != 0
                oItemCaixa["quantidadePack"] := (QRY_CXS)->Z7_QTDPCT
            EndIf
            If !Empty(AllTrim((QRY_CXS)->B2_LOCAL))
                oItemCaixa["deposito"] := AllTrim((QRY_CXS)->B2_LOCAL)
            EndIf
            AAdd(aItensCaixa, oItemCaixa)

            (QRY_CXS)->(DbSkip())

        End

        // Fecha a ultima caixa fisica
        If oCaixa != Nil
            oCaixa["itensCaixa"] := aItensCaixa
            AAdd(aCaixas, oCaixa)
        EndIf

        QRY_CXS->(DbCloseArea())

        oJsonRequest["Caixas"] := aCaixas   // atribui o array de caixas ao JSON

        // ----------------------------------------------------------------------
        // ITENS DA NOTA FISCAL (SD2)
        //
        // REGRA: se UnidadeArmazenagem estiver preenchida (lTemArmazenagem = .T.),
        //   o array "itens" NAO e enviado. Enviar ambos causa inconsistencia no WMS.
        //   Os itens so sao enviados quando nao ha estrutura de armazenagem.
        //
        // Usa SD2 (Itens da NF de Saida) em vez de SC6 (Itens do Pedido de Venda).
        //   MOTIVO: SC6 contem os itens do pedido original, que pode ter mais itens
        //   do que os efetivamente faturados. SD2 contem exatamente os itens que
        //   constam na nota fiscal emitida, garantindo precisao nos dados enviados.
        //
        // Filtro por D2_DOC + D2_SERIE + D2_FILIAL: vincula os itens a esta NF especifica.
        // Campos opcionais: somente adicionados se tiverem valor.
        // ----------------------------------------------------------------------
        If !lTemArmazenagem

            // Monta os itens da NF somente quando nao ha UnidadeArmazenagem preenchida
            oJsonRequest["itens"] := {}

            cQueryC6 := " SELECT SD2.D2_ITEM, SD2.D2_COD, SD2.D2_QUANT, SD2.D2_TOTAL, "
            cQueryC6 += "        SD2.D2_PEDIDO, SD2.D2_TES, "
            cQueryC6 += "        SB1.B1_CODCOR, SB1.B1_CODTAM, "
            // B1_CODMOD removido: grade nao e utilizado nesta integracao
            cQueryC6 += "        SZ7.Z7_QTDPCT, "
            cQueryC6 += "        (SELECT TOP 1 B2_LOCAL FROM " + RetSQLName("SB2") + " (NOLOCK) WHERE B2_COD = SD2.D2_COD AND B2_FILIAL = SD2.D2_FILIAL AND D_E_L_E_T_ = ' ' ORDER BY B2_LOCAL) AS B2_LOCAL "
            cQueryC6 += " FROM " + RetSQLName("SD2") + " SD2 (NOLOCK) "
            cQueryC6 += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
            cQueryC6 += "   ON SB1.B1_COD     = SD2.D2_COD "
            cQueryC6 += "  AND SB1.B1_FILIAL  = SD2.D2_FILIAL "
            cQueryC6 += "  AND SB1.D_E_L_E_T_ = ' ' "
            cQueryC6 += " LEFT JOIN " + RetSQLName("SZ7") + " SZ7 (NOLOCK) "
            cQueryC6 += "   ON SZ7.Z7_COD     = SB1.B1_CODMOD "
            cQueryC6 += "  AND SZ7.D_E_L_E_T_ = ' ' "
            cQueryC6 += " WHERE SD2.D_E_L_E_T_ = ' ' "
            cQueryC6 += "   AND SD2.D2_DOC     = " + ValToSql(AllTrim((QRY_SC5)->C5_NOTA))
            cQueryC6 += "   AND SD2.D2_SERIE   = " + ValToSql(AllTrim((QRY_SC5)->C5_SERIE))
            cQueryC6 += "   AND SD2.D2_FILIAL  = '" + AllTrim((QRY_SC5)->C5_FILIAL) + "' "
            cQueryC6 += " ORDER BY SD2.D2_ITEM "

            If Select("QRY_SC6") > 0
                QRY_SC6->(DbCloseArea())
            EndIf
            // Alias dinamico para SD2 (pode variar a cada execucao do loop)
            QRY_SC6 := GETNEXTALIAS()
            MPSysOpenQuery(cQueryC6, QRY_SC6)

            While (QRY_SC6)->(!Eof())

                // Monta cada item da NF como objeto JSON
                // Campos opcionais: somente adicionados se tiverem valor
                oItem := JsonObject():New()
                oItem["codigoItemErp"]    := AllTrim((QRY_SC6)->D2_ITEM)
                oItem["produto"]          := AllTrim((QRY_SC6)->D2_COD)
                oItem["quantidade"]       := (QRY_SC6)->D2_QUANT
                oItem["valorTotal"]       := (QRY_SC6)->D2_TOTAL
                oItem["quantidadePedido"] := (QRY_SC6)->D2_QUANT
                oItem["item"]             := Val(AllTrim((QRY_SC6)->D2_ITEM))  // numero do item como numerico
                If !Empty(AllTrim((QRY_SC6)->B1_CODCOR))
                    oItem["cor"]          := AllTrim((QRY_SC6)->B1_CODCOR)
                EndIf
                If !Empty(AllTrim((QRY_SC6)->B1_CODTAM))
                    oItem["tamanho"]      := AllTrim((QRY_SC6)->B1_CODTAM)
                EndIf
                // grade omitido: nao utilizam grade nesta integracao
                // codigoPack omitido junto pois tambem depende de B1_CODMOD (grade)
                // Campos: custo, desconto, lote, validade, numeroSerie, lotes
                //         -> omitidos pois nao possuem valor nesta integracao
                If !Empty(AllTrim((QRY_SC6)->B2_LOCAL))
                    oItem["deposito"] := AllTrim((QRY_SC6)->B2_LOCAL)
                EndIf

                // AAdd direto no array oJsonRequest["itens"] funciona aqui pois
                // o array foi inicializado como {} vazio e o JsonObject retorna referencia correta
                AAdd(oJsonRequest["itens"], oItem)

                (QRY_SC6)->(DbSkip())

            End

            If Select("QRY_SC6") > 0
                QRY_SC6->(DbCloseArea())
            EndIf

        Else
            // UnidadeArmazenagem preenchida: campo "itens" omitido do JSON
            // conforme recomendacao da API para evitar inconsistencia no processamento
            MsgInfo("UnidadeArmazenagem preenchida - campo 'itens' omitido do JSON." + Chr(13)+Chr(10) + ;
                "Nota: " + AllTrim((QRY_SC5)->C5_NOTA), "Regra API - itens x armazenagem")
        EndIf

        // ----------------------------------------------------------------------
        // DIAGNOSTICO VISUAL: exibe o JSON montado antes de enviar
        // Permite verificar a estrutura completa do payload da API
        // ----------------------------------------------------------------------
        MsgInfo(oJsonRequest:ToJson(), "JSON - Nota: " + AllTrim((QRY_SC5)->C5_NOTA))

        // ----------------------------------------------------------------------
        // DIAGNOSTICO VISUAL: monta e exibe o cURL equivalente
        // Util para testar o endpoint manualmente fora do Protheus
        // ----------------------------------------------------------------------
        cJsonBody := "[" + oJsonRequest:ToJson() + "]"   // API espera array de objetos: [{...}]
        cAuthHdr  := ""
        // Extrai o header de Authorization do array de headers para exibir no cURL
        For nH := 1 To Len(aHeader)
            If "Authorization" $ aHeader[nH]
                cAuthHdr := aHeader[nH]
            EndIf
        Next nH

        cCurl  := 'curl -X POST "https://stg.api.pdahub.com.br/api/Integration/Recebimento"' + Chr(13)+Chr(10)
        cCurl  += '  -H "Content-Type: application/json"' + Chr(13)+Chr(10)
        If !Empty(cAuthHdr)
            cCurl += '  -H "' + cAuthHdr + '"' + Chr(13)+Chr(10)
        EndIf
        cCurl  += '  -d ' + Chr(39) + cJsonBody + Chr(39)

        MsgInfo(cCurl, "cURL - Nota: " + AllTrim((QRY_SC5)->C5_NOTA))

        // ----------------------------------------------------------------------
        // ENVIO PARA A API REST
        //
        // oRest:SetPath(cPath) e chamado DENTRO do loop (antes de cada Post).
        // MOTIVO: FwRest requer SetPath antes de cada chamada Post/Get.
        //   Se SetPath for chamado apenas uma vez fora do loop, as chamadas
        //   subsequentes falham silenciosamente sem enviar para a API.
        //
        // oRest:SetPostParams: define o corpo do POST (JSON como string)
        // oRest:Post(aHeader): executa o POST com os headers (Authorization + Content-Type)
        // ----------------------------------------------------------------------
        oRest:SetPath(cPath)            // DEVE ser chamado antes de cada Post
        oRest:SetPostParams(cJsonBody)  // corpo: array JSON "[{...}]"
        oRest:Post(aHeader)             // executa o POST

        // Obtem resultado e status HTTP da ultima chamada
        cJsonRet := oRest:GetResult()
        oJsonRet := JsonObject():New()
        oJsonRet:FromJson(oRest:GetResult())

        SC5->(DbSetOrder(1))
        SC5->(DBGoTo((QRY_SC5)->REC))

        If Empty(cJsonRet) .OR. oJsonRet["badRequest"] == .T.
            nIgnorados++
            // oLogger:Gravar(PDALogEntry():New("SC5", "ERRO", AllTrim((QRY_SC5)->C5_NUM), ;
            //     "Erro ao integrar nota: " + AllTrim((QRY_SC5)->C5_NOTA)))

            If AllTrim(SC5->C5_NUM) == AllTrim((QRY_SC5)->C5_NUM)
                // SC5->(Reclock("SC5", .F.))
                // SC5->C5_INTWMS := "E"
                // SC5->(MsUnLock())
            EndIf
        Else
            nProcessados++
            // oLogger:Gravar(PDALogEntry():New("SC5", "INCLUSAO", AllTrim((QRY_SC5)->C5_NUM), ;
            //     "Nota integrada com sucesso: " + AllTrim((QRY_SC5)->C5_NOTA)))

            If AllTrim(SC5->C5_NUM) == AllTrim((QRY_SC5)->C5_NUM)
                // SC5->(Reclock("SC5", .F.))
                // SC5->C5_INTWMS := "S"
                // SC5->(MsUnLock())
            EndIf
        EndIf

        (QRY_SC5)->(DbSkip())

    End

    If Select("QRY_SC5") > 0
        QRY_SC5->(DbCloseArea())
    EndIf

    // // Log final com totalizadores do processamento (vendas)
    // oLogger:Gravar(PDALogEntry():New("SC5", "INFO", "", ;
    //     "Total: "   + cValToChar(nTotal)       + ;
    //     " | OK: "   + cValToChar(nProcessados) + ;
    //     " | Erro: " + cValToChar(nIgnorados)))

    // ==========================================================================
    // IMPORTADOS: Notas Fiscais de Entrada (SF1/SD1)
    //
    // Identifica NFs de importacao com CFOP 3101/3102 (excluindo 3949)
    // tipoEntrada = "IMP"
    // pedidoVenda = [] / Caixas = [] (caixas enviadas via DistribuicaoV2)
    //
    // FLUXO:
    //   1. Identifica NF importacao (SF1 com SD1.D1_CF IN ('3101','3102'))
    //   2. Monta e envia JSON Recebimento (sem caixas, sem pedidoVenda)
    //   3. Se OK: monta e envia JSON Distribuicao (/api/Integration/DistribuicaoV2)
    //   4. Atualiza SF1.F1_INTWMS (S=sucesso / E=erro)
    //
    // REGRAS:
    //   - cor/tamanho sem zeros a esquerda (padronizacao entre endpoints)
    //   - itens respeitam a estrutura fiscal da NF (sem split/agrupamento)
    //   - ZCQ sem filtro por filial (ZCQ_FILIAL sempre vazio nesta base)
    //   - Consistencia total entre Recebimento e Distribuicao
    //   - CFOP 3949 (transporte) NAO integra
    // ==========================================================================



    // ----------------------------------------------------------------------
    // QUERY PRINCIPAL: NFs de importacao (SF1)
    // Usa EXISTS em SD1 para identificar notas com CFOP de importacao
    // Nao faz JOIN direto para evitar duplicatas na query de cabecalho
    // ----------------------------------------------------------------------
    cQueryImp := " SELECT SF1.F1_FILIAL, SF1.F1_DOC, SF1.F1_SERIE, SF1.F1_EMISSAO, "
    cQueryImp += "        SF1.F1_FORNECE, SF1.F1_LOJA, SF1.F1_CHVNFE, "
    cQueryImp += "        SF1.F1_DTENT, SF1.R_E_C_N_O_ AS REC "
    cQueryImp += " FROM " + RetSQLName("SF1") + " SF1 (NOLOCK) "
    cQueryImp += " WHERE SF1.D_E_L_E_T_ = ' ' "
    cQueryImp += "   AND SF1.F1_FILIAL  = '" + xFilial("SF1") + "' "
    cQueryImp += "   AND SF1.F1_EMISSAO > '20260101' "
    //cQueryImp += "   AND SF1.F1_INTWMS  = ' ' "               // somente nao integradas
    cQueryImp += "   AND EXISTS ( "
    cQueryImp += "     SELECT 1 FROM " + RetSQLName("SD1") + " SD1 (NOLOCK) "
    cQueryImp += "     WHERE SD1.D1_DOC    = SF1.F1_DOC "
    cQueryImp += "       AND SD1.D1_SERIE  = SF1.F1_SERIE "
    cQueryImp += "       AND SD1.D1_FILIAL = SF1.F1_FILIAL "
    cQueryImp += "       AND SD1.D_E_L_E_T_ = ' ' "
    cQueryImp += "       AND SD1.D1_CF IN ('3101','3102') "
    cQueryImp += "       AND SD1.D1_CF <> '3949' "
    cQueryImp += "   ) "
    cQueryImp += " ORDER BY SF1.F1_DOC "

    If Select("QRY_IMP") > 0
        QRY_IMP->(DbCloseArea())
    EndIf

    QRY_IMP := GETNEXTALIAS()
    MPSysOpenQuery(cQueryImp, QRY_IMP)

    // ==========================================================================
    // LOOP IMPORTADOS: processa cada NF de importacao
    // ==========================================================================
    While (QRY_IMP)->(!Eof())

        nTotalImp++
        cRomaneioImp := ""
        cPedidoImp   := ""

        // ----------------------------------------------------------------------
        // Converte datas para formato UTC (API exige "YYYY-MM-DDTHH:MM:SS.000Z")
        // ----------------------------------------------------------------------
        cEmissaoImpUTC := FWTimeStamp(3, STOD((QRY_IMP)->F1_EMISSAO), "00:00:00") + ".000Z"
        cDtEntImpUTC   := ""
        If !Empty(AllTrim((QRY_IMP)->F1_DTENT))
            cDtEntImpUTC := FWTimeStamp(3, STOD((QRY_IMP)->F1_DTENT), "00:00:00") + ".000Z"
        EndIf

        // ----------------------------------------------------------------------
        // BUSCA DO ROMANEIO via ZCQ
        // IMPORTANTE: ZCQ_FILIAL e SEMPRE VAZIO nesta base - nao filtra por filial
        // ----------------------------------------------------------------------
        cQueryImpRom := " SELECT TOP 1 ZCQ_NUMROM "
        cQueryImpRom += " FROM " + RetSQLName("ZCQ") + " ZCQ (NOLOCK) "
        cQueryImpRom += " WHERE ZCQ.D_E_L_E_T_ = ' ' "
        cQueryImpRom += "   AND ZCQ.ZCQ_DOC   = " + ValToSql(AllTrim((QRY_IMP)->F1_DOC))
        cQueryImpRom += "   AND ZCQ.ZCQ_SERIE = " + ValToSql(AllTrim((QRY_IMP)->F1_SERIE))
        cQueryImpRom += "   AND LTRIM(RTRIM(ZCQ.ZCQ_NUMROM)) <> '' "

        If Select("QRY_IRM") > 0
            QRY_IRM->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryImpRom, "QRY_IRM")

        If !(QRY_IRM)->(Eof())
            cRomaneioImp := AllTrim((QRY_IRM)->ZCQ_NUMROM)
        EndIf
        QRY_IRM->(DbCloseArea())

        // Se nao encontrou romaneio, pula para proxima NF
        If Empty(cRomaneioImp)
            ConOut("[BUD1498 IMP] Romaneio nao encontrado para NF " + AllTrim((QRY_IMP)->F1_DOC))
            nIgnoradosImp++
            (QRY_IMP)->(DbSkip())
            Loop
        EndIf

        // ----------------------------------------------------------------------
        // BUSCA ITENS DA NF (SD1)
        //
        // REGRA: respeita a estrutura fiscal da NF - SEM split/agrupamento
        // Cada D1_ITEM e um item unico na NF. Nao faz GROUP BY.
        // CFOP 3101/3102 apenas, exclui 3949 (transporte)
        //
        // cor/tamanho: obtidos via SB1 com ISNULL para evitar erro de NULL
        // Normalizacao (remove zeros a esquerda) feita no AdvPL via RemoveLeadZeros()
        // ----------------------------------------------------------------------
        cQueryImpItens := " SELECT SD1.D1_ITEM, SD1.D1_COD, SD1.D1_QUANT, SD1.D1_TOTAL, "
        cQueryImpItens += "        SD1.D1_PEDIDO, "
        cQueryImpItens += "        ISNULL(SB1.B1_CODCOR,  '') AS B1_CODCOR, "
        cQueryImpItens += "        ISNULL(SB1.B1_CODTAM,  '') AS B1_CODTAM, "
        cQueryImpItens += "        ISNULL(SB1.B1_CODMOD,  '') AS B1_CODMOD "
        cQueryImpItens += " FROM " + RetSQLName("SD1") + " SD1 (NOLOCK) "
        cQueryImpItens += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
        cQueryImpItens += "   ON SB1.B1_COD     = SD1.D1_COD "
        cQueryImpItens += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
        cQueryImpItens += "  AND SB1.D_E_L_E_T_ = ' ' "
        cQueryImpItens += " WHERE SD1.D_E_L_E_T_ = ' ' "
        cQueryImpItens += "   AND SD1.D1_DOC    = " + ValToSql(AllTrim((QRY_IMP)->F1_DOC))
        cQueryImpItens += "   AND SD1.D1_SERIE  = " + ValToSql(AllTrim((QRY_IMP)->F1_SERIE))
        cQueryImpItens += "   AND SD1.D1_FILIAL = '" + AllTrim((QRY_IMP)->F1_FILIAL) + "' "
        cQueryImpItens += "   AND SD1.D1_CF IN ('3101','3102') "
        cQueryImpItens += "   AND SD1.D1_CF <> '3949' "
        cQueryImpItens += " ORDER BY SD1.D1_ITEM "

        If Select("QRY_IIT") > 0
            QRY_IIT->(DbCloseArea())
        EndIf
        MPSysOpenQuery(cQueryImpItens, "QRY_IIT")

        // ==================================================================
        // MONTA JSON RECEBIMENTO - IMPORTADOS
        // ==================================================================
        oJsonReqImp := JsonObject():New()
        oJsonReqImp["itens"] := {}

        While (QRY_IIT)->(!Eof())

            // Captura pedido do primeiro item (D1_PEDIDO -> pedido de compra)
            If Empty(cPedidoImp)
                cPedidoImp := AllTrim((QRY_IIT)->D1_PEDIDO)
            EndIf

            // Normaliza cor/tamanho: remove zeros a esquerda
            // Garante padronizacao identica entre Recebimento e Distribuicao
            cCorNorm := RemoveLeadZeros(AllTrim((QRY_IIT)->B1_CODCOR))
            cTamNorm := RemoveLeadZeros(AllTrim((QRY_IIT)->B1_CODTAM))

            oItemImp := JsonObject():New()
            oItemImp["codigoItemErp"]    := AllTrim((QRY_IIT)->D1_ITEM)
            oItemImp["produto"]          := AllTrim((QRY_IIT)->D1_COD)
            oItemImp["quantidade"]       := (QRY_IIT)->D1_QUANT
            oItemImp["quantidadePedido"] := (QRY_IIT)->D1_QUANT
            oItemImp["valorTotal"]       := (QRY_IIT)->D1_TOTAL
            oItemImp["item"]             := Val(AllTrim((QRY_IIT)->D1_ITEM))

            // Campos opcionais: somente adicionados se tiverem valor
            If !Empty(cCorNorm)
                oItemImp["cor"] := cCorNorm
            EndIf
            If !Empty(cTamNorm)
                oItemImp["tamanho"] := cTamNorm
            EndIf

            oItemImp["lotes"] := {}

            AAdd(oJsonReqImp["itens"], oItemImp)

            (QRY_IIT)->(DbSkip())

        End

        If Select("QRY_IIT") > 0
            QRY_IIT->(DbCloseArea())
        EndIf

        // Se nao encontrou itens, pula para proxima NF
        If Len(oJsonReqImp["itens"]) == 0
            ConOut("[BUD1498 IMP] Nenhum item encontrado para NF " + AllTrim((QRY_IMP)->F1_DOC))
            nIgnoradosImp++
            (QRY_IMP)->(DbSkip())
            Loop
        EndIf

        // ----------------------------------------------------------------------
        // CABECALHO DO RECEBIMENTO - IMPORTADOS
        //
        // codigoPedido: pedido de compra (D1_PEDIDO), fallback F1_DOC
        // tipoEntrada: "IMP" (Importacao)
        // codigoFornecedorErp: SF1.F1_FORNECE
        // sequenciaErp: SF1.F1_LOJA
        // pedidoVenda: [] (vazio - importados nao tem pedido de venda)
        // Caixas: [] (vazio - caixas enviadas via DistribuicaoV2)
        // Campo "xml" OMITIDO intencionalmente (API nao aceita null)
        // ----------------------------------------------------------------------
        If Empty(cPedidoImp)
            cPedidoImp := AllTrim((QRY_IMP)->F1_DOC)
        EndIf

        oJsonReqImp["codigoPedido"]        := cPedidoImp
        oJsonReqImp["referenciaPedido"]    := cPedidoImp
        oJsonReqImp["notaFiscal"]          := AllTrim((QRY_IMP)->F1_DOC)
        oJsonReqImp["serie"]               := AllTrim((QRY_IMP)->F1_SERIE)
        oJsonReqImp["emissao"]             := cEmissaoImpUTC
        oJsonReqImp["codigoFornecedorErp"] := AllTrim((QRY_IMP)->F1_FORNECE)
        oJsonReqImp["sequenciaErp"]        := AllTrim((QRY_IMP)->F1_LOJA)
        oJsonReqImp["tipoEntrada"]         := "IMP"
        oJsonReqImp["codigoFilial"]        := AllTrim((QRY_IMP)->F1_FILIAL)
        oJsonReqImp["romaneio"]            := cRomaneioImp

        // Campos opcionais do cabecalho
        If !Empty(AllTrim((QRY_IMP)->F1_CHVNFE))
            oJsonReqImp["chaveNfe"] := AllTrim((QRY_IMP)->F1_CHVNFE)
        EndIf
        If !Empty(cDtEntImpUTC)
            oJsonReqImp["dataEntegra"] := cDtEntImpUTC
        EndIf

        // pedidoVenda e Caixas VAZIOS para importados
        // Caixas sao enviadas separadamente via /api/Integration/DistribuicaoV2
        oJsonReqImp["pedidoVenda"] := {}
        oJsonReqImp["Caixas"]      := {}

        // ==================================================================
        // ENVIO RECEBIMENTO - IMPORTADOS
        // ==================================================================
        cJsonBodyImp := "[" + oJsonReqImp:ToJson() + "]"

        ConOut("[BUD1498 IMP] JSON Recebimento - NF: " + AllTrim((QRY_IMP)->F1_DOC) + " - " + cJsonBodyImp)

        oRest:SetPath(cPath)
        oRest:SetPostParams(cJsonBodyImp)
        oRest:Post(aHeader)

        cJsonRetImp := oRest:GetResult()
        oJsonRetImp := JsonObject():New()
        If !Empty(cJsonRetImp)
            cJsonRetImp := EncodeUTF8(cJsonRetImp, "cp1252")
            oJsonRetImp:FromJson(cJsonRetImp)
        EndIf

        If Empty(cJsonRetImp) .OR. oJsonRetImp["badRequest"] == .T.

            // ERRO no Recebimento - nao envia Distribuicao
            nIgnoradosImp++
            ConOut("[BUD1498 IMP] ERRO Recebimento NF: " + AllTrim((QRY_IMP)->F1_DOC))

            SF1->(DbSetOrder(1))
            SF1->(DBGoTo((QRY_IMP)->REC))
            If AllTrim(SF1->F1_DOC) == AllTrim((QRY_IMP)->F1_DOC)
                SF1->(Reclock("SF1", .F.))
                SF1->F1_INTWMS := "E"
                SF1->(MsUnLock())
            EndIf

        Else

            ConOut("[BUD1498 IMP] Recebimento OK NF: " + AllTrim((QRY_IMP)->F1_DOC))

            // ==============================================================
            // ENVIO DISTRIBUICAO (DistribuicaoV2)
            // Somente apos Recebimento com sucesso
            //
            // Busca dados de caixas/produtos via ZZ5 pelo romaneio
            // cor/tamanho normalizados com mesma regra do Recebimento
            // ==============================================================
            aItensDist   := {}
            nCaixaSeqImp := 0

            cQueryImpDist := " SELECT ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT, "
            cQueryImpDist += "        SUM(ZZ5.ZZ5_QTDENC) AS ZZ5_QTDENC, "
            cQueryImpDist += "        MAX(ISNULL(SB1.B1_CODCOR,  ''))  AS B1_CODCOR, "
            cQueryImpDist += "        MAX(ISNULL(SB1.B1_CODTAM,  ''))  AS B1_CODTAM, "
            cQueryImpDist += "        MAX(ISNULL(SB1.B1_CODMOD,  ''))  AS B1_CODMOD, "
            cQueryImpDist += "        MAX(ISNULL(SB1.B1_GRIFE,   ''))  AS B1_GRIFE, "
            cQueryImpDist += "        MAX(ISNULL(SB1.B1_COLECAO, ''))  AS B1_COLECAO, "
            cQueryImpDist += "        MAX(ISNULL(ZDU.ZDU_CAIXA,  ''))  AS ZDU_CAIXA "
            cQueryImpDist += " FROM " + RetSQLName("ZZ5") + " ZZ5 (NOLOCK) "
            cQueryImpDist += " LEFT JOIN " + RetSQLName("SB1") + " SB1 (NOLOCK) "
            cQueryImpDist += "   ON SB1.B1_COD     = ZZ5.ZZ5_PRODUT "
            cQueryImpDist += "  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' "
            cQueryImpDist += "  AND SB1.D_E_L_E_T_ = ' ' "
            cQueryImpDist += " LEFT JOIN " + RetSQLName("ZDU") + " ZDU (NOLOCK) "
            cQueryImpDist += "   ON ZDU.ZDU_PRODUT  = ZZ5.ZZ5_PRODUT "
            cQueryImpDist += "  AND ZDU.ZDU_ROMENV  = ZZ5.ZZ5_ROMENV "
            cQueryImpDist += "  AND ZDU.D_E_L_E_T_  = ' ' "
            cQueryImpDist += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
            cQueryImpDist += "   AND ZZ5.ZZ5_ROMENV = " + ValToSql(cRomaneioImp)
            cQueryImpDist += " GROUP BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "
            cQueryImpDist += " ORDER BY ZZ5.ZZ5_CODBOX, ZZ5.ZZ5_PRODUT "

            If Select("QRY_IDT") > 0
                QRY_IDT->(DbCloseArea())
            EndIf
            MPSysOpenQuery(cQueryImpDist, "QRY_IDT")

            While (QRY_IDT)->(!Eof())

                nCaixaSeqImp++
                oItemDist := JsonObject():New()

                oItemDist["pedido"]       := cPedidoImp
                oItemDist["codigoFilial"] := AllTrim((QRY_IMP)->F1_FILIAL)
                oItemDist["codigoCaixa"]  := nCaixaSeqImp

                // Caixa: prioridade ZZ5_CODBOX -> ZDU_CAIXA -> placeholder
                cCaixaImp := AllTrim((QRY_IDT)->ZZ5_CODBOX)
                If Empty(cCaixaImp)
                    cCaixaImp := AllTrim((QRY_IDT)->ZDU_CAIXA)
                EndIf
                If Empty(cCaixaImp)
                    cCaixaImp := "CX" + StrZero(nCaixaSeqImp, 4)
                EndIf
                oItemDist["caixa"]     := cCaixaImp
                oItemDist["caixaNome"] := cCaixaImp

                oItemDist["codigoDistribuicao"] := cRomaneioImp
                oItemDist["produto"]            := AllTrim((QRY_IDT)->ZZ5_PRODUT)

                // Normaliza cor/tamanho (mesma regra do Recebimento - sem zeros a esquerda)
                cCorNorm := RemoveLeadZeros(AllTrim((QRY_IDT)->B1_CODCOR))
                cTamNorm := RemoveLeadZeros(AllTrim((QRY_IDT)->B1_CODTAM))

                oItemDist["cor"]        := cCorNorm
                oItemDist["tamanho"]    := cTamNorm
                oItemDist["grade"]      := IIf(Empty(AllTrim((QRY_IDT)->B1_CODMOD)), "", AllTrim((QRY_IDT)->B1_CODMOD))
                oItemDist["quantidade"] := (QRY_IDT)->ZZ5_QTDENC
                oItemDist["grupo"]      := ""
                oItemDist["grife"]      := IIf(Empty(AllTrim((QRY_IDT)->B1_GRIFE)),   "", AllTrim((QRY_IDT)->B1_GRIFE))
                oItemDist["colecao"]    := IIf(Empty(AllTrim((QRY_IDT)->B1_COLECAO)), "", AllTrim((QRY_IDT)->B1_COLECAO))
                oItemDist["cabide"]     := ""
                oItemDist["codigoRota"]      := ""
                oItemDist["descricaoFilial"] := FWFilialName()

                AAdd(aItensDist, oItemDist)

                (QRY_IDT)->(DbSkip())

            End

            If Select("QRY_IDT") > 0
                QRY_IDT->(DbCloseArea())
            EndIf

            // Envia Distribuicao se houver itens
            If Len(aItensDist) > 0

                // Serializa array de JsonObjects manualmente
                cJsonBodyDist := "["
                For nI := 1 To Len(aItensDist)
                    If nI > 1
                        cJsonBodyDist += ","
                    EndIf
                    cJsonBodyDist += aItensDist[nI]:ToJson()
                Next nI
                cJsonBodyDist += "]"

                ConOut("[BUD1498 IMP] JSON Distribuicao - NF: " + AllTrim((QRY_IMP)->F1_DOC) + " - " + cJsonBodyDist)

                oRest:SetPath(cPathDist)
                oRest:SetPostParams(cJsonBodyDist)
                oRest:Post(aHeader)

                cJsonRetDist := oRest:GetResult()
                oJsonRetDist := JsonObject():New()
                If !Empty(cJsonRetDist)
                    cJsonRetDist := EncodeUTF8(cJsonRetDist, "cp1252")
                    oJsonRetDist:FromJson(cJsonRetDist)
                EndIf

                If Empty(cJsonRetDist) .OR. oJsonRetDist["badRequest"] == .T.
                    // Recebimento OK mas Distribuicao falhou
                    ConOut("[BUD1498 IMP] ERRO Distribuicao NF: " + AllTrim((QRY_IMP)->F1_DOC))
                    nIgnoradosImp++

                    SF1->(DbSetOrder(1))
                    SF1->(DBGoTo((QRY_IMP)->REC))
                    If AllTrim(SF1->F1_DOC) == AllTrim((QRY_IMP)->F1_DOC)
                        SF1->(Reclock("SF1", .F.))
                        SF1->F1_INTWMS := "E"
                        SF1->(MsUnLock())
                    EndIf
                Else
                    // Ambos endpoints OK
                    ConOut("[BUD1498 IMP] Distribuicao OK NF: " + AllTrim((QRY_IMP)->F1_DOC))
                    nProcessImp++

                    SF1->(DbSetOrder(1))
                    SF1->(DBGoTo((QRY_IMP)->REC))
                    If AllTrim(SF1->F1_DOC) == AllTrim((QRY_IMP)->F1_DOC)
                        SF1->(Reclock("SF1", .F.))
                        SF1->F1_INTWMS := "S"
                        SF1->(MsUnLock())
                    EndIf
                EndIf

            Else
                // Recebimento OK mas sem itens para distribuicao
                ConOut("[BUD1498 IMP] Sem itens distribuicao para NF: " + AllTrim((QRY_IMP)->F1_DOC))
                nProcessImp++

                SF1->(DbSetOrder(1))
                SF1->(DBGoTo((QRY_IMP)->REC))
                If AllTrim(SF1->F1_DOC) == AllTrim((QRY_IMP)->F1_DOC)
                    SF1->(Reclock("SF1", .F.))
                    SF1->F1_INTWMS := "S"
                    SF1->(MsUnLock())
                EndIf
            EndIf

        EndIf

        (QRY_IMP)->(DbSkip())

    End

    If Select("QRY_IMP") > 0
        QRY_IMP->(DbCloseArea())
    EndIf

    // Log final importados
    ConOut("[BUD1498 IMP] Total: " + cValToChar(nTotalImp) + ;
        " | OK: "   + cValToChar(nProcessImp) + ;
        " | Erro: " + cValToChar(nIgnoradosImp))

    // Dialogo de conclusao com resumo do processamento

    RpcCLearEnv()


Return .T.

/*
/==================================================================================\
| Nome     : RemoveLeadZeros                                                       |
|==================================================================================|
| Descricao: Remove zeros a esquerda de uma string                                 |
|            Preserva o conteudo valido e nunca retorna vazio para "0"              |
|            Exemplo: "00004464" -> "4464" / "00000027" -> "27" / "0" -> "0"       |
\==================================================================================/
*/

Static Function RemoveLeadZeros(cStr)

    Local cResult := AllTrim(cStr)

    While Len(cResult) > 1 .And. Left(cResult, 1) == "0"
        cResult := SubStr(cResult, 2)
    EndDo

Return cResult
