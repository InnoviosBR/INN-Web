#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebImgProd FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data cProduto

	METHOD New() Constructor
	METHOD Init()
	METHOD GetImg(  )
	METHOD GetImgUrl(  )
	METHOD SetProduto( )
	METHOD GetGaleria()
	METHOD Execute(  )

ENDCLASS

METHOD New( xParent ) CLASS INNWebImgProd
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebImgProd,ClsINNWeb

    ::Init()
	::oParent := xParent
	::oParent:AddBody(Self)
	::oParent:lImgPop := .T.

	::cProduto := ""
	
Return Self

METHOD Init() CLASS INNWebImgProd



Return

METHOD Execute() Class INNWebImgProd

	Local cBody := ""

Return(cBody)

METHOD GetImg(cCodigo,lIncorpora) Class INNWebImgProd

	Local cImagem	:= ""

	Default lIncorpora := .F.
	Default cCodigo := ::cProduto
			
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if ( SB1->(dbSeek(xFilial("SB1")+cCodigo)) )
	
		cImagem := "<div style='text-align: center;width: auto;'>"
		cImagem += "<a class='image-popup-no-margins' id='"+alltrim(SB1->B1_COD)+"' href='?x=wProdFotos&produto="+Alltrim(SB1->B1_COD)+"' target='wProdFotos"+Alltrim(SB1->B1_COD)+"'>"
		cImagem += "<i class='fas fa-camera-retro fa-3x'></i>"
		cImagem += "</a>"
		cImagem += "</div>"
       		
    	dbSelectArea("INN002")
    	INN002->(dbSetOrder(2)) 
			
		if INN002->(dbSeek(xFilial("SB1")+SB1->B1_COD)) //B1_COD+BMPID
		
    		dbSelectArea("INN001")
			INN001->(dbSetOrder(1))
			
			if INN001->(dbSeek(xFilial("SB1")+INN002->BMPID)) //BMPID
			
				cImagem := "<a class='image-popup-no-margins' id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'>"
				cImagem += "<img src='"+Alltrim(INN001->BMPURL)+"' style='max-width: 75px;'>"
				cImagem += "</a>"
								
			endif
			
    	endif
		
	endif

	if lIncorpora
		::oParent:AddBody(cImagem)
	endif

Return(cImagem)




METHOD GetImgUrl(cCodigo) Class INNWebImgProd

	Local cImagem	:= "https://dummyimage.com/450x300/dee2e6/6c757d.jpg"
			
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if ( SB1->(dbSeek(xFilial("SB1")+cCodigo)) )
	      		
    	dbSelectArea("INN002")
    	INN002->(dbSetOrder(2)) 
			
		if INN002->(dbSeek(xFilial("SB1")+SB1->B1_COD)) //B1_COD+BMPID
		
    		dbSelectArea("INN001")
			INN001->(dbSetOrder(1))
			
			if INN001->(dbSeek(xFilial("SB1")+INN002->BMPID)) //BMPID
			
				cImagem := Alltrim(INN001->BMPURL)
								
			endif
			
    	endif
		
	endif

Return(cImagem)

METHOD SetProduto( xProduto ) CLASS INNWebImgProd

	::cProduto := xProduto

Return

METHOD GetGaleria() CLASS INNWebImgProd

	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	if ( SB1->(dbSeek(xFilial("SB1")+::cProduto)) )	
       		
    	dbSelectArea("INN002")
    	INN002->(dbSetOrder(2)) 
		INN002->(dbSeek(xFilial("SB1")+SB1->B1_COD)) //BMFILIAL+B1_COD+SEQUEN

		While !( INN002->(eof()) ) .and. INN002->BMFILIAL == xFilial("SB1") .and. INN002->B1_COD == SB1->B1_COD

    		dbSelectArea("INN001")
			INN001->(dbSetOrder(1))
			if INN001->(dbSeek(xFilial("SB1")+INN002->BMPID)) //BMPID
			
				//cImagem := "<img src='"+Alltrim(INN001->BMPURL)+"' style='max-width: 75px;'></a>"
				/*cImagem := "<a class='image-popup-no-margins' id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'>"
				cImagem += "<img src='"+Alltrim(INN001->BMPURL)+"' style='max-width: 75px;'>"
				cImagem += "</a>"*/

				cBody := ""
				//cBody += "    <div style='max-width: 500px;' class='center-block'>" + CRLF
				cBody += "<figure class='figure'><a id='ImgProd' href='"+Alltrim(INN001->BMPURL)+"'><img src='"+Alltrim(INN001->BMPURL)+"' class='img-fluid'></a></figure>" + CRLF
				//cBody += "    </div>" + CRLF
				::oParent:addCard(cBody)
								
			endif

			INN002->(dbSkip())
			
    	EndDo
		
	endif

Return
