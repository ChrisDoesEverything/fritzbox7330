<?lua
-- de-first -begin
g_page_type = "no_menu"
g_page_title = [[{?439:979?}]]
------------------------------------------------------------------------------------------------------------>
dofile("../templates/global_lua.lua")
require"html"
local function ten_minutes()
local t = tonumber(box.query("logic:status/uptime_hours")) or 0
if t > 0 then
return false
end
t = tonumber(box.query("logic:status/uptime_minutes")) or 0
return t < 10
end
local function pushmail_enabled()
return box.query("emailnotify:settings/enabled") == "1"
and box.query("emailnotify:settings/reset_pwd_enabled") == "1"
end
local function pushmail_button()
return html.button{name="pushmail", type="submit",
[[{?439:179?}]]
}
end
local function reset_button()
return html.button{type="submit", name="reset",
[[{?439:6?}]]
}
end
local function attention()
return html.div{
html.span{class="WarnMsgBold",
[[{?439:504?}]]
},
html.p{
[[{?439:876?}]]
}
}
end
function write_pushmail_sent_html()
html.h4{
[[{?439:867?}]]
}.write()
html.p{
[[{?439:394?} ]]
}.write()
end
function write_pushmail_html()
if pushmail_enabled() then
html.h4{
[[{?439:2735?}]]
}.write()
html.p{
[[{?439:107?}]]
}.write()
if ten_minutes() then
html.div{class="btn_form", pushmail_button()}.write()
end
end
end
function write_reset_html()
if pushmail_enabled() then
if ten_minutes() then
html.hr{}.write()
html.h4{
[[{?439:357?}]]
}.write()
html.p{
[[{?439:250?}]]
}.write()
attention().write()
html.div{class="btn_form", reset_button()}.write()
end
else
html.p{
[[{?439:342?}]]
}.write()
attention().write()
if not ten_minutes() then
html.p{
[[{?439:735?}]]
}.write()
end
end
end
function write_buttons()
if pushmail_enabled() and not ten_minutes() then
pushmail_button().write()
end
if not pushmail_enabled() then
reset_button().write()
end
html.button{type="submit", name="cancel",
[[{?txtCancel?}]]
}.write()
end
g_err = {}
function write_error()
if g_err.code and g_err.code ~= 0 then
require("general")
local criterr = general.create_error_div(g_err.code,g_err.msg)
box.out(criterr)
end
end
function pushmail_sent()
return box.get.pushmail == "sent"
end
require("http")
require("href")
require("cmtable")
if box.post.cancel then
http.redirect("/login.lua")
elseif box.post.reset then
require("webuicookie")
webuicookie.set_action_allowed_time()
local savecookie = {}
cmtable.add_var(savecookie, webuicookie.vars())
local err, str = box.set_config(savecookie)
http.redirect(href.get("/restore.lua", "restore=login"))
elseif box.post.pushmail then
local saveset = {}
cmtable.add_var(saveset, "login:command/forgot_password_pushmail", "1")
g_err.code, g_err.msg = box.set_config(saveset)
if g_err.code == 0 then
http.redirect(href.get("/vergessen.lua", http.url_param("pushmail", "sent")))
end
end
?>
<?include "templates/html_head.html" ?>
<?include "templates/page_head.html" ?>
<form name="mainform" action="/vergessen.lua" method="POST">
<?lua
write_error()
if pushmail_sent() then
write_pushmail_sent_html()
else
write_pushmail_html()
write_reset_html()
end
?>
<div id="btn_form_foot">
<?lua
if not pushmail_sent() then
write_buttons()
end
?>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
