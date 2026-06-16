#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*
/=========================================================================\
|Cliente     : BUDDEMEYER                                                 |
|=========================================================================|
|Programa    : BUD576.PRW  | Responsável: Jonas koslowski                 |
|=========================================================================|
|Descricao   : Relatorio de Produtos sem Pedido                           |
|=========================================================================|
|Data        : 21/05/2007         | Implantacao:  25/05/2007              |
|=========================================================================|
|Programador : Jonas koslowski          								  |
|=========================================================================|
|Objetivos   : Relatorio de Produtos sem Pedido no periodo informado.     |
\=========================================================================/
*/

User Function BUD576()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := "Produtos sem Pedido no periodo informado"
	Local nLin         := 80

	Local Cabec1       := "Cod. Produto                     Al Descricao                                     Estoq.Atual        Reserva   Disponivel"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "BUD576" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "BUD576" // Coloque aqui o nome do arquivo usado para impressao em disco

	cPerg := "BUD576"
	aRegistros := {}
	AADD(aRegistros,{cPerg,"01","Data Entrega De   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"02","Data Entrega Ate  ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"03","Data Pedido De    ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"04","Data Pedido Ate   ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"05","Produto De        ?","mv_ch5","C",15,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"06","Produto Ate       ?","mv_ch6","C",15,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"07","Almoxarifado De   ?","mv_ch7","C",02,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"08","Almoxarifado Ate  ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"09","Tipo do Cliente   ?","mv_ch9","N",01,0,0,"C","","","Exportacao","","","Nacional","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"10","Consid. Cancelados?","mv_chA","N",01,0,0,"C","","","Sim","","","Nao","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"11","Pedido de         ?","mv_chB","C",06,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"12","Pedido ate        ?","mv_chC","C",06,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"13","Saldo Zerado      ?","mv_chD","N",01,0,0,"C","","","Imprime","","","Nao Imprime","","","","","","","","","","",""})
	AADD(aRegistros,{cPerg,"14","Mostra Itens c/ Nr. do Pedido ?","mv_chA","N",01,0,0,"C","","","Nao","","","Sim","","","","","","","","","","",""})

	CriaPerguntas(cPerg,aRegistros)

	Pergunte(cPerg,.f.)

	Private cString := "SC6"

	dbSelectArea("SC6")
	dbSetOrder(1)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	IF MV_PAR09==1
		Cabec1       := "Cod. Produto            Al     Descricao                                         Estoq.Atual        Reserva   Disponivel   Pedido"
	EndIf

	IF MV_PAR14==1
		Cabec1       := "Cod. Produto           Al      Descricao                                        Estoq.Atual        Reserva   Disponivel   Custo"
	EndIf
	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	Processa({|| GeraDados() },Titulo)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


Static Function GeraDados()

	aStru:={}
	Aadd(aStru,{"PRODUTO"  ,"C",30,0})
	Aadd(aStru,{"ALMOX"    ,"C",02,0})
	Aadd(aStru,{"SALDOATU" ,"N",16,4})
	Aadd(aStru,{"RESERVA"  ,"N",16,4})
	Aadd(aStru,{"DISP"     ,"N",16,4})

	If (Select("TRB") <> 0)
		dbSelectArea("TRB")
		dbCloseArea()
	EndIf

	cArq:=CriaTrab(aStru,.t.)
	DBUSEAREA(.T.,,cArq,"TRB",nil,.F.)
	Indregua("TRB",cArq,"ALMOX+PRODUTO",,,"Indexando...")

	cQuery := "SELECT DISTINCT B2_COD, B2_LOCAL "
	cQuery += "FROM " + RETSQLNAME("SB2") + " (NOLOCK) "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	If MV_PAR13 == 2
		cQuery += "AND B2_QATU <> 0 "
	EndIf
	cQuery += "AND B2_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	cQuery += "AND B2_COD BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	cQuery += "AND B2_COD NOT IN ( "
	cQuery += "SELECT DISTINCT C6_PRODUTO FROM " + RETSQLNAME("SC6") + " (NOLOCK) "
	cQuery += "WHERE D_E_L_E_T_ <> '*' "
	If MV_PAR10 == 2
		cQuery += "AND (C6_QTDVEN - C6_QTDCANC) > 0 "
	EndIf
	If MV_PAR09 == 1
		cQuery += "AND SUBSTRING(C6_CLI,1,2) = 'EX' "
	Else
		cQuery += "AND SUBSTRING(C6_CLI,1,2) <> 'EX' "
	EndIf
	cQuery += "AND C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	cQuery += "AND C6_NUM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
	cQuery += "AND (C6_ENTREG BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' OR C6_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')) "
	cQuery += "ORDER BY B2_COD"


	/*
SELECT B2.B2_COD, B2.B2_LOCAL, SUM(C6.C6_QTDVEN) AS C6_QTDVEN
FROM SB2010 B2
       LEFT OUTER JOIN SC6010 C6 ON ( B2.B2_FILIAL = C6.C6_FILIAL AND B2.B2_COD = C6.C6_PRODUTO
                                  AND B2.B2_LOCAL = C6.C6_LOCAL AND C6.D_E_L_E_T_ <> '*' )
WHERE B2.D_E_L_E_T_ <> '*' AND B2.B2_FILIAL = '01'
AND B2_LOCAL BETWEEN 'A4' AND 'A4'
AND B2_COD BETWEEN '   ' AND 'ZZZZZZZZZZZZZZZ'
GROUP BY B2.B2_COD, B2.B2_LOCAL
	*/

	If (Select("TT576") <> 0)
		DbSelectArea("TT576")
		DbCloseArea()
	EndIf

	cQuery2 := "SELECT DISTINCT C6_PRODUTO,C6.C6_DESCRI,C6_QTDVEN "
	cQuery2 += "FROM " + RETSQLNAME("SC6") + " (NOLOCK) "
	cQuery2 += "WHERE D_E_L_E_T_ <> '*' "
	If MV_PAR10 == 2
		cQuery2 += "AND (C6_QTDVEN - C6_QTDCANC) > 0 "
	EndIf

	cQuery2 += "AND C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	cQuery2 += "AND C6_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "
	cQuery2 += "AND C6_PRODUTO IN ( "
	cQuery2 += "SELECT DISTINCT B2_COD FROM " + RETSQLNAME("SB2") + " (NOLOCK) "
	cQuery2 += "WHERE D_E_L_E_T_ <> '*' "
	If MV_PAR13 == 2
		cQuery2 += "AND B2_QATU <> 0 "
	EndIf
	cQuery2 += "AND B2_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "') "
	If MV_PAR09 == 1
		cQuery2 += "AND SUBSTRING(C6_CLI,1,2) = 'EX' "
	Else
		cQuery2 += "AND SUBSTRING(C6_CLI,1,2) <> 'EX' "
	EndIf
	cQuery2 += "AND C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
	cQuery2 += "AND C6_NUM BETWEEN '" + MV_PAR11 + "' AND '" + MV_PAR12 + "' "
	cQuery2 += "AND (C6_ENTREG BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' OR C6_DATFAT BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "')) "
	cQuery2 += "ORDER BY B2_COD."

	/*
If (Select("TT576B") <> 0)
	DbSelectArea("TT576B")
	DbCloseArea()
EndIf
	*/



	cQuery := ChangeQuery(cQuery)
	cQuery2 := ChangeQuery(cQuery2)
	MsAguarde({|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TT576",.F.,.T.)},OemToAnsi("Gerando Tabela Temporária"),OemToansi("Filtrando Registros do Período ......"),.T.)
	//TCQuery cQuery NEW ALIAS "TT576"
	/*
TCSetField("TT576","B2_QATU"   ,"N",10,2)
TCSetField("TT576","B2_RESERVA","N",10,2)
TCSetField("TT576","DISP"      ,"N",10,2)
	*/

	dbSelectArea("TT576")
	ProcRegua(RecCount())
	dbGoTop()
	//dbSelectArea("TT576B")
	//ProcRegua(RecCount())
	//dbGoTop()
	While !Eof()

		IncProc("Filtrando produto...: " + ALLTRIM(TT576->B2_COD))

		dbSelectArea("SB2")
		dbSetOrder(1)
		dbGoTop()
		dbSeek(xFilial("SB2")+TT576->B2_COD+TT576->B2_LOCAL)



		dbSelectArea("TRB")
		If !dbSeek(TT576->B2_LOCAL+TT576->B2_COD)
			RecLock("TRB",.T.)
			TRB->PRODUTO  := TT576->B2_COD
			TRB->ALMOX    := TT576->B2_LOCAL
			TRB->SALDOATU := SB2->B2_QATU
			TRB->RESERVA  :=  SB2->B2_RESERVA
			TRB->DISP     := TRB->SALDOATU - TRB->RESERVA
			msUnlock("TRB")
		EndIf



		/*
	Else
		RecLock("TRB",.F.)
		TRB->SALDOATU := TRB->SALDOATU + TT576->B2_QATU
		TRB->RESERVA  := TRB->RESERVA + TT576->B2_RESERVA
		TRB->DISP     := TRB->DISP + TT576->DISP
		msUnlock("TRB")
	EndIf
		*/
		dbSelectArea("TT576")
		TT576->(dbSkip())
	EndDo

	If MV_PAR09 == 1

		aStru:={}
		Aadd(aStru,{"PRODUTO"   ,"C",30,0})
		Aadd(aStru,{"LOCAL1"   ,"C",06,0})
		Aadd(aStru,{"NUMPED"   ,"C",06,0})

		If (Select("TRB1") <> 0)
			dbSelectArea("TRB1")
			dbCloseArea()
		EndIf

		cArq:=CriaTrab(aStru,.t.)
		DBUSEAREA(.T.,,cArq,"TRB1",nil,.F.)
		Indregua("TRB1",cArq,"PRODUTO",,,"Indexando...")

		cANO:=0
		cMES:=0
		cDIA:=0

		cANO:=(substr(DTOS(MV_PAR01),1,4))
		cMES:=(substr(DTOS(MV_PAR01),5,2))
		cDIA:=(substr(DTOS(MV_PAR01),7,2))
		cMES:=VAL(cMES)-01
		cMES:=ALLTRIM(STRZERO(cMES,2,0))


		cQuery1:=""
		cQuery1+=" SELECT DISTINCT C6_PRODUTO,C6_NUM,C6_LOCAL"
		cQuery1+=" FROM " + RETSQLNAME("SC6") + "(NOLOCK) "
		//	cQuery1+= "INNER JOIN " + RETSQLNAME("SB2") + " B2 (NOLOCK) ON B2.B2_COD=C6.C6_PRODUTO"
		cQuery1+=" WHERE D_E_L_E_T_ <> '*' "
		//cQuery1+=" AND B2.D_E_L_E_T_ <> '*' "
		cQuery1+= "AND SUBSTRING(C6_CLI,1,2) = 'EX' "
		cQuery1+= "AND (C6_QTDVEN - C6_QTDCANC) > 0  " // Thiago
		cQuery1+= "AND C6_QTDENT < C6_QTDVEN  "
		cQuery1+= "AND C6_LOCAL BETWEEN '" + MV_PAR07 + "' AND '" + MV_PAR08 + "' "
		cQuery1+=" AND (C6_ENTREG BETWEEN '" + cANO+cMES+cDIA+ "' AND '" + DTOS(MV_PAR02) + "' OR C6_DATFAT BETWEEN '" + cANO+cMES+cDIA+ "' AND '" + DTOS(MV_PAR02) + "') "
		cQuery1+= "AND C6_PRODUTO BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "

		If (Select("TT576A") <> 0)
			dbSelectArea("TT576A")
			dbCloseArea()
		EndIf
	EndIf
	If MV_PAR09 == 1
		cQuery1 := ChangeQuery(cQuery1)
		TCQuery cQuery1 NEW ALIAS "TT576A"

		DbSelectArea("TT576A")
		ProcRegua(RecCount())
		DbGoTop()

		While !eof()

			IncProc("Filtrando ... " )


			dbSelectArea("TRB1")
			dbGoTop()
			If !dbSeek(TT576A->C6_LOCAL+TT576A->C6_PRODUTO)
				RecLock("TRB1",.T.)
				TRB1->NUMPED  :=TT576A->C6_NUM
				TRB1->PRODUTO :=TT576A->C6_PRODUTO
				TRB1->LOCAL1  :=TT576A->C6_LOCAL
				MsUnlock("TRB1")
			EndIf
			dbSelectArea("TT576A")
			TT576A->(dbSkip())

		EndDo
	EndIf


Return

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem

	dbSelectArea("TRB")
	SetRegua(RecCount())
	dbGoTop()
	While !EOF()

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		IncRegua()
		IF MV_PAR09==1
			If  MV_PAR14 ==1
				dbSelectArea("TRB1")
				dbGoTop()
				If dbSeek(TRB->PRODUTO,.T.)
					dbSelectArea("TRB")
					TRB->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf
		If nLin > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif


		//---- ALTERADO PARA FINS DE AUDITORIA:
		/*
    BeginSQL ALIAS "TTBUD576D"

    SELECT D3_DOC FROM %TABLE:SD3%
	  WHERE %NOTDEL%
	  AND D3_COD = %EXP:TRB->PRODUTO%
	  AND D3_EMISSAO BETWEEN %EXP:DTOS(MV_PAR03)% AND %EXP:DTOS(MV_PAR04)%
	ENDSQL

	IF TTBUD576D->(EOF())
	ELSE
		DbCloseArea("TTBUD576D")
		//nLin := nLin + 1
		dbSelectArea("TRB")
		TRB->(dbSkip())
		LOOP
	ENDIF

	DbCloseArea("TTBUD576D")
		*/
		// ------ FIM

		dbSelectArea("TRB")

		If MV_PAR09 == 1
			//If ALLTRIM(MV_PAR14) $ POSICIONE("SB1",1,XFILIAL("SB1")+TRB->PRODUTO,"B1_DESC")

			@nLin,000 PSAY ALLTRIM(TRB->PRODUTO)
			@nLin,024 PSAY TRB->ALMOX
			@nLin,027 PSAY SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+TRB->PRODUTO,"B1_DESC"),1,44)
			@nLin,080 PSAY TRANSFORM(TRB->SALDOATU,"@E 99,999,999")
			@nLin,097 PSAY TRANSFORM(TRB->RESERVA,"@E 99,999")
			@nLin,109 PSAY TRANSFORM(TRB->DISP,"@E 99,999")
			dbSelectArea("TRB1")
			dbGoTop()
			dbSeek(TRB->PRODUTO,.T.)
			While !Eof() .And. TRB->PRODUTO==TRB1->PRODUTO
				@nLin,118 PSAY TRB1->NUMPED
				nLin++
				dbSelectArea("TRB1")
				TRB1->(dbSkip())

				If nLin > 70
					Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin := 7
				Endif
			EndDo


			//EndIf
		Else
			@nLin,002 PSAY alltrim(TRB->PRODUTO)
			@nLin,024 PSAY TRB->ALMOX
			@nLin,027 PSAY SUBSTR(POSICIONE("SB1",1,XFILIAL("SB1")+TRB->PRODUTO,"B1_DESC"),1,44)
			@nLin,080 PSAY TRANSFORM(TRB->SALDOATU,"@E 99,999")
			@nLin,097 PSAY TRANSFORM(TRB->RESERVA,"@E 99,999")
			@nLin,109 PSAY TRANSFORM(TRB->DISP,"@E 99,999")

		Endif
		/*
	NVCUST	:= 0

	dbSelectArea("ZZY")
	DbGotop()
	ZZY->(dbSetOrder(1))
	If ZZY->(dbSeek(XFILIAL("ZZY")+TRB->PRODUTO))
		NVCUST	:= ZZY->ZZY_CUSTO
	EndIf

	@nLin,118 PSAY TRANSFORM(NVCUST,"@E 9,999.999")
		*/
		nLin := nLin + 1

		dbSelectArea("TRB")
		TRB->(dbSkip())

	EndDo
	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return

Static Function CriaPerguntas(cGrupo,aPer)

	LOCAL aReg  := {}
	Local _l    := 0
	Local _m    := 0
	Local _k    := 0


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

	DbSelectArea("SX1")
	For _l := 1 to Len(aReg)
		If !DbSeek(cGrupo+StrZero(_l,02,00))
			RecLock("SX1",.T.)
			For _m := 1 to FCount()
				FieldPut(_m,aReg[_l,_m])
			Next _m
			MsUnlock("SX1")
		Elseif Alltrim(aReg[_l,3]) <> Alltrim(SX1->X1_PERGUNT)
			RecLock("SX1",.F.)
			For _k := 1 to FCount()
				FieldPut(_k,aReg[_l,_k])
			Next _k
			MsUnlock("SX1")
		Endif
	Next _l
	
Return
