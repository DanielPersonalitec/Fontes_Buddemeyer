#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#Include "Protheus.ch"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} PDALogEntry
    Classe que representa um único registro de log PDA.
    Responsável por armazenar e validar os dados antes da gravação.
    @author Caique
    @since  17/02/2026
/*/
Class PDALogEntry

    Data cAlias
    Data cTipo
    Data cRegistro
    Data cDescricao
    Data dData
    Data cHora

    Method New(cAlias, cTipo, cRegistro, cDescricao) Constructor
    Method Validate()

EndClass

/*/{Protheus.doc} PDALogEntry:New
    Construtor - recebe os dados do log, valida e trunca conforme ZGO.
    @param  cAlias      Caracter  Alias da tabela (máx. 3)
    @param  cTipo       Caracter  Tipo da operação (máx. 10)
    @param  cRegistro   Caracter  Código do registro (máx. 30)
    @param  cDescricao  Caracter  Descrição da operação (máx. 50)
/*/
Method New(cAlias, cTipo, cRegistro, cDescricao) Class PDALogEntry

    // Garante que todos os parâmetros são strings
    If ValType(cAlias)     <> "C" ; cAlias     := "" ; EndIf
    If ValType(cTipo)      <> "C" ; cTipo      := "" ; EndIf
    If ValType(cRegistro)  <> "C" ; cRegistro  := "" ; EndIf
    If ValType(cDescricao) <> "C" ; cDescricao := "" ; EndIf

    // Trunca respeitando os tamanhos da tabela ZGO
    Self:cAlias     := SubStr(AllTrim(cAlias),     1, 3)
    Self:cTipo      := SubStr(AllTrim(cTipo),      1, 10)
    Self:cRegistro  := SubStr(AllTrim(cRegistro),  1, 30)
    Self:cDescricao := SubStr(AllTrim(cDescricao), 1, 50)

    // Preenche dados automáticos no momento da criação
    Self:dData := Date()
    Self:cHora := SubStr(Time(), 1, 5) // HH:MM conforme ZGO_HORA

Return Self

/*/{Protheus.doc} PDALogEntry:Validate
    Valida se o entry possui os campos mínimos obrigatórios.
    @return Logico  .T. se válido, .F. se inválido
/*/
Method Validate() Class PDALogEntry

    If Empty(Self:cAlias)
        ConOut("[PDALogEntry] ERRO: cAlias nao informado")
        Return .F.
    EndIf

    If Empty(Self:cTipo)
        ConOut("[PDALogEntry] ERRO: cTipo nao informado")
        Return .F.
    EndIf

Return .T.

// =============================================================================

/*/{Protheus.doc} PDALogger
    Classe responsável pela gravação de logs PDA na tabela ZGO.
    Recebe um PDALogEntry e persiste no banco de dados.
    @author Caique
    @since  17/02/2026

    Exemplo de uso:
        Local oEntry  := PDALogEntry():New("SA1", "ERRO", "000001/01", "Sem CPF/CNPJ")
        Local oLogger := PDALogger():New()
        oLogger:Gravar(oEntry)

    Forma abreviada:
        PDALogger():New():Gravar(PDALogEntry():New("SA1", "INCLUSAO", "10", "Sucesso"))
/*/
Class PDALogger

    Method New() Constructor
    Method Gravar(oEntry)

EndClass

/*/{Protheus.doc} PDALogger:New
    Construtor da classe PDALogger.
/*/
Method New() Class PDALogger
Return Self

/*/{Protheus.doc} PDALogger:Gravar
    Grava um PDALogEntry na tabela ZGO.
    @param  oEntry  Objeto  Instância de PDALogEntry com os dados do log
    @return Logico  .T. se gravou com sucesso, .F. em caso de erro
/*/
Method Gravar(oEntry) Class PDALogger

    Local lRet      := .T.

    // Valida se recebeu um objeto válido
    If ValType(oEntry) <> "O"
        ConOut("[PDALogger] ERRO: oEntry invalido")
        Return .F.
    EndIf

    // Valida campos obrigatórios do entry
    If ! oEntry:Validate()
        Return .F.
    EndIf

    DBSelectArea("ZGO")
    RecLock("ZGO", .T.)
    ZGO->ZGO_ALIAS  := oEntry:cAlias
    ZGO->ZGO_TIPO   := oEntry:cTipo
    ZGO->ZGO_REGIST := oEntry:cRegistro
    ZGO->ZGO_DESCRI := oEntry:cDescricao
    ZGO->ZGO_DATA   := oEntry:dData
    ZGO->ZGO_HORA   := oEntry:cHora
    ZGO->(MsUnlock())

Return lRet

// =============================================================================

/*/{Protheus.doc} PDALOG01
    Função de entrada mantida para compatibilidade com chamadas existentes.
    Internamente instancia PDALogEntry e PDALogger.
    @param  cAlias      Caracter  Alias da tabela relacionada
    @param  cTipo       Caracter  Tipo da operação
    @param  cRegistro   Caracter  Código do registro
    @param  cDescricao  Caracter  Descrição da operação
    @return Logico  .T. se gravou com sucesso, .F. em caso de erro
    @author Caique
    @since  17/02/2026
/*/
User Function PDALOG01(cAlias, cTipo, cRegistro, cDescricao)

    Local oEntry  := Nil
    Local oLogger := Nil
    Local lRet    := .F.

    Default cAlias     := ""
    Default cTipo      := ""
    Default cRegistro  := ""
    Default cDescricao := ""

    oEntry  := PDALogEntry():New(cAlias, cTipo, cRegistro, cDescricao)
    oLogger := PDALogger():New()
    lRet    := oLogger:Gravar(oEntry)

Return lRet
