-- Create final combined view

DROP MATERIALIZED VIEW IF EXISTS final;
CREATE MATERIALIZED VIEW final AS
       -- demographics and basic
SELECT c.icustay_id, c.gender, c.ethnicity_group, c.hospital_expire_flag
       , c.height, c.weight, c.bolus_volume
       -- vitals
       , c.last_map_pre, v.heartrate_min
       , v.heartrate_max, v.heartrate_mean, v.sysbp_min, v.sysbp_max
       , v.sysbp_mean, v.diasbp_min, v.diasbp_max, v.diasbp_mean, v.meanbp_min
       , v.meanbp_max, v.meanbp_mean, v.resprate_min, v.resprate_max
       , v.resprate_mean, v.tempc_min, v.tempc_max, v.tempc_mean, v.spo2_min
       , v.spo2_max, v.spo2_mean, v.glucose_min, v.glucose_mean
       -- pressors
       , p.pressor_duration_pre, p.pressor_duration_post
       -- comorbidity score
       , e.elixhauser_sid30
       -- sofa score? Maybe ignore because too aggregate...

       -- urine - need to fill in rows without values
       , COALESCE(u.urineoutput, 0) AS urine_output
       -- The outcome
       , c.max_map_post
FROM cohort c
-- Vitals
LEFT JOIN vitals v
ON c.icustay_id = v.icustay_id
-- pressors
LEFT JOIN pressors p
ON c.icustay_id = p.icustay_id
-- comorbidity score
LEFT JOIN elixhauser_quan_score e
ON c.hadm_id = e.hadm_id
-- Urine output
LEFT JOIN urine_output u
ON c.icustay_id = u.icustay_id
ORDER BY icustay_id;
