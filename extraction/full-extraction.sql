-- Single script combining all components to create full extraction views

\i mimic-code/icustay-detail.sql
\i mimic-code/HeightWeightQuery.sql
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

-- Combine all covariates into one view
\i combine-views.sql

-- Write csv
-- \i export-csv.sql
