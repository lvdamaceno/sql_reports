SELECT
--INFORMACOES BASICAS DOS PRODUTOS
PRO.CODPROD
,PRO.DESCRPROD
,PRO.AD_MODELOREF
--ULTIMA DATA DE MODIFICACAO DO PRODUTO
,PRO.DTALTER
--DIFERENCA DE DATAS ENTRE A DATA DE MODIFICACAO DO PRODUTO E A DATA ATUAL DO SISTEMA
,DATEDIFF(DAY, PRO.DTALTER, GETDATE()) AS [DIFERENCA]
--VALOR TOTAL DE VENDAS DO PRODUTO
,SUM(ITE.VLRTOT) AS [VLR]
--QUANTIDADE DE NOTAS DO PRODUTO
,COUNT(ITE.NUNOTA) AS [QTD_NOTAS]
--MEDIA ENTRE VALOR VENDIDO E POPULARIDADE
,SUM(ITE.VLRTOT)/COUNT(ITE.NUNOTA) AS [MEDIA]
--CALCULADO A MEDIA DE TODOS OS PRODUTOS
,
    (SELECT
    (SUM(ITE.VLRTOT)/COUNT(ITE.NUNOTA)) AS [MEDIA]
    FROM
    TGFPRO AS PRO
    ,TGFCAB AS CAB
    ,TGFITE AS ITE
    WHERE
    PRO.CODPROD=ITE.CODPROD
    AND ITE.NUNOTA = CAB.NUNOTA
    AND PRO.CODGRUPOPROD <= 1990000
    AND DATEDIFF(DAY, PRO.DTALTER, GETDATE()) <= 360
    AND CAB.CODTIPOPER IN (1110,1112,1101)) AS [FATOR]
    
FROM
TGFPRO AS PRO
,TGFCAB AS CAB
,TGFITE AS ITE

WHERE
PRO.CODPROD=ITE.CODPROD
AND ITE.NUNOTA = CAB.NUNOTA
AND PRO.CODGRUPOPROD <= 1990000
--MUDAR AQUI PARA DENTRO DE UM ANO OU MAIS DE UM ANO
AND DATEDIFF(DAY, PRO.DTALTER, GETDATE()) <= 360
AND CAB.CODTIPOPER IN (1110,1112,1101)

GROUP BY
PRO.CODPROD
,PRO.DESCRPROD
,PRO.AD_MODELOREF
,PRO.DTALTER

--MUDAR AQUI PARA MAIOR QUE O FATOR OU MENOR
HAVING
(SUM(ITE.VLRTOT)/COUNT(ITE.NUNOTA)) >=
    (SELECT
    (SUM(ITE.VLRTOT)/COUNT(ITE.NUNOTA)) AS [MEDIA]
    FROM
    TGFPRO AS PRO
    ,TGFCAB AS CAB
    ,TGFITE AS ITE
    WHERE
    PRO.CODPROD=ITE.CODPROD
    AND ITE.NUNOTA = CAB.NUNOTA
    AND PRO.CODGRUPOPROD <= 1990000
    AND DATEDIFF(DAY, PRO.DTALTER, GETDATE()) <= 360
    AND CAB.CODTIPOPER IN (1110,1112,1101))

ORDER BY
PRO.CODPROD
