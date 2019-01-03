DECLARE @MES AS INT = MONTH(GETDATE())
DECLARE @ANO AS INT = YEAR(GETDATE())
DECLARE @DIAS_UTEIS INT = 26
DECLARE @META_LOJA INT = xxxxx
DECLARE @META_VENDEDOR INT = xxxxx
DECLARE @SUPER_META_VENDEDOR INT = xxxxx
DECLARE @META_DIARIA_LOJA INT = @META_LOJA / @DIAS_UTEIS
DECLARE @META_DIARIA_VENDEDOR INT = @META_VENDEDOR / @DIAS_UTEIS

-- ESSA CTE CALCULA TODOS OS DIAS DO MES CORRENTE E FORMA UMA LISTA
;WITH 
CTE_DATA (DATAS_MES) AS (
SELECT
CAST(CAST(@ANO AS VARCHAR) + '-' + CAST(@MES AS VARCHAR) + '-01' AS DATETIME) + NUMBER AS [DATA]
FROM MASTER..SPT_VALUES
WHERE TYPE = 'P'
AND
(CAST(CAST(@ANO AS VARCHAR) + '-' + CAST(@MES AS VARCHAR) + '-01' AS DATETIME) + NUMBER ) <
DATEADD(MM,1,CAST(CAST(@ANO AS VARCHAR) + '-' + CAST(@MES AS VARCHAR) + '-01' AS DATETIME))),

-- ESSA CTE CRIA UMA TABELA COM OS FERIADOS DO ANO CORRENTE
CTE_FERIADO (FERIADO) AS (
SELECT 
DISTINCT CONVERT(DATE , CAST(YEAR(GETDATE()) AS VARCHAR)  + '-' + CAST(MONTH(DTFERIADO) AS VARCHAR) + '-' + CAST(DAY(DTFERIADO) AS VARCHAR)) 
FROM TSIFER )

-- COMEÇO DO RELÁTÓRIO
SELECT 
CONVERT(DATE, CTE1.DATAS_MES) AS DATAS_MES
,DAY(CTE1.DATAS_MES) AS DIA
,DATENAME(DW,CTE1.DATAS_MES) [DIA_SEMANA]
,
CASE 
WHEN DATEPART(DW,CTE1.DATAS_MES) <> 1 THEN
	(SELECT SUM(@META_DIARIA_VENDEDOR) 
	 FROM 
	 CTE_DATA AS CTE2 
	 WHERE CTE2.DATAS_MES <= CTE1.DATAS_MES
	 AND DATEPART(DW,CTE2.DATAS_MES) <> 1
	 AND CTE2.DATAS_MES NOT IN ('01/01/2019')
	 ) 
ELSE NULL
END [DIARIA_VENDEDOR]
,
CASE 
WHEN DATEPART(DW,CTE1.DATAS_MES) <> 1 THEN
	(SELECT SUM(@META_DIARIA_LOJA) 
	 FROM 
	 CTE_DATA AS CTE2 
	 WHERE CTE2.DATAS_MES <= CTE1.DATAS_MES
	 AND DATEPART(DW,CTE2.DATAS_MES) <> 1
	 AND CTE2.DATAS_MES NOT IN ('01/01/2019')
	 )
WHEN DATEPART(DW,CTE1.DATAS_MES) = 1 THEN NULL
END [DIARIA_LOJA]
FROM CTE_DATA AS CTE1

