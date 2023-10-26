df <- read.csv('datas/icu_diag_first.csv')
df_dead <- subset(df, hospital_expire_flag == 1)
length(unique(df_dead$icd_code))
# 败血症 septicemia
pattern <- 'septicemia'
df_sept <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_sept <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
table(df_sept$icd_code)

# 败血症 Sepsis
pattern <- 'sepsis'
df_seps <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_seps <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
nrow(table(df_seps$icd_code))

# 肿瘤 neoplasm
pattern <- 'neoplasm'
df_neoplasm <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_neoplasm <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
nrow(table(df_neoplasm$icd_code))

# 脑出血 cerebral hemorrhage
pattern <- 'cerebral hemorrhage'
df_ch <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_ch <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)


# 呼吸衰竭 acute respiratory failure
pattern <- 'acute.*respiratory failure'
df_arf <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_arf <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
table(df_arf$icd_code)


# 心肌梗塞 myocardial infarction
pattern <- 'myocardial infarction'
df_mi <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
df_mi <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
table(df_mi$icd_code)

# 心衰 heart failure
pattern <- 'heart failure'
df_hf <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_hf <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)
table(df_hf$icd_code)


# 脑梗塞 cerebral infarction
pattern <- 'cerebral infarction'
df_ci <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1 & 
                             icd_code != '43491  ' & icd_code != '43330  ' & 
                             icd_code != '43320  ' & icd_code != '43380  ')
df_ci <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1 & 
                             icd_code != '43491  ' & icd_code != '43330  ' & 
                             icd_code != '43320  ' & icd_code != '43380  ')
table(df_ci$icd_code)

# 蛛网膜下腔出血 subarachnoid hemorrhage
pattern <- 'subarachnoid hemorrhage'
df_sh <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)
df_sh <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)


# 肺炎 pneumonia
# exclude these with 'pneumonia':
# A403 Sepsis due to Streptococcus pneumoniae
# 0382 Pneumococcal septicemia [Streptococcus pneumoniae septicemia]
pattern <- 'pneumonia'
df_pneu <- subset.data.frame(df_dead, (grepl(pattern, long_title, ignore.case = T) == 1) &
                               icd_code != 'A403   ' & icd_code != '0382   ')
df_pneu <- subset.data.frame(df, (grepl(pattern, long_title, ignore.case = T) == 1) &
                               icd_code != 'A403   ' & icd_code != '0382   ')
table(df_pneu$icd_code)

# 肺炎 pneumonitis
pattern <- 'pneumonitis'
df_pneu <- subset.data.frame(df, (grepl(pattern, long_title, ignore.case = T) == 1))

# 心脏骤停 Cardiac arrest
pattern <- 'Cardiac arrest'
df_ca <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 肝硬化 Cirrhosis of liver
pattern <- 'cirrhosis of liver'
df_col <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 白血病 leukemia
pattern <- 'leukemia'
df_leu <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 急性肾功能衰竭 acute kidney failure
pattern <- 'acute kidney failure'
df_akf <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 肝功能衰竭 Hepatic failure
pattern <- 'hepatic failure'
df_hepf <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 室性心动过速 ventricular tachycardia
pattern <- 'ventricular tachycardia'
df_vt <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 急性胰腺炎 pancreatitis
pattern <- 'pancreatitis'
df_apt <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)

# 心室颤动 ventricular fibrillation
pattern <- 'ventricular fibrillation'
df_vf <- subset.data.frame(df, grepl(pattern, long_title, ignore.case = T) == 1)


# 中毒 Poisoning
pattern <- 'Poisoning'
df_poi <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)

# 术后感染 postoperative infection
pattern <- 'postoperative infection'
df_pi <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)

# 糖尿病
pattern <- 'diabetes'
df_dia <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)


# Atrial fibrillation
pattern <- 'Atrial fibrillation'
df_atf <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)

# 缺氧性脑损伤
pattern <- 'Anoxic brain damage'
df_abd <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)



# 其他肺部相关 pulmonary
pattern <- 'pulmonary'
df_pd <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)



# fracture
pattern <- 'fracture'
df_frac <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)

# Injury 
pattern <- 'injury'
df_inj <- subset.data.frame(df_dead, grepl(pattern, long_title, ignore.case = T) == 1)



