SELECT PRINCIPAL.NUNOTA
             ,PRINCIPAL.NUMNOTA
             ,PRINCIPAL.NOMEPARC
             ,PRINCIPAL.VLRNOTA
             ,PRINCIPAL.VLRFRETE
             ,PRINCIPAL.CODPROD
             ,PRINCIPAL.DESCRPROD
             ,PRINCIPAL.QTDNEG
             ,PRINCIPAL.VLRUNIT
             ,PRINCIPAL.VLRTOT
             ,PRINCIPAL.ALIQIPI
             ,PRINCIPAL.VLRIPI
             ,COMPRA.VLR_COMPRA [ULT_COMPRA]
             ,VENDA.PRECO_VENDA [ULT_VENDA]
FROM
(
SELECT CAB.NUNOTA
             ,CAB.NUMNOTA
             ,CAB.CODPARC
             ,PAR.NOMEPARC
             ,CAB.VLRNOTA
             ,ITE.CODPROD
             ,PRO.DESCRPROD + ' - ' + PRO.MARCA + ' - ' +PRO.AD_MODELOREF [DESCRPROD]
             ,ITE.QTDNEG
             ,ITE.VLRUNIT
             ,ITE.VLRTOT
             ,ITE.VLRIPI
             ,ITE.ALIQIPI
             ,CAB.VLRFRETE

FROM TGFCAB CAB
          ,TGFITE ITE
          ,TGFPAR PAR
          ,TGFPRO PRO

WHERE CAB.NUNOTA = ITE.NUNOTA
     AND CAB.CODPARC = PAR.CODPARC
     AND ITE.CODPROD = PRO.CODPROD ) AS PRINCIPAL

,

(
-- PRECO VENDA
SELECT DISTINCT
             PRO.CODPROD,
             PRO.DESCRPROD,
             PRO.AD_MODELOREF,
             (SELECT ME.VLRVENDA
              FROM TGFNTA NTA
                        ,TGFTAB MT
                        ,TGFEXC ME
              WHERE NTA.CODTAB = MT.CODTAB
                   AND MT.NUTAB = ME.NUTAB
                   AND NTA.CODTAB =  0
                   AND ME.CODPROD = PRO.CODPROD
                   AND MT.DTVIGOR = (SELECT MAX(MT.DTVIGOR)
                                                     FROM TGFNTA NTA, 
                                                                TGFTAB MT,
                                                                TGFEXC ME
                                                     WHERE NTA.CODTAB = MT.CODTAB
                                                          AND MT.NUTAB = ME.NUTAB
                                                          AND NTA.CODTAB = 0
                                                          AND ME.CODPROD = PRO.CODPROD)) AS PRECO_VENDA
              FROM TGFEST EST,
                         TGFPRO PRO
             WHERE EST.CODPROD = PRO.CODPROD
                          AND EST.CODEMP IN (1,2,4)
                          AND EST.ESTOQUE > 0
) AS VENDA

,

(
SELECT CAB.DTNEG
             ,ITE.CODPROD
             ,ITE.VLRUNIT [VLR_COMPRA]

FROM TGFCAB CAB
          ,TGFITE ITE

WHERE CAB.NUNOTA = ITE.NUNOTA
     AND CAB.CODTIPOPER IN (1413,1403,1412,1402,1417,1409,1418,1403,1433)
     AND CAB.DTNEG = (SELECT MAX(CAB1.DTNEG)
                                      FROM TGFCAB CAB1
                                                ,TGFITE ITE1
                                      WHERE CAB1.NUNOTA=ITE1.NUNOTA
                                           AND CAB1.CODTIPOPER IN (1413,1403,1412,1402,1417,1409,1418,1403,1433)
                                           AND ITE1.CODPROD = ITE.CODPROD)
) AS COMPRA

WHERE PRINCIPAL.CODPROD=VENDA.CODPROD
     AND PRINCIPAL.CODPROD = COMPRA.CODPROD
     AND PRINCIPAL.NUNOTA = 266925

ORDER BY PRINCIPAL.CODPROD
