DROP MATERIALIZED VIEW IF EXISTS lab_features;
CREATE MATERIALIZED VIEW lab_features AS (
	SELECT 
		MAX(subject_id) AS subject_id, MAX(hadm_id) AS hadm_id, MAX(charttime) AS charttime, le.specimen_id
		-- blood count
		, MAX ( CASE WHEN itemid = 51221 AND valuenum > 10 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS hct
		, MAX ( CASE WHEN itemid = 51222 AND valuenum > 0 AND valuenum < 30 THEN valuenum ELSE NULL END ) AS hgb
		, MAX ( CASE WHEN itemid = 51248 AND valuenum > 10 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS mch
		, MAX ( CASE WHEN itemid = 51249 AND valuenum > 5 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS mchc
		, MAX ( CASE WHEN itemid = 51250 AND valuenum > 30 AND valuenum < 200 THEN valuenum ELSE NULL END ) AS mcv
		, MAX ( CASE WHEN itemid = 51265 AND valuenum > 40 AND valuenum < 400 THEN valuenum ELSE NULL END ) AS platelet
		, MAX ( CASE WHEN itemid = 51279 AND valuenum > 0 AND valuenum < 10 THEN valuenum ELSE NULL END ) AS rbc
		, MAX ( CASE WHEN itemid = 51277 AND valuenum > 0 AND valuenum < 50 THEN valuenum ELSE NULL END ) AS rdw
		, MAX ( CASE WHEN itemid = 51301 AND valuenum > 0 AND valuenum < 40 THEN valuenum ELSE NULL END ) AS wbc
		-- blood diff
		, MAX ( CASE WHEN itemid = 51244 AND valuenum > 0 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS lym
		, MAX ( CASE WHEN itemid = 51256 AND valuenum > 0 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS neut
		, MAX ( CASE WHEN itemid = 51254 AND valuenum > 0 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS mono
		, MAX ( CASE WHEN itemid = 51200 AND valuenum > 0 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS eosi
		, MAX ( CASE WHEN itemid = 51146 AND valuenum > 0 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS baso
		
		-- blood gas
		, MAX ( CASE WHEN itemid = 50818 AND valuenum > 10 AND valuenum < 80 THEN valuenum ELSE NULL END ) AS pco2
		, MAX ( CASE WHEN itemid = 50821 AND valuenum > 50 AND valuenum < 125 THEN valuenum ELSE NULL END ) AS po2
		, MAX ( CASE WHEN itemid = 50804 AND valuenum > 5 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS tco2
		, MAX ( CASE WHEN itemid = 50802 AND valuenum > -15 AND valuenum < 15 THEN valuenum ELSE NULL END ) AS base_excess
		-- blood lipids
-- 		, MAX ( CASE WHEN itemid = 50907 THEN valuenum ELSE NULL END ) AS tc
-- 		, MAX ( CASE WHEN itemid = 51000 THEN valuenum ELSE NULL END ) AS tg
-- 		, MAX ( CASE WHEN itemid = 50904 THEN valuenum ELSE NULL END ) AS hdlc
-- 		, MAX ( CASE WHEN itemid = 50905 THEN valuenum ELSE NULL END ) AS ldlc
		-- chemistry
		, MAX ( CASE WHEN itemid = 50862 AND valuenum > 0 AND valuenum < 20 THEN valuenum ELSE NULL END ) AS albumin
		, MAX ( CASE WHEN itemid = 50930 AND valuenum > 0 AND valuenum < 20 THEN valuenum ELSE NULL END ) AS globulin
		, MAX ( CASE WHEN itemid = 50976 AND valuenum > 0 AND valuenum < 40 THEN valuenum ELSE NULL END ) AS total_protein
		, MAX ( CASE WHEN itemid = 50868 AND valuenum > 5 AND valuenum < 30 THEN valuenum ELSE NULL END ) AS aniongap
		, MAX ( CASE WHEN itemid = 50882 AND valuenum > 5 AND valuenum < 60 THEN valuenum ELSE NULL END ) AS bicarbonate
		, MAX ( CASE WHEN itemid = 51006 AND valuenum > 5 AND valuenum < 70 THEN valuenum ELSE NULL END ) AS bun
		, MAX ( CASE WHEN itemid = 50893 AND valuenum > 0 AND valuenum < 50 THEN valuenum ELSE NULL END ) AS calcium
		, MAX ( CASE WHEN itemid = 50902 AND valuenum > 0 AND valuenum < 300 THEN valuenum ELSE NULL END ) AS chloride
		, MAX ( CASE WHEN itemid = 50912 AND valuenum > 0 AND valuenum < 5 THEN valuenum ELSE NULL END ) AS creatinine
		, MAX ( CASE WHEN itemid = 50931 AND valuenum > 80 AND valuenum < 200 THEN valuenum ELSE NULL END ) AS glucose
		, MAX ( CASE WHEN itemid = 50983 AND valuenum > 5 AND valuenum < 200 THEN valuenum ELSE NULL END ) AS sodium
		, MAX ( CASE WHEN itemid = 50971 AND valuenum > 0 AND valuenum < 10 THEN valuenum ELSE NULL END ) AS potassium
		, MAX ( CASE WHEN itemid = 50960 AND valuenum > 0 AND valuenum < 10 THEN valuenum ELSE NULL END ) AS magnesium
		, MAX ( CASE WHEN itemid = 50970 AND valuenum > 0 AND valuenum < 15 THEN valuenum ELSE NULL END ) AS phosphate
		, MAX ( CASE WHEN itemid = 50813 AND valuenum > 0 AND valuenum < 15 THEN valuenum ELSE NULL END ) AS lactate
		, MAX ( CASE WHEN itemid = 50820 AND valuenum > 0 AND valuenum < 50 THEN valuenum ELSE NULL END ) AS ph
		-- coagulation
		, MAX ( CASE WHEN itemid = 51237 AND valuenum > 0 AND valuenum < 5 THEN valuenum ELSE NULL END ) AS inr				-- 国际标准化比值
		, MAX ( CASE WHEN itemid = 52187 AND valuenum > 0 AND valuenum < 40 THEN valuenum ELSE NULL END ) AS tt					-- 凝血酶时间
		, MAX ( CASE WHEN itemid = 51274 AND valuenum > 0 AND valuenum < 45 THEN valuenum ELSE NULL END ) AS pt					-- 凝血酶原时间
		, MAX ( CASE WHEN itemid = 51275 AND valuenum > 15 AND valuenum < 65 THEN valuenum ELSE NULL END ) AS ptt 				-- 部分凝血酶原时间
		-- enzyme				
		, MAX ( CASE WHEN itemid = 50861 AND valuenum > 0 AND valuenum < 90 THEN valuenum ELSE NULL END ) AS alt
		, MAX ( CASE WHEN itemid = 50863 AND valuenum > 30 AND valuenum < 180 THEN valuenum ELSE NULL END ) AS alp
		, MAX ( CASE WHEN itemid = 50878 AND valuenum > 0 AND valuenum < 80 THEN valuenum ELSE NULL END ) AS ast
		, MAX ( CASE WHEN itemid = 50867 THEN valuenum ELSE NULL END ) AS amylase
		, MAX ( CASE WHEN itemid = 50885 AND valuenum > 0 AND valuenum < 3 THEN valuenum ELSE NULL END ) AS bil_total
		, MAX ( CASE WHEN itemid = 50910 THEN valuenum ELSE NULL END ) AS ck_cpk
		, MAX ( CASE WHEN itemid = 50911 THEN valuenum ELSE NULL END ) AS ck_mb
		, MAX ( CASE WHEN itemid = 50927 THEN valuenum ELSE NULL END ) AS ggt
		, MAX ( CASE WHEN itemid = 50954 THEN valuenum ELSE NULL END ) AS ld_ldh
		-- urine rountine
-- 		, MAX ( CASE WHEN itemid = 51498 THEN valuenum ELSE NULL END ) AS sg
-- 		, MAX ( CASE WHEN itemid = 51484 THEN valuenum ELSE NULL END ) AS ket
-- 		, MAX ( CASE WHEN itemid = 51486 THEN valuenum ELSE NULL END ) AS leuk
-- 		, MAX ( CASE WHEN itemid = 51487 THEN valuenum ELSE NULL END ) AS nit
-- 		, MAX ( CASE WHEN itemid = 51464 THEN valuenum ELSE NULL END ) AS bil
-- 		, MAX ( CASE WHEN itemid = 51514 THEN valuenum ELSE NULL END ) AS ubg
	FROM mimic_hosp.labevents le
	WHERE
		le.itemid IN (
			51221  -- hematocrit %
			, 51222 -- hemoglobin g/dL
			, 51248 -- MCH pg
			, 51249 -- MCHC	g/dL
			, 51250 -- MCV fL
			, 51265 -- platelets 
			, 51279 -- RBC
			, 51277 -- RDW
			--, 52159 -- RDW SD
			, 51301 -- WBC K/uL
			
		  , 51244 -- lymphocytes %
		  , 51256 -- neutrophils %
		  , 51254 -- monocytes %
		  , 51200 -- eosinophils %
		  , 51146 -- basophlis %
			
			, 50818 -- pco2
			, 50821 -- po2
			, 50804 -- tco2 
			, 50802 -- base_excess
			
			, 50907 -- Total cholesterol 
			, 51000 -- Triglycerides
			, 50905 -- Low-density lipoprotein cholesterol
			, 50904 -- High-density lipoprotein cholesterol
			
			, 50862 -- ALBUMIN | CHEMISTRY | BLOOD | 146697
			, 50930 -- Globulin
			, 50976 -- Total protein
			, 50868 -- ANION GAP | CHEMISTRY | BLOOD | 769895
			, 50882 -- BICARBONATE | CHEMISTRY | BLOOD | 780733
			, 50893 -- Calcium
			, 50912 -- CREATININE | CHEMISTRY | BLOOD | 797476
			, 50902 -- CHLORIDE | CHEMISTRY | BLOOD | 795568
			, 50931 -- GLUCOSE | CHEMISTRY | BLOOD | 748981
			, 50971 -- POTASSIUM | CHEMISTRY | BLOOD | 845825
			, 50983 -- SODIUM | CHEMISTRY | BLOOD | 808489
			, 51006 -- UREA NITROGEN | CHEMISTRY | BLOOD | 791925
			, 50960 -- magnesium
			, 50970 -- phosphate
			, 50813 -- lactate
			, 50820 -- ph
			
			, 51237 -- INR
			, 51274 -- PT
			, 52187 -- TT
			, 51275 -- PTT
			
			, 50861 -- Alanine transaminase (ALT) 丙氨酸转氨酶
			, 50863 -- Alkaline phosphatase (ALP) 碱性磷酸酶
			, 50878 -- Aspartate transaminase (AST) 天冬氨酸转氨酶
			, 50867 -- Amylase 淀粉酶
			, 50885 -- total Bilirubin 总胆红素
			, 50910 -- ck_cpk	肌酸激酶
			, 50911 -- CK-MB	肌酸激酶同工酶
			, 50927 -- Gamma Glutamyltransferase (GGT) γ谷氨酰转移酶
			, 50954 -- Lactate Dehydrogenase (LD)	乳酸脱氢酶
			
			, 51498 -- Specific Gravity
			, 51484 -- Ketone
			, 51486 -- Leukocytes
			, 51487 -- Nitrite
			, 51464 -- Bilirubin
			, 51514 -- Urobilinogen 
			
		)
		AND valuenum IS NOT NULL
		GROUP BY le.specimen_id
)



