DROP MATERIALIZED VIEW IF EXISTS vital_sign_others CASCADE;
CREATE MATERIALIZED VIEW vital_sign_others AS ( 
		WITH nc AS (
				SELECT
						patientunitstayid,
						nursingchartoffset,
						nursingchartentryoffset,
						CASE 
								WHEN nursingchartcelltypevallabel = 'PA' 
								AND nursingchartcelltypevalname = 'PA Systolic' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS pasystolic,
						CASE
								WHEN nursingchartcelltypevallabel = 'PA' 
								AND nursingchartcelltypevalname = 'PA Diastolic' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS padiastolic,
						CASE
								WHEN nursingchartcelltypevallabel = 'PA' 
								AND nursingchartcelltypevalname = 'PA Mean'
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS pamean,
						CASE
								WHEN nursingchartcelltypevallabel = 'SV' 
								AND nursingchartcelltypevalname = 'SV' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS sv,
						CASE
								WHEN nursingchartcelltypevallabel = 'CO' 
								AND nursingchartcelltypevalname = 'CO' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS co,
						CASE
								WHEN nursingchartcelltypevallabel = 'SVR' 
								AND nursingchartcelltypevalname = 'SVR'
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS svr,
						CASE
								WHEN nursingchartcelltypevallabel = 'ICP' 
								AND nursingchartcelltypevalname = 'ICP' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS icp,
						CASE
								WHEN nursingchartcelltypevallabel = 'CI' 
								AND nursingchartcelltypevalname = 'CI' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS ci,
						CASE	
								WHEN nursingchartcelltypevallabel = 'SVRI' 
								AND nursingchartcelltypevalname = 'SVRI' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS svri,
						CASE				
								WHEN nursingchartcelltypevallabel = 'CPP' 
								AND nursingchartcelltypevalname = 'CPP' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS cpp,
						CASE
								WHEN nursingchartcelltypevallabel = 'SVO2' 
								AND nursingchartcelltypevalname = 'SVO2' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS svo2,
						CASE							
								WHEN nursingchartcelltypevallabel = 'PAOP' 
								AND nursingchartcelltypevalname = 'PAOP' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS paop,
						CASE
								WHEN nursingchartcelltypevallabel = 'PVR' 
								AND nursingchartcelltypevalname = 'PVR' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS pvr,
						CASE
																		
								WHEN nursingchartcelltypevallabel = 'PVRI' 
								AND nursingchartcelltypevalname = 'PVRI' 
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS pvri,
						CASE										
								WHEN nursingchartcelltypevallabel = 'IAP' 
								AND nursingchartcelltypevalname = 'IAP' -- verify it's numeric
								AND nursingchartvalue ~ '^[-]?[0-9]+[.]?[0-9]*$' 
								AND nursingchartvalue NOT IN ( '-', '.' ) THEN
								CAST ( nursingchartvalue AS NUMERIC ) ELSE NULL 
								END AS iap 
				FROM nursecharting
				WHERE nursingchartcelltypecat = 'Vital Signs' 
		) 
		SELECT
				patientunitstayid,
				nursingchartoffset AS chartoffset,
				nursingchartentryoffset AS entryoffset,
				ROUND(AVG(CASE WHEN pasystolic >= 0 AND pasystolic <= 1000 THEN pasystolic ELSE NULL END)::numeric, 2) AS pasystolic,
				ROUND(AVG(CASE WHEN padiastolic >= 0 AND padiastolic <= 1000 THEN padiastolic ELSE NULL END)::numeric, 2) AS padiastolic,
				ROUND(AVG(CASE WHEN pamean >= 0 AND pamean <= 1000 THEN pamean ELSE NULL END)::numeric, 2) AS pamean,
				ROUND(AVG(CASE WHEN sv >= 0 AND sv <= 1000 THEN sv ELSE NULL END)::numeric, 2) AS sv,
				ROUND(AVG(CASE WHEN co >= 0 AND co <= 1000 THEN co ELSE NULL END)::numeric, 2) AS co,
				ROUND(AVG(CASE WHEN svr >= 0 AND svr <= 1000 THEN svr ELSE NULL END)::numeric, 2) AS svr,
				ROUND(AVG(CASE WHEN icp >= 0 AND icp <= 1000 THEN icp ELSE NULL END)::numeric, 2) AS icp,
				ROUND(AVG(CASE WHEN ci >= 0 AND ci <= 1000 THEN ci ELSE NULL END)::numeric, 2) AS ci,
				ROUND(AVG(CASE WHEN svri >= 0 AND svri <= 1000 THEN svri ELSE NULL END)::numeric, 2) AS svri,
				ROUND(AVG(CASE WHEN cpp >= 0 AND cpp <= 1000 THEN cpp ELSE NULL END)::numeric, 2) AS cpp,
				ROUND(AVG(CASE WHEN svo2 >= 0 AND svo2 <= 1000 THEN svo2 ELSE NULL END)::numeric, 2) AS svo2,
				ROUND(AVG(CASE WHEN paop >= 0 AND paop <= 1000 THEN paop ELSE NULL END)::numeric, 2) AS paop,
				ROUND(AVG(CASE WHEN pvr >= 0 AND pvr <= 1000 THEN pvr ELSE NULL END)::numeric, 2) AS pvr,
				ROUND(AVG(CASE WHEN pvri >= 0 AND pvri <= 1000 THEN pvri ELSE NULL END)::numeric, 2) AS pvri,
				ROUND(AVG(CASE WHEN iap >= 0 AND iap <= 1000 THEN iap ELSE NULL END)::numeric, 2) AS iap 
		FROM nc 
		WHERE
				pasystolic IS NOT NULL 
				OR padiastolic IS NOT NULL 
				OR pamean IS NOT NULL 
				OR sv IS NOT NULL 
				OR co IS NOT NULL 
				OR svr IS NOT NULL 
				OR icp IS NOT NULL 
				OR ci IS NOT NULL 
				OR svri IS NOT NULL 
				OR cpp IS NOT NULL 
				OR svo2 IS NOT NULL 
				OR paop IS NOT NULL 
				OR pvr IS NOT NULL 
				OR pvri IS NOT NULL 
				OR iap IS NOT NULL 
		GROUP BY patientunitstayid, nursingchartoffset, nursingchartentryoffset 
		ORDER BY patientunitstayid, nursingchartoffset, nursingchartentryoffset
	);