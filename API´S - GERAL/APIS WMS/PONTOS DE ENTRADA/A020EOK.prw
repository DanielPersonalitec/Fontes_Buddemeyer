//Bibliotecas
#Include "Protheus.ch"

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  A020EOK                                                                                       |
 | Desc:  Confirmacao do cadastro de fornecedores - Integracao WMS                                      |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=6087480                                  |
 *------------------------------------------------------------------------------------------------------*/

User Function A020EOK()
    Local aArea   := GetArea()
    Local aAreaA2 := SA2->(GetArea())
    Local lRet    := .T.

    //Se for inclusao
    If INCLUI
        U_BUD1506()
    EndIf

    //Se for alteracao
    If ALTERA
        U_BUD1506()
    EndIf

    RestArea(aAreaA2)
    RestArea(aArea)
Return lRet
