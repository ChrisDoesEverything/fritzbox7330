--[[Access denied<?lua
    box.end_page()
?>?>?>?>]]
local table_insert=table.insert
local function typecheck(x,...)
local types={...}
if#types==0 then return end
local t=type(x)
for i=1,#types do
if t==types[i]then return end
end
error(
"Typecheck: expected "..table.concat(types," or ")
..", but got "..t
)
end
function tosigned(sz_value)
if not sz_value then return sz_value end
sz_value=sz_value:gsub("%-0*%.","-."):gsub("%-%-","")
return tonumber(sz_value)
end
array={}
func={}
function math.round(num,decimals)
typecheck(num,'number')
typecheck(decimals,'number','nil')
local d=10^(decimals or 0)
return math.floor(num*d+0.5)/d
end
function math.isnan(n)
return type(n)~='number'or n~=n
end
function string.split(self,separator,usepatterns)
typecheck(separator,'string','nil')
typecheck(usepatterns,'boolean','nil')
local result={}
if not separator or separator==""then
for i=1,#self do result[i]=self:sub(i,i)end
return result
end
local plain=not usepatterns
local curr=1
local left,right=self:find(separator,curr,plain)
while left and left<=right do
table_insert(result,self:sub(curr,left-1))
curr=right+1
left,right=self:find(separator,curr,plain)
end
table_insert(result,self:sub(curr))
return result
end
function string.at(self,idx)
typecheck(idx,'number')
return self:sub(idx,idx)
end
function string.pad(self,width,fill)
typecheck(width,'number')
typecheck(fill,'string','nil')
fill=fill or" "
fill=fill:rep(math.ceil(math.abs(width)/#fill))
if width<0 then
return string.sub(fill..self,width)
end
return string.sub(self..fill,1,width)
end
function string.trim(self)
return(self:gsub("^%s+",""):gsub("%s+$",""))
end
function string.esc(self)
return(self:gsub("(%W)","%%%1"))
end
function string.cat(self,...)
return table.concat({self,...},"")
end
function func.partial(fn,...)
typecheck(fn,'function')
local fixed_args={...}
return function(...)
return fn(unpack(array.cat(fixed_args,{...})))
end
end
function func.rpartial(fn,...)
typecheck(fn,'function')
local fixed_args={...}
return function(...)
return fn(unpack(array.cat({...},fixed_args)))
end
end
local function _curry(n,fn)
if n==0 then return fn()end
return function(a)
return _curry(n-1,function(...)return fn(a,...)end)
end
end
function func.curry(n,fn)
typecheck(n,'number')
typecheck(fn,'function')
return _curry(n,fn)
end
function func.id(...)return...end
function func.const(x)return function()return x end end
function func.eq(x,key)
if key==nil then
return function(val)return val==x end
else
return function(obj)
return obj and obj[key]==x
end
end
end
function func.neq(x,key)
local equal=func.eq(x,key)
return function(v)return not equal(v)end
end
function func.match(pattern,key)
if key==nil then
return function(val)
return type(val)=='string'and val:match(pattern)~=nil
end
else
return function(obj)
local s=obj and obj[key]
return type(s)=='string'and s:match(pattern)~=nil
end
end
end
function func.cached(fn)
typecheck(fn,'function')
local cache={}
return function(x)
local result=cache[x]
if result==nil then
result=fn(x)
cache[x]=result
end
return result
end
end
function func.get(key,default)
return function(obj)
return obj and obj[key]or default
end
end
function table.size(tbl)
typecheck(tbl,'table','nil')
local n=0
for k in pairs(tbl or{})do
n=n+1
end
return n
end
function table.update(dest,src)
typecheck(dest,'table','nil')
typecheck(src,'table','nil')
dest=dest or{}
for key,value in pairs(src or{})do
dest[key]=value
end
return dest
end
function table.extend(dest,src)
typecheck(dest,'table','nil')
typecheck(src,'table','nil')
dest=dest or{}
for key,value in pairs(src or{})do
if dest[key]==nil then dest[key]=value end
end
return dest
end
function table.transpose(tbl)
typecheck(tbl,'table','nil')
local result={}
for key,value in pairs(tbl or{})do
result[value]=key
end
return result
end
function array.indices(tbl)
typecheck(tbl,'table','nil')
local result={}
for i,value in ipairs(tbl or{})do
result[value]=i
end
return result
end
function table.keys(tbl)
typecheck(tbl,'table','nil')
local result={}
for key,value in pairs(tbl or{})do
table_insert(result,key)
end
return result
end
function table.values(tbl)
typecheck(tbl,'table','nil')
local result={}
for key,value in pairs(tbl or{})do
table_insert(result,value)
end
return result
end
function table.map(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
local result={}
for key,value in pairs(tbl or{})do
result[key]=fn(value,key)
end
return result
end
function array.map(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
local result={}
for i,value in ipairs(tbl or{})do
result[i]=fn(value,i)
end
return result
end
function table.filter(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
local yes,no={},{}
local list
for key,value in pairs(tbl or{})do
list=fn(value,key)and yes or no
list[key]=value
end
return yes,no
end
function array.filter(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
local yes,no={},{}
local list
for i,value in ipairs(tbl or{})do
list=fn(value,i)and yes or no
table_insert(list,value)
end
return yes,no
end
function table.reduce(tbl,base,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for key,value in pairs(tbl or{})do
base=fn(base,value,key)
end
return base
end
function array.reduce(tbl,base,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for i,value in ipairs(tbl or{})do
base=fn(base,value,i)
end
return base
end
function table.all(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for key,value in pairs(tbl or{})do
if not fn(value,key)then return false end
end
return true
end
function array.all(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for i,value in ipairs(tbl or{})do
if not fn(value,i)then return false end
end
return true
end
function table.any(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for key,value in pairs(tbl or{})do
if fn(value,key)then return true end
end
return false
end
function array.any(tbl,fn)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
for i,value in ipairs(tbl or{})do
if fn(value,i)then return true end
end
return false
end
function array.unique(tbl)
typecheck(tbl,'table','nil')
return table.keys(array.indices(tbl or{}))
end
function array.hash(tbl,key)
typecheck(tbl,'table','nil')
local result={}
local order={}
local idx
for i,obj in ipairs(tbl or{})do
if type(obj)=='table'then
idx=obj[key]
else
idx=nil
end
if idx==nil then idx=i end
result[idx]=obj
table_insert(order,idx)
end
return result,order
end
local function _clone(obj,done)
if type(obj)=='table'and not done[obj]then
local t={}
done[obj]=t
for key,value in pairs(obj)do
t[key]=_clone(value,done)
end
return t
else
return done[obj]or obj
end
end
function table.clone(obj)
return _clone(obj,{})
end
function array.cat(...)
local result={}
local tbl
for i=1,select('#',...)do
tbl=select(i,...)or{}
for j=1,#tbl do
table_insert(result,tbl[j])
end
end
return result
end
function array.build(n,fn)
typecheck(n,'number')
typecheck(fn,'function','nil')
local result={}
fn=fn or func.id
for i=1,n do result[i]=fn(i)end
return result
end
function array.truth(tbl)
typecheck(tbl,'table','nil')
local result={}
for i,value in ipairs(tbl or{})do
result[value]=true
end
return result
end
function array.revert(tbl)
typecheck(tbl,'table','nil')
tbl=tbl or{}
local result={}
local n=#tbl+1
for i=1,n/2 do
result[n-i],result[i]=tbl[i],tbl[n-i]
end
return result
end
function array.slice(tbl,first,last)
typecheck(tbl,'table','nil')
typecheck(first,'number','nil')
typecheck(last,'number','nil')
tbl=tbl or{}
local size=#tbl
first=first or 1
if first<0 then first=size+first+1 end
last=last or size
if last<0 then last=size+last end
local result={}
for i=first,last do
table_insert(result,tbl[i])
end
return result
end
function array.find(tbl,fn,idx)
typecheck(tbl,'table','nil')
typecheck(fn,'function')
typecheck(idx,'number','nil')
tbl=tbl or{}
idx=idx or 1
while idx<=#tbl do
if fn(tbl[idx],idx)then return idx,tbl[idx]end
idx=idx+1
end
end
