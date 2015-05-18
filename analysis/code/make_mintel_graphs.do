/******************************************************************************/
/**********************Make Graphs with Mintel Data****************************/
/******************************************************************************/

cd "/fof/ra_work/vincent/research/ptplending"

use "/a/nas1/space/fof.scratch/vincent/mintel/data/current_short.dta", clear

/*Graph Mail Volume Over Time*/

collapse (sum) mailvolume, by(reportquarter)
replace mailvolume = mailvolume/1000000

graph twoway scatter mailvolume reportquarter, title("Credit Card Offer Mail Volume") xtitle("Quarter") ytitle("Mail Volume (Millions)")

graphexportpdf ./analysis/output/graphs/mailvolumeovertime, dropeps
