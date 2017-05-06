<?lua
g_page_type = "all"
g_page_title = ""
dofile("../templates/global_lua.lua")
require"cmtable"
require"newval"
require"js"
require"html"
require"http"
require"pushservice"
require"general"
g_back_to_page = http.get_back_to_page( "/system/push_list.lua" )
if box.get.list or box.post.list then
g_menu_active_page = "/system/push_list.lua"
else
g_menu_active_page = g_back_to_page
end
local cfg_table = {}
cfg_table.fwupdate = {
webvars = {
enabled = "emailnotify:settings/fwupdatehint_enabled",
mailto = "emailnotify:settings/fwupdatehint_To"
},
explain = [[{?638:386?}]],
title = [[{?638:321?}]],
help = "hilfe_system_pushservice_fwupdate.html"
}
cfg_table.connectmail = {
webvars = {
enabled = "emailnotify:settings/enable_connect_mail",
mailto = "emailnotify:settings/connect_mail_To"
},
explain = [[{?638:678?}]],
title = [[{?638:467?}]],
help = "hilfe_system_pushservice_connectmail.html"
}
cfg_table.cfgexport = {
webvars = {
enabled = "emailnotify:settings/configexport_enabled",
mailto = "emailnotify:settings/configexport_To",
passwd = "emailnotify:settings/configexport_passwd"
},
explain = [[{?638:245?}]],
title = [[{?638:944?}]],
help = "hilfe_system_pushservice_cfgexport.html"
}
cfg_table.tam = {
type = "tam",
webvars = {
enabled = "tam:settings/TAM%d/PushmailActive",
mailto = "tam:settings/TAM%d/MailAddress",
delfromtam = ""
},
explain = [[{?638:589?}]],
title = [[{?638:957?}]],
help = "hilfe_system_pushservice_tam.html"
}
cfg_table.smarthome = {
type = "smarthome",
webvars = {},
help = "hilfe_system_pushservice_smarthome.html",
title = [[{?638:495?}]]
}
cfg_table.wlan_guest = {
type = "wlan_guest",
webvars = {
enabled = "emailnotify:settings/wlangueststatus_enabled",
counter = "emailnotify:settings/wlangueststatus_counter",
mailto = "emailnotify:settings/wlangueststatus_To"
},
help = "hilfe_system_pushservice_wlan_guest.html",
explain = [[{?638:253?}]],
title = [[{?638:401?}]]
}
cfg_table.pwdlost = {
type = "pwdlost",
webvars = {
enabled = "emailnotify:settings/reset_pwd_enabled"
},
help = "hilfe_system_pushservice_kennwort_vergessen.html",
explain = [[{?638:532?}]],
title = [[{?638:328?}]]
}
local function read_cfg()
local edit = box.get.edit or box.post.edit or ""
local idx
if string.find(edit, "tam") == 1 then
edit, idx = string.match(edit, "^(tam)(%d+)$")
end
if string.find(edit, "smarthome") == 1 then
edit, idx = string.match(edit, "^(smarthome)(%d+)$")
end
local result = cfg_table[edit or ""]
if result and edit == "tam" then
require"fon_devices"
require"general"
result.idx = idx
for x, webvar in pairs(result.webvars) do
result.webvars[x] = string.format(webvar, idx)
end
result.title = general.sprintf(result.title, fon_devices.get_tamname(idx))
end
if result and edit == "smarthome" then
result.idx = idx
result.device = pushservice.smarthome_get_device(idx)
result.title = general.sprintf(result.title, result.device.Name or "")
end
return result
end
g_cfg = read_cfg()
if not g_cfg then
http.redirect(g_back_to_page)
end
g_page_title = g_cfg.title
g_page_help = g_cfg.help
g_data = {}
local function read_data()
local data = {}
if g_cfg.type == "smarthome" then
data = pushservice.read_data_smarthome(g_cfg.device.pushmailcfg)
else
local webvar = g_cfg.webvars
local enabled = tonumber(box.query(webvar.enabled)) or 0
data.enabled = enabled > 0
if webvar.delfromtam then
data.delfromtam = enabled == 2
end
if webvar.passwd then
data.passwd = box.query(webvar.passwd)
end
data.mailto = pushservice.default_mailto(box.query(webvar.mailto or ""))
end
return data
end
local function refill_data()
local data = {}
data.enabled = box.post.enabled ~= nil
data.mailto = box.post.mailto
data.passwd = box.post.passwd
data.delfromtam = box.post.delfromtam ~= nil
data.TriggerSwitchChange = box.post.TriggerSwitchChange ~= nil
data.interval = box.post.interval
data.periodic = box.post.periodic ~= nil
data.ShowEnergyStat = box.post.ShowEnergyStat
return data
end
local function save_data_tam(saveset)
local webvar = g_cfg.webvars
local enabled = box.post.enabled and "1" or "0"
if box.post.enabled then
enabled = box.post.delfromtam and "2" or "1"
end
cmtable.add_var(saveset, webvar.enabled, enabled)
if box.post.enabled then
cmtable.add_var(saveset, webvar.mailto, general.clear_whitespace(box.post.mailto))
local prefix = string.format([[tam:settings/TAM%d/]], g_cfg.idx or 0)
cmtable.add_var(saveset, prefix .. "PushmailServer", "")
cmtable.add_var(saveset, prefix .. "PushmailUser", "")
cmtable.add_var(saveset, prefix .. "PushmailPass", "")
cmtable.add_var(saveset, prefix .. "PushmailFrom", "")
end
end
local function save_data(saveset)
if g_cfg.type == "smarthome" then
pushservice.save_data_smarthome(g_cfg.device.pushmailcfg)
elseif g_cfg.type == "tam" then
save_data_tam(saveset)
else
local webvar = g_cfg.webvars
cmtable.add_var(saveset, webvar.enabled, box.post.enabled and "1" or "0")
if box.post.enabled then
if webvar.mailto then
cmtable.add_var(saveset, webvar.mailto, general.clear_whitespace(box.post.mailto))
end
if webvar.passwd then
cmtable.add_var(saveset, webvar.passwd, box.post.passwd)
end
end
end
if g_cfg.type == "smarthome" then
return 0
end
return box.set_config(saveset)
end
local function validation()
if g_cfg.webvars.passwd then
newval.msg.pwd = {
[newval.ret.empty] = [[{?638:302?}]]
}
end
if g_cfg.type == "smarthome" then
pushservice.smarthome_validation()
elseif g_cfg.webvars.mailto then
pushservice.mailto_validation()
end
if g_cfg.webvars.passwd then
if newval.checked("enabled") then
newval.not_empty("passwd", "pwd")
end
end
end
function gethtml_delfromtam()
if g_cfg.webvars.delfromtam then
local name, id = "delfromtam", "uiDelfromtam"
return html.div{class="formular",
html.input{type="checkbox", name=name, id=id, checked=g_data[name]},
html.label{['for']=id,
[[{?638:818?}]]
}
}
end
end
function gethtml_passwd()
if g_cfg.webvars.passwd then
local name, id = "passwd", "uiPasswd"
return html.fragment(
html.div{class="formular widetext",
html.p{[[{?638:733?}]]},
html.label{['for']=id, [[{?638:64?}]]},
html.input{
type="text", name=name, id=id, autocomplete="off", value=g_data[name]
}
},
html.div{class="formular",
html.strong{[[{?txtHinweis?}]]},
html.p{[[{?638:402?}]]},
html.p{
[[{?638:901?}]]
}
}
)
end
end
function gehthtml_mailto(data)
if g_cfg.type == "pwdlost" then
return html.div{class="formular widetext",
html.span{class="label", [[{?638:397?}]]},
html.span{class="output", pushservice.default_mailto()},
html.div{
html.strong{[[{?txtHinweis?}]]},
html.p{html.raw(general.sprintf(
box.tohtml([[{?638:1390?}]]),
[[<a href="]]..href.get([[/system/push_account.lua]])..[[">]],
[[</a>]]))
}
}
}
else
return pushservice.gethtml_mailto(g_data)
end
end
function write_html()
if g_cfg.type == "smarthome" then
pushservice.smarthome_write_explain()
html.hr{}.write()
pushservice.smarthome_writehtml{data=g_data}
else
html.p{g_cfg.explain}.write()
html.hr{}.write()
pushservice.gethtml_enabled(g_data).write()
html.div{class="enableif_enabled",
gehthtml_mailto(),
gethtml_passwd(),
gethtml_delfromtam()
}.write()
end
end
function write_error()
if g_err.code and g_err.code ~= 0 then
require"general"
box.out(general.create_error_div(g_err.code, g_err.msg))
end
end
g_err = {code=0}
if box.post.validate == "apply" then
local valresult, answer = newval.validate(validation)
box.out(js.table(answer))
box.end_page()
end
if box.post.cancel then
http.redirect(href.get(g_back_to_page, http.url_param("list", box.post.list)))
elseif box.post.apply then
g_data = refill_data()
if newval.validate(validation) == newval.ret.ok then
local saveset = {}
g_err.code, g_err.msg = save_data(saveset)
if g_err.code == 0 then
http.redirect(href.get(g_back_to_page, http.url_param("list", box.post.list)))
end
end
else
g_data = read_data()
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
.formular span.label {
display: inline-block;
width: 200px;
margin-right: 6px;
}
</style>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<?lua href.default_submit('apply') ?>
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<input type="hidden" name="edit" value="<?lua box.html(box.get.edit or box.post.edit or '') ?>">
<input type="hidden" name="list" value="<?lua box.html(box.get.list or box.post.list or '') ?>">
<input type="hidden" name="back_to_page" value="<?lua box.html(g_back_to_page) ?>">
<?lua write_error() ?>
<?lua write_html() ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">{?txtOK?}</button>
<button type="submit" name="cancel">{?txtCancel?}</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<script type="text/javascript" src="/js/ajax.js"></script>
<script type="text/javascript" src="/js/validation.js"></script>
<script type="text/javascript" src="/js/handlers.js"></script>
<script type="text/javascript" src="/js/password_checker.js"></script>
<script type="text/javascript">
function init() {
enableOnClick({
inputName: "enabled",
classString: "enableif_enabled"
});
enableOnClick({
inputName: "periodic",
classString: "enableif_periodic"
});
createPasswordChecker( "uiPasswd" );
}
ready.onReady(init);
ready.onReady(ajaxValidation());
</script>
<?include "templates/html_end.html" ?>
