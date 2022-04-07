
cd "$topdir"


* Merge MFI data with NSS name data
use ${dataworkrep}/MFI_Exposure_REPLICATE.dta, clear

merge m:1 state district using ${dataworkrep}/nss_66_name.dta
drop if _merge==2 
drop _merge

ren district district_name
ren state state_name

sa ${dataworkrep}/mfi_prereg_data_nss_66_name,replace


* Merge in main NSS district data
local typ rural

u "${dataworkrep}/nss_all_10_dist_`typ'.dta",clear

* Generate matching statecode variable
tostring region,gen(state)
g strlen = length(state)
assert strlen==2|strlen==3
g statecode66 = regexs(0) if(regexm(state, "^[0-9]")) & strlen==2
replace statecode66 = regexs(0) if(regexm(state, "^[0-9][0-9]")) & strlen==3
destring statecode66,replace
drop state strlen

g districtcode66 = district

* Collapse all Delhi districts into one
replace districtcode66 = 1 if statecode66==7 //Delhi
bys round statecode66 districtcode66: egen total_n = sum(num_ppl)
replace num_ppl = total_n if statecode66==7 & district==1
drop if statecode66==7 & district~=1


* Merge with MFI data (at NSS 66 level name/codes)
merge m:1 statecode66 districtcode66 round using ${dataworkrep}/mfi_prereg_data_nss_66_name
drop if _merge==2 
drop _merge districtcode66 statecode66

	
ren region state_id
ren district district_id
	
g post = round==68
g expXpost = exp_ratio*post


merge m:1 state_id district_id using ${dataworkrep}/Census2011
keep if _merge==3
drop _merge


lab var	round	"	NSS Round	"
lab var	state_id	"	Region Code	"
lab var	district_id	"	District Code	"
lab var	state_name	"	State name	"
lab var	district_name	"	District name	"
cap lab var	sector	"	Survey Sector	"
lab var	post	"	Post AP Crisis (Round 68)	"
lab var	exp_ratio	"	Ratio of Exposure to AP Crisis	"
lab var	expXpost	"	exp_ratio * post	"
lab var	num_ppl	"	Number of people in district sector subsample"
lab var	GLP	"	Gross loan portfolio round"
lab var	GLP_2013	"	Gross loan portfolio 2013	"
lab var	GLP_2011	"	Gross loan portfolio 2011	"
lab var	GLP_2012	"	Gross loan portfolio 2012	"
lab var	pop_2011	"	Population in district (from 2011 Census)	"
lab var exp_ratio "Ratio of Exposure to AP Crisis"
lab var post "Post AP Crisis (Round 68)"
lab var expXpost "exp_ratio * post"

order round state_id district_id state_name district_name post exp_ratio expXpost
cap order round state_id district_id state_name district_name sector post exp_ratio expXpost hh* val* ln*


sa "${dataworkrep}/nss_mfi_merged_`typ'.dta",replace


* Merge on number of rural households at district level. 
u ${dataworkrep}/nss_66_10_dist.dta,clear

	keep if sector == 1 
	//rural
	drop sector
	ren region state_id
	ren district district_id

	collapse (sum) num_hh num_ppl,by(state_id district_id)
	* SUMMING ACROSS SUBSAMPLES
    rename num_hh num_hh_rural
	rename num_ppl num_ppl_rural
tempfile pop
sa `pop'


u ${dataworkrep}/nss_mfi_merged_`typ'.dta,clear

merge m:1 state_id district_id using `pop', replace update
keep if _merge==3 | _merge==4 | _merge==5
drop _merge

gen exp_ratio_dum=(exp_ratio>0) if exp_ratio<.

label var exp_ratio_dum "Indicator for Positive Exposure to AP Crisis"

sa ${dataworkrep}/nss_mfi_merged_`typ'_instr.dta,replace

keep round state_id district_id state_name district_name post exp* num_* GLP* pop*
collapse post exp* num_* GLP* pop*, by(round state_name district_name)
save ${dataworkrep}/merge_rural.dta, replace


* Merge in main NSS HH-level data
u "${dataworkrep}/nss_all_hh_`typ'.dta",clear

* Generate matching statecode variable
tostring region,gen(state)
g strlen = length(state)
assert strlen==2|strlen==3
g statecode66 = regexs(0) if(regexm(state, "^[0-9]")) & strlen==2
replace statecode66 = regexs(0) if(regexm(state, "^[0-9][0-9]")) & strlen==3
destring statecode66,replace
drop state strlen

g districtcode66 = district

* Collapse all Delhi districts into one
preserve
keep if statecode66==7 //Delhi
replace districtcode66 = 1 if statecode66==7 //Delhi
	
	tempfile delhi
	sa `delhi'
restore

drop if statecode66==7
append using `delhi'
			
merge m:1 statecode66 districtcode66 round using ${dataworkrep}/mfi_prereg_data_nss_66_name
drop _merge districtcode66 statecode66
	
ren region state_id
ren district district_id

sa ${dataworkrep}/nss_mfi_merged_hh_`typ'_instr_new.dta,replace

keep sector ln_value_cons* value_cons* dup64* survey_date round state_id district_id state_name district_name hh_* value_* fsu substratum subsample hamlet stratum_stage2 n_working pct_working weight

* Merge MFI data into the rural household data
merge m:1 state_name district_name round using ${dataworkrep}/merge_rural.dta, replace update
drop if state_name=="" | GLP==.
drop _merge

save ${dataworkrep}/nss_mfi_merged_hh_rural_instr_new.dta, replace







