
cd "$topdir"

use  "$dataworkrep/HH_regression_data.dta", clear

gen Year=2008 if round==64
replace Year=2010 if round==66
replace Year=2012 if round==68

drop _m

merge m:1 state_name district_name Year using "$dataworkrep/Bank.dta"
drop if _merge==2
drop _merge

save "$dataworkrep/HH_data_with_credit.dta", replace
