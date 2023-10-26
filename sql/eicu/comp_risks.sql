DROP MATERIALIZED VIEW IF EXISTS comp_risks_pats;
CREATE MATERIALIZED VIEW comp_risks_pats AS (

		WITH arf AS (
				SELECT patientunitstayid, 1 AS acute_resp_failure, 
				(CASE WHEN diagnosispriority = 'Primary' THEN 0 
							WHEN diagnosispriority = 'Major' THEN 1 
							ELSE 2 END) AS prior1
				FROM "diagnosis" WHERE diagnosisstring LIKE '%acute respiratory failure%'	
				
		), aref AS (
				SELECT patientunitstayid, 1 AS acute_renal_failure, 
				(CASE WHEN diagnosispriority = 'Primary' THEN 0 
							WHEN diagnosispriority = 'Major' THEN 1 ELSE 2 END) AS prior2
				FROM "diagnosis" WHERE diagnosisstring LIKE '%acute renal failure%'
						
		), pneu AS (
				SELECT patientunitstayid, 1 AS pneu, 
				(CASE WHEN diagnosispriority = 'Primary' THEN 0 
							WHEN diagnosispriority = 'Major' THEN 1 ELSE 2 END) AS prior3		
				 FROM "diagnosis" WHERE diagnosisstring LIKE '%pneumonia%'
							 
		), risks AS (
				SELECT patient.patientunitstayid,
						(CASE WHEN arf.acute_resp_failure IS NULL THEN 0 ELSE 1 END) AS acute_resp_failure,
						(CASE WHEN aref.acute_renal_failure IS NULL THEN 0 ELSE 1 END) AS acute_renal_failure,
						(CASE WHEN pneu.pneu IS NULL THEN 0 ELSE 1 END) AS pneu,
						(COALESCE(acute_resp_failure, 0) + COALESCE(acute_renal_failure, 0) + COALESCE(pneu, 0)) AS total,
						(CASE WHEN prior1 IS NULL THEN 99999 ELSE prior1 END) AS prior1,
						(CASE WHEN prior2 IS NULL THEN 99999 ELSE prior2 END) AS prior2,
						(CASE WHEN prior3 IS NULL THEN 99999 ELSE prior3 END) AS prior3
				FROM patient
				LEFT JOIN arf ON arf.patientunitstayid = patient.patientunitstayid
				LEFT JOIN aref ON aref.patientunitstayid = patient.patientunitstayid
				LEFT JOIN pneu ON pneu.patientunitstayid = patient.patientunitstayid
		)
		SELECT r.*,
				icu.gender, icu.age, icu_los_hours AS icu_stay,
				icu.hosp_mort, icu.hospitaldischargeoffset,
				CASE WHEN icu.admissionweight IS NOT NULL AND icu.admissionweight > 40 AND admissionweight < 150 THEN icu.admissionweight
						 WHEN icu.dischargeweight IS NOT NULL AND icu.dischargeweight > 40 AND dischargeweight < 150 THEN icu.dischargeweight
						 ELSE NULL END AS weight,
				CASE WHEN admissionheight >= 130 THEN icu.admissionheight ELSE NULL END AS height
				FROM risks r
				LEFT JOIN icustay_detail icu ON r.patientunitstayid = icu.patientunitstayid
				WHERE total > 1
				--AND (prior1 = 0 OR prior2 = 0 OR prior3 = 0)
)


