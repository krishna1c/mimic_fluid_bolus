-- Extract MAP measurements

-- DROP MATERIALIZED VIEW IF EXISTS map cascade;
-- CREATE MATERIALIZED VIEW map AS

-- SELECT DISTINCT subject_id, icustay_id, charttime, itemid, valuenum
-- FROM chartevents
-- WHERE valuenum IS NOT NULL AND itemid IN (220181, 220052, 225312, 224322, 6702, 443, 52, 456)
--   AND 30 < valuenum AND valuenum < 200
-- ORDER BY valuenum, icustay_id, charttime, itemid;


-- Get all map
DROP MATERIALIZED VIEW IF EXISTS map cascade;
CREATE MATERIALIZED VIEW map AS
WITH t0 as(
    SELECT DISTINCT ce.subject_id, ce.icustay_id, ce.charttime, ce.itemid
                    , ce.valuenum
    FROM chartevents ce
    WHERE valuenum IS NOT NULL
      AND itemid IN (220181, 220052, 225312, 224322, 6702, 443, 52, 456)
      AND 30 < valuenum
      AND valuenum < 200
)
SELECT t0.*, i.intime
FROM t0
LEFT JOIN icustays i
ON t0.icustay_id = i.icustay_id
ORDER BY icustay_id, charttime, itemid;


-- First 24h maps
DROP MATERIALIZED VIEW IF EXISTS day1_map cascade;
CREATE MATERIALIZED VIEW day1_map AS
SELECT subject_id, icustay_id, charttime, itemid, valuenum
FROM map
WHERE EXTRACT(EPOCH FROM (charttime - intime)) / 3600 < 24
ORDER BY icustay_id, charttime, itemid;

