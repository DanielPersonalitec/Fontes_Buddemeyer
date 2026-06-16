#Include 'Protheus.ch'

/*
/=========================================================================\
|Módulo      : Estoque/Custos                   	                   	 |
|=========================================================================|
|Programa    : MA261CPO.PRW  | Responsável: Thiago L. Machado	          |
|=========================================================================|
|Descricao   : P.E para incluir campos do usuário na Transf. mod 2   	 |
|=========================================================================|
|Data        : 26/04/2017 											 |
|=========================================================================|
|Programador : Paulo Afonso Erzinger Junior                               |
\=========================================================================/
*/

User Function MA261CPO()

	Local aArea := GetArea()
	Local lAuto   := IsBlind()

	//Adicionado por Paulo Afonso em 26/04/2017 para informar o motivo da transferência
	If ExistBlock("BUD1268MD2")
		U_BUD1268MD2()
	EndIf

	// Inclusão do campo de documento da guia eletrônica:
	If !lAuto
		If cEmpAnt == "01" .And. !lAutoma261 //Somente na empresa 01
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbGoTop()
			dbSeek("D3_DOCGUIA")
			Aadd(aHeader, {SX3->X3_TITULO, SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, '', SX3->X3_USADO, 'C', SX3->X3_ARQUIVO, ''})
		EndIf
	EndIf

	RestArea(aArea)

Return

