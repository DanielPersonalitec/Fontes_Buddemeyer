#include 'TOTVS.CH'

/*/{Protheus.doc} TstSF2460
@Teste isolado do ponto de entrada SF2460I para verificar questão de centavos.
@Dainel Victor da Rosa - Personalitec
@since 04/11/2025
/*/
User Function TstSF2460()

    RpcSetEnv("01","01")

    Local cFilil := "01"
    Local cDoc := "709188"
    Local cSerie := "4"

    If (Select('(cAliasCD2)')<> 0)
        dbSelectArea('(cAliasCD2)')
        dbCloseArea()
    EndIf

    cQuery := " SELECT D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, D2.D2_COD, D2.D2_ITEM, D2.D2_PRUNIT, D2.D2_VALICM, D2.D2_VALBRUT, "
    cQuery += " SUM(D2.D2_PICM / 100) AS PERCICMS, "
    cQuery += " SUM(D2.D2_ALQIMP5 / 100) AS PERCIMP5, "
    cQuery += " SUM(D2.D2_ALQIMP6 / 100) AS PERCIMP6, "
    cQuery += " ROUND( SUM(D2.D2_PICM / 100) * (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))), 2 ) AS VALICMS, "
    cQuery += " (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))) * SUM(D2.D2_ALQIMP5 / 100) AS VALIMP5, "
    cQuery += " (SUM(D2.D2_PRUNIT * D2.D2_QUANT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))) * SUM(D2.D2_ALQIMP6 / 100) AS VALIMP6, "
    cQuery += " SUM(D2.D2_QUANT * D2.D2_PRUNIT) AS TOTAL, "
    cQuery += " SUM(C5.C5_DESC1 / 100) AS PERC, "
    cQuery += " SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100) AS DESCONTO, "
    cQuery += " ROUND( (SUM(D2.D2_QUANT * D2.D2_PRUNIT) - (SUM(D2.D2_QUANT * D2.D2_PRUNIT) * SUM(C5.C5_DESC1 / 100))), 3 ) AS VALBRUT, "
    cQuery += " ROUND((D2.D2_TOTAL - D2.D2_DESCBUD), 2) AS DIFICM, "
    cQuery += " ROUND((D2.D2_VALBRUT - (D2.D2_TOTAL - D2.D2_DESCBUD)), 6) AS DIF "
    cQuery += " FROM "+RETSQLNAME("SD2")+" D2 (NOLOCK) "
    cQuery += " INNER JOIN "+RETSQLNAME("SC5")+" C5 (NOLOCK) "
    cQuery += " ON C5.C5_FILIAL = '01' AND C5.C5_NUM = D2.D2_PEDIDO AND C5.D_E_L_E_T_ = '' "
    cQuery += " WHERE D2.D_E_L_E_T_ = '' "
    cQuery += " AND D2.D2_FILIAL = "+valtosql(cFilil)+ " "
    cQuery += " AND D2.D2_DOC = "+valtosql(cDoc)+ " "
    cQuery += " AND D2.D2_SERIE = "+valtosql(cSerie)+ " "
    cQuery += " GROUP BY D2.D2_DOC, D2.D2_SERIE, D2.D2_CLIENTE, D2.D2_LOJA, D2.D2_COD, D2.D2_ITEM, D2.D2_PRUNIT, D2.D2_VALBRUT, D2.D2_TOTAL, D2.D2_DESCBUD, D2.D2_VALICM "

    cAliasCD2 := GetnextAlias()

    PLSQuery(cQuery, cAliasCD2)

    nTotal		:= 0
    nDesc		:= 0
    nTotDesc    := 0
    nDif		:= 0
    nValBrut	:= 0
    nValICMS	:= 0
    nBaseICMS	:= 0
    nBasimp5	:= 0
    nBasimp6	:= 0
    nValimp5	:= 0
    nValimp6	:= 0
    nRecnoSD2 	:= 0
    nVALDIF := 0

    While !(cAliasCD2)->(Eof())
        nVALDIF += (cAliasCD2)->DIF
        (cAliasCD2)->(DBSKIP())
    ENDDO

    (cAliasCD2)->(dbGoTop())
    While !(cAliasCD2)->(Eof())

        nTotal+=    ((cAliasCD2)->TOTAL)
        nDesc+=     ((cAliasCD2)->DESCONTO)
        nValBrut+=  ((cAliasCD2)->VALBRUT)
        nValICMS+=  (((cAliasCD2)->VALICMS))
        nBaseICMS+= (cAliasCD2)->VALBRUT
        nBasimp5+=  ((cAliasCD2)->VALBRUT - (cAliasCD2)->VALICMS)
        nBasimp6+=  ((cAliasCD2)->VALBRUT - (cAliasCD2)->VALICMS) //3.932,58618
        nValimp5+=  nBasimp5*0.0760 ///(((cAliasCD2)->VALIMP5  ))
        nValimp6+=  nBasimp6*0.0165 //(((cAliasCD2)->VALIMP6  ))


        DbSelectArea("SD2")
        DbSetOrder(3)
        DbGotop()
        IF DbSeek(xFilial("SD2")+(cAliasCD2)->D2_DOC+(cAliasCD2)->D2_SERIE+(cAliasCD2)->D2_CLIENTE+(cAliasCD2)->D2_LOJA+(cAliasCD2)->D2_COD+(cAliasCD2)->D2_ITEM)

            SD2->D2_PRCVEN //  (cAliasCD2)->D2_PRUNIT
            SD2->D2_TOTAL  // (((cAliasCD2)->TOTAL))
            SD2->D2_DESCBUD // ((cAliasCD2)->DESCONTO)
            If SD2->D2_ITEM  = "01"
                SD2->D2_BASEICM // IIF ((cAliasCD2)->VALICMS>0,(cAliasCD2)->VALBRUT,0)  //((cAliasCD2)->VALBRUT - 0.01) //(((cAliasCD2)->TOTAL - (cAliasCD2)->DESCONTO)) - ((cAliasCD2)->DIF)
            Else
                SD2->D2_BASEICM // IIF ((cAliasCD2)->VALICMS>0,(cAliasCD2)->VALBRUT,0)
            EndIf
            SD2->D2_VALBRUT // NOROUND(((cAliasCD2)->TOTAL - (cAliasCD2)->DESCONTO)    )
            SD2->D2_VALICM  // ((cAliasCD2)->VALICMS)
            SD2->D2_BASIMP5 // (cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS//((cAliasCD2)->TOTAL - ((cAliasCD2)->DESCONTO))
            SD2->D2_BASIMP6 //  (cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS//((cAliasCD2)->TOTAL - ((cAliasCD2)->DESCONTO))
            SD2->D2_VALIMP5 // ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS)*0.0760
            SD2->D2_VALIMP6 // ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS)*0.0165

            /////////////////////////////////////////////////////////////////////////////////////////////////
            //AJUSTE NO CD2
            DbSelectArea("CD2")
            DbSetOrder(1)
            DbGotop()
            IF DbSeek(xFilial("CD2")+'S'+(cAliasCD2)->D2_SERIE+(cAliasCD2)->D2_DOC+(cAliasCD2)->D2_CLIENTE+(cAliasCD2)->D2_LOJA+(cAliasCD2)->D2_ITEM+'  '+(cAliasCD2)->D2_COD+'ICM   ')

                If SD2->D2_ITEM  = "01"
                    CD2->CD2_BC // IIF((cAliasCD2)->VALICMS>0,(cAliasCD2)->VALBRUT,0) ///(SD2->D2_BASEICM - 0.01) // ((cAliasCD2)->TOTAL - (cAliasCD2)->DESCONTO) - ((cAliasCD2)->DIF)
                Else
                    CD2->CD2_BC // IIF((cAliasCD2)->VALICMS>0,(cAliasCD2)->VALBRUT,0) ///(cAliasCD2)->DIFICM  //SD2->D2_BASEICM //(((cAliasCD2)->TOTAL - (cAliasCD2)->DESCONTO)) - ((cAliasCD2)->DIF)
                EndIf
                CD2->CD2_VLTRIB // ((cAliasCD2)->VALICMS)

            ENDIF
            IF DbSeek(xFilial("CD2")+'S'+(cAliasCD2)->D2_SERIE+(cAliasCD2)->D2_DOC+(cAliasCD2)->D2_CLIENTE+(cAliasCD2)->D2_LOJA+(cAliasCD2)->D2_ITEM+'  '+(cAliasCD2)->D2_COD+'PS2   ')

                CD2->CD2_BC //  ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS) ///((cAliasCD2)->TOTAL - ((cAliasCD2)->DESCONTO))
                CD2->CD2_VLTRIB // ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS)*0.0165

            ENDIF
            IF DbSeek(xFilial("CD2")+'S'+(cAliasCD2)->D2_SERIE+(cAliasCD2)->D2_DOC+(cAliasCD2)->D2_CLIENTE+(cAliasCD2)->D2_LOJA+(cAliasCD2)->D2_ITEM+'  '+(cAliasCD2)->D2_COD+'CF2   ')

                CD2->CD2_BC // ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS) ///((cAliasCD2)->TOTAL - ((cAliasCD2)->DESCONTO))
                CD2->CD2_VLTRIB // ((cAliasCD2)->VALBRUT- (cAliasCD2)->VALICMS)*0.0760

            ENDIF

            /////////////////////////////////////////////////////////////////////////////////////////////////

        ENDIF

        (cAliasCD2)->(DBSKIP())
    ENDDO

    RpcCLearEnv()

Return
