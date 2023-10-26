DROP MATERIALIZED VIEW IF EXISTS features;
CREATE MATERIALIZED VIEW features AS (
		WITH lf AS (
				SELECT 
						patientunitstayid,
						ROUND((AVG(CASE WHEN hgb is NOT NULL THEN hgb ELSE NULL END))::numeric, 2) AS hgb,
						ROUND((AVG(CASE WHEN hct is NOT NULL THEN hct ELSE NULL END))::numeric, 2) AS hct,
						ROUND((AVG(CASE WHEN mch is NOT NULL THEN mch ELSE NULL END))::numeric, 2) AS mch,
						ROUND((AVG(CASE WHEN mchc is NOT NULL THEN mchc ELSE NULL END))::numeric, 2) AS mchc,
						ROUND((AVG(CASE WHEN mcv is NOT NULL THEN mcv ELSE NULL END))::numeric, 2) AS mcv,
						--ROUND((AVG(CASE WHEN mpv is NOT NULL THEN mch ELSE NULL END))::numeric, 2) AS mpv,
						ROUND((AVG(CASE WHEN platelets is NOT NULL THEN platelets ELSE NULL END))::numeric, 2) AS platelets,
						ROUND((AVG(CASE WHEN rbc is NOT NULL THEN rbc ELSE NULL END))::numeric, 2) AS rbc,
						ROUND((AVG(CASE WHEN rdw is NOT NULL THEN rdw ELSE NULL END))::numeric, 2) AS rdw,
						ROUND((AVG(CASE WHEN wbc is NOT NULL THEN wbc ELSE NULL END))::numeric, 2) AS wbc,
						--ROUND((AVG(CASE WHEN basophils is NOT NULL THEN basophils ELSE NULL END))::numeric, 2) AS basophils,
						--ROUND((AVG(CASE WHEN eosinophils is NOT NULL THEN eosinophils ELSE NULL END))::numeric, 2) AS eosinophils,
						--ROUND((AVG(CASE WHEN lymphocytes is NOT NULL THEN lymphocytes ELSE NULL END))::numeric, 2) AS lymphocytes,
						--ROUND((AVG(CASE WHEN monocytes is NOT NULL THEN monocytes ELSE NULL END))::numeric, 2) AS monocytes,
						
						ROUND((AVG(CASE WHEN inr is NOT NULL THEN inr ELSE NULL END))::numeric, 2) AS inr,
						ROUND((AVG(CASE WHEN pt is NOT NULL THEN pt ELSE NULL END))::numeric, 2) AS pt,
						ROUND((AVG(CASE WHEN ptt is NOT NULL THEN ptt ELSE NULL END))::numeric, 2) AS ptt,
						
						ROUND((AVG(CASE WHEN ph is NOT NULL THEN ph ELSE NULL END))::numeric, 2) AS ph,
						--ROUND((AVG(CASE WHEN albumin is NOT NULL THEN albumin ELSE NULL END))::numeric, 2) AS albumin,
						--ROUND((AVG(CASE WHEN total_protein is NOT NULL THEN total_protein ELSE NULL END))::numeric, 2) AS total_protein,
						ROUND((AVG(CASE WHEN aniongap is NOT NULL THEN aniongap ELSE NULL END))::numeric, 2) AS aniongap,
						ROUND((AVG(CASE WHEN bicarbonate is NOT NULL THEN bicarbonate ELSE NULL END))::numeric, 2) AS bicarbonate,
						ROUND((AVG(CASE WHEN phosphate is NOT NULL THEN phosphate ELSE NULL END))::numeric, 2) AS phosphate,
						--ROUND((AVG(CASE WHEN lactate is NOT NULL THEN lactate ELSE NULL END))::numeric, 2) AS lactate,
						ROUND((AVG(CASE WHEN BUN is NOT NULL THEN BUN ELSE NULL END))::numeric, 2) AS BUN,
						ROUND((AVG(CASE WHEN calcium is NOT NULL THEN calcium ELSE NULL END))::numeric, 2) AS calcium,
						ROUND((AVG(CASE WHEN chloride is NOT NULL THEN chloride ELSE NULL END))::numeric, 2) AS chloride,
						ROUND((AVG(CASE WHEN creatinine is NOT NULL THEN creatinine ELSE NULL END))::numeric, 2) AS creatinine,
						ROUND((AVG(CASE WHEN glucose is NOT NULL THEN glucose ELSE NULL END))::numeric, 2) AS glucose,
						ROUND((AVG(CASE WHEN sodium is NOT NULL THEN sodium ELSE NULL END))::numeric, 2) AS sodium,
						ROUND((AVG(CASE WHEN potassium is NOT NULL THEN potassium ELSE NULL END))::numeric, 2) AS potassium,
						ROUND((AVG(CASE WHEN magnesium is NOT NULL THEN magnesium ELSE NULL END))::numeric, 2) AS magnesium,
						
						--ROUND((AVG(CASE WHEN alt is NOT NULL THEN alt ELSE NULL END))::numeric, 2) AS alt,
						--ROUND((AVG(CASE WHEN alp is NOT NULL THEN alp ELSE NULL END))::numeric, 2) AS alp,
						--ROUND((AVG(CASE WHEN ast is NOT NULL THEN ast ELSE NULL END))::numeric, 2) AS ast,
						--ROUND((AVG(CASE WHEN bilirubin_total is NOT NULL THEN bilirubin_total ELSE NULL END))::numeric, 2) AS bilirubin_total,
						
						--ROUND((AVG(CASE WHEN fio2 is NOT NULL THEN fio2 ELSE NULL END))::numeric, 2) AS fio2,
						ROUND((AVG(CASE WHEN base_excess is NOT NULL THEN base_excess ELSE NULL END))::numeric, 2) AS base_excess,
						ROUND((AVG(CASE WHEN total_co2 is NOT NULL THEN total_co2 ELSE NULL END))::numeric, 2) AS total_co2,
						ROUND((AVG(CASE WHEN paco2 is NOT NULL THEN paco2 ELSE NULL END))::numeric, 2) AS paco2,
						ROUND((AVG(CASE WHEN pao2 is NOT NULL THEN pao2 ELSE NULL END))::numeric, 2) AS pao2		
				FROM lab_features 
				GROUP BY patientunitstayid
		), vs AS (
				SELECT 
						patientunitstayid,
						ROUND((AVG(CASE WHEN heartrate is NOT NULL THEN heartrate ELSE NULL END))::numeric, 2) AS heartrate,
						ROUND((AVG(CASE WHEN ibp_systolic is NOT NULL THEN ibp_systolic ELSE NULL END))::numeric, 2) AS sbp,
						ROUND((AVG(CASE WHEN ibp_diastolic is NOT NULL THEN ibp_diastolic ELSE NULL END))::numeric, 2) AS dbp,
						ROUND((AVG(CASE WHEN ibp_mean is NOT NULL THEN ibp_mean ELSE NULL END))::numeric, 2) AS mbp,
						ROUND((AVG(CASE WHEN nibp_systolic is NOT NULL THEN nibp_systolic ELSE NULL END))::numeric, 2) AS sbp_ni,
						ROUND((AVG(CASE WHEN nibp_diastolic is NOT NULL THEN nibp_diastolic ELSE NULL END))::numeric, 2) AS dbp_ni,
						ROUND((AVG(CASE WHEN nibp_mean is NOT NULL THEN nibp_mean ELSE NULL END))::numeric, 2) AS mbp_ni,
						ROUND((AVG(CASE WHEN respiratoryrate is NOT NULL THEN respiratoryrate ELSE NULL END))::numeric, 2) AS resp_rate,
						ROUND((AVG(CASE WHEN temperature is NOT NULL THEN temperature ELSE NULL END))::numeric, 2) AS temperature,
						ROUND((AVG(CASE WHEN spo2 is NOT NULL THEN spo2 ELSE NULL END))::numeric, 2) AS spo2
				FROM vital_signs
				GROUP BY patientunitstayid
		)
		SELECT 
				icd.patientunitstayid,
				--icd.gender,
				--icd.age,
				--ROUND((icd.icu_los_hours / 24)::numeric, 2) AS icu_los,
				--icd.hosp_mort AS "label",
				--icd.admissionheight AS heght,
				--icd.admissionweight AS weight,
				
				lf.hgb, 
				lf.hct,
				lf.mch,
				lf.mchc,
				lf.mcv,
				--lf.mpv,
				lf.platelets,
				lf.rbc,
				lf.rdw,
				lf.wbc,
				--lf.basophils,
				--lf.eosinophils,
				--lf.lymphocytes,
				--lf.monocytes,
				
				lf.inr,
				lf.pt,
				lf.ptt,
				
				lf.ph,
				--lf.albumin,
				--lf.total_protein,
				lf.aniongap,
				lf.bicarbonate,
				lf.phosphate,
				--lf.lactate,
				lf.bun,
				lf.calcium,
				lf.chloride,
				lf.creatinine,
				lf.glucose,
				lf.sodium,
				lf.potassium,
				lf.magnesium,
				
				--lf.alt,
				--lf.alp,
				--lf.ast,
				--lf.bilirubin_total,
				
				--lf.fio2,
				lf.base_excess,
				lf.total_co2,
				lf.paco2,
				lf.pao2,
				
				vs.heartrate,
				vs.sbp,
				vs.dbp,
				vs.mbp,
				vs.sbp_ni,
				vs.dbp_ni,
				vs.mbp_ni,
				vs.resp_rate,
				vs.temperature,
				vs.spo2
				
		FROM icustay_detail icd
		LEFT JOIN lf ON icd.patientunitstayid = lf.patientunitstayid
		LEFT JOIN vs ON icd.patientunitstayid = vs.patientunitstayid
);