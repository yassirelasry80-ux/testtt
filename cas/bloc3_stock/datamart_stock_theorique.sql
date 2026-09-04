SELECT
    stofcy_0,
    TO_CHAR(sysdate, 'dd/mm/yyyy') AS dateinv,
    itmref_0,
    SUM(qtypcu_0) AS stk
FROM stock
GROUP BY
    stofcy_0,
    itmref_0;