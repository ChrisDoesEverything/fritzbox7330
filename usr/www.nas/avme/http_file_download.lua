<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("nas_init")
function error_redirect()
gl.bib.http.redirect( [[/nas/css/]]..gl.var.style..[[/images/icon_bild_xl.png]], 303)
end
if not gl.logged_in then
gl.bib.http.redirect("/nas")
else
if gl.cmd == "httpdownload" or gl.cmd == "pic" or gl.cmd == "audio" or gl.cmd == "video" then
if not gl.cmd_files or not gl.cmd_files[1] or gl.cmd_files[1] == "" then
fail = 99
elseif (gl.cmd == "pic") then
fail = gl.bib.wu.WebUsb_GetImage( gl.username, gl.cmd_files[1], gl.pic_width, gl.pic_height)
else
if string.find(gl.cmd_files[1], "/") ~= 1 then
gl.cmd_files[1] = "/" .. gl.cmd_files[1]
end
fail = gl.bib.wu.WebUsb_Get ( gl.username, gl.cmd_files[1])
end
if type(fail) == "number" then
if fail == 0 then
cmd_files = ""
else
require("general")
box.html(general.sprintf(TXT([[{?126:352?}]]), gl.cmd_files))
end
end
elseif gl.cmd == "multidownload" and (gl.var.site == "files" or gl.var.site == "pictures") then
if not gl.cmd_files or type(gl.cmd_files) ~= "table" or #gl.cmd_files < 1 then
fail = 99
else
fail = gl.bib.wu.WebUsb_GetMultipleFiles(
gl.username,
"",
gl.cmd_files,
99999 )
end
if type(fail) == "number" then
if fail == 0 then
cmd_files = ""
else
if gl.cmd == "pic" then
error_redirect()
else
box.html(TXT([[{?126:712?}]]))
end
end
end
end
end
?>
