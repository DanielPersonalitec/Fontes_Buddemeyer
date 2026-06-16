#INCLUDE 'TOTVS.CH'


/*
+============================================================================+
| Nome            : VRN0179                                                |
|============================================================================|
| Descricao       : Ajusta impostos do Pedido de acordo com o XML Importado  |
|============================================================================|
| Autor           : DANIEL VICTOR DA ROSA                                    |
|============================================================================|
| Empresa         : PERSONALITEC                                             |
|============================================================================|
| Data de Criacao : 12/06/2025                                               |
+============================================================================+
*/
User Function VRN0179(oXML,cPed55,cDoc55,cSerie55,cCodCli55,cCodLoj55,cFil55)

    Local nY52  := 0
    Local oXML2 := oXML
    Local cPrdXML := ""
    Local cProd   := ""
    Local nValt1  := 0
    Local nAlic1  := 0
    Local nLimLin := 1
    Local nLinhaQTD := 0
    Local cCfo1   := ""
    Local cItem   := ""
    Local nValt2  := 0
    Local nAwi    := 0
    Local nAlic2  := 0
    Local cCfo2   := ""
    Local cDatEmiss := DTOS(DATE())
    Local cQuerySD2 := "" //"SD2"
    Local cQryQtL   := "" //"SD2"
    Local cQuerySFT := ""
    Local cQuerySF3 := ""
    Private l1Linha := .F.

    cQryQtL := " SELECT COUNT(D2_DOC) QTDLIN FROM "+RETSQLNAME('SD2')
    cQryQtL += " WHERE D_E_L_E_T_ = '' "
    cQryQtL += " AND D2_DOC       = " + valtosql(cDoc55)
    cQryQtL += " AND D2_SERIE     = " + valtosql(cSerie55)
    cQryQtL += " AND D2_PEDIDO    = " + valtosql(cPed55)
    cQryQtL += " AND D2_FILIAL    = " + valtosql(cFil55)
    cQryQtL += " AND D2_CLIENTE   = " + valtosql(cCodCli55)
    cQryQtL += " AND D2_LOJA      = " + valtosql(cCodLoj55)

    cAliasLi := GetnextAlias()

    MPsYSOpenQuery(cQryQtL,cAliasLi)
    IF VALTYPE(OXML2:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
        nLinhaQTD := 1
        l1Linha := .T.
    ELSE
        nLinhaQTD := Len(OXML2:_NFEPROC:_NFE:_INFNFE:_DET)
    ENDIF
    nLimLin := 1

    IF nLinhaQTD == (cAliasLi)->QTDLIN

        FOR nY52 := 1 TO nLinhaQTD

            IF l1Linha
                cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
            ELSE
                cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
            ENDIF
            cProd   :=  fGetPrd(cPrdXML)

            //////////////////////////////////////////////////////////////////////////////////////
            /////                               SD2  INICIO                                  /////
            //////////////////////////////////////////////////////////////////////////////////////

            cAliasSD2 := GetnextAlias()

            cQuerySD2 := "SELECT COUNT(D2_COD) QTDLINPED FROM "+ RetSQLName('SD2')+ " (nolock) "
            cQuerySD2 += " WHERE D_E_L_E_T_ = ' ' "
            cQuerySD2 += " AND D2_PEDIDO = '" + cPed55 + "' "
            cQuerySD2 += " AND D2_FILIAL = '" + cFil55 + "' "
            cQuerySD2 += " AND D2_DOC = '" + cDoc55 + "' "
            cQuerySD2 += " AND D2_SERIE = '" + cSerie55 + "' "
            cQuerySD2 += " AND D2_CLIENTE = '" + cCodCli55 + "' "
            cQuerySD2 += " AND D2_LOJA = '" + cCodLoj55 + "' "
            cQuerySD2 += " AND D2_COD = '" + cProd + "' "

            PLSQuery(cQuerySD2, cAliasSD2)

            IF (cAliasSD2)->QTDLINPED == nLimLin
                SD2->(DBSetOrder(3))
                IF SD2->(DBSEEK(xFilial('SD2')+cDoc55+cSerie55+cCodCli55+cCodLoj55+cProd))
                    // XML COM APENAS 1 ITEM.
                    IF l1Linha
                        RECLOCK('SD2',.F.)
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                            SD2->D2_VALIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                            SD2->D2_VALIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                        ENDIF
                        //VALOR DO ICMS(A BASE É O VALOR TOTAL DO PRODUTO, NÃO PRECISA DE CORREÇÃO)
                        IF SD2->D2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            SD2->D2_VALICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SD2->D2_BASEICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            SD2->D2_BASEICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        ENDIF
                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                        ENDIF
                        SD2->(MSUNLOCK())
                    ELSE

                        RECLOCK('SD2',.F.)
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                            SD2->D2_VALIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                            SD2->D2_VALIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                        ENDIF
                        //VALOR DO ICMS(A BASE É O VALOR TOTAL DO PRODUTO, NÃO PRECISA DE CORREÇÃO)
                        IF SD2->D2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            SD2->D2_VALICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SD2->D2_BASEICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            SD2->D2_BASEICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        ENDIF
                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                        SD2->(MSUNLOCK())
                    ENDIF
                ENDIF
            ENDIF

            //////////////////////////////////////////////////////////////////////////////////////
            /////                               SD2 FIM                                      /////
            //////////////////////////////////////////////////////////////////////////////////////
            //////////////////////////////////////////////////////////////////////////////////////
            /////                               SFT INICIO                                   /////
            //////////////////////////////////////////////////////////////////////////////////////

            cAliasSFT := GetnextAlias()

            cQuerySFT := "SELECT COUNT(FT_PRODUTO) AS QTFTLIN FROM "+ RetSQLName('SFT')+ " (nolock) "
            cQuerySFT += " WHERE D_E_L_E_T_ = ' ' "
            cQuerySFT += " AND FT_FILIAL = '" + cFil55 + "' "
            cQuerySFT += " AND FT_NFISCAL = '" + cDoc55 + "' "
            cQuerySFT += " AND FT_SERIE = '" + cSerie55 + "' "
            cQuerySFT += " AND FT_CLIEFOR = '" + cCodCli55 + "' "
            cQuerySFT += " AND FT_LOJA = '" + cCodLoj55 + "' "
            cQuerySFT += " AND FT_PRODUTO = '" + cProd + "' "

            PLSQuery(cQuerySFT, cAliasSFT)

            IF (cAliasSFT)->QTFTLIN == nLimLin

                cItem := cForIte(nY52)

                SFT->(DBSetOrder(1)) //FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
                IF SFT->(DBSEEK(xFilial('SFT')+"S"+cSerie55+cDoc55+cCodCli55+cCodLoj55+cItem+cProd)) //FT_TIPOMOV = "S" SAIDA
                    IF l1Linha
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT) //vBC
                            SFT->FT_BASEPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_BASECOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)  //vICMS
                            SFT->FT_BASECOF :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)  //vBC
                            SFT->FT_VALPIS  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        ENDIF
                        IF SFT->FT_VALCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)  //vICMS
                            SFT->FT_VALCOF  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) //vBC
                            SFT->FT_VALICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT
                        ENDIF
                        SFT->(MSUNLOCK())
                    ELSE
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT) //vBC
                            SFT->FT_BASEPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_BASECOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)  //vICMS
                            SFT->FT_BASECOF :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)  //vBC
                            SFT->FT_VALPIS  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        ENDIF
                        IF SFT->FT_VALCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)  //vICMS
                            SFT->FT_VALCOF  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) //vBC
                            SFT->FT_VALICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                    ENDIF
                ENDIF
            ENDIF

            //////////////////////////////////////////////////////////////////////////////////////
            /////                               CD2  INICIO                                  /////
            //////////////////////////////////////////////////////////////////////////////////////

            //CD2_FILIAL + CD2_TPMOV + CD2_SERIE + CD2_DOC + CD2_CODFOR + CD2_LOJFOR + CD2_ITEM + CD2_CODPRO + CD2_IMP(CF2 / ICM / PS2   )
            CD2->(DBSetOrder(2))
            IF  CD2->(DBSEEK(xFilial('CD2')+"S"+cSerie55+cDoc55+cCodCli55+cCodLoj55+cItem+cProd+"ICM"))

                IF l1Linha
                    //Atualiza CD2 - ICMS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ELSE
                    //Atualiza CD2 - ICMS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ENDIF
            ENDIF

            IF  CD2->(DBSEEK(xFilial('CD2')+"S"+cSerie55+cDoc55+cCodCli55+cCodLoj55+cItem+cProd+"PS2"))
                IF l1Linha
                    //Atualiza CD2 - PIS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ELSE
                    //Atualiza CD2 - PIS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ENDIF
            ENDIF

            IF  CD2->(DBSEEK(xFilial('CD2')+"S"+cSerie55+cDoc55+cCodCli55+cCodLoj55+cItem+cProd+"CF2"))
                IF l1Linha
                    //Atualiza CD2 - COFINS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ELSE
                    //Atualiza CD2 - COFINS
                    RECLOCK('CD2',.F.)
                    IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                        CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                    ENDIF
                    IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                    ENDIF
                    IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                        CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                    ENDIF
                    CD2->(MSUNLOCK())
                ENDIF
            ENDIF

            cItem  := ""
            (cAliasSD2)->(DBCloseArea())
            (cAliasSFT)->(DBCloseArea())
        Next nY52

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF2 INICIO                                   /////
        //////////////////////////////////////////////////////////////////////////////////////

        //A SF2 É UNICA, LOGO UM DESEEK É O MAIS CORRETO.
        SF2->(DBSetOrder(1))
        IF SF2->(DBSEEK(xFilial('SF2')+cDoc55+cSerie55+cCodCli55+cCodLoj55))

            RECLOCK("SF2",.F.)
            IF SF2->F2_VALBRUT <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) //vBC
                SF2->F2_VALBRUT := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF
            IF SF2->F2_BASEICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) //vBC
                SF2->F2_BASEICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF
            IF SF2->F2_VALMERC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)  //vBC
                SF2->F2_VALMERC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            //O VALOR DA BASE DO IMPOSTO PIS E COFINS É O VALOR TOTAL DA NOTA MENOS O VALOR DO ICMS
            IF SF2->F2_BASIMP5  <> (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))  //vICMS
                SF2->F2_BASIMP5 := (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
            ENDIF
            IF SF2->F2_BASIMP6  <> (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))  //vICMS
                SF2->F2_BASIMP6 := (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
            ENDIF
            /////////////////////////////////////////////////////////////////////////////////////////////////////
            IF SF2->F2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)  //vICMS
                SF2->F2_VALICM  :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)
            ENDIF
            IF SF2->F2_VALIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vPIS:TEXT)  //vPIS
                SF2->F2_VALIMP6 := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vPIS:TEXT)
            ENDIF
            IF SF2->F2_VALIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vCOFINS:TEXT)  //vCOFINS
                SF2->F2_VALIMP5 := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vCOFINS:TEXT)
            ENDIF
            SF2->(MSUNLOCK())
        ENDIF

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF2 FIM                                      /////
        //////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF3 INICIO                                   /////
        //////////////////////////////////////////////////////////////////////////////////////

        lOKSF3 := .F.
        cAliasSF3 := GetnextAlias()

        cQuerySF3 := " SELECT SUM(F3_VALICM) AS VALSF3 FROM "+RetSQLName('SF3')+ " (nolock) s "
        cQuerySF3 += " WHERE D_E_L_E_T_ = ' ' "
        cQuerySF3 += " AND F3_NFISCAL = '" + cDoc55 + "' "
        cQuerySF3 += " AND F3_SERIE = '" + cSerie55 + "' "
        cQuerySF3 += " AND F3_CLIEFOR = '" + cCodCli55 + "' "
        cQuerySF3 += " AND F3_LOJA = '" + cCodLoj55 + "' "
        cQuerySF3 += " AND F3_FILIAL = '" + xFilial('SF3') + "' "

        PLSQuery(cQuerySF3, cAliasSF3)

        IF (cAliasSF3)->VALSF3 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)

            cAlsSF3 := GetnextAlias()

            cQrySF32 := " SELECT   F3_BASEICM, F3_ALIQICM, F3_IDENTFT, F3_ENTRADA, F3_CFO, F3_EMISSAO  FROM "+RetSQLName('SF3')+ " (nolock) s "
            cQrySF32 += " WHERE D_E_L_E_T_ = ' ' "
            cQrySF32 += " AND F3_NFISCAL = '" + cDoc55 + "' "
            cQrySF32 += " AND F3_SERIE = '" + cSerie55 + "' "
            cQrySF32 += " AND F3_CLIEFOR = '" + cCodCli55 + "' "
            cQrySF32 += " AND F3_LOJA = '" + cCodLoj55 + "' "
            cQrySF32 += " AND F3_FILIAL = '" + xFilial('SF3') + "' "
            cQrySF32 += " ORDER BY F3_IDENTFT DESC "

            PLSQuery(cQrySF32, cAlsSF3)

            cDaTEnt := (cAlsSF3)->F3_ENTRADA
            cDatEmiss := (cAlsSF3)->F3_EMISSAO

            While (cAlsSF3)->(!EOF())
                IF nValt1 <> 0
                    nValt2 := Round((cAlsSF3)->F3_BASEICM * ((cAlsSF3)->F3_ALIQICM/100), 2)
                    nAlic2 := STR((cAlsSF3)->F3_ALIQICM, 5, 2)
                    cCfo2  := (cAlsSF3)->F3_CFO
                ENDIF
                IF nValt2 == 0
                    nValt1 := Round((cAlsSF3)->F3_BASEICM * ((cAlsSF3)->F3_ALIQICM/100), 2)
                    nAlic1 := STR((cAlsSF3)->F3_ALIQICM, 5, 2)
                    cCfo1  := (cAlsSF3)->F3_CFO
                ENDIF
                (cAlsSF3)->(DBSkip())
            End

            //SE AMBOS ESTIVEREM PREENCHIDOS É PORQUE HÁ 2 LINHAS NA SF3
            IF !(Empty(nValt1)) .AND. !Empty(nValt2)
                IF nValt1+nValt2 == VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)

                    SF3->(DBSetOrder(1)) //F3_FILIAL + DTOS(F3_ENTRADA) + F3_NFISCAL + F3_SERIE + F3_CLIEFOR + F3_LOJA + F3_CFO + STR(F3_ALIQICM, 5, 2)
                    //LINHA 1
                    IF SF3->(DBSEEK(xFilial('SF3')+DTOS(cDaTEnt)+cDoc55+cSerie55+cCodCli55+cCodLoj55+cCfo1+nAlic1))
                        RECLOCK('SF3',.F.)
                        SF3->F3_VALICM := nValt1
                        SF3->(MSUNLOCK())
                    ENDIF

                    //LINHA 2
                    IF SF3->(DBSEEK(xFilial('SF3')+DTOS(cDaTEnt)+cDoc55+cSerie55+cCodCli55+cCodLoj55+cCfo2+nAlic2))
                        RECLOCK('SF3',.F.)
                        SF3->F3_VALICM := nValt2
                        SF3->(MSUNLOCK())
                    ENDIF
                ENDIF
            ELSE
                //QUANDO HÁ APENAS 1 LINHA NA SF3
                SF3->(DBSetOrder(4)) //F3_FILIAL + F3_CLIEFOR + F3_LOJA + F3_NFISCAL + F3_SERIE
                IF SF3->(DBSEEK(xFilial('SF3')+cCodCli55+cCodLoj55+cDoc55+cSerie55))
                    RECLOCK('SF3',.F.)
                    SF3->F3_VALICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)
                    SF3->(MSUNLOCK())
                    lOKSF3 := .T.
                ENDIF
            ENDIF
        ENDIF

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF3 FIM                                      /////
        //////////////////////////////////////////////////////////////////////////////////////

        lMens := .T.

    ELSE

        nVlPisTot := 0
        nVlCofTot := 0
        nValIcmZY := 0
        nvalTesz  := 0
        aPercAd   := {}

        cQrySF3Y := " SELECT R_E_C_N_O_ AS RECST  FROM "+RetSQLName('SF3')+ " (nolock) s "
        cQrySF3Y += " WHERE D_E_L_E_T_ = ' ' "
        cQrySF3Y += " AND F3_NFISCAL = '" + cDoc55 + "' "
        cQrySF3Y += " AND F3_SERIE = '" + cSerie55 + "' "
        cQrySF3Y += " AND F3_CLIEFOR = '" + cCodCli55 + "' "
        cQrySF3Y += " AND F3_LOJA = '" + cCodLoj55 + "' "
        cQrySF3Y += " AND F3_FILIAL = '" + xFilial('SF3') + "' "
        cQrySF3Y += " ORDER BY F3_ALIQICM ASC  "

        cAliasZ1 := GetnextAlias()
        PLSQuery(cQrySF3Y, cAliasZ1)
        SF3->(DBSetOrder(1))
        While (cAliasZ1)->(!EOF())
            SF3->(DBGoTo((cAliasZ1)->RECST))
            aAdd(aPercAd,{SF3->F3_ALIQICM,0,0})
            (cAliasZ1)->(DBSkip())
        EndDo
        (cAliasZ1)->(DBCloseArea())
        //////////////////////////////////////////////////////////////////////////////////////
        /////               QUANDO XML TEM MENOS LINHAS QUE O PROTHEUS                   /////
        //////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////
        //**********************************************************************************//
        //////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SD2  INICIO                                  /////
        //////////////////////////////////////////////////////////////////////////////////////

        cAliasSD2 := GetnextAlias()

        cQuerySD2 := "SELECT R_E_C_N_O_ AS RECD2, D2_ITEM FROM "+ RetSQLName('SD2')+ " (nolock) "
        cQuerySD2 += " WHERE D_E_L_E_T_ = ' ' "
        cQuerySD2 += " AND D2_PEDIDO = '" + cPed55 + "' "
        cQuerySD2 += " AND D2_FILIAL = '" + cFil55 + "' "
        cQuerySD2 += " AND D2_DOC = '" + cDoc55 + "' "
        cQuerySD2 += " AND D2_SERIE = '" + cSerie55 + "' "
        cQuerySD2 += " ORDER BY D2_ITEM , RECD2 "

        PLSQuery(cQuerySD2, cAliasSD2)

        SD2->(DBSetOrder(1))
        nY52 := 1
        lPrinL := .T.
        lValModif := .F.

        SD2->(DBGoTo((cAliasSD2)->RECD2))

        IF l1Linha
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
        ELSE
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
        ENDIF

        cProd   :=  fGetPrd(cPrdXML)
        nCountz := 0

        While (cAliasSD2)->(!EOF())

            IF SD2->D2_COD == cProd

                IF SD2->D2_QUANT <> IIF(l1Linha, VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_qCom:TEXT), VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_qCom:TEXT))
                    lValModif := .T.
                    nCountz ++

                    IF l1Linha

                        nValBICM  := Int((SD2->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        //Controle de Centavos.
                        IF nCountz == 1
                            aValZY    := CalqIcmU(cPed55,cFil55,cDoc55,cSerie55,oXML2,nValIcms,"SD2",cProd)
                            IF aValZY[2]
                                nValIcms := nValIcms - aValZY[1] //-
                            ELSEIF   aValZY[3]
                                nValIcms := nValIcms + aValZY[1] //+
                            ENDIF
                        ENDIF
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100
                        nVlPisTot += nValImpis
                        nVlCofTot += nValImCof

                        FOR nAwi := 1 To Len(aPercAd)
                            IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) == aPercAd[nAwi][1]
                                aPercAd[nAwi][2] += nValIcms
                                aPercAd[nAwi][3] += nValBICM
                            ENDIF
                        Next nAwi

                        nvalTesz += Int((SD2->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                    ELSE
                        nValBICM  := Int((SD2->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        //Controle de Centavos.
                        IF nCountz == 1
                            aValZY    := CalqIcmU(cPed55,cFil55,cDoc55,cSerie55,oXML2,nValIcms,"SD2",cProd,nY52)
                            IF aValZY[2]
                                nValIcms := nValIcms - aValZY[1] //-
                            ELSEIF   aValZY[3]
                                nValIcms := nValIcms + aValZY[1] //+
                            ENDIF
                        ENDIF
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100
                        nVlPisTot += nValImpis
                        nVlCofTot += nValImCof
                        FOR nAwi := 1 To Len(aPercAd)
                            IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) == aPercAd[nAwi][1]
                                aPercAd[nAwi][2] += nValIcms
                                aPercAd[nAwi][3] += nValBICM
                            ENDIF
                        Next nAwi
                        nvalTesz +=  Int((SD2->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                    ENDIF

                ENDIF

                // XML COM APENAS 1 ITEM.
                IF l1Linha
                    RECLOCK('SD2',.F.)
                    IF lValModif
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> nValBase
                            SD2->D2_BASIMP5  := nValBase
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> nValBase
                            SD2->D2_BASIMP6  := nValBase
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> nValImCof
                            SD2->D2_VALIMP5  := nValImCof
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> nValImpis
                            SD2->D2_VALIMP6  := nValImpis
                        ENDIF
                        //VALOR DO ICMS
                        IF SD2->D2_VALICM  <> nValIcms
                            SD2->D2_VALICM   := nValIcms
                        ENDIF
                        IF SD2->D2_BASEICM  <> nValBICM
                            SD2->D2_BASEICM   := nValBICM
                        ENDIF
                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                        ENDIF
                    ELSE
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                            SD2->D2_VALIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                            SD2->D2_VALIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                        ENDIF
                        //VALOR DO ICMS(A BASE É O VALOR TOTAL DO PRODUTO, NÃO PRECISA DE CORREÇÃO)
                        IF SD2->D2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            SD2->D2_VALICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF

                        IF SD2->D2_BASEICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            SD2->D2_BASEICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        ENDIF

                        nVlCofTot += SD2->D2_VALIMP5
                        nVlPisTot += SD2->D2_VALIMP6

                        FOR nAwi := 1 To Len(aPercAd)
                            IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) == aPercAd[nAwi][1]
                                aPercAd[nAwi][2] += SD2->D2_VALICM
                                aPercAd[nAwi][3] += SD2->D2_BASEICMF
                            ENDIF
                        Next nAwi

                        nvalTesz +=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vProd:TEXT)

                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_PROD:_CFOP:TEXT
                        ENDIF
                    ENDIF
                    SD2->(MSUNLOCK())
                ELSE

                    RECLOCK('SD2',.F.)
                    IF lValModif
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> nValBase
                            SD2->D2_BASIMP5  := nValBase
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> nValBase
                            SD2->D2_BASIMP6  := nValBase
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> nValImCof
                            SD2->D2_VALIMP5  := nValImCof
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> nValImpis
                            SD2->D2_VALIMP6  := nValImpis
                        ENDIF
                        //VALOR DO ICMS
                        IF SD2->D2_VALICM  <> nValIcms
                            SD2->D2_VALICM   := nValIcms
                        ENDIF
                        IF SD2->D2_BASEICM  <> nValBICM
                            SD2->D2_BASEICM   := nValBICM
                        ENDIF
                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                    ELSE
                        //BASE DE CALCULO COFINS
                        IF SD2->D2_BASIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        //BASE DE CALCULO PIS
                        IF SD2->D2_BASIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                            SD2->D2_BASIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_VBC:TEXT)
                        ENDIF
                        //VALOR DO COFINS
                        IF SD2->D2_VALIMP5 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                            SD2->D2_VALIMP5  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        //VALOR DO PIS
                        IF SD2->D2_VALIMP6 <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                            SD2->D2_VALIMP6  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISALIQ:_vPIS:TEXT)
                        ENDIF
                        //VALOR DO ICMS
                        IF SD2->D2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            SD2->D2_VALICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF

                        IF SD2->D2_BASEICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            SD2->D2_BASEICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                        ENDIF

                        nVlCofTot += SD2->D2_VALIMP5
                        nVlPisTot += SD2->D2_VALIMP6

                        FOR nAwi := 1 To Len(aPercAd)
                            IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) == aPercAd[nAwi][1]
                                aPercAd[nAwi][2] += SD2->D2_VALICM
                                aPercAd[nAwi][3] += SD2->D2_BASEICMF
                            ENDIF
                        Next nAwi

                        nvalTesz +=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_vProd:TEXT)

                        IF SD2->D2_PICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            SD2->D2_PICM   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP5  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQIMP5   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            SD2->D2_ALQCOF   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQIMP6  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQIMP6   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_ALQPIS  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            SD2->D2_ALQPIS   := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SD2->D2_CF  <> OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                            SD2->D2_CF   := OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                    ENDIF
                    SD2->(MSUNLOCK())
                ENDIF

                (cAliasSD2)->(DBSkip())

                lValModif := .F.

                IF (cAliasSD2)->(!EOF())
                    SD2->(DBGoTo((cAliasSD2)->RECD2))

                    IF SD2->D2_COD <> cProd
                        nY52++
                        nCountz := 0
                    ENDIF

                    IF l1Linha
                        cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
                    ELSE
                        cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
                    ENDIF
                    cProd   :=  fGetPrd(cPrdXML)

                ENDIF

            ENDIF

        Enddo
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SD2  FIM                                     /////
        //////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SFT INICIO                                   /////
        //////////////////////////////////////////////////////////////////////////////////////

        cAliasSFT := GetnextAlias()

        cQuerySFT := "SELECT R_E_C_N_O_ AS RECFT FROM "+ RetSQLName('SFT')+ " (nolock) "
        cQuerySFT += " WHERE D_E_L_E_T_ = ' ' "
        cQuerySFT += " AND FT_FILIAL = '" + cFil55 + "' "
        cQuerySFT += " AND FT_NFISCAL = '" + cDoc55 + "' "
        cQuerySFT += " AND FT_SERIE = '" + cSerie55 + "' "
        cQuerySFT += " AND FT_CLIEFOR = '" + cCodCli55 + "' "
        cQuerySFT += " AND FT_LOJA = '" + cCodLoj55 + "' "
        cQuerySFT += " ORDER BY FT_ITEM ASC "

        PLSQuery(cQuerySFT, cAliasSFT)

        SFT->(DBSetOrder(1)) //FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
        nY52 := 1
        lPrinL := .T.
        lValModif := .F.

        SFT->(DBGoTo((cAliasSFT)->RECFT))
        nCountz := 0

        IF l1Linha
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
        ELSE
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
        ENDIF

        cProd   :=  fGetPrd(cPrdXML)

        While (cAliasSFT)->(!EOF())

            IF SFT->FT_PRODUTO == cProd

                IF SFT->FT_QUANT <> IIF(l1Linha, VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_qCom:TEXT), VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_qCom:TEXT))
                    lValModif := .T.
                    nCountz ++
                    IF l1Linha
                        nValBICM  := Int((SFT->FT_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        IF nCountz == 1
                            aValZY    := CalqIcmU(cPed55,cFil55,cDoc55,cSerie55,oXML2,nValIcms,"SFT",cProd,,cCodCli55,cCodLoj55)
                            IF aValZY[2]
                                nValIcms := nValIcms - aValZY[1] //-
                            ELSEIF   aValZY[3]
                                nValIcms := nValIcms + aValZY[1] //+
                            ENDIF
                        ENDIF
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100

                    ELSE
                        nValBICM  := Int((SFT->FT_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        IF nCountz == 1
                            aValZY    := CalqIcmU(cPed55,cFil55,cDoc55,cSerie55,oXML2,nValIcms,"SFT",cProd,nY52,cCodCli55,cCodLoj55)
                            IF aValZY[2]
                                nValIcms := nValIcms - aValZY[1] //-
                            ELSEIF   aValZY[3]
                                nValIcms := nValIcms + aValZY[1] //+
                            ENDIF
                        ENDIF
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100

                    ENDIF
                ENDIF

                IF l1Linha
                    IF lValModif
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> nValBase
                            SFT->FT_BASEPIS := nValBase
                        ENDIF
                        IF SFT->FT_BASECOF  <> nValBase
                            SFT->FT_BASECOF := nValBase
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> nValImpis  //vBC
                            SFT->FT_VALPIS  := nValImpis
                        ENDIF
                        IF SFT->FT_VALCOF  <> nValImCof  //vICMS
                            SFT->FT_VALCOF  := nValImCof
                        ENDIF
                        IF SFT->FT_VALICM <> nValICMS  //vBC
                            SFT->FT_VALICM := nValICMS
                        ENDIF
                        IF SFT->FT_BASEICM <> nValBICM
                            SFT->FT_BASEICM := nValBICM
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT
                        ENDIF
                        SFT->(MSUNLOCK())
                    ELSE
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT) //vBC
                            SFT->FT_BASEPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_BASECOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)  //vICMS
                            SFT->FT_BASECOF :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)  //vBC
                            SFT->FT_VALPIS  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        ENDIF
                        IF SFT->FT_VALCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)  //vICMS
                            SFT->FT_VALCOF  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) //vBC
                            SFT->FT_VALICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CFOP:TEXT
                        ENDIF
                        SFT->(MSUNLOCK())
                    ENDIF
                ELSE
                    IF lValModif
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> nValBase
                            SFT->FT_BASEPIS := nValBase
                        ENDIF
                        IF SFT->FT_BASECOF  <> nValBase
                            SFT->FT_BASECOF := nValBase
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> nValImpis  //vBC
                            SFT->FT_VALPIS  := nValImpis
                        ENDIF
                        IF SFT->FT_VALCOF  <> nValImCof  //vICMS
                            SFT->FT_VALCOF  := nValImCof
                        ENDIF
                        IF SFT->FT_VALICM <> nValICMS  //vBC
                            SFT->FT_VALICM := nValICMS
                        ENDIF
                        IF SFT->FT_BASEICM <> nValBICM
                            SFT->FT_BASEICM := nValBICM
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                        SFT->(MSUNLOCK())
                    ELSE
                        RECLOCK('SFT',.F.)
                        IF SFT->FT_BASEPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT) //vBC
                            SFT->FT_BASEPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_BASECOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)  //vICMS
                            SFT->FT_BASECOF :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_VBC:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) //vBC
                            SFT->FT_ALIQPIS := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)  //vICMS
                            SFT->FT_ALIQCOF := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_pCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALPIS <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)  //vBC
                            SFT->FT_VALPIS  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                        ENDIF
                        IF SFT->FT_VALCOF  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)  //vICMS
                            SFT->FT_VALCOF  := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSALIQ:_vCOFINS:TEXT)
                        ENDIF
                        IF SFT->FT_VALICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) //vBC
                            SFT->FT_VALICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                        ENDIF
                        IF SFT->FT_ALIQICM <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) //vBC
                            SFT->FT_ALIQICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                        ENDIF
                        IF SFT->FT_CFOP <> OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT//vBC
                            SFT->FT_CFOP := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CFOP:TEXT
                        ENDIF
                        SFT->(MSUNLOCK())
                    ENDIF
                ENDIF
            ENDIF

            (cAliasSFT)->(DBSkip())

            lValModif := .F.

            IF (cAliasSFT)->(!EOF())
                SFT->(DBGoTo((cAliasSFT)->RECFT))

                IF SFT->FT_PRODUTO <> cProd
                    nY52++
                    nCountz := 0
                ENDIF

                IF l1Linha
                    cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
                ELSE
                    cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
                ENDIF
                cProd   :=  fGetPrd(cPrdXML)
            ENDIF

        EndDo
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SFT FIM                                      /////
        //////////////////////////////////////////////////////////////////////////////////////

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               CD2  INICIO                                  /////
        //////////////////////////////////////////////////////////////////////////////////////

        cAliasCD2 := GetnextAlias()

        cQueryCD2 := " SELECT CD2.R_E_C_N_O_ AS RECCD2, SD2.D2_VALICM, CD2.CD2_FILIAL, CD2.CD2_DOC, CD2.CD2_SERIE, CD2.CD2_ITEM, CD2.CD2_CODFOR, "
        cQueryCD2 += " CD2.CD2_LOJFOR, CD2.CD2_CODPRO, SD2.D2_QUANT FROM "+RETSQLNAME("CD2")+" CD2 (NOLOCK) "
        cQueryCD2 += " INNER JOIN "+RETSQLNAME("SD2")+ " SD2 (NOLOCK) ON  SD2.D2_FILIAL = CD2.CD2_FILIAL AND SD2.D2_DOC = CD2.CD2_DOC "
        cQueryCD2 += " AND SD2.D2_SERIE = CD2.CD2_SERIE AND SD2.D2_ITEM = CD2.CD2_ITEM AND SD2.D_E_L_E_T_ = '' "
        cQueryCD2 += " WHERE CD2.D_E_L_E_T_ = '' "
        cQueryCD2 += " AND CD2.CD2_DOC    =  "+valtosql(cDoc55)
        cQueryCD2 += " AND CD2.CD2_SERIE  =  "+valtosql(cSerie55)
        cQueryCD2 += " AND CD2.CD2_FILIAL =  "+valtosql(cFil55)
        cQueryCD2 += " AND CD2.CD2_CODFOR =  "+valtosql(cCodCli55)
        cQueryCD2 += " AND CD2.CD2_LOJFOR =  "+valtosql(cCodLoj55)
        cQueryCD2 += " ORDER BY CD2.CD2_ITEM ASC "

        PLSQuery(cQueryCD2, cAliasCD2)

        CD2->(DBSetOrder(1)) //FT_FILIAL + FT_TIPOMOV + FT_SERIE + FT_NFISCAL + FT_CLIEFOR + FT_LOJA + FT_ITEM + FT_PRODUTO
        nY52 := 1
        lPrinL := .T.
        lValModif := .F.

        CD2->(DBGoTo((cAliasCD2)->RECCD2))

        IF l1Linha
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
        ELSE
            cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
        ENDIF

        cProd   :=  fGetPrd(cPrdXML)

        While (cAliasCD2)->(!EOF())

            IF CD2->CD2_CODPRO == cProd

                IF (cAliasCD2)->D2_QUANT <> IIF(l1Linha, VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_qCom:TEXT), VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_qCom:TEXT))
                    lValModif := .T.

                    IF l1Linha
                        nValBICM  := Int(((cAliasCD2)->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := (cAliasCD2)->D2_VALICM //Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100
                    ELSE
                        nValBICM  := Int(((cAliasCD2)->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                        nValIcms  := (cAliasCD2)->D2_VALICM //Int((nValBICM * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
                        nValBase  := Int((nValBICM - nValIcms) * 100) / 100
                        nValImCof := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT) / 100)) * 100) / 100
                        nValImpis := Int((nValBase * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT) / 100)) * 100) / 100
                    ENDIF
                ENDIF

                IF AllTrim(CD2->CD2_IMP) == "CF2"
                    IF l1Linha
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBase
                                CD2->CD2_BC := nValBase
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValImCof
                                CD2->CD2_VLTRIB := nValImCof
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            //Atualiza CD2 - COFINS
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ELSE
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBase
                                CD2->CD2_BC := nValBase
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValImCof
                                CD2->CD2_VLTRIB := nValImCof
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            //Atualiza CD2 - COFINS
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_pCOFINS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_COFINS:_COFINSAliq:_vCOFINS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ENDIF
                ENDIF

                (cAliasCD2)->(DBSkip())
                IF (cAliasCD2)->(!EOF())
                    CD2->(DBGoTo((cAliasCD2)->RECCD2))
                    IF CD2->CD2_CODPRO <> cProd
                        nY52++
                    ENDIF
                ENDIF

                IF AllTrim(CD2->CD2_IMP) == "ICM" //Atualiza CD2 - ICMS
                    IF l1Linha
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBICM
                                CD2->CD2_BC := nValBICM
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                                CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValIcms
                                CD2->CD2_VLTRIB := nValIcms
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                                CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ELSE
                        //Atualiza CD2 - ICMS
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBICM
                                CD2->CD2_BC := nValBICM
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                                CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValIcms
                                CD2->CD2_VLTRIB := nValIcms
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                                CD2->CD2_ALIQ :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ENDIF
                ENDIF

                (cAliasCD2)->(DBSkip())
                IF (cAliasCD2)->(!EOF())
                    CD2->(DBGoTo((cAliasCD2)->RECCD2))
                    IF CD2->CD2_CODPRO <> cProd
                        nY52++
                    ENDIF
                ENDIF

                IF AllTrim(CD2->CD2_IMP) == "PS2"
                    IF l1Linha
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBase
                                CD2->CD2_BC := nValBase
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValImpis
                                CD2->CD2_VLTRIB := nValImpis
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            //Atualiza CD2 - PIS
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ELSE
                        //Atualiza CD2 - PIS
                        IF lValModif
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> nValBase
                                CD2->CD2_BC := nValBase
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> nValImpis
                                CD2->CD2_VLTRIB := nValImpis
                            ENDIF
                            CD2->(MSUNLOCK())
                        ELSE
                            //Atualiza CD2 - PIS
                            RECLOCK('CD2',.F.)
                            IF CD2->CD2_BC <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                                CD2->CD2_BC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vBC:TEXT)
                            ENDIF
                            IF CD2->CD2_ALIQ <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                                CD2->CD2_ALIQ := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_pPIS:TEXT)
                            ENDIF
                            IF CD2->CD2_VLTRIB <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                                CD2->CD2_VLTRIB := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_PIS:_PISAliq:_vPIS:TEXT)
                            ENDIF
                            CD2->(MSUNLOCK())
                        ENDIF
                    ENDIF
                ENDIF

                (cAliasCD2)->(DBSkip())
                lValModif := .F.

                IF (cAliasCD2)->(!EOF())
                    CD2->(DBGoTo((cAliasCD2)->RECCD2))
                    IF CD2->CD2_CODPRO <> cProd
                        nY52++
                    ENDIF
                    IF l1Linha
                        cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_CEAN:TEXT
                    ELSE
                        cPrdXML := OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_CEAN:TEXT
                    ENDIF
                    cProd   :=  fGetPrd(cPrdXML)
                ENDIF
            ENDIF

        EndDo

        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF2 INICIO                                   /////
        //////////////////////////////////////////////////////////////////////////////////////

        //A SF2 É UNICA, LOGO UM DESEEK É O MAIS CORRETO.
        SF2->(DBSetOrder(1))
        IF SF2->(DBSEEK(xFilial('SF2')+cDoc55+cSerie55+cCodCli55+cCodLoj55))

            RECLOCK("SF2",.F.)
            IF SF2->F2_VALBRUT <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
                SF2->F2_VALBRUT := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF
            IF SF2->F2_BASEICM <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)   //vBC
                SF2->F2_BASEICM := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF
            IF SF2->F2_VALMERC <>  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)  //vBC
                SF2->F2_VALMERC := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT)
            ENDIF

            IF SF2->F2_VALICM  <> VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)  //vICMS
                SF2->F2_VALICM  :=  VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT)
            ENDIF
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            //O VALOR DA BASE DO IMPOSTO PIS E COFINS É O VALOR TOTAL DA NOTA MENOS O VALOR DO ICMS
            IF SF2->F2_BASIMP5  <> (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
                SF2->F2_BASIMP5 := (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
            ENDIF
            IF SF2->F2_BASIMP6  <> (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
                SF2->F2_BASIMP6 := (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_VBC:TEXT) - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_total:_ICMSTot:_vICMS:TEXT))
            ENDIF
            /////////////////////////////////////////////////////////////////////////////////////////////////////

            IF SF2->F2_VALIMP6  <> nVlPisTot  //vPIS
                SF2->F2_VALIMP6 := nVlPisTot
            ENDIF
            IF SF2->F2_VALIMP5  <> nVlCofTot  //vCOFINS
                SF2->F2_VALIMP5 := nVlCofTot
            ENDIF
            SF2->(MSUNLOCK())
        ENDIF
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF2 FIM                                      /////
        //////////////////////////////////////////////////////////////////////////////////////
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF3 INICIO                                   /////
        //////////////////////////////////////////////////////////////////////////////////////000049

        cQrySF3 := " SELECT R_E_C_N_O_ AS RECST  FROM "+RetSQLName('SF3')+ " (nolock) s "
        cQrySF3 += " WHERE D_E_L_E_T_ = ' ' "
        cQrySF3 += " AND F3_NFISCAL = '" + cDoc55 + "' "
        cQrySF3 += " AND F3_SERIE = '" + cSerie55 + "' "
        cQrySF3 += " AND F3_CLIEFOR = '" + cCodCli55 + "' "
        cQrySF3 += " AND F3_LOJA = '" + cCodLoj55 + "' "
        cQrySF3 += " AND F3_FILIAL = '" + xFilial('SF3') + "' "
        cQrySF3 += " ORDER BY F3_ALIQICM ASC  "

        cAliasZ2 := GetnextAlias()
        PLSQuery(cQrySF3, cAliasZ2)
        SF3->(DBSetOrder(1))
        While (cAliasZ2)->(!EOF())

            SF3->(DBGoTo((cAliasZ2)->RECST))

            FOR nAwi := 1 To Len(aPercAd)
                IF SF3->F3_ALIQICM == aPercAd[nAwi][1]
                    RECLOCK('SF3',.F.)
                    SF3->F3_VALCONT := aPercAd[nAwi][3]
                    SF3->F3_BASEICM := aPercAd[nAwi][3]
                    SF3->F3_VALICM  := aPercAd[nAwi][2]
                    SF3->(MSUNLOCK())
                ENDIF
            Next nAwi

            (cAliasZ2)->(DBSkip())

        EndDo
        //////////////////////////////////////////////////////////////////////////////////////
        /////                               SF3 FIM                                      /////
        //////////////////////////////////////////////////////////////////////////////////////

    ENDIF

    l1Linha := .F.
    nTesteV := 0

    IF VALTYPE(OXML2:_NFEPROC:_NFE:_INFNFE:_DET) == "O"
        nLinhaQTD := 1
        l1Linha := .T.
    ELSE
        nLinhaQTD := Len(OXML2:_NFEPROC:_NFE:_INFNFE:_DET)
    ENDIF

    IF l1Linha
        nTesteV :=   VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
    ELSE
        FOR nY52 := 1 TO nLinhaQTD
            nTesteV +=   VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_Det[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vBC:TEXT)
        Next nY52
    ENDIF


Return


Static Function fGetPrd(cPrdXML)

    Local cRetP01 := ""
    Local cEol := chr(10)
    Local cAliGEt := GetnextAlias()

    cSql := "  SELECT B1_COD "  + cEol
    cSql += "  FROM "+ RetSQLName("SB1") +" (NOLOCK) " + cEol
    cSql += "  WHERE D_E_L_E_T_ =  '' " + cEol
    cSql += "  AND B1_CODBAR =  " + valtosql(cPrdXML)

    PLSQuery(cSql, cAliGEt)

    IF  (cAliGEt)->(!Eof())
        cRetP01 := (cAliGEt)->B1_COD
    Endif

Return cRetP01

Static Function cForIte(nY52)
    Local cNum := ""
    Local cResult := ""
    Default nY52 := 0
    If nY52 < 10
        cNum := "0" + AllTrim(Str(nY52)) // "03"
    Else
        cNum := AllTrim(Str(nY52))       // "10", "99", "100"
    EndIf
    cResult := PadR(cNum, 4) // completa com espaços à direita até 4 caracteres
Return cResult


//Função responsável por validar centavos do ICMS calculados no Fonte.
//pois ao calcular aqui pode ser que fique 1 centavo errado
//Daniel Victor da Rosa - Personalitec
//23-10-2025
Static Function CalqIcmU(cPed56,cFil56,cDoc56,cSerie56,oXML2,nVaIcms,cTab,cProd2,nY52,cCodCli55,cCodLoj55,cImp)

    Local cQueryGe := ""
    Local cAliasGe := GetnextAlias()
    Local nValCout := 0
    Local nIcmCAL  := 0
    Local nIcmCAl2 := 0
    Local nQuantl  := 0
    Local lSoma    := .F.
    Local lSubtrai := .F.

    IF cTab == "SD2"

        cQueryGe := " SELECT D2_QUANT FROM " + RetSQLName('SD2')+ " (nolock) S "
        cQueryGe += " WHERE D_E_L_E_T_ = ' ' "
        cQueryGe += " AND D2_PEDIDO = '" + cPed56 + "' "
        cQueryGe += " AND D2_FILIAL = '" + cFil56 + "' "
        cQueryGe += " AND D2_DOC = '" + cDoc56 + "' "
        cQueryGe += " AND D2_SERIE = '" + cSerie56 + "' "
        cQueryGe += " AND D2_COD = '" + cProd2 + "' "

        PLSQuery(cQueryGe, cAliasGe)

        While (cAliasGe)->(!EOF())
            nQuantl++
            IF l1Linha
                nIcmCAL   := Int(((cAliasGe)->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                nIcmCAL2  += Int((nIcmCAL * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
            ELSE
                nIcmCAL   := Int(((cAliasGe)->D2_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                nIcmCAL2  += Int((nIcmCAL * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
            ENDIF

            (cAliasGe)->(DBSkip())
        EndDo

    ELSEIF cTab == "SFT"

        cQueryGe := "SELECT FT_QUANT FROM "+ RetSQLName('SFT')+ " (nolock) "
        cQueryGe += " WHERE D_E_L_E_T_ = ' ' "
        cQueryGe += " AND FT_FILIAL = '" + cFil56 + "' "
        cQueryGe += " AND FT_NFISCAL = '" + cDoc56 + "' "
        cQueryGe += " AND FT_SERIE = '" + cSerie56 + "' "
        cQueryGe += " AND FT_CLIEFOR = '" + cCodCli55 + "' "
        cQueryGe += " AND FT_LOJA = '" + cCodLoj55 + "' "
        cQueryGe += " AND FT_PRODUTO = '" + cProd2 + "' "

        PLSQuery(cQueryGe, cAliasGe)

        While (cAliasGe)->(!EOF())
            nQuantl++
            IF l1Linha
                nIcmCAL   := Int(((cAliasGe)->FT_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)) * 100) / 100
                nIcmCAL2  += Int((nIcmCAL * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
            ELSE
                nIcmCAL   := Int(((cAliasGe)->FT_QUANT * VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_PROD:_vUnCom:TEXT)) * 100) / 100
                nIcmCAL2  += Int((nIcmCAL * (VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_pICMS:TEXT) / 100)) * 100) / 100
            ENDIF

            (cAliasGe)->(DBSkip())
        EndDo
    ENDIF


    IF l1Linha

        IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:vICMS:TEXT) < nIcmCAL2

            nValCout :=  nIcmCAL2 - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:vICMS:TEXT)

        ELSEIF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:vICMS:TEXT) > nIcmCAL2

            nValCout := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:vICMS:TEXT) - nIcmCAL2

        ELSEIF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET:_IMPOSTO:_ICMS:_ICMS00:vICMS:TEXT) == nIcmCAL2
            nValCout := nIcmCAL2
        ENDIF

    ELSE

        IF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) < nIcmCAL2

            lSubtrai := .T.
            nValCout :=  nIcmCAL2 - VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT)

        ELSEIF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) > nIcmCAL2

            lSoma := .T.
            nValCout := VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) - nIcmCAL2

        ELSEIF VAL(OXML2:_NFEPROC:_NFE:_INFNFE:_DET[nY52]:_IMPOSTO:_ICMS:_ICMS00:_vICMS:TEXT) == nIcmCAL2
            nValCout := nIcmCAL2
        ENDIF

    ENDIF

Return {nValCout,lSubtrai,lSoma}
