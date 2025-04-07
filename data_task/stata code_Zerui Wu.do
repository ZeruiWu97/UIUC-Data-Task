/*
Title: Data Task for Simulation and Analysis
Author: Zerui Wu 
Date: 2025-04-06
*/



* Set the Stata environment
clear all
set scheme s1color
set varabbrev off
cd "/Users/wuzerui/Desktop/UCHICAGO/predoc/Anya Samek (University of California San Diego), Lena Song (University of Illinois Urbana-Champaign), and John List/data_task"	// Please set to the local working directory



********************************************************************************
*********************** Create a baseline survey data **************************
********************************************************************************
	
	* Set a seed for a replilcatable randomization
	set seed 1

	* Set 5000 observations
	set obs 5000

	* Create a unique identifier for each obs
	gen id = _n
	label var id "Identifier"
	
	
	* Create a baseline vaccine take-up data such that the probability of uptake = 0.3, following a bernoulli distribution
	gen vac_takeup0 = runiform() < 0.3 
	label var vac_takeup0 "Vaccine Takeup (Baseline)"	// Label vac_takeup0 variable
	
	* Define values for vbaseline accine dummy 
	label define vac0 0 "Not vaccinated" 1 "Vaccinated"
	label values vac_takeup0 vac0

	
	* Create the baseline age data from 18 to 80, following a uniform distribution
	gen age = runiform(18, 80)
	label var age "Age"		// Label age variable

	
	* Create the baseline gender data (female dummy) such that 0 = male, 1 = female, following a bernoulli distribution
	gen female = runiform() > 0.5
	label var female "Female"		// Label female variable 
	
	* Define values for gender
	label define gender 0 "Male" 1 "Female"
	label values female gender

	
	* Create the baseline education data such that 1 = Less than HS, 2 = HS, 3 = Some college, 4 = College+
	gen u = runiform()

	gen edu = .
	label var edu "Education"	 // Label education variable
	
	replace edu = 1 if u < 0.1         // 10%: Less than HS
	replace edu = 2 if u >= 0.1 & u < 0.4  // 30%: HS
	replace edu = 3 if u >= 0.4 & u < 0.6 // 20%: Some college
	replace edu = 4 if u >= 0.60          // 40%: College+
	
	* Define values for education
	label define education 1 "Less than HS" 2 "HS" 3 "Some college" 4 "College+"
	label values edu education
	
	* Drop the variable u
	drop u
	
	
	* Create a college dummy
	gen college = edu == 4
	label var college "College+"	// label college variable
	
	
	* Save the baseline survey data under `/raw_data/` folder
	save "raw_data/survey_data_baseline.dta", replace 
	



********************************************************************************
************************ Create a randomization data ***************************
********************************************************************************

	clear
	
	* Set 5000 observations
	set obs 5000

	* Create a unique identifier for each obs
	gen id = _n
	label var id "Identifier"
	
	
	* Create a randomization status data such that first ad = 1/3, second ad = 1/3, and control = 1/3
	gen treatment = 1			// Reason
	replace treatment = 2 if id > 1666 & id <= 3333 // Emotions
	replace treatment = 3 if id > 3333 & id <= 5000     // Control

	label var treatment "Treatment"		// Label the variable

	* Define values for treatment status
	label define arms 1 "Reason Ad" 2 "Emotions Ad" 3 "Control"
	label values treatment arms
	
	
	* Save the randomization data under `/raw_data/` folder
	save "raw_data/randomization_data.dta", replace 
	
	
	
********************************************************************************
*********************** Create an endline survey data **************************
********************************************************************************

	clear

	* Set a seed for a replilcatable randomization
	set seed 1
	
	* Set 5000 observations
	set obs 5000

	* Create a unique identifier for each obs
	gen id = _n
	label var id "Identifier"
	
	* Create a temperary baseline vaccine take-up data such that the probability of uptake = 0.3
	gen vac_takeup0 = runiform() < 0.3
	
	* Create a temperary randomization status data such that first ad = 1/3, second ad = 1/3, and control = 1/3
	gen treatment = 1			// Reason
	replace treatment = 2 if id > 1666 & id <= 3333 // Emotions
	replace treatment = 3 if id > 3333 & id <= 5000     // Control

	
	* Generate an endline vaccine uptake dummy, where people in the Reason campaign have a 55% of uptake, 70% in the Emotion campaign, and 30% in the Control group, using a uniform random draw
	gen vac_takeup1 = .
	replace vac_takeup1 = 1 if vac_takeup0 == 1		// Endline takeup dummy is 1 if the obs took the vaccine in the baseline

	gen u = runiform()
	replace vac_takeup1 = 1 if vac_takeup0 == 0 & treatment == 1 & u < 0.55	// The prob. of vaccinetaed is 0.55 for Reasons
	replace vac_takeup1 = 1 if vac_takeup0 == 0 & treatment == 2 & u < 0.7	// The prob. is 0.70 for Emotions
	replace vac_takeup1 = 1 if vac_takeup0 == 0 & treatment == 3 & u < 0.3	// The prob. is 0.30 for Control, assuming as same as baseline
	replace vac_takeup1 = 0 if missing(vac_takeup1)							// Other obs are not vaccinated
	
	label var vac_takeup1 "Vaccine Takeup (Endline)"	// Label the endline vaccine dummy 
	
	* Define values for the endline vaccinated status
	label define vac_end 0 "Not vaccinated" 1 "Vaccinated"
	label values vac_takeup1 vac_end
	
	* Randomly select 4,500 observations from a dataset of 5,000
	sample 4500, count
	
	* Delete irrelevant variables to the question
	drop vac_takeup0 u treatment
	
	* Save the endline survey data under `/raw_data/` folder
	save "raw_data/survey_data_endline.dta", replace 


********************************************************************************
***************************** Merge the Data Set *******************************
********************************************************************************
	
	* Load the baseline survey data as the master dataset 
	use "raw_data/survey_data_baseline.dta", clear 
	
	* Merge with randomization data
	merge 1:1 id using "raw_data/randomization_data.dta"
	
	* Check the result of the merge 
	tab _merge		// All 5,000 data are one-to-one matched
	
	* Drop _merge variable
	drop _merge
	
	* Merge with the endline survey data
	merge 1:1 id using "raw_data/survey_data_endline.dta"
	
	* Check the result of the merge 
	tab _merge		// 4,500 data are one-to-one matched, and 500 are missing from the endline survey
	
	* Drop the obs who are missing endline data and drop irrelevant drop variable
	drop if _merge == 1
	drop _merge
	
	* Save as final clean data under `/clean_data/` folder
	save "clean_data/final_data_clean.dta", replace 
	
	
********************************************************************************
************************** Analyze Treatment Effect ****************************
********************************************************************************	

	* Load the final clean data
	use "clean_data/final_data_clean.dta", clear 
	
	* Balance check
	foreach var in age female vac_takeup0 college {
		oneway `var' treatment, t	// One-way ANOVA tests
	}
	
	* Test whether the proportion of vaccinated individuals (at baseline) differs across the three treatment groups
	tab treatment vac_takeup0, chi2
	/*
	Balance Check: The sample appears well-balanced across the three groups (Reason, Emotions, Control) on key baseline characteristics. For each variable — baseline vaccination status, age, gender (female), and college education — the differences between group means are small and statistically insignificant. One-way ANOVA tests or Chi-squared test yield p-values well above 0.1, indicating no significant differences across treatment groups even at 10% level. Also, Bartlett’s tests confirm homogeneity of variances, supporting the assumption of comparable group distributions. These results suggest that randomization in this simulated data is successful.
	*/
	
	
	* (Endline) Test whether the proportion of vaccinated individuals at endline differs across the three treatment groups
	tab treatment vac_takeup1, chi2
	/*
	Chi-squared test shows that these differences are highly significant — the chances that these differences happened by random luck are basically zero (p < 0.001). This rejects the null hypothesis that the proportions of vaccinated individuals are same for these three groups at endline.
	*/
	
	
	**************************** Figure 1 **************************************
	preserve 
	
	
		* Aggregate the baseline and endline vaccine take-up by treatment status
		collapse (mean) ///
			mean_vac_takeup0 = vac_takeup0 ///
			mean_vac_takeup1 = vac_takeup1 ///
			(sd) ///
			sd_vac_takeip0 = vac_takeup0 ///
			sd_vac_takeip1 = vac_takeup1 ///
			(count) total = id, ///
			by(treatment)
		
		* Compute confidence intervals at the 95% level
		gen se0 = sd_vac_takeip0 / sqrt(total)
		gen se1 = sd_vac_takeip1 / sqrt(total)
		gen tcrit = invttail(total - 1, 0.025)

		gen ci_lower0 = mean_vac_takeup0 - tcrit * se0
		gen ci_upper0 = mean_vac_takeup0 + tcrit * se0
		gen ci_lower1 = mean_vac_takeup1 - tcrit * se1
		gen ci_upper1 = mean_vac_takeup1 + tcrit * se1
		
		
		* Sort the data by treatment status
		gsort treatment
		
		* Bar positions for baseline and endline
		gen pos_0 = treatment - 0.5						// Baseline Reason Ad
		replace pos_0 = pos_0 - 0.5 if treatment == 2	// Baseline Emotions Ad
		replace pos_0 = pos_0 - 1 if treatment == 3		// Baseline Control
		
		gen pos_1 = treatment + 1.5                     // Endline Reason Ad
		replace pos_1 = pos_1 - 0.5 if treatment == 2	// Endline Emotions Ad
		replace pos_1 = pos_1 - 1 if treatment == 3		// Endline Control
		
		* Bar plot of effects of different campaigns
		twoway (bar mean_vac_takeup0 pos_0, color(gs7) barwidth(0.5)) ///
			   (bar mean_vac_takeup1 pos_1, color(gs2) barwidth(0.5)) ///
			   (rcap ci_lower0 ci_upper0 pos_0, lcolor(black) lwidth(medium)) ///
			   (rcap ci_lower1 ci_upper1 pos_1, lcolor(black) lwidth(medium)), ///
			   yscale(r(0 1)) ///
			   ylabel(0(0.1)1, labsize(small) nogrid notick) ///
			   ytitle("Percentage of Vaccine Take-up", size(small)) ///
			   xtitle("Treatment", size(small)) ///
			   xscale(r(0 4)) ///
			   xlabel(0.5 "Reason" 1 "Emotions" 1.5 "Control"  2.5 "Reason" 3 "Emotions" 3.5 "Control", nogrid notick labsize(small)) ///
			   legend(order(1 "Baseline" 2 "Endline") size(small) region(lcolor(black)) row(1) position(6))
		  
		* Save the graph
		graph export "output/figure_bar_graph_treatment_effects.png", replace 
		
	restore 
	
	
	***************************** Table 1 **************************************
	* Linear Probability Regression of endline takeup on treatments with robust SE and Control as base
	reg vac_takeup1 ib3.treatment college female age vac_takeup0, robust
	est store model			// Store the regression results
	
	
	* Customize regression table in Latex format
	esttab model ///
		using "output/table_regression.tex", ///
		unstack ///
		cells(b(star fmt(4)) se(par)) ///
		keep(1.treatment 2.treatment college female age vac_takeup0 _cons) ///
		stats(r2 N, fmt(2 0) ///
			label(R² Observations)) ///
		nobase ///
		label collabels(none) ///
		starlevels(* 0.10 ** 0.05 *** 0.010) ///
		nonotes ///
		replace 
	
	
	***************************** Figure 2 *************************************
	* Plot coefficients for two treatments from regression
	coefplot (model, mcolor(gs1)), ///
		vertical  ///
		keep(1.treatment 2.treatment) ///
		ciopts(recast(rcap) color(gs1)) ///
		levels(95) ///
		yscale(r(0 0.4)) ///
		ylabel(0(0.1)0.4, nogrid labsize(small)) ///
		ytitle("Effects on Probability of Vaccine Take-Up", size(small)) ///
		legend(off)
	
	* Save the plot
	graph export "output/figure_coefficients_treatment_effects.png", replace 
	
	
clear all
