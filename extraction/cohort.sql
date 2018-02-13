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
    WITH t0 AS (
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
    )
    SELECT t0.*, hw.height_first as height, hw.weight_first as weight
    FROM t0
    LEFT JOIN heightweight hw
    ON t0.icustay_id = hw.icustay_id
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
    WITH t0 as (
        SELECT *, FIRST_VALUE(map_value) OVER(PARTITION BY icustay_id
                      ORDER BY map_time desc) AS last_map_pre
        FROM bolus_map
        WHERE EXTRACT(EPOCH FROM (bolus_time - map_time)) / 3600 BETWEEN 0 AND 1
    -- Aggregates
    ), t1 AS (
        SELECT icustay_id, MIN(bolus_time) AS bolus_time
               , MIN(bolus_volume) AS bolus_volume
               , MIN(map_value) AS min_map_pre, AVG(map_value) AS avg_map_pre
               , MAX(map_value) AS max_map_pre
               , MIN(last_map_pre) AS last_map_pre
        FROM t0
        GROUP BY icustay_id
    -- Keep those with some map < 65
    )
    SELECT *
    FROM t1
    WHERE min_map_pre < 65
), post_bolus_map AS (
    WITH t0 AS (
        -- Values 1h after initial bolus
        SELECT *
        FROM bolus_map
        WHERE EXTRACT(EPOCH FROM (map_time - bolus_time)) / 3600 BETWEEN 0 AND 1
    )
    -- Aggregates
    SELECT icustay_id, MAX(map_value) AS max_map_post
    FROM t0
    GROUP BY icustay_id
)
SELECT b.*, pr.bolus_time, pr.bolus_volume, pr.min_map_pre, pr.avg_map_pre
       , pr.max_map_pre, pr.last_map_pre, po.max_map_post
FROM base b
INNER JOIN pre_bolus_map pr
ON b.icustay_id = pr.icustay_id
INNER JOIN post_bolus_map po
ON b.icustay_id = po.icustay_id
ORDER BY icustay_id;
