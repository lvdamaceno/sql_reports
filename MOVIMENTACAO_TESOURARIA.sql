-- Variáveis para o período (mês / ano) e código da empresa
DECLARE @DT_INICIO DATE
SET @DT_INICIO = '01/05/2018'
DECLARE @DT_FIM DATE
SET @DT_FIM =  '11/06/2018'
DECLARE @EMP INT
SET @EMP = 1

SELECT
  ENTRADA.DTNEG
  ,ENTRADA.DESCRNAT [NATUREZA]
  ,ENTRADA.RECEITA_DE_VENDA
  ,ENTRADA.RECEITA_DE_RECEBIMENTO
  ,ENTRADA.MOVIMENTO_BANCARIO
  ,ENTRADA.ENTRADA
  ,SAIDA.SAIDA
  ,(ENTRADA.ENTRADA - SAIDA.SAIDA) AS SALDO_DO_DIA

FROM

-- Select que trás os valores agrupados por dia com a somatória dos títulos de dinheiro e carnê e movimentacao bancaria
(SELECT
  CAB.DTNEG
  ,NAT.DESCRNAT
  ,[RECEITA_DE_VENDA] = SUM(CASE WHEN FIN.CODTIPTIT = 1 THEN FIN.VLRDESDOB END)
  ,[RECEITA_DE_RECEBIMENTO] = SUM(CASE WHEN FIN.CODTIPTIT = 6 THEN FIN.VLRDESDOB END)

-- tras os valores de movimentacao bancaria da matriz
  ,(SELECT 
  SUM(VLRLANC) [VLRLANC]
  FROM 
  TGFMBC
  WHERE
  CODTIPOPER = 1780
  AND DTLANC = CAB.DTNEG
  AND CODCTABCOINT = 8
  GROUP BY
  CONVERT(datetime, CONVERT(DATE,  DTLANC, 101))
  ) AS [MOVIMENTO_BANCARIO]
 
-- soma os valores de entrada com a movimentacao bancaria
  ,( sum(isnull(FIN.VLRDESDOB,0))) 
  + (isnull( (SELECT 
  SUM(VLRLANC) [VLRLANC]
  FROM 
  TGFMBC
  WHERE
  CODTIPOPER = 1780
  AND DTLANC = CAB.DTNEG
  AND CODCTABCOINT = 8
  GROUP BY
  CONVERT(datetime, CONVERT(DATE,  DTLANC, 101))
  ),0) 

) AS ENTRADA
 

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
  NAT.DESCRNAT
  ,CAB.DTNEG) AS ENTRADA

-- Join para fazer o cruzamento das tabelas e considerar o valores nulos
LEFT OUTER JOIN

(
SELECT 
  CAB.DTNEG
  ,SUM(CAB.VLRNOTA) AS SAIDA

FROM
  TGFCAB CAB

WHERE
  CAB.CODTIPOPER = 1304
  AND CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODEMP=@EMP

GROUP BY
  CAB.DTNEG
) AS SAIDA

-- Juntando os dois selects via as datas de negociação
ON ENTRADA.DTNEG = SAIDA.DTNEG

ORDER BY
  ENTRADA.DTNEG
