

cd "$topdir"

	
use "$dataworkrep/MFI_Exposure_REPLICATE", clear	
	* Problem - this file does "drop if round==." so it's not a full panel.  However, can reshape. 

drop GLP round Year Month
* Some districts did not have MFIs during some of the periods so I am imputing zeros
gen state_district = state + " " + district
encode state_district, gen(state_dist)
duplicates drop

reshape long GLP_, i(state_district) j(Year)	
	* This is a balanced panel by construction. 
	
rename GLP_ GLP
	
** Merge on Controls	
		* Need: pop66 dist_to_AP casual_wage_66 hh_pc_cons_m_ea_66 if GLP_2008_rural_20_dum==0, 

gen round = 66 if Year==2010	
		
		
preserve

** Merge in the district-level controls (district level aggregates)

use "$dataworkrep/HH_data_collapsed.dta", clear	

global controls_distpanel  "round hh_pc_cons_m_ea_66 casual_wage_66 num_hh_rural dist_to_AP"	
keep round state* dist*  $controls_distpanel
keep if round==66

save "$dataworkrep/distcontrols_temp.dta"

restore

rename state state_name
rename district district_name 

merge m:1 round state_name district_name using "$dataworkrep/distcontrols_temp.dta"	
	
erase "$dataworkrep/distcontrols_temp.dta"

drop if state_name=="andhrapradesh"
	
	
keep if _merge==3 | _merge==1
gen GLP_2008 = GLP if Year==2008		
		
foreach var in $controls_distpanel GLP_2008 {
gen temp = `var'
drop `var'
bys state_name district_name: egen `var' = max(temp)
drop temp
}
		
		

gen GLP_phh_r = GLP / num_hh_rural
gen num_hh_rural_2 = num_hh_rural^2


gen exp_8 = exp_ratio*(Year==2008)
gen exp_9 = exp_ratio*(Year==2009)
gen exp_11 = exp_ratio*(Year==2011)
gen exp_12 =  exp_ratio*(Year==2012)
gen exp_13 = exp_ratio*(Year==2013)

		
areg GLP_phh_r exp_8 exp_9 exp_11 exp_12 exp_13 c.dist_to_AP#i.Year c.casual_wage_66#i.Year c.num_hh_rural#i.Year c.num_hh_rural_2#i.Year c.hh_pc_cons_m_ea_66#i.Year if  GLP_2008~=0, absorb(state_dist) cluster(state_dist)

parmest, saving ("$tables/fspanel.dta", replace)
		

* Make the plot

	use "$tables/fspanel", clear 
	gen year = substr(parm, -2, .)
	replace year = subinstr(year, "_", "", 1)
	replace year = subinstr(year, " ", "", 3)
	
	keep if _n<=5
	destring year, replace		
	set obs `= _N + 1'
	replace estimate = 0 if year == .
	replace min95 = 0 if year == . 
	replace max95 = 0 if year == . 
	replace year = 10 if year == .
	sort year 
		
   	twoway (connected estimate year, msize(small)) /// 
   (line min95 year, lpattern(dash)) ///
   (line max95 year, lpattern(dash)), ///
   ytitle("GLP per household" " ", size(small))  ///
   xtitle(" " "Year", size(small))  ///
   graphregion(c(white)) ysize(5) xsize(7)  ///
   ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small))sch(s2mono)

	graph export "$tables/fspanel.eps", replace

erase "$tables/fspanel.dta"

