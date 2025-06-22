#include 'protheus.ch'
#include 'parmtype.ch'
#include "innlib.ch"

user function w404(oINNWeb)

    Local cBody := ""

    cBody += "<div class='empty-state'>" + CRLF
    cBody += "  <div class='empty-state-container'>" + CRLF
    cBody += "    <div class='state-figure'>" + CRLF
    cBody += "	  <img class='img-fluid' src='imagens/illustration/img-2.svg' alt='' style='max-width: 320px'>" + CRLF
    cBody += "    </div>" + CRLF
    cBody += "    <h3 class='state-header'> Recurso não encontrado! </h3>" + CRLF
    cBody += "    <p class='state-description lead text-muted'> Descupe, este recurso não esta disponivel ou existe um erro no sistema. </p>" + CRLF
    cBody += "    <div class='state-action'>" + CRLF
    cBody += "	  <a href='/' class='btn btn-lg btn-light'><i class='fa fa-angle-right'></i> Voltar</a>" + CRLF
    cBody += "    </div>" + CRLF
    cBody += "  </div><!-- /.empty-state-container -->" + CRLF
    cBody += "</div><!-- /.empty-state -->" + CRLF

	oINNWeb:AddBody(cBody)
	oINNWeb:SetTitle("Recurso não encontrado") 
	oINNWeb:SetIdPgn("wStart")
	
Return(.T.)
