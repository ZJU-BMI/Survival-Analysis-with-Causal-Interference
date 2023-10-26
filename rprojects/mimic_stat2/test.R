df <- read.csv('results/mimic_data_final6.csv')

mean(df$alt)
median(df$alt)
df$alt <- ifelse(df$alt > 100, 36 + runif(1, -2, 2), df$alt)
sd(df$alt)

median(df$alp)
df$alp <- ifelse(df$alp > 180, 100 + runif(1, -20, 20), df$alp)
mean(df$alp)
sd(df$alp)

median(df$ast)
df$ast <- ifelse(df$ast > 90, 40 + runif(1, -10, 10), df$ast)
mean(df$ast)
sd(df$ast)

median(df$bil_total)
df$bil_total <- ifelse(df$bil_total > 3, 0.85 + runif(1, -0.5, 0.5), df$bil_total)
mean(df$bil_total)
sd(df$bil_total)

mean(df$bmi)
sd(df$bmi)

# 药物0-1化
for (i in 69:80) {
  df[, i] <- ifelse(df[, i] > 0, 1, 0)
}
write.csv(df, 'results/mimic_data_final7.csv', row.names = F)
