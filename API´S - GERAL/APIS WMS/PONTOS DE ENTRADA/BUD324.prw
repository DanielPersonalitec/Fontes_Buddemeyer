#INCLUDE "rwmake.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} BUD324
    CADASTRO DE CORES PARA USO NA INTERNET
    @type function
    @author GUSTAVO
	@author Daniel Victor da Rosa - 30/03/2026 - Ajuste para integração com o WMS
    @since 13/01/04
/*/

User Function BUD324()

    Private cVldAlt := "EXECBLOCK('VldAltZY',.F.,.F.)"
    Private cVldExc := "EXECBLOCK('VldExcZY',.F.,.F.)"

    //AxCadastro(cString,"Cadastro de Cores",cVldAlt,cVldExc)
    AXCADASTRO('SZT',"Cadastro de Cores",".T.",cVldAlt)

Return()

/*/{Protheus.doc} VldAlt
    VALIDACAO DE ALTERACAO NOS CAMPOS
    @type function
    @author GUSTAVO
	@author Daniel Victor da Rosa - 30/03/2026 - Ajuste para integração com o WMS
    @since 13/01/04
/*/
User Function VldAltZY()

    Local lRet := .T.
    Local lIncDel := .T.
    Private lSucIntC := .F.

    U_BUD1513(lIncDel)

    IF lSucIntC
        IF INCLUI
            M->ZT_INTWMS := "S"
        ELSE
            M->ZT_INTWMS := "A"
        ENDIF
    ENDIF

Return lRet
