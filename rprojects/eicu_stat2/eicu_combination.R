df <- read.csv('data/eicu_diags_comb.csv')
table(df$label)
table(df$diag)

# 死亡率前十统计
df_top_10 <- subset.data.frame(df, diag > 0 & diag < 11)
table(df_top_10$label)

# 组合统计
df2 <- subset.data.frame(df, diag != 0)
df_dead <- subset(df2, label == 1)
dnames <- c('Cardiac Arrest', 'Sepsis', 'Acute Respiratory Failure', 'Septic Shock', 'Stroke',
            'Pneumonia', 'GI Bleeding', 'Heart Failure', 'Acute Resp Distress', 'Myocardial Infarction',
            'Acute Renal Failure', 'Respiratory Arrest', 'Atrial Fibrillation', 'Subdural Hematoma',
            'COPD', 'Ventricular Tachycardial', 'Pulmonary Embolism')

combnames <- rep('', times =  17 * 8)
results <- rep(0, times = 17 * 8)
k = 1
for (i in 6:21) {
  for (j in (i + 1):22) {
    combnames[k] <- paste(dnames[i - 5], dnames[j - 5], sep = ' & ')
    results[k] <- table(df_dead[, i], df_dead[, j])[2,2]
    k = k + 1
  }
}
df_combs_cnts <- data.frame(a = combnames, b = results)

# acute renal failure
df_arenf <- subset.data.frame(df, diag == 1 | diag == 2 | diag == 3 | diag == 4 | diag == 6 | diag == 11)
table(df_arenf$label)

df_all <- rbind.data.frame(df_top_10, df_arenf)
library(dplyr)
df_all_rdup <- df_all[!duplicated(df_all[, 1]), ]
df_all_rdup['total11'] <- df_all_rdup$ca + df_all_rdup$seps + df_all_rdup$arf + df_all_rdup$ss + 
                          df_all_rdup$stk + df_all_rdup$pneu + df_all_rdup$gib + df_all_rdup$hf +
                          df_all_rdup$ard + df_all_rdup$mi + df_all_rdup$arenf
df_all2 <- subset.data.frame(df_all_rdup, total11 > 1)
table(df_all2$label)

tss <- subset.data.frame(df2, arf == 1 & ss == 1)
table(tss$label)

