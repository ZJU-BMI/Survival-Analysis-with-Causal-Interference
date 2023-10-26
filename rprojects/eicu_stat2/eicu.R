df <- read.csv('eicu_first_diag.csv')
df_dead <- subset.data.frame(df, label == 1)

# 心脏骤停 cardiac arrest 1377
pattern <- 'cardiac arrest' 
df_ca <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)
df_ca <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 败血症 sepsis 1076
pattern <- 'sepsis' 
df_seps <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T 
                             & icd9code != '518.81, J80' & icd9code != '584.9, N17.9')
df_seps <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T
                             & icd9code != '518.81, J80' & icd9code != '584.9, N17.9')


# 急性呼吸衰竭 acute respiratory failure 761
pattern <- 'acute.*respiratory failure'
df_arf <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T &
                              icd9code != '038.9, 518.81, R65.20, J96.0')
df_arf <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T &
                              icd9code != '038.9, 518.81, R65.20, J96.0')

# 感染性休克 septic shock 467
pattern <- 'septic shock' 
df_ssk <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)
df_ssk <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 中风 stroke 440
pattern <- 'stroke'
df_stk <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)
df_stk <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 肺炎 pneumonia 378
pattern <- 'pneumonia'
df_pneu <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)
df_pneu <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 消化道出血 GI bleeding 210
pattern <- 'GI bleeding' 
df_gib <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)
df_gib <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 心脏衰竭 heart failure 193
pattern <- 'heart failure'
df_hf <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T &
                             icd9code != '038.9, 428.0, R65.20, I50.9')
df_hf <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T &
                             icd9code != '038.9, 428.0, R65.20, I50.9')

# 急性呼吸窘迫 acute respiratory distress 179
pattern <- 'acute respiratory distress'
df_ard <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 心肌梗塞 myocardial infarction 169
pattern <- 'myocardial infarction' 
df_mi <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T &
                             diagnosisstring != 'cardiovascular|chest pain / ASHD|myocardial infarction ruled out')

# 急性肾衰竭 acute renal failure 104
pattern <- 'acute renal failure'
df_aref <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T & 
                               icd9code != '038.9, 584.9, R65.20, N17')

# 呼吸骤停 respiratory arrest 96
pattern <- 'respiratory arrest'
df_rat <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 心房颤动 atrial fibrillation 89
pattern <- 'atrial fibrillation'
df_af <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 硬膜下水肿 subdural hematoma 86
pattern <- 'subdural hematoma'
df_sha <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 慢性阻塞性肺疾病 COPD 82
pattern <- 'COPD'
df_copd <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 心室颤动 ventricular fibrillation 68
pattern <- 'ventricular fibrillation' 
df_vf <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 室性心动过速 ventricular tachycardia, including SVT 60 
pattern <- 'ventricular tachycardia|svt' 
df_vt <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 肝功能障碍/衰竭 hepatic dysfunction|hepatic failure 53
pattern <- 'hepatic dysfunction|hepatic failure'
df_hdf <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# pulmonary embolism 40
pattern <- 'pulmonary embolism'
df_pem <- subset.data.frame(df, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 脑出血 cerebral hemorrhage 29
pattern <- 'cerebral hemorrhage'
df_ch <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 心动过缓 bradycardia 29
pattern <- 'bradycardia' 
df_bc <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# lung cancer|lung CA 29
pattern <- 'lung cancer|lung CA'
df_lca <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)

# 内脏穿孔 viscus perforation 22
pattern <- 'viscus perforation'
df_vpf <- subset.data.frame(df_dead, grepl(pattern, diagnosisstring, ignore.case = T) == T)



