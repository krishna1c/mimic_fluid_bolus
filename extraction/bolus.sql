-- Crystalloid Bolus
DROP TABLE IF EXISTS crystalloid_bolus CASCADE;

CREATE TABLE crystalloid_bolus AS
-- metavision
with t1 as
(
  select
    mv.icustay_id
  , mv.starttime as charttime
  -- standardize the units to millilitres
  -- also metavision has floating point precision.. but we only care down to the mL
  , round(case
      when mv.amountuom = 'L'
        then mv.amount * 1000.0
      when mv.amountuom = 'ml'
        then mv.amount
    else null end) as amount
  from inputevents_mv mv
  where mv.itemid in
  (
    -- 225943 Solution
    225158, -- NaCl 0.9%
    225828, -- LR
    225944, -- Sterile Water
    225797  -- Free Water
  )
  and mv.statusdescription != 'Rewritten'
  and
  -- in MetaVision, these ITEMIDs appear with a null rate IFF endtime=starttime + 1 minute
  -- so it is sufficient to:
  --    (1) check the rate is > 240 if it exists or
  --    (2) ensure the rate is null and amount > 240 ml
    (
      (mv.rate is not null and mv.rateuom = 'mL/hour' and mv.rate > 248)
      OR (mv.rate is not null and mv.rateuom = 'mL/min' and mv.rate > (248/60.0))
      OR (mv.rate is null and mv.amountuom = 'L' and mv.amount > 0.248)
      OR (mv.rate is null and mv.amountuom = 'ml' and mv.amount > 248)
    )
)
select
    icustay_id
  , charttime
  , sum(amount) as crystalloid_bolus
from t1
-- just because the rate was high enough, does *not* mean the final amount was
where amount > 248
group by t1.icustay_id, t1.charttime;
