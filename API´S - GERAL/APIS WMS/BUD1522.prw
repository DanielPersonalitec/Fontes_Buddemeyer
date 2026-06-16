#include "protheus.ch"
#include "totvs.ch"

/*
/==================================================================================\
|Nome              : Realizado o envio tracking Protheus X PDA                     |
|==================================================================================|
|Descricao         : Envia os dados do Protheus para o WMS                         |
|==================================================================================|
|Autor             : Daniel Victor da Rosa - Personalitec                          |
|==================================================================================|
|Data de Criacao   : 16/03/2026                                                    |
\==================================================================================/
*/
User Function BUD1522()

    Local oRest         := FwRest():New("https://stg.api.pdahub.com.br")
    Local cPath         := "/api/Integration/tracking-gaiola"
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
    cQuery := " SELECT * FROM "+RETSQLNAME("ZDT")+ " (NOLOCK) "
    cQuery += " WHERE D_E_L_E_T_ = ' ' "
    //Deixado comentado pois existem poucos registros. e como é gaiolas, integrar todas toda vez que rodar.
    //cQuery += " AND ZDT_INTWMS = ' ' "

    If Select("QRY_ZDT") > 0
        QRY_ZDT->(DbCloseArea())
    EndIf

    QRY_ZDT := GETNEXTALIAS()

    MPSysOpenQuery(cQuery, QRY_ZDT)

    While (QRY_ZDT)->(!Eof())

        oJsonRequest["Codigo"]     :=  AllTrim((QRY_ZDT)->ZDT_CODIGO)
        oJsonRequest["Status"]   :=  AllTrim((QRY_ZDT)->ZDT_STATUS)
        oJsonRequest["Local"]   :=  AllTrim((QRY_ZDT)->ZDT_LOCFIS)

        oRest:Put(aHeader,"[" + oJsonRequest:ToJson() + "]" )

        cJsonRet := oRest:GetResult()
        cJsonRet := EncodeUTF8(cJsonRet, "cp1252")
        oJsonRet:FromJson(cJsonRet)

        IF !(EMPTY(oJsonRet[1]['erro']))
            oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola Tracking", (QRY_ZDT)->ZDT_CODIGO, "Erro ao atualizar status da gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
        else
            oLogger:Gravar(PDALogEntry():New("SZT", "Gaiola Tracking", (QRY_ZDT)->ZDT_CODIGO, "Sucesso ao atualizar status da gaiola no WMS cod: "+(QRY_ZDT)->ZDT_CODIGO+" desc: "+(QRY_ZDT)->ZDT_STATUS))
        EndIf
        (QRY_ZDT)->(DbSkip())
    End

    If IsBlind()
        RpcCClearEnv()
    EndIf

Return
