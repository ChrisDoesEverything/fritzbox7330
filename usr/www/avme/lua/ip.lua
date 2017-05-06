--[[Access denied<?lua
    box.end_page()
?>?>]]
module(...,package.seeall);
function byte2bitstr(b)
local bstr=""
for i=1,8 do
if b%2==1 then
bstr="1"..bstr
else
bstr="0"..bstr
end
b=math.floor(b/2)
end
return bstr
end
function quad2bitstr(ipstr)
local bytes={string.match(ipstr,"([%d]+)%.([%d]+)%.([%d]+)%.([%d]+)")}
local str=""
for _,b in ipairs(bytes)do
local bstr=byte2bitstr(b)
str=str..bstr
end
return str
end
function quad2table(addr)
local t={"","","",""}
if addr then
t={string.match(addr,"([%d]+)%.([%d]+)%.([%d]+)%.([%d]+)")}
if table.maxn(t)<4 then
t={"","","",""}
end
end
return t
end
function read_from_post(name,callback_fn)
local str=""
for i=0,3 do
local part=name..tostring(i)
if i>0 then str=str.."."end
str=str..tostring(tonumber(box.post[part])or 0)
if callback_fn and type(callback_fn)=="function"then
callback_fn(i,box.post[part])
end
end
return str
end
function analyse_net(ip,mask)
local boxstr=quad2bitstr(ip)
local maskstr=quad2bitstr(mask)
local netpart=string.match(maskstr,"^([1]+)0*$")
return{["net"]=string.sub(boxstr,1,string.len(netpart)),["host"]=string.sub(boxstr,string.len(netpart)+1)}
end
function addr_in_net(net,ip)
local ipstr=quad2bitstr(ip)
return net.net==string.sub(ipstr,1,string.len(net.net))
end
function is_net_addr(net,ip)
local ipstr=quad2bitstr(ip)
return string.match(string.sub(ipstr,string.len(net.net)+1),"^0+$")
end
function is_broadcast(net,ip)
local ipstr=quad2bitstr(ip)
return string.match(string.sub(ipstr,string.len(net.net)+1),"^1+$")
end
