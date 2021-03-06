DECLARE @NUCAIXA INT
SET @NUCAIXA = 4814

SELECT TIT.CODTIPTIT * 1.0 AS CODIGO
      ,CAST(TIT.DESCRTIPTIT AS VARCHAR(30)) AS DESCRICAO
      ,SUM(FIN.VLRDESDOB * MCX.RECDESP) AS VALOR
      ,SUM(CAB.VLRDESCTOT + DPI.VLRDESC) AS VLRDESCTOT
     ,SUM(CASE WHEN ISNULL(FIN.VLRCHEQUE,0) = 0 THEN  0 ELSE FIN.VLRCHEQUE - FIN.VLRDESDOB END) AS VLRTROCO
     ,((	SELECT  SUM(DISTINCT(M.VALOR * M.RECDESP)) AS VALOR
               FROM TGFMCX M, TGFFIN F, TGFTIT T 
              WHERE M.NUCAIXA = @NUCAIXA
                AND M.NROUNICO = F.NUFIN
                AND F.CODTIPTIT = T.CODTIPTIT
                AND F.CODTIPTIT = TIT.CODTIPTIT
                AND M.RECDESP = -1
                AND F.DHBAIXA IS NULL)	)AS VLRESTORNO
  FROM TGFMCX MCX
      ,TGFCAB CAB
       INNER JOIN ( SELECT SUM(VLRDESC) VLRDESC, NUNOTA FROM TGFITE GROUP BY NUNOTA) DPI ON DPI.NUNOTA = CAB.NUNOTA
      ,TGFFIN FIN
      ,TGFTIT TIT
 WHERE MCX.NUCAIXA = @NUCAIXA
   AND MCX.ORIGEM = 'E'
   AND MCX.NROUNICO = CAB.NUNOTA
   AND MCX.NROUNICO = FIN.NUNOTA
   AND FIN.CODTIPTIT = TIT.CODTIPTIT
 GROUP BY TIT.CODTIPTIT, TIT.DESCRTIPTIT, CAB.VLRDESCTOT

UNION

SELECT -1.0 AS CODIGO
      ,CAST('SEM FINANCEIRO' AS VARCHAR(30)) AS DESCRICAO
      ,SUM(MCX.VALOR * MCX.RECDESP) AS VALOR
      ,0.0 AS VLRDESCTOT
      ,0.0 AS VLRTROCO
      ,0.0 AS VLRESTORNO
  FROM TGFMCX MCX
      ,TGFCAB CAB
 WHERE MCX.NUCAIXA = @NUCAIXA
   AND MCX.ORIGEM = 'E'
   AND MCX.NROUNICO = CAB.NUNOTA
   AND NOT EXISTS(SELECT F1.NUFIN FROM TGFFIN F1 WHERE F1.NUNOTA = MCX.NROUNICO)
HAVING SUM(MCX.VALOR * MCX.RECDESP) > 0

UNION

SELECT -2.0 AS CODIGO
      ,CAST('TROCO' AS VARCHAR(30)) AS DESCRICAO
      ,0.0 AS VALOR
      ,SUM(CAB.VLRDESCTOT + DPI.VLRDESC) AS VLRDESCTOT
      ,SUM(CAB.TROCO) AS VLRTROCO
      ,0.0 AS VLRESTORNO
  FROM TGFMCX MCX
      ,TGFCAB CAB
       INNER JOIN ( SELECT SUM(VLRDESC) VLRDESC, NUNOTA FROM TGFITE GROUP BY NUNOTA) DPI ON DPI.NUNOTA = CAB.NUNOTA
 WHERE MCX.NUCAIXA = @NUCAIXA
   AND MCX.ORIGEM = 'E'
   AND MCX.NROUNICO = CAB.NUNOTA
   AND (CAB.VLRDESCTOT <> 0 OR CAB.TROCO <> 0)
 GROUP BY CAB.NUNOTA
 ORDER BY 1, 2
