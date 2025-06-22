#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wNFEntrada(oINNWeb)
	
	Local xID := Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))
	
	if xID > 0
		fDetalhe(@oINNWeb,xID)
		oINNWeb:SetTitNot("Dados detalhados da NF Entrada")
	else
		fPesquisa(@oINNWeb)
	endif
						
	oINNWeb:SetTitle("NF Entrada") 
	oINNWeb:SetIdPgn("wNFEntrada")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local nY
	Local _cQuery	:= ""
	
	Local aDescOr 	:= {}
	Local aDescAnd 	:= {}

	Local cDod		:= iif(Valtype(HttpGet->doc) == "C" .and. !empty(HttpGet->doc),HttpGet->doc,"")		
	Local cSerie	:= iif(Valtype(HttpGet->serie) == "C" .and. !empty(HttpGet->serie),HttpGet->serie,"")		
	Local cProd		:= iif(Valtype(HttpGet->produto) == "C" .and. !empty(HttpGet->produto),HttpGet->produto,"")
	Local cAlmox	:= iif(Valtype(HttpGet->almox) == "C" .and. !empty(HttpGet->almox),HttpGet->almox,"")
	Local cForne	:= iif(Valtype(HttpGet->Forne) == "C" .and. !empty(HttpGet->Forne),HttpGet->Forne,"")
	Local cLoja		:= iif(Valtype(HttpGet->Loja) == "C" .and. !empty(HttpGet->Loja),HttpGet->Loja,"")
	Local cTES		:= iif(Valtype(HttpGet->tes) == "C" .and. !empty(HttpGet->tes),HttpGet->tes,"")
	Local cCFOP		:= iif(Valtype(HttpGet->cfop) == "C" .and. !empty(HttpGet->cfop),HttpGet->cfop,"")
	Local cPedido	:= iif(Valtype(HttpGet->pedido) == "C" .and. !empty(HttpGet->pedido),HttpGet->pedido,"")
	Local dInicio	:= cTod(iif(Valtype(HttpGet->inicio) == "C" .and. !empty(HttpGet->inicio),HttpGet->inicio,""))
	Local dFim		:= cTod(iif(Valtype(HttpGet->fim) == "C" .and. !empty(HttpGet->fim),HttpGet->fim,""))
	Local dFTInicio	:= cTod(iif(Valtype(HttpGet->ftinicio) == "C" .and. !empty(HttpGet->ftinicio),HttpGet->ftinicio,""))
	Local dFTFim	:= cTod(iif(Valtype(HttpGet->ftfim) == "C" .and. !empty(HttpGet->ftfim),HttpGet->ftfim,""))
	Local cCC		:= iif(Valtype(HttpGet->ccusto) == "C" .and. !empty(HttpGet->ccusto),HttpGet->ccusto,"")		
	Local cDesc 	:= iif(Valtype(HttpGet->desc) == "C" .and. !empty(HttpGet->desc),HttpGet->desc,"")
	
	if !empty(cDesc)
		cDesc := StrTran(cDesc,"[%]","%")	
		cDesc := StrTran(cDesc,"%","[%]")	
		cDesc := StrTran (cDesc,"'",",")		
		if ',' $ cDesc
			aDescOr  := StrTokArr ( cDesc , "," )
		elseif '+' $ cDesc
			aDescAnd := StrTokArr ( cDesc , "+" )
		else
			aadd(aDescOr,cDesc)
		endif
		
		cDesc := ""
		
		for nY := 1 To len(aDescOr)
			aDescOr[nY] := Alltrim(UPPER(aDescOr[nY]))
			cDesc += iif(Empty(cDesc),"",",")
			cDesc += aDescOr[nY]
		next
		
		for nY := 1 To len(aDescAnd)
			aDescAnd[nY] := Alltrim(UPPER(aDescAnd[nY]))
			cDesc += iif(Empty(cDesc),"","+")
			cDesc += aDescAnd[nY]
		next
	endif

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'doc'		,'Documento'		, 9,cDod	,.F.} )
	oINNWebParam:addText( {'serie'		,'Serie'			, 3,cSerie	,.F.} )
	oINNWebParam:addText( {'produto'	,'Produto'			,15,cProd	,.F.} )
	oINNWebParam:addText( {'desc'		,'Descrição'		,50,cDesc	,.F.} )	
	oINNWebParam:addText( {'almox'		,'Armazem'			, 2,cAlmox	,.F.} )
	oINNWebParam:addText( {'Forne'		,'Fornecedor'		, 6,cForne	,.F.} )
	oINNWebParam:addText( {'Loja'		,'Loja'				, 2,cLoja	,.F.} )
	oINNWebParam:addText( {'tes'		,'TES'				, 3,cTES	,.F.} )
	oINNWebParam:addText( {'cfop'		,'CFOP'				, 4,cCFOP	,.F.} )
	oINNWebParam:addText( {'pedido'		,'Pedido Compra'	, 6,cPedido	,.F.} )
	oINNWebParam:addText( {'ccusto'		,'Centro Custo'		, 9,cCC		,.F.} )
	oINNWebParam:addData( {'inicio'		,'Emissão Inicio'	,dInicio	,.F.} )
	oINNWebParam:addData( {'fim'		,'Emissão Fim'		,dFim		,.F.} )
	oINNWebParam:addData( {'ftinicio'	,'Entrada Inicio'	,dFTInicio	,.F.} )
	oINNWebParam:addData( {'ftfim'		,'Entrada Fim'		,dFTFim		,.F.} )

	if !empty(cDod) .or. !empty(cSerie) .or. !empty(cProd) .or. !empty(cAlmox) .or. !empty(cDesc) .or. !empty(cForne) .or. !empty(cLoja) .or. !empty(cTES) .or. !empty(cCFOP) .or. !empty(cPedido) .or. ( !empty(dInicio) .and. !empty(dFim) ) .or. ( !empty(dFTInicio) .and. !empty(dFTFim) )  .or. !empty(cCC)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Documento"		,"C","",.T.})
		oINNWebTable:AddHead({"Serie"			,"C",""})
		oINNWebTable:AddHead({"Item"			,"C","",.T.})
		oINNWebTable:AddHead({"Tipo"			,"C",""})
		oINNWebTable:AddHead({"Emissão"			,"D","",.T.})
		oINNWebTable:AddHead({"Fornecedor"		,"C",""})
		oINNWebTable:AddHead({"Loja"			,"C",""})
		oINNWebTable:AddHead({"Nome"			,"C",""})
		oINNWebTable:AddHead({"Produto"			,"C",""})
		oINNWebTable:AddHead({"Descrição"		,"C",""})
		oINNWebTable:AddHead({"Tipo"			,"C",""})
		oINNWebTable:AddHead({"Almox"			,"C",""})
		oINNWebTable:AddHead({"Quantidade"		,"N","@E 99,999,999,999.999",.T.})
		oINNWebTable:AddHead({"Vlr Unit"		,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"Vlr Total"		,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"Custo"			,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"Pedido"			,"C","",.T.})
		oINNWebTable:AddHead({"Item Ped"		,"C",""})
		oINNWebTable:AddHead({"TES"				,"C",""})
		oINNWebTable:AddHead({"Centro Custo"	,"C",""})
		oINNWebTable:AddHead({"Item Contabil"	,"C",""})
		oINNWebTable:AddHead({"CFOP"			,"C",""})
		oINNWebTable:AddHead({"Chave NF-e"		,"C",""})

		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		_cQuery := ""
		if !Empty(cDod)
			_cQuery += " AND F1_DOC LIKE '%"+Alltrim(cDod)+"' "
		endif 
		if !Empty(cSerie)
			_cQuery += " AND F1_SERIE = '"+Alltrim(cSerie)+"' "
		endif
		if !Empty(cProd)
			_cQuery += " AND D1_COD = '"+Alltrim(cProd)+"' "
		endif
		if !Empty(cAlmox)
			_cQuery += " AND D1_LOCAL = '"+Alltrim(cAlmox)+"' "
		endif
		if !Empty(cForne)
			_cQuery += " AND F1_FORNECE = '"+Alltrim(cForne)+"' "
		endif
		if !Empty(cLoja)
			_cQuery += " AND F1_LOJA = '"+Alltrim(cLoja)+"' "
		endif
		if !Empty(cCFOP)
			_cQuery += " AND D1_CF LIKE '%"+Alltrim(cCFOP)+"%' "
		endif
		if !Empty(cTES)
			_cQuery += " AND D1_TES LIKE '%"+Alltrim(cTES)+"%' "
		endif
		if !Empty(cPedido)
			_cQuery += " AND D1_PEDIDO = '"+Alltrim(cPedido)+"' "
		endif
		if !Empty(dInicio)
			_cQuery += " AND F1_EMISSAO >= '"+dTos(dInicio)+"' "
		endif
		if !Empty(dFim)
			_cQuery += " AND F1_EMISSAO <= '"+dTos(dFim)+"' "
		endif
		if !Empty(dFTInicio) .OR. !Empty(dFTFim)
			_cQuery += " AND F1_FILIAL + F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA IN "
			_cQuery += "   ( SELECT DISTINCT FT_FILIAL + FT_NFISCAL + FT_SERIE + FT_CLIEFOR + FT_LOJA FROM "+RetSqlName("SFT")+" SFT "
			_cQuery += " 	 WHERE FT_FILIAL = '"+xFilial("SFT")+"' "
			_cQuery += " 	   AND %notDel% "
			if !Empty(dFTInicio)
				_cQuery += " AND FT_ENTRADA >= '"+dTos(dFTInicio)+"' "
			endif
			if !Empty(dFTFim)
				_cQuery += " AND FT_ENTRADA <= '"+dTos(dFTFim)+"' "
			endif
			_cQuery += " AND FT_TIPOMOV = 'E' "
			_cQuery += " ) "
		endif
		if !Empty(cCC)
			_cQuery += " AND (F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA IN "
			_cQuery += " (SELECT DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA FROM "+RetSqlName("SDE")+" SDE "
			_cQuery += "   WHERE DE_FILIAL = '"+xFilial("SDE")+"' AND DE_CC = '"+cCC+"' AND %notDel% ) OR D1_CC = '"+cCC+"') "
		endif
		
		IF Len(aDescOr) > 0 
			_cQuery += " AND (( " 
			for nY := 1 To len(aDescOr)
				_cQuery += IIF(nY > 1," OR ","")
				_cQuery += " UPPER(B1_DESC) LIKE '%"+aDescOr[nY]+"%' "
			next
			_cQuery += " ) OR ( " 
			for nY := 1 To len(aDescOr)
				_cQuery += IIF(nY > 1," OR ","")
				_cQuery += " UPPER(B1__DESCII) LIKE '%"+aDescOr[nY]+"%' "
			next
			_cQuery += " )) "
		ENDIF
		
		IF Len(aDescAnd) > 0 
			_cQuery += " AND (( " 
			for nY := 1 To len(aDescAnd)
				_cQuery += IIF(nY > 1," AND ","")
				_cQuery += " UPPER(B1_DESC) LIKE '%"+aDescAnd[nY]+"%' "
			next
			_cQuery += " ) OR ( " 
			for nY := 1 To len(aDescAnd)
				_cQuery += IIF(nY > 1," AND ","")
				_cQuery += " UPPER(B1__DESCII) LIKE '%"+aDescAnd[nY]+"%' "
			next
			_cQuery += " )) "
		ENDIF
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			SELECT SF1.R_E_C_N_O_ REGLOG,F1_FILIAL,F1_DOC,F1_SERIE,D1_ITEM,F1_TIPO,F1_EMISSAO,F1_FORNECE,F1_LOJA,D1_COD,D1_LOCAL,
				   D1_QUANT,D1_VUNIT,D1_TOTAL ,D1_TES,D1_CF,D1_PEDIDO,D1_ITEMPC,F1_CHVNFE,D1_CUSTO,SF1.R_E_C_N_O_ REGISTRO,D1_CC,D1_ITEMCTA 
			FROM %table:SF1% SF1
			INNER JOIN %table:SD1% SD1 ON D1_FILIAL = %xfilial:SD1% AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA 
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1% AND D1_COD = B1_COD
			WHERE F1_FILIAL = %xfilial:SF1% 
			AND SD1.%notDel% 
			AND SB1.%notDel% 
			AND SF1.%notDel% 
			%exp:_cQuery%
			ORDER BY F1_DOC,F1_SERIE,D1_ITEM 
		EndSql
			
		WHILE (TMP->(!EOF()))
						
			oINNWebTable:AddCols({	TMP->F1_DOC,;
									TMP->F1_SERIE,;
									TMP->D1_ITEM,;
									fNFTipo(TMP->F1_TIPO),;
									sTod(TMP->F1_EMISSAO ),;
									TMP->F1_FORNECE,;
									TMP->F1_LOJA,;
									POSICIONE("SA2",1,xFilial("SA2")+TMP->F1_FORNECE+TMP->F1_LOJA,"A2_NOME"),;
									TMP->D1_COD,;
									POSICIONE("SB1",1,xFilial("SB1")+TMP->D1_COD,"B1_DESC"),;
									POSICIONE("SB1",1,xFilial("SB1")+TMP->D1_COD,"B1_TIPO"),;
									TMP->D1_LOCAL,;
									TMP->D1_QUANT,;
									TMP->D1_VUNIT,;
									TMP->D1_TOTAL,;
									TMP->D1_CUSTO,;
									TMP->D1_PEDIDO,;
									TMP->D1_ITEMPC,;
									TMP->D1_TES,;
									TMP->D1_CC,;
									TMP->D1_ITEMCTA,;
									TMP->D1_CF,;
									TMP->F1_CHVNFE})
							
			oINNWebTable:SetLink(  , 1  , {"?x=wNFEntrada&xID="+cValToChar(TMP->REGISTRO),"wNFEntrada"+TMP->F1_DOC} )
			oINNWebTable:SetLink(  , 17 , {"?x=wPC&NumPC="+TMP->D1_PEDIDO,"NumPC"+TMP->D1_PEDIDO} )
							
			TMP->(DbSkip())
	
		ENDDO  
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 
			
	endif

Return

Static Function fNFTipo(cTipo)

	Local cRet := ""

	Do Case 
		Case cTipo == "N"
			cRet := "NF Normal"
		Case cTipo == "C"
			cRet := "Complemento"
		Case cTipo == "D"
			cRet := "Devolução"
		Case cTipo == "I"
			cRet := "NF Compl. ICMS"
		Case cTipo == "P"
			cRet := "NF Compl. IPI"
		Case cTipo == "B"
			cRet := "NF Beneficiamento"
	End Case

Return(cRet)

Static Function fDetalhe(oINNWeb,xID)

	dbSelectArea("SF1")
	SF1->(dbGoTo(xID))

	oINNWebBrowse := INNWebBrowse():New( oINNWeb )
	oINNWebBrowse:SetTabela( "SF1" )
	oINNWebBrowse:SetRec( xID )

	oTableSD1 := INNWebTable():New( oINNWeb )
	oTableSD1:xBrowse( "SD1",1, " SD1->D1_FILIAL == '"+SF1->F1_FILIAL+"' .AND. SD1->D1_DOC == '"+SF1->F1_DOC+"' .AND. SD1->D1_SERIE == '"+SF1->F1_SERIE+"' .AND. SD1->D1_FORNECE == '"+SF1->F1_FORNECE+"' .AND. SD1->D1_LOJA == '"+SF1->F1_LOJA+"' " )
	oTableSD1:Setlength(.F.)

	oTableSDE := INNWebTable():New( oINNWeb )
	oTableSDE:xBrowse( "SDE",1," SDE->DE_FILIAL == '"+SF1->F1_FILIAL+"' .AND. SDE->DE_DOC == '"+SF1->F1_DOC+"' .AND. SDE->DE_SERIE == '"+SF1->F1_SERIE+"' .AND. SDE->DE_FORNECE == '"+SF1->F1_FORNECE+"' .AND. SDE->DE_LOJA == '"+SF1->F1_LOJA+"' " )
	oTableSDE:Setlength(.F.)

	oTableSF3 := INNWebTable():New( oINNWeb )
	oTableSF3:xBrowse( "SF3",1," SF3->F3_FILIAL == '"+SF1->F1_FILIAL+"' .AND. SF3->F3_NFISCAL == '"+SF1->F1_DOC+"' .AND. SF3->F3_SERIE == '"+SF1->F1_SERIE+"' .AND. SF3->F3_CLIEFOR == '"+SF1->F1_FORNECE+"' .AND. SF3->F3_LOJA == '"+SF1->F1_LOJA+"' " )
	oTableSF3:Setlength(.F.)

	oTableCD2 := INNWebTable():New( oINNWeb )
	oTableCD2:xBrowse( "CD2",1," CD2->CD2_FILIAL == '"+SF1->F1_FILIAL+"' .AND. CD2->CD2_DOC == '"+SF1->F1_DOC+"' .AND. CD2->CD2_SERIE == '"+SF1->F1_SERIE+"' .AND. ( ( CD2->CD2_CODCLI == '"+SF1->F1_FORNECE+"'  .AND. CD2->CD2_LOJCLI == '"+SF1->F1_LOJA+"' ) .OR. ( CD2->CD2_CODFOR == '"+SF1->F1_FORNECE+"' .AND. CD2->CD2_LOJFOR == '"+SF1->F1_LOJA+"' ) ) " )
	oTableCD2:Setlength(.F.)

	oTableCDA := INNWebTable():New( oINNWeb )
	oTableCDA:xBrowse( "CDA",1," CD2->CD2_FILIAL == '"+SF1->F1_FILIAL+"' .AND. CD2->CD2_DOC == '"+SF1->F1_DOC+"' .AND. CD2->CD2_SERIE == '"+SF1->F1_SERIE+"' .AND. ( ( CD2->CD2_CODCLI == '"+SF1->F1_FORNECE+"'  .AND. CD2->CD2_LOJCLI == '"+SF1->F1_LOJA+"' ) .OR. ( CD2->CD2_CODFOR == '"+SF1->F1_FORNECE+"' .AND. CD2->CD2_LOJFOR == '"+SF1->F1_LOJA+"' ) ) " )
	oTableCDA:Setlength(.F.)

	oTableSE2 := INNWebTable():New( oINNWeb )
	oTableSE2:xBrowse( "SE2",1," SE2->E2_FILIAL == '"+SF1->F1_FILIAL+"' .AND. SE2->E2_NUM == '"+SF1->F1_DOC+"' .AND. SE2->E2_PREFIXO == '"+SF1->F1_SERIE+"' .AND. SE2->E2_FORNECE == '"+SF1->F1_FORNECE+"'  .AND. SE2->E2_LOJA == '"+SF1->F1_LOJA+"' " )
	oTableSE2:Setlength(.F.)

Return
