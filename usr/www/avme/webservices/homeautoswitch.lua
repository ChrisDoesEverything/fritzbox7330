<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
g_check_sid_zone = "all"
g_login_check_ok = 0
--funktion beendet die Seite und gibt nichts zurück
function cb_check_loggedin()
--wenn man nicht eingeloggt ist oder keine Lese bzw. Schreibrechte hat dann beenden.
if not gl.logged_in or gl.userrights.HomeAuto==nil or (gl.userrights.HomeAuto ~= 1 and gl.userrights.HomeAuto ~= 2) then
g_login_check_ok = 0
box.header(
"HTTP/1.0 403 Forbidden\nContent-Length: 0\nContent-Type: text/plain; charset=utf-8\n\n"
)
box.end_page()
else
g_login_check_ok = 1
end
end
g_check_sid_cb = cb_check_loggedin
require("check_sid")
if(g_login_check_ok==1) then
require("libaha")
require("ha_func_lib")
function get_id( ain)
local ldevices = aha.GetDeviceList()
if ( ldevices ~=nil and #ldevices > 0 ) then
for i=1, #ldevices do
if ( tostring( ain) == tostring(ldevices[i].Identifyer)) then
return tostring(ldevices[i].ID)
else
require("string")
basicain = string.gsub( tostring(ldevices[i].Identifyer) , " ", "")
if ( tostring(ain) == basicain ) then
return tostring(ldevices[i].ID)
end
end
end
end
return nil
end
function is_device_present(device)
if(device~=nil) then
if (device.Valid == 2) then
valid = true
else
valid = false
end
else
valid = false
end
return valid
end
function xml_escape(str)
str = string.gsub(str, "&", "&amp;")
str = string.gsub(str, "'", "&apos;")
str = string.gsub(str, "<", "&lt;")
str = string.gsub(str, ">", "&gt;")
str = string.gsub(str, '"', "&quot;")
return str
end
function write_switch_on(id)
local switchon = "error"
if (id~=nil) then
local ldevice = aha.GetSwitch(tonumber(id))
local lpresentdevice = aha.GetDevice(tonumber(id))
if(lpresentdevice~=nil and ldevice~=nil) then
if (is_device_present(lpresentdevice)) then
if (ldevice.SwitchOn == 0) then
switchon = "0"
elseif(ldevice.SwitchOn == 1) then
switchon = "1"
end
else
switchon = "inval"
end
end
end
if(switchon == "error") then
set_http_error()
else
box.out(switchon)
end
end
function write_switch_list()
local switchlist = ""
local ldevices = aha.GetDeviceList()
if ( ldevices ~=nil and #ldevices > 0 ) then
for i=1, #ldevices do
local ldevice = aha.GetSwitch(tonumber(ldevices[i].ID))
if(ldevice ~= nil) then
basicain = string.gsub( tostring(ldevices[i].Identifyer) , " ", "")
if( switchlist == "") then
switchlist = switchlist .. basicain
else
switchlist = switchlist .. "," .. basicain
end
end
end
end
box.out(switchlist)
end
function write_device_list_infos()
local xmlinfo = ""
xmlinfo = xmlinfo ..[[<devicelist version="1">]]
local ldevices = aha.GetDeviceList()
if (ldevices ~=nil and #ldevices > 0 ) then
for i=1, #ldevices do
local id = tonumber(ldevices[i].ID)
local switchdevice = aha.GetSwitch(id)
local multimeterdevice = aha.GetMultimeterWithoutRefresh(id)
local temperaturedevice = aha.GetTemperature(id)
local groupdevice = aha.GetGroup(id)
local device = ldevices[i]
local present = ""
if( tonumber( device.DeviceType) == 11) then
xmlinfo = xmlinfo .. [[<group]]
else
xmlinfo = xmlinfo .. [[<device]]
end
--Attribute
--AIN
xmlinfo = xmlinfo .. [[ identifier="]] .. device.Identifyer .. [["]]
--id
xmlinfo = xmlinfo .. [[ id="]] .. tostring(device.ID) .. [["]]
--FunctionBitMask
xmlinfo = xmlinfo .. [[ functionbitmask="]] .. tostring(device.FunctionBitMask) .. [["]]
--FWVersion
xmlinfo = xmlinfo .. [[ fwversion="]] .. tostring(device.FWVersion) .. [["]]
--Manufacturer
xmlinfo = xmlinfo .. [[ manufacturer="]] .. tostring(device.Manufacturer) .. [["]]
--ProductName
xmlinfo = xmlinfo .. [[ productname="]] .. tostring(device.ProductName) .. [["]]
xmlinfo = xmlinfo .. [[>]]
--present
if(is_device_present(device)) then
present = "1"
else
present = "0"
end
xmlinfo = xmlinfo .. [[<present>]] .. present .. [[</present>]]
xmlinfo = xmlinfo .. [[<name>]] .. xml_escape(device.Name) .. [[</name>]]
--switch
if(switchdevice ~= nil) then
xmlinfo = xmlinfo .. [[<switch>]]
local switchon = ""
local switchmode = ""
local switchlock = ""
--Switchmode
local standby = aha.GetSwitchStandbyOffRule(id)
local timer = aha.GetSwitchTimer(id)
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( timer)
if(standby~=nil and timer~=nil and l_b_value~=nil) then
if ( (( standby.Seconds == 0 ) or ( standby.Seconds == 65535 ) or ( standby.Power == 0 ) or ( standby.Power == 65535 ) ) and l_b_value==false ) then
switchmode = "manuell"
else
switchmode = "auto"
end
end
--switchon, switchlock
if(is_device_present(device)) then
if (switchdevice.SwitchOn == 0) then
switchon = "0"
elseif(switchdevice.SwitchOn == 1) then
switchon = "1"
end
if (switchdevice.SwitchLock == 0) then
switchlock = "0"
elseif(switchdevice.SwitchLock == 7) then
switchlock = "1"
end
else
switchon = ""
switchmode = ""
switchlock = ""
end
--switchon
xmlinfo = xmlinfo .. [[<state>]] .. switchon .. [[</state>]]
--switchmode
xmlinfo = xmlinfo .. [[<mode>]] .. switchmode .. [[</mode>]]
--switchlock
xmlinfo = xmlinfo .. [[<lock>]] .. switchlock .. [[</lock>]]
xmlinfo = xmlinfo .. [[</switch>]]
end --switchdevice
--multimeterdevice
if(multimeterdevice ~= nil) then
xmlinfo = xmlinfo .. [[<powermeter>]]
local power = ""
local energy = ""
--Energy und Power
if (is_device_present(device)) then
if(multimeterdevice.Power == -9999) then
power = ""
else
power = tostring((multimeterdevice.Power*10))
energy = tostring(multimeterdevice.Energie)
end
else
power = ""
energy = ""
end
--power
xmlinfo = xmlinfo .. [[<power>]] .. power .. [[</power>]]
--energy
xmlinfo = xmlinfo .. [[<energy>]] .. energy .. [[</energy>]]
xmlinfo = xmlinfo .. [[</powermeter>]]
end
--temperaturedevice
if(temperaturedevice ~= nil) then
xmlinfo = xmlinfo .. [[<temperature>]]
local Celsius = ""
local Offset = ""
--Offset Celsius
if (is_device_present(device)) then
if(temperaturedevice.Celsius == -9999) then
Celsius = ""
else
Celsius = tostring(temperaturedevice.Celsius)
end
if(temperaturedevice.Offset == -9999) then
Offset = ""
else
Offset = tostring(temperaturedevice.Offset)
end
end
--Celsius
xmlinfo = xmlinfo .. [[<celsius>]] .. Celsius .. [[</celsius>]]
--Offset
xmlinfo = xmlinfo .. [[<offset>]] .. Offset .. [[</offset>]]
xmlinfo = xmlinfo .. [[</temperature>]]
end
--Gruppe
if( tonumber( device.DeviceType) == 11 and groupdevice ~= nil) then
xmlinfo = xmlinfo .. [[<groupinfo>]]
local masterdeviceid = ""
local members = ""
--masterdeviceid
xmlinfo = xmlinfo .. [[<masterdeviceid>]] .. groupdevice.MasterDeviceID .. [[</masterdeviceid>]]
--members
local grouptestdevices = aha.GetDeviceList()
if ( grouptestdevices ~=nil and #grouptestdevices > 0 ) then
for i=1, #grouptestdevices do
if ( tostring( groupdevice.Identifyer) ~= tostring(grouptestdevices[i].Identifyer)) then
if(tostring(groupdevice.GroupHash) == tostring(grouptestdevices[i].GroupHash)) then
if( members == "") then
members = members .. tostring(grouptestdevices[i].ID)
else
members = members .. "," .. tostring(grouptestdevices[i].ID)
end
end
end
end--for
end
xmlinfo = xmlinfo .. [[<members>]] .. members .. [[</members>]]
xmlinfo = xmlinfo .. [[</groupinfo>]]
end
if( tonumber( device.DeviceType) == 11) then
xmlinfo = xmlinfo .. [[</group>]]
else
xmlinfo = xmlinfo .. [[</device>]]
end
end --for
end --devicelist
xmlinfo = xmlinfo .. [[</devicelist>]]
box.out(xmlinfo)
end --function
function write_switch_manual(id)
local switchmanual = "error"
if (id~=nil) then
local standby = aha.GetSwitchStandbyOffRule(tonumber(id))
local timer = aha.GetSwitchTimer(tonumber(id))
local l_b_value, l_sz_name, l_sz_value = ha_func_lib.is_timer_active( timer)
if(standby~=nil and timer~=nil and l_b_value~=nil) then
if( (standby.Power~=0 and standby.Seconds~=0) and l_b_value==false ) then
switchmanual = "0"
else
switchmanual = "1"
end
end
end
if(switchmanual == "error") then
set_http_error()
else
box.out(switchmanual)
end
end
function write_switch_valid(id)
local valid = "error"
if (id~=nil) then
local ldevice = aha.GetDevice(tonumber(id))
if (ldevice~=nil) then
if(is_device_present(ldevice)) then
valid = "1"
else
valid = "0"
end
end
end
if(valid == "error") then
set_http_error()
else
box.out(valid)
end
end
function write_set_switch_on(id, onoff)
local switchon = "error"
if (id~=nil and (onoff==1 or onoff==0)) then
local ldevice = aha.GetSwitch(tonumber(id))
local lpresentdevice = aha.GetDevice(tonumber(id))
if(lpresentdevice~=nil and ldevice~=nil) then
aha.SetSwitchOnOff(tonumber(id), onoff)
switchon = tostring(onoff)
end
end
if(switchon == "error") then
set_http_error()
else
box.out(switchon)
end
end
function write_set_switch_toggle(id)
local switchon = "error"
if (id~=nil) then
local ldevice = aha.GetSwitch(tonumber(id))
local lpresentdevice = aha.GetDevice(tonumber(id))
if(lpresentdevice~=nil and ldevice~=nil) then
local onoff = 0
if(ldevice.SwitchOn == 0) then
onoff = 1
else
onoff = 0
end
aha.SetSwitchOnOff(tonumber(id), onoff)
switchon = tostring(onoff)
end
end
if(switchon == "error") then
set_http_error()
else
box.out(switchon)
end
end
function write_switch_name(id)
local name = "error"
if (id~=nil) then
local ldevice = aha.GetDevice(tonumber(id))
if (ldevice~=nil) then
name = tostring(ldevice.Name)
end
end
if(name == "error") then
set_http_error()
else
box.out(name)
end
end
function write_switch_power(id)
local power = "error"
if (id~=nil) then
local ldevice = aha.GetMultimeterWithoutRefresh(tonumber(id))
local lpresentdevice = aha.GetDevice(tonumber(id))
if(lpresentdevice~=nil and ldevice~=nil) then
if (is_device_present(lpresentdevice)) then
if(ldevice.Power == -9999) then
power = "inval"
else
power = tostring((ldevice.Power*10))
end
else
power = "inval"
end
end
end
if(power == "error") then
set_http_error()
else
box.out(power)
end
end
function write_switch_energy(id)
local power = "error"
if (id~=nil) then
local ldevice = aha.GetMultimeterWithoutRefresh(tonumber(id))
local lpresentdevice = aha.GetDevice(tonumber(id))
if(lpresentdevice~=nil and ldevice~=nil) then
if (is_device_present(lpresentdevice)) then
if(ldevice.Energie == -9999) then
power = "inval"
else
power = tostring(ldevice.Energie)
end
else
power = "inval"
end
end
end
if(power == "error") then
set_http_error()
else
box.out(power)
end
end
function set_http_error()
box.header(
"HTTP/1.0 500 Internal Server Error\nContent-Length: 0\nContent-Type: text/plain; charset=utf-8\n\n"
)
box.end_page()
end
function set_http_bad_request()
box.header(
"HTTP/1.0 400 Bad Request\nContent-Length: 0\nContent-Type: text/plain; charset=utf-8\n\n"
)
box.end_page()
end
function set_http_ok()
box.header(
"HTTP/1.0 200 OK\n"
.. "Content-Type: text/plain; charset=utf-8\n"
.. "\n"
)
end
function set_http_ok_xml()
box.header(
"HTTP/1.0 200 OK\n"
.. "Content-Type: text/xml; charset=utf-8\n"
.. "\n"
)
end
------------------------------------------------------------------------------
-- main
if ( next(box.get)) then
if box.get.ain and box.get.switchcmd then
local id = get_id(tostring(box.get.ain))
if (id==nil) then
set_http_bad_request()
else
if (box.get.switchcmd == "getswitchstate") then
set_http_ok()
write_switch_on(id)
elseif (box.get.switchcmd == "getswitchmode") then
set_http_ok()
write_switch_manual(id)
elseif (box.get.switchcmd == "getswitchpresent") then
set_http_ok()
write_switch_valid(id)
elseif (box.get.switchcmd == "getswitchpower") then
set_http_ok()
write_switch_power(id)
elseif (box.get.switchcmd == "getswitchname") then
set_http_ok()
write_switch_name(id)
elseif (box.get.switchcmd == "getswitchenergy") then
set_http_ok()
write_switch_energy(id)
elseif (box.get.switchcmd == "setswitchon") then
set_http_ok()
write_set_switch_on(id, tonumber(1))
elseif (box.get.switchcmd == "setswitchoff") then
set_http_ok()
write_set_switch_on(id, tonumber(0))
elseif (box.get.switchcmd == "setswitchtoggle") then
set_http_ok()
write_set_switch_toggle(id)
elseif (box.get.switchcmd == "getswitchlist") then
set_http_ok()
write_switch_list()
elseif (box.get.switchcmd == "getdevicelistinfos") then
set_http_ok_xml()
write_device_list_infos()
else
set_http_bad_request()
end
end
else
if box.get.switchcmd then
if (box.get.switchcmd == "getswitchlist") then
set_http_ok()
write_switch_list()
elseif (box.get.switchcmd == "getdevicelistinfos") then
set_http_ok_xml()
write_device_list_infos()
end
else
set_http_bad_request()
end
end
else
set_http_bad_request()
end
else
box.header(
"HTTP/1.0 403 Forbidden\nContent-Length: 0\nContent-Type: text/plain; charset=utf-8\n\n"
)
end
?>
