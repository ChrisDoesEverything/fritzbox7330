--<?lua
if "../?/?.lua;../lua/?.lua;../?.lua" ~= package.path then
box.end_page()
end
--?>
pg = {}
if next( box.post ) then
pg = box.post
elseif next( box.get ) then
pg = box.get
end
if not g_check_sid_cb then
g_check_sid_cb = function() end
end
local check_sid = require("check_sid")
gl.bib.check_sid = check_sid
gl.bib.log.disable()
function forbidden_char_in_dir_file(str, not_allowed)
if string.find(str, not_allowed) then
return true
end
return false
end
function var_dir_picture_ok(str, delim)
if not delim or delim == "" then
delim = gl.delim
end
for part in string.gmatch(str, ".-"..gl.delim) do
part = string.sub(part, 1, string.len(part)-string.len(gl.delim))
if string.len(part) > 255 or forbidden_char_in_dir_file(part, gl.forbidden_char_pattern) then
return false
end
end
return true
end
gl.forbidden_char_pattern = '[\\\/\:\*\?\"\<\>\|]'
gl.delim = '://'
gl.bib.textdb = require("textdb")
gl.var.style="default"
gl.bib.href = require("href")
gl.bib.js = require("js")
local commands_allowed = {delete=true,newdir=true,["rename"]=true,copy=true,paste=true,create_share=true,del_share=true,ref_share=true,pic=true,audio=true,video=true,httpdownload=true,multidownload=true}
if pg.cmd~=nil and pg.cmd~="" and commands_allowed[pg.cmd] then gl.cmd = pg.cmd end
if gl.logged_in then
gl.bib.gpl = require("get_param_line")
gl.filelink_mode = (gl.int_userid and gl.int_userid > 109 and gl.int_userid < 200)
gl.var.site = "files"
local sites_allow = {pictures=true,files=true,help=true,login=true,share=true}
if pg.site ~= nil and pg.site~="" and sites_allow[pg.site] then gl.var.site = pg.site end
if pg.own_email or pg.own_password then
if pg.apply then
require"sso_dropdown"
if not sso_dropdown.save_values() then
gl.var.site = "sso_editmyself"
end
elseif not pg.cancel then
gl.var.site = "sso_editmyself"
end
end
gl.bib.store = require("store")
gl.var.search = ""
if pg.search~=nil then gl.var.search = box.tohtml(pg.search) end
gl.scan_detail = 0
local tmp_scan_detail = tonumber(pg.scan_detail)
if tmp_scan_detail then gl.scan_detail = tmp_scan_detail end
if pg.helppage and pg.helppage ~= "" then gl.helppage = box.tohtml(box.tojs(pg.helppage)) end
if gl.var.site ~= "help" and gl.var.site ~= "sso_editmyself" then
gl.ajax_url = "/nas/ajax_files_browse.lua"
gl.root_dir = "/fritz.nas"
if pg.cmd_files and pg.cmd_files ~= "" then
local skip_forbidden_char_check = {httpdownload=true,pic=true,audio=true,video=true}
gl.cmd_files = {}
local second_delim = [[/]]
local cnt = 0
for elem in string.gmatch(pg.cmd_files, ".-"..gl.delim) do
elem = string.sub(elem, 1, string.len(elem)-string.len(gl.delim))
local elem_ok = true
local start = string.sub(elem, 1, 2)
if start == "D/" or start == "F/" then
elem = string.sub(elem, 2)
end
for part in string.gmatch(elem, "[^"..second_delim.."]+") do
if string.len(part) > 255 or (not skip_forbidden_char_check[gl.cmd] and forbidden_char_in_dir_file(part, gl.forbidden_char_pattern)) then
elem_ok = false
break
end
end
if elem_ok then
cnt = cnt + 1
gl.cmd_files[cnt] = elem
end
end
end
gl.var.sort_by = "filename"
local sort_by_allowed = {size=true,filename=true,["type"]=true,mtime=true}
if pg.sort_by~=nil and pg.sort_by~="" and sort_by_allowed[pg.sort_by] then gl.var.sort_by = pg.sort_by end
gl.var.sort_order = "up"
local sort_order_allowed = {up=true,down=true}
if pg.sort_order~=nil and pg.sort_order~="" and sort_order_allowed[pg.sort_order] then gl.var.sort_order = pg.sort_order end
gl.fl_node = nil
if pg.fl_node~=nil and pg.fl_node~="" then gl.fl_node = box.tohtml(pg.fl_node) end
gl.expire = nil
if pg.expire~=nil and tonumber(pg.expire) then gl.expire = tonumber(pg.expire) end
gl.flname = nil
if pg.flname~=nil and pg.flname~="" then
local tmp = string.sub(pg.flname, 2, string.len(pg.flname)-string.len(gl.delim))
if string.len(tmp) > 255 or forbidden_char_in_dir_file(tmp, gl.forbidden_char_pattern) then
gl.flname = ""
else
gl.flname = tmp
end
end
gl.pic_width = 0
if pg.pw~=nil and pg.pw~="" then gl.pic_width = box.tohtml(pg.pw) end
gl.pic_height = 0
if pg.ph~=nil and pg.ph~="" then gl.pic_height = box.tohtml(pg.ph) end
gl.limit = nil
if pg.limit~=nil and tonumber(pg.limit) then gl.limit = tonumber(pg.limit) end
gl.var.dir="/"
local tmp_dir
if pg.dir~=nil and pg.dir~='' and var_dir_picture_ok(pg.dir) then tmp_dir = pg.dir end
if tmp_dir~=nil and tmp_dir~='' then
local deleted_dirup = 0
tmp_dir = string.reverse(tmp_dir)
while string.find(tmp_dir, "../", 1, true) == 1 do
tmp_dir = string.sub(tmp_dir, 4, string.len(tmp_dir))
deleted_dirup = deleted_dirup + 1
end
local start = 0
if deleted_dirup > 0 then
for i=1, deleted_dirup, 1 do
if tmp_dir ~= "" then
start = string.find(tmp_dir, "/", 1, true)
if start == string.len(tmp_dir) then
tmp_dir = ""
else
tmp_dir = string.sub(tmp_dir, start+1, string.len(tmp_dir))
end
end
end
end
gl.var.dir = string.reverse(tmp_dir)
end
if string.sub(gl.var.dir, string.len(gl.var.dir), string.len(gl.var.dir)) ~= "/" then
gl.var.dir = gl.var.dir..[[/]]
end
gl.ftps = box.query("ctlusb:settings/internet-secured") == "1"
gl.clipboard = "/var/tmp/nas_clipboard.txt"
if pg.picture~=nil and var_dir_picture_ok(pg.picture) then
gl.picture = pg.picture
if "/" ~= string.sub( gl.var.dir, 1, 1 ) then
gl.picture = [[/]] .. gl.picture
end
end
local tmp_pic_width = tonumber(pg.pic_width)
if tmp_pic_width then gl.pic_width = tmp_pic_width end
local tmp_pic_height = tonumber(pg.pic_height)
if tmp_pic_height then gl.pic_height = tmp_pic_height end
local tmp_result_code = tonumber(pg.ResultCode)
if tmp_result_code then gl.result_code = tmp_result_code end
local browse_mode_allowed = {["type:file"]=true,["type:directory"]=true}
if pg.browse_mode~=nil and pg.browse_mode~="" and browse_mode_allowed[pg.browse_mode] then gl.browse_mode = pg.browse_mode end
local tmp_total_file_count = tonumber(pg.total_file_count)
if tmp_total_file_count then gl.total_file_count = tmp_total_file_count end
local tmp_start_entry = tonumber(pg.start_entry)
if tmp_start_entry then gl.start_entry = tmp_start_entry end
gl.num_of_files = 100
if pg.num_of_files~=nil then
local tmp_num_of_files = tonumber(pg.num_of_files)
if tmp_num_of_files and tmp_num_of_files > 0 and tmp_num_of_files < 100 then
gl.num_of_files = tmp_num_of_files
end
end
gl.no_data_txt = [[<p class="error_browse_head">]]..box.tohtml(TXT([[{?832:263?}]]))..[[</p>]]
gl.cgi_error_txt = [[]]
if not gl.filelink_mode then
gl.cgi_error_txt = gl.cgi_error_txt..[[<p>]]..box.tohtml(TXT([[{?832:428?}]])) .. [[</p>]]
end
gl.bib.wu = require("libwebusb")
gl.bib.cw = require("call_webusb")
gl.bib.conv = require("convert_file_size")
gl.bib.wu.WebUsb_UseDB( true )
gl.bib.wu.WebUsb_Init(gl.username,gl.from_internet)
gl.bib.cr = require("cr_error")
gl.nas_user_dir = gl.bib.wu.WebUsb_GetRoot()
gl.ds_total, gl.ds_free, gl.ds_used, gl.ds_fail = gl.bib.wu.WebUsb_GetDiskInfo(gl.username,gl.var.dir)
if gl.ds_fail~=0 then
gl.ds_total = 1
gl.ds_free = 0
gl.ds_used = 0
elseif not(tonumber(gl.ds_total)) or (tonumber(gl.ds_total) <= 0) then
gl.ds_total = 1
elseif not(tonumber(gl.ds_used)) or (tonumber(gl.ds_used) < 0) then
gl.ds_used = 0
elseif not(tonumber(gl.ds_free)) or (tonumber(gl.ds_free) < 0) then
gl.ds_free = 0
end
gl.write_rights = gl.bib.wu.WebUsb_IsWriteable(gl.username,gl.var.dir) == 1
gl.bib.share = require("share_bib")
local do_not_check = {multidownload=true,httpdownload=true,pic=true,audio=true,video=true}
if gl.cmd~=nil and not do_not_check[gl.cmd] then
gl.bib.cmd = require("check_commands")
end
end
gl.bib.jsinit = require("nas_init_js")
else
gl.var.site = "login"
local ajax_command_tab = {create_share=true}
if ajax_command_tab[gl.cmd] then
box.out([[{"login":"failed"}]])
box.end_page()
end
end
pg = {}
