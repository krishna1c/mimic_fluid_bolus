-- Script to explore itemids to use for extracting bolus fluids



-- We are looking for all crystalloid solutions.
-- https://en.wikipedia.org/wiki/Volume_expander



-- Part 1a. Explore metavision structure
SELECT itemid, label, abbreviation, linksto, category, unitname, param_type
FROM d_items
WHERE linksto LIKE 'inputevents_mv'
LIMIT 20;

-- Check categories of mv
-- All mv items have a category
SELECT count(*)
FROM d_items
WHERE linksto LIKE 'inputevents_mv'
AND category IS Null; -- 0

-- All mv categories
SELECT DISTINCT(category)
FROM d_items
WHERE linksto LIKE 'inputevents_mv';
/*
          category
-----------------------------
 Medications
 Nutrition - Parenteral
 Blood Products/Colloids
 Nutrition - Enteral
 Nutrition - Supplements
 Fluids - Other (Not In Use)
 Antibiotics
 Fluids/Intake
(8 rows)
*/

-- Check whether 'Fluids - Other (Not In Use)' really doesn't exist
WITH nui AS(
    SELECT itemid
    FROM d_items
    WHERE category LIKE 'Fluids - Other (Not In Use)'
)
SELECT *
FROM inputevents_mv ie
inner JOIN nui
ON ie.itemid=nui.itemid;
-- 0 rows.
-- Conclusion: Search d_items with categori Fluids/Intake


SELECT itemid, label, abbreviation, linksto, category, unitname, param_type
FROM d_items
WHERE linksto LIKE 'inputevents_mv'
AND category LIKE 'Fluids/Intake';
/*
 itemid |             label             |         abbreviation          |    linksto     |   category    | unitname | param_type
--------+-------------------------------+-------------------------------+----------------+---------------+----------+------------
 220952 | Dextrose 50%                  | Dextrose 50%                  | inputevents_mv | Fluids/Intake | mL       | Solution
 228341 | NaCl 23.4%                    | NaCl 23.4%                    | inputevents_mv | Fluids/Intake | mL       | Solution
 225797 | Free Water                    | Free Water                    | inputevents_mv | Fluids/Intake | mL       | Solution
 225799 | Gastric Meds                  | Gastric Meds                  | inputevents_mv | Fluids/Intake | mL       | Solution
 225823 | D5 1/2NS                      | D5 1/2NS                      | inputevents_mv | Fluids/Intake | mL       | Solution
 225825 | D5NS                          | D5NS                          | inputevents_mv | Fluids/Intake | mL       | Solution
 225827 | D5LR                          | D5LR                          | inputevents_mv | Fluids/Intake | mL       | Solution
 225828 | LR                            | LR                            | inputevents_mv | Fluids/Intake | mL       | Solution
 225830 | Multivitamins                 | Multivitamins                 | inputevents_mv | Fluids/Intake | mL       | Solution
 227533 | Sodium Bicarbonate 8.4% (Amp) | Sodium Bicarbonate 8.4% (Amp) | inputevents_mv | Fluids/Intake | mL       | Solution
 226089 | Piggyback                     | Piggyback                     | inputevents_mv | Fluids/Intake | mL       | Solution
 225941 | D5 1/4NS                      | D5 1/4NS                      | inputevents_mv | Fluids/Intake | mL       | Solution
 225943 | Solution                      | Solution                      | inputevents_mv | Fluids/Intake | mL       | Solution
 225944 | Sterile Water                 | Sterile Water                 | inputevents_mv | Fluids/Intake | mL       | Solution
 228140 | Dextrose 20%                  | Dextrose 20%                  | inputevents_mv | Fluids/Intake | mL       | Solution
 228141 | Dextrose 30%                  | Dextrose 30%                  | inputevents_mv | Fluids/Intake | mL       | Solution
 228142 | Dextrose 40%                  | Dextrose 40%                  | inputevents_mv | Fluids/Intake | mL       | Solution
 220949 | Dextrose 5%                   | Dextrose 5%                   | inputevents_mv | Fluids/Intake | mL       | Solution
 220950 | Dextrose 10%                  | Dextrose 10%                  | inputevents_mv | Fluids/Intake | mL       | Solution
 225158 | NaCl 0.9%                     | NaCl 0.9%                     | inputevents_mv | Fluids/Intake | mL       | Solution
 225159 | NaCl 0.45%                    | NaCl 0.45%                    | inputevents_mv | Fluids/Intake | mL       | Solution
 225161 | NaCl 3% (Hypertonic Saline)   | NaCl 3% (Hypertonic Saline)   | inputevents_mv | Fluids/Intake | mL       | Solution
 225162 | Prismasate K2                 | Prismasate K2                 | inputevents_mv | Fluids/Intake | mL       | Solution
 225163 | Prismasate K4                 | Prismasate K4                 | inputevents_mv | Fluids/Intake | mL       | Solution
 225164 | Trisodium Citrate 0.4%        | Trisodium Citrate 0.4%        | inputevents_mv | Fluids/Intake | mL       | Solution
 225165 | Bicarbonate Base              | Bicarbonate Base              | inputevents_mv | Fluids/Intake | mL       | Solution
 226361 | Pre-Admission Intake          | Pre-Admission Intake          | inputevents_mv | Fluids/Intake | mL       | Solution
 226362 | ZGastric/TF Residual Intake   | ZGastric/TF Residual Intake   | inputevents_mv | Fluids/Intake | mL       | Solution
 226363 | Cath Lab Intake               | Cath Lab Intake               | inputevents_mv | Fluids/Intake | mL       | Solution
 226364 | OR Crystalloid Intake         | OR Crystalloid Intake         | inputevents_mv | Fluids/Intake | mL       | Solution
 226375 | PACU Crystalloid Intake       | PACU Crystalloid Intake       | inputevents_mv | Fluids/Intake | mL       | Solution
 226377 | PACU PO Intake                | PACU PO Intake                | inputevents_mv | Fluids/Intake | mL       | Solution
 226401 | GU Irrigant - Normal Saline   | GU Irrigant - Normal Saline   | inputevents_mv | Fluids/Intake | mL       | Solution
 226402 | GU Irrigant - Sterile Water   | GU Irrigant - Sterile Water   | inputevents_mv | Fluids/Intake | mL       | Solution
 226403 | GU Irrigant - Amphotericin B  | GU Irrigant - Amphotericin B  | inputevents_mv | Fluids/Intake | mL       | Solution
 226452 | PO Intake                     | PO Intake                     | inputevents_mv | Fluids/Intake | mL       | Solution
 226453 | GT Flush                      | GT Flush                      | inputevents_mv | Fluids/Intake | mL       | Solution
(37 rows)
*/




-- Part 1b. Explore carevue structure
SELECT itemid, label, abbreviation, linksto, category, unitname, param_type
FROM d_items
WHERE linksto LIKE 'inputevents_cv'
LIMIT 20;

-- Check categories of cv
-- Many cv items don't have a category
SELECT count(*)
FROM d_items
WHERE linksto LIKE 'inputevents_cv'
AND category IS Null; -- 693

-- Check out item category distribution
-- Seems like they'll have to be looked over, with some filters.
SELECT category, COUNT(category)
FROM d_items
WHERE linksto LIKE 'inputevents_cv'
GROUP BY category;
/*
     category     | count
------------------+-------
                  |     0
 Meds             |     1
 NG Feeding       |     1
 Free Form Intake |  2243
(4 rows)

Plus the 693 null rows
*/


-- More Intricate search
SELECT itemid, label, abbreviation, linksto, category, unitname, param_type
FROM d_items
WHERE label ILIKE '%crystal%'
AND linksto LIKE 'inputevents_cv%'
ORDER BY linksto;




-- Matthieu Komorowski's Crystalloid Codes:
SELECT hadm_id, icustay_id, charttime, itemid, amount, amountuom, rate, rateuom
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
LIMIT 20;








------------------------------------------------------------------------------
-- Part 2a: Figure out columns/units to use for volume - carevue
------------------------------------------------------------------------------

-- 4 potential columns: amount, rate, originalamount, originalrate
SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND amount IS NOT NULL;
--  5718082 amounts

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND rate IS NOT NULL;
-- 0 rates

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND originalamount IS NOT NULL;
-- 4940436 originalamounts

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND originalrate IS NOT NULL;
-- 2687870 originalrates



-- Quantify the venn-diagram of the three measurements:
-- amount, originalamount, originalamountrate

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND amount IS NOT NULL
AND originalamount IS NOT NULL
AND originalrate IS NOT NULL;
-- 2216801

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND amount IS NOT NULL
AND originalamount IS NULL
AND originalrate IS NULL;
-- 498916

SELECT COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND amount IS NULL
AND originalamount IS NOT NULL
AND originalrate IS NULL;
-- 104513

SELECT * -- COUNT(*)
FROM inputevents_cv
WHERE itemid IN (30013, 220949, 30187, 30016, 30317, 30318, 220952, 220950,
                 30018, 30296, 30190, 225158, 225943, 226089, 30021, 225828,
                 227533, 30020, 225159, 30160, 225823, 225825, 225827, 225941,
                 225823, 30159, 30143, 225161, 30061, 30015, 30060, 30030,
                 220995)
AND amount IS NULL
AND originalamount IS NULL
AND originalrate IS NOT NULL;
-- 6818





------------------------------------------------------------------------------
-- Part 2b: Figure out columns/units to use for volume - metavision
------------------------------------------------------------------------------

-- Explore distribution
SELECT
    icustay_id
    , starttime, endtime
    , EXTRACT(EPOCH FROM (endtime - starttime)) / 60 as duration_minutes
    -- standardize the units to millilitres
    -- also metavision has floating point precision.. but we only care down to the mL
    , amount, amountuom, rate, rateuom
FROM inputevents_mv
WHERE itemid IN
(
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
)
AND statusdescription != 'Rewritten'
LIMIT 500;
-- Weird case: icustayid=217863 amount=7.




AND
-- in MetaVision, these ITEMIDs appear with a null rate IFF endtime=starttime + 1 minute
-- so it is sufficient to:
--    (1) check the rate is > 240 if it exists or
--    (2) ensure the rate is null and amount > 240 ml
(
  (rate is not null and rateuom = 'mL/hour' and rate > 248)
  OR (rate is not null and rateuom = 'mL/min' and rate > (248/60.0))
  OR (rate is null and amountuom = 'L' and amount > 0.248)
  OR (rate is null and amountuom = 'ml' and amount > 248)
);






-- Inspect unit distribution

SELECT amountuom, COUNT(*)
FROM inputevents_mv
WHERE itemid IN (
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
)
GROUP BY amountuom;
/*
 amountuom | count
-----------+--------
 L         |      2
 ml        | 632154
*/


SELECT rateuom, COUNT(*)
FROM inputevents_mv
WHERE itemid IN (
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
)
GROUP BY rateuom;
/*
 rateuom | count
---------+--------
         |  76861
 mL/min  |     62
 mL/hour | 555233
*/


SELECT COUNT(*)
FROM inputevents_mv
WHERE itemid IN (
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
)
AND rate IS NOT NULL
AND rateuom IS NULL;
-- 0

