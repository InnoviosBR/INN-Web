#include "protheus.ch"
#Include "tbiconn.ch"
#Include "topconn.ch"
#Include "APWEBEX.CH"

User Function INNConfig(aParm)

	Local aDirTemp 		:= {}
	Local cCodGgle		:= ""
	
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR01", "", GetAdv97() ) ))//Caminho temporaio onde o arquivo foi criado
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR02", "", GetAdv97() ) ))//Caminho temporario onde o arquivo foi criado para montar a URL de Download
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR03", "", GetAdv97() ) ))//Caminho de upload
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR04", "", GetAdv97() ) ))//caminho do repositorio de arquivos
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR05", "", GetAdv97() ) ))//Caminho completo do repositorio de arquivos (para MD5)
	aadd(aDirTemp,Alltrim( GetPvProfString("INNWEB", "INNWEBDIR06", "", GetAdv97() ) ))//Caminho do repositorio para montar a URL de Download	

Return({aDirTemp,cCodGgle})
