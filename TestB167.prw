#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FILEIO.CH"


//--------------------------------------------------------------
/*/{Protheus.doc} TestB167
Description
FONTE PARA CONSEGUIR CORRIGIR OS IMPOSTO DOS XML´S QUE
TEM MAIS LINHAS NO PROTHEUS DO QUE NO XML.
DANIEL VICTOR DA ROSA - PERSONALITEC
@since 10/06/2025
/*/
//--------------------------------------------------------------
User Function TestB167()

    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := SPACE(44)
    Local oSay1
    Local oSay3
    Static oDlg

    DEFINE MSDIALOG oDlg TITLE "IMPORTAR XML" FROM 000, 000  TO 250, 500 COLORS 0, 16777215 PIXEL

    @ 010, 061 SAY oSay1 PROMPT "Atenção: Salvar aquivo em uma pasta no C:\XML" SIZE 123, 014 OF oDlg COLORS 0, 16777215 PIXEL
    @ 058, 041 MSGET oGet1 VAR cGet1 SIZE 167, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 076, 170 BUTTON oButton1 PROMPT "IMPORTAR" SIZE 037, 009 OF oDlg ACTION ProcX489(cGet1) PIXEL
    @ 045, 041 SAY oSay3 PROMPT "Chave do XML" SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 108, 206 BUTTON oButton2 PROMPT "SAIR" SIZE 037, 009 OF oDlg ACTION oDlg:end() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcX489
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
Static Function ProcX489(cChaveXML)

    Local cWarning      := ""
    Local cError        := ""

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
        FWMsgRun(, {||   cXMLFile := zRecurA9("C:\XML\",,,cChavXML2) }, "VAREJO FACIL","Aguarde Processando xml" )

        IF !Empty(cXMLFile)
            cXML :=  getXML(cXMLFile)
            cXML := StrTran( cXML, "ns2:", "" )
            oFullXML := XmlParser(cXML,"_",@cError,@cWarning)
            cChave   :=  Right(AllTrim(oFullXML:_nfeProc:_NFe:_InfNfe:_Id:Text),44)
            cNumNF   := padl(alltrim(oFullXML:_nfeProc:_NFe:_infNFe:_ide:_nNF:TEXT),6,'0')
            cSerie   := ALLTRIM(oFullXML:_nfeProc:_NFe:_infNFe:_ide:_serie:TEXT)
            xNome    := oFullXML:_nfeProc:_NFe:_infNFe:_emit:_xNome:TEXT
            cNFBudd   := cNumNF
            cSNFBudd  := cSerie
            If (XmlChildEx ( oFullXML:_nfeProc:_NFe:_infNFe:_emit ,"_CNPJ")<>Nil)
                cCNPJ	:=  oFullXML:_nfeProc:_NFe:_infNFe:_emit:_CNPJ:TEXT
            EndIf

            cCNPJCli	:=  oFullXML:_nfeProc:_NFe:_infNFe:_dest:_CNPJ:TEXT

            DBSELECTAREA("SA2")
            SA2->(DbSetOrder(3))
            If !SA2->( DbSeek(xfilial("SA2")+cCNPJCli))
                FWAlertError("Fornecedor não encontrado", "VA Importador XML")
            Endif

            U_VRN0179(oFullXML, cPedido, AvKey(cNFBudd, "FT_NFISCAL"), AvKey(cSNFBudd, "FT_SERIE") ,SA2->A2_COD,SA2->A2_LOJA,xFilial("SC5"))
        ENDIF
    ENDIF

Return



//10/06/2025
//DANIEL VICTOR DA ROSA - PERSONALITEC
//Função para percorrer diretórios e subdiretórios, buscando arquivos XML E VALIDAR A CHAVE
//zRecurDir
Static Function zRecurA9(cPasta, cMascara, dAPartir,cChavXML2)
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

Return cRetXML

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
