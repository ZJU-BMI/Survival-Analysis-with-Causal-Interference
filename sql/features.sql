DROP MATERIALIZED VIEW IF EXISTS eicu.features;
CREATE MATERIALIZED VIEW eicu.features AS(
		WITH pat AS (
				SELECT 
					pt.patientunitstayid,
					(CASE WHEN pt.gender = 'Male' THEN 1
								WHEN pt.gender = 'Female' THEN 0
								ELSE NULL END) AS gender,			-- gender
					(CASE WHEN (pt.age = '> 89') THEN 95
								WHEN (pt.age = '') THEN NULL
								ELSE to_number(pt.age, '999') END) AS age, 	--age
					(CASE WHEN pt.admissionweight IS NOT NULL THEN pt.admissionweight
								WHEN pt.dischargeweight IS NOT NULL THEN pt.dischargeweight
								ELSE NULL END) AS weight,	-- weight(admission weight or discharge weight)
					(CASE WHEN pt.hospitaldischargestatus = 'Alive' THEN 0
								WHEN pt.hospitaldischargestatus = 'Expired' THEN 1
								ELSE NULL END) AS "flag", -- death flag, 1: death; 0: alive 
					(CASE WHEN pt.unitdischargeoffset > 0 THEN ROUND(pt.unitdischargeoffset / 60.0, 2) -- convert from hours to days
								ELSE 0 END) AS los_icu  -- icustay days
				FROM patient pt
		), vital_p AS (
				SELECT 
					patientunitstayid,
					ROUND(AVG(temperature::numeric), 2) AS temperature,		-- temperature
					ROUND(AVG(sao2::numeric), 2) AS sao2,		-- sao2 血氧饱和度
					ROUND(AVG(heartrate::numeric), 2) AS heartrate,	--heartrate
					ROUND(AVG(respiration::numeric), 2) AS resp	-- respiratory rate
				FROM eicu.vitalperiodic
				GROUP BY patientunitstayid
		), vital_ap AS (
				SELECT 
					patientunitstayid,
					ROUND(AVG(noninvasivesystolic::numeric), 2) AS sbp,  -- Non Invasive Blood Pressure systolic
					ROUND(AVG(noninvasivediastolic::numeric), 2) AS dbp,  -- Non Invasive Blood Pressure diastolic
					ROUND(AVG(noninvasivemean::numeric), 2) AS mbp -- Non Invasive Blood Pressure mean
				FROM eicu.vitalaperiodic
				GROUP BY patientunitstayid
		), lab_res AS (
				SELECT 
					patientunitstayid,
					AVG(CASE WHEN labname IN('glucose', 'bedside glucose') AND labresult > 0 THEN ROUND(labresult / 18.0, 2)
									 ELSE NULL END) AS glucose	-- glucose		
				FROM
					eicu.lab
				WHERE labname IN(
					'glucose',
					'bedside glucose' 
				)
				GROUP BY patientunitstayid
		)
		SELECT 
			pat.*,
			vital_p.temperature,
			vital_p.sao2,
			vital_p.heartrate,
			vital_p.resp,
			vital_ap.sbp,
			vital_ap.dbp,
			vital_ap.mbp,
			lab_res.glucose
		FROM pat
			LEFT JOIN vital_p ON pat.patientunitstayid = vital_p.patientunitstayid
			LEFT JOIN vital_ap ON pat.patientunitstayid = vital_ap.patientunitstayid
			LEFT JOIN lab_res ON pat.patientunitstayid = lab_res.patientunitstayid
)


