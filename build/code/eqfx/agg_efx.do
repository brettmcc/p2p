/*Aggregate from individual level to zip/state level*/

  set more off

program agg
args geog
 use ../../output/equifax.dta,clear

 *summation collapsing for number of trades, balances, and credit limits.
 sort qtr `geog'
 foreach v of varlist num_trades_* bal_* hicred_* {
   quietly by qtr `geog': gen double sum_`v' = sum(`v')
   drop `v'
 }
 *average collapsing for payments, number of inquiries, age of oldest and newest accounts, number of accounts recently opened, percent recently opened, and credit card utilization
 foreach v of varlist pymt_* num_inquiries_* age_* num_acct_* num_r* num_inst* pct_* card_util {
   quietly by qtr `geog': egen mean_`v' = mean(`v')
 }
 save ../../output/equifax_`geog'.dta,replace
end

agg state
agg zip3dig
