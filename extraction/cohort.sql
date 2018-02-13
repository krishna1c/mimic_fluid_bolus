/* Generate cohort view. */

-- Dependencies
\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql
\i map.sql
\i crystalloid-fluids.sql

DROP MATERIALIZED VIEW IF EXISTS cohort CASCADE;

CREATE MATERIALIZED VIEW cohort AS(

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
, bolus_map AS (
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
    ), tmp_2 AS (
        SELECT icustay_id, map_value as last_pre_map
        FROM tmp_0
        WHERE row_num = 1
    )
    SELECT t1.*, t2.last_pre_map
    FROM tmp_1 t1
    JOIN tmp_2 t2
    ON t1.icustay_id = t1.icustay_id
)








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
    ), tmp_2 AS (
        SELECT icustay_id, map_value as last_pre_map
        FROM tmp_0
        WHERE row_num = 1
    )
    SELECT t1.*, t2.last_pre_map
    FROM tmp_1 t1
    JOIN tmp_2 t2
    ON t1.icustay_id = t1.icustay_id
)
select * from pre_bolus_map;


