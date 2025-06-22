#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"
#INCLUDE "INNLIB.CH"
#include "parmtype.ch"

CLASS INNWebAnexo FROM ClsINNWeb
	
	data oParent AS OBJECT READONLY
	data cTipo
	data cChave

	METHOD New() Constructor
	METHOD Init()
	METHOD SetChave(  )
	METHOD SetTipo(  )
	METHOD GetArquivos(  )
	METHOD Upload(  )
	METHOD Execute(  )

ENDCLASS

METHOD New( xParent ) CLASS INNWebAnexo
	
    //PARAMTYPE 0 VAR oParent AS OBJECT CLASS INNWebAnexo,ClsINNWeb

    ::Init()
	::oParent := xParent
	::oParent:AddBody(Self)

	::cTipo		:= ""
	::cChave 	:= ""
	
Return Self

METHOD Init() CLASS INNWebAnexo



Return

METHOD Execute() Class INNWebAnexo

	Local cBody := ""

Return(cBody)

METHOD GetArquivos(cTipo,cDocumento,lIncorpora) Class INNWebAnexo


	Local aArqs			:= {}
	Local oINNWebTable
	
	Default cTipo       := ::cTipo
	Default cDocumento  := ::cChave 
	Default lIncorpora  := .T.
	
	if lIncorpora
		oINNWebTable := INNWebTable():New( oINNWeb )
		oINNWebTable:SetTitle("Arquivos anexados a " + Alltrim(Upper(cDocumento)))
		oINNWebTable:AddHead({""			,"C","",.T.})
		oINNWebTable:AddHead({"Nome"		,"C","",.T.})
		oINNWebTable:AddHead({"Data"		,"D",""})
		oINNWebTable:AddHead({"Hora"		,"C",""})
		oINNWebTable:AddHead({"Usuario"		,"C",""})
		oINNWebTable:AddHead({"Tamanho (KB)","N","@E 99,999,999,999.99"})
	endif
	
	cDocumento := Alltrim(UPPER(cDocumento))
	
	IF Len(cDocumento) > 34
		cDocumento := MD5(cDocumento,2)
	ENDIF
	
	if select("TMPINN003") <> 0
		TMPINN003->(dbCloseArea())
	endif 
		
	cQuery := " SELECT * FROM INN003 WHERE TIPO = '"+cTipo+"' AND UPPER(LTRIM(RTRIM(DOC))) = '"+Alltrim(Upper(cDocumento))+"' AND D_E_L_E_T_ = '' "
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"TMPINN003",.F.,.T.)
	
	DbSelectArea("TMPINN003")
	TMPINN003->(dbGoTop())

	WHILE (TMPINN003->(!EOF()))
	
		if lIncorpora
					
			oINNWebTable:AddCols({	Self:fIcon(TMPINN003->BMPEXT),;
									TMPINN003->NOMEORIG,;
									sTod(TMPINN003->DTINCLU),;
									TMPINN003->HRINCLU,;
									TMPINN003->USINCLU,;
									TMPINN003->BMPSIZE/1024})

			oINNWebTable:SetLink(  , 1 , Alltrim(TMPINN003->BMPURL) )
			oINNWebTable:SetLink(  , 2 , Alltrim(TMPINN003->BMPURL) )

		else

			aadd(aArqs,{TMPINN003->BMPURL,TMPINN003->BMPID,Alltrim(TMPINN003->NOMEORIG)})

		endif
		
		TMPINN003->(dbSkip())
		
	Enddo  
	
	if select("TMPINN003") <> 0
		TMPINN003->(dbCloseArea())
	endif

Return(aArqs)

METHOD SetChave( xChave ) Class INNWebAnexo
	::cChave := xChave
Return

METHOD SetTipo( xTipo ) Class INNWebAnexo
	::cTipo := xTipo
Return

METHOD Upload( lIncorpora ) Class INNWebAnexo

	Local cBotao	:= ""
	Local cModal	:= ""
	Local aLoad 	:= {}
	
	Default lIncorpora := .T.

	cBotao := "    <div class='btn-group'>" + CRLF
	cBotao += "      <button class='btn btn-primary btn-lg' data-toggle='modal' data-target='#modalAnexaArquivo' data-backdrop='static'>Anexar arquivo</button>" + CRLF
	cBotao += "    </div>" + CRLF
	if lIncorpora
		::oParent:addCard(cBotao)
	endif

	cModal := "<div class='modal fade' id='modalAnexaArquivo' tabindex='-1' role='dialog' aria-labelledby='modalAnexaArquivoLabel' aria-hidden='true'>" + CRLF
	cModal += "  <div class='modal-dialog modal-dialog-centered' role='document'>" + CRLF
	cModal += "    <div class='modal-content'>" + CRLF
	cModal += "      <div class='modal-header'>" + CRLF
	cModal += "        <h5 class='modal-title'>Anexar um novo arquivo ao documento</h5>" + CRLF
	cModal += "      </div>" + CRLF
	cModal += "      <div class='modal-body'>" + CRLF
	cModal += "        <input name='Tipo' type='hidden' id='Tipo' value='"+::cTipo+"'>"
	cModal += "        <input name='Documento' type='hidden' id='Documento' value='"+::cChave+"'>"
	cModal += "        <input type='file' name='fileToUpload' id='fileToUpload'>"
	cModal += "      </div>" + CRLF
	cModal += "      <div class='modal-footer'>" + CRLF
	cModal += "        <button type='button' class='btn btn-default' name='cancelar' data-dismiss='modal'>Cancelar</button>" + CRLF
	cModal += "        <button type='button' class='btn btn-primary' name='enviar' id='enviar'>Enviar</button>" + CRLF
	cModal += "      </div>" + CRLF
	cModal += "    </div><!-- /.modal-content -->" + CRLF
	cModal += "  </div><!-- /.modal-dialog -->" + CRLF
	cModal += "</div><!-- /.modal -->" + CRLF
	if lIncorpora
		::oParent:AddBody(cModal)
	endif
	
	aLoad := {}
	
	aadd(aLoad,"$( '#enviar' ).click(function() { ")
	aadd(aLoad,"	frmEnviaAnexo();")
	aadd(aLoad,"})")
		
	aadd(aLoad,"function frmEnviaAnexo(){")		
	aadd(aLoad,"	$('#enviar').prop('disabled', true); ")
	aadd(aLoad,"	$('#cancelar').prop('disabled', true); ")
	//aadd(aLoad,"	$('#modal-body').loading(); ")
	aadd(aLoad,"	var dados; ")
	aadd(aLoad,"	dados = new FormData(); ")
	aadd(aLoad,"	dados.append( 'file', $( '#fileToUpload' )[0].files[0] );")
	aadd(aLoad,"	dados.append( 'Tipo', $( '#Tipo' ).val() );")
	aadd(aLoad,"	dados.append( 'Documento', $( '#Documento' ).val() );")		
	aadd(aLoad,"	$.ajax({")
	aadd(aLoad,"		url: '?x=wExplorer&form=update',")
	aadd(aLoad,"		type: 'POST',")
	aadd(aLoad,"		datatype: 'json',")
	aadd(aLoad,"		processData: false,")
  	aadd(aLoad,"		contentType: false,")
	aadd(aLoad,"		data: dados,")  
	//aadd(aLoad,"		timeout: 10000,")
	aadd(aLoad,"		success: function(data){")
	aadd(aLoad,"			data = JSON.parse(data);")	
	aadd(aLoad,"			if (data['STATUS']=='200') {")	
	aadd(aLoad,"		   		location.reload();")
	aadd(aLoad,"			}else{")
	aadd(aLoad,"		 		alert( data['MENSAGEM'] );")
	aadd(aLoad,"		 		$('#enviar').prop('disabled', false); ")
	aadd(aLoad,"			}")
	aadd(aLoad,"		},")
	aadd(aLoad,"		error:function(response){")
	aadd(aLoad,"			alert( 'Erro da requisicao ajax' );")
	aadd(aLoad,"			console.log(response);")
	aadd(aLoad,"		}")   
	aadd(aLoad,"	});")
	aadd(aLoad,"}")
	if lIncorpora
		::oParent:AddLoad(aLoad)
	endif

Return({ cBotao , cModal , aLoad })
