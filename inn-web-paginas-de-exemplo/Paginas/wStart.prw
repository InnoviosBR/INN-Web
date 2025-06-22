//#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wStart(oINNWeb)
	
	oINNWeb:SetTitle("Painel de Controle")
	oINNWeb:SetTitNot("Resumo de tudo que realmente importa")

	cTexto := ""
	cTexto += "Banco de Dados: "+UPPER(AllTrim(TcGetDb()))+"<br>"
	cTexto += "Ambiente: "+upper(ALLTRIM(GetEnvServer()))+"<br>"
	cTexto += "Release: "+GetRPORelease()+"<br>"
	cTexto += "Versão: "+oINNWeb:cVersao+"<br>"
	oINNWeb:addCard(cTexto)

Return
