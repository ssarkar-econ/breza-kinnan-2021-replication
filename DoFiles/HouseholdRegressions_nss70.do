set more off
*clear all

/***********************
NSS ROUND 70 DATA 
***********************/

********************************************************************************
* First stage: NSS round 70 data (Table 3)***********************************
********************************************************************************
use "$dataworkrep/NSS70_for_regressions.dta", clear
// XXX SS: add gen exposuredum = exp_ratio_dumXpost
gen exposuredum = exp_ratio_dumXpost


foreach i in dum std {

reg loan_amt630_fiSHG_nocoll_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum loan_amt630_fiSHG_nocoll_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg1_`i'


reg loan_amt630_bank_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum loan_amt630_bank_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg2_`i'

#d ;

reg loan_amount_out_june30_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist);
sum loan_amount_out_june30_w99 if exposuredum==0 & GLP_2010_rural>0;
eret2 scalar mn=r(mean);
eret2 scalar sd=r(sd);
est sto creg3_`i';

#d cr

***For appendix table
reg loan_amt630_MF_NBFC_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum loan_amt630_MF_NBFC_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto crega1_`i'
}

*Log (of winsorized)
foreach i in dum std {

reg lloan_amt630_fiSHG_nocoll_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum lloan_amt630_fiSHG_nocoll_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg4_`i'


reg lloan_amt630_bank_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum lloan_amt630_bank_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg5_`i'

#d ;

reg lloan_amount_out_june30_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist);
sum lloan_amount_out_june30_w99 if exposuredum==0 & GLP_2010_rural>0;
eret2 scalar mn=r(mean);
eret2 scalar sd=r(sd);
est sto creg6_`i';

#d cr

*For appendix tables
reg lloan_amt630_MF_NBFC_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum lloan_amt630_MF_NBFC_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto crega2_`i'

}

***Add in MF balance sheet first stage

use "$dataworkrep/HH_data_collapsed.dta", clear
gen exposuredum = exp_ratio_dumXpost

cap label var exposuredum "Any exposed lender $\times$ Post 2010"
cap label var exposurestd "Exposure Ratio $\times$ Post 2010"


foreach i in dum std {
foreach y in GLP_panel_FS_phh {

areg `y' exposure`i' $controls_D1, absorb(state_dist) vce(cluster state_dist)
sum `y' if exposuredum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'_`i'
}
}

*** Main table (table 3)

esttab GLP_panel_FS_phh_dum creg1_dum creg2_dum creg3_dum creg4_dum creg5_dum creg6_dum using "$tables/firstst_mf_nss70.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) nonumbers fragment booktabs keep(exposuredum) nonotes replace
esttab GLP_panel_FS_phh_std creg1_std creg2_std creg3_std creg4_std creg5_std creg6_std using "$tables/firstst_mf_nss70.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) label mlabel(none) fragment obslast booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") append


*** Narrow MFI measure for the appendix (winsorized)

esttab crega1_dum crega2_dum using "$appendix/firstst_nss70narrow.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) nonumbers fragment booktabs keep(exposuredum) nonotes replace
esttab crega1_std crega2_std using "$appendix/firstst_nss70narrow.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) label mlabel(none) fragment obslast booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") append


est clear

use "$dataworkrep/NSS70_for_regressions.dta", clear
gen exposuredum = exp_ratio_dumXpost


********************************************************************************
*2) SUMMARY STATISTICS (Table 2, 3rd Panel)
* Note: Here, as in the other NSS 70 stuff, we restrict to the earlier part of the sample: if survey_month<7
********************************************************************************

gen any_MF_narrow=.
replace any_MF_narrow=0 if loan_amt630_MF_NBFC_w99==0
replace any_MF_narrow=1 if loan_amt630_MF_NBFC_w99>0 & loan_amt630_MF_NBFC_w99<.

gen any_MF_broad=.
replace any_MF_broad=0 if loan_amt630_fiSHG_nocoll_w99==0
replace any_MF_broad=1 if loan_amt630_fiSHG_nocoll_w99>0 & loan_amt630_fiSHG_nocoll_w99<.

gen any_loan=.
replace any_loan=0 if loan_amount_out_june30_w99==0
replace any_loan=1 if loan_amount_out_june30_w99>0 & loan_amount_out_june30_w99<.

*** Winsorized version
global y_sum "loan_amt630_fiSHG_nocoll_w99 loan_amt630_bank_w99 loan_amount_out_june30_w99"


estpost sum $y_sum if exposuredum==0 & GLP_2010_rural>0 & survey_month<7 [aweight=weight]
esttab . using "$tables/sum_3.tex", cells("count(fmt(0)) mean(fmt(0)) sd(fmt(0))") ///
nomtitles label nonumbers nolines noobs fragment booktabs replace ///
posthead("%<*t1>") postfoot("%</t1>")


est clear

********************************************************************************
*3) INVESTMENT (expenditures) and ASSET STOCKS
* 
********************************************************************************

su expenditure, detail
cap gen expenditure_w99 = expenditure
replace expenditure_w99=`r(p99)' if expenditure > `r(p99)' & expenditure<.

su expend_hh, detail
cap gen expend_hh_w99 = expend_hh
replace expend_hh_w99=`r(p99)' if expend_hh > `r(p99)' & expend_hh<.

su expend_agbiz, detail
cap gen expend_agbiz_w99 = expend_agbiz
replace expend_agbiz_w99=`r(p99)' if expend_agbiz > `r(p99)' & expend_agbiz<.

su expend_nagbiz, detail
cap gen expend_nagbiz_w99 = expend_nagbiz
replace expend_nagbiz_w99=`r(p99)' if expend_nagbiz > `r(p99)' & expend_nagbiz<.


foreach i in dum std {

reg expenditure_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum expenditure_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto ireg1_`i'

reg expend_hh_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum expend_hh_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto ireg2_`i'

reg expend_agbiz_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum expend_agbiz_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto ireg3_`i'

reg expend_nagbiz_w99 exposure`i' $controls_70 [pweight = weight], cl(state_dist)
sum expend_nagbiz_w99 if exposuredum==0 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto ireg4_`i'

}


esttab ireg1_dum ireg2_dum ireg3_dum ireg4_dum using "$tables/invest_nss70.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) nonumbers fragment booktabs keep(exposuredum) nonotes replace
esttab ireg1_std ireg2_std ireg3_std ireg4_std using "$tables/invest_nss70.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) label mlabel(none) fragment obslast booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") append

