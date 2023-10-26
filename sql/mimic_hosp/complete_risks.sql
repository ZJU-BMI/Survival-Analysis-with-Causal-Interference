DROP MATERIALIZED VIEW IF EXISTS mimic_hosp.comp_risks_pats;
CREATE MATERIALIZED VIEW mimic_hosp.comp_risks_pats AS (
		-- septicemia
		WITH septicemia AS(
				SELECT subject_id, hadm_id, seq_num AS prior1, 1 AS sept
				FROM diagnoses_icd 
				WHERE icd_code IN('0383', '03840', '03841', '03842', '03843', '03844', '03849', '0388', '0389', '0545', '77181')
		)
		-- cerebral hemorrhage
		, cerebral_hemorrhage AS(
				SELECT subject_id, hadm_id, seq_num AS prior2, 1 AS cere_hemo 
				FROM diagnoses_icd 
				WHERE icd_code IN('431', '7670', 'I61', 'I610', 'I611', 'I612', 'I613', 'I614', 'I615', 'I616', 'I618', 'I619',
													'I691', 'I6910', 'I6911', 'I69110', 'I69111', 'I69112', 'I69113', 'I69114', 'I69115', 'I69118',
													'I69119', 'I6912', 'I69120', 'I69121', 'I69122', 'I69123', 'I69128', 'I6913',  'I69131', 'I69132', 
													'I69133', 'I69134', 'I69139', 'I6914', 'I69141', 'I69142', 'I69143', 'I69144', 'I69149', 'I6915',  
													'I69151', 'I69152', 'I69153', 'I69154', 'I69159', 'I6916',  'I69161', 'I69162', 'I69163', 'I69164', 
													'I69165', 'I69169', 'I6919', 'I69190', 'I69191', 'I69192', 'I69193', 'I69198', 'P101')
		)
		-- acute respiratory failure
		, acute_respiratory_failure AS(
				SELECT subject_id, hadm_id, seq_num AS prior3, 1 AS aresp_fail
				FROM diagnoses_icd 
				WHERE icd_code IN('51851' , '51881' ,'J960', 'J9600', 'J9601', 'J9602')
		)																					
		-- myocardial infarction
		, myocardial_infarction AS(
				SELECT subject_id, hadm_id, seq_num AS prior4, 1 AS my_inf  
				FROM diagnoses_icd 
				WHERE icd_code IN('41000', '41001', '41002', '41010', '41011', '41012', '41020', '41021', '41022', '41030', '41031',
													'41032', '41040', '41041', '41042', '41050', '41051', '41052', '41080', '41081', '41082', '41090',
													'41091', '41092', '4110', '41181', '412', '42979', 'I21', 'I210', 'I2101', 'I2102', 'I2109', 'I211',
													'I2111', 'I2119', 'I212', 'I2121', 'I2129', 'I213', 'I214', 'I219', 'I21A', 'I21A1', 'I21A9', 'I22',
													'I220', 'I221', 'I222', 'I228', 'I229', 'I23', 'I230', 'I231', 'I232', 'I233', 'I234', 'I235', 'I236',
													'I238', 'I240', 'I252')
		)	
		-- pneumonia																									
		, pneumonia AS(
				SELECT subject_id, hadm_id, seq_num AS prior5, 1 AS pneu  
				FROM diagnoses_icd 
				WHERE icd_code IN('00322', '01160', '01161', '01162', '01163', '01164', '01165', '01166', '0382', '0551', '0730', '11505', 
													'11515', '11595', '4800', '4801', '4802', '4803', '4808', '4809', '481', '4820', '4821', '4822', '48230', 
													'48231', '48232', '48239', '48240', '48241', '48242', '48249', '48281', '48282', '48283', '48284', '48289',  
													'4829', '4830', '4831', '4838', '4841', '4843', '4845', '4846', '4847', '4848', '485', '486', '4870',  
													'48801', '48811', '48881', '51630', '51635', '51636', '51637', '5171', '7700', 'A0103', '99731', '99732',  
													'A0222', 'A3700', 'A3701', 'A3710', 'A3711', 'A3780', 'A3781', 'A3790', 'A3791', 'A403', 'A5004', 'A5484',  
													'B012', 'B052', 'B0681', 'B7781', 'B953', 'B960', 'B961', 'J851', 'J09X1', 'J100', 'J1000', 'J1001', 'J1008',  
													'J110', 'J1100', 'J1108', 'J12', 'J120', 'J121', 'J122', 'J123', 'J128', 'J1281', 'J1289', 'J129', 'J13', 'J14',
													'J15', 'J150', 'J151', 'J152', 'J1520', 'J1521', 'J15211', 'J15212', 'J1529', 'J153', 'J154', 'J155', 'J156', 
													'J157', 'J158', 'J159', 'J16', 'J160', 'J168', 'J17', 'J18', 'J180', 'J181', 'J182', 'J188', 'J189', 'J200',
													'J8411', 'J84111', 'J84116', 'J84117', 'J842', 'J852', 'J95851', 'P23', 'P230', 'P231', 'P232', 'P233', 'P234',
													'P235', 'P236', 'P238', 'P239', 'V0382', 'V066', 'V1261', 'Z8701')
		)	
		, risks AS (
				SELECT ad.subject_id, ad.hadm_id, 
							(CASE WHEN sep.sept IS NULL THEN 0 ELSE 1 END) as sept, 
							(CASE WHEN ch.cere_hemo IS NULL THEN 0 ELSE 1 END) as cere_hemo,
							(CASE WHEN arf.aresp_fail IS NULL THEN 0 ELSE 1 END) as aresp_fail,
							(CASE WHEN mi.my_inf IS NULL THEN 0 ELSE 1 END) as my_inf,
							(CASE WHEN pn.pneu IS NULL THEN 0 ELSE 1 END) as pneu,
							(COALESCE(sept, 0) + COALESCE(cere_hemo, 0) + COALESCE(aresp_fail, 0) + COALESCE(my_inf, 0) + COALESCE(pneu, 0)) AS total,
							(CASE WHEN prior1 IS NULL THEN 99999 ELSE prior1 END) AS prior1,
							(CASE WHEN prior2 IS NULL THEN 99999 ELSE prior2 END) AS prior2,
							(CASE WHEN prior3 IS NULL THEN 99999 ELSE prior3 END) AS prior3,
							(CASE WHEN prior4 IS NULL THEN 99999 ELSE prior4 END) AS prior4,
							(CASE WHEN prior5 IS NULL THEN 99999 ELSE prior5 END) AS prior5
				FROM mimic_core.admissions ad
				LEFT JOIN septicemia sep ON sep.subject_id = ad.subject_id AND sep.hadm_id = ad.hadm_id
				LEFT JOIN cerebral_hemorrhage ch ON ch.subject_id = ad.subject_id AND ch.hadm_id = ad.hadm_id
				LEFT JOIN acute_respiratory_failure arf ON arf.subject_id = ad.subject_id AND arf.hadm_id = ad.hadm_id
				LEFT JOIN myocardial_infarction mi ON mi.subject_id = ad.subject_id AND mi.hadm_id = ad.hadm_id
				LEFT JOIN pneumonia pn ON pn.subject_id = ad.subject_id AND pn.hadm_id = ad.hadm_id
		)
		
		SELECT r.*,
		adm.age, adm.gender, adm.dod, adm.hospital_expire_flag, adm.hosp_stay
		FROM risks r
		LEFT JOIN mimic_core.admissions_detail_all adm ON adm.subject_id = r.subject_id AND adm.hadm_id = r.hadm_id
		WHERE total > 1 
);

