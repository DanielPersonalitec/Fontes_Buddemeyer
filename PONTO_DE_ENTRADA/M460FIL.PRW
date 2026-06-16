#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function m460fil()        // incluido pelo assistente de conversao do AP6 IDE em 24/04/02

	Private cGrpVrn := SuperGetMv('BD_GRPECOM',.F.,'000020')
	Private cFilPed	:= "C9_FILIAL == '"+xFilial("SC9")+"' "
	Private lFat
	Private lFatVrn
	Private lChamaRet	:= .F.

	lFatVrn := ValPed()

	// Thiago 07/08/2017:
	IF 	cEmpAnt == '01'
		// Digita pedidos:
		/*If MV_PAR03==2 .AND. MV_PAR19==1
			Processa({|| DigitaPedidos() }, "Aguarde...")
		EndIf*/

		// Verifico tela de complemento:
		If !_SetAutoMode() .And. !IsBlind()
			If MV_PAR05 == MV_PAR06
				//If VALTYPE(MV_PAR17) == "N" --Comentado por RobsonJP - 20200327
				//If MV_PAR17 == 1 --Comentado por RobsonJP - 20200327
				If !IsInCallStack("U_BUD1220A") .And. !IsInCallStack("U_BUD1302A")
					LjMsgRun(OemToAnsi('Verificando complemento do pedido. Aguarde!'),,{|| U_BUD039(MV_PAR05) } )
				End If
				//End If
				//EndIf
			EndIf
		EndIf
		//PERSONALITEC - 28-10-2024
		//Retirada de validaçoes BUDD que foram transferidas para o BUD1452
		//Processo relacionado ao painel de faturamento
		If FunName() <> "BUD1451" .AND. FunName() <> "BUD1452"
			cFilPed	:= VeriParc(cFilPed)
			cFilPed	:= VeriProd(cFilPed)
			cFilPed	:= VeriBloq(cFilPed)
			cFilPed	:= VeriPdr3(cFilPed)
			cFilPed	:= VeriDtBa(cFilPed)
			cFilPed	:= VeriFatD(cFilPed)
			cFilPed := VeriImpD(cFilPed)
			cFilPed := VeriDsRe(cFilPed)
			cFilPed := VeriPgto(cFilPed)
			cFilPed := VeriDtAn(cFilPed)
		EndIf
	EndIF

	IF	!lFat
		cFilPed	+= " .And. C9_PEDIDO == '" + MV_PAR05 + "'"
	ElseIf	lFatVrn
		cFilPed += (" .And. C9_PEDIDO >= '" + MV_PAR05 + "' .And. C9_PEDIDO <= '" + MV_PAR06 + "'")
	Endif

	//Incluído por Paulo Afonso em 07/06/2018 para filtrar pedidos vinculados
	If cEmpAnt == '01' .And. ExistBlock("BUD1298D") .And. !lChamaRet
		cFilPed += U_BUD1298D()
	EndIf

Return cFilPed

Static Function DigitaPedidos()
	//Local oSButton1

	aCols		:= {}
	aHeader 	:= {}

	aRotinaTmp	:= aRotina
	aRotina 	:= {{"","",0,1},{"","",0,2},{"","",0,3},{"","",0,4}}

	Aadd(aHeader,{"Pedido  "	,"PEDIDO","@!",6,0,"U_VALID460()","","C","SC5",""})
	Aadd(aHeader,{"Emissao "	,"EMISSAO","@!",8,0,"","","D","",""})
	Aadd(aHeader,{"Cliente "	,"A1_NOME","@!",40,0,"","","C","",""})


	aGetQtd := {}
	Aadd(aGetQtd,"PEDIDO")

	aCols := {}
	Aadd(aCols,{Space(06),CTOD("  /  /  "),Space(40),.F.})

	cTitulo := "Digitação de pedidos"

	@ 000,000 TO 400,580 DIALOG oPedidos TITLE cTitulo

	oBrowQtd := MsGetDados():New(010,010,130,285,4,"AllwaysTrue","AllwaysTrue","",.T.,aGetQtd,,,999)
	oBrowQtd:oBrowse:bWhen := {||(Len(aCols),.T.)}
	oBrowQtd:oBrowse:Refresh()

	//@ 175,020 BUTTON "Não Filtrar"	 	SIZE 38,12 ACTION Close(oPedidos)
	//@ 180,030 BUTTON "Filtrar"  		SIZE 38,12 ACTION Processa( { ||FilPed() }, "")

	@ 175, 010 BUTTON oButton1 PROMPT "Gerar NF" SIZE 037, 012 ACTION Processa( { ||FilPed() }, "") OF oPedidos PIXEL
	@ 175, 230 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 ACTION Close(oPedidos) OF oPedidos PIXEL


	ACTIVATE DIALOG oPedidos CENTERED

	aRotina 	:= aRotinaTmp

Return

Static Function FilPed()

	Local i := 0

	Close(oPedidos)

	cPedidos := ""
	For i:=1 to Len(aCols)
		cPedidos += "C9_PEDIDO = '" + ALLTRIM(aCols[i,1]) + "' .OR. "
	Next i
	cPedidos := "(" + SUBSTR(cPedidos,1,Len(cPedidos)-6) + ")"
	cFilPed	 := cPedidos

Return(cFilPed)

User Function VALID460()

	cA1_NOME := Space(40)
	lRet:= .T.
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbGotop()
	If DbSeek(xFilial("SC5")+M->PEDIDO,.T.)
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbGotop()
		lRet:=.T.
		If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
			cA1_NOME := SA1->A1_NOME
		EndIf

		aCols[n,2] := SC5->C5_EMISSAO
		aCols[n,3] := cA1_NOME
	Else
		MsgStop("Pedido não existe!!!")
		lRet:= .F.
	EndIf
Return(lRet)

Static Function ValPed()

	Local  _i := 0

	//// ADICIONADO PARA NAO PERMETIR QUE USUARIOS QUE NAO FAZEM PARTE DO FATURAMENTO REALIZAR ESTORNO OU FATURAMENTO DE VARIOS PEDIDOS AO MESMO TEMPO.
	//// SOLICITAÇÃO DO SR. JAIRO E ODAIR (LOGISTICA)
	//// JONAS - 23/06/14
	lFat := .F.
	PswOrder(2)
	If PswSeek(cUserName,.T.)
		aUsrInf := PswRet()
		For _i := 1 To Len(aUsrInf[1][10])
			If 	RTRim(Upper(AllTrim(aUsrInf[1][10][_i]))) $ cGrpVrn // PERMITE FATURAMENTO VRN - E-COMMERCE
				lFatVrn := .T.
				lFat    := .T.
				Exit
			EndIf
			If 	RTRim(Upper(AllTrim(aUsrInf[1][10][_i]))) $ "000012"  .OR. (RTrim(Upper(Substr(cUsuario,7,13))) == 'ADMINISTRADOR') // ESTORNO/FAT
				lFat := .T.
				Exit
			EndIf
		Next _i
	EndIf
	IF  !lFat  .AND. MV_PAR05 <> MV_PAR06
		ALERT("Usuário não autorizado a Faturar / Estornar mais de um pedido.")
	ENDIF

Return

// Rotina para verificar se o pagamento de pedidos à vista foi efetuado corretamente:
Static Function VeriPgto(cFilRec)

	If (Select("M460PAG") <> 0)
		dbSelectArea("M460PAG")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 ZCA_PEDIDO, ZCA_STPAG  "
	cCons += "FROM "+RetSqlName("ZCA")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC5")+" (NOLOCK) ON C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = ZCA_PEDIDO  AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SE4")+" (NOLOCK) ON  E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG AND "+RetSqlName("SE4")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = C5_NUM AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
	cCons += "WHERE ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cCons += "AND ZCA_PEDIDO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND F4_DUPLIC = 'S' "
	cCons += "AND ((REPLACE(SUBSTRING(LTRIM(E4_COND), 2, 2),',','') IN ('0','00','1','01') AND E4_TIPO = '8')OR E4_CODIGO = '001') "
	cCons += "AND ZCA_STPAG <> 'PAGO' "
	cCons += "AND ZCA_DTRESE <> '' "
	cCons += "AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "M460PAG"
	If !M460PAG->(EOF())
		// Caso cliente não efetuou pagamento à vista:
		MsgStop("Atenção! Pedido ["+AllTrim(M460PAG->ZCA_PEDIDO)+"] a vista ou com entrada ainda não foi pago! " + AllTrim(M460PAG->ZCA_STPAG))
		// Altero status logística:
		U_BUD1162(M460PAG->ZCA_PEDIDO, 'BLOQ. FAT. PGTO.')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
	EndIf

Return(cFilRec)

// Rotina para verificar se o pedido a ser faturado refere-se à um pedido reserva de distribuição:
Static Function VeriDsRe(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND C5_DISTRIB = 'R' "
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] é um pedido reserva com distribuição, e portanto não poderá ser faturado!")

		// Altero status logística:
		U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. PED. RESERVA')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
	EndIf
Return(cFilRec)

// Rotina para verificar se é permitido efetuar mais de um faturamento para o mesmo cliente:
Static Function VeriFatD(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, F2_DOC, F2_SERIE, F2_HORA  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	// Busco o código do cliente desse pedido, e também o código do grupo:
	cCons += "INNER JOIN "+RetSqlName("SA1")+" SA1_PED (NOLOCK) ON SA1_PED.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1_PED.A1_COD = C5_CLIENTE AND SA1_PED.A1_LOJA = C5_LOJACLI AND SA1_PED.A1_FATDIA = 'N' AND SA1_PED.D_E_L_E_T_ = '' "
	// Busco todos os clientes relacionados aquele cliente do pedido, tanto por código quanto por grupo:
	cCons += "INNER JOIN "+RetSqlName("SA1")+" SA1_GRU (NOLOCK) ON SA1_GRU.A1_FILIAL = '"+xFilial("SA1")+"' "
	cCons += "		AND ( "
	cCons += "				(SA1_GRU.A1_COD = SA1_PED.A1_COD AND SA1_PED.A1_GRUPO = '')  "
	cCons += "					OR  "
	cCons += "				(SA1_GRU.A1_GRUPO = SA1_PED.A1_GRUPO AND SA1_PED.A1_GRUPO <> '')  "
	cCons += "			) "
	cCons += "		AND SA1_GRU.D_E_L_E_T_ = '' "
	// Busco alguma nota fiscal que foi faturada já no dia atual da data base de qualquer loja ou grupo do cliente relacionado:
	cCons += "INNER JOIN "+RetSqlName("SF2")+" (NOLOCK) ON F2_FILIAL = '"+xFilial("SF2")+"' AND F2_CLIENTE = SA1_GRU.A1_COD AND F2_LOJA = SA1_GRU.A1_LOJA AND F2_EMISSAO = '"+DtoS(MsDate())+"' AND F2_DUPL <> '' AND "+RetSqlName("SF2")+".D_E_L_E_T_ = '' "
	cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cCons += "AND C5_TIPO1 = 'N' "
	// Filtros utilizados no início da rotina:
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! O cliente não aceita mais de um faturamento no mesmo dia. A nota ["+AllTrim(M460PAR->F2_DOC)+"] foi faturada às ["+AllTrim(M460PAR->F2_HORA)+"h]!")

		// Altero status logística:
		U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. MESMO DIA')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
	EndIf
Return (cFilRec)

// Rotina para verificar se é permitido faturar antes da data base:
Static Function VeriDtBa(cFilRec)
	// Verifico pedido com data base:
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_DTBASE, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
	cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND C5_FTBASE = 'N'  "
	cCons += "AND C5_DTBASE > '"+DtoS(MsDate())+"'  "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		// Somente bloqueio o pedido se o mesmo ainda não foi pago:
		If (AllTrim(M460PAR->ZCA_STPAG) != 'PAGO')
			lChamaRet	:= .T.
			MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] só poderá ser faturado a partir do dia ["+DtoC(StoD(M460PAR->C5_DTBASE))+"]!")

			// Altero status logística:
			U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. DT. BASE')
			cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
		End If
	EndIf

	// Verifico pedido referenciado para não deixar faturar antes do específico:
	if !lChamaRet
		If (Select("M460PAR") <> 0)
			dbSelectArea("M460PAR")
			dbCloseArea()
		EndIf
		cCons := "SELECT TOP 1 C5_NUM, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG, C5_RFBASE, C5_QTBASE "
		cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
		// Verifico se já teve pagamento de pedido à vista:
		cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
		cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  "
		cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
		cCons += "AND C5_FTBASE = 'N'  "
		cCons += "AND C5_TPBASE = 'R'  "
		cCons += "AND C5_RFBASE <> ''  "
		//cCons += "AND C5_DTBASE > '"+DtoS(MsDate())+"'  "
		cCons += "AND SC5010.D_E_L_E_T_ = '' "
		TCQuery cCons NEW ALIAS "M460PAR"
		If !M460PAR->(EOF())
			// Somente bloqueio o pedido se o mesmo ainda não foi pago:
			If (AllTrim(M460PAR->ZCA_STPAG) != 'PAGO')
				// Agora verifico se o pedido referenciado já foi faturado:
				If (Select("M460PREF") <> 0)
					dbSelectArea("M460PREF")
					dbCloseArea()
				EndIf
				cCons := "SELECT TOP 1 C5_NOTA, ISNULL(D2_EMISSAO, '') AS D2_EMISSAO "
				cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
				cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = C5_NUM AND "+RetSqlName("SC6")+".D_E_L_E_T_ = ''  "
				cCons += "LEFT  JOIN "+RetSqlName("SD2")+" (NOLOCK) ON D2_FILIAL = '"+xFilial("SD2")+"' AND D2_PEDIDO = C5_NUM AND "+RetSqlName("SD2")+".D_E_L_E_T_ = ''  "
				cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  "
				cCons += "AND (C5_NUM = '"+M460PAR->C5_RFBASE+"' OR C5_PEDREP = '"+M460PAR->C5_RFBASE+"') "
				cCons += "AND (C6_QTDVEN > C6_QTDCANC) "
				cCons += "AND SC5010.D_E_L_E_T_ = '' "
				cCons += "ORDER BY D2_EMISSAO ASC"
				TCQuery cCons NEW ALIAS "M460PREF"
				If !M460PREF->(EOF())
					If Empty(M460PREF->D2_EMISSAO) .Or. (M460PREF->D2_EMISSAO > DtoS(MsDate() - M460PAR->C5_QTBASE))
						lChamaRet	:= .T.
						MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] só poderá ser faturado a partir de ["+AllTrim(Str(M460PAR->C5_QTBASE))+" dia(s)] após o pedido ["+AllTrim(M460PAR->C5_RFBASE)+"]!")

						// Altero status logística:
						U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. DT. REFER.')
						cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
					EndIf
				End If
			End If
		EndIf

	End If

	// Verifico se o pedido contém data específica e está acima da data atual:
	if !lChamaRet
		// Verifico pedido com data específica:
		If (Select("M460PAR") <> 0)
			dbSelectArea("M460PAR")
			dbCloseArea()
		EndIf
		cCons := "SELECT TOP 1 C5_NUM, C5_DTFAT, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
		cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
		cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
		cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
		cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
		cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
		cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
		cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
		cCons += "AND C5_DTFATES = 'E' "
		cCons += "AND C5_DTFAT > '"+DtoS(MsDate())+"'  "
		TCQuery cCons NEW ALIAS "M460PAR"
		If !M460PAR->(EOF())
			// Somente bloqueio o pedido se o mesmo ainda não foi pago:
			If (AllTrim(M460PAR->ZCA_STPAG) != 'PAGO')
				lChamaRet	:= .T.
				MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] contém data específica de faturamento de ["+DtoC(StoD(M460PAR->C5_DTFAT))+"]!")

				// Altero status logística:
				U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. DT. ESP.')
				cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
			End If
		EndIf
	EndIf

Return (cFilRec)

// Rotina para verificar se o pedido está na "Inter":
Static Function VeriPdr3(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_LOCFIS  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
	cCons += " LEFT JOIN "+RetSqlName("ZZ5")+" (NOLOCK) z ON ZZ5_FILIAL = '"+xFilial("ZZ5")+"' AND ZZ5_PEDIDO = C5_NUM AND z.D_E_L_E_T_ = '' " //DANIEL PERSONALITEC - AINDA NÃO TESTADO - 01/12/2025
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND z.ZZ5_PALLET <> ' ' " //DANIEL PERSONALITEC - AINDA NÃO TESTADO - 01/12/2025
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND C5_LOCFIS NOT IN ('RETORNADO MATRIZ', '')  "


	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] encontra-se com o status ["+AllTrim(M460PAR->C5_LOCFIS)+"]!")

		// Altero status logística:
		U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. ' + AllTrim(M460PAR->C5_LOCFIS))
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
	EndIf
Return (cFilRec)

// Rotina para verificar se o pedido está sob inconsistência:
Static Function VeriInco(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 ZCA_PEDIDO, ZCA_STCORT  "
	cCons += "FROM "+RetSqlName("ZCA")+" (NOLOCK)  "
	cCons += "WHERE "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"'  "
	cCons += "AND ZCA_PEDIDO BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND ZCA_STCORT <> ''  "
	cCons += "AND ZCA_STCORT NOT IN ('FATURADO', 'CORTE EFETUADO')  "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->ZCA_PEDIDO)+"] está em fase de inconsistência com o status ["+AllTrim(M460PAR->ZCA_STCORT)+"]!")
		// Altero status logística:
		U_BUD1162(M460PAR->ZCA_PEDIDO, 'BLOQ. FAT. INCONS.')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido completo (solicitado por Eliza)
	EndIf
Return (cFilRec)

// Rotina para verificar se existem produtos bloqueados para faturamento pela rotina de reserva:
Static Function VeriProd(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C6_NUM, C6_PRODUTO, C6_DESCRI  "
	cCons += "FROM "+RetSqlName("SC6")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZCV")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND ZCV_PRODUT = C6_PRODUTO AND ZCV_TPBLOQ IN ('FATURAMENTO', 'AMBOS') AND "+RetSqlName("ZCV")+".D_E_L_E_T_ = ''  "
	cCons += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "AND C6_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C6_QTDEMP > 0  "
	cCons += "AND (C6_QTDVEN - C6_QTDENT - C6_QTDCANC) > 0  "
	cCons += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = ''  "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! O produto "+AllTrim(M460PAR->C6_NUM)+"/"+AllTrim(M460PAR->C6_PRODUTO) + " - " + AllTrim(M460PAR->C6_DESCRI)+" está bloqueado para faturamento!")
		// Altero status logística:
		U_BUD1162(M460PAR->C6_NUM, 'BLOQ. FAT. PRODUTO')
		//cFilRec	+= " AND C9_PRODUTO <> '"+AllTrim(M460PAR->C6_PRODUTO)+"' " // Filtro para não permitir faturar aquele produto
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido completo (solicitado por Eliza)
	EndIf
Return (cFilRec)

// Rotina para verificar se o cliente aceita faturamento parcial:
Static Function VeriParc(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_PARCIAL  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON "+RetSqlName("SC6")+".D_E_L_E_T_ = '' AND C6_NUM = C5_NUM AND C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON "+RetSqlName("SC9")+".D_E_L_E_T_ = '' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND C9_FILIAL = '"+xFilial("SC9")+"'  "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cCons += "AND (C6_QTDVEN - C6_QTDENT - C6_QTDCANC - C6_QTDEMP) > 0 "
	cCons += "AND C5_PARCIAL = 'N'  "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! Esse cliente não aceita faturamento parcial! - 1")
		// Altero status logística:
		U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. PARCIAL')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar
	EndIf
Return (cFilRec)

// Rotina para verificar se está bloqueado comercialmente:
Static Function VeriBloq(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, ZAE_DESCRI  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZAE")+" (NOLOCK) ON "+RetSqlName("ZAE")+".D_E_L_E_T_ = '' AND ZAE_CODIGO = C5_CDBLQC AND ZAE_FILIAL = '"+xFilial("ZAE")+"'  "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cCons += "AND C5_BLQCM = '2' "
	cCons += "AND C5_CDBLQC NOT IN ('', '0019')  "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		lChamaRet	:= .T.
		MsgStop("Atenção! Esse pedido ["+AllTrim(M460PAR->C5_NUM)+"] possui o seguinte bloqueio comercial: "+AllTrim(M460PAR->ZAE_DESCRI)+"!")
		// Altero status logística:
		U_BUD1162(AllTrim(M460PAR->C5_NUM), 'BLOQ. FAT. COMERCIAL')
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar
	EndIf
Return (cFilRec)

// Rotina para verificar se o pedido está tentando ser faturado com TES de importação direta, porém não existe mais saldo desse item para esse tipo de operação:
Static Function VeriImpD(cFilRec)
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT DISTINCT C6_NUM, C6_TES, C6_ITEM "
	cCons += "FROM "+RetSqlName("SC6")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZBY")+" (NOLOCK) ON ZBY_FILIAL = '"+xFilial("ZBY")+"' AND ZBY_COD = C6_PRODUTO AND ZBY_ATIVO = 'S' AND "+RetSqlName("ZBY")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S' AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("ZBZ")+" (NOLOCK) ON ZBZ_FILIAL = '"+xFilial("ZBZ")+"' AND ZBZ_TES2 = C6_TES AND "+RetSqlName("ZBZ")+".D_E_L_E_T_ = '' "
	cCons += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "AND C6_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'  "
	cCons += "AND ZBY_QTDE < C6_QTDEMP  "
	cCons += "AND C6_QTDEMP > 0 "
	cCons += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		cPedido	:= AllTrim(M460PAR->C6_NUM)
		cTes	:= AllTrim(M460PAR->C6_TES)
		cItens	:= "item ["
		nQtdItn	:= 0
		While !M460PAR->(EOF())
			nQtdItn++
			cItens	+= AllTrim(M460PAR->C6_ITEM) + ", "
			M460PAR->(dbSkip())
		EndDo
		cItens	+= "#"	// Fim
		cItens	:= StrTran(cItens, ", #", "]")
		if nQtdItn > 1
			cItens	:= StrTran(cItens, "item", "itens")
		EndIf

		lChamaRet	:= .T.
		MsgStop("Atenção! Não é permitido faturar o pedido ["+AllTrim(cPedido)+"] "+cItens+" com o tipo de TES ["+AllTrim(cTes)+"]. Pois não existem mais estoque de produtos importados de modo direto para essa operação! Gentileza solicitar alteração de TES para o comercial...")
		// Altero status logística:
		U_BUD1162(AllTrim(cPedido), 'BLOQ. TP. OPER. ' + Upper(cItens))
		cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar
	EndIf
Return (cFilRec)

// Rotina para verificar se é permitido faturar antes do prazo de entrega (antecipação):
Static Function VeriDtAn(cFilRec)
	// Verifico pedido com data base:
	If (Select("M460PAR") <> 0)
		dbSelectArea("M460PAR")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_DESCPRA, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cCons += "AND C5_NUM BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' "
	cCons += "AND C5_FTBASE = 'S' "						// Aceita antes da data base
	cCons += "AND C5_DTFATES = 'I' "					// Configurado faturamento entre intervalo
	cCons += "AND C5_ANTECIP = 'N' "					// Não aceita antecipação
	cCons += "AND C5_DTFATIN > '"+DtoS(MsDate())+"' " 	// A data esteja abaixo do faturamento inicial estabelecido no prazo de entrega
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "M460PAR"
	If !M460PAR->(EOF())
		// Somente bloqueio o pedido se o mesmo ainda não foi pago:
		If (AllTrim(M460PAR->ZCA_STPAG) != 'PAGO')
			MsgStop("Atenção! O pedido ["+AllTrim(M460PAR->C5_NUM)+"] só poderá ser faturado no prazo ["+AllTrim(M460PAR->C5_DESCPRA)+"]!")

			// Altero status logística:
			U_BUD1162(M460PAR->C5_NUM, 'BLOQ. FAT. ANTECIPACAO')
			cFilRec	+= " .And. 0 == 1 " // Filtro para não permitir faturar o pedido
		End If
	EndIf

Return (cFilRec)
