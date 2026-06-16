#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �BUD1030     � Autor � AP6 IDE            � Data � 04/11/2011���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          � Manuten��o dos Itens da Grade de Encaixotamento            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function BUD1030()
/*

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZCN"

dbSelectArea("ZCN")
dbSetOrder(1)

AxCadastro(cString,"Itens das Grades de Encaixotamento",cVldExc,cVldAlt)
*/

Local cVldAlt 	:= ".T." 
Local cVldExc 	:= ".T." 
Local aCores 	:= {}

Private lCancelar	:= .T.
Private aRotina 	:= { {"&Pesquisar"	,"AxPesqui",0,1} ,;
             			 {"&Visualizar"	,"AxVisual",0,2} ,;
             			 {"&Incluir"	,"AxInclui",0,3} ,;
             			 {"&Alterar"	,"AxAltera",0,4} ,;
             			 {"&Excluir"	,"AxDeleta",0,5} }					

Private cCadastro	:= "Itens das Grades de Encaixotamento"
Private cString 	:= "ZCN"
Private cFiltro		:= ""

aCampos := { {"Item"			,"ZCN_ITEM"}	,;         
             {"Refer�ncia"		,"ZCN_REF"}		,;         
             {"Tamanho"			,"ZCN_TAM"}		,;         
             {"C�d. Embalagem"	,"ZCN_CODEMB"}	,;         
             {"Quantidade"		,"ZCN_QTDE"}	}        

// -- Cadastrado no Configurador
If !Pergunte("BUD1030",.T.)
	Return
EndIf

If !Empty(MV_PAR01)
	cFiltro	+= " .AND. ZCN_CODIGO == '"+MV_PAR01+"' "
EndIf

dbSelectArea("ZCN")
dbSetOrder(1)
Set Filter to &("ZCN_FILIAL == '"+xFilial('ZCN')+"' " + cFiltro)
dbSelectArea(cString)
dbGotop()
Mbrowse(006,001,022,075,cString, aCampos, , , , , aCores, , , ,)

// Integracao WMS - Grade de Encaixotamento
U_BUD1519()

Return

User Function BUD1030I()
cItem	:= "0001" 
If (Select("TI1030") <> 0)
	dbSelectArea("TI1030")
	dbCloseArea()
EndIf
BeginSQL ALIAS "TI1030"
	SELECT DISTINCT TOP 1 ZCN_ITEM FROM %TABLE:ZCN%
	WHERE %NOTDEL% AND ZCN_FILIAL = %EXP:xFilial("ZCN")%
	AND ZCN_CODIGO = %EXP:MV_PAR01%
	ORDER BY ZCN_ITEM DESC
ENDSQL
DbSelectArea("TI1030")
If !Empty(TI1030->ZCN_ITEM)
	cItem		:= Soma1(TI1030->ZCN_ITEM)
EndIf
DbCloseArea("TI1030")	
Return cItem
