#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

#INCLUDE 'TOTVS.CH'
#INCLUDE 'TOTVSWEBSRV.CH'

/*
/=========================================================================\
|Módulo      : Estoque/Custos                                             |
|=========================================================================|
|Programa    : BUD1275.PRW   | Responsável: Thiago Lucas Machado          |
|=========================================================================|
|Descricao   : Web Service para Transferência de Estoque                  |
|=========================================================================|
|Data        : 30/06/2017                                                 |
|=========================================================================|
|Programador : Paulo Afonso Erzinger Junior                               |
\=========================================================================/
*/

WSSERVICE WS_BUD1275 DESCRIPTION "WebService para movimentações de estoque"

	WSDATA sTransf AS vTransf
	WSDATA sDesmonta AS vDesmonta
	WSDATA sDoc as STRING
	WSDATA cRetorno AS STRING
	WSDATA cProduto AS STRING
	WSDATA cLocal AS STRING
	WSDATA nQuant AS FLOAT

	WSMETHOD SetTransferencia DESCRIPTION "Realiza a transferência de estoque"
	WSMETHOD SetDesmontagem   DESCRIPTION "Realiza a desmontagem de um kit/jogo"
	WSMETHOD EstTransferencia DESCRIPTION "Estorna a transferência de estoque"
	WSMETHOD EstDesmontagem   DESCRIPTION "Estorna a desmontagem de um kit/jogo"
	WSMETHOD SaldoEst         DESCRIPTION "Consulta saldo em estoque do produto antes de efetuar a transferência"
ENDWSSERVICE

/*
+------------+--------------------------------------------------------------+
! Funcao     ! Metodo WS                                                    !
! Autor      ! Paulo Afonso Erzinger Junior                                 !
! Descricao  ! Realiza uma transferência de estoque no protheus             !
! Parametros !                                                              !
+------------+--------------------------------------------------------------+
*/
WSMETHOD SetTransferencia WSRECEIVE sTransf WSSEND cRetorno WSSERVICE WS_BUD1275

	Local lRet  := .T.
	Local lContiZ := .T.
	Local nOpcX := 3
	Local cZMsg5 := ""
	Local cEOLZ := CHR(13)+CHR(10)
	Local cDocGI  := ""
	Local cGuia	:= ''
	//06051982 VARIAVEIS UTILIZADAS NO MA261TRD3
	private cBUDGuia := ''
	private cBUDDocGI := ""

	cZMsg5 := " Inicio da Transferencia "+DTOS(DATE())+" "+TIME()+cEOLZ

	//DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - CONTROLE DE SEMÁFORO PARA EVITAR EXECUÇÃO CONCORRENTE
	IF !LockByName("zExecBusDoc_lock", .T., .F.)
		U_BUD1427("[BUD1275] - Atenção, outro usuário já está executando essa rotina (BuscaD3Doc)! ")
		While lContiZ
			Sleep(3000) // Aguarda 3000ms antes de tentar novamente
			IF !LockByName("zExecBusDoc_lock", .T., .F.)
			Else
				cDocGI := BuscaD3Doc()
				lContiZ := .F.
				U_BUD1427("[BUD1275] - Atenção, executando essa rotina (BuscaD3Doc)! ")
			ENDIF
		End
	Else
		cDocGI := BuscaD3Doc()
	EndIf

	cBUDDocGI := cDocGI
	//FIM - DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025

	U_BUD1427(Replicate("=",80))
	U_BUD1427("[BUD1275] - WS TRANSFERENCIA DE ESTOQUE - INICIO ("+TIME()+")")

	//Cabecalho a Incluir
	aAuto := {{cDocGI,dDataBase}}  //Cabecalho

	For nX := 1 to Len(::sTransf:Itens)
		// Número da guia:
		cGuia	:= ::sTransf:Itens[nX]:DOC_GUIA
		cBUDGuia := cGuia
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB1")+::sTransf:Itens[nX]:ORI_PRODUTO)
			cProdOri := SB1->B1_COD
			cDescOri := SB1->B1_DESC
			cUnidOri := SB1->B1_UM
			cZMsg5 += "Produto de ori: " + cProdOri + cEOLZ
			cZMsg5 += "Descricao de ori: " + cDescOri + cEOLZ
			cZMsg5 += "Unidade de ori: " + cUnidOri + cEOLZ
			cZMsg5 += "Guia de ori: " + cGuia + cEOLZ
		Else
			::cRetorno := "ERRO - Produto de ORIGEM nao encontrado"
			SetSoapFault("SetTransferencia","ERRO - Produto de ORIGEM nao encontrado")
			Return .F.
		EndIf

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB1")+::sTransf:Itens[nX]:DES_PRODUTO)
			cProdDes := SB1->B1_COD
			cDescDes := SB1->B1_DESC
			cUnidDes := SB1->B1_UM
			cZMsg5 += "Produto de des: " + cProdDes + cEOLZ
			cZMsg5 += "Descricao de des: " + cDescDes + cEOLZ
			cZMsg5 += "Unidade de des: " + cUnidDes + cEOLZ
			cZMsg5 += "Guia de des: " + cGuia + cEOLZ
		Else
			::cRetorno := "ERRO - Produto de DESTINO nao encontrado"
			SetSoapFault("SetTransferencia","ERRO - Produto de DESTINO nao encontrado")
			Return .F.
		EndIf

		CriaSB2(cProdOri,::sTransf:Itens[nX]:DES_LOCAL)
		CriaSB2(cProdDes,::sTransf:Itens[nX]:DES_LOCAL)

		cLocal := ::sTransf:Itens[nX]:ORI_LOCAL

		dbSelectArea("SB2")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("SB2")+cProdOri+cLocal)
			nSaldo := SaldoSb2()

			If ::sTransf:Itens[nX]:QUANTIDADE > nSaldo

				cErro := "ERRO - A quantidade solicitada e maior do que o disponível em estoque. Produto: " + cProdOri

				::cRetorno := cErro
				SetSoapFault("SetTransferencia",cErro)
				Return .F.

			EndIf

			If (::sTransf:Itens[nX]:ORI_LOCAL != ::sTransf:Itens[nX]:DES_LOCAL) .OR. (cProdOri != cProdDes)
				AADD(aAuto,{cProdOri,;                       // 01.Produto Origem
					cDescOri,;                       // 02.Descricao
					cUnidOri,;                       // 03.Unidade de Medida
					::sTransf:Itens[nX]:ORI_LOCAL,;  // 04.Local Origem
					CriaVar("D3_LOCALIZ",.F.),;      // 05.Endereco Origem
					cProdDes,;                    	 // 06.Produto Destino
					cDescDes,;                       // 07.Descricao
					cUnidDes,;                       // 08.Unidade de Medida
					::sTransf:Itens[nX]:DES_LOCAL,;  // 09.Armazem Destino
					CriaVar("D3_LOCALIZ",.F.),;      // 10.Endereco Destino
					CriaVar("D3_NUMSERI",.F.),;    	 // 11.Numero de Serie
					CriaVar("D3_LOTECTL",.F.),;      // 12.Lote Origem
					CriaVar("D3_NUMLOTE",.F.),;      // 13.Sublote
					CriaVar("D3_DTVALID",.F.),;      // 14.Data de Validade
					CriaVar("D3_POTENCI",.F.),;      // 15.Potencia do Lote
					::sTransf:Itens[nX]:QUANTIDADE ,;// 16.Quantidade
					CriaVar("D3_QTSEGUM",.F.),;      // 17.Quantidade na 2 UM
					CriaVar("D3_ESTORNO",.F.),;      // 18.Estorno
					CriaVar("D3_NUMSEQ" ,.F.),;      // 19.NumSeq
					CriaVar("D3_LOTECTL",.F.),;      // 20.Lote Destino
					CriaVar("D3_DTVALID",.F.),;      // 21.Data de Validade
					CriaVar("D3_ITEMGRD",.F.),;      // 22.Item Grade
					CriaVar("D3_OBSERVA",.F.)})
				//						CriaVar("D3_IDDCF",.F.),;
			EndIf
		EndIf
	Next nX

	If Len(aAuto) > 1
		lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
		lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()
		MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcX)

		If lMsErroAuto

			cZMsg5 += "Fim da Transferencia Erro "+TIME() + cEOLZ

			RollbackSx8()
			cErro := ""
			aErro := GetAutoGRLog()

			For nX := 1 To Len(aErro)
				cErro += aErro[nX] + Chr(13)+Chr(10)
			Next nX

			::cRetorno := "ERRO - " + cErro
			SetSoapFault("SetTransferencia","ERRO - " + cErro)
			lRet := .F.
		Else
			::cRetorno := cDocGI
			lRet := .T.

			cZMsg5 += "Fim da Transferencia Sucesso "+TIME() + cEOLZ

			//06051982 RETIRADO E INSERIDO NO PONTO DE ENTRADA MA261TRD3 EM 09032021;
			// Atualizo número da guia:
			/*
		     cUpd := ""
		     cUpd += "UPDATE "+RETSQLNAME("SD3")+" SET D3_DOCGUIA = '"+cGuia+"' "
		     cUpd += "WHERE D3_FILIAL = '"+xFilial("SD3")+"' "
		     cUpd += "AND D3_DOC = '"+cDocGI+"' "
		     cUpd += "AND D3_EMISSAO = '"+DtoS(dDataBase)+"' "
		     cUpd += "AND "+RETSQLNAME("SD3")+".D_E_L_E_T_ = '' "
		   TCSQLEXEC(cUpd)
			*/
		EndIf

	Else
		::cRetorno := ""
		lRet := .T.
	EndIf

	//DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - FIM DO CONTROLE DE SEMÁFORO
	cZMsg5 += "*********************************************************************" + cEOLZ
	_B1275LOG(cZMsg5)
	UnLockByName("zExecBusDoc_lock", .T., .F.)

Return lRet

/*
+------------+--------------------------------------------------------------+
! Funcao     ! Metodo WS                                                    !
! Autor      ! Paulo Afonso Erzinger Junior                                 !
! Descricao  ! Realiza a desmontagem de um produto no protheus              !
! Parametros !                                                              !
+------------+--------------------------------------------------------------+
*/
WSMETHOD SetDesmontagem WSRECEIVE sDesmonta WSSEND cRetorno WSSERVICE WS_BUD1275

	Local lRet      := .T.
	Local lContiZ   := .T.
	Local cZMsg6    := ""
	Local cEOL8     := CHR(13)+CHR(10)
	Local nOpcX     := 3
	Local cDocGI    := ""
	Local nQtdSegUm := 0


	cZMsg6 += " Inicio da Desmontagem "+DTOS(DATE())+" "+TIME()+cEOL8

	//DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - CONTROLE DE SEMÁFORO PARA EVITAR EXECUÇÃO CONCORRENTE
	IF !LockByName("zExecBusDoc_lock", .T., .F.)
		U_BUD1427("[BUD1275] - Atenção, outro usuário já está executando essa rotina (BuscaD3Doc)! ")
		While lContiZ
			Sleep(3000) // Aguarda 3000ms antes de tentar novamente
			IF !LockByName("zExecBusDoc_lock", .T., .F.)
			Else
				cDocGI := BuscaD3Doc()
				lContiZ := .F.
				U_BUD1427("[BUD1275] - Atenção, executando essa rotina (BuscaD3Doc)! ")
			ENDIF

		End
	Else
		cDocGI := BuscaD3Doc()
	EndIf
	//FIM - DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025

	cZMsg6 += " Doc : "+cDocGI+cEOL8

	U_BUD1427(Replicate("=",80))
	U_BUD1427("[BUD1275] - WS DESMONTAGEM DE PRODUTO - INICIO ("+TIME()+")")

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SB1")+::sDesmonta:Cabec:ORI_PRODUTO)
		cErro := "ERRO - Produto de ORIGEM nao encontrado: " +::sDesmonta:Cabec:ORI_PRODUTO
		::cRetorno := cErro
		SetSoapFault("SetDesmontagem", cErro)
		Return .F.
	EndIf

	cLocal := ::sDesmonta:Cabec:ORI_LOCAL
	nQuant := ::sDesmonta:Cabec:ORI_QUANT

	CriaSB2(SB1->B1_COD,cLocal)

	//Caclculo da segunda unidade de medida
	If SB1->B1_TIPCONV == "M"
		nQtdSegUm := nQuant * SB1->B1_CONV
	Else
		nQtdSegUm := nQuant / SB1->B1_CONV
	EndIf

	aCabecSD3 := {	{"cProduto"   , SB1->B1_COD           , Nil}, ;
		{"cLocOrig"   , cLocal                , Nil}, ;
		{"nQtdOrig"   , nQuant                , Nil}, ;
		{"nQtdOrigSe" , nQtdSegUm             , Nil}, ;
		{"cDocumento" , cDocGI                , Nil}, ;
		{"cNumLote"   , CriaVar("D3_NUMLOTE") , Nil}, ;
		{"cLoteDigi"  , CriaVar("D3_LOTECTL") , Nil}, ;
		{"dDtValid"   , CriaVar("D3_DTVALID") , Nil}, ;
		{"nPotencia"  , CriaVar("D3_POTENCI") , Nil}, ;
		{"cLocaliza"  , CriaVar("D3_LOCALIZ") , Nil}, ;
		{"cNumSerie"  , CriaVar("D3_NUMSERI") , Nil}}

	//Leio o total de itens para buscar a quantidade de produtos, afim de realizar o rateio
	nTotQuant := 0
	nTotCusto := 0

	For nX := 1 to Len(::sDesmonta:Itens)
		dbSelectArea("ZZY")
		dbSetOrder(1)
		dbGoTop()
		If dbSeek(xFilial("ZZY")+::sDesmonta:Itens[nX]:DES_PRODUTO)
			If ZZY->ZZY_CUSTO == 0
				nTotCusto += ZZY->ZZY_CUSTO
			Else
				nTotCusto := 0
				Exit
			EndIf
		Else
			nTotCusto := 0
			Exit
		EndIf
	Next nX

	If nTotCusto == 0
		For nX := 1 to Len(::sDesmonta:Itens)
			nTotQuant += ::sDesmonta:Itens[nX]:DES_QUANT
		Next nX
	EndIf

	aItensSD3  := {}
	For nX := 1 to Len(::sDesmonta:Itens)

		dbSelectArea("SB1")
		dbSetOrder(1)
		dbGoTop()
		If !dbSeek(xFilial("SB1")+::sDesmonta:Itens[nX]:DES_PRODUTO)
			cErro := "ERRO - Produto de DESTINO nao encontrado: " +::sDesmonta:Itens[nX]:DES_PRODUTO
			::cRetorno := cErro
			SetSoapFault("SetDesmontagem", cErro)
			Return .F.
		EndIf

		CriaSB2(SB1->B1_COD,cLocal)
		CriaSB2(SB1->B1_COD,::sDesmonta:Itens[nX]:DES_LOCAL)

		nQuant := ::sDesmonta:Itens[nX]:DES_QUANT

		//Calculo da segunda unidade de medida
		If SB1->B1_TIPCONV == "M"
			nQtdSegUm := nQuant * SB1->B1_CONV
		Else
			nQtdSegUm := nQuant / SB1->B1_CONV
		EndIf

		If nTotCusto > 0
			//Calculo do rateio
			dbSelectArea("ZZY")
			dbSetOrder(1)
			dbGoTop()
			If dbSeek(xFilial("ZZY")+::sDesmonta:Itens[nX]:DES_PRODUTO)
				nRateio := (ZZY->ZZY_CUSTO/nTotCusto) * 100
			Else
				nRateio := 0
			EndIf
		Else
			nRateio := (nQuant/nTotQuant) * 100
		EndIf

		AADD(aItensSD3,{	{"D3_COD"     , SB1->B1_COD           , Nil}, ;
			{"D3_LOCAL"   , ::sDesmonta:Itens[nX]:DES_LOCAL, Nil}, ;
			{"D3_QUANT"   , nQuant                , Nil}, ;
			{"D3_QTSEGUM" , nQtdSegUm             , Nil}, ;
			{"D3_RATEIO"  , nRateio               , Nil} })
		//					{"D3_LOCALIZ" , CriaVar("D3_LOCALIZ") , Nil}, ;
		//					{"D3_NUMSERI" , CriaVar("D3_NUMSERI") , Nil} })

	Next nX

	lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
	lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()
	MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aCabecSD3,aItensSD3,3,.T.)

	If lMsErroAuto
		RollbackSx8()
		cErro := "ERRO - "
		aErro := GetAutoGRLog()

		For nX := 1 To Len(aErro)
			cErro += aErro[nX] + Chr(13)+Chr(10)
		Next nX

		::cRetorno := cErro
		SetSoapFault("SetDesmontagem", cErro)
		lRet := .F.
		cZMsg6 += " Fim da Desmontagem Erro "+DTOS(DATE())+" "+TIME()+cEOL8
	Else
		cZMsg6 += " Fim da Desmontagem Sucesso "+DTOS(DATE())+" "+TIME()+cEOL8
		::cRetorno := cDocGI
		lRet := .T.
	EndIf

	//DANIEL VICTOR DA ROSA - PERSONALITEC - 10-07-2025 - FIM DO CONTROLE DE SEMÁFORO
	cZMsg6 += "*********************************************************************"+cEOL8
	_B1275L2(cZMsg6)
	UnLockByName("zExecBusDoc_lock", .T., .F.)

Return lRet

/*
+------------+--------------------------------------------------------------+
! Funcao     ! Metodo WS                                                    !
! Autor      ! Paulo Afonso Erzinger Junior                                 !
! Descricao  ! Inclui orçamento no Protheus.                                !
! Parametros !                                                              !
+------------+--------------------------------------------------------------+
*/
WSMETHOD EstTransferencia WSRECEIVE sDoc WSSEND cRetorno WSSERVICE WS_BUD1275

	Local lRet  := .T.
	Local nOpcX := 6 //Estorno

	U_BUD1427(Replicate("=",80))
	U_BUD1427("[BUD1275] - WS ESTORNO TRANSFERENCIA DE ESTOQUE - INICIO ("+TIME()+")")

	dbSelectArea("SD3")
	dbSetOrder(2)
	dbGoTop()
	If dbSeek(xFilial("SD3")+::sDoc)

		aAuto := {}
		AADD(aAuto,{::sDoc, DDATABASE})

		lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
		lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()
		MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcX)

		If lMsErroAuto
			RollbackSx8()
			cErro := ""
			aErro := GetAutoGRLog()

			For nX := 1 To Len(aErro)
				cErro += aErro[nX] + Chr(13)+Chr(10)
			Next nX

			::cRetorno := "ERRO - " + cErro
			SetSoapFault("EstTransferencia","ERRO - " + cErro)
			lRet := .F.
		Else
			::cRetorno := "Estorno realizado com sucesso!"
			lRet := .T.
		EndIf
	Else
		::cRetorno := "ERRO - Documento " + ::sDoc + " não localizado no sistema! Favor verificar com a TI!"
		SetSoapFault("EstTransferencia","ERRO - Documento " + ::sDoc + " não localizado no sistema! Favor verificar com a TI!")
		lRet := .F.
	EndIf

Return lRet

/*
+------------+--------------------------------------------------------------+
! Funcao     ! Metodo WS                                                    !
! Autor      ! Paulo Afonso Erzinger Junior                                 !
! Descricao  ! Inclui orçamento no Protheus.                                !
! Parametros !                                                              !
+------------+--------------------------------------------------------------+
*/
WSMETHOD EstDesmontagem WSRECEIVE sDoc WSSEND cRetorno WSSERVICE WS_BUD1275

	Local lRet  := .T.

	U_BUD1427(Replicate("=",80))
	U_BUD1427("[BUD1275] - WS ESTORNO DESMONTAGEM DE PRODUTO - INICIO ("+TIME()+")")

	aCabecSD3 := {}
	aItensSD3 := {}

	dbSelectArea("SD3")
	dbSetOrder(2)
	dbGoTop()
	If dbSeek(xFilial("SD3")+::sDoc)

		lMsErroAuto := .F.		//Indica retorno da MsExecAuto()
		lAutoErrNoFile := .T.	//Usada dentro da MsExecAuto()
		MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aCabecSD3,aItensSD3,5,.T.)

		If lMsErroAuto
			RollbackSx8()
			cErro := "ERRO - "
			aErro := GetAutoGRLog()

			For nX := 1 To Len(aErro)
				cErro += aErro[nX] + Chr(13)+Chr(10)
			Next nX

			::cRetorno := cErro
			SetSoapFault("EstDesmontagem", cErro)
			lRet := .F.
		Else
			::cRetorno := "Estorno realizado com sucesso!"
			lRet := .T.
		EndIf
	Else
		cErro := "ERRO - Documento " + ::sDoc + " não localizado no sistema! Favor verificar com a TI!"
		::cRetorno := cErro
		SetSoapFault("EstDesmontagem", cErro)
		lRet := .F.
	EndIf

Return lRet

/*
+------------+--------------------------------------------------------------+
! Funcao     ! Metodo WS                                                    !
! Autor      ! Paulo Afonso Erzinger Junior                                 !
! Descricao  ! Realiza uma transferência de estoque no protheus             !
! Parametros !                                                              !
+------------+--------------------------------------------------------------+
*/
WSMETHOD SaldoEst WSRECEIVE cProduto, cLocal, nQuant WSSEND cRetorno WSSERVICE WS_BUD1275

	Local lRet  := .T.

	U_BUD1427(Replicate("=",80))
	U_BUD1427("[BUD1275] - WS SALDO EM ESTOQUE - INICIO ("+TIME()+")")

	::cRetorno := "OK"
	::cProduto := PADR(::cProduto,TAMSX3("B1_COD")[1])

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbGoTop()
	If !dbSeek(xFilial("SB1")+::cProduto)
		::cRetorno := "ERRO - Produto de ORIGEM nao encontrado"
		//SetSoapFault("SaldoEst","ERRO - Produto de ORIGEM nao encontrado")
		//Return .F.
	EndIf

	dbSelectArea("SB2")
	dbSetOrder(1)
	dbGoTop()
	If dbSeek(xFilial("SB2")+::cProduto+::cLocal)
		nSaldo := SaldoSb2()
		If ::nQuant > nSaldo
			cErro := "ERRO - A quantidade solicitada ("+ALLTRIM(STR(::nQuant))+") e maior do que o disponivel em estoque ("+ALLTRIM(STR(nSaldo))+")"
			::cRetorno := cErro
			//06051982 RETIRADO POIS SE USAR O SetSoapFault NÃO ESTAVA PASSANDO O VALOR cRetorno, ALTERADO EM 18032021;
			//SetSoapFault("SaldoEst",cErro)
			//Return .F.
		EndIf
	Else
		cErro := "ERRO - A quantidade solicitada ("+ALLTRIM(STR(::nQuant))+") e maior do que o disponível em estoque (0)"
		::cRetorno := cErro
		//SetSoapFault("SaldoEst",cErro)
		//Return .F.
	EndIf

Return lRet

/*
+-----------+--------------------------------------------------------------+
! Funcao    ! Estrutura dos itens                                          !
! Autor     ! Paulo Afonso Erzinger Junior                                 !
! Descricao ! Estrutura para armazenamento dos itens da transferência      !
+-----------+--------------------------------------------------------------+
*/
WSSTRUCT vTransf
	WSDATA Itens AS ARRAY OF SD3
ENDWSSTRUCT

WSSTRUCT SD3
	WSDATA ORI_PRODUTO AS STRING
	WSDATA ORI_LOCAL AS STRING
	WSDATA DES_PRODUTO AS STRING
	WSDATA DES_LOCAL AS STRING
	WSDATA QUANTIDADE AS FLOAT
	WSDATA DOC_GUIA AS STRING
ENDWSSTRUCT

/*
+-----------+--------------------------------------------------------------+
! Funcao    ! Estrutura da desmontagem de produtos                         !
! Autor     ! Paulo Afonso Erzinger Junior                                 !
! Descricao ! Estrutura para desmontagem de um produto                     !
+-----------+--------------------------------------------------------------+
*/
WSSTRUCT vDesmonta
	WSDATA Cabec AS DESMONTA_CABEC
	WSDATA Itens AS ARRAY OF DESMONTA_ITENS
ENDWSSTRUCT

WSSTRUCT DESMONTA_CABEC
	WSDATA ORI_PRODUTO AS STRING
	WSDATA ORI_LOCAL AS STRING
	WSDATA ORI_QUANT AS FLOAT
ENDWSSTRUCT

WSSTRUCT DESMONTA_ITENS
	WSDATA DES_PRODUTO AS STRING
	WSDATA DES_LOCAL AS STRING
	WSDATA DES_QUANT AS FLOAT
ENDWSSTRUCT


/*
/============================================================================\
|Nome              : BuscaD3Doc                                              |
|============================================================================|
|Descricao         : Busca numeração para documento na SD3                   |
|============================================================================|
|Autor             : Thiago L. Machado                                       |
|============================================================================|
|Data de Criacao   : 19/02/2020                                              |
\============================================================================/
*/
Static Function BuscaD3Doc()

	Local cDocGIRet	:= 'gi0000000'

	// Busco última numeração:
	If (Select("T1307D3") <> 0)
		dbSelectArea("T1307D3")
		dbCloseArea()
	EndIf
	BeginSQL ALIAS "T1307D3"
		SELECT
			DISTINCT TOP 1 ISNULL(MAX(D3_DOC), 'gi0000000') AS D3MKT
		FROM
			SD3010 (NOLOCK)
		WHERE
			D3_FILIAL = %xfilial:SD3%
			AND D3_DOC BETWEEN 'gi0000000' AND 'gizzzzzzzzz'
			AND %TABLE:SD3%.%NotDel%
	EndSQL
	If !T1307D3->(Eof())
		cDocGIRet := T1307D3->D3MKT
		While .T.
			// Somo um na numeração:
			cDocGIRet := Soma1(cDocGIRet)

			// Verifico se o registro existe:
			If (Select("TSD3EXIST") <> 0)
				dbSelectArea("TSD3EXIST")
				dbCloseArea()
			EndIf
			BeginSQL ALIAS "TSD3EXIST"
				SELECT
					DISTINCT TOP 1 D3_DOC
				FROM
					SD3010 (NOLOCK)
				WHERE
					D3_FILIAL = %xfilial:SD3%
					AND D3_DOC = %Exp:cDocGIRet%
					AND %TABLE:SD3%.%NotDel%
			EndSQL
			// Caso não exista eu posso sair do loop:
			If TSD3EXIST->(Eof())
				Exit
			EndIf
		EndDo
	EndIf

Return cDocGIRet

/*Função para gerar Logs de GuiA
Daniel Victor da Rosa - Personalitec
14/08/2025 - Para Transferência
*/
Static Function _B1275LOG(_cZMsg)

	Local cArqTxt := "GUIA_TRANSFERENCIA_BUD1275_LOGS.txt"
	Local nHdlog  := fOpen(cArqTxt,2)

	//caso não consiga abrir o arquivo...
	If nHdlog == -1
		//tenta cria-lo
		nHdlog := fCreate(cArqTxt,2)
		//se também der erro
		If 	nHdlog == -1
			U_BUD1427('Erro ao Gerar o Arquivo de Log GUIA_BUD1275_LOGS !!!')
			Return
		EndIf
	Else
		//vai para o fim do arquivo
		fSeek(nHdlog,0,2)
	Endif

	fWrite(nHdlog,_cZMsg,Len(_cZMsg))

	fClose(nHdlog)

Return


/*Função para gerar Logs de GuiA
Daniel Victor da Rosa - Personalitec
14/08/2025 - Para Desmontagem
*/
Static Function _B1275L2(_cZMsg6)

	Local cArqTxt := "GUIA_DESMONTAGEM_BUD1275_LOGS.txt"
	Local nHdlog  := fOpen(cArqTxt,2)

	//caso não consiga abrir o arquivo...
	If nHdlog == -1
		//tenta cria-lo
		nHdlog := fCreate(cArqTxt,2)
		//se também der erro
		If 	nHdlog == -1
			U_BUD1427('Erro ao Gerar o Arquivo de Log GUIA_BUD1275_LOGS !!!')
			Return
		EndIf
	Else
		//vai para o fim do arquivo
		fSeek(nHdlog,0,2)
	Endif

	fWrite(nHdlog,_cZMsg6,Len(_cZMsg6))

	fClose(nHdlog)

Return

