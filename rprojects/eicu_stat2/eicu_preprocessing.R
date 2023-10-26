library(dplyr)
library(naniar)

eicu_data <- read.csv('results/eicu_data1.csv')

# 药物NA值改为0
for (i in 82:89) {
  eicu_data[, i] <- ifelse(is.na(eicu_data[, i]), 0, eicu_data[, i])
}

feats <- eicu_data[, 24:89]
pct_misses <- miss_var_summary(feats)
pct_misses$pct_miss <- round(pct_misses$pct_miss, 2)
pct_misses <- arrange(pct_misses, pct_miss)

# 删除缺失比例>32%的列
drops <- subset.data.frame(pct_misses, pct_miss > 33)$variable
eicu_data2 <- subset.data.frame(eicu_data, 
                                 select = -which(colnames(eicu_data) %in% drops))

# 删除缺失（值为0）70%以上的药物
sums <- apply(eicu_data2[, 61:68], 2, function(x)((sum(x == 0))/length(x)))
drop_drugs <- c('fentanyl', 'propofol', 'norepinephrine', 'insulin', 'midazolam', 
                'heparin', 'dexmedetomidine', 'amiodarone')
eicu_data3 <- subset.data.frame(eicu_data2, 
                                 select = -which(colnames(eicu_data2) %in% drop_drugs))

res <- miss_var_summary(eicu_data3)
# 保存原始数据
write.csv(eicu_data3, 'results/eicu_data_raw.csv', row.names = F)

eicu_data_raw <- read.csv('results/eicu_data_raw.csv')
# 无需计算时间偏移
# charttime <- as.Date(eicu_data_raw$charttime, format = '%Y-%m-%d')
# admittime <- as.Date(eicu_data_raw$admittime, format = '%Y-%m-%d')
# 计算测量时间差 time
# eicu_data_raw$time <- as.numeric(difftime(charttime, admittime), units = 'days')
# 计算time to event, tte
# eicu_data_raw$tte <- ifelse(eicu_data_raw$deathtime == '',
#                             eicu_data_raw$dischtime_diff, 
#                             eicu_data_raw$deathtime_diff)



# 发生事件标记，label，1-11，删失为0
eicu_data_raw$label <- ifelse(eicu_data_raw$label == 0, 0, eicu_data_raw$diag)

# 重新整理数据集
idx <- subset.data.frame(eicu_data_raw, select = c('id', 'tte', 'time', 'label', 'diag'))
disease <- subset.data.frame(eicu_data_raw, select = c(7:23))
features <- subset.data.frame(eicu_data_raw, select = c(24:63))
eicu_data_cleaned <- cbind(idx, disease, features)
eicu_data_cleaned <- arrange(eicu_data_cleaned, id, time)

# 保存结果
write.csv(eicu_data_cleaned, 'results/eicu_data_cleaned.csv', row.names = F)


# 插值
df <- read.csv('results/eicu_data_cleaned.csv')
features <- subset.data.frame(df, select = c(22:59))
res <- miss_var_summary(features)
table(df$label)
length(unique(df$id))

library(mice)

imp <- mice(df, m = 5)
df_imp <- complete(imp)

res <- miss_var_summary(df_imp)
# bmi计算
df_imp$bmi <- round(df_imp$weight * 10000 / (df_imp$height * df_imp$height), 2)
write.csv(df_imp, 'results/eicu_data_final.csv', row.names = F)
colnames(df_imp)
max(df_imp$gcs_total)







