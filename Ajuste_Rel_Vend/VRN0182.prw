#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
/=========================================================================\
|Módulo      : Vendas/Faturamento               	                   	  |
|=========================================================================|
|Programa    : VRN0182.PRW  | Responsável: Daniel Victor da Rosa          |
|=========================================================================|
|Descricao   : Relatório de Vendas - Resumido com vendedor         	      |
|=========================================================================|
|Data        : 07-10-2025       										  |
|=========================================================================|
|Programador : Daniel Victor da Rosa 	- Personalitec   		          |
\=========================================================================/
*/
User Function VRN0182()

    Local   oReport	:= Nil
    Private cPedidos	 := ""
    Private cTT789 := ""
    Private cPerg := ""
    Private cTitulo := "Relatório de Vendas - Sintético"

    cPerg := "BUD0031"

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Verifica as  perguntas selecionadas                          ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    if !Pergunte(cPerg,.T.)
        Return
    EndIf

    If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
        Msgstop("Ocorreu um erro na tentativa gerar o relatório. Gentileza verifique os campos!")
        Return
    EndIf

    oReport:= ReportDef() //(cAlias, cPergunte)
    //Dialogo do TReport
    RptStatus({|| oReport:PrintDialog() },cTitulo)


    MsgRun("Aguarde, gerando o relatório...","Aguarde",{|| ReportDef() })

Return

/*
/=========================================================================\
|Módulo      : Vendas/Faturamento               	                   	  |
|=========================================================================|
|Programa    : ReportDef    | Responsável: Daniel Victor da Rosa          |
|=========================================================================|
|Descricao   : Monta a estrutura do Relatório                   	      |
|=========================================================================|
|Data        : 07-10-2025       										  |
|=========================================================================|
|Programador : Daniel Victor da Rosa 	- Personalitec   		          |
\=========================================================================/
*/
Static Function ReportDef()

    Local oProd	 as Object

    oReport := TReport():New('VRN0182',cTitulo,,{|oReport| PrintReport(oReport)})

    oReport:SetLandscape() //layout horizontal
    oReport:nLineHeight := 40 //altura da linha
    oReport:SetColSpace(1) //espaÃ§amento da coluna
    oReport:SetTotalInLine(.T.) //totalizador de colunas
    oReport:nFontBody := 10
    oReport:cFontBody := "Arial"

    oProd :=  TRSection():New( oReport , "VRN0182" , {"SF2","SD2","SA1","SF4","SD1"} , /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ ,;
        "Total por Vendedor"/*<uTotalText>*/ , /*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , .T./*<lLineBreak>*/ ,;
        2 /*<nLeftMargin>*/ , /*<lLineStyle>*/ , /*<nColSpace>*/ , .T./*<lAutoSize>*/ , ": "/*<cCharSeparator>*/ , 2/*<nLinesBefore>*/ ,;
        /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ )

    TRCell():New(oProd,"SERIE"    ,"BUD0156Z" ,"Série"       ,/*Picture*/,TamSx3("F2_SERIE")[1]/*Tamanho do dado na Sx3*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,,.T./*Negrito*/)
    TRCell():New(oProd,"NUMERO"   ,"BUD0156Z" ,"Número"      ,/*Picture*/,TamSx3("F2_DOC")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"CLIENTE"  ,"BUD0156Z" ,"Cliente"     ,/*Picture*/,35,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"VENDE"    ,"BUD0156Z" ,"Vendedor"    ,/*Picture*/,25,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"TICKET"   ,"BUD0156Z" ,"Tickets"     ,/*Picture*/,5 ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"QUANT"    ,"BUD0156Z" ,"Quantidade"  ,/*Picture*/,TamSx3("D2_QUANT")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"VALOR"    ,"BUD0156Z" ,"Valor"       ,/*Picture*/,TamSx3("D2_TOTAL")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

    //TOTAL POR VENDENDOR
    oBreak := TRBreak():New( oProd , oProd:Cell("VENDE") , "TOTAIS " , .T./*<lTotalInLine>*/ , /*<cName>*/ , .T./*<lPageBreak>*/ )
    TRFunction():New(oProd:Cell("NUMERO"),/*cID*/,"COUNT",oBreak,"Total Pedidos"   ,"@E 999,999,999.99"/*cPicture*/,,.F./*lEndSection*/,.T./*lEndReport*/,.f./*lEndPage*/,oProd)
    TRFunction():New(oProd:Cell("QUANT") ,/*cID*/,"SUM"  ,oBreak,"Total Quantidade","@E 999,999,999.99"/*cPicture*/,,.F./*lEndSection*/,.T./*lEndReport*/,.f./*lEndPage*/,oProd)
    TRFunction():New(oProd:Cell("VALOR") ,/*cID*/,"SUM"  ,oBreak,"Total Valor"     ,"@E 999,999,999.99"/*cPicture*/,,.F./*lEndSection*/,.T./*lEndReport*/,.f./*lEndPage*/,oProd)

Return oReport

/*
/=========================================================================\
|Módulo      : Vendas/Faturamento               	                   	  |
|=========================================================================|
|Programa    : PrintReport  | Responsável: Daniel Victor da Rosa          |
|=========================================================================|
|Descricao   : Realiza a impressão do relatório                 	      |
|=========================================================================|
|Data        : 07-10-2025       										  |
|=========================================================================|
|Programador : Daniel Victor da Rosa 	- Personalitec   		          |
\=========================================================================/
*/
Static Function PrintReport(oReport)

    Local nTotalZ1  := 0
    Local nValVen	:= 0
    Local cVend2    := ""
    Local nAtual    := 0
    Local oProd     := oReport:Section(1)
    Private cSerLjTemp := SuperGetMV("BD_SERTMP")

    If (Select("TTVR182") <> 0)
        dbSelectArea("TTVR182")
        dbCloseArea()
    EndIf

    TTVR182 := GetNextAlias()

    //A3_FILIAL + A3_COD
    SA3->(DBSetOrder(1))

    cQuery := "SELECT DISTINCT F2_SERIE, F2_DOC, A1_COD, A1_NOME, F2_VEND1, SUM(D2_QUANT) AS QTD, SUM(D2_TOTAL) AS VLR, F2_VALPROM, F2_EMISSAO, F2_FRETE "
    cQuery += "  FROM "+RetSqlName("SF2")+" (NOLOCK)  "
    cQuery += "INNER JOIN "+RetSqlName("SD2")+" (NOLOCK) ON "+RetSqlName("SD2")+".D_E_L_E_T_ = '' AND D2_FILIAL = '"+xFilial("SD2")+"' AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA "
    cQuery += "INNER JOIN "+RetSqlName("SA1")+" (NOLOCK) ON "+RetSqlName("SA1")+".D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
    cQuery += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON "+RetSqlName("SF4")+".D_E_L_E_T_ = '' AND F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = D2_TES "
    cQuery += "WHERE "+RetSqlName("SF2")+".D_E_L_E_T_ = '' AND F2_FILIAL = '"+xFilial("SF2")+"' "
    cQuery += "AND F2_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
    cQuery += "AND D2_TES NOT IN ('515') " //não considerar consignação
    if MV_PAR04 == 1 /*Alterado para considerar as series do varejo facil Erik.N 23-11-2023*/
        cQuery += "AND F2_SERIE IN ("+cSerLjTemp+")"
    ElseIf MV_PAR04 == 2
        cQuery += "AND F2_SERIE NOT IN ("+cSerLjTemp+")"
    EndIf
    if MV_PAR09 == 2
        cQuery += "AND D2_TES <> '550' "
        cQuery += "AND D2_TES <> '902' "
        cQuery += "AND D2_TES <> '511' "
    EndIf
    if MV_PAR08 == 2
        cQuery += "	AND F4_ISS <> 'S' "
        cQuery += "AND ((F4_ESTOQUE = 'S' AND  F4_DUPLIC = 'S' )"
    else
        cQuery += "AND ((F4_ESTOQUE = 'S' AND  F4_DUPLIC = 'S' )"
        cQuery += "or (	 F4_ISS = 'S' and F4_ESTOQUE = 'N' AND  F4_DUPLIC = 'S')
    EndIf
    iF  MV_PAR09 == 1 // SIMPLES REMESSA
        cQuery += " OR ( (F4_DUPLIC = 'S') and (F4_ESTOQUE = 'N' )  and D2_CF IN('5922','6922')  )"
    ENDIF
    iF  MV_PAR10 == 1 //Venda Futura ?
        cQuery += " OR ( (F4_DUPLIC = 'N') and (F4_ESTOQUE = 'S' ) and D2_CF IN('5117','6117')  )"
    ENDIF
    iF  MV_PAR11 == 1 //Remessa Locacao
        cQuery += " OR( (F4_DUPLIC = 'N') and (F4_ESTOQUE = 'S' ) and D2_CF IN('5949','6949')  )"
    ENDIF
    cQuery += ")"
    iF  MV_PAR12 == 2 //Remessa Locacao
        cQuery += " AND SUBSTRING(A1_CGC,1,8) NOT IN ('04740770','07035484')"
    ENDIF

    cQuery += "AND (D2_PRCVEN > 0 OR D2_PVTOT > 0) "
    cQuery += "AND F2_TIPO = 'N' "
    cQuery += "AND (NOT (F2_NFCUPOM <> '' AND F2_SERIE = '1')) "
    cQuery += "GROUP BY F2_SERIE, F2_DOC, A1_COD, A1_NOME, F2_VALPROM, F2_EMISSAO, F2_FRETE, F2_VEND1 "

    // Alterada query da SD1 para considerar o valor do desconto na devolucao SUM((D1_TOTAL - D1_VALDESC) * (-1)) AS VLR, validado por Thais. Erik.N 08/03/2022
    If MV_PAR05 == 1
        cQuery += " UNION "
        cQuery += "SELECT DISTINCT F1_SERIE AS F2_SERIE, F1_DOC AS F2_DOC, A1_COD, A1_NOME, NULL AS F2_VEND1, SUM(D1_QUANT * (-1)) AS QTD, SUM((D1_TOTAL - D1_VALDESC) * (-1)) AS VLR, 0 AS F2_VALPROM, F1_EMISSAO AS F2_EMISSAO, 0 AS F2_FRETE "
        cQuery += "  FROM "+RetSqlName("SF1")+" (NOLOCK)  "
        cQuery += "INNER JOIN "+RetSqlName("SD1")+" (NOLOCK) ON "+RetSqlName("SD1")+".D_E_L_E_T_ = '' AND D1_FILIAL = '"+xFilial("SD1")+"' AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA "
        cQuery += "INNER JOIN "+RetSqlName("SA1")+" (NOLOCK) ON "+RetSqlName("SA1")+".D_E_L_E_T_ = '' AND A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = F1_FORNECE AND A1_LOJA = F1_LOJA "
        cQuery += "WHERE "+RetSqlName("SF1")+".D_E_L_E_T_ = '' AND F1_FILIAL = '"+xFilial("SF1")+"' "
        cQuery += "AND F1_EMISSAO BETWEEN '"+Dtos(MV_PAR01)+"' AND '"+Dtos(MV_PAR02)+"' "
        cQuery += "AND F1_TIPO = 'D' "
        if MV_PAR04 == 1 // Inserido para tratar a serie da devolucao se filtro atacado ou varejo Erik.N 23-11-2023
            cQuery += "AND F1_SERIE IN ("+cSerLjTemp+")"
        ElseIf MV_PAR04 == 2
            cQuery += "AND F1_SERIE NOT IN ("+cSerLjTemp+")"
        EndIf
        cQuery += "GROUP BY F1_SERIE, F1_DOC, A1_COD, A1_NOME, F1_EMISSAO "
    EndIf

    cQuery += "ORDER BY F2_VEND1 ASC, F2_EMISSAO ASC, F2_SERIE ASC, F2_DOC ASC "

    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "TTVR182", .F., .T.)

    Count to nTotalZ1
    TTVR182->(DbGoTop())

    oReport:SetMeter(nTotalZ1)
    oProd:Init()

    While TTVR182->(!EOF())

        If oReport:Cancel()
            Exit
        Endif

        //Incrementando a regua
        nAtual++
        oReport:SetMsgPrint("Imprimindo registro " + cValToChar(nAtual) + " de " + cValToChar(nTotalZ1) + "...")
        oReport:IncMeter()

        nValVen	:= TTVR182->VLR
        if MV_PAR03 == 1
            If !Empty(TTVR182->F2_VALPROM)
                nValVen	:= TTVR182->F2_VALPROM
            EndIf
        EndIf

        If MV_PAR07 == 1
            nValVen	+= TTVR182->F2_FRETE
        EndIf

        cVend1 := ""

        IF !EMPTY(AllTrim(TTVR182->F2_VEND1))
            IF SA3->(DBSeek(xfilial('SA3')+TTVR182->F2_VEND1))
                cVend1 :=  Substr(SA3->A3_NOME, 1, 40)
            ENDIF
        ELSE
            cVend1 := "NF sem vendedor."
        ENDIF

        IF !EMPTY(alltrim(cVend2))
            IF cVend1 <> cVend2
                oProd:Finish()
                oProd:Init()
            ENDIF
        ENDIF

        oProd:Cell("SERIE"  ):SetValue(alltrim(TTVR182->F2_SERIE))
        oProd:Cell("NUMERO" ):SetValue(AllTrim(TTVR182->F2_DOC))
        oProd:Cell("CLIENTE"):SetValue(Substr(AllTrim(TTVR182->A1_NOME), 1, 40))
        oProd:Cell("VENDE"  ):SetValue(alltrim(cVend1))
        oProd:Cell("TICKET" ):SetValue("")
        oProd:Cell("QUANT"  ):SetValue(alltrim(Transform(TTVR182->QTD, "@E 999,999,999")))
        oProd:Cell("VALOR"  ):SetValue(alltrim(Transform(nValVen, "@E 999,999,999.99")))
        oProd:PrintLine()

        TTVR182->(dbSkip())

        cVend2 := cVend1

    ENDDO

    TTVR182->(DbCloseArea())
    oProd:Finish()



Return
