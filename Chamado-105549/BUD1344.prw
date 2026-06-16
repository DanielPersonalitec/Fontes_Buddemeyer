#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

//Fonte chamado dentro do GATIPE
User Function BUD1344(_cNota,_cSerie)
	Local aArea  := GetArea()
	Local cQuery := ""
	Local cQry := ""
	Local cNumIte 	:= ""
	Local nValDif	:= 0
	Local lPriCda	:= .T.

	//Atualizando o SF6
	cQuery := "UPDATE "+RetSqlName("SF6")+" SET F6_VALOR = F1_DIFIMP "
	cQuery += "FROM "+RetSqlName("SF6")+" F6 ," +RetSqlName("SF1")+" F1 "
	cQuery += "WHERE F6.D_E_L_E_T_ = '' "
	cQuery += "AND F1.D_E_L_E_T_ = '' "
	cQuery += "AND F6_FILIAL = '"+xFilial("SF6")+"' "
	cQuery += "AND F1_FILIAL = '"+xFilial("SF1")+"' "
	cQuery += "AND F6_DOC = F1_DOC "
	cQuery += "AND F6_SERIE = F1_SERIE "
	cQuery += "AND F6_DOC = '"+_cNota+"' "
	cQuery += "AND F6_SERIE = '"+_cSerie+"' "
	TCSQLEXEC(cQuery)

	//Atualizando o SE2
	cQuery := "UPDATE "+RetSqlName("SE2")+" SET E2_VALOR = F6_VALOR, E2_VALLIQ = F6_VALOR, E2_SALDO = F6_VALOR, E2_VLCRUZ = F6_VALOR, E2_TIPO = 'BOL' "
	cQuery += "FROM "+RetSqlName("SF6")+" F6 ," +RetSqlName("SE2")+" E2 "
	cQuery += "WHERE F6.D_E_L_E_T_ = ''
	cQuery += "AND E2.D_E_L_E_T_ = ''
	cQuery += "AND F6_FILIAL = '"+xFilial("SF6")+"' "
	cQuery += "AND E2_FILORIG = '"+xFilial("SF6")+"' " //FILIAL ORIGEM TER ATENCAO A ISTO SE FOR ALTERAR
	cQuery += "AND E2_PREFIXO = 'ICM' "
	cQuery += "AND F6_DOC = E2_NUM "
	cQuery += "AND F6_DOC = '"+_cNota+"' "
	cQuery += "AND F6_SERIE = '"+_cSerie+"' "
	TCSQLEXEC(cQuery)

	// Murilo - Alteração de centavos na guia do ttd conforme solicitação do Marcelo Goone. 10/11/2021
	//Atualizando o CDA
	//Marcelo Goone - Alteração da aliquota do ttd na importação. 15/03/2022
	//antes - cQry := "SELECT ROUND((CDA_BASE / 0.96),2) AS BASE, ROUND(((CDA_BASE / 0.96) * 2.60) / 100,2)  AS VALOR, CDA_FILIAL, CDA_TPMOVI, CDA_ESPECI, CDA_FORMUL, CDA_NUMERO, CDA_SERIE, CDA_CLIFOR, CDA_LOJA, CDA_NUMITE, CDA_SEQ, CDA_CODLAN, CDA_CALPRO, F6_VALOR, "
	//antes - cQry += "(SELECT SUM(ROUND(((CDA_BASE / 0.96) * 2.60) / 100,2)) "

	//COMENTADO 07-08-2025 - DANIEL VICTOR DA ROSA PERSONALITEC - CHAMADO 105549
	// cQry := "SELECT ROUND((CDA_BASE / 0.96),2) AS BASE, ROUND(((CDA_BASE / 0.96) * 1.00) / 100,2)  AS VALOR, CDA_FILIAL, CDA_TPMOVI, CDA_ESPECI, CDA_FORMUL, CDA_NUMERO, CDA_SERIE, CDA_CLIFOR, CDA_LOJA, CDA_NUMITE, CDA_SEQ, CDA_CODLAN, CDA_CALPRO, F6_VALOR, "
	// cQry += "(SELECT SUM(ROUND(((CDA_BASE / 0.96) * 1.00) / 100,2)) "
	// cQry += "FROM " +RetSqlName("CDA")+" CDAB "
	// cQry += "WHERE CDAB.CDA_FILIAL = CDA.CDA_FILIAL "
	// cQry += "AND CDAB.CDA_NUMERO = CDA.CDA_NUMERO "
	// cQry += "AND CDAB.CDA_SERIE = CDA.CDA_SERIE "
	// cQry += "AND CDAB.CDA_GNRE <> '' "
	// cQry += "AND CDAB.D_E_L_E_T_ = '') AS CDATOTAL "
	// cQry += "FROM "+RetSqlName("SF6")+" F6 ," +RetSqlName("CDA")+" CDA "
	// cQry += "WHERE F6.D_E_L_E_T_ = '' "
	// cQry += "AND CDA.D_E_L_E_T_ = '' "
	// cQry += "AND F6_FILIAL = '"+xFilial("SF6")+"' "
	// cQry += "AND CDA_FILIAL = '"+xFilial("CDA")+"' "
	// cQry += "AND F6_SERIE = CDA_SERIE "
	// cQry += "AND F6_DOC = CDA_NUMERO "
	// cQry += "AND F6_DOC = '"+_cNota+"' "
	// cQry += "AND F6_SERIE = '"+_cSerie+"' "

	//AJUSTADO 07-08-2025 - DANIEL VICTOR DA ROSA PERSONALITEC - CHAMADO 105549
	cQry := " SELECT ROUND(((CDA_BASE-SD1.D1_XDICM ) / 0.96),2) AS BASE, ROUND((((CDA_BASE-SD1.D1_XDICM ) / 0.96) * 1.00)/100,2) AS VALOR, "
	cQry += " CDA_FILIAL, "
	cQry += " CDA_TPMOVI, "
	cQry += " CDA_ESPECI, "
	cQry += " CDA_FORMUL, "
	cQry += " CDA_NUMERO, "
	cQry += " CDA_SERIE,  "
	cQry += " CDA_CLIFOR, "
	cQry += " CDA_LOJA,   "
	cQry += " CDA_NUMITE, "
	cQry += " CDA_SEQ,    "
	cQry += " CDA_CODLAN, "
	cQry += " CDA_CALPRO, "
	cQry += " F6_VALOR,   "
	cQry += " (SELECT SUM(ROUND(((CDA_BASE / 0.96) * 1.00) / 100,2))  "
	cQry += " FROM "+RETSQLNAME("CDA") +" CDAB  "
	cQry += " WHERE CDAB.CDA_FILIAL = CDA.CDA_FILIAL  "
	cQry += " AND CDAB.CDA_NUMERO = CDA.CDA_NUMERO  "
	cQry += " AND CDAB.CDA_SERIE = CDA.CDA_SERIE  "
	cQry += " AND CDAB.CDA_GNRE <> ''  "
	cQry += " AND CDAB.D_E_L_E_T_ = '') AS CDATOTAL  "
	cQry += " FROM "+RETSQLNAME("SF6") +" F6, "+RETSQLNAME("CDA") +" CDA, "+RETSQLNAME("SD1") +" SD1  "
	cQry += " WHERE F6.D_E_L_E_T_ = ''  "
	cQry += " AND CDA.D_E_L_E_T_ = ''  "
	cQry += " AND F6_FILIAL = '01'  "
	cQry += " AND CDA_FILIAL = '01'  "
	cQry += " AND F6_SERIE = CDA_SERIE  "
	cQry += " AND F6_DOC = CDA_NUMERO  "
	cQry += " AND F6_DOC = "+valtosql(_cNota)
	cQry += " AND F6_SERIE = "+valtosql(_cSerie)
	cQry += " AND D1_FILIAL = CDA_FILIAL  "
	cQry += " AND D1_DOC = CDA_NUMERO  "
	cQry += " AND D1_SERIE = CDA_SERIE  "
	cQry += " AND D1_FORNECE = CDA_CLIFOR  "
	cQry += " AND D1_LOJA = CDA_LOJA  "
	cQry += " AND D1_ITEM = CDA_NUMITE  "
	cQry += " AND SD1.D_E_L_E_T_ = ''  "

	If (Select("TRB1")<>0)
		dbSelectArea("TRB1")
		dbCloseArea()
	End

	cQry := changequery(cQry)
	TCQuery cQry NEW ALIAS "TRB1"

	dbSelectarea("TRB1")
	While !Eof()

		dbSelectArea("CDA")
		dbGoTop()
		dbSetOrder(1)
		//If dbSeek(xFilial("CDA")+TRB1->CDA_TPMOVI+TRB1->CDA_ESPECI+ TRB1->CDA_FORMUL+ TRB1->CDA_NUMERO+ TRB1->CDA_SERIE+TRB1->CDA_CLIFOR+ TRB1->CDA_LOJA+ TRB1->CDA_NUMITE)	//Alterado Marcelo - GoOne 18/05/2021
		If dbSeek(xFilial("CDA")+TRB1->CDA_TPMOVI+TRB1->CDA_ESPECI+TRB1->CDA_FORMUL+TRB1->CDA_NUMERO+TRB1->CDA_SERIE+TRB1->CDA_CLIFOR+TRB1->CDA_LOJA+TRB1->CDA_NUMITE+TRB1->CDA_SEQ+TRB1->CDA_CODLAN+TRB1->CDA_CALPRO)

			RECLOCK("CDA",.F.)

			CDA->CDA_BASE 	:= TRB1->BASE
			CDA->CDA_VALOR 	:= TRB1->VALOR

			If lPriCda
				cNumIte := TRB1->CDA_NUMITE
				nValDif := TRB1->F6_VALOR - TRB1->CDATOTAL
				lPriCda := .F.
			EndIf

			If TRB1->CDA_NUMITE == cNumIte
				CDA->CDA_VALOR 	:= CDA->CDA_VALOR + nValDif
			EndIf

			MSUnlock("CDA")

		EndIf

		dbSelectarea("TRB1")
		dbSkip()

	EndDo

	//A pedido do Marcelo - incluido para deletar o registro da tabela SF6
	//SF6->(dbSetOrder(8)) //F6_FILIAL+F6_EST+F6_DOC+F6_SERIE
	/* Retirada a exclusão da guia de icms do sped fiscal -- 22/04/2025 - Marcelo mcs
SF6->(dbSetOrder(9)) //F6_FILIAL+F6_EST+F6_DOC+F6_SERIE  --Alteração do indice por conta da atualização do sistema.
If SF6->(dbSeek(xFilial("SF6")+"SC"+_cNota+_cSerie))
	SF6->(RecLock("SF6",.F.))
	SF6->(DbDelete())
	SF6->(MsUnlock())
EndIf
//Fim Murilo 10/11/2021
	Fim Retida */

	RestArea(aArea)
	//Validando total do CDA

Return
