--[[Access denied<?lua
box.end_page()
?>]]
newval = {}
require"ip"
require"utf8"
require"textdb"
local ret = {
ok = "ok",
notfound = "notfound",
empty = "empty",
different = "different",
notdifferent = "notdifferent",
outofrange = "outofrange",
wrong = "wrong",
format = "format",
missing = "missing",
tooshort = "tooshort",
toolong = "toolong",
toomuch = "toomuch",
group = "group",
outofnet = "outofnet",
thenet = "thenet",
broadcast = "broadcast",
thebox = "thebox",
nomask = "nomask",
unsized = "unsized",
notempty = "notempty",
zero ="zero",
notzero ="notzero",
allzero = "allzero",
ewemeternet = "ewemeternet",
leadchar = "leadchar",
endchar = "endchar",
reservednet = "reservednet",
greaterthan = "greaterthan",
equalerr = "equalerr"
}
newval.ret = ret
newval.msg = {}
local valfunc = {}
local state = {ok = true, result = ret.ok, tomark = {}, alert = nil}
local function default_msg(result)
result = result or ""
return TXT([[{?388:907?}]])
.. [[ (]] .. result .. [[)]]
.. [[\n]] .. TXT([[{?388:526?}]])
end
local function setstate(result, msgtab)
state.result = result
state.ok = result == ret.ok
if state.ok then
state.tomark = {}
end
if type(msgtab) == "string" then
msgtab = newval.msg[msgtab]
end
if msgtab and result ~= ret.ok then
state.alert = msgtab[result] or default_msg(result)
end
return result
end
local function call_valfunc(func_name, ...)
local params = {...}
if #params > 0 then
local msgtab = table.remove(params)
if msgtab == false or state.result == ret.ok then
local result = valfunc[func_name](unpack(params))
if msgtab == false then
return result == ret.ok
else
return setstate(result, msgtab)
end
end
end
end
setmetatable(newval, {
__index = function(self, key)
if type(valfunc[key]) == 'function' then
return function(...)
return call_valfunc(key, ...)
end
end
end
})
local function mark(...)
for i, name in ipairs{...} do
state.tomark[name] = true
end
end
local function unmark(...)
for i, name in ipairs{...} do
state.tomark[name] = nil
end
end
local function unmark_all()
state.tomark = {}
end
function newval.validate(prog)
setstate(ret.ok)
if type(prog) == "function" then
prog()
end
if state.ok then
unmark_all()
end
state.tomark = table.keys(state.tomark)
state.validate = box.post.validate
return state.result, state
end
function newval.exists(elem)
return box.post[elem] ~= nil
end
function newval.checked(elem)
return box.post[elem] ~= nil
end
function newval.radio_check(elem, value)
return box.post[elem] == value
end
function newval.value_empty(elem)
return not box.post[elem] or box.post[elem] == ""
end
function newval.value_equal(elem, value)
return box.post[elem] == value
end
function newval.values_not_all_empty(elem, count)
count = count or 0
for i = 0, count - 1 do
if not newval.value_empty(elem .. i) then
return true
end
end
return false
end
function newval.is_ipv6(ipv6)
if type(ipv6) ~= "string" or #ipv6 == 0 or string.find(ipv6, "[^:%x]" ) or
string.find(ipv6, "^:[^:]" ) or string.find(ipv6, "[^:]:$" ) or string.find(ipv6, ":::" ) then
return false
end
local double_colon_count
ipv6, double_colon_count = string.gsub(ipv6, "::", ":" )
if double_colon_count > 1 then return false end
ipv6 = string.gsub(ipv6, "^:?", ":" )
local groups
ipv6, groups = string.gsub(ipv6, ":%x%x?%x?%x?", "" )
return ( ( double_colon_count == 1 and groups < 8 ) or ( double_colon_count == 0 and groups == 8 ) )
and ( #ipv6 == 0 or ( double_colon_count == 1 and ipv6 == ":" ) )
end
local function read_value(elem)
return elem and box.post[elem] or ""
end
function valfunc.not_allowed(elem, bad_value)
local value = read_value(elem)
if value == tostring(bad_value) then
mark(elem)
return ret.wrong
end
return ret.ok
end
function valfunc.const_error(elems, errname)
if errname and ret[errname] then
local els = string.split(elems or "", ",")
for i, el in ipairs(els) do
mark(el)
end
return ret[errname]
end
return ret.ok
end
function valfunc.not_empty(elem)
if not box.post[elem] then
return ret.notfound
end
local value = read_value(elem)
if #value == 0 then
mark(elem)
return ret.empty
end
return ret.ok
end
function valfunc.not_empty_or_absent(elem)
if not box.post[elem] then
return ret.ok
end
return valfunc.not_empty(elem)
end
function valfunc.equal(elem1, elem2)
if read_value(elem1) ~= read_value(elem2) then
mark(elem1, elem2)
return ret.different
end
return ret.ok
end
function valfunc.time_not_equal(elem_hh_1, elem_mm_1, elem_hh_2, elem_mm_2, not_equal_0_24)
local hh_1 = tonumber(read_value(elem_hh_1))
local hh_2 = tonumber(read_value(elem_hh_2))
local mm_1 = tonumber(read_value(elem_mm_1))
local mm_2 = tonumber(read_value(elem_mm_2))
local equal_0_24 = not not_equal_0_24
if nil ~= mm_1 and mm_1 == mm_2 and nil ~= hh_1 and nil ~= hh_2 and
( hh_1 == hh_2 or ( equal_0_24 and hh_1 + 24 == hh_2 ) or ( equal_0_24 and hh_2 + 24 == hh_1 ) ) then
mark(elem_hh_1, elem_mm_1, elem_hh_2, elem_mm_2)
return ret.equalerr
end
return ret.ok
end
function valfunc.not_equals(elem, params)
local value = string.lower(read_value(elem))
params = params or {}
for i, param in ipairs(params) do
if value == string.lower(param) then
mark(elem)
return ret.equalerr
end
end
return ret.ok
end
function valfunc.less_than(elem1, elem2)
local value1 = tonumber(read_value(elem1))
if not value1 then
mark(elem1)
return ret.format
end
local value2 = tonumber(read_value(elem2))
if not value2 then
mark(elem2)
return ret.format
end
mark(elem1, elem2)
if value1 == value2 then
return ret.equalerr
end
if value1 > value2 then
return ret.greaterthan
end
return ret.ok
end
function valfunc.not_equal_ip(elem1, elem2)
local ip1 = ip.read_from_post(elem1)
local ip2 = ip.read_from_post(elem2)
if ip1 == ip2 then
mark(elem2)
return ret.notdifferent
end
return ret.ok
end
function valfunc.char_range(elem, min, max)
min = tonumber(min) or 0
max = tonumber(max) or 255
local str = read_value(elem)
for c = 1, #str do
local code = str:byte(c)
if code < min or code > max then
mark(elem)
return ret.outofrange
end
end
return ret.ok
end
function valfunc.f6rd_prefixlen(mask_elem, pref_elem)
local masklen = tonumber(read_value(mask_elem))
local preflen = tonumber(read_value(pref_elem))
if (preflen + (32 - masklen)) > 64 then
mark(mask_elem, pref_elem)
return ret.outofrange
end
return ret.ok
end
function valfunc.num_range(elem,min,max)
min = tonumber(min) or 0
max = tonumber(max) or 65536
local sznumber = read_value(elem)
mark(elem)
if #sznumber == 0 then
return ret.empty
end
local number = tonumber(sznumber)
if number == nil then
return ret.format
end
if number < min or number > max then
return ret.outofrange
end
return ret.ok
end
function valfunc.num_range_integer(elem,min,max)
min = tonumber(min) or 0
max = tonumber(max) or 65536
local res = valfunc.is_num_in(elem)
if res ~= ret.ok then
return res
end
local number = tonumber(read_value(elem))
if number < min or number > max then
mark(elem)
return ret.outofrange
end
return ret.ok
end
function valfunc.num_range_real(elem,post_dec_pos,min,max)
n_pos = tonumber(post_dec_pos) or 0
n_min = tonumber(min) or 0
n_max = tonumber(max) or 65536
local res = valfunc.is_float(elem,n_pos,max)
if res ~= ret.ok then
return res
end
local sz_number = read_value(elem)
local sznumber, n_count = string.gsub( sz_number, [[,]], [[.]])
local number = tonumber(sznumber)
if number < min or number > max then
mark(elem)
return ret.outofrange
end
return ret.ok
end
function valfunc.max_num(elem, max)
max = tonumber(max) or 65536
local sznumber = read_value(elem)
mark(elem)
if #sznumber == 0 then
return ret.empty
end
local number = tonumber(sznumber)
if number == nil then
return ret.format
end
if max < number then
return ret.outofrange
end
return ret.ok
end
function valfunc.min_num(elem, min)
min = tonumber(min) or 0
local sznumber = read_value(elem)
mark(elem)
if #sznumber == 0 then
return ret.empty
end
local number = tonumber(sznumber)
if number == nil then
return ret.format
end
if min > number then
return ret.outofrange
end
return ret.ok
end
function valfunc.is_valid_date(elem1, elem2, elem3)
local day = tonumber(read_value(elem1)) or -1
local month = tonumber(read_value(elem2)) or -1
local year = tonumber(read_value(elem3)) or -1
if month < 1 or month > 12 then
mark(elem2)
return ret.outofrange
end
if year < 2012 then
mark(elem3)
return ret.tooshort
end
local month_days = 31
if month == 2 then
month_days = 28
if math.abs(year - 2012) % 4 == 0 then
month_days = 29
end
elseif month == 4 or month == 6 or month == 9 or month == 11 then
month_days = 30
end
if day < 0 or month_days < day then
mark(elem1)
return ret.wrong
end
return ret.ok
end
function valfunc.is_valid_time(elem1, elem2)
local hour = tonumber(read_value(elem1)) or -1
local minutes = tonumber(read_value(elem2)) or -1
if hour == 24 and minutes ~= 0 then
mark(elem2)
return ret.wrong
end
return ret.ok
end
function valfunc.is_valid_countdown_time(elem1, elem2)
local hour = tonumber(read_value(elem1)) or -1
local minutes = tonumber(read_value(elem2)) or -1
if hour == 0 and minutes == 0 then
mark(elem1)
mark(elem2)
return ret.wrong
end
return ret.ok
end
function valfunc.least_one_checked(elem1, elem2)
if not newval.checked(elem1) and not newval.checked(elem2) then
mark(elem1, elem2)
return ret.wrong
end
return ret.ok
end
function valfunc.is_valid_degree(elem1, elem2, elem3, to_compare)
local degree = tonumber(read_value(elem1))
local min = tonumber(read_value(elem2))
local sec = tonumber(read_value(elem3))
if degree == to_compare then
if min == 0 and sec == 0 then
return ret.ok
else
mark(elem2, elem3)
return ret.wrong
end
end
return ret.ok
end
function valfunc.value_unallowable(elem, to_compare)
local value = read_value(elem)
if value == tostring(to_compare) then
mark(elem)
return ret.wrong
end
return ret.ok
end
function valfunc.length(elem, min, max, options)
min = tonumber(min) or 0
max = tonumber(max) or 255
options = options or {}
local str = read_value(elem)
mark(elem)
if options.empty_allowed and #str == 0 then
return ret.ok
end
if utf8.len(str) < min then
return ret.tooshort
end
if utf8.len(str) > max then
return ret.toolong
end
return ret.ok
end
function valfunc.no_lead_char(elem, char)
local value = read_value(elem)
if value:sub(1, 1) == string.char(tonumber(char)) then
mark(elem)
return ret.leadchar
end
return ret.ok
end
function valfunc.no_end_char(elem, char)
local value = read_value(elem)
if value:sub(-1, -1) == string.char(tonumber(char)) then
mark(elem)
return ret.endchar
end
return ret.ok
end
function valfunc.check_reserved_net(elem)
local clientip = ip.read_from_post(elem)
local reserved = ip.analyse_net("192.168.180.0", "255.255.255.0")
if ip.addr_in_net(reserved, clientip) then
for i = 0, 2 do
mark(elem .. i)
end
return ret.reservednet
end
return ret.ok
end
function valfunc.pwd_changed(elem)
local str = read_value(elem)
if str == "****" then
mark(elem)
return ret.notdifferent
end
return ret.ok
end
function valfunc.ipv4(elem, options)
options = options or {}
local res = ret.ok
local function cb_ip(idx, byte)
if byte then
if byte ~= "" then
local num = tonumber(byte)
if not num then
mark(elem .. idx)
if res == ret.ok then res = ret.format end
elseif num < 0 or num > 255 then
mark(elem .. idx)
if res == ret.ok then res = ret.outofrange end
end
else
mark(elem .. idx)
if res == ret.ok or res == ret.format or res == ret.outofrange then res = ret.empty end
end
else
mark(elem .. idx)
res = ret.notfound
end
end
local function cb_ip_check_empty(idx, byte)
if byte then
if byte ~= "" then
res = ret.notempty
end
end
end
local function cb_ip_check_zero(idx, byte)
if byte then
if byte ~= "0" then
res = ret.notzero
else
mark(elem .. idx)
end
end
end
if options.zero_not_allowed then
res = ret.zero
ip.read_from_post(elem, cb_ip_check_zero)
if res == ret.zero then
return ret.allzero
end
unmark_all()
end
if options.empty_allowed then
res = ret.empty
ip.read_from_post(elem, cb_ip_check_empty)
if res == ret.notempty then
res = ret.ok
ip.read_from_post(elem, cb_ip)
else
res = ret.ok
end
else
res = ret.ok
ip.read_from_post(elem, cb_ip)
end
return res
end
function valfunc.netmask(elem)
local res = valfunc.ipv4(elem, {})
if res ~= ret.ok then
return res
end
res = ret.ok
local str = ip.read_from_post(elem)
local bitstr = ip.quad2bitstr(str)
if not string.match(bitstr, "^1") then
mark(elem .. "0")
return ret.nomask
end
local badpos = string.find(bitstr, "01")
if badpos then
local byte = tostring(math.floor((badpos+1) / 8))
mark(elem .. byte)
return ret.nomask
end
if not string.match(bitstr, "00$") then
mark(elem .. "3")
return ret.nomask
end
return ret.ok
end
function valfunc.mac(elem)
local res = ret.ok
for i = 0, 5 do
local elem_i = elem .. i
local value_i = read_value(elem_i)
if value_i ~= "" then
if not string.match(value_i, "^%x%x$") then
mark(elem_i)
if res == ret.ok then res = ret.format end
elseif i==0 then
if tonumber(value_i, 16) % 2 == 1 then
mark(elem_i)
if res == ret.ok then res = ret.group end
end
end
else
mark(elem_i)
if res == ret.ok or res == ret.format then res = ret.empty end
end
end
return res
end
function valfunc.clock_duration(h_elem, m_elem)
local res = ret.ok
local hstr = read_value(h_elem)
local mstr = read_value(m_elem)
if not string.find(hstr, "^[%d]*$") then
mark(h_elem)
res = ret.format
end
if not string.find(mstr, "^[%d]*$") then
mark(m_elem)
res = ret.format
end
if res == ret.ok then
local h = tonumber(hstr) or 0
local m = tonumber(mstr) or 0
if h < 0 or h > 24 then
mark(h_elem)
res = ret.outofrange
end
if m < 0 or m > 59 then
mark(m_elem)
res = ret.outofrange
end
if res == ret.ok and h == 24 and m ~= 0 then
mark(h_elem)
res = ret.outofrange
end
end
return res
end
function valfunc.port_fw_port_values(start_port, end_port, fw_port)
local res = valfunc.num_range(start_port, 0, 65535)
if res ~= ret.ok then
return res
end
unmark(start_port)
res = valfunc.num_range(end_port, 0, 65535)
if res ~= ret.ok then
return res
end
unmark(end_port)
res = valfunc.num_range(fw_port, 0, 65535)
if res ~= ret.ok then
return res
end
unmark(fw_port)
res = valfunc.less_than(start_port, end_port)
if res ~= ret.ok and res ~= ret.equalerr then
return res
end
return ret.ok
end
function valfunc.port_fw_ip_adr(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local str = read_value(elem)
local ipv4 = string.match(str, "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$") ~= nil
if not ipv4 then
local ipv6 = string.match(str, "^%[?[%x:]+%]?:?%d*$") ~= nil
if not ipv6 then
return ret.ok
else
mark(elem)
return ret.format
end
else
local t_ipv4_oktetts = str:split(".")
for i=1, #t_ipv4_oktetts do
local t_ipv4_oktettsAsNumber = tonumber(t_ipv4_oktetts[i])
if t_ipv4_oktettsAsNumber == nil or t_ipv4_oktettsAsNumber < 0 or t_ipv4_oktettsAsNumber > 255 then
mark(elem)
return ret.outofrange
end
end
if tonumber(t_ipv4_oktetts[1]) == 0 and tonumber(t_ipv4_oktetts[2]) == 0
and tonumber(t_ipv4_oktetts[3]) == 0 and tonumber(t_ipv4_oktetts[4]) == 0 then
mark(elem)
return ret.allzero
end
if tonumber(t_ipv4_oktetts[4]) == 0 then
mark(elem)
return ret.zero
end
if tonumber(t_ipv4_oktetts[4]) == 255 then
mark(elem)
return ret.broadcast
end
end
return ret.ok
end
function valfunc.netmask_null(elem)
if ip.read_from_post(elem) ~= "0.0.0.0" and ip.read_from_post(elem) ~= "255.255.255.255" then
return valfunc.netmask(elem)
end
return ret.ok
end
function valfunc.box_client_ip_range(elem1, elem2, boxip, netmask)
local res = ret.ok
res = valfunc.box_client_ip(elem1, boxip, netmask)
if res ~= ret.ok then
return res
end
res = valfunc.box_client_ip(elem2, boxip, netmask)
if res ~= ret.ok then
return res
end
--[[ boxip und netmask werden jetzt als Parameter übergeben
local boxip
local netmask
if cb_get_boxip and type(cb_get_boxip)=="function" then
boxip = cb_get_boxip()
else
boxip = box.query("interfaces:settings/lan0/ipaddr")
end
if cb_get_netmask and type(cb_get_netmask)=="function" then
netmask = cb_get_netmask()
else
netmask = box.query("interfaces:settings/lan0/netmask")
end
]]
local hostlen = string.len(string.match(ip.quad2bitstr(netmask), "0+"))
local str = ip.read_from_post(elem1)
local start_host = tonumber(string.sub(ip.quad2bitstr(str), -hostlen), 2)
str = ip.read_from_post(elem2)
local end_host = tonumber(string.sub(ip.quad2bitstr(str), -hostlen), 2)
local box_host = tonumber(string.sub(ip.quad2bitstr(boxip), -hostlen), 2)
if end_host < start_host then
for i = 4 - math.ceil(hostlen / 8), 3 do
mark(elem2 .. i)
end
return ret.unsized
end
if start_host <= box_host and box_host <= end_host then
for i = 4 - math.ceil(hostlen / 8), 3 do
mark(elem1 .. i)
end
return ret.thebox
end
return ret.ok
end
function valfunc.check_ewe_smartmeter_subnet(elem)
local clientip = ip.read_from_post(elem)
local ewe_smartmeter_net = ip.analyse_net("192.168.123.0", "255.255.255.0")
if ip.addr_in_net(ewe_smartmeter_net, clientip) then
for i = 0, 2 do
mark(elem .. i)
end
return ret.ewemeternet
end
return ret.ok
end
function valfunc.box_client_ip(elem, boxip, netmask)
local res = ret.ok
res = valfunc.ipv4(elem)
if res ~= ret.ok then
return res
end
--[[boxip und netmask werden jetzt als Parameter übergeben
local boxip
local netmask
local opmode = box.query("box:settings/opmode")
if cb_get_boxip and type(cb_get_boxip)=="function" then
boxip = cb_get_boxip()
else
if opmode == "opmode_eth_ipclient" then
boxip = box.query("connection0:status/ip")
else
boxip = box.query("interfaces:settings/lan0/ipaddr")
end
end
if cb_get_netmask and type(cb_get_netmask)=="function" then
netmask = cb_get_netmask()
else
if opmode == "opmode_eth_ipclient" then
netmask = box.query("connection0:status/netmask")
else
netmask = box.query("interfaces:settings/lan0/netmask")
end
end
]]
local clientip = ip.read_from_post(elem)
if clientip == boxip then
mark(elem .. "3")
return ret.thebox
end
local net = ip.analyse_net(boxip, netmask)
if not ip.addr_in_net(net, clientip) then
for i = 1, math.ceil(string.len(net.net) / 8) do
local part = string.sub(net.net, (i - 1) * 8 + 1, i * 8)
local value = read_value(elem .. (i-1))
if string.sub(ip.byte2bitstr(value), 1, string.len(part)) ~= part then
-- nur das Byte markieren, das tatsächlich nicht passt
mark(elem .. (i-1))
end
end
return ret.outofnet
end
if ip.is_net_addr(net, clientip) then
mark(elem .. "3")
return ret.thenet
end
if ip.is_broadcast(net, clientip) then
mark(elem .. "3")
return ret.broadcast
end
return ret.ok
end
function valfunc.check_ip_net(elem1, elem2, elem3)
local clientip = ip.read_from_post(elem1)
local netmask = ip.read_from_post(elem2)
local gateway = ip.read_from_post(elem3)
local net = ip.analyse_net(clientip, netmask)
if ip.is_net_addr(net, clientip) then
mark(elem1 .. "3")
return ret.thenet
end
if ip.is_broadcast(net, clientip) then
mark(elem1 .. "3")
return ret.broadcast
end
if not ip.addr_in_net(net, gateway) then
for i = 1, math.ceil(string.len(net.net) / 8) do
local part = string.sub(net.net, (i - 1) * 8 + 1, i * 8)
local value = read_value(elem3 .. (i-1))
if string.sub(ip.byte2bitstr(value), 1, string.len(part)) ~= part then
-- nur das Byte markieren, das tatsächlich nicht passt
mark(elem3 .. (i-1))
end
end
return ret.outofnet
end
if ip.is_net_addr(net, gateway) then
mark(elem3 .. "3")
return ret.thenet
end
if ip.is_broadcast(net, gateway) then
mark(elem3 .."3")
return ret.broadcast
end
return ret.ok
end
function valfunc.default_route(elem1, elem2, akt_route)
local dip = true
local dsm = true
for i=0, 3, 1 do
if box.post[elem1..i]~="0" then
dip = false
end
if box.post[elem2..i]~="0" then
dsm = false
end
end
local default_route_exists = false
for i,elem in pairs(general.listquery("route:settings/route/list(ipaddr,netmask)")) do
if elem.ipaddr=="0.0.0.0" and elem.netmask=="0.0.0.0" and elem._node~=akt_route then
default_route_exists = true
end
end
local res = ret.ok
if (dip==true or dsm==true) then
if default_route_exists then
res = ret.equalerr
elseif dip~=dsm then
res = ret.different
end
for i=0, 3, 1 do
if dip==true then
mark(elem1.. i)
end
if dsm==true then
mark(elem2.. i)
end
end
end
return res
end
function valfunc.ip_not_backup_network(elem)
if box.post[elem.."0"]=="169" and box.post[elem.."1"]=="254" and box.post[elem.."2"]=="255" and box.post[elem.."3"]=="255" then
for i=0, 3, 1 do
mark(elem.. i)
end
return ret.wrong
end
return ret.ok
end
function valfunc.not_all_checked(elem, count)
count = tonumber(count)
if count and count > 0 then
local res = ret.ok
for i = 1, count do
res = valfunc.not_empty(elem .. i)
if res ~= ret.ok then
return res
end
end
else
return not_empty(elem)
end
end
function valfunc.server(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
local fqdn = string.match(value, "^[%a%d%.%-]+%.%a%a%a?%a?%a?%a?:?%d*$") ~= nil
local ipv4 = string.match(value, "^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$") ~= nil
local ipv6 = string.match(value, "^%[?[%x:]+%]?:?%d*$") ~= nil
if fqdn or ipv4 or ipv6 then
return ret.ok
end
mark(elem)
return ret.format
end
function valfunc.clock_time(h_elem, m_elem)
local res = valfunc.not_empty(h_elem)
if res ~= ret.ok then
return res
end
res = valfunc.not_empty(m_elem)
if res ~= ret.ok then
return res
end
local hours = tonumber(read_value(h_elem))
if not hours then
mark(h_elem)
return ret.format
end
local minutes = tonumber(read_value(m_elem))
if not minutes then
mark(m_elem)
return ret.format
end
if hours < 0 or hours > 24 or minutes < 0 or minutes > 59 or (hours == 24 and minutes > 0) then
mark(h_elem, m_elem)
return ret.outofrange
end
return ret.ok
end
function valfunc.email_list(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
for addr in string.gmatch(value, "[^,%s]+") do
if string.match(addr, "^[%a%d%._%%%+%-]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$") == nil then
mark(elem)
return ret.format
end
end
return ret.ok
end
function valfunc.email(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.match(value, "^[%a%d%._%%%+%-]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$") == nil then
mark(elem)
return ret.format
end
return ret.ok
end
function valfunc.is_num_in(elem, not_allowed)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, "[^0-9#]") ~= nil then
mark(elem)
return ret.format
end
for i, bad in ipairs(not_allowed or {}) do
if value == bad then
mark(elem)
return ret.wrong
end
end
return ret.ok
end
function valfunc.is_num_in_enh(elem, not_allowed)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, "[^0-9#*]") ~= nil then
mark(elem)
return ret.format
end
for i, bad in ipairs(not_allowed or {}) do
if value == bad then
mark(elem)
return ret.wrong
end
end
return ret.ok
end
function valfunc.is_num_out(elem, not_allowed)
local res = valfunc.not_empty(elems)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, "[^0-9]") ~= nil then
mark(elem)
return ret.format
end
for i, bad in ipairs(not_allowed or {}) do
if value == bad then
mark(elem)
return ret.wrong
end
end
return ret.ok
end
function valfunc.native_interface_id(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, "[^0-9a-fA-F:.]") ~= nil then
mark(elem)
return ret.format
end
if string.sub(value, 1, 2) ~= "::" then
mark(elem)
return ret.missing
end
return ret.ok
end
function valfunc.native_prefix(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, "[^0-9a-fA-F:.]") ~= nil then
mark(elem)
return ret.format
end
if string.sub(value, 1, 2) == "::" and #value > 2 then
mark(elem)
return ret.wrong
end
return ret.ok
end
function valfunc.interface_id(elem)
local res = ret.ok
local values = {}
local all_empty = true
for i = 1, 4 do
values[i] = read_value(elem .. i)
if values[i] ~= "" then
all_empty = false
end
end
if all_empty then
mark(elem)
return ret.empty
end
local wrong = true
for i = 1, 4 do
if not (values[i] == "" or tonumber(values[i]) == 0) then
wrong = false
end
end
if wrong then
mark(elem)
return ret.wrong
end
return ret.ok
end
function valfunc.fw_port_range(elem1, elem2, not_empty)
local res1 = valfunc.not_empty(elem1)
local res2 = valfunc.not_empty(elem2)
if res1 == ret.empty and res2 == ret.ok then
return ret.wrong
end
if res1 == ret.ok and res2 == ret.empty then
return ret.ok
end
if res1 == ret.empty and res2 == ret.empty then
if not_empty then
mark(elem1, elem2)
return ret.missing
else
return ret.ok
end
end
local value1 = tonumber(read_value(elem1))
local value2 = tonumber(read_value(elem2))
if value1 and value2 and value2 < value1 then
mark(elem1, elem2)
return ret.outofrange
end
if res1 ~= ret.ok then
return res1
end
if res2 ~= ret.ok then
return res2
end
return ret.ok
end
function valfunc.is_valid_float_degree(elem,pattern,maximum)
local value = read_value(elem)
local n = string.find(value, '°')
if n and n < #value then
mark(elem)
return ret.leadchar
end
local real_value = nil
if n then
real_value = string.sub(value, 1, n-1)
end
return valfunc.is_float_plus(elem, pattern, maximum, real_value)
end
function valfunc.is_float(elem,pattern,maximum)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if string.find(value, [=[[a-fA-F-_;:'#+*~?<>]]=]) then
mark(elem)
return ret.wrong
end
if pattern == 3 then
if ( not ( string.match(value, [[^%d*[,.]%d%d%d$]]) or
string.match(value, [[^%d*[,.]%d%d$]]) or
string.match(value, [[^%d*[,.]%d$]]) or
string.match(value, [[^%d+[,.]?$]]) )) then
mark(elem)
return ret.format
end
elseif pattern == 2 then
if ( not ( string.match(value, [[^%d*[,.]%d%d$]]) or
string.match(value, [[^%d*[,.]%d$]]) or
string.match(value, [[^%d+[,.]?$]]) )) then
mark(elem)
return ret.format
end
else
if ( not string.match(value, [[^%d*[,.]?%d*$]]) ) then
mark(elem)
return ret.format
end
end
if string.find(value, ",") then
value = string.gsub(value, ",", ".")
end
value = tonumber(value)
if ( value > tonumber( maximum) ) then
mark(elem)
return ret.toomuch
end
return ret.ok
end
function valfunc.is_float_plus(elem, pattern, maximum, real_value)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if real_value then
value = tostring(real_value)
end
if string.find(value, [=[[a-fA-F_;:'#+*~?<>]]=]) then
mark(elem)
return ret.wrong
end
if params == 3 then
if not string.match(value, [[^%d?%d?%d?%.%d?%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%.%d?%d?%d?]])
and not string.match(value, [[^%d?%d?%d?%,%d?%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%,%d?%d?%d?]]) then
mark(elem)
return ret.format
end
elseif params == 2 then
if not string.match(value, [[^%d?%d?%d?%.%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%.%d?%d?]])
and not string.match(value, [[^%d?%d?%d?%,%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%,%d?%d?]]) then
mark(elem)
return ret.format
end
else
if not string.match(value, [[^%d?%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?]])
and not string.match(value, [[^%d?%d?%d?%.%d?%d?%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%.%d?%d?%d?%d?]])
and not string.match(value, [[^%d?%d?%d?%,%d?%d?%d?%d?]])
and not string.match(value, [[^%-%d?%d?%d?%,%d?%d?%d?%d?]]) then
mark(elem)
return ret.format
end
end
if string.find(value, ",") then
value = string.gsub(value, ",", ".")
end
value = tonumber(value)
if math.abs(value) > maximum then
mark(elem)
return ret.outofrange
end
return ret.ok
end
function valfunc.ipv6(elem)
local res = valfunc.not_empty(elem)
if res ~= ret.ok then
return res
end
local value = read_value(elem)
if not newval.is_ipv6(value) then
mark(elem)
return ret.format
end
return ret.ok
end
function valfunc.char_range_regex(name, regex)
local str = read_value(name)
if newval.pattern[regex] then
regex = newval.pattern[regex] or [[.*]]
end
if not string.find(str, regex) then
mark(name)
return ret.outofrange
end
return ret.ok
end
function valfunc.allowed_devicename(name, regex)
local str_name = read_value(name)
local allowed_hostname = nil
allowed_hostname = box.query("box:settings/allowed_hostname")
if allowed_hostname ~= str_name then
return valfunc.char_range_regex(name, regex)
end
return ret.ok
end
function valfunc.is_in_list(name, list)
local str_name = read_value(name)
for i = 1, #list ,1 do
if list[i] == str_name then
return ret.ok
end
end
return ret.outofrange
end
newval.pattern = {
okz = [[^0[2-9]%d*$]],
anynonwhitespace = [=[[^%s]]=],
fonnum = [[^%s*[%+]?[0-9%s/%-#\*]*$]],
fonnumex = [[^%s*[%+]?[0-9%s/%-%(%)#\*]*$]],
sipnum = [[^%s*[%+]?[%d%s/%-%(%)a-zA-Z]*$]],
dectchar = [[^[^%§]*$]],
decimals = [[^%d*$]],
hexvalue = [[^[a-fA-F0-9]*$]],
wepascii = [[^[a-zA-Z0-9]*$]],
workgroupname = [[^[a-zA-Z0-9%_%-]*$]],
nassharename = [[^[a-zA-Z0-9%-%.]*$]],
fbname = [[^[a-zA-Z0-9][a-zA-Z0-9%-]*[a-zA-Z0-9]$]],
hostname = [[^[a-zA-Z0-9][a-zA-Z0-9%-]*[a-zA-Z0-9]$]],
name_ex = [[^[äöüa-zA-Z0-9%-%(%)%s]*$]],
pcname = [[^[0-9]*[a-zA-Z%-]+[a-zA-Z0-9%-]*$]],
plcname = [[^[0-9]*[a-zA-Z%-%.]+[a-zA-Z0-9%-%.]*$]],
email = [[^[%a%d%.%!%#%$%%%&%'%*%+%-%/%=%?%^%_%`%{%|%}%~]+@[%a%d%.%-]+%.%a%a%a?%a?%a?%a?$]],
fqdn = [[^[%a%d%.%-]+%.%a%a%a?%a?%a?%a?:?%d*$]],
ipv4 = [[^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?$]],
ipv4_port = [[^%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:?%d*$]],
ipv6 = [[^%[?[%x:]+%]?:?%d*$]],
url = [[^[a-zA-Z0-9%ß%ä%ö%ü%!%*%'%(%)%,%.%-%~%_%@%&%?%=%:%;%/%+%%%#%$]*$]],
dectpin = [[^%d%d%d%d$]],
boxusername = [[^[a-zA-Z%-%._][a-zA-Z0-9%-%.%_ ]*$]],
boxpassword = [[^[a-zA-Z0-9 %!%"%#%$%%%&%'%(%)%*%+%,%-%.%/%:%;%<%=%>%?%@%[%\%]%^%_%`%{%|%}%~]*$]],
rdsstation = [[^[^%`%~%@%#%$%^%&%*%=%+%[%]%{%}%\%|%;%:%'%"%,%<%>%?%/]*$]],
nlrradioname = [[^[0-9A-ZÄÖÜa-zäöü%!%#%"%%%&%'%[%]%(%)%*%+%,%-%.%/%:%;%<%=%>%?%@%`%~%_ ]*$]]
}
return newval
