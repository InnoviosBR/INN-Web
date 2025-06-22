#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wExplorer()

	//Local cTitulo	:= "Arquivos anexados"

	Local aDirTemp := aClone(oINNWeb:aDirTemp)

	oINNWeb:aDirTemp[4] += "explorer\"
	oINNWeb:aDirTemp[5] += "explorer\"
	oINNWeb:aDirTemp[6] += "explorer/"
		
	cForm     	:= iif(Valtype(HttpGet->form) == "C" .and. !empty(HttpGet->form),HttpGet->form,"")
	cTipo	    := iif(Valtype(HttpGet->Tipo) == "C" .and. !empty(HttpGet->Tipo),HttpGet->Tipo,"")
	cDocumento	:= iif(Valtype(HttpGet->Documento) == "C" .and. !empty(HttpGet->Documento),HttpGet->Documento,"")
	cSimples	:= iif(Valtype(HttpGet->Simples) == "C" .and. !empty(HttpGet->Simples),HttpGet->Simples,"")
							
	Do Case
	
		Case cForm == "delet"
			fDelet()

		Case cForm == "deletaHTML"
			fDelet()
			oINNWeb:cHTMLSub := ""
			fBrowse(cTipo,cDocumento)
			oINNWeb:AddHeadBtn({"wExplorer","form=limpa","Limpeza"})
			
		Case cForm == "json"
			fJson()
			
		Case cForm == "update"
			fUpdate()

		Case cForm == "limpa"
			fLimpa()

		Case !Empty(cTipo) .and. !Empty(cDocumento)
			oINNWeb:lSimpPG := !Empty(cSimples)
			fUpload(cTipo,cDocumento)

		OtherWise
			fBrowse(cTipo,cDocumento)
			oINNWeb:AddHeadBtn({"wExplorer","form=limpa","Limpeza"})
					
	End Case

	oINNWeb:aDirTemp := aClone(aDirTemp)
	
Return(.T.)

Static Function fDelet()

	Local cStatus    := "400"
	Local cMensagem  := ""
	Local cID      := iif(Valtype(httpGet->ID) == "C" .and. !empty(httpGet->ID),httpGet->ID,"")
        
	if !Empty(cID)
	
		dbSelectArea("INN003")
		INN003->(dbSetOrder(2))
		if INN003->(dbSeek(cID))

			PswOrder(1)//1 - ID do usuário/grupo
			PswSeek( oINNWeb:UserID, .T. )  
			cUsuario := PswRet()[1][2]
			
			RecLock("INN003",.F.)
				Replace USIEXCL 	with cUsuario
				Replace DTIEXCL 	with Date()
				Replace HRIEXCL 	with TimeFull()
			MsUnlock("INN003") 

			RecLock("INN003",.F.) 
				dbDelete()
			MsUnLock("INN003")
			
			cStatus := "200"
			cMensagem := "arquivo deletado"
						
			//fLimpa()
			
		else
		
			cStatus := "402"
		
		endif
		
	else
	
		cStatus := "401"
								
	endif
	
	cHTML := ''
	cHTML += '{'
	cHTML += '"STATUS":"'+cStatus+'"'
	cHTML += ','
	cHTML += '"MENSAGEM":"'+cMensagem+'"'
	cHTML += '}'
	
	oINNWeb:SetHtml(cHTML)
	
Return

Static Function fJson()
	
Return

Static Function fUpdate()

	Local cStatus    := "400"
	Local cMensagem  := ""
	Local cTipo      := iif(Valtype(httpPost->Tipo) == "C" .and. !empty(httpPost->Tipo),httpPost->Tipo,"DIM")
	Local cDocumento := iif(Valtype(httpPost->Documento) == "C" .and. !empty(httpPost->Documento),httpPost->Documento,"")
	
	cDocumento := Alltrim(UPPER(cDocumento))
	
	IF Len(cDocumento) > 35
		cDocumento := MD5(cDocumento,2)
	ENDIF
        
	if ValType(httpPost->file) == "C"   
			
		cOrig := httpPost->file		
		cOrig := SubStr(cOrig,RAT("\",cOrig)+1,Len(cOrig))
		cExt  := SubStr(cOrig,RAT(".",cOrig)+1,Len(cOrig))

		cDirUP  := oINNWeb:aDirTemp[3]
		cDirRp  := oINNWeb:aDirTemp[4]
		
		cId  :=  CriaTrab( NIL, .F. ) 
		cId  :=  SubStr(cId,3,Len(cId))
		cDest := cId + "." + cExt
		
		PswOrder(1)//1 - ID do usuário/grupo
		PswSeek( oINNWeb:UserID, .T. )  
		cUsuario := PswRet()[1][2]
				
		if !( lower(cExt) $ "pdf/xls/xlsx/csv/doc/docx/txt/zip/rar/png/jpg/gif/log" )

			cStatus := "401" 
			cMensagem := "Extencao de arquivo invalida!"
					
		else
				
			if FRENAME ( cDirUP + cOrig , cDirRp + cDest ) == -1

				cStatus := "402" 
				cMensagem := "Erro ao abrir o arquivo!"
			   
			else
			   	
		   		cMD5 := MD5File( oINNWeb:aDirTemp[5] + alltrim(cId) + "." + cExt ,2,1) 

				dbSelectArea("INN003")
				INN003->(dbSetOrder(3))
				//if INN003->(dbSeek(cMD5))

					//cStatus := "403" 
					//cMensagem := "Esse arquivo ja existe!"
				
				//else
		
					RecLock("INN003",.T.) 
						Replace TIPO    	with cTipo
						Replace DOC     	with Alltrim(Upper(cDocumento))
						Replace BMPID   	with cId
						Replace BMPNAME 	with cDest 
				 		Replace USINCLU 	with cUsuario
						Replace DTINCLU 	with Date()
						Replace HRINCLU 	with TimeFull()
						Replace BMPEXT  	with cExt
						Replace BMPURL  	with oINNWeb:aDirTemp[6] + cDest
						Replace BMPMD5  	with cMD5
						Replace BMPDIR  	with oINNWeb:aDirTemp[5] + alltrim(cId) +"."+ cExt
						Replace NOMEORIG 	with cOrig
					MsUnLock("INN003")
					
					cStatus := "200"
					
					//fLimpa()
					
				//endif

			endif
	
		endif
		
	endif
	
	
	cHTML := ''
	cHTML += '{'
	cHTML += '"STATUS":"'+cStatus+'"'
	cHTML += ','
	cHTML += '"MENSAGEM":"'+cMensagem+'"'
	//cHTML += ','
	//cHTML += '"ORIGEM":"'+cDirUP + cOrig+'"'
	//cHTML += ','
	//cHTML += '"DESTINO":"'+cDirRp + cDest+'"'
	cHTML += '}'
	
	oINNWeb:SetHtml(cHTML)
	
Return

Static Function fLimpa() 


	   
	Local aDir	 := {}
	Local nY



	oINNWebTable := INNWebTable():New( oINNWeb )
	oINNWebTable:AddHead({"ID"			,"C",""})
	oINNWebTable:AddHead({"Nome Original"	,"C",""})
	oINNWebTable:AddHead({"MD5"			,"C",""})
	oINNWebTable:AddHead({"Status"		,"C",""})







	
	//Primeira parte, olha para o diretorio
	//Lista o diretorio e entra encontrar o id no banco de dados
	//Se achar atualiza o tamanho
	//Se não achar move para a lixeira
	aDir := Directory(oINNWeb:aDirTemp[4]+"*.*")
	
	for nY := 1 To Len(aDir)
			
		cIdFoto := aDir[nY,1]
		cIdFoto := SubStr(cIdFoto,RAT("\",cIdFoto)+1,Len(cIdFoto))
		cIdFoto := SubStr(cIdFoto,1,RAT(".",cIdFoto)-1)
	
	    dbSelectArea("INN003")
		INN003->(dbSetOrder(2))
		if INN003->(dbSeek(cIdFoto))

			RecLock("INN003",.F.) 
				Replace BMPSIZE  with aDir[nY,2]
			MsUnLock("INN003") 	  
							
		else
			
			//oINNWeb:AddCallOut("O arquivo: "+aDir[nY,1] + " foi movido para a lixeira!<br>Aviso: 001","warning")
			
			//FRENAME ( oINNWeb:aDirTemp[4] + aDir[nY,1] ,oINNWeb:aDirTemp[4] + "\lixo\" + aDir[nY,1] )

			cMd5 := MD5File(oINNWeb:aDirTemp[4] + aDir[nY,1],2,1) 

			oINNWebTable:AddCols({	aDir[nY,1],;
									aDir[nY,1],;
									cMd5,;
									"Arquivo existe apenas fisicamente"})
						

			nDeletados := MpSysExecScalar(ChangeQuery(" SELECT COUNT(*) AS DELETADOS FROM INN003 WHERE UPPER(BMPNAME) = '"+Upper(Alltrim(aDir[nY,1]))+"' AND D_E_L_E_T_ = '*' "),"DELETADOS")
			
			if nDeletados > 0	
				oINNWebTable:SetValue( nLinha , 4 , oINNWebTable:GetValue( nLinha , 4 )  + ". Existem "+cValToChar(nDeletados)+" referencias deletadas manualmente para esse arquivo" )
			endif
			
		endif	
		
	next











	
	//Segunda parte, olha para o banco de dados
	//Lista o banco inteiro e tenta criar um MD5 do arquivo, se o arquivo não existir ou estiver corrompido, deleta o registro
    dbSelectArea("INN003")
	INN003->(dbSetOrder(1))
	INN003->(dbGoTOp())  	
	
	while !( INN003->(EOF()) )
		

		if File( Alltrim(oINNWeb:aDirTemp[5]) + alltrim(INN003->BMPID) + "." + Alltrim(INN003->BMPEXT) , 1 )
			
			cMd5 := Alltrim(oINNWeb:aDirTemp[5]) + alltrim(INN003->BMPID) + "." + Alltrim(INN003->BMPEXT)
			cMd5 := MD5File(cMd5,2,1) 

			if Empty(cMd5)
				oINNWebTable:AddCols({	alltrim(INN003->BMPID) + "." + Alltrim(INN003->BMPEXT),;
										INN003->NOMEORIG,;
										INN003->BMPMD5,;
										"Impossovivel criar MD5"})
			else
				RecLock("INN003",.F.) 
					Replace BMPMD5   with cMd5
				MsUnLock("INN003") 
			endif

		else

				oINNWebTable:AddCols({	alltrim(INN003->BMPID) + "." + Alltrim(INN003->BMPEXT),;
										INN003->NOMEORIG,;
										INN003->BMPMD5,;
										"Arquivo não encontrado"})

		endif
        
	  INN003->(dbSkip())

	enddo 











	
	oINNWeb:SetTitle("Explorer - Limpeza") 
	oINNWeb:SetIdPgn("wExplorer")
		
Return

Static Function fBrowse(cTipo,cDocumento)




	oINNWebTable := INNWebTable():New( oINNWeb )
	oINNWebTable:AddHead({""				,"C","",.T.})
	oINNWebTable:AddHead({"ID"				,"C","",.T.})
	oINNWebTable:AddHead({"Nome Original"	,"C",""})
	oINNWebTable:AddHead({"Data"			,"D",""})
	oINNWebTable:AddHead({"Hora"			,"C",""})
	oINNWebTable:AddHead({"Usuario"			,"C",""})
	oINNWebTable:AddHead({"Tipo"			,"C",""})
	oINNWebTable:AddHead({"Documento"		,"C",""})
	oINNWebTable:AddHead({"Tamanho (MB)"	,"N","@E 99,999,999,999.99"})
	oINNWebTable:AddHead({""				,"C","",.T.})

	if select("TMP003") <> 0
		TMP003->(dbCloseArea())
	endif
		
	cQuery := " SELECT * FROM INN003 WHERE D_E_L_E_T_ = '' "
	if !Empty(cTipo)
		cQuery += " AND TIPO = '"+cTipo+"'"
	endif
	if !Empty(cDocumento)
		cQuery += " AND DOC = '"+cDocumento+"'"
	endif
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMP003",.F.,.T.)
	
	DbSelectArea("TMP003")
	TMP003->(dbGoTop())

	WHILE (TMP003->(!EOF()))
		
		oINNWebTable:AddCols({	oINNWeb:fIcon(TMP003->BMPEXT),;
								TMP003->BMPID,;
								TMP003->NOMEORIG,;
								sTod(TMP003->DTINCLU),;
								TMP003->HRINCLU,;
								TMP003->USINCLU,;
								TMP003->TIPO,;
								TMP003->DOC,;
								Round((TMP003->BMPSIZE/1024)/1024,2),;
								"<i class='fas fa-trash-alt'></i>"})
					
		oINNWebTable:SetLink(  ,  1 , {Alltrim(TMP003->BMPURL),"_blank"} )
		oINNWebTable:SetLink(  ,  2 , {Alltrim(TMP003->BMPURL),"_blank"} )
		oINNWebTable:SetLink(  , 10 , "?x=wExplorer&form=deletaHTML&ID="+Alltrim(TMP003->BMPID) )
		
		TMP003->(dbSkip())
		
	Enddo  
	
	if select("TMP003") <> 0
		TMP003->(dbCloseArea())
	endif 
	

	

	oINNWeb:SetTitle("Explorer") 
	oINNWeb:SetIdPgn("wExplorer")
	//oINNWeb:ExecMonta()

Return

Static Function fUpload(cTipo,cChave)

	Local INNWebAnexo := INNWebAnexo():New(oINNWeb)

	INNWebAnexo:SetChave(cChave)
	INNWebAnexo:SetTipo(cTipo)
	INNWebAnexo:GetArquivos()
	INNWebAnexo:Upload()

Return
