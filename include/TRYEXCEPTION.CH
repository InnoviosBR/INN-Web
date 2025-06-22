#IFNDEF _TRYEXCEPTION_CH
	
	#DEFINE _TRYEXCEPTION_CH

	/*/
		Autor:		Marinaldo de Jesus
		Data:		07/10/2009
		Descricao:	Comandos para Simular TRY & CATCH EXCEPTION em ADVPL

	/*/
	#DEFINE TRY_ELEMENTS			3

	#DEFINE TRY_BLOCK				1
	#DEFINE TRY_INDEX				2
	#DEFINE TRY_OBJERROR			3

	#XTRANSLATE	TRY EXCEPTION	=> TRYEXCEPTION
	#XTRANSLATE	CATCH EXCEPTION	=> CATCHEXCEPTION
	#XTRANSLATE	END TRY			=> ENDEXCEPTION
	#XTRANSLATE	ENDTRY			=> ENDEXCEPTION
	#XTRANSLATE	END EXCEPTION	=> ENDEXCEPTION

	#XCOMMAND TRYEXCEPTION  	=> ;
		IF( !( Type( "aTryException" ) == "A" ) , _SetOwnerPrvt( "aTryException" , \{\} ) , NIL ) ;;
		IF( !( Type( "nTryException" ) == "N" ) , _SetOwnerPrvt( "nTryException" , 0  ) , NIL ) ;;
		aAdd( aTryException , Array(TRY_ELEMENTS) ) ;;
		++nTryException ;;
		aTryException\[nTryException\]\[TRY_BLOCK\]	:= ErrorBlock( \{ \|oError\| BREAK( @oError ) \} ) ;;
		aTryException\[nTryException\]\[TRY_INDEX\]	:= nTryException ;;
		ErrorBlock( \{ \|oError\| aTryException\[nTryException\]\[TRY_OBJERROR\] := oError , BREAK( @oError ) \} ) ;;
		BEGIN SEQUENCE ;;
	
	#XCOMMAND TRYEXCEPTION USING <bError> [PARAMETERS <aParameters>] => ;
		IF( !( Type( "aTryException" ) == "A" ) , _SetOwnerPrvt( "aTryException" , \{\} ) , NIL ) ;;
		IF( !( Type( "nTryException" ) == "N" ) , _SetOwnerPrvt( "nTryException" , 0 ) , NIL ) ;;
		aAdd( aTryException , Array( TRY_ELEMENTS ) ) ;;
		++nTryException ;;
		aTryException\[nTryException\]\[TRY_BLOCK\]	:= ErrorBlock( \{ \|oError\| BREAK( @oError ) \} ) ;;
		aTryException\[nTryException\]\[TRY_INDEX\]	:= nTryException ;;
		ErrorBlock( \{ \|oError\| aTryException\[nTryException\]\[TRY_OBJERROR\] := oError , Eval( <bError> , @oError , [@<aParameters>] ) \} ) ;;
		BEGIN SEQUENCE ;;

	#XCOMMAND CATCHEXCEPTION	=>  RECOVER ;;
	
	#XCOMMAND CATCHEXCEPTION USING <oException> => ;
		RECOVER ;;
		<oException>	:= aTryException\[nTryException\]\[TRY_OBJERROR\] ;;
	
	#XCOMMAND ENDEXCEPTION		=> ;
		END SEQUENCE ;;
		IF ( ( Type( "aTryException" ) == "A" ) .and. ( Type( "nTryException" ) == "N" ) ) ;;
			IF ( ValType(aTryException\[nTryException\]\[TRY_BLOCK\]) == "B" ) ;;
				ErrorBlock( aTryException\[nTryException\]\[TRY_BLOCK\] ) ;;
				aDel( aTryException , nTryException ) ;;
				aSize( aTryException , --nTryException ) ;;
			ENDIF ;;
		ENDIF ;;
		
#ENDIF
