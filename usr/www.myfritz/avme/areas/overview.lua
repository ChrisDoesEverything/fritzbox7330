<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
if gl and gl.logged_in and gl.areas then
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
if pg.startpos and tonumber(pg.startpos) then
pg.startpos = tonumber(pg.startpos)
else
pg.startpos = 0
end
local return_tab = {}
if pg.ajax_id >= 0 and pg.ajax_id < 10001 then
return_tab = { area="overview", ajax_id=pg.ajax_id }
if gl.areas.answer and gl.areas.answer.show then
calllog = require("libcallloglua")
require("href")
local tmp_tamcalls = calllog.GetTamCallsRange(-1, 0, 3)
return_tab.answer = { tamcalls=tmp_tamcalls, startpos=pg.startpos }
end
if gl.areas.calls and gl.areas.calls.show then
calllog = require("libcallloglua")
clickToDialActive = (box.query("telcfg:settings/UseClickToDial") == "1" and tonumber(box.query("rights:status/Dial",0)) > 0) or false
return_tab.calls = { calls=calllog.GetRange(0, 3, 7, 7), startpos=pg.startpos, clickToDial=clickToDialActive }
end
if gl.areas.nas and gl.areas.nas.show then
end
if gl.areas.homeauto and gl.areas.homeauto.show then
require("libaha")
require("ha_func_lib")
local devices = aha.GetDeviceList()
local ha_devices = {}
local cnt = 0
if devices and type(devices) == "table" then
for i,device in ipairs(devices) do
if tonumber(device.FunctionBitMask) ~= 1024 then
cnt = cnt + 1
ha_devices[cnt] = device
ha_devices[cnt].switch = aha.GetSwitch(device.ID)
ha_devices[cnt].pv_min = -1
ha_devices[cnt].pv_max = -1
ha_devices[cnt].pv_now = -1
end
if cnt >= 3 then break end
end
end
return_tab.homeauto = { devices=ha_devices }
end
end
require("js")
box.out(js.table(return_tab))
end
?>
