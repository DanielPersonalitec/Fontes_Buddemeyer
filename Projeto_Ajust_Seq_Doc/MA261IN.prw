#Include 'Protheus.ch'

/*
/=========================================================================\
|Módulo      : Estoque/Custos                   	                   	 |
|=========================================================================|
|Programa    : MA261IN.PRW  | Responsável: Thiago L. Machado	          |
|=========================================================================|
|Descricao   : P.E para exibir campos no estorno da transf. modelo 2      |
|=========================================================================|
|Data        : 26/04/2017 											 |
|=========================================================================|
|Programador : Paulo Afonso Erzinger Junior                               |
\=========================================================================/
*/

User Function MA261IN()

	Local nPosGui := 0

	//Adicionado por Paulo Afonso em 02/05/2017 para informar o motivo da transferência
	If ExistBlock("BUD1268I")
		U_BUD1268I()
	EndIf

	// Demonstra o número da guia na rotina de transferência:
	If cEmpAnt == "01" .And. !lAutoma261 .And. !IsBlind()
		If Type('aCols') == 'A' .And. Type('aHeader') == 'A'
			nPosGui 					:= aScan(aHeader, {|x| AllTrim(x[2]) == "D3_DOCGUIA"})
			aCols[Len(aCols), nPosGui] 	:= SD3->D3_DOCGUIA
		EndIf
	EndIf

Return

