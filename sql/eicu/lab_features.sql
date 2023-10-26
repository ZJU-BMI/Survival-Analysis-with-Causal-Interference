DROP MATERIALIZED VIEW IF EXISTS lab_features CASCADE;
CREATE MATERIALIZED VIEW lab_features AS (
		WITH vw0 AS (
				SELECT
						patientunitstayid,
						labname,
						labresultoffset,
						labresultrevisedoffset
				FROM lab 
				WHERE labname IN (
						'Hgb',
						'Hct',
						'MCH',
						'MCHC',
						'MCV',
						'MPV',
						'platelets x 1000',
						'RBC',
						'RDW',
						'WBC x 1000',
						
						'-basos',
						'-eos',
						'-lymphs',
						'-monos',
						'-polys',
						
						'PT - INR',
						'PT',
						'PTT',
						
						'pH',
						'albumin', --g/dL
						'total protein', -- g/dL
						'anion gap',
						'bicarbonate',
						'phosphate',
						'lactate',
						'BUN',
						'calcium',
						'chloride',
						'creatinine',
						'glucose', 'bedside glucose',
						'sodium',
						'potassium',
						'magnesium',
						
						'ALT (SGPT)',
						'alkaline phos.' 
						'AST (SGOT)',
						'total bilirubin',
						-- 'CPK',
						-- 'CPK-MB',
						
						'FiO2',
						'Base Excess',
						'Total CO2',
						'paCO2',
						'paO2'			
				) 
				GROUP BY
					patientunitstayid,
					labname,
					labresultoffset,
					labresultrevisedoffset 
				HAVING
					COUNT ( DISTINCT labresult ) <= 1 
		)
		, vw1 AS (
				SELECT
						lab.patientunitstayid,
						lab.labname,
						FLOOR((lab.labresultoffset / 360)::numeric) AS "time",
						lab.labresultrevisedoffset,
						lab.labresult,
 						ROW_NUMBER () OVER (PARTITION BY lab.patientunitstayid, lab.labname, lab.labresultoffset 
 								ORDER BY lab.labresultrevisedoffset DESC) AS rn 
				FROM lab
				INNER JOIN vw0 ON lab.patientunitstayid = vw0.patientunitstayid 
						AND lab.labname = vw0.labname 
						AND lab.labresultoffset = vw0.labresultoffset 
						AND lab.labresultrevisedoffset = vw0.labresultrevisedoffset
				WHERE
						(lab.labname = 'Hct' AND lab.labresult > 5 AND lab.labresult < 40) 
						OR (lab.labname = 'Hgb' AND lab.labresult > 0 AND lab.labresult < 30) 
						OR (lab.labname = 'MCH' AND lab.labresult > 10 AND lab.labresult < 36) 
						OR (lab.labname = 'MCHC' AND lab.labresult > 10 AND lab.labresult < 36) 
						OR (lab.labname = 'MCV' AND lab.labresult > 60 AND lab.labresult < 120) 
						OR (lab.labname = 'MPV' AND lab.labresult > 0 AND lab.labresult < 50) 
						OR (lab.labname = 'platelets x 1000' AND lab.labresult > 50 AND lab.labresult < 500)
						OR (lab.labname = 'RBC' AND lab.labresult > 0 AND lab.labresult < 10.0) 
						OR (lab.labname = 'RDW' AND lab.labresult > 0 AND lab.labresult < 50) 
						OR (lab.labname = 'WBC x 1000' AND lab.labresult > 0 AND lab.labresult <= 50)
						
						OR (lab.labname = '-basos' AND lab.labresult > 0 AND lab.labresult < 14) 
						OR (lab.labname = '-eos' AND lab.labresult > 0 AND lab.labresult < 25) 
						OR (lab.labname = '-lymphs' AND lab.labresult > 0.5 AND lab.labresult < 45) 
						OR (lab.labname = '-monos' AND lab.labresult > 0.5 AND lab.labresult < 25) 
						OR (lab.labname = '-polys' AND lab.labresult > 0.5 AND lab.labresult < 25) 
					
						OR (lab.labname = 'PT - INR' AND lab.labresult > 0 AND lab.labresult < 5)
						OR (lab.labname = 'PT' AND lab.labresult > 0 AND lab.labresult < 30) 
						OR (lab.labname = 'PTT' AND lab.labresult > 15 AND lab.labresult < 100) 
						
						
						OR (lab.labname = 'pH' AND lab.labresult > 6.5 AND lab.labresult < 9) 
						OR (lab.labname = 'albumin' AND lab.labresult >= 0.5 AND lab.labresult < 6.5)
						OR (lab.labname = 'total protein' AND lab.labresult > 0 AND lab.labresult < 100)
						OR (lab.labname = 'anion gap' AND lab.labresult > 0 AND lab.labresult < 30)
						OR (lab.labname = 'bicarbonate' AND lab.labresult > 10 AND lab.labresult < 50) 
						OR (lab.labname = 'phosphate' AND lab.labresult > 0 AND lab.labresult < 10)
						OR (lab.labname = 'lactate' AND lab.labresult > 0.1 AND lab.labresult < 30) 
						OR (lab.labname = 'BUN' AND lab.labresult > 0 AND lab.labresult < 80) 
						OR (lab.labname = 'calcium' AND lab.labresult > 2 AND lab.labresult < 15) 
						OR (lab.labname = 'chloride' AND lab.labresult > 30 AND lab.labresult < 200) 
						OR (lab.labname = 'creatinine' AND lab.labresult > 0 AND lab.labresult < 5)
						OR (lab.labname IN ( 'bedside glucose', 'glucose' ) AND lab.labresult > 50 AND lab.labresult < 300) 
						OR (lab.labname = 'sodium' AND lab.labresult > 80 AND lab.labresult < 300) 
						OR (lab.labname = 'potassium' AND lab.labresult > 0 AND lab.labresult < 10.0) 
						OR (lab.labname = 'magnesium' AND lab.labresult > 0 AND lab.labresult < 10)
						 
						OR (lab.labname = 'ALT (SGPT)' AND lab.labresult > 0 AND lab.labresult < 90) 
						OR (lab.labname = 'alkaline phos.' AND lab.labresult > 30 AND lab.labresult < 180) 
						OR (lab.labname = 'AST (SGOT)' AND lab.labresult > 0 AND lab.labresult < 80) 
						OR (lab.labname = 'total bilirubin' AND lab.labresult > 0.2 AND lab.labresult < 3) 

						OR (lab.labname = 'FiO2' AND lab.labresult > 5 AND lab.labresult < 95)
						OR (lab.labname = 'Base Excess' AND lab.labresult > -15 AND lab.labresult < 15) -- mmol/L
						OR (lab.labname = 'Total CO2' AND lab.labresult > 5 AND lab.labresult < 60) -- mmol/L
						OR (lab.labname = 'paCO2' AND lab.labresult > 10 AND lab.labresult < 80)
						OR (lab.labname = 'paO2' AND lab.labresult > 30 AND lab.labresult < 125)
						
		) 
		SELECT
				patientunitstayid,
				"time",
				ROUND(AVG (CASE WHEN labname = 'Hgb' THEN labresult ELSE NULL END)::numeric, 2) AS hgb,
				ROUND(AVG (CASE WHEN labname = 'Hct' THEN labresult ELSE NULL END)::numeric, 2) AS hct,
				ROUND(AVG (CASE WHEN labname = 'MCH' THEN labresult ELSE NULL END)::numeric, 2) AS mch,
				ROUND(AVG (CASE WHEN labname = 'MCHC' THEN labresult ELSE NULL END)::numeric, 2) AS mchc,
				ROUND(AVG (CASE WHEN labname = 'MCV' THEN labresult ELSE NULL END)::numeric, 2) AS mcv,
				ROUND(AVG (CASE WHEN labname = 'MPV' THEN labresult ELSE NULL END)::numeric, 2) AS mpv,
				ROUND(AVG (CASE WHEN labname = 'platelets x 1000' THEN labresult ELSE NULL END)::numeric, 2) AS platelets,
				ROUND(AVG (CASE WHEN labname = 'RBC' THEN labresult ELSE NULL END)::numeric, 2) AS rbc,
				ROUND(AVG (CASE WHEN labname = 'RDW' THEN labresult ELSE NULL END)::numeric, 2) AS rdw,
				ROUND(AVG (CASE WHEN labname = 'WBC x 1000' THEN labresult ELSE NULL END)::numeric, 2) AS wbc,
				ROUND(AVG (CASE WHEN labname = '-basos' THEN labresult ELSE NULL END)::numeric, 2) AS baso,
				ROUND(AVG (CASE WHEN labname = '-eos' THEN labresult ELSE NULL END)::numeric, 2) AS eosi,
				ROUND(AVG (CASE WHEN labname = '-lymphs' THEN labresult ELSE NULL END)::numeric, 2) AS lymp,
				ROUND(AVG (CASE WHEN labname = '-monos' THEN labresult ELSE NULL END)::numeric, 2) AS mono,
				ROUND(AVG (CASE WHEN labname = '-polys' THEN labresult ELSE NULL END)::numeric, 2) AS poly,
				
				ROUND(AVG (CASE WHEN labname = 'PT - INR' THEN labresult ELSE NULL END)::numeric, 2) AS inr,
				ROUND(AVG (CASE WHEN labname = 'PT' THEN labresult ELSE NULL END)::numeric, 2) AS pt,
				ROUND(AVG (CASE WHEN labname = 'PTT' THEN labresult ELSE NULL END)::numeric, 2) AS ptt,
				
				ROUND(AVG (CASE WHEN labname = 'pH' THEN labresult ELSE NULL END)::numeric, 2) AS ph,
				ROUND(AVG (CASE WHEN labname = 'albumin' THEN labresult ELSE NULL END)::numeric, 2) AS albumin,
				ROUND(AVG (CASE WHEN labname = 'total protein' THEN labresult ELSE NULL END)::numeric, 2) AS total_protein,
				ROUND(AVG (CASE WHEN labname = 'anion gap' THEN labresult ELSE NULL END)::numeric, 2) AS aniongap,
				ROUND(AVG (CASE WHEN labname = 'bicarbonate' THEN labresult ELSE NULL END)::numeric, 2) AS bicarbonate,
				ROUND(AVG (CASE WHEN labname = 'phosphate' THEN labresult ELSE NULL END)::numeric, 2) AS phosphate,
				ROUND(AVG (CASE WHEN labname = 'lactate' THEN labresult ELSE NULL END)::numeric, 2) AS lactate,
				ROUND(AVG (CASE WHEN labname = 'BUN' THEN labresult ELSE NULL END)::numeric, 2) AS bun,
				ROUND(AVG (CASE WHEN labname = 'calcium' THEN labresult ELSE NULL END)::numeric, 2) AS calcium,
				ROUND(AVG (CASE WHEN labname = 'chloride' THEN labresult ELSE NULL END)::numeric, 2) AS chloride,
				ROUND(AVG (CASE WHEN labname = 'creatinine' THEN labresult ELSE NULL END)::numeric, 2) AS creatinine,
				ROUND(AVG (CASE WHEN labname IN ('bedside glucose', 'glucose') THEN labresult ELSE NULL END)::numeric, 2) AS glucose,
				ROUND(AVG (CASE WHEN labname = 'sodium' THEN labresult ELSE NULL END)::numeric, 2) AS sodium,
				ROUND(AVG (CASE WHEN labname = 'potassium' THEN labresult ELSE NULL END)::numeric, 2) AS potassium,
				ROUND(AVG (CASE WHEN labname = 'magnesium' THEN labresult ELSE NULL END)::numeric, 2) AS magnesium,
				
				ROUND(AVG (CASE WHEN labname = 'ALT (SGPT)' THEN labresult ELSE NULL END)::numeric, 2) AS alt,
				ROUND(AVG (CASE WHEN labname = 'alkaline phos.' THEN labresult ELSE NULL END)::numeric, 2) AS alp,
				ROUND(AVG (CASE WHEN labname = 'AST (SGOT)' THEN labresult ELSE NULL END)::numeric, 2) AS ast,
				ROUND(AVG (CASE WHEN labname = 'total bilirubin' THEN labresult ELSE NULL END)::numeric, 2) AS bil_total,
				
				ROUND(AVG (CASE WHEN labname = 'FiO2' THEN labresult ELSE NULL END)::numeric, 2) AS fio2,
				ROUND(AVG (CASE WHEN labname = 'Base Excess' THEN labresult ELSE NULL END)::numeric, 2) AS base_excess,
				ROUND(AVG (CASE WHEN labname = 'Total CO2' THEN labresult ELSE NULL END)::numeric, 2) AS total_co2,
				ROUND(AVG (CASE WHEN labname = 'paCO2' THEN labresult ELSE NULL END)::numeric, 2) AS paco2,
				ROUND(AVG (CASE WHEN labname = 'paO2' THEN labresult ELSE NULL END)::numeric, 2) AS pao2
				
		FROM vw1 
		WHERE rn = 1 AND "time" >= 0
		GROUP BY patientunitstayid, "time" 
		ORDER BY patientunitstayid, "time"
);




