/******************************************************************************/
/*******************Exploring Mintel Data**************************************/
/******************************************************************************/
cd "/fof/scratch-m1vxl00/ptplending"

use "/a/nas1/space/fof.scratch/vincent/mintel/data/current.dta", clear

/*Get statecode from FIPS if missing*/
merge m:1 state using "./build/input/fipscode.dta", keepusing(statecode) update nogenerate

/*Fill in missing state fips code*/
bys statecode: egen state_fill = max(state)
replace state = state_fill if mi(state)
drop state_fill

gen zip_code_3 = substr(zip, 1, 3)

/*Cleanup Zip code 3 level data. It seems that there are some observations that have either misclassified their state or zip code. Just drop these observations*/
bys state zip_code_3: egen zip_code_3_count = count(id)
bys zip_code_3: egen zip_code_3_count_max = max(zip_code_3_count)
drop if zip_code_3_count < zip_code_3_count_max
drop zip_code_3_count zip_code_3_count_max

keep if Category == "Affinity Cards" | Category == "Co-Branded" | Category == "Credit Cards" | Category == "Lifestyle Cards"

/*Clean Up Report Month*/
split reportmonth, parse(" ") generate(date)
label define monthorder 1 January 2 February 3 March 4 April 5 May 6 June 7 July 8 August 9 September 10 October 11 November 12 December
encode date1, generate(month) label(monthorder) noextend
destring date2, replace
gen reportmonth2 = ym(date2, month)
drop reportmonth
rename reportmonth2 reportmonth
format reportmonth %tm

gen reportquarter = qofd(dofm(reportmonth))
format reportquarter %tq

keep panel_id id item_id detail_id product state statecode city zip zip_code_3 county msa weight reportmonth reportquarter Category CensusTract hhincome rent_own mailvolume
save "/a/nas1/space/fof.scratch/vincent/mintel/data/current_short.dta", replace

/*Collapse Mailvolume (sum and average) by 3-Digit Zip Codes*/
preserve
gen mailvolume_sum = mailvolume 

collapse (sum) mailvolume_sum (mean) mailvolume, by(zip_code_3)
drop if mi(mailvolume) | mi(zip_code_3)

rename mailvolume_sum mailvolume_zip3_sum
rename mailvolume mailvolume_zip3_avg
save "./build/output/mintel_zip3", replace
restore

/*Collapse Mailvolume (sum and average) by State*/
gen mailvolume_sum = mailvolume

collapse (sum) mailvolume_sum (mean) mailvolume, by(statecode)
drop if mi(statecode)

rename statecode state
rename mailvolume_sum mailvolume_state_sum
rename mailvolume mailvolume_state_avg

save "./build/output/mintel_state", replace
