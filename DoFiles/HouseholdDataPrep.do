cd "$topdir"


*** 1) Construct Subset of District-Level Controls

* Load Data and Compute distance to Hyderabad	
	* Used tools.wmflabs.org
u "${dataworkrep}/nss_mfi_merged_rural_instr.dta", clear
sort district_name
sort district_name
* merge m:1 district_name using "Analysis/Rainfall/rainfall_by_district.dta" // XXX SS: Comment this out 
merge m:1 district_name using "ReplicationFiles/Data/rainfall_by_district.dta"
drop _merge

	ssc install geodist
geodist Y_coord X_coord  17.37 78.48,gen(dist_to_AP)

*Calculate rainfall shocks using the round as the year:
gen rainfall_shock=.
replace rainfall_shock=rainfall_shock_2008 if round==64
replace rainfall_shock=rainfall_shock_2010 if round==66
replace rainfall_shock=rainfall_shock_2012 if round==68

* Generate GLP measures used in controls
foreach x in 2008 2010{
gen GLP_`x'_rural = GLP_`x'/num_hh_rural
lab var GLP_`x'_rural "`x' GLP scaled by number of households (rural)"
}

gen exp_ratioXpost = exp_ratio*(round==68)
gen exp_ratio_dumXpost = exp_ratio_dum*(round==68)


* Drop AP and Identify Border Districts
drop if state_name == "andhrapradesh"

* Generate IDs for each district
bysort round: gen counter = _n if round==64
g state_dist_temp = state_id*100+district_id
bysort state_dist_temp: egen state_dist = max(counter)
drop state_dist_temp
egen categorical_state_name = group(state_name)

g border_AP = 0
replace border_AP = 1 if state_id==331 & district_id==1 //tamilnadu - thiruvallur
replace border_AP = 1 if state_id==334 & district_id==31 //tamilnadu - krishnagiri
replace border_AP = 1 if state_id==331 & district_id==4 //tamilnadu - vellore

replace border_AP = 1 if state_id==294 & district_id==12 //karnataka - bellary
replace border_AP = 1 if state_id==294 & district_id==5 //karnataka - bidar
replace border_AP = 1 if state_id==294 & district_id==13 //karnataka - chitradurga
replace border_AP = 1 if state_id==294 & district_id==4 //karnataka - gulbarga
replace border_AP = 1 if state_id==293 & district_id==19 //karnataka - kolar
replace border_AP = 1 if state_id==294 & district_id==6 //karnataka - raichur
replace border_AP = 1 if state_id==293 & district_id==18 //karnataka - tumkur

replace border_AP = 1 if state_id==276 & district_id==13 //maharashtra - chandrapur
replace border_AP = 1 if state_id==276 & district_id==12 //maharashtra - gadchiroli
replace border_AP = 1 if state_id==274 & district_id==15 //maharashtra - nanded
replace border_AP = 1 if state_id==275 & district_id==14 //maharashtra - yavatmal

//dantewada and bijapur missing in data from chhattisgarh (borders AP)

replace border_AP = 1 if state_id==212 & district_id==19 //orissa - ganjam
replace border_AP = 1 if state_id==212 & district_id==20 //orissa - gajapati
replace border_AP = 1 if state_id==212 & district_id==29 //orissa - koraput
replace border_AP = 1 if state_id==212 & district_id==30 //orissa - malkangiri
replace border_AP = 1 if state_id==212 & district_id==27 //orissa - rayagada

//used: http://www.mapsofindia.com/districts-india/ (2011)

* Create GLP decile controls and rural population, by round
	*i.) Quintiles of GLP in pre-crisis periods
		
foreach year in 2008 2010{
forvalues x=20 (20) 80 {
	bysort round: egen temp_GLP_rural_`x'=pctile(GLP_`year'_rural) if GLP_`year'_rural > 0, p(`x')
	replace temp_GLP_rural_`x' = 0 if temp_GLP_rural_`x' == .
	egen GLP_`year'_rural_`x' = max(temp_GLP_rural_`x')
	drop temp_GLP_rural_`x'
	gen GLP_`year'_rural_`x'_dum_temp=0 if round==66
	replace GLP_`year'_rural_`x'_dum_temp=1 if GLP_`year'_rural<=GLP_`year'_rural_`x'&round==66
	
	bysort state_dist: egen GLP_`year'_rural_`x'_dum=min(GLP_`year'_rural_`x'_dum_temp)
	
	gen GLP_`year'_rural_`x'_dumX66=GLP_`year'_rural_`x'_dum*(round==66)
	gen GLP_`year'_rural_`x'_dumX68=GLP_`year'_rural_`x'_dum*(round==68)
}
}
		
	*ii.) Population		
gen num_hh_rural_2 = num_hh_rural*num_hh_rural

foreach var of varlist num_hh_rural num_hh_rural_2 {
	gen `var'_dumX66=`var'*(round==66)
	gen `var'_dumX68=`var'*(round==68)
	}
			

keep dist_to_AP categorical_state_name border_AP num_pp* exp_* state_dist round district_id state_id num_hh_rural* GLP*
	* Note: 71 obs with missing round district_id state_id; dropping these as they serve no purpose and break the merge below. 
duplicates tag round district_id state_id, gen(tag)
drop if tag
drop tag
save "${dataworkrep}/toMerge", replace


*** 2) Use HH level data

u "${dataworkrep}/nss_mfi_merged_hh_rural_instr_new", clear
drop if state_name == "andhrapradesh"
merge m:1 round district_id state_id using "${dataworkrep}/toMerge", update replace
erase "${dataworkrep}/toMerge.dta"

* Create month dummies
tostring survey_date, replace
gen month = substr(survey_date, -4 , 2 )
gen year = substr(survey_date, -2, 2)
destring month, replace
destring year, replace

drop if dup64_flag!=.

* Create outcome variables

	*create measure of average daily wage from casual labor per household
	gen hh_dly_wage_casual_labor = hh_wkly_wages_casual_labor/hh_wkly_dys_wrk_casual
	replace hh_dly_wage_casual_labor=. if hh_dly_wage_casual_labor==0
		
*create measure of average daily wage from casual labor per household for men and women between 18 and 45 (55) yrs old, non-public work nic 1
	gen hh_dly_ws_cl_l_pam_np_1 = hh_wkly_ws_cl_l_pam_np_1/hh_wkly_dys_wrk_cl_pam_np_1
	replace hh_dly_ws_cl_l_pam_np_1=. if hh_wkly_ws_cl_l_pam_np_1==0
	
	gen hh_dly_ws_cl_l_pam2_np_1 = hh_wkly_ws_cl_l_pam2_np_1/hh_wkly_dys_wrk_cl_pam2_np_1
	replace hh_dly_ws_cl_l_pam2_np_1=. if hh_wkly_ws_cl_l_pam2_np_1==0
	
	gen hh_dly_ws_cl_l_paf_np_1 = hh_wkly_ws_cl_l_paf_np_1/hh_wkly_dys_wrk_cl_paf_np_1
	replace hh_dly_ws_cl_l_paf_np_1=. if hh_wkly_ws_cl_l_paf_np_1==0
	
	gen hh_dly_ws_cl_l_paf2_np_1 = hh_wkly_ws_cl_l_paf2_np_1/hh_wkly_dys_wrk_cl_paf2_np_1
	replace hh_dly_ws_cl_l_paf2_np_1=. if hh_wkly_ws_cl_l_paf2_np_1==0


*create measure of average daily wage from casual labor per household for men and women between 18 and 45 (55) yrs old, non-public work all nic but 1
	gen hh_dly_ws_cl_l_pam_np_n1 = hh_wkly_ws_cl_l_pam_np_n1/hh_wkly_dys_wrk_cl_pam_np_n1
	replace hh_dly_ws_cl_l_pam_np_n1=. if hh_wkly_ws_cl_l_pam_np_n1==0
	
	gen hh_dly_ws_cl_l_pam2_np_n1 = hh_wkly_ws_cl_l_pam2_np_n1/hh_wkly_dys_wrk_cl_pam2_np_n1
	replace hh_dly_ws_cl_l_pam2_np_n1=. if hh_wkly_ws_cl_l_pam2_np_n1==0
	
	gen hh_dly_ws_cl_l_paf_np_n1 = hh_wkly_ws_cl_l_paf_np_n1/hh_wkly_dys_wrk_cl_paf_np_n1
	replace hh_dly_ws_cl_l_paf_np_n1=. if hh_wkly_ws_cl_l_paf_np_n1==0
	
	gen hh_dly_ws_cl_l_paf2_np_n1 = hh_wkly_ws_cl_l_paf2_np_n1/hh_wkly_dys_wrk_cl_paf2_np_n1
	replace hh_dly_ws_cl_l_paf2_np_n1=. if hh_wkly_ws_cl_l_paf2_np_n1==0


local outcomes "value_cons23 ln_value_cons23 value_cons20 ln_value_cons20 hh_wkly_earn hh_wkly_earn_wrking hh_wkly_dys_wrkd hh_dly_ws_cl_l_pam_np_1  hh_dly_ws_cl_l_pam_np_n1 hh_wkly_earn_wrking_slfemp hh_wkly_earn_wrking_nslfem"


foreach y in `outcomes'{
cap drop `y'_pe
gen `y'_pe = `y' / hh_earners
cap drop `y'_pp
gen `y'_pp = `y' / hh_size
}


lab var value_cons23 "Average monthly expenditures"
lab var ln_value_cons23 "Log of average monthly expenditures"
lab var value_cons20 "Value of expenditures on durables last 365 days"
lab var ln_value_cons20 "Log of value of expenditures on durables last 365 days"
lab var hh_wkly_earn "Household weekly earnings, including benefits"
lab var hh_wkly_earn_wrking "Household weekly earnings from working"
lab var hh_wkly_dys_wrkd "Household weekly days worked"
lab var hh_wkly_dys_wrkd_slfemp "Household weekly days worked in self-employment"
lab var hh_wkly_dys_wrkd_nslfem "Household weekly days worked in non-self-employment"
lab var value_cons23_pe "Average monthly expenditures (per earner)"
lab var ln_value_cons23_pe "Log of average monthly expenditures (per earner)"
lab var value_cons20_pe "Value of expenditures on durables last 365 days (per earner)"
lab var ln_value_cons20_pe "Log of value of expenditures on durables last 365 days (per earner)"
lab var hh_wkly_earn_pe "Household weekly earnings, including benefits (per earner)"
lab var hh_wkly_earn_wrking_pe "Household weekly earnings from working (per earner)"
lab var hh_wkly_dys_wrkd_pe "Household weekly days worked (per earner)"
lab var value_cons23_pp "Average monthly expenditures (per person)"
lab var ln_value_cons23_pp "Log of average monthly expenditures (per person)"
lab var value_cons20_pp "Value of expenditures on durables last 365 days (per person)"
lab var ln_value_cons20_pp "Log of value of expenditures on durables last 365 days (per person)"
lab var hh_wkly_earn_pp "Household weekly earnings, including benefits (per person)"
lab var hh_wkly_earn_wrking_pp "Household weekly earnings from working (per person)"
lab var hh_wkly_dys_wrkd_pp "Household weekly days worked (per person)"
lab var hh_dly_wage_casual_labor "Household daily wage from casual labor"
lab var hh_dly_ws_cl_l_pam_np_1 "HH daily wage casual lab,prime age males,non-pub work,nic 1"
lab var hh_dly_ws_cl_l_pam2_np_1 "HH daily wage casual lab,prime age males <55,non-pub work,nic 1"
lab var hh_dly_ws_cl_l_paf_np_1 "HH daily wage casual lab,prime age females,non-pub work,nic 1"
lab var hh_dly_ws_cl_l_paf2_np_1 "HH daily wage casual lab,prime age females <55,non-pub work,nic 1"
lab var hh_dly_ws_cl_l_pam_np_n1 "HH daily wage casual lab,prime age males,non-pub work,all nic but 1"
lab var hh_dly_ws_cl_l_pam2_np_n1 "HH daily wage casual lab,prime age males <55,non-pub work,all nic but 1"
lab var hh_dly_ws_cl_l_paf_np_n1 "HH daily wage casual lab,prime age females,non-pub work,all nic but 1"
lab var hh_dly_ws_cl_l_paf2_np_n1 "HH daily wage casual lab,prime age females <55,non-pub work,all nic but 1"
lab var hh_wkly_earn_wrking_slfemp "Household weekly earnings from self-employment"
lab var hh_wkly_earn_wrking_nslfem "Household weekly earnings from non-self-employment"
lab var hh_wkly_earn_pct_slfemp "Percent of household weekly earnings from self-employment"

lab var exp_ratioXpost "Exposure ratio > 0 X post"
lab var exp_ratio_dumXpost "Dummy for exposure ratio > 0 X post"


************************************************
************************************************
* Land holdings
************************************************
************************************************
************************************************
* 1. Absolute levels of land
*************************************************
		
*Measures of amount of land, in categories that match round 64
replace hh_land = hh_land/1000 if round!=64
gen hh_land_bins = hh_land if round==64
replace hh_land_bins = 1 if round!=64 & hh_land < .005
replace hh_land_bins = 2 if round!=64 & hh_land <= .01 & hh_land >= .005
replace hh_land_bins = 3 if round!=64 & hh_land <= .2 & hh_land >= .02
replace hh_land_bins = 4 if round!=64 & hh_land <= .4 & hh_land >= .21
replace hh_land_bins = 5 if round!=64 & hh_land <= 1 & hh_land >= .41
replace hh_land_bins = 6 if round!=64 & hh_land <= 2 & hh_land >= 1.01
replace hh_land_bins = 7 if round!=64 & hh_land <= 3 & hh_land >= 2.01
replace hh_land_bins = 8 if round!=64 & hh_land <= 4 & hh_land >= 3.01
replace hh_land_bins = 10 if round!=64 & hh_land <= 6 & hh_land >= 4.01
replace hh_land_bins = 11 if round!=64 & hh_land <= 8 & hh_land >= 6.01
replace hh_land_bins = 12 if round!=64 & hh_land > 8 & hh_land<.

************************************************
* 2. Within-district quantiles of land
*************************************************

gen land_pctile=.

forvalues q=1/99 {
	bysort state_dist round: egen landp_`q'=pctile(hh_land), p(`q')
	replace land_pctile=`q' if hh_land<=landp_`q' & land_pctile==.
	drop landp_`q'
}

la var land_pctile "Gives the HH's pctile rank in the district-round land dist."

gen wage_casual_labor=hh_dly_wage_casual_labor

cap set more off

gen hhdw_cl_pamnp1=hh_dly_ws_cl_l_pam_np_1
gen hhdw_cl_pamnpn1=hh_dly_ws_cl_l_pam_np_n1

lab var hhdw_cl_pamnp1 "HH daily wage casual lab,prime age males,non-pub work,nic 1"
lab var hhdw_cl_pamnpn1 "HH daily wage casual lab,prime age males,non-pub work,all nic but 1"


* Create a proxy for non-ag biz
gen hh_biz_nonag = hh_self_emp_non_ag_dum

bysort state_id district_id round: egen dist_val_cons23=mean(value_cons23)
sort round state_id district_id 
gen new_dist = state_dist[_n]~=state_dist[_n-1]

sum dist_val_cons23 if new_dist==1 & round==66, d
*median = 4427.328 
gen dist_val_cons23_r66 = dist_val_cons23 if new_dist==1 & round==66
gen poor50 = (dist_val_cons23<=  4427.328 ) if new_dist==1 & round==66

bysort state_id district_id: egen dist_cons_66 = max(dist_val_cons23_r66) 
bysort state_id district_id: egen poor50_66 = max(poor50) 

gen poor50_66Xemp_dumXpost=poor50_66*exp_ratio_dumXpost
la var poor50_66Xemp_dumXpost "Pov in rd 66*dummy exp*post"

gen pbo_exp_ratioXpost 	= exp_ratio*(round==66)
gen pbo_exp_ratio_dumXpost= exp_ratio_dum*(round==66)

gen region=0
replace region=1 if state_name=="westbengal" | state_name=="bihar" | state_name=="jharkhand" | state_name=="orissa" | state_name=="chhattisgarh" 
replace region=2 if state_name=="assam" | state_name=="meghalaya" | state_name=="sikkim" | state_name=="tripura" 
replace region=3 if state_name=="karnataka" | state_name=="kerala" | state_name=="pondicherry" | state_name=="tamilnadu" 
replace region=4 if state_name=="gujarat" | state_name=="maharashtra" | state_name=="madhyapradesh" | state_name=="rajasthan" 
replace region=5 if state_name=="punjab" | state_name=="haryana" | state_name=="uttarpradesh" | state_name=="chandigarh" | state_name=="uttaranchal" 


save "${dataworkrep}/HH_regression_data.dta", replace

egen stateXround=group(state_n round)
egen state_i=group(state_n) 
	* state dummies

	
//For first stage
gen GLP_panel_FS = 0
replace GLP_panel_FS = GLP_2008 if round==64
replace GLP_panel_FS = GLP_2010 if round==66
replace GLP_panel_FS = GLP_2012 if round==68
gen GLP_panel_FS_phh = GLP_panel_FS/num_hh_rural 

replace  GLP_panel_FS= GLP_panel_FS/100000
label var GLP_panel_FS "Gross loan portfolio in lakhs (100,000 INR)"


//QUINTILES OF HH SIZE
xtile hh_size_pctile=hh_size, n(5)
gen nadult=hh_size-hh_children
gen equivadult=1 + (nadult-1)*0.7 + hh_children*0.5 

gen hh_pc_cons_m=(value_cons23)/hh_size
gen hh_pc_cons_m_ea= value_cons23/equivadult

gen hh_pc_cons_m_ea_64_i=hh_pc_cons_m_ea if round==64
bysort state_dist: egen hh_pc_cons_m_ea_64=mean(hh_pc_cons_m_ea_64_i)
drop hh_pc_cons_m_ea_64_i

gen hh_pc_cons_m_ea_66_i=hh_pc_cons_m_ea if round==66
bysort state_dist: egen hh_pc_cons_m_ea_66=mean(hh_pc_cons_m_ea_66_i)
drop hh_pc_cons_m_ea_66_i

//SHARE BELOW POVERTY LINE
cap drop _m
sort state_name round
merge state_name round using "${dataworkrep}/pov_line_ru.dta"
tab _m
drop _m

gen pov_ea=.

replace pov_ea=1 if sector==1 & hh_pc_cons_m_ea<plr
replace pov_ea=1 if sector==2 & hh_pc_cons_m_ea<plu
replace pov_ea=0 if sector==1 & hh_pc_cons_m_ea>=plr & plr!=.
replace pov_ea=0 if sector==2 & hh_pc_cons_m_ea>=plu & plu!=.

gen pov_ea_64_i=pov_ea if round==64
bysort state_dist: egen pov_ea_64=mean(pov_ea_64_i)
drop pov_ea_64_i

gen pov_ea_66_i=pov_ea if round==66
bysort state_dist: egen pov_ea_66=mean(pov_ea_66_i)
drop pov_ea_66_i

//AVG AG WAGE
gen ag_wage = hh_dly_ws_cl_l_pam_np_1
gen ag_wage_64_i=ag_wage if round==64
bysort state_dist: egen ag_wage_64=mean(ag_wage_64_i)
drop ag_wage_64_i ag_wage

gen ag_wage = hh_dly_ws_cl_l_pam_np_1
gen ag_wage_66_i=ag_wage if round==66
bysort state_dist: egen ag_wage_66=mean(ag_wage_66_i)
drop ag_wage_66_i ag_wage

gen hh_biz_nonag_66_i=hh_biz_nonag if round==66
bysort state_dist: egen hh_biz_nonag_66=mean(hh_biz_nonag_66_i)
drop hh_biz_nonag_66_i



//MONTHLY DURABLES
gen value_cons20_mo = value_cons20/12
la var value_cons20_mo "Value of expenditures on durables last MONTH"


*we first generate poverty according to the rural line:
	gen pov=.
	replace pov=1 if sector==1 & hh_pc_cons_m<plr
	replace pov=1 if sector==2 & hh_pc_cons_m<plu
	replace pov=0 if sector==1 & hh_pc_cons_m>=plr & plr!=.
	replace pov=0 if sector==2 & hh_pc_cons_m>=plu & plu!=.

	
*Generate the Employer variable: recent or general occupation is employer	
	gen hh_is_employer_v1 = max(hh_is_employer, hh_is_employer_us)
		
		
*creating non durable consumption:
	egen nondur_aux = rowtotal(value_cons17 value_cons18 value_cons19),missing
	replace nondur_aux = nondur_aux/12
	egen value_nondurables = rowtotal(value_cons16 nondur_aux),missing
	drop nondur_aux
	lab var value_nondurables "Nondurable Monthly Consumption"
	
	*generate total consumption only when both components are non-missing:
	replace value_cons23 = . if value_nondurables==. | value_cons20_mo==.
	
	*similarly, we exclude poverty if missing the non-durable consumption data:
	replace pov = . if value_nondurables==. | value_cons20_mo==.	

*WINSORIZE CONS VARS
global y_cons_win "value_cons23 value_nondurables value_cons20_mo" //Don't winsorize pov (binary)

foreach y in $y_cons_win {

gen `y'_win1=`y'
su `y', detail
replace `y'_win1 = `r(p99)' if `y'>`r(p99)' & `y'<. 

sum `y'_win1

global y_cons_win_all "$y_cons_win_all `y'_win1"
global y_cons_win_all2 "$y_cons_win_all2 `y'_win12"
global y_cons_win_all3 "$y_cons_win_all3 `y'_win13"

}

*For durables, do the COP 99th pctile.
cap n drop value_cons20_mo_win1 

local y value_cons20_mo

gen `y'_win1=`y'
su `y' if `y'>0, detail
replace `y'_win1 = `r(p99)' if `y'>`r(p99)' & `y'<. 

*WINSORIZE EARNINGS
gen hh_wkly_earn_win1=hh_wkly_earn
su hh_wkly_earn if hh_wkly_earn>0, detail
replace hh_wkly_earn_win1 = `r(p99)' if hh_wkly_earn>`r(p99)' & hh_wkly_earn<. 

*compress
save "${dataworkrep}/HH_regression_data_prepped.dta", replace

*********************************************

* Additional exposure measures and variables:
gen exp_ratioX64=0
replace exp_ratioX64=exp_ratio if round==64

gen  exp_ratio_dumX64=0
replace exp_ratio_dumX64 = exp_ratio_dum if round==64

cap gen value_nondurables = value_cons23 - value_cons20_mo

*collapsing by district X round:

 collapse (sum) GLP_panel_FS GLP_panel_FS_phh /// First stage dep variables
exp_ratio exp_ratioXpost exp_ratio_dum exp_ratio_dumXpost /// Exposure vars
month hh_size num_hh_rural_dumX6* num_hh_rural_2_dumX6* num_hh_rural /// "demographic" controls
GLP_2008_rural_*_dumX6* GLP_2010_rural_*_dumX6* GLP_2010_rural GLP_2008_rural hh_dly_ws_cl_l_pam_np_1 hh_dly_ws_cl_l_pam_np_n1 hh_wkly_earn value_nondurables value_cons20_mo value_cons23 /// left-hand variables (for balance tables)
hh_pc_cons_m_ea_66 hh_pc_cons_m_ea_64 /// controls_new
(rawsum) weight (first) district_name district_id state_name state_id dist_to_AP border_AP ///
[pweight=weight], by(state_dist round)


foreach x in GLP_panel_FS GLP_panel_FS_phh month hh_size num_hh_rural_dumX66 num_hh_rural_dumX68 num_hh_rural_2_dumX66 num_hh_rural ///
exp_ratio exp_ratioXpost exp_ratio_dum exp_ratio_dumXpost ///
num_hh_rural_2_dumX68 GLP_2008_rural_20_dumX66 GLP_2008_rural_20_dumX68 GLP_2008_rural_40_dumX66 GLP_2008_rural_40_dumX68  ///
GLP_2008_rural_60_dumX66 GLP_2008_rural_60_dumX68 GLP_2008_rural_80_dumX66 GLP_2008_rural_80_dumX68 ///
GLP_2010_rural_20_dumX66 GLP_2010_rural_20_dumX68 GLP_2010_rural_40_dumX66 GLP_2010_rural_40_dumX68  ///
GLP_2010_rural_60_dumX66 GLP_2010_rural_60_dumX68 GLP_2010_rural_80_dumX66 GLP_2010_rural_80_dumX68 GLP_2008_rural GLP_2010_rural ///
hh_pc_cons_m_ea_66 hh_pc_cons_m_ea_64 /// controls_new
hh_dly_ws_cl_l_pam_np_1 hh_dly_ws_cl_l_pam_np_n1 hh_wkly_earn value_nondurables value_cons20_mo value_cons23 {
replace `x'= `x'/weight
}

*now we generate categories for HH size and interview month:

gen hh_size_cat = floor(hh_size)

gen month_cat = floor(month)

*First-stage variables:
label var GLP_panel_FS "District total gross loan portfolio in lakhs (100,000 NR)"
label var GLP_panel_FS_phh "District gross loan portfolio per household (INR)"

// XXX SS: In districtlevel.do authors use a variable called "exposuredum"
// However, it's not being created here. My sense is exposuredum = exp_ratio_dum

gen exposuredum = exp_ratio_dum

save "${dataworkrep}/HH_data_collapsed.dta", replace	

















