-- SELECT * FROM drug_cnt WHERE lower(label) like '%dextrose%'

DROP MATERIALIZED VIEW IF EXISTS drug;
CREATE MATERIALIZED VIEW drug AS (
	SELECT subject_id, hadm_id, starttime AS charttime
	, AVG(case when itemid in (225158) THEN ROUND(amount::numeric, 2) else null end) as NaCl_09		-- 生理盐水 0.9% ml
	, AVG(case when itemid in (220949, 220952, 220950, 228140, 228142, 228141) 
				THEN ROUND(amount::numeric, 2) else null end) as Dextrose	-- 葡萄糖 ml
	, AVG(case when itemid in (226452) THEN ROUND(amount::numeric, 2) else null end) as PO_Intake -- ? pL
	, AVG(case when itemid in (222168) THEN ROUND(amount::numeric, 2) else null end) as Propofol	-- 丙泊酚 mg
	, AVG(case when itemid in (221906) THEN ROUND(amount::numeric, 2) else null end) as Norepinephrine -- 去甲肾上腺素 mg
	, AVG(case when itemid in (225799) THEN ROUND(amount::numeric, 2) else null end) as Gastric_Med -- 胃药 ml
	, AVG(case when itemid in (223258, 223262, 223260, 223259, 229299, 223257, 223261, 229619) 
				THEN ROUND(amount::numeric, 2) else null end) as Insulin  -- 胰岛素 units
	, AVG(case when itemid in (226453) THEN ROUND(amount::numeric, 2) else null end) as GT_Flush -- ? ml
	, AVG(case when itemid in (221744, 225942) THEN ROUND(amount::numeric, 2) else null end) as Fentanyl -- 芬太尼 mg
	, AVG(case when itemid in (221749, 229630, 229632) THEN ROUND(amount::numeric, 2) else null end) as Phenylephrine -- 去氧肾上腺素 mg
	, AVG(case when itemid in (225166) THEN ROUND(amount::numeric, 2) else null end) as KCL -- KCL nMol/ml/min
	, AVG(case when itemid in (225975) THEN ROUND(amount::numeric, 2) else null end) as Heparin_Sodium -- 肝素钠 mg
	, AVG(case when itemid in (225798) THEN ROUND(amount::numeric, 2) else null end) as Vancomycin -- 万古霉素 mg
	, AVG(case when itemid in (221668) THEN ROUND(amount::numeric, 2) else null end) as midazolam -- 咪达唑仑 mg
	, AVG(case when itemid in (225828) THEN ROUND(amount::numeric, 2) else null end) as LR -- 指乳酸林格氏液? ml
	, AVG(case when itemid in (221833) THEN ROUND(amount::numeric, 2) else null end) as hydromorphone -- 氢吗啡酮 mg
	, AVG(case when itemid in (221794, 228340) THEN ROUND(amount::numeric, 2) else null end) as furosemide -- 呋塞米 mg
	
	FROM mimic_icu.inputevents
	WHERE itemid IN (
		225158
		, 220949, 220952, 220950, 228140, 228142, 228141
		, 226452
		, 222168
		, 221906
		, 225799
		, 223258, 223262, 223260, 223259, 229299, 223257, 223261, 229619
		, 226453
		, 221744, 225942
		, 221749, 229630, 229632
		, 225166
		, 225975
		, 225798
		, 221668
		, 225828
		, 221833
		, 221794, 228340
	)
	GROUP BY subject_id, hadm_id, starttime
);

SELECT 
	subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd') AS charttime
	, ROUND(AVG(NaCl_09)::numeric, 2) AS NaCl_09
	, ROUND(AVG(Dextrose)::numeric, 2) AS Dextrose
	, ROUND(AVG(PO_Intake)::numeric, 2) AS PO_Intake
	, ROUND(AVG(Propofol)::numeric, 2) AS Propofol
	, ROUND(AVG(Norepinephrine)::numeric, 2) AS Norepinephrine
	, ROUND(AVG(Gastric_Med)::numeric, 2) AS Gastric_Med
	, ROUND(AVG(Insulin)::numeric, 2) AS Insulin
	, ROUND(AVG(GT_Flush)::numeric, 2) AS GT_Flush
	, ROUND(AVG(Fentanyl)::numeric, 2) AS Fentanyl
	, ROUND(AVG(Phenylephrine)::numeric, 2) AS Phenylephrine
	, ROUND(AVG(KCL)::numeric, 2) AS KCL
	, ROUND(AVG(Heparin_Sodium)::numeric, 2) AS Heparin_Sodium
	, ROUND(AVG(Vancomycin)::numeric, 2) AS Vancomycin
	, ROUND(AVG(midazolam)::numeric, 2) AS midazolam
	, ROUND(AVG(LR)::numeric, 2) AS LR
	, ROUND(AVG(hydromorphone)::numeric, 2) AS hydromorphone
	, ROUND(AVG(furosemide)::numeric, 2) AS furosemide
	
FROM mimic_icu.drug
	GROUP BY subject_id, hadm_id, to_char(charttime, 'yyyy-MM-dd')

