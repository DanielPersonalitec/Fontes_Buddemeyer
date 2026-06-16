#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"

/*
/=========================================================================\
|Cliente     : BUDDEMEYER                                                 |
|=========================================================================|
|Programa    : BUD1497.PRW  | Responsável: Daniel Victor da Rosa          |
|=========================================================================|
|Descricao   : Relatorio de Produtos sem Pedido                           |
|=========================================================================|
|Data        : 09-10-2025       |                                         |
|=========================================================================|
|Programador : Daniel Victor da Rosa       								  |
|=========================================================================|
|Objetivos   : Relatorio de Produtos sem Pedido no periodo informado.     |
\=========================================================================/
*/
User Function BUD1497()

    Local   oReport	    := Nil
    Private nTotalZu    := 0
    Private cTitulo     := "Produtos sem Pedido no periodo informado"

    cPerg := "BUD1472"

    if !Pergunte(cPerg,.T.)
        Return
    EndIf

    oReport:= ReportDef()
    RptStatus({|| oReport:PrintDialog() },cTitulo)

Return

/*
/=========================================================================\
|Módulo      : Estoque/custos                   	                   	  |
|=========================================================================|
|Programa    : ReportDef    | Responsável: Daniel Victor da Rosa          |
|=========================================================================|
|Descricao   : Monta a estrutura do Relatório                   	      |
|=========================================================================|
|Data        : 09-10-2025       										  |
|=========================================================================|
|Programador : Daniel Victor da Rosa 	- Personalitec   		          |
\=========================================================================/
*/
Static Function ReportDef()

    Local oProd	 as Object
    oReport := TReport():New('BUD1497',cTitulo,,{|oReport| PrintReport(oReport)})

    oReport:SetLandscape(.F.) //layout horizontal
    oReport:nLineHeight := 40 //altura da linha
    oReport:SetColSpace(1) //espaçamento da coluna
    oReport:SetTotalInLine(.T.) //totalizador de colunas
    oReport:nFontBody := 9
    oReport:cFontBody := "Arial"

    oProd :=  TRSection():New( oReport , "BUD1497" , {"SB2","SC6"} , /*<aOrder>*/ , /*<lLoadCells>*/ , /*<lLoadOrder>*/ ,;
        "Total por Vendedor"/*<uTotalText>*/ , /*<lTotalInLine>*/ , /*<lHeaderPage>*/ , /*<lHeaderBreak>*/ , /*<lPageBreak>*/ , .T./*<lLineBreak>*/ ,;
        /*<nLeftMargin>*/ , /*<lLineStyle>*/ , /*<nColSpace>*/ , .T./*<lAutoSize>*/ , ": "/*<cCharSeparator>*/ , 2/*<nLinesBefore>*/ ,;
        /*<nCols>*/ , /*<nClrBack>*/ , /*<nClrFore>*/ , /*<nPercentage>*/ )

    TRCell():New(oProd,"CODPRD"   ,"SB2" ,"Cod. Produto",/*Picture*/,20 ,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,,,,.T./*Negrito*/)
    TRCell():New(oProd,"A1"       ,"SB2" ,"Al"          ,/*Picture*/, 5 ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"DESCRI"   ,"SB2" ,"Descricao"   ,/*Picture*/,30 ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"ESTATL"   ,"SB2" ,"Estoq.Atual ",/*Picture*/,14 ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"RESERV"   ,"SB2" ,"Reserva"     ,/*Picture*/,14 ,/*lPixel*/,/*{|| code-block de impressao }*/)
    TRCell():New(oProd,"DISPO"    ,"SB2" ,"Disponivel"  ,/*Picture*/,14 ,/*lPixel*/,/*{|| code-block de impressao }*/)

Return oReport

/*
/=========================================================================\
|Módulo      : Estoque/custos                   	                   	  |
|=========================================================================|
|Programa    : PrintReport    | Responsável: Daniel Victor da Rosa        |
|=========================================================================|
|Descricao   : Imprime o Relatório                                        |
|=========================================================================|
|Data        : 09-10-2025       										  |
|=========================================================================|
|Programador : Daniel Victor da Rosa 	- Personalitec   		          |
\=========================================================================/
*/
Static Function PrintReport(oReport)

    Local oProd     := oReport:Section(1)
    Local Nzyi      := 0

    cQuery := ""
    cQuery += " SELECT DISTINCT B2_COD, B2_LOCAL, B2_QATU, B2_RESERVA, B2_QATU - B2_RESERVA AS B2DISP "
    cQuery += " FROM " + RETSQLNAME("SB2") + " (NOLOCK) "
    cQuery += " WHERE D_E_L_E_T_ <> '*' "
    cQuery += " AND (B2_QATU - B2_RESERVA) > 0 "
    cQuery += " AND B2_RESERVA <= 0 "
    cQuery += " AND B2_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQuery += " AND B2_COD BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
    //NOT EXISTS: produtos não vendidos
    cQuery += " AND NOT EXISTS ( "
    cQuery += " SELECT 1 FROM " + RETSQLNAME("SC6") + " C6 (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SC5") + " C5 (NOLOCK) "
    cQuery += " ON C5.C5_NUM = C6.C6_NUM "
    cQuery += " AND C5.C5_FILIAL = C6.C6_FILIAL "
    cQuery += " WHERE C6.D_E_L_E_T_ <> '*' "
    cQuery += " AND C5.D_E_L_E_T_ <> '*' "
    If MV_PAR10 == 2
        cQuery += " AND (C6_QTDVEN - C6_QTDCANC) > 0 "
    EndIf
    If MV_PAR09 == 1
        cQuery += " AND SUBSTRING(C6_CLI,1,2) = 'EX' "
    Else
        cQuery += " AND SUBSTRING(C6_CLI,1,2) <> 'EX' "
    EndIf
    cQuery += " AND C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' ""
    cQuery += " AND C6_PRODUTO = B2_COD "
    cQuery += " AND (C5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    cQuery += " AND (C6.C6_ENTREG BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    cQuery += " OR C6.C6_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')) "
    cQuery += " ) "
    //NOT EXISTS: produtos que são componentes de jogos vendidos
    cQuery += " AND NOT EXISTS ( "
    cQuery += " SELECT 1 FROM " + RETSQLNAME("SG1") + " G1 (NOLOCK) "
    cQuery += " INNER JOIN " + RETSQLNAME("SC6") + " C6 (NOLOCK) "
    cQuery += " ON C6.C6_PRODUTO = G1.G1_COD "
    cQuery += " INNER JOIN " + RETSQLNAME("SC5") + " C5 (NOLOCK) "
    cQuery += " ON C5.C5_NUM = C6.C6_NUM "
    cQuery += " AND C5.C5_FILIAL = C6.C6_FILIAL "
    cQuery += " WHERE G1.D_E_L_E_T_ = ' ' "
    cQuery += " AND C6.D_E_L_E_T_ <> '*' "
    cQuery += " AND C5.D_E_L_E_T_ <> '*' "
    If MV_PAR10 == 2
        cQuery += " AND (C6_QTDVEN - C6_QTDCANC) > 0 "
    EndIf
    If MV_PAR09 == 1
        cQuery += " AND SUBSTRING(C6_CLI,1,2) = 'EX' "
    Else
        cQuery += " AND SUBSTRING(C6_CLI,1,2) <> 'EX' "
    EndIf
    cQuery += " AND C6.C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
    cQuery += " AND G1.G1_COMP = B2_COD "
    cQuery += " AND (C5.C5_EMISSAO BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    cQuery += " AND (C6.C6_ENTREG BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
    cQuery += " OR C6.C6_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')) "
    cQuery += " ) "
    cQuery += " ORDER BY B2_COD"

    If (Select("TT576") <> 0)
        DbSelectArea("TT576")
        DbCloseArea()
    EndIf

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery), "TT576", .F., .T.)

    Count to nTotalZu
    TT576->(DbGoTop())

    oReport:SetMeter(nTotalZu)
    oProd:Init()

    While TT576->(!EOF())

        Nzyi++
        oReport:SetMsgPrint("Imprimindo registros." + cValToChar(Nzyi) + " de " + cValToChar(nTotalZu) + "...")
        oReport:IncMeter()
        oProd:Cell("CODPRD"):SetValue(ALLTRIM(TT576->B2_COD))
        oProd:Cell("A1"    ):SetValue(ALLTRIM(TT576->B2_LOCAL))
        oProd:Cell("DESCRI"):SetValue(SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+TT576->B2_COD,"B1_DESC"),1,44))
        oProd:Cell("ESTATL"):SetValue(TRANSFORM(TT576->B2_QATU,"@E 99,999,999"))
        oProd:Cell("RESERV"):SetValue(TRANSFORM(TT576->B2_RESERVA,"@E 99,999"))
        oProd:Cell("DISPO" ):SetValue(TRANSFORM(TT576->B2DISP,"@E 99,999"))
        oProd:PrintLine()
        TT576->(dbSkip())

    EndDo

    oProd:Finish()

Return

//PODE SER USADO PARA CRIAR PERGUNTAS SEM SER PELO CFG
//MAS DEPOIS DE CRIAR, COMENTAR. ESSE FONTE JÁ ESTAVA AQUI E ERA USADO.
//DANIEL VICTOR DA ROSA - PERSONALITEC 16/10/2025.
// Static Function CriaPerguntas()

//     LOCAL aReg  := {}
//     Local _l    := 0
//     Local _m    := 0
//     Local _k    := 0

// aPer := {}
// AADD(aPer,{cPerg,"01","Data Entrega De   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"02","Data Entrega Ate  ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"03","Data Pedido De    ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"04","Data Pedido Ate   ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"05","Produto De        ?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"06","Produto Ate       ?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"07","Almoxarifado De   ?","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"08","Almoxarifado Ate  ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"09","Tipo do Cliente   ?","mv_ch9","N",01,0,0,"C","","","Exportacao","","","Nacional","","","","","","","","","","",""})
// AADD(aPer,{cPerg,"10","Consid. Cancelados?","mv_chA","N",01,0,0,"C","","","Sim","","","Nao","","","","","","","","","","",""})

//cGrupo := "BUD1472"

//     DbSelectArea("SX1")
//     If (FCount() == 43)
//         For _l := 1 To Len(aPer)
//             AAdd(aReg, { cGrupo, aPer[_l,2], aPer[_l,3], "", "", aPer[_l,4], aPer[_l,5], ;
//                 aPer[_l,6], aPer[_l,7], aPer[_l,8], aPer[_l,9], aPer[_l,10], ;
//                 aPer[_l,11], aPer[_l,12], "", "", aPer[_l,13], aPer[_l,14], ;
//                 aPer[_l,15], "", "", aPer[_l,16], aPer[_l,17], aPer[_l,18], "", "", ;
//                 aPer[_l,19], aPer[_l,20], aPer[_l,21], "", "", aPer[_l,22], ;
//                 aPer[_l,23], aPer[_l,24], "", "", aPer[_l,25], aPer[_l,26], "", "", "", "", "" })
//         Next _l
//     ElseIf (FCount() == 39)
//         For _l := 1 To Len(aPer)
//             AAdd(aReg, { cGrupo, aPer[_l,2], aPer[_l,3], "", "", aPer[_l,4], aPer[_l,5], ;
//                 aPer[_l,6], aPer[_l,7], aPer[_l,8], aPer[_l,9], aPer[_l,10], ;
//                 aPer[_l,11], aPer[_l,12], "", "", aPer[_l,13], aPer[_l,14], ;
//                 aPer[_l,15], "", "", aPer[_l,16], aPer[_l,17], aPer[_l,18], "", "", ;
//                 aPer[_l,19], aPer[_l,20], aPer[_l,21], "", "", aPer[_l,22], ;
//                 aPer[_l,23], aPer[_l,24], "", "", aPer[_l,25], aPer[_l,26], "" })
//         Next _l

//     ElseIf (FCount() == 26)
//         aReg := aPer
//     EndIf

//     DbSelectArea("SX1")
//     For _l := 1 to Len(aReg)
//         If !DbSeek(cGrupo+StrZero(_l,02,00))
//             RecLock("SX1",.T.)
//             For _m := 1 to FCount()
//                 FieldPut(_m,aReg[_l,_m])
//             Next _m
//             MsUnlock("SX1")
//         Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
//             RecLock("SX1",.F.)
//             For _k := 1 to FCount()
//                 FieldPut(_k,aReg[_l,_k])
//             Next _k
//             MsUnlock("SX1")
//         Endif
//     Next _l

// Return
