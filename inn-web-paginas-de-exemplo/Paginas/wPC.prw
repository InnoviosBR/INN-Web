#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH" 
#Include "RPTDEF.CH"

User Function wPC(oINNWeb)

	Local xID	:= val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,"0"))
	
	if xID > 0
		oTableSC7 := INNWebTable():New( oINNWeb )
		oTableSC7:SimpleX3Table( "SC7",1, " SC7->C7_FILIAL == '"+xFilial("SC7")+"' .AND. SC7->C7_NUM == '"+xID+"' " )
		oTableSC7:Setlength(.F.)
		oINNWeb:SetTitNot("Dados detalhados do Pedido de Compras")
	else		   
		fPesquisa(@oINNWeb)  
	endif
				
	oINNWeb:SetTitle("Pedido de Compra") 
	oINNWeb:SetIdPgn("wPC")

Return(.T.) 

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""     
	
	Local cNumPC	:= iif(Valtype(HttpGet->NumPC) == "C" .and. !empty(HttpGet->NumPC),HttpGet->NumPC,"")		
	Local cCodigo	:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")
	Local cForne	:= iif(Valtype(HttpGet->Forne) == "C" .and. !empty(HttpGet->Forne),HttpGet->Forne,"")		
	Local cLoja		:= iif(Valtype(HttpGet->Loja) == "C" .and. !empty(HttpGet->Loja),HttpGet->Loja,"")
	Local dInicio	:= cTod(iif(Valtype(HttpGet->inicio) == "C" .and. !empty(HttpGet->inicio),HttpGet->inicio,""))
	Local dFim		:= cTod(iif(Valtype(HttpGet->fim) == "C" .and. !empty(HttpGet->fim),HttpGet->fim,""))

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'NumPC'	,'Numero'		, 6,cNumPC	,.F.})
	oINNWebParam:addText( {'codigo'	,'Produto'		,15,cCodigo	,.F.})		
	oINNWebParam:addText( {'Forne'	,'Fornecedor'	, 6,cForne	,.F.})
	oINNWebParam:addText( {'Loja'	,'Loja'			,15,cLoja	,.F.})		
	oINNWebParam:addData( {'inicio'	,'Inicio'		,dInicio	,.F.})		
	oINNWebParam:addData( {'fim'	,'Fim'			,dFim		,.F.})	

	if  !empty(cNumPC) .or. !empty(cCodigo)  .or.  !empty(cForne) .or. !empty(cLoja) .or. ( !empty(dInicio) .and. !empty(dFim) )

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({""				,"C",""})	
		oINNWebTable:AddHead({"Número PC"		,"C","",.T.})
		oINNWebTable:AddHead({"Item"			,"C",""})
		oINNWebTable:AddHead({"Fornecedor"		,"C",""})
		oINNWebTable:AddHead({"Loja"			,"C",""})
		oINNWebTable:AddHead({"Nome"			,"C",""})
		oINNWebTable:AddHead({"Emissao"			,"D",""})
		oINNWebTable:AddHead({"Dt. Entrega"		,"D",""})
		oINNWebTable:AddHead({"Produto"			,"C",""})
		oINNWebTable:AddHead({"Descrição"		,"C",""})
		oINNWebTable:AddHead({"Observacoes"		,"C",""})
		oINNWebTable:AddHead({"Quantidade"		,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Valor"			,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Valor Total"		,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Quant. Entregue"	,"N","@E 99,999,999,999.999",.T.})
		oINNWebTable:AddHead({"NF Entrada"		,"C",""})
		oINNWebTable:AddHead({"Status"			,"C",""})
		oINNWebTable:AddHead({"Comprador"		,"C",""})
		oINNWebTable:AddHead({"Número SC"		,"C","",.T.})

		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

		_cQuery := ""
		IF !Empty(cNumPC)
			_cQuery += " AND C7_NUM = '"+Alltrim(cNumPC)+"' "
		ENDIF
		IF !Empty(cCodigo)
			_cQuery += " AND C7_PRODUTO = '"+Alltrim(cCodigo)+"' "
		ENDIF 
		IF !Empty(cForne)
			_cQuery += " AND C7_FORNECE = '"+Alltrim(cForne)+"' "
		ENDIF
		IF !Empty(cLoja)
			_cQuery += " AND C7_LOJA = '"+Alltrim(cLoja)+"' "
		ENDIF
		if !empty(dInicio)
			_cQuery += " AND C7_EMISSAO >= '"+dTos(dInicio)+"' "
		endif
		if !empty(dFim)
			_cQuery += " AND C7_EMISSAO <= '"+dTos(dFim)+"' "
		endif
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			column C7_EMISSAO as Date
			column C7_DATPRF as Date
			SELECT C7_NUM, C7_NUMSC, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_QUANT, C7_PRECO, C7_EMISSAO, C7_TOTAL, C7_QUJE,
					C7_FORNECE, C7_ITEMCTA, C7_CC, C7_LOJA,C7_TIPO,C7_RESIDUO,C7_ACCPROC,C7_CONAPRO,C7_CONTRA,C7_QTDACLA,
					C7_COMPRA,C7_DATPRF,SC7.R_E_C_N_O_ 'REGISTRO',C7_OBSM
			FROM %table:SC7% SC7 
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1% AND C7_PRODUTO = B1_COD
			WHERE SC7.C7_FILIAL = %xfilial:SC7% 
			%exp:_cQuery%
			AND SC7.%notDel% 
			AND SB1.%notDel% 
			ORDER BY C7_NUM , C7_ITEM  
		EndSql
					
		WHILE (TMP->(!EOF()))
		
			cStatus := u_wPcStatus("TMP",)
			cCor := u_wPcStatus("TMP","2")
				
			oINNWebTable:AddCols({	oINNWeb:LoadBitmap(cCor),;
									TMP->C7_NUM,;
									TMP->C7_ITEM,;
									TMP->C7_FORNECE,;
									TMP->C7_LOJA,;
									POSICIONE("SA2",1,xFilial("SA2")+TMP->C7_FORNECE+TMP->C7_LOJA,"A2_NOME"),;
									TMP->C7_EMISSAO,;
									TMP->C7_DATPRF,;
									TMP->C7_PRODUTO,;
									TMP->C7_DESCRI,;
									Alltrim(TMP->C7_OBSM),;
									TMP->C7_QUANT,;
									TMP->C7_PRECO,;
									TMP->C7_TOTAL,;
									TMP->C7_QUJE,;
									POSICIONE("SD1",13,xFilial("SD1")+TMP->C7_PRODUTO+TMP->C7_NUM,"D1_DOC"),;
									cStatus,;
									TMP->C7_COMPRA,;
									TMP->C7_NUMSC})
                                               
			oINNWebTable:SetLink(  , 2  , {"?x=wPC&xID="+cValToChar(TMP->C7_NUM),"u_wPC"+TMP->C7_NUM} )
			oINNWebTable:SetLink(  , 15 , {"?x=wNFEntrada&pedido="+TMP->C7_NUM+"&produto="+TMP->C7_PRODUTO,Alltrim(TMP->C7_NUM)+Alltrim(TMP->C7_PRODUTO)} )
		    oINNWebTable:SetLink(  , 19 , {"?NumSC="+TMP->C7_NUMSC+"&gerar=sim&x=wSC",TMP->C7_NUMSC} )
	
			TMP->(DbSkip())
	
		ENDDO  
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 
			
	endif

Return

User Function wPcStatus(cAlias,cTipo)

	Local nTipoPed	:= 1
	Local cStatus   := ""
	Local cCor := "BR_CINZA"
	Default cTipo = "1"

	Do Case
		Case (cAlias)->C7_TIPO != nTipoPed                     
			cStatus := "Autorizacao de Entrega ou Pedido" //BR_PRETO -- Autorizacao de Entrega ou Pedido
			cCor := "BR_PRETO"
		Case !Empty((cAlias)->C7_RESIDUO)
			cStatus := "Eliminado por Residuo" // BR_CINZA -- Eliminado por Residuo
			cCor := "BR_CINZA"
		Case SC7->(FieldPos("C7_ACCPROC")) > 0 .and. (cAlias)->C7_ACCPROC<>"1" .And. (cAlias)->C7_CONAPRO=="B" .And. (cAlias)->C7_QUJE < (cAlias)->C7_QUANT
			cStatus := "Bloqueado" //BR_AZUL -- Bloqueado
			cCor := "BR_AZUL"
		Case SC7->(FieldPos("C7_ACCPROC")) <= 0 .and. (cAlias)->C7_CONAPRO=="B" .And. (cAlias)->C7_QUJE < (cAlias)->C7_QUANT
			cStatus := "Bloqueado" //BR_AZUL -- Bloqueado
			cCor := "BR_AZUL"
		Case nTipoPed == 1 .and. !Empty((cAlias)->C7_CONTRA) .And. Empty((cAlias)->C7_RESIDUO)
			cStatus := "Integracao com o Modulo de Gestao de Contratos" //BR_BRANCO -- Integracao com o Modulo de Gestao de Contratos
			cCor := "BR_BRANCO"
		Case nTipoPed == 1 .and. !Empty((cAlias)->C7_CONTRA) .And. Empty((cAlias)->C7_RESIDUO) .and. SC7->(FieldPos("C7_ACCPROC")) > 0 .and. (cAlias)->C7_ACCPROC=="1"
			cStatus := "Integracao com o portal marketplace" //PMSEDT2 -- Integracao com o portal marketplace
			cCor := "PMSEDT2"
		Case (cAlias)->C7_QUJE == 0 .And. (cAlias)->C7_QTDACLA==0
			cStatus := "Pendente" //ENABLE -- Pendente
			cCor := "BR_VERMELHO"
		Case (cAlias)->C7_QUJE <> 0 .And. (cAlias)->C7_QUJE < (cAlias)->C7_QUANT
			cStatus := "Parcialmente Atendido" //BR_AMARELO -- Pedido Parcialmente Atendido
			cCor := "BR_AMARELO"
		Case (cAlias)->C7_QUJE >= (cAlias)->C7_QUANT
			cStatus := "Atendido" //DISABLE -- Pedido Atendido
			cCor := "DISABLE"
		Case (cAlias)->C7_QTDACLA > 0
			cStatus := "Usado em Pre-Nota" //BR_LARANJA -- Pedido Usado em Pre-Nota
			cCor := "BR_LARANJA"
		OtherWise
			cStatus := "?"
			cCor := ""
	EndCase
	
Return(iif(cTipo=="2",cCor,cStatus))
