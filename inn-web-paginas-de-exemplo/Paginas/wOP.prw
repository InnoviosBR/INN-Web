#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wOP(oINNWeb)

	Local xID := Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))

	if xID > 0
		fDetalhe(@oINNWeb,xID)
		oINNWeb:SetTitNot("Dados detalhados da Ordem de Produção")
	else
		fPesquisa(@oINNWeb)
	endif

	oINNWeb:SetTitle("Ordens Produção") 
	oINNWeb:SetIdPgn("wOP")

Return

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
	Local nPosTatus := 15
	
	Local cCodigo		:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")
	Local cNumOP		:= iif(Valtype(HttpGet->NumOP) == "C" .and. !empty(HttpGet->NumOP),HttpGet->NumOP,"")
	Local cItemOP		:= iif(Valtype(HttpGet->ItemOP) == "C" .and. !empty(HttpGet->ItemOP),HttpGet->ItemOP,"")
	Local cSeqOP		:= iif(Valtype(HttpGet->SeqOP) == "C" .and. !empty(HttpGet->SeqOP),HttpGet->SeqOP,"")					
	Local dInicio		:= cTod(iif(Valtype(HttpGet->inicio) == "C" .and. !empty(HttpGet->inicio),HttpGet->inicio,""))
	Local dFim			:= cTod(iif(Valtype(HttpGet->fim) == "C" .and. !empty(HttpGet->fim),HttpGet->fim,""))
	Local cAlmox		:= iif(Valtype(HttpGet->almox) == "C" .and. !empty(HttpGet->almox),HttpGet->almox,"")
	Local cStatus		:= iif(Valtype(HttpGet->status) == "C" .and. !empty(HttpGet->status),HttpGet->status,"")

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'NumOP'	,'Numero'	, 6,cNumOP	,.F.})
	oINNWebParam:addText( {'ItemOP'	,'Item'		, 2,cItemOP	,.F.})
	oINNWebParam:addText( {'SeqOP'	,'Sequencia', 3,cSeqOP	,.F.})
	oINNWebParam:addText( {'codigo'	,'Produto'	,15,cCodigo	,.F.})
	oINNWebParam:addText( {'almox'	,'Armazem'	, 2,cAlmox	,.F.})
	oINNWebParam:addData( {'inicio'	,'Inicio'	,dInicio	,.F.})
	oINNWebParam:addData( {'fim'	,'Fim'		,dFim		,.F.})
	oINNWebParam:addCombo( {'status','Status'	,cStatus	, {{"A","Em aberto"},{"E","Encerrada"},{"","Tudo"}} ,.F.} )
		
	if !empty(cNumOP) .or. !empty(cCodigo) .or. !empty(cAlmox) .or. !empty(cStatus) .or. ( !empty(dInicio) .and. !empty(dFim) )

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Número"				,"C","",.T.})
		oINNWebTable:AddHead({"Item"				,"C",""})
		oINNWebTable:AddHead({"Sequência"			,"C",""})
		oINNWebTable:AddHead({"Seq pai"				,"C",""})
		oINNWebTable:AddHead({"Emissão"				,"D",""})
		oINNWebTable:AddHead({"Previsao Ini"		,"D",""})
		oINNWebTable:AddHead({"Previsao Entrega"	,"D",""})		
		oINNWebTable:AddHead({"Data Fim"			,"D",""})
		oINNWebTable:AddHead({"Produto"				,"C",""})
		oINNWebTable:AddHead({"Descrição"			,"C",""})
		oINNWebTable:AddHead({"Almoxarifado"		,"C",""})
		oINNWebTable:AddHead({"Quantidade"			,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Quant. Entregue"		,"C","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Obs"					,"C",""})
		oINNWebTable:AddHead({"Status"				,""})
		oINNWebTable:AddHead({"Custo"				,"N","@E 99,999,999,999.99"})

		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

		_cQuery := ""
		IF !Empty(cNumOP)
			_cQuery += " AND C2_NUM = '"+Alltrim(cNumOP)+"' "
		ENDIF
		IF !Empty(cItemOP)
			_cQuery += " AND C2_ITEM = '"+Alltrim(cItemOP)+"' "
		ENDIF
		IF !Empty(cSeqOP)
			_cQuery += " AND C2_SEQUEN = '"+Alltrim(cSeqOP)+"' "
		ENDIF
		IF !Empty(cCodigo)
			_cQuery += " AND C2_PRODUTO = '"+Alltrim(cCodigo)+"' "
		ENDIF	
		IF !Empty(cAlmox)
			_cQuery += " AND C2_LOCAL = '"+Alltrim(cAlmox)+"' "
		ENDIF	
		if !Empty(dInicio)
			_cQuery += " AND C2_EMISSAO >= '"+dTos(dInicio)+"' "
		endif
		if !Empty(dFim)
			_cQuery += " AND C2_EMISSAO <= '"+dTos(dFim)+"' "
		endif	
		if cStatus == "E" // Encerradas
			_cQuery += " AND (C2_DATRF != '' OR C2_QUJE >= C2_QUANT ) "
		endif
		if cStatus == "A" // Abertas
			_cQuery += " AND C2_DATRF = '' AND C2_QUANT > (C2_QUJE+C2_PERDA) "
		endif
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			column C2_EMISSAO as Date
			column C2_DATPRI as Date
			column C2_DATPRF as Date
			column C2_DATRF as Date
			SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_SEQUEN, C2_SEQPAI, C2_PRODUTO, B1_DESC, C2_LOCAL, C2_DATPRI, C2_DATPRF, 
					C2_QUANT, C2_QUJE, C2_EMISSAO, C2_DATRF, C2_STATUS, C2_APRATU1 ,C2_OBS
			FROM %table:SC2% SC2
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1%  AND C2_PRODUTO = B1_COD
			WHERE C2_FILIAL = %xfilial:SC2% 
			AND SC2.%notDel% 
			AND SB1.%notDel% 
			%exp:_cQuery%
			ORDER BY C2_NUM DESC , C2_ITEM ASC , C2_SEQUEN ASC 
		EndSql
				
		DbSelectArea("TMP")
		TMP->(dbGoTop())

		dbSelectArea("SC2")
		SC2->(dbSetOrder(1))
			
		WHILE (TMP->(!EOF()))

			SC2->(MsSeek(TMP->C2_FILIAL+TMP->C2_NUM+TMP->C2_ITEM+TMP->C2_SEQUEN))

			oINNWebTable:AddCols({	TMP->C2_NUM,;
									TMP->C2_ITEM,;
									TMP->C2_SEQUEN,;
									TMP->C2_SEQPAI,;
									TMP->C2_EMISSAO,;
									TMP->C2_DATPRI,;
									TMP->C2_DATPRF,;
									TMP->C2_DATRF,;
									TMP->C2_PRODUTO,;
									TMP->B1_DESC,;
									TMP->C2_LOCAL,;
									TMP->C2_QUANT,;
									TMP->C2_QUJE,;
									TMP->C2_OBS,;
									"Status",;
									TMP->C2_APRATU1})
							
			oINNWebTable:SetLink(  , 1  , {"?x=wOP&xID="+cValToChar(SC2->(Recno())),"op"+TMP->C2_NUM+TMP->C2_ITEM+TMP->C2_SEQUEN} )

			Do Case
				Case A650DefLeg(1)
					oINNWebTable:SetValue(  , nPosTatus , "Prevista" )
				Case A650DefLeg(2)
					oINNWebTable:SetValue(  , nPosTatus , "Em aberto" )
				Case A650DefLeg(3)
					oINNWebTable:SetValue(  , nPosTatus , "Iniciada" )
				Case A650DefLeg(4)
					oINNWebTable:SetValue(  , nPosTatus , "Ociosa" )
				Case A650DefLeg(5)
					oINNWebTable:SetValue(  , nPosTatus , "Encerrada parcialmente" )
				Case A650DefLeg(6)
					oINNWebTable:SetValue(  , nPosTatus , "Encerrada totalmente" )
				OtherWise
					oINNWebTable:SetValue(  , nPosTatus , "" )
			EndCase
								
			TMP->(DbSkip())
	
		ENDDO  
					
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

	endif
				
Return(.T.)

Static Function fDetalhe(oINNWeb,xID)

	dbSelectArea("SC2")
	SC2->(dbGoTo(xID))

	oINNWebBrowse := INNWebBrowse():New( oINNWeb )
	oINNWebBrowse:SetTabela( "SC2" )
	oINNWebBrowse:SetRec( xID )

	oTableSD4 := INNWebTable():New( oINNWeb )
	oTableSD4:xBrowse( "SD4" , 1 , " SD4->D4_FILIAL == '"+SC2->C2_FILIAL+"' .AND. Alltrim(SD4->D4_OP) == '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' " )
	oTableSD4:Setlength(.F.)

	oTableSD3 := INNWebTable():New( oINNWeb )
	oTableSD3:xBrowse( "SD3" , 1 , " SD3->D3_FILIAL == '"+SC2->C2_FILIAL+"' .AND. Alltrim(SD3->D3_OP) == '"+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"' " )
	oTableSD3:Setlength(.F.)

Return
