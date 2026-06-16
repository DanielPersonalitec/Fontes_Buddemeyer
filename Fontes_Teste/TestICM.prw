#INCLUDE 'TOTVS.CH'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

User Function TestICM()

    Local  _cNota  := "804458"
    Local  _cSerie := "4"
    Local  cQry    := ""
    Local  nCoutZ8 := 0

    cQry := " SELECT ROUND(((CDA_BASE-SD1.D1_XDICM ) / 0.96),2) AS BASE, ROUND((((CDA_BASE-SD1.D1_XDICM ) / 0.96) * 1.00)/100,2) AS VALOR, "
    cQry += " CDA_FILIAL, "
    cQry += " CDA_TPMOVI, "
    cQry += " CDA_ESPECI, "
    cQry += " CDA_FORMUL, "
    cQry += " CDA_NUMERO, "
    cQry += " CDA_SERIE,  "
    cQry += " CDA_CLIFOR, "
    cQry += " CDA_LOJA,   "
    cQry += " CDA_NUMITE, "
    cQry += " CDA_SEQ,    "
    cQry += " CDA_CODLAN, "
    cQry += " CDA_CALPRO, "
    cQry += " F6_VALOR,   "
    cQry += " (SELECT SUM(ROUND(((CDA_BASE / 0.96) * 1.00) / 100,2))  "
    cQry += " FROM "+RETSQLNAME("CDA") +" CDAB  "
    cQry += " WHERE CDAB.CDA_FILIAL = CDA.CDA_FILIAL  "
    cQry += " AND CDAB.CDA_NUMERO = CDA.CDA_NUMERO  "
    cQry += " AND CDAB.CDA_SERIE = CDA.CDA_SERIE  "
    cQry += " AND CDAB.CDA_GNRE <> ''  "
    cQry += " AND CDAB.D_E_L_E_T_ = '') AS CDATOTAL  "
    cQry += " FROM "+RETSQLNAME("SF6") +" F6, "+RETSQLNAME("CDA") +" CDA, "+RETSQLNAME("SD1") +" SD1  "
    cQry += " WHERE F6.D_E_L_E_T_ = ''  "
    cQry += " AND CDA.D_E_L_E_T_ = ''  "
    cQry += " AND F6_FILIAL = '01'  "
    cQry += " AND CDA_FILIAL = '01'  "
    cQry += " AND F6_SERIE = CDA_SERIE  "
    cQry += " AND F6_DOC = CDA_NUMERO  "
    cQry += " AND F6_DOC = "+valtosql(_cNota)
    cQry += " AND F6_SERIE = "+valtosql(_cSerie)
    cQry += " AND D1_FILIAL = CDA_FILIAL  "
    cQry += " AND D1_DOC = CDA_NUMERO  "
    cQry += " AND D1_SERIE = CDA_SERIE  "
    cQry += " AND D1_FORNECE = CDA_CLIFOR  "
    cQry += " AND D1_LOJA = CDA_LOJA  "
    cQry += " AND D1_ITEM = CDA_NUMITE  "
    cQry += " AND SD1.D_E_L_E_T_ = ''  "

    If (Select("TRB1")<>0)
        dbSelectArea("TRB1")
        dbCloseArea()
    End

    cQry := changequery(cQry)

    TCQuery cQry NEW ALIAS "TRB1"


    While TRB1->(!Eof())
        nCoutZ8++
        TRB1->(dbSkip())
    EndDo

Return
