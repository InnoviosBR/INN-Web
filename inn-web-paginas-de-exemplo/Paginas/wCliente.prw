#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wCliente(oINNWeb)

	Local xID	:= Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))
	
	if xID > 0			
		oBrowseSA1 := INNWebBrowse():New( oINNWeb )
		oBrowseSA1:SetTabela( "SA1" )
		oBrowseSA1:SetRec( xID )
		oINNWeb:SetTitNot("Dados detalhados do cliente")
	else		   
		fPesquisa(@oINNWeb)
	endif
			
	oINNWeb:SetTitle("Clientes") 
	oINNWeb:SetIdPgn("wCliente")
	
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

		IF !Empty(cCodigo)
			_cQuery += " AND A1_COD = '"+Alltrim(cCodigo)+"' "
		ENDIF
		IF !Empty(cNome)
			_cQuery += " AND A1_NOME like '%"+Upper(Alltrim(cNome))+"%' "
		ENDIF
		IF !Empty(cCGC)
			_cQuery += " AND A1_CGC like '%"+Alltrim(cCGC)+"%' "
		ENDIF
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			SELECT 
			A1_COD, 
			A1_LOJA, 
			A1_NOME, 
			A1_PESSOA, 
			A1_CGC, 
			A1_INSCR, 
			A1_INSCRM, 
			A1_CEP, 
			A1_END, 	
			A1_BAIRRO, 
			A1_MUN, 
			A1_EST, 
			A1_DDD,  
			A1_TEL, 
			A1_EMAIL, 
			R_E_C_N_O_ 'REGISTRO' 
			FROM %table:SA1% SA1
			WHERE SA1.A1_FILIAL = %xfilial:SA1%
			AND SA1.%notDel% 
			%exp:_cQuery%
			ORDER BY A1_COD , A1_LOJA  
		EndSql
			
		WHILE (TMP->(!EOF()))
				
			oINNWebTable:AddCols({	TMP->A1_COD,;
									TMP->A1_LOJA,;
									TMP->A1_NOME,;
									fmcgc(TMP->A1_CGC),;
									fmtel(TMP->A1_DDD+TMP->A1_TEL ),;
									TMP->A1_END,;
									TMP->A1_BAIRRO,;
									TMP->A1_MUN,;
									TMP->A1_EST,;
									fmcep(TMP->A1_CEP),;
									TMP->A1_EMAIL,;
									TMP->A1_INSCR,;
									TMP->A1_INSCRM})

			oINNWebTable:SetLink(  , 1 , "?x=wCliente&xID="+cValToChar(TMP->REGISTRO) )
		
			TMP->(DbSkip())
	
		ENDDO  
					
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 
				
	endif

Return
