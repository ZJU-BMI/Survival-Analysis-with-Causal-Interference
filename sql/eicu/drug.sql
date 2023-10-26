DROP MATERIALIZED VIEW IF EXISTS drug;
CREATE MATERIALIZED VIEW drug AS (
	WITH dr AS(
		SELECT patientunitstayid, FLOOR((infusionoffset / 360)::numeric ) AS "time"
		, CASE WHEN drugname = 'Fentanyl (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS fentanyl
				 
		, CASE WHEN drugname = 'Propofol (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS propofol
				 
		, CASE WHEN drugname = 'Norepinephrine (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS norepinephrine		
					
		, CASE WHEN drugname = 'Insulin (units/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS insulin	
					
		, CASE WHEN drugname = 'Midazolam (mg/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS midazolam
				 
		 , CASE WHEN drugname = 'Heparin (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS heparin
		 
		 , CASE WHEN drugname = 'Dexmedetomidine (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS dexmedetomidine
				 
		 , CASE WHEN drugname = 'Amiodarone (ml/hr)' 
				 AND drugamount ~ '^[-]?[0-9]+[.]?[0-9]*$' 
				 AND drugamount NOT IN ( '-', '.' ) 
				 THEN CAST (drugamount AS NUMERIC) ELSE NULL 
				 END AS amiodarone	 
				 
		FROM infusiondrug
	)
	SELECT patientunitstayid, "time"
		, ROUND(AVG(fentanyl)::numeric, 2) AS fentanyl
		, ROUND(AVG(propofol)::numeric, 2) AS propofol
		, ROUND(AVG(norepinephrine)::numeric, 2) AS norepinephrine
		, ROUND(AVG(insulin)::numeric, 2) AS insulin
		, ROUND(AVG(midazolam)::numeric, 2) AS midazolam
		, ROUND(AVG(heparin)::numeric, 2) AS heparin
		, ROUND(AVG(dexmedetomidine)::numeric, 2) AS dexmedetomidine
		, ROUND(AVG(amiodarone)::numeric, 2) AS amiodarone
	FROM dr
	WHERE "time" >= 0
	GROUP BY patientunitstayid, "time"
	ORDER BY patientunitstayid, "time"
);