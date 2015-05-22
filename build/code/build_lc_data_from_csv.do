/******************************************************************************/
/*********************Create Lending Club Data*********************************/
/******************************************************************************/
clear
set more off

cd "/fof/scratch-m1vxl00/ptplending"

/*Load CSVs and convert to Stata*/
foreach l in a b c{
	import delimited `"./build/input/LoanStats3`l'_securev1.csv"', delimiter(comma) varnames(1) clear
	gen accept = 1
	save `"./build/temp/lendingclub`l'"', replace
}

foreach l in A B{
	import delimited `"./build/input/RejectStats`l'.csv"', delimiter(comma) varnames(1) clear
	gen accept = 0
	save `"./build/temp/lendingclub_reject`l'"', replace
}

/*Append all datasets together*/
use "./build/temp/lendingcluba", clear
append using "./build/temp/lendingclubb"
append using "./build/temp/lendingclubc"
save "./build/temp/lendingclub", replace
