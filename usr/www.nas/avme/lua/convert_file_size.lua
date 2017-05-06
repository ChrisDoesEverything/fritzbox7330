--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
local g_units = {"Byte", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"}
function get_index_of_unit(unit)
for i,v in ipairs(g_units) do
if string.lower(v) == string.lower(unit) then
return i
end
end
end
function get_new_unit_string(old_unit, unit_delta)
local new_index = -1
for i, v in ipairs(g_units) do
if string.lower(v) == string.lower(old_unit) and g_units[i+unit_delta] ~= nil then
new_index = i + unit_delta
break
end
end
if new_index ~= -1 then
return g_units[new_index]
else
return ""
end
end
function x_to_y(file_size, unit_of_file_size, convert_to_unit, prezision, binaer, with_unit_string)
local oldUnitIndex = get_index_of_unit(unit_of_file_size)
local newUnitIndex = get_index_of_unit(convert_to_unit)
--ToDo
end
--[[
1 Parameter "file_size" ist die grösse der Datei welche umgerechnet werden soll
2 Parameter "unit_of_file_size" gibt an in welchem Format die fileSize angegeben wurde byte, kb, mb, gb, tb ...
3 Parameter "precision" int der angiebt wieviele Nachkommastellen angezeigt oder zurückgegeben werden sollen.
4 Parameter "binaer" boolean. True: es wird mit 1024 umgerechnet. False: es wird mit 1000 umgerechnet.
5 Parameter "with_unit_string" boolean. True: es wird die Einheit als string angehangen also z.b. 1,5 GB. False: die grösse wird als Zahl z.B 1,5 zurückgegeben.
Rückgabe
]]
function humanReadable(file_size, unit_of_file_size, precision, binaer, with_unit_string)
local divisor = 1000
if binaer then divisor = 1024 end
local unit_delta = 0
local new_unit_str = unit_of_file_size
local new_file_size = 0
if file_size and type(file_size) == "string" then file_size = tonumber(file_size) end
if not(file_size) or file_size < 0 then file_size=0 end
if precision and type(precision) == "string" then precision = tonumber(precision) end
if not(precision) or precision < 0 then precision=0 end
local tmp = file_size
if tmp >= divisor then
repeat
unit_delta = unit_delta+1
tmp = tmp / divisor
until (tmp < divisor)
end
--Vierstellige Nummern werden nicht aktzeptiert und in die nächst höhere Einheit umgewandelt (dies kann nur bei der umrechnung mit 1024 geschehen)
if binaer and tmp > 999 then
unit_delta = unit_delta+1
tmp = tmp / divisor
end
new_unit_str = get_new_unit_string(unit_of_file_size, unit_delta)
if string.lower(new_unit_str) == "byte" then
precision = 0
end
new_file_size = string.format("%."..precision.."f", tmp)
if string.find(new_file_size, ".", 1, true) then
new_file_size = string.sub(new_file_size, 1, string.find(new_file_size, ".", 1, true) - 1)..','..string.sub(new_file_size, string.find(new_file_size, ".", 1, true) + 1, string.len(new_file_size))
end
if with_unit_string then
return new_file_size..' '..new_unit_str
else
return new_file_size
end
end
