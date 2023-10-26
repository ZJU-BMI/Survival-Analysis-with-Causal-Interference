df <- read.csv('results/eicu_data_final2.csv')

died <- subset.data.frame(df, label > 0)

table(df$label)
df$flag <- ifelse(df$label == 0, 0, 1)


# 卡方检验
res <- table(died$pe, died$label)
chisq.test(res)

nm <- table(df$pe)['1']
perc <- round(prop.table(table(df$pe)) * 100, 2)['1']
str_res <- sprintf("%d (%.2f%%)", nm, perc)
print(str_res)
# 分类变量
for (i in 0:11) {
  group <- subset.data.frame(df, label == i)
  print(i)
  num <- table(group$pe)['1']
  percents <- round(prop.table(table(group$pe)) * 100, 2)['1']
  if (is.na(num)) {
    str_res <- sprintf("%d (%.1f%%)", 0, 0.0)
  } else {
    str_res <- sprintf("%d (%.2f%%)", num, percents)
  }
  print(str_res)
}


median(df$bil_total)
quantile(df$bil_total, 0.75)
mean_val = round(mean(df$bil_total), 2)
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
chisq.test(table(died$pe, died$label))$p.value



mean_val = round(median(df$bil_total), 2)
qunt25 = round(quantile(df$bil_total, 0.25), 2)
qunt75 = round(quantile(df$bil_total, 0.75), 2)
str_res <- sprintf("%.1f(%.1f-%.1f)", mean_val, qunt25, qunt75)
print(str_res)
# 连续变量
for (i in 0:11) {
  group <- subset.data.frame(df, label == i)
  print(i)
  mean_val = round(median(group$bil_total), 2)
  qunt25 = round(quantile(group$bil_total, 0.25), 2)
  qunt75 = round(quantile(group$bil_total, 0.75), 2)
  str_res <- sprintf("%.1f(%.1f-%.1f)", mean_val, qunt25, qunt75)
  print(str_res)
}



