#Include 'Totvs.ch'
#Include 'FwMVCDef.ch'

Static __HasSNPrvt	:= NIL
Static ENTER 		:= CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BUD430M   ºAutor  ³Marcos A Schoeffel  º Data ³  07/10/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Ficha Tecnica de Artigos (Felpa/Veludo)        º±±
±±º          ³ - Dados Gerais                                             º±±
±±º          ³ - Tramas                                                   º±±
±±º          ³ - Carta Urdume de Cima                                     º±±
±±º          ³ - Carta Urdume de Baixo                                    º±±
±±º          ³ - Disposição dos Fios (UC, UB, Trama)                      º±±
±±º          ³ - Foto do Artigo (imagem - jpeg)                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Totvs11                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function BUD430_MVC(lAuto430,nOpcAuto)

	Local oBrowse
	Local cString  	:= "ZZA"
	Local cCadastro := "Ficha Tecnica"

	Private lEspecie := .F.
	Private nVF	   	 := 0
	Private lHabilUB2:= .F.
	Private lHabilUC2:= .F.
	Private nUCPERC  := 0, nUB1PERC := 0, nUB2PERC := 0, nUCPERC1 := 0, nTRPERC  := 0, nMOPERC := 0
	Private cTpMq    := ' '
	Private lGravar  := .F.
	Private lZZB	 := .F.
	Private cRef     := ""

	Public aCampos := {{"ZZA_OBSERV",""},{"ZZA_DISPC1",""},{"ZZA_DISPC2",""},{"ZZA_DISPC3",""},{"ZZA_DISPC4",""},;
	{"ZZA_TITUC",""} ,{"ZZA_FIOUC",0} ,{"ZZA_NFIUC",0} ,{"ZZA_PESUC",0} ,{"ZZA_CORUC",""} ,{"ZZA_MPUC",""} ,{"ZZA_TFIOC",""} ,{"ZZA_ESPEUC",""},;
	{"ZZA_TITUC1",""},{"ZZA_FIOUC1",0},{"ZZA_NFIUC1",0},{"ZZA_PESUC1",0},{"ZZA_CORUC1",""},{"ZZA_MPUC1",""},{"ZZA_TFIOC1",""},{"ZZA_ESPUC1",""},;
	{"ZZA_TITUB1",""},{"ZZA_FIOUB1",0},{"ZZA_NFIUB1",0},{"ZZA_PESUB1",0},{"ZZA_CORUB1",""},{"ZZA_MPUB1",""},{"ZZA_TFIOB",""} ,{"ZZA_ESPEUB",""},;
	{"ZZA_TITUB2",""},{"ZZA_FIOUB2",0},{"ZZA_NFIUB2",0},{"ZZA_PESUB2",0},{"ZZA_CORUB2",""},{"ZZA_MPUB2",""},{"ZZA_TFIOB2",""},{"ZZA_ESPEB2",""},;
	{"ZZA_TITTR",""} ,{"ZZA_FIOTR",0} ,{"ZZA_NFITR",0} ,{"ZZA_PESTR",0} ,{"ZZA_CORTR",""} ,{"ZZA_MPTR",""} ,{"ZZA_TFIOTR",""},{"ZZA_ESPETR",""},;
	{"ZZA_TITUC2",""},{"ZZA_NFIUC2",0},{"ZZA_PESUC2",0},{"ZZA_TFIOC2",""},{"ZZA_ESPUC2",""}}

	Public nLinDel := 0

	Default lAuto430 := .F.
	Default nOpcAuto := 0

	// Posiciona na tabela
	dbSelectArea(cString)
	dbSetOrder(1)

	If	!lAuto430
		// Instanciamento da Classe de Browse
		oBrowse := FWMBrowse():New()

		// Definição da tabela do Browse
		oBrowse:SetAlias(cString)

		// Titulo da Browse
		oBrowse:SetDescription(cCadastro)

		// Opcionalmente pode ser desligado a exibição dos detalhes
		oBrowse:DisableDetails()

		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetMenuDef('BUD430M') // Nome do fonte onde esta a função MenuDef

		// Ativação da Classe
		oBrowse:Activate()
	Else

		Do Case
			Case nOpcAuto == 2 //MODEL_OPERATION_VIEW
			U_B430MVIS()
			Case nOpcAuto == 3 //MODEL_OPERATION_INSERT
			U_B430MINC()
			Case nOpcAuto == 4 //MODEL_OPERATION_UPDATE
			U_B430MALT()
			Case nOpcAuto == 5 //MODEL_OPERATION_DELETE
			U_B430MEXC()
		End Case
	EndIf

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'U_B430MVIS()' OPERATION MODEL_OPERATION_VIEW ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'U_B430MINC()' OPERATION MODEL_OPERATION_INSERT ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'U_B430MALT()' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'U_B430MEXC()' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	ADD OPTION aRotina TITLE 'Copiar'     ACTION 'U_B430MCOP()' OPERATION MODEL_OPERATION_ONLYUPDATE ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'U_B430MPRT()' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
	ADD OPTION aRotina TITLE 'Ajuste Fio' ACTION 'U_BUD1469()'  OPERATION MODEL_OPERATION_UPDATE ACCESS 0

Return aRotina

//----------------------------------------------------------
User Function B430MVIS()

	FWExecView("Visualização", 'BUD430M', MODEL_OPERATION_VIEW, , { || .T. },,,,{ || .T. } )

Return .T.

//----------------------------------------------------------
User Function B430MINC()

	FWExecView('Inclusão', 'BUD430M', MODEL_OPERATION_INSERT, , { || .T. },,,,{ || .T. } )

Return .T.

//----------------------------------------------------------
User Function B430MALT()

	FWExecView('Alteração', 'BUD430M', MODEL_OPERATION_UPDATE, , { || .T. },,,,{ || .T. } )

Return .T.

//----------------------------------------------------------
User Function B430MEXC()

	Local lRet := .T.

	Processa({|| lRet := B430VldExc(), 'Aguarde Validando Exclusão de Tecido ...'})

	If	lRet
		FWExecView('Exclusão', 'BUD430M', MODEL_OPERATION_DELETE, , { || .T. },,,,{ || .T. } )
	EndIf

Return .T.

//----------------------------------------------------------
User Function B430MCOP()

	Local cLoad 	:= "BUD430M"
	//Local dData 	:= Stod("")
	Local bOkPer	:= {|| .T.}
	Local aButtons  := {}
	Local aParamBox	:= {}
	Local lCentered := .T.
	Local nPosx
	Local nPosy
	Local lCanSave 	:= .T.
	Local lUserSave := .T.
	Local cTitulo 	:= "Cópia de Ficha Técnica de Artigo"
	Local aPergRet	:= {}   // Retorno da informações de pergunta

	Local oProcess 	:= Nil

	Private cID      := "0000"
	Private bCampo	 := { |nCPO| Field(nCPO) }
	Private bBloco	 := '{||nTot++}'

	AADD(aParamBox,{1, "De Referencia    "  	,Space(TamSx3('ZZA_REF')[1])   ,"@!","NaoVazio().Or.ExistCpo('ZZA')","ZZA","",80,.T.}) //Artigo de ?
	AADD(aParamBox,{1, "De Tipo Maquina  "		,Space(TamSx3('ZZA_TIPOMA')[1]),"@!","NaoVazio().Or.ExistCpo('ZZE')","ZZE","",30,.T.}) //Tipo Maquina de ?
	AADD(aParamBox,{1, "Para Referencia  "  	,Space(TamSx3('ZZA_REF')[1])   ,"@!","NaoVazio().Or.ExistCpo('ZZA')","ZZA","",80,.T.}) //Artigo Ate ?
	AADD(aParamBox,{1, "Para Tipo Maquina"		,Space(TamSx3('ZZA_TIPOMA')[1]),"@!","NaoVazio().Or.ExistCpo('ZZE')","ZZE","",30,.T.}) //Tipo Maquina de ?

	If	!(ParamBox(aParamBox, cTitulo, @aPergRet, bOkPer, aButtons, lCentered, nPosx, nPosy, , cLoad, lCanSave, lUserSave))
		Return .T.
	EndIf

	If	(aPergRet[1] == aPergRet[3]) .And. (aPergRet[2] == aPergRet[4])
		Help( ,, 'Help',, 'É necessário que a ou a referência ou o tipo de máquina nas perguntas 3 e 4, sejam diferentes das perguntas 1 e 2 !!!', 1, 0 )
		Return .T.
	EndIf

	If !ZZA->(DbSeek(xFilial("ZZA")+aPergRet[1]+aPergRet[2]))
		Help( ,, 'Help',, "Referencia e Tipo de Maquina a serem copiados, nao existem!!!", 1, 0 )
		Return .T.
	EndIf

	If 	ZZA->(DbSeek(xFilial("ZZA")+aPergRet[3]+aPergRet[4]))
		Help( ,, 'Help',, "Referencia e Tipo de Maquina a serem gerados, ja existem!!!", 1, 0 )
		Return .T.
	EndIf

	oProcess := MsNewProcess():New({|| B430Copia(oProcess, aPergRet)},"Processando","Executando seleção...",.T.)
	oProcess:Activate()

	// ------------------------------------------------------

	ExecBlock("BUD757",.F.,.F.,5)

	// Enviar e-mail da ficha técnica:
	IF 	MsgYesNo ("Deseja enviar o e-mail de notificação da ficha técnica?")
		U_BUD1143(aPergRet[3], aPergRet[4])
	EndIf

Return .T.

Static Function B430Copia(oProcess, aParam)

	Local _i := 0
	Local aRotinas	:= {}
	Local bExecuta	:= "{|| aRotinas[i][2] }"

	// Processamento para fazer a copia das tabelas do Artigo

	aAdd(aRotinas,{"B430ZZA(oProcess, aParam)", "Copiando registros - ZZA -> Dados Ficha Técnica  " })
	aAdd(aRotinas,{"B430ZZB(oProcess, aParam)", "Copiando registros - ZZB -> Carta de Urdume Cima " })
	aAdd(aRotinas,{"B430U00(oProcess, aParam)", "Copiando registros - U00 -> Dados Tramas / Iros  " })

	oProcess:SetRegua1(len(aRotinas))
	Begin Transaction
		For _i:=1 to len(aRotinas)

			oProcess:IncRegua1(aRotinas[_i][2])
			bExecuta := "{|| "+aRotinas[_i][1] +"}"
			Sleep(1000)
			Eval(&bExecuta)

		Next i
	End Transaction

	//oProcess:SaveLog("Término da Cópia "+IIf(Right(cCena,1)=='P'," da Programação do Período "," do Cenário "+Right(cCena,1)+" do Período ")+cPeriodo)

	Aviso("Final","Cópia de Artigo executada com Sucesso !!!",{"OK"})

Return

//----------------------------------------------------------
User Function B430MPRT()

	//Local lRet := .T.

	// Chama Função para impressão da Ficha Técnica
	U_BUD631()

Return .T.


Static Function B430ZZA(oProcess, aParam)

	Local i	:= 0

	oProcess:SetRegua1(1)

	// COPIA DOS DADOS DA TABELA DE ARTIGOS
	If 	Select("TRZZA") <> 0
		TRZZA->(dbCloseArea())
	Endif

	BeginSql Alias "TRZZA"
	SELECT *
	FROM %Table:ZZA%
	WHERE %NotDel%
	AND ZZA_FILIAL = %xFilial:ZZA%
	AND ZZA_REF    = %Exp:aParam[1]%
	AND ZZA_TIPOMA = %Exp:aParam[2]%
	EndSql

	aEval(ZZA->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField('TRZZA',x[1],x[2],x[3],x[4]),Nil)})

	nTot := 0
	nCount := 0

	dbSelectArea("TRZZA")
	dbGoTop()
	DbEval(&bBloco)
	DbGotop()

	oProcess:IncRegua1("Tabela de Ficha Técnica - Artigo")
	oProcess:SetRegua2(nTot)

	dbSelectArea("ZZA")
	If !TRZZA->(Eof())

		While !TRZZA->(Eof())

			nCount++
			oProcess:IncRegua2("Copiando Cabeçalho Ficha Técnica - "+AllTrim(Str(nCount)) + "/" + Alltrim(STR(nTot)))

			RecLock("ZZA",.T.)

			For i := 1 To TRZZA->(FCount())
				If 	!(RTrim(TRZZA->(FieldName(i))) $ "ZZA_REF/ZZA_TIPOMA/ZZA_DTIMPL/ZZA_CALCUS/ZZA_USERGA/ZZA_USERGI/R_E_C_N_O_/D_E_L_E_T_")

					cCampo := TRZZA->(FieldName( i ))
					ZZA->(&cCampo) := TRZZA->( FieldGet( i ) )

				EndIf
			Next i

			ZZA->ZZA_REF    := aParam[3]
			ZZA->ZZA_TIPOMA := aParam[4]
			ZZA->ZZA_DTIMPL	:= dDataBase
			ZZA->ZZA_TIPO	:= Left(ZZA->ZZA_REF,1)
			ZZA->ZZA_ESPECI	:= IIF(AllTrim(ZZA->ZZA_ESPECI)=='BRANCO','',ZZA->ZZA_ESPECI)
			ZZA->ZZA_CALCUS	:= 'N'
			ZZA->ZZA_MSBLQL	:= '2'
			ZZA->(MsUnLock())

			TRZZA->(dbSkip())
		EndDo
	EndIf

Return

Static Function B430ZZB(oProcess, aParam)

	Local i	:= 0

	oProcess:SetRegua1(2)

	// COPIA DOS DADOS DA CARTA DE URDUME DE CIMA
	If 	Select("TRZZB") <> 0
		TRZZB->(dbCloseArea())
	Endif

	BeginSql Alias "TRZZB"
	SELECT *
	FROM %Table:ZZB%
	WHERE %NotDel%
	AND ZZB_FILIAL = %xFilial:ZZB%
	AND ZZB_REF    = %Exp:aParam[1]%
	AND ZZB_TIPOMA = %Exp:aParam[2]%
	EndSql

	aEval(ZZB->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField('TRZZB',x[1],x[2],x[3],x[4]),Nil)})

	nTot := 0
	nCount := 0

	dbSelectArea("TRZZB")
	dbGoTop()
	DbEval(&bBloco)
	DbGotop()

	oProcess:IncRegua1("Tabela de Ficha Técnica - Carta de Urdume de Cima")
	oProcess:SetRegua2(nTot)

	dbSelectArea("ZZB")
	If !TRZZB->(Eof())

		While !TRZZB->(Eof())

			nCount++
			oProcess:IncRegua2("Copiando Carta de Urdume de Cima - "+AllTrim(Str(nCount)) + "/" + Alltrim(STR(nTot)))

			RecLock("ZZB",.T.)

			For i := 1 To TRZZB->(FCount())
				If 	!(RTrim(TRZZB->(FieldName(i))) $ "ZZB_REF/ZZB_TIPOMA/R_E_C_N_O_/D_E_L_E_T_")

					cCampo := TRZZB->(FieldName( i ))
					ZZB->(&cCampo) := TRZZB->( FieldGet( i ) )

				EndIf
			Next i

			ZZB->ZZB_REF    := aParam[3]
			ZZB->ZZB_TIPOMA := aParam[4]
			ZZB->(MsUnLock())

			TRZZB->(dbSkip())
		EndDo
	EndIf

Return

Static Function B430U00(oProcess, aParam)

	Local i := 0

	oProcess:SetRegua1(3)

	// COPIA DOS DADOS DAS TRAMAS/IROS
	If 	Select("TRU00") <> 0
		TRU00->(dbCloseArea())
	Endif

	BeginSql Alias "TRU00"
	SELECT *
	FROM %Table:U00%
	WHERE %NotDel%
	AND (U00_FILIAL = '' OR U00_FILIAL='01')
	AND U00_REF    = %Exp:aParam[1]%
	AND U00_TIPOMA = %Exp:aParam[2]%
	EndSql

	aEval(U00->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField('TRU00',x[1],x[2],x[3],x[4]),Nil)})

	nTot := 0
	nCount := 0

	dbSelectArea("TRU00")
	dbGoTop()
	DbEval(&bBloco)
	DbGotop()

	oProcess:IncRegua1("Tabela de Ficha Técnica - Tramas/Iros")
	oProcess:SetRegua2(nTot)

	dbSelectArea("U00")
	If !TRU00->(Eof())

		While !TRU00->(Eof())

			nCount++
			oProcess:IncRegua2("Copiando Dados das Tramas/Iros - "+AllTrim(Str(nCount)) + "/" + Alltrim(STR(nTot)))

			RecLock("U00",.T.)

			For i := 1 To TRU00->(FCount())
				If 	!(RTrim(TRU00->(FieldName(i))) $ "U00_REF/U00_TIPOMA/R_E_C_N_O_/D_E_L_E_T_")

					cCampo := TRU00->(FieldName( i ))
					U00->(&cCampo) := TRU00->( FieldGet( i ) )

				EndIf
			Next i

			U00->U00_REF    := aParam[3]
			U00->U00_TIPOMA := aParam[4]
			U00->(MsUnLock())

			TRU00->(dbSkip())
		EndDo
	EndIf

Return

Static Function ViewDef()

	Local cStruZZA := 'ZZA_REF/ZZA_ARTIGO/ZZA_TIPO/ZZA_BARRAP/ZZA_TIPOMA/ZZA_DESTPM/ZZA_PRODUT/ZZA_ESPECI/ZZA_LARGPO/ZZA_COMPOL/ZZA_LARGUR/'+;
	'ZZA_COMPR/ZZA_PESOMT/ZZA_LARGTP/ZZA_PESOUN/ZZA_PESOLN/ZZA_TFIOUC/ZZA_TFIOUC1/'+;
	'ZZA_TFIOUB/ZZA_LARGUC/ZZA_LARGUB/ZZA_CHAPAC/ZZA_CHAPAB/ZZA_ALTFEL/ZZA_ALTFE2/ZZA_ALTFE3/ZZA_NBAT/ZZA_UNIDLA/ZZA_QTDUC/'+;
	'ZZA_BARRAL/ZZA_LARGTE/ZZA_COMPTE/ZZA_FLUXO/ZZA_OURELA/ZZA_DTIMPL/ZZA_MSBLQL/'+;
	'ZZA_SAIFIO/ZZA_OBS1/ZZA_OBS2/ZZA_OBS3/ZZA_OBS4/ZZA_USERI/ZZA_DATAI/ZZA_USERA/ZZA_DATAA/ZZA_CALCUS/ZZA_BARRAC/'+;
	'ZZA_COMPIM/ZZA_FIOTRI/ZZA_PERGOMA/ZZA_PRODUC/ZZA_PRODUB/ZZA_MODLUC/ZZA_MODLUB/ZZA_ALTCOR//ZZA_PERTOS'

	Local cStruZZB := 'ZZB_SEQ, ZZB_NFIOS, ZZB_COR1, ZZB_COR2, ZZB_COR3, ZZB_COR4, ZZB_VEZES, ZZB_TFIOS'
	Local cStruU00 := 'U00_SEQUEN, U00_COR, U00_QTDFIO, U00_FIOSBA, U00_TITFIO, U00_PESO, U00_TPFIO, U00_CORPO, U00_ESPECI'
	Local cStruZZD := 'ZZD_SEQ, ZZD_COR, ZZD_NFIOS, ZZD_VEZES, ZZD_TFIOS'

	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel 	   := FWLoadModel( "BUD430M" )

	// Cria a estrutura a ser usada na View
	Local oStruZZA := FWFormStruct( 2, 'ZZA', { |x| ALLTRIM(x) $ cStruZZA } )
	Local oStruZZB := FWFormStruct( 2, 'ZZB', { |x| ALLTRIM(x) $ cStruZZB } )
	Local oStruU00 := FWFormStruct( 2, 'U00', { |x| ALLTRIM(x) $ cStruU00 } )
	Local oStruZZD := FWFormStruct( 2, 'ZZD', { |x| ALLTRIM(x) $ cStruZZD } )

	// Interface de visualização construída
	Local oView

	// Alterado campo ZZA_ESPECI em separado devido ao tratamento especifico para o campo COMBOBOX

	nPos := aScan(oStruZZA:aFields,{|x| AllTrim(x[1]) == 'ZZA_ESPECI'})
	If	nPos > 0
		oStruZZA:aFields[nPos][13] := Separa(alltrim(GETMV("MV_TPTECID")),";",.F.)
	EndIf

	// Excluir campo ZZA_BARRA do vetor
	nPos := aScan(oStruZZA:aFields,{|x| AllTrim(x[1]) == 'ZZA_BARRA'})
	If	nPos > 0
		aDel(oStruZZA:aFields, nPos)
		aSize(oStruZZA:aFields,Len(oStruZZA:aFields)-1)
	EndIf

	/*SX3->(DbSetOrder(2))
	SX3->(DbSeek('ZZA_ESPECI'))
	oStruZZA:AddField(	"ZZA_ESPECI" 		,;	// [01] C Nome do Campo
	"05" 				,; 	// [02] C Ordem
	SX3->(X3Titulo())	,; 	// [03] C Titulo do campo
	SX3->(X3Descric())	,; // [04] C Descrição do campo
	{}         			,; 	// [05] A Array com Help
	"C" 				,; 	// [06] C Tipo do campo
	SX3->(X3Picture()),; // [07] C Picture
	Nil 				,; 	// [08] B Bloco de Picture Var
	"" 					,; 	// [09] C Consulta F3
	.T. 				,;	// [10] L Indica se o campo é evitável
	Nil 				,; 	// [11] C Pasta do campo
	Nil 				,;	// [12] C Agrupamento do campo
	Separa(alltrim(GETMV("MV_TPTECID")),";",.F.),; 	// [13] A Lista de valores permitido do campo (Combo)
	Nil 				,;	// [14] N Tamanho Maximo da maior opção do combo
	Nil 				,;	// [15] C Inicializador de Browse
	.F. 				,;	// [16] L Indica se o campo é virtual
	Nil )              	// [17] C Picture Variável*/

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado na View
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_ZZA', oStruZZA, 'ZZAMASTER' )

	//Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
	oView:AddGrid( 'VIEW_U00', oStruU00, 'U00DETAIL',,{|| lZZB := .F. } )
	oView:AddGrid( 'VIEW_ZZB', oStruZZB, 'ZZBDETAIL',,{|| lZZB := .T. } )
	oView:AddGrid( 'VIEW_ZZD', oStruZZD, 'ZZDDETAIL',,{|| lZZB := .F. } )

	// Criar um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 60 )
	oView:CreateHorizontalBox( 'INFERIOR', 40 )

	oView:CreateFolder('FOLDINF', 'INFERIOR')

	oView:AddSheet('FOLDINF','ESQUERDA','TRAMAS')
	oView:CreateHorizontalBox( 'BOXESQUERDA', 100,,, 'FOLDINF', 'ESQUERDA' )

	oView:AddSheet('FOLDINF','CENTRAL','FIOS U.C.')
	oView:CreateHorizontalBox( 'BOXCENTRAL', 100,,, 'FOLDINF', 'CENTRAL' )

	oView:AddSheet('FOLDINF','DIREITA','FIOS U.B.')
	oView:CreateHorizontalBox( 'BOXDIREITA', 100,,, 'FOLDINF', 'DIREITA' )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_ZZA', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_U00', 'BOXESQUERDA' )
	oView:SetOwnerView( 'VIEW_ZZB', 'BOXCENTRAL')
	oView:SetOwnerView( 'VIEW_ZZD', 'BOXDIREITA' )

	// Seta o campo para que seja utilizado com incremento automático
	oView:AddIncrementField('VIEW_ZZB' , 'ZZB_SEQ' )
	oView:AddIncrementField('VIEW_ZZD' , 'ZZD_SEQ' )

	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_ZZA', "DADOS GERAIS" )
	oView:EnableTitleView( 'VIEW_U00', "DADOS DAS TRAMAS/IROS"  )
	oView:EnableTitleView( 'VIEW_ZZB', "DADOS FIOS URDUME DE CIMA"  )
	oView:EnableTitleView( 'VIEW_ZZD', "DADOS FIOS URDUME DE BAIXO"  )

	//-------------------------------------------------------------------
	//HAbilita o ControlBar(Antiga EnchoiceBar)
	//-------------------------------------------------------------------
	oView:EnableControlBar(.T.)

	// Acao a ser executada quando o(s) botao(os) abaixo for(em) pressionado(s)
	oView:SetViewAction( 'BUTTONOK'    ,{ || } )
	oView:SetViewAction( 'BUTTONCANCEL',{ || } )

	// Adiciona botao de controle de usuario
	oView:AddUserButton( 'Foto Artigo'    , 'CLIPS', {|oView| B430ShowJpg(oView)} )
	oView:AddUserButton( 'Disp.Tipos Fios', 'CLIPS', {|oView| B430DispFios(oView)} )

	// Funcao F2 acionada que irá inserir nova linha para o U.C.
	SetKey(VK_F2, {|| IIf(lZZB, B430InsLin(),) } )

	// Retorna o objeto de View criado
Return oView

Static Function ModelDef()

	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZZA := FWFormStruct( 1, 'ZZA' )
	Local oStruZZB := FWFormStruct( 1, 'ZZB' )
	Local oStruU00 := FWFormStruct( 1, 'U00' )
	Local oStruZZD := FWFormStruct( 1, 'ZZD' )
	Local oModel
	//Local bTudoOK	:= { | oModel | fTudoOk430( oModel )}

	// Adiciona Trigger (gatilho)
	//aTrigger := CreateTrigger("U00_SEQUEN", "U00_SEQUEN", ".T.", "B430GatU00()")
	//oStruU00:AddTrigger( aTrigger[1], aTrigger[2] , aTrigger[3], aTrigger[4] )
	oStruU00:AddTrigger( "U00_SEQUEN", "U00_SEQUEN" , {|| .T. }, {|| B430GatU00()} )

	//aTrigger := CreateTrigger("ZZB_NFIOS", "ZZB_TPFIOS", ".T.", "B430GatZZB('ZZB_FIOS',.T.)")
	//oStruU00:AddTrigger( aTrigger[1], aTrigger[2] , aTrigger[3], aTrigger[4] )
	oStruZZB:AddTrigger( "ZZB_NFIOS" , "ZZB_NFIOS"	, {|| .T. }  , {|| B430GatZZB('ZZB_NFIOS',.T.) }  )

	//aTrigger := CreateTrigger("ZZB_VEZES", "ZZB_TPFIOS", ".T.", "B430GatZZB('ZZB_VEZES',.T.)")
	//oStruU00:AddTrigger( aTrigger[1], aTrigger[2] , aTrigger[3], aTrigger[4] )
	oStruZZB:AddTrigger( "ZZB_VEZES" , "ZZB_VEZES"	, {|| .T. }  , {|| B430GatZZB('ZZB_VEZES',.T.) }  )

	//aTrigger := CreateTrigger("ZZD_NFIOS", "ZZD_TFIOS", "B430ValGat('ZZDDETAIL')", "B430GatZZD('ZZD_NFIOS',.T.)")
	//oStruU00:AddTrigger( aTrigger[1], aTrigger[2] , aTrigger[3], aTrigger[4] )
	oStruZZD:AddTrigger( "ZZD_NFIOS" , "ZZD_NFIOS"	, {|| B430ValGat('ZZDDETAIL') }  , {|| B430GatZZD('ZZD_NFIOS',.T.) }  )

	//aTrigger := CreateTrigger("ZZD_VEZES", "ZZB_TFIOS", "B430ValGat('ZZDDETAIL')", "B430GatZZD('ZZD_VEZES',.T.)")
	//oStruU00:AddTrigger( aTrigger[1], aTrigger[2] , aTrigger[3], aTrigger[4] )
	oStruZZD:AddTrigger( "ZZD_VEZES" , "ZZD_VEZES"	, {|| B430ValGat('ZZDDETAIL') }  , {|| B430GatZZD('ZZD_VEZES',.T.) }  )

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'BUD430M',/*bPreValidacao*/,{|| .T. /*bPosValidacao*/},{ |oModel| B430Gravar(oModel) /*bPosGrava*/},{|oModel| B430Cancelar(oModel) /*bCancel*/} )

	oStruZZA:SetProperty('ZZA_DTIMPL', MODEL_FIELD_WHEN  , {|| .F. } )

	oStruZZB:SetProperty('ZZB_COR1', MODEL_FIELD_VALID, {|| Vazio() .Or. ExistCpo('ZAN') /*.And. StaticCall(BUD430M, B430AtuaZZB)*/ } )
	oStruZZB:SetProperty('ZZB_COR2', MODEL_FIELD_VALID, {|| Vazio() .Or. ExistCpo('ZAN') /*.And. StaticCall(BUD430M, B430AtuaZZB)*/ } )
	oStruZZB:SetProperty('ZZB_COR3', MODEL_FIELD_VALID, {|| Vazio() .Or. ExistCpo('ZAN') /*.And. StaticCall(BUD430M, B430AtuaZZB)*/ } )
	oStruZZB:SetProperty('ZZB_COR4', MODEL_FIELD_VALID, {|| Vazio() .Or. ExistCpo('ZAN') /*.And. StaticCall(BUD430M, B430AtuaZZB)*/ } )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'ZZAMASTER', ,oStruZZA, {|| .T.}, {|| B430ValZZA(oModel) } )

	// Adiciona ao modelo um componente de grid
	oModel:AddGrid( 'U00DETAIL', 'ZZAMASTER', oStruU00, {|| .T.} )
	oModel:AddGrid( 'ZZBDETAIL', 'ZZAMASTER', oStruZZB, {|| .T.} /*bLinePre*/, /*bLinePost*/, /*bPreVal*/ ,{|| &('StaticCall(BUD430M, B430AtZZB)') } /*bPosVal*/, /*BLoad*/  )
	oModel:addGrid( 'ZZDDETAIL', 'ZZAMASTER', oStruZZD, {|| .T.} /*bLinePre*/, /*bLinePost*/, /*bPreVal*/ ,{|| &('StaticCall(BUD430M, B430AtZZD)') } /*bPosVal*/, /*BLoad*/  )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation('U00DETAIL', { { 'U00_FILIAL', 'ZZA_FILIAL' }, { 'U00_REF', 'ZZA_REF' } ,{ 'U00_TIPOMA', 'ZZA_TIPOMA' }}, U00->( IndexKey( 1 ) ) )
	oModel:SetRelation('ZZBDETAIL', { { 'ZZB_FILIAL', 'ZZA_FILIAL' }, { 'ZZB_REF', 'ZZA_REF' }, { 'ZZB_TIPOMA', 'ZZA_TIPOMA' } }, ZZB->(IndexKey(1)) )
	oModel:SetRelation('ZZDDETAIL', { { 'ZZD_FILIAL', 'ZZA_FILIAL' }, { 'SUBSTRING(ZZD_CODUB,1,4)', 'ZZA_TFIOUB' }, { 'SUBSTRING(ZZD_CODUB,5,3)', 'ZZA_CORUB1' }, { 'SUBSTRING(ZZD_CODUB,8,3)', 'ZZA_CORUB2' }, { 'ZZD_TFIOUC', 'ZZA_TFIOUC' } }, ZZD->(IndexKey(1)) )

	// Adiciona a chave primaria caso nao exista
	oModel:SetPrimaryKey( { "ZZA_REF", "ZZA_TIPOMA" } )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Modelo de dados da Ficha Técnica' )

	// Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel( 'ZZAMASTER' ):SetDescription( "Dados Gerais Ficha Técnica" )
	oModel:GetModel( 'U00DETAIL' ):SetDescription( "Informações de Trama/IRO's" )
	oModel:GetModel( 'ZZBDETAIL' ):SetDescription( 'Informações de Fios Urdume Cima' )
	oModel:GetModel( 'ZZDDETAIL' ):SetDescription( 'Informações de Fios Urdume Baixo')

	// Liga o controle de não repetição de linha
	oModel:GetModel( 'U00DETAIL' ):SetUniqueLine( { 'U00_SEQUEN'} )
	oModel:GetModel( 'ZZBDETAIL' ):SetUniqueLine( { 'ZZB_SEQ'} )
	oModel:GetModel( 'ZZDDETAIL' ):SetUniqueLine( { 'ZZD_SEQ' } )

	// Preenchimento do Grid nao obrigatório
	oModel:getModel('ZZDDETAIL'):SetOptional(.T.)

	// Marca se deseja que os Grid utilizem o tratamento pela antiga aCols
	oModel:getModel('ZZBDETAIL'):SetUseOldGrid(.T.)

	// Executa validação na ativação do oModel caso retorne .F. o model não será ativado
	oModel:SetVldActivate({|oModel| B430VldActive(oModel) })

	// Retorna o Modelo de dados
Return oModel

Static Function B430VldActive(oModel)

	Local x	:= 0

	// Valida se existe outra ficha técnica com as mesmas características do Cadastro de UB para não exclui-lo indevidamente
	If	oModel:GetOperation() == MODEL_OPERATION_DELETE

		If	Select('AUX430')<>0
			AUX430->(DbCloseArea())
		EndIf

		BeginSql Alias 'AUX430'
		SELECT ZZA_REF FROM %Table:ZZA%
		WHERE %NotDel%
		AND ZZA_FILIAL = %xFilial:ZZA%
		AND ZZA_TFIOUB = %Exp:ZZA->ZZA_TFIOUB%
		AND ZZA_CORUB1 = %Exp:ZZA->ZZA_CORUB1%
		AND ZZA_CORUB2 = %Exp:ZZA->ZZA_CORUB2%
		AND ZZA_TFIOUC = %Exp:ZZA->ZZA_TFIOUC%
		AND ((ZZA_REF  = %Exp:ZZA->ZZA_REF% OR ZZA_TIPOMA <> %Exp:ZZA->ZZA_TIPOMA%) OR
		(ZZA_REF <> %Exp:ZZA->ZZA_REF% OR ZZA_TIPOMA = %Exp:ZZA->ZZA_TIPOMA%))
		EndSql

		If 	!AUX430->(Eof())
			oModel:GetModel( "ZZDDETAIL" ):SetOnlyView(.T.)
			oModel:GetModel( "ZZDDETAIL" ):SetOnlyQuery(.T.)
		EndIf
	Else
		// Funcao para criação de Variáveis de memória públicas
		B430CriaVa((oModel:GetOperation()==MODEL_OPERATION_INSERT),)
		// Armazenamento das variaveis de memória da tela em vetor a ser gravado posteriormente na tabela ZZA
		For	x:=1 To Len(aCampos)

			cCampo	 := aCampos[x,1]
			cVar := 'M->'+cCampo
			aCampos[x,2] := &(cVar)

		Next x
		If	(oModel:GetOperation() != MODEL_OPERATION_INSERT)
			If 	ZZE->(DbSeek(xFilial("ZZE")+ZZA->ZZA_TIPOMA))
				ctpmq := ALLTRIM(ZZE->ZZE_CLASSI)
			EndIf
		EndIf

	EndIf

Return .T.

// Validar se deverá ou não executar o gatilho para o calculo do total de fios no Urdume Cima/Baixo
Static Function B430ValGat(cGrid)

	Local lRet 	:= .T.
	//Local oModel:=	FwModelActive()
	//Local cAlias:= IIf(cGrid=='ZZBDETAIL','ZZB','ZZD')

	//If	(oModel:GetValue(cGrid,cAlias+'_NFIOS') = 0) .Or. (oModel:GetValue(cGrid,cAlias+'_VEZES') = 0)
	//	lRet := .F.
	//EndIf

Return lRet

// Gatilho para converter o campo de sequencia de iros para preencher o tamanho total do campo com zeros a esquerda
Static Function B430GatU00()

	Local oModel := FwModelActive()
	Local oU00   := oModel:GetModel("U00DETAIL")
	//Local nLin   := oU00:GetLine()
	Local cRet	   := ''

	cRet := StrZero(Val(oU00:GetValue('U00_SEQUEN')),TamSx3('U00_SEQUEN')[1])
	oU00:LoadValue('U00_SEQUEN', cRet)

Return cRet

// Executar gatilho para a tabela de Urdume de Cima, afim de gerar o total de fios nas linhas
Static Function B430GatZZB(cCpo, lRet, nLin, lUnico, nTotal, cTpPe)

	Local oModel := FwModelActive()
	Local oZZB   := oModel:GetModel("ZZBDETAIL")
	Local cRet   := 0
	Local nX	 := 0

	Default cCpo   := 'ZZB_TFIOS'
	Default lRet   := .F.
	Default nLin   := oZZB:GetLine()
	Default lUnico := .F.
	Default nTotal := 0
	Default cTpPE  := ''

	/*If	nLin == 1
	nTotal := 0
	ElseIf	nTotal == 0
	oZZB:GoLine(nLin-1)
	nTotal := oZZB:GetValue('ZZB_TFIOS')
	EndIf*/
	//nTotal := 0

	If	lUnico
		nTotal += oZZB:GetValue('ZZB_NFIOS') * oZZB:GetValue('ZZB_VEZES')
		oZZB:LoadValue('ZZB_TFIOS' , nTotal )
		If 	lRet
			cRet := oZZB:GetValue(cCpo)
		EndIf
	Else
		For	nX := 1/*nLin*/ To oZZB:Length()

			oZZB:GoLine(nX)
			lProcessa := (cTpPE == 'UNDELETE' .And. nX == nLinDel) .Or.;
			!(cTpPE == 'DELETE'  .And. nX == nLinDel) .Or.;
			((!oZZB:IsDeleted()) .And. (nX != nLinDel))

			If	lProcessa

				nTotal += oZZB:GetValue('ZZB_NFIOS') * oZZB:GetValue('ZZB_VEZES')

				oZZB:LoadValue('ZZB_TFIOS' , nTotal )
				If 	(nLin == nX) .And. lRet
					cRet := oZZB:GetValue(cCpo)
				EndIf

			EndIf

		Next nX
		oZZB:GoLine(nLin)
	EndIf

Return cRet


// Executar gatilho para a tabela de Urdume de Baixo, afim de gerar o total de fios nas linhas
Static Function B430GatZZD(cCpo, lRet, nLin, lUnico, nTotal)

	Local oModel := FwModelActive()
	Local oZZD   := oModel:GetModel("ZZDDETAIL")
	Local cRet   := 0
	Local nX     := 0

	Default cCpo   := 'ZZD_TFIOS'
	Default lRet   := .F.
	Default nLin   := oZZD:GetLine()
	Default lUnico := .F.
	Default nTotal := 0

	If	nLin == 1
		nTotal := 0
	ElseIf	nTotal == 0
		oZZD:GoLine(nLin-1)
		nTotal := oZZD:GetValue('ZZD_TFIOS')
	EndIf

	If	lUnico
		nTotal += oZZD:GetValue('ZZD_NFIOS') * oZZD:GetValue('ZZD_VEZES')
		oZZD:LoadValue('ZZD_TFIOS' , nTotal )
		If 	lRet
			cRet := oZZD:GetValue(cCpo)
		EndIf
	Else
		For	nX := nLin To oZZD:Length()

			oZZD:GoLine(nX)
			If	!oZZD:IsDeleted()

				nTotal += oZZD:GetValue('ZZD_NFIOS') * oZZD:GetValue('ZZD_VEZES')

				oZZD:LoadValue('ZZD_TFIOS' , nTotal )
				If 	(nLin == nX) .And. lRet
					cRet := oZZD:GetValue(cCpo)
				EndIf

			EndIf

		Next nX
	EndIf

Return cRet


// Inserir nova linha de dados para o Urdume de Cima, reposicionando as demais linhas abaixo para o proximo numero
Static Function B430InsLin()

	Local oModel 	:= FWMODELACTIVE()
	Local oView  	:= FWVIEWACTIVE()
	Local oZZB		:= oModel:GetModel("ZZBDETAIL")
	Local nLin		:= oZZB:GetLine()
	Local cSeq		:= StrZero(Val(oZZB:GetValue('ZZB_SEQ')),4)
	//Local nPos		:= aScan(oZZB:aHeader,{|x| AllTrim(x[2]) == "ZZB_SEQ"})
	Local nSeq		:= 0
	Local nX		:= 0
	Local nY		:= 0
	Local nFim		:= 0
	Local lDelAtu 	:= .F.
	Local lDelAnt 	:= .F.
	Local cSeqAtu 	:= '9999'
	Local cSeqAnt 	:= '9999'

	// Acerta primeiro a sequencia dos itens devido a possibilidade de existir algum item anterior excluido
	// Acerta o campo de sequencia (zzb_seq) para todos os itens do Urdume de Cima do Artigo
	/*nSeq := 0
	For nX := 1 to oZZB:Length()

	oZZB:GoLine(nX)
	If	!oZZB:IsDeleted()
	nSeq ++
	oZZB:LoadValue('ZZB_SEQ' , StrZero(nSeq,4) )
	EndIf

	Next nX*/

	// Posiciona na Linha seleciona para incluir uma nova linha e caso a mesma estiver deletada será posicionada na posterior
	oZZB:GoLine(nLin)
	If	oZZB:IsDeleted()
		If	(nLin > 1) .And. (nLin <= oZZB:Length())
			While oZZB:IsDeleted() .And. (nLin <= oZZB:Length())
				nLin --
				oZZB:GoLine(nLin)
			EndDo
			cSeq := StrZero(Val(oZZB:GetValue('ZZB_SEQ')),4)
		Else
			cSeq := '0001'
		EndIf
	EndIf

	// Adiciona uma nova linha
	oZZB:GoLine(oZZB:Length())
	oZZB:AddLine()
	nFim := oZZB:Length()

	// Acerta o campo de sequencia (zzb_seq) para todos os itens do Urdume de Cima do Artigo
	nSeq := 0
	For nX := 1 to oZZB:Length()

		oZZB:GoLine(nX)
		If	!oZZB:IsDeleted()
			If	(nX == oZZB:Length())
				oZZB:LoadValue('ZZB_SEQ' , cSeq )
				nSeq ++
			ElseIf (nX == nLin)
				nSeq += 2
				oZZB:LoadValue('ZZB_SEQ' , StrZero(nSeq,4) )
			Else
				nSeq ++
				oZZB:LoadValue('ZZB_SEQ' , StrZero(nSeq,4) )
			EndIf
		EndIf

	Next nX

	// Faz a reordenacao das sequencias do Urdume de Cima
	For nX := oZZB:Length() To 1 Step -1

		lDelAtu := .F.
		lDelAnt := .F.
		cSeqAtu := '9999'
		cSeqAnt := '9999'

		oZZB:GoLine(nX)
		lDelAtu :=	oZZB:IsDeleted()
		cSeqAtu := StrZero(Val(oZZB:GetValue('ZZB_SEQ')),4)
		If	nX > 1
			nY := nX -1
			oZZB:GoLine(nY)
			lDelAnt := oZZB:IsDeleted()
			cSeqAnt := StrZero(Val(oZZB:GetValue('ZZB_SEQ')),4)
		EndIf

		nY := nX - 1
		If	(cSeqAtu < cSeqAnt) .And. !lDelAtu .And. !lDelAnt .And. (nY > 0)
			oZZB:LineShift(nX,nY)
		ElseIf	lDelAnt
			oZZB:LineShift(nX,nY)
		EndIf

	Next nX

	// Recalcula Totais de Fios
	oZZB:GoLine(1)
	B430GatZZB(,.F.)

	// Refresh do objeto para mostrar os dados alterados
	oView:Refresh('VIEW_ZZB')

	// Posiciona na linha do grid onde foi pressionada a tecla F2 pra inserir nova linha
	oZZB:GoLine(nLin)
	oZZB:SetLine(nLin)

Return

// Funcao para visualizar a foto do artigo
Static Function B430ShowJpg(oView, cRef)
	//*****************************

	Local aSize 	:= FWGetDialogSize( oMainWnd )
	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= Nil
	Local oPnlSep1, cBmp, oBit

	Default oView := Nil
	Default cRef	:= ''

	Static oJpgDlg

	If	oView != Nil
		oZZA := oModel:GetModel("ZZAMASTER")
		cRef := oZZA:GetValue( 'ZZA_REF' )
	EndIf

	oJpgDlg := TDialog():New(aSize[1],aSize[2],aSize[3]*.8,aSize[4]*.8,"Foto do Artigo - "+cRef,,,,,,,,,.T.,,,,aSize[4]*.9,aSize[3]*.9)
	oPnlSep1 := TPanel():New(0,0,"",oJpgDlg,,,,,,300,300,,)
	oPnlSep1:Align := CONTROL_ALIGN_TOP
	oPnlSep1:nHeight := 3

     /*IF (SELECT("TTZZA") <> 0)
	    TTZZA->(DBCLOSEAREA())
     ENDIF
	BeginSql Alias 'TTZZA'
	  SELECT DISTINCT ZZA_REF,
	  CASE
          WHEN SUBSTRING(ZZA_REF,9,6)='000000' THEN 'CRU'
          ELSE 'COR'
          END AS TP_REF
	  FROM %Table:ZZA%
	  WHERE ZZA_FILIAL = %xFilial:ZZA%
	  AND %NotDel%
	  AND LEFT(ZZA_REF,8) = %Exp:SUBSTRING(ALLTRIM(cRef),1,8)%
	EndSql*/
    /*While TTZZA->(!Eof())

     If TTZZA->TP_REF=='COR'
	    cBMP := "\FIGURAS\"+ALLTRIM(cRef)+".jpg"
	 Else
	  cBMP := "\FIGURAS\"+ALLTRIM(TTZZA->ZZA_REF)+".jpg"
	 EnDIf

	If File(cBMP)
	If !File(cBMP)
		cBMP := "\FIGURAS\noimage.jpg"
	EndIf
	Exit
	EndIf
	TTZZA->(dbSkip())
	End*/

    cBMP := "\FIGURAS\"+ALLTRIM(cRef)+".jpg"
	If !File(cBMP)
		cBMP := "\FIGURAS\noimage.jpg"
	EndIf



	oBit := TBitMap():New(0, 0, 40, 40,,cBMP,.t., , , ,,.t. , , , , , .t.)
	oBit:Align 	:=  CONTROL_ALIGN_ALLCLIENT
	oBit:cBMPFile	:= cBMP
	oBit:Load(cBMP)
	oBit:refresh()

	oJpgDlg:bInit := {|| EnchoiceBar(oJpgDlg,{|| oJpgDlg:End()},{|| oJpgDlg:End()},.F.,)}
	oJpgDlg:Activate(,,,.T.,,,)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³B430VldExcºAutor  ³ Alan Leandro       º Data ³  13/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Deixa excluir apenas registros na ficha tecnica que nao    º±±
±±º          ³ existe no cadastro de produtos.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function B430VldExc()
	//**************************

	Local lRet		:= .T.
	Local cRef := ZZA->ZZA_REF
	Local nCntAx := 0
	//Local cTpMaq := ZZA->ZZA_TIPOMA
	Local aSegZZA	:= ZZA->(GetArea())
	Local cTecAux	:= cRef

	If	U_CodNovo(cRef,4) != '000000'
		If	Substr(cRef,1,1)=="F"
			cTecAux := "T"
		ElseIf	Substr(cRef,1,1)=="V"
			cTecAux := "Q"
		EndIf
	Else
		cTecAux := Left(cRef,1)
	EndIf

	cTecAux += Substr(cRef,2,29)

	If Select('AUX430')<>0
		AUX430->(DbCloseArea())
	EndIf

	BeginSql Alias 'AUX430'
	SELECT ZZA_REF FROM %Table:ZZA%
	WHERE %NotDel% AND ZZA_FILIAL = %xFilial:ZZA%
	AND ZZA_REF = %Exp:cRef%
	EndSql

	AUX430->(DbGotop())
	While !AUX430->(EOF())
		nCntAx++
		AUX430->(dbSkip())
	EndDo

	If nCntAx == 1

		SB1->(dbSetOrder(1))
		If	U_CODNOVO(cRef,4) == '000000'
			If SB1->(dbSeek(xFilial("SB1")+cRef))
				Help( ,, 'Help',, "Tecido existe no cadastro de produtos. Não é possível a exclusão !!!", 1, 0 )
				lRet := .F.
			EndIf
		ElseIf SB1->(dbSeek(xFilial("SB1")+IIF(Left(cRef,1)=="F","T","Q")+Substr(cRef,2,29)))
			Help( ,, 'Help',, "Tecido "+RTrim(SB1->B1_COD)+" existe no cadastro de produtos. Não é possível a exclusão !!!", 1, 0 )
			lRet := .F.
		EndIf

	EndIf

	If	nCntAx == 1

		If (Select("AUX430") <> 0)
			AUX430->(dbCloseArea())
		EndIf

		BeginSql Alias "AUX430"
		SELECT G1_COD
		FROM %Table:SG1%
		WHERE G1_FILIAL = %xFilial:SG1% AND %NotDel%
		AND ( G1_COMP = %Exp:cRef% OR G1_COMP = %Exp:cTecAux% )
		EndSql

		AUX430->(dbGoTop())
		While !AUX430->(EOF())
			Help( ,, 'Help',, "Este artigo esta amarrado na estrutura do produto "+RTrim(AUX430->G1_cod)+". Não é possível a exclusão !!!", 1, 0 )
			RestArea(aSegZZA)
			Return (lRet := .F.)
		EndDo

	EndIf

	RestArea(aSegZZA)

Return lRet

// Funcao para criação de Variáveis de memória públicas
Static Function B430CriaVa(lInc,cStack)

	Local aArea   	:= GetArea()
	Local aAreaSX3	:= SX3->(GetArea())
	//Local nX    	:= 0
	Local cAlias  	:= "ZZA"
	Local cCampo, cCpo, x

	DEFAULT __HasSNPrvt := FindFunction('_SETNAMEDPRVT')

	If ( cStack != NIL ) .And. ( ! __HasSNPrvt )
		UserException( 'Cannot find function _SetNamedPrvt' )
	EndIf

	dbSelectArea(cAlias)

	// Criacao das variaveis de memória de tela
	For	x:=1 To Len(aCampos)

		cCampo	 := aCampos[x,1]
		If	('ZZA_FIOTR/ZZA_NFITR' $ AllTrim(cCampo))
			//cCpo := FWFldGet(cCampo,0,oModel,.T. )
			Loop
		ElseIf	lGravar
			cCpo := aCampos[x,2]
		ElseIf ( lInc )
			cCpo := CriaVar(cCampo,.T.)
		Else
			cCpo := &(cAlias+"->"+cCampo)
		EndIf

		If ( cStack == NIL )
			_SetOwnerPrvt(cCampo, cCpo)
		Else
			_SetNamedPrvt(cCampo, cCpo, cStack)
		EndIf

	Next x

	lEspecie := .T.
	/*
	nPESOPERC := 0
	If Substr(oZZA:GetValue( 'ZZA_PRODUT' ),1,1) == "T"
	nPESOPERC := oZZA:GetValue( 'ZZA_PESOUN' )
	If 	oZZA:GetValue( 'ZZA_TIPO' ) == "V"
	nPESOPERC := nPESOPERC * 1.15
	EndIf
	ElseIf Substr(oZZA:GetValue( 'ZZA_PRODUT' ),1,1) == "R"
	nPESOPERC := oZZA:GetValue( 'ZZA_PESOLN' )
	EndIf
	nPESOPERC := nPESOPERC / 1000

	nUCPERC 	:= (M->ZZA_PESUC  / nPESOPERC) * 100
	nUB1PERC	:= (M->ZZA_PESUB1 / nPESOPERC) * 100
	nUB2PERC	:= (M->ZZA_PESUB2 / nPESOPERC) * 100
	nTRPERC		:= (M->ZZA_PESTR  / nPESOPERC) * 100
	*/
	RestArea(aAreaSX3)
	RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³B430DispFiosºAutor  ³ Marcos A. Schoeffelº Data ³  15/09/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para manutenção dos dados da Disposição de Fios         º±±
±±º          ³ para o Artigo posicionado no Tipo de Máquina.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function B430DispFios(oView)

	Local lConfirma := .F.								// Variável para controlar se o usuário clicou em OK
	Local aButtons  := {}								// Array com os botões exibidos na EnchoiceBar
	Local aSize 	:= FWGetDialogSize( oMainWnd )
	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local lUB2		:= lHabilUB2
	Local lUC2		:= lHabilUC2

	Local x 		:= 0

	Local aItemEsp  := {"","S=Sim","N=Não"}

	//Local cEspeUC := "", /*cEspxUC := "",*/ /*cEspeUC1,*//* xEspxUC1,*//* cEspeUB := "", /*cEspxUB := "",*/ cEspxB2 := "", /*cEspeB2 := "",*/	cEspxTr := "", /*cEspeTr := "",*/ cEspxUC2 := "", cEspUC2 := ""

	Private lVisualiz := (oView:GetOperation() == MODEL_OPERATION_VIEW)
	Private lExclusao := (oView:GetOperation() == MODEL_OPERATION_DELETE)

	Static oTelaDisp

	If	lExclusao
		lVisualiz := .T.
	EndIf

	// Funcao para criação de Variáveis de memória públicas
	B430CriaVa((oView:GetOperation()==MODEL_OPERATION_INSERT),)
	// Armazenamento das variaveis de memória da tela em vetor a ser gravado posteriormente na tabela ZZA

	For	x:=1 To Len(aCampos)

		cCampo	 := aCampos[x,1]
		cVar := 'M->'+cCampo
		aCampos[x,2] := &(cVar)

	Next x

	nPESOPERC := 0
	If Substr(oZZA:GetValue( 'ZZA_PRODUT' ),1,1) == "T"
		nPESOPERC := oZZA:GetValue( 'ZZA_PESOUN' )
		If 	oZZA:GetValue( 'ZZA_TIPO' ) == "V"
			nPESOPERC := nPESOPERC * 1.15
		EndIf
	ElseIf Substr(oZZA:GetValue( 'ZZA_PRODUT' ),1,1) == "R"
		nPESOPERC := oZZA:GetValue( 'ZZA_PESOLN' )
	EndIf
	nPESOPERC := nPESOPERC / 1000

	nUCPERC	:= (M->ZZA_PESUC  / nPESOPERC) * 100
	nUCPERC1:= (M->ZZA_PESUC1 / nPESOPERC) * 100
	nUB1PERC:= (M->ZZA_PESUB1 / nPESOPERC) * 100
	nUB2PERC:= (M->ZZA_PESUB2 / nPESOPERC) * 100
	nTRPERC	:= (M->ZZA_PESTR  / nPESOPERC) * 100
	nMOPERC	:= ((nUCPERC * M->ZZA_NFIUC2) / M->ZZA_NFIUC)

	lHabilUB2 := IIf(!lHabilUB2.And.!lVisualiz.And.!Empty(M->ZZA_TITUB2),.T.,.F.)
	lHabilUC2 := IIf(!lHabilUC2.And.!lVisualiz.And.(oZZA:GetValue('ZZA_QTDUC')=='2'),.T.,.F.)

	/* 	Logica Incluido por Valdecir em 23.05.06
	Foi necessario incluir a logica abaixo, pois quando acontece alteracao na Chapas Corpo, o programa
	deve recalcular o valor do Nro. de Fios da Trama.
	*/
	If	(oView:GetOperation()==MODEL_OPERATION_INSERT) .Or. (oZZA:GetValue('ZZA_QTDUC') != '2')

		If FWFldGet('ZZA_CHAPAC',0,oModel,.T. ) /*nCHAPAC*/ <> 0
			M->ZZA_NFITR := FWFldGet('ZZA_CHAPAC',0,oModel,.T. ) + FWFldGet('ZZA_CHAPAB',0,oModel,.T. ) // nCHAPAC + nCHAPAB
			M->ZZA_NFITR := M->ZZA_NFITR * FWFldGet('ZZA_NBAT',0,oModel,.T. ) // nNFITR * nNBAT
		Else
			M->ZZA_NFITR := M->ZZA_FIOTR * 100 //nFIOTR * 100
		EndIf

		M->ZZA_NFIUC 	:= FWFldGet('ZZA_TFIOUC',0,oModel,.T. )  / FWFldGet('ZZA_UNIDLA',0,oModel,.T. ) // (nTFIOUC / nUNIDLA)
		M->ZZA_NFIUB1 	:= FWFldGet('ZZA_TFIOUB',0,oModel,.T. )  / FWFldGet('ZZA_UNIDLA',0,oModel,.T. ) // (nTFIOUB / nUNIDLA)

	EndIf

	cTitDisp:="Ficha Tecnica - Disposicao / Tipos de Fios"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada do comando browse                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oTelaDisp := TDialog():New(aSize[1],aSize[2],aSize[3]*.4,aSize[4]*.4,cTitDisp,,,,,,,,oMainWnd/*oWnd*/,.T.,,,,aSize[4]*.62,aSize[3]*.64)
	oTelaDisp:lEscClose := .F.
	oTelaDisp:lCentered := .T.

	oPnlSep   := TPanel():New(32,0,"",oTelaDisp,,,,,,115,90,.T.,.T.)
	oPnlSep:Align := CONTROL_ALIGN_TOP
	oPnlSep:nHeight := 3

	oGrp1 := TGroup():New(32,01,190,aSize[4]*.3,'',oTelaDisp,,,.T.)
	oGrp2 := TGroup():New(34,03,069,aSize[4]*.298,'',oTelaDisp,,,.T.)

	@ 038,008 Say "Observação" SIZE 40,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 036,045 MsGet oObserv Var M->ZZA_OBSERV Picture "@!" When !lVisualiz SIZE 300,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	@ 054,008 Say "1a. Cor " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 052,045 MsGet oDispc1 Var M->ZZA_DISPC1 Picture "@!" F3 "ZAN" When !lVisualiz Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	@ 054,090 Say "2a. Cor " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 052,125 MsGet oDispc2 Var M->ZZA_DISPC2 Picture "@!" F3 "ZAN" When !lVisualiz Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	@ 054,170 Say "3a. Cor " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 052,205 MsGet oDispc3 Var M->ZZA_DISPC3 Picture "@!" F3 "ZAN" When !lVisualiz Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	@ 054,250 Say "4a. Cor " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 052,285 MsGet oDispc4 Var M->ZZA_DISPC4 Picture "@!" F3 "ZAN" When !lVisualiz Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	oGrp3 := TGroup():New(71,03,181,aSize[4]*.298,'',oTelaDisp,,,.T.)

	@ 076,005 Say "Tipo Fio" SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,043 Say "Titulo  " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,081 Say "Fios/Cm " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,119 Say "No. Fios" SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,157 Say "Peso    " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,199 Say "%       " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,233 Say "Cor     " SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,271 Say "Mat.Prima" SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,312 Say "Tipo Fio" SIZE 30,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 076,350 Say "Específico?" SIZE 40,10 COLOR CLR_HRED OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Informações de 1 Urdume de Cima
	@ 089,005 Say  "U.C.1  " SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,043 MsGet oTituc Var M->ZZA_TITUC Picture PesqPict("ZZA","ZZA_TITUC") When !lVisualiz Valid VldTit() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,081 MsGet oFiouc Var M->ZZA_FIOUC Picture PesqPict("ZZA","ZZA_FIOUC") When !lVisualiz Valid VldFio() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,119 MsGet oNfiuc Var M->ZZA_NFIUC Picture PesqPict("ZZA","ZZA_NFIUC") When !lVisualiz Valid VldNFi() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,157 MsGet oPesuc Var M->ZZA_PESUC Picture PesqPict("ZZA","ZZA_PESUC") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,195 MsGet oUcperc Var nUCPERC Picture "@E 99.9999" SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oUcPerc:bHelp := { || ShowHelpCpo("nUCPERC", {"Campo utilizado para informação do % do Urdume de Cima na Composição do Tecido"},5,{},0) }
	oUcPerc:cToolTip := 'CALCULADO'
	If	lVisualiz
		oUcPerc:bWhen := {|| .F. }
	Else
		oUcPerc:lReadOnly := .T.
	EndIf
	@ 089,233 MsGet oCoruc Var M->ZZA_CORUC Picture PesqPict("ZZA","ZZA_CORUC") F3 "ZAN" When !lVisualiz Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,271 MsGet oMpuc Var M->ZZA_MPUC Picture PesqPict("ZZA","ZZA_MPUC") When !lVisualiz SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,312 MsGet oTFioc Var M->ZZA_TFIOC Picture PesqPict("ZZA","ZZA_TFIOC") F3 "MZ2"  When !lVisualiz Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 089,350 MSCOMBOBOX oEspUC Var M->ZZA_ESPEUC ITEMS aItemEsp When !lVisualiz SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Informações de 2 Urdume de Cima
	If	oZZA:GetValue('ZZA_QTDUC')=='1'
		M->ZZA_TITUC1 := Space(TamSx3('ZZA_TITUC1')[1])
		M->ZZA_FIOUC1 := 0
		M->ZZA_NFIUC1 := 0
		M->ZZA_PESUC1 := 0
		nUCPERC1 := 0
		M->ZZA_CORUC1 := Space(TamSx3('ZZA_CORUC1')[1])
		M->ZZA_MPUC1  := Space(TamSx3('ZZA_MPUC1')[1])
		M->ZZA_TFIOC1 := Space(TamSx3('ZZA_TFIOC1')[1])
		M->ZZA_ESPUC1 := Space(TamSx3('ZZA_ESPUC1')[1])
	EndIf

	@ 104,005 Say  "U.C.2  " SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,043 MsGet oTituc1 Var M->ZZA_TITUC1 Picture PesqPict("ZZA","ZZA_TITUC1") When lHabilUC2 Valid VldTit() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,081 MsGet oFiouc1 Var M->ZZA_FIOUC1 Picture PesqPict("ZZA","ZZA_FIOUC1") When lHabilUC2 Valid VldFio() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,119 MsGet oNfiuc1 Var M->ZZA_NFIUC1 Picture PesqPict("ZZA","ZZA_NFIUC1") When lHabilUC2 Valid VldNFi() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,157 MsGet oPesuc1 Var M->ZZA_PESUC1 Picture PesqPict("ZZA","ZZA_PESUC1") When lHabilUC2 SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,195 MsGet oUcperc1 Var nUCPERC1 Picture "@E 99.9999" SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oUcPerc1:bHelp := { || ShowHelpCpo("nUCPERC1", {"Campo utilizado para informação do % do Urdume de Cima na Composição do Tecido"},5,{},0) }
	oUcPerc1:cToolTip := 'CALCULADO'
	If	lVisualiz .Or. !lHabilUC2
		oUcPerc1:bWhen := {|| .F. }
	Else
		oUcPerc1:lReadOnly := .T.
	EndIf
	@ 104,233 MsGet oCoruc1 Var M->ZZA_CORUC1 Picture PesqPict("ZZA","ZZA_CORUC1") F3 "ZAN" When lHabilUC2 Valid (Vazio() .Or. ExistCpo('ZAN')) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,271 MsGet oMpuc1 Var M->ZZA_MPUC1 Picture PesqPict("ZZA","ZZA_MPUC1") When lHabilUC2 SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,312 MsGet oTFioc1 Var M->ZZA_TFIOC1 Picture PesqPict("ZZA","ZZA_TFIOC1") F3 "MZ2"  When lHabilUC2 Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 104,350 MSCOMBOBOX oEspUC1 Var M->ZZA_ESPUC1 ITEMS aItemEsp When lHabilUC2 SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Informaçõoes do 1 Urdume de Baixo
	@ 119,005 Say  "U.B.1  " SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,043 MsGet oTitub1 Var M->ZZA_TITUB1 Picture PesqPict("ZZA","ZZA_TITUB1") When !lVisualiz Valid VldTit() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,081 MsGet oFioub1 Var M->ZZA_FIOUB1 Picture PesqPict("ZZA","ZZA_FIOUB1") When !lVisualiz Valid VldFio()SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,119 MsGet oNfiub1 Var M->ZZA_NFIUB1 Picture PesqPict("ZZA","ZZA_NFIUB1") When !lVisualiz Valid VldNfi() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,157 MsGet oPesub1 Var M->ZZA_PESUB1 Picture PesqPict("ZZA","ZZA_PESUB1") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,195 MsGet oUb1perc Var nUB1PERC Picture "@E 99.9999" SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oUb1Perc:bHelp := { || ShowHelpCpo("nUB1PERC", {"Campo utilizado para informação do % do Urdume de Baixo na Composição do Tecido"},5,{},0) }
	oUb1Perc:cToolTip := 'CALCULADO'
	If	lVisualiz
		oUb1Perc:bWhen := {|| .F. }
	Else
		oUb1Perc:lReadOnly := .T.
	EndIf
	@ 119,233 MsGet oCorub1 Var M->ZZA_CORUB1 Picture PesqPict("ZZA","ZZA_CORUB1") F3 "ZAN" When !lVisualiz Valid VldCor() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,271 MsGet oMpub1 Var M->ZZA_MPUB1 Picture PesqPict("ZZA","ZZA_MPUB1") When !lVisualiz SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,312 MsGet oTfiob Var M->ZZA_TFIOB Picture PesqPict("ZZA","ZZA_TFIOB") F3 "MZ2" When !lVisualiz Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 119,350 MSCOMBOBOX oEspUB Var M->ZZA_ESPEUB ITEMS aItemEsp When !lVisualiz SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Informações do 2 Urdume de Baixo
	@ 134,005 Say  "U.B.2  " SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,043 MsGet oTitub2 Var M->ZZA_TITUB2 Picture PesqPict("ZZA","ZZA_TITUB2") When lHabilUB2 Valid VldTit() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,081 MsGet oFioub2 Var M->ZZA_FIOUB2 Picture PesqPict("ZZA","ZZA_FIOUB2") When lHabilUB2 Valid VldFio() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,119 MsGet oNfiub2 Var M->ZZA_NFIUB2 Picture PesqPict("ZZA","ZZA_NFIUB2") When lHabilUB2 Valid VldNFi() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,157 MsGet oPesub2 Var M->ZZA_PESUB2 Picture PesqPict("ZZA","ZZA_PESUB2") When lHabilUB2 SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,195 MsGet oUb2perc Var nUB2PERC Picture "@E 99.9999" SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oUb2Perc:bHelp := { || ShowHelpCpo("nUB2PERC", {"Campo utilizado para informação do % do Urdume de Baixo na Composição do Tecido"},5,{},0) }
	oUb2perc:cToolTip := 'CALCULADO'
	If	lVisualiz .Or. !lHabilUB2
		oUb2Perc:bWhen := {|| .F. }
	ElseIf	lHabilUB2
		oUb2Perc:lReadOnly := .T.
	EndIf
	@ 134,233 MsGet oCorub2 Var M->ZZA_CORUB2 Picture PesqPict("ZZA","ZZA_CORUB2") F3 "ZAN" When lHabilUB2 Valid VldCor() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,271 MsGet oMpub2 Var M->ZZA_MPUB2 Picture PesqPict("ZZA","ZZA_MPUB2") When lHabilUB2 SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,312 MsGet oTfiob2 Var M->ZZA_TFIOB2 Picture PesqPict("ZZA","ZZA_TFIOB2") F3 "MZ2" When lHabilUB2 Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 134,350 MSCOMBOBOX oEspeB2 Var M->ZZA_ESPEB2 ITEMS aItemEsp When lHabilUB2 SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Informações das Tramas
	@ 149,005 Say  "TRAMA " SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,043 MsGet oTittr Var M->ZZA_TITTR Picture PesqPict("ZZA","ZZA_TITTR") When !lVisualiz Valid VldTit() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,081 MsGet oFiotr Var M->ZZA_FIOTR Picture PesqPict("ZZA","ZZA_FIOTR") When !lVisualiz Valid VldFio() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,119 MsGet oNfitr Var M->ZZA_NFITR Picture PesqPict("ZZA","ZZA_NFITR") When !lVisualiz Valid VldNFi() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,157 MsGet oPestr Var M->ZZA_PESTR Picture PesqPict("ZZA","ZZA_PESTR") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,195 MsGet oTrperc Var nTRPERC Picture "@E 99.9999" /*When !lVisualiz*/ SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oTrPerc:bHelp := { || ShowHelpCpo("nTRPERC", {"Campo utilizado para informação do % das Tramas na Composição do Tecido"},5,{},0) }
	oTrPerc:cToolTip := 'CALCULADO'
	If	lVisualiz
		oTrPerc:bWhen := {|| .F. }
	Else
		oTrPerc:lReadOnly := .T.
	EndIf
	@ 149,233 MsGet oCortr Var M->ZZA_CORTR Picture PesqPict("ZZA","ZZA_CORTR") F3 "ZAN" When !lVisualiz Valid VldCor() SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,271 MsGet oMptr Var M->ZZA_MPTR Picture PesqPict("ZZA","ZZA_MPTR") When !lVisualiz SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,312 MsGet oTfiotr Var M->ZZA_TFIOTR Picture PesqPict("ZZA","ZZA_TFIOTR") F3 "MZ2" When !lVisualiz Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 149,350 MSCOMBOBOX oEspTr Var M->ZZA_ESPETR ITEMS aItemEsp When !lVisualiz SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	// Alan - Tratamento do Fio Modal no Urdume de Cima
	@ 164,005 Say  "U.C. Modal" SIZE 40,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 164,043 MsGet oTituc2 Var M->ZZA_TITUC2 Picture PesqPict("ZZA","ZZA_TITUC2") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 164,119 MsGet oNfiuc2 Var M->ZZA_NFIUC2 Picture PesqPict("ZZA","ZZA_NFIUC2") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 164,157 MsGet oPesuc2 Var M->ZZA_PESUC2 Picture PesqPict("ZZA","ZZA_PESUC2") When !lVisualiz SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	@ 164,233 MsGet oMoperc Var nMOPERC Picture "@E 99.9999" /*When !lVisualiz*/ SIZE 30,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	oMoPerc:bHelp := { || ShowHelpCpo("nMOPERC", {"Campo utilizado para informação do % do Modal na Composição do Tecido"},5,{},0) }
	oMoPerc:cToolTip := 'CALCULADO'
	If	lVisualiz
		oMoPerc:bWhen := {|| .F. }
	Else
		oMoPerc:lReadOnly := .T.
	EndIf

	@ 164,312 MsGet oTfioc2 Var M->ZZA_TFIOC2 Picture PesqPict("ZZA","ZZA_TFIOC2") F3 "MZ2" When !lVisualiz Valid (Vazio().or.ExistCpo("ZA2")) SIZE 20,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE
	@ 164,350 MSCOMBOBOX oEspUC2 Var M->ZZA_ESPUC2 ITEMS aItemEsp When !lVisualiz SIZE 35,10 COLOR CLR_BLACK OF oTelaDisp PIXEL COLOR CLR_BLUE

	ACTIVATE DIALOG oTelaDisp CENTERED ON INIT EnchoiceBar( oTelaDisp, { || ( lConfirma := B430Fecha(), IIf(lConfirma,oTelaDisp:End(),) ) }, { || ( lConfirma := .F., oTelaDisp:End() ) },, aButtons )

	If lConfirma .And. !lVisualiz
		cVarAux   := __ReadVar

		__ReadVar := 'M->ZZA_NFIUB1'
		VldNfi()

		__ReadVar := 'M->ZZA_NFITR'
		VldFio()

		__ReadVar := cVarAux

		Processa({|| B430Atualiza(), 'Aguarde Atualizando Dados da Ficha Técnica ...' })
	EndIf

	lHabilUB2 := lUB2
	lHabilUC2 := lUC2

Return

Static Function B430Fecha()

	Local lRet 	:= .T.
	Local oModel:= FWMODELACTIVE()
	Local oZZA 	:= oModel:GetModel("ZZAMASTER")

	If	oZZA:GetValue('ZZA_QTDUC') == '2' .And. Empty(M->ZZA_TITUC1)
		Help( ,, 'Help',, "Este artigo está setado para utilizar DOIS Títulos de URDUME DE CIMA, é necessário preenche-los !!!", 1, 0 )
		lRet := .F.
	EndIf

Return lRet

Static Function B430Atualiza()

	Local oModel 	:= FWMODELACTIVE()
	Local oView  	:= FWVIEWACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")
	Local oU00		:= oModel:GetModel("U00DETAIL")

	Local nTamBl, nTamCp, nBarraL, nTrb, nTrIros, nX, nCompTe, nLargTe, nComp1, nLargUc, nLargUb, nValor, nMult	:= 0
	Local nPesol, nPesoLn := 0
	Local var1, var2, var3, var4, /*var5,*/ var6, var7, v1, nub, nub1, nub2 := 0
	Local nPeso, nComp, p1Tit1, p2Tit1, divub1, divub2, p1Tit2, p2Tit2, p1tit, p2tit, divtr := 0
	Local vpesoi, ntr, ntrpesaux, nQtdTram, nResTra := 0
	Local lPesTr := .F.

	Local  x := 0

	nTambl := 0
	If oZZA:GetValue('ZZA_CHAPAB') <> 0
		nTamBl := (oZZA:GetValue('ZZA_CHAPAB') * oZZA:GetValue('ZZA_NBAT') ) / M->ZZA_FIOTR
	EndIf

	nBARRAL 	:= nTamBl

	nTamcp := 0
	If oZZA:GetValue('ZZA_CHAPAC') <> 0
		nTamcp 	:= (oZZA:GetValue('ZZA_CHAPAC') * oZZA:GetValue('ZZA_NBAT') ) / M->ZZA_FIOTR
	EndIf

	nTrb		:= 0
	nTriros		:= 0
	For nX := 1 To oU00:Length()
		oU00:GoLine( nX )
		If (oU00:GetValue("U00_CORPO") <> "S") .And. !oU00:IsDeleted()
			nTriros += Round(oU00:GetValue("U00_QTDFIO") / oU00:GetValue("U00_FIOSBA"),4)
		EndIf
	Next nX

	nTrb := nTriros

	nBARRAL += nTrb
	oZZA:SetValue('ZZA_BARRAL', Round(nBARRAL,TamSx3('ZZA_BARRAL')[1]) )

	nCOMPTE := nBARRAL + nTamcp
	oZZA:SetValue('ZZA_COMPTE', Round(nCOMPTE,TamSx3('ZZA_COMPTE')[1]) )
	If 	oZZA:GetValue('ZZA_PRODUT') == "R"
		nCOMPTE := 100
		oZZA:SetValue('ZZA_COMPTE', Round(nCOMPTE,TamSx3('ZZA_COMPTE')[1]) )
	EndIf

	nLARGTE := M->ZZA_NFIUC / M->ZZA_FIOUC + oZZA:GetValue('ZZA_OURELA')

	// Novo Cálculo UC 2
	If	oZZA:GetValue('ZZA_QTDUC') == '2'
		nLARGTE += (M->ZZA_NFIUC1 / M->ZZA_FIOUC1)
	EndIf
	// Fim

	oZZA:SetValue('ZZA_LARGTE', Round(nLargTe,TamSx3('ZZA_LARGTE')[1]) )

	If 	oZZA:GetValue('ZZA_PRODUT') == "T"
		Var1 	:= M->ZZA_NFITR / M->ZZA_FIOTR
		Var2 	:= Var1 + nTrb
		nComp1	:= Var2 * 1.03
	Else
		nComp1	:= nCOMPTE - NBARRAL
	EndIf

	nLARGUC := M->ZZA_TFIOUC / M->ZZA_FIOUC
	oZZA:SetValue('ZZA_LARGUC', Round(nLARGUC,TamSx3('ZZA_LARGUC')[1]))

	If oZZA:GetValue('ZZA_PRODUT') == "T" //.AND. AllTrim(oZZA:GetValue('ZZA_ESPECI')) != 'MACRAME'
		Do Case
			Case oZZA:GetValue('ZZA_OURELA') == 4.4
			nValor := 48
			Case oZZA:GetValue('ZZA_OURELA') == 5.1
			nValor := 56
			Otherwise
			nValor := 72
		EndCase
		nMult := 0
		If oZZA:GetValue('ZZA_UNIDLA') > 1
			nMult := oZZA:GetValue('ZZA_UNIDLA') - 1
			nMult := nValor * nMult
		EndIf
		nLARGUC := oZZA:GetValue('ZZA_LARGUC') + (nMult / M->ZZA_FIOUB1)
		oZZA:SetValue('ZZA_LARGUC', Round(nLARGUC,TamSx3('ZZA_LARGUC')[1]) )
	EndIf

	//If 	!(AllTrim(oZZA:GetValue('ZZA_ESPECI')) $ "COLCHA/MACRAME")
	If 	AllTrim(oZZA:GetValue('ZZA_ESPECI')) <> "COLCHA"
		nLARGUB := nLARGUC + 5
		oZZA:SetValue('ZZA_LARGUB', Round(nLARGUB,TamSx3('ZZA_LARGUB')[1]) )
	Else
		nLARGUB := nLARGUC
		oZZA:SetValue('ZZA_LARGUB', Round(nLARGUB,TamSx3('ZZA_LARGUB')[1]) )
	EndIf

	If 	oZZA:GetValue('ZZA_PRODUT') == "R"
		npesol := oZZA:GetValue('ZZA_PESOMT')
		If 	oZZA:GetValue('ZZA_TIPO') == "V"
			nPesol := oZZA:GetValue('ZZA_PESOMT') * 1.15
		EndIf

		Do Case
			Case cTpMq == "B"
			npesol := npesol / 1.21688
			Case cTpMq == "A"
			npesol := npesol / 1.2508
		EndCase
		v1 := Int(nLARGUC + 0.5)
		nPesoLn := (npesol * v1) / 100
		oZZA:SetValue('ZZA_PESOLN', nPesoLn )
	EndIf

	Do Case
		Case oZZA:GetValue('ZZA_PRODUT') == "T"
		npeso := oZZA:GetValue('ZZA_PESOUN')
		If 	oZZA:GetValue('ZZA_TIPO') == "V"
			npeso := npeso * 1.15
		EndIf
		Case oZZA:GetValue('ZZA_PRODUT') == "R"
		npeso := oZZA:GetValue('ZZA_PESOLN')
	EndCase

	// Cálculo de Peso para Urdume de Baixo
	npeso 	:= npeso / 1000
	ncomp	:= nComp1 / 100
	p1tit1	:= Substr(M->ZZA_TITUB1,1,2)
	p2tit1 	:= Substr(M->ZZA_TITUB1,4,2)
	//divub1 	:= 1
	p1tit2	:= Substr(M->ZZA_TITUB2,1,1)
	p2tit2	:= Substr(M->ZZA_TITUB2,4,1)
	divub1	:= 1
	divub2	:= 1
	nub1	:= 0
	nub2	:= 0

	If 	Val(p2tit1) != 0
		divub1 := Val (p1tit1) / Val(p2tit1) * 1000
	endif

	If 	Val(p2tit2) != 0
		divub2 := Val (p1tit2) / Val(p2tit2) * 1000
	endif

	If oZZA:GetValue('ZZA_PRODUT') == "T"
		nub1 := M->ZZA_NFIUB1 * nComp * 0.59
		nub1 := nub1 / divub1
		if M->ZZA_NFIUB2 > 0
			nub2 := M->ZZA_NFIUB2 * nComp * 0.59
			nub2 := nub2 / divub2
		endif
	else
		nub1 := M->ZZA_NFIUB1 * 0.59
		nub1 := nub1 / divub1
		if M->ZZA_NFIUB2 > 0
			nub2 = M->ZZA_NFIUB2 * 0.59
			nub2 = nub2 / divub2
		endif
	endif

	// Calculo de Peso para Tramas
	p1tit := substr (M->ZZA_TITTR, 1, 2)
	p2tit := substr (M->ZZA_TITTR, 4, 1)
	divtr := 1
	if 	val (p2tit) != 0
		divtr := val (p1tit) / val (p2tit) * 1000
	endif

	vpesoi 		:= 0
	ntr 		:= 0
	ntrpesaux	:= 0
	lPesTr		:= .F.

	nQtdTram:= 0
	For nX := 1 To oU00:Length()
		oU00:GoLine( nX )
		If (Empty(oU00:GetValue("U00_QTDFIO")) .And. oU00:GetValue("U00_CORPO") == "S") .And. !oU00:IsDeleted()
			nQtdTram++
		EndIf
	Next nX

	nResTra := IIf(nQtdTram > 0, Mod(M->ZZA_NFITR, nQtdTram),0)

	For nX := 1 To oU00:Length()

		oU00:GoLine( nX )

		If	oU00:IsDeleted()
			Loop
		EndIf

		p1tit := Substr(oU00:GetValue("U00_TITFIO"),1,2)
		p2tit := Substr(oU00:GetValue("U00_TITFIO"),4,1)
		If 	!Empty(oU00:GetValue("U00_COR"))
			If 	Empty(oU00:GetValue("U00_QTDFIO")) .And. (oU00:GetValue("U00_CORPO") == "S")
				oU00:SetValue("U00_QTDFIO", IIf(nQtdTram > 0,(M->ZZA_NFITR / nQtdTram) + nResTra,M->ZZA_NFITR))
				nRestra := 0
			EndIf

			If	Empty(oU00:GetValue("U00_FIOSBA")) .And. (oU00:GetValue("U00_CORPO") == "S")
				oU00:SetValue("U00_FIOSBA", M->ZZA_FIOTR)
			EndIf

			If 	oU00:GetValue("U00_CORPO") == "S"
				lPesTr		:= .T.
			EndIf

			If !Empty(oU00:GetValue("U00_QTDFIO"))

				var1 := oU00:GetValue("U00_QTDFIO")
				var2 := val(p1tit) / val(p2tit)

				If 	oZZA:GetValue('ZZA_PRODUT') == "R"
					var3 := (oZZA:GetValue('ZZA_LARGUB') * 1.03) / 100
					var6 := Int(oZZA:GetValue('ZZA_LARGUC') + 0.5) / 100
				Else
					var3 := (oZZA:GetValue('ZZA_LARGTE') * 1.01) / 100
					var6 := oZZA:GetValue('ZZA_LARGTE') / 100
				EndIf

				var4 := var1 * var3 * 0.59
				var7 := var1 * var6 * 0.59
				If oU00:GetValue('U00_CORPO') <> "S"
					vpesoi	:= vpesoi + var7 / var2
				EndIf

				oU00:SetValue('U00_PESO', Round((var4 / var2) / 1000,4))
				ntr += oU00:GetValue('U00_PESO')

				If 	lPesTr
					ntrpesaux += oU00:GetValue('U00_PESO')
				EndIf

			EndIf
			lPesTr := .F.

		EndIf
	Next nX

	nub := nub1 + nub2

	M->ZZA_PESUB1 	:= nub1

	npub 			:= Round((nub1 / npeso) * 100,4)
	M->ZZA_PESUB2 	:= Round(nub2,TamSx3('ZZA_PESUB2')[1])

	npub 			:= Round((nub2 / npeso) * 100,4)
	M->ZZA_PESTR	:= Round(ntrpesaux,TamSx3('ZZA_PESTR')[1])
	//M->ZZA_ptr		:= Round((ntr / npeso) * 100,TamSx3('ZZA_PTR')[1])

	// Criado cálculo de proporção para peso UC 2
	If	oZZA:GetValue('ZZA_QTDUC') == '2'
		c1Tituc := Substr(M->ZZA_TITUC,1,2)
		c2Tituc := Substr(M->ZZA_TITUC,4,1)
		If 	val(c2Tituc) <> 0
			nDivUc := val(c1Tituc) / val(c2Tituc)
		Else
			nDivUc := val(c1Tituc)
		EndIf

		c1Tituc1 := Substr(M->ZZA_TITUC1,1,2)
		c2Tituc1 := Substr(M->ZZA_TITUC1,4,1)
		If 	val(c2Tituc1) <> 0
			nDivUc1 := val(c1Tituc1) / val(c2Tituc1)
		Else
			nDivUc1 := val(c1Tituc1)
		EndIf

		nPesUc := Round((0.59 / nDivUc ) * M->ZZA_NFIUC ,4)
		nPesUc1:= Round((0.59 / nDivUc1) * M->ZZA_NFIUC1,4)

		nTotUc  := (nPesUc + nPesUc1)
		M->ZZA_PESUC  := Round((npeso - nub - ntr) * (nPesUc  / nTotUc),TamSx3('ZZA_PESUC')[1])
		M->ZZA_PESUC1 := Round((npeso - nub - ntr) * (nPesUc1 / nTotUc),TamSx3('ZZA_PESUC1')[1])
	Else
		M->ZZA_PESUC 	:= npeso - nub - ntr
		M->ZZA_PESUC1	:= 0
	EndIf

	npesobl		:= 0
	p1tituc 	:= Substr(M->ZZA_TITUC,1,2)
	p2tituc 	:= Substr(M->ZZA_TITUC,4,1)

	nUCPERC 	:= Round((M->ZZA_PESUC  / npeso) * 100,4)
	nUCPERC1 	:= Round((M->ZZA_PESUC1 / npeso) * 100,4)
	nUB1PERC	:= Round((M->ZZA_PESUB1 / npeso) * 100,4)
	nUB2PERC	:= Round((M->ZZA_PESUB2 / npeso) * 100,4)
	nTRPERC 	:= Round((M->ZZA_PESTR  / npeso) * 100,4)
	nMOPERC	  	:= Round(((nUCPERC * M->ZZA_NFIUC2) / M->ZZA_NFIUC),4)

	If 	oZZA:GetValue('ZZA_BARRAL') <> 0
		var1 	:= (oZZA:GetValue('ZZA_BARRAL') * 0.59) * (M->ZZA_NFIUC + M->ZZA_NFIUC1)
		div 	:= 1
		If 	val(p2tituc) <> 0
			div := val(p1tituc) / val(p2tituc)
		EndIf
		var2	:= 100 * div * 1000
		npesobl := Round(var1 / var2,4)
	EndIf

	nub5	:= nub
	ntr2	:= ntr
	If 	cTpMq == "A"
		var15 := oZZA:GetValue('ZZA_COMPTE') / 100
		If oZZA:GetValue('ZZA_PRODUT') == "R"
			nub5 := (M->ZZA_NFIUC * 0.59) * var15
		Else
			nub5 := (M->ZZA_NFIUB1 * 0.59) * var15
		EndIf
		nub5 := nub5 / divub1
		If 	oZZA:GetValue('ZZA_PRODUT') == "T"
			var10 := oZZA:GetValue('ZZA_LARGTE')
		Else
			var10 := Int(oZZA:GetValue('ZZA_LARGUC') + 0.5)
		EndIf
		ntr2 := (M->ZZA_NFITR * var10) * 0.59
		ntr2 := ntr2 / divtr
		ntr2 := Round(ntr2 / 100,4)
	EndIf

	vpesoi := vpesoi / 1000
	vpesoac:= ntr2 + nub5 + npesobl
	Do Case
		Case oZZA:GetValue('ZZA_PRODUT') == "T"
		var1 := npeso - vpesoac
		If 	ctpmq == "A"
			var1 := var1 - vpesoi
		EndIf
		Case oZZA:GetValue('ZZA_PRODUT') == "R"
		var1 := nPESOLN / 1000 - vpesoac - vpesoi
	EndCase

	var2 := val(p1tituc) / val(p2tituc)
	If 	oZZA:GetValue('ZZA_PRODUT') == "R"
		var4 := nComp1 / 100
		var3 := (0.59 * M->ZZA_NFIUC * var4) / 1000
	Else
		var4 := ntamcp / 100
		var3 := (0.59 * (M->ZZA_NFIUC + M->ZZA_NFIUC1) * var4) / 1000
	EndIf

	nALTFEL := (var1 * var2) / var3 + 0.05
	oZZA:SetValue('ZZA_ALTFEL', Round(nALTFEL,TamSx3('ZZA_ALTFEL')[1]) )

	vconst := 0
	vconsc := 0
	If oZZA:GetValue('ZZA_PRODUT') == "T"
		Do Case
			Case Alltrim(oZZA:GetValue('ZZA_FLUXO')) == "A" .OR. Alltrim(oZZA:GetValue('ZZA_FLUXO')) == "B"
			If 	oZZA:GetValue('ZZA_LARGTE') > oZZA:GetValue('ZZA_COMPTE')
				compcons := (2 * (oZZA:GetValue('ZZA_LARGUR') + 3) * 6.05) / 100
				largcons := (2 * (oZZA:GetValue('ZZA_COMPR' ) * 2.75) / 100)
			Else
				compcons := (2 * (oZZA:GetValue('ZZA_COMPR') + 3) * 6.05) / 100
				largcons := (2 * oZZA:GetValue('ZZA_LARGUR') * 2.75) / 100
			EndIf
			vconst := (compcons + largcons) / 5000
			Case U_CODNOVO(oZZA:GetValue('ZZA_REF'),4)== "000000"
			If Substr(oZZA:GetValue('ZZA_REF'),15,1) == "1"
				var1 	:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
				varx 	:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
				compcons := (varx * (oZZA:GetValue('ZZA_COMPR') + 3) * 6.05)  / oZZA:GetValue('ZZA_UNIDLA') / 100
				largcons := (oZZA:GetValue('ZZA_LARGUR') / 2 * 2.75) / 100
			Else
				If oZZA:GetValue('ZZA_LARGTE') > oZZA:GetValue('ZZA_COMPTE')
					var1 	:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					vconsc = var1 / 5000
					varx 	:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
					compcons := (varx * (oZZA:GetValue('ZZA_LARGUR') + 3) * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					largcons := (2 * oZZA:GetValue('ZZA_COMPR') * 2.75) / 100
				Else
					var1 		:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					vconsc 	:= var1 / 5000
					varx 		:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
					compcons 	:= (varx * (oZZA:GetValue('ZZA_COMPR') + 3) * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					largcons 	:= (2 * oZZA:GetValue('ZZA_LARGUR') * 2.75) / 100
				EndIf
			EndIf
			vconst := (compcons + largcons) / 5000
			Case  U_CODNOVO(oZZA:GetValue('ZZA_REF'),4) <> "000000"
			If Substr(oZZA:GetValue('ZZA_REF'),15,1) == "1"
				var1 		:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
				varx 		:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
				compcons 	:= (varx * (oZZA:GetValue('ZZA_COMPR') + 3) * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
				largcons 	:= (oZZA:GetValue('ZZA_LARGUR') / 2 * 2.75) / 100
			Else
				If oZZA:GetValue('ZZA_LARGTE') > oZZA:GetValue('ZZA_COMPTE')
					var1 		:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					varx 		:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
					compcons 	:= (varx * (oZZA:GetValue('ZZA_LARGUR') + 3) * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					largcons 	:= (2 * oZZA:GetValue('ZZA_COMPR') * 2.75) / 100
				Else
					var1 		:= (2 * oZZA:GetValue('ZZA_COMPTE') * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					varx 		:= oZZA:GetValue('ZZA_UNIDLA') * 2 - 2
					compcons 	:= (varx * (oZZA:GetValue('ZZA_COMPR') + 3) * 6.05) / oZZA:GetValue('ZZA_UNIDLA') / 100
					largcons 	:= (2 * oZZA:GetValue('ZZA_LARGUR') * 2.75) / 100
				EndIf
			EndIf
			vconst := (var1 + compcons + largcons) / 5000
		EndCase
	EndIf

	// Posicione no primeiro registro das Tramas
	oU00:GoLine(1)

	// Armazenamento das variaveis de memória da tela em vetor a ser gravado posteriormente na tabela ZZA
	For	x:=1 To Len(aCampos)

		cCampo	 := aCampos[x,1]
		cVar := 'M->'+cCampo
		If	('ZZA_FIOTR/ZZA_NFITR' $ cCampo)
			oZZA:SetValue(cCampo, &cVar )
			aCampos[x,2] := &(cVar)
		Else
			aCampos[x,2] := &(cVar)
		EndIf

	Next x

	lGravar := .T.
	oView:Refresh()

Return

Static Function B430ValZZA(oModel)

	Local oZZA			:= oModel:GetModel("ZZAMASTER")
	Local nOperation 	:= oModel:GetOperation()
	Local lRet			:= .T.

	If	!lGravar
		Help( ,, 'Help',, "Não é possível fazer a Gravação dos Dados sem que seja feito o acesso a Opção de Disponibilidade de Tipos de Fios !!!", 1, 0 )
		lRet := .F.
	EndIf

	If (nOperation == MODEL_OPERATION_UPDATE) .Or. (nOperation == MODEL_OPERATION_INSERT)
		Do Case
			Case oZZA:GetValue('ZZA_LARGUR') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Largura Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_COMPR') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Comprimento Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_PESOMT') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Peso M2 Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_TFIOUC') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Total Fio UC Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_TFIOUB') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Total Fio UB Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_CHAPAC') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Chapa Corpo Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_CHAPAB') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Barra Lisa Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_NBAT') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Batidas Felpa Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_UNIDLA') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Unidade Largura Toalha) !!!", 1, 0 )
			lRet := .F.
			Case Empty(oZZA:GetValue('ZZA_FLUXO')) .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Fluxo Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_OURELA') == 0 .And. Substr(oZZA:GetValue('ZZA_PRODUT'),1,1) == "T"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Ourela Toalha) !!!", 1, 0 )
			lRet := .F.
			Case oZZA:GetValue('ZZA_PERTOS') == 0 .And. Substr(oZZA:GetValue('ZZA_REF'),1,1) == "V"
			Help( ,, 'Help',, "Campos Obrigatórios não informados (Percentual Perda Tosquiadeira) !!!", 1, 0 )
			lRet := .F.
		EndCase
	EndIf

Return lRet

// Gravação dos dados
Static Function B430Gravar(oModel)

	Local aArea	:= GetArea()				/// Salva a area corrente
	Local lRet 	:= .T.						/// Retorno da funcao
	Local nOpc 	:= oModel:GetOperation()	/// Numero da operacao (1: Visualizacao, 3: Inclusao, 4: Alteracao, 5: Exclusao)
	Local oZZA	:= oModel:GetModel("ZZAMASTER")
	Local oU00	:= oModel:GetModel("U00DETAIL")
	Local oZZB	:= oModel:GetModel("ZZBDETAIL")
	Local oZZD	:= oModel:GetModel("ZZDDETAIL")
	Local lRecCusto := .F.
	Local lFicha := .F.
	Local cZZA_CALCUS	:= oZZA:GetValue('ZZA_CALCUS')
	Local nZZA_PERTOS	:= oZZA:GetValue('ZZA_PERTOS')
	Local cZZA_REF		:= oZZA:GetValue('ZZA_REF')
	//Local cZZA_TIPOMA	:= oZZA:GetValue('ZZA_TIPOMA')
	//Local aRotiAux:= IIf(Type('aRotina')=='U',{},aClone(aRotina))
	//Local aHeadAux:= IIf(Type('aHeader')=='U',{},aClone(aHeader))
	//Local aColsAux:= IIf(Type('aCols')  =='U',{},aClone(aCols))
	Local x := 0
	Local nx := 0

	Private aHeader := {}
	Private aCols	  := {}
	Private aRotina := { {"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4},{"","",0,5}}

	aAdd(aHeader ,{"Referencia"	 ,"ZZA_REF"   ,"@!",TamSx3('ZZA_REF')[1]   , TamSx3('ZZA_REF')[2]   ,"","û","C","ZZA"})
	aAdd(aHeader ,{"Tipo Máquina","ZZA_TIPOMA","@!",TamSx3('ZZA_TIPOMA')[1], TamSx3('ZZA_TIPOMA')[2],"","û","C","ZZA"})
	aAdd(aHeader ,{"Artigo"      ,"ZZA_ARTIGO","@!",TamSx3('ZZA_ARTIGO')[1], TamSx3('ZZA_ARTIGO')[2],"","û","C","ZZA"})
	aAdd(aHeader ,{"Unid.Largura","ZZA_UNIDLA","@!",TamSx3('ZZA_UNIDLA')[1], TamSx3('ZZA_UNIDLA')[2],"","û","C","ZZA"})
	aAdd(aHeader ,{"Calcula Custo","ZZA_CALCUS","@!",TamSx3('ZZA_CALCUS')[1], TamSx3('ZZA_CALCUS')[2],"","û","C","ZZA"})
	aAdd(aHeader ,{"Recno"        ,"ZZA_RECNO" ,"@!",12                     , 0                      ,"","û","C",""})

	// Analisa se os campos indicados pelo usuario de Custos foram alterados e se Sim deverá ser alterado campo que indica que o
	// Custo do produto precisa ser Recalculado.
	If	((nOpc == MODEL_OPERATION_INSERT) .Or. (nOpc == MODEL_OPERATION_UPDATE))
		For nX := 1 To len(aCampos)

			cCampo := aCampos[nX,1]
			If	!(cCampo $ 'ZZA_CORUC/ZZA_CORUB/ZZA_CORUC1/ZZA_CORUB1/ZZA_CORTRA/ZZA_MPUC/ZZA_MPUB1/ZZA_MPUC1/ZZA_MPUB2/ZZA_MPTR/'+;
			'ZZA_ESPUC1/ZZA_ESPEUB/ZZA_ESPUB2/ZZA_ESPETR/ZZA_OBSERV/ZZA_DISPC1/ZZA_DISPC2/ZZA_DISPC3/ZZA_DISPC4')
				If	ZZA->(&cCampo) != aCampos[nX,2]
					lRecCusto := .T.
				EndIf
			EndIf

		Next nX

		// Analisa se a linhas das Tramas for nova e atualiza os campos chave na tabela U00
		For nX:= 1 To oU00:Length()

			oU00:GoLine(nX)
			If	oU00:IsInserted(nX) .And. !oU00:IsDeleted()
				oU00:LoadValue('U00_REF',oZZA:GetValue('ZZA_REF'))
				oU00:LoadValue('U00_TIPOMA',oZZA:GetValue('ZZA_TIPOMA'))
				lRecCusto := .T.
			ElseIf	U00->(DbSeek(xFilial('U00')+oU00:GetValue('U00_REF')+oU00:GetValue('U00_TIPOMA')+oU00:GetValue('U00_SEQUEN')))
				If	(U00->U00_QTDFIO != oU00:GetValue('U00_QTDFIO')) .Or.;
				(U00->U00_TITFIO != oU00:GetValue('U00_TITFIO')) .Or.;
				(U00->U00_FIOSBA != oU00:GetValue('U00_FIOSBA')) .Or.;
				(U00->U00_PESO   != oU00:GetValue('U00_PESO')) .Or.;
				(U00->U00_TPFIO != oU00:GetValue('U00_TPFIO'))
					lRecCusto := .T.
				EndIf
			EndIf

		Next nX

		// Analisa se a linhas do Urdume de Cima é nova e atualiza os campos chave na tabela ZZB
		For nX:= 1 To oZZB:Length()

			oZZB:GoLine(nX)
			If	oZZB:IsInserted(nX) .And. !oZZB:IsDeleted()
				oZZB:LoadValue('ZZB_REF',oZZA:GetValue('ZZA_REF'))
				oZZB:LoadValue('ZZB_TIPOMA',oZZA:GetValue('ZZA_TIPOMA'))
			EndIf

		Next nX

		// Analisa se a linhas do Urdume de Baixo é nova e atualiza os campos chave na tabela ZZD
		For nX:= 1 To oZZD:Length()

			oZZD:GoLine(nX)
			If	oZZD:IsInserted(nX) .And. !oZZD:IsDeleted()
				oZZD:LoadValue('ZZD_CODUB', StrZero(oZZA:GetValue('ZZA_TFIOUB'),4) + ;
				AllTrim(aCampos[aScan(aCampos,{|x| x[1] == 'ZZA_CORUB1'}),2]) +;
				AllTrim(aCampos[aScan(aCampos,{|x| x[1] == 'ZZA_CORUB2'}),2]))
			EndIf

		Next nX

	EndIf

	//Realiza a gravação do Modelo
	lRet := FwFormCommit(oModel)

	If lRet .And. ((nOpc == MODEL_OPERATION_INSERT) .Or. (nOpc == MODEL_OPERATION_UPDATE))

		nRecno := ZZA->(Recno())
		If	Select('TFICHA')<>0
			TFICHA->(DbCloseArea())
		EndIf

		BeginSql Alias 'TFICHA'
		Column ZZA_RECNO as Numeric(12,0)
		SELECT R_E_C_N_O_ AS ZZA_RECNO, ZZA_CALCUS, ZZA_REF, ZZA_ARTIGO, ZZA_TIPOMA, ZZA_UNIDLA, ZZA_PERTOS
		FROM %Table:ZZA%
		WHERE ZZA_FILIAL = %xFilial:ZZA%
		AND %NotDel%
		AND ZZA_REF = %Exp:oZZA:GetValue('ZZA_REF')%
		AND R_E_C_N_O_ != %Exp:AllTrim(Str(nRecno))%
		EndSql

		If	TFICHA->(Eof())
			cZZA_CALCUS := 'S'
			lFicha	:= .T.
		ElseIf	oZZA:GetValue('ZZA_CALCUS') == 'S'
			lFicha	:= .T.
			While !TFICHA->(Eof())

				cUpdate := "Begin Tran FICHA ; "+ENTER
				cUpdate += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_CALCUS = 'N' "
				cUpdate += " FROM "+RetSqlName("ZZA")+" WHERE R_E_C_N_O_ = '"+AllTrim(Str(TFICHA->ZZA_RECNO))+"' ; "+ENTER
				cUpdate += "Commit Tran FICHA ; "+ENTER
				If (TCSQLExec(cUpdate) < 0)
					MsgStop("TCSQLError() " + TCSQLError())
				EndIf

				TFICHA->(DbSkip())

			EndDo
		ElseIf	oZZA:GetValue('ZZA_CALCUS') == 'N'
			While !TFICHA->(Eof())

				aAdd(aCols,{TFICHA->ZZA_REF, TFICHA->ZZA_TIPOMA, TFICHA->ZZA_ARTIGO, TFICHA->ZZA_UNIDLA, TFICHA->ZZA_CALCUS, TFICHA->ZZA_RECNO, .F.})
				If	TFICHA->ZZA_CALCUS == 'S'
					lFicha := .T.
				EndIf

				TFICHA->(DbSkip())
			EndDo
		EndIf

		// Gravar o Percentual de Perda para todas as ficha técnicas existentes dos produtos de Veludo
		If	Left(cZZA_REF,1) == 'V'
			TFICHA->(DbGotop())
			While !TFICHA->(Eof())

				IF	Empty(TFICHA->ZZA_PERTOS)

					cUpdate := "Begin Tran FICHA ; "+ENTER
					cUpdate += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_PERTOS = " + AllTrim(Str(nZZA_PERTOS))
					cUpdate += " FROM "+RetSqlName("ZZA")+" WHERE R_E_C_N_O_ = '"+AllTrim(Str(TFICHA->ZZA_RECNO))+"' ; "+ENTER
					cUpdate += "Commit Tran FICHA ; "+ENTER
					If (TCSQLExec(cUpdate) < 0)
						MsgStop("TCSQLError() " + TCSQLError())
					EndIf

				EndIf

				TFICHA->(DbSkip())
			EndDo
		EndIf

		If	Select('TFICHA')<>0
			TFICHA->(DbCloseArea())
		EndIf

		ZZA->(DbGoto(nRecno))
		ZZA->(RecLock('ZZA',.F.))

		For nX := 1 To len(aCampos)

			cCampo := AllTrim(aCampos[nX,1])
			ZZA->(&cCampo) := aCampos[nX,2]

		Next nX

		If	lRecCusto
			ZZA->ZZA_ATUALI := "S"
		Else
			ZZA->ZZA_ATUALI := "N"
		EndIf

		ZZA->ZZA_CALCUS := cZZA_CALCUS

		ZZA->(MsUnlock())

		If	!lFicha
			Alert('Não existe nenhuma Ficha Técnica desta Referência selecionada para Cálculo de Custos, favor ajustar !!!')
			dbSelectArea('ZZA')
			dbGoto(nRecno)

			aAdd(aCols,{ZZA->ZZA_REF, ZZA->ZZA_TIPOMA, ZZA->ZZA_ARTIGO, ZZA->ZZA_UNIDLA, ZZA->ZZA_CALCUS, ZZA->(Recno()), .F.})
			aSort(aCols,,,{|x,y| x[6] < y[6]})

			Define MsDialog oDlg1 From 200,001 To 530,810 Pixel Title "Selecionar Ficha Técnica para Cálculo de Custos"
			oGetDb	:= MsGetDados():New(006,005,140,400,4,'U_B430VldCus()','U_B430VldCus()',,.F.,{"ZZA_CALCUS"},,.F.,Len(aCols),,,,"",oDlg1)

			Define SButton From 150,320 Type 1 Of oDlg1 Enable Action (LjMsgRun(OemToansi("Ajustando Fichas Técnicas ..."),'Ajustando Fichas Técnicas ...',{|| CursorWait(), lRet:=B430Custo(), If(lRet,oDlg1:End(),), CursorArrow()} ))
			Define SButton From 150,350 Type 2 Of oDlg1 Enable Action (oDlg1:End())

			ACTIVATE DIALOG oDlg1 CENTERED

		EndIf

	EndIf

	// Chama rotina que envia email avisando os responsaveis da Inclusao/Alteração de Ficha Tecnica.
	/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	If	(nOpc == MODEL_OPERATION_INSERT)
		ExecBlock("BUD757",.F.,.F.,2)
	ElseIf	(nOpc == MODEL_OPERATION_UPDATE)
		ExecBlock("BUD757",.F.,.F.,3)
	EndIf

	// Enviar e-mail da ficha técnica:
	If	((nOpc == MODEL_OPERATION_INSERT) .Or. (nOpc == MODEL_OPERATION_UPDATE))
		If 	MsgYesNo("Deseja enviar o e-mail de notificação da ficha técnica?")
			U_BUD1143(ZZA->ZZA_REF, ZZA->ZZA_TIPOMA)
		EndIf
	EndIf

	RestArea(aArea)

	lGravar  := .F.
	lHabilUB2:= .F.
	lHabilUC2:= .F.
	lZZB 	 := .F.

Return lRet

User Function B430VldCus()

	Local lRet := .T.
	Local cAux := ' '
	Local lSim := .F.
	Local x := 0

	For x:= 1 to Len(aCols)

		If	!GdDeleted(x,aHeader,aCols)
			If	GdFieldGet('ZZA_CALCUS',x,.F.,aHeader,aCols) == 'S'
				If	Empty(cAux)
					cAux := 'S'
				ElseIf	cAux == 'S'
					lSim := .T.
				EndIf
			EndIf
		EndIf

	Next

	If	lSim
		MsgInfo('Não é possível selecionar mais de uma linha como SIM para padrão de Cálculo de Custo, Favor Revisar !!!')
		lRet := .F.
	EndIf

Return lRet

Static Function B430Custo()

	Local lRet := U_B430VldCus()
	Local x := 0

	If	lRet

		For	x:=1 To Len(aCols)

			If	!GdDeleted(x,aHeader,aCols)
				cUpdate := "Begin Tran FICHA ; "+ENTER
				cUpdate += "UPDATE "+RetSqlName("ZZA")+" SET ZZA_CALCUS = '"+aCols[x][5]+"' "
				cUpdate += " FROM "+RetSqlName("ZZA")+" WHERE R_E_C_N_O_ = '"+AllTrim(Str(aCols[x][6]))+"' ; "+ENTER
				cUpdate += "Commit Tran FICHA ; "+ENTER
				If (TCSQLExec(cUpdate) < 0)
					MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			EndIf

		Next

	EndIf

Return lRet

Static Function B430Cancelar(oModel)

	Local lRet := .T.
	Local nX := 0

	lZZB 	 := .F.
	lGravar  := .F.
	lHabilUB2:= .F.
	lHabilUC2:= .F.
	For nX := 1 To len(aCampos)

		cTipo := ValType(aCampos[nX,2])
		Do Case
			Case cTipo == "C"
			aCampos[nX,2] := Space(TamSx3(aCampos[nX,1])[1])
			Case cTipo == "N"
			aCampos[nX,2] := 0
			Case cTipo == "D"
			aCampos[nX,2] := Stod("")
		End Case

	Next nX

Return lRet


Static Function B430AtZZB()

	Local nX		:= 0
	Local i 		:= 0
	Local x         := 0
	Local hh        := 0
	Local nSeq		:= 0
	Local nTotal	:= 0
	Local lDel	   	:= .F.
	Local aTempFio 	:= {}

	Local oModel	:= FwModelActive()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")
	Local oZZB		:= oModel:GetModel("ZZBDETAIL")

	nSeq   := 0
	nTotal := 0
	lDel   := .F.
	For nX := 1 to oZZB:Length()

		oZZB:GoLine(nX)
		If !oZZB:IsDeleted()
			nSeq ++
			oZZB:LoadValue('ZZB_SEQ' , StrZero(nSeq,4) )
			nTotal := B430GatZZB(, .T., nX, .T., nTotal)
		EndIf

	Next nX

	// Inclui Itens da tabela ZZB, recriando sequencia de inclusao.
	vuc 		:= aCampos[aScan(aCampos,{|x| x[1] == 'ZZA_PESUC'}),2]
	nTotReg 	:= 1
	nTotSai	:= oZZA:GetValue('ZZA_SAIFIO') //nSAIFIO
	nNrFioModal:= 0
	nTFIOS 	:= 0
	nSAI   	:= nTotSai
	vnfios		:= 0

	For nX := 1 to oZZB:Length()

		oZZB:GoLine(nX)
		If !oZZB:IsDeleted() //Deletado
			If 	oZZB:GetValue('ZZB_NFIOS') <> 0

				nQtdCor = 0
				For i := 1 to 4
					cCor = 'ZZB_COR' + ltrim (str (i))
					If !Empty(oZZB:GetValue(cCor))
						nQtdCor ++
					Endif
				Next i

				If	nQtdCor > 0
					nVft := 0
					For x := 1 to 4

						cCor    := 'ZZB_COR' + LTrim (Str(x))
						cCodCor := oZZB:GetValue(cCor)
						If	!Empty(cCodCor)
							nNfios  := oZZB:GetValue('ZZB_NFIOS')
							nFios	 := oZZB:GetValue('ZZB_NFIOS')
							nVft	 := oZZB:GetValue('ZZB_NFIOS')
							nVez	 := oZZB:GetValue('ZZB_VEZES')
							nFioSai := 0

							If	nTotSai > 0
								nVez -= 1
								If	nVft > nTotSai
									nFioSai := nVft - nTotSai
								Else
									nFioSai := 0
								EndIf
							EndIf

							If	nVft != 0
								nVft := nVft * nVez
								nVft += nFioSai
							EndIf

							nTotFios := nVft / nQtdCor

							nPos := aScan(aTempFio,{|X| X[1]== cCodCor})
							If nPos <> 0
								aTempFio[nPos,2] := aTempFio[nPos,2] + nTotFios
							ElseIf nPos == 0
								Aadd(aTempFio,{cCodCor,nTotFios})
							EndIf

						EndIf
					Next x

					nSdfio := nTotsai - nNfios
					if 	nSdfio > 0
						nTotsai := nSdfio
					else
						nTotsai = 0
					endif
					nTfios += nVft

				EndIf

			EndIf
		EndIf
	Next nX

	tfiosg 			:= 0
	tporc 			:= 0
	tpeso 			:= 0
	nNrFioModal 	:= 0
	nPesoFioModal	:= 0

	For hh := 1 to Len(aTempFio)
		vcor 		:= aTempFio[hh,1]
		Tfiosc 	:= aTempFio[hh,2]
		Tfiosg  	:= Tfiosg + Tfiosc

		porc 		:= (Tfiosc / nTfios) * 100
		Tporc 		:= Tporc + porc
		porcpeso 	:= (vuc * porc) / 100
		Tpeso 		:= Tpeso + porcpeso

		ZAN->(dbSetOrder(1))
		If ZAN->(dbSeek(xFilial("ZAN")+vcor))
			If ZAN->ZAN_modal == "S"
				nNrFioModal   += Tfiosc
				nPesoFioModal += porcpeso
			EndIf
		EndIf

	Next hh

	// Se tiver Numero de Fios Modal, posiciono na Ficha Tecnica para atualiza-la
	/////////////////////////////////////////////////////////////////////////////////////
	If !Empty(nNrFioModal) .and. !Empty(nPesoFioModal)

		// Caso nao tenha titulo informado, coloca o mesmo titulo do Urdume de Cima
		///////////////////////////////////////////////////////////////////////////////////
		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_TITUC2'})
		nPos1 := aScan(aCampos,{|x| x[1] == 'ZZA_TITUC'})
		If 	Empty(aCampos[nPos,2])
			aCampos[nPos,2] := aCampos[nPos1,2]
		EndIf

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_NFIUC2'})
		nPos1 := aScan(aCampos,{|x| x[1] == 'ZZA_PESUC2'})

		aCampos[nPos,2]  := nNrFioModal   // ZZA->ZZA_nfiuc2
		aCampos[nPos1,2] := nPesoFioModal // ZZA->ZZA_pesuc2

		// Caso nao tenha tipo de fio informado, coloca fixo MO (Modal)
		/////////////////////////////////////////////////////////////////////////
		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_TFIOC2'})
		If 	Empty(aCampos[nPos,2])  // ZZA->ZZA_tfioc2
			aCampos[nPos,2] := "MO" // ZZA->ZZA_tfioc2
		EndIf

		// Caso nao tenha sido informado se e Especifico e caso o fio seja realmente Modal, seto como especifico.
		/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_ESPUC2'})
		nPos1 := aScan(aCampos,{|x| x[1] == 'ZZA_TFIOC2'})
		If	Empty(aCampos[nPos,2]) .And. AllTrim(aCampos[nPos1,2]) == "MO"
			aCampos[nPos,2] := "S" // ZZA->ZZA_espuc2
		EndIf

	Else

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_TITUC2'})
		aCampos[nPos,2] := " "

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_NFIUC2'})
		aCampos[nPos,2] := 0

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_PESUC2'})
		aCampos[nPos,2] := 0

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_TFIOC2'})
		aCampos[nPos,2] := " "

		nPos  := aScan(aCampos,{|x| x[1] == 'ZZA_ESPUC2'})
		aCampos[nPos,2] := " "

	EndIf

Return .T.

Static Function B430AtZZD()

	Local nX		:= 0
	Local nSeq		:= 0
	Local nTotal	:= 0

	Local oModel	:= FwModelActive()
	Local oZZD		:= oModel:GetModel("ZZDDETAIL")

	nSeq   := 0
	nTotal := 0
	lDel   := .F.
	For nX := 1 to oZZD:Length()

		oZZD:GoLine(nX)
		If !oZZD:IsDeleted()
			nSeq ++
			oZZD:LoadValue('ZZD_SEQ' , StrZero(nSeq,4) )
			nTotal := B430GatZZD(, .T., nX, .T., nTotal)
		EndIf

	Next nX

Return .T.

// Validacao no preenchimento do campo ZZA_PRODUT
Static Function VldProduto()

	Local oModel 	:= FWMODELACTIVE()
	//Local oView  	:= FWVIEWACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.

	If  "ZZA_PRODUT" $ cCampo
		If	xValue == "T"
			lEspecie := .T.
		ElseIf	xValue == "R"
			lEspecie := .F.
			oZZA:ClearField( 'ZZA_ESPECI')
			oZZA:ClearField( 'ZZA_LARGPO')
			oZZA:ClearField( 'ZZA_COMPOL')
			oZZA:ClearField( 'ZZA_LARGUR')
			oZZA:ClearField( 'ZZA_COMPR' )
			oZZA:ClearField( 'ZZA_CHAPAC')
			oZZA:ClearField( 'ZZA_CHAPAB')
			oZZA:ClearField( 'ZZA_PESOUN')
			M->ZZA_NFITR :=  /*(oZZA:GetValue( 'ZZA_FIOTR' )*/ aCampos[aScan(aCampos,{|x| x[1] == 'ZZA_FIOTR'}),2] * 100
		EndIf
	EndIf

Return lRet

// Validacao no preenchimento do campo ZZA_ESPECI
Static Function VldEspecie()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local xCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local aEspecie:= Separa(alltrim(GETMV("MV_TPTECID")),";",.F.)
	Local nPos		:= 0

	If !Empty(xValue)
		nPos := aScan(aEspecie,{|x| AllTrim(x) == AllTrim(xValue)})
		If	nPos == 0
			Help( ,, 'Help',, 'Espécie nao relacionada para ser utilizada !!!', 1, 0 )
			lRet := .F.
		ElseIf	(oZZA:GetValue( 'ZZA_PRODUT' ) == 'T')
			If	(AllTrim(xValue) == 'BRANCO') .Or. (Empty(xValue))
				Help( ,, 'Help',, 'Quando o Produto for Toalha qualquer espécie pode ser informada menos BRANCO !!!', 1, 0 )
				lRet := .F.
			EndIf
		ElseIf	(oZZA:GetValue( 'ZZA_PRODUT' ) = 'R')
			If	(!(AllTrim(xValue) $ 'BRANCO/METROS') .And. !Empty(xValue))
				Help( ,, 'Help',, 'Para Produto Roupão a Espécie a ser informada deve ser BRANCO ou METROS !!!', 1, 0 )
				lRet := .F.
			EndIf
		EndIf
	EndIf

Return lRet


// Valida o preenchimento do campo Tipo Maquina
Static Function VldTpMaq()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local xCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.

	ZZA->(DbSetOrder(1))
	If ZZA->(DbSeek(xFilial("ZZA")+oZZA:GetValue( 'ZZA_REF' )+xValue))
		Help( ,, 'Help',, "Referencia/Tipo de Maquina já Cadastrada !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	ZZE->(DbSetOrder(1))
	If ZZE->(DbSeek(xFilial("ZZE")+xValue))
		oZZA:LoadValue( 'ZZA_DESTPM' , ZZE->ZZE_DESCRI )
		cTpMq	:= ALLTRIM(ZZE->ZZE_CLASSI)
	Else
		If !Empty(xValue)
			Help( ,, 'Help',, "Tipo de Máquina não Cadastrada !!!", 1, 0 )
			lRet := .F.
		EndIf
	EndIf

Return lRet


// Validacao do campo Tipo do Artigo
Static Function VldTipo()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local xCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local cTipo		:= ''

	cTipo := Left(oZZA:GetValue( 'ZZA_REF' ),1)
	If	(xValue != cTipo) .And. (xCampo $ 'M->ZZA_TIPO')
		M->ZZA_TIPO := cTipo
	Else
		oZZA:LoadValue( 'ZZA_TIPO' , cTipo )
	EndIf

	If 	cTipo == "F"
		oZZA:LoadValue( 'ZZA_DESTIP' , "Felpa " )
	ElseIf cTIPO == "V"
		oZZA:LoadValue( 'ZZA_DESTIP' , "Veludo" )
	EndIf

Return lRet

// Validação do Campo de Largura Polegada
Static Function VldLargPo()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nLargur	:= 0

	If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'R') .And. xValue <> 0
		Help( ,, 'Help',, 'Não deve ser informado esta Medida para o Produto Tipo Roupão !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	If 	xValue <> 0
		nLARGUR := Round((xValue * 2.54),2)
		nLARGUR := Int(nLARGUR + 0.5)
		oZZA:LoadValue( 'ZZA_LARGUR' , nLARGUR )
		a := (oZZA:GetValue( 'ZZA_PESOMT' ) / 1000)
		b := (oZZA:GetValue( 'ZZA_LARGUR' ) / 100)
		c := (oZZA:GetValue( 'ZZA_COMPR'  ) / 100)
		nPesoUn := Int(a * b * c * 1000)
		oZZA:LoadValue( 'ZZA_PESOUN' , nPesoUn )
	EndIf

Return lRet

// Validaçao do Campo Comprimento Polegada
Static Function VldComPol()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nCompr	:= 0

	If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'R') .And. xValue <> 0
		Help( ,, 'Help',, 'Não deve ser informado esta Medida para o Produto Tipo Roupão !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	If 	xValue <> 0
		nCOMPR := Round((xValue * 2.54),2)
		nCOMPR := Int(nCOMPR + 0.5)
		oZZA:LoadValue( 'ZZA_COMPR' , nCOMPR )
		a := (oZZA:GetValue( 'ZZA_PESOMT' ) / 1000)
		b := (oZZA:GetValue( 'ZZA_LARGUR' ) / 100)
		c := (oZZA:GetValue( 'ZZA_COMPR'  ) / 100)
		nPesoUn := Int(a * b * c * 1000)
		oZZA:LoadValue( 'ZZA_PESOUN' , nPesoUn )
	EndIf

Return lRet

// Validação do Campo Largura
Static Function VldLargur()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nLargPo	:= 0

	If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'R') .And. xValue <> 0
		Help( ,, 'Help',, 'Não deve ser informar esta Medida para o Produto Tipo Roupão !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	If 	(oZZA:GetValue( 'ZZA_PRODUT' ) = 'T') .And. xValue == 0
		Help( ,, 'Help',, 'Informar Largura em Polegadas ou Centímetros !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	If xValue <> 0
		nLARGPO := Round((xValue / 2.54),2)
		oZZA:LoadValue( 'ZZA_LARGPO' , nLARGPO )
		a := (oZZA:GetValue( 'ZZA_PESOMT' ) / 1000)
		b := (M->ZZA_LARGUR / 100)
		c := (oZZA:GetValue( 'ZZA_COMPR'  ) / 100)
		nPesoUn := Int(a * b * c * 1000)
		oZZA:LoadValue( 'ZZA_PESOUN' , nPesoUn )
	EndIf

Return lRet

// Validacao do Campo Comprimento
Static Function VldCompr()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nCompol	:= 0

	If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'R') .And. xValue <> 0
		Help( ,, 'Help',, 'Nao deve ser informado esta Medida para o Produto Tipo Roupão !!!', 1, 0 )
		Return .F.
	EndIf

	If 	(oZZA:GetValue( 'ZZA_PRODUT' ) = 'T') .And. xValue == 0
		Help( ,, 'Help',, 'Informar Largura em Polegadas ou Centímetros !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	If 	xValue <> 0
		nCOMPOL := Round((xValue / 2.54),2)
		oZZA:LoadValue( 'ZZA_COMPOL' , nCOMPOL )
		a := (oZZA:GetValue( 'ZZA_PESOMT' ) / 1000)
		b := (oZZA:GetValue( 'ZZA_LARGUR' ) / 100)
		c := (M->ZZA_COMPR / 100)
		nPesoUn := Int(a * b * c * 1000)
		oZZA:LoadValue( 'ZZA_PESOUN' , nPesoUn )

	EndIf

Return lRet

// Validação do Campo Peso M2
Static Function VldPesoMt()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local a,b,c,nPesoUn := 0

	If 	xValue == 0
		Help( ,, 'Help',, 'Informar Peso M2 !!!', 1, 0 )
		Return (lRet := .F.)
	EndIf

	a := (xValue / 1000)
	b := (oZZA:GetValue( 'ZZA_LARGUR' ) / 100)
	c := (oZZA:GetValue( 'ZZA_COMPR'  ) / 100)
	nPesoUn := Int(a * b * c * 1000)
	oZZA:LoadValue( 'ZZA_PESOUN' , nPesoUn )

Return lRet

// Validacao do Campo Total de Fios - UB e UC
Static Function VldTotFios()

	//Local oModel 	:= FWMODELACTIVE()
	//Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local cFio		:= IIf(RTrim(cCampo)$'ZZA_TFIOUC','Urdume de Cima','Urdume de Baixo')

	If xValue == 0
		Help( ,, 'Help',, "É necessário informar Total de Fios para "+cFio+" !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	If 	cFio == "Urdume de Baixo"
		aCampos[aScan(aCampos,{|x| x[1] == 'ZZA_NFIUB2'}),2] := 0
	EndIf

Return lRet

// Validação do Campo Chapas do Corpo
Static Function VldChapa()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local aArea	  	:= GetArea()
	Local aAreaSX3 	:= SX3->(GetArea())

	If 	xValue == 0 .And. (oZZA:GetValue( 'ZZA_PRODUT' ) = 'T')
		SX3->(DbSetOrder(2))
		SX3->(DbSeek(RTrim(cCampo)))
		Help( ,, 'Help',, "É necessário informar Valor para a "+SX3->(X3Descric())+" !!!", 1, 0 )
		lRet := .F.
	EndIf

	RestArea(aAreaSX3)
	RestArea(aArea)

Return lRet

// Validação do Campo Batidas por Felpa
Static Function VldNBat()

	//Local oModel 	:= FWMODELACTIVE()
	//Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.

	If xValue == 0
		Help( ,, 'Help',, "Informar valor para Batidas para Felpa !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

Return lRet

// Validacao do Campo Unidades por Largura
Static Function VldUnidLa()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nNFiuC, nVf, nNFiuB1 := 0

	If 	xValue == 0
		Help( ,, 'Help',, "Informar Valor para Unidade de Largura !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	nNFIUC := (oZZA:GetValue( 'ZZA_TFIOUC' ) / xValue)
	oZZA:LoadValue( 'ZZA_NFIUC' , nNFIUC )

	nVF	   := (oZZA:GetValue( 'ZZA_TFIOUB' ) / xValue)

	nNFIUB1:= (oZZA:GetValue( 'ZZA_TFIOUB' ) / xValue)
	oZZA:LoadValue( 'ZZA_NFIUB1' , nNFIUB1 )

Return lRet

// Validacao do Campo Ourelas
Static Function VldOurela()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")
	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.

	If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'T') .And. (xValue <> 4.4) .And. (xValue <> 5.1) .And. (xValue <> 6.4)
		Help( ,, 'Help',, "Para Tipos de Produto Toalha, devera ser informado os seguintes valores:  4.40 / 5.10 / 6.40 !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

Return	lRet

// Validacao da sequencia da trama para o tecido
Static Function VldTrama()

	Local oModel 	:= FWMODELACTIVE()
	Local oZZA		:= oModel:GetModel("ZZAMASTER")
	Local oU00		:= oModel:GetModel("U00DETAIL")

	//Local cCampo 	:= ReadVar()
	Local xValue 	:= &(ReadVar())
	Local lRet		:= .T.
	Local nLin		:= oU00:GetLine()
	Local nX		:= 0

	Local cRef 		:= oZZA:GetValue( 'ZZA_REF' )
	Local cTipoma	:= oZZA:GetValue( 'ZZA_TIPOMA' )

	If	!Empty(cRef) .And. !Empty(cTipoma)
		lRet := ExistChav('U00',cRef+cTipoma+xValue)
	EndIf

	If	lRet
		For nX := 1 To oU00:Length()
			If	(nLin != nX)
				oU00:GoLine( nX )
				If (oU00:GetValue("U00_SEQUEN") == xValue) .And. !oU00:IsDeleted()
					Help( ,, 'Help',, "Já existe esta seqüência de Trama Cadastrada para este Artigo.", 1, 0 )
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nX
	EndIf

Return lRet

// Validacao para o título do fio da Disposição de Fios
Static Function VldTit()

	Local lRet   := .T.
	Local cCampo := ReadVar()
	Local xValue := &(ReadVar())
	Local cTit	   := IIf(cCampo$'M->ZZA_TITUC','UC',IIf(cCampo$'M->ZZA_TITUC1','UC1',IIf(cCampo$'M->ZZA_TITUB1','UB1',IIf(cCampo$'M->ZZA_TITUB2','UB2','TR'))))

	If (Empty(xValue) .And. cTit == "UB1")
		Help( ,, 'Help',, "Informar Valor para o Titulo "+cTit+" !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	If cTit == "UB2" .And. !Empty(xValue)
		Help( ,, 'Help',, "Número de Fios UB1 igual ao Total Fios UB !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

Return lRet

//
Static Function VldFio()

	Local oModel := FWMODELACTIVE()
	Local oZZA	 := oModel:GetModel("ZZAMASTER")

	Local lRet 	 := .T.
	Local cCampo := ReadVar()
	Local xValue := &(ReadVar())
	Local cFio   := IIf(cCampo$'M->ZZA_FIOUC','UC',IIF(cCampo$'M->ZZA_FIOUC1','UC1',IIf(cCampo$'M->ZZA_FIOUB1','UB1',IIf(cCampo$'M->ZZA_FIOUB2','UB2','TR'))))

	If (Empty(xValue) .And. cFIO == "UB1")
		Help( ,, 'Help',, "Informar Valor para o Fio "+cFIO+" !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	If cFIO == "UB2" .And. 	!Empty(xValue)
		Help( ,, 'Help',, "Número Fios UB1 igual ao Total Fios UB !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	If cFio == "TR"
		If (oZZA:GetValue( 'ZZA_PRODUT' ) = 'T')
			M->ZZA_NFITR := M->ZZA_CHAPAC + M->ZZA_CHAPAB
			M->ZZA_NFITR := M->ZZA_NFITR * M->ZZA_NBAT
		ElseIf (oZZA:GetValue( 'ZZA_PRODUT' ) = 'R')
			M->ZZA_NFITR := (M->ZZA_FIOTR * 100)
		EndIf
	EndIf

Return lRet

//
Static Function VldNFi()

	//Local oModel 	:= FWMODELACTIVE()
	//Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local lRet := .T.
	Local cCampo := ReadVar()
	Local xValue := &(ReadVar())
	Local cNFI   := IIf(cCampo$'M->ZZA_NFIUC','UC',IIf(cCampo$'M->ZZA_NFIUC1','UC1',IIf(cCampo$'M->ZZA_NFIUB1','UB1',IIf(cCampo$'M->ZZA_NFIUB2','UB2','TR'))))

	If (Empty(xValue) .And. cNFI == "UB1")
		Help( ,, 'Help',, "Informar Valor para o Fio "+cNFI+" !!!", 1, 0 )
		Return (lRet := .F.)
	EndIf

	If cNFI == "UB1"
		IIf((nVF - xValue) < 0, M->ZZA_NFIUB2 := 0, M->ZZA_NFIUB2 := (nVF - xValue))
		If M->ZZA_NFIUB2 > 0
			If 	lVisualiz
				lHabilUB2 	:= .F.
			Else
				lHabilUB2 	:= .T.
			EndIf
			M->ZZA_TITUB2 	:= M->ZZA_TITUB1
			M->ZZA_NFIUB2	:= xValue
			M->ZZA_MPUB2	:= M->ZZA_MPUB1
		Else
			lHabilUB2		:= .F.
			M->ZZA_TITUB2 	:= Space(04)
			M->ZZA_NFIUB2	:= 0
			M->ZZA_MPUB2	:= Space(04)
		EndIf
	EndIf

	If 	cNFI == "UB2" .And. !Empty(xValue)
		Help( ,, 'Help',, "Número Fios UB1 igual ao Total Fios UB !!!", 1, 0 )
		lRet := .F.
	EndIf

Return lRet

//
Static Function VldCor()

	//Local oModel 	:= FWMODELACTIVE()
	//Local oZZA		:= oModel:GetModel("ZZAMASTER")

	Local lRet := .T.
	Local cCampo := ReadVar()
	Local xValue := &(ReadVar())
	Local cCor   := IIf(cCampo$'M->ZZA_CORUC','UC',IIf(cCampo$'M->ZZA_CORUC1','UC1',IIf(cCampo$'M->ZZA_CORUB1','UB1',IIf(cCampo$'M->ZZA_CORUB2','UB2','TR'))))

	If	!(lRet := ExistCpo('ZAN',xValue))
		Return lRet
	EndIf

	If 	(cCor == "UB1") .And. !Empty(xValue) .And. (xValue == M->ZZA_CORUB2)
		Help( ,, 'Help',, "Cor do U.B.2 Igual a Cor do U.B.1 !!!", 1, 0 )
		lRet := .F.
	ElseIf 	(cCor == "UB2") .And. !Empty(xValue) .And. (xValue == M->ZZA_CORUB1)
		Help( ,, 'Help',, "Cor do U.B.2 Igual a Cor do U.B.1 !!!", 1, 0 )
		lRet := .F.
	EndIf

Return lRet

User Function BUD430M()

	Local aParam    := ParamIxb
	Local lRet		:= .T.
	Local oObj
	Local cIdPonto
	Local cIdModel
	Local lIsGrid
	Local oModel
	Local oZZB

	If 	aParam <> NIL
		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]
		lIsGrid    := ( Len( aParam ) > 3 )

		If	lIsGrid
			If	cIdModel == 'ZZBDETAIL' .And. cIdPonto == 'FORMLINEPRE'
				// quando pressionar a tecla delete e a linha estiver ativa
				If 	aParam[5] == 'DELETE'
					oModel 	:= FWMODELACTIVE()
					oView  	:= FWVIEWACTIVE()
					oZZB	:= oModel:GetModel("ZZBDETAIL")
					nLinDel := oZZB:GetLine()
					oZZB:GoLine(1)
					B430GatZZB(,.F.,,,,'DELETE')
					oZZB:GoLine(nLinDel)
					nLinDel := 0
					// Refresh do objeto para mostrar os dados alterados
					oView:Refresh('VIEW_ZZB')

					// quando pressionar a tecla delete e a linha estiver deletada
				ElseIf	aParam[5] == 'UNDELETE'
					oModel 	:= FWMODELACTIVE()
					oView  	:= FWVIEWACTIVE()
					oZZB	:= oModel:GetModel("ZZBDETAIL")
					nLinDel := oZZB:GetLine()
					oZZB:GoLine(1)
					B430GatZZB(,.F.,,,,'UNDELETE')
					oZZB:GoLine(nLinDel)
					nLinDel := 0
					// Refresh do objeto para mostrar os dados alterados
					oView:Refresh('VIEW_ZZB')

					// depois do preenchimento do conteudo do campo aberto para edição
					/*ElseIf	aParam[5] == 'SETVALUE'
					Alert('Modelo '+ cIdModel + ' Ponto ' + cIdPonto + ' Opcao ' +aParam[5])
					// ao pressionar a tecla para habilitar o campo para edição
					ElseIf	aParam[5] == 'CANSETVALUE'
					Alert('Modelo '+ cIdModel + ' Ponto ' + cIdPonto + ' Opcao ' +aParam[5])*/
				EndIf
				// quando pressionar F2 para nova linha
				/*ElseIf	cIdModel == 'ZZBDETAIL' .And. cIdPonto == 'FORMPRE' .And. aParam[5] == 'ADDLINE'
				Alert('Modelo '+ cIdModel + ' Ponto ' + cIdPonto + ' Opcao ' +aParam[5] )*/
			EndIf
			/*ElseIf	cIdModel == 'ZZBDETAIL' .And. cIdPonto == 'MODELPRE'
			Alert('Modelo '+ cIdModel + ' Ponto ' + cIdPonto + ' Opcao ' +IIf(Len(aParam) > 4,aParam[5],'') )*/
		EndIf

	EnDIf

Return lRet

Static Function CreateTrigger(cDom,cCtDom,cVal,cRegra)

Local aAux :=   FwStruTrigger(;
      cDom ,; // Campo Dominio
      cCtDom ,; // Campo de Contradominio
      cRegra,; // Regra de Preenchimento
      .F. ,; // Se posicionara ou nao antes da execucao do gatilhos
      "" ,; // Alias da tabela a ser posicionada
      0 ,; // Ordem da tabela a ser posicionada
      "" ,; // Chave de busca da tabela a ser posicionada
      cVal ,; // Condicao para execucao do gatilho
      "01" ) // Sequencia do gatilho (usado para identificacao no caso de erro)

Return aAux
