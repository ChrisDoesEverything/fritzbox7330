<?lua
package.path = "../?/?.lua;../lua/?.lua;../?.lua"
require("nas_init")
box.header()
function error_redirect()
gl.bib.http.redirect( [[/nas/css/]]..gl.var.style..[[/images/icon_bild_xl.png]], 303)
end
if not gl.logged_in then
box.end_page()
else
if not(gl.picture) or not(gl.pic_width) or not(gl.pic_height) then
error_redirect()
else
fail = gl.bib.wu.WebUsb_GetImage (
gl.username,
gl.picture,
gl.pic_width,
gl.pic_height
)
if type(fail)=="number" and fail > 0 then
error_redirect()
end
end
end
?>
