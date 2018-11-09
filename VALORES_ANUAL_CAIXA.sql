-- ANUAL

DECLARE @ANO INT
SET @ANO = YEAR(GETDATE())

SELECT D.NOMEFANTASIA
      ,@ANO [ANO]
      ,D.DINHEIRO
      ,D.CARNE
      ,D.DINHEIRO + D.CARNE [SOMA]
      ,D.CREDITO
      ,D.DEBITO
      ,D.SOMA_C_D
      ,D.C_INTERNA
      ,D.TOTAL + D.CARNE [TOTAL] 
 FROM (
 
SELECT CASE
       WHEN USU.CODEMP = 1 THEN 'MATRIZ - PE. EUTIQUIO'
	   WHEN USU.CODEMP = 4 THEN 'FILIAL - PD. MIRANDA'		
       END AS [NOMEFANTASIA]
      ,[DINHEIRO] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE = 1 THEN FIN.VLRDESDOB * MCX.RECDESP END),0)
      ,(	SELECT [CARNE] = ISNULL(SUM(CASE WHEN F.CODTIPTIT = 6 THEN F.VLRDESDOB END),0)
              FROM TGFFIN F, TGFTIT T, TSIUSU U,TSIEMP E
             WHERE F.CODTIPTIT = T.CODTIPTIT
               AND F.CODUSUBAIXA = U.CODUSU
               AND F.CODEMP = E.CODEMP
               AND YEAR(F.DHBAIXA) = @ANO
               AND F.CODTIPOPER IN (1112,1101)
               AND VLRBAIXA > 0
               AND F.CODEMP = USU.CODEMP) AS [CARNE]
      ,NULL AS [SOMA]
      ,[CREDITO] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE = 3 THEN FIN.VLRDESDOB * MCX.RECDESP END),0)
      ,[DEBITO] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE = 4 THEN FIN.VLRDESDOB * MCX.RECDESP END),0)
      ,[SOMA_C_D] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE IN (3 ,4) THEN (FIN.VLRDESDOB * MCX.RECDESP) END),0)
      ,[C_INTERNA] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE = 5 THEN FIN.VLRDESDOB * MCX.RECDESP END),0)
      ,[TOTAL] = ISNULL(SUM(CASE WHEN TIT.TPAGNFCE IN (1, 3, 4, 5) THEN (FIN.VLRDESDOB * MCX.RECDESP) END),0)
  FROM TGFMCX MCX
      ,TGFCAB CAB
       INNER JOIN ( SELECT SUM(VLRDESC) VLRDESC, NUNOTA FROM TGFITE GROUP BY NUNOTA) DPI ON DPI.NUNOTA = CAB.NUNOTA
      ,TGFFIN FIN
      ,TGFTIT TIT
      ,TSIUSU USU
 WHERE YEAR(MCX.DTALTER) = @ANO
   AND MCX.ORIGEM = 'E'
   AND MCX.NROUNICO = CAB.NUNOTA
   AND MCX.NROUNICO = FIN.NUNOTA
   AND FIN.CODTIPTIT = TIT.CODTIPTIT
   AND MCX.CODUSU = USU.CODUSU
 GROUP BY USU.CODEMP	) AS D
 ORDER BY D.NOMEFANTASIA DESC
