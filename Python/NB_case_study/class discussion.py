# -*- coding: utf-8 -*-
"""
Created on Tue Jan 14 19:41:17 2025

@author: Giselle_Yhs
"""

# 1. Import the Data
import pandas as pd

# Load the data
file_path = "UV6486-XLS-ENG.xlsx"
sheet_name = "Nils Baker data"

# Read the dataset
data = pd.read_excel(file_path, sheet_name=sheet_name)

# Display the first few rows to check the data structure
print(data.head())

# Remove rows where the 'ID' column is not numeric (e.g., the comment row)
data_cleaned = data[pd.to_numeric(data['ID'], errors='coerce').notna()]

# Convert the 'ID' column to integers for consistency
data_cleaned['ID'] = data_cleaned['ID'].astype(int)

data_cleaned['Penetration Rate'] = data_cleaned['Households with Account'] / data_cleaned['Total Households in Area']

# 2. set the model
import numpy as np
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import variance_inflation_factor
from scipy.stats import levene
import matplotlib.pyplot as plt
import seaborn as sns

# Map "Inside" to 1 and "Outside" to 0
data_cleaned['Inside/Outside Footprint'] = data_cleaned['Inside/Outside Footprint'].map({'Inside': 1, 'Outside': 0})

# Ensure Penetration Rate is numeric
data_cleaned['Penetration Rate'] = pd.to_numeric(data_cleaned['Penetration Rate'], errors='coerce')

# Drop rows with missing or invalid values in relevant columns
data_cleaned = data_cleaned.dropna(subset=['Inside/Outside Footprint', 'Penetration Rate'])

# 1. Define X and y
X = data_cleaned[['Inside/Outside Footprint']]
X['Intercept'] = 1  # Add an intercept for the regression
y = data_cleaned['Penetration Rate']

# 2. Fit the regression model
model = sm.OLS(y, X).fit()

# --- Assumption 1: Linearity ---
# Plot observed vs. predicted values
data_cleaned['Predicted'] = model.predict(X)
plt.figure(figsize=(8, 6))
sns.scatterplot(x=data_cleaned['Inside/Outside Footprint'], y=y, label='Observed')
sns.scatterplot(x=data_cleaned['Inside/Outside Footprint'], y=data_cleaned['Predicted'], label='Predicted')
plt.title("Linearity Check: Observed vs. Predicted Values")
plt.xlabel("Inside/Outside Footprint (Binary)")
plt.ylabel("Penetration Rate")
plt.legend()
plt.show()

# --- Assumption 2: Normality of Errors ---
# Q-Q Plot of residuals
residuals = model.resid
sm.qqplot(residuals, line='s')
plt.title("Q-Q Plot: Normality of Residuals")
plt.show()

# --- Assumption 3: Homoscedasticity (Levene's Test) ---
# Group residuals by 'Inside/Outside Footprint' and test homoscedasticity
group1 = residuals[data_cleaned['Inside/Outside Footprint'] == 1]
group2 = residuals[data_cleaned['Inside/Outside Footprint'] == 0]
levene_stat, levene_p = levene(group1, group2)
print(f"Levene's Test: Statistic = {levene_stat:.2f}, p-value = {levene_p:.4f}")
if levene_p > 0.05:
    print("Homoscedasticity assumption is satisfied.")
else:
    print("Homoscedasticity assumption is violated.")

# --- Assumption 4: Multicollinearity (VIF) ---
# Check VIF (though not strictly needed for a single independent variable)
vif_data = pd.DataFrame()
vif_data['Variable'] = X.columns
vif_data['VIF'] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
print(vif_data)


# T-test 

from scipy.stats import ttest_ind

# --- One-Tailed t-Test ---
# 分组数据
inside_group = data_cleaned[data_cleaned['Inside/Outside Footprint'] == 1]['Penetration Rate']
outside_group = data_cleaned[data_cleaned['Inside/Outside Footprint'] == 0]['Penetration Rate']

# 进行双尾 t 检验
t_stat, p_value_two_tailed = ttest_ind(inside_group, outside_group, equal_var=True)

# 转换为单尾 p 值（假设效果是正向的：Inside > Outside）
p_value_one_tailed = p_value_two_tailed / 2

# 打印结果
print(f"t-Statistic: {t_stat:.4f}")
print(f"Two-Tailed p-Value: {p_value_two_tailed:.4f}")
print(f"One-Tailed p-Value: {p_value_one_tailed:.4f}")

# 显著性判断（假设 α = 0.05）
alpha = 0.05
if p_value_one_tailed < alpha and t_stat > 0:
    print("Reject the null hypothesis: Inside footprint significantly increases penetration rate.")
else:
    print("Fail to reject the null hypothesis: No significant positive effect of inside footprint.")






# Transfor the variabel: log(y)
import numpy as np
import pandas as pd
import statsmodels.api as sm
from statsmodels.stats.outliers_influence import variance_inflation_factor
from scipy.stats import levene, ttest_ind
import matplotlib.pyplot as plt
import seaborn as sns

# --- 对 y 取对数变换 ---
# 避免 log(0)，对 Penetration Rate 加 1
data_cleaned['Penetration Rate Log'] = np.log(data_cleaned['Penetration Rate'] + 1)

# 定义 X 和 y_log
X = data_cleaned[['Inside/Outside Footprint']]
X['Intercept'] = 1  # 添加截距项
y_log = data_cleaned['Penetration Rate Log']

# --- 建立回归模型 ---
model_log = sm.OLS(y_log, X).fit()

# 输出模型摘要
print("Regression Model Summary:")
print(model_log.summary())

# --- 假设检验 ---

# 1. 线性关系检查
data_cleaned['Predicted Log'] = model_log.predict(X)
plt.figure(figsize=(8, 6))
sns.scatterplot(x=data_cleaned['Inside/Outside Footprint'], y=y_log, label='Observed')
sns.scatterplot(x=data_cleaned['Inside/Outside Footprint'], y=data_cleaned['Predicted Log'], label='Predicted')
plt.title("Linearity Check: Observed vs. Predicted Values (Log Transformed)")
plt.xlabel("Inside/Outside Footprint")
plt.ylabel("Log(Penetration Rate)")
plt.legend()
plt.show()

# 2. 残差正态性检查
residuals_log = model_log.resid
sm.qqplot(residuals_log, line='s')
plt.title("Q-Q Plot: Normality of Residuals (Log Transformed)")
plt.show()

# 3. 同方差性检查 (Levene's Test)
inside_residuals = residuals_log[data_cleaned['Inside/Outside Footprint'] == 1]
outside_residuals = residuals_log[data_cleaned['Inside/Outside Footprint'] == 0]
levene_stat, levene_p = levene(inside_residuals, outside_residuals)
print(f"Levene's Test: Statistic = {levene_stat:.4f}, p-value = {levene_p:.4f}")
if levene_p > 0.05:
    print("Homoscedasticity assumption is satisfied.")
else:
    print("Homoscedasticity assumption is violated.")

# 4. 多重共线性检查 (VIF)
vif_data = pd.DataFrame()
vif_data['Variable'] = X.columns
vif_data['VIF'] = [variance_inflation_factor(X.values, i) for i in range(X.shape[1])]
print("VIF for Variables:")
print(vif_data)

# --- 单尾 t 检验 ---
inside_group_log = data_cleaned[data_cleaned['Inside/Outside Footprint'] == 1]['Penetration Rate Log']
outside_group_log = data_cleaned[data_cleaned['Inside/Outside Footprint'] == 0]['Penetration Rate Log']

# Welch's t-test
t_stat, p_value_two_tailed = ttest_ind(inside_group_log, outside_group_log, equal_var=False)

# 转换为单尾 p 值（假设 Inside > Outside）
p_value_one_tailed = p_value_two_tailed / 2

print(f"Welch's t-Statistic: {t_stat:.4f}")
print(f"Two-Tailed p-Value: {p_value_two_tailed:.4f}")
print(f"One-Tailed p-Value: {p_value_one_tailed:.4f}")

# 显著性判断
alpha = 0.05
if p_value_one_tailed < alpha and t_stat > 0:
    print("Reject the null hypothesis: Inside footprint significantly increases penetration rate.")
else:
    print("Fail to reject the null hypothesis: No significant positive effect of inside footprint.")







