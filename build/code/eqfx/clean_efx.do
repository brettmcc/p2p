/*This program cleans the raw Equifax data, renaming, recoding, and labeling certain variables.*/
/*Brett McCully, Vincent La 2015*/

  clear all
set more off

/*SQL query in RADAR to get the below dataset (5/22/2015):
SELECT cid,birthyear,cid,qtr,riskscore,state,zipcode,cust_attr301,cust_attr302,cust_attr303,cust_attr304,cust_attr305,cust_attr306,cust_attr307,cust_attr308,cust_attr309,cust_attr310,cust_attr311,cust_attr312,cust_attr313,cust_attr314,cust_attr315,cust_attr316,cust_attr317,cust_attr318,cust_attr319,cust_attr320,crtr_attr1,crtr_attr4,crtr_attr5,crtr_attr6,crtr_attr7,crtr_attr8,crtr_attr155,crtr_attr158,crtr_attr159,crtr_attr160,crtr_attr161,crtr_attr162,crtr_attr166,crtr_attr169,crtr_attr170,crtr_attr171,crtr_attr172,crtr_attr173,crtr_attr177,crtr_attr180,crtr_attr181,crtr_attr182,crtr_attr183,crtr_attr184,cma_attr3000,cma_attr3001,cma_attr3002,cma_attr3111,cma_attr3113,cma_attr3117,cma_attr3120,cma_attr3122,cma_attr3124,cma_attr3127,cma_attr3133,cma_attr3134,cma_attr3135,cma_attr3136,cma_attr3993,cma_attr3994,cma_attr3995,cma_attr3843,cma_attr3844,cma_attr3845,cma_attr3854 FROM concredit.view_join_static_dynamic_eqf WHERE (rand_no_primary in (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99) AND primary_flag_d='1' AND dup_cid_flag_d='1' AND qtr >= '1999-02-01' AND qtr <= '2015-03-01')
*/
use ../../input/equifax.dta,clear

/**RENAME**/
*joint variables
rename cust_attr301 card_hicred_jmcs
rename cust_attr302 card_bal_jmcs
drop cust_attr303 //dropping past due joint amounts since we dont need it
rename cust_attr304 card_pymt_amt_jmcs
rename cust_attr305 cf_hicred_jmcs
rename cust_attr306 cf_bal_jmcs
drop cust_attr307
rename cust_attr308 cf_pymt_amt_jmcs
rename cust_attr309 mort_hicred_jmcs
rename cust_attr310 mort_bal_jmcs
drop cust_attr311 
rename cust_attr312 mort_pymt_amt_jmcs
rename cust_attr313 hmeqinstal_hicred_jmcs
rename cust_attr314 hmeqinstal_bal_jmcs
drop cust_attr315
rename cust_attr316 hmeqinstal_pymt_amt_jmcs
rename cust_attr317 hmeqrevolv_hicred_jmcs
rename cust_attr318 hmeqrevolv_bal_jmcs
drop cust_attr319
rename cust_attr320 hmeqrevolv_pymt_amt_jmcs

*total number of trades
rename crtr_attr1 num_trades_all
rename crtr_attr4 num_trades_card
rename crtr_attr5 num_trades_cf
rename crtr_attr6 num_trades_mort
rename crtr_attr7 num_trades_hmeqinstal
rename crtr_attr8 num_trades_hmeqrevolv

*payment amounts
rename crtr_attr155 pymt_amt_all
rename crtr_attr158 pymt_amt_card
rename crtr_attr159 pymt_amt_cf
rename crtr_attr160 pymt_amt_mort
rename crtr_attr161 pymt_amt_hmeqinstal
rename crtr_attr162 pymt_amt_hmeqrevolv

*total balances
rename crtr_attr167 bal_all
rename crtr_attr169 bal_card
rename crtr_attr170 bal_cf
rename crtr_attr171 bal_mort
rename crtr_attr172 bal_hmeqinstal
rename crtr_attr173 bal_hmeqrevolv

*total high credit
rename crtr_attr177 hicred_tot
rename crtr_attr180 hicred_card
rename crtr_attr181 hicred_cf
rename crtr_attr182 hicred_mort
rename crtr_attr183 hicred_hmeqinstal
rename crtr_attr184 hicred_hmeqrevolv

*Credit Modeling Attributes
rename cma_attr3000 num_inquiries_3mo
rename cma_attr3001 num_inquiries_12mo
rename cma_attr3002 num_inquiries_24mo
rename cma_attr3111 age_oldest_acct
rename cma_attr3113 age_oldest_card
rename cma_attr3117 age_oldest_mort
rename cma_attr3120 age_oldest_revolv
rename cma_attr3122 age_newest_acct
rename cma_attr3124 age_newest_card
rename cma_attr3127 age_newest_instal
rename cma_attr3133 num_acct_open_6mo
rename cma_attr3134 num_revolv_open_6mo
rename cma_attr3135 num_acct_open_12mo
rename cma_attr3136 num_instal_open_12mo
rename cma_attr3843 pct_open_6mo_of_numaccts
rename cma_attr3844 pct_open_6mo_of_12mo
rename cma_attr3845 pct_revolv_6mo_of_12mo
rename cma_attr3854 card_util
rename cma_attr3993 pct_inq_3mo_of_12mo
rename cma_attr3994 pct_inq_3mo_of_24mo
rename cma_attr3995 pct_inq_12mo_of_24mo


/*Recode, relabel based on CMA codebook
https://j1dp1.kc.frbres.org/FILES/FRBNYCCP/equ_att_5_EFS-884-ADV_CMAPlusUserGuide-Dec_2008.pdf*/
  replace num_inquiries_3mo=. if num_inquiries_3mo>92
replace num_inquiries_12mo=. if num_inquiries_12mo>92
replace num_inquiries_24mo=. if num_inquiries_24mo>92
replace age_oldest_acct=. if age_oldest_acct>9992
label variable age_oldest_acct "Number of months since oldest account on file established"
replace age_oldest_card=. if age_oldest_card>9992
label variable age_oldest_card "Number of months since oldest bankcard account on file established"
replace age_oldest_mort=. if age_oldest_mort>9992
label variable age_oldest_mort "Number of months since oldest mortgage account on file established"
replace age_oldest_revolv=. if age_oldest_revolv>9992
label variable age_oldest_revolv "Number of months since oldest revolving account on file established"
replace age_newest_acct=. if age_newest_acct>9992
label variable age_newest_acct "Number of months since newest account on file established"
replace age_newest_card=. if age_newest_card>9992
label variable age_newest_card "Number of months since newest bankcard account on file established"
replace age_newest_instal=. if age_newest_instal>9992
label variable age_newest_instal "Number of months since newest installment account on file established"
replace num_acct_open_6mo=. if num_acct_open_6mo>92
replace num_revolv_open_6mo=. if num_revolv_open_6mo>92
replace num_acct_open_12mo=. if num_acct_open_12mo>92
replace num_instal_open_12mo=. if num_instal_open_12mo>92
replace pct_open_6mo_of_numaccts=. if pct_open_6mo_of_numaccts>1
replace pct_open_6mo_of_12mo=. if pct_open_6mo_of_12mo>1
replace pct_revolv_6mo_of_12mo=. if pct_revolv_6mo_of_12mo>1
replace card_util=. if card_util>9.9992
/**cma_attr3993-3995 not in codebook; check to see if their values are reasonable or if there is a cluster of high ones in the 99X range.*/
  
/*Deduct joint account values from total*/
foreach cred of "card cf mort hmeqinstal hmeqrevolv" {
  foreach attr of "hicred bal" {
    replace `attr'_`cred' = `attr'_`cred' - `cred'_`attr'_jmcs
  }
}  
drop *_jmcs

*create 3-digit zip code variable
gen zip3dig = int(zipcode/100)
drop zipcode

*check to see that we didnt forget to rename anything
describe cma_attr* cust_attr* crtr_attr*

save ../../output/equifax.dta,replace
