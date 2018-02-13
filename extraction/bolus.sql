-- Get first bolus values within 24 hours of admission

-- The first bolus of the icu-stay within 24h of intime and with volume >= 1L
DROP MATERIALIZED VIEW IF EXISTS first_bolus cascade;

CREATE MATERIALIZED VIEW first_bolus AS
-- Add icustayid
WITH bolus AS (
    SELECT cb.*, i.intime
    FROM crystalloid_bolus cb
    LEFT JOIN icustays i
    ON cb.icustay_id = i.icustay_id
-- Filter volume and time
), large_bolus AS (
    SELECT icustay_id, charttime, crystalloid_bolus AS bolus_volume
           , ROW_NUMBER() OVER (PARTITION BY icustay_id ORDER BY intime) row_num
    FROM bolus
    WHERE EXTRACT(EPOCH FROM (charttime - intime)) / 3600 < 24
    AND crystalloid_bolus > 490
)
-- Get first bolus for each icustay
SELECT icustay_id, charttime, bolus_volume
FROM large_bolus
WHERE row_num = 1;
