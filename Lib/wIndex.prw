#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#include "tryexception.ch"
#INCLUDE "INNLIB.CH"

User Function wIndex()

	Local cHtml 	:= ""
	Local cX
	Local cAtion
	Local cMsg 		:= ""
	Local lDebug	:= .F.
	Local lTrocaFil := .F.
	
	Public oINNWeb 	:= nil
	Public oINNLog	:= Nil

	WEB EXTENDED INIT cHtml
					
		TRY EXCEPTION

			TcInternal( 1, " INN web Sessao: " + httpSession->SESSIONID )
					
			HTTPSetPart(.F.)
		
			if Valtype(HttpGet->WsEmp) == "C" .and. !empty(HttpGet->WsEmp)
				HttpSession->WsEmp := HttpGet->WsEmp
				lTrocaFil := .T.
			elseif !Valtype(HttpSession->WsEmp) == "C" .and. empty(HttpSession->WsEmp)
				MyOpenSM0()
			endif
				
			if Valtype(HttpGet->WsFil) == "C" .and. !empty(HttpGet->WsFil)
				HttpSession->WsFil := HttpGet->WsFil
				lTrocaFil := .T.
			elseif !Valtype(HttpSession->WsFil) == "C" .and. empty(HttpSession->WsFil)
				MyOpenSM0()
			endif
			
			//RPCClearEnv()
			RPCSetType(3)// 3 - Excel Nao come licenca
			RPCSetEnv(HttpSession->WsEmp,HttpSession->WsFil,,,,"INN web",,,,,)//FILIAL_CHUMBADA
			RPCSetEmpFil( HttpSession->WsEmp , HttpSession->WsFil )

			IF Select("SM0") == 0 
				UserException("Erro ao abrir ambiente! SM0 não esta aberta!")
			ENDIF

			if !( SM0->(dbSeek(HttpSession->WsEmp+HttpSession->WsFil)) )
				UserException("Erro ao abrir ambiente! SM0 não esta aberta!")
			ENDIF
			
			PUTMV("IN_TOKEN", MD5( "INNOVIOS_INNWEB_" + upper(ALLTRIM(GetEnvServer())) + dtos(Date()) , 2 ) )

			//chama a classe
			oINNWeb	:= ClsINNWeb():New()

			if ExistBlock("Criadb")
				ExecBlock("Criadb",.F.,.F.)
			endif

			if GetPvProfString("INNWEB", "DEBUG", "0",GetAdv97() ) == "1" .and. ExistBlock("wINNLog") 
				lDebug := .T.
				oINNWeb:lDebug := .T.
			endif

			if lDebug
				oINNLog := INNLog():New()
				oINNLog:SetTpServ("web")
				oINNLog:SetServico("INNWeb")
				oINNLog:SetURL(fGetFullEnd())
			endif
									
			//Para validação de usuario
			cUsuario := iif(Valtype(HttpPost->inputusuario) == "C" .and. !empty(HttpPost->inputusuario),HttpPost->inputusuario,"")			
			cPass    := iif(Valtype(HttpPost->inputPassword) == "C" .and. !empty(HttpPost->inputPassword),HttpPost->inputPassword,"")
			cWSUsr   := iif(Valtype(HttpGet->WSUsr) == "C" .and. !empty(HttpGet->WSUsr),HttpGet->WSUsr,"")
			cToken   := iif(Valtype(HttpGet->Token) == "C" .and. !empty(HttpGet->Token),HttpGet->Token,"")
			
			if cWSUsr == "S"
				cUsuario := ""
				cPass    := ""
				cMsg     := "Usuario desconectado!"
				HttpSession->UseName := ""
				HttpSession->UseSenh := ""
				HttpSession->UsrToken := ""
			endif
			
			if !Empty(cToken)
				HttpSession->UsrToken := cToken
			endif
			
			if !Empty(cUsuario) .and. !Empty(cPass)
				fLoga(cUsuario,cPass)
			endif					
			
			//cria a chamada da pagina
			if lTrocaFil

				oINNWeb:SetHtml( '{"status":"ok"}' )

			else

				cX := iif(Valtype(HttpGet->x) == "C" .and. !empty(HttpGet->x),HttpGet->x,"wStart")
							
				If !Empty(cX)
					oINNWeb:cPagina := cX
                endif
				
                if !ExistBlock(cX)
					oINNWeb:cPagina := "w404"
					if lDebug
						oINNLog:SetStatus(404)
					endif
				EndIf

				if !oINNWeb:ValLogin(@cMsg)
					fFormLogin(@oINNWeb,@cMsg)
					if lDebug
						oINNLog:AddItemLog("fFormLogin")
					endif
				else

					oINNWeb:UsrSM0()

					if !(oINNWeb:VldSM0())

						HttpSession->WsEmp := oINNWeb:aUsrSM0[1][1]
						HttpSession->WsFil := oINNWeb:aUsrSM0[1][2]
						RPCSetEnv( HttpSession->WsEmp , HttpSession->WsFil )//FILIAL_CHUMBADA
						RPCSetEmpFil( HttpSession->WsEmp , HttpSession->WsFil )
						fGoEmp( HttpSession->WsEmp  , HttpSession->WsFil )

					endif

					cAtion := "U_"+oINNWeb:cPagina+"(@oINNWeb)"
					if lDebug
						oINNLog:AddItemLog(cAtion)
					endif
					Eval({|| &(cAtion) })

				endif

			endif

			//monta o html
			oINNWeb:ExecMonta()		
			cHtml := oINNWeb:cHTML

			if lDebug
				oINNLog:SetResponse(cHtml,200,.T.)
				FreeObj(oINNLog)
			endif

			if !lDebug
				SmartJob(   "U_INNWebCls" ,;//Indica o nome do Job que será executado.
							getenvserver(),;//Indica o nome do ambiente em que o Job será executado.
							.F.,;//Indica se, verdadeiro (.T.), o processo será finalizado; caso contrário, falso (.F.).
							{SM0->M0_CODIGO,SM0->M0_CODFIL},oINNWeb:aDirTemp) //MSSQL
			endif

			FreeObj(oINNWeb)

			RPCClearEnv()

			TcInternal( 1, " INN web Sessao: FREE" )
	
		CATCH EXCEPTION USING oError
		
			conout(oError:ERRORSTACK)
			
			cHTML := fErroUsi(@oError,lDebug)
			
		END TRY
		
	WEB EXTENDED END

	//FreeObj(oError)
	
Return(cHTML)

Static Function fErroUsi(oError,lDebug)

	Local cErrorHtml

	cErrorHtml := "<html>" + CRLF
	cErrorHtml += "<head>" + CRLF
	cErrorHtml += "<title>INN web</title>" + CRLF
	cErrorHtml += "<style>" + CRLF
	cErrorHtml += "  body {
	cErrorHtml += "    margin: 0px ;" + CRLF
	cErrorHtml += "  }" + CRLF
	cErrorHtml += "  .container {" + CRLF
	cErrorHtml += "    width: 100vw;" + CRLF
	cErrorHtml += "    height: 100vh;" + CRLF
	cErrorHtml += "    display: flex;" + CRLF
	cErrorHtml += "    flex-direction: row;" + CRLF
	cErrorHtml += "    justify-content: center;" + CRLF
	cErrorHtml += "    align-items: center;" + CRLF
	cErrorHtml += "    text-align: center;;" + CRLF
	cErrorHtml += "  }" + CRLF
	cErrorHtml += "  .box {" + CRLF
	cErrorHtml += "    width: 600px;" + CRLF
	cErrorHtml += "    height: 300px;;" + CRLF
	cErrorHtml += "  }" + CRLF
	cErrorHtml += "  .imgrobot {" + CRLF
	cErrorHtml += "    display: block;" + CRLF
	cErrorHtml += "    margin-left: auto;" + CRLF
	cErrorHtml += "    margin-right: auto;;" + CRLF
	cErrorHtml += "  }" + CRLF
	cErrorHtml += "  .card-body {" + CRLF
	cErrorHtml += "    text-align: left;" + CRLF
	cErrorHtml += "    background-color: black;" + CRLF
	cErrorHtml += "    color: white;" + CRLF
	cErrorHtml += "    padding: 5px; "+ CRLF
	cErrorHtml += "    white-space: break-spaces; "+ CRLF
	cErrorHtml += "  }" + CRLF
	cErrorHtml += "  </style>" + CRLF
	cErrorHtml += "</head>" + CRLF
	cErrorHtml += "<body>" + CRLF
	cErrorHtml += "<div class='container'><div class='box'>" + CRLF
	cErrorHtml += "<div class='imgrobot'><img src='imagens/broken-robot.png'></div>" + CRLF
	cErrorHtml += "<p>Ho não! Ocorreu um erro no processamento de sua pagina.<br>Tente novamente mais tarde, se o erro permanecer, entre em contato com a equipe Protheus.</p>" + CRLF
	if lDebug
		cErrorHtml += "<p><pre class='card card-body'>"+oError:ERRORSTACK+"</pre></p>" + CRLF
		oINNLog:SetStatus(400)
		oINNLog:AddItemLog("Erro",,,,oError:ERRORSTACK,"ERRO",.T.)
	endif
	cErrorHtml += "</div></div>" + CRLF
	cErrorHtml += "</body>" + CRLF
	cErrorHtml += "</html>" + CRLF
	
Return(cErrorHtml)

Static Function fFormLogin(oINNWeb,cMsg)

	Local cBody := ""
	Local cEnd := fGetEnd()
	
	oINNWeb:lSimpPG := .T.
	oINNWeb:SetTitle("INNOVIOS")

	//cMsg += "Voce será redirecionado para: "+cEnd

	cBody += "<main class='auth'>" + CRLF
	cBody += "  <header id='auth-header' class='auth-header' style='background-image: url(imagens/illustration/img-1.png);'>" + CRLF
	cBody += "	<h1><img src='imagens/logo-sigin.png' alt='INN web' style='-webkit-border-radius: 5px;-moz-border-radius: 5px;border-radius: 5px;'>" + CRLF
	cBody += "	</h1>" + CRLF
	//cBody += "	<p> Simplificando seu ERP</p>" + CRLF
	cBody += "  </header><!-- form -->" + CRLF
	cBody += "  <form class='auth-form' action='"+cEnd+"' method='post'>" + CRLF
	cBody += "	<!-- .form-group -->" + CRLF
	cBody += "	<div class='form-group'>" + CRLF
	cBody += "	  <div class='form-label-group'>" + CRLF
	cBody += "		<input type='text' id='inputusuario' name='inputusuario' class='form-control' placeholder='Username' autofocus=''> <label for='inputUser'>Usuario</label>" + CRLF
	cBody += "	  </div>" + CRLF
	cBody += "	</div><!-- /.form-group -->" + CRLF
	cBody += "	<!-- .form-group -->" + CRLF
	cBody += "	<div class='form-group'>" + CRLF
	cBody += "	  <div class='form-label-group'>" + CRLF
	cBody += "		<input type='password' id='inputPassword' name='inputPassword' class='form-control' placeholder='Password'> <label for='inputPassword'>Senha</label>" + CRLF
	cBody += "	  </div>" + CRLF
	cBody += "	</div><!-- /.form-group -->" + CRLF
	cBody += "	<!-- .form-group -->" + CRLF
	cBody += "	<div class='form-group'>" + CRLF
	cBody += "	  <button class='btn btn-lg btn-primary btn-block' type='submit'>Entrar</button>" + CRLF
	cBody += "	</div><!-- /.form-group -->" + CRLF
	cBody += "	<!-- .form-group -->" + CRLF
	cBody += "	<div class='form-group text-center'>" + CRLF
	cBody += cMsg
	cBody += "	</div><!-- /.form-group -->" + CRLF
	cBody += "	<!-- recovery links -->" + CRLF
	cBody += "  </form><!-- /.auth-form -->" + CRLF
	cBody += "  <!-- copyright -->" + CRLF
	cBody += "  <footer class='auth-footer'>INNOVIOS "+Year2Str(date())+"</footer>" + CRLF
	cBody += "</main><!-- /.auth -->" + CRLF

	aJSHead := {}
	aadd(aJSHead,"$(document).on('theme:init', () =>")
	aadd(aJSHead,"{")
	aadd(aJSHead,"particlesJS.load('auth-header', 'vendor/particles.js/particles.json');")
	aadd(aJSHead,"})")

	oINNWeb:addJSFoot(aJSHead)	
	oINNWeb:AddBody(cBody)

Return

Static Function	fLoga(cUsuario,cPass)

	HttpSession->UseName := cUsuario
	HttpSession->UseSenh := cPass
				
Return

Static Function MyOpenSM0()

	Local lOpen := .F.
	Local nLoop := 0
	Local cEmpIni := GetPvProfString("INNWEB", "EMPINI", "",GetAdv97() )

	If FindFunction( "OpenSM0" )
		For nLoop := 1 To 20
			OpenSM0()
			If Select("SM0") != 0 
				lOpen := .T.
				Exit
			EndIf
			Sleep( 500 )
		Next nLoop
	Else
		Final( "Não foi possível a abertura da tabela de empresas (OpenSM0).")
	EndIf
	
	If !lOpen
		Final( "Não foi possível a abertura da tabela de empresas (SM0).")
	EndIf
	
	SM0->(dbGoTop())
	if !Empty(cEmpIni)
		SM0->(dbSeek(cEmpIni))
	endif
	HttpSession->WsEmp := SM0->M0_CODIGO
	HttpSession->WsFil := SM0->M0_CODFIL

Return lOpen



Static Function fGetEnd()

	Local nY
	Local cHost := ""
	Local cGet := ""
	Local cPar := ""
	Local nPFim := ""
	Local xRet := ""
	Local cEnd := ""
	
	for nY := 1 To Len(httpHeadIn->aHeaders)

		cPar := "HOST:"
		nPFim := Len(cPar)
		xRet := httpHeadIn->aHeaders[nY]
		if substr(Alltrim(Upper(xRet)),1,nPFim) == cPar
			cHost := Alltrim(substr(xRet,nPFim+1))
		endif
					
		cPar := "GET /"
		nPFim := Len(cPar)
		xRet := httpHeadIn->aHeaders[nY]
		if substr(Alltrim(Upper(xRet)),1,nPFim) == cPar
			cGet := Alltrim(substr(xRet,nPFim+1))
			cGet := Alltrim(StrTran(cGet,"HTTP/1.0",""))
			cGet := Alltrim(StrTran(cGet,"HTTP/1.1",""))
		endif
		
	next nY
	
	if Empty(cGet) .or. upper("WSUsr") $ upper(cGet) .or. !(upper("u_windex.apw") $ upper(cGet))
		cEnd := "u_windex.apw"
	else
		cEnd := ""
	endif
	
Return(cEnd)

Static Function fGetFullEnd()

	Local nY
	Local cHost := ""
	Local cGet := ""
	Local cPar := ""
	Local nPFim := ""
	Local xRet := ""
	Local cEnd := ""
	
	for nY := 1 To Len(httpHeadIn->aHeaders)

		cPar := "HOST:"
		nPFim := Len(cPar)
		xRet := httpHeadIn->aHeaders[nY]
		if substr(Alltrim(Upper(xRet)),1,nPFim) == cPar
			cHost := Alltrim(substr(xRet,nPFim+1))
		endif
					
		cPar := "GET /"
		nPFim := Len(cPar)
		xRet := httpHeadIn->aHeaders[nY]
		if substr(Alltrim(Upper(xRet)),1,nPFim) == cPar
			cGet := Alltrim(substr(xRet,nPFim+1))
			cGet := Alltrim(StrTran(cGet,"HTTP/1.0",""))
			cGet := Alltrim(StrTran(cGet,"HTTP/1.1",""))
		endif
		
	next nY
	
	cEnd := cHost + cGet
	
Return(cEnd)
