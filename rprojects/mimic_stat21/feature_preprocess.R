library(dplyr)
library(naniar)

mimic_data <- read.csv('results/mimic_data1.csv')

# 药物NA值改为0
for (i in 100:116) {
  mimic_data[, i] <- ifelse(is.na(mimic_data[, i]), 0, mimic_data[, i])
}

feats <- mimic_data[, 29:116]
pct_misses <- miss_var_summary(feats)
pct_misses$pct_miss <- round(pct_misses$pct_miss)
pct_misses <- arrange(pct_misses, pct_miss)

# 删除缺失比例>32%的列
drops <- subset.data.frame(pct_misses, pct_miss > 30)$variable
mimic_data2 <- subset.data.frame(mimic_data, 
                                 select = -which(colnames(mimic_data) %in% drops))

# 删除缺失（值为0）70%以上的药物
drop_drugs <- c('midazolam', 'po_intake', 'phenylephrine', 'lr', 'hydromorphone')
mimic_data3 <- subset.data.frame(mimic_data2, 
                                 select = -which(colnames(mimic_data2) %in% drop_drugs))

res <- miss_var_summary(mimic_data3)
# 保存原始数据
write.csv(mimic_data3, 'results/mimic_data_raw.csv', row.names = F)


# 计算时间偏移，相对于入院时间
mimic_data_raw <- read.csv('results/mimic_data_raw.csv')
charttime <- as.Date(mimic_data_raw$charttime, format = '%Y-%m-%d')
admittime <- as.Date(mimic_data_raw$admittime, format = '%Y-%m-%d')
# 计算测量时间差 time
mimic_data_raw$time <- as.numeric(difftime(charttime, admittime), units = 'days')
# 计算time to event, tte
mimic_data_raw$tte <- ifelse(mimic_data_raw$deathtime == '',
                             mimic_data_raw$dischtime_diff, 
                             mimic_data_raw$deathtime_diff)

# 发生事件标记，label，1-11，删失为0
mimic_data_raw$label <- ifelse(mimic_data_raw$label == 0, 0, mimic_data_raw$diag)

# 重新整理数据集
idx <- subset.data.frame(mimic_data_raw, select = c('id', 'tte', 'time', 'label', 'diag'))
disease <- subset.data.frame(mimic_data_raw, select = c(12:28))
features <- subset.data.frame(mimic_data_raw, select = c(29:86))
mimic_data_cleaned <- cbind(idx, disease, features)
mimic_data_cleaned <- arrange(mimic_data_cleaned, id, time)

# 删除 hosp_stay
# mimic_data_cleaned <- subset.data.frame(mimic_data_cleaned, 
#                                       select = -which(colnames(mimic_data_cleaned) %in% c('hosp_stay')))

# 保存结果
write.csv(mimic_data_cleaned, 'results/mimic_data_cleaned.csv', row.names = F)


# 插值
df <- read.csv('results/mimic_data_cleaned.csv')
features <- subset.data.frame(df, select = c(23:80))
res <- miss_var_summary(features)
table(df$label)
length(unique(df$id))

library(mice)

imp <- mice(df, m = 5)
df_imp <- complete(imp)

res <- miss_var_summary(df_imp)
# bmi计算
df_imp$bmi <- round(df_imp$weight * 10000 / (df_imp$height * df_imp$height), 2)

write.csv(df_imp, 'results/mimic_data_final.csv', row.names = F)

