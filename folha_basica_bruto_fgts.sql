SELECT 
FOL.REFERENCIA
,FOL.CODEMP
,FOL.CODFUNC
,FUN.NOMEFUNC
,FOL.TIPFOLHA
,[SALARIO BASE] = SUM(CASE WHEN FOL.CODEVENTO IN (1) THEN FOL.VLREVENTO END)
,[FGTS] = SUM(CASE WHEN FOL.CODEVENTO IN (995) THEN FOL.VLREVENTO END)
,[BASE + FGTS] = SUM(CASE WHEN FOL.CODEVENTO IN (1,995) THEN FOL.VLREVENTO END)
FROM
TFPFOL FOL
,TFPFUN AS FUN
,TFPEVE AS EVE
WHERE
FOL.CODFUNC=FUN.CODFUNC
AND FOL.CODEMP=FUN.CODEMP
AND FOL.CODEVENTO = EVE.CODEVENTO
--AND FOL.CODFUNC IN (5, 17, 49)
--AND FOL.CODEMP=1
AND FOL.REFERENCIA = '01/05/2016'
AND FOL.TIPFOLHA = 'N'
AND FOL.CODEVENTO IN (1,995)
GROUP BY
FOL.REFERENCIA
,FOL.CODEMP
,FOL.CODFUNC
,FUN.NOMEFUNC
,FOL.TIPFOLHA
ORDER BY
FOL.CODEMP
,FOL.CODFUNC
