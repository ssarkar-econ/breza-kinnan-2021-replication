set more off
clear all

cd "$topdir"

********************************************************************************
* Reshape for Wages - Rural
********************************************************************************

use "${dataworkrep}/HH_regression_data.dta", clear

*rename wages in each casual labor category:
rename hh_dly_ws_cl_l_pam_np_1 dly_wage0
rename hh_dly_ws_cl_l_paf_np_1 dly_wage1
rename hh_dly_ws_cl_l_pam_np_n1 dly_wage2
rename hh_dly_ws_cl_l_paf_np_n1 dly_wage3

*rename number of HH workers in each labor category:
rename hh_wkr_cl_l_pam_np_1 casual_workers0
rename hh_wkr_cl_l_paf_np_1 casual_workers1
rename hh_wkr_cl_l_pam_np_n1 casual_workers2
rename hh_wkr_cl_l_paf_np_n1 casual_workers3

gen hh_id= _n

*create HH size percentile before reshaping the data:
xtile hh_size_pctile=hh_size, nq(5)

reshape long dly_wage casual_workers employer, i(hh_id) j(labor_type_id)

gen labor_type=""
replace labor_type="pam, agr" if labor_type_id==0
replace labor_type="paf, agr" if labor_type_id==1
replace labor_type="pam, nonagr" if labor_type_id==2
replace labor_type="paf, nonagr" if labor_type_id==3

cap drop _merge

*** To obtain hh_pc_cons_m_ea_66 for controls_new ***
merge m:1 state_id district_id round using "${dataworkrep}/HH_data_collapsed.dta", keepusing(hh_pc_cons_m_ea_66)
drop _merge


gen exp_ratioX64=0
replace exp_ratioX64=exp_ratio if round==64

gen  exp_ratio_dumX64=0
replace exp_ratio_dumX64 = exp_ratio_dum if round==64

gen dly_wage_win1 = dly_wage	
su dly_wage, detail
replace dly_wage_win1 = `r(p99)' if dly_wage>`r(p99)' & dly_wage<.
gen dly_wage_win11 = dly_wage_win1

label var dly_wage "Casual Daily Wage"

gen male_worker = 0
replace male_worker = 1 if 	labor_type_id == 0 | labor_type_id == 2
*Note: very few women work in non-ag, so for pooled regression, let's focus on men.

gen ag= (labor_type_id == 0 | labor_type_id == 1)
replace ag=. if labor_type_id==.
gen nonag=1-ag


* WINSORIZED WAGE - RIGHT WINSORIZED
ssc inst winsor2
winsor2 dly_wage, cuts(0 99) suffix(_w) label

save "${dataworkrep}/HH_regression_data_wage_long.dta", replace


preserve

gen aux = dly_wage*weight
replace aux=. if round!=66

gen weight_aux = weight
replace weight_aux = . if round!=66

bysort state_id district_id: egen aux1 = sum(aux)
bysort state_id district_id: egen aux2 = sum(weight_aux)

gen casual_wage_66 = aux1/aux2

drop aux weight_aux aux1 aux2

*Now, the male ag wage

gen aux = dly_wage*weight
replace aux=. if round!=66
*set to missing for all but male, ag
replace aux=. if labor_type_id==1 | labor_type_id==2 | labor_type_id==3

gen weight_aux = weight
replace weight_aux = . if round!=66
*set to missing for all but male, ag (cat 0)
replace weight_aux=. if labor_type_id==1 | labor_type_id==2 | labor_type_id==3

bysort state_id district_id: egen aux1 = sum(aux)
bysort state_id district_id: egen aux2 = sum(weight_aux)

gen casual_wage_ag_66 = aux1/aux2

drop aux weight_aux aux1 aux2

*Now, the male non-ag wage

gen aux = dly_wage*weight
replace aux=. if round!=66
*set to missing for all but male, non-ag (cat 2)
replace aux=. if labor_type_id==0 | labor_type_id==1 | labor_type_id==3

gen weight_aux = weight
replace weight_aux = . if round!=66
*set to missing for all but male, non-ag
replace weight_aux=. if labor_type_id==0 | labor_type_id==1 | labor_type_id==3

bysort state_id district_id: egen aux1 = sum(aux)
bysort state_id district_id: egen aux2 = sum(weight_aux)

gen casual_wage_nonag_66 = aux1/aux2

drop aux weight_aux aux1 aux2

keep state_id district_id round casual_wage_66 casual_wage_ag_66 casual_wage_nonag_66
collapse casual_wage_66 casual_wage_ag_66 casual_wage_nonag_66, by(state_id district_id round)

*dummy for the places with no casual ag labor
gen casual_wage_ag_66_0 = (casual_wage_ag_66==0)
tab casual_wage_ag_66_0

gen casual_wage_nonag_66_0 = (casual_wage_nonag_66==0)
tab casual_wage_nonag_66_0


keep if round==66
duplicates drop

save "${dataworkrep}/avg_casual_wage_66_bydistrict.dta", replace

restore

* Calculate average casual wages in round 64:
preserve

gen aux = dly_wage*weight
replace aux=. if round!=64

gen weight_aux = weight
replace weight_aux = . if round!=64

bysort district_id: egen aux1 = sum(aux)
bysort district_id: egen aux2 = sum(weight_aux)

gen casual_wage_64 = aux1/aux2

drop aux weight_aux aux1 aux2

*Now, the male ag wage

gen aux = dly_wage*weight
replace aux=. if round!=64
*set to missing for all but male, ag
replace aux=. if labor_type_id==1 | labor_type_id==2 | labor_type_id==3

gen weight_aux = weight
replace weight_aux = . if round!=64
*set to missing for all but male, ag (cat 0)
replace weight_aux=. if labor_type_id==1 | labor_type_id==2 | labor_type_id==3

bysort state_id district_id: egen aux1 = sum(aux)
bysort state_id district_id: egen aux2 = sum(weight_aux)

gen casual_wage_ag_64 = aux1/aux2

drop aux weight_aux aux1 aux2

*Now, the male non-ag wage

gen aux = dly_wage*weight
replace aux=. if round!=64
*set to missing for all but male, non-ag (cat 2)
replace aux=. if labor_type_id==0 | labor_type_id==1 | labor_type_id==3

gen weight_aux = weight
replace weight_aux = . if round!=64
*set to missing for all but male, non-ag
replace weight_aux=. if labor_type_id==0 | labor_type_id==1 | labor_type_id==3

bysort state_id district_id: egen aux1 = sum(aux)
bysort state_id district_id: egen aux2 = sum(weight_aux)

gen casual_wage_nonag_64 = aux1/aux2

drop aux weight_aux aux1 aux2

keep state_id district_id round casual_wage_64 casual_wage_ag_64 casual_wage_nonag_64
collapse casual_wage_64 casual_wage_ag_64 casual_wage_nonag_64, by(state_id district_id round)

*dummy for the places with no casual ag labor
gen casual_wage_ag_64_0 = (casual_wage_ag_64==0)
tab casual_wage_ag_64_0

gen casual_wage_nonag_64_0 = (casual_wage_nonag_64==0)
tab casual_wage_nonag_64_0

keep if round==64
duplicates drop

save "${dataworkrep}/avg_casual_wage_64_bydistrict.dta", replace

restore
