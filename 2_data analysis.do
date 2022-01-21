//data analysis

clear
cap log close
set more off
cap set maxvar 10000

//format output
set cformat %6.2f
set pformat %5.2f
set sformat %6.2f

// install user packages
ssc install mdesc
ssc install conindex

/*
1-missing values  
2-Descriptive statistics
3-Multivariate model creation and checking
3b-Predicted Probabilities
4-Appendix 1: Concentration Index
5-Appendix 2: Sensitivity analysis 

*/


//		1-identify var with missing values and categorize missing values separately for analysis

//check for var with missing values 
mdesc /* Maternal */ yearcat16 mage_recentdelcat firstpreg meducat mediaweekly wealthindex urban region_topo /* ANC */ m42c_1 anc_bp m42d_1 anc_urine m42e_1 anc_blood ancqual m13_1 anc_early m1_1 anc_tetanus m14_1 anc_vis ancloccat /* Delivery */ deloccat del_sba m17_1 csec /* Postnatal */ m19_1 lowbirthwt pp24 m70_1 m71_1 m72_1 if livebirthhbv==1 
//var w missing values == anc_early anc_tetanus anc_vis ancloccat csec lowbirthwt pp24 
//some var have missing values that reflect 'don't know' responses, including anc_early anc_vis anc_tetanus lowbirthwt
//some var have missing values due to receiving no ANC including anc_early anc_vis ancqual ancloccat anc_tetanus anc_vis

//create copies of all var with missing values, and recode missing values as 999
foreach v of varlist anc_early anc_tetanus anc_vis ancloccat csec lowbirthwt pp24 {
	g `v'_impcat = `v'
	replace `v'_impcat = 999 if `v' == .
	la val `v'_impcat `v'
	}	

//		2-Descriptive statistics

//table 1 - calculate the weighted counts and percentages for the total sample and stratified by vaccination status, and calculate chi-2
foreach v of varlist /* Maternal */ yearcat16 mage_recentdelcat firstpreg meducat mediaweekly wealthindex urban region_topo /* ANC */ ancqual anc_early anc_tetanus anc_vis ancloccat /* Del */ deloccat del_sba csec /* infant */ lowbirthwt pp24 {
	svy, subpop(livebirthhbv): tab `v' vax_recent, count col pearson format(%6.2g) miss
	}	

//check indiv
svy, subpop(livebirthhbv): tab deloccat vax_recent, count col pearson format(%6.2g)
svy, subpop(livebirthhbv): tab del_sba vax_recent, count col pearson format(%6.2g)
	
//calc col % and chi2 for ANC var where 'no anc' is a separate cat 
//recode var 
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus {
	replace `v' = . if `v' == 998
	}
	
//w the above code, no ANC is coded as missing
//tab2 m14_1 anc_vis if livebirthhbv ==1, missing
	
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus {
	svy, subpop(livebirthhbv): tab `v' vax_recent, count col pearson format(%6.2g)
	}
//recode var w 'no anc' so that obs are not dropped in table 2  
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus ancqual {
	replace `v' = 998 if `v' == . & anc_none==1
	}
	
svy, subpop(livebirthhbv): tab pp24 vax_recent, count col pearson format(%6.2g) miss
svy, subpop(livebirthhbv): tab ancloccat vax_recent, count col row pearson format(%6.2g)
	
//we recoded ancqual to be vs any anc OR no anc 
//replace ancqual = 0 if anc_none == 1

//eval ancqual separately bc it's defined as some vs less OR none at all
svy, subpop(livebirthhbv): tab ancqual vax_recent, count col pearson format(%6.2g) miss

//calculate N for all, incl 'no anc' in the total non-missing N
//missing val are excluded from chi2, ie not analyzed as a separate cat
foreach v of varlist /* SES/mat */ yearcat16 mage_recentdelcat meducat region_topo urban wealthindex mediaweekly firstpreg /* ANC */ ancqual anc_tetanus anc_early anc_vis ancloccat /* Del */ deloccat del_sba csec /* infant */ lowbirthwt pp24 {
	svy, subpop(livebirthhbv): tab `v' vax_recent, count col pearson format(%6.2g)
	}	
	
//calc col % and chi2 for ANC var where 'no anc' is a separate cat 
//recode var 
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus {
	replace `v' = . if `v' == 998
	}
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus {
	svy, subpop(livebirthhbv): tab `v' vax_recent, count col pearson format(%6.2g)
	}
//recode var w 'no anc' so that obs are not dropped in table 2  
foreach v of varlist /* ANC */ ancloccat anc_early anc_vis anc_tetanus ancqual {
	replace `v' = 998 if `v' == . & anc_none==1
	}
	
foreach v of varlist yearcat16 /* Maternal */ mage_recentdelcat meducat firstpreg mediaweekly wealthindex urban region_topo  /* Health system */ ancqual anc_early_impcat anc_tetanus anc_vis_impcat ancloccat_impcat deloccat del_sba csec_impcat /* Infant */ lowbirthwt_impcat {
	svy, subpop(livebirthhbv): tab `v' vax_recent, count row pearson format(%6.1g)
	}
	
//if women did not receive ANC, recode var to 'no ANC'
foreach v of varlist anc_early anc_tetanus ancloccat anc_vis {
	replace `v' = 998 if anc_none == 1
	la def `v' 998 "No ANC", modify
	}	
tab anc_vis , miss

//label data that is missing due to no ANC as a separate category
	
foreach v of varlist ancloccat anc_early anc_vis anc_tetanus csec lowbirthwt pp24 {
	g `v'_impcat = `v'
	replace `v'_impcat = 999 if `v' == .
	la val `v'_impcat `v'
	}	
	
//create a label for 'no anc' so that variables with values that are missing due to no ANC can be categorized separately
la def ancqual 999 "Missing", modify
la def anc_early 999 "Missing", modify
la def ancloccat 999 "Missing", modify
la def anc_vis 999 "Missing", modify
la def anc_tetanus 999 "Missing", modify
la def csec 999 "Missing", modify
la def lowbirthwt 998 "Not measured" 999 "Missing", modify
la def pp24 999 "Missing", modify

//csec will be only imputed w this option - same for both 
//for var w data missing due to no ANC: (ancqual is the only w no true missing data)
//prevent ppl w/o any ANC from being coded as missing 
//even if they said dk, don't code them as missing 
//defining ancqual as qual vs less qual OR no anc at all, so it doesn't need a separate category 
//but this does not account for svy weights , so = obs/participants rather than the weighted sample 

//for ANC var, check to see if they had any ANC
svy, subpop(livebirthhbv): tab anc_time anc_none, count col miss  
svy, subpop(livebirthhbv): tab anc_early anc_none, count col miss  
// 192 rly missing 
svy, subpop(livebirthhbv): tab ancloccat anc_none, count col miss //178 rly missing 
svy, subpop(livebirthhbv): tab anc_vis anc_none, count col miss
//200 rly missing
svy, subpop(livebirthhbv): tab anc_tetanus anc_none, count col miss  
// 57 rly miss  
svy, subpop(livebirthhbv): tab ancqual anc_none, count col miss  
//0 rly missing - don't need to impute 
svy, subpop(livebirthhbv): tab csec, count col miss  
// 12 rly miss
svy, subpop(livebirthhbv): tab lowbirthwt, count col miss  // 1754 = 50pc miss, but some were not measured, so ok to use MI but don't impute manually w the mean - can't relabel the 'not measured' as a sep category in the binary var, bc they MI will impute 'don't know' into 'not measure' - ergo need to recode with 'not measured' after MI using birthwt below
svy, subpop(livebirthhbv): tab birthwt, count col miss  
// - only 297 rly missing, 8pc 

svy, subpop(livebirthhbv): tab pp24, count col miss  
// 823 missing 
//based on
svy, subpop(livebirthhbv): tab m70_1, count col miss  
//3 ppl w dk for pp check at all 
svy, subpop(livebirthhbv): tab m71_1, count col miss  
//16 ppl dk re timing 
//and the rest truly missing 

//replace var that are missing not at random 	
//replace for ancqual, bc it will not be imputed 

//calc N for each var - n incl ppl w/o ANC, bc the col % reflect the whole sample, but excl ppl w missing data (+incl missing data dt dk responses, UNLESS that person had no ANC, in which case they are not actually dk, and they are counted in the whole sample - ie the dk responses should not be counted as missing unless they got some ANC - however, we don't want to impute a missing value to be labeled as 'no ANC' so dk values are initially coded as missing regardless of ANC status, and then recoded as no ANC after imputation - so for this N calculation, the ppl w no ANC need to be recoded as non-missing as well)
//use consistent col % for N, ie all non-missing data, regardless of whether or not they got ANC
//however-since I'm defining the var in the text as 'among women who got any anc' (except for ancqual), the col % should excl ppl w/o anc 
foreach v of varlist anc_early ancloccat anc_vis anc_tetanus {
	tab2 `v' anc_none, miss
    tab2 `v'_impcat anc_none, miss
	}	
tab ancqual anc_none, miss

//confirm current coding system 
tab2 ancloccat anc_none, miss
tab2 ancloccat_impcat anc_none, miss
//no anc is separate from missing and from other categories in the orig data before labeling missing separately - that's perfect 

//check for non-ANC var too - 
//lowbirthweight dk/not measured/missing were all labeled togethe
foreach v of varlist csec lowbirthwt pp24 {
	tab `v' if livebirthhbv, miss
    tab `v'_impcat if livebirthhbv, miss
	}

//		3-Multivariate modeling

// Rank predictors with univar logistic 
	
foreach v of varlist csec_impcat mediaweekly yearcat16 firstpreg anc_tetanus_impcat pp24_impcat {
	svy, subpop(livebirthhbv): logistic vax_recent i.`v'
	}
	
/* 	ranked addtl pot pred: criteria = p<0.2

csec 4.42
mediaweekly 2.35
yearcat16 0.25
firstpreg 1.63
pp24_impcat // excl for p > 0.2?
tetanuc 1.11

*/

//	Allen cady backwards modified selection using univariate Wald testing to identify the lowest-ranked predictor
// add all potential additional predictor variables 

svy, subpop(livebirthhbv): logistic vax_recent /* maternal */ i.mage_recentdelcat i.meducat  i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.deloccat i.del_sba   /* infant */ i.lowbirthwt_impcat /* addtl */ i.csec_impcat i.mediaweekly i.yearcat16  

/* 	ranked addtl pot pred

csec 4.42
mediaweekly 2.35
yearcat 0.25
firstpreg 1.63
tetanus 1.11

*/

/* model checking */
	
//VIF test
qui regress vax_recent i.yearcat16 /* maternal */ i.mage_recentdelcat i.meducat i.mediaweekly i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.deloccat i.del_sba  i.csec_impcat /* infant */ i.lowbirthwt_impcat if livebirthhbv==1 [pweight=wtval]
estat vif

//Link test
qui svy, subpop(livebirthhbv): logistic vax_recent i.yearcat16  /* maternal */ i.mage_recentdelcat i.meducat i.mediaweekly i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.deloccat i.del_sba i.csec_impcat /* infant */ i.lowbirthwt_impcat
linktest, nolog

//GOF test
svylogitgof

//final model for comparison to MI  
svy, subpop(livebirthhbv): logistic vax_recent i.yearcat16  /* SES/mat */ i.mage_recentdelcat i.meducat  i.urban i.wealthindex i.mediaweekly  /* ANC */ i.ancloccat_impcat i.anc_early_impcat i.anc_vis_impcat i.ancqual /* Del */ i.deloccat i.del_sba /* infant */ i.csec_impcat i.lowbirthwt_impcat    

//		3b-predicted probabilities using marginal effects at representative values (MER)

//best vs worse healthcare/delivery 
//g var for home del 
tab deloccat, nol
recode deloccat 0/2=0 3=1, g(del_home)
tab2 deloccat del_home if livebirthhbv, miss

qui svy, subpop(livebirthhbv): logistic vax_recent  i.yearcat16  /* SES/mat */ i.mage_recentdelcat i.meducat i.mediaweekly i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.del_home i.del_sba  i.csec_impcat /* infant */ i.lowbirthwt_impcat 

//best 
margins, at(ancqual=1 anc_early_impcat=1 anc_vis_impcat=2  ancloccat_impcat=2 del_home=0 del_sba=1) asobserved vce(unconditional) subpop(livebirthhbv)
//worst 
margins, at(ancqual=0 anc_early_impcat=998 anc_vis_impcat=998 ancloccat_impcat=998 del_home=1 del_sba=0) asobserved vce(unconditional) subpop(livebirthhbv)

//test the difference bt margins
qui margins /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.del_home i.del_sba, post asobserved vce(unconditional) subpop(livebirthhbv)
margins, coeflegend
test _b[0bn.del_home] = _b[1.del_home]	

//maximal benefits 
qui svy, subpop(livebirthhbv): logistic vax_recent  i.yearcat16  /* SES/mat */ i.mage_recentdelcat i.meducat i.mediaweekly i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.anc_early_impcat i.anc_vis_impcat i.ancloccat_impcat /* Del */ i.del_home i.del_sba  i.csec_impcat /* infant */ i.lowbirthwt_impcat 
margins, at(meducat=3 wealthindex=5 urban=1 mediaweekly=1 region_topo=0 ancqual=1 anc_early_impcat=1 anc_vis_impcat=2  ancloccat_impcat=1 del_home=0 del_sba=1) asobserved vce(unconditional) subpop(livebirthhbv)


//		4-Appendix 1: Concentration Index
//ranking the outcome by a) wealth index and b) maternal education

//Erreygers
conindex vax_recent, svy rankvar(meducat) truezero limits (0 1) bounded erreygers
conindex vax_recent, svy rankvar(wealthindex) truezero limits (0 1) bounded erreygers

//Wagstaff
//use cont edu var 
conindex vax_recent if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff graph
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//use continuous var for wealthindex 
conindex vax_recent if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff graph
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)

//CI 

//using outcome of basic ANC
//recode ancqual to 0/1 
recode ancqual 998=., g(ancqual_ci)
conindex ancqual_ci if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//using outcome of home del
conindex del_home if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//g var for fac del //wealth 
recode del_home 0=1 1=0, g(del_fac)
conindex del_fac if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
conindex del_fac if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//using outcome of media use //wealth 
conindex mediaweekly if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//using outcome of media use //wealth 
conindex mediaweekly if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//csec //wealth
conindex csec if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//csec //edu
conindex csec if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//region_topo > central/coastal (SS) vs others
recode region_topo 0 3 = 0 1 2 = 1, g(region_centralcoast)
tab region_topo region_centralcoast
//region_topo  // wealth
conindex region_centralcoast if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//region_topo  // mat edu 
conindex region_centralcoast if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//ancqual  // wealth
conindex ancqual if livebirthhbv, svy rankvar(v190a) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)
//ancqual  // mat edu 
conindex ancqual if livebirthhbv, svy rankvar(v133) truezero limits (0 1) bounded wagstaff 
di "CI: 0" round(r(CI), .01) "  SE: 0" round(r(CIse), .01)


//		5-Appendix 2: Sensitivity analysis 

//appendix table for sensitivity analysis, restricting vaccinated to only those infants w documentation on their health cards
//g var for more narrow def of outcome, based on vax card alone w/o maternal report
tab h50_1 if livebirthhbv, miss
tab h50_1 if livebirthhbv, miss nol
g vax_recentcard = .
replace vax_recentcard = 0 if h50_1 == 0 | h50_1 == 2 | h50_1 == 8
replace vax_recentcard = 1 if h50_1 == 1 | h50_1 == 3
tab h50_1 vax_recentcard if livebirth, miss

//definition of outcome and categories of evidence
svy, subpop(midx_1): tab h50_1 vax_recent, count col row miss format(%6.1g)

//sensitivity analysis
foreach v of varlist /* SES/mat */ yearcat16 mage_recentdelcat meducat wealthindex urban  region_topo mediaweekly /* ANC */ ancqual  anc_vis_impcat ancloccat_impcat /* Del */ deloccat del_sba csec_impcat /* infant */ lowbirthwt_impcat anc_early_impcat {
	svy, subpop(livebirthhbv): tab `v' vax_recentcard, count row pearson format(%6.3g)
	}

	foreach v of varlist /* SES/mat */ yearcat16 mage_recentdelcat meducat wealthindex urban  region_topo mediaweekly /* ANC */ ancqual  anc_vis_impcat ancloccat_impcat /* Del */ deloccat del_sba csec_impcat /* infant */ lowbirthwt_impcat anc_early_impcat {
	svy, subpop(livebirthhbv): logistic vax_recentcard i.`v'
	}
	
//model 1 for sensitivity analysis 
svy, subpop(livebirthhbv): logistic vax_recentcard i.yearcat16 /* SES/mat */ i.mage_recentdelcat i.meducat i.wealthindex i.urban i.region_topo

//model 2 for sensitivity analysis 
svy, subpop(livebirthhbv): logistic vax_recentcard i.yearcat16  /* SES/mat */ i.mage_recentdelcat i.meducat i.mediaweekly i.wealthindex i.urban i.region_topo /* ANC */ i.ancqual i.ancloccat_impcat i.anc_early_impcat i.anc_vis_impcat /* Del */ i.deloccat i.del_sba i.csec_impcat/* infant */ i.lowbirthwt_impcat
	
	



