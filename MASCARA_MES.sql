SELECT CASE WHEN MONTH(DTNEG)=1 THEN 'JAN'
            WHEN MONTH(DTNEG)=2 THEN 'FEV'
            WHEN MONTH(DTNEG)=3 THEN 'MAR'
            WHEN MONTH(DTNEG)=4 THEN 'ABR'
            WHEN MONTH(DTNEG)=5 THEN 'MAI'
            WHEN MONTH(DTNEG)=6 THEN 'JUN'
            WHEN MONTH(DTNEG)=7 THEN 'JUL'
            WHEN MONTH(DTNEG)=8 THEN 'AGO'
            WHEN MONTH(DTNEG)=9 THEN 'SET'
            WHEN MONTH(DTNEG)=10 THEN 'OUT'
            WHEN MONTH(DTNEG)=11 THEN 'NOV'
            WHEN MONTH(DTNEG)=12 THEN 'DEZ'
       END [MES]
