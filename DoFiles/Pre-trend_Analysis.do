**************************************************************
/*

PRE-TREND DATA ANALYSIS

THIS FILE PLOTS PRE-TRENDS for HH-level and HHxOccupation-level (ie, wage) outcomes TO MAKE FIG 2
		
**************************************************************/
clear

global pretrend_controls "i.month i.round i.hh_size_pctile c.num_hh_rural_dumX6*n c.num_hh_rural_2_dumX6*n i.GLP_2008_rural_*_dumX6*n i.GLP_2010_rural_*_dumX6*n dist_to_APX* c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round" 



******************************************************
* 1.) Household-level outcomes 
******************************************************

global var1 "value_cons23"
global var2 "value_cons20_mo" 	//We don't have this for round 62.  Run that regression dropping round 62
global var3 "hh_wkly_earn"

global y_key "$var1 $var2 $var3"

use "$dataworkrep/pretrend_data_for_regs",clear

*make num_hh_rural_dum
bysort state_id district_id: egen num_hh_rural_dum=max(num_hh_rural_dumX66n)
bysort state_id district_id: egen num_hh_rural_2_dum=max(num_hh_rural_2_dumX66n)


* OMIT ROUND 66 

global varlist "pbo_exp_ratioX60  pbo_exp_ratioX61 pbo_exp_ratioX62 pbo_exp_ratioX64 pbo_exp_ratioX68"
	
local m = 1
foreach y in $y_key {		
			
		areg `y' $varlist $pretrend_controls [pweight=weight], absorb(state_district) vce(cluster state_district)
			parmest, saving ("$dataworkrep/pretrends`m'_raw.dta", replace)

		local m = `m' + 1
		}	
		
	
******************************************************
* 2.) Household-by-occupation-level outcomes (wages) 
******************************************************
	
use "$dataworkrep/HH_regression_data_pretrend_wage_long.dta", clear

** Daily Wages
	* All categories
	local m = 4
	areg dly_wage $varlist $pretrend_controls i.labor_type_id#i.round [pweight=weight] if (split == 0), absorb(state_district) vce(cluster state_district)
		parmest, saving ("$dataworkrep/pretrends`m'_raw.dta", replace)

	* Ag Wages
	local m = 5
	areg dly_wage $varlist $pretrend_controls i.labor_type_id#i.round [pweight=weight] if (labor_type_id==0 | labor_type_id==1) & (split == 0), absorb(state_district) vce(cluster state_district)
		parmest, saving ("$dataworkrep/pretrends`m'_raw.dta", replace)
		
	* Non-Ag Wage
	local m = 6
	areg dly_wage $varlist $pretrend_controls i.labor_type_id#i.round [pweight=weight] if (labor_type_id==2 | labor_type_id==3) & (split == 0), absorb(state_district) vce(cluster state_district)
		parmest, saving ("$dataworkrep/pretrends`m'_raw.dta", replace)

		
******************************************************
* 3.) Graph Outputs 
******************************************************

* HH MONTHLY TOTAL CONSUMPTION 

		use "$dataworkrep/pretrends1_raw.dta", clear
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "62" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) ///
		(line min95 round, lpattern(dash)) (line max95 round, lpattern(dash)), ///
       ytitle("HH Monthly Total Consumption" " ", size(small)) ///
       xtitle(" " "Survey Round", size(small)) ///
	   graphregion(c(white)) ysize(5) xsize(7) ///
	   ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small))
	graph export "$tables/PreTrendPlots/pretrends1_raw.png", replace

	
* HH MONTHLY DURABLES CONSUMPTION (Round 62 did not ask this) - modify accordingly 

	use "$dataworkrep/pretrends2_raw.dta", clear 
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) ///
		(line min95 round, lpattern(dash)) (line max95 round, lpattern(dash)), ///
       ytitle("HH Monthly Durables Consumption" " ", size(small))  ///
       xtitle(" " "Survey Round", size(small))  ///
	   graphregion(c(white)) ysize(5) xsize(7) ///
	   ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small))
	graph export "$tables/PreTrendPlots/pretrends2_raw.png", replace
	
	
* HH WEEKLY LABOUR EARNINGS 

	use "$dataworkrep/pretrends3_raw.dta", clear 
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "62" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) ///
		(line min95 round, lpattern(dash)) (line max95 round, lpattern(dash)), ///
       ytitle("HH Weekly Labor Earnings" " ", size(small))  ///
       xtitle(" " "Survey Round", size(small))  ///
	   graphregion(c(white)) ysize(5) xsize(7) ///
	   ylabel(,labs(small) nogrid angle(verticle)) xlabel(,labs(small))
	graph export "$tables/PreTrendPlots/pretrends3_raw.png", replace	
	
	
* Casual Daily Wage	

		use "$dataworkrep/pretrends4_raw.dta", clear 
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "62" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) /// 
	   (line min95 round, lpattern(dash)) ///
	   (line max95 round, lpattern(dash)), ///
       ytitle("Casual Daily Wage" " ", size(small))  ///
       xtitle(" " "Survey Round", size(small))  ///
	   graphregion(c(white)) ysize(5) xsize(7)  ///
	   ylabel(-100(25)75,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) yscale(range(-100 75))

	graph export "$tables/PreTrendPlots/pretrends4_raw.png", replace
		

* CASUAL DAILY WAGE: AG 

		use "$dataworkrep/pretrends5_raw.dta", clear 
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "62" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) /// 
	   (line min95 round, lpattern(dash)) ///
	   (line max95 round, lpattern(dash)), ///
       ytitle("Casual Daily Wage: Ag" " ", size(small))  ///
       xtitle(" " "Survey Round", size(small))  ///
	   graphregion(c(white)) ysize(5) xsize(7)  ///
	   ylabel(-100(25)75,labs(small) nogrid angle(verticle)) xlabel(,labs(small)) yscale(range(-100 75)) 

	graph export "$tables/PreTrendPlots/pretrends5_raw.png", replace


* CASUAL DAILY WAGE: NON-AG 

	 	use "$dataworkrep/pretrends6_raw.dta", clear 
		gen round = substr(parm, -2, .)
		gen notinstr = indexnot("ratio",parm)
		keep if notinstr==0
		drop notinstr
		keep if round == "60" | round == "62" | round == "64" | round == "66" | round == "68" | round == "61"
		destring round, replace
		sort round 
		
		set obs `= _N + 1'
		replace estimate = 0 if round == .
		replace min95 = 0 if round == . 
		replace max95 = 0 if round == . 
		replace round = 66 if round == .
		sort round
		
		twoway (connected estimate round, msize(small)) /// 
	   (line min95 round, lpattern(dash)) ///
	   (line max95 round, lpattern(dash)), ///
       ytitle("Casual Daily Wage: Non-Ag" " ", size(small))  ///
       xtitle(" " "Survey Round", size(small))  ///
	   graphregion(c(white)) ysize(5) xsize(7)  ///
	   ylabel(-100(25)75, labs(small) nogrid angle(verticle)) xlabel(,labs(small)) yscale(range(-100 75)) 

	graph export "$tables/PreTrendPlots/pretrends6_raw.png", replace

	
