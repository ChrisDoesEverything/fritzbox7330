<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
function getPowerValueStatistik(powerValues)
local pv_min, pv_max, pv_now = 0,0,0
if powerValues and powerValues.anzahl > 0 and powerValues.values then
pv_min = powerValues.values[1]
pv_max = powerValues.values[1]
pv_now = powerValues.values[1]
for i,v in ipairs(powerValues.values) do
if v < pv_min then pv_min = v end
if v > pv_max then pv_max = v end
end
end
return pv_min/100, pv_max/100, pv_now/100
end
if gl and gl.logged_in and gl.areas and gl.areas.homeauto and gl.areas.homeauto.show then
pg = {}
if next(box.post) then
pg = box.post
elseif next(box.get) then
pg = box.get
end
box.post = nil
box.get = nil
if pg.ajax_id and tonumber(pg.ajax_id) then
pg.ajax_id = tonumber(pg.ajax_id)
else
pg.ajax_id = -1
end
require("js")
local return_tab = {}
if pg.ajax_id >= 0 and pg.ajax_id < 10001 then
require("libaha")
if "switchChange" == pg.cmd then
local id = tonumber(pg.deviceId) or -1
local value = tonumber(pg.cmdValue) or -1
if id > 0 or value == 0 or value == 1 then
aha.SetSwitchOnOff(id, value)
return_tab = { status="switchStateChangedSend", deviceId=id, ajax_id=pg.ajax_id }
end
elseif "switchChangeCheck" == pg.cmd then
local id = tonumber(pg.deviceId) or -1
local value = tonumber(pg.cmdValue) or -1
if 0 < id or 0 == value or 1 == value then
local switch = aha.GetSwitch( id )
if switch and switch.SwitchOn == value then
return_tab = { status="switchStateChanged", deviceId=id, ajax_id=pg.ajax_id }
else
return_tab = { status="switchStateNotChanged", deviceId=id, ajax_id=pg.ajax_id }
end
end
elseif "getData" == pg.cmd then
require("ha_func_lib")
local devices = aha.GetDeviceList()
local ha_devices = {}
local cnt = 0
if devices and type(devices) == "table" then
for i,device in ipairs(devices) do
if tonumber( device.FunctionBitMask ) ~= 1024 then
cnt = cnt + 1
ha_devices[cnt] = device
ha_devices[cnt].switch = aha.GetSwitch( device.ID )
ha_devices[cnt].pv_min = -1
ha_devices[cnt].pv_max = -1
ha_devices[cnt].pv_now = -1
if device.Valid == 2 and ha_func_lib.has_energy_monitor( device.FunctionBitMask ) then
ha_devices[cnt].pv_min, ha_devices[cnt].pv_max, ha_devices[cnt].pv_now = getPowerValueStatistik( aha.GetSwitchEnergyStat10MinValues( device.ID ) )
end
ha_devices[cnt].temperature = -9999
local temp_tab = aha.GetTemperature( device.ID )
if temp_tab and "table" == type( temp_tab ) and "number" == type( temp_tab.Celsius ) then
ha_devices[cnt].temperature = temp_tab.Celsius
end
end
end
end
require("myfritz_access")
local mf_shares = {}
local myfritz_shares = myfritz_access.read_list("sorted")
local myfritz_url = box.query("jasonii:settings/dyndnsname")
for i,share in ipairs(myfritz_shares) do
local lanDevName = myfritz_access.get_name(share)
for i,service in ipairs(share.services) do
local url = {}
local dyndnslabel = share.dyndnslabel or ""
if "1" == service.Enabled and "string" == type(myfritz_url) and "" ~= myfritz_url and "string" == type(dyndnslabel) and "" ~= dyndnslabel then
--myfritz_url = dyndnslabel .. "." .. myfritz_url
local port = tonumber(service.Port)
if port then
port = ":" .. port
end
url = {
service.Scheme or "",
--myfritz_url,
dyndnslabel .. "." .. myfritz_url,
port,
service.URLPath or ""
}
local idx = #mf_shares + 1
mf_shares[idx] = {}
mf_shares[idx].uid = share.UID..service._node
mf_shares[idx].name = lanDevName
mf_shares[idx].service = service.Name
mf_shares[idx].url = table.concat(url, "")
end
end
end
return_tab = { area="homeautoArea", devices=ha_devices, shares=mf_shares, ajax_id=pg.ajax_id }
end
end
box.out(js.table(return_tab))
end
?>
