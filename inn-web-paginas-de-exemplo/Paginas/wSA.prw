#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wSA(oINNWeb)

	if oINNWeb:ValidVinc("SD3","SCQ")
		
		xID := val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,"")	)
		
		if xID > 0

			oINNWebbBrowse := INNWebBrowse():New( oINNWeb )
			oINNWebbBrowse:SetTabela( "SCP" )
			oINNWebbBrowse:SetRec( xID )
			
		else

			fPesquisa(@oINNWeb)

		endif
		
	endif

	oINNWeb:SetTitle("Solicitação Armazém") 
	oINNWeb:SetIdPgn("wSA")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
	
	Local cNumSA	:= iif(Valtype(HttpGet->NumSA) == "C" .and. !empty(HttpGet->NumSA),HttpGet->NumSA,"")		
	Local cCodigo	:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")
	Local cSolic	:= iif(Valtype(HttpGet->solic) == "C" .and. !empty(HttpGet->solic),HttpGet->solic,"")	
	Local dinicio	:= cTod(iif(Valtype(HttpGet->dinicio) == "C" .and. !empty(HttpGet->dinicio),HttpGet->dinicio,""))
	Local dfim		:= cTod(iif(Valtype(HttpGet->dfim) == "C" .and. !empty(HttpGet->dfim),HttpGet->dfim,""))
	Local cNumSeq 	:= iif(Valtype(HttpGet->numseq) == "C" .and. !empty(HttpGet->numseq),HttpGet->numseq,"")

	oINNWebParam := INNWebParam():New( oINNWeb )	
	oINNWebParam:addText( {'NumSA'	,'Numero'		, 6,cNumSA	,.F.})
	oINNWebParam:addText( {'codigo'	,'Produto'		,15,cCodigo	,.F.})		
	oINNWebParam:addText( {'solic'	,'Solicitante'	,20,cSolic	,.F.})
	oINNWebParam:addText( {'numseq'	,'Sequencial'	, 9,cNumSeq	,.F.})
	oINNWebParam:addData( {'dinicio','Data Inicio'	,dinicio	,.F.})
	oINNWebParam:addData( {'dfim'	,'Data Fim'		,dfim		,.F.})

	if !empty(cNumSA) .or. !empty(cCodigo) .or. !empty(cSolic) .or. !empty(dinicio) .or. !empty(dfim) .or. !empty(cNumSeq)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Número"			,"C","",.T.})
		oINNWebTable:AddHead({"Item"			,"C",""})
		oINNWebTable:AddHead({"Solicitante"		,"C",""})
		oINNWebTable:AddHead({"Produto"			,"C",""})
		oINNWebTable:AddHead({"Descrição"		,"C",""})
		oINNWebTable:AddHead({"Almoxarifado"	,"C",""})
		oINNWebTable:AddHead({"Emissão"			,"D",""})
		oINNWebTable:AddHead({"Quantidade"		,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Quant. Entregue"	,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Centro Custo"	,"C",""})
		oINNWebTable:AddHead({"Item Contabil"	,"C",""})
		oINNWebTable:AddHead({"Status"			,"C",""})
						
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		IF !Empty(cNumSA)
			_cQuery += " AND CP_NUM = '"+Alltrim(cNumSA)+"' "
		ENDIF
		IF !Empty(cCodigo)
			_cQuery += " AND CP_PRODUTO = '"+Alltrim(cCodigo)+"' "
		ENDIF
		if !Empty(cSolic)
			_cQuery += " AND UPPER(CP_SOLICIT) LIKE '%"+Alltrim(upper(cSolic))+"%' "
		endif
		if !Empty(dinicio) .or. !Empty(dfim)
			_cQuery += " AND CP_FILIAL+CP_NUM+CP_ITEM+CP_PRODUTO IN (SELECT CQ_FILIAL+CQ_NUM+CQ_ITEM+CQ_PRODUTO FROM "+RetSqlName("SCQ")+" SCQ "
			_cQuery += " 											INNER JOIN "+RetSqlName("SD3")+" SD3 ON D3_FILIAL = CQ_FILIAL AND CQ_NUMREQ = D3_NUMSEQ AND CQ_PRODUTO = D3_COD AND CQ_LOCAL = D3_LOCAL "
			_cQuery += " 											WHERE CQ_FILIAL = '"+xFilial("SCQ")+"' "
			_cQuery += " 											AND D3_ESTORNO = '' "
			if !Empty(dinicio)
				_cQuery += " 										AND D3_EMISSAO >= '"+dTos(dinicio)+"' "
			endif
			if !Empty(dfim)
				_cQuery += " 										AND D3_EMISSAO <= '"+dTos(dfim)+"' "
			endif
			_cQuery += " 											AND SCQ.D_E_L_E_T_ = '' "
			_cQuery += " 											AND SD3.D_E_L_E_T_ = '' )"
		endif
		if  !Empty(cNumSeq)
			_cQuery += " AND CP_FILIAL+CP_NUM+CP_ITEM+CP_PRODUTO IN (SELECT CQ_FILIAL+CQ_NUM+CQ_ITEM+CQ_PRODUTO FROM "+RetSqlName("SCQ")+" SCQ "
			_cQuery += " 											INNER JOIN "+RetSqlName("SD3")+" SD3 ON D3_FILIAL = CQ_FILIAL AND CQ_NUMREQ = D3_NUMSEQ AND CQ_PRODUTO = D3_COD AND CQ_LOCAL = D3_LOCAL "
			_cQuery += " 											WHERE CQ_FILIAL = '"+xFilial("SCQ")+"' "
			_cQuery += " 											AND D3_ESTORNO = '' "
			if !Empty(cNumSeq)
				_cQuery += " 										AND D3_NUMSEQ = '"+cNumSeq+"' "
			endif
			_cQuery += " 											AND SCQ.D_E_L_E_T_ = '' "
			_cQuery += " 											AND SD3.D_E_L_E_T_ = '' )"
		endif
		_cQuery := '%'+_cQuery+'%'
	
		BeginSql alias 'TMP'
			SELECT
				CASE
					WHEN CP_QUANT = CP_QUJE THEN 'Atendida'
					WHEN CP_QUJE = '0' THEN 'Não Atendida'
					WHEN CP_QUANT > CP_QUJE THEN 'Parcialmente Atendida'
				END LEGENDA,
				CP_NUM,
				CP_ITEM,
				CP_PRODUTO,
				B1_DESC,
				CP_QUANT,
				CP_LOCAL,
				CP_EMISSAO,
				CP_QUJE,
				CP_SOLICIT,
				CP_CC,
				CP_ITEMCTA,
				SCP.R_E_C_N_O_ 'REC'
			FROM %table:SCP% SCP " 
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1% AND CP_PRODUTO = B1_COD "
			WHERE CP_FILIAL = %xfilial:SCP%
			AND SCP.%notDel%
			AND SB1.%notDel%
			%exp:_cQuery%
			ORDER BY CP_NUM , CP_ITEM
		EndSql
			
		WHILE (TMP->(!EOF()))
				
			oINNWebTable:AddCols({	TMP->CP_NUM,;
									TMP->CP_ITEM ,;
									TMP->CP_SOLICIT ,;
									TMP->CP_PRODUTO ,;
									TMP->B1_DESC ,;
									TMP->CP_LOCAL ,;
									stod(TMP->CP_EMISSAO) ,;
									TMP->CP_QUANT ,;
									TMP->CP_QUJE,;
									TMP->CP_CC,;
									TMP->CP_ITEMCTA,;
									TMP->LEGENDA })
			
			oINNWebTable:SetLink(  , 1 , {"?x=wSA&xID="+cValToChar( TMP->REC ),"SA"+TMP->CP_NUM} )
		
			TMP->(DbSkip())
	
		ENDDO  
					
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 
			
	endif

Return
