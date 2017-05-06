<?lua
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
function forbidden_char_path(dir)
if string.find(dir, '[\\\:\*\?\"\<\>\|]') then
return true
end
return false
end
function getDir(dir)
if not dir or type(dir) ~= "string" or dir == "" or string.len(dir) > 255 or forbidden_char_path(dir) then
return nil
end
if string.sub(dir, string.len(dir), string.len(dir)) ~= "/" then
dir = dir..[[/]]
end
return dir
end
function check_cr_error(file)
--Achtung ein %0d = Carrige Return kann bei Internen Speicher Fehlern auftreten um muss aus der path und filename raus.
if file.filename then
file.filename = string.gsub(file.filename, "\n", "")
file.filename = string.gsub(file.filename, "\r", "")
end
if file.path then
file.path = string.gsub(file.path, "\n", "")
file.path = string.gsub(file.path, "\r", "")
end
return file
end
if gl and gl.logged_in and gl.areas and gl.areas.nas and gl.areas.nas.show then
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
if not pg.browse_mode or pg.browse_mode ~= "type:directory" then
pg.browse_mode = "type:file"
end
pg.dir = getDir(pg.dir)
local return_tab = {}
require("js")
if pg.startpos > 0 and pg.dir and pg.ajax_id >= 0 and pg.ajax_id < 10001 then
gl.bib={}
gl.bib.wu = require("libwebusb")
gl.bib.cw = require("call_webusb")
gl.bib.wu.WebUsb_UseDB( true )
gl.bib.wu.WebUsb_Init(gl.username, gl.from_internet)
local total_run_elem_cnt = 0
local run_elem_cnt = 0
local max_elem = 50
local no_more_data = false
local elems = {}
repeat
result_browse, fail, err_txt, rest = gl.bib.cw.call_webusb_func( "browse", gl.username, pg.dir, pg.browse_mode, pg.startpos, ( max_elem - total_run_elem_cnt ), "+filename" )
for i,v in ipairs(result_browse) do
if v.filename~="." then
v = check_cr_error( v )
table.insert(elems, v)
if v.filename~=".." then
total_run_elem_cnt = total_run_elem_cnt + 1
run_elem_cnt = run_elem_cnt + 1
else
if pg.browse_mode == "type:file" then
table.remove(elems);
end
end
end
end
if fail == "" or fail == "browse_no_data" then
if rest then
no_more_data = true
pg.startpos = pg.startpos + run_elem_cnt
else
if pg.browse_mode == "type:directory" then
if total_run_elem_cnt >= max_elem then
no_more_data = true
end
pg.startpos = 1
run_elem_cnt = 0;
pg.browse_mode = "type:file"
else
no_more_data = true
pg.startpos = 0
end
end
else
no_more_data = true
pg.startpos = 0
end
until no_more_data
return_tab = { area="nasArea", startPos=pg.startpos, browse_mode=pg.browse_mode, ajax_id=pg.ajax_id, root=((gl.bib.wu.WebUsb_GetRoot() == "/") or false) , error_code=fail, error_txt=err_txt, elems=elems }
else
return_tab = { area="nasArea", startPos=0, browse_mode="", ajax_id=pg.ajax_id, root=false, error_code="-1", error_txt="", elems={} }
end
box.out(js.table(return_tab))
end
?>
