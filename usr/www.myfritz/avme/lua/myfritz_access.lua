--[[Access denied<?lua
    box.end_page()
?>?>?>]]
module(...,package.seeall);
local function get_landevice_value(device,which)
device.landevice=device.landevice or{}
if not device.landevice[which]then
local lan_uid=device.landevice_UID
if lan_uid then
device.landevice[which]=box.query("landevice:settings/landevice["..lan_uid.."]/"..which)
end
end
return device.landevice[which]or""
end
function get_name(device)
return get_landevice_value(device,"name")
end
function is_any_share_active(list)
for i,device in ipairs(list)do
for j,service in ipairs(device.services)do
if service.Enabled=="1"then
return true
end
end
end
return false
end
function read_list(sorted)
require("general")
require("utf8")
local list_length=0
local list=general.listquery(
"myfritzdevice:settings/device/list(UID,landevice_UID,myfritz_state,dyndnslabel)"
)
if sorted then
utf8.sort(list,get_name)
end
for i,device in ipairs(list)do
device.services=general.listquery(
"myfritzdevice:settings/"..device._node.."/services/entry/list("
.."Enabled,Name,Scheme,Port,URLPath,IPv4ForwardingWarning"
..")"
)
list_length=list_length+#(device.services or{})
if sorted then
utf8.sort(device.services,function(s)return s.Name or""end)
end
end
return list,list_length
end
