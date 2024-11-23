// Define the data path and change directory
global data_path "E:\Apps\StataDataDontRemove\FamilyExpenses"
cd $data_path

// List ODBC data sources (this is just for debugging, can be removed later)
odbc list 
clear

odbc load, table("LFS_RawData")        


