#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebParam FROM ClsINNWeb
	
	data oParent AS OBJECT
	data aParm
	data cTitulo
	data cTexto
	data cLbButon
	data lGet
	data cAction
	data cFormID
	data lTime
	data lAccordion

	METHOD New() Constructor
	METHOD Init()

	METHOD SetTitle(  )
	METHOD SetParm(  )


	METHOD SetTexto(  )
	METHOD SetTxtButton(  )
	METHOD SetMethodGet(  )
	METHOD SetMethodPost(  )
	METHOD SetAction()

	METHOD Execute(  )

	METHOD addData()
	METHOD addNum()
	METHOD addMonetary()
	METHOD addCombo()
	METHOD addComboMultiple()
	METHOD addcBoxX3()
	METHOD addHidden()
	METHOD addMemo()
	METHOD addFILIAL()
	METHOD addText()
	METHOD addHora()
	METHOD addTextArea()
	METHOD AddParm()
	METHOD addQuebra()
	METHOD addRadio()

	METHOD SetID( )

	METHOD SetAccordion( )

ENDCLASS

METHOD SetTitle( xTitulo ) CLASS INNWebParam
	::cTitulo := xTitulo
Return

METHOD SetID( xFormID ) CLASS INNWebParam
	::cFormID := xFormID
Return

METHOD SetParm( xParm ) CLASS INNWebParam
	::aParm := xParm
Return

METHOD SetTexto( xTexto ) CLASS INNWebParam
	::cTexto := xTexto
Return

METHOD SetTxtButton( xLbButon ) CLASS INNWebParam
	::cLbButon := xLbButon
Return

METHOD SetMethodGet(  ) CLASS INNWebParam
	::lGet := .T.
Return

METHOD SetMethodPost(  ) CLASS INNWebParam
	::lGet := .F.
Return

METHOD SetAction(xAction) CLASS INNWebParam
	::cAction := xAction
Return

METHOD SetAccordion(lAccordion) CLASS INNWebParam
	::lAccordion := lAccordion
Return

METHOD New( xParent ) CLASS INNWebParam
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebParam,ClsINNWeb

    ::Init()
	::oParent := xParent
            
    //oParent:AddItem(Self)	

	::oParent:AddBody(Self)
	
Return Self

METHOD Init() CLASS INNWebParam

	::aParm			:= {}
	::cTitulo		:= "Parâmetros para pesquisa"
	::cTexto		:= ""
	::cLbButon		:= "Pesquisar"
	::lGet			:= .T.
	::cAction		:= ""
	::cFormID		:= ""
	::lTime			:= .F.
	::lAccordion	:= .F.

	::cFormID := "INNFORM"+alltrim(CriaTrab( NIL, .F. ))

Return

METHOD Execute() Class INNWebParam

	Local cBody := ""
	Local nY	:= 0
	Local nX 	:= 0
	Local aSM0  := {}
	//Local aTemp := FWLoadSM0()
	
	/*For nX := 1 To Len(aTemp)
		if .T.//HttpSession->WsEmp == aTemp[nX][1]
			aadd(aSM0,aClone(aTemp[nX]))
		endif
	Next nX*/

	For nX := 1 To Len(::oParent:aUsrSM0)
		if HttpSession->WsEmp == ::oParent:aUsrSM0[nX][1]
			aadd(aSM0,aClone(::oParent:aUsrSM0[nX]))
		endif
	Next nX
	
	aadd(::aParm ,{'x','x',0,'H',::oParent:cPagina,.F.})
			
	//cBody += "<div class='card card-fluid'>" + CRLF
	//cBody += "<div class='card-body'>" + CRLF
	//cBody += "<h3 class='card-title'> "+::cTitulo+" </h3>" + CRLF
	if !Empty(::cTexto)
		cBody += "<p>"+::cTexto+"</p>" + CRLF
	endif
	cBody += "<form class='' method='"+iif(::lGet,"get","post")+"' enctype='application/x-www-form-urlencoded' name='"+::cFormID+"' id='"+::cFormID+"' "+iif(Empty(::cAction),""," action='"+::cAction+"'")+" onsubmit='return validateForm"+::cFormID+"()'>" + CRLF	
	cBody += "<div class='form-row align-items-center'>" + CRLF

	for nY := 1 To Len(::aParm)

		Do case

			Case ::aParm[nY][4] == "BR" //Quebra de linha
				cBody += "<div class='col-sm-12 col-lg-12 my-0'></div>" + CRLF

			Case ::aParm[nY][4] == "D" //Data
				::aParm[nY][5] := iif(empty(::aParm[nY][5]),"",dToc(::aParm[nY][5]))
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <input name='"+::aParm[nY][1]+"' "
				cBody += "             type='text' "
				cBody += "             class='form-control' "
				cBody += "             id='"+::aParm[nY][1]+"' "
				cBody += "             value='"+::aParm[nY][5]+"' "
				cBody += "             maxlength='10' "
				cBody += "             autocomplete='off' "
				IF ::aParm[nY][6]
					cBody += "         required "
				endif
				cBody += ">" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').datepicker({format: 'dd/mm/yyyy',todayBtn: 'linked',language: 'pt-BR',autoclose: true,toggleActive: true});" })			
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').mask('99/99/9999');" })
			
			Case ::aParm[nY][4] == "N" //Numerico
				aTemp := aClone(::aParm[nY])
				aTemp[3] += 20
				cPic := "@E 999,999,999,999."+Replicate("9",::aParm[nY][3])
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({aTemp[1],aTemp[2],aTemp[3],aTemp[4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='text' "
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				//cBody += "                     value='' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				cBody += "                     >" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').maskMoney({prefix:'', allowNegative: true, thousands:'.', decimal:',', affixesStay: false,precision: "+cValtochar(::aParm[nY][3])+"});" })
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').val("+cValToChar(::aParm[nY][5])+");" })

			
			Case ::aParm[nY][4] == "MN" //Monetario
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='text' "
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				cBody += "                     value='"+Alltrim(Transform(::aParm[nY][5],"@E 999,999,999,999.99"))+"' "
				cBody += "                     placeholder='0,00' "
				cBody += "                     autocomplete='off' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				cBody += "                     >" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({ "$('#"+::aParm[nY][1]+"').maskMoney({prefix:'R$ ', allowNegative: true, thousands:'.', decimal:',', affixesStay: false});" })
			
			Case ::aParm[nY][4] == "RD"
			
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <label class='d-block'>"+::aParm[nY][2]+"</label>" + CRLF

				for nX := 1 To Len(::aParm[nY][7])
					cBody += "    <div class='custom-control custom-control-inline custom-radio'>" + CRLF
					cBody += "      <input type='radio' class='custom-control-input' name='"+Alltrim(::aParm[nY][1])+"' id='rd_"+cValToChar(nY)+"_"+cValToChar(nX)+"' value='"+Alltrim(::aParm[nY][7][nX][1])+"'>" + CRLF
					cBody += "      <label class='custom-control-label' for='rd_"+cValToChar(nY)+"_"+cValToChar(nX)+"'>"+Alltrim(::aParm[nY][7][nX][2])+"</label>" + CRLF
					cBody += "    </div>" + CRLF
				next nX
				cBody += "  </div><!-- /form-label-group -->" + CRLF
				cBody += "</div><!-- /col-sm-12-->" + CRLF
				
				//::oParent:AddLoad({"$('#"+::aParm[nY][1]+"').val('"+::aParm[nY][5]+"');"})

			Case ::aParm[nY][4] == "C"//Combo ou select
			
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <select id='"+Alltrim(::aParm[nY][1])+"' name='"+Alltrim(::aParm[nY][1])+"' class='custom-select' " 
				IF ::aParm[nY][6]
					cBody += " required "
				endif
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += " >" + CRLF
				for nX := 1 To Len(::aParm[nY][7])
					cBody += "						<option value='"+Alltrim(::aParm[nY][7][nX][1])+"'>"+Alltrim(::aParm[nY][7][nX][2])+"</option>" + CRLF
				next nX
				cBody += "		         </select>" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				::oParent:AddLoad({"$('#"+::aParm[nY][1]+"').val('"+::aParm[nY][5]+"');"})
			
			Case ::aParm[nY][4] == "CM"//Combo ou select multipla escolha

				::oParent:AddLoad({"$('#"+Alltrim(::aParm[nY][1])+"').select2({placeholder: '"+::aParm[nY][2]+"'});"})
				::oParent:AddLoad({"$('#"+Alltrim(::aParm[nY][1])+"').val(["+::aParm[nY][5]+"]).trigger('change');"})

				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <select id='"+Alltrim(::aParm[nY][1])+"' name='"+Alltrim(::aParm[nY][1])+"' class='form-control js-example-basic-multiple' multiple"
				IF ::aParm[nY][6]
					cBody += " required "
				endif
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += ">" + CRLF
				for nX := 1 To Len(::aParm[nY][7])
					cBody += "      <option value='"+Alltrim(::aParm[nY][7][nX][1])+"'>"+Alltrim(::aParm[nY][7][nX][2])+"</option>" + CRLF
				next nX
				cBody += "    </select>" + CRLF

				cBody += "  </div><!-- /.form-group -->" + CRLF
				cBody += "</div><!-- /.col-sm-12 col-lg-12  -->" + CRLF
		
			Case ::aParm[nY][4] == "H" //Hidden (Escondido)
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody += "                     type='hidden' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				cBody += "                     value='"+::aParm[nY][5]+"'>" + CRLF
			
			Case ::aParm[nY][4] == "M"//Campo memo
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF		
				cBody += "			    <textarea style='width:100%; min-height: 500px;' "
				cBody += "                     name='"+::aParm[nY][1]+"' "			
				cBody += "                     class='form-control' "
				cBody += "                     id='"+::aParm[nY][1]+"' "
				IF nY == 1
					cBody += "                     autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody += "                     required "
				endif
				IF ::aParm[nY][4] == "TB"
					cBody += "                     disabled "
				endif
				cBody += "                     >"+::aParm[nY][5]+"</textarea>" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF		
			
			Case ::aParm[nY][4] == "FILIAL"//Exibe um combo para escolha das filais
				::aParm[nY][1] := "FilsCalc"
				::aParm[nY][2] := "Filial"
				::aParm[nY][3] := 20
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "	    <select id='FilsCalc' name='FilsCalc' size='2' class='form-select custom-select' required multiple "// multiple='multiple' style='min-width: 100px;' " 
				IF nY == 1
					cBody += " autofocus='' "
				endif
				cBody += " > "
				for nX := 1 To Len(aSM0)
					cBody += "<option value='"+Alltrim(aSM0[nX][2])+"'>"+Alltrim(aSM0[nX][7])+"</option>" + CRLF
				next nX
				cBody += "		         </select>" + CRLF
				cBody += "      <label>Filial</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF
				if ::aParm[nY][5] .and. Empty(::oParent:cFilsCalc)// .and. Empty(cformID)
					for nX := 1 To Len(aSM0)
						::oParent:cFilsCalc += iif(Empty(::oParent:cFilsCalc),"",",")
						::oParent:cFilsCalc += "'"+Alltrim(aSM0[nX][2])+"'"
					next nX				
				endif
				::oParent:AddLoad({"$('#FilsCalc').val(["+::oParent:cFilsCalc+"]).trigger('change');"})

			Case ::aParm[nY][4] == "TT"
				cBody += "<div class='col-sm-12 col-lg-12 my-1'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "      <textarea class='form-control' name='"+::aParm[nY][1]+"' id='"+::aParm[nY][1]+"' style='width:100%; min-height: 300px;'>"+::aParm[nY][5]+"</textarea>" + CRLF

				//cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF

			OtherWise //Texto
				cBody += "<div class='col-sm-12 col-lg-"
				cBody += ::oParent:TamFild({::aParm[nY][1],::aParm[nY][2],::aParm[nY][3],::aParm[nY][4]})
				cBody += " my-0'>" + CRLF
				cBody += "  <div class='form-group'>" + CRLF
				cBody += "    <div class='form-label-group'>" + CRLF
				cBody += "			    <input name='"+::aParm[nY][1]+"' "
				cBody +=                      "type='text' "
				cBody +=                      "class='form-control' "
				cBody +=                      "id='"+::aParm[nY][1]+"' "
				cBody +=                      "value='"+::aParm[nY][5]+"' "
				cBody +=                      "maxlength='"+cValToChar(::aParm[nY][3])+"' "
				IF nY == 1
					cBody +=                  "autofocus='' "
				endif
				IF ::aParm[nY][6]
					cBody +=                  "required "
				endif
				IF ::aParm[nY][4] == "TB"
					cBody +=                  "disabled "
				endif
				cBody +=                      ">" + CRLF
				cBody += "      <label>"+::aParm[nY][2]+"</label>" + CRLF
				cBody += "    </div><!-- /col-sm-12 -->" + CRLF
				cBody += "  </div><!-- /form-group -->" + CRLF
				cBody += "</div><!-- /form-label-group -->" + CRLF

		end

	next nY

	cBody += "			  </div><!-- /form-row align-items-center -->" + CRLF

	cBody += "    <div class='form-actions'>" + CRLF
    //cBody += "      <button class='btn btn-primary' type='submit'>"+::cLbButon+"</button>" + CRLF
	cBody += "      <button class='btn btn-primary' type='submit' onclick='' id='btnConfirmar"+::cFormID+"'>"+::cLbButon+"</button>" + CRLF
	cBody += "    </div><!-- /.form-actions -->" + CRLF
	cBody += "    </form>" + CRLF
	//cBody += "  </div><!-- /card-body -->" + CRLF
	//cBody += "</div><!-- /card card-fluid -->" + CRLF
	
	//::oParent:AddBody(cBody)

	cBody := ::oParent:addCard(	cBody,;			//cRetBody
								::cTitulo,;		//cTitulo
								,;				//cRetFoot
								::lAccordion,;	//lAccordion
								.F. )			//lIncorpora

	xbtnload := '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Processando...'
	aJSFoot := {}
	aadd(aJSFoot,"function validateForm"+::cFormID+"() {")
	aadd(aJSFoot,"  $('#btnConfirmar"+::cFormID+"').prop('disabled',true); ")
	aadd(aJSFoot,"  $('#btnConfirmar"+::cFormID+"').html('"+xbtnload+"'); ")
	aadd(aJSFoot,"}")//function

	::oParent:addJSFoot(aJSFoot)

Return(cBody)

METHOD addData(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'D',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	if ValType (xParm[3] ) != "D"
		aItemParm[5] := cTod("") //04 Conteudo
	else
		aItemParm[5] := xParm[3] //04 Conteudo
	endif
	aItemParm[6] := xParm[4] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addNum(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'N',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.,;
						"999,999,999,999.999"} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[3] := xParm[3] //03 Tamanho
	aItemParm[5] := xParm[4] //04 Conteudo 
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addMonetary(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						2,; 		//Tamanho
						'N',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.,;
						"999,999,999,999.99"} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //04 Conteudo 
	aItemParm[6] := xParm[4] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addCombo(xParm) Class INNWebParam

	Local nY
	Local aItemParm := {"",;	 	//01 Campo
						"",;	 	//02 Titulo do Campo
						0,; 		//03 Tamanho
						'C',; 		//04 Tipo do Campo
						"",; 		//05 Conteudo 
						.F.,; 		//06 Obrigatorio? (required)
						{}}			//07 Itens da array

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //03 Conteudo 
	aItemParm[7] := xParm[4] //04 Itens da array
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	for nY := 1 To Len(xParm[4])
		aItemParm[3] := Max( aItemParm[3] , Len(xParm[4][nY][2]) )
	next

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addcBoxX3(xParm) Class INNWebParam

	Local xParmX3 := {"","","",{},.F.}
	Local nLinha := 0
	Local xTemp
	Local aOpcoes := {{"",""}}
	Local aSaveArea		 := getArea()
	Local aSaveSX3		 := SX3->(getArea())

	xParmX3[1] := xParm[1] //01 Campo
	xParmX3[2] := xParm[2] //02 Titulo do Campo
	xParmX3[3] := xParm[3] //03 Conteudo 
	xParmX3[4] := {}       //04 Itens da array
	xParmX3[5] := xParm[5] //05 Obrigatorio? (required)
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	if SX3->(dbSeek(SUBSTR(xParm[4]+SPACE(10),1,10)))
	
		if SubStr(X3CBox(),1,1) == "#"
			xTemp := &(SubStr(X3CBox(),2))
		else
			xTemp := X3CBox()	
		endif
		
	endif

	if !empty(xTemp)

		//quebrar nas opções
		xTemp := STRTOKARR(xTemp,";")
		
		//percorre as opçoes
		for nLinha := 1 to len(xTemp)
		
			//quebra as opçoes que possuem valor e descricao
			xTemp[nLinha] := ALLTRIM(xTemp[nLinha])
			xTemp[nLinha] := StrTokArr(xTemp[nLinha],"=")
			
			//veio uma unica opção, então vou duplica ela pra virar uma array
			if len(xTemp[nLinha]) == 1
				aadd(aOpcoes,{xTemp[nLinha],xTemp[nLinha]})
			else
				aadd(aOpcoes,aclone(xTemp[nLinha]))
			endif
			
		NEXT

	endif
	
	SX3->(RestArea(aSaveSX3))
	RestArea(aSaveArea)

	xParmX3[4] := aClone(aOpcoes)

	//VARINFO("xParmX3",xParmX3)

	Self:addCombo(aClone(xParmX3))

Return

METHOD addComboMultiple(xParm) Class INNWebParam

	Local nY
	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'CM',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.,; 		//Obrigatorio? (required)
						{}}			//Itens da array

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //04 Conteudo 
	aItemParm[7] := xParm[4] //Itens da array
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	for nY := 1 To Len(xParm[4])
		aItemParm[3] := Max( aItemParm[3] , Len(xParm[4][nY][2]) )
	next

	aadd(::aParm,aClone(aItemParm))
	
Return(Len(::aParm))

METHOD addHidden(xParm) Class INNWebParam
	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'H',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[5] := xParm[2] //04 Conteudo 

	aadd(::aParm,aClone(aItemParm))
Return(Len(::aParm))

METHOD addMemo(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addFILIAL(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))

METHOD addText(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'T',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[3] := xParm[3] //03 Tamanho
	aItemParm[5] := xParm[4] //04 Conteudo 
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD addHora(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						5,; 		//Tamanho
						'T',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //03 Conteudo 
	aItemParm[6] := xParm[4] //04 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

	/*if !::lTime
		::oParent:AddLoad({ "$.mask.definitions['H'] = '[0-2]';" })
		::oParent:AddLoad({ "$.mask.definitions['h'] = '[0-9]';" })
		::oParent:AddLoad({ "$.mask.definitions['M'] = '[0-5]';" })
		::oParent:AddLoad({ "$.mask.definitions['m'] = '[0-9]';" })
		::lTime := .T.
	endif*/

	::oParent:AddLoad({ "$('#"+xParm[1]+"').mask('Hh:Mm',{translation: {'H': {pattern: /[0-2]/},'h': {pattern: /[0-9]/},'M': {pattern: /[0-6]/},'m': {pattern: /[0-9]/}}});" })

Return(Len(::aParm))

METHOD addTextArea(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'TT',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	aItemParm[5] := xParm[3] //03 Conteudo 

	aadd(::aParm,aClone(aItemParm))

	::oParent:lTxtEdit := .T.

Return(Len(::aParm))

METHOD addQuebra() Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'BR',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.} 		//Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))

Return(Len(::aParm))

METHOD AddParm(xParm) Class INNWebParam
	aadd(::aParm,aClone(xParm))
Return(Len(::aParm))


METHOD addRadio(xParm) Class INNWebParam

	Local aItemParm := {"",;	 	//Campo
						"",;	 	//Titulo do Campo
						0,; 		//Tamanho
						'RD',; 		//Tipo do Campo
						"",; 		//Conteudo 
						.F.,; 		//Obrigatorio? (required)
						{}}			//Itens da array

	aItemParm[1] := xParm[1] //01 Campo
	aItemParm[2] := xParm[2] //02 Titulo do Campo
	//aItemParm[5] := xParm[3] //04 Conteudo 
	aItemParm[7] := xParm[4] //Itens da array
	aItemParm[6] := xParm[5] //05 Obrigatorio? (required)

	aadd(::aParm,aClone(aItemParm))
	
Return(Len(::aParm))
