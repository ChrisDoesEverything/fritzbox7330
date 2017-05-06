<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
if gl and gl.logged_in and gl.areas and gl.areas.calls and gl.areas.calls.show then
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
require("js")
local return_tab = {}
if pg.ajax_id >= 0 and pg.ajax_id < 10001 then
if pg.cmd and pg.cmd == "cn" then
require("cmtable")
local saveset = {}
if (pg.action=="dial") then
cmtable.add_var(saveset, "telcfg:command/Dial", pg.number)
elseif (pg.action=="hangup") then
cmtable.add_var(saveset, "telcfg:command/Hangup", "")
end
local err_code, err_msg = box.set_config(saveset)
return_tab = { area="callsArea", cid=pg.cid, ajax_id=pg.ajax_id }
else
local calllog = require("libcallloglua")
local clickToDialActive = (box.query("telcfg:settings/UseClickToDial") == "1" and tonumber(box.query("rights:status/Dial",0)) > 0) or false
return_tab = { area="callsArea", calls=calllog.GetRange(pg.startpos, 50, 7, 7), startpos=pg.startpos, clickToDial=clickToDialActive, ajax_id=pg.ajax_id }
end
end
box.out(js.table(return_tab))
end
?>
