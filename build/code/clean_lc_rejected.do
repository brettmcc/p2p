/*****************************************************************************/
/*************Cleaning Up Lending Club Reject Data****************************/
/*****************************************************************************/
clear
set more off

cd "/fof/ra_work/vincent/research/ptplending"

use "./build/temp/lendingclub_rejectA", clear

append using "./build/temp/lendingclub_rejectB"

gen zip_code_3 = substr(zipcode, 1, 3)

/*Cleanup Zip code 3 level data. It seems that there are a lot of observations that have either misclassified their state or zip code. Just drop these observations*/
bys state zip_code_3: egen zip_code_3_count = count(accept)
bys zip_code_3: egen zip_code_3_count_max = max(zip_code_3_count)
drop if zip_code_3_count < zip_code_3_count_max
drop zip_code_3_count zip_code_3_count_max

gen application_date = date(applicationdate, "YMD")
replace application_date = date(applicationdate, "MDY") if mi(application_date)
format %td application_date
order application_date, after(applicationdate)
drop applicationdate

gen application_month = month(application_date)
gen application_year = year(application_date)

gen application_date_monthly = ym(application_year, application_month)
format application_date_monthly %tm

/*Rename variables to match lending club accepted data*/
rename risk_score fico
rename debttoincomeratio dti
rename employmentlength emp_length
rename amountrequested loan_amnt
rename application_year issue_year
rename application_date_monthly issue_date
rename zipcode zip_code

/*Cleanup Employed Length Time*/
replace emp_length = "" if emp_length == "n/a"
encode emp_length, generate(emp_length_n)
replace emp_length_n = 0 if emp_length_n == 11
replace emp_length_n = 11 if emp_length_n == 2
replace emp_length_n = emp_length_n - 1 if emp_length_n > 2

label define emp_length_n_l 0 "< 1 Year" 1 "1 Year" 2 "2 Years" 3 "3 Years" 4 "4 Years" 5 "5 Years" 6 "6 Years" 7 "7 Years" 8 "8 Years" 9 "9 Years" 10 "10+ Years"
label values emp_length_n emp_length_n_l

/*Generate some Dummy Variables*/
gen work_less_1 = (emp_length_n == 0)

/*Clean up loantitle variable*/
replace loantitle = trim(loantitle)
replace loantitle = lower(loantitle)
replace loantitle = subinstr(loantitle, "_", "", .)
replace loantitle = subinstr(loantitle, " ", "", .)
replace loantitle = "creditcard" if strpos(loantitle, "credit") > 0 | strpos(loantitle, "card") > 0 | strpos(loantitle, "cc") > 0
replace loantitle = "debtconsolidation" if strpos(loantitle, "consolidation") > 0 | strpos(loantitle, "consolidate") > 0 | strpos(loantitle, "debtc") > 0
replace loantitle = "smallbusiness" if strpos(loantitle, "business") > 0
replace loantitle = "medical" if strpos(loantitle, "medical") > 0
replace loantitle = "car" if strpos(loantitle, "car") > 0 & strpos(loantitle, "card") == 0
replace loantitle = "educational" if strpos(loantitle, "student") > 0 | strpos(loantitle, "college") > 0 | strpos(loantitle, "school") > 0 | strpos(loantitle, "educational") > 0
replace loantitle = "moving" if strpos(loantitle, "moving") > 0
replace loantitle = "wedding" if strpos(loantitle, "wedding") > 0
replace loantitle = "homeimprovement" if strpos(loantitle, "homeimp") > 0

gen purpose = "debt_consolidation" if loantitle == "debtconsolidation"
replace purpose = "credit_card" if loantitle == "creditcard"
replace purpose = "car" if loantitle == "car"
replace purpose = "educational" if loantitle == "educational"
replace purpose = "home_improvement" if loantitle == "homeimprovement"
replace purpose = "house" if loantitle == "house"
replace purpose = "major_purchase" if loantitle == "majorpurchase"
replace purpose = "medical" if loantitle == "medical"
replace purpose = "moving" if loantitle == "moving"
replace purpose = "other" if loantitle == "other"
replace purpose = "renewable_energy" if loantitle == "renewableenergy"
replace purpose = "small_business" if loantitle == "smallbusiness"
replace purpose = "vacation" if loantitle == "vacation"
replace purpose = "wedding" if loantitle == "wedding"

save "./build/temp/lendingclub_reject", replace
