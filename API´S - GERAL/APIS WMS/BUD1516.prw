#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1516
    Função para integrar gaiolas no WMS.
    @type function
    @author Daniel Victor da Rosa
    @since 10/03/2026
/*/
User Function BUD1516(lAtuaPDA,cCodGau,cAcao,cStaGai,cLocGai)

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/gaiola"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""
    Default lAtuaPDA    := .F.
    Default cCodGau     := ""
    Default cAcao       := ""
    Default cStaGai     := ""
    Default cLocGai     := ""

    If IsBlind()
        RPCSETENV("01","01")
    EndIf

    oAuth   := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    IF !lAtuaPDA

        //Ver qual vai ser o campo de controle
        cQuery := " SELECT R_E_C_N_O_ AS REC, * FROM "+RETSQLNAME("ZDT")+ " (NOLOCK) "
        cQuery += " WHERE D_E_L_E_T_ = ' ' "
        cQuery += " AND ZDT_INTWMS = ' ' "

        If Select("QRY_ZDT") > 0
            QRY_ZDT->(DbCloseArea())
        EndIf

        QRY_ZDT := GETNEXTALIAS()

        MPSysOpenQuery(cQuery, QRY_ZDT)
        ZDT->(DBSetOrder(1))

        While (QRY_ZDT)->(!Eof())

            oJsonRequest["Codigo"]     :=  AllTrim((QRY_ZDT)->ZDT_CODIGO)
            oJsonRequest["Status"]   :=  AllTrim((QRY_ZDT)->ZDT_STATUS)
            oJsonRequest["Peso"]   :=  (QRY_ZDT)->ZDT_PESO
            oJsonRequest["Local"]   :=  AllTrim((QRY_ZDT)->ZDT_LOCFIS)
            oJsonRequest["Altura"]   :=  (QRY_ZDT)->ZDT_HALT
            oJsonRequest["Largura"]   :=  (QRY_ZDT)->ZDT_LLARG
            oJsonRequest["Comprimento"]   :=  (QRY_ZDT)->ZDT_CCOM

            oRest:SetPostParams( "[" + oJsonRequest:ToJson() + "]" )
            oRest:Post(aHeader)

            cJsonRet := oRest:GetResult()
            cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
            oJsonRet:FromJson(cJsonRet)

            IF oJsonRet["badRequest"] == .T.
                oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola", (QRY_ZDT)->ZDT_CODIGO, "Erro ao integrar gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
                ZDT->(DBGOTO((QRY_ZDT)->REC))
                IF ZDT->ZDT_CODIGO == (QRY_ZDT)->ZDT_CODIGO
                    Reclock("ZDT", .F.)
                    ZDT->ZDT_INTWMS := "E"
                    ZDT->(MSUNLOCK())
                EndIf
            else
                oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola", (QRY_ZDT)->ZDT_CODIGO, "Sucesso ao integrar gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
                ZDT->(DBGOTO((QRY_ZDT)->REC))
                IF ZDT->ZDT_CODIGO == (QRY_ZDT)->ZDT_CODIGO
                    Reclock("ZDT", .F.)
                    ZDT->ZDT_INTWMS := "S"
                    ZDT->(MSUNLOCK())
                EndIf
            EndIf
            (QRY_ZDT)->(DbSkip())
        End

    else

        IF !Empty(cCodGau)
            cQuery := " SELECT R_E_C_N_O_ AS REC, * FROM "+RETSQLNAME("ZDT")+ " (NOLOCK) "
            cQuery += " WHERE D_E_L_E_T_ = ' ' "
            cQuery += " AND ZDT_CODIGO = '"+AllTrim(cCodGau)+"' "
            cQuery += " AND ZDT_FILIAL = '' "

            If Select("QRY_ZDT") > 0
                QRY_ZDT->(DbCloseArea())
            EndIf

            QRY_ZDT := GETNEXTALIAS()

            MPSysOpenQuery(cQuery, QRY_ZDT)
            ZDT->(DBSetOrder(1))

            IF  (QRY_ZDT)->(!Eof())

                oJsonRequest["Codigo"]     :=  AllTrim((QRY_ZDT)->ZDT_CODIGO)
                oJsonRequest["Status"]   :=  AllTrim(cStaGai)
                oJsonRequest["Peso"]   :=  (QRY_ZDT)->ZDT_PESO
                IF !Empty(cLocGai)
                    oJsonRequest["Local"]   :=  AllTrim(cLocGai)
                Else
                    oJsonRequest["Local"]   :=  AllTrim((QRY_ZDT)->ZDT_LOCFIS)
                EndIf
                oJsonRequest["Altura"]   :=  (QRY_ZDT)->ZDT_HALT
                oJsonRequest["Largura"]   :=  (QRY_ZDT)->ZDT_LLARG
                oJsonRequest["Comprimento"]   :=  (QRY_ZDT)->ZDT_CCOM
                oRest:SetPostParams( "[" + oJsonRequest:ToJson() + "]" )
                oRest:Post(aHeader)

                cJsonRet := oRest:GetResult()
                cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
                oJsonRet:FromJson(cJsonRet)

                IF oJsonRet["badRequest"] == .T.
                    oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola", (QRY_ZDT)->ZDT_CODIGO, "Erro ao integrar/atualizar gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
                    ZDT->(DBGOTO((QRY_ZDT)->REC))
                    IF ZDT->ZDT_CODIGO == (QRY_ZDT)->ZDT_CODIGO
                        Reclock("ZDT", .F.)
                        ZDT->ZDT_INTWMS := "E"
                        ZDT->(MSUNLOCK())
                    EndIf
                else
                    oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola", (QRY_ZDT)->ZDT_CODIGO, "Sucesso ao integrar/ atualizar gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
                    ZDT->(DBGOTO((QRY_ZDT)->REC))
                    IF ZDT->ZDT_CODIGO == (QRY_ZDT)->ZDT_CODIGO
                        Reclock("ZDT", .F.)
                        IF cAcao == "A"
                            ZDT->ZDT_INTWMS := "A"
                        Else
                            ZDT->ZDT_INTWMS := "S"
                        EndIf
                        ZDT->(MSUNLOCK())
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    If IsBlind()
        RpcCLearEnv()
    EndIf

Return .T.
