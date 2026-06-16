#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1513
    Função para integrar a COR no WMS.
    @type function
    @author Daniel Victor da Rosa
    @since 09/03/2026
/*/
User Function BUD1513(lIncDel)

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/CorProduto"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""
    Default lIncDel     := .F.
    Default lSucIntC    := .F.

    If IsBlind()
        RPCSETENV("01","01")
    EndIf

    oAuth := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    IF !lIncDel

        //Ver qual vai ser o campo de controle
        cQuery := " SELECT * FROM "+RETSQLNAME("SZT")+ " (NOLOCK) "
        cQuery += " WHERE D_E_L_E_T_ = ' ' "
        cQuery += " AND ZT_INTWMS = ' ' "

        If Select("QRY_SZT") > 0
            QRY_SZT->(DbCloseArea())
        EndIf

        QRY_SZT := GETNEXTALIAS()

        MPSysOpenQuery(cQuery, QRY_SZT)

        While (QRY_SZT)->(!Eof())

            oJsonRequest["codigoCorErp"]     :=  AllTrim((QRY_SZT)->ZT_COD)
            oJsonRequest["descricao"]   :=  AllTrim((QRY_SZT)->ZT_DESCRI)
            oRest:SetPostParams( "[" + oJsonRequest:ToJson() + "]" )
            oRest:Post(aHeader)

            cJsonRet := oRest:GetResult()
            cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
            oJsonRet:FromJson(cJsonRet)

            IF oJsonRet["badRequest"] == .T.
                oLogger:Gravar(PDALogEntry():New("SZT", "Cor", (QRY_SZT)->ZT_COD+(QRY_SZT)->ZT_CODCOR, "Erro ao integrar cor no WMS cod: "+(QRY_SZT)->ZT_COD+" desc: "+(QRY_SZT)->ZT_DESCRI))
            else
                oLogger:Gravar(PDALogEntry():New("SZT", "Cor", (QRY_SZT)->ZT_COD+(QRY_SZT)->ZT_CODCOR, "Sucesso ao integrar cor no WMS cod: "+(QRY_SZT)->ZT_COD+" desc: "+(QRY_SZT)->ZT_DESCRI))
            EndIf
            (QRY_SZT)->(DbSkip())

        End

    else

        oJsonRequest["codigoCorErp"]     :=  AllTrim(M->ZT_COD)
        oJsonRequest["descricao"]   :=  AllTrim(M->ZT_DESCRI)
        oRest:SetPostParams( "[" + oJsonRequest:ToJson() + "]" )
        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        IF cJsonRet == "true"
            oLogger:Gravar(PDALogEntry():New("SZT", "Cor", M->ZT_COD+M->ZT_CODCOR, "Erro ao integrar cor no WMS cod: "+M->ZT_COD+" desc: "+M->ZT_DESCRI))
            lSucIntC := .T.
        else
            oLogger:Gravar(PDALogEntry():New("SZT", "Cor", M->ZT_COD+M->ZT_CODCOR, "Sucesso ao integrar cor no WMS cod: "+M->ZT_COD+" desc: "+M->ZT_DESCRI))
            lSucIntC := .F.
        EndIf


    EndIf

    If IsBlind()
        RpcCLearEnv()
    EndIf

Return .T.
