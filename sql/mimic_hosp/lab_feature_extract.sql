SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime
	, ROUND(AVG(hct)::numeric, 2) AS hct
	, ROUND(AVG(hgb)::numeric, 2) AS hgb
	, ROUND(AVG(mch)::numeric, 2) AS mch
	, ROUND(AVG(mchc)::numeric, 2) AS mchc
	, ROUND(AVG(mcv)::numeric, 2) AS mcv
	, ROUND(AVG(platelet)::numeric, 2) AS platelet
	, ROUND(AVG(rbc)::numeric, 2) AS rbc
	, ROUND(AVG(rdw)::numeric, 2) AS rdw
	, ROUND(AVG(wbc)::numeric, 2) AS wbc
	
	, ROUND(AVG(lym)::numeric, 2) AS lym
	, ROUND(AVG(neut)::numeric, 2) AS neut
	, ROUND(AVG(mono)::numeric, 2) AS mono
	, ROUND(AVG(eosi)::numeric, 2) AS eosi
	, ROUND(AVG(baso)::numeric, 2) AS baso
	
	, ROUND(AVG(pco2)::numeric, 2) AS pco2
	, ROUND(AVG(po2)::numeric, 2) AS po2
	, ROUND(AVG(tco2)::numeric, 2) AS tco2
	, ROUND(AVG(base_excess)::numeric, 2) AS base_excess
	
	, ROUND(AVG(tc)::numeric, 2) AS tc
	, ROUND(AVG(tg)::numeric, 2) AS tg
	, ROUND(AVG(hdlc)::numeric, 2) AS hdlc
	, ROUND(AVG(ldlc)::numeric, 2) AS ldlc
	
	, ROUND(AVG(albumin)::numeric, 2) AS albumin
	, ROUND(AVG(globulin)::numeric, 2) AS globulin
	, ROUND(AVG(total_protein)::numeric, 2) AS total_protein
	, ROUND(AVG(aniongap)::numeric, 2) AS aniongap
	, ROUND(AVG(bicarbonate)::numeric, 2) AS bicarbonate
	, ROUND(AVG(bun)::numeric, 2) AS bun
	, ROUND(AVG(calcium)::numeric, 2) AS calcium
	, ROUND(AVG(chloride)::numeric, 2) AS chloride
	, ROUND(AVG(glucose)::numeric, 2) AS glucose
	, ROUND(AVG(sodium)::numeric, 2) AS sodium
	, ROUND(AVG(potassium)::numeric, 2) AS potassium
	, ROUND(AVG(magnesium)::numeric, 2) AS magnesium
	, ROUND(AVG(phosphate)::numeric, 2) AS phosphate
	, ROUND(AVG(lactate)::numeric, 2) AS lactate
	, ROUND(AVG(ph)::numeric, 2) AS ph
	
	, ROUND(AVG(inr)::numeric, 2) AS inr
	, ROUND(AVG(tt)::numeric, 2) AS tt
	, ROUND(AVG(pt)::numeric, 2) AS pt
	, ROUND(AVG(ptt)::numeric, 2) AS ptt
	
	, ROUND(AVG(alt)::numeric, 2) AS alt
	, ROUND(AVG(alp)::numeric, 2) AS alp
	, ROUND(AVG(ast)::numeric, 2) AS ast
	, ROUND(AVG(amylase)::numeric, 2) AS amylase
	, ROUND(AVG(bil_total)::numeric, 2) AS bil_total
	, ROUND(AVG(ck_cpk)::numeric, 2) AS ck_cpk
	, ROUND(AVG(ck_mb)::numeric, 2) AS ck_mb
	, ROUND(AVG(ggt)::numeric, 2) AS ggt
	, ROUND(AVG(ld_ldh)::numeric, 2) AS ld_ldh
	
-- 	, ROUND(AVG(sg)::numeric, 2) AS sg
-- 	, ROUND(AVG(ket)::numeric, 2) AS ket
-- 	--, ROUND(AVG(leuk)::numeric, 2) AS leuk
-- 	, ROUND(AVG(nit)::numeric, 2) AS nit
-- 	, ROUND(AVG(bil)::numeric, 2) AS bil
-- 	, ROUND(AVG(ubg)::numeric, 2) AS ubg
	
FROM mimic_hosp.lab_features
WHERE subject_id is not NULL AND hadm_id IS NOT NULL
GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd')