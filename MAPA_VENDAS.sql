DECLARE @DTINI DATE
DECLARE @DTFIM DATE
SET @DTINI = '01/01/2019'
SET @DTFIM = GETDATE()
SELECT
---------- DESCRIÇÃO COMPLETA DO PRODUTO
CONVERT(varchar(10), PRO.CODPROD) +' - '+ 
CONVERT(varchar(100), PRO.AD_MODELOREF) + ' - ' + 
CONVERT(varchar(250), PRO.DESCRPROD) AS [ARTIGO]
,GRU.DESCRGRUPOPROD
---------- ESTOQUE EXISTENTE ----------
,ISNULL(
(SELECT SUM(EST.ESTOQUE) 
FROM TGFEST EST
WHERE EST.CODPROD = PRO.CODPROD)
,0) [ESTOQUE]
---------- PREÇO DE TABELA ----------
,ISNULL(
(SELECT
(SELECT ME.VLRVENDA
FROM TGFNTA NTA, TGFTAB MT, TGFEXC ME
WHERE NTA.CODTAB = MT.CODTAB
AND MT.NUTAB = ME.NUTAB
AND NTA.CODTAB =  0
AND ME.CODPROD = PRO_INT.CODPROD
AND MT.DTVIGOR = (SELECT MAX(MT.DTVIGOR)
FROM TGFNTA NTA, TGFTAB MT, TGFEXC ME
WHERE NTA.CODTAB = MT.CODTAB
AND MT.NUTAB = ME.NUTAB
AND NTA.CODTAB = 0
AND ME.CODPROD = PRO_INT.CODPROD)) AS PREÇO
FROM TGFPRO PRO_INT
WHERE PRO_INT.CODPROD = PRO.CODPROD)
,0) [VLR_TABELA]
---------- DATA DA ULTIMA COMPRA ----------
,ISNULL(
(SELECT DTNEG FROM 
(SELECT ROW_NUMBER() OVER
(ORDER BY CAB.DTNEG DESC) AS ROWNUM, CAB.DTNEG
FROM TGFCAB CAB, TGFITE ITE
WHERE CAB.NUNOTA=ITE.NUNOTA
AND CODPROD=PRO.CODPROD 
AND CAB.CODTIPOPER IN (1413, 1403, 1412, 1402, 1417, 1409, 1418, 1434
, 1437, 1438, 1441, 1452, 1454, 1455, 1511, 1419)) AS DT_ULT_COMPRA
WHERE ROWNUM=1)
,0) [DT_COMPRA]
---------- VALOR DA ULTIMA COMPRA ----------
,ISNULL(
(SELECT VLRUNIT FROM 
(SELECT ROW_NUMBER() OVER
(ORDER BY CAB.DTNEG DESC) AS ROWNUM, ITE.VLRUNIT
FROM TGFCAB CAB, TGFITE ITE
WHERE CAB.NUNOTA=ITE.NUNOTA
AND CODPROD=PRO.CODPROD 
AND CAB.CODTIPOPER IN (1413, 1403, 1412, 1402, 1417, 1409, 1418, 1434
, 1437, 1438, 1441, 1452, 1454, 1455, 1511, 1419)) AS VLR_ULT_COMPRA
WHERE ROWNUM=1)
,0) [VLR_COMPRA]
---------- ALIQUOTA IPI DA ULTIMA COMPRA ----------
,ISNULL(
(SELECT ALIQIPI FROM 
(SELECT ROW_NUMBER() OVER(ORDER BY CAB.DTNEG DESC) AS ROWNUM, ITE.ALIQIPI
FROM TGFCAB CAB, TGFITE ITE
WHERE CAB.NUNOTA=ITE.NUNOTA
AND CODPROD=PRO.CODPROD 
AND CAB.CODTIPOPER IN (1413, 1403, 1412, 1402, 1417, 1409, 1418, 1434
, 1437, 1438, 1441, 1452, 1454, 1455, 1511, 1419)) AS ALQ_ULT_COMPRA
WHERE ROWNUM=1)
,0) [ALI_IPI]
---------- VALOR IPI DA ULTIMA COMPRA ----------
,ISNULL(
(SELECT IPI FROM 
(SELECT ROW_NUMBER() OVER(ORDER BY CAB.DTNEG DESC) AS ROWNUM,
((ITE.VLRUNIT*ITE.ALIQIPI)/100) AS IPI
FROM TGFCAB CAB, TGFITE ITE
WHERE CAB.NUNOTA=ITE.NUNOTA
AND CODPROD=PRO.CODPROD 
AND CAB.CODTIPOPER IN (1413, 1403, 1412, 1402, 1417, 1409, 1418, 1434
, 1437, 1438, 1441, 1452, 1454, 1455, 1511, 1419)) AS IPI_ULT_COMPRA
WHERE ROWNUM=1)
,0) [VLR_IPI]
---------- QTD VENDIDO NO PERÍODO ----------
,ISNULL(
(SELECT SUM(ITE.QTDNEG) AS VLR_VENDA
FROM TGFCAB CAB ,TGFITE ITE
WHERE CAB.NUNOTA = ITE.NUNOTA
AND CAB.CODTIPOPER IN (1101,1112)
AND ITE.CODPROD = PRO.CODPROD
AND CAB.DTNEG >= @DTINI
AND CAB.DTNEG <= @DTFIM)
,0) [QTD_VENDA]
---------- VALOR VENDIDO NO PERÍODO ----------
,ISNULL(
(SELECT SUM(ITE.VLRUNIT*ITE.QTDNEG) AS VLR_VENDA
FROM TGFCAB CAB, TGFITE ITE
WHERE CAB.NUNOTA = ITE.NUNOTA
AND CAB.CODTIPOPER IN (1101,1112)
AND ITE.CODPROD = PRO.CODPROD
AND CAB.DTNEG >= @DTINI
AND CAB.DTNEG <= @DTFIM)
,0) [VLR_VENDA]
---------- WHERE CLAUSE ----------
FROM TGFPRO PRO,TGFGRU GRU
WHERE PRO.CODGRUPOPROD = GRU.CODGRUPOPROD
AND PRO.MARCA LIKE '%FABONE%'
AND PRO.CODGRUPOPROD NOT IN (1990000)
ORDER BY
GRU.DESCRGRUPOPROD
,PRO.DESCRPROD 
