-- Single script combining all components to create full extraction views

-- Demographics and times
\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql

-- map and bolus
\i map.sql
\i bolus.sql

-- Base cohort
\i cohort.sql

-- Pressors
\i pressors.sql

-- Comorbidities
\i mimic-code/elixhauser-quan.sql
\i mimic-code/elixhauser-score-quan.sql

-- Sofa score
\i mimic-code/echo-data.sql
\i mimic-code/sofa.sql

-- Other vitals
\i mimic-code/vitals-first-day.sql

-- Urine
\i mimic-code/urine-output-first-day.sql

-- Combine all covariates into one view
\i combine-views.sql

-- Write csv
-- \i export-csv.sql
