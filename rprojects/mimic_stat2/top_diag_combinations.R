df <- read.csv('diag_combination.csv')
df <- subset(df, diag1 != 0 | diag2 != 0)

df_order <- df[order(df$long_title1, df$long_title2), ]
df_dead <- subset.data.frame(df_order, hospital_expire_flag == 1)
table(df_dead$diag1)

tab <- table(df_dead$diag1, df_dead$diag2)
mat <- matrix(tab, nrow = 11)
matcopy <- mat
for (i in 1:11) {
  for (j in 1:11) {
    if (i != j) {
      mat[i, j] = matcopy[i, j] + matcopy[j, i]
    }
  }
}
dnames <- c('others', 'Sepsis', 'Neoplasm', 'Cerebral hemorrhage', 'Acute Respiratory Failure', 'Myocardial infarction',
            'Heart failure', 'Pneumonia/Pneumonitis', 'Cerebral infarction', 'Subarachnoid hemorrhage', 'Cirrhosis of liver')
rownames(mat) <- dnames
colnames(mat) <- dnames
df_comb <- as.data.frame(mat)


# acute respiratory failure & septicemia/sepsis 392
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 1) | (diag1 == 1 & diag2 == 4))

#  pneumonia/pneumonitis & septicemia/sepsis 237
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 1) | (diag1 == 1 & diag2 == 4))

# acute respiratory failure & pneumonia/pneumonitis 206
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 7) | (diag1 == 7 & diag2 == 4))

# septicemia/sepsis & neoplasm 116
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 2) | (diag1 == 2 & diag2 == 4))

# PASSED cerebral hemorrhage & cerebral edema 105 
pattern2 <- 'cerebral edema' 
df_test <- subset.data.frame(df_dead, (diag1 == 3 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 3 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# acute respiratory failure $ heart failure 80
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 6) | (diag1 == 6 & diag2 == 4))

# neoplasm $ pneumonia/pneumonitis 75
df_test <- subset.data.frame(df_dead, (diag1 == 2 & diag2 == 7) | (diag1 == 7 & diag2 == 2))

# acute kidney failure & septicemia/sepsis 70
pattern2 <- 'acute kidney failure'
df_test <- subset.data.frame(df_dead, (diag1 == 1 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 1 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# acute respiratory failure & myocardial infarction 57
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 5) | (diag1 == 5 & diag2 == 4))

# myocardial infarction & heart failure 54
df_test <- subset.data.frame(df_dead, (diag1 == 6 & diag2 == 5) | (diag1 == 5 & diag2 == 6))

# cerebral hemorrhage & acute respiratory failure 48
df_test <- subset.data.frame(df_dead, (diag1 == 4 & diag2 == 3) | (diag1 == 3 & diag2 == 4))

# heart failure $ pneumonia/pneumonitis 47
df_test <- subset.data.frame(df_dead, (diag1 == 6 & diag2 == 7) | (diag1 == 7 & diag2 == 6))

# heart failure & acute kidney failure 44
pattern2 <- 'acute kidney failure'
df_test <- subset.data.frame(df_dead, (diag1 == 6 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 6 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# septicemia/sepsis & myocardial infarction 40
df_test <- subset.data.frame(df_dead, (diag1 == 1 & diag2 == 5) | (diag1 == 5 & diag2 == 1))


# acute respiratory failure & acute kidney failure 37
pattern2 <- 'acute kidney failure'
df_test <- subset.data.frame(df_dead, (diag1 == 4 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                                      (diag2 == 4 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# cerebral infarction & acute kidney failure 28
pattern2 <- 'acute kidney failure' 
df_test <- subset.data.frame(df_dead, (diag1 == 5 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 5 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# septicemia/sepsis & acute hepatic failure 27
pattern2 <- 'hepatic failure'
df_test <- subset.data.frame(df_dead, (diag1 == 1 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 1 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# pneumonia/penumonitis & acute kidney failure 25
pattern2 <- 'acute kidney failure'
df_test <- subset.data.frame(df_dead, (diag1 == 7 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 7 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# heart failure & subendocardial infarction 22
pattern2 <- 'subendocardial infarction' 
df_test <- subset.data.frame(df_dead, (diag1 == 6 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 6 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# pulmonary embolism & septicemia/sepsis 21
pattern2 <- 'pulmonary embolism'
df_test <- subset.data.frame(df_dead, (diag1 == 1 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 1 & grepl(pattern2, long_title1, ignore.case = T) == 1))

# acute respiratory failure & leukemia 19
pattern2 <- 'leukemia'
df_test <- subset.data.frame(df_dead, (diag1 == 4 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                             (diag2 == 4 & grepl(pattern2, long_title1, ignore.case = T) == 1))


# PASS subarachnoid hemorrhage & compression of brain 31
pattern2 <- 'compression of brain'
df_test <- subset.data.frame(df_dead, (diag1 == 9 & grepl(pattern2, long_title2, ignore.case = T) == 1) | 
                               (diag2 == 9 & grepl(pattern2, long_title1, ignore.case = T) == 1))


dia <- 10
df_test2 <- subset.data.frame(df_dead, (diag1 == dia & diag2 == 0) | (diag1 == 0 & diag2 == dia))
df_test2 <- df_test2[order(df_test2$long_title1, df_test2$long_title2), ]














