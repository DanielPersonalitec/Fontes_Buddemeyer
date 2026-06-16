#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} TestSema
(long_description)
@Fontes para teste de Semafaro.
@Daniel Victor da Rosa
@since 17/07/2025
/*/
User Function TestSema()

    Local lRet  := .T.
    Local lContiZ := .T.
    Local nOpcX := 3
    Local cDocGI  := ""
    Local cGuia	:= ''
    //06051982 VARIAVEIS UTILIZADAS NO MA261TRD3
    private cBUDGuia := ''
    private cBUDDocGI := ""

    //DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - CONTROLE DE SEMÁFORO PARA EVITAR EXECUÇÃO CONCORRENTE
    IF !LockByName("zExecBusDoc_lock", .T., .F.)
        //U_BUD1427("[BUD1275] - Atenção, outro usuário já está executando essa rotina (BuscZ889)! ")
        While lContiZ
            Sleep(3000) // Aguarda 3000ms antes de tentar novamente
            IF !LockByName("zExecBusDoc_lock", .T., .F.)
            Else
                cDocGI := BuscZ889()
                lContiZ := .F.
                //U_BUD1427("[BUD1275] - Atenção, executando essa rotina (BuscZ889)! ")
            ENDIF
        End
    Else
        cDocGI := BuscZ889()
    EndIf

    cBUDDocGI := cDocGI
    //FIM - DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025

    // U_BUD1427(Replicate("=",80))
    // U_BUD1427("[BUD1275] - WS TRANSFERENCIA DE ESTOQUE - INICIO ("+TIME()+")")

    // //Cabecalho a Incluir
    // aAuto := {{cDocGI,dDataBase}}  //Cabecalho

    // For nX := 1 to Len(::sTransf:Itens)
    //     // Número da guia:
    //     cGuia	:= ::sTransf:Itens[nX]:DOC_GUIA
    //     cBUDGuia := cGuia
    //     dbSelectArea("SB1")
    //     dbSetOrder(1)
    //     dbGoTop()
    //     If dbSeek(xFilial("SB1")+::sTransf:Itens[nX]:ORI_PRODUTO)
    //         cProdOri := SB1->B1_COD
    //         cDescOri := SB1->B1_DESC
    //         cUnidOri := SB1->B1_UM
    //     Else
    //         ::cRetorno := "ERRO - Produto de ORIGEM nao encontrado"
    //         SetSoapFault("SetTransferencia","ERRO - Produto de ORIGEM nao encontrado")
    //         Return .F.
    //     EndIf

    //     dbSelectArea("SB1")
    //     dbSetOrder(1)
    //     dbGoTop()
    //     If dbSeek(xFilial("SB1")+::sTransf:Itens[nX]:DES_PRODUTO)
    //         cProdDes := SB1->B1_COD
    //         cDescDes := SB1->B1_DESC
    //         cUnidDes := SB1->B1_UM
    //     Else
    //         ::cRetorno := "ERRO - Produto de DESTINO nao encontrado"
    //         SetSoapFault("SetTransferencia","ERRO - Produto de DESTINO nao encontrado")
    //         Return .F.
    //     EndIf

    //     CriaSB2(cProdOri,::sTransf:Itens[nX]:DES_LOCAL)
    //     CriaSB2(cProdDes,::sTransf:Itens[nX]:DES_LOCAL)

    //     cLocal := ::sTransf:Itens[nX]:ORI_LOCAL

    //     dbSelectArea("SB2")
    //     dbSetOrder(1)
    //     dbGoTop()
    //     If dbSeek(xFilial("SB2")+cProdOri+cLocal)
    //         nSaldo := SaldoSb2()

    //         If ::sTransf:Itens[nX]:QUANTIDADE > nSaldo

    //             cErro := "ERRO - A quantidade solicitada e maior do que o disponível em estoque. Produto: " + cProdOri

    //             ::cRetorno := cErro
    //             SetSoapFault("SetTransferencia",cErro)
    //             Return .F.

    //         EndIf

    //         If (::sTransf:Itens[nX]:ORI_LOCAL != ::sTransf:Itens[nX]:DES_LOCAL) .OR. (cProdOri != cProdDes)
    //             AADD(aAuto,{cProdOri,;                       // 01.Produto Origem
    //                 cDescOri,;                       // 02.Descricao
    //                 cUnidOri,;                       // 03.Unidade de Medida
    //                 ::sTransf:Itens[nX]:ORI_LOCAL,;  // 04.Local Origem
    //                 CriaVar("D3_LOCALIZ",.F.),;      // 05.Endereco Origem
    //                 cProdDes,;                    	 // 06.Produto Destino
    //                 cDescDes,;                       // 07.Descricao
    //                 cUnidDes,;                       // 08.Unidade de Medida
    //                 ::sTransf:Itens[nX]:DES_LOCAL,;  // 09.Armazem Destino
    //                 CriaVar("D3_LOCALIZ",.F.),;      // 10.Endereco Destino
    //                 CriaVar("D3_NUMSERI",.F.),;    	 // 11.Numero de Serie
    //                 CriaVar("D3_LOTECTL",.F.),;      // 12.Lote Origem
    //                 CriaVar("D3_NUMLOTE",.F.),;      // 13.Sublote
    //                 CriaVar("D3_DTVALID",.F.),;      // 14.Data de Validade
    //                 CriaVar("D3_POTENCI",.F.),;      // 15.Potencia do Lote
    //                 ::sTransf:Itens[nX]:QUANTIDADE ,;// 16.Quantidade
    //                 CriaVar("D3_QTSEGUM",.F.),;      // 17.Quantidade na 2 UM
    //                 CriaVar("D3_ESTORNO",.F.),;      // 18.Estorno
    //                 CriaVar("D3_NUMSEQ" ,.F.),;      // 19.NumSeq
    //                 CriaVar("D3_LOTECTL",.F.),;      // 20.Lote Destino
    //                 CriaVar("D3_DTVALID",.F.),;      // 21.Data de Validade
    //                 CriaVar("D3_ITEMGRD",.F.),;      // 22.Item Grade
    //                 CriaVar("D3_OBSERVA",.F.)})
    //             //						CriaVar("D3_IDDCF",.F.),;
    //         EndIf
    //     EndIf
    // Next nX

    // If Len(aAuto) > 1
    //     lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
    //     lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()
    //     MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcX)

    //     If lMsErroAuto
    //         RollbackSx8()
    //         cErro := ""
    //         aErro := GetAutoGRLog()

    //         For nX := 1 To Len(aErro)
    //             cErro += aErro[nX] + Chr(13)+Chr(10)
    //         Next nX

    //         ::cRetorno := "ERRO - " + cErro
    //         SetSoapFault("SetTransferencia","ERRO - " + cErro)
    //         lRet := .F.
    //     Else
    //         ::cRetorno := cDocGI
    //         lRet := .T.

    //         //06051982 RETIRADO E INSERIDO NO PONTO DE ENTRADA MA261TRD3 EM 09032021;
    //         // Atualizo número da guia:
    //         /*
	// 	     cUpd := ""
	// 	     cUpd += "UPDATE "+RETSQLNAME("SD3")+" SET D3_DOCGUIA = '"+cGuia+"' "
	// 	     cUpd += "WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
	// 	     cUpd += "AND D3_DOC = '"+cDocGI+"' "
	// 	     cUpd += "AND D3_EMISSAO = '"+DtoS(dDataBase)+"' "
	// 	     cUpd += "AND "+RETSQLNAME("SD3")+".D_E_L_E_T_ = '' "
	// 	   TCSQLEXEC(cUpd)
    //         */
    //     EndIf

    // Else
    //     ::cRetorno := ""
    //     lRet := .T.
    // EndIf

    IF  MsgNoYes("Liberar o Semafaro","Atenção")
        //DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - FIM DO CONTROLE DE SEMÁFORO
        UnLockByName("zExecBusDoc_lock", .T., .F.)
    ENDIF

Return

/*/{Protheus.doc} BuscZ889
@Daniel Victor da Rosa
@Fontes para teste de Semafaro.
@since 17/07/2025
/*/
Static Function BuscZ889()


Return "669900"
