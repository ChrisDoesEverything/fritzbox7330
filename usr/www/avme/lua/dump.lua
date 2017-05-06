--[[Access denied<?lua
    box.end_page()
?>?>?>]]
local _={}
function dumptable(tbl,level)
level=level or 1
local result={}
local key,value
for k,v in _.sorted_pairs(tbl or{})do
key,value=_.key[type(k)],_.value[type(v)]
if key and value then
table.insert(result,_.nl(level).."["..key(k).."]".." = "..value(v,level+1))
end
end
return"{"..table.concat(result,", ").._.nl(level-1).."}"
end
function _.cmp(str1,str2)
str1=tostring(str1 or"")
str2=tostring(str2 or"")
local i1,i,s1,n1,r1=str1:find("^(.-)(%d+)(.*)$")
local i2,i,s2,n2,r2=str2:find("^(.-)(%d+)(.*)$")
if i1 and i2 and s1==s2 then
n1,n2=tonumber(n1),tonumber(n2)
if n1 and n2 then
return n1==n2 and _.cmp(r1,r2)or n1<n2
end
end
return str1<str2
end
function _.sorted_pairs(tbl)
local order=_.table_keys(tbl)
table.sort(order,_.cmp)
local i=0
local n=#order
return function()
i=i+1
if i<=n then return order[i],tbl[order[i]]end
end
end
_.quoted=function(str)
return string.format("%q",str or"")
end
_.key={
['string']=_.quoted,
['number']=tostring,
['boolean']=tostring
}
_.value={
['string']=_.quoted,
['number']=tostring,
['boolean']=tostring,
['table']=dumptable
}
_.nl=function(level)
return"\n"..("  "):rep(math.max(0,level))
end
_.table_keys=table.keys or function(tbl)
local result={}
for key,value in pairs(tbl or{})do
table.insert(result,key)
end
return result
end
