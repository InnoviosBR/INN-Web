#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wTitPag(oINNWeb)

	Local nY
	Local aHead 	:= {}
	Local _cQuery	:= ""
	
	Local oTitPag   := nil

	Local cPrefixo	:= iif(Valtype(HttpGet->prefixo) == "C" .and. !empty(HttpGet->prefixo),HttpGet->prefixo,"")		
	Local cTitulo	:= iif(Valtype(HttpGet->titulo) == "C" .and. !empty(HttpGet->titulo),HttpGet->titulo,"")
	Local cParcela	:= iif(Valtype(HttpGet->parcela) == "C" .and. !empty(HttpGet->parcela),HttpGet->parcela,"")
	Local cFornece	:= iif(Valtype(HttpGet->fornecedor) == "C" .and. !empty(HttpGet->fornecedor),HttpGet->fornecedor,"")
	Local cLoja		:= iif(Valtype(HttpGet->loja) == "C" .and. !empty(HttpGet->loja),HttpGet->loja,"")
	Local cCGC		:= iif(Valtype(HttpGet->cgc) == "C" .and. !empty(HttpGet->cgc),HttpGet->cgc,"")

	cCGC		:= Numtrac(cCGC)
	cPrefixo	:= Alltrim(cPrefixo)
	cTitulo		:= Alltrim(cTitulo)
	cParcela	:= Alltrim(cParcela)
	cFornece	:= Alltrim(cFornece)		
	cLoja		:= Alltrim(cLoja)
	
	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText( {'prefixo'	,'Prefixo'		, 3,cPrefixo	,.F.})
	oINNWebParam:addText( {'titulo'		,'Titulo'		, 9,cTitulo		,.F.})		
	oINNWebParam:addText( {'parcela'	,'Parcela'		, 2,cParcela	,.F.})
	oINNWebParam:addText( {'fornecedor'	,'Fornecedor'	, 6,cFornece	,.F.})
	oINNWebParam:addText( {'loja'		,'Loja'			, 2,cLoja		,.F.})
	oINNWebParam:addText( {'cgc'		,'CNPJ/CPF'		,18,cCGC		,.F.})
	
	if !empty(cPrefixo) .or. !empty(cTitulo) .or. !empty(cParcela) .or. !empty(cFornece) .or. !empty(cLoja) .or. !empty(cCGC)
	
		oTitPag := ClsTitPag():New()

		oResumo := INNWebBrowse():New( oINNWeb )		
		oTableTitulos := INNWebTable():New( oINNWeb )
		oTableBaixas := INNWebTable():New( oINNWeb )

		oTableTitulos:SetTitle( "Titulos" )
		oTableTitulos:AddHead({"Prefixo"	,"C",""})
		oTableTitulos:AddHead({"Titulo"		,"C",""})
		oTableTitulos:AddHead({"Parcela"	,"C",""})
		oTableTitulos:AddHead({"Fornecedor"	,"C",""})
		oTableTitulos:AddHead({"Loja"		,"C",""})
		oTableTitulos:AddHead({"Tipo"		,"C",""})
		oTableTitulos:AddHead({"Valor"		,"N","@E 99,999,999,999.99"})
		oTableTitulos:AddHead({"Saldo"		,"N","@E 99,999,999,999.99"})
		oTableTitulos:AddHead({"Vencimento"	,"D",""})
		oTableTitulos:AddHead({"Baixa"		,"D",""})
		oTableTitulos:AddHead({"Movimento"	,"D",""})
	
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		_cQuery += iif(!Empty(cPrefixo)," AND E2_PREFIXO LIKE '%"+cPrefixo+"' ","")
		_cQuery += iif(!Empty(cTitulo)," AND E2_NUM LIKE '%"+cTitulo+"' ","")
		_cQuery += iif(!Empty(cParcela)," AND E2_PARCELA LIKE '%"+cParcela+"' ","")
		if !Empty(cFornece) .or. !Empty(cLoja) .or. !Empty(cCGC)
			_cQuery += " AND E2_FORNECE+E2_LOJA IN ( "
			_cQuery += " SELECT A2_COD+A2_LOJA FROM "+RetSQLName("SA2")+" SA2 WHERE A2_FILIAL = '"+xFilial("SA2")+"' AND D_E_L_E_T_ = '' "
			_cQuery += iif(!Empty(cFornece)," AND A2_COD = '"+cFornece+"' ","")
			_cQuery += iif(!Empty(cLoja)," AND A2_LOJA = '"+cLoja+"' ","")
			_cQuery += iif(!Empty(cCGC)," AND A2_CGC LIKE '%"+cCGC+"%' ","")
			_cQuery += " ) "			
		endif
		_cQuery += iif(!Empty(cFornece)," AND E2_FORNECE = '"+cFornece+"' ","")
		_cQuery += iif(!Empty(cLoja)," AND E2_LOJA = '"+cLoja+"' ","")
		_cQuery := '%'+_cQuery+'%'

		BeginSql alias 'TMP'
			SELECT E2_PREFIXO,E2_NUM,E2_PARCELA,E2_FORNECE,E2_LOJA,E2_TIPO,E2_VALOR,E2_SALDO,E2_VENCTO,E2_BAIXA,E2_MOVIMEN FROM %table:SE2%
			WHERE E2_FILIAL = %xfilial:SE2%
			AND %notDel%
			%exp:_cQuery%
			ORDER BY %exp:SqlOrder(SE2->(IndexKey()))%
				
		EndSql
		
		While !( TMP->(eof()))			
			if oTitPag:SetTitulo(TMP->E2_PREFIXO,TMP->E2_NUM,TMP->E2_PARCELA,TMP->E2_FORNECE,TMP->E2_LOJA)
				oTableTitulos:AddCols({TMP->E2_PREFIXO,TMP->E2_NUM,TMP->E2_PARCELA,TMP->E2_FORNECE,TMP->E2_LOJA,TMP->E2_TIPO,TMP->E2_VALOR,TMP->E2_SALDO,sTod(TMP->E2_VENCTO),sTod(TMP->E2_BAIXA),sTod(TMP->E2_MOVIMEN)})
				oTitPag:ExeCalc()
			else
				oINNWeb:AddAlert('Titulo não encontrado!')
			endif
			TMP->(dbSkip())			
		Enddo
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif 

		aDados := {}
		Aadd(aDados,{"oTitPag:Pago"		,"Data Pagamento"	,"D",oTitPag:Pago})
		Aadd(aDados,{"oTitPag:UltBx"	,"Data Ultima Baixa","D",oTitPag:UltBx})
		Aadd(aDados,{"oTitPag:Acres"	,"Acrescimo"		,"N",oTitPag:Acres})
		Aadd(aDados,{"oTitPag:Decres"	,"Descrescimo"		,"N",oTitPag:Decres})
		Aadd(aDados,{"oTitPag:Abatim"	,"Abatimento"		,"N",oTitPag:Abatim})
		Aadd(aDados,{"oTitPag:Valor"	,"Valor"			,"N",oTitPag:Valor})
		Aadd(aDados,{"oTitPag:ValorOri"	,"Valor Original"	,"N",oTitPag:ValorOri})
		Aadd(aDados,{"oTitPag:ValPag"	,"Valor Pago"		,"N",oTitPag:ValPag})
		Aadd(aDados,{"oTitPag:Saldo"	,"Saldo"			,"N",oTitPag:Saldo})
		Aadd(aDados,{"oTitPag:Pagar"	,"A Pagar"			,"N",oTitPag:Pagar})
		Aadd(aDados,{"oTitPag:Juros"	,"Juros"			,"N",oTitPag:Juros})

		oResumo:SetTitle( "Resumo" )
		oResumo:SetDados( aDados )
			
		oTableBaixas:SetTitle( "Baixas" )

		for nY := 1 To Len(aHead)
			oTableBaixas:AddHead( {aHead[nY][1],aHead[nY][2],iif(aHead[nY][2]=="N","@E 99,999,999,999.99","")})
		next nY
		
		oTableBaixas:SetCols( oTitPag:Baixas )
							
	endif
								
	oINNWeb:SetTitle("Contas a Pagar") 
	oINNWeb:SetIdPgn("wTitPag")
	
Return(.T.)
