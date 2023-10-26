df <- read.csv('../mimic_stat21/data/icu_diag_first2.csv')
table(df$hospital_expire_flag)
table(df$diag)


df_dead <- subset(df, hospital_expire_flag == 1)

# 死亡统计
table(df_dead$diag)
nrow(subset(df, diag != 0)) 
nrow(subset(df_dead, diag != 0))

# top 10 死亡原因统计
df_top_10 <- subset.data.frame(df, diag > 0 & diag < 11)

df_10_dead <- subset.data.frame(df_top_10, hospital_expire_flag == 1)
table(df_top_10$hospital_expire_flag)
table(df_top_10$diag)
table(df_top_10$total)
nrow(df_top_10)

# 组合统计
dnames <- c('Septicemia/Sepsis', 'Cerebral Hemorrhage', 'Acute Respiratory Failure', 
            'Myocardial Infarction', 'Heart Failure', 'Pneumonia/Pneumonitis', 'Cerebral Infarction', 
            'Subarachnoid Hemorrhage', 'Neoplasm of Bronchus and Lungs', 'Cirrhosis of Liver', 'Acute Kidney Failure')
df2 <- subset.data.frame(df, diag != 0)
table(df2$diag)
df_dead <- subset.data.frame(df2, hospital_expire_flag == 1)
table(df_dead$diag)
combnames <- rep('', times =  11 * 5)
results <- rep(0, times = 11 * 5)
k = 1
for (i in 7:16) {
  for (j in (i + 1):17) {
    combnames[k] <- paste(dnames[i - 6], dnames[j - 6], sep = ' & ')
    results[k] <- table(df_dead[, i], df_dead[, j])[2,2]
    k = k + 1
  }
}
df_combs_cnts <- data.frame(a = combnames, b = results)


library(dplyr)
df_akf <- subset.data.frame(df, diag == 1 | diag == 3 | diag == 6 | diag == 5 | diag == 11)
df_akf2 <- subset.data.frame(df, diag == 11)
table(df_akf$hospital_expire_flag)

df_all <- rbind.data.frame(df_top_10, df_akf)

df_all_rdup <- df_all[!duplicated(df_all[, c(1, 2)]), ]
df_all_rdup['total11'] <- df_all_rdup$sep + df_all_rdup$nobl + df_all_rdup$ch + df_all_rdup$arf + 
                          df_all_rdup$mi + df_all_rdup$hf + df_all_rdup$pneu + df_all_rdup$ci +
                          df_all_rdup$sh + df_all_rdup$col + df_all_rdup$akf
df_crk <- subset.data.frame(df_all_rdup, total11 > 1)
table(df_crk$hospital_expire_flag)
table(df_crk$diag, df_crk$hospital_expire_flag)



tss <- subset.data.frame(df_akf, hf == 1 & sep == 1)
table(tss$hospital_expire_flag)



