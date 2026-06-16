#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ SF1100E   ºAutor  ³ROBSON J. PAVANELLI  Data ³  16/11/17   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada executado após Exclusao do Doc. Entrada.  º±±
±±º          ³ Será enviado e-mail para o setor fiscal.                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ P12                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function SF1100E()

	SetPrvt("CLOTE,")

	/*IF ALLTRIM(SF1->F1_ESPECIE) == "NFEF"
	Processa({|| FazNota()})
	ENDIF*/

	Processa({|| EnvEmail()})

RETURN


Static Function FazNota()

	dbSelectArea("SZH")
	dbSetorder(2)
	dbSeek(xFilial("SZH")+SF1->F1_DOC+SF1->F1_SERIE,.T.)
	cLote := SZH->ZH_lote

	dbSelectArea("SZH")
	dbSetorder(1)
	procregua(reccount())
	dbSeek(xFilial("SZH")+cLote,.T.)
	While !eof() .and. SZH->ZH_filial == xFilial("SZH")  .and.;
			SZH->ZH_lote   == cLote

		incproc()

		reclock("SZH",.F.)
		SZH->ZH_docent := space(06)
		SZH->ZH_serent := space(03)
		msUnlock("SZH")

		dbSelectArea("SZH")
		dbskip()
	End
return

Static Function EnvEmail()

	Local cPara   :=  SuperGetMV("MV_SF2520E",.T.,'')

	// INICIA PROCESSO
	oProcess := TWFProcess():New("000001","Exclusão NF Entrada")
	oProcess:NewTask("0000055","\WORKFLOW\wfexcluinf.HTML")
	IF xFilial("SF1")  == "07"
		oProcess:cSubject := " Excluido Nota Fiscal de Entrada - Filial 07: " + SF3->F3_NFISCAL + "-" + SF3->F3_SERIE
	ELSEIF xFilial("SF1")  == "10"
		oProcess:cSubject := " Excluido Nota Fiscal de Entrada - Filial 10: " + SF3->F3_NFISCAL + "-" + SF3->F3_SERIE
	ELSEIF xFilial("SF1")  == "09"
		oProcess:cSubject := " Excluido Nota Fiscal de Entrada - Filial 09: " + SF3->F3_NFISCAL + "-" + SF3->F3_SERIE
	Else
		oProcess:cSubject := " Excluido Nota Fiscal de Entrada - Compras: " + SF3->F3_NFISCAL + "-" + SF3->F3_SERIE
	EndIf
	oProcess:cTo:= cPara

	oHTML := oProcess:oHTML

	If	Type('oHTML') == 'U'
		Return .T.
	EndIf

	_DataExtenso := strzero(day(dDatabase),2)    + " de " + MesExtenso(month(dDataBase)) + " de " +strzero(year(dDataBase),4)

	_cData := Capital(SM0->M0_CIDCOB)+", "+_DataExtenso

	// Data
	oHtml:ValByName("DATA"	,_cData)

	AADD((oHtml:ValByName("IT.NOTA"))	,SF3->F3_NFISCAL + " " + SF3->F3_SERIE)

	If (SF3->F3_TIPO == 'D')
		CNOME := Posicione("SA1", 1, XFILIAL("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA, "A1_NOME")

	Else
		CNOME := Posicione("SA2", 1, XFILIAL("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA, "A2_NOME")

	EndIf

	AADD((oHtml:ValByName("IT.FORNEC"))	,SF3->F3_CLIEFOR + " - " + CNOME)
	AADD((oHtml:ValByName("IT.VALOR")) 	,Transform(SF1->F1_VALMERC,"@E 99,999,999.99"))
	AADD((oHtml:ValByName("IT.DTENT"))	, SF3->F3_ENTRADA)
	AADD((oHtml:ValByName("IT.USUA"))	, alltrim(upper(subs(cUsuario,7,13))))

	//FINALIZA O PROCESSO
	oProcess:Start()
	oProcess:Finish()

Return
