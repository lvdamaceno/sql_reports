DECLARE @DT_INICIO DATE
    SET @DT_INICIO = '01/06/2018'
DECLARE @DT_FIM DATE
    SET @DT_FIM =  '14/06/2018'
DECLARE @EMP INT
    SET @EMP = 1

SELECT * FROM (

------------------------------------------------ ENTRADAS (DINHEIRO+DEPOSITO BANCARIOS / CARNÊ)

(
SELECT CAB.DTNEG
    -- CASE PARA DAR UM LABEL PARA DINHEIRO E CARNÊ
      ,CASE
       WHEN FIN.CODTIPTIT=1 THEN 'DINHEIRO'
       WHEN FIN.CODTIPTIT=6 THEN 'CARNE'
       END AS [TIPO_TITULO]
    -- O ISNULL FOI UTILIZADO PARA EVITAR QUE A SUBTRAÇÃO POR NULL RETORNA-SE NULL
    -- O PRIMEIRO SUM RETORNA A SOMATORIA DOS VALORES DE DINHEIRO E CARTÃO ENQUANTO
    -- O SEGUNDO FAZ UMA SUBQUERY PARA CONSULTAR DENTRO DA OUTRA TABELA QUE TEM OS
    -- VALORES DE MOVIMENTAÇÃO BANCARIA, FECHAR POR UM CODIGO ESPECIFO DE CONTA (VA
    -- LOR QUE DEVE SER MODIFICADO PARA TRAZER OS VALORES D EOUTRAS UNIDADES, NO FIM
    -- AGRUPANDO TUDO POR DATA.
      ,SUM(ISNULL(FIN.VLRDESDOB ,0))
      +ISNULL(
         (SELECT SUM(VLRLANC) [VLRLANC]
            FROM TGFMBC
           WHERE CODTIPOPER = 1780
             AND DTLANC = CAB.DTNEG
             AND CODCTABCOINT = 8
             AND FIN.CODTIPTIT=1
               --FILTRA OS REGISTROS DO BANCO AO LADO DOS REGISTRO EM DINHEIRO
        GROUP BY CONVERT(datetime, CONVERT(DATE,  DTLANC, 101))),0) AS [ENTRADA]
    -- CAMPOS NULOS PARA PODER FAZER A "ESCADA" NO RETORNO DOS VALORES
      ,NULL AS [NATUREZA]
      ,NULL AS [SAIDA]
      ,NULL AS [SALDO]
    -- ESSA COLUNA SORTBY SERÁ RESPONSAVEL POR ORDERNAR CORRETAMENTE NO FIM PARA QUE
    -- VENHAM PRIMEIROS OS VALORES DE ENTRADA, DEPOIS DE SAIR E POR FIM O SALDO.
      ,1 SORTBY
FROM TGFCAB CAB
    ,TGFFIN FIN
    ,TGFNAT NAT

WHERE CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODTIPOPER IN (1112,1101)
  AND CAB.NUMNOTA = FIN.NUMNOTA
  AND CAB.CODNAT = NAT.CODNAT
   -- ATENÇÃO AQUI, PARA NÃO DUPLICAR AS LINHAS FOI IGUALADA AS DATAS DE 
   -- NEGOCIAÇÃO DA TGFCAB E DATA DA BAIXA E MOVIMENTAÇÃO
   -- DA TGFFIN, SEM ISSO AS INFORMAÇÕES VEM REPETIDAS.
  AND CAB.DTNEG = FIN.DHMOV
  AND CAB.DTNEG = FIN.DHBAIXA
  AND FIN.CODTIPTIT IN (1,6)
  AND CAB.CODEMP=@EMP

GROUP BY CAB.DTNEG
        ,FIN.CODTIPTIT

------------------------------------------------ ENTRADAS (DINHEIRO+DEPOSITO BANCARIOS / CARNÊ)

) UNION ALL (

------------------------------------------------ SAIDAS
  
SELECT CAB.DTNEG
      ,NULL AS [TIPO_TITULO]
      ,NULL AS [ENTRADA]
      ,NAT.DESCRNAT [NATUREZA]
      ,SUM(CAB.VLRNOTA) AS SAIDA
      ,NULL AS [SALDO] 
      ,2 SORTBY 

FROM TGFCAB CAB
    ,TGFNAT NAT

WHERE CAB.CODTIPOPER = 1304
  AND CAB.CODNAT = NAT.CODNAT
  AND CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODEMP=@EMP

GROUP BY CAB.DTNEG
        ,NAT.DESCRNAT

------------------------------------------------ SAIDAS

) UNION ALL (

------------------------------------------------ SALDO
  
SELECT ENTRADA.DTNEG 
      ,NULL AS [TIPO_TITULO]
      ,NULL AS [ENTRADA]
      ,NULL AS [NATUREZA]
      ,NULL AS [SAIDA]
      ,ENTRADA.SALDO - ISNULL(SAIDA.SALDO,0) AS SALDO
      ,3 SORTBY

FROM 

(
SELECT CAB.DTNEG
      ,SUM(ISNULL(FIN.VLRDESDOB ,0))
      +ISNULL(
        (SELECT SUM(VLRLANC) [VLRLANC]
           FROM TGFMBC
          WHERE CODTIPOPER = 1780
            AND DTLANC = CAB.DTNEG
            AND CODCTABCOINT = 8
       GROUP BY CONVERT(datetime, CONVERT(DATE,  DTLANC, 101))),0) AS [SALDO]

FROM TGFCAB CAB
    ,TGFFIN FIN
    ,TGFNAT NAT

WHERE CAB.DTNEG >= @DT_INICIO
      AND CAB.DTNEG <= @DT_FIM
      AND CAB.CODTIPOPER IN (1112,1101)
      AND CAB.NUMNOTA = FIN.NUMNOTA
      AND CAB.CODNAT = NAT.CODNAT
      AND CAB.DTNEG = FIN.DHMOV
      AND CAB.DTNEG = FIN.DHBAIXA
      AND FIN.CODTIPTIT IN (1,6)
      AND CAB.CODEMP=@EMP

GROUP BY CAB.DTNEG) AS ENTRADA

------------------------------------------------
LEFT JOIN
------------------------------------------------

(
SELECT CAB.DTNEG
      ,ISNULL(SUM(CAB.VLRNOTA),0) AS SALDO

FROM TGFCAB CAB
    ,TGFNAT NAT

WHERE CAB.CODTIPOPER = 1304
  AND CAB.CODNAT = NAT.CODNAT
  AND CAB.DTNEG >= @DT_INICIO
  AND CAB.DTNEG <= @DT_FIM
  AND CAB.CODEMP=@EMP

GROUP BY CAB.DTNEG

) AS SAIDA

ON ENTRADA.DTNEG = SAIDA.DTNEG
  
------------------------------------------------ SALDO

)) AS RESULT_SET

GROUP BY RESULT_SET.DTNEG
        ,RESULT_SET.TIPO_TITULO
        ,RESULT_SET.ENTRADA
        ,RESULT_SET.NATUREZA
        ,RESULT_SET.SAIDA
        ,RESULT_SET.SALDO
        ,SORTBY

ORDER BY RESULT_SET.DTNEG
        ,SORTBY
