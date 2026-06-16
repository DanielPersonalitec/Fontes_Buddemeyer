//Bibliotecas
#Include "Protheus.ch"

/*------------------------------------------------------------------------------------------------------*
 | P.E.:  A010TOK                                                                                       |
 | Desc:  Confirmacao do cadastro de produtos - Integracao WMS                                          |
 | Link:  http://tdn.totvs.com/pages/releaseview.action?pageId=643991432                                |
 *------------------------------------------------------------------------------------------------------*/

User Function A010TOK()
    Local aArea   := GetArea()
    Local aAreaB1 := SB1->(GetArea())
    Local lRet    := .T.
    Private lA010Z := .T.
    Private lSuces := .F.

    //Se for inclusao
    If INCLUI
        U_BUD1508(lA010Z)
        IF lSuces
            M->B5_INTWMS := "S"
        ELSE
            M->B5_INTWMS := "E"
        ENDIF
    EndIf

    //Se for alteracao
    If ALTERA
        U_BUD1508(lA010Z)
        IF lSuces
            M->B5_INTWMS := "S"
        ELSE
            M->B5_INTWMS := "E"
        ENDIF
    EndIf

    RestArea(aAreaB1)
    RestArea(aArea)
Return lRet
