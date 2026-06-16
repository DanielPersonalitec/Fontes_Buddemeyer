#Include "Totvs.ch"
#Include "FWMVCDef.ch"

//--------------------------------------------------------------
/*/{Protheus.doc} BUD1469
    @Tela dos ajustes em lote.
    @Daniel Victor da Rosa - Personalitec
    @since 26/08/2025
/*/
//--------------------------------------------------------------

User Function BUD1469()

    Local oButton1
    Local oButton2
    Local oGet1
    Local cGet1 := Space(30)
    Local oGet2
    Local cGet2 := Space(3)
    Local oGroup1
    Local oGroup2
    Local oSay1
    Local oSay2
    Local oSay3
    Private  nReguaZ := 0
    Static oDlg36

    DEFINE MSDIALOG oDlg36 TITLE "" FROM 000, 000  TO 180, 400 COLORS 0, 16777215 PIXEL

    @ 005, 005 GROUP oGroup1 TO 085, 192 OF oDlg36 COLOR 0, 16777215 PIXEL
    @ 027, 008 GROUP oGroup2 TO 080, 188 OF oDlg36 COLOR 0, 16777215 PIXEL
    @ 015, 067 SAY oSay1 PROMPT "AJUSTE FIO EM LOTE" SIZE 057, 009 OF oDlg36 COLORS 0, 16777215 PIXEL
    @ 041, 010 SAY oSay2 PROMPT "REFERENCIA:" SIZE 040, 007 OF oDlg36 COLORS 0, 16777215 PIXEL
    @ 041, 134 SAY oSay3 PROMPT "FIO:" SIZE 017, 009 OF oDlg36 COLORS 0, 16777215 PIXEL
    @ 041, 051 MSGET oGet1 VAR cGet1 Picture GetSx3Cache("ZZA_REF","X3_PICTURE")  SIZE 080, 010 OF oDlg36 COLORS 0, 16777215 PIXEL
    @ 041, 148 MSGET oGet2 VAR cGet2 Picture GetSx3Cache("ZZA_TFIOC","X3_PICTURE") F3 "MZ2" SIZE 032, 010 OF oDlg36 COLORS 0, 16777215 PIXEL
    @ 065, 144 BUTTON oButton1 PROMPT "CONFIRMAR" SIZE 037, 011 OF oDlg36 ACTION ConfirZZA(cGet1,cGet2) PIXEL
    @ 065, 102 BUTTON oButton2 PROMPT "CANCELAR" SIZE 037, 011 OF oDlg36 ACTION oDlg36:End() PIXEL

    ACTIVATE MSDIALOG oDlg36 CENTERED

Return

/*/{Protheus.doc} ConfirZZA
    (long_description)
    @Função Responsável por executar os ajustes.
    @Daniel Victor da Rosa - Personalitec
    @since 26/08/2025
/*/
Static Function ConfirZZA(cGet1,cGet2)
    IF !Empty(alltrim(cGet1)) .AND. !Empty(alltrim(cGet2))
        ZA2->(DBSetOrder(1))
        IF !ZA2->(DbSeek(xFilial('ZA2')+cGet2))
            Help(,, "HELP",, "Fio nao cadastrado!", 1, 0)
            Return
        ELSE
            MoniZZA9(cGet1,cGet2)
        ENDIF
    ELSE
        MsgInfo("Referencia ou Fio em branco!")
    Endif
Return

//--------------------------------------------------------------
/*/{Protheus.doc} MoniZZA9
@TELA DE CONFIRMAÇÃO DOS DADOS A ALTERAR.
@author  - DANIEL VICTOR DA ROSA - PERSONALITEC
@since 28/08/2025
/*/
//--------------------------------------------------------------
Static Function MoniZZA9(cGet1,cGet2)

    Local aArea         := GetArea()
    Local aCampos := {}
    Local oSay1
    Local oTempTable := Nil
    Local aColunas := {}
    Local cFontPad    := 'Tahoma'
    Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
    //Barra de Botões

    Local aButtons    := {}
    Private lOk        := .F.
    //Janela e componentes
    Private oDlgBrow
    Private oPanGrid
    Private oFWBrowse
    Private cAliasTmp := GetNextAlias()
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg :=  1200
    Private nJanAltu :=  600
    Private cQtdite :=  0

    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'FLAG_OK'     , 'L', 1                       , 0}) //Flag para marcação
    aAdd(aCampos, { 'ZZA_REF'     , 'C', TamSX3('ZZA_REF')[1]    , 0}) //Produto
    aAdd(aCampos, { 'ZZA_TIPOMA'  , 'C', TamSX3('ZZA_TIPOMA')[1] , 0}) //Tipo
    aAdd(aCampos, { 'ZZA_ARTIGO'  , 'C', TamSX3('ZZA_ARTIGO')[1] , 0}) //Unid. Med.
    aAdd(aCampos, { 'ZZA_ESPECI'  , 'C', TamSX3('ZZA_ESPECI')[1] , 0}) //Descrição
    aAdd(aCampos, { 'RECNUM'      , 'N', 16                      , 0}) //RecNo da SB1

    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:Create()

    //Popula a tabela temporária
    Processa({|| xQueryZ(cGet1,cGet2)}, 'Processando...')

    //Adiciona as colunas que serão exibidas no browse
    aColunas := fCriaCols()

    //Criando a janela
    oDlgBrow := TDialog():New(0, 0, nJanAltu, nJanLarg, 'Monitor de Confirmacao', , , , , , /*nCorFundo*/, , , .T.)
    EnchoiceBar(oDlgBrow, {|| ProcZZA(cGet1, cGet2), oDlgBrow:end()   }, {|| lRet := .F., oDlgBrow:end()},,aButtons)
    @ 015, 005 BUTTON oButton1 PROMPT "MARCAR TODOS" SIZE 050, 011 OF oDlgBrow ACTION fMarkTod() PIXEL
    @ 017, 065 SAY oSay1 PROMPT "QTD ITENS:" SIZE 040, 011 OF oDlgBrow COLORS 0, 16777215 PIXEL
    @ 017, 085 SAY oSay1 PROMPT cQtdite SIZE 040, 011 OF oDlgBrow COLORS 0, 16777215 PIXEL

    //Dados
    oPanGrid := tPanel():New(035, 001, '', oDlgBrow, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), 595 , (480/2) - 1)
    oFWBrowse := FWBrowse():New()
    oFWBrowse:DisableFilter()
    oFWBrowse:DisableConfig()
    oFWBrowse:DisableReport()
    oFWBrowse:DisableSeek()
    oFWBrowse:DisableSaveConfig()
    oFWBrowse:SetFontBrowse(oFontGrid)
    oFWBrowse:SetAlias(cAliasTmp)
    oFWBrowse:SetDataTable()
    oFWBrowse:SetEditCell(.T., {|| .T.})
    oFWBrowse:lHeaderClick := .F.
    oFWBrowse:AddMarkColumns(;
        {|| Iif((cAliasTmp)->FLAG_OK, 'LBOK', 'LBNO') },;      //ícones
        {|| (cAliasTmp)->FLAG_OK := ! (cAliasTmp)->FLAG_OK};   //ao dar duplo clique
        )

    //Define as colunas, vincula ao painel e exibe
    oFWBrowse:SetColumns(aColunas)
    oFWBrowse:SetOwner(oPanGrid)
    oFWBrowse:Activate()

    oDlgBrow:Activate(, , , .T., , , )

    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oFWBrowse:DeActivate()

    RestArea(aArea)
Return

/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author  - DANIEL VICTOR DA ROSA - PERSONALITEC
@since 28/08/2025
/*/
Static Function fCriaCols()
    Local nAtual       := 0
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn

    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    //[7] - Editável? .T. = sim, .F. = não

    aAdd(aEstrut, { 'ZZA_REF'   , 'Referencia' , 'C', TamSX3('ZZA_REF')[1]   , 0, '',     .F.})
    aAdd(aEstrut, { 'ZZA_TIPOMA', 'Tipo Maq.'  , 'C', TamSX3('ZZA_TIPOMA')[1], 0, '',     .F.})
    aAdd(aEstrut, { 'ZZA_ARTIGO', 'Artigo'     , 'C', TamSX3('ZZA_ARTIGO')[1], 0, '',     .F.})
    aAdd(aEstrut, { 'ZZA_ESPECI', 'Descrição'  , 'C', TamSX3('ZZA_ESPECI')[1], 0, '',     .F.})

    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])

        //Se for ser possível ter o duplo clique
        If aEstrut[nAtual][7]
            oColumn:SetEdit(.T.)
            oColumn:SetReadVar(aEstrut[nAtual][1])
            //oColumn:SetValid({|| fSuaValid()})
        EndIf

        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas

/*/{Protheus.doc} fMarkTod
Marca todos os registros e desmarca também.
@author  - DANIEL VICTOR DA ROSA - PERSONALITEC
@since 28/08/2025
/*/
Static Function fMarkTod()
    Local nAtuz := 0
    //Percorre todos os registros
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    ProcRegua(nReguaZ)
    While ! (cAliasTmp)->(EoF())
        nAtuz++
        IncProc('Marcando registro ' + cValToChar(nAtuz) + ' de ' + cValToChar(nReguaZ) + '...')
        //Atualiza o registro atual
        RecLock(cAliasTmp, .F.)
        (cAliasTmp)->FLAG_OK := !(cAliasTmp)->FLAG_OK
        (cAliasTmp)->(MsUnlock())
        (cAliasTmp)->(DbSkip())
    EndDo
    //Volta pro topo, e atualiza a tela
    (cAliasTmp)->(DbGoTop())
    oFWBrowse:Refresh()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Query dos dados
    Popula os dados.
	@Daniel Victor da Rosa - Personalitec
	@since 28/08/2025
/*/
//-------------------------------------------------------------------
static function xQueryZ(cGet1,cGet2)

    Local cQuery1 := ""
    Local adados  := {}

    cQuery1 := " SELECT ZZA_REF, ZZA_TIPOMA, ZZA_ARTIGO, ZZA_ESPECI, R_E_C_N_O_ AS RECZ FROM "+RetSqlName('ZZA') + " (NOLOCK) Z "
    cQuery1 += " WHERE D_E_L_E_T_ = ' ' "
    cQuery1 += " AND Z.ZZA_REF LIKE "+"'"+AllTrim(cGet1)+"%' "
    //adicionar mais campos quando ter.

    If Select("cAliasZZA") > 0
        cAliasZZA->(DbCloseArea())
    EndIf

    cAliasZZA := GetNextAlias()
    DbUseArea(.T., "TOPCONN", TCGenQry( , , cQuery1), "cAliasZZA", .F., .T.)

    Count to nTotal
    cQtdite := STR(nTotal)
    ProcRegua(nTotal)
    nReguaZ := nTotal
    cAliasZZA->(DbGoTop())
    nAtual := 0

    //Enquanto houver registros, adiciona na temporária
    While !cAliasZZA->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
        RecLock(cAliasTmp, .T.)
        (cAliasTmp)->FLAG_OK    := .T.
        (cAliasTmp)->ZZA_REF    := cAliasZZA->ZZA_REF
        (cAliasTmp)->ZZA_TIPOMA := cAliasZZA->ZZA_TIPOMA
        (cAliasTmp)->ZZA_ARTIGO := cAliasZZA->ZZA_ARTIGO
        (cAliasTmp)->ZZA_ESPECI := cAliasZZA->ZZA_ESPECI
        (cAliasTmp)->RECNUM     := cAliasZZA->RECZ
        (cAliasTmp)->(MsUnlock())
        cAliasZZA->(DbSkip())
    EndDo
    cAliasZZA->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())

Return aDados

/*/{Protheus.doc} ProcZZA
	(long_description)
	@type  Static Function
	@Daniel Victor da Rosa - Personalitec
	@since 28/08/2025
/*/
Static Function ProcZZA(cGet1, cGet2)

    Local nLinha := oFWBrowse:nLen
    Local nNumLin as numeric
    Local Nzat   := 0
    Local lCert  := .F.
    Local nQatAj := 0
    Local aDados := {}

    (cAliasTmp)->(DbGoTop())
    ProcRegua(nReguaZ)
    FOR nNumLin := 1 to nLinha
        IF (cAliasTmp)->FLAG_OK
            Nzat ++
            IncProc('Processando.... ' + cValToChar(Nzat) + ' do total de ' + cValToChar(nReguaZ) + '...')
            ZZA->(DBSetOrder(1))
            ZZA->(DBGoTo((cAliasTmp)->RECNUM))
            IF Alltrim(cGet1) $ ZZA->ZZA_REF
                If  ZZA->ZZA_TFIOC <>  alltrim(cGet2)
                    aAdd(aDados, {ZZA->ZZA_REF, ZZA->ZZA_TFIOC, alltrim(cGet2)})
                    RecLock('ZZA', .F.)
                    ZZA->ZZA_TFIOC := alltrim(cGet2)
                    ZZA->(MsUnLock())
                    lCert := .T.
                    nQatAj ++
                Endif
            Endif
        ENDIF
        (cAliasTmp)->(DbSkip())
    NEXT nNumLin
    (cAliasTmp)->(DbGoTop())
    IF lCert
        MsgInfo("Ajuste realizado com sucesso! Registros ajustados: " + cValToChar(nQatAj))
        EnvEmail(aDados)
    ELSE
        MsgInfo("Nenhum registro foi ajustado. Verifique se os itens já estão configurados com o fio desejado.")
    ENDIF
Return

// Alterada função para envio de e-mail e destinatários por parâmetro. Karina.N 23/07/2021
// Envio e-mail:
Static Function EnvEmail(aDados)

    Local cMensagem   := ""
    Local nSendPort   := 0
    Local nSendSec    := 0
    Local nTimeout    := 60
    Local xRet
    Local nXYT        := 0
    Local oServer
    Local oMessage
    Local cSendSrv    := GETMV("MV_SERCONE") // servidor de envio
    Local cUser       := GetMV("MV_RELACNT") // usuário da conta de e-mail
    Local cPass	  	  := GetMV("MV_RELPSW")  // senha da conta de e-mail
    Local cAssunto    := "Alteração de ficha tecnica - FIOS."
    Local cMailFrom	  := "no-reply@buddemeyer.com.br"
    Local cMailTo	  := SUPERGETMV("BD_ALTFIOZ", .F. , "jonas@buddemeyer.com.br;janice@buddemeyer.com.br")

    Local cCodUsr     := RetCodUsr()
    Local cUserName   := Alltrim( UsrFullName(cCodUsr) )

    cMensagem += "<table border='1' cellspacing='0' cellpadding='4' style='font-size: 8pt; border-color:#E9E9E9;'>"
    cMensagem += "<tr bgcolor='#F2F2F2'>"
    cMensagem += "<td><b>Referência</b></td>"
    cMensagem += "<td><b>Fio Anterior</b></td>"
    cMensagem += "<td><b>Fio Novo</b></td>"
    cMensagem += "</tr>"

    // Loop no array
    For nXYT := 1 To Len(aDados)
        cMensagem += "<tr>"
        cMensagem += "<td>"+AllTrim(aDados[nXYT,1])+"</td>" // Referência
        cMensagem += "<td>"+AllTrim(aDados[nXYT,2])+"</td>" // Fio Anterior
        cMensagem += "<td>"+AllTrim(aDados[nXYT,3])+"</td>" // Novo Fio
        cMensagem += "</tr>"
    Next

    cMensagem += "</table>"
    cMensagem += "<br><hr noshade color='E9E9E9' size='1'>"
    cMensagem += "Data: "+Dtoc(MsDate())+". Hora: "+Substr(Time(),1,5)+". Usuário: "+AllTrim(Upper(cUserName))+"<br>"
    cMensagem += "</font>"

    oServer := TMailManager():New()
    oServer:SetUseSSL( .F. )
    oServer:SetUseTLS( .F. )

    if nSendSec == 0
        nSendPort := 25 // porta padrão para protocolo SMTP
    elseif nSendSec == 1
        nSendPort := 465 // porta padrão para protocolo SMTP com SSL
        oServer:SetUseSSL( .T. )
    else
        nSendPort := 587 // porta padrão para protocolo SMTP com TLS
        oServer:SetUseTLS( .T. )
    endif

    // uma vez que apenas enviará e-mails o recebedor será passado como ""
    // e a porta não será passada como parâmetro pois é opcional
    xRet := oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )
    if xRet != 0
        cErrorMsg := "Não foi possível iniciar servidor SMTP: " + oServer:GetErrorString( xRet ) + ' (BUD1469).'
        U_BUD1427( cErrorMsg )
    endif

    // esse método sera o timout para o servidor SMTP
    xRet := oServer:SetSMTPTimeout( nTimeout )
    if xRet != 0
        cErrorMsg := "Não foi possível setar o timeout do protocolo " + cProtocol + " de " + cValToChar( nTimeout ) + ' (BUD1469).'
        U_BUD1427( cErrorMsg )
    endif

    // estabelece a conexão com o servidor SMTP
    xRet := oServer:SMTPConnect()
    if xRet <> 0
        cErrorMsg := "Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ) + ' (BUD1469).'
        U_BUD1427( cErrorMsg )
    endif

    oMessage := TMailMessage():New()
    oMessage:Clear()

    //oMessage:cDate := cValToChar( Date() )
    oMessage:cFrom := cMailFrom
    oMessage:cTo   := cMailTo
    oMessage:cSubject := cAssunto
    oMessage:cBody := cMensagem

    xRet := oMessage:Send( oServer )
    if xRet <> 0
        cErrorMsg := "Não foi possível enviar a mensagem: " + oServer:GetErrorString( xRet ) + ' (BUD1469).'
        U_BUD1427( cErrorMsg )
    endif

    xRet := oServer:SMTPDisconnect()
    if xRet <> 0
        cMsg := "Não foi possível desconetar do servidor SMTP: " + oServer:GetErrorString( xRet ) + ' (BUD1469).'
        U_BUD1427( cErrorMsg )
    endif

Return
