/* Generate cohort view. This is the first view to be generated, upon which all
   other views are to be joined. */

-- Dependencies
\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql
\i map.sql

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
-- Aggregate map readings (and their times) before bolus:
-- max, min, average, last
), pre_bolus_map AS (

    SELECT
    FROM day1_map m
    INNER JOIN day1_bolus b
    ON m.




-- Aggregate map readings (and their times) after bolus:
-- max, min, average, first? last?
), post_bolus_map AS (

)


-- For each day1 bolus, join the day1 maps



with tmp_0 as (
  SELECT b.icustay_id, b.charttime AS bolus_time, b.bolus_volume
         , m.charttime AS map_time, m.itemid, m.valuenum AS map_value
  FROM day1_bolus b
  INNER JOIN day1_map m
  ON b.icustay_id = m.icustay_id
  ORDER BY icustay_id, map_time desc
)
SELECT DISTINCT ON (icustay_id) *
FROM tmp_0
WHERE map_time < bolus_time





-- Perhaps more logical to get max map before bolus?
