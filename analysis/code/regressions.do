/******************************************************************************/
/*This file is to conduct Regression Analysis for Lending Club Research Project*/
/*Research Assistants
         Brett Mccully
	 Vincent La
*/

clear
set more off

cd "/fof/ra_work/vincent/research/ptplending"

use "./build/output/lendingclub_clean", clear

/*Create Correlation Matrix*/
cor loan_amnt annual_inc fico issue_year open_acc emp_length_n

/*Run some basic regressions*/
reg loan_app mailvolume_state_sum
outreg2 using "./analysis/output/tables/basicreg.tex", tex(pretty frag) replace
reg loan_app mailvolume_state_avg
outreg2 using "./analysis/output/tables/basicreg.tex", tex(pretty frag)
reg loan_app_zip3 mailvolume_zip3_sum
outreg2 using "./analysis/output/tables/basicreg.tex", tex(pretty frag)
reg loan_app_zip3 mailvolume_zip3_avg
outreg2 using "./analysis/output/tables/basicreg.tex", tex(pretty frag)

reg loan_amnt open_acc annual_inc emp_length_n fico south midwest west

/*Replicate Table 8 of Mach et. al (2014)*/
set more off
global dummies credit_card debt_consolidation car educational major_purchase home_improvement wedding house medical renewable_energy vacation small_business moving
logit accept $dummies loan_amnt fico work_less_1 i.issue_year
outreg2 using "./analysis/output/tables/myreg.tex", keep($dummies loan_amnt fico work_less_1) ctitle("Logit: Accept") tex(pretty frag) replace

/*Replicate Table 9 of Mach et. al (2014)*/
reg int_rate responsible loan_amnt fico annual_inc loan_length_60 work_less_1 homeowner i.issue_year south midwest west
reg int_rate credit_card debt_consolidation car educational major_purchase home_improvement wedding house medical renewable_energy vacation small_business moving loan_amnt fico annual_inc loan_length_60 work_less_1 homeowner i.issue_year south midwest west
outreg2 using "./analysis/output/tables/myreg.tex", keep($dummies loan_amnt fico work_less_1) ctitle("OLS: int_rate") tex(pretty frag)

/*Replicate Table 10 of Mach et. al (2014)*/
logit poor_performance responsible loan_amnt fico annual_inc loan_length_60 work_less_1 homeowner i.issue_year south midwest west
logit poor_performance credit_card debt_consolidation car educational major_purchase home_improvement wedding house medical renewable_energy vacation small_business moving loan_amnt fico annual_inc loan_length_60 work_less_1 homeowner i.issue_year south midwest west
outreg2 using "./analysis/output/tables/myreg.tex", keep($dummies loan_amnt fico work_less_1) ctitle("Logit: poor_preformance") tex(pretty frag)
