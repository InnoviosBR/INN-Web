#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"

User Function INNMenu(aParm)

	Local aMenu		:= ParamIXB[1]
	//Local cUserID	:= ParamIXB[2]

	aadd(aMenu,{'wIndex','Estoque','#','menu-icon fa fa-cubes',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wProd','u_wIndex.apw?x=wProd','Produto',.F.})
	aadd(aMenu[i][6],{'wSaldo','u_wIndex.apw?x=wSaldo','Saldos',.F.})
	aadd(aMenu[i][6],{'wSA','u_wIndex.apw?x=wSA','Solicita Armazém',.F.})
	aadd(aMenu[i][6],{'wCliente','u_wIndex.apw?x=wCliente','Clientes',.F.})
	aadd(aMenu[i][6],{'wFornece','u_wIndex.apw?x=wFornece','Fornecedores',.F.})
	aadd(aMenu[i][6],{'wNFEntrada','u_wIndex.apw?x=wNFEntrada','NF Entrada',.F.})
	aadd(aMenu[i][6],{'wNFSaida','u_wIndex.apw?x=wNFSaida','NF Saida',.F.})


	aadd(aMenu,{'wIndex','Produção','#','menu-icon fa fa-industry',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wOP','u_wIndex.apw?x=wOP','Ordens Produção',.F.})


	aadd(aMenu,{'wIndex','Compras','#','menu-icon fa fa-calculator',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wPC','u_wIndex.apw?x=wPC','Pedido de Compra',.F.})
	aadd(aMenu[i][6],{'wSC','u_wIndex.apw?x=wSC','Solicita Compra',.F.})


	aadd(aMenu,{'wIndex','Faturamento','#','menu-icon fa fa-shopping-cart',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wCliente','u_wIndex.apw?x=wCliente','Clientes',.F.})
	aadd(aMenu[i][6],{'wPV','u_wIndex.apw?x=wPV','Pedido de Venda',.F.})			
	
		
	aadd(aMenu,{'wFinanceiro','Financeiro','u_wIndex.apw?x=wIndex','menu-icon fas fa-money-bill-alt',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wTitPag','u_wIndex.apw?x=wTitPag','Contas a Pagar',.F.})


	aadd(aMenu,{'wTI','Tec. Inform.','u_wIndex.apw?x=windex','menu-icon fa fa-wrench',.F.,{}})
	i := Len(aMenu)
	aadd(aMenu[i][6],{'wExplorer','u_wIndex.apw?x=wExplorer','Explorer',.F.})

Return(aMenu)
