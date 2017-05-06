<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("nas_init")
local return_tab = { login="failed" }
function check_cr_error(file)
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
function check_shared( file, shares )
for id, path in pairs( shares ) do
if path == file.path then
file.shared = true;
break;
end
end
return file
end
function check_size_info_webdav_spezial( total, used )
local webdav_mount = box.query( "webdavclient:settings/mountpoint" )
local usb_dev = gl.bib.store.get_usb_devices_list()
if string.find( gl.var.dir, "/" .. webdav_mount .. "/", 1, true ) == 1 then
for i, v in ipairs( usb_dev ) do
for j, logvol in ipairs( v.log_vol ) do
if (tonumber(logvol.capacity)-512000) <= total and total <= (tonumber(logvol.capacity)+512000) and
(tonumber(logvol.usedspace)-512000) <= used and used <= (tonumber(logvol.usedspace)+512000) then
return true
end
end
end
end
return false
end
function get_drive_size()
if gl.filelink_mode or gl.bib.wu == nil or gl.ds_fail~=0 or check_size_info_webdav_spezial( gl.ds_total, gl.ds_used ) then
return -1, -1
end
return tonumber( gl.ds_free ), tonumber( gl.ds_total )
end
if not gl.logged_in then
box.out(gl.bib.js.table(return_tab))
box.end_page()
else
if gl.start_entry <= 0 or not gl.var.dir or not gl.browse_mode or (gl.browse_mode and gl.browse_mode ~= "type:file" and gl.browse_mode ~= "type:directory") then
return_tab = { start_entry=0, browse_mode="", root=false, writable=false, error_code="-1", error_txt="", elems={}, dir="/", free_space=-1, total_space=-1 }
else
local total_run_elem_cnt = 0
local run_elem_cnt = 0
local max_elem = 50
if gl.start_entry >= max_elem then
max_elem = 200
end
local no_more_data = false
local elems = {}
gl.bib.general = require("general")
local shares = gl.bib.general.listquery("filelinks:settings/link/list(id,path)")
local my_shares = {}
for key, share in pairs( shares ) do
if share.id and 0 < #share.id and true then
my_shares[share.id] = string.sub( share.path, #gl.nas_user_dir )
end
end
repeat
if gl.var.search==nil or gl.var.search=="" then
result_browse, fail, err_txt, rest = gl.bib.cw.call_webusb_func("browse", gl.username, gl.var.dir, gl.browse_mode, gl.start_entry, (max_elem - total_run_elem_cnt), "+filename")
else
result_browse, fail, err_txt, rest = gl.bib.cw.call_webusb_func("search", gl.username, "/", [[keyword="]]..gl.var.search..[["]], gl.browse_mode, gl.start_entry, ( max_elem - total_run_elem_cnt ), "+filename")
end
for i,v in ipairs(result_browse) do
if v.filename~="." then
v = check_cr_error( v )
if v.filename~=".." then
v = check_shared( v, my_shares )
end
table.insert(elems, v)
if v.filename~=".." then
total_run_elem_cnt = total_run_elem_cnt + 1
run_elem_cnt = run_elem_cnt + 1
else
if gl.browse_mode == "type:file" then
table.remove(elems);
end
end
end
end
if "" == fail or "browse_no_data" == fail or "search_no_data" == fail then
if rest then
no_more_data = true
gl.start_entry = gl.start_entry + run_elem_cnt
else
if gl.browse_mode == "type:directory" then
if total_run_elem_cnt >= max_elem then
no_more_data = true
end
gl.start_entry = 1
run_elem_cnt = 0;
gl.browse_mode = "type:file"
else
no_more_data = true
gl.start_entry = 0
end
end
else
no_more_data = true
gl.start_entry = 0
end
until no_more_data
local free, total = get_drive_size();
return_tab = { start_entry=gl.start_entry, browse_mode=gl.browse_mode, root=((gl.bib.wu.WebUsb_GetRoot() == "/") or false), writable=(gl.bib.wu.WebUsb_IsWriteable(gl.username,gl.var.dir) == 1), error_code=fail, error_txt=err_txt, elems=elems, dir=gl.var.dir, free_space=free, total_space=total }
end
box.out(gl.bib.js.table(return_tab))
end
?>
