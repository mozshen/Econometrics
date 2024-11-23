// Define the data path and change directory
global data_path "E:\Apps\StataDataDontRemove\FamilyExpenses"
cd $data_path

// List ODBC data sources (this is just for debugging, can be removed later)
odbc list 
clear

odbc load, table("LFS_RawData")        

gen year = substr(pkey, 1, 2) // First 2 characters: Year
gen state = substr(pkey, 3, 2) // Next 2 characters: State code
gen urban_rural = substr(pkey, 5, 1) // Next 1 character: Urban/Rural indicator
gen cluster_no = substr(pkey, 6, 3) // Next 3 characters: Cluster number
gen household_no = substr(pkey, 9, 2) // Last 2 characters: Household number


// question 1
// renaming column
rename F2_D17 education
rename F2_D04 gender

gen studied_in_university = education == "6" | education == "7" | education == "8"

replace gender = "Male" if gender == "1"
replace gender = "Female" if gender== "2"

replace urban_rural = "Urban" if urban_rural == "1"
replace urban_rural= "Rural" if urban_rural== "2"

svyset [pweight=IW_Yearly]
svy: tabulate gender urban_rural if studied_in_university, cell percent





