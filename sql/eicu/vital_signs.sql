DROP MATERIALIZED VIEW IF EXISTS vital_signs CASCADE;
CREATE MATERIALIZED VIEW vital_signs AS (
		WITH nc AS (
				SELECT
						patientunitstayid,
						FLOOR((nursingchartoffset/360)::numeric) AS "time",
						CASE
								WHEN nursingchartcelltypevallabel = 'Heart Rate' 
								AND nursingchartcelltypevalname = 'Heart Rate' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) 
								THEN CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS heart_rate,
						CASE
								WHEN nursingchartcelltypevallabel = 'Respiratory Rate' 
								AND nursingchartcelltypevalname = 'Respiratory Rate' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS resp_rate,
						CASE
								WHEN nursingchartcelltypevallabel = 'O2 Saturation' 
								AND nursingchartcelltypevalname = 'O2 Saturation' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS sao2,
						CASE
								WHEN nursingchartcelltypevallabel = 'Non-Invasive BP' 
								AND nursingchartcelltypevalname = 'Non-Invasive BP Systolic' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS sbp,
						CASE
								WHEN nursingchartcelltypevallabel = 'Non-Invasive BP' 
								AND nursingchartcelltypevalname = 'Non-Invasive BP Diastolic' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS dbp,
						CASE
								WHEN nursingchartcelltypevallabel = 'Non-Invasive BP' 
								AND nursingchartcelltypevalname = 'Non-Invasive BP Mean' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS mbp,
						CASE
								WHEN nursingchartcelltypevallabel = 'Temperature' 
								AND nursingchartcelltypevalname = 'Temperature (C)' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC )
								WHEN nursingchartcelltypevallabel = 'Temperature' 
								AND nursingchartcelltypevalname = 'Temperature (F)' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN 
								ROUND(((CAST (nursingchartvalue AS NUMERIC) - 32) / 1.8)::numeric, 2) ELSE NULL
								END AS temperature,
						CASE
								WHEN nursingchartcelltypevallabel = 'Glasgow coma score' 
								AND nursingchartcelltypevalname = 'GCS Total' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL
								END AS gcs_total,
						CASE
								WHEN nursingchartcelltypevallabel = 'CVP' 
								AND nursingchartcelltypevalname = 'CVP' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL
								END AS cvp,
						CASE 
								WHEN nursingchartcelltypevallabel = 'SpO2'  
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS spo2
-- 						CASE			
-- 								WHEN nursingchartcelltypevallabel = 'Temperature' 
-- 								AND nursingchartcelltypevalname = 'Temperature Location' THEN
-- 								nursingchartvalue ELSE NULL 
-- 								END AS TemperatureLocation,						 
-- 						CASE				
-- 								WHEN nursingchartcelltypevallabel = 'Invasive BP' 
-- 								AND nursingchartcelltypevalname = 'Invasive BP Systolic' 
-- 								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
-- 								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
-- 								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
-- 								END AS ibp_systolic,
-- 						CASE					
-- 								WHEN nursingchartcelltypevallabel = 'Invasive BP' 
-- 								AND nursingchartcelltypevalname = 'Invasive BP Diastolic' 
-- 								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
-- 								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
-- 								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
-- 								END AS ibp_diastolic,
-- 						CASE								
-- 								WHEN nursingchartcelltypevallabel = 'Invasive BP' 
-- 								AND nursingchartcelltypevalname = 'Invasive BP Mean' 
-- 								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
-- 								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
-- 								CAST ( nursingchartvalue AS NUMERIC ) -- other map fields
-- 								WHEN nursingchartcelltypevallabel = 'MAP (mmHg)' 
-- 								AND nursingchartcelltypevalname = 'Value' 
-- 								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
-- 								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
-- 								CAST ( nursingchartvalue AS NUMERIC ) 
-- 								WHEN nursingchartcelltypevallabel = 'Arterial Line MAP (mmHg)' 
-- 								AND nursingchartcelltypevalname = 'Value' 
-- 								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
-- 								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
-- 								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
-- 								END AS ibp_mean 
				FROM nursecharting
				WHERE nursingchartcelltypecat IN ( 'Vital Signs', 'Scores', 'Other Vital Signs and Infusions' ) 
		) 
		SELECT
				patientunitstayid,
				"time",
				ROUND(AVG(CASE WHEN heart_rate > 30 AND heart_rate < 200 THEN heart_rate ELSE NULL END)::numeric, 2) AS heart_rate,
				ROUND(AVG(CASE WHEN resp_rate > 10 AND resp_rate < 100 THEN resp_rate ELSE NULL END)::numeric, 2) AS resp_rate,
				ROUND(AVG(CASE WHEN sao2 > 60 AND sao2 < 100 THEN sao2 ELSE NULL END)::numeric, 2) AS sao2,
				ROUND(AVG(CASE WHEN sbp > 50 AND sbp < 200 THEN sbp ELSE NULL END)::numeric, 2) AS sbp,
				ROUND(AVG(CASE WHEN dbp > 30 AND dbp < 120 THEN dbp ELSE NULL END)::numeric, 2) AS dbp,
				ROUND(AVG(CASE WHEN mbp > 20 AND mbp < 150 THEN mbp ELSE NULL END)::numeric, 2) AS mbp,
				ROUND(AVG(CASE WHEN temperature > 34 AND temperature < 45 THEN temperature ELSE NULL END)::numeric, 2) AS temperature,
				ROUND(AVG(CASE WHEN gcs_total >= 0 AND gcs_total < 100 THEN gcs_total ELSE NULL END)::numeric, 2) AS gcs_total,
				ROUND(AVG(CASE WHEN cvp > 0 AND cvp < 100 THEN cvp ELSE NULL END)::numeric, 2) AS cvp,
				ROUND(AVG(CASE WHEN spo2 > 0 AND spo2 < 100 THEN spo2 ELSE NULL END)::numeric, 2) AS spo2
		FROM nc 
 		WHERE "time" >= 0 
-- 				heartrate IS NOT NULL 
-- 				OR RespiratoryRate IS NOT NULL 
-- 				OR o2saturation IS NOT NULL 
-- 				OR nibp_systolic IS NOT NULL 
-- 				OR nibp_diastolic IS NOT NULL 
-- 				OR nibp_mean IS NOT NULL 
-- 				OR temperature IS NOT NULL 
-- 				OR temperaturelocation IS NOT NULL 
-- 				OR ibp_systolic IS NOT NULL 
-- 				OR ibp_diastolic IS NOT NULL 
-- 				OR ibp_mean IS NOT NULL 
		GROUP BY patientunitstayid, "time"
		ORDER BY patientunitstayid, "time"
);



