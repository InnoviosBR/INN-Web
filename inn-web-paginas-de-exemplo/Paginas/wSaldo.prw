#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wSaldo(oINNWeb)

	Local _cQuery	:= ""
		
	Local cCodigo	:= ""
	Local cAlmox	:= ""
	Local cDesc 	:= ""
	Local aDescOr 	:= {}
	Local aDescAnd 	:= {}
	Local nY
	
	cCodigo		:= Alltrim(UPPER(iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")))
	cAlmox 		:= iif(Valtype(HttpGet->almox) == "C" .and. !empty(HttpGet->almox),HttpGet->almox,"")
	cProdTipo	:= upper(iif(Valtype(HttpGet->ProdTipo) == "C" .and. !empty(HttpGet->ProdTipo),HttpGet->ProdTipo,""))
	cDesc 		:= iif(Valtype(HttpGet->desc) == "C" .and. !empty(HttpGet->desc),HttpGet->desc,"")
	ccombo 		:= iif(Valtype(HttpGet->combo) == "C" .and. !empty(HttpGet->combo),HttpGet->combo,"S")
	cmultiplo 	:= iif(Valtype(HttpGet->multiplo) == "C" .and. !empty(HttpGet->multiplo),HttpGet->multiplo,"S")
	dinicio 	:= cTod(iif(Valtype(HttpGet->dinicio) == "C" .and. !empty(HttpGet->dinicio),HttpGet->dinicio,""))


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

	oINNWebParam := INNWebParam():New( oINNWeb )	
	oINNWebParam:addText( {'codigo'		,'Código'		,15,cCodigo		,.F.})
	oINNWebParam:addText( {'almox'		,'Armazem'		, 2,cAlmox		,.F.})
	oINNWebParam:addText( {'ProdTipo'	,'Tipo'			, 2,cProdTipo	,.F.})
	oINNWebParam:addText( {'desc'		,'Descrição'	,30,cDesc		,.F.})	

	if !Empty(cCodigo) .or. !Empty(cAlmox) .or. !Empty(cProdTipo) .or. !Empty(cDesc)
						
		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({RetTitle("B1_COD")		,"C",""})
		oINNWebTable:AddHead({RetTitle("B1_DESC")		,"C",""})			
		oINNWebTable:AddHead({RetTitle("B1_TIPO")		,"C",""})
		oINNWebTable:AddHead({RetTitle("B2_LOCAL")		,"C",""})
		oINNWebTable:AddHead({"Sld. Lote"				,"N",PesqPict("SB8","B8_SALDO")})
		oINNWebTable:AddHead({"Sld. End"				,"N",PesqPict("SBF","BF_QUANT")})
		oINNWebTable:AddHead({"Disponivel"				,"N",PesqPict("SB2","B2_QATU")})
		oINNWebTable:AddHead({RetTitle("B2_QATU")		,"N",PesqPict("SB2","B2_QATU")})
		oINNWebTable:AddHead({RetTitle("B2_QEMP")		,"N",PesqPict("SB2","B2_QEMP")})
		oINNWebTable:AddHead({RetTitle("B2_QEMPSA")		,"N",PesqPict("SB2","B2_QEMPSA")})
		oINNWebTable:AddHead({RetTitle("B2_RESERVA")	,"N",PesqPict("SB2","B2_RESERVA")})
		oINNWebTable:AddHead({RetTitle("B2_QPEDVEN")	,"N",PesqPict("SB2","B2_QPEDVEN")})
		oINNWebTable:AddHead({RetTitle("B2_SALPEDI")	,"N",PesqPict("SB2","B2_SALPEDI")})
		oINNWebTable:AddHead({RetTitle("B2_QACLASS")	,"N",PesqPict("SB2","B2_QACLASS")})		
		oINNWebTable:AddHead({RetTitle("B2_QTNP")		,"N",PesqPict("SB2","B2_QTNP")})
		oINNWebTable:AddHead({RetTitle("B2_QNPT")		,"N",PesqPict("SB2","B2_QNPT")})
		oINNWebTable:AddHead({RetTitle("B2_QTER")		,"N",PesqPict("SB2","B2_QTER")})
		oINNWebTable:AddHead({RetTitle("B1_MSBLQL")		,"C",""})
		
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

		IF !Empty(cCodigo)
			_cQuery += " AND UPPER(B1_COD) LIKE '%"+cCodigo+"%' "
		ENDIF
		IF !Empty(cAlmox)
			_cQuery += " AND B2_LOCAL LIKE '%"+Alltrim(cAlmox)+"%' "
		ENDIF
		
		IF Len(aDescOr) > 0 
			_cQuery += " AND ( " 
			for nY := 1 To len(aDescOr)
				_cQuery += IIF(nY > 1," OR ","")
				_cQuery += " UPPER(B1_DESC) LIKE '%"+aDescOr[nY]+"%' "
			next
			_cQuery += " ) "
		ENDIF
		
		IF Len(aDescAnd) > 0 
			_cQuery += " AND ( " 
			for nY := 1 To len(aDescAnd)
				_cQuery += IIF(nY > 1," AND ","")
				_cQuery += " UPPER(B1_DESC) LIKE '%"+aDescAnd[nY]+"%' "
			next
			_cQuery += " ) "
		ENDIF
		
		IF !Empty(cProdTipo)
			_cQuery += " AND UPPER(B1_TIPO) = '"+Alltrim(cProdTipo)+"' "
		ENDIF
		_cQuery := '%'+_cQuery+'%'
	
		BeginSql alias 'TMP'
			SELECT
			B2_FILIAL,
			B2_COD,
			B2_LOCAL
			,(SELECT SUM(B8_SALDO) FROM %table:SB1% SB8 WHERE B2_FILIAL = B8_FILIAL AND B2_COD = B8_PRODUTO AND B2_LOCAL = B8_LOCAL AND %notDel%) B8_SALDO
			,(SELECT SUM(BF_QUANT) FROM %table:SB1% SBF WHERE B2_FILIAL = BF_FILIAL AND B2_COD = BF_PRODUTO AND B2_LOCAL = BF_LOCAL AND %notDel%) BF_QUANT
			FROM %table:SB1% SB1
			INNER JOIN %table:SB2% SB2 ON B2_FILIAL = %xfilial:SB2% AND B2_COD = B1_COD
			WHERE SB1.B1_FILIAL = %xfilial:SB1%
			AND SB2.%notDel%
			AND SB1.%notDel%
			%exp:_cQuery%
			ORDER BY B2_COD , B2_LOCAL
		EndSql

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(dbGoTop())
				
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		SB2->(dbGoTop())
		
		DbSelectArea("TMP")
		TMP->(dbGoTop())
						
		WHILE (TMP->(!EOF()))

			SB1->(MsSeek(xFilial("SB1")+TMP->B2_COD))
			SB2->(MsSeek(xFilial("SB2")+TMP->B2_COD+TMP->B2_LOCAL))
							
			oINNWebTable:AddCols({	SB1->B1_COD,;
									SB1->B1_DESC,;
									SB1->B1_TIPO,;
									SB2->B2_LOCAL,;
									TMP->B8_SALDO,;
									TMP->BF_QUANT,;
									SaldoSB2(),;
									SB2->B2_QATU,;
									SB2->B2_QEMP,;
									SB2->B2_QEMPSA,;
									SB2->B2_RESERVA,;
									SB2->B2_QPEDVEN,;
									SB2->B2_QACLASS,;
									SB2->B2_SALPEDI,;
									SB2->B2_QTNP,;
									SB2->B2_QNPT,;
									SB2->B2_QTER,;
									SB1->B1_MSBLQL + fVOpcBox(SB1->B1_MSBLQL,"","B1_MSBLQL")})
						
			TMP->(dbSkip())
							  			
		EndDo
						
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif
		
	endif
	
	oINNWeb:SetTitle("Saldos de Produtos") 
	oINNWeb:SetIdPgn("wSaldo")
	oINNWeb:SetTitNot("Descrição da pagina")
				
Return(.T.)
