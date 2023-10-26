library(naniar)
library(dplyr)

pat_info <- read.csv('data/pat_info.csv')
lab_feats <- read.csv('data/lab_features.csv')
vital_signs <- read.csv('data/vital_signs.csv')
drugs <- read.csv('data/drug.csv')

# 时间
pats <- subset.data.frame(pat_info, select = c(1))
pats <- arrange(pats, patientunitstayid)
# 创建id列
pats['id'] <- c(1:nrow(pats))


chrtime1 <- subset.data.frame(vital_signs, select = c(1, 2))
chrtime2 <- subset.data.frame(lab_feats, select = c(1, 2))
chrtime3 <- subset.data.frame(drugs, select = c(1, 2))

# 合并时间
pat_times1 <- merge.data.frame(pats, chrtime1, c('patientunitstayid'))
pat_times2 <- merge.data.frame(pats, chrtime2, c('patientunitstayid'))
pat_times3 <- merge.data.frame(pats, chrtime3, c('patientunitstayid'))

# 合并时间，删除重复行
pat_time <- rbind(pat_times1, pat_times2, pat_times3)
pat_time <- pat_time[!duplicated(pat_time[, c(1, 3)]), ]

pat_time <- arrange(pat_time, patientunitstayid, time)

# 合并特征
pat_feats <- merge.data.frame(pat_time, pat_info, by = c('patientunitstayid'))
pat_feats1 <- merge.data.frame(pat_feats, vital_signs, by = c('patientunitstayid', 'time'), all.x = T)
pat_feats2 <- merge.data.frame(pat_feats1, lab_feats, by = c('patientunitstayid', 'time'), all.x = T)
pat_feats3 <- merge.data.frame(pat_feats2, drugs, by = c('patientunitstayid', 'time'), all.x = T)
res <- miss_var_summary(pat_feats3)
res$pct_miss <- round(res$pct_miss, 2)
# 排序
pat_feats_final <- arrange(pat_feats3, patientunitstayid, time)
# 去除time > tte 的行
pat_feats_final <- subset.data.frame(pat_feats_final, time <= tte)

# 去除缺失值较多的行
feat_col <- pat_feats_final[, 24:89]
misses <- apply(feat_col, 1, function(x)sum(is.na(x)))
# 去除缺失值较多的行
misses2 <- which(misses < 28)
feat_col2 <- feat_col[misses2, ]
res_col <- miss_var_summary(feat_col2)
res_col$pct_miss <- round(res_col$pct_miss, 2)
res_col <- arrange(res_col, pct_miss)

pat_feats_final2 <- pat_feats_final[misses2, ]


# 统计只有一条记录的行
pat_gr <- group_by(pat_feats_final2, patientunitstayid)
sums <- summarise(pat_gr, count = n())
sum(sums$count > 1)

write.csv(pat_feats_final2, 'results/eicu_data1.csv', row.names = F)
write.csv(res_col, 'results/feature_misses.csv', row.names = F)
