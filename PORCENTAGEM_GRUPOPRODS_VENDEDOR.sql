DECLARE @YEAR int
SET @YEAR=2017

DECLARE @MONTH int
SET @MONTH=3

DECLARE @VEND int
SET @VEND=29

SELECT
  'ELETROS' [GRUPO]
  ,SUM(ITE.VLRTOT-ITE.VLRDESC) [QTDNEG]

FROM
  TGFCAB CAB
  ,TGFITE ITE
  ,TGFPRO PRO
  ,TGFVEN VEN

WHERE
  CAB.NUNOTA = ITE.NUNOTA
  AND PRO.CODPROD = ITE.CODPROD
  AND ITE.CODVEND = VEN.CODVEND
  AND YEAR(CAB.DTNEG) = @YEAR
  AND MONTH(CAB.DTNEG) = @MONTH
  AND CAB.CODTIPOPER IN (1110,1101,1112)
  AND ITE.CODVEND NOT IN (0,22,202)
  AND ((CODGRUPOPROD>='01010000' AND CODGRUPOPROD<='01029999') OR 
      (CODGRUPOPROD>='01040000' AND CODGRUPOPROD<='01049999'))

  AND ITE.CODVEND=@VEND


UNION ALL

SELECT
  'MOVEIS' [GRUPO]
  ,SUM(ITE.VLRTOT-ITE.VLRDESC) [QTDNEG]

FROM
  TGFCAB CAB
  ,TGFITE ITE
  ,TGFPRO PRO
  ,TGFVEN VEN

WHERE
  CAB.NUNOTA = ITE.NUNOTA
  AND PRO.CODPROD = ITE.CODPROD
  AND ITE.CODVEND = VEN.CODVEND
  AND YEAR(CAB.DTNEG) = @YEAR
  AND MONTH(CAB.DTNEG) = @MONTH
  AND CAB.CODTIPOPER IN (1110,1101,1112)
  AND ITE.CODVEND NOT IN (0,22,202)
  AND ((CODGRUPOPROD>='01030000' AND CODGRUPOPROD<='01039999') OR
      (CODGRUPOPROD>='01050000' AND CODGRUPOPROD<='01999999'))

AND ITE.CODVEND=@VEND
