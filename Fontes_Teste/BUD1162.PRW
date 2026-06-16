#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*******************************************************************************************
*	Data		: 04/08/2014															   *
*	Responsável	: Thiago Lucas Machado                                                     *
*   Setor  		: Logística                                                                *
*   Usuário		: Gaúcho/Jairo/Deise                                                       *
*   ------------------------------------------------------------------------------------   *
*	Descrição   : Gravação do status logística e registro dos logs                         *
********************************************************************************************/
User Function BUD1162(cPedido, cStatus, cUser)

	Default cPedido := ''
	Default cUser   := Alltrim(Substr(cUsuario,7,15))
	
	// 1) Validação dos parâmetros:
	if Empty(cPedido) .Or. Empty(cStatus)
		Return
	EndIf

	// 2) Validação do registro:
	If (Select("TT1162A") <> 0)
		dbSelectArea("TT1162A")
		dbCloseArea()
	EndIf
	cQuery := "SELECT TOP 1 ZC2_STATUS, ZC2_USUARI, ZC2_DATA, ZC2_HORA "
		cQuery += "FROM "+RetSqlName("ZC2")+" (NOLOCK) "
	cQuery += "WHERE ZC2_FILIAL = '"+xFilial("ZC2")+"' "
		cQuery += "AND ZC2_PEDIDO = '"+cPedido+"' "
		cQuery += "AND "+RetSqlName("ZC2")+".D_E_L_E_T_ = '' "
	cQuery += "ORDER BY ZC2_DATA DESC, ZC2_HORA DESC "
	TCQUERY cQuery NEW ALIAS "TT1162A"
	If TT1162A->(!Eof())
		// Caso o status atual seja o mesmo do último log daquele pedido, eu saio da rotina:
		If (AllTrim(TT1162A->ZC2_STATUS) == AllTrim(cStatus)) .And. (Alltrim(cUser) == AllTrim(TT1162A->ZC2_USUARI))
			Return
		EndIf
	EndIf

	// 3) Faço inclusão na tabela de log:
	ZC2->(RecLock("ZC2",.T.))
		ZC2->ZC2_FILIAL	:= xFilial("ZC2")
		ZC2->ZC2_DATA	:= MsDate()
		ZC2->ZC2_HORA	:= Substr(Time(),1,5)
		ZC2->ZC2_USUARI	:= Left(AllTrim(cUser), TamSx3('ZC2_USUARI')[1])
		ZC2->ZC2_PEDIDO	:= cPedido
		ZC2->ZC2_STATUS	:= Left(AllTrim(cStatus), TamSx3('ZC2_STATUS')[1])
	ZC2->(MsUnLock("ZC2"))

	// 4) Efetuo UPDATE no Pedido de Vendas
	if xFilial("SC5") == "01"
		// Campo C5_STLOGIS somente liberado para a filial 01:
		cUpdate := "UPDATE " + RETSQLNAME("SC5") + " SET C5_STLOGIS = '"+Left(AllTrim(cStatus), TamSx3('C5_STLOGIS')[1])+"' "
		cUpdate += "WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
			cUpdate += "AND C5_NUM = '"+cPedido+"' "
			cUpdate += "AND D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpdate)
	EndIf

	// 4.1) Efetuo UPDATE no ZCA status
	cUpdate := ""
	cUpdate += "UPDATE " + RETSQLNAME("ZCA") + " SET ZCA_STATUS = '"+Left(AllTrim(cStatus), TamSx3('ZCA_STATUS')[1])+"' "
	cUpdate += "WHERE ZCA_FILIAL = '01' "
		cUpdate += "AND ZCA_PEDIDO = '"+cPedido+"' "
		cUpdate += "AND D_E_L_E_T_ = '' "
	TCSQLEXEC(cUpdate) 
	
	// 5) Baixo status de recebimento do coletor
	if AllTrim(cStatus) == "RECEBIDO COLETOR"
		cUpdate := ""
		cUpdate += "UPDATE " + RETSQLNAME("ZCA") + " SET ZCA_STENCA = '"+Left(AllTrim(cStatus), TamSx3('ZCA_STENCA')[1])+"' "
		cUpdate += "								   , ZCA_STATUS = '"+Left(AllTrim(cStatus), TamSx3('ZCA_STATUS')[1])+"' "
		cUpdate += "								   , ZCA_DTATU = '"+DtoS(MsDate())+"' "
		cUpdate += "								   , ZCA_HRATU = '"+Substr(Time(),1,5)+"' "		
		cUpdate += "								   , ZCA_USUORI = '"+Left(AllTrim(cUser), TamSx3('ZCA_USUORI')[1])+"' "
		cUpdate += "WHERE ZCA_FILIAL = '01' "
			cUpdate += "AND ZCA_PEDIDO = '"+cPedido+"' "
			cUpdate += "AND ZCA_STENCA NOT LIKE '%FATURAMENTO%' "
			cUpdate += "AND D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpdate) 
		
		cUpdate := ""
		cUpdate += "UPDATE " + RETSQLNAME("ZCA") + " SET ZCA_STENCA = '"+Left(AllTrim(cStatus), TamSx3('ZCA_STENCA')[1])+"' "
		cUpdate += "								   , ZCA_STATUS = 'APTO A FATURAR' "
		cUpdate += "								   , ZCA_DTATU = '"+DtoS(MsDate())+"' "
		cUpdate += "								   , ZCA_HRATU = '"+Substr(Time(),1,5)+"' "		
		cUpdate += "								   , ZCA_USUORI = '"+Left(AllTrim(cUser), TamSx3('ZCA_USUORI')[1])+"' "
		cUpdate += "WHERE ZCA_FILIAL = '01' "
			cUpdate += "AND ZCA_PEDIDO = '"+cPedido+"' "
			cUpdate += "AND ZCA_STENCA LIKE '%FATURAMENTO%' "
			cUpdate += "AND D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpdate) 		
	EndIf

	// 6) Status de encaixotamento:
	if AllTrim(cStatus) == "ENVIADO COLETOR"
		cUpdate := ""
		cUpdate += "UPDATE " + RETSQLNAME("ZCA") + " SET ZCA_STATUS = 'ENCAIXOTANDO' "
		cUpdate += "								   , ZCA_DTATU = '"+DtoS(MsDate())+"' "
		cUpdate += "								   , ZCA_HRATU = '"+Substr(Time(),1,5)+"' "		
		cUpdate += "								   , ZCA_USUORI = '"+Left(AllTrim(cUser), TamSx3('ZCA_USUORI')[1])+"' "	
		cUpdate += "WHERE ZCA_FILIAL = '01' "
			cUpdate += "AND ZCA_PEDIDO = '"+cPedido+"' "
			cUpdate += "AND D_E_L_E_T_ = '' "
		TCSQLEXEC(cUpdate) 		
	EndIf

Return
