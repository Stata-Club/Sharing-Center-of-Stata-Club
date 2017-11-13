clear
set more off
cd g:/temp
use cnstock13.dta,replace
sort  stkcd
destring stkcd,replace
levelsof stkcd,local(stkcd)
foreach c of local stkcd {
while length("`c'")<6 {

cap local c= "0"+"`c'"
		     }

dis "`c'"

local p=0
forval page = 1/40 {

cap copy "http://vip.stock.finance.sina.com.cn/corp/view/vCB_AllBulletin.php?stockid=`c'&Page=`page'" "g:/temp.txt", replace

cap infix strL var 1-200000 using g:/temp.txt, clear
*keep if index(var,"&nbsp;<a target='_blank' href='")
cap keep if index(var,`"a target='_blank' href='/corp/view/vCB_AllBulletinDetail.php?stockid="')

if _N==0{
	 continue,break
	 }


split var,p("</a><br>")
drop var
sxpose, clear /*be sure to install sxpose, ssc install sxpose*/
drop in -1
rename _var1 var
split var,p("&nbsp;<a target='_blank' href='" `"'>"') 

drop var 
rename var1 date 
rename var2 url 
rename var3 title
replace url = "http://vip.stock.finance.sina.com.cn"+url
gen stkcd=`c'

save g:/temp/`c'_`page',replace 
local p = `p'+1
}



disp `p'
drop _all
}
}

forval page=1/`p' {
append using d:/temp/`c'_`page'

}

gen stkcd = `c'

save d:/temp/`c',replace 
}
