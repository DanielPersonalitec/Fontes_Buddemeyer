#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"


//--------------------------------------------------------------
/*/{Protheus.doc} VRN0180
Description
TELA DE IMPORTAÇÃO DE XML - DEVOLUÇÃO DE TERCEIRO - PF
DANIEL VICTOR DA ROSA - PERSONALITEC
@since 29-07-2025
/*/
//--------------------------------------------------------------
User Function VRN0180()

    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := SPACE(44)
    Local oSay1
    Local oSay3
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "IMPORTAR XML DEVOLUCAO - PF" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL

    @ 010, 061 SAY oSay1 PROMPT "Atenção: Salvar aquivo em uma pasta no C:\XML" SIZE 123, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 041 MSGET oGet1 VAR cGet1 SIZE 167, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 076, 170 BUTTON oButton1 PROMPT "IMPORTAR" SIZE 037, 009 OF oDlg ACTION ProcXmlZ8(cGet1) PIXEL
    @ 045, 041 SAY oSay3 PROMPT "Chave do XML" SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 108, 206 BUTTON oButton2 PROMPT "SAIR" SIZE 037, 009 OF oDlg ACTION oDlg:end() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcXmlZ8
    (long_description)
    @type  Function
    @author Daniel Victor da Rosa - Personalitec
    @since 29-07-2025
    @see (links_or_references)
/*/
Static Function ProcXmlZ8(cChaveXML)

    Private cXMLFile  :="" // guarda o caminho absoluto do xml, setar na mao quando o pedido ja estiver gerado
    Private cPedVend := "" // Numero do pedido de Venda que foi gravado, caso ja tenha sido gerado setar na mao
    Private cNFBudd  := ""
    Private cSNFBudd := ""
    Private oFullXML := Nil
    Private cChavXML2 := cChaveXML
    Private cPedido  := ""
    Private aDocOriSC6 := {}

    IF Alltrim(cChavXML2) == ""
        FWAlertError("Chave do XML não informada", "Atenção")
        Return
    ELSE

        //FUNÇÃO RESPONSÁVEL POR PERCORRER TODOS OS XML DA PASTA E PEGAR O ARQUIVO XML COM BASE NA CHAVE DIGITADA
        FWMsgRun(, {||   cXMLFile := zPerXml("C:\XML\",,,cChavXML2) }, "VAREJO FACIL","Aguarde Processando xml" )

        IF !Empty(cXMLFile) .AND. cXMLFile <> "1"
            //Gera o Pedido de Venda / Gera SF2-SD2 */ DESCOMENTAR ESSA PARTE AO FICAR PRONTO O FONTE.
            FWMsgRun(, {||  fGetXMLZ8(cXMLFile) }, "VAREJO FACIL","Aguarde Processando xml" )
        ELSEIF cXMLFile == "1"
            FWAlertError("CHAVE XML NAO ENCONTRADA NA PASTA C:\XML\ ->  "+cChavXML2, "ATENCAO")
        ELSE
            FWAlertError("O XML COM A CHAVE: "+cChavXML2 +" JA FOI IMPORTADO.", "ATENCAO")
        ENDIF

    ENDIF

Return

/*/{Protheus.doc} fGetXMLZ8
    @type  Function
    @author Daniel Victor da Rosa - Personalitec
    @since 29/07/2025
/*/
Static Function fGetXMLZ8(cXmlName)

    Local cMsg              := ""
    Local cWarning          := ""
    Local cError            := ""
    Local nI                := 0
    Local nXZ19             := 0
    Local nXZ18             := 0
    Local lOK               := .T.
    Private lMsErroAuto    	:= .F.
    Private lAutoErrNoFile 	:= .F.

    aRetSM0 := FWLoadSM0()
    If !Empty(alltrim(cXmlName))

        cXML :=  getXML(cXmlName)
        cXML := StrTran( cXML, "ns2:", "" )

        oFullXML := XmlParser(cXML,"_",@cError,@cWarning)
        cChave   := Right(AllTrim(oFullXML:_nfeProc:_NFe:_InfNfe:_Id:Text),44)
        cNumNF   := padl(alltrim(oFullXML:_nfeProc:_NFe:_infNFe:_ide:_nNF:TEXT),9,'0')
        cSerie   := ALLTRIM(oFullXML:_nfeProc:_NFe:_infNFe:_ide:_serie:TEXT)
        xNome    := oFullXML:_nfeProc:_NFe:_infNFe:_emit:_xNome:TEXT
        cNFBudd   := cNumNF
        cSNFBudd  := cSerie
        If (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_emit ,"_CNPJ")<>Nil)
            cCNPJ	:=  oFullXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT
        EndIf
        /*PESQUISO O CNPJ DA EMPRESA E POSICIONO*/
        nPosfil := aScan(aRetSM0,{|x| AllTrim(x[18])==cCNPJ})
        cFilAnt := aRetSM0[nPosFil][2]
        FWSM0Util():setSM0PositionBycFilAnt()

        cCodCLi2Z := ""
        cCodloj2Z := ""

        If (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_dest ,"_CNPJ")  != Nil)

            cCNPJCli	:=  oFullXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT
            cTpPes := "J"

            SA2->(DbSetOrder(3))
            If !SA2->( DbSeek(xfilial("SA2")+cCNPJCli))
                FWAlertError("Fornecedor não encontrado", "VA Importador XML")
                Return
            ELSE
                cCodCLi2Z := SA2->A2_COD
                cCodloj2Z := SA2->A2_LOJA
            Endif

        ELSEIF (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_dest ,"_CPF")  != Nil)

            cCNPJCli	:=  oFullXML:_nfeProc:_NFe:_infNFe:_dest:_CPF:TEXT
            cTpPes := "F"

            SA1->(DbSetOrder(3))
            If !SA1->(DbSeek(xfilial("SA1")+cCNPJCli))
                FWAlertError("Cliente não encontrado", "VA Importador XML")
                Return
            ELSE
                cCodCLi2Z :=  SA1->A1_COD
                cCodloj2Z :=  SA1->A1_LOJA
            Endif

        Endif

        IF EMPTY(AllTrim(cCodloj2Z)) .OR.  EMPTY(AllTrim(cCodloj2Z))
            FWAlertError("Codigo de Cliente/Fornecedor em branco.", "VA Importador XML")
            Return
        ENDIF

        aNfOrig :={}
        nQtdNfOr := 0
        If XMLCHILDEX (OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE ,"_NFREF") != Nil
            // Verifica se só tem 1 NF Origem
            If ValType(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF) == "O"
                cCHVOri :=  ALLTRIM(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT)
                nQtdNfOr := 1
                aadd(aNfOrig,cCHVOri)
            Else
                For nI := 1 to Len(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF)
                    aadd(aNfOrig,ALLTRIM(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF[nI]:_REFNFE:TEXT))
                    nQtdNfOr++
                Next nI
            Endif
        EndIf
        cTransp   := ""
        If (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe ,"_transp")  != Nil)

            cCgcTrans := oFullXML:_nfeProc:_NFe:_infNFe:_transp:_transporta:_CNPJ:TEXT
            cNmTrans  := UPPER( alltrim(oFullXML:_nfeProc:_NFe:_infNFe:_transp:_transporta:_XNOME:TEXT))
            cTransp   := POSICIONE("SA4",3,XFILIAL("SA4")+cCgcTrans,"A4_COD")

            If Empty(cTransp)
                msgalert("Gentileza VerIficar cadastro da Transportadora!. "+ cCgcTrans+"/"+ cNmTrans)
            EndIf

        EndIf

        cDoc      := STRZERO(VAL(oFullXML:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF:TEXT),6)
        cSerie    := oFullXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
        dEmissao  := StoD(SUBSTR(StrTran(AllTrim(oFullXML:_nfeProc:_NFe:_infNFe:_IDE:_dhEmi:text),"-","") ,1,8))
        DDATABASE := dEmissao
        cEST      := oFullXML:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT
        aCab      := {}
        aItens    := {}

        //Cabeçalho
        aadd(aCab,{"F1_TIPO"    , "D"          , NIL})
        aadd(aCab,{"F1_DOC"     , cDoc         , NIL})
        aadd(aCab,{"F1_SERIE"   , cSerie       , NIL})
        aadd(aCab,{"F1_FORNECE" , cCodCLi2Z    , NIL})
        aadd(aCab,{"F1_LOJA"    , cCodloj2Z    , NIL})
        aadd(aCab,{"F1_EMISSAO" , DDATABASE    , NIL})
        aadd(aCab,{"F1_DTDIGIT" , DDATABASE    , NIL})
        aadd(aCab,{"F1_FORMUL"  , "S"          , NIL})
        aadd(aCab,{"F1_ESPECIE" , "SPED"       , NIL})
        aadd(aCab,{"F1_EST"     , cEST         , NIL})// PEGAR DO XML - DEST
        aadd(aCab,{"F1_DESCONT" , 0            , Nil})
        aadd(aCab,{"F1_SEGURO"  , 0            , Nil})
        aadd(aCab,{"F1_FRETE"   , 0            , Nil})
        aadd(aCab,{"F1_MOEDA"   , 1            , Nil})
        aadd(aCab,{"F1_TXMOEDA" , 1            , Nil})
        aadd(aCab,{"F1_STATUS"  , "A"          , Nil})
        aadd(aCab,{"F1_CHVNFE"  , cChavXML2    , Nil})
        aAdd(aCab,{"VLDAMNFE"   , "S"          , Nil})

        cTesD1 := ""
        cCfopD1 := ""

        //Regras de TES E CFOP por empresa.
        IF cEmpAnt = "11"
            //TES 101 – DEVOLUÇÃO DE VENDA - CFOP 1202 (para clientes do mesmo estado) - CFOP 2202 (para clientes de outros estados).
            cTesD1 := "101"
            IF oFullXML:_nfeProc:_NFe:_infNFe:_dest:_enderDest:_UF:Text == oFullXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_UF:Text
                cCfopD1 := "1202"
            ELSE
                cCfopD1 := "2202"
            ENDIF
        ELSEIF cEmpAnt = "14"

            cTesD1 := "020"

            IF oFullXML:_nfeProc:_NFe:_infNFe:_dest:_enderDest:_UF:Text == oFullXML:_nfeProc:_NFe:_infNFe:_emit:_enderEmit:_UF:Text
                cCfopD1 := "1202"
            ELSE
                cCfopD1 := "2202"
            ENDIF

        ENDIF

        //quando so tem um item
        If  VALTYPE( oFullXML:_nfeProc:_NFe:_infNFe:_det) == "O"

            If Select("cAliD2z") > 0
                cAliD2z->(DbCloseArea())
            EndIf

            cAliD2z  := GetnextAlias()
            cProdB1 := fGetPrd(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_cEAN:TEXT) -- //passar o produto aqui

            IF !EMPTY(alltrim(cProdB1))

                cNfOriD2 := ArrTokStr(aNFOrig)

                cQryD2 := " SELECT * "
                cQryD2 += " FROM ( "
                cQryD2 += " SELECT D2_ITEM, B1_CODBAR, D2_LOCAL, D2_COD, B1_DESC, D2_QUANT, D2_DOC, "
                cQryD2 += " F2_CHVNFE, F2_DOC, D2_SERIE, F4_TESDV, D2_EMISSAO, SD2.R_E_C_N_O_ AS RECNO, D2_TES "
                cQryD2 += " FROM "+RETSQLNAME('SF2') +" SF2 (NOLOCK) "
                cQryD2 += " INNER JOIN " +RETSQLNAME('SD2') + " SD2 (NOLOCK) "
                cQryD2 += " ON D2_FILIAL = "+valtosql(xFilial('SD2'))
                cQryD2 += " AND D2_DOC = F2_DOC "
                cQryD2 += " AND D2_SERIE = F2_SERIE "
                cQryD2 += " AND SD2.D_E_L_E_T_ = '' "
                cQryD2 += " INNER JOIN "+RETSQLNAME('SB1') + " SB1 (NOLOCK) "
                cQryD2 += " ON B1_FILIAL = "+valtosql(xFilial('SB1'))
                cQryD2 += " AND B1_COD = D2_COD
                cQryD2 += " AND SB1.D_E_L_E_T_ = '' "
                cQryD2 += " INNER JOIN "+RETSQLNAME('SF4')+ " SF4 (NOLOCK) "
                cQryD2 += " ON F4_FILIAL = "+valtosql(xFilial('SF4'))
                cQryD2 += " AND F4_CODIGO = D2_TES "
                cQryD2 += " AND SF4.D_E_L_E_T_ = '' "
                cQryD2 += " WHERE F2_FILIAL = "+valtosql(xFilial('SF2'))
                cQryD2 += " AND F2_CHVNFE = " +valtosql(cNfOriD2)
                cQryD2 += " AND B1_COD = "+valtosql(cProdB1)
                cQryD2 += " AND SF2.D_E_L_E_T_ = '' "
                cQryD2 += " ) AS B "
                cQryD2 += " WHERE B.D2_QUANT > 0 "
                cQryD2 += " ORDER BY D2_ITEM ASC "

                DbUseArea(.T., "TOPCONN", TCGenQry( , , cQryD2), "cAliD2z", .F., .T.)

                Count to nTotal
                ProcRegua(nTotal)
                cAliD2z->(DbGoTop())

            ELSE
                lOK := .F.
                msgalert("Erro ao encontrar produto, verifique se o B1_CODBAR esta preenchido ou se o produto esta cadastrado: "+oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_cEAN:TEXT,"ATENCAO")
                Return
            ENDIF

            IF nTotal == val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_prod:_qCom:TEXT)
                IF cAliD2z->(!EOF())
                    While cAliD2z->(!EOF())
                        nXZ19++
                        aItem := {}
                        aadd(aItem,{"D1_ITEM"    , StrZero(nXZ19,4)   ,NIL})  //OK
                        aadd(aItem,{"D1_COD"     , cProdB1            ,NIL})  //OK
                        aadd(aItem,{"D1_UM"      , oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_uCom:TEXT  ,NIL})  //OK
                        aadd(aItem,{"D1_LOCAL"   , "10"               ,NIL})  //OK
                        aadd(aItem,{"D1_QUANT"   , 1                  ,NIL})  //COLOCADO 1 POIS NOS XMLS VEEM SEMPRE DE 1 EM 1 O QUE GERA 1 POR LINHA
                        aadd(aItem,{"D1_VUNIT"   , val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT) ,NIL})  //OK
                        aadd(aItem,{"D1_TOTAL"   , val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET:_PROD:_vUnCom:TEXT)  ,NIL})  //OK
                        aadd(aItem,{"D1_TES"     , cTesD1             ,NIL})  //OK
                        aadd(aItem,{"D1_CF"      , cCfopD1            ,NIL})  //OK
                        aadd(aItem,{"D1_CONTA"   , "112040001"        ,NIL})  //OK
                        aadd(aItem,{"D1_FORNECE" , cCodCLi2Z          ,NIL})  //OK
                        aadd(aItem,{"D1_LOJA"    , cCodloj2Z          ,NIL})  //OK
                        aadd(aItem,{"D1_DOC"     , cDoc               ,NIL})  //OK
                        aadd(aItem,{"D1_SERIE"   , cSerie             ,NIL})  //OK
                        aadd(aItem,{"D1_NFORI"   , alltrim(cAliD2z->F2_DOC)    ,NIL})  //OK
                        aadd(aItem,{"D1_ITEMORI" , cAliD2z->D2_ITEM   ,NIL})  //OK
                        aAdd(aItens,aItem)
                        cAliD2z->(DBSkip())

                    EndDo
                ENDIF
            ELSE
                lOK := .F.
                IF nTotal > 0
                    msgalert("Quantidade dos itens encontrados na NFORI:"+cNfOriD2+"  superior à quantidade devolvida - Cod. Produto: "+cProdB1+ " INCLUIR MANUALMENTE. ","ATENCAO")
                ELSE
                    msgalert("Erro ao encontrar NFORI:"+cNfOriD2+"  |  Cod. Produto: "+cProdB1,"ATENCAO")
                ENDIF
                Return
            ENDIF

        Else
            For nXZ18 := 1 To Len(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET)

                If Select("cAliD2z") > 0
                    cAliD2z->(DbCloseArea())
                EndIf

                cAliD2z  := GetnextAlias()

                cProdB1 := fGetPrd(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_PROD:_cEAN:TEXT) -- //passar o produto aqui

                IF !EMPTY(alltrim(cProdB1))

                    cNfOriD2 := ArrTokStr(aNFOrig)
                    cNfOriD2 := StrTran(cNfOriD2, '|', ',')
                    cNfOriD2 := FormatIn(cNfOriD2, ',')

                    cQryD2 := " SELECT * "
                    cQryD2 += " FROM ( "
                    cQryD2 += " SELECT D2_ITEM, B1_CODBAR, D2_LOCAL, D2_COD, B1_DESC, D2_QUANT, D2_DOC, "
                    cQryD2 += " F2_CHVNFE, F2_DOC, D2_SERIE, F4_TESDV, D2_EMISSAO, SD2.R_E_C_N_O_ AS RECNO, D2_TES "
                    cQryD2 += " FROM "+RETSQLNAME('SF2') +" SF2 (NOLOCK) "
                    cQryD2 += " INNER JOIN " +RETSQLNAME('SD2') + " SD2 (NOLOCK) "
                    cQryD2 += " ON D2_FILIAL = "+valtosql(xFilial('SD2'))
                    cQryD2 += " AND D2_DOC = F2_DOC "
                    cQryD2 += " AND D2_SERIE = F2_SERIE "
                    cQryD2 += " AND SD2.D_E_L_E_T_ = '' "
                    cQryD2 += " INNER JOIN "+RETSQLNAME('SB1') + " SB1 (NOLOCK) "
                    cQryD2 += " ON B1_FILIAL = "+valtosql(xFilial('SB1'))
                    cQryD2 += " AND B1_COD = D2_COD
                    cQryD2 += " AND SB1.D_E_L_E_T_ = '' "
                    cQryD2 += " INNER JOIN "+RETSQLNAME('SF4')+ " SF4 (NOLOCK) "
                    cQryD2 += " ON F4_FILIAL = "+valtosql(xFilial('SF4'))
                    cQryD2 += " AND F4_CODIGO = D2_TES "
                    cQryD2 += " AND SF4.D_E_L_E_T_ = '' "
                    cQryD2 += " WHERE F2_FILIAL = "+valtosql(xFilial('SF2'))
                    cQryD2 += " AND F2_CHVNFE IN "+ cNfOriD2
                    cQryD2 += " AND B1_COD = "+valtosql(cProdB1)
                    cQryD2 += " AND SF2.D_E_L_E_T_ = '' "
                    cQryD2 += " ) AS B "
                    cQryD2 += " WHERE B.D2_QUANT > 0 "
                    cQryD2 += " ORDER BY D2_ITEM ASC "

                    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQryD2), "cAliD2z", .F., .T.)

                    Count to nTotal
                    ProcRegua(nTotal)
                    cAliD2z->(DbGoTop())

                ELSE
                    lOK := .F.
                    msgalert("Erro ao encontrar produto, verifique se o B1_CODBAR esta preenchido, COD do Produto: "+ oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_PROD:_cEAN:TEXT,"ATENCAO")
                    Return
                ENDIF

                IF nTotal == val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_prod:_qCom:TEXT)
                    IF cAliD2z->(!EOF())
                        While cAliD2z->(!EOF())
                            nXZ19++
                            aItem := {}
                            aadd(aItem,{"D1_ITEM"    , StrZero(nXZ19,4)   ,NIL})  //OK
                            aadd(aItem,{"D1_COD"     , cProdB1            ,NIL})  //OK
                            aadd(aItem,{"D1_UM"      , oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_PROD:_uCom:TEXT  ,NIL})  //OK
                            aadd(aItem,{"D1_LOCAL"   , "10"               ,NIL})  //OK
                            aadd(aItem,{"D1_QUANT"   , 1                  ,NIL})  //COLOCADO 1 POIS NOS XMLS VEEM SEMPRE DE 1 EM 1 O QUE GERA 1 POR LINHA
                            aadd(aItem,{"D1_VUNIT"   , val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_PROD:_vUnCom:TEXT) ,NIL})  //PEGAR DO XML
                            aadd(aItem,{"D1_TOTAL"   , val(oFullXML:_NFEPROC:_NFE:_INFNFE:_DET[nXZ18]:_PROD:_vUnCom:TEXT) ,NIL})  //PEGAR DO XML
                            aadd(aItem,{"D1_TES"     , cTesD1             ,NIL})  //OK
                            aadd(aItem,{"D1_CF"      , cCfopD1            ,NIL})  //OK
                            aadd(aItem,{"D1_CONTA"   , "112040001"        ,NIL})  //OK
                            aadd(aItem,{"D1_FORNECE" , cCodCLi2Z          ,NIL})  //OK
                            aadd(aItem,{"D1_LOJA"    , cCodloj2Z          ,NIL})  //OK
                            aadd(aItem,{"D1_DOC"     , cDoc               ,NIL})  //OK
                            aadd(aItem,{"D1_SERIE"   , cSerie             ,NIL})  //OK
                            aadd(aItem,{"D1_NFORI"   , alltrim(cAliD2z->F2_DOC)     ,NIL})  //OK
                            aadd(aItem,{"D1_ITEMORI" , cAliD2z->D2_ITEM   ,NIL})  //OK
                            aAdd(aItens,aItem)
                            cAliD2z->(DBSkip())

                        EndDo
                    ENDIF
                ELSE
                    lOK := .F.
                    IF nTotal > 0
                        msgalert("Quantidade dos itens encontrados na NFORI:"+cNfOriD2+"  superior à quantidade devolvida - Cod. Produto: "+cProdB1 + " INCLUIR MANUALMENTE. ","ATENCAO")
                    ELSE
                        msgalert("Erro ao encontrar NFORI:"+cNfOriD2+"  |  Cod. Produto: "+cProdB1,"ATENCAO")
                    ENDIF
                    Return
                ENDIF

            Next nXZ18

        EndIf

        IF lOK
            nOpc := 3
            //3-Inclusão / 4-Classificação / 5-Exclusão
            MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItens,nOpc)

            If lMsErroAuto
                MostraErro()
            Else

                cMsg := "Documento integrado com sucesso!!!"
                msgalert(cMsg,"")

            EndIf
        EndIf

    Else
        cMsg :="Não foram encontrados arquivos. Pasta C:\XML "
        msgalert(cMsg,"ATENCAO")
    EndIf

Return



/*/{Protheus.doc} getXML
	(long_description)
	@type  Static Function
	@author user
	@since 07/11/2022
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
/*/
Static Function getXML(cArquivo)

    Local oFile := nil
    Local cArqLido := ""

    oFile := FWFileReader():New(cArquivo)
    oFile:setBufferSize(4096)

    if ( oFile:Open() )
        cArqLido :=  oFile:FullRead()
    Endif
    oFile:Close()

    FreeObj(oFile)
Return cArqLido



Static Function fGetPrd(cPrdXML)

    Local cRetPrd := ""
    Local cEol := chr(10)

    cSql := "  SELECT B1_COD "  + cEol
    cSql += "  FROM dbo."+ RetSQLName("SB1") +" (NOLOCK) SB1 " + cEol
    cSql += "  WHERE SB1.D_E_L_E_T_ =  '' " + cEol
    cSql += "  AND B1_CODBAR =  " + valtosql(cPrdXML)

    If (Select("TMPSB1") <> 0)
        dbSelectArea("TMPSB1")
        dbCloseArea()
    Endif
    //U_VRN0159(cSql)
    //    lGet := .t.
    TCQuery cSql NEW ALIAS "TMPSB1"

    IF  TMPSB1->(!Eof())
        cRetPrd := TMPSB1->B1_COD
    Endif
Return cRetPrd



Static Function fGetDev(cProd,nQCOM,aNfOrig,cCdForn,cLJFor)

    Local cNFOrig := ''
    Local aRetDev := {}

    cNFOrig := ArrTokStr(aNFOrig)    // resultado '01|02|03'
    cNFOrig := StrTran(cNFOrig, '|', ',') // resultado '01,02,03'
    cNFOrig := '%' + FormatIn(cNFOrig, ',') + '%' // resultado '('01','02','03)'

    if cEmpAnt == "14"
        cForBudd := "638545"
    elseif  cEmpAnt == "11"
        cForBudd := "035484"
    endif

    If Select('TMPSD1') <> 0
        TMPSD1->(dbCloseArea())
    EndIf
    IF (ALLTRIM(cProd) == 'F50286190013650052')
        BeginSql Alias 'TMPSD1'
            SELECT *
            FROM
                (
                    SELECT
                        B1_CODBAR,
                        D1_LOCAL,
                        D1_COD,
                        B1_DESC,
                        /*(D2_QUANT-ISNULL(D1_QUANT, 0)) AS*/
                        D1_QUANT,
                        D1_DOC,
                        F1_CHVNFE,
                        D1_SERIE,
                        D1_ITEM,
                        D1_VUNIT,
                        F4_TESDV,
                        D1_EMISSAO,
                        SD1.R_E_C_N_O_ AS RECNO,
                        D1_TES
                    FROM
                        %Table:SF1% SF1 (NOLOCK)
                    INNER JOIN %Table:SD1% SD1 (NOLOCK)
                    ON D1_FILIAL = %xFilial:SD1%
                        AND D1_DOC = F1_DOC
                        AND D1_SERIE = F1_SERIE
                        AND SD1.%NotDel%
                    INNER JOIN %Table:SB1% SB1 (NOLOCK)
                    ON B1_FILIAL = %xFilial:SB1%
                        AND B1_COD = D1_COD
                        AND SB1.%NotDel%
                    INNER JOIN %Table:SF4% SF4 (NOLOCK)
                    ON F4_FILIAL = %xFilial:Sf4%
                        AND F4_CODIGO = D1_TES
                        AND SF4.%NotDel%
                    WHERE
                        F1_FILIAL = %xFilial:SF1%
                        AND F1_CHVNFE IN %Exp:cNFOrig%
                        AND B1_COD = %Exp:cProd%
                        AND D1_DOC = '781782'
                        AND SF1.%NotDel%
                ) AS B
            WHERE
                B.D1_QUANT > 0
            ORDER BY
                D1_EMISSAO DESC
        EndSql
    ELSE
        BeginSql Alias 'TMPSD1'
            SELECT *
            FROM
                (
                    SELECT
                        B1_CODBAR,
                        D1_LOCAL,
                        D1_COD,
                        B1_DESC,
                        /*(D2_QUANT-ISNULL(D1_QUANT, 0)) AS*/
                        D1_QUANT,
                        D1_DOC,
                        F1_CHVNFE,
                        D1_SERIE,
                        D1_ITEM,
                        D1_VUNIT,
                        F4_TESDV,
                        D1_EMISSAO,
                        SD1.R_E_C_N_O_ AS RECNO,
                        D1_TES
                    FROM
                        %Table:SF1% SF1 (NOLOCK)
                    INNER JOIN %Table:SD1% SD1 (NOLOCK)
                    ON D1_FILIAL = %xFilial:SD1%
                        AND D1_DOC = F1_DOC
                        AND D1_SERIE = F1_SERIE
                        AND SD1.%NotDel%
                    INNER JOIN %Table:SB1% SB1 (NOLOCK)
                    ON B1_FILIAL = %xFilial:SB1%
                        AND B1_COD = D1_COD
                        AND SB1.%NotDel%
                    INNER JOIN %Table:SF4% SF4 (NOLOCK)
                    ON F4_FILIAL = %xFilial:Sf4%
                        AND F4_CODIGO = D1_TES
                        AND SF4.%NotDel%
                    WHERE
                        F1_FILIAL = %xFilial:SF1%
                        AND F1_CHVNFE IN %Exp:cNFOrig%
                        AND B1_COD = %Exp:cProd%
                        AND SF1.%NotDel%
                ) AS B
            WHERE
                B.D1_QUANT > 0
            ORDER BY
                D1_EMISSAO DESC
        EndSql
    ENDIF
    nSld := nQCOM
    While TMPSD1->(!eof())

        IF EMPTY(TMPSD1->F4_TESDV) .AND. cEmpAnt == "14"
            cTESDev := "520"
        Else
            cTESDEV := TMPSD1->F4_TESDV
        ENDIF

        aadd( aRetDev ,{TMPSD1->D1_DOC;
            ,TMPSD1->D1_SERIE ;
            ,TMPSD1->D1_ITEM  ;
            ,TMPSD1->D1_VUNIT ;
            ,cTESDev ;
            ,TMPSD1->D1_QUANT;
            })

        TMPSD1->(dbskip())
    Enddo

Return aRetDev


static function fGetRSC6(aSC6)

    Local nRecSC6 := 0
    Local cEol := CHR(10)

    cSql := " SELECT R_E_C_N_O_ RECSC6 " + cEol
    cSql += " FROM dbo."+ RetSQLName("SC6") +" (NOLOCK) TBL1 " + cEol
    cSql += " WHERE TBL1.D_E_L_E_T_        = '' " +cEol
    cSql += "       AND TBL1.C6_FILIAL     = "+VALTOSQL(xFilial("SC6"))+cEol
    cSql += "       AND TBL1.C6_CLI        = "+VALTOSQL(aSC6[1])+cEol
    cSql += "       AND TBL1.C6_LOJA       = "+VALTOSQL(aSC6[2])+cEol
    cSql += "       AND TBL1.C6_PRODUTO    = "+VALTOSQL(aSC6[3])+cEol
    cSql += "       AND TBL1.C6_NFORI      = "+VALTOSQL(aSC6[4])+cEol
    cSql += "       AND TBL1.C6_SERIORI    = "+VALTOSQL(aSC6[5])+cEol
    cSql += "       AND TBL1.C6_ITEMORI    = "+VALTOSQL(aSC6[6])+cEol
    cSql += "       AND TBL1.C6_NUM        = "+VALTOSQL(aSC6[7])+cEol

    If Select('TMPSC6') <> 0
        TMPSC6->(dbCloseArea())
    EndIf

    TCQuery cSql Alias TMPSC6 New

    IF  TMPSC6->(!eof())
        nRecSC6 := TMPSC6->RECSC6
    ENDIF
Return nRecSC6

Static Function V167Log(_Texto,lCria,cPedido)

    Local cArqTxt := cEmpAnt+'_'+cFilAnt+"_Pedido_"+cPedido+".txt"
    Local oFile   := FWFileWriter():new(cArqTxt,.T.)

    Static cEOL := CHR(13)+CHR(10)

    If  lCria
        //--------------- Se o arquivo já existe, apaga -------------------
        If  (oFile:Exists())
            oFile:Erase()
        EndIf

        //-------------- Cria o arquivo --------------
        If  (oFile:Create())
            //-------------- Se criou com sucesso, escreve ------------------------------
            oFile:Write('Documentos Vinculados em Pedidos a serem ajustados '+cEol)
            oFile:Write('---------------------------------------------------'+cEol)
        EndIf
    Else
        //grava os dados do registro por linha
        If  oFile:Exists()
            oFile:Open(FO_WRITE)
            oFile:GoBottom()
            oFile:Write(_Texto+cEOL)
        EndIf

    EndIf

    //-------------- Fecha o arquivo -----------
    oFile:Close()

Return

//22/07/2025
//DANIEL VICTOR DA ROSA - PERSONALITEC
//Função para percorrer diretórios e subdiretórios, buscando arquivos XML E VALIDAR A CHAVE
//zRecurDir
Static Function zPerXml(cPasta, cMascara, dAPartir,cChavXML2)
    Local aArea      := GetArea()
    //Local cTempoIni  := Time()
    //Local cTempoFim  := ""
    Local cError     := ""
    Local cWarning   := ""
    Local aArquivos  := {}
    Local aPastas    := {}
    Local aTemp      := {}
    Local aArqOrig   := {}
    Local nAtual     := 0
    Local nAux       := 0
    Local nTamanho   := 0
    Local nTamAux    := 0
    Local NXA5       := 0
    Local cRetXML    := ""
    Default cPasta   := ""
    Default cMascara := "*.xml"
    Default cChavXML2:= ""
    Default dAPartir := sToD("")

    //Se tiver pasta e máscara
    If ! Empty(cPasta) .And. ! Empty(cMascara)

        //Caso não tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
        cPasta += Iif(SubStr(cPasta, Len(cPasta), 1) != "\", "\", "")
        //Pega as pastas da raíz
        aPastas := Directory(cPasta + "*.*", "D")

        //Percorre todas as pastas do Array (Conforme ele for sendo atualizado, volta pro laço)
        For nAtual := 1 To Len(aPastas)
            //Se não tiver ponto no nome, e for do tipo D (Diretório)
            If ! "." $ Alltrim(aPastas[nAtual][1]) .And. aPastas[nAtual][5] == "D"
                //Se não tiver a pasta raíz no nome, adiciona, por exemplo, "SubPasta" -> "C:\TOTVS\SubPasta"
                If ! cPasta $ aPastas[nAtual][1]
                    aPastas[nAtual][1] := cPasta + aPastas[nAtual][1]
                EndIf
                //Caso não tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
                aPastas[nAtual][1] += Iif(SubStr(aPastas[nAtual][1], Len(aPastas[nAtual][1]), 1) != "\", "\", "")
                //Pegatodas as pastas dentro dessa
                aTemp := Directory(aPastas[nAtual][1] + "*.*", "D")
                //Percorre as subpastas dentro, e adiciona o texto a esquerda, por exemplo, "PastaX" -> "C:\TOTVS\SubPasta\PastaX"
                For nAux := 1 To Len(aTemp)
                    aTemp[nAux][1] := aPastas[nAtual][1] + aTemp[nAux][1]
                Next
                //Pega o tamanho das subpastas, e o tamanho atual das pastas
                nTamanho := Len(aTemp)
                nTamAux  := Len(aPastas)
                //Redimensiona o array das pastas, aumentando conforme o tamanho das subpastas
                aSize(aPastas, Len(aPastas) + nTamanho)
                //Copia as subpastas para dentro da pasta a partir da última posição
                aCopy(aTemp, aPastas, , , nTamAux + 1)
            EndIf
        Next
        //Pega o tamanho das pastas
        nTamanho := Len(aPastas)
        //Percorre todas as pastas
        For nAtual := 1 To nTamanho
            //Se tiver pasta a ser validada
            If nAtual <= Len(aPastas)
                //Se tiver ponto no nome, ou for diferente de D (Diretório)
                If "." $ Alltrim(aPastas[nAtual][1]) .Or. aPastas[nAtual][5] != "D"
                    //Exclui aposição atual do Array
                    aDel(aPastas, nAtual)
                    //Redimensiona o Array, diminuindo 1 posição
                    aSize(aPastas, Len(aPastas) - 1)
                    //Altera variáveis de controle, diminuindo elas
                    nTamanho--
                    nAtual--
                EndIf
            EndIf
        Next
        //Ordena o Array por ordem alfabética
        aSort(aPastas)
        //Pega os arquivos da pasta raíz
        aArquivos := Directory(cPasta + cMascara)
        //Percorre todos os arquivos
        For nAtual := 1 To Len(aArquivos)
            //Se a pasta não tiver no nome do arquivo, adiciona, por exemplo, "arquivo.xml" -> "C:\TOTVS\arquivo.xml"
            If ! cPasta $ aArquivos[nAtual][1]
                aArquivos[nAtual][1] := cPasta + aArquivos[nAtual][1]
            EndIf
        Next
        //Percorre todas as pastas / subpastas encontradas
        For nAtual := 1 To Len(aPastas)
            //Se a pasta realmente existe
            If ExistDir(aPastas[nAtual][1])
                //Caso não tenha "\" no fim adiciona, por exemplo, "C:\TOTVS" -> "C:\TOTVS\"
                aPastas[nAtual][1] += Iif(SubStr(aPastas[nAtual][1], Len(aPastas[nAtual][1]), 1) != "\", "\", "")
                //Pega todos os arquivos dessa subpasta filtrando a máscara
                aTemp := Directory(aPastas[nAtual][1] + cMascara)
                //Percorre todos os arquivos encontrados
                For nAux := 1 To Len(aTemp)
                    //Adiciona o caminho completo da subpasta, por exemplo, "arquivo2.xml" -> "C:\TOTVS\SubPasta\arquivo2.xml"
                    aTemp[nAux][1] := aPastas[nAtual][1] + aTemp[nAux][1]
                Next
                //Pega o tamanho do array dos arquivos encontrados, e o tamanho do array de arquivos que serão retornados
                nTamanho := Len(aTemp)
                nTamAux  := Len(aArquivos)
                //Aumento o tamanho do array de Arquivos, com o tamanho dos encontrados
                aSize(aArquivos, Len(aArquivos) + nTamanho)
                //Copia o conteúdo dos enontrados para dentro do array de Arquivos
                aCopy(aTemp, aArquivos, , , nTamAux + 1)
            EndIf
        Next
        //Copia para um novo array de backup
        aArqOrig := aClone(aArquivos)
        //Se tiver data de filtragem
        If ! Empty(dAPartir)
            //Enquanto houver arquivos
            nAtual := 0
            While nAtual <= Len(aArquivos)
                nAtual++
                //Se existir arquivos válidos a serem processados
                If Len(aArquivos) >= nAtual
                    //Se na pasta atual, a data do arquivo NÃO for maior que a data de corte
                    If ! aArquivos[nAtual][3] >= dAPartir
                        //Deleta a posição atual o array de Arquivos'
                        aDel(aArquivos, nAtual)
                        //Redimensiona o Array, diminuindo uma posição
                        aSize(aArquivos, Len(aArquivos) - 1)
                        nAtual--
                    EndIf
                EndIf
            EndDo
        EndIf
    EndIf

    IF len(aArquivos) <> 0
        FOR NXA5 := 1 TO Len(aArquivos)
            cXML1 :=  getXML(aArquivos[NXA5][1])
            cXML1 := StrTran( cXML1, "ns2:", "" )
            oFullXML := XmlParser(cXML1,"_",@cError,@cWarning)
            cChave   :=  Right(AllTrim(oFullXML:_nfeProc:_NFe:_InfNfe:_Id:Text),44)
            IF cChavXML2 <> ""
                IF cChave == cChavXML2
                    cRetXML := aArquivos[NXA5][1]
                ENDIF
            ENDIF
        NEXT NXA5
    EndIf

    RestArea(aArea)
    //não utilizado neste fonte pois ao tentar incluir um nota que já foi incluida ocorre o erro
    //padrão do protheus  - AJUDA:EXISTNF
    IF !EMPTY(cRetXML)

        cQuery10 := " SELECT C5_NUM FROM "+RETSQLNAME('SC5')
        cQuery10 += " WHERE D_E_L_E_T_ = '' "
        cQuery10 += " AND C5_CHVVRN = "+VALTOSQL(cChavXML2)
        cAlias10 := GetnextAlias()
        MPSysOpenQuery(cQuery10,cAlias10)

        IF (cAlias10)->(!EOF())
            Return ""
        ENDIF
    Else
        return "1"
    ENDIF

Return cRetXML
