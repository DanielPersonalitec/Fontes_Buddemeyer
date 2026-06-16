#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1511
    Função para integrar a transportadora no WMS.
    @type function
    @author Daniel Victor da Rosa
    @since 04/03/2026
    @version 1.1 - 05/03/2026 - Adicionada validacao de campos obrigatorios
/*/
User Function BUD1511(lM050Z)

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Transportadora"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""
    Local nTotal        := 0
    Local nProcessados  := 0
    Local nIgnorados    := 0
    Local nErros        := 0
    Local cCod          := ""
    Local cNome         := ""
    default lM050Z      := .F.
    default lJob        := .F.

    If IsBlind()
        RPCSETENV("01","01")
        lJob := .T.
    EndIf

    oAuth := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    IF !lM050Z

        cQuery := " SELECT A4_COD, A4_NOME, R_E_C_N_O_ AS REC "
        cQuery += " FROM " + RETSQLNAME('SA4') + " SA4 (NOLOCK) "
        cQuery += " WHERE SA4.D_E_L_E_T_ = ' ' "
        //cQuery += " AND A4_INTWMS = ' ' "

        If Select("QRY_SA4") > 0
            QRY_SA4->(DbCloseArea())
        EndIf

        QRY_SA4 := GETNEXTALIAS()

        MPSysOpenQuery(cQuery, QRY_SA4)

        While (QRY_SA4)->(!Eof())

            nTotal++

            cCod  := AllTrim((QRY_SA4)->A4_COD)
            cNome := AllTrim((QRY_SA4)->A4_NOME)

            // validacao dos campos obrigatorios (seguranca adicional ao filtro SQL)
            If Empty(cCod) .Or. Empty(cNome)
                nIgnorados++
                oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                    "Ignorado - Campo obrigatorio vazio: cod=[" + cCod + "] nome=[" + cNome + "]"))
                (QRY_SA4)->(DbSkip())
                Loop
            EndIf

            oJsonRequest["codigoTransportadora"] := cCod
            oJsonRequest["descricao"]            := cNome
            oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")
            oRest:Post(aHeader)
            cJsonRet := oRest:GetResult()

            If !Empty(cJsonRet)
                cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
                oJsonRet:FromJson(cJsonRet)
            EndIf

            SA4->(DbSetOrder(1))
            SA4->(DBGoTo((QRY_SA4)->REC))

            IF !Empty(cJsonRet) .And. oJsonRet["badRequest"] == .T.
                nErros++
                oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                    "Erro ao integrar transportadora no WMS cod: " + cCod + " desc: " + cNome))
                If AllTrim(SA4->A4_COD) == cCod
                    SA4->(Reclock("SA4",.F.))
                    SA4->A4_INTWMS := "E"
                    SA4->(MsUnLock())
                EndIf
            Else
                nProcessados++
                oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                    "Inclusao - Transportadora integrada com sucesso: " + cCod + " - " + cNome))
                If AllTrim(SA4->A4_COD) == cCod
                    SA4->(Reclock("SA4",.F.))
                    SA4->A4_INTWMS := "S"
                    SA4->(MsUnLock())
                EndIf
            EndIf
            cJsonRet := ""
            (QRY_SA4)->(DbSkip())
        End

        If Select("QRY_SA4") > 0
            QRY_SA4->(DbCloseArea())
        EndIf

    Else

        cCod  := AllTrim(M->A4_COD)
        cNome := AllTrim(M->A4_NOME)

        // validacao dos campos obrigatorios (seguranca adicional ao filtro SQL)
        If Empty(cCod) .Or. Empty(cNome)
            nIgnorados++
            oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                "Ignorado - Campo obrigatorio vazio: cod=[" + cCod + "] nome=[" + cNome + "]"))
        EndIf

        oJsonRequest["codigoTransportadora"] := cCod
        oJsonRequest["descricao"]            := cNome
        oRest:SetPostParams("[" + oJsonRequest:ToJson() + "]")
        oRest:Post(aHeader)
        cJsonRet := oRest:GetResult()

        If !Empty(cJsonRet)
            cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
            oJsonRet:FromJson(cJsonRet)
        EndIf

        IF cJsonRet <> "true"
            oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                "Erro ao integrar/alterar transportadora no WMS cod: " + cCod + " desc: " + cNome))
            lSuces := .F.
        Else
            oLogger:Gravar(PDALogEntry():New("SA4", "Transportadora", cCod, ;
                "Inclusao - Transportadora integrada/alterada com sucesso: " + cCod + " - " + cNome))
            lSuces := .T.
        EndIf
        nTotal := 1
    EndIf


    If lJob
        RpcCLearEnv()
    EndIf

Return .T.
