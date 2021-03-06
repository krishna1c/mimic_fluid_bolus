-- Single script combining all components to create full extraction views

-- Demographics and times
\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql

-- map and bolus
\i map.sql
\i bolus.sql

-- Base cohort (uses map and bolus)
\i cohort.sql

-- Pressors
\i pressors.sql

-- Comorbidities
\i mimic-code/elixhauser-quan.sql
\i mimic-code/elixhauser-score-quan.sql

-- Sofa score. So many requirements, and based on full 24h. Maybe skip?
-- \i mimic-code/echo-data.sql
-- \i mimic-code/sofa.sql

-- Other vitals
\i vitals.sql

-- Urine
\i urine-output.sql

-- Combine all covariates into one view
\i combine-views.sql

-- Write csv
\i export-csv.sql
