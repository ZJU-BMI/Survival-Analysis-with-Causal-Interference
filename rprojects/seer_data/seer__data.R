df <- read.csv('data/seer.csv', header = T)
table(df$SEER.cause.specific.death.classification)
table(df$COD.to.site.recode)
# df <- subset.data.frame(df, df$SEER.cause.specific.death.classification != 'N/A not seq 0-59')
# df <- subset.data.frame(df, df$SEER.cause.specific.death.classification != 'Dead (missing/unknown COD)')


# sdd <-table(df$Site.recode.ICD.O.3.WHO.2008)
# sdd <- as.data.frame(sdd)
# 
# sdd2 <- table(df$COD.to.site.recode)
# sdd2 <- as.data.frame(sdd2)

# df3 <- subset.data.frame(df, Site.recode.ICD.O.3.WHO.2008 == 'Breast')
# df4 <- subset.data.frame(df3, COD.to.site.recode == 'Breast' | 
#                          COD.to.site.recode == 'Diseases of Heart' |
#                          COD.to.site.recode == 'Cerebrovascular Diseases' |
#                          COD.to.site.recode == 'Alive')

table(df$Sex)
table(df$CS.mets.at.dx..2004.2015.)
# 去掉不需要的特征(缺失多，重复)
drop_cols <- c('Year.of.diagnosis', 'SEER.cause.specific.death.classification',
               'COD.to.site.rec.KM', 'Site.recode.ICD.O.3.WHO.2008', 
               'TNM.7.CS.v0204..Schema.recode', 'Lymphoma...Ann.Arbor.Stage..1983.2015.',
               'Total.number.of.benign.borderline.tumors.for.patient', 
               'RX.Summ..Scope.Reg.LN.Sur..2003..', 'RX.Summ..Surg.Oth.Reg.Dis..2003..',
               'SEER.Brain.and.CNS.Recode', 'SEER.Combined.Summary.Stage.2000..2004.2017.',
               'Total.number.of.benign.borderline.tumors.for.patient',
               'Lymphoid.neoplasm.recode.2021.Revision', 'Behavior.recode.for.analysis',
               'Behavior.code.ICD.O.3', 'Primary.Site', 'Combined.Summary.Stage..2004..',
               'SEER.historic.stage.A..1973.2015.', 'Histologic.Type.ICD.O.3', 
               'Derived.AJCC.M..6th.ed..2004.2015.', 'CS.Tumor.Size.Ext.Eval..2004.2015.',
               'CS.Reg.Node.Eval..2004.2015.', 'Sequence.number', 'CS.Mets.Eval..2004.2015.')
df5 <- subset(df, select = -which(colnames(df) %in% drop_cols))
colnames(df5)
col_names <- c('id', 'tte', 'label', 'age', 'gender', 'ethnicity', 
              'income_level', 'prim_site', 'grade', 'laterality',
              'hist_behavior', 'rx_prim_site', 'cs_tumor_size', 'cs_extension',
              'cs_lymph_nodes', 'cs_mets_at_dx', 'first_mailg', 'summary_stage', 'total_mailg',
              'derived_ajcc_stage', 'nodes_examed', 'nodes_positive')

# 生存时间 > 0, < 120, exclude 55588
df5 <- subset.data.frame(df5, Survival.months > 0 & Survival.months <= 120)

# 年龄转为整数
table(df5$Age.recode.with.single.ages.and.85.)
df5$Age.recode.with.single.ages.and.85. <- substr(df5$Age.recode.with.single.ages.and.85., 1, 2)
df5$Age.recode.with.single.ages.and.85. <- as.numeric(df5$Age.recode.with.single.ages.and.85.)

# 死因转化为数字
df5$COD.to.site.recode <- factor(df5$COD.to.site.recode, 
                                    levels = c('Alive', 'Breast', 'Diseases of Heart',
                                               'Cerebrovascular Diseases'))
df5$COD.to.site.recode <- as.numeric(df5$COD.to.site.recode)
df5$COD.to.site.recode <- df5$COD.to.site.recode - 1

#SEX 0-1化
table(df5$Sex)
df5$Sex <- ifelse(df5$Sex == 'Female', 0, 1)


table(df5$Race.recode..White..Black..Other.)
# 去掉种族为unknown 660
df5 <- subset(df5, df5$Race.recode..White..Black..Other. != 'Unknown')
df5$Race.recode..White..Black..Other. <- 
  ifelse(df5$Race.recode..White..Black..Other. == 'Other (American Indian/AK Native, Asian/Pacific Islander)',
         'other', df5$Race.recode..White..Black..Other.)


# income 去掉known 151
table(df5$Median.household.income.inflation.adj.to.2019)
df5 <- subset.data.frame(df5, Median.household.income.inflation.adj.to.2019 != 'Unknown/missing/no match/Not 1990-2018')
# income 转化为数字
df5$Median.household.income.inflation.adj.to.2019 <- factor(df5$Median.household.income.inflation.adj.to.2019)
levels(df5$Median.household.income.inflation.adj.to.2019)
df5$Median.household.income.inflation.adj.to.2019 <- as.numeric(df5$Median.household.income.inflation.adj.to.2019)
table(df5$Median.household.income.inflation.adj.to.2019)
df5$Median.household.income.inflation.adj.to.2019 <- ifelse(df5$Median.household.income.inflation.adj.to.2019 == 10,
                                                            0, df5$Median.household.income.inflation.adj.to.2019)


# 去掉grade == Unknown 8378
df5 <- subset.data.frame(df5, Grade..thru.2017. != 'Unknown')
table(df5$Grade..thru.2017.)
# grade 数字化
df5$Grade..thru.2017. <- factor(df5$Grade..thru.2017., 
                                levels = c('Well differentiated; Grade I',
                                           'Moderately differentiated; Grade II',
                                           'Poorly differentiated; Grade III',
                                           'Undifferentiated; anaplastic; Grade IV'))
levels(df5$Grade..thru.2017.)
df5$Grade..thru.2017. <- as.numeric(df5$Grade..thru.2017.)

table(df5$Laterality)

# tumor size < 150 : exclude: 6018
table(df5$CS.tumor.size..2004.2015.)
df5 <- subset.data.frame(df5, CS.tumor.size..2004.2015. <= 150)

# cs extension 去掉999
table(df5$CS.extension..2004.2015.)
df5 <- subset.data.frame(df5, CS.extension..2004.2015. != 999)
df5$CS.extension..2004.2015. <- ifelse(df5$CS.extension..2004.2015. == 950, 0, df5$CS.extension..2004.2015.)
df5$CS.extension..2004.2015. <- factor(df5$CS.extension..2004.2015.)
table(df5$CS.extension..2004.2015.)
df5$CS.extension..2004.2015. <- as.numeric(df5$CS.extension..2004.2015.)

# CS.lymph.nodes, 去掉999 2015
table(df5$CS.lymph.nodes..2004.2015.)
df5 <- subset.data.frame(df5, CS.lymph.nodes..2004.2015. != 999)
df5$CS.lymph.nodes..2004.2015. <- factor(df5$CS.lymph.nodes..2004.2015.)
df5$CS.lymph.nodes..2004.2015. <- as.numeric(df5$CS.lymph.nodes..2004.2015.)
table(df5$CS.lymph.nodes..2004.2015.)

# 去掉Summary.stage.2000..1998.2017. = Unknown/unstaged 1564
table(df5$Summary.stage.2000..1998.2017.)
df5 <- subset.data.frame(df5, Summary.stage.2000..1998.2017. != 'Unknown/unstaged')


# First.malignant.primary.indicator 0-1
table(df5$First.malignant.primary.indicator)
df5$First.malignant.primary.indicator <- ifelse(df5$First.malignant.primary.indicator == 'No', 0, 1)

table(df5$Total.number.of.in.situ.malignant.tumors.for.patient)


# Derived.AJCC.Stage.Group unknown=6572
table(df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015.)
df5 <- subset(df5, Derived.AJCC.Stage.Group..6th.ed..2004.2015. != 'UNK Stage')
df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015. <- factor(df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015.)
levels(df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015.)
df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015. <- as.numeric(df5$Derived.AJCC.Stage.Group..6th.ed..2004.2015.) - 1

# Regional.nodes.examined..1988.. 去掉大于89
table(df5$Regional.nodes.examined..1988..)
df5 <- subset.data.frame(df5, Regional.nodes.examined..1988.. <= 89)

# Regional.nodes.positive..1988.. 去掉大于89
table(df5$Regional.nodes.positive..1988..)
df5 <- subset.data.frame(df5, Regional.nodes.positive..1988.. <= 89)

# cs met at dx 分类变量
table(df5$CS.mets.at.dx..2004.2015.)
df5 <- subset.data.frame(df5, CS.mets.at.dx..2004.2015. != 99)


col_names <- c('id', 'tte', 'label', 'age', 'gender', 'ethnicity', 
               'income_level', 'prim_site', 'grade', 'laterality',
               'hist_behavior', 'rx_prim_site', 'cs_tumor_size', 'cs_extension',
               'cs_lymph_nodes', 'cs_mets_at_dx', 'first_mailg', 'summary_stage', 'total_mailg',
               'derived_ajcc_stage', 'nodes_examed', 'nodes_positive')
colnames(df5) <- col_names
write.csv(df5, 'results/seer_data.csv', row.names = F)
table(df5$COD.to.site.recode)

df5 <- read.csv('results/seer_data.csv')
write.csv(df5, 'results/seer_data.csv', row.names = F)


ll <- table(df5$hist_behavior)
ll <- as.data.frame(ll)
cols <- subset.data.frame(ll, Freq < 2000)
cols <- cols$Var1
df5$hist_behavior <- ifelse(df5$hist_behavior %in% cols, 'other', df5$hist_behavior)

table(df5$hist_behavior)

write.csv(df5, 'results/seer_data.csv', row.names = F)



df <- read.csv('results/seer_data.csv')
table(df$label)

