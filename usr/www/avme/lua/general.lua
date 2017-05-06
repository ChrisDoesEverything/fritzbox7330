--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("textdb")
require("config")
function dbg_out(txt)
end
function show_table(name,t)
end
function show_all_data(t,var_name)
end
function make_num(numstr)
local num=tonumber(numstr)
if num and type(num) == "number" then
return num
end
return 0
end
function sprintf(format, ...)
local str = string.gsub(format,"(%%%d+)%%%w+%%","%1")
for i=1, select('#', ...) do
local param = select(i, ...)
param = string.gsub(tostring(param), "%%", "%%%%")
str = string.gsub(str, "%%"..tostring(i), param)
end
return str
end
function tofixed(num, decimals, decimal_point)
local n = tonumber(num)
if not n then return num end
local fmt = "%f"
if decimals then fmt = "%." .. decimals .. "f" end
local s = string.format(fmt, n)
if decimal_point then s = s:gsub("%.", decimal_point) end
return s
end
function get_dsl_state()
require("libluadsl")
return luadsl.getOverviewStatus(1,"DS").STATE
end
function is_atamode (dataTable)
if not(dataTable) or (dataTable and type(dataTable) ~= "table") then
dataTable = {
ata_mode = box.query("box:settings/ata_mode")
}
end
return dataTable.ata_mode == "1"
end
local g_opmode = box.query("box:settings/opmode")
function is_ip_client ()
-- Wird die Box als IP-Client betrieben ?
return g_opmode == "opmode_eth_ipclient"
end
function is_router()
-- Wird die Box als Router betrieben?
-- d.h. nicht IP-Client oder DSL-Modem oder WDS Client etc.
return g_opmode ~= "opmode_eth_ipclient" and g_opmode ~='opmode_modem'
end
function is_dslmodem()
-- Wird die Box als DSL-Modem betrieben?
return g_opmode == "opmode_modem"
end
function inet_over_dsl()
if (config.LTE and config.DOCSIS) then
return false
end
return not (g_opmode:find("opmode_eth_") == 1 or g_opmode == "opmode_wlan_ip")
end
function is_wdsrepeater()
return config.WLAN and (config.WLAN_WDS or config.WLAN_WDS2)
and box.query("wlan:settings/WDS_enabled") == "1"
and box.query("wlan:settings/WDS_hop") == "1"
end
function get_active_tams(dataTable)
if (dataTable==nil) then
return 0
end
local tamActive = 0
local TamMode= config.TAM_MODE
if (TamMode > 0) then
for i=1,5,1 do
if (dataTable.Tam[i].active == "1") then
tamActive=tamActive+1
end
end
end
return tamActive
end
function get_display_tams(dataTable)
if (dataTable==nil) then
return 0
end
local tamDisplay=0
local TamMode= config.TAM_MODE
if (TamMode > 0) then
for i=1,5,1 do
if (dataTable.Tam[i].display == "1") then
tamDisplay=tamDisplay + 1
end
end
end
return tamDisplay
end
function is_bridged_mode(dataTable)
if (dataTable.ata_mode=="0" and dataTable.connection_type=="bridge" and dataTable.encapsulation=="dslencap_pppoe") then
return true
end
return false
end
function is_callblockade_active(dataTable)
if not(config.FON) then
return false
end
if (dataTable.CallerIdActions~=nil) then
for i, elem in ipairs(dataTable.CallerIdActions) do
if(elem.Action=="1") then
return true
end
end
end
if (dataTable.CallerIdRoutes~=nil) then
for i, elem in ipairs(dataTable.CallerIdRoutes) do
if(elem.Route=="s") then
return true
end
end
end
return false
end
function is_onlinecounter_active(dataTable)
if config.DSL or config.VDSL then
if (dataTable.boxDate ~= "" and box.query("connection0:settings/Budget/Enabled")=="1") then
return not is_ip_client()
end
end
return false
end
function is_budget_reached()
local strWarn = "";
local timeBudgetReached = box.query("box:status/hint_time_budget_reached")
if (timeBudgetReached == "1") then
strWarn = TXT([[{?3085:649?}]])
end
local volBudgetReached = box.query("box:status/hint_volume_budget_reached")
if (volBudgetReached == "1") then
strWarn = TXT([[{?3085:587?}]])
end
return strWarn~="",strWarn
end
local timestrings = {};
timestrings.hmStr =
{{TXT([[{?3085:57?}]]) ,TXT([[{?3085:856?}]]),TXT([[{?3085:501?}]])},
{TXT([[{?3085:582?}]]) ,TXT([[{?3085:6864?}]]),TXT([[{?3085:790?}]])},
{TXT([[{?3085:976?}]]),TXT([[{?3085:7431?}]]),TXT([[{?3085:894?}]])}
}
timestrings.getHmStr =
function (h,m)
local idxH = math.min(h,2)+1;
local idxM = math.min(m,2)+1;
return sprintf(timestrings.hmStr[idxH][idxM], tostring(h), tostring(m))
end
timestrings.ofHStr = {TXT([[{?3085:559?}]]),TXT([[{?3085:674?}]])}
timestrings.getOfHStr =
function (strPrefix,h)
local idx = 2;
if (h == 1) then
idx = 1;
end
return sprintf(timestrings.ofHStr[idx], tostring(strPrefix),tostring(h))
end
timestrings.convert_to_str_with_sec =
function (sec)
local _time=make_num(sec)
sec=_time%60
_time=math.floor(_time/60);
local minutes = _time%60;
local hours = math.floor(_time/60);
return sprintf(TXT([[{?3085:445?}]]),string.format("%02d",hours),string.format("%02d",minutes),string.format("%02d",sec))
end
timestrings.get_day_str =
function(days,hours,minutes)
local dayStr = {
TXT([[{?3085:484?}]]),
TXT([[{?3085:365?}]]),
TXT([[{?3085:250?}]]),
TXT([[{?3085:871?}]]),
TXT([[{?3085:996?}]]),
TXT([[{?3085:902?}]]),
TXT([[{?3085:30?}]]),
TXT([[{?3085:822?}]])
}
local idx=5
if days==1 then
if hours==1 then
if minutes==1 then
idx=2
else
idx=4
end
else
if minutes==1 then
idx=3
else
idx=1
end
end
else
if hours==1 then
if minutes==1 then
idx=6
else
idx=8
end
else
if minutes==1 then
idx=7
else
idx=5
end
end
end
return dayStr[idx]
end
timestrings.convert_to_str_with_day =
function (sec)
local _time=make_num(sec)
sec=_time%60
_time=math.floor(_time/60);
local minutes = _time%60;
local hours = math.floor(_time/60)
local days = math.floor(hours/24)
if (days==0) then
return timestrings.getHmStr(hours,minutes)
end
hours = hours%24
return sprintf(timestrings.get_day_str(days,hours,minutes),days, hours,minutes)
end
timestrings.convert_to_str =
function (sec)
local sec=make_num(sec)
sec=math.ceil(sec/60);
local minutes = sec%60;
local hours = math.floor(sec/60);
return sprintf(TXT([[{?3085:507?}]]),hours,string.format("%02d",minutes))
end
function convert_to_str(sec)
return timestrings.convert_to_str(sec)
end
function convert_to_str_with_sec(sec)
return timestrings.convert_to_str_with_sec(sec)
end
function convert_to_str_with_day(sec)
return timestrings.convert_to_str_with_day(sec)
end
function getHmStr(h,m)
return timestrings.getHmStr(h,m)
end
function get_online_usage_str(h,m,limit)
return timestrings.getOfHStr(timestrings.getHmStr(h,m),limit)
end
local _Mega = 1000000
local _Shift32 = 4294967296
local g_Kilo = 1000
local g_Mega = 1000000 --1000*1000;
local g_Giga = 1000000000 --1000*1000*1000;
local function mb2byte(mb) return math.floor(_Mega*mb) end
local function byte2mb(b) return math.floor(b/_Mega + 0.5)end
local function byte2low(b) return tonumber(b%_Shift32,10) end
local function byte2high(b) return math.floor(b/_Shift32) end
function highlow2byte(h,l) return h*_Shift32+l end
local function byte2kb(b) return math.floor(b/g_Kilo); end
local function byte2gb(b) return tostring(math.floor(b/g_Giga))..","..tostring(math.floor(b/(g_Giga/10)%10))..tostring(math.floor(b/(g_Giga/100)%10)) end
function get_onlinecounter_data()
local maxtime = math.ceil(make_num(box.query("connection0:settings/Budget/ConnectionTime"))/60);
local maxh = math.ceil(maxtime/60);
local cur = math.ceil(make_num(box.query("inetstat:status/ThisMonth/PhyConnTimeOutgoing"))/60);
local hours = math.floor(cur/60);
local minutes = math.ceil(cur%60);
local curmb = hours*60+minutes
local show=true
if config.VOL_COUNTER then
if (maxtime==0) then
local maxlow = make_num(box.query("connection0:settings/Budget/VolumeLow"))
local maxhigh = make_num(box.query("connection0:settings/Budget/VolumeHigh"))
local reclow = make_num(box.query("inetstat:status/ThisMonth/BytesReceivedLow"))
local rechigh = make_num(box.query("inetstat:status/ThisMonth/BytesReceivedHigh"))
local sentlow = make_num(box.query("inetstat:status/ThisMonth/BytesSentLow"))
local senthigh = make_num(box.query("inetstat:status/ThisMonth/BytesSentHigh"))
local maxvol = highlow2byte(maxhigh,maxlow)
local curvol = highlow2byte(rechigh,reclow) + highlow2byte(senthigh,sentlow)
local maxmb = byte2mb(maxvol)
curmb = byte2mb(curvol)
return hours,minutes,curmb,maxmb,maxtime,maxvol
end
end
return hours,minutes,curmb,maxh,maxtime,0
end
function make_vol_data(val)
local tmp=tonumber(val,10)
if tmp==nil then
return "0","0"
end
--local tmp = mb2byte(box.post.budget_vol);
local tmp = mb2byte(tmp);
local tmphigh = byte2high(tmp);
tmphigh = byte2low(tmphigh); -- Damit ist auch tmphigh höchstens 32-Bit
local tmplow = byte2low(tmp)
return tostring(tmphigh),tostring(tmplow)
end
function get_onlinecounter_amount()
local show=true
local hours,minutes,curmb,maxmb,maxtime,maxvol=get_onlinecounter_data()
local retstr = timestrings.getOfHStr(hours,maxmb)
if config.VOL_COUNTER then
if (maxtime==0) then
if curmb==0 then
show=false
end
local curr_str = string.format([[%d]], curmb)
retstr = curr_str.." "..TXT([[{?3085:977?}]]).." "..maxmb.." "..TXT([[{?3085:527?}]])
end
end
return retstr, show
end
function is_remote_https_active(dataTable)
if not(config.REMOTE_HTTPS) then
return false
end
local remote_active=box.query("remoteman:settings/enabled")
local showRemoteHttps=false
if (remote_active== "1") then
showRemoteHttps= true
end
if (is_bridged_mode(dataTable)) then
showRemoteHttps = false
end
if config.USB_GSM then
if (dataTable.umts_enabled=="1" and remote_active=="1") then
showRemoteHttps = true
end
end
return showRemoteHttps
end
function is_gsm_on_or_pin_set()
return box.query("gsm:settings/PinEmpty") == '0'
or box.query("gsm:settings/ModemPresent") == '1'
end
function is_gsm_active()
return box.query("gsm:settings/Established") =='1' and is_gsm_on_or_pin_set()
end
function is_email_active(dataTable)
local showEmail = false;
-- Alt: Es wurde geschaut ob eine Verbindung zum Internet hersgestellt werden konnte
-- Neu: Es ist nicht wichtig ob man ins internet kann nur ob Das Feature an ist und eventuell durch andere Bedingungen direkt deaktiviert werden kann
if config.MAILER or config.MAILER2 then
--if config.DSL or config.VDSL then --Kabel LTE prüfungen würden Fehlen wenn das wieder rein Kommt
showEmail = true
--end
end
--if (is_gsm_active()) then
-- showEmail = true
--elseif (is_bridged_mode(dataTable)) then
if (is_bridged_mode(dataTable)) then
showEmail = false
end
if (showEmail == true) then
showEmail = (box.query("emailnotify:settings/infoenabled")=="1")
end
return showEmail
end
function any_portrelease_active(dataTable)
local showPortfreigabe = false
if (dataTable.connection_type == "pppoe") then
showPortfreigabe = true
end
if (dataTable.encapsulation=="dslencap_ether") or
(dataTable.encapsulation=="dslencap_ipnlpid") or
(dataTable.encapsulation=="dslencap_ipsnap") or
(dataTable.encapsulation=="dslencap_ipraw") then
showPortfreigabe = true
end
if config.USB_GSM and dataTable.umts_enabled == "1" then
showPortfreigabe = true
end
return showPortfreigabe
end
function any_portrelease_info(dataTable)
if (any_portrelease_active(dataTable)==false) then
return false
end
local showPortfreigabeInfo = false
for i,elem in ipairs(dataTable.forwardrules) do
if (elem.activated == "1") then
return true
end
end
if (dataTable.use_exposed_host == "1" and dataTable.exposed_host ~="") then
return true
end
if (dataTable.upnp_activated=="1" and
dataTable.upnp_control_activated=="1" and
(#dataTable.igdforwardrules ~= 0)) then
return true
end
return false
end
function is_kids_active(dataTable)
if not(config.KIDS) then
return false
end
return box.query("userglobal:status/active") == "1"
end
function is_call_rerouting_active(dataTable)
local cntRufumleitungActiv = 0
local cntRufumleitungAll = 0
if not(config.FON) then
return cntRufumleitungAll, cntRufumleitungActiv
end
local mode = "";
local ziel = "";
for i=0,2,1 do
mode = box.query("telcfg:settings/MSN/Port"..i.."/Diversion")
ziel = box.query("telcfg:settings/MSN/Port"..i.."/DiversionNumber")
if (mode=="err" or ziel=="err") then
break
end
if mode ~= "0" then
cntRufumleitungAll=cntRufumleitungAll+1
if ziel ~= "" then
cntRufumleitungActiv=cntRufumleitungActiv+1
end
end
end
if (dataTable.DiversityList) then
for i,elem in ipairs(dataTable.DiversityList) do
if (elem.Active == "1" or count_all) then
cntRufumleitungActiv=cntRufumleitungActiv+1
end
cntRufumleitungAll=cntRufumleitungAll+1
end
end
if (dataTable.CallerIdActions) then
for i,elem in ipairs(dataTable.CallerIdActions) do
if (elem.Action=="0") then
if (elem.Active == "1" or count_all) then
cntRufumleitungActiv=cntRufumleitungActiv+1;
end
cntRufumleitungAll=cntRufumleitungAll+1
end
end
end
return cntRufumleitungAll, cntRufumleitungActiv
end
function is_komfort_feature_active(dataTable)
local showInfoLed = false
if (1 < make_num(box.query("box:settings/infoled_reason"))) then
showInfoLed = true
end
local callReroute=is_call_rerouting_active(dataTable)
if (showInfoLed == true or
dataTable.NightlockEnabled == "1" or
is_email_active(dataTable) or
is_kids_active(dataTable) or
any_portrelease_info(dataTable) or
dataTable.callthroughActive == "1" or
get_active_tams(dataTable) > 0 or
get_display_tams(dataTable) > 0 or
dataTable.intFaxActive==true or
dataTable.Alarmclock1Active == "1" or
dataTable.Alarmclock2Active == "1" or
is_callblockade_active(dataTable) or
callReroute.RufumleitungAktiv == true or
callReroute.cntRufumleitung > 0 or
is_remote_https_active(dataTable) or
dataTable.ddns_activated == "1" or
is_onlinecounter_active(dataTable) or
dataTable.InternalMemEnabled == "1") then
return true
end
return false
end
function get_remote_https_url(dataTable)
local connectiontype = dataTable.connection_type
local status = dataTable.connection_status
local caps = dataTable.encapsulation
if (is_atamode(dataTable)) then
if (not(caps == "dslencap_ether" or
caps == "dslencap_ipnlpid" or
caps == "dslencap_ipsnap" or
caps == "dslencap_ipraw")) then
if (status == "3" and status~="5") then
return ""
end
end
else
if (connectiontype == "pppoe" and caps == "dslencap_pppoe" and status == "3") then
return ""
end
end
local result = ""
if(dataTable.ddns_activated=="1" and
dataTable.ddns_password~="" and
dataTable.ddns_username~="" and
dataTable.ddns_provider~="")then
result = dataTable.ddns_domain
else
if (dataTable.dslite_active) then
result = dataTable.ipv6_ip
if result and result ~= "" then
result = "[" .. result .. "]"
end
elseif (dataTable.pppoe_ip ~= "" and
dataTable.pppoe_ip ~= "-" and
dataTable.pppoe_ip ~= "er" and
dataTable.pppoe_ip ~= "0.0.0.0") then
result = dataTable.pppoe_ip
end
end
if result and result ~= "" then
local port = box.query("remoteman:settings/https_port")
if port == "443" then port = "" end
if port ~= "" then port = ":" .. port end
result = "https://" .. result .. port
end
return result or ""
end
function port_range(pa,pe,pb)
if (pe=="" or pa==pe) then
return pb
end
a = tonumber(pa,10)
e = tonumber(pe,10)
b = tonumber(pb,10)
if (a==nil or e==nil or b==nil) then
return ""
end
return tostring(b).."-"..tostring(b+(e-a))
end
function get_icon_button(imgpath, id, name, val, title, onclick, disabled)
local str= [[<button type="submit" class="icon" id="]]..id..[["]]
if name then
str = str .. [[ name="]]..name..[["]]
else
str = str .. [[ name="]]..id..[["]]
end
if val then
str = str .. [[ value="]]..val..[["]]
end
if title then
str = str .. [[ title="]]..box.tohtml(title)..[["]]
end
if onclick and onclick~="" then
str = str .. [[ onclick="return ]]..onclick..[["]]
end
if disabled then
str = str .. [[ disabled ]]
end
str = str .. [[><img src="]]..imgpath..[["]]
if title then
str = str .. [[ alt="]]..box.tohtml(title)..[["]]
end
str = str .. [[/></button>]]
return str
end
local function parse_rows(qs)
local pos = string.find(qs, "%(")
if pos == nil then
return nil
end
-- landevice:settings/landevice/list(name,ip,mac)
-- params: ^^^^^^^^^^^
local params = string.sub(qs, pos+1, string.len(qs)-1)
local skipParam=0
if (string.find(qs,"listwindow")) then
-- landevice:settings/landevice/listwindow(von, bis, name,ip,mac)
-- params: ^^^^^^^^^^^
skipParam=2
end
local rows = {}
for p in string.gmatch(params, "[^,]+") do
if (skipParam<=0) then
table.insert(rows, p)
else
skipParam=skipParam-1
end
end
return rows
end
function listquery(querystring, cb_func)
local raw_result = box.multiquery(querystring)
local params = parse_rows(querystring) or {}
table.insert(params, 1, #params > 0 and "_node" or 1)
local result = {}
for _, val_table in ipairs(raw_result or {}) do
local t = {}
for i, value in ipairs(val_table) do
t[params[i] or i] = value
end
table.insert(result, t)
if cb_func and type(cb_func)=="function" then
cb_func(#result, t)
end
end
return result
end
function lazytable(tbl, getter, vars)
local mt = getmetatable(tbl) or {}
local oldindex = mt.__index
local oldindex_isfunc = type(oldindex) == 'function'
mt.__index = function(self, key)
if vars[key] then
local result = getter(unpack(vars[key]))
self[key] = result
return result
end
if oldindex then
if oldindex_isfunc then return oldindex(self, key)
else return oldindex[key]
end
end
end
return setmetatable(tbl, mt)
end
function build_ds_us_strings(ds, us, kbit_str, mbit_str)
local ds_str = sprintf(kbit_str, ds)
if ds >= 1000 then
ds_str = sprintf(mbit_str, string.gsub(string.format("%.1f", ds / 1000), "%.", ","))
end
local us_str = sprintf(kbit_str, us)
if us >= 1000 then
us_str = sprintf(mbit_str, string.gsub(string.format("%.1f", us / 1000), "%.", ","))
end
return ds_str, us_str
end
function sorted_by_i(tbl)
local order = table.filter(tbl, function(v, k) return k:find("_i", -2) and type(v) == 'number' end)
order = table.transpose(order)
order = array.map(order, function(v) return v:sub(1, -3) end)
return order
end
function is_webvar(str)
if type(str) ~= 'string' then return false end
return str:match("^.+(:settings/).+$")
or str:match("^.+(:status/).+$")
or str:match("^.+(:command/).+$")
end
function is_expert()
return (box.query("box:settings/expertmode/activated")=="1")
end
function get_bridge_mode()
local mode=box.query("wlan:settings/bridge_mode")
local rep_mode="wlan_bridge"
if (mode=="bridge-none") then
rep_mode = "wlan_bridge"
elseif (mode=="bridge-lan") then
rep_mode = "lan_bridge"
elseif (mode=="bridge-wlan") then
rep_mode = "wlan_bridge"
elseif (mode=="bridge-plc") then
rep_mode = "plc_bridge"
end
return rep_mode
end
function is_ipv6_dslite()
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
local mode = box.query("ipv6:settings/ipv4_active_mode")
return mode and mode ~= "er" and mode ~= "ipv4_normal"
end
return false
end
function is_ipv6_active()
if config.IPV6 and box.query("ipv6:settings/enabled") == "1" then
return true
end
return false
end
function get_date_without_year(Calldate,long)
local str=Calldate
local dd=string_op.split2table(Calldate," ",0)
-- dd enthält nun das Datum und die Uhrzeit getrennt
-- dd[1] ist das Datum 12.11.10
-- dd[2] ist die Uhrzeit 14:23
local xx=string_op.split2table(dd[1],".",0)
-- xx[1] wäre der Tag
-- xx[2] wäre der Monat
-- xx[3] wäre das Jahr
local months ={ TXT([[{?3085:818?}]]),
TXT([[{?3085:337?}]]),
TXT([[{?3085:904?}]]),
TXT([[{?3085:530?}]]),
TXT([[{?3085:615?}]]),
TXT([[{?3085:10?}]]),
TXT([[{?3085:12?}]]),
TXT([[{?3085:210?}]]),
TXT([[{?3085:412?}]]),
TXT([[{?3085:780?}]]),
TXT([[{?3085:327?}]]),
TXT([[{?3085:945?}]])}
local months_long ={ TXT([[{?3085:834?}]]),
TXT([[{?3085:391?}]]),
TXT([[{?3085:441?}]]),
TXT([[{?3085:232?}]]),
TXT([[{?3085:8?}]]),
TXT([[{?3085:328?}]]),
TXT([[{?3085:258?}]]),
TXT([[{?3085:3535?}]]),
TXT([[{?3085:870?}]]),
TXT([[{?3085:157?}]]),
TXT([[{?3085:536?}]]),
TXT([[{?3085:793?}]])}
local idx=general.make_num(xx[2])
if (idx<=0 or idx>12) then
--Umwandlung klappt nicht alles unverändert.
str=Calldate
else
if (long and long==true) then
str=tostring(xx[1])..[[.]]..months_long[idx]..[[ ]]..dd[2]
else
str=tostring(xx[1])..[[.]]..months[idx]..[[ ]]..dd[2]
end
end
return str
end
function boxip_isdefault()
local ip = box.query("interfaces:settings/lan0/ipaddr")
return ip == [[192.168.178.1]]
end
function wlan_active(band)
local ap = box.query("wlan:settings/ap_enabled") == "1"
local ap_scnd = box.query("wlan:settings/ap_enabled_scnd") == "1"
local bg_mode = tonumber(box.query("wlan:settings/bg_mode"))
if config.WLAN.is_double_wlan then
if band == '2.4' or band == '2,4' then
return ap
elseif band == '5' then
return ap_scnd
else
return ap or ap_scnd
end
else
if band == '2.4' or band == '2,4' then
return ap and bg_mode and bg_mode < 50
elseif band == '5' then
return ap and bg_mode and bg_mode > 50
else
return ap
end
end
end
function create_error_div(err,msg,add)
-- de-first -begin
local errmsg=[[<div class="LuaSaveVarError">]]..box.tohtml(TXT([[{?431:744?}]]))
if msg ~= nil and msg ~= "" then
errmsg = errmsg..[[<br>]]..box.tohtml(TXT([[{?431:319?}]]))..[[ ]]..box.tohtml(msg)
else
errmsg = errmsg..[[<br>]]..box.tohtml(TXT([[{?431:182?}]]))..[[ ]]..box.tohtml(err)
end
if (add) then
errmsg=errmsg..[[<br>]]..box.tohtml(add)
end
errmsg = errmsg..[[<br>]]..box.tohtml(TXT([[{?3085:748?}]]))..[[</div>]]
return errmsg
-- de-first -end
end
function has_lanport()
return true
end
local g_page_is_assi=false
function set_assi(is_assi)
g_page_is_assi=is_assi or false
end
function is_assi()
return g_page_is_assi
end
function get_dyndns_state(nState)
local state=""
if (nState==0) then
state=TXT("{?3085:90?}")
elseif (nState==3) then
state=TXT("{?3085:437?}")
elseif (nState==5) then
state=TXT("{?3085:542?}")
elseif (nState==97) then
state=TXT("{?3085:289?}")
elseif (nState==98) then
state=TXT("{?3085:850?}")
elseif (nState==99) then
state=TXT("{?3085:253?}")
else
state=TXT("{?3085:879?}")
end
return state
end
function clear_whitespace(str, replacement)
replacement = replacement or ""
return (string.gsub(str or "", "%s+", replacement))
end
function Callnumber_string(cnt)
if cnt == 1 then
return TXT([[{?3085:732?}]])
else
return TXT([[{?3085:295?}]])
end
end
function fritz_os_update()
return box.tohtml(TXT([[{?3085:28?}]]))..[[: <a href="]]..href.get("/system/update.lua","check=1","start=1")..[[">]]..box.tohtml(TXT([[{?3085:460?}]]))..[[</a>]]
end
function pwd_info()
return [[<a href="]] .. href.get('/system/boxuser_settings.lua') .. [[" title="]]..box.tohtml(TXT([[{?3085:555?}]]))..[[">]]..box.tohtml(TXT([[{?537:66?}]]))..[[</a>]]
end
function get_registered_dect(data)
local countDect=0
if (data and data.dect_device_list~=nil) then
for i, elem in ipairs(data.dect_device_list) do
if (elem.Subscribed=="1") then
countDect=countDect+1
end
end
end
return countDect
end
function get_txt_dect(data)
local countDect=get_registered_dect(data)
local Displaytxt=""
if (countDect==0) then
Displaytxt=TXT([[{?3085:926?}]])
elseif (countDect==1) then
Displaytxt=TXT([[{?3085:238?}]])
else
Displaytxt=general.sprintf(TXT([[{?3085:499?}]]),countDect)
end
return Displaytxt
end
function get_dect_info(data)
if data and not data.dect_enabled then
return ""
end
local Displaytxt=TXT([[{?3085:432?}]])..[[, ]]..get_txt_dect(data)
return Displaytxt
end
