#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description
TELA DE IMPORTAÇÃO DE XML
DANIEL VICTOR DA ROSA - PERSONALITEC
@since 10/06/2025
/*/
//--------------------------------------------------------------
User Function VRN0167()

    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := SPACE(44)
    Local oSay1
    Local oSay3
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "Imp Nota Devolucao LTD" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL

    @ 010, 061 SAY oSay1 PROMPT "Atenção: Salvar aquivo em uma pasta no C:\XML" SIZE 123, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 041 MSGET oGet1 VAR cGet1 SIZE 167, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 076, 170 BUTTON oButton1 PROMPT "IMPORTAR" SIZE 037, 009 OF oDlg ACTION ProcXml9(cGet1) PIXEL
    @ 045, 041 SAY oSay3 PROMPT "Chave do XML" SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 108, 206 BUTTON oButton2 PROMPT "SAIR" SIZE 037, 009 OF oDlg ACTION oDlg:end() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcXml9
    (long_description)
    @type  Function
    @author Gabriel
    @since 29/01/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ProcXml9(cChaveXML)

    Private cXMLFile  :="" // guarda o caminho absoluto do xml, setar na mao quando o pedido ja estiver gerado
    Private cPedVend := "" // Numero do pedido de Venda que foi gravado, caso ja tenha sido gerado setar na mao
    Private cNFBudd  := ""
    Private cSNFBudd := ""
    Private oFullXML := Nil
    Private cChavXML2 := cChaveXML
    Private cPedido  := ""
    Private lMens := .F.
    Private aDocOriSC6 := {}

    IF Alltrim(cChavXML2) == ""
        FWAlertError("Chave do XML não informada", "Atenção")
        Return
    ELSE

        //FUNÇÃO RESPONSÁVEL POR PERCORRER TODOS OS XML DA PASTA E PEGAR O ARQUIVO XML COM BASE NA CHAVE DIGITADA
        FWMsgRun(, {||   cXMLFile := zRecurDir("C:\XML\",,,cChavXML2) }, "VAREJO FACIL","Aguarde Processando xml" )

        IF !Empty(cXMLFile) .AND. cXMLFile <> "1"
            //Gera o Pedido de Venda / Gera SF2-SD2 */ DESCOMENTAR ESSA PARTE AO FICAR PRONTO O FONTE.
            FWMsgRun(, {||  fGetXML(cXMLFile) }, "VAREJO FACIL","Aguarde Processando xml" )
            IF lMens
                MsgInfo("XML importado com sucesso!","")
            ENDIF
        ELSEIF cXMLFile == "1"
            FWAlertError("CHAVE XML NAO ENCONTRADA NA PASTA C:\XML\ ->  "+cChavXML2, "ATENCAO")
        ELSE
            FWAlertError("O XML COM A CHAVE: "+cChavXML2 +" JA FOI IMPORTADO.", "ATENCAO")
        ENDIF

    ENDIF

Return

/*/{Protheus.doc} fGetXML
   Função para retornar o Objeto do XML, inicialmente está chumbado, pq eu nao se se usuario deverá ter acesso a essa rotina
    @type  Function
    @author Gabriel
    @since 29/01/2024
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function fGetXML(cXmlName)

    Local nDev
    Local cWarning      := ""
    Local cError        := ""
    Local cCNPJCli      := ""
    Local nI
    Local nX
    Private lMsErroAuto    	:= .F.
    Private lAutoErrNoFile 	:= .F.

    aRetSM0       := FWLoadSM0()
    If !Empty(alltrim(cXmlName))

        cXML :=  getXML(cXmlName)
        cXML := StrTran( cXML, "ns2:", "" )

        oFullXML := XmlParser(cXML,"_",@cError,@cWarning)
        cChave   :=  Right(AllTrim(oFullXML:_nfeProc:_NFe:_InfNfe:_Id:Text),44)
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

        If (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_dest ,"_CNPJ")  != Nil)
            cCNPJCli	:=  oFullXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT
            cTpPes := "J"
        ELSEIF (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_dest ,"_CPF")  != Nil)
            cCNPJCli	:=  oFullXML:_nfeProc:_NFe:_infNFe:_dest:_CPF:TEXT
            cTpPes := "F"
        Endif

        DBSELECTAREA("SA2")
        SA2->(DbSetOrder(3))
        If !SA2->( DbSeek(xfilial("SA2")+cCNPJCli))
            FWAlertError("Fornecedor não encontrado", "VA Importador XML")
            Return
        Endif
        aNfOrig :={}
        nQtdNfOr := 0
        If XMLCHILDEX(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE ,"_NFREF") != Nil
            // Verifica se só tem 1 NF Origem
            If ValType(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF) == "O"

                cCHVOri :=  ALLTRIM(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NFREF:_REFNFE:TEXT)
                nQtdNfOr := 1
                aadd(aNfOrig,cCHVOri)
            Else
                // Alimenta array com as Chaves para gravar na ZA7

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
        // cCondPag := U_VRN0117P('REM_CNDPAG')
        aCabec := {}
        cDoc       := STRZERO(VAL(oFullXML:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF:TEXT),6)
        cSerie     := oFullXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT
        dEmissao  := StoD(SUBSTR(StrTran(AllTrim(oFullXML:_nfeProc:_NFe:_infNFe:_IDE:_dhEmi:text),"-","") ,1,8))
        DDATABASE:=  dEmissao

        cPedido   := GetSxeNum("SC5","C5_NUM")
        SC5->(DbSetOrder(1))
        While SC5->(DBSeek(xFilial('SC5')+cPedido))
            cPedido   := GetSxeNum("SC5","C5_NUM")
        EndDo

        ConfirmSX8()
        cCondPag :=  '002'
        AADD(aCabec, {"C5_NUM"		, cPedido			 			, Nil})
        AADD(aCabec, {"C5_TIPO"		, "D"							, Nil})
        AADD(aCabec, {"C5_CLIENTE"	, SA2->A2_COD					, Nil})
        AADD(aCabec, {"C5_LOJACLI"	, SA2->A2_LOJA					, Nil})
        AADD(aCabec, {"C5_NOMECLI"	, SA2->A2_NOME					, Nil})
        AADD(aCabec, {"C5_TIPO1"	, "N"							, Nil})
        AADD(aCabec, {"C5_LOJAENT"	, SA2->A2_LOJA					, Nil})
        AADD(aCabec, {"C5_CONDPAG"	, cCondPag						, Nil})
        AADD(aCabec, {"C5_EMISSAO"	, DDATABASE                     , Nil})
        AADD(aCabec, {"C5_HREMIS"	, TIME()						, Nil})
        AADD(aCabec, {"C5_MOEDA"	, 1								, Nil})
        AADD(aCabec, {"C5_TPFRETE"	, "C"							, Nil})
        AADD(aCabec, {"C5_TRANSP"	, cTransp						, Nil})
        AADD(aCabec, {"C5_TIPOPED"  , "F"                           , Nil})
        AADD(aCabec, {"C5_INDPRES"  , "0"                           , Nil})

        V167Log('',.T.,cPedido)

        //quando so tem um item
        If  VALTYPE( oFullXML:_nfeProc:_NFe:_infNFe:_det) == "O"

            aItens := {}
            cItem  := "01"

            cPrdXML :=  alltrim( oFullXML:_nfeProc:_NFe:_infNFe:_det:_PROD:_CEAN:TEXT)
            cProd   :=  fGetPrd(cPrdXML)

            If  Empty(cProd)
                Alert('Produto '+ AllTrim(cPrdXML)+' não cadastrado ou não encontrado, favor verificar !!!')
                cPedido := ""
                Return
            EndIf

            nQCOM   :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det:_PROD:_QCOM:TEXT)
            nVUNCOM :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det:_PROD:_VUNCOM:TEXT)
            nVPROD  :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det:_PROD:_VPROD:TEXT)
            IF EMPTY(aNfOrig)
                IF VALTYPE(oFullXML:_nfeProc:_NFe:_infNFe:_det:_DFeReferenciado:_chaveAcesso:TEXT) == "C"
                    aNfOrig := {oFullXML:_nfeProc:_NFe:_infNFe:_det:_DFeReferenciado:_chaveAcesso:TEXT}
                ENDIF
            ENDIF
            aNFDev  :=  fGetDev(cProd,nQCOM,aNfOrig,SA2->A2_COD,SA2->A2_LOJA	)

            IF LEN(aNFDev) == 0
                Alert('XML sem a NFE de Referencia, favor verificar !!!')
                cPedido := ""
                Return
            ENDIF

            For nDev := 1 to Len(aNFDev)

                aLinha := {}
                If  nQCOM <= aNFDev[nDev][6]
                    nQuant := nQCOM
                    nQCOM  := 0
                Else
                    nQuant := aNFDev[nDev][6]
                    nQCOM  -= aNFDev[nDev][6]
                EndIf

                IF  nVUNCOM != aNFDev[nDev][4]
                    nVUNCOM := aNFDev[nDev][4]
                EndIf

                aadd(aLinha,{"C6_ITEM"   , cItem            , Nil})
                aadd(aLinha,{"C6_PRODUTO", cProd            , Nil})

                aadd(aLinha,{"C6_QTDVEN" , nQuant           , Nil})

                /*If  AllTrim(cProd) = 'F00223260000013322'
                        aadd(aLinha,{"C6_PRCVEN" , 37.5066670000, Nil})
                        aadd(aLinha,{"C6_PRUNIT" , 37.5066670000, Nil})
                    ElseIf  AllTrim(cProd) = 'F00223260000013434'
                        aadd(aLinha,{"C6_PRCVEN" , 38.5666670000, Nil})
                        aadd(aLinha,{"C6_PRUNIT" , 38.5666670000, Nil})
                Else*/
                aadd(aLinha,{"C6_PRCVEN" , nVUNCOM      , Nil})
                aadd(aLinha,{"C6_PRUNIT" , nVUNCOM      , Nil})
                //EndIf

                aadd(aLinha,{"C6_LOCAL"  , '10'             , Nil})
                aadd(aLinha,{"C6_TES"    , aNFDev[nDev][5]  , Nil})
                aadd(aLinha,{"C6_NFORI"  , aNFDev[nDev][1]  , Nil})
                aadd(aLinha,{"C6_SERIORI", aNFDev[nDev][2]  , Nil})
                aadd(aLinha,{"C6_ITEMORI", aNFDev[nDev][3]  , Nil})

                aLinha := FWVetByDic( aLinha, "SC6" )
                aadd(aItens, aLinha)

                SC6->(DbSetOrder(5))
                SC6->(DbSeek(xFilial('SC6')+SA2->(A2_COD+A2_LOJA)+cProd+aNFDev[nDev][1]+aNFDev[nDev][2]+aNFDev[nDev][3]))
                While SC6->(C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI) == ;
                        xFilial('SC6')+SA2->(A2_COD+A2_LOJA)+cProd+aNFDev[nDev][1]+aNFDev[nDev][2]+aNFDev[nDev][3]

                    aAdd(aDocOriSC6,{SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_SERIORI, SC6->C6_NFORI, SC6->C6_ITEMORI})

                    V167Log(SC6->C6_FILIAL+';'+SC6->C6_NUM+';'+SC6->C6_ITEM+';'+;
                        SC6->C6_PRODUTO+';'+SC6->C6_SERIORI+';'+SC6->C6_NFORI+';'+;
                        SC6->C6_ITEMORI,;
                        .F.,cPedido)

                    Reclock('SC6',.F.)
                    SC6->C6_SERIORI := ''
                    SC6->C6_NFORI   := ''
                    SC6->C6_ITEMORI := ''
                    MsUnlock()

                    SC6->(DbSkip())
                EndDo

                If  Empty(NQCOM)
                    Exit
                EndIf

            Next nDev

        Else
            aItens := {}
            cItem  := "00"
            For nI := 1 to Len( oFullXML:_nfeProc:_NFe:_infNFe:_det)

                cPrdXML :=  alltrim( oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_PROD:_CEAN:TEXT)
                cProd   :=  fGetPrd(cPrdXML)

                If  Empty(cProd)
                    Alert('Produto '+ AllTrim(cPrdXML)+' não cadastrado ou não encontrado, favor verificar !!!')
                    //cProTst += cPrdXML +CRLF
                    cPedido := ""
                    Return
                EndIf

                nQCOM   :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_PROD:_QCOM:TEXT)
                nVUNCOM :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_PROD:_VUNCOM:TEXT)
                nVPROD  :=  VAL(oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_PROD:_VPROD:TEXT)
                IF EMPTY(aNfOrig)
                    IF VALTYPE(oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_DFeReferenciado:_chaveAcesso:TEXT) == "C"
                        aNfOrig := {oFullXML:_nfeProc:_NFe:_infNFe:_det[nI]:_DFeReferenciado:_chaveAcesso:TEXT}
                    ENDIF
                ENDIF
                aNFDev  :=  fGetDev(cProd,nQCOM,aNfOrig,SA2->A2_COD,SA2->A2_LOJA)

                nQuant := 0
                For nDev := 1 to Len(aNFDev)

                    If  nQCOM <= aNFDev[nDev][6]
                        nQuant := nQCOM
                        nQCOM  := 0
                    Else
                        nQuant := aNFDev[nDev][6]
                        nQCOM  -= aNFDev[nDev][6]
                    EndIf

                    IF  nVUNCOM != aNFDev[nDev][4]
                        nVUNCOM := aNFDev[nDev][4]
                    EndIf

                    aLinha := {}

                    cItem  :=  SOMA1(cItem)
                    aadd(aLinha,{"C6_ITEM"   , cItem          , Nil})
                    aadd(aLinha,{"C6_PRODUTO", cProd          , Nil})
                    aadd(aLinha,{"C6_QTDVEN" , nQuant         , Nil})

                    /*If  AllTrim(cProd) = 'F00223260000013322'
                            aadd(aLinha,{"C6_PRCVEN" , 37.5066670000, Nil})
                            aadd(aLinha,{"C6_PRUNIT" , 37.5066670000, Nil})
                        ElseIf  AllTrim(cProd) = 'F00223260000013434'
                            aadd(aLinha,{"C6_PRCVEN" , 38.5666670000, Nil})
                            aadd(aLinha,{"C6_PRUNIT" , 38.5666670000, Nil})
                    Else*/
                    aadd(aLinha,{"C6_PRCVEN" , nVUNCOM      , Nil})
                    aadd(aLinha,{"C6_PRUNIT" , nVUNCOM      , Nil})
                    //EndIf

                    cTesz := aNFDev[nDev][5]
                    cNForiz := aNFDev[nDev][1]
                    cSerOriz := aNFDev[nDev][2]
                    cItemOrz := aNFDev[nDev][3]

                    aadd(aLinha,{"C6_LOCAL"  , '10'           , Nil})
                    aadd(aLinha,{"C6_TES"    , cTesz, Nil})
                    aadd(aLinha,{"C6_NFORI"  , cNForiz, Nil})
                    aadd(aLinha,{"C6_SERIORI", cSerOriz, Nil})
                    aadd(aLinha,{"C6_ITEMORI", cItemOrz, Nil})

                    aLinha := FWVetByDic( aLinha, "SC6" )
                    aadd(aItens, aLinha)

                    SC6->(DbSetOrder(5))
                    SC6->(DbSeek(xFilial('SC6')+SA2->(A2_COD+A2_LOJA)+cProd+aNFDev[nDev][1]+aNFDev[nDev][2]+aNFDev[nDev][3]))
                    While SC6->(C6_FILIAL+C6_CLI+C6_LOJA+C6_PRODUTO+C6_NFORI+C6_SERIORI+C6_ITEMORI) == ;
                            xFilial('SC6')+SA2->(A2_COD+A2_LOJA)+cProd+aNFDev[nDev][1]+aNFDev[nDev][2]+aNFDev[nDev][3]

                        aAdd(aDocOriSC6,{SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, SC6->C6_PRODUTO, SC6->C6_SERIORI, SC6->C6_NFORI, SC6->C6_ITEMORI})

                        V167Log(SC6->C6_FILIAL+';'+SC6->C6_NUM+';'+SC6->C6_ITEM+';'+;
                            SC6->C6_PRODUTO+';'+SC6->C6_SERIORI+';'+SC6->C6_NFORI+';'+;
                            SC6->C6_ITEMORI,;
                            .F.,cPedido)

                        Reclock('SC6',.F.)
                        SC6->C6_SERIORI := ''
                        SC6->C6_NFORI   := ''
                        SC6->C6_ITEMORI := ''
                        MsUnlock()

                        SC6->(DbSkip())
                    EndDo

                    If  Empty(NQCOM)
                        Exit
                    EndIf

                Next nDev
            Next nI

        EndIf
        aCabec := FWVetByDic( aCabec, "SC5" )
        lMsErroAuto := .F.

        IF len(aItens) == 0
            Alert('Nenhum item para importar, favor verificar a NFe de Referencia !!!')
            Return
        ENDIF

        MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 3, .F.)
        IF lMsErroAuto
            MostraErro()
        else

            SC5->(DbSetOrder(1))
            IF  SC5->( dbSeek(xFilial("SC5")+cPedido))
                RECLOCK('SC5', .F.)
                SC5->C5_CHVVRN := cChavXML2
                SC5->(MSUNLOCK())
            ENDIF

            fPutSF2(cPedido)
        ENDIF
        // Next n1
    Else
        cMsg :="Não foram encontrados arquivos. Pasta C:\XML "
        msgalert(cMsg,"WCT")
    EndIf

    If  !Empty(aDocOriSC6)
        For nX:=1 to Len(aDocOriSC6)
            SC6->(DbSetOrder(1))
            SC6->(DbSeek(aDocOriSC6[nX][1]+aDocOriSC6[nX][2]+aDocOriSC6[nX][3]+aDocOriSC6[nX][4]))
            If  SC6->(C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO) == ;
                    (aDocOriSC6[nX][1]+aDocOriSC6[nX][2]+aDocOriSC6[nX][3]+aDocOriSC6[nX][4])

                //aAdd(aDocOriSC6,{SC6->C6_FILIAL, SC6->C6_NUM, SC6->ITEM, SC6->C6_PRODUTO, SC6->C6_SERIORI, SC6->C6_NFORI, SC6->C6_ITEMORI})

                Reclock('SC6',.F.)
                SC6->C6_SERIORI := aDocOriSC6[nX][5]
                SC6->C6_NFORI   := aDocOriSC6[nX][6]
                SC6->C6_ITEMORI := aDocOriSC6[nX][7]
                MsUnlock()
            Endif
        Next nX
    EndIf

Return

Static Function fPutSF2(cPedido)

    Local nX
    lOCAL cEol := chr(10)
    lOCAL ADOCORI:= {}
    Local bFiscalSF2 := {|| .T. }
    Local bFiscalSD2 := {|| .T. }
    //-- Variáveis utilizadas para o controle de erro da rotina automática
    Private lMsErroAuto     := .F.
    Private lAutoErrNoFile  := .T.
    aStruSF2    :=  SF2->(dbStruct())
    oDet       := OFULLXML:_NFEPROC:_NFE:_INFNFE:_DET

    // Aadd(aCabs,"")
    aCabs := {}
    //Montagem do cabeçalho do Documento Fiscal
    nF2FILIAL   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_FILIAL"})
    nF2TIPO     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPO"})
    nF2DOC      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DOC"})
    nF2ESPECIE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_ESPECIE"})
    nF2SERIE    := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_SERIE"})
    nF2EMISSAO  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EMISSAO"})
    nF2HORA     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_HORA"})
    nF2CLIENTE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENTE"})
    nF2LOJA     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJA"})
    nF2CLIENT   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CLIENT"})
    nF2LOJENT   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_LOJENT"})
    nF2TIPOCLI  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_TIPOCLI"})
    nF2COND     := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_COND"})
    nF2CODA1U   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CODA1U"})
    nF2DTDIGIT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DTDIGIT"})
    nF2EST      := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_EST"})
    nF2UFORIG   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFORIG"})
    nF2UFDEST   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFDEST"})
    nF2VALMERC  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALMERC"})
    nF2VALBRUT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALBRUT"})
    nF2VALFAT   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALFAT"})
    nF2FRETE    := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_FRETE"})
    nF2CHVNFE   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CHVNFE"})
    nF2UFORIG   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFORIG"})
    nF2UFDEST   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_UFDEST"})
    nF2DESCONT  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DESCONT"})
    nF2BASEICM  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_BASEICM"})
    nF2VALICM   := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALICM"})
    nF2BASIMP5  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_BASIMP5"})
    nF2VALIMP5  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALIMP5"})
    nF2BASIMP6  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_BASIMP6"})
    nF2VALIMP6  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_VALIMP6"})
    nF2DESPESA  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_DESPESA"})
    //nF2CHVNFE  := Ascan(aStruSF2,{|x| AllTrim(x[1]) == "F2_CHVNFE"})

    For nX := 1 To Len(aStruSF2)
        If aStruSF2[nX][2] $ "C/M"
            Aadd(aCabs,"")
        ElseIf aStruSF2[nX][2] == "N"
            Aadd(aCabs,0)
        ElseIf aStruSF2[nX][2] == "D"
            Aadd(aCabs,CtoD("  /  /  "))
        ElseIf aStruSF2[nX][2] == "L"
            Aadd(aCabs,.F.)
        EndIf
    Next nX

    dbSelectArea("SC5")
    DbSetOrder(1)
    SC5->( dbSeek(xFilial("SC5")+cPedido) )

    DBSELECTAREA("SA2")
    SA2->(DbSetOrder(1))
    SA2->( DbSeek(xfilial("SA2")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))

    //  aCabs      :=  {}
    // OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE
    cEmissao := STRTRAN(SUBSTR(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,1,10),"-","")
    cHora := SUBSTR(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT,12,5)
    cUFEmit    := OFULLXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_ENDEREMIT:_UF:TEXT
    cUFDest    := OFULLXML:_NFEPROC:_NFE:_INFNFE:_DEST:_ENDERDEST:_UF:TEXT
    dDtDigit := DDATABASE
    DDATABASE := STOD(cEmissao)
    cDoc       := STRZERO(VAL(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_nNF:TEXT),6)
    cSerie     :=  ALLTRIM(OFULLXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT)

    aCabs[nF2FILIAL]    := xFilial("SF2")
    aCabs[nF2TIPO]      :=  "D"
    aCabs[nF2ESPECIE]   := "SPED"
    aCabs[nF2DOC]       := cDoc
    aCabs[nF2SERIE]     := cSerie
    aCabs[nF2EMISSAO]   := STOD(cEmissao)
    aCabs[nF2HORA]      := cHora
    aCabs[nF2CLIENTE]   := SA2->A2_COD
    aCabs[nF2LOJA]      := SA2->A2_LOJA
    aCabs[nF2CLIENT]    := SA2->A2_COD
    aCabs[nF2LOJENT]    := SA2->A2_LOJA
    aCabs[nF2TIPOCLI]   := SA2->A2_TIPO
    aCabs[nF2COND]      := SC5->C5_CONDPAG
    aCabs[nF2CODA1U]    := SC5->C5_CODA1U
    aCabs[nF2DTDIGIT]   := DDATABASE
    aCabs[nF2EST]       := SA2->A2_EST
    aCabs[nF2UFORIG]    := SA2->A2_EST
    aCabs[nF2UFDEST]    := SA2->A2_EST
    aCabs[nF2VALMERC]   := VAL(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vPROD:TEXT)-VAL(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vDESC:TEXT)
    If AttIsMemberOf(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT,"_vDESC")
        aCabs[nF2DESCONT]   := VAL(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vDESC:TEXT)
    EndIf
    If AttIsMemberOf(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT,"_vFRETE")
        aCabs[nF2FRETE]     := VAL(OFULLXML:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_vFRETE:TEXT)
    EndIf
    aCabs[nF2CHVNFE]    := OFULLXML:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
    aCabs[nF2UFORIG]    := cUFEmit
    aCabs[nF2UFDEST]    := cUFDest

    aStruSD2    :=  SD2->(dbStruct())

    //Montagem dos itens do Documento Fiscal
    nD2FILIAL   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_FILIAL"})
    nD2DOC      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DOC"})
    nD2SERIE    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIE"})
    nD2CLIENTE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CLIENTE"})
    nD2LOJA     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOJA"})
    nD2EMISSAO  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_EMISSAO"})
    nD2TIPO     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TIPO"})
    nD2ITEM     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEM"})
    nD2CF       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CF"})
    nD2COD      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_COD"})
    nD2UM       := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_UM"})
    nD2QUANT    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_QUANT"})
    nD2PRCVEN   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRCVEN"})
    nD2PRUNIT   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PRUNIT"})
    nD2TOTAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TOTAL"})
    nD2VALFRE   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALFRE"})
    nD2DESCON   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESCON"})
    nD2LOCAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_LOCAL"})
    nD2TES      := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_TES"})
    nD2PEDIDO   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PEDIDO"})
    nD2ITEMPV   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEMPV"})
    nD2ESTOQUE  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ESTOQUE"})
    nD2DIFAL    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DIFAL"})
    nD2BASEICM  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEICM"})
    nD2PICM     := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_PICM"})
    nD2VALICM   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALICM"})
    nD2BASIMP5  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASIMP5"})
    nD2ALQIMP5  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ALQIMP5"})
    nD2VALIMP5  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALIMP5"})
    nD2ALQCOF   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ALQCOF"})
    nD2BASIMP6  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASIMP6"})
    nD2ALQIMP6  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ALQIMP6"})
    nD2VALIMP6  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALIMP6"})
    nD2ALQPIS   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ALQPIS"})
    nD2CONTA    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_CONTA"})
    nD2DESPESA  := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_DESPESA"})
    nD2BASIPI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_BASEIPI"})
    nD2ALQIPI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_IPI"})
    nD2VALIPI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_VALIPI"})
    nD2NFORI    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_NFORI"})
    nD2SERORI   := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_SERIORI"})
    nD2ITORI    := Ascan(aStruSD2,{|x| AllTrim(x[1]) == "D2_ITEMORI"})

    cNFBudd:="000"+cDoc
    if cEmpAnt == "14"
        cForBudd := "638545"
    elseif  cEmpAnt == "11"
        cForBudd := "035484"
    endif

    If Select('TMPSC6') <> 0
        TMPSC6->(dbCloseArea())
    EndIf

    BeginSql Alias 'TMPSC6'
        SELECT
            R_E_C_N_O_ AS C6_RECNO, *
        FROM
            %Table:SC6% C6 (NOLOCK)
        WHERE
            %NotDel%
            AND C6_FILIAL = %xFilial:SC6%
            AND C6_NUM = %Exp:cPedido%
        ORDER BY
            C6_ITEM
    EndSql

    aItens := {}
    While !TMPSC6->(eof())

        aAdd(aItens, {})
        nPos := Len(aItens)

        For nX := 1 To Len(aStruSD2)
            If  aStruSD2[nX][2]$"C/M"
                aAdd(aItens[nPos],"")
            ElseIf aStruSD2[nX][2]=="D"
                aAdd(aItens[nPos],CToD(""))
            ElseIf aStruSD2[nX][2]=="N"
                aAdd(aItens[nPos],0)
            ElseIf aStruSD2[nX][2]=="L"
                aAdd(aItens[nPos],.T.)
            EndIf
        Next nX

        //Posiciono produto
        cProd := TMPSC6->C6_PRODUTO

        dbSelectArea("SB1")
        dbSetOrder(1)
        dbGoTop()
        If !dbSeek(xFilial("SB1")+cProd)
            FWAlertError("Produto não encontrado", "VF Importador XML")
        EndIf

        //Posiciono o item do pedido de venda
        aSc6 :={}
        AADD( aSC6,  SA2->A2_COD  )// [1] C6_CLI
        AADD( aSC6,  SA2->A2_LOJA  )// [2] C6_LOJA
        AADD( aSC6,  SB1->B1_COD )// [3] C6_PRODUTO
        AADD( aSC6,  TMPSC6->C6_NFORI )// [4] C6_NFORI
        AADD( aSC6,  TMPSC6->C6_SERIORI )// [5] C6_SERIORI
        AADD( aSC6,  TMPSC6->C6_ITEMORI )// [6] C6_ITEMORI
        AADD( aSC6,  cPedido )// [7] C6_NUM
        //nRecSC6 :=   fGetRSC6(aSc6)
        dbSelectArea("SC6")

        SC6->(dbGoTo(TMPSC6->C6_RECNO))
        _cTes := SC6->C6_TES

        AADD(aDocOri, 0)

        //
        aItens[Len(aItens),nD2FILIAL]  := xFilial("SD2")
        aItens[Len(aItens),nD2DOC]     := cDoc
        aItens[Len(aItens),nD2SERIE]   := cSerie
        aItens[Len(aItens),nD2CLIENTE] := SA2->A2_COD
        aItens[Len(aItens),nD2LOJA]    := SA2->A2_LOJA
        aItens[Len(aItens),nD2EMISSAO] := STOD(cEmissao)
        aItens[Len(aItens),nD2TIPO]    := "D"
        aItens[Len(aItens),nD2ITEM]    := SC6->C6_ITEM
        aItens[Len(aItens),nD2CF]      := SC6->C6_CF
        aItens[Len(aItens),nD2COD]     := SB1->B1_COD
        aItens[Len(aItens),nD2UM]      := SB1->B1_UM
        aItens[Len(aItens),nD2CONTA]   := SB1->B1_CONTA

        aItens[Len(aItens),nD2QUANT]   := SC6->C6_QTDVEN
        aItens[Len(aItens),nD2PRCVEN]  := SC6->C6_PRCVEN
        aItens[Len(aItens),nD2TOTAL]   := SC6->C6_VALOR
        aItens[Len(aItens),nD2PRUNIT]   := SC6->C6_PRUNIT
        aItens[Len(aItens),nD2LOCAL]    := '10'
        aItens[Len(aItens),nD2TES]      :=  _cTes
        aItens[Len(aItens),nD2PEDIDO]   := SC5->C5_NUM
        aItens[Len(aItens),nD2ITEMPV]   := SC6->C6_ITEM
        aItens[Len(aItens),nD2NFORI]    := SC6->C6_NFORI
        aItens[Len(aItens),nD2SERORI]   := SC6->C6_SERIORI
        aItens[Len(aItens),nD2ITORI]    := SC6->C6_ITEMORI
        aItens[Len(aItens),nD2ESTOQUE]  := "S"

        /*aItens[Len(aItens),nD2BASEICM]  := TMPSD1->D1_BASEICM
        aItens[Len(aItens),nD2PICM]     := TMPSD1->D1_PICM
        aItens[Len(aItens),nD2VALICM]   := TMPSD1->D1_VALICM
        aItens[Len(aItens), nD2BASIPI]  := TMPSD1->D1_BASEIPI
        aItens[Len(aItens), nD2ALQIPI]  := TMPSD1->D1_IPI
        aItens[Len(aItens), nD2VALIPI]  := TMPSD1->D1_VALIPI

        aItens[Len(aItens), nD2BASIMP5] := TMPSD1->D1_VALIPI+ TMPSD1->D1_TOTAL
        aItens[Len(aItens), nD2ALQIMP5] := TMPSD1->D1_ALQIMP5
        aItens[Len(aItens), nD2VALIMP5] := (TMPSD1->D1_VALIPI+ TMPSD1->D1_TOTAL)*(TMPSD1->D1_ALQIMP5/100)

        aItens[Len(aItens), nD2BASIMP6] := TMPSD1->D1_VALIPI+ TMPSD1->D1_TOTAL
        aItens[Len(aItens), nD2ALQIMP6] := TMPSD1->D1_ALQIMP6
        aItens[Len(aItens), nD2VALIMP6] := (TMPSD1->D1_VALIPI+ TMPSD1->D1_TOTAL)*(TMPSD1->D1_ALQIMP6/100)
        */

        // aItens[Len(aItens), nD2BASIMP5] :=   TMPSD1->D1_BASIMP5
        // aItens[Len(aItens), nD2ALQIMP5] :=   TMPSD1->D1_ALQIMP5
        // aItens[Len(aItens), nD2VALIMP5] :=   TMPSD1->D1_VALIMP5
        // aItens[Len(aItens), nD2BASIMP6] :=   TMPSD1->D1_BASIMP6
        // aItens[Len(aItens), nD2ALQIMP6] :=   TMPSD1->D1_ALQIMP6
        // aItens[Len(aItens), nD2VALIMP6] :=   TMPSD1->D1_VALIMP6

        TMPSC6->(dbskip())
    Enddo

    lMsErroAuto     := .F.
    lAutoErrNoFile  := .T.
    //aDocOri :={}
    cNF := MaNfs2Nfs(/*cSerOri*/        "",;        //Serie do Documento de Origem
        /*cNumORI*/         "",;        //Numero do Documento de Origem
        /*cClieFor*/       SA2->A2_COD,;        //Cliente/Fornecedor do documento do origem
        /*cLoja*/           SA2->A2_LOJA,;        //Loja do Documento de origem
        /*cSerieNFS*/       cSerie,;    //Serie do Documento a ser gerado
        /*lMostraCtb*/      NIL,;       //Mostra Lct.Contabil (OPC)
        /*lAglutCtb*/       NIL,;       //Aglutina Lct.Contabil (OPC)
        /*lCtbOnLine*/      NIL,;       //Contabiliza On-Line (OPC)
        /*lCtbCusto*/       NIL,;       //Contabiliza Custo On-Line (OPC)
        /*lReajusta*/       NIL,;       //Reajuste de preco na nota fiscal (OPC)
        /*nCalAcrs*/        NIL,;       //Tipo de Acrescimo Financeiro (OPC)
        /*nArredPrcLis*/    NIL,;       //Tipo de Arredondamento (OPC)
        /*lAtuSA7*/         NIL,;       //Atualiza Amarracao Cliente x Produto (OPC)
        /*lECF*/            NIL,;       //Cupom Fiscal (OPC)
        /*bFilSD2*/         NIL,;       //CodeBlock de Selecao do SD2 (OPC)
        /*bSD2*/            NIL,;       //CodeBlock a ser executado para o SD2 (OPC)
        /*bSF2*/            NIL,;       //CodeBlock a ser executadSIGAMDIo para o SF2 (OPC)
        /*bTTS*/            NIL,;       //CodeBlock a ser executado no final da transacao (OPC)
        /*aDocOri*/         aDocOri,;   //Array com os Recnos do SF2 (OPC)
        /*aItemOri*/        aItens,;    //Array com os itens do SD2 (OPC)
        /*aSF2*/            aCabs,;     //Array com os dados do SF2 (OPC)
        /*lNoFiscal*/       .F.,;       //Calculo Fiscal - Desabilita o calculo fiscal pois as informacoes ja foram passadas nos campos do SD2 e SF2 (OPC)
        /*bFiscalSF2*/      bFiscalSF2,;//CodeBlock para tratamento do fiscal - SF2 (OPC)
        /*bFiscalSD2*/      bFiscalSD2,;//CodeBlock para tratamento do fiscal - SD2 (OPC)
        /*bFatSE1*/         {|| .T.},;       //CodeBlock para tratamento do fiscal - SE1 (OPC)
        /*cNumNFS*/         cDoc)       //Numero do documento fiscal (OPC)
    conout("stop")
    if !empty(cNF)
        SC5->( dbSeek(xFilial("SC5")+cPedido) )
        //  cUpd := "UPDATE "+ RetSQLName("SC9")+"  SET  " +cEol
        //  cUpd += " C9_BLCRED = ' ' " +cEol
        //  cUpd += ", C9_BLEST = ' ' " +cEol
        //  cUpd += "WHERE C9_FILIAL = " + VALTOSQL(xFilial("SC9"))+cEol
        //  cUpd += "AND C9_NFISCAL  = ''"+cEol
        //  cUpd += "AND C9_PEDIDO  = " + VALTOSQL(SC5->C5_NUM)+cEol
        //  cUpd += "AND C9_CLIENTE  = " + VALTOSQL(SC5->C5_CLIENTE)+cEol
        //  cUpd += "AND C9_LOJA  = " + VALTOSQL(SC5->C5_LOJACLI)+cEol
        //  cUpd += "AND D_E_L_E_T_  = '' "

        //  TCSQLEXEC(cUpd)

        // Seto também na SF3
        cUpd := "UPDATE "+ RetSQLName("SF3")+"  SET  " +cEol
        cUpd += " F3_CODRET = 'M' " +cEol
        // cUpd += ",F3_OBSERV   = ''		"  +cEol // NF CANCELADA ou  NF INUTILIZADA;
        cUpd += ",F3_DTCANC  = ''"  +cEol
        cUpd += ",F3_CODRSEF = "  + VALTOSQL("100")+cEol  //102 (102 = Inutilização de NF-e);
        cUpd += ",F3_DESCRET = "  + VALTOSQL('Autorizado o uso da NF-e')+cEol

        cUpd += "WHERE F3_FILIAL = " + VALTOSQL(xFilial("SF3"))+cEol
        cUpd += "AND F3_NFISCAL  = " + VALTOSQL(cNF)+cEol
        cUpd += "AND F3_SERIE    = " + VALTOSQL("2")+cEol
        cUpd += "AND F3_EMISSAO  = " + VALTOSQL(DDATABASE)+cEol
        cUpd += "AND D_E_L_E_T_  = '' "
        TCSQLEXEC(cUpd)
        //   A410BxGc(SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_NUM,cNF,cSerie)

        //AJUSTE DE IMPOSTO SD2, SF2, SF3, SFT, CD2
        U_VRN0179(oFullXML, cPedido, AvKey(cNF, "FT_NFISCAL"), AvKey(cSerie, "FT_SERIE") ,SA2->A2_COD,SA2->A2_LOJA,xFilial("SC5"))

    endif

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
    // ENDIF
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

//10/06/2025
//DANIEL VICTOR DA ROSA - PERSONALITEC
//Função para percorrer diretórios e subdiretórios, buscando arquivos XML E VALIDAR A CHAVE
//zRecurDir
Static Function zRecurDir(cPasta, cMascara, dAPartir,cChavXML2)
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




