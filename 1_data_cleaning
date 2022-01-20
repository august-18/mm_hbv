/*
0-clean Myanmar survey
1-svyset
2-gen var (outcome and predictors)	
	2a-outcome, subpopulation
	2b-maternal/infant demographic factors
	2c-ANC factors
	2d-delivery factors
	2e-postnatal factors
	2f-other factors
3-missing values
4-descriptive statistics
*/

clear 
cap set maxvar 10000
set more off

//load data 
use "*/MMIR71FL.DTA"
//use Individual Recode data set. This dataset has one record for every eligible woman as defined by the household schedule. It contains all the data collected in the women's questionnaire plus some variables from the household. Up to 20 births in the birth history, and up to 6 children under age 5, for whom pregnancy and postnatal care as well as immunization and health data were collected, can be found in this file. The unit of analysis (case) in this file is the woman.

//drop var that were not answered in this country's DHS
lookfor "na - "
drop `r(varlist)'

// 1 svyset 
*svy set the data per DHS stats guide - citation is Croft, Trevor N., Aileen M. J. Marshall, Courtney K. Allen, et al. 2018. Guide to DHS Statistics. Rockville, Maryland, USA: ICF. https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.cfm

gen wtval = v005/1000000
la var wtval "DHS weight value"
*g strata var 
clonevar dhs_strata = v023
*svyset
svyset [pweight=wtval], psu(v021) strata(dhs_strata) 

// 2 gen var

//	2a-gen outcome var

//vaccination status
codebook h50_1	
*recode 'don't know' as 'no' 
recode h50_1 (1/3 = 1) (8=0), g(vax_recent)
la var vax_recent "most recent (last) child received HBV birth vax"

//create study sample of women who who had at least 1 live birth in the survey period (last 5 years) AND answered the vaccine question
g livebirthhbv = 0
replace livebirthhbv = 1 if midx_1 == 1 & vax_recent !=.
//midx_1 = most recent/last birth in the last 5 years
//vax_recent != missing means that the vaccine status question was answered either y/d

//check outcome for multiple gestation deliveries 
codebook b0_01 if livebirthhbv ==1
//max mult gestation number for the most recent delivery is 3 in the study sample, and that only applies to 1 child 

*list the vaccine status for all 3 children if the most recent delivery comes from a multi-gestation pregnancy and the vaccine status for the second OR third child is missing, within the study sample
li h50_1 h50_2 h50_3 b0_01 vax_recent if (b0_01 == 2 | b0_01 == 3) & livebirthhbv==1
//for all multi-gestation deliveries, all children had concordant vaccination status or missing data (2 children) 

//	2b maternal/infant demographic factors

*maternal age at most recent birth
g mage_recentdel = int((b3_01-v011)/12)
//create 5-yr age groups for maternal age at most recent delivery
recode mage_recentdel (min/20 = 0) (21/25 = 1) (26/30 = 2) (31/max = 3), g(mage_recentdelcat)
la def mage_recentdelcat 0 "<=20" 1 "21-25" 2 "26-30" 3 ">=31"
la val mage_recentdelcat mage_recentdelcat

*parity
recode v201 2/12=0 , g(firstpreg)
li v201 firstpreg b0_01 in 1/20 if b0_01==0 & v201 != 1 // double check coding of singleton births 
li v201 firstpreg b0_01 b0_02 b0_03 b0_04 if (b0_01==2 | b0_01==3) & v201 != 1 // check twins and triplets

//maternal highest education, categories
recode v133 0=0 1/6=1 6/11=2 12/max=3, g(meducat)
la def meducat 0 "None" 1 "Primary" 2 "Secondary" 3 "Higher"
la val meducat meducat
la var meducat "Highest education"

*urban
recode v102 2 = 0, g(urban)
la var urban "Urban"

*Geographic region, categorized by topographic/ecological regions
clonevar region = v101
recode region (7 12 14=0) (5 8 9 15 = 1) (6 10 11=2) (1/4 13=3), g(region_topo)
la def region_topo 0 "Delta Ayeyarwady/Bago/Yangon" 1 "Central Magway/Mandalay/NayPyiTaw/Sagaing" 2 "Coastal Mon/Rakhine/Tanintharyi" 3 "Hilly Chin/Kachin/Kayah/Kayin/Shan", modify
la val region_topo region_topo

*household wealth index quintiles 
clonevar wealthindex = v190a
la copy V190A wealthindex
la def wealthindex 1 "Poorest" 2 "Poorer" 3 "Middle" 4 "Richer" 5 "Richest", modify
la val wealthindex wealthindex

//birthweight, in kg
tab m19_1
tab2 m19a_1 vax_recent , miss
clonevar birthwt =  m19_1	
//g binary var for underweight at birth (<2500g)
//set unmeasured/don't know to missing
recode m19_1 2500/5000=0 min/2500=1 9996/9998 = ., g(lowbirthwt)	
bysort lowbirthwt: sum m19_1
tab2 lowbirthwt vax_recent , row col chi2

//	2c ANC factors 

//create variable for 'no ANC' for verification
g anc_none = .
replace anc_none = 1 if m2n_1 == 1 // set = 1 if they said they had no ANC provider
replace anc_none = 0 if m14_1 >= 1 & m14_1 < 90 // set == 0 if they reported any number of visits
replace anc_none = 0 if m57a_1 == 1 | m57b_1 == 1 | m57e_1 == 1 | m57f_1 == 1 | m57g_1 == 1 | m57h_1 == 1 | m57i_1 == 1 | m57j_1 == 1 | m57m_1 == 1 | m57n_1 == 1 | m57o_1 == 1 | m57p_1 == 1 | m57s_1 == 1 | m57x_1 == 1 // set == 0 if they received ANC at any location
replace anc_none = 0 if m13_1 >= 1 & m13_1 < 9 // set = 0 if they had a first visit at any point during pregnancy, including during month 9 (19 women)

//anc recommended services (ie 'anc quality')

*BP test m42c_1
clonevar anc_bp = m42c_1
*urine m42d_1
clonevar anc_urine = m42d_1
*blood test m42e_1
clonevar anc_blood = m42e_1

//skilled provider
g anc_sba = .
replace anc_sba = 0 if m2a_1 == 0 & m2b_1 == 0
replace anc_sba = 0 if m2n_1 == 1 //mark no if no ANC provider had been selected, to double check 
replace anc_sba = 1 if m2a_1 == 1 | m2b_1 == 1
la var anc_sba "ANC from SBA (MD/RN/MW/LHV)"

//create composite binary variable for receipt of recommended ANC services, ie ANC quality, vs lesser OR no ANC at all
g ancqual = .
replace ancqual = 0 if anc_bp == 0 | anc_urine == 0 | anc_blood == 0 | (m2a_1 == 0 & m2b_1 == 0)
replace ancqual = 1 if anc_bp == 1 & anc_urine == 1 & anc_blood == 1 & (m2a_1 == 1 | m2b_1 == 1)
replace ancqual = 0 if anc_none == 1
la val ancqual binary

//tetanus
//code 'don't know' as missing

g anc_tetanus = .
replace anc_tetanus = 0 if m1_1 == 0
replace anc_tetanus = 1 if m1_1 >= 1 & m1_1 <= 6
la copy M1_1 anc_tetanus
//la def anc_tetanus 998 "No ANC", modify
la val anc_tetanus anc_tetanus

*ANC first visit in first trimester
//code 'don't know' as missing
recode m13_1 (0/3 = 1) (3/9 = 0) (98 = .), g(anc_early)
la copy M13_1 anc_early
la val anc_early anc_early 

//la def anc_early 998 "No ANC", modify //only needed later - needed for all? only those w missing val?

* number of ANC visits among women who had at least 1 visit - do not create a category for women who had 0 visits
tab m14_1, miss
g anc_vis = .
replace anc_vis = 0 if m14_1 >= 1 & m14_1 < 4
replace anc_vis = 1 if m14_1 >= 4 & m14_1 < 8
replace anc_vis = 2 if m14_1 >= 8 & m14_1 <= 20
la def anc_vis 0 "1-3 visits" 1 "4-7" 2 ">8" 998 "No ANC", modify
la val anc_vis anc_vis
tab2 anc_vis vax_recent, miss

tab2 m14_1 anc_vis, miss 

/*
//recode for MI later 
//code 0 and don't know visits as missing 
recode m14_1 (0 98 = .), g(anc_numvis)
*/

*ANC location
codebook m57?_1

//make exclusive categories 
g ancloccat = .
la def ancloccat 0 "govt hosp only" 1 "govt clinics only" 2 "Private/other facility only" 3 "Home only" 4 "Multiple locations" 998 "No ANC" 
la val ancloccat ancloccat
replace ancloccat = 0 if m57e_1 == 1 & (m57a_1 == 0 & m57b_1 == 0 & m57f_1 == 0 & m57g_1 == 0 & m57h_1 == 0 & m57i_1 == 0 & m57j_1 == 0 & m57m_1 == 0 & m57n_1 == 0 & m57o_1 == 0 & m57p_1 == 0 & m57s_1 == 0 & m57x_1 == 0) //govt hosp only 
replace ancloccat = 1 if (m57f_1 == 1 | m57g_1 == 1 | m57h_1 == 1 | m57i_1 == 1 | m57j_1 == 1) & (m57a_1 == 0 & m57b_1 == 0 & m57e_1 == 0 & m57m_1 == 0 & m57n_1 == 0 & m57o_1 == 0 & m57p_1 == 0 & m57s_1 == 0 & m57x_1 == 0) //govt fac, clinic only
replace ancloccat = 2 if (m57m_1 == 1 | m57n_1 == 1 | m57o_1 == 1 | m57p_1 == 1 | m57s_1 == 1 | m57x_1 == 1) & (m57a_1 == 0 & m57b_1 == 0 & m57e_1 == 0 & m57f_1 == 0 & m57g_1 == 0 & m57h_1 == 0 & m57i_1 == 0 & m57j_1 == 0) // Private/Other fac only 
replace ancloccat = 3 if (m57a_1 == 1 | m57b_1 == 1) & (m57e_1 == 0 & m57f_1 == 0 & m57g_1 == 0 & m57h_1 == 0 & m57i_1 == 0 & m57j_1 == 0 & m57m_1 == 0 & m57n_1 == 0 & m57o_1 == 0 & m57p_1 == 0 & m57s_1 == 0 & m57x_1 == 0) //home only 
replace ancloccat = 4 if anc_none == 0 & ancloccat == . & (m57a_1 == 1 | m57b_1 == 1 | m57e_1 == 1 | m57f_1 == 1 | m57g_1 == 1 | m57h_1 == 1 | m57i_1 == 1 | m57j_1 == 1 | m57m_1 == 1 | m57n_1 == 1 | m57o_1 == 1 | m57p_1 == 1 | m57s_1 == 1 | m57x_1 == 1) //multiple locations 


//		2d-delivery factors
/*
Delivery variables included in DHS surveys in general:

m3a Assistance: Doctor
m3b Assistance: Country specific health professional
m3c Assistance: Country specific health professional
m3g Assistance: Traditional birth attendant
m3h Assistance: Country specific other person
m3k Assistance: Other
m3n Assistance: No one

m15 Place of delivery

m17 csection

*/

//delivery provider
codebook m3?_1  
g del_sba = .
replace del_sba = 0 if m3a_1 == 0 & m3b_1 == 0
replace del_sba = 1 if m3a_1 == 1 | m3b_1 == 1
la var del_sba "PNC from SBA (MD/RN/MW/LHV)"

//delivery location 
labelbook M15_1
g deloccat = .
replace deloccat = 0 if m15_1 == 21
replace deloccat = 1 if m15_1 == 22 | m15_1 == 23 | m15_1 == 24 | m15_1 == 25
replace deloccat = 2 if m15_1 == 31 | m15_1 == 32 | m15_1 == 33 | m15_1 == 36 | m15_1 == 46 | m15_1 == 96
replace deloccat = 3 if m15_1 == 11 | m15_1 == 12
la def deloccat 0 "gov hosp" 1 "gov clinic" 2 "priv/other" 3 "home" 
la val deloccat deloccat
tab2 deloccat vax_recent, miss
		
// csection mode of delivery 
clonevar csec = m17_1
tab2 csec vax_recent, miss
la copy M17_1 csec 
la val csec csec 

//		2e-postnatal factors

//postnatal checkup within 24 hr w/ a SBA
//code 'don't know' as missing 
tab m70_1
tab m71_1 //wi 24h == m71_1 <= 124
tab m72_1
recode m72_1 (11/12 = 1) (13/96=0), g(pp_sba) 
tab2 m72_1 m70_1  if livebirthhbv, miss
g pp24 = .
replace pp24 = 0 if m70_1 == 0 // if no checkup, code as no
replace pp24 = 1 if m70_1 == 1 & m71_1 <= 124 & m72_1 <= 13 // code as yes only if the checkup was within 24hr AND with a SBA
la var pp24 "Skilled postnatal health check wi 24h"
//check 
tab2 m72_1 pp24  if livebirthhbv, miss

	//	double check LR and analysis coding

//replace pp24 = . if m70_1 == 8 & m71_1 == 998 // set missing for MI if don't know if got check AND time is unknown
//replace pp24 = . if m70_1 == 1 & m71_1 == 998 // set missing for MI if got check AND don't know time


//	2f-other factors

//birth year
recode b2_01 2011=0 2012=1 2013=2 2014=3 2015=4 2016=5, g(yearcat16)
la def yearcat16 0 "2011" 1 "2012" 2 "2013" 3 "2014" 4 "2015" 5 "2016"
la val yearcat16 yearcat16
replace yearcat16 = . if livebirthhbv != 1

*media frequency
gen mediaweekly = .
replace mediaweekly = 0 if (v157 == 0 | v157 == 1 ) & (v158 == 0 | v158 == 1 ) & (v159 == 0 | v159 == 1)
replace mediaweekly = 0 if v157 == 1 & v158 == 1 & v159 == 1 
replace mediaweekly = 1 if v157 == 2 | v158 == 2 | v159 == 2 
la var mediaweekly "media use at least once per week"
