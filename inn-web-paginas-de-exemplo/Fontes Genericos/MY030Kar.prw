//#INCLUDE "MATC030.CH"
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
User Function MY030Kar(cCodigo,cAlmox,dIniK,dFimK,nTipo,lSaldIni)

	Local aRet := {}
	Local nY

	//ExecBlock("CHKEXEC",.f.,.f.,"U_MY030Kar1")

	Default lSaldIni := .T.
		
	Private aSalTel := {} ,nCusMed := 0 ,aSalIni := {}
	Private aArea:=GetArea()
	Private aGraph  := {}
	Private aTrbP   := {}
	Private aTrbTmp := {}
	Private aTela   := {}
	Private aSalAtu := { 0,0,0,0,0,0,0 }
	Private cPictTotQT:=PesqPictQt("B2_QATU")
	Private nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0
	Private cTRBSD1 := CriaTrab(,.F.)
	Private cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
	Private cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
	Private cPictQT := PesqPict("SB2","B2_QATU",18) 
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1) )
	if !( SB1->(dbSeek(xFilial("SB1")+cCodigo)) )
		Return( {{ctod(""),"Produto invalido ("+cCodigo+")","","","","",0,0,0,0,0}} )
	endif
	
	dbSelectArea("SB2")
	SB2->(dbSetOrder(1) )
	if !( SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD+cAlmox)) )
		Return( {{ctod(""),"Armazem invalido ("+cAlmox+")","","","","",0,0,0,0,0}} )
	endif
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas para parametros                         ³
	//³ mv_par01        // Data inicial                              ³
	//³ mv_par02        // Data final                                ³
	//³ mv_par03        // Qual Almoxarifado                         ³
	//³ mv_par04        // Saldo item a item : Sim / Nao             ³
	//³ mv_par05        // Qual Moeda ? 1 2 3 4 5                    |
	//³ mv_par06        // Imprime Localizacao: Sim / Nao            ³
	//³ mv_par07        // Sequencia Impressao : Digitacao / Calculo ³
	//³ mv_par08         // Lista Transf Locali (Sim/Nao)            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Pergunte("MTC030",.F.)  		
	mv_par01 := dIniK
	mv_par02 := dFimK
	mv_par03 := SB2->B2_LOCAL
	mv_par04 := 1
	mv_par05 := 1
	mv_par06 := 2
	mv_par07 := nTipo
	mv_par08 := 1	
	
	//Processa({|| aSalTel := STATICCALL(MATC030, MC030Monta ) },, "MY030Kar")
	Eval({|| &(" aSalTel := STATICCALL(MATC030, MC030Monta )  ") })

	if lSaldIni
	
		aadd(aRet,{DaySub(dIniK,1),;//"Data"
					"",;//"Documento"
					"",;//"Operação"
					"Saldo Inicial",;//Descrição
					"",;//CF
					"",;//"TES"
					0,;//"Quantidade"
					0,;//"Saldo"
					0,;//"Custo Unit"
					0,;//"Custo Total"
					0})//Custo acumulado
					
		aRet[1,08] := Round(aSalTel[1],3)//"Saldo"	
		aRet[1,09] := Round(aSalTel[2]/aSalTel[1],6)//"Custo Unit"
		aRet[1,10] := Round(aSalTel[2],2)//"Custo Total"
		aRet[1,11] := Round(aSalTel[2],2)//Custo acumulado
		
	endif
					
	if len(aTrbP) > 0 .and. len(aTrbP[1]) > 0
		nY := 1
		While  nY <= (Len(aTrbP[1])-1)

			cOPe := ""
			cCF := ""
			cDesc := ""
			cOPe += iif(left(aTrbP[1][nY][3],2)=="RE","SAIDA MANUAL","")
			cOPe += iif(left(aTrbP[1][nY][3],2)=="DE","ENTRADA MANUAL","")
			cOPe += iif(left(aTrbP[1][nY][3],2)=="PR","PRODUCAO","")
			cOPe += iif(left(aTrbP[1][nY][3],2)=="ER","ESTORNO","")
			IF left(aTrbP[1][nY][3],2) $ "DE/RE"
				cCF  += aTrbP[1][nY][3]
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="0","Operação Manual (custo médio no estoque)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="1","Operação Automática (custo médio no estoque)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="2","Operação Automática (apropriação interna)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="3","Operação Manual (Apropriação Interna)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="4","Transferência (custo médio no estoque por local físico)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="5","Requisição para OP na NF (usa o custo do documento fiscal)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="6","Requisição Valorizada","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="7","Transferência Múltipla (desmontagem de produtos)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="8","Integração com modulo Importação","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="9","Movimentos para OP sem agreg. Custo","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="A","Movimentos de Reavaliação de Custo","") 
			ENDIF
			IF left(aTrbP[1][nY][3],2) $ "PR/ER"
				cCF   += aTrbP[1][nY][3]
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="0","Operação Manual (custo médio no estoque)","")
				cDesc += IIF(right(aTrbP[1][nY][3],1)=="1","Operação Automática (custo médio no estoque)","")
			ENDIF
			if empty(cOPe)
				cOPe += iif(aTrbP[1][nY][2] >= "500","SAIDA NF","")
				cOPe += iif(aTrbP[1][nY][2] <  "500","ENTRADA NF","")
				cCF  += aTrbP[1][nY][3]
				cDesc += POSICIONE("SX5",1,xFilial("SX5")+"13"+aTrbP[1][nY][3],"X5_DESCRI")					
			endif
			
			aadd(aRet,{aTrbP[1][nY][1],;//"Data"
						aTrbP[1][nY][4],;//"Documento"
						UPPER(cOPe),;//"Operação"
						UPPER(cDesc),;//"Descricao"
						aTrbP[1][nY][3],;//CF
						aTrbP[1][nY][2],;//"TES"
						Round(val(replace(replace(aTrbP[1][nY][8],".",""),",",".")),3),;//"Quantidade"
						Round(val(replace(replace(aTrbP[1][nY+1][8],".",""),",",".")),3),;//"Saldo"
						Round(val(replace(replace(aTrbP[1][nY][9],".",""),",",".")),6),;//"Custo Unit"
						Round(val(replace(replace(aTrbP[1][nY][10],".",""),",",".")),2),;//"Custo Total"
						Round(val(replace(replace(aTrbP[1][nY+1][10],".",""),",",".")),2)})//Custo acumulado
							
			nY := nY + 2
		Enddo 
	endif
	
	FERASE(cTrbSD1+GetDBExtension())
	FERASE(cTrbSD1+OrdbagExt())
	FERASE(cTrbSD2+GetDBExtension())
	FERASE(cTrbSD2+OrdbagExt())
	FERASE(cTrbSD3+GetDBExtension())
	FERASE(cTrbSD3+OrdbagExt())
		
Return(aRet)
