#include "TOTVS.CH"
  
User Function INNOpen(cPagina,cParm)
	
	Local cTitulo		:= "Abertura de Páginas - INN Web"
	Local cToken		:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cURLShl		:= Alltrim(GetMV("IN_SRVURL")) + "?x="+cPagina+"&simples=S&token="+cToken+"&"+cParm
	
	Local nMilissegundos := 10*1000 //30 segundos
	
	Local _oDlgOpen, oSay1, oURL, oBtnFechar, oTimer := nil
	
	ShellExecute( "open", cURLShl , "", "", 1 )

	_oDlgOpen  := MSDialog():New( 265,349,397,814,cTitulo,,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Caso o browser padrão não abra automaticamente em 30 segundos utilize a url abaixo."},_oDlgOpen,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)
	oURL       := TGet():New( 024,008,{|u| If(PCount()>0,cURLShl:=u,cURLShl)},_oDlgOpen,212,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cURLShl",,)
	oBtnFechar := TButton():New( 040,008,"Fechar",_oDlgOpen,{|| _oDlgOpen:End() },037,012,,,,.T.,,"",,,,.F. )

	oTimer := TTimer():New(nMilissegundos, {|| _oDlgOpen:End() }, _oDlgOpen )
	oTimer:Activate()

	_oDlgOpen:Activate(,,,.T.)
  
Return
