
set more off
clear

cd "$topdir"


* 1) Merge state and dist codes onto the instruments.  Prepare Round 66 controls. 
use "$dataworkrep/HH_data_collapsed.dta", clear

keep if round==68

foreach v in GLP_2008_rural_20_dum GLP_2008_rural_40_dum GLP_2008_rural_60_dum GLP_2008_rural_80_dum GLP_2010_rural_20_dum GLP_2010_rural_40_dum GLP_2010_rural_60_dum GLP_2010_rural_80_dum {
rename `v'X68 `v'
}
// XXX SS: correct variable names
keep state_name district_name /*exposuredum*/ exposure exposurestd exp_ratioXpost exp_ratio_dumXpost GLP_2008_rural GLP_2010_rural GLP_2008_rural_20_dum GLP_2008_rural_40_dum GLP_2008_rural_60_dum GLP_2008_rural_80_dum GLP_2010_rural_20_dum GLP_2010_rural_40_dum GLP_2010_rural_60_dum GLP_2010_rural_80_dum dist_to_AP hh_pc_cons_m_ea_66 //
rename state_name state_name68
rename district_name district_name68

merge 1:1 state_name68 district_name68 using "$dataworkrep/statedist_codes68.dta"
drop _merge

save "$dataworkrep/instruments.dta", replace

use "$dataworkrep/HH_data_with_credit.dta", clear
drop region
ren state_id region
ren district_id district

rename *outstanding* *paper*

#d ;
local cont_vars "no_accounts_agriculture amt_paper_agriculture no_accounts_dir_fin 
amt_paper_dir_fin no_accounts_indirect_fin amt_paper_indirect_fin
"
;

#d cr

local cont_list "value_cons23 value_cons20 hh_wkly_earn_wrking_slfemp hh_wkly_earn_wrking_nslfem hh_wkly_dys_wrkd hh_wkly_dys_wrkd_slfemp hh_wkly_dys_wrkd_nslfem hh_dly_wage_casual_labor hh_wkly_earn_pct_slfemp GLP_2008_rural_*_dum GLP_2010_rural_*_dum"



keep if round==66

keep region district  `cont_list' `cont_vars' weight

collapse `cont_list' `cont_vars' [pweight=weight], by(region district)

keep region district no_accounts_agriculture amt_paper_agriculture no_accounts_dir_fin amt_paper_dir_fin no_accounts_indirect_fin amt_paper_indirect_fin value_cons23 value_cons20 hh_wkly_earn_wrking_slfemp hh_wkly_earn_wrking_nslfem hh_wkly_dys_wrkd hh_wkly_dys_wrkd_slfemp hh_wkly_dys_wrkd_nslfem hh_dly_wage_casual_labor hh_wkly_earn_pct_slfemp

save "$dataworkrep/controls.dta", replace


* 2) Merge onto the NSS 70 data

use "$dataworkrep/NSS70"

keep if sector=="1"
	* Keep only the rural sample

capture drop _merge

capture drop _merge
merge m:1 region district using "$dataworkrep/instruments"
keep if _merge==3
drop _merge

merge m:1 region district using "$dataworkrep/controls"
drop _merge

gen round_temp=66
destring round,replace

clonevar district_name_old=district_name

replace district_name = subinstr(district_name, "   * ", "", 1)
replace district_name = subinstr(district_name, "  * ", "", 1)
replace district_name = subinstr(district_name, " * ", "", 1)
replace district_name = subinstr(district_name, "   *", "", 1)
replace district_name = subinstr(district_name, "  *", "", 1)
replace district_name = subinstr(district_name, " *", "", 1)
replace district_name = subinstr(district_name, "*", "", 1)


* Harmonize names between rounds 70 and 64/66/68
replace district_name = "Kandhamalphoolbani" if state_name=="orissa" & district_name =="Kandhamal"
replace district_name = "Lakshadweephisarai" if state_name=="bihar" & district_name=="Lakhisarai"
replace district_name = "Champaranw" if state_name=="bihar" & district_name=="Pashchim Champaran"
replace district_name = "Champarane" if state_name=="bihar" & district_name=="Purba Champaran"
replace state_name = "chattisgarh" if state_name =="chhattisgarh"
replace district_name = "Ahmedabad" if state_name=="gujarat" & district_name=="Ahmadabad"
replace district_name = "Panchmahals" if state_name=="gujarat" & district_name=="Panch Mahals"
replace district_name = "Sabarkantha" if state_name=="gujarat" & district_name=="Sabar Kantha"
replace district_name = "Hazaribag" if state_name=="jharkhand" & district_name=="Hazaribagh"
replace district_name = "Singhbhume" if state_name=="jharkhand" & district_name=="Purbi Singhbhum"
replace district_name = "Singhbhumw" if state_name=="jharkhand" & district_name=="Pashchimi Singhbhum"
replace district_name = "Bangalorerural" if state_name=="karnataka" & district_name=="Bangalore Rural"
replace district_name = "Dakshinakannada" if state_name=="karnataka" & district_name=="Dakshina Kannada"
replace district_name = "Uttarakannada" if state_name=="karnataka" & district_name=="Uttara Kannada"
replace district_name = "Palakshadweepkad" if state_name=="kerala" & district_name=="Palakkad"
replace district_name = "Enimar" if state_name=="madhyapradesh" & district_name=="East Nimar"
replace district_name = "Wnimar" if state_name=="madhyapradesh" & district_name=="West Nimar"
replace district_name = "Toothukudi" if state_name=="tamilnadu" & district_name=="Thoothukkudi"
replace district_name = "Tiruvanamalai" if state_name=="tamilnadu" & district_name=="Tiruvannamalai"
replace district_name = "Dehradunh" if state_name=="uttaranchal" & district_name=="Dehradun"
replace district_name = "Nainitalh" if state_name=="uttaranchal" & district_name=="Nainital"
replace district_name = "Ambedkarnag" if state_name=="uttarpradesh" & district_name=="Ambedkar Nagar"
replace district_name = "Bulandshahr" if state_name=="uttarpradesh" & district_name=="Bulandshahar"
replace district_name = "Jphulenagar" if state_name=="uttarpradesh" & district_name=="Jyotiba Phule Nagar"
replace district_name = "Kanpurnagar" if state_name=="uttarpradesh" & district_name=="Kanpur Nagar"
replace district_name = "Maharajganj" if state_name=="uttarpradesh" & district_name=="Mahrajganj"
replace district_name = "Raebareli" if state_name=="uttarpradesh" & district_name=="Rae Bareli"
replace district_name = "Janjgirchampa" if state_name=="chattisgarh" & district_name=="Janjgir - Champa"
replace district_name = "Eastkhasihills" if state_name=="meghalaya" & district_name=="East Khasi Hills"
replace district_name = "Westkhasihills" if state_name=="meghalaya" & district_name=="West Khasi Hills"
replace district_name = "Sawaimadhopur" if state_name=="rajasthan" & district_name=="Sawai Madhopur"
replace district_name = "West" if state_name=="tripura" & district_name=="West Tripura"
replace district_name = "Udhamsinghnagar" if state_name=="uttaranchal" & district_name=="Udham Singh Nagar"
replace district_name = "Skabirnagar" if state_name=="uttarpradesh" & district_name=="Sant Kabir Nagar"
replace district_name = "Srnagarbhadoh" if state_name=="uttarpradesh" & district_name=="Sant Ravidas Nagar Bhadohi"
replace district_name = "Dakshindinajpur" if state_name=="westbengal" & district_name=="Dakshin Dinajpur"
replace district_name = "Howrah" if state_name=="westbengal" & district_name=="Haora"
replace district_name = "Kochbihar" if state_name=="westbengal" & district_name=="Koch Bihar"
replace district_name = "North24Parganas" if state_name=="westbengal" & district_name=="North Twenty Four Parganas"
replace district_name = "Paschimmidnapur" if state_name=="westbengal" & district_name=="Pashim Midnapur"
replace district_name = "Purbamidnapur" if state_name=="westbengal" & district_name=="Purba Midnapur"
replace district_name = "South24Parganas" if state_name=="westbengal" & district_name=="South  Twenty Four Parganas"
replace district_name = "Uttardinajpur" if state_name=="westbengal" & district_name=="Uttar Dinajpur"


*** Get state_id and district_id for merging with avg_casual_wage_66_bydistrict.dta file (for casual_wage_66 variable) ***
merge m:1 state_name district_name using "$dataworkrep/state_dist_identifiers.dta",keepusing(state_id district_id)
drop _merge


*** Merge with following files for obtaining controls_new variables ***
merge m:1 state_id district_id using "$dataworkrep/avg_casual_wage_66_bydistrict.dta",force
drop _merge


* Winsorizing at 99th percentile conditional on positive values

su loan_amount_out_june30 if loan_amount_out_june30~=0, detail
	*  940500
su loan_amt630_bank if loan_amt630_bank~=0, detail
	* 1040000
su loan_amt630_MF_NBFC if loan_amt630_MF_NBFC~=0, detail
	* 174440
su loan_amt630_fininstSHG_nocoll if loan_amt630_fininstSHG_nocoll~=0, detail
	* 345000

*Fix name to avoid confusion
ren loan_amt630_fininstSHG_nocoll loan_amt630_fiSHG_nocoll
	

gen loan_amount_out_june30_w99 = loan_amount_out_june30
replace loan_amount_out_june30_w99 = 940500 if loan_amount_out_june30> 940500

gen loan_amt630_bank_w99 = loan_amt630_bank
replace loan_amt630_bank_w99 = 1040000 if loan_amt630_bank>1040000

gen loan_amt630_MF_NBFC_w99=loan_amt630_MF_NBFC
replace loan_amt630_MF_NBFC_w99=174440 if loan_amt630_MF_NBFC>174440

gen loan_amt630_fiSHG_nocoll_w99= loan_amt630_fiSHG_nocoll
replace loan_amt630_fiSHG_nocoll_w99=345000 if loan_amt630_fiSHG_nocoll>345000

la var loan_amt630_MF_NBFC "MFI amt outstanding" //This goes in the appendix
la var loan_amt630_MF_NBFC_w99 "MFI amt outstanding, win" //This goes in the appendix
la var loan_amt630_fiSHG_nocoll "Uncollateralized formal non-bank amt outstanding"
la var loan_amt630_fiSHG_nocoll_w99 "Uncollateralized formal non-bank amt outstanding, win"
la var loan_amt630_bank_w99 "Bank amt outstanding, win"
la var loan_amount_out_june30_w99 "Total loan amt outstanding, win"
la var loan_amount_out_june30 "Total loan amt outstanding"


*Now take logs of winsorized vars:

foreach v in loan_amt630_MF_NBFC_w99 loan_amt630_fiSHG_nocoll_w99 loan_amt630_bank_w99 loan_amount_out_june30_w99 {

gen l`v'=log(0.001+`v')

}


merge 1:1 center_code fsu sample sector region district stratum substratum subround subsample fod hamlet stratum_stage2 hh_sample_no using "$dataworkrep/NSS70_Investment_Variables.dta"

drop if _merge==2
drop _merge

local investvars expend_nagbiz expend_agbiz expend_hh expenditure
foreach i of varlist `investvars' {
	replace `i'=0 if `i'==.
}

*Save dataset for regressions
save "$dataworkrep/NSS70_for_regressions.dta", replace 









