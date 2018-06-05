-- Variáveis para o período (mês / ano) e código da empresa
DECLARE @ANO INT
SET @ANO = 2018
DECLARE @MES INT
SET @MES = 5
DECLARE @EMP INT
SET @EMP = 1

SELECT
  ENTRADA.DTNEG
  ,ENTRADA.ENTRADA
  ,SAIDA.SAIDA
  ,(ENTRADA.ENTRADA - SAIDA.SAIDA) AS SALDO_DO_DIA

FROM

-- Select que trás os valores agrupados por dia com a somatória dos títulos de dinheiro e carnê.
(
SELECT
  CAB.DTNEG
  ,SUM(FIN.VLRDESDOB) AS ENTRADA

FROM
  TGFCAB CAB
  ,TGFFIN FIN

WHERE
  YEAR(CAB.DTNEG) = @ANO
  AND MONTH(CAB.DTNEG) = @MES
  AND CAB.CODTIPOPER IN (1112,1101)
  AND CAB.NUMNOTA = FIN.NUMNOTA
  -- Atenção aqui, para não duplicar as linhas foi igualada as datas de negociação da TGFCAB e data da baixa e movimentação
  -- da TGFFIN, sem isso as informações vem repetidas.
  AND CAB.DTNEG = FIN.DHMOV
  AND CAB.DTNEG = FIN.DHBAIXA
  AND FIN.CODTIPTIT IN (1,6)
  AND CAB.CODEMP=@EMP

GROUP BY
  CAB.DTNEG
) AS ENTRADA

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
  AND YEAR(CAB.DTNEG) = @ANO
  AND MONTH(CAB.DTNEG) = @MES
  AND CAB.CODEMP=@EMP

GROUP BY
  CAB.DTNEG
) AS SAIDA

-- Juntando os dois selects via as datas de negociação
ON ENTRADA.DTNEG = SAIDA.DTNEG

ORDER BY
  ENTRADA.DTNEG
