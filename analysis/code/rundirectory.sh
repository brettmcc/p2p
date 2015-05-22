#This file is for running all code in directory for PTP Project
#Authors: Brett McCully and Vincent La

#Clear the ./temp and ./output folders to ensure all output is produced by current code
rm /fof/scratch-m1vxl00/ptplending/analysis/temp/*
rm /fof/scratch-m1vxl00/ptplending/analysis/output/graphs/*
rm /fof/scratch-m1vxl00/ptplending/analysis/output/maps/*
rm /fof/scratch-m1vxl00/ptplending/analysis/output/tables/*

#Make Lending Club Graphs
stata-mp -b do make_lc_graphs.do

#Make Geographic Map (48 US States)
stata-mp -b do make_maps.do

#Make Mintel Data Graphs
stata-mp -b make_mintel_graphs.do

#Run Regressions
stata-mp -b regressions.do


