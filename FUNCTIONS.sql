-- função para formatação do CPF
-- chamada da função
-- ([sankhya].[formatarCPF](CPF)) [CPF]

USE SANKHYA_PROD	
GO				
CREATE FUNCTION FORMATARCPF(@CPF CHAR(11))
RETURNS CHAR(14)		
AS
BEGIN			 
DECLARE @RETORNO VARCHAR(14)			 
SET @RETORNO = SUBSTRING(@CPF,1,3) + '.' + SUBSTRING(@CPF,4,3) + '.' + SUBSTRING(@CPF,7,3) + '-' + SUBSTRING(@CPF,10,2) 			 
RETURN @RETORNO		
END

-- função para formatação do CNPJ
-- chamada da função
-- ([sankhya].[formatarCNPJ](CNPJ))[CNPJ]

USE SANKHYA_PROD	
GO				
CREATE FUNCTION FORMATARCNPJ(@CNPJ CHAR(14))
RETURNS CHAR(18)
AS
BEGIN 
DECLARE @RETORNO VARCHAR(18)
SET @RETORNO = SUBSTRING(@CNPJ ,1,2) + '.' + SUBSTRING(@CNPJ ,3,3) + '.' + SUBSTRING(@CNPJ ,6,3) + '/' + SUBSTRING(@CNPJ ,9,4) + '-' + SUBSTRING(@CNPJ ,13,2)
RETURN @RETORNO
END

-- função para formatação do CEP
-- chamada da função
-- ([sankhya].[formatarCEP](CEP)) [CEP]

USE SANKHYA_PROD	
GO				
CREATE FUNCTION FORMATARCEP(@CEP CHAR(8))
RETURNS CHAR(10)
AS
BEGIN 
DECLARE @RETORNO VARCHAR(10)
SET @RETORNO = SUBSTRING(@CEP, 1, 2) + '.' + SUBSTRING(@CEP, 3, 3) + '-' + SUBSTRING(@CEP, 6, LEN(@CEP))
RETURN @RETORNO
END

-- função para formatação do PIS
-- chamada da função
-- ([sankhya].[formatarPIS](PIS)) [PIS]
                                                                                                  
USE SANKHYA_PROD	
GO				
CREATE FUNCTION FORMATARPIS(@PIS CHAR(11))
RETURNS CHAR(14)		
AS
BEGIN			 
DECLARE @RETORNO VARCHAR(14)			 
SET @RETORNO = SUBSTRING(@PIS,1,3) + '.' + SUBSTRING(@PIS,4,5) + '.' + SUBSTRING(@PIS,7,2) + '-' + SUBSTRING(@PIS,10,2) 			 
RETURN @RETORNO		
END

-- função para formatação REAIS
-- chamada da função
-- ([sankhya].[FORMATAVALOR](FUN.SALBASE,'.',',')) [SALBASE]

USE SANKHYA_PROD	
GO				
CREATE FUNCTION FORMATAVALOR(@VALOR NUMERIC(18,4),@SEPMILHAR CHAR(1),@SEPDECIMAL CHAR(1))
RETURNS VARCHAR(50) AS
BEGIN
DECLARE @INTEIRO INT,
        @TEXTO VARCHAR(50),
        @VALORDECIMAL VARCHAR(04)
    SET @TEXTO = RTRIM(CAST(@VALOR AS VARCHAR(50)))
    SET @INTEIRO = CAST(@VALOR AS INTEGER)
    SET @VALORDECIMAL = SUBSTRING(@TEXTO,LEN(@TEXTO)-3,2)
     IF LEN(@INTEIRO) = 1
    SET @TEXTO = CAST(@INTEIRO AS VARCHAR(10)) + REPLACE(@SEPMILHAR, '.',',') + @VALORDECIMAL
     IF LEN(@INTEIRO) = 2
    SET @TEXTO = CAST(@INTEIRO AS VARCHAR(10)) + REPLACE(@SEPMILHAR, '.',',') + @VALORDECIMAL
     IF LEN(@INTEIRO) = 3
    SET @TEXTO = CAST(@INTEIRO AS VARCHAR(10)) + REPLACE(@SEPMILHAR, '.',',') + @VALORDECIMAL
     IF LEN(@INTEIRO) = 4
    SET @TEXTO = SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),1,1) + @SEPMILHAR + 
                 SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),2,3) + @SEPDECIMAL + @VALORDECIMAL
     IF LEN(@INTEIRO) = 5
    SET @TEXTO = SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),1,2) + @SEPMILHAR + 
                 SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),3,5) + @SEPDECIMAL + @VALORDECIMAL
     IF LEN(@INTEIRO) = 6
    SET @TEXTO = SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),1,3) + @SEPMILHAR + 
                 SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),4,7) + @SEPDECIMAL + @VALORDECIMAL 
     IF LEN(@INTEIRO) = 7
    SET @TEXTO = SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),1,1) + @SEPMILHAR + SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),2,3) + @SEPMILHAR + SUBSTRING(CAST(@INTEIRO AS VARCHAR(10)),5,7) + @SEPDECIMAL + @VALORDECIMAL
RETURN @TEXTO
END