df <- read.csv('eicu_diags_10.csv')
table(df$label)
table(df$diag)
df_dead <- subset(df, label == 1)
table(df_dead$diag)

nrow(subset(df_dead, diag != 0)) / nrow(df_dead)

df_10 <- subset.data.frame(df, diag != 0 & total > 1)
table(df_10$total)
nrow(subset(df_10))
nrow(subset.data.frame(df_10, arenf == 1)) / nrow(df_10)
