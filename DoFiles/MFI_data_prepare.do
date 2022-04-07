**********************************************************************************************
*
* Prepare MFI data - clean names, generate exposure measures
*
* NOTE: input file "MFI_Cleaned.dat" contains identified information about the contributing MFIS and cannot be shared publicly. The do file is for reference to provide details about the construction of the exposure measures.  
* The data output of this do file contains no identifiable MFI-level information and has been made available. 
*
*********************************************************************************************


cd "$topdir"
* Load MFI data file.  Observations at the MFI x District x Time level.
use "MFI_Cleaned.dta",clear
do "mfi_clean_names.do"

*** Create exposure variable

format GLP %20.4f
sort Year Month MFI state district branch
collapse (sum) GLP AC LA PAR* Total (mean) secure, by(state district Year Month MFI)

* 5259 MFI x district x time observations 

* Total_PF: total portfolio loan by MFI by particular Year & month
	bys Year Month MFI: egen Total_PF = sum (GLP)
	format Total_PF %20.4f

* AP_PF: Portfolio loan invested by MFI in AP state by Year & Month
	* if state=="andhrapradesh"
	bys Year Month MFI: egen AP_PF = sum (GLP) if state=="andhrapradesh"
	format AP_PF %20.4f

	replace AP_PF=0 if AP_PF>=.
	
* APtemp = AP_PF with missing values replaced by "0"
	rename AP_PF APtemp

* AP_PF: maximum investment made by an MFI in Andhra Pradesh by Year & Month
	bys Year Month MFI: egen AP_PF = max (APtemp) 

* FracAP: maximum investment by MFI in AP divided by total investment by Year & Month
	gen FracAP = AP_PF/Total_PF

* APPretemp: in Sep 2010, maximum investment by MFI in AP divided by total investment
	gen APPretemp = FracAP if (Month==1 & Year==2010)

* FracAPPre: maximum value of APPretemp by MFI level
	bysort MFI: egen FracAPPre= max (APPretemp)

* in Muthoot and Satin file, manage for missing values
	replace FracAPPre=0 if FracAPPre>=. & MFI=="Muthoot"
	replace FracAPPre=0 if FracAPPre>=. & MFI=="Satin"

* Calculate ExpDistAPPre: Exposure of a district to AP before the crisis
* generated temp variable using FracAPPre (explained before)
	gen temp=(GLP*FracAPPre)
	replace temp=0 if temp>=.
	bysort district Year Month: egen temp1 = sum (temp)
	
* Nonzero only for Sep 2010 observations (Pre-crisis i.e. just before crisis)
	replace temp1 = 0 if Month==0
		* Month is 1 only for round 66 - sept 2010
	bysort district: egen ExpDistAPPre = max (temp1)
	
* ExpDistAPPre representation format: 20 digits and then upto 2 places of decimals
	format ExpDistAPPre %20.2f

* Calculate GLPAPPre (likewise)
	gen tempo = GLP
	replace tempo=0 if tempo>=.
	bysort district Year Month: egen tempo1 = sum(tempo)
	
	replace tempo1 = 0 if (Month==0)
	bysort district: egen GLPAPPre = max(tempo1)
	format GLPAPPre %20.2f

	gen ExpRatio = (ExpDistAPPre/GLPAPPre)
	replace ExpRatio=0 if missing(ExpRatio)


gen GLPpos=(GLP>0)
replace GLPpos=0 if missing(GLP)


collapse (max) ExpRatio (sum) numMFI=GLPpos GLP, by (Year Month state district)

foreach var in numMFI GLP {
gen temp = `var' if Year==2013
bys state district: egen `var'_2013 = max(temp)
drop temp
gen temp = `var' if Year==2011
bys state district: egen `var'_2011 = max(temp)
drop temp
gen temp = `var' if Year==2012
bys state district: egen `var'_2012 = max(temp)
drop temp
gen temp = `var' if Year==2010
bys state district: egen `var'_2010 = max(temp)
drop temp
gen temp = `var' if Year==2009
bys state district: egen `var'_2009 = max(temp)
drop temp
gen temp = `var' if Year==2008
bys state district: egen `var'_2008 = max(temp)
drop temp
}

gen round = 64 if Year == 2008
replace round = 66 if Year == 2010 & Month == 1
replace round = 68 if Year == 2012
drop if round == .
****************************

* Some districts did not have MFIs during some of the periods so impute zeros
gen state_district = state + " " + district
encode state_district, gen(state_dist)
tsset state_dist round
tsfill, full

** Replace missings with zeros for rounds created with tsfill
foreach var in ExpRatio GLP GLP_2008 GLP_2009 GLP_2010 GLP_2011 GLP_2012 GLP_2013 {
replace `var' = 0 if state==""
}

foreach n in 2008 2009 2010 2011 2012 2013 {
	replace numMFI_`n' = 0 if numMFI ==. & (GLP_`n'==0 | GLP_`n'==.)
}

decode state_dist, gen(state_dist1)
split state_dist1, p(" ")
drop state district
rename state_dist11 state
rename state_dist12 district

drop state_district state_dist state_dist1 

replace Year = 2008 if round==64
replace Month = 0 if round == 64 | round == 66
replace Year = 2010 if round == 66
replace Year = 2012 if round == 68
replace Month = 1 if round == 66

foreach var in numMFI numMFI_2008 numMFI_2009 numMFI_2010 numMFI_2011 numMFI_2012 numMFI_2013 GLP GLP_2008 GLP_2009 GLP_2010 GLP_2011 GLP_2012 GLP_2013 {
gen temp = `var'
drop `var'
bys state district: egen `var' = max(temp)
drop temp
}

bys state district: egen exp_ratio = max(ExpRatio)

drop ExpRatio
* compresses the columns so that to fit more in one screen (Useful command for a big dataset)

compress state
compress district 
		
			
save ${dataworkrep}MFI_Exposure_REPLICATE.dta, replace			
			
