#Include "TOTVS.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "tbiconn.ch"
/*
Painel Faturamento
PERSONALITEC - ROBERTO
*/
User Function BUD1462()

	Local aArea := FWGetArea()
	Local aPergs   := {}
	Local xPar0 := sToD("")
	Local xPar1 := sToD("")
	Private xPar2 := "N"
	Private xPar3 := "T"
	//Private lRotUso := GETMV("BD_BUD1462")

	If cEmpAnt <> "01" .and. cFilAnt <> "10"
		MsgStop("Autorizado o uso somente para a Filial 10!")
		Return
	EndIf
	//Verifico se a rotina esta em uso
	/*If lRotUso
		MsgStop("Rotina Painel de Faturamento já esta em uso!!!")
		Return()
	Else
		//Marco a rotina em uso
		PutMV("BD_BUD1462", .T.)
	EndIf*/
	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Data de", xPar0,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Ate", xPar1,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {2, "Mercado", xPar2, {"N=BIANCHERIA"}, 090, ".T.", .T.})
	aAdd(aPergs, {2, "Status", xPar3, {"T=Todos os Pedidos","F=Finalizado", "E=Em Espera", "P=Em Processo", "R=Rejeitado", "C=Cancelado", "G=Gerado Nota"}, 090, ".T.", .T.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| B1462() },OemToAnsi("Aguarde... Selecionando os pedidos conforme filtro informado!"))
	EndIf

	//Limpo a rotina para poder ser usada novamente.
	//PutMV("BD_BUD1462", .F.)

	FWRestArea(aArea)
Return

Static Function B1462()

	Local aCampos:={}
	Local aSize           := {}
	LocaL aInfo           := {}
	Local _cLegSt := ""
	Local oRadioGrp1
	Local oGroup1
	Local oGroup2
	Local oGroup2

	Local oButton1
	Local oButton2
	Local oButton3
	Local oButton4
	Local oButton5
	Local oButton6
	Local oBitmap1

	Local aCdCores  := {}
	Local aCores  := {}

	Private cQry := ""

	Private cEdit1	 := Space(25)
	Private cEdit2	 := Space(60)

	Private nRadioGrp1	 := 0
	Private oEdit1
	Private _oDlg
	Private aCpoBro := {}
	Private lInverte := .F.
	Private cMarca  := GetMark()
	Private oMark
	Private nVlrAtr:= 0
	Private cParceir:=""
	Private nTotGeral:=0
	Private aVetor := {}

	Private oRadMenu1
	Private nRadMenu1 := 1
	Private oGet1
	Private cGet1 := Space(06)

	//Parametro para controle de local do mercado nacional
	Private _LocalN := AllTrim(GetNewPar("BD_B1462AL","")) // NOT IN ('06','13','18')

	//Certifico o parametro para não aparecer a tela da GNRE
	//PUTMV("MV_GNRENF", .T.)

	If Select("TTRB") > 0
		TTRB->(dbCloseArea())
	EndIf

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'STATUS', 'C', 30, 0}) //Status do Pedido
	aAdd(aCampos, { 'CONDPAG', 'C', 3, 0}) //Condição de Pagamento
	aAdd(aCampos, { 'CDPDESC', 'C', 15, 0}) //Descrição de Pagamento
	aAdd(aCampos, { 'PEDIDO', 'C', 6, 0}) //Pedido
	aAdd(aCampos, { 'CLIENTE', 'C', 6, 0}) //Cliente
	aAdd(aCampos, { 'LOJACLI', 'C', 2, 0}) //Loja
	aAdd(aCampos, { 'NOME', 'C', 50, 0}) //Nome
	aAdd(aCampos, { 'DTBASE', 'D', 10, 0}) //Data Base
	aAdd(aCampos, { 'ENTREGA', 'C', 1, 0}) //S SIM N NAO
	aAdd(aCampos, { 'PRAZOENT', 'C', 40, 0}) //Prazo Entrega
	aAdd(aCampos, { 'DATAFATURA',  'D', 10, 0}) //Data Fatura
	aAdd(aCampos, { 'FATURAESP',  'C', 1, 0}) //E=Especifica;I=Intervalo
	aAdd(aCampos, { 'ANTECIPA',  'C', 1, 0})//S=Sim;N=Nao
	aAdd(aCampos, { 'TIPOBASE',  'C', 1, 0}) //E=Especifica;R=Referenciada
	aAdd(aCampos, { 'DTREFEST',  'D', 10, 0}) //Data Referencia Especifica
	aAdd(aCampos, { 'VOLUME1', 'N', 4, 0}) //Volume
	aAdd(aCampos, { 'ESPECIE', 'C', 15, 0}) //Especie
	aAdd(aCampos, { 'VALORFAT', 'N', 16, 2}) //Valor
	aAdd(aCampos, { 'NOTA', 'C', 9, 0}) //Nota Fiscal
	aAdd(aCampos, { 'SERIE', 'C', 3, 0}) //Série
	aAdd(aCampos, { 'NUMGNRE', 'C', 12, 0}) //GNRE
	aAdd(aCampos, { 'ESTADO', 'C', 2, 0}) //Estado
	aAdd(aCampos, { 'VALORGNRE', 'N', 16, 2}) //VAlor GNRE
	aAdd(aCampos, { 'RECIBO', 'C', 30, 0}) //Recibo GNRE
	aAdd(aCampos, { 'LEG', 'C', 1, 0}) //Status leganda


	cArq:=Criatrab(aCampos,.T.)
	DBUSEAREA(.t.,,carq,"TTRB",.F.,.F.)
	IndRegua("TTRB",Left(cArq,7)+'A',"CONDPAG",,,"Selecionando Registros...")

	dbClearIndex()
	dbSetIndex(Left(cArq,7)+'A' + OrdBagExt())

	dbSelectArea("TTRB")
	dbSetOrder(1)

	If (Select("BD1462") <> 0)
		dbSelectArea("BD1462")
		dbCloseArea()
	EndIf

	If MV_PAR03 == "N"

		BUDQRY(1)

	EndIf

	PLSQuery(cQry, 'BD1462')

	//Definindo o tamanho da régua
	DbSelectArea('BD1462')
	Count to nTotal
	ProcRegua(nTotal)
	BD1462->(DbGoTop())

	dbSelectArea("BD1462")
	dbGoTop()
	nTotalWhile := 0

	SE4->(DBSetOrder(1))

	While  BD1462->(!Eof())

		nTotalWhile ++
		IncProc('Buscando Pedido ' + cValToChar(nTotalWhile) + ' do total de ' + cValToChar(nTotal) + '...')

		aCdCores  := {{ 'BR_VERDE'    	,"PEDIDO EM ESPERA"},;
			{ 'BR_BRANCO' 				,"PEDIDO EM PROCESSO"},;
			{ 'BR_AMARELO'	    		,"PEDIDO FINALIZADO"},;
			{ 'BR_PRETO'	    		,"PEDIDO REJEITADO"},;
			{ 'BR_CANCEL'	        	,"PEDIDO CANCELADO"},;
			{ 'BR_VERMELHO'	        	,"PEDIDO FATURADO"},;
			{ 'BR_VIOLETA'	    	    ,"PEDIDO FINALIZADO / A VISTA"},;
			{ 'BR_LARANJA'	        	,"BLOQ. FAT. COMERCIAL"}}

		IF SE4->(DBSEEK(xFilial("SE4")+BD1462->C5_CONDPAG)) //FILIAL+CONDICAO PAGTO
			cCondDes := SE4->E4_DESCRI
		ELSE
			cCondDes := " "
		ENDIF

		// Rotina para verificar se está bloqueado comercialmente:
		If (Select("B14INC2") <> 0)
			dbSelectArea("B14INC2")
			dbCloseArea()
		EndIf

		cCons2 := "SELECT C5_NUM  "
		cCons2 += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
		cCons2 += "WHERE D_E_L_E_T_ = '' "
		cCons2 += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
		cCons2 += "AND C5_NUM = '"+BD1462->C5_NUM+"'  "
		cCons2 += "AND C5_BLQCM = '2' "
		cCons2 += "AND C5_CDBLQC NOT IN ('', '0019')  "
		TCQuery cCons2 NEW ALIAS "B14INC2"
		If !B14INC2->(EOF())
			_cLegSt := "B"
		Else

			//Validação antecipada para trazer as legeendas da tela
			If Alltrim(BD1462->C5_STLOGIS) == "EM ESPERA"
				_cLegSt := "E"
			ElseIF Alltrim(BD1462->C5_STLOGIS) == "EM PROCESSO"
				_cLegSt := "P"
			ElseIF Alltrim(BD1462->C5_STLOGIS) == "FINALIZADO"
				IF  Alltrim(BD1462->C5_STLOGIS) == "FINALIZADO" .AND. Alltrim(cCondDes) == "A VISTA"
					_cLegSt := "H"
				ELSE
					_cLegSt := "F"
				ENDIF
			ElseIF Alltrim(BD1462->C5_STLOGIS) == "REJEITADO"
				_cLegSt := "R"
			ElseIF Alltrim(BD1462->C5_STLOGIS) == "CANCELADO"
				_cLegSt := "C"
			ElseIF Alltrim(BD1462->C5_STLOGIS) == "FATURADO"
				_cLegSt := "G"
			EndIF

		EndIF

		_cRetStatus := U_B1462Leg(_cLegSt)

		DbSelectArea("TTRB")
		RecLock("TTRB",.T.)

		TTRB->STATUS := _cRetStatus
		TTRB->CONDPAG := BD1462->C5_CONDPAG
		TTRB->CDPDESC := Alltrim(cCondDes)
		TTRB->PEDIDO := BD1462->C5_NUM
		TTRB->CLIENTE := BD1462->C5_CLIENTE
		TTRB->LOJACLI := BD1462->C5_LOJACLI
		TTRB->NOME    := ALLTRIM(BD1462->A1_NOME)
		TTRB->DTBASE := BD1462->C5_DTBASE
		TTRB->ENTREGA := BD1462->C5_FTBASE
		TTRB->PRAZOENT := BD1462->C5_DESCPRA
		TTRB->DATAFATURA := BD1462->C5_DTFAT
		TTRB->FATURAESP := BD1462->C5_DTFATES
		TTRB->ANTECIPA := BD1462->C5_ANTECIP
		TTRB->TIPOBASE := BD1462->C5_TPBASE
		TTRB->DTREFEST := BD1462->C5_DTBEST
		TTRB->VOLUME1 := BD1462->C5_VOLUME1
		TTRB->ESPECIE := BD1462->C5_ESPECI1
		TTRB->VALORFAT := BD1462->C5_VALFAT
		TTRB->NOTA := BD1462->C5_NOTA
		TTRB->SERIE := BD1462->C5_SERIE
		TTRB->NUMGNRE := Space(12)
		TTRB->ESTADO := Space(02)
		TTRB->VALORGNRE := 0
		TTRB->RECIBO := Space(30)
		TTRB->LEG := _cLegSt

		MsunLock()

		BD1462->(DbSkip())

	Enddo

	TTRB->(DbGotop())

	aCpoBro	:= {{ "OK"       ,, ""          ,"@!"},;
		{ "STATUS"       ,, "STATUS "   ,"@1!"},;
		{ "CONDPAG"   ,, "CONDPAG"   ,"@1!"},;
		{ "CDPDESC"   ,, "CONDPAG DESC"   ,"@1!"},;
		{ "PEDIDO"   ,, "PEDIDO "   ,"@1!"},;
		{ "CLIENTE"   ,, "CLIENTE"   ,"@1!"},;
		{ "LOJACLI"   ,, "LOJACLI"   ,"@1!"},;
		{ "NOME"      ,, "NOME CLIENTE "   ,"@1!"},;
		{ "DTBASE"    ,, "DTBASE"   ,"@1!"},;
		{ "ENTREGA"     ,, "ENTREGA"   ,"@1!"},;
		{ "PRAZOENT"    ,, "PRAZO ENTREGA"   ,"@1!"},;
		{ "DATAFATURA"  ,, "DATA FATURA"   ,"@1!"},;
		{ "FATURAESP"   ,, "FATURA ESP"   ,"@1!"},;
		{ "ANTECIPA"   ,, "FAT ANTECIPA"   ,"@1!"},;
		{ "TIPOBASE"   ,, "TIPO BASE"   ,"@1!"},;
		{ "DTREFEST"   ,, "DT REF EST"   ,"@1!"},;
		{ "VOLUME1"   ,, "VOLUME1"   ,"@1!"},;
		{ "ESPECIE"   ,, "ESPECIE "   ,"@1!"},;
		{ "VALORFAT"   ,, "VALOR FAT"   ,"@E 999,999,999.99"},;
		{ "NOTA"   ,,  "NOTA"   ,"@1!"},;
		{ "SERIE"   ,,  "SERIE"   ,"@1!"},;
		{ "NUMGNRE"   ,,  "GNRE NUMERO"   ,"@1!"},;
		{ "ESTADO"   ,,"GNRE EST"   ,"@1!"},;
		{ "VALORGNRE"   ,, "GNRE VALOR"   ,"@E 999,999,999.99"},;
		{ "RECIBO"   ,, "GNRE RECIBO"   ,"@1!"},;
		{ "LEG"   ,, "LEG"   ,"@1!"}}


	aCdCores  := {{ 'BR_VERDE'    	,"PEDIDO EM ESPERA"},;
		{ 'BR_BRANCO' 				,"PEDIDO EM PROCESSO"},;
		{ 'BR_AMARELO'	    		,"PEDIDO FINALIZADO"},;
		{ 'BR_PRETO'	    		,"PEDIDO REJEITADO"},;
		{ 'BR_CANCEL'	        	,"PEDIDO CANCELADO"},;
		{ 'BR_VERMELHO'	        	,"PEDIDO FATURADO"},;
		{ 'BR_VIOLETA'	    	    ,"PEDIDO FINALIZADO / A VISTA"},;
		{ 'BR_LARANJA'	        	,"BLOQ. FAT. COMERCIAL"}}


	aCores    := {	{"TTRB->LEG = 'E' ",	aCdCores[1,1]},;
		{"TTRB->LEG== 'P' ",	aCdCores[2,1]},;
		{"TTRB->LEG = 'F'",	aCdCores[3,1]},;
		{"TTRB->LEG = 'R'",	aCdCores[4,1]},;
		{"TTRB->LEG = 'C'",	aCdCores[5,1]},;
		{"TTRB->LEG = 'G'",	aCdCores[6,1]},;
		{"TTRB->LEG = 'H'",	aCdCores[7,1]},;
		{"TTRB->LEG = 'B'",	aCdCores[8,1]}}

	aObjects := {}
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice
	AAdd( aObjects, { 200, 200, .T., .T. } ) // Dados da getdados
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	_oDlg := TDialog():New(0,0,700,2000,"PAINEL FATURAMENTO - Filial 10 - Biancheria",,,,,,,,,.T.,,,,,)
	_oDlg:lCentered := .T.

	DEFINE FONT oFont1 NAME "Tahoma" SIZE 0, -11 BOLD
	DEFINE FONT oFont2 NAME "Tahoma" SIZE 0, -11 BOLD

	nLarg := 408

	//Group Filtros
	@ 002, 001 GROUP oGroup1 TO 060, 250 PROMPT "Filtro" OF _oDlg COLOR 0, 16777215 PIXEL
	@ 032, 078 BUTTON oButton1 PROMPT "Filtrar" SIZE 048, 014 OF _oDlg ACTION Loc1462() PIXEL
	@ 032, 134 BUTTON oButton2 PROMPT "Nfe Sefaz" SIZE 048, 014 OF _oDlg  ACTION SPEDNFE() PIXEL
	@ 032, 191 BUTTON oButton3 PROMPT "Resumo FAT" SIZE 048, 014 OF _oDlg ACTION U_B1462Resumo() PIXEL
	@ 014, 017 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "PEDIDO","CLIENTE","GRUPO" SIZE 051, 036 OF _oDlg COLOR 0, 16777215 PIXEL
	@ 015, 078 MSGET oGet1 VAR cGet1 SIZE 161, 014 OF _oDlg COLORS 0, 16777215 PIXEL

	//Group funções  e  gerar nota
	@ 002, 260 GROUP oGroup2 TO 060, 347 PROMPT "Funções" OF _oDlg COLOR 0, 16777215 PIXEL
	@ 010, 268 BUTTON oButton4 PROMPT "OUTRAS AÇÕES" SIZE 070, 014 OF _oDlg   ACTION u_B1462TSTopUp() PIXEL
	@ 026, 268 BUTTON oButton5 PROMPT "GERAR NOTA" SIZE 070, 014 OF _oDlg ACTION Processa({|| u_B1462NOTA() },OemToAnsi("Aguarde...Iniciando FATURAMENTO do(s) pedido(s) selecionado(s)...")) PIXEL
	@ 042, 268 BUTTON oButton6 PROMPT "ATUALIZAR" SIZE 070, 014 OF _oDlg ACTION Processa({|| aPerg62() },OemToAnsi("Aguarde...Iniciando atualização do Painel..."))  PIXEL

	oButton5:SetCSS( getCSS('TBUTTON_01') )

	nLin := c(55)
	nCol := c(1)
	nLarg:= c(833)//c(890)
	nAlt := c(280)

	oMark := MsSelect():New("TTRB","OK",,aCpoBro,@lInverte,@cMarca,{nLin,nCol,nAlt,nLarg},,,_oDlg,,aCores)
	oMark:oBrowse:lHasMark		:= .T.
	oMark:oBrowse:lCanAllmark	:= .T.
	oMark:oBrowse:lAdjustColSize:= .T.
	oMark:oBrowse:lJustific     := .F.
	oMark:bAval 				:= {|| B1462Mark()}
	oMark:oBrowse:bAllMark 		:= {|| B1462All()}
	//oMark:oBrowse:bRClicked := { |o,Nx,Ny| U_B1462TSTopUp( Nx, Ny, oMark ) }

	nVlrPed:= SPACE(150)
	cParceir:= SPACE(150)

	ocParceir := TSay():New(249,226,{|| cParceir},_oDlg,,oFont2,,,,.T.,CLR_HBLUE,CLR_WHITE)

	_oDlg:Activate(,,,.T.,,,)

Return

Static Function Disp()
	RecLock("TTRB",.F.)
	If Marked("OK")
		TTRB->OK := cMark
	Else
		TTRB->OK := ""
	EndIf

	MSUNLOCK()

	oMark:oBrowse:Refresh()
Return ()

Static Function B1462Mark()

	dbSelectArea("TTRB")

	RecLock('TTRB',.F.)
	If Empty(TTRB->OK) .and. (TTRB->LEG == "F" .OR. TTRB->LEG == "H")
		TTRB->OK:= cMarca
	ElseIF !Empty(TTRB->OK) .and. (TTRB->LEG == "F" .OR. TTRB->LEG == "H")
		TTRB->OK:= "  "
	Else
		TTRB->OK:= "  "
		MsgAlert("ATENÇÃO - Pedido com bloqueio para faturamento!!!")
	EndIf
	TTRB->(MsUnlock())

	_oDlg:Refresh()

Return

Static Function B1462All()

	Local nRecno := TTRB->(Recno())
	dbSelectArea("TTRB")
	TTRB->(dbGoTop())
	While TTRB->(!Eof())
		B1462Mark()
		TTRB->(dbSkip())
	EndDo

	TTRB->(dbGoTo(nRecno))
	_oDlg:Refresh()

Return .T.

Static Function Loc1462()

	Local cPesq:=""
	dbSelectArea("TTRB")
	IF nRadMenu1 == 1
		B1462Ordem()
		cPesq	:= cGet1
	ElseIf nRadMenu1 == 2
		B1462Ordem()
		cPesq:= cGet1
	ElseIf nRadMenu1 == 3
		B1462Ordem()
		cPesq:= cGet1
	EndIf

	TTRB->(dbSeek(Alltrim(cPesq),.T.))

	oMark:oBrowse:Refresh()
Return()

Static Function B1462Ordem()

	// Verifica a ordem informada pelo usuario e cria o indice novamente
	////////////////////////////////////////////////////////////////////////////////////////
	dbSelectArea("TTRB")
	If nRadMenu1 == 1
		IndRegua("TTRB",Left(cArq,7)+'A',"PEDIDO",,,"Selecionando Registros...")//Index on TTRB->PEDIDO to &TTRB
	ElseIf nRadMenu1 == 2
		IndRegua("TTRB",Left(cArq,7)+'A',"CLIENTE",,,"Selecionando Registros...")//Index on TTRB->CLIENTE to &TTRB
	EndIf

	TTRB->(dbGoTop())

	oMark:oBrowse:Refresh()

Return

Static Function AtGrid()

	dbSelectArea("TTRB")
	TTRB->(dbGoTop())
	cEdit1	 := Space(25)
	IndRegua("TTRB",Left(cArq,7)+'A',"PEDIDO",,,"Selecionando Registros...")//Index on TTRB->PEDIDO to &TTRB
	oMark:oBrowse:Refresh()
	U_B1462TSTopUp()
Return()


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.20//1.28
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8/11/12" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPos ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna numero da coluna onde se encontra o Campo na         ³±±
±±³           ³ NewGetDados                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Numero da coluna localizada pelo aScan                       ³±±
±±³           ³ OBS: Se retornar Zero significa que nao localizou o Registro ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldPos(oObjeto,cCampo)
	Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
Return(nCol)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldGet ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna Valor da Celula da NewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ xRet := O Valor da Celula independente de seu TYPE           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldGet(oObjeto,cCampo,nLinha)
	Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
	Local xRet
	// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
	Default nLinha := oObjeto:nAt
	xRet := oObjeto:aCols[nLinha,nCol]
Return(xRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPut ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Alimenta novo Valor na Celula da NewGetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±³           ³ xNewValue := Valor a ser inputado na Celula.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldPut(oObjeto,cCampo,nLinha,xNewValue)
	Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
	// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
	Default nLinha := oObjeto:nAt
	// Alimenta Celula com novo Valor se este foi preenchido
	If !Empty(xNewValue)
		oObjeto:aCols[nLinha,nCol] := xNewValue
	Endif
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwDeleted  ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se a linha da NewGetDados esta Deletada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ lRet := True = Linha Deletada / False = Nao Deletada         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwDeleted(oObjeto,nLinha)
	Local nCol := Len(oObjeto:aCols[1])
	Local lRet := .T.
	// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
	Default nLinha := oObjeto:nAt
	// Alimenta Celula com novo Valor
	lRet := oObjeto:aCols[nLinha,nCol]
Return(lRet)

//User Function B1462TSTopUp(030, 030, _oDlg)

User Function B1462TSTopUp(nLeft, nTop, _oDlg)

	Local oMenu
	Local oMenuItem  := {}

	Local MV_PAR01	:= 	TTRB->PEDIDO
	Local cPedComp	:= TTRB->PEDIDO

	nLeft :=325
	nTop := 150

	CursorWait()
	MENU oMenu POPUP
	//MenuItem "Pedidos" Action ExecBlock("B889Ped",.F.,.F.) RESOURCE 'PARAMETROS'
	MenuItem "Pedidos" Action MATA410() RESOURCE 'PARAMETROS'
	MenuItem "Monitor NF-e" Action SpedNFe1Mnt() RESOURCE 'PMSDOC'
	//MenuItem "Complemento Pedido" Action U_BUD039("","" )  RESOURCE 'RECALC'
	MenuItem "Complemento Pedido" Action B1462Compl(1)  RESOURCE 'RECALC'
	MenuItem '_____________' DISABLED
	MenuItem "Visualizar" Action MATA410() RESOURCE 'BMPINCLUIR'
	MenuItem "Danfe" Action SPEDNFE() RESOURCE 'EXCLUIR'
	MenuItem '_____________' DISABLED
	//MenuItem "Em Desenvolvimento" Action B1462Desenv() RESOURCE "BTCALEND"
	//MenuItem "Em Desenvolvimento" Action B1462Desenv() RESOURCE "PESQUISA"
	//MenuItem "Em Desenvolvimento"  Action oMenu:End() RESOURCE 'PREV'
	ENDMENU

	CursorArrow()

	ACTIVATE POPUP oMenu AT nLeft, nTop OF _oDlg

Return

Static Function getCSS( cClass )

	Local cCSS      := '' as character
	Default cClass    := ''

	If cClass == 'TBUTTON_01'
		cCSS   += "QPushButton { color: white }"
		cCSS   += "QPushButton { font-weight: bolder }"
		cCSS   += "QPushButton { border: 2px solid #CECECE }"
		cCSS   += "QPushButton { background-color: red }"
		cCSS   += "QPushButton { border-radius: 8px }"
		//cCSS   += "QPushButton:hover { background-color: #434bdf } "
		//cCSS   += "QPushButton:hover { border-style: solid } "
		//cCSS   += "QPushButton:hover { border-width: 4px }"
		//cCSS   += "QPushButton:pressed { background-color: #373fd4 }"
		cCSS   += "QPushButton:focus { background-color: #1c25d7 } "
		cCSS   += "QPushButton:focus { border-style: solid } "
		cCSS   += "QPushButton:focus { border-width: 8px }"
	Endif

Return( cCSS )

//https://tdn.totvs.com/pages/releaseview.action?pageId=578374528
User Function B1462NOTA()

	Private lPula33 := .F.
	Private cSerie := "5  "
	Private aPvlNfs:= {}


	TTRB->(dbGoTop())
	While TTRB->(! Eof())
		If !Empty(TTRB->OK) //campos selecionados

			lPula33 := .F.

			IF Alltrim(TTRB->CDPDESC) == "A VISTA" .AND. Alltrim(TTRB->LEG) == "H"

				IF !cVldTit(TTRB->PEDIDO,TTRB->CLIENTE,TTRB->LOJACLI,TTRB->VALORFAT)
					//Se for a vista, não ter nota RA com saldo na SE1, não gera nota
					MsgAlert("PEDIDO A VISTA! VERIFICADO QUE NÃO HOUVE BAIXA DE TÍTULO. FAVOR VERIFICAR COM O SETOR FINANCEIRO." +;
						"  --  PEDIDO: "+TTRB->PEDIDO + "  --  CLIENTE: " + TTRB->CLIENTE + "  --  LOJA: " + TTRB->LOJACLI +;
						"  --  VALOR: " + Transform(TTRB->VALORFAT,"999999999.99"))
					lPula33 := .T.
				ENDIF

			ENDIF

			IF 	!lPula33

				U_LibPed(TTRB->PEDIDO, TTRB->CLIENTE, TTRB->LOJACLI)

				dbSelectArea("SC9")
				SC9->(dbSetOrder(1))
				SC9->(dbSeek(xFilial("SC9") + TTRB->PEDIDO, .T.))
				While !EOF("SC9") .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == TTRB->PEDIDO

					//Validação necessária para os pedidos parciais
					If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == "" .And. AllTrim(SC9->C9_CREDBUD) <> "10"
						//abre o cabecalho dos pedidos
						SC5->(DbSetOrder(1))
						SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO))
						cCliente := SC5->C5_CLIENTE
						cLoja    := SC5->C5_LOJACLI

						//abre os itens dos pedidos
						SC6->(dbSetOrder(1))
						SC6->(MsSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))

						SE4->(DbSetOrder(1))
						SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

						SB1->(DbSetOrder(1))
						SB1->(MsSeek(xFilial("SB1") + SC9->C9_PRODUTO))    //FILIAL+PRODUTO

						SB2->(DbSetOrder(1))
						SB2->(MsSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL)) //FILIAL+PRODUTO+LOCAL

						SF4->(DbSetOrder(1))
						SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))   //FILIAL+TES

						aAdd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
							SC9->C9_ITEM,;
							SC9->C9_SEQUEN,;
							SC9->C9_QTDLIB,;
							SC9->C9_PRCVEN,;
							SC9->C9_PRODUTO,;
							.F.,;
							SC9->(RecNo()),;
							SC5->(RecNo()),;
							SC6->(RecNo()),;
							SE4->(RecNo()),;
							SB1->(RecNo()),;
							SB2->(RecNo()),;
							SF4->(RecNo()) } )

					EndIf

					dbSelectArea("SC9")
					SC9->(dbSkip())
				EndDo

				If !Empty(aPvlNfs)
					lMsErroAuto := .F.
					cNota := MaPvlNfs(aPvlNfs, cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.,)

					If lMsErroAuto
						MsgAlert("Ocorreu um erro na geração da Nota Fiscal!" + "  --  PEDIDO: "+TTRB->PEDIDO )
						aPvlNfs:= {}
						DisarmTransaction()
						Mostraerro()
					Else
						//MsgAlert("Nota fiscal  " + cNota  + "  gerada com sucesso  para o pedido  " + TTRB->PEDIDO)

						//Altero o Status do pedido para faturado
						RecLock("TTRB",.F.)
						If !Empty(cNota)
							TTRB->OK 	 := ""
							TTRB->STATUS := "PEDIDO FATURADO"
							TTRB->NOTA 	 := cNota
							TTRB->SERIE  := cSerie
							TTRB->LEG    := "G"
						EndIf
						MSUNLOCK()

						SC5->(DbSetOrder(1))
						If SC5->(MsSeek(xFilial("SC5") + TTRB->PEDIDO))
							RecLock("SC5",.F.)
							SC5->C5_PAINEL := "S"
							MSUNLOCK()
						EndIf

						aPvlNfs:= {}
					EndIf

					MsUnlockAll()

				EndIf
			EndIf

		EndIf

		dbSelectArea("TTRB")
		TTRB->(dbSkip())
	EndDo

	//TTRB->(dbCloseArea())
	//BUDQRY(2)
	oMark:oBrowse:Refresh()
	//oDlg:End()

Return

Static Function B1462Compl(nTipo)

	SetPrvt("CPERG,AREGISTROS,I,J,cPedComp")
	SetPrvt("CTRANSP,CPGTO,CTPFRETE,CREDESPACHO,NFRETE,NSEGURO,CEPVOL,dDtBase,oText1,oText2")
	SetPrvt("NDESPESA,CTEXT1,CTEXT2,CTEXT3,CTEXT4,cTxtBuff1,cTxtBuff2,NVOLUME1,CESPECI1,NPESOL")
	SetPrvt("NPBRUTO,CMENSA1,CMENSA2,CMENSA3,CMENSA4,CMENSA5")
	SetPrvt("CMENSA6,NFRETEFOB,NPERCOMI,ACRA,NTXMOEDA")

	nVOL :=	0

	cPerg := "BUD039"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Numero do Pedido   ?","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","SC5"})
	CriaPerguntas(cPerg,aRegistros)
	If !Pergunte(cPerg,.t.)
		Return
	Else
		cPedComp	:= MV_PAR01
	endif
	If Empty(cPedComp)
		Return
	EndIf

	SELE SC5
	IF dbSeek(xFilial("SC5")+cPedComp)
		// Se caso a transportadora estiver vazia, busca do cadastro de cliente:
		cTRANSP     := SC5->C5_TRANSP
		If Empty(cTRANSP)
			cTRANSP	:= Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI, "A1_TRANSP")
		End If

		cPGTO       := SC5->C5_CONDPAG
		cTPFRETE    := SC5->C5_TPFRETE
		cPLACA		:= SC5->C5_VEICULO//Rodrigo 31/10/2013
		cREDESPACHO := SC5->C5_REDESP
		nFRETE      := SC5->C5_FRETE
		nSEGURO     := SC5->C5_SEGURO
		nDESPESA    := SC5->C5_DESPESA
		cTEXT1      := SC5->C5_TEXT1
		cTEXT2      := SC5->C5_TEXT2
		If ("SC5")->(FieldPos("C5_TEXT3") > 0 )
			cTEXT3      := SC5->C5_TEXT3
		EndIf
		If ("SC5")->(FieldPos("C5_TEXT4") > 0 )
			cTEXT4      := SC5->C5_TEXT4
		EndIf
		cTxtBuff1	:= SC5->C5_TEXT1
		cTxtBuff2	:= SC5->C5_TEXT2
		If nVOL > 0
			nVOLUME1    := /*SC5->C5_VOLUME1*/  IIF((substr(cPedComp,1,2) $ AllTrim(GetMv("BD_PREFEXP"))),SC5->C5_VOLUME1,nVOL)
		Else
			nVOLUME1    := SC5->C5_VOLUME1
		EndIf

		// Caso a espécie estiver vazia, trago como padrão alguma caixa que foi gerado por aquela etiqueta:
		cESPECI1    := SC5->C5_ESPECI1
		If Empty(cESPECI1) .And. !Empty(cEPVOL)
			cESPECI1	:= cEPVOL
		End If

		NTXMOEDA := SC5->C5_TXMOEDA

		nPESOL      := SC5->C5_PESOL
		nPBRUTO     := SC5->C5_PBRUTO
		cMENSA1     := SC5->C5_MENSNF1
		If Empty(SC5->C5_MENSNF1)
			cMENSA1     := "CIF ATE DESTINO"
		EndIf
		cMENSA2     := SC5->C5_MENSNF2

		cMENSA3     := SC5->C5_MENSNF3
		cMENSA4     := SC5->C5_MENSNF4
		cMENSA5     := SC5->C5_MENSNF5
		cMENSA6     := SC5->C5_MENSNF6
		nFRETEFOB   := SC5->C5_PERFRE
		nPERCOMI    := SC5->C5_PERCOMI
		dDtBase		:= SC5->C5_DTBASE
		aCRA      :={ "Confirma" , "Redigita" , "Abandona" }

		nOp1:=0

		@ 05,05 TO 480,610 DIALOG oDlg1 TITLE "Pedido - "+SC5->C5_NUM

		@ 05,05 TO 170,300
		@ 010,010 Say "Transp: "
		@ 010,045 Get cTransp F3 "SA4"
		@ 010,110 Say "Cond.Pgto: "
		@ 010,160 Get cPgto PICT "@!" F3 "PGT"

		@ 010,200 Say "Dt.Base: "
		@ 010,230 Get dDtBase SIZE 50,10

		//Rodrigo 31/10/2013
		@ 020,110 Say "Placa do Veículo: "
		@ 020,160 Get cPlaca PICT "@!"
		//Fim Rodrigo
		@ 020,010 Say "Tp Frete: "+space(18)+" (C)if  ou  (F)ob "
		@ 020,045 Get cTpFrete valid Pertence("CF")
		@ 030,010 Say "Redespacho: "
		@ 030,045 Get cRedespacho PICT "@!" F3 "SA4"

		if SC5->C5_TIPOCLI == "X"
			@ 030,110 Say "TX. Moeda: "
			@ 030,160 Get NTXMOEDA PICT "@E 99,999.9999" SIZE 50,10
		EndIF

		@ 040,010 Say "Vl. Frete : "
		@ 040,045 Get nFrete PICT "@E 999,999.99" SIZE 50,10
		@ 040,110 Say "Vl. Seguro: "
		@ 040,160 Get nSeguro PICT "@E 999,999.99" SIZE 50,10
		@ 050,010 Say "Despesa : "
		@ 050,045 Get nDespesa PICT "@E 999,999.99" SIZE 50,10
		@ 060,010 Say "Volume 1: "
		@ 060,045 Get nVolume1 pict "99999"
		@ 060,110 Say "Especie 1: "
		@ 060,160 Get cEspeci1 Pict "@!" F3 "EE5"

		// Peso somente para pedidos unitários:

		@ 070,010 Say "Peso Liq.: "
		@ 070,045 Get nPesol pict "@E 99,999.9999"  SIZE 50,10
		@ 070,110 Say "Peso Bruto: "
		@ 070,160 Get nPBruto pict "@E 99,999.9999" SIZE 50,10


		@ 080,010 Say "% Frete FOB.: "
		@ 080,110 Say "% Comissao Exp.: "
		if SC5->C5_TIPOCLI == "X"
			@ 080,045 Get nFreteFOB pict "@E 99.999999"
			@ 080,160 Get nPerComi pict "@E 99.99"
		endif
		@ 090,010 Say "Tx. Leg.1: "
		@ 090,045 Get cText1 PICT "@!" F3 "SZ4"
		@ 090,110 Say "Tx. Leg.2: "
		@ 090,160 Get cText2 PICT "@!" F3 "SZ4"
		If ("SC5")->(FieldPos("C5_TEXT3") > 0 )
			@ 100,010 Say "Tx. Leg.3: "
			@ 100,045 Get cText3 PICT "@!" F3 "SZ4"
		EndIf
		If ("SC5")->(FieldPos("C5_TEXT4") > 0 )
			@ 100,110 Say "Tx. Leg.4: "
			@ 100,160 Get cText4 PICT "@!" F3 "SZ4"
		EndIf

		@ 110,010 Say "Mensagem:"
		@ 110,045 Get cMensa1 PICT "@!S45" SIZE 200,10
		@ 120,045 Get cMensa2 PICT "@!S45" SIZE 200,10
		@ 130,045 Get cMensa3 PICT "@!S45" SIZE 200,10
		@ 140,045 Get cMensa4 PICT "@!S45" SIZE 200,10
		@ 150,045 Get cMensa5 PICT "@!S45" SIZE 200,10
		@ 160,045 Get cMensa6 PICT "@!S45" SIZE 200,10
		@ 185,200 BUTTON "Confirma" Size 40,10 ACTION B1462C5(nTipo)
		@ 185,260 BUTTON "Sair" Size 40,10  ACTION (oDlg1:End(), nOp1:= 1, lOk := .F.)

		ACTIVATE DIALOG oDlg1 CENTERED

	Else
		MsgBox ("NUMERO DO PEDIDO NAO ENCONTRADO","Atenção","ALERT")
	Endif

Return

Static Function CriaPerguntas(cGrupo,aPer)

	LOCAL aReg  := {}
	Local _l	:= 0

	DbSelectArea("SX1")
	If (FCount() == 39)
		For _l := 1 to Len(aPer)
			Aadd(aReg,{cGrupo,aPer[_l,2],aPer[_l,3],"","",aPer[_l,4],aPer[_l,5],;
				aPer[_l,6],aPer[_l,7],aPer[_l,8],aPer[_l,9],aPer[_l,10],;
				aPer[_l,11],aPer[_l,12],"","",aPer[_l,13],aPer[_l,14],;
				aPer[_l,15],"","",aPer[_l,16],aPer[_l,17],aPer[_l,18],"","",;
				aPer[_l,19],aPer[_l,20],aPer[_l,21],"","",aPer[_l,22],;
				aPer[_l,23],aPer[_l,24],"","",aPer[_l,25],aPer[_l,26],""})
		Next _l
	Elseif (FCount() == 26)
		aReg := aPer
	Endif

Return

Static FUNCTION B1462C5(Tipo)

	Local _i := 0
	//Private aPedUpd := {}
	//Trato pedidos de exportação.
	//Tipo 1 Nacional
	//Tipo 2 Exportação
	If Tipo == 2

		For _i := 1 to Len(oMSNewGe1:ACOLS)

			dbSelectArea("SC5")
			dbSetOrder(1)
			dbGoTop()
			If dbSeek(xFilial("SC5")+oMSNewGe1:ACOLS[_i][1])

				Reclock("SC5", .F.)
				SC5->C5_TRANSP  := cTransp
				SC5->C5_TPFRETE := cTpFrete
				SC5->C5_VEICULO := cPlaca
				SC5->C5_CONDPAG := cPgto
				SC5->C5_REDESP  := cRedespacho
				SC5->C5_FRETE   := 0
				SC5->C5_SEGURO  := 0
				SC5->C5_DESPESA := 0
				SC5->C5_PERFRE  := 0
				SC5->C5_PERCOMI := 0
				SC5->C5_TEXT1   := ""
				SC5->C5_TEXT2   := ""
				If ("SC5")->(FieldPos("C5_TEXT3") > 0)
					SC5->C5_TEXT3 := cTEXT3
				EndIf
				If ("SC5")->(FieldPos("C5_TEXT4") > 0)
					SC5->C5_TEXT4 := cTEXT4
				EndIf
				SC5->C5_MENSNF1 := cMensa1
				SC5->C5_MENSNF2 := cMensa2
				SC5->C5_MENSNF3 := cMensa3
				SC5->C5_MENSNF4 := cMensa4
				SC5->C5_MENSNF5 := cMensa5
				SC5->C5_MENSNF6 := cMensa6
				SC5->C5_DTBASE  := dDtBase
				//Para exportação somente o ultimo pedido é atualizado com peso e volume
				If _i == Len(oMSNewGe1:ACOLS)
					SC5->C5_MENSNF1 := cMensa1
					SC5->C5_MENSNF2 := cMensa2
					SC5->C5_MENSNF3 := cMensa3
					SC5->C5_MENSNF4 := cMensa4
					SC5->C5_MENSNF5 := cMensa5
					SC5->C5_MENSNF6 := cMensa6
					SC5->C5_DTBASE  := dDtBase
					SC5->C5_TRANSP  := cTransp
					SC5->C5_TPFRETE := cTpFrete
					SC5->C5_VEICULO := cPlaca
					SC5->C5_CONDPAG := cPgto
					SC5->C5_REDESP  := cRedespacho
					SC5->C5_MENSNF1 := cMensa1
					SC5->C5_SEGURO  := nSeguro
					SC5->C5_DESPESA := nDespesa
					SC5->C5_TEXT1   := cText1
					SC5->C5_TEXT2   := cText2
					SC5->C5_PERCOMI := nPERCOMI
					SC5->C5_FRETE   := nFrete
					SC5->C5_TXMOEDA := NTXMOEDA
					SC5->C5_PERFRE  := nFRETEFOB
					SC5->C5_PESOL   := nPesol
					SC5->C5_PBRUTO  := nPBruto
					SC5->C5_VOLUME1 := nVolume1
					SC5->C5_ESPECI1 := cEspeci1
					If nFreteFOB > 0
						SELE SC6
						dbSeek(xFilial("SC6")+oMSNewGe1:ACOLS[_i][1])
						While !eof() .and. SC6->C6_NUM == oMSNewGe1:ACOLS[_i][1]
							reclock("SC6",.f.)
							nPrcVen := nPreDes:=0
							nPrcVen := SC6->C6_PRORIG - ((SC6->C6_PRORIG * nFRETEFOB) / 100) // Alterado por Paulo em 15.12.2004
							nPreDes := nPrcVen - ((nPrcVen * nPerComi) / 100)
							SC6->C6_PRCVEN := nPreDes
							SC6->C6_VALOR  := SC6->C6_PRCVEN * SC6->C6_QTDVEN
							SC6->C6_PERFRE := nFRETEFOB
							SC6->C6_PERCOMI:= nPERCOMI
							msunlock("SC6")
							SELE SC9
							dbSeek(xFilial("SC9")+oMSNewGe1:ACOLS[_i][1]+SC6->C6_ITEM,.T.)
							While !eof() .and. xFilial("SC9") == SC9->C9_FILIAL .AND. SC9->C9_PEDIDO == oMSNewGe1:ACOLS[_i][1];
									.and. SC9->C9_ITEM == SC6->C6_ITEM
								if empty(SC9->C9_NFISCAL)
									RECLOCK("SC9",.F.)
									SC9->C9_PRCVEN:=round(SC6->C6_PRCVEN,4)
									MSUNLOCK("SC9")
								Endif
								SELE SC9
								dbSkip()
							EndDo

							SELE SC6
							dbSkip()
						EndDo
					EndIf
				Else //não sendo o ultimo pedido
					SC5->C5_PESOL   := 0
					SC5->C5_PBRUTO  := 0
					SC5->C5_VOLUME1 := 0
					SC5->C5_ESPECI1 := ""
				EndIF

				SC5->(MsUnlock())

			EndIf

		Next _i

	Else
		//Gravação do complemento para projetos DIFERENTES  de exportação
		dbSelectArea("SC5")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SC5")+cPedComp)

			Reclock("SC5", .F.)
			SC5->C5_TRANSP  := cTransp
			SC5->C5_TPFRETE := cTpFrete
			SC5->C5_VEICULO := cPlaca
			SC5->C5_CONDPAG := cPgto
			SC5->C5_REDESP  := cRedespacho
			SC5->C5_FRETE   := nFrete
			SC5->C5_SEGURO  := nSeguro
			SC5->C5_DESPESA := nDespesa
			SC5->C5_PESOL   := nPesol
			SC5->C5_PBRUTO  := nPBruto
			SC5->C5_VOLUME1 := nVolume1
			SC5->C5_ESPECI1 := cEspeci1
			SC5->C5_PERFRE  := nFRETEFOB
			SC5->C5_PERCOMI := nPERCOMI
			SC5->C5_TEXT1   := cText1
			SC5->C5_TEXT2   := cText2
			If ("SC5")->(FieldPos("C5_TEXT3") > 0)
				SC5->C5_TEXT3 := cTEXT3
			EndIf
			If ("SC5")->(FieldPos("C5_TEXT4") > 0)
				SC5->C5_TEXT4 := cTEXT4
			EndIf
			SC5->C5_MENSNF1 := cMensa1
			SC5->C5_MENSNF2 := cMensa2
			SC5->C5_MENSNF3 := cMensa3
			SC5->C5_MENSNF4 := cMensa4
			SC5->C5_MENSNF5 := cMensa5
			SC5->C5_MENSNF6 := cMensa6
			SC5->C5_DTBASE  := dDtBase
			SC5->(MsUnlock())

		EndIf

	EndIf

	Close(oDlg1)

return

User Function B1462Resumo()

	MsgStop("ROTINA EM DESENVOLVIMENTO E ANALISE")

Return

User Function B1462Export()
	Local oButton1
	Local oButton2
	Local oFont1 := TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)

	Static oDlg

	STATIC oMSNewGe1

	DEFINE MSDIALOG oDlg TITLE "PEDIDO(S) EXPORTAÇÃO" FROM 000, 000  TO 370, 950 COLORS 0, 16777215 PIXEL

	fMSNewGe1()

	@ 162, 383 BUTTON oButton1 PROMPT "Gerar Nota" SIZE 086, 018 OF oDlg FONT oFont1 ACTION Processa({|| B1462NFEXP() },OemToAnsi("Aguarde... Selecionando os pedidos para gerar a nota fiscal!"))  PIXEL
	@ 162, 290 BUTTON oButton2 PROMPT "Complemento" SIZE 086, 018 OF oDlg FONT oFont1 ACTION B1462Compl(2) PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------
Static Function fMSNewGe1()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}

	Local aFieldFill := {}
	Local aFields := {"PEDIDO","C5_CLIENTE","C5_LOJACLI","A1_NOME","C5_EMISSAO","C5_VOLUME1","C5_ESPECI1"}
	Local aAlterFields := {"PEDIDO"}

	PRIVATE INCLUI
	PRIVATE aColsEx := {}
	PRIVATE aCols := {}

	STATIC oMSNewGe1

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	aAdd(aHeaderEx, {'PEDIDO'	        ,'PEDIDO' , '@!'          , 6 , 0 ,"u_B1462VEXP()" , , 'C' ,'SC5EXP' , , , }) //1
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	oMSNewGe1 := MsNewGetDados():New( 000, 000, 158, 475, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

User Function B1462VEXP()

	DbSelectArea("SC5")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SC5")+M->PEDIDO,.T.)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGotop()
		DbSeek(xFilial("SA1")+SC5->C5_CLIENTE,.T.)
		lRet:=.T.

		aCols[n,2] := SC5->C5_CLIENTE
		aCols[n,3] := SC5->C5_LOJACLI
		aCols[n,4] := SA1->A1_NOME
		aCols[n,5] := SC5->C5_EMISSAO
		aCols[n,6] := SC5->C5_VOLUME1
		aCols[n,7] := SC5->C5_ESPECI1
		/*If ExistTrigger('C6_PRODUTO') // verifica se existe trigger para este campo
			RunTrigger(2,n,nil,,'C6_PRODUTO')
		Endif*/

		oMSNewGe1:Refresh()
	Else
		MsgStop("Pedido não existe!!!")
		lRet:= .F.
	EndIf

Return(lRet)

Static function B1462NFEXP()

	Local _i := 0

	Private cSerie := "5  "
	Private aPvlNfs:= {}

	For _i := 1 to Len(oMSNewGe1:ACOLS)

		dbSelectArea("SC9")
		SC9->(dbSetOrder(1))
		SC9->(dbSeek(xFilial("SC9") + oMSNewGe1:ACOLS[_i][1] , .T.))
		While !EOF("SC9") .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == oMSNewGe1:ACOLS[_i][1]



			//Validação necessária para os pedidos parciais
			If AllTrim(SC9->C9_BLEST) == "" .And. AllTrim(SC9->C9_BLCRED) == "" .And. AllTrim(SC9->C9_CREDBUD) <> "10"
				//abre o cabecalho dos pedidos
				SC5->(DbSetOrder(1))
				SC5->(MsSeek(xFilial("SC5") + SC9->C9_PEDIDO))
				cCliente := SC5->C5_CLIENTE
				cLoja    := SC5->C5_LOJACLI

				//abre os itens dos pedidos
				SC6->(dbSetOrder(1))
				SC6->(MsSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM))

				SE4->(DbSetOrder(1))
				SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG) )  //FILIAL+CONDICAO PAGTO

				SB1->(DbSetOrder(1))
				SB1->(MsSeek(xFilial("SB1") + SC9->C9_PRODUTO))    //FILIAL+PRODUTO

				SB2->(DbSetOrder(1))
				SB2->(MsSeek(xFilial("SB2") + SC9->C9_PRODUTO + SC9->C9_LOCAL)) //FILIAL+PRODUTO+LOCAL

				SF4->(DbSetOrder(1))
				SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))   //FILIAL+TES

				aAdd(aPvlNfs,{ 	SC9->C9_PEDIDO,;
					SC9->C9_ITEM,;
					SC9->C9_SEQUEN,;
					SC9->C9_QTDLIB,;
					SC9->C9_PRCVEN,;
					SC9->C9_PRODUTO,;
					.F.,;
					SC9->(RecNo()),;
					SC5->(RecNo()),;
					SC6->(RecNo()),;
					SE4->(RecNo()),;
					SB1->(RecNo()),;
					SB2->(RecNo()),;
					SF4->(RecNo()) } )

			EndIf

			dbSelectArea("SC9")
			SC9->(dbSkip())
		EndDo

	Next _i

	If !Empty(aPvlNfs)
		lMsErroAuto := .F.
		//cNota := MaPvlNfs(aPvlNfs, cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.,)

		//Trabalho a função para jntar todas as notas iguais e não ter erro no salto de pedido
		cNota := MaPvlNfs(  /*aPvlNfs*/         aPvlNfs,;  // 01 - Array com os itens a serem gerados
			/*cSerieNFS*/       cSerie,;    // 02 - Serie da Nota Fiscal
			/*lMostraCtb*/      .F.,;       // 03 - Mostra Lançamento Contábil
			/*lAglutCtb*/       .F.,;       // 04 - Aglutina Lançamento Contábil
			/*lCtbOnLine*/      .F.,;       // 05 - Contabiliza On-Line
			/*lCtbCusto*/       .T.,;       // 06 - Contabiliza Custo On-Line
			/*lReajuste*/       .F.,;       // 07 - Reajuste de preço na Nota Fiscal
			/*nCalAcrs*/        0,;         // 08 - Tipo de Acréscimo Financeiro
			/*nArredPrcLis*/    0,;         // 09 - Tipo de Arredondamento
			/*lAtuSA7*/         .T.,;       // 10 - Atualiza Amarração Cliente x Produto
			/*lECF*/            .F.,;       // 11 - Cupom Fiscal
			/*cEmbExp*/         	"",;   	   // 12 - Número do Embarque de Exportação
			/*bAtuFin*/         {||},;      // 13 - Bloco de Código para complemento de atualização dos títulos financeiros
			/*bAtuPGerNF*/      {||},;      // 14 - Bloco de Código para complemento de atualização dos dados após a geração da Nota Fiscal
			/*bAtuPvl*/         {||},;      // 15 - Bloco de Código de atualização do Pedido de Venda antes da geração da Nota Fiscal
			/*bFatSE1*/         {|| .T. },; // 16 - Bloco de Código para indicar se o valor do Titulo a Receber será gravado no campo F2_VALFAT quando o parâmetro MV_TMSMFAT estiver com o valor igual a "2".
			/*dDataMoe*/         Date(),; // 17 - Data da cotação para conversão dos valores da Moeda do Pedido de Venda para a Moeda Forte
			/*lJunta*/          .T.)        // 18 - Aglutina Pedido Iguais

		If lMsErroAuto
			MsgAlert("Ocorreu um erro na geração da Nota Fiscal!" )
			aPvlNfs:= {}
			DisarmTransaction()
			Mostraerro()
		Else
			MsgAlert("Nota fiscal  " + cNota  + "  gerada com sucesso!")
			aPvlNfs:= {}
		EndIf

		MsUnlockAll()

	EndIf

Return

User Function B1462Leg(_cStRet)

	Local _cStatusAtual := ""

	If _cStRet == "E"
		_cStatusAtual := "PEDIDO EM ESPERA"
	ElseIf _cStRet == "P"
		_cStatusAtual := "PEDIDO EM PROCESSO"
	ElseIf _cStRet == "F"
		_cStatusAtual := "PEDIDO FINALIZADO"
	ElseIf _cStRet == "R"
		_cStatusAtual := "PEDIDO REJEITADO"
	ElseIf _cStRet ==  "C"
		_cStatusAtual := "PEDIDO CANCELADO"
	ElseIf _cStRet == "G"
		_cStatusAtual := "PEDIDO FATURADO"
	ElseIf _cStRet == "H"
		_cStatusAtual := "PEDIDO FINALIZADO A VISTA"
	ElseIf _cStRet == "B"
		_cStatusAtual := "BLOQ. FAT. COMERCIAL"
	EndIF

Return _cStatusAtual
User Function LibPed(cNumPed, cCliCod, cCodLoja)

	Local aArea     := FWGetArea()
	Local cPedido   := cNumPed
	Local lAvCred := .F.
	Local lAvEst  := .F.
	Local lLibPar := .F.
	Local lTrfLocal := .F.
	Private lContinua := .T.

	lContinua := B1462CRED(cNumPed, cCliCod, cCodLoja)

	If lContinua
		DbSelectArea("SC5")
		SC5->(DbSetOrder(1)) // C5_FILIAL + C5_NUM
		DbSelectArea("SC6")
		SC6->(DbSetOrder(1)) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
		DbSelectArea("SC9")
		SC9->(DbSetOrder(1)) // C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO + C9_BLEST + C9_BLCRED

		//Somente se encontrar o pedido e ele não tiver tido nota emitida ainda
		If SC5->(MsSeek(FWxFilial("SC5") + cPedido)) .And. Empty(SC5->C5_NOTA)
			SC6->(DbGoTop())
			SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )

			//Estorna as liberações
			While ! SC6->(EoF()) .And. SC6->C6_FILIAL = SC5->C5_FILIAL .And. SC6->C6_NUM == SC5->C5_NUM
				//Posiciona na liberação do item do pedido e estorna a liberação
				SC9->(DbSeek(FWxFilial('SC9')+SC6->C6_NUM+SC6->C6_ITEM))
				While  ! SC9->(EoF()) .And. SC9->(C9_FILIAL+C9_PEDIDO+C9_ITEM) == FWxFilial('SC9')+SC6->(C6_NUM+C6_ITEM)
					SC9->(a460Estorna(.T.))
					SC9->(DbSkip())
				EndDo

				SC6->(DbSkip())
			EndDo

			//Define que o pedido foi liberado
			RecLock("SC5", .F.)
			SC5->C5_LIBEROK := 'S'
			SC5->(MsUnlock())

			SC6->(DbGoTop())
			SC6->( MsSeek( SC5->C5_FILIAL + SC5->C5_NUM ) )
			While !SC6->(Eof()) .And. SC5->C5_NUM == SC6->C6_NUM
				lAvCred := .F.
				lAvEst  := .F.
				lLibPar := .F.
				lTrfLocal := .F.

				MaLibDoFat(;
					SC6->(RecNo()),; //nRegSC6 	- Número do recno do registro da SC6
					SC6->C6_QTDVEN,; //nQtdaLib - Quantidade liberada do pedido.
					,;               //lCredito	- Indica se lança crédito
					,;               //lEstoque	- Indica se gera estoque
					lAvCred,;        //lAvCred	- Indica se faz avaliação de crédito
					lAvEst,;         //lAvEst	- Indica se faz avaliação de estoque
					lLibPar,;        //lLibPar	- Indica se faz liberação parcial
					lTrfLocal;       //lTrfLocal- Indica se faz transferência local
					)
				SC6->(DbSkip())
			EndDo
		EndIf

	EndIF
	FWRestArea(aArea)
Return

/*
ANALISA CREDITO COM BASE NAS ROTINAS JA EXISTENTES DA BUDD
*/

Static Function B1462CRED(_Ped, _cCli, _cLj)

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SA1")+_cCli + _cLj)
	_cGrupo:= SA1->A1_GRUPO

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SC5")+_Ped)
	cTPPed :=  SC5->C5_TIPO

	lContinua := .T.

	IF (SELECT("B1462CRED") <> 0)
		DBSELECTAREA("B1462CRED")
		DBCLOSEAREA()
	ENDIF

	BeginSql Alias "B1462CRED"
		Column VALOR AS NUMERIC (14, 2)
		SELECT
			A1_GRUPO,
			E1_CLIENTE,
			E1_LOJA,
			SUM(E1_VALOR) AS VALOR
		FROM
			%Table:SE1% E1 (NOLOCK)
		INNER JOIN %Table:SA1% A1 (NOLOCK)
		ON A1.A1_COD = E1.E1_CLIENTE
			AND A1.A1_LOJA = E1.E1_LOJA
			AND A1.%NotDel%
			AND A1.A1_FILIAL = %xFilial:SA1%
		WHERE
			E1.%NotDel%
			AND E1_CLIENTE = %EXP:_cCli%
			AND E1_LOJA = %EXP:_cLj%
			AND E1_CLIENTE NOT IN (
				'740770',
				'638542',
				'295247',
				'379837',
				'035484',
				'604113',
				'390716',
				'476908',
				'270019',
				'791343'
			)
			AND A1_GRUPO NOT IN ('0016')
			AND (
				E1_BAIXA = ' '
				OR E1_SALDO <> 0
			)
			AND E1_TIPO NOT IN ('NCC', 'RA')
			AND LEFT(E1_CLIENTE, 2) != 'EX'
			AND E1_VENCREA < %EXP:DTOS(DDATABASE)%
			AND A1.A1_RISCO <> 'A'
		GROUP BY
			A1_GRUPO,
			E1_CLIENTE,
			E1_LOJA
	EndSql

	If (SELECT("B1462GRP") <> 0)
		DBSELECTAREA("B1462GRP")
		DBCLOSEAREA()
	EndIf
	//AND E1.E1_FILIAL = %Exp:xFilial("SE1")%
	IF !EMPTY(_cGrupo)

		BeginSql Alias "B1462GRP"
			Column VALOR AS NUMERIC (14, 2)
			SELECT
				A1_GRUPO,
				E1_CLIENTE,
				E1_LOJA,
				SUM(E1_VALOR) AS VALOR
			FROM
				%Table:SE1% E1 (NOLOCK)
			INNER JOIN %Table:SA1% A1 (NOLOCK)
			ON A1.A1_COD = E1.E1_CLIENTE
				AND A1.A1_LOJA = E1.E1_LOJA
				AND A1.%NotDel%
				AND A1.A1_FILIAL = %xFilial:SA1%
			WHERE
				E1.%NotDel%
				AND A1_GRUPO = %EXP:_cGrupo%
				AND E1_CLIENTE NOT IN (
					'128398',
					'740770',
					'638542',
					'295247',
					'379837',
					'035484',
					'604113',
					'390716',
					'638545'
				)
				AND A1_GRUPO NOT IN ('0016')
				AND (
					E1_BAIXA = ' '
					OR E1_SALDO <> 0
				)
				AND E1_TIPO NOT IN ('NCC', 'RA')
				AND LEFT(E1_CLIENTE, 2) != 'EX'
				AND E1_VENCREA < %EXP:DTOS(DDATABASE)%
				AND A1.A1_RISCO <> 'A'
			GROUP BY
				A1_GRUPO,
				E1_CLIENTE,
				E1_LOJA
		EndSql

	EndIf
	//AND E1.E1_FILIAL = %xFilial:SE1%
	BeginSql alias 'B1462VEND'
		%noparser%

		SELECT
			C5_CREDFAT AS CREDFAT,
			C6_NOTA AS NOTA
		FROM
			%table:SC5% C5 (NOLOCK)
		INNER JOIN %table:SC6% C6
		ON C6.C6_NUM = C5.C5_NUM
			AND C6.%NotDel%
			AND C6.C6_FILIAL = %xFilial:SC6%
		WHERE
			C5.%NotDel%
			AND C5.C5_FILIAL = %xFilial:SC5%
			AND C5.C5_NUM = %exp:_Ped%
			AND (
				(C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0
			)
	EndSql

	B1462VEND->(DbCloseArea())

	IF SC5->C5_CREDFAT<>'5' //// ATERADO CONFORME ALINHAMENTO COM A VANESSA/LUCIANO - 31/01/2022 - JONAS
		IF B1462CRED->VALOR > 0  //.AND. SC5->C5_CREDFAT <> '1' //--- Retirado conforme Gediel/Magali
			IF B1462CRED->VALOR > 0  .AND. cTPPed $ "A/B/F"
				BlQCRED(_Ped)
				lContinua := .F.

				Alert("ATENÇÃO!!  PEDIDO "+ _Ped+ " BLOQUEADO POR CRÉDITO " )
			ENDIF

			IF /*SC5->C5_CREDFAT <> '1' .AND. SC5->C5_CREDFAT <> '4'* .AND.*/ B1462CRED->VALOR > 0  .AND. cTPPed $ "N"
				BlQCRED(_Ped)
				lContinua := .F.
				Alert("ATENÇÃO!!  PEDIDO "+ _Ped+ " BLOQUEADO POR CRÉDITO " )
			ENDIF
			/////// BLOQUEA PEDIDO
			IF SC5->C5_CREDFAT == '4'

				SC5->(Reclock("SC5",.F.))
				IIF(!EMPTY(B1462CRED->A1_GRUPO),SC5->C5_CREDFAT:='4',SC5->C5_CREDFAT:='4')
				SC5->(msunlock("SC5"))
				BlQCRED(_Ped)
				lContinua := .F.
				Alert("ATENÇÃO!!  PEDIDO "+ _Ped+ " BLOQUEADO POR CRÉDITO " )
			ELSE
				SC5->(Reclock("SC5",.F.))
				SC5->C5_CREDFAT:='2'
				SC5->(msunlock("SC5"))
			ENDIF

		ENDIF
	ENDIF
	IF !EMPTY(_cGrupo)
		IF SC5->C5_CREDFAT<>'5' //// ATERADO CONFORME ALINHAMENTO COM A VANESSA/LUCIANO - 31/01/2022 - JONAS
			IF B1462GRP->VALOR > 0  /*.AND. SC5->C5_CREDFAT <> '1'*/ .AND. SC5->C5_CONDPAG <> '9A0' //Condição pagamento diferente de 9A0 para não bloquear, solicitado por Jennyfer - Alterado por RobsonJP 20210519 //.AND. !EMPTY(B1462GRP->A1_GRUPO)
				//retirado em função ao fonte BUD1451
				//ALERT("GRUPO CLIENTE "+ POSICIONE("ZZ7",1,XFILIAL("ZZ7")+alltrim(cGrupo),"ZZ7_DESCRI") + " POSSUI TÍTULOS EM ATRASO." +"FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO") //! MSGBOX("CLIENTE "+ B1462CRED->E1_CLIENTE + " POSSUI TÍTULOS EM ATRASO." + " NO VALOR DE "+ Alltrim(TRANSFORM(B1462CRED->VALOR,"@E 99,999,999.99"))+". FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO.DESEJA CONTINUAR?","ATENÇÃO","YESNO")

				IF /*(SC5->C5_CREDFAT <> '4') .AND.*/ B1462GRP->VALOR > 0 .AND. cTPPed $ "A/B/F"
					BlQCRED(_Ped)
					lContinua := .F.
					Alert("ATENÇÃO!!  PEDIDO "+ _Ped+ " BLOQUEADO POR CRÉDITO " )
				ENDIF

				IF /*SC5->C5_CREDFAT <> '1' .AND. SC5->C5_CREDFAT <> '4' .AND.*/ B1462GRP->VALOR > 0  .AND. cTPPed $ "N"
					BlQCRED(_Ped)
					lContinua := .F.
					Alert("ATENÇÃO!!  PEDIDO "+ _Ped+ " BLOQUEADO POR CRÉDITO " )
				ENDIF
				/////// BLOQUEA PEDIDO
				IF SC5->C5_CREDFAT == '4'

					SC5->(Reclock("SC5",.F.))
					SC5->C5_CREDFAT:='2'
					SC5->(msunlock("SC5"))
					BlQCRED(_Ped)
				ELSE
					SC5->(Reclock("SC5",.F.))
					SC5->C5_CREDFAT:='2'
					SC5->(msunlock("SC5"))

				ENDIF

			ENDIF
		ENDIF
	ENDIF

Return lContinua
Static Function BlQCRED(cPED1462)

	Local aArea 	 := GetArea()
	Local aAreaSC9 := SC9->(GetArea())
	Local _cPedido := cPED1462

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SC9")+cPED1462)

		While !SC9->(Eof()) .and. SC9->C9_filial == xFilial("SC9") .AND.  SC9->C9_pedido == _cPedido

			SC9->(Reclock("SC9",.F.))
			SC9->C9_CREDBUD:='10'
			SC9->(msunlock("SC9"))
			SC9->(dbSkip())

		Enddo

		RestArea(aAreaSC9)
		RestArea(aArea)

	EndIf

	RestArea(aAreaSC9)
	RestArea(aArea)

Return

Static Function BUDQRY(nPesq)

	Local cQry01 := ""
	Local aCampos2 := {}
	Local _cLegSt := ""

	cQry01 := " SELECT C5_NUM, C5_STLOGIS, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, C5_CONDPAG, "
	cQry01 += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME  "
	cQry01 += " FROM SC5010 C5, SC6010 C6, SA1010 A1
	cQry01 += " WHERE C6.D_E_L_E_T_ = '' "
	cQry01 += " AND C5.D_E_L_E_T_ = '' "
	cQry01 += " AND C6_FILIAL = '"+xFilial("SC6")+"'  "
	cQry01 += " AND C5_FILIAL = '"+xFilial("SC5")+"'  "

	IF ALLTRIM(DTOS(MV_PAR01))  <> ""
		cQry01 += " AND C5_EMISSAO >=  "+DTOS(MV_PAR01)
	ENDIF
	IF ALLTRIM(DTOS(MV_PAR02))  <> ""
		cQry01 += " AND C5_EMISSAO <=  "+DTOS(MV_PAR02)
	ENDIF

	cQry01 += " AND C5_LOCAL = '"+_LocalN+"' "
	cQry01 += " AND C5_NUM = C6_NUM "
	cQry01 += " AND C5_CLIENTE + C5_LOJACLI = A1_COD + A1_LOJA "
	cQry01 += " AND C5_CLIENTE + C5_LOJACLI = C6_CLI + C6_LOJA "
	cQry01 += " AND ((C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0) "
	cQry01 += " AND C5_STLOGIS <> '' "
	cQry01 += " GROUP BY C6_NUM, C6_CLI, C6_LOJA, C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, "
	cQry01 += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME, C5_STLOGIS, C5_CONDPAG  "
	cQry01 += " ORDER BY C5_CONDPAG  "

	IF nPesq == 2

		If Select("TTRB") > 0
			TTRB->(dbCloseArea())
		EndIf

		//Adiciona as colunas que serão criadas na temporária
		aAdd(aCampos2, { 'OK', 'C', 2, 0}) //Flag para marcação
		aAdd(aCampos2, { 'STATUS', 'C', 30, 0}) //Pedido
		aAdd(aCampos2, { 'CONDPAG', 'C', 3, 0}) //Condição de Pagamento
		aAdd(aCampos2, { 'CDPDESC', 'C', 15, 0}) //Descrição de Pagamento
		aAdd(aCampos2, { 'PEDIDO', 'C', 6, 0}) //Pedido
		aAdd(aCampos2, { 'CLIENTE', 'C', 6, 0}) //Cliente
		aAdd(aCampos2, { 'LOJACLI', 'C', 2, 0}) //Loja
		aAdd(aCampos2, { 'NOME', 'C', 50, 0}) //Nome
		aAdd(aCampos2, { 'DTBASE', 'D', 10, 0})
		aAdd(aCampos2, { 'ENTREGA', 'C', 1, 0}) //S SIM N NAO
		aAdd(aCampos2, { 'PRAZOENT', 'C', 40, 0})
		aAdd(aCampos2, { 'DATAFATURA',  'D', 10, 0})
		aAdd(aCampos2, { 'FATURAESP',  'C', 1, 0}) //E=Especifica;I=Intervalo
		aAdd(aCampos2, { 'ANTECIPA',  'C', 1, 0})//S=Sim;N=Nao
		aAdd(aCampos2, { 'TIPOBASE',  'C', 1, 0}) //E=Especifica;R=Referenciada
		aAdd(aCampos2, { 'DTREFEST',  'D', 10, 0})
		aAdd(aCampos2, { 'VOLUME1', 'N', 4, 0}) //Volume
		aAdd(aCampos2, { 'ESPECIE', 'C', 15, 0}) //Especie
		aAdd(aCampos2, { 'VALORFAT', 'N', 16, 2}) //Valor
		aAdd(aCampos2, { 'NOTA', 'C', 9, 0}) //Nota Fiscal
		aAdd(aCampos2, { 'SERIE', 'C', 3, 0}) //Série
		aAdd(aCampos2, { 'NUMGNRE', 'C', 12, 0}) //GNRE
		aAdd(aCampos2, { 'ESTADO', 'C', 2, 0}) //Estado
		aAdd(aCampos2, { 'VALORGNRE', 'N', 16, 2}) //VAlor GNRE
		aAdd(aCampos2, { 'RECIBO', 'C', 30, 0}) //Recibo GNRE
		aAdd(aCampos2, { 'LEG', 'C', 1, 0}) //Status leganda

		cArq:=Criatrab(aCampos2,.T.)
		DBUSEAREA(.t.,,carq,"TTRB",.F.,.F.)
		IndRegua("TTRB",Left(cArq,7)+'A',"CONDPAG",,,"Selecionando Registros...")

		dbClearIndex()
		dbSetIndex(Left(cArq,7)+'A' + OrdBagExt())

		dbSelectArea("TTRB")
		dbSetOrder(1)

		If (Select("BD1462") <> 0)
			dbSelectArea("BD1462")
			dbCloseArea()
		EndIf


		PLSQuery(cQry01, 'BD1462')

		//Definindo o tamanho da régua
		DbSelectArea('BD1462')
		Count to nTotal
		ProcRegua(nTotal)
		BD1462->(DbGoTop())

		nTotalWhile := 0

		SE4->(DbSetOrder(1)) //SE4_FILIAL + SE4_CONDPAG

		While  BD1462->(!Eof())

			nTotalWhile ++
			IncProc('Buscando Pedido ' + cValToChar(nTotalWhile) + ' do total de ' + cValToChar(nTotal) + '...')

			aCdCores  := {{ 'BR_VERDE'    	,"PEDIDO EM ESPERA"},;
				{ 'BR_BRANCO' 				,"PEDIDO EM PROCESSO"},;
				{ 'BR_AMARELO'	    		,"PEDIDO FINALIZADO"},;
				{ 'BR_PRETO'	    		,"PEDIDO REJEITADO"},;
				{ 'BR_CANCEL'	        	,"PEDIDO CANCELADO"},;
				{ 'BR_VERMELHO'	        	,"PEDIDO FATURADO"},;
				{ 'BR_VIOLETA'	    	    ,"PEDIDO FINALIZADO / A VISTA"},;
				{ 'BR_LARANJA'	        	,"BLOQ. FAT. COMERCIAL"}}

			IF SE4->(DBSEEK(xFilial("SE4")+BD1462->C5_CONDPAG)) //FILIAL+CONDICAO PAGTO
				cCondDes := SE4->E4_DESCRI
			ELSE
				cCondDes := " "
			ENDIF

			// Rotina para verificar se está bloqueado comercialmente:
			If (Select("B14INC") <> 0)
				dbSelectArea("B14INC")
				dbCloseArea()
			EndIf

			cCons := "SELECT C5_NUM  "
			cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
			cCons += "WHERE D_E_L_E_T_ = '' "
			cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
			cCons += "AND C5_NUM = '"+BD1462->C5_NUM+"'  "
			cCons += "AND C5_BLQCM = '2' "
			cCons += "AND C5_CDBLQC NOT IN ('', '0019')  "
			TCQuery cCons NEW ALIAS "B14INC"
			
			If !B14INC->(EOF())
				_cLegSt := "B"
			Else

				//Validação antecipada para trazer as legeendas da tela
				If Alltrim(BD1462->C5_STLOGIS) == "EM ESPERA"
					_cLegSt := "E"
				ElseIF Alltrim(BD1462->C5_STLOGIS) == "EM PROCESSO"
					_cLegSt := "P"
				ElseIF Alltrim(BD1462->C5_STLOGIS) == "FINALIZADO"
					IF  Alltrim(BD1462->C5_STLOGIS) == "FINALIZADO" .AND. Alltrim(cCondDes) == "A VISTA"
						_cLegSt := "H"
					ELSE
						_cLegSt := "F"
					ENDIF
				ElseIF Alltrim(BD1462->C5_STLOGIS) == "REJEITADO"
					_cLegSt := "R"
				ElseIF Alltrim(BD1462->C5_STLOGIS) == "CANCELADO"
					_cLegSt := "C"
				ElseIF Alltrim(BD1462->C5_STLOGIS) == "FATURADO"
					_cLegSt := "G"
				EndIF

			EndIf

			_cRetStatus := U_B1462Leg(_cLegSt)

			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)

			TTRB->STATUS := _cRetStatus
			TTRB->CONDPAG := BD1462->C5_CONDPAG
			TTRB->CDPDESC := Alltrim(cCondDes)
			TTRB->PEDIDO := BD1462->C5_NUM
			TTRB->CLIENTE := BD1462->C5_CLIENTE
			TTRB->LOJACLI := BD1462->C5_LOJACLI
			TTRB->NOME    := ALLTRIM(BD1462->A1_NOME)
			TTRB->DTBASE := BD1462->C5_DTBASE
			TTRB->ENTREGA := BD1462->C5_FTBASE
			TTRB->PRAZOENT := BD1462->C5_DESCPRA
			TTRB->DATAFATURA := BD1462->C5_DTFAT
			TTRB->FATURAESP := BD1462->C5_DTFATES
			TTRB->ANTECIPA := BD1462->C5_ANTECIP
			TTRB->TIPOBASE := BD1462->C5_TPBASE
			TTRB->DTREFEST := BD1462->C5_DTBEST
			TTRB->VOLUME1 := BD1462->C5_VOLUME1
			TTRB->ESPECIE := BD1462->C5_ESPECI1
			TTRB->VALORFAT := BD1462->C5_VALFAT
			TTRB->NOTA := BD1462->C5_NOTA
			TTRB->SERIE := BD1462->C5_SERIE
			TTRB->NUMGNRE := Space(12)
			TTRB->ESTADO := Space(02)
			TTRB->VALORGNRE := 0
			TTRB->RECIBO := Space(30)
			TTRB->LEG := _cLegSt
			MsunLock()

			BD1462->(DbSkip())

		Enddo

		TTRB->(DbGotop())


	ENDIF

	cQry := cQry01

Return

/*
FUNÇÃO PARA CRIAR O PERGUNTE PARA O BOTÃO REFRESH
DANIEL VICTOR DA ROSA - PERSONALITEC
Data: 05/06/2025
*/
Static Function aPerg62()

	Local aPergs := {}
	Local xPar4  :=	sToD("") //IIF( ALLTRIM(DTOS(MV_PAR01))  <> ""      , MV_PAR01 ,sToD("") )
	Local xPar5  := sToD("") //IIF( ALLTRIM(DTOS(MV_PAR02))  <> ""      , MV_PAR02 ,sToD("") )
	Private xPar6 := "N"
	Private xPar7 := "T"
	//Private lRotUso := GETMV("BD_BUD1462")

	If cEmpAnt <> "01" .and. cFilAnt <> "10"
		MsgStop("Autorizado o uso somente para a Filial 10!")
		Return
	EndIf

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Data de", xPar4,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Ate", xPar5,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {2, "Mercado", xPar6, {"N=BIANCHERIA"}, 090, ".T.", .T.})
	aAdd(aPergs, {2, "Status", xPar7, {"T=Todos os Pedidos","F=Finalizado", "E=Em Espera", "P=Em Processo", "R=Rejeitado", "C=Cancelado", "G=Gerado Nota"}, 090, ".T.", .T.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| BUDQRY(2) },OemToAnsi("Aguarde... Selecionando os pedidos conforme filtro informado!"))
	EndIf

Return

/*
FUNÇÃO PARA VALIDAR SE O CLIENTE TEM TITULO RA NA SE1 COM SALDO, SE SIM, GERA A NOTA FISCAL.
DANIEL VICTOR DA ROSA - PERSONALITEC
Data: 05/06/2025
*/
Static Function cVldTit(cPed33,cCli33,cLoj33,nVal33)

	Local cQuery33 := ""
	Local cAlias33 := GetnextAlias()
	Local lRet33   := .F.
	Local nVal34   := 0

	cQuery33 := " SELECT E1_CLIENTE, E1_LOJA, SUM(E1_SALDO) AS SALDO FROM "+ RETSQLNAME('SE1')
	cQuery33 += " WHERE D_E_L_E_T_ = '' "
	cQuery33 += " AND E1_CLIENTE = '" + cCli33 + "' "
	cQuery33 += " AND E1_LOJA = '" + cLoj33 + "' "
	cQuery33 += " AND E1_FILORIG = '10' "
	cQuery33 += " AND E1_TIPO = 'RA' "
	cQuery33 += " AND E1_SALDO > 0 "
	cQuery33 += " AND E1_STATUS = 'A' "
	cQuery33 += " GROUP BY E1_CLIENTE, E1_LOJA"

	PLSQuery(cQuery33, cAlias33)

	If (cAlias33)->(!Eof())
		nVal34 += (cAlias33)->SALDO
	EndIf

	IF nVal33 < nVal34
		lRet33 := .T.
	ELSE
		lRet33 := .F.
	ENDIF

Return lRet33
