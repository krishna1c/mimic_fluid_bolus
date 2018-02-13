/* Get pressor duration 1h before and after bolus.
   Linearly sum time of multiple simultaneous pressors */

-- Dependencies
\i cohort.sql

DROP MATERIALIZED VIEW IF EXISTS pressors;
CREATE MATERIALIZED VIEW pressors AS
-- Join cohort with bolus to pressors
WITH pressors AS (
    SELECT c.icustay_id, c.bolus_time, v.starttime, v.endtime
    FROM cohort c
    LEFT JOIN vasopressordurations v
    ON c.icustay_id = v.icustay_id
), pre_bolus_pressors AS (
    -- Get items with at least some overlap with the 1h window before the bolus
    WITH t0 AS (
        SELECT *
        FROM pressors
        WHERE starttime < bolus_time
        AND endtime > bolus_time - interval '1 hour'
    -- Truncate the pressor durations to the preceeding 1h window
    ), t1 AS (
        SELECT icustay_id, GREATEST(starttime, bolus_time - interval '1 hour') AS starttime
               , LEAST(endtime, bolus_time) AS endtime
        FROM t0
    -- Add up the durations in minutes
    )
    SELECT icustay_id, SUM(EXTRACT(EPOCH FROM(endtime - starttime) / 60)) AS pressor_duration_pre
    FROM t1
    GROUP BY icustay_id
), post_bolus_pressors AS (
    -- Get items with at least some overlap with the 1h window before the bolus
    WITH t0 AS (
        SELECT *
        FROM pressors
        WHERE starttime < bolus_time + interval '1 hour'
        AND endtime > bolus_time
    -- Truncate the pressor durations to the proceeding 1h window
    ), t1 AS (
        SELECT icustay_id, GREATEST(starttime, bolus_time) AS starttime
               , LEAST(endtime, bolus_time + interval '1 hour') AS endtime
        FROM t0
    -- Add up the durations in minutes
    )
    SELECT icustay_id, SUM(EXTRACT(EPOCH FROM(endtime - starttime) / 60)) AS pressor_duration_post
    FROM t1
    GROUP BY icustay_id
)
SELECT c.icustay_id
       , COALESCE(pr.pressor_duration_pre, 0) AS pressor_duration_pre
       , COALESCE(po.pressor_duration_post, 0) AS pressor_duration_post
FROM cohort c
LEFT JOIN pre_bolus_pressors pr
ON c.icustay_id = pr.icustay_id
LEFT JOIN post_bolus_pressors po
ON c.icustay_id = po.icustay_id
ORDER BY icustay_id;
