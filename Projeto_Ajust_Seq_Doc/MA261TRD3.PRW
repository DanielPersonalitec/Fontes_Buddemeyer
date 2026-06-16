#Include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MA261TRD3 ºAutor  ³Microsiga           º Data ³  27/04/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de entrada executado após a transferencia de produtosº±±
±±º          ³ MATA261 para gravar informações de usuário                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±                             MANUTENÇÃO                                  ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
01/03/2022   | Personalitec   | Chamado 64743: comentar chamada para a rotina
             |                | BUD1273 - Versão antiga Magento.
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function MA261TRD3()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recebe os identificadores Recno() gerados na tabela SD3      ³
	//³ para que seja feito o posicionamento                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local aRecSD3 := PARAMIXB[1]
	Local nX := 1
	Local cMensgp := " "
	Local cEOLOZ := CHR(13)+CHR(10)
	Default cBUDGuia := ''

	// Declara variavel cFuncaoPai como vazia se nao existir
	Default cFuncaoPai := ''

	//incluido por Paulo Afonso em 23/06/2021 para ignorar transferências do marketplaces
	If IsInCallStatic('U_BUD1307')
		Return
	EndIf

	If cEmpAnt == '01'
		cMensgp := "--------------------------------------------------------------------------------------"
		cMensgp += " Inicio do Log Ponto de Entrada MA261TRD2 "+DTOS(DATE())+" "+TIME()+cEOLOZ
		// 01/03/2022 - Personalitec: chamado 64743
		/***************************************************************************
	    *  Rodrigo Peres Leal   | 11/01/2017 | Alimenta sincronização site:        *
		* *************************************************************************/
		/*
	   cBD_ALMSINC := alltrim(GetMV("BD_ALMSINC"))

	   For nX := 1 To Len(aRecSD3)
	   	SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
	   	If SD3->D3_LOCAL $ cBD_ALMSINC
	   		//U_BUD1273A('SB2', 'B2_COD', SD3->D3_COD)
	   	EndIf

	   	SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
	   	If SD3->D3_LOCAL $ cBD_ALMSINC
	   		//U_BUD1273A('SB2', 'B2_COD', SD3->D3_COD)
	   	EndIf
	   Next nX
		*/
		/* Fim - Alimenta sincronização site. */

		cFunNa := 'RPC'
		// ATUALIZAR O NUMERO DA GUIA NO SD3
		If (FunName() == cFunNa)
			If (!Empty(cBUDGuia))
				For nX := 1 To Len(aRecSD3)

					SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
					RecLock('SD3',.F.)
					SD3->D3_DOCGUIA := cBUDGuia
					MsUnlock()

					SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
					RecLock('SD3',.F.)
					SD3->D3_DOCGUIA := cBUDGuia
					MsUnlock()

				Next nX
			ELSE
				//COLOCAR LOG.
				cRecnos := ""
				For nX := 1 To Len(aRecSD3)
					cRecnos += cValToChar(aRecSD3[nX][1]) +cEOLOZ
					cRecnos += cValToChar(aRecSD3[nX][2]) +cEOLOZ
				Next nX
				cMensgp += " Transferência chegou aqui com a guia vazia "+cEOLOZ + cRecnos
			EndIf
			// Inserido para uso no APP transferencia entre estoque
			If 	IsInCallStack("RESTCALLWS") .AND. cFuncaoPai == "BUD1445"
				For nX := 1 To Len(aRecSD3)

					SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
					RecLock('SD3',.F.)
					SD3->D3_LOTEFIO := cGuia
					SD3->D3_USUARIO := cUsuario
					MsUnlock()

					SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
					RecLock('SD3',.F.)
					SD3->D3_LOTEFIO := cGuia
					SD3->D3_USUARIO := cUsuario
					MsUnlock()

				Next nX
			EndIf
		ELSE
			cMensgp += " Transferência/Desmontagem chegou aqui sem ser pelo FUNNAME = 'RPC' e sim por: " + FunName()+cEOLOZ
		EndIf
	EndIf

	If	IsInCallStatic('U_BUD744') .Or. ;
			IsInCallStatic('U_BUD561') .Or. ;
			IsInCallStatic('U_BUD561Auto') .Or.;
			IsInCallStatic('U_BUD613') .Or.;
			IsInCallStatic('U_BUD748')

		For nX := 1 To Len(aRecSD3)

			SD3->(DbGoto(aRecSD3[nX][1])) // Requisicao RE4
			RecLock('SD3',.F.)
			SD3->D3_SEQBUDD := cSeqBudd
			If	SD3->(FieldPos('D3_OPBUDD')) > 0 .And. IsInCallStatic('U_BUD744')
				SD3->D3_OPBUDD := cNumOP
			ElseIf	IsInCallStatic('U_BUD613')
				SD3->D3_OPBUDD := cPecaP3
			ElseIf	IsInCallStatic('U_BUD561') .Or. IsInCallStatic('U_BUD561Auto') .Or. IsInCallStatic('U_BUD748')
				SD3->D3_OPBUDD := ZA8->(ZA8_NUM+ZA8_ITEM+ZA8_SEQ)
			EndIf
			MsUnlock()

			SD3->(DbGoto(aRecSD3[nX][2])) // Devolucao DE4
			RecLock('SD3',.F.)
			SD3->D3_SEQBUDD := cSeqBudd
			If	SD3->(FieldPos('D3_OPBUDD')) > 0 .And. IsInCallStatic('U_BUD744')
				SD3->D3_OPBUDD := cNumOP
			ElseIf	IsInCallStatic('U_BUD613')
				SD3->D3_OPBUDD := cPecaP3
			ElseIf	IsInCallStatic('U_BUD561') .Or. IsInCallStatic('U_BUD561Auto') .Or. IsInCallStatic('U_BUD748')
				SD3->D3_OPBUDD := ZA8->(ZA8_NUM+ZA8_ITEM+ZA8_SEQ)
			EndIf
			MsUnlock()

		Next nX

	EndIf

	cMensgp += " Fim do Log Ponto de Entrada MA261TRD2 "+DTOS(DATE())+" "+TIME()+cEOLOZ
	cMensgp += "--------------------------------------------------------------------------------------"

	MA261LOG(cMensgp)

Return Nil


/*Função para gerar Logs de GuiA
Daniel Victor da Rosa - Personalitec
14/08/2025 - Para Transferência
*/
Static Function MA261LOG(_cZMsg)

	Local cArqTxt := "PONTO_ENTRADA_MA261TRD3_LOGS.txt"
	Local nHdlog  := fOpen(cArqTxt,2)

	//caso não consiga abrir o arquivo...
	If nHdlog == -1
		//tenta cria-lo
		nHdlog := fCreate(cArqTxt,2)
		//se também der erro
		If 	nHdlog == -1
			U_BUD1427('Erro ao Gerar o Arquivo de Log PONTO_ENTRADA_MA261TRD3_LOGS !!!')
			Return
		EndIf
	Else
		//vai para o fim do arquivo
		fSeek(nHdlog,0,2)
	Endif

	fWrite(nHdlog,_cZMsg,Len(_cZMsg))

	fClose(nHdlog)

Return
