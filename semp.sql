-- SEMP VENDAS
SELECT
EMP.CGC [CNPJ LOJA]
,FUN.CPF
,ITE.CODPROD [CÓDIGO PRODUTO]
,PRO.DESCRPROD [DESCRIÇÃO PRODUTO]
,ITE.QTDNEG [QUANTIDADE]
,CAB.NUMNOTA [NÚMERO NOTA FISCAL]
,ITE.CODCFO [CFOP]
,CAB.DTNEG [DATA VENDA]

FROM
TGFCAB CAB
,TGFITE ITE
,TGFPRO PRO
,TSIEMP EMP
,TGFVEN VEN
,TFPFUN FUN

WHERE
CAB.NUNOTA = ITE.NUNOTA
AND ITE.CODPROD = PRO.CODPROD
AND CAB.CODEMP = EMP.CODEMP
AND ITE.CODVEND = VEN.CODVEND
AND VEN.CODFUNC = FUN.CODFUNC
AND VEN.CODEMP = FUN.CODEMP
AND CAB.CODTIPOPER IN (1112, 1101)
AND YEAR(DTNEG) = YEAR(GETDATE())
AND MONTH(DTNEG) = MONTH(GETDATE())-1
AND PRO.DESCRPROD LIKE '%TV SEMP%'

ORDER BY
CAB.DTNEG

-- SEMP PRODUTOS

SELECT DISTINCT
ITE.CODPROD [CÓDIGO REVENDA]
,PRO.DESCRPROD [DESCRIÇÃO PRODUTO]

FROM
TGFCAB CAB
,TGFITE ITE
,TGFPRO PRO
,TSIEMP EMP
,TGFVEN VEN
,TFPFUN FUN

WHERE
CAB.NUNOTA = ITE.NUNOTA
AND ITE.CODPROD = PRO.CODPROD
AND CAB.CODEMP = EMP.CODEMP
AND ITE.CODVEND = VEN.CODVEND
AND VEN.CODFUNC = FUN.CODFUNC
AND VEN.CODEMP = FUN.CODEMP
AND CAB.CODTIPOPER IN (1112, 1101)
AND YEAR(DTNEG) = YEAR(GETDATE())
AND MONTH(DTNEG) = MONTH(GETDATE())-1
AND PRO.DESCRPROD LIKE '%TV SEMP%'

-- SEMP CADASTRO DE FUNCIONARIOS

SELECT DISTINCT
EMP.CODEMP [NÚMERO FILIAL]
,FUN.NOMEFUNC [NOME] 
,FUN.CPF
,VEN.TIPVEND
,EMP.CGC [CNPJ LOJA]
,EMP.RAZAOSOCIAL


FROM
TGFCAB CAB
,TGFITE ITE
,TGFPRO PRO
,TSIEMP EMP
,TGFVEN VEN
,TFPFUN FUN

WHERE
CAB.NUNOTA = ITE.NUNOTA
AND ITE.CODPROD = PRO.CODPROD
AND CAB.CODEMP = EMP.CODEMP
AND ITE.CODVEND = VEN.CODVEND
AND VEN.CODFUNC = FUN.CODFUNC
AND VEN.CODEMP = FUN.CODEMP
AND CAB.CODTIPOPER IN (1112, 1101)
AND YEAR(DTNEG) = YEAR(GETDATE())
AND MONTH(DTNEG) = MONTH(GETDATE())-1
AND PRO.DESCRPROD LIKE '%TV SEMP%'

-- SEMP LOJAS

SELECT 
EMP.CGC
,EMP.RAZAOSOCIAL
,RTRIM(UPPER(RUA.TIPO+' '+RUA.NOMEEND)) [RUA]
,BAI.NOMEBAI
,CID.NOMECID
,'PA' AS [UF]
,EMP.CEP
,'91' AS [DDD]
,EMP.TELEFONE

FROM 
TSIEMP EMP
,TSIEND RUA
,TSIBAI BAI
,TSICID CID

WHERE
EMP.CODEND = RUA.CODEND
AND EMP.CODBAI = BAI.CODBAI
AND EMP.CODCID = CID.CODCID
AND CODEMP <> 3
