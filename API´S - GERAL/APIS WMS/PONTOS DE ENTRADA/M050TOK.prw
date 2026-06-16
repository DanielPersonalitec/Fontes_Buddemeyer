#Include "Protheus.ch"

User Function M050TOK()

    Local lRet := .T.
    Private lM050Z := .T.
    Private lSuces := .F.

    IF ALTERA
        U_BUD1511(lM050Z)
        IF lSuces
            M->ZT_INTWMS := "A"
        ELSE
            M->ZT_INTWMS := "E"
        ENDIF
    ELSE
        // U_BUD1511(lM050Z)
        // IF lSuces
        //     M->ZT_INTWMS := "A"
        // ELSE
        //     M->ZT_INTWMS := "E"
        //     ENDIFF
        // ENDIF
    ENDIF

Return lRet
