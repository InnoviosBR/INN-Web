#include "TOTVS.CH"
  
User Function INNOpen(cPagina,cParm)

	Local __oDlgOpen	:= nil
	Local oWebEngine 	:= nil
	Local cToken		:= Alltrim(GetMV("IN_TOKEN"))+RetCodUsr()
	Local cURL 			:= Alltrim(GetMV("IN_SRVURL")) + "?x="+cPagina+"&simples=S&token="+cToken+"&"+cParm
	
	Local aObjects
	Local aSize
	Local aInfo
	Local aPosObj
	
	aObjects := {}
	aSize    := MsAdvSize(.F.)
	aSize[3] := aSize[3]*0.70//horizontal
	aSize[5] := aSize[5]*0.70//horizontal
	aSize[4] := aSize[4]*0.70//vertival
	aSize[6] := aSize[6]*0.70//vertival
	aInfo    := { aSize[ 1 ] , aSize[ 2 ] , aSize[ 3 ] , aSize[ 4 ] , 0 , 0 }
	AAdd( aObjects, { 100, 100, .T. , .T. , } )
	aPosObj  := MsObjSize( aInfo, aObjects )
	
	__oDlgOpen := MSDialog():New( aSize[7],aSize[1],aSize[6],aSize[5],"INNWeb",,,.F.,,,,,,.T.,,,.T. )

	oWebEngine := TWebEngine():New(__oDlgOpen,aSize[7],aSize[1],aSize[6],aSize[5])
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
	oWebEngine:navigate(cURL)
	
	__oDlgOpen:Activate(,,,.T.)
  
Return
