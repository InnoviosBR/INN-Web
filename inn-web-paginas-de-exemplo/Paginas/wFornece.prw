#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wFornece(oINNWeb)

	xID	:= Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))
	
	if xID > 0			
		oBrowseSA2 := INNWebBrowse():New( oINNWeb )
		oBrowseSA2:SetTabela( "SA2" )
		oBrowseSA2:SetRec( xID )
		oINNWeb:SetTitNot("Dados detalhados do fornecedor")
	else		   
		fPesquisa(@oINNWeb)
	endif
			
	oINNWeb:SetTitle("Fornecedores") 
	oINNWeb:SetIdPgn("wFornece")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
	
	Local cCodigo	:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")		
	Local cNome		:= iif(Valtype(HttpGet->nome) == "C" .and. !empty(HttpGet->nome),HttpGet->nome,"")		
	Local cCGC		:= iif(Valtype(HttpGet->cgc) == "C" .and. !empty(HttpGet->cgc),HttpGet->cgc,"")
		
	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'codigo','Código'     ,15,cCodigo,.F.} )
	oINNWebParam:addText( {'nome'  ,'Nome'       ,50,cNome  ,.F.} )
	oINNWebParam:addText( {'cgc'   ,'CNPJ ou CPF',18,cCGC   ,.F.} )
	
	if !empty(cCodigo) .or. !empty(cNome) .or. !empty(cCGC)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Código"			,"C","",.T.})
		oINNWebTable:AddHead({"Loja"			,"C",""})
		oINNWebTable:AddHead({"Nome"			,"C",""})
		oINNWebTable:AddHead({"CNPJ/CPF"		,"C",""})
		oINNWebTable:AddHead({"Telefone"		,"C",""})
		oINNWebTable:AddHead({"Endereço"		,"C",""})
		oINNWebTable:AddHead({"Bairro"			,"C",""})
		oINNWebTable:AddHead({"Município"		,"C",""})
		oINNWebTable:AddHead({"Estado"			,"C",""})
		oINNWebTable:AddHead({"CEP"				,"C",""})
		oINNWebTable:AddHead({"EMail"			,"C",""})
		oINNWebTable:AddHead({"Insc. Estadual"	,"C",""})
		oINNWebTable:AddHead({"Insc. Municipal"	,"C",""})

		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

		_cQuery := ""
		IF !Empty(cCodigo)
			_cQuery += " AND A2_COD = '"+Alltrim(cCodigo)+"' "
		ENDIF
		IF !Empty(cNome)
			_cQuery += " AND A2_NOME like '%"+Upper(Alltrim(cNome))+"%' "
		ENDIF
		IF !Empty(cCGC)
			_cQuery += " AND A2_CGC like '%"+Alltrim(cCGC)+"%' "
		ENDIF
		_cQuery := '%'+_cQuery+'%'
		
		BeginSql alias 'TMP'
			SELECT A2_COD, A2_LOJA, A2_NOME, A2_CGC, A2_INSCR, 
			       A2_INSCRM, A2_CEP, A2_END, A2_BAIRRO, A2_MUN, A2_EST, A2_DDD, A2_TEL, A2_EMAIL, R_E_C_N_O_ 'REGISTRO' 
			FROM %table:SA2% SA2
			WHERE A2_FILIAL = %xfilial:SA2% 
			      %exp:_cQuery%
			  AND SA2.%notDel% 
			ORDER BY A2_COD , A2_LOJA 
		EndSql  

		DbSelectArea("TMP")
		TMP->(dbGoTop())
			
		WHILE (TMP->(!EOF()))
				
			oINNWebTable:AddCols({	TMP->A2_COD,;
									TMP->A2_LOJA,;
									TMP->A2_NOME,;
									fmcgc(TMP->A2_CGC),;
									fmtel(TMP->A2_DDD+TMP->A2_TEL ),;
									TMP->A2_END,;
									TMP->A2_BAIRRO,;
									TMP->A2_MUN,;
									TMP->A2_EST,;
									fmcep(TMP->A2_CEP),;
									TMP->A2_EMAIL,;
									TMP->A2_INSCR,;
									TMP->A2_INSCRM})

			oINNWebTable:SetLink(  , 1 , "?x=wFornece&xID="+cValToChar(TMP->REGISTRO) )
		
			TMP->(DbSkip())
	
		ENDDO  
					
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 
			
	endif

Return
