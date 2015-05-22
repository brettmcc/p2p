#This file is for running all code in directory for PTP Project
#Authors: Brett McCully and Vincent La

#Clear the ./temp and ./output folders to ensure all output is produced by current code
rm /fof/scratch-m1vxl00/ptplending/build/temp/*
rm /fof/scratch-m1vxl00/ptplending/build/output/*

#Input Fico Score By State
stata-mp -b do input_fico_score_by_state.do

#Convert Lending Club CSV to Stata Files
stata-mp -b do build_lc_data_from_csv.do

#Clean Lending Club Rejected Data
stata-mp -b clean_lc_rejected.do

#Clean Mintel Data
stata-mp -b clean_mintel_data.do

#Create Lending Club With Mintel Final Output
stata-mp -b create_lc_final_output.do


