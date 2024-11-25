
// Load and prepare data
clear
cd D:\University\Master\Sem01\Metrics\DataHW1
odbc query "LFS1402"
odbc load, table("LFS_RawData")



// Extract components from pkey
gen year = substr(pkey, 1, 2)
gen state = substr(pkey, 3, 2)
gen urban_rural = substr(pkey, 5, 1)
gen cluster_no = substr(pkey, 6, 3)
gen household_no = substr(pkey, 9, 2)


// Recode variables
rename F2_D17 education
rename F2_D04 gender

gen studied_in_university = inlist(education, "6", "7", "8")

replace gender = "Male" if gender == "1"
replace gender = "Female" if gender == "2"

replace urban_rural = "Urban" if urban_rural == "1"
replace urban_rural = "Rural" if urban_rural == "2"

// question 1
svyset [pweight=IW_Yearly]
asdoc svy: tabulate gender urban_rural if studied_in_university, cell percent save(Q1)


//question 2

// A. distribution of groups
rename F3_D36 UnemployedState

encode UnemployedState, gen(UnemployedState_num)
replace UnemployedState_num = 6 if UnemployedState_num >= 6

label define UnemployedState_lbl 1 ///
	"Currently Working" 2 "Currently in Education" 3 "Housework" ///
    4 "Retired" 5 "Not Retired" 6 "Other" 7 "Other" 8 "Other"

label values UnemployedState_num UnemployedState_lbl

drop UnemployedState
rename UnemployedState_num UnemployedState

graph pie UnemployedState, over(UnemployedState) plabel(_all percent, position(outside))

save "LFS1402.dta", replace

svyset [pweight=IW_Yearly]

collapse (sum) IW_Yearly, by(UnemployedState)
gen proportion = IW_Yearly / sum(IW_Yearly)

graph pie proportion, ///
	over(UnemployedState) ///
	plabel(_all percent, ///
	position(outside) ///
	format(%9.1f)) ///
	title("Share of States for Unemployed")

// excluding currently working group
svyset [pweight=IW_Yearly]
collapse (sum) IW_Yearly if UnemployedState != 1, by(UnemployedState)
gen proportion = IW_Yearly / sum(IW_Yearly)

graph pie proportion, /// 
    over(UnemployedState) /// 
    plabel(_all percent, /// 
    position(outside) /// 
    format(%9.1f)) /// 
    title("Share of States for Unemployed (Excluding Currently Working)")

/// B. Age average in groups
use "LFS1402.dta", clear

rename F2_D07 Age

encode Age, gen(Age_num)
drop Age
rename Age_num Age

save "LFS1402.dta", replace

* Calculate the average of Age for each UnemployedState
collapse (mean) Age [pw=IW_Yearly], by(UnemployedState)
gsort Age
* Display the results
list UnemployedState Age

* Generate a bar chart for the average Age
graph bar Age, over(UnemployedState, label(angle(45))) ///
    bar(1, color("47663B")) ///
	title("Average Age by Unemployed State") ///
    ylabel(, angle(0) format(%9.0f)) /// Set y-axis to integers
    blabel(bar, format(%9.1f))

use "LFS1402.dta", clear
	
// Question 3
rename F3_D13 IsInsured

replace IsInsured = "Insured" if IsInsured == "1"
replace IsInsured = "Not-Insured" if IsInsured == "2"
drop if IsInsured == "&"

save "LFS1402.dta", replace

* Set up survey design with weights
svyset [pweight=IW_Yearly]

* Create a new variable for individuals who are insured and have studied in university
gen insured_and_studied = (IsInsured == "Yes" & studied_in_university == 1)

* Set up survey design with weights
svyset [pweight=IW_Yearly]

* Restrict the analysis to insured individuals
svy: tabulate gender studied_in_university if IsInsured == "Insured", row percent

* Restrict the dataset to insured individuals
gen insured = (IsInsured == "Insured")

** chart
use "LFS1402.dta", clear

* Collapse the data for mean calculation, weighted by survey weights
gen weighted_total = studied_in_university * IW_Yearly

collapse (sum) weighted_total (sum) IW_Yearly, by(gender insured)
keep if insured == 1

gen mean_value= weighted_total/ IW_Yearly

summarize weighted_total
scalar total_weighted_total = r(sum)

summarize IW_Yearly
scalar total_IW_Yearly = r(sum)

* Calculate the total weighted mean
scalar total_mean = total_weighted_total / total_IW_Yearly

* Generate a bar chart for the share of university education by gender
graph bar mean_value, over(gender, label(angle(45))) ///
    bar(1, color("47663B")) ///
    ylabel(, format(%9.1f)) ///
    ytitle("Percentage") ///
    title("Share of University Education Among Insured Individuals") ///
    blabel(bar, format(%9.2f)) ///
    yline(`=total_mean', lcolor(blue) lwidth(medium) lpattern(dash)) ///
    text(`=total_mean' 95 "Total Mean", color(blue) size(small) align(right))
	
// Question 4

use "LFS1402.dta", clear
rename F3_D50 Sector


replace Sector= "Farming" if Sector == "1"
replace Sector = "Industry" if Sector == "2"
replace Sector = "Services" if Sector == "3"

destring F3_D14SAL, generate(t_total_year)
destring F3_D14MAH, generate(t_total_month)
destring F3_D15SAL, generate(tc_total_year)
destring F3_D15MAH, generate(tc_total_month)

gen ExperienceCurrentPosition= t_total_year+ t_total_month/ 12
gen Experience= tc_total_year+ tc_total_month/ 12

	