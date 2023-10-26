DROP MATERIALIZED VIEW IF EXISTS eicu.basic_demographics;
CREATE MATERIALIZED VIEW eicu.basic_demographics AS (
		SELECT pt.patientunitstayid,
					 pt.apacheadmissiondx,
					 pt.admissionweight,
					 pt.dischargeweight,
					 pt.admissionheight,
					 CASE WHEN pt.ethnicity = '' THEN 'Other/Unknown'
					 ELSE pt.ethnicity END AS ethnicity,
					 CASE WHEN pt.age = '> 89' THEN 95
								WHEN pt.age = '' THEN NULL
								ELSE TO_NUMBER(pt.age, '999') END AS age,
					 CASE WHEN pt.gender = 'Male' THEN 'Male'
								WHEN pt.gender = 'Female' THEN 'Female'
								ELSE NULL END AS gender,
					 CASE WHEN pt.hospitaldischargestatus = 'Alive' THEN 0
								WHEN pt.hospitaldischargestatus = 'Expired' THEN 1
								ELSE NULL END AS hosp_mortality,
					 ROUND(pt.unitdischargeoffset / 60) AS icu_los_hours
		FROM eicu.patient pt
		ORDER BY pt.patientunitstayid
);