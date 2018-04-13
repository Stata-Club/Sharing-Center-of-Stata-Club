// 查看json数据
insheetjson using "aqi_gz.json" , showresponse

insheetjson using "aqi_gz.json" , showresponse flatten 

// 以table方式读取数据
gen str80 lat = ""
gen str80 qua = ""
gen str80 lng = ""
gen str80 aqi = ""
gen str80 region = ""

insheetjson lat qua lng aqi region using "aqi_gz.json", ///
    table(list) col("LAT" "QUALITY" "ING" "AQI" "REGIONNAME") replace 
compress

// 读取json中的某个值
gen str80 type = ""
insheetjson type using "aqi_gz.json", ///
    col("type")
compress

gen str80 yf = ""
insheetjson yf using "aqi_gz.json", ///
    col("list:21:REGIONNAME")
compress
