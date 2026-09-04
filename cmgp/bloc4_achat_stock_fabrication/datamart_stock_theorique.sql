SELECT
    stofcy_0,
    TO_CHAR(SYSDATE, 'dd/mm/yyyy') dateinv,
    itmref_0,
    SUM(qtypcu_0) stk
FROM
    stock
WHERE
    itmref_0 NOT LIKE 'C%'
GROUP BY
    stofcy_0,
    itmref_0