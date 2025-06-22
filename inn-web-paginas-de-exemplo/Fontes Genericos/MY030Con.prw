#INCLUDE "MATC030.CH"
#INCLUDE "PROTHEUS.CH"
#DEFINE USADO CHR(0)+CHR(0)+CHR(1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡…o    ?MY030Con ?Autor ?Paulo Boschetti       ?Data ?18/03/93 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Envia para funcao que monta o arquivo de trabalho com as   ³±?
±±?         ?movimentacoes e mostra-o na tela                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATC030                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
User Function MY030Con()
	
	LOCAL aSalTel := {} ,nCusMed := 0 ,aSalIni := {}
	LOCAL aArea:=GetArea()

	/*ExecBlock("CHKEXEC",.f.,.f.,"U_MY030Con") PROGRAMA MUITO USADO EM JOB, DISPENSA DE LOG*/
	
	Private lCusUnif  := IIf(FindFunction("A330CusFil"),A330CusFil(),GetNewPar("MV_CUSFIL",.F.))
	
	Private cCadastro := OemtoAnsi("Processo de fechamento de estoque")
	Private aRotina   := {{"Pesquisa","AxPesqui", 0 , 1},{"Consulta","U_MY030Con", 0 , 2}}
	
	PRIVATE aGraph  := {}
	PRIVATE aTrbP   := {}
	PRIVATE aTrbTmp := {}
	PRIVATE aTela   := {}
	PRIVATE aSalAtu := { 0,0,0,0,0,0,0 }
	PRIVATE cPictTotQT:=PesqPictQt("B2_QATU")
	PRIVATE nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0
	PRIVATE cTRBSD1 := CriaTrab(,.F.)
	PRIVATE cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
	PRIVATE cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
	PRIVATE cPictQT := PesqPict("SB2","B2_QATU",18) 
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Grava as movimentacoes no arquivo de trabalho                ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Processa({|| aSalTel := MY030Monta()},, "Produto: "+SB2->B2_COD+" Local: "+SB2->B2_LOCAL)
	
	aSalTel := MY030Monta()
	
	If Len(aTrbP) > 0
		
		If aSalTel[1] > 0 .AND. aSalTel[mv_par05+1] > 0
			nCusMed := aSalTel[mv_par05+1]/aSalTel[1]
		ElseIf aSalTel[1] == 0 .AND. aSalTel[mv_par05+1] == 0
			nCusMed := 0
		ElseIf aSalTel[1] < 0 .AND. aSalTel[mv_par05+1] < 0
			nCusMed := aSalTel[mv_par05+1]/aSalTel[1]		
		Else
			nCusMed := aSalTel[mv_par05+1]
		Endif
		aAdd(aSalIni,Transf(aSaltel[1],PesqPict("SD1","D1_QUANT",18)))
		aAdd(aSalIni,Transf(nCusMed,PesqPict("SB2","B2_CM1")))
		aAdd(aSalIni,Transf(aSaltel[mv_par05+1],PesqPict("SB9","B9_VINI1")))
		
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Apaga Arquivos Temporarios                     ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FERASE(cTrbSD1+GetDBExtension())
		FERASE(cTrbSD1+OrdbagExt())
		FERASE(cTrbSD2+GetDBExtension())
		FERASE(cTrbSD2+OrdbagExt())
		FERASE(cTrbSD3+GetDBExtension())
		FERASE(cTrbSD3+OrdbagExt())
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Recupera a Ordem Original do arquivo principal               ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSelectArea("SD2")
	dbSetOrder(1)
	dbSelectArea("SD3")
	dbSetOrder(1)
	RestArea(aArea)
		
Return({aSalTel,aSalIni,aTrbP})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡…o    ?Y030Monta?Autor ?Paulo Boschetti       ?Data ?18/03/93 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Grava arquivo de trabalho                                  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?Nenhum 						                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpA1 = Array do saldo inicial	                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?Generico                                                   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?        ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?rogramador ?Data   ?BOPS ? Motivo da Alteracao                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arcio Lopes?7/04/06?6428 ?Foi incluso a verificacao quando eh      ³±?
±±?		   ?	?   ?emitida a nota sobre cupom, ou seja, nao ³±?
±±?		   ?	?   ?eh para ser apresentada no Kardex essa   ³±?
±±?		   ?	?   ?nota.                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/

Static Function MY030Monta()

	Static lIxbConTes  := NIL
	Local dCntData
	Local nCusMed   := 0
	Local cIdent    := ""
	Local aSaldoIni := {}
	Local cDocumento:=""
	Local aRetorno  := {cPictQT, cPictTotQT}
	Local nInd,cCondicao
	Local cNumSeqTr := "" , nRegTr := 0
	Local cAlias    := "", cSeqIni := ""
	Local i         := 0
	Local aDados	:= {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Verifica se existe ponto de entrada                          ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local lTesNEst  := .F.
	Local lMc030Idmv:= ExistBlock("MC030IDMV")
	
	// Indica se esta listando relatorio do almox. de processo
	Local lLocProc  := mv_par03 == SuperGetMV("MV_LOCPROC")
	// Indica se deve imprimir movimento invertido (almox. de processo)
	Local lInverteMov:= .F.
	Local cDepTrf    := SuperGetMv("MV_DEPTRANS",.F.,"95")	// Dep.transferencia
	Local lTranSB2   := SuperGetMv("MV_TRANSB2",.F.,.F.)	// Atualiza saldos de transferencia
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//? Indica produto MANUTENCAO (MV_PRODMNT) qdo integrado com MNT       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	Local cAliasSD2 := "SD2" // por default deve ser a tabela SD2
	Local cQuerySD2 := ""
	Local lQuerySD2 := .F.    
	//Local aProdsMNT := {}
	
	//ProcRegua(mv_par02 - mv_par01)
	      
	lIxbConTes := IF(lIxbConTes == NIL,ExistBlock("MTAAVLTES"),lIxbConTes)
	       
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Verifica se utiliza custo unificado por Empresa/Filial       ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE lCusUnif := IIf(FindFunction("A330CusFil"),A330CusFil(),SuperGetMV("MV_CUSFIL",.F.))
	lCusUnif:=lCusUnif .And. "*" $ mv_par03
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Calcula o Saldo Inicial do Produto             ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusUnif
		aArea:=GetArea()
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek(xFilial()+SB1->B1_COD)
		While !Eof() .And. B2_FILIAL+B2_COD == xFilial()+SB1->B1_COD
			aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,mv_par01)
			For i:=1 to Len(aSalAtu)
				aSalAtu[i] += aSalAlmox[i]
			Next i
			dbSkip()
		EndDo
		RestArea(aArea)
	Else
		aSalAtu  := CalcEst(SB1->B1_COD,mv_par03,mv_par01)
	EndIf
	aSaldoIni:= ACLONE(aSalAtu)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Ponto de entrada para Altera‡„o de Picture.    ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock('MC030PIC')
		aRetorno := ExecBlock('MC030PIC', .F., .F., aRetorno)
		If ValType(aRetorno) == 'A'
			cPictQT    := aRetorno[1]
			cPictTotQT := aRetorno[2]
		EndIf
	EndIf
	dCntData  := mv_par01
	dbSelectArea("SD1")
	If mv_par07 == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Cria Indice condicional p/ Custo Unificado                   ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCusUnif
			dbSelectArea("SD1")
			cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_NUMSEQ"
			cFiltro:=dbFilter()
			IndRegua("SD1",cTrbSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029) // Selecionando Registros
			nInd := RetIndex("SD1")
			#IFNDEF TOP
				dbSetIndex(cTrbSD1+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd+1)
		Else
			dbSetOrder(7)
		EndIf
	Else
		If lCusUnif
			cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
		Else
			cIndice:="D1_FILIAL+D1_COD+D1_LOCAL+DTOS(D1_DTDIGIT)+D1_SEQCALC+D1_NUMSEQ"
		EndIf
		cFiltro:=dbFilter()
		IndRegua("SD1",cTRBSD1,cIndice,,"D1_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029) // Selecionando Registros
		nInd := RetIndex("SD1")
		#IFNDEF TOP
			dbSetIndex(cTRBSD1+OrdBagExt())
		#ENDIF
		dbSetOrder(nInd+1)
	Endif
	dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+dtos(dCntData),.T.)
	         
	#IFDEF TOP
		cQuerySD2 := "SELECT SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO "
		cQuerySD2 +=     " , SD2.D2_NUMSEQ, SD2.D2_LOCAL, SD2.D2_SEQCALC, SD2.D2_ORIGLAN "
		cQuerySD2 +=     " , SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA "
		cQuerySD2 +=     " , SD2.D2_REMITO, SD2.D2_TPDCENV, SD2.D2_TES, SD2.R_E_C_N_O_ RECSD2 "
		cQuerySD2 +=  " FROM "+ RetSQLTab('SD2')
		cQuerySD2 += " WHERE SD2.D2_FILIAL = '"+xFilial("SD2")+"' "
		cQuerySD2 +=   " AND SD2.D2_COD = '" + SB1->B1_COD + "' "
		If !lCusUnif
			cQuerySD2 += " AND SD2.D2_LOCAL = '" + mv_par03 + "' "
		EndIf
		cQuerySD2 += " AND SD2.D2_EMISSAO >= '" + DToS(dCntData) + "' "
		cQuerySD2 += " AND SD2.D2_EMISSAO <= '" + DToS(mv_par02) + "' "
		cQuerySD2 += " AND SD2.D_E_L_E_T_ = ' ' "
	
		If mv_par07 == 1
			// Ordem de digitacao
			If lCusUnif
				cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_NUMSEQ "
			Else
				cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, SD2.D2_EMISSAO, SD2.D2_NUMSEQ "
			EndIf
		Else
			// Ordem de calculo
			If lCusUnif
				cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_EMISSAO, SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
			Else
				cQuerySD2 += " ORDER BY SD2.D2_FILIAL, SD2.D2_COD, SD2.D2_LOCAL, SD2.D2_EMISSAO, SD2.D2_SEQCALC, SD2.D2_NUMSEQ "
			EndIf
		EndIf
		lQuerySD2 := .T.
		cAliasSD2 := GetNextAlias()
		cQuerySD2 := ChangeQuery( cQuerySD2 )
		DbUseArea( .T., 'TOPCONN', TcGenQry(,,cQuerySD2), cAliasSD2, .T., .F. )
	#ELSE
		dbSelectArea(cAliasSD2)
		If mv_par07 == 1
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Cria Indice condicional p/ Custo Unificado                   ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCusUnif
				cIndice:="D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_NUMSEQ"
			Else
				cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_NUMSEQ"
			EndIf
			cFiltro:=dbFilter()
			IndRegua("SD2",cTrbSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029)  // Selecionando Registros
			nInd := RetIndex("SD2")
			dbSetIndex(cTrbSD2+OrdBagExt())
			dbSetOrder(nInd+1)
		Else
			If lCusUnif
				cIndice:="D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_SEQCALC+D2_NUMSEQ"
			Else
				cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+DTOS(D2_EMISSAO)+D2_SEQCALC+D2_NUMSEQ"
			EndIf
			cFiltro:=dbFilter()
			IndRegua("SD2",cTRBSD2,cIndice,,"D2_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029) // Selecionando Registros
			nInd := RetIndex("SD2")
			dbSetIndex(cTRBSD2+OrdBagExt())
			dbSetOrder(nInd+1)
		EndIf
		dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+dtos(dCntData),.T.)
	#ENDIF
	
	dbSelectArea("SD3")
	If mv_par07 ==1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Cria Indice condicional p/ Custo Unificado ou Aprop.Indireta ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCusUnif .Or. lLocProc
			dbSelectArea("SD3")
			cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ"
			cFiltro:=dbFilter()
			IndRegua("SD3",cTrbSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029)  // Selecionando Registros
			nInd := RetIndex("SD3")
			#IFNDEF TOP
				dbSetIndex(cTrbSD3+OrdBagExt())
			#ENDIF
			dbSetOrder(nInd+1)
		Else
			dbSetOrder(7)
		EndIf
	Else
		If lCusUnif .Or. lLocProc
			cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
		Else
			cIndice:="D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_SEQCALC+D3_NUMSEQ"
		EndIf
		cFiltro:=dbFilter()
		IndRegua("SD3",cTRBSD3,cIndice,,"D3_COD == '" + SB1->B1_COD + "'" + If(!Empty(cFiltro)," .AND. " + cFiltro,""),STR0029) // Selecionando Registros
		nInd := RetIndex("SD3")
		#IFNDEF  TOP
			dbSetIndex(cTRBSD3+OrdBagExt())
		#ENDIF
		dbSetOrder(nInd+1)
	EndIf
	dbSeek(cFilial+SB1->B1_COD+If(lCusUnif.Or.lLocProc,"",mv_par03)+dtos(dCntData),.T.)
	
	While .T.
		cSeqIni := ""
		cAlias  := ""
		IncProc()
	
		dbSelectArea("SD1")
		Do While !Eof() .AND. D1_FILIAL == cFilial .AND. D1_DTDIGIT == dCntData .AND. D1_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,D1_LOCAL == mv_par03)
			If D1_ORIGLAN $ "LF"
				dbSkip()
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Despreza Notas Fiscais com Remitos                           ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisloc<>"BRA" .AND. !Empty(D1_REMITO)
				dbSkip()
				Loop
			EndIf
			SF4->(dbSeek(cFilial+SD1->D1_TES))
			If SF4->F4_ESTOQUE # "S"
				dbSkip()
				Loop
			EndIf
			cSeqIni  := If(mv_par07==1,D1_NUMSEQ,D1_SEQCALC+D1_NUMSEQ)
			cAlias   := Alias()
			aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
			dbSkip()
			Loop
		EndDo
		
		dbSelectArea("SD3")
		Do While !Eof() .AND. D3_FILIAL == cFilial .AND. D3_EMISSAO == dCntData .AND. D3_COD == SB1->B1_COD .AND. If(lCusUnif.Or.lLocProc,.T.,D3_LOCAL == mv_par03)
			If !D3Valido()
				dbSkip()
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Nao imprimir os produtos que estao no armazem de transito                  ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc <> "BRA" .And. !lTranSB2 .And. AllTrim(SD3->D3_LOCAL) == AllTrim(cDepTrf)
				dbSkip()
				Loop
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Quando movimento ref apropr. indireta, so considera os         ?
			//?movimentos com destino ao almoxarifado de apropriacao indireta.?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lInverteMov:=.F.
			If D3_LOCAL <> mv_par03 .Or. lCusUnif
				If !(Substr(D3_CF,3,1) == "3")
					If !lCusUnif
						dbSkip()
						Loop
					EndIf
				Else
					lInverteMov:=.T.
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Caso seja uma transferencia de localizacao verifica se lista   ?
			//?o movimento ou nao                                             ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par08 == 2 .AND. Substr(D3_CF,3,1) == "4"
				cNumSeqTr := SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL
				nRegTr    := Recno()
				dbSkip()
				If SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL == cNumSeqTr
					dbSkip()
					Loop		
				Else
					dbGoto(nRegTr)
				EndIf
			EndIf
			cSeqIni  := If(mv_par07==1,D3_NUMSEQ,D3_SEQCALC+D3_NUMSEQ)
			cAlias   := Alias()
			aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),lInverteMov,If(D3_CF == "RE5","02","")})
			dbSkip()
		EndDo
		
		dbSelectArea(cAliasSD2)
		Do While !Eof() .AND. (cAliasSD2)->D2_FILIAL == xFilial("SD2") .AND. (cAliasSD2)->D2_EMISSAO == IIf(lQuerySD2, DToS(dCntData),dCntData) .AND. (cAliasSD2)->D2_COD == SB1->B1_COD .AND. If(lCusUnif,.T.,(cAliasSD2)->D2_LOCAL == mv_par03)
			If (cAliasSD2)->D2_ORIGLAN $ "LF" 
				dbSkip()
				Loop
			EndIf
			If nModulo = 12
				SF2->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2") + (cAliasSD2)->D2_DOC  + (cAliasSD2)->D2_SERIE + (cAliasSD2)->D2_CLIENTE + (cAliasSD2)->D2_LOJA ))
					If !Empty(SF2->F2_NFCUPOM) .AND. Alltrim(Upper(SF2->F2_ESPECIE)) == Alltrim(Upper(MVNOTAFIS))
						(cAliasSD2)->(dbSkip())
						Loop
					EndIf
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Despreza Notas Fiscais com Remitos                           ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc<> "BRA" .AND. !Empty((cAliasSD2)->D2_REMITO)
				If !((cAliasSD2)->D2_TPDCENV $ '1A')
					(cAliasSD2)->(dbSkip())
					Loop
				EndIf
			EndIf
	        
	        SF4->(dbSeek(cFilial+(cAliasSD2)->D2_TES))
			If SF4->F4_ESTOQUE # "S"
				dbSkip()
				Loop
			EndIf
			cSeqIni  := If(mv_par07==1,(cAliasSD2)->D2_NUMSEQ,(cAliasSD2)->D2_SEQCALC+(cAliasSD2)->D2_NUMSEQ)
			cAlias	 := "SD2"
			#IFNDEF TOP
				aAdd(aDados,{cAlias,dCntData,cSeqIni,Recno(),.F.,""})
			#ELSE
				aAdd(aDados,{cAlias,dCntData,cSeqIni,(cAliasSD2)->RECSD2,.F.,""})
			#ENDIF
			dbSkip()
		EndDo
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//?Caso seja fim de arquivo no SD1, SD2 e SD3 nao continua o    ?
		//?processamento.                                               ?
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SD1->(Eof()) .AND. (cAliasSD2)->(Eof()) .AND. SD3->(Eof())
			Exit
		Endif  
	
		If Empty(cAlias)
			dCntData++
		EndIf	
		cCondicao:=dCntData>mv_par02
		If mv_par07==2 .AND. !lCusUnif
			cCondicao:=cCondicao .OR. (	SD1->D1_COD + SD1->D1_LOCAL <> SB1->B1_COD + mv_par03 .AND. ;
										(cAliasSD2)->D2_COD + (cAliasSD2)->D2_LOCAL <> SB1->B1_COD + mv_par03 .AND. ;
										SD3->D3_COD <> SB1->B1_COD )
		Endif
		If cCondicao
			Exit
		EndIf
	
	EndDo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Ordena os registros a serem processados conforme a configuracao |
	//?do parametro mv_par07 (Digitacao ou Calculo).					|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	If Len(aDados) > 1
		//-- Passado o elemento 6 no array devido a problemas com o aSort
		ASORT(aDados,,, { |x, y| DTOS(x[2])+x[3]+x[6] < DTOS(y[2])+y[3]+y[6] })
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	//?Processa os registros do Array aDados							|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
	For i := 1 to Len(aDados)
		If aDados[i,1] == "SD1"
			dbSelectArea("SD1")
			MsGoto(aDados[i,4])
			If cPaisLoc == "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se o TES atualiza estoque             ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF4")
				dbSeek(cFilial+SD1->D1_TES)
				dbSelectArea("SD1")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Executa ponto de entrada para verificar se considera TES que ?
				//?NAO ATUALIZA saldos em estoque.                              ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
					lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
					lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
				EndIf
				If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
					Loop
				EndIf
				If D1_TES <= "500"
					aSalAtu[1] += D1_QUANT
					aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] += D1_QTSEGUM
					nTotEnt    += D1_QUANT
					nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				Else
					aSalAtu[1] -= D1_QUANT
					aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] -= D1_QTSEGUM
					nTotSda    += D1_QUANT
					nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Calcula o Custo Medio do Produto               ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCusmed := MYCalcCMed(aSalAtu)
				cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
	 			MYAddArray({	SD1->D1_DTDIGIT,;
	 							SUBS(SD1->D1_TES,1,3),;
	 							SD1->D1_CF,;
	 							SD1->D1_DOC,;
	 							" ",;
	 							" ",;
	 							cIdent,;
	 							TRANSF(SD1->D1_QUANT,cPictQT),;
	 							TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),;
	 							TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO")),;
	 							SD1->D1_LOTECTL,;
	 							SD1->D1_NUMLOTE,;
	 							SD1->D1_NUMSEQ,;
	 							SD1->D1_IDENTB6,;
	 							"",;
	 							SD1->D1_CC,;
	 							SD1->D1_ITEMCTA},aDados[i,1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Localizacao                  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If mv_par06 == 1
					dbSelectArea("SDB")
					dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
					While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == mv_par03) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
						If SDB->DB_ESTORNO == "S"
							dbSkip()
							Loop
						EndIf   
						MYAddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE,"" },aDados[i,1])
						SDB->(DbSkip())
					EndDo
				EndIf*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Saldo item a item            ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If mv_par04 == 1
					MYAddArray({	STR0004,;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									Transf(aSalAtu[1],cPictQT),;
									Transf(nCusMed,PesqPict("SB2","B2_CM1")),;
									Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1")),;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""},aDados[i,1])
				EndIf
				aAdd(aGraph,{MY030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se o TES atualiza estoque             ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF4")
				dbSeek(cFilial+SD1->D1_TES)
				dbSelectArea("SD1")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Executa ponto de entrada para verificar se considera TES que ?
				//?NAO ATUALIZA saldos em estoque.                              ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
					lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
					lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
				EndIf
				If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
					Loop
				EndIf
				
				SF1->(DbSetOrder(1))
				SF1->(DbSeek(xFilial("SF1")+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA))
				If cPaisLoc != "BRA" .AND. AllTrim(D1_ESPECIE) == "RCN" .AND. !Empty(SF1->F1_HAWB) 
					Loop
				EndIf
				
				If D1_TES <= "500"
					aSalAtu[1] += D1_QUANT
					aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] += D1_QTSEGUM
					nTotEnt    += D1_QUANT
					nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				Else
					aSalAtu[1] -= D1_QUANT
					aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
					aSalAtu[7] -= D1_QTSEGUM
					nTotSda    += D1_QUANT
					nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				EndIf

				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Calcula o Custo Medio do Produto               ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCusmed := MYCalcCMed(aSalAtu)
				
				cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
				
				cDocumento:=SD1->D1_DOC            				
				MYAddArray({	SD1->D1_DTDIGIT,;
								SD1->D1_TES,;
								If(IsRemito(1,'SD1->D1_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),;
								cDocumento,;
								"",;
								"",;
								cIdent,;
								TRANSF(SD1->D1_QUANT,cPictQT),;
								TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),;
								TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO")),;
								SD1->D1_LOTECTL,;
								SD1->D1_NUMLOTE,;
								SD1->D1_NUMSEQ,;
								SD1->D1_IDENTB6,;
								"",;
								SD1->D1_CC,;
								SD1->D1_ITEMCTA},aDados[i,1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Localizacao                  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If mv_par06 == 1
					dbSelectArea("SDB")
					dbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
					While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == mv_par03) .AND. DB_NUMSEQ == SD1->D1_NUMSEQ
						If SDB->DB_ESTORNO == "S"
							dbSkip()
							Loop
						EndIf   				
						MYAddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE,""},aDados[i,1])
						SDB->(dbSkip())
					EndDo
				EndIf*/
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Saldo item a item            ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If mv_par04 == 1
					MYAddArray({	STR0004,;
									" ",;
									" ",;
									" ",;
									" ",;
									" ",;
									" ",;
									Transf(aSalAtu[1],cPictQT),;
									Transf(nCusMed,PesqPict("SB2","B2_CM1")),;
									Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1")),;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""},aDados[i,1])
				EndIf
				aAdd(aGraph,{MY030Data("SD1"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
			EndIf
		EndIf
		If aDados[i,1] == "SD3"
			dbSelectArea("SD3")
			MsGoto(aDados[i,4])
			If aDados[i,5]  //lInverteMov
				If D3_TM > "500"
					aSalAtu[1] += D3_QUANT
					aSalAtu[mv_par05+1] += &("D3_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] += D3_QTSEGUM
					nTotEnt    += D3_QUANT
					nTotvEnt   += &("D3_CUSTO"+Str(mv_par05,1,0))
				Else
					aSalAtu[1] -= D3_QUANT
					aSalAtu[mv_par05+1] -= &("D3_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] -= D3_QTSEGUM
					nTotSda    += D3_QUANT
					nTotvSda   += &("D3_CUSTO"+Str(mv_par05,1,0))
				EndIf
			Else	
				If D3_TM <= "500"
					aSalAtu[1] += D3_QUANT
					aSalAtu[mv_par05+1] += &("D3_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] += D3_QTSEGUM
					nTotEnt    += D3_QUANT
					nTotvEnt   += &("D3_CUSTO"+Str(mv_par05,1,0))
				Else
					aSalAtu[1] -= D3_QUANT
					aSalAtu[mv_par05+1] -= &("D3_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] -= D3_QTSEGUM
					nTotSda    += D3_QUANT
					nTotvSda   += &("D3_CUSTO"+Str(mv_par05,1,0))
				EndIf
			EndIf
			cIdent := If(Empty(D3_OP),D3_CC, D3_OP)
			If lMc030Idmv
				cIdent := ExecBlock("MC030IDMV",.F.,.F.,{D3_OP,D3_CC})
			EndIf	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Calcula o Custo Medio do Produto               ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := MYCalcCMed(aSalAtu)
			MYAddArray({	SD3->D3_EMISSAO,;
							SUBS(SD3->D3_TM,1,3),;
							SD3->D3_CF+If(aDados[i,5],"*",""),;
							SD3->D3_DOC,;
							SD3->D3_LOCALIZ,;
							SD3->D3_NUMSERI,;
							cIdent,;
							TRANSF(SD3->D3_QUANT,cPictQT),;
							TRANSF((&("SD3->D3_CUSTO"+Str(mv_par05,1,0))/SD3->D3_QUANT),PesqPict("SB2","B2_CM1")),;
							TRANSF(&("SD3->D3_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),;
							SD3->D3_LOTECTL,;
							SD3->D3_NUMLOTE,;
							SD3->D3_NUMSEQ,;
							"",;
							SD3->D3_OBS,;
							SD3->D3_CC,;
							SD3->D3_ITEMCTA},aDados[i,1])
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Verifica se Lista Localizacao                  ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   	/*If mv_par06 == 1
				dbSelectArea("SDB")
				dbSeek(cFilial+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ)
				While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == mv_par03)	.AND. DB_NUMSEQ == SD3->D3_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						dbSkip()
						Loop
					EndIf
					MYAddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE ,""},aDados[i,1])
					SDB->(dbSkip())
				EndDo
			EndIf*/
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//?Verifica se Lista Saldo item a item            ?
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
			If mv_par04 == 1
				MYAddArray({	STR0004,;
								"",;
								"",;
								"",;
								"",;
								"",;
								"",;
								Transf(aSalAtu[1],cPictQT),;
								Transf(nCusMed,PesqPict("SB2","B2_CM1")),;
								Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1")),;
								"",;
								"",;
								"",;
								"",;
								"",;
								"",;
								""},aDados[i,1])
			EndIf
		    aAdd(aGraph,{MY030Data("SD3"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
		EndIf
		If aDados[i,1] == "SD2"
			dbSelectArea("SD2")
			MsGoto(aDados[i,4])
			If cPaisLoc == "BRA"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se o TES atualiza estoque             ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF4")
				dbSeek(cFilial+SD2->D2_TES)
				dbSelectArea("SD2")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Executa ponto de entrada para verificar se considera TES que ?
				//?NAO ATUALIZA saldos em estoque.                              ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
					lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
					lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
				EndIf
				If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
					Loop
				EndIf
				
				If D2_TES <= "500"
					aSalAtu[1] += D2_QUANT
					aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] += D2_QTSEGUM
					nTotEnt    += D2_QUANT
					nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
				Else
					aSalAtu[1] -= D2_QUANT
					aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] -= D2_QTSEGUM
					nTotSda    += D2_QUANT
					nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
				EndIf
				
				cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Calcula o Custo Medio do Produto               ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCusmed := MYCalcCMed(aSalAtu)
	
	 			MYAddArray({	SD2->D2_EMISSAO,;
	 							SUBS(SD2->D2_TES,1,3),;
	 							SD2->D2_CF,;
	 							SD2->D2_DOC,;
	 							" ",;
	 							" ",;
	 							cIdent,;
	 							TRANSF(SD2->D2_QUANT,cPictQT),;
	 							TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),;
	 							TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),;
	 							SD2->D2_LOTECTL,;
	 							SD2->D2_NUMLOTE,;
	 							SD2->D2_NUMSEQ,;
	 							SD2->D2_IDENTB6,;
	 							"",;
	 							"",;
	 							""},aDados[i,1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Localizacao                  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If mv_par06 == 1
					dbSelectArea("SDB")
					dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
					While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == mv_par03)	.AND. DB_NUMSEQ == SD2->D2_NUMSEQ
						If SDB->DB_ESTORNO == "S"
							dbSkip()
							Loop
						EndIf   				
						MYAddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE,"" },aDados[i,1])
						SDB->(dbSkip())
					EndDo
				EndIf*/
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Saldo item a item            ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If mv_par04 == 1
					MYAddArray({	STR0004,;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									Transf(aSalAtu[1],cPictQT),;
									Transf(nCusMed,PesqPict("SB2","B2_CM1")),;
									Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1")),;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""},aDados[i,1])
				EndIf
				aAdd(aGraph,{MY030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se o TES atualiza estoque             ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SF4")
				dbSeek(cFilial+SD2->D2_TES)
				dbSelectArea("SD2")
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Executa ponto de entrada para verificar se considera TES que ?
				//?NAO ATUALIZA saldos em estoque.                              ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lIxbConTes .AND. SF4->F4_ESTOQUE <> "S"
					lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
					lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
				EndIf
				If (SF4->F4_ESTOQUE <> "S" .AND. !lTesNEst)
					Loop
				EndIf
				
				If D2_TES <= "500"
					aSalAtu[1] += D2_QUANT
					aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] += D2_QTSEGUM
					nTotEnt    += D2_QUANT
					nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
				Else
					aSalAtu[1] -= D2_QUANT
					aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
					aSalAtu[7] -= D2_QTSEGUM
					nTotSda    += D2_QUANT
					nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
				EndIf
				
				cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Calcula o Custo Medio do Produto               ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nCusmed := MYCalcCMed(aSalAtu)
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				//?Verifica o pais para verificar o tamanho do documento ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
				cDocumento := SD2->D2_DOC				
				MYAddArray({	SD2->D2_EMISSAO,;
								SD2->D2_TES,;
								If(IsRemito(1,'SD2->D2_TIPODOC'),Substr(GetDescRem(),1,3)," FAC "),;
								cDocumento,;
								"",;
								"",;
								cIdent,;
								TRANSF(SD2->D2_QUANT,cPictQT),;
								TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),;
								TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")),;
								SD2->D2_LOTECTL,;
								SD2->D2_NUMLOTE,;
								SD2->D2_NUMSEQ,;
								SD2->D2_IDENTB6,;
								"",;
								"",;
								""},aDados[i,1])
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Localizacao                  ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				/*If mv_par06 == 1
					dbSelectArea("SDB")
					dbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
					While !Eof() .AND. DB_FILIAL == cFilial .AND. DB_PRODUTO == SB1->B1_COD .AND. If(lCusUnif,.T.,DB_LOCAL == mv_par03)	.AND. DB_NUMSEQ == SD2->D2_NUMSEQ
						If SDB->DB_ESTORNO == "S"
							dbSkip()
							Loop
						EndIf   				
						MYAddArray({" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," ",SDB->DB_LOTECTL,SDB->DB_NUMLOTE ,""},aDados[i,1])
						SDB->(dbSkip())
					EndDo
				EndIf*/
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//?Verifica se Lista Saldo item a item            ?
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
				If mv_par04 == 1
					MYAddArray({	STR0004,;
									" ",;
									" ",;
									" ",;
									" ",;
									" ",;
									" ",;
									Transf(aSalAtu[1],cPictQT),;
									Transf(nCusMed,PesqPict("SB2","B2_CM1")),;
									Transf(aSalAtu[mv_par05+1],PesqPict("SB9","B9_VINI1")),;
									"",;
									"",;
									"",;
									"",;
									"",;
									"",;
									""},aDados[i,1])
				EndIf
				aAdd(aGraph,{MY030Data("SD2"),aSalAtu[1],nCusMed,aSalAtu[mv_par05+1]} )
			EndIf
		EndIf
	Next i
	
	If Len(aTrbTmp)>0
		AADD(aTrbP,aTrbTmp)
		aTrbTmp:={}
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//?Limpando os filtros da IndRegua()              ?
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SD1")
	dbClearFilter()
	#IFDEF TOP
		(cAliasSD2)->( DbCloseArea() )
	#ELSE
		dbSelectArea("SD2")
		dbClearFilter()
	#ENDIF
	dbSelectArea("SD3")
	dbClearFilter()
	
Return aSaldoIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡…o    ?MYCalcCMed ?Autor ?Paulo Boschetti       ?Data ?22.03.93 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?Calcula o Custo Medio do Produto                           ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?ExpN1 := MYCalcCMed(ExpA1)   		                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpA1 = Array do saldo atual                               ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpN1 = custo medio calculado                              ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?Generico                                                   ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function MYCalcCMed(aSalAtu)
	
	Local nCusmed := 0
	
	If QtdComp(aSalAtu[1]) == QtdComp(0)
		nCusMed := 0
	Else
		nCusMed := aSalAtu[mv_par05+1]/aSalAtu[1]
	EndIf
	
Return nCusmed




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±?un‡…o    ?YAddArray   ?Autor ?rmando Pereira Waiteman?Data ?et/2001 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±?escri‡…o ?diciona array mantendo tamanho maximo de elementos por      ³±?
±±?         ?imensao                                                     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?intaxe   ?MYAddArray(ExpA1)			  		                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?arametros?ExpA1 = Array dos dados dos itens da consulta			   ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?etorno   ?Nenhum                                                      ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±?Uso      ?MATC030                                                     ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MYAddArray(aItem,cAlias)

	Local aRetPE  := {}
	Local aItemPE := aClone(aItem)   
	
	DEFAULT cAlias := ""
	
	If ExistBlock('MC030ARR')                          
		aRetPE := ExecBlock('MC030ARR', .F., .F.,{aItemPE,cAlias})
		If ValType(aRetPE) == 'A'
			aItem := aRetPE
		EndIf
	EndIf
	
	aAdd(aTrbTmp, aItem)
	
	If Len(aTrbTmp) >= 65000
		AADD(aTrbp,aTrbtmp)
		aTrbTmp:= {}
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±?
±±?un‡…o    ?Y030Data  ?Autor ?arcelo Iuspa          ?Data ?et/2001 ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±?
±±?escri‡…o ?btem a data a partir do dos arrays aTrbTmp e aTrbP         ³±?
±±?         ?                                                           ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?intaxe   ?ExpD1 := MY030Data(ExpC1)	 	                          ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?arametros?ExpC1 = Alias do arq. de movimento						  ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?etorno   ?ExpD1 = Data do arq.mov. ou dos arrays aTrbTmp e aTrbP     ³±?
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±?
±±?Uso      ?MATC030                                                    ³±?
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±?
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±?
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß?
*/
Static Function MY030Data(cAlias)

	Local dData
	Default cAlias := Nil
	If mv_par04==1 .AND. Len(aTrbTmp) == 0
		dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-1] [1]
	ElseIf mv_par04==1 .AND. Len(aTrbTmp) == 1
		dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
	ElseIf mv_par04==2 .AND. Len(aTrbTmp) == 0
		dData := aTrbP  [Len(aTrbp)]  [Len(aTrbp[Len(aTrbP)])-0] [1]
	ElseIf mv_par04==2 .AND. Len(aTrbTmp) == 1
		dData:=aTrbTmp[Len(aTrbTmp)] [1]
	Else 
		dData:=aTrbTmp[Len(aTrbTmp)-If(mv_par04==1,1,0)][1]
	Endif
	/*If mv_par06 == 1
	    If cAlias == "SD1"
	       dData := SD1->D1_DTDIGIT
	    ElseIf cAlias == "SD2"
	       dData := SD2->D2_EMISSAO   
	    ElseIf cAlias == "SD3"
	       dData := SD3->D3_EMISSAO   
	    Endif	
	EndIf*/
	
Return(dData)
