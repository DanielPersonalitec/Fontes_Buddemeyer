#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} TestMT119
(long_description)
@type user function
@Daniel Victor da Rosa
@since 10/02/2026
/*/
User Function TestMT119()

    RPCSETENV("01","01")

    Local cPara   :=  "dan.elvictor.rosa@gmail.com"

    // INICIA PROCESSO
    oProcess := TWFProcess():New("000001","Exclusão NF Entrada")
    oProcess:NewTask("0000055","\WORKFLOW\wfexcluinf.HTML")

    oProcess:cSubject := " Excluido Nota Fiscal de Entrada - DIMP: " + "TESTE123" + "-" + "SERIE123"

    oProcess:cTo:= cPara

    oHTML := oProcess:oHTML

    If	Type('oHTML') == 'U'
        Return .T.
    EndIf

    _DataExtenso := strzero(day(Date()),2)    + " de " + MesExtenso(month(Date())) + " de " +strzero(year(Date()),4)
    _cData := Capital(alltrim(SM0->M0_CIDCOB))+", "+_DataExtenso

    // Data
    oHtml:ValByName("DATA"	,_cData)

    AADD((oHtml:ValByName("IT.NOTA"))	,"TESTE123" + " " + "SERIE123")

    AADD((oHtml:ValByName("IT.FORNEC"))	,"FORNECEDOR TESTE")
    AADD((oHtml:ValByName("IT.VALOR")) 	,Transform(1000.00,"@E 99,999,999.99"))
    AADD((oHtml:ValByName("IT.DTENT"))	, Date())
    AADD((oHtml:ValByName("IT.USUA"))	, alltrim(upper(subs(cUsuario,7,13))))

    //FINALIZA O PROCESSO
    oProcess:Start()
    oProcess:Finish()

    RPCCLEARENV()


Return
