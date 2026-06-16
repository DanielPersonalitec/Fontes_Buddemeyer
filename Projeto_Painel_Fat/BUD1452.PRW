#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
/*
Aplica as regras dos pontos de entrada do faturamento, antecipando os bloqueios.
BUD1452(BD1451->C5_NUM, BD1451->C5_CLIENTE,BD1451->C5_LOJACLI,BD1451->C5_TIPO)
PERSONALITEC - ROBERTO
*/
User Function BUD1452(_Pedido,_cCliente, _cLojaCli, _cTipoPed)

	Local cAlias := GetNextAlias()

	Local _volta:=''
	Local cGrupo:= ""
	Local cNomeCli := ""

	Private cEmpr := AllTrim(SM0->M0_CODIGO + SM0->M0_CODFIL)

	Private _cB1452Ped := _Pedido
	Private _cB1452Cli := _cCliente
	Private _cB1452Loj := _cLojaCli
	PRIVATE _cRet := "F"
	Private _cPedido := _Pedido

//M460FIL
// Rotina para verificar se o pagamento de pedidos à vista foi efetuado corretamente:
	/*If (Select("M460PAG") <> 0)
		dbSelectArea("M460PAG")
		dbCloseArea()
	EndIf
	*/
	cCons := "SELECT TOP 1 ZCA_PEDIDO, ZCA_STPAG  "
	cCons += "FROM "+RetSqlName("ZCA")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC5")+" (NOLOCK) ON C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = ZCA_PEDIDO  AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SE4")+" (NOLOCK) ON  E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG AND "+RetSqlName("SE4")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = C5_NUM AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
	cCons += "WHERE ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cCons += "AND ZCA_PEDIDO BETWEEN '"+_Pedido+"' AND '"+_Pedido+"' "
	cCons += "AND C5_CLIENTE BETWEEN '"+_cCliente+"' AND '"+_cCliente+"' "
	cCons += "AND F4_DUPLIC = 'S' "
	cCons += "AND ((REPLACE(SUBSTRING(LTRIM(E4_COND), 2, 2),',','') IN ('0','00','1','01') AND E4_TIPO = '8')OR E4_CODIGO = '001') "
	cCons += "AND ZCA_STPAG <> 'PAGO' "
	cCons += "AND ZCA_DTRESE <> '' "
	cCons += "AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	/*TCQuery cCons NEW ALIAS "M460PAG"*/
	If Select(cAlias) > 0
		dbSelectArea(cAlias)
		dbCloseArea()
	Endif
	TCQUERY cCons NEW ALIAS &cAlias
	If !(cAlias)->(EOF())
		// Altero status logística:
		U_BUD1162((cAlias)->ZCA_PEDIDO, 'BLOQ. FAT. PGTO.')
		_cRet := "1"
		Return _cRet
	EndIf

//verifica se o pedido a ser faturado refere-se à um pedido reserva de distribuição:
	If (Select("B1452DIS") <> 0)
		dbSelectArea("B1452DIS")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM  = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND C5_DISTRIB = 'R' "
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "B1452DIS"
	If !B1452DIS->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(B1452DIS->C5_NUM, 'BLOQ. FAT. PED. RESERVA')
		_cRet := "2"
		Return _cRet
	EndIf


// Rotina para verificar se é permitido efetuar mais de um faturamento para o mesmo cliente:
	If (Select("B1452FAT") <> 0)
		dbSelectArea("B1452FAT")
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
	cCons += "AND C5_NUM  = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "B1452FAT"
	If !B1452FAT->(EOF())
		// Altero status logística:
		U_BUD1162(B1452FAT->C5_NUM, 'BLOQ. FAT. MESMO DIA')
		_cRet := "3"
		Return _cRet
	EndIf

// Rotina para verificar se é permitido faturar antes da data base:
	If (Select("B1452DAT") <> 0)
		dbSelectArea("B1452DAT")
		dbCloseArea()
	EndIf
	lChamaRet := .F.
	cCons := "SELECT TOP 1 C5_NUM, C5_DTBASE, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
	cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM  = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND C5_FTBASE = 'N'  "
	cCons += "AND C5_DTBASE > '"+DtoS(MsDate())+"'  "
	TCQuery cCons NEW ALIAS "B1452DAT"
	If !B1452DAT->(EOF())
		// Somente bloqueio o pedido se o mesmo ainda não foi pago:
		If (AllTrim(B1452DAT->ZCA_STPAG) != 'PAGO')
			lChamaRet	:= .T.
			// Altero status logística:
			U_BUD1162(B1452DAT->C5_NUM, 'BLOQ. FAT. DT. BASE')
			_cRet := "4"
			Return _cRet
		End If
	EndIf

	// Verifico pedido referenciado para não deixar faturar antes do específico:
	if !lChamaRet
		If (Select("B1452DAT") <> 0)
			dbSelectArea("B1452DAT")
			dbCloseArea()
		EndIf
		cCons := "SELECT TOP 1 C5_NUM, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG, C5_RFBASE, C5_QTBASE "
		cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
		// Verifico se já teve pagamento de pedido à vista:
		cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
		cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"'  "
		cCons += "AND C5_NUM = '"+_Pedido+"'  "
		cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
		cCons += "AND C5_FTBASE = 'N'  "
		cCons += "AND C5_TPBASE = 'R'  "
		cCons += "AND C5_RFBASE <> ''  "
		//cCons += "AND C5_DTBASE > '"+DtoS(MsDate())+"'  "
		cCons += "AND SC5010.D_E_L_E_T_ = '' "
		TCQuery cCons NEW ALIAS "B1452DAT"
		If !B1452DAT->(EOF())
			// Somente bloqueio o pedido se o mesmo ainda não foi pago:
			If (AllTrim(B1452DAT->ZCA_STPAG) != 'PAGO')
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
				cCons += "AND (C5_NUM = '"+B1452DAT->C5_RFBASE+"' OR C5_PEDREP = '"+B1452DAT->C5_RFBASE+"') "
				cCons += "AND (C6_QTDVEN > C6_QTDCANC) "
				cCons += "AND SC5010.D_E_L_E_T_ = '' "
				cCons += "ORDER BY D2_EMISSAO ASC"
				TCQuery cCons NEW ALIAS "M460PREF"
				If !M460PREF->(EOF())
					If Empty(M460PREF->D2_EMISSAO) .Or. (M460PREF->D2_EMISSAO > DtoS(MsDate() - B1452DAT->C5_QTBASE))
						lChamaRet	:= .T.
						// Altero status logística:
						U_BUD1162(B1452DAT->C5_NUM, 'BLOQ. FAT. DT. REFER.')
						_cRet := "5"
						Return _cRet
					EndIf
				End If
			End If
		EndIf

	EndIf

	// Verifico se o pedido contém data específica e está acima da data atual:
	if !lChamaRet
		// Verifico pedido com data específica:
		If (Select("B1452DAT") <> 0)
			dbSelectArea("B1452DAT")
			dbCloseArea()
		EndIf
		cCons := "SELECT TOP 1 C5_NUM, C5_DTFAT, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
		cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
		cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
		cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
		cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
		cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
		cCons += "AND C5_NUM = '"+_Pedido+"'  "
		cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
		cCons += "AND C5_DTFATES = 'E' "
		cCons += "AND C5_DTFAT > '"+DtoS(MsDate())+"'  "
		TCQuery cCons NEW ALIAS "B1452DAT"
		If !B1452DAT->(EOF())
			// Somente bloqueio o pedido se o mesmo ainda não foi pago:
			If (AllTrim(B1452DAT->ZCA_STPAG) != 'PAGO')
				lChamaRet	:= .T.
				// Altero status logística:
				U_BUD1162(B1452DAT->C5_NUM, 'BLOQ. FAT. DT. ESP.')
				_cRet := "6"
				Return _cRet
			EndIf
		EndIf
	EndIf

// Rotina para verificar se o pedido está na "Inter":
	If (Select("B1452INT") <> 0)
		dbSelectArea("B1452INT")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_LOCFIS  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON C9_FILIAL = '"+xFilial("SC9")+"' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND "+RetSqlName("SC9")+".D_E_L_E_T_ = '' "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND C5_LOCFIS NOT IN ('RETORNADO MATRIZ', '')  "
	TCQuery cCons NEW ALIAS "B1452INT"
	If !B1452INT->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(B1452INT->C5_NUM, 'BLOQ. FAT. ' + AllTrim(B1452INT->C5_LOCFIS))
		_cRet := "7"
		Return _cRet
	EndIf

/* 
Validação retirada, pois não tem chamada dentro do ponto de entrada
// Rotina para verificar se o pedido está sob inconsistência:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 ZCA_PEDIDO, ZCA_STCORT  "
	cCons += "FROM "+RetSqlName("ZCA")+" (NOLOCK)  "
	cCons += "WHERE "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "AND ZCA_FILIAL = '"+xFilial("ZCA")+"'  "
	cCons += "AND ZCA_PEDIDO = '"+_Pedido+"'  "
	cCons += "AND ZCA_STCORT <> ''  "
	cCons += "AND ZCA_STCORT NOT IN ('FATURADO', 'CORTE EFETUADO')  "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(B1452INC->ZCA_PEDIDO, 'BLOQ. FAT. INCONS.')
		_cRet := "8"
		Return _cRet
	EndIf
*/
// Rotina para verificar se existem produtos bloqueados para faturamento pela rotina de reserva:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C6_NUM, C6_PRODUTO, C6_DESCRI  "
	cCons += "FROM "+RetSqlName("SC6")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZCV")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND ZCV_PRODUT = C6_PRODUTO AND ZCV_TPBLOQ IN ('FATURAMENTO', 'AMBOS') AND "+RetSqlName("ZCV")+".D_E_L_E_T_ = ''  "
	cCons += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "AND C6_NUM = '"+_Pedido+"'  "
	cCons += "AND C6_QTDEMP > 0  "
	cCons += "AND (C6_QTDVEN - C6_QTDENT - C6_QTDCANC) > 0  "
	cCons += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = ''  "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(B1452INC->C6_NUM, 'BLOQ. FAT. PRODUTO')
		_cRet := "9"
		Return _cRet
	EndIf


// Rotina para verificar se o cliente aceita faturamento parcial:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_PARCIAL  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON "+RetSqlName("SC6")+".D_E_L_E_T_ = '' AND C6_NUM = C5_NUM AND C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "INNER JOIN "+RetSqlName("SC9")+" (NOLOCK) ON "+RetSqlName("SC9")+".D_E_L_E_T_ = '' AND C9_PEDIDO = C5_NUM AND C9_NFISCAL = '' AND C9_FILIAL = '"+xFilial("SC9")+"'  "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM = '"+_Pedido+"'  "
	cCons += "AND (C6_QTDVEN - C6_QTDENT - C6_QTDCANC - C6_QTDEMP) > 0 "
	cCons += "AND C5_PARCIAL = 'N'  "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(B1452INC->C5_NUM, 'BLOQ. FAT. PARCIAL')
		_cRet := "A"
		Return _cRet
	EndIf


// Rotina para verificar se está bloqueado comercialmente:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, ZAE_DESCRI  "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZAE")+" (NOLOCK) ON "+RetSqlName("ZAE")+".D_E_L_E_T_ = '' AND ZAE_CODIGO = C5_CDBLQC AND ZAE_FILIAL = '"+xFilial("ZAE")+"'  "
	cCons += "WHERE "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "AND C5_FILIAL = '"+xFilial("SC5")+"'  "
	cCons += "AND C5_NUM = '"+_Pedido+"'  "
	cCons += "AND C5_BLQCM = '2' "
	cCons += "AND C5_CDBLQC NOT IN ('', '0019')  "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(AllTrim(B1452INC->C5_NUM), 'BLOQ. FAT. COMERCIAL')
		_cRet := "B"
		Return _cRet
	EndIf


// Rotina para verificar se o pedido está tentando ser faturado com TES de importação direta, porém não existe mais saldo desse item para esse tipo de operação:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT DISTINCT C6_NUM, C6_TES, C6_ITEM "
	cCons += "FROM "+RetSqlName("SC6")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("ZBY")+" (NOLOCK) ON ZBY_FILIAL = '"+xFilial("ZBY")+"' AND ZBY_COD = C6_PRODUTO AND ZBY_ATIVO = 'S' AND "+RetSqlName("ZBY")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND F4_ESTOQUE = 'S' AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("ZBZ")+" (NOLOCK) ON ZBZ_FILIAL = '"+xFilial("ZBZ")+"' AND ZBZ_TES2 = C6_TES AND "+RetSqlName("ZBZ")+".D_E_L_E_T_ = '' "
	cCons += "WHERE C6_FILIAL = '"+xFilial("SC6")+"'  "
	cCons += "AND C6_NUM = '"+_Pedido+"'  "
	cCons += "AND ZBY_QTDE < C6_QTDEMP  "
	cCons += "AND C6_QTDEMP > 0 "
	cCons += "AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		cPedido	:= AllTrim(B1452INC->C6_NUM)
		cTes	:= AllTrim(B1452INC->C6_TES)
		cItens	:= "item ["
		nQtdItn	:= 0
		While !B1452INC->(EOF())
			nQtdItn++
			cItens	+= AllTrim(B1452INC->C6_ITEM) + ", "
			B1452INC->(dbSkip())
		EndDo
		cItens	+= "#"	// Fim
		cItens	:= StrTran(cItens, ", #", "]")
		if nQtdItn > 1
			cItens	:= StrTran(cItens, "item", "itens")
		EndIf

		lChamaRet	:= .T.
		// Altero status logística:
		U_BUD1162(AllTrim(cPedido), 'BLOQ. TP. OPER. ' + Upper(cItens))
		_cRet := "C"
		Return _cRet
	EndIf


// Rotina para verificar se é permitido faturar antes do prazo de entrega (antecipação):
	// Verifico pedido com data base:
	If (Select("B1452INC") <> 0)
		dbSelectArea("B1452INC")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 C5_NUM, C5_DESCPRA, ISNULL(ZCA_STPAG, 'SEM_ZCA') AS ZCA_STPAG "
	cCons += "FROM "+RetSqlName("SC5")+" (NOLOCK)  "
	cCons += "LEFT  JOIN "+RetSqlName("ZCA")+" (NOLOCK) ON ZCA_FILIAL = '"+xFilial("ZCA")+"' AND ZCA_PEDIDO = C5_NUM AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	cCons += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
	cCons += "AND C5_NUM = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND C5_FTBASE = 'S' "						// Aceita antes da data base
	cCons += "AND C5_DTFATES = 'I' "					// Configurado faturamento entre intervalo
	cCons += "AND C5_ANTECIP = 'N' "					// Não aceita antecipação
	cCons += "AND C5_DTFATIN > '"+DtoS(MsDate())+"' " 	// A data esteja abaixo do faturamento inicial estabelecido no prazo de entrega
	cCons += "AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "B1452INC"
	If !B1452INC->(EOF())
		// Somente bloqueio o pedido se o mesmo ainda não foi pago:
		If (AllTrim(B1452INC->ZCA_STPAG) != 'PAGO')
			// Altero status logística:
			U_BUD1162(B1452INC->C5_NUM, 'BLOQ. FAT. ANTECIPACAO')
			_cRet := 'D"
			Return _cRet
		EndIf
	EndIf

// Rotina para verificar se o pagamento de pedidos à vista foi efetuado corretamente:
	If (Select("B1452PAG") <> 0)
		dbSelectArea("B1452PAG")
		dbCloseArea()
	EndIf
	cCons := "SELECT TOP 1 ZCA_PEDIDO, ZCA_STPAG  "
	cCons += "FROM "+RetSqlName("ZCA")+" (NOLOCK)  "
	cCons += "INNER JOIN "+RetSqlName("SC5")+" (NOLOCK) ON C5_FILIAL = '"+xFilial("SC5")+"' AND C5_NUM = ZCA_PEDIDO  AND "+RetSqlName("SC5")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SE4")+" (NOLOCK) ON  E4_FILIAL = '"+xFilial("SE4")+"' AND E4_CODIGO = C5_CONDPAG AND "+RetSqlName("SE4")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SC6")+" (NOLOCK) ON C6_FILIAL = '"+xFilial("SC6")+"' AND C6_NUM = C5_NUM AND "+RetSqlName("SC6")+".D_E_L_E_T_ = '' "
	cCons += "INNER JOIN "+RetSqlName("SF4")+" (NOLOCK) ON F4_FILIAL = '"+xFilial("SF4")+"' AND F4_CODIGO = C6_TES AND "+RetSqlName("SF4")+".D_E_L_E_T_ = '' "
	cCons += "WHERE ZCA_FILIAL = '"+xFilial("ZCA")+"' "
	cCons += "AND ZCA_PEDIDO = '"+_Pedido+"'  "
	cCons += "AND C5_CLIENTE = '"+_cCliente+"' "
	cCons += "AND F4_DUPLIC = 'S' "
	cCons += "AND ((REPLACE(SUBSTRING(LTRIM(E4_COND), 2, 2),',','') IN ('0','00','1','01') AND E4_TIPO = '8')OR E4_CODIGO = '001') "
	cCons += "AND ZCA_STPAG <> 'PAGO' "
	cCons += "AND ZCA_DTRESE <> '' "
	cCons += "AND "+RetSqlName("ZCA")+".D_E_L_E_T_ = '' "
	TCQuery cCons NEW ALIAS "B1452PAG"
	If !B1452PAG->(EOF())
		// Altero status logística:
		U_BUD1162(B1452PAG->ZCA_PEDIDO, 'BLOQ. FAT. PGTO.')
		_cRet := "1"
		Return _cRet
	EndIf


//M460QRY
//////////////////////////////////////

	dbSelectArea("SC5")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SC5")+_Pedido)

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbGoTop()
	dbSeek(xFilial("SA1")+_cCliente + _cLojaCli)
	cGrupo:= SA1->A1_GRUPO
	cNomeCli:= SA1->A1_NOME

	VeriEtq(_Pedido)

	cQuery := " "
	cQuery += "SELECT  DISTINCT C5_TIPO,C6_TES,F4_DUPLIC "
	cQuery += "FROM SC5010 (NOLOCK) C5 "
	cQuery += "INNER JOIN SC6010 C6 (NOLOCK) ON C6.C6_NUM=C5.C5_NUM AND C6.D_E_L_E_T_='' AND C6.C6_FILIAL ='01' "
	cQuery += "INNER JOIN SF4010 F4 (NOLOCK) ON F4.F4_FILIAL = ' ' AND F4.F4_CODIGO=C6.C6_TES AND F4.D_E_L_E_T_=' ' "
	cQuery += "WHERE C5.C5_FILIAL = '01' AND C5.D_E_L_E_T_ = ' '  "
	cQuery += "AND C5_NUM = '"+ALLTRIM(_Pedido)+"' "
	cQuery += "AND ((C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0) "

	If (Select("M460TES") <> 0)
		dbSelectArea("M460TES")
		dbCloseArea()
	EndIf

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "M460TES"
	dbSelectArea("M460TES")

	cDuplicN:=''
	cDuplicS:=''
	cTPPed  :=''

	While !M460TES->(Eof())

		IF M460TES->F4_DUPLIC == 'N'
			cDuplicN:= ALLTRIM(M460TES->F4_DUPLIC)
		Else
			cDuplicS:= ALLTRIM(M460TES->F4_DUPLIC)
		ENDIF
		cTPPed:=  M460TES->C5_TIPO

		M460TES->(DbSkip())

	EndDo

	IF (SELECT("M460CRED") <> 0)
		DBSELECTAREA("M460CRED")
		DBCLOSEAREA()
	ENDIF

	BeginSql Alias "M460CRED"
		Column VALOR  AS NUMERIC (14,2)
		SELECT A1_GRUPO,E1_CLIENTE,E1_LOJA,SUM(E1_VALOR) AS VALOR
		FROM %Table:SE1% E1 (NOLOCK)
		INNER JOIN %Table:SA1% A1 (NOLOCK) ON A1.A1_COD=E1.E1_CLIENTE AND A1.A1_LOJA=E1.E1_LOJA AND A1.%NotDel% AND A1.A1_FILIAL = %xFilial:SA1%
		WHERE E1.%NotDel%
		AND E1_CLIENTE = %EXP:_cCliente%
		AND E1_LOJA = %EXP:_cLojaCli%
		AND E1_CLIENTE NOT IN ('740770','638542','295247','379837','035484','604113','390716','476908','270019','791343')
		AND A1_GRUPO NOT IN ('0016')
		AND (E1_BAIXA = ' ' OR E1_SALDO<>0 )
		AND E1_TIPO NOT IN ('NCC','RA')
		AND LEFT(E1_CLIENTE,2)!= 'EX'
		AND E1_VENCREA < %EXP:DTOS(DDATABASE)%
		AND A1.A1_RISCO <> 'A'
		AND E1.E1_FILIAL = %Exp:xFilial("SE1")%
		GROUP BY A1_GRUPO,E1_CLIENTE,E1_LOJA
	EndSql

	If (SELECT("M460GRP") <> 0)
		DBSELECTAREA("M460GRP")
		DBCLOSEAREA()
	EndIf

	IF !EMPTY(cGrupo)

		BeginSql Alias "M460GRP"
			Column VALOR  AS NUMERIC (14,2)

			SELECT A1_GRUPO,E1_CLIENTE,E1_LOJA,SUM(E1_VALOR) AS VALOR
			FROM %Table:SE1% E1 (NOLOCK)
			INNER JOIN %Table:SA1% A1 (NOLOCK)ON A1.A1_COD=E1.E1_CLIENTE AND A1.A1_LOJA=E1.E1_LOJA AND A1.%NotDel% AND A1.A1_FILIAL = %xFilial:SA1%
			WHERE E1.%NotDel%
			AND E1.E1_FILIAL = %xFilial:SE1%
			AND A1_GRUPO= %EXP:cGrupo%
			AND E1_CLIENTE NOT IN ('128398','740770','638542','295247','379837','035484','604113','390716', '638545')
			AND A1_GRUPO NOT IN ('0016')
			AND (E1_BAIXA = ' ' OR E1_SALDO<>0 )
			AND E1_TIPO NOT IN ('NCC','RA')
			AND LEFT(E1_CLIENTE,2)!= 'EX'
			AND E1_VENCREA < %EXP:DTOS(DDATABASE)%
			AND A1.A1_RISCO <> 'A'
			GROUP BY A1_GRUPO,E1_CLIENTE,E1_LOJA
		EndSql

	EndIf

	BeginSql alias 'M460VEND'
		%noparser%
		SELECT C5_CREDFAT AS CREDFAT,C6_NOTA AS NOTA
		FROM %table:SC5% C5  (NOLOCK)
		INNER JOIN %table:SC6% C6 ON C6.C6_NUM=C5.C5_NUM AND C6.%NotDel% AND C6.C6_FILIAL = %xFilial:SC6%
		WHERE C5.%NotDel%
		AND C5.C5_FILIAL = %xFilial:SC5%
		AND C5.C5_NUM = %exp:_Pedido%
		AND ((C6.C6_QTDVEN - C6.C6_QTDENT - C6.C6_QTDCANC) > 0)
	EndSql

	/*	IF M460VEND->CREDFAT == '1' .AND. !EMPTY(M460VEND->NOTA)
	SC5->(Reclock("SC5",.F.))
	SC5->C5_CREDFAT:=''
	SC5->(msunlock("SC5"))
	//SC5->(dbSkip())
ENDIF */

	M460VEND->(DbCloseArea()) 

IF cEmpAnt == "01"
   IF SC5->C5_CREDFAT<>'5' //// ATERADO CONFORME ALINHAMENTO COM A VANESSA/LUCIANO - 31/01/2022 - JONAS
	  IF M460CRED->VALOR> 0  //.AND. SC5->C5_CREDFAT <> '1' //--- Retirado conforme Gediel/Magali
		//IF M460CRED->VALOR > 0
				//retirado em função ao fonte BUD1451	
				//MSGBOX("CLIENTE "+ M460CRED->E1_CLIENTE + " POSSUI TÍTULOS EM ATRASO." + " NO VALOR DE "+ Alltrim(TRANSFORM(M460CRED->VALOR,"@E 99,999,999.99"))+". FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO")//! MSGBOX("CLIENTE "+ M460CRED->E1_CLIENTE + " POSSUI TÍTULOS EM ATRASO." + " NO VALOR DE "+ Alltrim(TRANSFORM(M460CRED->VALOR,"@E 99,999,999.99"))+". FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO.DESEJA CONTINUAR?","ATENÇÃO","YESNO")
		//ENDIF
		IF /*SC5->C5_CREDFAT <> '1' .AND. SC5->C5_CREDFAT <> '4' .AND.*/ M460CRED->VALOR > 0 .AND. cDuplicS=='S' .AND. EMPTY(cDuplicN) .AND. cTPPed $ "A/B/F"
				BlQCRED()

		ENDIF

		IF /*SC5->C5_CREDFAT <> '1' .AND. SC5->C5_CREDFAT <> '4'* .AND.*/ M460CRED->VALOR > 0 .AND. cDuplicS=='S' .AND. EMPTY(cDuplicN) .AND. cTPPed $ "N"
				BlQCRED()

		ENDIF
			/////// BLOQUEA PEDIDO
		IF SC5->C5_CREDFAT == '4' .AND. cDuplicS == 'S'
			SC5->(Reclock("SC5",.F.))
			IIF(!EMPTY(M460CRED->A1_GRUPO),SC5->C5_CREDFAT:='4',SC5->C5_CREDFAT:='4')
			SC5->(msunlock("SC5"))
			BlQCRED()

		ELSE
			If SC5->C5_CREDFAT == '4' .AND. cDuplicN == 'N'
				SC5->(Reclock("SC5",.F.))
				SC5->C5_CREDFAT:='1'
				SC5->(msunlock("SC5"))
			Else
				SC5->(Reclock("SC5",.F.))
				SC5->C5_CREDFAT:='2'
				SC5->(msunlock("SC5"))
			EndIf
		ENDIF

			U_BUD1162(SC5->C5_NUM, 'BLOQUEIO FATURAMENTO')

	    ENDIF
    ENDIF	
	IF !EMPTY(cGrupo)
	    IF SC5->C5_CREDFAT<>'5' //// ATERADO CONFORME ALINHAMENTO COM A VANESSA/LUCIANO - 31/01/2022 - JONAS
		    IF M460GRP->VALOR > 0  /*.AND. SC5->C5_CREDFAT <> '1'*/ .AND. SC5->C5_CONDPAG <> '9A0' //Condição pagamento diferente de 9A0 para não bloquear, solicitado por Jennyfer - Alterado por RobsonJP 20210519 //.AND. !EMPTY(M460GRP->A1_GRUPO)
				//retirado em função ao fonte BUD1451	
				//ALERT("GRUPO CLIENTE "+ POSICIONE("ZZ7",1,XFILIAL("ZZ7")+alltrim(cGrupo),"ZZ7_DESCRI") + " POSSUI TÍTULOS EM ATRASO." +"FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO") //! MSGBOX("CLIENTE "+ M460CRED->E1_CLIENTE + " POSSUI TÍTULOS EM ATRASO." + " NO VALOR DE "+ Alltrim(TRANSFORM(M460CRED->VALOR,"@E 99,999,999.99"))+". FAVOR VERIFICAR JUNTO AO SETOR FINANCEIRO.DESEJA CONTINUAR?","ATENÇÃO","YESNO")

			IF /*(SC5->C5_CREDFAT <> '4') .AND.*/ M460GRP->VALOR > 0 .AND. cDuplicS=='S' .AND. cTPPed $ "A/B/F"
					BlQCRED()
			ENDIF

			IF /*SC5->C5_CREDFAT <> '1' .AND. SC5->C5_CREDFAT <> '4' .AND.*/ M460GRP->VALOR > 0 .AND. cDuplicS=='S' .AND.  EMPTY(cDuplicN) .AND. cTPPed $ "N"
				BlQCRED()
		    ENDIF
				/////// BLOQUEA PEDIDO
			IF SC5->C5_CREDFAT == '4' .AND. cDuplicS == 'S'
				SC5->(Reclock("SC5",.F.))
				SC5->C5_CREDFAT:='2'
				SC5->(msunlock("SC5"))
				BlQCRED()

			ELSE
				If SC5->C5_CREDFAT == '4' .AND. cDuplicN == 'N'
					SC5->(Reclock("SC5",.F.))
					SC5->C5_CREDFAT:='1'
					SC5->(msunlock("SC5"))
				Else
					SC5->(Reclock("SC5",.F.))
					SC5->C5_CREDFAT:='2'
					SC5->(msunlock("SC5"))
				EndIf
			ENDIF

				U_BUD1162(SC5->C5_NUM, 'BLOQUEIO FATURAMENTO')

		ENDIF
		ENDIF
	ENDIF
ENDIF

	// Se a empresa for Matriz 01 e a filial for 01 ou 10
	If cEmpr == "0101" .Or. cEmpr == "0110"
		cPed := SC5->C5_NUM
		
		// Se o pedido gerar financeiro e estiver bloqueado por limite de crédito
		If (Select("VERBLQ") <> 0)
			dbSelectArea("VERBLQ")
			dbCloseArea()
		EndIf

		BeginSql alias 'VERBLQ'
			SELECT DISTINCT C5_CREDITO, F4_DUPLIC
				FROM %Table:SC5% (NOLOCK) C5
			INNER JOIN %Table:SC6% (NOLOCK) C6 
				ON C6_FILIAL = %xFilial:SC6%
				AND C6_NUM = C5_NUM 
				AND C6.%NotDel%
			INNER JOIN %Table:SF4% (NOLOCK) F4 
				ON F4_FILIAL = %xFilial:SF4%
				AND F4_CODIGO = C6_TES 
				AND F4_DUPLIC = 'S'
				AND F4.%NotDel%
			INNER JOIN %Table:SA1% (NOLOCK) A1
				ON A1_FILIAL = %xFilial:SA1%
				AND A1_COD = C5_CLIENTE
				AND A1_LOJA = C5_LOJACLI 
				AND A1_COD NOT IN ('740770', '638542', '295247', '379837', '035484', '604113', '390716', '476908', '270019', '791343')
				AND A1_GRUPO <> '0016'
				AND A1.%NotDel%
			WHERE C5_FILIAL = %xFilial:SC5%
				AND C5_NUM = %Exp:cPed%
				AND LEFT(C5_NUM, 1) <> 'C'
				AND C5_CREDITO = '2'
				AND C5_TIPO = 'N'
				AND C5_CONDPAG <> '001'
				AND C5.%NotDel%
		EndSql

		// Se estiver bloqueado
		If !VERBLQ->(Eof())
			MSGBOX("O CLIENTE " + AllTrim(cNomeCli) + " POSSUI UM BLOQUEIO POR LIMITE DE CREDITO. FAVOR VERIFICAR LIBERAÇÃO JUNTO AO SETOR FINANCEIRO!")
			BlQCRED()

			U_BUD1162(SC5->C5_NUM, 'BLOQUEIO FATURAMENTO')
		EndIf
	EndIf

Return _cRet

Static Function VeriEtq(_PedidoC9)

	IF (SELECT("M460ETQ") <> 0)
		DBSELECTAREA("M460ETQ")
		DBCLOSEAREA()
	ENDIF

	BeginSql alias 'M460ETQ'
		SELECT C9_BLQENCX,C9_ITEM,C9_PRODUTO,SUM(C9_QTDLIB)AS QTDLIB,( SELECT SUM(ISNULL(ZZ5_QTDENC,0)) AS QTDENC
		FROM %table:ZZ5% ZZ5
		WHERE ZZ5.%NotDel% AND ZZ5.ZZ5_FILIAL = %xFilial:ZZ5%
		AND ZZ5_DOC = ' '
		AND ZZ5_PEDIDO=%exp:_PedidoC9%  AND C9.C9_ITEM=ZZ5_ITEM) AS QTDENC
		FROM %table:SC9% C9  (NOLOCK)
			INNER JOIN %table:SC5% SC5 ON SC5.%NotDel% AND SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM = C9.C9_PEDIDO
		WHERE C9.%NotDel%
			AND C9.C9_FILIAL = %xFilial:SC9%
			AND C9_NFISCAL=' '
			AND SC5.C5_DISTRIB != 'D'
			AND C9_LOCAL!='A4'
			AND C9_BLQENCX != '02'
			AND C9_PEDIDO=%exp:_PedidoC9%
			AND ((C9_PEDIDO BETWEEN 'M' AND 'OZZZZZ') OR LEFT(C9_PEDIDO, 5) = 'TESTE')
		GROUP BY C9_BLQENCX,C9_ITEM,C9_PRODUTO
	EndSql

	DBSELECTAREA("M460ETQ")

	Private aProd:={}
	lret:=.F.
	While !M460ETQ->(Eof())
		If (M460ETQ->QTDLIB <> M460ETQ->QTDENC)
			cDESC:= Posicione("SB1", 1, xFilial("SB1")+M460ETQ->C9_PRODUTO, "B1_DESC")
			aAdd(aProd,{M460ETQ->C9_ITEM,M460ETQ->C9_PRODUTO,ALLTRIM(cDESC),M460ETQ->QTDLIB,M460ETQ->QTDENC})
			lret:=.T.
		EndIf
		M460ETQ->(dbSkip())
	EndDo

	IF lret
		
		BlQETQ(_PedidoC9)
	Else
		// Libero bloqueio:
		dbSelectArea("SC9")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("SC9")+_PedidoC9)
		While !SC9->(Eof()) .and. SC9->C9_filial == xFilial("SC9") .AND.  SC9->C9_pedido == _PedidoC9
			SC9->(Reclock("SC9",.F.))
			SC9->C9_BLQENCX  :=	''
			SC9->(msunlock("SC9"))
			SC9->(dbSkip())
		Enddo
	Endif

Return()

Static Function BlQETQ(PedBloq)

	Local aArea 	 := GetArea()
	Local aAreaSC9 := SC9->(GetArea())

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SC9")+PedBloq)

	While !SC9->(Eof()) .and. SC9->C9_filial == xFilial("SC9") .AND.  SC9->C9_pedido == PedBloq

		SC9->(Reclock("SC9",.F.))
		//	SC9->C9_BLINF  :='BLOQ. ENCAIXOTAMENTO'
		SC9->C9_BLQENCX  :='01'
		SC9->(msunlock("SC9"))
		SC9->(dbSkip())
	Enddo

	// Seto histórico logística:
	U_BUD1162(PedBloq, 'BLOQ. FAT. DIVERGENCIA')

	// Seto inconsistência de reserva:
	cUpdate := ""
	cUpdate += "UPDATE ZCA010 SET ZCA_STCORT = 'PENDENTE' "
	cUpdate += "			   	, ZCA_STATUS = 'INCONSISTENCIA' "
	cUpdate += "				, ZCA_DTCORT = '"+DtoS(MsDate())+"' "
	cUpdate += "				, ZCA_HRCORT = '"+Substr(Time(),1,5)+"' "
	cUpdate += "				, ZCA_USUCOR = '"+Alltrim(Substr(cUsuario,7,15))+"' "
	cUpdate += "WHERE ZCA010.D_E_L_E_T_ = '' "
	cUpdate += "AND ZCA_FILIAL = '01' "
	cUpdate += "AND ZCA_PEDIDO = '"+PedBloq+"' "
	TCSQLEXEC(cUpdate)

	_cRet := "8"
	Return _cRet
	RestArea(aAreaSC9)
	RestArea(aArea)
	EndIF 

Return


Static Function BlQCRED()

	Local aArea 	 := GetArea()
	Local aAreaSC9 := SC9->(GetArea())

	dbSelectArea("SC9")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SC9")+_cPedido)
	
		While !SC9->(Eof()) .and. SC9->C9_filial == xFilial("SC9") .AND.  SC9->C9_pedido == _cPedido

			SC9->(Reclock("SC9",.F.))
			SC9->C9_CREDBUD:='10'
			SC9->(msunlock("SC9"))
			SC9->(dbSkip())

		Enddo
		_cRet := "1"
		RestArea(aAreaSC9)
		RestArea(aArea)		
		Return _cRet
	EndIf 

	RestArea(aAreaSC9)
	RestArea(aArea)

Return
