/* Generate cohort view. */

-- Dependencies
\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql
\i map.sql
\i crystalloid-fluids.sql

DROP MATERIALIZED VIEW IF EXISTS cohort CASCADE;
-- Age, gender, ethnicity, first bolus time and volume, map features
CREATE MATERIALIZED VIEW cohort AS
-- First icustay adults
WITH base AS(
    SELECT
        icustay_id, subject_id, hadm_id, gender
        , CASE WHEN ethnicity IN ('ASIAN', 'ASIAN - ASIAN INDIAN',
                                  'ASIAN - CAMBODIAN', 'ASIAN - CHINESE',
                                  'ASIAN - FILIPINO', 'ASIAN - JAPANESE',
                                  'ASIAN - KOREAN', 'ASIAN - OTHER',
                                  'ASIAN - THAI', 'ASIAN - VIETNAMESE') THEN 'Asian'

               WHEN ethnicity IN ('BLACK/AFRICAN', 'BLACK/AFRICAN AMERICAN',
                                  'BLACK/CAPE VERDEAN', 'BLACK/HAITIAN',
                                  'CARIBBEAN ISLAND') THEN 'Black'

               WHEN ethnicity IN ('HISPANIC/LATINO - CENTRAL AMERICAN (OTHER)',
                                  'HISPANIC/LATINO - COLOMBIAN',
                                  'HISPANIC/LATINO - CUBAN',
                                  'HISPANIC/LATINO - DOMINICAN',
                                  'HISPANIC/LATINO - GUATEMALAN',
                                  'HISPANIC/LATINO - HONDURAN',
                                  'HISPANIC/LATINO - MEXICAN',
                                  'HISPANIC/LATINO - PUERTO RICAN',
                                  'HISPANIC/LATINO - SALVADORAN',
                                  'HISPANIC OR LATINO', 'PORTUGUESE',
                                  'SOUTH AMERICAN') THEN 'Latino'

               WHEN ethnicity IN ('AMERICAN INDIAN/ALASKA NATIVE',
                                  'AMERICAN INDIAN/ALASKA NATIVE FEDERALLY RECOGNIZED TRIBE',
                                  'MIDDLE EASTERN', 'MULTI RACE ETHNICITY',
                                  'NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER',
                                  'OTHER') THEN 'Other'

               WHEN ethnicity IN ('PATIENT DECLINED TO ANSWER', 'UNABLE TO OBTAIN',
                                  'UNKNOWN/NOT SPECIFIED') THEN 'Unknown'

               WHEN ethnicity IN ('WHITE', 'WHITE - BRAZILIAN',
                                  'WHITE - EASTERN EUROPEAN',
                                  'WHITE - OTHER EUROPEAN', 'WHITE - RUSSIAN')
                 THEN 'White'
        END AS ethnicity_group
        , intime, outtime, los_icu, dod, hospital_expire_flag
    FROM icustay_detail
    WHERE first_icu_stay is True
    AND admission_age >= 18
-- table with the first bolus time, joined to maps
), bolus_map AS (
    SELECT b.icustay_id, b.charttime AS bolus_time, b.bolus_volume
           , m.charttime AS map_time, m.itemid, m.valuenum AS map_value
    FROM first_bolus b
    INNER JOIN day1_map m
    ON b.icustay_id = m.icustay_id
    ORDER BY icustay_id, map_time
-- Aggregate map readings (and their times) before bolus:
-- max, min, average, last
), pre_bolus_map AS (
    WITH tmp_0 as (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY icustay_id
                                     ORDER BY map_time desc) row_num
        FROM bolus_map
        WHERE map_time < bolus_time
    -- Aggregates
    ), tmp_1 AS (
        SELECT icustay_id, min(bolus_time) as bolus_time, min(bolus_volume) as bolus_volume
               , MIN(map_value) AS min_map_pre, AVG(map_value) AS avg_map_pre
               , MAX(map_value) AS max_map_pre
        FROM tmp_0
    -- Need to make another table for last map
    GROUP BY icustay_id
    ), tmp_2 AS (
        SELECT icustay_id, map_value as last_map_pre
        FROM tmp_0
        WHERE row_num = 1
    )
    SELECT t1.*, t2.last_map_pre
    FROM tmp_1 t1
    INNER JOIN tmp_2 t2
    ON t1.icustay_id = t1.icustay_id
), post_bolus_map AS (
    WITH tmp_0 as (
        -- Values 1h after initial bolus
        SELECT *
        FROM bolus_map
        WHERE EXTRACT(EPOCH FROM (map_time - bolus_time)) / 3600 BETWEEN 0 AND 1
    )
    -- Aggregates
    SELECT icustay_id, MAX(map_value) AS max_map_post
    FROM tmp_0
    GROUP BY icustay_id
)
SELECT b.*, pr.bolus_time, pr.bolus_volume, pr.min_map_pre, pr.avg_map_pre
       , pr.max_map_pre, pr.last_map_pre, po.max_map_post
FROM base b
INNER JOIN pre_bolus_map pr
ON b.icustay_id = pr.icustay_id
INNER JOIN post_bolus_map po
ON b.icustay_id = po.icustay_id;


















--------------- Test Run







-- table with the first bolus time, joined to maps
with bolus_map AS (
    SELECT b.icustay_id, b.charttime AS bolus_time, b.bolus_volume
           , m.charttime AS map_time, m.itemid, m.valuenum AS map_value
    FROM first_bolus b
    INNER JOIN day1_map m
    ON b.icustay_id = m.icustay_id
    ORDER BY icustay_id, map_time
-- Aggregate map readings (and their times) before bolus:
-- max, min, average, last
), pre_bolus_map AS (
    WITH tmp_0 as (
        SELECT *, ROW_NUMBER() OVER (PARTITION BY icustay_id
                                     ORDER BY map_time desc) row_num
        FROM bolus_map
        WHERE map_time < bolus_time
    -- Aggregates
    ), tmp_1 AS (
        SELECT icustay_id, min(bolus_time), min(bolus_volume), MIN(map_value) AS min_map,
               AVG(map_value) AS avg_map, MAX(map_value) AS max_map
        FROM tmp_0
    -- Need to make another table for last map
    GROUP BY icustay_id
    )
    SELECT icustay_id, map_value as last_pre_map
    FROM tmp_0
    WHERE row_num = 1
)
select * from pre_bolus_map;




select
from icustays i
left join admissions a
on i.subject_id = a.subject_id
left join heightweight h
on h.icustay_id = i.icustay_id;
