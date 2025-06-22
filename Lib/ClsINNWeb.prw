#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS ClsINNWeb

	data xInicio
	data cVersao
	data cHTML
	data cHTMLSub
	data cHead
	data cMenu
	data cTopBar
	data aMenu
	data aTopBar
	data cFixBar
	data cFlxBar
	data cIdPgn
	data aBody
	data cFoot
	data cTitlePage
	data cTitNot
	data aBreadCrb
	data aIncl
	data aInclCust
	data aLoadHead
	data aThemeInit
	data aJSHead
	data aJSFoot
	data aJSVar
	data aLoad
	data cCSS
	data WsFil
	data WsEmp
	data nMax
	data cRedir
	data lAlert
	data lTxtEdit
	data lTxtSpls
	data lGrafico
	data nPgn
	data lLogado
	data UserName
	data UserID
	data aDirTemp
	data cUpLog
	data cCodGgle
	data aHeadBtn
	data lSimpPG
	data lSimpHTML
	data cFaIcons
	data cNomeApp
	data lExibProp
	data cMapsKey
	data lLicense
	data cPagina
	data cPgBase
	data nCallOut
	data cIDToast
	data cBodyToast
	data lImgPop
	data lDebug
	data cAccordion
	data cIdCard

	data aUsrSM0

		
	METHOD New() Constructor

	//Define as coisas basicas
	METHOD SetTitle() 
	METHOD SetTitNot()
	METHOD SetIdPgn()
	METHOD ValLogin()

	//Executa as coisas basicas
	METHOD ExecHead()
	METHOD ExecMenu()
	METHOD ExecBar()
	METHOD ExecFoot()
	METHOD ExecListaFil()
	METHOD ExecMonta()
	METHOD Criadb()
	
	//Metodos para itens/elementos html
	METHOD AddBody()
	METHOD AddPre()
	METHOD AddLoad()
	METHOD AddLoadHead()
	METHOD AddThemeInit()
	METHOD AddCallOut()
	METHOD AddToast()
	METHOD fIcon()
	METHOD LoadBitmap()
	METHOD addJSHead()
	METHOD addJSFoot()
	METHOD addCSS()
	METHOD addCard()
	METHOD addModal()
	METHOD AddHeadBtn()
	METHOD AddAlert()
	METHOD AddBreadCrb()
	METHOD TamFild()
	METHOD AddInclud()
	METHOD jsFoot()

	//Metodos para editar itens/elementos gerais html
	METHOD SetBody()
	METHOD SetHtml()
	METHOD SetRedir()	
	METHOD ValidVinc()

	//Pseudos metodos apenas para facilitar a vida
	METHOD SimpleX3Table()
	METHOD xModelo3()
	METHOD xCadastro()
	METHOD ImgProd()
	METHOD GetImgUrl()
	METHOD RepArqs()
	METHOD ExePod()

	METHOD UsrSM0()
	METHOD VldSM0()
	
ENDCLASS

METHOD New() Class ClsINNWeb
		
	::xInicio   := dTos(date())+" "+Time()
	::cVersao	:= "1.0.0" //03/06/2022
		
	::cNomeApp	:= "INN web"
	::cTitlePage:= "INNOVIOS"
	::cTitNot	:= ""
	::aBreadCrb	:= {} //1=>URL 2=>Texto 3=>Icone 4=>css
	::lExibProp := .T.
	
	::cHTML		:= ""
	::cHTMLSub  := ""
	::cHead		:= ""
	::cMenu		:= ""
	::cTopBar	:= ""
	::aBody		:= {}
	::cFoot		:= ""
	::cIdPgn	:= ""

	::aIncl		:= {}                                   
	::aInclCust	:= {}
	::aLoad		:= {}
	::aThemeInit:= {}
	::aLoadHead := {}
	::aJSHead	:= {}
	::aJSFoot	:= {}
	::aJSVar	:= {}
	::cCSS      := ""
	::aMenu		:= {}
	::aTopBar	:= {}
	::WsFil		:= ""
	::WsEmp		:= ""
	::nMax		:= 500
	::cRedir	:= ""
	::lAlert	:= .F.
	::cUpLog	:= ""
	::lTxtEdit	:= .F.
	::lTxtSpls  := .F.
	::lGrafico	:= .F.
	::lLogado	:= .F.
	::UserID	:= ""
	::UserName	:= ""
	::nPgn		:= Val(iif(Valtype(HttpGet->pgn) == "C" .and. !empty(HttpGet->pgn),HttpGet->pgn,"1"))
	::aDirTemp	:= {"","","","",""}
	::cCodGgle	:= ""
	::aHeadBtn  := {}
	::lSimpPG   := .F.
	::lSimpHTML := .F.
	::cFaIcons  := ""
	::cMapsKey  := ""
	::lLicense	:= .F.
	::cFixBar	:= ""
	::cFlxBar	:= ""
	::nCallOut	:= 0
	::cIDToast	:= "000"
	::cBodyToast:= ""
	::lImgPop	:= .F.
	::lDebug	:= .F.
	::cAccordion:= "00"
	::cIdCard   := "00"
		
	::cPagina	:= "wStart"
	::cPgBase	:= "u_windex.apw"

	::aUsrSM0	:= {}

	if Valtype(HttpSession->WsEmp) == "C"	
		::WsEmp := HttpSession->WsEmp
	endif
		
	if Valtype(HttpSession->WsFil) == "C"	
		::WsFil := HttpSession->WsFil
	endif

	Self:Criadb()

	IF ExistBlock("INNCONFIG")
		Self:ValLogin("")
		aParam := { ::aDirTemp , ::UserID , ::cCodGgle }
		aParam := ExecBlock("INNCONFIG",.F.,.F.,aParam)
		if Len(aParam) == 2
			::aDirTemp 		:= aParam[1]//aDirTemp
			::cCodGgle		:= aParam[2]//cCodGgle
			
			if ::lLogado .and. UGrpIn(::UserID,"000000") .and. ( !ExistDir(::aDirTemp[3]) .or. !ExistDir(::aDirTemp[4]) )
				self:AddAlert(	"<a href='?x=wINNConfig'>Clique aqui</a> para revisar a configuração.",;
								"warning",;
								"A configuração de diretorios parace errada!")
			endif
			
		else
			self:AddCallOut("Retorno INNConfig invalido!","danger")
		endif
	else
		self:AddCallOut("INNConfig não compilado!","danger")
	ENDIF

	if Empty(GetMV("IN_TOKEN"))
		self:AddAlert(	"",;
						"warning",;
						"Parametro IN_TOKEN não encontrado")
	endif

Return Self

METHOD AddHeadBtn(xRec) Class ClsINNWeb

	Local cUrl := ""

	cUrl := Self:cPgBase+"?x="+xRec[1] 
	
	if !Empty(xRec[2])
		cUrl += "&amp;"+xRec[2]
	endif
	
	aadd(Self:aHeadBtn,{cUrl,xRec[3]})

Return

METHOD ValLogin(cMsg) Class ClsINNWeb

	Local cUseName  := iif(ValType(HttpSession->UseName)!="C","",HttpSession->UseName)
	Local cUseSenh  := iif(ValType(HttpSession->UseSenh)!="C","",HttpSession->UseSenh)
	Local aDados	:= {}
	
	if Empty(HttpSession->UsrToken)//Não estamos com token ativo

		if at("\",cUseName) > 0

			cUseName := StrTokArr(cUseName,"\")
			cUseName[1] := Alltrim(cUseName[1])
			cUseName[2] := Alltrim(cUseName[2])

			if ADUserValid( cUseName[1] , cUseName[2] , cUseSenh )
				if PswSeek(Alltrim(cUseName[2]),.T.) 
					aDados     := PSWRET()
					if aDados[01][17]
						::lLogado  := .F.
						cMsg       := "Usuario bloqueado!"
					else
						::UserID   := aDados[01][01]
						::UserName := aDados[01][04]
						::lLogado  := .T.
					endif
				else
					::lLogado  := .F.
					cMsg       := "Usuario invalido"
				endif
			else
				::lLogado  := .F.
				cMsg       := "Autenticação pelo AD falhou"
			endif

		else

			PswOrder(2)
					
			if !Empty(cUseName) .and. !Empty(cUseSenh)
		
				if PswSeek(Alltrim(cUseName),.T.) .and. PswName(Alltrim(cUseSenh))
					aDados     := PSWRET()
					if aDados[01][17]
						::lLogado  := .F.
						cMsg       := "Usuario bloqueado!"
					else
						::UserID   := aDados[01][01]
						::UserName := aDados[01][04]
						::lLogado  := .T.
					endif
				else
					::lLogado  := .F.
					cMsg       := "Usuario ou senha invalidos"
				endif
			else
				::lLogado  := .F.
			endif

		endif
		
	else

		if left(HttpSession->UsrToken,32) == Alltrim(GetMV("IN_TOKEN"))
			::UserID   := Right(HttpSession->UsrToken,6)
			::UserName := UsrRetName(::UserID)
			::lLogado  := .T.			
		else
			HttpSession->UsrToken := ""
			::lLogado := .F.
		endif
	
	endif

	if !::lLogado	
		HttpSession->UseName := ""
		HttpSession->UseSenh := ""
		::UserID   := ""
		::UserName := ""
	endif

Return(::lLogado)

// --------------------------------------------------------------------------
METHOD AddBody(xBody) Class ClsINNWeb
	aadd(::aBody,xBody)
Return

// --------------------------------------------------------------------------
METHOD AddPre(cPre) Class ClsINNWeb
	aadd(::aBody,"<pre class='card card-body'>" + cPre + "</pre>")
Return

// --------------------------------------------------------------------------
METHOD AddAlert(cAlert,cTipo,cTitulo,cIcone) Class ClsINNWeb

	Local cBody		:= ""
	Local cClass 	:= ""

	Default cTipo 	:= ""
	Default cTitulo := ""
	Default cIcone 	:= ""
	Default cAlert 	:= ""
	

	Do Case
		Case cTipo == "danger"
			cClass := "alert-danger
			cIcone := "fas fa-exclamation-triangle"

		Case cTipo == "success"
			cClass := "alert-success"
			cIcone := "oi oi-check"

		Case cTipo == "info"
			cClass := "alert-info"
			cIcone := "oi oi-info"

		OtherWise
			cClass := "alert-secondary"
			cIcone := "oi oi-flag"
	End

	cBody += "<div class='alert "+cClass+iif(!Empty(cIcone)," has-icon ","")+" alert-dismissible fade show'>" + CRLF
	cBody += "<button type='button' class='close' data-dismiss='alert'>&times;</button>" + CRLF
	if !Empty(cIcone)
		cBody += "<div class='alert-icon'><span class='"+cIcone+"'></span></div>" + CRLF
	endif
	if !Empty(cTitulo)
		cBody += "<h4 class='alert-heading'> "+cTitulo+" </h4>" + CRLF
	endif
	cBody += "<p class='mb-0'> " + cAlert + "</p>" + CRLF
	cBody += "</div>" + CRLF

	Self:AddBody(cBody)

Return

METHOD AddBreadCrb(aBreadCrb) Class ClsINNWeb

	aadd(::aBreadCrb,aClone(aBreadCrb))

Return

// --------------------------------------------------------------------------
METHOD addCard(cRetBody,cTitulo,cRetFoot,lAccordion,lIncorpora,cBodyId) Class ClsINNWeb

	Local cBody := ""

	Default cTitulo 	:= ""
	Default cRetFoot 	:= ""
	Default lAccordion 	:= .F.
	Default lIncorpora 	:= .T.
	Default cBodyId		:= ""

	if Empty(cBodyId)
		::cIdCard := Soma1(::cIdCard)
		cBodyId := "Card"+::cIdCard
	endif

	if lAccordion

		::cAccordion := Soma1(::cAccordion)

		cBody += "<div id='accordionParam' class='card-expansion'>"
		cBody += "  <div class='card card-fluid card-expansion-item expanded' style='overflow-y: hidden;overflow-x: auto;'>"
		cBody += "    <div class='card-header border-0' id='headingOne2'>"
		cBody += "      <button class='btn btn-reset d-flex justify-content-between w-100' data-toggle='collapse' data-target='#collapseOne"+::cAccordion+"' aria-expanded='true' aria-controls='collapseOne"+::cAccordion+"'><span>" + cTitulo + "</span> <span class='collapse-indicator'><i class='fa fa-fw fa-chevron-down'></i></span></button>"
		cBody += "    </div>"
		cBody += "    <div id='collapseOne"+::cAccordion+"' class='collapse show' aria-labelledby='headingOne2' data-parent='#accordionParam'>"

		cBody += "      <div class='card-body' id='"+cBodyId+"'>" + CRLF
		cBody +=          cRetBody + CRLF	
		cBody += "      </div><!-- /card-body -->" + CRLF

		if !Empty(cRetFoot)
		cBody += "      <div class='card-footer'>" + CRLF
		cBody += "        <div style='padding: 5px;font-size: small;' class='ml-auto'>"+cRetFoot+"</div>" + CRLF
		cBody += "      </div>" + CRLF
		endif

		cBody += "    </div><!-- /collapseOne2 -->" + CRLF
		cBody += "  </div><!-- /card card-fluid -->" + CRLF
		cBody += "</div><!-- /accordionParam-->" + CRLF

	else
		cBody += "<div class='card card-fluid' style='overflow-y: hidden;overflow-x: auto;'>" + CRLF
		cBody += "<div class='card-body'>" + CRLF
		if !Empty(cTitulo)
			cBody += "<h3 class='card-title'>"+cTitulo+"</h3>" + CRLF
		endif
		cBody += "<div id='"+cBodyId+"'>" + CRLF
		cBody += cRetBody + CRLF	
		cBody += "</div>" + CRLF
		cBody += "  </div><!-- /card-body -->" + CRLF

		if !Empty(cRetFoot)
			cBody += "<div class='card-footer'>" + CRLF
			cBody += "  <div style='padding: 5px;font-size: small;' class='ml-auto'>"+cRetFoot+"</div>" + CRLF
			cBody += "</div>" + CRLF
		endif

		cBody += "</div><!-- /card card-fluid -->" + CRLF
	endif

	if lIncorpora
		Self:AddBody(cBody)
	endif

Return(cBody)

// --------------------------------------------------------------------------
METHOD addModal(cTipo,cID,cTitulo,cRetBody,cFoot) Class ClsINNWeb

	Local cBody		:= ""
	Local cTipoModal := ""
	Default cTipo	:= ""
	Default cTitulo	:= ""
	Default cFoot	:= ""

	cTipo := lower(Alltrim(cTipo))
	do Case 
		Case cTipo == "lg"
			cTipoModal := "modal-dialog modal-lg"
		Case cTipo == "centered"
			cTipoModal := "modal-dialog modal-dialog-centered"
		Case cTipo == "scrollable"
			cTipoModal := "modal-dialog modal-dialog-scrollable"
		otherwise
			cTipoModal := "modal-dialog"
	EndCase 

	cBody += "<div class='modal fade' id='"+cID+"' tabindex='-1' role='dialog' aria-labelledby='"+cID+"' aria-hidden='true'>" + CRLF
	cBody += "  <div class='"+cTipoModal+"' role='document'>" + CRLF
	cBody += "    <div class='modal-content'>" + CRLF
	if !Empty(cTitulo)
		cBody += "      <div class='modal-header'>" + CRLF
		cBody += "        <h5 class='modal-title'> "+cTitulo+" </h5>" + CRLF
		cBody += "      </div><!-- /.modal-header -->" + CRLF
	endif
	cBody += "      <div class='modal-body'>"+cRetBody+"</div><!-- /.modal-body -->" + CRLF
	if !Empty(cFoot)
		cBody += "      <div class='modal-footer'>"+cFoot+"</div><!-- /.modal-footer -->" + CRLF
	endif
	cBody += "    </div><!-- /.modal-content -->" + CRLF
	cBody += "  </div><!-- /.modal-dialog -->" + CRLF
	cBody += "</div><!-- /.modal -->" + CRLF

	Self:AddBody(cBody)

Return

// --------------------------------------------------------------------------
METHOD SetRedir(cRedir) Class ClsINNWeb
	::cRedir := cRedir	
Return

// --------------------------------------------------------------------------
METHOD AddLoad(aRetLoad) Class ClsINNWeb
	Local nY
	for nY := 1 To Len(aRetLoad)
		aadd(::aLoad,aRetLoad[nY])
	next
Return

METHOD AddLoadHead(aRetHead) Class ClsINNWeb
	Local nY
	for nY := 1 To Len(aRetHead)
		aadd(::aLoadHead,aRetHead[nY])
	next
Return

// --------------------------------------------------------------------------
METHOD AddThemeInit(aRetThemeInit) Class ClsINNWeb
	Local nY
	for nY := 1 To Len(aRetThemeInit)
		aadd(::aThemeInit,aRetThemeInit[nY])
	next
Return

// --------------------------------------------------------------------------
METHOD addJSHead(aRetJSHead) Class ClsINNWeb
	Local nY
	for nY := 1 To Len(aRetJSHead)
		aadd(::aJSHead,aRetJSHead[nY])
	next
Return

// --------------------------------------------------------------------------
METHOD addJSFoot(aRetJSFoot) Class ClsINNWeb
	Local nY
	for nY := 1 To Len(aRetJSFoot)
		aadd(::aJSFoot,aRetJSFoot[nY])
	next
Return


METHOD addCSS(xCSS) Class ClsINNWeb
	::cCSS += xCSS
Return

METHOD AddInclud( xIncl ) Class ClsINNWeb

	aadd(::aInclCust,aClone(xIncl))

Return( Len(::aInclCust) )

// --------------------------------------------------------------------------
METHOD AddCallOut(cMsg,cTipo) Class ClsINNWeb

	Local cBody := ""
	Default cTipo := ""

	cTipo := lower(Alltrim(cTipo))

	Do Case
		Case cTipo == "info"
			cBody := "<div class='page-message' role='alert' style='background-color: #5bc0de;color: #fff;margin-top: "+cValToChar(::nCallOut*50)+"px'>" + CRLF
			cBody += "<i class='fas fa-info-circle'></i>&nbsp;&nbsp;"
			cBody += cMsg
			cBody += "<a href='#' class='btn btn-sm btn-icon btn-warning ml-1' aria-label='Close' onclick='$(this).parent().fadeOut()'><span aria-hidden='true'><i class='fa fa-times'></i></span></a>" + CRLF
			cBody += "</div>" + CRLF
		Case cTipo == "success"
			cBody := "<div class='page-message' role='alert' style='background-color: #5cb85c;color: #fff;margin-top: "+cValToChar(::nCallOut*50)+"px'>" + CRLF
			cBody += "<i class='fas fa-check-circle '></i>&nbsp;&nbsp;"
			cBody += cMsg
			cBody += "<a href='#' class='btn btn-sm btn-icon btn-warning ml-1' aria-label='Close' onclick='$(this).parent().fadeOut()'><span aria-hidden='true'><i class='fa fa-times'></i></span></a>" + CRLF
			cBody += "</div>" + CRLF		
		Case cTipo == "warning"
			cBody := "<div class='page-message' role='alert' style='background-color: #f0ad4e;color: #fff;margin-top: "+cValToChar(::nCallOut*50)+"px'>" + CRLF
			cBody += "<i class='fas fa-exclamation-circle'></i>&nbsp;&nbsp;"
			cBody += cMsg
			cBody += "<a href='#' class='btn btn-sm btn-icon btn-warning ml-1' aria-label='Close' onclick='$(this).parent().fadeOut()'><span aria-hidden='true'><i class='fa fa-times'></i></span></a>" + CRLF
			cBody += "</div>" + CRLF
		Case cTipo == "danger"
			cBody := "<div class='page-message' role='alert' style='background-color: #c9302c;color: #fff;margin-top: "+cValToChar(::nCallOut*50)+"px'>" + CRLF
			cBody += "<i class='fas fa-times-circle'></i>&nbsp;&nbsp;"
			cBody += cMsg
			cBody += "<a href='#' class='btn btn-sm btn-icon btn-warning ml-1' aria-label='Close' onclick='$(this).parent().fadeOut()'><span aria-hidden='true'><i class='fa fa-times'></i></span></a>" + CRLF
			cBody += "</div>" + CRLF
		OtherWise
			cBody := "<div class='page-message' role='alert' style='color: #fff;margin-top: "+cValToChar(::nCallOut*50)+"px'>" + CRLF
			cBody += "<i class='fas fa-info-circle'></i> &nbsp;&nbsp;"
			cBody += cMsg
			cBody += "<a href='#' class='btn btn-sm btn-icon btn-warning ml-1' aria-label='Close' onclick='$(this).parent().fadeOut()'><span aria-hidden='true'><i class='fa fa-times'></i></span></a>" + CRLF
			cBody += "</div>" + CRLF									
	End Case
			
	Self:addbody(cBody)
	::nCallOut += 1
	
Return

// --------------------------------------------------------------------------
METHOD AddToast(cTitulo,cMsg) Class ClsINNWeb

	Default cTitulo := ""
	
	::cIDToast := Soma1(::cIDToast)
	
	::cBodyToast += "    <div id='toast"+::cIDToast+"' class='toast fade hide' role='alert' aria-live='assertive' aria-atomic='true' data-delay='5000'>" + CRLF
	::cBodyToast += "      <div class='toast-header'>" + CRLF
	//::cBodyToast += "        <img class='rounded mr-2' src='assets/images/avatars/bootstrap.svg' alt='' width='20'>" + CRLF
	::cBodyToast += "		  <strong class='mr-auto'>"+cTitulo+"</strong>" + CRLF
	//::cBodyToast += "		  <small>11 mins ago</small>" + CRLF
	::cBodyToast += "      </div>" + CRLF
	::cBodyToast += "      <div class='toast-body'>" + CRLF
	::cBodyToast += "        <p> "+cMsg+" </p>" + CRLF
	::cBodyToast += "      </div>" + CRLF
	::cBodyToast += "    </div><!-- /.toast -->" + CRLF
			
	Self:AddLoadHead({"$('#toast"+::cIDToast+"').toast('show')"})
	
Return

// --------------------------------------------------------------------------
METHOD SetTitle(xTitulo) Class ClsINNWeb
	::cTitlePage := xTitulo	
Return

// --------------------------------------------------------------------------
METHOD SetTitNot(cTitNot) Class ClsINNWeb
	::cTitNot := cTitNot	
Return

// --------------------------------------------------------------------------
METHOD SetIdPgn(cId) Class ClsINNWeb
	::cIdPgn := cId	
Return

// --------------------------------------------------------------------------
METHOD SetBody(cBody) Class ClsINNWeb
	::aBody := {}
	aadd(::aBody,cBody)
Return

// --------------------------------------------------------------------------
METHOD ExecHead() Class ClsINNWeb

	Local i := 0
	Local nY
	Local cdivLoad := '<div class="d-flex justify-content-center"><div class="spinner-border" role="status"><span class="sr-only">Loading...</span></div></div>'
	Local aJSFoot := {}

	::cHead += "<!DOCTYPE html>" + CRLF
	::cHead += "<html lang='pt-BR'>" + CRLF
	::cHead += "<head>" + CRLF

    //Required meta tags
    //::cHead += "<meta charset='utf-8'>" + CRLF
    ::cHead += "  <meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>" + CRLF

	::cHead += "  <meta name='robots' content='noindex,nofollow'>" + CRLF
	::cHead += "  <meta name='roots' content='noarchive'>" + CRLF	
	::cHead += "  <meta http-equiv='content-language' content='pt-br'>" + CRLF
	::cHead += "  <meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1' />" + CRLF

	//TITULO
	::cHead += "  <title>"+::cTitlePage+" - "+::cNomeApp+"</title>" + CRLF

	//Begin SEO tag

	cSEOTagDesc := "INN web é uma ferramenta open source de Business Intelligence (BI) para consulta de dados do ERP Protheus da Totvs."
	cSEOTagUrl  := "https://innovios.com.br/site/"
	//cSEOTagimg  := "https://innovios.com.br/site/img/icone.png"
	cSEOTagimg  := "https://innovios.com.br/site/img/og_image.png"
	cSEOTagSP  := "https://innovios.com.br/suporte/"
	cSEOTagTitle := ::cTitlePage+" - "+::cNomeApp
	cSEOTagtype := "SoftwareApplication"
	cSEOTagCategory := "BusinessApplication"
	cSEOTagCreator := "INNOVIOS"

    ::cHead += "<meta property='og:locale' content='pt_BR'>" + CRLF

    ::cHead += "<meta name='author' content='"+cSEOTagCreator+"'>" + CRLF
	::cHead += "<meta name='description' content='"+cSEOTagDesc+"'>" + CRLF
    ::cHead += "<link rel='canonical' href='"+cSEOTagUrl+"'>" + CRLF
    ::cHead += "<meta property='og:description' content='"+cSEOTagDesc+"'>" + CRLF
    ::cHead += "<meta property='og:url' content='"+cSEOTagUrl+"'>" + CRLF
	::cHead += "<meta property='og:type' content='"+cSEOTagtype+"'>" + CRLF
    ::cHead += "<meta property='og:title' content='"+cSEOTagTitle+"'>" + CRLF
	::cHead += "<meta property='og:image' content='"+cSEOTagimg+"'>" + CRLF
	::cHead += "<meta property='og:site_name' content='"+::cNomeApp+"'>" + CRLF

	::cHead += "<script type='application/ld+json'>" + CRLF
	::cHead += "{" + CRLF
	::cHead += "  '@context': 'http://schema.org'," + CRLF
	::cHead += "  '@type': '"+cSEOTagtype+"'," + CRLF
	::cHead += "  'name': '"+::cNomeApp+"'," + CRLF
	::cHead += "  'description': '"+cSEOTagDesc+"'," + CRLF
	::cHead += "  'url': '"+cSEOTagUrl+"'," + CRLF
	::cHead += "  'image': '"+cSEOTagimg+"'," + CRLF
	::cHead += "  'applicationCategory': '"+cSEOTagCategory+"'," + CRLF
	::cHead += "  'operatingSystem': 'Web'," + CRLF
	::cHead += "  'softwareVersion': '1.0.1'," + CRLF
	::cHead += "  'datePublished': '2010-09-28'," + CRLF
	::cHead += "  'license': 'https://www.gnu.org/licenses/old-licenses/gpl-2.0.html'," + CRLF
	::cHead += "  'creator': {" + CRLF
	::cHead += "    '@type': 'Organization'," + CRLF
	::cHead += "    'name': '"+cSEOTagCreator+"'," + CRLF
	::cHead += "    'url': '"+cSEOTagUrl+"' " + CRLF
	::cHead += "  }," + CRLF
	::cHead += "  'support': {" + CRLF
	::cHead += "    '@type': 'ContactPoint'," + CRLF
	::cHead += "    'contactType': 'customer support'," + CRLF
	::cHead += "    'url': '"+cSEOTagSP+"' " + CRLF
	::cHead += "  }," + CRLF
	::cHead += "  'offers': {" + CRLF
	::cHead += "    '@type': 'Offer'," + CRLF
	::cHead += "    'price': '0'," + CRLF
	::cHead += "    'priceCurrency': 'BRL'" + CRLF
	::cHead += "  }" + CRLF
	::cHead += "}" + CRLF
	::cHead += "</script>" + CRLF
	

    /*::cHead += "<script type='application/ld+json'>" + CRLF
    ::cHead += "  {" + CRLF
    ::cHead += "    'name': 'INN web'," + CRLF
    ::cHead += "    'description': 'INN web'," + CRLF
    ::cHead += "    'author':" + CRLF
    ::cHead += "    {" + CRLF
    ::cHead += "      '@type': 'Person'," + CRLF
    ::cHead += "      'name': 'INN web'" + CRLF
    ::cHead += "    }," + CRLF
    ::cHead += "    '@type': 'WebSite'," + CRLF
    ::cHead += "    'url': ''," + CRLF
    ::cHead += "    'headline': 'Dashboard'," + CRLF
    ::cHead += "    '@context': 'http://schema.org'" + CRLF
    ::cHead += "  }" + CRLF
    ::cHead += "</script>" + CRLF*/
	
    //FAVICONS
    //::cHead += "<link rel='apple-touch-icon' sizes='144x144' href='apple-touch-icon.png'>" + CRLF
    ::cHead += "<link rel='shortcut icon' href='favicon.ico'>" + CRLF
    ::cHead += "<meta name='theme-color' content='#3063A0'>" + CRLF

	aadd(::aIncl,{'GOOGLE FONT',{}})
	i := Len(::aIncl)
	aadd(::aIncl[i][2],{"css","<link href='https://fonts.googleapis.com/css?family=Fira+Sans:400,500,600' rel='stylesheet'>"})

	aadd(::aIncl,{'BASE',{}})
	i := Len(::aIncl)

	//Tema base
	aadd(::aIncl[i][2],{"foot","<script src='vendor/jquery/jquery.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/popper.js/umd/popper.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/bootstrap/js/bootstrap.min.js'></script>"})
	aadd(::aIncl[i][2],{"css","<link href='vendor/bootstrap/css/bootstrap.min.css' rel='stylesheet'>"})

	aadd(::aIncl[i][2],{"css","<link href='stylesheets/theme.css' rel='stylesheet' data-skin='default'>"})
	aadd(::aIncl[i][2],{"css","<link href='stylesheets/theme-dark.css' rel='stylesheet' data-skin='dark'>"})
	//aadd(::aIncl[i][2],{"css","<link href='stylesheets/custom.css' rel='stylesheet'>"})
	aadd(::aIncl[i][2],{"foot","<script src='javascript/theme.min.js'></script>"})



	aadd(::aIncl[i][2],{"foot","<script src='vendor/stacked-menu/js/stacked-menu.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/perfect-scrollbar/perfect-scrollbar.min.js'></script>"})
	//aadd(::aIncl[i][2],{"foot","<script src='vendor/easy-pie-chart/jquery.easypiechart.min.js'></script>"})
	//aadd(::aIncl[i][2],{"foot","<script src='vendor/chart.js/Chart.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/particles.js/particles.js'></script>"})


	//THEME STYLES JS
	aadd(::aJSHead,"var skin = localStorage.getItem('skin') || 'default';")
	aadd(::aJSHead,"var isCompact = JSON.parse(localStorage.getItem('hasCompactMenu'));")
	aadd(::aJSHead,"var disabledSkinStylesheet = document.querySelector('link[data-skin]:not([data-skin="+chr(34)+"' + skin + '"+chr(34)+"])');")
	aadd(::aJSHead,"disabledSkinStylesheet.setAttribute('rel', '');")// Disable unused skin immediately
	aadd(::aJSHead,"disabledSkinStylesheet.setAttribute('disabled', true);")
	aadd(::aJSHead,"if (isCompact == true) document.querySelector('html').classList.add('preparing-compact-menu');")// add flag class to html immediately

	aadd(::aIncl,{'PLUGINS',{}})
	i := Len(::aIncl)

	//flatpickr
	aadd(::aIncl[i][2],{"foot","<script src='vendor/flatpickr/flatpickr.min.js'></script>"})
	aadd(::aIncl[i][2],{"css","<link href='vendor/flatpickr/flatpickr.min.css' rel='stylesheet'>"})

	//Icones
	aadd(::aIncl[i][2],{"css","<link href='vendor/open-iconic/font/css/open-iconic-bootstrap.min.css' rel='stylesheet'>"})
	aadd(::aIncl[i][2],{"css","<link href='vendor/@fortawesome/fontawesome-free/css/all.min.css' rel='stylesheet'>"})

	//jstree
	aadd(::aIncl[i][2],{"css","<link href='vendor/jstree/themes/default/style.min.css' rel='stylesheet'>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/jstree/jstree.min.js'></script>"})

	if !::lSimpPG
		//Barra de progresso
		aadd(::aIncl[i][2],{"foot","<script src='vendor/pace-progress/pace.min.js'></script>"})
	endif

	//select2
	aadd(::aIncl[i][2],{"css","<link href='vendor/select2/css/select2.min.css'>"})
	aadd(::aIncl[i][2],{"css","<link href='vendor/select2/css/select2-bootstrap.min.css'>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/select2/js/select2.min.js'></script>"})

	//HoldOn-js
	//aadd(::aIncl[i][2],{"css","<link href='vendor/HoldOn-js/css/HoldOn.min.css'>"})
	//aadd(::aIncl[i][2],{"foot","<script src='vendor/HoldOn-js/js/HoldOn.min.js'></script>"})

	//redirect
	aadd(::aIncl[i][2],{"foot","<script src='vendor/redirect/jquery.redirect.js'></script>"})

	//datatables
	aadd(::aIncl[i][2],{"css","<link href='vendor/datatables.net-4/datatables.min.css'>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/datatables.net-4/datatables.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/datatables.net-4/JSZip-2.5.0/jszip.min.js'></script>"})

	//toastr
	aadd(::aIncl[i][2],{"css","<link href='vendor/toastr/build/toastr.min.css'>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/toastr/build/toastr.min.js'></script>"})

	//Mascaras
	aadd(::aIncl[i][2],{"foot","<script src='vendor/datepicker/js/bootstrap-datepicker.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/datepicker/locales/bootstrap-datepicker.pt-BR.min.js'></script>"})
	aadd(::aIncl[i][2],{"css","<link href='vendor/datepicker/css/bootstrap-datepicker.standalone.css' rel='stylesheet'>"})
	//aadd(::aLoadHead,"$.datepicker.setDefaults($.datepicker.regional['pt-BR']);")
	aadd(::aIncl[i][2],{"foot","<script src='vendor/mask/jquery.mask.min.js'></script>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/mask/jquery.maskMoney.min.js'></script>"})

	//touchspin
	aadd(::aIncl[i][2],{"css","<link href='vendor/touchspin/jquery.bootstrap-touchspin.css' rel='stylesheet'>"})
	aadd(::aIncl[i][2],{"foot","<script src='vendor/touchspin/jquery.bootstrap-touchspin.js'></script>"})

	if ::lTxtEdit .or. ::lTxtSpls
	
		aadd(::aIncl,{'TinyMCE',{}})
		i := Len(::aIncl)
		aadd(::aIncl[i][2],{"js","<script src='vendor/tinymce/tinymce.min.js' type='text/javascript'></script>"})	
		aadd(::aIncl[i][2],{"js","<script src='vendor/tinymce/langs/pt_BR.js' type='text/javascript'></script>"})	

	endif

	if ::lTxtEdit
		
		aadd(::aLoadHead,"tinymce.init({")
		aadd(::aLoadHead,"    selector: 'textarea',")
		aadd(::aLoadHead,"    license_key: 'gpl',")
		aadd(::aLoadHead,"	  language : 'pt_BR',")
		aadd(::aLoadHead,"	  menubar: false,")
		aadd(::aLoadHead,"	  statusbar: false,")
		//aadd(::aLoadHead,"	  paste_data_imagens : true,")				
		//aadd(::aLoadHead,"    plugins: ['autolink directionality visualblocks visualchars image link media table hr toc advlist lists textcolor wordcount imagetools contextmenu colorpicker textpattern paste'],")
		aadd(::aLoadHead,"    plugins: ['code','link','lists','table','image','directionality','autolink','advlist'],")
		aadd(::aLoadHead,"    toolbar: 'formatselect | bold italic strikethrough forecolor backcolor | link | alignleft aligncenter alignright alignjustify | numlist bullist outdent indent | removeformat | code'")
		aadd(::aLoadHead,"});")
		
	endif

	if ::lTxtSpls
		
		aadd(::aLoadHead,"tinymce.init({")
		aadd(::aLoadHead,"    selector: 'textarea',")
		aadd(::aLoadHead,"    license_key: 'gpl',")
		aadd(::aLoadHead,"	  language : 'pt_BR',")
		aadd(::aLoadHead,"	  menubar: false,")
		aadd(::aLoadHead,"	  statusbar: false,")
		aadd(::aLoadHead,"    toolbar: 'bold italic underline strikethrough | undo redo'")
		aadd(::aLoadHead,"});")
		
	endif
	

	if ::lGrafico

		aadd(::aIncl,{'highcharts',{}})
		i := Len(::aIncl)

		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/highcharts.js' type='text/javascript'></script>"})	
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/highcharts-3d.js' type='text/javascript'></script>"})	
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/highcharts-more.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/series-label.js' type='text/javascript'></script>"})	
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/exporting.js' type='text/javascript'></script>"})	
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/export-data.js' type='text/javascript'></script>"})
		
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/sankey.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/organization.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/funnel.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/pareto.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/timeline.js' type='text/javascript'></script>"})
		aadd(::aIncl[i][2],{"js","<script src='vendor/Highcharts-7.2.1/modules/heatmap.js' type='text/javascript'></script>"})

		aadd(::aLoadHead,"Highcharts.setOptions({ ")
		aadd(::aLoadHead,"    lang: { ")
		aadd(::aLoadHead,"        months: ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'], ")
		aadd(::aLoadHead,"        shortMonths: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'], ")
		aadd(::aLoadHead,"        weekdays: ['Domingo', 'Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado'], ")
		aadd(::aLoadHead,"        loading: ['Atualizando o gráfico...aguarde'], ")
		aadd(::aLoadHead,"        contextButtonTitle: 'Exportar gráfico', ")
		aadd(::aLoadHead,"        decimalPoint: ',', ")
		aadd(::aLoadHead,"        thousandsSep: '.', ")
		aadd(::aLoadHead,"        downloadJPEG: 'Baixar imagem JPEG', ")
		aadd(::aLoadHead,"        downloadPDF: 'Baixar arquivo PDF', ")
		aadd(::aLoadHead,"        downloadPNG: 'Baixar imagem PNG', ")
		aadd(::aLoadHead,"        downloadSVG: 'Baixar vetor SVG', ")
		aadd(::aLoadHead,"        printChart: 'Imprimir gráfico', ")
		aadd(::aLoadHead,"        rangeSelectorFrom: 'De', ")
		aadd(::aLoadHead,"        rangeSelectorTo: 'Para', ")
		aadd(::aLoadHead,"        rangeSelectorZoom: 'Zoom', ")
		aadd(::aLoadHead,"        resetZoom: 'Limpar Zoom', ")
		aadd(::aLoadHead,"        resetZoomTitle: 'Voltar Zoom para nível 1:1', ")
		aadd(::aLoadHead,"    } ")
		aadd(::aLoadHead,"}); ")

	endif

	if ::lImgPop

		aadd(::aIncl,{'Magnific-Popup',{}})
		i := Len(::aIncl)

		aadd(::aIncl[i][2],{"foot","<script src='vendor/Magnific-Popup-master/jquery.magnific-popup.min.js'></script>"})
		aadd(::aIncl[i][2],{"css","<link href='vendor/Magnific-Popup-master/magnific-popup.css' rel='stylesheet'>"})

		aadd(::aJSFoot,"function renderImgProd(){")
		aadd(::aJSFoot,"  $('#ImgProd*').magnificPopup({ ")
		aadd(::aJSFoot,"    type: 'image', ")
		aadd(::aJSFoot,"    closeOnContentClick: true, ")
		aadd(::aJSFoot,"    mainClass: 'mfp-img-mobile mfp-no-margins mfp-with-zoom', ")
		aadd(::aJSFoot,"    image: { verticalFit: true }, ")
		aadd(::aJSFoot,"    zoom: { ")
		aadd(::aJSFoot,"      enabled: true, ")
		aadd(::aJSFoot,"      duration: 300 ")
		aadd(::aJSFoot,"    } ")
		aadd(::aJSFoot,"  }); ")
		aadd(::aJSFoot,"} ")
	endif

	if ::lDebug
		aadd(::aIncl,{'DEBUG',{}})
		i := Len(::aIncl)
		aadd(::aIncl[i][2],{"css","<link rel='stylesheet' href='https://cdnjs.cloudflare.com/ajax/libs/github-fork-ribbon-css/0.2.3/gh-fork-ribbon.min.css' />"})
	endif

	aadd(::aIncl,{'CUSTOM',{}})
	i := Len(::aIncl)
	for nY := 1 To Len(::aInclCust)
		aadd(::aIncl[i][2],aClone(::aInclCust[nY]))
	next

	//Função para mudar a filial
	aJSFoot := {}
	aadd(aJSFoot,"function MudaFilial(cEmp,cFil) {")
	aadd(aJSFoot,"	$('.page-inner').html('"+cdivLoad+"');")
	aadd(aJSFoot,"	$.ajax({")
	aadd(aJSFoot,"		url: '?WsEmp='+cEmp+'&WsFil='+cFil,")
	aadd(aJSFoot,"		type: 'POST',")
	aadd(aJSFoot,"		datatype: 'json',")
	aadd(aJSFoot,"		processData: false,")
  	aadd(aJSFoot,"		contentType: false,")
	aadd(aJSFoot,"		success: function(data){")
	aadd(aJSFoot,"			data = JSON.parse(data);")	
	aadd(aJSFoot,"			if (data['status']=='ok') {")	
	aadd(aJSFoot,"		   		location.reload();")
	aadd(aJSFoot,"			}")
	aadd(aJSFoot,"		},")
	aadd(aJSFoot,"		error:function(response){")
	aadd(aJSFoot,"			alert( 'Erro ao mudar de filial, atualize a pagina e tente novamente.' );")
	aadd(aJSFoot,"			console.log(response);")
	aadd(aJSFoot,"		}")   
	aadd(aJSFoot,"	});")
	aadd(aJSFoot,"}")//function
	Self:addJSFoot(aJSFoot)

	//Contante de formatação para javascript
	aJSFoot := {}
	aadd(aJSFoot,"const options = { style: 'decimal', minimumFractionDigits: 2, maximumFractionDigits: 3 };")
	aadd(aJSFoot,"const formatNumber = new Intl.NumberFormat('pt-BR', options);")
	Self:addJSFoot(aJSFoot)

Return


// --------------------------------------------------------------------------
METHOD ExecMenu() Class ClsINNWeb

	Local nY := 0
	Local nX := 0

	IF ExistBlock("INNMenu")
		::aMenu := {}
		aParam := {::aMenu,::UserID,::cIdPgn}
		aParam := ExecBlock("INNMenu",.F.,.F.,aParam)
		::aMenu := aClone(aParam)
	ELSE
		self:AddCallOut("INNMenu não compilado!","danger")
	ENDIF
				
	if !Empty(::cIdPgn)
		For nY := 1 To Len(::aMenu)
			if ::aMenu[nY][1] == ::cIdPgn
				::aMenu[nY][5] := .T.
				::cFaIcons := iif(Empty(::cFaIcons),::aMenu[nY][4],::cFaIcons)
			endif
			for nX := 1 To Len(::aMenu[nY][6])
				if ::aMenu[nY][6][nX][1] == ::cIdPgn
					::aMenu[nY][5] := .T.
					::cFaIcons := iif(Empty(::cFaIcons),::aMenu[nY][4],::cFaIcons)
					::aMenu[nY][6][nX][4] := .T.
				endif
			next nX
		Next nY
	endif


	::cMenu += "<aside class='app-aside app-aside-expand-md app-aside-light'>" + CRLF
	::cMenu += "<!-- .aside-content -->" + CRLF
	::cMenu += "<div class='aside-content'>" + CRLF
	::cMenu += "  <!-- .aside-header -->" + CRLF
	::cMenu += "  <header class='aside-header d-block d-md-none'>" + CRLF
	::cMenu += "	<!-- .btn-account -->" + CRLF
	::cMenu += "	<button class='btn-account' type='button' data-toggle='collapse' data-target='#dropdown-aside'>"
	::cMenu += "	  <span class='user-avatar user-avatar-lg'><img src='imagens/unknown-profile.jpg' alt=''></span>"
	::cMenu += "	  <span class='account-icon'><span class='fa fa-caret-down fa-lg'></span></span>"
	::cMenu += "	  <span class='account-summary'>"
	::cMenu += "	    <span class='account-name'>"+Capital(::UserName)+"</span>"
	::cMenu += "	    <span class='account-description'>"+SM0->M0_CODFIL+" - "+Alltrim(SM0->M0_FILIAL)+"/"+SM0->M0_CODIGO+" - "+Alltrim(FWGrpName(SM0->M0_CODIGO))+"</span>"
	::cMenu += "	  </span>"
	::cMenu += "	</button> <!-- /.btn-account -->" + CRLF
	::cMenu += "	<!-- .dropdown-aside -->" + CRLF
	::cMenu += "	<div id='dropdown-aside' class='dropdown-aside collapse'>" + CRLF
	::cMenu += "	  <!-- dropdown-items -->" + CRLF
	::cMenu += "	  <div class='pb-3'>" + CRLF
	::cMenu += Self:ExecListaFil()
	::cMenu += "	  </div><!-- /dropdown-items -->" + CRLF
	::cMenu += "	</div><!-- /.dropdown-aside -->" + CRLF
	::cMenu += "  </header><!-- /.aside-header -->" + CRLF
	::cMenu += "  <!-- .aside-menu -->" + CRLF
	::cMenu += "  <div class='aside-menu overflow-hidden'>" + CRLF
	::cMenu += "	<!-- .stacked-menu -->" + CRLF
	::cMenu += "	<nav id='stacked-menu' class='stacked-menu'>" + CRLF
	::cMenu += "	  <!-- .menu -->" + CRLF
	::cMenu += "	  <ul class='menu'>" + CRLF
	::cMenu += "		<!-- .menu-item -->" + CRLF
	::cMenu += "		<li class='menu-item"+iif(Upper(Alltrim(::cIdPgn)) == "DASHBOARD" .or. Upper(Alltrim(::cIdPgn)) == "WSTART"," has-active","")+"'>" + CRLF
	::cMenu += "		  <a href='"+Self:cPgBase+"' class='menu-link'><span class='menu-icon fas fa-home'></span> <span class='menu-text'>Dashboard</span></a>" + CRLF
	::cMenu += "		</li><!-- /.menu-item -->" + CRLF
	::cMenu += "		<!-- .menu-item -->" + CRLF

	For nY := 1 To Len(::aMenu)

		//existe sub-menu
		if Len(::aMenu[nY][6]) > 0
			::cMenu += "<li class='menu-item has-child"+iif(::aMenu[nY][5]," has-active","")+"'>" + CRLF
			::cMenu += "  <a href='"+::aMenu[nY][3]+"' class='menu-link'><span class='"+::aMenu[nY][4]+"'></span> <span class='menu-text'>"+::aMenu[nY][2]+"</span></a></a>" + CRLF	
			::cMenu += "    <ul class='menu'>" + CRLF
			for nX := 1 To Len(::aMenu[nY][6])
				::cMenu += "    <li class='menu-item"+iif(::aMenu[nY][6][nX][4]," has-active","")+"'><a href='"+::aMenu[nY][6][nX][2]+"' class='menu-link'>"+::aMenu[nY][6][nX][3]+"</a></li>" + CRLF
			next nX
			::cMenu += "    </ul><!-- menu .._" + CRLF
			::cMenu += "</li><!-- menu-item has-child -->" + CRLF
		else
			::cMenu += "<li class='menu-item"+iif(::aMenu[nY][5]," has-active","")+"'>" + CRLF
			::cMenu += "  <a href='"+::aMenu[nY][3]+"' class='menu-link'><span class='"+::aMenu[nY][4]+"'></span> <span class='menu-text'>"+::aMenu[nY][2]+"</span></a>" + CRLF
			::cMenu += "</li><!-- /.menu-item -->" + CRLF
		endif
	Next nY


	::cMenu += "		<!-- .menu-header -->" + CRLF
	::cMenu += "	  </ul><!-- /.menu -->" + CRLF
	::cMenu += "	</nav><!-- /.stacked-menu -->" + CRLF
	::cMenu += "  </div><!-- /.aside-menu -->" + CRLF
	::cMenu += "  <!-- Skin changer -->" + CRLF
	::cMenu += "  <footer class='aside-footer border-top p-2'>" + CRLF
	::cMenu += "	<button class='btn btn-light btn-block text-primary' data-toggle='skin'><span class='d-compact-menu-none'>Modo escuro</span> <i class='fas fa-moon ml-1'></i></button>" + CRLF
	::cMenu += "  </footer><!-- /Skin changer -->" + CRLF
	::cMenu += "</div><!-- /.aside-content -->" + CRLF
	::cMenu += "</aside><!-- /.app-aside -->" + CRLF
	
Return

// --------------------------------------------------------------------------
METHOD ExecBar() Class ClsINNWeb

	::cTopBar += "<header class='app-header app-header-dark'>" + CRLF
	::cTopBar += "<!-- .top-bar -->" + CRLF
	::cTopBar += "<div class='top-bar'>" + CRLF
	::cTopBar += "	<!-- .top-bar-brand -->" + CRLF
	::cTopBar += "	<div class='top-bar-brand'>" + CRLF
	::cTopBar += "	<!-- toggle aside menu -->" + CRLF
	::cTopBar += "	<button class='hamburger hamburger-squeeze mr-2' type='button' data-toggle='aside-menu' aria-label='toggle aside menu'><span class='hamburger-box'><span class='hamburger-inner'></span></span></button> <!-- /toggle aside menu -->" + CRLF
	::cTopBar += "	<a href='"+Self:cPgBase+"'><img src='imagens/logo_head.png' alt='INN web'></a>" + CRLF
	::cTopBar += "	</div><!-- /.top-bar-brand -->" + CRLF
	::cTopBar += "	<!-- .top-bar-list -->" + CRLF
	::cTopBar += "	<div class='top-bar-list'>" + CRLF
	::cTopBar += "	<!-- .top-bar-item -->" + CRLF
	::cTopBar += "	<div class='top-bar-item px-2 d-md-none d-lg-none d-xl-none'>" + CRLF
	::cTopBar += "		<!-- toggle menu -->" + CRLF
	::cTopBar += "		<button class='hamburger hamburger-squeeze' type='button' data-toggle='aside' aria-label='toggle menu'><span class='hamburger-box'><span class='hamburger-inner'></span></span></button> <!-- /toggle menu -->" + CRLF
	::cTopBar += "	</div><!-- /.top-bar-item -->" + CRLF
	::cTopBar += "	<div class='top-bar-item top-bar-item-right px-0 d-none d-sm-flex'>" + CRLF
	::cTopBar += "		<!-- .btn-account -->" + CRLF
	::cTopBar += "		<div class='dropdown d-none d-md-flex'>" + CRLF
	::cTopBar += "		<button class='btn-account' type='button' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'>"
	::cTopBar += "		  <span class='user-avatar user-avatar-md'><img src='imagens/unknown-profile.jpg' alt=''></span>"
	::cTopBar += "		  <span class='account-summary pr-lg-4 d-none d-lg-block'>"
	::cTopBar += "		    <span class='account-name'>"+Capital(::UserName)+"</span>"
	::cTopBar += "		    <span class='account-description'>"+SM0->M0_CODFIL+" - "+Alltrim(SM0->M0_FILIAL)+"/"+SM0->M0_CODIGO+" - "+Alltrim(FWGrpName(SM0->M0_CODIGO))+"</span>"
	::cTopBar += "		  </span>"
	::cTopBar += "		</button> <!-- .dropdown-menu -->" + CRLF
	::cTopBar += "		<div class='dropdown-menu'>" + CRLF
	::cTopBar += Self:ExecListaFil()
	::cTopBar += "		</div><!-- /.dropdown-menu -->" + CRLF
	::cTopBar += "		</div><!-- /.btn-account -->" + CRLF
	::cTopBar += "	</div><!-- /.top-bar-item -->" + CRLF
	::cTopBar += "	</div><!-- /.top-bar-list -->" + CRLF
	::cTopBar += "</div><!-- /.top-bar -->" + CRLF
	::cTopBar += "</header><!-- /.app-header -->" + CRLF
		
Return

METHOD ExecListaFil() Class ClsINNWeb

	Local cHtml  := ""
	Local aSM0   := aClone(::aUsrSM0)//FWLoadSM0()
	Local cGrupo := ""
	Local nX

	cGrupo := ""
	for nX := 1 To Len(aSM0)
		if cGrupo != aSM0[nX][1]
			cHtml += "<a class='dropdown-item'><i class='fas fa-warehouse'></i> "+Alltrim(aSM0[nX][1])+" - "+Alltrim(FWGrpName(aSM0[nX][1]))+"</a>"
			cGrupo := aSM0[nX][1]
		endif
		//cHtml += "<a style='padding-left: 30px;' class='dropdown-item' href='?WsEmp="+Alltrim(aSM0[nX][1])+"&WsFil="+Alltrim(aSM0[nX][2])+"'><i class='fas fa-building'></i> "+Alltrim(aSM0[nX][2])+" - "+Alltrim(aSM0[nX][7])+"</a>" + CRLF
		cHtml += "<a style='padding-left: 30px;' class='dropdown-item' "
		//cHtml += " href='?WsEmp="+Alltrim(aSM0[nX][1])+"&WsFil="+Alltrim(aSM0[nX][2])+"' "
		cHtml += " onclick='MudaFilial("
		cHtml += '"'+Alltrim(aSM0[nX][1])+'"'
		cHtml += ","
		cHtml += '"'+Alltrim(aSM0[nX][2])+'"'
		cHtml += ")' "
		cHtml += ">"
		cHtml += " <i class='fas fa-building'></i> "
		cHtml += Alltrim(aSM0[nX][2])+" - "+Alltrim(aSM0[nX][3])
		cHtml += "</a>" + CRLF
	next nX

	cHtml += "<div class='dropdown-divider'></div>
	cHtml += "<a class='dropdown-item' href='?WSUsr=S'><span class='dropdown-icon oi oi-account-logout'></span> Sair</a>"

Return(cHtml)

// --------------------------------------------------------------------------
METHOD ExecFoot() Class ClsINNWeb

	::cFoot += "</body>" + CRLF
	::cFoot += "</html>"
	
Return

// --------------------------------------------------------------------------
METHOD ExecMonta() Class ClsINNWeb

	Local nY := 0
	Local nX := 0
	Local nBody
	
	::cHTML := ""
	
	if !Empty(::cRedir)
	
		::cHTML += "<html>" + CRLF
		::cHTML += "<head>" + CRLF 
		::cHTML += "<script>" + CRLF
		::cHTML += "window.location.href = '"+::cRedir+"';" + CRLF
		::cHTML += "</script>" + CRLF
		::cHTML += "</head>" + CRLF
		::cHTML += "<body>" + CRLF
		::cHTML += "Se o redirecionamento não acontecer automaticamente <a href='"+::cRedir+"'>clique aqui</a>" + CRLF			
		::cHTML += "</body>" + CRLF
		::cHTML += "</html>" + CRLF    
        
	elseif !Empty(::cHTMLSub)
	
		::cHTML := ::cHTMLSub
		
	elseif ::lSimpHTML

		::cHTML := ::cBody	
			
	else
	
		Self:ExecHead()
		Self:ExecMenu()
		Self:ExecBar()
		Self:ExecFoot()
		
		::cHTML += ::cHead + CRLF
		For nY := 1 To Len(::aIncl)
			::cHTML += Space(2) + "<!-- "+::aIncl[nY][1]+" -->" + CRLF
			for nX := 1 To Len(::aIncl[nY][2])
				IF ::aIncl[nY][2][nX][1] != "foot"
					::cHTML += Space(4) + ::aIncl[nY][2][nX][2] + CRLF
				ENDIF
			next
			::cHTML += CRLF + CRLF
		Next
		
		if Len(::aJSVar) > 0
			::cHTML += "<script>" + CRLF
			For nY := 1 To Len(::aJSVar)
					::cHTML += Space(2) + "var " + ::aJSVar[nY] + ";" + CRLF
			Next
			::cHTML += "</script>" + CRLF  
		endif
		
		if Len(::aJSHead) > 0
			::cHTML += "<script>" + CRLF
			For nY := 1 To Len(::aJSHead)
					::cHTML += Space(2) + ::aJSHead[nY] + CRLF
			Next
			::cHTML += "</script>" + CRLF  
		endif

		if Len(::cCSS) > 0
			::cHTML += "<style>" + CRLF
			::cHTML += ::cCSS + CRLF
			::cHTML += "</style>" + CRLF
		endif
		
		::cHTML += "</head>" + CRLF
		::cHTML += "<body>" + CRLF
		if ::lDebug
			::cHTML += "<a class='github-fork-ribbon' href='https://innovios.com.br/wiki/index.php?search=INN+Web+debug' target='_black' data-ribbon='debug ativo' title='debug ativo'>debug ativo</a>" + CRLF
		endif
		If !Empty(::cCodGgle)
			::cHTML += "<script>" + CRLF
			::cHTML += " (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){" + CRLF
			::cHTML += " (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o)," + CRLF
			::cHTML += " m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)" + CRLF
			::cHTML += " })(window,document,'script','//www.google-analytics.com/analytics.js','ga');" + CRLF
			::cHTML += " ga('create', '"+::cCodGgle+"', 'auto');" + CRLF
			::cHTML += " ga('send', 'pageview');" + CRLF
			::cHTML += "</script>" + CRLF 
		endif

		if !::lSimpPG
			::cHTML += "<!-- .app -->" + CRLF 
			::cHTML += "    <div class='app'>" + CRLF 
			::cHTML += "      <!--[if lt IE 10]>" + CRLF 
			::cHTML += "      <div class='page-message' role='alert'>You are using an <strong>outdated</strong> browser. Please <a class='alert-link' href='http://browsehappy.com/'>upgrade your browser</a> to improve your experience and security.</div>" + CRLF 
			::cHTML += "      <![endif]-->" + CRLF 
			::cHTML += "      <!-- .app-header -->" + CRLF 
			::cHTML += ::cTopBar
			::cHTML += ::cMenu

		
			::cHTML += "<main class='app-main'>" + CRLF
			::cHTML += "<!-- .wrapper -->" + CRLF
			::cHTML += "<div class='wrapper'>" + CRLF
			::cHTML += "  <!-- .page -->" + CRLF
			IF !Empty(::cFixBar)
				::cHTML += "  <div class='page has-sidebar has-sidebar-expand-xl'>" + CRLF
				::cHTML += "  <div class='sidebar-backdrop'></div>" + CRLF
			elseif !Empty(::cFlxBar)
				::cHTML += "  <div class='page has-sidebar'>" + CRLF
			else
				::cHTML += "  <div class='page'>" + CRLF
			endif
			::cHTML += "	<!-- .page-inner -->" + CRLF
			::cHTML += "	<div class='page-inner'>" + CRLF
			::cHTML += "	  <!-- .page-title-bar -->" + CRLF

			if Len(::aBreadCrb) > 0
				::cHTML += "	  <nav aria-label='breadcrumb'>" + CRLF
				::cHTML += "	    <ol class='breadcrumb'>" + CRLF
				for nY := 1 To Len(::aBreadCrb)
					::cHTML += "	      <li class='breadcrumb-item "+::aBreadCrb[nY][4]+"'>" + CRLF
					::cHTML += "	        <a href='"+::aBreadCrb[nY][1]+"'>
					::cHTML += iif(!Empty(::aBreadCrb[nY][3]),"<i class='breadcrumb-icon "+::aBreadCrb[nY][3]+" mr-2'></i>","")
					::cHTML += ::aBreadCrb[nY][2]+"</a>" + CRLF
					::cHTML += "	      </li>" + CRLF
				next
				::cHTML += "	    </ol>" + CRLF
				::cHTML += "	  </nav>" + CRLF
			endif
			
			::cHTML += "	  <header class='page-title-bar'>" + CRLF
			::cHTML += "		<div class='d-flex flex-column flex-md-row'>" + CRLF
			::cHTML += "		  <p class='lead'>" + CRLF
			::cHTML += "			<span class='font-weight-bold'>"+::cTitlePage+"</span>" + CRLF
			if !Empty(::cTitNot)
				::cHTML += "			<span class='d-block text-muted'>"+::cTitNot+"</span>" + CRLF
			endif
			::cHTML += "		  </p>" + CRLF

			if Len(::aHeadBtn) > 0
				::cHTML += "		  <div class='ml-auto'>" + CRLF
				::cHTML += "		    <div class='dropdown'>" + CRLF
				::cHTML += "		      <button class='btn btn-secondary' data-toggle='dropdown' aria-haspopup='true' aria-expanded='false'><span>Outras ações</span> <i class='fa fa-fw fa-caret-down'></i></button>" + CRLF
				::cHTML += "		      <div class='dropdown-menu dropdown-menu-right dropdown-menu-md stop-propagation'>" + CRLF
				::cHTML += "		        <div class='dropdown-arrow'></div>" + CRLF
				for nY := 1 To Len(::aHeadBtn)
					::cHTML += "		          <div class='custom-control'><a href='"+::aHeadBtn[nY][1]+"' class='custom-control-label d-flex justify-content-between'>"+::aHeadBtn[nY][2]+"</a></div>" + CRLF
				next nY
				::cHTML += "		      </div><!-- /.dropdown-menu -->" + CRLF
				::cHTML += "		    </div><!-- /.dropdown -->" + CRLF
				::cHTML += "		  </div><!-- /.ml-auto -->" + CRLF
			endif

			::cHTML += "		</div><!-- /.d-flex flex-column flex-md-row -->" + CRLF
			::cHTML += "	  </header><!-- /.page-title-bar -->" + CRLF
			//::cHTML += "	  <? } ?>" + CRLF*/
			::cHTML += "	  <!-- .page-section -->" + CRLF
			::cHTML += "	  <div class='page-section'>" + CRLF
		endif
		
		::cHTML += "<!-- ************************************************************ FIM DO HEAD ************************************************************* -->" + CRLF 	
		::cHTML += CRLF + CRLF
		for nBody := 1 To Len(::aBody)
			::cHTML += "<!-- Elemento: "+cValToChar(nBody)+" -- INICIO -->" + CRLF 	
			if ValType( ::aBody[nBody] ) == "O"
				::cHTML += ::aBody[nBody]:Execute() + CRLF
				FreeObj(::aBody[nBody])
			elseif ValType( ::aBody[nBody] ) == "C"
				::cHTML += ::aBody[nBody] + CRLF
			else
				::cHTML += "<p>Elemento invalido</p>"+ CRLF
			endif
			::cHTML += "<!-- Elemento: "+cValToChar(nBody)+" -- FIM -->" + CRLF 	
		next nBody


		if !Empty(::cBodyToast)
			::cHTML += "<div aria-live='polite' aria-atomic='true'>" + CRLF
			::cHTML += "  <div style='position: fixed; top: 4.5rem; right: 1rem; z-index: 1050'>" + CRLF
			::cHTML += ::cBodyToast
			::cHTML += "  </div><!-- /toasts position -->" + CRLF
			::cHTML += "</div><!-- /toasts container -->" + CRLF
		endif

		::cHTML += CRLF + CRLF
		::cHTML += "<!-- ********************************************************** INICIO DO FOOT ************************************************************ -->" + CRLF 

		if !::lSimpPG
			::cHTML += "		  </div><!-- /.page-section -->" + CRLF
			::cHTML += "		</div><!-- /.page-inner -->" + CRLF
			::cHTML += ::cFixBar
			::cHTML += ::cFlxBar
			::cHTML += "	  </div><!-- /.page -->" + CRLF
			::cHTML += "	</div><!-- .app-footer -->" + CRLF
			::cHTML += "	<!-- /.wrapper -->" + CRLF
			::cHTML += "  </main><!-- /.app-main -->" + CRLF
			::cHTML += "</div><!-- /.app -->" + CRLF
		endif
		
		::cHTML += CRLF + CRLF	

		For nY := 1 To Len(::aIncl)
			::cHTML += Space(2) + "<!-- "+::aIncl[nY][1]+" -->" + CRLF
			for nX := 1 To Len(::aIncl[nY][2])
				IF ::aIncl[nY][2][nX][1] == "foot"
					::cHTML += Space(4) + ::aIncl[nY][2][nX][2] + CRLF
				ENDIF
			next
			::cHTML += CRLF + CRLF
		Next

		if Len(::aLoadHead) > 0 .or. Len(::aLoad)
			::cHTML += "<script>" + CRLF
			::cHTML += "$(document).ready(function() {" + CRLF
			For nY := 1 To Len(::aLoadHead)
					::cHTML += Space(2) + ::aLoadHead[nY] + CRLF
			Next
			::cHTML += CRLF + CRLF + CRLF
			For nY := 1 To Len(::aLoad)
					::cHTML += Space(2) + ::aLoad[nY] + CRLF
			Next		
			::cHTML += "});" + CRLF
			::cHTML += "</script>" + CRLF
		endif

		if Len(::aThemeInit) > 0 
			::cHTML += "<script>" + CRLF
			::cHTML += "$(document).on('theme:init', function () {" + CRLF
			For nY := 1 To Len(::aThemeInit)
					::cHTML += Space(2) + ::aThemeInit[nY] + CRLF
			Next
			::cHTML += "});" + CRLF
			::cHTML += "</script>" + CRLF
		endif
		
		if Len(::aJSFoot) > 0
			::cHTML += "<script>" + CRLF
			For nY := 1 To Len(::aJSFoot)
					::cHTML += Space(2) + ::aJSFoot[nY] + CRLF
			Next
			::cHTML += "</script>" + CRLF  
		endif

		::cHTML += ::cFoot
		
	endif
	
	::cHTML := StrToHtml(::cHTML)
		                                           
Return


METHOD SetHtml(cHtml) Class ClsINNWeb

	::cHTMLSub := cHtml

Return

METHOD LoadBitmap(cCodImg) Class ClsINNWeb

	Local cResorce := ""
	
	Do Case
		Case cCodImg == "BR_VERMELHO" .OR. cCodImg == "ENABLE" 
			cResorce := "<img src='imagens/BR_VERMELHO.PNG'>"
		Case cCodImg == "BR_AZUL"
			cResorce := "<img src='imagens/BR_AZUL.PNG'>"
		Case cCodImg == "BR_VERDE"
			cResorce := "<img src='imagens/BR_VERDE.PNG'>"
		Case cCodImg == "BR_LARANJA"
			cResorce := "<img src='imagens/BR_LARANJA.PNG'>"
		Case cCodImg == "BR_AMARELO"
			cResorce := "<img src='imagens/BR_AMARELO.PNG'>"
		Case cCodImg == "BR_PRETO"
			cResorce := "<img src='imagens/BR_PRETO.PNG'>"
		Case cCodImg == "BR_BRANCO"
			cResorce := "<img src='imagens/BR_BRANCO.PNG'>"
		Case cCodImg == "PMSEDT2"
			cResorce := "<img src='imagens/PMSEDT2.PNG'>"
		OtherWise
			cResorce := "<img src='imagens/BR_CINZA.PNG'>"
	End Case
	
Return(cResorce)

METHOD fIcon(xTpExt) Class ClsINNWeb

	Local cIcone := ""
	
	xTpExt := Alltrim(Lower(xTpExt))

   	Do Case 

    	Case xTpExt == "pdf"
			cIcone := "<i class='fas fa-file-pdf fa-2x'></i>"
			
    	Case xTpExt == "xls" .or. xTpExt == "xlsx" .or. xTpExt == "csv"
			cIcone := "<i class='fas fa-file-excel fa-2x'></i>"
			
    	Case xTpExt == "doc" .or. xTpExt == "docx" .or. xTpExt == "txt"
			cIcone := "<i class='fas fa-file-word fa-2x'></i>"
			
    	Case xTpExt == "zip" .or. xTpExt == "rar"
			cIcone := "<i class='fas fa-file-archive fa-2x'></i>"
			    			    		
		OtherWise
			cIcone := "<i class='fas fa-file fa-2x'></i>"
    		
    EndCase
    
    cIcone := "<div align='center'>" + cIcone + "</div>"

Return(cIcone)

METHOD ValidVinc(c1Tab,c2Tab) Class ClsINNWeb

	Local lRet := .T.
	
	if xFilial(c1Tab) == xFilial(c2Tab)
		lRet := .T.
	else
		lRet := .F.
	endif
	
Return(lRet)

METHOD TamFild(aField) Class ClsINNWeb
	
	//aField[1] -> Nome do campo (Nao usado)
	//aField[2] -> Titulo
	//aField[3] -> Conteudo
	//aField[4] -> Tipo

	Local xTam := "2"
	Local cTamValue := aField[3] //Conteudo
	Local cTamTitulo := len(aField[2]) //Titulo

	if aField[4] == "D"
		cTamValue := 10
	endif

	xTam := max(cTamValue,Round(cTamTitulo*0.4,0))
	xTam := iif (xTam > 60 , 60 , xTam) 
	xTam := round(xTam/10,0) + iif ( xTam % 10 >= 0 , 1 , 0)
	xTam := iif (xTam > 6 , 6 , xTam)
	xTam := cValToChar(xTam)
	
Return(xTam)


METHOD SimpleX3Table(xAlias,nIndex,bRegra,cCampos) Class ClsINNWeb

	Local oINNWebTable := INNWebTable():New( Self )
	oINNWebTable:SimpleX3Table(xAlias,nIndex,bRegra,cCampos)

Return(oINNWebTable)

METHOD xModelo3(xAlias1,xRecAlias1,xAlias2,xIndice2,xFiltro) Class ClsINNWeb

	Local oBrowse	:= INNWebBrowse():New( Self )
	Local oTable	:= INNWebTable():New( Self )

	oBrowse:SetTabela( xAlias1 )
	oBrowse:SetRec( xRecAlias1 )

	oTable:SimpleX3Table(xAlias2,xIndice2,xFiltro)

Return({oBrowse,oTable})

METHOD xCadastro(xAlias,xRecAlias) Class ClsINNWeb

	Local oBrowse	:= INNWebBrowse():New( Self )

	oBrowse:SetTabela( xAlias )
	oBrowse:SetRec( xRecAlias )

Return(oBrowse)

METHOD ImgProd(cCodigo) Class ClsINNWeb

	Local oINNWebImgProd := INNWebImgProd():New(Self)
	Local cImagem := ""

	cImagem := oINNWebImgProd:GetImg(cCodigo)

Return(cImagem)

METHOD GetImgUrl(cCodigo) Class ClsINNWeb

	Local oINNWebImgProd := INNWebImgProd():New(Self)
	Local cImagem := ""

	cImagem := oINNWebImgProd:GetImgUrl(cCodigo)

Return(cImagem)

METHOD RepArqs(cTipo,cChave) Class ClsINNWeb

	Local oINNWebAnexo := INNWebAnexo():New(Self)

	oINNWebAnexo:SetChave(cChave)
	oINNWebAnexo:SetTipo(cTipo)
	oINNWebAnexo:GetArquivos()
	oINNWebAnexo:Upload()

Return()

METHOD Criadb() Class ClsINNWeb

	Local cReposit := ""
	Local cDriver  := ""//__cRDD
	Local cFile    := ""
	Local lReOpen  := .F.
	//Local lRet     := .T.
	Local aStru    := {}	
	Local nY       := 0
	Local nX       := 0
	Local aIndex   := {}
	Local cQUpdate
	//Local aUniquege
	Local aTabelas	:= {}
	
	cDriver  := __cRDD
	
	// FOTOS DOS PRODUTOS
	aadd(aTabelas,{"INN001",{},{},{}})
	nY := Len(aTabelas)
	Aadd(aTabelas[nY][2],{"BMFILIAL","C",len(xFilial("SB1")),0})
	Aadd(aTabelas[nY][2],{"BMPID"   ,"C",006,0})
	Aadd(aTabelas[nY][2],{"BMPNAME" ,"C",020,0})
	Aadd(aTabelas[nY][2],{"BMPSIZE" ,"N",012,0})
	Aadd(aTabelas[nY][2],{"BMPEXT"  ,"C",010,0})
	Aadd(aTabelas[nY][2],{"BMPURL"  ,"C",250,0})
	Aadd(aTabelas[nY][2],{"BMPDIR"  ,"C",250,0})
	Aadd(aTabelas[nY][2],{"BMPMD5"  ,"C",035,0})
	Aadd(aTabelas[nY][2],{"USINCLU" ,"C",050,0})
	Aadd(aTabelas[nY][2],{"DTINCLU" ,"D",008,0})
	Aadd(aTabelas[nY][2],{"BMPFULL" ,"M",010,0})
	Aadd(aTabelas[nY][2],{"BMP75"   ,"M",010,0})
	Aadd(aTabelas[nY][2],{"BMP250"  ,"M",010,0})
	Aadd(aTabelas[nY][2],{"BMP500"  ,"M",010,0})	
	Aadd(aTabelas[nY][3],"BMFILIAL+BMPID")
	Aadd(aTabelas[nY][3],"BMFILIAL+BMPMD5")
	Aadd(aTabelas[nY][4],"BMFILIAL")
	Aadd(aTabelas[nY][4],"BMPID")

	// Amarracao FOTOS X PRODUTOS
	aadd(aTabelas,{"INN002",{},{},{}})
	nY := Len(aTabelas)
	Aadd(aTabelas[nY][2],{"BMFILIAL","C",len(xFilial("SB1")),0})
	Aadd(aTabelas[nY][2],{"BMPID"   ,"C",006,0})
	Aadd(aTabelas[nY][2],{"B1_COD"  ,"C",015,0})
	Aadd(aTabelas[nY][2],{"SEQUENC" ,"C",002,0})	
	Aadd(aTabelas[nY][3],"BMFILIAL+BMPID+B1_COD")
	Aadd(aTabelas[nY][3],"BMFILIAL+B1_COD+SEQUENC")
	Aadd(aTabelas[nY][4],"BMFILIAL")
	Aadd(aTabelas[nY][4],"B1_COD")
	Aadd(aTabelas[nY][4],"SEQUENC")
		
	// Anexo de arquivos a elementos do Protheus	
	aadd(aTabelas,{"INN003",{},{},{}})
	nY := Len(aTabelas)
	Aadd(aTabelas[nY][2],{"TIPO"    ,"C",003,0}) // "DI ","NFE"
	Aadd(aTabelas[nY][2],{"DOC"     ,"C",035,0})
	Aadd(aTabelas[nY][2],{"BMPID"   ,"C",009,0})
	Aadd(aTabelas[nY][2],{"BMPNAME" ,"C",020,0})
	Aadd(aTabelas[nY][2],{"BMPSIZE" ,"N",012,0})
	Aadd(aTabelas[nY][2],{"BMPEXT"  ,"C",010,0})
	Aadd(aTabelas[nY][2],{"BMPURL"  ,"C",250,0})
	Aadd(aTabelas[nY][2],{"BMPDIR"  ,"C",250,0})
	Aadd(aTabelas[nY][2],{"BMPMD5"  ,"C",035,0})
	Aadd(aTabelas[nY][2],{"USINCLU" ,"C",050,0})
	Aadd(aTabelas[nY][2],{"DTINCLU" ,"D",008,0})
	Aadd(aTabelas[nY][2],{"HRINCLU" ,"C",012,0})

	Aadd(aTabelas[nY][2],{"USIEXCL" ,"C",050,0})
	Aadd(aTabelas[nY][2],{"DTIEXCL" ,"D",008,0})
	Aadd(aTabelas[nY][2],{"HRIEXCL" ,"C",012,0})	

	Aadd(aTabelas[nY][2],{"NOMEORIG","C",050,0})
	Aadd(aTabelas[nY][3],"TIPO+DOC+BMPID")
	Aadd(aTabelas[nY][3],"BMPID+TIPO+DOC")
	Aadd(aTabelas[nY][3],"BMPMD5")


	For nY := 1 To Len(aTabelas)
			
		cReposit := aTabelas[nY][1]
		aStru    := aTabelas[nY][2]
		aIndex	 := aTabelas[nY][3]
		aUnique	 := aTabelas[nY][4]
	
		if Select(cReposit) == 0
	
			cFile    := RetArq(cDriver,cReposit,.T.)	
			
			If !MsFile(cFile,,cDriver)
				DbCreate(cReposit,aStru,cDriver)
				if len(aUnique) > 0
					aadd(aUnique,"R_E_C_D_E_L_")
					cQUpdate := ""
					for nX := 1 To Len(aUnique)
						cQUpdate += iif(!Empty(cQUpdate),", ","")
						cQUpdate += " ["+aUnique[nX]+"] ASC "
					next nX
					If UPPER(AllTrim(TcGetDb())) == "MSSQL"
						cQUpdate := " CREATE UNIQUE NONCLUSTERED INDEX ["+cReposit+"_UNQ] ON [dbo].["+cReposit+"] ("+cQUpdate+") "
						cQUpdate += " WITH (	PAD_INDEX = OFF, "
						cQUpdate += "           STATISTICS_NORECOMPUTE = OFF, "
						cQUpdate += "           SORT_IN_TEMPDB = OFF, "
						cQUpdate += "           IGNORE_DUP_KEY = OFF, "
						cQUpdate += "           DROP_EXISTING = OFF, "
						cQUpdate += "           ONLINE = OFF, "
						cQUpdate += "           ALLOW_ROW_LOCKS = ON, "
						cQUpdate += "           ALLOW_PAGE_LOCKS = ON) "
						cQUpdate += " ON [PRIMARY]"
						nRet := TCSqlExec(cQUpdate)
						If nRet != 0
							UserException( TcSqlError() )
						EndIf
					EndIf
				endif
			EndIf
			
			If MsOpenDbf(.T.,cDriver,cFile,cReposit,.T.,.F.,.F.,.F.) //MsOpEndbf(lNewArea,cDriver,cArquivo,cAlias,lShared,lReadOnly,lHelp,lQuit)
				DbSelectArea(cReposit)
				
				for nX := 1 To Len(aIndex)
				
					lReOpen := !MsFile(cFile,cFile+cValToChar(nX),cDriver)
					cIndex  := cReposit+cValToChar(nX)
					MsOpenIdx(cIndex,aIndex[nX],.T.,.F.,,cFile)//cIndice,cChave,lUnique,lMensagem,oAction,cArquivo,nLin,nCol
				
					If lReOpen
						DbCloseArea()
						MsOpenDbf(.T.,cDriver,cFile,cReposit,.T.,.F.,.F.,.F.)
						DbSelectArea(cReposit)
						cIndex  := cReposit+cValToChar(nX)
						MsOpenIdx(cIndex,aIndex[nX],.T.,.F.,,cFile)
					EndIf
					
				Next nX
				
				DbSetOrder(1)
				
			EndIf
			
		endif
		
	next nY

Return

METHOD ExePod(cCodigo) Class ClsINNWeb

	Local aLinha 	:= {}
	Local oINNWebTable := INNWebTable():New( oINNWeb )
	
	oINNWebTable:SetSimple()
	oINNWebTable:AddHead({"","C",""})
	oINNWebTable:AddHead({RetTitle("B1_COD")	,TamSx3("B1_COD")[3]	,PesqPict("SB1","B1_COD")})
	oINNWebTable:AddHead({RetTitle("B1_DESC")	,TamSx3("B1_COD")[3]	,PesqPict("SB1","B1_DESC")})
	oINNWebTable:AddHead({RetTitle("B1_TIPO")	,TamSx3("B1_COD")[3]	,PesqPict("SB1","B1_TIPO")})
	oINNWebTable:AddHead({RetTitle("B1_UM")		,TamSx3("B1_UM")[3]		,PesqPict("SB1","B1_UM")})
	oINNWebTable:AddHead({RetTitle("B1_LOCPAD")	,TamSx3("B1_LOCPAD")[3]	,PesqPict("SB1","B1_LOCPAD")})
	oINNWebTable:AddHead({RetTitle("B1_GRUPO")	,TamSx3("B1_GRUPO")[3]	,PesqPict("SB1","B1_GRUPO")})

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if ( SB1->(dbSeek(xFilial("SB1")+cCodigo)) )
	
		aLinha := {}
		aadd(aLinha,Self:ImgProd(cCodigo))
		aadd(aLinha,SB1->B1_COD)
		aadd(aLinha,SB1->B1_DESC)
		aadd(aLinha,SB1->B1_TIPO + " - " + POSICIONE("SX5",1,xFilial("SX5")+"02"+SB1->B1_TIPO,"X5_DESCRI") )
		aadd(aLinha,SB1->B1_UM + " - " + POSICIONE("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO"))
		aadd(aLinha,SB1->B1_LOCPAD + " - " + POSICIONE("NNR",1,xFilial("NNR")+SB1->B1_LOCPAD,"NNR_DESCRI") )
		aadd(aLinha,SB1->B1_GRUPO + " - " + POSICIONE("SBM",1,xFilial("SBM")+SB1->B1_GRUPO,"BM_DESC") )
		
		oINNWebTable:AddCols(aLinha)
	
	endif
	
Return

Static Function StrToHtml(cTexto)

	cTexto := StrTran(cTexto,"ç","&ccedil;")
	cTexto := StrTran(cTexto,"á","&aacute;")
	cTexto := StrTran(cTexto,"à","&agrave;")
	cTexto := StrTran(cTexto,"â","&acirc;" )
	cTexto := StrTran(cTexto,"ã","&atilde;")
	cTexto := StrTran(cTexto,"ä","&auml;"  )
	cTexto := StrTran(cTexto,"ó","&oacute;")
	cTexto := StrTran(cTexto,"ò","&ograve;")
	cTexto := StrTran(cTexto,"ô","&ocirc;" )
	cTexto := StrTran(cTexto,"õ","&otilde;")
	cTexto := StrTran(cTexto,"é","&eacute;")
	cTexto := StrTran(cTexto,"è","&egrave;")
	cTexto := StrTran(cTexto,"ê","&ecirc;" )
	cTexto := StrTran(cTexto,"í","&iacute;")
	cTexto := StrTran(cTexto,"ì","&igrave;")
	cTexto := StrTran(cTexto,"î","&icirc;" )
	cTexto := StrTran(cTexto,"ú","&uacute;")
	cTexto := StrTran(cTexto,"ù","&ugrave;")
	cTexto := StrTran(cTexto,"û","&ucirc;" )

	cTexto := StrTran(cTexto,"Ç","&Ccedil;")
	cTexto := StrTran(cTexto,"Á","&Aacute;")
	cTexto := StrTran(cTexto,"À","&Agrave;")
	cTexto := StrTran(cTexto,"Â","&Acirc;" )
	cTexto := StrTran(cTexto,"Ã","&Atilde;")
	cTexto := StrTran(cTexto,"Ä","&Auml;"  )
	cTexto := StrTran(cTexto,"Ó","&Oacute;")
	cTexto := StrTran(cTexto,"Ò","&Ograve;")
	cTexto := StrTran(cTexto,"Ô","&Ocirc;" )
	cTexto := StrTran(cTexto,"Õ","&Otilde;")
	cTexto := StrTran(cTexto,"É","&Eacute;")
	cTexto := StrTran(cTexto,"È","&Egrave;")
	cTexto := StrTran(cTexto,"Ê","&Ecirc;" )
	cTexto := StrTran(cTexto,"Í","&Iacute;")
	cTexto := StrTran(cTexto,"Ì","&Igrave;")
	cTexto := StrTran(cTexto,"Î","&Icirc;" )
	cTexto := StrTran(cTexto,"Ú","&Uacute;")
	cTexto := StrTran(cTexto,"Ù","&Ugrave;")
	cTexto := StrTran(cTexto,"Û","&Ucirc;" )
	
	cTexto := StrTran(cTexto,"°","&deg;"   )
	cTexto := StrTran(cTexto,"º","&ordm;"  )
	cTexto := StrTran(cTexto,"–","&ndash;" )
	                                        
	cTexto := StrTran(cTexto,"‡","&Dagger;")
	cTexto := StrTran(cTexto,"’","&rsquo;" )	
	cTexto := StrTran(cTexto,"£","&#163"   )	
	
Return(cTexto)

METHOD UsrSM0() Class ClsINNWeb

	Local aTemp := {}
	Local nY

	//Se for Admin lista as filiais, pq o admin não respeita nada e tem tudo
	IF UGrpIn(::UserID,"000000")

		iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

		cQuery := " SELECT DISTINCT  [M0_CODIGO] USR_GRPEMP ,[M0_CODFIL] USR_FILIAL FROM SYS_COMPANY WHERE D_E_L_E_T_ = ' ' "

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.F.,.T.)

		DbSelectArea("TMP")
		TMP->(dbGoTop())
			
		WHILE (TMP->(!EOF()))

			aadd(aTemp,{TMP->USR_GRPEMP,TMP->USR_FILIAL,FWFilName(TMP->USR_GRPEMP,TMP->USR_FILIAL)})

			TMP->(DbSkip())

		ENDDO  
					
		iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

	endif

	//Acesso de filiais por grupo
	iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

	cQuery := " SELECT DISTINCT GRUPO.USR_PRIORIZA,USR.USR_GRPRULE,GR__GRPEMP,GR__FILIAL "
	cQuery += " FROM SYS_USR USR "
	cQuery += " INNER JOIN SYS_USR_GROUPS GRUPO ON USR.USR_ID = GRUPO.USR_ID "
	cQuery += " INNER JOIN SYS_GRP_FILIAL GRP_FILIAL ON GRP_FILIAL.GR__ID = GRUPO.USR_GRUPO "
	cQuery += " WHERE  USR.USR_ID = '"+::UserID+"' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	TMP->(dbGoTop())
		
	WHILE (TMP->(!EOF()))

		IF TMP->USR_GRPRULE == "1" .or. TMP->USR_GRPRULE == "3"
			aadd(aTemp,{TMP->GR__GRPEMP,TMP->GR__FILIAL,FWFilName(TMP->GR__GRPEMP,TMP->GR__FILIAL)})
		ENDIF
		TMP->(DbSkip())

	ENDDO  
	

	//Acesso direto no usuario
	iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

	cQuery := " SELECT DISTINCT FILIAL.USR_GRPEMP,FILIAL.USR_FILIAL "
	cQuery += " FROM SYS_USR USR "
	cQuery += " INNER JOIN SYS_USR_FILIAL FILIAL ON USR.USR_ID = FILIAL.USR_ID "
	cQuery += " WHERE FILIAL.USR_ACESSO = 'T' "
	cQuery += " AND USR.USR_ID = '"+::UserID+"'  "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	TMP->(dbGoTop())
		
	WHILE (TMP->(!EOF()))

		aadd(aTemp,{TMP->USR_GRPEMP,TMP->USR_FILIAL,FWFilName(TMP->USR_GRPEMP,TMP->USR_FILIAL)})
		TMP->(DbSkip())

	ENDDO  
	

	//Acesso se estiver marcado todas as empresas no usuario
	iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

	cQuery := " SELECT DISTINCT  [M0_CODIGO] USR_GRPEMP ,[M0_CODFIL] USR_FILIAL "
	cQuery += " FROM SYS_USR USR "
	cQuery += " INNER JOIN SYS_COMPANY SM0 ON SM0.D_E_L_E_T_ != '*' "
	cQuery += " WHERE USR.USR_ALLEMP = '1' "
	cQuery += " AND USR.USR_ID = '"+::UserID+"' "

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP",.F.,.T.)

	DbSelectArea("TMP")
	TMP->(dbGoTop())
		
	WHILE (TMP->(!EOF()))

		aadd(aTemp,{TMP->USR_GRPEMP,TMP->USR_FILIAL,FWFilName(TMP->USR_GRPEMP,TMP->USR_FILIAL)})
		TMP->(DbSkip())

	ENDDO  
				
	iif(select("TMP") <> 0,TMP->(dbCloseArea()),nil)

	::aUsrSM0 := {}

	for nY := 1 To Len(aTemp)
		aTemp[nY][1] := Alltrim(aTemp[nY][1])
		aTemp[nY][2] := Alltrim(aTemp[nY][2])
		aTemp[nY][3] := Alltrim(aTemp[nY][3])
		if aScan( ::aUsrSM0 ,{|x| x[1] == aTemp[nY][1] .and.  x[2] == aTemp[nY][2] }) < 1
			aadd( ::aUsrSM0 , aClone(aTemp[nY]) )
		endif
	next nY


Return(.T.)

METHOD VldSM0() Class ClsINNWeb

	Local lRet := .T.

	if aScan( ::aUsrSM0 ,{|x| x[1] == HttpSession->WsEmp .and.  x[2] == HttpSession->WsFil }) < 1
		lRet := .F.
	endif

	if Len(::aUsrSM0) == 0
		UserException( "Usuario sem acesso a nenhuma filial." )
	endif

Return(lRet)
