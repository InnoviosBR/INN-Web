#include "protheus.ch"
#INCLUDE "MYLIB.CH"
#include "tryexception.ch"
#include "msobject.ch"
#INCLUDE "parmtype.CH"


User Function INNWebCls(aEmpr,aDirTemp)

    Local oError        := nil
    Local dDtRef        := Date()-2
    Local nX
    Local nCount

    Local aFiles := {} // O array receberá os nomes dos arquivos e do diretório
    Local aSizes := {} // O array receberá os tamanhos dos arquivos e do diretorio
    Local aDatas := {}
    
    DEFAULT aEmpr := {"01","01"}

    SET CENTURY ON
    Set(_SET_DATEFORMAT, "dd/mm/yyyy")

    oError := ErrorBlock({|e| conout("* INNWebCls - ErrorBlock ") })

    Begin Sequence

        //Listar diretorio (aDirTemp[1])
        //apagar os arquivos com data anterior a now-1

        ADir(aDirTemp[1]+"\*.*", aFiles, aSizes, aDatas)

        nCount := Len( aFiles )
        For nX := 1 to nCount
            //ConOut( 'Arquivo: ' + aFiles[nX] + ' - Size: ' + AllTrim(Str(aSizes[nX]) + ' - De: ' + dtoc(aDatas[nX])) )
            if aDatas[nX] <= dDtRef
                lRet := (FErase( aDirTemp[1] + aFiles[nX] ) == -1)
                //ConOut("Deletando: "+aDirTemp[1] + aFiles[nX]+iif(lRet," Sucesso!"," Erro!"))
            endif
        Next nX

    End Sequence

    ErrorBlock(oError)

Return
