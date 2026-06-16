#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*
/=========================================================================\
|Módulo      : Estoque/Compras/Faturamento                         		  |
|=========================================================================|
|Programa    : BUD1391.PRW                                  		      |
|=========================================================================|
|Descricao   : Gera NF de retorno Facção, apontamento e envio para dep.   |
|=========================================================================|
|Data        : 31/03/2021 												  |
|=========================================================================|
|Programador : Desenvolvimento - Compassio               				  |
\=========================================================================/
*/
// Chamada manual:
User Function BUD1391()
	LjMsgRun(OemToAnsi('Processando notas fiscais da facção. Aguarde!'),,{|| U_BD1391Proc()} )
Return

// Chamada através do workflow:
User Function BD1391Auto()
	U_BD1391Proc("01", "01")
Return

// Função padrão
User Function BD1391Proc(xCodEmp, xCodFil)

	Local cStErro		:= ""
	Local lEnvMail		:= .F.
	Local cRotina		:= "BUD1391"

	Private cCamErro	:= "\"
	Private cArqErro	:= "ErroFaccao.log"
	Private cNomeResp	:= "AUTO.FACCAO"
	Private cTmpExpira	:= ""
	Private __AUTO 		:= IIf((xCodEmp <> Nil) .And. (xCodFil <> Nil), .T., .F.)
	Private cSQL		:= "" //24/11/2025

	If (__AUTO)
		U_BUD1427("# Inicio da execucao do BUD1391 as "+Time())
		RpcSetEnv(xCodEmp,xCodFil,,,,"SIGACOM",,)
	EndIf

	// Verifico se o modo inventário está ativado:
	If GetMV("BD_MODINVE")
		U_BUD1427("Modo inventário ativado [BUD1391]!")
		If (__AUTO)
			RpcClearEnv()
		EndIf
		Return "ERRO: Modo inventário está ativado!"
	EndIf

	// Controle de execução do schedule:
	If !MayIUseCode(cRotina)
		U_BUD1427("Rotina ["+cRotina+"] já está em execução!")
		If (__AUTO)
			RpcClearEnv()
		EndIf
		Return "ERRO: Rotina já está em execução!"
	EndIf

	// Chamo tempo de expiração:
	cTmpExpira	:= U_B1391Param("FACCAO", "PROC_TEMPO")

	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Destravo processamentos antigos:
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	// Destravamento das flags:
	If (Select("TT1391") <> 0)
		DbSelectArea("TT1391")
		DbCloseArea()
	Endif
	cQuery := "SELECT DISTINCT ZE8_CODIGO, ZE8_PROCFL FROM ZE8010 (NOLOCK) WHERE ZE8_FILIAL = '' AND ZE8_STATUS = 'FINALIZADO' AND ZE8_PROCFL <> '' AND ZE8_PROCFL <> 'OK' AND ZE8010.D_E_L_E_T_ = '' ORDER BY ZE8_PROCFL ASC "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391"
	If !TT1391->(Eof())
		While !TT1391->(Eof())
			If ElapTime(Right(AllTrim(TT1391->ZE8_PROCFL), 8), Time()) >= cTmpExpira
				// Então destravo processamento para permitir execução:
				/*cUpd := "UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PROCESSAMENTO EXPIRADO' "
				cUpd += "				 , ZE8_PROCFL = '' "
				cUpd += "				 , ZE8_STENTR = IIF(ZE8_STENTR = 'PROCESSANDO', 'AGUARDANDO', ZE8_STENTR) "
				cUpd += "				 , ZE8_STCOBR = IIF(ZE8_STCOBR = 'PROCESSANDO', 'AGUARDANDO', ZE8_STCOBR) "
				cUpd += "				 , ZE8_STAPON = IIF(ZE8_STAPON = 'PROCESSANDO', 'AGUARDANDO', ZE8_STAPON) "
				cUpd += "				 , ZE8_STTRAN = IIF(ZE8_STTRAN = 'PROCESSANDO', 'AGUARDANDO', ZE8_STTRAN) "
				cUpd += "				 , ZE8_NUMROM = IIF(ZE8_NUMROM = 'ZZZZZZ', '', ZE8_NUMROM) "
				cUpd += "WHERE ZE8_FILIAL = '' "
					cUpd += "AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' "
					cUpd += "AND ZE8_STATUS = 'FINALIZADO' "
					cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
				TcSQLExec(cUpd)	*/

				//24/11/2025 - PERSONALITEC
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " ZE8010 "
				cSQL += " WHERE ZE8010.D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + TT1391->ZE8_CODIGO + "' "
				cSQL += "   AND ZE8_STATUS = 'FINALIZADO' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				If !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] PROCESSAMENTO EXPIRADO"
						ZE8->ZE8_PROCFL := ""
						ZE8->ZE8_STENTR := IIF(ZE8->ZE8_STENTR == "PROCESSANDO", "AGUARDANDO", ZE8->ZE8_STENTR)
						ZE8->ZE8_STCOBR := IIF(ZE8->ZE8_STCOBR == "PROCESSANDO", "AGUARDANDO", ZE8->ZE8_STCOBR)
						ZE8->ZE8_STAPON := IIF(ZE8->ZE8_STAPON == "PROCESSANDO", "AGUARDANDO", ZE8->ZE8_STAPON)
						ZE8->ZE8_STTRAN := IIF(ZE8->ZE8_STTRAN == "PROCESSANDO", "AGUARDANDO", ZE8->ZE8_STTRAN)
						ZE8->ZE8_NUMROM := IIF(ZE8->ZE8_NUMROM == "ZZZZZZ", "", ZE8->ZE8_NUMROM)
						MsUnlock()
					EndIf
				EndIf

				TMPZE8->(DbCloseArea())

			EndIf
			TT1391->(DbSkip())
		EndDo
	EndIf

	// Verifico notas fiscais de industrializações geradas manualmente:
	/*cUpd := "UPDATE ZE8010 SET ZE8_NFENTR = F1_DOC, ZE8_SEENTR = F1_SERIE, ZE8_STENTR = 'GERADO' "
		cUpd += "FROM ZE8010 (NOLOCK) "
		cUpd += "INNER JOIN SF1010 (NOLOCK) ON F1_FILIAL = '01' AND F1_CHVNFE = ZE8_CHVIND AND SF1010.D_E_L_E_T_ = '' "
	cUpd += "WHERE ZE8_FILIAL = '' "
		cUpd += "AND ZE8_PROCFL = '' "
		cUpd += "AND ZE8_STENTR IN ('ERRO', 'AGUARDANDO') "
		cUpd += "AND ZE8_CHVIND <> '' "
		cUpd += "AND ZE8_STATUS = 'FINALIZADO' "
		cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
	TcSQLExec(cUpd)*/
	//17/11/2025 - PERSONALITEC
	If Select("TMPZE8") > 0
		TMPZE8->(DbCloseArea())
	EndIf

	cSQL := "SELECT ZE8010.R_E_C_N_O_, "
	cSQL += "       SF1010.F1_DOC      AS F1_DOC, "   //16/01/2026 - PERSONALITEC - Incluido campo para ser usado no reclock
	cSQL += "       SF1010.F1_SERIE    AS F1_SERIE "  //16/01/2026 - PERSONALITEC - Incluido campo para ser usado no reclock
	cSQL += "  FROM " + RetSqlName("ZE8") + " ZE8010 "
	cSQL += "  INNER JOIN " + RetSqlName("SF1") + " SF1010 "
	cSQL += "          ON SF1010.D_E_L_E_T_ = '' "
	cSQL += "         AND F1_FILIAL = '01' "
	cSQL += "         AND F1_CHVNFE = ZE8_CHVIND "
	cSQL += " WHERE ZE8010.D_E_L_E_T_ = '' "
	cSQL += "   AND ZE8_FILIAL = '' "
	cSQL += "   AND ZE8_PROCFL = '' "
	cSQL += "   AND ZE8_STENTR IN ('ERRO', 'AGUARDANDO') "
	cSQL += "   AND ZE8_CHVIND <> '' "
	cSQL += "   AND ZE8_STATUS = 'FINALIZADO' "

	cSQL := ChangeQuery(cSQL)
	TCQUERY cSQL NEW ALIAS "TMPZE8"

	DbSelectArea("TMPZE8")
	TMPZE8->(DbGoTop())

	While !TMPZE8->(Eof())
		DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))

		//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
		If RecLock("ZE8", .F.)
			ZE8->ZE8_NFENTR := TMPZE8->F1_DOC //16/01/2026 - PERSONALITEC - Correção para buscar o documento da query
			ZE8->ZE8_SEENTR := TMPZE8->F1_SERIE //16/01/2026 - PERSONALITEC - Correção para buscar o documento da query
			ZE8->ZE8_STENTR := "GERADO"
			MsUnlock()
		EndIf

		TMPZE8->(DbSkip())
	EndDo

	TMPZE8->(DbCloseArea())

	// Verifico notas fiscais de cobrança geradas manualmente:
	/*cUpd := "UPDATE ZE8010 SET ZE8_NFCOBR = F1_DOC, ZE8_SECOBR = F1_SERIE, ZE8_STCOBR = 'GERADO' "
		cUpd += "FROM ZE8010 (NOLOCK) "
		cUpd += "INNER JOIN SF1010 (NOLOCK) ON F1_FILIAL = '01' AND F1_CHVNFE = ZE8_CHVCOB AND SF1010.D_E_L_E_T_ = '' "
	cUpd += "WHERE ZE8_FILIAL = '' "
		cUpd += "AND ZE8_PROCFL = '' "
		cUpd += "AND ZE8_STCOBR IN ('ERRO', 'AGUARDANDO') "
		cUpd += "AND ZE8_CHVCOB <> '' "
		cUpd += "AND ZE8_STATUS = 'FINALIZADO' "
		cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
	TcSQLExec(cUpd)*/

	//17/11/2025 - PERSONALITEC
	If Select("TMPZE8") > 0
		TMPZE8->(DbCloseArea())
	EndIf

	cSQL := "SELECT ZE8010.R_E_C_N_O_, "
	cSQL += "       SF1010.F1_DOC      AS F1_DOC, "   //16/01/2026 - PERSONALITEC - Incluido campo para ser usado no reclock
	cSQL += "       SF1010.F1_SERIE    AS F1_SERIE "  //16/01/2026 - PERSONALITEC - Incluido campo para ser usado no reclock
	cSQL += "  FROM " + RetSqlName("ZE8") + " ZE8010 "
	cSQL += "  INNER JOIN " + RetSqlName("SF1") + " SF1010 "
	cSQL += "          ON SF1010.D_E_L_E_T_ = '' "
	cSQL += "         AND F1_FILIAL = '01' "
	cSQL += "         AND F1_CHVNFE = ZE8_CHVCOB "
	cSQL += " WHERE ZE8010.D_E_L_E_T_ = '' "
	cSQL += "   AND ZE8_FILIAL = '' "
	cSQL += "   AND ZE8_PROCFL = '' "
	cSQL += "   AND ZE8_STCOBR IN ('ERRO', 'AGUARDANDO') "
	cSQL += "   AND ZE8_CHVCOB <> '' "
	cSQL += "   AND ZE8_STATUS = 'FINALIZADO' "

	cSQL := ChangeQuery(cSQL)
	TCQUERY cSQL NEW ALIAS "TMPZE8"

	DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workarea
	TMPZE8->(DbGoTop())
	While !TMPZE8->(Eof())
		DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
		//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
		If RecLock("ZE8", .F.)
			ZE8->ZE8_NFCOBR := TMPZE8->F1_DOC	//16/01/2026 - PERSONALITEC - Correção para buscar o documento da query
			ZE8->ZE8_SECOBR := TMPZE8->F1_SERIE //16/01/2026 - PERSONALITEC - Correção para buscar o documento da query
			ZE8->ZE8_STCOBR := "GERADO"
			MsUnlock()
		EndIf

		TMPZE8->(DbSkip())
	EndDo

	TMPZE8->(DbCloseArea())

	// Verifico se alguma OP retornou por outra NF anteriormente:
	If (Select("TT1391") <> 0)
		DbSelectArea("TT1391")
		DbCloseArea()
	Endif

	cQuery := "SELECT TOP 1 ZE8_CODIGO, ZE8_NUMOP, F1_DOC, F1_SERIE, F1_CHVNFE, F4_DUPLIC "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "INNER JOIN SD1010 (NOLOCK) ON D1_FILIAL = '01' AND D1_OP = ZE8_NUMOP AND D1_DOC <> ZE8_NFENTR AND SD1010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SF1010 (NOLOCK) ON F1_FILIAL = '01' AND F1_DOC = D1_DOC AND F1_SERIE = D1_SERIE AND F1_FORNECE = D1_FORNECE AND F1_LOJA = D1_LOJA AND F1_EMISSAO = D1_EMISSAO AND SF1010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SF4010 (NOLOCK) ON F4_FILIAL = '' AND F4_CODIGO = D1_TES AND SF4010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND (ZE8_NFENTR = '' OR ZE8_NFCOBR = '') "
	cQuery += "AND ZE8_PROCFL = '' "
	cQuery += "AND F1_EMISSAO >= '"+DtoS(MsDate() - 365)+"' "
	cQuery += "AND ZE8_STATUS = 'FINALIZADO' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391"
	If !TT1391->(Eof())
		While !TT1391->(Eof())
			/*
				cCmpUPD	:= ""

				// Verifico tipo da NF:
				if AllTrim(TT1391->F4_DUPLIC) == "S"
					cCmpUPD	:= "ZE8_NFCOBR = '"+AllTrim(TT1391->F1_DOC)+"', ZE8_SECOBR = '"+AllTrim(TT1391->F1_SERIE)+"', ZE8_STCOBR = 'GERADO'"
				Else
					cCmpUPD	:= "ZE8_NFENTR = '"+AllTrim(TT1391->F1_DOC)+"', ZE8_SEENTR = '"+AllTrim(TT1391->F1_SERIE)+"', ZE8_STENTR = 'GERADO'"
				EndIf
				// Acerto campos na ZE8:
				TcSQLExec("UPDATE ZE8010 SET "+cCmpUPD+", ZE8_STAPON = 'NF_MANUAL', ZE8_STTRAN = 'NF_MANUAL', ZE8_NUMROM = 'ZZZZZZ' WHERE ZE8_FILIAL = '' AND ZE8_STATUS = 'FINALIZADO' AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' AND ZE8010.D_E_L_E_T_ = '' ")
			*/

			// Seto erro de carga caso a OP já foi retoranda em outra NF anteriormente:
			cMsg := "["+DtoC(dDataBase)+" "+Time()+"] ERRO: A OP ["+AllTrim(TT1391->ZE8_NUMOP)+"] JA FOI ENVIADA PELA NF "+AllTrim(TT1391->F1_DOC)+"/"+AllTrim(TT1391->F1_SERIE)+". FAVOR VERIFICAR!"
			/*cUpd := "UPDATE ZE8010 SET ZE8_STCOBR = 'ERRO' "
							cUpd += ", ZE8_STENTR = 'ERRO' "
							cUpd += ", ZE8_STAPON = 'ERRO' "
							cUpd += ", ZE8_STATUS = 'ERRO' "
							cUpd += ", ZE8_PROCFL = 'ERRO' "
							cUpd += ", ZE8_NUMROM = 'XXXXXX' "
							cUpd += ", ZE8_PROC = '"+cMsg+"' "
			cUpd += "FROM ZE8010 (NOLOCK) "
			cUpd += "WHERE ZE8_FILIAL = '' "
				cUpd += "AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' "
				cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
			TcSQLExec(cUpd)*/

			//24/11/2025 - PERSONALITEC
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + TT1391->ZE8_CODIGO + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_STCOBR := "ERRO"
					ZE8->ZE8_STENTR := "ERRO"
					ZE8->ZE8_STAPON := "ERRO"
					ZE8->ZE8_STATUS := "ERRO"
					ZE8->ZE8_PROCFL := "ERRO"
					ZE8->ZE8_NUMROM := "XXXXXX"
					ZE8->ZE8_PROC   := cMsg
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			TT1391->(DbSkip())
		EndDo
	EndIf
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

	// Seto variáveis de usuário:
	cUserName	:= IIF(Empty(cUserName), AllTrim(cNomeResp), cUserName)
	cUsuario	:= IIF(Empty(cUsuario), "******"+AllTrim(cNomeResp), cUsuario)

	If (Select("TT1391") <> 0)
		DbSelectArea("TT1391")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE8_CODIGO, ZE8_STENTR, ZE8_STCOBR, ZE8_STTRAN, ZE8_DESTIN, ZE8_NUMROM, MIN(ZE8_STAPON) AS ZE8_STAPON "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_PROCFL = '' "
	cQuery += "AND 'AGUARDANDO' IN (ZE8_STENTR, ZE8_STCOBR, ZE8_STAPON, ZE8_STTRAN) "
	cQuery += "AND ZE8_STATUS = 'FINALIZADO' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY ZE8_CODIGO, ZE8_STENTR, ZE8_STCOBR, ZE8_STTRAN, ZE8_DESTIN, ZE8_NUMROM "
	cQuery += "ORDER BY IIF(ISNULL((SELECT TOP 1 ZE8_ERRO.ZE8_CODIGO "
	cQuery += "FROM ZE8010 (NOLOCK) ZE8_ERRO "
	cQuery += "WHERE ZE8_ERRO.ZE8_FILIAL = '' "
	cQuery += "AND ZE8_ERRO.ZE8_CODIGO = ZE8010.ZE8_CODIGO "
	cQuery += "AND 'ERRO' IN (ZE8_ERRO.ZE8_STENTR, ZE8_ERRO.ZE8_STCOBR, ZE8_ERRO.ZE8_STAPON, ZE8_ERRO.ZE8_STTRAN) "
	cQuery += "AND ZE8_ERRO.D_E_L_E_T_ = ''), 'N_ERRO') = 'N_ERRO', 'A', 'B') ASC"
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391"
	If !TT1391->(Eof())
		// Seto status de processamento:
		//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] INICIANDO PROCESSAMENTO', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + TT1391->ZE8_CODIGO + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] INICIANDO PROCESSAMENTO"
				ZE8->ZE8_PROCFL := DtoS(dDataBase) + "_" + StrTran(Time(), ":", "")
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		// Efetuo processamento da NF de industrialização:
		If Empty(cStErro) .And. AllTrim(TT1391->ZE8_STENTR) == "AGUARDANDO"
			lEnvMail	:= .T.
			cStErro 	:= GeraNFEntr(1, TT1391->ZE8_CODIGO)
		EndIf

		// Efetuo processamento da NF de cobrança:
		If Empty(cStErro) .And. AllTrim(TT1391->ZE8_STCOBR) == "AGUARDANDO"
			lEnvMail	:= .T.
			cStErro 	:= GeraNFEntr(2, TT1391->ZE8_CODIGO)
		EndIf

		// Os demais processos serão apenas efetuados se o destino for depósito:
		If Empty(cStErro)
			If AllTrim(TT1391->ZE8_DESTIN) == "DEPOSITO"
				// Efetuo processamento de apontamento da OP:
				If Empty(cStErro) .And. AllTrim(TT1391->ZE8_STAPON) == "AGUARDANDO"
					cStErro 	:= ApontaOP(TT1391->ZE8_CODIGO)
				EndIf

				// Efetuo geração de ordem de endereçamento no CD:
				If Empty(cStErro) .And. Empty(TT1391->ZE8_NUMROM)
					// Criar rotina para gerar ordem de coleta alimentando a ZDU:
					cStErro := GeraZDUOrd(TT1391->ZE8_CODIGO)
				EndIf

				// Efetuo processamento de nota fiscal de transferência para depósito:
				If Empty(cStErro) .And. AllTrim(TT1391->ZE8_STTRAN) == "AGUARDANDO"
					// Criar rotina para para geração de romaneio + pedido + NF de saída de transferência para o depósito:
					lEnvMail	:= .T.
					cStErro 	:= GeraNFTran(TT1391->ZE8_CODIGO)
				EndIf
			Else
				// Caso contrário, apenas baixo as flags existentes:
				If TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'N_NECESSARIO', ZE8_STTRAN = 'N_NECESSARIO', ZE8_NUMROM = 'XXXXXX' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' AND ZE8010.D_E_L_E_T_ = '' ") < 0
					cStRet	:= AllTrim(TCSQLError())
					//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

					//24/11/2025 - PERSONALITEC
					If Select("TMPZEA") > 0
						TMPZEA->(DbCloseArea())
					EndIf

					cSQL := "SELECT R_E_C_N_O_ "
					cSQL += "  FROM " + RetSqlName("ZE8") + " "
					cSQL += " WHERE D_E_L_E_T_ = '' "
					cSQL += "   AND ZE8_FILIAL = '' "
					cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

					cSQL := ChangeQuery(cSQL)
					TCQUERY cSQL NEW ALIAS "TMPZEA"

					TMPZEA->(DbGoTop())
					While !TMPZEA->(Eof())
						DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						ZE8->(DbGoTo(TMPZEA->R_E_C_N_O_))
						//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
						If RecLock("ZE8", .F.)
							ZE8->ZE8_PROC := cStRet
							MsUnlock()
						EndIf

						TMPZEA->(DbSkip())
					EndDo

					TMPZEA->(DbCloseArea())
					Return cStRet
				EndIf
			EndIf
		EndIf

		// Envio e-mail:
		If Empty(cStErro) .And. lEnvMail
			EnviaMail(TT1391->ZE8_CODIGO)
		EndIf

		// Seto status de processamento:
		If Empty(cStErro)
			//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] FIM DO PROCESSAMENTO', ZE8_PROCFL = 'OK' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + TT1391->ZE8_CODIGO + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] FIM DO PROCESSAMENTO"
					ZE8->ZE8_PROCFL := "OK"
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

		Else
			// Baixo flag:
			//TcSQLExec("UPDATE ZE8010 SET ZE8_PROCFL = '' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+TT1391->ZE8_CODIGO+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + TT1391->ZE8_CODIGO + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_PROCFL := ""
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())
		EndIf
	EndIf

	Leave1Code(cRotina)

	If (__AUTO)
		U_BUD1427("# Fim da execucao do BUD1391 as "+Time())
		RpcClearEnv()
	EndIf

Return

// Rotina para efetuar a geração das notas fiscais de entrada:
Static Function GeraNFEntr(nTp, cCodCarga)

	Local cStRet 		:= ""
	Local aTitulo		:= {"NF de Industrializacao", "NF de Cobranca"}
	Local aStCampo		:= {"ZE8_STENTR", "ZE8_STCOBR"}
	Local aDocCampo		:= {"ZE8_NFENTR", "ZE8_NFCOBR"}
	Local aSerCampo		:= {"ZE8_SEENTR", "ZE8_SECOBR"}
	Local aChvCampo		:= {"ZE8_CHVIND", "ZE8_CHVCOB"}
	Local aXMLCampo		:= {"ZE8_XMLIND", "ZE8_XMLCOB"}
	Local cCNPJFor		:= ""
	Local aInfoXML		:= {}
	Local aFormulSF1	:= {"N", "N"}
	Local aCondNF		:= {"", ""}
	Local cCodCobr		:= ""
	Local aQuery		:= {"", "", ""}
	Local cQuery		:= ""
	Local aAutoItens	:= {}
	Local aAutoCab		:= {}
	Local aReg			:= {}
	Local cCF			:= ""
	Local cDocForn		:= ""
	Local cChvNFe		:= ""
	Local cSerForn		:= ""
	Local cCodForn		:= ""
	Local cLojaForn		:= ""
	Local dEmisForn		:= ""
	Local nPrcUnit		:= 0
	Local nQtdNF		:= 0
	Local aLogAuto		:= {}
	Local _z			:= 0
	Local lMsErroAuto	:= .F.
	Local aRetXML		:= {}
	Local nVldQtd		:= 0
	Local nVldVlr		:= 0
	Local nVlrRec		:= 0
	Local nDifVlr		:= 0
	Local nTotNF		:= 0

	// Seto status de processamento:
	If TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'PROCESSANDO', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PROCESSANDO "+Upper(aTitulo[nTp])+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ") < 0
		cStRet	:= AllTrim(TCSQLError())
		//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
				ZE8->ZE8_PROC := cStRet
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		Return cStRet
	EndIf

	// Inicialmente, verifico se as NFs já foram geradas anteriormente:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 F1_DOC FROM SF1010 (NOLOCK) "
	cQuery += "INNER JOIN ZE8010 (NOLOCK) ON ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN ZA9010 (NOLOCK) ON ZA9_FILIAL = '01' AND ZA9_NUMOP = ZE8_NUMOP AND ZA9010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = ZA9_PEDFAC AND SC5010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SA2010 (NOLOCK) ON A2_FILIAL = '' AND A2_COD = C5_CLIENTE AND A2_LOJA = C5_LOJACLI AND SA2010.D_E_L_E_T_ = '' "
	cQuery += "WHERE F1_FILIAL = '01' "
	cQuery += "AND F1_DOC = "+aDocCampo[nTp]+" "
	cQuery += "AND SUBSTRING(F1_SERIE, PATINDEX('%[^0]%', F1_SERIE+'.'), LEN(F1_SERIE)) = SUBSTRING("+aSerCampo[nTp]+", PATINDEX('%[^0]%', "+aSerCampo[nTp]+"+'.'), LEN("+aSerCampo[nTp]+")) "
	cQuery += "AND F1_CHVNFE = "+aChvCampo[nTp]+" "
	cQuery += "AND F1_FORNECE = A2_COD "
	cQuery += "AND F1_LOJA = A2_LOJA "
	cQuery += "AND SF1010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	If !TT1391A->(Eof())
		cStRet		:= "["+DtoC(dDataBase)+" "+Time()+"] A "+Upper(aTitulo[nTp])+" JA FOI GERADA ANTERIORMENTE"
		//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'GERADO', ZE8_PROC = '"+cStRet+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->( FieldPut(FieldPos(aStCampo[nTp]), "GERADO") )
				ZE8->ZE8_PROC   := cStRet
				ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		Return ""
	EndIf

	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	 * Definições das consultas conforme tipo da NF:                               *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
	// Consulta tipo nota de industrização:
	aQuery[1] := "SELECT DISTINCT ZE8_NUMOP AS 'OP', A2_COD AS 'COD_FORN', A2_LOJA AS 'LOJA_FORN', A2_CGC AS 'CNPJ_FORN', D2_COD AS 'COD', D2_LOCAL AS 'LOCAL_NF', D2_QUANT AS 'QTD', D2_DOC AS 'NF_ORI', D2_SERIE AS 'SERIE_ORI', "
	aQuery[1] += "D2_ITEM AS 'ITEM', D2_IDENTB6 AS 'IDENT', D2_PRCVEN AS 'PRUNIT', F4_TESDV AS 'TES_ENV', F4_TESDV AS 'TES', D2_TOTAL AS 'TOT_NF', A2_COND AS 'COND', "
	aQuery[1] += aDocCampo[nTp]+" AS 'DOC', "+aSerCampo[nTp]+" AS 'SERIE', "+aChvCampo[nTp]+" AS 'CHV' "
	aQuery[1] += "FROM ZE8010 (NOLOCK) "
	aQuery[1] += "LEFT JOIN ZA9010 (NOLOCK) ON ZA9_FILIAL = '01' AND ZA9_NUMOP = ZE8_NUMOP AND ZA9010.D_E_L_E_T_ = '' "
	aQuery[1] += "LEFT JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = ZA9_PEDFAC AND SC5010.D_E_L_E_T_ = '' "
	aQuery[1] += "LEFT JOIN SA2010 (NOLOCK) ON A2_FILIAL = '' AND A2_COD = C5_CLIENTE AND A2_LOJA = C5_LOJACLI AND SA2010.D_E_L_E_T_ = '' "
	aQuery[1] += "LEFT JOIN SD2010 (NOLOCK) ON D2_FILIAL = '01' AND D2_PEDIDO = ZA9_PEDFAC AND D2_ITEMPV = ZA9_ITEFAC AND D2_CLIENTE = A2_COD AND D2_LOJA = A2_LOJA AND SD2010.D_E_L_E_T_ = '' "
	aQuery[1] += "LEFT JOIN SB6010 (NOLOCK) ON B6_FILIAL = '01' AND B6_CLIFOR = D2_CLIENTE AND B6_IDENT = D2_IDENTB6 AND B6_PRODUTO = D2_COD AND B6_SALDO > 0 AND B6_CLIFOR = A2_COD AND B6_LOJA = D2_LOJA AND SB6010.D_E_L_E_T_ = '' "
	aQuery[1] += "LEFT JOIN SF4010 (NOLOCK) ON F4_FILIAL = '' AND F4_CODIGO = B6_TES AND SF4010.D_E_L_E_T_ = '' "
	aQuery[1] += "WHERE ZE8_FILIAL = '' "
	aQuery[1] += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	aQuery[1] += "AND ZE8010.D_E_L_E_T_ = '' "

	// Consulta tipo nota de cobrança:
	cCodCobr	:= U_B1391Param("FACCAO", "COB_PROD")
	aCondNF[2]	:= U_B1391Param("FACCAO", "COB_COND")
	aQuery[2] := "SELECT DISTINCT ZE8_NUMOP AS 'OP', ZE8_PRODUT AS 'COD_PA', A2_COD AS 'COD_FORN', A2_LOJA AS 'LOJA_FORN', A2_CGC AS 'CNPJ_FORN', '"+cCodCobr+"' AS 'COD', B1_LOCPAD AS 'LOCAL_NF', ZA9_QTDFAC AS 'QTD', '"+Space(TamSx3('D2_DOC')[1])+"' AS 'NF_ORI', '"+Space(TamSx3('D2_SERIE')[1])+"' AS 'SERIE_ORI', "
	aQuery[2] += "'"+Space(TamSx3('D2_ITEM')[1])+"' AS 'ITEM', '"+Space(TamSx3('D2_IDENTB6')[1])+"' AS 'IDENT', 0 AS 'PRUNIT', '' AS 'TES_ENV', B1_TE AS 'TES', '"+aCondNF[nTp]+"' AS 'COND', ZA9_ETIQ AS 'ETIQ_ADIC', "
	aQuery[2] += aDocCampo[nTp]+" AS 'DOC', "+aSerCampo[nTp]+" AS 'SERIE', "+aChvCampo[nTp]+" AS 'CHV' "
	aQuery[2] += "FROM ZE8010 (NOLOCK) "
	aQuery[2] += "LEFT JOIN ZA9010 (NOLOCK) ON ZA9_FILIAL = '01' AND ZA9_NUMOP = ZE8_NUMOP AND ZA9010.D_E_L_E_T_ = '' "
	aQuery[2] += "LEFT JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = ZA9_PEDFAC AND SC5010.D_E_L_E_T_ = '' "
	aQuery[2] += "LEFT JOIN SA2010 (NOLOCK) ON A2_FILIAL = '' AND A2_COD = C5_CLIENTE AND A2_LOJA = C5_LOJACLI AND SA2010.D_E_L_E_T_ = '' "
	aQuery[2] += "LEFT JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = '"+cCodCobr+"' AND SB1010.D_E_L_E_T_ = '' "
	aQuery[2] += "LEFT JOIN SD2010 (NOLOCK) ON D2_FILIAL = '01' AND D2_PEDIDO = ZA9_PEDFAC AND D2_ITEMPV = ZA9_ITEFAC AND D2_CLIENTE = A2_COD AND D2_LOJA = A2_LOJA AND SD2010.D_E_L_E_T_ = '' "
	aQuery[2] += "WHERE ZE8_FILIAL = '' "
	aQuery[2] += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	aQuery[2] += "AND ZE8010.D_E_L_E_T_ = '' "
	/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

	// Busco quantidades e itens da carga:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := ChangeQuery(aQuery[nTp])
	TCQuery cQuery NEW ALIAS "TT1391A"

	While !TT1391A->(Eof())
		// Verifico se achou documento de origem:
		If Empty(TT1391A->PRUNIT) .And. nTp == 1
			cStRet	:= "NF. DE ORIGEM NAO ENCONTRADA OU SEM SALDO ["+TT1391A->IDENT+"]"
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido existência o cadastro de fornecedor:
		If Empty(TT1391A->COD_FORN)
			cStRet	:= "CODIGO DO FORNECEDOR NAO ENCONTRADO ["+TT1391A->COD_FORN+"]"
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido existência do poder de terceiros:
		If Empty(TT1391A->COD)
			cStRet	:= "NOTA FISCAL DE SAIDA NAO ENCONTRADA"
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido existência do poder de terceiros:
		If Empty(TT1391A->TES)
			cStRet	:= "TES DE RETORNO NAO IDENTIFICADA PARA O ENVIO ["+AllTrim(TT1391A->TES_ENV)+"]"
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido existência do preenchimento da NF:
		If Empty(TT1391A->DOC) .Or. Empty(TT1391A->SERIE)
			cStRet	:= "NUMERO DA NOTA FISCAL OU SERIE NAO INFORMADOS PARA A CARGA ["+cCodCarga+"] "
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido existência da chave da NFE:
		If Empty(TT1391A->CHV)
			cStRet	:= "CHAVE DA NOTA FISCAL NAO INFORMADA PARA A CARGA ["+cCodCarga+"] "
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Valido quantidades:
		If Empty(TT1391A->QTD) .Or. TT1391A->QTD <= 0
			cStRet	:= "QUANTIDADE NAO LOCALIZADA NAS TABELAS INTERNAS DA BUDDEMEYER"
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Definição do preço unitário:
		nPrcUnit	:= TT1391A->PRUNIT

		// Definição da quantidade:
		nQtdNF		:= TT1391A->QTD

		// Para pedidos de cobrança, verifico o valor unitário conforme tabela de preços + adicional:
		If nTp == 2
			// Verifico se a origem da cobrança é em cima do que foi apontado pelo coletor:
			If U_B1391Param("FACCAO", "COB_ORIG") == "APONTADA"
				nQtdNF	:= 0
				// Verifico preço na tabela:
				If (Select("TT1391B") <> 0)
					DbSelectArea("TT1391B")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 "
				cQuery += "ISNULL(SUM(ZE8_QTDTOT), 0) AS QTD_APO, "
				cQuery += "ISNULL((SELECT SUM(ZAB_QUANT) FROM ZAB010 (NOLOCK) WHERE ZAB_FILIAL = '01' AND ZAB_OP = ZE8_NUMOP AND RIGHT(RTRIM(ZAB_CODDEF), 2) <> '99' AND ZAB010.D_E_L_E_T_ = '' ), 0) AS QTD_SEG "
				cQuery += "FROM ZE8010 (NOLOCK) "
				cQuery += "WHERE ZE8_FILIAL = '' "
				cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
				cQuery += "AND ZE8_NUMOP = '"+TT1391A->OP+"' "
				cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
				cQuery += "GROUP BY ZE8_NUMOP"
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TT1391B"
				If !TT1391B->(Eof())
					nQtdNF	:= TT1391B->QTD_APO
					nQtdNF	+= TT1391B->QTD_SEG
				EndIf
			EndIf

			nPrcUnit	:= 0
			// Verifico se existe origem cadastrada:
			If (Select("TT1391B") <> 0)
				DbSelectArea("TT1391B")
				DbCloseArea()
			Endif
			cQuery := "SELECT TOP 1 ZF0_VLRUNI, ZF0_VLRADI, ZF0_DTENV FROM ZF0010 (NOLOCK) WHERE ZF0_FILIAL = '' AND ZF0_NUMOP = '"+AllTrim(TT1391A->OP)+"' AND ZF0010.D_E_L_E_T_ = '' ORDER BY ZF0_DTENV DESC"
			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1391B"
			If !TT1391B->(Eof())
				nPrcUnit	:= TT1391B->ZF0_VLRUNI
				nPrcUnit	+= TT1391B->ZF0_VLRADI
			Else
				// Verifico preço na tabela:
				If (Select("TT1391B") <> 0)
					DbSelectArea("TT1391B")
					DbCloseArea()
				Endif
				cQuery := "SELECT TOP 1 AIB_PRCCOM, AIB_ITEM FROM AIB010 (NOLOCK) WHERE AIB_FILIAL = '01' AND AIB_CODPRO = '"+TT1391A->COD_PA+"' AND AIB010.D_E_L_E_T_ = '' ORDER BY AIB_ITEM DESC "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TT1391B"
				If !TT1391B->(Eof())
					nPrcUnit	:= TT1391B->AIB_PRCCOM
				EndIf
				If nPrcUnit <= 0
					If (Select("TT1391B") <> 0)
						DbSelectArea("TT1391B")
						DbCloseArea()
					Endif
					cQuery := "SELECT TOP 1 Z3_VLRFACC FROM SZ3010 (NOLOCK) WHERE Z3_FILIAL = '' AND Z3_COD = '"+Right(AllTrim(TT1391A->COD_PA), 4)+"' AND SZ3010.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)
					TCQuery cQuery NEW ALIAS "TT1391B"
					If !TT1391B->(Eof())
						nPrcUnit	:= TT1391B->Z3_VLRFACC
					EndIf
				EndIf
				// Verifico adicionais:
				nPrcUnit += &('StaticCall(BUD765, B765PrcAd, TT1391A->ETIQ_ADIC)')
			EndIf

			// Caso não localize o preço:
			If nPrcUnit <= 0
				cStRet	:= "PRECO DO ITEM ["+AllTrim(TT1391A->COD_PA)+"] NAO FOI LOCALIZADO NA TABELA DE PRECOS FACCOES"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
		EndIf

		// Tratativa classificação fiscal:
		SF4->(dbSeek(xFilial('SF4')+TT1391A->TES))
		If Left(SF4->F4_CF, 1) <> '1'
			cCF := '1'+SubSTR(SF4->F4_CF,2,3)
		Else
			cCF := SF4->F4_CF
		EndIF

		// Valor total da NF:
		If nTp == 1
			nTotNF	:= TT1391A->TOT_NF
		Else
			nTotNF	:= Round((nQtdNF * nPrcUnit), 2)
		EndIf

		// Adiciono itens:
		aReg := {}
		aadd(aReg,{"D1_COD"    	, TT1391A->COD  					, Nil})
		aadd(aReg,{"D1_LOCAL"	, TT1391A->LOCAL_NF					, Nil})
		aadd(aReg,{"D1_TES"		, TT1391A->TES						, Nil})
		aadd(aReg,{"D1_QUANT"  	, nQtdNF							, Nil})
		aadd(aReg,{"D1_CF"		, cCF								, Nil})
		If nTp == 1
			aadd(aReg,{"D1_NFORI"  	, TT1391A->NF_ORI				, Nil})
			aadd(aReg,{"D1_SERIORI"	, TT1391A->SERIE_ORI			, Nil})
			aadd(aReg,{"D1_ITEMORI"	, TT1391A->ITEM					, Nil})
			aadd(aReg,{"D1_IDENTB6"	, TT1391A->IDENT				, Nil})
		EndIf
		aadd(aReg,{"D1_OP"		, TT1391A->OP						, Nil})
		aadd(aReg,{"D1_VUNIT"  	, nPrcUnit  						, Nil})
		aadd(aReg,{"D1_TOTAL"  	, nTotNF							, Nil})
		aadd(aReg,{"AUTDELETA" 	, "N"     							, Nil})
		aAdd(aAutoItens, aReg)

		// Efetuo a soma para validação com o XML do fornecedor posterior:
		nVldQtd++
		nVldVlr	+= nTotNF

		// Defino variáveis para cabeçalho:
		cDocForn		:= TT1391A->DOC
		cSerForn		:= TT1391A->SERIE
		cCodForn		:= TT1391A->COD_FORN
		cLojaForn		:= TT1391A->LOJA_FORN
		cCNPJFor		:= TT1391A->CNPJ_FORN
		cChvNFe			:= TT1391A->CHV
		aCondNF[nTp]	:= TT1391A->COND
		dEmisForn		:= dDataBase

		TT1391A->(DbSkip())
	EndDo

	// Verifico retorno:
	If Len(aAutoItens) <= 0
		cStRet	:= "NAO FOI POSSIVEL LOCALIZAR OS ITENS DA CARGA ["+cCodCarga+"]"
		Return cStRet
	EndIf

	// Caso o tipo da verificação seja via SEFAZ:
	If U_B1391Param("FACCAO", "PROC_VXML") == "SEFAZ"
		aRetXML	:= U_BUD1392(cChvNFe)
		if !Empty(aRetXML[1])
			cStRet	:= "SEFAZ: " + Left(AllTrim(Upper(aRetXML[1])), (TamSx3('ZE8_PROC')[1] - 10))
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		Else
			// 1) No caso de NF de industrialização eu também efetuo uma validação de quantidade dos itens = quantidade das OPs:
			If nTp == 1
				If aRetXML[3] != nVldQtd
					cStRet	:= "QUANTIDADE DE OPs DA NF DO FORNECEDOR DIVERGE COM A QTD. DO SISTEMA [FORN.: "+AllTrim(Str(aRetXML[3]))+"] x [QTD.: "+AllTrim(Str(nVldQtd))+"]"
					//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

					//24/11/2025
					If Select("TMPZE8") > 0
						TMPZE8->(DbCloseArea())
					EndIf

					cSQL := "SELECT R_E_C_N_O_ "
					cSQL += "  FROM " + RetSqlName("ZE8") + " "
					cSQL += " WHERE D_E_L_E_T_ = '' "
					cSQL += "   AND ZE8_FILIAL = '' "
					cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

					cSQL := ChangeQuery(cSQL)
					TCQUERY cSQL NEW ALIAS "TMPZE8"

					DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					TMPZE8->(DbGoTop())
					While !TMPZE8->(Eof())
						DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
						//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
						If RecLock("ZE8", .F.)
							&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
							ZE8->ZE8_PROC := cStRet
							MsUnlock()
						EndIf

						TMPZE8->(DbSkip())
					EndDo

					TMPZE8->(DbCloseArea())

					Return cStRet
				EndIf
			EndIf

			// 3) Efetuo validação de valor:
			nVldVlr	:= Round(nVldVlr, 2)
			nVlrRec	:= Round(Val(aRetXML[2]), 2)
			nDifVlr	:= nVldVlr - nVlrRec
			nDifVlr	:= IIF(nDifVlr < 0, (nDifVlr * (-1)), nDifVlr)
			// Verifico se a diferença é superior:
			If nDifVlr > Val(U_B1391Param("FACCAO", "COB_VLRD"))
				cStRet	:= "VALOR DA NF DO FORNECEDOR DIVERGE COM CALCULO DO SISTEMA [FORN.: R$ "+AllTrim(Str(nVlrRec))+"] x [CALC.: R$ "+AllTrim(Str(nVldVlr))+"]"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
		EndIf
	ElseIf U_B1391Param("FACCAO", "PROC_VXML") == "XML"
		// Caso o tipo da verificação seja via XML do fornecedor:
		If (Select("TT1391B") <> 0)
			DbSelectArea("TT1391B")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 ZE8_XMLINF FROM ZE8010 (NOLOCK) WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_XMLINF NOT LIKE 'XML VALIDO%' AND ZE8010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391B"
		If !TT1391B->(Eof())
			cStRet	:= "O XML ENVIADO PELO FORNECEDOR NAO E VALIDO ["+AllTrim(TT1391B->ZE8_XMLINF)+"] "
			//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
					ZE8->ZE8_PROC := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Busco as informações retiradas do XML:
		If (Select("TT1391B") <> 0)
			DbSelectArea("TT1391B")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 "+aXMLCampo[nTp]+" AS FXML FROM ZE8010 (NOLOCK) WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391B"
		If !TT1391B->(Eof())
			// No caso de estar vazio:
			If Empty(TT1391B->FXML)
				cStRet	:= "NAO FOI POSSIVEL LOCALIZAR AS INFORMACOES DO XML DO FORNECEDOR"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf

			// Pego as informações:
			aInfoXML	:= StrToKArr(AllTrim(TT1391B->FXML), "|")
			If Len(aINfoXML) < 8
				cStRet	:= "INFORMACOES DO XML DO FORNECEDOR ESTAO INCORRETAS"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf

			// Verifico chave:
			If aInfoXML[1] != AllTrim(cChvNFe)
				cStRet	:= "A CHAVE INFORMADA ESTA DIVERGENTE DO XML ["+cChvNFe+"]"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
			// Verifico retorno SEFAZ:
			If aInfoXML[2] != "100"
				cStRet	:= "A NFE DO FORNECEDOR NAO FOI AUTORIZADA NO SEFAZ ["+aInfoXML[2]+"]"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
			// Verifico CNPJ Buddemeyer:
			If aInfoXML[3] != Alltrim(Alltrim(FWArrFilAtu(FWCodEmp(),FWCodFil())[18]))
				cStRet	:= "O CNPJ NAO FOI DESTINADO A EMPRESA CORRETA ["+aInfoXML[3]+"] "
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
			// Verifico CNPJ do Fornecedor:
			If aInfoXML[4] != AllTrim(cCNPJFor)
				cStRet	:= "O CNPJ DO FORNECEDOR NAO CONFERE COM O XML ["+aInfoXML[4]+" x "+AllTrim(cCNPJFor)+"] "
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
			// Verifico valor:
			nVldVlr	:= Round(nVldVlr, 2)
			nVlrRec	:= Round(Val(aInfoXML[5]), 2)
			nDifVlr	:= nVldVlr - nVlrRec
			nDifVlr	:= IIF(nDifVlr < 0, (nDifVlr * (-1)), nDifVlr)
			If nDifVlr > Val(U_B1391Param("FACCAO", "COB_VLRD"))
				cStRet	:= "VALOR DA NF DO FORNECEDOR DIVERGE COM CALCULO DO SISTEMA [FORN.: R$ "+AllTrim(Str(nVlrRec))+"] x [CALC.: R$ "+AllTrim(Str(nVldVlr))+"]"
				//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
						ZE8->ZE8_PROC := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf
			// No caso de NF de industrialização, verifico quantidade das OPs (itens na NF):
			If nTp == 1
				If Val(aInfoXML[6]) != nVldQtd
					cStRet	:= "QUANTIDADE DE OPs DA NF DO FORNECEDOR DIVERGE COM A QTD. DO SISTEMA [FORN.: "+AllTrim(aInfoXML[6])+"] x [QTD.: "+AllTrim(Str(nVldQtd))+"]"
					//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

					//24/11/2025
					If Select("TMPZE8") > 0
						TMPZE8->(DbCloseArea())
					EndIf

					cSQL := "SELECT R_E_C_N_O_ "
					cSQL += "  FROM " + RetSqlName("ZE8") + " "
					cSQL += " WHERE D_E_L_E_T_ = '' "
					cSQL += "   AND ZE8_FILIAL = '' "
					cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

					cSQL := ChangeQuery(cSQL)
					TCQUERY cSQL NEW ALIAS "TMPZE8"

					DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					TMPZE8->(DbGoTop())
					While !TMPZE8->(Eof())
						DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
						//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
						If RecLock("ZE8", .F.)
							&( "ZE8->" + aStCampo[nTp] ) := "ERRO"
							ZE8->ZE8_PROC := cStRet
							MsUnlock()
						EndIf

						TMPZE8->(DbSkip())
					EndDo

					TMPZE8->(DbCloseArea())

					Return cStRet
				EndIf
			EndIf

			// Busco data de emissão do XML do fornecedor:
			dEmisForn	:= IIF(!Empty(aInfoXML[8]), CToD(aInfoXML[8]), dDataBase)
		EndIf
	EndIf

	// Cabeçalho:
	AAdd(aAutoCab, {"F1_TIPO"    	, "N" 							, Nil } )
	AAdd(aAutoCab, {"F1_FORMUL" 	, aFormulSF1[nTp] 				, Nil } )
	AAdd(aAutoCab, {"F1_DOC"    	, cDocForn						, Nil } )
	AAdd(aAutoCab, {"F1_SERIE"   	, cSerForn						, Nil } )
	AAdd(aAutoCab, {"F1_EMISSAO"	, dEmisForn		  				, Nil } )
	AAdd(aAutoCab, {"F1_FORNECE"	, cCodForn     	   				, Nil } )
	AAdd(aAutoCab, {"F1_LOJA"    	, cLojaForn    	  				, Nil } )
	AAdd(aAutoCab, {"F1_COND"   	, aCondNF[nTp] 					, Nil } )
	AAdd(aAutoCab, {"F1_ESPECIE" 	, "SPED" 		   				, Nil } )
	AAdd(aAutoCab, {"F1_DOCVIN" 	, cCodCarga	   	 				, Nil } )
	// Para efetuar testes, desativar parâmetro MV_DCHVNFE/MV_CHVNFE e comentar linha abaixo:
	AAdd(aAutoCab, {"F1_CHVNFE" 	, cChvNFe		  				, Nil } )

	// Efetua inclusão da NF:
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z| MATA103(x,y,z)}, aAutoCab, aAutoItens, 3)
	If lMsErroAuto
		If (__AUTO)
			aLogAuto := GetAutoGRLog()
			For _z := 1 To Len(aLogAuto)
				cStRet += aLogAuto[_z] + " "
			Next _z
		Else
			MostraErro()
		EndIf
	EndIf

	// No caso de OK, mesmo assim, preciso verificar se realmente a NF foi incluída:
	If !lMsErroAuto
		If (Select("TT1391A") <> 0)
			DbSelectArea("TT1391A")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 F1_DOC "
		cQuery += "FROM SF1010 (NOLOCK) "
		cQuery += "WHERE F1_FILIAL = '01' "
		cQuery += "AND F1_DOC = '"+cDocForn+"' "
		cQuery += "AND F1_SERIE = '"+cSerForn+"' "
		cQuery += "AND F1_FORNECE = '"+cCodForn+"' "
		cQuery += "AND F1_LOJA = '"+cLojaForn+"' "
		cQuery += "AND F1_EMISSAO = '"+DtoS(dDataBase)+"' "
		cQuery += "AND F1_TIPO = 'N' "
		cQuery += "AND F1_FORMUL IN ('"+aFormulSF1[nTp] +"', '') "
		cQuery += "AND SF1010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391A"
		If TT1391A->(Eof())
			lMsErroAuto	:= .T.
			cStRet		:= IIf(Empty(cStRet), "["+DtoC(dDataBase)+" "+Time()+"] A "+Upper(aTitulo[nTp])+" NAO FOI GERADA. POSSIVEL MOTIVO CHAVE INVALIDA", cStRet)
		EndIf
	EndIF

	// No caso de inclusão OK, eu atualizo as datas de vencimento conforme cadastro na tabela de vencimento:
	If !lMsErroAuto .And. nTp == 2
		// Busco data de vencimento:
		If (Select("TT1391A") <> 0)
			DbSelectArea("TT1391A")
			DbCloseArea()
		Endif
		cQuery := "SELECT TOP 1 ZEA_DTVENC "
		cQuery += "FROM ZEA010 (NOLOCK) "
		cQuery += "WHERE ZEA_FILIAL = '' "
		cQuery += "AND '"+DtoS(dDataBase)+"' BETWEEN ZEA_DATADE AND ZEA_DATATE "
		cQuery += "AND ZEA_DTVENC <> '' AND ZEA_DATADE <> '' AND ZEA_DATATE <> '' "
		cQuery += "AND ZEA010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391A"

		If !TT1391A->(Eof())
			// Efetuo ajustes na data de vencimento do título de cobrança gerado:
			/*cUpd := "UPDATE SE2010 SET E2_VENCTO = '"+TT1391A->ZEA_DTVENC+"' "
			cUpd += "				 , E2_VENCREA = '"+TT1391A->ZEA_DTVENC+"' "
			cUpd += "				 , E2_VENCORI = '"+TT1391A->ZEA_DTVENC+"' "
			//cUpd += "WHERE E2_FILIAL = '01' "
			cUpd += "WHERE E2_FILIAL = '' " //25/06/2024 - PERSONALITEC - SE2 ATUALMENTE É COMPARTILHADA.
			cUpd += "AND E2_PREFIXO = '"+cSerForn+"' "
			cUpd += "AND E2_NUM = '"+cDocForn+"' "
			cUpd += "AND E2_FORNECE = '"+cCodForn+"' "
			cUpd += "AND E2_LOJA = '"+cLojaForn+"' "
			cUpd += "AND E2_EMISSAO = '"+DtoS(dDataBase)+"' "
			cUpd += "AND E2_BAIXA = '' "
			cUpd += "AND E2_TIPO = 'NF' "
			cUpd += "AND SE2010.D_E_L_E_T_ = '' "
			TcSQLExec(cUpd)	*/

			//24/11/2025
			If Select("TMPSE2") > 0
				TMPSE2->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("SE2") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND E2_FILIAL = '' "
			cSQL += "   AND E2_PREFIXO  = '" + cSerForn  + "' "
			cSQL += "   AND E2_NUM      = '" + cDocForn  + "' "
			cSQL += "   AND E2_FORNECE  = '" + cCodForn  + "' "
			cSQL += "   AND E2_LOJA     = '" + cLojaForn + "' "
			cSQL += "   AND E2_EMISSAO  = '" + DtoS(dDataBase) + "' "
			cSQL += "   AND E2_BAIXA    = '' "
			cSQL += "   AND E2_TIPO     = 'NF' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPSE2"

			TMPSE2->(DbGoTop())
			While !TMPSE2->(Eof())
				DbSelectArea("SE2") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				SE2->(DbGoTo(TMPSE2->R_E_C_N_O_))
				RecLock("SE2", .F.)
				//24/02/2026 - PERSONALITEC - CORRIGIDO ATRIBUIÇÃO PARA NÃO GERAR ERROR LOG
				SE2->E2_VENCTO  := STOD(TT1391A->ZEA_DTVENC) //TT1391A->ZEA_DTVENC
				SE2->E2_VENCREA := STOD(TT1391A->ZEA_DTVENC) //TT1391A->ZEA_DTVENC
				SE2->E2_VENCORI := STOD(TT1391A->ZEA_DTVENC) //TT1391A->ZEA_DTVENC
				MsUnlock()

				TMPSE2->(DbSkip())
			EndDo

			TMPSE2->(DbCloseArea())

		EndIf
	EndIf

	// Retorno status para tabela de controle:
	If !lMsErroAuto
		//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'GERADO', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] "+Upper(aTitulo[nTp])+" GERADA COM SUCESSO', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->( FieldPut(FieldPos(aStCampo[nTp]), "GERADO") ) //24/11/2025 - VALIDAR
				ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] " + Upper(aTitulo[nTp]) + " GERADA COM SUCESSO"
				ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

	Else
		// Seto erro:
		//TcSQLExec("UPDATE ZE8010 SET "+aStCampo[nTp]+" = 'ERRO', ZE8_PROC = '"+Left(cStRet, TamSx3('ZE8_PROC')[1])+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				&( "ZE8->" + aStCampo[nTp] ) := "ERRO"//24/11/2025 - VALIDAR
				ZE8->ZE8_PROC   := Left(cStRet, TamSX3("ZE8_PROC")[1])
				ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

	EndIf

Return cStRet

// Rotina para efetuar o apontamento das OPs:
Static Function ApontaOP(cCodCarga)

	Local cStRet 		:= ""
	Local a250Fim 		:= {}
	Local dData			:= dDataBase
	Local nOpc 			:= 7
	Local lMsErroAuto	:= .F.

	// Verifico se existe algum erro nas NFs de industrialização:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE8_CODIGO "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND (ZE8_STENTR <> 'GERADO' OR ZE8_STCOBR <> 'GERADO') "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		cStRet	:= "ERRO AO APONTAR AS OPS [NFS DE RETORNO OU COBRANCA NAO GERADA]"
		Return cStRet
	EndIf

	// Efetuo apontamento das OPs conforme quantidade bipada na ZE8:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT DISTINCT C2_DATRF, C2_QUANT, C2_QUJE, C2_PERDA, C2_PRODUTO, ZE8_NUMOP, SUM(ZE8_QTDTOT) AS QTD_AP "
	cQuery += "FROM SC2010 (NOLOCK) "
	cQuery += "INNER JOIN ZE8010 (NOLOCK) ON ZE8_FILIAL = '' AND LEFT(ZE8_NUMOP, 6) = C2_NUM AND ZE8_NUMOP = (C2_NUM+C2_ITEM+C2_SEQUEN) AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "WHERE C2_FILIAL = '01' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND ZE8_STAPON IN ('AGUARDANDO', 'ERRO') "
	cQuery += "AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY C2_DATRF, C2_QUANT, C2_QUJE, C2_PERDA, C2_PRODUTO, ZE8_NUMOP "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		While !TT1391A->(Eof())
			cStRet	:= ""

			// Seto status de processamento:
			If TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'PROCESSANDO', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PROCESSANDO APONTAMENTO', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ") < 0
				cStRet	:= AllTrim(TCSQLError())
				//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
				cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_STAPON := "ERRO"
						ZE8->ZE8_PROC   := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf

			// Verifico situação do apontamento:
			If TT1391A->QTD_AP <= 0
				// Caso não tenha quantidade para realizar o apontamento:
				cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] A OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"] NAO FOI LIDA"
				//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'N_GERADO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
				cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_STAPON := "N_GERADO"
						ZE8->ZE8_PROC   := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

			ElseIf Empty(TT1391A->C2_DATRF)
				lErrApon	:= .F.

				// Verifico se existe possibilidade de executar o apontamento:
				//if (TT1391A->C2_QUJE + TT1391A->C2_PERDA + TT1391A->QTD_AP) <= (TT1391A->C2_QUANT * 1.2) // 20% de tolerância é aceitável
				If TT1391A->C2_QUJE <= TT1391A->QTD_AP
					// Verifico se existe movimentação no SD3:
					If (Select("TT1391B") <> 0)
						DbSelectArea("TT1391B")
						DbCloseArea()
					Endif
					cQuery := "SELECT TOP 1 D3_DOC FROM SD3010 (NOLOCK) WHERE D3_FILIAL = '01' AND D3_OP = '"+TT1391A->ZE8_NUMOP+"' AND D3_COD = '"+TT1391A->C2_PRODUTO+"' AND D3_QUANT >= '"+AllTrim(Str(TT1391A->QTD_AP))+"' AND D3_TM = '001' AND D3_CF = 'PR0' AND D3_ESTORNO = '' AND SD3010.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)
					TCQuery cQuery NEW ALIAS "TT1391B"
					If TT1391B->(Eof())
						// Caso não achou movimentação no SD3 de produção efetuada, faço o apontamento nesse momento:
						lErrApon	:= U_BUD744(TT1391A->ZE8_NUMOP, .T., TT1391A->QTD_AP) // Caso retorne TRUE
					EndIf
				EndIf

				// Verifico se realmente efetuou apontamento na SC2:
				If (Select("TT1391B") <> 0)
					DbSelectArea("TT1391B")
					DbCloseArea()
				Endif
				//cQuery := "SELECT TOP 1 C2_PERDA, C2_QUJE FROM SC2010 (NOLOCK) WHERE C2_FILIAL = '01' AND C2_NUM = '"+Left(TT1391A->ZE8_NUMOP, 6)+"' AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND (C2_QUJE + C2_PERDA) >= '"+AllTrim(Str(TT1391A->QTD_AP))+"' AND SC2010.D_E_L_E_T_ = '' "
				cQuery := "SELECT TOP 1 C2_PERDA, C2_QUJE FROM SC2010 (NOLOCK) WHERE C2_FILIAL = '01' AND C2_NUM = '"+Left(TT1391A->ZE8_NUMOP, 6)+"' AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND (C2_QUJE + C2_PERDA) <= 0 AND SC2010.D_E_L_E_T_ = '' "
				cQuery := ChangeQuery(cQuery)
				TCQuery cQuery NEW ALIAS "TT1391B"
				If !TT1391B->(Eof())
					// Então eu seto como erro:
					cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] A OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"] NAO FOI APONTADA CORRETAMENTE"
					//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

					//24/11/2025
					If Select("TMPZE8") > 0
						TMPZE8->(DbCloseArea())
					EndIf

					cSQL := "SELECT R_E_C_N_O_ "
					cSQL += "  FROM " + RetSqlName("ZE8") + " "
					cSQL += " WHERE D_E_L_E_T_ = '' "
					cSQL += "   AND ZE8_FILIAL = '' "
					cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
					cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

					cSQL := ChangeQuery(cSQL)
					TCQUERY cSQL NEW ALIAS "TMPZE8"

					DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					TMPZE8->(DbGoTop())
					While !TMPZE8->(Eof())
						DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
						//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
						If RecLock("ZE8", .F.)
							ZE8->ZE8_STAPON := "ERRO"
							ZE8->ZE8_PROC   := cStRet
							MsUnlock()
						EndIf

						TMPZE8->(DbSkip())
					EndDo

					TMPZE8->(DbCloseArea())

					Return cStRet
				Else
					lErrApon	:= .F.
				EndIf

				// Mesmo assim, verifico se a OP já não foi encerrada anteriormente:
				If lErrApon
					If (Select("TT1391B") <> 0)
						DbSelectArea("TT1391B")
						DbCloseArea()
					Endif
					cQuery := "SELECT TOP 1 C2_DATRF FROM SC2010 (NOLOCK) WHERE C2_FILIAL = '01' AND C2_NUM = '"+Left(TT1391A->ZE8_NUMOP, 6)+"' AND C2_NUM+C2_ITEM+C2_SEQUEN = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND C2_DATRF = '' AND SC2010.D_E_L_E_T_ = '' "
					cQuery := ChangeQuery(cQuery)
					TCQuery cQuery NEW ALIAS "TT1391B"
					If !TT1391B->(Eof())
						// Então eu seto como erro:
						cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] OCORREU ERRO NO APONTAMENTO DA OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"]"
						//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

						//24/11/2025
						If Select("TMPZE8") > 0
							TMPZE8->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("ZE8") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND ZE8_FILIAL = '' "
						cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
						cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPZE8"

						DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						TMPZE8->(DbGoTop())
						While !TMPZE8->(Eof())
							DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
							//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
							If RecLock("ZE8", .F.)
								ZE8->ZE8_STAPON := "ERRO"
								ZE8->ZE8_PROC   := cStRet
								MsUnlock()
							EndIf

							TMPZE8->(DbSkip())
						EndDo

						TMPZE8->(DbCloseArea())

						Return cStRet
					EndIf
				Else
					// Finalizo OP:
					If (Select("TT1391B") <> 0)
						DbSelectArea("TT1391B")
						DbCloseArea()
					Endif
					cQuery := "SELECT TOP 1 R_E_C_N_O_ AS D3_REG FROM SD3010 (NOLOCK) WHERE D3_FILIAL = '01' AND D3_OP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND D3_TM = '001' AND D3_ESTORNO = '' AND D3_EMISSAO = '"+DtoS(dData)+"' AND SD3010.D_E_L_E_T_ = '' ORDER BY D3_REG DESC"
					TCQuery cQuery NEW ALIAS "TT1391B"
					If !TT1391B->(Eof())
						// Posiciono no registro da SD3:
						dbSelectArea("SD3")
						DbSetOrder(2)
						dbGoTo(TT1391B->D3_REG)
						a250Fim  := {	{"D3_TM",		SD3->D3_TM,			NIL},;
							{"D3_QUANT",	SD3->D3_QUANT,		NIL},;
							{"D3_DOC",		SD3->D3_DOC,		NIL},;
							{"D3_COD",		SD3->D3_COD,		NIL},;
							{"D3_LOCAL",	SD3->D3_LOCAL,		NIL},;
							{"D3_OP",		SD3->D3_OP,			NIL}}

						lMsErroAuto := .F.
						MSExecAuto({|x,y| mata250(x, y)}, a250Fim, nOpc)
						If !lMsErroAuto
							cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] A OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"] FOI APONTADA COM SUCESSO"
						Else
							cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"] APONTADA, MAS NAO FINALIZADA"
						EndIf
					EndIf
				EndIf

				// Seto finalização no ZE8:
				//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'GERADO', ZE8_PROC = '"+cStRet+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
				cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_STAPON := "GERADO"
						ZE8->ZE8_PROC   := cStRet
						ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				cStRet	:= ""
			Else
				cStRet	:= "["+DtoC(dDataBase)+" "+Time()+"] A OP ["+AllTrim(TT1391A->ZE8_NUMOP)+"] FOI FINALIZADA DIA ["+DtoC(StoD(TT1391A->C2_DATRF))+"]"
				//TcSQLExec("UPDATE ZE8010 SET ZE8_STAPON = 'GERADO', ZE8_PROC = '"+cStRet+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8_NUMOP = '"+AllTrim(TT1391A->ZE8_NUMOP)+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "
				cSQL += "   AND ZE8_NUMOP  = '" + AllTrim(TT1391A->ZE8_NUMOP) + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_STAPON := "GERADO"
						ZE8->ZE8_PROC   := cStRet
						ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				cStRet	:= ""
			EndIf

			TT1391A->(dbSkip())
		EndDo
	EndIf

	// Antes de retornar, verifico se deu erro em alguma OP:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE8_NUMOP, ZE8_PROC, ZE8_STAPON "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND ZE8_STAPON <> 'GERADO' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		cStRet	:= "ERRO ["+AllTrim(TT1391A->ZE8_PROC)+" | "+AllTrim(TT1391A->ZE8_STAPON)+"] AO APONTAR A OP ["+AllTrim(TT1391A->ZE8_PROC)+"]"
	EndIf

Return cStRet

// Rotina para gerar ZDU e romaneio:
Static Function GeraZDUOrd(cCodCarga)
	Local cStRet 		:= ""
	Local _z			:= 0
	Local cCodRom		:= ""
	Local cSeqApon		:= "0000"
	Local cOPQuebr		:= ""

	// Verifico se existe algum erro nas NFs de industrialização ou de apontamento das OPs:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE8_CODIGO "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND (ZE8_STENTR <> 'GERADO' OR ZE8_STCOBR <> 'GERADO' OR ZE8_STAPON <> 'GERADO') "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		cStRet	:= "ERRO AO EXECUTAR AS TRANSFERENCIAS [NFS DE RETORNO, COBRANCA OU OPS NAO GERADA]"
		Return cStRet
	EndIf

	// Seto status de processamento:
	If TcSQLExec("UPDATE ZE8010 SET ZE8_NUMROM = 'ZZZZZZ', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PROCESSANDO ROMANEIO', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ") < 0
		cStRet	:= AllTrim(TCSQLError())
		//TcSQLExec("UPDATE ZE8010 SET ZE8_NUMROM = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->ZE8_NUMROM := "ERRO"
				ZE8->ZE8_PROC   := cStRet
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		Return cStRet
	EndIf

	// Verifico itens pendentes para geração do romaneio:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT B1_CODBAR, SUM(ZE8_QTDTOT) AS QTD_AP, MAX(ZE8_USUARI) AS ZE8_USU, "
	cQuery += "RTRIM((SELECT FORMAT(MAX(CAST(ZCQ_NUMROM AS INT)+1), '000000') FROM ZCQ010 (NOLOCK) WHERE ZCQ_FILIAL = '' AND ZCQ010.D_E_L_E_T_ = '')) AS PROX_ZCQ "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZE8_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY B1_CODBAR "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		MsUnlockAll()
		cCodRom	:= AllTrim(TT1391A->PROX_ZCQ)
		While !TT1391A->(Eof())
			// Efetuo inclusão dos itens na ZCQ:
			MsUnlockAll()
			RecLock("ZCQ",.T.)
			ZCQ->ZCQ_NUMROM	:= cCodRom
			ZCQ->ZCQ_CODIGO	:= AllTrim(TT1391A->B1_CODBAR)
			ZCQ->ZCQ_MULT	:= TT1391A->QTD_AP
			ZCQ->ZCQ_STATUS	:= '2'
			ZCQ->ZCQ_DATA	:= MsDate()
			ZCQ->ZCQ_HORA	:= Time()
			ZCQ->ZCQ_USUARI	:= Upper(AllTrim(TT1391A->ZE8_USU))
			ZCQ->ZCQ_TIPOMV	:= 'E'
			ZCQ->ZCQ_LOCAL	:= 'I2'
			MsUnLock("ZCQ")
			MsUnlockAll()

			TT1391A->(dbSkip())
		EndDo

		MsUnlockAll()
		// Após efetuar a inclusão do romaneio, eu seto o código dele gerado:
		//TcSQLExec("UPDATE ZE8010 SET ZE8_NUMROM = '"+cCodRom+"', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] GERADO ROMANEIO ["+cCodRom+"]' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->ZE8_NUMROM := cCodRom
				ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] GERADO ROMANEIO [" + cCodRom + "]"
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		// Efetuo a geração da ZDU:
		If (Select("TT1391A") <> 0)
			DbSelectArea("TT1391A")
			DbCloseArea()
		Endif
		cQuery := "SELECT ZE8_MULTIP, ZE8_QTDTOT, ZE8_CODGAI, ZE8_NUMOP, ZE8_PRODUT, ZE8_USUARI, C5_CLIENTE, C5_LOJACLI, C5_LOCAL, C5_NUM, A1_GRUPO "
		cQuery += "FROM ZE8010 (NOLOCK) "
		cQuery += "LEFT JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZE8_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZE8_NUMOP AND SC2010.D_E_L_E_T_ = '' "
		cQuery += "LEFT JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = C2_NUMPED AND SC5010.D_E_L_E_T_ = '' "
		cQuery += "LEFT JOIN SA1010 (NOLOCK) ON A1_FILIAL = '' AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZE8_FILIAL = '' "
		cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
		cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
		cQuery += "ORDER BY ZE8_NUMOP ASC, ZE8_CODGAI ASC "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391A"
		If !TT1391A->(Eof())
			While !TT1391A->(Eof())
				// Verifico sequência da OP:
				cSeqApon	:= IIF(cOPQuebr != TT1391A->ZE8_NUMOP, Soma1(cSeqApon), cSeqApon)
				cOPQuebr	:= TT1391A->ZE8_NUMOP

				// Abro os itens conforme quantidade:
				For _z := TT1391A->ZE8_MULTIP To TT1391A->ZE8_QTDTOT Step TT1391A->ZE8_MULTIP
					// Efetuo inclusão na tabela ZDU:
					DbSelectArea("ZDU")
					RecLock("ZDU",.T.)
					ZDU->ZDU_CODGA	:= TT1391A->ZE8_CODGAI
					ZDU->ZDU_NUMOP	:= TT1391A->ZE8_NUMOP
					ZDU->ZDU_ITEMGA	:= cSeqApon
					ZDU->ZDU_PRODUT	:= TT1391A->ZE8_PRODUT
					ZDU->ZDU_MULTIP	:= TT1391A->ZE8_MULTIP
					ZDU->ZDU_ESTAC	:= 'AUTO.WF'
					ZDU->ZDU_DTGERA	:= MsDate()
					ZDU->ZDU_HRGERA	:= Time()
					ZDU->ZDU_USGERA	:= Upper(AllTrim(TT1391A->ZE8_USUARI))
					ZDU->ZDU_STATUS	:= 'EM TRANSITO'
					ZDU->ZDU_LOCFIS	:= 'SA'
					ZDU->ZDU_CLI	:= TT1391A->C5_CLIENTE
					ZDU->ZDU_LOJA	:= TT1391A->C5_LOJACLI
					ZDU->ZDU_LOCAL	:= TT1391A->C5_LOCAL
					ZDU->ZDU_PEDIDO	:= TT1391A->C5_NUM
					ZDU->ZDU_CLIGRU	:= TT1391A->A1_GRUPO
					ZDU->ZDU_ROMENV	:= cCodRom
					MsUnLock("ZDU")
					MsUnlockAll()
				Next _z

				// Seto status na gaiola:
				//TcSQLExec("UPDATE ZDT010 SET ZDT_STATUS = 'TRANSITO', ZDT_OBS = 'TRANSITO FACCAO CARGA ["+AllTrim(cCodCarga)+"] ROMANEIO ["+AllTrim(cCodRom)+"]' WHERE ZDT_FILIAL = '' AND ZDT_CODIGO = '"+StrTran(TT1391A->ZE8_CODGAI, "GL", "")+"' AND ZDT010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZDT") > 0
					TMPZDT->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZDT") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZDT_FILIAL = '' "
				cSQL += "   AND ZDT_CODIGO = '" + StrTran(TT1391A->ZE8_CODGAI, "GL", "") + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZDT"

				TMPZDT->(DbGoTop())
				While !TMPZDT->(Eof())
					DbSelectArea("ZDT") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZDT->(DbGoTo(TMPZDT->R_E_C_N_O_))
					RecLock("ZDT", .F.)
					ZDT->ZDT_STATUS := "TRANSITO"
					ZDT->ZDT_OBS    := "TRANSITO FACCAO CARGA [" + AllTrim(cCodCarga) + "] ROMANEIO [" + AllTrim(cCodRom) + "]"
					MsUnlock()

					cCodGai := ZDT->ZDT_CODIGO
					U_BUD1516(.T.,cCodGai,"A","TRANSITO")

					TMPZDT->(DbSkip())
				EndDo

				TMPZDT->(DbCloseArea())

				TT1391A->(dbSkip())
			EndDo

			// Tudo OK:
			//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] FIM DA GERACAO DO ROMANEIO/GAIOLA' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_PROC := "[" + DtoC(dDataBase) + " " + Time() + "] FIM DA GERACAO DO ROMANEIO/GAIOLA"
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

		EndIf
	EndIf

Return cStRet

// Rotina para gerar pedido e nota fiscal de transferência:
Static Function GeraNFTran(cCodCarga)

	Local cStRet 		:= ""
	Local cItem 		:= "00"
	Local nPrcVen		:= 0
	Local cLocPed		:= U_B1391Param("FACCAO", "TRA_LOCAL")
	Local cCliTran		:= U_B1391Param("FACCAO", "TRA_CLI")
	Local cLojTran		:= U_B1391Param("FACCAO", "TRA_LOJA")
	Local cTransPed		:= U_B1391Param("FACCAO", "TRA_TRANSP")
	Local cEspPed		:= U_B1391Param("FACCAO", "TRA_ESPECI")
	Local cTesPed		:= AllTrim(GetMV("BD_TSCDENV"))
	Local cTxtLeg		:= IIF(Empty(GetMV("BD_TXCDREM")), "047", AllTrim(GetMV("BD_TXCDREM")))
	Local cNumPed		:= "TG0000"
	Local nPesoL		:= 0
	Local nPesoB		:= 0
	Local nVolume1		:= 0
	Local lMsErroAuto	:= .F.
	Local a410Item		:= {}
	Local a410Cab		:= {}
	Local aPvlNfs		:= {}
	Local cNFSaida		:= ""
	Local cSerSaida		:= "400"
	Local aLogAuto		:= {}
	Local _z			:= 0
	Local cNumRom		:= ""
	Local cMensNF1		:= "CARGA FACCAO ["+cCodCarga+"]"
	Local cMensNF2		:= ""

	// Verifico se existe algum erro nas NFs de industrialização ou de apontamento das OPs:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE8_CODIGO "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND (ZE8_STENTR <> 'GERADO' OR ZE8_STCOBR <> 'GERADO' OR ZE8_STAPON <> 'GERADO' OR ZE8_NUMROM = '') "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		cStRet	:= "ERRO AO GERAR A NF DE TRANSFERENCIA [NFS DE RETORNO, COBRANCA OU OPS NAO GERADA]"
		Return cStRet
	EndIf

	// Seto status de processamento:
	If TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'PROCESSANDO', ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PROCESSANDO NF DE TRANSFERENCIA', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ") < 0
		cStRet	:= AllTrim(TCSQLError())
		//TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZE8") > 0
			TMPZE8->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZE8") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZE8_FILIAL = '' "
		cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZE8"

		DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
		TMPZE8->(DbGoTop())
		While !TMPZE8->(Eof())
			DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
			//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
			If RecLock("ZE8", .F.)
				ZE8->ZE8_STTRAN := "ERRO"
				ZE8->ZE8_PROC   := cStRet
				MsUnlock()
			EndIf

			TMPZE8->(DbSkip())
		EndDo

		TMPZE8->(DbCloseArea())

		Return cStRet
	EndIf

	// Verifico itens para gerar pedido + nota fiscal de saída:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT ZE8_PRODUT, ZE8_NUMROM, B1_PESO, C6_PRCVEN, B1_UPRC, Z7_M3, SUM(ZE8_QTDTOT) AS QTD_AP "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZE8_PRODUT AND SB1010.D_E_L_E_T_ = ''  "
	cQuery += "INNER JOIN SZ7010 (NOLOCK) ON Z7_FILIAL = '' AND Z7_COD = B1_CODMOD AND SZ7010.D_E_L_E_T_ = ''  "
	cQuery += "LEFT  JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZE8_NUMOP, 6) AND C2_NUM+C2_ITEM+C2_SEQUEN = ZE8_NUMOP AND SC2010.D_E_L_E_T_ = ''  "
	cQuery += "LEFT  JOIN SC6010 (NOLOCK) ON C6_FILIAL = '01' AND C6_NUM = C2_NUMPED AND C6_PRODUTO = ZE8_PRODUT AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY ZE8_PRODUT, ZE8_NUMROM, B1_PESO, C6_PRCVEN, Z7_M3, B1_UPRC "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	dbSelectArea("TT1391A")
	If !TT1391A->(Eof())
		While !TT1391A->(Eof())
			cItem 	:= Soma1(cItem)
			cNumRom	:= TT1391A->ZE8_NUMROM

			// Tratativa preço de venda:
			nPrcVen	:= TT1391A->C6_PRCVEN
			nPrcVen	:= IIf(Empty(nPrcVen), TT1391A->B1_UPRC, nPrcVen)
			nPrcVen	:= IIf(Empty(nPrcVen), (TT1391A->Z7_M3 * 1000), nPrcVen)
			nPrcVen	:= IIf(Empty(nPrcVen), (TT1391A->B1_PESO * 50), nPrcVen)

			// Tratativa caso não localize o preço de vendas:
			If Empty(nPrcVen)
				cStRet	:= "O PRECO DE VENDA NAO FOI ENCONTRADO"
				//TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_STTRAN := "ERRO"
						ZE8->ZE8_PROC   := cStRet
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				Return cStRet
			EndIf

			// Alimento item:
			aadd(a410Item,	{	{"C6_ITEM"		, cItem       			,	Nil}	,;
				{"C6_PRODUTO"	, TT1391A->ZE8_PRODUT	,	Nil}	,;
				{"C6_QTDVEN"	, TT1391A->QTD_AP		,	Nil}	,;
				{"C6_PRCVEN"	, Round(nPrcVen, 2)		,	Nil}	,;
				{"C6_PRUNIT"	, Round(nPrcVen, 2)		,	Nil}	,;
				{"C6_LOCAL"		, cLocPed				,	Nil}	,;
				{"C6_QTDLIB"	, TT1391A->QTD_AP		,	Nil}	,;
				{"C6_TES"		, cTesPed 				,	Nil}	})

			// Somo peso líquido:
			nPesoL	+= (TT1391A->B1_PESO * TT1391A->QTD_AP)
			nPesoB	:= nPesoL

			TT1391A->(dbSkip())
		EndDo

		// Verifico vazio:
		If Len(a410Item) <= 0
			cStRet	:= "NAO FORAM ENCONTRADOS ITENS PARA TRANSFERIR"
			//TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_STTRAN := "ERRO"
					ZE8->ZE8_PROC   := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Busco gaiolas utilizadas:
		If (Select("TT1391B") <> 0)
			DbSelectArea("TT1391B")
			DbCloseArea()
		Endif
		cQuery := "SELECT DISTINCT ZE8_CODGAI, ZDT_PESO FROM ZE8010 (NOLOCK)  "
		cQuery += "INNER JOIN ZDT010 (NOLOCK) ON ZDT_FILIAL = '' AND ('GL'+ZDT_CODIGO) = ZE8_CODGAI AND ZDT010.D_E_L_E_T_ = '' "
		cQuery += "WHERE ZE8_FILIAL = '' "
		cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"'  "
		cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
		cQuery := ChangeQuery(cQuery)
		TCQuery cQuery NEW ALIAS "TT1391B"
		If !TT1391B->(Eof())
			cMensNF2 	:= ". GAIOLA(S) ["
			While !TT1391B->(Eof())
				nPesoB		+= TT1391B->ZDT_PESO
				cMensNF2 	+= IIF(nVolume1 <= 0, AllTrim(TT1391B->ZE8_CODGAI), ", "+AllTrim(TT1391B->ZE8_CODGAI))
				nVolume1++
				TT1391B->(dbSkip())
			EndDo
			cMensNF2	:= StrTran(cMensNF2, "GL", "")
			cMensNF2 	:= Left(cMensNF2, 50)
			cMensNF2 	+= "]"
		EndIf

		// Busco numeração de pedidos com gaiolas:
		If (Select("TT1391B") <> 0)
			DbSelectArea("TT1391B")
			DbCloseArea()
		Endif
		cQuery := ChangeQuery("SELECT TOP 1 C5_NUM FROM SC5010 (NOLOCK) WHERE C5_FILIAL = '01' AND LEFT(C5_NUM, 2) = 'TG' AND C5_NUM <= 'TG9999' AND SC5010.D_E_L_E_T_ = '' ORDER BY C5_NUM DESC ")
		TCQuery cQuery NEW ALIAS "TT1391B"
		If !TT1391B->(Eof())
			cNumPed	:= TT1391B->C5_NUM
		EndIf

		// Busco próxima sequência:
		While .T.
			cNumPed := Soma1(cNumPed)
			SC5->(dbSeek(xFilial('SC5')+cNumPed))
			If	!SC5->(Found())
				Exit
			EndIf
		EndDo

		// Cabeçalho do pedido:
		a410Cab :=	{	{"C5_NUM"			, cNumPed  			,	Nil}	,;
			{"C5_TIPO"			, 'N'	   			,	Nil}	,;
			{"C5_TIPO1"			, 'N'	   			,	Nil}	,;
			{"C5_TIPOPED"		, 'O'				,	Nil}	,;
			{"C5_CLIENTE"		, cCliTran 			,	Nil}	,;
			{"C5_LOJACLI"		, cLojTran			,	Nil}	,;
			{"C5_LOCAL"			, cLocPed			,	Nil}	,;
			{"C5_TRANSP"		, cTransPed			,	Nil}	,;
			{"C5_EMISSAO"		, MsDate() 			,	Nil}	,;
			{"C5_DTCAD"			, MsDate() 			,	Nil}	,;
			{"C5_DTENT"			, MsDate() 			,	Nil}	,;
			{"C5_CREDITO"		, '1' 				,	Nil}	,;
			{"C5_TPFRETE"		, 'F' 				,	Nil}	,;
			{"C5_TEXT1"			, cTxtLeg 			,	Nil}	,;
			{"C5_CONDPAG"		, '001'	   			,	Nil}	,;
			{"C5_PBRUTO" 		, Round(nPesoB, 2)	,	Nil}	,;
			{"C5_PESOL"  		, Round(nPesoL, 2)	,	Nil}	,;
			{"C5_VOLUME1"		, Round(nVolume1, 0),	Nil}	,;
			{"C5_MENSNF1"		, cMensNF1			,	Nil}	,;
			{"C5_MENSNF2"		, cMensNF2			,	Nil}	,;
			{"C5_ESPECI1"		, cEspPed			,	Nil}	}

		lMsErroAuto := .F.
		MSExecAuto({|x,y,z| Mata410(x,y,z)}, a410Cab, a410Item, 3)
		If lMsErroAuto
			If (__AUTO)
				aLogAuto := GetAutoGRLog()
				For _z := 1 To Len(aLogAuto)
					cStRet += aLogAuto[_z] + " "
				Next _z
			Else
				MostraErro()
			EndIf
		EndIf

		// Retorno status para tabela de controle:
		If !lMsErroAuto .Or. !Empty(cStRet)
			//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] PEDIDO ["+cNumPed+"] GERADO COM SUCESSO', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] PEDIDO [" + cNumPed + "] GERADO COM SUCESSO"
					ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

		Else
			// Seto erro:
			cStRet	:= IIf(Empty(cStRet), "PEDIDO ["+cNumPed+"] NAO GERADO", cStRet)
			//TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO', ZE8_PROC = '"+Left(cStRet, TamSx3('ZE8_PROC')[1])+"', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_STTRAN := "ERRO"
					ZE8->ZE8_PROC   := Left(cStRet, TamSX3("ZE8_PROC")[1])
					ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		EndIf

		// Caso tudo certo seto pedido no romaneio:
		//TcSQLExec("UPDATE ZCQ010 SET ZCQ_PEDIDO = '"+cNumPed+"', ZCQ_STATUS = '2' WHERE ZCQ_FILIAL = '' AND ZCQ_NUMROM = '"+cNumRom+"' AND ZCQ010.D_E_L_E_T_ = '' ")

		//24/11/2025
		If Select("TMPZCQ") > 0
			TMPZCQ->(DbCloseArea())
		EndIf

		cSQL := "SELECT R_E_C_N_O_ "
		cSQL += "  FROM " + RetSqlName("ZCQ") + " "
		cSQL += " WHERE D_E_L_E_T_ = '' "
		cSQL += "   AND ZCQ_FILIAL = '' "
		cSQL += "   AND ZCQ_NUMROM = '" + cNumRom + "' "

		cSQL := ChangeQuery(cSQL)
		TCQUERY cSQL NEW ALIAS "TMPZCQ"

		TMPZCQ->(DbGoTop())
		While !TMPZCQ->(Eof())
			DbSelectArea("ZCQ") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			ZCQ->(DbGoTo(TMPZCQ->R_E_C_N_O_))
			RecLock("ZCQ", .F.)
			ZCQ->ZCQ_PEDIDO := cNumPed
			ZCQ->ZCQ_STATUS := "2"
			MsUnlock()

			TMPZCQ->(DbSkip())
		EndDo

		TMPZCQ->(DbCloseArea())

		// Efetuo faturamento do pedido:
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+cNumPed))
		SC6->(DbSetOrder(1))
		SC6->(MsSeek(xFilial("SC6")+SC5->C5_NUM))
		While SC6->(!Eof() .And. C6_FILIAL == xFilial("SC6")) .And. SC6->C6_NUM == SC5->C5_NUM
			SC9->(DbSetOrder(1))
			SC9->(MsSeek(xFilial("SC9")+SC6->(C6_NUM+C6_ITEM)))
			SE4->(DbSetOrder(1))
			SE4->(MsSeek(xFilial("SE4")+SC5->C5_CONDPAG))
			SB1->(DbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+SC6->C6_PRODUTO))
			SB2->(DbSetOrder(1))
			SB2->(MsSeek(xFilial("SB2")+SC6->(C6_PRODUTO+C6_LOCAL)))
			SF4->(DbSetOrder(1))
			SF4->(MsSeek(xFilial("SF4")+SC6->C6_TES))
			nPrcVen := SC9->C9_PRCVEN
			If (SC5->C5_MOEDA <> 1)
				nPrcVen := xMoeda(nPrcVen,SC5->C5_MOEDA,1,MsDate())
			EndIf
			Aadd(aPvlNfs, {	SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				nPrcVen,;
				SC9->C9_PRODUTO,;
				.F.,;
				SC9->(RecNo()),;
				SC5->(RecNo()),;
				SC6->(RecNo()),;
				SE4->(RecNo()),;
				SB1->(RecNo()),;
				SB2->(RecNo()),;
				SF4->(RecNo())})
			SC6->(DbSkip())
		End
		cNFSaida	:= MaPvlNfs(aPvlNfs, cSerSaida, .F., .F., .F., .F., .F., 0, 0, .T., .F.,)

		If Empty(cNFSaida)
			cStRet	:= "OCORREU UM ERRO NA TENTATIVA DE GERAR A NF ["+cNFSaida+"] PEDIDO ["+cNumPed+"]"
			//TcSQLExec("UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO', ZE8_PROC = '"+cStRet+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

			//24/11/2025
			If Select("TMPZE8") > 0
				TMPZE8->(DbCloseArea())
			EndIf

			cSQL := "SELECT R_E_C_N_O_ "
			cSQL += "  FROM " + RetSqlName("ZE8") + " "
			cSQL += " WHERE D_E_L_E_T_ = '' "
			cSQL += "   AND ZE8_FILIAL = '' "
			cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

			cSQL := ChangeQuery(cSQL)
			TCQUERY cSQL NEW ALIAS "TMPZE8"

			DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
			TMPZE8->(DbGoTop())
			While !TMPZE8->(Eof())
				DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
				//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
				If RecLock("ZE8", .F.)
					ZE8->ZE8_STTRAN := "ERRO"
					ZE8->ZE8_PROC   := cStRet
					MsUnlock()
				EndIf

				TMPZE8->(DbSkip())
			EndDo

			TMPZE8->(DbCloseArea())

			Return cStRet
		Else
			If !Empty(cNFSaida) .And. !Empty(cSerSaida)
				//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] TRANSMITINDO SEFAZ NF ["+cNFSaida+"/"+cSerSaida+"]', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

				//24/11/2025
				If Select("TMPZE8") > 0
					TMPZE8->(DbCloseArea())
				EndIf

				cSQL := "SELECT R_E_C_N_O_ "
				cSQL += "  FROM " + RetSqlName("ZE8") + " "
				cSQL += " WHERE D_E_L_E_T_ = '' "
				cSQL += "   AND ZE8_FILIAL = '' "
				cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

				cSQL := ChangeQuery(cSQL)
				TCQUERY cSQL NEW ALIAS "TMPZE8"

				DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
				TMPZE8->(DbGoTop())
				While !TMPZE8->(Eof())
					DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
					//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
					If RecLock("ZE8", .F.)
						ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] TRANSMITINDO SEFAZ NF [" + cNFSaida + "/" + cSerSaida + "]"
						ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
						MsUnlock()
					EndIf

					TMPZE8->(DbSkip())
				EndDo

				TMPZE8->(DbCloseArea())

				// Envio para o SEFAZ:
				//AutoNfeEnv(cEmpAnt, xFilial("SF2"), "1", "1", cSerSaida, cNFSaida, cNFSaida) - JONAS 31/05/2021
				//Alterado em funçao da Totvs ter descontinuado o AutoNfeEnv - Jonas 31/05/2021
				_cIDent 	:= getCfgEntidade()
				_cVersao 	:= getCfgVersao("", _cIDent, "NFE")
				_cModal 	:= getCfgModalidade("", _cIDent, "NFE")
				_cAmbi		:= getCfgAmbiente("", _cIDent, _cModal)
				SpedNFeTrf("SF2", cSerSaida, cNFSaida, cNFSaida, _cIDent, _cAmbi, _cModal, _cVersao,,.F.,.T.,nil,nil,)

				// Verifico o retorno do SEFAZ:
				cSerNFSaida 	:= cSerSaida + cNFSaida

				nTentativa 		:= 0
				While .T. .And. nTentativa <= 500
					//TcSQLExec("UPDATE ZE8010 SET ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] AGUARDANDO RETORNO SEFAZ NF ["+cNFSaida+"/"+cSerSaida+"]', ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' WHERE ZE8_FILIAL = '' AND ZE8_CODIGO = '"+cCodCarga+"' AND ZE8010.D_E_L_E_T_ = '' ")

					//24/11/2025
					If Select("TMPZE8") > 0
						TMPZE8->(DbCloseArea())
					EndIf

					cSQL := "SELECT R_E_C_N_O_ "
					cSQL += "  FROM " + RetSqlName("ZE8") + " "
					cSQL += " WHERE D_E_L_E_T_ = '' "
					cSQL += "   AND ZE8_FILIAL = '' "
					cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

					cSQL := ChangeQuery(cSQL)
					TCQUERY cSQL NEW ALIAS "TMPZE8"

					DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
					TMPZE8->(DbGoTop())
					While !TMPZE8->(Eof())
						DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
						//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
						If RecLock("ZE8", .F.)
							ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] AGUARDANDO RETORNO SEFAZ NF [" + cNFSaida + "/" + cSerSaida + "]"
							ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
							MsUnlock()
						EndIf

						TMPZE8->(DbSkip())
					EndDo

					TMPZE8->(DbCloseArea())

					nTentativa++
					If (Select("TT1391B") <> 0)
						dbSelectArea("TT1391B")
						dbCloseArea()
					EndIf
					BeginSql Alias "TT1391B"
						SELECT
							DISTINCT TOP 1 STATUS AS IDSTATUS,
							DOC_CHV
						FROM
							SPED050 (NOLOCK)
						WHERE
							NFE_ID = %Exp:cSerNFSaida%
							AND D_E_L_E_T_ = ' '
					EndSql
					If TT1391B->IDSTATUS == 6
						/*cUpd := "UPDATE "+RETSQLNAME("SF2")+" SET F2_FIMP = 'S'  "
						cUpd += "								, F2_USERBUD = '"+cNomeResp+"'  "
						cUpd += "								, F2_CHVNFE = '"+AllTrim(TT1391B->DOC_CHV)+"'  "
						cUpd += "								, F2_DAUTNFE = '"+DtoS(MsDate())+"'  "
						cUpd += "								, F2_HAUTNFE = '"+SubStr(Time(), 1, 5)+"'  "
						cUpd += "WHERE  F2_FILIAL = '"+xFilial("SF2")+"' "
						cUpd += "AND F2_DOC = '"+cNFSaida+"' "
						cUpd += "AND F2_SERIE = '"+cSerSaida+"' "
						cUpd += "AND SF2010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						If Select("TMPSF2") > 0
							TMPSF2->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("SF2") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND F2_FILIAL = '" + xFilial("SF2") + "' "
						cSQL += "   AND F2_DOC    = '" + cNFSaida    + "' "
						cSQL += "   AND F2_SERIE  = '" + cSerSaida   + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPSF2"

						TMPSF2->(DbGoTop())
						While !TMPSF2->(Eof())
							DbSelectArea("SF2") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							SF2->(DbGoTo(TMPSF2->R_E_C_N_O_))
							RecLock("SF2", .F.)
							SF2->F2_FIMP     := "S"
							SF2->F2_USERBUD  := cNomeResp
							SF2->F2_CHVNFE   := AllTrim(TT1391B->DOC_CHV)
							SF2->F2_DAUTNFE  := MsDate() //DtoS(MsDate()) - 16/01/2026 - PERSONALITEC - Erro na conversão usando reclock - no update anterior não gerava o erro
							SF2->F2_HAUTNFE  := SubStr(Time(), 1, 5)
							MsUnlock()

							TMPSF2->(DbSkip())
						EndDo

						TMPSF2->(DbCloseArea())

						// Efetuo ajustes na tabela do sped:
						cUpd := "UPDATE SPED050 SET DATE_ENFE = '"+DtoS(MsDate())+"' "
						cUpd += "				  , TIME_ENFE = '"+Time()+"' "
						cUpd += "				  , RESP_GXML = '"+cNomeResp+"' "
						cUpd += "WHERE ID_ENT = '000001' "
						cUpd += "AND DATE_NFE = '"+DtoS(MsDate())+"' "
						cUpd += "AND NFE_ID LIKE '"+cNFSaida+"' "
						cUpd += "AND NFE_ID LIKE '"+cSerSaida+"%' "
						cUpd += "AND SPED050.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)

						/*
						//16/01/2026  - NÃO TEM COMO USAR RECLOCK POIS SPED050 NÃO ESTA NO DICIONÁRIO PROTHEUS.
						If Select("TMPSPED") > 0
							TMPSPED->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM SPED050 "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND ID_ENT    = '000001' "
						cSQL += "   AND DATE_NFE  = '" + DtoS(MsDate()) + "' "
						cSQL += "   AND NFE_ID    LIKE '" + cNFSaida + "' "
						cSQL += "   AND NFE_ID    LIKE '" + cSerSaida + "%' "

						TCQUERY cSQL NEW ALIAS "TMPSPED"

						TMPSPED->(DbGoTop())
						While !TMPSPED->(Eof())

							SPED050->(DbGoTo(TMPSPED->R_E_C_N_O_))
							RecLock("SPED050", .F.)
								SPED050->DATE_ENFE := DtoS(MsDate())
								SPED050->TIME_ENFE := Time()
								SPED050->RESP_GXML := cNomeResp
							MsUnlock()

							TMPSPED->(DbSkip())
						EndDo

						TMPSPED->(DbCloseArea())*/

						// Seto também na SF3
						/*cUpd := "UPDATE SF3010 SET F3_CHVNFE = '"+AllTrim(TT1391B->DOC_CHV)+"' "
						cUpd += "WHERE F3_FILIAL = '"+xFilial("SF3")+"' "
						cUpd += "AND F3_NFISCAL = '"+cNFSaida+"' "
						cUpd += "AND F3_SERIE = '"+cSerSaida+"' "
						cUpd += "AND F3_EMISSAO = '"+DtoS(MsDate())+"' "
						cUpd += "AND SF3010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						//24/11/2025
						If Select("TMPSF3") > 0
							TMPSF3->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("SF3") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND F3_FILIAL  = '" + xFilial("SF3")      + "' "
						cSQL += "   AND F3_NFISCAL = '" + cNFSaida          + "' "
						cSQL += "   AND F3_SERIE   = '" + cSerSaida         + "' "
						cSQL += "   AND F3_EMISSAO = '" + DtoS(MsDate())    + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPSF3"

						TMPSF3->(DbGoTop())
						While !TMPSF3->(Eof())
							DbSelectArea("SF3") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							SF3->(DbGoTo(TMPSF3->R_E_C_N_O_))
							RecLock("SF3", .F.)
							SF3->F3_CHVNFE := AllTrim(TT1391B->DOC_CHV)
							MsUnlock()

							TMPSF3->(DbSkip())
						EndDo

						TMPSF3->(DbCloseArea())

						// Seto também na SFT
						/*cUpd := "UPDATE SFT010 SET FT_CHVNFE = '"+AllTrim(TT1391B->DOC_CHV)+"' "
						cUpd += "WHERE FT_FILIAL = '"+xFilial("SFT")+"' "
						cUpd += "AND FT_NFISCAL = '"+cNFSaida+"' "
						cUpd += "AND FT_SERIE = '"+cSerSaida+"' "
						cUpd += "AND FT_EMISSAO = '"+DtoS(MsDate())+"' "
						cUpd += "AND SFT010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						//24/11/2025
						If Select("TMPSFT") > 0
							TMPSFT->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("SFT") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND FT_FILIAL  = '" + xFilial("SFT")     + "' "
						cSQL += "   AND FT_NFISCAL = '" + cNFSaida           + "' "
						cSQL += "   AND FT_SERIE   = '" + cSerSaida          + "' "
						cSQL += "   AND FT_EMISSAO = '" + DtoS(MsDate())     + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPSFT"

						TMPSFT->(DbGoTop())
						While !TMPSFT->(Eof())
							DbSelectArea("SFT") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							SFT->(DbGoTo(TMPSFT->R_E_C_N_O_))
							RecLock("SFT", .F.)
							SFT->FT_CHVNFE := AllTrim(TT1391B->DOC_CHV)
							MsUnlock()

							TMPSFT->(DbSkip())
						EndDo

						TMPSFT->(DbCloseArea())


						// Seto NFs na saída de romaneio:
						/*cUpd := "UPDATE ZCQ010 SET ZCQ_NFSTAT = 'NF. GERADA' "
						cUpd += " 				 , ZCQ_DOC = '"+cNFSaida+"' "
						cUpd += " 				 , ZCQ_SERIE = '"+cSerSaida+"' "
						cUpd += " 				 , ZCQ_STATUS = '2'  "
						cUpd += "WHERE ZCQ_FILIAL = '' "
						cUpd += "AND ZCQ_NUMROM = '"+cNumRom+"' "
						cUpd += "AND ZCQ010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						//24/11/2025
						If Select("TMPZCQ") > 0
							TMPZCQ->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("ZCQ") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND ZCQ_FILIAL = '' "
						cSQL += "   AND ZCQ_NUMROM = '" + cNumRom + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPZCQ"

						TMPZCQ->(DbGoTop())
						While !TMPZCQ->(Eof())
							DbSelectArea("ZCQ") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							ZCQ->(DbGoTo(TMPZCQ->R_E_C_N_O_))
							RecLock("ZCQ", .F.)
							ZCQ->ZCQ_NFSTAT := "NF. GERADA"
							ZCQ->ZCQ_DOC    := cNFSaida
							ZCQ->ZCQ_SERIE  := cSerSaida
							ZCQ->ZCQ_STATUS := "2"
							MsUnlock()

							TMPZCQ->(DbSkip())
						EndDo

						TMPZCQ->(DbCloseArea())

						// Seto status na ZE8:
						/*cUpd := "UPDATE ZE8010 SET ZE8_STTRAN = 'GERADO' "
						cUpd += " 				 , ZE8_NFTRAN = '"+cNFSaida+"' "
						cUpd += " 				 , ZE8_SETRAN = '"+cSerSaida+"' "
						cUpd += " 				 , ZE8_PROC = '["+DtoC(dDataBase)+" "+Time()+"] NF AUTORIZADA'  "
						cUpd += " 				 , ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' "
						cUpd += "WHERE ZE8_FILIAL = '' "
						cUpd += "AND ZE8_CODIGO = '"+cCodCarga+"' "
						cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						If Select("TMPZE8") > 0
							TMPZE8->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("ZE8") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND ZE8_FILIAL = '' "
						cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPZE8"

						DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						TMPZE8->(DbGoTop())
						While !TMPZE8->(Eof())
							DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
							//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
							If RecLock("ZE8", .F.)
								ZE8->ZE8_STTRAN := "GERADO"
								ZE8->ZE8_NFTRAN := cNFSaida
								ZE8->ZE8_SETRAN := cSerSaida
								ZE8->ZE8_PROC   := "[" + DtoC(dDataBase) + " " + Time() + "] NF AUTORIZADA"
								ZE8->ZE8_PROCFL := DtoS(dDataBase) + "_" + StrTran(Time(), ":", "")
								MsUnlock()
							EndIf

							TMPZE8->(DbSkip())
						EndDo

						TMPZE8->(DbCloseArea())
						Exit
					ElseIf TT1220B->IDSTATUS == 3 .Or. TT1220B->IDSTATUS == 5
						// Não autorizada:
						/*cStRet := "["+DtoC(dDataBase)+" "+Time()+"] NF ["+cNFSaida+"/"+cSerSaida+"] NAO AUTORIZADA"
						cUpd := "UPDATE ZE8010 SET ZE8_STTRAN = 'ERRO' "
						cUpd += " 				 , ZE8_PROC = '"+cStRet+"'  "
						cUpd += " 				 , ZE8_PROCFL = '"+DtoS(dDataBase)+"_"+Time()+"' "
						cUpd += "WHERE ZE8_FILIAL = '' "
						cUpd += "AND ZE8_CODIGO = '"+cCodCarga+"' "
						cUpd += "AND ZE8010.D_E_L_E_T_ = '' "
						TCSQLEXEC(cUpd)*/

						//24/11/2025
						If Select("TMPZE8") > 0
							TMPZE8->(DbCloseArea())
						EndIf

						cSQL := "SELECT R_E_C_N_O_ "
						cSQL += "  FROM " + RetSqlName("ZE8") + " "
						cSQL += " WHERE D_E_L_E_T_ = '' "
						cSQL += "   AND ZE8_FILIAL = '' "
						cSQL += "   AND ZE8_CODIGO = '" + cCodCarga + "' "

						cSQL := ChangeQuery(cSQL)
						TCQUERY cSQL NEW ALIAS "TMPZE8"

						DbSelectArea("TMPZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
						TMPZE8->(DbGoTop())
						While !TMPZE8->(Eof())
							DbSelectArea("ZE8") //16/01/2026 - PERSONALITEC  - Garante a seleção da workare
							ZE8->(DbGoTo(TMPZE8->R_E_C_N_O_))
							//16/01/2026 - PERSONALITEC - Ajustado incluindo if no reclock
							If RecLock("ZE8", .F.)
								ZE8->ZE8_STTRAN := "ERRO"
								ZE8->ZE8_PROC   := cStRet
								ZE8->ZE8_PROCFL := DtoS(dDataBase)+"_"+Time()
								MsUnlock()
							EndIf

							TMPZE8->(DbSkip())
						EndDo

						TMPZE8->(DbCloseArea())

						Break
						Return cStRet
						Exit
					EndIf
					Sleep(1000)
				EndDo
			End If
		EndIf
	EndIf

Return cStRet

// Rotina para enviar e-mail:
Static Function EnviaMail(cCodCarga)

	Local cServer     	:= GETMV("MV_SERCONE")
	Local cConta      	:= GetMV("MV_RELACNT")
	Local cSenhaMail  	:= GetMV("MV_RELPSW")
	Local cMensagem		:= ""
	Local lResult		:= .T.
	Local cMailFrom   	:= "no-reply@buddemeyer.com.br"
	Local cAssunto    	:= ""
	Local cMailTo	  	:= U_B1391Param("FACCAO", "PROC_EMAIL")
	Local cStatusPed	:= ""
	Local nQtdCob 		:= 0
	Local nVlrUni		:= 0
	Local nVlrTot		:= 0
	Local nQtdAcuApo	:= 0
	Local nQtdAcuCob	:= 0
	Local nVlrAcuTot	:= 0
	Local nQtdOP		:= 0
	Local aOPUtil		:= {}
	Local nQtdAcuSeg    := 0
	Local nQtdAcuRet    := 0
	Local nQtdSeg		:= 0
	Local nQtdRet		:= 0

	// Busco informações da carga:
	If (Select("TT1391A") <> 0)
		DbSelectArea("TT1391A")
		DbCloseArea()
	Endif
	cQuery := "SELECT ZE8_DESTIN, A2_COD, A2_LOJA, A2_NOME, A2_EMAIL, ZE8_NUMOP, ZE8_CODGAI, ZE8_PRODUT, B1_DESC, ZE8_PROC, "
	cQuery += "SUM(ZE8_QTDTOT) AS QTD_OP, "
	cQuery += "ZE8_STENTR, ZE8_NFENTR, ZE8_SEENTR, ZE8_CHVIND, "
	cQuery += "ZE8_STCOBR, ZE8_NFCOBR, ZE8_SECOBR, ZE8_CHVCOB, "
	cQuery += "ZE8_STAPON, "
	cQuery += "ZE8_NUMROM, "
	cQuery += "ZE8_STTRAN, ZE8_NFTRAN, ZE8_SETRAN, "
	cQuery += "ISNULL(MAX(C2_NUMPED), '') AS C2_NUMPED "
	cQuery += "FROM ZE8010 (NOLOCK) "
	cQuery += "INNER JOIN ZA9010 (NOLOCK) ON ZA9_FILIAL = '01' AND ZA9_NUMOP = ZE8_NUMOP AND ZA9010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SC5010 (NOLOCK) ON C5_FILIAL = '01' AND C5_NUM = ZA9_PEDFAC AND SC5010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SA2010 (NOLOCK) ON A2_FILIAL = '' AND A2_COD = C5_CLIENTE AND A2_LOJA = C5_LOJACLI AND SA2010.D_E_L_E_T_ = '' "
	cQuery += "INNER JOIN SB1010 (NOLOCK) ON B1_FILIAL = '' AND B1_COD = ZE8_PRODUT AND SB1010.D_E_L_E_T_ = '' "
	cQuery += "LEFT  JOIN SC2010 (NOLOCK) ON C2_FILIAL = '01' AND C2_NUM = LEFT(ZE8_NUMOP, 6) AND (C2_NUM+C2_ITEM+C2_SEQUEN) = ZE8_NUMOP AND SC2010.D_E_L_E_T_ = '' "
	cQuery += "WHERE ZE8_FILIAL = '' "
	cQuery += "AND ZE8_CODIGO = '"+cCodCarga+"' "
	cQuery += "AND ZE8010.D_E_L_E_T_ = '' "
	cQuery += "GROUP BY A2_COD, A2_LOJA, A2_NOME, A2_EMAIL, ZE8_DESTIN, ZE8_NUMOP, ZE8_CODGAI, ZE8_PRODUT, B1_DESC, ZE8_PROC, ZE8_STENTR, ZE8_NFENTR, ZE8_SEENTR, ZE8_STCOBR, ZE8_NFCOBR, ZE8_SECOBR, ZE8_STAPON, ZE8_NUMROM, ZE8_STTRAN, ZE8_NFTRAN, ZE8_SETRAN, ZE8_CHVIND, ZE8_CHVCOB "
	cQuery += "ORDER BY ZE8_CODGAI ASC, ZE8_NUMOP ASC  "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391A"
	If !TT1391A->(Eof())
		// Verifico se envia e-mail para fornecedor:
		If U_B1391Param("FACCAO", "PROC_EFOR") == "SIM"
			If !Empty(TT1391A->A2_EMAIL)
				cMailTo += ", " + AllTrim(Lower(TT1391A->A2_EMAIL))
			EndIf
		EndIf

		If Empty(cMailTo)
			Return
		EndIf

		// Atualizo assunto:
		cAssunto    	:= "Notas Fiscais Facção | Carga "+cCodCarga + " p/ " + AllTrim(TT1391A->ZE8_DESTIN)

		cMensagem := "<font face='Arial' style='font-size: 9pt'>"
		cMensagem += "Prezados, foram geradas as seguintes notas fiscais do fornecedor: <br><b>"+AllTrim(TT1391A->A2_COD)+"/"+AllTrim(TT1391A->A2_LOJA)+" - "+AllTrim(TT1391A->A2_NOME)+"</b><br><br>"
		cMensagem += "Destino: <b>"+AllTrim(TT1391A->ZE8_DESTIN)+"</b><br><br>"

		cMensagem += "<hr noshade color='#E9E9E9' size='1'><br>"

		cMensagem += "Nota fiscal de industrialização: <br><font color='#000000'><b>"+AllTrim(TT1391A->ZE8_NFENTR)+"/"+AllTrim(TT1391A->ZE8_SEENTR)+"</b><br><i>"+AllTrim(TT1391A->ZE8_CHVIND)+"</i></font>"
		cMensagem += "<br><br>"
		cMensagem += "Nota fiscal de cobrança: <br><font color='#000000'><b>"+AllTrim(TT1391A->ZE8_NFCOBR)+"/"+AllTrim(TT1391A->ZE8_SECOBR)+"</b><br><i>"+AllTrim(TT1391A->ZE8_CHVCOB)+"</i></font>"

		// Caso o destino seja para o depósito:
		If AllTrim(TT1391A->ZE8_DESTIN) == "DEPOSITO"
			cMensagem += "<br><br>"
			cMensagem += "Status do apontamento de produção: <br><font color='#000000'><b>"+AllTrim(TT1391A->ZE8_STAPON)+"</b></font>"
			cMensagem += "<br><br>"
			cMensagem += "Romaneio de saída para depósito: <br><font color='#000000'><b>"+AllTrim(TT1391A->ZE8_NUMROM)+"</b></font>"
			cMensagem += "<br><br>"
			cMensagem += "Nota fiscal de transferência: <br><font color='#000000'><b>"+AllTrim(TT1391A->ZE8_NFTRAN)+"/"+AllTrim(TT1391A->ZE8_SETRAN)+"</b></font>"
		EndIf

		// Demonstro resumo das OPs:
		cMensagem += "<br><br>"
		cMensagem += "<hr noshade color='#E9E9E9' size='1'><br>"
		cMensagem += "Resumo dos apontamentos efetuados:"
		cMensagem += "<table style='font-size: 8pt; font-family: Arial; border-collapse: collapse' border='0' width='100%' cellpadding='5'>"
		cMensagem += "<tr bgcolor='#E9E9E9'>"
		cMensagem += "<td align='center'><b>OP</b></td>"
		cMensagem += "<td align='center'><b>"+IIf(AllTrim(TT1391A->ZE8_DESTIN) == "DEPOSITO", "Gaiola", "Carrinho")+"</b></td>"
		cMensagem += "<td align='left'><b>Cód. Produto</b></td>"
		cMensagem += "<td align='left'><b>Produto</b></td>"
		cMensagem += "<td align='right'><b>Qtd.Apo.</b></td>"
		cMensagem += "<td align='right'><b>Qtd.Seg.</b></td>"
		cMensagem += "<td align='right'><b>Qtd.Ret.</b></td>"
		cMensagem += "<td align='right'><b>Qtd.Cob.</b></td>"
		cMensagem += "<td align='right'><b>Vlr.Unit.</b></td>"
		cMensagem += "<td align='right'><b>Vlr.Tot.</b></td>"
		cMensagem += "</tr>"
		While !TT1391A->(Eof())
			// Atualizo status no pedido:
			if !Empty(TT1391A->C2_NUMPED)
				cStatusPed := "RETORNADO TERCEIRIZACAO VIA CARGA ["+cCodCarga+"/"+AllTrim(TT1391A->ZE8_CODGAI)+"]"
				If AllTrim(TT1391A->ZE8_DESTIN) == "DEPOSITO"
					cStatusPed += " E ENVIADO PARA DEPOSITO"
				EndIf
				U_BUD1162(AllTrim(TT1391A->C2_NUMPED), cStatusPed)
			EndIf

			// Busco informações da SD1 de cobrança:
			nQtdCob := 0
			nQtdVis	:= 0
			nVlrUni	:= 0
			nVlrTot	:= 0
			nVlrTvi	:= 0

			If (Select("TT1391B") <> 0)
				DbSelectArea("TT1391B")
				DbCloseArea()
			EndIf

			cQuery := "SELECT TOP 1 D1_QUANT, D1_VUNIT, D1_TOTAL, "
			cQuery += "ISNULL((SELECT SUM(ZAB_QUANT) FROM ZAB010 (NOLOCK) WHERE ZAB_FILIAL = '01' AND ZAB_OP = '"+TT1391A->ZE8_NUMOP+"' AND RIGHT(RTRIM(ZAB_CODDEF), 2) <> '99' AND ZAB010.D_E_L_E_T_ = ''), 0) AS QTD_SEG, "
			cQuery += "ISNULL((SELECT SUM(ZAB_QTDPC) FROM ZAB010 ZAB (NOLOCK) WHERE ZAB_FILIAL = '01' AND ZAB_OP = '"+TT1391A->ZE8_NUMOP+"'  AND ZAB.D_E_L_E_T_ = ' ' ),0) AS QTD_RET "
			cQuery += "FROM SD1010 (NOLOCK) "
			cQuery += "WHERE D1_FILIAL = '01' "
			cQuery += "AND D1_DOC = '"+TT1391A->ZE8_NFCOBR+"' "
			cQuery += "AND D1_SERIE = '"+TT1391A->ZE8_SECOBR+"' "
			cQuery += "AND D1_FORNECE = '"+TT1391A->A2_COD+"' "
			cQuery += "AND D1_LOJA = '"+TT1391A->A2_LOJA+"' "
			cQuery += "AND D1_OP = '"+TT1391A->ZE8_NUMOP+"' "
			cQuery += "AND SD1010.D_E_L_E_T_ = '' "

			cQuery := ChangeQuery(cQuery)
			TCQuery cQuery NEW ALIAS "TT1391B"

			If !TT1391B->(Eof())
				nQtdCob := TT1391B->D1_QUANT
				nVlrUni	:= TT1391B->D1_VUNIT
				nVlrTot	:= TT1391B->D1_TOTAL
				nVlrTvi	:= nVlrTot
				nQtdVis	:= nQtdCob
				nQtdSeg := TT1391B->QTD_SEG
				nQtdRet := TT1391B->QTD_RET
			EndIf

			If aScan(aOPUtil, TT1391A->ZE8_NUMOP) > 0
				nQtdVis	:= TT1391A->QTD_OP
				nVlrTvi	:= nQtdVis * nVlrUni
			EndIf

			cMensagem += "<tr bgcolor='#FFFFFF'>"
			cMensagem += "<td align='center'>"+AllTrim(TT1391A->ZE8_NUMOP)+"</td>"
			cMensagem += "<td align='center'>"+AllTrim(TT1391A->ZE8_CODGAI)+"</td>"
			cMensagem += "<td align='left'>"+AllTrim(TT1391A->ZE8_PRODUT)+"</td>"
			cMensagem += "<td align='left'>"+AllTrim(TT1391A->B1_DESC)+"</td>"
			cMensagem += "<td align='right'>"+Transform(TT1391A->QTD_OP, "@E 9,999")+"</td>"
			cMensagem += "<td align='right'>"+Transform(nQtdSeg, "@E 9,999")+"</td>"
			cMensagem += "<td align='right'>"+Transform(nQtdRet, "@E 9,999")+"</td>"
			cMensagem += "<td align='right'>"+Transform(nQtdVis, "@E 9,999")+"</td>"
			cMensagem += "<td align='right'>"+Transform(nVlrUni, "@E 999,999.999999")+"</td>"
			cMensagem += "<td align='right'>"+Transform(nVlrTvi, "@E 999,999.99")+"</td>"
			cMensagem += "</tr>"

			// Soma dos valores para utilização abaixo:
			nQtdAcuApo += TT1391A->QTD_OP
			nQtdAcuSeg += nQtdSeg
			nQtdAcuRet += nQtdRet

			If aScan(aOPUtil, TT1391A->ZE8_NUMOP) <= 0
				nQtdAcuCob	+= nQtdCob
				nVlrAcuTot	+= nVlrTot
				nQtdOP++
			EndIf

			AAdd(aOPUtil, TT1391A->ZE8_NUMOP)

			TT1391A->(dbSkip())
		EndDo

		// Total:
		cMensagem += "<tr bgcolor='#FFFFFF'>"
		cMensagem += "<td align='right' colspan='4'><b>TOTAL ["+AllTrim(Str(nQtdOP))+"]:</b></td>"
		cMensagem += "<td align='right'><b>"+Transform(nQtdAcuApo, "@E 9,999")+"</b></td>"
		cMensagem += "<td align='right'><b>"+Transform(nQtdAcuSeg, "@E 9,999")+"</b></td>"
		cMensagem += "<td align='right'><b>"+Transform(nQtdAcuRet, "@E 9,999")+"</b></td>"
		cMensagem += "<td align='right'><b>"+Transform(nQtdAcuCob, "@E 9,999")+"</b></td>"
		cMensagem += "<td align='right'></td>"
		cMensagem += "<td align='right'><b>"+Transform(nVlrAcuTot, "@E 9,999,999.99")+"</b></td>"
		cMensagem += "</tr>"

		cMensagem += "</table>"

		cMensagem += "<br><br><hr noshade color='#E9E9E9' size='1'>"
		cMensagem += "Data: "+Dtoc(MsDate())+". Hora: "+Substr(Time(),1,5)+".<br>"
		// Caso tenha algum status de processamento:
		If !Empty(TT1391A->ZE8_PROC)
			cMensagem += "Status processamento: "+AllTrim(TT1391A->ZE8_PROC)+".<br>"
		EndIf
		cMensagem += "</font>"

		// Executo envio via SMTP:
		CONNECT SMTP SERVER cServer ACCOUNT cConta PASSWORD cSenhaMail RESULT lResult
		SEND MAIL FROM cMailFrom TO cMailTo SUBJECT cAssunto BODY cMensagem RESULT lResult
		DISCONNECT SMTP SERVER

	EndIf

Return

// Rotina para buscar parâmetro de configuração:
User Function B1391Param(cGrupo, cParametro)
	Local cRetVal	:= ""

	If (Select("TT1391P") <> 0)
		DbSelectArea("TT1391P")
		DbCloseArea()
	Endif
	cQuery := "SELECT TOP 1 ZE9_VALOR FROM ZE9010 (NOLOCK) WHERE ZE9_FILIAL = '' AND ZE9_GRUPO = '"+cGrupo+"' AND ZE9_PARAME = '"+cParametro+"' AND ZE9010.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery NEW ALIAS "TT1391P"
	If !TT1391P->(Eof())
		cRetVal	:= AllTrim(TT1391P->ZE9_VALOR)
	EndIf

Return cRetVal
