#INCLUDE 'Protheus.ch'
#INCLUDE 'Restful.ch'

/*
+------------+--------------------------------------------------------------+
! Classe     ! API PDA AUTH LOGIN                                           !
! Autor      ! Caique Silva                                                 !
! Descricao  ! Autenticacao PDA HUB - Geracao Token                         !
! Data       ! 28-01-2026                                                   !
+------------+--------------------------------------------------------------+
*/
Class PDAAuthLogin

    Data cUrlBase
    Data cLogin
    Data cPassword
    Data cToken
    Data cRefreshToken
    Data aHeader
    Data cEndPoint
    Data cCreated
    Data cExpiration
    Data lAuthenticated
    Data cLastError

    Method New() Constructor
    Method GetToken()
    Method GetHeader()
    Method RefreshToken()
    Method IsAuthenticated()
    Method GetLastError()

EndClass

/*/ {Protheus.doc} New
    Construtor de classe
    @type Method
    @author Caique Silva
    @since 28/01/2026
/*/
Method New(cLogin, cPassword) Class PDAAuthLogin
    
    Default cLogin    := GetMv('BUD_1505LG')
    Default cPassword := GetMv('BUD_1505PW')
    
    Self:cUrlBase       := GetMv('BUD_1505UR')
    Self:cLogin         := cLogin
    Self:cPassword      := cPassword
    Self:lAuthenticated := .F.
    Self:cLastError     := ''
    Self:cToken         := Self:GetToken()
    Self:aHeader        := Self:GetHeader()


Return Self

/*/ {Protheus.doc} GetToken
    Obtem o token de autenticacao da API
    @type Method
    @author Caique Silva
    @since 28/01/2026
    @return cToken - Token de autenticacao
/*/
Method GetToken() Class PDAAuthLogin

    Local aHeader   := {}
    Local oJsonBody := JsonObject():New()
    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New(Self:cUrlBase)

    Self:cEndPoint := '/api/Autenticacao'
    oRest:SetPath(Self:cEndPoint)

    AAdd(aHeader, "Content-Type: application/json")

    oJsonBody['login']    := Self:cLogin
    oJsonBody['password'] := alltrim(Self:cPassword)

    oRest:SetPostParams(oJsonBody:ToJson())

    If oRest:Post(aHeader)
        
        oJsonRet:FromJson(oRest:GetResult())

        If !Empty(oJsonRet["accessToken"])
            Self:cToken         := oJsonRet["accessToken"]
            Self:cRefreshToken  := oJsonRet["refreshToken"]
            Self:cCreated       := oJsonRet["created"]
            Self:cExpiration    := oJsonRet["expiration"]
            Self:lAuthenticated := .T.
        Else
            Self:cLastError := "Token não retornado pela API"
            Self:lAuthenticated := .F.
        EndIf
        
    Else
        Self:cLastError := "Erro ao autenticar: " + oRest:GetLastError()
        Self:lAuthenticated := .F.
    EndIf

Return Self:cToken

/*/ {Protheus.doc} GetHeader
    Retorna o cabeçalho com o token de autenticacao
    @type Method
    @author Caique Silva
    @since 28/01/2026
    @return aHeader - Array com cabeçalho
/*/
Method GetHeader() Class PDAAuthLogin

    Local aHeader := {}

    AAdd(aHeader, "Content-Type: application/json")
    
    If !Empty(Self:cToken)
        AAdd(aHeader, "Authorization: Bearer " + Self:cToken)
    EndIf

Return aHeader

/*/ {Protheus.doc} RefreshToken
    Atualiza o token de autenticacao
    @type Method
    @author Caique Silva
    @since 28/01/2026
    @return lSuccess - .T. se renovado com sucesso
/*/
Method RefreshToken() Class PDAAuthLogin

    Local aHeader   := {}
    Local oJsonBody := JsonObject():New()
    Local oJsonRet  := JsonObject():New()
    Local oRest     := FwRest():New(Self:cUrlBase)
    Local lSuccess  := .F.

    Self:cEndPoint := "/api/Autenticacao/Refresh-Token"
    oRest:SetPath(Self:cEndPoint)

    AAdd(aHeader, "Content-Type: application/json")

    oJsonBody["login"]        := Self:cLogin
    oJsonBody["refreshToken"] := Self:cRefreshToken

    oRest:SetPostParams(oJsonBody:ToJson())

    If oRest:Post(aHeader)
        
        oJsonRet:FromJson(oRest:GetResult())

        If !Empty(oJsonRet["accessToken"])
            Self:cToken         := oJsonRet["accessToken"]
            Self:cRefreshToken  := oJsonRet["refreshToken"]
            Self:cCreated       := oJsonRet["created"]
            Self:cExpiration    := oJsonRet["expiration"]
            Self:aHeader        := Self:GetHeader()
            Self:lAuthenticated := .T.
            lSuccess            := .T.
        Else
            Self:cLastError := "Token não renovado pela API"
        EndIf
        
    Else
        Self:cLastError := "Erro ao renovar token: " + oRest:GetLastError()
    EndIf

Return lSuccess

/*/ {Protheus.doc} IsAuthenticated
    Verifica se está autenticado
    @type Method
    @author Caique Silva
    @since 28/01/2026
    @return lAuthenticated
/*/
Method IsAuthenticated() Class PDAAuthLogin
Return Self:lAuthenticated

/*/ {Protheus.doc} GetLastError
    Retorna o último erro ocorrido
    @type Method
    @author Caique Silva
    @since 28/01/2026
    @return cLastError
/*/
Method GetLastError() Class PDAAuthLogin
Return Self:cLastError
