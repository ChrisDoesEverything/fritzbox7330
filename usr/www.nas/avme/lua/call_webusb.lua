--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
if not gl.bib.wu then
gl.bib.wu = require("libwebusb")
end
function call_webusb_func(func, ...)
if not(gl.bib.wu) then
return nil, "no_webusb", "webusb not available"
end
if not(func) or (type(func)~="function" and type(func)~="string") then
return nil, "no_func", "no function"
end
function sprintf(format, ...)
local str = string.gsub(format,"(%%%d+)%%%w+%%","%1")
for i=1, select('#', ...) do
local param = select(i, ...)
str = string.gsub(str, "%%"..tostring(i), tostring(param))
end
return str
end
local err_txt = ""
local err_code = "unknown"
if type(func) == "string" then
if func == "scan_info" then
func = gl.bib.wu.WebUsb_GetScanInfo
err_code = "scan_info_failed"
elseif func == "start_fnasdb" then
func = gl.bib.wu.WebUsb_StartFritznasdb
err_code = "restart_fnasdb_failed"
elseif func == "browse" then
func = gl.bib.wu.WebUsb_Browse
err_txt = [[<div id="error_div_browse">]]..box.tohtml(TXT([[{?7782:356?}]]))..[[</div>]]
err_code = "browse_no_data"
elseif func == "search" then
func = gl.bib.wu.WebUsb_Search
err_txt = ""
err_code = "search_no_data"
end
end
if type(func)~="function" then
return nil, "no_func_found", "No function for given ID"
end
local tab, fail, p1 = func(...)
local ret_tab = {}
local index = {}
if type(fail) == "boolean" and not(fail) and tab ~= nil and type(tab) == "table" and tab[2]~=nil and type(tab[2])=="table" then
local tab_size = tab
for index_aussen,row in ipairs(tab) do
if ("table" == type(row)) then
if (index_aussen == 1) then
for index_innen,column in ipairs(row) do
if (type(column) == "string") then
index[index_innen] = column
end
end
tab[index_aussen] = nil
else
ret_tab[index_aussen - 1] = {}
for index_innen,column in ipairs(row) do
ret_tab[index_aussen -1 ][index[index_innen]] = row[index_innen]
end
tab[index_aussen] = nil
end
end
end
return ret_tab, "", "", p1
elseif type(tab)== "boolean" and type(fail) == "number" then
return tab, fail
end
return ret_tab, err_code, err_txt, p1
end
