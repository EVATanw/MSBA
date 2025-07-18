library(data.table)

# 1 load the dataset
setwd('/Users/monster/Desktop/dobby/NTU_BA/T1_AY2024_10/Analytics_Strategy/Graded Team Assignment - Gender Discrimination Lawsuit')
lawsuit <- fread("Lawsuit.csv")
summary(lawsuit)
lawsuit$SalIncrement <- lawsuit$Sal95-lawsuit$Sal94
lawsuit$PtgIncrement <- lawsuit$SalIncrement / lawsuit$Sal94
summary(lawsuit)

## 2 descriptive analysis
library(ggplot2)
library(scales)
# page 4-1 Salary and gender (Simon)
ggplot(lawsuit, aes(x = factor(Gender), y = Sal94, color = factor(Gender))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "female", "1" = "male")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Salary94 by Gender", x = "Gender", y = "Sal94") + 
  theme_minimal()

ggplot(lawsuit, aes(x = factor(Gender), y = Sal95, color = factor(Gender))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "female", "1" = "male")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Salary95 by Gender", x = "Gender", y = "Sal95") +
  theme_minimal()

ggplot(lawsuit, aes(x = factor(Gender), y = PtgIncrement, color = factor(Gender)))+
  geom_line()+
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "female", "1" = "male")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Percentage of Salary Increment by Gender", x = "Gender", y = "Percentage") +
  theme_minimal() 

# page 4-2 Rank and gender (Eva)
ggplot(lawsuit, aes(x = factor(Rank), fill = factor(Gender))) +
  geom_bar(position = "dodge", alpha = 1) + 
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full professor")) +
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +
  labs(title = "Number of Individuals by Rank - Gender", x = NULL, y = "Count", fill = "Gender") +
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
# Obviously, women are more likely to be rank 1(Assistant), while men are more likely to be rank 2(Full professor).
# but we can see the total count of male is lager than female. so we can compare the percentage.

gender_rank <- lawsuit %>% group_by(Gender, Rank) %>% summarise(count = n(), .groups = 'drop') %>%
  group_by(Gender) %>% mutate(total_count = sum(count), ptg = count / total_count * 100) %>% ungroup()
print(gender_rank)

ggplot(gender_rank, aes(x = "", y = ptg, fill = factor(Rank))) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar("y") +
  scale_fill_manual(values = c("1" = "#D3B9FF", "2" = "#9B59B6", "3" = "#6A1B9A"),
                    labels = c("1 Assistant", "2 Associate", "3 Full professor")) +
  facet_wrap(~ Gender, labeller = as_labeller(c("0" = "Female", "1" = "Male")), strip.position = "bottom") +
  geom_text(aes(label = paste0(round(ptg, 1), "%")), position = position_stack(vjust = 0.5), size = 4) + 
  labs(title = "Rank Distribution by Gender", x = NULL, y = NULL, fill = "Rank") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 11, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    axis.text.x = element_blank(),  
    axis.text.y = element_blank(),  
    axis.title.x = element_blank(), 
    axis.title.y = element_blank(), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 16, face = "bold"),
    panel.grid = element_blank()
  )
# from the pie chart, the proportion of male at rank 3 is almost three times that of female at rank 3.

## 3 Detail analysis
# page 5-1 department (Haidan)

ggplot(lawsuit, aes(x = factor(Dept), y = Sal94, color = factor(Gender))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "Primarily research emphasis", "1" = "Primarily clinical emphasis")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Salary94 by Dept", x = "Dept", y = "Sal94") +
  theme_minimal()

# page 5-2 clinical (Eva)
# salary - gender (same clin)

library(patchwork)
p1 <- ggplot(lawsuit, aes(x = factor(Clin), y = Sal94, fill = factor(Gender))) +
  geom_boxplot(alpha = 1) +
  scale_x_discrete(labels = c("0" = "0\nresearch\nemphasis", "1" = "1\nclinical\nemphasis")) + 
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +
  scale_y_continuous(labels = comma) + 
  labs(title = "Same Clin, Salary94/95 by Gender", x = NULL, y = "Sal94", fill = 'Gender') +
  theme_minimal()+
  theme(
    axis.text.x = element_text(size = 10, face = "bold"),  
    axis.text.y = element_text(size = 10),  
    axis.title.x = element_text(size = 12, margin = margin(t = 15)), 
    axis.title.y = element_text(size = 12, margin = margin(t = 15)),
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 16, face = "bold") 
  ) 
p2 <- ggplot(lawsuit, aes(x = factor(Clin), y = Sal95, fill = factor(Gender))) +
  geom_boxplot(alpha = 1) +
  scale_x_discrete(labels = c("0" = "0\nresearch\nemphasis", "1" = "1\nclinical\nemphasis")) + 
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +
  scale_y_continuous(labels = comma) + 
  labs(title = NULL, x = NULL, y = "Sal95", fill = 'Gender') +
  theme_minimal()+
  theme(
    axis.text.x = element_text(size = 10, face = "bold"),  
    axis.text.y = element_text(size = 10),  
    axis.title.x = element_text(size = 12, margin = margin(t = 15)), 
    axis.title.y = element_text(size = 12, margin = margin(t = 15)), 
    legend.text = element_text(size = 11), 
    legend.title = element_text(size = 11), 
    plot.title = element_text(size = 16, face = "bold") 
  ) 
p1+p2
# Men earn more than women, both in research and clinical field.

# compare median salary of different rank and gender(same clin)
library(dplyr)
library(scales)

lawsuit_clin <- group_by(lawsuit, Gender, Rank, Clin)

ggplot(lawsuit_clin, aes(x = factor(Rank), y = Sal94, fill = factor(Gender))) +
  geom_boxplot(alpha = 1) +
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full Professor")) + 
  scale_y_continuous(labels = label_comma()) + 
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +  
  labs(title = "Same Clin, Salary94 by Rank and Gender", x = NULL, y = "Sal94", fill = 'Gender') +
  facet_wrap(~ Clin, labeller = labeller(Clin = c("0" = "Primarily Research Emphasis", "1" = "Primarily Clinical Emphasis")), strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    legend.title = element_text(size = 11),                
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),  # Rotate x-axis labels
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold") 
  )

ggplot(lawsuit_clin, aes(x = factor(Rank), y = Sal95, fill = factor(Gender))) +
  geom_boxplot(alpha = 1) +
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full Professor")) + 
  scale_y_continuous(labels = label_comma()) + 
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +  
  labs(title = "Same Clin, Salary95 by Rank and Gender", x = NULL, y = "Sal95", fill = 'Gender') +
  facet_wrap(~ Clin, labeller = labeller(Clin = c("0" = "Primarily Research Emphasis", "1" = "Primarily Clinical Emphasis")), strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    legend.title = element_text(size = 11),                
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),  # Rotate x-axis labels
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold") 
  )

# same field, same rank, male earn more than female.
# what about the specific difference?

# the specific difference of median salary
sal_median_clin <- summarise(lawsuit_clin, sal_median = median(Sal94),.groups = 'drop')

ggplot(sal_median_clin, aes(x = factor(Rank), y = sal_median, fill = factor(Gender))) +
  geom_bar(stat = "identity", position = "dodge", alpha = 1) +
  geom_text(aes(label = paste0(round(sal_median,0))), position = position_dodge(width = 0.9), vjust = -0.5, size = 3) +  # Add text labels
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full Professor")) + 
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +  
  labs(title = "Same Clin, Median of Sal94 by Rank and Gender",
       x = NULL,
       y = "Median of Sal94",
       fill = "Gender") +
  facet_wrap(~ Clin, labeller = labeller(Clin = c("0" = "Primarily Research Emphasis", "1" = "Primarily Clinical Emphasis")), strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    legend.title = element_text(size = 11),                
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),  # Rotate x-axis labels
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold") 
  )

# the specific difference of mean salary
sal_mean_clin <- summarise(lawsuit_clin, sal_mean = mean(Sal94),.groups = 'drop')

ggplot(sal_mean_clin, aes(x = factor(Rank), y = sal_mean, fill = factor(Gender))) +
  geom_bar(stat = "identity", position = "dodge", alpha = 1) +
  geom_text(aes(label = paste0(round(sal_mean,0))), position = position_dodge(width = 0.9), vjust = -0.5, size = 3) +  # Add text labels
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full Professor")) + 
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +  
  labs(title = "Same Clin, Mean of Sal94 by Rank and Gender",
       x = NULL,
       y = "Mean of Sal94",
       fill = "Gender") +
  facet_wrap(~ Clin, labeller = labeller(Clin = c("0" = "Primarily Research Emphasis", "1" = "Primarily Clinical Emphasis")), strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    legend.title = element_text(size = 11),                
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),  # Rotate x-axis labels
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold") 
  )
# same conclusion


# analyze the PtgIncrement
ggplot(lawsuit, aes(x = factor(Clin), y = PtgIncrement, color = factor(Gender))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "0 Primarily research emphasis", "1" = "1 Primarily clinical emphasis")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Percentage of Salary Increment by Clin", x = "Clin", y = "Percentage") +
  theme_minimal()
# not helpful, cuz percentage of salary increment is familiar

# 2-2-2 rank - gender (same clin)
lawsuit_clin <- group_by(lawsuit, Gender, Rank, Clin)
lawsuit_counts <- summarise(lawsuit_clin, count = n(),.groups = 'drop')

ggplot(lawsuit_counts, aes(x = factor(Rank), y = count, fill = factor(Gender))) +
  geom_bar(stat = "identity", position = "dodge", alpha = 1) +
  geom_text(aes(label = count), position = position_dodge(width = 0.9), vjust = -0.5, size = 3) +  # Add text labels
  scale_x_discrete(labels = c("1" = "1 Assistant", "2" = "2 Associate", "3" = "3 Full Professor")) + 
  scale_y_continuous(labels = comma) +
  scale_fill_manual(values = c("1" = "#5cb7bf" , "0" = "#de7774"), labels = c("0" = "Female", "1" = "Male")) +  
  labs(title = "Same Clin, Number of Individuals by Rank and Gender",
       x = NULL,
       y = "Count",
       fill = "Gender") +
  facet_wrap(~ Clin, labeller = labeller(Clin = c("0" = "Primarily Research Emphasis", "1" = "Primarily Clinical Emphasis")), strip.position = "bottom") +
  theme_minimal() +
  theme(
    strip.text = element_text(size = 12, face = "bold"),  # Font size and style of facet labels
    strip.placement = "outside",  # Position of facet labels
    strip.background = element_rect(fill = "lightgray"),  # Background color of facet labels
    legend.title = element_text(size = 11),                
    legend.text = element_text(size = 11),
    axis.text.x = element_text(size = 11, face = "bold"),  # Rotate x-axis labels
    axis.text.y = element_text(size = 11),
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    plot.title = element_text(size = 16, face = "bold") 
  )

# page 6-1 Cert(Annie)
ggplot(lawsuit, aes(x = factor(Cert), y = Sal94, color = factor(Gender))) +
  geom_boxplot() +
  scale_x_discrete(labels = c("0" = "Primarily research emphasis", "1" = "Primarily clinical emphasis")) + 
  scale_y_continuous(labels = comma) + 
  labs(title = "Salary94 by Cert", x = "Cert", y = "Sal94") +
  theme_minimal()

# page 6-2 Publication rate(YANXIN)
# page 7 Experience years(Anh)



# page 8-2 logistics Reg model
## Rank ~ Gender
# CART
set.seed(2020)
# Random sample from majority class Insured and combine into new trainset -----
lawsuit.male <- lawsuit[Gender == 1]

lawsuit.female <- lawsuit[Gender == 0]

chosen <- sample(seq(1:nrow(lawsuit.male)), size = nrow(lawsuit.female))

lawsuit.male.chosen <- lawsuit.male[chosen]

# Combine two data tables by appending the rows
lawsuit2 <- rbind(lawsuit.female, lawsuit.male.chosen)
summary(lawsuit2)
## 50% male and 50% female
# -------------------------------------------------------------------

lawsuit2$Dept <- as.factor(lawsuit2$Dept)
lawsuit2$Gender <- as.factor(lawsuit2$Gender)
lawsuit2$Clin <- as.factor(lawsuit2$Clin)
lawsuit2$Cert <- as.factor(lawsuit2$Cert)
lawsuit2$Rank <- as.factor(lawsuit2$Rank)
summary(lawsuit2)

CARTmodel <- rpart(Rank ~ Dept + Gender + Clin + Cert + Prate + Exper , data = lawsuit2, method = 'class', cp = 0)

printcp(CARTmodel, digits = 3)  ## Turning Point exists.

plotcp(CARTmodel)  ## Too many subtrees to see the best tree using 1SE rule.

# Use my Rcode given in AAD1 Chap 8 or Unit 5 slides to get best tree automatically.
# Compute min CVerror + 1SE in maximal tree m2 
CVerror.cap <- CARTmodel$cptable[which.min(CARTmodel$cptable[,"xerror"]), "xerror"] + CARTmodel$cptable[which.min(CARTmodel$cptable[,"xerror"]), "xstd"]

# Find the optimal CP region whose CV error is just below CVerror.cap in maximal tree m2.
i <- 1; j<- 4
while (CARTmodel$cptable[i,j] > CVerror.cap) {
  i <- i + 1
}

# Get geometric mean of the two identified CP values in the optimal region if optimal tree has at least one split.
cp.opt = ifelse(i > 1, sqrt(CARTmodel$cptable[i,1] * CARTmodel$cptable[i-1,1]), 1)

# Get best tree based on 10 fold CV with 1 SE
CARTmodel.best <- prune(CARTmodel, cp = cp.opt)

printcp(CARTmodel.best, digits = 3)

CARTmodel.best$variable.importance
CARTmodel.best.scaledVarImpt <- round(100*CARTmodel.best$variable.importance/sum(CARTmodel.best$variable.importance))
CARTmodel.best.scaledVarImpt

# gender is the 3rd important factor.

# analyze quantitative relationship
library(nnet)
lawsuit2$Rank <- as.character(lawsuit2$Rank)
lawsuit2$Rank[lawsuit2$Rank %in% c("1", "2")] <- "4"
lawsuit2$Rank_binary <- ifelse(lawsuit2$Rank == 4, 0, 1)
summary(lawsuit2)
Rmodel <- glm(Rank_binary ~ Dept + Gender + Clin + Cert + Prate + Exper, family = binomial, data = lawsuit2)
summary(Rmodel)

Rmodel_exP <- glm(Rank_binary ~ Dept + Gender + Clin + Cert + Exper, family = binomial, data = lawsuit2)
summary(Rmodel_exP)

new_data_male_rank <- data.frame(
  Dept = factor(5, levels = levels(lawsuit2$Dept)),
  Gender = factor(1, levels = levels(lawsuit2$Gender)),
  Clin = factor(1, levels = levels(lawsuit2$Clin)),
  Cert = factor(1, levels = levels(lawsuit2$Cert)),
  Prate = median(lawsuit2$Prate),  
  Exper = mean(lawsuit2$Exper) 
)
new_data_female_rank <- data.frame(
  Dept = factor(5, levels = levels(lawsuit2$Dept)),
  Gender = factor(0, levels = levels(lawsuit2$Gender)),
  Clin = factor(1, levels = levels(lawsuit2$Clin)),
  Cert = factor(1, levels = levels(lawsuit2$Cert)),
  Prate = median(lawsuit2$Prate),  
  Exper = mean(lawsuit2$Exper) 
)

predicted_male_rank <- predict(Rmodel, newdata = new_data_male_rank, type = "response")
predicted_female_rank <- predict(Rmodel, newdata = new_data_female_rank, type = "response")

print(predicted_male_rank)
print(predicted_female_rank)


prob_rank <- data.frame(
  Rank3_probability = c(predicted_male_rank[1], predicted_female_rank[1]),
  Gender = c("male", "female")
)

print(prob_rank)


# page 8-1 Linear Reg model

lawsuit$Dept <- as.factor(lawsuit$Dept)
lawsuit$Gender <- as.factor(lawsuit$Gender)
lawsuit$Clin <- as.factor(lawsuit$Clin)
lawsuit$Cert <- as.factor(lawsuit$Cert)
lawsuit$Rank <- as.factor(lawsuit$Rank)
summary(lawsuit)

hist(lawsuit$Sal94, main = "Histogram of Sal94", xlab = "Sal94", breaks = 30) #存在偏态分布
hist(log10(lawsuit$Sal94), main = "Histogram of log10(Sal94)", xlab = "Sal94", breaks = 30)
m10 <- lm(log10(lawsuit$Sal94) ~ Dept + Gender + Clin + Cert + Exper + Prate, data = lawsuit) #Prate not significant
m1 <- lm(log10(lawsuit$Sal94) ~ Dept + Gender + Clin + Cert + Exper, data = lawsuit) #为啥要做log？
summary(m1)

# Probability about rank and salary of male/female(Eva)

new_data_male100 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female100 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male200 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female200 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male300 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female300 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male400 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female400 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male500 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female500 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male600 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female600 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male110 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female110 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male210 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female210 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male310 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female310 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male410 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female410 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male510 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female510 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male610 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female610 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(0, levels = levels(lawsuit$Cert)), # 1、0
  Exper = mean(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male101 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female101 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male201 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female201 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male301 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female301 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male401 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female401 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male501 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female501 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male601 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female601 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(0, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male111 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female111 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male211 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female211 <- data.frame(
  Dept = factor(2, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male311 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female311 <- data.frame(
  Dept = factor(3, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male411 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female411 <- data.frame(
  Dept = factor(4, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male511 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female511 <- data.frame(
  Dept = factor(5, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)

new_data_male611 <- data.frame(
  Dept = factor(1, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(1, levels = levels(lawsuit$Gender))
)
new_data_female611 <- data.frame(
  Dept = factor(6, levels = levels(lawsuit$Dept)), # 1、2、3、4、5、6，mode=5
  Clin = factor(1, levels = levels(lawsuit$Clin)), # 1、0
  Cert = factor(1, levels = levels(lawsuit$Cert)), # 1、0
  Exper = median(lawsuit$Exper), # median
  Gender = factor(0, levels = levels(lawsuit$Gender))
)


predicted_male100 <- predict(m1, newdata = new_data_male100)
predicted_male200 <- predict(m1, newdata = new_data_male200)
predicted_male300 <- predict(m1, newdata = new_data_male300)
predicted_male400 <- predict(m1, newdata = new_data_male400)
predicted_male500 <- predict(m1, newdata = new_data_male500)
predicted_male600 <- predict(m1, newdata = new_data_male600)
predicted_male110 <- predict(m1, newdata = new_data_male110)
predicted_male210 <- predict(m1, newdata = new_data_male210)
predicted_male310 <- predict(m1, newdata = new_data_male310)
predicted_male410 <- predict(m1, newdata = new_data_male410)
predicted_male510 <- predict(m1, newdata = new_data_male510)
predicted_male610 <- predict(m1, newdata = new_data_male610)
predicted_male101 <- predict(m1, newdata = new_data_male101)
predicted_male201 <- predict(m1, newdata = new_data_male201)
predicted_male301 <- predict(m1, newdata = new_data_male301)
predicted_male401 <- predict(m1, newdata = new_data_male401)
predicted_male501 <- predict(m1, newdata = new_data_male501)
predicted_male601 <- predict(m1, newdata = new_data_male601)
predicted_male111 <- predict(m1, newdata = new_data_male111)
predicted_male211 <- predict(m1, newdata = new_data_male211)
predicted_male311 <- predict(m1, newdata = new_data_male311)
predicted_male411 <- predict(m1, newdata = new_data_male411)
predicted_male511 <- predict(m1, newdata = new_data_male511)
predicted_male611 <- predict(m1, newdata = new_data_male611)
predicted_female100 <- predict(m1, newdata = new_data_female100)
predicted_female200 <- predict(m1, newdata = new_data_female200)
predicted_female300 <- predict(m1, newdata = new_data_female300)
predicted_female400 <- predict(m1, newdata = new_data_female400)
predicted_female500 <- predict(m1, newdata = new_data_female500)
predicted_female600 <- predict(m1, newdata = new_data_female600)
predicted_female110 <- predict(m1, newdata = new_data_female110)
predicted_female210 <- predict(m1, newdata = new_data_female210)
predicted_female310 <- predict(m1, newdata = new_data_female310)
predicted_female410 <- predict(m1, newdata = new_data_female410)
predicted_female510 <- predict(m1, newdata = new_data_female510)
predicted_female610 <- predict(m1, newdata = new_data_female610)
predicted_female101 <- predict(m1, newdata = new_data_female101)
predicted_female201 <- predict(m1, newdata = new_data_female201)
predicted_female301 <- predict(m1, newdata = new_data_female301)
predicted_female401 <- predict(m1, newdata = new_data_female401)
predicted_female501 <- predict(m1, newdata = new_data_female501)
predicted_female601 <- predict(m1, newdata = new_data_female601)
predicted_female111 <- predict(m1, newdata = new_data_female111)
predicted_female211 <- predict(m1, newdata = new_data_female211)
predicted_female311 <- predict(m1, newdata = new_data_female311)
predicted_female411 <- predict(m1, newdata = new_data_female411)
predicted_female511 <- predict(m1, newdata = new_data_female511)
predicted_female611 <- predict(m1, newdata = new_data_female611)

e <- round(new_data_male100$Exper,1)

Dept_result <- c(1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6,1,2,3,4,5,6)
Clin_result <- c(0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1)
Cert_result <- c(0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1)
Exper_result <- c(e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e,e)
male_result <- c(10**predicted_male100[1],
                 10**predicted_male200[1],
                 10**predicted_male300[1],
                 10**predicted_male400[1],
                 10**predicted_male500[1],
                 10**predicted_male600[1],
                 10**predicted_male101[1],
                 10**predicted_male201[1],
                 10**predicted_male301[1],
                 10**predicted_male401[1],
                 10**predicted_male501[1],
                 10**predicted_male601[1],
                 10**predicted_male110[1],
                 10**predicted_male210[1],
                 10**predicted_male310[1],
                 10**predicted_male410[1],
                 10**predicted_male510[1],
                 10**predicted_male610[1],
                 10**predicted_male111[1],
                 10**predicted_male211[1],
                 10**predicted_male311[1],
                 10**predicted_male411[1],
                 10**predicted_male511[1],
                 10**predicted_male611[1])
female_result <- c(10**predicted_female100[1],
                   10**predicted_female200[1],
                   10**predicted_female300[1],
                   10**predicted_female400[1],
                   10**predicted_female500[1],
                   10**predicted_female600[1],
                   10**predicted_female101[1],
                   10**predicted_female201[1],
                   10**predicted_female301[1],
                   10**predicted_female401[1],
                   10**predicted_female501[1],
                   10**predicted_female601[1],
                   10**predicted_female110[1],
                   10**predicted_female210[1],
                   10**predicted_female310[1],
                   10**predicted_female410[1],
                   10**predicted_female510[1],
                   10**predicted_female610[1],
                   10**predicted_female111[1],
                   10**predicted_female211[1],
                   10**predicted_female311[1],
                   10**predicted_female411[1],
                   10**predicted_female511[1],
                   10**predicted_female611[1])

prob_sal <- data.frame(
  Dept = Dept_result,
  Clin = Clin_result,
  Cert = Cert_result,
  Exper = Exper_result,
  ProbableSalary_male = male_result,
  ProbableSalary_female = female_result
)
prob_sal['male-female'] = male_result-female_result
prob_sal$higher_salary <- ifelse(prob_sal$'male-female' > 0, 'male', 'female')

print(prob_sal[,c(1,2,3,4,8)])


print(prob_sal)
print((prob_sal[1,1]/prob_sal[2,1]-1)*100)

# 创建数据的通用函数
create_data <- function(dept, gender, clin, cert, prate, exper) {
  data.frame(
    Dept = factor(dept, levels = levels(lawsuit$Dept)),
    Gender = factor(gender, levels = levels(lawsuit$Gender)),
    Clin = factor(clin, levels = levels(lawsuit$Clin)),
    Cert = factor(cert, levels = levels(lawsuit$Cert)),
    Prate = prate,
    Exper = exper
  )
}

# 预测函数
predict_salaries <- function(dept, clin_list, cert_list, gender_list, prate, exper) {
  male_data <- list()
  female_data <- list()
  
  for (i in seq_along(clin_list)) {
    # 创建男性和女性数据
    male_data[[i]] <- create_data(dept, gender_list[1], clin_list[i], cert_list[i], prate, exper)
    female_data[[i]] <- create_data(dept, gender_list[2], clin_list[i], cert_list[i], prate, exper)
  }
  
  # 进行预测
  predicted_male <- lapply(male_data, function(data) predict(Smodel94_exR, newdata = data)[1])
  predicted_female <- lapply(female_data, function(data) predict(Smodel94_exR, newdata = data)[1])
  
  # 创建最终的数据框
  prob_sal <- data.frame(
    Dept = as.numeric(as.character(male_data[[1]]$Dept)),
    Clin = sapply(male_data, function(data) as.numeric(as.character(data$Clin))),
    Cert = sapply(male_data, function(data) as.numeric(as.character(data$Cert))),
    Prate = rep(prate, length(clin_list)),
    Exper = round(rep(exper, length(clin_list)), 1),
    ProbableSalary_male = unlist(predicted_male),
    ProbableSalary_female = unlist(predicted_female)
  )
  
  return(prob_sal)
}

# 使用循环生成数据并进行预测
dept <- 5
clin_list <- c(1, 1)  # 两组 Clin 值
cert_list <- c(1, 0)  # 两组 Cert 值
gender_list <- c(1, 0)  # 男性和女性
prate <- median(lawsuit$Prate)
exper <- mean(lawsuit$Exper)

# 调用函数
result <- predict_salaries(dept, clin_list, cert_list, gender_list, prate, exper)

# 打印结果
print(result)





