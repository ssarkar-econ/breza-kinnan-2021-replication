set more off
*clear all

/*******************************************************************************
TABLES IN THE PAPER - DISTRICT LEVEL REGRESSIONS
NOTE: THESE REGS HAVE NO WEIGHTS (pweight, etc.)
********************************************************************************/


cd "$topdir/"

*set dependent variable lists:
global y_firstst "GLP_panel_FS_phh"

	
use "$dataworkrep/HH_data_collapsed.dta", clear	
*First-stage (Table 3, col 1) variable:
label var GLP_panel_FS_phh "District gross loan portfolio per household (INR)"
	
********************************************************************************
*FIRST STAGE RESULTS
********************************************************************************

// XXX SS: replaced all exp_ratio_dum with exp_ratio_dum

foreach i in _ratio_dum  {
foreach y in GLP_panel_FS GLP_panel_FS_phh {

areg `y' exp`i' $controls_D1, absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'
}


// XXX SS: GLP_panel_FS_phhdum renamed to GLP_panel_FS_phh_ratio_dum, and phhstd to phhosurestd
// have to comment it out bec too long a name 
esttab GLP_panel_FS_phh_ratio_dum using "$tables/firstst.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exp_ratio_dum) nolines nomtitles nonumbers replace
esttab GLP_panel_FS_phhosurestd using "$tables/firstst.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exposurestd) nolines nomtitles nonumbers postfoot("\hline") append
esttab GLP_panel_FS_phh_ratio_dum using "$tables/firstst.tex", cells(none) scalars("mn Control mean" "sd Control SD") obslast label mlabel(none) nonumbers fragment booktabs postfoot("\hline") append
est clear

*summary statistics on credit
gen GLP_panel_FS_phh_aux = GLP_panel_FS_phh
replace GLP_panel_FS_phh_aux=. if exp_ratio_dum==1
label var GLP_panel_FS_phh_aux "Gross loan portfolio, per rural household (unexposed districts)"

gen GLP_panel_FS_aux = GLP_panel_FS
replace GLP_panel_FS_aux=. if exp_ratio_dum==1
label var GLP_panel_FS_aux "Gross loan portfolio in lakhs (100,000 Rs., unexposed districts)"

gen exp_ratio_aux1=exp_ratio
replace exp_ratio_aux1=. if exp_ratio_dum==0
la var exp_ratio_aux1 "Exposure ratio (exposed districts)"

gen exp_ratio_aux2=exp_ratio
la var exp_ratio_aux2 "Exposure ratio (all districts)"

gen exp_ratio_dum_aux = exp_ratio_dum
la var exp_ratio_dum_aux "Any exposed lender (all districts)"

estpost sum exp_ratio_dum_aux exp_ratio_aux2 exp_ratio_aux1 GLP_panel_FS_aux if round==68 [aweight=weight]
esttab . using "$tables/sum_2.tex", cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2))") ///
 nomtitles label nonumbers nolines noobs fragment booktabs replace ///
posthead("%<*t2>") postfoot("%</t2>")


********************************************************************************/
* Cross-sectional version of Table 3, col 1 (appendix table C.II)
*Outcome is GLP_panel_FS_phh
*******************************************************************************

foreach i in _ratio_dum osurestd {

*Cross-sectional version
reg GLP_panel_FS_phh exposure`i' hh_pc_cons_m_ea_66 casual_wage_66 num_hh_rural_dumX68 num_hh_rural_2_dumX68 i.GLP_2008_rural_*_dumX68 i.GLP_2010_rural_*_dumX68 dist_to_AP if round==68, vce(cluster state_dist)
sum GLP_panel_FS_phh if exp_ratio_dum==0 & GLP_2010_rural>0 & round==68 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg_cs_`i'

*Regular diff in diff version
areg GLP_panel_FS_phh exposure`i' $controls_D1, absorb(state_dist) vce(cluster state_dist)
sum GLP_panel_FS_phh if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg_dd_`i'
}

esttab creg_cs_dum creg_dd_dum using "$appendix/firstst_cross_section.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exp_ratio_dum) nolines nomtitles nonumbers replace
esttab creg_cs_std creg_dd_std using "$appendix/firstst_cross_section.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exposurestd) nolines nomtitles nonumbers postfoot("\hline") append
esttab creg_cs_dum creg_dd_dum using "$appendix/firstst_cross_section.tex", cells(none) scalars("mn Control mean" "sd Control SD") obslast label mlabel(none) nonumbers fragment booktabs postfoot("\hline") append
est clear

}


foreach i in std  {
foreach y in GLP_panel_FS GLP_panel_FS_phh {

areg `y' exp`i' $controls_D1, absorb(state_dist) vce(cluster state_dist)
sum `y' if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto `y'`i'
}


// XXX SS: GLP_panel_FS_phhdum renamed to GLP_panel_FS_phh_ratio_dum, and phhstd to phhosurestd
// have to comment it out bec too long a name 
esttab GLP_panel_FS_phh_ratio_dum using "$tables/firstst.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exp_ratio_dum) nolines nomtitles nonumbers replace
esttab GLP_panel_FS_phhosurestd using "$tables/firstst.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exposurestd) nolines nomtitles nonumbers postfoot("\hline") append
esttab GLP_panel_FS_phh_ratio_dum using "$tables/firstst.tex", cells(none) scalars("mn Control mean" "sd Control SD") obslast label mlabel(none) nonumbers fragment booktabs postfoot("\hline") append
est clear

*summary statistics on credit
gen GLP_panel_FS_phh_aux = GLP_panel_FS_phh
replace GLP_panel_FS_phh_aux=. if exp_ratio_dum==1
label var GLP_panel_FS_phh_aux "Gross loan portfolio, per rural household (unexposed districts)"

gen GLP_panel_FS_aux = GLP_panel_FS
replace GLP_panel_FS_aux=. if exp_ratio_dum==1
label var GLP_panel_FS_aux "Gross loan portfolio in lakhs (100,000 Rs., unexposed districts)"

gen exp_ratio_aux1=exp_ratio
replace exp_ratio_aux1=. if exp_ratio_dum==0
la var exp_ratio_aux1 "Exposure ratio (exposed districts)"

gen exp_ratio_aux2=exp_ratio
la var exp_ratio_aux2 "Exposure ratio (all districts)"

gen exp_ratio_dum_aux = exp_ratio_dum
la var exp_ratio_dum_aux "Any exposed lender (all districts)"

estpost sum exp_ratio_dum_aux exp_ratio_aux2 exp_ratio_aux1 GLP_panel_FS_aux if round==68 [aweight=weight]
esttab . using "$tables/sum_2.tex", cells("count(fmt(0)) mean(fmt(2)) sd(fmt(2))") ///
 nomtitles label nonumbers nolines noobs fragment booktabs replace ///
posthead("%<*t2>") postfoot("%</t2>")


********************************************************************************/
* Cross-sectional version of Table 3, col 1 (appendix table C.II)
*Outcome is GLP_panel_FS_phh
*******************************************************************************

foreach i in _ratio_dum osurestd {

*Cross-sectional version
reg GLP_panel_FS_phh exposure`i' hh_pc_cons_m_ea_66 casual_wage_66 num_hh_rural_dumX68 num_hh_rural_2_dumX68 i.GLP_2008_rural_*_dumX68 i.GLP_2010_rural_*_dumX68 dist_to_AP if round==68, vce(cluster state_dist)
sum GLP_panel_FS_phh if exp_ratio_dum==0 & GLP_2010_rural>0 & round==68 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg_cs_`i'

*Regular diff in diff version
areg GLP_panel_FS_phh exposure`i' $controls_D1, absorb(state_dist) vce(cluster state_dist)
sum GLP_panel_FS_phh if exp_ratio_dum==0 & round==68 & GLP_2010_rural>0 [aweight=weight]
eret2 scalar mn=r(mean)
eret2 scalar sd=r(sd)
est sto creg_dd_`i'
}

esttab creg_cs_dum creg_dd_dum using "$appendix/firstst_cross_section.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exp_ratio_dum) nolines nomtitles nonumbers replace
esttab creg_cs_std creg_dd_std using "$appendix/firstst_cross_section.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) noobs label mlabel(none) fragment booktabs keep(exposurestd) nolines nomtitles nonumbers postfoot("\hline") append
esttab creg_cs_dum creg_dd_dum using "$appendix/firstst_cross_section.tex", cells(none) scalars("mn Control mean" "sd Control SD") obslast label mlabel(none) nonumbers fragment booktabs postfoot("\hline") append
est clear

}
