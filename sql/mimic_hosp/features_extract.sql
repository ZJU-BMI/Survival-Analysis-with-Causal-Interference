SELECT ctid, crp.*
FROM comp_risks_pats crp
WHERE ctid in (select min(ctid) from comp_risks_pats group by subject_id, hadm_id) AND age >= 30 AND hosp_stay <= 50 AND hosp_stay > 5


SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime,
	ROUND(AVG(hematocrit)::numeric, 2) AS hematocrit,
	ROUND(AVG(hemoglobin)::numeric, 2) AS hemoglobin,
	ROUND(AVG(mch)::numeric, 2) AS mch,
	ROUND(AVG(mchc)::numeric, 2) AS mchc,
	ROUND(AVG(mcv)::numeric, 2) AS mcv,
	ROUND(AVG(platelet)::numeric, 2) AS platelet,
	ROUND(AVG(rbc)::numeric, 2) AS rbc,
	ROUND(AVG(rdw)::numeric, 2) AS rdw,
	ROUND(AVG(wbc)::numeric, 2) AS wbc
FROM blood_count
WHERE hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd');
		


SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime,
	ROUND(AVG(total_co2)::numeric, 2) AS total_co2,
	ROUND(AVG(pco2)::numeric, 2) AS pco2,
	ROUND(AVG(po2)::numeric, 2) AS po2,
	ROUND(AVG(base_excess)::numeric, 2) AS base_excess
FROM blood_gas
WHERE hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd');



SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime,
	ROUND(AVG(aniongap)::numeric, 2) AS aniongap,
	ROUND(AVG(bicarbonate)::numeric, 2) AS bicarbonate,
	ROUND(AVG(bun)::numeric, 2) AS bun,
	ROUND(AVG(calcium)::numeric, 2) AS calcium,
	ROUND(AVG(chloride)::numeric, 2) AS chloride,
	ROUND(AVG(creatinine)::numeric, 2) AS creatinine,
	ROUND(AVG(glucose)::numeric, 2) AS glucose,
	ROUND(AVG(sodium)::numeric, 2) AS sodium,
	ROUND(AVG(potassium)::numeric, 2) AS potassium,
	ROUND(AVG(magnesium)::numeric, 2) AS magnesium,
	ROUND(AVG(phosphate)::numeric, 2) AS phosphate,
	ROUND(AVG(ph)::numeric, 2) AS ph
FROM chemistry
WHERE hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd');



SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime,
	ROUND(AVG(inr)::numeric, 2) AS inr,
	ROUND(AVG(pt)::numeric, 2) AS pt,
	ROUND(AVG(ptt)::numeric, 2) AS ptt
FROM coagulation
WHERE hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd');






