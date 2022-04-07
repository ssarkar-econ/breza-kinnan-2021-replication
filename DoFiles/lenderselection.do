set more off
*clear all

/***********************
SELECTION INTO THE SAMPLE (Table 1)
***********************/

cd "$topdir"


********************************************************************************
*NOTE THIS FILE CANNOT BE RUN W/O MFI LEVEL BALANCE SHEET DATA
********************************************************************************


use "$dataworkrep/MFI_Cleaned.dta", clear

* Replace State names to Lower-Case
replace state=lower(state) // State names to Lower-case
replace state=subinstr(state," ","",10) // remove " "
replace state=subinstr(state,".","",4)  // remove "."
replace state=subinstr(state,",","",4)  // remove ","
replace state=subinstr(state,"&","",4)  // remove "&"
replace state=subinstr(state,"(","",4)  // remove "("
replace state=subinstr(state,")","",4)  // remove ")"
replace state=subinstr(state,"*","",4)  // remove "*"

* Match: State Names
replace state="jammukashmir" if state=="jammukashmer"
replace state="karnataka" if state=="karnatak"
replace state="uttaranchal" if (state=="uttarakhand" | state=="uttrakhand" | state=="uttarkhand")
replace state="orissa" if state=="odisha"
replace state="pondicherry" if state=="puducherry"
replace state="gujarat" if state=="gujrat"
replace state="chhattisgarh" if (state=="chathisgarh" | state=="chattisgarh")
replace state="karnataka" if state=="karnatka"
replace state="maharashtra" if state=="maharastra"
replace state="haryana" if state=="hariyana"
replace state="chandigarh" if state=="chandigarhut"
replace state="delhi" if state=="newdelhi"
replace state="assam" if state=="asam"
 
* District names to lower case and remove characters
replace district=lower(district)
replace district=subinstr(district," ","",10)
replace district=subinstr(district,".","",4)
replace district=subinstr(district,"-","",4)
replace district=subinstr(district,",","",4)
replace district=subinstr(district,"&","",4)
replace district=subinstr(district,"(","",4)
replace district=subinstr(district,")","",4)
replace district=subinstr(district,"*","",4)
replace district=subinstr(district,"'","",4)

* Match: State Names (corrected)
replace state="uttarpradesh" if district=="bareilly" & state=="uttaranchal"
replace state="uttarpradesh" if district=="saharanpur" & state=="uttaranchal"
replace state="uttarpradesh" if district=="agra" & state=="rajasthan"
replace state="maharashtra" if district=="yavatmal" & state=="andhrapradesh"

* Match: District Names
replace district="" if district==""
replace district="south" if state=="delhi" & district=="southdelhi"
replace district="southwest" if state=="delhi" & district=="southwestdelhi"
replace district="northwest" if state=="delhi" & district=="northwestdelhi"
replace district="bhopal" if district=="bhopalrural" & state=="madhyapradesh"
replace district="hoshangabad" if (district=="hosangabad" | district=="hosangbad") & (state=="madhyapradesh")
replace district="vidisha" if district=="vidhisa" & state=="madhyapradesh"
replace district="ahmadnagar" if district=="ahmednagar" & state=="maharashtra"
replace district="bid" if district=="beed" & state=="maharashtra"
replace district="khordha" if district=="bhubaneswar" & state=="orissa"
replace district="pondicherry" if district=="puducherry"
replace district="karaikal" if district=="karaikkal" & state=="pondicherry"
replace district="ludhiana" if district=="ludhiyana" & state=="punjab"
replace district="kancheepuram" if district=="kanchipuram" & state=="tamilnadu"
replace district="sivaganga" if district=="sivagangai" & state=="tamilnadu"
replace district="toothukudi" if district=="thoothukkudi" & state=="tamilnadu"
replace district="viluppuram" if district=="villupuram" & state=="tamilnadu"
replace district="agra" if district=="agara" & state=="uttarpradesh"
replace district="ambedkarnag" if district=="ambedkarnagar" & state=="uttarpradesh"
replace district="ballia" if district=="balia" & state=="uttarpradesh"
replace district="bulandshahr" if (district=="bulandshahar" | district=="bulandsahar") & state=="uttarpradesh"
replace district="gorakhpur" if (district=="gorakhapur" | district=="barhalganj") & state=="uttarpradesh"
replace district="moradabad" if district=="muradabad" & state=="uttarpradesh"
replace district="shahjahanpur" if district=="shahajahanpur" & state=="uttarpradesh"
replace district="saran" if district=="chapra" & state=="bihar"
replace district="vaishali" if district=="hazipur" & state=="bihar"
replace district="jphulenagar" if state=="uttarpradesh" & (district=="amroha" | district=="jpnagar" | district=="jpnagaramroha")
replace district="tiruvanamalai" if state=="tamilnadu" & district=="tiruvannamalai"
replace district="thiruvallur" if state=="tamilnadu" & district=="tiruvallur"
replace district="thiruvarur" if state=="tamilnadu" & district=="tiruvarur"
replace district="skabirnagar" if state=="uttarpradesh" & district=="santkabirnagar"
replace district="northeast" if state=="delhi" & district=="northeastdelhi"
replace district="north" if state=="delhi" & district=="northdelhi"
replace district="ghaziabad" if state=="uttarpradesh" & (district=="gaziabad" | district=="gazaibad")
replace district="narsimhapur" if state=="madhyapradesh" & district=="narsingpur"
replace district="baleshwar" if state=="orissa" & district=="balesore"
replace district="balangir" if state=="orissa" & district=="bolangir"
replace district="jajapur" if state=="orissa" & district=="jajpur"
replace district="khordha" if state=="orissa" & (district=="khurdha" | district=="khurda")
replace district="nabarangapur" if state=="orissa" & district=="nawrangpur"
replace district="sonapur" if state=="orissa" & district=="sonepur"
replace district="north24-parganas" if state=="westbengal" & district=="north24"
replace district="purbamidnapur" if district=="purbamedinipur" & state=="westbengal"
replace district="south24-parganas" if state=="westbengal" & (district=="south24" | district=="south24parganas")
replace district="hugli" if state=="westbengal" & district=="hoogly"
replace district="barddhaman" if state=="westbengal" & (district=="burwman" | district=="bardhaman" | district=="burdwan")
replace district="srnagarbhadoh" if state=="uttarpradesh" & (district=="bhadohi" | district=="bhodohi")
replace district="nainitalh" if state=="uttaranchal" & (district=="" | district=="")
replace district="pudukkottai" if state=="tamilnadu" & district=="pudukottai"
replace district="tiruvanamalai" if state=="tamilnadu" & district=="thiruvannamalai"
replace district="tiruchirappalli" if state=="tamilnadu" & district=="tiruchirapalli"
replace district="toothukudi" if state=="tamilnadu" & district=="tuticorin"
replace district="puruliya" if state=="westbengal" & district=="purulia"
replace district="bareilly" if state=="uttarpradesh" & district=="barelly"
replace district="saharanpur" if state=="uttarpradesh" & district=="saharnpur"
replace district="hardwar" if state=="uttaranchal" & district=="haridwar"
replace district="amravati" if state=="maharashtra" & district=="amaravathi"
replace district="buldana" if state=="maharashtra" & district=="buldhana"
replace district="gondiya" if state=="maharashtra" & district=="gondia"
replace district="jalgaon" if state=="maharashtra" & district=="jalgoan"
replace district="osmanabad" if state=="maharashtra" & district=="osamanabad"
replace district="sangli" if state=="maharashtra" & district=="sangali"
replace district="solapur" if state=="maharashtra" & district=="sholapur"
replace district="singhbhume" if state=="jharkhand" & district=="eastsinghbhum"
replace district="kodarma" if state=="jharkhand" & district=="koderma"
replace district="chhindwara" if state=="madhyapradesh" & district=="chhindawara"
replace district="dhaulpur" if state=="rajasthan" & district=="dholpur"
replace district="southnimachai" if state=="sikkim" & district=="southsikkim"
replace district="eastgangtok" if state=="sikkim" & district=="eastsikkim"
replace district="raipur" if state=="chhattisgarh" & district=="bhatapara"
replace district="rajnandgaon" if state=="chhattisgarh" & district=="rajnadgaon"
replace district="champarane" if state=="bihar" & district=="purvichamparan"
replace district="saran" if state=="bihar" & district=="sonepur"
replace district="katihar" if state=="bihar" & district=="kathihar"
replace district="anantapur" if state=="andhrapradesh" & district=="ananthapur"
replace district="cuddapah" if state=="andhrapradesh" & district=="kadapa"
replace district="chittoor" if state=="andhrapradesh" & district=="kuppam"
replace district="rangareddi" if state=="andhrapradesh" & district=="rangareddy"
replace district="kendujhar" if state=="orissa" & district=="keonjhar"
replace district="kandhamalphoolbani" if state=="orissa" & district=="kandhamal"
replace district="bangalore" if state=="karnataka" & district=="bangaloreurban"
replace district="nainitalh" if state=="uttaranchal" & (district=="nainital" | district=="nanital")
replace district="kolar" if state=="karnataka" & district=="chikkaballapura" | district=="chikkaballapur"
replace district="chikmagalur" if state=="karnataka" & district=="chikkamagalore"
replace district="davanagere" if state=="karnataka" & (district=="davangere" | district=="devaganere" | district=="devanagere")
replace district="bangalorerural" if state=="karnataka" & (district=="ramanagara" | district=="ramanagaram")
replace district="uttarakannada" if state=="karnataka" & district=="uttarkannada"
replace district="kanniyakumari" if state=="tamilnadu" & district=="kanyakumari"
replace district="thenilgiris" if state=="tamilnadu" & district=="nilgiris"
replace district="thiruvallur" if state=="tamilnadu" & district=="thiruvalluar"
replace district="tiruchirappalli" if state=="tamilnadu" & district=="trichy"
replace district="hazaribag" if state=="jharkhand" & district=="ramgarh"
replace district="dindigul" if state=="tamilnadu" & district=="dindugal"
replace district="anugul" if state=="orissa" & district=="angul"
replace district="puri" if state=="orissa" & district=="purid"
replace district="sambalpur" if state=="orissa" & district=="bhojpur"
replace district="baleshwar" if state=="orissa" & district=="baleswar"
replace district="kawardha" if state=="chhattisgarh" & district=="kabirdham"
replace district="kozhikode" if state=="kerala" & district=="kozhikkode"
replace district="kasaragod" if state=="kerala" & district=="kasargode"
replace district="thiruvananthapuram" if state=="kerala" & district=="trivandrum"
replace district="nashik" if state=="maharashtra" & district=="nasik"
replace district="thane" if state=="maharashtra" & district=="thaned"
replace district="kamrup" if state=="assam" &(district=="kamrupmetro" | district=="kamruprural")
replace district="kaimurbhabua" if state=="bihar" & district=="kaimur"
replace district="bharuch" if state=="gujarat" & district=="ankaleshwar"
replace district="vadodara" if state=="gujarat" & district=="baroda"
replace district="bharuch" if state=="gujarat" & district=="baruch"
replace district="sonipat" if state=="haryana" & district=="sonepat"
replace district="faridabad" if state=="haryana" & district=="palwal"
replace district="hisar" if state=="haryana" & district=="hissar"
replace district="ambala" if state=="haryana" & district=="amblacant"
replace district="belgaum" if state=="karnataka" & district=="belgam"
replace district="bagalkot" if state=="karnataka" & district=="bagalkote"
replace district="chamarajanagar" if state=="karnataka" & district=="chamarajanagara"
replace district="chitradurga" if state=="karnataka" & district=="chithradurga"
replace district="dharwad" if state=="karnataka" & district=="dharwar"
replace district="devanagere" if state=="karnataka" & district=="harihara"
replace district="koppal" if state=="karnataka" & district=="koppala"
replace district="bathinda" if state=="punjab" & district=="bhatinda"
replace district="ajmer" if state=="rajasthan" & district=="ajmeer"
replace district="jaipur" if state=="rajasthan" & (district=="bhahmpuri" | district=="brahmpuri")
replace district="ajmer" if state=="rajasthan" & district=="kishangarh"
replace district="sawaimadhopur" if state=="rajasthan" & district=="sawaimadhavpur"
replace district="ganganagar" if state=="rajasthan" & district=="sriganganagar"
replace district="north24-parganas" if state=="westbengal" & (district=="24parganasnorth" | district=="north24prgs")
replace district="south24-parganas" if state=="westbengal" & (district=="24parganassouth" | district=="south24prgs")
replace district="kochbihar" if state=="westbengal" & district=="coochbehar"
replace district="darjiling" if state=="westbengal" & district=="darjeeling"
replace district="purbamidnapur" if state=="westbengal" & (district=="eastmidnapur" | district=="midnaporeeast")
replace district="hugli" if state=="westbengal" & district=="hooghly"
replace district="maldah" if state=="westbengal" & district=="malda"
replace district="uttardinajpur" if state=="westbengal" & district=="northdinajpur"
replace district="paschimmidnapur" if state=="westbengal" & (district=="paschimmedinipur" | district=="westmidnapore")
replace district="dakshindinajpur" if state=="westbengal" & (district=="southdinajpur" | district=="southdenajpur")
replace district="alappuzha" if state=="kerala" & district=="allapuzha"
replace district="ernakulam" if state=="kerala" & district=="cochin"
replace district="chhindwara" if state=="madhyapradesh" & district=="chindwara"
replace district="hoshangabad" if state=="madhyapradesh" & district=="itarsi"
replace district="narsimhapur" if state=="madhyapradesh" & (district=="narsinghpur" | district=="narsingapur" | district=="narsinghpur" | district=="narshingpur")
replace district="katni" if state=="madhyapradesh" & district=="katani"
replace district="wnimar" if state=="madhyapradesh" & district=="khargone"
replace district="enimar" if state=="madhyapradesh" & district=="khandwa"
replace district="rewa" if (state=="madhyapradesh" | state=="uttarpradesh") & district=="reewa"
replace district="varanasi" if state=="uttarpradesh" & district=="varansi"
replace district="raebareli" if state=="uttarpradesh" & (district=="raibareilly" | district=="raibareliy")
replace district="jphulenagar" if state=="uttarpradesh" & district=="jyotibaphulenagar"
replace district="kanpurnagar" if state=="uttarpradesh" & district=="kanpur"
replace district="firozabad" if state=="uttarpradesh" & district=="ferozabad"
replace district="etah" if state=="uttarpradesh" & district=="etha"
replace district="bijnor" if state=="uttarpradesh" & district=="bijnour"
replace district="ghazipur" if state=="uttarpradesh" & district=="gazipur"
replace district="hathras" if state=="uttarpradesh" & district=="mahamayanagar"
replace district="dehradunh" if state=="uttaranchal" & (district=="dehradun" | district=="dehradoon")
replace district="hardwar" if state=="uttaranchal" & (district=="roorke" | district=="roorkee")
replace district="warangal" if state=="andhrapradesh" & district=="waragal"
replace district="basti" if state=="uttarpradesh" & district=="basticity"
replace district="budaun" if state=="uttarpradesh" & (district=="badaun" | district=="baduan")
replace district="moradabad" if state=="uttarpradesh" & district=="bhimnagar"
replace district="ghaziabad" if state=="uttarpradesh" & (district=="hapur" | district=="panchsheelnagar" | district=="garhmukteshwar")
replace district="muzaffarnagar" if state=="uttarpradesh" & district=="muzafernagar"
replace district="etah" if state=="uttarpradesh" & (district=="kashiramnagar" | district=="kasganj")
replace district="shimoga" if state=="karnataka" & district=="shivmoga"
replace district="gulbarga" if state=="karnataka" & district=="yadgir"
replace district="alappuzha" if state=="kerala" & district=="allepy"
replace district="gurdaspur" if state=="punjab" & district=="pathankot"
replace district="ramanathapuram" if state=="tamilnadu" & district=="ramnad"
replace district="thanjavur" if state=="tamilnadu" & district=="tanjore"
replace state="pondicherry" if state=="tamilnadu" & district=="pondichery"
replace district="tirunelveli" if state=="tamilnadu" & district=="thirunelveli"
replace district="coimbatore" if state=="tamilnadu" & (district=="thiruppur" | district=="tirupur" | district=="tiruppur")
replace district="pondicherry" if state=="pondicherry" & district=="pondichery"
replace district="kurukshetra" if state=="haryana" & district=="krukshetra"

* Fixes for SKS
replace district="aurangabad" if district=="aurangabadofbihar"
replace district="bhojpur" if district=="arrah" & MFI=="Saija"
replace district="vaishali" if district=="hajipur" & MFI=="Saija"
replace district="lakshadweephisarai" if district=="lakhisarai" & state=="bihar"
replace district="champarane" if district=="purbachamparan" & state=="bihar"
replace district="champaranw" if district=="pashchimchamparan"  & state=="bihar"
replace district=subinstr(district,"ofchhattisgarh","",1)
replace district="ahmedabad" if district=="ahmadabad" & state=="gujarat"
replace district=subinstr(district,"ofgujarat","",1)
replace district="dohad" if district=="dahod"
replace district="panchmahals" if district=="panchmahal"
replace district="pakaur" if district=="pakur" & state=="jharkhand"
replace district="singhbhume" if district=="purbasinghbhum"
replace district="singhbhumw" if district=="pashchimsinghbhum"
replace district="chamarajanagar" if district=="chamrajnagar"
replace district="davanagere" if district=="devanagere"
replace district="dakshinakannada" if district=="dakshinkannad"
replace district="uttarakannada" if district=="uttarkannand"
replace district="palakshadweepkad" if district=="palakkad"
replace district="pathanamthitta" if district=="pattanamtitta"
replace district="enimar" if district=="eastnimar"
replace district="wnimar" if district=="westnimar"
replace district=subinstr(district,"ofmaharashtra","",1)
replace district="bargarh" if district=="baragarh"
replace district="baudh" if district=="boudh"
replace district="nabarangapur" if district=="nabarangpur"
replace district="nainitalh" if district=="haldwani"
replace district="garhwal" if district=="paurigarhwal"
replace district="hoshangabad" if district=="hosangbad" & state=="uttarpradesh"
replace state="madhyapradesh" if district=="hoshangabad" & state=="uttarpradesh"
replace district="birbhum" if district=="bhirbhum"
replace district="howrah" if district=="haora"
replace district=subinstr(district, "-", "", 1)
replace state="madhyapradesh" if state=="uttarpradesh" & district=="rewa"
replace district="kheri" if district=="lakhimpurkheri"
replace district="srnagarbhadoh" if district=="santravidasnagar"
replace district="visakhapatnam" if district=="vishakhapatnam" & state=="andhrapradesh"
replace district="debagarh" if district=="deogarh"
replace district="jagatsinghapur" if district=="jagatsinghpur"
replace district="purbamidnapur" if district=="midnapore" & branch=="Panskura"
replace district="purbamidnapur" if district=="midnapore" & branch==" Panskura"
replace district="paschimmidnapur" if district=="midnapore" & branch=="Midnapore"
replace district="paschimmidnapur" if district=="midnapore" & branch==" Midnapore"
replace district="paschimmidnapur" if district=="midnapore" & branch=="Kharagpur"
replace district="paschimmidnapur" if district=="midnapore" & branch==" Kharagpur"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mecheda"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mecheda"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mechada"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mechada"
replace district="purbamidnapur" if district=="midnapore" & branch=="Mechada Bazar"
replace district="purbamidnapur" if district=="midnapore" & branch==" Mechada Bazar"
replace district="sultanpur" if district=="chhatrapatisahujimaharajnagar" & state=="uttarpradesh"
drop if strpos(district, "educational")!=0
drop if strpos(district, "total")!=0
drop if strpos(state, "tobeclo")!=0
drop if strpos(district,"purchased")!=0
drop if strpos(district, "loanstoeducational")!=0

drop if state=="westbengal" & district=="westbengal"
	
* Replace all Delhi districts as one
	
	/* NOTE: Combining all Delhi districts into one - the difference in exposure between the districts as listed is stark
	for the different MFI's: it is either ~28% in the "delhi" district or =0% in the other regions, the average is ~16%
	when combining the two sets - combine for now and revisit*/
	
	replace district="delhi" if state=="delhi"	
	
********************************************************************************
*WE NOW GENERATE EXPOSURE FOR EACH MFI:
********************************************************************************

sort Year Month MFI state district branch
collapse (sum) GLP AC LA PAR* Total (mean) secure, by(state district Year Month MFI)

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

* exp_frac and exp: in Sep 2010, maximum investment by MFI in AP, both as fraction and total
	gen exp_frac_aux = FracAP if (Month==1 & Year==2010)
	gen exp_aux = AP_PF if (Month==1 & Year==2010)

* FracAPPre: maximum value of APPretemp by MFI level
	bysort MFI: egen exp= max (exp_aux)
	bysort MFI: egen exp_frac = max (exp_frac_aux)

*collapsing:
	collapse (max) exp exp_frac (sum) GLP, by (Year Month MFI state district)
	*collapse (mean) exp exp_frac GLP, by (Year MFI state district)
	
*the values in 2010 refer to the pre-crisis period
	drop if Month==0 & Year==2010
	drop Month
	
gen exp_dum=0
replace exp_dum=1 if exp>0

sort MFI Year
	
*generate first year;
		gen first_year = Year
		replace first_year=. if MFI==MFI[_n-1]

*now we can collapse exposure at the MFI level:
collapse (mean) exp_dum exp_frac first_year, by(MFI)
sum
*save:

rename MFI mfiname
tab mfiname

save "$dataworkrep/sampled_mfi.dta", replace

********************************************************************************
*PREPARE MIX DATA
********************************************************************************

use "$dataworkrep/MIX_India.dta", clear
tab mfiname

merge m:1 mfiname using "$dataworkrep/sampled_mfi.dta"
drop if _m==2
rename _m merged

keep if fiscalyear<=2014
keep if fiscalyear>=2007

gen has09_temp=(fiscalyear==2009)
bysort mfiname: egen has09 = max(has09_temp)

drop has09_temp
gen ones=1
bysort fiscalyear: egen num_mfi_yr = sum(ones)



gen legalstatus=0
replace legalstatus=1 if currentlegalstatus=="NBFI"
replace legalstatus=2 if currentlegalstatus=="NGO"

drop if fiscalyear>2012

gen GLP=grossloanportfolio
replace GLP=subinstr(GLP, ",","",6)
destring GLP, replace
replace GLP=0 if GLP==. & age=="New"

preserve
collapse (sum) GLP ones, by(fiscalyear legalstatus)
sort legalstatus fiscalyear

restore

count
keep if has09==1
sort mfiname

merge m:1 mfiname using "$dataworkrep/mergeMFIN_MIX.dta"
drop _merge

gen MFIN = (insample~=.)
replace insample= 0 if insample==.

tab mfiname if insample==1 & merged==1

gen numborr = numberofactiveborrowers
replace numborr = subinstr(numborr, ",","",6)
destring numborr, replace

gen WO = writeoffratio
replace WO = subinstr(WO, "%", "", 1)
destring WO, replace
ren WO WO_orig
gen WO=WO_orig/100

gen avgloanperborr = averageloanbalanceperborrower
replace avgloanperborr = subinstr(avgloanperborr, ",", "", 3)
destring avgloanperborr, replace
destring portfolioatriskgt30days, replace ignore("%")
replace portfolioatriskgt30days  = . if portfolioatriskgt30days  >100 //2 obs
ren portfolioatriskgt30days portfolioatriskgt30_orig
gen portfolioatriskgt30days = portfolioatriskgt30_orig/100

*generate age for insample:
gen age_sample = 2010-first_year

********************************************************************************
*ANALYSIS
********************************************************************************

global size "avgloanperborr numborr borrowersperstaffmember"
global quality "WO portfolioatriskgt30days"


tab mfiname if insample==1

tab first_year if insample==1

label var insample "MFI in the Sample"
label var exp_dum "Exposure to AP"

	*all MFIs:
	
	foreach y in $size $quality {
	
	reg `y' insample if fiscalyear==2009, robust
	gen inreg=e(sample)==1
	sum `y' if inreg==1 & insample==0
	eret2 scalar mn=r(mean)
	eret2 scalar sd=r(sd)
	est sto `y'
	drop inreg
	}
	
	esttab avgloanperborr numborr borrowersperstaffmember WO portfolioatriskgt30days using "$tables/selectionsample.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast label mlabel(none) fragment booktabs keep(insample) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") extracols(6) replace

	
	est clear
	
		
	*only sampled ones, effect of exposure variables:
	
	foreach y in $size age_sample $quality {
	
	reg `y' exp_dum  if fiscalyear==2009, robust
	gen inreg=e(sample)==1
	sum `y' if inreg==1 & exp_dum==0
	eret2 scalar mn=r(mean)
	eret2 scalar sd=r(sd)
	est sto `y'
	drop inreg
	}
	
	esttab avgloanperborr numborr borrowersperstaffmember WO portfolioatriskgt30days age_sample using "$tables/selectionsample_exp.tex", se b(3) noconstant star(* 0.10 ** 0.05 *** 0.01) obslast label mlabel(none) fragment booktabs keep(exp_dum) nolines scalars("mn Control mean" "sd Control SD") nomtitles nonumbers prefoot("\hline") postfoot("\hline") replace
	est clear
