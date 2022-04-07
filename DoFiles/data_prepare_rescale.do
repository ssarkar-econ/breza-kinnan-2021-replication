set more off

cd "$topdir"

*************************************
*************************************
* DEFINE EXPOSURE VARS
* AND MERGE IN DISTANCE
* NOTE: THE FILES "$nss70\NSS70_merged_rural_instr.dta" "$dataworkrep/NSS70_merged_rural_instr_quintile" "$dataworkrep\NSS70_merged_urban_instr.dta" ARE NOT HERE BECAUSE THEY ARE CLEANED LATER ON IN THE FILE SEQUENCE
*************************************
*************************************
ssc install isvar

#d ;
foreach data in "$dataworkrep/HH_regression_data_prepped.dta" "$dataworkrep/HH_data_collapsed.dta" "$dataworkrep/HH_regression_data_wage_long.dta" "$dataworkrep/HH_data_with_credit.dta"
{;
di "`data'";

use "`data'", clear;

isvar dist_to_AP;
cap n drop _merge;

if "`r(badlist)'"=="dist_to_AP" {;
	clonevar state_id=region;
	clonevar district_id=district;
	merge m:1 state_id district_id using "$dataworkrep/distance_to_AP_districtwise.dta";
	drop _merge;
};

merge m:1 state_name using "$dataworkrep/party.dta";
drop _merge;
merge m:1 state_id district_id using "$dataworkrep/avg_casual_wage_66_bydistrict.dta";
drop _merge;
merge m:1 state_id district_id using "$dataworkrep/avg_casual_wage_64_bydistrict.dta";
drop _merge;
merge m:1 state_name district_name using "$dataworkrep/CreditPre_wide.dta";
drop if _merge==2;
drop _merge;


*** EXPOSURE (DUMMY);
cap n drop exposuredum;
clonevar exposuredum = exp_ratio_dumXpost ;
sum exposuredum; 
label var exposuredum "Any exposed lender $\times$ Post 2010";


**** EXPOSURE standardized (Standardized Raw Exposure) ;
cap n drop exp_ratioXpost;
gen exp_ratioXpost=0 ;
replace exp_ratioXpost=exp_ratio if round==68; 
cap n drop exposure;
clonevar exposure = exp_ratioXpost;
cap n drop exposurestd;
sum exposure [aweight=weight] if round==68;
gen exposurestd = exposure/r(sd);
sum exposurestd;
label var exposurestd "Exposure Ratio $\times$ Post 2010";


save "`data'",  replace;

};
