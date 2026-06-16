#INCLUDE "RWMAKE.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*
/=========================================================================\
| Módulo      : API REST                                                  |
|=========================================================================|
| Programa    : VRN0176.PRW   | Responsável: Marcos Schoeffel             |
|=========================================================================|
| Descricao   : Api de reprocessar cupons lojas LTD                       |
|=========================================================================|
| Data        : 17/12/2024                                                |
|=========================================================================|
| Programador : César Grossl                                              |
\=========================================================================/
*/
WSRESTFUL cuponsltd DESCRIPTION "Reprocessar Cupons Lojas LTD"

	WSMETHOD POST DESCRIPTION "Recebe variveis pelo post" WSSYNTAX "/cuponsltd/ [ POST ]"

END WSRESTFUL


WSMETHOD POST WSSERVICE cuponsltd

    ::SetContentType("application/json")
    Local cBody := ::GetContent()
    Local oCupom
    Local cIDVenda := ""
    FWJsonDeserialize(DecodeUTF8(cBody),@oCupom)
	cIDVenda := oCupom:cIDVenda
    //Chama rotina para solicitar o reprocessamento
    U_VRN0160(cIDVenda,'', .t.)

Return .T.    
