
WITH subjects AS(
	SELECT subject_id, hadm_id, hospital_expire_flag
	, icd_code AS icd_code1
	, long_title AS long_title1
	, CASE WHEN icd_code IN(-- septicemia
													'0545', '03812', '03811', '03849', '0382', '0388', '03819', '0031', '0383', '03842', 
													'03840', '03841', '03843', '03844', '03810', '0380', '0389',
													-- sepsis
													'A427', 'B377', 'A5486', 'A4150', 'A4159',  'A4189',  'A408',   'O85',    '67022',  '67024',  
													'A021',   '99591',  'A4181',  'A4151',  'A413',   'A4102',  'A4101',  'A4152',  'A4153',  
													'A403',   'A414',   'A411',   'A400',   'A401',   'A412',   'T8144XA','T8144XD','O8604',  
													'O0337', 'A419',  '99592',  'R6521',  'R6520',  'A409') THEN 1
			 -- 2 neoplasm
 			 WHEN lower(long_title) like '%neoplasm%' THEN 2
			 -- 3 cerebral hemorrhage
 			 WHEN icd_code IN('I69120', 'I69193', 'I6911',  'I69122', 'I69191', 'I69121', 'I69192', 'I69152', 'I69154', 
 											'I69151', 'I69153', '431',    'I613',   'I614',   'I611',   'I610',   'I612',   'I615',   
 											'I616',   'I619',   'I618',  'I69165', 'I69198', 'I69128', 'I69119' ) THEN 3
			 -- 4	acute respiratory failure						
 			 WHEN icd_code IN('J95822', '51884',  '51853',  'J9622',  'J9621',  'J9620',  'J95821', '51881',  '51851',  
 											  'J9602',  'J9601',  'J9600'  ) THEN 4
				
			 -- 5 myocardial infarction													
 			 WHEN icd_code IN('I240',   '41001',  '41002',  '41021',  '41022', '41031',  '41032',  '41010',  '41011',  
												'41012',  '41040',  '41041',  '41042',  '41051',  '41081',  '41082',  '41090',  
												'41091',  '41092',  'I219',   '42979',  'I21A1',  'I214',   '412',    'I252',   'I238',   
												'I21A9',  '4110',   'I235',   'I2102',  'I2121', 'I2101',  'I2109',  'I2119',  'I2129',  
												'I2111',  'I213',   'I220',   'I221',   'I228',   'I229',   'I222',  'I236',   'I232'   ) THEN 5
			 -- 6 heart failure										
 			 WHEN icd_code IN('I5041',  '42841',  'I5031',  '42831',  'I5043',  '42843',  'I5033',  '42833',  'I50813', 
												'I5023',  '42823',  'I50811', 'I5021',  '42821',  '40211',   'I5082',  'I5042',  '42842',  
												'I5032',  '42832',  'I50812', 'I5022',  '42822',  '42840',  '4280',   '42830',  'I5084',  
												'4289',   'I509',   'I130',   'I132',     '40411',   '40401',  '40403',    '40493',  
												'40491',     'I110',     '4281',   '40201',  'I5089',  'I97130', 'I97131', 'I0981',  
												'39891',  'I50814', 'I50810', '42820',  'I5040',  'I5030',  '40291',   'I5020'  )		THEN 6
												
 			
			-- 7 pneumonia/pneumonitis
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
											'4958', 'J690', '5070', '5071', 'J691', 'J698', '5078', '4959', '0521')	THEN 7
			 -- 8 cerebral infarction
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
 											 'V1254',  'Z8673',  'I69313','I6930',  'I69319', 'I69312' )	THEN 8								
			-- 9 subarachnoid hemorrhage						 
 			WHEN icd_code IN('I69020', 'I6901',  'I69092', 'I69054', 'I69051', 'I602',   'I604',   'I6022',  'I6002',  
 											'I6012',  'I6032',  'I6052',  'I606',   'I6021',  'I6001',  'I6011', 'I6031',  'I6051',  
 											'I6020',  'I607',   'I6010',  'I609',   'I608',   'I69098', 'I69028', '430',    '85216',  
											'85211',  '85200',  '85202',  '85209',  '85206',  '85203',  '85201',  '85204',  '85205',  
 											'S066X6A','S066X3A','S066X1A','S066X7A','S066X8A','S066X9A','S066X9D','S066X0A','S066X0S',
 											'S066X0D') THEN 9
																					
			-- 10 cirrhosis of liver
			WHEN icd_code IN('5712', 'K7031', 'K7030', '5715', 'K7469', 'K717', 'K7460') THEN 10					
			ELSE 0 END AS diag1
	FROM icu_diags WHERE seq_num = 1
)

, diag2 AS (
	SELECT subject_id, hadm_id, icd_code AS icd_code2
	, long_title AS long_title2
	, CASE WHEN icd_code IN(-- septicemia
													'0545', '03812', '03811', '03849', '0382', '0388', '03819', '0031', '0383', '03842', 
													'03840', '03841', '03843', '03844', '03810', '0380', '0389',
													-- sepsis
													'A427', 'B377', 'A5486', 'A4150', 'A4159',  'A4189',  'A408',   'O85',    '67022',  '67024',  
													'A021',   '99591',  'A4181',  'A4151',  'A413',   'A4102',  'A4101',  'A4152',  'A4153',  
													'A403',   'A414',   'A411',   'A400',   'A401',   'A412',   'T8144XA','T8144XD','O8604',  
													'O0337', 'A419',  '99592',  'R6521',  'R6520',  'A409') THEN 1
			 -- 2 neoplasm
 			 WHEN lower(long_title) like '%neoplasm%' THEN 2
			 -- 3 cerebral hemorrhage
 			 WHEN icd_code IN('I69120', 'I69193', 'I6911',  'I69122', 'I69191', 'I69121', 'I69192', 'I69152', 'I69154', 
 											'I69151', 'I69153', '431',    'I613',   'I614',   'I611',   'I610',   'I612',   'I615',   
 											'I616',   'I619',   'I618',  'I69165', 'I69198', 'I69128', 'I69119' ) THEN 3
			 -- 4	acute respiratory failure						
 			 WHEN icd_code IN('J95822', '51884',  '51853',  'J9622',  'J9621',  'J9620',  'J95821', '51881',  '51851',  
 											  'J9602',  'J9601',  'J9600'  ) THEN 4
				
			 -- 5 myocardial infarction													
 			 WHEN icd_code IN('I240',   '41001',  '41002',  '41021',  '41022', '41031',  '41032',  '41010',  '41011',  
												'41012',  '41040',  '41041',  '41042',  '41051',  '41081',  '41082',  '41090',  
												'41091',  '41092',  'I219',   '42979',  'I21A1',  'I214',   '412',    'I252',   'I238',   
												'I21A9',  '4110',   'I235',   'I2102',  'I2121', 'I2101',  'I2109',  'I2119',  'I2129',  
												'I2111',  'I213',   'I220',   'I221',   'I228',   'I229',   'I222',  'I236',   'I232'   ) THEN 5
			 -- 6 heart failure										
 			 WHEN icd_code IN('I5041',  '42841',  'I5031',  '42831',  'I5043',  '42843',  'I5033',  '42833',  'I50813', 
												'I5023',  '42823',  'I50811', 'I5021',  '42821',  '40211',   'I5082',  'I5042',  '42842',  
												'I5032',  '42832',  'I50812', 'I5022',  '42822',  '42840',  '4280',   '42830',  'I5084',  
												'4289',   'I509',   'I130',   'I132',     '40411',   '40401',  '40403',    '40493',  
												'40491',     'I110',     '4281',   '40201',  'I5089',  'I97130', 'I97131', 'I0981',  
												'39891',  'I50814', 'I50810', '42820',  'I5040',  'I5030',  '40291',   'I5020'  )		THEN 6
												
 			
			-- 7 pneumonia/pneumonitis
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
											'4958', 'J690', '5070', '5071', 'J691', 'J698', '5078', '4959', '0521')	THEN 7
			 -- 8 cerebral infarction
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
 											 'V1254',  'Z8673',  'I69313','I6930',  'I69319', 'I69312' )	THEN 8								
			-- 9 subarachnoid hemorrhage						 
 			WHEN icd_code IN('I69020', 'I6901',  'I69092', 'I69054', 'I69051', 'I602',   'I604',   'I6022',  'I6002',  
 											'I6012',  'I6032',  'I6052',  'I606',   'I6021',  'I6001',  'I6011', 'I6031',  'I6051',  
 											'I6020',  'I607',   'I6010',  'I609',   'I608',   'I69098', 'I69028', '430',    '85216',  
											'85211',  '85200',  '85202',  '85209',  '85206',  '85203',  '85201',  '85204',  '85205',  
 											'S066X6A','S066X3A','S066X1A','S066X7A','S066X8A','S066X9A','S066X9D','S066X0A','S066X0S',
 											'S066X0D') THEN 9
																					
			-- 10 cirrhosis of liver
			WHEN icd_code IN('5712', 'K7031', 'K7030', '5715', 'K7469', 'K717', 'K7460') THEN 10					
			ELSE 0 END AS diag2
	FROM icu_diags WHERE seq_num = 2
)

SELECT s.subject_id, s.hadm_id, s.hospital_expire_flag
	, s.diag1, d2.diag2
	, s.icd_code1, d2.icd_code2
	, s.long_title1, d2.long_title2
	FROM subjects s
	LEFT JOIN diag2 d2 ON s.subject_id = d2.subject_id AND s.hadm_id = d2.hadm_id
	ORDER BY subject_id, hadm_id
	