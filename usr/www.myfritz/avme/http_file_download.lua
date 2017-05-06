<?lua
--http_file_download
package.path = "../lua/?.lua;../menus/?.lua;../files/?.lua;../help/?.lua;../?.lua;" .. (package.path or "")
require("check_sid")
require("areas")
function error_redirect()
require("http")
http.redirect( [[/myfritz/css/default/images/icon_bild_xl.png]], 303)
end
if gl and gl.logged_in then
--gl.cmd_files Die Dateien auf die das cmd auszuführen ist.
gl.cmd_files = ""
if box.get.cmd_files~=nil and box.get.cmd_files~="" then gl.cmd_files = box.get.cmd_files end
if box.post.cmd_files~=nil and box.post.cmd_files~="" then gl.cmd_files = box.post.cmd_files end
gl.cmd = ""
if box.get.cmd~=nil and box.get.cmd~="" then gl.cmd = box.get.cmd end
if box.post.cmd~=nil and box.post.cmd~="" then gl.cmd = box.post.cmd end
gl.pic_width = 0
if box.get.pw~=nil and box.get.pw~="" and tonumber(box.get.pw) then gl.pic_width = tonumber(box.get.pw) end
if box.post.pw~=nil and box.post.pw~="" and tonumber(box.post.pw) then gl.pic_width = tonumber(box.post.pw) end
gl.pic_height = 0
if box.get.ph~=nil and box.get.ph~="" and tonumber(box.get.ph) then gl.pic_height = tonumber(box.get.ph) end
if box.post.ph~=nil and box.post.ph~="" and tonumber(box.post.ph) then gl.pic_height = tonumber(box.post.ph) end
gl.tam_idx = ""
if box.get.tam~=nil and box.get.tam~="" and tonumber(box.get.tam) then gl.tam_idx = tonumber(box.get.tam) end
if box.post.tam~=nil and box.post.tam~="" and tonumber(box.post.tam) then gl.tam_idx = tonumber(box.post.tam) end
gl.tam_msg_idx = ""
if box.get.msg~=nil and box.get.msg~="" and tonumber(box.get.msg) then gl.tam_msg_idx = tonumber(box.get.msg) end
if box.post.msg~=nil and box.post.msg~="" and tonumber(box.post.msg) then gl.tam_msg_idx = tonumber(box.post.msg) end
gl.bib.wu = require("libwebusb")
gl.bib.wu.WebUsb_Init( gl.username, box.frominternet())
local fail = 9999
if gl.cmd == "tam" then
fail = gl.bib.wu.WebUsb_GetTamFile( gl.cmd_files )
elseif gl.cmd == "pic" then
fail = gl.bib.wu.WebUsb_GetImage( gl.username, gl.cmd_files, gl.pic_width, gl.pic_height )
else
fail = gl.bib.wu.WebUsb_Get( gl.username, gl.cmd_files ) --Pfad und name der Datei.
end
-- hier noch die Fehlerbehandlung und fertch
if type(fail) == "number" and fail > 0 then
if gl.cmd == "pic" then
error_redirect()
else
require("general")
box.html(general.sprintf(TXT([[{?3930:776?}]]), gl.cmd_files))
end
elseif gl.cmd == "tam" then
-- Wenn kein Fehler war, dann Tamnachricht als gelesen markieren.
local calllog = require( "libcallloglua" )
calllog.SetFlagOnTamCall( gl.tam_idx, gl.tam_msg_idx )
end
end
?>
