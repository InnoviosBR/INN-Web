#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wPV(oINNWeb)
		
	xID	:= iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,"")

	dbSelectArea("SC5")
	SC5->(dbSetOrder(1))
	
	if !Empty(xID) .and. SC5->(dbSeek(xFilial("SC5")+xID))				

		oINNWebBrowse := INNWebBrowse():New( oINNWeb )
		oINNWebBrowse:SetTabela( "SC5" )
		oINNWebBrowse:SetRec( SC5->(Recno()) )

		oTableSC6 := INNWebTable():New( oINNWeb )
		oTableSC6:xBrowse( "SC6",1, " SC6->C6_NUM == '"+SC5->C5_NUM+"' .AND. SC6->C6_FILIAL == '"+SC5->C5_FILIAL+"' ")
		oTableSC6:Setlength(.F.)

		oTableSD2 := INNWebTable():New( oINNWeb )
		oTableSD2:xBrowse( "SD2",1, " SD2->D2_PEDIDO == '"+SC5->C5_NUM+"' .AND. SD2->D2_FILIAL == '"+SC5->C5_FILIAL+"' ")
		oTableSD2:Setlength(.F.)

		oINNWeb:SetTitNot("Dados detalhados do Pedido de Venda")

	else

		fPesquisa(@oINNWeb)

	endif
			
	oINNWeb:SetTitle("Pedidos de Venda") 
	oINNWeb:SetIdPgn("wPV")
	
Return(.T.)

Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""

	Local cNumPV	:= iif(Valtype(HttpGet->NumPV) == "C" .and. !empty(HttpGet->NumPV),HttpGet->NumPV,"")		
	Local cCodigo	:= iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")
	Local cAlmox	:= iif(Valtype(HttpGet->Almox) == "C" .and. !empty(HttpGet->Almox),HttpGet->Almox,"")
	Local cCliente	:= iif(Valtype(HttpGet->Cliente) == "C" .and. !empty(HttpGet->Cliente),HttpGet->Cliente,"")
	Local cLoja		:= iif(Valtype(HttpGet->Loja) == "C" .and. !empty(HttpGet->Loja),HttpGet->Loja,"")
	Local cNFNum	:= iif(Valtype(HttpGet->NFNum) == "C" .and. !empty(HttpGet->NFNum),HttpGet->NFNum,"")

	oINNWebParam := INNWebParam():New( oINNWeb )	
	oINNWebParam:addText( {'NumPV'	,'Numero'	, 6,cNumPV	,.F.})
	oINNWebParam:addText( {'codigo'	,'Produto'	,15,cCodigo	,.F.})		
	oINNWebParam:addText( {'Almox'	,'Armazem'	, 2,cAlmox	,.F.})
	oINNWebParam:addText( {'Cliente','Cliente'	, 6,cCliente,.F.})
	oINNWebParam:addText( {'Loja'	,'Loja'		, 2,cLoja	,.F.})
	oINNWebParam:addText( {'NFNum'	,'NF Numero', 9,cNFNum	,.F.})
	
	if !empty(cNumPV) .or. !empty(cCodigo) .or. !empty(cCliente) .or. !empty(cLoja) .or. !empty(cAlmox) .or. !empty(cNFNum)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Número"			,"C","",.T.})
		oINNWebTable:AddHead({"Item"			,"C",""})
		oINNWebTable:AddHead({"Cliente"			,"C",""})
		oINNWebTable:AddHead({"Produto"			,"C",""})
		oINNWebTable:AddHead({"Descrição"		,"C",""})
		oINNWebTable:AddHead({"NCM"				,"C",""})
		oINNWebTable:AddHead({"Local"			,"C",""})
		oINNWebTable:AddHead({"TES"				,"C",""})
		oINNWebTable:AddHead({"CFOP"			,"C",""})
		oINNWebTable:AddHead({"Emissao"			,"D",""})
		oINNWebTable:AddHead({"Quantidade"		,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Valor Unitário"	,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Valor Total"		,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Qtd Liberada"	,"N","@E 99,999,999,999.999"})
		oINNWebTable:AddHead({"Estq?"			,"C",""})
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		IF !Empty(cNumPV)
			_cQuery += " AND C6_NUM = '"+Alltrim(cNumPV)+"' "
		ENDIF
		IF !Empty(cCodigo)
			_cQuery += " AND C6_PRODUTO = '"+Alltrim(cCodigo)+"' "
		ENDIF
		IF !Empty(cAlmox)
			_cQuery += " AND C6_LOCAL = '"+Alltrim(cAlmox)+"' "
		ENDIF
		IF !Empty(cCliente)
			_cQuery += " AND C6_CLI = '"+Alltrim(cCliente)+"' "
		ENDIF
		IF !Empty(cLoja)
			_cQuery += " AND C6_LOJA = '"+Alltrim(cLoja)+"' "
		ENDIF
		IF !Empty(cNFNum)
			_cQuery += " AND C6_NOTA = '"+Alltrim(cNFNum)+"' "
		ENDIF
		_cQuery := '%'+_cQuery+'%'
	
		BeginSql alias 'TMP'
			SELECT
				C6_NUM,
				C6_ITEM,
				C6_PRODUTO,
				C6_LOCAL,
				C6_TES,
				C6_DESCRI,
				C6_QTDVEN,
				C6_PRCVEN,
				C6_VALOR,
				C6_CLI,
				C6_LOJA,
				C6_CF,
				C6_QTDLIB,
				C5_EMISSAO,
				B1_POSIPI,
				B1_TIPO,
				SC5.R_E_C_N_O_ REC
			FROM %table:SC6% SC6
			INNER JOIN %table:SC5% SC5 ON C5_FILIAL = C6_FILIAL AND C6_NUM = C5_NUM
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xfilial:SB1% AND C6_PRODUTO = B1_COD
			WHERE C5_FILIAL = %xfilial:SC4%
			  AND SB1.%notDel%
			  AND SC6.%notDel%
			  AND SC5.%notDel%
			  %exp:_cQuery%
			ORDER BY C6_NUM , C6_ITEM
		EndSql

		WHILE (TMP->(!EOF()))
		
			oINNWebTable:AddCols({	TMP->C6_NUM,;
									TMP->C6_ITEM,;
									TMP->C6_CLI + "-" + TMP->C6_LOJA,;
									TMP->C6_PRODUTO,;
									Alltrim(TMP->C6_DESCRI) + " - " + Alltrim(TMP->B1_TIPO),;
									TMP->B1_POSIPI,;
									TMP->C6_LOCAL,;
									TMP->C6_TES,;
									TMP->C6_CF,;
									sTod(TMP->C5_EMISSAO),;
									TMP->C6_QTDVEN,;
									TMP->C6_PRCVEN,;
									TMP->C6_VALOR,;
									TMP->C6_QTDLIB,;
									IF( Rastro(TMP->C6_PRODUTO) , "Sim" , "Não" )})

			oINNWebTable:SetLink(  , 1 , "?x=wPV&xID="+TMP->C6_NUM )
						
			TMP->(DbSkip())
	
		ENDDO  
					
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif
			
	endif

Return
