-- 患者基本特征，包括心率、血压、呼吸频率、体温等
DROP MATERIALIZED VIEW IF EXISTS mimic_icu.vital_signs CASCADE;
CREATE MATERIALIZED VIEW mimic_icu.vital_signs AS (
		select
				ce.subject_id
			, ce.hadm_id
			, ce.charttime
			, AVG(case when itemid in (220045) and valuenum > 30 and valuenum < 150 then valuenum else null end) as heart_rate
			, AVG(case when itemid in (220179, 220050) and valuenum > 50 and valuenum < 200 then valuenum else null end) as sbp
			, AVG(case when itemid in (220180, 220051) and valuenum > 30 and valuenum < 100 then valuenum else null end) as dbp
			, AVG(case when itemid in (220052, 220181, 225312) and valuenum > 30 and valuenum < 150 then valuenum else null end) as mbp
			--, AVG(case when itemid = 220179 and valuenum > 0 and valuenum < 400 then valuenum else null end) as sbp_ni
			--, AVG(case when itemid = 220180 and valuenum > 0 and valuenum < 300 then valuenum else null end) as dbp_ni
			--, AVG(case when itemid = 220181 and valuenum > 0 and valuenum < 300 then valuenum else null end) as mbp_ni
			, AVG(case when itemid = 220074 and valuenum > 0 and valuenum < 50 then valuenum else null end) as cvp
			, AVG(case when itemid = 223835 and valuenum > 0 and valuenum < 300 then valuenum else null end) as fio2
			, AVG(case when itemid = 223834 and valuenum > 0 and valuenum < 120 then valuenum else null end) as o2flow
			, AVG(case when itemid in (220210, 224690) and valuenum > 10 and valuenum < 40 then valuenum else null end) as resp_rate
			, AVG(case when itemid in (223761) and valuenum > 85 and valuenum < 120 then ROUND(((valuenum-32) / 1.8)::numeric, 2) -- 华氏度转摄氏度
								 when itemid in (223762) and valuenum > 30 and valuenum < 45  then ROUND(valuenum::numeric, 2) 
								 else null end) AS temperature
			--, MAX(CASE WHEN itemid = 224642 THEN value ELSE NULL END) AS temperature_site
			, AVG(case when itemid in (220277) and valuenum > 80 and valuenum < 100 then valuenum else null end) as spo2
-- 			, AVG(case when itemid in (220224) and valuenum > 30 and valuenum < 200 then valuenum else null end) as pao2
-- 			, AVG(case when itemid in (220235) and valuenum > 10 and valuenum < 100 then valuenum else null end) as paco2
-- 			, AVG(case when itemid in (224828) and valuenum > -20 and valuenum < 20 then valuenum else null end) as base_excess
-- 			, AVG(case when itemid in (225698) and valuenum > 10 and valuenum < 70 then valuenum else null end) as tco2
-- 			, AVG(case when itemid in (220765, 227989) and valuenum > 0 and valuenum < 50 then valuenum else null end) as icp
			
			--, AVG(case when itemid in (225664, 220621, 226537) and valuenum > 0 then valuenum else null end) as glucose
			--, AVG(case when itemid in (224719) then valuenum else null end) as sao2,
-- 			, AVG(case when itemid in (226512, 224639) and valuenum > 0 and valuenum < 300 then valuenum
-- 						     when itemid in (226531) and valuenum > 0 and valuenum < 660 then ROUND((valuenum / 2.2)::numeric, 2) --- 英镑转化为千克
-- 								 else null end) as weight
			FROM mimic_icu.chartevents ce
			-- where ce.stay_id IS NOT NULL
			where ce.itemid in
			(
				220045, -- Heart Rate
				225309, -- ART BP Systolic
				225310, -- ART BP Diastolic
				225312, -- ART BP Mean
				220050, -- Arterial Blood Pressure systolic
				220051, -- Arterial Blood Pressure diastolic
				220052, -- Arterial Blood Pressure mean
				220179, -- Non Invasive Blood Pressure systolic
				220180, -- Non Invasive Blood Pressure diastolic
				220181, -- Non Invasive Blood Pressure mean
				220074, -- Central Venous Pressure
				223835, -- inspired O2 fraction
				223834, -- O2 flow
				220210, -- Respiratory Rate
				224690, -- Respiratory Rate (Total)
				220277, -- SPO2, peripheral 血氧饱和度
				220224, -- PaO2 动脉氧分压 mmHg
				220235, -- PaCO2, 动脉二氧化碳分压 mmHg
				225698, -- base excess 动脉碱剩余 mmol/L
				224828, -- tco2 总二氧化碳
				220765, -- Intra Cranial Pressure -- 92306 颅内压
				227989, -- Intra Cranial Pressure #2 -- 1052 颅内压
				-- GLUCOSE, both lab and fingerstick
				--225664, -- Glucose finger stick
				--220621, -- Glucose (serum)
				--226537, -- Glucose (whole blood)
				-- TEMPERATURE
				223762, -- "Temperature Celsius"
				223761  -- "Temperature Fahrenheit"
				--224642 -- Temperature Site
				-- 226329 -- Blood Temperature CCO (C)
-- 				226512, -- weight
-- 				224639,
-- 				226531
		)
		group by ce.subject_id, ce.hadm_id, ce.charttime
);


-- DROP MATERIALIZED VIEW IF EXISTS mimic_icu.features;
-- CREATE MATERIALIZED VIEW mimic_icu.features AS (
-- 		SELECT 
-- 			fd.subject_id, 
-- 			fd.hadm_id,
-- 			fd.stay_id, 
-- 			ROUND(AVG(fd.heart_rate)::numeric, 2) AS heart_rate, 
-- 			ROUND(AVG(fd.sbp)::numeric, 2) AS sbp, 
-- 			ROUND(AVG(fd.dbp)::numeric, 2) AS dbp,
-- 			ROUND(AVG(fd.mbp)::numeric, 2) AS mbp, 
-- 			ROUND(AVG(fd.resp_rate)::numeric, 2) AS resp_rate, 
-- 			ROUND(AVG(fd.temperature)::numeric, 2) AS temperature, 
-- 			ROUND(AVG(fd.spo2)::numeric, 2) AS spo2, 
-- 			ROUND(AVG(fd.glucose)::numeric, 2) AS glucose,
-- 			ROUND(AVG(fd.weight)::numeric, 2) AS weight
-- 		FROM features_detail fd
-- 			GROUP BY fd.subject_id, fd.hadm_id, fd.stay_id
-- )

SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime
	, ROUND(AVG(heart_rate)::numeric, 2) AS heart_rate
	, ROUND(AVG(sbp)::numeric, 2) AS sbp
	, ROUND(AVG(dbp)::numeric, 2) AS dbp
	, ROUND(AVG(mbp)::numeric, 2) AS mbp
	, ROUND(AVG(cvp)::numeric, 2) AS cvp
	, ROUND(AVG(fio2)::numeric, 2) AS fio2
	, ROUND(AVG(o2flow)::numeric, 2) AS o2flow
	, ROUND(AVG(resp_rate)::numeric, 2) AS resp_rate
	, ROUND(AVG(temperature)::numeric, 2) AS temperature
	, ROUND(AVG(spo2)::numeric, 2) AS spo2
	, ROUND(AVG(pao2)::numeric, 2) AS pao2
	, ROUND(AVG(paco2)::numeric, 2) AS paco2
	, ROUND(AVG(base_excess)::numeric, 2) AS base_excess
	, ROUND(AVG(tco2)::numeric, 2) AS tco2
	, ROUND(AVG(icp)::numeric, 2) AS icp
	
FROM vital_signs
	GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd')





