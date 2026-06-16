#include "rwmake.ch"
#include "tbiconn.ch"
#INCLUDE "fivewin.ch"
#INCLUDE "TopConn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ M119AGR  บAutor  ณ Sensus             บ Data ณ 27/06/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Ponto de entrada executado na rotina de Despesas de        บฑฑ
ฑฑบ          ณ de Importacao (MATA119) para atualizar informacoes da      บฑฑ
ฑฑบ          ณ nota fiscal incluida. Localizado na fun็ใo A119Inclui(),   บฑฑ
ฑฑบ          ณ no final das grava็๕es e antes da grava็ใo do SIGAPCO.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Buddemeyer                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nenhum retorno                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT119AGR()

	Local aArea	 	:= GetArea()
	Local aAreaSD1	:= SD1->(GetArea())
	Local aAreaSB1	:= SB1->(GetArea())
	Local cPara   :=  SuperGetMV("MV_SF2520E",.T.,'')

	If Inclui .And. AllTrim(cEspecie) $ "NFS/NFSE"
		SD1->(dbSetOrder(1))
		SFT->(dbSetOrder(1))
		SF3->(dbSetOrder(1))
		SB1->(dbSetOrder(1))
		If SD1->(dbSeek(xFilial("SD1")+cNFiscal+cSerie+cA100For+cLoja))
			While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
					cNFiscal == SD1->D1_DOC 	.And. cSerie == SD1->D1_SERIE .And.;
					cA100For == SD1->D1_FORNECE .And. cLoja  == SD1->D1_LOJA
				SD1->(RecLock("SD1", .F.))
				If Type("cBM119ISS") <> "U"
					SD1->D1_CODISS := cBM119ISS
				EndIf
				SD1->D1_TP := "SE"
				SD1->( MsUnlock() )
				SD1->( dbSkip() )
				//If SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD)) .And. SB1->B1_TIPO <> "SE"
				//SB1->(RecLock("SB1", .F.))
				//SB1->B1_ALIQISS := 0
				//SB1->( MsUnlock() )
				//EndIf
			EndDo
		Endif
		If SFT->(dbSeek(xFilial("SFT")+cNFiscal+cSerie+cA100For+cLoja))
			While !SD1->( Eof() ) .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
					cNFiscal == SD1->D1_DOC 	.And. cSerie == SD1->D1_SERIE .And.;
					cA100For == SD1->D1_FORNECE .And. cLoja  == SD1->D1_LOJA
				SD1->(RecLock("SD1", .F.))
				If Type("cBM119ISS") <> "U"
					SD1->D1_CODISS := cBM119ISS
				EndIf
				SD1->D1_TP := "SE"
				SD1->( MsUnlock() )
				SD1->( dbSkip() )
				//If SB1->(dbSeek(xFilial("SB1")+SD1->D1_COD)) .And. SB1->B1_TIPO <> "SE"
				//SB1->(RecLock("SB1", .F.))
				//SB1->B1_ALIQISS := 0
				//SB1->( MsUnlock() )
				//EndIf
			EndDo
		Endif

		ZeraISS()

	EndIf

	IF !ALTERA .AND. !INCLUI

		// INICIA PROCESSO
		oProcess := TWFProcess():New("000001","Exclusใo NF Entrada")
		oProcess:NewTask("0000055","\WORKFLOW\wfexcluinf.HTML")

		oProcess:cSubject := " Excluido Nota Fiscal de Entrada - DIMP: " + CNFISCAL + "-" + CSERIE

		oProcess:cTo:= cPara

		oHTML := oProcess:oHTML

		If	Type('oHTML') == 'U'
			Return .T.
		EndIf

		_DataExtenso := strzero(day(dDatabase),2)    + " de " + MesExtenso(month(dDataBase)) + " de " +strzero(year(dDataBase),4)
		_cData := Capital(alltrim(SM0->M0_CIDCOB))+", "+_DataExtenso

		// Data
		oHtml:ValByName("DATA"	,_cData)

		AADD((oHtml:ValByName("IT.NOTA"))	,CNFISCAL + " " + CSERIE)

		If (CTIPO == 'D')
			CNOME := Posicione("SA1", 1, XFILIAL("SA1")+CA100FOR+CLOJA, "A1_NOME")
		Else
			CNOME := Posicione("SA2", 1, XFILIAL("SA2")+CA100FOR+CLOJA, "A2_NOME")
		EndIf

		AADD((oHtml:ValByName("IT.FORNEC"))	,CA100FOR + " - " + CNOME)
		AADD((oHtml:ValByName("IT.VALOR")) 	,Transform(NVALDESP,"@E 99,999,999.99"))
		AADD((oHtml:ValByName("IT.DTENT"))	, DDEMISSAO)
		AADD((oHtml:ValByName("IT.USUA"))	, alltrim(upper(subs(cUsuario,7,13))))

		//FINALIZA O PROCESSO
		oProcess:Start()
		oProcess:Finish()

	ENDIF

	RestArea(aAreaSB1)
	RestArea(aAreaSD1)
	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZeraISS  บAutor  ณ Sensus Murilo      บ Data ณ 22/08/2017  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que vai zerar a aliquota de ISS para os produtos    บฑฑ
ฑฑบ          ณ que sao diferentes do tipo SE (Servico).                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Buddemeyer                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Nenhum retorno                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ZeraISS()
	Local cQuery		:= ""
	Local cAliasT		:= GetNextAlias()

	cQuery += "SELECT R_E_C_N_O_ AS RECNO "
	cQuery += "FROM "+RETSQLNAME("SB1")+" B1 "
	cQuery += "WHERE B1_ALIQISS <> 0 "
	cQuery += "AND B1_TIPO <> 'SE' "
	cQuery += "AND B1.D_E_L_E_T_ = ''"

	TCQuery cQuery NEW ALIAS &cAliasT
	(cAliasT)->(dbGoTop())
	If ! (cAliasT)->(EOF())
		While ! (cAliasT)->(EOF())
			SB1->(dbGoTo((cAliasT)->RECNO))
			SB1->(RecLock("SB1", .F.))
			SB1->B1_ALIQISS := 0
			SB1->B1_CODISS	:= ""
			SB1->B1_IRRF	:= ""
			SB1->( MsUnlock() )
			(cAliasT)->(DbSkip())
		EndDo
	EndIf

	DbCloseArea(cAliasT)

Return .T.
