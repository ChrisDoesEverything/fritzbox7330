<?lua
-- de-first -begin
--[[
Datei Name: no_password.lua
Datei Beschreibung: Warnung vor nicht gesetztem Kennwort
]]
g_page_type = "no_menu"
g_page_title = [[{?29:9187?}]]
dofile("../templates/global_lua.lua")
require("cmtable")
require("val")
require("first")
require("webuicookie")
require("boxusers")
g_hide_password = not boxusers.show_pwreminder()
or webuicookie.get("noPwdReminder") == "1"
g_hide_crashreport = not config.DOCSIS
or box.query("emailnotify:settings/crashreport_mode") ~= 'disable_mail'
function write_crashreport_checked()
if config.oem ~= 'kdg' then
box.out([[ checked]])
end
end
function hide_if(cond)
if cond then box.out([[ style="display:none;"]]) end
end
function btn_text()
if g_hide_password then
box.html([[{?txtOK?}]])
else
box.html([[{?txtOK?}]])
end
end
g_val = {}
g_val.prog = ""
if not g_hide_password then
g_val.prog = [[
if __checked(uiActive/active) then
not_empty(uiPass/pass, pass)
length(uiPass/pass, 0, 32, pass)
char_range_regex(uiPass/pass, boxpassword, pass)
end
]]
end
val.msg.pass = {
[val.ret.empty] = [[{?29:1964?}]],
[val.ret.tooshort] = [[]],
[val.ret.notfound] = [[]],
[val.ret.toolong] = [[{?29:885?}]],
[val.ret.outofrange] = [[{?29:5681?}]]
}
g_online = (box.query("connection0:status/connect")=="5")
if config.USB_GSM then
g_online = g_online or (box.query("umts:settings/enabled")=="1" and box.query("gsm:settings/Established")=="1")
end
if config.IPV6 then
g_online = g_online or (box.query("ipv6:settings/state")=="5")
end
g_whyUrl = ""
if g_online then
if config.language == "de" then
g_whyUrl = "http://www.avm.de/fritzbox_safety"
else
g_whyUrl = "http://www.avm.de/en/fritzbox_safety"
end
end
if box.post.apply then
if val.validate(g_val) == val.ret.ok then
local saveset = {}
if not g_hide_password then
if box.post.active or box.post.no_reminder then
if box.post.active and box.post.pass then
cmtable.add_var(saveset, "security:settings/password", box.post.pass)
end
if box.post.no_reminder then
webuicookie.set("noPwdReminder", "1")
end
end
end
if not g_hide_crashreport then
cmtable.add_var(saveset,
"emailnotify:settings/crashreport_mode",
box.post.crashreport and "to_support_only" or "disabled_by_user"
)
end
if config.DOCSIS and webuicookie.get("docsisSetupDone") == "2" then
webuicookie.set("docsisSetupDone", "0")
end
cmtable.add_var(saveset, webuicookie.vars())
local errcode, errmsg = box.set_config(saveset)
http.redirect("/login.lua")
end
end
?>
<?include "templates/html_head.html" ?>
<script type="text/javascript" src="/js/validate.js"></script>
<script type="text/javascript">
<?lua
if not g_hide_password then
val.write_js_error_strings()
end
?>
function uiDoOnMainFormSubmit()
{
var ret;
<?lua
if not g_hide_password then
val.write_js_checks(g_val)
end
?>
return true;
}
function uiDoOnActiveClick()
{
if (jxl.getChecked("uiActive")) {
jxl.disable("uiNoReminder")
jxl.disableNode("uiPasswordArea", false)
} else {
jxl.enable("uiNoReminder")
jxl.disableNode("uiPasswordArea", true)
}
}
function init()
{
jxl.addEventHandler("uiActive", "click", uiDoOnActiveClick);
uiDoOnActiveClick();
}
ready.onReady(val.init(uiDoOnMainFormSubmit, "apply", "main_form" ));
ready.onReady(init);
</script>
<?include "templates/page_head.html" ?>
<form class="narrow" method="POST" action="<?lua box.html(box.glob.script) ?>" name="main_form">
<div <?lua hide_if(g_hide_password) ?>>
<p>{?29:7827?}</p>
<div class="formular">
<input type="checkbox" id="uiActive" name="active" checked>
<label for="uiActive">{?29:3999?}</label>
<div class="formular" id="uiPasswordArea">
<label for="uiPass">{?29:5812?}</label>
<input type="text" name="pass" id="uiPass" maxlength="32" autocomplete="off" <?lua val.write_attrs(g_val, "uiPass") ?>>
</div>
</div>
<p>{?29:9096?}</p>
<?lua
if g_online then
box.out([[<p><a href="]]..g_whyUrl..[[" target="_blank">{?29:6462?}</a></p>]])
end
?>
<input type="checkbox" id="uiNoReminder" name="no_reminder">
<label for="uiNoReminder">{?29:3737?}</label>
</div>
<hr <?lua hide_if(g_hide_password or g_hide_crashreport) ?>>
<div <?lua hide_if(g_hide_crashreport) ?>>
<h4>{?29:151?}</h4>
<p>{?29:408?}</p>
<div class="formular">
<input type="checkbox" name="crashreport" id="uiCrashreport" <?lua write_crashreport_checked() ?>>
<label for="uiCrashreport">{?29:456?}</label>
<p class="form_input_explain">
{?29:547?}
</p>
</div>
</div>
<div id="btn_form_foot">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="submit" name="apply" id="uiApply" value="<?lua btn_text() ?>">
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
