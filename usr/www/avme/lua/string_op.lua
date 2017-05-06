--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
function is_number(token)
if token == nil or type(token) ~= "string" or #token == 0 then
return false
end
return string.match(token, "[^0-9]") == nil
end
function trim_start_end_spaces(what)
what = string.gsub(what, "^%s", "")
what = string.gsub(what, "%s$", "")
return what
end
function split2table(what, delim, maxcount)
local start
local fin
local first
local rest
local result = {}
while true do
start, fin, first, rest = string.find(what, "([^" .. delim .. "]*)" .. delim .. "(.*)")
if first == nil then
table.insert(result, what)
return result
end
table.insert(result, first)
what = rest
if maxcount > 0 then
maxcount = maxcount - 1
if maxcount == 0 then
table.insert(result, what)
return result
end
end
end
end
function txt_selected(Condition)
if Condition then
return " selected"
end
return ""
end
function txt_checked(Condition)
if Condition then
return " checked"
end
return ""
end
function txt_disabled(Condition)
if Condition then
return " disabled"
end
return ""
end
function txt_style_display_none(Condition)
if Condition then
return " style='display:none'"
end
return ""
end
function txt_js_bool(Condition)
if Condition then
return "true"
end
return "false"
end
function bool_to_value(value, trueval, falseval)
if value then
return trueval
end
return falseval
end
function on_off_to_value(value, trueval, falseval)
if value == "on" then
return trueval
end
return falseval
end
function in_list(value, liste)
for Index = 1, #liste, 1 do
if value == liste[Index] then
return true
end
end
return false
end
function html_escape(str)
str = str:gsub('&', '&amp;')
str = str:gsub('<', '&lt;')
str = str:gsub('>', '&gt;')
return str
end
function shift_blanks(str)
--Leerzeichen (0x20) auf 0xA0 mappen, damit es auch mehrfach angezeigt wird
str = str:gsub(' ', '&nbsp;')
return str
end
