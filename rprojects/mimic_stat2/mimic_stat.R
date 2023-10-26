df <- read.csv('results/mimic_data_final2.csv')

died <- subset.data.frame(df, label > 0)
table(df$label)
sh <- subset.data.frame(died, label == 9)


str_res <- sprintf("%d(%.2f%%)", table(df$diab)['1'], round(prop.table(table(df$diab)) * 100, 2)['1'])
str_res

# 卡方检验
df$flag <- ifelse(df$label == 0, 0, 1)

res <- table(df$furosemide, df$label)
chisq.test(res)

# 分类变量
table(df$furosemide)
round(prop.table(table(df$furosemide)) * 100, 2)
for (i in 0:11) {
  group <- subset.data.frame(df, label == i)
  print(i)
  num <- table(group$furosemide)['1']
  percents <- round(prop.table(table(group$furosemide)) * 100, 2)['1']
  if (is.na(num)) {
    str_res <- sprintf("%d (%.1f%%)", 0, 0.0)
  } else {
    str_res <- sprintf("%d (%.2f%%)", num, percents)
  }
  
  print(str_res)
}


mean_val = round(mean(df$nacl_09), 2)
sd_val = round(sd(df$bil_total), 2)
# qunt25 = round(quantile(df$bil_total, 0.25), 2)
# qunt75 = round(quantile(df$bil_total, 0.75), 2)
# str_res <- sprintf("%.2f(%.2f, %.2f-%.2f)", mean_val, sd_val, qunt25, qunt75)
str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
print(str_res)
# 连续变量
for (i in 0:11) {
  group <- subset.data.frame(df, label == i)
  print(i)
  mean_val = round(mean(group$bil_total), 2)
  sd_val = round(sd(group$bil_total), 2)
  # qunt25 = round(quantile(group$bil_total, 0.25), 2)
  # qunt75 = round(quantile(group$bil_total, 0.75), 2)
  # str_res <- sprintf("%.2f(%.2f, %.2f-%.2f)", mean_val, sd_val, qunt25, qunt75)
  str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
  print(str_res)
}

kruskal.test(bil_total~label, died)$p.value


mean_val = round(median(df$age), 2)
sd_val = round(sd(df$age), 2)
qunt25 = round(quantile(df$age, 0.25), 2)
qunt75 = round(quantile(df$age, 0.75), 2)
str_res <- sprintf("%.2f(%.2f to %.2f)", mean_val, qunt25, qunt75)
# str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
print(str_res)
# 连续变量
for (i in 0:11) {
  group <- subset.data.frame(df, label == i)
  print(i)
  mean_val = round(median(group$age), 2)
  # sd_val = round(sd(group$age), 2)
  qunt25 = round(quantile(group$age, 0.25), 2)
  qunt75 = round(quantile(group$age, 0.75), 2)
  str_res <- sprintf("%.0f(%.0f to %.0f)", mean_val, qunt25, qunt75)
  # str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
  print(str_res)
}










