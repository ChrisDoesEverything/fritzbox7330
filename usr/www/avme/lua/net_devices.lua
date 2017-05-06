--[[Access denied<?lua
box.end_page()
?>]]
module(..., package.seeall);
require("config")
require("general")
require("utf8")
require("textdb")
require("cmtable")
require("html")
g_init = ""
g_list = {}
g_WlanList= {}
g_KisiList= {}
g_PlcList= {}
local filter_userlist
function get_kisiuser(dev)
require"filter"
local kisi = {}
if type(dev.kisi_idx) == 'number' then
kisi = g_KisiList[dev.kisi_idx] or {}
end
local user = nil
filter_userlist = filter_userlist or filter.read_userlist()
local idx
if kisi.UID and kisi.UID ~= "" then
idx, user = array.find(filter_userlist.ip_user, func.eq(kisi.UID, "UID"))
if not user then
idx, user = array.find(filter_userlist.pc_user, func.eq(kisi.UID, "UID"))
end
elseif kisi.auto and kisi.id then
idx, user = array.find(filter_userlist.pc_user, func.eq(kisi.id, "autouser"))
elseif dev.guest == "1" then
user = {guest=true}
else
idx, user = array.find(filter_userlist.ip_user, func.eq(dev.UID, "landevice"))
end
return user
end
function get_count()
if config.GUI_IS_REPEATER then
local count=0
for idx, elem in ipairs(g_list) do
if (elem.is_ap~="1") then
count=count+1
end
end
return count
else
return #g_list
end
end
function find_dev_by_uid(list, uid)
if (not list or not uid or uid == "") then
return nil, nil
end
for idx, elem in ipairs(list) do
if tostring(elem.UID) == uid then
return idx, elem
end
if elem.wlan_UIDs and string.find(elem.wlan_UIDs,uid) then
return idx, elem
end
end
return nil, nil
end
function get_parental_control_abuse_count()
return #array.filter(net_devices.g_list, function(elem)
return elem.active == "1" and elem.parental_control_abuse == "1"
end)
end
function get_online_dev_count()
local net_device_list = net_devices.g_list
local online_dev_count = 0
for i, elem in ipairs(net_device_list) do
if elem.online=="1" and elem.active=="1" then
online_dev_count = online_dev_count + 1
end
end
return online_dev_count, #net_device_list
end
function find_dev_by_node(list, node_name)
if (not list or not node_name or node_name == "") then
return nil, nil
end
for idx, elem in ipairs(list) do
if tostring(elem._node) == node_name then
return idx, elem
end
end
return nil, nil
end
function find_dev_by_id(list, id)
if (not list or not id or id == "") then
return nil, nil
end
for idx, elem in ipairs(list) do
if tostring(elem.id) == id then
return idx, elem
end
end
return nil, nil
end
function find_dev_by_name(list, name)
if (not list or not name or name == "") then
return nil, nil
end
for idx, elem in ipairs(list) do
if tostring(elem.name) == name then
return idx, elem
end
end
return nil, nil
end
function any_user(list)
if (not list ) then
return false
end
for idx, elem in ipairs(list) do
if tostring(elem.type) == "user" then
return true
end
end
return false
end
function find_dev_by_key(list, key, value)
if (not list or not key) then
return nil, nil
end
for idx, elem in ipairs(list) do
if elem[key] == value then
return idx, elem
end
end
return nil, nil
end
function find_dev_by_mac(list, mac)
return find_dev_by_key(list, "mac", mac)
end
function get_rule_part(szValue)
local l_szRet1 = ""
local l_szRet2 = ""
local l_szRet3 = ""
local l_Pos = 0
l_Pos = string.find( szValue, " ")
l_szRet1 = string.sub( szValue, 1, (l_Pos-1))
local l_Pos2 = l_Pos
l_Pos = string.find( szValue, "-")
if ( l_Pos ~= nil) then
l_szRet2 = string.sub( szValue, (l_Pos2+1), (l_Pos-1))
l_szRet3 = string.sub( szValue, (l_Pos+1))
else
l_szRet2 = string.sub( szValue, (l_Pos2+1))
end
return l_szRet1, l_szRet2, l_szRet3
end
function get_displayname_lower(device)
local str = ""
if (device.displayname and device.displayname~="") then
str = string.lower(device.displayname)
elseif (device.name and device.name~="") then
str = string.lower(device.name)
end
return str
end
function get_displayname(device)
local str = ""
if (device.displayname and device.displayname~="") then
str = device.displayname
elseif (device.name and device.name~="") then
str = device.name
end
return str
end
function index_In_List(list,valname,val, startIndex)
if (list==nil) then
return -1
end
if (val=="") then
return -1
end
if (startIndex and startIndex~=-1) then
for j,elem in ipairs(list) do
if (j>startIndex) then
if (elem[valname] == val) then
return j
end
end
end
else
for j,elem in ipairs(list) do
if (elem[valname] == val) then
return j
end
end
end
return -1
end
function add_kids_to_list()
if config.KIDS then
g_KisiList=general.listquery("user:settings/user/list("
.. "type,name,UID,hostname,filter_profile_UID"
--.. ",monday_thursday_allowed,budget_time_monday_thursday,monday_thursday_start_time,monday_thursday_end_time,friday_allowed,budget_time_friday,friday_start_time,friday_end_time,saturday_allowed,budget_time_saturday,saturday_start_time,saturday_end_time,sunday_allowed,budget_time_sunday,sunday_start_time,sunday_end_time"
.. ")")
local autouserlist=general.listquery("autouser:status/autouser/list(type,name,UID,hostname)")
for i,elem in ipairs(autouserlist) do
table.insert(g_KisiList, { id=elem._node,
UID = elem.UID,
type=elem.type,
name=elem.name,
hostname=elem.hostname,
auto=true
})
end
--
for i,elem in ipairs(g_KisiList) do
local kisiInfo = ""
if (elem.auto) then
kisiInfo = 'auto'
else
kisiInfo = 'active'
end
if (elem.type=="3" or elem.type == "4") then
elseif ( elem.type=="2") then
table.insert(g_list, { id= elem._node,
UID = elem.UID,
name= elem.name,
type= "user",
active="0",
kisi=kisiInfo,
kisi_idx=i
})
elseif (elem.type=="1") then
local idx = index_In_List(g_list,'ip',elem.name)
if idx >= 0 and g_list[idx].guest ~= "1" then
g_list[idx].kisi = kisiInfo
g_list[idx].kisi_idx = i
g_list[idx].kisi_UID = elem.UID
if (g_list[idx].type == 'unknown') then
g_list[idx].type = "ipuser"
end
end
elseif ( not elem.auto) then
table.insert(g_list, { id= elem._node,
UID = elem.UID,
ip= elem.name,
name= elem.hostname,
type= "ipuser",
active="0",
kisi=kisiInfo,
kisi_idx=i
})
end
end
end
end
function merge(i,elem)
for j,lan_elem in ipairs(g_list) do
if (lan_elem.wlan_UIDs == elem.UID) then
lan_elem.wlan_idx = i
lan_elem.wlan_node = elem._node
lan_elem.wlan_UID = elem.UID
lan_elem.wlan_mac = elem.mac
lan_elem=table.extend(lan_elem,elem)
end
end
end
function add_wlan_to_list()
if config.WLAN then
if config.GUI_IS_REPEATER then
g_WlanList=general.listquery("wlan:settings/wlanlist/list(hostname,mac,UID,state,quality,cipher,wmm_active,powersave,is_ap,ap_state,flags,flags_set,mode,speed_rx,channel_width,streams)")
else
g_WlanList=general.listquery("wlan:settings/wlanlist/list(hostname,mac,UID,state,rssi,quality,is_turbo,wmm_active,cipher,powersave,is_repeater,flags,flags_set,mode,is_guest,speed_rx,channel_width,streams)")
end
for i,elem in ipairs(g_WlanList) do
merge(i,elem)
end
end
end
function get_plc_name(name, isAVM)
local str = name
if not name or name == "" then
if isAVM then
str = TXT([[{?3508:54?}]])
else
str = TXT([[{?3508:760?}]])
end
end
return str
end
function get_manufactor_name(manufactor, isAVM)
if isAVM then
return [[AVM GmbH]]
end
return manufactor
end
function get_modell_name(model, isAVM)
if isAVM then
return [[FRITZ!Powerline ]]..model
end
return ""
end
function get_plc_on_port(port)
for i,lan_elem in ipairs(g_list) do
if (lan_elem.plc == "1" and lan_elem.ethernet_port == port and lan_elem.isLocal) then
return lan_elem
end
end
return nil
end
function get_remote_plc_for_mac(searchmac)
for i,lan_elem in ipairs(g_list) do
if (lan_elem.plc == "1" and not lan_elem.isLocal) then
for j=1, #(lan_elem.ConnectedDevices or {}) do
if (string.lower(searchmac) == string.lower(lan_elem.ConnectedDevices[j])) then
return lan_elem
end
end
end
end
return nil
end
function find_own_plc()
for i,elem in ipairs(g_list) do
if (elem.is_internal) then
return elem.UID, elem
end
end
return "",{}
end
function add_plc_to_list()
require("string_op")
if config.PLC_DETECTION then
g_PlcList=general.listquery("plc:settings/device/list(manufactor,usr,mac,isLocal,model,phyRateRX,phyRateTX,green,class,led,isAVM,firmwareVersion,isDefaultNMK,ethernetrate,bridgedDevices,hasFirmwareupdate,firmwareupdateVersion,canSetLEDs,canSetGreenMode,isInternal,firmwareupdate,status,writeStatus,couplingClass,couplingTX,couplingRX)")
for i,plc_elem in ipairs(g_PlcList) do
local found = 0
for j,lan_elem in ipairs(g_list) do
if (lan_elem.mac == plc_elem.mac) then
found = 1
lan_elem.id = plc_elem._node
lan_elem.isAVM = plc_elem.isAVM == "YES"
lan_elem.name = get_plc_name(plc_elem.usr, lan_elem.isAVM)
lan_elem.manufactor = get_manufactor_name(plc_elem.manufactor, lan_elem.isAVM)
lan_elem.type = "plc"
lan_elem.status = plc_elem.status
if plc_elem.status and plc_elem.status ~= "" then
if string.sub( plc_elem.status,1,6) == "ACTIVE" then
lan_elem.active = "1"
else
lan_elem.active = "0"
end
else
lan_elem.active = "0"
end
lan_elem.writeStatus = plc_elem.writeStatus
lan_elem.isLocal = plc_elem.isLocal == "1"
lan_elem.model = get_modell_name(plc_elem.model, lan_elem.isAVM)
lan_elem.phyRateRX = plc_elem.phyRateRX
lan_elem.phyRateTX = plc_elem.phyRateTX
lan_elem.green = plc_elem.green
lan_elem.class = plc_elem.class
lan_elem.led = plc_elem.led
lan_elem.firmwareVersion = plc_elem.firmwareVersion
lan_elem.isDefaultNMK = plc_elem.isDefaultNMK
lan_elem.ethernetrate = plc_elem.ethernetrate
lan_elem.ConnectedDevices=string_op.split2table(plc_elem.bridgedDevices,",",0)
lan_elem.hasFirmwareupdate = plc_elem.hasFirmwareupdate
lan_elem.firmwareupdate = plc_elem.firmwareupdate == "1"
lan_elem.firmwareupdateVersion = plc_elem.firmwareupdateVersion
lan_elem.canSetLEDs = plc_elem.canSetLEDs == "1"
lan_elem.canSetGreenMode = plc_elem.canSetGreenMode == "1"
lan_elem.is_internal = plc_elem.isInternal == "1"
lan_elem.couplingClass = plc_elem.couplingClass
lan_elem.couplingTX = plc_elem.couplingTX
lan_elem.couplingRX = plc_elem.couplingRX
break
end
end
if (found == 0) then
table.insert(g_list, { id = plc_elem._node,
isAVM = plc_elem.isAVM == "YES",
mac = plc_elem.mac,
UID = plc_elem.mac,
name = get_plc_name(plc_elem.usr, plc_elem.isAVM == "YES"),
manufactor = get_manufactor_name(plc_elem.manufactor, plc_elem.isAVM == "YES"),
type= "plc",
active = (string.sub( plc_elem.status,1,6) == "ACTIVE") and "1" or "0",
status = plc_elem.status,
writeStatus = plc_elem.writeStatus,
isLocal = plc_elem.isLocal == "1",
model = get_modell_name(plc_elem.model, plc_elem.isAVM == "YES"),
phyRateRX = plc_elem.phyRateRX,
phyRateTX = plc_elem.phyRateTX,
green = plc_elem.green,
class = plc_elem.class,
led = plc_elem.led,
firmwareVersion = plc_elem.firmwareVersion,
isDefaultNMK = plc_elem.isDefaultNMK,
ethernetrate = plc_elem.ethernetrate,
ConnectedDevices=string_op.split2table(plc_elem.bridgedDevices,",",0),
hasFirmwareupdate = plc_elem.hasFirmwareupdate,
firmwareupdateVersion = plc_elem.firmwareupdateVersion,
firmwareupdate = plc_elem.firmwareupdate == "1",
canSetLEDs = plc_elem.canSetLEDs == "1",
canSetGreenMode = plc_elem.canSetGreenMode == "1",
is_internal = plc_elem.isInternal == "1",
couplingClass = plc_elem.couplingClass,
couplingTX = plc_elem.couplingTX,
couplingRX = plc_elem.couplingRX
})
end
end
for j,lan_elem in ipairs(g_list) do
local plc = get_remote_plc_for_mac(lan_elem.mac)
if not plc and lan_elem.plc == "1" then
plc = get_plc_on_port(lan_elem.ethernet_port) -- only plc (to get the connection between two 520E)
end
if plc then
if plc.name~="" and plc.name ~= lan_elem.name then
lan_elem.parentname = plc.name
end
if plc.UID~="" and plc.UID ~= lan_elem.UID then
lan_elem.parentuid = plc.UID
end
end
end
end
end
function add_portfw_to_list()
local idx = -2
local useExposedHost = box.query("forwardrules:settings/use_exposed_host")
local exposedHost = box.query("forwardrules:settings/exposed_host")
if (useExposedHost == "1" and exposedHost) then
idx = index_In_List(g_list,'ip',exposedHost)
if (idx >= 0) then
g_list[idx].exposedhost = true
end
end
local forwardrules=general.listquery("forwardrules:settings/rule/list(activated,fwip)")
for i,elem in ipairs(forwardrules) do
idx = index_In_List(g_list,'ip',elem.fwip)
if (idx >= 0) then
g_list[idx].portfw = true
end
end
local ipv6forwardrules=general.listquery("ipv6firewall:settings/rule/list(enabled,neighbour_name,ifaceid)")
for i,elem in ipairs(ipv6forwardrules) do
idx = index_In_List(g_list,'ipv6_ifid',elem.ifaceid)
if (idx >= 0) then
g_list[idx].ipv6portfw = true
g_list[idx].rule_id = i
end
end
if (box.query("box:settings/upnp/activated")== "1") then
if (box.query("box:settings/upnp/control_activated")== "1") then
local igdforwardrules=general.listquery("igdforwardrules:settings/rule/list(fwip)")
for i,elem in ipairs(igdforwardrules) do
idx = index_In_List(g_list,'ip',elem.fwip)
if (idx >= 0) then
g_list[idx].igdportfw = true
end
end
end
end
end
function get_myfritz_services(elem)
if (not elem._node) then
return
end
elem.myfritz_services={}
local services = general.listquery(
"landevice:settings/"
.. elem._node
.. "/myfritz_services/entry/list(enabled,name,type,url)"
)
if #services > 0 then
elem.myfritz_services = services
end
end
function add_myfritz_services_to_list()
for i, elem in ipairs(g_list) do
get_myfritz_services(elem)
end
end
function get_appcam_url(elem)
if elem.myfritz_services==nil then
get_myfritz_services(elem)
end
local camtype = "1"
local i, s = array.find(elem.myfritz_services or {}, func.eq(camtype, "type"))
if i and s then
if s.enabled == "1" and #s.url > 0 then
return s.url
end
end
return
end
function getNetType(elem)
local netType = "unknown"
if (elem.ethernet == "1") then
netType = "ethernet"
elseif (elem.wlan == "1") then
netType = "wlan"
end
return netType
end
function add_type_to_list()
for i,elem in ipairs(g_list) do
elem.type= getNetType(elem)
end
end
function add_ipv6_addr()
if (not g_list) then
return
end
if (config.IPV6) then
for i,elem in ipairs(g_list) do
elem.ipv6addrs = general.listquery("landevice:settings/"..elem._node.."/ipv6addrs0/entry/list(ipv6addr)")
end
else
for i,elem in ipairs(g_list) do
elem.ipv6addrs = {}
end
end
end
function add_lan_to_list()
g_list = general.listquery(
"landevice:settings/landevice/list("
.. "name,ip,mac,UID,dhcp,wlan,ethernet,active,static_dhcp,manu_name,wakeup,deleteable,source"
.. ",online,speed,wlan_UIDs,auto_wakeup,guest,url,wlan_station_type,vendorname,parentname,parentuid"
.. ",ethernet_port,wlan_show_in_monitor,plc,ipv6_ifid,parental_control_abuse"
.. ")"
)
end
function InitNetList()
add_lan_to_list()
add_type_to_list()
add_wlan_to_list()
add_plc_to_list()
add_kids_to_list()
add_portfw_to_list()
utf8.sort(g_list, get_displayname_lower)
end
function AnyWlanDevice(wlanlist)
if (wlanlist==nil) then
return false
end
for i,elem in ipairs(wlanlist) do
if (elem.radiotype=="2") then
return true
end
if (elem.radiotype==nil and elem.type=="wlan") then
return true
end
end
return false
end
function get_num_of_aps_at_channel(wlanlist,band,channel)
local radio=""
if band=="24" then
radio="1"
elseif band=="5" then
radio="2"
end
local count=0
for i,elem in ipairs(wlanlist) do
if (elem.radioband==radio and wlanscan.extract_current_channel(elem.channel)==channel) then
count=count+1
end
end
if (count>0)then
return count-1
end
return 0
end
function get_idx_by_rssi(rssi)
local nrssi = 0
if (rssi~="-1") then
rssi = tonumber(rssi) or 0
if rssi >= 0 and rssi <=170 then
nrssi = 0
elseif rssi > 170 and rssi <= 180 then
nrssi = 1
elseif rssi > 180 and rssi <= 190 then
nrssi = 2
elseif rssi > 190 and rssi <= 200 then
nrssi = 3
elseif rssi > 200 and rssi <= 215 then
nrssi = 4
elseif rssi > 215 then
nrssi = 5
end
else
nrssi = 0
end
return nrssi
end
function get_idx_by_quality(elem)
local quality=elem.quality
local nrssi=0;
if (quality==nil) then
return 0;
end
if (elem.is_ap=="1" and elem.ap_state~="5") then
return 0;
end
if config.WLAN_WDS then
local wds_active =box.query("wlan:settings/WDS_enabled")
local wds_encryption=box.query("wlan:settings/WDS_encryption")
if (wds_active == "1" and wds_encryption ~= "2" and wds_encryption ~= "3" and elem.is_repeater=="1") then
return 6
end
end
if( (tonumber(quality) <= 0)) then
nrssi = 0;
elseif( (tonumber(quality) > 0) and (tonumber(quality) <20) ) then
nrssi = 1;
elseif( (tonumber(quality) >= 20) and (tonumber(quality) <40) ) then
nrssi = 2;
elseif( (tonumber(quality) >= 40) and (tonumber(quality) <60) ) then
nrssi = 3;
elseif( (tonumber(quality) >= 60) and (tonumber(quality) <80) ) then
nrssi = 4;
else
nrssi = 5;
end
return nrssi;
end
function check_and_add(list, mac_or_more)
require("string_op")
local channel = box.query("wlan:settings/channel")
local active = (box.query("wlan:settings/ap_enabled")=="1")
local mac=mac_or_more
if string.find(mac_or_more,"§") then
local data=string_op.split2table(mac_or_more,"§",0)
mac=data[1]
end
local channel_scnd = 0
if config.WLAN.is_double_wlan then
channel_scnd =box.query("wlan:settings/channel_scnd")
end
if (not list) then
return
end
if (mac~="" and mac~="00:00:00:00:00:00" ) then
local idx,elem=find_dev_by_mac(list,mac)
if (elem==nil) then
local cur_channel = channel_scnd
local cur_radioband = 2
if (active) then
cur_channel = channel
cur_radioband = 1
end
elem={id = "",
name=mac,
ssid="",
hostname="",
ip="",
mac=mac,
state="0",
speed="0",
rssi="-1",
quality="0",
is_turbo="0",
wmm_active="0",
cipher="0",
powersave="0",
is_repeater="0",
mini="0",
wlan="1",
type="wlan",
radiotype="2",
checked=true,
channel="0,"..cur_channel..",0",
radioband= cur_radioband,
encStr="none"
}
table.insert(list,elem)
else
elem.checked=true
end
end
end
function get_num_of_active_wlan_devs(list)
if not list then
list=g_list
end
local count=0
for i,elem in ipairs(list) do
if elem.guest=="0" and elem.type=="wlan" and elem.active=="1" then
count=count+1
end
end
return count
end
function get_num_of_active_wlan_guestdevs(list)
if not list then
list=g_list
end
local count=0
for i,elem in ipairs(list) do
if elem.guest=="1" and elem.type=="wlan" and elem.active=="1" then
count=count+1
end
end
return count
end
function get_name(elem)
if elem.displayname then
return elem.displayname
elseif elem.name then
return elem.name
end
return ""
end
function create_name(elem)
local name=get_name(elem)
if (name=="") then
name="PC-"..tostring(elem.mac)
name=string.gsub(name,":","-")
end
return name
end
function get_name_with_link(elem)
local name=get_name(elem)
if elem.url and elem.url~="" and elem.active=="1" then
return [[<a target="_blank" href="]]..box.tohtml(elem.url)..[[">]]..box.tohtml(name)..[[</a>]]
end
return box.tohtml(name)
end
function get_displayname_with_link(elem)
local name=get_displayname(elem)
if elem.url and elem.url~="" and elem.active=="1" then
return [[<a target="_blank" href="]]..box.tohtml(elem.url)..[[">]]..box.tohtml(name)..[[</a>]]
end
return box.tohtml(name)
end
function get_parent_dev(elem)
local parentIdx, parentDev
if elem.url and elem.url ~= "" then
local idx = index_In_List(g_list,'name',elem.name)
end
if elem.parentuid and elem.parentuid ~= "" then
parentIdx, parentDev = find_dev_by_uid(g_list, elem.parentuid)
elseif elem.parentname and elem.parentname ~= "" then
parentIdx, parentDev = find_dev_by_name(g_list, elem.parentname)
end
return parentDev
end
function get_ip(elem)
local result={}
if elem.ip and elem.ip ~="" then
table.insert(result,elem.ip)
end
if (#result==0) then
return "-"
end
return table.concat(result,", ")
end
function get_mac(elem)
if elem.mac and elem.mac ~="" then
return elem.mac
end
return "-"
end
function get_speed_up_down(elem)
if (elem==nil) then
return ""
end
local str=" - "
if config.WLAN_WDS then
local wds_active =box.query("wlan:settings/WDS_enabled")
local wds_encryption=box.query("wlan:settings/WDS_encryption")
if (wds_active == "1" and wds_encryption ~= "2" and wds_encryption ~= "3" and elem.is_repeater=="1") then
return ""
end
end
if ( elem.state ~= "5") then
return ""
end
str = tostring(elem.speed).." / "..tostring(elem.speed_rx)
return str;
end
function get_speed(elem)
if (elem==nil) then
return ""
end
local str=" - "
if config.WLAN_WDS then
local wds_active =box.query("wlan:settings/WDS_enabled")
local wds_encryption=box.query("wlan:settings/WDS_encryption")
if (wds_active == "1" and wds_encryption ~= "2" and wds_encryption ~= "3" and elem.is_repeater=="1") then
return ""
end
end
if ( elem.state ~= "5") then
return ""
end
str = tostring(elem.speed).." "..TXT([[{?3508:929?}]])
return str;
end
function get_ssid(elem)
if (elem.ssid and string.find(elem.ssid,"0x") == 1) then
local i=0;
local bHideSsid="1";
for i=2, #elem.ssid,1 do
if (elem.ssid[i] ~= "0") then
bHideSsid="0";
break;
end
end
if (bHideSsid=="1") then
elem.ssid="";
end
end
if (elem.ssid) then
return elem.ssid
end
if (elem.name) then
return elem.name
end
return " - "
end
function get_ssid_with_link(elem)
local ssid=get_ssid(elem)
if elem.url and elem.url~="" and elem.active=="1" then
return [[<a target="_blank" href="]]..box.tohtml(elem.url)..[[">]]..box.tohtml(ssid)..[[</a>]]
end
return box.tohtml(ssid)
end
function get_ssid_as_title(elem)
local ssid = get_ssid(elem)
ssid = box.tohtml(ssid)
ssid = ssid:gsub([[']], [[&apos;]]) -- '
return ssid
end
function convert_num_to_enc(enc)
if (enc=="0") then
return "none"
elseif (enc=="1") then
return "wep"
elseif (enc=="2") then
return "wpa"
elseif (enc=="3") then
return "wpa2"
elseif (enc=="4") then
return "wpamixed"
end
return "none"
end
function convert_enc_to_num(seclevel)
if (seclevel=="none") then
return "0"
elseif (seclevel=="wep") then
return "1"
elseif (seclevel=="wpa") then
return "2"
elseif (seclevel=="wpa2") then
return "3"
elseif (seclevel=="wpamixed") then
return "4"
end
return "0"
end
local g_encStr = {TXT([[{?3508:631?}]]), [[WEP]], [[WPA]], [[WPA2]], [[WPA+WPA2]]};
function get_encryption_as_str(elem)
local idx=(tonumber(convert_enc_to_num(elem.encStr)) or 0)+1
return g_encStr[idx]
end
function get_seclevel(seclevel)
local idx=(tonumber(seclevel) or 0)+1
return g_encStr[idx]
end
function get_encryption(elem)
require ("bit")
local capabilities = tonumber(elem.capabilities) or 0
local isEncrypted = bit.isset(capabilities, 5)
local isWPA = bit.isset(capabilities, 0)
local isWPA2 = bit.isset(capabilities, 1)
local isMixed = isWPA and isWPA2;
if (isMixed) then
return "4"
end
if (isWPA2) then
return "3"
end
if (isWPA) then
return "2"
end
if (isEncrypted) then
return "1"
end
return "0"
end
g_txt_Wlan_Cipher_State = {TXT([[{?3508:348?}]]),[[WPA]],[[WEP]],[[WPA2]],[[WPA+WPA2]]}
function write_js_enc_array()
box.out([[var txt={"none":"]]..g_txt_Wlan_Cipher_State[1]..[[","wpa":"]]..g_txt_Wlan_Cipher_State[2]..[[","wep":"]]..g_txt_Wlan_Cipher_State[3]..[[","wpa2":"]]..g_txt_Wlan_Cipher_State[4]..[[","wpamixed":"]]..g_txt_Wlan_Cipher_State[5]..[["};]])
end
function wds2_capable(elem)
require ("bit")
local capabilities = tonumber(elem.capabilities) or 0
local cap_bits = bit.tobits(capabilities)
return cap_bits[11] == 1
end
function get_wlan_mode_fastest(mode_bit)
local mode_bit = tonumber(mode_bit)or 0
require ("bit")
local mode_str = ""
if bit.isset(mode_bit,2) then
mode_str = "g"
end
if bit.isset(mode_bit,1) then
if mode ~= "" then
mode_str = mode_str.."+"
end
mode_str = mode_str.."b"
end
if bit.isset(mode_bit,0) then
mode_str = "a"
end
if bit.isset(mode_bit,3) then
mode_str = "n"
end
if bit.isset(mode_bit,4) then
mode_str = "ac"
end
return mode_str;
end
function get_wlan_mode_str(mode_bit)
local mode_str = ""
local fastest = ""
local mode_bit = tonumber(mode_bit)or 0
require ("bit")
local add_mode = function(mode, bits)
if bit.isset(mode_bit, bits) then
if mode_str ~= "" then
mode_str = mode_str.."+"
end
mode_str = mode_str..mode
end
end
add_mode("n", 3)
add_mode("a", 0)
add_mode("ac", 4)
add_mode("b", 1)
add_mode("g", 2)
return mode_str
end
function get_enh(elem)
if ( elem.state ~= "5") then
return TXT([[{?3508:694?}]])
end
local str = ""
if config.WLAN.is_double_wlan then
if is_5ghz_mode_bit(elem.mode) then
str = str.."5&nbsp;GHz / "
else
str = str.."2,4&nbsp;GHz / "
end
end
str = str..get_wlan_mode_fastest(elem.mode).." / "
--str=str..general.sprintf(TXT([[{?3508:2662?}]]), tostring(elem.channel_width))..", "
str=str..tostring(elem.channel_width).."&nbsp;MHz"
local idx=tonumber(elem.cipher)+1
local class = ""
if (idx == 1 or idx == 3) then
class = [[ class="WarnMsg"]]
end
str=str..[[<br>]]
if (idx>4) then
str=str..tostring(elem.cipher)
else
str=str..[[<span]]..class..[[>]]..g_txt_Wlan_Cipher_State[idx]..[[</span>]]
end
return str
end
function get_btn_str_empty(show_feedback,show_edit,show_del, elem)
local str=""
if (show_feedback and show_edit and show_del) then
if (elem and elem.wlan=="1") then
local var_id = "name"
if elem.UID and elem.UID~="" then
var_id = "UID"
elseif elem._node then
var_id = "node"
elseif elem.id then
var_id = "id"
end
str=[[<td class="buttonrow"></td><td class="buttonrow"></td><td class="buttonrow">]]..general.get_icon_button("/css/default/images/feedback.gif", "feedback_"..elem[var_id], "feedback", elem[var_id], TXT([[{?txtIconBtnFeedback?}]]))..[[</td>]]
else
str=[[<td class="buttonrow"></td><td class="buttonrow"></td><td class="buttonrow"><div class="empty_btn">&nbsp;</div></td>]]
end
elseif (show_feedback and show_edit or show_feedback and show_del or show_del and show_edit) then
str=[[<td class="buttonrow"></td><td class="buttonrow"><div class="empty_btn">&nbsp;</div></td>]]
elseif (show_feedback or show_edit or show_del) then
str=[[<td class="buttonrow"><div class="empty_btn">&nbsp;</div></td>]]
end
return str
end
local internaldata = general.lazytable({}, box.query, {
macfilter = {"wlan:settings/is_macfilter_active"},
wlan_count = {"wlan:settings/wlanlist/count"}
})
function get_btn_str(elem,var_id,show_feedback,show_edit,show_del)
local onclick = "checkWlanDelete('"..elem.type.."','"..elem.wlan.."','"..elem.deleteable.."','"..box.tojs(box.tohtml(get_name(elem))).."','"..elem.active.."','"..elem.is_repeater.."','"..elem.kisi.."')"
local b_disabled = (elem.deleteable=="0") or (internaldata.macfilter=="0" and elem.wlan=="1" and elem.active=="1") or
(internaldata.macfilter=="1" and elem.wlan=="1" and tonumber(internaldata.wlan_count)<2)
local is_wlan = (elem.wlan=="1")
local devname = box.tohtml(get_name(elem))
local str=[[]]
if (show_feedback) then
if (is_wlan) then
str=str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/feedback.gif", "feedback_"..elem[var_id], "feedback", elem[var_id], TXT([[{?txtIconBtnFeedback?}]]))..[[</td>]]
else
str=str..[[<td class="buttonrow"></td>]]
end
end
if (show_edit) then
str=str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/bearbeiten.gif", "edit_"..elem[var_id], "edit", elem[var_id], TXT([[{?txtIconBtnEdit?}]]))..[[</td>]]
end
if (show_del) then
if elem.type == "plc" then
str = str..[[<td class="buttonrow"></td>]]
else
str = str..[[<td class="buttonrow">]]..general.get_icon_button("/css/default/images/loeschen.gif", "delete_"..elem[var_id], "delete", elem[var_id], TXT([[{?txtIconBtnDelete?}]]), onclick, b_disabled)..[[</td>]]
end
end
return str
end
function get_netdev_buttons(elem,show_feedback,show_edit,show_del)
if elem.is_repeater==nil then
elem.is_repeater="0"
end
if elem.kisi==nil then
elem.kisi="auto"
end
if elem.deleteable==nil then
elem.deleteable="2"
end
if elem.wlan==nil then
elem.wlan="0"
end
if elem.guest=="1" then
return get_btn_str_empty(show_feedback,show_edit,show_del,elem)
end
if elem.UID and elem.UID~="" then
return get_btn_str(elem,"UID",show_feedback,show_edit,show_del)
elseif elem._node then
return get_btn_str(elem,"node",show_feedback,show_edit,show_del)
elseif elem.id then
return get_btn_str(elem,"id",show_feedback,show_edit,show_del)
else
return get_btn_str(elem,"name",show_feedback,show_edit,show_del)
end
return ""
end
function get_notfound()
return TXT([[{?3508:651?}]])
end
function get_userdef()
return TXT([[{?3508:271?}]])
end
function get_unknown()
return TXT([[{?3508:279?}]])
end
function create_dev_row_checked_enc(n,elem)
return create_dev_row_checked(n,elem,true)
end
function create_dev_row_checked_wds2(n,elem)
return create_dev_row_checked(n,elem,true,true)
end
function create_dev_row_checked(n,elem,show_encrypt,show_wds2)
if (elem.mac==nil or elem.mac=="") then
return ""
end
local onclick_handler = [[return OnChangeActive(this,]]..n..[[);]]
local cur_chan=tostring(wlanscan.extract_current_channel(elem.channel))
local str=[[<tr id='uiViewRow]]..n..[[' ]]
local nrssi = 0
local rowClass=""
local channel = box.query("wlan:settings/channel")
local active = (box.query("wlan:settings/ap_enabled")=="1")
local channel_scnd = ""
if config.WLAN.is_double_wlan then
if config.GUI_IS_REPEATER and tostring(elem.radioband) == "2" then
onclick_handler = [[return OnChangeActiveScnd(this,]]..n..[[);]]
str=[[<tr id='uiViewRowScnd]]..n..[[' ]]
end
channel_scnd =box.query("wlan:settings/channel_scnd")
active_scnd =(box.query("wlan:settings/ap_enabled_scnd")=="1")
end
if (not show_encrypt) then
local IsBad=channel~=cur_chan
if config.WLAN.is_double_wlan then
IsBad=false
if (active_scnd and active) then
IsBad = (cur_chan~=channel) and (cur_chan~=channel_scnd)
elseif (active_scnd) then
IsBad = (cur_chan~=channel_scnd)
else
IsBad = (cur_chan~=channel);
end
end
if (IsBad) then
rowClass=rowClass..[[ badchannel ]]
end
end
local disable_checkbox = false
local tr_title
if show_wds2 and config.WLAN_WDS2 then
if not wds2_capable(elem) then
rowClass = rowClass .. [[ disabled ]]
disable_checkbox = true
elem.checked = false
tr_title = TXT([[{?3508:107?}]])
end
end
if (elem.checked) then
rowClass=rowClass..[[ highlight ]]
end
str=str..[[ class="]]..rowClass..[["]]
if tr_title then
str = str .. [[ title="]] .. box.tohtml(tr_title) .. [[" ]]
end
str = str .. [[>]]
str=str..[[<td><input type='checkbox' name='check]]..n..[[' value=']]
str=str.. box.tohtml(elem.mac.."§"..cur_chan.."§"..elem.encStr.."§"..(elem.ssid or ""):gsub([[']], [[&apos;]]))
str=str..[[']]
if disable_checkbox then
str=str..[[ disabled ]]
else
str = str .. [[ onclick=']]..onclick_handler..[[' ]]
end
if (elem.checked) then
str=str..[[ checked='checked' ]]
end
str=str..[[></td>]]
if (elem.rssi~="-1") then
local nrssi=0
nrssi=get_idx_by_rssi(elem.rssi)
local tooltip = "<20"
if( nrssi ~= 0) then
tooltip=tostring(nrssi*20 )
end
str = str.. [[<td]]
if not tr_title then
str = str .. [[ title=']]..tooltip..[[%']]
end
str = str .. [[ class='wlan_rssi]]..nrssi..[['></td>]]
else
str = str.. [[<td]]
if not tr_title then
str = str .. [[ title=']]..get_userdef()..[[']]
end
str = str .. [[ class='wlan_own_mac'></td>]]
elem.ssid = get_notfound()
end
str = str..[[<td]]
if not tr_title then
str = str .. [[ title=']]..get_ssid_as_title(elem)..[[']]
end
str = str .. [[>]] .. get_ssid_with_link(elem)..[[</td>]]
str = str..[[<td >]] .. cur_chan .. [[</td>]]
str = str..[[<td >]] .. elem.mac .. [[</td>]]
if (show_encrypt) then
str = str..[[<td >]] .. get_encryption_as_str(elem) .. [[</td>]]
end
str = str..[[<td >&nbsp;</td></tr>]]
return str;
end
function create_dev_row_raw(n,elem)
if (elem.mac==nil or elem.mac=="") then
return ""
end
local str=""
local nrssi = 0
local rowClass=""
local cur_chan=wlanscan.extract_current_channel(elem.channel)
str=str..[[<tr id='uiViewRow]]..n..[[' ]]
str=str..[[class=']]..rowClass..[[' >]]
if (elem.rssi~="-1") then
local nrssi=0
nrssi=get_idx_by_rssi(elem.rssi)
local tooltip = "<20"
if( nrssi ~= 0) then
tooltip=tostring(nrssi*20 )
end
str = str.. [[<td title=']]..tooltip..[[%' class='wlan_rssi]]..nrssi..[['></td>]]
else
str = str.. [[<td title=']]..get_userdef()..[[' class='wlan_own_mac'></td>]]
elem.ssid = get_notfound()
end
str = str..[[<td title=']]..get_ssid_as_title(elem)..[[' >]]..get_ssid_with_link(elem)..[[</td>]]
str = str..[[<td >]] .. cur_chan .. [[</td>]]
str = str..[[<td >]] .. elem.mac .. [[</td>]]
str = str..[[<td >&nbsp;</td></tr>]]
return str;
end
function create_dev_row_wlan_rep(n,elem,show_feedback)
if (elem.radiotype=="1") then
return ""
end
if (elem.mac==nil or elem.mac=="") then
return ""
end
local str=""
local nrssi = 0
local rowClass=""
local guest=""
local show_edit=false
local show_del=true
str=str..[[<tr id='uiViewRow]]..n..[[' ]]
str=str..[[class=']]..rowClass..[[' >]]
if (elem.rssi~="-1") then
local nrssi=0
nrssi=get_idx_by_quality(elem)
local tooltip = "<20"
if( nrssi ~= 0) then
tooltip=tostring(nrssi*20 )
end
if elem.guest=="1" then
guest="_guest"
end
str = str.. [[<td title=']]..tooltip..[[%' class='wlan_rssi]]..guest..nrssi..[['></td>]]
else
str = str.. [[<td title=']]..get_userdef()..[[' class='wlan_own_mac'></td>]]
elem.ssid = get_notfound()
end
str = str..[[<td title=']]..get_ssid_as_title(elem)..[[' class='cut_overflow'>]] .. get_ssid_with_link(elem) .. [[</td>]]
str = str..[[<td >]] .. net_devices.get_ip(elem) .. [[</td>]]
str = str..[[<td >]] .. elem.mac .. [[</td>]]
str = str..[[<td class = "hint">]]..get_speed_up_down(elem)..[[</td>]]
str = str..[[<td >]]..get_enh(elem)..[[</td>]]
str = str..get_netdev_buttons(elem,show_feedback,show_edit,show_del)
str = str..[[</tr>]]
return str;
end
function get_separator(style,num_of_col)
local str=""
if (style=="wlan_active") then
local ssid=box.query("wlan:settings/ssid")
local ssid_scnd=""
if config.WLAN.is_double_wlan then
ssid_scnd=box.query("wlan:settings/ssid_scnd")
end
str=TXT([[{?3508:798?}]])..[[ ]]..box.tohtml(ssid)..[[]]
if (ssid_scnd~="" and ssid~=ssid_scnd) then
str=TXT([[{?3508:787?}]])..[[: ]]..box.tohtml(ssid)..[[ / ]]..box.tohtml(ssid_scnd)..[[]]
end
elseif (style=="wlan_guest") then
local ssid=box.query("wlan:settings/guest_ssid")
str=TXT([[{?3508:400?}]])..[[: ]]..box.tohtml(ssid)..[[]]
elseif (style=="lan_guest") then
str=TXT([[{?3508:418?}]])
elseif (style=="lan_active") then
str=TXT([[{?3508:907?}]])
elseif (style=="user") then
str=TXT([[{?3508:173?}]])
elseif (style=="lan_passive") then
if (any_user(g_list)) then
str=TXT([[{?3508:376?}]])
else
str=TXT([[{?3508:3746?}]])
end
end
return [[<tr class='separator'><td colspan=']]..tostring(num_of_col)..[['><hr><p><span> ]]..str..[[ </span></p></td></tr>]]
--return [[<tr ><td class="txt_center" colspan="]]..tostring(num_of_col)..[[">--------------------------------------------- ]]..str..[[ ---------------------------------------------</td></tr>]]
end
function create_known_wlandevices_table_rep()
if not config.GUI_IS_REPEATER then
return ""
else
local str_guest=""
local str_active=""
local str=[[<table class='zebra'>]]
local show_feedback=true
local num_of_col=6
if (show_feedback) then
num_of_col=7
str=str..[[<colgroup><col width='35px'><col width='160px'><col width='90px'><col width='110px'><col width='100px'><col width='140px'><col width='35px'></colgroup>]]
else
str=str..[[<colgroup><col width='35px'><col width='160px'><col width='90px'><col width='110px'><col width='100px'><col width='140px'></colgroup>]]
end
str=str..[[<tr class="thead">
<th class="sortable sort_by_class" title=']]..TXT([[{?3508:182?}]])..[['></th>]]..
[[<th class="sortable">]]..TXT([[{?3508:246?}]])..[[<span class="sort_no">&nbsp;</span></th>]]..
[[<th class="sortable">]]..TXT([[{?3508:894?}]])..[[<span class="sort_no">&nbsp;</span></th>]]..
[[<th class="sortable">]]..TXT([[{?3508:571?}]])..[[<span class="sort_no">&nbsp;</span></th>]]..
[[<th class="sortable hint" title="]]..TXT([[{?3508:175?}]])..[[">]]..TXT([[{?3508:578?}]])..[[<br> (Mbit/s)</th>]]..
[[<th>]]..TXT([[{?3508:483?}]])..[[</th>
<th class='buttonrow'></th>]]
if show_feedback then
str=str..[[<th class='buttonrow'></th>]]
end
str=str..[[</tr>]]
local any_dev_found=false
local row=""
for i,elem in ipairs(g_list) do
if (elem.type=="wlan") then
row=""
if (elem.is_ap~="1") then
row=create_dev_row_wlan_rep(i-1,elem,show_feedback)
any_dev_found=true
end
if (elem.guest=="1") then
if (elem.active=="1") then
str_guest=str_guest..row
end
else
str_active=str_active..row
end
end
end
if (not any_dev_found) then
if config.GUI_IS_POWERLINE then
str=str..[[<tr><td colspan=']]..num_of_col..[[' class='txt_center'>]]..TXT([[{?3508:277?}]])..[[</td></tr>]]
else
str=str..[[<tr><td colspan=']]..num_of_col..[[' class='txt_center'>]]..TXT([[{?3508:391?}]])..[[</td></tr>]]
end
end
if str_guest~="" then
str=str..get_separator("wlan_active",num_of_col)
if (str_active=="") then
str=str..[[<tr><td colspan=']]..num_of_col..[[' class='txt_center'>]]..TXT([[{?3508:734?}]])..[[</td></tr>]]
end
end
str=str..str_active
if str_guest~="" then
str=str..get_separator("wlan_guest",num_of_col)
str=str..str_guest
end
str=str..[[</table>]]
return str
end
end
function create_dev_row_wlan_sta(n,elem)
if (elem.mac==nil or elem.mac=="") then
return ""
end
local str=""
local nrssi = 0
local rowClass=""
str=str..[[<tr id='uiViewRow]]..n..[[' ]]
str=str..[[class=']]..rowClass..[[' >]]
if (elem.ap_state=="5") then
local nrssi=0
nrssi=get_idx_by_quality(elem)
local tooltip = "<20"
if( nrssi ~= 0) then
tooltip=tostring(nrssi*20 )
end
str = str.. [[<td title=']]..tooltip..[[%' class='wlan_rssi]]..nrssi..[['></td>]]
else
str = str.. [[<td title='{?3508:371?}' class='wlan_rssi0'></td>]]
end
str = str..[[<td title=']]..get_ssid_as_title(elem)..[[' >]]..get_ssid_with_link(elem)..[[</td>]]
str = str..[[<td >]] .. elem.mac .. [[</td>]]
str = str..[[<td >]]..get_speed(elem)..[[</td>]]
str = str..[[<td >]]..get_enh(elem)..[[</td>]]
str = str..[[<td >&nbsp;</td></tr>]]
return str;
end
function get_sta_master(scnd)
local suffix = ""
if scnd then
suffix = "_scnd"
end
local sta = {
enabled = box.query("wlan:settings/STA_enabled"..suffix),
configured= box.query("wlan:settings/STA_configured"..suffix),
mac = box.query("wlan:settings/STA_mac_master"..suffix),
ssid = box.query("wlan:settings/STA_ssid"..suffix),
encryption= box.query("wlan:settings/STA_encryption"..suffix),
mode = bg_mode_2_bits(box.query("wlan:settings/STA_mode"..suffix))
}
if sta.configured=="1" then
local dev_list = g_WlanList
local elem_key = "mac"
if #g_list > 0 then
dev_list = g_list
elem_key = "wlan_mac"
end
local idx, myAp=find_dev_by_key(dev_list, elem_key, sta.mac)
if (myAp~=nil) then
myAp=table.extend(myAp,sta)
else
idx, myAp=find_dev_by_mac(g_WlanList, sta.mac)
if (myAp~=nil) then
myAp=table.extend(myAp,sta)
myAp.speed = box.query("wlan:settings/"..myAp._node.."/speed")
myAp.speed_rx = box.query("wlan:settings/"..myAp._node.."/speed_rx")
else
myAp = sta
end
end
return myAp
end
return {}
end
function is_5ghz_mode_bit(mode_bit)
require ("bit")
mode_bit = tonumber(mode_bit) or 0
return bit.isset(mode_bit,4) or bit.isset(mode_bit, 0)
end
function bg_mode_2_bits(mode)
require ("bit")
mode = tostring(mode) or "25"
local mode_bit = 0
if mode == "53" then
mode_bit = bit.set(mode_bit,4)
elseif mode == "52" then
mode_bit = bit.set(mode_bit,0)
mode_bit = bit.set(mode_bit,3)
elseif mode == "25" then
mode_bit = bit.set(mode_bit,1)
mode_bit = bit.set(mode_bit,2)
mode_bit = bit.set(mode_bit,3)
elseif mode == "24" then
mode_bit = bit.set(mode_bit,1)
mode_bit = bit.set(mode_bit,2)
elseif mode == "23" then
mode_bit = bit.set(mode_bit,2)
mode_bit = bit.set(mode_bit,3)
end
return mode_bit;
end
function bits2Mode(mode)
require ("bit")
local mode_bit = mode
if (type(mode)=='string') then
mode_bit=tonumber(mode)or 0
end
if (bit.isset(mode_bit,4)) then
return "53";
elseif (bit.isset(mode_bit,0)) then
return "52";
elseif (bit.isset(mode_bit,1) and bit.isset(mode_bit,2) and bit.isset(mode_bit,3)) then
return "25";
elseif (bit.isset(mode_bit,1) and bit.isset(mode_bit,2)) then
return "24";
elseif (bit.isset(mode_bit,2) and bit.isset(mode_bit,3)) then
return "23";
end
return tostring(mode);
end
function get_bg_mode(scnd)
local sta_master = get_sta_master(scnd)
if (sta_master and sta_master.configured=="1") then
return sta_master.mode;
end
local suffix = ""
if scnd then
suffix = "_scnd"
end
return box.query("wlan:settings/bg_mode"..suffix)
end
function get_wds2_uplink_band()
if config.WLAN_WDS2 and box.query("wlan:settings/WDS_enabled") == "1" then
local wds2_ap_mac = box.query("wlan:settings/WDS_mac_master")
local i, wds2_ap = array.find(g_WlanList, func.eq(wds2_ap_mac, "mac"))
if wds2_ap then
if is_5ghz_mode_bit(wds2_ap.mode) then
return "2"
else
return "1"
end
end
end
end
function create_configured_sta(get_content)
local str=[[<table class='zebra'>]]
str=str..[[<colgroup><col width='30px'><col width='220px'><col width='110px'><col width='70px'><col width='95px'><col width='5px'></colgroup>]]
str=str..[[<tr><th title=']]..TXT([[{?3508:2124?}]])..[['></th>]]..
[[<th>]]..TXT([[{?3508:197?}]])..[[</th>]]..
[[<th>]]..TXT([[{?3508:732?}]])..[[</th>]]..
[[<th>]]..TXT([[{?3508:128?}]])..[[</th>]]..
[[<th>]]..TXT([[{?3508:380?}]])..[[</th>]]..
[[<th></th></tr>]]
--<img src='/css/default/images/wlan_antenne.gif' width='11px' height='13px'>
local my_ap = get_sta_master()
local my_ap_scnd = {}
if config.WLAN.is_double_wlan then
my_ap_scnd = get_sta_master(true)
end
local ap_string = ""
if my_ap.configured == "1" or my_ap_scnd.configured == "1" then
if (my_ap.UID and my_ap.UID ~= "" and get_content) then
ap_string = ap_string..create_dev_row_wlan_sta(1,my_ap)
end
if (my_ap_scnd.UID and my_ap_scnd.UID ~= "" and get_content) then
ap_string = ap_string..create_dev_row_wlan_sta(1,my_ap_scnd)
end
if ap_string == "" then
ap_string = [[<tr><td colspan='6' class='txt_center'>]]..TXT([[{?3508:956?}]])..[[</td></tr>]]
end
else
ap_string = [[<tr><td colspan='6' class='txt_center'>]]..TXT([[{?3508:797?}]])..[[</td></tr>]]
end
str=str..ap_string..[[</table>]]
return str
end
function is_active(valname, value)
local i = index_In_List(g_list, valname, value)
if i > 0 then
local active = tonumber(g_list[i].active)
return active and active == 1
end
end
function check_connected(elem)
local tmp = [[<td class="iconrow]]
if not(elem) then
tmp = tmp..[[">]]
elseif elem.online=="1" and elem.active=="1" then
if (elem.guest=="1") then
tmp = tmp..[[ globe_online_guest"]]
tmp = tmp..[[ title="]]..box.tohtml(TXT([[{?3508:613?}]]))..[[">]]
else
tmp = tmp..[[ globe_online"]]
tmp = tmp..[[ title="]]..box.tohtml(TXT([[{?3508:335?}]]))..[[">]]
end
elseif elem.active=="1" then
if elem.parental_control_abuse == "1" then
tmp = tmp..[[ dev_blocked"]]
tmp = tmp..[[ title="]]..box.tohtml(TXT([[{?3508:234?}]]))..[[">]]
elseif (elem.guest=="1") then
tmp = tmp..[[ led_green_guest"]]
tmp = tmp..[[ title="]]..box.tohtml(TXT([[{?3508:665?}]]))..[[">]]
else
tmp = tmp..[[ led_green"]]
tmp = tmp..[[ title="]]..box.tohtml(TXT([[{?3508:547?}]]))..[[">]]
end
elseif elem.type=="user" or elem.type=="ipuser" then
tmp = tmp..[[">]]
else
tmp = tmp..[[">]]
end
return tmp..[[</td>]]
end
function get_comma(str)
if str ~= "" then
return ", "
end
return ""
end
g_opmode = box.query("box:settings/opmode")
function get_properties(elem)
local tmp = ""
if elem.active == "1" and elem.parental_control_abuse == "1" then
tmp = tmp .. [[
<div>
<a href=" " onclick="showBlockedExplain(); return false;" class="textlink">
<img src="/css/default/images/icon_help.png" alt="" class="linkimg">
</a>
<a href=" " onclick="showBlockedExplain(); return false;">
]] .. TXT([[{?3508:617?}]]) .. [[
</a>
</div>
]]
return tmp
end
local appcam_url = get_appcam_url(elem)
if appcam_url then
tmp=tmp..[[<div class="cut_overflow">]]
tmp=tmp..[[
<img src="/css/default/images/appcam.png" alt="" class="linkimg">
<a href="]] .. appcam_url ..[[" target="_blank">]]
tmp=tmp.. box.tohtml(TXT([[ {?3508:29?}]]))
tmp=tmp.. [[</a>]]
tmp=tmp..[[</div>]]
end
local parentElem = get_parent_dev(elem)
if (parentElem) then
tmp=tmp..[[<div title="]]..box.tohtml(get_name(parentElem))..[[" class="cut_overflow">]]
tmp=tmp..[[<img src="/css/default/images/parent.png" alt="]]..general.sprintf(TXT([[{?3508:297?}]]), elem.parentname)..[[" title="]]..general.sprintf(TXT([[{?3508:2454?}]]), parentElem.name)..[["> ]]..
get_name_with_link(parentElem)
tmp=tmp..[[</div>]]
end
if g_opmode ~= 'opmode_modem' and g_opmode ~= 'opmode_eth_ipclient' then
if elem.exposedhost or elem.portfw or elem.igdportfw or elem.ipv6portfw then
if elem.exposedhost then
tmp=tmp.."<a href='"..href.get("/internet/port_fw.lua")..[['>]]..box.tohtml(TXT([[{?3508:991?}]]))..[[</a>]]
else
if elem.portfw then
tmp=tmp.."<a href='"..href.get("/internet/port_fw.lua")..[['>]]..box.tohtml(TXT([[{?3508:553?}]]))..[[</a> ]]
end
if elem.ipv6portfw then
tmp=tmp.."<a href='"..href.get("/internet/ipv6_fw.lua")..[['>]]..box.tohtml(TXT([[{?3508:150?}]]))..[[</a>]]
end
end
end
end
if elem.type == "plc" and not elem.isLocal then
if elem.exposedhost or elem.portfw or elem.igdportfw or elem.ipv6portfw then
tmp=tmp.."<br>"
end
if (tonumber(elem.phyRateRX) and tonumber(elem.phyRateRX) > 0 and tonumber(elem.phyRateTX) and tonumber(elem.phyRateTX) > 0) then
tmp = tmp..tostring(elem.phyRateRX).." / "..tostring(elem.phyRateTX)..TXT([[ {?3508:262?}]])
else
tmp = "- / -"
end
end
return tmp
end
function is_mimo(dev)
return dev and (dev.couplingClass=="MIMO" or g_dev.couplingClass=="DIVERSITY")
end
function convert_plc_mimo(couplingClass)
if couplingClass=="SISO" then
return TXT([[{?3508:658?}]])
elseif couplingClass=="DIVERSITY" then
return TXT([[{?3508:687?}]])
elseif couplingClass=="MIMO" then
return TXT([[{?3508:111?}]])
end
require("general")
return general.sprintf(TXT([[{?3508:554?}]]),tostring(couplingClass))
end
function get_coupling_txt(coupling)
if coupling=="0" then
return TXT([[{?3508:715?}]])
elseif coupling=="1" then
return TXT([[{?3508:83?}]])
elseif coupling=="2" then
return TXT([[{?3508:145?}]])
end
return convert_plc_mimo(coupling)
end
function convert_plc_speed(speed)
local str=""
local speed = tonumber(speed) or 0
if speed and speed > 0 then
if speed >= 1000 then
str = tostring(speed/1000)..TXT([[ {?3508:780?}]])
else
str = tostring(speed)..TXT([[ {?3508:645?}]])
end
end
return str
end
function get_connection_speed(elem)
local str = ""
if (elem.type=="plc") then
if (elem.ethernetrate and elem.ethernetrate~="") then
str=convert_plc_speed(elem.ethernetrate)
else
str=convert_plc_speed(elem.class)
end
else
str=convert_plc_speed(elem.speed)
end
return str
end
function get_lan_speed_text(elem)
if (elem.ethernet_port and elem.ethernet_port=="0") then
return ""
end
local lan_str = [[LAN]]
if (elem.ethernet_port) then
lan_str = lan_str..[[ ]]..elem.ethernet_port
end
local connection_speed = get_connection_speed(elem)
if connection_speed == "" then
return lan_str
else
return general.sprintf(TXT([[{?3508:809?}]]), lan_str, connection_speed)
end
end
function get_connection_type(elem)
local str = "<div>"
if elem.type then
if elem.type=="wlan" then
if elem.active=="1" then
str = str..[[<a class="no_link" href="]]..href.get('/wlan/wlan_settings.lua')..[["><img alt="" src="/css/default/images/clients_wlan.png"> WLAN</a>]]
else
str = str..[[<a class="no_link" href="]]..href.get('/wlan/wlan_settings.lua')..[["><img alt="" src="/css/default/images/clients_wlan00.png"> WLAN</a>]]
end
str = str..[[ ]]..get_connection_speed(elem)..[[ ]]
elseif elem.type == "ethernet" then
if elem.active=="1" then
str = str..[[<img alt="" src="/css/default/images/clients_lan.png">]]
else
str = str..[[<img alt="" src="/css/default/images/clients_lan00.png">]]
end
str = str..[[ ]]..get_lan_speed_text(elem)..[[ ]]
elseif elem.type == "user" then
if elem.active=="1" then
str = str..[[<img alt="" src="/css/default/images/clients_benutzer.png">]]
else
str = str..[[<img alt="" src="/css/default/images/clients_benutzer.png">]]
end
elseif elem.type == "plc" then
if elem.active=="1" then
str = str..[[<img alt="" src="/css/default/images/plc_green.gif">]]
else
str = str..[[<img alt="" src="/css/default/images/plc_gray.gif">]]
end
str = str..[[ ]]..get_lan_speed_text(elem)..[[ ]]
end
end
return str.."</div>"
end
function create_row_lan(elem)
local str = [[<tr>]]..check_connected(elem)
str = str..[[<td class="cut_overflow" title="]]..box.tohtml(get_name(elem))..[[">]]..get_name_with_link(elem)..[[</td>]]
if (general.is_expert()) then
str = str..[[<td>]]..get_ip(elem)..[[</td>]]
str = str..[[<td>]]..get_mac(elem)..[[</td>]]
end
str = str..[[<td class="connection_type">]]..get_connection_type(elem)..[[</td>]]
str = str..[[<td>]]..get_properties(elem)..[[</td>]]
str = str..get_netdev_buttons(elem,false,true,true)..[[</tr>]]
return str
end
function create_dev_row_wlan(n, elem, show_list)
if (elem.radiotype=="1") then
return ""
end
if (elem.mac==nil or elem.mac=="") then
return ""
end
if config.WLAN_WDS2 and elem.wlan_station_type == "wds_slave_child" then
return ""
end
local row = {}
row = html.tr()
row.id = [[uiViewRow]]..n
local nrssi = 0
local guest=""
if show_list["receive"] then
if (elem.rssi~="-1") then
local nrssi=0
nrssi=net_devices.get_idx_by_quality(elem)
local tooltip = "<20"
if( nrssi ~= 0) then
tooltip=tostring(nrssi*20 )
end
if elem.guest=="1" then
guest="_guest"
end
row.add(html.td{title = tooltip.."%", class = "wlan_rssi"..guest..nrssi})
else
row.add(html.td{title = net_devices.get_userdef(), class = "wlan_own_mac"})
elem.ssid = net_devices.get_notfound()
end
end
if show_list["name"] then
row.add(html.raw([[<td title=']]..get_ssid_as_title(elem)..[[' class='cut_overflow'>]]..get_ssid_with_link(elem)..[[</td>]]))
end
if show_list["ip"] then
row.add(html.td{net_devices.get_ip(elem)})
end
if show_list["mac"] then
row.add(html.td{elem.mac})
end
if show_list["rate"] then
row.add(html.td{class = "hint", net_devices.get_speed_up_down(elem)})
end
if show_list["properties"] then
row.add(html.td{html.raw(net_devices.get_enh(elem))})
end
row.add(html.raw(net_devices.get_netdev_buttons(elem, show_list["feedback"], show_list["edit_btn"], show_list["del_btn"])))
return row;
end
function create_known_wlandevices_table(...)
local list = net_devices.g_list
local show_list = {}
for i, elem in ipairs(arg) do
show_list[elem] = true
end
local colgroup = html.colgroup()
local head_row = html.tr({class="thead"})
local num_of_col = 0
local add_head_elem = function (id, width, properties)
if (show_list[id]) then
num_of_col = num_of_col + 1
colgroup.add(html.col{width = width})
local th = html.th(properties)
head_row.add(th)
end
end
add_head_elem("receive", "35px", {
title = TXT([[{?3508:433?}]]),
class="sortable sort_by_class"
})
add_head_elem("name", "150px", {TXT([[{?3508:945?}]]),class="sortable",html.span({class="sort_no",html.raw([[&nbsp;]])})})
add_head_elem("ip", "90px", {TXT([[{?3508:867?}]]),class="sortable",html.span({class="sort_no",html.raw([[&nbsp;]])})})
add_head_elem("mac", "105px", {TXT([[{?3508:998?}]]),class="sortable",html.span({class="sort_no",html.raw([[&nbsp;]])})})
add_head_elem("rate", "80px", {TXT([[{?3508:710?}]]), html.br{}, " (Mbit/s)", class="sortable hint",
title=TXT([[{?3508:836?}]]), html.span({class="sort_no",html.raw([[&nbsp;]])})})
add_head_elem("properties", "130px", {TXT([[{?3508:532?}]]),class="sortable",html.span({class="sort_no",html.raw([[&nbsp;]])})})
add_head_elem("feedback", "40px", {class = "buttonrow"})
add_head_elem("edit_btn", "40px", {class = "buttonrow"})
add_head_elem("del_btn", "40px", {class = "buttonrow"})
local guest_rows = {}
local active_rows = {}
local j = 0
for i,elem in ipairs(list) do
if (elem.type=="wlan" and (elem.wlan_show_in_monitor ~= "0" or config.GUI_IS_REPEATER)) then
local row
if config.GUI_IS_REPEATER then
if (elem.is_ap~="1") then
row = create_dev_row_wlan(j, elem, show_list)
j = j + 1
end
else
row = create_dev_row_wlan(j, elem, show_list)
j = j + 1
end
if row then
if (elem.guest=="1") then
if (elem.active=="1") then
table.insert(guest_rows, row)
end
else
table.insert(active_rows, row)
end
end
end
end
local table_elems = {}
table_elems = html.table()
table_elems.id = [[uiWlanDevs]]
table_elems.class = [[zebra]]
table_elems.add(colgroup)
table_elems.add(head_row)
if #guest_rows > 0 or #active_rows > 0 then
if #guest_rows > 0 then
table_elems.add(html.raw(net_devices.get_separator("wlan_active",num_of_col)))
if #active_rows <= 0 then
table_elems.add(html.tr{html.td{colspan = num_of_col, class = "txt_center", TXT([[{?3508:17?}]])}})
end
end
for j, active_elem in ipairs(active_rows) do
table_elems.add(active_elem)
end
if #guest_rows > 0 then
table_elems.add(html.raw(net_devices.get_separator("wlan_guest",num_of_col)))
for k, guest_elem in ipairs(guest_rows) do
table_elems.add(guest_elem)
end
end
else
local no_devices_txt = TXT([[{?3508:167?}]])
if config.GUI_IS_POWERLINE then
no_devices_txt = TXT([[{?3508:275?}]])
elseif GUI_IS_REPEATER then
no_devices_txt = TXT([[{?3508:464?}]])
end
table_elems.add(html.tr{html.td{colspan = num_of_col, class="txt_center", no_devices_txt}})
end
return table_elems.get(), (#guest_rows + #active_rows)
end
function compareByName(dev1, dev2)
local name1byte = string.byte(string.lower(dev1.name)) or 0
local name2byte = string.byte(string.lower(dev2.name)) or 0
for i=1, #dev1.name, 1 do
if name1byte ~= name2byte then
break;
end
name1byte = string.byte(string.lower(dev1.name), i) or 0
name2byte = string.byte(string.lower(dev2.name), i) or 0
end
return name1byte < name2byte
end
function compareByQuality(dev1, dev2)
local quality1 = tonumber(dev1.quality) or 0
local quality2 = tonumber(dev2.quality) or 0
if quality1 > quality2 then
return true
elseif quality1 < quality2 then
return false
end
return compareByName(dev1, dev2)
end
function get_escaped_js_qr_wifi_string(qr_wifi_string)
local js_qr_wifi_string = box.tojs(qr_wifi_string)
js_qr_wifi_string = string.gsub(js_qr_wifi_string, ";", [[\;]])
js_qr_wifi_string = string.gsub(js_qr_wifi_string, ":", [[\:]])
js_qr_wifi_string = string.gsub(js_qr_wifi_string, ",", [[\,]])
js_qr_wifi_string = string.gsub(js_qr_wifi_string, "/", [[\/]])
return js_qr_wifi_string
end
function get_wlan_qr_string(ssid, enc, key, hidden)
local pass = ""
if key then
pass = key
end
local auth_type = "nopass"
if enc == "1" then
auth_type = "WEP"
elseif enc == "2" or enc == "3" or enc == "4" then
auth_type = "WPA"
end
local hidden_string = ""
if hidden and hidden == "1" then
hidden_string = "H:true"
end
return [[WIFI:S:]]..get_escaped_js_qr_wifi_string(ssid)..[[;T:]]..auth_type..[[;P:]]..get_escaped_js_qr_wifi_string(pass)..[[;]]..hidden_string..[[;]]
end
function write_printpreview_btn(condition)
if condition or condition == nil then
box.out([[<button type="button" id="uiViewPrintButton" name="print" onclick="showPrintView()">]]..box.tohtml(TXT([[{?3508:365?}]]))..[[</button>]])
end
end
function write_showPrintView_func(page_type)
if not page_type then
page_type = ""
end
require"http"
local url = href.get('/wlan/pp_qrcode.lua',
http.url_param('page_type', tostring(page_type)),
http.url_param('stylemode', 'print'),
http.url_param('page_title', TXT([[{?3508:159?}]]))
)
local str=[[
function showPrintView(param_url)
{
var url = "]] .. url .. [[";
if (param_url)
url = url + "&" + param_url;
var ppWindow = window.open(url, "Zweitfenster", "width=815,height=620,statusbar,resizable=yes,scrollbars=yes");
ppWindow.focus();
}
]]
box.out(str)
end
function calc_ascii_key(hex_key)
local res=""
for i=1,#hex_key,2 do
local hex_char = string.sub(tostring(hex_key), i, i + 1) or ""
res=res..string.char(tonumber(hex_char, 16) or 0)
end
return res
end
if not g_no_auto_init_net_devices==true then
InitNetList()
end
