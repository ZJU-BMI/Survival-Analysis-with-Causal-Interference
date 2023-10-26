library(dplyr)

mimic_data <- read.csv('results/mimic_data_final2.csv')
mimic_data$ethnicity <- ifelse(mimic_data$ethnicity == 'UNABLE TO OBTAIN' | mimic_data$ethnicity == 'UNKNOWN',
                                'OTHER', mimic_data$ethnicity)
table(mimic_data$ethnicity)

# length(unique(mimic_data2$id))
# table(mimic_data2$label)


mimic_data$tte <- ifelse(mimic_data$tte >= mimic_data$time, mimic_data$tte, mimic_data$time)
chaos <- subset.data.frame(mimic_data, tte < time)

mimic_data <- subset.data.frame(mimic_data, tte <= 120)


# 药物0-1化
for (i in 69:80) {
  mimic_data[, i] <- ifelse(mimic_data[, i] > 0, 1, 0)
}

# 取每个患者第一条数据
mimic_data2 <- mimic_data[!duplicated(mimic_data[, 1]), ]

table(mimic_data2$label)
# write.csv(mimic_data, 'results/mimic_data_final.csv', row.names = F)
# write.csv(mimic_data2, 'results/mimic_data_final6.csv', row.names = F)

# 计算time，将第一条记录时间记为0
mimic_data_time <- subset.data.frame(mimic_data2, select = c(1))
mimic_data_time$time2 <- mimic_data2$time

mimic_data3 <- merge.data.frame(mimic_data_time, mimic_data, by = 'id')
mimic_data3$tte <- mimic_data3$tte - mimic_data3$time2
mimic_data3$time <- mimic_data3$time - mimic_data3$time2
mimic_data3 <- subset.data.frame(mimic_data3, select = -c(2))
mimic_data3 <- arrange(mimic_data3, id, time)
mimic_data4 <- mimic_data3[!duplicated(mimic_data3[, 1]), ]

write.csv(mimic_data3, 'results/mimic_data_final3.csv', row.names = F)
write.csv(mimic_data4, 'results/mimic_data_final4.csv', row.names = F)

for(i in 26:68) {
  avg <- mean(mimic_data4[, i])
  std <- sd(mimic_data4[, i])
  res_str <- sprintf('%.2f, %.2f', avg, std)
  print(colnames(mimic_data4)[i])
  print(res_str)
  print('------------------------------------')
}
max(mimic_data4$tte)
table(mimic_data4$label)



