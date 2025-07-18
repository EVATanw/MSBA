**********************************
**** Augmented version of model****
********** Feb 4, 2025 ************
************ Team 6 ***************
***********************************

** programming environment setup

clear
query memory           // check the memory   

// 1. import data
*use output.dta, clear
use final_dataset.dta, clear


// 2. Data preprocessing
* Log-transform average_mp (exclude values <= 0)
gen log_avg_mp = log(average_mp) if average_mp > 0
* Log-transform mp1 mp2 mp3 mp4 mp5
gen log_mp1 = log(mp1) if mp1 > 0
gen log_mp2 = log(mp2) if mp2 > 0
gen log_mp3 = log(mp3) if mp3 > 0
gen log_mp4 = log(mp4) if mp4 > 0
gen log_mp5 = log(mp5) if mp5 > 0
* Convert state from string to numeric variable
encode state, gen(state_id)
summarize                  // Summary statistics of all variables


// 3. Model Test
reghdfe LBW_ratio log_mp1 log_mp2 log_mp3 log_mp4 log_mp5 late_pregnancy_temp late_pregnancy_preci late_pregnancy_airp, absorb(birth_month state_id#birth_year) vce(robust) resid(resids)

// Test model assumptions:
* Assumption 1: Linearity assumption
predict fitted, xb
gen fitted_sq = fitted^2
reg log_LBW fitted fitted_sq, robust
* 1.1 Plot residuals vs. fitted values
twoway (scatter resids fitted, mcolor(blue) msize(small)) /// Blue dots
       (function y = 0, range(fitted) lcolor(red) lwidth(medium)), /// Red reference line
       title("Residuals vs. Fitted Values") /// Title of the plot
       xtitle("Fitted Values") /// X-axis label
       ytitle("Residuals") /// Y-axis label
       legend(label(1 "Residuals") label(2 "Zero Reference")) /// Legend
       scheme(s1mono) // Use a simple theme style
* 1.2 Plot observed vs. predicted values
// Plot observed vs. predicted values
twoway (scatter LBW_ratio fitted, mcolor(blue) msize(small)) ///
       (function y = x, range(fitted) lcolor(red) lwidth(medium)), ///
       title("Overall Linearity Check: Observed vs. Predicted Values") ///
       xtitle("Predicted Values") ///
       ytitle("Observed Values") ///
       legend(order(1 "Observed" 2 "45° Reference")) ///
       scheme(s1mono)
// Check linearity assumption for mp1
twoway (scatter LBW_ratio log_mp1, mcolor(blue) msize(small)) ///
       (scatter fitted mp1, mcolor(red) msize(small)), ///
       title("Linearity Check for mp1") ///
       xtitle("log_mp1") ///
       ytitle("LBW_ratio") ///
       legend(order(1 "Observed" 2 "Predicted")) ///
       scheme(s1mono)
	   
* Assumption 2: Normality of error terms
* Plot Q-Q graph
qnorm resids, title("Residual Normality Check") name(qqplot, replace)
* Assumption 3: Homoscedasticity
* 3.1 Modified Wald Test for Groupwise Heteroskedasticity
* Sort by birth_year within each state_id and generate an order variable t
bysort state_id (birth_year): gen t = _n
* Set panel data structure, with panel variable as state_id and time variable as t
xtset state_id t
* Re-run fixed effects model (Note: use xtreg, fe version and may need to adjust model specification)
xtreg LBW_ratio log_mp1 log_mp2 log_mp3 log_mp4 log_mp5 late_pregnancy_temp late_pregnancy_preci late_pregnancy_airp i.birth_month, fe vce(robust)
* Perform modified Wald test (test for heteroskedasticity across panels)
xttest3
* 3.2 Use Levene's Test to check if residual variances are equal across different groups
// Create a grouping variable based on fitted values (e.g., divide into 4 groups)
xtile group_var = fitted, nq(4)
levene resids, by(group_var)
// Group by birth_month
levene resids, by(birth_month)
// Or group by state_id
levene resids, by(state_id)
// Group by birth_year
levene resids, by(birth_year)
* Assumption 4: Multicollinearity
* Calculate uncentered VIF
vif, uncentered
* Correlation matrix
correlate log_mp1 log_mp2 log_mp3 log_mp4 log_mp5 late_pregnancy_temp late_pregnancy_preci late_pregnancy_airp

// 4. Export model results
// 4.1 Outreg2
* Run reghdfe regression
reghdfe LBW_ratio log_mp1 log_mp2 log_mp3 log_mp4 log_mp5 late_pregnancy_temp late_pregnancy_preci late_pregnancy_airp, absorb(birth_month state_id#birth_year) vce(robust)
* Export regression results to Excel (including coefficients, standard errors, t-statistics, p-values)
outreg2 using results2.xlsx, replace excel stats(coef se tstat pval)
* Add notes explaining fixed effects (Stata cannot automatically export absorb() variables)
outreg2 using results2.xlsx, append excel addtext(Fixed Effects, Birth Month & State × Year)

