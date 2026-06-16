#Include 'TOTVS.CH'

User Function TstIdTSS(aParam)

    //RpcSetEnv("06", aParam[2])

    Local cIdent    := ""
    Local cQuerZy   := ""
    Local cAliaZy   := ""

    SF2->(DBSetOrder(1))

    cIdent := RetIdEnti()
    cIdent2 := getCfgEntidade()

    cQuerZy := " SELECT SPEZ.DOC_CHV AS CHV, NFE_ID, F2_CLIENTE , F2_LOJA , F2_NOMCLIE , ID_ENT , F2_DOC , F2_SERIE FROM "+RETSQLNAME('SF2')+" s "
    cQuerZy += " INNER JOIN SPED050 SPEZ ON s.F2_SERIE = LTRIM(RTRIM(LEFT(SPEZ.NFE_ID, 3))) AND s.F2_DOC = RIGHT(LTRIM(RTRIM(SPEZ.NFE_ID)), 6) "
    cQuerZy += " AND SPEZ.D_E_L_E_T_ = ' ' "
    cQuerZy += " WHERE  s.D_E_L_E_T_  = ' ' "
    cQuerZy += " AND F2_CHVNFE = ' ' "
    cQuerZy += " AND SPEZ.ID_ENT = " +ValtoSql(cIdent)
    cQuerZy += " AND F2_ESPECIE  = 'SPED' "
    cQuerZy += " AND SPEZ.DATE_NFE > '20250801' " // = " +ValtoSql(DTOS(Date()))
    cQuerZy += " GROUP BY SPEZ.DOC_CHV, NFE_ID, F2_CLIENTE , F2_LOJA , F2_NOMCLIE , ID_ENT , F2_DOC , F2_SERIE "

    cAliaZy := GetNextAlias()

    MPSysOpenQuery(cQuerZy, cAliaZy)

    While (cAliaZy)->(!EOF())

        //cDoc55+cSerie55+cCodCli55+cCodLoj55
        IF SF2->(DBSEEK(xFilial('SF2')+(cAliaZy)->F2_DOC+(cAliaZy)->F2_SERIE+(cAliaZy)->F2_CLIENTE+(cAliaZy)->F2_LOJA))
            RECLOCK('SF2',.F.)
            SF2->F2_CHVNFE := (cAliaZy)->CHV
            SF2->(MSUNLOCK())
        ENDIF
        (cAliaZy)->(DbSkip())
    EndDo

    //RpcClearEnv()

Return
