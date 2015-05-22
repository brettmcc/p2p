/******************************************************************************/
/*This Do-File Contains Scripts for our project on Peer to Peer Lending. The
  data sets we are currently using are publicly available data from Lending Club
  along with proprietary Mintel Compremedia data on credit offers        */
/*Authors:
         Brett Mccully
	 Vincent La
*/

/******************************************************************************/
/********************Exploratory Analysis of Lending Club Data*****************/
/******************************************************************************/
clear
set more off

cd "/fof/scratch-m1vxl00/ptplending"

/*Do some cleaning of the lendingclub data*/
use "./build/temp/lendingclub", clear
rename addr_state state

/*Clean Loan Status Variable*/
replace loan_status = "Current" if loan_status == "Does not meet the credit policy.  Status:Current"
replace loan_status = "Charged Off" if loan_status == "Does not meet the credit policy.  Status:Charged Off"
replace loan_status = "Fully Paid" if loan_status == "Does not meet the credit policy.  Status:Fully Paid"
replace loan_status = "Late (31-120 days)" if loan_status == "Does not meet the credit policy.  Status:Late (31-120 days)"

/*Fix the date variable*/
gen issue_date = monthly(issue_d, "M20Y")
format issue_date %tm

gen issue_year = year(dofm(issue_date))
gen issue_month = month(dofm(issue_date))
drop issue_d

/*Cleanup Employed Length Time*/
replace emp_length = "" if emp_length == "n/a"
encode emp_length, generate(emp_length_n)
replace emp_length_n = 0 if emp_length_n == 11
replace emp_length_n = 11 if emp_length_n == 2
replace emp_length_n = emp_length_n - 1 if emp_length_n > 2

label define emp_length_n_l 0 "< 1 Year" 1 "1 Year" 2 "2 Years" 3 "3 Years" 4 "4 Years" 5 "5 Years" 6 "6 Years" 7 "7 Years" 8 "8 Years" 9 "9 Years" 10 "10+ Years"
label values emp_length_n emp_length_n_l

/*Generate 3 digit zip code*/
gen zip_code_3 = substr(zip_code, 1, 3)

/*Cleanup Zip code 3 level data. It seems that there are some observations that have either misclassified their state or zip code. Just drop these observations*/
bys state zip_code_3: egen zip_code_3_count = count(accept)
bys zip_code_3: egen zip_code_3_count_max = max(zip_code_3_count)
drop if zip_code_3_count < zip_code_3_count_max
drop zip_code_3_count zip_code_3_count_max

egen fico = rowmean(fico_range_low fico_range_high)
encode sub_grade, generate(sub_grade_n)

/*Merge in Average State Fico Score*/
merge m:1 state using "./build/input/state_fico", nogenerate

/*Cleanup Interest Rate Variable*/
destring int_rate, ignore(%) replace force

/*Drop if observations in state less than 30. Also add in Region Indicators*/
encode state, generate(state_n)
bys state: egen state_count = count(state_n)
drop if state_count < 30
drop state_count

gen region = "Northeast" if state == "PA" | state == "NJ" | state == "NY" | state == "CT" | state == "RI" | state == "MA" | state == "VT" | state == "NH" | state == "ME"
replace region = "South" if state == "DE" | state == "MD" | state == "DC" | state == "WV" | state == "VA" | state == "KY" | state == "NC" | state == "TN" | state == "SC" | ///
                            state == "GA" | state == "AL" | state == "FL" | state == "MS" | state == "LA" | state == "TX" | state == "OK" | state == "AR"
replace region = "Midwest" if state == "ND" | state == "MN" | state == "WI" | state == "MI" | state == "OH" | state == "IN" | state == "IL" | state == "MO" | state == "KS" | ///
                              state == "NE" | state == "SD" | state == "IA"
replace region = "West" if state == "WA" | state == "OR" | state == "CA" | state == "NV" | state == "ID" | state == "AZ" | state == "MT" | state == "WY" | state == "CO" | state == "NM" | state == "UT" | state == "AK" | state == "HI"
encode region, generate(region_n)
gen northeast = region == "Northeast"
gen south = region == "South"
gen midwest = region == "Midwest"
gen west = region == "West"

/*Append Reject Data. Also Merge in Average Mail Volume by State from Mintel Data. BE CAREFUL with this*/
append using "./build/temp/lendingclub_reject", keep(loan_amnt state issue_year issue_date accept fico emp_length_n purpose zip_code_3 zip_code)
merge m:1 state using "./build/output/mintel_state", nogenerate
merge m:1 zip_code_3 using "./build/output/mintel_zip3", nogenerate

/*Categorize Loans as "Responsible" vs. "Irresponsible". This definition is arbitrary for now, let's see what happens*/
gen responsible = (purpose == "credit_card" | purpose == "debt_consolidation" | purpose == "medical" | purpose == "educational" | purpose == "small_business")
levelsof purpose
foreach l in `r(levels)'{
	gen `l' = (purpose == `"`l'"')
}

bys state: egen loan_app = count(accept)
bys zip_code_3: egen loan_app_zip3 = count(accept)

/*Drop if 3 Digit Zip code is less than 10. Also drop zip codes that we are invalid or not in use: http://en.wikipedia.org/wiki/List_of_ZIP_code_prefixes*/
bys zip_code_3: egen zip_code_3_count = count(accept)
drop if zip_code_3_count <= 10
drop zip_code_3_count

destring zip_code_3, generate(zip_code_3_num)
gen drop_d = inlist(zip_code_3_num, 0, 1, 2, 3, 4, 6, 7, 8, 9, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 213, 269, 343, 345, 348, 353, 419, 428, 429, 517, 518, 519, 529, 533, 536, 552, 568, 578, 579, 589, 621, 632, 642, 643, 659, 663, 682, 694, 695, 696, 697, 698, 699, 702, 709, 715, 732, 742, 771, 817, 818, 819, 839, 848, 849, 854, 858, 861, 862, 866, 867, 868, 869, 876, 886, 887, 888, 892, 896, 899, 909, 929, 962, 963, 964, 965, 966, 987)
drop if drop_d
drop if mi(zip_code_3)
drop drop_d

/*Generate some Dummy Variables*/
gen loan_length_60 = (term == " 60 months")
gen work_less_1 = (emp_length_n == 0)
gen homeowner = (home_ownership == "MORTGAGE" | home_ownership == "OWN")
gen poor_performance = (loan_status == "Charged Off" | loan_status == "Default" | loan_status == "Late (31-120 days)")

save "./build/output/lendingclub_clean", replace

/******************************************************************************/
/**************************Collapse to make Maps*******************************/
/******************************************************************************/
use "./build/output/lendingclub_clean", clear

/*Be Careful Here with Importing to Maps. Previously was only Accepted Loans. Now, it's all loans*/
keep loan_app loan_amnt funded_amnt sub_grade_n /*zip_code_3*/ annual_inc fico state state_fico int_rate
collapse loan_app fico state_fico int_rate, by(state /*zip_code_3*/)

gen fico_diff = fico - state_fico

save "./build/output/lendingclub_map", replace


