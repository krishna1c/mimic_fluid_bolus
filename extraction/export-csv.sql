COPY (SELECT * FROM final)
TO '/home/cx1111/Projects/mimic_fluid_bolus/data/design-matrix.csv'
DELIMITER ',' CSV HEADER;
