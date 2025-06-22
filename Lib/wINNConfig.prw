#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wINNConfig(oINNWeb)

    Local nY

    For nY := 1 To Len(oINNWeb:aDirTemp)
        oINNWeb:addBody(strzero(nY,2)+": "+oINNWeb:aDirTemp[nY]+" | "+iif(ExistDir(oINNWeb:aDirTemp[nY]),"ok","Erro")+"<br>" )
    next 

    oINNWeb:addBody( "<br><br>" )
    oINNWeb:addBody("GetEnvServer: "+GetEnvServer()+"<br>" )
    oINNWeb:addBody("GetBuild: "+GetBuild()+"<br>" )
    oINNWeb:addBody("GetSrvVersion: "+GetSrvVersion()+"<br>" )
    oINNWeb:addBody("RootPath: "+GetSrvProfString("RootPath", "\undefined")+"<br>" )
    oINNWeb:addBody("StartPath: "+GetSrvProfString("StartPath", "\undefined")+"<br>" )

    oINNWeb:SetTitle("INN Config")

Return
