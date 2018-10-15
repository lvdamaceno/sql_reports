SELECT EST.CODEMP
      ,CAB.DTNEG
      ,ITE.CODPROD
      ,PRO.DESCRPROD
      ,EST.ESTOQUE
      ,ITE.ALIQICMS
      ,ITE.VLRUNIT
      ,(EST.ESTOQUE * ITE.VLRUNIT) AS [ESTOQUExVLRUNIT]
      ,((ITE.VLRUNIT * ITE.ALIQICMS) / 100) AS [ICMSUNIT]
      ,(EST.ESTOQUE * ((ITE.VLRUNIT * ITE.ALIQICMS) / 100)) AS [ESTOQUExICMSUNIT]
      ,(EST.ESTOQUE * (ITE.VLRUNIT + (((ITE.VLRUNIT * ITE.ALIQICMS) / 100)))) AS [VLRFINAL]
  FROM TGFCAB CAB
      ,TGFITE ITE
      ,TGFEST EST
      ,TGFPRO PRO
 WHERE CAB.NUNOTA = ITE.NUNOTA 
   AND ITE.CODPROD = EST.CODPROD
   AND ITE.CODPROD = PRO.CODPROD
   AND CAB.CODTIPOPER IN (1431, 1410, 1432, 1414, 1404, 
                          1411, 1408, 1401, 1429, 1415, 
                          1405, 1436, 1433, 1419, 1438, 
                          1441, 1453, 1511, 1418, 1409, 
                          1434, 1437, 1413, 1403 ,1412, 
                          1402, 1454, 1417 ,1418, 1452)
   AND CAB.DTNEG = (SELECT MAX(CAB1.DTNEG)
                      FROM TGFCAB CAB1
                          ,TGFITE ITE1
	                 WHERE CAB1.NUNOTA = ITE1.NUNOTA 
	                   AND ITE1.CODPROD = ITE.CODPROD
	                   AND CAB1.CODTIPOPER IN (1431, 1410, 1432, 1414, 1404, 
						                       1411, 1408, 1401, 1429, 1415, 
						                       1405, 1436, 1433, 1419, 1438, 
						                       1441, 1453, 1511, 1418, 1409, 
						                       1434, 1437, 1413, 1403 ,1412, 
						                       1402, 1454, 1417 ,1418, 1452))
   AND EST.CODEMP = 2
   AND EST.ESTOQUE > 0
   AND PRO.CODGRUPOPROD <= '01140000'
   ORDER BY EST.ESTOQUE