#Include "TOTVS.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"
#include "tbiconn.ch"
/*
Painel Faturamento
PERSONALITEC - ROBERTO
*/
User Function BUD1451()

	Local aArea := FWGetArea()
	Local aPergs   := {}
	Local xPar0 := sToD("")
	Local xPar1 := sToD("")
	Private xPar2 := "N"
	Private xPar3 := "T"
	Private lRotUso := GETMV("BD_BUD1451")

	If cEmpAnt == "01" .and. cFilAnt == "10"
		//Painel para perfumaria
		U_BUD1462()
		Return
	Else
		//Verifico se a rotina esta em uso
		//Adicionando os parametros do ParamBox
		aAdd(aPergs, {1, "Data de", xPar0,  "", ".T.", "", ".T.", 80,  .F.})
		aAdd(aPergs, {1, "Data Ate", xPar1,  "", ".T.", "", ".T.", 80,  .F.})
		aAdd(aPergs, {2, "Mercado", xPar2, {"N=Mercado Nacional", "P=Mercado Projetos", "E=Mercado Exportação", "L=Luxus"}, 090, ".T.", .T.})
		aAdd(aPergs, {2, "Liberação", xPar3, {"T=Todos Pedidos", "F=Aptos a Faturar", "B=Bloqueados para Faturar"}, 090, ".T.", .T.})

		//Se a pergunta for confirma, chama a tela
		If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
			Processa({|| _TE01() },OemToAnsi("Aguarde... Selecionando os pedidos e aplicando as regras comerciais!"))
		EndIf

		//Limpo a rotina para poder ser usada novamente.
		//PutMV("BD_BUD1451", .F.)
	EndIF
	FWRestArea(aArea)
Return

Static Function _TE01()

	Local aCampos:={}
	Local aSize           := {}
	LocaL aInfo           := {}
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

	Local _cNomGrp := ""

	Private cQry51 := ""

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
	Private _LocalN := AllTrim(GetNewPar("BD_B1451AL","")) // NOT IN ('06','13','18')
	//Parametro para control ***********
	Private _LocalP := AllTrim(GetNewPar("BD_B1451P","")) //IN ('05','06','07','08','09','10','11','12','13','14','15','16','17','18')
	Private lNgnreNf := .T.

	//Certifico o parametro para não aparecer a tela da GNRE
	PUTMV("MV_GNRENF", .T.)
	lNgnreNf := .T.
	If MV_PAR03 == "E"
		U_B1451Export()
		Return()
	EndIf

	If Select("TTRB") > 0
		TTRB->(dbCloseArea())
	EndIf

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'STATUS', 'C', 30, 0}) //Pedido
	aAdd(aCampos, { 'PEDIDO', 'C', 6, 0}) //Pedido
	aAdd(aCampos, { 'GRUPO', 'C', 30, 0}) //Cliente
	aAdd(aCampos, { 'CIDADE', 'C', 60, 0}) //Cliente
	aAdd(aCampos, { 'ESTADO', 'C', 2, 0}) //Loja
	aAdd(aCampos, { 'CLIENTE', 'C', 6, 0}) //Cliente
	aAdd(aCampos, { 'LOJACLI', 'C', 2, 0}) //Loja
	aAdd(aCampos, { 'NOME', 'C', 50, 0}) //Nome
	aAdd(aCampos, { 'DTBASE', 'D', 10, 0})
	aAdd(aCampos, { 'ENTREGA', 'C', 1, 0}) //S SIM N NAO
	aAdd(aCampos, { 'PRAZOENT', 'C', 40, 0})
	aAdd(aCampos, { 'DATAFATURA',  'D', 10, 0})
	aAdd(aCampos, { 'FATURAESP',  'C', 1, 0}) //E=Especifica;I=Intervalo
	aAdd(aCampos, { 'ANTECIPA',  'C', 1, 0})//S=Sim;N=Nao
	aAdd(aCampos, { 'TIPOBASE',  'C', 1, 0}) //E=Especifica;R=Referenciada
	aAdd(aCampos, { 'DTREFEST',  'D', 10, 0})
	aAdd(aCampos, { 'VOLUME1', 'N', 4, 0}) //Volume
	aAdd(aCampos, { 'ESPECIE', 'C', 15, 0}) //Especie
	aAdd(aCampos, { 'VALORFAT', 'N', 16, 2}) //Valor
	aAdd(aCampos, { 'NOTA', 'C', 9, 0}) //Nota Fiscal
	aAdd(aCampos, { 'SERIE', 'C', 3, 0}) //Série
	aAdd(aCampos, { 'NUMGNRE', 'C', 12, 0}) //GNRE
	aAdd(aCampos, { 'VALORGNRE', 'N', 16, 2}) //VAlor GNRE
	aAdd(aCampos, { 'RECIBO', 'C', 30, 0}) //Recibo GNRE
	aAdd(aCampos, { 'LEG', 'C', 1, 0}) //Status leganda

	cArq:=Criatrab(aCampos,.T.)
	DBUSEAREA(.t.,,carq,"TTRB",.F.,.F.)
	IndRegua("TTRB",Left(cArq,7)+'A',"PEDIDO",,,"Selecionando Registros...")

	dbClearIndex()
	dbSetIndex(Left(cArq,7)+'A' + OrdBagExt())

	dbSelectArea("TTRB")
	dbSetOrder(1)

	If (Select("BD1451") <> 0)
		dbSelectArea("BD1451")
		dbCloseArea()
	EndIf

	BUDQRY51(1)

	PLSQuery(cQry51, 'BD1451')

	//Definindo o tamanho da régua
	DbSelectArea('BD1451')
	Count to nTotal
	ProcRegua(nTotal)
	BD1451->(DbGoTop())

	dbSelectArea("BD1451")
	dbGoTop()
	nTotalWhile := 0

	While  BD1451->(!Eof())

		nTotalWhile ++
		IncProc('Analisando Pedido ' + cValToChar(nTotalWhile) + ' do total de ' + cValToChar(nTotal) + '...')

		//Validação antecipada para trazer as legeendas da tela
		_cLegSt := ""
		_cLegSt := U_BUD1452(BD1451->C5_NUM, BD1451->C5_CLIENTE,BD1451->C5_LOJACLI,BD1451->C5_TIPO)

		_cRetStatus := U_B1451Status(_cLegSt)

		//Posicionamento no grupo comercial do cliente
		//A1_GRUPO
		ZZ7->(DbSetOrder(1))
		If ZZ7->(MsSeek(xFilial("ZZ7") + BD1451->A1_GRUPO))
			_cNomGrp := ALLTRIM(ZZ7->ZZ7_DESCRI)
		EndIf
		//////////////////////////////////////////////

		If MV_PAR04 == "T"
			DbSelectArea("TTRB")
			RecLock("TTRB",.T.)

			TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
			TTRB->PEDIDO := BD1451->C5_NUM
			TTRB->GRUPO :=  _cNomGrp//ALLTRIM(BD1451->ZZ7_DESCRI)
			TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
			TTRB->ESTADO := BD1451->A1_EST
			TTRB->CLIENTE := BD1451->C5_CLIENTE
			TTRB->LOJACLI := BD1451->C5_LOJACLI
			TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
			TTRB->DTBASE := BD1451->C5_DTBASE
			TTRB->ENTREGA := BD1451->C5_FTBASE
			TTRB->PRAZOENT := BD1451->C5_DESCPRA
			TTRB->DATAFATURA := BD1451->C5_DTFAT
			TTRB->FATURAESP := BD1451->C5_DTFATES
			TTRB->ANTECIPA := BD1451->C5_ANTECIP
			TTRB->TIPOBASE := BD1451->C5_TPBASE
			TTRB->DTREFEST := BD1451->C5_DTBEST
			TTRB->VOLUME1 := BD1451->C5_VOLUME1
			TTRB->ESPECIE := BD1451->C5_ESPECI1
			TTRB->VALORFAT := BD1451->C5_VALFAT
			TTRB->NOTA := BD1451->C5_NOTA
			TTRB->SERIE := BD1451->C5_SERIE
			TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMERO
			TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
			TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
			//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
			TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
			MsunLock()

		ElseIF MV_PAR04 == "F"
			If  _cLegSt == "F"
				DbSelectArea("TTRB")
				RecLock("TTRB",.T.)
				TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
				TTRB->PEDIDO := BD1451->C5_NUM
				TTRB->GRUPO := _cNomGrp//ALLTRIM(BD1451->ZZ7_DESCRI)
				TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
				TTRB->ESTADO := BD1451->A1_EST
				TTRB->CLIENTE := BD1451->C5_CLIENTE
				TTRB->LOJACLI := BD1451->C5_LOJACLI
				TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
				TTRB->DTBASE := BD1451->C5_DTBASE
				TTRB->ENTREGA := BD1451->C5_FTBASE
				TTRB->PRAZOENT := BD1451->C5_DESCPRA
				TTRB->DATAFATURA := BD1451->C5_DTFAT
				TTRB->FATURAESP := BD1451->C5_DTFATES
				TTRB->ANTECIPA := BD1451->C5_ANTECIP
				TTRB->TIPOBASE := BD1451->C5_TPBASE
				TTRB->DTREFEST := BD1451->C5_DTBEST
				TTRB->VOLUME1 := BD1451->C5_VOLUME1
				TTRB->ESPECIE := BD1451->C5_ESPECI1
				TTRB->VALORFAT := BD1451->C5_VALFAT
				TTRB->NOTA := BD1451->C5_NOTA
				TTRB->SERIE := BD1451->C5_SERIE
				TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMERO
				TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
				TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
				//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
				TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
				MsunLock()
			EndIF

		ElseIF MV_PAR04 == "B"
			If  _cLegSt <> "F"
				DbSelectArea("TTRB")
				RecLock("TTRB",.T.)
				TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
				TTRB->PEDIDO := BD1451->C5_NUM
				TTRB->GRUPO :=  _cNomGrp//ALLTRIM(BD1451->ZZ7_DESCRI)
				TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
				TTRB->ESTADO := BD1451->A1_EST
				TTRB->CLIENTE := BD1451->C5_CLIENTE
				TTRB->LOJACLI := BD1451->C5_LOJACLI
				TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
				TTRB->DTBASE := BD1451->C5_DTBASE
				TTRB->ENTREGA := BD1451->C5_FTBASE
				TTRB->PRAZOENT := BD1451->C5_DESCPRA
				TTRB->DATAFATURA := BD1451->C5_DTFAT
				TTRB->FATURAESP := BD1451->C5_DTFATES
				TTRB->ANTECIPA := BD1451->C5_ANTECIP
				TTRB->TIPOBASE := BD1451->C5_TPBASE
				TTRB->DTREFEST := BD1451->C5_DTBEST
				TTRB->VOLUME1 := BD1451->C5_VOLUME1
				TTRB->ESPECIE := BD1451->C5_ESPECI1
				TTRB->VALORFAT := BD1451->C5_VALFAT
				TTRB->NOTA := BD1451->C5_NOTA
				TTRB->SERIE := BD1451->C5_SERIE
				TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMERO
				TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
				TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
				//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
				TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
				MsunLock()
			EndIF
		EndIf
		BD1451->(DbSkip())

	Enddo

	TTRB->(DbGotop())

	aCpoBro	:= {{ "OK"       ,, ""          ,"@!"},;
		{ "STATUS"       ,, "STATUS "   ,"@1!"},;
		{ "PEDIDO"   ,, "PEDIDO "   ,"@1!"},;
		{ "GRUPO"   ,, "GRUPO"   ,"@1!"},;
		{ "CIDADE"   ,, "CIDADE"   ,"@1!"},;
		{ "ESTADO"   ,, "ESTADO"   ,"@1!"},;
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
		{ "VALORGNRE"   ,, "GNRE VALOR"   ,"@E 999,999,999.99"},;
		{ "RECIBO"   ,, "GNRE RECIBO"   ,"@1!"},;
		{ "LEG"   ,, "LEG"   ,"@1!"}}


	aCdCores  := {{ 'PMSEDT1'    	,"BLOQ. FINANCEIRO"},;
		{ 'BR_PRETO' 				,"BLOQ. FAT. PED. RESERVA"},;
		{ 'BR_LARANJA'	    		,"BLOQ. FAT. MESMO DIA"},;
		{ 'BR_VIOLETA'	    		,"BLOQ. FAT. DT. BASE"},;
		{ 'BR_PINK'	        		,"BLOQ. FAT. DT. REFER"},;
		{ 'BR_BRANCO'	        	,"BLOQ. FAT. DT. ESP"},;
		{ 'BR_CINZA'	        	,"BLOQ. FAT.INTER"},;
		{ 'BR_MARROM'	        	,"BLOQ. ENCAIXOTAMENTO"},;
		{ 'BR_VERDE_ESCURO'	       	,"BLOQ. FAT. PRODUTO"},;
		{ 'BR_AZUL_CLARO'	       	,"BLOQ. FAT. PARCIAL"},;
		{ 'BR_CANCEL'	        	,"BLOQ. FAT. COMERCIAL"},;
		{ 'BR_MARRON_OCEAN'	       	,"BLOQ. TP. OPER. TES"},;
		{ 'BR_AMARELO'	        	,"BLOQ. FAT. ANTECIPACAO"},;
		{ 'BR_VERMELHO'	        	,"GERADO NOTA E GNRE"},;
		{ 'BR_VERDE'	    		,"Pedido apto para faturar"}}

	aCores    := {	{"TTRB->LEG = '1' ",	aCdCores[1,1]},;
		{"TTRB->LEG== '2' ",	aCdCores[2,1]},;
		{"TTRB->LEG = '3'",	aCdCores[3,1]},;
		{"TTRB->LEG = '4'",	aCdCores[4,1]},;
		{"TTRB->LEG = '5'",	aCdCores[5,1]},;
		{"TTRB->LEG = '6'",	aCdCores[6,1]},;
		{"TTRB->LEG = '7'",	aCdCores[7,1]},;
		{"TTRB->LEG = '8'",	aCdCores[8,1]},;
		{"TTRB->LEG = '9'",	aCdCores[9,1]},;
		{"TTRB->LEG = 'A'",	aCdCores[10,1]},;
		{"TTRB->LEG = 'B'",	aCdCores[11,1]},;
		{"TTRB->LEG = 'C'",	aCdCores[12,1]},;
		{"TTRB->LEG = 'D'",	aCdCores[13,1]},;
		{"TTRB->LEG = 'E'",	aCdCores[14,1]},;
		{"TTRB->LEG = 'F' ",aCdCores[15,1]}}

	aObjects := {}
	aSize := MsAdvSize()
	AAdd( aObjects, { 100, 100, .T., .T. } ) // Dados da Enchoice
	AAdd( aObjects, { 200, 200, .T., .T. } ) // Dados da getdados
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T.)

	_oDlg := TDialog():New(0,0,800,2000,"PAINEL FATURAMENTO - Mercado Nacional",,,,,,,,,.T.,,,,,)
	_oDlg:lCentered := .T.

	DEFINE FONT oFont1 NAME "Tahoma" SIZE 0, -11 BOLD
	DEFINE FONT oFont2 NAME "Tahoma" SIZE 0, -11 BOLD

	nLarg := 408

	//Group Filtros
	@ 002, 001 GROUP oGroup1 TO 060, 250 PROMPT "Filtro" OF _oDlg COLOR 0, 16777215 PIXEL
	@ 032, 078 BUTTON oButton1 PROMPT "Filtrar" SIZE 048, 014 OF _oDlg ACTION Loc1451() PIXEL
	@ 032, 134 BUTTON oButton2 PROMPT "Exportação" SIZE 048, 014 OF _oDlg  ACTION U_B1451Export() PIXEL
	@ 032, 191 BUTTON oButton3 PROMPT "Resumo FAT" SIZE 048, 014 OF _oDlg ACTION U_B1451Resumo() PIXEL
	@ 014, 017 RADIO oRadMenu1 VAR nRadMenu1 ITEMS "PEDIDO","CLIENTE","GRUPO" SIZE 051, 036 OF _oDlg COLOR 0, 16777215 PIXEL
	@ 015, 078 MSGET oGet1 VAR cGet1 SIZE 161, 014 OF _oDlg COLORS 0, 16777215 PIXEL

	//Group funções  e  gerar nota
	@ 002, 260 GROUP oGroup2 TO 060, 347 PROMPT "Funções" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 018, 268 BUTTON oButton4 PROMPT "Outras Ações" SIZE 070, 014 OF _oDlg   ACTION u_TSTopUp() PIXEL
	//@ 035, 268 BUTTON oButton5 PROMPT "GERAR NOTA" SIZE 070, 014 OF _oDlg ACTION Processa({|| u_B1452NOTA() },OemToAnsi("Aguarde...Iniciando FATURAMENTO do(s) pedido(s) selecionado(s)...")) PIXEL

	@ 010, 268 BUTTON oButton4 PROMPT "OUTRAS AÇÕES" SIZE 070, 014 OF _oDlg   ACTION u_TSTopUp() PIXEL
	@ 026, 268 BUTTON oButton5 PROMPT "GERAR NOTA" SIZE 070, 014 OF _oDlg ACTION Processa({|| u_B1452NOTA() },OemToAnsi("Aguarde...Iniciando FATURAMENTO do(s) pedido(s) selecionado(s)...")) PIXEL
	@ 042, 268 BUTTON oButton6 PROMPT "ATUALIZAR" SIZE 070, 014 OF _oDlg ACTION Processa({|| aPergs51() },OemToAnsi("Aguarde...Iniciando atualização do Painel..."))  PIXEL

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
	oMark:bAval 				:= {|| B1451Mark()}
	oMark:oBrowse:bAllMark 		:= {|| B1451All()}
	//oMark:oBrowse:bRClicked := { |o,Nx,Ny| U_TSTopUp( Nx, Ny, oMark ) }

	//@ 585, 260 GROUP oGroup4 TO 060, 347 PROMPT "Legendas" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 585, 260 GROUP oGroup4 TO 060, 347 PROMPT "Legendas" OF _oDlg COLOR 0, 16777215 PIXEL
	/*
	nLinBmp := 566//580//370
	TBtnBmp2():New(c(nLinBmp)   ,c(020),025,020,aCdCores[1,1],,,,,_oDlg,aCdCores[1,2],,,)
	TBtnBmp2():New(c(nLinBmp+20),c(020),025,020,aCdCores[2,1],,,,,_oDlg,aCdCores[2,2],,,)
	TBtnBmp2():New(c(nLinBmp+40),c(020),025,020,aCdCores[3,1],,,,,_oDlg,aCdCores[3,2],,,)
	TBtnBmp2():New(c(nLinBmp+60),c(020),025,020,aCdCores[4,1],,,,,_oDlg,aCdCores[4,2],,,)
	TBtnBmp2():New(c(nLinBmp+80),c(020),025,020,aCdCores[5,1],,,,,_oDlg,aCdCores[5,2],,,)

	nLinBmp := 566//580//370
	TBtnBmp2():New(c(nLinBmp)   ,c(220),025,020,aCdCores[6,1],,,,,_oDlg,aCdCores[6,2],,,)
	TBtnBmp2():New(c(nLinBmp+20),c(220),025,020,aCdCores[7,1],,,,,_oDlg,aCdCores[7,2],,,)
	TBtnBmp2():New(c(nLinBmp+40),c(220),025,020,aCdCores[8,1],,,,,_oDlg,aCdCores[8,2],,,)
	TBtnBmp2():New(c(nLinBmp+60),c(220),025,020,aCdCores[9,1],,,,,_oDlg,aCdCores[9,2],,,)
	TBtnBmp2():New(c(nLinBmp+80),c(220),025,020,aCdCores[10,1],,,,,_oDlg,aCdCores[10,2],,,)

	nLinBmp := 566//580//370
	TBtnBmp2():New(c(nLinBmp)   ,c(420),025,020,aCdCores[11,1],,,,,_oDlg,aCdCores[11,2],,,)
	TBtnBmp2():New(c(nLinBmp+20),c(420),025,020,aCdCores[12,1],,,,,_oDlg,aCdCores[12,2],,,)
	TBtnBmp2():New(c(nLinBmp+40),c(420),025,020,aCdCores[13,1],,,,,_oDlg,aCdCores[13,2],,,)
	TBtnBmp2():New(c(nLinBmp+60),c(420),025,020,aCdCores[14,1],,,,,_oDlg,aCdCores[14,2],,,)
	TBtnBmp2():New(c(nLinBmp+80),c(420),025,020,aCdCores[15,1],,,,,_oDlg,aCdCores[15,2],,,)
	*/
	/*
	nLinTxt := 285//292//186
	TSay():New(c(nLinTxt)   ,c(025),{|| "BLOQ. FINANCEIRO"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+10),c(025),{|| "BLOQ. FAT. PED. RESERVA"	}		,_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+21),c(025),{|| "BLOQ. FAT. MESMO DIA"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+31),c(025),{|| "BLOQ. FAT. DT. BASE"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+41),c(025),{|| "BLOQ. FAT. DT. REFER"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )

	nLinTxt := 285
	TSay():New(c(nLinTxt)   ,c(125),{|| "BLOQ. FAT. DT. ESP"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+10),c(125),{|| "BLOQ. FAT.INTER"	}		,_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+21),c(125),{|| "BLOQ. ENCAIXOTAMENTO"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+31),c(125),{|| "BLOQ. FAT. PRODUTO"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+41),c(125),{|| "BLOQ. FAT. PARCIAL"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )

	nLinTxt := 285
	TSay():New(c(nLinTxt)   ,c(225),{|| "BLOQ. FAT. COMERCIAL"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+10),c(225),{|| "BLOQ. TP. OPER. TES"	}		,_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+21),c(225),{|| "BLOQ. FAT. ANTECIPACAO"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+31),c(225),{|| "GERADO NOTA E GNRE"					},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	TSay():New(c(nLinTxt+41),c(225),{|| "APTO PARA FATURAR"		 	},_oDlg,,,.F.,,,.T.,,,100,10,,,,, )
	*/
	//MENSAGENS DO PEDIDO DE VENDAS
	//nLinTxt := 285
	//TSay():New(c(nLinTxt)   ,c(325),{|| "FAVOR FATURAR ESSE PEDIDO DIA 10/08/24.   "		 	},_oDlg,,,.F.,,,.T.,,,300,10,,,,, )

	//oGroup6:= TGroup():New(285,325,295,295,'Objeto TGroup 1',_oDlg,,,.T.)
	//@ 260, 424 GROUP oGroup1 TO 306, 575 PROMPT "oGroup1" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 320, 429 GROUP oGroup1 TO 366, 581 PROMPT "MENSAGENS DO PEDIDO" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 337, 264 GROUP oGroup1 TO 406, 541 PROMPT "MENSAGENS DO PEDIDO" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 337, 330 GROUP oGroup1 TO 400, 607 PROMPT  "MENSAGENS DO PEDIDO" OF _oDlg COLOR 0, 16777215 PIXEL
	//@ 338, 359 GROUP oGroup1 TO 394, 637 PROMPT  "Informações do Pedido"  OF _oDlg COLOR 0, 16777215 PIXEL
	@ 338, 005 GROUP oGroup1 TO 394, 394 PROMPT  "Informações do Pedido"  OF _oDlg COLOR 0, 16777215 PIXEL

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

Static Function B1451Mark()
	dbSelectArea("TTRB")

	RecLock('TTRB',.F.)

	If Empty(TTRB->OK) .and. TTRB->LEG == "F"
		TTRB->OK:= cMarca
	ELSEIF !Empty(TTRB->OK) .and. TTRB->LEG == "F"
		TTRB->OK:= "  "
	Else
		TTRB->OK:= "  "
		MsgAlert("ATENÇÃO - Pedido com bloqueio para faturamento!!!")
	EndIf
	TTRB->(MsUnlock())

	_oDlg:Refresh()

Return

Static Function B1451All()

	Local nRecno := TTRB->(Recno())
	dbSelectArea("TTRB")
	TTRB->(dbGoTop())
	While TTRB->(!Eof())
		B1451Mark()
		TTRB->(dbSkip())
	EndDo

	TTRB->(dbGoTo(nRecno))
	_oDlg:Refresh()

Return .T.

Static Function B1451AtuMsg()

	If	Select("BD1451A")<>0
		BD1451A->(DbCloseArea())
	EndIf

	BeginSql alias 'BD1451A'
		%noparser%

		SELECT
			DISTINCT C6_NUM,
			A1_COD,
			A1_LOJA,
			A1_EXCLUSI,
			SUM(C6_VALOR) AS VALOR
		FROM
			%table:SC6% C6 (NOLOCK)
		INNER JOIN %table:SC5% C5
		ON C5.C5_NUM = C6.C6_NUM
			AND C5.%NotDel%
		INNER JOIN %table:SA1% A1
		ON A1.A1_COD = C5.C5_CLIENTE
			AND A1.A1_LOJA = C5_LOJACLI
			AND A1.%NotDel%
		WHERE
			C6.%NotDel%
			AND C6_NUM = %exp:TTRB->PEDIDO%
		GROUP BY
			C6_NUM,
			C6_CLI,
			A1_COD,
			A1_LOJA,
			A1_EXCLUSI
	EndSql
	nVlrPed:= BD1451A->VALOR
	cParceir:=""

	IF BD1451A->A1_EXCLUSI == "S"
		cParceir:= "CLIENTE - EXCLUSIVO"
	ENDIF

	IF (SELECT("TITATRASO") <> 0)
		TITATRASO->(DBCLOSEAREA())
	ENDIF

	BeginSql Alias "TITATRASO"
		%noParser%

		Column VALOR AS NUMERIC (14, 2)
		SELECT
			E1_CLIENTE,
			E1_LOJA,
			SUM(E1_VALOR) AS VALOR
		FROM
			%Table:SE1% E1 (NOLOCK)
		WHERE
			E1.%NotDel%
			AND E1_CLIENTE = %EXP:TTRB->CLIENTE%
			AND E1_LOJA = %EXP:TTRB->CLILOJA%
			AND (
				E1_BAIXA = ' '
				OR E1_SALDO <> 0
			)
			AND E1_TIPO NOT IN ('NCC', 'RA')
			AND E1_VENCREA < %EXP:DTOS(DDATABASE)%
		GROUP BY
			E1_CLIENTE,
			E1_LOJA
	EndSql

	IF TITATRASO->VALOR > 0
		nVlrAtr:= TITATRASO->VALOR
	ENDIF

	TITATRASO->(DbCloseArea())

	_oDlg:Refresh()

Return

Static Function Loc1451()

	Local cPesq:=""
	dbSelectArea("TTRB")
	IF nRadMenu1 == 1
		B1451Ordem()
		cPesq	:= cGet1
	ElseIf nRadMenu1 == 2
		B1451Ordem()
		cPesq:= cGet1
	ElseIf nRadMenu1 == 3
		B1451Ordem()
		cPesq:= cGet1
	EndIf

	TTRB->(dbSeek(Alltrim(cPesq),.T.))

	oMark:oBrowse:Refresh()
Return()

Static Function B1451Ordem()

	// Verifica a ordem informada pelo usuario e cria o indice novamente
	////////////////////////////////////////////////////////////////////////////////////////
	dbSelectArea("TTRB")
	If nRadMenu1 == 1
		IndRegua("TTRB",Left(cArq,7)+'A',"PEDIDO",,,"Selecionando Registros...")//Index on TTRB->PEDIDO to &TTRB
	ElseIf nRadMenu1 == 2
		IndRegua("TTRB",Left(cArq,7)+'A',"CLIENTE",,,"Selecionando Registros...")//Index on TTRB->CLIENTE to &TTRB
	ElseIf nRadMenu1 == 3
		IndRegua("TTRB",Left(cArq,7)+'A',"GRUPO",,,"Selecionando Registros...")//Index on TTRB->CLIENTE to &TTRB
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
	U_TSTopUp()
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

//User Function TSTopUp(030, 030, _oDlg)

User Function TSTopUp(nLeft, nTop, _oDlg)

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
	MenuItem "Complemento Pedido" Action B1451Compl(1)  RESOURCE 'RECALC'
	MenuItem '_____________' DISABLED
	MenuItem "Visualizar" Action MATA410() RESOURCE 'BMPINCLUIR'
	MenuItem "Danfe" Action SPEDNFE() RESOURCE 'EXCLUIR'
	MenuItem '_____________' DISABLED
	//MenuItem "Em Desenvolvimento" Action B1451Desenv() RESOURCE "BTCALEND"
	//MenuItem "Em Desenvolvimento" Action B1451Desenv() RESOURCE "PESQUISA"
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
User Function B1452NOTA()
	Private cSerie := "4  "
	Private aPvlNfs:= {}
	Private lNgnreNf := .T.

	//Certifico o parametro para não aparecer a tela da GNRE
	PUTMV("MV_GNRENF", .T.)
	lNgnreNf := .T.
	TTRB->(dbGoTop())
	While TTRB->(! Eof())
		If !Empty(TTRB->OK) //campos selecionados
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
						TTRB->LEG    := "E"
					EndIf
					MSUNLOCK()

					SC5->(DbSetOrder(1))
					If SC5->(MsSeek(xFilial("SC5") + TTRB->PEDIDO))
						RecLock("SC5",.F.)
						SC5->C5_PAINEL := "S"
						MSUNLOCK()
					EndIf
					PUTMV("MV_GNRENF", .T.)
					lNgnreNf := .T.
					aPvlNfs:= {}
				EndIf

				MsUnlockAll()

			EndIf

		EndIf

		dbSelectArea("TTRB")
		TTRB->(dbSkip())
	EndDo

	//TTRB->(dbCloseArea())

	MsgStop("NOTAS FISCAIS EMITIDAS!!!")
	oMark:oBrowse:Refresh()
	//oDlg:End()

Return

Static Function B1451Compl(nTipo)

	SetPrvt("CPERG,AREGISTROS,I,J,cPedComp")
	SetPrvt("CTRANSP,CPGTO,CTPFRETE,CREDESPACHO,NFRETE,NSEGURO,CEPVOL,dDtBase,oText1,oText2")
	SetPrvt("NDESPESA,CTEXT1,CTEXT2,CTEXT3,CTEXT4,cTxtBuff1,cTxtBuff2,NVOLUME1,CESPECI1,NPESOL")
	SetPrvt("NPBRUTO,CMENSA1,CMENSA2,CMENSA3,CMENSA4,CMENSA5")
	SetPrvt("CMENSA6,NFRETEFOB,NPERCOMI,ACRA,NTXMOEDA,_cPedComp")

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

		_cPedComp := SC5->C5_CLIENTE

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

		NTXMOEDA := SC5->C5_BUDMOED

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
			@ 030,160 Get NTXMOEDA PICT "@E 99.999999" SIZE 50,10
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
		@ 185,200 BUTTON "Confirma" Size 40,10 ACTION (B1451C5(nTipo),B1451Compl(1))
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

Static FUNCTION B1451C5(Tipo)

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
				SC5->C5_PERFRE  := nFRETEFOB
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

				//Chamado Portal Budd - 99567
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


					If _cPedComp = 'EX9112' //CARA CALLA
						//If nFrete > 0
						SC5->C5_FRETE   := nFrete
						//EndIF
					Else //trazer o frete convertido
						PutMV("BD_FRE1451", nFrete)
						SC5->C5_FRETE   := nFrete * NTXMOEDA
					EndIF

					SC5->C5_BUDMOED := NTXMOEDA
					SC5->C5_PERFRE  := nFRETEFOB
					SC5->C5_PESOL   := nPesol
					SC5->C5_PBRUTO  := nPBruto
					SC5->C5_VOLUME1 := nVolume1
					SC5->C5_ESPECI1 := cEspeci1
					/*If nFreteFOB > 0
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
					EndIf */
				Else //não sendo o ultimo pedido
					//Alteração em 10-02-2025
					//Conforme solicitado via chamado do portal - 99567

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

User Function B1451Resumo()

	MsgStop("ROTINA EM DESENVOLVIMENTO E ANALISE")
	/*
	Local aPergs   := {}
	Local xPar0 := sToD("")
	Local xPar1 := sToD("")

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Faturamento de", xPar0,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Faturamento Ate", xPar1,  "", ".T.", "", ".T.", 80,  .F.})

	If ParamBox(aPergs, 'Informe os parâmetros para executar o filtro', /*aRet*///, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
	//Processa({|| U_B1451TelaTotal(MV_PAR01, MV_PAR02) },OemToAnsi("Calculando os Totalizadores... "))
	//EndIf

Return
/*
User Function B1451TelaTotal(dDataDe,dDataAte)

Local oBitmap1
Local oFont1 := TFont():New("MS Sans Serif",,031,,.T.,,,,,.F.,.F.)
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6

Static oDlg

///VALOR MERCADO INTERNO

///VALOR MERCADO EXTERNO

///VALOR MERCADO PROJETO

//TOTAL DE NOTAS

//TOTAL ROMANEIO

//TOTAL GERAL FATURAMENTO


  DEFINE MSDIALOG oDlg TITLE "TOTALIZADORES"  FROM -002, 000  TO 495, 935 COLORS 0, 16777215 PIXEL

    @ 000, 000 BITMAP oBitmap1 SIZE 467, 245 OF oDlg FILENAME "D:\Personalitec\BUDD\Gaia\Painel logistica\TOTALIZADOR.png" NOBORDER PIXEL

    @ 092, 045 SAY oSay1 PROMPT "VLMI" SIZE 082, 021 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL
    @ 095, 194 SAY oSay2 PROMPT "VLME" SIZE 095, 019 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL
    @ 093, 366 SAY oSay3 PROMPT "VLPR" SIZE 093, 020 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL

    @ 154, 157 SAY oSay4 PROMPT "TOTNOTA" SIZE 110, 020 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL
    @ 183, 157 SAY oSay5 PROMPT "TOTNFROM" SIZE 117, 018 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL
    @ 213, 188 SAY oSay6 PROMPT "TGVLNOTA" SIZE 138, 019 OF oDlg FONT oFont1 COLORS 255, 16777215 PIXEL

  ACTIVATE MSDIALOG oDlg CENTERED

Return
*/

User Function B1451Export()
	Local oButton1
	Local oButton2
	Local oFont1 := TFont():New("MS Sans Serif",,022,,.T.,,,,,.F.,.F.)

	Static oDlg

	STATIC oMSNewGe1

	DEFINE MSDIALOG oDlg TITLE "PEDIDO(S) EXPORTAÇÃO" FROM 000, 000  TO 370, 950 COLORS 0, 16777215 PIXEL

	fMSNewGe1()

	@ 162, 383 BUTTON oButton1 PROMPT "Gerar Nota" SIZE 086, 018 OF oDlg FONT oFont1 ACTION Processa({|| B1451NFEXP() },OemToAnsi("Aguarde... Selecionando os pedidos para gerar a nota fiscal!"))  PIXEL
	@ 162, 290 BUTTON oButton2 PROMPT "Complemento" SIZE 086, 018 OF oDlg FONT oFont1 ACTION B1451Compl(2) PIXEL

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
	aAdd(aHeaderEx, {'PEDIDO'	        ,'PEDIDO' , '@!'          , 6 , 0 ,"u_B1451VEXP()" , , 'C' ,'SC5EXP' , , , }) //1
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	oMSNewGe1 := MsNewGetDados():New( 000, 000, 158, 475, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

User Function B1451VEXP()

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

Static function B1451NFEXP()

	Local _i := 0

	Private cSerie := "4  "
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
		_cPExp := oMSNewGe1:ACOLS[_i][1]
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
			SC5->(DbSetOrder(1))
			If SC5->(MsSeek(xFilial("SC5") + oMSNewGe1:ACOLS[Len(oMSNewGe1:ACOLS)][1])) //oMSNewGe1:ACOLS[_i][1]
				RecLock("SC5",.F.)
				SC5->C5_PAINEL := "S" //
				If !SC5->C5_CLIENTE = 'EX9112'
					SC5->C5_FRETE   := GetMV("BD_FRE1451") //Pego o valor do frete que foi gravado no MV
					PutMV("BD_FRE1451", 0) //Zera o valor do frete
				EndIF
				MSUNLOCK()
			EndIf
			aPvlNfs:= {}
		EndIf

		MsUnlockAll()

	EndIf

Return


User Function B1451Status(_cStRet)

	Local _cStatusAtual := ""
	Local _cNomGrp := ""

	If _cStRet == '1'
		_cStatusAtual := "BLQ. FINANCEIRO"
	ElseIf _cStRet == '2'
		_cStatusAtual := "BLOQ. PED. RESERVA"
	ElseIf _cStRet == '3'
		_cStatusAtual := "BLOQ. FAT MESMO DIA"
	ElseIf _cStRet == '4'
		_cStatusAtual := "BLOQ. FAT. DT. BASE"
	ElseIf _cStRet == '5'
		_cStatusAtual := "BLOQ. FAT. DT. REFER"
	ElseIf _cStRet == '6'
		_cStatusAtual := "BLOQ. FAT. DT. ESP"
	ElseIf _cStRet == '7'
		_cStatusAtual := "BLOQ. FAT.INTER"
	ElseIf _cStRet == '8'
		_cStatusAtual := "BLOQ. ENCAIXOTAMENTO"
	ElseIf _cStRet == '9'
		_cStatusAtual := "BLOQ. FAT. PRODUTO"
	ElseIf _cStRet == 'A'
		_cStatusAtual := "BLOQ. FAT. PARCIAL"
	ElseIf _cStRet == 'B'
		_cStatusAtual := "BLOQ. FAT. COMERCIAL"
	ElseIf _cStRet == 'C'
		_cStatusAtual := "BLOQ. TP. OPER. TES"
	ElseIf _cStRet == 'D'
		_cStatusAtual := "BLOQ. FAT. ANTECIPACAO"
	ElseIf _cStRet == 'E'
		_cStatusAtual := "GERADO NOTA E GNRE"
	ElseIf _cStRet == 'F'
		_cStatusAtual := "Pedido apto para faturar"
	Else
		_cStatusAtual := "COM BLOQUEIO"
	EndIF

Return _cStatusAtual

Static Function BUDQRY51(nOpc)

	Local cQryDados := ""
	Local aCampo51  := {}
	Local _cNomGrp := ""

	//Certifico o parametro para não aparecer a tela da GNRE
	PUTMV("MV_GNRENF", .T.)
	lNgnreNf := .T.
	If MV_PAR03 == "E"
		U_B1451Export()
		Return()
	EndIf

	If MV_PAR03 == "N" .or. MV_PAR03 == "L" // Mercado nacional ou LUXUS

		//cQryDados := " SELECT C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, A1_GRUPO, ZZ7_DESCRI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, A1_EST, A1_MUN, "
		cQryDados := " SELECT C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, A1_GRUPO, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, A1_EST, A1_MUN, "
		cQryDados += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME  "
		cQryDados += " FROM SC5010 C5, SC6010 C6, ZCA010 ZCA, SA1010 A1 "
		cQryDados += " WHERE C6.D_E_L_E_T_ = '' "
		cQryDados += " AND C5.D_E_L_E_T_ = '' "
		cQryDados += " AND ZCA.D_E_L_E_T_ = ''  "
		//cQryDados += " AND ZZ7.D_E_L_E_T_ = ''  " Retirado pelas repetições deletadas
		cQryDados += " AND C6_FILIAL = '"+xFilial("SC6")+"'  "
		cQryDados += " AND C5_FILIAL = '"+xFilial("SC5")+"'  "
		cQryDados += " AND ZCA_FILIAL = '"+xFilial("ZCA")+"'  "
		//cQryDados += " AND ZZ7_FILIAL = '  '  "
		If MV_PAR03 == "L"
			cQryDados += " AND C5_LOCAL = '06' "
		Else
			cQryDados += " AND C5_LOCAL NOT IN "+_LocalN+" "
		EndIF
		cQryDados += " AND C5_NUM = C6_NUM "

		IF ALLTRIM(DTOS(MV_PAR01))  <> ""
			cQryDados += " AND C5_EMISSAO >=  "+DTOS(MV_PAR01)
		ENDIF
		IF ALLTRIM(DTOS(MV_PAR02))  <> ""
			cQryDados += " AND C5_EMISSAO <=  "+DTOS(MV_PAR02)
		ENDIF

		cQryDados += " AND C5_NUM = ZCA_PEDIDO "
		cQryDados += " AND C6_NUM = ZCA_PEDIDO "
		cQryDados += " AND C5_CLIENTE + C5_LOJACLI = A1_COD + A1_LOJA "
		cQryDados += " AND C5_CLIENTE + C5_LOJACLI = C6_CLI + C6_LOJA "
		cQryDados += " AND ((C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0) "
		cQryDados += " AND ZCA_STENCA = 'RECEBIDO COLETOR' "
		//cQryDados += " AND A1_GRUPO = ZZ7_CODIGO "
		cQryDados += " AND LEFT(C5_CLIENTE,2) <> 'EX' "
		//cQryDados += " AND C5_NUM = 'H14423' "//para testes de pedido
		cQryDados += " GROUP BY A1_GRUPO, C6_NUM, C6_CLI, C6_LOJA, C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, "
		cQryDados += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME,  A1_EST, A1_MUN  "
		cQryDados += " ORDER BY 6 "

	ElseIF MV_PAR03 == "P" // Mercado Projetos

		MsgStop("Tipo de mercado em desenvolvimento!!!")
		Return()
		/*
		cQryDados := " SELECT  TOP 15 C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, A1_GRUPO, ZZ7_DESCRI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, "
		cQryDados += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME  "
		cQryDados += " FROM SC5010 C5, SC6010 C6, ZCA010 ZCA, SA1010 A1, ZZ7010 ZZ7 "
		cQryDados += " WHERE C6.D_E_L_E_T_ = '' "
		cQryDados += " AND C5.D_E_L_E_T_ = '' "
		cQryDados += " AND ZCA.D_E_L_E_T_ = ''  "
		cQryDados += " AND C6_FILIAL = '"+xFilial("SC6")+"'  "
		cQryDados += " AND C5_FILIAL = '"+xFilial("SC5")+"'  "
		cQryDados += " AND ZCA_FILIAL = '"+xFilial("ZCA")+"'  "
		cQryDados += " AND ZZ7_FILIAL = '  '  "
		cQryDados += " AND C5_LOCAL IN "+_LocalP+" "
		cQryDados += " AND C5_NUM = C6_NUM "
		cQryDados += " AND C5_NUM = ZCA_PEDIDO "
		cQryDados += " AND C6_NUM = ZCA_PEDIDO "
		cQryDados += " AND C5_CLIENTE + C5_LOJACLI = A1_COD + A1_LOJA "
		cQryDados += " AND C5_CLIENTE + C5_LOJACLI = C6_CLI + C6_LOJA "
		cQryDados += " AND ((C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0) "
		cQryDados += " AND ZCA_STENCA = 'RECEBIDO MAQUINA'
		//cQryDados += " AND ZCA_STATUS = 'APTO A FATURAR'
		cQryDados += " AND A1_GRUPO = ZZ7_CODIGO "
		cQryDados += " AND LEFT(C5_CLIENTE,2) <> 'EX' "

		//cQryDados += " AND ZCA_PEDIDO in ( 'NEF497', 'NED139', 'NEH212','NEA658', 'NEA661', 'NEA659') "

		cQryDados += " GROUP BY A1_GRUPO, ZZ7_DESCRI, C6_NUM, C6_CLI, C6_LOJA, C5_NUM, C5_CREDFAT, C5_CREDITO, C5_CLIENTE, C5_LOJACLI, C5_DTBASE, C5_FTBASE, C5_DESCPRA, C5_DTFAT, C5_DTFATES, C5_ANTECIP,  C5_TPBASE, C5_DTBEST, C5_VOLUME1, C5_ESPECI1, "
		cQryDados += " C5_VALFAT, C5_NOTA, C5_SERIE, C5_TIPO, A1_NOME  "
		cQryDados += " ORDER BY 6 "
		*/

	EndIf

	IF nOpc == 2

		If Select("TTRB") > 0
			TTRB->(dbCloseArea())
		EndIf

		//Adiciona as colunas que serão criadas na temporária
		aAdd(aCampo51, { 'OK', 'C', 2, 0}) //Flag para marcação
		aAdd(aCampo51, { 'STATUS', 'C', 30, 0}) //Pedido
		aAdd(aCampo51, { 'PEDIDO', 'C', 6, 0}) //Pedido
		aAdd(aCampo51, { 'GRUPO', 'C', 30, 0}) //Cliente
		aAdd(aCampo51, { 'CIDADE', 'C', 60, 0}) //Cliente
		aAdd(aCampo51, { 'ESTADO', 'C', 2, 0}) //Loja
		aAdd(aCampo51, { 'CLIENTE', 'C', 6, 0}) //Cliente
		aAdd(aCampo51, { 'LOJACLI', 'C', 2, 0}) //Loja
		aAdd(aCampo51, { 'NOME', 'C', 50, 0}) //Nome
		aAdd(aCampo51, { 'DTBASE', 'D', 10, 0})
		aAdd(aCampo51, { 'ENTREGA', 'C', 1, 0}) //S SIM N NAO
		aAdd(aCampo51, { 'PRAZOENT', 'C', 40, 0})
		aAdd(aCampo51, { 'DATAFATURA',  'D', 10, 0})
		aAdd(aCampo51, { 'FATURAESP',  'C', 1, 0}) //E=Especifica;I=Intervalo
		aAdd(aCampo51, { 'ANTECIPA',  'C', 1, 0})//S=Sim;N=Nao
		aAdd(aCampo51, { 'TIPOBASE',  'C', 1, 0}) //E=Especifica;R=Referenciada
		aAdd(aCampo51, { 'DTREFEST',  'D', 10, 0})
		aAdd(aCampo51, { 'VOLUME1', 'N', 4, 0}) //Volume
		aAdd(aCampo51, { 'ESPECIE', 'C', 15, 0}) //Especie
		aAdd(aCampo51, { 'VALORFAT', 'N', 16, 2}) //Valor
		aAdd(aCampo51, { 'NOTA', 'C', 9, 0}) //Nota Fiscal
		aAdd(aCampo51, { 'SERIE', 'C', 3, 0}) //Série
		aAdd(aCampo51, { 'NUMGNRE', 'C', 12, 0}) //GNRE
		aAdd(aCampo51, { 'VALORGNRE', 'N', 16, 2}) //VAlor GNRE
		aAdd(aCampo51, { 'RECIBO', 'C', 30, 0}) //Recibo GNRE
		aAdd(aCampo51, { 'LEG', 'C', 1, 0}) //Status leganda

		cArq:=Criatrab(aCampo51,.T.)
		DBUSEAREA(.t.,,carq,"TTRB",.F.,.F.)
		IndRegua("TTRB",Left(cArq,7)+'A',"PEDIDO",,,"Selecionando Registros...")

		dbClearIndex()
		dbSetIndex(Left(cArq,7)+'A' + OrdBagExt())

		dbSelectArea("TTRB")
		dbSetOrder(1)

		If (Select("BD1451") <> 0)
			dbSelectArea("BD1451")
			dbCloseArea()
		EndIf

		PLSQuery(cQryDados, 'BD1451')

		//Definindo o tamanho da régua
		DbSelectArea('BD1451')
		Count to nTotal
		ProcRegua(nTotal)
		BD1451->(DbGoTop())

		nTotalWhile := 0

		While  BD1451->(!Eof())

			nTotalWhile ++
			IncProc('Analisando Pedido ' + cValToChar(nTotalWhile) + ' do total de ' + cValToChar(nTotal) + '...')

			//Validação antecipada para trazer as legeendas da tela
			_cLegSt := ""
			_cLegSt := U_BUD1452(BD1451->C5_NUM, BD1451->C5_CLIENTE,BD1451->C5_LOJACLI,BD1451->C5_TIPO)

			_cRetStatus := U_B1451Status(_cLegSt)

			//Posicionamento no grupo comercial do cliente
			//A1_GRUPO
			ZZ7->(DbSetOrder(1))
			If ZZ7->(MsSeek(xFilial("ZZ7") + BD1451->A1_GRUPO))
				_cNomGrp := ALLTRIM(ZZ7->ZZ7_DESCRI)
			EndIf
			//////////////////////////////////////////////
			If MV_PAR04 == "T"
				DbSelectArea("TTRB")
				RecLock("TTRB",.T.)

				TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
				TTRB->PEDIDO := BD1451->C5_NUM
				TTRB->GRUPO :=  _cNomGrp //ALLTRIM(BD1451->ZZ7_DESCRI)
				TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
				TTRB->ESTADO := BD1451->A1_EST
				TTRB->CLIENTE := BD1451->C5_CLIENTE
				TTRB->LOJACLI := BD1451->C5_LOJACLI
				TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
				TTRB->DTBASE := BD1451->C5_DTBASE
				TTRB->ENTREGA := BD1451->C5_FTBASE
				TTRB->PRAZOENT := BD1451->C5_DESCPRA
				TTRB->DATAFATURA := BD1451->C5_DTFAT
				TTRB->FATURAESP := BD1451->C5_DTFATES
				TTRB->ANTECIPA := BD1451->C5_ANTECIP
				TTRB->TIPOBASE := BD1451->C5_TPBASE
				TTRB->DTREFEST := BD1451->C5_DTBEST
				TTRB->VOLUME1 := BD1451->C5_VOLUME1
				TTRB->ESPECIE := BD1451->C5_ESPECI1
				TTRB->VALORFAT := BD1451->C5_VALFAT
				TTRB->NOTA := BD1451->C5_NOTA
				TTRB->SERIE := BD1451->C5_SERIE
				TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMER
				TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
				TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
				//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
				TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
				MsunLock()

			ElseIF MV_PAR04 == "F"
				If  _cLegSt == "F"
					DbSelectArea("TTRB")
					RecLock("TTRB",.T.)
					TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
					TTRB->PEDIDO := BD1451->C5_NUM
					TTRB->GRUPO :=  _cNomGrp//ALLTRIM(BD1451->ZZ7_DESCRI)
					TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
					TTRB->ESTADO := BD1451->A1_EST
					TTRB->CLIENTE := BD1451->C5_CLIENTE
					TTRB->LOJACLI := BD1451->C5_LOJACLI
					TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
					TTRB->DTBASE := BD1451->C5_DTBASE
					TTRB->ENTREGA := BD1451->C5_FTBASE
					TTRB->PRAZOENT := BD1451->C5_DESCPRA
					TTRB->DATAFATURA := BD1451->C5_DTFAT
					TTRB->FATURAESP := BD1451->C5_DTFATES
					TTRB->ANTECIPA := BD1451->C5_ANTECIP
					TTRB->TIPOBASE := BD1451->C5_TPBASE
					TTRB->DTREFEST := BD1451->C5_DTBEST
					TTRB->VOLUME1 := BD1451->C5_VOLUME1
					TTRB->ESPECIE := BD1451->C5_ESPECI1
					TTRB->VALORFAT := BD1451->C5_VALFAT
					TTRB->NOTA := BD1451->C5_NOTA
					TTRB->SERIE := BD1451->C5_SERIE
					TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMERO
					TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
					TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
					//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
					TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
					MsunLock()
				EndIF

			ElseIF MV_PAR04 == "B"
				If  _cLegSt <> "F"
					DbSelectArea("TTRB")
					RecLock("TTRB",.T.)
					TTRB->STATUS := _cRetStatus //IIf(_cLegSt <> 'F',"PED COM BLOQUEIO","*** APTO A FATURAR ***")
					TTRB->PEDIDO := BD1451->C5_NUM
					TTRB->GRUPO :=  _cNomGrp//ALLTRIM(BD1451->ZZ7_DESCRI)
					TTRB->CIDADE := AllTrim(BD1451->A1_MUN)
					TTRB->ESTADO := BD1451->A1_EST
					TTRB->CLIENTE := BD1451->C5_CLIENTE
					TTRB->LOJACLI := BD1451->C5_LOJACLI
					TTRB->NOME    := ALLTRIM(BD1451->A1_NOME)
					TTRB->DTBASE := BD1451->C5_DTBASE
					TTRB->ENTREGA := BD1451->C5_FTBASE
					TTRB->PRAZOENT := BD1451->C5_DESCPRA
					TTRB->DATAFATURA := BD1451->C5_DTFAT
					TTRB->FATURAESP := BD1451->C5_DTFATES
					TTRB->ANTECIPA := BD1451->C5_ANTECIP
					TTRB->TIPOBASE := BD1451->C5_TPBASE
					TTRB->DTREFEST := BD1451->C5_DTBEST
					TTRB->VOLUME1 := BD1451->C5_VOLUME1
					TTRB->ESPECIE := BD1451->C5_ESPECI1
					TTRB->VALORFAT := BD1451->C5_VALFAT
					TTRB->NOTA := BD1451->C5_NOTA
					TTRB->SERIE := BD1451->C5_SERIE
					TTRB->NUMGNRE := Space(12)//BD1451->F6_NUMERO
					TTRB->VALORGNRE := 0//Space(18)//BD1451->F6_VALOR
					TTRB->RECIBO := Space(30)//BD1451->F6_RECIBO
					//TTRB->C5_OBSLOGI := BD1451->C5_OBSLOGI
					TTRB->LEG := _cLegSt//Space(1)//BD1451->F6_RECIBO
					MsunLock()
				EndIF
			EndIf
			BD1451->(DbSkip())

		Enddo

		TTRB->(DbGotop())

	ENDIF

	cQry51 := cQryDados

Return

Static Function aPergs51()

	Local aPergs   := {}
	Local xPar8 := sToD("")
	Local xPar9 := sToD("")
	Private xPar10 := "N"
	Private xPar11 := "T"
	Private lRotUso := GETMV("BD_BUD1451")

	//Verifico se a rotina esta em uso
	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Data de", xPar8,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Ate", xPar9,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {2, "Mercado", xPar10, {"N=Mercado Nacional", "P=Mercado Projetos", "E=Mercado Exportação", "L=Luxus"}, 090, ".T.", .T.})
	aAdd(aPergs, {2, "Liberação", xPar11, {"T=Todos Pedidos", "F=Aptos a Faturar", "B=Bloqueados para Faturar"}, 090, ".T.", .T.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, 'Informe os parâmetros', /*aRet*/, /*bOk*/, /*aButtons*/, /*lCentered*/, /*nPosx*/, /*nPosy*/, /*oDlgWizard*/, /*cLoad*/, .F., .F.)
		Processa({|| BUDQRY51(2) },OemToAnsi("Aguarde... Selecionando os pedidos e aplicando as regras comerciais!"))
	EndIf


Return ()
