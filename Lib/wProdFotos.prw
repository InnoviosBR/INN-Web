#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#Include "INNLIB.ch"

User Function wProdFotos()

	Local aDirTemp := aClone(oINNWeb:aDirTemp)

	oINNWeb:lImgPop := .T.

	oINNWeb:AddHeadBtn({"wProd","","Produtos"})
	oINNWeb:AddHeadBtn({"wProdFotos","","Fotos"})
	
	oINNWeb:aDirTemp[4] += "produtos\"
	oINNWeb:aDirTemp[5] += "produtos\"
	oINNWeb:aDirTemp[6] += "produtos/"
	//fLimpa() 
    
	cProduto := iif(Valtype(HttpGet->produto) == "C" .and. !empty(HttpGet->produto),HttpGet->produto,"")
	cIdFoto := iif(Valtype(HttpGet->IdFoto) == "C" .and. !empty(HttpGet->IdFoto),HttpGet->IdFoto,"")
	cUpLoad := iif(Valtype(HttpGet->formUpload) == "C" .and. !empty(HttpGet->formUpload),HttpGet->formUpload,"")
	cUpVinc := iif(Valtype(HttpGet->insertProd) == "C" .and. !empty(HttpGet->insertProd),HttpGet->insertProd,"")
	cImposteVinc := iif(Valtype(HttpGet->imposteVinc) == "C" .and. !empty(HttpGet->imposteVinc),HttpGet->imposteVinc,"")    	
	cSentido := iif(Valtype(HttpGet->Sentido) == "C" .and. !empty(HttpGet->Sentido),HttpGet->Sentido,"")
	cDelFot := iif(Valtype(HttpGet->DelFot) == "C" .and. !empty(HttpGet->DelFot),HttpGet->DelFot,"")
	cDelVic := iif(Valtype(HttpGet->DelVic) == "C" .and. !empty(HttpGet->DelVic),HttpGet->DelVic,"")
	cAltIdFoto := iif(Valtype(HttpGet->AltIdFoto) == "C" .and. !empty(HttpGet->AltIdFoto),HttpGet->AltIdFoto,"")
	cLimpa := iif(Valtype(HttpGet->limpa) == "C" .and. !empty(HttpGet->limpa),HttpGet->limpa,"")
	
	Do Case 

    	Case !Empty(cLimpa)
    		fLimpa()
    		fGaleria()
    		
    	Case !Empty(cAltIdFoto)
    		fAltIdFoto(cAltIdFoto)
    		
    	Case !Empty(cDelFot)
    		fDelFot(cDelFot)
    		
    	Case !Empty(cDelVic)
    		fDelVic(cIdFoto,cProduto,cDelVic)
    			    		    	
		Case cUpLoad == "T"
    		fInsertUplod()

    	Case !Empty(cProduto)
    		fOrdena(cProduto,cIdFoto,cSentido) 
    		fProduto(cProduto)
			    		
    	Case !Empty(cIdFoto)
    		fFoto(cIdFoto,cUpVinc,cImposteVinc)
			    		
		OtherWise
    		fGaleria()
    		
    EndCase
					
	oINNWeb:SetTitle("Galeria de Fotos dos Produtos") 
	oINNWeb:SetIdPgn("wProd")

	oINNWeb:aDirTemp := aClone(aDirTemp)
	
Return(.T.)  

Static Function fLimpa() 
   
	//Local aFotos := {}
	Local aDir	 := {}
	Local nY
	
	//aCols := {}
				
	aDir := Directory(oINNWeb:aDirTemp[4]+"*.*")
	
	for nY := 1 To Len(aDir)
		
		//aadd(aCols,{aDir[nY,1],cValToChar(round(aDir[nY,2]/1024,2))+" KB",aDir[nY,3],aDir[nY,4],aDir[nY,5]})
		
		cIdFoto := aDir[nY,1]
		cIdFoto := SubStr(cIdFoto,RAT("\",cIdFoto)+1,Len(cIdFoto))
		cIdFoto := SubStr(cIdFoto,1,RAT(".",cIdFoto)-1)

	    dbSelectArea("INN001")
		INN001->(dbSetOrder(1))
		if INN001->(dbSeek(xFilial("SB1")+cIdFoto))

			RecLock("INN001",.F.) 
				Replace BMPSIZE  with aDir[nY,2]
			MsUnLock("INN001") 	  
							
		else
			
			FRENAME ( oINNWeb:aDirTemp[4] + aDir[nY,1] ,oINNWeb:aDirTemp[4] + "\lixo\" + aDir[nY,1] )
			
		endif	
		
	next
	
/*	aHead := {}
	aadd(aHead,{"Nome"		,"C",""})
	aadd(aHead,{"Tamanho"	,"C",""})
	aadd(aHead,{"Data"		,"D",""})
	aadd(aHead,{"Hora"		,"C",""})
	aadd(aHead,{"Atributos"	,"C",""}) 
		
	oINNWeb:SetTable(,aHead,aCols,.T.,.F.)*/
  
    dbSelectArea("INN001")
	INN001->(dbSetOrder(1))
	INN001->(dbGoTOp())  	
	
	while !( INN001->(EOF()) )
		
		RecLock("INN001",.F.) 
			Replace BMPMD5   with MD5File(oINNWeb:aDirTemp[5] + alltrim(INN001->BMPID) +"."+ INN001->BMPEXT,2,1) 
			Replace BMPDIR   with oINNWeb:aDirTemp[5] + alltrim(INN001->BMPID) +"."+ INN001->BMPEXT
		MsUnLock("INN001") 
        
	  INN001->(dbSkip()) 

	enddo 
	
    dbSelectArea("INN001")
	INN001->(dbSetOrder(1))
	INN001->(dbGoTOp())  	
		
Return

Static Function fOrdena(cProduto,cIdFoto,cSentido)
   
	Local aFotos := {}
	
	Local nY
  
    dbSelectArea("INN002")
	INN002->(dbSetOrder(2))
	INN002->(dbSeek(xFilial("SB1")+cProduto))  	
	
	while !( INN002->(EOF()) ) .and. alltrim(INN002->B1_COD) == alltrim(cProduto)
	
      aadd(aFotos,{ INN002->BMPID,INN002->SEQUENC}) 
        
	  INN002->(dbSkip()) 

	enddo 
	
	nLinha := aScan(aFotos,{|x| x[1] == cIdFoto})
	
	
	if cSentido == "down" .and. nLinha < len(aFotos)
	
		aTemp1 := aClone(aFotos[nLinha])
		aTemp2 := aClone(aFotos[nLinha+1])
		
		aFotos[nLinha][1] := aTemp2[1]
		aFotos[nLinha][2] := aTemp2[2]
		
		aFotos[nLinha+1][1] := aTemp1[1]
		aFotos[nLinha+1][2] := aTemp1[2]
		
	endif
	
	if cSentido == "up" .and. nLinha > 1
	
		aTemp1 := aClone(aFotos[nLinha])
		aTemp2 := aClone(aFotos[nLinha-1])
		
		aFotos[nLinha][1] := aTemp2[1]
		aFotos[nLinha][2] := aTemp2[2]
		
		aFotos[nLinha-1][1] := aTemp1[1]
		aFotos[nLinha-1][2] := aTemp1[2]
		
	endif

	FOR nY := 1 To len(aFotos) 
	
	    dbSelectArea("INN002")
		INN002->(dbSetOrder(1))
		INN002->(dbSeek(xFilial("SB1")+aFotos[nY,1]+cProduto)) 
		
		RecLock("INN002",.F.) 
			Replace SEQUENC  with strzero(99-nY,2)
		MsUnLock("INN002")
    
    next

	FOR nY := 1 To len(aFotos) 
	
	    dbSelectArea("INN002")
		INN002->(dbSetOrder(1))
		INN002->(dbSeek(xFilial("SB1")+aFotos[nY,1]+cProduto)) 
		
		RecLock("INN002",.F.) 
			Replace SEQUENC  with strzero(nY,2)
		MsUnLock("INN002")
    
    next

Return

Static Function fProduto(cProduto)
    

	
	oINNWeb:ExePod(cProduto)

	oINNWebTable := INNWebTable():New( oINNWeb )
	oINNWebTable:SetSimple()
	oINNWebTable:SetTitle("Fotos do produto: "+cProduto)
	oINNWebTable:AddHead({""		,"C",""})
	oINNWebTable:AddHead({""		,"C",""})
	oINNWebTable:AddHead({"ID"		,"C","",.T.})
	oINNWebTable:AddHead({"Data"	,"D",""})
	oINNWebTable:AddHead({"Usuario"	,"C",""})     
	

	dbSelectArea("SB1")
	SB1->(dbSeek(xFilial("SB1")+cProduto))
    
	dbSelectArea("INN002")
	INN002->(dbSetOrder(2)) 
	INN002->(dbSeek(xFilial("SB1")+SB1->B1_COD))
	
    dbSelectArea("INN001")
	INN001->(dbSetOrder(1))
	
	while !( INN002->(EOF()) ) .and. INN002->B1_COD == SB1->B1_COD .AND. xFilial("SB1") == INN002->BMFILIAL
	
		INN001->(dbSeek(xFilial("SB1")+INN002->BMPID)) 
		
		/*aLoad := {} 
		
		aadd(aLoad," $('#"+alltrim(INN001->BMPID)+"').magnificPopup({ ")
		aadd(aLoad,"    type: 'image', ")
		aadd(aLoad,"    closeOnContentClick: true, ")
		aadd(aLoad,"    mainClass: 'mfp-img-mobile mfp-no-margins mfp-with-zoom', ")
		aadd(aLoad,"    image: { verticalFit: true },")
		aadd(aLoad,"    zoom: {")
		aadd(aLoad,"      enabled: true,")
		aadd(aLoad,"      duration: 300")
		aadd(aLoad,"    }")
		aadd(aLoad," });")
		 
		oINNWeb:AddLoad(aLoad) */
		
		cLinkAcao := "<a href='?x=wProdFotos&produto="+alltrim(INN002->B1_COD)+"&IdFoto="+alltrim(INN002->BMPID)+"&Sentido=up'><i class='fas fa-caret-up'></i></a> "
		cLinkAcao += "<a href='?x=wProdFotos&produto="+alltrim(INN002->B1_COD)+"&IdFoto="+alltrim(INN002->BMPID)+"&Sentido=down'><i class='fas fa-caret-down'></i></a> "
		cLinkAcao += "<a href='?x=wProdFotos&produto="+alltrim(INN002->B1_COD)+"&IdFoto="+alltrim(INN002->BMPID)+"&DelVic="+cValToChar(INN002->(Recno()))+"'><i class='fas fa-trash'></i></a>"
		
		oINNWebTable:AddCols({	cLinkAcao,;
								"<div style='max-width: 250px;'><a class='image-popup-no-margins' id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'><img src='"+Alltrim(INN001->BMPURL)+"' class='img-responsive' style='max-width: 250px;'></a></div>",;
								INN001->BMPID,;
								INN001->DTINCLU,;
								INN001->USINCLU})
					
		oINNWebTable:SetLink(  , 3 , "?x=wProdFotos&IdFoto="+INN001->BMPID )
				

		INN002->(dbSkip()) 
		
	enddo
		
	fUpload(cProduto)

Return

Static Function fFoto(cIdFoto,cUpVinc,cImposteVinc)

	Local cBody := ""  
	Local nRec		:= 0
	    	
    dbSelectArea("INN001")
	INN001->(dbSetOrder(1))
	INN001->(dbSeek(xFilial("SB1")+cIdFoto))
	
	if !Empty(cUpVinc)
	
		fInsertVinc(cIdFoto,cUpVinc)
		
	endif

	if !Empty(cImposteVinc)
		
	    dbSelectArea("INN001")
		INN001->(dbSetOrder(1))
		if INN001->(dbSeek(xFilial("SB1")+cImposteVinc))
		
			dbSelectArea("INN002")
			INN002->(dbSetOrder(1)) 
			INN002->(dbSeek(xFilial("SB1")+cImposteVinc))
			
			while !( INN002->(EOF()) ) .and. INN002->BMPID == cImposteVinc
		
				nRec := INN002->(RecNo())
				
				fInsertVinc(cIdFoto,INN002->B1_COD)						
				
				INN002->(dbGoTo(nRec))
		
				INN002->(dbSkip()) 
				
			enddo								

		endif

	endif
	
	dbSelectArea("INN001")
	INN001->(dbSetOrder(1))
	INN001->(dbSeek(xFilial("SB1")+cIdFoto))

		
	/*aLoad := {} 
	
	aadd(aLoad," $('#"+alltrim(INN001->BMPID)+"').magnificPopup({ ")
	aadd(aLoad,"    type: 'image', ")
	aadd(aLoad,"    closeOnContentClick: true, ")
	aadd(aLoad,"    mainClass: 'mfp-img-mobile mfp-no-margins mfp-with-zoom', ")
	aadd(aLoad,"    image: { verticalFit: true },")
	aadd(aLoad,"    zoom: {")
	aadd(aLoad,"      enabled: true,")
	aadd(aLoad,"      duration: 300")
	aadd(aLoad,"    }")
	aadd(aLoad," });")
	 	
	oINNWeb:AddLoad(aLoad) */

		
	/*cBody := "<div class='row'>" + CRLF
	
	cBody += "  <div class='col-lg-2'>" + CRLF
	cBody += "  <h4>ID: "+alltrim(INN001->BMPID)+"</h4>" + CRLF
	cBody += "  </div>" + CRLF
	
	
	cBody += "  <div class='col-lg-8'>" + CRLF
	cBody += "    <div style='max-width: 500px;' class='center-block'>" + CRLF
	cBody += '      <a id="'+alltrim(INN001->BMPID)+'" href="'+Alltrim(INN001->BMPURL)+'"><img src="'+Alltrim(INN001->BMPURL)+'" class="img-responsive"></a>' + CRLF
	cBody += "    </div>" + CRLF
	cBody += "  </div>" + CRLF
	
	cBody += "  <div class='col-lg-2'>	
	
	cBody += "    <div class='panel panel-default'>" + CRLF
	cBody += "      <div class='panel-body' >" + CRLF			
	cBody += "	      <p class='text-left'>Tamhano: " + Transform(INN001->BMPSIZE/1024,"@E 99,999,999,999.99") + " KB</p>" + CRLF
	cBody += "	      <p class='text-left'>Inserida em: " + dToc(INN001->DTINCLU) + "</p>" + CRLF
	cBody += "	      <p class='text-left'>Inserida por: " + Alltrim(INN001->USINCLU) + "</p>" + CRLF
	cBody += "      </div>" + CRLF
	cBody += "    </div>" + CRLF
	
	cBody += "    <div class='panel panel-default'>" + CRLF
	cBody += "      <div class='panel-body' >" + CRLF			
		
	cBody += "          <a href='"+Alltrim(INN001->BMPURL)+"' class='list-group-item'>" + CRLF
	cBody += "	          <i class='fas fa-download fa-fw'></i> Baixar" + CRLF
	cBody += "          </a>" + CRLF
	
/ *	cBody += "          <a href='u_wProdFotos.apw?AltIdFoto="+Alltrim(INN001->BMPID)+"' class='list-group-item'>" + CRLF
	cBody += "	          <i class='fas fa-pencil-square-o fa-fw'></i> Alterar</span>" + CRLF
	cBody += "          </a>" + CRLF* /
	
	cBody += "          <a href='?x=wProdFotos&DelFot="+Alltrim(INN001->BMPID)+"' class='list-group-item'>" + CRLF
	cBody += "	          <i class='fas fa-trash'></i> Excluir" + CRLF
	cBody += "          </a>" + CRLF
	
	cBody += "      </div>" + CRLF
	cBody += "    </div>" + CRLF
	cBody += "  </div>" + CRLF
	
	cBody += "</div>" + CRLF
	
	oINNWeb:AddBody(cBody)*/


	oINNWeb:cFixBar += "            <div class='page-sidebar'>" + CRLF
	oINNWeb:cFixBar += "              <!-- .sidebar-header -->" + CRLF
	oINNWeb:cFixBar += "              <header class='sidebar-header d-sm-none'>" + CRLF
	oINNWeb:cFixBar += "                <nav aria-label='breadcrumb'>" + CRLF
	oINNWeb:cFixBar += "                  <ol class='breadcrumb'>" + CRLF
	oINNWeb:cFixBar += "                    <li class='breadcrumb-item active'>" + CRLF
	oINNWeb:cFixBar += "                      <a href='#' onclick='Looper.toggleSidebar()'><i class='breadcrumb-icon fa fa-angle-left mr-2'></i>Back</a>" + CRLF
	oINNWeb:cFixBar += "                    </li>" + CRLF
	oINNWeb:cFixBar += "                  </ol>" + CRLF
	oINNWeb:cFixBar += "                </nav>" + CRLF
	oINNWeb:cFixBar += "              </header><!-- /.sidebar-header -->" + CRLF
	oINNWeb:cFixBar += "              <!-- .sidebar-section-fill -->" + CRLF
	oINNWeb:cFixBar += "              <div class='sidebar-section-fill'>" + CRLF
	oINNWeb:cFixBar += "                <!-- .card -->" + CRLF
	oINNWeb:cFixBar += "                <div class='card card-reflow'>" + CRLF
	oINNWeb:cFixBar += "                  <!-- .card-body -->" + CRLF
	oINNWeb:cFixBar += "                  <div class='card-body'>" + CRLF
	oINNWeb:cFixBar += "                    <button type='button' class='close mt-n1 d-none d-xl-none d-sm-block' onclick='Looper.toggleSidebar()' aria-label='Close'><span aria-hidden='true'>x</span></button>" + CRLF
	oINNWeb:cFixBar += "                    <h4 class='card-title'> Sumario </h4><!-- grid row -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.card-body -->" + CRLF
	oINNWeb:cFixBar += "                  <!-- .card-body -->" + CRLF


	oINNWeb:cFixBar += "                  <div class='list-group list-group-bordered list-group-reflow'>" + CRLF
	oINNWeb:cFixBar += "                    <!-- .list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                    <div class='list-group-item justify-content-between align-items-center' style='border-color: white;'>" + CRLF
	oINNWeb:cFixBar += "                      <span> Tamhano<br>"+Transform(INN001->BMPSIZE/1024,"@E 99,999,999,999.99") + " KB</span> " + CRLF
	oINNWeb:cFixBar += "                    </div><!-- /.list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.list-group -->" + CRLF

	oINNWeb:cFixBar += "                  <div class='list-group list-group-bordered list-group-reflow'>" + CRLF
	oINNWeb:cFixBar += "                    <!-- .list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                    <div class='list-group-item justify-content-between align-items-center' style='border-color: white;'>" + CRLF
	oINNWeb:cFixBar += "                      <span> Inserida por<br>"+ Alltrim(INN001->USINCLU)+"</span> " + CRLF
	oINNWeb:cFixBar += "                    </div><!-- /.list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.list-group -->" + CRLF

	oINNWeb:cFixBar += "                  <div class='list-group list-group-bordered list-group-reflow'>" + CRLF
	oINNWeb:cFixBar += "                    <!-- .list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                    <div class='list-group-item justify-content-between align-items-center' style='border-color: white;'>" + CRLF
	oINNWeb:cFixBar += "                      <span> Inserida em<br>"+ dtoc(INN001->DTINCLU)+"</span> " + CRLF
	oINNWeb:cFixBar += "                    </div><!-- /.list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.list-group -->" + CRLF

	oINNWeb:cFixBar += "                  <div class='list-group list-group-bordered list-group-reflow'>" + CRLF
	oINNWeb:cFixBar += "                    <!-- .list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                    <div class='list-group-item justify-content-between align-items-center'>" + CRLF
	oINNWeb:cFixBar += "                      <span> " + CRLF
	oINNWeb:cFixBar += "                        <a href='"+Alltrim(INN001->BMPURL)+"'>" + CRLF
	oINNWeb:cFixBar += "                          <i class='fas fa-download fa-fw'></i> Baixar" + CRLF
	oINNWeb:cFixBar += "                        </a>" + CRLF
	oINNWeb:cFixBar += "                      </span> " + CRLF
	oINNWeb:cFixBar += "                    </div><!-- /.list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.list-group -->" + CRLF

	oINNWeb:cFixBar += "                  <div class='list-group list-group-bordered list-group-reflow'>" + CRLF
	oINNWeb:cFixBar += "                    <!-- .list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                    <div class='list-group-item justify-content-between align-items-center'>" + CRLF
	oINNWeb:cFixBar += "                      <span> " + CRLF
	oINNWeb:cFixBar += "                        <a href='?x=wProdFotos&DelFot="+Alltrim(INN001->BMPID)+"'>" + CRLF
	oINNWeb:cFixBar += "                          <i class='fas fa-trash'></i> Excluir" + CRLF
	oINNWeb:cFixBar += "                        </a>" + CRLF
	oINNWeb:cFixBar += "                      </span> " + CRLF
	oINNWeb:cFixBar += "                    </div><!-- /.list-group-item -->" + CRLF
	oINNWeb:cFixBar += "                  </div><!-- /.list-group -->" + CRLF

	oINNWeb:cFixBar += "                  <!-- .card-body -->" + CRLF
	oINNWeb:cFixBar += "                </div><!-- /.card -->" + CRLF
	oINNWeb:cFixBar += "              </div><!-- /.sidebar-section-fill -->" + CRLF
	oINNWeb:cFixBar += "            </div>" + CRLF	

	cBody := ""
	//cBody += "    <div style='max-width: 500px;' class='center-block'>" + CRLF
	cBody += "<figure class='figure'><a id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'><img src='"+Alltrim(INN001->BMPURL)+"' class='img-fluid'></a></figure>" + CRLF
	//cBody += "    </div>" + CRLF
	oINNWeb:addCard(cBody)
		
	oINNWebTable := INNWebTable():New( oINNWeb )
	oINNWebTable:SetSimple()
	oINNWebTable:SetTitle("Produtos vinculados a foto: "+cIdFoto)
	oINNWebTable:AddHead({RetTitle("B1_COD")	,"C","",.T.})
	oINNWebTable:AddHead({RetTitle("B1_DESC")	,"C",""})

	dbSelectArea("INN002")
	INN002->(dbSetOrder(1)) 
	INN002->(dbSeek(xFilial("SB1")+cIdFoto))
	
	while !( INN002->(EOF()) ) .and. INN002->BMPID == cIdFoto .and. INN002->BMFILIAL == xFilial("SB1")  

		dbSelectArea("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+INN002->B1_COD))
		
		cLinkDel := "<div class='pull-right'><a href='?x=wProdFotos&IdFoto="+INN002->BMPID+"&DelVic="+cValToChar(INN002->(Recno()))+"'><i class='fas fa-trash'></i></a></div>"
		
		oINNWebTable:AddCols({SB1->B1_COD,SB1->B1_DESC + cLinkDel})
					
		oINNWebTable:SetLink(  , 1 , "?x=wProdFotos&produto="+Alltrim(SB1->B1_COD) )

		INN002->(dbSkip()) 
		
	enddo
	
	//Adiciona botão
	cBody := ""
	cBody += "<div class='row'>"
	cBody += "	<div class='col-md-4 col-md-8'>"
	cBody += "	  <button type='button' class='btn btn-primary' data-toggle='modal' data-target='#Adiciona-Produto'>Adicionar vinculo de produto</button>"
	cBody += "	  <button type='button' class='btn btn-primary' data-toggle='modal' data-target='#Importa-Vinculo'>Importar vinculo de outra imagem</button>"
	cBody += "	</div>"
	cBody += "</div>"
	oINNWeb:addCard(cBody)
	
	//modal do botao Adicionar vinculo de produto
	cBody := ""
	cBody += "<div class='modal fade' id='Adiciona-Produto' role='dialog' aria-labelledby='Adiciona-Produto'>"
	cBody += "  <form class='form-inline' method='get' enctype='application/x-www-form-urlencoded' name='parametro' id='parametro'>"
	cBody += "    <input name='x' type='hidden' id='x' value='wProdFotos'>"
	cBody += "    <input name='IdFoto' type='hidden' id='IdFoto' value='"+cIdFoto+"'>"
	cBody += "    <div class='modal-dialog modal-lg' role='document'>"
	cBody += "      <div class='modal-content'>"
	cBody += "        <div class='modal-header'>"
	cBody += "          <h5 class='modal-title'>Adicionar vinculo de produto</h5>"
	cBody += "        </div>"
	cBody += "        <div class='modal-body'>"
	cBody += "	        <div class='form-group input-group'>"
	cBody += "	          <span class='input-group-addon'>Codigo do produto</span>"
	cBody += "	          <input name='insertProd' type='text' class='form-control' id='insertProd' value='' size='15' maxlength='15' autofocus=''>"
	cBody += "	        </div>"
	cBody += "        </div>"
	cBody += "        <div class='modal-footer'>"
	cBody += "          <button type='submit' class='btn btn-primary'>Salvar</button>"
	cBody += "        </div>"
	cBody += "      </div>"
	cBody += "    </div>"
	cBody += "  </form>"
	cBody += "</div>"
	oINNWeb:AddBody(cBody)

	//Modal do botão Importar vinculo de outra imagem
	cBody := ""
	cBody += "<div class='modal fade' id='Importa-Vinculo' role='dialog' aria-labelledby='Importa-Vinculo'>"
	cBody += "  <form class='form-inline' method='get' enctype='application/x-www-form-urlencoded' name='parametro' id='parametro'>"
	cBody += "    <input name='IdFoto' type='hidden' id='IdFoto' value='"+cIdFoto+"'>"
	cBody += "    <div class='modal-dialog modal-lg' role='document'>"
	cBody += "      <div class='modal-content'>"
	cBody += "        <div class='modal-header'>"
	cBody += "          <h5 class='modal-title'>Importar vinculos de outra foto</h5>"
	cBody += "        </div>"
	cBody += "        <div class='modal-body'>"
	cBody += "	        <div class='form-group input-group'>"
	cBody += "	          <span class='input-group-addon'>Codigo da imagem</span>"
	cBody += "	          <input name='imposteVinc' type='text' class='form-control' id='imposteVinc' value='' size='6' maxlength='6' autofocus=''>"
	cBody += "	        </div>"
	cBody += "        </div>"
	cBody += "        <div class='modal-footer'>"
	cBody += "          <button type='submit' class='btn btn-primary'>Importar</button>"
	cBody += "        </div>"
	cBody += "      </div>"
	cBody += "    </div>"
	cBody += "  </form>"
	cBody += "</div>"	
	oINNWeb:AddBody(cBody)

Return

Static Function fGaleria()

	Local cBuscaProd 	:= "" 
	Local lBuscaProd    := .F.
	//Local layout		:= ""
	
	clayout := iif(Valtype(HttpGet->layout) == "C" .and. !empty(HttpGet->layout),HttpGet->layout,"")   
	cBuscaProd := iif(Valtype(HttpGet->buscaProd) == "C" .and. !empty(HttpGet->buscaProd),HttpGet->buscaProd,"")

	oINNWebParam := INNWebParam():New( oINNWeb )
	oINNWebParam:addText({'buscaProd','Cod do Produto',15,cBuscaProd,.F.})
	//oINNWebParam:addCombo({'layout','Apresentação',clayout,.F.,{{'','Tabela'},{'G','Grid'}}})
	//oINNWeb:AddParm(aParm)
	
	fUpload("")
		
	//if clayout == "G"
	/*	
		aLoad := {} 
		
		aadd(aLoad," $('#gallery').magnificPopup({ ")
		aadd(aLoad,"    type: 'image', ")
		aadd(aLoad,"    delegate: 'a', ")
		aadd(aLoad,"    closeOnContentClick: true, ")
		aadd(aLoad,"    mainClass: 'mfp-img-mobile mfp-no-margins mfp-with-zoom', ")
		aadd(aLoad,"    image: { verticalFit: true },")
		aadd(aLoad,"    gallery: { enabled:true },")
		aadd(aLoad,"    zoom: {")
		aadd(aLoad,"      enabled: true,")
		aadd(aLoad,"      duration: 300")
		aadd(aLoad,"    }")
		aadd(aLoad," });")
		 
		oINNWeb:AddLoad(aLoad)
		
		cBody += "<div class='row'>" + CRLF
		cBody += "  <div class='col-xs-12'>" + CRLF
		cBody += "    <div class='panel panel-default'>" + CRLF
		cBody += "      <div class='panel-heading'>Galeria</div>" + CRLF
		cBody += "      <div class='panel-body' id='gallery'>" + CRLF

	    dbSelectArea("INN001")
		INN001->(dbSetOrder(1))		
		INN001->(dbGoTop())
		
		while !( INN001->(EOF()) )
			
			cBody += "      <a class='image-popup-no-margins' id='"+alltrim(INN001->BMPID)+"' href='"+Alltrim(INN001->BMPURL)+"'>" + CRLF
			cBody += "      <img src='"+Alltrim(INN001->BMPURL)+"' alt='"+Alltrim(INN001->BMPID)+"' style='max-width: 250px;' class='mythumbnail'>" + CRLF
			cBody += "      </a>" + CRLF
		  	 
			INN001->(dbSkip()) 
			
		enddo
		
		cBody += "      </div>" + CRLF
		cBody += "    </div>" + CRLF
		cBody += "  </div>" + CRLF
		cBody += "</div>" + CRLF	
		
		oINNWeb:AddBody(cBody)
	*/
	
	//else
		
		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:SetTitle("Galeria Completa")
		oINNWebTable:AddHead({""									,"C",""})
		oINNWebTable:AddHead({"ID"									,"C","",.T.})
		oINNWebTable:AddHead({"Data"								,"D",""})
		oINNWebTable:AddHead({"Usuario"								,"C",""})
		oINNWebTable:AddHead({"Tamanho (KB)"						,"N","@E 99,999,999,999.99"})
		oINNWebTable:AddHead({"Produtos (Sequencia) - Descrição"	,"C",""})
			
	    dbSelectArea("INN001")
		INN001->(dbSetOrder(1))
		INN001->(dbGoTop())
		
		while !( INN001->(EOF()) )
	
			cProd := ""
			lBuscaProd := .F.
			
			dbSelectArea("INN002")
			INN002->(dbSetOrder(1)) 
			INN002->(dbSeek(xFilial("SB1")+INN001->BMPID))		
			
			while !( INN002->(EOF()) ) .and. INN002->BMPID == INN001->BMPID .AND. xFilial("SB1") == INN001->BMFILIAL
			
				if Alltrim(INN002->B1_COD) == cBuscaProd
					lBuscaProd := .T.
				endif                 
				
				cProd += "<a href='?x=wProdFotos&produto="+Alltrim(INN002->B1_COD)+"'>" 
				cProd += alltrim(INN002->B1_COD)
				cProd += "</a> " 
				cProd += "("+INN002->SEQUENC+") "			
				cProd += " - "
				cProd += alltrim(POSICIONE("SB1",1,xFilial("SB1")+INN002->B1_COD,"B1_DESC"))
				cProd += "</br>"
				
				INN002->(dbSkip()) 
				
			enddo
			
			if !empty(cBuscaProd) .and. !lBuscaProd
				INN001->(dbSkip())
				loop 
			endif
			
			
			/*aLoad := {} 
			
			aadd(aLoad," $('#"+alltrim(INN001->BMPID)+"').magnificPopup({ ")
			aadd(aLoad,"    type: 'image', ")
			aadd(aLoad,"    closeOnContentClick: true, ")
			aadd(aLoad,"    mainClass: 'mfp-img-mobile mfp-no-margins mfp-with-zoom', ")
			aadd(aLoad,"    image: { verticalFit: true },")
			aadd(aLoad,"    zoom: {")
			aadd(aLoad,"      enabled: true,")
			aadd(aLoad,"      duration: 300")
			aadd(aLoad,"    }")
			aadd(aLoad," });")
			 
			oINNWeb:AddLoad(aLoad) */
			
			oINNWebTable:AddCols({;
									"<a class='image-popup-no-margins' id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'><img src='"+Alltrim(INN001->BMPURL)+"' style='max-width: 250px'></a>",;
									INN001->BMPID/* + "<br>" + MD5File(oINNWeb:aDirTemp[5] + alltrim(INN001->BMPID) +"."+ INN001->BMPEXT,2,1)/*MD5File(alltrim(INN001->BMPDIR),2,1)*/,;
									INN001->DTINCLU,;
									INN001->USINCLU,;
									INN001->BMPSIZE/1024,;
									cProd;
								})
						
			oINNWebTable:SetLink(  , 2 , "?x=wProdFotos&IdFoto="+INN001->BMPID )
					
	
			INN001->(dbSkip()) 
			
		enddo
		
		//oINNWeb:SetTable("Todas as Fotos",aHead,aCols,.T.,.F.,.T.,aLinks)
		
	//endif
	
/*	cBody += "<div class='row'>" + CRLF
	cBody += "  <div class='col-xs-12'>" + CRLF
	cBody += "     <a href='#'>Adicionar fotos</a>" + CRLF
	cBody += "  </div>" + CRLF
	cBody += "</div>" + CRLF
	
	oINNWeb:AddBody(cBody)*/

Return

Static Function fUpload(cProduto)

	Local cForm := ""

	cForm += "<form class='' name='formUpload' id='formUpload' action='?x=wProdFotos&formUpload=T' method='post' enctype='multipart/form-data'>"
	cForm += "  <input name='produto' type='hidden' id='produto' value='"+cProduto+"'>"
	cForm += "  <div class='form-group'>
    cForm += "    <div class='form-label-group'>
	cForm += "      <input type='file' name='fileToUpload' id='fileToUpload'>"
	cForm += "    </div>"
	cForm += "  </div>"
	cForm += "  <div class='form-actions'>"
	cForm += "    <button type='submit' class='btn btn-primary'>Enviar Imagem</button>"
	cForm += "  </div>"
	cForm += "</form>"

	oINNWeb:addCard(cForm,"Upload de Fotos")

Return

Static Function fInsertUplod()

   	cProduto := iif(Valtype(httpPost->produto) == "C" .and. !empty(httpPost->produto),httpPost->produto,"")
        
	cFile := iif(Valtype(httpPost->fileToUpload) == "C" .and. !empty(httpPost->fileToUpload),httpPost->fileToUpload,"")
	
	fMove(cProduto,cFile,.F.)
	
Return

Static Function fMove(cProduto,cfileToUpload,lRemoto)

	Local lProd := .F.        
			
	cOrig := cfileToUpload
	cOrig := SubStr(cOrig,RAT("\",cOrig)+1,Len(cOrig))
	cExt  := SubStr(cOrig,RAT(".",cOrig)+1,Len(cOrig))

	cDirUP  := oINNWeb:aDirTemp[3]
	cDirRp  := oINNWeb:aDirTemp[4]
	
	cId  :=  CriaTrab( NIL, .F. ) 
	cId  :=  SubStr(cId,3,Len(cId))
	cDest := cId + "." + cExt
	
	PswOrder(1)//1 - ID do usuário/grupo
	PswSeek( oINNWeb:UserID, .T. )  
	cUsuario := PswRet()[1][2]
	
	if !( lower(cExt) $ "jpg/png/gif/jpg/jpeg/" )
	
		oINNWeb:AddCallOut("Extenção de arquivo invalida!","danger")
		fProduto(cProduto)
				
	else
			
		
		if FRENAME ( cDirUP + cOrig , cDirRp + cDest ) == -1
		   			   
		   oINNWeb:AddCallOut("Erro ao abrir o arquivo!<br>"+cDirUP + cOrig+"<br>"+cDirRp + cDest+"<br>"+str(ferror(),4),"danger")
		   fProduto(cProduto)
		   
		else
		
			//oINNWeb:AddCallOut(cDirUP + cOrig+"<br>"+cDirRp + cDest,"success")
		   		
	   		//oINNWeb:AddCallOut(oINNWeb:aDirTemp[5] + alltrim(cId) +"."+ cExt,"danger")
	   		cMD5 := MD5File( oINNWeb:aDirTemp[5] + alltrim(cId) +"."+ cExt ,2,1) 

			dbSelectArea("INN001")
			INN001->(dbSetOrder(2))
			if INN001->(dbSeek(xFilial("SB1")+cMD5))
												   
			   	oINNWeb:AddCallOut("Esse arquivo ja existe!","danger")
				
				if !Empty(cProduto)
					
					fInsertVinc(INN001->BMPID,cProduto)
					
				endif
				
				if !lRemoto
					fFoto(INN001->BMPID)
				endif
			
			else
	
				RecLock("INN001",.T.) 
					Replace BMFILIAL with xFilial("SB1")
					Replace BMPID    with cId
					Replace BMPNAME  with cDest 
			 		Replace USINCLU  with cUsuario
					Replace DTINCLU  with Date()
					Replace BMPDIR   with cDirRp
					Replace BMPEXT   with cExt
					Replace BMPURL   with oINNWeb:aDirTemp[6] + cDest
					Replace BMPMD5   with cMD5
					Replace BMPDIR   with oINNWeb:aDirTemp[5] + alltrim(cId) +"."+ cExt
				MsUnLock("INN001")
				
				if !Empty(cProduto)
				
					dbSelectArea("SB1")
					SB1->(dbSetOrder(1))
					if SB1->(dbSeek(xFilial("SB1")+cProduto))
					
						fInsertVinc(cId,cProduto)
						
					endif
					
				endif
						
				oINNWeb:AddCallOut("Foto adicionada!","success")
				
				//fLimpa() 
				
				if !lRemoto
					if lProd
						fProduto(cProduto)
					else
						fFoto(cId)
					endif
				endif
				
			endif

		endif

	endif
	
Return()

Static Function fInsertVinc(cId,cProd)

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if SB1->(dbSeek(xFilial("SB1")+cProd))	
		
		dbSelectArea("INN002")
		INN002->(dbSetOrder(1))
		if !INN002->(dbSeek(xFilial("SB1")+cId+SB1->B1_COD))

			RecLock("INN002",.T.) 
				Replace BMFILIAL  	with xFilial("SB1")
				Replace BMPID  		with cId
				Replace B1_COD 		with SB1->B1_COD 
				Replace SEQUENC 	with "99" 
			MsUnLock("INN002") 
			
			oINNWeb:AddCallOut("Vinculo criado!","success")
				
		ELSE
					
			oINNWeb:AddCallOut("Ja existe esse vinculo!","danger")

		ENDIF
		
	else
			
		oINNWeb:AddCallOut("Produto não encontrado!","danger")
					
	endif
		
	fOrdena(cProd,"","") 
							
Return

Static Function fDelFot(cIdFoto)


	dbSelectArea("INN001")
	INN001->(dbSetOrder(1)) 
	if INN001->(dbSeek(xFilial("SB1")+cIdFoto))
	
		RecLock("INN001",.F.) 
			dbDelete()
		MsUnLock("INN001") 	
	
		dbSelectArea("INN002")
		INN002->(dbSetOrder(1)) 
		INN002->(dbSeek(xFilial("SB1")+cIdFoto))
		
		while !( INN002->(EOF()) ) .and. INN002->BMPID == cIdFoto
	
			RecLock("INN002",.F.) 
				dbDelete()
			MsUnLock("INN002") 				
	
			INN002->(dbSkip()) 
			
		enddo

		oINNWeb:AddCallOut("Foto excluida com sucesso!","success")
	
	else
	
		oINNWeb:AddCallOut("Foto não encontrada","danger")
	
	endif
	
	fGaleria()
							
Return

Static Function fDelVic(cIdFoto,cProd,cDelVic)

	dbSelectArea("INN002")
	INN002->(dbSetOrder(1)) 
	INN002->(dbGoTo(val(cDelVic)))
	
	if INN002->(Recno()) == val(cDelVic) .and. Alltrim(cIdFoto) == Alltrim(INN002->BMPID)
	
		RecLock("INN002",.F.) 
			dbDelete()
		MsUnLock("INN002") 
		
		oINNWeb:AddCallOut("Vinculo excluido com sucesso!","success")
		
	else
	
		oINNWeb:AddCallOut("Erro ao encontrar vinculo!","danger")
	
	endif
	
	if !Empty(cProd)
		fProduto(cProd)
	else
		fFoto(cIdFoto)
	endif
							
Return

Static Function fAltIdFoto(cAltIdFoto)

Return
