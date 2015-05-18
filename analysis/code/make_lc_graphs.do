/*****************************************************************************/
/*************************Make Lending Club Maps******************************/
/*****************************************************************************/
clear
set more off

cd "/fof/ra_work/vincent/research/ptplending"

use "./build/output/lendingclub_clean", clear

keep loan_amnt fico issue_date accept loan_app mailvolume_state_avg state

/*Graph over Time*/
preserve
collapse loan_amnt fico, by(issue_date accept)

graph twoway scatter loan_amnt issue_date, xline(575 593) /*December 2007 to June 2009*/
graph twoway scatter fico issue_date, xline(575 593) /*December 2007 to June 2009*/

graph twoway (scatter fico issue_date if accept == 1) (scatter fico issue_date if accept == 0), xline(575 593) legend(order(1 "Loan Accepted" 2 "Loan Declined")) title("LC Fico Over Time")
graphexportpdf ./analysis/output/graphs/ficoovertime, dropeps
restore

/*Graph Loan Applications vs. mailvolume (data collapsed at state level)*/
preserve
collapse loan_app mailvolume_state_avg, by(state)
drop if mi(state)
graph twoway (scatter loan_app mailvolume_state_avg [w=loan_app], msymbol(circle_hollow) mcolor(navy)) (scatter loan_app mailvolume_state_avg, mlabel(state) mcolor(navy)) (lfit loan_app mailvolume_state_avg [w=loan_app]), ///
              title("Lending Club Loan Applications vs. Credit Card Mailings") ytitle("Lending Club Loan Applications") xtitle("Credit Card Mailings") legend(order(2 "Loan Applications by State" 3 "Fitted Values"))
graphexportpdf ./analysis/output/graphs/loanappovermail, dropeps
restore
