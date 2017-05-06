--[[Access denied<?lua
    box.end_page()
?>?>?>]]
utf8={}
local math_min=math.min
local table_insert,table_sort,table_concat=table.insert,table.sort,table.concat
local string_char,string_byte=string.char,string.byte
local function utf8_char_type(b1,b2,b3,b4)
if not b1 then return 0 end
if 0x0<=b1 and b1<=0x7F then return 1 end
if not b2 then return 0 end
local tail_b2=0x80<=b2 and b2<=0xBF
if 0xC2<=b1 and b1<=0xDF and tail_b2 then return 2 end
if not b3 then return 0 end
local tail_b3=0x80<=b3 and b3<=0xBF
if 0xE0==b1 and 0xA0<=b2 and b2<=0xBF and tail_b3 then return 3 end
if 0xE1<=b1 and b1<=0xEC and tail_b2 and tail_b3 then return 3 end
if 0xED==b1 and 0x80<=b2 and b2<=0x9F and tail_b3 then return 3 end
if 0xEE<=b1 and b1<=0xEF and tail_b2 and tail_b3 then return 3 end
if not b4 then return 0 end
local tail_b4=0x80<=b4 and b4<=0xBF
if 0xF0==b1 and 0x90<=b2 and b2<=0xBF and tail_b3 and tail_b4 then return 4 end
if 0xF1<=b1 and b1<=0xF3 and tail_b2 and tail_b3 and tail_b4 then return 4 end
if 0xF4==b1 and 0x80<=b2 and b2<=0x8F and tail_b3 and tail_b4 then return 4 end
return 0
end
local function ubytes_strict(str,idx)
local cnt=utf8_char_type(str:byte(idx,idx+4))
return cnt,cnt>0 and str:sub(idx,idx+cnt-1)or nil
end
local function ubytes_loose(str,idx)
local cnt=utf8_char_type(str:byte(idx,idx+4))
if cnt==0 then cnt=1 end
return cnt,str:sub(idx,idx+cnt-1)
end
local function ubytes_throw(str,idx)
local cnt=utf8_char_type(str:byte(idx,idx+4))
if cnt==0 then
error("invalid UTF8 byte near '..."..string_char(str:byte(idx,idx+4)).."...'.")
end
return cnt,str:sub(idx,idx+cnt-1)
end
local ubytes=ubytes_strict
function utf8.set_mode(mode)
if mode=='strict'then ubytes=ubytes_strict
elseif mode=='loose'then ubytes=ubytes_loose
elseif mode=='throw'then ubytes=ubytes_throw
end
end
function utf8.first_char(str)
local _,uchar=ubytes(str,1)
return uchar
end
function utf8.chars(str)
local i,n=1,#str
return function()
if i<=n then
local u,uchar=ubytes(str,i)
i=i+u
return uchar
end
end
end
function utf8.valid(str)
local i,u=1,0
while i<=#str do
u=ubytes_strict(str,i)
if u==0 then return false end
i=i+u
end
return true
end
function utf8.len(str)
local cnt=0
for _ in utf8.chars(str)do cnt=cnt+1 end
return cnt
end
local utf8_mt={}
function utf8.chartable(str)
local t=setmetatable({},utf8_mt)
for ch in utf8.chars(str)do
table_insert(t,ch)
end
return t
end
function utf8.sort(tbl,get_string)
get_string=get_string or function(s)return s end
local cache=setmetatable({},{__index=function(self,obj)local u=utf8.chartable(get_string(obj));self[obj]=u;return u end})
table_sort(tbl,function(obj1,obj2)return cache[obj1]<cache[obj2]end)
end
local abc={
de="AaÄäBbCcDdEeFfGgHhIiJjKkLlMmNnOoÖöPpQqRrSsßTtUuÜüVvWwXxYyZz",
en="AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz",
fr="AaÀàÂâBbCcÇçDdEeÉéÉéÊêËëFfGgHhIiÎîÏïJjKkLlMmNnOoÔôŒœPpQqRrSsTtUuÙùÛûÜüVvWwXxYyŸÿZz",
it="AaÀàBbCcDdEeÈèÉéFfGgHhIiÎîÏïJjKkLlMmNnOoÒòÓóPpQqRrSsTtUuÙùVvWwXxYyZz",
es="AaÁáBbCcDdEeÉéFfGgHhIiÍíJjKkLlMmNnÑñOoÓóPpQqRrSsTtUuÚúÜüVvWwXxYyZz",
pl="AaĄąBbCcĆćDdEeĘęFfGgHhIiJjKkLlŁłMmNnOoÓóPpQqRrSsŚśTtUuVvWwXxYyZzŹźŻż"
}
abc=setmetatable(abc,{
__index=func.const(abc.en)
})
local abc_idx=array.indices(utf8.chartable(abc[config.language])or{})
function utf8.set_language(id)
id=id or""
if id==""then id=config.language end
abc_idx=array.indices(utf8.chartable(abc[id])or{})
end
local function unicode(utf8char)
local b1,b2,b3,b4=string_byte(utf8char,1,4)
local diff,code=0,0
if b1 then code=b1 end
if b2 then code=code*64+b2;diff=12416 end
if b3 then code=code*64+b3;diff=925824 end
if b4 then code=code*64+b4;diff=63447168 end
return code-diff
end
utf8_mt.__lt=function(u1,u2)
local i,n=0,math_min(#u1,#u2)
repeat i=i+1 until i>n or u1[i]~=u2[i]
if i>n then return#u1<#u2 end
local i1,i2=abc_idx[u1[i]],abc_idx[u2[i]]
if i1 and i2 then return i1<i2 end
return unicode(u1[i])<unicode(u2[i])
end
utf8_mt.__eq=function(u1,u2)
return table_concat(u1)==table_concat(u2)
end
utf8_mt.__le=function(u1,u2)
return u1<u2 or u1==u2
end
utf8_mt.__tostring=function(u)
return table_concat(u)
end
return utf8
