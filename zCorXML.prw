#include 'protheus.ch'
#include 'parmtype.ch'
#Include "TOTVS.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "RwMake.ch"
#include "fileio.ch"

//--------------------------------------------------------------
/*/{Protheus.doc} zCorXML
Description
 Tela da Função para corrigir XMLS que foram gerados com o cProd errado.
DANIEL VICTOR DA ROSA - PERSONALITEC
@since 02/12/2025
/*/
//--------------------------------------------------------------
User Function zCorXML()

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
    @ 076, 170 BUTTON oButton1 PROMPT "IMPORTAR" SIZE 037, 009 OF oDlg ACTION ProcXZY(cGet1) PIXEL
    @ 045, 041 SAY oSay3 PROMPT "Chave do XML" SIZE 036, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 108, 206 BUTTON oButton2 PROMPT "SAIR" SIZE 037, 009 OF oDlg ACTION oDlg:end() PIXEL

    ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} ProcXZY
    Função para corrigir XMLS que foram gerados com o cProd errado.
    @Author DANIEL VICTOR DA ROSA - PERSONALITEC
   @since 02/12/2025
/*/
Static Function ProcXZY(cChaveXML)

    Local cWarning      := ""
    Local nY52          := 0
    Local nY523         := 0
    Local cError        := ""
    Local cXml         := ""
    Local cXMLNew      := ""
    Local cXMLCon      := ""
    Local nPos1    := 0
    Local cStrSeek := "<cProd>"
    Local cStrSeek2 := "</cProd>"
    Local nLen1 := len(cStrSeek)
    Local nLen2 := len(cStrSeek2)
    Local nItem := 0
    Local i := 0
    Local cStrNew1 := ""
    Local nControl := 0

    Private aXmls  := {} // guarda o caminho absoluto do xml, setar na mao quando o pedido ja estiver gerado
    Private cPedVend := "" // Numero do pedido de Venda que foi gravado, caso ja tenha sido gerado setar na mao
    Private cNFBudd  := ""
    Private cSNFBudd := ""
    Private oFullXML := Nil
    Private cChavXML2 := cChaveXML
    Private cPedido  := ""
    Private aDocOriSC6 := {}

    //FUNÇÃO RESPONSÁVEL POR PERCORRER TODOS OS XML DA PASTA E PEGAR O ARQUIVO XML COM BASE NA CHAVE DIGITADA
    FWMsgRun(, {||   aXmls := zRecuA10("C:\XML\",,,cChavXML2) }, "VAREJO FACIL","Aguarde Processando xml" )

    FOR nY523 := 1 TO LEN(aXmls)

        cXML :=  GetXmlZ2(aXmls[nY523][1])
        cXML := StrTran( cXML, "ns2:", "" )

        nItem := u_zExe096(cXml, "nItem")

        nPos1 := AT(cStrSeek,cXml)+nLen1-1
        nPos2 := AT(cStrSeek2,cXml)

        cXMLCon := cXml
        cXMLNew := ""
        for i := 1 to nItem

            nPos3 := AT('nItem="' + cvaltochar(i),cXml)

            nLenXml :=len(cXml)

            cEanRet := SUBSTR(cXMLCon, 1,nPos3+22) //vc pega o xml ate a posição
            cXMLNew += SUBSTR(cXMLCon, 1,nPos1)

            cStrNew1 := cvaltochar(i)
            cXMLNew += cStrNew1 // Adiciona o conteudo novo

            cXMLNew += SUBSTR(cXMLCon, nPos2,nLenXml) //adiciona o conteudo original a partir daa ultima posição

            cXMLCon := cXMLNew

            nPos3 := AT('nItem="' + cvaltochar(i+1),cXml)

            nPos1 := AT(cStrSeek,  SUBSTR(cXml, nPos3,nLenXml)) + nPos3
            nPos2 := AT(cStrSeek2, SUBSTR(cXml, nPos3,nLenXml)) + nPos3

        next i

    Next nY523


Return


//10/06/2025
//DANIEL VICTOR DA ROSA - PERSONALITEC
//Função para percorrer diretórios e subdiretórios, buscando arquivos XML E VALIDAR A CHAVE
//zRecurDir
Static Function zRecuA10(cPasta, cMascara, dAPartir,cChavXML2)
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

    RestArea(aArea)

Return aArquivos

/*/{Protheus.doc} GetXmlZ2
	(long_description)
	@type  Static Function
	@aDaniel Victor da Rosa - PERSONALITEC
    @since 02/12/2025
/*/
Static Function GetXmlZ2(cArquivo)

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


User Function zExe096(cFrase, cBusca)
    Local aArea     := FWGetArea()
    Local nTotal    := 0

    Default cFrase    := ""
    Default cBusca    := ""
    //Conta quantas repetições teve
    nTotal := CountStr(cBusca, cFrase)
    //WAlertInfo("Número de vezes que a busca se repete: " + cValToChar(nTotal), "Teste CountStr")

    FWRestArea(aArea)
Return nTotal
