clear all 
cd E:\putdocx
fs *.css
disp `"`r(files)'"'
foreach cssname in `r(files)' {
    disp "`cssname'"
	subinfile header.txt ,from(`"href="./.*?\.css"') to(`"href="./`cssname'"') ///
	     fromregex save(header.txt) replace
	dyndoc p18.do,replace
	shellout p18.html

	sleep 10000
	!taskkill /F /IM chrome.exe /T
}
