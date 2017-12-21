SELECT
PAR.CODPARC
,YEAR(PAR.DTCAD) [ANO_CAD]
-- RETORNA ENDEREÇO COMPLETO E CONCATENADO
,UPPER(RUA.TIPO+" "+RUA.NOMEEND+" , "+RTRIM(BAI.NOMEBAI)+" , "+RTRIM(PAR.NUMEND)+" , "+PAR.CEP+" , "+CID.NOMECID) [ENDERECO]
-- RETORNA O NOME DA RUA COM O PREFIXO
,UPPER(RUA.TIPO+" "+RUA.NOMEEND) [LOGRADOURO]
,BAI.NOMEBAI
,PAR.NUMEND
,PAR.CEP
,CID.NOMECID
,PAR.AD_LOCACAO
-- CONTA A QUANTIDADE DE NOTAS DE COMPRA
,[QTD_NOTAS_COMPRA] = COUNT(CASE WHEN  CAB.CODTIPOPER IN (1112,1101,1110) THEN NUNOTA END)
-- RETORNA O VALOR DAS NOTAS DE COMPRA
,[VLR_NOTAS_COMPRA] = SUM(CASE WHEN  CAB.CODTIPOPER IN (1112,1101,1110) THEN CAB.VLRNOTA END)
-- RETORNA A DATA DA ULTIMA COMPRA
,[ULTIMA_COMPRA] = MAX(CASE WHEN CAB.CODTIPOPER IN (1112,1101,1110) THEN CAB.DTNEG END)
-- CONTA A QUANTIDADE DE NOTAS DE DEVOLUCAO
,[QTD_NOTAS_DEV] = COUNT(CASE WHEN  CAB.CODTIPOPER IN (1201) THEN NUNOTA END)
-- RETORNA O VALOR DAS NOTAS DE DECOLUCAO
,[VLR_NOTAS_DEV] = SUM(CASE WHEN  CAB.CODTIPOPER IN (1201) THEN CAB.VLRNOTA END)
-- RETORNA A DATA DA ULTIMA DEVOLUCAO
,[ULTIMA_DEV] = MAX(CASE WHEN CAB.CODTIPOPER IN (1201) THEN CAB.DTNEG END)

FROM
TGFPAR PAR
,TGFCAB CAB
,TSIBAI BAI
,TSIEND RUA
,TSICID CID

WHERE
PAR.CODPARC = CAB.CODPARC
AND PAR.CODBAI=BAI.CODBAI
AND PAR.CODEND = RUA.CODEND
AND PAR.CODCID = CID.CODCID
AND ATIVO='S'
AND PAR.CODPARC NOT IN (0,1,2,3,4,193)
AND CAB.CODTIPOPER IN (1112,1101,1110,1201)


GROUP BY
PAR.CODPARC
,PAR.DTCAD
,RUA.TIPO
,RUA.NOMEEND
,BAI.NOMEBAI
,PAR.NUMEND
,PAR.CEP
,CID.NOMECID
,PAR.AD_LOCACAO


ORDER BY
SUM(CASE WHEN  CAB.CODTIPOPER IN (1112,1101,1110,1201) THEN CAB.VLRNOTA END) DESC
