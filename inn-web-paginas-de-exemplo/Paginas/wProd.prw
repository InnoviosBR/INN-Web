#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function wProd(oINNWeb)

	Local xID	:= Val(iif(Valtype(HttpGet->xID) == "C" .and. !empty(HttpGet->xID),HttpGet->xID,""))
			
	if xID > 0			

		dbSelectArea("SB1")
		SB1->(dbGoTo(xID))

		if SB1->(Recno()) == xID .and. SB1->B1_FILIAL == xFilial("SB1")
					
			oINNWebbBrowse := INNWebBrowse():New( oINNWeb )
			oINNWebbBrowse:SetTabela( "SB1" )
			oINNWebbBrowse:SetRec( xID )
			
			dbSelectArea("SB1")
			SB1->(dbGoTo(xID))
			dbSelectArea("SB5")
			SB5->(dbSetOrder(1))
			IF SB5->(dbSeek(xFilial("SB5")+SB1->B1_COD))
				oINNWebbBrowse := INNWebBrowse():New( oINNWeb )
				oINNWebbBrowse:SetTabela( "SB5" )
				oINNWebbBrowse:SetRec( SB5->(Recno()) )
			ENDIF

			fGaleria(xID)
			
			oINNWeb:SetTitNot("Dados detalhados do produto")

		else

			oINNWeb:AddCallOut("Produto não encontrado.","danger")
			oINNWeb:SetTitle("Produto ( - )")

		endif

	else
		fPesquisa(@oINNWeb)  
	endif

	oINNWeb:SetTitle("Produtos")
	oINNWeb:SetIdPgn("wProd")
	
Return(.T.)


Static Function fPesquisa(oINNWeb)

	Local _cQuery	:= ""
		
	Local aDescOr 	:= {}
	Local aDescAnd 	:= {}
	Local nY		:= 0
	
	Local cCodigo	:= Alltrim(Upper(iif(Valtype(HttpGet->Codigo) == "C" .and. !empty(HttpGet->Codigo),HttpGet->Codigo,"")))
	Local cProdTipo	:= Upper(iif(Valtype(HttpGet->ProdTipo) == "C" .and. !empty(HttpGet->ProdTipo),HttpGet->ProdTipo,""))
	Local cDesc 	:= iif(Valtype(HttpGet->desc) == "C" .and. !empty(HttpGet->desc),HttpGet->desc,"")
	Local cGrupo	:= iif(Valtype(HttpGet->Grupo) == "C" .and. !empty(HttpGet->Grupo),HttpGet->Grupo,"")
	Local cNCM		:= iif(Valtype(HttpGet->NCM) == "C" .and. !empty(HttpGet->NCM),HttpGet->NCM,"")

	cDesc := StrTran(cDesc,"[%]","%")		
	cDesc := StrTran(cDesc,"%","[%]")
	cDesc := StrTran(cDesc,"'",",")		
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
	oINNWebParam:addText( {'codigo'		,'Código'	,15,cCodigo		,.F.})
	oINNWebParam:addText( {'ProdTipo'	,'Tipo'		, 2,cProdTipo	,.F.})
	oINNWebParam:addText( {'desc'		,'Descrição',50,cDesc		,.F.})
	oINNWebParam:addText( {'Grupo'		,'Grupo'	, 4,cGrupo		,.F.})
	oINNWebParam:addText( {'NCM'		,'NCM'		, 8,cNCM		,.F.})
	
	if !Empty(cCodigo) .or. !Empty(cProdTipo) .or. !Empty(cDesc) .or. !Empty(cGrupo) .or. !Empty(cNCM)

		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:AddHead({"Código"				,"C","",.T.})
		oINNWebTable:AddHead({"Descrição"			,"C",""})
		oINNWebTable:AddHead({"Tipo"				,"C",""})
		oINNWebTable:AddHead({"Un Med"				,"C",""})
		oINNWebTable:AddHead({"Armazem"				,"C",""})
		oINNWebTable:AddHead({"Grupo"				,"C",""})
		oINNWebTable:AddHead({"Origem"				,"C",""})
		oINNWebTable:AddHead({"IPI"					,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"Saldo Disponivel"	,"N","@E 99,999,999,999.999",.T.})
		oINNWebTable:AddHead({"Custo arbitrado"		,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"Cto Real"			,"N","@E 99,999,999,999.99",.T.})
		oINNWebTable:AddHead({"NCM"					,"C",""})
		oINNWebTable:AddHead({"Estq?"				,"C",""})
		oINNWebTable:AddHead({"Bloqueio"			,"C",""})
			
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif

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
		
		IF !Empty(cNCM)
			_cQuery += " AND B1_POSIPI LIKE '"+Alltrim(cNCM)+"%' "
		ENDIF
		
		IF !Empty(cCodigo)
			_cQuery += " AND UPPER(B1_COD) LIKE '%"+cCodigo+"%' "
		ENDIF	
		IF !Empty(cGrupo)
			_cQuery += " AND B1_GRUPO = '"+Alltrim(cGrupo)+"' "
		ENDIF
		_cQuery := '%'+_cQuery+'%'
		
		BeginSql alias 'TMP'
			SELECT
				B1_FILIAL,
				B1_COD,
				B1_DESC,
				B1_TIPO,
				B1_UM,
				B1_LOCPAD,
				B1_GRUPO,
				B1_POSIPI,
				B1_QE,
				B1_PRV1,
				B1_PE,
				B1_TIPE,
				B1_MSBLQL,
				B1_ORIGEM,
				B1_IPI,
				B1_CUSTD,
				B1_UPRC,
				B1_UCOM,
				(SELECT AVG(B2_CM1) FROM %table:SB2% WHERE B2_FILIAL = %xfilial:SB2% AND B2_COD = B1_COD AND %notDel% ) B2_CM1,
				R_E_C_N_O_ REC
			FROM %table:SB1% SB1
			WHERE B1_FILIAL = %xfilial:SB1%
			  AND SB1.%notDel%
			  %exp:_cQuery%
			ORDER BY B1_COD
		EndSql
					
		WHILE (TMP->(!EOF()))
		
			SB1->(MsSeek(xFilial("SB1")+TMP->B1_COD))
			SB2->(MsSeek(xFilial("SB2")+TMP->B1_COD))
			
			_nSaldo := 0
			
			While !( SB2->(eof()) ) .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == TMP->B1_COD
				_nSaldo += SaldoSB2()
				SB2->(dbSkip())
			EndDo
						    							 
			oINNWebTable:AddCols({	TMP->B1_COD,;
									TMP->B1_DESC,;
									TMP->B1_TIPO + " - " + POSICIONE("SX5",1,xFilial("SX5")+"02"+TMP->B1_TIPO,"X5_DESCRI"),;
									TMP->B1_UM + " - " + POSICIONE("SAH",1,xFilial("SAH")+TMP->B1_UM,"AH_UMRES"),;
									TMP->B1_LOCPAD + " - " + POSICIONE("NNR",1,TMP->B1_FILIAL+TMP->B1_LOCPAD,"NNR_DESCRI"),;
									TMP->B1_GRUPO + " - " + POSICIONE("SBM",1,xFilial("SBM")+TMP->B1_GRUPO,"BM_DESC"),;
									TMP->B1_ORIGEM + " - " + POSICIONE("SX5",1,xFilial("SX5")+"S0"+TMP->B1_ORIGEM,"X5_DESCSPA"),;
									TMP->B1_IPI,;
									_nSaldo,;
									0,;
									B1Cust(TMP->B1_COD),;
									TMP->B1_POSIPI,;
									IF( Rastro(TMP->B1_COD) , "Sim" , "Não" ),;
									TMP->B1_MSBLQL + fVOpcBox(TMP->B1_MSBLQL,"","B1_MSBLQL")})
						
			oINNWebTable:SetLink(  , 1 , {"?x=wProd&xID="+cValToChar( TMP->REC ),"PROD"+cValToChar( TMP->REC )} )
						
			TMP->(dbSkip())
							  			
		EndDo
					                                      
		if select("TMP") <> 0
			TMP->(dbCloseArea())
		endif
		
	endif
		
Return


Static Function fGaleria(xID) 
    	   
	dbSelectArea("SB1")
	SB1->(dbGoto(xID))
    
	oINNWebImgProd := INNWebImgProd():New( oINNWeb )
	oINNWebImgProd:SetProduto( SB1->B1_COD )
	oINNWebImgProd:GetGaleria()

	oINNWeb:AddHeadBtn( {"wProdFotos","produto="+SB1->B1_COD,"Galeria Fotos"} )
	
Return 
