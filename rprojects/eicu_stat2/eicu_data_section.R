library(dplyr)


eicu_data <- read.csv('results/eicu_data_final.csv')
table(eicu_data$ethnicity)
eicu_data$ethnicity <- ifelse(eicu_data$ethnicity == '' | eicu_data$ethnicity == 'Other/Unknown',
                               'OTHER', eicu_data$ethnicity)
table(eicu_data$ethnicity)


# 取tte小于150的数据
# eicu_data3 <- subset.data.frame(eicu_data, tte <= 150)
# 取每个患者第一条数据
# eicu_data4 <- eicu_data3[!duplicated(eicu_data3[, 1]), ]
# write.csv(eicu_data3, 'results/eicu_data_final.csv', row.names = F)
# write.csv(eicu_data4, 'results/eicu_data_final2.csv', row.names = F)

eicu_data <- read.csv('results/eicu_data_final.csv')
eicu_data2 <- eicu_data[!duplicated(eicu_data[, 1]), ]

eicu_data_time <- subset.data.frame(eicu_data2, select = c(1))
eicu_data_time$time2 <- eicu_data2$time

eicu_data3 <- merge.data.frame(eicu_data_time, eicu_data, by = 'id')
eicu_data3$tte <- eicu_data3$tte - eicu_data3$time2
eicu_data3$time <- eicu_data3$time - eicu_data3$time2
eicu_data3 <- subset.data.frame(eicu_data3, select = -c(2))
eicu_data3 <- arrange(eicu_data3, id, time)
eicu_data4 <- eicu_data3[!duplicated(eicu_data3[, 1]), ]

write.csv(eicu_data3, 'results/eicu_data_final.csv', row.names = F)
write.csv(eicu_data4, 'results/eicu_data_final2.csv', row.names = F)


