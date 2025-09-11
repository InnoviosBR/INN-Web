#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wSC(oINNWeb)

	Local xID := iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,"")  

	if !Empty(xID)
		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:SimpleX3Table( "SC1",1, " SC1->C1_FILIAL == '"+xFilial("SC1")+"' .AND. SC1->C1_NUM == '"+xID+"' " )
		oINNWebTable:SetSimple()
	else
		fPesquisa(@oINNWeb)
	endif

	oINNWeb:SetTitle("Solicitação de Compra") 
	oINNWeb:SetIdPgn("wSC")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
		
	Local cNumSC	:= iif(Valtype(HttpGet->NumSC) == "C" .and. !empty(HttpGet->NumSC),HttpGet->NumSC,"")		
	Local cCodigo	:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")
	Local cSolic	:= iif(Valtype(HttpGet->solic) == "C" .and. !empty(HttpGet->solic),HttpGet->solic,"")	
	Local dInicio	:= cTod(iif(Valtype(HttpGet->inicio) == "C" .and. !empty(HttpGet->inicio),HttpGet->inicio,""))
	Local dFim		:= cTod(iif(Valtype(HttpGet->fim) == "C" .and. !empty(HttpGet->fim),HttpGet->fim,""))
	Local cOP  		:= iif(Valtype(HttpGet->op) == "C" .and. !empty(HttpGet->op),HttpGet->op,"")	
	Local cUniReq	:= iif(Valtype(HttpGet->UniReq) == "C" .and. !empty(HttpGet->UniReq),HttpGet->UniReq,"")		

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'NumSC'	,'Numero'		, 6,cNumSC	,.F.})
	oINNWebParam:addText( {'codigo'	,'Produto'		,15,cCodigo	,.F.})
	oINNWebParam:addText( {'solic'	,'Solicitante'	,20,cSolic	,.F.})
	oINNWebParam:addCombo( {'UniReq','Unidade requisitante',cUniReq,fBuscaUniReq(),.F.})
	oINNWebParam:addData( {'inicio'	,'Inicio'	,dInicio,.F.})
	oINNWebParam:addData( {'fim'	,'Fim'		,dFim	,.F.})
	
	if !empty(cNumSC) .or. !empty(cCodigo) .or. !empty(cSolic) .or. !empty(cOP) .or. ( !empty(dInicio) .and. !empty(dFim) ) .or. !Empty(cUniReq)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({""				,"C",""})	
		oINNWebTable:AddHead({"Número"			,"C","",.T.})
		oINNWebTable:AddHead({"Item"			,"C",""})
		oINNWebTable:AddHead({"Produto"			,"C",""})
		oINNWebTable:AddHead({"Descrição"		,"C",""})
		oINNWebTable:AddHead({"Almoxarifado"	,"C",""})
		oINNWebTable:AddHead({"Solicitante"		,"C",""})
		oINNWebTable:AddHead({"Emissão"			,"D",""})
		oINNWebTable:AddHead({"Necessidade"		,"D",""})
		oINNWebTable:AddHead({"Quantidade"		,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Quant. Entregue"	,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Ord Producao"	,"C",""})
		oINNWebTable:AddHead({"Centro Custo"	,"C",""})
		oINNWebTable:AddHead({"Item Contabil"	,"C",""})
		oINNWebTable:AddHead({"Obs"				,"C",""})
		oINNWebTable:AddHead({"Pedico Compra"	,"C","",.T.})
		oINNWebTable:AddHead({"NF Entrada"		,"C","",.T.})
		oINNWebTable:AddHead({"Status"			,"C",""})
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		IF !Empty(cNumSC)
			_cQuery += " AND C1_NUM = '"+Alltrim(cNumSC)+"' "
		ENDIF
		IF !Empty(cCodigo)
			_cQuery += " AND C1_PRODUTO = '"+Alltrim(cCodigo)+"' "
		ENDIF
		IF !Empty(cUniReq)
			_cQuery += " AND C1_UNIDREQ = '"+Alltrim(cUniReq)+"' "
		ENDIF
		if !Empty(dInicio)
			_cQuery += " AND C1_EMISSAO >= '"+dTos(dInicio)+"' "
		endif
		if !Empty(dFim)
			_cQuery += " AND C1_EMISSAO <= '"+dTos(dFim)+"' "
		endif
		if !Empty(cSolic)
			_cQuery += " AND UPPER(C1_SOLICIT) LIKE '%"+Alltrim(upper(cSolic))+"%' "
		endif
		if !Empty(cOP)
			_cQuery += " AND C1_OP LIKE '%"+Alltrim(cOP)+"%' "
		endif
		_cQuery := '%'+_cQuery+'%'
	
		BeginSql alias 'TMP'
			SELECT
				C1_NUM,
				C1_ITEM,
				C1_PRODUTO,
				B1_DESC,
				C1_QUANT,
				C1_LOCAL,
				C1_EMISSAO,
				C1_QUJE,
				C1_OBS,
				C1_DATPRF,
				C1_SOLICIT,
				C1_PEDIDO,
				C1_OP,
				C1_ITEMPED,
				C1_COTACAO,
				C1_FLAGGCT,
				C1_TIPO,
				C1_RESIDUO,
				C1_QUJE,
				C1_APROV,
				C1_TPSC,
				C1_IMPORT,
				C1_CC,
				C1_ITEMCTA
			FROM %table:SB1% SC1
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1% AND C1_PRODUTO = B1_COD 
			WHERE SC1.C1_FILIAL = %xfilial:SC1%
			AND SC1.%notDel%
			AND SB1.%notDel%
			%exp:_cQuery%
			ORDER BY C1_NUM , C1_ITEM 
		EndSql

		DbSelectArea("SD1")		
		SD1->(dbSetOrder(14))
			
		WHILE (TMP->(!EOF()))
					
			aStatus := fStatus("TMP")
			cLnkNF  := ""

			if SD1->(dbSeek(xFilial("SD1")+TMP->C1_PEDIDO)) .and. !Empty(TMP->C1_PEDIDO)
				cLnkNF  := POSICIONE("SD1",14,xFilial("SD1")+TMP->C1_PEDIDO,"D1_DOC")
			endif

			oINNWebTable:AddCols({	oINNWeb:LoadBitmap(aStatus[2]),;
									TMP->C1_NUM,;
									TMP->C1_ITEM,;
									TMP->C1_PRODUTO,;
									TMP->B1_DESC,;
									TMP->C1_LOCAL,;
									TMP->C1_SOLICIT,;
									stod(TMP->C1_EMISSAO),;
									sTod(TMP->C1_DATPRF),;
									TMP->C1_QUANT,;
									TMP->C1_QUJE,;
									TMP->C1_OP,;
									TMP->C1_CC,;
									TMP->C1_ITEMCTA,;
									TMP->C1_OBS,;
									TMP->C1_PEDIDO + " - " + TMP->C1_ITEMPED,;
									cLnkNF,;
									aStatus[1]})

			oINNWebTable:SetLink(  , 2  , {"?x=wSC&xID="+TMP->C1_NUM,"WSC"+TMP->C1_NUM} )
			oINNWebTable:SetLink(  , 16 , {"?x=wPC&NumPC="+TMP->C1_PEDIDO,"WPC"+TMP->C1_PEDIDO} )
			oINNWebTable:SetLink(  , 17 , {"?x=wNFEntrada&pedido="+TMP->C1_PEDIDO,"WPC"+TMP->C1_PEDIDO} )
						
			TMP->(DbSkip())
	
		ENDDO  
				
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif
			
	endif

Return

Static Function fStatus(cAlias)

	Local lAProvSI   := GetNewPar("MV_APROVSI",.F.)
	Local aStatus := {}
	Local aTipos := {}
	
	aadd(aTipos,{"Totalmente Atendida pelo SIGAGCT"		,"BR_MARROM"})
	aadd(aTipos,{"Solicitacao de Importacao"			,"BR_BRANCO"})
	aadd(aTipos,{"Eliminada por Residuo"				,"BR_PRETO"})
	aadd(aTipos,{"Pedido Colocado"						,"DISABLE"})
	aadd(aTipos,{"Solicitacao para Licitacao"			,"LIGHTBLU"})
	aadd(aTipos,{"SC em Aberto"							,"ENABLE"})
	aadd(aTipos,{"SC Rejeitada"							,"BR_LARANJA"})
	aadd(aTipos,{"SC Bloqueada"							,"BR_CINZA"})
	aadd(aTipos,{"SC com Pedido Colocado Parcial"		,"BR_AMARELO"})
	aadd(aTipos,{"Solicitação em Processo de Edital"	,"PMSEDT4"})
	aadd(aTipos,{"SC em Processo de Cotacao"			,"BR_AZUL"})
	aadd(aTipos,{"SC com Produto Importado"				,"BR_PINK"})
	aadd(aTipos,{"?"									,"UNKNOWN"})

	Do Case
		Case (cAlias)->C1_FLAGGCT == "1" .And. (cAlias)->C1_QUJE < (cAlias)->C1_QUANT 
			aStatus := {"Totalmente Atendida pelo SIGAGCT","BR_MARROM"}  //BR_MARROM -- SC Totalmente Atendida pelo SIGAGCT
		Case SC1->(FieldPos("C1_TIPO"))>0 .AND. (cAlias)->C1_TIPO == 2 
			aStatus := {"Solicitacao de Importacao","BR_BRANCO"}  //BR_BRANCO -- Solicitacao de Importacao	
		Case !Empty((cAlias)->C1_RESIDUO) 
			aStatus := {"Eliminada por Residuo","BR_PRETO"}  //BR_PRETO -- SC Eliminada por Residuo
		Case (cAlias)->C1_QUJE == (cAlias)->C1_QUANT 
			aStatus := {"Pedido Colocado","DISABLE"}  //DISABLE -- SC com Pedido Colocado
		Case SC1->(FieldPos("C1_TPSC")) > 0 .AND. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_APROV $ " ,L" .And. (cAlias)->C1_TPSC == "2" 
			aStatus := {"Solicitacao para Licitacao","LIGHTBLU"}  //LIGHTBLU -- Solicitacao para Licitacao
		Case (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_APROV $ " ,L" 
			aStatus := {"SC em Aberto","BR_VERMELHO"}  //ENABLE -- SC em Aberto
		Case lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. ((cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .Or. (cAlias)->C1_COTACAO == "IMPORT") .And. (cAlias)->C1_APROV == "R" 
			aStatus := {"SC Rejeitada","BR_LARANJA"}  //BR_LARANJA -- SC Rejeitada
		Case lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. ((cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .Or. (cAlias)->C1_COTACAO == "IMPORT") .And. (cAlias)->C1_APROV == "B" 
			aStatus := {"SC Bloqueada","BR_CINZA"}  //BR_CINZA -- SC Bloqueada
		Case !lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_APROV == "R"
			aStatus := {"SC Rejeitada","BR_LARANJA"}  //BR_LARANJA -- SC Rejeitada
		Case !lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO == Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_APROV == "B"
			aStatus := {"SC Bloqueada","BR_CINZA"}  //BR_CINZA  -- SC Bloqueada
		Case (cAlias)->C1_QUJE > 0 
			aStatus := {"SC com Pedido Colocado Parcial","BR_AMARELO"}  //BR_AMARELO -- SC com Pedido Colocado Parcial                         
		Case (cAlias)->C1_TPSC == "2" .And. (cAlias)->C1_QUJE == 0 .And. !Empty((cAlias)->C1_CODED) 
			aStatus := {"Solicitação em Processo de Edital","PMSEDT4"}  // PMSEDT4 -- Solicitação em Processo de Edital
		Case (cAlias)->C1_TPSC != "2" .And. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO <> Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_IMPORT <>"S" 
			aStatus := {"SC em Processo de Cotacao","BR_AZUL"}  //BR_AZUL -- SC em Processo de Cotacao
		Case lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO <> Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_IMPORT == "S" .And. (cAlias)->C1_APROV $ " ,L" 
			aStatus := {"SC com Produto Importado","BR_PINK"}  //BR_PINK -- SC com Produto Importado
		Case !lAprovSI .AND. (cAlias)->C1_QUJE == 0 .And. (cAlias)->C1_COTACAO <> Space(Len((cAlias)->C1_COTACAO)) .And. (cAlias)->C1_IMPORT == "S" 
			aStatus := {"SC com Produto Importado","BR_PINK"}  // BR_PINK -- SC com Produto Importado
		OtherWise
			aStatus := {"?","UNKNOWN"}
	EndCase
	
Return(aStatus)

Static Function fBuscaUniReq()

	Local aUniReq := {}
	Local _cQuery := " SELECT Y3_COD,Y3_DESC FROM "+RetSQLName("SY3")+" WHERE Y3_FILIAL = '"+xFilial("SY3")+"' AND D_E_L_E_T_ != '*'  "
			
	if select("TMP") <> 0
		TMP->(dbCloseArea())
	endif 
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,_cQuery),"TMP",.F.,.T.)
	
	DbSelectArea("TMP")
	TMP->(dbGoTop())

	WHILE (TMP->(!EOF()))
		aadd(aUniReq,{Alltrim(TMP->Y3_COD),TMP->Y3_COD + " - " + TMP->Y3_DESC })
		TMP->(DbSkip())
	ENDDO
	
	if select("TMP") <> 0
		TMP->(dbCloseArea())
	endif 

Return(aUniReq)
