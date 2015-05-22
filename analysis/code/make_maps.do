/*This Do-File will Detail how to go about Creating a Stata Map*/
/*Research Assistants: Vincent La
                       Brett McCully*/
clear
set more off
	
cd "/fof/scratch-m1vxl00/ptplending"

/*Shape File Downloaded from:*/
shp2dta using ./analysis/input/s_16de14.shp, database(./analysis/temp/usdb) coordinates(./analysis/temp/uscoord) genid(id) replace

use "./analysis/temp/usdb", clear
describe

rename *, lower

merge 1:1 state using "./build/output/lendingclub_map", nogenerate

merge 1:1 state using "./build/output/mintel_state", nogenerate

drop if state == "AK" | state == "HI" | state == "GU" | state == "PR" | state == "AS" | state == "FM" | state == "MH" | state == "MP" | state == "VI"

local uscoord ./analysis/temp/uscoord

spmap loan_app using `uscoord', id(id) fcolor(Blues) title("Loan Applications by State (Lending Club)")
graphexportpdf ./analysis/output/maps/lcmap_loanapp, dropeps

spmap fico using `uscoord', id(id) fcolor(Blues) title("Average FICO Score by State (Lending Club)")
graphexportpdf ./analysis/output/maps/lcmap, dropeps

spmap state_fico using `uscoord', id(id) fcolor(Blues) title("Average FICO Score by State (US Pop)")
graphexportpdf ./analysis/output/maps/lcmap_uspop, dropeps

spmap fico_diff using `uscoord', id(id) fcolor(Blues) title("Difference in FICO Score by State (Lending Club - US Pop)")
graphexportpdf ./analysis/output/maps/lcmap_diff, dropeps

spmap int_rate using `uscoord', id(id) fcolor(Blues) title("Lending Club Interest Rate")
graphexportpdf ./analysis/output/maps/lcmap_intrate, dropeps

spmap mailvolume_state_avg using `uscoord', id(id) fcolor(Blues) title("Mintel Credit Card Average Mail Volume")
graphexportpdf ./analysis/output/maps/mintelstate, dropeps
