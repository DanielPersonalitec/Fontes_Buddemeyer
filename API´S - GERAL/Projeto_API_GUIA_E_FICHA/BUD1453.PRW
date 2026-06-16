#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FWMVCDEF.CH"
#Include 'Protheus.ch'
#Include 'parmtype.ch'

/*
/=========================================================================\
| Modulo      : ApiRest                                                   |
|=========================================================================|
| Programa    : BUD1453.PRW   | Resposavel: Joao Gebauer		      	  |
|=========================================================================|
| Descricao   : update/insert/get estruturas dos produtos			 	  |
|=========================================================================|
| Data        : 22/10/2024 						                          |
|=========================================================================|
| Programador : Joao Gebauer          	                                  |
\=========================================================================/
*/


WSRESTFUL wsestruturas DESCRIPTION "update/insert/get estruturas dos produtos"

    WSDATA codproduto    AS String
    WSDATA codcomponente AS String
    WSDATA cnumquery     AS String
    WSDATA cvalue        AS String

    ::SetContentType("application/json")
    ::SetHeader('Access-Control-Allow-Credentials', "true")

    WSMETHOD POST DESCRIPTION "update/insert estruturas dos produtos" PATH "/wsestruturas/upsert";
        TTALK "v1";
        WSSYNTAX "/wsestruturas/upsert"

    WSMETHOD GET DESCRIPTION "get estruturas dos produtos" PATH "/wsestruturas/consultar/{cnumquery}";
        TTALK "v1";
        WSSYNTAX "/wsestruturas/consultar/{cnumquery}?codproduto={codproduto}&codcomponente={codcomponente}&cvalue={cvalue}"

END WSRESTFUL

/*
/==================================================================================\
|Nome              : POST wsestruturas                                             |
|==================================================================================|
|Descricao         : Recebe JSON e executa operacoes de geracao/remocao de         |
|                    estruturas (SG1) e roteiros de operacoes (SG2)                |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 22/10/2024                                                    |
\==================================================================================/
*/
WSMETHOD POST WSSERVICE wsestruturas
    Local cBody       := ::GetContent()
    Local oEstruturas
    Local cOperacao   := ""
    Local nX          := 1
    Local aCab        := {}
    Local aEstruturas := {}

    Private cFuncaoPai       := "BUD1453"
    Private PrivalMsHelpAuto := .T.
    Private lMsErroAuto      := .F.
    Private lAutoErrNoFile   := .T.

    FWJsonDeserialize(DecodeUtf8(cBody), @oEstruturas)

    aEstruturas := oEstruturas:fwestruturas
    cCod        := oEstruturas:fwcod

    oJson     := JsonObject():New()
    oJsonItem := JsonObject():New()

    oJson["retorno"] := {}

    If Empty(aEstruturas)
        oJsonItem['code']    := 1
        oJsonItem['message'] := EncodeUtf8("Nao foi informado as estruturas a serem geradas, favor verificar!")
        ConOut("[API ESTRUTURAS] - ERRO 001 - Nao foi informado as estruturas a serem geradas - " + DtoC(MsDate()) + " - " + Time() + "!")

    ElseIf Empty(cCod)
        oJsonItem['code']    := 2
        oJsonItem['message'] := EncodeUtf8("Nao foi informado o produto, favor verificar!")
        ConOut("[API ESTRUTURAS] - ERRO 002 - Nao foi informado o produto - " + DtoC(MsDate()) + " - " + Time() + "!")

    Else
        DbSelectArea("SB1")
        DbSetOrder(1)
        If DbSeek(xFilial("SB1") + cCod)
            aCab := {{"G1_COD",    cCod, NIL},;
                {"G1_QUANT",  1,    NIL},;
                {"ATUREVSB1", "N",  NIL},;
                {"NIVALT",    "S",  NIL}}

            For nX := 1 To Len(aEstruturas)
                cOperacao := aEstruturas[nX]:fwoperacao

                If cOperacao == "GERAR SG1"
                    B1453SG1Gerar(aCab, aEstruturas[nX]:fwcomp)

                ElseIf cOperacao == "GERAR SG2"
                    B1453SG2Gerar(cCod, aEstruturas[nX]:fwcomp)

                ElseIf cOperacao == "DELETAR SG1"
                    B1453SG1Del(aCab)

                ElseIf cOperacao == "DELETAR SG2"
                    B1453SG2Del(aCab)

                Else
                    oJsonItem['code']    := 4
                    oJsonItem['message'] := EncodeUtf8("A operacao informada e invalida, favor verificar!")
                    ConOut("[API ESTRUTURAS] - ERRO 004 - A operacao informada e invalida - " + DtoC(MsDate()) + " - " + Time() + "!")
                EndIf
            Next nX
        Else
            oJsonItem['code']    := 3
            oJsonItem['message'] := EncodeUtf8("O produto acabado: " + cCod + " nao foi encontrado na tabela de produtos, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 003 - O produto acabado: " + cCod + " nao foi encontrado na tabela de produtos - " + DtoC(MsDate()) + " - " + Time() + "!")
        EndIf
    EndIf

    AAdd(oJson["retorno"], oJsonItem)
    ::SetResponse(EncodeUtf8(oJson:toJson()))
Return .T.

/*
/==================================================================================\
|Nome              : GET wsestruturas                                              |
|==================================================================================|
|Descricao         : Consulta estruturas de produtos via queries parametrizadas    |
|==================================================================================|
|Autor             : Daniel Victor Rosa / Eduardo Dalitz - Personalitec            |
|==================================================================================|
|Data de Criacao   : 08/12/2025                                                    |
\==================================================================================/
*/
WSMETHOD GET WSSERVICE wsestruturas

    Local nTotal      := 0
    Private jBody     := JsonObject():New()
    Private jJsonItem := JsonObject():New()
    Private oRetorno  := JsonObject():New()
    Private aRetValid := {}

    oRetorno["code"]    := 0
    oRetorno["message"] := ""
    oRetorno["retorno"] := {}

    If ValidaJsonSG1(::codproduto, ::codcomponente, ::cnumquery)

        If Select("cAliasSG1") > 0
            cAliasSG1->(DbCloseArea())
        EndIf

        cAliasSG1 := GetNextAlias()
        cQuerySG1 := DadosSG1(::codproduto, ::codcomponente, ::cnumquery, ::cvalue)

        If !Empty(cQuerySG1)
            MPSysOpenQuery(cQuerySG1, cAliasSG1)

            While (cAliasSG1)->(!EOF())
                jJsonItem := JsonObject():New()

                Do Case
                    Case ::cnumquery == "1"
                        jJsonItem['SG1_COD']  := AllTrim((cAliasSG1)->G1_COD)
                        jJsonItem['SG1_COMP'] := AllTrim((cAliasSG1)->G1_COMP)
                        jJsonItem['SB1_DESC'] := AllTrim((cAliasSG1)->B1_DESC)
                    Case ::cnumquery == "2"
                        jJsonItem['SG1_COD']  := AllTrim((cAliasSG1)->G1_COD)
                        jJsonItem['SG1_COMP'] := AllTrim((cAliasSG1)->G1_COMP)
                        jJsonItem['SG1_QUANT']:= (cAliasSG1)->G1_QUANT
                    Case ::cnumquery == "3"
                        jJsonItem['SG1_COD']  := AllTrim((cAliasSG1)->G1_COD)
                        jJsonItem['SG1_COMP'] := AllTrim((cAliasSG1)->G1_COMP)
                        jJsonItem['SG1_QUANT']:= (cAliasSG1)->G1_QUANT
                    Case ::cnumquery $ "4|6"
                        jJsonItem['SB1_DESC']  := AllTrim((cAliasSG1)->B1_DESC)
                        jJsonItem['SB1_GRUPO'] := AllTrim((cAliasSG1)->TIPO)
                        jJsonItem['SG1_QUANT'] := (cAliasSG1)->G1_QUANT
                        jJsonItem['SG1_PERDA'] := (cAliasSG1)->G1_PERDA
                        jJsonItem['SG1_COMP']  := AllTrim((cAliasSG1)->G1_COMP)
                    Case ::cnumquery == "5"
                        jJsonItem['SB1_COD']   := AllTrim((cAliasSG1)->B1_COD)
                        jJsonItem['SB1_DESC']  := AllTrim((cAliasSG1)->B1_DESC)
                        jJsonItem['SG1_QUANT'] := (cAliasSG1)->G1_QUANT
                        jJsonItem['SG1_PERDA'] := (cAliasSG1)->G1_PERDA
                EndCase

                AAdd(oRetorno["retorno"], jJsonItem)
                (cAliasSG1)->(DbSkip())
            End

            (cAliasSG1)->(DbCloseArea())
        EndIf

        If Len(oRetorno["retorno"]) == 0
            oRetorno["code"]    := 5
            oRetorno["message"] := "Nenhum registro foi encontrado."
        Else
            nTotal              := Len(oRetorno["retorno"])
            oRetorno["code"]    := 200
            oRetorno["message"] := cValToChar(nTotal) + " " + ;
                If(nTotal == 1, "registro encontrado.", "registros encontrados.")
        EndIf
    EndIf

    Self:SetContentType('application/json')
    Self:SetResponse(EncodeUTF8(oRetorno:toJSON()))
Return .T.

/*
/==================================================================================\
|Nome              : TxtErro                                                       |
|==================================================================================|
|Descricao         : Concatena as mensagens do log de erro automatico              |
\==================================================================================/
*/
Static Function TxtErro(aAutoErro)
    Local cRet := ""
    Local nX   := 1
    For nX := 1 To Len(aAutoErro)
        cRet += AllTrim(aAutoErro[nX]) + Chr(13) + Chr(10)
    Next nX
Return cRet

/*
/==================================================================================\
|Nome              : B1453SG1Gerar                                                 |
|==================================================================================|
|Descricao         : Gera as estruturas do produto (SG1) via MSExecAuto/PCPA200    |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 22/10/2024                                                    |
\==================================================================================/
*/
Static Function B1453SG1Gerar(aCab, _comp)
    Local aGets  := {}
    Local aBody  := {}
    Local cComp  := ""
    Local nQuant := 0
    Local nPerda := 0
    Local nX     := 1
    Local lPost  := .T.

    For nX := 1 To Len(_comp)
        cComp  := _comp[nX]:fwcodcomp
        nQuant := _comp[nX]:fwquant
        nPerda := _comp[nX]:fwperda

        If Empty(cComp)
            oJsonItem['code']    := 5
            oJsonItem['message'] := EncodeUtf8("Ocorreu um erro no " + Str(nX) + " componente, pois nao foi informado o codigo do componente, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 005 - Codigo do componente nao informado no item " + Str(nX) + " - " + DtoC(MsDate()) + " - " + Time() + "!")

        ElseIf Empty(nQuant)
            oJsonItem['code']    := 6
            oJsonItem['message'] := EncodeUtf8("Ocorreu um erro no " + Str(nX) + " componente, pois nao foi informado a quantidade do componente, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 006 - Quantidade do componente nao informada no item " + Str(nX) + " - " + DtoC(MsDate()) + " - " + Time() + "!")

        Else
            DbSelectArea("SB1")
            DbSetOrder(1)
            If DbSeek(xFilial("SB1") + cComp)
                aGets := {}
                AAdd(aGets, {"G1_COD",     aCab[1][2],         NIL})
                AAdd(aGets, {"G1_COMP",    cComp,              NIL})
                AAdd(aGets, {"G1_QUANT",   nQuant,             NIL})
                AAdd(aGets, {"G1_PERDA",   nPerda,             NIL})
                AAdd(aGets, {"G1_NIV",     "01",               NIL})
                AAdd(aGets, {"G1_OBSERV",  "",                 NIL})
                AAdd(aGets, {"G1_FIXVAR",  "V",                NIL})
                AAdd(aGets, {"G1_NIVINV",  "99",               NIL})
                AAdd(aGets, {"G1_REVFIM",  "ZZZ",              NIL})
                AAdd(aGets, {"G1_POTENCI", 0,                  NIL})
                AAdd(aGets, {"G1_VLCOMPE", "N",                NIL})
                AAdd(aGets, {"G1_INI",     dDataBase,          NIL})
                AAdd(aGets, {"G1_FIM",     CtoD("31/01/2045"), NIL})
                AAdd(aBody, aGets)
            Else
                lPost := .F.
                oJsonItem['code']    := 7
                oJsonItem['message'] := EncodeUtf8("O componente: " + cComp + " nao foi encontrado na tabela de produtos, favor verificar!")
                ConOut("[API ESTRUTURAS] - ERRO 007 - Componente: " + cComp + " nao encontrado - " + DtoC(MsDate()) + " - " + Time() + "!")
            EndIf
        EndIf
    Next nX

    If !Empty(aCab) .And. !Empty(aBody) .And. lPost
        lMsHelpAuto    := .T.
        lMsErroAuto    := .F.
        lAutoErrNoFile := .T.

        MSExecAuto({|x,y,z| PCPA200(x,y,z)}, aCab, aBody, 3)

        If lMsErroAuto
            aAutoErro := GETAUTOGRLOG()
            cRetorno  := TXTERRO(aAutoErro)
            oJsonItem['code']    := 8
            oJsonItem['message'] := EncodeUtf8(cRetorno)
            ConOut("[API ESTRUTURAS] - ERRO 008 - " + cRetorno)
        Else
            oJsonItem['code']    := 200
            oJsonItem['message'] := EncodeUtf8("Estrutura gerada com sucesso!")
            ConOut("[API ESTRUTURAS] - SUCESSO - Estrutura gerada com sucesso!")
        EndIf
    EndIf
Return

/*
/==================================================================================\
|Nome              : B1453SG2Gerar                                                 |
|==================================================================================|
|Descricao         : Gera os roteiros de operacoes do produto (SG2)                |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 22/10/2024                                                    |
\==================================================================================/
*/
Static Function B1453SG2Gerar(_produto, _comp)
    Local cRecurso := ""
    Local cDescri  := ""
    Local cOperzzv := ""
    Local cOperac  := ""
    Local nMaoobra := 0
    Local nLotepad := 0
    Local nX       := 1
    Local nY       := 1

    For nX := 1 To Len(_comp)
        cRecurso := AllTrim(_comp[nX]:fwrecurso)
        cDescri  := AllTrim(_comp[nX]:fwdescri)
        nMaoobra := _comp[nX]:fwmaoobra
        nLotepad := _comp[nX]:fwlotepad
        cOperzzv := AllTrim(_comp[nX]:fwoperzzv)
        cOperac  := PadL(cValToChar(nY), 2, "0")

        If Empty(cRecurso)
            oJsonItem['code']    := 10
            oJsonItem['message'] := EncodeUtf8("Nao foi informado o recurso da estrutura, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 010 - Recurso nao informado - " + DtoC(MsDate()) + " - " + Time() + "!")

        ElseIf Empty(cDescri)
            oJsonItem['code']    := 11
            oJsonItem['message'] := EncodeUtf8("Nao foi informado a descricao da estrutura, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 011 - Descricao nao informada - " + DtoC(MsDate()) + " - " + Time() + "!")

        ElseIf Empty(nMaoobra)
            oJsonItem['code']    := 12
            oJsonItem['message'] := EncodeUtf8("Nao foi informado a mao de obra da estrutura, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 012 - Mao de obra nao informada - " + DtoC(MsDate()) + " - " + Time() + "!")

        ElseIf Empty(nLotepad)
            oJsonItem['code']    := 13
            oJsonItem['message'] := EncodeUtf8("Nao foi informado o lote da estrutura, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 013 - Lote nao informado - " + DtoC(MsDate()) + " - " + Time() + "!")

        ElseIf Empty(cOperzzv)
            oJsonItem['code']    := 14
            oJsonItem['message'] := EncodeUtf8("Nao foi informado o operador da estrutura, favor verificar!")
            ConOut("[API ESTRUTURAS] - ERRO 014 - Operador nao informado - " + DtoC(MsDate()) + " - " + Time() + "!")

        Else
            DbSelectArea("SG2")
            DbSetOrder(1)
            DbGoTop()

            If !DbSeek(xFilial("SG2") + _produto + "            01" + cOperac)
                // Inclusao
                (RecLock("SG2", .T.))
                SG2->G2_FILIAL  = xFilial("SG2")
                SG2->G2_CODIGO  = '01'
                SG2->G2_PRODUTO = _produto
                SG2->G2_OPERAC  = cOperac
                SG2->G2_RECURSO = cRecurso
                SG2->G2_TPLINHA = "I"
                SG2->G2_DESCRI  = cDescri
                SG2->G2_MAOOBRA = nMaoobra
                SG2->G2_SETUP   = 0
                SG2->G2_LOTEPAD = nLotepad
                SG2->G2_TEMPAD  = 1
                SG2->G2_TPOPER  = '1'
                SG2->G2_TEMPSOB = 0
                SG2->G2_TEMPDES = 0
                SG2->G2_NIVMONT = 0
                SG2->G2_CHAVMON = 0
                SG2->G2_MAXINCR = 0
                SG2->G2_OPERZZV = cOperzzv
                SG2->G2_FACCAO  = 'N'
                SG2->G2_TEMPEND = 0
                SG2->(MsUnlock())
            Else
                // Alteracao
                (RecLock("SG2", .F.))
                SG2->G2_FILIAL  = xFilial("SG2")
                SG2->G2_CODIGO  = '01'
                SG2->G2_PRODUTO = _produto
                SG2->G2_OPERAC  = cOperac
                SG2->G2_RECURSO = cRecurso
                SG2->G2_TPLINHA = "I"
                SG2->G2_DESCRI  = cDescri
                SG2->G2_MAOOBRA = nMaoobra
                SG2->G2_SETUP   = 0
                SG2->G2_LOTEPAD = nLotepad
                SG2->G2_TEMPAD  = 1
                SG2->G2_TPOPER  = '1'
                SG2->G2_TEMPSOB = 0
                SG2->G2_TEMPDES = 0
                SG2->G2_NIVMONT = 0
                SG2->G2_CHAVMON = 0
                SG2->G2_MAXINCR = 0
                SG2->G2_OPERZZV = cOperzzv
                SG2->G2_FACCAO  = 'N'
                SG2->G2_TEMPEND = 0
                SG2->(MsUnlock())
            EndIf

            oJsonItem['code']    := 200
            oJsonItem['message'] := EncodeUtf8("Roteiro de operacoes gerado com sucesso!")
            ConOut("[API ESTRUTURAS] - SUCESSO - Roteiro de operacoes gerado com sucesso!")
            nY++
        EndIf
    Next nX
Return

/*
/==================================================================================\
|Nome              : B1453SG1Del                                                   |
|==================================================================================|
|Descricao         : Remove as estruturas do produto (SG1) via MSExecAuto/PCPA200  |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 22/10/2024                                                    |
\==================================================================================/
*/
Static Function B1453SG1Del(aCab)
    Local cRetorno  := ""
    Local aAutoErro := {}
    Local lPost     := .F.

    DbSelectArea("SG1")
    DbSetOrder(1)
    DbGoTop()

    If DbSeek(xFilial("SG1") + aCab[1][2])
        lMsHelpAuto    := .T.
        lMsErroAuto    := .F.
        lAutoErrNoFile := .T.

        MSExecAuto({|x,y,z| PCPA200(x,y,z)}, aCab, NIL, 5)

        If lMsErroAuto
            aAutoErro := GETAUTOGRLOG()
            cRetorno  := TXTERRO(aAutoErro)
            oJsonItem['code']    := 17
            oJsonItem['message'] := EncodeUtf8(cRetorno)
            ConOut("[API ESTRUTURAS] - ERRO 017 - " + cRetorno)
            DisarmTransaction()
        Else
            oJsonItem['code']    := 200
            oJsonItem['message'] := EncodeUtf8("Estrutura removida com sucesso!")
            ConOut("[API ESTRUTURAS] - SUCESSO - Estrutura removida com sucesso!")
            lPost := .T.
        EndIf

        If lPost
            B1453SG2Del(aCab)
        EndIf
    Else
        oJsonItem['code']    := 16
        oJsonItem['message'] := EncodeUtf8("O produto: " + aCab[1][2] + " nao foi encontrado nas estruturas, favor verificar!")
        ConOut("[API ESTRUTURAS] - ERRO 016 - Produto: " + aCab[1][2] + " nao encontrado nas estruturas - " + DtoC(MsDate()) + " - " + Time() + "!")
    EndIf
Return

/*
/==================================================================================\
|Nome              : B1453SG2Del                                                   |
|==================================================================================|
|Descricao         : Remove os roteiros de operacoes do produto (SG2)              |
|==================================================================================|
|Autor             : Joao Gebauer                                                  |
|==================================================================================|
|Data de Criacao   : 22/10/2024                                                    |
\==================================================================================/
*/
Static Function B1453SG2Del(aCab)
    DbSelectArea("SG2")
    DbSetOrder(1)
    DbGoTop()

    If DbSeek(xFilial("SG2") + aCab[1][2])
        While SG2->(!Eof()) .And. AllTrim(SG2->G2_PRODUTO) == AllTrim(aCab[1][2])
            SG2->(RecLock("SG2", .F.))
            SG2->(DbDelete())
            SG2->(MsUnlock())

            oJsonItem['code']    := 200
            oJsonItem['message'] := EncodeUtf8("Roteiro de operacoes removido com sucesso!")
            ConOut("[API ESTRUTURAS] - SUCESSO - Roteiro de operacoes removido com sucesso!")

            SG2->(DbSkip())
        EndDo
    Else
        oJsonItem['code']    := 18
        oJsonItem['message'] := EncodeUtf8("O produto: " + aCab[1][2] + " nao foi encontrado no roteiro de operacoes, favor verificar!")
        ConOut("[API ESTRUTURAS] - ERRO 018 - Produto: " + aCab[1][2] + " nao encontrado no roteiro de operacoes - " + DtoC(MsDate()) + " - " + Time() + "!")
    EndIf
Return

/*
/==================================================================================\
|Nome              : DadosSG1                                                      |
|==================================================================================|
|Descricao         : Monta a query SQL para consulta de estruturas                 |
|==================================================================================|
|Autor             : Daniel Victor Rosa / Eduardo Dalitz - Personalitec            |
|==================================================================================|
|Data de Criacao   : 29/01/2026                                                    |
\==================================================================================/
*/
Static Function DadosSG1(cCodProduto, cCodComponente, cCNumQuery, cValue)
    Local cRetQuery := ""
    Local cFiltro   := ""

    If cCNumQuery == "5"
        If !Empty(AllTrim(cValue))
            cFiltro := " AND (B1_COD LIKE '%" + AllTrim(Upper(cValue)) + "%'" + ;
                " OR B1_DESC LIKE '%" + AllTrim(Upper(cValue)) + "%') "
        EndIf
    EndIf

    Do Case
        Case cCNumQuery == "1"
            cRetQuery := " SELECT DISTINCT SG1_COMPONENTE.G1_COD, SG1_TECIDO.G1_COMP, B1_DESC"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) SG1_TECIDO"
            cRetQuery += " INNER JOIN " + RetSqlName("SG1") + " (NOLOCK) SG1_COMPONENTE"
            cRetQuery += "   ON SG1_COMPONENTE.D_E_L_E_T_ = ''"
            cRetQuery += "  AND SG1_COMPONENTE.G1_COD = SG1_TECIDO.G1_COD"
            cRetQuery += " INNER JOIN " + RetSqlName("SG1") + " (NOLOCK) SG1_PA"
            cRetQuery += "   ON SG1_PA.D_E_L_E_T_ = ''"
            cRetQuery += "  AND SG1_PA.G1_COMP = SG1_COMPONENTE.G1_COD"
            cRetQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) SB1"
            cRetQuery += "   ON B1_COD = SG1_COMPONENTE.G1_COD"
            cRetQuery += " WHERE SG1_TECIDO.D_E_L_E_T_ = ''"
            cRetQuery += " AND SG1_TECIDO.G1_COMP = " + ValToSql(cCodComponente)
            cRetQuery += " AND SG1_PA.G1_COD = "      + ValToSql(cCodProduto)
        Case cCNumQuery == "2"
            cRetQuery := " SELECT G1_QUANT, G1_COD, G1_COMP"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) "
            cRetQuery += " WHERE D_E_L_E_T_ = ''"
            cRetQuery += " AND G1_FILIAL = " + ValToSql(xfilial("SG1"))
            cRetQuery += " AND G1_COD = "    + ValToSql(cCodProduto)
            cRetQuery += " AND G1_COMP = "   + ValToSql(cCodComponente)
        Case cCNumQuery == "3"
            cRetQuery := " SELECT G1_COD, G1_COMP, G1_QUANT"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) "
            cRetQuery += " WHERE D_E_L_E_T_ = ''"
            cRetQuery += " AND G1_COD = " + ValToSql(cCodProduto)
        Case cCNumQuery == "4"
            cRetQuery := " SELECT B1_DESC,"
            cRetQuery += "   CASE B1_GRUPO WHEN '0104' THEN 'TECIDO' ELSE 'ITEM' END AS TIPO,"
            cRetQuery += "   G1_QUANT, G1_PERDA, G1_COMP"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) "
            cRetQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) ON B1_COD = G1_COMP"
            cRetQuery += " WHERE " + RetSqlName("SG1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND "   + RetSqlName("SB1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND G1_FILIAL = " + ValToSql(xfilial("SG1"))
            cRetQuery += " AND G1_COD = "    + ValToSql(cCodProduto)
        Case cCNumQuery == "5"
            cRetQuery := " SELECT TOP 500 B1_COD, B1_DESC, G1_QUANT, G1_PERDA"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) "
            cRetQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) ON G1_COMP = B1_COD"
            cRetQuery += " WHERE " + RetSqlName("SB1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND "   + RetSqlName("SG1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND G1_FILIAL = " + ValToSql(xfilial("SG1"))
            cRetQuery += cFiltro
        Case cCNumQuery == "6"
            cRetQuery := " SELECT B1_DESC,"
            cRetQuery += "   CASE B1_GRUPO WHEN '0104' THEN 'TECIDO' ELSE 'ITEM' END AS TIPO,"
            cRetQuery += "   G1_QUANT, G1_PERDA, G1_COMP"
            cRetQuery += " FROM " + RetSqlName("SG1") + " (NOLOCK) "
            cRetQuery += " INNER JOIN " + RetSqlName("SB1") + " (NOLOCK) ON B1_COD = G1_COMP"
            cRetQuery += " WHERE " + RetSqlName("SG1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND "   + RetSqlName("SB1") + ".D_E_L_E_T_ = ''"
            cRetQuery += " AND G1_COD = " + ValToSql(cCodProduto)
    EndCase

Return cRetQuery

/*
/==================================================================================\
|Nome              : ValidaJsonSG1                                                 |
|==================================================================================|
|Descricao         : Valida os parametros de entrada do metodo GET                 |
|==================================================================================|
|Autor             : Daniel Victor Rosa / Eduardo Dalitz - Personalitec            |
|==================================================================================|
|Ultima Alteracao  : 16/06/2026                                                    |
\==================================================================================/
*/
Static Function ValidaJsonSG1(cCodProduto, cCodComponente, cNumQuery)

    If ValType(cNumQuery) <> "C" .Or. Empty(cNumQuery)
        jJsonItem['message'] := "Favor preencher o parametro obrigatorio: cnumquery"
        jJsonItem['code']    := 4
        AAdd(oRetorno["retorno"], jJsonItem)
        Return .F.
    EndIf

    If cNumQuery $ "1|2|3|4|6"
        If ValType(cCodProduto) <> "C" .Or. Empty(cCodProduto)
            jJsonItem['message'] := "Favor preencher o parametro obrigatorio: codproduto"
            jJsonItem['code']    := 2
            AAdd(oRetorno["retorno"], jJsonItem)
            Return .F.
        EndIf
    EndIf

    If cNumQuery $ "1|2"
        If ValType(cCodComponente) <> "C" .Or. Empty(cCodComponente)
            jJsonItem['message'] := "Favor preencher o parametro obrigatorio: codcomponente"
            jJsonItem['code']    := 3
            AAdd(oRetorno["retorno"], jJsonItem)
            Return .F.
        EndIf
    EndIf

Return .T.
