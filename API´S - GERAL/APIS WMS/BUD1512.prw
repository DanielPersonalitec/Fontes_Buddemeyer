#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD1512
    Função para integrar a filial no WMS.
    @type function
    @author Daniel Victor da Rosa
    @since 09/03/2026
/*/
User Function BUD1512()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/Filiais"
    Local aHeader       := {}
    Local oJsonRequest  := JsonObject():New()
    Local oJsonRet      := JsonObject():New()
    Local oLogger       := PDALogger():New()
    Local cJsonRet      := ""

    If IsBlind()
        RPCSETENV("01","01")
    EndIf

    oAuth := PDAAuthLogin():New()
    aHeader := oAuth:GetHeader()

    oRest:SetPath(cPath)

    //Ver qual vai ser o campo de controle
    cQuery := " SELECT * FROM SYS_COMPANY (NOLOCK) "
    cQuery += " WHERE SYS_COMPANY.D_E_L_E_T_ = ' ' "

    If Select("QRY_SYS") > 0
        QRY_SYS->(DbCloseArea())
    EndIf

    QRY_SYS := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_SYS)

    While (QRY_SYS)->(!Eof())

        oJsonRequest["codigoFilial"]     :=  AllTrim((QRY_SYS)->M0_CODIGO)
        oJsonRequest["cnpj"]   :=  AllTrim((QRY_SYS)->M0_CGC)
        oJsonRequest["descricao"]   :=  AllTrim((QRY_SYS)->M0_FILIAL)
        oJsonRequest["tipoFilial"]   :=  AllTrim(IIF(AllTrim((QRY_SYS)->M0_CODIGO) == "01", "1", "0"))

        oRest:SetPostParams( "[" + oJsonRequest:ToJson() + "]" )

        oRest:Post(aHeader)

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        IF oJsonRet["badRequest"] == .T.
            oLogger:Gravar(PDALogEntry():New("SYS_COMPANY", "Filial", (QRY_SYS)->M0_CODIGO, "Erro ao integrar filial no WMS cod: "+(QRY_SYS)->M0_CODIGO+" desc: "+(QRY_SYS)->M0_FILIAL))
        else
            oLogger:Gravar(PDALogEntry():New("SYS_COMPANY", "Filial", (QRY_SYS)->M0_CODIGO, "Sucesso ao integrar filial no WMS cod: "+(QRY_SYS)->M0_CODIGO+" desc: "+(QRY_SYS)->M0_FILIAL))
        EndIf
        (QRY_SYS)->(DbSkip())
    End

    If IsBlind()
        RpcCLearEnv()
    EndIf

Return .T.
