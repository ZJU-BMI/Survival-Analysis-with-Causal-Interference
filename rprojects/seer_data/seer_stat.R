df <- read.csv('results/seer_data.csv')


died <- subset.data.frame(df, label > 0)

table(df$label)
df$flag <- ifelse(df$label == 0, 0, 1)


# 卡方检验
res <- table(died$summary_stnodes_positive, died$label)
chisq.test(res)


table(df$prim_site)
round(prop.table(table(df$summary_stnodes_positive)) * 100, 2)
nm <- table(df$summary_stnodes_positive)['0']
perc <- round(prop.table(table(df$summary_stnodes_positive)) * 100, 2)['0']
str_res <- sprintf("%d (%.2f%%)", nm, perc)
print(str_res)
# 分类变量
for (i in 0:3) {
  group <- subset.data.frame(df, label == i)
  print(i)
  num <- table(group$summary_stnodes_positive)['Regional']
  percents <- round(prop.table(table(group$summary_stnodes_positive)) * 100, 3)['Regional']
  if (is.na(num)) {
    str_res <- sprintf("%d (%.1f%%)", 0, 0.0)
  } else {
    str_res <- sprintf("%d (%.2f%%)", num, percents)
  }
  print(str_res)
}



mean_val = round(mean(df$nodes_positive), 2)
sd_val = round(sd(df$nodes_positive), 2)
# qunt25 = round(quantile(df$nodes_positive, 0.25), 2)
# qunt75 = round(quantile(df$nodes_positive, 0.75), 2)
# str_res <- sprintf("%.2f(%.2f, %.2f-%.2f)", mean_val, sd_val, qunt25, qunt75)
str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
print(str_res)
# 连续变量
for (i in 0:3) {
  group <- subset.data.frame(df, label == i)
  print(i)
  mean_val = round(mean(group$nodes_positive), 2)
  sd_val = round(sd(group$nodes_positive), 2)
  # qunt25 = round(quantile(group$nodes_positive, 0.25), 2)
  # qunt75 = round(quantile(group$nodes_positive, 0.75), 2)
  # str_res <- sprintf("%.2f(%.2f, %.2f-%.2f)", mean_val, sd_val, qunt25, qunt75)
  str_res <- sprintf("%.2f (%.2f)", mean_val, sd_val)
  print(str_res)
}

kruskal.test(nodes_positive~label, df)$p.value
chisq.test(table(df$summary_stnodes_positive, df$label))$p.value



mean_val = round(median(df$nodes_positive), 2)
qunt25 = round(quantile(df$nodes_positive, 0.25), 2)
qunt75 = round(quantile(df$nodes_positive, 0.75), 2)
str_res <- sprintf("%.1f (%.1f-%.1f)", mean_val, qunt25, qunt75)
print(str_res)
# 连续变量
for (i in 0:3) {
  group <- subset.data.frame(df, label == i)
  print(i)
  mean_val = round(median(group$nodes_positive), 2)
  qunt25 = round(quantile(group$nodes_positive, 0.25), 2)
  qunt75 = round(quantile(group$nodes_positive, 0.75), 2)
  str_res <- sprintf("%.1f (%.1f-%.1f)", mean_val, qunt25, qunt75)
  print(str_res)
}



