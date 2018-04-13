// 多级json数据的读取
clear
gen str80 id = ""
gen str80 state = ""
gen str80 display_name = ""
gen str80 party = ""

insheetjson id state display_name party using "data.json", ///
    table("votes Present") col("id" "state" "display_name" "party") 
compress

// 将第一级数据的键和值保存为返回值
insheetjson id state display_name party using "data.json", ///
    table("votes Present") col("id" "state" "display_name" "party") topscalars
compress


// 索引中还有空格怎么办？
subinfile data.json , from("Not Voting") to("Not_Voting") save(data1.json) replace

clear
gen str80 id = ""
gen str80 state = ""
gen str80 display_name = ""
gen str80 party = ""

insheetjson id state display_name party using "data1.json", ///
    table("votes Not_Voting") col("id" "state" "display_name" "party")
compress

// 样本追加
clear
gen str80 id = ""
gen str80 state = ""
gen str80 display_name = ""
gen str80 party = ""

insheetjson id state display_name party using "data1.json", ///
    table("votes Not_Voting") col("id" "state" "display_name" "party")
gen statu = "Not_Voting"

insheetjson id state display_name party using "data.json", ///
    table("votes Present") col("id" "state" "display_name" "party") offset(`c(N)')
replace statu = "Present" if statu == ""
compress

