SELECT
    bpsnum_0  AS frs,
    bpsnam_0  AS lib_frs
FROM bpsupplier
WHERE bpsnum_0 >= '0'
  AND bpsnum_0 <  ':'
  AND LENGTH(bpsnum_0) > 1