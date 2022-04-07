set more off
clear 

********************************************************************************
*1.) Prepare data for the household-level regressions 
********************************************************************************
use "$dataworkrep/Pretrend_ForAnalysis.dta", clear

* Create variables for number of households 
bysort state_id district_id fsu round sector substratum hamlet stratum_stage2 hh_sample_no: gen nvals = _n == 1
	collapse (sum) num_hh = nvals [pweight = weight], by (sector state_id district_id round)

tempfile hh_num
save `hh_num'

keep if sector == 1
collapse (sum) num_hh,by(state_id district_id round)
    rename num_hh num_hh_rural
	
tempfile hh_num_rural
save `hh_num_rural'

use "$dataworkrep/Pretrend_ForAnalysis.dta", clear
merge m:1 sector state_id district_id round using `hh_num'
	drop if _m==1
	drop _merge
	
merge m:1 state_id district_id round using `hh_num_rural'
	drop if _m==1
	drop _merge

gen num_hh_rural_2 = num_hh_rural * num_hh_rural 	


* Create variable for monthly purchase of durable goods 
gen value_cons20_mo = value_cons20 / 12

* Scale up casual days worked by 10 
replace hh_wkly_dys_wrk_casual = 10 * hh_wkly_dys_wrk_casual

* Append main data (rds 64, 66, 68) to the pre-trend data
append using "$dataworkrep/HH_regression_data_prepped.dta"

******************************************************
* CREATE CONTROL VARIABLES (hh_size_pctile num_hh_rural_dum*each round)
******************************************************

* Generate percentile of hh_size by survey round and district 
drop hh_size_pctile 

bysort round state_id district_id: egen aux1=pctile(hh_size), p(20)
bysort round state_id district_id: egen aux2=pctile(hh_size), p(40)
bysort round state_id district_id: egen aux3=pctile(hh_size), p(60)
bysort round state_id district_id: egen aux4=pctile(hh_size), p(80)
gen hh_size_pctile=0
replace hh_size_pctile=1 if hh_size>aux1 & hh_size<=aux2
replace hh_size_pctile=2 if hh_size>aux2 & hh_size<=aux3
replace hh_size_pctile=3 if hh_size>aux3 & hh_size<=aux4
replace hh_size_pctile=4 if hh_size>aux4
drop aux1 aux2 aux3 aux4

* Generate interactions of num_hh_rural_dum and num_hh_rural_dum_2 with survey round 
local numlist "60 61 62 64 66 68"
	foreach y of numlist `numlist' {
			gen num_hh_rural_dumX`y'n=num_hh_rural*(round==`y')
			gen num_hh_rural_2_dumX`y'n=num_hh_rural_2*(round==`y')
	}


* Generate interaction of GLP_2008_rural_*_dum and survey round
forvalues x = 20(20)80 {
	bysort state_id district_id: egen GLP_2008_rural_`x'_dum_new = max(GLP_2008_rural_`x'_dum)
	bysort state_id district_id: egen GLP_2010_rural_`x'_dum_new = max(GLP_2010_rural_`x'_dum)
		local numlist "60 61 62 64 66 68"
		foreach y of numlist `numlist' {
			gen GLP_2008_rural_`x'_dumX`y'n = GLP_2008_rural_`x'_dum_new * (round==`y')
			gen GLP_2010_rural_`x'_dumX`y'n = GLP_2010_rural_`x'_dum_new * (round==`y')
		}
}

****** NOTE: THIS VARIABLE (STATE_DIST) IS NOT CONSISTENT ACROSS RDS. DON'T USE IT.
drop state_dist

egen state_district = concat (state_id district_id)

sort state_id district_id round

* Generate ag and non-ag wage for earlier survey rounds 
*First, male wages
replace hh_wkly_dys_wrk_cl_pam_np_1 = 10 * hh_wkly_dys_wrk_cl_pam_np_1 if round < 64
replace hh_wkly_dys_wrk_cl_pam_np_n1 = 10 * hh_wkly_dys_wrk_cl_pam_np_n1 if round < 64 

replace hh_dly_ws_cl_l_pam_np_1 = hh_wkly_ws_cl_l_pam_np_1/hh_wkly_dys_wrk_cl_pam_np_1 if round < 64 
	replace hh_dly_ws_cl_l_pam_np_1=. if hh_wkly_ws_cl_l_pam_np_1==0

replace hh_dly_ws_cl_l_pam_np_n1 = hh_wkly_ws_cl_l_pam_np_n1/hh_wkly_dys_wrk_cl_pam_np_n1 if round < 64 
	replace hh_dly_ws_cl_l_pam_np_n1=. if hh_wkly_ws_cl_l_pam_np_n1==0
	
rename hh_dly_ws_cl_l_pam_np_1 wage_ag_m 
rename hh_dly_ws_cl_l_pam_np_n1 wage_nag_m

*Female wages
replace hh_wkly_dys_wrk_cl_paf_np_1 = 10 * hh_wkly_dys_wrk_cl_paf_np_1 if round < 64
replace hh_wkly_dys_wrk_cl_paf_np_n1 = 10 * hh_wkly_dys_wrk_cl_paf_np_n1 if round < 64 

replace hh_dly_ws_cl_l_paf_np_1 = hh_wkly_ws_cl_l_paf_np_1/hh_wkly_dys_wrk_cl_paf_np_1 if round < 64 
	replace hh_dly_ws_cl_l_paf_np_1=. if hh_wkly_ws_cl_l_paf_np_1==0

replace hh_dly_ws_cl_l_paf_np_n1 = hh_wkly_ws_cl_l_paf_np_n1/hh_wkly_dys_wrk_cl_paf_np_n1 if round < 64 
	replace hh_dly_ws_cl_l_paf_np_n1=. if hh_wkly_ws_cl_l_paf_np_n1==0
	
rename hh_dly_ws_cl_l_paf_np_1 wage_ag_f
rename hh_dly_ws_cl_l_paf_np_n1 wage_nag_f


* Generate interaction of distance to AP and survey round
bysort state_id district_id: egen dist_to_AP_temp = max(dist_to_AP)
	drop dist_to_AP
	rename dist_to_AP_temp dist_to_AP
local numlist "60 61 62 64 66 68"
	foreach y of numlist `numlist' {
			gen dist_to_APX`y' = dist_to_AP * (round == `y')
	}
	
* Fill in hh_pc_cons_m_ea_66
bysort state_id district_id: egen hh_pc_cons_m_ea_66temp = max(hh_pc_cons_m_ea_66)
	drop hh_pc_cons_m_ea_66
	rename hh_pc_cons_m_ea_66temp hh_pc_cons_m_ea_66

* Merge with casual wage dataset 
merge m:1 state_id district_id using "$dataworkrep/avg_casual_wage_66_bydistrict.dta" 
	drop _merge
	
* Fill in casual wage data
foreach var in casual_wage_66 casual_wage_ag_66 casual_wage_nonag_66 {
bysort state_id district_id: egen `var'temp = max(`var')
	drop `var'
	rename `var'temp `var'
}
	
tabstat casual_wage_66 casual_wage_ag_66 casual_wage_nonag_66, by(round)

******************************************************
* CREATE MAIN REGRESSORS
******************************************************


*New version for post renaming - when ready uncomment this and delete the version below w/ old names
foreach v of varlist exp_ratio exp_ratio_dum {
	bysort state_id district_id: egen `v'n = max(`v')
	drop `v'
	rename `v'n `v'
}

local numlist "60 61 62 64 66 68"
	foreach y of numlist `numlist' {
		gen pbo_exp_ratioX`y' = exp_ratio*(round==`y')
}


	gen split = 0
	replace split = 1 if district_name == "krishnagiri" | district_name == "dharmapuri" | district_name == "paschimmidnapur" | district_name == "purbamidnapur"
	
	local numlist "60 61 62 64 66 68"
	foreach n of numlist `numlist'{
		gen round`n' = round == `n'
	}
	

**** SAVE DATASET FOR RESHAPE FOR WAGES
compress
la data "Data from NSS rounds 60, 61, 62, 64, 66, 68 for pre-trends analysis"
save "$dataworkrep/pretrend_data_for_regs", replace


********************************************************************************
*2.) Prepare data for the wage regressions (household x job type)
********************************************************************************

use "$dataworkrep/pretrend_data_for_regs.dta", clear

*rename wages in each casual labor category:
rename wage_ag_m dly_wage0
rename wage_ag_f dly_wage1
rename wage_nag_m dly_wage2
rename wage_nag_f dly_wage3

*rename number of HH workers in each labor category:
rename hh_wkr_cl_l_pam_np_1 casual_workers0
rename hh_wkr_cl_l_paf_np_1 casual_workers1
rename hh_wkr_cl_l_pam_np_n1 casual_workers2
rename hh_wkr_cl_l_paf_np_n1 casual_workers3

gen hh_id= _n

reshape long dly_wage casual_workers, i(hh_id) j(labor_type_id)

gen labor_type=""
replace labor_type="pam, agr" if labor_type_id==0
replace labor_type="paf, agr" if labor_type_id==1
replace labor_type="pam, nonagr" if labor_type_id==2
replace labor_type="paf, nonagr" if labor_type_id==3

*Remove incorrect value label
la values labor_type_id

la data "Wage data (long) from NSS rounds 60, 61, 62, 64, 66, 68 for pre-trends analysis"
save "$dataworkrep/HH_regression_data_pretrend_wage_long.dta", replace

