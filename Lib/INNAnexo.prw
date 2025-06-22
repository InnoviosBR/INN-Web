#include "TOTVS.CH"
  
User Function INNAnexo(cTipo,cDocumento)

	Local __oDlgAnexo	:= nil
	Local oWebEngine 	:= nil

	Local cToken	:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cSite		:= Alltrim(GetMV("IN_SRVURL"))
	Local cURLDlg 	:= ""
	Local cURLShl 	:= ""
	
	Local aObjects
	Local aSize
	Local aInfo
	Local aPosObj

	cURLDlg := cSite
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
	

	aObjects := {}
	aSize    := MsAdvSize(.F.)
	aSize[3] := aSize[3]*0.70//horizontal
	aSize[5] := aSize[5]*0.70//horizontal
	aSize[4] := aSize[4]*0.70//vertival
	aSize[6] := aSize[6]*0.70//vertival
	aInfo    := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 , 0 }
	AAdd( aObjects, { 100, 100, .T. , .T. , } )
	aPosObj  := MsObjSize( aInfo, aObjects )
	
	__oDlgAnexo := MSDialog():New( aSize[7],aSize[1],aSize[6],aSize[5],"Anexos ("+Alltrim(cTipo)+"-"+Alltrim(cDocumento)+")",,,.F.,,,,,,.T.,,,.T. )

	oWebEngine := TWebEngine():New(__oDlgAnexo,aSize[7],aSize[1],aSize[6],aSize[5])
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
	oWebEngine:navigate(cURLDlg)
	
	__oDlgAnexo:Activate(,,,.T.)

	//ShellExecute( "open", cURLShl , "", "", 1 )

Return
