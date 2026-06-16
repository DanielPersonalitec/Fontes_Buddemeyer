#include "protheus.ch"
#include "parmtype.ch"
#include "FWMVCDEF.CH"

Static __LogTela    := NIL

/*
*****************************************************************************
*****************************************************************************
** Programa  : CRMA980    Autor: Marcos A Schoeffel     Data: 27/07/2022   **
*****************************************************************************
** Descricao : Ponto de Entrada padrao do cadastro de clientes para P12    **
**             Estara habilitado quando o parametro MV_MVCSA1 estiver .T.  **
**             Substituir� os P.E. MA030TOK                                **
*****************************************************************************
** Uso        : CRMA980                                                    **
** Programador: Robson J. Pavanelli                                        **
*****************************************************************************
*****************************************************************************
*/

User Function CRMA980() ///cXXX1,cXXX2,cXXX3,cXXX4,cXXX5,cXXX6
    Local aParam        := PARAMIXB
    Local lIsGrid       := .F.
//  Local nLinha        := 0
//  Local nQtdLinhas    := 0
//  Local cRotMVC       := "CRMA980"
    Local cIDPonto      := ''
    Local cIDModel      := ''
//  Local cIDForm       := ''
//  Local cEvento       := ''
//  Local cCampo        := ''
//  Local cConteudo     := ''
//  Local cMsg          := ''
    Local oObj          := NIL
    Local lRet		:= .T.
    Local aGrpUser      := {}
    Local cBody := ""

	//Variaves e-mail:
	Local nSendPort := 0, nSendSec := 0
	Local nTimeout := 60 //definir o tempo limite para 60 segundos
	Local oServer, oMessage

	Local cSendSrv    := GETMV("MV_SERCONE") //definir o servidor de envio
	Local cUser       := GetMV("MV_RELACNT") //definir o nome de usu�rio da conta de e-mail
	Local cPass	  	  := GetMV("MV_RELPSW")  //definir a senha da conta de e-mail
	Local cMailFrom	  := 'cpd@buddemeyer.com.br' //E-mail de envio
	Local cMailTo	  := 'info.ti@buddemeyer.com.br'//E-mail que recebe
	Local cEmailCc	  := 'robson@buddemeyer.com.br' //E-mail para envio de copia

//  If __LogTela == NIL
//     __LogTela   := ApMsgYesNo("A geracao do 'LOG de processamento' dos PE 'CRMA980' (MVC) sera exibido em TELA?" + CRLF + CRLF +;
//     'SIM = TELA' + CRLF +;
//     'NAO = CONSOLE do AppServer')
//  EndIf

/*
	Murilo - GoOne - 08/04/2019
	Conforme pedido do Marcelo - GoOne, precisamos validar os campos A1_SUFRAMA, A1_TPREG e A1_CALCSUF.
*/
/*
  Alteracao Marcelo Goone 13/12/2021 validar codigo do municipio
	ALC - TABATINGA  - 04062
	ALC - GUAJARA-MIRIM  - 00106
	ALC - BOA VISTA E BONFIM  - 00100 - 00159
	ALC - MACAPA E SANTANA  - 00303  - 00600
	ALC - BRASILEIA, CRUZEIRO DO SUL E EPITACIOLANDIA  - 00104  - 00203 - 00252
*/


    If aParam <> NIL
        oObj        := aParam[1]
        cIDPonto    := aParam[2]
        cIDModel    := aParam[3]
        lIsGrid     := (Len(aParam) > 3)
        nOperation := oObj:GetOperation()

        If cIDPonto == 'MODELCOMMITTTS'

			// Integracao WMS - Cliente (inclusao ou alteracao)
			If (nOperation == 3 .Or. nOperation == 4) .And. lRet
				U_BUD1507()
			EndIf
				// Mostra o tipo de Operacao
				//MsgAlert("Operacao " + CValToChar(nOperation), "Tipo de operacao MODELCOMMITTTS")
				// Inclusao
				//If nOperation == 3
					// MsgAlert("Entrou no PE - Operacao de Inclusao", "Tipo de operacao 3 MODELCOMMITTTS")
				//EndIf

				// Alteracao
				// If nOperation == 4
					// MsgAlert("Entrou no PE - Operacao de Alteracao", "Tipo de operacao 4 MODELCOMMITTTS")
				//EndIf

				// Exclusao
				//If nOperation == 5
					// MsgAlert("Entrou no PE - Operacao de Exclusao", "Tipo de operacao 5 MODELCOMMITTTS")
				//EndIf

			If nOperation == 3 .or. nOperation == 4
				// Empresa Simples Nacional
				If ! Empty(M->A1_SUFRAMA) .And. M->A1_SIMPNAC == "1" .And. ! Empty(M->A1_TPREG) .AND. M->A1_COD_MUN $ "04062/00106/00100/00159/00303/00600/00104/00203/00252"
					MsgStop("Se o campo [ " + AllTrim(GetSx3Cache("A1_SUFRAMA","X3_TITULO")) + " ] estiver preenchido, " + CHR(13) +CHR(10) +;
					"e o campo [ "  + AllTrim(GetSx3Cache("A1_SIMPNAC","X3_TITULO"))   + " ] estiver preenchido com [ 1 - SIM ], " + CHR(13) +CHR(10) +;
					"o campo [ "  + AllTrim(GetSx3Cache("A1_TPREG","X3_TITULO"))   + " ] nao pode estar preenchido!")

					lRet := .F.

				// Empresa Normal
				ElseIf ! Empty(M->A1_SUFRAMA) .And. Empty(M->A1_TPREG) .And. M->A1_SIMPNAC <> "1" .AND. M->A1_COD_MUN $"04062/00106/00100/00159/00303/00600/00104/00203/00252"
					MsgStop("Se o campo [ " + AllTrim(GetSx3Cache("A1_SUFRAMA","X3_TITULO")) + " ] estiver preenchido, " + CHR(13) +CHR(10) +;
					"e o campo [ "  + AllTrim(GetSx3Cache("A1_SIMPNAC","X3_TITULO"))   + " ] for diferente de [ 1 - SIM ], " + CHR(13) +CHR(10) +;
					"precisa preencher o campo [ " + AllTrim(GetSx3Cache("A1_TPREG","X3_TITULO")) + " ]!")

					lRet := .F.

				// Regime Cumulativo
				ElseIf ! Empty(M->A1_SUFRAMA) .And. M->A1_TPREG <> "1" .And. M->A1_SIMPNAC <> "1" .AND. M->A1_COD_MUN $"04062/00106/00100/00159/00303/00600/00104/00203/00252"
					If M->A1_CALCSUF <> "S" //.And. M->A1_CALCSUF <> "I"
						MsgStop("Se o campo [ " + AllTrim(GetSx3Cache("A1_SUFRAMA","X3_TITULO")) + " ] estiver preenchido, " + CHR(13) +CHR(10) +;
								"e o campo [ "  + AllTrim(GetSx3Cache("A1_TPREG","X3_TITULO"))   + " ] for diferente de [ 1 - Nao Cumulativo ], " + CHR(13) +CHR(10) +;
								"precisa preencher o campo [ " + AllTrim(GetSx3Cache("A1_CALCSUF","X3_TITULO")) + " ] com [ S - Sim ]!")

						lRet := .F.
					EndIf
				// Regime Nao Cumulativo
				ElseIf ! Empty(M->A1_SUFRAMA) .And. M->A1_TPREG == "1" .And. M->A1_SIMPNAC <> "1"  .AND. M->A1_COD_MUN $"04062/00106/00100/00159/00303/00600/00104/00203/00252"
					If M->A1_CALCSUF <> "I"
						MsgStop("Se o campo [ " + AllTrim(GetSx3Cache("A1_SUFRAMA","X3_TITULO")) + " ] estiver preenchido, " + CHR(13) +CHR(10) +;
								"e o campo [ "  + AllTrim(GetSx3Cache("A1_TPREG","X3_TITULO"))   + " ] for igual a [ 1 - Nao Cumulativo ], " + CHR(13) +CHR(10) +;
								"precisa preencher o campo [ " + AllTrim(GetSx3Cache("A1_CALCSUF","X3_TITULO")) + " ] com [ I - Icms ]!")

						lRet := .F.
					EndIf

				EndIf
			EndIf

			If	nOperation == 3 .And. lRet

				CTH->(DbSeek(xFilial('CTH')+"C"+M->A1_COD+M->A1_LOJA))
				If	!CTH->(Found())
					RecLock("CTH",.T.)
				Else
					RecLock("CTH",.F.)
				EndIf
				CTH->CTH_FILIAL := xFilial("CTH")
				CTH->CTH_CLVL   := "C"+M->A1_COD+M->A1_LOJA
				CTH->CTH_DESC01 := M->A1_NOME
				CTH->CTH_CLASSE := "2"
				CTH->CTH_BLOQ   := "2"
				CTH->CTH_DTEXIS := STOD("19800101")
				CTH->CTH_CLVLLP := "C"+M->A1_COD+M->A1_LOJA
				MsUnlock()

			ElseIf 	nOperation == 4 .And. lRet

				aAltera := {}
				cVarx01 := ""
				cVarx02 := ""

				SX3->(DbSetOrder(1))
				SX3->(DbGotop())
				SX3->(DbSeek("SA1",.T.))
				While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == "SA1")
					If X3USO(SX3->X3_USADO)
						If (Alltrim(SX3->X3_CAMPO) <> "A1_FILIAL")
							If SX3->X3_CONTEXT == "V"
								SX3->(dbSkip())
								Loop
							EndIf

							cVar01 := "M->"+ALLTRIM(SX3->X3_CAMPO)
							cVar02 := "SA1->"+ALLTRIM(SX3->X3_CAMPO)

							If &cVar01 <> &cVar02
								If SX3->X3_TIPO == "N"
									AADD(aAltera,{cVar02,str(&cVar02),str(&cVar01)})
								ElseIf SX3->X3_TIPO == "D"
									AADD(aAltera,{cVar02,dtoc(&cVar02),dtoc(&cVar01)})
								Else
									AADD(aAltera,{cVar02,&cVar02,&cVar01})
								EndIf
							EndIf

						EndIf
					EndIf

					SX3->(dbSkip())
				EndDo

				//Envia e-mail:

				// Instancia um novo TMailManager
				oServer := tMailManager():New()

				// Usa SSL e TLS na conexao
				oServer:setUseSSL(.F.)
				oServer:SetUseTLS( .F. )

				// Inicializa
				oServer:Init( "", cSendSrv, cUser, cPass, , nSendPort )

				// Define o Timeout SMTP
				If oServer:SetSMTPTimeout(nTimeout) != 0
					U_BUD1427("[ERROR]Falha ao definir timeout")
					Return .F.
				EndIf

				// Conecta ao servidor
				nErr := oServer:smtpConnect()
				If nErr <> 0
					U_BUD1427("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
					oServer:smtpDisconnect()
					Return .F.
				EndIf

				// Realiza autenticacao no servidor
				nErr := oServer:smtpAuth(cUser, cPass)
				If nErr <> 0
					U_BUD1427("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
					oServer:smtpDisconnect()
					Return .F.
				EndIf

				// Cria uma nova mensagem (TMailMessage)
				oMessage := tMailMessage():new()
				oMessage:clear()
				oMessage:cFrom    := cMailFrom
				oMessage:cTo      := cMailTo
				oMessage:cCC      := cEmailCc
				oMessage:cSubject := "Foi alterado o cliente " + ALLTRIM(SA1->A1_NOME) //Assunto do e-mail

				// cBody com o corpo do e-mail
				cBody := "<html>"
				cBody += "<body>"
				cBody += "<div>"
				cBody += "Cliente: " +  ALLTRIM(SA1->A1_COD) + CHR(13) +CHR(10) + "<br>"
				cBody += "Descricao: " + ALLTRIM(SA1->A1_NOME) + CHR(13) +CHR(10) + CHR(13) +CHR(10) + "<br>"
				cBody += "Alterado por: " + substr(upper(cUsuario),7,15) + CHR(13) +CHR(10) + CHR(13) +CHR(10) + "<br>"
				cBody += "Alteracoes feitas: " + CHR(13) +CHR(10) + CHR(13) +CHR(10) + "<br>"
				For i:=1 to Len(aAltera)
					cBody += "Campo: " + aAltera[i,1] + CHR(13) +CHR(10) + "<br>"
					cBody += "Vlr Antigo: " + aAltera[i,2] + CHR(13) +CHR(10) + "<br>"
					cBody += "Vlr Novo: " + aAltera[i,3] + CHR(13) +CHR(10) + CHR(13) +CHR(10) + "<br>"
				Next i
				cBody += "</div>"
				cBody += "</body>"
				cBody += "</html>"
				oMessage:cBody := cBody

				// Envia a mensagem
				nErr := oMessage:send(oServer)
				If nErr <> 0
					U_BUD1427("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
					oServer:smtpDisconnect()
					Return .F.
				EndIf

				// Disconecta do Servidor
				oServer:smtpDisconnect()

			EndIf
		EndIf
	EndIf

Return lRet
