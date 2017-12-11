** Makes QR codes containing text.

cap prog drop txt2qr
prog def txt2qr

version 9.0
syntax anything using/ , [save] [replace]
local j = subinstr(`anything'," ","&",.)

copy `"http://qr.liantu.com/api.php?&w=300&text=`j'"' `using' , `s' `replace'
end
