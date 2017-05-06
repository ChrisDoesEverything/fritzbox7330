--[[Access denied<?lua
    box.end_page()
?>?>?>?>]]
js={}
local table_insert,table_concat,math_floor=table.insert,table.concat,math.floor
local pairs,ipairs,type=pairs,ipairs,type
local is_no_arrayindex,is_array,jskey,jsvalue,nl
function js.table(tbl,level)
level=level or 0
if is_array(tbl)then
return"["..js.array(tbl,level).."]"
else
return"{"..js.object(tbl,level).."}"
end
end
function js.array(arr,level)
level=level or 0
local result={}
local value
for k,v in ipairs(arr or{})do
value=jsvalue[type(v)]
if value then
table_insert(result,value(v,level+1))
end
end
return table_concat(result,", ")
end
function js.object(tbl,level)
level=level or 0
local result={}
local key,value
for k,v in pairs(tbl or{})do
key=jskey[type(k)]
value=jsvalue[type(v)]
if key and value then
table_insert(result,nl(level)..key(k)..": "..value(v,level+1))
end
end
return table_concat(result,", ")..nl(level-1)
end
function js.quoted(s)
s=tostring(s)
s=s:gsub("%c"," ")
s=s:gsub([[\]],[[\\]])
s=s:gsub([[\\n]],[[\n]])
s=s:gsub([[/]],[[\/]])
s=s:gsub([["]],[[\"]])
return[["]]..s..[["]]
end
function js.camelize(str)
return string.gsub(str or"","(_%a)",
function(s)return s:at(2):upper()end
)
end
is_no_arrayindex=function(key,array_length)
return type(key)~='number'
or math_floor(key)~=key
or key<=0
or key>array_length
end
is_array=function(tbl)
if type(tbl)~='table'then return false end
local n=#tbl
if n==0 then return false end
for k in pairs(tbl)do
if is_no_arrayindex(k,n)then
return false
end
end
return true
end
jskey={
['string']=js.quoted,
['number']=js.quoted
}
jsvalue={
['string']=js.quoted,
['number']=tostring,
['boolean']=tostring,
['table']=js.table
}
nl=function(level)
return"\n"..("  "):rep(math.max(0,level))
end
return js