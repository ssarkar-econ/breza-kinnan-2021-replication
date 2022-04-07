set more off

cd "$topdir"

ssc install xtqreg
use "$dataworkrep/HH_regression_data_prepped.dta", clear
gen exposuredum = exp_ratio_dumXpost
// XXX SS: i think exposuredum = exposure dum is times post dummy. But it's missing from the data
********************************************************************************
	
*main dependent variables used below:
global y_cons_win "value_cons23 value_nondurables value_cons20_mo" //Don't winsorize pov (it's binary)
global y_labor "hh_wkly_dys_wrkd hh_wkly_dys_wrk_casual hh_wkly_earn_win1 hh_invol hh_is_employer_v1 hh_biz"

*changing labels to match tables:
	
	*Labor (Table 4 and 5) variables:
	label var hh_dly_ws_cl_l_pam_np_1 "Casual Daily Wage: Ag" 
	label var hh_dly_ws_cl_l_pam_np_n1 "Casual Daily Wage: Non-Ag" 
	label var hh_wkly_dys_wrkd "HH Weekly Days Worked: Total"
	label var hh_wkly_dys_wrk_casual "HH Weekly Days Worked: Casual"
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	label var hh_invol "Any HH Member Invol. Unemployment"
	label var hh_biz_nonag "Any non-Ag. Self Employment"

	*Consumption (Table 6) variables:
	label var value_cons23 "HH Monthly Consumption: Total"
	label var value_cons20_mo "HH Monthly Consumption: Durables"
	label var value_nondurables "HH Monthly Consumption: Nonurables"
	
	label var hh_wkly_earn "HH Weekly Labor Earnings"
	
	*Summary statistics variables:
	
	label var hh_size "HH size"
	label var hh_NREGA "Any HH Member had NREGA Work this Week"
	

********************************************************************************/
* Consumption Outcomes (Table 6)***********************************************
********************************************************************************

*HERE WE JUST CREATE A GLOBAL TO HOLD THE WINSORIZED VARIABLE NAMES - 1 PER SPECIFICATION.
global y_cons_win_all ""
global y_cons_win_alldum ""
global y_cons_win_allstd ""

foreach y in $y_cons_win {
global y_cons_win_all "$y_cons_win_all `y'_win1"
global y_cons_win_alldum "$y_cons_win_alldum `y'_win1dum"
global y_cons_win_allstd "$y_cons_win_allstd `y'_win1std"

}

di "$y_cons_win"

foreach i in dum std {
foreach y in $y_cons_win_all pov {

areg `y' exposure`i' i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'

}
}


esttab $y_cons_win_alldum povdum using "$tables/cons.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs nonumbers	 label mlabel(none) fragment booktabs keep(exposuredum) nonotes replace
esttab $y_cons_win_allstd povstd using "$tables/cons.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") append

est clear




********************************************************************************/
* Summary Statistics, 2012 NSS (Table 2, 2nd panel)
********************************************************************************

#d ;
global y_sum "hh_wkly_earn hh_dly_ws_cl_l_pam_np_1 hh_dly_ws_cl_l_pam_np_n1 hh_wkly_dys_wrkd hh_wkly_dys_wrkd_slfemp 
hh_wkly_dys_wrkd_nslfem hh_invol hh_NREGA hh_size value_cons23 value_cons20_mo hh_biz_nonag";

#d cr

estpost sum $y_sum if round==68 & exp_ratio_dum==0 & GLP_2010_rural>0 [aweight=weight]
esttab . using "$tables/sum_1.tex", cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2))") ///
nomtitles label nonumbers nolines noobs fragment booktabs replace ///
posthead("%<*t1>") postfoot("%</t1>")

est clear


********************************************************************************/
* Labor Outcomes (Table 5):****************************************************
********************************************************************************

foreach i in dum std {
foreach y in $y_labor {

di "`y'"

areg `y' exposure`i' i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'

}
}

********************************************
********************************************
*now we use wage data in the long format:
********************************************
********************************************

use "$dataworkrep/HH_regression_data_wage_long.dta", clear
gen exposuredum = exp_ratio_dumXpost

foreach i in dum std {

areg dly_wage_win1 exposure`i' i.labor_type_id#i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum dly_wage if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto dly_wage_win1`i'

}

esttab dly_wage_win1dum hh_wkly_dys_wrkddum hh_wkly_dys_wrk_casualdum hh_wkly_earn_win1dum hh_involdum  hh_is_employer_v1dum hh_bizdum using "$tables/labor.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) nonumbers  fragment booktabs keep(exposuredum) nonotes replace
esttab dly_wage_win1std hh_wkly_dys_wrkdstd hh_wkly_dys_wrk_casualstd hh_wkly_earn_win1std hh_involstd  hh_is_employer_v1std hh_bizstd using "$tables/labor.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast label fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") append


/*------------------------------------------------------------------------------
// XXX SS: Checking robustness //
*Robustness 1: use non-winsorized wage, not much change
areg dly_wage exposuredum i.labor_type_id#i.round $controls_M $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
areg hh_wkly_earn exposuredum i.labor_type_id#i.round $controls_M $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
* add year
areg dly_wage exposuredum i.labor_type_id#i.round 		   	///
	c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round 	///
	i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* 	///
	c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* 		///
	i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round i.year [pweight=weight], absorb(state_dist) vce(cluster state_dist)
*add month#year	
areg dly_wage exposuredum i.labor_type_id#i.round 		   	///
	c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round 	///
	i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* 	///
	c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* 		///
	i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round i.year#i.month [pweight=weight], absorb(state_dist) vce(cluster state_dist)
*Robustness 2: use district level controls instead of main controls, not much changes
areg dly_wage_win1 exposuredum i.labor_type_id#i.round  $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
areg hh_wkly_dys_wrkd exposuredum i.labor_type_id#i.round  $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
areg hh_wkly_dys_wrk_casual exposuredum i.labor_type_id#i.round  $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
areg hh_wkly_earn_win1 exposuredum i.labor_type_id#i.round  $controls_D1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)

------------------------------------------------------------------------------*/

********************************************************************************
* Casual Wages (Table 5):****************************************************
* Note: We stack the ag and non-ag wages (the 'pool' in the model names)
* and allow the effect of exposure to differ.
********************************************************************************

*INTERACT EXPOSURE VARS WITH THE AG INDICATOR
*DUMMY
gen exposuredum_ag=exposuredum*ag
gen exposuredum_nonag=exposuredum*nonag
label var exposuredum_ag "(Any exposed lender x Post 2010) x Agriculture"
label var exposuredum_nonag "(Any exposed lender x Post 2010) x Non-agriculture"

*RAW
gen exposurestd_ag=exposurestd*ag
gen exposurestd_nonag=exposurestd*nonag
label var exposurestd_ag "(Exposure Ratio x Post 2010) x Agriculture"
label var exposurestd_nonag "(Exposure Ratio x Post 2010) x Non-agriculture"

*SET THE OUTCOME VARIABLE (DAILY WAGE). 
*Note: dly_wage_w is winsorized at the 99th percentile: 
global y_dly_wage "dly_wage dly_wage_w"

	
foreach i in dum std {

foreach y in $y_dly_wage {

*Wages (men and women)
areg `y' exposure`i'_ag exposure`i'_nonag i.labor_type_id#i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
test exposure`i'_ag=exposure`i'_nonag
eret2 scalar anp=r(p)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 & (labor_type_id == 0 | labor_type_id == 1) [aweight=weight]
eret2 scalar agmn=r(mean)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 & (labor_type_id == 2 | labor_type_id == 3) [aweight=weight]
eret2 scalar namn=r(mean)
est sto pool_`y'`i'

*Men only
areg `y' exposure`i'_ag exposure`i'_nonag i.labor_type_id#i.round $controls_M if male_worker==1 [pweight=weight], absorb(state_dist) vce(cluster state_dist)
test exposure`i'_ag=exposure`i'_nonag
eret2 scalar anp=r(p)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 & (labor_type_id == 0 | labor_type_id == 1) & male_worker==1 [aweight=weight]
eret2 scalar agmn=r(mean)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 & (labor_type_id == 2 | labor_type_id == 3) & male_worker==1 [aweight=weight]
eret2 scalar namn=r(mean)
est sto mpool_`y'`i'

}

}

/* XXX SS: Robustness
areg dly_wage exposuredum_ag exposuredum_nonag i.labor_type_id#i.round $controls_M i.year#i.month [pweight=weight], absorb(state_dist) vce(cluster state_dist)
*/

esttab pool_dly_wagedum mpool_dly_wagedum pool_dly_wage_wdum mpool_dly_wage_wdum  using "$tables/wages_pool.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs   label mlabel(none) nonumbers  fragment booktabs keep(exposuredum_ag exposuredum_nonag) prefoot("\hline") postfoot("\hline \\") nonotes scalars("anp p-value: Ag=non-Ag") replace
esttab pool_dly_wagestd mpool_dly_wagestd pool_dly_wage_wstd mpool_dly_wage_wstd  using "$tables/wages_pool.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast label mlabel(none) nonumbers  fragment booktabs keep(exposurestd_ag exposurestd_nonag) nolines nomtitles nonumbers prefoot("\hline") postfoot("\hline") nonotes scalars("anp p-value: Ag=non-Ag" "agmn Ag mean" "namn Non-ag mean") append

est clear

********************************************************************************
* Quantile Regressions (Table 8):***********************************************
********************************************************************************


use "$dataworkrep/HH_regression_data_prepped.dta", clear
gen exposuredum = exp_ratio_dumXpost

set seed 456123
global reps 250

ren hh_wkly_dys_wrk_casual hh_wkly_dys_wrk

foreach i in std {
*foreach y in value_cons23 value_cons20_mo hh_wkly_earn hh_wkly_dys_wrk_casual {
foreach y in hh_wkly_dys_wrk {
	
*Panel A: 25th pctile regression
di "25th pctile regression, unweighted, `y'"
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist) quantile(.25)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'2_bs

*Panel B: Median regression
di "Median regression, unweighted, `y'"
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'b_bs

*Panel C: 75th pctile regression
di "75th pctile regression, unweighted, `y'"
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist) quantile(.75)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'7_bs


*For appendix: Unweighted OLS (for comparison to quantile regs)
di "Unweighted OLS, `y'"
areg `y' exposure`i' i.round $controls_M, absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'c

*For appendix: OLS with no winsorizing
di "OLS with no winsorizing, `y'"
areg `y' exposure`i' i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'

}
}

********************************************************************************
*WORKER LEVEL DEPENDENT VARIABLE********************************************
********************************************************************************

use "$dataworkrep/HH_regression_data_wage_long.dta", clear
gen exposuredum = exp_ratio_dum

foreach i in std {
foreach y in dly_wage {
	
*25th pctile regression
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist) quantile(.25)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
cap n eret2 scalar mn=r(mean)
cap n eret2 scalar sd=r(sd)
est sto `y'`i'b25_bs

*75th pctile regression
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist) quantile(.75)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
cap n eret2 scalar mn=r(mean)
cap n eret2 scalar sd=r(sd)
est sto `y'`i'b75_bs

*Median regression
*qreg2 `y' exposure`i' i.state_dist $controls_M, cl(state_dist)
bs, reps($reps) cluster(state_dist): xtqreg `y' exposure`i' $controls_M, i(state_dist) q(.5)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
cap n eret2 scalar mn=r(mean)
cap n eret2 scalar sd=r(sd)
est sto `y'`i'b_bs

*For appendix: OLS with no winsorizing
areg `y' exposure`i' i.round $controls_M [pweight=weight], absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
cap n eret2 scalar mn=r(mean)
cap n eret2 scalar sd=r(sd)
est sto `y'`i'

*For appendix: *Unweighted OLS
areg `y' exposure`i' i.round $controls_M, absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0
cap n eret2 scalar mn=r(mean)
cap n eret2 scalar sd=r(sd)
est sto `y'`i'c

}
}

#d;

*Panel A: 25th pctile regression, unweighted (summary outcomes);
esttab value_cons23std2_bs value_cons20_mostd2_bs hh_wkly_earnstd2_bs hh_wkly_dys_wrkstd2_bs dly_wagestdb25_bs using "$tables/tailsB25.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace;

*Panel B: Median regression with no winsorizing (summary outcomes);
esttab value_cons23stdb_bs value_cons20_mostdb_bs hh_wkly_earnstdb_bs hh_wkly_dys_wrkstdb_bs dly_wagestdb_bs using "$tables/tailsB50.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace;

*Panel C: 75th pctile regression, unweighted (summary outcomes);
esttab value_cons23std7_bs value_cons20_mostd7_bs hh_wkly_earnstd7_bs hh_wkly_dys_wrkstd7_bs dly_wagestdb75_bs using "$tables/tailsB75.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace;

*Appendix: OLS with no winsorizing (summary outcomes);
esttab value_cons23std value_cons20_mostd hh_wkly_earnstd hh_wkly_dys_wrkstd dly_wagestd using "$appendix/tailsA.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace;

*Appendix: Unweighted OLS (summary outcomes);
esttab value_cons23stdc value_cons20_mostdc hh_wkly_earnstdc hh_wkly_dys_wrkstdc dly_wagestdc using "$appendix/tailsC.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast  label mlabel(none) fragment booktabs keep(exposurestd) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace;

est clear;
