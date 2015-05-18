/****************************************************************************/
/**************************Create Average Fico Score By State US Pop*********/
/****************************************************************************/
/*Source: http://www.credit-report-101.com/credit-score/average-fico-score.html#Distribution*/
cd "/fof/ra_work/vincent/research/ptplending"

set more off 
clear
input str2 state state_fico
"AL" 610
"AR" 612
"AZ" 629
"CA" 639
"CO" 639
"CT" 645
"DC" .
"DE" 623
"FL" 625
"GA" 616
"IA" 633
"ID" 631
"IL" 630
"IN" 620
"KS" 628
"KY" 616
"LA" 613
"MA" 649
"MD" 623
"ME" 633
"MI" 623
"MN" 645
"MO" 624
"MS" 602
"MT" 637
"NC" 617
"NE" 634
"NH" 646
"NJ" 641
"NM" 622
"NV" 624
"NY" 638
"OH" 622
"OK" 622
"OR" 636
"PA" 628
"RI" 635
"SC" 612
"SD" 639
"TN" 618
"TX" 622
"UT" 636
"VA" 632
"VT" 641
"WA" 639
"WI" 637
"WV" 628
"WY" 628
end

save "./build/input/state_fico", replace
