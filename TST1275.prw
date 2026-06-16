#Include 'TOTVS.CH'

User Function TST1275Z()

    Local nTest := 0
    Local cZMsg5 := ""
    Local cEOLZ := CHR(13)+CHR(10)
    Local cZMsg6    := ""
    Local cEOL8     := CHR(13)+CHR(10)

    IF nTest == 1

        cZMsg5 := " Inicio da Transferencia "+DTOS(DATE())+" "+TIME()+cEOLZ
        cZMsg5 += "Produto de ori: " + "cProdOri" + cEOLZ
        cZMsg5 += "Descricao de ori: " + "cDescOri" + cEOLZ
        cZMsg5 += "Unidade de ori: " + "cUnidOri" + cEOLZ
        cZMsg5 += "Guia de ori: " + "cGuia" + cEOLZ
        cZMsg5 += "Produto de des: " + "cProdDes" + cEOLZ
        cZMsg5 += "Descricao de des: " + "cDescDes" + cEOLZ
        cZMsg5 += "Unidade de des: " + "cUnidDes" + cEOLZ
        cZMsg5 += "Guia de des: " + "cGuia" + cEOLZ
        cZMsg5 += "Fim da Transferencia Erro "+TIME() + cEOLZ
        cZMsg5 += "Fim da Transferencia Sucesso "+TIME() + cEOLZ
        cZMsg5 += "*********************************************************************" + cEOLZ

        _B1275LOG(cZMsg5)

    ELSE

        cZMsg6 += " Inicio da Desmontagem "+DTOS(DATE())+" "+TIME()+cEOL8
        cZMsg6 += " Doc : "+"cDocGI"+cEOL8
        cZMsg6 += " Fim da Desmontagem Erro "+DTOS(DATE())+" "+TIME()+cEOL8
        cZMsg6 += " Fim da Desmontagem Sucesso "+DTOS(DATE())+" "+TIME()+cEOL8
        cZMsg6 += "*********************************************************************"+cEOL8
        _B1275L2(cZMsg6)

    ENDIF


Return


/*Função para gerar Logs de GuiA
Daniel Victor da Rosa - Personalitec
14/08/2025 - Para Transferência
*/
Static Function _B1275LOG(_cZMsg)

    Local cArqTxt := "GUIA_TRANSFERENCIA_BUD1275_LOGS.txt"
    Local nHdlog  := fOpen(cArqTxt,2)

    //caso não consiga abrir o arquivo...
    If nHdlog == -1
        //tenta cria-lo
        nHdlog := fCreate(cArqTxt,2)
        //se também der erro
        If 	nHdlog == -1
            U_BUD1427('Erro ao Gerar o Arquivo de Log GUIA_BUD1275_LOGS !!!')
            Return
        EndIf
    Else
        //vai para o fim do arquivo
        fSeek(nHdlog,0,2)
    Endif

    fWrite(nHdlog,_cZMsg,Len(_cZMsg))

    fClose(nHdlog)

Return


/*Função para gerar Logs de GuiA
Daniel Victor da Rosa - Personalitec
14/08/2025 - Para Desmontagem
*/
Static Function _B1275L2(_cZMsg6)

    Local cArqTxt := "GUIA_DESMONTAGEM_BUD1275_LOGS.txt"
    Local nHdlog  := fOpen(cArqTxt,2)

    //caso não consiga abrir o arquivo...
    If nHdlog == -1
        //tenta cria-lo
        nHdlog := fCreate(cArqTxt,2)
        //se também der erro
        If 	nHdlog == -1
            U_BUD1427('Erro ao Gerar o Arquivo de Log GUIA_BUD1275_LOGS !!!')
            Return
        EndIf
    Else
        //vai para o fim do arquivo
        fSeek(nHdlog,0,2)
    Endif

    fWrite(nHdlog,_cZMsg6,Len(_cZMsg6))

    fClose(nHdlog)

Return
