--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
local g_debug = false
local g_handle = nil
local g_sort_tables = true
function sort_table_by_keys(Table, Func)
local NameTable = {}
local Name
local Value
for Name, Value in pairs(Table) do
table.insert(NameTable, Name)
end
table.sort(NameTable, Func)
local Index = 0
local Sort = function()
Index = Index + 1
if NameTable[Index] == nil then
return NameTable[Index], nil
end
return NameTable[Index], Table[NameTable[Index]]
end
return Sort
end
function sort_tables(sort)
g_sort_tables = sort
end
function reset()
g_sort_tables = true
if g_debug == false then
return
end
if g_handle == "Finish" then
g_handle = nil
return
end
if g_handle ~= nil then
g_handle:close()
g_handle = nil
end
end
function fin()
if g_debug == false then
return
end
reset()
g_handle = "Finish"
end
function WithAddInfo(Text, AddInfo)
if AddInfo == nil then
return Text
end
if (AddInfo.Insert == nil) or (AddInfo.Length == nil) or (AddInfo.Text == nil) then
return Text
end
if AddInfo.Insert == "" then
AddInfo.Insert = " "
end
while string.len(Text) < AddInfo.Length do
Text = Text .. string.sub(AddInfo.Insert, 1, AddInfo.Length - string.len(Text))
end
return Text .. AddInfo.Text
end
function txt_pur(text, AddInfo)
if g_debug == false or g_handle == "Finish" then
return
end
if (AddInfo ~= nil) and (AddInfo.Enabled ~= nil) and (AddInfo.Enabled == "F") then
return
end
if g_handle == nil then
g_handle = io.open("/dev/console", "w")
if g_handle == nil then
return
end
end
g_handle:write(text)
end
function GetPraefix(AddInfo)
if (AddInfo ~= nil) and (AddInfo.Praefix ~= nil) then
return AddInfo.Praefix
end
return "[Lua]"
end
function txt(text, AddInfo)
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. text, AddInfo), AddInfo)
end
function txt_nl(text, AddInfo)
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. text, AddInfo) .. "\n", AddInfo)
end
function nl(cnt, AddInfo)
for index = 1, cnt, 1 do
txt_pur(WithAddInfo("", AddInfo) .. "\n", AddInfo)
end
end
function var(text, value, AddInfo)
if g_debug == false or g_handle == "Finish" then
return
end
if value == nil then
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. text .. "=(NIL)", AddInfo) .. "\n", AddInfo)
return
end
if value == "" then
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. text .. "=(EMPTY)", AddInfo) .. "\n", AddInfo)
return
end
local typ_of_value = type(value)
if typ_of_value == "boolean" then
if value == true then
value = "true"
else
value = "false"
end
end
if typ_of_value == "table" then
if g_sort_tables then
for text_sub, value_sub in sort_table_by_keys(value, nil) do
var(text .. "." .. text_sub, value_sub, AddInfo)
end
else
for text_sub, value_sub in pairs(value) do
var(text .. "." .. text_sub, value_sub, AddInfo)
end
end
return
end
if typ_of_value == "function" then
for Name, Value in value do
var(text .. "." .. Name, Value, AddInfo)
end
return
end
if typ_of_value ~= "number" and typ_of_value ~= "string" and typ_of_value ~= "boolean" then
value = "nyi:not(num,str,bool)"
end
local hex_out = ""
if (typ_of_value == "number") and (AddInfo ~= nil) and (AddInfo.NumFormat ~= nil) and (AddInfo.NumFormat == "DH") then
hex_out = " / 0x" .. string.format("%x", value)
end
txt_pur( WithAddInfo(GetPraefix(AddInfo) .. text .. "=" .. typ_of_value .. "(" .. value .. hex_out .. ")", AddInfo)
.. "\n", AddInfo
)
end
function SpaceText(cnt, text)
local index = 0
for index = 1, cnt, 1 do
text = " " .. text
end
return text
end
function spc_var(cnt, text, value, AddInfo)
if g_debug == false or g_handle == "Finish" then
return
end
var(SpaceText(cnt, text), value, AddInfo)
end
function spc_txt(cnt, text, AddInfo)
if g_debug == false or g_handle == "Finish" then
return
end
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. SpaceText(cnt, text), AddInfo), AddInfo)
end
function spc_txt_nl(cnt, text, AddInfo)
if g_debug == false or g_handle == "Finish" then
return
end
txt_pur(WithAddInfo(GetPraefix(AddInfo) .. SpaceText(cnt, text), AddInfo) .. "\n", AddInfo)
end
