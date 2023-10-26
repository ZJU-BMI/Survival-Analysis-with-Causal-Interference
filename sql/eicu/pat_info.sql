DROP MATERIALIZED VIEW IF EXISTS pat_info CASCADE;
CREATE MATERIALIZED VIEW pat_info AS(
	WITH pat_detail AS (
		SELECT patientunitstayid, age, gender, ethnicity
		, CASE WHEN admissionheight < 120 THEN NULL ELSE admissionheight END AS height
		, CASE WHEN admissionweight IS NOT NULL AND dischargeweight IS NOT NULL 
								THEN ROUND(((admissionweight + dischargeweight) / 2)::numeric, 2)
					 WHEN admissionweight IS NULL AND dischargeweight IS NOT NULL THEN dischargeweight
					 WHEN admissionweight IS NOT NULL AND dischargeweight IS NULL THEN admissionweight
					 ELSE NULL END AS weight
		, icu_los_hours AS tte
		FROM icustay_detail WHERE (age <= 89 OR age IS NULL)
	)

	-- 1228 without tte, 24279 remained
	SELECT 
		d.patientunitstayid, d.label, FLOOR(de.tte / 6) AS tte, d.diag
		, d.ca, d.seps, d.arf, d.ss, d.stk, d.pneu, d.gib, d.hf, d.ard, d.mi, d.arenf
		, d.ra, d.respa, d.suhe, d.copd, d.vt, d.pe
		, de.age, de.gender, de.ethnicity, 
		CASE WHEN de.weight > 30 AND de.weight < 200 THEN de.weight ELSE NULL END AS weight
		, CASE WHEN de.height > 120 AND de.height < 250 THEN de.height ELSE NULL END AS height
		, ROUND((de.weight * 10000 / (de.height * de.height)), 2) AS bmi
	 FROM icu_diags d
	 LEFT JOIN pat_detail de ON d.patientunitstayid = de.patientunitstayid
	 WHERE total = 1 AND diag > 0 AND tte IS NOT NULL
 )