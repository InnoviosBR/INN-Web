#include "TOTVS.CH"
  

User Function INNAnexo(cTipo,cDocumento,cAlias,nRecno)

	Local cTitulo	:= "Anexos ("+Alltrim(cTipo)+"-"+Alltrim(cDocumento)+")"
	Local cToken	:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cSite		:= Alltrim(GetMV("IN_SRVURL"))
	Local cURLShl 	:= ""

	Local nMilissegundos := 10*1000 //30 segundos

	Local _oDlgAnexo, oSay1, oURL, oBtnFechar, oTimer := nil

	Default cAlias      := ""
	Default nRecno      := 0

	cURLShl := cSite
	cURLShl += "u_windex.apw"
	cURLShl += "?x=wExplorer"
	cURLShl += "&Tipo="+cTipo
	cURLShl += "&Documento="+cDocumento
	cURLShl += "&Token="+cToken

	//Vou preparar o envio dessas informações mas não implementei ainda.
	//Quando implementar, será possivel ver um cabacario ao anexo associado
	cURLShl += "&alias="+cAlias
	cURLShl += "&recno="+cValToChar(nRecno)

	ShellExecute( "open", cURLShl , "", "", 1 )

	_oDlgAnexo := MSDialog():New( 265,349,397,814,cTitulo,,,.F.,,,,,,.T.,,,.T. )
	oSay1      := TSay():New( 008,004,{||"Caso o browser padrão não abra automaticamente em 30 segundos utilize a url abaixo."},_oDlgAnexo,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,250,008)
	oURL       := TGet():New( 024,008,{|u| If(PCount()>0,cURLShl:=u,cURLShl)},_oDlgAnexo,212,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cURLShl",,)
	oBtnFechar := TButton():New( 040,008,"Fechar",_oDlgAnexo,{|| _oDlgAnexo:End() },037,012,,,,.T.,,"",,,,.F. )

	oTimer := TTimer():New(nMilissegundos, {|| _oDlgAnexo:End() }, _oDlgAnexo )
	oTimer:Activate()

	_oDlgAnexo:Activate(,,,.T.)

Return

/*
User Function INNAnexo(cTipo,cDocumento)

	Local _oDlgAnexo	:= nil
	Local oWebEngine 	:= nil

	Local cToken	:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cSite		:= Alltrim(GetMV("IN_SRVURL"))
	Local cURLDlg 	:= ""
	Local cURLShl 	:= ""
	
	Local aObjects
	Local aSize
	Local aInfo
	Local aPosObj

	cURLDlg := "https://192.168.1.20:8085/innweb/" //cSite
	cURLDlg += "u_windex.apw"
	cURLDlg += "?x=wExplorer"
	cURLDlg += "&Simples=S"
	cURLDlg += "&Tipo="+cTipo
	cURLDlg += "&Documento="+cDocumento
	cURLDlg += "&Token="+cToken

	cURLShl := cSite
	cURLShl += "u_windex.apw"
	cURLShl += "?x=wExplorer"
	cURLShl += "&Tipo="+cTipo
	cURLShl += "&Documento="+cDocumento
	cURLShl += "&Token="+cToken
	
	conout(cURLDlg)
	conout(cURLShl)

	//cURLDlg := "https://innovios.com.br/site/"

	aObjects := {}
	aSize    := MsAdvSize(.F.)
	aSize[3] := aSize[3]*0.70//horizontal
	aSize[5] := aSize[5]*0.70//horizontal
	aSize[4] := aSize[4]*0.70//vertival
	aSize[6] := aSize[6]*0.70//vertival
	aInfo    := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 , 0 }
	AAdd( aObjects, { 100, 100, .T. , .T. , } )
	aPosObj  := MsObjSize( aInfo, aObjects )
	
	_oDlgAnexo := MSDialog():New( aSize[7],aSize[1],aSize[6],aSize[5],"Anexos ("+Alltrim(cTipo)+"-"+Alltrim(cDocumento)+")",,,.F.,,,,,,.T.,,,.T. )

        oWebChannel := TWebChannel():New()
        nPort := oWebChannel::connect()


	oWebEngine := TWebEngine():New(_oDlgAnexo,aSize[7],aSize[1],aSize[6],aSize[5],, nPort)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
	oWebEngine:navigate(cURLDlg)
	
	_oDlgAnexo:Activate(,,,.T.)

	//ShellExecute( "open", cURLShl , "", "", 1 )

Return
/*
