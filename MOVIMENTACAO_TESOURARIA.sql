DECLARE @DT_INICIO DATE
SET @DT_INICIO = '01/06/2018'
DECLARE @DT_FIM DATE
SET @DT_FIM =  '14/06/2018'
DECLARE @EMP INT
SET @EMP = 1

-- ENTRADAS
SELECT
  CAB.DTNEG
  ,CASE
  WHEN CODTIPTIT=1 THEN 'DINHEIRO'
  WHEN CODTIPTIT=6 THEN 'CARNE'
  END AS [TIPO_TITULO]
,SUM(ISNULL(FIN.VLRDESDOB ,0))
     +ISNULL( (SELECT 
  SUM(VLRLANC) [VLRLANC]
  FROM 
  TGFMBC
  WHERE
  CODTIPOPER = 1780
  AND DTLANC = CAB.DTNEG
  AND CODCTABCOINT = 8
  GROUP BY
  CONVERT(datetime, CONVERT(DATE,  DTLANC, 101))
  ) ,0) AS [ENTRADA]

  ,NULL AS [DESCRNAT]
  ,NULL AS [SAIDA]

FROM
  TGFCAB CAB
  ,TGFFIN FIN
  ,TGFNAT NAT

WHERE
  CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODTIPOPER IN (1112,1101)
  AND CAB.NUMNOTA = FIN.NUMNOTA
  AND CAB.CODNAT = NAT.CODNAT
  -- Atenção aqui, para não duplicar as linhas foi igualada as datas de negociação da TGFCAB e data da baixa e movimentação
  -- da TGFFIN, sem isso as informações vem repetidas.
  AND CAB.DTNEG = FIN.DHMOV
  AND CAB.DTNEG = FIN.DHBAIXA
  AND FIN.CODTIPTIT IN (1,6)
  AND CAB.CODEMP=@EMP

GROUP BY
   CAB.DTNEG
  ,FIN.CODTIPTIT

UNION

-- SAIDAS
SELECT 
  CAB.DTNEG
  ,NULL AS [TIPO_TITULO]
  ,NULL AS [ENTRADA]
  ,NAT.DESCRNAT
  ,SUM(CAB.VLRNOTA) AS SAIDA

FROM
  TGFCAB CAB
  ,TGFNAT NAT

WHERE
  CAB.CODTIPOPER = 1304
  AND CAB.CODNAT = NAT.CODNAT
  AND CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODEMP=@EMP

GROUP BY
  CAB.DTNEG
  ,NAT.DESCRNAT


ORDER BY
  CAB.DTNEG
