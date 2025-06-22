#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#INCLUDE "FWPrintSetup.ch"
#Include "RPTDEF.CH" 

User Function wNFSaida(oINNWeb)

	Local xID:= Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))
		
	if xID > 0
		fDetalhe(@oINNWeb,xID)
		oINNWeb:SetTitNot("Dados detalhados da NF Saida")
	else
		fPesquisa(@oINNWeb)
	endif
										
	oINNWeb:SetTitle("NF Saida") 
	oINNWeb:SetIdPgn("wNFSaida")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
		
	Local cDod		:= iif(Valtype(HttpGet->doc) == "C" .and. !empty(HttpGet->doc),HttpGet->doc,"")		
	Local cSerie	:= iif(Valtype(HttpGet->serie) == "C" .and. !empty(HttpGet->serie),HttpGet->serie,"")		
	Local cProd		:= iif(Valtype(HttpGet->produto) == "C" .and. !empty(HttpGet->produto),HttpGet->produto,"")
	Local cAlmox	:= iif(Valtype(HttpGet->almox) == "C" .and. !empty(HttpGet->almox),HttpGet->almox,"")
	Local cCliente	:= iif(Valtype(HttpGet->Cliente) == "C" .and. !empty(HttpGet->Cliente),HttpGet->Cliente,"")
	Local cLoja		:= iif(Valtype(HttpGet->Loja) == "C" .and. !empty(HttpGet->Loja),HttpGet->Loja,"")
	Local cTES		:= iif(Valtype(HttpGet->tes) == "C" .and. !empty(HttpGet->tes),HttpGet->tes,"")
	Local cCFOP		:= iif(Valtype(HttpGet->cfop) == "C" .and. !empty(HttpGet->cfop),HttpGet->cfop,"")
	Local cPV 		:= iif(Valtype(HttpGet->PV) == "C" .and. !empty(HttpGet->PV),HttpGet->PV,"")
	Local dInicio	:= cTod(iif(Valtype(HttpGet->inicio) == "C" .and. !empty(HttpGet->inicio),HttpGet->inicio,""))
	Local dFim		:= cTod(iif(Valtype(HttpGet->fim) == "C" .and. !empty(HttpGet->fim),HttpGet->fim,""))

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'doc'		,'Documento'	,9,cDod		,.F.} )		
	oINNWebParam:addText( {'serie'		,'Serie'		,3,cSerie	,.F.} )
	oINNWebParam:addText( {'produto'	,'Produto'		,15,cProd	,.F.} )
	oINNWebParam:addText( {'almox'		,'Armazem'		,2,cAlmox	,.F.} )		
	oINNWebParam:addText( {'Cliente'	,'Cliente'		,6,cCliente	,.F.} )
	oINNWebParam:addText( {'Loja'		,'Loja'			,2,cLoja	,.F.} )
	oINNWebParam:addText( {'tes'		,'TES'			,3,cTES		,.F.} )
	oINNWebParam:addText( {'cfop'		,'CFOP'			,4,cCFOP	,.F.} )
	oINNWebParam:addText( {'PV'			,'Pedido Venda'	,6,cPV		,.F.} )
	oINNWebParam:addData( {'inicio'		,'Inicio'		,dInicio,.F.} )
	oINNWebParam:addData( {'fim'		,'Fim'			,dFim	,.F.} )

	if !empty(cDod) .or. !empty(cSerie) .or. !empty(cProd) .or. !empty(cAlmox) .or. !empty(cCliente) .or. !empty(cLoja) .or. !empty(cTES) .or. !empty(cCFOP) .or. !empty(cPV) .or. ( !empty(dInicio) .and. !empty(dFim) ) 

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Documento"	,"C","",.T.})
		oINNWebTable:AddHead({"Serie"		,"C",""})
		oINNWebTable:AddHead({"Item"		,"C",""})
		oINNWebTable:AddHead({"Tipo"		,"C",""})
		oINNWebTable:AddHead({"Emissão"		,"D",""})
		oINNWebTable:AddHead({"Cliente"		,"C",""})
		oINNWebTable:AddHead({"Loja"		,"C",""})
		oINNWebTable:AddHead({"Nome"		,"C",""})
		oINNWebTable:AddHead({"Produto"		,"C",""})
		oINNWebTable:AddHead({"Descrição"	,"C",""})
		oINNWebTable:AddHead({"Tipo"		,"C",""})
		oINNWebTable:AddHead({"Almox"		,"C",""})
		oINNWebTable:AddHead({"Quantidade"	,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Vlr Unit"	,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Vlr Total"	,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Custo"		,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"TES"			,"C",""})
		oINNWebTable:AddHead({"Pedido"		,"C",""})
		oINNWebTable:AddHead({"CFOP"		,"C",""})
		oINNWebTable:AddHead({"Chave"		,"C","",.T.})

		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

		_cQuery := ""
		if !Empty(cDod)
			_cQuery += " AND F2_DOC LIKE '%"+Alltrim(cDod)+"' "
		endif 
		if !Empty(cSerie)
			_cQuery += " AND F2_SERIE = '"+Alltrim(cSerie)+"' "
		endif
		if !Empty(cProd)
			_cQuery += " AND D2_COD = '"+Alltrim(cProd)+"' "
		endif
		if !Empty(cAlmox)
			_cQuery += " AND D2_LOCAL = '"+Alltrim(cAlmox)+"' "
		endif
		if !Empty(cCliente)
			_cQuery += " AND F2_CLIENTE = '"+Alltrim(cCliente)+"' "
		endif
		if !Empty(cLoja)
			_cQuery += " AND F2_LOJA = '"+Alltrim(cLoja)+"' "
		endif
		if !Empty(cCFOP)
			_cQuery += " AND D2_CF LIKE '%"+Alltrim(cCFOP)+"%' "
		endif
		if !Empty(cTES)
			_cQuery += " AND D2_TES LIKE '%"+Alltrim(cTES)+"%' "
		endif 
		if !Empty(cPV)  
			_cQuery += " AND D2_PEDIDO LIKE '%"+Alltrim(cPV)+"%' "
		endif
		if !Empty(dInicio) 
			_cQuery += " AND F2_EMISSAO >= '"+dTos(dInicio)+"' "
		endif
		if !Empty(dFim)
			_cQuery += " AND F2_EMISSAO <= '"+dTos(dFim)+"' "
		endif
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			SELECT F2_FILIAL,F2_DOC,F2_SERIE,D2_ITEM,F2_TIPO,F2_EMISSAO,F2_CLIENTE,F2_LOJA,D2_COD,D2_LOCAL,D2_QUANT,D2_PRCVEN,
					D2_TOTAL,D2_TES,D2_CF,D2_PEDIDO,D2_CUSTO1 ,SF2.R_E_C_N_O_ REGISTRO ,F2_CHVNFE
			FROM %table:SF2% SF2
			INNER JOIN %table:SD2% SD2 ON D2_FILIAL = %xfilial:SD2%  AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE 
			WHERE F2_FILIAL = %xfilial:SF2% 
			AND SD2.%notDel% 
			AND SF2.%notDel% 
			%exp:_cQuery%
			ORDER BY F2_DOC,F2_SERIE,D2_ITEM
		EndSql
					
		WHILE (TMP->(!EOF()))
				
			oINNWebTable:AddCols({	TMP->F2_DOC,;
									TMP->F2_SERIE,;
									TMP->D2_ITEM,;
									TMP->F2_TIPO,;
									sTod(TMP->F2_EMISSAO ),;
									TMP->F2_CLIENTE,;
									TMP->F2_LOJA,;
									POSICIONE("SA1",1,xFilial("SA1")+TMP->F2_CLIENTE+TMP->F2_LOJA,"A1_NOME"),;
									TMP->D2_COD,;
									POSICIONE("SB1",1,xFilial("SB1")+TMP->D2_COD,"B1_DESC"),;
									POSICIONE("SB1",1,xFilial("SB1")+TMP->D2_COD,"B1_TIPO"),;
									TMP->D2_LOCAL,;
									TMP->D2_QUANT,;
									TMP->D2_PRCVEN,;
									TMP->D2_TOTAL,;
									TMP->D2_CUSTO1,;
									TMP->D2_TES,;
									TMP->D2_PEDIDO,;
									TMP->D2_CF,;
									TMP->F2_CHVNFE})
							
			oINNWebTable:SetLink(  , 1  , {"?x=wNFSaida&xID="+cValToChar(TMP->REGISTRO),"wNFSaida"+TMP->F2_DOC} )
			oINNWebTable:SetLink(  , 20 , {"?x=wDANFE&xID="+cValToChar(TMP->REGISTRO),"wNFSaida"+TMP->F2_CHVNFE} )
					
			TMP->(DbSkip())
	
		ENDDO  
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

	endif

Return

Static Function fDetalhe(oINNWeb,xID)

	dbSelectArea("SF2")
	SF2->(dbGoTo(xID))

	oBrowseSF2 := INNWebBrowse():New( oINNWeb )
	oBrowseSF2:SetTabela( "SF2" )
	oBrowseSF2:SetRec( xID )

	oTableSD2 := INNWebTable():New( oINNWeb )
	oTableSD2:xBrowse( "SD2",1, " SD2->D2_FILIAL == '"+SF2->F2_FILIAL+"' .AND. SD2->D2_DOC == '"+SF2->F2_DOC+"' .AND. SD2->D2_SERIE == '"+SF2->F2_SERIE+"' " )
	oTableSD2:Setlength(.F.)

	oTableSDE := INNWebTable():New( oINNWeb )
	oTableSDE:xBrowse( "SDE",1," SDE->DE_FILIAL == '"+SF2->F2_FILIAL+"' .AND. SDE->DE_DOC == '"+SF2->F2_DOC+"' .AND. SDE->DE_SERIE == '"+SF2->F2_SERIE+"' .AND. SDE->DE_FORNECE == '"+SF2->F2_CLIENTE+"' .AND. SDE->DE_LOJA == '"+SF2->F2_LOJA+"' ")
	oTableSDE:Setlength(.F.)

	oTableSF3 := INNWebTable():New( oINNWeb )
	oTableSF3:xBrowse( "SF3",1," SF3->F3_FILIAL == '"+SF2->F2_FILIAL+"' .AND. SF3->F3_NFISCAL == '"+SF2->F2_DOC+"' .AND. SF3->F3_SERIE == '"+SF2->F2_SERIE+"' .AND. SF3->F3_CLIEFOR == '"+SF2->F2_CLIENTE+"' .AND. SF3->F3_LOJA == '"+SF2->F2_LOJA+"' ")
	oTableSF3:Setlength(.F.)

	oTableCD2 := INNWebTable():New( oINNWeb )
	oTableCD2:xBrowse( "CD2",1," CD2->CD2_FILIAL == '"+SF2->F2_FILIAL+"' .AND. CD2->CD2_DOC == '"+SF2->F2_DOC+"' .AND. CD2->CD2_SERIE == '"+SF2->F2_SERIE+"' .AND. ( ( CD2->CD2_CODCLI == '"+SF2->F2_CLIENTE+"'  .AND. CD2->CD2_LOJCLI == '"+SF2->F2_LOJA+"' ) .OR. ( CD2->CD2_CODFOR == '"+SF2->F2_CLIENTE+"' .AND. CD2->CD2_LOJFOR == '"+SF2->F2_LOJA+"' ) ) " )
	oTableCD2:Setlength(.F.)

	oTableSE1 := INNWebTable():New( oINNWeb )
	oTableSE1:xBrowse( "SE1",1," SE1->E1_FILIAL == '"+SF2->F2_FILIAL+"' .AND. SE1->E1_NUM == '"+SF2->F2_DOC+"' .AND. SE1->E1_PREFIXO == '"+SF2->F2_SERIE+"' .AND. SE1->E1_CLIENTE == '"+SF2->F2_CLIENTE+"'  .AND. SE1->E1_LOJA == '"+SF2->F2_LOJA+"' ")
	oTableSE1:Setlength(.F.)

	oTableCDA := INNWebTable():New( oINNWeb )
	oTableCDA:xBrowse( "CDA",1," CDA->CDA_FILIAL == '"+SF2->F2_FILIAL+"' .AND. CDA->CDA_NUMERO == '"+SF2->F2_DOC+"' .AND. CDA->CDA_SERIE == '"+SF2->F2_SERIE+"' .AND. CDA->CDA_CLIFOR == '"+SF2->F2_CLIENTE+"'  .AND. CDA->CDA_LOJA == '"+SF2->F2_LOJA+"' ")
	oTableCDA:Setlength(.F.)

Return
