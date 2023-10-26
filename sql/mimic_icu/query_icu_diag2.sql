DROP MATERIALIZED VIEW IF EXISTS icu_diag_first2 CASCADE;
CREATE MATERIALIZED VIEW icu_diag_first2 AS(
WITH subjects AS(
	SELECT *
		-- 1 septicemia/sepsis
		, CASE WHEN icd_code IN(
													-- septicemia
													'0545', '03812', '03811', '03849', '0382', '0388', '03819', '0031', '0383', '03842', 
													'03840', '03841', '03843', '03844', '03810', '0380', '0389',
													-- sepsis
													'A427', 'B377', 'A5486', 'A4150', 'A4159',  'A4189',  'A408',   'O85',    '67022',  '67024',  
													'A021',   '99591',  'A4181',  'A4151',  'A413',   'A4102',  'A4101',  'A4152',  'A4153',  
													'A403',   'A414',   'A411',   'A400',   'A401',   'A412',   'T8144XA','T8144XD','O8604',  
													'O0337', 'A419',  '99592',  'R6521',  'R6520',  'A409') THEN 1
													
			 
			 -- 2 cerebral hemorrhage
 			 WHEN icd_code IN('I69120', 'I69193', 'I6911',  'I69122', 'I69191', 'I69121', 'I69192', 'I69152', 'I69154', 
 											'I69151', 'I69153', '431',    'I613',   'I614',   'I611',   'I610',   'I612',   'I615',   
 											'I616',   'I619',   'I618',  'I69165', 'I69198', 'I69128', 'I69119' ) THEN 2
											
			 -- 3	acute respiratory failure						
 			 WHEN icd_code IN('J95822', '51884',  '51853',  'J9622',  'J9621',  'J9620',  'J95821', '51881',  '51851',  
 											  'J9602',  'J9601',  'J9600'  ) THEN 3
				
			 -- 4 myocardial infarction													
 			 WHEN icd_code IN('I240',   '41001',  '41002',  '41021',  '41022', '41031',  '41032',  '41010',  '41011',  
												'41012',  '41040',  '41041',  '41042',  '41051',  '41081',  '41082',  '41090',  
												'41091',  '41092',  'I219',   '42979',  'I21A1',  'I214',   '412',    'I252',   'I238',   
												'I21A9',  '4110',   'I235',   'I2102',  'I2121', 'I2101',  'I2109',  'I2119',  'I2129',  
												'I2111',  'I213',   'I220',   'I221',   'I228',   'I229',   'I222',  'I236',   'I232') THEN 4
												
			 -- 5 heart failure										
 			 WHEN icd_code IN('I5041',  '42841',  'I5031',  '42831',  'I5043',  '42843',  'I5033',  '42833',  'I50813', 
												'I5023',  '42823',  'I50811', 'I5021',  '42821',  '40211',   'I5082',  'I5042',  '42842',  
												'I5032',  '42832',  'I50812', 'I5022',  '42822',  '42840',  '4280',   '42830',  'I5084',  
												'4289',   'I509',   'I130',   'I132',     '40411',   '40401',  '40403',    '40493',  
												'40491',     'I110',     '4281',   '40201',  'I5089',  'I97130', 'I97131', 'I0981',  
												'39891',  'I50814', 'I50810', '42820',  'I5040',  'I5030',  '40291',   'I5020')		THEN 5
												
			-- 6 pneumonia/pneumonitis
			WHEN icd_code IN('J851', 'J120', '4829', '485', 'J180', '51636', 'J84116', '51637',  'J84117', 'J123',   
 											'11505',  '48811',  '48801',  '48881',  'J09X1',  'J1008',  'J1001',  'J1000',  'J1108',  
 											'J1100', '4870',    'J181',   '48242',  '48241',  'V066',   '48249',  'J188',    'J1289',  
 											'J122',  'V1261',  'Z8701',  '481',    'J155',   'J14',    '4822',   '4820',   'J150',   
 											'48284',  'J15212', 'J15211', 'J157',   '4821',   'J151',   '48240', 'J13',    '48231',  
 											'48232',  '48230',  '4800',   '48281',  '48282',  '4830',   'J156',  '48239',  '48283',  
 											'48289',  'J158',   'J168',   '4838',  'J1529',  'J154',   '4808',   '4802',   '4801',   
 											'J1520',  'J153',   '4846',   '4841',   'J17',    '4848',   '4847',   '486',    'J189',   
											'99732',  'J121',   'A0222',   'B953',  'J159',   'B012',   '99731',  'J95851', '4809',   
 											'J129', '4957', '51633', 'J680', '5060', 'J954', 'B250',  'J678',  'J679',   'J84113', 
											'4958', 'J690', '5070', '5071', 'J691', 'J698', '5078', '4959', '0521')	THEN 6
											
			 -- 7 cerebral infarction
			WHEN icd_code IN('I69320', 'I69390', 'I69393', 'I69310',  '43411',  'I636',  'I6312', 
											 'I63423', 'I63133', 'I63443', 'I63413', 'I63433', 'I63422', 'I63132', 'I63442', 'I63412', 
											 'I63432', 'I63112', 'I6349',  'I6319',  'I63421', 'I63131', 'I63441', 'I63411', 'I63431', 
											 'I63111', 'I63429', 'I63139', 'I63449', 'I6340',  'I63419', 'I63439', 'I6310',  'I63119', 
											 'I6302',  'I63343', 'I63313', 'I63333', 'I63013', 'I63322', 'I63032', 'I63342', 'I63312', 
											 'I63332', 'I63012', 'I6339',  'I6309', 'I63321', 'I63031', 'I63341', 'I63311', 'I63331', 
											 'I63011', 'I63349', 'I6330',  'I6322',  'I63523', 'I63233', 'I63543', 'I63513', 'I63533', 
											 'I63213', 'I63522', 'I63232','I63542', 'I63512', 'I63532', 'I63212', 'I6359',  'I6329',  
											 'I63521', 'I63231', 'I63541', 'I63511', 'I63531', 'I63211', 'I63529', 'I63239', 'I63549', 
											 'I6350',  'I6320',  'I639',   '43401',  'I6931',  'I69315', 'I69322', 'I69391', 
											 'I69321', 'I69392','I69323', 'I69354', 'I69351', 'I69353', 'I69359', 'I69311', 'I69344', 
 											 'I69341', 'I69334', 'I69331', '43301',   '43311',   '43331',    '43381',    '43391',  
											 '43321',   'I638',   'I6389',  'I6381',  'I69369', 'I69365', 'I69398', 'I69328', 'I69318', 
 											 'V1254',  'Z8673',  'I69313','I6930',  'I69319', 'I69312') THEN 7
																		 
			-- 8 subarachnoid hemorrhage						 
 			WHEN icd_code IN('I69020', 'I6901',  'I69092', 'I69054', 'I69051', 'I602',   'I604',   'I6022',  'I6002',  
 											'I6012',  'I6032',  'I6052',  'I606',   'I6021',  'I6001',  'I6011', 'I6031',  'I6051',  
 											'I6020',  'I607',   'I6010',  'I609',   'I608',   'I69098', 'I69028', '430',    '85216',  
											'85211',  '85200',  '85202',  '85209',  '85206',  '85203',  '85201',  '85204',  '85205',  
 											'S066X6A','S066X3A','S066X1A','S066X7A','S066X8A','S066X9A','S066X9D','S066X0A','S066X0S',
 											'S066X0D') THEN 8
																					
			-- 9 neoplasm of bronchus and lungs
 			WHEN icd_code IN('1622   ', '1623   ', '1624   ','1625   ', '1629   ', '1628   ', '1970  ', 'C3401  ',
												'C3411  ', 'C3412  ', 'C342   ', 'C3431  ', 'C3432  ','C3481  ', 'C3482  ', 'C3490  ',
												'C7800', 'C7801 ', 'C7802  ', '2123   ', 'D1432  ','C3402  ','C3430  ','C3400  ','C3492  ',
												'C3491  ','D381   ','2357   ') THEN 9
																					
			-- 10 cirrhosis of liver
			WHEN icd_code IN('5712', 'K7031', 'K7030', '5715', 'K7469', 'K717', 'K7460') THEN 10	
			
			
			-- 11 acute kidney failure
			WHEN icd_code IN('66932', '66934', 'N171', '5847', '5845', '5848', 'N170', '5849', 'N179', 'N178', 'O904', 'N990') THEN 11	
			ELSE 0 END AS diag
												
	 FROM icu_diags WHERE seq_num = 1 
)

, subj_diag AS (
	SELECT s.subject_id, s.hadm_id, s.hospital_expire_flag, ids.icd_code, ids.icd_version, ids.long_title
	FROM subjects s 
	LEFT JOIN icu_diags ids ON s.subject_id = ids.subject_id AND s.hadm_id = ids.hadm_id
)

-- 1 septicemia and sepsis
, sep AS (
	SELECT subject_id, hadm_id, 1 AS sep
	FROM subj_diag 
	WHERE icd_code IN(-- septicemia
										'0545', '03812', '03811', '03849', '0382', '0388', '03819', '0031', '0383', '03842', 
										'03840', '03841', '03843', '03844', '03810', '0380', '0389',
										-- sepsis
										'A427', 'B377', 'A5486', 'A4150', 'A4159',  'A4189',  'A408',   'O85',    '67022',  '67024',  
 										'A021',   '99591',  'A4181',  'A4151',  'A413',   'A4102',  'A4101',  'A4152',  'A4153',  
										'A403',   'A414',   'A411',   'A400',   'A401',   'A412',   'T8144XA','T8144XD','O8604',  
 										'O0337', 'A419',  '99592',  'R6521',  'R6520',  'A409')
	GROUP BY subject_id, hadm_id
)	

-- 2 cerebral hemorrhage
, ch AS (
		SELECT subject_id, hadm_id, 1 AS ch
		FROM subj_diag
		WHERE icd_code IN('I69120', 'I69193', 'I6911',  'I69122', 'I69191', 'I69121', 'I69192', 'I69152', 'I69154', 
											'I69151', 'I69153', '431',    'I613',   'I614',   'I611',   'I610',   'I612',   'I615',   
											'I616',   'I619',   'I618',  'I69165', 'I69198', 'I69128', 'I69119' )
		GROUP BY subject_id, hadm_id
)

-- 3 Acute respiratory failure
, arf AS (
		SELECT subject_id, hadm_id, 1 AS arf
		FROM subj_diag
		WHERE icd_code IN('J95822', '51884',  '51853',  'J9622',  'J9621',  'J9620',  'J95821', '51881',  '51851',  
											'J9602',  'J9601',  'J9600'  )
		GROUP BY subject_id, hadm_id
)

-- 4 myocardial infarction
, mi AS (
		SELECT subject_id, hadm_id, 1 AS mi
		FROM subj_diag
		WHERE icd_code IN('I240',   '41001',  '41002',  '41021',  '41022', '41031',  '41032',  '41010',  '41011',  
											'41012',  '41040',  '41041',  '41042',  '41051',  '41081',  '41082',  '41090',  
											'41091',  '41092',  'I219',   '42979',  'I21A1',  'I214',   '412',    'I252',   'I238',   
											'I21A9',  '4110',   'I235',   'I2102',  'I2121', 'I2101',  'I2109',  'I2119',  'I2129',  
											'I2111',  'I213',   'I220',   'I221',   'I228',   'I229',   'I222',  'I236',   'I232'   )
		GROUP BY subject_id, hadm_id
)

-- 5 heart failure
, hf AS (
		SELECT subject_id, hadm_id, 1 AS hf
		FROM subj_diag
		WHERE icd_code IN('I5041',  '42841',  'I5031',  '42831',  'I5043',  '42843',  'I5033',  '42833',  'I50813', 
											'I5023',  '42823',  'I50811', 'I5021',  '42821',  '40211',   'I5082',  'I5042',  '42842',  
											'I5032',  '42832',  'I50812', 'I5022',  '42822',  '42840',  '4280',   '42830',  'I5084',  
											'4289',   'I509',   'I130',   'I132',     '40411',   '40401',  '40403',    '40493',  
											'40491',     'I110',     '4281',   '40201',  'I5089',  'I97130', 'I97131', 'I0981',  
											'39891',  'I50814', 'I50810', '42820',  'I5040',  'I5030',  '40291',   'I5020'  )
		GROUP BY subject_id, hadm_id
)

-- 6 pneumonia and pneumonitis
, pneu AS (
		SELECT subject_id, hadm_id, 1 AS pneu
		FROM subj_diag
		WHERE icd_code IN('J851', 'J120', '4829', '485', 'J180', '51636', 'J84116', '51637',  'J84117', 'J123',   
											'11505',  '48811',  '48801',  '48881',  'J09X1',  'J1008',  'J1001',  'J1000',  'J1108',  
											'J1100', '4870',    'J181',   '48242',  '48241',  'V066',   '48249',  'J188',    'J1289',  
											'J122',  'V1261',  'Z8701',  '481',    'J155',   'J14',    '4822',   '4820',   'J150',   
											'48284',  'J15212', 'J15211', 'J157',   '4821',   'J151',   '48240', 'J13',    '48231',  
											'48232',  '48230',  '4800',   '48281',  '48282',  '4830',   'J156',  '48239',  '48283',  
											'48289',  'J158',   'J168',   '4838',  'J1529',  'J154',   '4808',   '4802',   '4801',   
											'J1520',  'J153',   '4846',   '4841',   'J17',    '4848',   '4847',   '486',    'J189',   
											'99732',  'J121',   'A0222',   'B953',  'J159',   'B012',   '99731',  'J95851', '4809',   
											'J129', '4957', '51633', 'J680', '5060', 'J954', 'B250',  'J678',  'J679',   'J84113', 
											'4958', 'J690', '5070', '5071', 'J691', 'J698', '5078', '4959', '0521'   )
		GROUP BY subject_id, hadm_id
)

-- 7 subarachnoid hemorrhage
, sh AS (
		SELECT subject_id, hadm_id, 1 AS sh
		FROM subj_diag
		WHERE icd_code IN('I69020', 'I6901',  'I69092', 'I69054', 'I69051', 'I602',   'I604',   'I6022',  'I6002',  
											'I6012',  'I6032',  'I6052',  'I606',   'I6021',  'I6001',  'I6011', 'I6031',  'I6051',  
											'I6020',  'I607',   'I6010',  'I609',   'I608',   'I69098', 'I69028', '430',    '85216',  
											'85211',  '85200',  '85202',  '85209',  '85206',  '85203',  '85201',  '85204',  '85205',  
											'S066X6A','S066X3A','S066X1A','S066X7A','S066X8A','S066X9A','S066X9D','S066X0A','S066X0S',
											'S066X0D')
		GROUP BY subject_id, hadm_id
)

-- 8 Cerebral infarction
, ci AS (
		SELECT subject_id, hadm_id, 1 AS ci
		FROM subj_diag
		WHERE icd_code IN('I69320', 'I69390', 'I69393', 'I69310', '43411',  'I636',  'I6312', 
											'I63423', 'I63133', 'I63443', 'I63413', 'I63433', 'I63422', 'I63132', 'I63442', 'I63412', 
											'I63432', 'I63112', 'I6349',  'I6319',  'I63421', 'I63131', 'I63441', 'I63411', 'I63431', 
											'I63111', 'I63429', 'I63139', 'I63449', 'I6340',  'I63419', 'I63439', 'I6310',  'I63119', 
											'I6302',  'I63343', 'I63313', 'I63333', 'I63013', 'I63322', 'I63032', 'I63342', 'I63312', 
											'I63332', 'I63012', 'I6339',  'I6309', 'I63321', 'I63031', 'I63341', 'I63311', 'I63331', 
											'I63011', 'I63349', 'I6330',  'I6322',  'I63523', 'I63233', 'I63543', 'I63513', 'I63533', 
											'I63213', 'I63522', 'I63232','I63542', 'I63512', 'I63532', 'I63212', 'I6359',  'I6329',  
											'I63521', 'I63231', 'I63541', 'I63511', 'I63531', 'I63211', 'I63529', 'I63239', 'I63549', 
											'I6350',  'I6320',  'I639',   '43401',  'I6931',  'I69315', 'I69322', 'I69391', 
											'I69321', 'I69392','I69323', 'I69354', 'I69351', 'I69353', 'I69359', 'I69311', 'I69344', 
											'I69341', 'I69334', 'I69331', '43301',   '43311',   '43331',    '43381',    '43391',  
											'43321',   'I638',   'I6389',  'I6381',  'I69369', 'I69365', 'I69398', 'I69328', 'I69318', 
											'V1254',  'Z8673',  'I69313','I6930',  'I69319', 'I69312' )
		GROUP BY subject_id, hadm_id
)

-- 9 neoplasm of bronchus and lungs
, nobl AS (
		SELECT subject_id, hadm_id, 1 AS nobl
		FROM subj_diag
		WHERE icd_code IN('1622   ', '1623   ', '1624   ','1625   ', '1629   ', '1628   ', '1970  ', 'C3401  ',
												'C3411  ', 'C3412  ', 'C342   ', 'C3431  ', 'C3432  ','C3481  ', 'C3482  ', 'C3490  ',
												'C7800', 'C7801 ', 'C7802  ', '2123   ', 'D1432  ','C3402  ','C3430  ','C3400  ','C3492  ',
												'C3491  ','D381   ','2357   ')
		GROUP BY subject_id, hadm_id
)

-- 10 cirrhosis of liver
, col AS (
	SELECT subject_id, hadm_id, 1 AS col
		FROM subj_diag
		WHERE icd_code IN('5712',   'K7031', 'K7030',  '5715',   'K7469',  'K717',   'K7460'  )
		GROUP BY subject_id, hadm_id
)

-- 11 acute kidney failure
, akf AS (
	SELECT subject_id, hadm_id, 1 AS akf
		FROM subj_diag
		WHERE icd_code IN('66932', '66934', 'N171', '5847', '5845', '5848', 'N170', '5849', 'N179', 'N178', 'O904', 'N990')
		GROUP BY subject_id, hadm_id
)

-- 12 cardiac arrest
, ca AS (
	SELECT subject_id, hadm_id, 1 AS ca
		FROM subj_diag
		WHERE icd_code IN('4275', 'I468', 'I462', 'I469', 'I97710', 'I97711', 'V1253', 'Z8674', 'I97120', 'I97121' )
		GROUP BY subject_id, hadm_id
)

-- 13 leukemia
, leu AS (
	SELECT subject_id, hadm_id, 1 AS leu
		FROM subj_diag
		WHERE icd_code IN('C9500',  '20800',  'C9100',  'C9102',  'C9101',  '20402',  '20401',  '20400',  'C9420',  'C9421',  
											'C9300',  '20600', 'C9202',  'C9201',  'C9200',  'C92A0',  '20502',  '20501',  '20500',  
											'C9250',  'C9240',  'C9150',  'C9152',  'C9221',  'C9511',  'C9111',  'C9110',  '20412',  
											'20411',  '20410', 'C9211',  'C9210',  '20512',  '20511',  '20510',  'C9310',  'V166',   
											'Z806',   'C9140',  'C9142', 'C9141',  'C9590',  'C9591',  'C9191', '20722',  'C9290',  
											'C91Z0',  '20482',  'C91Z2',  'C91Z1',  '20480',  'C92Z0',  'C92Z2',  'C92Z1',  '20780',  
											'C9480',  'Z856',   'C9010',  '20312',  '20891',  '20890', '20492',  '20490')
		GROUP BY subject_id, hadm_id
)

-- 14 hepatic failure 
, hepf AS (
	SELECT subject_id, hadm_id, 1 AS hepf
		FROM subj_diag
		WHERE icd_code IN('K7201', 'K7200',  'K7041',  'K7040',  'K7211',  'K7210',  'K7291', 'K7290',  'K9182')
		GROUP BY subject_id, hadm_id
)

-- 15 ventricular tachycardia
, vt AS (
	SELECT subject_id, hadm_id, 1 AS vt
		FROM subj_diag
		WHERE icd_code IN('4270',   '4271',   'I471',   'I472'   )
		GROUP BY subject_id, hadm_id
)

-- 16 pancreatitis
, panc AS (
	SELECT subject_id, hadm_id, 1 AS panc
		FROM subj_diag
		WHERE icd_code IN('5770',   'K8592',  'K8591',  'K8590',  'K859',   'K852',   'K8522',  'K8521',  'K8520',  'K860',   
											'K851',   'K8512',  'K8511',  'K8510',  '5771',   'K853',   'K8531',  'K8530',  'K8502',  'K8500',  
											'K858',   'K8582',  'K8581',  'K8580',  'K861'   )
		GROUP BY subject_id, hadm_id
)

-- 17 diabetes
, diab AS (
	SELECT subject_id, hadm_id, 1 AS diab
		FROM subj_diag
		WHERE LOWER(long_title) LIKE '%diabetes%'
		GROUP BY subject_id, hadm_id
)


SELECT s.subject_id, s.hadm_id, s.hospital_expire_flag, s.diag, s.icd_code, s.long_title
							, (CASE WHEN sep.sep IS NULL THEN 0 ELSE 1 END) as sep
 							, (CASE WHEN ch.ch IS NULL THEN 0 ELSE 1 END) as ch
 							, (CASE WHEN arf.arf IS NULL THEN 0 ELSE 1 END) as arf
 							, (CASE WHEN mi.mi IS NULL THEN 0 ELSE 1 END) as mi
 							, (CASE WHEN hf.hf IS NULL THEN 0 ELSE 1 END) as hf
 							, (CASE WHEN pneu.pneu IS NULL THEN 0 ELSE 1 END) as pneu
							, (CASE WHEN ci.ci IS NULL THEN 0 ELSE 1 END) as ci
 							, (CASE WHEN sh.sh IS NULL THEN 0 ELSE 1 END) as sh
							, (CASE WHEN nobl.nobl IS NULL THEN 0 ELSE 1 END) as nobl
 							, (CASE WHEN col.col IS NULL THEN 0 ELSE 1 END) as col
							, (CASE WHEN akf.akf IS NULL THEN 0 ELSE 1 END) as akf
							, (CASE WHEN ca.ca IS NULL THEN 0 ELSE 1 END) as ca
							, (CASE WHEN leu.leu IS NULL THEN 0 ELSE 1 END) as leu
							, (CASE WHEN hepf.hepf IS NULL THEN 0 ELSE 1 END) as hepf
							, (CASE WHEN panc.panc IS NULL THEN 0 ELSE 1 END) as panc
							, (CASE WHEN vt.vt IS NULL THEN 0 ELSE 1 END) as vt
							, (CASE WHEN diab.diab IS NULL THEN 0 ELSE 1 END) as diab
 							, (COALESCE(sep.sep, 0) + COALESCE(nobl.nobl, 0) + COALESCE(ch.ch, 0) + 
 							   COALESCE(arf.arf, 0) + COALESCE(mi.mi, 0) + COALESCE(hf.hf, 0) + COALESCE(ci.ci, 0) +
 							   COALESCE(sh.sh, 0)+ COALESCE(pneu.pneu, 0) + COALESCE(col.col, 0) + COALESCE(akf.akf, 0)) AS total
				FROM subjects s
				LEFT JOIN sep ON s.subject_id = sep.subject_id AND s.hadm_id = sep.hadm_id
 				LEFT JOIN nobl ON nobl.subject_id = s.subject_id AND nobl.hadm_id = s.hadm_id
 				LEFT JOIN ch ON ch.subject_id = s.subject_id AND ch.hadm_id = s.hadm_id
 				LEFT JOIN arf ON arf.subject_id = s.subject_id AND arf.hadm_id = s.hadm_id
 				LEFT JOIN mi ON mi.subject_id = s.subject_id AND mi.hadm_id = s.hadm_id
 				LEFT JOIN hf ON hf.subject_id = s.subject_id AND hf.hadm_id = s.hadm_id
 				LEFT JOIN ci ON ci.subject_id = s.subject_id AND ci.hadm_id = s.hadm_id
 				LEFT JOIN sh ON sh.subject_id = s.subject_id AND sh.hadm_id = s.hadm_id
 				LEFT JOIN pneu ON pneu.subject_id = s.subject_id AND pneu.hadm_id = s.hadm_id
				LEFT JOIN col ON col.subject_id = s.subject_id AND col.hadm_id = s.hadm_id
				LEFT JOIN akf ON akf.subject_id = s.subject_id AND akf.hadm_id = s.hadm_id
				LEFT JOIN ca ON ca.subject_id = s.subject_id AND ca.hadm_id = s.hadm_id
				LEFT JOIN leu ON leu.subject_id = s.subject_id AND leu.hadm_id = s.hadm_id
				LEFT JOIN hepf ON hepf.subject_id = s.subject_id AND hepf.hadm_id = s.hadm_id
				LEFT JOIN panc ON panc.subject_id = s.subject_id AND panc.hadm_id = s.hadm_id
				LEFT JOIN vt ON vt.subject_id = s.subject_id AND vt.hadm_id = s.hadm_id
				LEFT JOIN diab ON diab.subject_id = s.subject_id AND diab.hadm_id = s.hadm_id
 				ORDER BY s.subject_id, s.hadm_id
)
-- 
-- SELECT icd_code, icd_version, long_title, count(*) FROM icu_diags 
-- WHERE lower(long_title) ~ 'heart failure'
--  GROUP BY icd_code, icd_version, long_title ORDER BY long_title 

