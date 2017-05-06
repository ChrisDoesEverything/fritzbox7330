--[[Access denied<?lua
box.end_page()
?>]]
package.path = "../lua/?.lua;../menus/?.lua;../help/?.lua;" .. (package.path or "")
require("lualib")
g_tab_options = {}
function global_lua_check_sid_cb()
--Seiten auf denen kein Login nötig ist.
local no_login_page = {
["/login.lua"] = true,
["/logincheck.lua"] = true,
["/vergessen.lua"] = true,
["/restore.lua"] = true,
["/firmware_update_notify.lua"] = true,
["/myfritz_email_verified.lua"] = true
}
if not gl.logged_in and not no_login_page[box.glob.script] then
--Es ist eine Seite auf der ich mich einloggen muss.
if box.get.xhr or (box.post.xhr and box.post.validate) then
--es handelt sich um einen ajax request per get oder eine Ajax-Validation (per post)
--dann ein forbidden und keine Loginseite zurückgeben
require("http")
http.forbidden()
elseif box.post.xhr then
-- box.post.xhr, also ein POST per Ajax, da brechen wir einfach ab weil wir das allgemein nicht zulassen.
box.end_page()
else
--Kein Ajax und nicht eingelogged dann Fehlerbehandlung
local loc = "/login.lua"
local sep = "?"
loc = loc .. sep .. "page=" .. box.glob.script
sep = "&"
for name,value in pairs(box.get) do
if name:sub(-2)~="_i" then
loc = loc .. sep .. name .. "=" .. value
sep = "&"
end
end
if box.glob.inputsid then
loc = loc .. sep .. "sid=" .. box.glob.inputsid
end
require("http")
http.redirect(loc)
end
elseif gl.logged_in then
if box.get.xhr and gl.skipauth_sidchanged then
-- Eingelogged wg. skip_auth, aber die alte inputsid ist ungültig
require("http")
http.forbidden()
end
end
end
if not gl or not gl.security_zone or gl.security_zone == "box" then
if not g_check_sid_cb then
g_check_sid_cb = global_lua_check_sid_cb
end
require("check_sid")
end
require("log")
require("href")
require("config")
if box.get.stylemode and box.get.stylemode=="print" then
g_print_mode = true
end
