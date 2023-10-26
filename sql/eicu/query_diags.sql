DROP MATERIALIZED VIEW IF EXISTS icu_diags2 CASCADE;
CREATE MATERIALIZED VIEW icu_diags2 AS(
	WITH diags_10 AS(
		SELECT *, 
			CASE WHEN lower(diagnosisstring) LIKE '%cardiac arrest%' THEN 1
					 WHEN lower(diagnosisstring) LIKE '%sepsis%' AND icd9code != '518.81, J80' AND icd9code != '584.9, N17.9' THEN 2
					 WHEN lower(diagnosisstring) LIKE '%acute%respiratory failure%' AND icd9code != '038.9, 518.81, R65.20, J96.0' THEN 3
					 WHEN lower(diagnosisstring) LIKE '%septic shock%' THEN 4
					 WHEN lower(diagnosisstring) LIKE '%stroke%' THEN 5
					 WHEN lower(diagnosisstring) LIKE '%pneumonia%' THEN 6
					 WHEN lower(diagnosisstring) LIKE '%gi bleeding%' THEN 7
					 WHEN lower(diagnosisstring) LIKE '%heart failure%' AND icd9code != '038.9, 428.0, R65.20, I50.9' THEN 8
					 WHEN lower(diagnosisstring) LIKE '%acute respiratory distress%' THEN 9
					 WHEN lower(diagnosisstring) LIKE '%myocardial infarction%' 
								AND diagnosisstring != 'cardiovascular|chest pain / ASHD|myocardial infarction ruled out' THEN 10
					 WHEN lower(diagnosisstring) LIKE '%acute renal failure%' AND icd9code != '038.9, 584.9, R65.20, N17' THEN 11
	-- 				 WHEN lower(diagnosisstring) LIKE '%respiratory arrest%' THEN 12
	-- 				 WHEN lower(diagnosisstring) LIKE '%atrial fibrillation%' THEN 13
	-- 				 WHEN lower(diagnosisstring) LIKE '%subdural hematoma%' THEN 14
	-- 				 WHEN lower(diagnosisstring) LIKE '%copd%' THEN 15
	-- 				 WHEN icd9code = '427.1, I47.2' THEN 16
	-- 				 WHEN icd9code = '415.19, I26.99' THEN 17
					 ELSE 0 END AS diag
		FROM diag_first
	)

	, diags AS (
		SELECT df.patientunitstayid, df.label, df.diag, d.diagnosisstring, d.icd9code, d.diagnosispriority
		FROM diags_10 df
		LEFT JOIN diagnosis d ON df.patientunitstayid = d.patientunitstayid
	)
	-- 1 cardiac arrest
	, ca AS (
		SELECT patientunitstayid, 1 AS ca 
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%cardiac arrest%' GROUP BY patientunitstayid
	)
	-- 2 sepsis
	, seps AS (
		SELECT patientunitstayid, 1 AS seps 
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%sepsis%' AND icd9code != '518.81, J80' AND icd9code != '584.9, N17.9'
		GROUP BY patientunitstayid
	)
	-- 3 acute respiratory failure
	, arf AS (
		SELECT patientunitstayid, 1 AS arf 
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%acute%respiratory failure%' AND icd9code != '038.9, 518.81, R65.20, J96.0'
		GROUP BY patientunitstayid
	)
	-- 4 septic shock
	, ss AS (
		SELECT patientunitstayid, 1 AS ss
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%septic shock%' AND icd9code != '038.9, 518.81, R65.20, J96.0'
		GROUP BY patientunitstayid
	)
	-- 5 stroke
	, stk AS (
		SELECT patientunitstayid, 1 AS stk
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%stroke%'
		GROUP BY patientunitstayid
	)
	-- 6 pneumonia
	, pneu AS (
		SELECT patientunitstayid, 1 AS pneu
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%pneumonia%'
		GROUP BY patientunitstayid
	)
	-- 7 GI bleeding
	, gib AS (
		SELECT patientunitstayid, 1 AS gib
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%gi bleeding%'
		GROUP BY patientunitstayid
	)
	-- 8 heart failure
	, hf AS (
		SELECT patientunitstayid, 1 AS hf
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%heart failure%' AND icd9code != '038.9, 428.0, R65.20, I50.9'
		GROUP BY patientunitstayid
	)
	-- 9 acute respiratory distress
	, ard AS (
		SELECT patientunitstayid, 1 AS ard
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%acute respiratory distress%'
		GROUP BY patientunitstayid
	)
	-- 10 myocardial infarction
	, mi AS (
		SELECT patientunitstayid, 1 AS mi
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%myocardial infarction%' 
				AND diagnosisstring != 'cardiovascular|chest pain / ASHD|myocardial infarction ruled out'
		GROUP BY patientunitstayid
	)
	-- 11 acute renal failure
	, arenf AS (
		SELECT patientunitstayid, 1 AS arenf
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%acute renal failure%' AND icd9code != '038.9, 584.9, R65.20, N17'
		GROUP BY patientunitstayid
	)

	-- 12 respiratory arrest
	, respa AS (
		SELECT patientunitstayid, 1 AS respa
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%respiratory arrest%'
		GROUP BY patientunitstayid
	)

	-- 13 atrial fibrillation
	, atf AS (
		SELECT patientunitstayid, 1 AS atf
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%atrial fibrillation%'
		GROUP BY patientunitstayid
	)

	-- 14 subdural hematoma
	, suhe AS (
		SELECT patientunitstayid, 1 AS suhe
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%subdural hematoma%'
		GROUP BY patientunitstayid
	)

	-- 15 COPD
	, copd AS (
		SELECT patientunitstayid, 1 AS copd
		FROM diags 
		WHERE lower(diagnosisstring) LIKE '%copd%'
		GROUP BY patientunitstayid
	)

	-- 16 ventricular tachycardia
	, vt AS (
		SELECT patientunitstayid, 1 AS vt
		FROM diags 
		WHERE icd9code = '427.1, I47.2'
		GROUP BY patientunitstayid
	)

	-- 17 pulmonary embolism
	, pe AS (
		SELECT patientunitstayid, 1 AS pe
		FROM diags 
		WHERE icd9code = '415.19, I26.99'
		GROUP BY patientunitstayid
	)


	SELECT d.patientunitstayid, d.label, d.diag, d.diagnosisstring, d.icd9code
								, (CASE WHEN ca.ca IS NULL THEN 0 ELSE 1 END) as ca
								, (CASE WHEN seps.seps IS NULL THEN 0 ELSE 1 END) as seps
								, (CASE WHEN arf.arf IS NULL THEN 0 ELSE 1 END) as arf
								, (CASE WHEN ss.ss IS NULL THEN 0 ELSE 1 END) as ss
								, (CASE WHEN stk.stk IS NULL THEN 0 ELSE 1 END) as stk
								, (CASE WHEN pneu.pneu IS NULL THEN 0 ELSE 1 END) as pneu
								, (CASE WHEN gib.gib IS NULL THEN 0 ELSE 1 END) as gib
								, (CASE WHEN hf.hf IS NULL THEN 0 ELSE 1 END) as hf
								, (CASE WHEN ard.ard IS NULL THEN 0 ELSE 1 END) as ard
								, (CASE WHEN mi.mi IS NULL THEN 0 ELSE 1 END) as mi
								, (CASE WHEN arenf.arenf IS NULL THEN 0 ELSE 1 END) as arenf
								, (CASE WHEN respa.respa IS NULL THEN 0 ELSE 1 END) as ra
								, (CASE WHEN atf.atf IS NULL THEN 0 ELSE 1 END) as respa
								, (CASE WHEN suhe.suhe IS NULL THEN 0 ELSE 1 END) as suhe
								, (CASE WHEN copd.copd IS NULL THEN 0 ELSE 1 END) as copd
								, (CASE WHEN vt.vt IS NULL THEN 0 ELSE 1 END) as vt
								, (CASE WHEN pe.pe IS NULL THEN 0 ELSE 1 END) as pe
								, (COALESCE(ca.ca, 0) + COALESCE(seps.seps, 0) + COALESCE(arf.arf, 0) + COALESCE(ss.ss, 0) + 
									 COALESCE(stk.stk, 0) + COALESCE(pneu.pneu, 0) + COALESCE(gib.gib, 0) + COALESCE(hf.hf, 0) +
									 COALESCE(ard.ard, 0) + COALESCE(mi.mi, 0) + COALESCE(arenf.arenf, 0)) AS total
					FROM diags_10 d
					LEFT JOIN ca ON d.patientunitstayid = ca.patientunitstayid
					LEFT JOIN seps ON d.patientunitstayid = seps.patientunitstayid
					LEFT JOIN arf ON d.patientunitstayid = arf.patientunitstayid
					LEFT JOIN ss ON d.patientunitstayid = ss.patientunitstayid
					LEFT JOIN stk ON d.patientunitstayid = stk.patientunitstayid
					LEFT JOIN pneu ON d.patientunitstayid = pneu.patientunitstayid
					LEFT JOIN gib ON d.patientunitstayid = gib.patientunitstayid
					LEFT JOIN hf ON d.patientunitstayid = hf.patientunitstayid
					LEFT JOIN ard ON d.patientunitstayid = ard.patientunitstayid
					LEFT JOIN mi ON d.patientunitstayid = mi.patientunitstayid
					LEFT JOIN arenf ON d.patientunitstayid = arenf.patientunitstayid
					LEFT JOIN respa ON d.patientunitstayid = respa.patientunitstayid
					LEFT JOIN atf ON d.patientunitstayid = atf.patientunitstayid
					LEFT JOIN suhe ON d.patientunitstayid = suhe.patientunitstayid
					LEFT JOIN copd ON d.patientunitstayid = copd.patientunitstayid
					LEFT JOIN vt ON d.patientunitstayid = vt.patientunitstayid
					LEFT JOIN pe ON d.patientunitstayid = pe.patientunitstayid
					ORDER BY patientunitstayid
)

--SELECT diagnosisstring, icd9code FROM diagnosis WHERE LOWER(diagnosisstring) 
--LIKE '%diabetes%' GROUP BY diagnosisstring, icd9code
