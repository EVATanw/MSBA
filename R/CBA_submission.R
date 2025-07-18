# Purpose: Demo of arules Rpackage
# Author: Chew C. H.
# Dataset: milk.csv
# How to conversion to transactions datatype: https://rdrr.io/cran/arules/man/transactions-class.html

library(ggplot2)
library(dplyr)
library(scales)
library(rpart)
# library(randomForest) cannot install

setwd('/Users/monster/Desktop/dobby/NTU_BA/T1_AY2024_10/Analytics_Strategy/CBA')
data <- read.csv('INF002v4.csv')

summary(data)
## Q1 Explore the data and report 3 notable findings.
# 1-1 what is the distribution of LOS?
data$LOS <- cut(data$Length.of.Stay, breaks = c(1, 3, 6, 11, 120), include.lowest = T)

ggplot(data,aes(LOS)) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  ) 

ggplot(data, aes(y = Length.of.Stay)) +
  geom_boxplot() +
  scale_y_continuous(labels = comma) + 
  labs(title = "LOS distribution", x = NULL, y = "count") + 
  theme_minimal()

# 1-2 is there any relation between LOS and Hospital.Service.Area?
levels(data$Hospital.Service.Area)
length_area_avg <- data %>% group_by(Hospital.Service.Area) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_area_avg
# -- "New York City" "Finger Lakes" >10
# -- "Southern Tier" "Western NY" >9
# -- "Long Island" "Hudson Valley" "Central NY" "Capital/Adirond" >8

length_area_median <- data %>% group_by(Hospital.Service.Area) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_area_median
# -- "New York City" "Southern Tier" : 7
# -- "Finger Lakes" "Western NY" "Long Island" "Hudson Valley": 6
# -- "Central NY" "Capital/Adirond" : 5.5/5

ggplot(data,aes(x = factor(Hospital.Service.Area), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution each Area', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  scale_fill_manual(values = c("[1,3]" = "#ADD8E6", "(3,6]" = "#87CEEB", "(6,11]" = "#4682B4","(11,120]" = "#00008B"))+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )

# -- "Capital/Adirond" 1>2>3>4 
# -- "Central NY" 2>1>3>4      o 
# -- "Finger Lakes" 1>4>2>3    
# -- "Hudson Valley" 2>1>3>4   o
# -- "Long Island"  2>1>3>4    o
# -- "New York City" 4>3>2>1   x
# -- "Southern Tier" 2=4>3>1   x
# -- "Western NY" 1>2>4>3

# >> the length of stay at hospitals in "New York City" is more likely to be longer.

# 1-3 is there any relation between LOS and Age.Group?
levels(data$Age.Group)
length_age_avg <- data %>% group_by(Age.Group) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_age_avg
# -- 50 to 69 > 70 or Older > 30 to 49 > 18 to 29 > 0 to 17
length_age_median <- data %>% group_by(Age.Group) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_age_median
# -- 70 or Older > 50 to 69 > 30 to 49 > 18 to 29 > 0 to 17
# -- mean > median, there always are some people in every age group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Age.Group))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by Age', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )

# -- in every LOS group, the elderly are most and the young are least. but the population of each age group may effects.

ggplot(data,aes(x = factor(Age.Group), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution each Age Group', x = NULL, y='count')+
  guides(fill = guide_legend(title = 'LOS Group'))+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )

# -- "0 to 17" : 1>2>3>4
# -- "18 to 29" : 1>2>3>4
# -- "30 to 49" : 1>2>4>3
# -- "50 to 69" :4>2>1>3
# -- "70 or Older": 2>3>4>1

# >> the length of stay of elderly is more likely to be longer than young.
# >> when the age is larger than 50, the length of stay increases and is more likely to be over 11 days.
# >> but when the age is up to 70, the length of stay is more likely to be 3 to 6 days.


# 1-4 is there any relation between LOS and Gender?
levels(data$Gender)
length_gender_avg <- data %>% group_by(Gender) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_gender_avg
# -- M(9.96) > F(9.18)
length_gender_median <- data %>% group_by(Gender) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_gender_median
# -- M = F = 6
# -- mean > median, there always are some people in every gender group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Gender))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by Gender', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- every length group(except [1,3]) especially (11,120], M>F

ggplot(data,aes(x = factor(Gender), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per Gender', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- F: 1>2>3>4
# -- M: 2>4>1>3

# >> female is more likely to stay less than 6 days.

# 1-5 is there any relation between LOS and Race?
levels(data$Race)
length_race_avg <- data %>% group_by(Race) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_race_avg
# -- Black/African American > Other Race > Multi-racial > White
length_race_median <- data %>% group_by(Race) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_race_median
# -- Black/African American > (Other Race = Multi-racial = White)
# -- mean > median, there always are some people in every race group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Race))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by Race', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- every length group, white > other race > Black/African American > Multi-racial. the population factor appears again.

ggplot(data,aes(x = factor(Race), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution each Race', x = NULL, y='count')+
  theme_minimal()+
  guides(fill = guide_legend(title = 'LOS Group'))+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- white: 2>1>3>4
# -- other race : 2>1>4>3 
# -- Black/African American : 4>3>2>1
# -- Multi-racial : 1>2>4>3

# >> the length of stay of Black/African American is more likely to be more than 6 days.
# >> the length of stay of white is more likely to be less than 6 days.

# 1-6 is there any relation between LOS and Ethnicity?
levels(data$Ethnicity)
length_Ethnicity_avg <- data %>% group_by(Ethnicity) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_Ethnicity_avg
# -- Multi-ethnic is the lowest.
length_Ethnicity_median <- data %>% group_by(Ethnicity) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_Ethnicity_median
# -- all 6.
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Ethnicity))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by Ethnicity', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- Not Span/Hispanic >> Spanish/Hispanic >> Multi-ethnic.

ggplot(data,aes(x = factor(Ethnicity), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per Ethnicity', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- Not Span/Hispanic: 2>1>3>4
# -- Spanish/Hispanic: 1>2>4>3
# -- Multi-ethnic: 2>1>4>3

# >> cannot see obvious pattern.

# 1-6 is there any relation between LOS and Admission?
levels(data$Type.of.Admission)
length_Admission_avg <- data %>% group_by(Type.of.Admission) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_Admission_avg
# -- urgent12.8 > elective11.6 > trauma9.96 > emergency9.46
length_Admission_median <- data %>% group_by(Type.of.Admission) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_Admission_median
# -- trauma9 > urgent8 > elective7 > emergency6
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Type.of.Admission))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by Admission', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- in every length group, emergency is much more than others. then urgent. then elective > trauma.

ggplot(data,aes(x = factor(Type.of.Admission), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per Admission', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- emergency: 2>1>4>3
# -- urgent: 4>3>2>1
# -- elective: 4>1>2>3
# -- trauma: 3>4>2>1

# >> the length of stay of urgent and elective is more likely to be more than 11 days.
# >> the length of stay of emergency is more likely to be less than 6 days

# 1-7 is there any relation between LOS and APR.DRG.Code?
data$APR.DRG.Code <- as.factor(data$APR.DRG.Code)
levels(data$APR.DRG.Code)
length_illness_avg <- data %>% group_by(APR.DRG.Code) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_illness_avg
# -- 4(53.9) > 5(44.3) > 2(43) > 161(40)
length_illness_median <- data %>% group_by(APR.DRG.Code) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_illness_median
# -- 4(44) > 5(37) > 2(43) > 161(40)
# -- mean >= median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(APR.DRG.Code))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by illness', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- in every length group, NO.72 is much more than others. then NO.710.

ggplot(data,aes(x = factor(APR.DRG.Code), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per illness', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# >> the length of stay of patients with NO.890, NO.710, NO.5 and NO.4 is more likely to be more than 6 days.
# >> the length of stay of patients with NO.720 is more likely to be less than 6 days.

# 1-8 is there any relation between LOS and APR.Severity.of.Illness.Description?
levels(data$APR.Severity.of.Illness.Description)
length_illnessS_avg <- data %>% group_by(APR.Severity.of.Illness.Description) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_illnessS_avg
# -- Extreme 13.1 > Major 7.82 > Moderate 4.72 > Minor 3.28
length_illnessS_median <- data %>% group_by(APR.Severity.of.Illness.Description) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_illnessS_median
# -- Extreme 9 > Major 6 > Moderate 4 > Minor 3
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(APR.Severity.of.Illness.Description))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by illness severity', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- [1,3]: moderate > major > extreme > minor
# -- (3,6]: moderate > major > extreme > minor
# -- (6,11]: extreme > major > moderate > minor
# -- (11,120]: extreme > major > moderate > minor

ggplot(data,aes(x = factor(APR.Severity.of.Illness.Description), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per illness severity', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- extreme: 4>3>2>1
# -- major: 2>3>1>4
# -- moderate: 1>2>3>4
# -- minor: 1>2>3>4
# >> the length of stay of patients with extreme severe illness is more likely to be more than 6 days and even more than 11 days.
# >> the length of stay of patients with minor and moderate severe illness is more likely to be less than 6 days and even less than 3 days.
# >> once the illness severity is higher than moderate, then the probability of staying in hospital more than 6 days increases.

# 1-9 is there any relation between LOS and APR.Risk.of.Mortality?
levels(data$APR.Risk.of.Mortality)
length_mortality_avg <- data %>% group_by(APR.Risk.of.Mortality) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_mortality_avg
# -- Extreme 12.5 > Major 8.34 > Moderate 5.59 > Minor 3.8
length_mortality_median <- data %>% group_by(APR.Risk.of.Mortality) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_mortality_median
# -- Extreme 9 > Major 6 > Moderate 4 > Minor 3
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(APR.Risk.of.Mortality))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by mortality risk', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- in every length group: extreme > moderate > major > minor

ggplot(data,aes(x = factor(APR.Risk.of.Mortality), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per mortality risk', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- extreme: 4>3>2>1
# -- major: 2>3>1>4
# -- moderate: 1>2>3>4
# -- minor: 1>2>3>4
# >> the length of stay of patients with extreme mortality risk is more likely to be more than 6 days and even more than 11 days.
# >> the length of stay of patients with minor and moderate mortality risk is more likely to be less than 6 days and even less than 3 days.
# >> once the mortality risk is higher than moderate, then the probability of staying in hospital more than 6 days increases.

# 1-10 is there any relation between LOS and APR.Medical.Surgical.Description?
levels(data$APR.Medical.Surgical.Description)
length_surgical_avg <- data %>% group_by(APR.Medical.Surgical.Description) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_surgical_avg
# -- surgical 19.5 >> medical 8.29
length_surgical_median <- data %>% group_by(APR.Medical.Surgical.Description) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_surgical_median
# -- surgical 13 >> medical 6
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(APR.Medical.Surgical.Description))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by medical or surgical', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- in every length group: medical > surgical

ggplot(data,aes(x = factor(APR.Medical.Surgical.Description), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per medical or surgical', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
)
# --medical: 2>1>3>4
# --surgical: 4>3>2>1
# >> the length of stay of surgical is more likely to be more than 6 days and even more than 11 days.
# >> the length of stay of medical is more likely to be less than 6 days and even less than 3 days.

# 1-11 is there any relation between LOS and Emergency.Department.Indicator?
levels(data$Emergency.Department.Indicator)
length_indicator_avg <- data %>% group_by(Emergency.Department.Indicator) %>% summarize(mean_length = mean(Length.of.Stay, na.rm = TRUE))
length_indicator_avg
# -- N11.8 > Y9.46
length_indicator_median <- data %>% group_by(Emergency.Department.Indicator) %>% summarize(median_length = median(Length.of.Stay, na.rm = TRUE))
length_indicator_median
# -- N7 > Y6
# -- mean > median, there always are some people in every ethnicity group stay quite long.

ggplot(data,aes(x = factor(LOS), fill = factor(Emergency.Department.Indicator))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution by emergency indicator', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- in every length group: Y>N

ggplot(data,aes(x = factor(Emergency.Department.Indicator), fill = factor(LOS))) + 
  geom_bar(position = 'dodge',alpha = 1) +
  labs(title = 'LOS distribution per emergency indicator', x = NULL, y='count')+
  theme_minimal()+
  geom_text(stat = 'count', aes(label = after_stat(count)), position = position_dodge(width = 0.9), vjust = -0.5, size = 4)+
  theme(
    axis.text.x = element_text(size = 11, face = "bold"),  
    axis.text.y = element_text(size = 11),  
    axis.title.y = element_text(size = 12, margin = margin(t = 15), face = "bold"), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 20, face = "bold") 
  )
# -- Y: 2>1>4>3
# -- N: 4>1>2>3
# cannot see obvious pattern


## Q2 State the list of potential predictor X variables that will be inputs to models and the final dimensions of the dataset (i.e. number of observations and variables).

## X: Hospital.Service.Area, Age.Group, Gender, Race, Ethnicity, Type.of.Admission, APR.DRG.Code, APR.Severity.of.Illness.Description, APR.Risk.of.Mortality, APR.Medical.Surgical.Description, Emergency.Department.Indicator.  
data_new <- data[data$Hospital.Service.Area != "" &
                   data$Gender != "U" & 
                   data$Ethnicity != "Unknown" & 
                   data$Type.of.Admission != "Not Available" &
                   data$APR.Severity.of.Illness.Description != "" &
                   data$APR.Risk.of.Mortality != "" &
                   data$APR.Medical.Surgical.Description != "Not Applicable",
                 c('Length.of.Stay',
                   'Hospital.Service.Area', 
                   'Age.Group', 
                   'Gender', 
                   'Race', 
                   'Ethnicity', 
                   'Type.of.Admission', 
                   'APR.DRG.Code', 
                   'APR.Severity.of.Illness.Description', 
                   'APR.Risk.of.Mortality', 
                   'APR.Medical.Surgical.Description', 
                   'Emergency.Department.Indicator')]
data_new <- droplevels(data_new)
summary(data_new)
sum(is.na(data_new))

## final dimensions: 25320 obs. of 12 variables

## Q3 Using 70-30 train-test, conduct (a) Linear Regression, (b) CART and (c) Random Forest to compare testset errors. Display the results in a table.

# combine several levels to one.
# since there is only one record in some levels, if we split data to train-test data, such data cannot be split and predicted successfully.
data_new$APR.DRG.Code <- replace(data_new$APR.DRG.Code, data_new$APR.DRG.Code %in% c('2', '6', '7', '8', '161', '956'), 'others')
data_new$APR.DRG.Code <- as.factor(data_new$APR.DRG.Code)
levels(data_new$APR.DRG.Code)

set.seed(123)
train_index <- sample(1:nrow(data_new), 0.7 * nrow(data_new))
train_data <- data_new[train_index, ]
test_data <- data_new[-train_index, ]

# 3-a linear regression
m_linear <- lm(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                 APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                 Emergency.Department.Indicator, data=train_data)
lm_predictions <- predict(m_linear, newdata = test_data)

# model performance
train_rmse <- sqrt(mean(residuals(m_linear)^2))
train_rmse
test_rmse <- sqrt(mean((test_data$Length.of.Stay - lm_predictions)^2))
test_rmse

train_r2 <- summary(m_linear)$r.squared
train_r2
test_r2 <- 1 - (sum((test_data$Length.of.Stay - lm_predictions)^2) / sum((test_data$Length.of.Stay - mean(test_data$Length.of.Stay))^2))
test_r2

summary(m_linear)

# 3-b CART
summary(data_new)

m_CART <- rpart(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                  APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                  Emergency.Department.Indicator, data = train_data, method = 'anova', cp = 0)
print(m_CART)
tail(printcp(m_CART)) 
plotcp(m_CART)

CVerror.cap <- m_CART$cptable[which.min(m_CART$cptable[,"xerror"]), "xerror"] + 
  m_CART$cptable[which.min(m_CART$cptable[,"xerror"]), "xstd"]

i <- 1; j<- 4
while (m_CART$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}
cp.opt = ifelse(i > 1, sqrt(m_CART$cptable[i,1] * m_CART$cptable[i-1,1]), 1)
m_CART.best <- prune(m_CART, cp = cp.opt)
tail(printcp(m_CART.best))

CART_predictions <- predict(m_CART.best, newdata = test_data)
train_rmse <- sqrt(mean(residuals(m_CART.best)^2))
train_rmse
test_rmse <- sqrt(mean((test_data$Length.of.Stay - CART_predictions)^2))
test_rmse

SST <- sum((test_data$Length.of.Stay - mean(test_data$Length.of.Stay))^2) 
SSE <- sum((test_data$Length.of.Stay - CART_predictions)^2) 
r2 <- 1 - (SSE / SST)
r2

importance <- m_CART$variable.importance
importance

# 3-c Random Forest
m_RF <- randomForest(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                       APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                       Emergency.Department.Indicator, data = train_data, 
                       na.action = na.omit, 
                       importance = T)
RF_test_predictions <- predict(m_RF, newdata = test_data)
RF_train_predictions <- predict(m_RF, newdata = train_data)
train_rmse <- sqrt(mean((train_data$Length.of.Stay - RF_train_predictions)^2))
train_rmse
test_rmse <- sqrt(mean((test_data$Length.of.Stay - RF_test_predictions)^2))
test_rmse

## improve models

#remove outliers
remove_outliers <- function(x, threshold = 1.5) {
  Q1 <- quantile(x, 0.25)
  Q3 <- quantile(x, 0.75)
  IQR <- Q3 - Q1
  mask <- !(x < (Q1 - threshold * IQR) | x > (Q3 + threshold * IQR))
  return(mask)
} #chatgpt

mask <- remove_outliers(data_new$Length.of.Stay)
data_clean <- data_new[mask, ]

# 3-a linear regression
m_linear_clean <- lm(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                 APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                 Emergency.Department.Indicator, data=train_data_clean)
lm_predictions_clean <- predict(m_linear_clean, newdata = test_data_clean)

# model performance
train_rmse_clean <- sqrt(mean(residuals(m_linear_clean)^2))
train_rmse_clean
test_rmse_clean <- sqrt(mean((test_data_clean$Length.of.Stay - lm_predictions_clean)^2))
test_rmse_clean

train_r2_clean <- summary(m_linear_clean)$r.squared
train_r2_clean
test_r2_clean <- 1 - (sum((test_data_clean$Length.of.Stay - lm_predictions_clean)^2) / sum((test_data_clean$Length.of.Stay - mean(test_data_clean$Length.of.Stay))^2))
test_r2_clean

# 3-b CART
m_CART_clean <- rpart(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                  APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                  Emergency.Department.Indicator, data = train_data_clean, method = 'anova', cp = 0)
print(m_CART_clean)
tail(printcp(m_CART_clean)) 
plotcp(m_CART_clean)

CVerror.cap <- m_CART_clean$cptable[which.min(m_CART_clean$cptable[,"xerror"]), "xerror"] + 
  m_CART_clean$cptable[which.min(m_CART_clean$cptable[,"xerror"]), "xstd"]

i <- 1; j<- 4
while (m_CART_clean$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}
cp.opt = ifelse(i > 1, sqrt(m_CART_clean$cptable[i,1] * m_CART_clean$cptable[i-1,1]), 1)
m_CART_clean.best <- prune(m_CART_clean, cp = cp.opt)
tail(printcp(m_CART_clean.best))

CART_predictions_clean <- predict(m_CART_clean.best, newdata = test_data_clean)
train_rmse_clean <- sqrt(mean(residuals(m_CART_clean.best)^2))
train_rmse_clean
test_rmse_clean <- sqrt(mean((test_data_clean$Length.of.Stay - CART_predictions_clean)^2))
test_rmse_clean

SST_clean <- sum((test_data_clean$Length.of.Stay - mean(test_data_clean$Length.of.Stay))^2) 
SSE_clean <- sum((test_data_clean$Length.of.Stay - CART_predictions_clean)^2) 
r2_clean <- 1 - (SSE_clean / SST_clean)
r2_clean

importance_clean <- m_CART_clean$variable.importance
importance_clean

# 3-c Random Forest
m_RF_clean <- randomForest(Length.of.Stay ~ Hospital.Service.Area + Age.Group + Gender + Race + Ethnicity + Type.of.Admission + 
                       APR.DRG.Code + APR.Severity.of.Illness.Description + APR.Risk.of.Mortality + APR.Medical.Surgical.Description + 
                       Emergency.Department.Indicator, data = train_data_clean, 
                     na.action = na.omit, 
                     importance = T)
RF_test_predictions_clean <- predict(m_RF_clean, newdata = test_data_clean)
RF_train_predictions_clean <- predict(m_RF_clean, newdata = train_data_clean)
train_rmse_clean <- sqrt(mean((train_data_clean$Length.of.Stay - RF_train_predictions_clean)^2))
train_rmse_clean
test_rmse_clean <- sqrt(mean((test_data_clean$Length.of.Stay - RF_test_predictions_clean)^2))
test_rmse_clean






