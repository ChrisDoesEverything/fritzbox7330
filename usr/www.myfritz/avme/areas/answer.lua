<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
if gl and gl.logged_in and gl.areas and gl.areas.answer and gl.areas.answer.show then
require("js")
pg = {}
if next(box.post) then
pg = box.post
elseif next(box.get) then
pg = box.get
end
box.post = nil
box.get = nil
if pg.startpos and tonumber(pg.startpos) then
pg.startpos = tonumber(pg.startpos)
else
pg.startpos = 0
end
if pg.ajax_id and tonumber(pg.ajax_id) then
pg.ajax_id = tonumber(pg.ajax_id)
else
pg.ajax_id = -1
end
local return_tab = {}
if pg.ajax_id >= 0 and pg.ajax_id < 10001 then
local calllog = require("libcallloglua")
require("href")
local tmp_tamcalls = calllog.GetTamCallsRange(-1, pg.startpos, 50)
return_tab = { area="answerArea", tamcalls=tmp_tamcalls, startpos=pg.startpos, ajax_id=pg.ajax_id }
end
box.out(js.table(return_tab))
end
?>
