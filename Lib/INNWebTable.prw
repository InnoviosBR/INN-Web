#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

/*
Monta uma tabela na tela
*/

CLASS INNWebTable FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data cTitulo
	data aHead
	data aCols
	data aFoot
	data lCSV
	data aLinks
	data aForm
	data cNomArq
	data lSimples
	data lLinks
	data cLengthMenu
	data lButtons
	data cOrdem
	data lLength
	data lOrdering
	data cId
	data cArqJsonDown
	data cArqJsonDisp
	data cArqCSVDown
	data cArqCSVDisp
	data lFoot

	METHOD New() Constructor
	METHOD Init()

	METHOD SetTitle(  )
    METHOD AddHead(  )
	METHOD addX3Field(  )
    METHOD AddCols(  )
	METHOD AddFoot(  )
	METHOD SetCols(  )
    METHOD SetValue(  )
	METHOD SumValue(  )
	METHOD GetValue(  )
	METHOD GetLen(  )
    METHOD SetLinks(  )
    METHOD SetLink(  )
	METHOD SetSimple(  )
	METHOD SetCSV(  )
	METHOD SetFile(  )
	METHOD Execute(  )
	METHOD lengthMenu(  )
	METHOD Setlength(  )
	METHOD SetOrdem(  )
	METHOD SetID(  )

	METHOD GetCSV( )
	METHOD GetJson( )

	METHOD SimpleX3Table() //Exibe um tabela de itens baseado em uma tabela do dicionario aplicado um filtro
	METHOD SimpleQueryTable() //Cria uma tabla na tela a partir de uma query

ENDCLASS

METHOD New( xParent ) CLASS INNWebTable
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebTable,ClsINNWeb

    ::Init()
	::oParent := xParent
	::lSimples := ::oParent:lSimpPG
    ::oParent:AddBody(Self)

	::cId   := alltrim(CriaTrab( NIL, .F. ))
	::cId   := "INN"+iif(!Empty(::oParent:cIdPgn),::oParent:cIdPgn,"")+dtos(date())+strtran(time(),":","")+"_"+substr(::cId,3,len(::cId))
	
Return Self

METHOD Init() CLASS INNWebTable

	::cTitulo		:= "Visualização em tela"
	::aHead			:= {}
	::aCols			:= {}
	::aFoot			:= {}
	::aLinks		:= {}
	::lCSV			:= .F.
	::aForm			:= {}
	::cNomArq		:= ""
	::lSimples		:= .F.
	::lLinks		:= .F.
	::cLengthMenu	:= "[25, 50, 100, -1], [ 25, 50, 100, 'All']"
	::cOrdem		:= "[0, 'asc']"
	::lButtons		:= .T.
	::lLength		:= .T.
	::lOrdering		:= .T.
	::cId			:= ""
	::cArqJsonDown	:= ""
	::cArqJsonDisp	:= ""
	::cArqCSVDown	:= ""
	::cArqCSVDisp	:= ""
	::lFoot			:= .F.

Return

METHOD SetTitle( xTitulo ) Class INNWebTable
	::cTitulo := xTitulo
Return

METHOD AddHead( xHead ) Class INNWebTable

	//xHead[1] = Titulo
	//xHead[2] = Tipo
	//xHead[3] = Mascara
	//xHead[4] = link?
	//xHead[5] = Soma numero no foot

	if Len(xHead) < 4
		aadd(xHead,.F.)
	endif
	if ValType(xHead[4]) != "L"
		xHead[4] := .F.
	endif
	if Len(xHead) < 5
		aadd(xHead,.F.)
	endif
	if ValType(xHead[5]) != "L"
		xHead[5] := .F.
	endif
	if xHead[5]
		::lFoot := .T.
	endif
	aadd(::aHead,aClone(xHead))
	aadd(::aFoot,"")

Return

METHOD addX3Field( xHead ) Class INNWebTable

	//O que devemos receber nesse metodo
	//xHead[1] = Campo
	//xHead[2] = link?
	//xHead[3] = Soma numero no foot

	if Len(xHead) < 2
		aadd(xHead,.F.)
	endif

	if Len(xHead) < 3
		aadd(xHead,.F.)
	endif

	//O que devemos passar para o AddHead
	//xHead[1] = Titulo
	//xHead[2] = Tipo
	//xHead[3] = Mascara
	//xHead[4] = link?
	//xHead[5] = Soma numero no foot

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	SX3->(dbSeek(xHead[1]))

	Self:AddHead({	Alltrim(SX3->X3_TITULO),;
					SX3->X3_TIPO,;
					SX3->X3_PICTURE,;
					xHead[2],;
					xHead[3]})

Return

METHOD AddCols( xCols ) Class INNWebTable
	aadd(::aCols,aClone(xCols))
	aadd(::aLinks,Array(len(::aHead)))
Return(Len(::aCols))

METHOD AddFoot( xCol , xValue ) Class INNWebTable

	::lFoot := .T.
	::aFoot[xCol] := xValue

Return(.T.)

METHOD SetCols( xCols ) Class INNWebTable
	Local nY
	::aCols := {}
	for nY := 1 To Len(xCols)
		aadd(::aCols,aClone(xCols[nY]))
		aadd(::aLinks,Array(len(::aHead)))
	next nY
Return(Len(::aCols))

METHOD SetValue( xLinha , xCol , xValor ) Class INNWebTable
	Default xLinha := Len(::aCols)
	::aCols[xLinha][xCol] := xValor
Return

METHOD SumValue( xLinha , xCol , xValor ) Class INNWebTable
	Default xLinha := Len(::aCols)
	::aCols[xLinha][xCol] += xValor
Return

METHOD GetValue( xLinha , xCol ) Class INNWebTable
	Local xValor := nil
	Default xLinha := Len(::aCols)
	xValor := ::aCols[xLinha][xCol]
Return(xValor)

METHOD GetLen() Class INNWebTable
Return(Len(::aCols))

METHOD SetLinks( xLinks ) Class INNWebTable
	::aLinks := aClone(xLinks)
Return

METHOD SetLink( xLinha , xCol , xLink ) Class INNWebTable
	Default xLinha := Len(::aCols)
	::aLinks[xLinha][xCol] := xLink
Return

METHOD SetCSV(  ) Class INNWebTable
	::lCSV := .T.
Return

METHOD SetFile( xNomArq ) Class INNWebTable
	::cNomArq := xNomArq
	::cId   := alltrim(CriaTrab( NIL, .F. ))
	::cId   := ::cNomArq+substr(::cId,3,len(::cId))
Return

METHOD SetSimple(  ) Class INNWebTable
	::lSimples := .T.
	::lOrdering := .F.
	::cOrdem := ""
Return

METHOD lengthMenu( xLengthMenu ) Class INNWebTable
	::cLengthMenu := xLengthMenu
Return

METHOD Setlength( xLength ) Class INNWebTable
	::lLength := xLength
Return

METHOD SetOrdem( xOrdem ) Class INNWebTable
	::cOrdem := xOrdem
Return

METHOD SetID( xID ) Class INNWebTable
	::cID := xID
Return

METHOD GetCSV( ) Class INNWebTable

	Local nY
	Local nLinha
	Local nCol
	Local cLog
	Local nHandle
	Local cLinha
	Local cCampo
	Local cTipo

	::cArqCSVDisp := ::oParent:aDirTemp[1] + ::cId + ".csv"
	::cArqCSVDown := ::oParent:aDirTemp[2] + ::cId + ".csv"
	
	cLog := ""
	nHandle := FCreate(::cArqCSVDisp)

	If nHandle == -1

		Self:addBody("<!-- ID: "+::cId+" -->")
		Self:addBody("<!-- Arquivo: "+::cArqCSVDisp+" -->")
		Self:addBody("<!-- URL: "+::cArqCSVDown+" -->")
		cLog += 'Erro de abertura : FERROR ' + str(ferror(),4) + "<br>" + CRLF	

	else

		cLinha    := ""
		
		For nY := 1 To Len(::aHead)
			cLinha += Alltrim(::aHead[nY][1]) + ";"
		next

		FWrite(nHandle, cLinha + CRLF)
		
		For nLinha := 1 To Len(::aCols)
			cLinha := ""
			For nCol := 1 To Len(::aHead)
				cCampo := ::aCols[nLinha][nCol]
				cTipo  := ::aHead[nCol][2]//ValType(cCampo)
				if cTipo == "D"
					if Empty(cCampo)
						cCampo := ""
					else
						cCampo := dToc(cCampo)
					endif
				elseif cTipo == "N"
					cCampo := Alltrim(Transform(cCampo,::aHead[nCol][3]))
				elseif cTipo == "L"
					cCampo := iif(cCampo,'="Verdadeiro"','="Falso"')
				elseif cTipo == "C" .and. ("<i" $ cCampo .or. "<a" $ cCampo)
					cCampo := ""
				elseif cTipo == "C" .and. Empty(cCampo)
					cCampo := ""
				elseif cTipo == "C"
					cCampo := '="' + fTxtToCsv(cCampo) + '"'
				else
					cCampo := ""
				endif			
				cLinha += cCampo + ";"
			next nCol
			FWrite(nHandle, cLinha + CRLF) // Insere texto no arquivo  
		Next nLinha
		FClose(nHandle)
	endif  
	
Return

METHOD GetJson() Class INNWebTable

	Local cBody	:= ""
	Local nY
	Local nLinha
	Local nCol
	Local aJSFoot
	Local cLog
	Local nHandle
	Local cLinha
	Local cCampo
	Local cTipo
	Local aColsDef
	Local xValor

	::lLinks := iif( Len(::aCols) == Len(::aLinks) , .T. , .F. )

	::cArqJsonDisp := ::oParent:aDirTemp[1] + ::cId + ".json"
	::cArqJsonDown := ::oParent:aDirTemp[2] + ::cId + ".json"

	//=================================
	// Monta a parte html que vai pro navegador
	//=================================
	cBody += "<div class='card card-fluid'>" + CRLF
	cBody += "  <div class='card-body'>" + CRLF
	cBody += "    <h3 class='card-title'> "+::cTitulo+" </h3>" + CRLF
	cBody += "	  <table id='"+::cId+"' class='table table-striped table-bordered table-hover'>" + CRLF
	cBody += "	    <thead>" + CRLF
	cBody += "        <tr>" + CRLF
	For nY := 1 To Len(::aHead)
		cBody += "          <th> "+Alltrim(::aHead[nY][1])+" </th>" + CRLF
	next
	cBody += "        </tr>" + CRLF
	cBody += "      </thead>" + CRLF
	if ::lFoot
		cBody += "	    <tfoot>" + CRLF
		cBody += "        <tr>" + CRLF
		For nY := 1 To Len(::aHead)
			cBody += "          <th></th>" + CRLF
		next
		cBody += "        </tr>" + CRLF
		cBody += "      </tfoot>" + CRLF
	endif
	cBody += "	  </table><!-- /.table -->" + CRLF
	cBody += "  </div><!-- /.card-body -->" + CRLF
	cBody += "</div><!-- /.card -->" + CRLF


	//=================================
	// Monta a parte javascript que vai pro navegador
	//=================================
	aColsDef := {}
	aJSFoot := {}
	aadd(aJSFoot,"$('#"+::cId+"').DataTable({")
	if ::lSimples
		aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'><'col-sm-12 col-md-6 text-right'>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'><'col-sm-12 col-md-7 d-flex justify-content-end'>>"+chr(34)+",")
		aadd(aJSFoot,"paging: false,")
		aadd(aJSFoot,"searching: false,")
	else
		if ::lLength
			aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'l><'col-sm-12 col-md-6 text-right'B>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 d-flex justify-content-end'p>>"+chr(34)+",")
		else
			aadd(aJSFoot,"dom: "+chr(34)+"<'row'<'col-sm-12 col-md-6'i><'col-sm-12 col-md-6 text-right'B>>\n<'table-responsive'tr>\n<'row align-items-center'<'col-sm-12 col-md-5'><'col-sm-12 col-md-7 d-flex justify-content-end'>>"+chr(34)+",")
			aadd(aJSFoot,"paging: false,")
		endif
		aadd(aJSFoot,"lengthMenu: ["+::cLengthMenu+"],")
	endif

	if ::lOrdering
		aadd(aJSFoot,"ordering: true,")
		aadd(aJSFoot,"order: ["+::cOrdem+"],")
	else
		aadd(aJSFoot,"ordering: false,")
	endif
	
	if ::lButtons
		/*aadd(aJSFoot,	"buttons: [														"+;
						"           {													"+;
						"             text: 'CSV',										"+;
						"             action: function ( e, dt, node, config ) {		"+;
						"               window.open('"+::cArqCSVDown+"');				"+;
						"             }													"+;
						"           },													"+;
						"           'print'												"+;
						"         ],													")*/

		aadd(aJSFoot,	"buttons: [{text: 'CSV',action: function ( e, dt, node, config ) {window.open('"+::cArqCSVDown+"');}},'print'],")
	else
		aadd(aJSFoot,	"buttons: [],")
	endif

	aadd(aJSFoot,"language: {'url': 'vendor/datatables.net-4/pt-br.json'},")
	aadd(aJSFoot,"ajax: {url: '"+::cArqJsonDown+"',type: 'GET',datatype: 'json'},")
	//aadd(aJSFoot,"fixedHeader: true,")
	//aadd(aJSFoot,"responsive: true,")
	aadd(aJSFoot,"columns: [")
	For nY := 1 To Len(::aHead)
		cLinha := iif(nY>1,",","")
		cCpoHed := "FIELD"+StrZero(nY,3)
		Do Case
			Case ::aHead[nY][4]
				cLinha += "{ data: {_:'"+cCpoHed+".display'}}"
				aadd(aColsDef,	"{ targets: "+cValtoChar(nY-1)+",render: function ( data, type, row ) {return '<a href="+chr(34)+"'+row."+cCpoHed+".url+'"+chr(34)+" target="+chr(34)+"'+row."+cCpoHed+".target+'"+chr(34)+">'+data+'</a>';}}")
			Case ::aHead[nY][2] == "D" 
				cLinha += "{ data: {_:'"+cCpoHed+".display',sort: '"+cCpoHed+".timestamp'}}"
				aadd(aColsDef,"{className: 'text-center', targets: "+cValtoChar(nY-1)+"}")
			Case ::aHead[nY][2] == "N"
				cLinha += "{ data: {_:'"+cCpoHed+".display',sort: '"+cCpoHed+".valor'}}"
				aadd(aColsDef,"{className: 'text-right', targets: "+cValtoChar(nY-1)+"}")
			OtherWise
				cLinha += "{ data: '"+cCpoHed+"' }"
		End Case
		aadd(aJSFoot,cLinha)
	next
	aadd(aJSFoot,"],")
	aadd(aJSFoot,"columnDefs: [")
	For nY := 1 To Len(aColsDef)
		aadd(aJSFoot,iif(nY>1,",","")+aColsDef[nY])
	next 
	aadd(aJSFoot,"],")

	if ::lFoot
		aadd(aJSFoot,"footerCallback: function (row, data, start, end, display) {")

		//Essa função intval é para converter string em decimal para que possamos somar os valores
		aadd(aJSFoot,"	var intVal = function (i) {")
		aadd(aJSFoot,"		var res = i;")
		aadd(aJSFoot,"		if (typeof i === 'string'){")
		aadd(aJSFoot,"			res = res.replace('.', '');")
		aadd(aJSFoot,"			res = res.replace(',', '.');")
		aadd(aJSFoot,"			res = res * 1;")
		aadd(aJSFoot,"		}")
		aadd(aJSFoot,"		return res;")
		aadd(aJSFoot,"	};")

		//mas a soma dos itens por coluna
		aadd(aJSFoot,"	var api = this.api();")			
		For nY := 1 To Len(::aHead)
			if ::aHead[nY][2] == "N" .and. ::aHead[nY][5]
				//cVarHed := "cpo"+StrZero(nY,3)
				//aadd(aJSFoot,"	"+cVarHed+" = api.column("+cValToChar(nY-1)+").data().reduce(function (a, b) {return intVal(a) + intVal(b)}, 0);")
				//aadd(aJSFoot,"	$(api.column("+cValToChar(nY-1)+").footer()).html( formatNumber.format("+cVarHed+") );")
				//aadd(aJSFoot,"  console.log("+cVarHed+");")
				xValor := 0
				For nLinha := 1 To Len(::aCols)
					xValor += ::aCols[nLinha][nY]
				Next nLinha
				aadd(aJSFoot,"	$(api.column("+cValToChar(nY-1)+").footer()).html('"+Transform(xValor,"@E 999,999,999,999.999")+"');")
			elseif !Empty(::aFoot[nY])
				aadd(aJSFoot,"	$(api.column("+cValToChar(nY-1)+").footer()).html('"+::aFoot[nY]+"');")
			endif
		next

		aadd(aJSFoot,"}")
		
	endif

	aadd(aJSFoot,"});")

	if ::oParent:lImgPop == .T.
		aadd(aJSFoot,"$('#"+::cId+"').on('init.dt', function () {")
		//aadd(aJSFoot,"  alert( 'Table redraw' );")
		aadd(aJSFoot,"  renderImgProd();")
		aadd(aJSFoot,"} );")
	endif

	::oParent:addJSFoot(aJSFoot)

	
	//=================================
	// Cria o arquivo no servidor que sera baixado pelo javascript
	//=================================
	nHandle := FCreate(::cArqJsonDisp)

	If nHandle == -1
		Self:addBody("<!-- ID: "+::cId+" -->")
		Self:addBody("<!-- Arquivo: "+::cArqJsonDisp+" -->")
		cLog += 'Erro de abertura : FERROR ' + str(ferror(),4) + "<br>" + CRLF			
	else
		
		FWrite(nHandle, '{"data": [')
		
		For nLinha := 1 To Len(::aCols)
			cLinha := ""
			cLinha += iif(nLinha>1,",","")
			cLinha += "{"
			For nCol := 1 To Len(::aHead)

				cCpoHed := "FIELD"+StrZero(nCol,3)
				cCampo  := ::aCols[nLinha][nCol]
				cTipo   := ::aHead[nCol][2]
				lLink	:= .F.

				if ::lLinks
					if ValType(::aLinks[nLinha]) == "A"
						if ValType(::aLinks[nLinha][nCol]) == "A"
							lLink	:= .T.
							clink   := iif(Len(::aLinks)==0,"",::aLinks[nLinha][nCol][1])
							cTarget := iif(Len(::aLinks)==0,"",::aLinks[nLinha][nCol][2])
						elseif ValType(::aLinks[nLinha][nCol]) == "C"
							lLink	:= .T.
							clink   := ::aLinks[nLinha][nCol]
							cTarget := ""
						endif
					endif
				endif

				Do Case

					Case lLink .and. cTipo == "D" .and. Empty(cCampo)
						cCampo := '"'+cCpoHed+'": {"display": "/  /","url": "'+clink+'","target": "'+cTarget+'"}'
					Case lLink .and. cTipo == "D" .and. !Empty(cCampo)
						cCampo := '"'+cCpoHed+'": {"display": "'+dToc(cCampo)+'","url": "'+clink+'","target": "'+cTarget+'"}'
					Case lLink .and. cTipo == "N"
						cCampo := '"'+cCpoHed+'": {"display": "'+Alltrim(Transform(cCampo,::aHead[nCol][3]))+'","url": "'+clink+'","target": "'+cTarget+'"}'
					Case lLink .and. cTipo == "L"
						cCampo := '"'+cCpoHed+'": {"display": "'+iif(cCampo,'"Verdadeiro"','"Falso"')+'","url": "'+clink+'","target": "'+cTarget+'"}'
					Case lLink .and. cTipo == "C"
						cCampo := '"'+cCpoHed+'": {"display": "'+fTxtToHtml(cCampo)+'","url": "'+clink+'","target": "'+cTarget+'"}'


					Case cTipo == "D" .and. Empty(cCampo)
						cCampo := '"'+cCpoHed+'": {"display": "","timestamp": "0"}'
					Case cTipo == "D" .and. !Empty(cCampo)
						cCampo := '"'+cCpoHed+'": {"display": "'+dToc(cCampo)+'","timestamp": "'+FWTimeStamp(4,cCampo,"00:00:00")+'"}'
					Case cTipo == "N"
						xValor := cCampo
						cCampo := '"'+cCpoHed+'": {"display":"'+Alltrim(Transform(xValor,::aHead[nCol][3]))+'","valor": '
						//cCampo += Alltrim(iif( "." $ STR(xValor) , STR(xValor) , STR(xValor)+".0"))
						cCampo += cValToChar(xValor)
						cCampo += "}"
					Case cTipo == "L"
						cCampo := '"'+cCpoHed+'": '+iif(cCampo,'"Verdadeiro"','"Falso"')

					OtherWise
						cCampo := '"'+cCpoHed+'": "'+fTxtToHtml(cCampo)+'"'

				End Case

				cLinha += iif(nCol>1,",","")
				cLinha += cCampo

			next nCol
			cLinha += "}"
			FWrite(nHandle, cLinha + CRLF) // Insere texto no arquivo  
		Next nLinha
		FWrite(nHandle, "]}")
		FClose(nHandle)

	endif

Return(cBody)


METHOD Execute() Class INNWebTable

	Local cBody	:= ""
	Local cLog

	Self:GetCSV()

	if ::lCSV
		
		cBody += "<div class='card card-fluid'>" + CRLF
		cBody += "<div class='card-body'>" + CRLF	
		if !empty(cLog)
			cBody += cLog
		else
			cBody += "<h4>Arquivo gerado com sucesso!</h4>" + CRLF
			cBody += "<p>" + CRLF
			cBody += "ID: "+::cId+"<br>
			cBody += "Arquivo: "+::cArqCSVDisp + CRLF
			cBody += "<br><br />" + CRLF
			cBody += "<button type='button' class='btn btn-primary' onClick="+char(34)+"location.href='"+::cArqCSVDown+"'"+char(34)+">Baixar</button>" + CRLF
			cBody += "</p>" + CRLF		
		endif
		cBody += "</div><!-- /card-body -->" + CRLF
		cBody += "</div><!-- /card card-fluid -->" + CRLF

	else
	
		cBody := Self:GetJson()

	endif

Return(cBody)



// --------------------------------------------------------------------------
METHOD SimpleX3Table(xAlias,nIndex,bRegra,cCampos) Class INNWebTable

	Local aCampo		:= {}
	Local nY
	
	Local aArea		:= GetArea()
	Local aAreaEsp	:= (xAlias)->(GetArea())
	
	Private ALTERA   := .F.
	Private DELETA   := .F.
	Private INCLUI   := .F.
	Private VISUAL   := .T.
	
	Default cCampos := ""
				
	aCampo := {}
	
	DbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(dbSeek(xAlias))
	
	WHILE !SX3->(EOF()) .and. ALLTRIM(SX3->X3_ARQUIVO) == xAlias 

		IF ( X3USO(SX3->X3_USADO) .or.  "_FILIAL" $ Alltrim(SX3->X3_CAMPO) )  .or. Alltrim(SX3->X3_CAMPO) $ cCampos
						
			aadd(aCampo ,{Alltrim(SX3->X3_CAMPO),Alltrim(SX3->X3_TITULO),SX3->X3_TIPO,SX3->X3_PICTURE,SX3->X3_CBOX})
			
		ENDIF
					
		SX3->(dbSkip())
		
	ENDDO 				

	for nY := 1 To len(aCampo)
	
		Self:AddHead({aCampo[nY,2],aCampo[nY,3],aCampo[nY,4]})
	
	next nY
	
	DbSelectArea(xAlias)
	(xAlias)->(DBClearFilter())
	(xAlias)->(DBSetFilter( { || &bRegra } , bRegra ))
	(xAlias)->(dbSetOrder(nIndex)) 
	(xAlias)->(dbGoTop()) 
		
	WHILE !( (xAlias)->(EOF()) )// .and. {|| bRegra }
	
		RegToMemory(xAlias,.F.,.T.)
		aLinha := {}
		
		for nY := 1 To len(aCampo)
		
			IF aCampo[nY,3] ==  "D" // Data
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "N" // Numerico
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "L" // Logico
				aadd(aLinha, M->&(aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "C" .and. Empty(aCampo[nY,5]) // Caracter
				aadd(aLinha, Alltrim(M->&(aCampo[nY,1])) )
				
			ELSEIF aCampo[nY,3] ==  "C" .and. !Empty(aCampo[nY,5]) // Caracter
				aadd(aLinha, Alltrim(M->&(aCampo[nY,1])) + fVOpcBox(M->&(aCampo[nY,1]),"",aCampo[nY,1]) )
				
			ELSEIF aCampo[nY,3] ==  "M" // Memo
				aadd(aLinha, LEFT(Alltrim(M->&(aCampo[nY,1])),100) )
				
			ELSE
			
				aadd(aLinha, "DESPREPARADO PARA O TIPO: " + aCampo[nY,3] )
				
			ENDIF 
		
		next nY
		
		Self:AddCols(aClone(aLinha))
	
		(xAlias)->(dbSkip())
		
	ENDDO 
	
	Self:SetTitle( xAlias + " - " + Alltrim(POSICIONE("SX2",1,xAlias,"X2_NOME")) )
	
	(xAlias)->(DBClearFilter())
	(xAlias)->(RestArea(aAreaEsp))
	RestArea(aArea)
		
Return

METHOD SimpleQueryTable(cTitulo,cQuery,lExcel) Class INNWebTable

	Local cAlias 	:= GetNextAlias()
	Local aStrut 	:= {}
	Local aHead 	:= {}
	Local aLinha	:= {}
	Local nY		:= 0

	Default lExcel := .F.
	Default cTitulo := "Visualização em tela simples"

	Self:SetTitle( cTitulo )

	if lExcel
		Self:SetCSV()
	endif
		
	if select(cAlias) <> 0
		(cAlias)->(dbCloseArea())
	endif 
				 
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAlias,.F.,.T.)

	DbSelectArea(cAlias)
	(cAlias)->(dbGoTop())
	
	aStrut	:= (cAlias)->(dbStruct()) 
	
	for nY := 1 To Len(aStrut)

		Aadd(aHead,{aStrut[nY,1],aStrut[nY,2],"",.T.})
		aStrut[nY,4] := .F.
	
	next
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	for nY := 1 To Len(aHead)
		if SX3->(MSSeek(aHead[nY,1]))
			aHead[nY,1] := SX3->X3_TITULO
			aHead[nY,2] := SX3->X3_TIPO
			aHead[nY,3] := SX3->X3_PICTURE
			if !Empty( X3CBox() )
				aStrut[nY,4] := .T.
			endif
		else
			IF aHead[nY,2] == "N"
				aHead[nY,3] := "@E 99,999,999,999.999"
			ENDIF
		endif

		Self:AddHead({aHead[nY,1],aHead[nY,2],aHead[nY,3],.F.})
	next
			
	WHILE ((cAlias)->(!EOF()))
	
		aLinha := {}	
	
		for nY := 1 To Len(aStrut)
			
			Do Case
				Case aStrut[nY,4]
					Aadd(aLinha,(cAlias)->&(aStrut[nY,1]) + fVOpcBox((cAlias)->&(aStrut[nY,1]),"",aStrut[nY,1]))
				Case aStrut[nY,2] == "C" .and. aHead[nY,2] == "D"
					Aadd(aLinha,sTod((cAlias)->&(aStrut[nY,1])))
				Case aStrut[nY,2] == "C"
					Aadd(aLinha,(cAlias)->&(aStrut[nY,1]))
				Case aStrut[nY,2] == "D"
					Aadd(aLinha,(cAlias)->&(aStrut[nY,1]))
				Case aStrut[nY,2] == "N"
					Aadd(aLinha,(cAlias)->&(aStrut[nY,1]))
				Case aStrut[nY,2] == "L"
					Aadd(aLinha,iif((cAlias)->&(aStrut[nY,1]),"Verdadeiro","Falso"))
				OtherWise
					Aadd(aLinha,"")				
			End Case
					
		next
		
		Self:AddCols(aLinha)

		(cAlias)->(DbSkip())

	ENDDO  
				
	if select(cAlias) <> 0
		(cAlias)->(dbCloseArea())
	endif 

Return

Static Function fTxtToHtml(cTexto)
	cTexto := Alltrim(cTexto)
	cTexto := StrTran(cTexto,chr(129),"")
	cTexto := StrTran(cTexto,chr(141),"")
	cTexto := StrTran(cTexto,chr(143),"")
	cTexto := StrTran(cTexto,chr(144),"")
	cTexto := StrTran(cTexto,chr(157),"")
	cTexto := StrTran(cTexto,chr(9),"")
	cTexto := StrTran(cTexto,";","")	
	cTexto := StrTran(cTexto,'"',"")
	cTexto := StrTran(cTexto,CRLF,"<br/>")
	cTexto := StrTran(cTexto,"\","\\")
	//cTexto := StrTran(cTexto,"ç","&ccedil;")
	//cTexto := StrTran(cTexto,"Ç","&Ccedil;")
	//cTexto := StrToHtml(cTexto)
	//cTexto := OEMToAnsi(cTexto)
	cTexto := EncodeUtf8(cTexto)
Return(cTexto)

Static Function fTxtToCsv(cTexto)
	cTexto := Alltrim(cTexto)
	cTexto := StrTran(cTexto,chr(129),"")
	cTexto := StrTran(cTexto,chr(141),"")
	cTexto := StrTran(cTexto,chr(143),"")
	cTexto := StrTran(cTexto,chr(144),"")
	cTexto := StrTran(cTexto,chr(157),"")
	cTexto := StrTran(cTexto,chr(9),"")
	cTexto := StrTran(cTexto,";","")	
	cTexto := StrTran(cTexto,'"',"")
	cTexto := StrTran(cTexto,CRLF,"")
	cTexto := StrTran(cTexto,"\","\\")
Return(cTexto)

Static Function StrToHtml(cTexto)

	cTexto := StrTran(cTexto,"ç","c")
	cTexto := StrTran(cTexto,"á","a")
	cTexto := StrTran(cTexto,"à","a")
	cTexto := StrTran(cTexto,"â","a")
	cTexto := StrTran(cTexto,"ã","a")
	cTexto := StrTran(cTexto,"ä","a")
	cTexto := StrTran(cTexto,"ó","o")
	cTexto := StrTran(cTexto,"ò","o")
	cTexto := StrTran(cTexto,"ô","o")
	cTexto := StrTran(cTexto,"õ","o")
	cTexto := StrTran(cTexto,"é","e")
	cTexto := StrTran(cTexto,"è","e")
	cTexto := StrTran(cTexto,"ê","e")
	cTexto := StrTran(cTexto,"í","i")
	cTexto := StrTran(cTexto,"ì","i")
	cTexto := StrTran(cTexto,"î","i")
	cTexto := StrTran(cTexto,"ú","u")
	cTexto := StrTran(cTexto,"ù","u")
	cTexto := StrTran(cTexto,"û","u")

	cTexto := StrTran(cTexto,"Ç","C")
	cTexto := StrTran(cTexto,"Á","A")
	cTexto := StrTran(cTexto,"À","A")
	cTexto := StrTran(cTexto,"Â","A")
	cTexto := StrTran(cTexto,"Ã","A")
	cTexto := StrTran(cTexto,"Ä","A")
	cTexto := StrTran(cTexto,"Ó","O")
	cTexto := StrTran(cTexto,"Ò","O")
	cTexto := StrTran(cTexto,"Ô","O")
	cTexto := StrTran(cTexto,"Õ","O")
	cTexto := StrTran(cTexto,"É","E")
	cTexto := StrTran(cTexto,"È","E")
	cTexto := StrTran(cTexto,"Ê","E")
	cTexto := StrTran(cTexto,"Í","I")
	cTexto := StrTran(cTexto,"Ì","I")
	cTexto := StrTran(cTexto,"Î","I")
	cTexto := StrTran(cTexto,"Ú","U")
	cTexto := StrTran(cTexto,"Ù","U")
	cTexto := StrTran(cTexto,"Û","U")
	
	cTexto := StrTran(cTexto,"°","&deg;"   )
	cTexto := StrTran(cTexto,"º","&ordm;"  )
	cTexto := StrTran(cTexto,"–","&ndash;" )
	                                        
	cTexto := StrTran(cTexto,"‡","&Dagger;")
	cTexto := StrTran(cTexto,"’","&rsquo;" )	
	cTexto := StrTran(cTexto,"£","&#163"   )	
	
Return(cTexto)
