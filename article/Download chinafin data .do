clear
set more off
mkdir d:/chinafin
cd d:/chinafin
cnstock all
levelsof stkcd,local(stkcd)
foreach c of local stkcd{
	chinafin `c'
	}
	
