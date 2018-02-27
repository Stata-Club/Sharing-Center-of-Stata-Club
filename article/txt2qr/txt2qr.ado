** Makes QR codes containing text.

cap prog drop txt2qr
prog def txt2qr

version 9.0
syntax anything using/ , [save] [replace]
local j = subinstr(`anything'," ","&",.)
copy `"http://pan.baidu.com/share/qrcode?w=300&h=300&url=`j'"'  `using' , `s' `replace'
end
