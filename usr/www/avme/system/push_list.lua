<?lua
g_page_type = "all"
g_page_title = ""
g_page_help = "hilfe_system_pushservice_list.html"
dofile("../templates/global_lua.lua")
require"href"
require"html"
require"http"
require"general"
require"pushservice"
require"js"
require"cmtable"
g_push = {}
if pushservice.available.info then
table.insert(g_push, {
id = "info",
text = [[{?93:794?}]],
enabled = pushservice.info_active(),
mailto = pushservice.info.To or "",
link = href.get("/system/push_edit_info.lua")
})
end
do
if config.TAM_MODE and config.TAM_MODE > 0 then
if #pushservice.tam.list > 0 then
local p = {
id = "tam",
text = [[{?93:702?}]],
enabled = pushservice.tam_active()
}
if #pushservice.tam.list > 1 then
p.link = href.get("/system/push_editlist.lua", http.url_param("list", "tam"))
else
local idx = pushservice.tam.list[1].idx or 0
p.link = href.get("/system/push_edit.lua", http.url_param("edit", "tam" .. idx))
p.mailto = pushservice.tam.list[1].MailAddress or ""
end
table.insert(g_push, p)
end
end
end
if config.FON then
local p = {
id = "calls",
text = [[{?93:470?}]],
enabled = pushservice.calls_active(),
link = href.get("/system/push_edit_calls.lua")
}
if not pushservice.calls_any_number_active() then
p.mailto = pushservice.calls.list[1].Address or ""
end
table.insert(g_push, p)
end
if config.HOME_AUTO then
if #pushservice.smarthome.list > 0 then
local p = {
id = "smarthome",
text = [[{?93:879?}]],
enabled = pushservice.smarthome_active()
}
if #pushservice.smarthome.list > 1 then
p.link = href.get("/system/push_editlist.lua", http.url_param("list", "smarthome"))
else
local idx = pushservice.smarthome.list[1].ID
p.link = href.get("/system/push_edit.lua", http.url_param("edit", "smarthome" .. idx))
p.mailto = pushservice.smarthome.list[1].pushmailcfg.email or ""
end
table.insert(g_push, p)
end
end
if config.WLAN_GUEST then
table.insert(g_push, {
id = "wlan_guest",
text = [[{?93:135?}]],
enabled = pushservice.wlan_guest.wlangueststatus_enabled == "1",
mailto = pushservice.wlan_guest.wlangueststatus_To or "",
link = href.get("/system/push_edit.lua", http.url_param("edit", "wlan_guest"))
})
end
if config.FON and config.FAX2MAIL then
local fax_active = tonumber(pushservice.fax.FaxMailActive)
if fax_active then
table.insert(g_push, {
id = "fax",
text = [[{?93:79?}]],
enabled = pushservice.fax_active(),
mailto = pushservice.fax.FaxMailAddress or "",
link = href.get("/fon_devices/edit_fax_option.lua",
http.url_param("back_to_page", box.glob.script), http.url_param("notabs", "")
)
})
end
end
require"menu"
if menu.check_page("system", "/system/update.lua") then
table.insert(g_push, {
id = "fwupdate",
text = [[{?93:289?}]],
enabled = pushservice.fwupdate.fwupdatehint_enabled == "1",
mailto = pushservice.fwupdate.fwupdatehint_To or "",
link = href.get("/system/push_edit.lua", http.url_param("edit", "fwupdate"))
})
end
if pushservice.available.cfgexport then
table.insert(g_push, {
id = "cfgexport",
text = [[{?93:872?}]],
enabled = pushservice.cfgexport.configexport_enabled == "1",
mailto = pushservice.cfgexport.configexport_To or "",
link = href.get("/system/push_edit.lua", http.url_param("edit", "cfgexport"))
})
end
if pushservice.available.pwdlost then
table.insert(g_push, {
id = "pwdlost",
text = [[{?93:971?}]],
enabled = pushservice.pwdlost.reset_pwd_enabled == "1",
mailto = pushservice.default_mailto(),
link = href.get("/system/push_edit.lua", http.url_param("edit", "pwdlost"))
})
end
if pushservice.available.connectmail then
table.insert(g_push, {
id = "connectmail",
text = [[{?93:587?}]],
enabled = pushservice.connectmail.enable_connect_mail == "1",
mailto = pushservice.connectmail.connect_mail_To or "",
link = href.get("/system/push_edit.lua", http.url_param("edit", "connectmail"))
})
end
local save = {}
function save.info(saveset, p)
local enable = box.post.enable_info == "info"
if enable and not p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/infoenabled", "1")
local mailto = pushservice.default_mailto(p.mailto)
cmtable.add_var(saveset, "emailnotify:settings/To", mailto)
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/infoenabled", "0")
end
end
function save.wlan_guest(saveset, p)
local enable = box.post.enable_wlan_guest == "wlan_guest"
if enable and not p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/wlangueststatus_enabled", "1")
local mailto = pushservice.default_mailto(p.mailto)
cmtable.add_var(saveset, "emailnotify:settings/wlangueststatus_To", mailto)
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/wlangueststatus_enabled", "0")
end
end
function save.tam(saveset, p)
local enable = box.post.enable_tam == "tam"
local webvar
if enable and not p.enabled then
for i, tam in ipairs(pushservice.tam.list) do
webvar = string.format([[tam:settings/TAM%d]], tam.idx)
cmtable.add_var(saveset, webvar .. "/PushmailActive", "1")
if tam.MailAddress == "" then
cmtable.add_var(saveset, webvar .. "/MailAddress", pushservice.default_mailto())
end
end
elseif not enable and p.enabled then
for i, tam in ipairs(pushservice.tam.list) do
webvar = string.format([[tam:settings/TAM%d]], tam.idx)
cmtable.add_var(saveset, webvar .. "/PushmailActive", "0")
end
end
end
function save.calls(saveset, p)
local enable = box.post.enable_calls == "calls"
local webvar = [[telcfg:settings/NotifyEmail]]
if enable and not p.enabled then
cmtable.add_var(saveset, webvar .. "/Active", "1")
cmtable.add_var(saveset, webvar .. "/MSN", "")
if not p.mailto or p.mailto == "" then
cmtable.add_var(saveset, webvar .. "/Address", pushservice.default_mailto())
end
elseif not enable and p.enabled then
for idx in ipairs(pushservice.calls.list) do
cmtable.add_var(saveset, webvar .. (idx-1) .. "/Active", "0")
end
end
end
function save.fax(saveset, p)
local enable = box.post.enable_fax == "fax"
local value = tonumber(pushservice.fax.FaxMailActive) or 0
if enable and not p.enabled then
value = value + 1
cmtable.add_var(saveset, "telcfg:settings/FaxMailActive", tostring(value))
if p.mailto == "" then
cmtable.add_var(saveset, "telcfg:settings/FaxMailAddress", pushservice.default_mailto())
end
elseif not enable and p.enabled then
value = math.max(value - 1, 0)
cmtable.add_var(saveset, "telcfg:settings/FaxMailActive", tostring(value))
end
end
function save.smarthome(saveset, p)
local enable = box.post.enable_smarthome == "smarthome"
local cfg
if enable and not p.enabled then
for i, dev in ipairs(pushservice.smarthome.list) do
cfg = pushservice.smarthome_get_cfg(dev)
pushservice.save_default_smarthome(cfg)
end
elseif not enable and p.enabled then
for i, dev in ipairs(pushservice.smarthome.list) do
cfg = pushservice.smarthome_get_cfg(dev)
cfg.ID = cfg.ID or dev.ID
cfg.activ = 0
aha.SetPushMailConfig(cfg.ID, cfg)
end
end
end
function save.cfgexport(saveset, p)
local enable = box.post.enable_cfgexport == "cfgexport"
if enable and not p.enabled then
if pushservice.cfgexport.configexport_passwd ~= "" then
cmtable.add_var(saveset, "emailnotify:settings/configexport_enabled", "1")
if p.mailto == "" then
cmtable.add_var(saveset, "emailnotify:settings/configexport_To", pushservice.default_mailto())
end
end
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/configexport_enabled", "0")
end
end
function save.fwupdate(saveset, p)
local enable = box.post.enable_fwupdate == "fwupdate"
if enable and not p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/fwupdatehint_enabled", "1")
if p.mailto == "" then
cmtable.add_var(saveset, "emailnotify:settings/fwupdatehint_To", pushservice.default_mailto())
end
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/fwupdatehint_enabled", "0")
end
end
function save.connectmail(saveset, p)
local enable = box.post.enable_connectmail == "connectmail"
if enable and not p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/enable_connect_mail", "1")
if p.mailto == "" then
cmtable.add_var(saveset, "emailnotify:settings/connect_mail_To", pushservice.default_mailto())
end
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/enable_connect_mail", "0")
end
end
function save.pwdlost(saveset, p)
local enable = box.post.enable_pwdlost == "pwdlost"
if enable and not p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/reset_pwd_enabled", "1")
elseif not enable and p.enabled then
cmtable.add_var(saveset, "emailnotify:settings/reset_pwd_enabled", "0")
end
end
if box.post.edit then
local _, toedit = array.find(g_push, func.eq(box.post.edit, "id"))
if toedit and toedit.link then
http.redirect(toedit.link)
end
end
if box.post.apply then
local saveset = {}
for i, p in ipairs(g_push) do
if save[p.id] then
save[p.id](saveset, p)
end
end
local e, m = box.set_config(saveset)
if e == 0 then
http.redirect(box.glob.script)
end
end
local function edit_btn(p)
if p.id then
return html.button{
type="submit", class="icon", name="edit", value=p.id,
html.img{
src="/css/default/images/bearbeiten.gif",
title = [[{?txtIconBtnEdit?}]]
}
}
end
end
local function details(p)
if p.mailto then
return pushservice.display_mailto(p.mailto)
else
return html.a{href=p.link, class="textlink", [[{?93:211?}]]}
end
end
local function enable_checkbox(p)
if p.id then
return html.input{
type='checkbox', name="enable_"..p.id, id="uiEnable_"..p.id, value=p.id, checked=p.enabled
}
end
end
local function enable_label(p)
if p.id then
return html.label{
['for']="uiEnable_" .. p.id, p.text
}
else
return p.text
end
end
function write_list()
local tbl = html.table{class="zebra", id="uiPushlist"}
tbl.add(html.tr{class="thead",
html.th{},
html.th{class="name sortable",
[[{?93:996?}]],
html.span({class="sort_no",html.raw([[&nbsp;]])})
},
html.th{class="sortable",
[[{?93:372?}]],
html.span({class="sort_no",html.raw([[&nbsp;]])})
},
html.th{class="btncolumn"}
})
if not pushservice.account_configured() then
tbl.add(html.tr{class="emptylist",
html.td{colspan=4,
[[{?93:346?}]]
}
})
else
for i, p in ipairs(g_push) do
tbl.add(html.tr{
html.td{enable_checkbox(p)},
html.td{class="name", enable_label(p)},
html.td{details(p)},
html.td{class="btncolumn", edit_btn(p)}
})
end
end
tbl.write()
end
function write_wizard_link()
if not pushservice.account_configured() then
html.div{class="btn_form",
html.a{class="textlink", href=href.get("/assis/pushmail_account.lua"),
[[{?93:632?}]]
}
}.write()
end
end
function write_notime_hint()
if box.query("box:status/localtime") == "" then
html.br{}.write()
html.strong{[[{?txtHinweis?}]]}.write()
html.p{
[[{?93:457?}]]
}.write()
end
end
function write_checkbox_msg_js()
local result = {}
if pushservice.cfgexport.configexport_passwd == "" then
result.cfgexport = {
onchecked = true,
alert = table.concat({
[[{?93:535?}]],
[[\n]],
[[{?93:396?}]]
})
}
end
local fax_active = tonumber(pushservice.fax.FaxMailActive) or 0
if fax_active < 2 then
result.fax = {
onchecked = false,
confirm = table.concat({
[[{?93:295?}]],
[[\n\n]],
[[{?93:102?}]]
})
}
end
box.out(js.table(result))
end
?>
<?include "templates/html_head.html" ?>
<style type="text/css">
#uiPushlist tr th:first-child,
#uiPushlist tr td:first-child {
text-align: center;
width: 24px;
}
#uiPushlist tr td:first-child input {
vertical-align: baseline;
}
#uiPushlist th.name,
#uiPushlist td.name {
width: 200px;
}
</style>
<script type="text/javascript" src="/js/sort.js"></script>
<script type="text/javascript" src="/js/ready.js"></script>
<script type="text/javascript" src="/js/jxl.js"></script>
<script type="text/javascript">
var gPush = <?lua box.out(js.table(g_push)) ?>;
var sort = sorter();
function initCheckboxHandler() {
var msgs = <?lua write_checkbox_msg_js() ?>;
function onCheckbox(evt) {
var ch = jxl.evtTarget(evt);
if (ch.type == "checkbox") {
var msg = msgs[ch.value];
if (msg) {
if (msg.onchecked == ch.checked) {
if (msg.alert) {
alert(msg.alert);
return jxl.cancelEvent(evt);
}
if (msg.confirm) {
if (!confirm(msg.confirm)) {
return jxl.cancelEvent(evt);
}
}
}
}
}
}
var frm = document.forms.mainform;
jxl.addEventHandler(frm, "click", onCheckbox);
}
function initTableSorter() {
sort.init("uiPushlist");
sort.sort_table_again(1);
}
ready.onReady(initTableSorter);
ready.onReady(initCheckboxHandler);
</script>
<?include "templates/page_head.html" ?>
<form name="mainform" method="POST" action="<?lua box.html(box.glob.script) ?>">
<input type="hidden" name="sid" value="<?lua box.html(box.glob.sid) ?>">
<p>
{?93:93?}
</p>
<?lua write_notime_hint() ?>
<hr>
<?lua write_list() ?>
<?lua write_wizard_link() ?>
<div id="btn_form_foot">
<button type="submit" name="apply" id="uiApply">
{?txtApply?}
</button>
<button type="submit" name="cancel">
{?txtCancel?}
</button>
</div>
</form>
<?include "templates/page_end.html" ?>
<?include "templates/html_end.html" ?>
