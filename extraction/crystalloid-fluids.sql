-- Crystalloid fluids

-- All crystalloid fluids within 48h admission



-- First 24h Bolus with volume >= 1l
DROP MATERIALIZED VIEW IF EXISTS day1_bolus cascade;

CREATE MATERIALIZED VIEW day1_bolus AS
WITH bolus AS (
    SELECT cb.*, i.intime
    FROM crystalloid_bolus cb
    LEFT JOIN icustays i
    ON cb.icustay_id = i.icustay_id
)
SELECT icustay_id, charttime, crystalloid_bolus AS bolus_volume
FROM bolus
WHERE EXTRACT(EPOCH FROM (charttime - intime)) / 3600 < 24
AND crystalloid_bolus > 1000;
