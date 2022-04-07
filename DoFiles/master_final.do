set more off
clear all

***********************
* MASTER:
* this file calls all files that generate the data and the tables
***********************

*Set your top-level path here.
global topdir "/Users/shreyasarkar/Dropbox/_UC_Berkeley/Y2Spring/ECON 270B/PSET/"

cd "$topdir"

***************************************
* 1 - SET PATHS AND CONTROL VARIABLES
***************************************
 
global dodir	"ReplicationFiles/DoFiles"
global tables   "ReplicationFiles/Exhibits"
global appendix "ReplicationFiles/Exhibits_appendix"
global dataworkrep	"ReplicationFiles/Data"


global controls "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round"
global pbo_controls "c.hh_pc_cons_m_ea_64#i.round c.casual_wage_64#i.round"

#d ;

*Main;
global controls_M "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round";

*District-level;
global controls_D1 "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round";
global controls_D2 "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round c.num_hh_rural_pct20X6* c.num_hh_rural_pct40X6* c.num_hh_rural_pct60X6* c.num_hh_rural_pct80X6* c.num_hh_pct20X6* c.num_hh_pct40X6* c.num_hh_pct60X6* c.num_hh_pct80X6*  i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round";		


*NSS 70;
*NOTE THAT HERE WE KEEP ONLY MONTHS 1-6;
global controls_70 "
c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round no_accounts_agriculture amt_paper_agriculture no_accounts_dir_fin amt_paper_dir_fin
no_accounts_indirect_fin amt_paper_indirect_fin GLP_2010_rural GLP_2008_rural GLP_2008_rural_20_dum 
GLP_2008_rural_40_dum GLP_2008_rural_60_dum GLP_2008_rural_80_dum GLP_2010_rural_20_dum
GLP_2010_rural_40_dum GLP_2010_rural_60_dum GLP_2010_rural_80_dum value_cons23 value_cons20
hh_wkly_earn_wrking_slfemp hh_wkly_earn_wrking_nslfem hh_wkly_dys_wrkd hh_wkly_dys_wrkd_slfemp hh_wkly_dys_wrkd_nslfem
hh_dly_wage_casual_labor hh_wkly_earn_pct_slfemp c.dist_to_AP if survey_month<7";


*ROBUSTNESS;
global controls_R "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round";
global pbo_controls_R "$pbo_controls_new i.month i.round i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* c.dist_to_AP#i.round";

*ROBUSTNESS, DISTANCE (GET RID OF LINEAR DISTANCE B/C WE ADD OTHER MEASURES);
global controls_Rdist "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round i.month i.hh_size_pctile c.num_hh_rural_dumX6* c.num_hh_rural_2_dumX6* i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6*";


*URBAN;
global controls_urb "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round i.round i.month i.hh_size_pctile c.num_hh_urban_dumX6* c.num_hh_urban_2_dumX6* i.GLP_2008_rural_*_dumX6* i.GLP_2010_rural_*_dumX6* c.dist_to_AP#i.round";

#d cr

*BASELINE BALANCE:
*NOTE: DON'T ADD DISTANCE HERE B/C IT'S THE OUTCOME IN COLS 1 AND 2.
global controls_ag "c.hh_pc_cons_m_ea_66#i.round c.casual_wage_66#i.round c.num_hh_rural_dumX66 c.num_hh_rural_2_dumX66 i.GLP_2008_rural_*_dumX66 i.GLP_2010_rural_*_dumX66"



***********************
* 2 - PREPARE DATA:
***********************

	*1) MFI Data: generate exposure variable
	*do "$dodir/MFI_data_prepare.do"
		* Confidential MFI data, generates "$dodir/MFI_Exposure_REPLICATE"
	
	*2) Merges MFI Data with NSS District and HH-level data:
	do "$dodir/MergeNSS_MFI.do" 

	*3) Prepare the data to be used: 
	do "$dodir/HouseholdDataPrep.do" 
	*Note: creates "${dataworkrep}/HH_regression_data.dta" and "${dataworkrep}/HH_regression_data_prepped.dta" and "${dataworkrep}/HH_data_collapsed.dta"
		
	*4) Prepare the long data:
	do "$dodir/reshape_wages.do"	
	*Makes "${dataworkrep}/HH_regression_data_wage_long.dta" and "${dataworkrep}/avg_casual_wage_66_bydistrict.dta" and "${dataworkrep}/HH_regression_data_wage_long_urban.dta"

	*5) Merge cleaned bank credit data with HH data
	do "$dodir/MergeBank.do"	
	
	*6) Rescale exposure variable and merge in controls_70
	do "$dodir/data_prepare_rescale.do"
	
	*7) Prepare the pre-trend data
	do "$dodir/Pre-trend_Prepare_data.do"
	
	*8) NSS 70 data preparation
	do "$dodir/nss70_prepare.do" 
	

	
***********************
* 3 - TABLES AND FIGURES MASTER:
***********************

	*1) Selection into the sample:
		*Table 1
	*** do "$dodir/lenderselection.do"
	*** calls proprietary data - do file is available but data are not

	*2) District Level Variables (district level first stage (table 3 col 1), and crops):
		*Tables 2 (summary stats: 1st panel), 3 (total lending: Balance sheet)
		****Note: Data for table 3 (district level first stage) is cleaned here
	do "$dodir/districtlevel.do"
	
	*3) Main Household and Worker Level Estimates:
		*Tables 2 (summary stats: 2nd panel), 4 (labor outcomes), 5 (daily wages by sector), 6 (consumption outcomes)
	do "$dodir/Household_regressions.do"	
	
	*4) First Stage and NSS 70 regressions:
		*Tables 2 (summary stats: 3rd panel), 3 (total lending: NSS 70), Table 7 (Investment)
	do "$dodir/HouseholdRegressions_nss70.do"
	
	*5) First Stage Picture (Fig 1: District-level MFI panel)
	do "$dodir/FirstStage_MFIData_Panel.do"
	
	*6) Pre-trend Analysis (Fig 2)
	do "$dodir/Pre-trend_Analysis.do"
	
