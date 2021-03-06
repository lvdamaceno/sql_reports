SELECT
ITE.CODPROD
,PRO.DESCRPROD
,PRO.AD_MODELOREF
,PRO.MARCA
,EST.ESTOQUE
,SUM(ITE.QTDNEG) AS QTDNEG
,SUM(ITE.VLRTOT-ITE.VLRDESC) AS VLRTOT
FROM
TGFITE AS ITE

INNER JOIN
TGFCAB AS CAB
ON CAB.NUNOTA=ITE.NUNOTA

INNER JOIN
TGFPRO AS PRO
ON ITE.CODPROD=PRO.CODPROD

INNER JOIN
TGFGRU AS GRU
ON PRO.CODGRUPOPROD=GRU.CODGRUPOPROD

LEFT OUTER JOIN
ESTOQUECOMAVARIA AS EST
ON ITE.CODPROD=EST.CODPROD

WHERE
CAB.CODTIPOPER IN (1110,1101) 
AND GRU.DESCRGRUPOPROD LIKE ('%COLCHAO%')
AND PRO.MARCA LIKE ('%ANJOS%')
AND CAB.DTNEG>='01/01/2014'

GROUP BY
ITE.CODPROD,
PRO.DESCRPROD,
PRO.AD_MODELOREF,
PRO.MARCA,
EST.ESTOQUE

ORDER BY
SUM(ITE.VLRTOT) DESC
